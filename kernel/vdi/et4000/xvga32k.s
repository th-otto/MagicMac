;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*        hicolor 5-5-5 VGA screen driver for NVDI                            *;
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

DRV_PLANES = 16
PATTERN_LENGTH    EQU 16*16*2*2                  ;minimale Fuellmusterlaenge

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
      /* 1824 */
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
organisation:     DC.L  32768             ;Farben
                  DC.W  DRV_PLANES        ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  0x81              ;Bitverteilung
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
		move.l     _nvdi_aes_wk(a0),aes_wk_ptr
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_load_NOD_driver(a0),a2
		lea.l      organisation,a0
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
		bsr        build_exp
		bsr        clear_device
		move.l     #32768,d0
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
		move.l     save_vt52_vec(pc),(a2)
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
		move.w     #256,26-90(a0)       ;work_out[13]: Anzahl der Farben
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
		lea.l      scrninfo(pc),a1
		move.w     (a1)+,(a0)+    ;[0] Packed Pixel
		move.w     (a1)+,(a0)+    ;[1] Software-CLUT
		move.w     (a1)+,(a0)+    ;[2] Anzahl der Ebenen
		move.l     (a1)+,(a0)+    ;[3/4] Farbanzahl
		move.w     BYTES_LIN.w,(a0)+ ;[5] Bytes pro Zeile
relok2:
		move.l     v_bas_ad.w,(a0)+  ;[6/7] Bildschirmadresse
		addq.l     #6,a1
		move.w     (a1)+,(a0)+    ;[8]  Bits der Rot-Intensitaet
		move.w     (a1)+,(a0)+    ;[9]  Bits der Gruen-Intensitaet
		move.w     (a1)+,(a0)+    ;[10] Bits der Blau-Intensitaet
		move.w     (a1)+,(a0)+    ;[11] kein Alpha-Channel
		move.w     (a1)+,(a0)+    ;[12] kein Genlock
		move.w     (a1)+,(a0)+    ;[13] keine unbenutzten Bits
		move.w     (a1)+,(a0)+    ;[14] Bitorganisation
		move.w     (a1)+,(a0)+    ;[15] unbenutzt
		move.w     #255,d0
scrninfo_loop:
		move.w     (a1)+,(a0)+
		dbf        d0,scrninfo_loop
		movem.l    (a7)+,d0-d1/a0-a1
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Daten fuer vq_scrninfo()'

scrninfo:
                  DC.W 2                  ;Packed Pixels
                  DC.W 2                  ;Software-CLUT
                  DC.W DRV_PLANES         ;16 Ebenen
                  DC.L 32768              ;32768 Farben
                  DC.W 0,0,0
                  DC.W 5                  ;5 Bits fuer die Rot-Intensitaet
                  DC.W 5                  ;5 Bits fuer die Gruen-Intensitaet
                  DC.W 5                  ;5 Bits fuer die Blau-Intensitaet
                  DC.W 0                  ;kein Bit fuer Alpha-Channel
                  DC.W 0                  ;kein Bit fuer Genlock
                  DC.W 1                  ;1 unbenutztes Bit
                  DC.W 0x81               ;Bit organization: byte swapped
                  DC.W 0                  ;reserved

/* GGGBBBBB xRRRRRGG */
                  DC.W  2,3,4,5,6         ;Bits der Rot-Intensitaet
                  DCB.W 11,-1
                  DC.W  13,14,15,0,1      ;Bits der Gruen-Intensitaet
                  DCB.W 11,-1
                  DC.W  8,9,10,11,12      ;Bits der Blau-Intensitaet
                  DCB.W 11,-1
                  DCB.W 16,-1             ;kein Alpha-Channel
                  DCB.W 16,-1             ;keine Bits fuer Genlock
                  DC.W 7                  ;Bit 7 ist unbenutzt
                  DCB.W 31,-1             ;unbenutzte Bits

                  DCB.W 156,0             ;reserviert

synth_tab:
		dc.b 0x00,0x10,0x08,0x18,0x04,0x14,0x0c,0x1c,0x02,0x12,0x0a,0x1a,0x06,0x16,0x0e,0x1e
		dc.b 0x01,0x11,0x09,0x19,0x05,0x15,0x0d,0x1d,0x03,0x13,0x0b,0x1b,0x07,0x17,0x0f,0x1f

find_vgamode:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        load_vga_inf
		move.l     a0,d0
		beq.s      find_vgamode7
		move.w     58(a0),x1118a
		move.w     60(a0),x1118c
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
		move.w     vgainf_defmode+6(a0),d2 ; vga_defmode[3] == 32768 color driver
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

load_vga_inf:
		movem.l    d0-d2/a1-a2,-(a7)
		move.w     #25,-(a7) ; Dgetdrv
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


set_color_rgb:
		rts

palette_data:
		dc.w 0xff7f,0x007c,0xe003,0xe07f,0x1f00,0x1f7c,0xff03,0x5a6b
		dc.w 0x1042,0x0054,0xa002,0xa056,0x1500,0x1554,0xb502,0x0000

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #21,d0
		beq.s      cursconf
		cmp.w      #64,d0
		beq        blitmode
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
relok3:
cursconf_ret:
		rts
cursconf_3:
		bclr       #CURSOR_BL,V_STAT_0.w
relok4:
		rts
cursconf_4:
		move.b     1(a0),V_PERIOD.w
relok5:
		rts
cursconf_5:
		moveq.l    #0,d0
		move.b     V_PERIOD.w,d0
relok6:
		rts

blitmode:
		move.w     #5000,INQ_TAB6.w
relok7:
		moveq.l    #0,d0
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'GEMDOS\BIOS\XBIOS'

; OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
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

;Cursor positionieren
;Eingabe
;d0 Textspalte
;d1 Textzeile
;Ausgabe
;a1 Cursoradresse
;zerstoert werden d0-d2
set_cursor_xy:
		bsr.s      cursor_off
set_cur_clipx1:
		move.w     V_CEL_MX.w,d2
relok8:
		tst.w      d0
		bpl.s      set_cur_clipx2
		moveq.l    #0,d0
set_cur_clipx2:
		cmp.w      d2,d0
		ble.s      set_cur_clipy1
		move.w     d2,d0
set_cur_clipy1:
		move.w     V_CEL_MY.w,d2
relok9:
		tst.w      d1
		bpl.s      set_cur_clipy2
		moveq.l    #0,d1
set_cur_clipy2:
		cmp.w      d2,d1
		ble.s      set_cursor
		move.w     d2,d1
set_cursor:
		movem.w    d0-d1,V_CUR_XY.w
relok10:
		movea.l    v_bas_ad.w,a1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok11:
		adda.l     d1,a1
		lsl.w      #4,d0
		adda.w     d0,a1
		move.l     a1,V_CUR_AD.w
relok12:
		bra.s      cursor_on

;Cursor ausschalten
cursor_off:
		addq.w     #1,hid_cnt
		cmpi.w     #1,hid_cnt
		bne.s      cursor_off_exit
		bclr       #CURSOR_STATE,V_STAT_0.w
relok13:
		bne.s      cursor
cursor_off_exit:
		rts

;Cursor einschalten
cursor_on:
		cmpi.w     #1,hid_cnt
		bcs.s      cursor_on_exit2
		bhi.s      cursor_on_exit1
		move.b     V_PERIOD.w,V_CUR_CT.w
relok14:
		bsr.s      cursor
		bset       #CURSOR_STATE,V_STAT_0.w
relok15:
cursor_on_exit1:
		subq.w     #1,hid_cnt
cursor_on_exit2:
		rts

vbl_cursor:
		btst       #CURSOR_BL,V_STAT_0.w
relok16:
		beq.s      vbl_no_bl
		bchg       #CURSOR_STATE,V_STAT_0.w
relok17:
		bra.s      cursor
vbl_no_bl:
		bset       #CURSOR_STATE,V_STAT_0.w
relok18:
		beq.s      cursor
		rts

;Cursor zeichnen
cursor:
		movem.l    d0-d1/a1,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
relok19:
		add.w      d0,d0
		move.w     d0,d1
		add.w      d0,d0          ;(16 - Zeichenhoehe) * 6 ; BUG: must be * 10
		add.w      d1,d0
		movea.l    V_CUR_AD.w,a1
relok20:
		moveq.l    #-16,d1
		add.w      BYTES_LIN.w,d1
relok21:
		jmp        cursor_jmp(pc,d0.w)
cursor_jmp:
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		movem.l    (a7)+,d0-d1/a1
cursor_exit:
		rts

;BEL, Klingelzeichen
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
		move.w     #32,-(a7) ; Dosound
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

;BACKSPACE, ein Zeichen zurueck
;d0 Textspalte
;d1 Textzeile
vt_bs:
		movem.w    V_CUR_XY.w,d0-d1
relok22:
		subq.w     #1,d0
		bra        set_cursor_xy

;HT
;d0 Textspalte
;d1 Textzeile
vt_ht:
		andi.w     #-8,d0
		addq.w     #8,d0
		bra        set_cursor_xy

;LINEFEED, naechste Zeile
;d1 Textzeile
vt_lf:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		sub.w      V_CEL_MY.w,d1
relok23:
		beq        scroll_up_page
		move.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok24:
		add.l      d1,V_CUR_AD.w
relok25:
		addq.w     #1,V_CUR_XY1.w
relok26:
		rts

;RETURN, Zeilenanfang
;d0 Textspalte
vt_cr:
		bsr        cursor_off
		pea.l      cursor_on(pc)
		movea.l    V_CUR_AD.w,a1
relok27:

;Cursor an den Zeilenanfang setzen
;Eingabe
;d0 Cursorspalte
;a1 Cursoradresse
;Ausgabe
;a1 neue Cursoradresse
;zerstoert werden d0/d2
set_x0:
		lsl.w      #4,d0
		suba.w     d0,a1
		move.l     a1,V_CUR_AD.w
relok28:
		clr.w      V_CUR_XY.w
relok29:
		rts

;ESC
vt_esc:
		move.l     #vt_esc_seq,mycon_state
		rts

vt_control:
		cmpi.w     #27,d1
		beq.s      vt_esc
		subq.w     #7,d1
		subq.w     #6,d1
		bhi.s      vt_c_exit
		move.l     #vt_con0,mycon_state
		add.w      d1,d1
		move.w     vt_c_tab(pc,d1.w),d2
		movem.w    V_CUR_XY.w,d0-d1
relok30:
		jmp        vt_c_tab(pc,d2.w)
vt_c_exit:
		rts

                  DC.W vt_bel-vt_c_tab    ;7  BEL
                  DC.W vt_bs-vt_c_tab     ;8  BS
                  DC.W vt_ht-vt_c_tab     ;9  HT
                  DC.W vt_lf-vt_c_tab     ;10 LF
                  DC.W vt_lf-vt_c_tab     ;11 VT
                  DC.W vt_lf-vt_c_tab     ;12 FF
vt_c_tab:         DC.W vt_cr-vt_c_tab     ;13 CR

vt_con:
		movea.l    mycon_state(pc),a0
		jmp        (a0)
vt_con0:
		cmpi.w     #32,d1
		blt.s      vt_control

vt_rawcon:
		movea.l    font_image(pc),a0
		movea.l    V_CUR_AD.w,a1
relok31:
		moveq.l    #-16,d2
		add.w      BYTES_LIN.w,d2
relok32:
		move.b     #2,V_CUR_CT.w
relok33:
		bclr       #CURSOR_STATE,V_STAT_0.w
relok34:
		move.l     V_FNT_AD.w,d0
relok35:
		btst       #CURSOR_INVERSE,V_STAT_0.w
relok36:
		bne        vt_char_rcol
		cmp.l      sysfont_addr(pc),d0
		bne        vt_char_col
		cmpi.l     #15,V_COL_BG.w
relok37:
		bne        vt_char_col
		lsl.w      #4,d1
		adda.w     d1,a0
		move.w     V_CEL_HT.w,d1
relok38:
		subq.w     #1,d1
		lea.l      expand_tab(pc),a2
		move.l     a3,-(a7)
vt_char_bloop:
		moveq.l    #0,d0
		move.b     (a0)+,d0
		lsl.w      #4,d0
		movea.l    a2,a3
		adda.w     d0,a3
		move.l     (a3)+,(a1)+
		move.l     (a3)+,(a1)+
		move.l     (a3)+,(a1)+
		move.l     (a3)+,(a1)+
		adda.w     d2,a1
		dbf        d1,vt_char_bloop
		movea.l    (a7)+,a3
vt_n_column:
		move.w     V_CUR_XY0.w,d0
relok39:
		cmp.w      V_CEL_MX.w,d0
relok40:
		bge.s      vt_l_column
		addi.l     #16,V_CUR_AD.w
relok41:
		addq.w     #1,V_CUR_XY0.w
relok42:
		rts
vt_l_column:
		btst       #CURSOR_WRAP,V_STAT_0.w
relok43:
		beq.s      vt_con_exit
		addq.w     #1,hid_cnt
vt_l_column2:
		ext.l      d0
		lsl.l      #4,d0
		sub.l      d0,V_CUR_AD.w
relok44:
		clr.w      V_CUR_XY0.w
relok45:
		move.w     V_CUR_XY1.w,d1
relok46:
		pea.l      vt_con_exit2(pc)
		cmp.w      V_CEL_MY.w,d1
relok47:
		bge        scroll_up_page
		addq.l     #4,a7
		move.w     V_CEL_WR.w,d0 /* FIXME: V_CEL_WR is obsolete */
relok48:
		add.l      d0,V_CUR_AD.w
relok49:
		addq.w     #1,V_CUR_XY1.w
relok50:
vt_con_exit2:
		subq.w     #1,hid_cnt
vt_con_exit:
		rts

vt_char_col:
vt_char_rcol:
		movem.l    d3-d4/a3,-(a7)
		lea.l      V_COL_BG.w,a2
relok51:
		move.w     (a2)+,d3             ;V_COL_BG
		move.w     (a2)+,d2             ;V_COL_FG
		add.w      d2,d2
		add.w      d3,d3
		lea.l      palette_data(pc),a2
		move.w     0(a2,d2.w),d2        ;Vordergrundfarbe
		move.w     0(a2,d3.w),d3        ;Hintergrundfarbe
		btst       #CURSOR_INVERSE,V_STAT_0.w ;invertieren ?
relok52:
		beq.s      vt_char_col2
		exg        d2,d3
vt_char_col2:
		movea.l    d0,a0
		adda.w     d1,a0
		movea.w    V_FNT_WD.w,a2
relok53:
		movea.w    BYTES_LIN.w,a3
relok54:
		lea.l      -16(a3),a3
		move.w     V_CEL_HT.w,d1
relok55:
		subq.w     #1,d1                ;Zeilenzaehler
vt_char_cloop:
		move.b     (a0),d4
		moveq.l    #7,d0
vt_char_cloop2:
		add.b      d4,d4
		bcc.s      vt_char_cbg
		move.w     d2,(a1)+
		dbf        d0,vt_char_cloop2
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d1,vt_char_cloop
		movem.l    (a7)+,d3-d4 ; BUG
		bra        vt_n_column
vt_char_cbg:
		move.w     d3,(a1)+
		dbf        d0,vt_char_cloop2
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d1,vt_char_cloop
		movem.l    (a7)+,d3-d4/a3
		bra        vt_n_column

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq:
		cmpi.w     #'Y',d1
		beq        vt_seq_Y
		move.w     d1,d2
		movem.w    V_CUR_XY0.w,d0-d1
relok56:
		movea.l    V_CUR_AD.w,a1
relok57:
		movea.w    BYTES_LIN.w,a2
relok58:
		move.l     #vt_con0,mycon_state
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


;d0 Textspalte
;d1 Textzeile
;a1 Cursoradresse
;a2 Bytes pro Zeile

; ALPHA CURSOR UP (VDI 5, ESCAPE 4)/ Cursor up (VT 52 ESC A)
v_curup:
vt_seq_A:
		subq.w     #1,d1
		bra        set_cursor_xy

;ALPHA CURSOR DOWN (VDI 5,ESCAPE 5)/ Cursor down (VT52 ESC B)
v_curdown:
vt_seq_B:
		addq.w     #1,d1
		bra        set_cursor_xy

; ALPHA CURSOR RIGHT (VDI 5, ESCAPE 6)/ Cursor right (VT52 ESC C)
v_curright:
vt_seq_C:
		addq.w     #1,d0
		bra        set_cursor_xy

; ALPHA CURSOR LEFT (VDI 5, ESCAPE 7)/ Cursor left (VT52 ESC D)
v_curleft:
vt_seq_D:
		subq.w     #1,d0
		bra        set_cursor_xy

;Clear screen (VT52 ESC E)
vt_seq_E:
		bsr        cursor_off
		bsr        clear_screen
		bra.s      vt_seq_H_in

; HOME ALPHA CURSOR (VDI 5, ESCAPE 8)/ Home Cursor (VT52 ESC H)
v_curhome:
vt_seq_H:
		bsr        cursor_off
vt_seq_H_in:
		clr.l      V_CUR_XY0.w
relok59:
		movea.l    v_bas_ad.w,a1
		move.l     a1,V_CUR_AD.w
relok60:
		bra        cursor_on

;Cursor up and insert (VT52 ESC I)
vt_seq_I:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		subq.w     #1,d1
		blt        scroll_down_page
		suba.w     V_CEL_WR.w,a1 /* FIXME: V_CEL_WR is obsolete */
relok61:
		move.l     a1,V_CUR_AD.w
relok62:
		move.w     d1,V_CUR_XY1.w
relok63:
		rts

; ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
v_eeos:
vt_seq_J:
		bsr.s      vt_seq_K
		move.w     V_CUR_XY1.w,d1
relok64:
		move.w     V_CEL_MY.w,d2
relok65:
		sub.w      d1,d2
		beq.s      vt_seq_J_exit
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a1
		addq.w     #1,d1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok66:
		adda.l     d1,a1
		move.w     d2,d7
		mulu.w     V_CEL_HT.w,d7
relok67:
		subq.w     #1,d7
		bra        clear_lines
vt_seq_J_exit:
		rts

; ERASE TO END OF ALPHA TEXT LINE (VDI 5, ESCAPE 10)
v_eeol:
;Clear to end of line (VT52 ESC K)
vt_seq_K:
		bsr        cursor_off
		move.w     V_CEL_MX.w,d2
relok68:
		sub.w      d0,d2
		bsr        clear_line_part
		bra        cursor_on

;Insert line (VT52 ESC I)
vt_seq_L:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d5
relok69:
		sub.w      d1,d5
		beq.s      vt_seq_L_exit
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok70:
		movea.w    a2,a3
		move.w     V_CEL_HT.w,d0
relok71:
		mulu.w     d0,d1
		move.w     d1,d3
		add.w      d0,d3
		move.w     V_CEL_MX.w,d4
relok72:
		lsl.w      #3,d4
		addq.w     #7,d4
		mulu.w     d0,d5
		subq.w     #1,d5
		moveq.l    #3,d7
		moveq.l    #0,d0
		moveq.l    #0,d2
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		move.w     V_CUR_XY1.w,d0
relok73:
		mulu.w     V_CEL_WR.w,d0 /* FIXME: V_CEL_WR is obsolete */
relok74:
		adda.l     d0,a1
		bra        clear_line2
vt_seq_L_exit:
		movea.l    V_CUR_AD.w,a1
relok75:
		bra        clear_line2

;Delete Line (VT52 ESC M)
vt_seq_M:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok76:
		sub.w      d1,d7
		beq.s      vt_seq_M_last
		move.w     V_CEL_HT.w,d3
relok77:
		moveq.l    #0,d0
		mulu.w     d3,d1
		moveq.l    #0,d2
		add.w      d1,d3
		exg        d1,d3
		movem.w    V_CEL_MX.w,d4-d5
relok78:
		addq.w     #1,d4
		lsl.w      #4,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
relok79:
		subq.w     #1,d5
		sub.w      d1,d5
		bra        scroll_up2
vt_seq_M_last:
		move.l     a1,d0
		movea.l    v_bas_ad.w,a1
		sub.l      a1,d0
		adda.l     d0,a1
		bra        clear_line2

;Set cursor position (VT52 ESC Y)
vt_seq_Y:
		move.l     #vt_set_y,mycon_state
		rts
;y-Koordinate setzen
vt_set_y:
		subi.w     #32,d1
		move.w     V_CUR_XY0.w,d0
relok80:
		move.l     #vt_set_x,mycon_state
		bra        set_cursor_xy
;x-Koordinate setzen
vt_set_x:
		subi.w     #32,d1
		move.w     d1,d0
		move.w     V_CUR_XY1.w,d1
relok81:
		move.l     #vt_con0,mycon_state
		bra        set_cursor_xy

;Foreground color (VT52 ESC b)
vt_seq_b:
		move.l     #vt_set_b,mycon_state
		rts
vt_set_b:
		lea.l      V_COL_FG.w,a1
relok82:
vt_set_col:
		moveq.l    #15,d0
		and.w      d0,d1
		move.w     d1,(a1)
		move.l     #vt_con0,mycon_state
		rts

;Background color (VT52 ESC c)
vt_seq_c:
		move.l     #vt_set_c,mycon_state
		rts
vt_set_c:
		lea.l      V_COL_BG.w,a1
relok83:
		bra.s      vt_set_col

;Erase to start of page (VT52 ESC d)
vt_seq_d:
		bsr.s      vt_seq_o
		move.w     V_CUR_XY1.w,d1
relok84:
		beq.s      vt_seq_d_exit
		movem.l    d2-d7/a1-a6,-(a7)
		mulu.w     V_CEL_HT.w,d1
relok85:
		move.w     d1,d7
		subq.w     #1,d7
		movea.l    v_bas_ad.w,a1
		bra        clear_lines
vt_seq_d_exit:
		rts

;Show cursor (VT52 ESC e)
vt_seq_e:
		tst.w      hid_cnt
		beq.s      vt_seq_e_exit
		move.w     #1,hid_cnt
		bra        cursor_on
vt_seq_e_exit:
		rts

;Hide cursor (VT52 ESC f)
vt_seq_f:
		bra        cursor_off

;Save cursor (VT52 ESC j)
vt_seq_j:
		bset       #CURSOR_SAVED,V_STAT_0.w
relok86:
		move.l     V_CUR_XY0.w,V_SAV_XY.w
relok87:
		rts

;Restore cursor (VT52 ESC k)
vt_seq_k:
		movem.w    V_SAV_XY.w,d0-d1
relok88:
		bclr       #CURSOR_SAVED,V_STAT_0.w
relok89:
		bne        set_cursor_xy
		moveq.l    #0,d0
		moveq.l    #0,d1
		bra        set_cursor_xy

;Erase line (VT52 ESC l)
vt_seq_l:
		bsr        cursor_off
		bsr        set_x0
		bsr        clear_line
		bra        cursor_on

;Erase to line start (VT52 ESC o)
vt_seq_o:
		move.w     d0,d2
		subq.w     #1,d2
		bmi.s      vt_seq_o_exit
		movea.l    v_bas_ad.w,a1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok90:
		adda.l     d1,a1
		bra        clear_line_part
vt_seq_o_exit:
		rts

;REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
v_rvon:
vt_seq_p:
		bset       #CURSOR_INVERSE,V_STAT_0.w
relok91:
		rts

; REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
v_rvoff:
vt_seq_q:
		bclr       #CURSOR_INVERSE,V_STAT_0.w
relok92:
		rts

;Wrap at end of line (VT52 ESC v)
vt_seq_v:
		bset       #CURSOR_WRAP,V_STAT_0.w
relok93:
		rts

;Discard end of line (VT52 ESC w)
vt_seq_w:
		bclr       #CURSOR_WRAP,V_STAT_0.w
relok94:
		rts

scroll_up_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		move.w     V_CEL_HT.w,d1
relok95:
		moveq.l    #0,d2
		moveq.l    #0,d3
		movem.w    V_CEL_MX.w,d4-d5
relok96:
		addq.w     #1,d4
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
relok97:
		subq.w     #1,d5
scroll_up2:
		moveq.l    #S_ONLY,d7
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok98:
		movea.w    a2,a3
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		move.w     V_CEL_MY.w,d0
relok99:
		mulu.w     V_CEL_WR.w,d0 /* FIXME: V_CEL_WR is obsolete */
relok100:
		adda.l     d0,a1
		bra.s      clear_line2

scroll_down_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		moveq.l    #0,d1
		moveq.l    #0,d2
		move.w     V_CEL_HT.w,d3
relok101:
		movem.w    V_CEL_MX.w,d4-d5
relok102:
		addq.w     #1,d4
		addq.w     #1,d5
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     d3,d5
		subq.w     #1,d5
		moveq.l    #S_ONLY,d7
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok103:
		movea.w    a2,a3
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		bra.s      clear_line2

clear_line:
		movem.l    d2-d7/a1-a6,-(a7)
;Eingabe
;a1.l Zeilenadresse
clear_line2:
		move.w     V_CEL_HT.w,d7
relok104:
		subq.w     #1,d7
;d7.w Zeilenzaehler
clear_lines:
		move.w     V_COL_BG.w,d6        ;Hintergrundfarbe
relok105:
		beq.s      clear_lwhite         ;weiss?
		move.l     a1,d2
		movea.l    v_bas_ad.w,a1
		sub.l      a1,d2
		lsl.l      #2,d2
		adda.l     d2,a1
		add.w      d6,d6
		lea.l      palette_data(pc),a2
		adda.w     d6,a2
		move.w     (a2),d6
		swap       d6
		move.w     (a2),d6
		move.w     V_CEL_MX.w,d4
relok106:
		move.w     BYTES_LIN.w,d5
relok107:
		move.w     d4,d2
		addq.w     #1,d2
		lsl.w      #4,d2
		sub.w      d2,d5
clear_line_bloop:
		move.w     d4,d2
clear_line_loop:
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		dbf        d2,clear_line_loop
		adda.w     d5,a1
		dbf        d7,clear_line_bloop
		movem.l    (a7)+,d2-d7/a1-a6
		rts
clear_lwhite:
		moveq.l    #-1,d6
		move.w     V_CEL_MX.w,d4
relok108:
		addq.w     #1,d4      ;Zeichenanzahl pro Zeile
		move.w     BYTES_LIN.w,d5
relok109:
		move.w     d4,d2
		lsl.w      #4,d2
		sub.w      d2,d5
		subq.w     #1,d4
clear_lw_bloop:
		move.w     d4,d2
clear_lw_loop:
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		dbf        d2,clear_lw_loop
		adda.w     d5,a1
		dbf        d7,clear_lw_bloop
		movem.l    (a7)+,d2-d7/a1-a6
		rts

;Bildschirm loeschen
;Eingaben
; -
;Ausgaben
;kein Register wird zerstoert
clear_screen:
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok110:
		addq.w     #1,d7
		mulu.w     V_CEL_HT.w,d7
relok111:
		subq.w     #1,d7
		movea.l    v_bas_ad.w,a1
		bra        clear_lines

;Bereich einer Textzeile loeschen
;Eingaben
;d2.w Spaltenanzahl -1
;a1.l Adresse
;a2.w Bytes pro Zeile
;Ausgaben
;d0-d2/a0-a1 werden zerstoert
clear_line_part:
		move.l     d3,-(a7)
		move.w     V_COL_BG.w,d3
relok112:
		add.w      d3,d3
		lea.l      palette_data(pc),a0
		adda.w     d3,a0
		move.w     (a0),d3
		swap       d3
		move.w     (a0),d3
		move.w     V_CEL_HT.w,d1
relok113:
		subq.w     #1,d1
		move.w     d2,d0
		addq.w     #1,d0
		lsl.w      #4,d0
		movea.w    BYTES_LIN.w,a0
relok114:
		suba.w     d0,a0
clear_lpart_bloop:
		move.w     d2,d0
clear_lpart_loop:
		move.l     d3,(a1)+
		move.l     d3,(a1)+
		move.l     d3,(a1)+
		move.l     d3,(a1)+
		dbf        d0,clear_lpart_loop
		adda.w     a0,a1
		dbf        d1,clear_lpart_bloop
		move.l     (a7)+,d3
		rts

;Undraw Sprite ($A00C)
;Eingaben
;a2.l Zeiger auf den Sprite-Save-Block
;Ausgaben
;d2/a1-a5 werden zerstoert
undraw_sprite:
		move.w     (a2)+,d2
		subq.w     #1,d2         ; line counter - 1 for dbra
		bmi        undraw_exit
		movea.l    (a2)+,a1      ; destination address
		bclr       #0,(a2)       ; save block valid?
		beq        undraw_exit
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      TS_I(a5),a4
		move.b     (a4),-(a7)
		move.b     #0x02,(a4)+
		move.b     (a4),-(a7)
		move.b     #0x0f,(a4)
		move.b     #0x04,-1(a4)
		move.b     (a4),-(a7)
		andi.b     #0xF7,(a4)
		lea.l      GDC_I(a5),a5
		move.b     (a5),-(a7)
		move.b     #0x05,(a5)+
		move.b     (a5),-(a7)
		andi.b     #0xFC,(a5)
		move.b     #0x01,-1(a5)
		move.b     (a5),-(a7)
		move.b     #0x00,(a5)
		move.b     #0x08,-1(a5)
		move.b     (a5),-(a7)
		move.b     #0x00,(a5)
		movea.l    vga_memend1(pc),a0
		move.b     d2,(a0)
		ori.b      #0x08,(a4)
		move.b     #0xff,(a5)
		movea.w    BYTES_LIN.w,a3
relok115:
		lea.l      -32(a3),a3   ; offset to next line
		addq.l     #2,a2        ; address of saved background
undraw_spr_loop:
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		adda.w     a3,a1
		dbf        d2,undraw_spr_loop
		andi.b     #0xF7,(a4)
		tst.b      (a0)
		move.b     #0x08,-(a5)
		move.b     (a7)+,1(a5)
		move.b     #0x01,(a5)+
		move.b     (a7)+,(a5)
		move.b     #0x05,-(a5)
		move.b     (a7)+,1(a5)
		move.b     (a7)+,(a5)
		move.b     #0x04,-(a4)
		move.b     (a7)+,1(a4)
		move.b     #0x02,(a4)+
		move.b     (a7)+,(a4)
		move.b     (a7)+,-(a4)
undraw_exit:
		rts

;Draw Sprite ($A00D)
;Eingaben
;d0.w x
;d1.w y
;a0.l Zeiger auf die Spritedefinition
;a2.l Zeiger auf den Hintergrundbuffer
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
draw_sprite:
		moveq.l    #15,d2     ; width - 1
		moveq.l    #15,d3     ; height - 1
		moveq.l    #0,d6
		moveq.l    #0,d7
		move.b     7(a0),d6   ; background color
		move.b     9(a0),d7   ; foreground color
		lsl.l      #3,d6
		lsl.l      #3,d7
		movea.l    aes_wk_ptr(pc),a1
		movea.l    wk_ctab(a1),a1
		lea.l      ctab_colors+2(a1,d6.l),a3
		move.w     (a3)+,d6
		lsl.l      #5,d6
		move.w     (a3)+,d6
		lsl.l      #5,d6
		move.w     (a3)+,d6
		lsl.l      #5,d6
		swap       d6
		lea.l      ctab_colors+2(a1,d7.l),a3
		move.w     (a3)+,d7
		lsl.l      #5,d7
		move.w     (a3)+,d7
		lsl.l      #5,d7
		move.w     (a3)+,d7
		lsl.l      #5,d7
		swap       d7
		movea.l    aes_wk_ptr(pc),a1
		btst       #7,bitmap_flags+1(a1)
		beq.s      draw_spr_swap
		rol.w      #8,d6
		rol.w      #8,d7
draw_spr_swap:
		sub.w      (a0)+,d0      ; X_Koord - intxhot
		bpl.s      draw_spr_x2
		add.w      d0,d2         ; width to draw - 1
		bmi        draw_spr_exit
draw_spr_x2:
		move.w     DEV_TAB0.w,d4 ; WORK_OUT[0] max. raster width
relok116:
		subi.w     #15,d4
		sub.w      d0,d4
		bge.s      draw_spr_y
		add.w      d4,d2         ; width to draw - 1
		bmi        draw_spr_exit
draw_spr_y:
		sub.w      (a0)+,d1      ; Y_Koord - intyhot
		addq.l     #6,a0         ; pointer to sprite-image
		bpl.s      draw_spr_y2
		add.w      d1,d3         ; height to draw - 1
		bmi        draw_spr_exit
		add.w      d1,d1
		add.w      d1,d1
		suba.w     d1,a0         ; adjust sprite start address
		moveq.l    #0,d1
draw_spr_y2:
		move.w     DEV_TAB1.w,d5 ; WORK_OUT[1] max. raster height
relok117:
		subi.w     #15,d5
		sub.w      d1,d5
		bge.s      draw_spr_save
		add.w      d5,d3         ; height to draw - 1
		bmi        draw_spr_exit
draw_spr_save:
		move.w     d3,(a2)
		addq.w     #1,(a2)+      ; saved number of lines
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      TS_I(a5),a4
		move.b     (a4),-(a7)
		move.b     #0x02,(a4)+
		move.b     (a4),-(a7)
		move.b     #0x0F,(a4)
		move.b     #0x04,-1(a4)
		move.b     (a4),-(a7)
		andi.b     #0xF7,(a4)
		lea.l      GDC_I(a5),a5
		move.b     (a5),-(a7)
		move.b     #0x05,(a5)+
		move.b     (a5),-(a7)
		andi.b     #0xFC,(a5)
		move.b     #0x01,-1(a5)
		move.b     (a5),-(a7)
		move.b     #0x00,(a5)
		move.b     #0x08,-1(a5)
		move.b     (a5),-(a7)
		move.b     #0x00,(a5)
		movea.l    vga_memend1(pc),a1
		move.b     d2,(a1)
		ori.b      #0x08,(a4)
		move.b     #0xFF,(a5)
		move.l     a4,-(a7)
		muls.w     BYTES_LIN.w,d1
relok118:
		movea.l    v_bas_ad.w,a1
		adda.l     d1,a1         ; line address
		movea.l    a1,a4
		move.w     d0,d4
		cmp.w      #15,d2        ; full width?
		beq.s      draw_spr_saddr
		moveq.l    #0,d4
		tst.w      d0            ; beyond left margin?
		bmi.s      draw_spr_saddr
		moveq.l    #-15,d4
		add.w      DEV_TAB0.w,d4 ;32 bytes away from right margin
relok119:
draw_spr_saddr:
		add.w      d4,d4
		adda.w     d4,a4
		move.l     a4,(a2)+      ; address of saved background
		move.w     #256,(a2)+    ; mark as valid
		movea.w    BYTES_LIN.w,a3
relok120:
		lea.l      -32(a3),a3    ; offset to next line
		move.w     d3,d5
draw_spr_sloop:
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		adda.w     a3,a4
		dbf        d5,draw_spr_sloop
		movea.w    BYTES_LIN.w,a3
relok121:
		suba.w     d2,a3
		suba.w     d2,a3
		subq.w     #2,a3
		adda.w     d0,a1
		adda.w     d0,a1
		cmp.w      #15,d2        ; mouse pointer at screen margins?
		beq.s      draw_it
		tst.w      d0
		bpl.s      draw_it       ; at left margin?
		suba.w     d0,a1
		suba.w     d0,a1
		neg.w      d0
		bra.s      draw_spr_bloop
draw_it:
		moveq.l    #0,d0
draw_spr_bloop:
		move.w     (a0)+,d4      ; background mask
		move.w     (a0)+,d5      ; foreground mask
		lsl.w      d0,d4         ; shift if at left margin
		lsl.w      d0,d5
		move.w     d2,d1         ; width counter
draw_spr_loop:
		add.w      d5,d5         ; foreground bit set?
		bcc.s      draw_spr_bg
		move.w     d7,(a1)+
		add.w      d4,d4
		dbf        d1,draw_spr_loop
		bra.s      draw_spr_next
draw_spr_bg:
		add.w      d4,d4         ; background bit set?
		bcc.s      draw_spr_nth
		move.w     d6,(a1)+
		dbf        d1,draw_spr_loop
		bra.s      draw_spr_next
draw_spr_nth:
		addq.l     #2,a1
		dbf        d1,draw_spr_loop
draw_spr_next:
		adda.w     a3,a1
		dbf        d3,draw_spr_bloop ; next line
		movea.l    (a7)+,a4
		andi.b     #0xF7,(a4)
		movea.l    vga_memend1(pc),a1
		tst.b      (a1)
		move.b     #0x08,-(a5)
		move.b     (a7)+,1(a5)
		move.b     #0x01,(a5)+
		move.b     (a7)+,(a5)
		move.b     #0x05,-(a5)
		move.b     (a7)+,1(a5)
		move.b     (a7)+,(a5)
		lea.l      TS_I-GDC_I(a5),a5
		move.b     #0x04,(a5)+
		move.b     (a7)+,(a5)
		move.b     #0x02,-1(a5)
		move.b     (a7)+,(a5)
		move.b     (a7)+,-(a5)
draw_spr_exit:
		rts

vbl_mouse:
		lea.l      vscr_struct+10(pc),a1
		movem.w    (a1),d2-d5
		subq.w     #1,d4
		subq.w     #1,d5
		move.w     d4,d7
		swap       d7
		move.w     d5,d7
		move.l     vgamode+vga_xres(pc),d6
		cmp.l      d7,d6
		beq        vbl_mouse_exit
		add.w      d2,d4
		add.w      d3,d5
		moveq.l    #-32,d0
		moveq.l    #-32,d1
		add.w      GCURX.w,d0
relok122:
		add.w      GCURY.w,d1
relok123:
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
		add.w      d2,d2
		moveq.l    #7,d0
		and.w      d2,d0
		sub.w      d0,d2
		mulu.w     vgamode+vga_line_width(pc),d3
		ext.l      d2
		add.l      d3,d2
		lsr.l      #2,d2
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
relok124:
		move.w     d2,WIDTH.w
relok125:
		move.w     d2,BYTES_LIN.w
relok126:
		movem.l    (a7)+,d0-d2/a0-a2
		rts

;VT52-Emulator an die gewaehlte Aufloesung anpassen
;kein Register wird zerstoert
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
relok127:
		move.w     d1,V_REZ_VT.w
relok128:
		movea.l    _sf_font_hdr_ptr(a0),a1
		lea.l      sizeof_FONTHDR(a1),a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		lea.l      sizeof_FONTHDR(a1),a1
init_vt52_font:
		move.l     dat_table(a1),V_FNT_AD.w
relok129:
		move.l     off_table(a1),V_OFF_AD.w
relok130:
		move.w     #256,V_FNT_WD.w
relok131:
		move.l     #0x00FF0000,V_FNT_ND.w
relok132:
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT.w
relok133:
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		movem.w    d0-d2,V_CEL_MX.w ; V_CEL_MX/V_CEL_MY/V_CEL_WR
relok134:
		move.l     #15,V_COL_BG.w
relok135:
		move.w     #1,V_HID_CNT.w
relok136:
		move.w     #1,hid_cnt
		move.w     #256,V_STAT_0.w
relok137:
		move.w     #0x1E1E,V_PERIOD.w
relok138:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok139:
		clr.l      V_CUR_XY.w
relok140:
		clr.w      V_CUR_OF.w
relok141:
		move.l     #vt_con0,mycon_state
		movem.l    (a7)+,d0-d4/a0-a2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Expandier-Tabelle erstellen

build_exp:
		movem.l    d0-d2/a0-a1,-(a7)
		lea.l      expand_tab(pc),a0
		moveq.l    #0,d0
build_exp_bloop:
		move.w     d0,d1
		moveq.l    #7,d2
build_exp_loop:
		clr.w      (a0)+
		add.b      d1,d1
		bcs.s      build_exp_next
		not.w      -2(a0)
build_exp_next:
		dbf        d2,build_exp_loop
		addq.w     #1,d0
		cmp.w      #256,d0
		blt.s      build_exp_bloop
		movem.l    (a7)+,d0-d2/a0-a1
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
		movem.l    d0-d7/a0-a6,-(a7)
		bsr.s      initmode
		bsr        clear_framebuffer
		movem.l    (a7)+,d0-d7/a0-a6
		rts

initmode:
		cmpi.w     #2,x1118a
		bne.s      initmode_1
		bsr        x10858
initmode_1:
		tst.w      x1118a
		bne.s      initmode_2
		clr.w      0x00D02000
initmode_2:
		movea.l    vgamode+vga_membase(pc),a0
		movea.l    a0,a1
		adda.l     #0x0003FFFF,a0
		adda.l     #0x00100000,a1
		move.l     a0,vga_memend1
		move.l     a1,vga_memend2
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     vgamode+vga_MISC_W(pc),d0
		cmpi.w     #1,x1118a
		bne.s      initmode_3
		and.b      #0xF3,d0
		or.b       #0x03,d0
initmode_3:
		move.b     d0,MISC_W(a0)
		move.b     #0x01,VIDSUB(a0)      /* Enable VGA mode */
		cmpi.w     #1,x1118a
		bne.s      initmode_4
		moveq.l    #8,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #4,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #4,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #4,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #4,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #8,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
		moveq.l    #12,d1
		or.b       d0,d1
		move.b     d1,MISC_W(a0)
initmode_4:
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
		cmpi.w     #1,x1118a
		bne.s      initmode_6
		cmpi.w     #2,x1118c
		bne.s      initmode_6
		move.b     #0x07,(a1)
		move.b     #0xA4,(a2)
initmode_6:
		move.b     #0x00,(a1)
		move.b     #0x03,(a2)
		cmpi.w     #2,x1118a
		bne.s      initmode_7
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0xA0,DAC_PEL(a0)
initmode_7:
		cmpi.w     #1,x1118a
		bne.s      initmode_9
		cmpi.w     #2,x1118c
		bne.s      initmode_8
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     #0xA0,DAC_PEL(a0)
initmode_8:
		moveq.l    #31,d0
		and.w      vgamode+vga_synth,d0
		lea.l      synth_tab(pc),a1
		move.b     0(a1,d0.w),d0
		cmpi.w     #1,vgamode+vga_dac_type
		beq.s      initmode_8_1
		bset       #7,d0
initmode_8_1:
		move.b     d0,(a0) ; BUG? should that be DAC_PEL(a0)?
initmode_9:
		cmpi.w     #3,x1118a
		bne.s      initmode_10
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     DAC_PEL(a0),d0
		move.b     vgamode+vga_PEL(pc),DAC_PEL(a0)
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

		cmpi.w     #1,x1118a
		bne.s      initmode_14
		cmpi.w     #2,x1118c
		bne.s      initmode_14
		move.b     #0x16,(a1)
		move.b     #0x80,(a1)
initmode_14:
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
		bne.s      initmode_15
		rts
initmode_15:
		move.w     vgamode+vga_xres(pc),d0
		addq.w     #1,d0
		add.w      d0,d0
		move.w     d0,vgamode+vga_line_width
		movea.l    vgamode+vga_regbase(pc),a0
		lea.l      CRTC_IG(a0),a0
		lsr.w      #3,d0
		move.b     #0x13,(a0)+
		move.b     d0,(a0)
		rts

x10858:
		move.w     d3,-(a7)
		move.w     vgamode+vga_synth,d0
		move.w     d0,d3
		and.w      #0x001F,d3
		or.w       #0x0040,d3
		move.w     d3,d0
		bsr.s      x10896
		moveq.l    #32,d0
		or.w       d3,d0
		bsr.s      x10896
		move.w     d3,d0
		bsr.s      x10896
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     #0x03,GENHP(a0)      /* enable upper 32k of graphics mode buffer */
		move.b     #0xA0,CGAMODE(a0)    /* enable ET4000 extensions */
		move.b     #0x34,CRTC_IG(a0)    /* unlock registers */
		clr.b      CRTC_DG(a0)
		move.w     (a7)+,d3
		rts

x10896:
		movem.l    d1-d3/a0,-(a7)
		movea.l    vgamode+vga_regbase(pc),a0
		move.b     GENMO(a0),d1
		and.w      #0xFFF3,d1
		move.w     #0x8000,d2
x10896_1:
		move.w     d0,d3
		and.w      d2,d3
		beq.s      x10896_2
		move.w     d1,d3
		or.b       #0x04,d3
		move.b     d3,MISC_W(a0)
		or.b       #0x08,d3
		move.b     d3,MISC_W(a0)
		bra.s      x10896_3
x10896_2:
		move.w     d1,d3
		move.b     d3,MISC_W(a0)
		or.b       #0x08,d3
		move.b     d3,MISC_W(a0)
x10896_3:
		lsr.w      #1,d2
		bne.s      x10896_1
		move.b     #0x03,GENHP(a0)      /* enable upper 32k of graphics mode buffer */
		move.b     #0xA0,CGAMODE(a0)    /* enable ET4000 extensions */
		move.b     #0x34,CRTC_IG(a0)    /* unlock registers */
		andi.b     #0xFD,CRTC_DG(a0)
		ori.b      #0x02,CRTC_DG(a0)    /* enable Hercules emulation */
		movem.l    (a7)+,d1-d3/a0
		rts

clear_framebuffer:
		movea.l    vgamode+vga_membase(pc),a1
		move.w     vgamode+vga_xres(pc),d2
		moveq.l    #0,d1
		move.w     #0x7C00,d5 /* red mask */
		moveq.l    #0x001f,d6 /* blue mask */
		move.w     #0x03E0,d7 /* green mask */
clear_framebuffer1:
		moveq.l    #0,d0
clear_framebuffer2:
		move.w     d1,d3
		sub.w      d0,d3
		move.w     d3,d4
		and.w      d5,d3
		neg.w      d4
		and.w      d6,d4
		or.w       d4,d3
		move.w     d1,d4
		add.w      d0,d4
		and.w      d7,d4
		or.w       d4,d3
		rol.w      #8,d3
		move.w     d3,(a1)+
		addq.w     #1,d0
		cmp.w      d2,d0
		ble.s      clear_framebuffer2
		addq.w     #1,d1
		cmp.w      vgamode+vga_yres,d1
		ble.s      clear_framebuffer1
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
		move.w     #255,colors(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation,a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.l     p_fbox(a6),fbox_ptr
		move.l     p_hline(a6),hline_ptr
		move.l     p_bitblt(a6),bitblt_ptr
		move.l     p_escapes(a6),escape_ptr
		move.l     #fbox,p_fbox(a6)
		move.l     #hline,p_hline(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #v_escape,p_escapes(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     #32768,d0
		bsr        alloc_ctable
		move.l     a0,wk_ctab(a6)
		bne.s      wk_init1
		move.l     global_ctable(pc),wk_ctab(a6)
wk_init1:
		moveq.l    #1,d0
		rts

wk_reset:
		movem.l    d0-d2/a0-a1,-(a7)
		move.l     wk_ctab(a6),d0
		beq.s      wk_reset1
		cmp.l      global_ctable(pc),d0
		beq.s      wk_reset1
		movea.l    d0,a0
		bsr        free_ctable
wk_reset1:
		movem.l    (a7)+,d0-d2/a0-a1
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '7. Escapes'

;VDI-Escapes abarbeiten
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d1.l pb
;a0.l pb
;a6.l Workstation
;Ausgaben:
;-
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
relok142:
		movea.l    V_CUR_AD.w,a1
relok143:
		movea.w    BYTES_LIN.w,a2
relok144:
		jsr        v_escape_tab(pc,d2.w)
		movem.l    (a7)+,d1-d7/a2-a5
v_escape_exit:
		rts
v_escape_unof:
		movea.l    escape_ptr(pc),a1
		jmp        (a1)

v_escape_tab:     DC.W v_escape_exit-v_escape_tab
                  DC.W vq_chcells-v_escape_tab ;1
                  DC.W v_exit-v_escape_tab ;2
                  DC.W v_enter_cur-v_escape_tab ;3
                  DC.W v_curup-v_escape_tab ;4
                  DC.W v_curdown-v_escape_tab ;5
                  DC.W v_curright-v_escape_tab ;6
                  DC.W v_curleft-v_escape_tab ;7
                  DC.W v_curhome-v_escape_tab ;8
                  DC.W v_eeos-v_escape_tab ;9
                  DC.W v_eeol-v_escape_tab ;10
                  DC.W v_curaddress-v_escape_tab ;11
                  DC.W v_curtext-v_escape_tab ;12
                  DC.W v_rvon-v_escape_tab ;13
                  DC.W v_rvoff-v_escape_tab ;14
                  DC.W vq_curaddress-v_escape_tab ;15

; INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS (VDI 5, ESCAPE 1)
vq_chcells:
		move.l     V_CEL_MX.w,d3
relok145:
		addi.l     #0x00010001,d3
		swap       d3
		move.l     d3,(a4)
		move.w     #2,v_nintout(a0)
		rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:
		addq.w     #1,hid_cnt
		bclr       #CURSOR_STATE,V_STAT_0.w
relok146:
		bra        clear_screen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:
		clr.l      V_CUR_XY0.w
relok147:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok148:
		move.l     #vt_con0,mycon_state
		bsr        clear_screen
		bclr       #CURSOR_STATE,V_STAT_0.w
relok149:
		move.w     #1,hid_cnt
		bra        cursor_on

; DIRECT ALPHA CURSOR ADDRESS (VDI 5, ESCAPE 11)
v_curaddress:
		move.w     (a5)+,d1
		move.w     (a5)+,d0
		subq.w     #1,d0
		subq.w     #1,d1
		bra        set_cursor_xy

; INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15)
vq_curaddress:
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     d1,(a4)+
		move.w     d0,(a4)+
		move.w     #2,v_nintout(a0)
		rts

;horizontalen Linie ohne Clipping zeichnen
;Vorgaben:
;Register d0-d2/d4-d7/a1 koennen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y
;d2.w x2
;d6.w Linienmuster
;d7.w Schreibmodus
;a6.l Workstation
;Ausgaben:
;-
hline_exit:
		movea.l    hline_ptr(pc),a1
		jmp        (a1)

hline_modes1:
	dc.b 15,12
	
hline:
		cmp.w      #-1,d7
		bne.s      hline_exit
		cmpi.w     #MD_TRANS-1,wr_mode(a6)
		bgt.s      hline_exit
		move.l     r_fg_pixel+2(a6),d4 ; get pixel value into upper 16 bit
		move.w     r_fg_pixel+2(a6),d4 ; get pixel value into lowet 16 bit
		movea.l    v_bas_ad.w,a1
		cmpa.l     vgamode+vga_membase(pc),a1
		bne.s      hline_exit
		moveq.l    #-32,d6
		add.w      d2,d6
		sub.w      d0,d6
		bmi        hline5
		tst.w      d4
		beq.s      hline1
		cmp.w      #0xFF7F,d4
		bne        hline5
		moveq.l    #-1,d4
hline1:
		move.w     BYTES_LIN.w,d5
relok150:
		lsr.w      #2,d5
		muls.w     d5,d1
		move.w     d0,d7
		lsr.w      #1,d7
		ext.l      d7
		add.l      d7,d1
		adda.l     d1,a1
		move.l     a5,-(a7)
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      TS_I(a5),a5
		move.b     #0x04,(a5)+
		andi.b     #0xF7,(a5)
		move.b     #0x02,-1(a5)
		moveq.l    #1,d5
		and.w      d0,d5
		move.b     hline_modes1(pc,d5.w),(a5)
		move.b     d4,(a1)+
		move.b     #0x0F,(a5)
		moveq.l    #1,d5
		and.w      d2,d5
		lsr.w      #1,d0
		lsr.w      #1,d2
		sub.w      d0,d2
		subq.w     #1,d2
		btst       #0,d1
		bne.s      hline2
		move.b     d4,(a1)+
		subq.w     #1,d2
hline2:
		moveq.l    #3,d7
		move.w     d2,d0
		not.w      d0
		and.w      d7,d0
		add.w      d0,d0
		lsr.w      #2,d2
		subq.w     #1,d2
		move.w     d2,d1
		not.w      d1
		and.w      d7,d1
		add.w      d1,d1
		lsr.w      #2,d2
		jmp        hline3(pc,d1.w)
hline3:
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		dbf        d2,hline3
		jmp        hline4(pc,d0.w)
hline4:
		move.b     d4,(a1)+
		move.b     d4,(a1)+
		move.b     d4,(a1)+
		move.b     hline_modes2(pc,d5.w),(a5)
		move.b     d4,(a1)
		move.b     #0x04,-(a5)
		ori.b      #0x08,1(a5)
		move.b     #0x02,(a5)+
		move.b     #0x0F,(a5)
		movea.l    (a7)+,a5
		rts

hline_modes2:
	dc.b 3,15

hline5:
		muls.w     BYTES_LIN.w,d1
relok151:
		ext.l      d0
		add.l      d0,d1
		add.l      d0,d1
		adda.l     d1,a1
		sub.w      d0,d2
		btst       #0,d2
		bne.s      hline6
		move.w     d4,(a1)+
		subq.w     #1,d2
		bmi.s      hline8
hline6:
		moveq.l    #14,d0
		and.w      d2,d0
		eori.w     #14,d0
		lsr.w      #4,d2
		jmp        hline7(pc,d0.w)
hline7:
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		dbf        d2,hline7
hline8:
		rts

fbox_default:
		movea.l    fbox_ptr(pc),a0
		jmp        (a0)

;Gefuelltes Rechteck ohne Clipping zeichnen
;Vorgaben:
;Register d0-d7/a0-a6 koennen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Workstation (wr_mode, f_pointer, f_interior, f_color)
;Ausgaben:
;-
fbox:
		tst.l      r_fg_pixel(a6)
		bne.s      fbox_default
		movea.l    v_bas_ad.w,a1
		cmpa.l     vgamode+vga_membase(pc),a1
		bne.s      fbox_default
		move.w     f_interior(a6),d6
		move.w     wr_mode(a6),d7
		bne.s      fbox1
		tst.w      d6
		beq.s      fbox2
		subq.w     #1,d6
		beq.s      fbox3
		subq.w     #1,d6
		bne.s      fbox_default
		cmpi.w     #8,f_style(a6)
		bne.s      fbox_default
		bra.s      fbox3
fbox1:
		subq.w     #1,d7
		bne.s      fbox_default
		subq.w     #1,d6
		beq.s      fbox3
		subq.w     #1,d6
		bne.s      fbox_default
		cmpi.w     #8,f_style(a6)
		bne.s      fbox_default
		bra.s      fbox3

fbox_modes1:
	dc.b 15,12,3,15

fbox2:
		move.l     #0xFF7FFF7F,d4
		bra.s      fbox4
fbox3:
		move.l     r_fg_pixel+2(a6),d4
		move.w     r_fg_pixel+2(a6),d4 ; BUG?
fbox4:
		sub.w      d1,d3
		move.w     BYTES_LIN.w,d6
relok152:
		movea.w    d6,a3
		muls.w     d6,d1
		ext.l      d0
		add.l      d0,d1
		add.l      d0,d1
		moveq.l    #-32,d6
		add.w      d2,d6
		sub.w      d0,d6
		bmi        fbox12
		tst.w      d4
		beq.s      fbox5
		cmp.w      #0xFF7F,d4
		bne        fbox12
		moveq.l    #-1,d4
fbox5:
		lsr.l      #2,d1
		adda.l     d1,a1
		moveq.l    #1,d5
		and.w      d0,d5
		moveq.l    #1,d6
		and.w      d2,d6
		move.b     fbox_modes1(pc,d5.w),d5
		move.b     fbox_modes1+2(pc,d6.w),d6
		lsr.w      #1,d0
		lsr.w      #1,d2
		sub.w      d0,d2
		move.w     a3,d0
		lsr.w      #2,d0
		sub.w      d2,d0
		movea.w    d0,a3
		subq.w     #1,d2
		btst       #0,d1
		bne.s      fbox6
		subq.w     #1,d2
fbox6:
		moveq.l    #3,d7
		move.w     d2,d0
		not.w      d0
		and.w      d7,d0
		add.w      d0,d0
		lsr.w      #2,d2
		subq.w     #1,d2
		and.w      d2,d7
		eori.w     #3,d7
		add.w      d7,d7
		lsr.w      #2,d2
		lea.l      fbox10(pc,d7.w),a0
		lea.l      fbox11(pc,d0.w),a4
		btst       #0,d1
		bne.s      fbox7
		movea.l    a0,a2
		lea.l      fbox9(pc),a0
fbox7:
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      TS_I(a5),a5
		move.b     #0x04,(a5)+
		andi.b     #0xF7,(a5)
		move.b     #0x02,-1(a5)
		move.w     #15,d7
fbox8:
		move.b     d5,(a5)
		move.b     d4,(a1)+
		move.b     d7,(a5)
		move.w     d2,d0
		jmp        (a0)
fbox9:
		move.b     d4,(a1)+
		jmp        (a2)
fbox10:
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		dbf        d0,fbox10
		jmp        (a4)
fbox11:
		move.b     d4,(a1)+
		move.b     d4,(a1)+
		move.b     d4,(a1)+
		move.b     d6,(a5)
		move.b     d4,(a1)
		adda.w     a3,a1
		dbf        d3,fbox8
		move.b     #0x04,-(a5)
		ori.b      #0x08,1(a5)
		move.b     #0x02,(a5)+
		move.b     #0x0F,(a5)
		rts

fbox12:
		sub.w      d0,d2
		adda.l     d1,a1
		move.w     d2,d0
		addq.w     #1,d0
		add.w      d0,d0
		suba.w     d0,a3
		btst       #0,d2
		bne.s      fbox13
		lea.l      fbox15(pc),a0
		lea.l      fbox17(pc),a2
		subq.w     #1,d2
		bmi.s      fbox14
		moveq.l    #14,d0
		and.w      d2,d0
		eori.w     #14,d0
		lsr.w      #4,d2
		lea        fbox16(pc,d0.w),a2
		bra.s      fbox14
fbox13:
		moveq.l    #14,d0
		and.w      d2,d0
		eori.w     #14,d0
		lsr.w      #4,d2
		lea.l      fbox16(pc,d0.w),a0
fbox14:
		move.w     d2,d0
		jmp        (a0)
fbox15:
		move.w     d4,(a1)+
		jmp        (a2)
fbox16:
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		move.l     d4,(a1)+
		dbf        d0,fbox16
fbox17:
		adda.w     a3,a1
		dbf        d3,fbox14
		rts

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
bitblt_ret:
		movem.w    (a7)+,d6-d7
		movea.l    bitblt_ptr(pc),a4
		jmp        (a4)

bitblt_in:
		movem.w    d4-d5,-(a7)
		bra.s      bitblt1
bitblt:
		movem.w    d6-d7,-(a7)
		cmp.w      d4,d6
		bne.s      bitblt_ret
		cmp.w      d5,d7
		bne.s      bitblt_ret
		btst       #4,r_wmode+1(a6)
		bne.s      bitblt_ret
		moveq.l    #15,d7
		and.w      r_wmode(a6),d7
		movea.l    r_saddr(a6),a0
		movea.l    r_daddr(a6),a1
		movea.w    r_swidth(a6),a2
		movea.w    r_dwidth(a6),a3
		/* BUG: does not check planes */
bitblt1:
		cmpa.l     vgamode+vga_membase(pc),a0
		bne.s      bitblt_ret
		cmpa.l     a0,a1
		bne.s      bitblt_ret
		cmpa.w     vgamode+vga_line_width(pc),a2
		bne.s      bitblt_ret
		cmpa.w     a2,a3
		bne.s      bitblt_ret
		cmp.w      #3,d7
		bne.s      bitblt_ret
		cmp.w      #15,d4
		ble.s      bitblt_ret
		moveq.l    #1,d6
		moveq.l    #1,d7
		and.w      d0,d6
		and.w      d2,d7
		cmp.w      d6,d7
		bne.s      bitblt_ret
		addq.l     #4,a7
		ext.l      d0
		ext.l      d2
		move.w     a2,d6
		mulu.w     d6,d1
		add.l      d0,d1
		add.l      d0,d1
		adda.l     d1,a0
		move.w     a3,d6
		mulu.w     d6,d3
		add.l      d2,d3
		add.l      d2,d3
		adda.l     d3,a1
		cmpa.l     a1,a0
		bhi        bitblt7
		move.w     a2,d6
		mulu.w     d5,d6
		movea.l    a0,a4
		adda.l     d6,a4
		adda.w     d4,a4
		adda.w     d4,a4
		cmpa.l     a1,a4
		bcs        bitblt7
		addq.l     #2,a4
		add.l      a4,d1
		sub.l      a0,d1
		movea.l    a1,a5
		move.w     a3,d6
		mulu.w     d5,d6
		adda.l     d6,a5
		adda.w     d4,a5
		adda.w     d4,a5
		addq.l     #2,a5
		add.l      a5,d3
		sub.l      a1,d3
		exg        a0,a4
		exg        a1,a5
		bra.s      bitblt2

blt_modes1:
	dc.b 15,12,3,15

bitblt2:
		tst.w      is_mste
		beq.s      bitblt3
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
bitblt3:
		suba.l     d1,a0
		suba.l     d3,a1
		addq.l     #3,d1
		addq.l     #3,d3
		lsr.l      #2,d1
		lsr.l      #2,d3
		adda.l     d1,a0
		adda.l     d3,a1
		add.w      d0,d4
		moveq.l    #1,d2
		moveq.l    #1,d3
		and.w      d0,d2
		and.w      d4,d3
		move.b     blt_modes1(pc,d2.w),d2
		move.b     blt_modes1+2(pc,d3.w),d3
		moveq.l    #15,d6
		lsr.w      #1,d0
		lsr.w      #1,d4
		sub.w      d0,d4
		addq.w     #1,d4
		move.w     a2,d0
		lsr.w      #2,d0
		sub.w      d4,d0
		move.w     a3,d1
		lsr.w      #2,d1
		sub.w      d4,d1
		subq.w     #3,d4
		move.w     d4,d7
		lsr.w      #4,d4
		not.w      d7
		and.w      d6,d7
		add.w      d7,d7
		lea.l      bitblt5(pc,d7.w),a4
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      GDC_I(a5),a6
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		ori.b      #0x01,(a6)
		lea.l      TS_I(a5),a5
		move.b     #0x04,(a5)+
		andi.b     #0xF7,(a5)
		move.b     #0x02,-1(a5)
bitblt4:
		move.w     d4,d7
		move.b     d3,(a5)
		move.b     -(a0),-(a1)
		move.b     d6,(a5)
		jmp        (a4)
bitblt5:
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
		dbf        d7,bitblt5
		move.b     d2,(a5)
		move.b     -(a0),-(a1)
		suba.w     d0,a0
		suba.w     d1,a1
		dbf        d5,bitblt4
		move.b     #0x04,-(a5)
		ori.b      #0x08,1(a5)
		move.b     #0x02,(a5)+
		move.b     d6,(a5)
		andi.b     #0xFC,(a6)
		tst.w      is_mste
		beq.s      bitblt6
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
bitblt6:
		rts

blt_modes2:
	dc.b 15,12,3,15

bitblt7:
		tst.w      is_mste
		beq.s      bitblt8
		move.b     MSTE_CACHE_CTRL.w,-(a7) /* save cache ctrl */
		andi.b     #0xFE,MSTE_CACHE_CTRL.w /* set 8Mz */
bitblt8:
		suba.l     d1,a0
		suba.l     d3,a1
		lsr.l      #2,d1
		lsr.l      #2,d3
		adda.l     d1,a0
		adda.l     d3,a1
		add.w      d0,d4
		moveq.l    #1,d2
		moveq.l    #1,d3
		and.w      d0,d2
		and.w      d4,d3
		move.b     blt_modes2(pc,d2.w),d2
		move.b     blt_modes2+2(pc,d3.w),d3
		moveq.l    #15,d6
		lsr.w      #1,d0
		lsr.w      #1,d4
		sub.w      d0,d4
		move.w     a2,d0
		lsr.w      #2,d0
		sub.w      d4,d0
		move.w     a3,d1
		lsr.w      #2,d1
		sub.w      d4,d1
		subq.w     #2,d4
		move.w     d4,d7
		lsr.w      #4,d4
		not.w      d7
		and.w      d6,d7
		add.w      d7,d7
		lea.l      bitblt10(pc,d7.w),a4
		movea.l    vgamode+vga_regbase(pc),a5
		lea.l      GDC_I(a5),a6
		move.b     #0x05,(a6)+
		andi.b     #0xFC,(a6)
		ori.b      #0x01,(a6)
		lea.l      TS_I(a5),a5
		move.b     #0x04,(a5)+
		andi.b     #0xF7,(a5)
		move.b     #0x02,-1(a5)
bitblt9:
		move.w     d4,d7
		move.b     d2,(a5)
		move.b     (a0)+,(a1)+
		move.b     d6,(a5)
		jmp        (a4)
bitblt10:
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
		dbf        d7,bitblt10
		move.b     d3,(a5)
		move.b     (a0),(a1)
		adda.w     d0,a0
		adda.w     d1,a1
		dbf        d5,bitblt9
		move.b     #0x04,-(a5)
		ori.b      #0x08,1(a5)
		move.b     #0x02,(a5)+
		move.b     d6,(a5)
		andi.b     #0xFC,(a6)
		tst.w      is_mste
		beq.s      bitblt11
		move.b     (a7)+,MSTE_CACHE_CTRL.w /* restore cache ctrl */
bitblt11:
		rts
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

alloc_ctable:
		moveq.l    #1,d1
		movea.l    nvdi_struct,a0
		movea.l    _nvdi_create_ctab(a0),a0
		jsr        (a0)
		rts

free_ctable:
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_Mfree_sys(a1),a1
		jsr        (a1)
		rts

		.data

dev_name:
		dc.b 'VGA 32768 Farben',0
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
                  DC.W relok14-relok13-2,2
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
                  DC.W relok40-relok39
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
                  DC.W relok87-relok86-2,2
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
                  DC.W relok110-relok109
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
                  DC.W 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS
is_mste:          ds.w 1
redirect_ptr:     ds.l 1		; redirect? uncertain, must be set by another program

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L 1
aes_wk_ptr:       DS.L 1

xbios_tab:        DS.L 1                  ;alte NVDI-XBios-Vektoren
bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab

escape_ptr:       ds.l 1
hline_ptr:        ds.l 1
bitblt_ptr:       ds.l 1
fbox_ptr:         ds.l 1

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 16*16*2

hid_cnt:          ds.w 1
mycon_state:      ds.l 1

save_vt52_vec:    ds.l 1
vscr_struct:      ds.b 22       ; space for VSCR cookie

	ds.w 1
	ds.w 1
xbios_rez:        ds.w 1
expand_tab:       ds.l 512
expand_tabo:      ds.l 512

x1118a:           ds.w 1
x1118c:           ds.w 1

vgamode:          ds.b VGA_MODESIZE
vga_memend1:      ds.l 1
vga_memend2:      ds.l 1

linea_save:       ds.w 25

save_v_bas_ad:    ds.l 1
sysfont_addr:     ds.l 1
font_image:       ds.l 1

nvdivga_size:     ds.l 1
nvdivga_path:     ds.b 128

global_ctable:    ds.l 1
global_itable:    ds.l 1
