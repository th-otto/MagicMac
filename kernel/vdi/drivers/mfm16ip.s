;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*            4-Plane-Bildschirmtreiber fuer NVDI 3.0                         *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten

VERSION           EQU $0313

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"

.INCLUDE "..\include\pixmap.inc"

PATTERN_LENGTH    EQU (16*16)/4           ;Fuellmusterlaenge bei 4 Ebenen

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
organisation:     DC.L  16                ;Farben
                  DC.W  4                 ;Planes
                  DC.W  0                 ;Pixelformat
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

save_screen_vecs: rts

set_screen_vecs:  rts

reset_screen_vecs:   rts

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
                     
                  move.w   #16,26-90(a0)  ;work_out[13]: Anzahl der Farben
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
                  move.w   #4,8-90(a0)    ;work_out[4]: Anzahl der Farbebenen
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
                  moveq    #8,d0          ;Bits pro Farbintensitaet

                  move.w   #0,(a0)+       ;[0] Interleaved Planes
                  move.w   #1,(a0)+       ;[1] Hardware-CLUT
                  move.w   #4,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #16,(a0)+      ;[3/4] Farbanzahl
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

                  moveq    #15,d0
                  lea      color_map,a1
scrninfo_loop:    moveq    #0,d1
                  move.b   (a1)+,d1
                  move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

                  move.w   #239,d0
scrninfo_loop2:   move.w   #15,(a0)+
                  dbra     d0,scrninfo_loop2

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Farbpalette'

;Farbtabelle
palette_data:
DC.w $0fff, $0f00, $00e0, $0ff0, $000f, $0e39, $01cb, $0ddd
DC.w $0888, $0800, $0080, $0ba3, $0008, $0808, $0088, $0000
                  
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

                  move.w   #556,pixw
                  move.w   #556,pixh

                  movem.w  x_res,d0-d1    ;xres,yres
                  move.w   line_width,d2  ;Bytes pro Zeile

                  move.l   vram,v_bas_ad.w ;Bildadresse
                  move.w   #4,PLANES.w    ;Anzahl der Bildebenen
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
                  move.l   #15,V_COL_BG.w ;Hinter-/Vordergrundfarbe
                  move.w   #1,V_HID_CNT.w ;Cursor aus
                  move.w   #256,V_STAT_0.w ;blinken
                  move.w   #$1e1e,V_PERIOD.w ;Blinkrate des Cursors/Zaehler
                  move.l   v_bas_ad.w,V_CUR_AD.w ;Cursoradresse
                  clr.l    V_CUR_XY.w     ;Cursor nach links oben
                  clr.w    V_CUR_OF.w     ;Offset von v_bas_ad
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
                  cmp.w    #16,d3         ;schon alle 256 Farben gesetzt?
                  blt.s    set_palette
                  movem.l  (sp)+,d0-d4/a0-a2/a6
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '1. Kontrollfunktionen'

;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:

                  move.l   x_res,res_x(a6) ;Aufloesung
                  move.w   #3,r_planes(a6)   ;Anzahl der Bildebenen -1
                  move.w   #15,colors(a6) ;hoechste Farbnummer
                  clr.w    res_ratio(a6)  ;Seitenverhaeltnis

                  move.l   res_x(a6),clip_xmax(a6) ;clip_xmax/clip_ymax

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
                  DATA
                  ; 'Relozierungs-Information'
relokation:

                  DC.W 0
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Farbtabellen'

color_map:        DC.B 0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
color_remap:      DC.B 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dev_name:         DC.B  'Mac 16 Farben interleaved',0

                  EVEN
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0
driver_struct:    DS.L  1

x_res:            DS.W 1                  ;adressierbare Rasterbreite (von 0 aus)
y_res:            DS.W 1                  ;adressierbare Rasterhoehe (von 0 aus)
pixw:             DS.W 1                  ;Pixelbreite in Mikrometern
pixh:             DS.W 1                  ;Pixelhoehe in Mikrometern
line_width:       DS.W 1                  ;Bytes pro Pixelzeile
vram:             DS.L 1                  ;Adresse des Video-RAMs

rgb_in_tab:       DS.B  1002              ;UBYTE   rgb_in_tab[1002];
rgb_out_tab:      DS.W  256               ;UWORD   rgb_out_tab[256];
vdi_palette:      DS.W 48                 ;Palette zum Speichern der VDI-Farbintesitaeten
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
