.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"
.INCLUDE "..\include\vdi.inc"

.INCLUDE "nova.inc"
.INCLUDE "vgainf.inc"

			.text

entry:
		bra.s      main

		dc.b 'REDIRECT'
		dc.w 320
		dc.l main-entry
		dc.l 0
		dc.l 0
		dc.l 'XVGA'
		dc.l vgamode

main:
/* required startup code */
		movea.l    4(a7),a0
		move.l     12(a0),d0
		add.l      20(a0),d0
		add.l      28(a0),d0
		addi.l     #256,d0
		move.l     d0,_PgmSize
		lea.l      stackend(pc),a7
		move.l     d0,-(a7)
		move.l     a0,-(a7)
		clr.w      -(a7)
		move.w     #74,-(a7) ; Mshrink
		trap       #1
		lea.l      12(a7),a7

/* abort if shift-shift pressed */
		move.w     #-1,-(a7)
		move.w     #11,-(a7) ; Kbshift
		trap       #13
		addq.l     #4,a7
		subq.w     #3,d0
		beq.s      exit

		bsr        find_vgamode
		tst.l      d0
		beq.s      novgainf
		subq.l     #1,d0
		beq.s      nomonores
		dc.w       0xa000
		move.l     a0,lineavars
		move.l     a1,fontring
		pea.l      install(pc)
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		moveq.l    #46,d0 ; TRAP #14
		lea.l      myxbios(pc),a0
		lea.l      myxbios-4(pc),a1
		bsr        setvec
		move.w     #1,active_flag
		bsr        clear_framebuffer
		bsr        copy_screen
		bsr        delay
		clr.w      -(a7)
		move.l     _PgmSize(pc),-(a7)
		move.w     #49,-(a7) ; Ptermres
		trap       #1

novgainf:
		pea.l      novgainf_msg(pc)
		move.w     #9,-(a7) ; Cconws
		trap       #1
		addq.l     #6,a7
		bra.s      exit

nomonores:
		pea.l      nomonores_msg(pc)
		move.w     #9,-(a7) ; Cconws
		trap       #1
		addq.l     #6,a7

exit:
		clr.w      -(a7)
		trap       #1

novgainf_msg:
		dc.b 'Kann NVDIVGA.INF nicht finden!',13,10,0
nomonores_msg:
		dc.b 'Keine monochrome 640*400-Aufl',0x94,'sung vorhanden!',13,10,0
		.even

install:
		movem.l    d0-d7/a0-a6,-(a7)
		bsr        save_lineavars
		bsr        initmode
		bsr        install_cookie
		bsr        set_lineavars
		move.w     #6,frame_offset
		tst.w      longframe.w
		beq.s      install1
		move.w     #8,frame_offset
install1:
		movem.l    (a7)+,d0-d7/a0-a6
		rts

setvec:
		movem.l    d0-d1/a0,-(a7)
		moveq.l    #-1,d1
		cmpa.l     d1,a1
		beq.s      setvec1
		movea.l    d1,a0
		bsr.s      Setexc
		move.l     d0,(a1)
		movem.l    (a7),d0-d1/a0
setvec1:
		bsr.s      Setexc
		movem.l    (a7)+,d0-d1/a0
		rts

Setexc:
		movem.l    d1-d2/a1-a2,-(a7)
		move.l     a0,-(a7)
		move.w     d0,-(a7)
		move.w     #5,-(a7) ; Setexc
		trap       #13
		addq.l     #8,a7
		movea.l    d0,a0
		movem.l    (a7)+,d1-d2/a1-a2
		rts

gooldxbios:
		movea.l    myxbios-4(pc),a0
		jmp        (a0)

	dc.l 'XBRA'
	dc.l 'RDCT'
	dc.l 0
myxbios:
		move.l     usp,a0
		btst       #5,(a7)
		beq.s      xbios_user
		movea.l    a7,a0
		adda.w     frame_offset(pc),a0
xbios_user:
		move.w     active_flag(pc),d0
		beq.s      gooldxbios
		move.w     (a0),d0
		subq.w     #2,d0
		beq.s      physbase
		subq.w     #1,d0
		beq.s      physbase
		subq.w     #1,d0
		beq.s      getrez
		subq.w     #1,d0
		bne.s      gooldxbios
		/* deliberately ignore Setscreen */
		rte
getrez:
		moveq.l    #2,d0
		rte
physbase:
		move.l     vgamode+vga_membase(pc),d0
		rte

find_vgamode:
		movem.l    d1-d2/a0-a2,-(a7)
		bsr        load_vga_inf
		move.l     a0,d0
		beq        find_vgamode8   ; error: file not found
		move.w     vgainf_cardtype(a0),cardtype
		move.w     vgainf_cardsubtype(a0),cardsubtype
		lea.l      vgainf_modes(a0),a1
		moveq.l    #-1,d1
find_vgamode1:
		move.l     vga_next(a1),d0
		cmp.l      d1,d0
		beq.s      find_vgamode2
		add.l      a1,d0
		move.l     d0,vga_next(a1)
		movea.l    d0,a1
		bra.s      find_vgamode1
find_vgamode2:
		lea.l      vgainf_modes(a0),a1
		moveq.l    #0,d0
find_vgamode3:
		cmpi.w     #640-1,vga_visible_xres(a1)
		bne.s      find_vgamode4
		cmpi.w     #400-1,vga_visible_yres(a1)
		bne.s      find_vgamode4
		cmpi.w     #1,vga_planes(a1)
		beq.s      find_vgamode5
		addq.w     #1,d0
find_vgamode4:
		movea.l    vga_next(a1),a1
		cmp.l      a1,d1
		beq.s      find_vgamode9
		bra.s      find_vgamode3
find_vgamode5:
		move.w     vgainf_length(a1),d0
		cmp.w      #VGA_MODESIZE,d0
		bgt.s      find_vgamode7
		subq.w     #1,d0
		lea.l      vgamode(pc),a2
find_vgamode6:
		move.b     (a1)+,(a2)+
		dbf        d0,find_vgamode6
		move.l     #vgamode,d0
		add.l      d0,vgamode+vga_modename
		add.l      d0,vgamode+vga_ts_regs
		add.l      d0,vgamode+vga_crtc_regs
		add.l      d0,vgamode+vga_atc_regs
		add.l      d0,vgamode+vga_gdc_regs
find_vgamode7:
		move.l     a0,d0
		bsr        Mfree
		moveq.l    #-1,d0 ; success
find_vgamode8:
		movem.l    (a7)+,d1-d2/a0-a2
		rts
find_vgamode9:
		move.l     a0,d0
		bsr        Mfree
		moveq.l    #1,d0            ; error: mode not found
		movem.l    (a7)+,d1-d2/a0-a2
		rts

load_vga_inf:
		movem.l    d0-d2/a1-a2,-(a7)
		move.w     #25,-(a7) ; Dgetdrv
		trap       #1
		addq.l     #2,a7
		lea.l      nvdivga_path(pc),a0
		movea.l    a0,a1
		addi.b     #'A',d0 ; FIXME: drive_to_letter
		move.b     d0,(a0)+
		move.b     #':',(a0)+
		move.l     #'\AUT',(a0)+
		move.l     #'O\NV',(a0)+
		move.l     #'DIVG',(a0)+
		move.l     #'A.IN',(a0)+
		move.b     #'F',(a0)+
		clr.b      (a0)+
		bsr.s      Fgetdta
		movea.l    a0,a2
		lea.l      dta(pc),a0
		bsr.s      Fsetdta
		moveq.l    #0,d0
		movea.l    a1,a0
		bsr.s      Fsfirst
		movea.l    a2,a0
		bsr.s      Fsetdta
		tst.w      d0
		bne.s      load_vga_inf2
		move.l     dta+26(pc),d0
		bsr        Malloc
		tst.l      d0
		beq.s      load_vga_inf2
		movea.l    d0,a2
		moveq.l    #0,d0
		movea.l    a1,a0
		bsr.s      Fopen
		move.w     d0,d2
		bmi.s      load_vga_inf1
		move.l     dta+26(pc),d1
		movea.l    a2,a0
		bsr.s      Fread
		move.w     d2,d0
		bsr        Fclose
		movem.l    (a7)+,d0-d2/a1-a2
		rts
load_vga_inf1:
		movea.l    a2,a0
		bsr        Mfree
load_vga_inf2:
		suba.l     a0,a0
		movem.l    (a7)+,d0-d2/a1-a2
		rts

Fsetdta:
		movem.l    d0-d2/a0-a2,-(a7)
		move.l     a0,-(a7)
		move.w     #26,-(a7) ; Fsetdta
		trap       #1
		addq.l     #6,a7
		movem.l    (a7)+,d0-d2/a0-a2
		rts

Fgetdta:
		movem.l    d0-d2/a1-a2,-(a7)
		move.w     #47,-(a7) ; Fgetdta
		trap       #1
		addq.l     #2,a7
		movea.l    d0,a0
		movem.l    (a7)+,d0-d2/a1-a2
		rts

Fsfirst:
		movem.l    d1-d2/a0-a2,-(a7)
		move.w     d0,-(a7)
		move.l     a0,-(a7)
		move.w     #78,-(a7) ; Fsfirst
		trap       #1
		addq.l     #8,a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

Fopen:
		movem.l    d1-d2/a0-a2,-(a7)
		move.w     d0,-(a7)
		move.l     a0,-(a7)
		move.w     #61,-(a7) ; Fopen
		trap       #1
		addq.l     #8,a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

Fread:
		movem.l    d1-d2/a0-a2,-(a7)
		move.l     a0,-(a7)
		move.l     d1,-(a7)
		move.w     d0,-(a7)
		move.w     #63,-(a7) ; Fread
		trap       #1
		lea.l      12(a7),a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

Fclose:
		movem.l    d0-d2/a0-a2,-(a7)
		move.w     d0,-(a7)
		move.w     #62,-(a7) ; Fclose
		trap       #1
		addq.l     #4,a7
		movem.l    (a7)+,d0-d2/a0-a2
		rts

Malloc:
		movem.l    d1-d2/a0-a2,-(a7)
		move.l     d0,-(a7)
		move.w     #72,-(a7) ; Malloc
		trap       #1
		addq.l     #6,a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

Mfree:
		movem.l    d1-d2/a0-a2,-(a7)
		move.l     d0,-(a7)
		move.w     #73,-(a7) ; Mfree
		trap       #1
		addq.l     #6,a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

save_lineavars:
		move.l     a0,-(a7)
		movea.l    lineavars(pc),a0
		move.l     v_bas_ad.w,screen_ptr
		move.w     PLANES-LINE_A_BASE(a0),planes
		move.w     BYTES_LIN-LINE_A_BASE(a0),bytes_lin
		move.w     V_REZ_HZ-LINE_A_BASE(a0),res_x
		move.w     V_REZ_VT-LINE_A_BASE(a0),res_y
		move.w     V_CEL_WR-LINE_A_BASE(a0),v_cel_wr
		movea.l    (a7)+,a0
		rts

set_lineavars:
		movem.l    d0-d4/a0-a2,-(a7)
		movea.l    lineavars(pc),a0
		movem.w    vgamode+vga_visible_xres(pc),d0-d1
		move.w     vgamode+vga_line_width(pc),d2
		move.l     vgamode+vga_membase(pc),v_bas_ad.w
		move.w     #1,PLANES-LINE_A_BASE(a0)
		move.w     d2,WIDTH-LINE_A_BASE(a0)
		move.w     d2,BYTES_LIN-LINE_A_BASE(a0)
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     d0,V_REZ_HZ-LINE_A_BASE(a0)
		move.w     d1,V_REZ_VT-LINE_A_BASE(a0)
		movea.l    fontring(pc),a1
		movea.l    8(a1),a1
		move.l     dat_table(a1),V_FNT_AD-LINE_A_BASE(a0)
		move.l     off_table(a1),V_OFF_AD-LINE_A_BASE(a0)
		move.w     #256,V_FNT_WD-LINE_A_BASE(a0)
		move.l     #0x00FF0000,V_FNT_ND-LINE_A_BASE(a0)
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT-LINE_A_BASE(a0)
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		movem.w    d0-d2,V_CEL_MX-LINE_A_BASE(a0) /* V_CEL_MX/V_CEL_MY/V_CEL_WR */
		move.l     #255,V_COL_BG-LINE_A_BASE(a0)
		move.w     #1,V_HID_CNT-LINE_A_BASE(a0)
		move.w     #0x0100,V_STAT_0-LINE_A_BASE(a0)
		move.w     #0x1E1E,V_PERIOD-LINE_A_BASE(a0)
		move.w     V_CUR_XY1-LINE_A_BASE(a0),d1
		cmp.w      #24,d1
		bls.s      set_lineavars1
		move.w     #24,d1
set_lineavars1:
		move.w     V_CUR_XY0-LINE_A_BASE(a0),d0
		cmp.w      #79,d0
		bls.s      set_lineavars2
		move.w     #79,d0
set_lineavars2:
		movem.w    d0-d1,V_CUR_XY-LINE_A_BASE(a0)
		mulu.w     V_CEL_WR-LINE_A_BASE(a0),d1
		movea.l    v_bas_ad.w,a1
		adda.l     d1,a1
		adda.w     d0,a1
		move.l     a1,V_CUR_AD-LINE_A_BASE(a0)
		clr.w      V_CUR_OF-LINE_A_BASE(a0)
		move.b     #2,sshiftmd.w
		movem.l    (a7)+,d0-d4/a0-a2
		rts

/*
 * clear VGA screen memory
 */
clear_framebuffer:
		movea.l    vgamode+vga_membase(pc),a1
		move.w     vgamode+vga_visible_yres(pc),d0
		addq.w     #1,d0
		mulu.w     vgamode+vga_line_width(pc),d0
		lsr.l      #2,d0
		subq.l     #1,d0
clear_framebuffer1:
		clr.l      (a1)+
		subq.l     #1,d0
		bpl.s      clear_framebuffer1
		rts

/*
 * copy current screen to VGA memory
 */
copy_screen:
		movea.l    screen_ptr(pc),a0
		movea.l    vgamode+vga_membase(pc),a1
		movea.w    bytes_lin(pc),a2
		movea.w    planes(pc),a5
		adda.w     a5,a5
		move.w     res_x(pc),d0
		lsr.w      #4,d0
		subq.w     #1,d0
		cmp.w      #39,d0
		bls.s      copy_screen1
		moveq.l    #39,d0
copy_screen1:
		move.w     res_y(pc),d1
		subq.w     #1,d1
copy_screen2:
		move.w     d0,d2
		movea.l    a0,a4
		movea.l    a1,a3
copy_screen3:
		move.w     (a4),(a3)+
		adda.w     a5,a4
		dbf        d2,copy_screen3
		adda.w     a2,a0
		lea.l      80(a1),a1
		dbf        d1,copy_screen2
		rts

delay:
		pea.l      get_starthz(pc)
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
delay1:
		pea.l      get_stophz(pc)
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		move.l     stophz(pc),d0
		sub.l      starthz(pc),d0
		cmpi.l     #300,d0
		blt.s      delay1
		rts

get_starthz:
		move.l     hz_200.w,starthz
		rts

get_stophz:
		move.l     hz_200.w,stophz
		rts

install_cookie:
		move.l     p_cookies.w,d0
		bne.s      gotjar
		move.l     resvalid.w,old_resvalid
		move.l     resvector.w,old_resvector
		move.l     #resvec,resvector.w
		move.l     #0x31415926,resvalid.w
		moveq.l    #8*8,d0
		bsr        Malloc
		move.l     d0,p_cookies.w
		beq.s      jarmemerr
		movea.l    d0,a0
		clr.l      (a0)+
		move.l     #8,(a0)
gotjar:
		movea.l    d0,a0
		movea.l    d0,a1
		moveq.l    #0,d0
sizejar:
		addq.l     #1,d0
		tst.l      (a1)
		addq.l     #8,a1
		bne.s      sizejar
		move.l     -(a1),d1
		subq.l     #4,a1
		cmp.l      d1,d0
		blt.s      nojarresize
		move.l     d1,d2
		subq.l     #1,d2
		bgt.s      install_cookie1
		moveq.l    #0,d1
		moveq.l    #0,d2
install_cookie1:
		addq.l     #8,d1
		move.l     d1,d0
		lsl.l      #3,d0
		bsr        Malloc
		move.l     d0,p_cookies.w
		beq.s      jarmemerr
		movea.l    d0,a1
		bra.s      copyjarnext
copyjar:
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
copyjarnext:
		dbf        d2,copyjar
nojarresize:
		move.l     #'RDCT',(a1)+
		move.l     #cookfunc,(a1)+
		clr.l      (a1)+
		move.l     d1,(a1)+
jarmemerr:
		rts

resvec:
		clr.l      p_cookies.w
		move.l     old_resvalid(pc),resvalid.w
		move.l     old_resvector(pc),resvector.w
		jmp        (a6)

cookfunc:
		movem.l    d0-d2/a0-a2,-(a7)
		lea.l      functab(pc),a0
		cmp.w      #1,d0
		bhi.s      cookfunc1
		lsl.w      #2,d0
		adda.w     d0,a0
cookfunc1:
		move.l     (a0),-(a7)
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		movem.l    (a7)+,d0-d2/a0-a2
		rts

functab:
		dc.l disable_redirect
		dc.l enable_redirect

disable_redirect:
		tst.w      active_flag
		beq.s      disable_redirect_exit
		clr.w      active_flag
		lea.l      screen_ptr(pc),a0
		movea.l    lineavars(pc),a1
		move.l     (a0)+,d0
		move.l     d0,v_bas_ad.w
		move.l     d0,V_CUR_AD-LINE_A_BASE(a1)
		move.w     (a0)+,PLANES-LINE_A_BASE(a1)   /* planes */
		move.w     (a0)+,d0                       /* bytes_lin */
		move.w     d0,WIDTH-LINE_A_BASE(a1)
		move.w     d0,BYTES_LIN-LINE_A_BASE(a1)
		move.w     (a0)+,V_REZ_HZ-LINE_A_BASE(a1) /* res_x */
		move.w     (a0)+,V_REZ_VT-LINE_A_BASE(a1) /* res_y */
		clr.l      V_CUR_XY-LINE_A_BASE(a1)
		move.w     v_cel_wr(pc),V_CEL_WR-LINE_A_BASE(a1)
disable_redirect_exit:
		rts

enable_redirect:
		bsr.s      initmode
		bsr        set_lineavars
		bsr        clear_framebuffer
		move.w     #1,active_flag
		rts

initmode:
		cmpi.w     #CARD_SPEKTRUM,cardtype
		bne.s      initmode_1
		bsr        initclock
initmode_1:
		tst.w      cardtype
		bne.s      initmode_2
		clr.w      0x00D02000
initmode_2:
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     vgamode+vga_MISC_W(pc),MISC_W(a0)    /* Select color mode & MCLK1 */
		move.b     #0x01,VIDSUB(a0)      /* Enable VGA mode */
		move.b     #0x17,CRTC_IM(a0)
		move.b     #0x00,CRTC_DM(a0)
		move.b     #0x17,CRTC_IG(a0)
		move.b     #0x00,CRTC_DG(a0)
		move.b     #0x11,CRTC_IM(a0)
		move.b     #0x00,CRTC_DM(a0)
		move.b     #0x11,CRTC_IG(a0)
		move.b     #0x00,CRTC_DG(a0)
		move.b     #0xFF,DAC_PEL(a0)
		move.b     #0x00,TS_I(a0)
		move.b     #0x00,TS_D(a0)
		move.b     #0x03,GENHP(a0)      /* enable upper 32k of graphics mode buffer */
		move.b     #0xA0,CGAMODE(a0)    /* enable ET4000 extensions */
		lea.l      TS_I(a0),a1
		lea.l      TS_D(a0),a2
		movea.l    vgamode+vga_ts_regs(pc),a3
		moveq.l    #0,d0
		move.w     (a3)+,d1
		subq.w     #1,d1
		addq.l     #1,a3
		subq.w     #1,d1
initmode_3:
		addq.w     #1,d0
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		dbf        d1,initmode_3
		move.b     #0x00,(a1)
		move.b     #0x03,(a2)
		cmpi.w     #CARD_SPEKTRUM,cardtype
		bne.s      initmode_4
		tst.w      cardsubtype
		beq.s      initmode_8
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0x02,DAC_PEL(a0)
initmode_4:
		cmpi.w     #CARD_CRAZYDOTS,cardtype
		bne.s      initmode_7
		cmpi.w     #2,cardsubtype
		bne.s      initmode_5
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0x00,DAC_PEL(a0)  /* HiColor off */
initmode_5:
		moveq.l    #31,d0
		and.w      vgamode+vga_synth(pc),d0
		lea.l      synth_tab(pc),a1
		move.b     0(a1,d0.w),d0
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      initmode_6
		bset       #7,d0
initmode_6:
		move.b     d0,(a0) ; BUG? should that be DAC_PEL(a0)?
initmode_7:
		cmpi.w     #CARD_VOFA,cardtype
		bne.s      initmode_8
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     vgamode+vga_PEL(pc),DAC_PEL(a0)
initmode_8:
		lea.l      CRTC_IG(a0),a1
		lea.l      CRTC_DG(a0),a2
		movea.l    vgamode+vga_crtc_regs(pc),a3
		moveq.l    #0,d0
		move.w     (a3)+,d1
		subq.w     #1,d1
initmode_9:
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		addq.w     #1,d0
		dbf        d1,initmode_9
		lea.l      GDC_I(a0),a1
		lea.l      GDC_D(a0),a2
		movea.l    vgamode+vga_gdc_regs(pc),a3
		moveq.l    #0,d0
		move.w     (a3)+,d1
		subq.w     #1,d1
initmode_10:
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		addq.w     #1,d0
		dbf        d1,initmode_10

		move.b     IS1_RC(a0),d0
		lea.l      ATC_IW(a0),a1
		movea.l    vgamode+vga_atc_regs(pc),a2
		moveq.l    #0,d0
		move.w     (a2)+,d1
		subq.w     #1,d1
initmode_11:
		move.b     d0,(a1)
		move.b     (a2)+,(a1)
		addq.w     #1,d0
		dbf        d1,initmode_11

		move.b     #0x20,(a1)           /* enable screen output */
		lea.l      DAC_IW(a0),a1
		lea.l      DAC_D(a0),a2
		moveq.l    #0,d3
		move.b     d3,(a1)
		move.b     #0xFF,(a2)
		move.b     #0xFF,(a2)
		move.b     #0xFF,(a2)
		moveq.l    #1,d3
initmode_12:
		move.b     d3,(a1)
		move.b     #0x00,(a2)
		move.b     #0x00,(a2)
		move.b     #0x00,(a2)
		addq.w     #1,d3
		cmp.w      #256,d3
		blt.s      initmode_12
		rts

initclock:
		move.w     d3,-(a7)
		move.w     vgamode+vga_synth(pc),d0
		move.w     d0,d3
		and.w      #0x001F,d3
		or.w       #0x0040,d3
		move.w     d3,d0
		bsr.s      selectclock
		moveq.l    #0x20,d0
		or.w       d3,d0
		bsr.s      selectclock
		move.w     d3,d0
		bsr.s      selectclock
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     #0x03,GENHP(a0)      /* enable upper 32k of graphics mode buffer */
		move.b     #0xA0,CGAMODE(a0)    /* enable ET4000 extensions */
		move.b     #0x34,CRTC_IG(a0)    /* unlock registers */
		clr.b      CRTC_DG(a0)
		move.w     (a7)+,d3
		rts

selectclock:
		movem.l    d1-d3/a0,-(a7)
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     GENMO(a0),d1
		and.w      #0xFFF3,d1
		move.w     #0x8000,d2
selectclock_1:
		move.w     d0,d3
		and.w      d2,d3
		beq.s      selectclock_2
		move.w     d1,d3
		or.b       #0x04,d3
		move.b     d3,MISC_W(a0)
		or.b       #0x08,d3
		move.b     d3,MISC_W(a0)
		bra.s      selectclock_3
selectclock_2:
		move.w     d1,d3
		move.b     d3,MISC_W(a0)
		or.b       #0x08,d3
		move.b     d3,MISC_W(a0)
selectclock_3:
		lsr.w      #1,d2
		bne.s      selectclock_1
		move.b     #0x03,GENHP(a0)      /* enable upper 32k of graphics mode buffer */
		move.b     #0xA0,CGAMODE(a0)    /* enable ET4000 extensions */
		move.b     #0x34,CRTC_IG(a0)    /* unlock registers */
		andi.b     #0xFD,CRTC_DG(a0)
		ori.b      #0x02,CRTC_DG(a0)    /* enable Hercules emulation */
		movem.l    (a7)+,d1-d3/a0
		rts

synth_tab:
		dc.b 0x00,0x10,0x08,0x18,0x04,0x14,0x0c,0x1c,0x02,0x12,0x0a,0x1a,0x06,0x16,0x0e,0x1e
		dc.b 0x01,0x11,0x09,0x19,0x05,0x15,0x0d,0x1d,0x03,0x13,0x0b,0x1b,0x07,0x17,0x0f,0x1f

	.bss

frame_offset: ds.w 1
lineavars:    ds.l 1
fontring:     ds.l 1

screen_ptr:   ds.l 1
planes:       ds.w 1
bytes_lin:    ds.w 1
res_x:        ds.w 1
res_y:        ds.w 1
v_cel_wr:     ds.w 1
              ds.w 2
dta:          ds.b 44
nvdivga_path: ds.b 128
active_flag:  ds.w 1
cardtype:     ds.w 1
cardsubtype:  ds.w 1
vgamode:      ds.b VGA_MODESIZE

old_resvalid: ds.l 1
old_resvector: ds.l 1
_PgmSize:     ds.l 1
starthz:      ds.l 1
stophz:       ds.l 1

stack:        ds.b 0x4000 /* FIXME: way too much */
stackend:
              ds.b 16004 /* WTF? */
