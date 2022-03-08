;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*             Falcon-32768-Farb-Offscreen-Treiber fuer NVDI 4.1              *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ; 'Header'

VERSION           EQU $0411

INCLUDE "..\include\linea.inc"
INCLUDE "..\include\tos.inc"
INCLUDE "..\include\seedfill.inc"

INCLUDE "..\include\nvdi_wk.inc"
INCLUDE "..\include\vdi.inc"

INCLUDE "..\include\driver.inc"

PATTERN_LENGTH    EQU (32*16)             ;Fuellmusterlaenge bei 16 Ebenen
PAL_LENGTH        EQU 512                 ;Laenge der Pseudo-Palette
c_palette         EQU f_saddr+PATTERN_LENGTH ;Startadresse der Pseudo-Palette

m2                EQU 0                   ;Offset mit 2 multiplizieren
m4                EQU 1                   ;Offset mit 4 multiplizieren
m6                EQU 2                   ;Offset mit 6 multiplizieren

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'NVDI-Treiber initialisieren'
                  TEXT

start:
header:           bra.s continue          ;Fuer Aufrufe von normale Treibern
                  DC.B  'OFFSCRN',0       ;
                  DC.W  VERSION           ;Versionsnummer im BCD-Format
                  DC.W  header_end-header ;Laenge des Headers
                  DC.W  N_OFFSCREEN       ;Offscreen-Treiber
                  DC.L  init              ;Adresse der Installationsfkt.
                  DC.L  reset             ;Adresse der Reinstallationsfkt.
                  DC.L  wk_init
                  DC.L  wk_reset
                  DC.L  get_opnwkinfo
                  DC.L  get_extndinfo
                  DC.L  get_scrninfo
                  DC.L  get_resinfo
                  DC.L  0,0,0,0           ;reserviert
organisation:     DC.L  32768             ;Farben
                  DC.W  16                ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  2                 ;Bitverteilung
                  DC.W  0,0,0             ;reserviert
header_end:


continue:         rts

init:             movem.l  d0-d2/a0-a2,-(sp)

                  move.l   a0,nvdi_struct
                  bsr      make_relo      ;Treiber relozieren

                  bsr      build_exp      ;Expandier-Tabelle erstellen
                  bsr      build_color_maps  ;Farbcodierungstabellen erstellen
                  moveq    #5,d0          ;5 Bit Rot-Anteil
                  moveq    #5,d1          ;5 Bit Gruen-Anteil
                  moveq    #5,d2          ;5 Bit Blau-Anteil
                  bsr      init_rgb_tabs

init_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  move.l   #WK_LENGTH+PATTERN_LENGTH+PAL_LENGTH,d0 ;Laenge einer Workstation
                  rts

reset:            rts

;Ausgaben von v_opnwk()/v_opnvwk()/v_opnbm() zurueckliefern
;Vorgaben:
;-
;Eingaben:
;a0.l intout
;a1.l ptsout
;a6.l Workstation
;Ausgaben:
;-
get_opnwkinfo:    movem.l  d0/a0-a2,-(sp)
                  move.l   res_x(a6),(a0)+   ;adressierbare Rasterbreite
                  clr.w    (a0)+          ;genaue Skalierung moeglich !
                  move.l   pixel_width(a6),(a0)+ ;Pixelbreite/Pixelhoehe
                  moveq    #39,d0         ;40 Elemente kopieren
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_opnwk_work_out(a2),a2
                  lea      10(a2),a2      ;work_out + 5
work_out_int:     move.w   (a2)+,(a0)+
                  dbra     d0,work_out_int
                     
                  move.w   #256,26-90(a0) ;work_out[13]: Anzahl der Farben
                  move.w   #1,70-90(a0)   ;work_out[35]: Farbe ist vorhanden
                  clr.w    78-90(a0)      ;work_out[39]: mehr als 32767 Farbabstufungen in der Palette

                  moveq    #11,d0         
work_out_pts:     move.w   (a2)+,(a1)+
                  dbra     d0,work_out_pts
                  movem.l  (sp)+,d0/a0-a2
                  rts

;Ausgaben von vq_extnd() zurueckliefern
;Vorgaben:
;-
;Eingaben:
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

                  clr.w    0-90(a0)          ;work_out[0]: kein Bildschirm
                  clr.w    2-90(a0)          ;work_out[1]: mehr als 32767 Farbabstufungen
                  move.w   #16,8-90(a0)      ;work_out[4]: Anzahl der Farbebenen
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
                  move.w   bitmap_width(a6),(a0)+  ;[5] Bytes pro Zeile
                  move.l   bitmap_addr(a6),(a0)+   ;[6/7] Bildschirmadresse
                  addq.l   #6,a1
                  move.w   (a1)+,(a0)+    ;[8]  Bits der Rot-Intensitaet
                  move.w   (a1)+,(a0)+    ;[9]  Bits der Gruen-Intensitaet
                  move.w   (a1)+,(a0)+    ;[10] Bits der Blau-Intensitaet
                  move.w   (a1)+,(a0)+    ;[11] kein Alpha-Channel
                  move.w   (a1)+,(a0)+    ;[12] kein Genlock
                  move.w   (a1)+,(a0)+    ;[13] keine unbenutzten Bits
                  move.w   (a1)+,(a0)+ ;[14] Bitorganisation
                  move.w   (a1)+,(a0)+    ;[15] unbenutzt

                  moveq    #111,d0
                  lea      scrninfo_mot(pc),a1  ;Daten fuers Motorola-Format
scrninfo_loop:    move.w   (a1)+,(a0)+
                  dbf      d0,scrninfo_loop

                  move.w   #143,d0
scrninfo_clr:     clr.w    (a0)+
                  dbf      d0,scrninfo_clr

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

;Eingaben:
;a0.l Zeiger auf resinfo-Struktur
get_resinfo:      rts

;Tabellen fuer die Umsetzung von VDI-Index in Farbwert bauen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;-
;Ausgaben:
;-
build_color_maps: movem.l  d0/a0-a2,-(sp)
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_colmaptab(a2),a2
                  
                  movea.l  _color_map_ptr(a2),a0
                  lea      color_map(pc),a1
                  moveq    #63,d0
copy_map_loop:    move.l   (a0)+,(a1)+
                  dbra     d0,copy_map_loop

                  movem.l  (sp)+,d0/a0-a2
                  rts

build_exp:        movem.l  d0-d2/a0-a1,-(sp)
                  lea      expand_tab(pc),a0
                  moveq    #0,d0          ;Zaehler
build_exp_bloop:  move.w   d0,d1          ;Bitmuster
                  moveq    #7,d2
build_exp_loop:   clr.w    (a0)+
                  add.b    d1,d1          ;Bit gesetzt?
                  bcs.s    build_exp_next
                  not.w    -2(a0)
build_exp_next:   dbra     d2,build_exp_loop
                  addq.w   #1,d0
                  cmp.w    #256,d0        ;alle 256 Bitmuster durch?
                  blt.s    build_exp_bloop
                  movem.l  (sp)+,d0-d2/a0-a1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Daten fuer vq_scrninfo()'

scrninfo:         DC.W 2                  ;Packed Pixels
                  DC.W 2                  ;Software-CLUT
                  DC.W 16                 ;16 Ebenen
                  DC.L 32768              ;32768 Farben
                  DC.W 0,0,0
                  DC.W 5                  ;5 Bits fuer die Rot-Intensitaet
                  DC.W 5                  ;5 Bits fuer die Gruen-Intensitaet
                  DC.W 5                  ;5 Bits fuer die Blau-Intensitaet
                  DC.W 0                  ;kein Bit fuer Alpha-Channel
                  DC.W 0                  ;kein Bit fuer Genlock
                  DC.W 1                  ;1 unbenutztes Bit
                  DC.W 2                  ;Bitorganisation
                  DC.W  0

scrninfo_mot:     DC.W  11,12,13,14,15    ;Bits der Rot-Intensitaet
                  DCB.W 11,-1
                  DC.W  6,7,8,9,10        ;Bits der Gruen-Intensitaet
                  DCB.W 11,-1
                  DC.W  0,1,2,3,4         ;Bits der Blau-Intensitaet
                  DCB.W 11,-1
                  DCB.W 16,-1             ;kein Alpha-Channel
                  DCB.W 16,-1             ;keine Bits fuer Genlock
                  DC.W  5                 ;Bit 5 ist unbenutzt
                  DCB.W 31,-1             ;unbenutzte Bits
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Farbpalette'

;Die Farbpalette
palette_data:
DC.w $ffff, $f000, $0720, $ffe0, $001e, $e193, $1e57, $dedb
DC.w $8410, $8000, $0400, $b507, $0010, $8010, $0410, $18c3
DC.w $0006, $000c, $0013, $0019, $001f, $0180, $0186, $018c
DC.w $0193, $0199, $019f, $0320, $0326, $032c, $0333, $0339
DC.w $033f, $04c0, $04c6, $04cc, $04d3, $04d9, $04df, $0660
DC.w $0666, $066c, $0673, $0679, $067f, $07e0, $07e6, $07ec
DC.w $07f3, $07f9, $07ff, $3000, $3006, $300c, $3013, $3019
DC.w $301f, $3180, $3186, $318c, $0018, $3199, $319f, $3320
DC.w $3326, $332c, $3333, $3339, $333f, $34c0, $34c6, $34cc
DC.w $34d3, $34d9, $34df, $3660, $3666, $366c, $3673, $3679
DC.w $367f, $37e0, $37e6, $37ec, $37f3, $37f9, $37ff, $6000
DC.w $6006, $600c, $6013, $6019, $601f, $6180, $6186, $618c
DC.w $6193, $6199, $619f, $6320, $6326, $632c, $6333, $6339
DC.w $633f, $64c0, $64c6, $64cc, $64d3, $64d9, $64df, $6660
DC.w $6666, $666c, $6673, $6679, $667f, $67e0, $67e6, $67ec
DC.w $67f3, $67f9, $67ff, $9800, $9806, $980c, $9813, $9819
DC.w $981f, $9980, $9986, $998c, $9993, $9999, $999f, $9b20
DC.w $9b26, $9b2c, $9b33, $9b39, $9b3f, $9cc0, $9cc6, $9ccc
DC.w $9cd3, $9cd9, $9cdf, $9e60, $9e66, $9e6c, $9e73, $9e79
DC.w $9e7f, $9fe0, $9fe6, $9fec, $9ff3, $9ff9, $9fff, $c800
DC.w $c806, $c80c, $c813, $c819, $c81f, $c980, $c986, $c98c
DC.w $c993, $c999, $c99f, $cb20, $cb26, $cb2c, $cb33, $cb39
DC.w $cb3f, $ccc0, $ccc6, $cccc, $ccd3, $ccd9, $ccdf, $ce60
DC.w $ce66, $ce6c, $ce73, $ce79, $ce7f, $cfe0, $cfe6, $cfec
DC.w $cff3, $cff9, $cfff, $f800, $f806, $f80c, $f813, $f819
DC.w $f81f, $f980, $f986, $f98c, $f993, $f999, $f99f, $fb20
DC.w $fb26, $fb2c, $fb33, $fb39, $fb3f, $fcc0, $fcc6, $fccc
DC.w $fcd3, $fcd9, $fcdf, $fe60, $fe66, $fe6c, $fe73, $fe79
DC.w $fe7f, $ffe0, $ffe6, $ffec, $fff3, $fff9, $f000, $e000
DC.w $c000, $b000, $8000, $4800, $1800, $0780, $0720, $0600
DC.w $0580, $0400, $0260, $00c0, $0003, $0009, $0010, $0016
DC.w $3193, $001c, $f79e, $e73c, $c618, $b596, $4a69, $0000

                  
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

                  lea      rgb_in_tab(pc),a0

                  moveq    #2,d5
init_rgbi_bloop:  moveq    #0,d3
init_rgbi_loop:   move.w   d3,d4
                  mulu     d0,d4       ;*hoechste Intensitaet
                  add.l    #500,d4     ;runden
                  divu     #1000,d4
                  move.b   d4,(a0)+    
                  addq.w   #1,d3
                  cmp.w    #1000,d3
                  ble.s    init_rgbi_loop

                  move.w   d1,d0
                  move.w   d2,d1
                  addq.l   #1,a0       ;Element 1002 ueberspringen (Wortgrenze!)
                  dbra     d5,init_rgbi_bloop

                  movem.w  (sp)+,d0-d2

                  lea      rgb_out_tab(pc),a1

                  moveq    #2,d6
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

                  move.w   d1,d0       ;maximale Intensitaet der naechsten Grundfarbe
                  move.w   d2,d1
                  dbra     d6,init_rgbo_bloop
                  movem.l  (sp)+,d0-d6/a0-a1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '1. Kontrollfunktionen'

;WK-Tabelle intialisieren
;Eingaben
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:          movem.l  d0-d1/a0-a2,-(sp)

                  move.w   #15,r_planes(a6)  ;Anzahl der Bildebenen -1
                  move.w   #255,colors(a6) ;hoechste Farbnummer

                  move.l   #fbox,p_fbox(a6)
                  move.l   #fline,p_fline(a6)
                  move.l   #hline,p_hline(a6)
                  move.l   #vline,p_vline(a6)
                  move.l   #line,p_line(a6)

                  move.l   #expblt,p_expblt(a6)
                  move.l   #bitblt,p_bitblt(a6)
                  move.l   #textblt,p_textblt(a6)

                  move.l   #scanline,p_scanline(a6)

                  move.l   #get_pixel,p_get_pixel(a6)
                  move.l   #set_pixel,p_set_pixel(a6)
                  move.l   #transform,p_transform(a6)
                  move.l   #set_pattern,p_set_pattern(a6)

                  move.l   #set_color_rgb,p_set_color_rgb(a6)
                  move.l   #get_color_rgb,p_get_color_rgb(a6)
                  move.l   #vdi_to_color,p_vdi_to_color(a6)
                  move.l   #color_to_vdi,p_color_to_vdi(a6)

                  lea      palette_data(pc),a0
                  lea      c_palette(a6),a1
                  lea      color_map(pc),a2

                  move.w   #255,d1
set_palette:      moveq    #0,d0
                  move.b   (a2)+,d0
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d0
                  and.w    #$ffdf,d0
                  move.w   d0,(a1)+
                  dbra     d1,set_palette
                  movem.l  (sp)+,d0-d1/a0-a2
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
;a6.l Workstation
;Ausgaben:
;-
set_color_rgb:    lea      c_palette(a6),a1
                  add.w    d3,d3
                  adda.w   d3,a1

                  lea      rgb_in_tab(pc),a0
                  move.b   0(a0,d0.w),d0
                  lsl.w    #5,d0
                  lea      1002(a0),a0    ;Gruen-Tabelle
                  or.b     0(a0,d1.w),d0
                  lsl.w    #6,d0
                  lea      1002(a0),a0    ;Blau-Tabelle
                  or.b     0(a0,d2.w),d0
set_col_rgb_save: move.w   d0,(a1)
                  rts

;RGB-Wert fuer einen VDI-Farbindex erfragen
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w VDI-Farbindex
;d1.w 0: erbetene Intensitaet zurueckliefern, sonst realisierte Intensitaet zurueckliefern
;a6.l Workstation
;Ausgaben:
;d0.w Rot-Intensitaet in Promille
;d1.w Gruen-Intensitaet in Promille
;d2.w Blau-Intensitaet in Promille
get_color_rgb:    lea      c_palette(a6),a1
                  add.w    d0,d0
                  move.w   0(a1,d0.w),d2
                  lea      rgb_out_tab(pc),a1
                  rol.w    #6,d2
                  moveq    #%111110,d0
                  and.w    d2,d0
                  move.w   0(a1,d0.w),d0  ;Rot-Intensitaet in Promille
                  lea      64(a1),a1
                  rol.w    #5,d2
                  moveq    #%111110,d1
                  and.w    d2,d1
                  move.w   0(a1,d1.w),d1  ;Gruen-Intensitaet in Promille
                  lea      64(a1),a1
                  rol.w    #6,d2
                  and.w    #%111110,d2
                  move.w   0(a1,d2.w),d2  ;Blau-Intensitaet in Promille
                  rts

;Muster setzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w Wortanzahl
;a0.l Zeiger auf das Fuellmuster
;a1.l Zeiger auf die Zieladresse
;a6.l Workstation
;Ausgaben:
;d0.w Planeanzahl - 1
set_pattern:      cmp.w    #16,d0         ;farbiges Fuellmuster?
                  bne.s    set_pattern_col
                  REPT 8
                  move.l   (a0)+,(a1)+
                  ENDM
                  moveq    #0,d0          ;Fuellmuster mit nur einer Ebene
                  rts

set_pattern_col:  movem.l  d1-d2,-(sp)
                  move.w   #255,d2        ;Pixelzaehler
set_pattern_loop: move.l   (a0)+,d0       ;32-Bit-True-Color-Fuellmuster
                  move.l   d0,d1
                  lsr.l    #3,d1          ;Rot-Intensitaet auf 5 Bits verkleinern
                  move.w   d0,d1
                  lsr.l    #2,d1          ;Gruen-Intensitaet auf 5 Bits verkleinern
                  and.l    #$fffffe00,d1  ;1 unbenutztes Bit
                  move.b   d0,d1
                  lsr.l    #3,d1          ;Blau-Intensitaet auf 5 Bits verkleinern
                  move.w   d1,(a1)+
                  dbra     d2,set_pattern_loop
                                    
                  movem.l  (sp)+,d1-d2
                  moveq    #15,d0         ;Fuellmuster mit 16 Ebenen
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;VDI-Farbindex in realen Farbwert umsetzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w VDI-Farbindex
;a6.l Workstation
;Ausgaben:
;d0.l Farbwert
vdi_to_color:     lea      c_palette(a6),a0
                  add.w    d0,d0
                  adda.w   d0,a0
                  moveq    #0,d0
                  move.w   (a0),d0
                  rts

;Farbwert in VDI-Farbindex umsetzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l Farbwert
;a6.l Workstation
;Ausgaben:
;d0.w VDI-Farbindex
color_to_vdi:     moveq    #-1,d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Raster transformieren
;in diesem Fall ein Atari-konformes vr_trnfm(), d.h. FALSCH
;Vorgaben:
;Register d0-d7/a0-a5 koennen veraendert werden
;Eingaben:
;a0.l Zeiger auf den Quell-MFDB
;a1.l Zeiger auf den Ziel-MFDB
;a6.l Workstation
;Ausgaben:
;-
transform:        move.l   a6,-(sp)
                  moveq    #0,d0          ;Langwort loeschen
                  move.w   fd_nplanes(a0),d0 ;Anzahl der Ebenen
                  move.w   fd_h(a0),d1    ;Anzahl der Zeilen
                  mulu     fd_wdwidth(a0),d1 ;Wortanzahl pro Ebene
                  moveq    #0,d2          ;geraeteabhaengiges Zielformat
                  tst.w    fd_stand(a0)   ;geraeteabhaengiges Quellformat?
                  bne.s    vr_trnfm_frmt
                  moveq    #1,d2          ;standardisiertes Zielformat
vr_trnfm_frmt:    move.w   d2,fd_stand(a1) ;Format des Zielblocks eintragen

                  movea.l  (a0),a0        ;Quellblockadresse
                  movea.l  (a1),a1        ;Zielblockadresse
                  subq.l   #1,d1          ;mindestens ein Wort?
                  bmi.s    vr_trnfm_exit

                  subq.w   #1,d0          ;nur eine Ebene, monochrom?
                  beq      vr_trnfm_mono
                  sub.w    #16-1,d0       ;16 Ebenen?
                  bne.s    vr_trnfm_exit

                  add.w    d2,d2
                  add.w    d2,d2
                  movea.l  vr_tr_tab(pc,d2.w),a2 ;Zeiger auf die Wandlungsroutine

                  cmpa.l   a0,a1          ;Quell- und Zieladresse gleich?
                  bne.s    vr_trnfm_diff

                  move.l   d1,d3
                  addq.l   #1,d3          ;Wortanzahl pro Ebene
                  lsl.l    #5,d3          ;Speicherbedarf des Blocks (Wortanzahl * 2 * 16)
                  cmp.l    buffer_len(a6),d3 ;passt der Block in den Buffer?
                  bgt.s    vr_trnfm_same

                  move.l   d3,-(sp)       ;Laenge des Blocks
                  move.l   a0,-(sp)       ;Quell- und Zieladresse
                  movea.l  buffer_addr(a6),a1
                  move.l   a1,-(sp)       ;Bufferadresse
                  move.l   d1,d0
                  addq.l   #1,d0
                  jsr      (a2)           ;Block im Buffer wandeln
                  movea.l  (sp)+,a0       ;Bufferadresse
                  movea.l  (sp)+,a1       ;Zieladresse
                  move.l   (sp)+,d1
                  lsr.l    #1,d1
                  subq.l   #1,d1          ;Laenge des Blocks in Worten - 1
                  bra      vr_trnfm_copy  ;Buffer umkopieren

vr_trnfm_same:    movea.l  vr_tr_tab2(pc,d2.w),a2
                  bra.s    vr_trnfm_jsr

vr_trnfm_diff:    move.l   d1,d0
                  addq.l   #1,d0          ;Laenge einer Ebene in Worten
vr_trnfm_jsr:     jsr      (a2)           ;Block wandeln

vr_trnfm_exit:    movea.l  (sp)+,a6
                  rts

vr_tr_tab:        DC.L vr_trnfm_dev
                  DC.L vr_trnfm_stand

vr_tr_tab2:       DC.L vr_trnfm_samed
                  DC.L vr_trnfm_sames

;Block mit gleicher Quell- und Zieladresse ins geraetespezifische Format wandeln
;Eingaben
;d1.l Worte pro Ebene - 1
;a0.l Quelladresse
;a1.l Zieladresse (gleich der Quelladresse)
;Ausgaben
;Register d0-d4/a0-a2 werden veraendert
vr_trnfm_samed:   movem.l  d1/a0-a1,-(sp)
                  move.l   d1,d0          ;Anzahl der Worte pro Ebene - 1
                  moveq    #15,d4         ;Anzahl der Ebenen - 1
                  bsr      vr_trnfm_interl ;Block in interleaved Planes wandeln
                  movem.l  (sp)+,d1/a0-a1
vr_trnfm_sdev1:   movea.l  d1,a6
                  move.l   a0,-(sp)
                  move.l   28(a0),-(sp)   ;Ebenen 14/15
                  move.l   24(a0),-(sp)   ;Ebenen 12/13
                  move.l   20(a0),-(sp)   ;Ebenen 10/11
                  move.l   16(a0),-(sp)   ;Ebenen 8/9
                  move.l   a1,-(sp)
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 0-7 liegen im High-Byte
                  movea.l  (sp)+,a1
                  movea.l  sp,a0
                  addq.l   #1,a1          ;Ebenen 8-15 liegen im Low-Byte
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 8-15 ausgeben
                  lea      16(sp),sp
                  movea.l  (sp)+,a0
                  lea      32(a0),a0      ;16 Pixel weiter
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sdev1
                  rts
vr_trnfm_sdev2:   moveq    #15,d0
                  swap     d0
                  move.w   (a0)+,d0       ;Ebene 0
                  move.w   (a0)+,d1       ;Ebene 1
                  move.w   (a0)+,d2       ;Ebene 2
                  move.w   (a0)+,d3       ;Ebene 3
                  move.w   (a0)+,d4       ;Ebene 4
                  move.w   (a0)+,d5       ;Ebene 5
                  move.w   (a0)+,d6       ;Ebene 6
                  move.w   (a0)+,d7       ;Ebene 7
                  swap     d0
                  swap     d7
vr_trnfm_sdev3:   swap     d0
                  add.w    d0,d0
                  addx.b   d7,d7
                  add.w    d1,d1
                  addx.b   d7,d7
                  add.w    d2,d2
                  addx.b   d7,d7
                  add.w    d3,d3
                  addx.b   d7,d7
                  add.w    d4,d4
                  addx.b   d7,d7
                  add.w    d5,d5
                  addx.b   d7,d7
                  add.w    d6,d6
                  addx.b   d7,d7
                  swap     d7
                  add.w    d7,d7
                  swap     d7
                  addx.b   d7,d7
                  move.b   d7,(a1)+       ;Byte im geraetespezifischen Format ausgeben
                  addq.l   #1,a1          ;Byte ueberspringen
                  swap     d0
                  dbra     d0,vr_trnfm_sdev3
                  rts

vr_trnfm_sstd2:   moveq    #15,d0         ;16 Pixel bearbeiten
vr_trnfm_sstd3:   swap     d0
                  swap     d7
                  move.b   (a0)+,d7
                  addq.l   #1,a0          ;Byte ueberspringen
                  add.b    d7,d7
                  addx.w   d0,d0
                  add.b    d7,d7
                  addx.w   d1,d1
                  add.b    d7,d7
                  addx.w   d2,d2
                  add.b    d7,d7
                  addx.w   d3,d3
                  add.b    d7,d7
                  addx.w   d4,d4
                  add.b    d7,d7
                  addx.w   d5,d5
                  add.b    d7,d7
                  addx.w   d6,d6
                  add.b    d7,d7
                  swap     d7
                  addx.w   d7,d7
                  swap     d0
                  dbra     d0,vr_trnfm_sstd3
                  swap     d0
                  move.w   d0,(a1)+       ;Ebene 0
                  move.w   d1,(a1)+       ;Ebene 1
                  move.w   d2,(a1)+       ;Ebene 2
                  move.w   d3,(a1)+       ;Ebene 3
                  move.w   d4,(a1)+       ;Ebene 4
                  move.w   d5,(a1)+       ;Ebene 5
                  move.w   d6,(a1)+       ;Ebene 6
                  move.w   d7,(a1)+       ;Ebene 7
                  rts

;Block mit gleicher Quell- und Zieladresse ins Standardformat wandeln
;Eingaben
;d1.l Worte pro Ebene - 1
;a0.l Quelladresse
;a1.l Zieladresse (gleich der Quelladresse)
;Ausgaben
;Register d0-d4/a0-a2 werden veraendert
vr_trnfm_sames:   movem.l  d1/a0-a1,-(sp)
vr_trnfm_sstd1:   movea.l  d1,a6
                  move.l   a0,-(sp)
                  lea      32(a0),a2
                  REPT 8
                  move.l   -(a2),-(sp)    ;16 Pixel sichern
                  ENDM
                  bsr.s    vr_trnfm_sstd2 ;Ebenen 0-7 liegen im High-Byte
                  movea.l  sp,a0
                  addq.l   #1,a0          ;Ebenen 8-15 liegen im Low-Byte
                  bsr.s    vr_trnfm_sstd2 ;Ebenen 8-15 bearbeiten
                  lea      32(sp),sp
                  movea.l  (sp)+,a0
                  lea      32(a0),a0      ;16 Pixel weiter
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sstd1
                  movem.l  (sp)+,d4/a0-a1
                  moveq    #15,d0         ;interleaved Planes ins Standardformat wandeln

;Block vom Standardformat ins interleaved Bitplane-Format wandeln oder umgekehrt
;Eingaben
;d0.l Anzahl der Ebenen des Standardformats oder Anzahl der Worte pro Ebene - 1
;d4.l Anzahl der Worte pro Ebene oder Anzahl der Ebenen - 1
;a0.l Quelladresse, identisch mit der Zieladresse
;Ausgaben
;Register d0-d4/a0-a2.l werden veraendert
vr_trnfm_interl:  subq.l   #1,d4
                  bmi.s    vr_trnfm_iexit
vr_trnfm_ibloop:  moveq    #0,d2
                  move.l   d4,d1          ;Wortzaehler
vr_trnfm_iloop:   adda.l   d0,a0
                  lea      2(a0,d0.l),a0  ;Adresse des naechsten Worts der Ebene
                  move.w   (a0),d5
                  movea.l  a0,a1
                  movea.l  a0,a2
                  add.l    d0,d2
                  move.l   d2,d3
                  bra.s    vr_trnfm_inext
vr_trnfm_icopy:   movea.l  a1,a2
                  move.w   -(a1),(a2)     ;alles um ein Wort verschieben
vr_trnfm_inext:   subq.l   #1,d3
                  bpl.s    vr_trnfm_icopy
                  move.w   d5,(a1)
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_iloop
                  movea.l  a2,a0
                  subq.l   #1,d0
                  bpl.s    vr_trnfm_ibloop
vr_trnfm_iexit:   rts

;Block ins Standardformat transformieren
;Eingaben
;d0.l Laenge einer Ebene in Worten
;d1.l Pixelanzahl/16 -1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;d0-d7/a0-a6 werden veraendert
vr_trnfm_stand:   add.l    d0,d0          ;Laenge einer Ebene in Bytes
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_stand2 ;Ebenen 0-7 liegen im High-Byte
                  movem.l  (sp)+,d0-d1/a0-a1
                  addq.l   #1,a0          ;Ebenen 8-15 liegen im Low-Byte
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a1          ;Zeiger auf Ebene 8
vr_trnfm_stand2:  lea      0(a1,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

vr_trnfm_sbloop:  movea.l  d1,a6
                  moveq    #15,d0         ;16 Pixel bearbeiten
vr_trnfm_sloop:   swap     d0
                  swap     d7
                  move.b   (a0)+,d7
                  addq.l   #1,a0          ;Byte ueberspringen
                  add.b    d7,d7
                  addx.w   d0,d0
                  add.b    d7,d7
                  addx.w   d1,d1
                  add.b    d7,d7
                  addx.w   d2,d2
                  add.b    d7,d7
                  addx.w   d3,d3
                  add.b    d7,d7
                  addx.w   d4,d4
                  add.b    d7,d7
                  addx.w   d5,d5
                  add.b    d7,d7
                  addx.w   d6,d6
                  add.b    d7,d7
                  swap     d7
                  addx.w   d7,d7
                  swap     d0
                  dbra     d0,vr_trnfm_sloop
                  swap     d0
                  move.w   d0,(a1)+       ;Ebene 0
                  move.w   d1,(a2)+       ;Ebene 1
                  move.w   d2,(a3)+       ;Ebene 2
                  move.w   d3,(a4)+       ;Ebene 3
                  move.w   d4,-2(a1,a5.l) ;Ebene 4
                  move.w   d5,-2(a2,a5.l) ;Ebene 5
                  move.w   d6,-2(a3,a5.l) ;Ebene 6
                  move.w   d7,-2(a4,a5.l) ;Ebene 7
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sbloop
                  rts

;Block ins geraetespezifische Format transformieren
;Eingaben
;d0.l Laenge einer Ebene in Worten
;d1.l Pixelanzahl/16 -1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;d0-d7/a0-a6 werden veraendert
vr_trnfm_dev:     add.l    d0,d0          ;Laenge einer Ebene in Bytes
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_dev2  ;Ebenen 0-7 liegen im im High-Byte
                  movem.l  (sp)+,d0-d1/a0-a1
                  addq.l   #1,a1          ;Ebenen 8-15 liegen im Low-Byte
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a0          ;Zeiger auf Ebene 8

vr_trnfm_dev2:    lea      0(a0,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

vr_trnfm_dbloop:  movea.l  d1,a6
                  moveq    #15,d0
                  swap     d0
                  move.w   (a0)+,d0       ;Ebene 0
                  move.w   (a2)+,d1       ;Ebene 1
                  move.w   (a3)+,d2       ;Ebene 2
                  move.w   (a4)+,d3       ;Ebene 3
                  move.w   -2(a0,a5.l),d4 ;Ebene 4
                  move.w   -2(a2,a5.l),d5 ;Ebene 5
                  move.w   -2(a3,a5.l),d6 ;Ebene 6
                  move.w   -2(a4,a5.l),d7 ;Ebene 7
                  swap     d0
                  swap     d7

vr_trnfm_dloop:   swap     d0
                  add.w    d0,d0
                  addx.b   d7,d7
                  add.w    d1,d1
                  addx.b   d7,d7
                  add.w    d2,d2
                  addx.b   d7,d7
                  add.w    d3,d3
                  addx.b   d7,d7
                  add.w    d4,d4
                  addx.b   d7,d7
                  add.w    d5,d5
                  addx.b   d7,d7
                  add.w    d6,d6
                  addx.b   d7,d7
                  swap     d7
                  add.w    d7,d7
                  swap     d7
                  addx.b   d7,d7
                  move.b   d7,(a1)+       ;Byte im geraetespezifischen Format ausgeben
                  addq.l   #1,a1          ;naechste Byte ueberspringen
                  swap     d0
                  dbra     d0,vr_trnfm_dloop

                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_dbloop
                  rts

;monochromen Block kopieren
;Eingaben
;d1.l Laenge in Worten - 1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;Register d1/a0/a1.l werden veraendert

vr_trnfm_mono:    cmpa.l   a0,a1          ;gleiche Adresse?
                  beq.s    vr_trnfm_cexit
vr_trnfm_copy:    lsr.l    #1,d1          ;ein Wort uebertrag?
                  bcs.s    vr_trnfm_cloop
                  move.w   (a0)+,(a1)+
                  bra.s    vr_trnfm_cnext
vr_trnfm_cloop:   move.l   (a0)+,(a1)+
vr_trnfm_cnext:   subq.l   #1,d1
                  bpl.s    vr_trnfm_cloop

vr_trnfm_cexit:   movea.l  (sp)+,a6
                  rts

;Pixel auslesen
;Vorgaben:
;Register d0-d1/a0 koennen veraendert werden
;Eingaben:
;d0.w x
;d1.w y
;a6.l Workstation
;Ausgaben:
;d0.l Farbwert
get_pixel:        tst.w    bitmap_width(a6)
                  beq.s    get_pixel_screen
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    get_pixel_line
get_pixel_screen: movea.l  v_bas_ad.w,a0
relok0:
                  muls     BYTES_LIN.w,d1
get_pixel_line:   add.l    d1,a0
                  add.w    d0,d0
                  add.w    d0,a0
                  moveq    #0,d0
                  move.w   (a0),d0
                  rts

;Pixel setzen
;Vorgaben:
;Register d0-d1/a0 koennen veraendert werden
;Eingaben:
;d0.w x
;d1.w y
;d2.l Farbwert
;a6.l Workstation
;Ausgaben:
;-
set_pixel:        tst.w    bitmap_width(a6)
                  beq.s    set_pixel_screen
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    set_pixel_line
set_pixel_screen: movea.l  v_bas_ad.w,a0
relok1:
                  muls     BYTES_LIN.w,d1
set_pixel_line:   add.l    d1,a0
                  add.w    d0,d0
                  add.w    d0,a0
                  move.w   d2,(a0)
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Text fuer 9 und 10 Punkte'

;Textausgabe mit Clipping ab Bufferstart
;Eingaben
;d0.w x-Quelle (xs1)
;d1.w y-Quelle (ys1)
;d2.w x-Ziel (xd1)
;d3.w y-Ziel (yd1)
;d4.w Breite -1
;d5.w Hoehe -1
;a0.l Bufferadresse
;a2.w Bytes pro Bufferzeile
;a6.l Workstation
;Ausgaben
;d0-a5 werden zerstoert
textblt:          movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok2:
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    textblt_color
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  movea.w  bitmap_width(a6),a3 ;Bytes pro Zeile
textblt_color:    clr.w    r_bgcol(a6)
                  move.w   t_color(a6),r_fgcol(a6)
                  move.w   wr_mode(a6),r_wmode(a6)
                  move.w   #0,r_splanes(a6)
                  move.w   r_planes(a6),r_dplanes(a6)
                  cmpi.w   #MD_ERASE-MD_REPLACE,r_wmode(a6) ;REVERS TRANSPARENT?
                  bne      expand_blt
                  clr.w    r_fgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_bgcol(a6) ;Textfarbe
                  bra      expand_blt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'horizontale Linie'

;horizontalen Linie mit Fuellmuster ohne Clipping zeichnen
;Vorgaben:
;d0-d2/d4-d7/a1 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y
;d2.w x2
;d7.w Schreibmodus
;a6.l Zeiger auf die Workstation
;Ausgaben:
;-
fline:            tst.w    f_planes(a6)
                  beq.s    fline_mono_pat

                  move.l   a0,-(sp)
                  
                  movea.l  f_pointer(a6),a0
                  moveq    #15,d4
                  and.w    d1,d4
                  lsl.w    #5,d4
                  adda.w   d4,a0          ;Zeiger auf die Musterzeile

relok3:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fline_laddr

                  move.w   bitmap_width(a6),d4  ;Bytes pro Zeile
                  movea.l  bitmap_addr(a6),a1   ;Adresse der Bitmap
                  
fline_laddr:      sub.w    d0,d2          ;dx
                  add.w    d0,d0          ;Abstand vom Zeilenanfang in Bytes
                  mulu     d4,d1          
                  ext.l    d0
                  add.l    d0,d1          ;Zieladresse

                  move.l   a1,-(sp)

                  moveq    #32,d7         ;Abstand identischer Punkte des Musters
                  
                  moveq    #15,d6         ;Punktezaehler fuers Muster
                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fline_color
                  move.w   d2,d6

fline_color:      moveq    #31,d0
                  and.w    d1,d0
                  move.w   0(a0,d0.w),d5

                  move.w   d2,d4
                  lsr.w    #4,d4
                  movea.l  (sp),a1
                  adda.l   d1,a1          ;Offset addieren
fline_color_loop: move.w   d5,(a1)
                  adda.w   d7,a1
                  dbra     d4,fline_color_loop
               
                  addq.l   #2,d1          ;zum naechsten Punkt des Musters
                  subq.w   #1,d2
                  dbra     d6,fline_color
                  addq.l   #4,sp
                  move.l   (sp)+,a0
fline_exit:       rts

fline_mono_pat:   movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6  ;Linienmuster
                  lea      c_palette(a6),a1
                  move.w   f_color(a6),d5
                  add.w    d5,d5
                  move.w   0(a1,d5.w),d5  ;RGB-Farbwert
                  move.w   d5,d4
                  swap     d4
                  move.w   d5,d4

                  tst.w    bitmap_width(a6)  ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  movea.l  bitmap_addr(a6),a1   ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr
                  
;horizontalen Linie ohne Clipping zeichnen
;Vorgaben:
;d0-d2/d4-d7/a1 duerfen zerstoert werden
;Eingaben:
;d0.w x1
;d1.w y
;d2.w x2
;d6.w Linienstil
;d7.w Schreibmodus
;a6.l Zeiger auf die Workstation
;Ausgaben:
;-
hline:            lea      c_palette(a6),a1
                  move.w   l_color(a6),d5
                  add.w    d5,d5
                  move.w   0(a1,d5.w),d5  ;RGB-Farbwert
                  move.w   d5,d4
                  swap     d4
                  move.w   d5,d4

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr
hline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok4:
                  muls     BYTES_LIN.w,d1
hline_laddr:      ext.l    d0
                  add.l    d0,d1
                  add.l    d0,d1
                  adda.l   d1,a1          ;Zieladresse

                  add.w    d7,d7
                  move.w   hline_tab(pc,d7.w),d7
                  jmp      hline_tab(pc,d7.w)

hline_exit:       rts
hline_tab:        DC.W hline_replace-hline_tab
                  DC.W hline_trans-hline_tab
                  DC.W hline_eor-hline_tab
                  DC.W hline_rev_trans-hline_tab

hline_replace:    cmp.w    #$ffff,d6
                  beq      hline_solid
                  
                  move.l   a3,-(sp)
                  move.w   d5,-(sp)

                  sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

                  moveq    #32,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_repl_loop
                  move.w   d2,d0

hline_repl_loop:  add.w    d6,d6          ;Punkt gesetzt?
                  scc      d5
                  ext.w    d5
                  or.w     (sp),d5

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      hline_repl_points(pc,d7.w)

hline_repl_points:REPT 16
                  move.w   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_repl_points

                  addq.l   #2,a1
                  subq.w   #1,d2
                  dbra     d0,hline_repl_loop
                  move.w   (sp)+,d5
                  movea.l  (sp)+,a3
                  rts

hline_rev_trans:  not.w    d6
hline_trans:      cmp.w    #$ffff,d6
                  beq       hline_solid

                  move.l   a3,-(sp)

                  sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

                  moveq    #32,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_tr_loop
                  move.w   d2,d0

hline_tr_loop:    add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    hline_tr_next

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      hline_tr_points(pc,d7.w)

hline_tr_points:  REPT 16
                  move.w   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_tr_points

hline_tr_next:    addq.l   #2,a1

                  subq.w   #1,d2
                  dbra     d0,hline_tr_loop
                  movea.l  (sp)+,a3
                  rts

hline_eor_grow2:  addq.l   #2,a1
                  dbra     d2,hline_eor_grow
                  rts
hline_eor_grow:   lsr.w    #1,d2
                  moveq    #$ffffffff,d4
                  not.w    d4             ;d4 = $ffff0000
                  move.l   a1,d0
                  btst     #1,d0
                  beq.s    hline_grow_loop
                  subq.l   #2,a1
                  not.l    d4             ;d4 = $0000ffff
hline_grow_loop:  eor.l    d4,(a1)+
                  dbra     d2,hline_grow_loop
                  rts

hline_eor:        sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

                  cmp.w    #$aaaa,d6
                  beq.s    hline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    hline_eor_grow2

                  move.l   a3,-(sp)
                  moveq    #$ffffffff,d5

                  moveq    #32,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_eor_loop
                  move.w   d2,d0

hline_eor_loop:   add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    hline_eor_next

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      hline_eor_points(pc,d7.w)

hline_eor_points: REPT 16
                  not.w    (a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_eor_points

hline_eor_next:   addq.l   #2,a1
                  subq.w   #1,d2
                  dbra     d0,hline_eor_loop
                  movea.l  (sp)+,a3
                  rts

hline_solid:      sub.w    d0,d2
hline_solid_loop: move.w   d4,(a1)+
                  dbra     d2,hline_solid_loop
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'vertikale Linie'

;vertikale Linie zeichnen
;Eingaben
;d0.w x
;d1.w y1
;d3.w y2
;d6.w Linienmuster
;d7.w Grafikmodus
;a6.l Zeiger auf die Workstation
;Ausgaben
;d0-d7/a1 werden zerstoert
vline:            sub.w    d1,d3          ;Zaehler

;Startadresse berechnen
                  lea      c_palette(a6),a1
                  move.w   l_color(a6),d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d4  ;RGB-Farbwert

                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok5:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  add.w    d0,d0
                  adda.w   d0,a1          ;Startadresse

                  add.w    d7,d7
                  move.w   vline_tab(pc,d7.w),d7
                  jmp      vline_tab(pc,d7.w)

vline_tab:        DC.W vline_replace-vline_tab
                  DC.W vline_trans-vline_tab
                  DC.W vline_eor-vline_tab
                  DC.W vline_rev_trans-vline_tab


vline_rev_trans:  not.w    d6
vline_trans:      move.w   d5,-(sp)
                  ext.l    d5
                  lsl.l    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_tr_loop
                  move.w   d3,d0

vline_tr_loop:    move.l   a1,d2
                  add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    vline_tr_next

                  move.w   d3,d1
                  lsr.w    #4,d1
                  move.w   d1,d7
                  lsr.w    #4,d1
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  jmp      vline_tr_points(pc,d7.w)

vline_tr_points:  REPT 16
                  move.w   d4,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_tr_points

vline_tr_next:    movea.l  d2,a1
                  adda.w   (sp),a1
                  subq.w   #1,d3
                  dbra     d0,vline_tr_loop
                  addq.l   #2,sp
                  rts

vline_eor_grow2:  adda.w   d5,a1
                  dbra     d3,vline_eor_grow
                  rts
vline_eor_grow:   add.w    d5,d5
                  lsr.w    #1,d3
vloop_eor_grow:   eor.w    d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vloop_eor_grow
                  rts

vline_eor:        moveq    #$ffffffff,d4
                  cmp.w    #$aaaa,d6
                  beq.s    vline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    vline_eor_grow2

                  move.w   d5,-(sp)
                  ext.l    d5
                  lsl.l    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_eor_loop
                  move.w   d3,d0

vline_eor_loop:   move.l   a1,d2
                  add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    vline_eor_next

                  move.w   d3,d1
                  lsr.w    #4,d1
                  move.w   d1,d7
                  lsr.w    #4,d1
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7
                  jmp      vline_eor_points(pc,d7.w)

vline_eor_points: REPT 16
                  eor.w    d4,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_eor_points

vline_eor_next:   movea.l  d2,a1
                  adda.w   (sp),a1
                  subq.w   #1,d3
                  dbra     d0,vline_eor_loop
                  addq.l   #2,sp
                  rts

vline_replace:    cmp.w    #$ffff,d6
                  beq      vline_solid

                  move.w   d5,-(sp)
                  ext.l    d5
                  lsl.l    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_repl_loop
                  move.w   d3,d0

vline_repl_loop:  move.l   a1,-(sp)

                  add.w    d6,d6          ;Punkt gesetzt?
                  scc      d2
                  ext.w    d2
                  or.w     d4,d2

                  move.w   d3,d1
                  lsr.w    #4,d1
                  move.w   d1,d7
                  lsr.w    #4,d1
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7
                  jmp      vline_repl_points(pc,d7.w)

vline_repl_points:REPT 16
                  move.w   d2,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_repl_points

                  movea.l  (sp)+,a1
                  adda.w   (sp),a1
                  subq.w   #1,d3
                  dbra     d0,vline_repl_loop
                  addq.l   #2,sp
                  rts

vline_solid:      move.w   d3,d2
                  not.w    d2
                  and.w    #15,d2
                  add.w    d2,d2
                  add.w    d2,d2
                  lsr.w    #4,d3
                  jmp      vline_sld_loop(pc,d2.w)

vline_sld_loop:   REPT 16
                  move.w   d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  ENDM
                  dbra     d3,vline_sld_loop
vline_solid_exit: rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'schraege Linie'

;schraege Linie zeichnen
;Eingaben
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;d6.w Linienmuster
;d7.w Grafikmodus
;a6.l Zeiger auf die Workstation
;Ausgaben
;d0-d7/a1 werden zerstoert
line:             movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok6:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    line_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
line_laddr:       move.w   d5,d4
                  muls     d1,d4          ;Bytes pro Zeile * y1
                  adda.l   d4,a1          ;Zeilenadresse
                  adda.w   d0,a1
                  adda.w   d0,a1          ;Startadresse

                  moveq    #$0f,d4
                  and.w    d0,d4
                  rol.w    d4,d6          ;Muster rotieren

                  sub.w    d0,d2          ;dx
                  bmi.s    line_exit
                  sub.w    d1,d3          ;dy
                  bpl.s    line_color     ;negativ ?

                  neg.w    d3
                  neg.w    d5             ;vertikale Schrittrichtung aendern

line_color:       move.l   a0,-(sp)
                  lea      c_palette(a6),a0
                  move.w   l_color(a6),d4
                  add.w    d4,d4
                  move.w   0(a0,d4.w),d4
                  movea.l  (sp)+,a0

                  cmp.w    d3,d2          ;Winkel > 44 degree ?
                  blt.s    line_angle45

                  move.w   d2,d0
                  add.w    l_lastpix(a6),d0 ;Punktezaehler
                  bmi.s    line_exit

                  move.w   d3,d1
                  add.w    d1,d1          ;xa = 2dy
                  neg.w    d2
                  move.w   d2,d3          ;e  = -dx
                  add.w    d2,d2          ;ya = -2dx

                  add.w    d7,d7
                  move.w   line_tab0(pc,d7.w),d7 ;Sprungadresse
                  jmp      line_tab0(pc,d7.w) ;Linie zeichnen
line_exit:        rts

line_tab0:        DC.W line_rep-line_tab0
                  DC.W line_trans-line_tab0
                  DC.W line_eor-line_tab0
                  DC.W line_rev_trans-line_tab0

line_angle45:     move.w   d3,d0
                  add.w    l_lastpix(a6),d0 ;Punktezaehler
                  bmi.s    line_exit

                  neg.w    d3             ;e  = -dy
                  move.w   d3,d1
                  add.w    d1,d1          ;xa = -2dy
                  add.w    d2,d2          ;ya = 2dx

                  add.w    d7,d7
                  move.w   line_tab45(pc,d7.w),d7
                  jmp      line_tab45(pc,d7.w) ;Linie zeichnen

line_tab45:       DC.W line_rep45-line_tab45
                  DC.W line_trans45-line_tab45
                  DC.W line_eor45-line_tab45
                  DC.W line_rev_trans45-line_tab45

line_rep:         cmp.w    #$ffff,d6      ;durchgehend schwarz?
                  beq.s    line_solid
                  moveq    #$ffffffff,d7
line_rep_loop:    rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_white ;nicht gesetzt ?
                  move.w   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_rep_loop
                  rts
line_rep_white:   move.w   d7,(a1)+       ;weissen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop
                  rts
line_rep_ystep:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  dbra     d0,line_rep_loop ;Punktezaehler dekrementieren
line_rep_exit:    rts

line_solid:       move.w   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_sl_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_solid
                  rts
line_sl_ystep:    adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  dbra     d0,line_solid  ;Punktezaehler dekrementieren
                  rts

line_rev_trans:   not.w    d6
line_trans:       rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_trans_next ;nicht gesetzt ?
                  move.w   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_tr_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_trans
                  rts
line_trans_next:  addq.l   #2,a1          ;naechster Punkt

                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_tr_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_trans
                  rts
;vertikaler Schritt
line_tr_ystep:    adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  dbra     d0,line_trans  ;Punktezaehler dekrementieren
line_tr_exit:     rts

line_eor:         moveq    #$ffffffff,d4
line_eor_loop:    rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_next  ;nicht gesetzt ?
                  eor.w    d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_eor_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_eor_loop
                  rts
line_eor_next:    addq.l   #2,a1          ;naechster Punkt
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_eor_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_eor_loop
                  rts
line_eor_ystep:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  dbra     d0,line_eor_loop ;Punktezaehler dekrementieren
line_eor_exit:    rts

line_rep45:       cmp.w    #$ffff,d6      ;durchgehend schwarz?
                  beq.s    line_solid45
                  moveq    #$ffffffff,d7
line_rep_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_w45   ;nicht gesetzt ?
                  move.w   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
line_rep_w45:     move.w   d7,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach oben oder unten
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_rep_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #2,a1          ;naechster Punkt
                  dbra     d0,line_rep_loop45
                  rts

line_solid45:     move.w   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_solid_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_solid45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_solid_x45:   add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #2,a1          ;naechster Punkt
                  dbra     d0,line_solid45
                  rts

line_rev_trans45: not.w    d6             ;Linienstil invertieren
line_trans45:     rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_tr_next45 ;nicht gesetzt ?
                  move.w   d4,(a1)        ;schwarzen Punkt setzen
line_tr_next45:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_trans_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_trans45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_trans_x45:   add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #2,a1          ;naechster Punkt
                  dbra     d0,line_trans45
                  rts

line_eor45:       moveq    #$ffffffff,d4
line_eor_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_next45 ;nicht gesetzt ?
                  eor.w    d4,(a1)        ;schwarzen Punkt setzen
line_eor_next45:  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_eor_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_eor_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_eor_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #2,a1          ;naechster Punkt
                  dbra     d0,line_eor_loop45
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Rechteck'

;Gefuelltes Rechteck zeichnen
;Vorgaben:
;Register d0-a6 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Workstation (wr_mode, f_pointer, f_interior, f_color)
;Ausgaben
;-
fbox:             lea      c_palette(a6),a0
                  move.w   f_color(a6),d5
                  add.w    d5,d5
                  move.w   0(a0,d5.w),d5  ;RGB-Farbwert

                  movea.l  v_bas_ad.w,a1  ;Bildadresse
relok7:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_universal
                  
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

fbox_universal:   move.w   wr_mode(a6),d7

                  movea.l  f_pointer(a6),a4 ;Zeiger aufs Fuellmuster
                  
                  movea.l  buffer_addr(a6),a0 ;Bufferadresse
                  sub.w    d1,d3          ;Zeilenzaehler in d3
                  move.w   d4,d6
                  move.w   d6,-(sp)       ;Bytes pro Zeile
                  muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse
                  adda.w   d0,a1
                  adda.w   d0,a1          ;Langwortadresse

                  tst.w    d7             ;REPLACE?
                  bne      fbox_eor

                  move.w   d5,d7
                  swap     d7
                  move.w   d5,d7          ;RGB-Farbwert

                  moveq    #$fffffff0,d5
                  and.w    d2,d5
                  sub.w    d0,d5
                  add.w    d5,d5
                  ext.l    d6
                  lsl.l    #4,d6          ;Bytes pro 16 Zeilen
                  ext.l    d5
                  sub.l    d5,d6
                  movea.l  d6,a3          ;Abstand zu 17. Zeile

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d6

                  tst.w    f_planes(a6)      ;Farbmuster?
                  beq      fbox_repl_mono

                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_cfill2

                  move.l   a4,-(sp)
                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #5,d1
                  adda.w   d1,a4

fbox_repl_cfill1: REPT     8
                  move.l   (a4)+,(a5)+
                  ENDM
                  dbra     d5,fbox_repl_cfill1
                  movea.l  (sp)+,a4

fbox_repl_cfill2: REPT     8
                  move.l   (a4)+,(a5)+
                  ENDM
                  dbra     d6,fbox_repl_cfill2
                  
                  bra      fbox_repl_x2
                  
fbox_repl_mono:   lea      expand_tab(pc),a6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_fill2

                  move.l   a4,-(sp)
                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  adda.w   d1,a4

fbox_repl_fill1:  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,d1
                  or.l     d7,d1          ;ausmaskieren
                  move.l   d1,(a5)+
                  ENDM
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,d1
                  or.l     d7,d1          ;ausmaskieren
                  move.l   d1,(a5)+
                  ENDM
                  dbra     d5,fbox_repl_fill1
                  movea.l  (sp)+,a4

fbox_repl_fill2:  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,d1
                  or.l     d7,d1          ;ausmaskieren
                  move.l   d1,(a5)+
                  ENDM
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,d1
                  or.l     d7,d1          ;ausmaskieren
                  move.l   d1,(a5)+
                  ENDM
                  dbra     d6,fbox_repl_fill2

fbox_repl_x2:     move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bmi      fbox_repl_short

                  and.w    #15,d6
                  add.w    d6,d6
                  movea.w  d6,a4
                  addq.w   #2,a4

                  and.w    #15,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  movea.l  fbox_repl_stab(pc,d0.w),a2
                  movea.l  fbox_repl_etab(pc,d6.w),a6

                  bra      fbox_repl_mask

fbox_repl_stab:   DC.L fbox_repl_ld0
                  DC.L fbox_repl_sd0
                  DC.L fbox_repl_ld1
                  DC.L fbox_repl_sd1
                  DC.L fbox_repl_ld4
                  DC.L fbox_repl_sd4
                  DC.L fbox_repl_ld5
                  DC.L fbox_repl_sd5
                  DC.L fbox_repl_ld6
                  DC.L fbox_repl_sd6
                  DC.L fbox_repl_ld7
                  DC.L fbox_repl_sd7
                  DC.L fbox_repl_la4
                  DC.L fbox_repl_sa4
                  DC.L fbox_repl_la5
                  DC.L fbox_repl_sa5

fbox_repl_etab:   DC.L fbox_repl_ewd0
                  DC.L fbox_repl_ed0
                  DC.L fbox_repl_ewd1
                  DC.L fbox_repl_ed1
                  DC.L fbox_repl_ewd4
                  DC.L fbox_repl_ed4
                  DC.L fbox_repl_ewd5
                  DC.L fbox_repl_ed5
                  DC.L fbox_repl_ewd6
                  DC.L fbox_repl_ed6
                  DC.L fbox_repl_ewd7
                  DC.L fbox_repl_ed7
                  DC.L fbox_repl_ewa4
                  DC.L fbox_repl_ea4
                  DC.L fbox_repl_ewa5
                  DC.L fbox_repl_ea5


fbox_repl_mask:   moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_replace2
                  move.w   d3,d0

fbox_replace2:    swap     d3
                  move.w   d0,d3

fbox_repl_bloop:  swap     d3

                  move.l   d3,-(sp)
                  lsr.w    #4,d3

                  move.l   a0,-(sp)
                  move.w   a4,-(sp)

                  move.l   (a0)+,d0
                  move.l   (a0)+,d1
                  move.l   (a0)+,d4
                  move.l   (a0)+,d5
                  move.l   (a0)+,d6
                  move.l   (a0)+,d7
                  movea.l  (a0)+,a4
                  movea.l  (a0)+,a5

                  movea.w  (sp)+,a0


                  move.l   a1,-(sp)

fbox_repl_line:   move.w   d2,-(sp)
                  jmp      (a2)

fbox_repl_sd0:    move.w   d0,(a1)+
                  bra.s    fbox_repl_ld1
fbox_repl_sd1:    move.w   d1,(a1)+
                  bra.s    fbox_repl_ld4
fbox_repl_sd4:    move.w   d4,(a1)+
                  bra.s    fbox_repl_ld5
fbox_repl_sd5:    move.w   d5,(a1)+
                  bra.s    fbox_repl_ld6
fbox_repl_sd6:    move.w   d6,(a1)+
                  bra.s    fbox_repl_ld7
fbox_repl_sd7:    move.w   d7,(a1)+
                  bra.s    fbox_repl_la4
fbox_repl_sa4:    move.w   a4,(a1)+
                  bra.s    fbox_repl_la5
fbox_repl_sa5:    move.w   a5,(a1)+
                  bra.s    fbox_repl_lnext

fbox_repl_loop:
fbox_repl_ld0:    move.l   d0,(a1)+
fbox_repl_ld1:    move.l   d1,(a1)+
fbox_repl_ld4:    move.l   d4,(a1)+
fbox_repl_ld5:    move.l   d5,(a1)+
fbox_repl_ld6:    move.l   d6,(a1)+
fbox_repl_ld7:    move.l   d7,(a1)+
fbox_repl_la4:    move.l   a4,(a1)+
fbox_repl_la5:    move.l   a5,(a1)+
fbox_repl_lnext:  dbra     d2,fbox_repl_loop

                  adda.w   a0,a1
                  jmp      (a6)

fbox_repl_ewa5:   move.l   a5,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ea4
fbox_repl_ewa4:   move.l   a4,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed7
fbox_repl_ewd7:   move.l   d7,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed6
fbox_repl_ewd6:   move.l   d6,d2
                  swap     d2

                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed5
fbox_repl_ewd5:   move.l   d5,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed4
fbox_repl_ewd4:   move.l   d4,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed1

fbox_repl_ewd1:   move.l   d1,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_ed0
fbox_repl_ewd0:   move.l   d0,d2
                  swap     d2
                  move.w   d2,-(a1)
                  bra.s    fbox_repl_next

fbox_repl_ea5:    move.l   a5,-(a1)
fbox_repl_ea4:    move.l   a4,-(a1)
fbox_repl_ed7:    move.l   d7,-(a1)
fbox_repl_ed6:    move.l   d6,-(a1)
fbox_repl_ed5:    move.l   d5,-(a1)
fbox_repl_ed4:    move.l   d4,-(a1)
fbox_repl_ed1:    move.l   d1,-(a1)
fbox_repl_ed0:    move.l   d0,-(a1)

fbox_repl_next:   move.w   (sp)+,d2

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d3,fbox_repl_line

                  movea.l  (sp)+,a1

                  movea.w  a0,a4
                  movea.l  (sp)+,a0
                  lea      32(a0),a0

                  move.l   (sp)+,d3
                  subq.w   #1,d3
                  swap     d3

                  adda.w   (sp),a1        ;naechste Zeile

                  dbra     d3,fbox_repl_bloop ;naechste Fuellmusterzeile
                  addq.l   #2,sp
                  rts

fbox_repl_short:  movea.w  (sp)+,a3       ;Bytes pro Zeile

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  suba.w   d6,a3
                  suba.w   d6,a3          ;Zeilenbreite angleichen
                  eor.w    d1,d6
                  add.w    d6,d6
                  lea      fbox_repl_shrt2(pc,d6.w),a2

                  and.w    d1,d0
                  add.w    d0,d0
                  adda.w   d0,a0          ;Quelladresse

fbox_repl_shrt0:  movea.l  a0,a4
                  lea      32(a0),a0
                  dbra     d1,fbox_repl_shrt1
                  moveq    #15,d1
                  lea      -512(a0),a0

fbox_repl_shrt1:  jmp      (a2)
fbox_repl_shrt2:  REPT 15
                  move.w   (a4)+,(a1)+
                  ENDM
                  move.w   (a4)+,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_repl_shrt0
                  rts

fbox_eor:         subq.w   #MD_XOR-MD_REPLACE,d7
                  blt      fbox_trans     ;TRANSPARENT?
                  bne      fbox_rev_trans ;REVERS TRANSPARENT?
                  move.w   f_interior(a6),d7
                  beq      fbox_eor_exit  ;leer?
                  subq.w   #F_SOLID,d7    ;voll?
                  beq      fbox_not
                  subq.w   #F_PATTERN-F_SOLID,d7
                  bne.s    fbox_eor_buf
                  cmpi.w   #8,f_style(a6)
                  beq      fbox_not

fbox_eor_buf:     moveq    #$fffffff0,d5
                  and.w    d2,d5
                  sub.w    d0,d5
                  add.w    d5,d5
                  ext.l    d6
                  lsl.w    #4,d6          ;Bytes pro 16 Zeilen
                  ext.l    d5
                  sub.l    d5,d6
                  movea.l  d6,a3          ;Abstand zu 17. Zeile

                  lea      expand_tab(pc),a6

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d6

                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_eor_fill2

                  move.l   a4,-(sp)
                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  adda.w   d1,a4

fbox_eor_fill1:   moveq    #0,d1
                  move.b   (a4)+,d1
                  not.b    d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,(a5)+
                  ENDM
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  not.b    d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,(a5)+
                  ENDM
                  dbra     d5,fbox_eor_fill1

                  movea.l  (sp)+,a4

fbox_eor_fill2:   moveq    #0,d1
                  move.b   (a4)+,d1
                  not.b    d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,(a5)+
                  ENDM
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  not.b    d1
                  lsl.w    #4,d1
                  lea      0(a6,d1.w),a2
                  REPT 4
                  move.l   (a2)+,(a5)+
                  ENDM
                  dbra     d6,fbox_eor_fill2

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bmi      fbox_eor_short

                  and.w    #15,d6
                  add.w    d6,d6
                  movea.w  d6,a4
                  addq.w   #2,a4

                  and.w    #15,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  movea.l  fbox_eor_stab(pc,d0.w),a2
                  movea.l  fbox_eor_etab(pc,d6.w),a6

                  bra      fbox_eor_mask

fbox_eor_stab:    DC.L fbox_eor_ld0
                  DC.L fbox_eor_sd0
                  DC.L fbox_eor_ld1
                  DC.L fbox_eor_sd1
                  DC.L fbox_eor_ld4
                  DC.L fbox_eor_sd4
                  DC.L fbox_eor_ld5
                  DC.L fbox_eor_sd5
                  DC.L fbox_eor_ld6
                  DC.L fbox_eor_sd6
                  DC.L fbox_eor_ld7
                  DC.L fbox_eor_sd7
                  DC.L fbox_eor_la4
                  DC.L fbox_eor_sa4
                  DC.L fbox_eor_la5
                  DC.L fbox_eor_sa5

fbox_eor_etab:    DC.L fbox_eor_ewd0
                  DC.L fbox_eor_ed0
                  DC.L fbox_eor_ewd1
                  DC.L fbox_eor_ed1
                  DC.L fbox_eor_ewd4
                  DC.L fbox_eor_ed4
                  DC.L fbox_eor_ewd5
                  DC.L fbox_eor_ed5
                  DC.L fbox_eor_ewd6
                  DC.L fbox_eor_ed6
                  DC.L fbox_eor_ewd7
                  DC.L fbox_eor_ed7
                  DC.L fbox_eor_ewa4
                  DC.L fbox_eor_ea4
                  DC.L fbox_eor_ewa5
                  DC.L fbox_eor_em


fbox_eor_mask:    moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_eorace2
                  move.w   d3,d0

fbox_eorace2:     swap     d3
                  move.w   d0,d3

fbox_eor_bloop:   swap     d3

                  move.l   d3,-(sp)
                  lsr.w    #4,d3

                  move.l   a0,-(sp)
                  move.w   a4,-(sp)

                  move.l   (a0)+,d0
                  move.l   (a0)+,d1
                  move.l   (a0)+,d4
                  move.l   (a0)+,d5
                  move.l   (a0)+,d6
                  move.l   (a0)+,d7
                  movea.l  (a0)+,a4
                  movea.l  (a0)+,a5

                  movea.w  (sp)+,a0
                  move.l   a1,-(sp)

fbox_eor_line:    move.w   d2,-(sp)

                  exg      a4,d3
                  exg      a5,d2

                  jmp      (a2)

fbox_eor_sd0:     eor.w    d0,(a1)+
                  bra.s    fbox_eor_ld1
fbox_eor_sd1:     eor.w    d1,(a1)+
                  bra.s    fbox_eor_ld4
fbox_eor_sd4:     eor.w    d4,(a1)+
                  bra.s    fbox_eor_ld5
fbox_eor_sd5:     eor.w    d5,(a1)+
                  bra.s    fbox_eor_ld6
fbox_eor_sd6:     eor.w    d6,(a1)+
                  bra.s    fbox_eor_ld7
fbox_eor_sd7:     eor.w    d7,(a1)+
                  bra.s    fbox_eor_la4
fbox_eor_sa4:     eor.w    d3,(a1)+
                  bra.s    fbox_eor_la5
fbox_eor_sa5:     move.w   d2,(a1)+
                  bra.s    fbox_eor_d

fbox_eor_loop:    exg      a5,d2
fbox_eor_ld0:     eor.l    d0,(a1)+
fbox_eor_ld1:     eor.l    d1,(a1)+
fbox_eor_ld4:     eor.l    d4,(a1)+
fbox_eor_ld5:     eor.l    d5,(a1)+
fbox_eor_ld6:     eor.l    d6,(a1)+
fbox_eor_ld7:     eor.l    d7,(a1)+
fbox_eor_la4:     eor.l    d3,(a1)+
fbox_eor_la5:     eor.l    d2,(a1)+
fbox_eor_d:       exg      a5,d2
                  dbra     d2,fbox_eor_loop

                  adda.w   a0,a1
                  jmp      (a6)

fbox_eor_ewa5:    move.l   a5,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ea4
fbox_eor_ewa4:    move.l   d3,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed7
fbox_eor_ewd7:    move.l   d7,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed6
fbox_eor_ewd6:    move.l   d6,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed5
fbox_eor_ewd5:    move.l   d5,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed4
fbox_eor_ewd4:    move.l   d4,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed1
fbox_eor_ewd1:    move.l   d1,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_ed0
fbox_eor_ewd0:    move.l   d0,d2
                  swap     d2
                  eor.w    d2,-(a1)
                  bra.s    fbox_eor_next

fbox_eor_em:      move.l   a5,d2
                  eor.l    d2,-(a1)
fbox_eor_ea4:     eor.l    d3,-(a1)
fbox_eor_ed7:     eor.l    d7,-(a1)
fbox_eor_ed6:     eor.l    d6,-(a1)
fbox_eor_ed5:     eor.l    d5,-(a1)
fbox_eor_ed4:     eor.l    d4,-(a1)
fbox_eor_ed1:     eor.l    d1,-(a1)
fbox_eor_ed0:     eor.l    d0,-(a1)

fbox_eor_next:    exg      a4,d3
                  move.w   (sp)+,d2

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d3,fbox_eor_line

                  movea.l  (sp)+,a1

                  movea.w  a0,a4
                  movea.l  (sp)+,a0
                  lea      32(a0),a0

                  move.l   (sp)+,d3
                  subq.w   #1,d3
                  swap     d3
                  adda.w   (sp),a1        ;naechste Zeile

                  dbra     d3,fbox_eor_bloop ;naechste Fuellmusterzeile
fbox_eor_exit:    addq.l   #2,sp
                  rts

fbox_eor_short:   movea.w  (sp)+,a3       ;Bytes pro Zeile

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  suba.w   d6,a3
                  suba.w   d6,a3          ;Zeilenbreite angleichen
                  eor.w    d1,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  lea      fbox_eor_shrt2(pc,d6.w),a2

                  and.w    d1,d0
                  add.w    d0,d0
                  adda.w   d0,a0          ;Quelladresse

fbox_eor_shrt0:   movea.l  a0,a4
                  lea      32(a0),a0
                  dbra     d1,fbox_eor_shrt1
                  moveq    #15,d1

                  lea      -512(a0),a0

fbox_eor_shrt1:   jmp      (a2)
fbox_eor_shrt2:   REPT 15
                  move.w   (a4)+,d0
                  eor.w    d0,(a1)+
                  ENDM
                  move.w   (a4)+,d0
                  eor.w    d0,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_eor_shrt0
                  rts

fbox_not:         sub.w    d0,d2          ;dx
                  sub.w    d2,d6
                  sub.w    d2,d6
                  subq.w   #2,d6          ;Abstand zur naechsten Zeile

                  btst     #0,d2          ;Ausgleichswort notwendig?
                  bne.s    fbox_not_long

                  lea      fbox_not_word(pc),a0
                  lea      fbox_not_next(pc),a2
                  subq.w   #1,d2          ;nur ein Pixel?
                  bmi.s    fbox_not_bloop

                  moveq    #$0e,d0
                  and.w    d2,d0
                  lsr.w    #4,d2          ;16-Pixel-Zaehler
                  eori.w   #$0e,d0
                  lea      fbox_not_loop(pc,d0.w),a2
                  bra.s    fbox_not_bloop

fbox_not_long:    moveq    #$0e,d0
                  and.w    d2,d0
                  lsr.w    #4,d2          ;16-Pixel-Zaehler
                  eori.w   #$0e,d0
                  lea      fbox_not_loop(pc,d0.w),a0

fbox_not_bloop:   move.w   d2,d0
                  jmp      (a0)
fbox_not_word:    not.w    (a1)+
                  jmp      (a2)
fbox_not_loop:    REPT 8
                  not.l    (a1)+
                  ENDM
                  dbra     d0,fbox_not_loop
fbox_not_next:    adda.w   d6,a1          ;naechste Zeile
                  dbra     d3,fbox_not_bloop
                  addq.l   #2,sp
                  rts

fbox_rev_trans:   sub.w    d0,d2          ;dx

                  ext.l    d6
                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0          ;x1 & 15
                  and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_rtr_fill2

                  move.w   d1,d7          ;y1
                  eor.w    d6,d7
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_rtr_fill1:   move.w   (a2)+,d1
                  not.w    d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d7,fbox_rtr_fill1

fbox_rtr_fill2:   move.w   (a4)+,d1
                  not.w    d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d6,fbox_rtr_fill2

                  bra.s    fbox_tr_color

fbox_trans:       sub.w    d0,d2          ;dx
                     
                  ext.l    d6
                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0
                  and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_trans_fill2

                  move.w   d1,d7          ;y1
                  eor.w    d6,d7
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_trans_fill1: move.w   (a2)+,d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d7,fbox_trans_fill1

fbox_trans_fill2: move.w   (a4)+,d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d6,fbox_trans_fill2

fbox_tr_color:    move.w   d5,d7          ;RGB-Farbwert

                  cmp.w    d4,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_tr_vcount
                  move.w   d3,d4
fbox_tr_vcount:   swap     d3
                  move.w   d4,d3

                  movea.w  #32,a2         ;Abstand identischer Punkte des Musters

                  moveq    #15,d6         ;Punktezaehler fuers Muster

                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fbox_tr_hcount
                  move.w   d2,d6

fbox_tr_hcount:   movea.w  d6,a4          ;Punktezaehler
                  sub.w    d6,d2
                  addq.w   #1,d6
                  add.w    d6,d6
                  suba.w   d6,a3          ;Abstand zur 17. Zeile

fbox_tr_bloop:    swap     d3

                  move.w   d3,d1
                  lsr.w    #4,d1

                  movea.l  a1,a5          ;Zieladresse

fbox_tr_lines:    move.w   a4,d6          ;Punktezaehler
                  move.w   (a0),d0        ;Musterzeile

fbox_tr_line:     add.w    d0,d0          ;Punkt gesetzt?
                  bcc.s    fbox_tr_next

                  move.w   d2,d4
                  add.w    d6,d4
                  lsr.w    #4,d4
                  move.w   d4,d5
                  lsr.w    #4,d4
                  not.w    d5
                  andi.w   #15,d5
                  add.w    d5,d5
                  add.w    d5,d5

                  movea.l  a5,a6

                  jmp      fbox_tr_points(pc,d5.w)

fbox_tr_points:   REPT 16
                  move.w   d7,(a6)
                  adda.w   a2,a6
                  ENDM
                  dbra     d4,fbox_tr_points

fbox_tr_next:     addq.l   #2,a5
                  dbra     d6,fbox_tr_line

                  adda.l   a3,a5          ;16 Zeilen weiter
                  dbra     d1,fbox_tr_lines

                  addq.l   #2,a0          ;naechste Musterzeile
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_tr_bloop ;naechste Fuellmusterzeile
                  addq.l   #2,sp
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Expand-Blt'

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
expblt:           movea.l  r_saddr(a6),a0
                  movea.l  r_daddr(a6),a1
                  movea.w  r_swidth(a6),a2
                  movea.w  r_dwidth(a6),a3
                  and.w    #3,r_wmode(a6)

;Expand-Blt, Raster mit einer Ebene auf 8 Ebenen unter Vorgabe von
;Vorder- und Hintergrundfarbe expandieren
;Vorgaben:
;Register d0-d7/a0-a5.l werden veraendert
;Eingaben:
;d0.w xq
;d1.w yq
;d2.w xz
;d3.w yz
;d4.w dx
;d5.w dy
;a0.l Quellblockadresse
;a1.l Zielblockadresse
;a2.w Breite einer Quellzeile in Bytes
;a3.w Breite einer Zielzeile in Bytes
;a6.l r_wmode, r_fgcol, r_bgcol, r_dplanes
expand_blt:       move.w   a2,d6          ;Bytes pro Quellzeile
                  move.w   a3,d7          ;Bytes pro Quellzeile

                  muls     d6,d1
                  adda.l   d1,a0
                  move.w   d0,d1
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a0          ;Quelladresse

                  muls     d7,d3
                  adda.l   d3,a1          ;Zielzeilenadresse
                  add.w    d2,d2
                  adda.w   d2,a1          ;Zieladresse

                  moveq    #15,d1
                  and.w    d1,d0          ;Shifts nach links fuer das erste Wort
                  eor.w    d0,d1          ;Schleifenzaehler fuer das erste Wort
                  
                  cmp.w    d1,d4          ;Schleifenzaehler groesser als die Breite?
                  bge.s    expand_blt_wcnt
                  move.w   d4,d1          ;Schleifenzaehler begrenzen
expand_blt_wcnt:  swap     d0
                  move.w   d1,d0          ;Schleifenzaehler
                  swap     d0

                  move.w   d0,d2          ;xq1 / 16
                  add.w    d4,d2          ;xq2
                  lsr.w    #4,d2          ;/ 16
                  add.w    d2,d2
                  addq.w   #2,d2
                  suba.w   d2,a2          ;Abstand zur naechsten Quellzeile

                  move.w   d4,d2
                  add.w    d2,d2
                  addq.w   #2,d2
                  suba.w   d2,a3          ;Abstand zur naechsten Zielzeile

                  lea      c_palette(a6),a4 ;Zeiger auf die virtuelle Palette
                  movea.l  a4,a5
                  move.w   r_fgcol(a6),d6 ;Vordergrundfarbe
                  add.w    d6,d6
                  adda.w   d6,a4
                  move.l   (a4),d6  
                  move.w   (a4),d6  

                  move.w   r_bgcol(a6),d7 ;Hintergrundfarbe
                  add.w    d7,d7
                  adda.w   d7,a5
                  move.l   (a5),d7
                  move.w   (a5),d7

                  move.w   r_wmode(a6),d2
                  add.w    d2,d2
                  move.w   eblt_tab(pc,d2.w),d2
                  jmp      eblt_tab(pc,d2.w)
                  
eblt_tab:         DC.W     eblt_repl-eblt_tab
                  DC.W     eblt_trans-eblt_tab
                  DC.W     eblt_eor-eblt_tab
                  DC.W     eblt_rev_trans-eblt_tab

eblt_repl:        move.l   d6,d2
                  move.w   d7,d2
                  movea.l  d2,a4
                  move.l   d7,d3
                  move.w   d6,d3
                  movea.l  d3,a5
                  
eblt_repl_bloop:  move.w   d4,d3          ;dx

                  move.w   (a0)+,d2
                  rol.w    d0,d2          ;ueberzaehlige Pixel wegrotieren

                  move.l   d0,d1
                  swap     d1
                  bra.s    eblt_repl_dec
                  
eblt_repl_read:   move.w   (a0)+,d2
eblt_repl_dec:    sub.w    d1,d3
                  subq.w   #1,d3
                  addq.w   #2,d1
                  bra.s    eblt_repl_sub
                        
eblt_repl_loop:   add.w    d2,d2
                  bcc.s    eblt_repl_white
                  add.w    d2,d2
                  bcc.s    eblt_repl_bw
                  move.l   d6,(a1)+
eblt_repl_sub:    subq.w   #2,d1
                  bgt.s    eblt_repl_loop
                  beq.s    eblt_repl_last
                  bra.s    eblt_repl_next
                  
eblt_repl_bw:     move.l   a4,(a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_repl_loop
                  beq.s    eblt_repl_last
                  bra.s    eblt_repl_next

eblt_repl_white:  add.w    d2,d2
                  bcs.s    eblt_repl_wb

                  move.l   d7,(a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_repl_loop
                  beq.s    eblt_repl_last
                  bra.s    eblt_repl_next
                  
eblt_repl_wb:     move.l   a5,(a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_repl_loop
                  beq.s    eblt_repl_last
                  bra.s    eblt_repl_next

eblt_repl_last:   add.w    d2,d2
                  bcc.s    eblt_repl_lw
                  
                  move.w   d6,(a1)+                
                  bra.s    eblt_repl_next
                  
eblt_repl_lw:     move.w   d7,(a1)+

eblt_repl_next:   moveq    #15,d1
                  cmp.w    d1,d3
                  bge.s    eblt_repl_read
                  move.w   d3,d1
                  bpl.s    eblt_repl_read
                  
eblt_repl_nline:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_repl_bloop
                  rts

eblt_trans:
eblt_trans_bloop: move.w   d4,d3          ;dx

                  move.w   (a0)+,d2
                  rol.w    d0,d2          ;ueberzaehlige Pixel wegrotieren

                  move.l   d0,d1
                  swap     d1
                  bra.s    eblt_trans_dec
                  
eblt_trans_read:  move.w   (a0)+,d2
eblt_trans_dec:   sub.w    d1,d3
                  subq.w   #1,d3
                  addq.w   #2,d1
                  bra.s    eblt_trans_sub
                        
eblt_trans_loop:  add.w    d2,d2
                  bcs.s    eblt_trans_black
                  add.w    d2,d2
                  bcs.s    eblt_trans_wb
                  addq.l   #4,a1
                  subq.w   #2,d1
                  bgt.s    eblt_trans_loop
                  beq.s    eblt_trans_last
                  bra.s    eblt_trans_next
                  
eblt_trans_wb:    addq.l   #2,a1
                  move.w   d6,(a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_trans_loop
                  beq.s    eblt_trans_last
                  bra.s    eblt_trans_next

eblt_trans_black: add.w    d2,d2
                  bcc.s    eblt_trans_bw
                  
                  move.l   d6,(a1)+
eblt_trans_sub:   subq.w   #2,d1
                  bgt.s    eblt_trans_loop
                  beq.s    eblt_trans_last
                  bra.s    eblt_trans_next
                  
eblt_trans_bw:    move.w   d6,(a1)+
                  addq.l   #2,a1
                  subq.w   #2,d1
                  bgt.s    eblt_trans_loop
                  beq.s    eblt_trans_last
                  bra.s    eblt_trans_next

eblt_trans_last:  add.w    d2,d2
                  bcc.s    eblt_trans_lw
                  
                  move.w   d6,(a1)                 
                  
eblt_trans_lw:    addq.l   #2,a1

eblt_trans_next:  moveq    #15,d1
                  cmp.w    d1,d3
                  bge.s    eblt_trans_read
                  move.w   d3,d1
                  bpl.s    eblt_trans_read
                  
eblt_trans_nline: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_trans_bloop
                  rts

eblt_eor:         move.w   d4,d3          ;dx

                  move.w   (a0)+,d2
                  rol.w    d0,d2          ;ueberzaehlige Pixel wegrotieren

                  move.l   d0,d1
                  swap     d1
                  bra.s    eblt_eor_dec
                  
eblt_eor_read:    move.w   (a0)+,d2
eblt_eor_dec:     sub.w    d1,d3
                  subq.w   #1,d3
                  addq.w   #2,d1
                  bra.s    eblt_eor_sub
                        
eblt_eor_loop:    add.w    d2,d2
                  bcs.s    eblt_eor_black
                  add.w    d2,d2
                  bcs.s    eblt_eor_wb
                  addq.l   #4,a1
                  subq.w   #2,d1
                  bgt.s    eblt_eor_loop
                  beq.s    eblt_eor_last
                  bra.s    eblt_eor_next
                  
eblt_eor_wb:      addq.l   #2,a1
                  not.w    (a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_eor_loop
                  beq.s    eblt_eor_last
                  bra.s    eblt_eor_next

eblt_eor_black:   add.w    d2,d2
                  bcc.s    eblt_eor_bw
                  
                  not.l    (a1)+
eblt_eor_sub:     subq.w   #2,d1
                  bgt.s    eblt_eor_loop
                  beq.s    eblt_eor_last
                  bra.s    eblt_eor_next
                  
eblt_eor_bw:      not.w    (a1)+
                  addq.l   #2,a1
                  subq.w   #2,d1
                  bgt.s    eblt_eor_loop
                  beq.s    eblt_eor_last
                  bra.s    eblt_eor_next

eblt_eor_last:    add.w    d2,d2
                  bcc.s    eblt_eor_lw
                  
                  not.w    (a1)
                  
eblt_eor_lw:      addq.l   #2,a1

eblt_eor_next:    moveq    #15,d1
                  cmp.w    d1,d3
                  bge.s    eblt_eor_read
                  move.w   d3,d1
                  bpl.s    eblt_eor_read
                  
eblt_eor_nline:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_eor
                  rts

eblt_rev_trans:
eblt_rtr_bloop:   move.w   d4,d3          ;dx

                  move.w   (a0)+,d2
                  rol.w    d0,d2          ;ueberzaehlige Pixel wegrotieren

                  move.l   d0,d1
                  swap     d1
                  bra.s    eblt_rtr_dec
                  
eblt_rtr_read:    move.w   (a0)+,d2
eblt_rtr_dec:     sub.w    d1,d3
                  subq.w   #1,d3
                  addq.w   #2,d1
                  bra.s    eblt_rtr_sub
                        
eblt_rtr_loop:    add.w    d2,d2
                  bcs.s    eblt_rtr_black
                  add.w    d2,d2
                  bcs.s    eblt_rtr_wb
                  move.l   d7,(a1)+
eblt_rtr_sub:     subq.w   #2,d1
                  bgt.s    eblt_rtr_loop
                  beq.s    eblt_rtr_last
                  bra.s    eblt_rtr_next
                  
eblt_rtr_wb:      move.w   d7,(a1)+
                  addq.l   #2,a1
                  subq.w   #2,d1
                  bgt.s    eblt_rtr_loop
                  beq.s    eblt_rtr_last
                  bra.s    eblt_rtr_next

eblt_rtr_black:   add.w    d2,d2
                  bcc.s    eblt_rtr_bw
                  addq.l   #4,a1
                  subq.w   #2,d1
                  bgt.s    eblt_rtr_loop
                  beq.s    eblt_rtr_last
                  bra.s    eblt_rtr_next
                  
eblt_rtr_bw:      addq.l   #2,a1
                  move.w   d7,(a1)+
                  subq.w   #2,d1
                  bgt.s    eblt_rtr_loop
                  beq.s    eblt_rtr_last
                  bra.s    eblt_rtr_next

eblt_rtr_last:    add.w    d2,d2
                  bcs.s    eblt_rtr_lw
                  
                  move.w   d7,(a1)                 
                  
eblt_rtr_lw:      addq.l   #2,a1

eblt_rtr_next:    moveq    #15,d1
                  cmp.w    d1,d3
                  bge.s    eblt_rtr_read
                  move.w   d3,d1
                  bpl.s    eblt_rtr_read
                  
eblt_rtr_nline:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_rtr_bloop
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Bitblocktransfer'

bitblt_exit:      rts

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
bitblt:           cmp.w    d4,d6                            ;horizontal skalieren?
;                 bne      bitblt_scale
                  cmp.w    d5,d7                            ;vertikal skalieren?
;                 bne      bitblt_scale

                  bclr     #4,r_wmode+1(a6)                 ;vrt_cpyfm mit Schreibmodus 0-3?
                  bne      expblt
                  
                  moveq    #15,d7
                  and.w    r_wmode(a6),d7

                  movea.l  r_saddr(a6),a0
                  movea.l  r_daddr(a6),a1
                  movea.w  r_swidth(a6),a2
                  movea.w  r_dwidth(a6),a3

                  move.w   r_splanes(a6),d6
                  cmp.w    r_dplanes(a6),d6
                  bne      bitblt_exit
                  subi.w   #15,d6
                  bne.s    bitblt_exit

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
bitblt_in:        ext.l    d0
                  ext.l    d2

                  move.w   a2,d6
                  mulu     d6,d1

                  add.l    d0,d1
                  add.l    d0,d1
                  adda.l   d1,a0          ;Quelladresse

                  move.w   a3,d6
                  mulu     d6,d3
                  add.l    d2,d3
                  add.l    d2,d3
                  adda.l   d3,a1          ;Zieladresse

                  cmpa.l   a1,a0          ;Quelladresse > Zieladresse?
                  bhi      bitblt_inc

                  move.w   #%1000010000000001,d6
                  btst     d7,d6          ;Modus 15, 10 oder 0?
                  bne      bitblt_inc

                  move.w   a2,d6
                  mulu     d5,d6
                  movea.l  a0,a4
                  adda.l   d6,a4
                  adda.w   d4,a4
                  adda.w   d4,a4          ;Quellendadresse
                  cmpa.l   a1,a4          ;Quellendadresse < Zieladresse?
                  bcs      bitblt_inc

                  addq.l   #2,a4          ;Quellendadresse + 12
                  add.l    a4,d1
                  sub.l    a0,d1

                  movea.l  a1,a5
                  move.w   a3,d6
                  mulu     d5,d6
                  adda.l   d6,a5
                  adda.w   d4,a5
                  adda.w   d4,a5
                  addq.l   #2,a5          ;Zielendadresse + 2
                  add.l    a5,d3
                  sub.l    a1,d3

                  exg      a0,a4
                  exg      a1,a5

bitblt_dec:       move.w   d4,d6
                  addq.w   #1,d6
                  add.w    d6,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

blt_dec_long:     moveq    #2,d0          ;kein zusaetzliches Wort
                  btst     #0,d4          ;Wortueberhang?
                  bne.s    blt_dec_lcount
                  moveq    #0,d0          ;zusaetzliches Wort
                  subq.w   #1,d4
blt_dec_lcount:   moveq    #6,d1
                  and.w    d4,d1          ;Wortzahl
                  eori.w   #6,d1

                  asr.w    #3,d4          ;8-Wortzaehler

                  tst.w    d4
                  bpl.s    blt_dec_mode
                  moveq    #0,d4
                  moveq    #8,d1          ;alles ueberspringen

blt_dec_mode:     add.w    d7,d7
                  add.w    d7,d7
                  lea      bltld_tab(pc,d7.w),a4
                  move.w   (a4)+,d7
                  beq.s    bltld_jmp
                  subq.w   #m4,d7
                  beq.s    bltld_m4

                  move.w   d0,d7
                  add.w    d0,d0
                  add.w    d7,d0
                  move.w   d1,d7
                  add.w    d1,d1
                  add.w    d7,d1
                  bra.s    bltld_jmp

bltld_m4:         add.w    d0,d0
                  add.w    d1,d1

bltld_jmp:        move.w   (a4)+,d7
                  jmp      bltld_tab(pc,d7.w)

bltld_tab:        DC.W m2,blt0li-bltld_tab
                  DC.W m4,blt1ld-bltld_tab
                  DC.W m6,blt2ld-bltld_tab
                  DC.W m2,blt3ld-bltld_tab
                  DC.W m6,blt4ld-bltld_tab
                  DC.W m2,blt5-bltld_tab
                  DC.W m4,blt6ld-bltld_tab
                  DC.W m4,blt7ld-bltld_tab
                  DC.W m6,blt8ld-bltld_tab
                  DC.W m6,blt9ld-bltld_tab
                  DC.W m2,blt10li-bltld_tab
                  DC.W m6,blt11ld-bltld_tab
                  DC.W m6,blt12ld-bltld_tab
                  DC.W m6,blt13ld-bltld_tab
                  DC.W m6,blt14ld-bltld_tab
                  DC.W m2,blt15li-bltld_tab


blt1ld:           lea      blt1ld_jmp1(pc,d2.w),a4
                  lea      blt1ld_loop(pc,d1.w),a5
blt1ld_bloop:     jmp      (a4)
blt1ld_jmp1:      move.w   -(a0),d0
                  and.w    d0,-(a1)

                  move.w   d4,d6
                  jmp      (a5)
blt1ld_loop:      REPT 4
                  move.l   -(a0),d0
                  and.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt1ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1ld_bloop
                  rts

blt2ld:           lea      blt2ld_jmp1(pc,d0.w),a4
                  lea      blt2ld_loop(pc,d1.w),a5
blt2ld_bloop:     jmp      (a4)
blt2ld_jmp1:      move.w   -(a0),d0
                  not.w    (a1)
                  and.w    d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt2ld_loop:      REPT 4
                  move.l   -(a0),d0
                  not.l    (a1)
                  and.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt2ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2ld_bloop
                  rts

blt3ld:           lea      blt3ld_jmp1(pc,d0.w),a4
                  lea      blt3ld_loop(pc,d1.w),a5
blt3ld_bloop:     jmp      (a4)
blt3ld_jmp1:      move.w   -(a0),-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt3ld_loop:      REPT 4
                  move.l   -(a0),-(a1)
                  ENDM
                  dbra     d6,blt3ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3ld_bloop
                  rts

blt4ld:           lea      blt4ld_jmp1(pc,d0.w),a4
                  lea      blt4ld_loop(pc,d1.w),a5
blt4ld_bloop:     jmp      (a4)
blt4ld_jmp1:      move.w   -(a0),d0
                  not.w    d0
                  and.w    d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt4ld_loop:      REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  and.l    d0,-(a1)
                  ENDM

                  dbra     d6,blt4ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4ld_bloop
blt5:             rts

blt6ld:           lea      blt6ld_jmp1(pc,d0.w),a4
                  lea      blt6ld_loop(pc,d1.w),a5
blt6ld_bloop:     jmp      (a4)
blt6ld_jmp1:      move.w   -(a0),d0

                  eor.w    d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt6ld_loop:      REPT 4
                  move.l   -(a0),d0
                  eor.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt6ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6ld_bloop
                  rts

blt7ld:           lea      blt7ld_jmp1(pc,d0.w),a4
                  lea      blt7ld_loop(pc,d1.w),a5
blt7ld_bloop:     jmp      (a4)
blt7ld_jmp1:      move.w   -(a0),d0
                  or.w     d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt7ld_loop:      REPT 4
                  move.l   -(a0),d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt7ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7ld_bloop
                  rts

blt8ld:           lea      blt8ld_jmp1(pc,d0.w),a4
                  lea      blt8ld_loop(pc,d1.w),a5
blt8ld_bloop:     jmp      (a4)
blt8ld_jmp1:      move.w   -(a0),d0
                  or.w     d0,(a1)
                  not.w    -(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt8ld_loop:      REPT 4
                  move.l   -(a0),d0
                  or.l     d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt8ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8ld_bloop
                  rts

blt9ld:           lea      blt9ld_jmp1(pc,d0.w),a4
                  lea      blt9ld_loop(pc,d1.w),a5
blt9ld_bloop:     jmp      (a4)
blt9ld_jmp1:      move.w   -(a0),d0
                  eor.w    d0,(a1)
                  not.w    -(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt9ld_loop:      REPT 4
                  move.l   -(a0),d0
                  eor.l    d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt9ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9ld_bloop
                  rts

blt11ld:          lea      blt11ld_jmp1(pc,d0.w),a4
                  lea      blt11ld_loop(pc,d1.w),a5
blt11ld_bloop:    jmp      (a4)
blt11ld_jmp1:     not.w    (a1)
                  move.w   -(a0),d0
                  or.w     d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt11ld_loop:     REPT 4
                  not.l    (a1)
                  move.l   -(a0),d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt11ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11ld_bloop
                  rts

blt12ld:          lea      blt12ld_jmp1(pc,d0.w),a4
                  lea      blt12ld_loop(pc,d1.w),a5
blt12ld_bloop:    jmp      (a4)
blt12ld_jmp1:     move.w   -(a0),d0
                  not.w    d0
                  move.w   d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt12ld_loop:     REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  move.l   d0,-(a1)
                  ENDM
                  dbra     d6,blt12ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt12ld_bloop
                  rts

blt13ld:          lea      blt13ld_jmp1(pc,d0.w),a4
                  lea      blt13ld_loop(pc,d1.w),a5
blt13ld_bloop:    jmp      (a4)
blt13ld_jmp1:     move.w   -(a0),d0
                  not.w    d0
                  or.w     d0,-(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt13ld_loop:     REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt13ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13ld_bloop
                  rts

blt14ld:          lea      blt14ld_jmp1(pc,d0.w),a4
                  lea      blt14ld_loop(pc,d1.w),a5
blt14ld_bloop:    jmp      (a4)
blt14ld_jmp1:     move.w   -(a0),d0
                  and.w    d0,(a1)
                  not.w    -(a1)
                  move.w   d4,d6
                  jmp      (a5)
blt14ld_loop:     REPT 4
                  move.l   -(a0),d0
                  and.l    d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt14ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14ld_bloop
                  rts

bitblt_inc:       move.w   d4,d6
                  addq.w   #1,d6
                  add.w    d6,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

blt_inc_long:     moveq    #2,d0          ;kein zusaetzliches Wort
                  btst     #0,d4          ;Wortueberhang?
                  bne.s    blt_inc_lcount
                  moveq    #0,d0          ;zusaetzliches Wort
                  subq.w   #1,d4
blt_inc_lcount:   moveq    #6,d1
                  and.w    d4,d1          ;Wortzahl
                  eori.w   #6,d1
                  asr.w    #3,d4          ;8-Wortzaehler

                  tst.w    d4
                  bpl.s    blt_inc_mode
                  moveq    #0,d4
                  moveq    #8,d1          ;alles ueberspringen

blt_inc_mode:     add.w    d7,d7
                  add.w    d7,d7
                  lea      bltli_tab(pc,d7.w),a4
                  move.w   (a4)+,d7       ;m2?
                  beq.s    bltli_jmp
                  subq.w   #m4,d7         ;m4?
                  beq.s    bltli_m4

                  move.w   d0,d7          ;m6
                  add.w    d0,d0
                  add.w    d7,d0
                  move.w   d1,d7
                  add.w    d1,d1
                  add.w    d7,d1
                  bra.s    bltli_jmp

bltli_m4:         add.w    d0,d0
                  add.w    d1,d1

bltli_jmp:        move.w   (a4)+,d7
                  jmp      bltli_tab(pc,d7.w)

bltli_tab:        DC.W m2,blt0li-bltli_tab
                  DC.W m4,blt1li-bltli_tab
                  DC.W m6,blt2li-bltli_tab
                  DC.W m2,blt3li-bltli_tab
                  DC.W m6,blt4li-bltli_tab
                  DC.W m2,blt5-bltli_tab
                  DC.W m4,blt6li-bltli_tab
                  DC.W m4,blt7li-bltli_tab
                  DC.W m6,blt8li-bltli_tab
                  DC.W m6,blt9li-bltli_tab
                  DC.W m2,blt10li-bltli_tab
                  DC.W m6,blt11li-bltli_tab
                  DC.W m6,blt12li-bltli_tab
                  DC.W m6,blt13li-bltli_tab
                  DC.W m6,blt14li-bltli_tab
                  DC.W m2,blt15li-bltli_tab

blt15li:          moveq    #$ffffffff,d7
                  bra.s    blt0li_jmp
blt0li:           moveq    #$00000000,d7
blt0li_jmp:       lea      blt0li_jmp1(pc,d0.w),a4
                  lea      blt0li_loop(pc,d1.w),a5
blt0li_bloop:     jmp      (a4)
blt0li_jmp1:      move.w   d7,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt0li_loop:      REPT 4
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d6,blt0li_loop
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt0li_bloop
                  rts

blt1li:           lea      blt1li_jmp1(pc,d0.w),a4
                  lea      blt1li_loop(pc,d1.w),a5
blt1li_bloop:     jmp      (a4)
blt1li_jmp1:      move.w   (a0)+,d0
                  and.w    d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt1li_loop:      REPT 4
                  move.l   (a0)+,d0
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt1li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1li_bloop
                  rts

blt2li:           lea      blt2li_jmp1(pc,d0.w),a4
                  lea      blt2li_loop(pc,d1.w),a5
blt2li_bloop:     jmp      (a4)
blt2li_jmp1:      move.w   (a0)+,d0
                  not.w    (a1)
                  and.w    d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt2li_loop:      REPT 4
                  move.l   (a0)+,d0
                  not.l    (a1)
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt2li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2li_bloop
                  rts

blt3li:           lea      blt3li_jmp1(pc,d0.w),a4
                  lea      blt3li_loop(pc,d1.w),a5
blt3li_bloop:     jmp      (a4)
blt3li_jmp1:      move.w   (a0)+,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt3li_loop:      REPT 4
                  move.l   (a0)+,(a1)+
                  ENDM
                  dbra     d6,blt3li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3li_bloop
                  rts

blt4li:           lea      blt4li_jmp1(pc,d0.w),a4
                  lea      blt4li_loop(pc,d1.w),a5
blt4li_bloop:     jmp      (a4)
blt4li_jmp1:      move.w   (a0)+,d0
                  not.w    d0
                  and.w    d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt4li_loop:      REPT 4
                  move.l   (a0)+,d0
                  not.l    d0
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt4li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4li_bloop
                  rts

blt6li:           lea      blt6li_jmp1(pc,d0.w),a4
                  lea      blt6li_loop(pc,d1.w),a5
blt6li_bloop:     jmp      (a4)
blt6li_jmp1:      move.w   (a0)+,d0
                  eor.w    d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt6li_loop:      REPT 4
                  move.l   (a0)+,d0
                  eor.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt6li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6li_bloop
                  rts

blt7li:           lea      blt7li_jmp1(pc,d0.w),a4
                  lea      blt7li_loop(pc,d1.w),a5
blt7li_bloop:     jmp      (a4)
blt7li_jmp1:      move.w   (a0)+,d0
                  or.w     d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt7li_loop:      REPT 4
                  move.l   (a0)+,d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt7li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7li_bloop
                  rts

blt8li:           lea      blt8li_jmp1(pc,d0.w),a4
                  lea      blt8li_loop(pc,d1.w),a5
blt8li_bloop:     jmp      (a4)
blt8li_jmp1:      move.w   (a0)+,d0
                  or.w     d0,(a1)
                  not.w    (a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt8li_loop:      REPT 4
                  move.l   (a0)+,d0
                  or.l     d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt8li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8li_bloop
                  rts


blt9li:           lea      blt9li_jmp1(pc,d0.w),a4
                  lea      blt9li_loop(pc,d1.w),a5
blt9li_bloop:     jmp      (a4)
blt9li_jmp1:      move.w   (a0)+,d0
                  eor.w    d0,(a1)
                  not.w    (a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt9li_loop:      REPT 4
                  move.l   (a0)+,d0
                  eor.l    d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt9li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9li_bloop
                  rts

blt10li:          lea      blt10li_jmp1(pc,d0.w),a4
                  lea      blt10li_loop(pc,d1.w),a5
blt10li_bloop:    jmp      (a4)
blt10li_jmp1:     not.w    (a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt10li_loop:     REPT 4
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt10li_loop
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt10li_bloop
                  rts

blt11li:          lea      blt11li_jmp1(pc,d0.w),a4
                  lea      blt11li_loop(pc,d1.w),a5
blt11li_bloop:    jmp      (a4)
blt11li_jmp1:     not.w    (a1)
                  move.w   (a0)+,d0
                  or.w     d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt11li_loop:     REPT 4
                  not.l    (a1)
                  move.l   (a0)+,d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt11li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11li_bloop
                  rts

blt12li:          lea      blt12li_jmp1(pc,d0.w),a4
                  lea      blt12li_loop(pc,d1.w),a5
blt12li_bloop:    jmp      (a4)
blt12li_jmp1:     move.w   (a0)+,d0
                  not.w    d0
                  move.w   d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt12li_loop:     REPT 4
                  move.l   (a0)+,d0
                  not.l    d0
                  move.l   d0,(a1)+
                  ENDM
                  dbra     d6,blt12li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile

                  dbra     d5,blt12li_bloop
                  rts

blt13li:          lea      blt13li_jmp1(pc,d0.w),a4
                  lea      blt13li_loop(pc,d1.w),a5
blt13li_bloop:    jmp      (a4)
blt13li_jmp1:     move.w   (a0)+,d0
                  not.w    d0
                  or.w     d0,(a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt13li_loop:     REPT 4
                  move.l   (a0)+,d0
                  not.l    d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt13li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13li_bloop
                  rts

blt14li:          lea      blt14li_jmp1(pc,d0.w),a4
                  lea      blt14li_loop(pc,d1.w),a5
blt14li_bloop:    jmp      (a4)
blt14li_jmp1:     move.w   (a0)+,d0
                  and.w    d0,(a1)
                  not.w    (a1)+
                  move.w   d4,d6
                  jmp      (a5)
blt14li_loop:     REPT 4
                  move.l   (a0)+,d0
                  and.l    d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt14li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14li_bloop
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF 0
scale_blt_err:    lea   SCALE_STACK+4(sp),sp
                  rts

;Skalierender Bitblocktransfer
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
bitblt_scale:     lea   scale_buf_init(pc),a0
                  lea   scale_buf_reset(pc),a1
                  lea   scale_line_init(pc),a2
                  lea   write_line_init(pc),a3

;Skalierendes Bitblt
;Vorgaben:                 
;Register d0-d7/a0-a5 werden veraendert
;Eingaben:
;Register d0-d7 enthalten im oberen Wort jeweils die nicht geclippten Werte
;Die Paramter 4(sp) bis 18(sp) sind nur vorhanden, wenn skaliert werden muss
;d0.w qx, linke x-Koordinate des Quellrechtecks
;d1.w qy, obere y-Koordinate des Quellrechtecks
;d2.w zx, linke x-Koordinate des Zielrechtecks
;d3.w zy, obere y-Koordinate des Zielrechtecks
;d4.w qdx, Breite der Quelle -1
;d5.w qdy, Hoehe der Quelle -1
;d6.w zdx, Breite des Ziels -1
;d7.w zdy, Hoehe des Ziels -1
;a0.l Zeiger auf scale_buf_init
;a1.l Zeiger auf scale_buf_reset
;a2.l Zeiger auf scale_line_init
;a3.l Zeiger auf write_line_init
;a6.l Workstation
;4(sp).w qx ohne Clipping
;6(sp).w qy ohne Clipping
;8(sp).w zx ohne Clipping
;10(sp).w zy ohne Clipping
;12(sp).w qdx ohne Clipping
;14(sp).w qdy ohne Clipping
;16(sp).w zdx ohne Clipping
;18(sp).w zdy ohne Clipping
scale_blt:        move.l   a1,-(sp)                         ;Zeiger auf scale_buf_reset sichern
                  lea      -SCALE_STACK(sp),sp

                  movea.l  a0,a1
                  lea      noclip_registers(sp),a0          ;Zeiger auf die ungeclippten Koordinaten
                  jsr      (a1)                             ;scale_buf_init aufrufen
                  move.l   a0,write_buffer(sp)
                  move.l   a0,scale_buffer(sp)
                  beq.s    scale_blt_err                    ;liess sich der Buffer nicht anlegen?
                  
                  movea.l  a2,a1
                  lea      noclip_registers(sp),a0          ;Zeiger auf die ungeclippten Koordinaten
                  lea      scale_registers(sp),a2           ;Zeiger auf Registerbuffer
                  jsr      (a1)                             ;scale_line_init aufrufen
                  movea.l  a0,a4                            ;Quelladresse
                  move.l   a1,scale_jump(sp)                ;Zeiger auf scale_line
                  move.l   a2,scale_jump_trans(sp)          ;Zeiger auf scale_line_trans
                  
                  lea      noclip_registers(sp),a0          ;Zeiger auf die ungeclippten Koordinaten
                  lea      write_registers(sp),a2           ;Zeiger auf Registerbuffer
                  jsr      (a3)                             ;write_line_init aufrufen
                  movea.l  a0,a5                            ;Zieladresse
                  move.l   a1,write_jump(sp)                ;Zeiger auf write_line

                  sub.w    noclip_qy(sp),d1                 ;Verschiebung der qy-Koordinate durch Clipping
                  sub.w    noclip_zy(sp),d3                 ;Verschiebung der zy-Koordinate durch Clipping

                  move.w   d7,d4                            ;zdy
                  
                  move.w   noclip_zdy(sp),d6
                  move.w   noclip_qdy(sp),d7
               
                  cmp.w    #32767,d6                        ;zu gross?
                  bhs.s    scale_ver_half
                  cmp.w    #32767,d7                        ;zu gross?
                  blo.s    scale_ver_height

scale_ver_half:   lsr.w    #1,d6                            ;halbieren, um ueberlauf zu vermeiden
                  lsr.w    #1,d7                            ;halbieren, um ueberlauf zu vermeiden
                  
scale_ver_height: addq.w   #1,d6                            ;zdy + 1 = dy + 1 
                  addq.w   #1,d7                            ;qdy + 1 = dx + 1

                  cmp.w    d7,d6                            ;dy <= dx?
                  ble.s    shrink_ver                       ;vertikal verkleinern?

;Block vertikal dehnen (Quellhoehe <= Zielhoehe, entspricht Linie mit dx <= dy)
;Vorgaben:
;Register d0-d7/a0-a5 werden veraendert
;Eingaben:
;d1.w Verschiebung der y-Quellkoordinate durch Clipping
;d3.w Verschiebung der y-Zielkoordinate durch Clipping
;d4.w Anzahl der auszugebenden Zeilen - 1
;d5.w Anzahl der einzulesenden Zeilen - 1
;d6.w xa = Zielhoehe = dy + 1 (Fehler fuer Schritt zur naechsten Quellzeile)
;d7.w ya = Quellhoehe = dx + 1 (Fehler fuer Schritt zur naechsten Zielzeile)
;a4.l Quelladresse
;a5.l Zieladresse
;a6.l Workstation
grow_ver:         move.w   d6,d5
                  neg.w    d5                               ;e = - Zielhoehe = - ( dy + 1 )
                  ext.l    d5
                  
                  tst.w    d1                               ;Verschiebung der qy-Koordinate durch Clipping?
                  beq.s    grow_ver_offset
                  
                  mulu     d6,d1                            ;Verschiebung * xa = Verschiebung * ( dy + 1 )
                  sub.l    d1,d5                            ;e korrigieren

grow_ver_offset:  tst.w    d3                               ;Verschiebung der zy-Koordinate durch Clipping
                  beq.s    grow_ver_loop
                  
                  mulu     d7,d3                            ;Verschiebung * ya = Verschiebung * ( dx + 1 )
                  add.l    d3,d5                            ;e korrigieren

grow_ver_loop:    lea      scale_registers(sp),a2           ;Zeiger auf Registerbuffer
                  movea.l  a4,a0                            ;Quelladresse
                  movea.l  scale_buffer(sp),a1              ;Zeiger auf Zwischenbuffer
                  movea.l  scale_jump(sp),a3                ;Zeiger auf scale_line
                  jsr      (a3)                             ;Zeile skalieren

grow_ver_test:    movea.l  sp,a2                            ;lea  write_buffer(sp),a2
                  movea.l  (a2)+,a0                         ;Zeiger auf den Zwischenbuffer
                  movea.l  a5,a1                            ;Zieladresse
                  movea.l  (a2)+,a3                         ;Zeiger auf write_line, a2 zeigt auf Registerbuffer
                  jsr      (a3)                             ;Zeile ausgeben
                  adda.w   r_dwidth(a6),a5                  ;naechste Zielzeile

grow_ver_err:     add.w    d7,d5                            ;+ ya, naechste Zielzeile
                  bpl.s    grow_ver_next                    ;Fehler >= 0, naechstes Quellpixel?
                  dbra     d4,grow_ver_test                 ;sind noch weitere Zielzeilen vorhanden?
                  bra.s    grow_ver_exit

grow_ver_next:    sub.w    d6,d5                            ;- xa, naechste Quellzeile
                  adda.w   r_swidth(a6),a4                  ;naechste Quellzeile
                  dbra     d4,grow_ver_loop                 ;sind noch weitere Zielzeilen vorhanden?

grow_ver_exit:    movea.l  (sp),a0                          ;Zeiger auf den Buffer
                  lea      SCALE_STACK(sp),sp
                  movea.l  (sp)+,a1                         ;Zeiger auf scale_buf_reset
                  jmp      (a1)                             ;Buffer freigeben

;Block vertikal stauchen (Quellhoehe >= Zielhoehe, entspricht Linie mit dx >= dy)
;Vorgaben:
;Register d0-d7/a0-a5 werden veraendert
;Eingaben:
;d1.w Verschiebung der y-Quellkoordinate durch Clipping
;d3.w Verschiebung der y-Zielkoordinate durch Clipping
;d4.w Anzahl der auszugebenden Zeilen - 1
;d5.w Anzahl der einzulesenden Zeilen - 1
;d6.w xa = Zielhoehe = dy + 1 (Fehler fuer Schritt zu naechsten Quellzeile)
;d7.w ya = Quellhoehe = dx + 1 (Fehler fuer Schritt zur naechsten Zielzeile)
;a4.l Quelladresse
;a5.l Zieladresse
;a6.l Workstation
;Ausgaben:
;-
shrink_ver:       move.w   d5,d4                            ;Anzahl der einzulesenden Zeilen - 1
                  
                  move.w   d7,d5
                  neg.w    d5                               ;e = - Quellhoehe = - ( dx + 1 )
                  ext.l    d5
                  
                  tst.w    d1                               ;Verschiebung der qy-Koordinate durch Clipping?
                  beq.s    shrink_ver_off
                  
                  mulu     d6,d1                            ;Verschiebung * xa = Verschiebung * ( dy + 1 )
                  add.l    d1,d5                            ;e korrigieren

shrink_ver_off:   tst.w    d3                               ;Verschiebung der zy-Koordinate durch Clipping
                  beq.s    shrink_ver_loop
                  
                  mulu     d7,d3                            ;Verschiebung * ya = Verschiebung  * ( dx + 1 )
                  sub.l    d3,d5                            ;e korrigieren

shrink_ver_loop:  movea.l  scale_jump(sp),a3                ;Zeiger auf scale_line
                  bra.s    shrink_ver_reg

shrink_ver_trans: movea.l  scale_jump_trans(sp),a3          ;Zeiger auf scale_line_trans
shrink_ver_reg:   lea      scale_registers(sp),a2           ;Zeiger auf Registerbuffer
                  movea.l  a4,a0                            ;Quelladresse
                  movea.l  scale_buffer(sp),a1              ;Zeiger auf Zwischenbuffer
                  jsr      (a3)                             ;Zeile skalieren

shrink_ver_err:   adda.w   r_swidth(a6),a4                  ;naechste Quellzeile
                  add.w    d6,d5                            ;+ xa, naechste Quellzeile
                  bpl.s    shrink_ver_next                  ;Fehler >= 0, naechste Zielzeile?
                  dbra     d4,shrink_ver_trans              ;sind noch weitere Quellzeilen vorhanden?
   
                  moveq    #0,d4                            ;Zeile ausgeben und Funktion verlassen

shrink_ver_next:  movea.l  sp,a2                            ;lea  write_buffer(sp),a2
                  movea.l  (a2)+,a0                         ;Zeiger auf den Zwischenbuffer
                  movea.l  a5,a1                            ;Zieladresse
                  movea.l  (a2)+,a3                         ;Zeiger auf write_line, a2 zeigt auf Registerbuffer
                  jsr      (a3)                             ;Zeile ausgeben

                  sub.w    d7,d5                            ;- ya, naechste Zielzeile
                  adda.w   r_dwidth(a6),a5                  ;naechste Zielzeile
                  dbra     d4,shrink_ver_loop               ;sind noch weitere Quellzeilen vorhanden?

                  movea.l  (sp),a0                          ;Zeiger auf den Buffer
                  lea      SCALE_STACK(sp),sp
                  movea.l  (sp)+,a1                         ;Zeiger auf scale_buf_reset
                  jmp      (a1)                             ;Buffer freigeben

;Buffer
;Vorgaben:
;Register d0-d7/a1-a7 duerfen nicht veraendert werden
;Eingaben:
;d0.w qx, linke x-Koordinate des Quellrechtecks
;d1.w qy, obere y-Koordinate des Quellrechtecks
;d2.w zx, linke x-Koordinate des Zielrechtecks
;d3.w zy, obere y-Koordinate des Zielrechtecks
;d4.w qdx, Breite der Quelle -1
;d5.w qdy, Hoehe der Quelle -1
;d6.w zdx, Breite des Ziels -1
;d7.w zdy, Hoehe des Ziels -1
;a6.l Workstation
;Ausgaben:
;a0.l Zeiger auf den Buffer oder 0L
scale_buf_init:   move.l   d0,-(sp)
                  moveq    #15,d0
                  and.w    d2,d0
                  add.w    d6,d0                            
                  add.w    #16,d0
                  add.w    d0,d0                            ;Bufferlaenge in Bytes

                  tst.w    r_splanes(a6)                    ;16 Bit?
                  bne.s    scale_buf_len
                  
                  lsr.w    #5,d0                            ;Anzahl der Worte
                  addq.w   #1,d0                            ;Anzahl der Worte + 1
                  add.w    d0,d0                            ;Anzahl der Bytes + 2
                  
scale_buf_len:    movea.l  nvdi_struct(pc),a0
                  movea.l  _nvdi_nmalloc(a0),a0             ;Zeiger auf nmalloc
                  jsr      (a0)
                  
                  move.l   (sp)+,d0
                  rts

;Vorgaben:
;Register d0-d7/a1-a7 duerfen nicht veraendert werden
;Eingaben:
;a0.l Zeiger auf den Buffer
;a6.l Workstation
;Ausgaben:
;-
scale_buf_reset:  movem.l  d0/a0-a1,-(sp)
                  movea.l  nvdi_struct(pc),a1
                  movea.l  _nvdi_nmfree(a1),a1              ;Zeiger auf nmfree
                  jsr      (a1)
                  movem.l  (sp)+,d0/a0-a1
                  rts

;Eingaben:
;d0.w qx (linke x-Koordinate des Quellrechtecks)
;d1.w qy (obere y-Koordinate des Quellrechtecks)
;d2.w zx (linke x-Koordinate des Zielrechtecks)
;d3.w zy (obere y-Koordinate des Zielrechtecks)
;d4.w qdx (Breite der Quelle -1)
;d5.w qdy (Hoehe der Quelle -1)
;d6.w zdx (Breite des Ziels -1)
;d7.w zdy (Hoehe des Ziels -1)
;a0.l Zeiger auf die ungeclippten Koordinaten
;a2.l Zeiger auf Buffer fuer Daten
;a6.l Workstation
;Ausgaben:
;a0.l Startadresse des Quellzeigers
;a1.l Zeiger auf scale_line
;a2.l Zeiger auf scale_line_trans
scale_line_init:  movem.l  d0-d7,-(sp)

                  movea.l  r_saddr(a6),a1
                  muls     r_swidth(a6),d1
                  adda.l   d1,a1
                  move.w   d0,d1
                  ext.l    d1
                  add.l    d1,d1
                  tst.w    r_splanes(a6)                    ;16 Bit?
                  bne.s    scale_init_addr
                  asr.l    #5,d1
                  add.l    d1,d1
scale_init_addr:  adda.l   d1,a1                            ;Quelladresse

scale_init_zx:    move.w   d2,d7                            ;zx
                  
                  move.w   d4,d2                            ;qdx
                  move.w   d6,d3                            ;zdx
                  
                  move.w   d0,d6                            ;qx
                  moveq    #15,d4
                  and.w    d6,d4                            ;Verschiebung der Quelldaten nach links
                  
                  sub.w    (a0),d6                          ;Verschiebung der qx-Koordinate durch Clipping
                  sub.w    2*2(a0),d7                       ;Verschiebung der zx-Koordinate durch Clipping

                  move.w   4*2(a0),d0                       ;qdx ohne Clipping
                  move.w   6*2(a0),d1                       ;zdx ohne Clipping
                  
                  cmp.w    #32767,d0                        ;zu gross?
                  bhs.s    scale_init_half
                  cmp.w    #32767,d1                        ;zu gross?
                  blo.s    scale_init_width

scale_init_half:  lsr.w    #1,d0                            ;halbieren, um ueberlauf zu vermeiden
                  lsr.w    #1,d1                            ;halbieren, um ueberlauf zu vermeiden

scale_init_width: addq.w   #1,d0                            ;Breite der Quelle ohne Clipping
                  addq.w   #1,d1                            ;Breite des Ziels ohne Clipping

scale_init_cmp:   cmp.w    d0,d1
                  ble.s    scale_init_shr                   ;verkleinern?
                  
                  move.w   d1,d2
                  neg.w    d2                               ;e = - Zielbreite = - dy
                  ext.l    d2
                  
                  tst.w    d6                               ;Verschiebung der qx-Koordinate durch Clipping?
                  beq.s    scale_init_gya
                  mulu     d1,d6                            ;Verschiebung * xa
                  sub.l    d6,d2                            ;e korrigieren

scale_init_gya:   tst.w    d7                               ;Verschiebung der zx-Koordinate durch Clipping?
                  beq.s    scale_init_exit
                  mulu     d0,d7                            ;Verschiebung * ya
                  add.l    d7,d2                            ;e korrigieren
                  bra.s    scale_init_exit

scale_init_shr:   move.w   d0,d3
                  neg.w    d3                               ;e = - Quellbreite = - dx
                  ext.l    d3

                  tst.w    d6                               ;Verschiebung der qx-Koordinate durch Clipping?
                  beq.s    scale_init_sya
                  mulu     d1,d6                            ;Verschiebung * xa
                  add.l    d6,d3                            ;e korrigieren

scale_init_sya:   tst.w    d7                               ;Verschiebung der zx-Koordinate durch Clipping?
                  beq.s    scale_init_exit
                  mulu     d0,d7                            ;Verschiebung * ya
                  sub.l    d7,d3                            ;e korrigieren
                  
scale_init_exit:  move.w   d1,d6                            ;xa = Zielbreite = dy + 1
                  move.w   d0,d7                            ;ya = Quellbreite = dx + 1
                  
                  movem.w  d2-d4/d6-d7,(a2)                 ;Register sichern
                  movea.l  a1,a0                            ;Quelladresse

                  tst.w    r_splanes(a6)                    ;16 Bit?
                  bne.s    scale_init16

                  lea      scale_line1(pc),a1
                  lea      scale_line1_trans(pc),a2

                  movem.l  (sp)+,d0-d7
                  rts

scale_init16:     lea      scale_line16(pc),a1
                  lea      scale_line16_trans(pc),a2

                  movem.l  (sp)+,d0-d7
                  rts
                  
;Zeile skalieren
;Vorgaben:
;Register d4-d7.w muessen werden gesichert
;Register d0-d3/(d4-d7)/a0-a3 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
scale_line1_trans:
scale_line1:      movem.w  d4/d6-d7,-(sp)                   ;Register sichern

                  movem.w  (a2),d2-d4/a2-a3                 ;Register besetzen
                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line1                     ;verkleinern?

;Zeile verbreitern (Quellbreite <= Zielbreite, entspricht Linie mit dx <= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w e = - Zielbreite = - dy
;d3.w Anzahl der auszugebenden Pixel - 1
;d4.w Verschiebung der Quelldaten nach links (xs & 15)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
grow_line1:       move.w   #$8000,d6
                  moveq    #0,d7
                  bra.s    grow_line1_read

grow_line1_next:  sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  ror.w    #1,d6                            ;Maske um ein Pixel verschieben
                  dbcs     d3,grow_line1_loop               ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  move.w   d7,(a1)+
                  moveq    #0,d7
                  subq.w   #1,d3                            ;sind noch weitere Zielpixel vorhanden?
                  bmi.s    grow_line1_exit
grow_line1_loop:  dbra     d0,grow_line1_test
grow_line1_read:  moveq    #15,d0                           ;Pixelzaehler fuer ein Wort
                  move.l   (a0),d1                          ;16 + 16 Pixel einlesen
                  addq.l   #2,a0
                  lsl.l    d4,d1
                  swap     d1
grow_line1_test:  btst     d0,d1                            ;Pixel gesetzt?
                  beq.s    grow_line1_err
                  or.w     d6,d7
grow_line1_err:   add.w    a3,d2                            ;+ ya, naechstes Zielpixel
                  bpl.s    grow_line1_next                  ;Fehler >= 0, naechstes Quellpixel?
                  ror.w    #1,d6
                  dbcs     d3,grow_line1_test               ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  move.w   d7,(a1)+
                  moveq    #0,d7
                  subq.w   #1,d3                            ;sind noch weitere Zielpixel vorhanden
                  bpl.s    grow_line1_test
grow_line1_exit:  movem.w  (sp)+,d4/d6-d7
                  rts

;Zeile verkleinern (Quellbreite >= Zielbreite, entspricht Linie mit dx >= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w Anzahl der einzulesenden Pixel - 1
;d3.w e = - Quellbreite = - dx
;d4.w Verschiebung der Quelldaten nach links (xs & 15)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
shrink_line1:     move.w   #$8000,d6
                  moveq    #0,d7
                  bra.s    shrink_line1_read
                  
shrink_line1_next:sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  ror.w    #1,d6
                  dbcs     d2,shrink_line1_loop             ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
                  move.w   d7,(a1)+
                  moveq    #0,d7
                  subq.w   #1,d2                            ;sind noch weitere Quellpixel vorhanden?
                  bmi.s    shrink_line1_exit
shrink_line1_loop:dbra     d0,shrink_line1_test
shrink_line1_read:moveq    #15,d0                           ;Pixelzaehler fuer ein Wort  
                  move.l   (a0),d1                          ;16 + 16 Pixel einlesen
                  addq.l   #2,a0
                  lsl.l    d4,d1                            ;nach links schieben
                  swap     d1
shrink_line1_test:btst     d0,d1                            ;Pixel gesetzt?
                  beq.s    shrink_line1_err
                  or.w     d6,d7
shrink_line1_err: add.w    a2,d3                            ;+ xa, naechstes Quellpixel
                  bpl.s    shrink_line1_next                ;Fehler >= 0, naechstes Zielpixel?
                  dbra     d2,shrink_line1_loop             ;sind noch weitere Quellpixel vorhanden?
                  move.w   d7,(a1)+
shrink_line1_exit:movem.w  (sp)+,d4/d6-d7
                  rts

;Zeile skalieren
;Vorgaben:
;Register d4-d7.w muessen werden gesichert
;Register d0-d3/(d4-d7)/a0-a3 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
scale_line16_trans:
scale_line16:     movem.w  (a2),d2-d3
                  movem.w  3*2(a2),a2-a3

                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line16                    ;verkleinern?

;Zeile verbreitern (Quellbreite <= Zielbreite, entspricht Linie mit dx <= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w e = - Zielbreite = - dy
;d3.w Anzahl der auszugebenden Pixel - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
grow_line16:      move.w   (a0)+,d1                         ;Pixel einlesen
grow_line16_wr:   move.w   d1,(a1)+                         ;Pixel ausgeben
                  add.w    a3,d2                            ;+ ya, naechstes Zielpixel
                  bpl.s    grow_line16_next                 ;Fehler >= 0, naechstes Quellpixel?
                  dbra     d3,grow_line16_wr                ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  rts

grow_line16_next: sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  dbra     d3,grow_line16                   ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  rts

;Zeile verkleinern (Quellbreite >= Zielbreite, entspricht Linie mit dx >= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w Anzahl der einzulesenden Pixel - 1
;d3.w e = - Quellbreite = - dx
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
shrink_line16:    move.w   (a0)+,d1
                  add.w    a2,d3                            ;+ xa, naechstes Quellpixel
                  bpl.s    shrink_line16_nx                 ;Fehler >= 0, naechstes Zielpixel?
                  dbra     d2,shrink_line16                 ;sind noch weitere Quellpixel vorhanden?
                  move.w   d1,(a1)+
                  rts

shrink_line16_nx: move.w   d1,(a1)+
                  sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  dbra     d2,shrink_line16                 ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
                  rts

;Eingaben:
;d0.w qx (linke x-Koordinate des Quellrechtecks)
;d1.w qy (obere y-Koordinate des Quellrechtecks)
;d2.w zx (linke x-Koordinate des Zielrechtecks)
;d3.w zy (obere y-Koordinate des Zielrechtecks)
;d4.w qdx (Breite der Quelle -1)
;d5.w qdy (Hoehe der Quelle -1)
;d6.w zdx (Breite des Ziels -1)
;d7.w zdy (Hoehe des Ziels -1)
;a2.l Zeiger auf Buffer fuer Daten
;a6.l Workstation
;Ausgaben:
;a0.l Startadresse des Zielzeigers
;a1.l Zeiger auf write_line
write_line_init:  movem.l  d0-d3,-(sp)
                  movea.l  r_daddr(a6),a0
                  muls     r_dwidth(a6),d3
                  adda.l   d3,a0
                  adda.w   d2,a0
                  adda.w   d2,a0                            ;Zieladresse
                  
                  tst.w    r_splanes(a6)                    ;16 Bit?
                  bne.s    write_line_init16
                  
                  moveq    #15,d0
                  and.w    d6,d0                            ;Anzahl der restlichen Pixel - 1
                  swap     d0
                  move.w   d6,d0
                  lsr.w    #4,d0                            ;Anzahl der Worte - 1
                  move.l   d0,(a2)+
                  
                  lea      c_palette(a6),a1
                  move.w   r_fgcol(a6),d0
                  add.w    d0,d0
                  move.w   0(a1,d0.w),(a2)+                 ;Vordergrundfarbe
                  move.w   r_bgcol(a6),d0
                  add.w    d0,d0
                  move.w   0(a1,d0.w),(a2)+                 ;Hintergrundfarbe

                  moveq    #3,d0
                  and.w    r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   wl_1_16_tab(pc,d0.w),d0          ;Offset der Funktion
                  lea      wl_1_16_tab(pc,d0.w),a1          ;Zeiger auf Ausgabefunktion
                  movem.l  (sp)+,d0-d3
                  rts

wl_1_16_tab:      DC.W  wl_1_16_repl-wl_1_16_tab
                  DC.W  wl_1_16_trans-wl_1_16_tab
                  DC.W  wl_1_16_eor-wl_1_16_tab
                  DC.W  wl_1_16_rev_trans-wl_1_16_tab
                  
write_line_init16:moveq    #15,d0
                  and.w    r_wmode(a6),d0
               
                  moveq    #0,d1
                  move.w   d6,d1
                  swap     d1

                  cmp.w    #3,d0                            ;nicht ersetzend?
                  bne.s    write_line_cnt16
                  
                  moveq    #1,d1
                  and.w    d6,d1
                  swap     d1
                  move.w   d6,d1
                  lsr.w    #1,d1

write_line_cnt16: move.l   d1,(a2)+
                  
                  add.w    d0,d0
                  move.w   wl_16_16_tab(pc,d0.w),d0         ;Offset der Funktion
                  lea      wl_16_16_tab(pc,d0.w),a1         ;Zeiger auf Ausgabefunktion

                  movem.l  (sp)+,d0-d3
                  rts

wl_16_16_tab:     DC.W  wl_16_16_mode0-wl_16_16_tab
                  DC.W  wl_16_16_mode1-wl_16_16_tab
                  DC.W  wl_16_16_mode2-wl_16_16_tab
                  DC.W  wl_16_16_mode3-wl_16_16_tab
                  DC.W  wl_16_16_mode4-wl_16_16_tab
                  DC.W  wl_16_16_mode5-wl_16_16_tab
                  DC.W  wl_16_16_mode6-wl_16_16_tab
                  DC.W  wl_16_16_mode7-wl_16_16_tab
                  DC.W  wl_16_16_mode8-wl_16_16_tab
                  DC.W  wl_16_16_mode9-wl_16_16_tab
                  DC.W  wl_16_16_mode10-wl_16_16_tab
                  DC.W  wl_16_16_mode11-wl_16_16_tab
                  DC.W  wl_16_16_mode12-wl_16_16_tab
                  DC.W  wl_16_16_mode13-wl_16_16_tab
                  DC.W  wl_16_16_mode14-wl_16_16_tab
                  DC.W  wl_16_16_mode15-wl_16_16_tab
                              
;Zeile ausgeben, von 1 Bit auf 16 Bit expandieren, REPLACE
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_16_repl:     move.l   d4,a3                            ;d4 sichern
                  move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.w   (a2)+,d2                         ;Vordergrundfarbe
                  move.w   (a2)+,d3                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_16_rpl_end

wl_1_16_rpl_loop: move.w   (a0)+,d1
                  moveq    #15,d4

wl_1_16_rpl_word: add.w    d1,d1
                  bcc.s    wl_1_16_rpl_bg
                  move.w   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d4,wl_1_16_rpl_word
                  
                  dbra     d0,wl_1_16_rpl_loop
                  bra.s    wl_1_16_rpl_end

wl_1_16_rpl_bg:   move.w   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d4,wl_1_16_rpl_word
                  dbra     d0,wl_1_16_rpl_loop

wl_1_16_rpl_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_16_rpl_endfg:add.w    d1,d1
                  bcc.s    wl_1_16_rpl_endbg
                  move.w   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d0,wl_1_16_rpl_endfg

                  move.l   a3,d4
                  rts

wl_1_16_rpl_endbg:move.w   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d0,wl_1_16_rpl_endfg

                  move.l   a3,d4
                  rts

;Zeile ausgeben, von 1 Bit auf 16 Bit expandieren, TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_16_trans:    move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.w   (a2)+,d2                         ;Vordergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_16_trn_end

wl_1_16_trn_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_16_trn_word: add.w    d1,d1
                  bcc.s    wl_1_16_trn_bg
                  move.w   d2,(a1)                          ;Vordergrundfarbe
wl_1_16_trn_bg:   addq.l   #2,a1
                  dbra     d3,wl_1_16_trn_word
                  dbra     d0,wl_1_16_trn_loop

wl_1_16_trn_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_16_trn_endfg:add.w    d1,d1
                  bcc.s    wl_1_16_trn_endbg
                  move.w   d2,(a1)                          ;Vordergrundfarbe
wl_1_16_trn_endbg:addq.l   #2,a1
                  dbra     d0,wl_1_16_trn_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 16 Bit expandieren, EOR
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_16_eor:      move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_16_eor_end

wl_1_16_eor_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_16_eor_word: add.w    d1,d1
                  scs      d2
                  ext.w    d2
                  eor.w    d2,(a1)+
                  dbra     d3,wl_1_16_eor_word
                  dbra     d0,wl_1_16_eor_loop

wl_1_16_eor_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_16_eor_endfg:add.w    d1,d1
                  scs      d2
                  ext.w    d2
                  eor.w    d2,(a1)+
                  dbra     d0,wl_1_16_eor_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 16 Bit expandieren, REVERS TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_16_rev_trans:move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.l   (a2)+,d2                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_16_rtr_end

wl_1_16_rtr_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_16_rtr_word: add.w    d1,d1
                  bcs.s    wl_1_16_rtr_fg
                  move.w   d2,(a1)                          ;Hintergrundfarbe
wl_1_16_rtr_fg:   addq.l   #2,a1
                  dbra     d3,wl_1_16_rtr_word
                  dbra     d0,wl_1_16_rtr_loop

wl_1_16_rtr_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_16_rtr_endbg:add.w    d1,d1
                  bcs.s    wl_1_16_rtr_endfg
                  move.w   d2,(a1)                          ;Hintergrundfarbe
wl_1_16_rtr_endfg:addq.l   #2,a1
                  dbra     d0,wl_1_16_rtr_endbg

                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile ausgeben, Modus 0 (ALL_ZERO)
wl_16_16_mode0:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #0,d1
wl_16_16_m0_loop: move.w   d1,(a1)+
                  dbra     d0,wl_16_16_m0_loop
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_16_16_mode1:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m1_loop: move.w   (a0)+,d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_16_16_m1_loop
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_16_16_mode2:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m2_loop: move.w   (a0)+,d1
                  not.w    (a1)
                  and.w    d1,(a1)+
                  dbra     d0,wl_16_16_m2_loop
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_16_16_mode3:   move.w   (a2)+,d1
                  move.w   (a2)+,d0
                  subq.w   #1,d0
                  bmi.s    wl_16_16_m3_loopw
wl_16_16_m3_loopl:move.l   (a0)+,(a1)+
                  dbra     d0,wl_16_16_m3_loopl
wl_16_16_m3_loopw:move.w   (a0)+,(a1)+
                  dbra     d1,wl_16_16_m3_loopw
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_16_16_mode4:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m4_loop: move.w   (a0)+,d1
                  not.w    d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_16_16_m4_loop
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_16_16_mode5:   rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_16_16_mode6:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m6_loop: move.w   (a0)+,d1
                  eor.w    d1,(a1)+
                  dbra     d0,wl_16_16_m6_loop
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_16_16_mode7:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m7_loop: move.w   (a0)+,d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_16_16_m7_loop
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_16_16_mode8:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m8_loop: move.w   (a0)+,d1
                  or.w     d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_16_16_m8_loop
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_16_16_mode9:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m9_loop: move.w   (a0)+,d1
                  eor.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_16_16_m9_loop
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_16_16_mode10:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m10_loop:not.w    (a1)+
                  dbra     d0,wl_16_16_m10_loop
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_16_16_mode11:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m11_loop:move.w   (a0)+,d1
                  not.w    (a1)
                  or.w     d1,(a1)+
                  dbra     d0,wl_16_16_m11_loop
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_16_16_mode12:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m12_loop:move.w   (a0)+,d1
                  not.w    d1
                  move.w   d1,(a1)+
                  dbra     d0,wl_16_16_m12_loop
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_16_16_mode13:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m13_loop:move.w   (a0)+,d1
                  not.w    d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_16_16_m13_loop
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_16_16_mode14:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_16_16_m14_loop:move.w   (a0)+,d1
                  and.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_16_16_m14_loop
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_16_16_mode15:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #$ffffffff,d1
wl_16_16_m15_loop:move.w   d1,(a1)+
                  dbra     d0,wl_16_16_m15_loop
                  rts
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'v_contourfill'

;Zeile absuchen bis sich die Pixelfarbe aendert
;Vorgaben:
;Register d0-d4/a3-a4 koennen veraendert werden
;Eingaben:
;d0.w x
;d1.w y
;d2.l clip_xmin/clip_xmax
;a0.l Adresse des Worts fuer die linke Grenze
;a1.l Adresse des Worts fuer die rechte Grenze
;a5.l Zeiger auf die Seedfill-Struktur
;Ausgaben:
;d0.w Rueckgabewert
scanline:         move.w   d0,d3          ;X-Start merken
                  swap     d3
                  move.w   d0,d3          ;wird 2 mal gebraucht

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    scanline_screen
                  movea.l  bitmap_addr(a6),a3 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    scanline_laddr
scanline_screen:  movea.l  v_bas_ad.w,a3  ;Adresse des Bildschirms
relok8:
                  muls     BYTES_LIN.w,d1 ;Y1
scanline_laddr:   adda.l   d1,a3
                  adda.w   d0,a3
                  adda.w   d0,a3          ;Bildschirmanfang+Y-Zeile+ Zeilenoffset
                  movea.l  a3,a4          ;Pos. des Start-Words sichern

                  move.w   (a3),d4        ;Farbe des Startpunkts sichern

; Startwort
                  cmp.w    d2,d3          ;innerhalb der Clippinggrenzen?
                  bgt.s    try_l

                  addq.l   #2,a3          ;Startpunkt ueberspringen

r_word:           cmp.w    (a3)+,d4
                  bne.s    try_l          ;Begrenzung erreicht
                  addq.w   #1,d3          ;eine X-Pos. weiter
                  cmp.w    d2,d3
                  blt.s    r_word

etry_l:           move.w   d2,d3          ;X=clip_xmax


try_l:            move.w   d3,(a1)        ;rechte Begrenzung
                  swap     d2
                  swap     d3             ;X-Start holen
                  movea.l  a4,a3          ;alte Startadr.

scan_l:           cmp.w    d2,d3
                  ble.s    fnd_limits
                  move.w   d3,d0          ;X-Start


l_word:           cmp.w    -(a3),d4
                  bne.s    fnd_limits
                  subq.w   #1,d3
                  cmp.w    d2,d3          ;noch innerhalb Cliprect ?
                  bgt.s    l_word

e_limits:         move.w   d2,d3          ;X=clip_xmin

fnd_limits:       move.w   d3,(a0)        ;linke Begrenzung

                  move.w   (a5),d0

                  cmp.w    v_1e+2(a5),d4
                  beq.s    lblE0
                  eori.w   #1,d0
lblE0:            rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  DATA
                  ; 'Relozierungs-Information'
relokation:
;Reloziert am: Sun Jan 21 20:48:34 1996

                  DC.W relok0-start+2
                  DC.W relok1-relok0
                  DC.W relok2-relok1
                  DC.W relok3-relok2
                  DC.W relok4-relok3
                  DC.W relok5-relok4
                  DC.W relok6-relok5
                  DC.W relok7-relok6
                  DC.W relok8-relok7

                  DC.W 0


                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'

                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0

;Farbumwandlungstabelle fuer 256 Farben
color_map:        DS.B 256

expand_tab:       DS.B 16*256

rgb_in_tab:       DS.B  3006              ;UBYTE   rgb_in_tab[3][1002];
rgb_out_tab:      DS.W  96                ;UWORD   rgb_out_tab[3][32];

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
