	XDEF	Cconws
	XDEF	Dgetdrv
	XDEF	Dgetpath
	XDEF	Fgetdta
	XDEF	Fsetdta
	XDEF	Fsfirst
	XDEF	Fsnext
	XDEF	Fcreate
	XDEF	Fopen
	XDEF	Fseek
	XDEF	Fread
	XDEF	Fclose
	XDEF	Fwrite
	XDEF	Malloc_sys
	XDEF	Mfree_sys
	XDEF	Mshrink_sys

	XDEF	Bconin
	XDEF	Bconout

	TEXT

;LONG	Bconin( WORD dev );
Bconin:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts


;void	Bconout( WORD dev, WORD c );
Bconout:
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;WORD	Cconws( const BYTE *buf );
Cconws:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;WORD	Dgetdrv( void );
Dgetdrv:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	#25,-(sp) ;Laufwerksnummer erfragen
	trap	#1
	addq.l	#2,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;WORD	Dgetpath( BYTE *buf, WORD driveno )
Dgetpath:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#71,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;DTA	*Fgetdta( void );
Fgetdta:
	movem.l	d1-d2/a1-a2,-(sp)
	move.w	#47,-(sp)
	trap	#1
	addq.l	#2,sp
	movea.l	d0,a0 			;Adresse der DTA
	movem.l	(sp)+,d1-d2/a1-a2
	rts

;void	Fsetdta( DTA *dta );
Fsetdta:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,-(sp) 		;Adresse der neuen DTA (dta)
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;WORD	Fsfirst( const BYTE *filename, WORD attr );
Fsfirst:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp) 		;Dateiname mit Pfadangabe
	move.w	#78,-(sp)		;DTA der Datei erfragen
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;WORD	Fsnext( void );
Fsnext:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	#79,-(sp)
	trap	#1
	addq.l	#2,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

	MODULE Fcreate
;LONG	Fcreate( BYTE *name, WORD attrib );						
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp)		;Attribute
	move.l	a0,-(sp) 		;Name
	move.w	#60,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts
	ENDMOD

;LONG	Fopen( const BYTE *filename, WORD mode );
Fopen:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp)			;Modus
	move.l	a0,-(sp)			;Dateiname
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;LONG	Fseek( LONG offset, WORD handle, WORD seekmode );
Fseek:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d2,-(sp) 		;Modus
	move.w	d1,-(sp) 		;Handle
	move.l	d0,-(sp) 		;Offset
	move.w	#66,-(sp)
	trap	#1
	lea		10(sp),sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;LONG	Fread( WORD handle, LONG count, void *buf );
Fread:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	a0,-(sp) 		;Bufferadresse
	move.l	d1,-(sp) 		;Laenge
	move.w	d0,-(sp) 		;Handle
	move.w	#63,-(sp)
	trap	#1
	lea		12(sp),sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;WORD	Fclose( WORD handle );
Fclose:
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	d0,-(sp) 		;Handle
	move.w	#62,-(sp)		;Datei schliessen
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

	MODULE Fwrite
;LONG	Fwrite( WORD handle, LONG count, void *buf );						
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	a0,-(sp)
	move.l	d1,-(sp)
	move.w	d0,-(sp)			;Handle
	move.w	#64,-(sp)
	trap	#1
	lea		12(sp),sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts
	ENDMOD

;void	*Malloc_sys( LONG len );
;Speicher allozieren
;Eingaben
;d0.l Laenge des Speicherbereichs
;Ausgaben
;d0.l Adresse des Speicherblocks oder 0 (Fehler)
;a0.l	Adresse des Speicherblocks oder 0 (Fehler)
Malloc_sys:
	movem.l	d1-d3/a1-a2,-(sp)
	move.w	#$4033,d1 ; DONT_FREE+SUPER_MEM+TT_RAM_pref
	moveq	#68,d2
malloc:
	move.w	d1,-(sp)			;Modus
	move.l	d0,-(sp)			;Laenge
	move.w	d2,-(sp)			;Opcode
	trap	#1
	addq.l	#8,sp
	move.l	d0,d1
	subq.l	#1,d1				;wurde ein 0 Bytes langer Bereich angefordert?
	bne.s	malloc_exit
	moveq	#0,d0				;kein Speicher
malloc_exit:
	movea.l	d0,a0
	movem.l	(sp)+,d1-d3/a1-a2
	rts

;WORD	Mfree_sys( void *addr );
;Allozierten Speicher zurueckgeben
;Eingaben
;a0.l Adresse des Speicherblocks
;Ausgaben
;d0.w evtl. -40 (falsche Adresse)
Mfree_sys:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	a0,-(sp) 		;Bereichsadresse
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;WORD	Mshrink_sys( void *addr, LONG size );
;Eingaben
;d0.l neue Laenge des Speicherblocks
;a0.l Adresse des Speicherblocks
;Ausgaben
;d0.w evtl. -40 (falsche Adresse) oder -67 (Speicherblock vergroessert)
Mshrink_sys:
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	d0,-(sp) 		;Bereichslaenge
	move.l	a0,-(sp) 		;Bereichsadresse
	clr.w	-(sp)
	move.w	#74,-(sp)
	trap	#1
	lea		12(sp),sp
	movem.l	(sp)+,d1-d2/a0-a2
	rts
