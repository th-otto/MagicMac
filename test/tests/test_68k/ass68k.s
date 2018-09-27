	EXPORT roxr_w
	EXPORT roxr_l
	EXPORT roxl_w
	EXPORT roxl_l

	EXPORT divs_l
	EXPORT muls_l

	EXPORT sub_w
	EXPORT subx_w
	EXPORT subx_l

	EXPORT t1
	EXPORT t2
	EXPORT t3

	MC68020

sub_w:
	move		d2,ccr
	sub.w	d1,d0
	move		ccr,d0
	rts

subx_w:
	move		d2,ccr
	subx.w	d1,d0
	move		ccr,d0
	rts

subx_l:
	move		d2,ccr
	subx.l	d1,d0
	move		ccr,d0
	rts

roxr_w:
	move		d1,ccr
	roxr.w	#1,d0
	move		ccr,d1
	move.w	d1,(a0)
	rts

roxr_l:
	move		d1,ccr
	roxr.l	#1,d0
	move		ccr,d1
	move.w	d1,(a0)
	rts

roxl_w:
	move		d1,ccr
	roxl.w	#1,d0
	move		ccr,d1
	move.w	d1,(a0)
	rts

roxl_l:
	move		d1,ccr
	roxl.l	#1,d0
	move		ccr,d1
	move.w	d1,(a0)
	rts

divs_l:
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	8(a0),d2
	divs.l	d2,d0:d1
	move.l	d0,(a0)
	move.l	d1,4(a0)
	move.l	d2,8(a0)
	rts

muls_l:
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	8(a0),d2
	muls.l	d2,d0:d1
	move.l	d0,(a0)
	move.l	d1,4(a0)
	move.l	d2,8(a0)
	rts

	END