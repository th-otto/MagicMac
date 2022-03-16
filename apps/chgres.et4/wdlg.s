		XREF _GemParBlk
		XREF my_aes

		XDEF wdlg_create
		XDEF wdlg_open
		XDEF wdlg_close
		XDEF wdlg_delete
		XDEF wdlg_get_tree
		XDEF wdlg_get_edit
		XDEF wdlg_get_udata
		XDEF wdlg_get_handle
		XDEF wdlg_set_edit
		XDEF wdlg_evnt
		XDEF wdlg_redraw

		XDEF lbox_create
		XDEF lbox_do
		XDEF lbox_update
		XDEF lbox_delete
		XDEF lbox_cnt_items
		XDEF lbox_get_tree
		XDEF lbox_get_avis
		XDEF lbox_get_udata
		XDEF lbox_get_afirst
		XDEF lbox_get_slct_idx
		XDEF lbox_get_items
		XDEF lbox_get_item
		XDEF lbox_get_slct_item
		XDEF lbox_get_idx
		XDEF lbox_get_bvis
		XDEF lbox_get_bentries
		XDEF lbox_get_bfirst
		XDEF lbox_set_asldr
		XDEF lbox_set_items
		XDEF lbox_free_items
		XDEF lbox_free_list
		XDEF lbox_ascroll_to
		XDEF lbox_set_bsldr
		XDEF lbox_set_bentries
		XDEF lbox_bscroll_to

		XDEF fnts_create
		XDEF fnts_delete
		XDEF fnts_open
		XDEF fnts_close
		XDEF fnts_get_no_styles
		XDEF fnts_get_style
		XDEF fnts_get_name
		XDEF fnts_get_info
		XDEF fnts_add
		XDEF fnts_remove
		XDEF fnts_update
		XDEF fnts_evnt
		XDEF fnts_do

	OFFSET 0
control:  ds.w 15
global:   ds.w 15
intin:    ds.w 132
intout:   ds.w 140
addrin:   ds.l 16
addrout:  ds.l 16

	TEXT

wdlg_create:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A0,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0004,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    8(a7),(a2)+
	move.l    12(a7),(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

wdlg_open:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A1,(a2)
	move.w    #$0004,2(a2)
	move.w    #$0003,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	move.w    d2,(a2)+
	move.w    8(a7),(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    10(a7),(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_close:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A2,(a2)
	clr.w     2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_delete:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A3,(a2)
	clr.w     2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_get_tree:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A4,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0003,6(a2)
	lea.l     _GemParBlk+intin,a2
	clr.w     (a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    8(a7),(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_get_edit:
	move.l    a2,-(a7)
	move.l     a1,-(a7)
	move.w     #-1,_GemParBlk+intout+2
	lea.l     _GemParBlk+control,a2
	move.w    #$00A4,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0001,(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l    (a7)+,a1
	lea       _GemParBlk+intout,a0
	move.w     (a0)+,d0
	move.w     (a0),(a1)
	movea.l   (a7)+,a2
	rts

wdlg_get_udata:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A4,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0002,(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

wdlg_get_handle:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A4,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0003,(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_set_edit:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A5,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	clr.w     (a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_set_tree:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A5,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #1,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_set_size:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A5,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #2,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_evnt:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A6,(a2)
	clr.w     2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

wdlg_redraw:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00A7,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_create:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AA,(a2)
	move.w    #$0008,2(a2)
	move.w    #$0008,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	lea.l     8(a7),a0
	move.l    (a0)+,(a2)+
	move.l    (a0)+,(a2)+
	lea.l     _GemParBlk+intin,a1
	move.w    d0,(a1)+
	move.w    d1,(a1)+
	move.l    (a0)+,(a2)+
	move.l    (a0)+,(a2)+
	move.w    d2,(a1)+
	move.w    (a0)+,(a1)+
	move.l    (a0)+,(a2)+
	move.l    (a0)+,(a2)+
	move.w    (a0)+,(a1)+
	move.w    (a0)+,(a1)+
	move.w    (a0)+,(a1)+
	move.w    (a0)+,(a1)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_update:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AB,(a2)
	clr.w     2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_do:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AC,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_delete:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AD,(a2)
	clr.w     2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_cnt_items:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	clr.w     (a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_get_tree:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0001,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_get_avis:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0002,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts
	
lbox_get_udata:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0003,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_get_afirst:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0004,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_get_slct_idx:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0005,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_get_items:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0006,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_get_item:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0007,(a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_get_slct_item:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0008,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

lbox_get_idx:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0009,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_get_bvis:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$000A,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts
	
lbox_get_bentries:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$000B,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_get_bfirst:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AE,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$000C,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

lbox_set_asldr:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	clr.w     (a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_set_items:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0001,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_free_items:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0002,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_free_list:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0003,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_ascroll_to:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0003,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0004,(a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    8(a7),(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_set_bsldr:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0005,(a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_set_bentries:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0006,(a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

lbox_bscroll_to:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00AF,(a2)
	move.w    #$0002,2(a2)
	move.w    #$0003,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0007,(a2)+
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    8(a7),(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

fnts_create:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B4,(a2)
	move.w    #$0004,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	move.w    d2,(a2)+
	move.w    8(a7),(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	movea.l   _GemParBlk+addrout,a0
	movea.l   (a7)+,a2
	rts

fnts_delete:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B5,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_open:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B6,(a2)
	move.w    #$0009,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.w    d1,(a2)+
	move.w    d2,(a2)+
	lea.l     8(a7),a0
	move.l    (a0)+,(a2)+
	move.l    (a0)+,(a2)+
	move.l    (a0)+,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_close:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B7,(a2)
	move.w    #$0000,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_get_no_styles:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B8,(a2)
	move.w    #$0003,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0000,(a2)+
	move.l    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_get_style:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B8,(a2)
	move.w    #$0004,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0001,(a2)+
	move.l    d0,(a2)+
	move.w    d1,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	move.l    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_get_name:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B8,(a2)
	move.w    #$0003,2(a2)
	move.w    #$0004,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0002,(a2)+
	move.l    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	move.l    8(a7),(a2)+
	move.l    12(a7),(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_get_info:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B8,(a2)
	move.w    #$0003,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0003,(a2)+
	move.l    d0,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,-(a7)
	bsr       my_aes
	movea.l   (a7)+,a1
	movea.l   8(a7),a2
	lea.l     _GemParBlk+intout,a0
	move.w    (a0)+,d0
	move.w    (a0)+,(a1)
	move.w    (a0)+,(a2)
	movea.l   (a7)+,a2
	rts

fnts_add:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B9,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0000,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr       my_aes
	move.w    _GemParBlk+intout,d0
	movea.l   (a7)+,a2
	rts

fnts_remove:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00B9,(a2)
	move.w    #$0001,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+intin,a2
	move.w    #$0001,(a2)+
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	bsr       my_aes
	movea.l   (a7)+,a2
	rts

fnts_evnt:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00BA,(a2)
	move.w    #$0000,2(a2)
	move.w    #$0002,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	move.l    a1,(a2)+
	bsr.w     my_aes
	lea.l     _GemParBlk+intout,a2
	move.w    (a2)+,d0
	lea.l     8(a7),a0
	movea.l   (a0)+,a1
	move.w    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.w    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a7)+,a2
	rts

fonts_do:
	move.l    a2,-(a7)
	lea.l     _GemParBlk+control,a2
	move.w    #$00BB,(a2)
	move.w    #$0007,2(a2)
	move.w    #$0001,6(a2)
	lea.l     _GemParBlk+addrin,a2
	move.l    a0,(a2)+
	lea.l     _GemParBlk+intin,a2
	move.w    d0,(a2)+
	move.l    d1,(a2)+
	move.l    d2,(a2)+
	move.l    8(a7),(a2)+
	move.l    a1,-(a7)
	bsr.w     my_aes
	movea.l   (a7)+,a1
	lea.l     _GemParBlk+intout,a2
	move.w    (a2)+,d0
	move.w    (a2)+,(a1)
	lea.l     12(a7),a0
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a0)+,a1
	move.l    (a2)+,(a1)
	movea.l   (a7)+,a2
	rts
