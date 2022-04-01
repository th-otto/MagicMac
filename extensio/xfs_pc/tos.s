
	text

	dc.w 0x23f9
	dc.b 'cio2con.'

	xdef _xbios
	text
_xbios:
	move.l    (a7)+,saveret
	trap      #14
	move.l    saveret,-(a7)
	rts

	xdef _bios
	xdef bios
_bios:
bios:
	move.l    (a7)+,saveret
	trap      #13
	move.l    saveret,-(a7)
	rts

	xdef _gemdos
	text
_gemdos:
	move.l    (a7)+,saveret
	trap      #1
	move.l    saveret,-(a7)
	rts

	dc.w 0x23f9
	dc.b 'osbind.o'

	bss
saveret: ds.l 1
