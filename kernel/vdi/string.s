	XDEF	strgcat
	XDEF	strgcmp
	XDEF	strgcpy
	XDEF	strglen
	XDEF	strgint
	XDEF	copy_mem
	XDEF	strgupr
	XDEF	clear_mem
	XDEF	intstrg
	XDEF	fill_mem
	XDEF	copy_me_

	TEXT

clear_mem:
	move.l	d0,d1
	moveq	#0,d0
memset: ; not exported!
fill_mem:
	movea.l	a0,a1
	move.l	a0,d2
	and.w	#1,d2
	beq.s	memset_a
	move.b	d0,(a1)+
	subq.l	#1,d1
	bmi.s	memset_e
memset_a:
	move.b	d0,d2
	lsl.w	#8,d2
	move.b	d0,d2
	move.w	d2,d0
	swap	d0
	move.w	d2,d0
	moveq	#3,d2
	and.w	d1,d2
	lsr.l	#2,d1
	bra.s	memset_s
memset_l:
	move.l	d0,(a1)+
memset_s:
	subq.l	#1,d1
	bpl.s	memset_l
	subq.w	#1,d2
	bmi.s	memset_e
memset_b:
	move.b	d0,(a1)+
	subq.w	#1,d2
	bpl.s	memset_b
memset_e:
	rts

copy_mem:
	moveq	#1,d1
	move.w	a0,d2
	and.w	d1,d2
	bne.s	copy_so
	move.w	a1,d2
	and.w	d1,d2
	beq.s	copy_cnt
	bra.s	copy_sb_2
copy_pre:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
copy_cnt:
	moveq	#3,d1
	and.l	d0,d1
	asr.l	#2,d0
	bra.s	copy_a_s

copy_a_l:
	move.l	(a0)+,(a1)+
copy_a_s:
	subq.l	#1,d0
	bpl.s	copy_a_l
	bra.s	copy_b_s

copy_b_l:
	move.b	(a0)+,(a1)+
copy_b_s:
	subq.w	#1,d1
	bpl.s	copy_b_l
	rts

copy_so:
	move.w	a1,d2
	and.w	d1,d2
	bne.s	copy_pre
	bra.s	copy_sb_2

copy_sb_1:
	move.b	(a0)+,(a1)+
copy_sb_2:
	subq.l	#1,d0
	bpl.s	copy_sb_1
	rts

strgcat:
strcat: ; not exported!
	tst.b	(a0)+
	bne.s	strgcat
	subq.l	#1,a0
strgcpy:
strcpy: ; not exported!
	move.b	(a1)+,(a0)+
	bne.s	strgcpy
	rts

strglen:
strlen: ; not exported!
	movea.l	a0,a1
strlen_loop:
	tst.b	(a1)+
	bne.s	strlen_loop
	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	rts

strgcmp:
strcmp: ; not exported!
	moveq	#0,d0
	moveq	#0,d1
strcmp_loop:
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	cmp.w	d1,d0
	blt.s	strcmp_less
	bgt.s	strcmp_greater
	or.b	d0,d1
	bne.s	strcmp_loop
strcmp_equal:
	moveq	#0,d0
	rts
strcmp_less:
	moveq	#-1,d0
	rts
strcmp_greater:
	moveq	#1,d0
	rts

strgupr:
strupr: ; not exported!
	movea.l	a0,a1
strupr_loop:
	move.b	(a1),d0
	cmp.b	#97,d0
	blt.s	strupr_store
	cmp.b	#122,d0
	bgt.s	strupr_a
	sub.b	#32,d0
	bra.s	strupr_store
strupr_a:
	cmp.b	#132,d0 ; lowercase ae
	bne.s	strupr_o
	move.b	#142,d0
	bra.s	strupr_store
strupr_o:
	cmp.b	#148,d0 ; lowercase ue
	bne.s	strupr_u
	move.b	#153,d0
	bra.s	strupr_store
strupr_u:
	cmp.b	#129,d0 ; lowercase oe
	bne.s	strupr_store
	move.b	#154,d0
strupr_store:
	move.b	d0,(a1)+
	bne.s	strupr_loop
	rts

; BUG: actually works with shorts only
intstrg:
	clr.l	-(a7)
	clr.l	-(a7)
	clr.l	-(a7)
	lea 	10(a7),a1
intstrg_1:
	divu	#10,d0
	swap	d0
	add.b	#48,d0
	move.b	d0,-(a1)
	clr.w	d0
	swap	d0
	tst.w	d0
	bne.s	intstrg_1
	move.l	a0,d0
intstrg_2:
	move.b	(a1)+,(a0)+
	bne.s	intstrg_2
	movea.l	d0,a0
	lea 	12(a7),a7
	rts

strgint:
	moveq	#0,d0
	moveq	#0,d1
	bra.s	strgint_2
strgint_1:
	sub.b	#48,d1
	cmp.w	#9,d1
	bhi.s	strgint_3
	mulu.w	#10,d0
	add.l	d1,d0
strgint_2:
	move.b	(a0)+,d1
	bne.s	strgint_1
strgint_3:
	rts
