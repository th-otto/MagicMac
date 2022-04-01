* 
*	Floating Point Negation :
*		Front End to FFP Floating Point Package.
*
*		double
*		fpneg(farg)
*		double farg;
*
*	Returns : negated Floating point number
*
	xdef fpneg
	xdef _fpneg
	xref ffpneg
	text
fpneg:
_fpneg:
	link	a6,#-4
	movem.l	d3-d7,-(sp)
	move.l	8(a6),d7
	jsr		ffpneg
	move.l	d7,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'fpneg.o',0
