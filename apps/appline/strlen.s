		.globl _strlen
		.globl Rstrlen

		.text

_strlen:
		movea.l    4(a7),a0
Rstrlen:
		movea.l    a0,a1
strlen1:
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		beq.s      strlen2
		tst.b      (a0)+
		bne.s      strlen1
strlen2:
		move.l     a0,d0
		sub.l      a1,d0
		subq.l     #1,d0
		rts
