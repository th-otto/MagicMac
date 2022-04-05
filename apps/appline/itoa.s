		.globl _itoa
		.globl _ltoa
		
		.text
		
/* char *itoa(int n, char *ptr, int base) */
_itoa:
		lea.l      4(a7),a2
		move.w     (a2)+,d1
		ext.l      d1
		bra.s      ltoa1
_ltoa:
/* char *ltoa(long n, char *ptr, int base) */
		lea.l      4(a7),a2
		move.l     (a2)+,d1
ltoa1:
		movea.l    (a2)+,a0
		bge.s      ltoa2
		move.b     #$2D,(a0)+
		neg.l      d1
		bra.s      ltoa2
		lea.l      4(a7),a2
		move.l     (a2)+,d1
		movea.l    (a2)+,a0
ltoa2:
		move.w     (a2),d2
		move.l     d3,-(a7)
		movea.l    a0,a1
ltoa3:
		move.l     d1,d3
		clr.w      d3
		swap       d3
		divu.w     d2,d3
		moveq.l    #0,d0
		move.w     d3,d0
		swap       d0
		move.w     d1,d3
		divu.w     d2,d3
		moveq.l    #0,d1
		move.w     d3,d1
		add.l      d0,d1
		swap       d3
		move.b     hexdigits(pc,d3.w),(a1)+
		tst.l      d1
		bhi.s      ltoa3
		clr.b      (a1)
ltoa4:
		move.b     -(a1),d0
		move.b     (a0),(a1)
		move.b     d0,(a0)+
		cmpa.l     a0,a1
		bhi.s      ltoa4
		move.l     (a7)+,d3
		move.l     -(a2),d0
		rts

hexdigits:
		.dc.b '0123456789ABCDEF',0
		.even
