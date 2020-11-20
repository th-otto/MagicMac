;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                 True Color-Bildschirmtreiber fuer NVDI 3.0                 *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ;Header'

VERSION           EQU $0313

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"

.INCLUDE "..\include\pixmap.inc"

PATTERN_LENGTH    EQU (32*32)             ;Fuellmusterlaenge bei 32 Ebenen
PAL_LENGTH        EQU   1024              ;Laenge der Pseudo-Palette

c_palette         EQU   f_saddr+PATTERN_LENGTH ;Startadresse der Pseudo-Palette

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;NVDI-Treiber initialisieren'
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
organisation:     DC.L  16777216          ;Farben
                  DC.W  32                ;Planes
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
                  bsr      build_color_maps
                  bsr      init_res       ;VDI-Variablen initialisieren
                  bsr      init_vt52      ;Daten fuer VT52
                  movem.l  (sp)+,d0-a6

init_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  move.l   #WK_LENGTH+PATTERN_LENGTH+PAL_LENGTH,d0 ;Laenge einer Workstation
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
                  move.l   #V_HID_CNT,_cursor_cnt_vec(a1)   ;Zeiger auf den Hide-Counter
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
                  move.w   #32,8-90(a0)   ;work_out[4]: Anzahl der Farbebenen
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
;a0.l intout
;a6.l Workstation
;Ausgaben:
;-
get_scrninfo:     movem.l  d0-d1/a0-a1,-(sp)
                  lea      scrninfo(pc),a1
                  move.w   (a1)+,(a0)+    ;[0] Packed Pixel
                  move.w   (a1)+,(a0)+    ;[1] Software-CLUT
                  move.w   (a1)+,(a0)+    ;[2] Anzahl der Ebenen
                  move.l   (a1)+,(a0)+    ;[3/4] Farbanzahl
                  move.w   BYTES_LIN.w,(a0)+ ;[5] Bytes pro Zeile
                  move.l   v_bas_ad.w,(a0)+  ;[6/7] Bildschirmadresse
                  addq.l   #6,a1
                  move.w   (a1)+,(a0)+    ;[8]  Bits der Rot-Intensitaet
                  move.w   (a1)+,(a0)+    ;[9]  Bits der Gruen-Intensitaet
                  move.w   (a1)+,(a0)+    ;[10] Bits der Blau-Intensitaet
                  move.w   (a1)+,(a0)+    ;[11] kein Alpha-Channel
                  move.w   (a1)+,(a0)+    ;[12] kein Genlock
                  move.w   (a1)+,(a0)+    ;[13] keine unbenutzten Bits
                  move.w   (a1)+,(a0)+    ;[14] Bitorganisation
                  move.w   (a1)+,(a0)+    ;[15] unbenutzt

                  move.w   #255,d0
scrninfo_loop:    move.w   (a1)+,(a0)+
                  dbf      d0,scrninfo_loop

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Daten fuer vq_scrninfo()'

scrninfo:         DC.W 2                  ;Packed Pixels
                  DC.W 2                  ;Software-CLUT
                  DC.W 32                 ;32 Ebenen
                  DC.L 16777216           ;16777216 Farben
                  DC.W 0,0,0
                  DC.W 8                  ;8 Bits fuer die Rot-Intensitaet
                  DC.W 8                  ;8 Bits fuer die Gruen-Intensitaet
                  DC.W 8                  ;8 Bits fuer die Blau-Intensitaet
                  DC.W 8                  ;8 Bit fuer Alpha-Channel
                  DC.W 0                  ;kein Bit fuer Genlock
                  DC.W 0                  ;kein unbenutztes Bit
                  DC.W  1
                  DC.W  0

                  DC.W 16,17,18,19,20,21,22,23 ;Bits der Rot-Intensitaet
                  DCB.W 8,-1
                  DC.W 8,9,10,11,12,13,14,15 ;Bits der Gruen-Intensitaet
                  DCB.W 8,-1
                  DC.W 0,1,2,3,4,5,6,7    ;Bits der Blau-Intensitaet
                  DCB.W 8,-1
                  DC.W  24,25,26,27,28,29,30,31 ;Bits fuer den Alpha-Channel
                  DCB.W 8,-1              
                  DCB.W 16,-1             ;keine Bits fuer Genlock
                  DCB.W 32,-1             ;unbenutzte Bits

                  DCB.W 156,0             ;reserviert

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Farbpalette'

palette_data:     DC.L $ffffff,$ff0000,$ff00,$ffff00,$ff,$ff00ff,$ffff,$d5d5d5
                  DC.L $838383,$ac0000,$ac00,$acac00,$ac,$ac00ac,$acac,$00
                  DC.L $ffffff,$eeeeee,$dedede,$cdcdcd,$bdbdbd,$acacac,$9c9c9c,$8b8b8b
                  DC.L $737373,$626262,$525252,$414141,$313131,$202020,$101010,$00
                  DC.L $ff0000,$ff0010,$ff0020,$ff0031,$ff0041,$ff0052,$ff0062,$ff0073
                  DC.L $ff008b,$ff009c,$ff00ac,$ff00bd,$ff00cd,$ff00de,$ff00ee,$ff00ff
                  DC.L $ee00ff,$de00ff,$cd00ff,$bd00ff,$ac00ff,$9c00ff,$8b00ff,$7300ff
                  DC.L $6200ff,$5200ff,$4100ff,$3100ff,$2000ff,$1000ff,$ff,$10ff
                  DC.L $20ff,$31ff,$41ff,$52ff,$62ff,$73ff,$8bff,$9cff
                  DC.L $acff,$bdff,$cdff,$deff,$eeff,$ffff,$ffee,$ffde
                  DC.L $ffcd,$ffbd,$ffac,$ff9c,$ff8b,$ff73,$ff62,$ff52
                  DC.L $ff41,$ff31,$ff20,$ff10,$ff00,$10ff00,$20ff00,$31ff00
                  DC.L $41ff00,$52ff00,$62ff00,$73ff00,$8bff00,$9cff00,$acff00,$bdff00
                  DC.L $cdff00,$deff00,$eeff00,$ffff00,$ffee00,$ffde00,$ffcd00,$ffbd00
                  DC.L $ffac00,$ff9c00,$ff8b00,$ff7300,$ff6200,$ff5200,$ff4100,$ff3100
                  DC.L $ff2000,$ff1000,$bd0000,$bd0010,$bd0020,$bd0031,$bd0041,$bd0052
                  DC.L $bd0062,$bd0073,$bd008b,$bd009c,$bd00ac,$bd00bd,$ac00bd,$9c00bd
                  DC.L $8b00bd,$7300bd,$6200bd,$5200bd,$4100bd,$3100bd,$2000bd,$1000bd
                  DC.L $bd,$10bd,$20bd,$31bd,$41bd,$52bd,$62bd,$73bd
                  DC.L $8bbd,$9cbd,$acbd,$bdbd,$bdac,$bd9c,$bd8b,$bd73
                  DC.L $bd62,$bd52,$bd41,$bd31,$bd20,$bd10,$bd00,$10bd00
                  DC.L $20bd00,$31bd00,$41bd00,$52bd00,$62bd00,$73bd00,$8bbd00,$9cbd00
                  DC.L $acbd00,$bdbd00,$bdac00,$bd9c00,$bd8b00,$bd7300,$bd6200,$bd5200
                  DC.L $bd4100,$bd3100,$bd2000,$bd1000,$730000,$730010,$730020,$730031
                  DC.L $730041,$730052,$730062,$730073,$620073,$520073,$410073,$310073
                  DC.L $200073,$100073,$73,$1073,$2073,$3173,$4173,$5273
                  DC.L $6273,$7373,$7362,$7352,$7341,$7331,$7320,$7310
                  DC.L $7300,$107300,$207300,$317300,$417300,$527300,$627300,$737300
                  DC.L $736200,$735200,$734100,$733100,$732000,$731000,$410000,$410010
                  DC.L $410020,$410031,$410041,$310041,$200041,$100041,$41,$1041
                  DC.L $2041,$3141,$4141,$4131,$4120,$4110,$4100,$104100
                  DC.L $204100,$314100,$414100,$413100,$412000,$411000,$00,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Relozierungsroutine'
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
                  ;GEMDOS\BIOS\XBIOS'

; OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
v_curtext:        movem.l  d1-d3/a2-a3,-(sp)
                  movea.l  pb_intin(a0),a3 ;intin
                  move.w   v_nintin(a1),d3 ;Zeichenanzahl
                  subq.w   #1,d3          ;zu wenig Zeichen ?
                  bmi.s    v_curtext_exit
v_curtext_loop:   move.w   (a3)+,d1       ;Zeichen
                  movea.l  con_state.w,a0 ;Sprungadresse
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
                  moveq    #0,d2
                  move.w   d1,d2
                  MC68020
                  mulu.l   v_cel_wr_LONG(pc),d2
                  MC68000
                  adda.l   d2,a1          ;Zeilenadresse
                  lsl.w    #5,d0
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
                  moveq    #-32,d1
                  add.w    BYTES_LIN.w,d1 ;Bytes pro Zeile
                  jmp      cursor_jmp(pc,d0.w)
cursor_jmp:       REPT 15
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  adda.w   d1,a1
                  ENDM
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
                  not.l    (a1)+
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
                  move.l   v_cel_wr_LONG(pc),d0
                  add.l    d0,V_CUR_AD.w  ;naechste Textzeile
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
set_x0:           lsl.w    #5,d0
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

vt_con:           cmpi.w   #32,d1         ;Steuerzeichen ?
                  blt.s    vt_control
vt_rawcon:        movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  moveq    #-32,d2
                  add.w    BYTES_LIN.w,d2 ;Bytes pro Zeile
                  move.b   #2,V_CUR_CT.w  ;Zaehler auf 2 -> keinen Cursor zeichnen
                  bclr     #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
                  move.l   V_FNT_AD.w,d0  ;Fontimageadresse

vt_char_col:      movem.l  d3-d4/a3,-(sp)
                  lea      V_COL_BG.w,a2
                  move.w   (a2)+,d3       ;V_COL_BG
                  move.w   (a2)+,d2       ;V_COL_FG
                  add.w    d2,d2
                  add.w    d2,d2
                  add.w    d3,d3
                  add.w    d3,d3
                  lea      palette_data(pc),a2
                  move.l   0(a2,d2.w),d2  ;Vordergrundfarbe
                  move.l   0(a2,d3.w),d3  ;Hintergrundfarbe
                  btst     #CURSOR_INVERSE,V_STAT_0.w ;invertieren ?
                  beq.s    vt_char_col2
                  exg      d2,d3
vt_char_col2:     movea.l  d0,a0
                  adda.w   d1,a0
                  movea.w  V_FNT_WD.w,a2
                  movea.w  BYTES_LIN.w,a3
                  lea      -32(a3),a3
                  move.w   V_CEL_HT.w,d1
                  subq.w   #1,d1          ;Zeilenzaehler

vt_char_cloop:    move.b   (a0),d4
                  moveq    #7,d0

vt_char_cloop2:   add.b    d4,d4
                  bcc.s    vt_char_cbg
                  move.l   d2,(a1)+
                  dbra     d0,vt_char_cloop2
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,vt_char_cloop

                  movem.l  (sp)+,d3-d4/a3
                  bra      vt_n_column

vt_char_cbg:      move.l   d3,(a1)+
                  dbra     d0,vt_char_cloop2
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,vt_char_cloop

                  movem.l  (sp)+,d3-d4/a3

vt_n_column:      move.w   V_CUR_XY0.w,d0
                  cmp.w    V_CEL_MX.w,d0  ;letzte Spalte ?
                  bge.s    vt_l_column
                  addi.l   #32,V_CUR_AD.w ;naechste Spalte
                  addq.w   #1,V_CUR_XY0.w
                  moveq    #-1,d0         ;alles OK fuer MiNT
                  rts
vt_l_column:      btst     #CURSOR_WRAP,V_STAT_0.w ;Wrapping ein ?
                  beq.s    vt_con_exit
                  addq.w   #1,V_HID_CNT.w ;Cursor sperren
vt_l_column2:     ext.l    d0
                  lsl.l    #5,d0
                  sub.l    d0,V_CUR_AD.w  ;Zeilenanfang (d0: High-Word=0 !)
                  clr.w    V_CUR_XY0.w
                  move.w   V_CUR_XY1.w,d1
                  pea      vt_con_exit2(pc)
                  cmp.w    V_CEL_MY.w,d1  ;letzte Zeile (Scrolling) ?
                  bge      scroll_up_page
                  addq.l   #4,sp          ;Stack korrigieren
                  move.l   v_cel_wr_LONG(pc),d0
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
                  suba.l   v_cel_wr_LONG(pc),a1 ;eine Zeile nach oben
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
                  and.l    #$0000ffff,d1
                  MC68020
                  mulu.l   v_cel_wr_LONG(pc),d1
                  MC68000
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
                  moveq    #0,d0
                  move.w   V_CUR_XY1.w,d0
                  MC68020
                  mulu.l   v_cel_wr_LONG(pc),d0
                  MC68000
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
                  lsl.w    #4,d4
                  subq.w   #1,d4
                  mulu     V_CEL_HT.w,d5
                  subq.w   #1,d5
                  sub.w    d1,d5
                  bra      scroll_up2
vt_seq_M_last:    bra      clear_line2

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
                  and.l    #$0000ffff,d1
                  MC68020
                  mulu.l   v_cel_wr_LONG(pc),d1
                  MC68000
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
                  moveq    #0,d0          ;xs
                  move.w   V_CEL_HT.w,d1  ;ys
                  moveq    #0,d2          ;dx
                  moveq    #0,d3          ;yd
                  movem.w  V_CEL_MX.w,d4-d5
                  addq.w   #1,d4
                  lsl.w    #3,d4
                  subq.w   #1,d4          ;dx
                  mulu     V_CEL_HT.w,d5
                  subq.w   #1,d5          ;dy
scroll_up2:       moveq    #3,d7          ;Modus fuer bitblt
                  movea.l  v_bas_ad.w,a0
                  movea.l  a0,a1
                  movea.w  BYTES_LIN.w,a2
                  movea.w  a2,a3
                  jsr      bitblt_in
                  movea.l  v_bas_ad.w,a1
                  moveq    #0,d0
                  move.w   V_CEL_MY.w,d0
                  MC68020
                  mulu.l   v_cel_wr_LONG(pc),d0
                  MC68000
                  adda.l   d0,a1
                  bra.s    clear_line2

scroll_down_page: movem.l  d2-d7/a1-a6,-(sp)
                  moveq    #0,d0          ;xs
                  moveq    #0,d1          ;ys
                  moveq    #0,d2          ;xd
                  move.w   V_CEL_HT.w,d3  ;yd
                  movem.w  V_CEL_MX.w,d4-d5
                  addq.w   #1,d4
                  addq.w   #1,d5
                  lsl.w    #3,d4
                  subq.w   #1,d4          ;dx
                  mulu     d3,d5
                  subq.w   #1,d5          ;dy
                  moveq    #3,d7          ;Modus fuer bitblt
                  movea.l  v_bas_ad.w,a0
                  movea.l  a0,a1
                  movea.w  BYTES_LIN.w,a2
                  movea.w  a2,a3
                  jsr      bitblt_in
                  movea.l  v_bas_ad.w,a1
                  bra.s    clear_line2

clear_line:       movem.l  d2-d7/a1-a6,-(sp)


;Eingabe
;a1.l
clear_line2:      move.w   V_CEL_HT.w,d7
                  subq.w   #1,d7
;d7.w Zeilenzaehler
clear_lines:      move.w   V_COL_BG.w,d6  ;Hintergrundfarbe
                  beq.s    clear_lwhite   ;weiss?

                  add.w    d6,d6
                  add.w    d6,d6
                  lea      palette_data(pc),a2
                  adda.w   d6,a2
                  move.l   (a2),d6        ;Hintergrundfarbe

                  move.w   V_CEL_MX.w,d4

                  move.w   BYTES_LIN.w,d5
                  move.w   d4,d2
                  addq.w   #1,d2          ;Zeichenanzahl pro Zeile
                  lsl.w    #5,d2          ;32 Bytes pro Zeichen
                  sub.w    d2,d5          ;Abstand zur naechsten Zeile

clear_line_bloop: move.w   d4,d2
clear_line_loop:  REPT 8
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d2,clear_line_loop
                  adda.w   d5,a1
                  dbra     d7,clear_line_bloop

                  movem.l  (sp)+,d2-d7/a1-a6
                  rts

clear_lwhite:     moveq    #$ffffffff,d6

                  move.w   V_CEL_MX.w,d4
                  move.w   d4,d2

                  addq.w   #1,d2          ;Zeichenanzahl pro Zeile
                  lsl.w    #5,d2          ;32 Bytes pro Zeichen
                  move.w   BYTES_LIN.w,d5
                  sub.w    d2,d5

clear_lw_bloop:   move.w   d4,d2
clear_lw_loop:    REPT 8
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d2,clear_lw_loop
                  adda.w   d5,a1
                  dbra     d7,clear_lw_bloop

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
                  bra      clear_lines

;Bereich einer Textzeile loeschen
;Eingaben
;d2.w Spaltenanzahl -1
;a1.l Adresse
;a2.w Bytes pro Zeile
;Ausgaben
;d0-d2/a0-a1 werden zerstoert
clear_line_part:  move.l   d3,-(sp)
                  move.w   V_COL_BG.w,d3  ;Hintergrundfarbe
                  add.w    d3,d3
                  add.w    d3,d3
                  lea      palette_data(pc),a0
                  move.l   0(a0,d3.w),d3  ;Hintergrundfarbe

                  move.w   V_CEL_HT.w,d1
                  subq.w   #1,d1          ;Zeilenzaehler

                  move.w   d2,d0
                  addq.w   #1,d0
                  lsl.w    #5,d0
                  movea.w  BYTES_LIN.w,a0
                  suba.w   d0,a0

clear_lpart_bloop:move.w   d2,d0
clear_lpart_loop: REPT 8
                  move.l   d3,(a1)+
                  ENDM
                  dbra     d0,clear_lpart_loop
                  adda.w   a0,a1
                  dbra     d1,clear_lpart_bloop

                  move.l   (sp)+,d3
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;LineA'

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
                  lea      -64(a3),a3
                  addq.l   #2,a2          ;Adresse des Hintergrunds
undraw_spr_loop:  REPT 16
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

                  moveq    #0,d6
                  moveq    #0,d7
                  move.b   7(a0),d6       ;Hintergrundfarbe
                  move.b   9(a0),d7       ;Vordergrundfarbe
                  lea      color_remap,a1
                  move.b   0(a1,d6.w),d6
                  move.b   0(a1,d7.w),d7
                  add.w    d6,d6
                  add.w    d6,d6
                  add.w    d7,d7
                  add.w    d7,d7
                  movea.l  aes_wk_ptr,a1
                  lea      c_palette(a1),a1
                  move.l   0(a1,d6.w),d6
                  move.l   0(a1,d7.w),d7

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

                  movea.l  a1,a4
                  move.w   d0,d4
                  cmp.w    #15,d2         ;volle Breite?
                  beq.s    draw_spr_saddr
                  moveq    #0,d4
                  tst.w    d0             ;ueberschreitet den linken Rand?
                  bmi.s    draw_spr_saddr
                  moveq    #-15,d4
                  add.w    DEV_TAB0.w,d4  ;32 Bytes vom rechten Rand entfernt

draw_spr_saddr:   add.w    d4,d4
                  add.w    d4,d4
                  adda.w   d4,a4

                  move.l   a4,(a2)+       ;Adresse des Hintergrunds
                  move.w   #$0100,(a2)+   ;Bereich gesichert
                  movea.w  BYTES_LIN.w,a3
                  lea      -64(a3),a3     ;Abstand zur naechsten Zeile
                  move.w   d3,d5

draw_spr_sloop:   REPT 16
                  move.l   (a4)+,(a2)+
                  ENDM

                  adda.w   a3,a4

                  dbra     d5,draw_spr_sloop

                  movea.w  BYTES_LIN.w,a3
                  add.w    d2,d2
                  add.w    d2,d2
                  suba.w   d2,a3
                  subq.w   #4,a3
                  asr.w    #2,d2

                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a1
                  asr.w    #2,d0
                  cmp.w    #15,d2         ;Mauszeiger an einem der Raender?
                  beq.s    draw_it

                  tst.w    d0             ;Mauszeiger am linken Rand?
                  bpl.s    draw_it

                  add.w    d0,d0
                  add.w    d0,d0
                  suba.w   d0,a1
                  asr.w    #2,d0
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
                  move.l   d7,(a1)+
                  add.w    d4,d4
                  dbra     d1,draw_spr_loop
                  bra.s    draw_spr_next

draw_spr_bg:      add.w    d4,d4
                  bcc.s    draw_spr_nth
                  move.l   d6,(a1)+
                  dbra     d1,draw_spr_loop
                  bra.s    draw_spr_next

draw_spr_nth:     addq.l   #4,a1
                  dbra     d1,draw_spr_loop

draw_spr_next:    adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,draw_spr_bloop

draw_spr_exit:    rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Initialisierung'

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
                  move.w   #32,PLANES.w   ;Anzahl der Bildebenen
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
                  movea.l  _sf_font_hdr_ptr(a0),a1 ;Zeiger auf die Systemfont-Header
                  lea      88(a1),a1      ;8*8 Systemfont 
                  cmpi.w   #400,d1        ;weniger als 400 Zeilen?
                  blt.s    init_vt52_font
                  lea      88(a1),a1      ;8*16 Systemfont
init_vt52_font:   move.l   dat_table(a1),V_FNT_AD.w ;Adresse des Fontimage
                  move.l   off_table(a1),V_OFF_AD.w ;Adresse der HOT
                  move.w   #256,V_FNT_WD.w ;Breite des Fontimages in Bytes

                  move.l   #$ff0000,V_FNT_ND.w ;Nummer des letzten/ersten Zeichens
                  move.w   form_height(a1),d3 ;Zeichenhoehe
                  move.w   d3,V_CEL_HT.w  ;Zeichenhoehe
                  lsr.w    #3,d0
                  subq.w   #1,d0          ;Textspaltenanzahl -1
                  divu     d3,d1
                  subq.w   #1,d1          ;Textzeilenanzahl -1
                  mulu     d3,d2          ;Bytes pro Textzeile
                  move.l   d2,v_cel_wr_LONG  ;wg. ueberlauf
                  movem.w  d0-d2,V_CEL_MX.w ;V_CEL_MX, V_CEL_MY, V_CEL_WR
                  move.l   #255,V_COL_BG.w ;Hinter-/Vordergrundfarbe
                  move.w   #1,V_HID_CNT.w ;Cursor aus
                  move.w   #256,V_STAT_0.w ;blinken
                  move.w   #$1e1e,V_PERIOD.w ;Blinkrate des Cursors/Zaehler
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Cursoradresse
                  clr.l    V_CUR_XY.w     ;Cursor nach links oben
                  clr.w    V_CUR_OF.w     ;Offset von v_bas_ad
                  move.l   #vt_con,con_state.w
                  movem.l  (sp)+,d0-d4/a0-a2
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
                  ;1. Kontrollfunktionen'

;Workstation intialisieren
;Vorgaben:
;kein Register darf veraendert werden
;Eingaben:
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben:
;-
wk_init:          tst.l    aes_wk_ptr
                  bne.s    wk_init_res
                  move.l   a6,aes_wk_ptr     

wk_init_res:      move.l   x_res,res_x(a6) ;Aufloesung
                  move.w   #31,r_planes(a6)  ;Anzahl der Bildebenen -1
                  move.w   #255,colors(a6) ;hoechste Farbnummer
                  clr.w    res_ratio(a6)  ;Seitenverhaeltnis

                  move.l   res_x(a6),clip_xmax(a6) ;clip_xmax/clip_ymax

                  move.l   p_bitblt(a6),bitblt_ptr
                  move.l   p_escapes(a6),escape_ptr

                  move.l   #v_escape,p_escapes(a6)

                  rts

;Workstation entfernen
;Vorgaben:
;kein Register darf veraendert werden
;Eingaben:
;a6.l Workstation
;Ausgaben:
;-
wk_reset:         cmpa.l   aes_wk_ptr(pc),a6
                  bne.s    wk_reset_exit
                  clr.l    aes_wk_ptr
wk_reset_exit:    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;7. Escapes'

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
                  
dev_name:         DC.B  'Mac 16M Farben',0
                  EVEN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Relozierungs-Information'
relokation:

                  DC.W 0

                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Laufzeitdaten'

                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L  1

escape_ptr:       DS.L  1
bitblt_ptr:       DS.L  1

v_cel_wr_LONG:    DS.L  1                 ;Langwort statt V_CEL_WR

bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab

aes_wk_ptr:       DS.L 1                  ;Zeiger auf die AES-Workstation

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 64*16

;Farbumwandlungstabelle fuer 256 Farben
color_map:        DS.B 256
;Tabelle fuer die Umwandlung von Farbebenenflag zu Farbnummer
color_remap:      DS.B 256

x_res:            DS.W 1                  ;adressierbare Rasterbreite (von 0 aus)
y_res:            DS.W 1                  ;adressierbare Rasterhoehe (von 0 aus)
pixw:             DS.W 1                  ;Pixelbreite in Mikrometern
pixh:             DS.W 1                  ;Pixelhoehe in Mikrometern
line_width:       DS.W 1                  ;Bytes pro Pixelzeile
vram:             DS.L 1                  ;Adresse des Video-RAMs
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
