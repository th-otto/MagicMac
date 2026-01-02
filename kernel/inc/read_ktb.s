FSIZE_MIN		EQU	(9*128)

**********************************************************************
*
* void read_keytbl( void )
*
* Liest die Tastaturtabellen ein (9*128 Bytes)
*

keytbl_fname:
 DC.B	'\GEMSYS\MAGIC\XTENSION\KEYTABLS.SYS',0
	EVEN

read_keytbl:
 movem.l	a6/d6/d7,-(sp)
 suba.w #xattr_sizeof,a7

; Datei zum Lesen oeffnen

 clr.w	-(sp)				; Oeffnen zum Lesen
 pea		keytbl_fname(pc)		; Pfad
 move.w	#$3d,-(sp)			; Fopen
 trap	#1
 addq.l	#8,sp
 move.l	d0,d7
 bmi	rdkt_ende				; nicht gefunden

; determine file size

  move.w #FSTAT,-(a7)
  pea 2(a7)				; &xattr
  move.w d7,-(a7)
  move.w	#$104,-(sp)			; Fcntl
  trap	#1
  lea 10(a7),a7
  tst.l d0
  bmi.s rdkt_close

  move.l xattr_size(a7),d6		; d6 = file size
  cmpi.l #FSIZE_MIN,d6
  bcs.s rdkt_close			; file too small

; Speicher allozieren

 move.w	#2,-(sp)				; lieber ST-RAM
 move.l d6,a0
 pea (N_KEYTBL*4)(a0)		; 10 Zeiger + 10 Tabellen je 128 Bytes
 move.w	#$44,-(sp)			; Mxalloc
 trap	#1
 addq.l	#8,sp
 tst.l	d0
 beq.b	rdkt_close			; nicht genuegend Speicher
 move.l	d0,a6

; Datei einlesen

 pea		(N_KEYTBL*4)(a6)
 move.l	d6,-(sp)		    ; ganze Datei
 move.w	d7,-(sp)
 move.w	#$3f,-(sp)			; Fread
 trap	#1
 lea 12(a7),a7
 sub.l	d6,d0
 bne.b	rdkt_free				; Dateilaenge zu kurz

; Tabellen aktivieren

 move.l	a6,a0
 lea		(N_KEYTBL*4)(a6),a1
 moveq	#N_KEYTBL-1,d0			; Zaehler
rdkt_loop:
 move.l	a1,(a0)+
 lea		128(a1),a1
 dbra	d0,rdkt_loop
 move.l	a6,default_keytblxp		; als Default aktivieren
 IFNE DEADKEYS
 cmpi.l #(9*128),d6
 bne rdkt_inst
 clr.l -4(a0)
rdkt_inst:
 ENDC

 bsr 	_Bioskeys				; richtig aktivieren
 bra.b	rdkt_close

; Speicher freigeben

rdkt_free:
 move.l	a6,-(sp)
 move.w	#73,-(sp) 			; Mfree
 trap	#1
 addq.l	#6,sp

; Datei schliessen

rdkt_close:
 move.w	d7,-(sp)
 move.w	#$3e,-(sp)			; Fclose
 trap	#1
 addq.l	#4,sp

rdkt_ende:
 adda.w #xattr_sizeof,a7
 movem.l	(sp)+,a6/d6/d7
 rts
