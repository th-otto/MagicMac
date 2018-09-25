     MC68030
     SUPER

 cmp2     4(a0),d1
 cmp2     4(a0),a2
 bra      lbl1
 chk2     4(a0),d1
 chk2     4(a0),a2
 bra      lbl2
 cas      d3,d4,5(a0)
 cas2     d1:d2,d3:d4,(a6):(d5)
 bra      lbl3
 moves    d6,5(a0)
 moves    7(a4),a7
 bra      lbl4
 chk.l    7(a5),d5
 bra      lbl5
 move     ccr,d7
 bra      lbl6
 link.l   a0,#$12345678
 bra      lbl7
 bkpt     #5
 bra      lbl8
 extb.l   d7
 bra      lbl9
 muls.l   5(a4),d5
 mulu.l   5(a4),d5:d6
 bra      lbl10
 divu.l   4(a4),d3
 divu.l   4(a4),d4:d7
 divul.l  4(a4),d4:d7
 bra      lbl11
 rtd      #5
 movec    cacr,d7
 movec    d7,cacr
 movec    d7,vbr
 bra      lbl12
 trapne
 trapeq.w #6
 trapcs.l #6
 bra.l    lbl13
 pack     -(a4),-(a5),#$12
 pack     d4,d5,#$12
 unpk     -(a4),-(a5),#$12
 unpk     d4,d5,#$12
 bra      lbl14
 bfchg    $12{7:8}
 bfchg    $12{d7:d2}
 bfclr    $12{d7:d2}
 bfexts   $12{d7:d2},d6
 bfextu   $12{d7:d2},d6
 bfffo    $12{d7:d2},d6
 bfins    d5,$12{d7:d2}
 bfset    $12{d7:d2}
 bftst    $12{d7:d2}
 bra      lbl15

lbl1:
 nop
lbl2:
 nop
lbl3:
 nop
lbl4:
 nop
lbl5:
 nop
lbl6:
 nop
lbl7:
 nop
lbl8:
 nop
lbl9:
 nop
lbl10:
 nop
lbl11:
 nop
lbl12:
 nop
lbl13:
 nop
lbl14:
 nop
lbl15:
 nop

