;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                 16-Color Matrix CX screen driver for NVDI                  *;
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


DRV_PLANES = 4
PATTERN_LENGTH    EQU ((16*16)/2)*2           ;minimale Fuellmusterlaenge

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
organisation:     DC.L  16                ;Farben
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
		move.l     _nvdi_aes_wk(a0),aes_wk_ptr
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_load_NOD_driver(a0),a2
		lea.l      organisation,a0
		jsr        (a2)
		movea.l    driver_struct(pc),a1
		move.l     a0,driver_offscreen(a1)
		beq.s      init_err
		bsr        save_screen_vecs
		movem.l    d0-d7/a0-a6,-(a7)
		bsr        save_linea
		bsr        install_vscr_cookie
		bsr        search_rdct_cookie
		bsr        check_redirect
		bsr        rundriver
		bsr        set_screen_vecs
		bsr        build_exp
		moveq.l    #16,d0
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
		movem.l    d0-d2/a0-a2,-(a7)
		move.l     redirect_ptr(pc),d0
		beq.s      check_redirect1
		movea.l    d0,a0
		moveq.l    #0,d0
		jsr        (a0)
check_redirect1:
		movem.l    (a7)+,d0-d2/a0-a2
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
		move.w     #16,26-90(a0)        ;work_out[13]: Anzahl der Farben
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
		move.l     #16,(a0)+   ;[3/4] Farbanzahl
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
		moveq.l    #15,d0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_colmaptab(a1),a1
		movea.l    (a1),a1
get_scrninfo1:
		moveq.l    #15,d1
		and.b      (a1)+,d1
		move.w     d1,(a0)+
		dbf        d0,get_scrninfo1
		move.w     #240-1,d0
get_scrninfo2:
		move.w     #15,(a0)+
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
		add.w      #'A',d0 ; FIXME: drive_to_letter
; construct command line for cxx_driv.ttp
		lea.l      cmdline+1(pc),a1
		lea.l      pathbuf(pc),a2
		move.b     d0,(a1)+
		move.b     d0,(a2)+
		move.b     #0,cmdline
		lea.l      cxs_path(pc),a0
rundriver1:
		addq.b     #1,cmdline
		move.b     (a0)+,(a1)+
		bne.s      rundriver1
		lea.l      cxx_driv_name(pc),a0
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
		move.l     x104b0(pc),fontbuf_ptr
		bne.s      rundriver5
		move.l     #fontbuf,fontbuf_ptr
rundriver5:
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
		bne.s      rundriver6
		move.w     #8,colorbits
rundriver6:
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
		add.w      #'A',d0 ; FIXME: drive_to_letter
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
fontbuf_ptr:    dc.l 0
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

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #86,d0
		beq        esetgray
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
		lsl.w      #2,d0
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
		movem.l    d0-d1/a1/a4-a5,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
relok19:
		add.w      d0,d0
		move.w     d0,d1
		add.w      d0,d0
		add.w      d1,d0 /* (16 - Zeichenhoehe) * 6; BUG: must be * 4 */
		movea.l    V_CUR_AD.w,a1
relok20:
		move.w     BYTES_LIN.w,d1
relok21:
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
		movem.l    (a7)+,d0-d1/a1/a4-a5
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
		lsl.w      #2,d0
		suba.w     d0,a1
		move.l     a1,V_CUR_AD.w
relok28:
		clr.w      V_CUR_XY0.w
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
		cmpi.w     #32,d1               ;Steuerzeichen ?
		blt.s      vt_control

vt_rawcon:
		movea.l    font_image(pc),a0
		movea.l    V_CUR_AD.w,a1
relok31:
		move.w     BYTES_LIN.w,d2
relok32:
		move.b     #2,V_CUR_CT.w        ;Zaehler auf 2 -> keinen Cursor zeichnen
relok33:
		bclr       #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
relok34:
		move.l     V_FNT_AD.w,d0        ;Fontimageadresse
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
vt_char_bloop:
		moveq.l    #0,d0
		move.b     (a0)+,d0
		add.w      d0,d0
		add.w      d0,d0
		move.l     0(a2,d0.w),(a1)
		adda.w     d2,a1
		dbf        d1,vt_char_bloop
vt_n_column:
		move.w     V_CUR_XY0.w,d0
relok39:
		cmp.w      V_CEL_MX.w,d0
relok40:
		bge.s      vt_l_column
		addq.l     #4,V_CUR_AD.w
relok41:
		addq.w     #1,V_CUR_XY0.w
relok42:
		moveq.l    #-1,d0
		rts
vt_l_column:
		btst       #CURSOR_WRAP,V_STAT_0.w
relok43:
		beq.s      vt_con_exit
		addq.w     #1,hid_cnt
		ext.l      d0
		lsl.l      #2,d0
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

vt_char_rcol:
		movem.l    d3-d7,-(a7)
		lea.l      nibble2tab,a2
		move.w     V_COL_FG.w,d6
relok51:
		move.w     V_COL_BG.w,d5
relok52:
		add.w      d5,d5
		add.w      d5,d5
		add.w      d6,d6
		add.w      d6,d6
		move.l     0(a2,d5.w),d5
		move.l     0(a2,d6.w),d6
		bra.s      vt_char_col1

vt_char_col:
		movem.l    d3-d7,-(a7)
		lea.l      nibble2tab,a2
		move.w     V_COL_FG.w,d5
relok53:
		move.w     V_COL_BG.w,d6
relok54:
		add.w      d5,d5
		add.w      d5,d5
		add.w      d6,d6
		add.w      d6,d6
		move.l     0(a2,d5.w),d5
		move.l     0(a2,d6.w),d6
vt_char_col1:
		movea.l    d0,a0
		adda.w     d1,a0
		move.w     V_FNT_WD.w,d0
relok55:
		move.w     V_CEL_HT.w,d1
relok56:
		subq.w     #1,d1
		lea.l      expand_tab(pc),a2
vt_char_cloop:
		moveq.l    #0,d7
		move.b     (a0),d7
		add.w      d7,d7
		add.w      d7,d7
		move.l     0(a2,d7.w),d3
		move.l     d3,d4
		not.l      d4
		and.l      d5,d3
		and.l      d6,d4
		or.l       d4,d3
		move.l     d3,(a1)
		adda.w     d0,a0
		adda.w     d2,a1
		dbf        d1,vt_char_cloop
		movem.l    (a7)+,d3-d7
		bra        vt_n_column

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq:
		cmpi.w     #'Y',d1
		beq        vt_seq_Y
		move.w     d1,d2
		movem.w    V_CUR_XY.w,d0-d1
relok57:
		movea.l    V_CUR_AD.w,a1
relok58:
		movea.w    BYTES_LIN.w,a2
relok59:
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
		clr.l      V_CUR_XY.w
relok60:
		movea.l    v_bas_ad.w,a1
		move.l     a1,V_CUR_AD.w
relok61:
		bra        cursor_on

;Cursor up and insert (VT52 ESC I)
vt_seq_I:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		subq.w     #1,d1
		blt        scroll_down_page
		suba.w     V_CEL_WR.w,a1 /* FIXME: V_CEL_WR is obsolete */
relok62:
		move.l     a1,V_CUR_AD.w
relok63:
		move.w     d1,V_CUR_XY1.w
relok64:
		rts

; ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
v_eeos:
vt_seq_J:
		bsr.s      vt_seq_K
		move.w     V_CUR_XY1.w,d1
relok65:
		move.w     V_CEL_MY.w,d2
relok66:
		sub.w      d1,d2
		beq.s      vt_seq_J_exit
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a1
		addq.w     #1,d1
		mulu.w     V_CEL_WR.w,d1 /* FIXME: V_CEL_WR is obsolete */
relok67:
		lsr.l      #2,d1 ; BUG
		adda.l     d1,a1
		move.w     d2,d7
		mulu.w     V_CEL_HT.w,d7
relok68:
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
relok69:
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
relok70:
		sub.w      d1,d5
		beq.s      vt_seq_L_exit
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok71:
		movea.w    a2,a3
		move.w     V_CEL_HT.w,d0
relok72:
		mulu.w     d0,d1
		move.w     d1,d3
		add.w      d0,d3
		move.w     V_CEL_MX.w,d4
relok73:
		lsl.w      #3,d4
		addq.w     #7,d4
		mulu.w     d0,d5
		subq.w     #1,d5
		moveq.l    #3,d7
		moveq.l    #0,d0
		moveq.l    #0,d2
		movea.l    aes_wk_ptr(pc),a6
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		move.w     V_CUR_XY1.w,d0
relok74:
		mulu.w     V_CEL_WR.w,d0 /* FIXME: V_CEL_WR is obsolete */
relok75:
		adda.l     d0,a1
		bra        clear_line2
vt_seq_L_exit:
		movea.l    V_CUR_AD.w,a1
relok76:
		bra        clear_line2

;Delete Line (VT52 ESC M)
vt_seq_M:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
relok77:
		sub.w      d1,d7
		beq.s      vt_seq_M_last
		move.w     V_CEL_HT.w,d3
relok78:
		moveq.l    #0,d0
		mulu.w     d3,d1
		moveq.l    #0,d2
		add.w      d1,d3
		exg        d1,d3
		movem.w    V_CEL_MX.w,d4-d5
relok79:
		addq.w     #1,d4
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
relok80:
		subq.w     #1,d5
		sub.w      d1,d5
		bra        scroll_up2
vt_seq_M_last:
		bra        clear_line2

;Set cursor position (VT52 ESC Y)
vt_seq_Y:
		move.l     #vt_set_y,mycon_state
		rts
;y-Koordinate setzen
vt_set_y:
		subi.w     #32,d1
		move.w     V_CUR_XY0.w,d0
relok81:
		move.l     #vt_set_x,mycon_state
		bra        set_cursor_xy
;x-Koordinate setzen
vt_set_x:
		subi.w     #32,d1
		move.w     d1,d0
		move.w     V_CUR_XY1.w,d1
relok82:
		move.l     #vt_con0,mycon_state
		bra        set_cursor_xy

;Foreground color (VT52 ESC b)
vt_seq_b:
		move.l     #vt_set_b,mycon_state
		rts
vt_set_b:
		lea.l      V_COL_FG.w,a1
relok83:
vt_set_col:
		and.w      #15,d1
		move.w     d1,(a1)
		move.l     #vt_con0,mycon_state
		rts

;Background color (VT52 ESC c)
vt_seq_c:
		move.l     #vt_set_c,mycon_state
		rts
vt_set_c:
		lea.l      V_COL_BG.w,a1
relok84:
		bra.s      vt_set_col

;Erase to start of page (VT52 ESC d)
vt_seq_d:
		bsr.s      vt_seq_o
		move.w     V_CUR_XY1.w,d1
relok85:
		beq.s      vt_seq_d_exit
		movem.l    d2-d7/a1-a6,-(a7)
		mulu.w     V_CEL_HT.w,d1
relok86:
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
relok87:
		move.l     V_CUR_XY.w,V_SAV_XY.w
relok88:
		rts

;Restore cursor (VT52 ESC k)
vt_seq_k:
		movem.w    V_SAV_XY.w,d0-d1
relok89:
		bclr       #CURSOR_SAVED,V_STAT_0.w
relok90:
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
relok91:
		adda.l     d1,a1
		bra        clear_line_part
vt_seq_o_exit:
		rts

;REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
v_rvon:
vt_seq_p:
		bset       #CURSOR_INVERSE,V_STAT_0.w
relok92:
		rts

; REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
v_rvoff:
vt_seq_q:
		bclr       #CURSOR_INVERSE,V_STAT_0.w
relok93:
		rts

;Wrap at end of line (VT52 ESC v)
vt_seq_v:
		bset       #CURSOR_WRAP,V_STAT_0.w
relok94:
		rts

;Discard end of line (VT52 ESC w)
vt_seq_w:
		bclr       #CURSOR_WRAP,V_STAT_0.w
relok95:
		rts

scroll_up_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		move.w     V_CEL_HT.w,d1
relok96:
		moveq.l    #0,d2
		moveq.l    #0,d3
		movem.w    V_CEL_MX.w,d4-d5
relok97:
		addq.w     #1,d4
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
relok98:
		subq.w     #1,d5
scroll_up2:
		moveq.l    #3,d7
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok99:
		movea.w    a2,a3
		movea.l    aes_wk_ptr(pc),a6
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		move.w     V_CEL_MY.w,d0
relok100:
		mulu.w     V_CEL_WR.w,d0 /* FIXME: V_CEL_WR is obsolete */
relok101:
		adda.l     d0,a1
		bra.s      clear_line2

scroll_down_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		moveq.l    #0,d1
		moveq.l    #0,d2
		move.w     V_CEL_HT.w,d3
relok102:
		movem.w    V_CEL_MX.w,d4-d5
relok103:
		addq.w     #1,d4
		addq.w     #1,d5
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     d3,d5
		subq.w     #1,d5
		moveq.l    #3,d7
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
relok104:
		movea.w    a2,a3
		movea.l    aes_wk_ptr(pc),a6
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		bra.s      clear_line2

clear_line:
		movem.l    d2-d7/a1-a6,-(a7)
;Eingabe
;a1.l Zeilenadresse
clear_line2:
		move.w     V_CEL_HT.w,d7
relok105:
		subq.w     #1,d7
;d7.w Zeilenzaehler
clear_lines:
		lea.l      nibble2tab,a2
		move.w     V_COL_BG.w,d6
relok106:
		add.w      d6,d6
		add.w      d6,d6
		move.l     0(a2,d6.w),d6
		move.w     V_CEL_MX.w,d4
relok107:
		move.w     BYTES_LIN.w,d5
relok108:
		move.w     d4,d2
		addq.w     #1,d2
		add.w      d2,d2
		add.w      d2,d2
		sub.w      d2,d5
clear_line_bloop:
		move.w     d4,d2
clear_line_loop:
		move.l     d6,(a1)+
		dbf        d2,clear_line_loop
		adda.w     d5,a1
		dbf        d7,clear_line_bloop
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
relok109:
		addq.w     #1,d7
		mulu.w     V_CEL_HT.w,d7
relok110:
		subq.w     #1,d7
		movea.l    v_bas_ad.w,a1
		bra.s      clear_lines

;Bereich einer Textzeile loeschen
;Eingaben
;d2.w Spaltenanzahl -1
;a1.l Adresse
;a2.w Bytes pro Zeile
;Ausgaben
;d0-d2/a0-a1 werden zerstoert
clear_line_part:
		move.l     d3,-(a7)
		lea.l      nibble2tab,a3
		move.w     V_COL_BG.w,d3
relok111:
		add.w      d3,d3
		add.w      d3,d3
		move.l     0(a3,d3.w),d3
		move.w     V_CEL_HT.w,d1
relok112:
		subq.w     #1,d1
		move.w     d2,d0
		addq.w     #1,d0
		add.w      d0,d0
		add.w      d0,d0
		movea.w    BYTES_LIN.w,a0
relok113:
		suba.w     d0,a0
clear_lpart_bloop:
		move.w     d2,d0
clear_lpart_loop:
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
		subq.w     #1,d2        ; line counter - 1 for dbra
		bmi.s      undraw_exit
		movea.l    (a2)+,a1
		bclr       #0,(a2)      ; save block valid?
		beq.s      undraw_exit
		movea.w    BYTES_LIN.w,a3
relok114:
		lea.l      -12(a3),a3   ; offset to next line
		addq.l     #2,a2
undraw_spr_loop:
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		move.l     (a2)+,(a1)+
		adda.w     a3,a1
		dbf        d2,undraw_spr_loop
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
		move.b     7(a0),d6   ; background color
		move.b     9(a0),d7   ; foreground color
		and.w      #15,d6
		and.w      #15,d7
		sub.w      (a0)+,d0      ; X_Koord - intxhot
		bpl.s      draw_spr_x2
		add.w      d0,d2         ; width to draw - 1
		bmi        draw_spr_exit
draw_spr_x2:
		move.w     DEV_TAB0.w,d4 ; WORK_OUT[0] max. raster width
relok115:
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
relok116:
		subi.w     #15,d5
		sub.w      d1,d5
		bge.s      draw_spr_save
		add.w      d5,d3         ; height to draw - 1
		bmi        draw_spr_exit
draw_spr_save:
		move.w     d3,(a2)
		addq.w     #1,(a2)+      ; saved number of lines
		muls.w     BYTES_LIN.w,d1
relok117:
		movea.l    v_bas_ad.w,a1
		adda.l     d1,a1         ; line address
		moveq.l    #0,d4
		tst.w      d0            ; beyond left margin?
		bmi.s      draw_spr_saddr
		moveq.l    #-19,d4
		add.w      DEV_TAB0.w,d4
relok118:
		cmp.w      d0,d4
		blt.s      draw_spr_saddr
		moveq.l    #-4,d4
		and.w      d0,d4
draw_spr_saddr:
		movea.l    a1,a4
		lsr.w      #1,d4
		adda.w     d4,a4
		move.l     a4,(a2)+      ; address of saved background
		move.w     #256,(a2)+    ; mark as valid
		movea.w    BYTES_LIN.w,a3
relok119:
		lea.l      -12(a3),a3    ; offset to next line
		move.w     d3,d5
draw_spr_sloop:
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		move.l     (a4)+,(a2)+
		adda.w     a3,a4
		dbf        d5,draw_spr_sloop
		movea.w    BYTES_LIN.w,a3
relok120:
		moveq.l    #1,d1
		and.w      d0,d1
		beq.s      draw_spr1
		moveq.l    #-16,d1
		bra.s      draw_spr2
draw_spr1:
		moveq.l    #15,d1
		lsl.w      #4,d6
		lsl.w      #4,d7
draw_spr2:
		asr.w      #1,d0
		adda.w     d0,a1
		cmp.w      #15,d2        ; mouse pointer at screen margins?
		beq.s      draw_it
		tst.w      d0
		bpl.s      draw_it       ; at left margin?
		suba.w     d0,a1
		neg.w      d0
		bra.s      draw_spr_bloop
draw_it:
		moveq.l    #0,d0
draw_spr_bloop:
		move.w     (a0)+,d4
		move.w     (a0)+,d5
		lsl.w      d0,d4
		lsl.w      d0,d5
		move.l     a1,-(a7)
		movem.w    d1-d2/d6-d7,-(a7)
draw_spr_loop:
		add.w      d5,d5
		bcc.s      draw_spr_bg
		and.b      d1,(a1)
		or.b       d7,(a1)
		add.w      d4,d4
		bra.s      draw_spr_nth
draw_spr_bg:
		add.w      d4,d4
		bcc.s      draw_spr_nth
		and.b      d1,(a1)
		or.b       d6,(a1)
draw_spr_nth:
		ror.b      #4,d1
		ror.b      #4,d6
		ror.b      #4,d7
		cmp.b      #15,d1
		bne.s      draw_spr_skip
		addq.l     #1,a1
draw_spr_skip:
		dbf        d2,draw_spr_loop
		movem.w    (a7)+,d1-d2/d6-d7
		movea.l    (a7)+,a1
		adda.w     a3,a1
		dbf        d3,draw_spr_bloop
draw_spr_exit:
		rts

panscreen:
		movem.w    GCURX.w,d0-d1
relok121:
		movem.w    vscr_struct+10(pc),d4-d5 ; get x/y
		movem.w    visible_xres(pc),d6-d7
		add.w      d4,d6
		add.w      d5,d7
		sub.w      #32,d0
		sub.w      #32,d1
		cmp.w      d4,d0
		bge.s      panscreen1
		move.w     d0,d4
		and.w      #-4,d4
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
		addq.w     #3,d4
		and.w      #-4,d4
panscreen6:
		movem.w    d4-d5,vscr_struct+10
		movea.l    cxs_info1(pc),a0
		movea.l    cxs_282(a0),a1
		btst       #0,65(a1)
		beq.s      panscreen8
		move.w     d4,d0
		and.l      #0x0000FFF8,d0
		lsr.w      #1,d0
		mulu.w     line_width(pc),d5
		add.l      d5,d0
		add.l      cxs_274(a0),d0
		sub.l      cxs_278(a0),d0
		swap       d0
		movea.l    cxs_360(a0),a1
		cmp.l      screen_offset(pc),d0
		bne.s      panscreen7
		cmpi.w     #0x01CB,cxs_400(a0)
		bne.s      panscreen8
		and.w      #7,d4
		lsl.w      #5,d4
		movea.l    cxs_rgbtab(a0),a2
		move.b     #2,(a2)
		move.b     #2,2(a2)
		move.b     d4,4(a2)
		rts
panscreen7:
		move.l     d0,screen_offset
		move.l     d0,10(a1)
panscreen8:
		rts

init_res:
		movem.l    d0-d2/a0-a2,-(a7)
		movem.w    xres(pc),d0-d1
		move.w     line_width(pc),d2
		move.l     vga_membase(pc),v_bas_ad.w
		move.w     #DRV_PLANES,PLANES.w
relok122:
		move.w     d2,WIDTH.w
relok123:
		move.w     d2,BYTES_LIN.w
relok124:
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
		move.l     _sf_bold_image(a0),bold_image
		movem.w    xres(pc),d0-d1
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     line_width(pc),d2
		move.w     d0,V_REZ_HZ.w
relok125:
		move.w     d1,V_REZ_VT.w
relok126:
		move.w     d1,V_REZ_VT.w
relok127:
		movea.l    _sf_font_hdr_ptr(a0),a1
		lea.l      sizeof_FONTHDR(a1),a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		lea.l      sizeof_FONTHDR(a1),a1
init_vt52_font:
		move.l     dat_table(a1),V_FNT_AD.w
relok128:
		move.l     off_table(a1),V_OFF_AD.w
relok129:
		move.w     #256,V_FNT_WD.w
relok130:
		move.l     #0x00FF0000,V_FNT_ND.w
relok131:
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT.w
relok132:
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		movem.w    d0-d2,V_CEL_MX.w /* V_CEL_MX/V_CEL_MY/V_CEL_WR */
relok133:
		move.l     #15,V_COL_BG.w
relok134:
		move.w     #1,V_HID_CNT.w
relok135:
		move.w     #1,hid_cnt
		move.w     #256,V_STAT_0.w
relok136:
		move.w     #0x1E1E,V_PERIOD.w
relok137:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok138:
		clr.l      V_CUR_XY.w
relok139:
		clr.w      V_CUR_OF.w
relok140:
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
		moveq.l    #3,d2
build_exp_loop:
		clr.b      (a0)
		add.b      d1,d1
		bcc.s      build_exp1
		eori.b     #0xF0,(a0)
build_exp1:
		add.b      d1,d1
		bcc.s      build_exp2
		eori.b     #0x0F,(a0)
build_exp2:
		addq.l     #1,a0
		dbf        d2,build_exp_loop
		addq.w     #1,d0
		cmp.w      #256,d0
		blt.s      build_exp_bloop
		movem.l    (a7)+,d0-d2/a0-a1
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
		move.w     #15,colors(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation(pc),a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.l     global_ctable(pc),wk_ctab(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     p_fbox(a6),fbox_ptr
		move.l     p_hline(a6),hline_ptr
		move.l     p_vline(a6),vline_ptr
		move.l     p_line(a6),line_ptr
		move.l     p_bitblt(a6),bitblt_ptr
		move.l     p_textblt(a6),textblt_ptr
		move.l     p_escapes(a6),escape_ptr
		move.l     p_gtext(a6),gtext_ptr
		move.l     #fbox,p_fbox(a6)
		move.l     #hline,p_hline(a6)
		move.l     #vline,p_vline(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #v_escape,p_escapes(a6)
		move.l     #gtext,p_gtext(a6)
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
		tst.w      graymode
		beq.s      set_color_rgb3
		add.w      d1,d0
		add.w      d0,d1
		lsl.w      #2,d1
		add.w      d1,d0
		add.w      d2,d2
		add.w      d2,d0
		lsr.w      #4,d0
		move.w     d0,d1
		move.w     d0,d2
set_color_rgb3:
		move.b     d0,(a2)
		move.b     d1,(a2)
		move.b     d2,(a2)
		addq.l     #1,d3
		cmp.l      d3,d4
		bge.s      set_color_rgb1
		movem.l    (a7)+,d3-d5/a2-a3
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
		movem.w    V_CUR_XY.w,d0-d1
relok141:
		movea.l    V_CUR_AD.w,a1
relok142:
		movea.w    BYTES_LIN.w,a2
relok143:
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
relok144:
		addi.l     #0x00010001,d3
		swap       d3
		move.l     d3,(a4)
		move.w     #2,v_nintout(a0)
		rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:
		addq.w     #1,hid_cnt
		bclr       #CURSOR_STATE,V_STAT_0.w
relok145:
		bra        clear_screen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:
		clr.l      V_CUR_XY.w
relok146:
		move.l     v_bas_ad.w,V_CUR_AD.w
relok147:
		move.l     #vt_con0,mycon_state
		bsr        clear_screen
		bclr       #CURSOR_STATE,V_STAT_0.w
relok148:
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
hline_accel:
		move.l     a0,-(a7)
		movea.l    x104b4(pc),a0
		movea.l    x104a4(pc),a1
		tst.w      d5
		sne        d5
		and.w      #15,d5
		sub.w      d0,d2
		moveq.l    #0,d4
		move.w     d4,4(a0)
		move.w     a1,2(a0)
		move.w     #0x4F00,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     #0x4100,(a1)+
		move.w     #-1,(a1)+
		move.w     d5,(a1)+
		move.w     #0x6400,(a1)+
		move.l     d4,(a1)+
		move.w     d2,(a1)+
		move.w     d4,(a1)+
		move.w     #0x0301,(a1)+
		move.w     #0x0200,(a0)
		addq.l     #1,a0
hline_accel1:
		btst       d4,(a0)
		beq.s      hline_accel1
		movea.l    (a7)+,a0
		rts

hline:
		movea.l    v_bas_ad.w,a1
		move.w     wr_mode(a6),d6
		bne.s      hline_exit
		move.w     d2,d4
		sub.w      d0,d4
		cmp.w      #50,d4
		blt.s      hline_exit
		tst.w      bitmap_addr(a6) ; BUG: must be long
		bne.s      hline_exit
		cmpa.l     vga_membase(pc),a1
		bne.s      hline_exit
		cmp.w      #-1,d7
		bne.s      hline_exit
		move.l     r_fg_pixel(a6),d5
		beq.s      hline_accel
		cmpi.w     #1,d5
		beq.s      hline_accel
hline_exit:
		movea.l    hline_ptr(pc),a1
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
		cmp.w      #150,d2
		blt.s      vline_exit
		tst.w      bitmap_width(a6)
		bne.s      vline_exit
		movea.l    v_bas_ad.w,a1
		cmpa.l     vga_membase(pc),a1
		beq.s      vline_accel
vline_exit:
		movea.l    vline_ptr(pc),a1
		jmp        (a1)
vline_accel:
		move.l     a0,-(a7)
		move.w     wr_mode(a6),d6
		movea.l    x104a4(pc),a1
		move.w     #0x4F00,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     #0x3D00,(a1)+
		lea.l      nibbletab(pc),a0
		move.l     r_fg_pixel(a6),d0
		add.w      d0,d0
		move.w     0(a0,d0.w),(a1)+
		move.l     r_bg_pixel(a6),d0
		add.w      d0,d0
		move.w     0(a0,d0.w),(a1)+
		subq.w     #2,d6
		bmi.s      vline_a2
		bne.s      vline_a1
		move.l     #0xFFFF0000,-4(a1)
		bra.s      vline_a2
vline_a1:
		not.w      d7
		move.l     -(a1),d0
		swap       d0
		move.l     d0,(a1)+
vline_a2:
		move.w     #0x4100,(a1)+
		move.w     #0xFFFF,(a1)+
		add.w      d6,d6
		add.w      d6,d6
		move.l     x1160a+8(pc,d6.w),(a1)+
		move.w     d7,(a1)+
		move.w     #0x5400,(a1)+
		move.w     #0,(a1)+
		move.w     d2,(a1)+
		move.w     #0x0301,(a1)+
		movea.l    x104b4(pc),a0
		move.w     x104a4+2(pc),2(a0)
		move.w     #0,4(a0)
		move.w     #0x0200,(a0)
		addq.l     #1,a0
vline_a3:
		btst       #0,(a0)
		beq.s      vline_a3
		movea.l    (a7)+,a0
		rts

x1160a:
	dc.l 0x00050600
	dc.l 0x00050700
	dc.l 0x00060600
	dc.l 0x00050700

/* 1161a */
		move.l     a0,-(a7)
		move.w     wr_mode(a6),d6
		movea.l    x104a4(pc),a1
		sub.w      d0,d2
		sub.w      d1,d3
		move.w     #0x4F00,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     #0x3D00,(a1)+
		lea.l      nibbletab(pc),a0
		move.l     r_fg_pixel(a6),d0
		add.w      d0,d0
		move.w     0(a0,d0.w),(a1)+
		move.l     r_bg_pixel(a6),d0
		add.w      d0,d0
		move.w     0(a0,d0.w),(a1)+
		subq.w     #2,d6
		bmi.s      hline_a2
		bne.s      hline_a1
		move.l     #0xFFFF0000,-4(a1)
		bra.s      hline_a2
hline_a1:
		not.w      d7
		move.l     -(a1),d0
		swap       d0
		move.l     d0,(a1)+
hline_a2:
		move.w     #0x4100,(a1)+
		move.w     #0xFFFF,(a1)+
		add.w      d6,d6
		add.w      d6,d6
		move.l     x116a2+8(pc,d6.w),(a1)+
		move.w     d7,(a1)+
		move.w     #0x5400,(a1)+
		move.w     d2,(a1)+
		move.w     d3,(a1)+
		move.w     #0x0301,(a1)+
		movea.l    x104b4(pc),a0
		move.w     x104a4+2(pc),2(a0)
		move.w     #0,4(a0)
		move.w     #0x0200,(a0)
		addq.l     #1,a0
hline_a3:
		btst       #0,(a0)
		beq.s      hline_a3
		movea.l    (a7)+,a0
		rts

x116a2:
	dc.l 0x00050600
	dc.l 0x00050700
	dc.l 0x00060600
	dc.l 0x00050700

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
fbox_accel:
		sub.w      d0,d2
		sub.w      d1,d3
		move.l     r_fg_pixel(a6),d6
		move.w     wr_mode(a6),d7
		bne.s      fbox_a1
		tst.w      d6
		beq        fbox_accel_white
		cmp.w      #150,d2 ; hm, only considers width, but not height?
		bge.s      fbox_a1
		add.w      d0,d2
		add.w      d1,d3
		bra        fbox_exit
fbox_a1:
		move.w     #0x0200,d4
		moveq.l    #0,d5
		lea.l      nibbletab(pc),a0
		add.w      d6,d6
		move.l     0(a0,d6.w),d6
		move.w     r_bg_pixel+2(a6),d6
		add.w      d6,d6
		move.w     0(a0,d6.w),d6
		movea.l    x104b4(pc),a0
		lea.l      1(a0),a1
		lea.l      2(a0),a2
		movea.l    x104a4(pc),a3
		movea.l    a3,a4
		movea.l    x104a8(pc),a5
		move.l     #1,(a5)
		move.w     d2,4(a5)
		move.w     #0x4F00,(a4)+
		move.w     d0,(a4)+
		subq.w     #1,d1
		move.w     d1,(a4)+
		addq.w     #1,d1
		move.w     #0x3D00,(a4)+
		move.l     d6,(a4)+
		swap       d6
		move.w     #0x4100,(a4)+
		moveq.l    #15,d0
		and.w      d1,d0
		move.w     d0,d1
		add.w      d0,d0
		movea.l    f_pointer(a6),a6
		adda.w     d0,a6
		eori.w     #0x000F,d1
		add.w      d7,d7
		move.w     fbox_accel_jmptab(pc,d7.w),d7
		jmp        fbox_accel_jmptab(pc,d7.w)

fbox_accel_jmptab:
	dc.w fbox_accel_repl-fbox_accel_jmptab
	dc.w fbox_accel_trans-fbox_accel_jmptab
	dc.w fbox_accel_xor-fbox_accel_jmptab
	dc.w fbox_accel_erase-fbox_accel_jmptab

fbox_accel_repl:
		move.l     #0xFFFF0005,(a4)+
		move.w     #0x0301,(a4)+
		move.w     a3,(a2)
		move.w     #0,4(a0)
		move.w     d4,(a0)
		movea.l    a4,a3
		move.w     #0x0600,(a4)+
		move.w     #0xBA00,4(a3)
		move.w     a5,6(a3)
		move.l     #1,8(a3)
		move.w     #0x0301,12(a3)
fbox_accel_repl1:
		btst       d5,(a1)
		beq.s      fbox_accel_repl1
		move.w     (a6)+,(a4)
		dbf        d1,fbox_accel_repl2
		moveq.l    #15,d1
		lea.l      -32(a6),a6
fbox_accel_repl2:
		move.w     a3,(a2)
		move.w     d4,(a0)
		dbf        d3,fbox_accel_repl1
fbox_accel_repl3:
		btst       d5,(a1)
		beq.s      fbox_accel_repl3
		rts

fbox_accel_white:
		movea.l    x104b4(pc),a0
		movea.l    x104a4(pc),a1
		moveq.l    #0,d5
		move.w     d5,4(a0)
		move.w     a1,2(a0)
		move.w     #0x4F00,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     #0x4100,(a1)+
		move.l     #0xFFFF0000,(a1)+
		move.w     #0x6400,(a1)+
		move.l     d5,(a1)+
		move.w     d2,(a1)+
		move.w     d3,(a1)+
		move.w     #0x0301,(a1)+
		move.w     #0x0200,(a0)
		addq.l     #1,a0
fbox_accel_white1:
		btst       d5,(a0)
		beq.s      fbox_accel_white1
		rts

fbox_accel_trans:
		move.l     #0xFFFF0005,(a4)+
		move.w     #0x0301,(a4)+
		move.w     a3,(a2)
		move.w     #0,4(a0)
		move.w     d4,(a0)
		movea.l    a4,a3
		move.w     #0x0700,(a4)+
		move.w     #0xBA00,4(a3)
		move.w     a5,6(a3)
		move.l     #1,8(a3)
		move.w     #0x0301,12(a3)
fbox_accel_trans1:
		btst       d5,(a1)
		beq.s      fbox_accel_trans1
		move.w     (a6)+,(a4)
		dbf        d1,fbox_accel_trans2
		moveq.l    #15,d1
		lea.l      -32(a6),a6
fbox_accel_trans2:
		move.w     a3,(a2)
		move.w     d4,(a0)
		dbf        d3,fbox_accel_trans1
fbox_accel_trans3:
		btst       d5,(a1)
		beq.s      fbox_accel_trans3
		rts

fbox_accel_xor:
		move.l     #0xFFFF0006,(a4)+
		move.w     #0x3D00,(a4)+
		move.l     #0xFFFF0000,(a4)+
		move.w     #0x0301,(a4)+
		move.w     a3,(a2)
		move.w     #0,4(a0)
		move.w     d4,(a0)
		movea.l    a4,a3
		move.w     #0x0600,(a4)+
		move.w     #0xBA00,4(a3)
		move.w     a5,6(a3)
		move.l     #1,8(a3)
		move.w     #0x0301,12(a3)
fbox_accel_xor1:
		btst       d5,(a1)
		beq.s      fbox_accel_xor1
		move.w     (a6)+,(a4)
		dbf        d1,fbox_accel_xor2
		moveq.l    #15,d1
		lea.l      -32(a6),a6
fbox_accel_xor2:
		move.w     a3,(a2)
		move.w     d4,(a0)
		dbf        d3,fbox_accel_xor1
fbox_accel_xor3:
		btst       d5,(a1)
		beq.s      fbox_accel_xor3
		rts

fbox_accel_erase:
		move.l     -6(a4),d0
		swap       d0
		move.l     d0,-6(a4)
		move.l     #0xFFFF0005,(a4)+
		move.w     #0x0301,(a4)+
		move.w     a3,(a2)
		move.w     #0,4(a0)
		move.w     d4,(a0)
		movea.l    a4,a3
		move.w     #0x0700,(a4)+
		move.w     #0xBA00,4(a3)
		move.w     a5,6(a3)
		move.l     #1,8(a3)
		move.w     #0x0301,12(a3)
fbox_accel_erase1:
		btst       d5,(a1)
		beq.s      fbox_accel_erase1
		move.w     (a6)+,d0
		not.w      d0
		move.w     d0,(a4)
		dbf        d1,fbox_accel_erase2
		moveq.l    #15,d1
		lea.l      -32(a6),a6
fbox_accel_erase2:
		move.w     a3,(a2)
		move.w     d4,(a0)
		dbf        d3,fbox_accel_erase1
fbox_accel_erase3:
		btst       d5,(a1)
		beq.s      fbox_accel_erase3
		rts

fbox:
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d4
relok149:
		tst.w      bitmap_width(a6)
		beq.s      fbox1
		movea.l    bitmap_addr(a6),a1
		move.w     bitmap_width(a6),d4
fbox1:
		cmpi.w     #4,f_interior(a6)
		beq.s      fbox_exit
		cmpa.l     vga_membase(pc),a1
		beq        fbox_accel
fbox_exit:
		movea.l    fbox_ptr(pc),a1
		jmp        (a1)

bitblt_in:
		move.w     d7,r_wmode(a6)
		move.w     d4,d6
		move.w     d5,d7
		bra.s      bitblt1

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
		bne.s      bitblt_exit
		cmp.w      d5,d7
		bne.s      bitblt_exit
		btst       #4,r_wmode+1(a6)
		bne.s      bitblt_exit
		movea.l    r_saddr(a6),a0
		movea.l    r_daddr(a6),a1
		movea.w    r_swidth(a6),a2
		movea.w    r_dwidth(a6),a3
bitblt1:
		cmpa.l     vga_membase(pc),a0
		bne.s      bitblt_exit
		cmpa.l     vga_membase(pc),a1
		bne.s      bitblt_exit
		cmpa.w     line_width(pc),a2
		bne.s      bitblt_exit
		cmpa.w     line_width(pc),a3
		beq.s      bitblt2
bitblt_exit:
		movea.l    bitblt_ptr(pc),a4
		jmp        (a4)
bitblt2:
		moveq.l    #15,d7
		and.w      r_wmode(a6),d7
		movea.l    x104b4,a0
		movea.l    x104a4,a1
		move.w     #0,4(a0)
		move.w     a1,2(a0)
		move.w     #0x4F00,(a1)+
		move.w     d2,(a1)+
		move.w     d3,(a1)+
		move.w     #0x4100,(a1)+
		move.w     #0xFFFF,(a1)+
		move.b     bitblt_optab(pc,d7.w),d7
		move.w     d7,(a1)+
		move.w     #0x6400,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     d4,(a1)+
		move.w     d5,(a1)+
		move.w     #0x0301,(a1)+
		move.w     #0x0200,(a0)
		moveq.l    #0,d0
		addq.l     #1,a0
bitblt3:
		btst       d0,(a0)
		beq.s      bitblt3
		rts

bitblt_optab:
	dc.b 0,1,4,5,2,3,6,7,8,9,12,13,10,11,14,15

gtext_exit:
		movea.l    gtext_ptr(pc),a4
		jmp        (a4)

gtext_small:
		subq.w     #8,d0
		or.w       t_effects(a6),d0
		bne.s      gtext_exit
		movea.l    fontbuf_ptr(pc),a1
		movea.l    t_image(a6),a0
gtext_small1:
		movea.l    a0,a4
		adda.w     (a2)+,a4
		move.b     (a4),(a1)+
		move.b     256(a4),255(a1)
		move.b     512(a4),511(a1)
		move.b     768(a4),767(a1)
		move.b     1024(a4),1023(a1)
		move.b     1280(a4),1279(a1)
		move.b     1536(a4),1535(a1)
		move.b     1792(a4),1791(a1)
		dbf        d6,gtext_small1
		move.w     (a3)+,d2
		move.w     (a3)+,d3
		lsl.w      #3,d4
		addq.w     #7,d4
		moveq.l    #7,d5
		bra        gtext3

gtext_effects:
		movea.l    bold_image(pc),a0
		subq.w     #1,d0
		beq        gtext0
		subq.w     #8,d0
		beq.s      gtext_effects1
		addq.w     #1,d0
		bne.s      gtext_exit
		movea.l    font_image(pc),a0
gtext_effects1:
		movea.l    fontbuf_ptr(pc),a1
gtext_effects2:
		movea.l    a0,a4
		move.w     (a2)+,d0
		lsl.w      #4,d0
		adda.w     d0,a4
		move.b     (a4)+,(a1)+
		move.b     (a4)+,255(a1)
		move.b     (a4)+,511(a1)
		move.b     (a4)+,767(a1)
		move.b     (a4)+,1023(a1)
		move.b     (a4)+,1279(a1)
		move.b     (a4)+,1535(a1)
		move.b     (a4)+,1791(a1)
		move.b     (a4)+,2047(a1)
		move.b     (a4)+,2303(a1)
		move.b     (a4)+,2559(a1)
		move.b     (a4)+,2815(a1)
		move.b     (a4)+,3071(a1)
		move.b     (a4)+,3327(a1)
		move.b     (a4)+,3583(a1)
		move.b     #0xFF,3839(a1)
		dbf        d6,gtext_effects2
		bra        gtext2

/*
 * Allgemeine Textroutine
 * Eingaben
 * a1 contrl
 * a2 intin
 * a3 ptsin
 * a6 Zeiger auf die Workstation
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
gtext:
		move.w     v_nintin(a1),d6
		subq.w     #1,d6
		cmp.w      #255,d6
		bhi        gtext_exit
		move.w     d6,d4
		move.w     t_number(a6),d0
		subq.w     #1,d0
		or.b       t_grow(a6),d0
		or.w       t_rotation(a6),d0
		bne        gtext_exit
		moveq.l    #16,d0
		sub.w      t_cheight(a6),d0
		bne        gtext_small
		or.w       t_effects(a6),d0
		bne        gtext_effects
		movea.l    font_image(pc),a0
gtext0:
		movea.l    fontbuf_ptr(pc),a1
gtext1:
		movea.l    a0,a4
		move.w     (a2)+,d0
		lsl.w      #4,d0
		adda.w     d0,a4
		move.b     (a4)+,(a1)+
		move.b     (a4)+,255(a1)
		move.b     (a4)+,511(a1)
		move.b     (a4)+,767(a1)
		move.b     (a4)+,1023(a1)
		move.b     (a4)+,1279(a1)
		move.b     (a4)+,1535(a1)
		move.b     (a4)+,1791(a1)
		move.b     (a4)+,2047(a1)
		move.b     (a4)+,2303(a1)
		move.b     (a4)+,2559(a1)
		move.b     (a4)+,2815(a1)
		move.b     (a4)+,3071(a1)
		move.b     (a4)+,3327(a1)
		move.b     (a4)+,3583(a1)
		move.b     (a4)+,3839(a1)
		dbf        d6,gtext1
gtext2:
		move.w     (a3)+,d2
		move.w     (a3)+,d3
		lsl.w      #3,d4
		addq.w     #7,d4
		moveq.l    #15,d5
gtext3:
		move.w     t_ver(a6),d1
		add.w      d1,d1
		sub.w      t_base(a6,d1.w),d3
		move.w     t_hor(a6),d7
		beq.s      gtext5
		moveq.l    #0,d0
		subq.w     #1,d7
		bne.s      gtext4
		move.w     d4,d0
		addq.w     #1,d0
		asr.w      #1,d0
		sub.w      d0,d2
		bra.s      gtext5
gtext4:
		sub.w      d4,d2
gtext5:
		movea.l    fontbuf_ptr(pc),a0
		movea.w    #256,a2
		bra.s      gtext6
		rts

textblt_exit:
		move.l     textblt_ptr(pc),-(a7)
		rts
textblt_ret:
		rts

gtext6:
		moveq.l    #0,d0
		moveq.l    #0,d1
		move.w     d5,d7
		add.w      d2,d4
		add.w      d3,d5
		lea.l      clip_xmin(a6),a1
		cmp.w      (a1)+,d2
		bge.s      gtext7
		sub.w      d2,d0
		move.w     -2(a1),d2
		add.w      d2,d0
gtext7:
		cmp.w      (a1)+,d3
		bge.s      gtext8
		sub.w      d3,d1
		move.w     -2(a1),d3
		add.w      d3,d1
gtext8:
		cmp.w      (a1)+,d4
		ble.s      gtext9
		move.w     -2(a1),d4
gtext9:
		cmp.w      (a1),d5
		ble.s      gtext10
		move.w     (a1),d5
gtext10:
		sub.w      d2,d4
		bmi.s      textblt_ret
		sub.w      d3,d5
		bmi.s      textblt_ret
		movem.l    d0-d1/a0/a2,-(a7)
		move.l     wk_itab(a6),-(a7)
		movea.l    nvdi_struct(pc),a3
		move.l     wk_px_format(a6),d1
		lea.l      t_fg_colorrgb(a6),a0
		movea.l    wk_ctab(a6),a1
		move.w     t_color(a6),d0
		bpl.s      gtext11
		movea.l    _nvdi_color2value(a3),a3
		move.l     d1,d0
		jsr        (a3)
		move.l     d0,r_fg_pixel(a6)
		move.l     wk_px_format(a6),d0
		lea.l      t_bg_colorrgb(a6),a0
		movea.l    wk_ctab(a6),a1
		jsr        (a3)
		move.l     d0,r_bg_pixel(a6)
		bra.s      gtext13
gtext11:
		movea.l    _nvdi_color2pixel(a3),a3
		jsr        (a3)
		move.l     gdos_buffer(a6),d1
		cmpi.w     #MD_ERASE-1,wr_mode(a6)
		bne.s      gtext12
		exg        d0,d1
gtext12:
		move.l     d0,r_fg_pixel(a6)
		move.l     d1,r_bg_pixel(a6)
gtext13:
		addq.l     #4,a7
		movem.l    (a7)+,d0-d1/a0/a2
		movea.l    v_bas_ad.w,a1
		movea.w    BYTES_LIN.w,a3
relok150:
		cmpa.l     vga_membase(pc),a1
		bne        textblt_exit
		cmpa.l     x104b0(pc),a0
		bne        textblt_exit
		move.l     a0,d6
		sub.l      x104a0(pc),d6
		swap       d6
		move.l     r_fg_pixel(a6),d7
		movea.l    x104b4(pc),a0
		movea.l    x104a4(pc),a1
		move.w     #0,4(a0)
		move.w     a1,2(a0)
		move.w     #0x4F00,(a1)+
		move.w     d2,(a1)+
		move.w     d3,(a1)+
		move.w     #0x3D00,(a1)+
		lea.l      nibbletab(pc),a3
		move.l     r_fg_pixel(a6),d7
		add.w      d7,d7
		move.w     0(a3,d7.w),(a1)+
		move.w     #0x0000,(a1)+
		move.w     #0x4100,(a1)+
		move.w     #0xFFFF,(a1)+
		move.w     wr_mode(a6),d7
		cmp.w      #MD_XOR-1,d7
		bne.s      gtext14
		move.w     #-1,-8(a1)
gtext14:
		add.w      d7,d7
		add.w      d7,d7
		move.l     x11c76(pc,d7.w),(a1)+
		move.l     d6,(a1)+
		move.w     a2,d2
		lsl.w      #3,d2
		subq.w     #1,d2
		move.w     d1,d3
		add.w      d5,d3
		move.w     d2,(a1)+
		move.w     d3,(a1)+
		move.w     d0,(a1)+
		move.w     d1,(a1)+
		move.w     d4,(a1)+
		move.w     d5,(a1)+
		move.w     #0x0301,(a1)+
		move.w     #0x0200,(a0)
		moveq.l    #0,d0
		addq.l     #1,a0
gtext15:
		btst       d0,(a0)
		beq.s      gtext15
		rts

x11c76:
	dc.l 0x0005d400
	dc.l 0x0005d500
	dc.l 0x0006d400
	dc.l 0x0005d700

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
                  DC.W relok87-relok86
                  DC.W relok88-relok87-2,2
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
                  DC.W 0

nibbletab:
		dc.w 0x0000
		dc.w 0x1111
		dc.w 0x2222
		dc.w 0x3333
		dc.w 0x4444
		dc.w 0x5555
		dc.w 0x6666
		dc.w 0x7777
		dc.w 0x8888
		dc.w 0x9999
		dc.w 0xaaaa
		dc.w 0xbbbb
		dc.w 0xcccc
		dc.w 0xdddd
		dc.w 0xeeee
		dc.w 0xffff

nibble2tab:
		dc.l 0x00000000
		dc.l 0x11111111
		dc.l 0x22222222
		dc.l 0x33333333
		dc.l 0x44444444
		dc.l 0x55555555
		dc.l 0x66666666
		dc.l 0x77777777
		dc.l 0x88888888
		dc.l 0x99999999
		dc.l 0xaaaaaaaa
		dc.l 0xbbbbbbbb
		dc.l 0xcccccccc
		dc.l 0xdddddddd
		dc.l 0xeeeeeeee
		dc.l 0xffffffff

cxx_driv_name:
		dc.b ':\MATRIX\CXX_DRIV.TTP',0
cxx_info_name:
		dc.b ':\MATRIX\CXX_INFO.TOS',0
cxs_path:
		dc.b ':\MATRIX\CXX\*.CXS',0
		.even

dev_name:
		dc.b 'Matric CXX 16 Farben',0
		.even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS

redirect_ptr:     ds.l 1

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L 1

escape_ptr:       ds.l 1
bitblt_ptr:       ds.l 1
hline_ptr:        ds.l 1
vline_ptr:        ds.l 1
line_ptr:         ds.l 1
fbox_ptr:         ds.l 1
gtext_ptr:        ds.l 1
textblt_ptr:      ds.l 1

xbios_tab:        ds.l 1                  ;alte NVDI-XBios-Vektoren
bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 20*16

aes_wk_ptr:       ds.l 1
hid_cnt:          ds.w 1
mycon_state:      ds.l 1
save_vt52_vec:    ds.l 1

vscr_struct:      ds.b 22
xbios_rez:        ds.w 1
expand_tab:       ds.l 256

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

sysfont_addr:     ds.l 1
font_image:       ds.l 1
bold_image:       ds.l 1
oldvbl:           ds.l 1
oldvme:           ds.l 1
screen_offset:    ds.l 1

cmdline:          ds.b 128
pathbuf:          ds.b 128

global_ctable:    ds.l 1
global_itable:    ds.l 1

graymode:         ds.w 1
fontbuf:          ds.b 256*16
