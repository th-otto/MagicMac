		XDEF mgx_check
		XDEF nvdi_check

mgx_check:
		movea.l   ($000005A0).w,a0
		move.l    a0,d0
		beq.s     mgx_check4
		bra.s     mgx_check3
mgx_check1:
		cmpi.l    #$4D616758,(a0) ; 'MagX'
		bne.s     mgx_check2
		move.l    4(a0),d0
		rts
mgx_check2:
		addq.w    #8,a0
mgx_check3:
		move.l    (a0),d0
		bne.s     mgx_check1
mgx_check4:
		moveq.l   #0,d0
		rts


nvdi_check:
		movea.l   ($000005A0).w,a0
		move.l    a0,d0
		beq.s     nvdi_check4
		bra.s     nvdi_check3
nvdi_check1:
		cmpi.l    #$4E564449,(a0) ; 'NVDI'
		bne.s     nvdi_check2
		move.l    4(a0),d0
		rts
nvdi_check2:
		addq.w    #8,a0
nvdi_check3:
		move.l    (a0),d0
		bne.s     nvdi_check1
nvdi_check4:
		moveq.l   #0,d0
		rts
