		XDEF dsp_pdlg_create
		XDEF dsp_pdlg_delete
		XDEF dsp_pdlg_open
		XDEF dsp_pdlg_close
		XDEF dsp_pdlg_get
		XDEF dsp_pdlg_set
		XDEF dsp_pdlg_evnt
		XDEF dsp_pdlg_do
		
		XREF pdlg_create
		XREF pdlg_delete
		XREF pdlg_xopen
		XREF pdlg_close
		XREF pdlg_get_setsize
		XREF pdlg_add_printers
		XREF pdlg_remove_printers
		XREF pdlg_update
		XREF pdlg_add_sub_dialogs
		XREF pdlg_remove_sub_dialogs
		XREF pdlg_new_settings
		XREF pdlg_free_settings
		XREF pdlg_dflt_settings
		XREF pdlg_validate_settings
		XREF pdlg_use_settings
		XREF pdlg_save_default_settings
		XREF pdlg_evnt
		XREF pdlg_do

		.TEXT

dsp_pdlg_create:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		move.w    (a2)+,d0
		bsr       pdlg_create
		move.l    a0,(a5)
		movem.l   (a7)+,a2-a5
		rts

dsp_pdlg_delete:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		movea.l   (a3)+,a0
		bsr       pdlg_delete
		move.w    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts

dsp_pdlg_open:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		move.w    (a2)+,d0
		move.w    (a2)+,d1
		move.w    (a2)+,d2
		movea.l   4(a0),a0
		move.w    4(a0),-(a7)
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		move.l    (a3)+,-(a7)
		bsr       pdlg_xopen
		addq.l    #6,a7
		move.w    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts

dsp_pdlg_close:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		movea.l   (a3)+,a0
		lea.l     2(a4),a1
		lea.l     4(a4),a2
		move.l    a2,-(a7)
		bsr       pdlg_close
		addq.l    #4,a7
		move.w    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts

pdlg_get_error:
		movem.l   (a7)+,a2-a5
		rts
dsp_pdlg_get:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		move.w    (a2)+,d0
		bne.s     pdlg_get_error
		bsr       pdlg_get_setsize
		move.l    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts

dsp_pdlg_set:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		move.w    (a2)+,d0
		cmp.w     #10,d0
		bhi.s     dsp_pdlg_set_error
		lsl.w     #3,d0
		lea.l     apdlg_set_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0) ; set nintout
		move.w    (a1)+,8(a0) ; set naddrout
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
dsp_pdlg_set_error:
		movem.l   (a7)+,a2-a5
		rts

apdlg_set_tab:
	dc.w 1,0
	dc.l dsp_pdlg_add_printers
	dc.w 1,0
	dc.l dsp_pdlg_remove_printers
	dc.w 0,0 ; BUG: nintout should be 1
	dc.l dsp_pdlg_update
	dc.w 1,0
	dc.l dsp_pdlg_add_sub_dialogs
	dc.w 1,0
	dc.l dsp_pdlg_remove_sub_dialogs
	dc.w 0,1
	dc.l dsp_pdlg_new_settings
	dc.w 1,0
	dc.l dsp_pdlg_free_settings
	dc.w 1,0
	dc.l dsp_pdlg_dflt_settings
	dc.w 1,0
	dc.l dsp_pdlg_validate_settings
	dc.w 1,0
	dc.l dsp_pdlg_use_settings
	dc.w 1,0
	dc.l dsp_pdlg_save_default_settings

dsp_pdlg_add_printers:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_add_printers
		move.w    d0,(a4)
		rts

dsp_pdlg_remove_printers:
		movea.l   (a3)+,a0
		bsr       pdlg_remove_printers
		move.w    d0,(a4)
		rts

dsp_pdlg_update:
		movea.l   (a3)+,a0
		addq.l    #4,a3
		movea.l   (a3)+,a1
		bsr       pdlg_update
		move.w    d0,(a4)
		rts

dsp_pdlg_add_sub_dialogs:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_add_sub_dialogs
		move.w    d0,(a4)
		rts

dsp_pdlg_remove_sub_dialogs:
		movea.l   (a3)+,a0
		bsr       pdlg_remove_sub_dialogs
		move.w    d0,(a4)
		rts

dsp_pdlg_new_settings:
		movea.l   (a3)+,a0
		bsr       pdlg_new_settings
		move.l    a0,(a5)
		rts

dsp_pdlg_free_settings:
		movea.l   (a3)+,a0
		bsr       pdlg_free_settings
		move.w    d0,(a4)
		rts

dsp_pdlg_dflt_settings:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_dflt_settings
		move.w    d0,(a4)
		rts

dsp_pdlg_validate_settings:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_validate_settings
		move.w    d0,(a4)
		rts

dsp_pdlg_use_settings:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_use_settings
		move.w    d0,(a4)
		rts

dsp_pdlg_save_default_settings:
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		bsr       pdlg_save_default_settings
		move.w    d0,(a4)
		rts


dsp_pdlg_evnt:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		lea.l     2(a4),a2
		move.l    a2,-(a7)
		move.l    (a3)+,-(a7)
		bsr       pdlg_evnt
		addq.l    #8,a7
		move.w    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts

dsp_pdlg_do:
		movem.l   a2-a5,-(a7)
		movea.l   8(a0),a2
		movea.l   16(a0),a3
		movea.l   12(a0),a4
		movea.l   20(a0),a5
		move.w    (a2)+,d0
		movea.l   (a3)+,a0
		movea.l   (a3)+,a1
		move.l    (a3)+,-(a7)
		bsr       pdlg_do
		addq.l    #4,a7
		move.w    d0,(a4)
		movem.l   (a7)+,a2-a5
		rts
