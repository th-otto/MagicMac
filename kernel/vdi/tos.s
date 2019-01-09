	XDEF	Bconout
	XDEF	Fread
	XDEF	Dgetdrv
	XDEF	Fseek
	XDEF	Fopen
	XDEF	Fcreate
	XDEF	Fgetdta
	XDEF	Fsetdta
	XDEF	Fsfirst
	XDEF	Bconin
	XDEF	Cconws
	XDEF	Fclose
	XDEF	Mfree_sys
	XDEF	Dgetpath
	XDEF	Malloc_sys
	XDEF	Fsnext
	XDEF	Fwrite
	XDEF	Mshrink_sys

	TEXT

Bconin:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.w	#2,-(a7)
	trap	#13
	addq.l	#4,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Bconout:
	movem.l	d0-d2/a0-a2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	movem.l	(a7)+,d0-d2/a0-a2
	rts

Cconws:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Dgetdrv:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	#25,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Dgetpath:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.l	a0,-(a7)
	move.w	#71,-(a7)
	trap	#1
	addq.l	#8,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fgetdta:
	movem.l	d1-d2/a1-a2,-(a7)
	move.w	#47,-(a7)
	trap	#1
	addq.l	#2,a7
	movea.l	d0,a0
	movem.l	(a7)+,d1-d2/a1-a2
	rts

Fsetdta:
	movem.l	d0-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.w	#26,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d0-d2/a0-a2
	rts

Fsfirst:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.l	a0,-(a7)
	move.w	#78,-(a7)
	trap	#1
	addq.l	#8,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fsnext:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	#79,-(a7)
	trap	#1
	addq.l	#2,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fcreate:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.l	a0,-(a7)
	move.w	#60,-(a7)
	trap	#1
	addq.l	#8,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fopen:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.l	a0,-(a7)
	move.w	#61,-(a7)
	trap	#1
	addq.l	#8,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fseek:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	move.w	#66,-(a7)
	trap	#1
	lea 	10(a7),a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fread:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	move.w	#63,-(a7)
	trap	#1
	lea 	12(a7),a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fclose:
	movem.l	d1-d2/a0-a2,-(a7)
	move.w	d0,-(a7)
	move.w	#62,-(a7)
	trap	#1
	addq.l	#4,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Fwrite:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	move.w	#64,-(a7)
	trap	#1
	lea 	12(a7),a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Malloc_sys:
	movem.l	d1-d3/a1-a2,-(a7)
	move.w	#$4033,d1
	moveq	#68,d2
malloc:
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	move.w	d2,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	d0,d1
	subq.l	#1,d1
	bne.s	malloc_error
	moveq	#0,d0
malloc_error:
	movea.l	d0,a0
	movem.l	(a7)+,d1-d3/a1-a2
	rts

Mfree_sys:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.w	#73,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

Mshrink_sys:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	d0,-(a7)
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#74,-(a7)
	trap	#1
	lea 	12(a7),a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts
