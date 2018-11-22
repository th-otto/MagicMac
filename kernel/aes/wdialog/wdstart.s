        .EXPORT exit

        .EXPORT _BasPag
        .EXPORT errno
        .EXPORT _PgmSize
		.EXPORT gl_apversion

		XDEF magx_found
		XDEF magx_version
				
        .EXPORT __text, __data, __bss

        .IMPORT main
		.IMPORT wd_xinit
		.IMPORT wd_xexit
		.IMPORT wd_nvdi_exit
		.IMPORT wd_aes_init
		.IMPORT aes_check
		.IMPORT mgx_check
		.IMPORT nvdi_check
		.IMPORT aes_global

		XREF do_xfrm_popup
		XREF wdlg_create
		XREF wdlg_open
		XREF wdlg_close
		XREF wdlg_delete
		XREF wdlg_get_tree
		XREF wdlg_get_edit
		XREF wdlg_get_udata
		XREF wdlg_get_handle
		XREF wdlg_set_edit
		XREF wdlg_set_tree
		XREF wdlg_set_size
		XREF wdlg_set_iconify
		XREF wdlg_set_uniconify
		XREF wdlg_evnt
		XREF wdlg_redraw
		XREF lbox_create
		XREF lbox_update
		XREF lbox_do
		XREF lbox_delete
		XREF lbox_cnt_items
		XREF lbox_get_tree
		XREF lbox_get_avis
		XREF lbox_get_udata
		XREF lbox_get_afirst
		XREF lbox_get_slct_idx
		XREF lbox_get_items
		XREF lbox_get_item
		XREF lbox_get_slct_item
		XREF lbox_get_idx
		XREF lbox_get_bvis
		XREF lbox_get_bentries
		XREF lbox_get_bfirst
		XREF lbox_set_asldr
		XREF lbox_set_items
		XREF lbox_free_items
		XREF lbox_free_list
		XREF lbox_ascroll_to
		XREF lbox_set_bsldr
		XREF lbox_set_bentries
		XREF lbox_bscroll_to
		XREF fnts_create
		XREF fnts_delete
		XREF fnts_open
		XREF fnts_close
		XREF fnts_get_no_styles
		XREF fnts_get_style
		XREF fnts_get_name
		XREF fnts_get_info
		XREF fnts_add
		XREF fnts_remove
		XREF fnts_update
		XREF fnts_evnt
		XREF fnts_do
		XREF pdlg_create
		XREF pdlg_delete
		XREF pdlg_xopen
		XREF pdlg_close
		XREF pdlg_evnt
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

		XREF vdi_device
		XREF aes_font
		XREF aes_height
		XREF aes_flags
		
syshdr equ $4f2
_longframe equ $59e

WDLG_SUPPORTED equ $17 ; wdlg/lbox/fnts/pdlg supported


GAI_INFO equ $0200

LBOX_GET_BFIRST     equ 12
LBOX_BSCROLL_TO     equ 7

*>>>>>>> Data segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .DATA
__data:

*>>>>>>> Bss segment <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        .BSS
__bss:

* Pointer to base page

_BasPag:
        .DS.L   1

* Program size

_PgmSize:
        .DS.L   1

in_appl_init: ds.w 1 ; 24bce
applinit_ret_pb: ds.l 1 ; 24bd0
applinit_ret_pc: ds.l 1 ; 24bd4
agi_sema: ds.w 1
agi_ret_pb: ds.l 1 ; 24bda
agi_ret_pc: ds.l 1 ; 24bde
vdi_ret_pb: ds.l 1 ; 24be2
vdi_ret_pc: ds.l 1 ; 24be6
bios_ret_pc: ds.l 1 ; 24bea
in_wd_xinit: ds.w 1
stack_offset: ds.w 1 ; 24bf0
magx_found: ds.w 1 ; 24bf2
magx_version: ds.w 1 ; 24bf4
gl_apversion: ds.w 1 ; 24bf6
wk_handle: ds.w 1 ; 24bf8

stack: ds.b 4096
stackend:
	   ds.l 1

        .TEXT
__text:


Start:
        bra.s   Start0
		nop


******* Configuration data

		dc.b 'wdlg'
		dc.l 32
		dc.l 0
		dc.w 0
		dc.l $197
		dc.l 0
		dc.l 0
		dc.l 0
		
EmpStr:
        .DC.B   $00
        .EVEN



* Setup pointer to base page

Start0:
        move.l  4(a7),a0

* Compute size of required memory
* := text segment size + data segment size + bss segment size
*  + stack size + base page size
* (base page size includes stack size)

        move.l  12(a0),d0
        add.l   20(a0),d0
        add.l   28(a0),d0
        add.l   #$100,d0

        MOVE.L  a0,_BasPag
        MOVE.L  d0,_PgmSize

* Setup longword aligned application stack

        lea stackend,a7

* Free not required memory

        move.l  d0,-(a7)
        move.l  a0,-(a7)
        clr.w   -(a7)
        move.w  #74,-(a7)
        trap    #1
        lea.l   12(a7),a7

		clr.w     wk_handle
		clr.w     in_wd_xinit
	    bsr     aes_check
		move.w d0,gl_apversion

		pea.l     install(pc)
		move.w    #$0026,-(a7)
		trap      #14
		addq.l    #6,a7
		tst.w     d0
		beq.s     not_inst
		move.w    gl_apversion,d0
		beq.s     inst_ok
		moveq.l   #-1,d0
		bsr       wd_aes_init
		move.w    #1,in_wd_xinit
		clr.w     d1
		bsr       wd_xinit
		clr.w     in_wd_xinit
inst_ok:
		pea.l     inst_ok_msg
		move.w    #9,-(a7)
		trap      #1
		addq.l    #6,a7
		pea.l     crlf
		move.w    #9,-(a7)
		trap      #1
		addq.l    #6,a7
		clr.w     -(a7)
		move.l    _PgmSize,-(a7)
		move.w    #$0031,-(a7)
		trap      #1
not_inst:
		pea.l     not_inst_msg
		move.w    #9,-(a7)
		trap      #1
		addq.l    #6,a7
exit:
		clr.w     -(a7)
		trap      #1


install:

		clr.w     magx_version
		bsr       mgx_check
		tst.l     d0
		sne       d0
		ext.w     d0
		move.w    d0,magx_found
		beq.s     install1
		movea.l   (syshdr).w,a0
		move.l    24(a0),d0
		swap      d0
		cmpi.l    #$19960801,d0
		bcs.s     install1
		move.w    #$0500,magx_version
		cmpi.l    #$1998040A,d0
		bcs.s     install1
		move.w    #$0600,magx_version
		moveq.l   #0,d0
		rts
install1:
		move.w    #6,stack_offset
		tst.w     ($0000059E).w
		beq.s     install2
		move.w    #8,stack_offset
install2:
		clr.w     in_appl_init
		clr.w     agi_sema
		moveq.l   #34,d0
		lea.l     vdi_trap(pc),a0
		lea.l     old_vdi_trap(pc),a1
		bsr.w     instvec
		tst.w     gl_apversion
		beq.s     install3
		pea.l     aes_found_msg
		move.w    #9,-(a7)
		trap      #1
		addq.l    #6,a7
		moveq.l   #34,d0
		lea.l     aes_trap(pc),a0
		lea.l     old_aes_trap(pc),a1
		bsr.w     instvec
install3:
		moveq.l   #45,d0
		lea.l     bios_trap(pc),a0
		lea.l     old_bios_trap(pc),a1
		bsr.w     instvec
		moveq.l   #1,d0
		rts


instvec:
		movem.l   d0-d1/a0,-(a7)
		moveq.l   #-1,d1
		cmpa.l    d1,a1
		beq.s     instvec1
		movea.l   d1,a0
		bsr.s     setexc
		move.l    d0,(a1)
		movem.l   (a7),d0-d1/a0
instvec1:
		bsr.s     setexc
		movem.l   (a7)+,d0-d1/a0
		rts

setexc:
		movem.l   d1-d2/a1-a2,-(a7)
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		move.w    #5,-(a7)
		trap      #13
		addq.l    #8,a7
		movea.l   d0,a0
		movem.l   (a7)+,d1-d2/a1-a2
		rts

		dc.b 'XBRA'
		dc.b 'wdlg'
old_bios_trap: dc.l 0
bios_trap:
		btst      #5,(a7)
		bne.s     bios_super
		move.l    a0,-(a7)
		move.l    usp,a0
		cmpi.w    #5,(a0)+ ; is it Setexc call?
		bne.s     gooldbios
		cmpi.w    #$0022,(a0) ; is it GEM trap?
		beq.s     checkgem
		movea.l   (a7)+,a0
		move.l    old_bios_trap(pc),-(a7)
		rts
bios_super:
		move.l    a0,-(a7)
		lea.l     4(a7),a0
		adda.w    stack_offset,a0
		cmpi.w    #5,(a0)+ ; is it Setexc call?
		beq.s     checkcrit
gooldbios:
		movea.l   (a7)+,a0
		move.l    old_bios_trap(pc),-(a7)
		rts
checkcrit:
		cmpi.w    #$0101,(a0)+ ; is it critical error handler?
		bne.s     gooldbios
		cmpi.l    #-1,(a0)
		beq.s     gooldbios
/* check whether we are still in the GEM trap */
		movea.l   ($00000088).w,a0
checkcrit1:
		cmpa.l    #aes_trap,a0
		beq.s     gooldbios
		cmpi.l    #$58425241,-12(a0)
		bne.s     checkcrit2
		movea.l   -(a0),a0
		bra.s     checkcrit1
checkcrit2:
		move.l    ($00000088).w,old_aes_trap
		move.l    #aes_trap,($00000088).w
		bra.s     gooldbios
checkgem:
		cmpi.l    #-1,2(a0)
		beq.s     gooldbios
		movea.l   2(a0),a0
		cmpa.l    #vdi_trap,a0
		beq.s     gooldbios
		cmpi.l    #$58425241,-12(a0)
		bne.s     gooldbios
		cmpi.l    #$4E564449,-8(a0)
		bne.s     gooldbios
		movea.l   (a7)+,a0
		move.l    2(a7),bios_ret_pc
		move.l    #setexc_wrap,2(a7)
		move.l    old_bios_trap(pc),-(a7)
		rts
setexc_wrap:
		movem.l   d0-d2/a0-a2,-(a7)
		pea.l     setexc_ret(pc)
		move.w    #$0026,-(a7)
		trap      #14
		addq.l    #6,a7
		movem.l   (a7)+,d0-d2/a0-a2
		move.l    bios_ret_pc,-(a7)
		rts
setexc_ret:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   ($00000088).w,a1
setexc_ret1:
		movea.l   a1,a0
		cmpi.l    #$58425241,-12(a0)
		bne.s     setexc_ret2
		movea.l   -4(a0),a1
		cmpa.l    #vdi_trap,a1
		bne.s     setexc_ret1
		move.l    old_vdi_trap(pc),-4(a0)
		move.l    ($00000088).w,old_vdi_trap
		move.l    #vdi_trap,($00000088).w
setexc_ret2:
		movem.l   (a7)+,d0-d2/a0-a2
		rts


		dc.b 'XBRA'
		dc.b 'wdlg'
old_vdi_trap: dc.l 0
vdi_trap:
		cmpi.w    #115,d0
		bne.s     gooldvdi
		move.l    a0,-(a7)
		movea.l   d1,a0
		movea.l   (a0),a0
		move.w    (a0),d0
		cmpi.w    #1,d0
		beq.s     do_opnwk
		cmpi.w    #2,d0
		beq.s     do_clswk
vdiret:
		movea.l   (a7)+,a0
		moveq.l   #115,d0
gooldvdi:
		move.l    old_vdi_trap(pc),-(a7)
		rts
do_opnwk:
		tst.w     wk_handle
		bne.s     vdiret
		movea.l   d1,a0
		movea.l   4(a0),a0 ; get intin ptr
		move.w    (a0),d0 ; get workstartion id
		cmpi.w    #10,d0
		bgt.s     vdiret
		tst.w     d0
		bgt.s     do_opnwk1
		move.w    #$0001,(a0)
do_opnwk1:
		movea.l   (a7)+,a0
		move.l    d1,vdi_ret_pb
		move.l    2(a7),vdi_ret_pc
		move.l    #do_opnwk2,2(a7)
		moveq.l   #115,d0
		move.l    old_vdi_trap(pc),-(a7)
		rts
do_opnwk2:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   vdi_ret_pb,a0
		movea.l   (a0),a0
		move.w    12(a0),d0
		beq.s     do_opnwk3
		move.w    d0,wk_handle
		bsr       wd_aes_init
do_opnwk3:
		movem.l   (a7)+,d0-d2/a0-a2
		move.l    vdi_ret_pc,-(a7)
		rts

do_clswk:
		move.w    12(a0),d0
		cmp.w     wk_handle,d0
		bne.s     vdiret
		movem.l   d0-d2/a0-a2,-(a7)
		movea.w   #$008C,a0
do_clswk1:
		movea.l   -4(a0),a1
		cmpa.l    #aes_trap,a1
		beq.s     do_clswk2
		cmpi.l    #$58425241,-12(a1)
		bne.s     do_clswk3
		movea.l   a1,a0
		bra.s     do_clswk1
do_clswk2:
		move.l    -4(a1),-4(a0)
do_clswk3:
		bsr       nvdi_check
		tst.l     d0
		beq.s     do_clswk4
		bsr       wd_nvdi_exit
		bra.s     do_clswk5
do_clswk4:
		bsr       wd_xexit
do_clswk5:
		clr.w     wk_handle
		movem.l   (a7)+,d0-d2/a0-a2
		bra       vdiret

		dc.b 'XBRA'
		dc.b 'wdlg'
old_aes_trap: dc.l 0
aes_trap:
		cmpi.w    #$00C8,d0
		bne.s     gooldaes
		move.l    a0,-(a7)
		movea.l   d1,a0
		movea.l   (a0),a0
		move.w    (a0),d0
		cmp.w     #(aestabend-aestab-1),d0
		bhi.s     aesret
		move.b    aestab(pc,d0.w),d0
		bne       aesdispatch
aesret:
		movea.l   (a7)+,a0
aesret1:
		move.w    #$00C8,d0
gooldaes:
		move.l    old_aes_trap(pc),-(a7)
		rts
aestab:
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      10
		dc.b	  0
		dc.b      0
		dc.b	  13
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      130
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  135
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      160
		dc.b	  161
		dc.b      162
		dc.b	  163
		dc.b      164
		dc.b	  165
		dc.b      166
		dc.b	  167
		dc.b      0
		dc.b	  0
		dc.b      170
		dc.b	  171
		dc.b      172
		dc.b	  173
		dc.b      174
		dc.b	  175
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      180
		dc.b	  181
		dc.b      182
		dc.b	  183
		dc.b      184
		dc.b	  185
		dc.b      186
		dc.b	  187
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      0
		dc.b	  0
		dc.b      200
		dc.b	  201
		dc.b      202
		dc.b	  203
		dc.b      204
		dc.b	  205
		dc.b      206
		dc.b	  207
aestabend:

aesdispatch:
		cmp.w     #135,d0
		bne.s     aesdisp1
		move.w    magx_found,d0
		bne       aesret
		bra       do_form_popup
aesdisp1:
		cmp.w     #10,d0
		beq       do_applinit
		cmp.w     #13,d0
		beq       do_applfind
		cmp.w     #130,d0
		beq       do_appl_getinfo
		movea.l   (a7)+,a0
		move.l    2(a7),d0
		move.l    #gotouser,2(a7)
		rte
gotouser:
		move.l    d0,-(a7)
		movem.l   d1-d7/a0-a6,-(a7)
		movea.l   d1,a0
		movea.l   (a0),a0 ; get control array
		move.w    (a0),d0
		sub.w     #160,d0
		lsl.w     #3,d0
		lea.l     wdlg_fntab(pc,d0.w),a1
		move.w    (a1)+,4(a0)
		move.w    (a1)+,8(a0)
		movea.l   (a1)+,a1
		movea.l   d1,a0
		movea.l   4(a0),a2 ; get global array
		lea.l     aes_global,a3
		move.l    (a2)+,(a3)+
		move.w    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		move.l    (a2)+,(a3)+
		movea.l   8(a0),a2 ; a2 = intin array
		movea.l   16(a0),a3 ; a3 = addrin array
		movea.l   12(a0),a4 ; a4 = intout array
		movea.l   20(a0),a5 ; a5 = addrout array
		jsr       (a1)
		movem.l   (a7)+,d1-d7/a0-a6
		rts

wdlg_fntab:
		dc.w	0,1
		dc.l	dsp_wdlg_create     ; 160
		dc.w	1,0
		dc.l	dsp_wdlg_open       ; 161
		dc.w	1,0
		dc.l	dsp_wdlg_close      ; 162
		dc.w	1,0
		dc.l	dsp_wdlg_delete     ; 163
		dc.w	1,0
		dc.l	dsp_wdlg_get        ; 164
		dc.w	1,0
		dc.l	dsp_wdlg_set        ; 165
		dc.w	1,0
		dc.l	dsp_wdlg_evnt       ; 166
		dc.w	0,0
		dc.l	dsp_wdlg_redraw     ; 167
		dc.w	0,0
		dc.l	dsp_error           ; 168
		dc.w	0,0
		dc.l	dsp_error           ; 169
		dc.w	0,1
		dc.l	dsp_lbox_create     ; 170
		dc.w	0,0
		dc.l	dsp_lbox_update     ; 171
		dc.w	1,0
		dc.l	dsp_lbox_do         ; 172
		dc.w	1,0
		dc.l	dsp_lbox_delete     ; 173
		dc.w	0,0
		dc.l	dsp_lbox_get        ; 174
		dc.w	0,0
		dc.l	dsp_lbox_set        ; 175
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,1
		dc.l	dsp_fnts_create     ; 180
		dc.w	1,0
		dc.l	dsp_fnts_delete     ; 181
		dc.w	1,0
		dc.l	dsp_fnts_open       ; 182
		dc.w	1,0
		dc.l	dsp_fnts_close      ; 183
		dc.w	0,0
		dc.l	dsp_fnts_get        ; 184
		dc.w	0,0
		dc.l	dsp_fnts_set        ; 185
		dc.w	9,0
		dc.l	dsp_fnts_evnt       ; 186
		dc.w	8,0
		dc.l	dsp_fnts_do         ; 187
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,0
		dc.l	dsp_error           ;
		dc.w	0,0
		dc.l	dsp_fslx_open       ; 190
		dc.w	0,0
		dc.l	dsp_fslx_close      ; 191
		dc.w	0,0
		dc.l	dsp_fslx_getnxtfile ; 192
		dc.w	0,0
		dc.l	dsp_fslx_evnt       ; 193
		dc.w	0,0
		dc.l	dsp_fslx_do         ; 194
		dc.w	0,0
		dc.l	dsp_fslx_set        ; 195
		dc.w	0,0
		dc.l	dsp_error           ; 196
		dc.w	0,0
		dc.l	dsp_error           ; 197
		dc.w	0,0
		dc.l	dsp_error           ; 198
		dc.w	0,0
		dc.l	dsp_error           ; 199
		dc.w	0,1
		dc.l	dsp_pdlg_create     ; 200
		dc.w	1,0
		dc.l	dsp_pdlg_delete     ; 201
		dc.w	1,0
		dc.l	dsp_pdlg_open       ; 202
		dc.w	3,0
		dc.l	dsp_pdlg_close      ; 203
		dc.w	2,0
		dc.l	dsp_pdlg_get        ; 204
		dc.w	0,0
		dc.l	dsp_pdlg_set        ; 205
		dc.w	2,0
		dc.l	dsp_pdlg_evnt       ; 206
		dc.w	1,0
		dc.l	dsp_pdlg_do         ; 207



do_applinit:
		bset      #7,in_appl_init
		bne       aesret
		movea.l   (a7)+,a0
		move.l    d1,applinit_ret_pb
		move.l    2(a7),applinit_ret_pc
		move.l    #ret_from_applinit,2(a7)
		move.w    #$00C8,d0
		move.l    old_aes_trap(pc),-(a7)
		rts
ret_from_applinit:
		lea.l     stackend,a0
		move.l    a7,-(a0)
		movea.l   a0,a7
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   applinit_ret_pb,a0
		move.w    #1,in_wd_xinit
		movea.l   4(a0),a0
		move.w    (a0),d0
		move.w    4(a0),d1
		bsr       wd_xinit
		clr.w     in_wd_xinit
		movem.l   (a7)+,d0-d2/a0-a2
		movea.l   (a7)+,a7
		move.l    applinit_ret_pc,-(a7)
		clr.w     in_appl_init
		rts


do_applfind:
		tst.w     in_wd_xinit
		bne       aesret
		movea.l   d1,a0
		movea.l   16(a0),a0
		move.l    (a0),d0
; Zeiger == NULL ?
		beq       aesret
		movea.l   d0,a0
; Hiword == -1 ?
		swap      d0
		cmp.w     #-1,d0
		beq       aesret
; Hiword == -2 ?
		cmp.w     #-2,d0
		beq       aesret
		movep.w   0(a0),d0
		swap      d0
		movep.w   1(a0),d0
		cmp.l     #$3F474149,d0 ; '?GAI'
		bne       aesret
		tst.b     4(a0)
		bne       aesret
		movea.l   d1,a0
		movea.l   (a0),a0
		move.w    #1,4(a0) ; nintout = 1
		clr.w     8(a0)    ; naddrout = 0
		movea.l   d1,a0
		movea.l   12(a0),a0
		clr.w     (a0) ; intout[0] = 0
		movea.l   (a7)+,a0
		rte

do_appl_getinfo:
		movea.l   (a7)+,a0
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   d1,a0
		movea.l   8(a0),a1
		move.w    (a1),d0
		movea.l   12(a0),a1
		movea.l   (a0),a0
		tst.w     in_wd_xinit
		bne.s     do_appl_getinfo1
		move.w    aes_flags,d2
		and.w     #GAI_INFO,d2
		beq.s     do_appl_getinfo3
do_appl_getinfo1:
		subq.w    #7,d0
		bne       do_appl_getinfo5
		movem.l   (a7)+,d0-d2/a0-a2
		bset      #7,agi_sema
		bne       aesret1
		move.l    d1,agi_ret_pb
		move.l    2(a7),agi_ret_pc
		move.l    #ret_from_appl_getinfo,2(a7)
		move.w    #$00C8,d0
		move.l    old_aes_trap(pc),-(a7)
		rts
ret_from_appl_getinfo:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   agi_ret_pb,a0
		movea.l   12(a0),a1
		movea.l   (a0),a0
		ori.w     #WDLG_SUPPORTED,2(a1) ; intout[1]: wdlg/lbox/fnts/pdlg supported
		tst.w     (a1)
		bne.s     do_appl_getinfo2
		move.w    #5,4(a0) ; nintout = 5
		clr.w     8(a0) ; naddrout = 0
		move.w    #1,(a1)+ ; intout[0] = 1 (no error)
		bsr       agi7
do_appl_getinfo2:
		movem.l   (a7)+,d0-d2/a0-a2
		move.l    agi_ret_pc,-(a7)
		clr.w     agi_sema
		rts
do_appl_getinfo3:
		move.w    #5,4(a0) ; nintout = 5
		clr.w     8(a0) ; naddrout = 0
		move.w    #1,(a1)+ ; intout[0] = 1 (no error)
		cmp.w     #7,d0
		bhi.s     agierror
		add.w     d0,d0
		add.w     d0,d0
		movea.l   apgi_tab(pc,d0.w),a2
		jsr       (a2)
do_appl_getinfo4:
		movem.l   (a7)+,d0-d2/a0-a2
		rte
do_appl_getinfo5:
		movem.l   (a7)+,d0-d2/a0-a2
		bra       aesret1
agierror:
		clr.w     -(a1) ; intout[0] = 0 (error)
		move.w    #1,4(a0) ; nintout = 1
		bra.s     do_appl_getinfo4
apgi_tab:
		dc.l agi0
		dc.l agi1
		dc.l agi2
		dc.l agi3
		dc.l agi4
		dc.l agi5
		dc.l agi6
		dc.l agi7
agi0:
		move.w    aes_height,(a1)+       ; large size
		move.w    aes_font,(a1)+         ; large ID
		clr.l     (a1)+
		rts
agi1:
		move.w    #4,(a1)+               ; small size
		move.w    aes_font,(a1)+         ; small id
		clr.l     (a1)+
		rts
agi2:
		move.w    vdi_device,(a1)+  ; vdi device number
		move.w    #16,(a1)+         ; 16 colors
		clr.l     (a1)+
		rts
agi3:
		move.w    #COUNTRY,(a1)+    ; AES language
		clr.w     (a1)+
		clr.l     (a1)+
		rts
agi4:
agi5:
agi6:
		move.w    #1,4(a0) ; nintout = 1
		clr.w     -(a1) ;  intout[0] = 0 (error)
		rts
agi7:
		move.w    #WDLG_SUPPORTED,(a1)+ ; intout[1]: wdlg/lbox/fnts/pdlg supported
		clr.w     (a1)+
		clr.l     (a1)+
		rts

do_form_popup:
		movea.l   (a7)+,a0
		move.l    2(a7),d0
		move.l    #popup_user,2(a7)
		rte
popup_user:
		move.l    d0,-(a7)
		movem.l   d1-d2/a0-a1,-(a7)
		movea.l   d1,a1
		movea.l   8(a1),a0
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		movea.l   16(a1),a0
		movea.l   (a0),a0
		bsr       do_xfrm_popup
		movea.l   (a7),a1
		movea.l   (a1),a0
		move.w    #1,4(a0) ; nintout = 1
		movea.l   12(a1),a0
		move.w    d0,(a0)
		movem.l   (a7)+,d1-d2/a0-a1
		rts

dsp_fslx_open:
dsp_fslx_close:
dsp_fslx_getnxtfile:
dsp_fslx_evnt:
dsp_fslx_do:
dsp_fslx_set:
dsp_error:
		rts

dsp_wdlg_create:
		lea.l     16(a3),a3                ; addrin+4
		move.l    -(a3),-(a7)              ; addrin[3] = data
		move.w    (a2)+,d0                 ; intin[0] = code
		move.w    (a2)+,d1                 ; intin[1] = flags
		move.l    -(a3),-(a7)              ; addrin[2] = user_data
		movea.l   -(a3),a1                 ; addrin[1] = tree
		movea.l   -(a3),a0                 ; addrin[0] = handle_exit
		bsr       wdlg_create
		addq.l    #8,a7
		move.l    a0,(a5)                  ; addrout[0]
		rts

dsp_wdlg_open:
		lea.l     8(a2),a2                 ; intin+4
		lea.l     12(a3),a3                ; addrin+3
		move.l    -(a3),-(a7)              ; addrin[2] = data
		move.w    -(a2),-(a7)              ; intin[3] = code
		move.w    -(a2),d2                 ; intin[2] = y
		move.w    -(a2),d1                 ; intin[1] = x
		move.w    -(a2),d0                 ; intin[0] = kind
		movea.l   -(a3),a1                 ; addrin[1] = title
		movea.l   -(a3),a0                 ; addrin[0] = dialog
		bsr       wdlg_open
		addq.l    #6,a7
		move.w    d0,(a4)
		rts

dsp_wdlg_close:
		movea.l   (a3)+,a0                 ; addrin[0] = dialog
		lea.l     2(a4),a1                 ; intout[1] = x
		lea.l     4(a4),a2                 ; intout[2] = y
		move.l    a2,-(a7)
		bsr       wdlg_close
		addq.l    #4,a7
		move.w    d0,(a4)
		rts

dsp_wdlg_delete:
		movea.l   (a3),a0                  ; addrin[0] = dialog
		bsr       wdlg_delete
		move.w    d0,(a4)
		rts

dsp_wdlg_get:
		move.w    (a2)+,d0                 ; addrin[0]: dialog
		beq.s     awdlg_get_tree           ; intin[0] = subcode, 0: wdlg_get_tree?
		subq.w    #1,d0                    ; 1: wdlg_get_edit ?
		beq.s     awdlg_get_edit
		subq.w    #1,d0                    ; 2: wdlg_get_udata ?
		beq.s     awdlg_get_udata
		subq.w    #1,d0                    ; 3: wdlg_get_handle ?
		beq.s     awdlg_get_handle
		clr.w     (a4)                     ; intout[0] = 0: error
		rts
awdlg_get_tree:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1                 ; addrin[1]: tree
		move.l    (a3)+,-(a7)              ; addrin[2]: r
		bsr       wdlg_get_tree
		addq.l    #4,a7
		move.w    d0,(a4)
		rts
awdlg_get_edit:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		lea.l     2(a4),a1                 ; &intout[1]
		bsr       wdlg_get_edit
		move.w    d0,(a4)
		rts
awdlg_get_udata:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		bsr       wdlg_get_udata
		move.l    a0,(a5)
		rts
awdlg_get_handle:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		bsr       wdlg_get_handle
		move.w    d0,(a4)
		rts

dsp_wdlg_set:
		move.w    (a2)+,d0                 ; intin[0] = 0: wdlg_set_edit?
		beq.s     awdlg_set_edit
		subq.w    #1,d0
		beq.s     awdlg_set_tree
		subq.w    #1,d0
		beq.s     awdlg_set_size
		subq.w    #1,d0
		beq.s     awdlg_set_iconify
		subq.w    #1,d0
		beq.s     awdlg_set_uniconify
		clr.w     (a4)                     ; intout[0] = 0: error
		rts
awdlg_set_edit:
		move.w    (a2)+,d0                 
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		bsr       wdlg_set_edit
		move.w    d0,(a4)
		rts
awdlg_set_tree:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1
		bsr       wdlg_set_tree
		move.w    d0,(a4)
		rts
awdlg_set_size:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1
		bsr       wdlg_set_size
		move.w    d0,(a4)
		rts
awdlg_set_iconify:
		move.w    (a2)+,d0
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1
		move.l    (a3)+,d1
		move.l    (a3)+,-(a7)
		move.l    d1,-(a7)
		bsr       wdlg_set_iconify
		addq.l    #8,a7
		move.w    d0,(a4)
		rts
awdlg_set_uniconify:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1
		move.l    (a3)+,d0
		move.l    (a3)+,-(a7)
		move.l    d0,-(a7)
		bsr       wdlg_set_uniconify
		addq.l    #8,a7
		move.w    d0,(a4)
		rts

dsp_wdlg_evnt:
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1                 ; addrin[1]: events
		bsr       wdlg_evnt
		move.w    d0,(a4)
		rts

dsp_wdlg_redraw:
		move.w    (a2)+,d0                 ; intin[0]: obj
		move.w    (a2)+,d1                 ; intin[1]: depth
		movea.l   (a3)+,a0                 ; addrin[0]: dialog
		movea.l   (a3)+,a1                 ; addrin[1]: rect
		bsr       wdlg_redraw
		rts

dsp_lbox_create:
		lea.l     16(a2),a2                ; intin+8
		lea.l     32(a3),a3                ; addrin+8
		move.w    -(a2),-(a7)              ; intin[7]:    pause2
		move.w    -(a2),-(a7)              ; intin[6]:    width
		move.w    -(a2),-(a7)              ; intin[5]:    visible
		move.w    -(a2),-(a7)              ; intin[4]:    offset
		move.l    -(a3),-(a7)              ; addrin[7]:   dialog
		move.l    -(a3),-(a7)              ; addrin[6]:   user_data
		move.w    -(a2),-(a7)              ; intin[3]:    pause
		move.w    -(a2),d2                 ; intin[2]:    flags
		move.l    -(a3),-(a7)              ; addrin[5]:   objs
		move.l    -(a3),-(a7)              ; addrin[4]:   ctrl_objs
		move.w    -(a2),d1                 ; intin[1]:    first
		move.w    -(a2),d0                 ; intin[0]:    entries
		move.l    -(a3),-(a7)              ; addrin[3]:   items
		move.l    -(a3),-(a7)              ; addrin[2]:   set
		movea.l   -(a3),a1                 ; addrin[1]:   slct
		movea.l   -(a3),a0                 ; addrin[0]:   tree
		bsr       lbox_create
		lea.l     34(a7),a7
		move.l    a0,(a5)
		rts

dsp_lbox_update:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		movea.l   (a3)+,a1                 ; addrin[1]: rect
		bsr       lbox_update
		rts

dsp_lbox_do:
		move.w    (a2)+,d0                 ; intin[0]: obj
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_do
		move.w    d0,(a4)
		rts

dsp_lbox_delete:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_delete
		move.w    d0,(a4)
		rts

dsp_lbox_get:
		move.w    (a2)+,d0                 ; intin[0]: Funktionsnummer
		cmp.w     #LBOX_GET_BFIRST,d0
		bhi.s     albox_get_exit
		lsl.w     #3,d0
		lea.l     albox_get_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0)              ; nintout
		move.w    (a1)+,8(a0)              ; naddrount
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
albox_get_exit:
		rts
albox_get_tab:
		dc.w 1,0
		dc.l	albox_cnt_items
		dc.w 0,1
		dc.l	albox_get_tree
		dc.w 1,0
		dc.l	albox_get_avis
		dc.w 0,1
		dc.l	albox_get_udata
		dc.w 1,0
		dc.l	albox_get_first
		dc.w 1,0
		dc.l	albox_get_s_idx
		dc.w 0,1
		dc.l	albox_get_items
		dc.w 0,1
		dc.l	albox_get_item
		dc.w 0,1
		dc.l	albox_get_s_item
		dc.w 1,0
		dc.l	albox_get_idx
		dc.w 1,0
		dc.l	albox_get_bvis
		dc.w 1,0
		dc.l	albox_get_bentries
		dc.w 1,0
		dc.l	albox_get_bfirst

albox_cnt_items:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_cnt_items
		move.w    d0,(a4)
		rts
albox_get_tree:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_tree
		move.l    a0,(a5)
		rts
albox_get_avis:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_avis
		move.w    d0,(a4)
		rts
albox_get_udata:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_udata
		move.l    a0,(a5)
		rts
albox_get_first:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_afirst
		move.w    d0,(a4)
		rts
albox_get_s_idx:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_slct_idx
		move.w    d0,(a4)
		rts
albox_get_items:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_items
		move.l    a0,(a5)
		rts
albox_get_item:
		move.w    (a2)+,d0                 ; intin[1]: n
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_item
		move.l    a0,(a5)
		rts
albox_get_s_item:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_slct_item
		move.l    a0,(a5)
		rts
albox_get_idx:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		movea.l   (a3)+,a1
		bsr       lbox_get_idx
		move.w    d0,(a4)
		rts
albox_get_bvis:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_bvis
		move.w    d0,(a4)
		rts
albox_get_bentries:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_bentries
		move.w    d0,(a4)
		rts
albox_get_bfirst:
		movea.l   (a3)+,a0                 ; addrin[0]: box
		bsr       lbox_get_bfirst
		move.w    d0,(a4)
		rts

dsp_lbox_set:
		move.w    (a2)+,d0                 ; intin[0]: Funktionsnummer
		cmp.w     #LBOX_BSCROLL_TO,d0
		bhi.s     albox_set_exit
		lsl.w     #3,d0
		lea.l     albox_set_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0)
		move.w    (a1)+,8(a0)
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
albox_set_exit:
		rts
albox_set_tab:
		dc.w 0,0
		dc.l	albox_set_slider
		dc.w 0,0
		dc.l	albox_set_items
		dc.w 0,0
		dc.l	albox_free_items
		dc.w 0,0
		dc.l	albox_free_list
		dc.w 0,0
		dc.l	albox_scroll_to
		dc.w 0,0
		dc.l	albox_set_bsldr
		dc.w 0,0
		dc.l	albox_set_bentries
		dc.w 0,0
		dc.l	albox_bscroll_to
albox_set_slider:
		move.w    (a2)+,d0                  ; intin[1]: first
		movea.l   (a3)+,a0                  ; addrin[0]: box
		movea.l   (a3)+,a1                  ; addrin[1]: rect
		bsr       lbox_set_asldr
		rts
albox_set_items:
		movea.l   (a3)+,a0                  ; addrin[0]: box
		movea.l   (a3)+,a1                  ; items
		bsr       lbox_set_items
		rts
albox_free_items:
		movea.l   (a3)+,a0                  ; addrin[0]: box
		bsr       lbox_free_items
		rts
albox_free_list:
		movea.l   (a3)+,a0                  ; addrin[0]: box
		bsr       lbox_free_list
		rts
albox_scroll_to:
		move.w    (a2)+,d0                  ; intin[1]: first
		movea.l   (a3)+,a0                  ; addrin[0]: box
		movea.l   (a3)+,a1                  ; addrin[1]: box_rect
		move.l    (a3)+,-(a7)               ; addrin[2]: slider_rect
		bsr       lbox_ascroll_to
		addq.l    #4,a7
		rts
albox_set_bsldr:
		move.w    (a2)+,d0                  ; intin[1]: first
		movea.l   (a3)+,a0                  ; addrin[0]: box
		movea.l   (a3)+,a1                  ; addrin[1]: rect
		bsr       lbox_set_bsldr
		rts
albox_set_bentries:
		move.w    (a2)+,d0                  ; intin[1]: entries
		movea.l   (a3)+,a0                  ; addrin[0]: box
		bsr       lbox_set_bentries
		rts
albox_bscroll_to:
		move.w    (a2)+,d0                  ; intin[1]: first
		movea.l   (a3)+,a0                  ; addrin[0]: box
		movea.l   (a3)+,a1                  ; addrin[1]: box_rect
		move.l    (a3)+,-(a7)               ; addrin[2]: slider_rect
		bsr       lbox_bscroll_to
		addq.l    #4,a7
		rts

dsp_fnts_create:
		move.w    (a2)+,d0                  ; intin[0]: vdi_handle
		move.w    (a2)+,d1                  ; intin[1]: no_fonts
		move.w    (a2)+,d2                  ; intin[2]: font_flags
		move.w    (a2)+,-(a7)               ; intin[3]: dialog_flags
		movea.l   (a3)+,a0                  ; addrin[0]: sample
		movea.l   (a3)+,a1                  ; addrin[1]: opt_button
		bsr       fnts_create
		addq.l    #2,a7
		move.l    a0,(a5)                   ; addrout[0]:
		rts

dsp_fnts_delete:
		move.w    (a2)+,d0                  ; intin[0]: vdi_handle
		movea.l   (a3)+,a0                  ; addrin[0]: fnt_dialog
		bsr       fnts_delete
		move.w    d0,(a4)                   ; intout[0]:
		rts

dsp_fnts_open:
		lea.l     18(a2),a2                 ; 9 * 2, Zeiger auf intin[9]
		move.l    -(a2),-(a7)               ; intin[7/8]: ratio
		move.l    -(a2),-(a7)               ; intin[5/6]: pt
		move.l    -(a2),-(a7)               ; intin[3/4]: id
		move.w    -(a2),d2                  ; intin[2]: y
		move.w    -(a2),d1                  ; intin[1]: x
		move.w    -(a2),d0                  ; intin[0]: button_flags
		movea.l   (a3)+,a0                  ; addrin[0]: fnt_dialog
		bsr       fnts_open
		lea.l     12(a7),a7
		move.w    d0,(a4)                   ; intout[0]:
		rts

dsp_fnts_close:
		movea.l   (a3)+,a0                  ; addrin[0]: fnt_dialog
		lea.l     2(a4),a1                  ; intout[1] = x
		lea.l     4(a4),a2                  ; intout[2] = y
		move.l    a2,-(a7)
		bsr       fnts_close
		addq.l    #4,a7
		move.w    d0,(a4)                   ; intout[0]:
		rts

dsp_fnts_get:
		move.w    (a2)+,d0                  ; intin[0]: function number
		cmp.w     #3,d0
		bhi.s     afnts_get_exit
		lsl.w     #3,d0
		lea.l     afnts_get_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0)               ; nintout
		move.w    (a1)+,8(a0)               ; naddrout
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
afnts_get_exit:
		rts
afnts_get_tab:
		dc.w 1,0
		dc.l	dsp_fnts_get_no_styles
		dc.w 2,0
		dc.l	dsp_fnts_get_style
		dc.w 1,0
		dc.l	dsp_fnts_get_name
		dc.w 3,0
		dc.l	dsp_fnts_get_info
		
dsp_fnts_get_no_styles:
		move.l    (a2)+,d0                 ; intin[1/2]: id
		movea.l   (a3)+,a0                 ; addrin[0]: fnt_dialog
		bsr       fnts_get_no_styles
		move.w    d0,(a4)
		rts
dsp_fnts_get_style:
		move.l    (a2)+,d0                 ; intin[1/2]: id
		move.w    (a2)+,d1                 ; intin[3]: index
		movea.l   (a3)+,a0                 ; addrin[0]: fnt_dialog
		bsr       fnts_get_style
		move.l    d0,(a4)                  ; intout[0/1]: font id
		rts
dsp_fnts_get_name:
		move.l    (a2)+,d0                 ; intin[1/2]: id
		movea.l   (a3)+,a0                 ; addrin[0]: fnt_dialog
		movea.l   (a3)+,a1                 ; addrin[1]: full_name
		move.l    4(a3),-(a7)              ; addrin[3]: style_name
		move.l    (a3),-(a7)               ; addrin[2]: family_name
		bsr       fnts_get_name
		addq.l    #8,a7
		move.w    d0,(a4)
		rts
dsp_fnts_get_info:
		move.l    (a2)+,d0                 ; intin[1/2]: id
		movea.l   (a3)+,a0                 ; addrin[0]: fnt_dialog
		lea.l     2(a4),a1                 ; &intout[1]: mono
		lea.l     4(a4),a2                 ; &intout[2]: outline
		move.l    a2,-(a7)
		bsr       fnts_get_info
		addq.l    #4,a7
		move.w    d0,(a4)
		rts

dsp_fnts_set:
		move.w    (a2)+,d0
		cmp.w     #2,d0
		bhi.s     afnts_set_exit
		lsl.w     #3,d0
		lea.l     afnts_set_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0)             ; nintout
		move.w    (a1)+,8(a0)             ; naddrout
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
afnts_set_exit:
		rts
afnts_set_tab:
		dc.w	1,0
		dc.l	dsp_fnts_add
		dc.w	0,0
		dc.l	dsp_fnts_remove
		dc.w	1,0
		dc.l	dsp_fnts_update
dsp_fnts_add:
		movea.l   (a3)+,a0                ; addrin[0]: fnt_dialog
		movea.l   (a3)+,a1                ; addrin[1]: user_fonts
		bsr       fnts_add
		move.w    d0,(a4)
		rts
dsp_fnts_remove:
		movea.l   (a3)+,a0                ; addrin[0]: fnt_dialog
		bsr       fnts_remove
		rts
dsp_fnts_update:
		move.w    (a2)+,d0                ; intin[1]: button_flags
		move.l    (a2)+,d1                ; intin[2/3]: id
		move.l    (a2)+,d2                ; intin[4/5]: pt
		move.l    (a2),-(a7)              ; intin[6/7]: ratio
		movea.l   (a3)+,a0                ; addrin[0]: fnt_dialog
		bsr       fnts_update
		addq.l    #4,a7
		move.w    d0,(a4)
		rts


dsp_fnts_evnt:
		lea.l     14(a4),a2               ; &intout[7/8]: ratio
		move.l    a2,-(a7)
		subq.l    #4,a2                   ; &intout[5/6]: pt
		move.l    a2,-(a7)
		subq.l    #4,a2                   ; &intout[3/4]: id
		move.l    a2,-(a7)
		subq.l    #2,a2                   ; &intout[2]: check_boxes
		move.l    a2,-(a7)
		subq.l    #2,a2                   ; &intout[1]: button
		move.l    a2,-(a7)
		movea.l   (a3)+,a0                ; addrin[0]: fnt_dialog
		movea.l   (a3)+,a1                ; addrin[1]: events
		bsr       fnts_evnt
		lea.l     20(a7),a7
		move.w    d0,(a4)
		rts

dsp_fnts_do:
		movea.l   (a3)+,a0                ; addrin[0]: fnt_dialog
		lea.l     12(a4),a3               ; &intout[6/7]      (ratio)
		move.l    a3,-(a7)
		subq.l    #4,a3                   ; &intout[4/5]      (pt)
		move.l    a3,-(a7)
		subq.l    #4,a3                   ; &intout[2/3]      (id)
		move.l    a3,-(a7)
		subq.l    #2,a3                   ; &intout[1]        (check_boxes)
		movea.l   a3,a1
		move.w    (a2)+,d0                ; intin[0]: button_flags
		move.l    (a2)+,d1                ; intin[1/2]: id_in
		move.l    (a2)+,d2                ; intin[3/4]: pt_in
		move.l    (a2)+,-(a7)             ; intin[5/6]: ratio_in
		bsr       fnts_do
		lea.l     16(a7),a7
		move.w    d0,(a4)                 ; intout[0]: button
		rts

dsp_pdlg_create:
		move.w    (a2)+,d0                ; intin[0]: dialog_flags
		bsr       pdlg_create
		move.l    a0,(a5)                 ; addrout[0]: prn_dialog
		rts

dsp_pdlg_delete:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		bsr       pdlg_delete
		move.w    d0,(a4)
		rts

dsp_pdlg_open:
		move.w    (a2)+,d0                ; intin[0]: option_flags
		move.w    (a2)+,d1                ; intin[1]: x
		move.w    (a2)+,d2                ; intin[2]: y
		movea.l   4(a0),a0
		move.w    4(a0),-(a7)             ; aes_global[2]: ap_id
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: settings
		move.l    (a3)+,-(a7)             ; addrin[2]: document_name
		bsr       pdlg_xopen
		addq.l    #6,a7
		move.w    d0,(a4)
		rts

dsp_pdlg_close:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		lea.l     2(a4),a1                ; &intout[1]: x
		lea.l     4(a4),a2                ; &intout[2]: y
		move.l    a2,-(a7)
		bsr       pdlg_close
		addq.l    #4,a7
		move.w    d0,(a4)
		rts

dsp_pdlg_get:
		move.w    (a2)+,d0
		bne.s     apdlg_get_exit
		bsr       pdlg_get_setsize
		move.l    d0,(a4)
apdlg_get_exit:
		rts

dsp_pdlg_set:
		move.w    (a2)+,d0
		cmp.w     #10,d0
		bhi.s     apdlg_set_exit
		lsl.w     #3,d0
		lea.l     apdlg_set_tab(pc,d0.w),a1
		movea.l   (a0),a0
		move.w    (a1)+,4(a0)  ; nintout
		move.w    (a1)+,8(a0)  ; naddrout
		movea.l   (a1)+,a1
		movea.l   d1,a0
		jsr       (a1)
apdlg_set_exit:
		rts
apdlg_set_tab:
		dc.w	1,0
		dc.l	apdlg_add_printers
		dc.w	1,0
		dc.l	apdlg_remove_printers
		dc.w	0,0
		dc.l	apdlg_update
		dc.w	1,0
		dc.l	apdlg_add_sub_dialogs
		dc.w	1,0
		dc.l	apdlg_remove_sub_dialogs
		dc.w	0,1
		dc.l	apdlg_new_settings
		dc.w	1,0
		dc.l	apdlg_free_settings
		dc.w	1,0
		dc.l	apdlg_dflt_settings
		dc.w	1,0
		dc.l	apdlg_validate_settings
		dc.w	1,0
		dc.l	apdlg_use_settings
		dc.w	1,0
		dc.l	apdlg_save_default_settings

apdlg_add_printers:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: drv_info
		bsr       pdlg_add_printers
		move.w    d0,(a4)
		rts
apdlg_remove_printers:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		bsr       pdlg_remove_printers
		move.w    d0,(a4)
		rts
apdlg_update:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		addq.l    #4,a3                   ; addrin[1]: reserved
		movea.l   (a3)+,a1                ; addrin[2]: document_name
		bsr       pdlg_update
		move.w    d0,(a4)
		rts
apdlg_add_sub_dialogs:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: sub_dialog
		bsr       pdlg_add_sub_dialogs
		move.w    d0,(a4)
		rts
apdlg_remove_sub_dialogs:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		bsr       pdlg_remove_sub_dialogs
		move.w    d0,(a4)
		rts
apdlg_new_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		bsr       pdlg_new_settings
		move.l    a0,(a5)
		rts
apdlg_free_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_settings
		bsr       pdlg_free_settings
		move.w    d0,(a4)
		rts
apdlg_dflt_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		bsr       pdlg_dflt_settings
		move.w    d0,(a4)
		rts
apdlg_validate_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		bsr       pdlg_validate_settings
		move.w    d0,(a4)
		rts
apdlg_use_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		bsr       pdlg_use_settings
		move.w    d0,(a4)
		rts
apdlg_save_default_settings:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		bsr       pdlg_save_default_settings
		move.w    d0,(a4)
		rts


dsp_pdlg_evnt:
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		lea.l     2(a4),a2                ; &intout[1]: button
		move.l    a2,-(a7)
		move.l    (a3)+,-(a7)             ; addrin[2]: events
		bsr       pdlg_evnt
		addq.l    #8,a7
		move.w    d0,(a4)
		rts

dsp_pdlg_do:
		move.w    (a2)+,d0                ; intin[0]: option_flags
		movea.l   (a3)+,a0                ; addrin[0]: prn_dialog
		movea.l   (a3)+,a1                ; addrin[1]: prn_settings
		move.l    (a3)+,-(a7)             ; addrin[2]: document_name
		bsr       pdlg_do
		addq.l    #4,a7
		move.w    d0,(a4)
		rts

		.data

aes_found_msg:
	dc.b 'AES bereits vorhanden.',13,10,0
inst_ok_msg:
	dc.b 'WDIALOG 2.04 wurde installiert.',13,10,0
crlf:
	dc.b 13,10,0
not_inst_msg:
	dc.b 'MagiC 6.0 oder neuer ist vorhanden.',13,10
	dc.b 'WDIALOG wird nicht installiert.',13,10,13,10,0
	EVEN
