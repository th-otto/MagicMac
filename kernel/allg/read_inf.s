*
*
* In diesem Modul wird die MAGX.INF geladen und ausgewertet
*
*

	INCLUDE "dos.inc"
	INCLUDE "errno.inc"

	XDEF	read_inf
	XDEF	rinf_sec
	XDEF rinf_tok
	XDEF rinf_nl
	XDEF scan_tok
	XDEF	rinf_vfat,rinf_img,rinf_log
	XDEF	rinf_path
	XDEF	rinf_ul
	XDEF	rinf_coo
	XDEF	rinf_idt
	XDEF	rinf_bdev
	XDEF	rinf_dvh

	XREF	dfs_longnames
	XREF	drive_from_letter

* von STD

	XREF	hexl,putstr,crlf,getch

* von DOS

	XREF	asgndevh			; an READ_INF


DEBUG	EQU	0

	INCLUDE "debug.inc"
	IFNE	DEBUG
	SUPER
	ENDIF

*********************************************************************
*
* void *read_inf( void )
*
* Liest die MAGX.INF vom Wurzelverzeichnis des aktuellen Laufwerks,
* alloziert entsprechend Speicher (ST-RAM preferred) und gibt einen
* Zeiger auf den Puffer (bzw. NULL) zurueck.
* Die Daten werden mit EOS abgeschlossen.
*

inf_s:	DC.B	'\MAGX.INF',0
	EVEN

read_inf:
 movem.l	d7/a6,-(sp)
 suba.w	#xattr_sizeof,sp
 suba.l	a6,a6
; Datei zum Lesen oeffnen
 clr.w	-(sp)			; O_RDONLY
 pea		inf_s(pc)
 move.w	#$3d,-(sp)
 trap	#1				; gemdos Fopen
 addq.l	#8,sp
 move.l	d0,d7
 bmi.b	ri_err			; Lesefehler
; Dateilaenge ermitteln
 move.w	#FSTAT,-(sp)
 pea		2(sp)			; &xattr
 move.w	d7,-(sp)
 move.w	#$104,-(sp)
 trap	#1				; gemdos Fcntl
 adda.w	#10,sp
 tst.l	d0
 bmi.b	ri_err2
; Speicher allozieren
 move.w	#2,-(sp)			; ST-RAM preferred
 move.l	xattr_size+2(sp),-(sp)
 addq.l	#1,(sp)			; Platz fuers Nullbyte lassen!
 move.w	#$44,-(sp)
 trap	#1				; gemdos Mxalloc
 addq.l	#8,sp
 tst.l	d0
 beq.b	ri_err2
; Datei einlesen
 move.l	d0,a6
 move.l	xattr_size(sp),d1
 clr.b	0(a6,d1.l)		; Nullbyte eintragen
 move.l	a6,-(sp)
 move.l	d1,-(sp)
 move.w	d7,-(sp)
 move.w	#$3f,-(sp)
 trap	#1				; gemdos Fread
 adda.w	#12,sp
ri_err2:
; Datei schliessen
 move.w	d7,-(sp)
 move.w	#$3e,-(sp)
 trap	#1				; gemdos Fclose
 addq.l	#4,sp
ri_err:
 move.l	a6,d0			; Adresse oder NULL
 adda.w	#xattr_sizeof,sp
 movem.l	(sp)+,d7/a6
 rts


*********************************************************************
*
* char *rinf_path( a0 = char *line, a1 = char *buf, d0 = LONG buflen )
*
* Liest einen Pfad ein, ueberspringt dazu erstmal Blanks.
* Es wird nichts kopiert, wenn es einen Ueberlauf gibt.
* Rueckgabe: Zeiger hinter den Pfad.
*

_skip_spc:
 cmpi.b	#' ',(a0) 			; SPACE
 beq.b	_sk_sk
 cmpi.b	#9,(a0)				; TAB
 beq.b	_sk_sk
 rts
_sk_sk:
 addq.l	#1,a0
 bra.b	_skip_spc

rinf_path:
 bsr.b	_skip_spc				; Leerzeichen ueberspringen
 move.l	a0,a2				; Beginn des Pfades
rinfp_loop1:
 tst.b	(a0) 				; Zeile bis Leerstelle scannen
 beq.b	rinfp_el1
 cmpi.b	#$d,(a0)
 beq.b	rinfp_el1
 cmpi.b	#' ',(a0)
 beq.b	rinfp_el1
 cmpi.b	#9,(a0)
 beq.b	rinfp_el1
 addq.l	#1,a0
 bra.b	rinfp_loop1
rinfp_el1:
 move.l	a0,d1
 sub.l	a2,d1
 cmp.l	d0,d1
 bcc.b	rinfp_end
rinfp_loop2:
 cmpa.l	a0,a2
 bcc.b	rinfp_end
 move.b	(a2)+,(a1)+
 bra.b	rinfp_loop2
rinfp_end:
 clr.b	(a1)					; buf loeschen
 move.l	a0,d0				; Zeiger hinter den String
 rts


**********************************************************************
*
* EQ/NE d0/a0 ULONG rinf_ul(a0 = char *s)
*
* liest eine "unsigned long" im Dezimalformat ein.
* Rueckgabe: a0 auf erstes ungueltiges Zeichen.
*

rinf_ul:
 bsr.b	_skip_spc				; Leerzeichen ueberspringen
 moveq	#0,d0
 moveq	#0,d1
 move.l	a0,a1
 cmp.b  #'$',(a0)
 beq    rinf_hex
sd_loop:
 move.b	(a0)+,d1
 subi.b	#'0',d1
 bcs.b	sd_endloop
 cmpi.b	#10,d1
 bcc.b	sd_endloop
 add.l	d0,d0
 move.l	d0,d2
 add.l	d0,d0
 add.l	d0,d0
 add.l	d2,d0				; lmulu #10,d0
 add.l	d1,d0
 bra.b	sd_loop
sd_endloop:
 subq.l	#1,a0				; auf erstes ungueltiges Zeichen
 cmpa.l	a1,a0				; Rueckgabe EQ, wenn Fehler
 rts

rinf_hex:
 addq.w #1,a0
sd_hex_loop:
 move.b	(a0)+,d1
 subi.b	#'0',d1
 bcs.b	sd_endloop
 cmpi.b	#10,d1
 bcs.b	sd_hex2
 subi.b #'A'-'0',d1
 bcs.s  sd_endloop
 cmpi.b	#6,d1
 bcs.b	sd_hex1
 subi.b #'a'-'A',d1
 bcs.s  sd_endloop
 cmpi.b	#6,d1
 bcc.b	sd_endloop
sd_hex1:
 add.b  #10,d1
sd_hex2:
 lsl.l  #4,d0
 add.l	d1,d0
 bra.b	sd_hex_loop


*********************************************************************
*
* char *rinf_nl( a0 = char *line )
*
* Setzt den Zeiger auf die naechste Zeile.
* Rueckgabe NULL bei Ende
*

rinf_nl:
 tst.b	(a0)
 beq.b	rinf_nl_null
 cmpi.b	#$a,(a0)+
 bne.b	rinf_nl
rinf_nl_ende:
 move.l	a0,d0
 rts
rinf_nl_null:
 suba.l	a0,a0
 bra.b	rinf_nl_ende


*********************************************************************
*
* char *rinf_sec( a0 = char *inf, a1 = char *section )
*
* Durchsucht die MAGX.INF nach einer Sektion, d.h. z.B. ist
* section == "[aes]".
* Gibt in d0 einen Zeiger auf das erste Zeichen der folgenden
* Zeile zurueck. Bzw. NULL, wenn nicht gefunden.
*

rinf_sec:
 move.l	a1,a2				; token merken
; neue Zeile. Auf Token testen
rinf_loop:
 tst.b	(a0)
 beq.b 	risc_null
 move.l	a2,a1				; gesuchtes Token
 bsr.s		scan_tok				; gefunden ?
 beq.b	rinf_srch_seceol		; nein
rinf_srch_seceol2:
 tst.b	(a0)
 beq.b 	rinf_ende
 cmpi.b	#$a,(a0)+
 bne.b	rinf_srch_seceol2
rinf_ende:
 move.l	a0,d0
 rts
risc_null:
 suba.l	a0,a0				; nix gefunden
 bra.b	rinf_ende
rinf_srch_seceol:
 bsr.b	rinf_nl				; a0 auf naechste Zeile
 bne.b	rinf_loop				; OK
 rts


*********************************************************************
*
* char *rinf_tok( a0 = char *inf, a1 = char *token )
*
* Durchsucht die MAGX.INF innerhalb einer Sektion nach dem naechsten
* Vorkommen eines Token.
* Gibt in d0 und a0 einen Zeiger auf die gefundene Zeile zurueck.
* Rueckgabe NULL, wenn nicht gefunden, d.h. EOF oder die naechste
* Sektion erreicht.
*

rinf_tok:
 move.l	a1,a2				; token merken
; neue Zeile. Auf Token testen
rinft_loop:
 move.b	(a0),d0
 beq.b 	rinft_null
 lsl.w	#8,d0
 move.b	1(a0),d0
 cmpi.w	#'#[',d0				; naechste Section?
 beq.b	rinft_null			; ja, nichts gefunden
 move.l	a0,d2				; Zeiger auf Zeilenanfang merken
 move.l	a2,a1				; gesuchtes Token
 bsr.s		scan_tok				; gefunden ?
 beq.b	rinft_srch_seceol		; nein
 move.l	d2,a0				; Zeiger auf Zeilenanfang zurueck
rinft_ende:
 move.l	a0,d0
 rts
rinft_null:
 suba.l	a0,a0				; nix gefunden
 bra.b	rinft_ende
rinft_srch_seceol:
 bsr.b	rinf_nl				; a0 auf naechste Zeile
 bne.b	rinft_loop			; OK
 rts


**********************************************************************
*
* EQ/NE d0/a0 scan_tok(a0 = char *s, a1 = char *token)
*
* aendert nur d1/d0/a0/a1
* a0 hinter das Token, wenn gefunden
*

scan_tok:
 move.l	a0,d1				; Zeiger merken
scantok_loop:
 tst.b	(a1)
 beq.b	scantok_found
 cmp.b	(a0)+,(a1)+
 beq.b	scantok_loop
 move.l	d1,a0				; a0 restaurieren
 moveq	#0,d0
 rts
scantok_found:
 moveq	#1,d0				; gefunden
 rts


*********************************************************************
*
* void rinf_vfat( a0 = char *inf )
*
* Fuehrt alle Aktionen zur Initialisierung des VFAT-XFS aus der
* MAGX.INF aus. D.h. sucht nach der Section "[vfat]" und nach der
* Zeile "drives="
*

vfat_tok:		DC.B	'#[vfat]',0
vfat_tok2:	DC.B	'drives=',0
	EVEN

rinf_vfat:
 movem.l	a6/d7,-(sp)
 move.l	a0,d0
 beq.s	rivf_ende				; keine INF-Datei
 lea		vfat_tok(pc),a1
 bsr.s		rinf_sec
 tst.l	d0
 beq.b	rivf_ende				; section fehlt
;move.l	d0,a0
 lea		vfat_tok2(pc),a1
 bsr.s		scan_tok
 beq.b	rivf_ende				; token ungueltig
 move.l	a0,a6
 moveq	#0,d7				; noch keine Laufwerke
rivf_loop:
 moveq  #0,d0
 move.b	(a6)+,d0
 bsr	drive_from_letter
 bmi.s	rivf_endloop

; d0 ist jetzt die Laufwerknummer.
rivf_set:
 bset.l	d0,d7				; merken!

; Laufwerk freigeben (unmount)

 move.w	d0,-(sp)				; drv
 move.w	#1,-(sp)				; sperren
 move.w	#$135,-(sp)
 trap	#1					; gemdos Dlock
 tst.l	d0					; Sperren erfolgreich ?
 bmi.b	rivf_err				; nein, wahrscheinlich nicht gemountet
 clr.w	2(sp)				; freigeben!
 trap	#1
 bra.b	rivf_ok
; Laufwerk liess sich nicht sperren, fuer U: lange Namen temporaer
rivf_err:
 move.w	4(sp),d0				; Laufwerk
 cmpi.w	#'U'-'A',d0			; Laufwerk U: ?
 bne.b	rivf_ok				; nein
 move.l	#$413a5c00,-(sp)		; "A:\\"
 add.b	d0,(sp)
 pea		1					; lange Namen einschalten
 pea		4(sp)				; path
 move.l	#$01305601,-(sp)		; Dcntl(VFAT_CNFLN, ...)
 trap	#1
 adda.w	#16,sp
rivf_ok:
 addq.l	#6,sp
 bra.b	rivf_loop				; naechstes Zeichen

; d7.l enthaelt jetzt die Bitmaske

rivf_endloop:
 move.l	d7,dfs_longnames.w

rivf_ende:
 movem.l	(sp)+,d7/a6
 rts


*********************************************************************
*
* void rinf_pth( a0 = char *inf, d0 = char *section,
*				d1 = char *token, a1 = char *path )
*
* Sucht in der Section <section> nach der Zeile <token> und gibt den
* angegebenen Pfad zurueck.
*

rinf_pth:
 move.l	a0,d2
 beq.b	rpth_ende				; keine INF-Datei
 move.l	a1,-(sp)
 move.l	d1,-(sp)
 move.l	d0,a1
 bsr		rinf_sec
 tst.l	d0
 beq.b	rpth_err				; section fehlt
 move.l	d0,a0
 move.l	(sp)+,a1
 bsr		rinf_tok
 beq		rpth_err2				; token ungueltig
 move.l	(sp)+,a1
rpth_loop:
 cmpi.b	#'=',(a0)+
 bne.b	rpth_loop
rpth_cploop:
 move.b	(a0)+,d0
 cmpi.b	#' ',d0
 bcs.b	rpth_ende
 move.b	d0,(a1)+
 bra.b	rpth_cploop

rpth_err:
 addq.l	#4,sp
rpth_err2:
 move.l	(sp)+,a1
rpth_ende:
 clr.b	(a1)					; leerer Pfad
 rts


*********************************************************************
*
* LONG rinf_coo( a0 = char *inf )
*
* Sucht nach der Section "#[boot]" und nach der
* Zeile "cookies=" und gibt die Zahl zurueck. 
*

rinf_coo:
 move.l	a0,d0
 beq.b	rcoo_ok				; keine INF-Datei
 lea		boot_tok(pc),a1
;move.l	a0,a0
 bsr		rinf_sec
 tst.l	d0
 beq.b	rcoo_ok				; section fehlt
 move.l	d0,a0
 lea		coo_tok(pc),a1
 bsr		rinf_tok
 move.l	a0,d0
 beq.b	rcoo_ok				; keine Angabe
 addq.l	#8,a0
 bsr		rinf_ul
rcoo_ok:
 rts


*********************************************************************
*
* LONG rinf_idt( a0 = char *inf )
*
* Sucht nach der Section "#[boot]" und nach der
* Zeile "idt=" und gibt die Zahl zurueck. 
*

rinf_idt:
 move.l	a0,d0
 beq.b	ridt_ok				; keine INF-Datei
 lea		boot_tok(pc),a1
;move.l	a0,a0
 bsr		rinf_sec
 tst.l	d0
 beq.b	ridt_ok				; section fehlt
 move.l	d0,a0
 lea		idt_tok(pc),a1
 bsr		rinf_tok
 move.l	a0,d0
 beq.b	ridt_ok				; keine Angabe
 addq.l	#4,a0
 bsr		rinf_ul
ridt_ok:
 rts


*********************************************************************
*
* LONG rinf_log( a0 = char *inf )
*
* Sucht nach der Section "#[boot]" und nach der
* Zeile "log=" und oeffnet die angegebene Datei zum Schreiben. 
*

rinf_log:
 suba.w	#128,sp
 lea		boot_tok(pc),a1
 move.l	a1,d0
 lea		log_tok(pc),a1
 move.l	a1,d1
 lea		(sp),a1
 bsr		rinf_pth
 tst.b	(sp)
 beq.b	rlog_ende				; keine Datei angegeben

 clr.w	-(sp)				; normale Datei
 pea		2(sp)				; Pfad
 gemdos	Fcreate
 addq.l	#8,sp
 bra.b	rlog_ok
rlog_ende:
 moveq	#ERROR,d0
rlog_ok:
 adda.w	#128,sp
 rts


*********************************************************************
*
* void rinf_img( a0 = char *inf )
*
* Fuehrt alle Aktionen zur Anzeige eines Startbilds aus der
* MAGX.INF aus. D.h. sucht nach der Section "#[boot]" und nach der
* Zeile "image=" und "tiles="
*

	OFFSET

img_buf:		DS.L	1		/* Bild */
img_w:		DS.W	1		/* Bildbreite */
img_h:		DS.W	1		/* Bildhoehe */
img_linew:	DS.W	1		/* Bytes pro Zeile */
img_nplanes:	DS.W	1		/* Tiefe */
img_palette:	DS.L	1		/* Zeiger auf Palette */
img_npal:		DS.W	1		/* Laenge der Palette */

	TEXT

* MFDB

fd_addr		EQU	0
fd_w 		EQU	4
fd_h 		EQU	6
fd_wdwidth	EQU	8
fd_stand		EQU	10
fd_nplanes	EQU	12
fd_sizeof 	EQU	20

	IF	DEBUG
img_lad:		DC.B	'IMG laden => ',0
img_cnv:		DC.B	'IMG => MFDB => ',0
img_cls:		DC.B	'IMG schlie',$9e,'en => ',0
	ENDIF
boot_tok:		DC.B	'#[boot]',0
log_tok:		DC.B	'log=',0
coo_tok:		DC.B	'cookies=',0
idt_tok:		DC.B	'idt=',0
bdv_tok:		DC.B 'biosdev=',0
con_tok:		DC.B	'con=',0
aux_tok:		DC.B	'aux=',0
prn_tok:		DC.B	'prn=',0
tiles_tok:	DC.B	'tiles=',0
img_tok:		DC.B	'image=',0
load_img_slb:	DC.B	'load_img.slb',0
	EVEN

	IMGPATH	SET	0
	TILPATH	SET	IMGPATH+128
	SCRW		SET	TILPATH+128
	SCRH		SET	SCRW+2
	VDIPB	SET	SCRH+2
	VCONTRL	SET	VDIPB+20
	VINTIN	SET	VCONTRL+24	; WORD vcontrl[12]
	VPTSIN	SET	VINTIN+24		; WORD vintin[12]
	VINTOUT	SET	VPTSIN+16		; WORD vptsin[8]
	VPTSOUT	SET	VINTOUT+58+58	; WORD vintout[58]
	IMGFN	SET	VPTSOUT+16	; WORD ptsout[8]
	IMGHDL	SET	IMGFN+4
	IMGDESC	SET	IMGHDL+4
	MFDB		SET	IMGDESC+4
	STACK	SET	MFDB+fd_sizeof

rinf_img:
 suba.w	#STACK,sp

 move.l	a0,-(sp)
 lea		boot_tok(pc),a1
 move.l	a1,d0
 lea		tiles_tok(pc),a1
 move.l	a1,d1
 lea		TILPATH+4(sp),a1		; Pfad kopieren
 bsr		rinf_pth
 move.l	(sp)+,a0

 lea		boot_tok(pc),a1
 move.l	a1,d0
 lea		img_tok(pc),a1
 move.l	a1,d1
 lea		IMGPATH(sp),a1			; Pfad kopieren
 bsr		rinf_pth

 tst.b	TILPATH(sp)
 bne.b	rimg_go
 tst.b	IMGPATH(sp)
 beq		rimg_ende				; keine Datei angegeben

* VDIPB initialisieren

rimg_go:
 lea		VDIPB(sp),a0
 lea		VCONTRL(sp),a1
 move.l	a1,(a0)+
 lea		VINTIN(sp),a1
 move.l	a1,(a0)+
 lea		VPTSIN(sp),a1
 move.l	a1,(a0)+
 lea		VINTOUT(sp),a1
 move.l	a1,(a0)+
 lea		VPTSOUT(sp),a1
 move.l	a1,(a0)

* Workstation oeffnen (zunaechst mit Geraetenummer 1)

 lea		VINTIN(sp),a1
 move.w	#1,(a1)+				; VDI-Device
 moveq	#8,d0
rimg_loop2:
 move.w	#1,(a1)+
 dbf 	d0,rimg_loop2
 move.w	#2,(a1)+				; RC- Koordinaten

; fuer NVDI:
;  move.l	#'XRES',(a1)+
;  move.w	dflt_xdv,(a1)
; move.w	dflt_xdv,VPTSOUT(sp)	; FALCON!!!

 lea		VCONTRL(sp),a1
 move.w	#1,(a1)+				; open workstation
 clr.l	(a1)+				; kein ptsin/ptsout
 move.w	#11,(a1)+				; 11 intin-Werte (NVDI: 12)
 clr.l (a1)+
 clr.w (a1)
 lea		VDIPB(sp),a0
 move.l	a0,d1
 moveq	#$73,d0
 trap	#2
 tst.w	VCONTRL+12(sp)			; Handle OK?
 beq		rimg_ende				; nein, Fehler

 move.l	VINTOUT(sp),SCRW(sp)	; Bildschirmgroesse-1
 addq.w	#1,SCRW(sp)
 addq.w	#1,SCRH(sp)			; VDI => AES

*
* LOAD_IMG.SLB laden
*

 lea		(sp),a0
 clr.l	-(sp)				; param = NULL
 pea		IMGFN(a0)
 pea		IMGHDL(a0)
 clr.l	-(sp)				; min_ver
 clr.l	-(sp)				; path
 pea		load_img_slb(pc)
 move.w	#$16,-(sp)			; Slbopen
 trap	#1
 adda.w	#26,sp
 tst.l	d0
 bmi		rimg_closews			; Fehler

*
* Kacheln laden
*

 tst.b	TILPATH(sp)			; Kacheln?
 beq		rimg_loadcntr			; nein, nur zentriertes Bild

 lea		(sp),a0
 pea		IMGDESC(a0)			; Deskriptor ermitteln
 pea		TILPATH(a0)			; Pfad
 move.w	#4,-(sp)				; 4 WORDs uebergeben
 clr.l	-(sp)				; Funktion #0
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#18,sp

 tst.l	d0
 bmi		rimg_loadcntr			; Datei nicht gefunden

*
* Kachel in MFDB wandeln
*

 lea		(sp),a0
 move.w	VCONTRL+12(a0),-(sp)	; VDI-Handle
 move.w	#256,-(sp)			; max_pen
 move.w	#16,-(sp)				; min_index
 pea		MFDB(a0)				; mfdb ermitteln
 move.l	IMGDESC(a0),-(sp)		; Deskriptor uebergeben
 move.w	#7,-(sp)				; 7 WORDs uebergeben
 move.l	#2,-(sp)				; Funktion #2
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#24,sp

 tst.l	d0
 bmi.b	rimg_free_til			; Zuwenig Speicher?

*
* Kachel zeichnen
*

 lea		(sp),a0
 move.l	SCRW(a0),-(sp)
 clr.l	-(sp)				; clipg = ganzer Bildschirm
 move.l	SCRW(a0),-(sp)
 clr.l	-(sp)				; objg = ganzer Bildschirm

 pea		8(sp)				; &clipg
 pea		4(sp)				; &g

 pea		MFDB(a0)				; mfdb
 move.w	VCONTRL+12(a0),-(sp)	; VDI-Handle
 move.w	#7,-(sp)				; 7 WORDs uebergeben
 move.l	#4,-(sp)				; Funktion #4
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#40,sp

*
* MFDB fuer Kachel freigeben
*

 move.l	IMGHDL(sp),a0
 move.l	img_buf(a0),a0
 cmpa.l	MFDB+fd_addr(sp),a0		; extra-Puffer fuer exp. Bild?
 beq.b	rimg_free_til
 move.l	MFDB+fd_addr(sp),-(sp)
 gemdos	Mfree
 addq.l	#6,sp

*
* Kachel freigeben
*

rimg_free_til:
 lea		(sp),a0
 move.l	IMGDESC(a0),-(sp)		; Deskriptor freigeben
 move.w	#2,-(sp)				; 2 WORDs uebergeben
 move.l	#1,-(sp)				; Funktion #1
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#14,sp

*
* IMG laden
*

rimg_loadcntr:
 tst.b	IMGPATH(sp)
 beq		rimg_closeimgslb		; kein zentriertes Bild

 lea		(sp),a0
 pea		IMGDESC(a0)			; Deskriptor ermitteln
 pea		IMGPATH(a0)			; Pfad
 move.w	#4,-(sp)				; 4 WORDs uebergeben
 clr.l	-(sp)				; Funktion #0
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#18,sp

 tst.l	d0
 bmi		rimg_closeimgslb		; Datei nicht gefunden

* Bild-Ausmasse testen

 move.l	IMGDESC(sp),a0
 move.w	img_w(a0),d0			; Bildbreite
 cmp.w	SCRW(sp),d0
 bhi		rimg_free_img			; Bild zu breit
 move.w	img_h(a0),d0			; Bildhoehe
 cmp.w	SCRH(sp),d0
 bhi		rimg_free_img			; Bild zu hoch

* IMG in MFDB wandeln

 lea		(sp),a0
 move.w	VCONTRL+12(a0),-(sp)	; VDI-Handle
 move.w	#256,-(sp)			; max_pen
 move.w	#16,-(sp)				; min_index
 pea		MFDB(a0)				; mfdb ermitteln
 move.l	IMGDESC(a0),-(sp)		; Deskriptor uebergeben
 move.w	#7,-(sp)				; 7 WORDs uebergeben
 move.l	#2,-(sp)				; Funktion #2
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#24,sp

 tst.l	d0
 bmi.b	rimg_free_img			; Zuwenig Speicher?

* IMG zeichnen

 lea		(sp),a0

 move.l	IMGDESC(a0),a1
 move.w	SCRH(a0),d0			; Bildschirmhoehe
 sub.w	img_h(a1),d0			; - Bildhoehe
 lsr.w	#1,d0
 move.w	d0,-(sp)				; y

 move.w	SCRW(a0),d0			; Bildschirmbreite
 sub.w	img_w(a1),d0			; Bildbreite
 lsr.w	#1,d0
 move.w	d0,-(sp)				; x

 pea		MFDB(a0)				; mfdb
 move.w	VCONTRL+12(a0),-(sp)	; VDI-Handle
 move.w	#5,-(sp)				; 5 WORDs uebergeben
 move.l	#3,-(sp)				; Funktion #3
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#20,sp


*
* MFDB fuer Bild freigeben
*

 move.l	IMGHDL(sp),a0
 move.l	img_buf(a0),a0
 cmpa.l	MFDB+fd_addr(sp),a0		; extra-Puffer fuer exp. Bild?
 beq.b	rimg_free_img
 move.l	MFDB+fd_addr(sp),-(sp)
 gemdos	Mfree
 addq.l	#6,sp

*
* IMG freigeben
*

rimg_free_img:
 lea		(sp),a0
 move.l	IMGDESC(a0),-(sp)		; Deskriptor freigeben
 move.w	#2,-(sp)				; 2 WORDs uebergeben
 move.l	#1,-(sp)				; Funktion #1
 move.l	IMGHDL(a0),-(sp)		; Bib-Deskriptor
 move.l	IMGFN(a0),a1
 jsr		(a1)					; SLB aufrufen
 adda.w	#14,sp

*
* LOAD_IMG.SLB schliessen
*

rimg_closeimgslb:
 move.l	IMGHDL(sp),-(sp)
 move.w	#$17,-(sp)			; Slbclose
 trap	#1
 addq.l	#6,sp

* WS schliessen

rimg_closews:
 lea		VCONTRL(sp),a1
 move.w	#2,(a1)+				; close workstation
 clr.w	(a1)+
 addq.l	#2,a1
 clr.w	(a1)
 lea		VDIPB(sp),a0
 move.l	a0,d1
 moveq	#$73,d0
 trap	#2

rimg_ende:
 adda.w	#STACK,sp
 rts


*********************************************************************
*
* LONG rinf_bdev( a0 = char *inf )
*
* Sucht nach der Section "#[boot]" und bearbeitet alle
* Zeilen "biosdev=<n>,<devpath>". 
*

rinf_bdev:
 movem.l	d7/a6,-(sp)
	DEBON
	DEB	'Read device information'
 suba.w	#80,sp
 move.l	a0,d0
 beq		rbd_ok				; keine INF-Datei
 lea		boot_tok(pc),a1
;move.l	a0,a0
 bsr		rinf_sec
 tst.l	d0
 beq		rbd_ok				; section fehlt
; Schleife
rbd_loop:
 lea		bdv_tok(pc),a1
 bsr		rinf_tok
 move.l	a0,d0
 beq		rbd_ok				; Ende
 addq.l	#8,a0
	DEBL	a0,'Zeile = '
 bsr		rinf_ul
 move.l	d0,d7				; BIOS-Geraetenummer
	DEBL	a0,'Zeile2 = '
	DEBL d7,'BIOS-Ger',$84,'t'
 cmpi.b	#',',(a0)+
 bne.b	rbd_nxt				; Fehler
 moveq	#80,d0				; Puffergroesse
 lea		(sp),a1				; Puffer
;move.l	a0,a0
 bsr		rinf_path				; Pfad einlesen
	DEBT	a7,'Pfad = '
 tst.b	(sp)
 beq.b	rbd_nxt				; Pfad ist leer

; Geraet anmelden
 move.l	a0,a6				; inf retten

 move.l	d7,-(sp)				; BIOS-Nummer
 clr.l	-(sp)				; leerer Geraetetreiber
 pea		(sp)					; Treiber-Informationen
 pea		12(sp)				; Pfad
 move.w	#MX_DEV_INSTALL2,-(sp)
 gemdos	Dcntl
 adda.w	#20,sp
 
 move.l	a6,a0				; inf zurueck

rbd_nxt:
 bsr		rinf_nl
 move.l	a0,d0
 bne		rbd_loop
rbd_ok:
 adda.w	#80,sp
	DEBOFF
 movem.l	(sp)+,d7/a6
 rts


*********************************************************************
*
* LONG rinf_dvh( a0 = char *inf )
*
* Sucht nach der Section "#[boot]" und bearbeitet alle
* Zeilen "biosdev=<n>,<devpath>". 
*

rinf_dvh:
 move.l	a0,-(sp)
 lea		con_tok(pc),a1
 moveq	#-1,d0
 bsr.s		_rinf_dvh				; fuer Handle -1 (CON)
 move.l	(sp),a0
 lea		aux_tok(pc),a1
 moveq	#-2,d0
 bsr.s		_rinf_dvh				; fuer Handle -2 (AUX)
 move.l	(sp)+,a0
 lea		prn_tok(pc),a1
 moveq	#-3,d0
;bra.b	_rinf_dvh


*********************************************************************
*
* LONG _rinf_dvh( a0 = char *inf, a1 = char *token, d0 = WORD devhdl )
*
* Sucht nach der Section "#[boot]" und bearbeitet das Token, indem
* das jeweilige Handle zugewiesen wird.
*

_rinf_dvh:
 movem.l	d7/a6,-(sp)
	DEBON
	DEB	'Read device handle information'
 move.w	d0,d7				; d7 = Handle
 move.l	a1,a6				; a6 = Token
 suba.w	#80,sp
 move.l	a0,d0
 beq		dvh_ok				; keine INF-Datei
 lea		boot_tok(pc),a1
;move.l	a0,a0
 bsr		rinf_sec
 tst.l	d0
 beq		dvh_ok				; section fehlt

 move.l	a6,a1
 bsr		rinf_tok
 move.l	a0,d0
 beq		dvh_ok				; Ende

dvh_loop:
 cmpi.b	#'=',(a0)+
 bne.b	dvh_loop

 moveq	#80,d0				; Puffergroesse
 lea		(sp),a1				; Puffer
;move.l	a0,a0
 bsr		rinf_path				; Pfad einlesen

; Geraete-Handle zuweisen

 lea		(sp),a0				; Pfad
 move.w	d7,d0				; Geraetehandle
 jsr		asgndevh
 
dvh_ok:
 adda.w	#80,sp
	DEBOFF
 movem.l	(sp)+,d7/a6
 rts
