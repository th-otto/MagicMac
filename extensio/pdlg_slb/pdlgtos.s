	XDEF	Mfree
	XDEF	Malloc
	XDEF	mmalloc
	XDEF	Fwrite
	XDEF	Fsetdta
	XDEF	Fseek
	XDEF	Fread
	XDEF	Fgetdta
	XDEF	Fclose
	XDEF	Dgetdrv
	XDEF	Fsfirst
	XDEF	Fopen
	XDEF	Fxattr
	XDEF	Slbopen
	
	XDEF Getrez
	XDEF Supexec
	
	TEXT

	MODULE Mfree
	pea (a2)
	pea (a0)
	move.w	#73,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Malloc
mmalloc:
	pea (a2)
	move.l	d0,-(a7)
	move.w	#72,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l d0,a0
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fwrite
	movem.l   d0-d1/a0/a2,-(a7)
	move.w	#64,(a7)
	trap	#1
	lea 	12(a7),a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fsetdta
	pea (a2)
	pea (a0)
	move.w	#26,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fseek
	pea (a2)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	move.w	#66,-(a7)
	trap	#1
	lea 	10(a7),a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fread
	movem.l   d0-d1/a0/a2,-(a7)
	move.w	#63,(a7)
	trap	#1
	lea 	12(a7),a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fgetdta
	pea (a2)
	move.w	#47,-(a7)
	trap	#1
	addq.w	#2,a7
	movea.l	d0,a0
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fclose
	pea (a2)
	move.w	d0,-(a7)
	move.w	#62,-(a7)
	trap	#1
	addq.w	#4,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Dgetdrv
	pea (a2)
	move.w	#25,-(a7)
	trap	#1
	addq.w	#2,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fsfirst
	pea (a2)
	move.w	d0,-(a7)
	pea (a0)
	move.w	#78,-(a7)
	trap	#1
	addq.w	#8,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fopen
	pea (a2)
	move.w	d0,-(a7)
	pea (a0)
	move.w	#61,-(a7)
	trap	#1
	addq.w	#8,a7
	move.l (a7)+,a2
	rts
	ENDMOD

	MODULE Fxattr
	movem.l   d0/a0-a2,-(a7)
	move.w	#$12c,(a7)
	trap	#1
	lea 12(a7),a7
	move.l (a7)+,a2
	rts
	ENDMOD
	
	MODULE Supexec
	pea (a2)
	pea (a0)
	move.w	#38,-(a7)
	trap	#14
	addq.w	#6,a7
	move.l (a7)+,a2
	rts
	ENDMOD

				MODULE	Slbopen
				pea		(a2)
				move.l	12(a7),-(a7)
				move.l	12(a7),-(a7)
				move.l	d0,-(a7)
				pea		(a1)
				pea		(a0)
				move.w	#$16,-(a7)
				trap #1
				lea		22(a7),a7
				move.l	(a7)+,a2
				rts
				ENDMOD
								
				MODULE	Slbclose
				pea		(a2)
				pea		(a0)
				move.w	#$17,-(a7)
				trap #1
				addq.l	#6,a7
				move.l	(a7)+,a2
				rts
				ENDMOD
								
