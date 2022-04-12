;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                 2-Color Matrix CX screen driver for NVDI                   *;
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

.INCLUDE "cxs.inc"


DRV_PLANES = 1
PATTERN_LENGTH    EQU (16*16)/8           ;minimale Fuellmusterlaenge

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
               ds.b 104

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
		bsr        save_screen_vecs
		movem.l    d0-d7/a0-a6,-(a7)
		DC.W 0xa000
		bsr        save_linea
		bsr        rundriver
		bsr        set_screen_vecs
		bsr        install_vscr_cookie
		moveq.l    #2,d0
		bsr        init_maps
		bsr        init_res
		bsr        init_vt52
		bsr        install_vecs
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
		bsr        reset_screen_vecs
		bsr        reset_vscr_cookie
		bsr        remove_vecs
		bsr        restore_linea
		bsr        check_redirect
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
		movem.l    d0-d2/a0-a2,-(a7)
		move.l     redirect_ptr(pc),d0
		beq.s      check_redirect1
		movea.l    d0,a0
		moveq.l    #0,d0
		jsr        (a0)
check_redirect1:
		movem.l    (a7)+,d0-d2/a0-a2
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
		move.w     xres(pc),(a0)+       ;adressierbare Rasterbreite
		move.w     yres(pc),(a0)+       ;adressierbare Rasterhoehe
		clr.w      (a0)+                ;genaue Skalierung moeglich !
		move.l     pixw(pc),(a0)+       ;Pixelbreite/Pixelhoehe
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
		move.w     colorbits(pc),d0
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

rundriver:
		movem.l    d0-d7/a0-a6,-(a7)
		bsr        run_cxx_info
; FIXME: no error check here
		move.w     #25,-(a7) ; Dgetdrv
		trap       #1
		addq.l     #2,a7
		add.w      #'A',d0
; construct command line for cxx_driv.ttp
		lea.l      cmdline+1(pc),a1
		lea.l      pathbuf(pc),a2
		move.b     d0,(a1)+
		move.b     d0,(a2)+
		move.b     #0,cmdline
		lea.l      cxs_path,a0
rundriver1:
		addq.b     #1,cmdline
		move.b     (a0)+,(a1)+
		bne.s      rundriver1
		lea.l      cxx_driv_name,a0
rundriver2:
		move.b     (a0)+,(a2)+
		bne.s      rundriver2
		moveq.l    #0,d0
		lea.l      pathbuf(pc),a0
		lea.l      cmdline(pc),a1
		suba.l     a2,a2
; execute cxx_driv.ttp
		bsr        pexec
; FIXME: no error check here
		move.w     #0x7D01,-(a7) ; unknown
		trap       #14
		addq.l     #2,a7
		move.l     d0,cxs_info2
		move.w     #0x7D00,-(a7) ; unknown
		trap       #14
		addq.l     #2,a7
		movea.l    d0,a0
		move.l     a0,cxs_info1
		move.w     cxs_xres(a0),d0
		move.w     d0,vscr_struct+14 ; set width
		subq.w     #1,d0
		move.w     d0,xres
		move.w     d0,visible_xres
		move.w     cxs_yres(a0),d0
		move.w     d0,vscr_struct+16 ; set height
		subq.w     #1,d0
		move.w     d0,yres
		move.w     d0,visible_yres
		tst.w      cxs_virtual(a0)
		beq.s      rundriver3
		move.w     cxs_visible_xres(a0),d0
		move.w     d0,vscr_struct+14 ; set width
		subq.w     #1,d0
		move.w     d0,visible_xres
		move.w     cxs_visible_yres(a0),d0
		move.w     d0,vscr_struct+16 ; set height
		subq.w     #1,d0
		move.w     d0,visible_yres
rundriver3:
		move.w     cxs_line_width(a0),line_width
		move.w     cxs_64(a0),x10b0a
		clr.w      x104c2
		tst.w      cxs_236(a0)
		bne.s      rundriver4
		move.w     #1,x104c2
rundriver4:
		move.l     cxs_rgbtab(a0),rgbtab
		move.w     cxs_234(a0),x104c6
		move.w     cxs_dac_type(a0),dac_type
		move.w     cxs_400(a0),x104c4
		move.l     cxs_278(a0),x104a0
		move.l     cxs_372(a0),x104a4
		move.l     cxs_376(a0),x104a8
		move.l     cxs_360(a0),x104ac
		move.l     cxs_388(a0),x104b0
		move.l     cxs_282(a0),d0
		addi.l     #32,d0
		move.l     d0,x104b4
		movea.l    x104ac(pc),a0
		move.l     x104a0(pc),d0
		move.w     12(a0),d1
		swap       d1
		move.w     10(a0),d1
		add.l      d1,d0
		move.l     d0,vga_membase
		move.w     #265,pixw
		move.w     #265,pixh
		move.w     #6,colorbits
		cmpi.w     #256,dac_type
		bne.s      rundriver5
		move.w     #8,colorbits
rundriver5:
		movem.l    (a7)+,d0-d7/a0-a6
		rts

run_cxx_info:
		movem.l    d1-d2/a0-a2,-(a7)
		move.w     #0x7D02,-(a7) ; CHECKInst; cxx_info.tos already installed?
		trap       #14
		addq.l     #2,a7
		cmp.l      #'CxOk',d0
		beq.s      run_cxx_info2
		move.w     #25,-(a7) ; Dgetdrv
		trap       #1
		addq.l     #2,a7
		add.w      #'A',d0
		lea.l      cxx_info_name(pc),a0
		lea.l      pathbuf(pc),a1
		move.b     d0,(a1)+
run_cxx_info1:
		move.b     (a0)+,(a1)+
		bne.s      run_cxx_info1
		clr.l      cmdline
		moveq.l    #0,d0
		lea.l      pathbuf(pc),a0
		lea.l      cmdline(pc),a1
		suba.l     a2,a2
		bsr.s      pexec
		tst.l      d0
		bmi.s      run_cxx_info3
		move.w     #0x7D02,-(a7)
		trap       #14
		addq.l     #2,a7
		cmp.l      #'CxOk',d0
		bne.s      run_cxx_info3
run_cxx_info2:
		moveq.l    #0,d0
		movem.l    (a7)+,d1-d2/a0-a2
		rts
run_cxx_info3:
		moveq.l    #-1,d0
		movem.l    (a7)+,d1-d2/a0-a2
		rts

pexec:
		movem.l    d1-d2/a0-a2,-(a7)
		move.l     a2,-(a7)
		move.l     a1,-(a7)
		move.l     a0,-(a7)
		move.w     d0,-(a7)
		move.w     #75,-(a7) ; Pexec
		trap       #1
		lea.l      16(a7),a7
		movem.l    (a7)+,d1-d2/a0-a2
		rts

cxs_info1: dc.l 0
cxs_info2: dc.l 0
rgbtab:    dc.l 0
x104a0:    dc.l 0
x104a4:    dc.l 0
x104a8:    dc.l 0
x104ac:    dc.l 0
x104b0:    dc.l 0
x104b4:    dc.l 0
           dc.l 0
           dc.l 0
dac_type:  dc.w 0
x104c2:    dc.w 0
x104c4:    dc.w 0
x104c6:    dc.w 0

		movem.l    d3-d7/a2-a6,-(a7)
		movem.l    (a7)+,d3-d7/a2-a6
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

init_res:
		movem.l    d0-d2/a0-a2,-(a7)
		movem.w    xres(pc),d0-d1
		move.w     line_width(pc),d2
		move.l     vga_membase(pc),v_bas_ad.w
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
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_sys_font_info(a0),a0
		movem.w    xres(pc),d0-d1
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     line_width(pc),d2
		move.w     d0,V_REZ_HZ.w
relok6:
		move.w     d1,V_REZ_VT.w
relok7:
		move.w     d1,V_REZ_VT.w
relok8:
		movea.l    _sf_font_hdr_ptr(a0),a1
		lea.l      sizeof_FONTHDR(a1),a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		lea.l      sizeof_FONTHDR(a1),a1
init_vt52_font:
		move.l     dat_table(a1),V_FNT_AD.w
relok9:
		move.l     off_table(a1),V_OFF_AD.w
relok10:
		move.w     #256,V_FNT_WD.w
relok11:
		move.l     #0x00FF0000,V_FNT_ND.w
relok12:
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT.w
relok13:
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		movem.w    d0-d2,V_CEL_MX.w /* V_CEL_MX/V_CEL_MY/V_CEL_WR */
relok14:
		move.l     #255,V_COL_BG.w
relok15:
		move.w     #1,V_HID_CNT.w
relok16:
		move.w     #256,V_STAT_0.w
relok17:
		move.w     #0x1E1E,V_PERIOD.w
relok18:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok19:
		clr.l      V_CUR_XY.w
relok20:
		clr.w      V_CUR_OF.w
relok21:
		movem.l    (a7)+,d0-d4/a0-a2
		rts

install_vecs:
		movem.l    d0/a0-a2,-(a7)
		movea.l    cxs_info1(pc),a2
		cmpi.w     #0x01CB,cxs_400(a2)
		bne.s      install_vecs3
		cmpi.w     #4,cxs_428(a2)
		bne.s      install_vecs3
		moveq.l    #28,d0 ; VBL
		lea.l      vblnointr(pc),a0
		lea.l      oldvbl(pc),a1
		bsr        setvec
		move.w     cxs_462(a2),d0
		bmi.s      install_vecs2
		bne.s      install_vecs1
		moveq.l    #29,d0 ; VME
install_vecs1:
		lea.l      vmeintr(pc),a0
		lea.l      oldvme(pc),a1
		bsr        setvec
		movea.l    cxs_282(a2),a1
		move.b     d0,161(a1)
		ori.b      #0x10,vme_mask.w
		movea.l    cxs_364(a2),a0
		andi.w     #0xFF7F,2(a0)
		suba.l     cxs_278(a2),a0
		move.l     a0,d0
		swap       d0
		move.l     d0,66(a1)
		move.w     #0x0500,64(a1)
install_vecs2:
		movem.l    (a7)+,d0/a0-a2
		rts
install_vecs3:
		moveq.l    #28,d0 ; VBL
		lea.l      vblintr(pc),a0
		lea.l      oldvbl(pc),a1
		bsr        setvec
		movem.l    (a7)+,d0/a0-a2
		rts

vmeintr:
		move.l     a0,-(a7)
		movea.l    cxs_info1(pc),a0
		movea.l    cxs_282(a0),a0
		tst.w      4(a0)
		tst.w      72(a0)
		movea.l    xres(pc),a0
		cmpa.l     visible_xres(pc),a0
		beq.s      vmeintr1
		movem.l    d0-d7/a1-a2,-(a7)
		bsr        panscreen
		movem.l    (a7)+,d0-d7/a1-a2
vmeintr1:
		movea.l    (a7),a0
		move.l     oldvbl(pc),(a7)
		rts

vblintr:
		move.l     a0,-(a7)
		movea.l    xres(pc),a0
		cmpa.l     visible_xres(pc),a0
		beq.s      vblintr1
		movem.l    d0-d7/a1-a2,-(a7)
		bsr        panscreen
		movem.l    (a7)+,d0-d7/a1-a2
vblintr1:
		movea.l    (a7),a0
		move.l     oldvbl(pc),(a7)
		rts

vblnointr:
		rte

remove_vecs:
		movem.l    d0/a0-a2,-(a7)
		movea.l    cxs_info1(pc),a2
		cmpi.w     #0x01CB,cxs_400(a2)
		bne.s      remove_vecs3
		cmpi.w     #4,cxs_428(a2)
		bne.s      remove_vecs3
		moveq.l    #28,d0 ; VBL
		movea.l    oldvbl(pc),a0
		movea.w    #-1,a1
		bsr        setvec
		move.w     cxs_462(a2),d0
		bmi.s      remove_vecs2
		bne.s      remove_vecs1
		moveq.l    #29,d0 ; VME
remove_vecs1:
		movea.l    oldvme(pc),a0
		movea.w    #-1,a1
		bsr        setvec
		movea.l    cxs_282(a2),a1
		move.b     d0,161(a1)
		andi.b     #0xEF,vme_mask.w
		movea.l    cxs_364(a2),a0
		ori.w      #0x0080,2(a0)
		suba.l     cxs_278(a2),a0
		move.l     a0,d0
		swap       d0
		move.l     d0,66(a1)
		move.w     #0x0500,64(a1)
remove_vecs2:
		movem.l    (a7)+,d0/a0-a2
		rts
remove_vecs3:
		moveq.l    #28,d0 ; VBL
		movea.l    oldvbl(pc),a0
		movea.w    #-1,a1
		bsr        setvec
		movem.l    (a7)+,d0/a0-a2
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

install_vscr_cookie:
		movem.l    d0-d2/a0-a1,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_init_cookie(a0),a0
		move.l     #'VSCR',d0
		move.l     #vscr_struct,d1
		jsr        (a0)
		movem.l    (a7)+,d0-d2/a0-a1
		rts

search_rdct_cookie:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		move.l     #'RDCT',d0
		movea.l    _nvdi_search_cookie(a0),a0
		jsr        (a0)
		move.l     d1,redirect_ptr
		movem.l    (a7)+,d0-d2/a0-a2
		rts

search_cookie:
		movem.l    d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_search_cookie(a0),a0
		jsr        (a0)
		movem.l    (a7)+,d2/a0-a2
		rts

reset_vscr_cookie:
		movem.l    d0-d2/a0-a2,-(a7)
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_reset_cookie(a0),a0
		move.l     #'VSCR',d0
		jsr        (a0)
		movem.l    (a7)+,d0-d2/a0-a2
		rts

panscreen:
		movem.w    GCURX.w,d0-d1
relok22:
		movem.w    vscr_struct+10(pc),d4-d5 ; get x/y
		movem.w    visible_xres(pc),d6-d7
		add.w      d4,d6
		add.w      d5,d7
		sub.w      #32,d0
		sub.w      #32,d1
		cmp.w      d4,d0
		bge.s      panscreen1
		move.w     d0,d4
		and.w      #-32,d4
		bpl.s      panscreen1
		moveq.l    #0,d4
panscreen1:
		cmp.w      d5,d1
		bge.s      panscreen2
		move.w     d1,d5
		bpl.s      panscreen2
		moveq.l    #0,d5
panscreen2:
		add.w      #64,d0
		add.w      #64,d1
		cmp.w      d7,d1
		ble.s      panscreen4
		cmp.w      yres(pc),d1
		ble.s      panscreen3
		move.w     yres(pc),d1
panscreen3:
		sub.w      d7,d1
		add.w      d1,d5
panscreen4:
		cmp.w      d6,d0
		ble.s      panscreen6
		cmp.w      xres(pc),d0
		ble.s      panscreen5
		move.w     xres(pc),d0
panscreen5:
		sub.w      d6,d0
		add.w      d0,d4
		add.w      #31,d4
		and.w      #-32,d4
panscreen6:
		movem.w    d4-d5,vscr_struct+10
		movea.l    cxs_info1(pc),a0
		movea.l    cxs_282(a0),a1
		btst       #0,65(a1)
		beq.s      panscreen7
		ext.l      d4
		lsr.w      #3,d4
		mulu.w     line_width(pc),d5
		add.l      d5,d4
		add.l      cxs_274(a0),d4
		sub.l      cxs_278(a0),d4
		swap       d4
		movea.l    cxs_360(a0),a1
		cmp.l      screen_offset(pc),d4
		beq.s      panscreen7
		move.l     d4,screen_offset
		move.l     d4,10(a1)
panscreen7:
		rts

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #64,d0
		beq.s      gooldxbios
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
		move.l     vga_membase(pc),d0
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
		move.l     xres(pc),res_x(a6)
		move.l     pixw(pc),pixel_width(a6)
		move.w     #DRV_PLANES-1,r_planes(a6)
		move.w     #1,colors(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation(pc),a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.l     global_ctable(pc),wk_ctab(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     #set_color_rgb,p_set_color_rgb(a6)
		moveq.l    #1,d0
		rts

wk_reset:
		rts

set_color_rgb:
		movem.l    d3-d5/a2-a3,-(a7)
		move.l     d0,d3
		move.l     d1,d4
		moveq.l    #16,d5
		sub.w      colorbits,d5
		movea.l    rgbtab(pc),a1
		move.b     d3,(a1)
		lea.l      2(a1),a2
		movea.l    cxs_info1(pc),a3
		cmpi.w     #0x01CB,cxs_400(a3)
		bne.s      set_color_rgb1
		addq.l     #4,a2
set_color_rgb1:
		move.l     (a0)+,d0
		move.w     (a0)+,d1
		move.w     (a0)+,d2
		move.b     d3,(a1)
		cmpi.w     #0x01CB,cxs_400(a3)
		bne.s      set_color_rgb2
		move.b     #0,-4(a2)
set_color_rgb2:
		lsr.w      d5,d0
		lsr.w      d5,d1
		lsr.w      d5,d2
		move.b     d0,(a2)
		move.b     d1,(a2)
		move.b     d2,(a2)
		addq.l     #1,d3
		cmp.l      d3,d4
		bge.s      set_color_rgb1
		movem.l    (a7)+,d3-d5/a2-a3
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

	.data

cxx_driv_name:
		dc.b ':\MATRIX\CXX_DRIV.TTP',0
cxx_info_name:
		dc.b ':\MATRIX\CXX_INFO.TOS',0
cxs_path:
		dc.b ':\MATRIX\CXX\*.CXS',0
		.even

dev_name:
		dc.b 'Matric CXX 2 Farben',0
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
                  DC.W 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS

redirect_ptr:     ds.l 1

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L 1
xbios_rez:        ds.w 1
xbios_tab:        ds.l 1

vscr_struct:      ds.b 22       ; space for VSCR cookie

linea_save:       ds.w 25
save_v_bas_ad:    ds.l 1
xres:             ds.w 1
yres:             ds.w 1
visible_xres:     ds.w 1
visible_yres:     ds.w 1
pixw:             ds.w 1
pixh:             ds.w 1
x10b0a:           ds.w 1
                  ds.l 1
line_width:       ds.w 1
vga_membase:      ds.l 1
colorbits:        ds.w 1
oldvbl:           ds.l 1
oldvme:           ds.l 1
screen_offset:    ds.l 1
cmdline:          ds.b 128
pathbuf:          ds.b 128

global_ctable:    ds.l 1
global_itable:    ds.l 1
