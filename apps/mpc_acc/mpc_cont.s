	xdef mpc_control
	xdef mpc_call
	xdef mpc_debout
	
	.text
mpc_control:
	lea.l      4(a7),a0
	move.l     4(a7),d0                ; function no
	movem.l    d1-d7/a0-a7,-(a7)
	dc.w 0x47bf,0x0020                 ; mec3       $0020
	movem.l    (a7)+,d1-d7/a0-a7
	rts


mpc_call:
	link       a6,#0
	movem.l    d1-d7/a0-a7,-(a7)
	moveq.l    #0x30,d0                ; function no
	movea.l    8(a6),a1
	move.l     12(a6),d1
	movea.l    16(a6),a2
	move.l     20(a6),d2
	dc.w 0x47bf,0x0020                 ; mec3       $0020
	movem.l    (a7)+,d1-d7/a0-a7
	unlk       a6
	rts

mpc_debout:
	link       a6,#0
	movem.l    d1-d7/a0,-(a7)
	moveq.l    #0x40,d0                ; function no
	movea.l    8(a6),a0                ; str
	move.l     12(a6),d1               ; up to 7 parameters
	move.l     16(a6),d2
	move.l     20(a6),d3
	move.l     24(a6),d4
	move.l     28(a6),d5
	move.l     32(a6),d6
	move.l     36(a6),d7
	dc.w 0x47bf,0x0020                 ; mec3       $0020
	movem.l    (a7)+,d1-d7/a0
	unlk       a6
	rts
