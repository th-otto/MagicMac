/*
*
* Assembler-Modul fÅr MGVIEW
*
*/

	XDEF	memchr2

/*************************************************************
*
* void  *memchr2( const void *s, size_t len );
*
* Sucht nach dem ersten Vorkommen der Zeichen CR oder LF
*
*************************************************************/

memchr2:
 moveq	#10,d1			; LF
mchr_loop:
 subq.l	#1,d0
 bcs.b	mchr_nix			; nicht gefunden
 move.b	(a0)+,d2			; Zeichen holen
 sub.b	d1,d2
 beq.b	mchr_found		; LF
 subq.b	#3,d2			; CR ?
 bne.b	mchr_loop			; nein
mchr_found:
 subq.l	#1,a0
 rts
mchr_nix:
 suba.l	a0,a0
 rts
