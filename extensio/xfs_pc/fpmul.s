* 
*	Floating Point Multiplication :
*		Front End to FFP Floating Point Package.
*
*		double
*		fpmul(multiplier,multiplicand)
*		double multiplier, multiplicand;
*
*	Return : Result of Floating Point Multiply
*
	xdef fpmul
	xdef _fpmul
	xdef fpmult
	xdef _fpmult
	xdef ffpmul2
	text
fpmult:
_fpmult:
fpmul:
_fpmul:
	link	a6,#-4
	movem.l	d3-d7,-(sp)
	move.l	8(a6),d7
	move.l	12(a6),d6
	jsr		ffpmul2
	move.l	d7,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'fpmul.o',0

