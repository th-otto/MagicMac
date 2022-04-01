* 
*	Floating Point Division :
*		Front End to FFP Floating Point Package.
*
*		double
*		fpdiv(divisor,dividend)
*		double divisor, dividend;
*
*	Return : Floating Point Quotient
*
	xdef fpdiv
	xdef _fpdiv
	xref ffpdiv
	text
fpdiv:
_fpdiv:
	link	a6,#-4
	movem.l	d3-d7,-(sp)
	move.l	8(a6),d7
	move.l	12(a6),d6
	jsr		ffpdiv
	move.l	d7,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'fpdiv.o',0
