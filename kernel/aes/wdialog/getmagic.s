		; FIXME: duplicate to mgx_check
		XDEF get_magic

get_magic:
		movea.l   ($000005A0).w,a0
		move.l    a0,d0
		beq.s     get_magic4
		bra.s     get_magic3
get_magic1:
		cmpi.l    #$4D616758,(a0) ; 'MagX'
		bne.s     get_magic2
		move.l    4(a0),d0
		rts
get_magic2:
		addq.w    #8,a0
get_magic3:
		move.l    (a0),d0
		bne.s     get_magic1
get_magic4:
		moveq.l   #0,d0
		rts


