* 
*	Floating Point Subtraction :
*		Front End to FFP Floating Point Package.
*
*		double
*		fpsub(subtrahend,minuend)
*		double subtrahend, minuend;
*
*	Returns : Floating point subtraction result
*
	xdef fpsub
	xdef _fpsub
	xdef ffpsub
	text
fpsub:
_fpsub:
	link	a6,#-4
	movem.l	d3-d7,-(sp)
	move.l	8(a6),d7
	move.l	12(a6),d6
	jsr		ffpsub
	move.l	d7,d0
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

	dc.w 0x23f9
	dc.b 'fpsub.o',0
