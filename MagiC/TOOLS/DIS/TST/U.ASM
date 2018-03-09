     MC68030
     SUPER

 pmove	crp,d0
 pmove	d0,crp
 pmovefd	d0,crp
 pmove	srp,d0
;pmove	drp,d0
 pmove	tc,d0
 pmove	psr,d0
;pmove	pcsr,d0
;pmove	cal,d0
;pmove	val,d0
;pmove	ac,d0
 pmove	tt0,d0
 pmove	tt1,d0
 pmove	bad0,d0
 pmove	bad7,d0
 pmove	bac0,d0
 pmove	bac7,d0
 pmove	d0,crp
 pmovefd	d0,crp

 ptestr	dfc,(a0),#1
 ptestw	dfc,(a0),#1
 ptestw	sfc,(a0),#1
 ptestw	sfc,(a0),#7
 ptestw	sfc,(a0),#7,a0
 ptestw	sfc,(a0),#7,a7

 ploadr	dfc,(a0)
 ploadw	dfc,(a0)
 ploadw	sfc,(a0)
 ploadw	d0,(a0)
 ploadw	d7,(a0)
 ploadw	#7,(a0)
 ploadw	#7,(a7)
 ploadw	#7,15(a7)

 pflush	dfc,#0
 pflush	dfc,#7
 pflush	dfc,#15
 bra		lbl1
 pflush	sfc,#7
 bra		lbl2
 pflush	d0,#7
 bra		lbl3
 pflush	d7,#7
 bra		lbl4
 pflush	#0,#7
 pflush	#7,#7
 bra		lbl5
 pflush	#7,#7,8(a0)
 bra		lbl6
 pflush	#7,#7,8(a7)
 bra		lbl7
 pflush	#7,#7,(a7)

lbl1:
lbl2:
lbl3:
lbl4:
lbl5:
lbl6:
lbl7:
