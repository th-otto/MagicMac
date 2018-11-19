	XDEF	_gemdos
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

	XDEF Getrez
	XDEF Supexec
	
	TEXT

_gemdos:
	move.l	(a7)+,save_pc
	move.l	a2,save_a2
	trap #1
	move.l save_a2,a2
	move.l save_pc,a1
	jmp (a1)

Mfree:
	pea (a2)
	pea (a0)
	move.w	#73,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l (a7)+,a2
	rts

mmalloc:
Malloc:
	pea (a2)
	move.l	d0,-(a7)
	move.w	#72,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l d0,a0
	move.l (a7)+,a2
	rts

Fwrite:
	movem.l   d0-d1/a0/a2,-(a7)
	move.w	#64,(a7)
	trap	#1
	lea 	12(a7),a7
	move.l (a7)+,a2
	rts

Fsetdta:
	pea (a2)
	pea (a0)
	move.w	#26,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l (a7)+,a2
	rts

Fseek:
	pea (a2)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.l	d0,-(a7)
	move.w	#66,-(a7)
	trap	#1
	lea 	10(a7),a7
	move.l (a7)+,a2
	rts

Fread:
	movem.l   d0-d1/a0/a2,-(a7)
	move.w	#63,(a7)
	trap	#1
	lea 	12(a7),a7
	move.l (a7)+,a2
	rts

Fgetdta:
	pea (a2)
	move.w	#47,-(a7)
	trap	#1
	addq.w	#2,a7
	movea.l	d0,a0
	move.l (a7)+,a2
	rts

Fclose:
	pea (a2)
	move.w	d0,-(a7)
	move.w	#62,-(a7)
	trap	#1
	addq.w	#4,a7
	move.l (a7)+,a2
	rts

Dgetdrv:
	pea (a2)
	move.w	#25,-(a7)
	trap	#1
	addq.w	#2,a7
	move.l (a7)+,a2
	rts

Fsfirst:
	pea (a2)
	move.w	d0,-(a7)
	pea (a0)
	move.w	#78,-(a7)
	trap	#1
	addq.w	#8,a7
	move.l (a7)+,a2
	rts

Fopen:
	pea (a2)
	move.w	d0,-(a7)
	pea (a0)
	move.w	#61,-(a7)
	trap	#1
	addq.w	#8,a7
	move.l (a7)+,a2
	rts

Fxattr:
	movem.l   d0/a0-a2,-(a7)
	move.w	#$12c,(a7)
	trap	#1
	lea 12(a7),a7
	move.l (a7)+,a2
	rts

Supexec:
	pea (a2)
	pea (a0)
	move.w	#38,-(a7)
	trap	#14
	addq.w	#6,a7
	move.l (a7)+,a2
	rts

	BSS
save_pc: ds.l 1
save_a2: ds.l 1
