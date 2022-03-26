/*
 ******************************************************************************
 *                                                                            *
 *        16-color memory-banked VGA screen driver for NVDI                   *
 *                                                                            *
 ******************************************************************************
 */

/* Labels und Konstanten */
         /* 'Header' */

VERSION           EQU $0500

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"
.INCLUDE "..\include\hardware.inc"

.INCLUDE "nova.inc"
.INCLUDE "vgainf.inc"

DRV_PLANES = 4
PATTERN_LENGTH    EQU ((16*16)/2)*2                /* minimale Fuellmusterlaenge */

	OFFSET WK_LENGTH_300
               ds.l 1
               ds.l 1
               ds.l 1
wk_px_format:  ds.l 1
               ds.l 1
               ds.l 1
               ds.l 1
               ds.l 1
wk_ctab:       ds.l 1
wk_itab:       ds.l 1
               ds.l 1
               ds.l 1
t_fg_colorrgb: ds.w 4 /* text color fg */
t_bg_colorrgb: ds.w 4 /* text color bg */
f_fg_colorrgb: ds.w 4 /* fill color fg */
f_bg_colorrgb: ds.w 4 /* fill color bg */
l_fg_colorrgb: ds.w 4 /* line color fg */
l_bg_colorrgb: ds.w 4 /* line color bg */
m_fg_colorrgb: ds.w 4 /* marker color fg */
m_bg_colorrgb: ds.w 4 /* marker color bg */
r_fg_colorrgb: ds.w 4 /* raster color fg */
r_bg_colorrgb: ds.w 4 /* raster color bg */
               ds.b 72

      ds.b PATTERN_LENGTH
      /* 1056 */
wk_sizeof:

		.text
	
start:
header:           bra.s continue          /* Fuer Aufrufe von normale Treibern */
                  DC.B  'NVDIDRV',0       /* ID des NVDI-Treibers */
                  DC.W  VERSION           /* Versionsnummer im BCD-Format */
                  DC.W  header_end-header /* Laenge des Headers */
                  DC.W  N_SCREEN          /* Bildschirmtreiber */
                  DC.L  init              /* Adresse der Installationsfkt. */
                  DC.L  reset             /* Adresse der Reinstallationsfkt. */
                  DC.L  wk_init
                  DC.L  wk_reset
                  DC.L  get_opnwkinfo
                  DC.L  get_extndinfo
                  DC.L  get_scrninfo
                  DC.L  dev_name
                  DC.L  0,0,0,0           /* reserviert */
organisation:     DC.L  16                /* Farben */
                  DC.W  DRV_PLANES        /* Planes */
                  DC.W  1                 /* Pixelformat */
                  DC.W  1                 /* Bitverteilung */
                  DC.W  0,0,0             /* reserviert */
header_end:


continue:
		rts

/*
 * Treiber initialisieren
 * Vorgaben:
 * nur Register d0 wird veraendert
 * Eingaben:
 * d1.l pb
 * a0.l Zeiger auf nvdi_struct
 * a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
 * Ausgaben:
 * d0.l Laenge der Workstation oder 0L bei einem Fehler
 */
init:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        make_relo
		bsr        get_driver_id
		move.l     a0,nvdi_struct
		move.l     a1,driver_struct
		move.w     _nvdi_cpu020(a0),fast_cpu
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_load_NOD_driver(a0),a2
		lea.l      organisation(pc),a0
		jsr        (a2)
		movea.l    driver_struct(pc),a1
		move.l     a0,driver_offscreen(a1)
		beq.s      init_err
		bsr        save_screen_vecs
		bsr        set_screen_vecs
		bsr        find_vgamode
		movem.l    d0-d7/a0-a6,-(a7)
		bsr        save_linea
		bsr        install_vscr_cookie
		bsr        check_mste
		bsr        clear_device
		moveq.l    #16,d0
		bsr        init_maps
		bsr        init_res
		bsr        init_vt52
		bsr        init_vbl
		movem.l    (a7)+,d0-d7/a0-a6
		movem.l    (a7)+,d0-d2/a0-a2
		move.l     #wk_sizeof,d0
		rts
init_err:
		movem.l    (a7)+,d0-d2/a0-a2
		moveq.l    #0,d0
		rts

reset:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        free_tables
		movem.l    (a7),d0-d2/a0-a2
		movea.l    _nvdi_unload_NOD_driver(a0),a2
		movea.l    driver_offscreen(a1),a0
		jsr        (a2)
		bsr        reset_screen_vecs
		bsr        reset_vscr_cookie
		bsr        reset_vbl
		bsr        restore_linea
		bsr        check_redirect
		movem.l    (a7)+,d0-d2/a0-a2
		rts

save_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     _xbios_vec(a1),xbios_tab
		movea.l    _nvdi_mouse_tab(a0),a1
		lea.l      mouse_tab(pc),a2
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		movea.l    _nvdi_bios_tab(a0),a1
		lea.l      bios_tab(pc),a2
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		move.l     (a1)+,(a2)+
		rts

set_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     #myxbios,_xbios_vec(a1)
		movea.l    _nvdi_mouse_tab(a0),a1
		move.l     #mouse_len,_mouse_buffer(a1)
		move.l     #draw_sprite,_draw_spr_vec(a1)
		move.l     #undraw_sprite,_undraw_spr_vec(a1)
		move.w     #1,hid_cnt
		movea.l    _nvdi_bios_tab(a0),a1
		movea.l    _vt52_vec_vec(a1),a2
		move.l     (a2),save_vt52_vec
		move.l     #vt_con,(a2)
		move.l     #hid_cnt,_cursor_cnt_vec(a1)
		move.l     #vbl_cursor,_cursor_vbl_vec(a1)
		move.l     #mycon_state,_vt52_vec_vec(a1)
		move.l     #vt_con,_con_vec(a1)
		move.l     #vt_rawcon,_rawcon_vec(a1)
		rts

reset_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     xbios_tab(pc),_xbios_vec(a1)
		movea.l    _nvdi_mouse_tab(a0),a1
		lea.l      mouse_tab(pc),a2
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		movea.l    _nvdi_bios_tab(a0),a1
		lea.l      bios_tab(pc),a2
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		movea.l    _nvdi_bios_tab(a0),a1
		movea.l    _vt52_vec_vec(a1),a2
		move.l     save_vt52_vec,(a2)
		rts

save_linea:
		movem.l    d0/a0-a1,-(a7)
		lea.l      V_CEL_HT.w,a0
relok0:
		lea.l      linea_save(pc),a1
		moveq.l    #25-1,d0
save_linea1:
		move.w     (a0)+,(a1)+
		dbf        d0,save_linea1
		move.l     v_bas_ad.w,save_v_bas_ad
		movem.l    (a7)+,d0/a0-a1
		rts

restore_linea:
		movem.l    d0/a0-a1,-(a7)
		lea.l      linea_save(pc),a0
		lea.l      V_CEL_HT.w,a1
relok1:
		moveq.l    #25-1,d0
restore_linea1:
		move.w     (a0)+,(a1)+
		dbf        d0,restore_linea1
		move.l     save_v_bas_ad,v_bas_ad.w
		movem.l    (a7)+,d0/a0-a1
		rts

check_redirect:
		move.l     v_bas_ad.w,d0
		cmp.l      vgamode+vga_membase(pc),d0
		bne.s      check_redirect1
		move.l     redirect_ptr,d0
		beq.s      check_redirect1
		movea.l    d0,a0
		moveq.l    #1,d0
		jsr        (a0)
check_redirect1:
		rts

get_driver_id:
		movem.l    d0/a0,-(a7)
		movea.l    d1,a0
		movea.l    pb_intin(a0),a0
		move.w     (a0),d0
		subq.w     #2,d0
		bpl.s      get_driver_id1
		moveq.l    #0,d0
get_driver_id1:
		move.w     d0,xbios_rez
		movem.l    (a7)+,d0/a0
		rts

/*
 * Ausgaben von v_opnwk()/v_opnvwk()/v_opnbm() zurueckliefern
 * Vorgaben:
 * -
 * Eingaben:
 * d1.l pb oder 0L
 * a0.l intout
 * a1.l ptsout
 * a6.l Workstation
 * Ausgaben:
 */
get_opnwkinfo:
		movem.l    d0/a0-a2,-(a7)
		move.w     vgamode+vga_xres(pc),(a0)+      /* adressierbare Rasterbreite */
		move.w     vgamode+vga_yres(pc),(a0)+      /* adressierbare Rasterhoehe */
		clr.w      (a0)+                /* genaue Skalierung moeglich ! */
		move.l     vgamode+vga_pixw(pc),(a0)+       /* Pixelbreite/Pixelhoehe */
		moveq.l    #39,d0               /* 40 Elemente kopieren */
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_opnwk_work_out(a2),a2
		lea.l      10(a2),a2
work_out_int:
		move.w     (a2)+,(a0)+
		dbf        d0,work_out_int
		move.w     #16,26-90(a0)        /* work_out[13]: Anzahl der Farben */
		move.w     #1,70-90(a0)         /* work_out[35]: Farbe ist vorhanden */
		move.w     #0,78-90(a0)         /* work_out[39]: mehr als 32767 Farbabstufungen in der Palette */
		moveq.l    #12-1,d0
work_out_pts:
		move.w     (a2)+,(a1)+
		dbf        d0,work_out_pts
		movem.l    (a7)+,d0/a0-a2
		rts

/*
 * Ausgaben von vq_extnd() zurueckliefern
 * Vorgaben:
 * -
 * Eingaben:
 * d1.l pb oder 0L
 * a0.l intout
 * a1.l ptsout
 * a6.l Workstation
 * Ausgaben:
 */
get_extndinfo:
		movem.l    d0/a0-a2,-(a7)
		moveq.l    #45-1,d0
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_extnd_work_out(a2),a2
ext_out_int:
		move.w     (a2)+,(a0)+
		dbf        d0,ext_out_int
		move.w     #0,2-90(a0)          /* work_out[1]: mehr als 32767 Farbabstufungen */
		move.w     #DRV_PLANES,8-90(a0) /* work_out[4]: Anzahl der Farbebenen */
		move.w     #1,10-90(a0)         /* work_out[5]: CLUT vorhanden */
		move.w     #2200,12-90(a0)      /* work_out[6]: Anzahl der Rasteroperationen */
		move.w     #1,38-90(a0)         /* work_out[19]: Clipping an */
		moveq.l    #12-1,d0
ext_out_pts:
		move.w     (a2)+,(a1)+
		dbf        d0,ext_out_pts
		lea.l      clip_xmin(a6),a2
		move.l     (a2)+,0-24(a1)       /* work_out[45/46]: clip_xmin/clip_ymin */
		move.l     (a2)+,4-24(a1)       /* work_out[47/48]: clip_xmax/clip_ymax */
		movem.l    (a7)+,d0/a0-a2
		rts

/*
 * Ausgaben von vq_scrninfo() zurueckliefern
 * Vorgaben:
 * 
 * Eingaben:
 * d1.l pb oder 0L
 * a0.l intout
 * a6.l Workstation
 * Ausgaben:
 */
get_scrninfo:
		movem.l    d0-d1/a0-a1,-(a7)
		moveq.l    #6,d0
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      get_scrninfo1
		moveq.l    #8,d0
get_scrninfo1:
		move.w     #-1,(a0)+    /* [0] unknown format */
		move.w     #1,(a0)+     /* [1] Software-CLUT */
		move.w     #DRV_PLANES,(a0)+ /* [2] Anzahl der Ebenen */
		move.l     #16,(a0)+    /* [3/4] Farbanzahl */
		move.w     BYTES_LIN.w,(a0)+ /* [5] Bytes pro Zeile */
relok2:
		move.l     v_bas_ad.w,(a0)+  /* [6/7] Bildschirmadresse */
		move.w     d0,(a0)+     /* [8]  Bits der Rot-Intensitaet */
		move.w     d0,(a0)+     /* [9]  Bits der Gruen-Intensitaet */
		move.w     d0,(a0)+     /* [10] Bits der Blau-Intensitaet */
		move.w     #0,(a0)+     /* [11] kein Alpha-Channel */
		move.w     #0,(a0)+     /* [12] kein Genlock */
		move.w     #0,(a0)+     /* [13] keine unbenutzten Bits */
		move.w     #1,(a0)+     /* [14] Bitorganisation */
		clr.w      (a0)+        /* [15] unbenutzt */
		moveq.l    #16-1,d0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_colmaptab(a1),a1
		movea.l    (a1),a1
scrninfo_loop:
		moveq.l    #15,d1
		and.b      (a1)+,d1
		move.w     d1,(a0)+
		dbf        d0,scrninfo_loop
		move.w     #240-1,d0
		moveq.l    #15,d1
scrninfo_loop2:
		move.w     d1,(a0)+
		dbf        d0,scrninfo_loop2
		movem.l    (a7)+,d0-d1/a0-a1
		rts

synth_tab:
		dc.b 0x00,0x10,0x08,0x18,0x04,0x14,0x0c,0x1c,0x02,0x12,0x0a,0x1a,0x06,0x16,0x0e,0x1e
		dc.b 0x01,0x11,0x09,0x19,0x05,0x15,0x0d,0x1d,0x03,0x13,0x0b,0x1b,0x07,0x17,0x0f,0x1f

find_vgamode:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        load_vga_inf
		move.l     a0,d0
		beq        find_vgamode7
		move.w     vgainf_cardtype(a0),cardtype
		move.w     vgainf_cardsubtype(a0),cardsubtype
		lea.l      vgainf_modes(a0),a1
		moveq.l    #-1,d1
find_vgamode1:
		move.l     vga_next(a1),d0    /* get offset to next mode */
		cmp.l      d1,d0      /* end of modes? */
		beq.s      find_vgamode2
		add.l      a1,d0      /* convert offset to address */
		move.l     d0,vga_next(a1)    /* store address */
		movea.l    d0,a1
		bra.s      find_vgamode1
find_vgamode2:
		move.w     vgainf_defmode+2(a0),d2 /* vga_defmode[1] == 16 color driver */
		bmi.s      find_vgamode6
		lea.l      vgainf_modes(a0),a1
		moveq.l    #0,d0
find_vgamode3:
		cmpi.w     #1,vga_planes(a1)
		bne.s      find_vgamode4
		cmp.w      d0,d2
		beq.s      find_vgamode5
		addq.w     #1,d0
find_vgamode4:
		movea.l    vga_next(a1),a1
		cmp.l      a1,d1
		beq.s      find_vgamode6
		bra.s      find_vgamode3
find_vgamode5:
		movem.l    a0-a1,-(a7)
		movea.l    a1,a0
		lea.l      vgamode(pc),a1
		move.l     a0,d0
		move.w     #DRV_PLANES,vga_planes(a0)
		move.l     #16,vga_colors(a0)
		add.l      d0,vga_modename(a0)
		add.l      d0,vga_ts_regs(a0)
		add.l      d0,vga_crtc_regs(a0)
		add.l      d0,vga_atc_regs(a0)
		add.l      d0,vga_gdc_regs(a0)
		move.w     #VGA_MODESIZE,d0
		bsr        copy_vgainf
		movem.l    (a7)+,a0-a1
find_vgamode6:
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_Mfree_sys(a2),a2
		jsr        (a2)
find_vgamode7:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

load_vga_inf:
		movem.l    d0-d2/a1-a2,-(a7)
		move.w     #25,-(a7) /* Dgetdrv */
		trap       #1
		addq.l     #2,a7
		lea.l      nvdivga_path(pc),a0
		movea.l    a0,a1
		addi.b     #'A',d0
		move.b     d0,(a0)+
		move.b     #':',(a0)+
		move.l     #'\AUT',(a0)+
		move.l     #'O\NV',(a0)+
		move.l     #'DIVG',(a0)+
		move.l     #'A.IN',(a0)+
		move.b     #'F',(a0)+
		clr.b      (a0)+
		lea.l      nvdivga_path(pc),a0
		lea.l      nvdivga_size(pc),a1
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_load_file(a2),a2
		jsr        (a2)
		movem.l    (a7)+,d0-d2/a1-a2
		rts

vscr_funct:
		movem.l    d3-d7/a2-a6,-(a7)
		cmp.w      #2,d0
		bhi.s      vscr_funct_err
		add.w      d0,d0
		move.w     vscr_jmptable(pc,d0.w),d0
		jsr        vscr_jmptable(pc,d0.w)
vscr_funct_err:
		movem.l    (a7)+,d3-d7/a2-a6
		rts
vscr_jmptable:
		dc.w vscr_func0-vscr_jmptable
		dc.w vscr_func1-vscr_jmptable
		dc.w vscr_func2-vscr_jmptable
vscr_func0:
		lea        nvdivga_path(pc),a0
		rts
vscr_func1:
		lea.l      vgamode(pc),a0
		rts
vscr_func2:
		lea.l      vgamode(pc),a1
		move.w     #VGA_MODESIZE,d0
		bsr.s      copy_vgainf
		bsr        initmode
		move.w     #DRV_PLANES,vga_planes(a1)
		move.l     #16,vga_colors(a1)
		rts

/*
 * a0: src
 * a1: dst
 * d0.w: maximum length
 */
copy_vgainf:
		movem.l    d1/a0-a2,-(a7)
		move.w     vgainf_length(a0),d1
		cmp.w      d0,d1
		bgt.s      copy_vgainf4
		movea.l    a1,a2
		move.l     a1,d0
		sub.l      a0,d0
		subq.w     #1,d1
copy_vgainf1:
		move.b     (a0)+,(a1)+
		dbf        d1,copy_vgainf1
		add.l      d0,vga_modename(a2)
		add.l      d0,vga_ts_regs(a2)
		add.l      d0,vga_crtc_regs(a2)
		add.l      d0,vga_atc_regs(a2)
		add.l      d0,vga_gdc_regs(a2)
		cmpi.w     #TOS_PIXW,vga_pixw(a2)
		bne.s      copy_vgainf2
		move.w     #VGA_PIXW,vga_pixw(a2)
copy_vgainf2:
		cmpi.w     #TOS_PIXH,vga_pixh(a2)
		bne.s      copy_vgainf3
		move.w     #VGA_PIXH,vga_pixh(a2)
copy_vgainf3:
		moveq.l    #-1,d0
		movem.l    (a7)+,d1/a0-a2
		rts
copy_vgainf4:
		moveq.l    #0,d0
		movem.l    (a7)+,d1/a0-a2
		rts

/* **************************************************************************** */
                  /* 'Relozierungsroutine' */
make_relo:
		movem.l    d0-d2/a0-a2,-(a7)
		DC.W 0xa000
		sub.w      #CMP_BASE,d0         /* Differenz der Line-A-Adressen */
		beq.s      relo_exit            /* keine Relokation noetig ? */
		lea.l      start(pc),a0         /* Start des Textsegments */
		lea.l      relokation(pc),a1    /* Relokationsinformation */
relo_loop:
		move.w     (a1)+,d1             /* Adress-Offset */
		beq.s      relo_exit
		adda.w     d1,a0
		add.w      d0,(a0)              /* relozieren */
		bra.s      relo_loop
relo_exit:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

init_res:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    vgamode+vga_membase(pc),a0
		movea.l    a0,a1
		adda.l     #0x0003FFFF,a0
		adda.l     #VGA_MEMSIZE,a1
		move.l     a0,vga_memend1
		move.l     a1,vga_memend2
		movem.w    vgamode+vga_xres(pc),d0-d1
		move.w     vgamode+vga_line_width(pc),d2
		move.l     vgamode+vga_membase(pc),v_bas_ad.w
		move.w     #DRV_PLANES,PLANES.w
relok3:
		add.w      d2,d2
		add.w      d2,d2
		move.w     d2,WIDTH.w
relok4:
		move.w     d2,BYTES_LIN.w
relok5:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

/*
 * VT52-Emulator an die gewaehlte Aufloesung anpassen
 * kein Register wird zerstoert
 */
init_vt52:
		movem.l    d0-d4/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_sys_font_info(a0),a0
		move.l     _sf_font_addr(a0),sysfont_addr
		move.l     _sf_image(a0),font_image
		movem.w    vgamode+vga_xres(pc),d0-d1
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     vgamode+vga_line_width(pc),d2
		move.w     d0,V_REZ_HZ.w
relok6:
		move.w     d1,V_REZ_VT.w
relok7:
		movea.l    _sf_font_hdr_ptr(a0),a1
		lea.l      sizeof_FONTHDR(a1),a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		lea.l      sizeof_FONTHDR(a1),a1
init_vt52_font:
		move.l     dat_table(a1),V_FNT_AD.w
relok8:
		move.l     off_table(a1),V_OFF_AD.w
relok9:
		move.w     #256,V_FNT_WD.w
relok10:
		move.l     #0x00FF0000,V_FNT_ND.w
relok11:
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT.w
relok12:
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		movem.w    d0-d2,V_CEL_MX.w /* V_CEL_MX/V_CEL_MY/V_CEL_WR */
relok13:
		move.l     #15,V_COL_BG.w
relok14:
		move.w     #1,V_HID_CNT.w
relok15:
		move.w     #256,V_STAT_0.w
relok16:
		move.w     #0x1E1E,V_PERIOD.w
relok17:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok18:
		clr.l      V_CUR_XY.w
relok19:
		clr.w      V_CUR_OF.w
relok20:
		lea.l      vt_con0(pc),a0
		lea.l      vt_rawcon(pc),a1
		move.l     a0,mycon_state
		movem.l    a0-a1,convecs
		movem.l    (a7)+,d0-d4/a0-a2
		rts

init_vbl:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_init_virtual_vbl(a0),a1
		lea.l      vbl_mouse(pc),a0
		jsr        (a1)
		rts

reset_vbl:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_reset_virtual_vbl(a0),a1
		lea.l      vbl_mouse(pc),a0
		jsr        (a1)
		rts

clear_device:
		bsr.s      initmode
		bsr        clear_framebuffer
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
		move.b     vgamode+vga_MISC_W,MISC_W(a0)
		move.b     #0x01,VIDSUB(a0)
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
initmode_5:
		addq.w     #1,d0
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		dbf        d1,initmode_5
initmode_6:
		move.b     #0x00,(a1)
		move.b     #0x03,(a2)
		cmpi.w     #CARD_SPEKTRUM,cardtype
		bne.s      initmode_7
		tst.w      cardsubtype
		beq        initmode_10
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0x02,DAC_PEL(a0)
initmode_7:
		cmpi.w     #CARD_CRAZYDOTS,cardtype
		bne.s      initmode_9
		cmpi.w     #2,cardsubtype
		bne.s      initmode_8
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0x00,DAC_PEL(a0)
initmode_8:
		moveq.l    #31,d0
		and.w      vgamode+vga_synth,d0
		lea.l      synth_tab(pc),a1
		move.b     0(a1,d0.w),d0
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      initmode_8_1
		bset       #7,d0
initmode_8_1:
		move.b     d0,(a0) /* BUG? should that be DAC_PEL(a0)? */
initmode_9:
		cmpi.w     #CARD_VOFA,cardtype
		bne.s      initmode_10
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     vgamode+vga_PEL,DAC_PEL(a0)
initmode_10:
		lea.l      CRTC_IG(a0),a1
		lea.l      CRTC_DG(a0),a2
		movea.l    vgamode+vga_crtc_regs(pc),a3
		moveq.l    #0,d0
		move.w     (a3)+,d1
		subq.w     #1,d1
initmode_11:
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		addq.w     #1,d0
		dbf        d1,initmode_11
		lea.l      GDC_I(a0),a1
		lea.l      GDC_D(a0),a2
		movea.l    vgamode+vga_gdc_regs(pc),a3
		moveq.l    #0,d0
		move.w     (a3)+,d1
		subq.w     #1,d1
initmode_12:
		move.b     d0,(a1)
		move.b     (a3)+,(a2)
		addq.w     #1,d0
		dbf        d1,initmode_12

		move.b     IS1_RC(a0),d0
		lea.l      ATC_IW(a0),a1
		movea.l    vgamode+vga_atc_regs(pc),a2
		moveq.l    #0,d0
		move.w     (a2)+,d1
		subq.w     #1,d1
initmode_13:
		move.b     d0,(a1)
		move.b     (a2)+,(a1)
		addq.w     #1,d0
		dbf        d1,initmode_13

		move.b     #0x20,(a1)           /* enable screen output */
		move.l     vgamode+vga_visible_xres(pc),d0
		add.l      #0x00010001,d0
		lea.l      vscr_struct(pc),a1
		move.l     #'VSCR',(a1)+
		move.l     #'NVDI',(a1)+
		move.w     #0x100,(a1)+
		clr.l      (a1)+
		move.l     d0,(a1)+
		move.l     #vscr_funct,(a1)+
		move.l     vgamode+vga_visible_xres(pc),d0
		cmp.l      vgamode+vga_xres(pc),d0
		bne.s      initmode_15
		rts
initmode_15:
		move.w     vgamode+vga_xres(pc),d0
		addq.w     #1,d0
		lsr.w      #3,d0
		move.w     d0,vgamode+vga_line_width
		movea.l    vgamode+vga_regbase(pc),a0
		lea.l      CRTC_IG(a0),a0
		lsr.w      #1,d0
		move.b     #0x13,(a0)
		move.b     d0,1(a0)
		rts

initclock:
		move.w     d3,-(a7)
		move.w     vgamode+vga_synth,d0
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

clear_framebuffer:
		movea.l    vgamode+vga_membase(pc),a1
		move.w     vgamode+vga_yres,d0
		addq.w     #1,d0
		mulu.w     vgamode+vga_line_width(pc),d0
		lsr.l      #2,d0
		subq.l     #1,d0
clear_framebuffer1:
		clr.l      (a1)+
		dbf        d0,clear_framebuffer1
		rts

install_vscr_cookie:
		movem.l    d0-d2/a0-a1,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_init_cookie(a0),a0
		move.l     #'VSCR',d0
		move.l     #vscr_struct,d1
		jsr        (a0)
		movem.l    (a7)+,d0-d2/a0-a1
		rts

check_mste:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		move.l     _nvdi_cookie_MCH(a0),d1
		moveq.l    #0,d0
		swap       d1
		subq.w     #1,d1
		bne.s      check_mste1
		swap       d1
		cmp.w      #16,d1
		bne.s      check_mste1
		move.w     #1,d0
check_mste1:
		move.w     d0,is_mste
		move.l     #'RDCT',d0
		movea.l    _nvdi_search_cookie(a0),a0
		jsr        (a0)
		move.l     d1,redirect_ptr
		movem.l    (a7)+,d0-d2/a0-a2
		rts

reset_vscr_cookie:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_reset_cookie(a0),a0
		move.l     #'VSCR',d0
		jsr        (a0)
		movem.l    (a7)+,d0-d2/a0-a2
		rts

/*
 * Undraw Sprite ($A00C)
 * Eingaben
 * a2.l Zeiger auf den Sprite-Save-Block
 * Ausgaben
 * d2/a1-a5 werden zerstoert
 */
undraw_sprite:
		move.w     (a2)+,d2
		subq.w     #1,d2         /* line counter - 1 for dbra */
		bmi        undraw_exit
		movea.l    (a2)+,a1      /* destination address */
		bclr       #0,(a2)       /* save block valid? */
		beq        undraw_exit
		addq.l     #2,a2         /* address of saved background */
		move.w     BYTES_LIN.w,d0
relok21:
		lsr.w      #2,d0
		movea.w    d0,a3         /* offset to next line */
		moveq.l    #DRV_PLANES-1,d0
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     TS_I(a0),-(a7)       /* save value of TS index register */
		move.b     GDC_I(a0),-(a7)      /* save value of GDC index register */
		move.b     #0x04,TS_I(a0)       /* select memory mode register */
		move.b     TS_D(a0),-(a7)       /* save memory mode value */
		andi.b     #0xF7,TS_D(a0)       /* Enables sequential data access within a bit map */
		move.b     #0x05,GDC_I(a0)      /* select graphic mode register */
		move.b     GDC_D(a0),-(a7)      /* save old graphic mode */
		andi.b     #0xFC,GDC_D(a0)      /* select byte oriented write mode */
		move.b     #0x01,GDC_I(a0)      /* select enable set register */
		move.b     GDC_D(a0),-(a7)      /* save old value */
		move.b     #0x00,GDC_D(a0)      /* disable set/reset */
		move.b     #0x08,GDC_I(a0)      /* select bit mask register */
		move.b     GDC_D(a0),-(a7)      /* save old value */
		move.b     #0x00,GDC_D(a0)      /* data is from latches */
		movea.l    vga_memend1(pc),a4
		move.b     d2,(a4)
		move.b     #0xFF,GDC_D(a0)      /* write to all bits */
		move.b     #0x02,TS_I(a0)       /* select map mask register */
		move.b     #0x04,GDC_I(a0)      /* select map select register */
		move.b     TS_D(a0),-(a7)       /* save old value */
		move.b     GDC_D(a0),-(a7)      /* save old value */
undraw_spr_plane_loop:
		move.b     memwrite_table(pc,d0.w),TS_D(a0) /* enable writes to bank */
		move.b     memread_table(pc,d0.w),GDC_D(a0)
		move.w     d2,d1
		movea.l    a1,a4
undraw_spr_line_loop:
		move.l     (a2)+,(a4)
		adda.w     a3,a4
		dbf        d1,undraw_spr_line_loop
		dbf        d0,undraw_spr_plane_loop
		movea.l    vga_memend1(pc),a4
		tst.b      (a4)
		move.b     (a7)+,GDC_D(a0)      /* restore old value */
		move.b     (a7)+,TS_D(a0)       /* restore old value */
		move.b     #0x08,GDC_I(a0)      /* select bit mask register */
		move.b     (a7)+,GDC_D(a0)      /* restore old value */
		move.b     #0x01,GDC_I(a0)      /* select enable set register */
		move.b     (a7)+,GDC_D(a0)      /* restore old value */
		move.b     #0x05,GDC_I(a0)      /* select graphic mode register */
		move.b     (a7)+,GDC_D(a0)      /* restore old graphic mode */
		move.b     #0x04,TS_I(a0)       /* select memory mode register */
		move.b     (a7)+,TS_D(a0)       /* restore memory mode value */
		move.b     (a7)+,GDC_I(a0)      /* restore GDC index register */
		move.b     (a7)+,TS_I(a0)       /* restore TS index register */
undraw_exit:
		rts

memwrite_table:
	dc.b 8,4,2,1
memread_table:
	dc.b 3,2,1,0

/*
 * Draw Sprite ($A00D)
 * Eingaben
 * d0.w x
 * d1.w y
 * a0.l Zeiger auf die Spritedefinition
 * a2.l Zeiger auf den Hintergrundbuffer
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
draw_sprite:
		move.l     a6,-(a7)
		movea.l    vgamode+vga_regbase(pc),a4
		move.b     TS_I(a4),-(a7)       /* save value of TS index register */
		move.b     GDC_I(a4),-(a7)      /* save value of GDC index register */
		move.b     #0x04,TS_I(a4)       /* select memory mode register */
		move.b     TS_D(a4),-(a7)       /* save memory mode value */
		andi.b     #0xF7,TS_D(a4)       /* Enables sequential data access within a bit map */
		move.b     #0x05,GDC_I(a4)      /* select graphic mode register */
		move.b     GDC_D(a4),-(a7)      /* save old graphic mode */
		andi.b     #0xFC,GDC_D(a4)      /* select byte oriented write mode */
		move.b     #0x01,GDC_I(a4)      /* select enable set register */
		move.b     GDC_D(a4),-(a7)      /* save old value */
		move.b     #0x00,GDC_D(a4)      /* disable set/reset */
		move.b     #0x08,GDC_I(a4)      /* select bit mask register */
		move.b     GDC_D(a4),-(a7)      /* save old value */
		move.b     #0x00,GDC_D(a4)      /* data is from latches */
		movea.l    vga_memend1(pc),a1
		move.b     d2,(a1)
		move.b     #0xFF,GDC_D(a4)      /* write to all bits */
		move.b     #0x02,TS_I(a4)       /* select map mask register */
		move.b     #0x04,GDC_I(a4)      /* select map select register */
		move.b     TS_D(a4),-(a7)       /* save old value */
		move.b     GDC_D(a4),-(a7)      /* save old value */
		move.w     6(a0),-(a7)          /* save background color */
		move.w     8(a0),-(a7)          /* save foreground color */
		clr.w      d2
		sub.w      (a0),d0              /* X_Koord - intxhot */
		bcs.s      draw_spr_x2
		move.w     DEV_TAB0.w,d3
relok22:
		subi.w     #15,d3
		cmp.w      d3,d0
		bhi.s      draw_spr_x3
		bra.s      draw_spr_y
draw_spr_x2:
		addi.w     #16,d0
		moveq.l    #4,d2
		bra.s      draw_spr_y
draw_spr_x3:
		moveq.l    #8,d2
draw_spr_y:
		sub.w      2(a0),d1             /* Y_Koord - intyhot */
		lea.l      10(a0),a0            /* pointer to sprite-image */
		bcs.s      draw_spr_y2
		move.w     DEV_TAB1.w,d3
relok23:
		subi.w     #15,d3
		cmp.w      d3,d1
		bhi.s      draw_spr_y3
		moveq.l    #16,d5
		bra.s      draw_spr_y4
draw_spr_y2:
		move.w     d1,d5
		addi.w     #16,d5
		asl.w      #2,d1
		suba.w     d1,a0
		clr.w      d1
		bra.s      draw_spr_y4
draw_spr_y3:
		move.w     DEV_TAB1.w,d5
relok24:
		sub.w      d1,d5
		addq.w     #1,d5
draw_spr_y4:
		move.w     d0,-(a7)
		movea.l    v_bas_ad.w,a1
		muls.w     BYTES_LIN.w,d1
relok25:
		lsr.l      #2,d1
		adda.l     d1,a1
		asr.w      #4,d0
		add.w      d0,d0
		adda.w     d0,a1
		moveq.l    #15,d0
		and.w      (a7)+,d0
		lea.l      drawspr12(pc),a3
		move.w     d0,d6
		cmpi.w     #8,d6
		bcs.s      drawspr1
		lea.l      drawspr11(pc),a3
		move.w     #16,d6
		sub.w      d0,d6
drawspr1:
		movea.l    drawspr_tmptable1(pc,d2.w),a5
		movea.l    drawspr_tmptable2(pc,d2.w),a6
		moveq.l    #0,d7
		moveq.l    #DRV_PLANES-1,d7
drawspr2:
		move.w     BYTES_LIN.w,d4
relok26:
		lsr.w      #2,d4
		move.w     d5,(a2)+
		move.l     a1,(a2)+
		cmpa.l     #drawspr9,a6
		bne.s      drawspr3
		subq.l     #2,-4(a2)
drawspr3:
		move.w     #0x0300,(a2)+
		subq.w     #1,d5
		bpl.s      drawspr4
		bmi.s      drawspr4_1

drawspr_tmptable1:
	dc.l drawspr6
	dc.l drawspr8
	dc.l drawspr10
drawspr_tmptable2:
	dc.l drawspr5
	dc.l drawspr7
	dc.l drawspr9

drawspr4:
		move.l     a4,-(a7)
		move.b     memwrite_table2(pc,d7.w),TS_D(a4)
		move.b     memread_table2(pc,d7.w),GDC_D(a4)
		clr.w      d0
		lsr.w      4(a7)
		addx.w     d0,d0
		lsr.w      6(a7)
		roxl.w     #3,d0
		movea.l    drawspr_jmptable3(pc,d0.w),a4
		move.w     d5,-(a7)
		movem.l    a0-a1,-(a7)
		jsr        (a6)
		movem.l    (a7)+,a0-a1
		move.w     (a7)+,d5
		movea.l    (a7)+,a4
		dbf        d7,drawspr4
drawspr4_1:
		addq.l     #4,a7
		movea.l    vga_memend1(pc),a1
		tst.b      (a1)
		move.b     (a7)+,GDC_D(a4)      /* restore old value */
		move.b     (a7)+,TS_D(a4)       /* restore old value */
		move.b     #0x08,GDC_I(a4)      /* select bit mask register */
		move.b     (a7)+,GDC_D(a4)      /* restore old value */
		move.b     #0x01,GDC_I(a4)      /* select enable set register */
		move.b     (a7)+,GDC_D(a4)      /* restore old value */
		move.b     #0x05,GDC_I(a4)      /* select graphic mode register */
		move.b     (a7)+,GDC_D(a4)      /* restore old graphic mode */
		move.b     #0x04,TS_I(a4)       /* select memory mode register */
		move.b     (a7)+,TS_D(a4)       /* restore memory mode value */
		move.b     (a7)+,GDC_I(a4)      /* restore GDC index register */
		move.b     (a7)+,TS_I(a4)       /* restore TS index register */
		movea.l    (a7)+,a6
		rts

memwrite_table2:
	dc.b 8,4,2,1
memread_table2:
	dc.b 3,2,1,0

drawspr_jmptable3:
	dc.l drawspr13
	dc.l drawspr14
	dc.l drawspr15
	dc.l drawspr16

drawspr5:
		move.l     (a1),d2
		move.l     d2,(a2)+
		jmp        (a3)
drawspr6:
		move.l     d2,(a1)
		adda.w     d4,a1
		dbf        d5,drawspr5
		rts
drawspr7:
		move.l     (a1),d2
		move.l     d2,(a2)+
		swap       d2
		jmp        (a3)
drawspr8:
		move.w     d2,(a1)
		adda.w     d4,a1
		dbf        d5,drawspr7
		rts
drawspr9:
		move.l     -2(a1),d2
		move.l     d2,(a2)+
		swap       d2
		jmp        (a3)
drawspr10:
		swap       d2
		move.w     d2,(a1)
		adda.w     d4,a1
		dbf        d5,drawspr9
		rts
drawspr11:
		moveq.l    #0,d0
		moveq.l    #0,d1
		move.w     (a0)+,d0
		move.w     (a0)+,d1
		rol.l      d6,d0
		rol.l      d6,d1
		jmp        (a4)
drawspr12:
		move.l     (a0)+,d0
		move.w     d0,d1
		swap       d1
		clr.w      d0
		clr.w      d1
		ror.l      d6,d0
		ror.l      d6,d1
		jmp        (a4)
drawspr13:
		or.l       d1,d0
		not.l      d0
		and.l      d0,d2
		jmp        (a5)
drawspr14:
		or.l       d0,d2
		not.l      d1
		and.l      d1,d2
		jmp        (a5)
drawspr15:
		not.l      d0
		and.l      d0,d2
		or.l       d1,d2
		jmp        (a5)
drawspr16:
		or.l       d0,d2
		or.l       d1,d2
		jmp        (a5)

vbl_mouse:
		lea.l      vgamode+vga_visible_xres(pc),a0
		move.l     vgamode+vga_xres(pc),d6
		cmp.l      (a0),d6
		beq        vbl_mouse_exit
		lea.l      vscr_struct+10(pc),a1
		movem.w    (a0),d4-d5
		movem.w    (a1),d2-d3
		add.w      d2,d4
		add.w      d3,d5
		moveq.l    #-32,d0
		moveq.l    #-32,d1
		add.w      GCURX.w,d0
relok27:
		add.w      GCURY.w,d1
relok28:
		cmp.w      d2,d0
		bge.s      vbl_mouse1
		move.w     d0,d2
		bpl.s      vbl_mouse1
		moveq.l    #0,d2
vbl_mouse1:
		cmp.w      d3,d1
		bge.s      vbl_mouse2
		move.w     d1,d3
		bpl.s      vbl_mouse2
		moveq.l    #0,d3
vbl_mouse2:
		moveq.l    #64,d7
		add.w      d7,d0
		add.w      d7,d1
		cmp.w      d5,d1
		ble.s      vbl_mouse4
		cmp.w      d6,d1
		ble.s      vbl_mouse3
		move.w     d6,d1
vbl_mouse3:
		sub.w      d5,d1
		add.w      d1,d3
vbl_mouse4:
		cmp.w      d4,d0
		ble.s      vbl_mouse6
		swap       d6
		cmp.w      d6,d0
		ble.s      vbl_mouse5
		move.w     d6,d0
vbl_mouse5:
		sub.w      d4,d0
		add.w      d0,d2
vbl_mouse6:
		move.w     d2,d0
		swap       d0
		move.w     d3,d0
		cmp.l      (a1),d0
		beq.s      vbl_mouse_exit
		move.l     d0,(a1)
		moveq.l    #7,d0
		and.w      d2,d0
		mulu.w     vgamode+vga_line_width(pc),d3
		ext.l      d2
		lsr.l      #3,d2
		add.l      d3,d2
		movea.l    vgamode+vga_regbase(pc),a0
		tst.b      IS1_RC(a0)
		lea.l      ATC_IW(a0),a1
		move.b     #0x33,(a1)
		move.b     d0,(a1)
		lea.l      CRTC_DG(a0),a1
		lea.l      CRTC_IG(a0),a0
		move.b     #0x0D,(a0)
		move.b     d2,(a1)
		lsr.w      #8,d2
		move.b     #0x0C,(a0)
		move.b     d2,(a1)
		swap       d2
		move.b     #0x33,(a0)
		move.b     d2,(a1)
vbl_mouse_exit:
		rts

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #86,d0
		beq        esetgray
		cmp.w      #64,d0
		beq        blitmode
		cmp.w      #21,d0
		beq.s      cursconf
		cmp.w      #2,d0
		blt.s      gooldxbios
		cmp.w      #7,d0
		bgt.s      gooldxbios
		subq.w     #3,d0
		blt.s      physbase
		beq.s      logbase
		subq.w     #1,d0
		beq.s      getrez
		subq.w     #1,d0
		beq.s      setscreen
		subq.w     #1,d0
		beq.s      setpalette
		bra.s      setcolor
physbase:
		move.l     vgamode+vga_membase(pc),d0
		rte
logbase:
		move.l     v_bas_ad.w,d0
		rte
getrez:
		move.w     xbios_rez(pc),d0
		rte
setscreen:
		move.l     (a0)+,d0
		cmp.l      #-1,d0
		beq.s      setscreen1
		move.l     d0,v_bas_ad.w
setscreen1:
		rte
setpalette:
		rte
setcolor:
		rte

cursconf:
		move.w     (a0)+,d0
		cmp.w      #5,d0
		bhi.s      cursconf1
		move.b     cursconf_tab(pc,d0.w),d0
		jsr        cursconf_tab(pc,d0.w)
cursconf1:
		rte


cursconf_tab:
		dc.b cursconf_0-cursconf_tab
		dc.b cursconf_1-cursconf_tab
		dc.b cursconf_2-cursconf_tab
		dc.b cursconf_3-cursconf_tab
		dc.b cursconf_4-cursconf_tab
		dc.b cursconf_5-cursconf_tab

cursconf_0:
		bra        cursor_off
cursconf_1:
		tst.w      hid_cnt
		beq.s      cursconf_ret
		move.w     #1,hid_cnt
		bra        cursor_on
cursconf_2:
		bset       #CURSOR_BL,V_STAT_0.w
relok29:
cursconf_ret:
		rts
cursconf_3:
		bclr       #CURSOR_BL,V_STAT_0.w
relok30:
		rts
cursconf_4:
		move.b     1(a0),V_PERIOD.w
relok31:
		rts
cursconf_5:
		moveq.l    #0,d0
		move.b     V_PERIOD.w,d0
relok32:
		rts

blitmode:
		moveq.l    #0,d0
		rte

esetgray:
		move.w     graymode(pc),-(a7)
		move.w     (a0),d0
		bmi.s      esetgray1
		move.w     d0,graymode
		moveq.l    #0,d0
		moveq.l    #15,d1
		movea.l    global_ctable(pc),a0
		lea.l      ctab_colors(a0),a0
		bsr        set_color_rgb
esetgray1:
		move.w     (a7)+,d0
		rte

		rte /* unused */

/* **************************************************************************** */
                  /* 'GEMDOS\BIOS\XBIOS' */

/* OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12) */
v_curtext:
		movem.l    d1-d3/a2-a3,-(a7)
		movea.l    pb_intin(a0),a3
		move.w     v_nintin(a1),d3
		subq.w     #1,d3
		bmi.s      v_curtext_exit
v_curtext_loop:
		move.w     (a3)+,d1
		movea.l    mycon_state(pc),a0
		jsr        (a0)
		dbf        d3,v_curtext_loop
v_curtext_exit:
		movem.l    (a7)+,d1-d3/a2-a3
		rts

/*
 * Cursor positionieren
 * Eingabe
 * d0 Textspalte
 * d1 Textzeile
 * Ausgabe
 * a1 Cursoradresse
 * zerstoert werden d0-d2
 */
set_cursor_xy:
		bsr.s      cursor_off
set_cur_clipx1:
		move.w     V_CEL_MX.w,d2
relok33:
		tst.w      d0
		bpl.s      set_cur_clipx2
		moveq.l    #0,d0
set_cur_clipx2:
		cmp.w      d2,d0
		ble.s      set_cur_clipy1
		move.w     d2,d0
set_cur_clipy1:
		move.w     V_CEL_MY.w,d2
relok34:
		tst.w      d1
		bpl.s      set_cur_clipy2
		moveq.l    #0,d1
set_cur_clipy2:
		cmp.w      d2,d1
		ble.s      set_cursor
		move.w     d2,d1
set_cursor:
		movem.w    d0-d1,V_CUR_XY.w
relok35:
		movea.l    v_bas_ad.w,a1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok36:
		adda.l     d1,a1
		adda.w     d0,a1
		adda.w     V_CUR_OF.w,a1
relok37:
		move.l     a1,V_CUR_AD.w
relok38:
		bra.s      cursor_on

/* Cursor ausschalten */
cursor_off:
		addq.w     #1,hid_cnt
		cmpi.w     #1,hid_cnt
		bne.s      cursor_off_exit
		bclr       #CURSOR_STATE,V_STAT_0.w
relok39:
		bne.s      cursor
cursor_off_exit:
		rts

/* Cursor einschalten */
cursor_on:
		cmpi.w     #1,hid_cnt
		bcs.s      cursor_on_exit2
		bhi.s      cursor_on_exit1
		move.b     V_PERIOD.w,V_CUR_CT.w
relok40:
		bsr.s      cursor
		bset       #CURSOR_STATE,V_STAT_0.w
relok41:
cursor_on_exit1:
		subq.w     #1,hid_cnt
cursor_on_exit2:
		rts

vbl_cursor:
		btst       #CURSOR_BL,V_STAT_0.w
relok42:
		beq.s      vbl_no_bl
		bchg       #CURSOR_STATE,V_STAT_0.w
relok43:
		bra.s      cursor
vbl_no_bl:
		bset       #CURSOR_STATE,V_STAT_0.w
relok44:
		beq.s      cursor
		rts

/* Cursor zeichnen */
cursor:
		movem.l    d0-d1/a0-a1,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
relok45:
		add.w      d0,d0
		add.w      d0,d0          /* (16 - Zeichenhoehe) * 4 */
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d1
relok46:
		mulu.w     V_CUR_XY1.w,d1
relok47:
		mulu.w     V_CEL_HT.w,d1
relok48:
		adda.l     d1,a1
		move.w     V_CUR_XY.w,d1
relok49:
		add.w      d1,d1
		add.w      d1,d1
		adda.w     d1,a1
		move.w     BYTES_LIN.w,d1
relok50:
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     TS_I(a0),-(a7)
		move.b     #0x04,TS_I(a0)
		move.b     TS_D(a0),-(a7)
		bset       #0x03,TS_D(a0)
		move.b     #0x02,TS_I(a0)
		move.b     TS_D(a0),-(a7)
		move.b     #0x0F,TS_D(a0)
		jmp        cursor_jmp(pc,d0.w)
cursor_jmp:
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		adda.w     d1,a1
		not.l      (a1)
		/* BUG: adda missing (happens only with V_CEL_HT = 1) */
		move.b     (a7)+,TS_D(a0)
		move.b     #0x04,TS_I(a0)
		move.b     (a7)+,TS_D(a0)
		move.b     (a7)+,TS_I(a0)
		movem.l    (a7)+,d0-d1/a0-a1
cursor_exit:
		rts

/* BEL, Klingelzeichen */
vt_bel:
		btst       #2,conterm.w
		beq.s      cursor_exit
		movea.l    bell_hook.w,a0
		jmp        (a0)

/* not used */
		dc.l 'XBRA'
		dc.l 'NVDI'
		dc.l 0
make_pling:
		pea.l      pling(pc)
		move.w     #32,-(a7) /* Dosound */
		trap       #14
		addq.l     #6,a7
		rts
pling:            DC.B 0x00,0x34
				  DC.B 0x01,0x00
				  DC.B 0x02,0x00
				  DC.B 0x03,0x00
				  DC.B 0x04,0x00
				  DC.B 0x05,0x00
				  DC.B 0x06,0x00
				  DC.B 0x07,0xfe
                  DC.B 0x08,0x10
                  DC.B 0x09,0x00
                  DC.B 0x0a,0x00
                  DC.B 0x0b,0x00
                  DC.B 0x0c,0x10
                  DC.B 0x0d,0x09
                  DC.B 0xff,0x00

/* BACKSPACE, ein Zeichen zurueck */
vt_bs:
		movem.w    V_CUR_XY.w,d0-d1
relok51:
		subq.w     #1,d0
		bra        set_cursor_xy

/* HT */
vt_ht:
		andi.w     #-8,d0
		addq.w     #8,d0
		bra        set_cursor_xy

/* LINEFEED, naechste Zeile */
vt_lf:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		sub.w      V_CEL_MY.w,d1
relok52:
		beq        scroll_up_page
		move.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok53:
		add.l      d1,V_CUR_AD.w
relok54:
		addq.w     #1,V_CUR_XY1.w
relok55:
		rts

/* RETURN, Zeilenanfang */
vt_cr:
		bsr        cursor_off
		pea.l      cursor_on(pc)
		movea.l    V_CUR_AD.w,a1
relok56:

/*
 * Cursor an den Zeilenanfang setzen
 * Eingabe
 * d0 Cursorspalte
 * a1 Cursoradresse
 * Ausgabe
 * a1 neue Cursoradresse
 * zerstoert werden d0/d2
 */
set_x0:
		suba.w     d0,a1
		move.l     a1,V_CUR_AD.w
relok57:
		clr.w      V_CUR_XY.w
relok58:
		rts

/* ESC */
vt_esc:
		move.l     #vt_esc_seq,mycon_state
		rts

vt_control:
		cmpi.w     #27,d1
		beq.s      vt_esc
		subq.w     #7,d1
		subq.w     #6,d1
		bhi.s      vt_c_exit
		move.l     convecs,mycon_state
		add.w      d1,d1
		move.w     vt_c_tab(pc,d1.w),d2
		movem.w    V_CUR_XY.w,d0-d1
relok59:
		jmp        vt_c_tab(pc,d2.w)
vt_c_exit:
		rts

                  DC.W vt_bel-vt_c_tab    /* 7  BEL */
                  DC.W vt_bs-vt_c_tab     /* 8  BS */
                  DC.W vt_ht-vt_c_tab     /* 9  HT */
                  DC.W vt_lf-vt_c_tab     /* 10 LF */
                  DC.W vt_lf-vt_c_tab     /* 11 VT */
                  DC.W vt_lf-vt_c_tab     /* 12 FF */
vt_c_tab:         DC.W vt_cr-vt_c_tab     /* 13 CR */

vt_con:
		movea.l    mycon_state(pc),a0
		jmp        (a0)
vt_con0:
		cmpi.w     #32,d1
		blt.s      vt_control

vt_rawcon:
		move.l     d3,-(a7)
		move.l     a3,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
relok60:
		add.w      d0,d0
		move.w     d0,d2
		lsl.w      #7,d2
		sub.w      d2,d1
		movea.l    V_FNT_AD.w,a0
relok61:
		movea.l    V_CUR_AD.w,a1
relok62:
		move.w     BYTES_LIN.w,d2
relok63:
		lsr.w      #2,d2
		movea.w    d2,a2
		adda.w     d1,a0
		moveq.l    #3,d2
		move.l     V_COL_BG.w,d3
relok64:
		move.b     #2,V_CUR_CT.w
relok65:
		movea.l    vgamode+vga_regbase(pc),a3
		move.b     #0x02,TS_I(a3)
		move.b     #0x04,GDC_I(a3)
		bclr       #CURSOR_STATE,V_STAT_0.w
relok66:
		btst       #CURSOR_INVERSE,V_STAT_0.w
relok67:
		beq.s      vt_char_bloop
		swap       d3
vt_char_bloop:
		move.b     memwrite_table3(pc,d2.w),TS_D(a3)
		move.b     memread_table3(pc,d2.w),GDC_D(a3)
		move.l     a1,-(a7)
		pea.l      vt_char2(pc)
		lsr.l      #1,d3
		bcc.s      vt_char1
		btst       #15,d3
		beq.s      vt_char_col
		bra        vt_char_rcol
vt_char1:
		btst       #15,d3
		bne        vt_char_col2
		bra        vt_char_rcol0
vt_char2:
		movea.l    (a7)+,a1
		dbf        d2,vt_char_bloop
		movea.l    (a7)+,a3
		move.l     (a7)+,d3
		move.w     V_CUR_XY.w,d0
relok68:
		cmp.w      V_CEL_MX.w,d0
relok69:
		bge.s      vt_l_column
		addq.w     #1,V_CUR_XY.w
relok70:
		addq.l     #1,V_CUR_AD.w
relok71:
		moveq.l    #-1,d0
		rts

memwrite_table3:
	dc.b 8,4,2,1
memread_table3:
	dc.b 3,2,1,0

vt_l_column:
		btst       #CURSOR_WRAP,V_STAT_0.w
relok72:
		beq.s      vt_con_exit
		addq.w     #1,hid_cnt
		movea.l    V_CUR_AD.w,a1
relok73:
		suba.w     d0,a1
		move.l     a1,V_CUR_AD.w
relok74:
		clr.w      V_CUR_XY.w
relok75:
		move.w     V_CUR_XY1.w,d1
relok76:
		pea.l      vt_l_column2(pc)
		cmp.w      V_CEL_MY.w,d1
relok77:
		bge        scroll_up_page
		addq.l     #4,a7
		adda.w     V_CEL_WR.w,a1 /* FIXME: V_CEL_WR is obsolete */
relok78:
		move.l     a1,V_CUR_AD.w
relok79:
		addq.w     #1,V_CUR_XY1.w
relok80:
vt_l_column2:
		subq.w     #1,hid_cnt
vt_con_exit:
		rts

vt_char_col:
		tst.w      d0
		beq.s      vt_char_coljmp
		move.w     d0,d1
		add.w      d1,d1
		add.w      d0,d1
		jmp        vt_char_coljmp-2(pc,d1.w)
vt_char_coljmp:
		move.b     (a0),(a1)
		adda.w     a2,a1
		move.b     256(a0),(a1)
		adda.w     a2,a1
		move.b     512(a0),(a1)
		adda.w     a2,a1
		move.b     768(a0),(a1)
		adda.w     a2,a1
		move.b     1024(a0),(a1)
		adda.w     a2,a1
		move.b     1280(a0),(a1)
		adda.w     a2,a1
		move.b     1536(a0),(a1)
		adda.w     a2,a1
		move.b     1792(a0),(a1)
		adda.w     a2,a1
		move.b     2048(a0),(a1)
		adda.w     a2,a1
		move.b     2304(a0),(a1)
		adda.w     a2,a1
		move.b     2560(a0),(a1)
		adda.w     a2,a1
		move.b     2816(a0),(a1)
		adda.w     a2,a1
		move.b     3072(a0),(a1)
		adda.w     a2,a1
		move.b     3328(a0),(a1)
		adda.w     a2,a1
		move.b     3584(a0),(a1)
		adda.w     a2,a1
		move.b     3840(a0),(a1)
		rts

vt_char_col2:
		tst.w      d0
		beq.s      vt_char_coljmp2
		move.w     d0,d1
		add.w      d1,d1
		add.w      d1,d1
		add.w      d0,d1
		jmp        vt_char_coljmp2-2(pc,d1.w)
vt_char_coljmp2:
		move.b     (a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     256(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     512(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     768(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     1024(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     1280(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     1536(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     1792(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     2048(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     2304(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     2560(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     2816(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     3072(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     3328(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     3584(a0),d1
		not.b      d1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     3840(a0),d1
		not.b      d1
		move.b     d1,(a1)
		rts

vt_char_rcol0:
		moveq.l    #0,d1
		bra.s      vt_char_rcol1
vt_char_rcol:
		moveq.l    #-1,d1
vt_char_rcol1:
		add.w      d0,d0
		beq.s      vt_char_rcoljmp
		jmp        vt_char_rcoljmp(pc,d0.w)
vt_char_rcoljmp:
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		adda.w     a2,a1
		move.b     d1,(a1)
		lsr.w      #1,d0
		rts


/* **************************************************************************** */
/* ESC SEQUENZ abarbeiten */
/* **************************************************************************** */
vt_esc_seq:
		cmpi.w     #'Y',d1
		beq        vt_seq_Y
		move.w     d1,d2
		move.w     BYTES_LIN.w,d0
relok81:
		lsr.w      #2,d0
		movea.w    d0,a2
		movem.w    V_CUR_XY0.w,d0-d1
relok82:
		movea.l    V_CUR_AD.w,a1
relok83:
		move.l     convecs,mycon_state
		subi.w     #'A',d2
		cmpi.w     #12,d2
		bhi.s      vt_seq_tb
		add.w      d2,d2
		move.w     vt_seq_tab1(pc,d2.w),d2
		jmp        vt_seq_tab1(pc,d2.w)
vt_seq_tb:
		subi.w     #33,d2
		cmpi.w     #21,d2
		bhi.s      vt_seq_exit
		add.w      d2,d2
		move.w     vt_seq_tab2(pc,d2.w),d2
		jmp        vt_seq_tab2(pc,d2.w)
vt_seq_exit:
		rts

vt_seq_tab1:      DC.W vt_seq_A-vt_seq_tab1
                  DC.W vt_seq_B-vt_seq_tab1
                  DC.W vt_seq_C-vt_seq_tab1
                  DC.W vt_seq_D-vt_seq_tab1
                  DC.W vt_seq_E-vt_seq_tab1
                  DC.W vt_seq_exit-vt_seq_tab1
                  DC.W vt_seq_exit-vt_seq_tab1
                  DC.W vt_seq_H-vt_seq_tab1
                  DC.W vt_seq_I-vt_seq_tab1
                  DC.W vt_seq_J-vt_seq_tab1
                  DC.W vt_seq_K-vt_seq_tab1
                  DC.W vt_seq_L-vt_seq_tab1
                  DC.W vt_seq_M-vt_seq_tab1

vt_seq_tab2:      DC.W vt_seq_b-vt_seq_tab2
                  DC.W vt_seq_c-vt_seq_tab2
                  DC.W vt_seq_d-vt_seq_tab2
                  DC.W vt_seq_e-vt_seq_tab2
                  DC.W vt_seq_f-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_j-vt_seq_tab2
                  DC.W vt_seq_k-vt_seq_tab2
                  DC.W vt_seq_l-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_o-vt_seq_tab2
                  DC.W vt_seq_p-vt_seq_tab2
                  DC.W vt_seq_q-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_exit-vt_seq_tab2
                  DC.W vt_seq_v-vt_seq_tab2
                  DC.W vt_seq_w-vt_seq_tab2


/*
 * d0 Textspalte
 * d1 Textzeile
 * a1 Cursoradresse
 * a2 Bytes pro Zeile
 */
/* ALPHA CURSOR UP (VDI 5, ESCAPE 4)/ Cursor up (VT 52 ESC A) */
v_curup:
vt_seq_A:
		subq.w     #1,d1
		bra        set_cursor_xy

/* ALPHA CURSOR DOWN (VDI 5,ESCAPE 5)/ Cursor down (VT52 ESC B) */
v_curdown:
vt_seq_B:
		addq.w     #1,d1
		bra        set_cursor_xy

/* ALPHA CURSOR RIGHT (VDI 5, ESCAPE 6)/ Cursor right (VT52 ESC C) */
v_curright:
vt_seq_C:
		addq.w     #1,d0
		bra        set_cursor_xy

/* ALPHA CURSOR LEFT (VDI 5, ESCAPE 7)/ Cursor left (VT52 ESC D) */
v_curleft:
vt_seq_D:
		subq.w     #1,d0
		bra        set_cursor_xy

/* Clear screen (VT52 ESC E) */
vt_seq_E:
		bsr        cursor_off
		bsr        clear_screen
		bra.s      vt_seq_H_in

/* HOME ALPHA CURSOR (VDI 5, ESCAPE 8)/ Home Cursor (VT52 ESC H) */
v_curhome:
vt_seq_H:
		bsr        cursor_off
vt_seq_H_in:
		clr.l      V_CUR_XY0.w
relok84:
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok85:
		move.l     a1,V_CUR_AD.w
relok86:
		bra        cursor_on

/* Cursor up and insert (VT52 ESC I) */
vt_seq_I:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		subq.w     #1,d1
		blt        scroll_down_page
		suba.w     V_CEL_WR.w,a1 /* FIXME: V_CEL_WR is obsolete */
relok87:
		move.l     a1,V_CUR_AD.w
relok88:
		move.w     d1,V_CUR_XY1.w
relok89:
		rts

/* ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J) */
v_eeos:
vt_seq_J:
		bsr.s      vt_seq_K
		move.w     V_CUR_XY1.w,d1
relok90:
		move.w     V_CEL_MY.w,d2
relok91:
		sub.w      d1,d2
		beq.s      vt_seq_J_exit
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok92:
		addq.w     #1,d1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok93:
		adda.l     d1,a1
		move.w     d2,d7
		mulu.w     V_CEL_HT.w,d7
relok94:
		subq.w     #1,d7
		bra        clear_lines
vt_seq_J_exit:
		rts

/* ERASE TO END OF ALPHA TEXT LINE (VDI 5, ESCAPE 10) */
v_eeol:
/* Clear to end of line (VT52 ESC K) */
vt_seq_K:
		bsr        cursor_off
		move.w     V_CEL_MX.w,d2
relok95:
		sub.w      d0,d2
		bsr        clear_line_part
		bra        cursor_on

/* Insert line (VT52 ESC I) */
vt_seq_L:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok96:
		move.w     d7,d5
		sub.w      d1,d7
		beq.s      vt_seq_L_exit
		move.w     V_CEL_WR.w,d6 /* FIXME: V_CEL_WR is obsolete */
relok97:
		mulu.w     d6,d5
		movea.l    v_bas_ad.w,a0
		adda.w     V_CUR_OF.w,a0
relok98:
		adda.l     d5,a0
		lea.l      0(a0,d6.w),a1
		mulu.w     d6,d7
		bsr        scroll_page
vt_seq_L_exit:
		movea.l    V_CUR_AD.w,a1
relok99:
		bra        clear_line2

/* Delete Line (VT52 ESC M) */
vt_seq_M:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok100:
		sub.w      d1,d7
		beq        clear_line2
		move.w     V_CEL_WR.w,d6 /* FIXME: V_CEL_WR is obsolete */
relok101:
		lea.l      0(a1,d6.w),a0
		mulu.w     d6,d7
		bra        scroll_up2

/* Set cursor position (VT52 ESC Y) */
vt_seq_Y:
		move.l     #vt_set_y,mycon_state
		rts
/* y-Koordinate setzen */
vt_set_y:
		subi.w     #32,d1
		move.w     V_CUR_XY0.w,d0
relok102:
		move.l     #vt_set_x,mycon_state
		bra        set_cursor_xy
/* x-Koordinate setzen */
vt_set_x:
		subi.w     #32,d1
		move.w     d1,d0
		move.w     V_CUR_XY1.w,d1
relok103:
		move.l     convecs,mycon_state
		bra        set_cursor_xy

/* Foreground color (VT52 ESC b) */
vt_seq_b:
		move.l     #vt_set_b,mycon_state
		rts
vt_set_b:
		and.w      #15,d1
		move.w     d1,V_COL_FG.w
relok104:
		lea.l      vt_con0(pc),a0
		lea.l      vt_rawcon(pc),a1
		move.l     a0,convecs
		move.l     a1,convecs+4
		move.l     convecs,mycon_state
		rts
/* Background color (VT52 ESC c) */
vt_seq_c:
		move.l     #vt_set_c,mycon_state
		rts
vt_set_c:
		and.w      #15,d1
		move.w     d1,V_COL_BG.w
relok105:
		lea.l      vt_con0(pc),a0
		lea.l      vt_rawcon(pc),a1
		move.l     a0,convecs
		move.l     a1,convecs+4
		move.l     convecs,mycon_state
		rts

/* Erase to start of page (VT52 ESC d) */
vt_seq_d:
		bsr.s      vt_seq_o
		move.w     V_CUR_XY1.w,d1
relok106:
		beq.s      vt_seq_d_exit
		movem.l    d2-d7/a1-a6,-(a7)
		mulu.w     V_CEL_HT.w,d1
relok107:
		move.w     d1,d7
		subq.w     #1,d7
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok108:
		bra        clear_lines
vt_seq_d_exit:
		rts

/* Show cursor (VT52 ESC e) */
vt_seq_e:
		tst.w      hid_cnt
		beq.s      vt_seq_e_exit
		move.w     #1,hid_cnt
		bra        cursor_on
vt_seq_e_exit:
		rts

/* Hide cursor (VT52 ESC f) */
vt_seq_f:
		bra        cursor_off

/* Save cursor (VT52 ESC j) */
vt_seq_j:
		bset       #CURSOR_SAVED,V_STAT_0.w
relok109:
		move.l     V_CUR_XY0.w,V_SAV_XY.w
relok110:
		rts

/* Restore cursor (VT52 ESC k) */
vt_seq_k:
		movem.w    V_SAV_XY.w,d0-d1
relok111:
		bclr       #CURSOR_SAVED,V_STAT_0.w
relok112:
		bne        set_cursor_xy
		moveq.l    #0,d0
		moveq.l    #0,d1
		bra        set_cursor_xy

/* Erase line (VT52 ESC l) */
vt_seq_l:
		bsr        cursor_off
		bsr        set_x0
		bsr        clear_line
		bra        cursor_on

/* Erase to line start (VT52 ESC o) */
vt_seq_o:
		move.w     d0,d2
		subq.w     #1,d2
		bmi.s      vt_seq_o_exit
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok113:
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok114:
		adda.l     d1,a1
		bra        clear_line_part
vt_seq_o_exit:
		rts

/* REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p) */
v_rvon:
vt_seq_p:
		bset       #CURSOR_INVERSE,V_STAT_0.w
relok115:
		rts

/* REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q) */
v_rvoff:
vt_seq_q:
		bclr       #CURSOR_INVERSE,V_STAT_0.w
relok116:
		rts

/* Wrap at end of line (VT52 ESC v) */
vt_seq_v:
		bset       #CURSOR_WRAP,V_STAT_0.w
relok117:
		rts

/* Discard end of line (VT52 ESC w) */
vt_seq_w:
		bclr       #CURSOR_WRAP,V_STAT_0.w
relok118:
		rts

scroll_up_page:
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok119:
		movea.l    a1,a0
		move.w     V_CEL_WR.w,d7 /* FIXME: V_CEL_WR is obsolete */
relok120:
		adda.w     d7,a0
		mulu.w     V_CEL_MY.w,d7
relok121:
scroll_up2:
		pea.l      clear_line2(pc)
		tst.w      is_mste
		beq.s      scroll_up3
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
scroll_up3:
		movea.l    vgamode+vga_regbase(pc),a6
		move.b     #0x02,TS_I(a6)
		move.b     #0x0F,TS_D(a6)
		move.b     #0x05,GDC_I(a6)
		move.b     GDC_D(a6),d2
		move.b     d2,-(a7)
		and.b      0x000000FC.w,d2 /* BUG: # missing */
		or.b       #0x01,d2
		move.b     d2,GDC_D(a6)
		subq.l     #1,d7
		moveq.l    #31,d6
		and.w      d7,d6
		lsr.l      #5,d7
		eori.w     #31,d6
		add.w      d6,d6
		jmp        scroll_jmp(pc,d6.w)
scroll_jmp:
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		subq.l     #1,d7
		bpl.s      scroll_jmp
		move.b     (a7)+,GDC_D(a6)
		tst.w      is_mste
		beq.s      scroll_up4
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
scroll_up4:
		rts

scroll_down_page:
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a0
		adda.w     V_CUR_OF.w,a0
relok122:
		move.w     V_CEL_WR.w,d6 /* FIXME: V_CEL_WR is obsolete */
relok123:
		move.w     V_CEL_MY.w,d7
relok124:
		mulu.w     d6,d7
		adda.l     d7,a0
		lea.l      0(a0,d6.w),a1
		bsr.s      scroll_page
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok125:
		bra        clear_line2

scroll_page:
		tst.w      is_mste
		beq.s      scroll_page1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
scroll_page1:
		movea.l    vgamode+vga_regbase(pc),a6
		move.b     #0x02,TS_I(a6)
		move.b     #0x0F,TS_D(a6)
		move.b     #0x05,GDC_I(a6)
		move.b     GDC_D(a6),d2
		move.b     d2,-(a7)
		and.b      0x000000FC.w,d2 /* BUG: # missing */
		or.b       #0x01,d2
		move.b     d2,GDC_D(a6)
		subq.l     #1,d7
		moveq.l    #31,d6
		and.l      d7,d6
		lsr.l      #5,d7
		eori.w     #31,d6
		add.w      d6,d6
		jmp        scroll_pjmp(pc,d6.w)
scroll_pjmp:
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		subq.l     #1,d7
		bpl.s      scroll_pjmp
		move.b     (a7)+,GDC_D(a6)
		tst.w      is_mste
		beq.s      scroll_page2
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
scroll_page2:
		rts

memwrite_table4:
		dc.b 8,4,2,1

clear_line:
		movem.l    d2-d7/a1-a6,-(a7)
/* Eingabe: a1.l Zeilenadresse */
clear_line2:
		move.w     V_CEL_HT.w,d7
relok126:
		subq.w     #1,d7
clear_lines:
		move.w     V_CEL_MX.w,d4
relok127:
		addq.w     #1,d4
		move.w     V_COL_BG.w,d6
relok128:
		move.w     BYTES_LIN.w,d2
relok129:
		lsr.w      #2,d2
		movea.w    d2,a2
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      TS_I(a5),a5
		move.b     #0x02,(a5)+
		moveq.l    #3,d3
		suba.w     d4,a2
		subq.w     #4,d4
		lsr.w      #2,d4
		bcc.s      clear_lines1
		lea.l      clear_lines4(pc),a3
		move.w     d4,d5
		lsr.w      #7,d4
		not.w      d5
		and.w      #0x007F,d5
		add.w      d5,d5
		lea.l      clear_lines5(pc,d5.w),a4
		bra.s      clear_lines2
clear_lines1:
		move.w     d4,d5
		lsr.w      #7,d4
		not.w      d5
		and.w      #0x007F,d5
		add.w      d5,d5
		lea.l      clear_lines5(pc,d5.w),a3
clear_lines2:
		move.l     a1,-(a7)
		move.b     memwrite_table4(pc,d3.w),(a5)
		moveq.l    #0,d2
		lsr.w      #1,d6
		negx.l     d2
		move.w     d7,-(a7)
clear_lines3:
		move.w     d4,d5
		jmp        (a3)
clear_lines4:
		move.w     d2,(a1)+
		jmp        (a4)
clear_lines5:
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		move.l     d2,(a1)+
		dbf        d5,clear_lines5
		adda.w     a2,a1
		dbf        d7,clear_lines3
		move.w     (a7)+,d7
		movea.l    (a7)+,a1
		dbf        d3,clear_lines2
		movem.l    (a7)+,d2-d7/a1-a6
		rts

/*
 * Bildschirm loeschen
 * Eingaben
 *  -
 * Ausgaben
 * kein Register wird zerstoert
 */
clear_screen:
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok130:
		addq.w     #1,d7
		mulu.w     V_CEL_HT.w,d7
relok131:
		subq.w     #1,d7
		movea.l    v_bas_ad.w,a1
		adda.w     V_CUR_OF.w,a1
relok132:
		bra        clear_lines

/*
 * Bereich einer Textzeile loeschen
 * Eingaben
 * d2.w Spaltenanzahl -1
 * a1.l Adresse
 * a2.w Bytes pro Zeile
 * Ausgaben
 * d0-d2/a0-a1 werden zerstoert
 */
memwrite_table5:
		dc.b 8,4,2,1
memread_table5:
		dc.b 3,2,1,0

clear_line_part:
		movem.l    d3-d5/a3-a5,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
relok133:
		add.w      d0,d0
		move.w     V_COL_BG.w,d4
relok134:
		moveq.l    #3,d5
		movea.l    a1,a3
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x04,GDC_I(a5)
clear_line_part1:
		move.w     d2,d3
		movea.l    a3,a0
		move.b     memwrite_table5(pc,d5.w),TS_D(a5)
		move.b     memread_table5(pc,d5.w),GDC_D(a5)
		lea.l      vt_char_rcol0(pc),a4
		lsr.w      #1,d4
		bcc.s      clear_line_part2
		lea.l      vt_char_rcol(pc),a4
clear_line_part2:
		movea.l    a0,a1
		jsr        (a4)
		addq.l     #1,a0
		dbf        d3,clear_line_part2
		dbf        d5,clear_line_part1
		movem.l    (a7)+,d3-d5/a3-a5
		rts

/* **************************************************************************** */

/*
 * WK-Tabelle intialisieren
 * Eingaben
 * d1.l pb oder 0L
 * a6.l Workstation
 * Ausgaben
 * Die Workstation wird initialisert
 */
wk_init:
		move.l     vgamode+vga_xres(pc),res_x(a6)
		move.l     vgamode+vga_pixw(pc),pixel_width(a6)
		move.w     #DRV_PLANES-1,r_planes(a6)
		move.w     #15,colors(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation(pc),a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.w     res_x(a6),d0
		addq.w     #1,d0
		lsr.w      #3,d0
		move.w     res_y(a6),d1
		addq.w     #1,d1
		mulu.w     d1,d0
		lsl.l      #2,d0
		move.l     d0,bitmap_len(a6)
		move.l     global_ctable(pc),wk_ctab(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     p_fbox(a6),fbox_ptr
		move.l     p_fline(a6),fline_ptr
		move.l     p_hline(a6),hline_ptr
		move.l     p_vline(a6),vline_ptr
		move.l     p_line(a6),line_ptr
		move.l     p_bitblt(a6),bitblt_ptr
		move.l     p_expblt(a6),expblt_ptr
		move.l     p_textblt(a6),textblt_ptr
		move.l     p_escapes(a6),escape_ptr
		move.l     p_scanline(a6),scanline_ptr
		move.l     #fbox,p_fbox(a6)
		move.l     #fline,p_fline(a6)
		move.l     #hline,p_hline(a6)
		move.l     #vline,p_vline(a6)
		move.l     #line,p_line(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #expblt,p_expblt(a6)
		move.l     #textblt,p_textblt(a6)
		move.l     #v_escape,p_escapes(a6)
		move.l     #scanline,p_scanline(a6)
		move.l     #get_pixel,p_get_pixel(a6)
		move.l     #set_pixel,p_set_pixel(a6)
		move.l     #set_color_rgb,p_set_color_rgb(a6)
		moveq.l    #1,d0
		rts

wk_reset:
		rts

/* **************************************************************************** */

/*
 * RGB-Farbwert fuer einen VDI-Farbindex setzen
 * Vorgaben:
 * Register d0-d4/a0-a1 koennen veraendert werden
 * Eingaben:
 * d0.w Rot-Intensitaet von 0 - 1000
 * d1.w Gruen-Intensitaet von 0 - 1000
 * d2.w Blau-Intensitaet von 0 - 1000
 * d3.w VDI-Farbindex
 * a6.l Workstation
 * Ausgaben:
 */
set_color_rgb:
		movem.l    d3-d5/a2,-(a7)
		move.l     d0,d3
		move.l     d1,d4
		movea.l    vgamode+vga_regbase(pc),a1
		lea.l      DAC_D(a1),a2
		lea.l      DAC_IW(a1),a1
		moveq.l    #10,d5
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      set_color_rgb1
		moveq.l    #8,d5
set_color_rgb1:
		move.l     (a0)+,d0
		move.w     (a0)+,d1
		move.w     (a0)+,d2
		move.b     d3,(a1)
		lsr.w      d5,d0
		lsr.w      d5,d1
		lsr.w      d5,d2
		tst.w      graymode
		beq.s      set_color_rgb2
		add.w      d1,d0
		add.w      d0,d1
		lsl.w      #2,d1
		add.w      d1,d0
		add.w      d2,d2
		add.w      d2,d0
		lsr.w      #4,d0
		move.w     d0,d1
		move.w     d0,d2
set_color_rgb2:
		move.b     d0,(a2)
		move.b     d1,(a2)
		move.b     d2,(a2)
		addq.l     #1,d3
		cmp.l      d3,d4
		bge.s      set_color_rgb1
		movem.l    (a7)+,d3-d5/a2
		rts

/*
 * Pixel auslesen
 * Vorgaben:
 * Register d0-d1/a0 koennen veraendert werden
 * Eingaben:
 * d0.w x
 * d1.w y
 * a6.l Workstation
 * Ausgaben:
 * d0.l Farbwert
 */
get_pixel:
		movem.l    d2-d3/a1-a2,-(a7)
		tst.w      bitmap_width(a6)
		beq.s      get_pixel1
		movea.l    bitmap_addr(a6),a0
		muls.w     bitmap_width(a6),d1
		bra.s      get_pixel2
get_pixel1:
		movea.l    v_bas_ad.w,a0
		muls.w     BYTES_LIN.w,d1
relok135:
get_pixel2:
		lsr.l      #2,d1
		adda.l     d1,a0
		move.w     d0,d1
		lsr.w      #4,d1
		add.w      d1,d1
		adda.w     d1,a0
		moveq.l    #15,d1
		not.w      d0
		and.w      d0,d1
		moveq.l    #DRV_PLANES-1,d2
		moveq.l    #0,d0
		lea.l      pixel_readtable(pc),a1
		movea.l    vgamode+vga_regbase(pc),a2
		lea.l      GDC_I(a2),a2
		move.b     #0x04,(a2)+
get_pixel3:
		move.b     (a1)+,(a2)
		lsr.w      #1,d0
		move.w     (a0),d3
		btst       d1,d3
		beq.s      get_pixel4
		addq.w     #8,d0
get_pixel4:
		dbf        d2,get_pixel3
		movem.l    (a7)+,d2-d3/a1-a2
		rts

/*
 * Pixel setzen
 * Vorgaben:
 * Register d0-d1/a0 koennen veraendert werden
 * Eingaben:
 * d0.w x
 * d1.w y
 * d2.l Farbwert
 * a6.l Workstation
 * Ausgaben:
 */
pixel_readtable:
		dc.b 0,1,2,3

set_pixel:
		movem.l    d2-d3/a1-a2,-(a7)
		tst.w      bitmap_width(a6)
		beq.s      set_pixel1
		movea.l    bitmap_addr(a6),a0
		muls.w     bitmap_width(a6),d1
		bra.s      set_pixel2
set_pixel1:
		movea.l    v_bas_ad.w,a0
		muls.w     BYTES_LIN.w,d1
relok136:
set_pixel2:
		lsr.l      #2,d1
		adda.l     d1,a0
		move.w     d0,d1
		lsr.w      #4,d1
		add.w      d1,d1
		adda.w     d1,a0
		not.w      d0
		andi.w     #15,d0
		moveq.l    #0,d1
		bset       d0,d1
		move.w     d1,d0
		not.w      d0
		moveq.l    #DRV_PLANES-1,d3
		lea.l      pixel_readtable(pc),a1
		movea.l    vgamode+vga_regbase(pc),a2
		lea.l      GDC_I(a2),a2
		move.b     #0x04,(a2)+
set_pixel3:
		move.b     (a1)+,(a2)
		ror.w      #1,d2
		bcc.s      set_pixel4
		or.w       d1,(a0)
		adda.l     d4,a0
		dbf        d3,set_pixel3
		movem.l    (a7)+,d2-d3/a1-a2
		rts
set_pixel4:
		and.w      d0,(a0)
		adda.l     d4,a0
		dbf        d3,set_pixel3
		movem.l    (a7)+,d2-d3/a1-a2
		rts

/* **************************************************************************** */
                  /* '7. Escapes' */

/*
 * VDI-Escapes abarbeiten
 * Vorgaben:
 * Register d0/a0-a1 koennen veraendert werden
 * Eingaben:
 * d1.l pb
 * a0.l pb
 * a6.l Workstation
 * Ausgaben:
 */
v_escape:
		movea.l    pb_control(a0),a1
		move.w     v_opcode2(a1),d0
		cmpi.w     #V_CURTEXT,d0
		beq        v_curtext
		cmp.w      #VQ_CURADDRESS,d0
		bhi.s      v_escape_unof
		movem.l    d1-d7/a2-a5,-(a7)
		movem.l    pb_intin(a0),a2-a5
		add.w      d0,d0
		move.w     v_escape_tab(pc,d0.w),d2
		movea.l    a2,a5
		movea.l    a1,a0
		movem.w    V_CUR_XY0.w,d0-d1
relok137:
		movea.l    V_CUR_AD.w,a1
relok138:
		movea.w    BYTES_LIN.w,a2
relok139:
		jsr        v_escape_tab(pc,d2.w)
		movem.l    (a7)+,d1-d7/a2-a5
v_escape_exit:
		rts
v_escape_unof:
		movea.l    escape_ptr(pc),a1
		jmp        (a1)

v_escape_tab:     DC.W v_escape_exit-v_escape_tab
                  DC.W vq_chcells-v_escape_tab /* 1 */
                  DC.W v_exit-v_escape_tab /* 2 */
                  DC.W v_enter_cur-v_escape_tab /* 3 */
                  DC.W v_curup-v_escape_tab /* 4 */
                  DC.W v_curdown-v_escape_tab /* 5 */
                  DC.W v_curright-v_escape_tab /* 6 */
                  DC.W v_curleft-v_escape_tab /* 7 */
                  DC.W v_curhome-v_escape_tab /* 8 */
                  DC.W v_eeos-v_escape_tab /* 9 */
                  DC.W v_eeol-v_escape_tab /* 10 */
                  DC.W v_curaddress-v_escape_tab /* 11 */
                  DC.W v_curtext-v_escape_tab /* 12 */
                  DC.W v_rvon-v_escape_tab /* 13 */
                  DC.W v_rvoff-v_escape_tab /* 14 */
                  DC.W vq_curaddress-v_escape_tab /* 15 */

/* INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS (VDI 5, ESCAPE 1) */
vq_chcells:
		move.l     V_CEL_MX.w,d3
relok140:
		addi.l     #0x00010001,d3
		swap       d3
		move.l     d3,(a4)
		move.w     #2,v_nintout(a0)
		rts

/* EXIT ALPHA MODE (VDI 5, ESCAPE 2) */
v_exit:
		addq.w     #1,hid_cnt
		bclr       #CURSOR_STATE,V_STAT_0.w
relok141:
		bra        clear_screen

/* ENTER ALPHA MODE (VDI 5, ESCAPE 3) */
v_enter_cur:
		clr.l      V_CUR_XY0.w
relok142:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok143:
		move.l     convecs(pc),mycon_state
		bsr        clear_screen
		bclr       #CURSOR_STATE,V_STAT_0.w
relok144:
		move.w     #1,hid_cnt
		bra        cursor_on

/* DIRECT ALPHA CURSOR ADDRESS (VDI 5, ESCAPE 11) */
v_curaddress:
		move.w     (a5)+,d1
		move.w     (a5)+,d0
		subq.w     #1,d0
		subq.w     #1,d1
		bra        set_cursor_xy

/* INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15) */
vq_curaddress:
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     d1,(a4)+
		move.w     d0,(a4)+
		move.w     #2,v_nintout(a0)
		rts

/*
 * Textausgabe ohne Clipping
 * Vorgaben:
 * Register d0-d7/a0-a5 koennen veraendert werden
 * Eingaben:
 * d0.w xq (linke x-Koordinate des Quellrechtecks)
 * d1.w yq (obere y-Koordinate des Quellrechtecks)
 * d2.w xz (linke x-Koordinate des Zielrechtecks)
 * d3.w yz (obere y-Koordinate des Zielrechtecks)
 * d4.w dx (Breite -1)
 * d5.w dy (Hoehe -1)
 * a0.l Quellblockadresse
 * a2.w Bytes pro Quellzeile
 * a6.l Workstation
 * Ausgaben:
 */
textblt:
		movea.l    v_bas_ad.w,a1
		movea.w    BYTES_LIN.w,a3
relok145:
		tst.w      bitmap_width(a6)
		beq.s      textblt1
		movea.l    bitmap_addr(a6),a1
		movea.w    bitmap_width(a6),a3
		sub.w      bitmap_off_x(a6),d2
		sub.w      bitmap_off_y(a6),d3
textblt1:
		move.l     a0,r_saddr(a6)
		move.l     a1,r_daddr(a6)
		move.w     a2,r_swidth(a6)
		move.w     a3,r_dwidth(a6)
		clr.l      r_splane_len(a6)
		move.l     bitmap_len(a6),r_dplane_len(a6)
		move.w     wr_mode(a6),r_wmode(a6)
		clr.w      r_splanes(a6)
		move.w     r_planes(a6),r_dplanes(a6)
		bra.s      expblt

/*
 * Bitblocktransfer ohne Clipping
 * Vorgaben:
 * Register d0-d7/a0-a6 koennen veraendert werden
 * Eingaben:
 * Vorgaben:
 * Register d0-d7/a0-a5 koennen veraendert werden
 * Eingaben:
 * Die Paramter 4(sp) bis 18(sp) sind nur vorhanden, wenn skaliert werden muss
 * d0.w qx, linke x-Koordinate des Quellrechtecks
 * d1.w qy, obere y-Koordinate des Quellrechtecks
 * d2.w zx, linke x-Koordinate des Zielrechtecks
 * d3.w zy, obere y-Koordinate des Zielrechtecks
 * d4.w qdx, Breite der Quelle - 1
 * d5.w qdy, Hoehe der Quelle -1
 * d6.w zdx, Breite des Ziels - 1
 * d7.w zdy, Hoehe des Ziels -1
 * a6.l Workstation
 * 4(sp).w qx ohne Clipping
 * 6(sp).w qy ohne Clipping
 * 8(sp).w zx ohne Clipping
 * 10(sp).w zy ohne Clipping
 * 12(sp).w qdx ohne Clipping
 * 14(sp).w qdy ohne Clipping
 * 16(sp).w zdx ohne Clipping
 * 18(sp).w zdy ohne Clipping
 * Ausgaben:
 */
bitblt:
		cmp.w      d4,d6
		bne        bitblt_scale
		cmp.w      d5,d7
		bne        bitblt_scale
		bclr       #4,r_wmode+1(a6)
		bne.s      expblt
		moveq.l    #15,d7
		lea.l      r_wmode(a6),a4
		and.w      (a4),d7
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		bra.s      expblt1

/* **************************************************************************** */
                  /* 'Expand-Blt' */

/*
 * expandierender Bitblocktransfer, eine Ebene unter Vorgabe von
 * Vorder- und Hintergrundfarbe expandieren
 * Vorgaben:
 * Register d0-d7/a0-a5.l koennen veraendert werden
 * Eingaben:
 * d0.w xq
 * d1.w yq
 * d2.w xz
 * d3.w yz
 * d4.w dx
 * d5.w dy
 * a6.l r_wmode, r_fgcol, r_bgcol, r_saddr, r_daddr, r_swidth, r_dwidth, r_dplanes
 * Ausgaben:
 */
expblt_modes:     DC.B 0,12,3,15          /* MD_REPLACE */
                  DC.B 4,4,7,7            /* MD_TRANS */
                  DC.B 6,6,6,6            /* MD_XOR */
                  DC.B 1,13,1,13          /* MD_ERASE */

expblt:
		moveq.l    #3,d7
		and.w      r_wmode(a6),d7
		add.w      d7,d7
		add.w      d7,d7
		move.l     expblt_modes(pc,d7.w),r_wmode(a6)
		clr.l      r_splane_len(a6)
expblt1:
		movea.l    r_saddr(a6),a0
		movea.l    r_daddr(a6),a1
		movea.l    vgamode+vga_membase(pc),a2
		cmpa.l     a2,a0
		bne.s      expblt2
		clr.l      r_splane_len(a6)
expblt2:
		cmpa.l     a2,a1
		bne.s      expblt3
		clr.l      r_dplane_len(a6)
expblt3:
		move.l     r_splane_len(a6),d6
		lsr.l      #2,d6
		move.l     d6,r_splane_len(a6)
		move.l     r_dplane_len(a6),d6
		lsr.l      #2,d6
		move.l     d6,r_dplane_len(a6)
		addq.w     #1,r_splanes(a6)
		addq.w     #1,r_dplanes(a6)
		moveq.l    #0,d6
		moveq.l    #0,d7
		move.w     r_swidth(a6),d6
		move.w     r_dwidth(a6),d7
		divu.w     r_splanes(a6),d6
		divu.w     r_dplanes(a6),d7
		move.w     d6,r_swidth(a6)
		move.w     d7,r_dwidth(a6)
		movea.w    d6,a2                /* src bytes per line */
		movea.w    d7,a3                /* dst bytes per line */

		mulu.w     d1,d6                /* * y-src */
		adda.l     d6,a0                /* start of line */
		move.w     d0,d6                /* x-src */
		lsr.w      #4,d6
		add.w      d6,d6
		adda.w     d6,a0                /* src address */

		mulu.w     d3,d7                /* * y-dst */
		adda.l     d7,a1                /* start of line */
		move.w     d2,d7                /* x-dst */
		lsr.w      #4,d7
		add.w      d7,d7
		adda.w     d7,a1                /* dst address */

		cmpa.l     a1,a0                /* src addreess > dst address */
		bhi.s      expblt5
		beq.s      bitblt_equal

		adda.w     a2,a0
		cmpa.l     a0,a1                /* copy inside a line? */
		bcs        bitblt_dec
		suba.w     a2,a0

		move.w     a2,d6
		mulu.w     d5,d6
		adda.l     d6,a0                /* last address of source block */
		move.w     a3,d6
		mulu.w     d5,d6
		adda.l     d6,a1                /* last address of dest block */

		move.w     a2,d6
		neg.w      d6
		movea.w    d6,a2                /* negate source width */
		move.w     a3,d6
		neg.w      d6
		movea.w    d6,a3                /* negate dst width */
		neg.w      r_swidth(a6)
		neg.w      r_dwidth(a6)
		bra.s      expblt5

bitblt_equal:
		moveq.l    #15,d6
		and.w      d0,d6
		movea.w    d6,a4
		moveq.l    #15,d6
		and.w      d2,d6
		sub.w      a4,d6
		bgt        bitblt_dec           /* predecrement when moving ro right */
		bne.s      expblt5
		cmpa.w     a2,a3
		bgt        bitblt_dec

expblt5:
		movea.l    vgamode+vga_membase(pc),a4 /* inside graphic card memory? */
		movea.l    a4,a5
		adda.l     #VGA_MEMSIZE,a5
		cmpa.l     a4,a0
		bcs.s      expblt6
		cmpa.l     a5,a0
		bcc.s      expblt6
		clr.l      r_splane_len(a6)
expblt6:
		cmpa.l     a4,a1
		bcs.s      expblt7
		cmpa.l     a5,a1
		bcc.s      expblt7
		clr.l      r_dplane_len(a6)
expblt7:
		move.w     r_dplanes(a6),d7
		cmp.w      r_splanes(a6),d7
		bne.s      expblt8
		subq.w     #4,d7
		bne.s      expblt8
		move.l     r_splane_len(a6),d7
		or.l       r_dplane_len(a6),d7
		bne.s      expblt8
		tst.l      r_fg_pixel(a6)
		bne.s      expblt8
		tst.l      r_bg_pixel(a6)
		bne.s      expblt8
		cmpi.b     #S_ONLY,r_wmode(a6)
		bne.s      expblt8
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d0,d6
		and.w      d2,d7
		cmp.w      d6,d7
		beq        bitblt_sonly_inc
expblt8:
		moveq.l    #15,d6               /* for masking */
		and.w      d6,d0
		move.w     d0,d7
		add.w      d4,d7
		lsr.w      #4,d7                /* src word count -1 */

		move.w     d2,d3
		and.w      d6,d3
		sub.w      d3,d0                /* shift to left */

		move.w     d2,d1
		and.w      d6,d1
		add.w      d4,d1
		lsr.w      #4,d1                /* dst word count - 1 */

		sub.w      d1,d7                /* src count - dst count */

		add.w      d2,d4
		not.w      d4
		and.w      d6,d4
		moveq.l    #-1,d3
		lsl.w      d4,d3                /* endmask */
		and.w      d2,d6
		moveq.l    #-1,d2
		lsr.w      d6,d2                /* startmask */

		move.w     d1,d4
		add.w      d4,d4
		suba.w     d4,a2                /* distance to next src line */
		suba.w     d4,a3                /* distance to next dst line */

		move.w     d7,d4                /* src count - dst count */

		moveq.l    #4,d6                /* jmp offset for reading first word */
		moveq.l    #0,d7                /* jmp offset for reading last word */
		lea.l      blt_inc_tab(pc),a4

		tst.w      d0                   /* no shifts? */
		beq.s      blt_inc_jmp
		blt.s      blt_inc_right
		lea.l      blt_inc_l_tab(pc),a4
		tst.w      d1                   /* only one dst word? */
		bne.s      blt_inc_l_end
		tst.w      d4                   /* only one src word? */
		bne.s      blt_inc_l_end
		moveq.l    #10,d6               /* only read one start word */
		bra.s      blt_inc_jmp
blt_inc_l_end:
		moveq.l    #4,d6                /* read 2 start words */
		subq.w     #2,a2                /* 2 more source bytes */
		tst.w      d4                   /* more src than dst words? */
		bgt.s      blt_inc_l_shifts
		moveq.l    #2,d7                /* no extra endword when equal */
blt_inc_l_shifts:
		cmp.w      #8,d0                /* not more than 8 shifts to left? */
		ble.s      blt_inc_jmp
		lea.l      blt_inc_r_tab(pc),a4
		subq.w     #1,d0
		eori.w     #15,d0               /* shifts to right */
		bra.s      blt_inc_jmp

blt_inc_right:
		lea.l      blt_inc_r_tab(pc),a4
		neg.w      d0                   /* shifts to right */
		moveq.l    #8,d6                /* read only 1 startword */
		/*
		tst.w      d1
		beq        blt_inc_jmp
		*/
		tst.w      d4                   /* less dst than src words? */
		bpl.s      blt_inc_r_shifts
		moveq.l    #2,d7                /* no extra endword */
blt_inc_r_shifts:
		cmpi.w     #8,d0                /* not more than 8 shifts to right? */
		ble.s      blt_inc_jmp
		lea.l      blt_inc_l_tab(pc),a4
		subq.w     #1,d0
		eori.w     #15,d0               /* shifts to left */

blt_inc_jmp:
		swap       d7
		subq.w     #2,d1
		cmp.w      #-2,d1
		bne.s      expblt14
		and.w      d3,d2
		moveq.l    #0,d3
		subq.w     #2,a2
		subq.w     #2,a3
expblt14:
		move.w     d5,-(a7)
		moveq.l    #15,d4
		cmp.w      d4,d5
		bge.s      expblt15
		move.w     d5,d4
expblt15:
		move.w     d4,d5
		move.w     r_dplanes(a6),d7
		movem.l    a0-a1,-(a7)
		move.l     r_fg_pixel(a6),-(a7)
		move.l     r_bg_pixel(a6),-(a7)
		bra.s      blt_inc_next
blt_inc_loop:
		move.l     a4,-(a7)
		clr.w      d4
		lsr.w      r_fg_pixel+2(a6)     /* foreground color bit */
		addx.w     d4,d4
		lsr.w      r_bg_pixel+2(a6)     /* background color bit */
		addx.w     d4,d4
		lea.l      r_wmode(a6),a4
		move.b     0(a4,d4.w),d4        /* logical op */
		movea.l    vgamode+vga_regbase(pc),a4
		move.b     #0x02,TS_I(a4)
		move.b     #0x04,GDC_I(a4)
		move.b     memwrite_table6(pc,d7.w),TS_D(a4)
		move.b     memread_table6(pc,d7.w),GDC_D(a4)
		movea.l    (a7),a4
		lsl.w      #3,d4
		adda.w     d4,a4                /* pointer to jmp table */
		movem.l    d5-d7/a0-a1,-(a7)
		swap       d7
		move.w     (a4)+,d4             /* offset to bitblt function */
		add.w      d4,d6                /* offset for first jump */
		add.w      (a4)+,d7             /* offset for 2nd jump */
		cmp.w      #-2,d1               /* move only 1 word? */
		bne.s      blt_inc_offsets
		move.w     (a4),d7              /* do not read/write endwort */
blt_inc_offsets:
		lea.l      blt_inc_tab(pc),a4
		movea.l    a4,a5
		adda.w     d6,a4
		adda.w     d7,a5
		jsr        blt_inc_tab(pc,d4.w)
		movem.l    (a7)+,d5-d7/a0-a1/a4
		adda.l     r_splane_len(a6),a0  /* next source plane */
		adda.l     r_dplane_len(a6),a1  /* next dest plane */
blt_inc_next:
		dbf        d7,blt_inc_loop
		move.l     (a7)+,r_bg_pixel(a6)
		move.l     (a7)+,r_fg_pixel(a6)
		movem.l    (a7)+,a0-a1
		move.w     r_swidth(a6),d4
		asl.w      #4,d4
		adda.w     d4,a0
		move.w     r_dwidth(a6),d4
		asl.w      #4,d4
		adda.w     d4,a1
		move.w     (a7)+,d5
		sub.w      #16,d5
		bpl        expblt14
		rts

memwrite_table6:
	dc.b 8,4,2,1
memread_table6:
	dc.b 3,2,1,0


blt_inc_tab:
	dc.w blt0inc-blt_inc_tab,blt0inc4-blt_inc_tab,blt0inc5-blt_inc_tab,0
	dc.w blt1inc-blt_inc_tab,blt1inc3-blt_inc_tab,blt1inc4-blt_inc_tab,0
	dc.w blt2inc-blt_inc_tab,blt2inc3-blt_inc_tab,blt2inc4-blt_inc_tab,0
	dc.w blt3inc-blt_inc_tab,0,0,0
	dc.w blt4inc-blt_inc_tab,blt4inc3-blt_inc_tab,blt4inc4-blt_inc_tab,0
	dc.w blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,0
	dc.w blt6inc-blt_inc_tab,blt6inc3-blt_inc_tab,blt6inc4-blt_inc_tab,0
	dc.w blt7inc-blt_inc_tab,blt7inc3-blt_inc_tab,blt7inc4-blt_inc_tab,0
	dc.w blt8inc-blt_inc_tab,blt8inc3-blt_inc_tab,blt8inc4-blt_inc_tab,0
	dc.w blt9inc-blt_inc_tab,blt9inc3-blt_inc_tab,blt9inc4-blt_inc_tab,0
	dc.w blt10inc-blt_inc_tab,blt10inc4-blt_inc_tab,blt10inc5-blt_inc_tab,0
	dc.w blt11inc-blt_inc_tab,blt11inc3-blt_inc_tab,blt11inc4-blt_inc_tab,0
	dc.w blt12inc-blt_inc_tab,blt12inc3-blt_inc_tab,blt12inc4-blt_inc_tab,0
	dc.w blt13inc-blt_inc_tab,blt13inc3-blt_inc_tab,blt13inc4-blt_inc_tab,0
	dc.w blt14inc-blt_inc_tab,blt14inc3-blt_inc_tab,blt14inc4-blt_inc_tab,0
	dc.w blt15inc-blt_inc_tab,blt15inc4-blt_inc_tab,blt15inc5-blt_inc_tab,0

blt_inc_l_tab:
	dc.w blt0inc-blt_inc_tab,blt0inc4-blt_inc_tab,blt0inc5-blt_inc_tab,0
	dc.w blt1incl-blt_inc_tab,blt1incl3-blt_inc_tab,blt1incl4-blt_inc_tab,0
	dc.w blt2incl-blt_inc_tab,blt2incl3-blt_inc_tab,blt2incl4-blt_inc_tab,0
	dc.w blt3incl-blt_inc_tab,blt3incl3-blt_inc_tab,blt3incl4-blt_inc_tab,0
	dc.w blt4incl-blt_inc_tab,blt4incl3-blt_inc_tab,blt4incl4-blt_inc_tab,0
	dc.w blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,0
	dc.w blt6incl-blt_inc_tab,blt6incl3-blt_inc_tab,blt6incl4-blt_inc_tab,0
	dc.w blt7incl-blt_inc_tab,blt7incl3-blt_inc_tab,blt7incl4-blt_inc_tab,0
	dc.w blt8incl-blt_inc_tab,blt8incl3-blt_inc_tab,blt8incl4-blt_inc_tab,0
	dc.w blt9incl-blt_inc_tab,blt9incl3-blt_inc_tab,blt9incl4-blt_inc_tab,0
	dc.w blt10inc-blt_inc_tab,blt10inc4-blt_inc_tab,blt10inc5-blt_inc_tab,0
	dc.w blt11incl-blt_inc_tab,blt11incl3-blt_inc_tab,blt11incl4-blt_inc_tab,0
	dc.w blt12incl-blt_inc_tab,blt12incl3-blt_inc_tab,blt12incl4-blt_inc_tab,0
	dc.w blt13incl-blt_inc_tab,blt13incl4-blt_inc_tab,blt13incl5-blt_inc_tab,0
	dc.w blt14incl-blt_inc_tab,blt14incl3-blt_inc_tab,blt14incl4-blt_inc_tab,0
	dc.w blt15inc-blt_inc_tab,blt15inc4-blt_inc_tab,blt15inc5-blt_inc_tab,0

blt_inc_r_tab:
	dc.w blt0inc-blt_inc_tab,blt0inc4-blt_inc_tab,blt0inc5-blt_inc_tab,0
	dc.w blt0incr-blt_inc_tab,blt0incr3-blt_inc_tab,blt0incr4-blt_inc_tab,0
	dc.w blt2incr-blt_inc_tab,blt2incr3-blt_inc_tab,blt2incr4-blt_inc_tab,0
	dc.w blt3incr-blt_inc_tab,blt3incr3-blt_inc_tab,blt3incr4-blt_inc_tab,0
	dc.w blt4incr-blt_inc_tab,blt4incr3-blt_inc_tab,blt4incr4-blt_inc_tab,0
	dc.w blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,blt5inc-blt_inc_tab,0
	dc.w blt6incr-blt_inc_tab,blt6incr3-blt_inc_tab,blt6incr4-blt_inc_tab,0
	dc.w blt7incr-blt_inc_tab,blt7incr3-blt_inc_tab,blt7incr4-blt_inc_tab,0
	dc.w blt8incr-blt_inc_tab,blt8incr3-blt_inc_tab,blt8incr4-blt_inc_tab,0
	dc.w blt9incr-blt_inc_tab,blt9incr3-blt_inc_tab,blt9incr4-blt_inc_tab,0
	dc.w blt10inc-blt_inc_tab,blt10inc4-blt_inc_tab,blt10inc5-blt_inc_tab,0
	dc.w blt11incr-blt_inc_tab,blt11incr3-blt_inc_tab,blt11incr4-blt_inc_tab,0
	dc.w blt12incr-blt_inc_tab,blt12incr3-blt_inc_tab,blt12incr4-blt_inc_tab,0
	dc.w blt13incr-blt_inc_tab,blt13incr3-blt_inc_tab,blt13incr4-blt_inc_tab,0
	dc.w blt14incr-blt_inc_tab,blt14incr3-blt_inc_tab,blt14incr4-blt_inc_tab,0
	dc.w blt15inc-blt_inc_tab,blt15inc4-blt_inc_tab,blt15inc5-blt_inc_tab,0

blt0inc:
		not.w      d2
		not.w      d3
		moveq.l    #0,d7
		lea.l      blt0inc5(pc),a5
		cmp.w      #-1,d3
		beq.s      blt0inc1
		lea.l      blt0inc4(pc),a5
blt0inc1:
		and.w      d2,(a1)+
		move.w     d1,d4
		bmi.s      blt0inc3
blt0inc2:
		move.w     d7,(a1)+
		dbf        d4,blt0inc2
blt0inc3:
		jmp        (a5)
blt0inc4:
		and.w      d3,(a1)
blt0inc5:
		adda.w     a3,a1
		dbf        d5,blt0inc1
		not.w      d2
		not.w      d3
		rts

blt1inc:
		move.w     (a0)+,d6
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt1inc2
blt1inc1:
		move.w     (a0)+,d6
		and.w      d6,(a1)+
		dbf        d4,blt1inc1
blt1inc2:
		jmp        (a5)
blt1inc3:
		move.w     (a0),d6
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
blt1inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt1inc
		rts

blt0incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt0incr2
blt0incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d6,(a1)+
		dbf        d4,blt0incr1
blt0incr2:
		swap       d7
		jmp        (a5)
blt0incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		not.w      d3
		or.w       d3,d7
		not.w      d3
		and.w      d7,(a1)
blt0incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt0incr
		rts

blt1incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt1incl2
blt1incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d6,(a1)+
		dbf        d4,blt1incl1
blt1incl2:
		jmp        (a5)
blt1incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		not.w      d3
		or.w       d3,d7
		not.w      d3
		and.w      d7,(a1)
blt1incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt1incl
		rts

blt2inc:
		move.w     (a0)+,d6
		eor.w      d2,(a1)
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt2inc2
blt2inc1:
		move.w     (a0)+,d6
		not.w      (a1)
		and.w      d6,(a1)+
		dbf        d4,blt2inc1
blt2inc2:
		jmp        (a5)
blt2inc3:
		move.w     (a0),d6
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
blt2inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt2inc
		rts

blt2incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		eor.w      d2,(a1)
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt2incr2
blt2incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      (a1)
		and.w      d6,(a1)+
		dbf        d4,blt2incr1
blt2incr2:
		swap       d7
		jmp        (a5)
blt2incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d7
		not.w      d3
		and.w      d7,(a1)
blt2incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt2incr
		rts

blt2incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		eor.w      d2,(a1)
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt2incl2
blt2incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      (a1)
		and.w      d6,(a1)+
		dbf        d4,blt2incl1
blt2incl2:
		jmp        (a5)
blt2incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d7
		not.w      d3
		and.w      d7,(a1)
blt2incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt2incl
		rts

blt3inc:
		move.w     d1,d4
		bmi        blt3inc7
		move.w     d1,-(a7)
		lsr.w      #1,d4
		bcs.s      blt3inc2
		lea.l      blt3inc4(pc),a4
		bne.s      blt3inc1
		lea.l      blt3inc6(pc),a5
		bra.s      blt3inc3
blt3inc1:
		subq.w     #1,d4
		move.w     d4,d0
		lsr.w      #4,d4
		move.w     d4,d1
		not.w      d0
		andi.w     #15,d0
		add.w      d0,d0
		lea.l      blt3inc5(pc,d0.w),a5
		bra.s      blt3inc3
blt3inc2:
		move.w     d4,d0
		lsr.w      #4,d4
		move.w     d4,d1
		not.w      d0
		andi.w     #15,d0
		add.w      d0,d0
		lea.l      blt3inc5(pc,d0.w),a4
blt3inc3:
		move.w     (a0)+,d6
		not.w      d6
		and.w      d2,d6
		or.w       d2,(a1)
		eor.w      d6,(a1)+
		move.w     d1,d4
		jmp        (a4)
blt3inc4:
		move.w     (a0)+,(a1)+
		jmp        (a5)
blt3inc5:
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		move.l     (a0)+,(a1)+
		dbf        d4,blt3inc5
blt3inc6:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		or.w       d3,(a1)
		eor.w      d6,(a1)
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt3inc3
		move.w     (a7)+,d1
		rts
blt3inc7:
		move.w     d2,-(a7)
		move.w     d3,-(a7)
		addq.w     #2,a2
		addq.w     #2,a3
		tst.w      d3
		beq.s      blt3inc9
		swap       d2
		move.w     d3,d2
		move.l     d2,d3
		not.l      d3
blt3inc8:
		move.l     (a0),d6
		and.l      d2,d6
		and.l      d3,(a1)
		or.l       d6,(a1)
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt3inc8
		subq.w     #2,a2
		subq.w     #2,a3
		move.w     (a7)+,d3
		move.w     (a7)+,d2
		rts
blt3inc9:
		move.w     d2,d3
		not.w      d3
blt3inc10:
		move.w     (a0),d6
		and.w      d2,d6
		and.w      d3,(a1)
		or.w       d6,(a1)
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt3inc10
		subq.w     #2,a2
		subq.w     #2,a3
		move.w     (a7)+,d3
		move.w     (a7)+,d2
		rts

blt3incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		swap       d7
		ror.l      d0,d6
		not.w      d6
		and.w      d2,d6
		or.w       d2,(a1)
		eor.w      d6,(a1)+
		swap       d5
		move.w     d1,d5
		bmi.s      blt3incr2
		lsr.w      #1,d5
		bcs.s      blt3incr1
		move.w     (a0)+,d7
		move.l     d7,d6
		swap       d7
		ror.l      d0,d6
		move.w     d6,(a1)+
		subq.w     #1,d5
		bmi.s      blt3incr2
blt3incr1:
		move.l     d7,d6
		move.l     (a0)+,d7
		move.l     d7,d4
		swap       d7
		move.w     d7,d6
		ror.l      d0,d6
		ror.l      d0,d4
		swap       d6
		move.w     d4,d6
		move.l     d6,(a1)+
		dbf        d5,blt3incr1
blt3incr2:
		swap       d5
		jmp        (a5)
blt3incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		not.w      d7
		and.w      d3,d7
		or.w       d3,(a1)
		eor.w      d7,(a1)
blt3incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt3incr
		rts

blt3incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d2,d6
		or.w       d2,(a1)
		eor.w      d6,(a1)+
		swap       d5
		move.w     d1,d5
		bmi.s      blt3incl2
		lsr.w      #1,d5
		bcs.s      blt3incl1
		move.w     (a0)+,d7
		swap       d7
		move.l     d7,d6
		rol.l      d0,d6
		move.w     d6,(a1)+
		subq.w     #1,d5
		bmi.s      blt3incl2
blt3incl1:
		move.l     d7,d6
		move.l     (a0)+,d7
		swap       d7
		move.w     d7,d6
		move.l     d7,d4
		rol.l      d0,d6
		rol.l      d0,d4
		move.w     d4,d6
		move.l     d6,(a1)+
		dbf        d5,blt3incl1
blt3incl2:
		swap       d5
		jmp        (a5)
blt3incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		not.w      d7
		and.w      d3,d7
		or.w       d3,(a1)
		eor.w      d7,(a1)
blt3incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt3incl
		rts

blt4inc:
		move.w     (a0)+,d6
		and.w      d2,d6
		not.w      d6
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt4inc2
blt4inc1:
		move.w     (a0)+,d6
		not.w      d6
		and.w      d6,(a1)+
		dbf        d4,blt4inc1
blt4inc2:
		jmp        (a5)
blt4inc3:
		move.w     (a0),d6
		and.w      d3,d6
		not.w      d6
		and.w      d6,(a1)
blt4inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt4inc
		rts

blt4incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d2,d6
		not.w      d6
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt4incr2
blt4incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d6,(a1)+
		dbf        d4,blt4incr1
blt4incr2:
		swap       d7
		jmp        (a5)
blt4incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		and.w      d3,d7
		not.w      d7
		and.w      d7,(a1)
blt4incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt4incr
		rts

blt4incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d2,d6
		not.w      d6
		and.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt4incl2
blt4incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d6,(a1)+
		dbf        d4,blt4incl1
blt4incl2:
		jmp        (a5)
blt4incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		and.w      d3,d7
		not.w      d7
		and.w      d7,(a1)
blt4incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt4incl
		rts

blt5inc:
		rts

blt6inc:
		move.w     (a0)+,d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt6inc2
blt6inc1:
		move.w     (a0)+,d6
		eor.w      d6,(a1)+
		dbf        d4,blt6inc1
blt6inc2:
		jmp        (a5)
blt6inc3:
		move.w     (a0),d6
		and.w      d3,d6
		eor.w      d6,(a1)
blt6inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt6inc
		rts

blt6incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt6incr2
blt6incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		eor.w      d6,(a1)+
		dbf        d4,blt6incr1
blt6incr2:
		swap       d7
		jmp        (a5)
blt6incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		and.w      d3,d7
		eor.w      d7,(a1)
blt6incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt6incr
		rts

blt6incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt6incl2
blt6incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		eor.w      d6,(a1)+
		dbf        d4,blt6incl1
blt6incl2:
		jmp        (a5)
blt6incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		and.w      d3,d7
		eor.w      d7,(a1)
blt6incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt6incl
		rts

blt7inc:
		move.w     (a0)+,d6
		and.w      d2,d6
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt7inc2
blt7inc1:
		move.w     (a0)+,d6
		or.w       d6,(a1)+
		dbf        d4,blt7inc1
blt7inc2:
		jmp        (a5)
blt7inc3:
		move.w     (a0),d6
		and.w      d3,d6
		or.w       d6,(a1)
blt7inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt7inc
		rts

blt7incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		swap       d7
		ror.l      d0,d6
		and.w      d2,d6
		or.w       d6,(a1)+
		swap       d5
		move.w     d1,d5
		bmi.s      blt7incr2
		lsr.w      #1,d5
		bcs.s      blt7incr1
		move.w     (a0)+,d7
		move.l     d7,d6
		swap       d7
		ror.l      d0,d6
		or.w       d6,(a1)+
		subq.w     #1,d5
		bmi.s      blt7incr2
blt7incr1:
		move.l     d7,d6
		move.l     (a0)+,d7
		move.l     d7,d4
		swap       d7
		move.w     d7,d6
		ror.l      d0,d6
		ror.l      d0,d4
		swap       d6
		move.w     d4,d6
		or.l       d6,(a1)+
		dbf        d5,blt7incr1
blt7incr2:
		swap       d5
		jmp        (a5)
blt7incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		and.w      d3,d7
		or.w       d7,(a1)
blt7incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt7incr
		rts

blt7incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d2,d6
		or.w       d6,(a1)+
		swap       d5
		move.w     d1,d5
		bmi.s      blt7incl2
		lsr.w      #1,d5
		bcs.s      blt7incl1
		move.w     (a0)+,d7
		swap       d7
		move.l     d7,d6
		rol.l      d0,d6
		or.w       d6,(a1)+
		subq.w     #1,d5
		bmi.s      blt7incl2
blt7incl1:
		move.l     d7,d6
		move.l     (a0)+,d7
		swap       d7
		move.w     d7,d6
		move.l     d7,d4
		rol.l      d0,d6
		rol.l      d0,d4
		move.w     d4,d6
		or.l       d6,(a1)+
		dbf        d5,blt7incl1
blt7incl2:
		swap       d5
		jmp        (a5)
blt7incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		and.w      d3,d7
		or.w       d7,(a1)
blt7incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt7incl
		rts

blt8inc:
		move.w     (a0)+,d6
		and.w      d2,d6
		or.w       d6,(a1)
		eor.w      d2,(a1)+
		move.w     d1,d4
		bmi.s      blt8inc2
blt8inc1:
		move.w     (a0)+,d6
		or.w       d6,(a1)
		not.w      (a1)+
		dbf        d4,blt8inc1
blt8inc2:
		jmp        (a5)
blt8inc3:
		move.w     (a0),d6
		and.w      d3,d6
		or.w       d6,(a1)
		eor.w      d3,(a1)
blt8inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt8inc
		rts

blt8incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d2,d6
		or.w       d6,(a1)
		eor.w      d2,(a1)+
		move.w     d1,d4
		bmi.s      blt8incr2
blt8incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		or.w       d6,(a1)+
		dbf        d4,blt8incr1
blt8incr2:
		swap       d7
		jmp        (a5)
blt8incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		and.w      d3,d7
		or.w       d7,(a1)
		eor.w      d3,(a1)
blt8incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt8incr
		rts

blt8incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d2,d6
		or.w       d6,(a1)
		eor.w      d2,(a1)+
		move.w     d1,d4
		bmi.s      blt8incl2
blt8incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		or.w       d6,(a1)
		not.w      (a1)+
		dbf        d4,blt8incl1
blt8incl2:
		jmp        (a5)
blt8incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		and.w      d3,d7
		or.w       d7,(a1)
		eor.w      d3,(a1)
blt8incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt8incl
		rts

blt9inc:
		move.w     (a0)+,d6
		not.w      d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt9inc2
blt9inc1:
		move.w     (a0)+,d6
		not.w      d6
		eor.w      d6,(a1)+
		dbf        d4,blt9inc1
blt9inc2:
		jmp        (a5)
blt9inc3:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		eor.w      d6,(a1)
blt9inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt9inc
		rts

blt9incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt9incr2
blt9incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		eor.w      d6,(a1)+
		dbf        d4,blt9incr1
blt9incr2:
		swap       d7
		jmp        (a5)
blt9incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		not.w      d7
		and.w      d3,d7
		eor.w      d7,(a1)
blt9incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt9incr
		rts

blt9incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d2,d6
		eor.w      d6,(a1)+
		move.w     d1,d4
		bmi.s      blt9incl2
blt9incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		eor.w      d6,(a1)+
		dbf        d4,blt9incl1
blt9incl2:
		jmp        (a5)
blt9incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		not.w      d7
		and.w      d3,d7
		eor.w      d7,(a1)
blt9incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt9incl
		rts

blt10inc:
		lea.l      blt10inc5(pc),a5
		tst.w      d3
		beq.s      blt10inc1
		lea.l      blt10inc4(pc),a5
blt10inc1:
		eor.w      d2,(a1)+
		move.w     d1,d4
		bmi.s      blt10inc3
blt10inc2:
		not.w      (a1)+
		dbf        d4,blt10inc2
blt10inc3:
		jmp        (a5)
		nop
blt10inc4:
		eor.w      d3,(a1)
blt10inc5:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt10inc1
		rts

blt11inc:
		move.w     (a0)+,d6
		and.w      d2,d6
		eor.w      d2,(a1)
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt11inc2
blt11inc1:
		move.w     (a0)+,d6
		not.w      (a1)
		or.w       d6,(a1)+
		dbf        d4,blt11inc1
blt11inc2:
		jmp        (a5)
blt11inc3:
		move.w     (a0),d6
		and.w      d3,d6
		eor.w      d3,(a1)
		or.w       d6,(a1)
blt11inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt11inc
		rts

blt11incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d2,d6
		eor.w      d2,(a1)
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt11incr2
blt11incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      (a1)
		or.w       d6,(a1)+
		dbf        d4,blt11incr1
blt11incr2:
		swap       d7
		jmp        (a5)
blt11incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		and.w      d3,d7
		eor.w      d3,(a1)
		or.w       d7,(a1)
blt11incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt11incr
		rts

blt11incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d2,d6
		eor.w      d2,(a1)
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt11incl2
blt11incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      (a1)
		or.w       d6,(a1)+
		dbf        d4,blt11incl1
blt11incl2:
		jmp        (a5)
blt11incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		and.w      d3,d7
		eor.w      d3,(a1)
		or.w       d7,(a1)
blt11incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt11incl
		rts

blt12inc:
		move.w     (a0)+,d6
		not.w      d6
		and.w      d2,d6
		not.w      d2
		and.w      d2,(a1)
		not.w      d2
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt12inc2
blt12inc1:
		move.w     (a0)+,d6
		not.w      d6
		move.w     d6,(a1)+
		dbf        d4,blt12inc1
blt12inc2:
		jmp        (a5)
blt12inc3:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d6,(a1)
blt12inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt12inc
		rts

blt12incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d2,d6
		not.w      d2
		and.w      d2,(a1)
		not.w      d2
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt12incr2
blt12incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		move.w     d6,(a1)+
		dbf        d4,blt12incr1
blt12incr2:
		swap       d7
		jmp        (a5)
blt12incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		not.w      d7
		and.w      d3,d7
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d7,(a1)
blt12incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt12incr
		rts

blt12incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d2,d6
		not.w      d2
		and.w      d2,(a1)
		not.w      d2
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt12incl2
blt12incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		move.w     d6,(a1)+
		dbf        d4,blt12incl1
blt12incl2:
		jmp        (a5)
blt12incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		not.w      d7
		and.w      d3,d7
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d7,(a1)
blt12incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt12incl
		rts

blt13inc:
		move.w     (a0)+,d6
		not.w      d6
		and.w      d2,d6
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt13inc2
blt13inc1:
		move.w     (a0)+,d6
		not.w      d6
		or.w       d6,(a1)+
		dbf        d4,blt13inc1
blt13inc2:
		jmp        (a5)
blt13inc3:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		or.w       d6,(a1)
blt13inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt13inc
		rts

blt13incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d2,d6
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt13incr2
blt13incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		not.w      d6
		or.w       d6,(a1)+
		dbf        d4,blt13incr1
blt13incr2:
		swap       d7
		jmp        (a5)
blt13incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		not.w      d7
		and.w      d3,d7
		or.w       d7,(a1)
blt13incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt13incr
		rts

blt13incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d2,d6
		or.w       d6,(a1)+
		move.w     d1,d4
		bmi.s      blt13incl3
blt13incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		not.w      d6
		or.w       d6,(a1)+
		dbf        d4,blt13incl1
blt13incl3:
		jmp        (a5)
blt13incl4:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		not.w      d7
		and.w      d3,d7
		or.w       d7,(a1)
blt13incl5:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt13incl
		rts

blt14inc:
		move.w     (a0)+,d6
		or.w       d2,d6
		and.w      d6,(a1)
		or.w       d2,(a1)+
		move.w     d1,d4
		bmi.s      blt14inc2
blt14inc1:
		move.w     (a0)+,d6
		and.w      d6,(a1)
		not.w      (a1)+
		dbf        d4,blt14inc1
blt14inc2:
		jmp        (a5)
blt14inc3:
		move.w     (a0),d6
		or.w       d3,d6
		and.w      d6,(a1)
		eor.w      d3,(a1)
blt14inc4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt14inc
		rts

blt14incr:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		or.w       d2,d6
		and.w      d6,(a1)
		or.w       d2,(a1)+
		move.w     d1,d4
		bmi.s      blt14incr2
blt14incr1:
		move.w     d7,d6
		swap       d6
		move.w     (a0)+,d6
		move.w     d6,d7
		ror.l      d0,d6
		and.w      d6,(a1)
		not.w      (a1)+
		dbf        d4,blt14incr1
blt14incr2:
		swap       d7
		jmp        (a5)
blt14incr3:
		move.w     (a0),d7
		ror.l      d0,d7
		or.w       d3,d7
		and.w      d7,(a1)
		eor.w      d3,(a1)
blt14incr4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt14incr
		rts

blt14incl:
		move.w     (a0)+,d6
		jmp        (a4)
		swap       d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		or.w       d2,d6
		and.w      d6,(a1)
		or.w       d2,(a1)+
		move.w     d1,d4
		bmi.s      blt14incl2
blt14incl1:
		move.l     d7,d6
		move.w     (a0)+,d6
		swap       d6
		move.l     d6,d7
		rol.l      d0,d6
		and.w      d6,(a1)
		not.w      (a1)+
		dbf        d4,blt14incl1
blt14incl2:
		jmp        (a5)
blt14incl3:
		move.w     (a0),d7
		swap       d7
		rol.l      d0,d7
		or.w       d3,d7
		and.w      d7,(a1)
		eor.w      d3,(a1)
blt14incl4:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,blt14incl
		rts

blt15inc:
		moveq.l    #-1,d7
		lea.l      blt15inc4(pc),a5
		tst.w      d3
		bne.s      blt15inc1
		lea.l      blt15inc5(pc),a5
blt15inc1:
		or.w       d2,(a1)+
		move.w     d1,d4
		bmi.s      blt15inc3
blt15inc2:
		move.w     d7,(a1)+
		dbf        d4,blt15inc2
blt15inc3:
		jmp        (a5)
blt15inc4:
		or.w       d3,(a1)
blt15inc5:
		adda.w     a3,a1
		dbf        d5,blt15inc1
		rts

bitblt_dec:
		movea.w    d7,a5
		movea.l    r_saddr(a6),a0       /* source address */
		movea.l    r_daddr(a6),a1       /* dest address */
		move.w     a2,d6                /* bytes per source line */
		add.w      d5,d1
		mulu.w     d1,d6                /* * y src */
		adda.l     d6,a0                /* start of line */
		move.w     d0,d6
		add.w      d4,d6
		lsr.w      #4,d6
		add.w      d6,d6
		adda.w     d6,a0                /* source address */

		move.w     a3,d6                /* bytes per dest line */
		add.w      d5,d3
		mulu.w     d3,d6                /* * y dst */
		adda.l     d6,a1                /* start of line */
		move.w     d2,d6
		add.w      d4,d6
		lsr.w      #4,d6
		add.w      d6,d6
		adda.w     d6,a1                /* dest address */

		movea.l    vgamode+vga_membase(pc),a4 /* inside graphic card memory? */
		movea.l    a4,a5
		adda.l     #VGA_MEMSIZE,a5
		cmpa.l     a4,a0
		bcs.s      bitblt20
		cmpa.l     a5,a0
		bcc.s      bitblt20
		clr.l      r_splane_len(a6)
bitblt20:
		cmpa.l     a4,a1
		bcs.s      bitblt21
		cmpa.l     a5,a1
		bcc.s      bitblt21
		clr.l      r_dplane_len(a6)
bitblt21:
		move.w     r_dplanes(a6),d7
		cmp.w      r_splanes(a6),d7
		bne.s      bitblt22
		subq.w     #DRV_PLANES,d7
		bne.s      bitblt22
		move.l     r_splane_len(a6),d7
		or.l       r_dplane_len(a6),d7
		bne.s      bitblt22
		tst.l      r_fg_pixel(a6)
		bne.s      bitblt22
		tst.l      r_bg_pixel(a6)
		bne.s      bitblt22
		cmpi.b     #S_ONLY,r_wmode(a6)
		bne.s      bitblt22
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d0,d6
		and.w      d2,d7
		cmp.w      d6,d7
		beq        bitblt_sonly_dec
bitblt22:
		moveq.l    #15,d6
		move.w     d0,d7
		and.w      d6,d7
		add.w      d4,d7
		lsr.w      #4,d7
		move.w     d2,d3
		add.w      d4,d3
		add.w      d4,d0
		and.w      d6,d0
		and.w      d6,d3
		sub.w      d3,d0
		move.w     d2,d1
		and.w      d6,d1
		add.w      d4,d1
		lsr.w      #4,d1
		sub.w      d1,d7
		add.w      d2,d4
		not.w      d4
		and.w      d6,d4
		moveq.l    #-1,d3
		lsl.w      d4,d3
		and.w      d2,d6
		moveq.l    #-1,d2
		lsr.w      d6,d2
		move.w     d1,d4
		add.w      d4,d4
		suba.w     d4,a2
		suba.w     d4,a3
		move.w     d7,d4
		moveq.l    #4,d6
		moveq.l    #0,d7
		lea.l      bltdec_tab(pc),a4
		tst.w      d0
		beq.s      bitblt27
		blt.s      bitblt24
		lea.l      bltdec_tab2(pc),a4
		moveq.l    #8,d6
		tst.w      d4
		bpl.s      bitblt23
		moveq.l    #2,d7
		addq.w     #2,a2
bitblt23:
		cmpi.w     #8,d0
		ble.s      bitblt27
		lea.l      bltdec_tab3(pc),a4
		subq.w     #1,d0
		eori.w     #15,d0
		bra.s      bitblt27
bitblt24:
		lea.l      bltdec_tab3(pc),a4
		neg.w      d0
		tst.w      d1
		bne.s      bitblt25
		tst.w      d4
		bne.s      bitblt25
		moveq.l    #10,d6
		bra.s      bitblt27
bitblt25:
		moveq.l    #4,d6
		subq.w     #2,a2
		tst.w      d4
		bgt.s      bitblt26
		moveq.l    #2,d7
		addq.w     #2,a2
bitblt26:
		cmpi.w     #8,d0
		ble.s      bitblt27
		lea.l      bltdec_tab2(pc),a4
		subq.w     #1,d0
		eori.w     #15,d0
bitblt27:
		swap       d7
		subq.w     #2,d1
		cmp.w      #-2,d1
		bne.s      bitblt28
		and.w      d2,d3
		moveq.l    #0,d2
bitblt28:
		move.w     d5,-(a7)
		moveq.l    #15,d4
		cmp.w      d4,d5
		bge.s      bitblt29
		move.w     d5,d4
bitblt29:
		move.w     d4,d5
		move.w     r_dplanes(a6),d7
		movem.l    a0-a1,-(a7)
		move.l     r_fg_pixel(a6),-(a7)
		move.l     r_bg_pixel(a6),-(a7)
		bra.s      bitblt32
bitblt30:
		move.l     a4,-(a7)
		clr.w      d4
		lsr.w      r_fg_pixel+2(a6)
		addx.w     d4,d4
		lsr.w      r_bg_pixel+2(a6)
		addx.w     d4,d4
		lea.l      r_wmode(a6),a4
		move.b     0(a4,d4.w),d4
		movea.l    vgamode+vga_regbase(pc),a4
		move.b     #0x02,TS_I(a4)
		move.b     #0x04,GDC_I(a4)
		move.b     memwrite_table7(pc,d7.w),TS_D(a4)
		move.b     memread_table7(pc,d7.w),GDC_D(a4)
		movea.l    (a7),a4
		lsl.w      #3,d4
		adda.w     d4,a4
		movem.l    d5-d7/a0-a1,-(a7)
		swap       d7
		move.w     (a4)+,d4
		add.w      d4,d6
		add.w      (a4)+,d7
		cmp.w      #-2,d1
		bne.s      bitblt31
		move.w     (a4),d7
bitblt31:
		lea.l      bltdec_tab(pc),a4
		lea.l      bltdec_tab(pc),a5
		adda.w     d6,a4
		adda.w     d7,a5
		jsr        bltdec_tab(pc,d4.w)
		movem.l    (a7)+,d5-d7/a0-a1/a4
		adda.l     r_splane_len(a6),a0
		adda.l     r_dplane_len(a6),a1
bitblt32:
		dbf        d7,bitblt30
		move.l     (a7)+,r_bg_pixel(a6)
		move.l     (a7)+,r_fg_pixel(a6)
		movem.l    (a7)+,a0-a1
		move.w     r_swidth(a6),d4
		asl.w      #4,d4
		suba.w     d4,a0
		move.w     r_dwidth(a6),d4
		asl.w      #4,d4
		suba.w     d4,a1
		move.w     (a7)+,d5
		sub.w      #16,d5
		bpl        bitblt28
		rts

memwrite_table7:
	dc.b 8,4,2,1
memread_table7:
	dc.b 3,2,1,0

bltdec_tab:
	dc.w blt0dec-bltdec_tab,blt0dec4-bltdec_tab,blt0dec5-bltdec_tab,0
	dc.w blt1dec-bltdec_tab,blt1dec3-bltdec_tab,blt1dec4-bltdec_tab,0
	dc.w blt2dec-bltdec_tab,blt2dec3-bltdec_tab,blt2dec4-bltdec_tab,0
	dc.w blt3dec-bltdec_tab,0,0,0
	dc.w blt4dec-bltdec_tab,blt4dec3-bltdec_tab,blt4dec4-bltdec_tab,0
	dc.w blt5dec-bltdec_tab,blt5dec-bltdec_tab,blt5dec-bltdec_tab,0
	dc.w blt6dec-bltdec_tab,blt6dec3-bltdec_tab,blt6dec4-bltdec_tab,0
	dc.w blt7dec-bltdec_tab,blt7dec3-bltdec_tab,blt7dec4-bltdec_tab,0
	dc.w blt8dec-bltdec_tab,blt8dec3-bltdec_tab,blt8dec4-bltdec_tab,0
	dc.w blt9dec-bltdec_tab,blt9dec3-bltdec_tab,blt9dec4-bltdec_tab,0
	dc.w blt10dec-bltdec_tab,blt10dec4-bltdec_tab,blt10dec5-bltdec_tab,0
	dc.w blt11dec-bltdec_tab,blt11dec3-bltdec_tab,blt11dec4-bltdec_tab,0
	dc.w blt12dec-bltdec_tab,blt12dec3-bltdec_tab,blt12dec4-bltdec_tab,0
	dc.w blt13dec-bltdec_tab,blt13dec3-bltdec_tab,blt13dec4-bltdec_tab,0
	dc.w blt14dec-bltdec_tab,blt14dec3-bltdec_tab,blt14dec4-bltdec_tab,0
	dc.w blt15dec-bltdec_tab,blt15dec4-bltdec_tab,blt15dec5-bltdec_tab,0

bltdec_tab2:
	dc.w blt0dec-bltdec_tab,blt0dec4-bltdec_tab,blt0dec5-bltdec_tab,0
	dc.w blt1decl-bltdec_tab,blt1decl3-bltdec_tab,blt1decl4-bltdec_tab,0
	dc.w blt2decl-bltdec_tab,blt2decl3-bltdec_tab,blt2decl4-bltdec_tab,0
	dc.w blt3decl-bltdec_tab,blt3decl3-bltdec_tab,blt3decl4-bltdec_tab,0
	dc.w blt4decl-bltdec_tab,blt4decl3-bltdec_tab,blt4decl4-bltdec_tab,0
	dc.w blt5dec-bltdec_tab,blt5dec-bltdec_tab,blt5dec-bltdec_tab,0
	dc.w blt6decl-bltdec_tab,blt6decl3-bltdec_tab,blt6decl4-bltdec_tab,0
	dc.w blt7decl-bltdec_tab,blt7decl3-bltdec_tab,blt7decl4-bltdec_tab,0
	dc.w blt8decl-bltdec_tab,blt8decl3-bltdec_tab,blt8decl4-bltdec_tab,0
	dc.w blt9decl-bltdec_tab,blt9decl3-bltdec_tab,blt9decl4-bltdec_tab,0
	dc.w blt10dec-bltdec_tab,blt10dec4-bltdec_tab,blt10dec5-bltdec_tab,0
	dc.w blt11decl-bltdec_tab,blt11decl3-bltdec_tab,blt11decl4-bltdec_tab,0
	dc.w blt12decl-bltdec_tab,blt12decl3-bltdec_tab,blt12decl4-bltdec_tab,0
	dc.w blt13decl-bltdec_tab,blt13decl3-bltdec_tab,blt13decl4-bltdec_tab,0
	dc.w blt14decl-bltdec_tab,blt14decl3-bltdec_tab,blt14decl4-bltdec_tab,0
	dc.w blt15dec-bltdec_tab,blt15dec4-bltdec_tab,blt15dec5-bltdec_tab,0

bltdec_tab3:
	dc.w blt0dec-bltdec_tab,blt0dec4-bltdec_tab,blt0dec5-bltdec_tab,0
	dc.w blt1decr-bltdec_tab,blt1decr3-bltdec_tab,blt1decr4-bltdec_tab,0
	dc.w blt2decr-bltdec_tab,blt2decr3-bltdec_tab,blt2decr4-bltdec_tab,0
	dc.w blt3decr-bltdec_tab,blt3decr3-bltdec_tab,blt3decr4-bltdec_tab,0
	dc.w blt4decr-bltdec_tab,blt4decr3-bltdec_tab,blt4decr4-bltdec_tab,0
	dc.w blt5dec-bltdec_tab,blt5dec-bltdec_tab,blt5dec-bltdec_tab,0
	dc.w blt6decr-bltdec_tab,blt6decr3-bltdec_tab,blt6decr4-bltdec_tab,0
	dc.w blt7decr-bltdec_tab,blt7decr3-bltdec_tab,blt7decr4-bltdec_tab,0
	dc.w blt8decr-bltdec_tab,blt8decr3-bltdec_tab,blt8decr4-bltdec_tab,0
	dc.w blt9decr-bltdec_tab,blt9decr3-bltdec_tab,blt9decr4-bltdec_tab,0
	dc.w blt10dec-bltdec_tab,blt10dec4-bltdec_tab,blt10dec5-bltdec_tab,0
	dc.w blt11decr-bltdec_tab,blt11decr3-bltdec_tab,blt11decr4-bltdec_tab,0
	dc.w blt12decr-bltdec_tab,blt12decr3-bltdec_tab,blt12decr4-bltdec_tab,0
	dc.w blt13decr-bltdec_tab,blt13decr3-bltdec_tab,blt13decr4-bltdec_tab,0
	dc.w blt14decr-bltdec_tab,blt14decr3-bltdec_tab,blt14decr4-bltdec_tab,0
	dc.w blt15dec-bltdec_tab,blt15dec4-bltdec_tab,blt15dec5-bltdec_tab,0

blt0dec:
		not.w      d2
		not.w      d3
		moveq.l    #0,d7
		lea.l      blt0dec5(pc),a5
		cmp.w      #-1,d2
		beq.s      blt0dec1
		lea.l      blt0dec4(pc),a5
blt0dec1:
		and.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt0dec3
blt0dec2:
		move.w     d7,-(a1)
		dbf        d4,blt0dec2
blt0dec3:
		jmp        (a5)
blt0dec4:
		and.w      d2,-(a1)
blt0dec5:
		suba.w     a3,a1
		dbf        d5,blt0dec1
		not.w      d2
		not.w      d3
		rts

blt1dec:
		move.w     (a0),d6
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt1dec2
blt1dec1:
		move.w     -(a0),d6
		and.w      d6,-(a1)
		dbf        d4,blt1dec1
blt1dec2:
		jmp        (a5)
blt1dec3:
		move.w     -(a0),d6
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,-(a1)
blt1dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt1dec
		rts

blt1decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d3
		or.w       d3,d6
		and.w      d6,(a1)
		not.w      d3
		move.w     d1,d4
		bmi.s      blt1decr2
blt1decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d6,-(a1)
		dbf        d4,blt1decr1
blt1decr2:
		jmp        (a5)
blt1decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		not.w      d2
		or.w       d2,d7
		not.w      d2
		and.w      d7,-(a1)
blt1decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt1decr
		rts

blt1decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt1decl2
blt1decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d6,-(a1)
		dbf        d4,blt1decl1
blt1decl2:
		swap       d7
		jmp        (a5)
blt1decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		not.w      d2
		or.w       d2,d7
		not.w      d2
		and.w      d7,-(a1)
blt1decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt1decl
		rts

blt2dec:
		move.w     (a0),d6
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt2dec2
blt2dec1:
		move.w     -(a0),d6
		not.w      -(a1)
		and.w      d6,(a1)
		dbf        d4,blt2dec1
blt2dec2:
		jmp        (a5)
blt2dec3:
		move.w     -(a0),d6
		eor.w      d2,-(a1)
		not.w      d2
		or.w       d2,d6
		not.w      d2
		and.w      d6,(a1)
blt2dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt2dec
		rts

blt2decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt2decr2
blt2decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      -(a1)
		and.w      d6,(a1)
		dbf        d4,blt2decr1
blt2decr2:
		jmp        (a5)
blt2decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		eor.w      d2,-(a1)
		not.w      d2
		or.w       d2,d7
		not.w      d2
		and.w      d7,(a1)
blt2decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt2decr
		rts

blt2decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		eor.w      d3,(a1)
		not.w      d3
		or.w       d3,d6
		not.w      d3
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt2decl2
blt2decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      -(a1)
		and.w      d6,(a1)
		dbf        d4,blt2decl1
blt2decl2:
		swap       d7
		jmp        (a5)
blt2decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		eor.w      d2,-(a1)
		not.w      d2
		or.w       d2,d7
		not.w      d2
		and.w      d7,(a1)
blt2decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt2decl
		rts

blt3dec:
		move.w     d1,d4
		bmi        blt3dec7
		move.w     d1,-(a7)
		lsr.w      #1,d4
		bcs.s      blt3dec2
		lea.l      blt3dec4(pc),a4
		bne.s      blt3dec1
		lea.l      blt3dec6(pc),a5
		bra.s      blt3dec3
blt3dec1:
		subq.w     #1,d4
		move.w     d4,d0
		lsr.w      #4,d4
		move.w     d4,d1
		not.w      d0
		andi.w     #15,d0
		add.w      d0,d0
		lea.l      blt3dec5(pc,d0.w),a5
		bra.s      blt3dec3
blt3dec2:
		move.w     d4,d0
		lsr.w      #4,d4
		move.w     d4,d1
		not.w      d0
		andi.w     #15,d0
		add.w      d0,d0
		lea.l      blt3dec5(pc,d0.w),a4
blt3dec3:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		or.w       d3,(a1)
		eor.w      d6,(a1)
		move.w     d1,d4
		jmp        (a4)
blt3dec4:
		move.w     -(a0),-(a1)
		jmp        (a5)
blt3dec5:
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		move.l     -(a0),-(a1)
		dbf        d4,blt3dec5
blt3dec6:
		move.w     -(a0),d6
		not.w      d6
		and.w      d2,d6
		or.w       d2,-(a1)
		eor.w      d6,(a1)
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt3dec3
		move.w     (a7)+,d1
		rts
blt3dec7:
		move.w     d2,-(a7)
		move.w     d3,-(a7)
		tst.w      d2
		beq.s      blt3dec9
		subq.l     #2,a0
		subq.l     #2,a1
		swap       d2
		move.w     d3,d2
		move.l     d2,d3
		not.l      d3
		addq.w     #2,a2
		addq.w     #2,a3
blt3dec8:
		move.l     (a0),d6
		and.l      d2,d6
		and.l      d3,(a1)
		or.l       d6,(a1)
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt3dec8
		subq.w     #2,a2
		subq.w     #2,a3
		move.w     (a7)+,d3
		move.w     (a7)+,d2
		rts
blt3dec9:
		move.w     d3,d2
		not.w      d3
blt3dec10:
		move.w     (a0),d6
		and.w      d2,d6
		and.w      d3,(a1)
		or.w       d6,(a1)
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt3dec10
		move.w     (a7)+,d3
		move.w     (a7)+,d2
		rts

blt3decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d3,d6
		or.w       d3,(a1)
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt3decr2
blt3decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		move.w     d6,-(a1)
		dbf        d4,blt3decr1
blt3decr2:
		jmp        (a5)
blt3decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		not.w      d7
		and.w      d2,d7
		or.w       d2,-(a1)
		eor.w      d7,(a1)
blt3decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt3decr
		rts

blt3decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d3,d6
		or.w       d3,(a1)
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt3decl2
blt3decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		move.w     d6,-(a1)
		dbf        d4,blt3decl1
blt3decl2:
		swap       d7
		jmp        (a5)
blt3decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		not.w      d7
		and.w      d2,d7
		or.w       d2,-(a1)
		eor.w      d7,(a1)
blt3decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt3decl
		rts

blt4dec:
		move.w     (a0),d6
		and.w      d3,d6
		not.w      d6
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt4dec2
blt4dec1:
		move.w     -(a0),d6
		not.w      d6
		and.w      d6,-(a1)
		dbf        d4,blt4dec1
blt4dec2:
		jmp        (a5)
blt4dec3:
		move.w     -(a0),d6
		and.w      d2,d6
		not.w      d6
		and.w      d6,-(a1)
blt4dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt4dec
		rts

blt4decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d3,d6
		not.w      d6
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt4decr2
blt4decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d6,-(a1)
		dbf        d4,blt4decr1
blt4decr2:
		jmp        (a5)
blt4decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		and.w      d2,d7
		not.w      d7
		and.w      d7,-(a1)
blt4decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt4decr
		rts

blt4decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d3,d6
		not.w      d6
		and.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt4decl2
blt4decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d6,-(a1)
		dbf        d4,blt4decl1
blt4decl2:
		swap       d7
		jmp        (a5)
blt4decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		and.w      d2,d7
		not.w      d7
		and.w      d7,-(a1)
blt4decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt4decl
		rts

blt5dec:
		rts

blt6dec:
		move.w     (a0),d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt6dec2
blt6dec1:
		move.w     -(a0),d6
		eor.w      d6,-(a1)
		dbf        d4,blt6dec1
blt6dec2:
		jmp        (a5)
blt6dec3:
		move.w     -(a0),d6
		and.w      d2,d6
		eor.w      d6,-(a1)
blt6dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt6dec
		rts

blt6decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt6decr2
blt6decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		eor.w      d6,-(a1)
		dbf        d4,blt6decr1
blt6decr2:
		jmp        (a5)
blt6decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		and.w      d2,d7
		eor.w      d7,-(a1)
blt6decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt6decr
		rts

blt6decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt6decl2
blt6decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		eor.w      d6,-(a1)
		dbf        d4,blt6decl1
blt6decl2:
		swap       d7
		jmp        (a5)
blt6decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		and.w      d2,d7
		eor.w      d7,-(a1)
blt6decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt6decl
		rts

blt7dec:
		move.w     (a0),d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt7dec2
blt7dec1:
		move.w     -(a0),d6
		or.w       d6,-(a1)
		dbf        d4,blt7dec1
blt7dec2:
		jmp        (a5)
blt7dec3:
		move.w     -(a0),d6
		and.w      d2,d6
		or.w       d6,-(a1)
blt7dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt7dec
		rts

blt7decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt7decr2
blt7decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		or.w       d6,-(a1)
		dbf        d4,blt7decr1
blt7decr2:
		jmp        (a5)
blt7decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		and.w      d2,d7
		or.w       d7,-(a1)
blt7decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt7decr
		rts

blt7decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt7decl2
blt7decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		or.w       d6,-(a1)
		dbf        d4,blt7decl1
blt7decl2:
		swap       d7
		jmp        (a5)
blt7decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		and.w      d2,d7
		or.w       d7,-(a1)
blt7decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt7decl
		rts

blt8dec:
		move.w     (a0),d6
		and.w      d3,d6
		or.w       d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt8dec2
blt8dec1:
		move.w     -(a0),d6
		or.w       d6,-(a1)
		not.w      (a1)
		dbf        d4,blt8dec1
blt8dec2:
		jmp        (a5)
blt8dec3:
		move.w     -(a0),d6
		and.w      d2,d6
		or.w       d6,-(a1)
		eor.w      d2,(a1)
blt8dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt8dec
		rts

blt8decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d3,d6
		or.w       d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt8decr2
blt8decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		or.w       d6,-(a1)
		not.w      (a1)
		dbf        d4,blt8decr1
blt8decr2:
		jmp        (a5)
blt8decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		and.w      d2,d7
		or.w       d7,-(a1)
		eor.w      d2,(a1)
blt8decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt8decr
		rts

blt8decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d3,d6
		or.w       d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt8decl2
blt8decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		or.w       d6,-(a1)
		not.w      (a1)
		dbf        d4,blt8decl1
blt8decl2:
		swap       d7
		jmp        (a5)
blt8decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		and.w      d2,d7
		or.w       d7,-(a1)
		eor.w      d2,(a1)
blt8decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt8decl
		rts

blt9dec:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt9dec2
blt9dec1:
		move.w     -(a0),d6
		not.w      d6
		eor.w      d6,-(a1)
		dbf        d4,blt9dec1
blt9dec2:
		jmp        (a5)
blt9dec3:
		move.w     -(a0),d6
		not.w      d6
		and.w      d2,d6
		eor.w      d6,-(a1)
blt9dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt9dec
		rts

blt9decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt9decr2
blt9decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		eor.w      d6,-(a1)
		dbf        d4,blt9decr1
blt9decr2:
		jmp        (a5)
blt9decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		not.w      d7
		and.w      d2,d7
		eor.w      d7,-(a1)
blt9decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt9decr
		rts

blt9decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d3,d6
		eor.w      d6,(a1)
		move.w     d1,d4
		bmi.s      blt9decl2
blt9decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		eor.w      d6,-(a1)
		dbf        d4,blt9decl1
blt9decl2:
		swap       d7
		jmp        (a5)
blt9decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		not.w      d7
		and.w      d2,d7
		eor.w      d7,-(a1)
blt9decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt9decl
		rts

blt10dec:
		lea.l      blt10dec5(pc),a5
		tst.w      d2
		beq.s      blt10dec1
		lea.l      blt10dec4(pc),a5
blt10dec1:
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt10dec3
blt10dec2:
		not.w      -(a1)
		dbf        d4,blt10dec2
blt10dec3:
		jmp        (a5)
		nop
blt10dec4:
		eor.w      d2,-(a1)
blt10dec5:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt10dec1
		rts

blt11dec:
		move.w     (a0),d6
		and.w      d3,d6
		eor.w      d3,(a1)
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt11dec2
blt11dec1:
		move.w     -(a0),d6
		not.w      -(a1)
		or.w       d6,(a1)
		dbf        d4,blt11dec1
blt11dec2:
		jmp        (a5)
blt11dec3:
		move.w     -(a0),d6
		and.w      d2,d6
		eor.w      d2,-(a1)
		or.w       d6,(a1)
blt11dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt11dec
		rts

blt11decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d3,d6
		eor.w      d3,(a1)
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt11decr2
blt11decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      -(a1)
		or.w       d6,(a1)
		dbf        d4,blt11decr1
blt11decr2:
		jmp        (a5)
blt11decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		and.w      d2,d7
		eor.w      d2,-(a1)
		or.w       d7,(a1)
blt11decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt11decr
		rts

blt11decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d3,d6
		eor.w      d3,(a1)
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt11decl2
blt11decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      -(a1)
		or.w       d6,(a1)
		dbf        d4,blt11decl1
blt11decl2:
		swap       d7
		jmp        (a5)
blt11decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		and.w      d2,d7
		eor.w      d2,-(a1)
		or.w       d7,(a1)
blt11decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt11decl
		rts

blt12dec:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt12dec2
blt12dec1:
		move.w     -(a0),d6
		not.w      d6
		move.w     d6,-(a1)
		dbf        d4,blt12dec1
blt12dec2:
		jmp        (a5)
blt12dec3:
		move.w     -(a0),d6
		not.w      d6
		and.w      d2,d6
		not.w      d2
		and.w      d2,-(a1)
		not.w      d2
		or.w       d6,(a1)
blt12dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt12dec
		rts

blt12decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d3,d6
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt12decr2
blt12decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		move.w     d6,-(a1)
		dbf        d4,blt12decr1
blt12decr2:
		jmp        (a5)
blt12decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		not.w      d7
		and.w      d2,d7
		not.w      d2
		and.w      d2,-(a1)
		not.w      d2
		or.w       d7,(a1)
blt12decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt12decr
		rts

blt12decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d3,d6
		not.w      d3
		and.w      d3,(a1)
		not.w      d3
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt12decl2
blt12decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		move.w     d6,-(a1)
		dbf        d4,blt12decl1
blt12decl2:
		swap       d7
		jmp        (a5)
blt12decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		not.w      d7
		and.w      d2,d7
		not.w      d2
		and.w      d2,-(a1)
		not.w      d2
		or.w       d7,(a1)
blt12decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt12decl
		rts

blt13dec:
		move.w     (a0),d6
		not.w      d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt13dec2
blt13dec1:
		move.w     -(a0),d6
		not.w      d6
		or.w       d6,-(a1)
		dbf        d4,blt13dec1
blt13dec2:
		jmp        (a5)
blt13dec3:
		move.w     -(a0),d6
		not.w      d6
		and.w      d2,d6
		or.w       d6,-(a1)
blt13dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt13dec
		rts

blt13decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt13decr2
blt13decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		not.w      d6
		or.w       d6,-(a1)
		dbf        d4,blt13decr1
blt13decr2:
		jmp        (a5)
blt13decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		not.w      d7
		and.w      d2,d7
		or.w       d7,-(a1)
blt13decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt13decr
		rts

blt13decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		and.w      d3,d6
		or.w       d6,(a1)
		move.w     d1,d4
		bmi.s      blt13decl2
blt13decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		not.w      d6
		or.w       d6,-(a1)
		dbf        d4,blt13decl1
blt13decl2:
		swap       d7
		jmp        (a5)
blt13decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		not.w      d7
		and.w      d2,d7
		or.w       d7,-(a1)
blt13decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt13decl
		rts

blt14dec:
		move.w     (a0),d6
		or.w       d3,d6
		and.w      d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt14dec2
blt14dec1:
		move.w     -(a0),d6
		and.w      d6,-(a1)
		not.w      (a1)
		dbf        d4,blt14dec1
blt14dec2:
		jmp        (a5)
blt14dec3:
		move.w     -(a0),d6
		or.w       d2,d6
		and.w      d6,-(a1)
		or.w       d2,(a1)
blt14dec4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt14dec
		rts

blt14decr:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		or.w       d3,d6
		and.w      d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt14decr2
blt14decr1:
		move.l     d7,d6
		move.w     -(a0),d6
		swap       d6
		move.l     d6,d7
		ror.l      d0,d6
		and.w      d6,-(a1)
		not.w      (a1)
		dbf        d4,blt14decr1
blt14decr2:
		jmp        (a5)
blt14decr3:
		move.w     -(a0),d7
		swap       d7
		ror.l      d0,d7
		or.w       d2,d7
		and.w      d7,-(a1)
		or.w       d2,(a1)
blt14decr4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt14decr
		rts

blt14decl:
		move.w     (a0),d6
		jmp        (a4)
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		or.w       d3,d6
		and.w      d6,(a1)
		eor.w      d3,(a1)
		move.w     d1,d4
		bmi.s      blt14decl2
blt14decl1:
		move.w     d7,d6
		swap       d6
		move.w     -(a0),d6
		move.w     d6,d7
		rol.l      d0,d6
		and.w      d6,-(a1)
		not.w      (a1)
		dbf        d4,blt14decl1
blt14decl2:
		swap       d7
		jmp        (a5)
blt14decl3:
		move.w     -(a0),d7
		rol.l      d0,d7
		or.w       d2,d7
		and.w      d7,-(a1)
		or.w       d2,(a1)
blt14decl4:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,blt14decl
		rts

blt15dec:
		moveq.l    #-1,d7
		lea.l      blt15dec4(pc),a5
		tst.w      d2
		bne.s      blt15dec1
		lea.l      blt15dec5(pc),a5
blt15dec1:
		or.w       d3,(a1)
		move.w     d1,d4
		bmi.s      blt15dec3
blt15dec2:
		move.w     d7,-(a1)
		dbf        d4,blt15dec2
blt15dec3:
		jmp        (a5)
blt15dec4:
		or.w       d2,-(a1)
blt15dec5:
		suba.w     a3,a1
		dbf        d5,blt15dec1
		rts

startmask: dc.b 0xff,0x7f,0x3f,0x1f,0x0f,0x07,0x03,0x01
endmask:   dc.b 0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff

bitblt_sonly_inc:
		btst       #3,d0
		beq.s      bitblt_sinc1
		addq.l     #1,a0
bitblt_sinc1:
		btst       #3,d2
		beq.s      bitblt_sinc2
		addq.l     #1,a1
bitblt_sinc2:
		add.w      d2,d4
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d2,d6
		and.w      d4,d7
		lsr.w      #3,d2
		lsr.w      #3,d4
		sub.w      d2,d4
		addq.w     #1,d4
		suba.w     d4,a2
		suba.w     d4,a3
		move.b     startmask(pc,d6.w),d0
		move.b     endmask(pc,d7.w),d1
		move.b     d0,d2
		move.b     d1,d3
		not.w      d0
		not.w      d1
		subq.w     #2,d4
		bmi.s      bitblt_sinc4
		beq.s      bitblt_sinc3
		lea.l      bitblt_sinc8(pc),a4
		subq.w     #1,d4
		moveq.l    #31,d6
		and.w      d4,d6
		lsr.w      #5,d4
		eori.w     #31,d6
		add.w      d6,d6
		adda.w     d6,a4
		bra.s      bitblt_sinc5
bitblt_sinc3:
		lea.l      bitblt_sinc9(pc),a4
		bra.s      bitblt_sinc5
bitblt_sinc4:
		lea.l      bitblt_sinc10(pc),a4
		and.b      d3,d2
		move.w     d2,d0
		not.w      d0
bitblt_sinc5:
		tst.w      is_mste
		beq.s      bitblt_sinc6
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
bitblt_sinc6:
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      GDC_I(a5),a6
		lea.l      TS_I(a5),a5
		move.b     #0x02,(a5)+
		move.b     #0x01,(a6)
		move.b     #0x00,1(a6)
bitblt_sinc7:
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		move.b     #0x04,-1(a6)
		move.b     #0x01,(a5)
		move.b     #0x00,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x02,(a5)
		move.b     #0x01,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x04,(a5)
		move.b     #0x02,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x08,(a5)
		move.b     #0x03,(a6)
		move.b     (a0)+,d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)+
		move.b     #0x05,-(a6)
		andi.b     #0xFC,1(a6)
		ori.b      #0x01,1(a6)
		move.b     #0x0F,(a5)
		move.w     d4,d6
		jmp        (a4)
bitblt_sinc8:
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		move.b     (a0)+,(a1)+
		dbf        d6,bitblt_sinc8
bitblt_sinc9:
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		move.b     #0x04,-1(a6)
		move.b     #0x01,(a5)
		move.b     #0x00,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x02,(a5)
		move.b     #0x01,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x04,(a5)
		move.b     #0x02,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x08,(a5)
		move.b     #0x03,(a6)
		move.b     (a0)+,d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)+
		subq.l     #1,a6
bitblt_sinc10:
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d5,bitblt_sinc7
		move.b     #0x0F,(a5)
		tst.w      is_mste
		beq.s      bitblt_sinc11
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
bitblt_sinc11:
		rts

startmask2: dc.b 0xff,0x7f,0x3f,0x1f,0x0f,0x07,0x03,0x01
endmask2:   dc.b 0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff

bitblt_sonly_dec:
		addq.l     #1,a0
		addq.l     #1,a1
		add.w      d4,d0
		add.w      d2,d4
		btst       #3,d0
		beq.s      bitblt_dec1
		addq.l     #1,a0
bitblt_dec1:
		btst       #3,d4
		beq.s      bitblt_dec2
		addq.l     #1,a1
bitblt_dec2:
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d2,d6
		and.w      d4,d7
		lsr.w      #3,d2
		lsr.w      #3,d4
		sub.w      d2,d4
		addq.w     #1,d4
		suba.w     d4,a2
		suba.w     d4,a3
		move.b     startmask2(pc,d6.w),d0
		move.b     endmask2(pc,d7.w),d1
		move.b     d0,d2
		move.b     d1,d3
		not.w      d0
		not.w      d1
		subq.w     #2,d4
		bmi.s      bitblt_dec4
		beq.s      bitblt_dec3
		lea.l      bitblt_dec8(pc),a4
		subq.w     #1,d4
		moveq.l    #31,d6
		and.w      d4,d6
		lsr.w      #5,d4
		eori.w     #31,d6
		add.w      d6,d6
		adda.w     d6,a4
		bra.s      bitblt_dec5
bitblt_dec3:
		lea.l      bitblt_dec9(pc),a4
		bra.s      bitblt_dec5
bitblt_dec4:
		lea.l      bitblt_dec10(pc),a4
		and.b      d2,d3
		move.w     d3,d1
		not.w      d1
bitblt_dec5:
		tst.w      is_mste
		beq.s      bitblt_dec6
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
bitblt_dec6:
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      GDC_I(a5),a6
		lea.l      TS_I(a5),a5
		move.b     #0x02,(a5)+
		move.b     #0x01,(a6)
		move.b     #0x00,1(a6)
bitblt_dec7:
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		move.b     #0x04,-1(a6)
		move.b     #0x01,(a5)
		move.b     #0x00,(a6)
		move.b     -(a0),d6
		and.b      d1,-(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x02,(a5)
		move.b     #0x01,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x04,(a5)
		move.b     #0x02,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x08,(a5)
		move.b     #0x03,(a6)
		move.b     (a0),d6
		and.b      d1,(a1)
		and.b      d3,d6
		or.b       d6,(a1)
		move.b     #0x05,-(a6)
		andi.b     #0xFC,1(a6)
		ori.b      #0x01,1(a6)
		move.b     #0x0F,(a5)
		move.w     d4,d6
		jmp        (a4)
bitblt_dec8:
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		move.b     -(a0),-(a1)
		dbf        d6,bitblt_dec8
bitblt_dec9:
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		move.b     #0x04,-1(a6)
		move.b     #0x01,(a5)
		move.b     #0x00,(a6)
		move.b     -(a0),d6
		and.b      d0,-(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x02,(a5)
		move.b     #0x01,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x04,(a5)
		move.b     #0x02,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		move.b     #0x08,(a5)
		move.b     #0x03,(a6)
		move.b     (a0),d6
		and.b      d0,(a1)
		and.b      d2,d6
		or.b       d6,(a1)
		subq.l     #1,a6
bitblt_dec10:
		suba.w     a2,a0
		suba.w     a3,a1
		dbf        d5,bitblt_dec7
		move.b     #0x0F,(a5)
		tst.w      is_mste
		beq.s      bitblt_dec11
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
bitblt_dec11:
		rts

/* **************************************************************************** */

	.offset 0
write_buffer:     ds.l 1  /*   0 */
write_jump:       ds.l 1  /*   4 */
write_registers:  ds.l 16 /*   8 */
scale_buffer:     ds.l 1  /*  72 */
scale_jump:       ds.l 1  /*  76 */
scale_jump_trans: ds.l 1  /*  80 */
scale_registers:  ds.l 16 /*  84 */
SCALE_STACK:              /* 148 */
                  ds.l 2
noclip_registers:         /* 156 */
noclip_qx:        ds.w 1  /* 156 */
noclip_qy:        ds.w 1  /* 158 */
noclip_zx:        ds.w 1  /* 160 */
noclip_zy:        ds.w 1  /* 162 */
noclip_qdx:       ds.w 1  /* 164 */
noclip_qdy:       ds.w 1  /* 166 */
noclip_zdx:       ds.w 1  /* 168 */
noclip_zdy:       ds.w 1  /* 170 */

	.text
scale_blt_err:
		lea.l      SCALE_STACK+4(a7),a7
		rts

/*
 * Scaling bitblock transfer
 * Register d0-d7/a0-a5 can be modified
 * Inputs:
 * d0.w qx, upper left x-coordinate of source rectangle
 * d1.w qy, upper left y-coordinate of source rectangle
 * d2.w zx, upper left x-coordinate of dest rectangle
 * d3.w zy, upper left y-coordinate of dest rectangle
 * d4.w qdx, width of sourcee - 1
 * d5.w qdy, height of source -1
 * d6.w zdx, width of dest - 1
 * d7.w zdy, height of dest -1
 * a6.l workstation
 * 4(sp).w qx without clipping
 * 6(sp).w qy without clipping
 * 8(sp).w zx without clipping
 * 10(sp).w zy without clipping
 * 12(sp).w qdx without clipping
 * 14(sp).w qdy without clipping
 * 16(sp).w zdx without clipping
 * 18(sp).w zdy without clipping
 * Outputs:
 */
bitblt_scale:
		movea.l    r_saddr(a6),a0
		movea.l    vgamode+vga_membase(pc),a2
		cmpa.l     a2,a0
		bne.s      bitblt_scale1
		clr.l      r_splane_len(a6)
bitblt_scale1:
		movea.l    r_daddr(a6),a1
		cmpa.l     a2,a1
		bne.s      bitblt_scale2
		clr.l      r_dplane_len(a6)
bitblt_scale2:
		lea.l      scale_buf_init(pc),a0
		lea.l      scale_buf_reset(pc),a1
		lea.l      scale_line_init(pc),a2
		lea.l      write_line_init(pc),a3

		move.l     a1,-(a7)             /* save pointer to scale_buf_reset */
		lea.l      -SCALE_STACK(a7),a7
		move.l     d0,-(a7)
		moveq.l    #0,d0
		tst.w      r_splanes(a6)
		beq.s      bitblt_scale3
		move.w     r_swidth(a6),d0
		lsr.w      #2,d0
		move.w     d0,r_swidth(a6)
		move.l     r_splane_len(a6),d0
		lsr.l      #2,d0
bitblt_scale3:
		move.l     d0,r_splane_len(a6)
		move.w     r_dwidth(a6),d0
		lsr.w      #2,d0
		move.w     d0,r_dwidth(a6)
		move.l     r_dplane_len(a6),d0
		lsr.l      #2,d0
		move.l     d0,r_dplane_len(a6)
		move.l     (a7)+,d0

		movea.l    a0,a1
		lea.l      noclip_registers(a7),a0  /* pointer to unclipped coordinates */
		jsr        (a1)                     /* call scale_buf_init */
		move.l     a0,write_buffer(a7)
		move.l     a0,scale_buffer(a7)
		beq.s      scale_blt_err            /* error creating buffer? */

		movea.l    a2,a1
		lea.l      noclip_registers(a7),a0  /* pointer to unclipped coordinates */
		lea.l      scale_registers(a7),a2   /* pointer to register buffer */
		jsr        (a1)                     /* call scale_line_init */
		movea.l    a0,a4                    /* source address */
		move.l     a1,scale_jump(a7)        /* pointer to scale_line */
		move.l     a2,scale_jump_trans(a7)  /* pointer to scale_line_trans */

		lea.l      noclip_registers(a7),a0  /* pointer to unclipped coordinates */
		lea.l      write_registers(a7),a2   /* pointer to register buffer */
		jsr        (a3)                     /* call write_line_init */
		movea.l    a0,a5                    /* dest address */
		move.l     a1,write_jump(a7)        /* pointer to write_line */

		sub.w      noclip_qy(a7),d1         /* movement of qy-ccordinate from clipping */
		sub.w      noclip_zy(a7),d3         /* movement of zy-ccordinate from clipping */

		move.w     d7,d4
		move.w     noclip_zdy(a7),d6
		move.w     noclip_qdy(a7),d7

		cmp.w      #32767,d6                /* too large? */
		bcc.s      scale_ver_half
		cmp.w      #32767,d7                /* too large? */
		bcs.s      scale_ver_height
scale_ver_half:
		lsr.w      #1,d6                    /* cut in half, to prevent overflow */
		lsr.w      #1,d7
scale_ver_height:
		addq.w     #1,d6                    /* zdy + 1 = dy + 1 */
		addq.w     #1,d7                    /* qdy + 1 = dx + 1 */
		moveq.l    #DRV_PLANES-1,d0
scale_ver_loop:
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     #0x02,TS_I(a0)
		move.b     #0x04,GDC_I(a0)
		move.b     memwrite_table8(pc,d0.w),TS_D(a0)
		move.b     memread_table8(pc,d0.w),GDC_D(a0)
		movem.l    d0-d1/d3-d7/a4-a5,-(a7)
		bsr.w      scale_ver
		movem.l    (a7)+,d0-d1/d3-d7/a4-a5
		adda.l     r_splane_len(a6),a4      /* next source plane */
		adda.l     r_dplane_len(a6),a5      /* next dest plane */
		dbf        d0,scale_ver_loop
		movea.l    (a7),a0
		lea.l      SCALE_STACK(a7),a7
		movea.l    (a7)+,a1                 /* pointer to scale_buf_reset */
		jmp        (a1)                     /* free buffer */

memwrite_table8:
	dc.b 8,4,2,1
memread_table8:
	dc.b 3,2,1,0

SP_OFFSET         EQU      10*4                             /* Register d0-d1/d3-d7/a4-a5 und eine Ruecksprungadresse */

scale_ver:
		cmp.w      d7,d6
		ble.s      shrink_ver

/*
 * Stretch block vertical (Quellhoehe <= Zielhoehe, entspricht Linie mit dx <= dy)
 * Register d0-d7/a0-a5 are modified
 * Inputs:
 * d1.w movement of y-source coordinate from clipping
 * d3.w movement of y-dest coordinate from clipping
 * d4.w number of lines to write - 1
 * d5.w number of lines to read - 1
 * d6.w xa = dest height = dy + 1 (error for step to next source line)
 * d7.w ya = source height = dx + 1 (error for step to next dest line)
 * a4.l source address
 * a5.l dest address
 * a6.l workstation
 */
grow_ver:
		move.w     d6,d5
		neg.w      d5                       /* e = - dest height = - ( dy + 1 ) */
		ext.l      d5
		tst.w      d1                       /* move qy coordinate from clipping? */
		beq.s      grow_ver_offset
		mulu.w     d6,d1                    /* movement * xa = movement * ( dy + 1 ) */
		sub.l      d1,d5                    /* adjust e */
grow_ver_offset:
		tst.w      d3                       /* move zy coordinate from clipping? */
		beq.s      grow_ver_loop
		mulu.w     d7,d3                    /* movement * ya = movement * ( dx + 1 ) */
		add.l      d3,d5                    /* adjust e */
grow_ver_loop:
		lea.l      SP_OFFSET+scale_registers(a7),a2 /* pointer to register buffer */
		movea.l    a4,a0                            /* source address */
		movea.l    SP_OFFSET+scale_buffer(a7),a1    /* pointer to temp buffer */
		movea.l    SP_OFFSET+scale_jump(a7),a3      /* pointer to scale_line */
		jsr        (a3)                             /* scale line */
grow_ver_test:
		lea.l      SP_OFFSET+write_buffer(a7),a2
		movea.l    (a2)+,a0                 /* pointer to temp buffer */
		movea.l    a5,a1                    /* dest address */
		movea.l    (a2)+,a3                 /* pointer to write_line, a2 points to register buffer */
		jsr        (a3)                     /* write line */
		adda.w     r_dwidth(a6),a5          /* next dest line address */
grow_ver_err:
		add.w      d7,d5                    /* + ya, next dest line */
		bpl.s      grow_ver_next            /* error >= 0, next source pixel? */
		dbf        d4,grow_ver_test         /* loop for number of lines */
		bra.s      grow_ver_exit
grow_ver_next:
		sub.w      d6,d5                    /* - xa, next source line */
		adda.w     r_swidth(a6),a4          /* next source line address */
		dbf        d4,grow_ver_loop         /* loop for number of lines */
grow_ver_exit:
		rts

/*
 * Shrink block vertical (Quellhoehe >= Zielhoehe, entspricht Linie mit dx >= dy)
 * Register d0-d7/a0-a5 are modified
 * Inputs:
 * d1.w movement of y-source coordinate from clipping
 * d3.w movement of y-dest coordinate from clipping
 * d4.w number of lines to write - 1
 * d5.w number of lines to read - 1
 * d6.w xa = dest height = dy + 1 (error for step to next source line)
 * d7.w ya = source height = dx + 1 (error for step to next dest line)
 * a4.l source address
 * a5.l dest address
 * a6.l workstation
 */
shrink_ver:
		move.w     d5,d4                    /* number of lines to read */
		move.w     d7,d5
		neg.w      d5                       /* e = - source height = - ( dx + 1 ) */
		ext.l      d5
		tst.w      d1                       /* move qy coordinate from clipping? */
		beq.s      shrink_ver_off
		mulu.w     d6,d1                    /* movement * xa = movement * ( dy + 1 ) */
		add.l      d1,d5                    /* adjust e */
shrink_ver_off:
		tst.w      d3                       /* move zy coordinate from clipping? */
		beq.s      shrink_ver_loop
		mulu.w     d7,d3                    /* movement * ya = movement * ( dx + 1 ) */
		sub.l      d3,d5                    /* adjust e */
shrink_ver_loop:
		movea.l    SP_OFFSET+scale_jump(a7),a3  /* pointer to scale_line */
		bra.s      shrink_ver_reg
shrink_ver_trans:
		movea.l    SP_OFFSET+scale_jump_trans(a7),a3  /* pointer to scale_line_trans */
shrink_ver_reg:
		lea.l      SP_OFFSET+scale_registers(a7),a2   /* pointer to register buffer */
		movea.l    a4,a0                              /* source address */
		movea.l    SP_OFFSET+scale_buffer(a7),a1      /* pointer to temp buffer */
		jsr        (a3)                               /* scale line */
shrink_ver_err:
		adda.w     r_swidth(a6),a4          /* next source line address */
		add.w      d6,d5                    /* +xa, next source line */
		bpl.s      shrink_ver_next          /* error >= 0, next dest line? */
		dbf        d4,shrink_ver_trans      /* loop for number of lines */
		moveq.l    #0,d4                    /* output line and leave loop */
shrink_ver_next:
		lea.l      SP_OFFSET+write_buffer(a7),a2
		movea.l    (a2)+,a0                 /* pointer to temp buffer */
		movea.l    a5,a1                    /* dest address */
		movea.l    (a2)+,a3                 /* pointer to write_line, a2 points to register buffer */
		jsr        (a3)                     /* write line */
		sub.w      d7,d5                    /* -ya, next dest line */
		adda.w     r_dwidth(a6),a5          /* next dest line address */
		dbf        d4,shrink_ver_loop       /* loop for number of lines */
		rts

/*
 * Buffer
 * Register d0-d7/a1-a7 must not be modified
 * INputs:
 * d0.w qx, linke x-Koordinate des Quellrechtecks
 * d1.w qy, obere y-Koordinate des Quellrechtecks
 * d2.w zx, linke x-Koordinate des Zielrechtecks
 * d3.w zy, obere y-Koordinate des Zielrechtecks
 * d4.w qdx, Breite der Quelle -1
 * d5.w qdy, Hoehe der Quelle -1
 * d6.w zdx, Breite des Ziels -1
 * d7.w zdy, Hoehe des Ziels -1
 * a6.l Workstation
 * Ausgaben:
 * a0.l Zeiger auf den Buffer oder 0L
 */
scale_buf_init:
		move.l     d0,-(a7)
		moveq.l    #15,d0
		and.w      d2,d0
		add.w      d6,d0
		lsr.w      #4,d0
		addq.w     #2,d0
		add.w      d0,d0
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_nmalloc(a0),a0
		jsr        (a0)
		move.l     (a7)+,d0
		rts

/*
 * Vorgaben:
 * Register d0-d7/a1-a7 duerfen nicht veraendert werden
 * Eingaben:
 * a0.l Zeiger auf den Buffer
 * a6.l Workstation
 * Ausgaben:
 */
scale_buf_reset:
		movem.l    d0/a0-a1,-(a7)
		movea.l    nvdi_struct(pc),a1
		movea.l    _nvdi_nmfree(a1),a1
		jsr        (a1)
		movem.l    (a7)+,d0/a0-a1
		rts

/*
 * Eingaben:
 * d0.w qx (linke x-Koordinate des Quellrechtecks)
 * d1.w qy (obere y-Koordinate des Quellrechtecks)
 * d2.w zx (linke x-Koordinate des Zielrechtecks)
 * d3.w zy (obere y-Koordinate des Zielrechtecks)
 * d4.w qdx (Breite der Quelle -1)
 * d5.w qdy (Hoehe der Quelle -1)
 * d6.w zdx (Breite des Ziels -1)
 * d7.w zdy (Hoehe des Ziels -1)
 * a0.l Zeiger auf die ungeclippten Koordinaten
 * a2.l Zeiger auf Buffer fuer Daten
 * a6.l Workstation
 * Ausgaben:
 * a0.l Startadresse des Quellzeigers
 * a1.l Zeiger auf scale_line
 * a2.l Zeiger auf scale_line_trans
 */
scale_line_init:
		movem.l    d0-d7,-(a7)
		movea.l    r_saddr(a6),a1
		muls.w     r_swidth(a6),d1
		adda.l     d1,a1
		move.w     d0,d1
		lsr.w      #4,d1
		add.w      d1,d1
		adda.w     d1,a1
scale_init_zx:
		move.w     d2,d7
		move.w     d4,d2
		move.w     d6,d3
		move.w     d0,d6
		moveq.l    #15,d4
		and.w      d6,d4
		moveq.l    #15,d5
		and.w      d7,d5
		sub.w      (a0),d6
		sub.w      4(a0),d7
		move.w     8(a0),d0
		move.w     12(a0),d1
		cmp.w      #32767,d0
		bcc.s      scale_init_half
		cmp.w      #32767,d1
		bcs.s      scale_init_width
scale_init_half:
		lsr.w      #1,d0
		lsr.w      #1,d1
scale_init_width:
		addq.w     #1,d0
		addq.w     #1,d1
scale_init_cmp:
		cmp.w      d0,d1
		ble.s      scale_init_shr
		move.w     d1,d2
		neg.w      d2
		ext.l      d2
		tst.w      d6
		beq.s      scale_init_gya
		mulu.w     d1,d6
		sub.l      d6,d2
scale_init_gya:
		tst.w      d7
		beq.s      scale_init_exit
		mulu.w     d0,d7
		add.l      d7,d2
		bra.s      scale_init_exit
scale_init_shr:
		move.w     d0,d3
		neg.w      d3
		ext.l      d3
		tst.w      d6
		beq.s      scale_init_sya
		mulu.w     d1,d6
		add.l      d6,d3
scale_init_sya:
		tst.w      d7
		beq.s      scale_init_exit
		mulu.w     d0,d7
		sub.l      d7,d3
scale_init_exit:
		move.w     d1,d6
		move.w     d0,d7
		movem.w    d2-d7,(a2)
		movea.l    a1,a0
		lea.l      scale_line1(pc),a1
		lea.l      scale_line1_trans(pc),a2
		movem.l    (a7)+,d0-d7
		rts

/*
 * Zeile skalieren
 * Vorgaben:
 * Register d4-d7.w muessen werden gesichert
 * Register d0-d3/(d4-d7)/a0-a3 werden veraendert
 * Eingaben:
 * a0.l Quelladresse
 * a1.l Zieladresse
 * a2.l Zeiger auf den Parameter-Buffer
 * Ausgaben:
 */
scale_line1:
scale_line1_trans:
		movem.w    d4-d7,-(a7)
		movem.w    (a2),d2-d5/a2-a3
		cmpa.w     a3,a2
		ble.s      shrink_line1
grow_line1:
		move.w     #0x8000,d6
		moveq.l    #0,d7
		clr.w      (a1)
		bra.s      grow_line1_read
grow_line1_next:
		sub.w      a2,d2
		ror.w      #1,d6
		dbcs       d3,grow_line1_loop
		ror.l      d5,d7
		or.w       d7,(a1)+
		swap       d7
		move.w     d7,(a1)
		moveq.l    #0,d7
		subq.w     #1,d3
		bmi.s      grow_line1_exit
grow_line1_loop:
		dbf        d0,grow_line1_test
grow_line1_read:
		moveq.l    #15,d0
		move.l     (a0),d1
		addq.l     #2,a0
		lsl.l      d4,d1
		swap       d1
grow_line1_test:
		btst       d0,d1
		beq.s      grow_line1_err
		or.w       d6,d7
grow_line1_err:
		add.w      a3,d2
		bpl.s      grow_line1_next
		ror.w      #1,d6
		dbcs       d3,grow_line1_test
		ror.l      d5,d7
		or.w       d7,(a1)+
		swap       d7
		move.w     d7,(a1)
		moveq.l    #0,d7
		subq.w     #1,d3
		bpl.s      grow_line1_test
grow_line1_exit:
		movem.w    (a7)+,d4-d7
		rts

/*
 * Zeile verkleinern (Quellbreite >= Zielbreite, entspricht Linie mit dx >= dy)
 * Vorgaben:
 * Register d4-d7.w befinden sich gesichert auf dem Stack
 * Register d0-d3/d6-d7/a0-a1 werden veraendert
 * Eingaben:
 * d2.w Anzahl der einzulesenden Pixel - 1
 * d3.w e = - Quellbreite = - dx
 * d4.w Verschiebung der Quelldaten nach links (xs & 15)
 * d5.w Verschiebung der Zieldaten nach rechts (xd & 15)
 * a0.l Quelladresse
 * a1.l Zieladresse
 * a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
 * a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
 * a4.w Abstand zum naechsten Quellpixel der gleichen Ebene
 * Ausgaben:
 */
shrink_line1:
		move.w     #0x8000,d6
		moveq.l    #0,d7
		clr.w      (a1)
		bra.s      shrink_line1_read
shrink_line1_next:
		sub.w      a3,d3
		ror.w      #1,d6
		dbcs       d2,shrink_line1_loop
		ror.l      d5,d7
		or.w       d7,(a1)+
		swap       d7
		move.w     d7,(a1)
		moveq.l    #0,d7
		subq.w     #1,d2
		bmi.s      shrink_line1_exit
shrink_line1_loop:
		dbf        d0,shrink_line1_test
shrink_line1_read:
		moveq.l    #15,d0
		move.l     (a0),d1
		addq.l     #2,a0
		lsl.l      d4,d1
		swap       d1
shrink_line1_test:
		btst       d0,d1
		beq.s      shrink_line1_err
		or.w       d6,d7
shrink_line1_err:
		add.w      a2,d3
		bpl.s      shrink_line1_next
		dbf        d2,shrink_line1_loop
		ror.l      d5,d7
		or.w       d7,(a1)+
		swap       d7
		move.w     d7,(a1)
shrink_line1_exit:
		movem.w    (a7)+,d4-d7
		rts

/*
 * Eingaben:
 * d0.w qx (linke x-Koordinate des Quellrechtecks)
 * d1.w qy (obere y-Koordinate des Quellrechtecks)
 * d2.w zx (linke x-Koordinate des Zielrechtecks)
 * d3.w zy (obere y-Koordinate des Zielrechtecks)
 * d4.w qdx (Breite der Quelle -1)
 * d5.w qdy (Hoehe der Quelle -1)
 * d6.w zdx (Breite des Ziels -1)
 * d7.w zdy (Hoehe des Ziels -1)
 * a2.l Zeiger auf Buffer fuer Daten
 * a6.l Workstation
 * Ausgaben:
 * a0.l Startadresse des Zielzeigers
 * a1.l Zeiger auf write_line
 */
write_line_init:
		movem.l    d0-d3,-(a7)
		movea.l    r_daddr(a6),a0
		muls.w     r_dwidth(a6),d3
		adda.l     d3,a0
		move.w     d2,d3
		lsr.w      #4,d3
		add.w      d3,d3
		adda.w     d3,a0
		move.w     d2,d0
		move.w     d2,d1
		add.w      d6,d1
		moveq.l    #15,d3
		and.w      d3,d2
		add.w      d2,d2
		move.w     write_start_mask(pc,d2.w),d2
		not.w      d2
		and.w      d1,d3
		add.w      d3,d3
		move.w     write_end_mask(pc,d3.w),d3
		lsr.w      #4,d0
		lsr.w      #4,d1
		neg.w      d0
		add.w      d1,d0
		movem.w    d0/d2-d3,(a2)
		moveq.l    #31,d0
		and.w      r_wmode(a6),d0
		cmp.w      #16,d0
		blt.s      write_line_mode
		and.w      #3,d0
		add.w      d0,d0
		add.w      d0,d0
		moveq.l    #0,d1
		lsr.w      r_fg_pixel+2(a6)
		addx.w     d1,d1
		lsr.w      r_bg_pixel+2(a6)
		addx.w     d1,d1
		add.w      d0,d1
		move.b     wl_exp_modes(pc,d1.w),d0
write_line_mode:
		add.w      d0,d0
		move.w     wl_1_1_tab(pc,d0.w),d0
		lea.l      wl_1_1_tab(pc,d0.w),a1
		movem.l    (a7)+,d0-d3
		rts

wl_exp_modes:     DC.B 0,12,3,15          /* MD_REPLACE */
                  DC.B 4,4,7,7            /* MD_TRANS */
                  DC.B 6,6,6,6            /* MD_XOR */
                  DC.B 1,13,1,13          /* MD_ERASE */

write_start_mask:
	dc.w 0xffff
write_end_mask: 
	dc.w 0x7fff,0x3fff,0x1fff,0x0fff,0x07ff,0x03ff,0x01ff,0x00ff
	dc.w 0x007f,0x003f,0x001f,0x000f,0x0007,0x0003,0x0001,0x0000

wl_1_1_tab:       DC.W  wl_1_1_mode0-wl_1_1_tab
                  DC.W  wl_1_1_mode1-wl_1_1_tab
                  DC.W  wl_1_1_mode2-wl_1_1_tab
                  DC.W  wl_1_1_mode3-wl_1_1_tab
                  DC.W  wl_1_1_mode4-wl_1_1_tab
                  DC.W  wl_1_1_mode5-wl_1_1_tab
                  DC.W  wl_1_1_mode6-wl_1_1_tab
                  DC.W  wl_1_1_mode7-wl_1_1_tab
                  DC.W  wl_1_1_mode8-wl_1_1_tab
                  DC.W  wl_1_1_mode9-wl_1_1_tab
                  DC.W  wl_1_1_mode10-wl_1_1_tab
                  DC.W  wl_1_1_mode11-wl_1_1_tab
                  DC.W  wl_1_1_mode12-wl_1_1_tab
                  DC.W  wl_1_1_mode13-wl_1_1_tab
                  DC.W  wl_1_1_mode14-wl_1_1_tab
                  DC.W  wl_1_1_mode15-wl_1_1_tab


/* **************************************************************************** */

/* Zeile ausgeben, Modus 0 (ALL_ZERO) */
wl_1_1_mode0:
		movem.w    (a2),d0/d2-d3
		moveq.l    #0,d1
		and.w      d2,(a1)
		subq.w     #2,d0
		bmi.s      wl_1_1_m0_2nd
wl_1_1_m0_loop:
		move.w     d1,(a1)+
		dbf        d0,wl_1_1_m0_loop
wl_1_1_m0_end:
		and.w      d3,(a1)+
		rts
wl_1_1_m0_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m0_end
		rts

/* Zeile ausgeben, Modus 1 (S_AND_D) */
wl_1_1_mode1:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		or.w       d2,d1
		and.w      d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m1_2nd
wl_1_1_m1_loop:
		move.w     (a0)+,d1
		and.w      d1,(a1)+
		dbf        d0,wl_1_1_m1_loop
wl_1_1_m1_end:
		move.w     (a0)+,d1
		or.w       d3,d1
		and.w      d1,(a1)+
		rts
wl_1_1_m1_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m1_end
		rts

/* Zeile ausgeben, Modus 2 (S_AND_NOT_D) */
wl_1_1_mode2:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		or.w       d2,d1
		not.w      d2
		eor.w      d2,(a1)
		and.w      d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m2_2nd
wl_1_1_m2_loop:
		move.w     (a0)+,d1
		not.w      (a1)
		and.w      d1,(a1)+
		dbf        d0,wl_1_1_m2_loop
wl_1_1_m2_end:
		move.w     (a0)+,d1
		or.w       d3,d1
		not.w      d3
		eor.w      d3,(a1)
		and.w      d1,(a1)+
		rts
wl_1_1_m2_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m2_end
		rts

/* Zeile ausgeben, Modus 3 (S_ONLY) */
wl_1_1_mode3:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		and.w      d2,(a1)
		or.w       d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m3_2nd
wl_1_1_m3_loop:
		move.w     (a0)+,(a1)+
		dbf        d0,wl_1_1_m3_loop
wl_1_1_m3_end:
		move.w     (a0)+,d1
		and.w      d3,(a1)
		or.w       d1,(a1)+
		rts
wl_1_1_m3_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m3_end
		rts

/* Zeile ausgeben, Modus 4 (NOT_S_AND_D) */
wl_1_1_mode4:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		not.w      d1
		or.w       d2,d1
		and.w      d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m4_2nd
wl_1_1_m4_loop:
		move.w     (a0)+,d1
		not.w      d1
		and.w      d1,(a1)+
		dbf        d0,wl_1_1_m4_loop
wl_1_1_m4_end:
		move.w     (a0)+,d1
		not.w      d1
		or.w       d3,d1
		and.w      d1,(a1)+
		rts
wl_1_1_m4_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m4_end
		rts

/* Zeile ausgeben, Modus 5 (D_ONLY) */
wl_1_1_mode5:
		rts

/* Zeile ausgeben, Modus 6 (S_EOR_D) */
wl_1_1_mode6:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		eor.w      d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m6_2nd
wl_1_1_m6_loop:
		move.w     (a0)+,d1
		eor.w      d1,(a1)+
		dbf        d0,wl_1_1_m6_loop
wl_1_1_m6_end:
		move.w     (a0)+,d1
		eor.w      d1,(a1)+
		rts
wl_1_1_m6_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m6_end
		rts

/* Zeile ausgeben, Modus 7 (S_OR_D) */
wl_1_1_mode7:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		or.w       d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m7_2nd
wl_1_1_m7_loop:
		move.w     (a0)+,d1
		or.w       d1,(a1)+
		dbf        d0,wl_1_1_m7_loop
wl_1_1_m7_end:
		move.w     (a0)+,d1
		or.w       d1,(a1)+
		rts
wl_1_1_m7_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m7_end
		rts

/* Zeile ausgeben, Modus 8 (NOT_(S_OR_D)) */
wl_1_1_mode8:
		movem.w    (a2),d0/d2-d3
		not.w      d2
		not.w      d3
		move.w     (a0)+,d1
		or.w       d1,(a1)
		eor.w      d2,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m8_2nd
wl_1_1_m8_loop:
		move.w     (a0)+,d1
		or.w       d1,(a1)
		not.w      (a1)+
		dbf        d0,wl_1_1_m8_loop
wl_1_1_m8_end:
		move.w     (a0)+,d1
		or.w       d1,(a1)
		eor.w      d3,(a1)+
		rts
wl_1_1_m8_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m8_end
		rts

/* Zeile ausgeben, Modus 9 (NOT_(S_EOR_D)) */
wl_1_1_mode9:
		movem.w    (a2),d0/d2-d3
		not.w      d2
		not.w      d3
		move.w     (a0)+,d1
		eor.w      d1,(a1)
		eor.w      d2,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m9_2nd
wl_1_1_m9_loop:
		move.w     (a0)+,d1
		eor.w      d1,(a1)
		not.w      (a1)+
		dbf        d0,wl_1_1_m9_loop
wl_1_1_m9_end:
		move.w     (a0)+,d1
		eor.w      d1,(a1)
		eor.w      d3,(a1)+
		rts
wl_1_1_m9_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m9_end
		rts

/* Zeile ausgeben, Modus 10 (NOT_D) */
wl_1_1_mode10:
		movem.w    (a2),d0/d2-d3
		not.w      d2
		not.w      d3
		eor.w      d2,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m10_2nd
wl_1_1_m10_loop:
		not.w      (a1)+
		dbf        d0,wl_1_1_m10_loop
wl_1_1_m10_end:
		eor.w      d3,(a1)+
		rts
wl_1_1_m10_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m10_end
		rts

/* Zeile ausgeben, Modus 11 (S_OR_NOT_D) */
wl_1_1_mode11:
		movem.w    (a2),d0/d2-d3
		not.w      d2
		not.w      d3
		move.w     (a0)+,d1
		eor.w      d2,(a1)
		or.w       d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m11_2nd
wl_1_1_m11_loop:
		move.w     (a0)+,d1
		not.w      (a1)
		or.w       d1,(a1)+
		dbf        d0,wl_1_1_m11_loop
wl_1_1_m11_end:
		move.w     (a0)+,d1
		eor.w      d3,(a1)
		or.w       d1,(a1)+
		rts
wl_1_1_m11_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m11_end
		rts

/* Zeile ausgeben, Modus 12 (NOT_S) */
wl_1_1_mode12:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		and.w      d2,(a1)
		or.w       d2,d1
		not.w      d1
		or.w       d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m12_2nd
wl_1_1_m12_loop:
		move.w     (a0)+,d1
		not.w      d1
		move.w     d1,(a1)+
		dbf        d0,wl_1_1_m12_loop
wl_1_1_m12_end:
		move.w     (a0)+,d1
		and.w      d3,(a1)
		or.w       d3,d1
		not.w      d1
		or.w       d1,(a1)+
		rts
wl_1_1_m12_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m12_end
		rts

/* Zeile ausgeben, Modus 13 (NOT_S_OR_D) */
wl_1_1_mode13:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		or.w       d2,d1
		not.w      d1
		or.w       d1,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m13_2nd
wl_1_1_m13_loop:
		move.w     (a0)+,d1
		not.w      d1
		or.w       d1,(a1)+
		dbf        d0,wl_1_1_m13_loop
wl_1_1_m13_end:
		move.w     (a0)+,d1
		or.w       d3,d1
		not.w      d1
		or.w       d1,(a1)+
		rts
wl_1_1_m13_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m13_end
		rts

/* Zeile ausgeben, Modus 14 (NOT_(S_AND_D)) */
wl_1_1_mode14:
		movem.w    (a2),d0/d2-d3
		move.w     (a0)+,d1
		or.w       d2,d1
		and.w      d1,(a1)
		not.w      d2
		eor.w      d2,(a1)+
		subq.w     #2,d0
		bmi.s      wl_1_1_m14_2nd
wl_1_1_m14_loop:
		move.w     (a0)+,d1
		and.w      d1,(a1)
		not.w      (a1)+
		dbf        d0,wl_1_1_m14_loop
wl_1_1_m14_end:
		move.w     (a0)+,d1
		or.w       d3,d1
		and.w      d1,(a1)
		not.w      d3
		eor.w      d3,(a1)+
		rts
wl_1_1_m14_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m14_end
		rts

/* Zeile ausgeben, Modus 15  (ALL_ONE) */
wl_1_1_mode15:
		movem.w    (a2),d0/d2-d3
		moveq.l    #-1,d1
		not.w      d2
		not.w      d3
		or.w       d2,(a1)
		subq.w     #2,d0
		bmi.s      wl_1_1_m15_2nd
wl_1_1_m15_loop:
		move.w     d1,(a1)+
		dbf        d0,wl_1_1_m15_loop
wl_1_1_m15_end:
		or.w       d3,(a1)+
		rts
wl_1_1_m15_2nd:
		addq.w     #1,d0
		beq.s      wl_1_1_m15_end
		rts

/* **************************************************************************** */
                  /* 'Rechteck' */

/*
 * gefuelltes Reckteck ohne Clipping per Software zeichnen
 * Vorgaben:
 * d0-d7/a0-a4/a6 duerfen veraendert werden
 * Eingaben:
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * a6.l Zeiger auf die Attributdaten
 * Ausgaben:
 * d0-d7/a0-a4/a6 werden veraendert
 */
fbox:
		tst.w      bitmap_width(a6)
		bne.s      fbox_mode2
		movea.l    v_bas_ad.w,a1
		move.w     wr_mode(a6),d7
		cmp.w      #MD_TRANS-1,d7
		bgt.s      fbox_mode2
		cmpa.l     vgamode+vga_membase(pc),a1
		bne.s      fbox_mode2
		move.w     f_interior(a6),d4
		tst.l      r_bg_pixel(a6)
		bne.s      fbox_usual
		tst.w      d7
		bne.s      fbox_usual
		tst.l      r_fg_pixel(a6)
		beq        fbox_white
		tst.w      d4
		bne.s      fbox_usual
		move.l     r_fg_pixel(a6),-(a7)
		clr.l      r_fg_pixel(a6)
		bsr        fbox_white
		move.l     (a7)+,r_fg_pixel(a6)
		rts
fbox_usual:
		subq.w     #1,d4 /* FIS_SOLID */
		beq        fbox_white
		subq.w     #1,d4
		bne.s      fbox_mode2
		cmpi.w     #8,f_style(a6)
		beq        fbox_white
		bgt.s      fbox_mode2
		tst.w      d7
		beq        fbox_solid
fbox_mode2:
		movea.l    f_pointer(a6),a0
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d4
relok146:
		tst.w      bitmap_width(a6)
		beq.s      fbox2
		lea.l      bitmap_off_x(a6),a1
		sub.w      (a1),d0
		sub.w      (a1)+,d2
		sub.w      (a1),d1
		sub.w      (a1)+,d3
		movea.l    bitmap_addr(a6),a1
		move.w     bitmap_width(a6),d4
fbox2:
		lsr.w      #2,d4
		movea.w    d4,a3
		muls.w     d1,d4
		adda.l     d4,a1
		move.w     d0,d5
		asr.w      #5,d0
		move.w     d0,d4
		add.w      d4,d4
		add.w      d4,d4
		adda.w     d4,a1
		sub.w      d1,d3
		moveq.l    #31,d6
		and.w      d6,d5
		moveq.l    #-1,d4
		lsr.l      d5,d4
		and.w      d2,d6
		eori.w     #31,d6
		moveq.l    #-1,d5
		lsl.l      d6,d5
		moveq.l    #15,d6
		add.w      bitmap_off_y(a6),d1
		and.w      d6,d1
		adda.w     d1,a0
		adda.w     d1,a0
		eor.w      d6,d1
		asr.w      #5,d2
		move.w     r_planes(a6),d6
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
		tst.w      bitmap_width(a6)
		bne        fbox5
		move.l     vgamode+vga_membase(pc),d7  /* inside graphic card memory? */
		cmpa.l     d7,a1
		bcs        fbox5
		add.l      #VGA_MEMSIZE,d7
		cmpa.l     d7,a1
		bcc        fbox5
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x04,GDC_I(a5)
fbox_loop:
		move.w     wr_mode(a6),d7
		lsr.w      (a7)
		addx.w     d7,d7
		lsr.w      2(a7)
		addx.w     d7,d7
		add.w      d7,d7
		movem.l    d0-d6/a0-a1/a3,-(a7)
		move.b     memwrite_table9(pc,d6.w),TS_D(a5)
		move.b     memread_table9(pc,d6.w),GDC_D(a5)
		pea.l      fbox3(pc)
		sub.w      d0,d2
		beq        fbox8
		move.w     d2,d0
		add.w      d0,d0
		add.w      d0,d0
		suba.w     d0,a3
		subq.w     #1,d2
		move.w     fbox_jmptable(pc,d7.w),d7
		jmp        fbox_jmptable(pc,d7.w)
fbox3:
		movem.l    (a7)+,d0-d6/a0-a1/a3
		tst.w      f_planes(a6)
		beq.s      fbox4
		lea.l      32(a0),a0
fbox4:
		dbf        d6,fbox_loop
		move.b     #0x0F,TS_D(a5)
		addq.l     #4,a7
		rts

memwrite_table9:
	dc.b 8,4,2,1
memread_table9:
	dc.b 3,2,1,0

fbox_jmptable:
	dc.w fbox_repl_00-fbox_jmptable
    dc.w fbox_repl_01-fbox_jmptable
	dc.w fbox_repl_10-fbox_jmptable
	dc.w fbox_repl_11-fbox_jmptable
	dc.w fbox_trans_00-fbox_jmptable
	dc.w fbox_trans_01-fbox_jmptable
	dc.w fbox_trans_10-fbox_jmptable
	dc.w fbox_trans_11-fbox_jmptable
	dc.w fbox_eor_00-fbox_jmptable
	dc.w fbox_eor_01-fbox_jmptable
	dc.w fbox_eor_10-fbox_jmptable
	dc.w fbox_eor_11-fbox_jmptable
	dc.w fbox_erase_00-fbox_jmptable
	dc.w fbox_erase_01-fbox_jmptable
	dc.w fbox_erase_10-fbox_jmptable
	dc.w fbox_erase_11-fbox_jmptable

fbox5:
		move.w     wr_mode(a6),d7
		lsr.w      (a7)
		addx.w     d7,d7
		lsr.w      2(a7)
		addx.w     d7,d7
		add.w      d7,d7
		movem.l    d0-d6/a0-a1/a3,-(a7)
		pea.l      fbox6(pc)
		sub.w      d0,d2
		beq.s      fbox8
		move.w     d2,d0
		add.w      d0,d0
		add.w      d0,d0
		suba.w     d0,a3
		subq.w     #1,d2
		move.w     fbox_jmptable(pc,d7.w),d7
		jmp        fbox_jmptable(pc,d7.w)
fbox6:
		movem.l    (a7)+,d0-d6/a0-a1/a3
		tst.w      f_planes(a6)
		beq.s      fbox7
		lea.l      32(a0),a0
fbox7:
		move.l     bitmap_len(a6),d7
		lsr.l      #2,d7
		adda.l     d7,a1
		dbf        d6,fbox5
		addq.l     #4,a7
		rts

fbox8:
		and.l      d5,d4
		move.l     d4,d5
		not.l      d5
		bra        fbox10

fbox_repl_00:
		moveq.l    #0,d7
		not.l      d4
		not.l      d5
fbox_repl_00_1:
		move.w     d2,d0
		and.l      d4,(a1)+
		bra.s      fbox_repl_00_3
fbox_repl_00_2:
		move.l     d7,(a1)+
fbox_repl_00_3:
		dbf        d0,fbox_repl_00_2
		and.l      d5,(a1)
		adda.w     a3,a1
		dbf        d3,fbox_repl_00_1
		rts

fbox_repl_01:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		move.l     d6,d7
		not.l      d7
		and.l      d4,d6
		or.l       d4,(a1)
		eor.l      d6,(a1)+
		bra.s      fbox_repl_01_2
fbox_repl_01_1:
		move.l     d7,(a1)+
fbox_repl_01_2:
		dbf        d0,fbox_repl_01_1
		not.l      d7
		and.l      d5,d7
		or.l       d5,(a1)
		eor.l      d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_repl_01_3
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_repl_01_3:
		dbf        d3,fbox_repl_01
		rts

fbox_repl_10:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		move.l     d6,d7
		not.l      d6
		and.l      d4,d6
		or.l       d4,(a1)
		eor.l      d6,(a1)+
		bra.s      fbox_repl_10_2
fbox_repl_10_1:
		move.l     d7,(a1)+
fbox_repl_10_2:
		dbf        d0,fbox_repl_10_1
		not.l      d7
		and.l      d5,d7
		or.l       d5,(a1)
		eor.l      d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_repl_10_3
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_repl_10_3:
		dbf        d3,fbox_repl_10
		rts

fbox_repl_11:
		moveq.l    #-1,d7
fbox_repl_11_1:
		move.w     d2,d0
		or.l       d4,(a1)+
		bra.s      fbox_repl_11_3
fbox_repl_11_2:
		move.l     d7,(a1)+
fbox_repl_11_3:
		dbf        d0,fbox_repl_11_2
		or.l       d5,(a1)
		adda.w     a3,a1
		dbf        d3,fbox_repl_11_1
		rts

fbox_trans_00:
fbox_trans_01:
		not.l      d4
		not.l      d5
fbox_trans_00_1:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		not.l      d6
		move.l     d6,d7
		or.l       d4,d6
		and.l      d6,(a1)+
		bra.s      fbox_trans_00_3
fbox_trans_00_2:
		and.l      d7,(a1)+
fbox_trans_00_3:
		dbf        d0,fbox_trans_00_2
		or.l       d5,d7
		and.l      d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_trans_00_4
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_trans_00_4:
		dbf        d3,fbox_trans_00_1
		rts

fbox_trans_10:
fbox_trans_11:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		move.l     d6,d7
		and.l      d4,d6
		or.l       d6,(a1)+
		bra.s      fbox_trans_10_2
fbox_trans_10_1:
		or.l       d7,(a1)+
fbox_trans_10_2:
		dbf        d0,fbox_trans_10_1
		and.l      d5,d7
		or.l       d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_trans_10_3
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_trans_10_3:
		dbf        d3,fbox_trans_10
		rts

fbox_eor_00:
fbox_eor_01:
fbox_eor_10:
fbox_eor_11:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		move.l     d6,d7
		and.l      d4,d6
		eor.l      d6,(a1)+
		bra.s      fbox_eor_00_2
fbox_eor_00_1:
		eor.l      d7,(a1)+
fbox_eor_00_2:
		dbf        d0,fbox_eor_00_1
		and.l      d5,d7
		eor.l      d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_eor_00_3
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_eor_00_3:
		dbf        d3,fbox_eor_00
		rts

fbox_erase_00:
fbox_erase_10:
		not.l      d4
		not.l      d5
fbox_erase_00_1:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		move.l     d6,d7
		or.l       d4,d6
		and.l      d6,(a1)+
		bra.s      fbox_erase_00_3
fbox_erase_00_2:
		and.l      d7,(a1)+
fbox_erase_00_3:
		dbf        d0,fbox_erase_00_2
		or.l       d5,d7
		and.l      d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_erase_00_4
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_erase_00_4:
		dbf        d3,fbox_erase_00_1
		rts

fbox_erase_01:
fbox_erase_11:
		move.w     d2,d0
		move.l     (a0),d6
		move.w     (a0)+,d6
		not.l      d6
		move.l     d6,d7
		and.l      d4,d6
		or.l       d6,(a1)+
		bra.s      fbox_erase_01_2
fbox_erase_01_1:
		or.l       d7,(a1)+
fbox_erase_01_2:
		dbf        d0,fbox_erase_01_1
		and.l      d5,d7
		or.l       d7,(a1)
		adda.w     a3,a1
		dbf        d1,fbox_erase_01_3
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fbox_erase_01_3:
		dbf        d3,fbox_erase_01
		rts

fbox9:
		swap       d4
		move.w     d5,d4
		move.l     d4,d5
		not.l      d5
fbox10:
		move.w     fboxl_jmptable(pc,d7.w),d7
		jmp        fboxl_jmptable(pc,d7.w)

fboxl_jmptable:
		dc.w fboxl_repl_00-fboxl_jmptable
		dc.w fboxl_repl_01-fboxl_jmptable
		dc.w fboxl_repl_10-fboxl_jmptable
		dc.w fboxl_repl_11-fboxl_jmptable
		dc.w fboxl_trans_00-fboxl_jmptable
		dc.w fboxl_trans_01-fboxl_jmptable
		dc.w fboxl_trans_10-fboxl_jmptable
		dc.w fboxl_trans_11-fboxl_jmptable
		dc.w fboxl_eor_00-fboxl_jmptable
		dc.w fboxl_eor_01-fboxl_jmptable
		dc.w fboxl_eor_10-fboxl_jmptable
		dc.w fboxl_eor_11-fboxl_jmptable
		dc.w fboxl_erase_00-fboxl_jmptable
		dc.w fboxl_erase_01-fboxl_jmptable
		dc.w fboxl_erase_10-fboxl_jmptable
		dc.w fboxl_erase_11-fboxl_jmptable

fboxl_repl_00:
		and.l      d5,(a1)
		adda.w     a3,a1
		dbf        d3,fboxl_repl_00
		rts

fboxl_repl_01:
		move.l     (a0),d6
		move.w     (a0)+,d6
		not.l      d6
		and.l      d4,d6
		and.l      d5,(a1)
		or.l       d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_repl_01_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_repl_01_next:
		dbf        d3,fboxl_repl_01
		rts

fboxl_repl_10:
		move.l     (a0),d6
		move.w     (a0)+,d6
		and.l      d4,d6
		and.l      d5,(a1)
		or.l       d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_repl_10_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_repl_10_next:
		dbf        d3,fboxl_repl_10
		rts

fboxl_repl_11:
		or.l       d4,(a1)
		adda.w     a3,a1
		dbf        d3,fboxl_repl_11
		rts

fboxl_trans_00:
fboxl_trans_01:
		move.l     (a0),d6
		move.w     (a0)+,d6
		not.l      d6
		or.l       d5,d6
		and.l      d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_trans_00_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_trans_00_next:
		dbf        d3,fboxl_trans_00
		rts

fboxl_trans_10:
fboxl_trans_11:
		move.l     (a0),d6
		move.w     (a0)+,d6
		and.l      d4,d6
		or.l       d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_trans_10_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_trans_10_next:
		dbf        d3,fboxl_trans_10
		rts

fboxl_eor_00:
fboxl_eor_01:
fboxl_eor_10:
fboxl_eor_11:
		move.l     (a0),d6
		move.w     (a0)+,d6
		and.l      d4,d6
		eor.l      d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_eor_00_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_eor_00_next:
		dbf        d3,fboxl_eor_00
		rts

fboxl_erase_00:
fboxl_erase_10:
		move.l     (a0),d6
		move.w     (a0)+,d6
		or.l       d5,d6
		and.l      d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_erase_00_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_erase_00_next:
		dbf        d3,fboxl_erase_00
		rts

fboxl_erase_01:
fboxl_erase_11:
		move.l     (a0),d6
		move.w     (a0)+,d6
		not.l      d6
		and.l      d4,d6
		or.l       d6,(a1)
		adda.w     a3,a1
		dbf        d1,fboxl_erase_01_next
		moveq.l    #15,d1
		lea.l      -32(a0),a0
fboxl_erase_01_next:
		dbf        d3,fboxl_erase_01
		rts

fbox_white:
		move.l     r_fg_pixel(a6),d4
		not.b      d4
		tst.w      is_mste
		beq.s      fbox_w1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
fbox_w1:
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     d4,(a5)
		move.b     #0x00,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x08,(a5)+
		sub.w      d1,d3
		moveq.l    #-1,d4
		moveq.l    #-1,d5
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d2,d7
		eor.w      d6,d7
		and.w      d0,d6
		lsr.b      d6,d4
		lsl.b      d7,d5
		move.w     BYTES_LIN.w,d7
relok147:
		lsr.w      #2,d7
		mulu.w     d7,d1
		adda.l     d1,a1
		move.w     d0,d1
		lsr.w      #3,d1
		adda.w     d1,a1
		lsr.w      #3,d2
		sub.w      d1,d2
		sub.w      d2,d7
		cmp.w      #8,d2
		blt.s      fbox_w8
		lea.l      fbox_w4(pc),a0
		btst       #0,d1
		bne.s      fbox_w2
		subq.l     #2,a0
		subq.w     #1,d2
fbox_w2:
		subq.w     #1,d2
		move.w     d2,d0
		lsr.w      #2,d2
		subq.w     #1,d2
		not.w      d0
		and.w      #3,d0
		add.w      d0,d0
		lea.l      fbox_w6(pc,d0.w),a4
		moveq.l    #-1,d0
fbox_w3:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     d0,(a5)
		jmp        (a0)
		move.b     d0,(a1)+
fbox_w4:
		move.w     d2,d6
fbox_w5:
		move.l     d0,(a1)+
		dbf        d6,fbox_w5
		jmp        (a4)
fbox_w6:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)
		adda.w     d7,a1
		dbf        d3,fbox_w3
		move.b     d0,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      fbox_w7
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
fbox_w7:
		rts
fbox_w8:
		moveq.l    #-1,d0
		subq.w     #1,d7
		move.w     d2,d1
		not.w      d1
		and.w      #7,d1
		add.w      d1,d1
		lea.l      fbox_w10(pc,d1.w),a0
		tst.w      d2
		bne.s      fbox_w9
		lea.l      fbox_w11(pc),a0
		and.w      d5,d4
fbox_w9:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     d0,(a5)
		jmp        (a0)
fbox_w10:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
fbox_w11:
		adda.w     d7,a1
		dbf        d3,fbox_w9
		move.b     d0,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      fbox_w12
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
fbox_w12:
		rts

fbox_solid:
		move.l     r_fg_pixel(a6),d4
		not.b      d4
		tst.w      is_mste
		beq.s      fbox_s1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
fbox_s1:
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     d4,(a5)
		move.b     #0x00,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x08,(a5)+
		sub.w      d1,d3
		moveq.l    #-1,d4
		moveq.l    #-1,d5
		moveq.l    #7,d6
		moveq.l    #7,d7
		and.w      d2,d7
		eor.w      d6,d7
		and.w      d0,d6
		lsr.b      d6,d4
		lsl.b      d7,d5
		move.w     BYTES_LIN.w,d7
relok148:
		lsr.w      #2,d7
		mulu.w     d1,d7
		adda.l     d7,a1
		lsr.w      #3,d0
		adda.w     d0,a1
		lsr.w      #3,d2
		sub.w      d0,d2
		move.w     BYTES_LIN.w,d7
relok149:
		lsl.w      #2,d7
		sub.w      d2,d7
		movea.w    d7,a3
		moveq.l    #15,d7
		cmp.w      d7,d3
		bge.s      fbox_s2
		move.w     d3,d7
fbox_s2:
		swap       d3
		move.w     d7,d3
		movea.l    198(a6),a0
		moveq.l    #15,d7
		and.w      d1,d7
		adda.w     d7,a0
		adda.w     d7,a0
		eori.w     #15,d7
		cmp.w      #8,d2
		blt        fbox_s10
		move.l     a6,-(a7)
		lea.l      fbox_s6(pc),a6
		btst       #0,d0
		bne.s      fbox_s3
		subq.l     #2,a6
		subq.w     #1,d2
fbox_s3:
		subq.w     #1,d2
		move.w     d2,d0
		lsr.w      #2,d2
		subq.w     #1,d2
		not.w      d0
		and.w      #3,d0
		add.w      d0,d0
		lea.l      fbox_s8(pc,d0.w),a4
fbox_s4:
		swap       d3
		move.w     d3,-(a7)
		move.l     a1,-(a7)
		lsr.w      #4,d3
		move.l     (a0),d0
		move.w     (a0)+,d0
		dbf        d7,fbox_s5
		lea.l      -32(a0),a0
		moveq.l    #15,d7
fbox_s5:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     #0xFF,(a5)
		jmp        (a6)
		move.b     d0,(a1)+
fbox_s6:
		move.w     d2,d6
fbox_s7:
		move.l     d0,(a1)+
		dbf        d6,fbox_s7
		jmp        (a4)
fbox_s8:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)
		adda.w     a3,a1
		dbf        d3,fbox_s5
		movea.l    (a7)+,a1
		move.w     (a7)+,d3
		subq.w     #1,d3
		swap       d3
		move.w     BYTES_LIN.w,d0
relok150:
		lsr.w      #2,d0
		adda.w     d0,a1
		dbf        d3,fbox_s4
		move.b     #0xFF,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		movea.l    (a7)+,a6
		tst.w      is_mste
		beq.s      fbox_s9
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
fbox_s9:
		rts
fbox_s10:
		subq.w     #1,a3
		move.w     d2,d1
		not.w      d1
		and.w      #7,d1
		add.w      d1,d1
		lea.l      fbox_s13(pc,d1.w),a4
		tst.w      d2
		bne.s      fbox_s11
		lea.l      fbox_s14(pc),a4
		and.w      d5,d4
fbox_s11:
		swap       d3
		move.w     d3,-(a7)
		move.l     a1,-(a7)
		lsr.w      #4,d3
		move.l     (a0),d0
		move.w     (a0)+,d0
		dbf        d7,fbox_s12
		lea.l      -32(a0),a0
		moveq.l    #15,d7
fbox_s12:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     #0xFF,(a5)
		jmp        (a4)
fbox_s13:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
fbox_s14:
		adda.w     a3,a1
		dbf        d3,fbox_s12
		movea.l    (a7)+,a1
		move.w     (a7)+,d3
		subq.w     #1,d3
		swap       d3
		move.w     BYTES_LIN.w,d0
relok151:
		lsr.w      #2,d0
		adda.w     d0,a1
		dbf        d3,fbox_s11
		move.b     #0xFF,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      fbox_s15
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
fbox_s15:
		rts

/* **************************************************************************** */
                  /* 'horizontale Linie' */

/*
 * horizontalen Linie mit Fuellmuster ohne Clipping zeichnen
 * Vorgaben:
 * d0-d2/d4-d7/a1 duerfen veraendert werden
 * Eingaben:
 * d0.w x1
 * d1.w y
 * d2.w x2
 * d7.w Schreibmodus
 * a6.l Zeiger auf die Workstation
 * Ausgaben:
 */
fline:
		movem.l    a0/a5,-(a7)
		movea.l    f_pointer(a6),a0
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d4
relok152:
		tst.w      bitmap_width(a6)
		beq.s      fline_screen
		lea.l      bitmap_off_x(a6),a1
		sub.w      (a1),d0
		sub.w      (a1)+,d2
		sub.w      (a1),d1
		sub.w      (a1)+,d3
		movea.l    bitmap_addr(a6),a1
		move.w     bitmap_width(a6),d4
fline_screen:
		lsr.w      #2,d4
		muls.w     d1,d4
		adda.l     d4,a1
		move.w     d0,d5
		asr.w      #5,d0
		move.w     d0,d4
		add.w      d4,d4
		add.w      d4,d4
		adda.w     d4,a1
		sub.w      d1,d3
		moveq.l    #31,d6
		and.w      d6,d5
		moveq.l    #-1,d4
		lsr.l      d5,d4
		and.w      d2,d6
		eori.w     #31,d6
		moveq.l    #-1,d5
		lsl.l      d6,d5
		moveq.l    #15,d6
		add.w      bitmap_off_y(a6),d1
		and.w      d6,d1
		adda.w     d1,a0
		adda.w     d1,a0
		eor.w      d6,d1
		asr.w      #5,d2
		sub.w      d0,d2
		subq.w     #1,d2
		move.w     r_planes(a6),d6
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
		move.l     vgamode+vga_membase(pc),d1 /* inside graphic card memory? */
		cmpa.l     d1,a1
		bcs        fline_soft
		add.l      #VGA_MEMSIZE,d1
		cmpa.l     d1,a1
		bcc        fline_soft
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x04,GDC_I(a5)
fline_loop:
		move.w     wr_mode(a6),d7
		lsr.w      (a7)
		addx.w     d7,d7
		lsr.w      2(a7)
		addx.w     d7,d7
		add.w      d7,d7
		movem.l    d2-d6/a1,-(a7)
		move.b     memwrite_table10(pc,d6.w),TS_D(a5)
		move.b     memread_table10(pc,d6.w),GDC_D(a5)
		move.l     (a0),d6
		move.w     (a0),d6
		pea.l      fline1(pc)
		tst.w      d2
		bmi        fline_single
		move.w     fline_jmptable(pc,d7.w),d7
		jmp        fline_jmptable(pc,d7.w)
fline1:
		movem.l    (a7)+,d2-d6/a1
		tst.w      f_planes(a6)
		beq.s      fline2
		lea.l      32(a0),a0
fline2:
		dbf        d6,fline_loop
		move.b     #0x0F,TS_D(a5)
		addq.l     #4,a7
		movem.l    (a7)+,a0/a5
		rts

memwrite_table10:
	dc.b 8,4,2,1
memread_table10:
	dc.b 3,2,1,0

fline_jmptable:
		dc.w fline_repl_00-fline_jmptable
		dc.w fline_repl_01-fline_jmptable
		dc.w fline_repl_10-fline_jmptable
		dc.w fline_repl_11-fline_jmptable
		dc.w fline_trans_00-fline_jmptable
		dc.w fline_trans_01-fline_jmptable
		dc.w fline_trans_10-fline_jmptable
		dc.w fline_trans_11-fline_jmptable
		dc.w fline_eor_00-fline_jmptable
		dc.w fline_eor_01-fline_jmptable
		dc.w fline_eor_10-fline_jmptable
		dc.w fline_eor_11-fline_jmptable
		dc.w fline_erase_00-fline_jmptable
		dc.w fline_erase_01-fline_jmptable
		dc.w fline_erase_10-fline_jmptable
		dc.w fline_erase_11-fline_jmptable

fline_soft:
		move.w     wr_mode(a6),d7
		lsr.w      (a7)
		addx.w     d7,d7
		lsr.w      2(a7)
		addx.w     d7,d7
		add.w      d7,d7
		movem.l    d2-d6/a1,-(a7)
		move.l     (a0),d6
		move.w     (a0),d6
		pea.l      fline_so1(pc)
		tst.w      d2
		bmi        fline_single
		move.w     fline_jmptable(pc,d7.w),d7
		jmp        fline_jmptable(pc,d7.w)
fline_so1:
		movem.l    (a7)+,d2-d6/a1
		tst.w      f_planes(a6)
		beq.s      fline_so2
		lea.l      32(a0),a0
fline_so2:
		move.l     bitmap_len(a6),d0
		lsr.l      #2,d0
		adda.l     d0,a1
		dbf        d6,fline_soft
		addq.l     #4,a7
		movem.l    (a7)+,a0/a5
		rts

fline_repl_00:
		moveq.l    #0,d7
		not.l      d4
		not.l      d5
		move.w     d2,d0
		and.l      d4,(a1)+
		bra.s      fline_repl_00_2
fline_repl_00_1:
		move.l     d7,(a1)+
fline_repl_00_2:
		dbf        d0,fline_repl_00_1
		and.l      d5,(a1)
		rts

fline_repl_01:
		move.w     d2,d0
		move.l     d6,d7
		not.l      d7
		and.l      d4,d6
		or.l       d4,(a1)
		eor.l      d6,(a1)+
		bra.s      fline_repl_01_2
fline_repl_01_1:
		move.l     d7,(a1)+
fline_repl_01_2:
		dbf        d0,fline_repl_01_1
		not.l      d7
		and.l      d5,d7
		or.l       d5,(a1)
		eor.l      d7,(a1)
		rts

fline_repl_10:
		move.w     d2,d0
		move.l     d6,d7
		not.l      d6
		and.l      d4,d6
		or.l       d4,(a1)
		eor.l      d6,(a1)+
		bra.s      fline_repl_10_2
fline_repl_10_1:
		move.l     d7,(a1)+
fline_repl_10_2:
		dbf        d0,fline_repl_10_1
		not.l      d7
		and.l      d5,d7
		or.l       d5,(a1)
		eor.l      d7,(a1)
		rts

fline_repl_11:
		moveq.l    #-1,d7
		move.w     d2,d0
		or.l       d4,(a1)+
		bra.s      fline_repl_11_2
fline_repl_11_1:
		move.l     d7,(a1)+
fline_repl_11_2:
		dbf        d0,fline_repl_11_1
		or.l       d5,(a1)
		rts

fline_trans_00:
fline_trans_01:
		not.l      d4
		not.l      d5
		move.w     d2,d0
		not.l      d6
		move.l     d6,d7
		or.l       d4,d6
		and.l      d6,(a1)+
		bra.s      fline_trans_00_2
fline_trans_00_1:
		and.l      d7,(a1)+
fline_trans_00_2:
		dbf        d0,fline_trans_00_1
		or.l       d5,d7
		and.l      d7,(a1)
		rts

fline_trans_10:
fline_trans_11:
		move.w     d2,d0
		move.l     d6,d7
		and.l      d4,d6
		or.l       d6,(a1)+
		bra.s      fline_trans_10_2
fline_trans_10_1:
		or.l       d7,(a1)+
fline_trans_10_2:
		dbf        d0,fline_trans_10_1
		and.l      d5,d7
		or.l       d7,(a1)
		rts

fline_eor_00:
fline_eor_01:
fline_eor_10:
fline_eor_11:
		move.w     d2,d0
		move.l     d6,d7
		and.l      d4,d6
		eor.l      d6,(a1)+
		bra.s      fline_eor_00_2
fline_eor_00_1:
		eor.l      d7,(a1)+
fline_eor_00_2:
		dbf        d0,fline_eor_00_1
		and.l      d5,d7
		eor.l      d7,(a1)
		rts

fline_erase_00:
fline_erase_10:
		not.l      d4
		not.l      d5
		move.w     d2,d0
		move.l     d6,d7
		or.l       d4,d6
		and.l      d6,(a1)+
		bra.s      fline_erase_00_2
fline_erase_00_1:
		and.l      d7,(a1)+
fline_erase_00_2:
		dbf        d0,fline_erase_00_1
		or.l       d5,d7
		and.l      d7,(a1)
		rts

fline_erase_01:
fline_erase_11:
		move.w     d2,d0
		not.l      d6
		move.l     d6,d7
		and.l      d4,d6
		or.l       d6,(a1)+
		bra.s      fline_erase_01_2
fline_erase_01_1:
		or.l       d7,(a1)+
fline_erase_01_2:
		dbf        d0,fline_erase_01_1
		and.l      d5,d7
		or.l       d7,(a1)
		rts

fline_single:
		and.l      d5,d4
		move.l     d4,d5
		not.l      d5
		move.w     flines_jmptable(pc,d7.w),d7
		jmp        flines_jmptable(pc,d7.w)

flines_jmptable:
		dc.w flines_repl_00-flines_jmptable
		dc.w flines_repl_01-flines_jmptable
		dc.w flines_repl_10-flines_jmptable
		dc.w flines_repl_11-flines_jmptable
		dc.w flines_trans_00-flines_jmptable
		dc.w flines_trans_01-flines_jmptable
		dc.w flines_trans_10-flines_jmptable
		dc.w flines_trans_11-flines_jmptable
		dc.w flines_eor_00-flines_jmptable
		dc.w flines_eor_01-flines_jmptable
		dc.w flines_eor_10-flines_jmptable
		dc.w flines_eor_11-flines_jmptable
		dc.w flines_erase_00-flines_jmptable
		dc.w flines_erase_01-flines_jmptable
		dc.w flines_erase_10-flines_jmptable
		dc.w flines_erase_11-flines_jmptable

flines_repl_00:
		and.l      d5,(a1)
		rts

flines_repl_01:
		not.l      d6
		and.l      d4,d6
		and.l      d5,(a1)
		or.l       d6,(a1)
		rts

flines_repl_10:
		and.l      d4,d6
		and.l      d5,(a1)
		or.l       d6,(a1)
		rts

flines_repl_11:
		or.l       d4,(a1)
		rts

flines_trans_00:
flines_trans_01:
		not.l      d6
		or.l       d5,d6
		and.l      d6,(a1)
		rts

flines_trans_10:
flines_trans_11:
		and.l      d4,d6
		or.l       d6,(a1)
		rts

flines_eor_00:
flines_eor_01:
flines_eor_10:
flines_eor_11:
		and.l      d4,d6
		eor.l      d6,(a1)
		rts

flines_erase_00:
flines_erase_10:
		or.l       d5,d6
		and.l      d6,(a1)
		rts

flines_erase_01:
flines_erase_11:
		not.l      d6
		and.l      d4,d6
		or.l       d6,(a1)
		rts

/* **************************************************************************** */

/*
 * horizontalen Linie ohne Clipping zeichnen
 * Vorgaben:
 * d0-d2/d4-d7/a1 duerfen zerstoert werden
 * Eingaben:
 * d0.w x1
 * d1.w y
 * d2.w x2
 * d6.w Linienstil
 * d7.w Schreibmodus
 * a6.l Zeiger auf die Workstation
 * Ausgaben:
 */
hline:
		moveq.l    #15,d4
		and.w      d0,d4
		ror.w      d4,d7
		tst.w      bitmap_width(a6)
		bne.s      hline3
		movea.l    v_bas_ad.w,a1
		cmpa.l     vgamode+vga_membase(pc),a1
		bne.s      hline3
		tst.l      r_bg_pixel(a6)
		bne.s      hline3
		move.w     wr_mode(a6),d6
		cmp.w      #2,d6
		bgt.s      hline3
		beq.s      hline2
		tst.w      d6
		beq.s      hline1
		cmp.w      #-1,d7
		beq        hline_solid
		bra.s      hline3
hline1:
		move.w     d7,d4
		lsr.w      #8,d4
		cmp.b      d7,d4
		beq        hline_solid
		bra.s      hline3
hline2:
		move.w     d7,d4
		lsr.w      #8,d4
		cmp.b      d7,d4
		beq        hline_mono
hline3:
		move.w     bitmap_width(a6),d4
		beq.s      hline4
		lea.l      bitmap_off_x(a6),a1
		sub.w      (a1),d0
		sub.w      (a1)+,d2
		sub.w      (a1),d1
		movea.l    bitmap_addr(a6),a1
		bra.s      hline5
hline4:
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d4
relok153:
hline5:
		lsr.w      #2,d4
		muls.w     d4,d1
		adda.l     d1,a1
		move.w     d0,d1
		andi.w     #-32,d0
		asr.w      #3,d0
		adda.w     d0,a1
		move.w     d7,d5
		swap       d7
		move.w     d5,d7
		moveq.l    #31,d5
		and.w      d5,d1
		moveq.l    #-1,d4
		lsr.l      d1,d4
		move.w     d2,d1
		not.w      d1
		and.w      d5,d1
		moveq.l    #-1,d5
		lsl.l      d1,d5
		asr.w      #3,d2
		sub.w      d0,d2
		asr.w      #2,d2
		tst.w      bitmap_width(a6)
		bne        hline_soft
		move.l     vgamode+vga_membase(pc),d1 /* inside graphic card memory? */
		cmpa.l     d1,a1
		bcs        hline_soft
		add.l      #VGA_MEMSIZE,d1
		cmpa.l     d1,a1
		bcc        hline_soft
		move.l     a6,-(a7)
		move.w     r_planes(a6),d6
		move.w     wr_mode(a6),-(a7)
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
		movea.l    vgamode+vga_regbase(pc),a6
		move.b     #0x02,TS_I(a6)
		move.b     #0x04,GDC_I(a6)
hline6:
		move.w     4(a7),d1
		lsr.w      (a7)
		addx.w     d1,d1
		lsr.w      2(a7)
		addx.w     d1,d1
		add.w      d1,d1
		movem.l    d2-d7/a1,-(a7)
		move.b     memwrite_table11(pc,d6.w),TS_D(a6)
		move.b     memread_table11(pc,d6.w),GDC_D(a6)
		pea.l      hline7(pc)
		subq.w     #1,d2
		bmi        hline_single
		beq        hline_double
		subq.w     #1,d2
		move.w     d2,d0
		lsr.w      #5,d2
		not.w      d0
		andi.w     #31,d0
		add.w      d0,d0
		move.w     hline_jmptable(pc,d1.w),d1
		jmp        hline_jmptable(pc,d1.w)
hline7:
		movem.l    (a7)+,d2-d7/a1
hline8:
		dbf        d6,hline6
		move.b     #0x0F,TS_D(a6)
		addq.l     #6,a7
		movea.l    (a7)+,a6
		rts

memwrite_table11:
	dc.b 8,4,2,1
memread_table11:
	dc.b 3,2,1,0

hline_jmptable:
		dc.w hline_repl_00-hline_jmptable
		dc.w hline_repl_01-hline_jmptable
		dc.w hline_repl_10-hline_jmptable
		dc.w hline_repl_11-hline_jmptable
		dc.w hline_trans_00-hline_jmptable
		dc.w hline_trans_01-hline_jmptable
		dc.w hline_trans_10-hline_jmptable
		dc.w hline_trans_11-hline_jmptable
		dc.w hline_eor_00-hline_jmptable
		dc.w hline_eor_01-hline_jmptable
		dc.w hline_eor_10-hline_jmptable
		dc.w hline_eor_11-hline_jmptable
		dc.w hline_erase_00-hline_jmptable
		dc.w hline_erase_01-hline_jmptable
		dc.w hline_erase_10-hline_jmptable
		dc.w hline_erase_11-hline_jmptable

hline_soft:
		move.w     r_planes(a6),d6
		move.w     wr_mode(a6),-(a7)
		move.w     r_bg_pixel+2(a6),-(a7) 
		move.w     r_fg_pixel+2(a6),-(a7)
hline10:
		move.w     4(a7),d1
		lsr.w      (a7)
		addx.w     d1,d1
		lsr.w      2(a7)
		addx.w     d1,d1
		add.w      d1,d1
		movem.l    d2-d7/a1,-(a7)
		pea.l      hline11(pc)
		subq.w     #1,d2
		bmi        hline_single
		beq        hline_double
		subq.w     #1,d2
		move.w     d2,d0
		lsr.w      #5,d2
		not.w      d0
		andi.w     #31,d0
		add.w      d0,d0
		move.w     hline_jmptable(pc,d1.w),d1
		jmp        hline_jmptable(pc,d1.w)
hline11:
		movem.l    (a7)+,d2-d7/a1
		move.l     bitmap_len(a6),d0
		lsr.l      #2,d0
		adda.l     d0,a1
		dbf        d6,hline10
		addq.l     #4,a7
		rts

hline_repl_00:
		moveq.l    #0,d7
		bra.s      hline_repl_10
hline_repl_01:
		not.l      d7
		bra.s      hline_repl_10
hline_repl_11:
		moveq.l    #-1,d7
hline_repl_10:
		move.l     d7,d6
		and.l      d4,d6
		not.l      d4
		and.l      d4,(a1)
		or.l       d6,(a1)+
		jmp        hline_repl1(pc,d0.w)
hline_repl1:
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		dbf        d2,hline_repl1
		and.l      d5,d7
		not.l      d5
		and.l      d5,(a1)
		or.l       d7,(a1)
		rts

hline_trans_00:
hline_trans_01:
		not.l      d7
hline_erase_00:
hline_erase_10:
		not.l      d4
		or.l       d7,d4
		and.l      d4,(a1)+
		jmp        hline_trans1(pc,d0.w)
hline_trans1:
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		and.l      d7,(a1)+
		dbf        d2,hline_trans1
		not.l      d5
		or.l       d7,d5
		and.l      d5,(a1)
		rts

hline_erase_01:
hline_erase_11:
		not.l      d7
hline_trans_10:
hline_trans_11:
		cmp.w      #-1,d7
		beq        hline_repl_11
		and.l      d7,d4
		or.l       d4,(a1)+
		jmp        hline_erase1(pc,d0.w)
hline_erase1:
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		or.l       d7,(a1)+
		dbf        d2,hline_erase1
		and.l      d7,d5
		or.l       d5,(a1)
		rts

hline_eor_00:
hline_eor_01:
hline_eor_10:
hline_eor_11:
		and.l      d7,d4
		eor.l      d4,(a1)+
		jmp        hline_eor1(pc,d0.w)
hline_eor1:
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		eor.l      d7,(a1)+
		dbf        d2,hline_eor1
		and.l      d7,d5
		eor.l      d5,(a1)
		rts

hline_single:
		and.l      d5,d4
		move.w     hlines_jmptable(pc,d1.w),d1
		jmp        hlines_jmptable(pc,d1.w)

hlines_jmptable:
		dc.w hlines_repl_00-hlines_jmptable
		dc.w hlines_repl_01-hlines_jmptable
		dc.w hlines_repl_10-hlines_jmptable
		dc.w hlines_repl_11-hlines_jmptable
		dc.w hlines_trans_00-hlines_jmptable
		dc.w hlines_trans_01-hlines_jmptable
		dc.w hlines_trans_10-hlines_jmptable
		dc.w hlines_trans_11-hlines_jmptable
		dc.w hlines_eor_00-hlines_jmptable
		dc.w hlines_eor_01-hlines_jmptable
		dc.w hlines_eor_10-hlines_jmptable
		dc.w hlines_eor_11-hlines_jmptable
		dc.w hlines_erase_00-hlines_jmptable
		dc.w hlines_erase_01-hlines_jmptable
		dc.w hlines_erase_10-hlines_jmptable
		dc.w hlines_erase_11-hlines_jmptable

hlines_repl_00:
		not.l      d4
		and.l      d4,(a1)
		rts

hlines_repl_01:
		not.l      d7
hlines_repl_10:
		and.l      d4,d7
		not.l      d4
		and.l      d4,(a1)
		or.l       d7,(a1)
		rts
hlines_repl_11:
		or.l       d4,(a1)
		rts
hlines_trans_00:
hlines_trans_01:
		not.l      d7
hlines_erase_00:
hlines_erase_10:
		not.l      d4
		or.l       d7,d4
		and.l      d4,(a1)
		rts

hlines_erase_01:
hlines_erase_11:
		not.l      d7
hlines_trans_10:
hlines_trans_11:
		and.l      d7,d4
		or.l       d4,(a1)
		rts

hlines_eor_00:
hlines_eor_01:
hlines_eor_10:
hlines_eor_11:
		and.l      d7,d4
		eor.l      d4,(a1)
		rts

hline_double:
		move.w     hlined_jmptable(pc,d1.w),d1
		jmp        hlined_jmptable(pc,d1.w)

hlined_jmptable:
		dc.w hlined_repl_00-hlined_jmptable
		dc.w hlined_repl_01-hlined_jmptable
		dc.w hlined_repl_10-hlined_jmptable
		dc.w hlined_repl_11-hlined_jmptable
		dc.w hlined_trans_00-hlined_jmptable
		dc.w hlined_trans_01-hlined_jmptable
		dc.w hlined_trans_10-hlined_jmptable
		dc.w hlined_trans_11-hlined_jmptable
		dc.w hlined_eor_00-hlined_jmptable
		dc.w hlined_eor_01-hlined_jmptable
		dc.w hlined_eor_10-hlined_jmptable
		dc.w hlined_eor_11-hlined_jmptable
		dc.w hlined_erase_00-hlined_jmptable
		dc.w hlined_erase_01-hlined_jmptable
		dc.w hlined_erase_10-hlined_jmptable
		dc.w hlined_erase_11-hlined_jmptable

hlined_repl_00:
		not.l      d4
		and.l      d4,(a1)+
		not.l      d5
		and.l      d5,(a1)
		rts

hlined_repl_01:
		not.l      d7
hlined_repl_10:
		move.l     d7,d6
		and.l      d4,d7
		not.l      d4
		and.l      d4,(a1)
		or.l       d7,(a1)+
		and.l      d5,d6
		not.l      d5
		and.l      d5,(a1)
		or.l       d6,(a1)
		rts

hlined_repl_11:
		or.l       d4,(a1)+
		or.l       d5,(a1)
		rts

hlined_trans_00:
hlined_trans_01:
		not.l      d7
hlined_erase_00:
hlined_erase_10:
		not.l      d4
		or.l       d7,d4
		and.l      d4,(a1)+
		not.l      d5
		or.l       d7,d5
		and.l      d5,(a1)
		rts

hlined_erase_01:
hlined_erase_11:
		not.l      d7
hlined_trans_10:
hlined_trans_11:
		and.l      d7,d4
		or.l       d4,(a1)+
		and.l      d7,d5
		or.l       d5,(a1)
		rts

hlined_eor_00:
hlined_eor_01:
hlined_eor_10:
hlined_eor_11:
		and.l      d7,d4
		eor.l      d4,(a1)+
		and.l      d7,d5
		eor.l      d5,(a1)
		rts

hline_mono:
		move.l     a5,-(a7)
		tst.w      is_mste
		beq.s      hline_m1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
hline_m1:
		movea.l    vgamode+vga_regbase(pc),a5
		move.w     d7,-(a7)
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     #0x00,(a5)
		move.b     #0x03,-(a5)
		move.b     #0x18,1(a5)
		move.b     #0x08,(a5)+
		moveq.l    #-1,d4
		moveq.l    #-1,d5
		moveq.l    #7,d7
		moveq.l    #7,d6
		and.w      d2,d6
		eor.w      d7,d6
		and.w      d0,d7
		lsr.b      d7,d4
		lsl.b      d6,d5
		move.w     BYTES_LIN.w,d6
relok154:
		lsr.w      #2,d6
		mulu.w     d6,d1
		adda.l     d1,a1
		move.w     d0,d1
		lsr.w      #3,d1
		adda.w     d1,a1
		lsr.w      #3,d2
		sub.w      d1,d2
		move.w     (a7)+,d0
		subq.w     #1,d2
		bpl.s      hline_m2
		and.b      d4,d5
		bra.s      hline_m4
hline_m2:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		subq.w     #1,d2
		bmi.s      hline_m4
		move.b     #0xFF,(a5)
hline_m3:
		tst.b      (a1)
		move.b     d0,(a1)+
		dbf        d2,hline_m3
hline_m4:
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)
		move.b     #0xFF,(a5)
		move.b     #0x03,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      hline_m5
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
hline_m5:
		movea.l    (a7)+,a5
		rts

hline_solid:
		move.l     a5,-(a7)
		tst.w      is_mste
		beq.s      hline_so1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
hline_so1:
		move.w     d7,-(a7)
		move.l     r_fg_pixel(a6),d4
		not.b      d4
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     d4,(a5)
		move.b     #0x00,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x08,(a5)+
		moveq.l    #-1,d4
		moveq.l    #-1,d5
		moveq.l    #7,d7
		moveq.l    #7,d6
		and.w      d2,d6
		eor.w      d7,d6
		and.w      d0,d7
		lsr.b      d7,d4
		lsl.b      d6,d5
		move.w     BYTES_LIN.w,d6
relok155:
		lsr.w      #2,d6
		mulu.w     d6,d1
		adda.l     d1,a1
		move.w     d0,d1
		lsr.w      #3,d1
		adda.w     d1,a1
		lsr.w      #3,d2
		sub.w      d1,d2
		move.w     (a7),d0
		swap       d0
		move.w     (a7)+,d0
		cmp.w      #8,d2
		blt.s      hline_so6
		btst       #0,d1
		bne.s      hline_so2
		subq.w     #1,d2
hline_so2:
		subq.w     #1,d2
		move.w     d2,d6
		lsr.w      #2,d2
		subq.w     #1,d2
		not.w      d6
		and.w      #3,d6
		add.w      d6,d6
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     #0xFF,(a5)
		btst       #0,d1
		bne.s      hline_so3
		move.b     d0,(a1)+
hline_so3:
		move.l     d0,(a1)+
		dbf        d2,hline_so3
		jmp        hline_so4(pc,d6.w)
hline_so4:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)
		move.b     #0xFF,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      hline_so5
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
hline_so5:
		movea.l    (a7)+,a5
		rts
hline_so6:
		move.w     d2,d1
		not.w      d1
		and.w      #7,d1
		add.w      d1,d1
		tst.w      d2
		bne.s      hline_so7
		moveq.l    #18,d1
		and.w      d5,d4
hline_so7:
		move.b     d4,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     #0xFF,(a5)
		jmp        hline_so8(pc,d1.w)
hline_so8:
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d0,(a1)+
		move.b     d5,(a5)
		tst.b      (a1)
		move.b     d0,(a1)+
		move.b     #0xFF,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      hline_so9
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
hline_so9:
		movea.l    (a7)+,a5
		rts

/* **************************************************************************** */
                  /* 'vertical Line' */

/*
 * Draw vertical line
 * Inputs:
 * d0.w x
 * d1.w y1
 * d3.w y2
 * d7.w line pattern
 * a6.l pointer to workstation
 * Outputs:
 * d0-d7/a1 are trashed
 */
vline:
		movem.l    a4-a6,-(a7)
		move.w     bitmap_width(a6),d5
		beq.s      vline1               /* offscreem bitmap? */
		movea.l    bitmap_addr(a6),a1
		tst.w      r_planes(a6)
		beq.s      vline_laddr
		bra.s      vline_laddr
vline1:
		move.w     BYTES_LIN.w,d5       /* bytes per line */
relok156:
		movea.l    v_bas_ad.w,a1        /* screen address */
vline_laddr:
		lsr.w      #2,d5
		muls.w     d5,d1
		adda.l     d1,a1                /* line address */
		move.w     d0,d3
		asr.w      #3,d3
		adda.w     d3,a1                /* start address */

		not.w      d0
		and.w      #7,d0
		moveq.l    #0,d1
		bset       d0,d1                /* or mask */
		move.b     d1,d3
		not.b      d3                   /* and mask */

		move.l     vgamode+vga_membase(pc),d0
		cmpa.l     d0,a1
		bcs        vline5
		add.l      #VGA_MEMSIZE,d0
		cmpa.l     d0,a1
		bcc        vline5
		tst.l      r_bg_pixel(a6)
		bne.s      vline3
		move.w     wr_mode(a6),d6
		beq        vline_black
		cmp.w      #1,d6
		bne.s      vline3
		cmp.w      #0xFFFF,d7
		beq        vline_black
vline3:
		cmp.w      #MD_XOR-1,d6
		beq        vline_eor
		lsl.w      #3,d6
		lea.l      vline_jmptable(pc,d6.w),a4
		moveq.l    #3,d6
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
		movea.l    vgamode+vga_regbase(pc),a6
		move.b     #0x02,TS_I(a6)
		move.b     #0x04,GDC_I(a6)
vline4:
		lea.l      vline_jmptable(pc),a5
		moveq.l    #0,d0
		lsr.w      (a7)
		addx.w     d0,d0
		lsr.w      2(a7)
		addx.w     d0,d0
		add.w      d0,d0
		adda.w     0(a4,d0.w),a5
		movem.l    d2-d7/a1,-(a7)
		move.b     memwrite_table12(pc,d6.w),TS_D(a6)
		move.b     memread_table12(pc,d6.w),GDC_D(a6)
		jsr        (a5)
		movem.l    (a7)+,d2-d7/a1
		dbf        d6,vline4
		move.b     #0x0F,TS_D(a6)
		addq.l     #4,a7
		movem.l    (a7)+,a4-a6
		rts

memwrite_table12:
	dc.b 8,4,2,1
memread_table12:
	dc.b 3,2,1,0

vline_jmptable:
	dc.w vline_repl_00-vline_jmptable
	dc.w vline_repl_01-vline_jmptable
	dc.w vline_repl_10-vline_jmptable
	dc.w vline_repl_11-vline_jmptable
	dc.w vline_trans_00-vline_jmptable
	dc.w vline_trans_01-vline_jmptable
	dc.w vline_trans_10-vline_jmptable
	dc.w vline_trans_11-vline_jmptable
	dc.w vline_eor_00-vline_jmptable
	dc.w vline_eor_01-vline_jmptable
	dc.w vline_eor_10-vline_jmptable
	dc.w vline_eor_11-vline_jmptable
	dc.w vline_erase_00-vline_jmptable
	dc.w vline_erase_01-vline_jmptable
	dc.w vline_erase_10-vline_jmptable
	dc.w vline_erase_11-vline_jmptable

vline5:
		move.w     wr_mode(a6),d6
		lsl.w      #3,d6
		lea.l      vline_jmptable(pc,d6.w),a4
		move.w     r_planes(a6),d6
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
vline6:
		lea.l      vline_jmptable(pc),a5
		moveq.l    #0,d0
		lsr.w      (a7)
		addx.w     d0,d0
		lsr.w      2(a7)
		addx.w     d0,d0
		add.w      d0,d0
		adda.w     0(a4,d0.w),a5
		movem.l    d2-d7/a1,-(a7)
		jsr        (a5)
		movem.l    (a7)+,d2-d7/a1
		move.l     bitmap_len(a6),d0
		lsr.l      #2,d0
		adda.l     d0,a1
		dbf        d6,vline6
		addq.l     #4,a7
		movem.l    (a7)+,a4-a6
		rts

vline_repl_00:
		and.b      d3,(a1)
		adda.w     d5,a1
		dbf        d2,vline_repl_00
		rts

vline_repl_01:
		not.l      d7
vline_repl_10:
		addq.w     #1,d7
		beq.s      vline_repl_11
		subq.w     #1,d7
vline_repl1:
		rol.w      #1,d7
		bcc.s      vline_repl4
vline_repl2:
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,vline_repl1
		rts
vline_repl3:
		rol.w      #1,d7
		bcs.s      vline_repl2
vline_repl4:
		and.b      d3,(a1)
		adda.w     d5,a1
		dbf        d2,vline_repl3
		rts

vline_repl5:
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,vline_repl5
		rts

vline_repl_11:
		move.w     fast_cpu(pc),d0
		bne.s      vline_repl5
		move.w     d2,d3
		lsr.w      #5,d2
		not.w      d3
		and.w      #31,d3
		add.w      d3,d3
		add.w      d3,d3
		jmp        vline_repl_11_1(pc,d3.w)
vline_repl_11_1:
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,vline_repl_11_1
		rts

vline_trans_00:
vline_trans_01:
		not.w      d7
vline_erase_00:
vline_erase_10:
		rol.w      #1,d7
		bcs.s      vline_trans_00_1
		and.b      d3,(a1)
vline_trans_00_1:
		adda.w     d5,a1
		dbf        d2,vline_erase_00
		rts

		rts

vline_erase_01:
vline_erase_11:
		not.w      d7
vline_trans_10:
vline_trans_11:
		addq.w     #1,d7
		beq        vline_repl_11
		subq.w     #1,d7
vline_erase_01_1:
		rol.w      #1,d7
		bcc.s      vline_erase_01_2
		or.b       d1,(a1)
vline_erase_01_2:
		adda.w     d5,a1
		dbf        d2,vline_erase_01_1
		rts

vline_eor_00:
vline_eor_01:
vline_eor_10:
vline_eor_11:
		cmpi.w     #0xAAAA,d7
		beq.s      vline_eor_00_6
		cmpi.w     #0x5555,d7
		beq.s      vline_eor_00_3
vline_eor_00_1:
		rol.w      #1,d7
		bcc.s      vline_eor_00_2
		eor.b      d1,(a1)
vline_eor_00_2:
		adda.w     d5,a1
		dbf        d2,vline_eor_00_1
		rts
vline_eor_00_3:
		adda.w     d5,a1
		dbf        d2,vline_eor_00_6
vline_eor_00_4:
		lsr.w      #1,d2
vline_eor_00_5:
		eor.b      d1,(a1)
		adda.w     d5,a1
		dbf        d2,vline_eor_00_5
		rts
vline_eor_00_6:
		add.w      d5,d5
		move.w     fast_cpu(pc),d0
		bne.s      vline_eor_00_4
		move.w     d2,d3
		lsr.w      #5,d2
		not.w      d3
		andi.w     #0x001E,d3
		add.w      d3,d3
		jmp        vline_eor_00_7(pc,d3.w)
vline_eor_00_7:
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		eor.b      d1,(a1)
		adda.w     d5,a1
		dbf        d2,vline_eor_00_7
		rts

vline_black:
		move.l     r_fg_pixel(a6),d6
		not.b      d6
		tst.w      is_mste
		beq.s      vline_bl1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
vline_bl1:
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     d6,(a5)
		move.b     #0x00,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x08,(a5)+
		move.b     d1,(a5)
		bsr.s      draw_vline
		move.b     #0xFF,(a5)
		move.b     #0x01,-1(a5)
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      vline_bl2
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
vline_bl2:
		movem.l    (a7)+,a4-a6
		rts


draw_vline:
		addq.w     #1,d7
		beq.s      draw_vline6
		subq.w     #1,d7
draw_vline1:
		rol.w      #1,d7
		bcc.s      draw_vline4
draw_vline2:
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,draw_vline1
		rts
draw_vline3:
		rol.w      #1,d7
		bcs.s      draw_vline2
draw_vline4:
		and.b      d3,(a1)
		adda.w     d5,a1
		dbf        d2,draw_vline3
		rts
draw_vline5:
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,draw_vline5
		rts
draw_vline6:
		tst.w      fast_cpu
		bne.s      draw_vline5
draw_vline7:
		move.w     d2,d3
		lsr.w      #5,d2
		not.w      d3
		and.w      #31,d3
		add.w      d3,d3
		add.w      d3,d3
		jmp        draw_vline8(pc,d3.w)
draw_vline8:
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		or.b       d1,(a1)
		adda.w     d5,a1
		dbf        d2,draw_vline8
		rts

vline_eor:
		tst.w      is_mste
		beq.s      vline_eor1
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
vline_eor1:
		movea.l    vgamode+vga_regbase(pc),a5
		move.b     #0x02,TS_I(a5)
		move.b     #0x0F,TS_D(a5)
		lea.l      GDC_I(a5),a5
		move.b     #0x01,(a5)+
		move.b     #0x00,(a5)
		move.b     #0x00,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x03,(a5)+
		move.b     #0x18,(a5)
		move.b     #0x08,-1(a5)
		move.b     d1,(a5)
		bsr        draw_vline
		move.b     #0xFF,(a5)
		move.b     #0x03,-(a5)
		move.b     #0x00,1(a5)
		move.b     #0x01,(a5)+
		move.b     #0x00,(a5)
		tst.w      is_mste
		beq.s      vline_eor2
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
vline_eor2:
		movem.l    (a7)+,a4-a6
		rts

/* **************************************************************************** */
                  /* 'arbitrary Line' */

/*
 * Draw arbitray line
 * Inputs:
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * d7.w line pattern
 * a6.l pointer to workstation
 * Ausgaben
 * d0-d7/a1 are trashed
 */
line:
		movem.l    a3-a6,-(a7)
		move.w     bitmap_width(a6),d6  /* offscreen bitmap? */
		beq.s      line_laddr
		movea.l    bitmap_addr(a6),a1   /* address of bitmap */
		sub.w      bitmap_off_x(a6),d0
		sub.w      bitmap_off_y(a6),d1
		bra.s      line_screen
line_laddr:
		movea.l    v_bas_ad.w,a1        /* screen address */
		move.w     BYTES_LIN.w,d6
relok157:
line_screen:
		lsr.w      #2,d6
		muls.w     d6,d1                /* bytes per line * y1 */
		adda.l     d1,a1                /* line address */
		moveq.l    #-16,d1
		and.w      d0,d1
		asr.w      #3,d1
		adda.w     d1,a1                /* start address */

		tst.l      d6
		bpl.s      line_neg
		neg.w      d6
line_neg:
		moveq.l    #15,d1
		and.w      d0,d1
		move.w     #0x8000,d0           /* dot mask */
		lsr.w      d1,d0
		swap       d1
		move.w     wr_mode(a6),d1
		cmp.w      d4,d5
		bhi.s      line1
		swap       d1
		ror.w      d1,d7
		swap       d1
		addq.w     #4,d1
line1:
		lea.l      line_jmptable(pc),a4
		lsl.w      #3,d1
		adda.w     d1,a4
		move.w     r_bg_pixel+2(a6),-(a7)
		move.w     r_fg_pixel+2(a6),-(a7)
		move.w     r_planes(a6),-(a7)
		move.l     vgamode+vga_membase(pc),d1 /* inside graphic card memory? */
		cmpa.l     d1,a1
		bcs.s      line2
		add.l      #VGA_MEMSIZE,d1
		cmpa.l     d1,a1
		bcs.s      line3
line2:
		lea.l      line_jmptable(pc),a3
		moveq.l    #0,d1
		lsr.w      2(a7)
		addx.w     d1,d1
		lsr.w      4(a7)
		addx.w     d1,d1
		add.w      d1,d1
		adda.w     0(a4,d1.w),a3
		movem.l    d0/d2-d7/a1,-(a7)
		jsr        (a3)
		movem.l    (a7)+,d0/d2-d7/a1
		move.l     bitmap_len(a6),d1
		lsr.l      #2,d1                /* size of 1 plane */
		adda.l     d1,a1
		subq.w     #1,(a7)
		bpl.s      line2                /* next plane */
		addq.l     #6,a7
		movem.l    (a7)+,a3-a6
		rts
line3:
		movea.l    vgamode+vga_regbase(pc),a6
		move.b     #0x02,TS_I(a6)
		move.b     #0x04,GDC_I(a6)
line4:
		move.w     (a7),d1
		move.b     memwrite_table13(pc,d1.w),TS_D(a6)
		move.b     memread_table13(pc,d1.w),GDC_D(a6)
		lea.l      line_jmptable(pc),a3
		moveq.l    #0,d1
		lsr.w      2(a7)
		addx.w     d1,d1
		lsr.w      4(a7)
		addx.w     d1,d1
		add.w      d1,d1
		adda.w     0(a4,d1.w),a3
		movem.l    d0/d2-d7/a1,-(a7)
		jsr        (a3)
		movem.l    (a7)+,d0/d2-d7/a1
		subq.w     #1,(a7)
		bpl.s      line4
		move.b     #0x0F,TS_D(a6)
		addq.l     #6,a7
		movem.l    (a7)+,a3-a6
		rts

memwrite_table13:
	dc.b 8,4,2,1
memread_table13:
	dc.b 3,2,1,0

line_jmptable:
		dc.w lineh_repl_00-line_jmptable
		dc.w lineh_repl_01-line_jmptable
		dc.w lineh_repl_10-line_jmptable
		dc.w lineh_repl_11-line_jmptable
		dc.w lineh_trans_00-line_jmptable
		dc.w lineh_trans_01-line_jmptable
		dc.w lineh_trans_10-line_jmptable
		dc.w lineh_trans_11-line_jmptable
		dc.w lineh_eor_00-line_jmptable
		dc.w lineh_eor_01-line_jmptable
		dc.w lineh_eor_10-line_jmptable
		dc.w lineh_eor_11-line_jmptable
		dc.w lineh_erase_00-line_jmptable
		dc.w lineh_erase_01-line_jmptable
		dc.w lineh_erase_10-line_jmptable
		dc.w lineh_erase_11-line_jmptable

		dc.w linev_repl_00-line_jmptable
		dc.w linev_repl_01-line_jmptable
		dc.w linev_repl_10-line_jmptable
		dc.w linev_repl_11-line_jmptable
		dc.w linev_trans_00-line_jmptable
		dc.w linev_trans_01-line_jmptable
		dc.w linev_trans_10-line_jmptable
		dc.w linev_trans_11-line_jmptable
		dc.w linev_eor_00-line_jmptable
		dc.w linev_eor_01-line_jmptable
		dc.w linev_eor_10-line_jmptable
		dc.w linev_eor_11-line_jmptable
		dc.w linev_erase_00-line_jmptable
		dc.w linev_erase_01-line_jmptable
		dc.w linev_erase_10-line_jmptable
		dc.w linev_erase_11-line_jmptable

linev_repl_00:
		moveq.l    #0,d7
		bra.s      linev_repl_10
linev_repl_01:
		not.w      d7
		bra.s      linev_repl_10
linev_repl_11:
		moveq.l    #-1,d7
linev_repl_10:
		cmp.w      #-1,d7
		beq.s      linev_repl5
		bra.s      linev_repl2
linev_repl1:
		sub.w      d4,d3
		and.w      d1,(a1)
		not.w      d1
		and.w      d7,d1
		or.w       d1,(a1)
		adda.w     d6,a1
		ror.w      #1,d0
		dbcs       d2,linev_repl2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      linev_repl4
linev_repl2:
		moveq.l    #-1,d1
linev_repl3:
		eor.w      d0,d1
		add.w      d5,d3
		bpl.s      linev_repl1
		ror.w      #1,d0
		dbcs       d2,linev_repl3
		and.w      d1,(a1)
		not.w      d1
		and.w      d7,d1
		or.w       d1,(a1)+
		subq.w     #1,d2
		bpl.s      linev_repl2
linev_repl4:
		rts
linev_repl5:
		bra.s      linev_repl7
linev_repl6:
		sub.w      d4,d3
		or.w       d1,(a1)
		adda.w     d6,a1
		ror.w      #1,d0
		dbcs       d2,linev_repl7
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      linev_repl9
linev_repl7:
		moveq.l    #0,d1
linev_repl8:
		or.w       d0,d1
		add.w      d5,d3
		bpl.s      linev_repl6
		ror.w      #1,d0
		dbcs       d2,linev_repl8
		or.w       d1,(a1)+
		subq.w     #1,d2
		bpl.s      linev_repl7
linev_repl9:
		rts

linev_trans_00:
linev_trans_01:
		not.w      d7
linev_erase_00:
linev_erase_10:
		bra.s      linev_trans2
linev_trans1:
		sub.w      d4,d3
		or.w       d7,d1
		and.w      d1,(a1)
		adda.w     d6,a1
		ror.w      #1,d0
		dbcs       d2,linev_trans2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      linev_trans4
linev_trans2:
		moveq.l    #-1,d1
linev_trans3:
		eor.w      d0,d1
		add.w      d5,d3
		bpl.s      linev_trans1
		ror.w      #1,d0
		dbcs       d2,linev_trans3
		or.w       d7,d1
		and.w      d1,(a1)+
		subq.w     #1,d2
		bpl.s      linev_trans2
linev_trans4:
		rts

linev_erase_01:
linev_erase_11:
		not.w      d7
linev_trans_10:
linev_trans_11:
		cmp.w      #-1,d7
		beq.s      linev_repl5
		bra.s      linev_erase2
linev_erase1:
		sub.w      d4,d3
		and.w      d7,d1
		or.w       d1,(a1)
		adda.w     d6,a1
		ror.w      #1,d0
		dbcs       d2,linev_erase2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      linev_erase4
linev_erase2:
		moveq.l    #0,d1
linev_erase3:
		or.w       d0,d1
		add.w      d5,d3
		bpl.s      linev_erase1
		ror.w      #1,d0
		dbcs       d2,linev_erase3
		and.w      d7,d1
		or.w       d1,(a1)+
		subq.w     #1,d2
		bpl.s      linev_erase2
linev_erase4:
		rts

linev_eor_00:
linev_eor_01:
linev_eor_10:
linev_eor_11:
		bra.s      linev_eor2
linev_eor1:
		sub.w      d4,d3
		and.w      d7,d1
		eor.w      d1,(a1)
		adda.w     d6,a1
		ror.w      #1,d0
		dbcs       d2,linev_eor2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      linev_eor4
linev_eor2:
		moveq.l    #0,d1
linev_eor3:
		or.w       d0,d1
		add.w      d5,d3
		bpl.s      linev_eor1
		ror.w      #1,d0
		dbcs       d2,linev_eor3
		and.w      d7,d1
		eor.w      d1,(a1)+
		subq.w     #1,d2
		bpl.s      linev_eor2
linev_eor4:
		rts

lineh_repl_00:
		moveq.l    #0,d7
		bra.s      lineh_repl_10
lineh_repl_01:
		not.w      d7
		bra.s      lineh_repl_10
lineh_repl_11:
		moveq.l    #-1,d7
lineh_repl_10:
		cmp.w      #-1,d7
		beq.s      lineh_repl7
		move.w     d0,d1
		not.w      d1
		bra.s      lineh_repl2
lineh_repl1:
		sub.w      d5,d3
		ror.w      #1,d1
		ror.w      #1,d0
		dbcs       d2,lineh_repl2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      lineh_repl6
lineh_repl2:
		rol.w      #1,d7
		bcc.s      lineh_repl5
lineh_repl3:
		or.w       d0,(a1)
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_repl1
		dbf        d2,lineh_repl2
		rts
lineh_repl4:
		rol.w      #1,d7
		bcs.s      lineh_repl3
lineh_repl5:
		and.w      d1,(a1)
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_repl1
		dbf        d2,lineh_repl4
lineh_repl6:
		rts
lineh_repl7:
		bra.s      lineh_repl9
lineh_repl8:
		sub.w      d5,d3
		ror.w      #1,d0
		dbcs       d2,lineh_repl9
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      lineh_repl10
lineh_repl9:
		or.w       d0,(a1)
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_repl8
		dbf        d2,lineh_repl9
lineh_repl10:
		rts

lineh_trans_00:
lineh_trans_01:
		not.w      d7
lineh_erase_00:
lineh_erase_10:
		move.w     d0,d1
		not.w      d1
		bra.s      lineh_trans2
lineh_trans1:
		sub.w      d5,d3
		ror.w      #1,d1
		dbcc       d2,lineh_trans2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      lineh_trans4
lineh_trans2:
		rol.w      #1,d7
		bcs.s      lineh_trans3
		and.w      d1,(a1)
lineh_trans3:
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_trans1
		dbf        d2,lineh_trans2
lineh_trans4:
		rts

lineh_erase_01:
lineh_erase_11:
		not.w      d7
lineh_trans_10:
lineh_trans_11:
		cmp.w      #-1,d7
		beq.s      lineh_repl7
		bra.s      lineh_erase2
lineh_erase1:
		sub.w      d5,d3
		ror.w      #1,d0
		dbcs       d2,lineh_erase2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      lineh_erase4
lineh_erase2:
		rol.w      #1,d7
		bcc.s      lineh_erase3
		or.w       d0,(a1)
lineh_erase3:
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_erase1
		dbf        d2,lineh_erase2
lineh_erase4:
		rts

lineh_eor_00:
lineh_eor_01:
lineh_eor_10:
lineh_eor_11:
		bra.s      lineh_eor2
lineh_eor1:
		sub.w      d5,d3
		ror.w      #1,d0
		dbcs       d2,lineh_eor2
		addq.l     #2,a1
		subq.w     #1,d2
		bmi.s      lineh_eor4
lineh_eor2:
		rol.w      #1,d7
		bcc.s      lineh_eor3
		eor.w      d0,(a1)
lineh_eor3:
		adda.w     d6,a1
		add.w      d4,d3
		bpl.s      lineh_eor1
		dbf        d2,lineh_eor2
lineh_eor4:
		rts

/* **************************************************************************** */
                  /* 'v_contourfill' */

/*
 * Zeile absuchen bis sich die Pixelfarbe aendert
 * Vorgaben:
 * Register d0-d4/a3-a4 koennen veraendert werden
 * Eingaben:
 * d0.w x
 * d1.w y
 * d2.l clip_xmin/clip_xmax
 * a0.l Adresse des Worts fuer die linke Grenze
 * a1.l Adresse des Worts fuer die rechte Grenze
 * a5.l Zeiger auf die Seedfill-Struktur
 * Ausgaben:
 * d0.w Rueckgabewert
 */
fill_abort:
		moveq.l    #0,d0
		rts

memread_table14:
	dc.b 3,2,1,0

scanline:
		movem.l    d5-d7,-(a7)
		move.w     d0,d3
		swap       d3
		move.w     d0,d3
		tst.w      bitmap_width(a6)
		beq.s      scanline_screen
		movea.l    bitmap_addr(a6),a4
		muls.w     bitmap_width(a6),d1
		tst.w      r_planes(a6)
		beq.s      scanline_laddr
		lsr.l      #2,d1
		bra.s      scanline_laddr
scanline_screen:
		movea.l    v_bas_ad.w,a4
		muls.w     BYTES_LIN.w,d1
relok158:
		lsr.l      #2,d1
scanline_laddr:
		adda.l     d1,a4
		move.w     d0,d4
		asr.w      #4,d4
		add.w      d4,d4
		adda.w     d4,a4
		not.w      d0
		moveq.l    #15,d4
		and.w      d0,d4
		moveq.l    #0,d0
		bset       d4,d0
		moveq.l    #0,d6
		moveq.l    #3,d7
		move.l     a6,-(a7)
		movea.l    vgamode+vga_regbase(pc),a6
		lea.l      GDC_I(a6),a6 
		move.b     #0x04,(a6)+
scanline_loop:
		move.b     memread_table14(pc,d7.w),(a6)
		movem.l    d0-d1/d3-d4,-(a7)
		movea.l    a4,a3
		lsr.w      #1,d6
		move.w     (a3),d1
		and.w      d0,d1
		sne        d4
		beq.s      scan_ext
		addq.w     #8,d6
scan_ext:
		ext.w      d4
		cmp.w      d2,d3
		bgt.s      try_l
		move.w     d3,d0
		andi.w     #15,d0
		move.w     (a3)+,d1
		lsl.w      d0,d1
		move.w     d4,d5
		lsl.w      d0,d5
		cmp.w      d1,d5
		beq.s      r_wgr
		add.w      d1,d1
r_1wd:
		add.w      d1,d1
		scs        d0
		cmp.b      d0,d4
		bne.s      try_l
		addq.w     #1,d3
		cmp.w      d2,d3
		blt.s      r_1wd
		bra.s      etry_l
r_wgr:
		move.w     d3,d0
		not.w      d0
		and.w      #15,d0
		add.w      d0,d3
		cmp.w      d2,d3
		bge.s      etry_l
rs_wd:
		move.w     (a3)+,d1
		cmp.w      d1,d4
		bne.s      rs_ew
		add.w      #16,d3
		cmp.w      d2,d3
		blt.s      rs_wd
		bra.s      etry_l
rs_ew:
		add.w      d1,d1
		scs        d0
		cmp.b      d0,d4
		bne.s      try_l
		addq.w     #1,d3
		cmp.w      d2,d3
		blt.s      rs_ew
etry_l:
		move.w     d2,d3
try_l:
		move.w     d3,(a1)
		swap       d2
		swap       d3
		movea.l    a4,a3
scan_l:
		cmp.w      d2,d3
		blt.s      fnd_limits
		move.w     d3,d0
		not.w      d0
		and.w      #15,d0
		move.w     (a3),d1
		lsr.w      d0,d1
		move.w     d4,d5
		lsr.w      d0,d5
		cmp.w      d1,d5
		beq.s      l_wgr
		lsr.w      #1,d1
l_1wd:
		lsr.w      #1,d1
		scs        d0
		cmp.b      d0,d4
		bne.s      fnd_limits
		subq.w     #1,d3
		cmp.w      d2,d3
		bgt.s      l_1wd
		bra.s      e_limits
l_wgr:
		move.w     d3,d0
		and.w      #15,d0
		sub.w      d0,d3
		cmp.w      d2,d3
		ble.s      e_limits
ls_wd:
		subq.l     #8,a3
		move.w     (a3),d1
		cmp.w      d1,d4
		bne.s      ls_ew
		sub.w      #16,d3
		cmp.w      d2,d3
		bgt.s      ls_wd
		bra.s      e_limits
ls_ew:
		lsr.w      #1,d1
		scs        d0
		cmp.b      d0,d4
		bne.s      fnd_limits
		subq.w     #1,d3
		cmp.w      d2,d3
		bgt.s      ls_ew
e_limits:
		move.w     d2,d3
fnd_limits:
		move.w     d3,(a0)
		move.w     (a0),d2
		swap       d2
		move.w     (a1),d2
		movem.l    (a7)+,d0-d1/d3-d4
		dbf        d7,scanline_loop
		movea.l    (a7)+,a6
		move.w     (a5),d0
		cmp.w      4(a5),d6
		beq.s      scanline_exit
		eori.w     #1,d0
scanline_exit:
		movem.l    (a7)+,d5-d7
		rts
		rts

/* **************************************************************************** */

init_maps:
		move.l     d3,-(a7)
		move.l     d0,d3
		jsr        alloc_tables
		tst.l      d0
		beq.s      init_maps2
		tst.l      d3
		beq.s      init_maps1
		cmp.l      #256,d3
		bgt.s      init_maps1
		movea.l    global_ctable,a0
		lea.l      ctab_colors(a0),a0
		moveq.l    #-1,d1
		add.l      d3,d1
		moveq.l    #0,d0
		jsr        set_color_rgb
init_maps1:
		moveq.l    #1,d0
		bra.s      init_maps3
init_maps2:
		moveq.l    #0,d0
init_maps3:
		move.l     (a7)+,d3
		rts

free_tables:
		move.l     global_ctable,d0
		beq.s      free_tables1
		movea.l    d0,a0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_Mfree_sys(a1),a1
		jsr        (a1)
		clr.l      global_ctable
free_tables1:
		move.l     global_itable,d0
		beq.s      free_tables2
		movea.l    d0,a0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_Mfree_sys(a1),a1
		jsr        (a1)
		clr.l      global_itable
free_tables2:
		rts

alloc_tables:
		move.l     d3,-(a7)
		move.l     d4,-(a7)
		move.l     d0,d3
		moveq.l    #1,d1                /* color space RGB */
		movea.l    nvdi_struct,a0
		movea.l    _nvdi_create_ctab(a0),a0
		jsr        (a0)
		move.l     a0,global_ctable
		move.l     a0,d0
		beq.s      alloc_tables3
		moveq.l    #16,d1
		cmp.l      d3,d1
		blt.s      alloc_tables1
		moveq.l    #3,d4
		bra.s      alloc_tables2
alloc_tables1:
		moveq.l    #4,d4
alloc_tables2:
		moveq.l    #1,d1
		lsl.w      d4,d1
		move.w     d4,d0
		movea.l    global_ctable,a0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_create_itab(a1),a1
		jsr        (a1)
		move.l     a0,global_itable
		moveq.l    #1,d0
		bra.s      alloc_tables4
alloc_tables3:
		clr.l      global_itable
		moveq.l    #0,d0
alloc_tables4:
		move.l     (a7)+,d4
		move.l     (a7)+,d3
		rts

		.data

dev_name:
		dc.b 'VGA 16 Farben',0
		.even

/* **************************************************************************** */
                  /* 'Relozierungs-Information' */
relokation:
                  DC.W relok0-start-2
                  DC.W relok1-relok0
                  DC.W relok2-relok1
                  DC.W relok3-relok2
                  DC.W relok4-relok3
                  DC.W relok5-relok4
                  DC.W relok6-relok5
                  DC.W relok7-relok6
                  DC.W relok8-relok7
                  DC.W relok9-relok8
                  DC.W relok10-relok9
                  DC.W relok11-relok10
                  DC.W relok12-relok11
                  DC.W relok13-relok12
                  DC.W relok14-relok13
                  DC.W relok15-relok14
                  DC.W relok16-relok15
                  DC.W relok17-relok16
                  DC.W relok18-relok17
                  DC.W relok19-relok18
                  DC.W relok20-relok19
                  DC.W relok21-relok20
                  DC.W relok22-relok21
                  DC.W relok23-relok22
                  DC.W relok24-relok23
                  DC.W relok25-relok24
                  DC.W relok26-relok25
                  DC.W relok27-relok26
                  DC.W relok28-relok27
                  DC.W relok29-relok28
                  DC.W relok30-relok29
                  DC.W relok31-relok30
                  DC.W relok32-relok31
                  DC.W relok33-relok32
                  DC.W relok34-relok33
                  DC.W relok35-relok34
                  DC.W relok36-relok35
                  DC.W relok37-relok36
                  DC.W relok38-relok37
                  DC.W relok39-relok38
                  DC.W relok40-relok39-2,2
                  DC.W relok41-relok40
                  DC.W relok42-relok41
                  DC.W relok43-relok42
                  DC.W relok44-relok43
                  DC.W relok45-relok44
                  DC.W relok46-relok45
                  DC.W relok47-relok46
                  DC.W relok48-relok47
                  DC.W relok49-relok48
                  DC.W relok50-relok49
                  DC.W relok51-relok50
                  DC.W relok52-relok51
                  DC.W relok53-relok52
                  DC.W relok54-relok53
                  DC.W relok55-relok54
                  DC.W relok56-relok55
                  DC.W relok57-relok56
                  DC.W relok58-relok57
                  DC.W relok59-relok58
                  DC.W relok60-relok59
                  DC.W relok61-relok60
                  DC.W relok62-relok61
                  DC.W relok63-relok62
                  DC.W relok64-relok63
                  DC.W relok65-relok64
                  DC.W relok66-relok65
                  DC.W relok67-relok66
                  DC.W relok68-relok67
                  DC.W relok69-relok68
                  DC.W relok70-relok69
                  DC.W relok71-relok70
                  DC.W relok72-relok71
                  DC.W relok73-relok72
                  DC.W relok74-relok73
                  DC.W relok75-relok74
                  DC.W relok76-relok75
                  DC.W relok77-relok76
                  DC.W relok78-relok77
                  DC.W relok79-relok78
                  DC.W relok80-relok79
                  DC.W relok81-relok80
                  DC.W relok82-relok81
                  DC.W relok83-relok82
                  DC.W relok84-relok83
                  DC.W relok85-relok84
                  DC.W relok86-relok85
                  DC.W relok87-relok86
                  DC.W relok88-relok87
                  DC.W relok89-relok88
                  DC.W relok90-relok89
                  DC.W relok91-relok90
                  DC.W relok92-relok91
                  DC.W relok93-relok92
                  DC.W relok94-relok93
                  DC.W relok95-relok94
                  DC.W relok96-relok95
                  DC.W relok97-relok96
                  DC.W relok98-relok97
                  DC.W relok99-relok98
                  DC.W relok100-relok99
                  DC.W relok101-relok100
                  DC.W relok102-relok101
                  DC.W relok103-relok102
                  DC.W relok104-relok103
                  DC.W relok105-relok104
                  DC.W relok106-relok105
                  DC.W relok107-relok106
                  DC.W relok108-relok107
                  DC.W relok109-relok108
                  DC.W relok110-relok109-2,2
                  DC.W relok111-relok110
                  DC.W relok112-relok111
                  DC.W relok113-relok112
                  DC.W relok114-relok113
                  DC.W relok115-relok114
                  DC.W relok116-relok115
                  DC.W relok117-relok116
                  DC.W relok118-relok117
                  DC.W relok119-relok118
                  DC.W relok120-relok119
                  DC.W relok121-relok120
                  DC.W relok122-relok121
                  DC.W relok123-relok122
                  DC.W relok124-relok123
                  DC.W relok125-relok124
                  DC.W relok126-relok125
                  DC.W relok127-relok126
                  DC.W relok128-relok127
                  DC.W relok129-relok128
                  DC.W relok130-relok129
                  DC.W relok131-relok130
                  DC.W relok132-relok131
                  DC.W relok133-relok132
                  DC.W relok134-relok133
                  DC.W relok135-relok134
                  DC.W relok136-relok135
                  DC.W relok137-relok136
                  DC.W relok138-relok137
                  DC.W relok139-relok138
                  DC.W relok140-relok139
                  DC.W relok141-relok140
                  DC.W relok142-relok141
                  DC.W relok143-relok142
                  DC.W relok144-relok143
                  DC.W relok145-relok144
                  DC.W relok146-relok145
                  DC.W relok147-relok146
                  DC.W relok148-relok147
                  DC.W relok149-relok148
                  DC.W relok150-relok149
                  DC.W relok151-relok150
                  DC.W relok152-relok151
                  DC.W relok153-relok152
                  DC.W relok154-relok153
                  DC.W relok155-relok154
                  DC.W relok156-relok155
                  DC.W relok157-relok156
                  DC.W relok158-relok157
                  DC.W 0

/* **************************************************************************** */
                  /* 'Laufzeitdaten' */
                  BSS
fast_cpu:         ds.w 1
is_mste:          ds.w 1
redirect_ptr:     ds.l 1		/* redirect? uncertain, must be set by another program */

nvdi_struct:      DS.L 1                  /* Zeiger auf nvdi_struct oder 0 */
driver_struct:    DS.L 1

escape_ptr:       ds.l 1
hline_ptr:        ds.l 1
vline_ptr:        ds.l 1
line_ptr:         ds.l 1
bitblt_ptr:       ds.l 1
expblt_ptr:       ds.l 1
fline_ptr:        ds.l 1
fbox_ptr:         ds.l 1
textblt_ptr:      ds.l 1
scanline_ptr:     ds.l 1

xbios_tab:        DS.L 1                  /* alte NVDI-XBios-Vektoren */
bios_tab:         DS.L 5                  /* alte NVDI-Bios-Vektoren */
mouse_tab:        DS.L 4                  /* alte Vektoren in mouse_tab */

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 20*16

graymode:         ds.w 1
hid_cnt:          ds.w 1
mycon_state:      ds.l 1
convecs:          ds.l 2

vscr_struct:      ds.b 22       /* space for VSCR cookie */

xbios_rez:        ds.w 1

expand_tab:       ds.l 512
expand_tabo:      ds.l 512


sysfont_addr:     ds.l 1
font_image:       ds.l 1
save_vt52_vec:    ds.l 1
linea_save:       ds.w 25
save_v_bas_ad:    ds.l 1

cardtype:         ds.w 1
cardsubtype:      ds.w 1

vgamode:          ds.b VGA_MODESIZE
vga_memend1:      ds.l 1
vga_memend2:      ds.l 1
nvdivga_size:     ds.l 1
nvdivga_path:     ds.b 128

global_ctable:    ds.l 1
global_itable:    ds.l 1
