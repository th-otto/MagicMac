;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*              2-Farb-Bildschirmtreiber fuer den Mac                         *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ; 'Header'

VERSION           EQU $313

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"

.INCLUDE "..\include\pixmap.inc"

PATTERN_LENGTH    EQU (32*1)              ;Fuellmusterlaenge bei 1 Ebenen

SCROLL_LINE       EQU 320                 ;Laenge eines MOVEM-Bereichs

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
organisation:     DC.L  2                 ;Farben
                  DC.W  1                 ;Planes
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
;d3.w ID
;a0.l Zeiger auf nvdi_struct
;a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
;Ausgaben:
;d0.l Laenge der Workstation oder 0L bei einem Fehler
init:             movem.l  d0-d2/a0-a2,-(sp)
                  bsr      make_relo      ;Treiber relozieren

                  move.l   a0,nvdi_struct
                  move.l   a1,driver_struct
                  
                  move.l   _nvdi_bios_tab(a0),nvdi_bios_tab
                  
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
                  move.l   #con_state,_vt52_vec_vec(a1)     ;VT52-Vektor eintragen
                  move.l   #vtm_con,_con_vec(a1)            ;Routine fuer CON-Ausgaben
                  move.l   #vtm_rawcon,_rawcon_vec(a1)      ;Routine fuer RAW-Ausgaben
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
                     
                  move.w   #2,26-90(a0)   ;work_out[13]: Anzahl der Farben
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

                  move.w   #0,2-90(a0)       ;work_out[1]: mehr als 32767 Farbabstufungen
                  move.w   #1,8-90(a0)       ;work_out[4]: Anzahl der Farbebenen
                  move.w   #1,10-90(a0)      ;work_out[5]: CLUT vorhanden
                  move.w   #2200,12-90(a0)   ;work_out[6]: Anzahl der Rasteroperationen
                  move.w   #1,38-90(a0)      ;work_out[19]: Clipping an

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
                  move.w   #1,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #2,(a0)+       ;[3/4] Farbanzahl
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

                  clr.w    (a0)+
                  move.w   #254,d0
                  moveq    #1,d1
scrninfo_loop:    move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

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
                  move.w   #1,PLANES.w    ;Anzahl der Bildebenen
                  move.w   d2,WIDTH.w     ;Bytes pro Zeile
                  move.w   d2,BYTES_LIN.w ;Bytes pro Zeile

                  movem.l  (sp)+,d0-d2/a0-a2
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
                  movem.w  d0-d2,V_CEL_MX.w ;V_CEL_MX, V_CEL_MY, V_CEL_WR
                  move.l   #255,V_COL_BG.w ;Hinter-/Vordergrundfarbe
                  move.w   #1,V_HID_CNT.w ;TOS-Cursor aus!
                  move.w   #256,V_STAT_0.w ;blinken
                  move.w   #$1e1e,V_PERIOD.w ;Blinkrate des Cursors/Zaehler
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Cursoradresse
                  clr.l    V_CUR_XY.w     ;Cursor nach links oben
                  clr.w    V_CUR_OF.w     ;Offset von v_bas_ad
                  move.l   #vtm_con,con_state
                  move.l   #vtm_con,con_vec
                  move.l   #vtm_rawcon,rawcon_vec
                  movea.l  nvdi_bios_tab(pc),a1
                  move.l   #vtm_con,_con_vec(a1)
                  move.l   #vtm_rawcon,_rawcon_vec(a1)
                  movem.l  (sp)+,d0-d4/a0-a2
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Cursor positionieren
;Eingabe
;d0 Textspalte
;d1 Textzeile
;Ausgabe
;a1 Cursoradresse
;zerstoert werden d0-d2
set_cursor_xy:    bsr      cursor_off
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
                  adda.w   d0,a1          ;Cursoradresse
                  adda.w   V_CUR_OF.w,a1  ;Offset
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
cursor:           movem.l  d0/a0-a2,-(sp)
                  moveq    #16,d0
                  sub.w    V_CEL_HT.w,d0
                  add.w    d0,d0
                  add.w    d0,d0          ;(16 - Zeichenhoehe) * 4
                  lea      cursor_jmp(pc,d0.w),a0 ;Sprungadresse

                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  movea.w  BYTES_LIN.w,a2 ;Bytes pro Zeile
                  jmp      (a0)
cursor_jmp:       REPT 15
                  not.b    (a1)
                  adda.w   a2,a1
                  ENDM
                  not.b    (a1)
                  movem.l  (sp)+,d0/a0-a2
cursor_exit:      rts


;BEL, Klingelzeichen
vt_bel:           btst     #2,conterm.w   ;Glocke an ?
                  beq.s    cursor_exit
                  movea.l  bell_hook.w,a0
                  jmp      (a0)


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
set_x0:           suba.w   d0,a1
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
                  move.l   con_vec(pc),con_state.w ;Sprungadresse
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

vtm_con:          cmpi.w   #32,d1         ;Steuerzeichen ?
                  blt.s    vt_control
vtm_rawcon:       movea.l  V_FNT_AD.w,a0  ;Fontimageadresse
                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  adda.w   d1,a0          ;Adresse des Zeichens
                  moveq    #16,d0         ;Zeichenhoehe 16 (High = 0 !!)
                  move.w   BYTES_LIN.w,d2 ;Bytes pro Zeile
                  move.b   #4,V_CUR_CT.w  ;Zaehler auf 4 -> keinen Cursor zeichnen
                  bclr     #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
                  btst     #INVERSE,V_STAT_0.w ;invertieren ?
                  bne      vtm_charrev
                  sub.w    V_CEL_HT.w,d0  ;Zeichenhoehe 16 ?
                  beq.s    vtm_charx_jmp
                  add.w    d0,d0
                  move.w   d0,d1
                  add.w    d0,d0
                  add.w    d1,d0          ;(16-Zeichenhoehe)*6
                  suba.w   vtm_charx_jmp(pc,d0.w),a0
                  jmp      vtm_charx_jmp-2(pc,d0.w)
vtm_charx_jmp:    move.b   (a0),(a1)      ;Byte uebertragen
                  adda.w   d2,a1          ;naechste Bilschirmzeile
                  move.b   256(a0),(a1)
                  adda.w   d2,a1
                  move.b   512(a0),(a1)
                  adda.w   d2,a1
                  move.b   768(a0),(a1)
                  adda.w   d2,a1
                  move.b   1024(a0),(a1)
                  adda.w   d2,a1
                  move.b   1280(a0),(a1)
                  adda.w   d2,a1
                  move.b   1536(a0),(a1)
                  adda.w   d2,a1
                  move.b   1792(a0),(a1)
                  adda.w   d2,a1
                  move.b   2048(a0),(a1)
                  adda.w   d2,a1
                  move.b   2304(a0),(a1)
                  adda.w   d2,a1
                  move.b   2560(a0),(a1)
                  adda.w   d2,a1
                  move.b   2816(a0),(a1)
                  adda.w   d2,a1
                  move.b   3072(a0),(a1)
                  adda.w   d2,a1
                  move.b   3328(a0),(a1)
                  adda.w   d2,a1
                  move.b   3584(a0),(a1)
                  adda.w   d2,a1
                  move.b   3840(a0),(a1)
vtm_n_column:     move.w   V_CUR_XY0.w,d0
                  cmp.w    V_CEL_MX.w,d0  ;letzte Spalte ?
                  bge.s    vtm_l_column
                  addq.l   #1,V_CUR_AD.w  ;naechste Spalte
                  addq.w   #1,V_CUR_XY0.w
                  rts

vtm_l_column:     btst     #WRAP,V_STAT_0.w ;Wrapping ein ?
                  beq.s    vtm_con_exit
                  addq.w   #1,V_HID_CNT.w ;Cursor sperren
vtm_l_column2:    sub.l    d0,V_CUR_AD.w  ;Zeilenanfang (d0: High-Word=0 !)
                  clr.w    V_CUR_XY0.w
                  move.w   V_CUR_XY1.w,d1
                  pea      vtm_con_exit2(pc)
                  cmp.w    V_CEL_MY.w,d1  ;letzte Zeile (Scrolling) ?
                  bge      scroll_up_page
                  addq.l   #4,sp          ;Stack korrigieren
                  move.w   V_CEL_WR.w,d0  ;Bytes pro Textzeile (d0: High-Word=0!)
                  add.l    d0,V_CUR_AD.w  ;naechste Textzeile
                  addq.w   #1,V_CUR_XY1.w
vtm_con_exit2:    subq.w   #1,V_HID_CNT.w ;Cursor zulassen
vtm_con_exit:     rts

;Zeichen invertiert ausgeben
vtm_charrev:      sub.w    V_CEL_HT.w,d0  ;Zeichenhoehe 16 ?
                  beq.s    vtm_charrev16
                  add.w    d0,d0
                  move.w   d0,d1
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d1,d0          ;(16-Zeichenhoehe) * 10
                  suba.w   vtm_charrev16(pc,d0.w),a0
                  jmp      vtm_charrev16-2(pc,d0.w)
vtm_charrev16:    move.b   (a0),d1        ;Zeile uebertragen
                  not.b    d1             ;invertieren
                  move.b   d1,(a1)        ;ausgeben
                  adda.w   d2,a1          ;naechste Bilschirmzeile
                  move.b   256(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   512(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   768(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   1024(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   1280(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   1536(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   1792(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   2048(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   2304(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   2560(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   2816(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   3072(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   3328(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   3584(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   d2,a1
                  move.b   3840(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  move.w   V_CUR_XY0.w,d0
                  cmp.w    V_CEL_MX.w,d0  ;letzte Spalte ?
                  bge      vtm_l_column
                  addq.l   #1,V_CUR_AD.w  ;naechste Spalte
                  addq.w   #1,V_CUR_XY0.w
                  rts


vtc_con:          cmpi.w   #32,d1         ;Steuerzeichen ?
                  blt      vt_control
vtc_rawcon:       move.l   d3,-(sp)
                  moveq    #16,d0
                  sub.w    V_CEL_HT.w,d0
                  add.w    d0,d0          ;(16 - Zeichenhoehe) * 2
                  move.w   d0,d2
                  lsl.w    #7,d2          ;(16 - Zeichenhoehe) * 256
                  sub.w    d2,d1          ;Zeichennummer "korrigieren"
                  movea.l  V_FNT_AD.w,a0  ;Fontimageadresse
                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  movea.w  BYTES_LIN.w,a2 ;Bytes pro Zeile
                  adda.w   d1,a0          ;Adresse des Zeichens(-Offset)
                  moveq    #1,d2          ;PLANES
                  subq.w   #1,d2          ;Planezaehler
                  move.l   V_COL_BG.w,d3  ;Hintergrundfarbe/Vordergrundfarbe
                  move.b   #4,V_CUR_CT.w  ;Blinkzaehler hochsetzen -> kein Cursor
                  bclr     #CURSOR_STATE,V_STAT_0.w ;Cursor nicht sichtbar
                  btst     #INVERSE,V_STAT_0.w ;invertieren ?
                  beq.s    vtc_char_loop
                  swap     d3             ;Hinter- und Vordergrundfarbe tauschen
vtc_char_loop:    move.l   a1,-(sp)
                  pea      vtc_char_next(pc)
                  lsr.l    #1,d3          ;Vordergrundfarbe ?
                  bcc.s    vtc_char_fg0
                  btst     #15,d3
                  beq      vtc_charx
                  bra      vtc_bg_black
vtc_char_fg0:     btst     #15,d3         ;Hintergrundfarbe ?
                  bne      vtc_charrev
                  bra      vtc_bg_white
vtc_char_next:    movea.l  (sp)+,a1
                  addq.l   #2,a1          ;naechste Plane
                  dbra     d2,vtc_char_loop
                  move.l   (sp)+,d3
                  move.w   V_CUR_XY0.w,d0
                  cmp.w    V_CEL_MX.w,d0  ;letzte Spalte ?
                  bge.s    vtc_l_column
                  addq.w   #1,V_CUR_XY0.w ;naechste Spalte
                  lsr.w    #1,d0          ;Planeoffset dazu ?
                  bcs.s    vtc_n_column
                  addq.l   #1,V_CUR_AD.w  ;naechste Spalte
                  moveq    #-1,d0         ;alles OK fuer MiNT
                  rts
vtc_n_column:     subq.l   #1,a1
                  move.l   a1,V_CUR_AD.w
                  moveq    #-1,d0         ;alles OK fuer MiNT
                  rts
vtc_l_column:     btst     #WRAP,V_STAT_0.w ;Wrapping ein ?
                  beq.s    vtc_con_exit1
                  addq.w   #1,V_HID_CNT.w ;Cursor sperren
                  subq.w   #1,d0
                  moveq    #1,d1          ;High-Byte=0 !
                  move.b   vtc_planes-1(pc,d1.w),d1
                  lsl.w    d1,d0          ;Byteoffset

                  addq.w   #1,d0
                  movea.l  V_CUR_AD.w,a1
                  suba.w   d0,a1
                  move.l   a1,V_CUR_AD.w  ;Zeilenanfang
                  clr.w    V_CUR_XY0.w
                  move.w   V_CUR_XY1.w,d1

                  pea      vtc_con_exit2(pc)
                  cmp.w    V_CEL_MY.w,d1  ;letzte Zeile (Scrolling) ?
                  bge      scroll_up_page
                  addq.l   #4,sp          ;Stack korriegieren
                  adda.w   V_CEL_WR.w,a1  ;naechste Zeile
                  move.l   a1,V_CUR_AD.w
                  addq.w   #1,V_CUR_XY1.w
vtc_con_exit2:    subq.w   #1,V_HID_CNT.w ;Cursor zulassen
vtc_con_exit1:    rts

vtc_planes:       DC.B 0                  ;1 Plane
                  DC.B 1                  ;2 Planes
                  DC.B 0
                  DC.B 2                  ;4 Planes
                  DC.B 0
                  DC.B 0
                  DC.B 0
                  DC.B 3                  ;8 Planes

vtc_charx:        tst.w    d0
                  beq.s    vtc_charx_jmp
                  move.w   d0,d1
                  add.w    d1,d1
                  add.w    d0,d1          ;(16-Zeichenhoehe)*6
                  jmp      vtc_charx_jmp-2(pc,d1.w)
vtc_charx_jmp:    move.b   (a0),(a1)      ;Byte uebertragen
                  adda.w   a2,a1          ;naechste Bilschirmzeile
                  move.b   256(a0),(a1)
                  adda.w   a2,a1
                  move.b   512(a0),(a1)
                  adda.w   a2,a1
                  move.b   768(a0),(a1)
                  adda.w   a2,a1
                  move.b   1024(a0),(a1)

                  adda.w   a2,a1
                  move.b   1280(a0),(a1)
                  adda.w   a2,a1
                  move.b   1536(a0),(a1)

                  adda.w   a2,a1
                  move.b   1792(a0),(a1)
                  adda.w   a2,a1
                  move.b   2048(a0),(a1)
                  adda.w   a2,a1
                  move.b   2304(a0),(a1)
                  adda.w   a2,a1
                  move.b   2560(a0),(a1)
                  adda.w   a2,a1
                  move.b   2816(a0),(a1)
                  adda.w   a2,a1
                  move.b   3072(a0),(a1)
                  adda.w   a2,a1
                  move.b   3328(a0),(a1)
                  adda.w   a2,a1
                  move.b   3584(a0),(a1)
                  adda.w   a2,a1
                  move.b   3840(a0),(a1)
                  rts

vtc_charrev:      tst.w    d0
                  beq.s    vtc_charrev16
                  move.w   d0,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  add.w    d0,d1          ;(16-Zeichenhoehe) * 10
                  jmp      vtc_charrev16-2(pc,d1.w)
vtc_charrev16:    move.b   (a0),d1        ;Zeile uebertragen
                  not.b    d1             ;invertieren
                  move.b   d1,(a1)        ;ausgeben
                  adda.w   a2,a1          ;naechste Bilschirmzeile
                  move.b   256(a0),d1
                  not.b    d1
                  move.b   d1,(a1)

                  adda.w   a2,a1
                  move.b   512(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   768(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   1024(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1

                  move.b   1280(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   1536(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   1792(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   2048(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   2304(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   2560(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   2816(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   3072(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   3328(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   3584(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  move.b   3840(a0),d1
                  not.b    d1
                  move.b   d1,(a1)
                  rts

;d0 (16 - Zeichenoehe) * 2
;a1 Cursoradresse
;a2 Bytes pro Zeile
vtc_bg_white:     moveq    #0,d1
                  bra.s    vtc_bg
vtc_bg_black:     moveq    #-1,d1
vtc_bg:           add.w    d0,d0
                  beq.s    vtc_bg16
                  jmp      vtc_bg16(pc,d0.w)
vtc_bg16:         REPT 15
                  move.b   d1,(a1)
                  adda.w   a2,a1
                  ENDM
                  move.b   d1,(a1)
                  lsr.w    #1,d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq:       cmpi.w   #89,d1         ;ESC Y ?
                  beq      vt_seq_Y
                  move.w   d1,d2

                  movem.w  V_CUR_XY0.w,d0-d1 ;Textspalte/-zeile
                  movea.l  V_CUR_AD.w,a1  ;Cursoradresse
                  movea.w  BYTES_LIN.w,a2 ;Bytes pro Zeile
                  move.l   con_vec(pc),con_state.w ;Sprungadresse

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

/*
 * ALPHA CURSOR UP (VDI 5, ESCAPE 4)/ Cursor up (VT 52 ESC A)
 */
v_curup:
vt_seq_A:         subq.w   #1,d1
                  bra      set_cursor_xy

/*
 * ALPHA CURSOR DOWN (VDI 5,ESCAPE 5)/ Cursor down (VT52 ESC B)
 */
v_curdown:
vt_seq_B:         addq.w   #1,d1
                  bra      set_cursor_xy

/*
 * ALPHA CURSOR RIGHT (VDI 5, ESCAPE 6)/ Cursor right (VT52 ESC C)
 */
v_curright:
vt_seq_C:         addq.w   #1,d0
                  bra      set_cursor_xy

/*
 * ALPHA CURSOR LEFT (VDI 5, ESCAPE 7)/ Cursor left (VT52 ESC D)
 */
v_curleft:
vt_seq_D:         subq.w   #1,d0
                  bra      set_cursor_xy

/*
 * Clear screen (VT52 ESC E)
 */
vt_seq_E:         bsr      cursor_off
                  bsr      clear_screen
                  bra.s    vt_seq_H_in

/*
 * HOME ALPHA CURSOR (VDI 5, ESCAPE 8)/ Home Cursor (VT52 ESC H)
 */
v_curhome:
vt_seq_H:         bsr      cursor_off
vt_seq_H_in:      clr.l    V_CUR_XY0.w
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1
                  move.l   a1,V_CUR_AD.w
                  bra      cursor_on

/*
 * Cursor up and insert (VT52 ESC I)
 */
vt_seq_I:         pea      cursor_on(pc)
                  bsr      cursor_off
                  subq.w   #1,d1          ;Cursor bereits in der obersten Zeile ?
                  blt      scroll_down_page
                  suba.w   V_CEL_WR.w,a1  ;eine Zeile nach oben
                  move.l   a1,V_CUR_AD.w
                  move.w   d1,V_CUR_XY1.w
                  rts

/*
 * ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
 */
v_eeos:
vt_seq_J:         bsr.s    vt_seq_K       ;Bis zum Zeilenende loeschen
                  move.w   V_CUR_XY1.w,d1 ;Textzeile
                  move.w   V_CEL_MY.w,d2  ;maximale Textzeile
                  sub.w    d1,d2          ;Anzahl der zu loeschenden Textzeilen
                  beq.s    vt_seq_J_exit
                  movem.l  d2-d7/a1-a6,-(sp)
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1
                  addq.w   #1,d1
                  mulu     V_CEL_WR.w,d1
                  adda.l   d1,a1          ;Startadresse
                  move.w   d2,d7
                  mulu     V_CEL_HT.w,d7
                  subq.w   #1,d7          ;Anzahl der zu loeschenden Bildzeilen -1
                  bra      clear_lines    ;Zeilen loeschen/Register zurueck
vt_seq_J_exit:    rts

/*
 * ERASE TO END OF ALPHA TEXT LINE (VDI 5, ESCAPE 10)
 */
v_eeol:
/*
 * Clear to end of line (VT52 ESC K)
 */
vt_seq_K:         bsr      cursor_off
                  move.w   V_CEL_MX.w,d2
                  sub.w    d0,d2          ;Anzahl der zu loeschenden Zeichen
                  bsr      clear_line_part
                  bra      cursor_on

/*
 * Insert line (VT52 ESC I)
 */
vt_seq_L:         pea      cursor_on(pc)
                  bsr      cursor_off
                  bsr      set_x0         ;Cursor an Zeilenanfang
                  movem.l  d2-d7/a1-a6,-(sp) ;Register sichern

                  move.w   V_CEL_MY.w,d7
                  move.w   d7,d5
                  sub.w    d1,d7          ;letzte Zeile ?
                  beq.s    vt_seq_L_exit
                  move.w   V_CEL_WR.w,d6  ;Bytes pro Textzeile
                  mulu     d6,d5
                  movea.l  v_bas_ad.w,a0
                  adda.w   V_CUR_OF.w,a0
                  adda.l   d5,a0          ;Quelladresse
                  lea      0(a0,d6.w),a1  ;Zieladresse
                  mulu     d6,d7          ;Anzahl der Bytes
                  divu     #SCROLL_LINE,d7 ;320-Byte-Zaehler
                  subq.w   #1,d7          ;wegen dbf
                  bsr      scroll_down
vt_seq_L_exit:    movea.l  V_CUR_AD.w,a1  ;Startadresse
                  bra      clear_line2    ;Zeile loeschen/ Register zurueck

/*
 * Delete Line (VT52 ESC M)
 */
vt_seq_M:         pea      cursor_on(pc)
                  bsr      cursor_off
                  bsr      set_x0         ;Cursor an Zeilenanfang
                  movem.l  d2-d7/a1-a6,-(sp) ;Register sichern
                  move.w   V_CEL_MY.w,d7
                  sub.w    d1,d7          ;nur letzte Zeile loeschen ?
                  beq      clear_line2
                  move.w   V_CEL_WR.w,d6  ;Bytes pro Buchstabenzeile
                  lea      0(a1,d6.w),a0  ;Quelladresse
                  mulu     d6,d7          ;Anzahl der Bytes
                  divu     #SCROLL_LINE,d7 ;320-Byte-Zaehler
                  subq.w   #1,d7          ;wegen dbf
                  bra      scroll_up2     ;Scrollen/loeschen/Register/Cursor an

/*
 * Set cursor position (VT52 ESC Y)
 */
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
                  move.l   con_vec(pc),con_state.w ;Sprungadresse
                  bra      set_cursor_xy

/*
 * Foreground color (VT52 ESC b)
 */
vt_seq_b:         move.l   #vt_set_b,con_state.w
                  rts
vt_set_b:         and.w    #1,d1          ;ausmaskieren
                  move.w   d1,V_COL_FG.w
vt_set_b_in:      move.l   V_COL_BG.w,d1  ;Hinter-/Vordergrundfarbe
                  lea      vtc_con(pc),a0
                  lea      vtc_rawcon(pc),a1
                  subq.w   #1,d0          ;1 Plane ?
                  bne.s    vt_set_b_exit
vt_set_b_mono:    subq.l   #1,d1          ;Vordergrund 1/ Hintergrund 0 ?
                  bne.s    vt_set_b_ok
                  lea      vtm_con(pc),a0 ;schnelle Ausgabe fuer sw
                  lea      vtm_rawcon(pc),a1
vt_set_b_ok:      move.l   a0,con_vec
                  move.l   a1,rawcon_vec
                  movea.l  nvdi_bios_tab(pc),a1
                  move.l   a0,_con_vec(a1)
                  move.l   rawcon_vec(pc),_rawcon_vec(a1)
vt_set_b_exit:    move.l   con_vec(pc),con_state.w ;Sprungadresse
                  rts

/*
 * Background color (VT52 ESC c)
 */
vt_seq_c:         move.l   #vt_set_c,con_state.w
                  rts
vt_set_c:         and.w    #1,d1
                  move.w   d1,V_COL_BG.w
                  bra.s    vt_set_b_in

/*
 * Erase to start of page (VT52 ESC d)
 */
vt_seq_d:         bsr.s    vt_seq_o       ;ab Zeilenanfang loeschen
                  move.w   V_CUR_XY1.w,d1 ;Textzeile
                  beq.s    vt_seq_d_exit
                  movem.l  d2-d7/a1-a6,-(sp)
                  mulu     V_CEL_HT.w,d1
                  move.w   d1,d7
                  subq.w   #1,d7          ;Zeilenzaehler
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1  ;Seitenanfang
                  bra      clear_lines    ;loeschen/Register zurueck
vt_seq_d_exit:    rts

/*
 * Show cursor (VT52 ESC e)
 */
vt_seq_e:         tst.w    V_HID_CNT.w
                  beq.s    vt_seq_e_exit
                  move.w   #1,V_HID_CNT.w
                  bra      cursor_on
vt_seq_e_exit:    rts

/*
 * Hide cursor (VT52 ESC f)
 */
vt_seq_f:         bra      cursor_off

/*
 * Save cursor (VT52 ESC j)
 */
vt_seq_j:         bset     #CURSOR_SAVED,V_STAT_0.w
                  move.l   V_CUR_XY0.w,V_SAV_XY.w
                  rts

/*
 * Restore cursor (VT52 ESC k)
 */
vt_seq_k:         movem.w  V_SAV_XY.w,d0-d1

                  bclr     #CURSOR_SAVED,V_STAT_0.w
                  bne      set_cursor_xy
                  moveq    #0,d0
                  moveq    #0,d1
                  bra      set_cursor_xy

/*
 * Erase line (VT52 ESC l)
 */
vt_seq_l:         bsr      cursor_off
                  bsr      set_x0         ;Zeilenanfang
                  bsr      clear_line
                  bra      cursor_on

/*
 * Erase to line start (VT52 ESC o)
 */
vt_seq_o:         move.w   d0,d2
                  subq.w   #1,d2          ;Spaltenanzahl -1
                  bmi.s    vt_seq_o_exit
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1
                  mulu     V_CEL_WR.w,d1
                  adda.l   d1,a1          ;Zeilenanfang
                  bra      clear_line_part
vt_seq_o_exit:    rts

/*
 * REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
 */
v_rvon:
vt_seq_p:         bset     #INVERSE,V_STAT_0.w
                  rts

/*
 * REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
 */
v_rvoff:
vt_seq_q:         bclr     #INVERSE,V_STAT_0.w
                  rts

/*
 * Wrap at end of line (VT52 ESC v)
 */
vt_seq_v:         bset     #WRAP,V_STAT_0.w
                  rts

/*
 * Discard end of line (VT52 ESC w)
 */
vt_seq_w:         bclr     #WRAP,V_STAT_0.w
                  rts

scroll_up_page:   movem.l  d2-d7/a1-a6,-(sp)
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1
                  movea.l  a1,a0
                  move.w   V_CEL_WR.w,d7  ;Bytes pro Textzeile
                  adda.w   d7,a0
                  mulu     V_CEL_MY.w,d7  ;* Zeilenanzahl
                  divu     #SCROLL_LINE,d7
                  subq.w   #1,d7          ;wegen dbf
scroll_up2:       pea      clear_line2(pc)
scroll_up:        REPT 4
                  movem.l  (a0)+,d2-d6/a2-a6
                  movem.l  d2-d6/a2-a6,(a1)
                  movem.l  (a0)+,d2-d6/a2-a6
                  movem.l  d2-d6/a2-a6,40(a1)

                  lea      80(a1),a1
                  ENDM
                  dbra     d7,scroll_up
                  swap     d7
                  lsr.w    #1,d7
                  dbra     d7,scroll_upw
                  rts
scroll_upw:       move.w   (a0)+,(a1)+
                  dbra     d7,scroll_upw
                  rts

scroll_down_page: movem.l  d2-d7/a1-a6,-(sp)
                  movea.l  v_bas_ad.w,a0
                  adda.w   V_CUR_OF.w,a0
                  move.w   V_CEL_WR.w,d6  ;Bytes pro Textzeile
                  move.w   V_CEL_MY.w,d7  ;zu scrollenden Textzeilenanzahl
                  mulu     d6,d7          ;zu verschiebende Byteanzahl
                  lea      -40(a0,d7.l),a0 ;Ende der vorletzten Textzeile -40
                  lea      40(a0,d6.w),a1 ;Ende der letzten Textzeile
                  divu     #SCROLL_LINE,d7
                  subq.w   #1,d7          ;wegen dbf
                  bsr.s    scroll_down2
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1
                  bra.s    clear_line2
scroll_down:      lea      -40(a0),a0
scroll_down2:     REPT 4
                  movem.l  (a0),d2-d6/a2-a6
                  movem.l  d2-d6/a2-a6,-(a1)
                  movem.l  -40(a0),d2-d6/a2-a6
                  movem.l  d2-d6/a2-a6,-(a1)
                  lea      -80(a0),a0
                  ENDM
                  dbra     d7,scroll_down2
                  swap     d7
                  lea      40(a0),a0      ;um die -40 zu korrigieren !
                  lsr.w    #1,d7
                  dbra     d7,scroll_downw
                  rts
scroll_downw:     move.w   -(a0),-(a1)
                  dbra     d7,scroll_downw
                  rts

/*
 * Inputs:
 * a1 address of line
 */
clear_line:       movem.l  d2-d7/a1-a6,-(sp)
clear_line2:      move.w   V_CEL_HT.w,d7
                  subq.w   #1,d7
clear_lines:      move.w   V_CEL_MX.w,d5
                  addq.w   #1,d5
                  move.w   V_COL_BG.w,d6
                  movea.w  BYTES_LIN.w,a2

clear_mono:       moveq    #0,d2
                  lsr.w    #1,d6
                  negx.l   d2             ;je nach V_COL_BG schwarz oder weiss
                  suba.w   d5,a2
                  subq.w   #4,d5
                  lsr.w    #2,d5          ;/4
                  bcc.s    clear_mono2
                  lea      clear_scr_word(pc),a3
                  move.w   d5,d6
                  lsr.w    #7,d5          ;/128 Zaehler

                  not.w    d6
                  and.w    #127,d6
                  add.w    d6,d6
                  lea      clear_scr_mono(pc,d6.w),a4 ;Sprungadresse
                  move.w   d5,d6
                  jmp      (a3)
clear_mono2:      move.w   d5,d6
                  lsr.w    #7,d5          ;/128 Zaehler
                  not.w    d6
                  and.w    #127,d6
                  add.w    d6,d6
                  lea      clear_scr_mono(pc,d6.w),a3 ;Sprungadresse
/*
 * d5 counter inside line
 * d7 line counter
 * a2 offset to next line
 * a3 jump address
 */
clear_scrm_loop:  move.w   d5,d6
                  jmp      (a3)
clear_scr_word:   move.w   d2,(a1)+
                  jmp      (a4)
clear_scr_mono:   REPT 128
                  move.l   d2,(a1)+
                  ENDM
                  dbra     d6,clear_scr_mono
                  adda.w   a2,a1          ;naechste Zeile
                  dbra     d7,clear_scrm_loop
clear_lines_ex:   movem.l  (sp)+,d2-d7/a1-a6
                  rts

/*
 * clear screen
 * inputs:
 * -
 * outputs:
 * all registers preserved
 */
clear_screen:     movem.l  d2-d7/a1-a6,-(sp)
                  move.w   V_CEL_MY.w,d7  /* number of textlines -1 */
                  addq.w   #1,d7
                  mulu     V_CEL_HT.w,d7
                  subq.w   #1,d7          /* number of lines -1 */
                  movea.l  v_bas_ad.w,a1
                  adda.w   V_CUR_OF.w,a1  /* start address */
                  bra      clear_lines

/*
 * clear part of a line
 * inputs:
 * d2.w number of columns -1
 * a1.l address
 * a2.w bytes per line
 * outputs:
 * d0-d2/a0-a1 are trashed
 */
clear_line_part:  movem.l  d3-d6/a3-a4,-(sp)
                  moveq    #16,d0
                  sub.w    V_CEL_HT.w,d0
                  add.w    d0,d0
                  move.w   V_COL_BG.w,d4  /* background color */
                  moveq    #1,d5          /* PLANES */
                  move.w   d5,d6
                  add.w    d5,d5          /* plane offset */
                  subq.w   #1,d6          /* plane counter */
                  movea.l  a1,a3
clear_lp_bloop:   move.w   d2,d3
                  movea.l  a3,a0
                  lea      vtc_bg_white(pc),a4
                  lsr.w    #1,d4
                  bcc.s    clear_lp_loop
                  lea      vtc_bg_black(pc),a4
clear_lp_loop:    movea.l  a0,a1
                  jsr      (a4)
                  addq.l   #1,a0
                  move.l   a0,d1
                  lsr.w    #1,d1
                  bcs.s    clear_lp_dbf
                  subq.l   #2,a0
                  adda.w   d5,a0
clear_lp_dbf:     dbra     d3,clear_lp_loop
                  addq.l   #2,a3          ;naechste Plane
                  dbra     d6,clear_lp_bloop
                  movem.l  (sp)+,d3-d6/a3-a4
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;VDI-Escapes abarbeiten
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d1.l pb
;a0.l pb
;a6.l Workstation
;Ausgaben:
;-
v_escape:         movea.l  (a0),a1        ;contrl
                  move.w   opcode2(a1),d0 ;Unteropcode
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
                  move.w   #2,n_intout(a0) ;Eintraege in intout
                  rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:           addq.w   #1,V_HID_CNT.w ;Cursor aus
                  bclr     #CURSOR_STATE,V_STAT_0.w
                  bra      clear_screen   ;Bildschirm loeschen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:      clr.l    V_CUR_XY0.w    ;Spalte 0/Zeile 0
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Adresse des Cursors
                  move.l   con_vec,con_state.w  ;Zeiger auf VT-Routine
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

; OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
v_curtext:        movem.l  d1-d3/a2-a3,-(sp)
                  movea.l  pb_intin(a0),a3 ;intin
                  move.w   n_intin(a1),d3 ;Zeichenanzahl
                  subq.w   #1,d3          ;zu wenig Zeichen ?
                  bmi.s    v_curtext_exit
v_curtext_loop:   move.w   (a3)+,d1       ;Zeichen
                  movea.l  con_state.w,a0 ;Sprungadresse
                  jsr      (a0)
                  dbra     d3,v_curtext_loop
v_curtext_exit:   movem.l  (sp)+,d1-d3/a2-a3
                  rts

; INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15)
vq_curaddress:    addq.w   #1,d0
                  addq.w   #1,d1
                  move.w   d1,(a4)+       ;intout[0] = Zeile;
                  move.w   d0,(a4)+       ;intout[1] = Spalte;
                  move.w   #2,n_intout(a0) ;Eintraege in intout
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
                  addq.l   #2,a2          ;Adresse des Hintergrunds
undraw_1_plane:   move.l   (a2)+,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d2,undraw_1_plane
undraw_exit:      rts

;Draw Sprite ($A00D)
;Eingaben
;d0.w x
;d1.w y
;a0.l Zeiger auf die Spritedefinition
;a2.l Zeiger auf den Hintergrundbuffer
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
draw_sprite:      move.l   a6,-(sp)
                  move.w   6(a0),-(sp)    ;Hintergrundfarbe
                  move.w   8(a0),-(sp)    ;Vordergrundfarbe
                  clr.w    d2
                  tst.w    4(a0)          ;intform
                  bge.s    vdi_form       ;+1-> VDI-Format
                  moveq    #16,d2         ;-1-> XOR-Format

vdi_form:         move.w   d2,-(sp)       ;Offset fuer VDI/XOR-Routinen
                  clr.w    d2             ;Offset fuer MOVE-Routinen
                  sub.w    (a0),d0        ;X_Koord - intxhot
                  bcs.s    Xko_lt_intxh   ;X_Koord < intxhot

                  move.w   x_res(pc),d3   ;WORK_OUT[0] max. Rasterbreite
                  subi.w   #15,d3
                  cmp.w    d3,d0
                  bhi.s    X_am_rRand     ;X_koord > Rasterbreite-15
                  bra.s    get_yhot

Xko_lt_intxh:     addi.w   #16,d0         ;X_koord+16
                  moveq    #4,d2          ;Offset fuer MOVE-Routinen
                  bra.s    get_yhot

X_am_rRand:       moveq    #8,d2
get_yhot:         sub.w    2(a0),d1       ;Y_Koord - intyhot
                  lea      10(a0),a0      ;Zeiger auf das Sprite-Image
                  bcs.s    Y_am_oRand     ;Y_koord < intyhot

                  move.w   y_res(pc),d3   ;max. Rasterhoehe
                  subi.w   #15,d3         ;Rasterhoehe - 15
                  cmp.w    d3,d1

                  bhi.s    Y_am_uRand     ;Y_Koord > Rasterhoehe-15
                  moveq    #16,d5
                  bra.s    hole_Koord

Y_am_oRand:       move.w   d1,d5
                  addi.w   #16,d5
                  asl.w    #2,d1
                  suba.w   d1,a0
                  clr.w    d1
                  bra.s    hole_Koord

Y_am_uRand:       move.w   y_res(pc),d5   ;max. Rasterhoehe
                  sub.w    d1,d5
                  addq.w   #1,d5

hole_Koord:       bsr      calc_addr
                  andi.w   #15,d0

                  lea      draw_sprite_right(pc),a3
                  move.w   d0,d6          ;Xbit sichern
                  cmpi.w   #8,d6
                  bcs.s    load_drrout    ;Xbit < 8

;mindendestens 8 ROR-> daher ueber ROL gehen
                  lea      draw_sprite_left(pc),a3
                  move.w   #16,d6
                  sub.w    d0,d6          ;16 - ROR-Anzahl

load_drrout:      movea.l  draw_spr_tab1(pc,d2.w),a5
                  movea.l  draw_spr_tab2(pc,d2.w),a6

                  move.w   PLANES.w,d7
                  move.w   d7,d3
                  add.w    d3,d3          ;PLANES*2
                  ext.l    d3
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Pixelzeile

                  move.w   d5,(a2)+       ;Zeilenanzahl
                  move.l   a1,(a2)+       ;Quelladresse
                  cmpa.l   #draw_spr_word2,a6
                  bne.s    draw_x_ok
                  sub.l    d3,-4(a2)
draw_x_ok:        move.w   #$0300,(a2)+   ;Information in Langworten
                  subq.w   #1,d5
                  bpl.s    draw_spr_next  ;Verknuepfungsmode waehlen
                  bra.s    draw_spr_exit

draw_spr_tab1:    DC.L draw_spr_long
                  DC.L draw_spr_left
                  DC.L draw_spr_right
draw_spr_tab2:    DC.L draw_spr
                  DC.L draw_spr_word1
                  DC.L draw_spr_word2

draw_spr_loop:    clr.w    d0
                  lsr.w    2(sp)          ;Vordergrundfarbe
                  addx.w   d0,d0
                  lsr.w    4(sp)          ;Hintergrundfarbe
                  roxl.w   #3,d0
                  add.w    (sp),d0        ;Offset fuer VDI/XOR-Rout. addieren
                  movea.l  draw_spr_link(pc,d0.w),a4 ;Sprungadresse

                  move.w   d5,-(sp)
                  movem.l  a0-a2,-(sp)
                  jsr      (a6)           ;Bildebene ausgeben
                  movem.l  (sp)+,a0-a2
                  move.w   (sp)+,d5

                  addq.l   #2,a1          ;naechste Bildebene
                  addq.l   #2,a2          ;naechste Bufferebene

draw_spr_next:    dbra     d7,draw_spr_loop
draw_spr_exit:    addq.l   #6,sp
                  movea.l  (sp)+,a6
                  rts
; Adressen der Verknuepfungsroutinen
draw_spr_link:    DC.L draw_spr_vdi0
                  DC.L draw_spr_vdi1
                  DC.L draw_spr_vdi2
                  DC.L draw_spr_vdi3
                  DC.L draw_spr_eor0
                  DC.L draw_spr_eor1
                  DC.L draw_spr_eor2
                  DC.L draw_spr_eor3

;Hauptschleife, um eine Bildebenen auszugeben
;Eingaben
;d3.w Abstand zum naechsten Wort der Bildebene
;a1.l Zieladresse
;a2.l Sprite-Save-Buffer
;a3.l Adresse der Rotierroutine

;Ausgaben
;d2.l Hintergrund
draw_spr:         move.w   (a1),d2
                  move.w   d2,(a2)
                  adda.w   d3,a2
                  swap     d2
                  move.w   0(a1,d3.w),d2
                  move.w   d2,(a2)
                  adda.w   d3,a2
                  jmp      (a3)
draw_spr_long:    move.w   d2,0(a1,d3.w)
                  swap     d2
                  move.w   d2,(a1)
                  adda.w   d4,a1          ;naechste Zeile
                  dbra     d5,draw_spr
                  rts

draw_spr_word1:   move.w   (a1),d2
                  move.w   d2,(a2)
                  adda.w   d3,a2
                  move.w   0(a1,d3.w),(a2)
                  adda.w   d3,a2
                  jmp      (a3)
draw_spr_left:    move.w   d2,(a1)
                  adda.w   d4,a1          ;naechste Zeile
                  dbra     d5,draw_spr_word1
                  rts

draw_spr_word2:   move.w   (a1),d2
                  neg.w    d3
                  move.w   0(a1,d3.w),(a2)
                  neg.w    d3
                  adda.w   d3,a2
                  move.w   d2,(a2)
                  adda.w   d3,a2
                  swap     d2
                  jmp      (a3)
draw_spr_right:   swap     d2
                  move.w   d2,(a1)
                  adda.w   d4,a1          ;naechste Zeile
                  dbra     d5,draw_spr_word2
                  rts

;Spritezeile auslesen und rotieren
;Eingaben
;d6.l Shiftanzahl

;a0.l Zeiger auf Vorder- und Hintergrundmaske
;a4.l Adresse der Verknuepfenden Routine
;Ausgaben
;d0.l Vordergrundmaske
;d1.l Hintergrundmaske
draw_sprite_left: moveq    #0,d0
                  moveq    #0,d1
                  move.w   (a0)+,d0       ;Sprite
                  move.w   (a0)+,d1       ;Maske
                  rol.l    d6,d0          ;um Xbit rotieren
                  rol.l    d6,d1          ;um Xbit rotieren
                  jmp      (a4)           ;je nach Verknuepfung LINK-Rout. anspringen

draw_sprite_right:move.l   (a0)+,d0       ;Sprite/Maske
                  move.w   d0,d1
                  swap     d1
                  clr.w    d0             ;Sprite
                  clr.w    d1             ;Maske
                  ror.l    d6,d0          ;um Xbit rotieren
                  ror.l    d6,d1          ;um Xbit rotieren
                  jmp      (a4)           ;je nach Verknuepfung LINK-Rout. anspringen

;Verknuepfungsroutinen
;Eingaben
;d0.l Vordergrundmaske
;d1.l Hintergrundmaske
;d2.l Bildausschnitt
;a5.l Adresse der ausgebenden Routine
;Ausgaben
;d2.l Ausgabezeile
draw_spr_vdi0:    or.l     d1,d0
                  not.l    d0
                  and.l    d0,d2
                  jmp      (a5)
draw_spr_vdi1:    or.l     d0,d2
                  not.l    d1
                  and.l    d1,d2
                  jmp      (a5)
draw_spr_vdi2:    not.l    d0
                  and.l    d0,d2
                  or.l     d1,d2
                  jmp      (a5)
draw_spr_vdi3:    or.l     d0,d2
                  or.l     d1,d2
                  jmp      (a5)
draw_spr_eor0:    eor.l    d1,d2
                  not.l    d0
                  and.l    d0,d2
                  jmp      (a5)
draw_spr_eor1:    or.l     d0,d2
                  eor.l    d1,d2
                  jmp      (a5)
draw_spr_eor2:    not.l    d0
                  and.l    d0,d2
                  eor.l    d1,d2
                  jmp      (a5)
draw_spr_eor3:    eor.l    d0,d2
                  or.l     d1,d2
                  jmp      (a5)

;Adresse aufloesungsunabhaengig berechnen
;Eingaben
;d0.w x
;d1.w y
;Ausgaben
;d0.w x
;d1.w y
;a1.l Adresse
calc_addr:        move.w   d0,-(sp)
                  move.w   d1,-(sp)

                  movea.l  v_bas_ad.w,a1
                  muls     BYTES_LIN.w,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  and.w    #$fff0,d0
                  asr.w    #3,d0          ;Anzahl der Bytes
                  adda.w   d0,a1          ;Zieladresse
                  move.w   (sp)+,d1
                  move.w   (sp)+,d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Setmode'

palette_data:     DC.W $0fff,$00

init_hardware:
set_dflt_palette: movem.l  d0-d3/a0-a2/a6,-(sp)

                  lea      palette_data(pc),a0 ;Zeiger auf Palettendaten
                  moveq    #0,d3          ;Farbindex

set_palette:      move.w   d3,d0
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d4  ;Farbintensitaet im TT-Format
                  ror.w    #8,d4

                  moveq    #15,d0
                  moveq    #15,d1
                  moveq    #15,d2
                  and.w    d4,d0          ;Intensitaet von 0-15
                  mulu     #1000,d0
                  divu     d1,d0          ;Intensitaet in Promille (0-1000)
                  rol.w    #4,d4
                  and.w    d4,d1          ;Intensitaet von 0-15
                  mulu     #1000,d1
                  divu     d2,d1          ;Intensitaet in Promille (0-1000)
                  rol.w    #4,d4
                  and.w    d4,d2          ;Intensitaet von 0-15
                  mulu     #1000,d2
                  divu     #15,d2         ;Intensitaet in Promille (0-1000)

                  movem.l  d3/a0/a2,-(sp)
                  bsr      set_color_rgb
                  movem.l  (sp)+,d3/a0/a2

                  addq.w   #1,d3          ;Farbnummer erhoehen
                  cmp.w    #2,d3          ;schon alle Farben gesetzt?
                  blt.s    set_palette
                  movem.l  (sp)+,d0-d3/a0-a2/a6
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
                  move.l   x_res,res_x(a6) ;Aufloesung
                  move.w   #0,r_planes(a6)   ;Anzahl der Bildebenen -1
                  move.w   #1,colors(a6) ;hoechste Farbnummer
                  clr.w    res_ratio(a6)  ;Seitenverhaeltnis

                  move.l   res_x(a6),clip_xmax(a6) ;clip_xmax/clip_ymax

                  move.l   p_escapes(a6),escape_ptr
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
dummy:            rts

                  DATA
dev_name:         DC.B  'Mac 2 Farben',0
                  EVEN
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relokationsdaten'

relokation:

                  DC.W 0                  ;Ende der Daten

                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'BSS-Segment'
                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L  1
nvdi_bios_tab:    DS.L  1

con_vec:          DS.L  1
rawcon_vec:       DS.L  1

escape_ptr:       DS.L  1

rgb_in_tab:       DS.B 1002
rgb_out_tab:      DS.W 256
vdi_palette:      DS.W 6                  ;Palette zum Speichern der VDI-Farbintesitaeten

x_res:            DS.W 1                  ;adressierbare Rasterbreite (von 0 aus)
y_res:            DS.W 1                  ;adressierbare Rasterhoehe (von 0 aus)
pixw:             DS.W 1                  ;Pixelbreite in Mikrometern
pixh:             DS.W 1                  ;Pixelhoehe in Mikrometern
line_width:       DS.W 1                  ;Bytes pro Pixelzeile
vram:             DS.L 1                  ;Adresse des Video-RAMs

bios_tab:         DS.L 5                  ;alte NVDI-Bios-Vektoren
mouse_tab:        DS.L 4                  ;alte Vektoren in mouse_tab

mouse_len:        DS.W 1
mouse_addr:       DS.L 1
mouse_stat:       DS.W 1
mouse_savebuf:    DS.B 32*1

ds.l 128

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  END
