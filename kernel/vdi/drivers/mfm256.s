;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*              8-Plane-Bildschirmtreiber fuer NVDI 3.0                       *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ; 'Header'

VERSION           EQU $0313

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"

.INCLUDE "..\include\pixmap.inc"

PATTERN_LENGTH    EQU (32*8)              ;Fuellmusterlaenge bei 8 Ebenen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'NVDI-Treiber initialisieren'
                  TEXT

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
organisation:     DC.L  256               ;Farben
                  DC.W  8                 ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  1                 ;Bitverteilung
                  DC.W  0,0,0             ;reserviert
header_end:


continue:         rts

;Treiber initialisieren
;Vorgaben:
;nur Register d0 wird veraendert
;Eingaben:
;d1.l pb
;a0.l Zeiger auf nvdi_struct
;a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
;Ausgaben:
;d0.l Laenge der Workstation oder 0L bei einem Fehler
init:             movem.l  d0-d2/a0-a2,-(sp)
                  bsr      make_relo      ;Treiber relozieren

                  move.l   a0,nvdi_struct
                  move.l   a1,driver_struct
                  move.l   _nvdi_aes_wk(a0),aes_wk_ptr ;Zeiger auf die AES-Workstation
                  
                  movea.l  nvdi_struct,a0
                  movea.l  _nvdi_load_NOD_driver(a0),a2
                  lea      organisation,a0
                  jsr      (a2)           ;DRIVER  *load_NOD_driver( ORGANISATION *info );
                  movea.l  driver_struct,a1

                  move.l   a0,driver_offscreen(a1) ;kein Treiber vorhanden?
                  beq.s    init_err
                  
                  bsr      save_screen_vecs
      

                  movem.l  d0-a6,-(sp)
                  bsr      set_screen_vecs

                  moveq    #8,d0          ;8 Bit Rot-Anteil
                  moveq    #8,d1          ;8 Bit Gruen-Anteil
                  moveq    #8,d2          ;8 Bit Blau-Anteil
                  bsr      init_rgb_tabs
                  bsr      build_exp      ;Expandier-Tabelle erstellen
                  bsr      build_color_maps  ;Farbcodierungstabellen erstellen
                  bsr      init_hardware  ;Hardware initialisieren
                  bsr      init_res       ;VDI-Variablen initialisieren
                  bsr      init_vt52      ;Daten fuer VT52
                  movem.l  (sp)+,d0-a6

init_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  move.l   #WK_LENGTH+PATTERN_LENGTH,d0 ;Laenge einer Workstation
                  rts

init_err:         movem.l  (sp)+,d0-d2/a0-a2
                  moveq    #0,d0          ;Fehler aufgetreten
                  rts

;Treiber entfernen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;a0.l Zeiger auf nvdi_struct
;a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
Ausgaben:
;-
reset:            movem.l  d0-d2/a0-a2,-(sp)
                  movea.l  _nvdi_unload_NOD_driver(a0),a2
                  movea.l  driver_offscreen(a1),a0 ;Offscreen-Treiber entfernen
                  jsr      (a2)           ;WORD unload_NOD_driver( DRIVER *drv );
                  bsr      reset_screen_vecs
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

save_screen_vecs: movea.l  nvdi_struct,a0

                  movea.l  _nvdi_mouse_tab(a0),a1 ;Adresse der Maustabelle
                  lea      mouse_tab,a2
                  REPT 3
                  move.l   (a1)+,(a2)+
                  ENDM

                  movea.l  _nvdi_bios_tab(a0),a1
                  lea      bios_tab,a2
                  REPT 5
                  move.l   (a1)+,(a2)+
                  ENDM
                  rts

set_screen_vecs:  movea.l  nvdi_struct,a0

                  movea.l  _nvdi_mouse_tab(a0),a1 ;Adresse der Maustabelle
                  move.l   #mouse_len,_mouse_buffer(a1) ;Adresse des Redraw-Buffers
                  move.l   #draw_sprite,_draw_spr_vec(a1) ;Routine zum Sprite-Zeichnen
                  move.l   #undraw_sprite,_undraw_spr_vec(a1) ;Routine zum Sprite-Redraw

                  movea.l  _nvdi_bios_tab(a0),a1

                  move.l   #V_HID_CNT.w,_cursor_cnt_vec(a1) ;Zeiger auf den Hide-Counter
                  move.l   #vbl_cursor,_cursor_vbl_vec(a1)  ;Zeiger auf Cursor-Routine im VBL
                  move.l   #con_state,_vt52_vec_vec(a1)     ;eigenen VT52-Vektor eintragen
                  move.l   #vt_con,_con_vec(a1)             ;Routine fuer CON-Ausgaben
                  move.l   #vt_rawcon,_rawcon_vec(a1)       ;Routine fuer RAW-Ausgaben
                  rts
                  
reset_screen_vecs:   movea.l  nvdi_struct,a0

                  movea.l  _nvdi_mouse_tab(a0),a1 ;Adresse der Maustabelle
                  lea      mouse_tab,a2
                  REPT 3
                  move.l   (a2)+,(a1)+
                  ENDM

                  movea.l  _nvdi_bios_tab(a0),a1
                  lea      bios_tab,a2
                  REPT 5
                  move.l   (a2)+,(a1)+
                  ENDM
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
get_opnwkinfo:    movem.l  d0/a0-a2,-(sp)
                  move.w   x_res,(a0)+    ;adressierbare Rasterbreite
                  move.w   y_res,(a0)+    ;adressierbare Rasterhoehe
                  clr.w    (a0)+          ;genaue Skalierung moeglich !
                  move.l   pixw,(a0)+     ;Pixelbreite/Pixelhoehe
                  moveq    #39,d0         ;40 Elemente kopieren
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_opnwk_work_out(a2),a2
                  lea      10(a2),a2      ;work_out + 5
work_out_int:     move.w   (a2)+,(a0)+
                  dbra     d0,work_out_int
                     
                  move.w   #256,26-90(a0) ;work_out[13]: Anzahl der Farben
                  move.w   #1,70-90(a0)   ;work_out[35]: Farbe ist vorhanden
                  move.w   #0,78-90(a0)   ;work_out[39]: mehr als 32767 Farbabstufungen in der Palette

                  moveq    #11,d0         
work_out_pts:     move.w   (a2)+,(a1)+
                  dbra     d0,work_out_pts
                  movem.l  (sp)+,d0/a0-a2
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
get_extndinfo:    movem.l  d0/a0-a2,-(sp)
                  moveq    #44,d0         ;45 Elemente kopieren
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_extnd_work_out(a2),a2
ext_out_int:      move.w   (a2)+,(a0)+
                  dbra     d0,ext_out_int

                  move.w   #0,2-90(a0)    ;work_out[1]: mehr als 32767 Farbabstufungen
                  move.w   #8,8-90(a0)    ;work_out[4]: Anzahl der Farbebenen
                  move.w   #1,10-90(a0)   ;work_out[5]: CLUT vorhanden
                  move.w   #2200,12-90(a0)   ;work_out[6]: Anzahl der Rasteroperationen
                  move.w   #1,38-90(a0)   ;work_out[19]: Clipping an

                  moveq    #11,d0         
ext_out_pts:      move.w   (a2)+,(a1)+
                  dbra     d0,ext_out_pts
                  lea      clip_xmin(a6),a2
                  move.l   (a2)+,0-24(a1)    ;work_out[45/46]: clip_xmin/clip_ymin
                  move.l   (a2)+,4-24(a1)    ;work_out[47/48]: clip_xmax/clip_ymax

                  movem.l  (sp)+,d0/a0-a2
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
get_scrninfo:     movem.l  d0-d1/a0-a1,-(sp)
                  moveq    #8,d0          ;8 Bits pro Farbintensitaet

scrninfo_clut:    move.w   #2,(a0)+       ;[0] Packed Pixel
                  move.w   #1,(a0)+       ;[1] Hardware-CLUT
                  move.w   #8,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #256,(a0)+     ;[3/4] Farbanzahl
                  move.w   BYTES_LIN.w,(a0)+ ;[5] Bytes pro Zeile
                  move.l   v_bas_ad.w,(a0)+  ;[6/7] Bildschirmadresse
                  move.w   d0,(a0)+       ;[8]  Bits der Rot-Intensitaet
                  move.w   d0,(a0)+       ;[9]  Bits der Gruen-Intensitaet
                  move.w   d0,(a0)+       ;[10] Bits der Blau-Intensitaet
                  move.w   #0,(a0)+       ;[11] kein Alpha-Channel
                  move.w   #0,(a0)+       ;[12] kein Genlock
                  move.w   #0,(a0)+       ;[13] keine unbenutzten Bits
                  move.w   #1,(a0)+       ;[14] Bitorganisation
                  clr.w    (a0)+          ;[15] unbenutzt

                  move.w   #255,d0
                  lea      color_map,a1
scrninfo_loop:    moveq    #0,d1
                  move.b   (a1)+,d1
                  move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Farbpalette'

;Farbtabelle
palette_data:
DC.w $7fff, $7800, $0380, $7fe0, $001e, $70d3, $0f37, $6f7b
DC.w $4210, $4000, $0200, $5a87, $0010, $4010, $0210, $0c63
DC.w $0006, $000c, $0013, $0019, $001f, $00c0, $00c6, $00cc
DC.w $00d3, $00d9, $00df, $0180, $0186, $018c, $0193, $0199
DC.w $019f, $0260, $0266, $026c, $0273, $0279, $027f, $0320
DC.w $0326, $032c, $0333, $0339, $033f, $03e0, $03e6, $03ec
DC.w $03f3, $03f9, $03ff, $1800, $1806, $180c, $1813, $1819
DC.w $181f, $18c0, $18c6, $18cc, $0018, $18d9, $18df, $1980
DC.w $1986, $198c, $1993, $1999, $199f, $1a60, $1a66, $1a6c
DC.w $1a73, $1a79, $1a7f, $1b20, $1b26, $1b2c, $1b33, $1b39
DC.w $1b3f, $1be0, $1be6, $1bec, $1bf3, $1bf9, $1bff, $3000
DC.w $3006, $300c, $3013, $3019, $301f, $30c0, $30c6, $30cc
DC.w $30d3, $30d9, $30df, $3180, $3186, $318c, $3193, $3199
DC.w $319f, $3260, $3266, $326c, $3273, $3279, $327f, $3320
DC.w $3326, $332c, $3333, $3339, $333f, $33e0, $33e6, $33ec
DC.w $33f3, $33f9, $33ff, $4c00, $4c06, $4c0c, $4c13, $4c19
DC.w $4c1f, $4cc0, $4cc6, $4ccc, $4cd3, $4cd9, $4cdf, $4d80
DC.w $4d86, $4d8c, $4d93, $4d99, $4d9f, $4e60, $4e66, $4e6c
DC.w $4e73, $4e79, $4e7f, $4f20, $4f26, $4f2c, $4f33, $4f39
DC.w $4f3f, $4fe0, $4fe6, $4fec, $4ff3, $4ff9, $4fff, $6400
DC.w $6406, $640c, $6413, $6419, $641f, $64c0, $64c6, $64cc
DC.w $64d3, $64d9, $64df, $6580, $6586, $658c, $6593, $6599
DC.w $659f, $6660, $6666, $666c, $6673, $6679, $667f, $6720
DC.w $6726, $672c, $6733, $6739, $673f, $67e0, $67e6, $67ec
DC.w $67f3, $67f9, $67ff, $7c00, $7c06, $7c0c, $7c13, $7c19
DC.w $7c1f, $7cc0, $7cc6, $7ccc, $7cd3, $7cd9, $7cdf, $7d80
DC.w $7d86, $7d8c, $7d93, $7d99, $7d9f, $7e60, $7e66, $7e6c
DC.w $7e73, $7e79, $7e7f, $7f20, $7f26, $7f2c, $7f33, $7f39
DC.w $7f3f, $7fe0, $7fe6, $7fec, $7ff3, $7ff9, $7800, $7000
DC.w $6000, $5800, $4000, $2400, $0c00, $03c0, $0380, $0300
DC.w $02c0, $0200, $0120, $0060, $0003, $0009, $0010, $0016
DC.w $18d3, $001c, $7bde, $739c, $6318, $5ad6, $2529, $0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungsroutine'
make_relo:        movem.l  d0-d2/a0-a2,-(sp)
                  DC.W $a000
                  sub.w    #CMP_BASE,d0   ;Differenz der Line-A-Adressen
                  beq.s    relo_exit      ;keine Relokation noetig ?
                  lea      start(pc),a0   ;Start des Textsegments
                  lea      relokation,a1  ;Relokationsinformation

relo_loop:        move.w   (a1)+,d1       ;Adress-Offset
                  beq.s    relo_exit
                  adda.w   d1,a0
                  add.w    d0,(a0)        ;relozieren
                  bra.s    relo_loop
relo_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'GEMDOS\BIOS\XBIOS'

; OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
v_curtext:        movem.l  d1-d3/a2-a3,-(sp)
                  movea.l  pb_intin(a0),a3 ;intin
                  move.w   v_nintin(a1),d3 ;Zeichenanzahl
                  subq.w   #1,d3          ;zu wenig Zeichen ?
                  bmi.s    v_curtext_exit
v_curtext_loop:   move.w   (a3)+,d1          ;Zeichen
                  movea.l  con_state.w,a0    ;Sprungadresse
                  jsr      (a0)
                  dbra     d3,v_curtext_loop
v_curtext_exit:   movem.l  (sp)+,d1-d3/a2-a3
                  rts

;Cursor positionieren
;Eingabe
;d0 Textspalte
;d1 Textzeile
;Ausgabe
;a1 Cursoradresse
;zerstoert werden d0-d2
set_cursor_xy:    bsr.s    cursor_off
set_cur_clipx1:   move.w   V_CEL_MX.w,d2
                  tst.w    d0
                  bpl.s    set_cur_clipx2
                  moveq    #0,d0
set_cur_clipx2:   cmp.w    d2,d0
                  ble.s    set_cur_clipy1
                  move.w   d2,d0
set_cur_clipy1:   move.w   V_CEL_MY.w,d2
                  tst.w    d1
                  bpl.s    set_cur_clipy2
                  moveq    #0,d1
set_cur_clipy2:   cmp.w    d2,d1
                  ble.s    set_cursor
                  move.w   d2,d1
set_cursor:       movem.w  d0-d1,V_CUR_XY0.w
                  movea.l  v_bas_ad.w,a1
                  mulu     V_CEL_WR.w,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  lsl.w    #3,d0
                  adda.w   d0,a1          ;Zieladresse
                  move.l   a1,V_CUR_AD.w
                  bra.s    cursor_on

;Cursor ausschalten
cursor_off:       addq.w   #1,V_HID_CNT.w ;Hochzaehlen
                  cmpi.w   #1,V_HID_CNT.w
                  bne.s    cursor_off_exit
                  bclr     #CURSOR_STATE,V_STAT_0.w ;Cursor sichtbar ?
                  bne.s    cursor
cursor_off_exit:  rts

;Cursor einschalten
cursor_on:        cmpi.w   #1,V_HID_CNT.w
                  bcs.s    cursor_on_exit2
                  bhi.s    cursor_on_exit1
                  move.b   V_PERIOD.w,V_CUR_CT.w
                  bsr.s    cursor
                  bset     #CURSOR_STATE,V_STAT_0.w ;Cursor sichtbar
cursor_on_exit1:  subq.w   #1,V_HID_CNT.w
cursor_on_exit2:  rts

vbl_cursor:       btst     #CURSOR_BL,V_STAT_0.w ;Blinken ein ?
                  beq.s    vbl_no_bl
                  bchg     #CURSOR_STATE,V_STAT_0.w
                  bra.s    cursor
vbl_no_bl:        bset     #CURSOR_STATE,V_STAT_0.w
                  beq.s    cursor
                  rts

;Cursor zeichnen
cursor:           movem.l  d0-d1/a1/a4-a5,-(sp)

                  moveq    #16,d0
                  sub.w    V_CEL_HT.w,d0
                  add.w    d0,d0
                  move.w   d0,d1
                  add.w    d0,d0          ;(16 - Zeichenhoehe) * 6
                  add.w    d1,d0

                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  move.w   BYTES_LIN.w,d1 ;Bytes pro Zeile
                  subq.w   #8,d1
                  jmp      cursor_jmp(pc,d0.w)
cursor_jmp:       REPT 15
                  not.l    (a1)+
                  not.l    (a1)+
                  adda.w   d1,a1
                  ENDM
                  not.l    (a1)+
                  not.l    (a1)+

                  movem.l  (sp)+,d0-d1/a1/a4-a5
cursor_exit:      rts

;BEL, Klingelzeichen
vt_bel:           btst     #2,conterm.w   ;Glocke an ?
                  beq.s    cursor_exit
                  movea.l  bell_hook.w,a0
                  jmp      (a0)

                  DC.L 'XBRA'
                  DC.L 'NVDI'
                  DC.L 0
;Glocke erzeugen
make_pling:       pea      pling(pc)      ;Sequenz fuer Yamaha-Chip
                  move.w   #DOSOUND,-(sp)
                  trap     #XBIOS
                  addq.l   #6,sp
                  rts
pling:            DC.B $00,$34,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
                  DC.B $08,$10,$09,$00,$0a,$00,$0b,$00,$0c,$10,$0d,$09,$ff,$00


;BACKSPACE, ein Zeichen zurueck
;d0 Textspalte
;d1 Textzeile
vt_bs:            movem.w  V_CUR_XY0.w,d0-d1
                  subq.w   #1,d0          ;eine Spalte zurueck
                  bra      set_cursor_xy

;HT
;d0 Textspalte
;d1 Textzeile
vt_ht:            andi.w   #$fff8,d0      ;maskieren
                  addq.w   #8,d0          ;naechster Tabulator
                  bra      set_cursor_xy
;LINEFEED, naechste Zeile
;d1 Textzeile
vt_lf:            pea      cursor_on(pc)
                  bsr      cursor_off
                  sub.w    V_CEL_MY.w,d1
                  beq      scroll_up_page
                  move.w   V_CEL_WR.w,d1  ;d1: High-Word=0 ! (durch movem.w)
                  add.l    d1,V_CUR_AD.w  ;naechste Textzeile
                  addq.w   #1,V_CUR_XY1.w
                  rts
;RETURN, Zeilenanfang
;d0 Textspalte
vt_cr:            bsr      cursor_off
                  pea      cursor_on(pc)
                  movea.l  V_CUR_AD.w,a1

;Cursor an den Zeilenanfang setzen
;Eingabe
;d0 Cursorspalte
;a1 Cursoradresse
;Ausgabe
;a1 neue Cursoradresse
;zerstoert werden d0/d2
set_x0:           lsl.w    #3,d0
                  suba.w   d0,a1
                  move.l   a1,V_CUR_AD.w
                  clr.w    V_CUR_XY0.w
                  rts

;ESC
vt_esc:           move.l   #vt_esc_seq,con_state.w ;Sprungadresse
                  rts

vt_control:       cmpi.w   #27,d1
                  beq.s    vt_esc
                  subq.w   #7,d1
                  subq.w   #6,d1
                  bhi.s    vt_c_exit
                  move.l   #vt_con,con_state.w ;Sprungadresse
                  add.w    d1,d1
                  move.w   vt_c_tab(pc,d1.w),d2
                  movem.w  V_CUR_XY0.w,d0-d1 ;Textspalte/-zeile
                  jmp      vt_c_tab(pc,d2.w)
vt_c_exit:        rts

                  DC.W vt_bel-vt_c_tab    ;7  BEL
                  DC.W vt_bs-vt_c_tab     ;8  BS
                  DC.W vt_ht-vt_c_tab     ;9  HT
                  DC.W vt_lf-vt_c_tab     ;10 LF
                  DC.W vt_lf-vt_c_tab     ;11 VT
                  DC.W vt_lf-vt_c_tab     ;12 FF
vt_c_tab:         DC.W vt_cr-vt_c_tab     ;13 CR


vt_char_rcol:     movem.l  d3-d7,-(sp)
                  lea      V_COL_BG+1.w,a2
                  movep.w  0(a2),d6
                  move.b   (a2)+,d6
                  move.w   d6,d4
                  swap     d6
                  move.w   d4,d6          ;Maske fuer die Hintergrundfarbe
                  movep.w  1(a2),d5
                  move.b   1(a2),d5
                  move.w   d5,d3
                  swap     d5
                  move.w   d3,d5          ;Maske fuer die Vordergrundfarbe
                  not.l    d5
                  not.l    d6
                  bra.s    vt_char_col2

vt_con:           cmpi.w   #32,d1         ;Steuerzeichen ?
                  blt.s    vt_control
vt_rawcon:        movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  move.w   BYTES_LIN.w,d2 ;Bytes pro Zeile
                  subq.w   #8,d2
                  move.b   #2,V_CUR_CT.w  ;Zaehler auf 2 -> keinen Cursor zeichnen
                  bclr     #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
                  move.l   V_FNT_AD.w,d0  ;Fontimageadresse
                  btst     #CURSOR_INVERSE,V_STAT_0.w ;invertieren ?
                  bne      vt_char_rcol

vt_char_col:      movem.l  d3-d7,-(sp)
                  lea      V_COL_BG+1.w,a2
                  movep.w  0(a2),d6
                  move.b   (a2)+,d6
                  move.w   d6,d4
                  swap     d6
                  move.w   d4,d6          ;Maske fuer die Hintergrundfarbe
                  movep.w  1(a2),d5
                  move.b   1(a2),d5
                  move.w   d5,d3
                  swap     d5
                  move.w   d3,d5          ;Maske fuer die Vordergrundfarbe

vt_char_col2:     movea.l  d0,a0
                  adda.w   d1,a0
                  move.w   V_FNT_WD.w,d0
                  move.w   V_CEL_HT.w,d1
                  subq.w   #1,d1          ;Zeilenzaehler
                  lea      expand_tab,a2

vt_char_cloop:    moveq    #0,d7
                  move.b   (a0),d7
                  lsl.w    #3,d7
                  move.l   0(a2,d7.w),d3
                  move.l   d3,d4
                  not.l    d4
                  and.l    d5,d3          ;Vordergrundfarbe
                  and.l    d6,d4          ;Hintergrundfarbe
                  or.l     d4,d3
                  move.l   d3,(a1)+
                  move.l   4(a2,d7.w),d3
                  move.l   d3,d4
                  not.l    d4
                  and.l    d5,d3
                  and.l    d6,d4
                  or.l     d4,d3
                  move.l   d3,(a1)+
                  adda.w   d0,a0
                  adda.w   d2,a1
                  dbra     d1,vt_char_cloop

                  movem.l  (sp)+,d3-d7
vt_n_column:      move.w   V_CUR_XY0.w,d0
                  cmp.w    V_CEL_MX.w,d0  ;letzte Spalte ?
                  bge.s    vt_l_column
                  addq.l   #8,V_CUR_AD.w  ;naechste Spalte
                  addq.w   #1,V_CUR_XY0.w
                  moveq    #-1,d0         ;alles OK fuer MiNT
                  rts
vt_l_column:      btst     #CURSOR_WRAP,V_STAT_0.w ;Wrapping ein ?
                  beq.s    vt_con_exit
                  addq.w   #1,V_HID_CNT.w ;Cursor sperren
vt_l_column2:     ext.l    d0
                  lsl.l    #3,d0
                  sub.l    d0,V_CUR_AD.w  ;Zeilenanfang (d0: High-Word=0 !)
                  clr.w    V_CUR_XY0.w
                  move.w   V_CUR_XY1.w,d1
                  pea      vt_con_exit2(pc)
                  cmp.w    V_CEL_MY.w,d1  ;letzte Zeile (Scrolling) ?
                  bge      scroll_up_page
                  addq.l   #4,sp          ;Stack korrigieren
                  move.w   V_CEL_WR.w,d0  ;Bytes pro Textzeile (d0: High-Word=0!)
                  add.l    d0,V_CUR_AD.w  ;naechste Textzeile
                  addq.w   #1,V_CUR_XY1.w
vt_con_exit2:     subq.w   #1,V_HID_CNT.w ;Cursor zulassen
vt_con_exit:      rts

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq:       cmpi.w   #89,d1         ;ESC Y ?
                  beq      vt_seq_Y
                  move.w   d1,d2

                  movem.w  V_CUR_XY0.w,d0-d1 ;Textspalte/-zeile
                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  movea.w  BYTES_LIN.w,a2 ;Bytes pro Zeile
                  move.l   #vt_con,con_state.w ;Sprungadresse

vt_seq_tA:        subi.w   #65,d2         ;>=65 & <= 77 ?
                  cmpi.w   #12,d2
                  bhi.s    vt_seq_tb
                  add.w    d2,d2
                  move.w   vt_seq_tab1(pc,d2.w),d2
                  jmp      vt_seq_tab1(pc,d2.w)

vt_seq_tb:        subi.w   #33,d2         ;>=98 & <= 119 ?
                  cmpi.w   #21,d2
                  bhi.s    vt_seq_exit
                  add.w    d2,d2
                  move.w   vt_seq_tab2(pc,d2.w),d2
                  jmp      vt_seq_tab2(pc,d2.w)
;Beendet bei falschen Opcode
vt_seq_exit:      rts

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
vt_seq_A:         subq.w   #1,d1
                  bra      set_cursor_xy
;ALPHA CURSOR DOWN (VDI 5,ESCAPE 5)/ Cursor down (VT52 ESC B)
v_curdown:
vt_seq_B:         addq.w   #1,d1
                  bra      set_cursor_xy
; ALPHA CURSOR RIGHT (VDI 5, ESCAPE 6)/ Cursor right (VT52 ESC C)

v_curright:
vt_seq_C:         addq.w   #1,d0
                  bra      set_cursor_xy
; ALPHA CURSOR LEFT (VDI 5, ESCAPE 7)/ Cursor left (VT52 ESC D)
v_curleft:
vt_seq_D:         subq.w   #1,d0
                  bra      set_cursor_xy
;Clear screen (VT52 ESC E)
vt_seq_E:         bsr      cursor_off
                  bsr      clear_screen
                  bra.s    vt_seq_H_in
; HOME ALPHA CURSOR (VDI 5, ESCAPE 8)/ Home Cursor (VT52 ESC H)
v_curhome:
vt_seq_H:         bsr      cursor_off
vt_seq_H_in:      clr.l    V_CUR_XY0.w
                  movea.l  v_bas_ad.w,a1
                  move.l   a1,V_CUR_AD.w
                  bra      cursor_on
;Cursor up and insert (VT52 ESC I)
vt_seq_I:         pea      cursor_on(pc)
                  bsr      cursor_off
                  subq.w   #1,d1          ;Cursor bereits in der obersten Zeile ?
                  blt      scroll_down_page
                  suba.w   V_CEL_WR.w,a1  ;eine Zeile nach oben
                  move.l   a1,V_CUR_AD.w
                  move.w   d1,V_CUR_XY1.w
                  rts
; ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
v_eeos:
vt_seq_J:         bsr.s    vt_seq_K       ;Bis zum Zeilenende loeschen
                  move.w   V_CUR_XY1.w,d1 ;Textzeile
                  move.w   V_CEL_MY.w,d2  ;maximale Textzeile
                  sub.w    d1,d2          ;Anzahl der zu loeschenden Textzeilen
                  beq.s    vt_seq_J_exit
                  movem.l  d2-d7/a1-a6,-(sp)
                  movea.l  v_bas_ad.w,a1
                  addq.w   #1,d1
                  mulu     V_CEL_WR.w,d1
                  lsr.l    #2,d1
                  adda.l   d1,a1          ;Startadresse
                  move.w   d2,d7
                  mulu     V_CEL_HT.w,d7
                  subq.w   #1,d7          ;Anzahl der zu loeschenden Bildzeilen -1
                  bra      clear_lines    ;Zeilen loeschen/Register zurueck
vt_seq_J_exit:    rts
; ERASE TO END OF ALPHA TEXT LINE (VDI 5, ESCAPE 10)
v_eeol:
;Clear to end of line (VT52 ESC K)
vt_seq_K:         bsr      cursor_off
                  move.w   V_CEL_MX.w,d2
                  sub.w    d0,d2          ;Anzahl der zu loeschenden Zeichen
                  bsr      clear_line_part
                  bra      cursor_on
;Insert line (VT52 ESC I)
vt_seq_L:         pea      cursor_on(pc)
                  bsr      cursor_off
                  bsr      set_x0         ;Cursor an Zeilenanfang
                  movem.l  d2-d7/a1-a6,-(sp) ;Register sichern
                  move.w   V_CEL_MY.w,d5
                  sub.w    d1,d5          ;letzte Zeile ?
                  beq.s    vt_seq_L_exit

                  movea.l  v_bas_ad.w,a0
                  movea.l  a0,a1
                  movea.w  BYTES_LIN.w,a2
                  movea.w  a2,a3
                  move.w   V_CEL_HT.w,d0
                  mulu     d0,d1
                  move.w   d1,d3
                  add.w    d0,d3
                  move.w   V_CEL_MX.w,d4
                  lsl.w    #3,d4
                  addq.w   #7,d4
                  mulu     d0,d5
                  subq.w   #1,d5
                  moveq    #3,d7
                  moveq    #0,d0
                  moveq    #0,d2
                  jsr      bitblt_in
                  movea.l  v_bas_ad.w,a1
                  move.w   V_CUR_XY1.w,d0
                  mulu     V_CEL_WR.w,d0
                  lsr.l    #2,d0
                  adda.l   d0,a1
                  bra      clear_line2

vt_seq_L_exit:    movea.l  V_CUR_AD.w,a1  ;Startadresse
                  bra      clear_line2    ;Zeile loeschen/ Register zurueck

;Delete Line (VT52 ESC M)
vt_seq_M:         pea      cursor_on(pc)
                  bsr      cursor_off
                  bsr      set_x0         ;Cursor an Zeilenanfang
                  movem.l  d2-d7/a1-a6,-(sp) ;Register sichern
                  move.w   V_CEL_MY.w,d7
                  sub.w    d1,d7          ;nur letzte Zeile loeschen ?
                  beq.s    vt_seq_M_last
                  move.w   V_CEL_HT.w,d3
                  moveq    #0,d0
                  mulu     d3,d1
                  moveq    #0,d2
                  add.w    d1,d3
                  exg      d1,d3
                  movem.w  V_CEL_MX.w,d4-d5
                  addq.w   #1,d4
                  lsl.w    #3,d4
                  subq.w   #1,d4
                  mulu     V_CEL_HT.w,d5
                  subq.w   #1,d5
                  sub.w    d1,d5
                  bra      scroll_up2
vt_seq_M_last:    move.l   a1,d0
                  movea.l  v_bas_ad.w,a1
                  sub.l    a1,d0
                  lsr.l    #2,d0
                  adda.l   d0,a1
                  bra      clear_line2

;Set cursor position (VT52 ESC Y)
vt_seq_Y:         move.l   #vt_set_y,con_state.w ;Sprungadresse
                  rts
;y-Koordinate setzen
vt_set_y:         subi.w   #32,d1
                  move.w   V_CUR_XY0.w,d0
                  move.l   #vt_set_x,con_state.w ;Sprungadresse
                  bra      set_cursor_xy
;x-Koordinate setzen
vt_set_x:         subi.w   #32,d1
                  move.w   d1,d0
                  move.w   V_CUR_XY1.w,d1
                  move.l   #vt_con,con_state.w ;Sprungadresse
                  bra      set_cursor_xy

;Foreground color (VT52 ESC b)
vt_seq_b:         move.l   #vt_set_b,con_state.w
                  rts
vt_set_b:         lea      V_COL_FG.w,a1
vt_set_col:       moveq    #$0f,d0
                  and.w    d0,d1          ;ausmaskieren
                  cmp.w    d0,d1
                  bne.s    vt_write_col
                  move.w   #$ff,d1
vt_write_col:     move.w   d1,(a1)
                  move.l   #vt_con,con_state.w ;Sprungadresse
                  rts
;Background color (VT52 ESC c)
vt_seq_c:         move.l   #vt_set_c,con_state.w
                  rts
vt_set_c:         lea      V_COL_BG.w,a1
                  bra.s    vt_set_col
;Erase to start of page (VT52 ESC d)
vt_seq_d:         bsr.s    vt_seq_o       ;ab Zeilenanfang loeschen
                  move.w   V_CUR_XY1.w,d1 ;Textzeile
                  beq.s    vt_seq_d_exit
                  movem.l  d2-d7/a1-a6,-(sp)
                  mulu     V_CEL_HT.w,d1
                  move.w   d1,d7
                  subq.w   #1,d7          ;Zeilenzaehler

                  movea.l  v_bas_ad.w,a1
                  bra      clear_lines    ;loeschen/Register zurueck
vt_seq_d_exit:    rts
;Show cursor (VT52 ESC e)
vt_seq_e:         tst.w    V_HID_CNT.w
                  beq.s    vt_seq_e_exit
                  move.w   #1,V_HID_CNT.w
                  bra      cursor_on
vt_seq_e_exit:    rts
;Hide cursor (VT52 ESC f)
vt_seq_f:         bra      cursor_off
;Save cursor (VT52 ESC j)
vt_seq_j:         bset     #CURSOR_SAVED,V_STAT_0.w
                  move.l   V_CUR_XY0.w,V_SAV_XY.w
                  rts
;Restore cursor (VT52 ESC k)
vt_seq_k:         movem.w  V_SAV_XY.w,d0-d1
                  bclr     #CURSOR_SAVED,V_STAT_0.w
                  bne      set_cursor_xy
                  moveq    #0,d0
                  moveq    #0,d1
                  bra      set_cursor_xy
;Erase line (VT52 ESC l)
vt_seq_l:         bsr      cursor_off
                  bsr      set_x0         ;Zeilenanfang
                  bsr      clear_line
                  bra      cursor_on
;Erase to line start (VT52 ESC o)
vt_seq_o:         move.w   d0,d2
                  subq.w   #1,d2          ;Spaltenanzahl -1
                  bmi.s    vt_seq_o_exit
                  movea.l  v_bas_ad.w,a1
                  mulu     V_CEL_WR.w,d1
                  adda.l   d1,a1          ;Zeilenanfang
                  bra      clear_line_part
vt_seq_o_exit:    rts
;REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
v_rvon:
vt_seq_p:         bset     #CURSOR_INVERSE,V_STAT_0.w
                  rts
; REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
v_rvoff:
vt_seq_q:         bclr     #CURSOR_INVERSE,V_STAT_0.w
                  rts
;Wrap at end of line (VT52 ESC v)
vt_seq_v:         bset     #CURSOR_WRAP,V_STAT_0.w


                  rts
;Discard end of line (VT52 ESC w)
vt_seq_w:         bclr     #CURSOR_WRAP,V_STAT_0.w
                  rts

scroll_up_page:   movem.l  d2-d7/a1-a6,-(sp)
                  moveq    #0,d0
                  move.w   V_CEL_HT.w,d1
                  moveq    #0,d2
                  moveq    #0,d3
                  movem.w  V_CEL_MX.w,d4-d5
                  addq.w   #1,d4
                  lsl.w    #3,d4
                  subq.w   #1,d4
                  mulu     V_CEL_HT.w,d5
                  subq.w   #1,d5
scroll_up2:       moveq    #3,d7
                  movea.l  v_bas_ad.w,a0
                  movea.l  a0,a1
                  movea.w  BYTES_LIN.w,a2
                  movea.w  a2,a3
                  jsr      bitblt_in
                  movea.l  v_bas_ad.w,a1
                  move.w   V_CEL_MY.w,d0
                  mulu     V_CEL_WR.w,d0
                  adda.l   d0,a1
                  bra.s    clear_line2

scroll_down_page: movem.l  d2-d7/a1-a6,-(sp)
                  moveq    #0,d0
                  moveq    #0,d1
                  moveq    #0,d2
                  move.w   V_CEL_HT.w,d3
                  movem.w  V_CEL_MX.w,d4-d5
                  addq.w   #1,d4
                  addq.w   #1,d5
                  lsl.w    #3,d4
                  subq.w   #1,d4
                  mulu     d3,d5
                  subq.w   #1,d5
                  moveq    #3,d7
                  movea.l  v_bas_ad.w,a0
                  movea.l  a0,a1
                  movea.w  BYTES_LIN.w,a2
                  movea.w  a2,a3
                  jsr      bitblt_in
                  movea.l  v_bas_ad.w,a1
                  bra.s    clear_line2

clear_line:       movem.l  d2-d7/a1-a6,-(sp)

;Eingabe
;a1.l Zeilenadresse
clear_line2:      move.w   V_CEL_HT.w,d7
                  subq.w   #1,d7
;d7.w Zeilenzaehler
clear_lines:      lea      V_COL_BG+1.w,a2
                  movep.w  0(a2),d6

                  move.b   (a2),d6
                  move.w   d6,d2
                  swap     d6
                  move.w   d2,d6

                  move.w   V_CEL_MX.w,d4  ;Zeichenanzahl pro Zeile -1

                  move.w   BYTES_LIN.w,d5
                  move.w   d4,d2
                  addq.w   #1,d2
                  lsl.w    #3,d2
                  sub.w    d2,d5

clear_line_bloop: move.w   d4,d2
clear_line_loop:  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  dbra     d2,clear_line_loop
                  adda.w   d5,a1
                  dbra     d7,clear_line_bloop

                  movem.l  (sp)+,d2-d7/a1-a6
                  rts

;Bildschirm loeschen

;Eingaben
; -
;Ausgaben
;kein Register wird zerstoert
clear_screen:     movem.l  d2-d7/a1-a6,-(sp)
                  move.w   V_CEL_MY.w,d7  ;Textzeilenanzahl -1
                  addq.w   #1,d7
                  mulu     V_CEL_HT.w,d7
                  subq.w   #1,d7          ;Zeilenanzahl -1
                  movea.l  v_bas_ad.w,a1
                  bra.s    clear_lines

;Bereich einer Textzeile loeschen
;Eingaben
;d2.w Spaltenanzahl -1
;a1.l Adresse
;a2.w Bytes pro Zeile
;Ausgaben
;d0-d2/a0-a1 werden zerstoert
clear_line_part:  move.l   d3,-(sp)
                  lea      V_COL_BG+1.w,a0
                  movep.w  0(a0),d3
                  move.b   (a0),d3
                  move.w   d3,d0
                  swap     d3
                  move.w   d0,d3

                  move.w   V_CEL_HT.w,d1
                  subq.w   #1,d1          ;Zeilenzaehler

                  move.w   d2,d0
                  addq.w   #1,d0
                  lsl.w    #3,d0
                  movea.w  BYTES_LIN.w,a0
                  suba.w   d0,a0

clear_lpart_bloop:move.w   d2,d0
clear_lpart_loop: move.l   d3,(a1)+
                  move.l   d3,(a1)+
                  dbra     d0,clear_lpart_loop
                  adda.w   a0,a1
                  dbra     d1,clear_lpart_bloop

                  move.l   (sp)+,d3
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'LineA'

;Undraw Sprite ($A00C)
;Eingaben
;a2.l Zeiger auf den Sprite-Save-Block
;Ausgaben
;d2/a1-a5 werden zerstoert
undraw_sprite:    move.w   (a2)+,d2
                  subq.w   #1,d2          ;Sprite-Zeilen - 1 wg. dbf
                  bmi.s    undraw_exit
                  movea.l  (a2)+,a1       ;Zieladresse
                  bclr     #0,(a2)        ;Bereich gesichert ?
                  beq.s    undraw_exit

                  movea.w  BYTES_LIN.w,a3
                  lea      -20(a3),a3
                  addq.l   #2,a2          ;Adresse des Hintergrunds
undraw_spr_loop:  REPT 5
                  move.l   (a2)+,(a1)+
                  ENDM
                  adda.w   a3,a1
                  dbra     d2,undraw_spr_loop

undraw_exit:      rts

;Draw Sprite ($A00D)
;Eingaben
;d0.w x
;d1.w y
;a0.l Zeiger auf die Spritedefinition
;a2.l Zeiger auf den Hintergrundbuffer
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
draw_sprite:      moveq    #15,d2         ;Breite - 1
                  moveq    #15,d3         ;Hoehe - 1

                  move.b   7(a0),d6       ;Hintergrundfarbe
                  move.b   9(a0),d7       ;Vordergrundfarbe

                  sub.w    (a0)+,d0       ;X_Koord - intxhot
                  bpl.s    draw_spr_x2

                  add.w    d0,d2          ;zu zeichnende Breite - 1
                  bmi      draw_spr_exit

draw_spr_x2:      move.w   DEV_TAB0.w,d4  ;WORK_OUT[0] max. Rasterbreite
                  subi.w   #15,d4
                  sub.w    d0,d4
                  bge.s    draw_spr_y

                  add.w    d4,d2          ;zu zeichnende Breite - 1
                  bmi      draw_spr_exit

draw_spr_y:       sub.w    (a0)+,d1       ;Y_Koord - intyhot
                  addq.l   #6,a0          ;Zeiger auf das Sprite-Image
                  bpl.s    draw_spr_y2

                  add.w    d1,d3          ;zu zeichnende Hoehe - 1
                  bmi      draw_spr_exit
                  add.w    d1,d1
                  add.w    d1,d1
                  suba.w   d1,a0          ;Sprite-Start korrigieren
                  moveq    #0,d1

draw_spr_y2:      move.w   DEV_TAB1.w,d5  ;WORK_OUT[0] max. Rasterbreite
                  subi.w   #15,d5
                  sub.w    d1,d5
                  bge.s    draw_spr_save

                  add.w    d5,d3          ;zu zeichnende Hoehe - 1
                  bmi      draw_spr_exit

draw_spr_save:    move.w   d3,(a2)
                  addq.w   #1,(a2)+       ;gespeicherte Zeilenanzahl

                  muls     BYTES_LIN.w,d1
                  movea.l  v_bas_ad.w,a1
                  adda.l   d1,a1          ;Zeilenadresse

                  moveq    #0,d4
                  tst.w    d0             ;ueberschreitet den linken Rand?
                  bmi.s    draw_spr_saddr
                  moveq    #-19,d4
                  add.w    DEV_TAB0.w,d4  ;20 Bytes vom rechten Rand entfernt
                  cmp.w    d0,d4
                  blt.s    draw_spr_saddr
                  moveq    #$fffffffc,d4
                  and.w    d0,d4
draw_spr_saddr:   movea.l  a1,a4          ;Zeilenadresse
                  adda.w   d4,a4          ;+ Langwortposition

                  move.l   a4,(a2)+       ;Adresse des Hintergrunds
                  move.w   #$0100,(a2)+   ;Bereich gesichert
                  movea.w  BYTES_LIN.w,a3
                  lea      -20(a3),a3     ;Abstand zur naechsten Zeile
                  move.w   d3,d5

draw_spr_sloop:   REPT 5
                  move.l   (a4)+,(a2)+
                  ENDM
                  adda.w   a3,a4
                  dbra     d5,draw_spr_sloop

                  movea.w  BYTES_LIN.w,a3
                  suba.w   d2,a3
                  subq.w   #1,a3

                  adda.w   d0,a1
                  cmp.w    #15,d2
                  beq.s    draw_it

                  tst.w    d0
                  bpl.s    draw_it
                  suba.w   d0,a1
                  neg.w    d0
                  bra.s    draw_spr_bloop

draw_it:          moveq    #0,d0

draw_spr_bloop:   move.w   (a0)+,d4       ;Hintergrundmaske
                  move.w   (a0)+,d5       ;Vordergrundmaske
                  lsl.w    d0,d4          ;shiften, falls Mauszeiger am linken Rand
                  lsl.w    d0,d5
                  move.w   d2,d1          ;Breitenzaehler

draw_spr_loop:    add.w    d5,d5          ;Vordergrundbit gesetzt?
                  bcc.s    draw_spr_bg
                  move.b   d7,(a1)+
                  add.w    d4,d4
                  dbra     d1,draw_spr_loop
                  bra.s    draw_spr_next

draw_spr_bg:      add.w    d4,d4
                  bcc.s    draw_spr_nth
                  move.b   d6,(a1)+
                  dbra     d1,draw_spr_loop
                  bra.s    draw_spr_next

draw_spr_nth:     addq.l   #1,a1
                  dbra     d1,draw_spr_loop

draw_spr_next:    adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,draw_spr_bloop

draw_spr_exit:    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Initialisierung'

;Aufloesungsabhaengige Daten initialisieren
;Eingaben
;xres, yres, line_width, pixw, pixh, fonts
;Ausgaben
;kein Register wird zerstoert
init_res:         movem.l  d0-d2/a0-a2,-(sp)
                  movea.l  nvdi_struct(pc),a0
                  movea.l  _nvdi_vdi_setup_ptr(a0),a0

                  move.l   PM_baseAddr(a0),vram
                  move.w   PM_rowBytes(a0),d0
                  and.w    #$1fff,d0
                  move.w   d0,line_width
                  move.w   PM_bounds+R_right(a0),d0
                  sub.w    PM_bounds+R_left(a0),d0
                  subq.w   #1,d0
                  move.w   d0,x_res
                  move.w   PM_bounds+R_bottom(a0),d0
                  sub.w    PM_bounds+R_top(a0),d0
                  subq.w   #1,d0
                  move.w   d0,y_res

                  move.w   #278,pixw
                  move.w   #278,pixh

                  movem.w  x_res,d0-d1    ;xres,yres
                  move.w   line_width,d2  ;Bytes pro Zeile

                  move.l   vram,v_bas_ad.w ;Bildadresse
                  move.w   #8,PLANES.w    ;Anzahl der Bildebenen
                  move.w   d2,WIDTH.w     ;Bytes pro Zeile
                  move.w   d2,BYTES_LIN.w ;Bytes pro Zeile

                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;VT52-Emulator an die gewaehlte Aufloesung anpassen
;kein Register wird zerstoert
init_vt52:        movem.l  d0-d4/a0-a2,-(sp)
                  movea.l  nvdi_struct,a0
                  movea.l  _nvdi_sys_font_info(a0),a0 ;Zeiger auf Informationen ueber den Systemfont

                  movem.w  x_res,d0-d1    ;xres,yres
                  addq.w   #1,d0
                  addq.w   #1,d1
                  move.w   line_width,d2
                  move.w   d0,V_REZ_HZ.w  ;Sichbare Breite in Pixeln
                  move.w   d1,V_REZ_VT.w  ;Sichbare Hoehe in Zeilen
                  move.w   d1,V_REZ_VT.w  ;Sichbare Hoehe in Zeilen
                  movea.l  _sf_font_hdr_ptr(a0),a1 ;Zeiger auf die Systemfont-Header
                  lea      88(a1),a1      ;8*8 Systemfont 
                  cmpi.w   #400,d1        ;weniger als 400 Zeilen?
                  blt.s    init_vt52_font
                  lea      88(a1),a1      ;8*16 Systemfont
init_vt52_font:   move.l   dat_table(a1),V_FNT_AD.w ;Adresse des Fontimage
                  move.l   off_table(a1),V_OFF_AD.w ;Adresse der Offset-Table
                  move.w   #256,V_FNT_WD.w ;Breite des Fontimages in Bytes
                  move.l   #$ff0000,V_FNT_ND.w ;Nummer des letzten/ersten Zeichens
                  move.w   form_height(a1),d3 ;Zeichenhoehe
                  move.w   d3,V_CEL_HT.w  ;Zeichenhoehe
                  lsr.w    #3,d0
                  subq.w   #1,d0          ;Textspaltenanzahl -1
                  divu     d3,d1
                  subq.w   #1,d1          ;Textzeilenanzahl -1
                  mulu     d3,d2          ;Bytes pro Textzeile
                  movem.w  d0-d2,V_CEL_MX.w ;V_CEL_MX, V_CEL_MY, V_CEL_WR
                  move.l   #255,V_COL_BG.w ;Hinter-/Vordergrundfarbe
                  move.w   #1,V_HID_CNT.w ;TOS-Cursor aus!
                  move.w   #1,V_HID_CNT.w ;Cursor aus
                  move.w   #256,V_STAT_0.w ;blinken
                  move.w   #$1e1e,V_PERIOD.w ;Blinkrate des Cursors/Zaehler
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Cursoradresse
                  clr.l    V_CUR_XY.w     ;Cursor nach links oben
                  clr.w    V_CUR_OF.w     ;Offset von v_bas_ad
                  move.l   #vt_con,con_state.w
                  movem.l  (sp)+,d0-d4/a0-a2
                  rts

;Die Felder rgb_in_tab und rgb_out_tab fuer vs_color/vq_color initialisieren
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;d0.w Bitanzahl fuer Rot
;d1.w Bitanzahl fuer Gruen
;d2.w Bitanzahl fuer Blau
;Ausgaben:
;-
init_rgb_tabs:    movem.l  d0-d6/a0-a1,-(sp)

                  moveq    #1,d3
                  lsl.w    d0,d3
                  subq.w   #1,d3
                  move.w   d3,d0          ;maximale Rot-Intensitaet der CLUT
                  moveq    #1,d3
                  lsl.w    d1,d3
                  subq.w   #1,d3
                  move.w   d3,d1          ;maximale Gruen-Intensitaet der CLUT
                  moveq    #1,d3
                  lsl.w    d2,d3
                  subq.w   #1,d3
                  move.w   d3,d2          ;maximale Blau-Intensitaet der CLUT

                  movem.w  d0-d2,-(sp)

                  lea      rgb_in_tab,a0

init_rgbi_bloop:  moveq    #0,d3
init_rgbi_loop:   move.w   d3,d4
                  mulu     d0,d4       ;*hoechste Intensitaet
                  add.l    #500,d4     ;runden
                  divu     #1000,d4
                  move.b   d4,(a0)+    
                  addq.w   #1,d3
                  cmp.w    #1000,d3
                  ble.s    init_rgbi_loop

                  movem.w  (sp)+,d0-d2

                  lea      rgb_out_tab,a1

init_rgbo_bloop:  moveq    #0,d3
                  move.w   d0,d5       ;maximale Intensitaet der CLUT
                  lsr.w    #1,d5       
                  ext.l    d5          ;Rundungswert
init_rgbo_loop:   move.w   d3,d4       ;
                  mulu     #1000,d4    ;
                  add.l    d5,d4       ;runden
                  divu     d0,d4
                  move.w   d4,(a1)+
                  addq.w   #1,d3
                  cmp.w    d0,d3
                  ble.s    init_rgbo_loop

                  movem.l  (sp)+,d0-d6/a0-a1
                  rts

build_exp:        movem.l  d0-d2/a0-a1,-(sp)
                  lea      expand_tab,a0
                  lea      expand_tabo,a1
                  moveq    #0,d0          ;Zaehler
build_exp_bloop:  move.w   d0,d1          ;Bitmuster
                  moveq    #7,d2
build_exp_loop:   clr.b    (a0)
                  add.b    d1,d1          ;Bit gesetzt?
                  bcc.s    build_exp_next
                  not.b    (a0)
build_exp_next:   addq.l   #1,a0
                  dbra     d2,build_exp_loop
                  movep.l  -8(a0),d1
                  move.l   d1,(a1)+
                  movep.l  -7(a0),d1
                  move.l   d1,(a1)+
                  addq.w   #1,d0
                  cmp.w    #256,d0        ;alle 256 Farben durch?
                  blt.s    build_exp_bloop
                  movem.l  (sp)+,d0-d2/a0-a1
                  rts

build_color_maps: movem.l  d0/a0-a2,-(sp)
                  movea.l  nvdi_struct,a2
                  movea.l  _nvdi_colmaptab(a2),a2
                  
                  movea.l  _color_map_ptr(a2),a0
                  lea      color_map,a1
                  moveq    #63,d0
copy_map_loop:    move.l   (a0)+,(a1)+
                  dbra     d0,copy_map_loop
                                    
                  movea.l  _color_remap_ptr(a2),a0
                  lea      color_remap(pc),a1
                  moveq    #63,d0
copy_remap_loop:  move.l   (a0)+,(a1)+
                  dbra     d0,copy_remap_loop

                  movem.l  (sp)+,d0/a0-a2
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Setmode'

init_hardware:
set_dflt_palette: movem.l  d0-d4/a0-a2/a6,-(sp)
                  lea      palette_data(pc),a0 ;Zeiger auf Palettendaten
                  lea      color_map,a2   ;Zeiger auf die Farbumwandlungstabelle
                  moveq    #0,d3          ;Farbindex

set_palette:      moveq    #0,d0
                  move.b   (a2)+,d0
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d4

                  moveq    #31,d0
                  moveq    #31,d1
                  moveq    #31,d2

                  rol.w    #6,d4
                  and.w    d4,d0          ;Intensitaet von 0-15
                  mulu     #1000,d0
                  divu     d1,d0          ;Intensitaet in Promille (0-1000)
                  rol.w    #5,d4
                  and.w    d4,d1          ;Intensitaet von 0-15
                  mulu     #1000,d1
                  divu     d2,d1          ;Intensitaet in Promille (0-1000)
                  rol.w    #5,d4
                  and.w    d4,d2          ;Intensitaet von 0-15
                  mulu     #1000,d2
                  divu     #31,d2         ;Intensitaet in Promille (0-1000)

                  movem.l  d3/a0/a2,-(sp)
                  bsr      set_color_rgb
                  movem.l  (sp)+,d3/a0/a2

                  addq.w   #1,d3          ;Farbnummer erhoehen
                  cmp.w    #256,d3        ;schon alle 256 Farben gesetzt?
                  blt.s    set_palette
                  movem.l  (sp)+,d0-d4/a0-a2/a6
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
                  move.l   x_res,res_x(a6) ;Aufloesung
                  move.w   #7,r_planes(a6)   ;Anzahl der Bildebenen -1
                  move.w   #255,colors(a6) ;hoechste Farbnummer
                  clr.w    res_ratio(a6)  ;Seitenverhaeltnis

                  move.l   res_x(a6),clip_xmax(a6) ;clip_xmax/clip_ymax

                  move.l   p_escapes(a6),escape_ptr
                  move.l   p_bitblt(a6),bitblt_ptr

                  move.l   #v_escape,p_escapes(a6)

                  move.l   #set_color_rgb,p_set_color_rgb(a6)
                  move.l   #get_color_rgb,p_get_color_rgb(a6)

                  rts

wk_reset:         rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '3. Attributfunktionen'

;RGB-Farbwert fuer einen VDI-Farbindex setzen
;Vorgaben:
;Register d0-d4/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w Rot-Intensitaet von 0 - 1000
;d1.w Gruen-Intensitaet von 0 - 1000
;d2.w Blau-Intensitaet von 0 - 1000
;d3.w VDI-Farbindex
;Ausgaben:
;-
set_color_rgb:    lea      vdi_palette(pc),a1 ;VDI-Palette
                  move.w   d3,d4
                  add.w    d4,d4
                  add.w    d3,d4
                  add.w    d4,d4          ;*6 fuer Tabellenzugriff
                  adda.w   d4,a1
                  move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen

                  lea      color_map,a0
                  move.b   0(a0,d3.w),d3  ;Bitbelegung


                  move.l   a2,-(sp)
                  clr.l    -(sp)
                  movea.l  sp,a0
                  addq.l   #1,a0

                  lea      rgb_in_tab,a1  ;Tabelle ohne Kalibration

                  move.b   (a1,d0.w),(a0)+   ;Intensitaet der Grundfarbe setzen
                  move.b   (a1,d1.w),(a0)+   ;Intensitaet der Grundfarbe setzen
                  move.b   (a1,d2.w),(a0)+   ;Intensitaet der Grundfarbe setzen

                  move.l   sp,-(sp)       ;Zeiger auf XRGB-Buffer
                  move.w   #1,-(sp)       ;nur einen Paletteneintrag setzen
                  move.w   d3,-(sp)       ;Farbnummer
                  move.w   #VSETRGB,-(sp)
                  trap     #XBIOS
                  lea      14(sp),sp      ;Stack korrigieren
                  movea.l  (sp)+,a2
                  rts

;RGB-Farbwert fuer einen VDI-Farbindex zurueckliefern
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w VDI-Farbindex
;d1.w 0: erbetene Intensitaet zurueckliefern, sonst realisierte Intensitaet zurueckliefern
;Ausgaben:
;d0.w Rot-Intensitaet von 0 - 1000
;d1.w Gruen-Intensitaet von 0 - 1000
;d2.w Blau-Intensitaet von 0 - 1000
get_color_rgb:    add.w    d0,d0
                  move.w   d0,d2
                  add.w    d0,d0
                  add.w    d2,d0          ;mit 6 multiplizieren
                  lea      vdi_palette(pc),a0
                  adda.w   d0,a0
                  tst.w    d1             ;tatsaechliche Intensitaet?
                  bne.s    get_color_real
                  move.w   (a0)+,d0       ;Rot
                  move.w   (a0)+,d1       ;Gruen
                  move.w   (a0)+,d2       ;Blau
                  rts

get_color_real:   move.w   (a0)+,d0       ;Rot
                  move.w   (a0)+,d1       ;Gruen
                  move.w   (a0)+,d2       ;Blau
                  
                  move.l   a2,-(sp)
                  lea      rgb_in_tab,a1
                  lea      rgb_out_tab,a2

                  move.b   0(a1,d0.w),d0  ;Intensitaet fuer die CLUT (0-255)
                  and.w    #$ff,d0
                  add.w    d0,d0
                  move.w   0(a2,d0.w),d0  ;
                  move.b   0(a1,d1.w),d1  ;Intensitaet fuer die CLUT (0-255)
                  and.w    #$ff,d1
                  add.w    d1,d1
                  move.w   0(a2,d1.w),d1  ;
                  move.b   0(a1,d2.w),d2  ;Intensitaet fuer die CLUT (0-255)
                  and.w    #$ff,d2
                  add.w    d2,d2
                  move.w   0(a2,d2.w),d2  ;
                  movem.l  (sp)+,a2
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '7. Escapes'

; ESCAPE (VDI 5)
v_escape:         movea.l  (a0),a1        ;contrl
                  move.w   v_opcode2(a1),d0 ;Unteropcode
;Opcodebereich pruefen
                  cmpi.w   #V_CURTEXT,d0  ;v_curtext()?
                  beq      v_curtext
                  cmp.w    #VQ_CURADDRESS,d0
                  bhi.s    v_escape_unof
                  movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  pb_intin(a0),a2-a5
                  add.w    d0,d0
                  move.w   v_escape_tab(pc,d0.w),d2
                  movea.l  a2,a5
                  movea.l  a1,a0
                  movem.w  V_CUR_XY0.w,d0-d1
                  movea.l  V_CUR_AD.w,a1
                  movea.w  BYTES_LIN.w,a2
                  jsr      v_escape_tab(pc,d2.w)
                  movem.l  (sp)+,d1-d7/a2-a5
v_escape_exit:    rts
v_escape_unof:    movea.l  escape_ptr(pc),a1
                  jmp      (a1)           ;in normale Escapes einspringen

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
vq_chcells:       move.l   V_CEL_MX.w,d3  ;Spalten / Zeilen
                  addi.l   #$010001,d3
                  swap     d3

                  move.l   d3,(a4)
                  move.w   #2,v_nintout(a0) ;Eintraege in intout
                  rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:           addq.w   #1,V_HID_CNT.w ;Cursor aus
                  bclr     #CURSOR_STATE,V_STAT_0.w
                  bra      clear_screen   ;Bildschirm loeschen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:      clr.l    V_CUR_XY0.w    ;Spalte 0/Zeile 0
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Adresse des Cursors
                  move.l   #vt_con,con_state.w ;Zeiger auf VT-Routine
                  bsr      clear_screen   ;Bildschirm loeschen
                  bclr     #CURSOR_STATE,V_STAT_0.w
                  move.w   #1,V_HID_CNT.w
                  bra      cursor_on      ;Cursor an

; DIRECT ALPHA CURSOR ADDRESS (VDI 5, ESCAPE 11)
v_curaddress:     move.w   (a5)+,d1       ;Zeile
                  move.w   (a5)+,d0       ;Spalte
                  subq.w   #1,d0
                  subq.w   #1,d1
                  bra      set_cursor_xy

; INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15)
vq_curaddress:    addq.w   #1,d0
                  addq.w   #1,d1
                  move.w   d1,(a4)+       ;intout[0] = Zeile;
                  move.w   d0,(a4)+       ;intout[1] = Spalte;
                  move.w   #2,v_nintout(a0) ;Eintraege in intout
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
bitblt_in:        movea.l  aes_wk_ptr(pc),a6

                  move.w   d7,r_wmode(a6)
                  move.l   a0,r_saddr(a6)
                  move.l   a1,r_daddr(a6)
                  move.w   a2,r_swidth(a6)
                  move.w   a3,r_dwidth(a6)
                  move.w   r_planes(a6),d6
                  move.w   d6,r_splanes(a6)
                  move.w   d6,r_dplanes(a6)

                  movea.l  bitblt_ptr(pc),a4
                  jmp      (a4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  DATA

dev_name:         DC.B  'Mac 256 Farben',0
                  EVEN
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungs-Information'
relokation:

                  DC.W 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L  1
aes_wk_ptr:       DS.L 1                  ;Zeiger auf die AES-Workstation

escape_ptr:       DS.L  1
bitblt_ptr:       DS.L  1

bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 20*16

;Farbumwandlungstabelle fuer 256 Farben
color_map:        DS.B 256
;Tabelle fuer die Umwandlung von Farbebenenflag zu Farbnummer
color_remap:      DS.B 256

expand_tab:       DS.L 512                ;Expandiertabelle
expand_tabo:      DS.L 512                ;Expandiertabelle fuer movep.l

x_res:            DS.W 1                  ;adressierbare Rasterbreite (von 0 aus)
y_res:            DS.W 1                  ;adressierbare Rasterhoehe (von 0 aus)
pixw:             DS.W 1                  ;Pixelbreite in Mikrometern
pixh:             DS.W 1                  ;Pixelhoehe in Mikrometern
line_width:       DS.W 1                  ;Bytes pro Pixelzeile
vram:             DS.L 1                  ;Adresse des Video-RAMs

rgb_in_tab:       DS.B  1002              ;UBYTE   rgb_in_tab[3][1002];
rgb_out_tab:      DS.W  256               ;UWORD   rgb_out_tab[3][256];
vdi_palette:      DS.W  768               ;Palette zum Speichern der VDI-Farbintesitaeten

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
