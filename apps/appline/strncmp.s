		.globl _strncmp
		.globl Rstrncmp

		.text

_strncmp:
		movem.l    4(a7),a0-a1
		move.w     12(a7),d1
Rstrncmp:
		move.b     (a0),d0
		sub.b      (a1)+,d0
		bne.s      strncmp1
		subq.w     #1,d1
		beq.s      strncmp1
		tst.b      (a0)+
		bne.s      Rstrncmp
		moveq.l    #0,d0
		rts
strncmp1:
		ext.w      d0
		rts
