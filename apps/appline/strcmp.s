		.globl _strcmp
		.globl Rstrcmp

		.text

_strcmp:
		movem.l    4(a7),a0-a1
Rstrcmp:
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		bne.s      strcmp1
		move.b     (a0)+,d0
		beq.s      strcmp2
		sub.b      (a1)+,d0
		beq.s      Rstrcmp
strcmp1:
		ext.w      d0
		rts
strcmp2:
		sub.b      (a1),d0
		ext.w      d0
		rts
