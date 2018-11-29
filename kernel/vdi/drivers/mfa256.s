;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                   256-Farb-Bildschirmtreiber fuer NVDI 3.0                 *;
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

PATTERN_LENGTH    EQU (32*8)              ;Fuellmusterlaenge bei 8 Ebenen


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
organisation:     DC.L  256                  ;Farben
                  DC.W  8                 ;Planes
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
                  moveq    #4,d0          ;4 Bits pro Farbintensitaet auf STE/TT
                  subq.w   #TT_VIDEO,d1   ;STE oder TT?
                  ble.s    scrninfo_clut
                  moveq    #6,d0          ;6 Bits pro Farbintensitaet auf dem Falcon

scrninfo_clut:    move.w   #0,(a0)+       ;[0] Interleaved Planes
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
                  moveq    #0,d1
                  lea      color_map(pc),a1
scrninfo_loop:    move.b   (a1)+,d1
                  move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

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
init_res_vd:      lea      out_tt_low(pc),a2
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
                  bne.s    init_res_raster
                  move.w   #1,INQ_TAB1.w  ;nur eine Farbabstufung
init_res_raster:  move.w   #2200,INQ_TAB6.w ;Anzahl der Rasteroperationen
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
                  move.w   #256,(a0)+ ;Farbstiftanzahl
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

out_tt_low:       DC.W 556,278,256,1,4096 ; TT 320*480

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_colors:      movem.l  d0-d2/a0-a2,-(sp)
                  lea      set_color_ptr(pc),a0
                  move.l   #set_color_rgb_tt,(a0)+
                  move.l   #get_color_rgb_tt,(a0)
                  cmp.w    #TT_VIDEO,video
                  beq.s    init_color_maps
                  move.l   #get_color_rgb_falcon,(a0)
                  move.l   #set_color_rgb_falcon,-(a0)

init_color_maps:  bsr      build_color_maps
                  bsr      init_palette
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Tabellen fuer die Umsetzung von VDI-Index in Farbwert bauen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;-
;Ausgaben:
;-
build_color_maps: movem.l  d0/a0-a2,-(sp)
                  movea.l  nvdi_struct,a2
                  movea.l  _nvdi_colmaptab(a2),a2
                  
                  movea.l  _color_map_ptr(a2),a0
                  lea      color_map,a1
                  moveq    #63,d0
copy_map_loop:    move.l   (a0)+,(a1)+
                  dbra     d0,copy_map_loop

                  movem.l  (sp)+,d0/a0-a2
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
                  move.w   0(a3,d0.w),d4

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

                  move.w   (sp)+,d3
                  addq.w   #1,d3
                  cmp.w    #256,d3
                  blt.s    init_pal_loop

init_pal_exit:    movem.l  (sp)+,d0-d4/a0-a3
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

IF 0
;Farbpaletten
palette:          DC.W $0fff,$0f00,$f0,$0ff0,$0f,$0f0f,$ff,$0ccc
                  DC.W $0888,$0a00,$a0,$0aa0,$0a,$0a0a,$aa,0
                  DC.W $0fff,$0eee,$0ddd,$0ccc,$0bbb,$0aaa,$0999,$0888
                  DC.W $0777,$0666,$0555,$0444,$0333,$0222,$0111,0
                  DC.W $0f00,$0f01,$0f02,$0f03,$0f04,$0f05,$0f06,$0f07
                  DC.W $0f08,$0f09,$0f0a,$0f0b,$0f0c,$0f0d,$0f0e,$0f0f
                  DC.W $0e0f,$0d0f,$0c0f,$0b0f,$0a0f,$090f,$080f,$070f
                  DC.W $060f,$050f,$040f,$030f,$020f,$010f,$0f,$1f
                  DC.W $2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f
                  DC.W $af,$bf,$cf,$df,$ef,$ff,$fe,$fd
                  DC.W $fc,$fb,$fa,$f9,$f8,$f7,$f6,$f5
                  DC.W $f4,$f3,$f2,$f1,$f0,$01f0,$02f0,$03f0
                  DC.W $04f0,$05f0,$06f0,$07f0,$08f0,$09f0,$0af0,$0bf0
                  DC.W $0cf0,$0df0,$0ef0,$0ff0,$0fe0,$0fd0,$0fc0,$0fb0
                  DC.W $0fa0,$0f90,$0f80,$0f70,$0f60,$0f50,$0f40,$0f30
                  DC.W $0f20,$0f10,$0b00,$0b01,$0b02,$0b03,$0b04,$0b05
                  DC.W $0b06,$0b07,$0b08,$0b09,$0b0a,$0b0b,$0a0b,$090b
                  DC.W $080b,$070b,$060b,$050b,$040b,$030b,$020b,$010b
                  DC.W $0b,$1b,$2b,$3b,$4b,$5b,$6b,$7b
                  DC.W $8b,$9b,$ab,$bb,$ba,$b9,$b8,$b7
                  DC.W $b6,$b5,$b4,$b3,$b2,$b1,$b0,$01b0
                  DC.W $02b0,$03b0,$04b0,$05b0,$06b0,$07b0,$08b0,$09b0
                  DC.W $0ab0,$0bb0,$0ba0,$0b90,$0b80,$0b70,$0b60,$0b50
                  DC.W $0b40,$0b30,$0b20,$0b10,$0700,$0701,$0702,$0703
                  DC.W $0704,$0705,$0706,$0707,$0607,$0507,$0407,$0307
                  DC.W $0207,$0107,$07,$17,$27,$37,$47,$57
                  DC.W $67,$77,$76,$75,$74,$73,$72,$71
                  DC.W $70,$0170,$0270,$0370,$0470,$0570,$0670,$0770
                  DC.W $0760,$0750,$0740,$0730,$0720,$0710,$0400,$0401
                  DC.W $0402,$0403,$0404,$0304,$0204,$0104,$04,$14
                  DC.W $24,$34,$44,$43,$42,$41,$40,$0140
                  DC.W $0240,$0340,$0440,$0430,$0420,$0410,$0fff,$00
ENDIF

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
                  move.w   #7,r_planes(a6)              ;Anzahl der Bildebenen -1
                  move.w   #255,colors(a6)            ;hoechste Farbnummer

                  move.l   res_x(a6),clip_xmax(a6)    ;clip_xmax/clip_ymax
                  
                  lea      organisation(pc),a0        ;Zeiger auf die Formatbeschreibung
                  move.l   (a0)+,bitmap_colors(a6)    ;Anzahl der gleichzeitig darstellbaren Farben
                  move.w   (a0)+,bitmap_planes(a6)    ;Anzahl der Farbebenen
                  move.w   (a0)+,bitmap_format(a6)    ;Pixelformat
                  move.w   (a0)+,bitmap_flags(a6)     ;Bitreihenfolge

                  move.l   #set_color_rgb,p_set_color_rgb(a6)
                  move.l   #get_color_rgb,p_get_color_rgb(a6)

wk_init_exit:     movea.l  (sp)+,a0
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
                  cmp.w    #16,d3         ;VDI-Farbindex < 16?
                  blt.s    set_color_rgb_p
                  lea      REQ_COL_X-(16*2*3).w,a1   ;VDI-Palette fuer die naechsten 240 Farben
set_color_rgb_p:  move.w   d3,d4
                  add.w    d4,d4
                  add.w    d3,d4
                  add.w    d4,d4          ;VDI-Farbindex * 6 fuer Tabellenzugriff
                  adda.w   d4,a1
                  move.w   d0,(a1)+       ;Rot in VDI-Palette eintragen
                  move.w   d1,(a1)+       ;Gruen in die VDI-Palette eintragen
                  move.w   d2,(a1)+       ;Blau in die VDI-Palette eintragen
                  lea      color_map(pc),a0
                  move.b   0(a0,d3),d3    ;Farbwert
                  movea.l  set_color_ptr(pc),a0
                  jmp      (a0)

set_color_rgb_tt: lea      TT_PALETTE.w,a0 ;Adresse der CLUT fuer TT
                  add.w    d3,d3
                  adda.w   d3,a0          ;Zeiger auf den CLUT-Eintrag
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
                  cmp.w    #16,d0         ;VDI-Farbindex < 16?
                  blt.s    get_color_rgb_p
                  lea      REQ_COL_X-(16*2*3).w,a0   ;VDI-Palette fuer die naechsten 240 Farben
get_color_rgb_p:  move.w   d0,d2
                  add.w    d2,d2
                  add.w    d0,d2
                  add.w    d2,d2          ;mit 6 multiplizieren
                  adda.w   d2,a0
                  lea      color_map(pc),a1
                  move.b   0(a1,d0.w),d0  ;Farbwert
                  move.l   get_color_ptr(pc),a1
                  jmp      (a1)

get_color_rgb_set:move.w   (a0)+,d0       ;Rot
                  move.w   (a0)+,d1       ;Gruen
                  move.w   (a0)+,d2       ;Blau
                  rts

get_color_rgb_tt: tst.w    d1
                  beq      get_color_rgb_set
                  move.w   TT_SHFTMODE.w,d1 ;TT Shift-Modus-Register
                  btst     #GRAY_BIT,d1   ;Graustufenmodus ?
                  bne.s    get_color_grey
                  movea.l  d3,a1          ;Register sichern
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

get_color_grey:   move.w   (a0)+,d0       ;Rot
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

dev_name:         DC.B  'Bildschirm 256 Farben',0
                  EVEN
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  BSS

cpu020:           DS.W 1                  ;Prozessortyp
video:            DS.W  1                 ;Videohardware
modecode:         DS.W  1                 ;Falcon-Modecode

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct
driver_struct:    DS.L  1                 ;Zeiger auf die Treiberstruktur DEVICE_DRIVER

set_color_ptr:    DS.L  1                 ;interner Zeiger fuer set_color_rgb
get_color_ptr:    DS.L  1                 ;interner Zeiger fuer get_color_rgb

old_xbios_vec:    DS.L  1                 ;Zeiger auf die XBIOS-Routinen des Kernels

falcon_res:       DS.W  8                 ;temporaere Daten fuer Falcon-Aufloesungen (init_res)

color_map:        DS.B  256

                  END
