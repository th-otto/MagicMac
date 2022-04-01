	xref	_ldivr
	globl	_lrem
	globl	lrem
	text
_lrem:
lrem:
	link	a6,#-2
	move.l	12(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_ldiv
	cmpm.l	(sp)+,(sp)+
	move.l	_ldivr,d0
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'lrem.o',0,0
