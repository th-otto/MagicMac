	XDEF	_uldiv
	XDEF	_ulmod
	XDEF	_ulmul
	XDEF	_ldiv
	XDEF	_lmul

	XREF cpu020 ; from mxvdiknl.o
	
	mc68020

	TEXT

_ulmul:
	tst.w	cpu020.l
	beq.s	_ulmul_68000
	mulu.l	d1,d0
	rts
_ulmul_68000:
	move.l	d3,-(a7)
	moveq #0,d3
	bra.s _lmul_l2

_lmul:
	tst.w	cpu020.l
	beq.s	_lmul_68000
	muls.l	d1,d0
	rts
_lmul_68000:
	move.l	d3,-(a7)
	move.l	d0,d3
	bpl.s	_lmul_l1
	neg.l	d0
_lmul_l1:
	eor.l	d1,d3
	tst.l	d1
	bpl.s	_lmul_l2
	neg.l	d1
_lmul_l2:
	move.l	d0,d2
	swap	d2
	tst.w	d2
	beq.s	_lmul_hi
	mulu.w	d1,d2
	bra.s	_lmul_lo

_lmul_hi:
	move.l	d1,d2
	swap	d2
	tst.w	d2
	beq.s	_lmul_hi2
	mulu.w	d0,d2
_lmul_lo:
	mulu.w	d1,d0
	swap	d2
	add.l	d2,d0
	bra.s	_lmul_si

_lmul_hi2:
	mulu.w	d1,d0
_lmul_si:
	tst.l	d3
	bpl.s	_lmul_ex
	neg.l	d0
_lmul_ex:
	move.l	(a7)+,d3
	rts

_ldiv:
	tst.w	cpu020.l
	beq.s	_ldiv_68000
	divsl.l	d1,d1:d0
	rts

_ldiv_68000:
	move.l	d3,-(a7)
	move.l	d0,d3
	bpl.s	_ldiv_l1
	neg.l	d0
_ldiv_l1:
	eor.l	d1,d3
	tst.l	d1
	bpl.s	_ldiv_l2
	neg.l	d1
_ldiv_l2:
	bsr.s	uldiv_68000
	tst.l	d3
	bpl.s	_ldiv_ex
	neg.l	d0
_ldiv_ex:
	move.l	(a7)+,d3
	rts

_uldiv:
	tst.w	cpu020.l
	beq.s	uldiv_68000
	divul.l	d1,d1:d0
	rts
uldiv_68000:
	moveq	#1,d2
	swap	d2
	cmp.l	d2,d1
	bcc.s	uldiv3231
	swap	d0
	cmp.w	d1,d0
	bge.s	uldiv321
	swap	d0
	divu	d1,d0
	move.l	d0,d1
	eor.w	d0,d1
	eor.l	d1,d0
	swap	d1
	rts

uldiv321:
	move.l	d0,d2
	clr.w	d2
	eor.l	d2,d0
	swap	d2
	divu	d1,d0
	movea.w	d0,a0
	move.w	d2,d0
	divu	d1,d0
	swap	d0
	moveq	#0,d1
	move.w	d0,d1
	move.w	a0,d0
	swap	d0
	rts

uldiv3231:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move.w	d0,d1
	clr.w	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
uldiv3232:
	sub.l	a0,d1
	bcc.s	uldiv3233
	add.l	a0,d1
uldiv3233:
	addx.l	d0,d0
	addx.l	d1,d1
	dbf	d2,uldiv3232
	not.w	d0
	roxr.l	#1,d1
	rts

_ulmod:
	tst.w	cpu020.l
	beq.s	ulmod_68
	divul.l	d1,d1:d0
	move.l	d1,d0
	rts

ulmod_68:
	bsr.s uldiv_68000
	move.l	d1,d0
	rts
