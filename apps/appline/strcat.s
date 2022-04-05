		.globl _strcat
		.globl Rstrcat

_strcat:
		movem.l    4(a7),a0-a1
Rstrcat:
		move.l     a0,d0
strcat1:
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		beq.s      strcat2
		tst.b      (a0)+
		bne.s      strcat1
strcat2:
		subq.w     #1,a0
strcat3:
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		beq.s      strcat4
		move.b     (a1)+,(a0)+
		bne.s      strcat3
strcat4:
		rts
