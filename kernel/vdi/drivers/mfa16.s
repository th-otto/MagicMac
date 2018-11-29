;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                   16-Farb-Bildschirmtreiber fuer NVDI 3.0                  *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ;'Header'

VERSION           EQU $0313

.INCLUDE "..\include\linea.inc"
.INCLUDE "..\include\tos.inc"
.INCLUDE "..\include\hardware.inc"

.INCLUDE "..\include\nvdi_wk.inc"
.INCLUDE "..\include\vdi.inc"
.INCLUDE "..\include\driver.inc"                

PATTERN_LENGTH    EQU (32*4)              ;Fuellmusterlaenge bei 4 Ebenen

                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Initialisierung'
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
;d3.w ID
;a0.l Zeiger auf nvdi_struct
;a1.l Zeiger auf Treiberstruktur DEVICE_DRIVER
;Ausgaben:
;d0.l Laenge der Workstation oder 0L bei einem Fehler
init:             movem.l  d0-d2/a0-a2,-(sp)
                  move.l   a0,nvdi_struct
                  move.l   a1,driver_struct
                  
                  movea.l  nvdi_struct(pc),a0
                  movea.l  _nvdi_load_NOD_driver(a0),a2
                  lea      organisation(pc),a0
                  jsr      (a2)           ;DRIVER  *load_NOD_driver( ORGANISATION *info );

                  movea.l  driver_struct,a1
                  move.l   a0,driver_offscreen(a1) ;kein Treiber vorhanden?
                  beq      init_err

                  bsr      save_screen_vecs
                  bsr      set_screen_vecs
                  
                  movea.l  nvdi_struct(pc),a0
                  move.w   _nvdi_cpu020(a0),cpu020
                  move.w   _nvdi_cookie_VDO(a0),video
                  move.w   _nvdi_modecode(a0),modecode

                  bsr      init_res       ;VDI-Variablen initialisieren
                  bsr      init_colors
                  
init_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  move.l   #WK_LENGTH+PATTERN_LENGTH,d0 ;Laenge einer Workstation
                  rts

init_err:         movem.l  (sp)+,d0-d2/a0-a2
                  moveq    #0,d0          ;Fehler aufgetreten
                  rts

save_screen_vecs: movea.l  nvdi_struct(pc),a0
                  rts

set_screen_vecs:  movea.l  nvdi_struct(pc),a0
                  rts
                  
reset_screen_vecs:   movea.l  nvdi_struct(pc),a0
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
                  bsr.s    reset_screen_vecs
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Ausgaben von v_opnwk()/v_opnvwk()/v_opnbm() zurueckliefern
;Aus Kompatibilitaetsgruenden werden die LINEA-Variablen zurueckgeliefert
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
                  moveq    #44,d0         ;45 Elemente kopieren
                  lea      DEV_TAB.w,a2
get_opnwk_int:    move.w   (a2)+,(a0)+
                  dbra     d0,get_opnwk_int
                  moveq    #11,d0         
                  lea      SIZ_TAB.w,a2
get_opnwk_pts:    move.w   (a2)+,(a1)+
                  dbra     d0,get_opnwk_pts
                  movem.l  (sp)+,d0/a0-a2
                  rts

;Ausgaben von vq_extnd() zurueckliefern
;Aus Kompatibilitaetsgruenden werden die LINEA-Variablen zurueckgeliefert
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
                  lea      INQ_TAB.w,a2
                  moveq    #44,d0         ;45 Elemente kopieren
ext_out_int:      move.w   (a2)+,(a0)+
                  dbra     d0,ext_out_int
                  
                  move.w   #1,38-90(a0)      ;work_out[19]: Clipping an
                  
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_extnd_work_out(a2),a2
                  lea      90(a2),a2

                  moveq    #11,d0         
ext_out_pts:      move.w   (a2)+,(a1)+
                  dbra     d0,ext_out_pts
                  lea      clip_xmin(a6),a2
                  move.l   (a2)+,0-24(a1)    ;work_out[46/47]: clip_xmin/clip_ymin
                  move.l   (a2)+,4-24(a1)    ;work_out[48/49]: clip_xmax/clip_ymax
                  
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
get_scrninfo:     movem.l  d0-d2/a0-a1,-(sp)
                  move.w   video(pc),d1
                  moveq    #3,d0          ;3 Bits pro Farbintensitaet auf ST
                  cmpi.w   #ST_VIDEO,d1   ;ST?
                  beq.s    scrninfo_clut
                  moveq    #4,d0          ;4 Bits pro Farbintensitaet auf STE/TT
                  subq.w   #TT_VIDEO,d1   ;STE oder TT?
                  ble.s    scrninfo_clut
                  moveq    #6,d0          ;6 Bits pro Farbintensitaet auf dem Falcon

scrninfo_clut:    move.w   #0,(a0)+       ;[0] Interleaved Planes
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
                  moveq    #0,d1
                  lea      color_map(pc),a1
scrninfo_loop:    move.b   (a1)+,d1
                  move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop
                  move.w   #239,d0
                  moveq    #15,d1
scrninfo_loop2:   move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop2

                  movem.l  (sp)+,d0-d2/a0-a1
                  rts
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Initialisierung'

;Aufloesungsabhaengige Daten initialisieren
;Eingaben
;xres, yres, line_width, pixw, pixh, fonts
;Ausgaben
;kein Register wird zerstoert
init_res:         movem.l  d0-d2/a0-a2,-(sp)
                  move.w   video(pc),d0   ;Videohardware
                  cmp.w    #FALCON_VIDEO,d0 ;Falcon-Video-Hardware?
                  bne.s    init_res_vd
                  bsr      init_res_falcon ;Eintrag fuer Falcon zusammenstellen
                  bra.s    init_res_set
init_res_vd:      lea      out_st_low(pc),a2
                  cmp.w    #ST_VIDEO,d0
                  beq.s    init_res_set
                  lea      out_tt_ste_low(pc),a2
                  cmpi.b   #0,sshiftmd.w  ;ST-niedrig?
                  beq.s    init_res_set
                  lea      out_tt_mid(pc),a2 
init_res_set:     lea      DEV_TAB.w,a1   ;work_out fuer v_opnwk/v_opnvwk
                  move.w   V_REZ_HZ.w,(a1)
                  subq.w   #1,(a1)+       ;adressierbare Rasterbreite
                  move.w   V_REZ_VT.w,(a1)
                  subq.w   #1,(a1)+       ;adressierbare Rasterhoehe
                  clr.w    (a1)+          ;genaue Skalierung moeglich !
                  move.l   (a2)+,(a1)+    ;Pixelbreite/Pixelhoehe
                  moveq    #39,d0         ;40 Elemente kopieren
                  movea.l  nvdi_struct(pc),a0
                  movea.l  _nvdi_opnwk_work_out(a0),a0
                  lea      10(a0),a0      ;work_out + 5
init_res_opn:     move.w   (a0)+,(a1)+
                  dbra     d0,init_res_opn
                  move.w   (a2)+,DEV_TAB13.w ;Farbanzahl
                  move.w   (a2)+,DEV_TAB35.w ;Farbdarstellungsflag
                  move.w   (a2)+,DEV_TAB39.w ;Anzahl der Farbabstufungen

                  moveq    #11,d0
                  lea      SIZ_TAB.w,a1   ;work_out[45-56]
init_res_opn2:    move.w   (a0)+,(a1)+ 
                  dbra     d0,init_res_opn2

                  moveq    #44,d0         ;45 Elemente kopieren
                  movea.l  nvdi_struct(pc),a0
                  movea.l  _nvdi_extnd_work_out(a0),a0
                  lea      INQ_TAB0.w,a1  ;work_out fuer vq_extnd
init_res_ext:     move.w   (a0)+,(a1)+
                  dbra     d0,init_res_ext

                  move.w   DEV_TAB39.w,INQ_TAB1.w ;Anzahl der Farbabstufungen
                  move.w   PLANES.w,INQ_TAB4.w ;Anzahl der Bildebenen
                  move.w   DEV_TAB35.w,INQ_TAB5.w ;CLUT-Unterstuetzung
                  move.w   #2200,INQ_TAB6.w ;Anzahl der Rasteroperationen
                  cmpi.w   #STE_VIDEO,video ;nur ST-Hardware ?
                  ble.s    init_res_exit
                  move.w   #5000,INQ_TAB6.w ;Anzahl der Rasteroperationen
init_res_exit:    movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Ausgaben:
;a2.l Zeiger auf Daten fuer init_res
init_res_falcon:  movem.l  d0-d2/a0-a1,-(sp)
                  move.w   modecode(pc),d0
                  lea      falcon_res(pc),a0
                  movea.l  a0,a2
                  move.w   #278,d1
                  cmpi.w   #640,V_REZ_HZ.w
                  bge.s    init_res_flc_x
                  add.w    d1,d1          ;Pixelbreite verdoppeln
init_res_flc_x:   move.w   d1,(a0)+
                  move.w   #278,d1
                  cmpi.w   #400,V_REZ_VT.w
                  bge.s    init_res_flc_y
                  add.w    d1,d1          ;Pixelhoehe verdoppeln
init_res_flc_y:   move.w   d1,(a0)+
                  moveq    #7,d1
                  and.w    d0,d1
                  add.w    d1,d1
                  move.w   #16,(a0)+ ;Farbstiftanzahl
                  move.w   #1,(a0)+ ;Farbdarstellungsflag
                  move.w   #4096,(a0)+    ;STE/TT-kompatibel
                  btst     #STC_BIT,d0
                  bne.s    init_res_flc_cw
                  clr.w    -2(a0)         ;mehr als 32767 Abstufungen
init_res_flc_cw:  movem.l  (sp)+,d0-d2/a0-a1
                  rts

;1 Pixelbreite
;2 Pixelhoehe
;3 Farbanzahl
;4 Farbdarstellungsflag
;5 Anzahl der Farbabstufungen
;work_out[3/4/5/13/35/39/47/48] fuer TT

out_tt_mid:       DC.W 278,278,16,1,4096  ; 4 TT 640*480
out_tt_ste_low:   DC.W 556,556,16,1,4096  ; 0 ST 320*200
out_st_low:       DC.W 556,556,16,1,512   ; 0 ST 320*200

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_colors:      movem.l  d0-d2/a0-a2,-(sp)
                  lea      set_color_ptr(pc),a0
                  move.l   #set_color_rgb_st,(a0)+
                  move.l   #get_color_rgb_st,(a0)
                  move.w   video(pc),d0
                  beq.s    init_color_pal
                  move.l   #get_color_rgb_ste,(a0)
                  move.l   #set_color_rgb_ste,-(a0)
                  subq.w   #STE_VIDEO,d0
                  beq.s    init_color_pal
                  move.l   #set_color_rgb_tt,(a0)+
                  move.l   #get_color_rgb_tt,(a0)
                  subq.w   #TT_VIDEO-STE_VIDEO,d0
                  beq.s    init_color_pal
                  move.l   #get_color_rgb_falcon,(a0)
                  move.l   #set_color_rgb_falcon,-(a0)

init_color_pal:   bsr      init_palette
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Farbpalette abhaengig von der XBIOS-Aufloesung setzen
;Vorgaben:
;kein Register wird zerstoert
;Eingaben:
;a6.l Workstation
;Ausgaben:
;-
init_palette:     movem.l  d0-d4/a0-a3,-(sp)

                  cmpi.w   #TT_VIDEO,video
                  bne.s    init_pal_colors

                  clr.w    -(sp)          ;kein Graumodus
                  move.w   #ESETGRAY,-(sp)
                  trap     #XBIOS
                  addq.l   #4,sp

                  clr.w    -(sp)          ;Bank 0 setzen
                  move.w   #ESETBANK,-(sp)
                  trap     #XBIOS
                  addq.l   #4,sp

init_pal_colors:  moveq    #0,d3          ;VDI-Farbnummer
                  lea      color_map(pc),a2
                  lea      palette_data(pc),a3

init_pal_loop:    move.w   d3,-(sp)
                  moveq    #0,d0
                  move.b   (a2)+,d0
                  add.w    d0,d0
                  move.w   0(a3,d0.w),d2

                  ror.w    #8,d2
                  moveq    #15,d0
                  and.w    d2,d0
                  mulu     #1000,d0       
                  divu     #15,d0         ;in Promille wandeln
                  rol.w    #4,d2
                  moveq    #15,d1
                  and.w    d2,d1
                  mulu     #1000,d1       
                  divu     #15,d1         ;in Promille wandeln
                  rol.w    #4,d2
                  and.w    #15,d2
                  mulu     #1000,d2       
                  divu     #15,d2         ;in Promille wandeln

                  bsr      set_color_rgb

                  move.w   (sp)+,d3
                  addq.w   #1,d3
                  cmp.w    #16,d3
                  blt.s    init_pal_loop

init_pal_exit:    movem.l  (sp)+,d0-d4/a0-a3
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Farbpaletten
palette_data:        
DC.w $0fff, $0f00, $00e0, $0ff0, $000f, $0e39, $01cb, $0ddd
DC.w $0888, $0800, $0080, $0ba3, $0008, $0808, $0088, $0111

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;WK-Tabelle intialisieren
;Eingaben
;d1.l pb oder 0L
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:          move.l   a0,-(sp)

                  move.l   DEV_TAB0.w,res_x(a6)       ;Aufloesung
                  move.l   DEV_TAB3.w,pixel_width(a6) ;Pixelbreite/Pixelhoehe
                  move.w   #3,r_planes(a6)              ;Anzahl der Bildebenen -1
                  move.w   #15,colors(a6)             ;hoechste Farbnummer

                  move.l   res_x(a6),clip_xmax(a6)    ;clip_xmax/clip_ymax

                  lea      organisation(pc),a0        ;Zeiger auf die Formatbeschreibung
                  move.l   (a0)+,bitmap_colors(a6)    ;Anzahl der gleichzeitig darstellbaren Farben
                  move.w   (a0)+,bitmap_planes(a6)    ;Anzahl der Farbebenen
                  move.w   (a0)+,bitmap_format(a6)    ;Pixelformat
                  move.w   (a0)+,bitmap_flags(a6)     ;Bitreihenfolge

                  move.l   #set_color_rgb,p_set_color_rgb(a6)
                  move.l   #get_color_rgb,p_get_color_rgb(a6)

                  movea.l  (sp)+,a0
                  rts

wk_reset:         rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
set_color_rgb:    lea      REQ_COL.w,a1   ;VDI-Palette fuer die ersten 16 Farben
                  move.w   d3,d4
                  add.w    d4,d4
                  add.w    d3,d4
                  add.w    d4,d4          ;VDI-Farbindex * 6 fuer Tabellenzugriff
                  adda.w   d4,a1
                  lea      color_map(pc),a0
                  move.b   0(a0,d3),d3    ;Farbwert
                  movea.l  set_color_ptr(pc),a0
                  jmp      (a0)

set_color_rgb_st: move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen
                  lea      ST_PALETTE.w,a0
                  add.w    d3,d3
                  adda.w   d3,a0          ;Zeiger auf den CLUT-Eintrag
                  moveq    #0,d3
                  move.w   d0,d3
                  lsl      #3,d3
                  sub.w    d0,d3          ;*7
                  add.w    #500,d3
                  divu     #1000,d3       ;Rot-Intensitaet von 0 - 7
                  move.w   d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d1,d3
                  lsl.w    #3,d3
                  sub.w    d1,d3          ;*7
                  add.w    #500,d3
                  divu     #1000,d3       ;Blau-Intensitaet von 0 - 7
                  add.w    d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d2,d3
                  lsl.w    #3,d3
                  sub.w    d2,d3          ;*7
                  add.w    #500,d3
                  divu     #1000,d3       ;Gruen-Intensitaet von 0 - 7
                  add.w    d3,d4
                  move.w   d4,(a0)        ;in die CLUT eintragen
                  rts

set_color_rgb_ste:   move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen
                  lea      ST_PALETTE.w,a0
                  add.w    d3,d3
                  adda.w   d3,a0          ;Zeiger auf den CLUT-Eintrag
                  moveq    #0,d3
                  move.w   d0,d3
                  lsl      #4,d3
                  sub.w    d0,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Rot-Intensitaet von 0 - 15
                  lsr.w    #1,d3          ;Bittausch fuer STE
                  bcc.s    set_col_ste_ncr
                  addq.w   #8,d3          ;Bit 3 setzen
set_col_ste_ncr:  move.w   d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d1,d3
                  lsl.w    #4,d3
                  sub.w    d1,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Gruen-Intensitaet von 0 - 15
                  lsr.w    #1,d3          ;Bittausch fuer STE
                  bcc.s    set_col_ste_ncg
                  addq.w   #8,d3          ;Bit 3 setzen
set_col_ste_ncg:  add.w    d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d2,d3
                  lsl.w    #4,d3
                  sub.w    d2,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Blau-Intensitaet von 0 - 15
                  lsr.w    #1,d3          ;Bittausch fuer STE
                  bcc.s    set_col_ste_ncb
                  addq.w   #8,d3          ;Bit 3 setzen
set_col_ste_ncb:  add.w    d3,d4
                  move.w   d4,(a0)        ;in die CLUT eintragen
                  rts

set_color_rgb_tt: lea      TT_PALETTE.w,a0 ;Adresse der CLUT fuer TT
                  move.w   TT_SHFTMODE.w,d4 ;TT-Shift-Modus-Register
                  and.w    #PALETTE,d4    ;Nummer der Bank
                  lsl.w    #5,d4          ;Palettennummer * 16 * 2
                  add.w    d3,d3
                  add.w    d4,d3          ;Offset des anzusprechenden Farbeintrags
                  adda.w   d3,a0          ;Zeiger auf den CLUT-Eintrag
                  cmp.w    #(16*2),d3     ;Farbindex < 16?
                  blt.s    set_col_rgb_tt_p
                  lea      REQ_COL_X-(16*2*3)-REQ_COL(a1),a1  ;VDI-Palette fuer die naechsten 240 Farben
set_col_rgb_tt_p: move.w   d4,d3
                  add.w    d3,d3
                  add.w    d4,d3          ;Bank * 16 * 2 * 3 
                  adda.w   d3,a1          ;Zeiger auf den VDI-Paletteneintrag
                  move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen
                  move.w   TT_SHFTMODE.w,d4 ;TT-Shift-Modus-Register
                  btst     #GRAY_BIT,d4   ;Graustufenmodus ?
                  bne.s    set_color_grey
                  moveq    #0,d3
                  move.w   d0,d3
                  lsl.w    #4,d3
                  sub.w    d0,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Rot-Intensitaet von 0 - 15
                  move.w   d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d1,d3
                  lsl.w    #4,d3
                  sub.w    d1,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Gruen-Intensitaet von 0 - 15
                  add.w    d3,d4
                  lsl.w    #4,d4
                  moveq    #0,d3
                  move.w   d2,d3
                  lsl.w    #4,d3
                  sub.w    d2,d3          ;*15
                  add.w    #500,d3
                  divu     #1000,d3       ;Blau-Intensitaet von 0 - 15
                  add.w    d3,d4
                  move.w   d4,(a0)        ;in die CLUT eintragen
                  rts

set_color_grey:   mulu     #30,d0         ;Rot mit 30% Graustufenanteil
                  divu     #100,d0
                  move.w   d0,d4
                  mulu     #59,d1         ;Gruen mit 59% Graustufenanteil
                  divu     #100,d1
                  add.w    d1,d4
                  mulu     #11,d2         ;Blau mit 11% Graustufenanteil
                  divu     #100,d2
                  add.w    d2,d4
                  mulu     #255,d4
                  divu     #1000,d4       ;Grauwert von 0 - 255
                  move.w   d4,(a0)        ;in die CLUT eintragen
                  rts

set_color_rgb_falcon:
                  move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen
                  move.l   a2,-(sp)
                  clr.l    -(sp)
                  movea.l  sp,a0
                  addq.l   #1,a0

                  move.w   #1000,d4
                  
                  mulu     #255,d0
                  divu     d4,d0
                  move.b   d0,(a0)+       ;Rot-Intensitaet von 0 - 255
                  mulu     #255,d1
                  divu     d4,d1
                  move.b   d1,(a0)+       ;Gruen-Intensitaet von 0 - 255
                  mulu     #255,d2
                  divu     d4,d2
                  move.b   d2,(a0)+       ;Blau-Intensitaet von 0 - 255

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
;d0.w Rot-Intensitaet in Promille
;d1.w Gruen-Intensitaet in Promille
;d2.w Blau-Intensitaet in Promille
get_color_rgb:    lea      REQ_COL.w,a0   ;VDI-Palette fuer die ersten 16 Farben
                  move.w   d0,d2
                  add.w    d2,d2
                  add.w    d0,d2
                  add.w    d2,d2          ;mit 6 multiplizieren
                  adda.w   d2,a0
                  lea      color_map(pc),a1
                  move.b   0(a1,d0.w),d0  ;Farbwert
                  move.l   get_color_ptr(pc),a1
                  jmp      (a1)

get_col_rgb_sett: move.w   TT_SHFTMODE.w,d1 ;TT Shift-Modus-Register
                  and.w    #PALETTE,d1    ;Nummer der TT-Palette
                  beq.s    get_color_rgb_set ;erste Bank?
                  lea      REQ_COL_X-(16*2*3)-REQ_COL(a0),a0  ;VDI-Palette fuer die naechsten 240 Farben
                  lsl.w    #5,d1          ;Palettennummer * 16 * 2
                  move.w   d1,d0
                  add.w    d0,d0
                  add.w    d1,d0          ;Bank * 16 * 2 * 3
                  adda.w   d0,a0          ;richtige Bank anwaehlen
get_color_rgb_set:move.w   (a0)+,d0       ;Rot
                  move.w   (a0)+,d1       ;Gruen
                  move.w   (a0)+,d2       ;Blau
                  rts
                  
get_color_rgb_st: tst.w    d1             ;vorgegebene Intensitaet?
                  beq.s    get_color_rgb_set
                  movea.l  d3,a1
                  lea      ST_PALETTE.w,a0 ;Adresse der CLUT
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d3  ;CLUT-Eintrag auslesen
                  ror.w    #8,d3
                  moveq    #7,d0
                  moveq    #7,d1
                  moveq    #7,d2
                  and.w    d3,d0          ;Rot-Intensitaet von 0 - 7
                  mulu     #1000,d0
                  divu     d1,d0
                  rol.w    #4,d3
                  and.w    d3,d1          ;Gruen-Intensitaet von 0 - 7
                  mulu     #1000,d1
                  divu     d2,d1
                  rol.w    #4,d3
                  and.w    d3,d2          ;Blau-Intensitaet von 0 - 7
                  mulu     #1000,d2
                  divu     #7,d2
                  move.l   a1,d3
                  rts                  

get_color_rgb_ste:tst.w    d1             ;vorgegebene Intensitaet?
                  beq.s    get_color_rgb_set
                  movea.l  d3,a1
                  lea      ST_PALETTE.w,a0 ;Adresse der CLUT
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d3  ;CLUT-Eintrag auslesen
                  ror.w    #8,d3
                  moveq    #15,d0
                  moveq    #15,d1
                  moveq    #15,d2
                  and.w    d3,d0          ;Rot-Intensitaet von 0 - 15
                  add.w    d0,d0
                  bclr     #4,d0          ;Bittausch fuer STE
                  beq.s    get_col_ste_ncr
                  addq.w   #1,d0
get_col_ste_ncr:  mulu     #1000,d0
                  divu     d1,d0
                  rol.w    #4,d3
                  and.w    d3,d1          ;Gruen-Intensitaet von 0 - 15
                  add.w    d1,d1
                  bclr     #4,d1          ;Bittausch fuer STE
                  beq.s    get_col_ste_ncg
                  addq.w   #1,d1
get_col_ste_ncg:  mulu     #1000,d1
                  divu     d2,d1
                  rol.w    #4,d3
                  and.w    d3,d2          ;Blau-Intensitaet von 0 - 15
                  add.w    d2,d2
                  bclr     #4,d2          ;Bittausch fuer STE
                  beq.s    get_col_ste_ncb
                  addq.w   #1,d2
get_col_ste_ncb:  mulu     #1000,d2
                  divu     #15,d2
                  move.l   a1,d3
                  rts                  

get_color_rgb_tt: tst.w    d1
                  beq      get_col_rgb_sett
                  move.w   TT_SHFTMODE.w,d1 ;TT Shift-Modus-Register
                  btst     #GRAY_BIT,d1   ;Graustufenmodus ?
                  bne.s    get_color_grey
                  movea.l  d3,a1          ;Register sichern
                  and.w    #PALETTE,d1    ;Nummer der TT-Palette
                  lsl.w    #4,d1          ;Palettennummer * 16
                  add.w    d1,d0          ;Nummer des anzusprechenden Farbeintrags
                  add.w    d0,d0
                  lea      TT_PALETTE.w,a0 ;Adresse der CLUT
                  move.w   0(a0,d0),d3    ;CLUT-Eintrag auslesen
                  ror.w    #8,d3
                  moveq    #15,d0
                  moveq    #15,d1
                  moveq    #15,d2
                  and.w    d3,d0          ;Rot-Intensitaet von 0 - 15
                  mulu     #1000,d0
                  divu     d1,d0
                  rol.w    #4,d3
                  and.w    d3,d1          ;Gruen-Intensitaet von 0 - 15
                  mulu     #1000,d1
                  divu     d2,d1
                  rol.w    #4,d3
                  and.w    d3,d2          ;Blau-Intensitaet von 0 - 15
                  mulu     #1000,d2
                  divu     #15,d2
                  move.l   a1,d3
                  rts                  

get_color_grey:   and.w    #PALETTE,d1    ;Nummer der TT-Palette
                  beq.s    get_color_grey_n  ;erste Bank?
                  lea      REQ_COL_X-(16*2*3)-REQ_COL(a0),a0  ;VDI-Palette fuer die naechsten 240 Farben
                  lsl.w    #5,d1          ;Palettennummer * 16 * 2
                  move.w   d1,d0
                  add.w    d0,d0
                  add.w    d1,d0          ;Bank * 16 * 2 * 3
                  adda.w   d0,a0          ;richtige Bank auswaehlen
                  
get_color_grey_n: move.w   (a0)+,d0       ;Rot
                  move.w   (a0)+,d1       ;Gruen
                  move.w   (a0)+,d2       ;Blau
                  rts

get_color_rgb_falcon:   tst.w d1
                  beq      get_color_rgb_set
                  movem.l  d3-d4/a2,-(sp)
                  clr.l    -(sp)          ;Platz fuer XRGB-Buffer

                  move.l   sp,-(sp)       ;Buffer
                  move.w   #1,-(sp)       ;nur eine Intensitaet
                  move.w   d0,-(sp)       ;Farbnummer
                  move.w   #VGETRGB,-(sp)
                  trap     #XBIOS
                  lea      10(sp),sp      ;Stack korrigieren

                  moveq    #2,d3
                  moveq    #63,d4         ;64 Abstufungen pro Farbkanal
                  btst     #STC_BIT,modecode+1 ;ST-Kompatibilitaet?
                  beq.s    vq_color_fout
                  moveq    #4,d3
                  moveq    #15,d4         ;16 Abstufungen pro Farbkanal
vq_color_fout:    movea.l  sp,a1
                  addq.l   #1,a1

                  moveq    #0,d0
                  moveq    #0,d1
                  moveq    #0,d2
                  move.b   (a1)+,d0
                  lsr.b    d3,d0
                  mulu     #1000,d0
                  divu     d4,d0
                  move.b   (a1)+,d1
                  lsr.b    d3,d1
                  mulu     #1000,d1
                  divu     d4,d1
                  move.b   (a1)+,d2
                  lsr.b    d3,d2
                  mulu     #1000,d2
                  divu     d4,d2

                  addq.l   #4,sp          ;Platz fuer XRGB-Buffer freigeben
                  movem.l  (sp)+,d3-d4/a2
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  DATA

dev_name:         DC.B  'Bildschirm 16 Farben',0
                  EVEN

;Farbumwandlungstabelle fuer 16 Farben
color_map:        DC.B 0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  BSS

cpu020:           DS.W  1                 ;Prozessortyp
video:            DS.W  1                 ;Videohardware
modecode:         DS.W  1                 ;Falcon-Modecode

nvdi_struct:      DS.L  1                 ;Zeiger auf nvdi_struct
driver_struct:    DS.L  1                 ;Zeiger auf die Treiberstruktur DEVICE_DRIVER

set_color_ptr:    DS.L  1                 ;interner Zeiger fuer set_color_rgb
get_color_ptr:    DS.L  1                 ;interner Zeiger fuer get_color_rgb

falcon_res:       DS.W  8                 ;temporaere Daten fuer Falcon-Aufloesungen (init_res)

                  END
