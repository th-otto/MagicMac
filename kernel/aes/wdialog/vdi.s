				INCLUDE	"gem.i"

				XDEF v_opnvwk

				XDEF _VdiCtrl
				XDEF vdi
				XDEF aes_global
				XDEF _myVDIParBlk

				XDEF v_pline
				XDEF v_opnwk
				XDEF v_clswk
				XDEF v_opnvwk
				XDEF v_clsvwk
				XDEF vs_clip
				XDEF vswr_mode
				XDEF vst_unload_fonts
				XDEF vst_skew
				XDEF vst_setsize32
				XDEF vst_point
				XDEF vst_height
				XDEF vst_load_fonts
				XDEF vst_font
				XDEF vst_effects
				XDEF vst_color
				XDEF vst_arbpt32
				XDEF vst_kern
				XDEF vst_alignment
				XDEF vsl_type
				XDEF vsl_color
				XDEF vsf_interior
				XDEF vsf_color
				XDEF vr_recfl
				XDEF vrt_cpyfm
				XDEF vro_cpyfm
				XDEF vq_gdos
				XDEF vq_extnd
				XDEF vqt_width
				XDEF vqt_fontinfo
				XDEF vqt_attributes
				XDEF v_gtext
				XDEF v_ftext
				XDEF vqt_fontheader

				DATA
								
_VdiParBlk:		dc.l	_myVDIParBlk+control
				dc.l	_myVDIParBlk+intin
				dc.l	_myVDIParBlk+ptsin
				dc.l	_myVDIParBlk+intout
				dc.l	_myVDIParBlk+ptsout

vdipb:
				dc.l	_myVDIParBlk+control
				dc.l	_myVDIParBlk+intin
				dc.l	_myVDIParBlk+ptsin
				dc.l	_myVDIParBlk+intout
				dc.l	_myVDIParBlk+ptsout
				
				BSS

_myVDIParBlk:
				ds.w	VDI_CNTRLMAX    ; control
				ds.w	VDI_INTINMAX    ; intin
				ds.w	VDI_INTOUTMAX   ; intout
				ds.w	VDI_PTSINMAX    ; ptsin
				ds.w	VDI_PTSOUTMAX   ; ptsout

				
				TEXT

; _VdiCtrl(short handle, short opcode, long counts)
				MODULE	_VdiCtrl
				lea		_myVDIParBlk+control,a0
				move.w	d0,v_handle(a0)
				move.w	d1,(a0)+ ; v_opcode
				move.w	d2,v_nintin-2(a0)
				swap    d2
				move.w	d2,v_nptsin-2(a0)
				moveq	#$73,d0
				move.l	#_VdiParBlk,d1
				pea (a2)
				trap	#2
				move.l	(a7)+,a2
				lea		_myVDIParBlk+intout,a0
				move.w	(a0)+,d0
				rts
				ENDMOD

; vdi(VDIPB *pb)
				MODULE	vdi
				pea (a2)
				moveq	#$73,d0
				move.l	a0,d1
				trap	#2
				move.l	(a7)+,a2
				rts
				ENDMOD

; v_pline(short handle, short nptsin, short *ptsin)
				MODULE	v_pline
				move.l a0,_VdiParBlk+v_ptsin
				move.w d1,d2
				swap d2
				clr.w d2
				moveq #6,d1
				bsr.w _VdiCtrl
				move.l #_myVDIParBlk+ptsin,_VdiParBlk+v_ptsin
				rts
				ENDMOD

				MODULE	v_opnwk
				pea.l     (a2)
				pea.l     (a1)
				lea.l     vdipb,a1
				move.l    a1,d1
				move.l    a0,v_intin(a1)
				movea.l   12(a7),a0
				move.l    a0,v_intout(a1)
				lea.l     90(a0),a0
				move.l    a0,v_ptsout(a1)
				lea.l     _myVDIParBlk+control,a0
				move.l    #$00010000,v_opcode(a0) ; v_opcode + v_nptsin
				move.w    #11,v_nintin(a0)
				moveq.l   #115,d0
				trap      #2
				movea.l   (a7)+,a0
				move.w    _myVDIParBlk+control+v_handle,(a0)
				movea.l   (a7)+,a2
				rts
				ENDMOD

				MODULE	v_opnvwk
				pea.l     (a2)
				pea.l     (a1)
				lea.l     _myVDIParBlk+control,a2
				move.w    (a1),v_handle(a2)
				lea.l     vdipb,a1
				move.l    a1,d1
				move.l    a0,v_intin(a1)
				movea.l   12(a7),a0
				move.l    a0,v_intout(a1)
				lea.l     90(a0),a0
				move.l    a0,v_ptsout(a1)
				move.l    #$00640000,(a2) ; v_opcode + v_nptsin
				move.w    #11,v_nintin(a2)
				moveq.l   #115,d0
				trap      #2
				movea.l   (a7)+,a0
				move.w    _myVDIParBlk+control+v_handle,(a0)
				movea.l   (a7)+,a2
				rts
				ENDMOD

				MODULE	v_clswk
				moveq.l   #2,d1
				moveq.l   #0,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	v_clsvwk
				moveq.l   #101,d1
				moveq.l   #0,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vs_clip
				lea.l     _myVDIParBlk+ptsin,a1
				move.l    (a0)+,(a1)+
				move.l    (a0),(a1)
				move.w    d1,intin-ptsin-4(a1)
				move.w    #129,d1
				move.l    #$00020001,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vswr_mode
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #32,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_unload_fonts
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #120,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_skew
				move.w    d1,_myVDIParBlk+intin
				move.w    #253,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_setsize32
				pea.l     (a1)
				pea.l     (a0)
				move.l    d1,_myVDIParBlk+intin
				move.w    #252,d1
				moveq.l   #2,d2
				bsr       _VdiCtrl
				subq.w    #2,a0
				move.l    (a0),d0
				lea.l     ptsout-intout(a0),a0
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   4(a7),a1
				move.w    (a0)+,(a1)
				movea.l   8(a7),a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vst_point
				pea.l     (a1)
				pea.l     (a0)
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #107,d1
				moveq.l   #1,d2
				bsr       _VdiCtrl
				lea.l     ptsout-intout-2(a0),a0
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   4(a7),a1
				move.w    (a0)+,(a1)
				movea.l   8(a7),a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vst_height
				pea.l     (a1)
				pea.l     (a0)
				lea.l     _myVDIParBlk+ptsin,a0
				clr.w     (a0)+
				move.w    d1,(a0)
				moveq.l   #12,d1
				move.l    #$00010000,d2
				bsr       _VdiCtrl
				lea.l     ptsout-intout-2(a0),a0
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   4(a7),a1
				move.w    (a0)+,(a1)
				movea.l   8(a7),a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vst_load_fonts
				move.w    d1,_myVDIParBlk+intin
				clr.l     _myVDIParBlk+control+20 /* contrl[10/11] = 0 */
				moveq.l   #119,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_font
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #21,d1
				moveq.l   #1,d2
				bra       _VdiCtrl

				MODULE	vst_effects
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #106,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_color
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #22,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vst_arbpt32
				pea.l     (a1)
				pea.l     (a0)
				move.l    d1,_myVDIParBlk+intin
				move.w    #246,d1
				moveq.l   #2,d2
				bsr       _VdiCtrl
				subq.w    #2,a0
				move.l    (a0),d0
				lea.l     ptsout-intout(a0),a0
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   (a7)+,a1
				move.w    (a0)+,(a1)
				movea.l   4(a7),a1
				move.w    (a0)+,(a1)
				movea.l   8(a7),a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vst_kern
				pea.l     (a1)
				pea.l     (a0)
				movem.w   d1-d2,_myVDIParBlk+intin
				move.w    #237,d1
				moveq.l   #2,d2
				bsr       _VdiCtrl
				movea.l   (a7)+,a1
				move.w    d0,(a1)
				movea.l   (a7)+,a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vst_alignment
				pea.l     (a1)
				pea.l     (a0)
				movem.w   d1-d2,_myVDIParBlk+intin
				moveq.l   #39,d1
				moveq.l   #2,d2
				bsr       _VdiCtrl
				movea.l   (a7)+,a1
				move.w    d0,(a1)
				movea.l   (a7)+,a1
				move.w    (a0),(a1)
				rts
				ENDMOD

				MODULE	vsl_type
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #15,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vsl_color
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #17,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vsf_interior
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #23,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vsf_color
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #25,d1
				moveq.l   #1,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vr_recfl
				lea.l     _myVDIParBlk+ptsin,a1
				move.l    (a0)+,(a1)+
				move.l    (a0),(a1)
				moveq.l   #114,d1
				move.l    #$00020000,d2
				bra       _VdiCtrl
				ENDMOD

				MODULE	vrt_cpyfm
				move.l    a0,_VdiParBlk+v_ptsin
				lea.l     _myVDIParBlk+control+v_param,a0
				move.l    a1,(a0)+
				move.l    4(a7),(a0)
				lea.l     intin-control-v_param-4(a0),a0
				move.w    d1,(a0)+
				movea.l   8(a7),a1
				move.l    (a1),(a0)
				moveq.l   #121,d1
				move.l    #$00040003,d2
				bsr       _VdiCtrl
				move.l    #_myVDIParBlk+ptsin,_VdiParBlk+v_ptsin
				rts
				ENDMOD

				MODULE	vro_cpyfm
				move.l    a0,_VdiParBlk+v_ptsin
				lea.l     _myVDIParBlk+control+v_param,a0
				move.l    a1,(a0)+
				move.l    4(a7),(a0)
				move.w    d1,intin-control-v_param-4(a0)
				moveq.l   #109,d1
				move.l    #$00040001,d2
				bsr       _VdiCtrl
				move.l    #_myVDIParBlk+ptsin,_VdiParBlk+v_ptsin
				rts
				ENDMOD

				MODULE	vq_gdos
				pea (a2)
				moveq    #-2,d0
				trap     #2
				addq.w   #2,d0
				movea.l  (sp)+,a2
				rts
				ENDMOD

				MODULE	vq_extnd
				move.l    a0,_VdiParBlk+v_intout
				lea.l     90(a0),a0
				move.l    a0,_VdiParBlk+v_ptsout
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #102,d1
				moveq.l   #1,d2
				bsr       _VdiCtrl
				move.l    #_myVDIParBlk+intout,_VdiParBlk+v_intout
				move.l    #_myVDIParBlk+ptsout,_VdiParBlk+v_ptsout
				rts
				ENDMOD

				MODULE	vqt_width
				pea.l     (a1)
				pea.l     (a0)
				move.w    d1,_myVDIParBlk+intin
				moveq.l   #117,d1
				moveq.l   #1,d2
				bsr       _VdiCtrl
				movea.l   (a7)+,a1
				lea.l     ptsout-intout-2(a0),a0
				move.w    (a0),(a1)
				movea.l   (a7)+,a1
				move.w    4(a0),(a1)
				movea.l   4(a7),a1
				move.w    8(a0),(a1)
				rts
				ENDMOD

				MODULE vqt_fontinfo
				pea.l     (a1)
				pea.l     (a0)
				move.w    #131,d1
				moveq.l   #0,d2
				bsr       _VdiCtrl
				movea.l   (a7)+,a1
				move.w    d0,(a1)
				movea.l   (a7)+,a1
				move.w    (a0),(a1)
				lea.l     ptsout-intout-2(a0),a0
				movea.l   8(a7),a1 ; maxwidth
				move.w    (a0)+,(a1)
				move.l    a2,d1
				movea.l   4(a7),a1 ; distances
				movea.l   12(a7),a2 ; effects
				move.w    (a0)+,(a1)+
				move.w    (a0)+,(a2)+
				move.w    (a0)+,(a1)+
				move.w    (a0)+,(a2)+
				move.w    (a0)+,(a1)+
				move.w    (a0)+,(a2)+
				move.w    (a0)+,(a1)+
				move.w    2(a0),(a1)
				movea.l   d1,a2
				rts
				ENDMOD

				MODULE vqt_attributes
				lea.l     _VdiParBlk,a1
				move.l    a0,v_intout(a1)
				lea.l     12(a0),a0
				move.l    a0,v_ptsout(a1)
				moveq.l   #38,d1
				moveq.l   #0,d2
				bsr       _VdiCtrl
				move.l    #_myVDIParBlk+ptsout,_VdiParBlk+v_ptsout
				move.l    #_myVDIParBlk+intout,_VdiParBlk+v_intout
				rts
				ENDMOD

				MODULE v_gtext
				lea.l     _myVDIParBlk+intin,a1
				movem.w   d1-d2,ptsin-intin(a1)
				move.l    #$00010000,d2
				moveq.l   #0,d1
				bra.s     v_gtext2
v_gtext1:
				move.w    d1,(a1)+
				addq.w    #1,d2
v_gtext2:
				move.b    (a0)+,d1
				bne.s     v_gtext1
				moveq.l   #8,d1
				bra       _VdiCtrl
				ENDMOD

				MODULE v_ftext
				lea.l     _myVDIParBlk+intin,a1
				movem.w   d1-d2,ptsin-intin(a1)
				move.l    #$00010000,d2
				moveq.l   #0,d1
				bra.s     v_ftext2
v_ftext1:
				move.w    d1,(a1)+
				addq.w    #1,d2
v_ftext2:
				move.b    (a0)+,d1
				bne.s     v_ftext1
				move.w    #241,d1
				bra       _VdiCtrl
				ENDMOD

				MODULE vqt_fontheader
				pea.l     (a1)
				move.l    a0,_myVDIParBlk+intin
				move.w    #232,d1
				moveq.l   #2,d2
				bsr       _VdiCtrl
				movea.l   (a7)+,a1
				move.w    control+v_nintout-intout-2(a0),d1
				move.w    d1,d0
				subq.w    #2,a0
				bra.s     vqt_fontheader2
vqt_fontheader1:
				move.w    (a0)+,d2
				move.b    d2,(a1)+
vqt_fontheader2:
				dbf       d1,vqt_fontheader1
				rts
				ENDMOD
