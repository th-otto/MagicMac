;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*              Farb-Bildschirmtreiber fuer NVDI_PC                           *;
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

DRV_PLANES = 32

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
               ds.b 328

      ds.b 1792
      /* 2848 */
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
organisation:     DC.L  16777216          ;Farben
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
		movea.l    nvdi_struct,a0
		movea.l    _nvdi_load_NOD_driver(a0),a2
		lea.l      organisation,a0
		jsr        (a2)
		movea.l    driver_struct,a1
		move.l     a0,driver_offscreen(a1)
		beq.s      init_err
		moveq.l    #1,d0
		dc.w       0x41bf,1 ; mecnvdi 1
		lea.l      x_res(pc),a0
		moveq.l    #3,d0
		jsr        load_nvdipc_inf
		tst.w      d0
		bne.s      init_ret
		lea.l      x_res(pc),a0
		move.w     (a0),d0
		move.w     2(a0),d1
		moveq.l    #DRV_PLANES,d2
		suba.l     a1,a1
		lea.l      x_res(pc),a2
		dc.w       0x41bf,48 ; mecnvdi 48
		tst.w      d0
		bne.s      init_ret
		bsr        save_screen_vecs
		movem.l    d0-d7/a0-a6,-(a7)
		bsr.s      save_linea
		bsr        set_screen_vecs
		move.l     #16777216,d0
		bsr        init_maps
		bsr        init_res
		bsr        init_vt52
		movem.l    (a7)+,d0-d7/a0-a6
		movem.l    (a7)+,d0-d2/a0-a2
		move.l     #wk_sizeof,d0
		rts
init_ret:
		moveq.l    #0,d0
		dc.w       0x41bf,1 ; mecnvdi 1
init_err:
		movem.l    (a7)+,d0-d2/a0-a2
		moveq.l    #0,d0
		rts

save_linea:
		movem.l    d0/a0-a1,-(a7)
		lea.l      V_CEL_HT.w,a0
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
		moveq.l    #25-1,d0
restore_linea1:
		move.w     (a0)+,(a1)+
		dbf        d0,restore_linea1
		move.l     save_v_bas_ad(pc),v_bas_ad.w
		movem.l    (a7)+,d0/a0-a1
		rts

reset:
		movem.l    d0-d2/a0-a2,-(a7)
		bsr        free_tables
		movem.l    (a7),d0-d2/a0-a2
		movea.l    _nvdi_unload_NOD_driver(a0),a2
		movea.l    driver_offscreen(a1),a0
		jsr        (a2)
		bsr        reset_screen_vecs
		dc.w       0x41bf,49 ; mecnvdi 49
		bsr.s      restore_linea
		moveq.l    #0,d0
		dc.w       0x41bf,1 ; mecnvdi 1
		movem.l    (a7)+,d0-d2/a0-a2
		rts

save_screen_vecs:
		movea.l    nvdi_struct(pc),a0
		movea.l    _nvdi_xbios_tab(a0),a1
		move.l     _call_old_xbios(a1),xbios_tab+4
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
		move.w     x_res,(a0)+          ;adressierbare Rasterbreite
		move.w     y_res,(a0)+          ;adressierbare Rasterhoehe
		clr.w      (a0)+                ;genaue Skalierung moeglich !
		move.l     pixw,(a0)+           ;Pixelbreite/Pixelhoehe
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
		moveq.l    #11,d0
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
                  DC.W DRV_PLANES         ;32 Ebenen
                  DC.L 16777216           ;16777216 Farben
                  DC.W 0,0,0
                  DC.W 8                  ;8 Bits fuer die Rot-Intensitaet
                  DC.W 8                  ;8 Bits fuer die Gruen-Intensitaet
                  DC.W 8                  ;8 Bits fuer die Blau-Intensitaet
                  DC.W 8                  ;8 Bits fuer Alpha-Channel
                  DC.W 0                  ;kein Bit fuer Genlock
                  DC.W 0                  ;kein unbenutztes Bit
                  DC.W 0x81
                  DC.W 0
                  DC.W  8,9,10,11,12,13,14,15         ;Bits der Rot-Intensitaet
                  DCB.W 8,-1
                  DC.W  16,17,18,19,20,21,22,23       ;Bits der Gruen-Intensitaet
                  DCB.W 8,-1
                  DC.W  24,25,26,27,28,29,30,31       ;Bits der Rot-Intensitaet
                  DCB.W 8,-1
                  DC.W  0,1,2,3,4,5,6,7               ;Bits fuer Alpha-Channel
                  DCB.W 8,-1
                  DCB.W 16,-1             ;keine Bits fuer Genlock

                  DCB.W 32,-1             ;unbenutzte Bits

                  DCB.W 156,0             ;reserviert

palette_data:
	dc.l 0xffffffff,0x0000ff00,0x00ff0000,0x00ffff00,0xff000000,0xff00ff00,0xffff0000,0xd5d5d500
	dc.l 0x83838300,0x0000ac00,0x00ac0000,0x00acac00,0xac000000,0xac00ac00,0xacac0000,0x00000000


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
		tst.w      d0
		bpl.s      set_cur_clipx2
		moveq.l    #0,d0
set_cur_clipx2:
		cmp.w      d2,d0
		ble.s      set_cur_clipy1
		move.w     d2,d0
set_cur_clipy1:
		move.w     V_CEL_MY.w,d2
		tst.w      d1
		bpl.s      set_cur_clipy2
		moveq.l    #0,d1
set_cur_clipy2:
		cmp.w      d2,d1
		ble.s      set_cursor
		move.w     d2,d1
set_cursor:
		movem.w    d0-d1,V_CUR_XY.w
		movea.l    v_bas_ad.w,a1
		moveq.l    #0,d2
		move.w     d1,d2
		bsr        calc_screenadr
		adda.l     d2,a1
		lsl.w      #5,d0
		adda.w     d0,a1
		move.l     a1,V_CUR_AD.w
		bra.s      cursor_on

;Cursor ausschalten
cursor_off:
		addq.w     #1,hid_cnt
		cmpi.w     #1,hid_cnt
		bne.s      cursor_off_exit
		bclr       #CURSOR_STATE,V_STAT_0.w
		bne.s      cursor
cursor_off_exit:
		rts

;Cursor einschalten
cursor_on:
		cmpi.w     #1,hid_cnt
		bcs.s      cursor_on_exit2
		bhi.s      cursor_on_exit1
		move.b     V_PERIOD.w,V_CUR_CT.w
		bsr.s      cursor
		bset       #CURSOR_STATE,V_STAT_0.w
cursor_on_exit1:
		subq.w     #1,hid_cnt
cursor_on_exit2:
		rts

vbl_cursor:
		btst       #CURSOR_BL,V_STAT_0.w
		beq.s      vbl_no_bl
		bchg       #CURSOR_STATE,V_STAT_0.w
		bra.s      cursor
vbl_no_bl:
		bset       #CURSOR_STATE,V_STAT_0.w
		beq.s      cursor
		rts

;Cursor zeichnen
cursor:
		movem.l    d0-d1/a1/a4-a5,-(a7)
		moveq.l    #16,d0
		sub.w      V_CEL_HT.w,d0
		add.w      d0,d0
		move.w     d0,d1
		add.w      d0,d0          ;(16 - Zeichenhoehe) * 6 ; BUG: must be * 10
		add.w      d1,d0
		movea.l    V_CUR_AD.w,a1
		moveq.l    #-32,d1
		add.w      BYTES_LIN.w,d1
		jmp        cursor_jmp(pc,d0.w)
cursor_jmp:
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		adda.w     d1,a1
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		not.l      (a1)+
		movem.l    (a7)+,d0-d1/a1/a4-a5
cursor_exit:
		rts

;BEL, Klingelzeichen
vt_bel:
		btst       #2,conterm.w
		beq.s      cursor_exit
		movea.l    bell_hook.w,a0
		jmp        (a0)

;BACKSPACE, ein Zeichen zurueck
;d0 Textspalte
;d1 Textzeile
vt_bs:
		movem.w    V_CUR_XY.w,d0-d1
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
		beq        scroll_up_page
		move.l     v_cel_wr(pc),d0
		add.l      d0,V_CUR_AD.w
		addq.w     #1,V_CUR_XY+2.w
		rts

;RETURN, Zeilenanfang
;d0 Textspalte
vt_cr:
		bsr        cursor_off
		pea.l      cursor_on(pc)
		movea.l    V_CUR_AD.w,a1

;Cursor an den Zeilenanfang setzen
;Eingabe
;d0 Cursorspalte
;a1 Cursoradresse
;Ausgabe
;a1 neue Cursoradresse
;zerstoert werden d0/d2
set_x0:
		lsl.w      #5,d0
		suba.w     d0,a1
		move.l     a1,V_CUR_AD.w
		clr.w      V_CUR_XY.w
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
		move.l     #vt_con0,mycon_state ;Sprungadresse
		add.w      d1,d1
		move.w     vt_c_tab(pc,d1.w),d2
		movem.w    V_CUR_XY.w,d0-d1 ;Textspalte/-zeile
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
		st         in_con
		jmp        (a0)
vt_con0:
		cmpi.w     #32,d1               ;Steuerzeichen ?
		blt.s      vt_control

vt_rawcon:
		movea.l    V_CUR_AD.w,a1        ;Cursoradresse
		moveq.l    #-32,d2
		add.w      BYTES_LIN.w,d2       ;Bytes pro Zeile
		move.b     #2,V_CUR_CT.w        ;Zaehler auf 2 -> keinen Cursor zeichnen
		bclr       #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
		move.l     V_FNT_AD.w,d0        ;Fontimageadresse

vt_char_col:
		movem.l    d3-d4/a3,-(a7)
		lea.l      V_COL_BG.w,a2
		move.w     (a2)+,d3             ;V_COL_BG
		move.w     (a2)+,d2             ;V_COL_FG
		add.w      d2,d2
		add.w      d2,d2
		add.w      d3,d3
		add.w      d3,d3
		lea.l      palette_data(pc),a2
		move.l     0(a2,d2.w),d2
		move.l     0(a2,d3.w),d3
		btst       #CURSOR_INVERSE,V_STAT_0.w ;invertieren ?
		beq.s      vt_char_col2
		exg        d2,d3
vt_char_col2:
		movea.l    d0,a0
		adda.w     d1,a0
		movea.w    V_FNT_WD.w,a2
		movea.w    BYTES_LIN.w,a3
		lea.l      -32(a3),a3
		move.w     V_CEL_HT.w,d1
		subq.w     #1,d1                ;Zeilenzaehler
vt_char_cloop:
		move.b     (a0),d4
		moveq.l    #7,d0
vt_char_cloop2:
		add.b      d4,d4
		bcc.s      vt_char_cbg
		move.l     d2,(a1)+
		dbf        d0,vt_char_cloop2
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d1,vt_char_cloop
		movem.l    (a7)+,d3-d4/a3
		bra.s      vt_n_column
vt_char_cbg:
		move.l     d3,(a1)+
		dbf        d0,vt_char_cloop2
		adda.w     a2,a0
		adda.w     a3,a1
		dbf        d1,vt_char_cloop
		movem.l    (a7)+,d3-d4/a3
vt_n_column:
		move.w     V_CUR_XY.w,d0
		cmp.w      V_CEL_MX.w,d0        ;letzte Spalte ?
		bge.s      vt_l_column
		addi.l     #32,V_CUR_AD.w       ;naechste Spalte
		addq.w     #1,V_CUR_XY0.w
		moveq.l    #-1,d0
		rts
vt_l_column:
		btst       #CURSOR_WRAP,V_STAT_0.w ; Wrapping ein ?
		beq.s      vt_con_exit
		addq.w     #1,hid_cnt           ;Cursor sperren
vt_l_column2:
		ext.l      d0
		lsl.l      #5,d0
		sub.l      d0,V_CUR_AD.w        ;Zeilenanfang (d0: High-Word=0 !)
		clr.w      V_CUR_XY0.w
		move.w     V_CUR_XY1.w,d1
		pea.l      vt_con_exit2(pc)
		cmp.w      V_CEL_MY.w,d1        ;letzte Zeile (Scrolling) ?
		bge        scroll_up_page
		addq.l     #4,a7                ;Stack korrigieren
		move.l     v_cel_wr(pc),d0      ;Bytes pro Textzeile
		add.l      d0,V_CUR_AD.w        ;naechste Textzeile
		addq.w     #1,V_CUR_XY1.w
vt_con_exit2:
		subq.w     #1,hid_cnt           ;Cursor zulassen
vt_con_exit:
		rts

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq:
		cmpi.w     #'Y',d1
		beq        vt_seq_Y
		move.w     d1,d2
		movem.w    V_CUR_XY0.w,d0-d1
		movea.l    V_CUR_AD.w,a1
		movea.w    BYTES_LIN.w,a2
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
		movea.l    v_bas_ad.w,a1
		move.l     a1,V_CUR_AD.w
		bra        cursor_on

;Cursor up and insert (VT52 ESC I)
vt_seq_I:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		subq.w     #1,d1
		blt        scroll_down_page
		suba.l     v_cel_wr(pc),a1
		move.l     a1,V_CUR_AD.w
		move.w     d1,V_CUR_XY1.w
		rts

; ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
v_eeos:
vt_seq_J:
		bsr.s      vt_seq_K
		move.w     V_CUR_XY1.w,d1
		move.w     V_CEL_MY.w,d2
		sub.w      d1,d2
		beq.s      vt_seq_J_exit
		movem.l    d2-d7/a1-a6,-(a7)
		movea.l    v_bas_ad.w,a1
		addq.w     #1,d1
		and.l      #0x0000FFFF,d1
		bsr        calc_screenadr
		adda.l     d1,a1
		move.w     d2,d7
		mulu.w     V_CEL_HT.w,d7
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
		sub.w      d1,d5
		beq.s      vt_seq_L_exit
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
		movea.w    a2,a3
		move.w     V_CEL_HT.w,d0
		mulu.w     d0,d1
		move.w     d1,d3
		add.w      d0,d3
		move.w     V_CEL_MX.w,d4
		lsl.w      #3,d4
		addq.w     #7,d4
		mulu.w     d0,d5
		subq.w     #1,d5
		moveq.l    #3,d7
		moveq.l    #0,d0
		moveq.l    #0,d2
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		moveq.l    #0,d0
		move.w     V_CUR_XY1.w,d0
		bsr        calc_screenadr
		adda.l     d0,a1
		bra        clear_line2
vt_seq_L_exit:
		movea.l    V_CUR_AD.w,a1
		bra        clear_line2

;Delete Line (VT52 ESC M)
vt_seq_M:
		pea.l      cursor_on(pc)
		bsr        cursor_off
		bsr        set_x0
		movem.l    d2-d7/a1-a6,-(a7)
		move.w     V_CEL_MY.w,d7
		sub.w      d1,d7
		beq.s      vt_seq_M_last
		move.w     V_CEL_HT.w,d3
		moveq.l    #0,d0
		mulu.w     d3,d1
		moveq.l    #0,d2
		add.w      d1,d3
		exg        d1,d3
		movem.w    V_CEL_MX.w,d4-d5
		addq.w     #1,d4
		lsl.w      #4,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
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
		move.w     V_CUR_XY.w,d0
		move.l     #vt_set_x,mycon_state
		bra        set_cursor_xy
;x-Koordinate setzen
vt_set_x:
		subi.w     #32,d1
		move.w     d1,d0
		move.w     V_CUR_XY1.w,d1
		move.l     #vt_con0,mycon_state
		bra        set_cursor_xy

;Foreground color (VT52 ESC b)
vt_seq_b:
		move.l     #vt_set_b,mycon_state
		rts
vt_set_b:
		lea.l      V_COL_FG.w,a1
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
		bra.s      vt_set_col

;Erase to start of page (VT52 ESC d)
vt_seq_d:
		bsr.s      vt_seq_o
		move.w     V_CUR_XY1.w,d1
		beq.s      vt_seq_d_exit
		movem.l    d2-d7/a1-a6,-(a7)
		mulu.w     V_CEL_HT.w,d1
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
		move.l     V_CUR_XY0.w,V_SAV_XY.w
		rts

;Restore cursor (VT52 ESC k)
vt_seq_k:
		movem.w    V_SAV_XY.w,d0-d1
		bclr       #CURSOR_SAVED,V_STAT_0.w
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
		and.l      #0x0000FFFF,d1
		bsr        calc_screenadr
		adda.l     d1,a1
		bra        clear_line_part
vt_seq_o_exit:
		rts

;REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
v_rvon:
vt_seq_p:
		bset       #CURSOR_INVERSE,V_STAT_0.w
		rts

; REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
v_rvoff:
vt_seq_q:
		bclr       #CURSOR_INVERSE,V_STAT_0.w
		rts

;Wrap at end of line (VT52 ESC v)
vt_seq_v:
		bset       #CURSOR_WRAP,V_STAT_0.w
		rts

;Discard end of line (VT52 ESC w)
vt_seq_w:
		bclr       #CURSOR_WRAP,V_STAT_0.w
		rts

scroll_up_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		move.w     V_CEL_HT.w,d1
		moveq.l    #0,d2
		moveq.l    #0,d3
		movem.w    V_CEL_MX.w,d4-d5
		addq.w     #1,d4
		lsl.w      #3,d4
		subq.w     #1,d4
		mulu.w     V_CEL_HT.w,d5
		subq.w     #1,d5
scroll_up2:
		moveq.l    #S_ONLY,d7
		movea.l    v_bas_ad.w,a0
		movea.l    a0,a1
		movea.w    BYTES_LIN.w,a2
		movea.w    a2,a3
		jsr        bitblt_in
		movea.l    v_bas_ad.w,a1
		moveq.l    #0,d0
		move.w     V_CEL_MY.w,d0
		bsr        calc_screenadr
		adda.l     d0,a1
		bra.s      clear_line2

scroll_down_page:
		movem.l    d2-d7/a1-a6,-(a7)
		moveq.l    #0,d0
		moveq.l    #0,d1
		moveq.l    #0,d2
		move.w     V_CEL_HT.w,d3
		movem.w    V_CEL_MX.w,d4-d5
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
		subq.w     #1,d7
;d7.w Zeilenzaehler
clear_lines:
		move.w     V_COL_BG.w,d6        ;Hintergrundfarbe
		beq.s      clear_lwhite         ;weiss?
		add.w      d6,d6
		add.w      d6,d6
		lea.l      palette_data(pc),a2
		adda.w     d6,a2
		move.l     (a2),d6
		move.w     V_CEL_MX.w,d4
		move.w     BYTES_LIN.w,d5
		move.w     d4,d2
		addq.w     #1,d2
		lsl.w      #5,d2
		sub.w      d2,d5
clear_line_bloop:
		move.w     d4,d2
clear_line_loop:
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
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
		move.w     d4,d2
		addq.w     #1,d2
		lsl.w      #5,d2
		move.w     BYTES_LIN.w,d5
		sub.w      d2,d5
clear_lw_bloop:
		move.w     d4,d2
clear_lw_loop:
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
		move.l     d6,(a1)+
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
		addq.w     #1,d7
		mulu.w     V_CEL_HT.w,d7
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
		add.w      d3,d3
		add.w      d3,d3
		lea.l      palette_data(pc),a0
		move.l     0(a0,d3.w),d3
		move.w     V_CEL_HT.w,d1
		subq.w     #1,d1
		move.w     d2,d0
		addq.w     #1,d0
		lsl.w      #5,d0
		movea.w    BYTES_LIN.w,a0
		suba.w     d0,a0
clear_lpart_bloop:
		move.w     d2,d0
clear_lpart_loop:
		move.l     d3,(a1)+
		move.l     d3,(a1)+
		move.l     d3,(a1)+
		move.l     d3,(a1)+
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
		movea.w    BYTES_LIN.w,a3
		dc.w       0x41bf,52 ; mecnvdi 52
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
		moveq.l    #0,d6
		moveq.l    #0,d7
		move.b     7(a0),d6
		move.b     9(a0),d7
		lsl.l      #3,d6
		lsl.l      #3,d7
		movea.l    aes_wk_ptr(pc),a1
		movea.l    wk_ctab(a1),a1
		lea.l      ctab_colors(a1,d6.l),a3
		move.w     (a3)+,d6
		move.b     (a3),d6
		addq.l     #2,a3
		swap       d6
		move.w     (a3)+,d6
		move.b     (a3),d6
		lea.l      ctab_colors(a1,d7.l),a3
		move.w     (a3)+,d7
		move.b     (a3),d7
		addq.l     #2,a3
		swap       d7
		move.w     (a3)+,d7
		move.b     (a3),d7
		movea.l    v_bas_ad.w,a1
		movea.w    BYTES_LIN.w,a3
		dc.w       0x41bf,53 ; mecnvdi 53
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
		move.w     #265,pixw
		move.w     #265,pixh
		movem.w    x_res,d0-d1
		move.w     line_width,d2
		move.l     screen_ptr,v_bas_ad.w
		move.w     #DRV_PLANES,PLANES.w
		move.w     d2,WIDTH.w
		move.w     d2,BYTES_LIN.w
		movem.l    (a7)+,d0-d2/a0-a2
		rts

;VT52-Emulator an die gewaehlte Aufloesung anpassen
;kein Register wird zerstoert
init_vt52:
		movem.l    d0-d4/a0-a2,-(a7)
		movea.l    nvdi_struct,a0
		movea.l    _nvdi_sys_font_info(a0),a0
		move.l     _sf_image(a0),font_image
		movem.w    x_res,d0-d1
		addq.w     #1,d0
		addq.w     #1,d1
		move.w     line_width,d2
		move.w     d0,V_REZ_HZ.w
		move.w     d1,V_REZ_VT.w
		movea.l    _sf_font_hdr_ptr(a0),a1
		lea.l      sizeof_FONTHDR(a1),a1
		cmpi.w     #400,d1
		blt.s      init_vt52_font
		lea.l      sizeof_FONTHDR(a1),a1
init_vt52_font:
		move.l     dat_table(a1),V_FNT_AD.w
		move.l     off_table(a1),V_OFF_AD.w
		move.w     #256,V_FNT_WD.w
		move.l     #0x00FF0000,V_FNT_ND.w
		move.w     form_height(a1),d3
		move.w     d3,V_CEL_HT.w
		lsr.w      #3,d0
		subq.w     #1,d0
		divu.w     d3,d1
		subq.w     #1,d1
		mulu.w     d3,d2
		move.l     d2,v_cel_wr
		movem.w    d0-d2,V_CEL_MX.w ; V_CEL_MX/V_CEL_MY/V_CEL_WR
		move.l     #15,V_COL_BG.w
		move.w     #1,V_HID_CNT.w
		move.w     #1,hid_cnt
		move.w     #256,V_STAT_0.w
		move.w     #0x1E1E,V_PERIOD.w
		move.l     v_bas_ad.w,V_CUR_AD.w
		clr.l      V_CUR_XY.w
		clr.w      V_CUR_OF.w
		move.l     #vt_con0,mycon_state
		movem.l    (a7)+,d0-d4/a0-a2
		rts

gooldxbios:
		movea.l    xbios_tab(pc),a1
		jmp        (a1)

myxbios:
		cmp.w      #21,d0 ;Cursconf?
		beq.s      cursconf
		cmp.w      #5,d0
		beq.s      setscreen
		cmp.w      #2,d0
		beq.s      physbase
		cmp.w      #4,d0
		beq.s      getrez
		bra.s      gooldxbios

physbase:
		move.l     screen_ptr(pc),d0
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
cursconf_ret:
		rts
cursconf_3:
		bclr       #CURSOR_BL,V_STAT_0.w
		rts
cursconf_4:
		move.b     1(a0),V_PERIOD.w
		rts
cursconf_5:
		moveq.l    #0,d0
		move.b     V_PERIOD.w,d0
		rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
		move.l     x_res,res_x(a6)
		move.w     #DRV_PLANES-1,r_planes(a6)
		move.w     #255,colors(a6)
		clr.w      res_ratio(a6)
		move.l     res_x(a6),clip_xmax(a6)
		lea.l      organisation,a0
		move.l     (a0)+,bitmap_colors(a6)
		move.w     (a0)+,bitmap_planes(a6)
		move.w     (a0)+,bitmap_format(a6)
		move.w     (a0)+,bitmap_flags(a6)
		move.l     p_fbox(a6),fbox_ptr
		move.l     p_hline(a6),hline_ptr
		move.l     p_fline(a6),fline_ptr
		move.l     p_vline(a6),vline_ptr
		move.l     p_line(a6),line_ptr
		move.l     p_bitblt(a6),bitblt_ptr
		move.l     p_unknown1(a6),unknown1_ptr
		move.l     p_escapes(a6),escape_ptr
		move.l     p_expblt(a6),expblt_ptr
		move.l     p_textblt(a6),textblt_ptr
		move.l     p_gtext(a6),gtext_ptr
		move.l     #fbox,p_fbox(a6)
		move.l     #hline,p_hline(a6)
		move.l     #fline,p_fline(a6)
		move.l     #vline,p_vline(a6)
		move.l     #line,p_line(a6)
		move.l     #bitblt,p_bitblt(a6)
		move.l     #funknown1,p_unknown1(a6)
		move.l     #expblt,p_expblt(a6)
		move.l     #textblt,p_textblt(a6)
		move.l     #gtext,p_gtext(a6)
		move.l     #v_escape,p_escapes(a6)
		move.l     global_itable(pc),wk_itab(a6)
		move.l     #16777216,d0
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
		movea.l    V_CUR_AD.w,a1
		movea.w    BYTES_LIN.w,a2
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
		addi.l     #0x00010001,d3
		swap       d3
		move.l     d3,(a4)
		move.w     #2,v_nintout(a0)
		rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:
		addq.w     #1,hid_cnt
		bclr       #CURSOR_STATE,V_STAT_0.w
		bra        clear_screen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:
		clr.l      V_CUR_XY0.w
		move.l     v_bas_ad.w,V_CUR_AD.w
		move.l     #vt_con0,mycon_state
		bsr        clear_screen
		bclr       #CURSOR_STATE,V_STAT_0.w
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

calc_screenadr:
		movem.l    d0-d1,-(a7)
		move.l     d2,d1
		move.l     v_cel_wr(pc),d0
		bsr.w      _ulmul
		move.l     d1,d2
		movem.l    (a7)+,d0-d1
		rts

_ulmul:
		movem.l    d3-d4,-(a7)
		move.w     d0,d2
		move.w     d1,d3
		move.w     d1,d4
		swap       d0
		swap       d1
		mulu.w     d2,d4
		mulu.w     d0,d3
		mulu.w     d1,d2
		mulu.w     d1,d0
		moveq.l    #0,d1
		add.l      d3,d2
		addx.w     d1,d1
		swap       d1
		add.l      d1,d0
		move.l     d2,d1
		clr.w      d2
		swap       d2
		add.l      d2,d0
		moveq.l    #0,d2
		swap       d1
		clr.w      d1
		add.l      d4,d1
		addx.l     d2,d0
		movem.l    (a7)+,d3-d4
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Rechteck'

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
		movea.l    v_bas_ad.w,a0
		movea.l    f_pointer(a6),a1
		move.w     f_planes(a6),d5
		move.w     f_interior(a6),d7
		move.w     wr_mode(a6),d6
		movea.w    BYTES_LIN.w,a2
		dc.w       0x41bf,60 ; mecnvdi 60
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
hline:
		move.w     wr_mode(a6),d6
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d5
		dc.w       0x41bf,56 ; mecnvdi 56
		rts

;horizontale Linie mit Fuellmuster ohne Clipping zeichnen
;Vorgaben:
;Register d0-d2/d4-d7/a1 koennen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y
;d2.w x2
;d7.w Schreibmodus
;a6.l Workstation
;Ausgaben:
;-
fline:
		move.l     a0,-(a7)
		move.w     f_planes(a6),d5
		move.w     f_interior(a6),d7
		move.w     wr_mode(a6),d6
		movea.l    f_pointer(a6),a0
		move.w     BYTES_LIN.w,d3
		movea.l    v_bas_ad.w,a1
		dc.w       0x41bf,59 ; mecnvdi 59
		movea.l    (a7)+,a0
		rts

;vertikale Linie ohne Clipping zeichnen
;Vorgaben:
;Register d0-d7/a1 koennen veraendert werden
;Eingaben:
;d0.w x
;d1.w y1
;d3.w y2
;d6.w Linienmuster
;d7.w Schreibmodus
;a6.l Workstation
;Ausgaben:
;-
vline:
		move.w     wr_mode(a6),d6
		movea.l    v_bas_ad.w,a1
		move.w     BYTES_LIN.w,d5
		dc.w       0x41bf,57 ; mecnvdi 57
		rts

;schraege Linie ohne Clipping zeichnen
;Vorgaben:
;Register d0-d7/a1 koennen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;d6.w Linienmuster
;d7.w Schreibmodus
;a6.l Workstation
;Ausgaben:
;-
line:
		movem.l    a2-a3,-(a7)
		movea.w    wr_mode(a6),a3
		movea.l    v_bas_ad.w,a1
		movea.w    BYTES_LIN.w,a2
		dc.w       0x41bf,58 ; mecnvdi 58
		movem.l    (a7)+,a2-a3
		rts

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
		movem.w    (a7)+,d6-d7 ; WTF? BUG?
		movea.l    r_saddr(a6),a0
		movea.l    r_daddr(a6),a1
		movea.w    r_swidth(a6),a2
		movea.w    r_dwidth(a6),a3
		move.l     r_fg_pixel(a6),d6
		ror.w      #8,d6
		swap       d6
		ror.w      #8,d6
		move.l     r_bg_pixel(a6),d7
		ror.w      #8,d7
		swap       d7
		ror.w      #8,d7
		movea.w    r_wmode(a6),a5
		dc.w       0x41bf,62 ; mecnvdi 62
		rts

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
		move.l     r_fg_pixel(a6),d6
		ror.w      #8,d6
		swap       d6
		ror.w      #8,d6
		move.l     r_bg_pixel(a6),d7
		ror.w      #8,d7
		swap       d7
		ror.w      #8,d7
		movea.w    wr_mode(a6),a5
		dc.w       0x41bf,62 ; mecnvdi 62
		rts

text_default:
		movea.l    gtext_ptr(pc),a4
		jsr        (a4)
		rts
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
		move.w     v_nintin(a1),d0
		cmp.w      #1024,d0
		bhi.s      text_default
		move.w     t_number(a6),d1
		subq.w     #1,d1
		or.b       t_grow(a6),d1
		or.w       t_rotation(a6),d1
		bne.s      text_default
		moveq.l    #16,d2
		sub.w      t_cheight(a6),d2
		bne.s      text_default
		or.w       t_effects(a6),d2
		bne.s      text_default
		movea.l    font_image(pc),a0
		movea.l    v_bas_ad.w,a4
		movea.w    BYTES_LIN.w,a5
		move.w     wr_mode(a6),d5
		movem.l    d0-d2/a0-a3,-(a7)
		move.l     wk_itab(a6),-(a7)
		movea.l    nvdi_struct(pc),a3
		move.l     wk_px_format(a6),d1
		lea.l      t_fg_colorrgb(a6),a0
		movea.l    wk_ctab(a6),a1
		move.w     t_color(a6),d0
		bpl.s      gtext1
		movea.l    _nvdi_color2value(a3),a3
		move.l     d1,d0
		jsr        (a3)
		move.l     d0,d6
		move.l     wk_px_format(a6),d0
		lea.l      t_bg_colorrgb(a6),a0
		movea.l    wk_ctab(a6),a1
		jsr        (a3)
		move.l     d0,d7
		bra.s      gtext3
gtext1:
		movea.l    _nvdi_color2pixel(a3),a3
		jsr        (a3)
		move.l     gdos_buffer(a6),d1
		cmpi.w     #MD_ERASE-1,wr_mode(a6)
		bne.s      gtext2
		exg        d0,d1
gtext2:
		move.l     d0,d6
		move.l     d1,d7
gtext3:
		addq.l     #4,a7
		movem.l    (a7)+,d0-d2/a0-a3
		ror.w      #8,d6
		swap       d6
		ror.w      #8,d6
		ror.w      #8,d7
		swap       d7
		ror.w      #8,d7
		dc.w       0x41bf,64 ; mecnvdi 64
		rts

funknown1:
		movem.l    a1/a3-a4,-(a7)
		movea.l    unknown1_ptr(pc),a4
		jsr        (a4)
		movem.l    (a7)+,a1/a3-a4
		dc.w       0x41bf,66 ; mecnvdi 66
		rts

bitblt_scale:
		movem.w    (a7),d6-d7
		movem.w    d2-d3,-(a7)
		lea.l      28(a7),a5
		move.l     -(a5),-(a7)
		move.l     -(a5),-(a7)
		move.l     -(a5),-(a7)
		move.l     -(a5),-(a7)
		movea.l    bitblt_ptr(pc),a4
		jsr        (a4)
		lea.l      16(a7),a7
		movem.w    (a7)+,d0-d3
		movea.l    r_daddr(a6),a0
		dc.w       0x41bf,54 ; mecnvdi 54
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
bitblt:
		movem.w    d6-d7,-(a7)
		cmp.w      d4,d6
		bne.s      bitblt_scale
		cmp.w      d5,d7
		bne.s      bitblt_scale
		btst       #4,r_wmode+1(a6)
		bne        expblt
		movea.l    r_saddr(a6),a0
		movea.w    r_swidth(a6),a1
		movea.l    r_daddr(a6),a2
		movea.w    r_dwidth(a6),a3
		movea.w    r_dplanes(a6),a4
		movea.w    r_wmode(a6),a5
		dc.w       0x41bf,63 ; mecnvdi 63
		movem.w    (a7)+,d6-d7
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Bitblocktransfer'

;Bitblocktransfer
;Vorgaben:
;Register d0-a6 duerfen veraendert werden
;Eingaben:
;d0.w xq
;d1.w yq
;d2.w xz
;d3.w yz
;d4.w Breite - 1 (dx)
;d5.w Hoehe - 1 (dy)
;d7.w Verknuepfungsmodus
;a0.l Quellblockadresse
;a1.l Zielblockadresse
;a2.w Bytes pro Quellzeile
;a3.w Bytes pro Zielzeile
;Ausgaben:
;-
bitblt_in:
		movea.l    aes_wk_ptr(pc),a6
		move.w     d7,r_wmode(a6)
		move.l     a0,r_saddr(a6)
		move.l     a1,r_daddr(a6)
		move.w     a2,r_swidth(a6)
		move.w     a3,r_dwidth(a6)
		move.w     r_planes(a6),d6
		move.w     d6,r_splanes(a6)
		move.w     d6,r_dplanes(a6)
		move.w     d4,d6
		move.w     d5,d7
		movea.l    bitblt_ptr(pc),a4
		jmp        (a4)

init_maps:
		move.l     d3,-(a7)
		move.l     d0,d3
		bsr.w      alloc_tables
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
		bsr        set_color_rgb
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

load_nvdipc_inf:
		movem.l    d3/a2-a4,-(a7)
		lea.l      -24(a7),a7
		move.w     d0,d3
		movea.l    a0,a4
		lea.l      nvdipc_inf,a1
		lea.l      (a7),a0
		moveq.l    #nvdipc_inf_end-nvdipc_inf-1,d1
load_nvdipc_inf1: 
		move.b     (a1)+,(a0)+
		dbf        d1,load_nvdipc_inf1
		bsr.w      dgetdrv
		add.b      #'A',d0
		move.b     d0,(a7)
		lea.l      20(a7),a1
		lea.l      (a7),a0
		movea.l    nvdi_struct,a2
		movea.l    _nvdi_load_file(a2),a2
		jsr        (a2)
		movea.l    a0,a2
		move.l     a2,d0
		beq.s      load_nvdipc_inf4
		lea.l      48(a2),a3
		move.w     d3,d1
		ext.l      d1
		add.l      d1,d1
		move.w     16(a2,d1.l),d2
		bmi.s      load_nvdipc_inf2
		ext.l      d2
		move.l     d2,d0
		lsl.l      #2,d0
		add.l      d2,d0
		add.l      d0,d0
		adda.l     d0,a3
		move.w     6(a3),(a4) /* x_res */
		move.w     8(a3),2(a4) /* y_res */
		bra.s      load_nvdipc_inf3
load_nvdipc_inf2:
		move.w     #640-1,(a4)
		move.w     #400-1,2(a4)
load_nvdipc_inf3:
		movea.l    a2,a0
		movea.l    nvdi_struct,a1
		movea.l    _nvdi_Mfree_sys(a1),a1
		jsr        (a1)
		bra.s      load_nvdipc_inf5
load_nvdipc_inf4:
		move.w     #640-1,(a4)
		move.w     #400-1,2(a4)
load_nvdipc_inf5:
		clr.w      d0
		lea.l      24(a7),a7
		movem.l    (a7)+,d3/a2-a4
		rts

dgetdrv:
		pea.l      (a2)
		move.w     #25,-(a7) ; Dgetdrv
		trap       #1
		addq.w     #2,a7
		movea.l    (a7)+,a2
		rts

	.data

dev_name:
		dc.b '16M Farben',0
		.even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungs-Information'
relokation:
                  DC.W 0
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nvdipc_inf:
	dc.b 'C:',$5c,'AUTO',$5c,'NVDIPC.INF',0
nvdipc_inf_end:
	.even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS


nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L  1

hline_ptr:        ds.l  1
fline_ptr:        ds.l  1
vline_ptr:        ds.l  1
line_ptr:         ds.l  1
fbox_ptr:         ds.l  1
escape_ptr:       ds.l  1
unknown1_ptr:     ds.l  1
bitblt_ptr:       ds.l  1
expblt_ptr:       ds.l  1
textblt_ptr:      ds.l  1
gtext_ptr:        ds.l  1

font_image:       ds.l 1

bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab
xbios_tab:        DS.L 2                  ;alte NVDI-XBios-Vektoren

hid_cnt:          ds.w 1
mycon_state:      ds.l 1
v_cel_wr:         ds.l 1
save_vt52_vec:    ds.l 1
linea_save:       ds.w 25
save_v_bas_ad:    ds.l 1

aes_wk_ptr:       DS.L 1                  ;Zeiger auf die AES-Workstation

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 4*16*16

xbios_rez:        ds.w 1

/* structure; must remain in order */
x_res:            ds.w 1                  ;adressierbare Rasterbreite (von 0 aus)
y_res:            ds.w 1                  ;adressierbare Rasterhoehe (von 0 aus)
pixw:             DS.W 1                  ;Pixelbreite in Mikrometern
pixh:             DS.W 1                  ;Pixelhoehe in Mikrometern
screen_ptr:       ds.l 1
line_width:       ds.w 1                  ;Bytes pro Pixelzeile
in_con:           ds.b 1
	even
global_ctable:    ds.l 1
global_itable:    ds.l 1
