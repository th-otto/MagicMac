**********************************************************************
*
* long Puntaes( long magic, int subfn, ... )
*
* ab MagiC vom 13.4.95
*
* <magic> muss 'AnKr' sein.
*
* subfn = 0:   System beenden und zurueck zum MacOS bzw. Windows
* subfn = 1:   Wandle folgenden Alt-Tastencode in ASCII um
* subfn = 2:   Neustart (warm_boot, nur fuer Atari)
* subfn = 3:   Kaltstart (cold_boot, nur fuer Atari)
* subfn = 4:   Getcookie: liefert Zeiger auf Cookie	12.4.98
* subfn = 5:	Date2str: initialisiert datemode und liefert date2str
* subfn = 6:	VT52 anmelden, alten Vektor zurueckgeben
*

Puntaes:
 cmpi.l	#'AnKr',(a0)+			; magic
 bne		pua_ende
 move.w	(a0)+,d0				; subfn
 beq.b	pua_0
 subq.w	#1,d0
 beq.b	pua_1
	IFNE	MACINTOSH
 subq.w	#3,d0
	ELSE
 subq.w   #1,d0
 beq.b    pua_2
 subq.w   #1,d0
 beq.b    pua_3
 subq.w	#1,d0
	ENDIF
 beq.b	pua_4
 subq.w	#1,d0
 beq.b	pua_5
 subq.w	#1,d0
 bne.b	pua_err
* case 6:
 move.l	p_vt52,d0			; Rueckgabe: alter Vektor
 move.l	(a0),d1
 bmi.b	pua6_get			; neuer Vektor -1, nur alten liefern
 beq.b	pua6_reset		; neuer Vektor 0, Vektor loeschen
 move.l	d1,a0			; Struktur
 tst.l	(a0)				; Versionsnummer
 bne.b	pua_6_err			; passt nicht
pua6_reset:
 move.l	d1,p_vt52
pua6_get:
 rte
pua_6_err:
 moveq	#ERANGE,d0
 rte
* case 5:
pua_5:
 move.w	#$012e,datemode	; Default: TMJ/Trenner '.'
 move.l	#'_IDT',d0
 bsr		getcookie
 beq.b	pua5_nf
 andi.w	#$0fff,d1
 move.w	d1,datemode
pua5_nf:
 lea		date2str,a0
 move.l	a0,d0
 rte
* case 4:
pua_4:
 move.l	(a0),d0			; Cookie-Schluessel
 bsr		getcookie
 beq.b	pua4_nf			; nicht gefunden
 move.l	a0,d0			; Zeiger liefern
pua4_nf:
 rte
	IFEQ	MACINTOSH
* case 3:
pua_3:
 bra      cold_boot
* case 2:
pua_2:
 bra      warm_boot
	ENDIF
* case 1:
pua_1:
 move.w	(a0)+,d0
 bsr 	altcode_asc
 rte
* case 0:
pua_0:
	IFNE	MACINTOSH
 tst.l	act_appl.l
 beq.b	pua0_noaes
 jsr		v_clswk				; Auf dem Mac das VDI schliessen
pua0_noaes:
	IFNE	MACOSX
 lea		MSysX+MacSysX_exit(pc),a0
 MACPPC
	ELSE
 move.l	a5,-(sp)
 move.l	MSys+MacSys_a5(pc),a5
 MAC
 DC.W	$a9f4		; _ExitToShell
 ATARI
 move.l	(sp)+,a5
 	ENDIF
	ELSE
; MagicPC kann man beenden
 move.l	magic_pc,d0
 ble.b	pua_0_atari
 DC.W	$47bf,$0001			; Shutdown von MagicPC
; Den Atari kann man nicht beenden
pua_0_atari:
	ENDIF
 moveq	#0,d0
 rte
pua_err:
 moveq	#EINVFN,d0
pua_ende:
 rte
