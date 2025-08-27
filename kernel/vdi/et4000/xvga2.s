;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                 2-Color VGA screen driver for NVDI                         *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Labels und Konstanten
                  ; 'Header'

VERSION           EQU $0500

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"
.INCLUDE "..\include\hardware.inc"

.INCLUDE "nova.inc"
.INCLUDE "vgainf.inc"

DRV_PLANES = 1
PATTERN_LENGTH    EQU ((16*16)/8)*2           ;minimale Fuellmusterlaenge

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
      /* 864 */
wk_sizeof:

		.text
	
start:
header:           bra.s continue          ;Fuer Aufrufe von normale Treibern
                  DC.B  'NVDIDRV',0       ;ID des NVDI-Treibers
                  DC.W  VERSION           ;Versionsnummer im BCD-Format
                  DC.W  header_end-header ;Laenge des Headers
                  DC.W  N_SCREEN          ;Bildschirmtreiber
                  DC.L  init              ;Adresse der Installationsfkt.
                  DC.L  reset             ;Adresse der Reinstallationsfkt.
                  DC.L  wk_init
                  DC.L  wk_reset
                  DC.L  get_opnwkinfo
                  DC.L  get_extndinfo
                  DC.L  get_scrninfo
                  DC.L  dev_name
                  DC.L  0,0,0,0           ;reserviert
organisation:     DC.L  2                 ;Farben
                  DC.W  DRV_PLANES        ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  1                 ;Bitverteilung
                  DC.W  0,0,0             ;reserviert
header_end:


continue:
		rts


;Treiber initialisieren
;Vorgaben:
;nur Register d0 wird veraendert
;Eingaben:
;d1.l pb
;a0.l Zeiger auf nvdi_struct
;a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
;Ausgaben:
;d0.l Laenge der Workstation oder 0L bei einem Fehler
init:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        make_relo
		bsr        get_driver_id
		move.l     a0,nvdi_struct
		move.l     a1,driver_struct
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_load_NOD_driver(a0),a2
		lea.l      organisation,a0
		jsr        (a2)
		movea.l    driver_struct(pc),a1
		move.l     a0,driver_offscreen(a1)
		beq.s      init_err
		bsr.w      save_screen_vecs
		bsr.w      set_screen_vecs
		bsr        find_vgamode
		movem.l    d0-d7/a0-a6,-(a7)
		DC.W 0xa000
		move.l     a1,fontring
		bsr        save_linea
		bsr        install_vscr_cookie
		bsr        clear_device
		moveq.l    #2,d0
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

save_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     _xbios_vec(a1),xbios_tab
		rts

set_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     #myxbios,_xbios_vec(a1)
		rts

reset_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     xbios_tab(pc),_xbios_vec(a1)
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

reset:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        free_tables
		movem.l    (a7),d0-d2/a0-a2
		movea.l    _nvdi_unload_NOD_driver(a0),a2
		movea.l    driver_offscreen(a1),a0
		jsr        (a2)
		bsr.w      reset_screen_vecs
		bsr        reset_vscr_cookie
		bsr        reset_vbl
		bsr.w      restore_linea
		bsr.w      check_redirect
		movem.l    (a7)+,d0-d2/a0-a2
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
		move.l     save_v_bas_ad(pc),v_bas_ad.w
		movem.l    (a7)+,d0/a0-a1
		rts

check_redirect:
		move.l     v_bas_ad.w,d0
		cmp.l      vgamode+vga_membase(pc),d0
		bne.s      check_redirect1
		move.l     redirect_ptr(pc),d0
		beq.s      check_redirect1
		movea.l    d0,a0
		moveq.l    #1,d0
		jsr        (a0)
check_redirect1:
		rts

;Ausgaben von v_opnwk()/v_opnvwk()/v_opnbm() zurueckliefern
;Vorgaben:
;-
;Eingaben:
;d1.l pb oder 0L
;a0.l intout
;a1.l ptsout
;a6.l Workstation
;Ausgaben:
;-
get_opnwkinfo:
		movem.l    d0/a0-a2,-(a7)
		move.w     vgamode+vga_xres(pc),(a0)+      ;adressierbare Rasterbreite
		move.w     vgamode+vga_yres(pc),(a0)+      ;adressierbare Rasterhoehe
		clr.w      (a0)+                ;genaue Skalierung moeglich !
		move.l     vgamode+vga_pixw(pc),(a0)+       ;Pixelbreite/Pixelhoehe
		moveq.l    #39,d0               ;40 Elemente kopieren
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_opnwk_work_out(a2),a2
		lea.l      10(a2),a2
work_out_int:
		move.w     (a2)+,(a0)+
		dbf        d0,work_out_int
		move.w     #2,26-90(a0)         ;work_out[13]: Anzahl der Farben
		move.w     #1,70-90(a0)         ;work_out[35]: Farbe ist vorhanden
		move.w     #0,78-90(a0)         ;work_out[39]: mehr als 32767 Farbabstufungen in der Palette
		moveq.l    #12-1,d0
work_out_pts:
		move.w     (a2)+,(a1)+
		dbf        d0,work_out_pts
		movem.l    (a7)+,d0/a0-a2
		rts

;Ausgaben von vq_extnd() zurueckliefern
;Vorgaben:
;-
;Eingaben:
;d1.l pb oder 0L
;a0.l intout
;a1.l ptsout
;a6.l Workstation
;Ausgaben:
;-
get_extndinfo:
		movem.l    d0/a0-a2,-(a7)
		moveq.l    #45-1,d0
		movea.l    nvdi_struct(pc),a2
		movea.l    _nvdi_extnd_work_out(a2),a2
ext_out_int:
		move.w     (a2)+,(a0)+
		dbf        d0,ext_out_int
		move.w     #0,2-90(a0)          ;work_out[1]: mehr als 32767 Farbabstufungen
		move.w     #DRV_PLANES,8-90(a0) ;work_out[4]: Anzahl der Farbebenen
		move.w     #1,10-90(a0)         ;work_out[5]: CLUT vorhanden
		move.w     #2200,12-90(a0)      ;work_out[6]: Anzahl der Rasteroperationen
		move.w     #1,38-90(a0)         ;work_out[19]: Clipping an
		moveq.l    #12-1,d0
ext_out_pts:
		move.w     (a2)+,(a1)+
		dbf        d0,ext_out_pts
		lea.l      clip_xmin(a6),a2
		move.l     (a2)+,0-24(a1)       ;work_out[45/46]: clip_xmin/clip_ymin
		move.l     (a2)+,4-24(a1)       ;work_out[47/48]: clip_xmax/clip_ymax
		movem.l    (a7)+,d0/a0-a2
		rts

;Ausgaben von vq_scrninfo() zurueckliefern
;Vorgaben:
;
;Eingaben:
;d1.l pb oder 0L
;a0.l intout
;a6.l Workstation
;Ausgaben:
;-
get_scrninfo:
		movem.l    d0-d1/a0-a1,-(a7)
		moveq.l    #6,d0
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      get_scrninfo1
		moveq.l    #8,d0
get_scrninfo1:
		move.w     #2,(a0)+    ;[0] Packed Pixel
		move.w     #1,(a0)+    ;[1] Hardware-CLUT
		move.w     #DRV_PLANES,(a0)+    ;[2] Anzahl der Ebenen
		move.l     #2,(a0)+    ;[3/4] Farbanzahl
		move.w     BYTES_LIN.w,(a0)+ ;[5] Bytes pro Zeile
relok2:
		move.l     v_bas_ad.w,(a0)+  ;[6/7] Bildschirmadresse
		move.w     d0,(a0)+    ;[8]  Bits der Rot-Intensitaet
		move.w     d0,(a0)+    ;[9]  Bits der Gruen-Intensitaet
		move.w     d0,(a0)+    ;[10] Bits der Blau-Intensitaet
		move.w     #0,(a0)+    ;[11] kein Alpha-Channel
		move.w     #0,(a0)+    ;[12] kein Genlock
		move.w     #0,(a0)+    ;[13] keine unbenutzten Bits
		move.w     #1,(a0)+    ;[14] Bitorganisation
		clr.w      (a0)+       ;[15] unbenutzt
		clr.w      (a0)+       ;[16] pixval[0] = 0
		move.w     #255-1,d0
		moveq.l    #1,d1
get_scrninfo2:
		move.w     d1,(a0)+
		dbf        d0,get_scrninfo2
		movem.l    (a7)+,d0-d1/a0-a1
		rts

synth_tab:
		dc.b 0x00,0x10,0x08,0x18,0x04,0x14,0x0c,0x1c,0x02,0x12,0x0a,0x1a,0x06,0x16,0x0e,0x1e
		dc.b 0x01,0x11,0x09,0x19,0x05,0x15,0x0d,0x1d,0x03,0x13,0x0b,0x1b,0x07,0x17,0x0f,0x1f

default_cardtype:    dc.w CARD_CRAZYDOTS
default_cardsubtype: dc.w 0

default_vga_mode:
		dc.l -1
		dc.w default_vga_mode_end-default_vga_mode
		dc.l default_modename
		dc.w 1024-1 ; xres
		dc.w 768-1  ; yres
		dc.w 1024-1 ; virtual xres
		dc.w 768-1  ; virtual yres
		dc.w VGA_PIXW ; pixw
		dc.w VGA_PIXH ; pixh
		dc.w DRV_PLANES ; planes
		dc.w 0
		dc.w 2
		dc.w 128        ; line width
		dc.l 0xfec00000 ; membase
		dc.l 0xfebf0000 ; regbase
		dc.w 2          ; dac_type
		dc.w 0x009f     ; synth
		dc.w 641        ; hfreq
		dc.w 800        ; vfreq
		dc.l 80000      ; pfreq
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0
		dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0x03     ; MISC_W
		dc.l default_ts_regs
		dc.l default_crtc_regs
		dc.l default_atc_regs
		dc.l default_gdc_regs
		dc.l 0
default_ts_regs:
		dc.w 8
		dc.b 0x00,0x01
		dc.b 0x0f,0x00
		dc.b 0x06,0x00
		dc.b 0x00,0xf4
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
default_crtc_regs:
		dc.w 56
		dc.b 0x97,0x7f
		dc.b 0x7f,0x1b
		dc.b 0x82,0x10
		dc.b 0x1e,0xf5
		dc.b 0x00,0x60
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x05
		dc.b 0xff,0x40
		dc.b 0x00,0xff
		dc.b 0x1f,0xc3
		dc.b 0xff,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0xf0,0x0f
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
default_atc_regs:
		dc.w 23
		dc.b 0x00,0x01
		dc.b 0x02,0x03
		dc.b 0x04,0x05
		dc.b 0x06,0x07
		dc.b 0x08,0x09
		dc.b 0x0a,0x0b
		dc.b 0x0c,0x0d
		dc.b 0x0e,0x0f
		dc.b 0x01,0x11
		dc.b 0x0f,0x00
		dc.b 0x00,0x00
		dc.b 0x10,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
default_gdc_regs:
		dc.w 9
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x01,0x0f
		dc.b 0xff,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
		dc.b 0x00,0x00
default_modename:
		dc.b 0,0
		dc.w 0x0000
		dc.w 0x0000
		dc.l 0
default_vga_mode_end:

find_vgamode:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        load_vga_inf
		move.l     a0,d0
		beq.s      find_vgamode7
		move.w     vgainf_cardtype(a0),cardtype
		move.w     vgainf_cardsubtype(a0),cardsubtype
		lea.l      vgainf_modes(a0),a1
		moveq.l    #-1,d1
find_vgamode1:
		move.l     vga_next(a1),d0    ; get offset to next mode
		cmp.l      d1,d0      ; end of modes?
		beq.s      find_vgamode2
		add.l      a1,d0      ; convert offset to address
		move.l     d0,vga_next(a1)    ; store address
		movea.l    d0,a1
		bra.s      find_vgamode1
find_vgamode2:
		move.w     vgainf_defmode(a0),d2 ; vga_defmode[0] == 2 color driver
		bmi.s      find_vgamode6
		lea.l      vgainf_modes(a0),a1
		moveq.l    #0,d0
find_vgamode3:
		cmpi.w     #DRV_PLANES,vga_planes(a1)
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

/* not used anywhere? */
set_defaults:
		move.w     default_cardtype(pc),cardtype
		move.w     default_cardsubtype(pc),cardsubtype
		lea.l      default_vga_mode(pc),a0
		lea.l      vgamode(pc),a1
		move.w     #VGA_MODESIZE,d0
		bsr        copy_vgainf
		movem.l    (a7)+,d0-d2/a0-a2
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
		lea        vgamode(pc),a0
		rts
vscr_func2:
		lea        vgamode(pc),a1
		move.w     #VGA_MODESIZE,d0
		bsr.s      copy_vgainf
		bsr        initmode
		rts

;
; a0: src
; a1: dst
; d0.w: maximum length
;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungsroutine'
make_relo:
		movem.l    d0-d2/a0-a2,-(a7)
		DC.W 0xa000
		sub.w      #CMP_BASE,d0         ;Differenz der Line-A-Adressen
		beq.s      relo_exit            ;keine Relokation noetig ?
		lea.l      start(pc),a0         ;Start des Textsegments
		lea.l      relokation,a1        ;Relokationsinformation
relo_loop:
		move.w     (a1)+,d1             ;Adress-Offset
		beq.s      relo_exit
		adda.w     d1,a0
		add.w      d0,(a0)              ;relozieren
		bra.s      relo_loop
relo_exit:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Initialisierung'

;Aufloesungsabhaengige Daten initialisieren
;Eingaben
;xres, yres, line_width, pixw, pixh, fonts
;Ausgaben
;kein Register wird zerstoert
init_res:
		movem.l    d0-d2/a0-a2,-(a7)
		movem.w    vgamode+vga_xres(pc),d0-d1
		move.w     vgamode+vga_line_width(pc),d2
		move.l     vgamode+vga_membase(pc),v_bas_ad.w
		move.w     #DRV_PLANES,PLANES.w
relok3:
		move.w     d2,WIDTH.w
relok4:
		move.w     d2,BYTES_LIN.w
relok5:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

;VT52-Emulator an die gewaehlte Aufloesung anpassen
;kein Register wird zerstoert
init_vt52:
		movem.l    d0-d4/a0-a2,-(a7)
		movem.w    vgamode+vga_xres(pc),d0-d1
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     vgamode+vga_line_width(pc),d2
		move.w     d0,V_REZ_HZ.w
relok6:
		move.w     d1,V_REZ_VT.w
relok7:
		movea.l    fontring(pc),a1
		addq.l     #4,a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		addq.l     #4,a1
init_vt52_font:
		movea.l    (a1),a1
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
		movem.w    d0-d2,V_CEL_MX.w ; V_CEL_MX/V_CEL_MY/V_CEL_WR
relok13:
		move.l     #255,V_COL_BG.w
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
		beq        initmode_8
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
		and.w      vgamode+vga_synth,d0
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
		move.l     vgamode+vga_visible_xres(pc),d0
		add.l      #0x00010001,d0
		lea.l      vscr_struct,a1
		move.l     #'VSCR',(a1)+
		move.l     #'NVDI',(a1)+
		move.w     #0x100,(a1)+
		clr.l      (a1)+
		move.l     d0,(a1)+
		move.l     #vscr_funct,(a1)+
		move.l     vgamode+vga_visible_xres(pc),d0
		cmp.l      vgamode+vga_xres(pc),d0
		bne.s      initmode_12
		rts
initmode_12:
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

reset_vscr_cookie:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_reset_cookie(a0),a0
		move.l     #'VSCR',d0
		jsr        (a0)
		movem.l    (a7)+,d0-d2/a0-a2
		rts

vbl_mouse:
		lea.l      vgamode+vga_visible_xres(pc),a0
		move.l     vgamode+vga_xres(pc),d6
		cmp.l      (a0),d6
		beq        vbl_mouse7
		lea.l      vscr_struct+10(pc),a1
		movem.w    (a0),d4-d5
		movem.w    (a1),d2-d3
		add.w      d2,d4
		add.w      d3,d5
		moveq.l    #-32,d0
		moveq.l    #-32,d1
		add.w      GCURX.w,d0
relok21:
		add.w      GCURY.w,d1
relok22:
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
		beq.s      vbl_mouse7
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
vbl_mouse7:
		rts

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #64,d0 ; Blitmode?
		bne.s      myxbios1
		bsr.w      blitmode
		bra.s      gooldxbios
myxbios1:
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

blitmode:
		movea.l    nvdi_struct(pc),a1
		btst       #1,_nvdi_blitter+1(a1)
		beq        blitmode_ret
		move.w     (a0),d0
		bmi        blitmode_ret ; BUG: should return current state
		movem.l    d2/a0-a2/a6,-(a7)
		move.w     #2200,d1
		tst.w      fast_cpu
		beq.s      blitmode1
		move.w     #5000,d1
blitmode1:
		bclr       #0,_nvdi_blitter+1(a1)
		and.w      #1,d0
		beq.s      blitmode2
		move.w     #5000,d1
blitmode2:
		or.w       d0,_nvdi_blitter(a1)
		move.w     d1,INQ_TAB6.w
relok23:
		move.w     _nvdi_no_wks(a1),d1
		movea.l    _nvdi_wks(a1),a2
		subq.l     #4,a2 
blitmode3:
		movea.l    (a2)+,a6 ; get next wk
		tst.w      wk_handle(a6)
		bmi.s      blitmode4
		move.l     device_drvr(a6),d2
		beq.s      blitmode4
		movea.l    d2,a0
		cmpi.l     #start,driver_addr(a0)
		bne.s      blitmode4
		move.l     fbox_ptr(pc),p_fbox(a6)
		move.l     vline_ptr(pc),p_vline(a6)
		move.l     bitblt_ptr(pc),p_bitblt(a6)
		move.l     expblt_ptr(pc),p_expblt(a6)
		move.l     textblt_ptr(pc),p_textblt(a6)
		tst.w      d0
		beq.s      blitmode4
		move.l     #fbox,p_fbox(a6)
		move.l     #vline,p_vline(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #expblt,p_expblt(a6)
		move.l     #textblt,p_textblt(a6)
blitmode4:
		dbf        d1,blitmode3
		movem.l    (a7)+,d2/a0-a2/a6
		 ; BUG: should return new state
blitmode_ret:
		moveq.l    #64,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
		move.l     vgamode+vga_xres(pc),res_x(a6)
		move.l     vgamode+vga_pixw(pc),pixel_width(a6)
		move.w     #DRV_PLANES-1,r_planes(a6)
		move.w     #1,colors(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation,a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.l     global_ctable(pc),wk_ctab(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     p_fbox(a6),fbox_ptr
		move.l     p_vline(a6),vline_ptr
		move.l     p_bitblt(a6),bitblt_ptr
		move.l     p_expblt(a6),expblt_ptr
		move.l     p_textblt(a6),textblt_ptr
		move.l     #set_color_rgb,p_set_color_rgb(a6)
		movea.l    nvdi_struct(pc),a0
		lea.l      _nvdi_blitter+1(a0),a0
		btst       #1,(a0)
		beq.s      wk_init1
		btst       #0,(a0)
		beq.s      wk_init1
		move.l     #fbox,p_fbox(a6)
		move.l     #vline,p_vline(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #expblt,p_expblt(a6)
		move.l     #textblt,p_textblt(a6)
wk_init1:
		moveq.l    #1,d0
		rts

wk_reset:
		rts

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
		move.b     d0,(a2)
		move.b     d1,(a2)
		move.b     d2,(a2)
		addq.l     #1,d3
		cmp.l      d3,d4
		bge.s      set_color_rgb1
		movem.l    (a7)+,d3-d5/a2
		rts

bitblt_ret:
		movea.l    bitblt_ptr(pc),a0
		jmp        (a0)

;Textausgabe ohne Clipping
;Vorgaben:
;Register d0-d7/a0-a5 koennen veraendert werden
;Eingaben:
;d0.w xq (linke x-Koordinate des Quellrechtecks)
;d1.w yq (obere y-Koordinate des Quellrechtecks)
;d2.w xz (linke x-Koordinate des Zielrechtecks)
;d3.w yz (obere y-Koordinate des Zielrechtecks)
;d4.w dx (Breite -1)
;d5.w dy (Hoehe -1)
;a0.l Quellblockadresse
;a2.w Bytes pro Quellzeile
;a6.l Workstation
;Ausgaben:
;-
textblt:
		movea.l    v_bas_ad.w,a1
		movea.w    BYTES_LIN.w,a3
relok24:
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
		clr.w      r_splanes(a6)
		clr.w      r_dplanes(a6)
		move.w     wr_mode(a6),d7
		add.w      d7,d7
		add.w      d7,d7
		move.l     blt_modes_blitter(pc,d7.w),r_wmode(a6)
		bra.s      expblt_blitter_in

;Bitblocktransfer ohne Clipping
;Vorgaben:
;Register d0-d7/a0-a6 koennen veraendert werden
;Eingaben:
;Vorgaben:
;Register d0-d7/a0-a5 koennen veraendert werden
;Eingaben:
;Die Paramter 4(sp) bis 18(sp) sind nur vorhanden, wenn skaliert werden muss
;d0.w qx, linke x-Koordinate des Quellrechtecks
;d1.w qy, obere y-Koordinate des Quellrechtecks
;d2.w zx, linke x-Koordinate des Zielrechtecks
;d3.w zy, obere y-Koordinate des Zielrechtecks
;d4.w qdx, Breite der Quelle - 1
;d5.w qdy, Hoehe der Quelle -1
;d6.w zdx, Breite des Ziels - 1
;d7.w zdy, Hoehe des Ziels -1
;a6.l Workstation
;4(sp).w qx ohne Clipping
;6(sp).w qy ohne Clipping
;8(sp).w zx ohne Clipping
;10(sp).w zy ohne Clipping
;12(sp).w qdx ohne Clipping
;14(sp).w qdy ohne Clipping
;16(sp).w zdx ohne Clipping
;18(sp).w zdy ohne Clipping
;Ausgaben:
;-
bitblt:
		cmp.w      d4,d6
		bne.s      bitblt_ret
		cmp.w      d5,d7
		bne.s      bitblt_ret
		bclr       #4,r_wmode+1(a6)
		bne.s      expblt
		and.w      #15,d7
		lea.l      r_wmode(a6),a4
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		move.b     d7,(a4)+
		bra.s      bitblt_planes_blitter

blt_modes_blitter:
	dc.b ALL_WHITE,NOT_S,S_ONLY,ALL_BLACK
	dc.b NOTS_AND_D,NOTS_AND_D,S_OR_D,S_OR_D
	dc.b S_XOR_D,S_XOR_D,S_XOR_D,S_XOR_D
	dc.b S_AND_D,NOTS_OR_D,S_AND_D,NOTS_OR_D

blt_mask_blitter:
	.dc.w 0x0000
	.dc.w 0x8000
	.dc.w 0xc000
	.dc.w 0xe000
	.dc.w 0xf000
	.dc.w 0xf800
	.dc.w 0xfc00
	.dc.w 0xfe00
	.dc.w 0xff00
	.dc.w 0xff80
	.dc.w 0xffc0
	.dc.w 0xffe0
	.dc.w 0xfff0
	.dc.w 0xfff8
	.dc.w 0xfffc
	.dc.w 0xfffe
	.dc.w 0xffff

;expandierender Bitblocktransfer, eine Ebene unter Vorgabe von
;Vorder- und Hintergrundfarbe expandieren
;Vorgaben:
;Register d0-d7/a0-a5.l koennen veraendert werden
;Eingaben:
;d0.w xq
;d1.w yq
;d2.w xz
;d3.w yz
;d4.w dx
;d5.w dy
;a6.l r_wmode, r_fgcol, r_bgcol, r_saddr, r_daddr, r_swidth, r_dwidth, r_dplanes
;Ausgaben:
;-
expblt:
		moveq.l    #3,d7
		and.w      r_wmode(a6),d7
		add.w      d7,d7
		add.w      d7,d7
		move.l     blt_modes_blitter(pc,d7.w),r_wmode(a6)
bitblt_planes_blitter:
		movea.l    r_saddr(a6),a0
		movea.l    r_daddr(a6),a1
expblt_blitter_in:
		movem.w    d1/d3/d5,-(a7)
		move.w     d2,d6
		add.w      d4,d6
		add.w      d0,d4
		move.w     d3,d7
		add.w      d5,d7
		add.w      d1,d5
		movea.w    d7,a5
		muls.w     r_swidth(a6),d5
		adda.l     d5,a0
		moveq.l    #15,d1
		move.w     d2,d5
		and.w      d1,d5
		move.w     d5,d7
		add.w      d5,d5
		move.w     blt_mask_blitter(pc,d5.w),d3
		not.w      d3
		swap       d3
		move.w     d6,d5
		and.w      d1,d5
		add.w      d5,d5
		move.w     blt_mask_blitter+2(pc,d5.w),d3
		move.w     d0,d5
		and.w      d1,d5
		sub.w      d5,d7
		lsr.w      #4,d0
		lsr.w      #4,d4
		lsr.w      #4,d2
		lsr.w      #4,d6
		adda.w     d4,a0
		adda.w     d4,a0
		sub.w      d0,d4
		move.w     d6,d1
		sub.w      d2,d6
		bgt.s      bitblt_blitter1
		move.l     d3,d5
		swap       d5
		and.l      d5,d3
bitblt_blitter1:
		add.w      d1,d1
		move.w     a5,d5
		muls.w     r_dwidth(a6),d5
		adda.l     d5,a1
		adda.w     d1,a1
		moveq.l    #0,d1
		cmpa.l     a1,a0
		bgt.s      bitblt_blitter2
		bne.s      bitblt_blitter3
		tst.w      d7
		bge.s      bitblt_blitter3
bitblt_blitter2:
		add.w      d0,d0
		move.w     (a7),d5
		muls.w     r_swidth(a6),d5
		movea.l    r_saddr(a6),a0
		adda.w     d0,a0
		adda.l     d5,a0
		add.w      d2,d2
		move.w     2(a7),d5
		muls.w     r_dwidth(a6),d5
		movea.l    r_daddr(a6),a1
		adda.w     d2,a1
		adda.l     d5,a1
		moveq.l    #8,d1
		swap       d3
bitblt_blitter3:
		move.w     d6,d5
		addq.w     #1,d5
		tst.w      d7
		bge.s      bitblt_blitter4
		addq.w     #2,d1
bitblt_blitter4:
		cmp.w      d4,d6
		bne.s      bitblt_blitter5
		addq.w     #4,d1
bitblt_blitter5:
		moveq.l    #2,d2
		move.w     d4,d0
		add.w      d4,d4
		neg.w      d4
		add.w      r_swidth(a6),d4
		add.w      d6,d0
		add.w      d6,d6
		neg.w      d6
		add.w      r_dwidth(a6),d6
		btst       #3,d1
		bne.s      bitblt_blitter6
		neg.w      d2
		neg.w      d4
		neg.w      d6
bitblt_blitter6:
		tst.w      d0
		bne.s      bitblt_blitter8
		move.w     d7,d2
		addi.w     #16,d1
bitblt_blitter8:
		andi.w     #15,d7
		or.w       blitter_ops(pc,d1.w),d7
		lea.l      SrcX_Inc.w,a4
		move.w     d2,(a4)+ ; SrcX_Inc
		move.w     d4,(a4)+ ; SrcY_Inc
		move.l     a0,(a4)+ ; SrcAddress
		move.w     d3,(a4)+ ; ENDMASK1
		move.w     #-1,(a4)+ ; ENDMASK2
		swap       d3
		move.w     d3,(a4)+ ; ENDMASK3
		move.w     d2,(a4)+ ; DestX_Inc
		bne.s      bitblt_blitter9
		bset       #7,d7
bitblt_blitter9:
		move.w     d6,(a4)+ ; DestY_Inc
		move.l     a1,(a4)+ ; DestAddress
		move.w     d5,(a4)+ ; X_Cnt
		move.w     4(a7),d2
		addq.w     #1,d2
		move.w     d2,(a4)+ ; Y_Cnt
		move.w     #0x0200,(a4)+ ; HOP
		move.l     r_fg_pixel(a6),d3
		move.l     r_bg_pixel(a6),d4
		clr.w      d6
		lsr.w      #1,d3
		addx.w     d6,d6
		lsr.w      #1,d4
		addx.w     d6,d6
		lea.l      r_wmode(a6),a3
		move.b     0(a3,d6.w),OP.w
		move.w     d7,(a4) ; Line_Num
bitblt_blitter10:
		tas.b      (a4)
		bmi.s      bitblt_blitter10
		addq.l     #6,a7
		rts

blitter_ops:
	.dc.w 0x8040
	.dc.w 0x8080
	.dc.w 0x80c0
	.dc.w 0x8000
	.dc.w 0x8040
	.dc.w 0x8080
	.dc.w 0x8000
	.dc.w 0x80c0
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000
	.dc.w 0x8000

fbox_mask1_blitter:
	.dc.w 0xffff
fbox_mask2_blitter:
	.dc.w 0x7fff
	.dc.w 0x3fff
	.dc.w 0x1fff
	.dc.w 0x0fff
	.dc.w 0x07ff
	.dc.w 0x03ff
	.dc.w 0x01ff
	.dc.w 0x00ff
	.dc.w 0x007f
	.dc.w 0x003f
	.dc.w 0x001f
	.dc.w 0x000f
	.dc.w 0x0007
	.dc.w 0x0003
	.dc.w 0x0001
	.dc.w 0x0000

/* **************************************************************************** */

                  /* 'gefuelltes Rechteck' */

/*
 * gefuelltes Reckteck ohne Clipping zeichnen
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
		move.w     d0,d4
		asr.w      #4,d0
		moveq.l    #-1,d6
		move.w     d2,d6
		asr.w      #4,d2
		moveq.l    #15,d5
		and.w      d5,d4
		and.w      d5,d6
		add.w      d6,d6
		add.w      d4,d4
		move.w     fbox_mask1_blitter(pc,d4.w),d4
		move.w     fbox_mask2_blitter(pc,d6.w),d6
		not.w      d6
		sub.w      d0,d2
		bne.s      fbox_blitter1
		and.w      d6,d4
fbox_blitter1:
		btst       #7,Line_Num.w
		bne.s      fbox_blitter1
		lea.l      ENDMASK1.w,a2
		move.w     d4,(a2)+
		move.l     d6,(a2)+
		move.w     d1,d4
		and.w      d5,d4
		ori.b      #0x80,d4
		sub.w      d1,d3
		addq.w     #1,d3
		movea.l    v_bas_ad.w,a0
		move.w     BYTES_LIN.w,d5
; FIXME: does not check bitmap_width
relok25:
		muls.w     d5,d1
		adda.l     d1,a0
		add.w      d0,d0
		adda.w     d0,a0
		sub.w      d2,d5
		sub.w      d2,d5
		addq.w     #1,d2
		move.w     #2,(a2)+ /* DestX_Inc */
		move.w     d5,(a2)+ /* DestY_Inc */
		move.l     a0,(a2)+ /* DestAdress */
		move.w     d2,(a2)+ /* X_Cnt */
		move.w     d3,(a2)+ /* Y_Cnt */
		lea.l      HalftoneRAM.w,a0
		tst.w      f_interior(a6)
		beq.s      fbox_blitter4
		movea.l    f_pointer(a6),a1
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.l     (a1)+,(a0)+
		move.w     wr_mode(a6),d0
		add.w      d0,d0
		add.w      r_fg_pixel+2(a6),d0
		add.w      d0,d0
		add.w      r_bg_pixel+2(a6),d0
		add.w      d0,d0
		move.w     fbox_ops(pc,d0.w),(a2)+
		move.b     d4,(a2)
fbox_blitter3:
		tas.b      (a2)
		bmi.s      fbox_blitter3
		rts

fbox_ops:
	dc.b 1,0
	dc.b 1,12
	dc.b 1,3
	dc.b 1,15
	dc.b 1,4
	dc.b 1,4
	dc.b 1,7
	dc.b 1,7
	dc.b 1,6
	dc.b 1,6
	dc.b 1,6
	dc.b 1,6
	dc.b 1,1
	dc.b 1,13
	dc.b 1,1
	dc.b 1,13

fbox_blitter4:
	moveq.l    #0,d0
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.l     d0,(a0)+
		move.w     wr_mode(a6),d0
		add.w      d0,d0
		add.w      r_fg_pixel+2(a6),d0
		add.w      d0,d0
		add.w      r_bg_pixel+2(a6),d0
		add.w      d0,d0
		move.w     fbox_ops(pc,d0.w),(a2)+
		move.b     d4,(a2)
fbox_blitter5:
		tas.b      (a2)
		bmi.s      fbox_blitter5
		rts

vline_ret:
		movea.l    vline_ptr(pc),a1
		jmp        (a1)

/*
 * vertikale Linie ohne Clipping zeichnen
 * Vorgaben:
 * Register d0-d7/a1 koennen veraendert werden
 * Eingaben:
 * d0.w x
 * d1.w y1
 * d3.w y2
 * d6.w Linienmuster
 * d7.w Schreibmodus
 * a6.l Workstation
 * Ausgaben:
 * -
 */
vline:
		lea.l      HalftoneRAM.w,a1
		ext.l      d7
		cmp.w      #-1,d7
		beq.s      vline_blitter2
		cmp.w      #0xAAAA,d7
		beq.s      vline_ret
		cmp.w      #0x5555,d7
		beq.s      vline_ret
		tst.w      d7
		beq.s      vline_blitter2
		moveq.l    #3,d5
vline_blitter1:
		add.w      d7,d7
		subx.w     d4,d4
		move.w     d4,(a1)+
		add.w      d7,d7
		subx.w     d4,d4
		move.w     d4,(a1)+
		add.w      d7,d7
		subx.w     d4,d4
		move.w     d4,(a1)+
		add.w      d7,d7
		subx.w     d4,d4
		move.w     d4,(a1)+
		dbf        d5,vline_blitter1
		bra.s      vline_blitter3
vline_blitter2:
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
		move.l     d7,(a1)+
vline_blitter3:
		addq.w     #1,d2
		move.w     d0,d3
		asr.w      #4,d0
		not.w      d3
		and.w      #15,d3
		clr.w      d4
		bset       d3,d4
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d3
relok26:
		tst.w      bitmap_width(a6)
		beq.s      vline_blitter4
	/* BUG: does not check whether bitmap is accessible by blitter */
		movea.l    bitmap_addr(a6),a1
		move.w     bitmap_width(a6),d3
vline_blitter4:
		muls.w     d3,d1
		adda.l     d1,a1
		add.w      d0,d0
		adda.w     d0,a1
		move.l     a1,d0
vline_blitter5:
		btst       #7,Line_Num.w
		bne.s      vline_blitter5
		move.w     d4,ENDMASK1.w
		lea.l      DestY_Inc.w,a1
		move.w     d3,(a1)+ /* DestY_Inc */
		move.l     d0,(a1)+ /* DestAdress */
		move.w     #1,(a1)+ /* X_Cnt */
		move.w     d2,(a1)+ /* Y_Cnt */
		move.w     wr_mode(a6),d6
		add.w      d6,d6
		add.w      r_fg_pixel+2(a6),d6
		add.w      d6,d6
		add.w      r_bg_pixel+2(a6),d6
		add.w      d6,d6
		move.w     vline_ops(pc,d6.w),(a1)+
		cmp.w      #608,d2
		bgt.s      vline_blitter6
	/* execute in HOG mode */
		move.w     #0xC000,(a1) /* HOP/OP */
		rts

vline_ops:
	dc.b 1,0
	dc.b 1,12
	dc.b 1,3
	dc.b 1,15
	dc.b 1,4
	dc.b 1,4
	dc.b 1,7
	dc.b 1,7
	dc.b 1,6
	dc.b 1,6
	dc.b 1,6
	dc.b 1,6
	dc.b 1,1
	dc.b 1,13
	dc.b 1,1
	dc.b 1,13

vline_blitter6:
		/* execute in non-HOG mode */
		move.w     #0x8000,(a1) /* HOP/OP */
vline_blitter7:
		tas.b      (a1)
		bmi.s      vline_blitter7
		rts

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
		moveq.l    #1,d1                ; color space RGB
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
		dc.b 'VGA 2 Farben',0
		.even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungs-Information'
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
                  DC.W 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS
fast_cpu:         ds.w 1
redirect_ptr:     ds.l 1		; redirect; BUG: not set here

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L 1
xbios_rez:        ds.w 1

vscr_struct:      ds.b 22       ; space for VSCR cookie

fbox_ptr:         ds.l 1
vline_ptr:        ds.l 1
bitblt_ptr:       ds.l 1
expblt_ptr:       ds.l 1
textblt_ptr:      ds.l 1

xbios_tab:        DS.L 1                  ;alte NVDI-XBios-Vektoren
fontring:         DS.L 1

linea_save:       ds.w 25
save_v_bas_ad:    ds.l 1
cardtype:         ds.w 1
cardsubtype:      ds.w 1

vgamode:          ds.b VGA_MODESIZE

nvdivga_size:     ds.l 1
nvdivga_path:     ds.b 128

global_ctable:    ds.l 1
global_itable:    ds.l 1
