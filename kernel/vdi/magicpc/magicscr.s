		.text

entry:
		jmp        start

start:
		movea.l    4(a7),a0
		move.l     #256,d0
		add.l      12(a0),d0
		add.l      20(a0),d0
		add.l      28(a0),d0
		move.l     a0,_base
		move.l     d0,_PgmSize
		move.l     d0,-(a7)
		move.l     a0,-(a7)
		clr.w      -(a7)
		move.w     #74,-(a7) ; Mshrink
		trap       #1
		adda.w     #12,a7
		move.w     #-1,-(a7)
		move.w     #11,-(a7) ; Kbshift
		trap       #13
		addq.l     #4,a7
		andi.w     #3,d0
		bne        cancelled
		moveq.l    #1,d0
		move.w     bytes_line,d1
		move.w     screen_width,d2
		move.w     screen_height,d3
		move.w     screen_planes,d4
		dc.w       0x43bf,0x0020 ; mec1       0x0020
		tst.w      d0
		ble        cancelled
		move.w     d1,bytes_line
		move.w     d2,screen_width
		move.w     d3,screen_height
		move.w     d4,screen_planes
		cmpi.w     #8,d4
		beq.s      main3
		cmpi.w     #4,d4
		beq.s      main2
		cmpi.w     #2,d4
		beq.s      main1
		move.w     #2,numcolors
		move.w     #2,my_rez
		bra.s      main4
main1:
		move.w     #4,numcolors
		move.w     #1,my_rez
		bra.s      main4
main2:
		move.w     #16,numcolors
		move.w     #0,my_rez
		bra.s      main4
main3:
		move.w     #256,numcolors
		move.w     #7,my_rez
main4:
		move.w     #278,d0
		move.w     d0,d1
		cmpi.w     #400,screen_width
		bge.s      main5
		add.w      d0,d0
main5:
		cmpi.w     #300,screen_height
		bge.s      main6
		add.w      d1,d1
main6:
		move.w     d0,pixel_width
		move.w     d1,pixel_height
		bsr        alloc_screen
		tst.l      d0
		ble.s      cancelled
		pea.l      install_vecs
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		move.w     #0,-(a7)
		move.l     _PgmSize,-(a7)
		move.w     #49,-(a7) ; Ptermres
		trap       #1
		rts

cancelled:
		clr.w      magicscr_active
		movea.l    #cancel_msg,a0
		dc.w       0x43bf,0x0010 ; mec1       0x0010
		clr.w      -(a7)
		trap       #1

install_vecs:
		move.w     #1,magicscr_active
		move.l     (0x000000B8).w,old_xbios
		move.l     #new_xbios,(0x000000B8).w
		move.l     (0x00000088).w,old_vdi
		move.l     #new_vdi,(0x00000088).w
		movea.l    #install_msg,a0
		dc.w       0x43bf,0x0010 ; mec1       0x0010
		rts

cancel_msg:
	dc.b '+++ BS_Extender: Abgebrochen! +++',0

install_msg:
	dc.b '+++ BS_Extender: Installiert! +++',0

dw_addline:
		move.l     a0,-(a7)
		movea.l    8(a7),a0
		dc.w       0x43bf,0x0010 ; mec1       0x0010
		movea.l    (a7)+,a0
		move.l     (a7),4(a7)
		addq.l     #4,a7
		rts

new_xbios:
		tst.w      magicscr_active
		beq.s      new_xbios2
		move.l     usp,a0
		btst       #5,(a7) ; from SuperVisor?
		beq.s      new_xbios1
		lea.l      6(a7),a0
new_xbios1:
		cmpi.w     #4,(a0) ; Getrez?
		beq.s      new_xbios3
new_xbios2:
		move.l     old_xbios,-(a7)
		rts
new_xbios3:
		moveq.l    #0,d0
		move.w     my_rez,d0
		rte

new_vdi:
		cmpi.w     #0x0073,d0 ; VDI call?
		bne.s      new_vdi2  ; -> no, ignore
		move.l     a0,-(a7)
		movea.l    d1,a0
		movea.l    (a0),a0    ; get control
		cmpi.w     #2,(a0)    
		bls.s      new_vdi3
new_vdi1:
		movea.l    (a7)+,a0
new_vdi2:
		move.l     old_vdi,-(a7)
		rts

new_vdi3:
		tst.w      (a0)       ; opcode 0?
		beq.s      new_vdi1   ; -> yes ignore
		cmpi.w     #2,(a0)    ; v_clswk?
		beq.s      do_clswk
		clr.w      magicscr_active
		movea.l    d1,a0
		movea.l    4(a0),a0   ; get intin
		cmpi.w     #1,(a0)    ; current rez?
		beq.s      new_vdi4
		cmpi.w     #2,(a0)
		blt.s      new_vdi1
		cmpi.w     #4,(a0)
		bgt.s      new_vdi1
new_vdi4:
		pea.l      vdi_open_msg(pc)
		bsr        dw_addline
		move.w     my_rez,(a0)
		addq.w     #2,(a0)
		move.l     d1,vdipb
		move.l     6(a7),vdi_ret
		move.l     #vdi_cont,6(a7)
		bra.s      new_vdi1

vdi_open_msg:
	dc.b 'VDI_OPEN!',0
	.even

do_clswk:
		clr.w      magicscr_active
		bra.s      new_vdi1

vdi_cont:
		movem.l    d0-d7/a0-a6,-(a7)
		pea.l      vdi_cont_msg
		bsr        dw_addline
		move.w     #-1,-(a7)
		move.l     screenptr,-(a7)
		move.l     screenptr,-(a7)
		move.w     #5,-(a7) ; Setscreen
		trap       #14
		adda.w     #12,a7
		bsr.w      lineainit
		bsr        postvdi
		bsr        setrez
		moveq.l    #0,d1
		moveq.l    #0,d2
		moveq.l    #0,d3
		moveq.l    #0,d4
		move.w     bytes_line,d1
		move.w     screen_width,d2
		move.w     screen_height,d3
		move.w     screen_planes,d4
		dc.w       0x43bf,0x0021 ; mec1       0x0021
		bsr        set_font_height
		move.w     #1,magicscr_active
		movem.l    (a7)+,d0-d7/a0-a6
		pea.l      vdi_done_msg
		bsr        dw_addline
		move.l     vdi_ret,-(a7)
		rts

vdi_cont_msg:
	dc.b '+++ VDI-Continue ',0
vdi_done_msg:
	dc.b '+++ VDI-Continue: fertig',0
	.even

lineainit:
		dc.w       0xa000
		move.l     a0,lineaptr
		move.l     a1,fontptr
		lea.l      -692(a0),a1 ; dev_tab
		bsr        init_devtab
		move.w     screen_width,-12(a0) ; v_rez_hz
		move.w     screen_height,-4(a0) ; v_rez_vt
		move.w     bytes_line,-2(a0)    ; bytes_lin
		move.w     bytes_line,2(a0)     ; v_lin_wr
		move.w     screen_planes,(a0)   ; v_planes
		move.l     screenptr,-34(a0)    ; v_cur_ad
		move.w     (0).w,-28(a0) ; v_cur_xy[0] ; BUG
		move.w     (0).w,-26(a0) ; v_cur_xy[1]
		movea.l    fontptr,a1
		addq.l     #4,a1
		cmpi.w     #320,screen_height
		blt.s      lineainit1
		addq.l     #4,a1
lineainit1:
		movea.l    (a1),a1
		move.l     a1,-460(a0)           ; def_font
		move.l     76(a1),-22(a0)        ; v_fnt_ad
		move.w     82(a1),-46(a0)        ; v_cel_ht
		move.w     screen_width,d0
		asr.w      #3,d0
		subq.w     #1,d0
		move.w     d0,-44(a0)            ; v_cel_mx
		moveq.l    #0,d0
		move.w     screen_height,d0
		divu.w     -46(a0),d0
		subq.w     #1,d0
		move.w     d0,-42(a0)            ; v_cel_my
		move.w     bytes_line,d0
		mulu.w     -46(a0),d0
		move.w     d0,-40(a0)            ; v_cel_wr
		rts

postvdi:
		movea.l    vdipb,a5
		movea.l    12(a5),a1 ; get intout
		bsr.w      init_devtab
		rts

init_devtab:
		move.w     screen_width,d0
		subq.w     #1,d0
		move.w     d0,(a1)           ; dev_tab[0] = screen_width - 1
		move.w     screen_height,d0
		subq.w     #1,d0
		move.w     d0,2(a1)          ; dev_tab[1] = screen_height - 1
		move.w     pixel_width,6(a1)  ; dev_tab[3] = pixel_width
		move.w     pixel_height,8(a1) ; dev_tab[4] = pixel_height
		move.w     numcolors,26(a1)  ; dev_tab[13] = numcolors
		rts

set_font_height:
		movea.l    vdipb,a5
		movea.l    (a5),a0
		movea.l    #control,a1
		move.w     #12,(a1)      ; opcode = vst_height
		move.w     #1,2(a1)
		move.w     #0,4(a1)
		move.w     12(a0),12(a1) ; copy handle
		movea.l    #ptsin,a1
		clr.w      (a1)+
		move.w     #6,(a1)
		cmpi.w     #320,screen_height
		ble.s      set_font_height1
		move.w     #13,(a1)
set_font_height1:
		moveq.l    #115,d0
		move.l     #myvdipb,d1
		trap       #2
		rts

myvdipb:
		dc.l control
		dc.l intin
		dc.l ptsin
		dc.l intout
		dc.l ptsout
control: ds.w 12
intin:   ds.w 4
ptsin:   ds.w 4
ptsout:  ds.w 32
intout:  ds.w 32


setrez:
		move.w     sr,-(a7)
		movea.w    #0x8200,a0
		moveq.l    #0,d0
		cmpi.w     #2,my_rez
		beq.s      setrez1
		moveq.l    #1,d0
setrez1:
		ori.w      #0x0700,sr
		dc.w       0x43bf,0x0022 ; mec1       0x0022
		move.w     my_rez,d0
		move.b     d0,0x00FF8260
		move.b     d0,(0x0000044C).w
		move.l     screenptr,d0
		move.l     d0,(0x0000044E).w
		lsr.l      #8,d0
		move.b     d0,3(a0)
		lsr.l      #8,d0
		move.b     d0,1(a0)
		clr.b      12(a0)
		move.w     (a7)+,sr
		rts

free_screen:
		move.l     screenbuf,d0
		beq.s      free_screen1
		clr.l      screenbuf
		move.l     d0,-(a7)
		move.w     #73,-(a7) ; Mfree
		trap       #1
		addq.l     #6,a7
free_screen1:
		clr.l      screenptr
		rts

alloc_screen:
		bsr.w      free_screen
		move.w     bytes_line,d0
		mulu.w     screen_height,d0
		addi.l     #0x00010100,d0
		move.l     d0,screen_size
		move.l     d0,-(a7)
		move.w     #72,-(a7) ; Malloc
		trap       #1
		addq.l     #6,a7
		tst.l      d0
		ble.s      alloc_screen1
		move.l     d0,screenbuf
		addi.l     #0x00008100,d0
		andi.l     #0xFFFFFF00,d0
		move.l     d0,screenptr
		movem.l    d0-d7/a0,-(a7)
		lea.l      scr_alloc_msg,a0
		move.l     screenbuf,d0
		move.l     screenptr,d1
		move.l     screen_size,d2
		move.l     screen_size,d3
		dc.w       0x43bf,0x0012 ; mec1       0x0012
		lea.l      scr_dim_msg,a0
		move.w     screen_width,d0
		ext.l      d0
		move.w     screen_height,d1
		ext.l      d1
		move.w     bytes_line,d2
		ext.l      d2
		move.w     screen_planes,d3
		ext.l      d3
		dc.w       0x43bf,0x0012 ; mec1       0x0012
		movem.l    (a7)+,d0-d7/a0
alloc_screen1:
		rts

	.data

old_vdi:       dc.l 0
old_xbios:     dc.l 0
lineaptr:      dc.l 0
fontptr:       dc.l 0
magicscr_active:     dc.w 0
screen_width:  dc.w 640
screen_height: dc.w 480
bytes_line:    dc.w 80
screen_planes: dc.w 1
numcolors:     dc.w 1
my_rez:        dc.w 1
screenptr:     dc.l 0
pixel_width:   dc.w 0
pixel_height:  dc.w 0
_base:                               dc.l 0
_PgmSize:                            dc.l 0
vdi_ret:                             dc.l 0
vdipb:                               dc.l 0
screenbuf:                           dc.l 0
screen_size:                         dc.l 0
scr_alloc_msg:                       dc.b 13,10,'scr_allo: %lx, %lx, %lx, %l',0
scr_dim_msg:                         dc.b 13,10,'br= %i, ho= %i, kl= %i, npl= %i',0
                                     dc.b 'VDI-Dispatcher eingeh',$84,'ngt!',0
                                     dc.b '\vdi: %i',0

