		.globl _strcpy
		.globl Rstrcpy
		
		.text

_strcpy:
		movem.l    4(a7),a0-a1
Rstrcpy:
		move.l     a0,d0
strcpy1:
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		beq.s      strcpy2
		move.b     (a1)+,(a0)+
		bne.s      strcpy1
strcpy2:
		rts
