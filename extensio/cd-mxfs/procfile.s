		XDEF proc_file
		XDEF proc_device
		XDEF proc_track
		XDEF proc_len

proc_file:
	bra.s	textstart

	dc.l textend-textstart
	dc.l 0 /* no data */
	dc.l 0 /* no bss */
	dc.l 0 /* no symbols */
	dc.l 0
	dc.l 0
	dc.w 0
textstart:
	move.l #0,-(a7)
	move.l #0,-(a7)
	move.l #0,-(a7)
	move.l #0,-(a7)
	move.l #0,-(a7)
	move.l #0,-(a7)
	pea	proc_bytes(pc)
	move.w	#0,-(a7)
	move.w	proc_device(pc),-(a7)
	move.w	#59,-(a7) /* Metastartaudio */
	trap	#14
	lea 	34(a7),a7
	tst.l	d0
	beq.s	alles_ok
	move.w	#1,-(a7)
alles_ok:
	move.w	d0,-(a7)
	move.w	#76,-(a7) /* Pterm */
	trap	#1
	illegal
vermurks:
	illegal
	illegal
	illegal
proc_device:
	dc.w	0

proc_bytes:
	dc.b	99
proc_track:
	dc.b	1
	dc.w	0
textend:
	dc.l vermurks-textstart /* offset to first relocation */
	dc.l 0 /* end of relocation table */
proc_len:
	dc.l	proc_len-proc_file
