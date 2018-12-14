
		XDEF objc_sysvar
		XDEF my_aes
		XDEF _crystal
		XDEF _aes

		XDEF appl_init
		XDEF appl_exit
		XDEF evnt_multi
		XDEF objc_offset
		XDEF graf_handle
		XDEF graf_mouse
		XDEF wind_update
		XDEF rsrc_load
		XDEF rsrc_free
		XDEF shel_write

		XDEF _GemParBlk

		OFFSET 0
control:  ds.w 15
global:   ds.w 15
intin:    ds.w 132
intout:   ds.w 140
addrin:   ds.l 16
addrout:  ds.l 16
gemparbsize:

		DATA
		
aespb1:
		dc.l _GemParBlk+control
		dc.l _GemParBlk+global
		dc.l _GemParBlk+intin
		dc.l _GemParBlk+intout
		dc.l _GemParBlk+addrin
		dc.l _GemParBlk+addrout
		
aespb2:
		dc.l _GemParBlk+control
		dc.l _GemParBlk+global
		dc.l _GemParBlk+intin
		dc.l _GemParBlk+intout
		dc.l _GemParBlk+addrin
		dc.l _GemParBlk+addrout
		
aespb3:
		dc.l _GemParBlk+control
		dc.l _GemParBlk+global
		dc.l _GemParBlk+intin
		dc.l _GemParBlk+intout
		dc.l _GemParBlk+addrin
		dc.l _GemParBlk+addrout
		
		BSS
_GemParBlk:
		ds.b gemparbsize

		TEXT
		
my_aes:
	lea.l     aespb1,a0
	move.l    a0,d1
	move.w    #200,d0
	trap      #2
	rts

objc_sysvar:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control(pc),a2
	move.w    #48,(a2)
	move.w    #4,2(a2)
	clr.w     6(a2)
	lea.l     _GemParBlk+intin(pc),a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	move.w    d2,(a2)+
	move.w    8(a7),(a2)+
	movem.l   a0-a1,-(a7)
	bsr.w     my_aes2
	movem.l   (a7)+,a0-a1
	lea.l     _GemParBlk+intout(pc),a2
	move.w    (a2)+,d0
	move.w    (a2)+,(a0)
	move.w    (a2)+,(a1)
	movea.l   (a7)+,a2
	rts

my_aes2:
	lea.l     aespb2(pc),a0
	move.l    a0,d1
	move.w    #200,d0
	trap      #2
	rts

_crystal:
	move.l    a2,-(a7)
	move.w    #$00C8,d0
	move.l    a0,d1
	trap      #2
	movea.l   (a7)+,a2
	rts

_aes:
	move.l    a2,-(a7)
	moveq.l   #0,d1
	lea.l     _GemParBlk+control,a0
	move.l    d1,(a0)+
	move.l    d1,(a0)+
	move.w    d1,(a0)
	movep.l   d0,-7(a0)
	move.w    #200,d0
	move.l    #aespb3,d1
	trap      #2
	lea.l     _GemParBlk+intout,a0
	move.w    (a0)+,d0
	movea.l   (a7)+,a2
	rts

appl_init:
	move.l    #$0A000100,d0
	bra.w     _aes

appl_exit:
	move.l    #$13000100,d0
	bra.w     _aes

evnt_multi:
	move.l    a0,_GemParBlk+addrin
	move.l    a1,-(a7)
	lea.l     8(a7),a0
	lea.l     _GemParBlk+intin,a1
	move.w    d0,(a1)+
	move.w    d1,(a1)+
	move.w    d2,(a1)+
	move.l    (a0)+,(a1)+
	move.l    (a0)+,(a1)+
	move.l    (a0)+,(a1)+
	move.l    (a0)+,(a1)+
	move.l    (a0)+,(a1)+
	move.l    (a0)+,(a1)+
	move.w    (a0),(a1)
	move.l    #$19100701,d0
	bsr.w     _aes
	movea.l   (a7)+,a1
	move.w    (a0)+,(a1)
	lea.l     30(a7),a1
	move.l    a2,-(a7)
	movea.l   (a1)+,a2
	move.w    (a0)+,(a2)
	movea.l   (a1)+,a2
	move.w    (a0)+,(a2)
	movea.l   (a1)+,a2
	move.w    (a0)+,(a2)
	movea.l   (a1)+,a2
	move.w    (a0)+,(a2)
	movea.l   (a1),a2
	move.w    (a0),(a2)
	movea.l   (a7)+,a2
	rts

objc_offset:
	move.w    d0,_GemParBlk+intin
	move.l    a0,_GemParBlk+addrin
	move.l    a1,-(a7)
	move.l    #$2C010301,d0
	bsr       _aes
	movea.l   (a7)+,a1
	move.w    (a0)+,(a1)
	movea.l   4(a7),a1
	move.w    (a0),(a1)
	rts

graf_handle:
	move.l    a1,-(a7)
	move.l    a0,-(a7)
	move.l    #$4D000500,d0
	bsr       _aes
	movea.l   (a7)+,a1
	move.w    (a0)+,(a1)
	movea.l   (a7)+,a1
	move.w    (a0)+,(a1)
	movea.l   4(a7),a1
	move.w    (a0)+,(a1)
	movea.l   8(a7),a1
	move.w    (a0),(a1)
	rts

graf_mouse:
	move.w    d0,_GemParBlk+intin
	move.l    a0,_GemParBlk+addrin
	move.l    #$4E010101,d0
	bra       _aes

wind_update:
	move.w    d0,_GemParBlk+intin
	move.l    #$6B010100,d0
	bra       _aes

rsrc_load:
	move.l    a0,_GemParBlk+addrin
	move.l    #$6E000101,d0
	bra       _aes

rsrc_free:
	move.l    #$6F000100,d0
	bra       _aes

shel_write:
	movem.w   d0-d2,_GemParBlk+intin
	movem.l   a0-a1,_GemParBlk+addrin
	move.l    #$79030102,d0
	bra       _aes
