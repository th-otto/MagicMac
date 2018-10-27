     XDEF      serno_test
     XDEF      serno_t2
     XDEF      serno_t3
     XDEF      serno_t4

	 XREF serno_isok
	 XREF dos_time
	 XREF ss_serno
     XREF prtstr

serno_test:
		lea.l     (serno_isok-837).l,a0
		tst.b     837(a0)
		bne.s     serno_test5
		lea.l     ss_serno-40,a0
		move.l    40(a0),d0
		movem.l   d3-d4,-(a7)
		sub.l     #$09F70A87,d0
		move.l    d0,d4
		andi.l    #$83571524,d4
		cmpi.l    #$01401104,d4
		bne.s     serno_test3
		move.l    #$7CA8EADB,d1
		moveq.l   #0,d4
		moveq.l   #31,d2
serno_test1:
		btst      d2,d1
		beq.s     serno_test2
		move.l    d0,d3
		lsr.l     #8,d3
		lsr.l     #8,d3
		lsr.l     #8,d3
		lsr.l     #7,d3
		lsl.l     #1,d4
		or.b      d3,d4
serno_test2:
		lsl.l     #1,d0
		dbf       d2,serno_test1
		divu.w    #7,d4
		move.l    d4,d0
		swap      d0
		ext.l     d0
		beq.s     serno_test4
serno_test3:
		moveq.l   #-1,d0
serno_test4:
		movem.l   (a7)+,d3-d4
		lea.l     (serno_isok-888).l,a1
		move.b    #1,888(a1)
		tst.l     d0
		beq.s     serno_test5
		lea.l     (dos_time.l-1585),a0
		btst      #0,1586(a0)
		beq.s     serno_test5
		st        888(a1)
serno_test5:
 rts



serno_t2:
		lea.l     (serno_isok-120).l,a0
		tst.b     120(a0)
		bge.s     serno_t2_1
		lea.l     (dos_time-86.l),a0
		move.b    87(a0),d0
		andi.b    #$07,d0
		beq.s     serno_t2_2
serno_t2_1:
		moveq.l   #0,d0
		rts
serno_t2_2:
		moveq.l   #-1,d0
		rts

serno_t3:
		tst.l     ss_serno
		bne       serno_t3_2
		lea.l     serno_msg(pc),a0
		jsr       prtstr
serno_t3_1:
		bra.s     serno_t3_1

serno_msg:
		dc.b 27,'E'
		dc.b '#######################################',13,10
		dc.b '    MagiC ist nicht personalisiert.    ',13,10
		dc.b 'Benutzen Sie INSTMAGX zur Installation!',13,10
		dc.b '#######################################'
		dc.b 0
		even

serno_t3_2:
		rts

serno_t4:
		rts
