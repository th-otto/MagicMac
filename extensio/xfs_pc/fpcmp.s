* 
*	Floating Point Compare :
*		Front End to FFP Floating Point Package.
*
*		int
*		fpcmp(source,dest)
*		double source, dest;
*
*	Returns : Condition codes based on Floating Point Compare
*
	xdef fpcmp
	xdef _fpcmp
	xref ffpcmp
.text
fpcmp:
_fpcmp:
	link	a6,#-4
	movem.l	d3-d7,-(sp)
	move.l	8(a6),d7
	move.l	12(a6),d6
	jsr		ffpcmp
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'fpcmp.o',0
