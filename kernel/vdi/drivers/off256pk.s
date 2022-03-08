;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                256-Farb-Pixel-Packed-Treiber fuer NVDI 4                   *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tabulatorgroesse:  3
;Kommentare:                                                ;ab Spalte 60

;Labels und Konstanten
                  ;'Header'

ENABLE_040        EQU   1                                   ;1: Funktionen fuer 040er ansprechen

VERSION           EQU $0411

INCLUDE "..\include\linea.inc"
INCLUDE "..\include\tos.inc"
INCLUDE "..\include\seedfill.inc"

INCLUDE "..\include\nvdi_wk.inc"
INCLUDE "..\include\vdi.inc"

INCLUDE "..\include\driver.inc"

PATTERN_LENGTH    EQU (32*8)              ;Fuellmusterlaenge bei 8 Ebenen

m2                EQU 0                   ;Offset mit 2 multiplizieren
m4                EQU 1                   ;Offset mit 4 multiplizieren
m6                EQU 2                   ;Offset mit 6 multiplizieren

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'NVDI-Treiber initialisieren'
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
organisation:     DC.L  256               ;Farben
                  DC.W  8                 ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  1                 ;Bitverteilung
                  DC.W  0,0,0             ;reserviert
header_end:


continue:         rts

init:             movem.l  d0-d2/a0-a2,-(sp)

                  move.l   a0,nvdi_struct
                  bsr      make_relo      ;Treiber relozieren

                  movea.l  nvdi_struct(pc),a0
                  move.w   _nvdi_cpu020(a0),cpu020

IF ENABLE_040                                               ;040er-Code benutzen?
                  move.w   _nvdi_cookie_CPU+2(a0),d0
                  cmp.w    #40,d0
                  seq      d0
                  ext.w    d0
                  move.w   d0,cpu040
ELSE                                                        ;kein 040er-Code
                  clr.w    cpu040
ENDIF
                                    
                  bsr      build_exp      ;Expandier-Tabelle erstellen
                  bsr      build_color_maps  ;Farbcodierungstabellen erstellen
init_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  move.l   #WK_LENGTH+PATTERN_LENGTH,d0 ;Laenge einer Workstation
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
                  move.w   #256,78-90(a0) ;work_out[39]: 256 Farbabstufungen in der Palette

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
                  move.w   #256,2-90(a0)     ;work_out[1]: 256 Farbabstufungen
                  move.w   #8,8-90(a0)       ;work_out[4]: Anzahl der Farbebenen
                  clr.w    10-90(a0)         ;work_out[5]: keine CLUT vorhanden
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
                  moveq    #0,d0
                  move.w   #2,(a0)+       ;[0] Packed Pixel
                  move.w   d0,(a0)+       ;[1] keine CLUT
                  move.w   #8,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #256,(a0)+     ;[3/4] Farbanzahl
                  move.w   bitmap_width(a6),(a0)+  ;[5] Bytes pro Zeile
                  move.l   bitmap_addr(a6),(a0)+   ;[6/7] Bildschirmadresse
                  move.w   d0,(a0)+       ;[8]  Bits der Rot-Intensitaet
                  move.w   d0,(a0)+       ;[9]  Bits der Gruen-Intensitaet
                  move.w   d0,(a0)+       ;[10] Bits der Blau-Intensitaet
                  move.w   d0,(a0)+       ;[11] kein Alpha-Channel
                  move.w   d0,(a0)+       ;[12] kein Genlock
                  move.w   d0,(a0)+       ;[13] keine unbenutzten Bits
                  move.w   #1,(a0)+       ;[14] Bitorganisation
                  clr.w    (a0)+          ;[15] unbenutzt

                  move.w   #255,d0
                  lea      color_map(pc),a1
scrninfo_loop:    moveq    #0,d1
                  move.b   (a1)+,d1
                  move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

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

build_exp:        movem.l  d0-d2/a0-a1,-(sp)
                  lea      expand_tab(pc),a0
                  lea      expand_tabo(pc),a1
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Relozierungsroutine'
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

;WK-Tabelle intialisieren
;Eingaben
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
                  move.w   #7,r_planes(a6)   ;Anzahl der Bildebenen -1
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
;a6.l Workstation
;Ausgaben:
;-
set_color_rgb:    rts

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
get_color_rgb:    moveq    #-1,d0
                  moveq    #-1,d1
                  moveq    #-1,d2
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile fuer v_contourfill absuchen
;
;Diese Routine ermittelt die Farbe des Startpunktes (x,y) und sucht dann
;links und rechts davon solange, bis ein Farbwechsel auftritt. Diese Grenzen
;werden ueber die Pointer (a0/a1) gesichert
;
;d5-d7/a0-a2/a5/a6 duerfen nicht veraendert werden

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
relok0:
                  muls     BYTES_LIN.w,d1
scanline_laddr:   adda.l   d1,a3
                  adda.w   d0,a3          ;Bildschirmanfang+Y-Zeile+ Zeilenoffset
                  movea.l  a3,a4          ;Pos. des Start-Words sichern

                  moveq    #0,d4
                  move.b   (a3),d4        ;Farbe des Startpunkts sichern

; Startwort
                  cmp.w    d2,d3          ;innerhaln der Clippinggrenzen?
                  bgt.s    try_l

                  addq.l   #1,a3          ;Startpunkt ueberspringen

r_byte:           cmp.b    (a3)+,d4
                  bne.s    try_l          ;Begrenzung erreicht
                  addq.w   #1,d3          ;eine X-Pos. weiter
                  cmp.w    d2,d3
                  blt.s    r_byte

etry_l:           move.w   d2,d3          ;X=clip_xmax

try_l:            move.w   d3,(a1)        ;rechte Begrenzung
                  swap     d2
                  swap     d3             ;X-Start holen
                  movea.l  a4,a3          ;alte Startadr.

scan_l:           cmp.w    d2,d3
                  ble.s    fnd_limits
                  move.w   d3,d0          ;X-Start

l_byte:           cmp.b    -(a3),d4
                  bne.s    fnd_limits
                  subq.w   #1,d3
                  cmp.w    d2,d3          ;noch innerhalb Cliprect ?
                  bgt.s    l_byte

e_limits:         move.w   d2,d3          ;X=clip_xmin

fnd_limits:       move.w   d3,(a0)        ;linke Begrenzung

                  move.w   (a5),d0

                  cmp.l    v_1e(a5),d4
                  beq.s    lblE0
                  eori.w   #1,d0
lblE0:            rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
set_pattern:      cmp.w    #16,d0      ;16 Worte?
                  beq.s    set_pattern_mono
                  movem.l  d1-d7/a2-a6,-(sp)
                  moveq    #16,d0         ;Laenge einer Ebene in Worten
                  moveq    #15,d1         ;Wortanzahl - 1
                  bsr      transform_dev
                  movem.l  (sp)+,d1-d7/a2-a6
                  moveq    #7,d0          ;8 Farbebenen
                  rts

set_pattern_mono: REPT     8
                  move.l   (a0)+,(a1)+
                  ENDM
                  moveq    #0,d0          ;1 Ebene
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'4. Rasterfunktionen'

;Raster transformieren
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
                  bne.s    transform_frmt
                  moveq    #1,d2          ;standardisiertes Zielformat
transform_frmt:   move.w   d2,fd_stand(a1) ;Format des Zielblocks eintragen

                  movea.l  (a0),a0        ;Quellblockadresse
                  movea.l  (a1),a1        ;Zielblockadresse
                  subq.l   #1,d1          ;mindestens ein Wort?
                  bmi.s    transform_exit

                  subq.w   #1,d0          ;nur eine Ebene, monochrom?
                  beq      transform_mono
                  subq.w   #8-1,d0        ;8 Ebenen?
                  bne.s    transform_exit

                  add.w    d2,d2
                  add.w    d2,d2
                  movea.l  trnfm_tab(pc,d2.w),a2 ;Zeiger auf die Wandlungsroutine

                  cmpa.l   a0,a1          ;Quell- und Zieladresse gleich?
                  bne.s    transform_diff

                  move.l   d1,d3
                  addq.l   #1,d3          ;Wortanzahl pro Ebene
                  lsl.l    #4,d3          ;Speicherbedarf des Blocks (Wortanzahl * 2 * 8)
                  cmp.l    buffer_len(a6),d3 ;passt der Block in den Buffer?
                  bgt.s    transform_same

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
                  bra      transform_copy ;Buffer umkopieren

transform_same:   movea.l  trnfm_tab2(pc,d2.w),a2
                  bra.s    transform_jsr

transform_diff:   move.l   d1,d0
                  addq.l   #1,d0          ;Laenge einer Ebene in Worten
transform_jsr:    jsr      (a2)           ;Block wandeln

transform_exit:   move.l   (sp)+,a6
                  rts

trnfm_tab:        DC.L transform_dev
                  DC.L transform_stand

trnfm_tab2:       DC.L transform_samed
                  DC.L transform_sames


;Block mit gleicher Quell- und Zieladresse ins geraetespezifische Format wandeln
;Eingaben
;d1.l Worte pro Ebene - 1
;a0.l Quelladresse
;a1.l Zieladresse (gleich der Quelladresse)
;Ausgaben
;Register d0-d4/a0-a2 werden veraendert
transform_samed:  movem.l  d1/a0-a1,-(sp)
                  move.l   d1,d0          ;Anzahl der Worte pro Ebene - 1
                  moveq    #7,d4          ;Anzahl der Ebenen - 1
                  bsr      transform_interl ;Block in interleaved Planes wandeln
                  movem.l  (sp)+,d1/a0-a1
transform_sdev1:  movea.l  d1,a6
                  moveq    #15,d0
                  swap     d0
                  move.w   (a0)+,d7       ;Ebene 0
                  move.w   (a0)+,d6       ;Ebene 1
                  move.w   (a0)+,d5       ;Ebene 2
                  move.w   (a0)+,d4       ;Ebene 3
                  move.w   (a0)+,d3       ;Ebene 4
                  move.w   (a0)+,d2       ;Ebene 5
                  move.w   (a0)+,d1       ;Ebene 6
                  move.w   (a0)+,d0       ;Ebene 7
                  swap     d0
                  swap     d7
transform_sdev2:  swap     d0
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
                  swap     d0
                  dbra     d0,transform_sdev2
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    transform_sdev1
                  rts

;Block mit gleicher Quell- und Zieladresse ins Standardformat wandeln
;Eingaben
;d1.l Worte pro Ebene - 1
;a0.l Quelladresse
;a1.l Zieladresse (gleich der Quelladresse)
;Ausgaben
;Register d0-d4/a0-a2 werden veraendert
transform_sames:  movem.l  d1/a0-a1,-(sp)
transform_sstd1:  movea.l  d1,a6
                  moveq    #15,d0         ;16 Pixel bearbeiten
transform_sstd2:  swap     d0
                  swap     d7
                  move.b   (a0)+,d7
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
                  dbra     d0,transform_sstd2
                  swap     d0
                  move.w   d7,(a1)+       ;Ebene 0
                  move.w   d6,(a1)+       ;Ebene 1
                  move.w   d5,(a1)+       ;Ebene 2
                  move.w   d4,(a1)+       ;Ebene 3
                  move.w   d3,(a1)+       ;Ebene 4
                  move.w   d2,(a1)+       ;Ebene 5
                  move.w   d1,(a1)+       ;Ebene 6
                  move.w   d0,(a1)+       ;Ebene 7
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    transform_sstd1
                  movem.l  (sp)+,d4/a0-a1
                  moveq    #7,d0          ;interleaved Planes ins Standardformat wandeln

;Block vom Standardformat ins interleaved Bitplane-Format wandeln oder umgekehrt
;Eingaben
;d0.l Anzahl der Ebenen des Standardformats oder Anzahl der Worte pro Ebene - 1
;d4.l Anzahl der Worte pro Eben oder Anzahl der Ebenen - 1
;a0.l Quelladresse, identisch mit der Zieladresse
;Ausgaben
;Register d0-d4/a0-a2.l werden veraendert
transform_interl: subq.l   #1,d4
                  bmi.s    transform_iexit
transform_ibloop: moveq    #0,d2
                  move.l   d4,d1          ;Wortzaehler
transform_iloop:  adda.l   d0,a0
                  lea      2(a0,d0.l),a0  ;Adresse des naechsten Worts der Ebene
                  move.w   (a0),d5
                  movea.l  a0,a1
                  movea.l  a0,a2
                  add.l    d0,d2
                  move.l   d2,d3
                  bra.s    transform_inext
transform_icopy:  movea.l  a1,a2
                  move.w   -(a1),(a2)     ;alles um ein Wort verschieben
transform_inext:  subq.l   #1,d3

                  bpl.s    transform_icopy
                  move.w   d5,(a1)
                  subq.l   #1,d1
                  bpl.s    transform_iloop
                  movea.l  a2,a0
                  subq.l   #1,d0
                  bpl.s    transform_ibloop
transform_iexit:  rts

;Block ins Standardformat transformieren
;Eingaben
;d0.l Laenge einer Ebene in Worten
;d1.l Pixelanzahl/16 -1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;d0-d7/a0-a6 werden veraendert
transform_stand:  add.l    d0,d0          ;Laenge einer Ebene in Bytes
                  lea      0(a1,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

transform_sbloop: movea.l  d1,a6
                  moveq    #15,d0         ;16 Pixel bearbeiten
transform_sloop:  swap     d0
                  swap     d7
                  move.b   (a0)+,d7
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
                  dbra     d0,transform_sloop
                  swap     d0
                  move.w   d7,(a1)+       ;Ebene 0
                  move.w   d6,(a2)+       ;Ebene 1
                  move.w   d5,(a3)+       ;Ebene 2
                  move.w   d4,(a4)+       ;Ebene 3
                  move.w   d3,-2(a1,a5.l) ;Ebene 4
                  move.w   d2,-2(a2,a5.l) ;Ebene 5
                  move.w   d1,-2(a3,a5.l) ;Ebene 6
                  move.w   d0,-2(a4,a5.l) ;Ebene 7
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    transform_sbloop
                  rts

;Block ins geraetespezifische Format transformieren
;Eingaben
;d0.l Laenge einer Ebene in Worten
;d1.l Pixelanzahl/16 -1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;d0-d7/a0-a6 werden veraendert
transform_dev:    add.l    d0,d0          ;Laenge einer Ebene in Bytes
                  lea      0(a0,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

transform_dbloop: movea.l  d1,a6
                  moveq    #15,d0
                  swap     d0
                  move.w   (a0)+,d7       ;Ebene 0
                  move.w   (a2)+,d6       ;Ebene 1
                  move.w   (a3)+,d5       ;Ebene 2
                  move.w   (a4)+,d4       ;Ebene 3
                  move.w   -2(a0,a5.l),d3 ;Ebene 4
                  move.w   -2(a2,a5.l),d2 ;Ebene 5
                  move.w   -2(a3,a5.l),d1 ;Ebene 6
                  move.w   -2(a4,a5.l),d0 ;Ebene 7
                  swap     d0
                  swap     d7

transform_dloop:  swap     d0
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
                  swap     d0
                  dbra     d0,transform_dloop
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    transform_dbloop
                  rts

;monochromen Block kopieren
;Eingaben
;d1.l Laenge in Worten - 1
;a0.l Quelladresse
;a1.l Zieladresse
;Ausgaben
;Register d1/a0/a1.l werden veraendert

transform_mono:   cmpa.l   a0,a1          ;gleiche Adresse?
                  beq.s    transform_cexit
transform_copy:   lsr.l    #1,d1          ;ein Wort uebertrag?
                  bcs.s    transform_cloop
                  move.w   (a0)+,(a1)+
                  bra.s    transform_cnext
transform_cloop:  move.l   (a0)+,(a1)+
transform_cnext:  subq.l   #1,d1
                  bpl.s    transform_cloop

transform_cexit:  movea.l  (sp)+,a6
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
relok1:
                  muls     BYTES_LIN.w,d1
get_pixel_line:   add.l    d1,a0
                  add.w    d0,a0
                  moveq    #0,d0
                  move.b   (a0),d0
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
relok2:
                  muls     BYTES_LIN.w,d1
set_pixel_line:   add.l    d1,a0
                  add.w    d0,a0
                  move.b   d2,(a0)
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
vdi_to_color:     lea      color_map(pc),a0
                  adda.w   d0,a0
                  moveq    #0,d0
                  move.b   (a0),d0
                  rts

;Farbwert in VDI-Farbindex umsetzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l Farbwert
;a6.l Workstation
;Ausgaben:
;d0.w VDI-Farbindex
color_to_vdi:     lea      color_remap(pc),a0
                  adda.w   d0,a0
                  moveq    #0,d0
                  move.b   (a0),d0
                  rts
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'horizontale Linie'

                  ALIGN 16
                  DCB.B 6,0

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
hline:            lea      color_map(pc),a1
                  adda.w   l_color(a6),a1
hline_color:      movep.w  0(a1),d5
                  move.b   (a1),d5        ;Ebenenzuordnung
                  move.w   d5,d4
                  swap     d4
                  move.w   d5,d4

                  tst.w    bitmap_addr(a6) ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr
hline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok3:
                  muls     BYTES_LIN.w,d1
hline_laddr:      ext.l    d0
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

hline_replace:    cmp.w    #$ffff,d6      ;durchgehendes Linienmuster?
                  beq      hline_solid
                  
                  move.l   a3,-(sp)
                  move.w   d5,-(sp)

                  sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

                  moveq    #16,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_repl_loop
                  move.w   d2,d0

hline_repl_loop:  add.w    d6,d6          ;Punkt gesetzt?
                  scs      d5
                  and.w    (sp),d5

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
                  move.b   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_repl_points

                  addq.l   #1,a1
                  subq.w   #1,d2
                  dbra     d0,hline_repl_loop
                  move.w   (sp)+,d5
                  movea.l  (sp)+,a3
                  rts

hline_rev_trans:  not.w    d6
hline_trans:      cmp.w    #$ffff,d6      ;durchgehendes Linienmuster?
                  beq      hline_solid
                  
                  move.l   a3,-(sp)

                  sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

                  moveq    #16,d1         ;Abstand identischer Punkte des Musters

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
                  move.b   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_tr_points

hline_tr_next:    addq.l   #1,a1

                  subq.w   #1,d2
                  dbra     d0,hline_tr_loop
                  movea.l  (sp)+,a3
                  rts

hline_eor_grow2:  addq.l   #1,a1
                  dbra     d2,hline_eor_grow
                  rts
hline_eor_grow:   lsr.w    #1,d2
                  move.w   #$ff00,d4
                  move.l   a1,d0
                  btst     #0,d0
                  beq.s    hline_grow_loop
                  subq.l   #1,a1
                  not.w    d4             ;d4 = $00ff
hline_grow_loop:  eor.w    d4,(a1)+
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

                  moveq    #16,d1         ;Abstand identischer Punkte des Musters

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
                  eor.b    d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,hline_eor_points

hline_eor_next:   addq.l   #1,a1
                  subq.w   #1,d2
                  dbra     d0,hline_eor_loop
                  movea.l  (sp)+,a3
                  rts

hline_solid:      sub.w    d0,d2          ;dx
hline_sld_loop:   move.b   d4,(a1)+
                  dbra     d2,hline_sld_loop
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'horizontale Linie  mit Fuellmuster

                  ALIGN 16
                  DCB.B 6,0

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
fline:            tst.w    f_planes(a6)   ;mehrere Ebenen?
                  bne.s    fline_save

fline_mono_pat:   movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6  ;Linienstil

                  lea      color_map(pc),a1
                  adda.w   f_color(a6),a1

                  bra      hline_color
fline_exit:       rts

fline_save:       move.l   a0,-(sp)
                  move.l   a3,-(sp)
                  movea.l  f_pointer(a6),a0
                  moveq    #15,d4
                  and.w    d1,d4
                  lsl.w    #4,d4
                  adda.w   d4,a0

;                 lea      color_map(pc),a1
;                 adda.w   f_color(a6),a1
;                 movep.w  0(a1),d5
;                 move.b   (a1),d5        ;Ebenenzuordnung
;                 move.w   d5,d4
;                 swap     d4
;                 move.w   d5,d4
                  moveq    #$ffffffff,d4
                  moveq    #$ffffffff,d5

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fline_screen
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    fline_laddr
fline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok4:
                  muls     BYTES_LIN.w,d1
fline_laddr:      ext.l    d0
                  add.l    d0,d1
                  adda.l   d1,a1          ;Zieladresse

                  sub.w    d0,d2          ;dx

                  moveq    #16,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d6         ;Punktezaehler fuers Muster
                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fline_jmp
                  move.w   d2,d6

fline_jmp:        
;                 add.w    d7,d7
                  moveq    #0,d7
                  move.w   fline_tab(pc,d7.w),d7
                  jsr      fline_tab(pc,d7.w)
                  movea.l  (sp)+,a3
                  movea.l  (sp)+,a0
                  rts
fline_tab:        DC.W fline_replace-fline_tab
                  DC.W fline_trans-fline_tab
                  DC.W fline_eor-fline_tab
                  DC.W fline_rev_trans-fline_tab

fline_replace:    move.w   d5,-(sp)

fline_repl_loop:  andi.w   #15,d0
                  move.b   0(a0,d0.w),d5
                  and.w    (sp),d5

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      fline_repl_points(pc,d7.w)

fline_repl_points:REPT 16
                  move.b   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,fline_repl_points

                  addq.l   #1,a1
                  subq.w   #1,d2
                  addq.w   #1,d0
                  dbra     d6,fline_repl_loop
                  move.w   (sp)+,d5
                  rts

fline_rev_trans:  movea.l  buffer_addr(a6),a3
                  REPT 4
                  move.l   (a0)+,d1
                  not.l    d1
                  move.l   d1,(a3)+
                  ENDM
                  movea.l  buffer_addr(a6),a0
fline_trans:      andi.w   #15,d0
                  tst.b    0(a0,d0.w)
                  beq.s    fline_tr_next

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7
                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      fline_tr_points(pc,d7.w)

fline_tr_points:  REPT 16
                  move.b   d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,fline_tr_points

fline_tr_next:    addq.l   #1,a1
                  subq.w   #1,d2
                  addq.w   #1,d0
                  dbra     d6,fline_trans
                  rts

fline_eor:        andi.w   #15,d0
                  move.b   0(a0,d0.w),d5  ;Punkt gesetzt?
                  beq.s    fline_eor_next

                  move.w   d2,d4
                  lsr.w    #4,d4
                  move.w   d4,d7
                  lsr.w    #4,d4
                  not.w    d7

                  andi.w   #15,d7
                  add.w    d7,d7
                  add.w    d7,d7

                  movea.l  a1,a3

                  jmp      fline_eor_points(pc,d7.w)

fline_eor_points: REPT 16
                  eor.b    d5,(a3)
                  adda.w   d1,a3
                  ENDM
                  dbra     d4,fline_eor_points

fline_eor_next:   addq.l   #1,a1
                  subq.w   #1,d2
                  addq.w   #1,d0
                  dbra     d6,fline_eor
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'vertikale Linie'

                  ALIGN 16
                  DCB.B 6,0

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
vline:            sub.w    d1,d3          ;Zaehler

                  move.w   l_color(a6),d4
                  lea      color_map(pc),a1
                  move.b   0(a1,d4.w),d4  ;Ebenenzuordnung

;Startadresse berechnen
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  moveq    #0,d5          ;Langwort loeschen
relok5:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
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
                  lsl.w    #4,d5          ;Abstand identischer Punkte des Musters

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
                  move.b   d4,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_tr_points

vline_tr_next:    movea.l  d2,a1
                  adda.w   (sp),a1        ;naechste Zeile
                  subq.w   #1,d3
                  dbra     d0,vline_tr_loop
                  addq.l   #2,sp
                  rts

vline_eor_grow2:  adda.w   d5,a1
                  dbra     d3,vline_eor_grow
                  rts
vline_eor_grow:   add.w    d5,d5
                  lsr.w    #1,d3
vloop_eor_grow:   eor.b    d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vloop_eor_grow
                  rts

vline_eor:        moveq    #$ffffffff,d4
                  cmp.w    #$aaaa,d6
                  beq.s    vline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    vline_eor_grow2

                  move.w   d5,-(sp)
                  lsl.w    #4,d5          ;Abstand identischer Punkte des Musters

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
                  eor.b    d4,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_eor_points

vline_eor_next:   movea.l  d2,a1
                  adda.w   (sp),a1        ;naechste Zeile
                  subq.w   #1,d3
                  dbra     d0,vline_eor_loop
                  addq.l   #2,sp
                  rts

vline_replace:    cmp.w    #$ffff,d6
                  beq.s    vline_solid

                  move.w   d5,-(sp)
                  lsl.w    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_repl_loop
                  move.w   d3,d0

vline_repl_loop:  move.l   a1,-(sp)

                  add.w    d6,d6          ;Punkt gesetzt?
                  scs      d2
                  and.w    d4,d2

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
                  move.b   d2,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d1,vline_repl_points

                  movea.l  (sp)+,a1
                  adda.w   (sp),a1        ;naechste Zeile
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
                  move.b   d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  ENDM
                  dbra     d3,vline_sld_loop
vline_solid_exit: rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'schraege Linie'

                  ALIGN 16
                  DCB.B 6,0

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
                  move.w   l_color(a6),d4
                  lea      color_map(pc),a0
                  move.b   0(a0,d4.w),d4
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
                  moveq    #0,d7
line_rep_loop:    rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_white ;nicht gesetzt ?
                  move.b   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_rep_loop
                  rts
line_rep_white:   move.b   d7,(a1)+       ;weissen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop
                  rts
line_rep_ystep:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  dbra     d0,line_rep_loop ;Punktezaehler dekrementieren
line_rep_exit:    rts

line_solid:       move.b   d4,(a1)+       ;schwarzen Punkt setzen
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
                  move.b   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_tr_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_trans
                  rts
line_trans_next:  addq.l   #1,a1          ;naechster Punkt
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
                  eor.b    d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dx-2dy
                  bpl.s    line_eor_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_eor_loop
                  rts
line_eor_next:    addq.l   #1,a1          ;naechster Punkt
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
                  moveq    #0,d7
line_rep_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_w45   ;nicht gesetzt ?
                  move.b   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
line_rep_w45:     move.b   d7,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach oben oder unten
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_rep_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #1,a1          ;naechster Punkt
                  dbra     d0,line_rep_loop45
                  rts

line_solid45:     move.b   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_solid_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_solid45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_solid_x45:   add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #1,a1          ;naechster Punkt
                  dbra     d0,line_solid45
                  rts

line_rev_trans45: not.w    d6             ;Linienstil invertieren
line_trans45:     rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_tr_next45 ;nicht gesetzt ?
                  move.b   d4,(a1)        ;schwarzen Punkt setzen
line_tr_next45:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_trans_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_trans45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_trans_x45:   add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #1,a1          ;naechster Punkt
                  dbra     d0,line_trans45
                  rts

line_eor45:       moveq    #$ffffffff,d4
line_eor_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_next45 ;nicht gesetzt ?
                  eor.b    d4,(a1)        ;schwarzen Punkt setzen
line_eor_next45:  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_eor_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_eor_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_eor_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  addq.l   #1,a1          ;naechster Punkt
                  dbra     d0,line_eor_loop45
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Rechteck'

                  ALIGN 16
                  DCB.B 6,0

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
fbox:             movea.l  f_pointer(a6),a4 ;Zeiger aufs Fuellmuster
                  movea.l  v_bas_ad.w,a1  ;Bildadresse
relok7:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_universal

                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

fbox_universal:   movea.l  buffer_addr(a6),a0 ;Bufferadresse
                  sub.w    d1,d3          ;Zeilenzaehler
                  moveq    #0,d6          ;Langwort loeschen
                  move.w   d4,d6
                  muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse

                  move.w   d6,-(sp)       ;Bytes pro Zeile

                  move.w   wr_mode(a6),d7
                  subq.w   #MD_TRANS-1,d7
                  beq      fbox_trans
                  subq.w   #MD_ERASE-MD_TRANS,d7
                  beq      fbox_rev_trans

                  moveq    #$fffffffc,d4
                  and.w    d0,d4
                  adda.w   d4,a1          ;Langwortadresse

                  moveq    #$fffffffc,d5
                  and.w    d2,d5
                  sub.w    d4,d5
                  lsl.w    #4,d6          ;Bytes pro 16 Zeilen
                  sub.w    d5,d6
                  movea.l  d6,a3          ;Abstand zu 17. Zeile

                  addq.w   #MD_ERASE-MD_XOR,d7 ;EOR?
                  beq      fbox_eor

                  lea      color_map(pc),a5
                  adda.w   f_color(a6),a5 ;VDI-Farbnummer

                  movep.w  0(a5),d7
                  move.b   (a5),d7
                  move.w   d7,d6
                  swap     d7
                  move.w   d6,d7          ;Farbmaske in d7

                  move.w   f_interior(a6),d6
                  tst.w    f_color(a6)    ;weiss?
                  beq      fbox_solid
                  tst.w    d6             ;weisses Fuellmuster?
                  bne.s    fbox_opt
                  moveq    #0,d7          ;weiss als Farbe benutzen
                  bra      fbox_solid

fbox_opt:         subq.w   #F_SOLID,d6    ;volles Muster?
                  beq      fbox_solid
                  subq.w   #F_PATTERN-F_SOLID,d6
                  bne.s    fbox_buffer_addr
                  cmpi.w   #8,f_style(a6) ;volles Muster?
                  beq      fbox_solid

fbox_buffer_addr: move.l   a0,-(sp)       ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_repl_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #4,d1          ;*16
                  lea      0(a4,d1.w),a2

fbox_repl_fill1:  REPT 4
                  move.l   (a2)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_repl_fill1

fbox_repl_fill2:  REPT 4
                  move.l   (a4)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d6,fbox_repl_fill2
                  bra.s    fbox_repl_x2

fbox_repl_mono:   lea      expand_tab(pc),a6

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_fill4

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_repl_fill3:  REPT 2
                  moveq    #0,d1
                  move.b   (a2)+,d1
                  lsl.w    #3,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  move.l   (a5)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_repl_fill3

fbox_repl_fill4:  REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #3,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  move.l   (a5)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d6,fbox_repl_fill4

fbox_repl_x2:     movea.l  (sp)+,a0

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1
                  beq      fbox_repl_short   ;kombinierte Start- und Endmaske (max. 16 Pixel)
                  
                  move.w   cpu040(pc),-(sp)     ;68040?
                  beq.s    fbox_repl_cnt
                     
                  move.l   a1,d4
                  moveq    #$fffffffc,d5
                  and.w    d0,d5
                  sub.w    d5,d4
                  and.w    #15,d4               ;Adresse fuer move16 auf 16-Byte-Grenze?
                  beq.s    fbox_repl_cnt

                  clr.w    (sp)                 ;keine 68040-Routine benutzen

fbox_repl_cnt:    subq.w   #2,d2 

                  moveq    #12,d4
                  and.w    d0,d4
                  movea.l  fbox_repl_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #12,d5
                  and.w    d6,d5
                  movea.l  fbox_repl_emtab(pc,d5.w),a6 ;Endmaskenausgabe
                  bra.s    fbox_repl_mask

fbox_repl_smtab:  DC.L fbox_repl_sm0
                  DC.L fbox_repl_sm1
                  DC.L fbox_repl_sm2
                  DC.L fbox_repl_sm3

fbox_repl_emtab:  DC.L fbox_repl_em3
                  DC.L fbox_repl_em2
                  DC.L fbox_repl_em1
                  DC.L fbox_repl_em0

fbox_repl_sms:    DC.L $ffffffff
                  DC.L $ffffff
                  DC.L $ffff
                  DC.L $ff
fbox_repl_ems:    DC.L $ff000000
                  DC.L $ffff0000
                  DC.L $ffffff00
                  DC.L $ffffffff

fbox_repl_mask:   moveq    #3,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_repl_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_repl_ems(pc,d6.w),d5 ;Endmaske

                  moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_repl_vcnt
                  move.w   d3,d0
fbox_repl_vcnt:   swap     d3
                  move.w   d0,d3

fbox_repl_bloop:  swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1

                  move.l   a1,-(sp)

                  movea.l  (a0)+,a4
                  movea.l  (a0)+,a5
                  move.l   (a0)+,d6
                  move.l   (a0)+,d7

fbox_repl_line:   jmp      (a2)

fbox_repl_sm3:    or.l     d4,(a1)
                  move.l   d7,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_repl_hcount

fbox_repl_sm2:    or.l     d4,(a1)
                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_repl_sd7

fbox_repl_sm1:    or.l     d4,(a1)
                  move.l   a5,d0
                  not.l    d0

                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_repl_sd6

fbox_repl_sm0:    or.l     d4,(a1)
                  move.l   a4,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

                  move.l   a5,(a1)+
fbox_repl_sd6:    move.l   d6,(a1)+
fbox_repl_sd7:    move.l   d7,(a1)+

fbox_repl_hcount: move.w   d2,d0
                  bmi.s    fbox_repl_ejmp

                  tst.w    4(sp)             ;68040-Routine benutzen?
                  bne.s    fbox_repl_040

fbox_repl_loop:   move.l   a4,(a1)+
                  move.l   a5,(a1)+
                  move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  dbra     d0,fbox_repl_loop
                  jmp      (a6)
                  
                  MC68040

fbox_repl_040:    move.l   a3,-(sp)
                  lea      -16(a0),a3
                  tst.l    (a3)              ;Datencache fuellen - ist wichtig, da move16 nicht den Cache fuellt!
                  
fbox_repl_loop40: movea.l  a3,a0
                  move16   (a0)+,(a1)+
                  dbra     d0,fbox_repl_loop40
                  movea.l  (sp)+,a3
                  
                  MC68000
                  
fbox_repl_ejmp:   jmp      (a6)

fbox_repl_em3:    move.l   a4,d0
                  bra.s    fbox_repl_next

fbox_repl_em2:    move.l   a4,(a1)+
                  move.l   a5,d0
                  bra.s    fbox_repl_next

fbox_repl_em1:    move.l   a4,(a1)+
                  move.l   a5,(a1)+
                  move.l   d6,d0
                  bra.s    fbox_repl_next

fbox_repl_em0:    move.l   a4,(a1)+
                  move.l   a5,(a1)+
                  move.l   d6,(a1)+
                  move.l   d7,d0

fbox_repl_next:   or.l     d5,(a1)
                  not.l    d0
                  and.l    d5,d0
                  eor.l    d0,(a1)

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d1,fbox_repl_line

                  movea.l  (sp)+,a1
                  adda.w   2(sp),a1       ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_repl_bloop ;naechste Fuellmusterzeile

                  addq.l   #4,sp          ;Stackpointer korrigieren
                  rts

fbox_repl_short:  movea.w  (sp)+,a3       ;Bytes pro Zeile

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  suba.w   d6,a3          ;Zeilenbreite angleichen
                  eor.w    d1,d6
                  add.w    d6,d6
                  lea      fbox_repl_shrt2(pc,d6.w),a2

                  and.w    d1,d0
                  adda.w   d0,a0          ;Quelladresse

                  and.w    #3,d0
                  adda.w   d0,a1          ;Byteadresse

fbox_repl_shrt0:  movea.l  a0,a4
                  lea      16(a0),a0
                  dbra     d1,fbox_repl_shrt1
                  moveq    #15,d1
                  lea      -256(a0),a0

fbox_repl_shrt1:  jmp      (a2)
fbox_repl_shrt2:  REPT 15
                  move.b   (a4)+,(a1)+
                  ENDM
                  move.b   (a4)+,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_repl_shrt0
                  rts

;Gefuelltes, exklusiv verodertes Rechteck zeichnen
;Vorgaben:
;Register d0-a6 werden veraendert
;der Stackpointer wird am Ende um 2 Bytes korrigiert
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w dy
;d4.w
;d5.w
;a0.l Bufferadresse
;a1.l Langwortadresse
;a3.w Abstand von 16 Zeilen abzueglich des zu zeichnenden Linie
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
fbox_eor:         move.w   f_interior(a6),d6
                  beq      fbox_eor_exit  ;leer?
                  subq.w   #F_SOLID,d6    ;voll?
                  beq      fbox_not
                  subq.w   #F_PATTERN-F_SOLID,d6
                  bne.s    fbox_eor_buf
                  cmpi.w   #8,f_style(a6)
                  beq      fbox_not

fbox_eor_buf:     movea.l  a0,a5          ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_eor_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_eor_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #4,d1          ;*16
                  lea      0(a4,d1.w),a2

fbox_eor_fill1:   REPT 4
                  move.l   (a2)+,(a5)+
                  ENDM
                  dbra     d5,fbox_eor_fill1

fbox_eor_fill2:   REPT 4
                  move.l   (a4)+,(a5)+
                  ENDM
                  dbra     d6,fbox_eor_fill2
                  bra.s    fbox_eor_x2

fbox_eor_mono:    lea      expand_tab(pc),a6

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_eor_fill4

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_eor_fill3:   REPT 2
                  moveq    #0,d1
                  move.b   (a2)+,d1
                  lsl.w    #3,d1
                  move.l   0(a6,d1.w),(a5)+
                  move.l   4(a6,d1.w),(a5)+
                  ENDM
                  dbra     d5,fbox_eor_fill3

fbox_eor_fill4:   REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #3,d1
                  move.l   0(a6,d1.w),(a5)+
                  move.l   4(a6,d1.w),(a5)+
                  ENDM
                  dbra     d6,fbox_eor_fill4

fbox_eor_x2:      move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bmi      fbox_eor_short

                  moveq    #12,d4
                  and.w    d0,d4
                  movea.l  fbox_eor_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #12,d5
                  and.w    d6,d5
                  movea.l  fbox_eor_emtab(pc,d5.w),a6 ;Endmaskenausgabe
                  bra.s    fbox_eor_mask

fbox_eor_smtab:   DC.L fbox_eor_sm0
                  DC.L fbox_eor_sm1
                  DC.L fbox_eor_sm2
                  DC.L fbox_eor_sm3

fbox_eor_emtab:   DC.L fbox_eor_em3
                  DC.L fbox_eor_em2
                  DC.L fbox_eor_em1
                  DC.L fbox_eor_em0

fbox_eor_sms:     DC.L $ffffffff
                  DC.L $ffffff
                  DC.L $ffff
                  DC.L $ff
fbox_eor_ems:     DC.L $ff000000
                  DC.L $ffff0000
                  DC.L $ffffff00
                  DC.L $ffffffff

fbox_eor_mask:    moveq    #3,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_eor_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_eor_ems(pc,d6.w),d5 ;Endmaske

                  moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_eor_vcnt
                  move.w   d3,d0
fbox_eor_vcnt:    swap     d3
                  move.w   d0,d3

fbox_eor_bloop:   swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1

                  move.l   d3,-(sp)
                  move.l   a1,-(sp)
                  move.w   d2,-(sp)

                  move.l   (a0)+,d2
                  move.l   (a0)+,d3
                  move.l   (a0)+,d6
                  move.l   (a0)+,d7

fbox_eor_line:    jmp      (a2)

fbox_eor_sm3:     move.l   d7,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_eor_hcount

fbox_eor_sm2:     move.l   d6,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_eor_sd7

fbox_eor_sm1:     move.l   d3,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_eor_sd6

fbox_eor_sm0:     move.l   d2,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  eor.l    d3,(a1)+
fbox_eor_sd6:     eor.l    d6,(a1)+
fbox_eor_sd7:     eor.l    d7,(a1)+

fbox_eor_hcount:  move.w   (sp),d0
                  subq.w   #1,d0
                  bmi.s    fbox_eor_ejmp
fbox_eor_loop:    eor.l    d2,(a1)+
                  eor.l    d3,(a1)+
                  eor.l    d6,(a1)+
                  eor.l    d7,(a1)+
                  dbra     d0,fbox_eor_loop

fbox_eor_ejmp:    jmp      (a6)

fbox_eor_em3:     move.l   d2,d0
                  bra.s    fbox_eor_next

fbox_eor_em2:     eor.l    d2,(a1)+
                  move.l   d3,d0
                  bra.s    fbox_eor_next

fbox_eor_em1:     eor.l    d2,(a1)+
                  eor.l    d3,(a1)+
                  move.l   d6,d0
                  bra.s    fbox_eor_next

fbox_eor_em0:     eor.l    d2,(a1)+
                  eor.l    d3,(a1)+
                  eor.l    d6,(a1)+
                  move.l   d7,d0

fbox_eor_next:    and.l    d5,d0
                  eor.l    d0,(a1)
                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d1,fbox_eor_line

                  move.w   (sp)+,d2
                  movea.l  (sp)+,a1
                  move.l   (sp)+,d3
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_eor_bloop ;naechste Fuellmusterzeile
fbox_eor_exit:    addq.l   #2,sp
                  rts

fbox_eor_short:   movea.w  (sp)+,a3       ;Bytes pro Zeile

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  suba.w   d6,a3          ;Zeilenbreite angleichen
                  eor.w    d1,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  lea      fbox_eor_shrt2(pc,d6.w),a2

                  and.w    d1,d0
                  adda.w   d0,a0          ;Quelladresse

                  and.w    #3,d0
                  adda.w   d0,a1          ;Byteadresse

fbox_eor_shrt0:   movea.l  a0,a4
                  lea      16(a0),a0
                  dbra     d1,fbox_eor_shrt1
                  moveq    #15,d1
                  lea      -256(a0),a0

fbox_eor_shrt1:   jmp      (a2)
fbox_eor_shrt2:   REPT 15
                  move.b   (a4)+,d0
                  eor.b    d0,(a1)+
                  ENDM
                  move.b   (a4)+,d0
                  eor.b    d0,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_eor_shrt0
                  rts


;Invertierendes Rechteck zeichnen
;Vorgaben:
;Register d0-a6 werden veraendert
;der Stackpointer wird um 2 Bytes korrigiert
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w dy
;d4.w
;d5.w
;a0.l Bufferadresse
;a1.l Langwortadresse
;a3.w Abstand von 16 Zeilen abzueglich des zu zeichnenden Linie
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
fbox_not:         moveq    #0,d7          ;Langwort loeschen
                  move.w   (sp)+,d7
                  move.l   d7,d6
                  lsl.l    #4,d6
                  sub.l    d7,d6
                  suba.l   d6,a3          ;Abstand zur naechsten Zeile

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bmi      fbox_not_short

                  moveq    #12,d4
                  and.w    d0,d4
                  movea.l  fbox_not_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #12,d5
                  and.w    d6,d5
                  movea.l  fbox_not_emtab(pc,d5.w),a6 ;Endmaskenausgabe
                  bra.s    fbox_not_mask

fbox_not_smtab:   DC.L fbox_not_sm0
                  DC.L fbox_not_sm1
                  DC.L fbox_not_sm2
                  DC.L fbox_not_sm3

fbox_not_emtab:   DC.L fbox_not_em3
                  DC.L fbox_not_em2
                  DC.L fbox_not_em1
                  DC.L fbox_not_em0

fbox_not_sms:     DC.L $ffffffff
                  DC.L $ffffff
                  DC.L $ffff
                  DC.L $ff
fbox_not_ems:     DC.L $ff000000
                  DC.L $ffff0000
                  DC.L $ffffff00
                  DC.L $ffffffff

fbox_not_mask:    moveq    #3,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_not_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_not_ems(pc,d6.w),d5 ;Endmaske

fbox_not_line:    eor.l    d4,(a1)+
                  jmp      (a2)
fbox_not_sm0:     not.l    (a1)+
fbox_not_sm1:     not.l    (a1)+
fbox_not_sm2:     not.l    (a1)+
fbox_not_sm3:
fbox_not_hcount:  move.w   d2,d0
                  subq.w   #1,d0
                  bmi.s    fbox_not_ejmp
fbox_not_loop:    REPT 4
                  not.l    (a1)+
                  ENDM

                  dbra     d0,fbox_not_loop

fbox_not_ejmp:    jmp      (a6)

fbox_not_em0:     not.l    (a1)+
fbox_not_em1:     not.l    (a1)+
fbox_not_em2:     not.l    (a1)+
fbox_not_em3:     eor.l    d5,(a1)
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_not_line

                  rts

fbox_not_short:   movea.w  d7,a3          ;Bytes pro Zeile

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  suba.w   d6,a3          ;Zeilenbreite angleichen
                  subq.w   #1,a3
                  eor.w    d1,d6
                  add.w    d6,d6
                  lea      fbox_not_shrt1(pc,d6.w),a2

                  and.w    d1,d0
                  adda.w   d0,a0          ;Quelladresse

                  and.w    #3,d0
                  adda.w   d0,a1          ;Byteadresse

fbox_not_shrt0:   jmp      (a2)
fbox_not_shrt1:   REPT 16
                  not.b    (a1)+
                  ENDM
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_not_shrt0
                  rts

;Gefuelltes, transparentes Rechteck zeichnen
;Vorgaben:
;Register d0-a6 werden veraendert
;der Stackpointer wird am Ende um 2 Bytes korrigiert
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w dy
;d6.l Bytes pro Zeile
;a0.l Bufferadresse
;a1.l Zeilenadresse
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
fbox_trans:       adda.w   d0,a1          ;Byteadresse

                  sub.w    d0,d2          ;dx

                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  lea      color_map(pc),a5
                  adda.w   f_color(a6),a5 ;VDI-Farbnummer
                  move.b   (a5),d7        ;Pixelwert

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  bne      fbox_trans_mfill

fbox_trans_mono:  and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_trans_fill6

                  move.w   d1,d5          ;y1
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_trans_fill5: move.w   (a2)+,d1
                  rol.w    d0,d1          ;Muster rotieren
                  move.w   d1,(a5)+
                  dbra     d5,fbox_trans_fill5

fbox_trans_fill6: move.w   (a4)+,d1
                  rol.w    d0,d1          ;Muster rotieren
                  move.w   d1,(a5)+
                  dbra     d6,fbox_trans_fill6

fbox_trn_color:   moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_trn_vcnt
                  move.w   d3,d0
fbox_trn_vcnt:    swap     d3
                  move.w   d0,d3

                  movea.w  #16,a2         ;Abstand identischer Punkte des Musters

                  moveq    #15,d6         ;Punktezaehler fuers Muster

                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fbox_trn_hcount
                  move.w   d2,d6

fbox_trn_hcount:  sub.w    d6,d2
                  suba.l   d6,a3
                  subq.l   #1,a3          ;Abstand zur 17. Zeile

                  movea.w  d6,a4          ;Punktezaehler

fbox_trn_bloop:   swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1

                  movea.l  a1,a5          ;Zieladresse

fbox_trn_lines:   move.w   a4,d6          ;Punktezaehler
                  move.w   (a0),d0

fbox_trn_line:    add.w    d0,d0          ;Punkt gesetzt?
                  bcc.s    fbox_trn_next

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

                  jmp      fbox_trn_points(pc,d5.w)

fbox_trn_points:  REPT 16
                  move.b   d7,(a6)
                  adda.w   a2,a6
                  ENDM
                  dbra     d4,fbox_trn_points

fbox_trn_next:    addq.l   #1,a5
                  dbra     d6,fbox_trn_line

                  adda.l   a3,a5          ;16 Zeilen weiter
                  dbra     d1,fbox_trn_lines

                  addq.l   #2,a0          ;naechste Musterzeile
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_trn_bloop ;naechste Fuellmusterzeile
                  addq.l   #2,sp          ;Stackpointer korriegieren
                  rts

;Gefuelltes, transparentes Rechteck mit mehreren Musterebenen zeichnen
fbox_trans_mfill: and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_trn_mfill3

                  move.w   d1,d5          ;y1
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #4,d1          ;*16
                  lea      0(a4,d1.w),a2

fbox_trn_mfill1:  moveq    #15,d1
fbox_trn_mfill2:  move.b   0(a2,d0.w),(a5)+
                  addq.w   #1,d0
                  and.w    d4,d0
                  dbra     d1,fbox_trn_mfill2
                  lea      16(a2),a2
                  dbra     d5,fbox_trn_mfill1

fbox_trn_mfill3:  moveq    #15,d1
fbox_trn_mfill4:  move.b   0(a4,d0.w),(a5)+
                  addq.w   #1,d0
                  and.w    d4,d0
                  dbra     d1,fbox_trn_mfill4
                  lea      16(a4),a4
                  dbra     d6,fbox_trn_mfill3

fbox_trn_mf_dy:   moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_trn_mf_vcnt
                  move.w   d3,d0
fbox_trn_mf_vcnt: swap     d3
                  move.w   d0,d3

                  movea.w  #16,a2         ;Abstand identischer Punkte des Musters

                  moveq    #15,d6         ;Punktezaehler fuers Muster

                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fbox_trn_mf_hcnt
                  move.w   d2,d6

fbox_trn_mf_hcnt: sub.w    d6,d2
                  suba.l   d6,a3
                  subq.l   #1,a3          ;Abstand zur 17. Zeile

fbox_trn_mf_loop: swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1

                  movea.l  a1,a5          ;Zieladresse

fbox_trn_mf_lines:move.w   d6,d0          ;Punktezaehler
                  movea.l  a0,a4          ;Musterzeiger

fbox_trn_mf_line: tst.b    (a4)+          ;Punkt gesetzt?
                  beq.s    fbox_trn_mf_next

                  move.w   d7,-(sp)
                  and.b    -1(a4),d7

                  move.w   d2,d4
                  add.w    d0,d4

                  lsr.w    #4,d4
                  move.w   d4,d5
                  lsr.w    #4,d4
                  not.w    d5
                  andi.w   #15,d5
                  add.w    d5,d5
                  add.w    d5,d5

                  movea.l  a5,a6

                  jmp      fbox_trn_mf_pts(pc,d5.w)

fbox_trn_mf_pts:  REPT 16
                  move.b   d7,(a6)
                  adda.w   a2,a6
                  ENDM
                  dbra     d4,fbox_trn_mf_pts

                  move.w   (sp)+,d7

fbox_trn_mf_next: addq.l   #1,a5
                  dbra     d0,fbox_trn_mf_line

                  adda.l   a3,a5          ;16 Zeilen weiter
                  dbra     d1,fbox_trn_mf_lines

                  lea      16(a0),a0      ;naechste Musterzeile
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_trn_mf_loop ;naechste Fuellmusterzeile

                  addq.l   #2,sp          ;Stackpointer korrigieren
                  rts

;Gefuelltes, revers transparentes Rechteck zeichnen
;Vorgaben:
;Register d0-a6 werden veraendert
;der Stackpointer wird am Ende um 2 Bytes korrigiert
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w dy
;d6.l Bytes pro Zeile
;a0.l Bufferadresse
;a1.l Zeilenadresse
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
fbox_rev_trans:   adda.w   d0,a1          ;Startadresse

                  sub.w    d0,d2          ;dx

                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  lea      color_map(pc),a5
                  adda.w   f_color(a6),a5 ;VDI-Farbnummer
                  move.b   (a5),d7        ;Pixelwert

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  bne.s    fbox_rtr_mfill

fbox_rtr_mono:    and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_rtr_fill5

                  move.w   d1,d5          ;y1
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_rtr_fill5:   move.w   (a2)+,d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d5,fbox_rtr_fill5

fbox_rtr_fill6:   move.w   (a4)+,d1
                  rol.w    d0,d1
                  move.w   d1,(a5)+
                  dbra     d6,fbox_rtr_fill6

                  bra      fbox_trn_color ;zum transparenten Rechteck

;Gefuelltes, rev. transp. Rechteck mit mehreren Musterebenen zeichnen
fbox_rtr_mfill:   and.w    d4,d1          ;y1 & 15
                  beq.s    fbox_rtr_fill3

                  move.w   d1,d5          ;y1
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #4,d1          ;*16
                  lea      0(a4,d1.w),a2
fbox_rtr_fill1:   moveq    #15,d1         ;16 Byte kopieren
fbox_rtr_fill2:   move.b   0(a2,d0.w),(a5)
                  not.b    (a5)+
                  addq.w   #1,d0
                  and.w    d4,d0
                  dbra     d1,fbox_rtr_fill2
                  lea      16(a2),a2
                  dbra     d5,fbox_rtr_fill1

fbox_rtr_fill3:   moveq    #15,d1         ;16 Byte kopieren
fbox_rtr_fill4:   move.b   0(a4,d0.w),(a5)
                  not.b    (a5)+
                  addq.w   #1,d0
                  and.w    d4,d0
                  dbra     d1,fbox_rtr_fill4
                  lea      16(a4),a4
                  dbra     d6,fbox_rtr_fill3

                  bra      fbox_trn_mf_dy ;zum transparenten Rechteck fuer mehrere Musterebenen

;d0.w x1
;d2.w y1
;d3.w dy
;d7.l Farbwert
;a0.l Buffer
;a1.l Startadresse (auf Langwort-Grenze)
;a6.l Workstation
;(sp).w Bytes pro Zeile
fbox_solid:       movea.w  (sp)+,a3
                  
                  moveq    #3,d4
                  and.w    d0,d4
                  adda.w   d4,a1                ;Startadresse
                  
                  move.w   d2,d6
                  sub.w    d0,d6                ;dx
                  sub.w    d6,a3                
                  subq.w   #1,a3                ;Abstand zur naechsten Zeile
                  cmp.w    #15,d6
                  ble      fbox_sld_short
                     
                  move.l   a1,d4
                  sub.w    d0,d4
                  and.w    #15,d4               ;Adresse fuer move16 auf 16-Byte-Grenze?
                  bne      fbox_solid_030
                  move.w   cpu040(pc),d4        ;68040?
                  beq      fbox_solid_030
                  
                  moveq    #15,d4
                  moveq    #15,d5
                  and.w    d0,d4                ;x1 & 15
                  and      d2,d5                ;x2 & 15
                  add.w    d4,d6
                  lsr.w    #4,d6
                  subq.w   #2,d6                ;Zaehler fuer den Mittelteil

                  add.w    d4,d4
                  move.b   fbox_sld_smtab(pc,d4.w),d1    ;Bytezaehler fuer Startmaske
                  move.b   fbox_sld_smtab+1(pc,d4.w),d2  ;Langwortzaehler fuer Startmaske
                  ext.w    d1
                  ext.w    d2

                  add.w    d5,d5
                  move.b   fbox_sld_emtab+1(pc,d5.w),d4  ;Langwortzaehler fuer Endmaske
                  move.b   fbox_sld_emtab(pc,d5.w),d5    ;Bytezaehler fuer Endmaske
                  ext.w    d4
                  ext.w    d5

                  movea.l  a0,a2             ;Zeiger aufs Fuellmuster

                  move.l   d7,(a0)+
                  move.l   d7,(a0)+
                  move.l   d7,(a0)+
                  move.l   d7,(a0)+

                  movea.l  a2,a0

                  bra.s    fbox_sld_bloop
                  
fbox_sld_smtab:   DC.B     -1, 3
                  DC.B      2, 2
                  DC.B      1, 2
                  DC.B      0, 2
                  DC.B     -1, 2
                  DC.B      2, 1
                  DC.B      1, 1
                  DC.B      0, 1
                  DC.B     -1, 1
                  DC.B      2, 0
                  DC.B      1, 0
                  DC.B      0, 0
                  DC.B     -1, 0
                  DC.B      2,-1
                  DC.B      1,-1
                  DC.B      0,-1

fbox_sld_emtab:   DC.B      0,-1
                  DC.B      1,-1
                  DC.B      2,-1
                  DC.B     -1, 0
                  DC.B      0, 0
                  DC.B      1, 0
                  DC.B      2, 0
                  DC.B     -1, 1
                  DC.B      0, 1
                  DC.B      1, 1
                  DC.B      2, 1
                  DC.B     -1, 2
                  DC.B      0, 2
                  DC.B      1, 2
                  DC.B      2, 2
                  DC.B     -1, 3

                  MC68040

fbox_sld_bloop:   move.w   d1,d0                ;Bytezaehler fuer Startmaske
                  bmi.s    fbox_sld_sm1
fbox_sld_sb:      move.b   d7,(a1)+
                  dbra     d0,fbox_sld_sb

fbox_sld_sm1:     move.w   d2,d0                ;Langwortzaehler fuer Startmaske
                  bmi.s    fbox_sld_sm3
fbox_sld_sl:      move.l   d7,(a1)+
                  dbra     d0,fbox_sld_sl

fbox_sld_sm3:     move.w   d6,d0                ;Zaehler fuer Mittelteil
                  bmi.s    fbox_sld_ejmp

                  move.l   (a0),d7              ;Datencache fuellen - besonders wichtig!
fbox_sld_loop40:  move16   (a0)+,(a1)+
                  movea.l  a2,a0
                  dbra     d0,fbox_sld_loop40
                  
fbox_sld_ejmp:    move.w   d4,d0                ;Langwortzaehler fuer Endmaske
                  bmi.s    fbox_sld_xx1
fbox_sld_el:      move.l   d7,(a1)+
                  dbra     d0,fbox_sld_el
                  
fbox_sld_xx1:     move.w   d5,d0                ;Langwortzaehler fuer Endmaske
                  bmi.s    fbox_sld_next
fbox_sld_eb:      move.b   d7,(a1)+
                  dbra     d0,fbox_sld_eb

fbox_sld_next:    adda.w   a3,a1                ;naechste Zeile
                  dbra     d3,fbox_sld_bloop

                  rts

                  MC68000

fbox_solid_030:   moveq    #3,d4
                  moveq    #3,d5
                  and.w    d0,d4                ;x1 & 3
                  and      d2,d5                ;x2 & 3
                  add.w    d4,d6
                  lsr.w    #2,d6
                  subq.w   #2,d6                ;Zaehler fuer den Mittelteil

                  eor.w    #3,d4                ;Zaehler fuer die Startmaske

fbox_sld_bloop30: move.w   d4,d0                ;Bytezaehler fuer Startmaske
                  bmi.s    fbox_sld_m30

fbox_sld_sm30:    move.b   d7,(a1)+
                  dbra     d0,fbox_sld_sm30

fbox_sld_m30:     move.w   d6,d0                ;Zaehler fuer Mittelteil
                  bmi.s    fbox_sld_end30

fbox_sld_loop30:  move.l   d7,(a1)+
                  dbra     d0,fbox_sld_loop30
                  
fbox_sld_end30:   move.w   d5,d0                ;Bytezaehler fuer Endmaske
                  bmi.s    fbox_sld_next30

fbox_sld_em30:    move.b   d7,(a1)+
                  dbra     d0,fbox_sld_em30

fbox_sld_next30:  adda.w   a3,a1                ;naechste Zeile
                  dbra     d3,fbox_sld_bloop30

                  rts


fbox_sld_short:   eor.w    #15,d6
                  add.w    d6,d6
                  lea      fbox_sld_shrt2(pc,d6.w),a2

fbox_sld_shrt0:   jmp      (a2)
fbox_sld_shrt2:   REPT 16
                  move.b   d7,(a1)+
                  ENDM
                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_sld_shrt0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  ALIGN 16
                  DCB.B 6,0

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
textblt:          movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok8:
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zielzeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    textblt_color
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  movea.w  bitmap_width(a6),a3 ;Bytes pro Zeile
textblt_color:    clr.w    r_bgcol(a6)
                  move.w   t_color(a6),r_fgcol(a6)
                  move.w   wr_mode(a6),r_wmode(a6)
                  clr.w    r_splanes(a6)
                  move.w   r_planes(a6),r_dplanes(a6)

                  cmpi.w   #MD_ERASE-MD_REPLACE,r_wmode(a6) ;REVERS TRANSPARENT?
                  bne.s    expand_blt
                  clr.w    r_fgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_bgcol(a6) ;Textfarbe
                  bra.s    expand_blt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  ALIGN 16
                  DCB.B 6,0

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
expand_blt:       lea      color_map(pc),a4 ;Zeiger auf die Farbumwandlungstabelle
                  movea.l  a1,a5          ;Zieladresse speichern

                  move.w   a2,d6          ;Bytes pro Quellzeile
                  move.w   a3,d7          ;Bytes pro Quellzeile

                  muls     d7,d3
                  adda.l   d3,a1          ;Zielzeilenadresse

                  muls     d6,d1
                  adda.l   d1,a0          ;Quellzeilenadresse
                  move.w   d0,d1
                  lsr.w    #3,d1          ;xq div 8
                  adda.w   d1,a0          ;Quelladresse

                  moveq    #7,d1
                  and.w    d0,d1          ;Pixelueberhang der Quelle
                  sub.w    d1,d2
                  adda.w   d2,a1          ;Zieladresse

                  move.w   cpu020(pc),d3  ;Wortzugriff auf ungerade Adressen moeglich?
                  bne.s    eblt_long

                  btst     #0,d2          ;ungerade Position?
                  bne      eblto_long     ;Routine fuer 68000 & 68010

eblt_long:        tst.w    d1             ;Beginn des Quellblocks auf Byte-Position?
                  bne.s    eblt_use_masks
                  moveq    #7,d3
                  and.w    d4,d3
                  subq.w   #7,d3          ;Bereichsende auf Bytegrenze?
                  bne.s    eblt_use_masks
                  move.w   r_wmode(a6),d0
                  beq.s    eblt_byte_repl ;REPLACE
                  subq.w   #MD_XOR-MD_REPLACE,d0
                  blt.s    eblt_byte_tr   ;TRANSPARENT?
                  beq.s    eblt_byte_eor  ;XOR?
                  bra.s    eblt_use_masks ;REVERS TRANSPARENT

eblt_byte_repl:   tst.w    r_bgcol(a6)    ;weiss als Hintergrundfarbe?
                  bne.s    eblt_use_masks
eblt_byte_tr:     cmpi.w   #1,r_fgcol(a6) ;schwarz als Vordergrundfarbe?
                  bne.s    eblt_use_masks

eblt_byte_eor:    addq.w   #1,d4
                  sub.w    d4,d7          ;Abstand zur naechsten Zielzeile
                  lsr.w    #3,d4
                  sub.w    d4,d6          ;Abstand zur naechsten Quellzeile
                  subq.w   #1,d4          ;Byte-Zaehler

                  lea      expand_tab(pc),a4

                  move.w   r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   eblt_byte_tab(pc,d0.w),d0
                  jmp      eblt_byte_tab(pc,d0.w)

eblt_byte_tab:    DC.W eblt_byte-eblt_byte_tab
                  DC.W eblt_trans_byte-eblt_byte_tab
                  DC.W eblt_eor_byte-eblt_byte_tab

eblt_use_masks:   lea      eblt_smask(pc),a2 ;Zeiger auf Startmasken
                  lea      eblt_emask(pc),a3 ;Zeiger auf die Endmasken

                  moveq    #8,d3
                  sub.w    d1,d3
                  sub.w    d3,d4          ;Quellbereich weniger als 8 Pixel breit?
                  bmi      eblt_short

                  lsl.w    #3,d1
                  adda.w   d1,a2          ;Adresse der Startmaske

                  moveq    #7,d0
                  and.w    d4,d0
                  sub.w    d0,d4

                  lsl.w    #3,d0
                  adda.w   d0,a3          ;Adresse der Endmaske

                  sub.w    d4,d7          ;Abstand zur naechsten Zielzeile
                  subi.w   #16,d7
                  lsr.w    #3,d4
                  sub.w    d4,d6          ;Abstand zur naechsten Quellzeile
                  subq.w   #2,d6
                  subq.w   #1,d4          ;Byte-Zaehler

                  move.l   a4,d0
                  adda.w   r_fgcol(a6),a4
                  movep.w  0(a4),d2
                  move.b   (a4),d2
                  move.w   d2,d1
                  swap     d2
                  move.w   d1,d2          ;Maske der Vordergrundfarbe
                  movea.l  d0,a4
                  adda.w   r_bgcol(a6),a4
                  movep.w  0(a4),d3
                  move.b   (a4),d3
                  move.w   d3,d1
                  swap     d3
                  move.w   d1,d3          ;Maske der Hintergrundfarbe

                  lea      expand_tab(pc),a4

                  cmpa.l   a1,a5          ;Zieladresse kleiner?
                  bgt.s    eblt_0

                  move.w   r_wmode(a6),d0 ;Verknuepfungsmodus
                  add.w    d0,d0
                  move.w   eblt_tab(pc,d0.w),d0
                  jmp      eblt_tab(pc,d0.w)

eblt_tab:         DC.W eblt_repl_blk-eblt_tab
                  DC.W eblt_trans-eblt_tab
                  DC.W eblt_eor-eblt_tab
                  DC.W eblt_rtr-eblt_tab

eblt_0:           move.l   a5,d1
                  sub.l    a1,d1          ;Verschiebung des Quellbytes
                  move.b   (a0)+,d0
                  lsl.b    d1,d0
                  neg.w    d1
                  addq.w   #7,d1          ;Bitzaehler
                  movea.l  a5,a1          ;Zieladresse

                  movea.w  r_wmode(a6),a5 ;Verknuepfungsmodus
                  adda.w   a5,a5
                  move.w   a5,-(sp)
                  movea.w  eblt_tab0(pc,a5.w),a5
                  jsr      eblt_tab0(pc,a5.w)
                  move.w   (sp)+,d0
                  move.w   eblt_tab_cont(pc,d0.w),d0
                  jmp      eblt_tab_cont(pc,d0.w)

eblt_tab0:        DC.W eblt_repl_0-eblt_tab0
                  DC.W eblt_trans_0-eblt_tab0
                  DC.W eblt_eor_0-eblt_tab0
                  DC.W eblt_rtr_0-eblt_tab0

eblt_tab_cont:    DC.W eblt_repl_cont-eblt_tab_cont
                  DC.W eblt_trans_cont-eblt_tab_cont
                  DC.W eblt_eor_cont-eblt_tab_cont
                  DC.W eblt_rtr_cont-eblt_tab_cont

eblt_short:       move.w   d1,d0
                  lsl.w    #3,d1
                  add.w    d3,d4          ;dx
                  add.w    d4,d0
                  lsl.w    #3,d0

                  adda.w   d1,a2
                  adda.w   d0,a3
                  move.l   (a2)+,d2
                  and.l    (a3)+,d2       ;Maske 1
                  move.l   (a3),d3
                  and.l    (a2),d3        ;Maske 2

                  subq.w   #8,d7
                  movea.w  d6,a2          ;Bytes pro Quellzeile
                  movea.w  d7,a3          ;Bytes zur naechsten Zielzeile

                  move.l   d2,d6
                  move.l   d3,d7

                  move.l   a4,d0
                  adda.w   r_fgcol(a6),a4
                  movep.w  0(a4),d2
                  move.b   (a4),d2
                  move.w   d2,d1
                  swap     d2
                  move.w   d1,d2          ;Maske der Vordergrundfarbe
                  movea.l  d0,a4
                  adda.w   r_bgcol(a6),a4
                  movep.w  0(a4),d3
                  move.b   (a4),d3
                  move.w   d3,d1
                  swap     d3
                  move.w   d1,d3          ;Maske der Hintergrundfarbe

                  cmpa.l   a1,a5          ;Zieladresse kleiner?
                  ble.s    eblt_short_md

                  move.l   a1,-(sp)
                  move.l   a5,d1
                  sub.l    a1,d1          ;Verschiebung nach links
                  move.b   (a0),d0
                  lsl.b    d1,d0
                  move.w   d4,d1          ;Bitzaehler
                  movea.l  a5,a1
                  movea.w  r_wmode(a6),a5 ;Verknuepfungsmodus
                  adda.w   a5,a5
                  movea.w  eblt_tab0(pc,a5.w),a5
                  jsr      eblt_tab0(pc,a5.w)
                  movea.l  (sp)+,a1
                  addq.l   #8,a1
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  subq.w   #1,d5          ;Zeilenanzahl dekrementieren
                  bpl.s    eblt_short_md
                  rts

eblt_short_md:    move.w   d5,d1
                  move.l   d6,d4
                  move.l   d7,d5
                  not.l    d4
                  not.l    d5

                  lea      expand_tab(pc),a4

                  move.w   r_wmode(a6),d0 ;Verknuepfungsmodus
                  add.w    d0,d0
                  move.w   eblt_short_tab(pc,d0.w),d0
                  jmp      eblt_short_tab(pc,d0.w)

eblt_short_tab:   DC.W eblt_repl_short-eblt_short_tab
                  DC.W eblt_trans_short-eblt_short_tab
                  DC.W eblt_eor_short-eblt_short_tab
                  DC.W eblt_rtr_short-eblt_short_tab


eblt_byte:        move.w   d4,d1
eblt_byte_loop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_byte_white
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,(a1)+
                  move.l   (a5)+,(a1)+
                  dbra     d1,eblt_byte_loop
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_byte
                  rts

eblt_byte_white:  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  dbra     d1,eblt_byte_loop
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_byte
                  rts

eblt_trans_byte:  move.w   d4,d1
eblt_trans_byte2: moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_tr_white8
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  or.l     d0,(a1)+
                  move.l   (a5)+,d0
                  or.l     d0,(a1)+
                  dbra     d1,eblt_trans_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_trans_byte
                  rts

eblt_tr_white8:   addq.l   #8,a1
                  dbra     d1,eblt_trans_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_trans_byte
                  rts

eblt_eor_byte:    move.w   d4,d1
eblt_eor_byte2:   moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_eor_white8
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  eor.l    d0,(a1)+
                  dbra     d1,eblt_eor_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_eor_byte
                  rts
eblt_eor_white8:  addq.l   #8,a1
                  dbra     d1,eblt_eor_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_eor_byte
                  rts

eblt_repl_0:      add.b    d0,d0
                  bcc.s    eblt_repl_0bk
                  move.b   d2,(a1)+
                  dbra     d1,eblt_repl_0
                  rts
eblt_repl_0bk:    move.b   d3,(a1)+
                  dbra     d1,eblt_repl_0
                  rts

eblt_trans_0:     add.b    d0,d0
                  bcc.s    eblt_trans_0bk
                  move.b   d2,(a1)
eblt_trans_0bk:   addq.l   #1,a1
                  dbra     d1,eblt_trans_0
                  rts

eblt_eor_0:       add.b    d0,d0
                  bcc.s    eblt_eor_0bk
                  not.b    (a1)
eblt_eor_0bk:     addq.l   #1,a1
                  dbra     d1,eblt_eor_0
                  rts

eblt_rtr_0:       add.b    d0,d0
                  bcs.s    eblt_rtr_0bk
                  move.b   d3,(a1)
eblt_rtr_0bk:     addq.l   #1,a1
                  dbra     d1,eblt_rtr_0
                  rts

eblt_blk_short:   moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  and.l    d4,(a1)
                  move.l   (a5)+,d0
                  and.l    d6,d0
                  or.l     d0,(a1)+
                  and.l    d5,(a1)
                  move.l   (a5)+,d0
                  and.l    d7,d0
                  or.l     d0,(a1)+

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblt_blk_short
                  rts

eblt_repl_short:  tst.w    d3             ;Hintergrundfarbe weiss?
                  bne.s    eblt_repl_sloop
                  move.w   d2,d0
                  not.w    d0             ;Vordergrundfarbe schwarz?
                  beq.s    eblt_blk_short

eblt_repl_sloop:  move.w   d1,-(sp)
                  moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  and.l    d4,(a1)
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  and.l    d6,d0
                  or.l     d0,(a1)+
                  and.l    d5,(a1)
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  and.l    d7,d0
                  or.l     d0,(a1)+

                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   (sp)+,d1
                  dbra     d1,eblt_repl_sloop
                  rts

eblt_trans_short: not.l    d2
eblt_tr_sloop:    moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    d6,d0
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    d7,d0
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblt_tr_sloop
                  rts

eblt_eor_short:   moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblt_eor_short
                  rts

eblt_rtr_short:   not.l    d3
eblt_rtr_sloop:   moveq    #0,d0
                  move.b   (a0),d0
                  not.b    d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    d6,d0
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    d7,d0
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

                  adda.w   a2,a0

                  adda.w   a3,a1
                  dbra     d1,eblt_rtr_sloop
                  rts

eblt_repl_cont:   tst.w    d3             ;Hintergrundfarbe weiss?
                  bne      eblt_repl_sd4
                  move.w   d2,d3
                  not.w    d3             ;Vordergrundfarbe schwarz?
                  bne      eblt_repl_fcd4
                  bra.s    eblt_blk_d4

eblt_repl_blk:    tst.w    d3             ;Hintergrundfarbe weiss?
                  bne      eblt_repl
                  move.w   d2,d3
                  not.w    d3             ;Vordergrundfarbe schwarz?
                  bne      eblt_repl_fcol

eblt_blk_bloop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a2),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+
                  move.l   4(a2),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+

eblt_blk_d4:      move.w   d4,d1
                  bmi.s    exp_black_eme
eblt_blk_loop:    moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_repl_bwht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,(a1)+
                  move.l   (a5)+,(a1)+
                  dbra     d1,eblt_blk_loop
                  bra.s    exp_black_eme

eblt_repl_bwht:   move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  dbra     d1,eblt_blk_loop


exp_black_eme:    moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5


                  move.l   (a3),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  not.l    d0

                  eor.l    d0,d1
                  move.l   d1,(a1)+
                  move.l   4(a3),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_blk_bloop
                  rts

eblt_repl_fcol:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a2),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  and.l    d2,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+
                  move.l   4(a2),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  and.l    d2,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+

eblt_repl_fcd4:   move.w   d4,d1
                  bmi.s    eblt_repl_fmask
eblt_repl_fcol2:  moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_repl_fwht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  and.l    d2,d0
                  move.l   d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    d2,d0
                  move.l   d0,(a1)+
                  dbra     d1,eblt_repl_fcol2
                  bra.s    eblt_repl_fmask

eblt_repl_fwht:   move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  dbra     d1,eblt_repl_fcol2

eblt_repl_fmask:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a3),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  and.l    d2,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+
                  move.l   4(a3),d0
                  move.l   (a1),d1
                  not.l    d1
                  or.l     d0,d1
                  and.l    (a5)+,d0
                  and.l    d2,d0
                  not.l    d0
                  eor.l    d0,d1
                  move.l   d1,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_repl_fcol
                  rts

eblt_repl:        moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a2),d0
                  not.l    d0
                  and.l    d0,(a1)
                  move.l   (a5)+,d1
                  not.l    d0
                  and.l    d1,d0
                  and.l    d2,d0
                  not.l    d1
                  and.l    (a2),d1
                  and.l    d3,d1
                  or.l     d1,d0
                  or.l     d0,(a1)+
                  move.l   4(a2),d0
                  not.l    d0
                  and.l    d0,(a1)
                  move.l   (a5)+,d1
                  not.l    d0
                  and.l    d1,d0
                  and.l    d2,d0
                  not.l    d1
                  and.l    4(a2),d1
                  and.l    d3,d1
                  or.l     d1,d0
                  or.l     d0,(a1)+

eblt_repl_sd4:    move.w   d4,-(sp)
                  bmi.s    eblt_repl_emask
eblt_repl_loop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  move.l   d0,(a1)+
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblt_repl_loop

eblt_repl_emask:  move.w   (sp)+,d4
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a3),d0
                  not.l    d0
                  and.l    d0,(a1)
                  move.l   (a5)+,d1
                  not.l    d0
                  and.l    d1,d0
                  and.l    d2,d0
                  not.l    d1
                  and.l    (a3),d1
                  and.l    d3,d1
                  or.l     d1,d0
                  or.l     d0,(a1)+
                  move.l   4(a3),d0
                  not.l    d0
                  and.l    d0,(a1)
                  move.l   (a5)+,d1
                  not.l    d0
                  and.l    d1,d0
                  and.l    d2,d0
                  not.l    d1
                  and.l    4(a3),d1
                  and.l    d3,d1
                  or.l     d1,d0
                  or.l     d0,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_repl
                  rts


eblt_trans_blk:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  or.l     d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  or.l     d0,(a1)+

eblt_trans_blkd4: move.w   d4,d1
                  bmi.s    eblt_tb_emask
eblt_trans_blk8:  moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_trans_bnxt
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  or.l     d0,(a1)+
                  move.l   (a5)+,d0

                  or.l     d0,(a1)+

                  dbra     d1,eblt_trans_blk8
                  bra.s    eblt_tb_emask

eblt_trans_bnxt:  addq.l   #8,a1
                  dbra     d1,eblt_trans_blk8

eblt_tb_emask:    moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  or.l     d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  or.l     d0,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_trans_blk
                  rts

eblt_trans_cont:  not.l    d2             ;Vordergrundfarbe negieren
                  beq.s    eblt_trans_blkd4 ;schwarz?
                  bra.s    eblt_trans_d4

eblt_trans:       not.l    d2             ;Vordergrundfarbe negieren
                  beq.s    eblt_trans_blk ;schwarz?
eblt_trans_bloop: moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a2),d0        ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a2),d0       ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

eblt_trans_d4:    move.w   d4,d1
                  bmi.s    eblt_t_emask
eblt_trans8:      moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_trans_nxt
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  or.l     d0,(a1)
                  and.l    d2,d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  or.l     d0,(a1)
                  and.l    d2,d0
                  eor.l    d0,(a1)+
                  dbra     d1,eblt_trans8
                  bra.s    eblt_t_emask

eblt_trans_nxt:   addq.l   #8,a1
                  dbra     d1,eblt_trans8



eblt_t_emask:     moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a3),d0        ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a3),d0       ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d2,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_trans_bloop
                  rts

eblt_eor:         moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  eor.l    d0,(a1)+

eblt_eor_cont:    move.w   d4,d1
                  bmi.s    eblt_eor_emask
eblt_eor8:        moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblt_eor_nxt
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  eor.l    d0,(a1)+
                  dbra     d1,eblt_eor8
                  bra.s    eblt_eor_emask

eblt_eor_nxt:     addq.l   #8,a1
                  dbra     d1,eblt_eor8

eblt_eor_emask:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  eor.l    d0,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_eor
                  rts

eblt_rtr_cont:    not.l    d3             ;Vordergrundfarbe negieren
                  bra.s    eblt_rtrd4

eblt_rtr:         not.l    d3             ;Vordergrundfarbe negieren
eblt_rtr_bloop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a2),d0        ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

                  move.l   (a5)+,d0
                  and.l    4(a2),d0       ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+


eblt_rtrd4:       move.w   d4,d1
                  bmi.s    eblt_rtr_emask
eblt_rtr8:        moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0
                  beq.s    eblt_rtr_nxt
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  or.l     d0,(a1)
                  and.l    d3,d0
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  or.l     d0,(a1)
                  and.l    d3,d0
                  eor.l    d0,(a1)+
                  dbra     d1,eblt_rtr8
                  bra.s    eblt_rtr_emask

eblt_rtr_nxt:     addq.l   #8,a1
                  dbra     d1,eblt_rtr8


eblt_rtr_emask:   moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  and.l    (a3),d0        ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+
                  move.l   (a5)+,d0
                  and.l    4(a3),d0       ;ausmaskieren
                  or.l     d0,(a1)
                  and.l    d3,d0          ;Verknuepfung mit der negierten Vordergrundfarbe
                  eor.l    d0,(a1)+

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblt_rtr_bloop
                  rts




eblt_smask:       DC.L $ffffffff,$ffffffff
                  DC.L $ffffff,$ffffffff
                  DC.L $ffff,$ffffffff
                  DC.L $ff,$ffffffff
                  DC.L $00,$ffffffff
                  DC.L $00,$ffffff
                  DC.L $00,$ffff
                  DC.L $00,$ff

eblt_emask:       DC.L $ff000000,$00
                  DC.L $ffff0000,$00
                  DC.L $ffffff00,$00
                  DC.L $ffffffff,$00
                  DC.L $ffffffff,$ff000000
                  DC.L $ffffffff,$ffff0000
                  DC.L $ffffffff,$ffffff00
                  DC.L $ffffffff,$ffffffff



eblto_smask:      DC.L $ffffffff,$ffffffff
                  DC.L $ffffff,$ffffffff
                  DC.L $ffffff,$ffffff
                  DC.L $ffff,$ffffff
                  DC.L $ffff,$ffff
                  DC.L $ff,$ffff
                  DC.L $ff,$ff
                  DC.L $00,$ff

eblto_emask:      DC.L $ff000000,$00
                  DC.L $ff000000,$ff000000
                  DC.L $ffff0000,$ff000000
                  DC.L $ffff0000,$ffff0000
                  DC.L $ffffff00,$ffff0000
                  DC.L $ffffff00,$ffffff00
                  DC.L $ffffffff,$ffffff00
                  DC.L $ffffffff,$ffffffff

eblto_long:       tst.w    d1             ;Beginn des Quellblocks auf Byte-Position?
                  bne.s    eblto_use_masks
                  moveq    #7,d3
                  and.w    d4,d3
                  subq.w   #7,d3          ;Bereichsende auf Bytegrenze?
                  bne.s    eblto_use_masks

                  move.w   r_wmode(a6),d0
                  beq.s    eblto_byte_repl ;REPLACE
                  subq.w   #MD_XOR-MD_REPLACE,d0
                  blt.s    eblto_byte_tr  ;TRANSPARENT?
                  beq.s    eblto_byte_eor ;XOR?
                  bra.s    eblto_use_masks ;REVERS TRANSPARENT

eblto_byte_repl:  tst.w    r_bgcol(a6)    ;weiss als Hintergrundfarbe?
                  bne.s    eblto_use_masks
eblto_byte_tr:    cmpi.w   #1,r_fgcol(a6) ;schwarz als Vordergrundfarbe?
                  bne.s    eblto_use_masks

eblto_byte_eor:   addq.w   #1,d4
                  sub.w    d4,d7          ;Abstand zur naechsten Zielzeile
                  lsr.w    #3,d4

                  sub.w    d4,d6          ;Abstand zur naechsten Quellzeile
                  subq.w   #1,d4          ;Byte-Zaehler

                  lea      expand_tabo(pc),a4

                  move.w   r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   eblto_byte_tab(pc,d0.w),d0
                  jmp      eblto_byte_tab(pc,d0.w)

eblto_byte_tab:   DC.W eblto_byte-eblto_byte_tab
                  DC.W eblto_trans_byte-eblto_byte_tab
                  DC.W eblto_eor_byte-eblto_byte_tab

eblto_use_masks:  lea      eblto_smask(pc),a2 ;Zeiger auf Startmasken
                  lea      eblto_emask(pc),a3 ;Zeiger auf die Endmasken

                  moveq    #8,d3
                  sub.w    d1,d3
                  sub.w    d3,d4          ;Quellbereich weniger als 8 Pixel breit?
                  bmi      eblto_short

                  lsl.w    #3,d1
                  adda.w   d1,a2

                  moveq    #7,d0
                  and.w    d4,d0
                  sub.w    d0,d4

                  lsl.w    #3,d0
                  adda.w   d0,a3

                  sub.w    d4,d7          ;Abstand zur naechsten Zielzeile
                  subq.w   #8,d7
                  lsr.w    #3,d4
                  sub.w    d4,d6          ;Abstand zur naechsten Quellzeile
                  subq.w   #2,d6
                  subq.w   #1,d4          ;Byte-Zaehler

                  move.l   a4,d0
                  adda.w   r_fgcol(a6),a4
                  movep.w  0(a4),d2
                  move.b   (a4),d2
                  move.w   d2,d1
                  swap     d2
                  move.w   d1,d2          ;Maske der Vordergrundfarbe
                  movea.l  d0,a4
                  adda.w   r_bgcol(a6),a4
                  movep.w  0(a4),d3
                  move.b   (a4),d3
                  move.w   d3,d1
                  swap     d3
                  move.w   d1,d3          ;Maske der Hintergrundfarbe

                  lea      expand_tabo(pc),a4

                  cmpa.l   a1,a5          ;Zieladresse kleiner?
                  bgt.s    eblto_0

                  move.w   r_wmode(a6),d0 ;Verknuepfungsmodus
                  add.w    d0,d0
                  move.w   eblto_tab(pc,d0.w),d0
                  jmp      eblto_tab(pc,d0.w)

eblto_tab:        DC.W eblto_repl_blk-eblto_tab
                  DC.W eblto_trans-eblto_tab
                  DC.W eblto_eor-eblto_tab
                  DC.W eblto_rtr-eblto_tab

eblto_0:          move.l   a5,d1
                  sub.l    a1,d1          ;Verschiebung des Quellbytes
                  move.b   (a0)+,d0
                  lsl.b    d1,d0
                  neg.w    d1
                  addq.w   #7,d1          ;Bitzaehler
                  movea.l  a5,a1          ;Zieladresse

                  movea.w  r_wmode(a6),a5 ;Verknuepfungsmodus
                  adda.w   a5,a5
                  move.w   a5,-(sp)
                  movea.w  eblto_tab0(pc,a5.w),a5
                  jsr      eblto_tab0(pc,a5.w)
                  move.w   (sp)+,d0
                  move.w   eblto_tab_cont(pc,d0.w),d0
                  jmp      eblto_tab_cont(pc,d0.w)

eblto_tab0:       DC.W eblt_repl_0-eblto_tab0
                  DC.W eblt_trans_0-eblto_tab0
                  DC.W eblt_eor_0-eblto_tab0
                  DC.W eblt_rtr_0-eblto_tab0

eblto_tab_cont:   DC.W eblto_repl_cont-eblto_tab_cont
                  DC.W eblto_trans_cont-eblto_tab_cont
                  DC.W eblto_eor_cont-eblto_tab_cont
                  DC.W eblt_rtr_cont-eblto_tab_cont


eblto_short:      move.w   d1,d0
                  lsl.w    #3,d1
                  add.w    d3,d4          ;dx
                  add.w    d4,d0
                  lsl.w    #3,d0

                  adda.w   d1,a2
                  adda.w   d0,a3
                  move.l   (a2)+,d2
                  and.l    (a3)+,d2       ;Maske 1
                  move.l   (a3),d3
                  and.l    (a2),d3        ;Maske 2

                  movea.w  d6,a2          ;Bytes pro Quellzeile
                  movea.w  d7,a3          ;Bytes pro Zielzeile

                  move.l   d2,d6
                  move.l   d3,d7

                  move.l   a4,d0
                  adda.w   r_fgcol(a6),a4
                  movep.w  0(a4),d2
                  move.b   (a4),d2
                  move.w   d2,d1
                  swap     d2
                  move.w   d1,d2          ;Maske der Vordergrundfarbe
                  movea.l  d0,a4
                  adda.w   r_bgcol(a6),a4
                  movep.w  0(a4),d3
                  move.b   (a4),d3
                  move.w   d3,d1
                  swap     d3
                  move.w   d1,d3          ;Maske der Hintergrundfarbe

                  cmpa.l   a1,a5          ;Zieladresse kleiner?
                  ble.s    eblto_short_md

                  move.l   a1,-(sp)
                  move.l   a5,d1
                  sub.l    a1,d1          ;Verschiebung nach links
                  move.b   (a0),d0
                  lsl.b    d1,d0
                  move.w   d4,d1          ;Bitzaehler
                  movea.l  a5,a1
                  movea.w  r_wmode(a6),a5 ;Verknuepfungsmodus
                  adda.w   a5,a5
                  movea.w  eblto_tab0(pc,a5.w),a5
                  jsr      eblto_tab0(pc,a5.w)
                  movea.l  (sp)+,a1
                  addq.l   #8,a1
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  subq.w   #1,d5          ;Zeilenanzahl dekrementieren
                  bpl.s    eblto_short_md
                  rts

eblto_short_md:   move.w   d5,d1
                  move.l   d6,d4
                  move.l   d7,d5
                  not.l    d4
                  not.l    d5

                  lea      expand_tabo(pc),a4

                  move.w   r_wmode(a6),d0 ;Verknuepfungsmodus
                  add.w    d0,d0
                  move.w   eblto_short_tab(pc,d0.w),d0
                  jmp      eblto_short_tab(pc,d0.w)

eblto_short_tab:  DC.W eblto_repl_short-eblto_short_tab
                  DC.W eblto_trans_short-eblto_short_tab
                  DC.W eblto_eor_short-eblto_short_tab
                  DC.W eblto_rtr_short-eblto_short_tab

eblto_byte:       move.w   d4,d1
eblto_byte_loop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_byte_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  movep.l  d0,0(a1)
                  move.l   (a5)+,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_byte_loop
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_byte
                  rts
eblto_byte_wht:   movep.l  d0,0(a1)
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_byte_loop
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_byte
                  rts

eblto_trans_byte: move.w   d4,d1
eblto_trans_byte2:moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_tr_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  movep.l  0(a1),d0
                  or.l     (a5)+,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  or.l     (a5)+,d0
                  movep.l  d0,1(a1)
eblto_tr_wht:     addq.l   #8,a1
                  dbra     d1,eblto_trans_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_trans_byte
                  rts

eblto_eor_byte:   move.w   d4,d1
eblto_eor_byte2:  moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_eor_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  movep.l  0(a1),d0
                  move.l   (a5)+,d2
                  eor.l    d2,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d2
                  eor.l    d2,d0
                  movep.l  d0,1(a1)
eblto_eor_wht:    addq.l   #8,a1
                  dbra     d1,eblto_eor_byte2
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_eor_byte
                  rts

eblto_blk_short:  moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  and.l    d4,d0
                  move.l   (a5)+,d2
                  and.l    d6,d2
                  or.l     d2,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  and.l    d5,d0
                  move.l   (a5)+,d2
                  and.l    d7,d2
                  or.l     d2,d0
                  movep.l  d0,1(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblto_blk_short

                  rts

eblto_repl_short: tst.w    d3             ;Hintergrundfarbe weiss?
                  bne.s    eblto_repl_sloop
                  move.w   d2,d0
                  not.w    d0             ;Vordergrundfarbe schwarz?
                  beq.s    eblto_blk_short

eblto_repl_sloop: moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  or.l     d6,d0
                  eor.l    d6,d0
                  move.l   (a5)+,d4
                  and.l    d6,d4

                  move.l   d4,d5
                  eor.l    d6,d5
                  and.l    d2,d4
                  and.l    d3,d5
                  or.l     d5,d4
                  or.l     d4,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  or.l     d7,d0
                  eor.l    d7,d0
                  move.l   (a5)+,d4
                  and.l    d7,d4
                  move.l   d4,d5
                  eor.l    d7,d5
                  and.l    d2,d4
                  and.l    d3,d5
                  or.l     d5,d4
                  or.l     d4,d0
                  movep.l  d0,1(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblto_repl_sloop
                  rts

eblto_trans_short:not.l    d2
eblto_tr_sloop:   moveq    #0,d0
                  move.b   (a0),d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a5)+,d4
                  and.l    d6,d4
                  or.l     d4,d0
                  and.l    d2,d4
                  eor.l    d4,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d4
                  and.l    d7,d4
                  or.l     d4,d0
                  and.l    d2,d4
                  eor.l    d4,d0
                  movep.l  d0,1(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblto_tr_sloop
                  rts

eblto_eor_short:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a5)+,d4
                  and.l    d6,d4
                  eor.l    d4,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d4
                  and.l    d7,d4
                  eor.l    d4,d0
                  movep.l  d0,1(a1)


                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d1,eblto_eor_short
                  rts

eblto_rtr_short:  not.l    d3
eblto_rtr_sloop:  moveq    #0,d0
                  move.b   (a0),d0
                  not.b    d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a5)+,d4
                  and.l    d6,d4
                  or.l     d4,d0
                  and.l    d3,d4
                  eor.l    d4,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d4
                  and.l    d7,d4
                  or.l     d4,d0
                  and.l    d3,d4
                  eor.l    d4,d0
                  movep.l  d0,1(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1

                  dbra     d1,eblto_rtr_sloop
                  rts


eblto_repl_cont:  tst.w    d3             ;Hintergrundfarbe weiss?
                  bne      eblto_repl_d4
                  move.w   d2,d3
                  not.w    d3             ;Vordergrundfarbe schwarz?
                  bne      eblto_repl_fcd4
                  bra.s    eblto_blk_d4

eblto_repl_blk:   tst.w    d3             ;Hintergrundfarbe weiss?
                  bne      eblto_repl
                  move.w   d2,d3
                  not.w    d3             ;Vordergrundfarbe schwarz?
                  bne      eblto_repl_fcol

eblto_blk_bloop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  or.l     d1,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   4(a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  or.l     d1,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1

eblto_blk_d4:     move.w   d4,d1
                  bmi.s    eblto_blk_eme
eblto_blk_loop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_blk_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  move.l   (a5)+,d0
                  movep.l  d0,0(a1)
                  move.l   (a5)+,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_blk_loop
                  bra.s    eblto_blk_eme

eblto_blk_wht:    movep.l  d0,0(a1)
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_blk_loop

eblto_blk_eme:    moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a3),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  or.l     d1,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   4(a3),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  or.l     d1,d0
                  movep.l  d0,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_blk_bloop
                  rts

eblto_repl_fcol:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  and.l    d2,d1
                  or.l     d1,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   4(a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  and.l    d2,d1
                  or.l     d1,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1

eblto_repl_fcd4:  move.w   d4,d1
                  bmi.s    eblto_repl_fmask
eblto_repl_fcol2: moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_repl_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  and.l    d2,d0
                  movep.l  d0,0(a1)
                  move.l   (a5)+,d0
                  and.l    d2,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_repl_fcol2
                  bra.s    eblto_repl_fmask

eblto_repl_wht:   movep.l  d0,0(a1)
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d1,eblto_repl_fcol2

eblto_repl_fmask: moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a3),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  and.l    d2,d1
                  or.l     d1,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   4(a3),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  and.l    (a5)+,d1
                  and.l    d2,d1
                  or.l     d1,d0
                  movep.l  d0,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_repl_fcol
                  rts

eblto_repl:       move.w   d6,-(sp)
                  move.w   d7,-(sp)

                  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  move.l   (a5)+,d6
                  and.l    d1,d6
                  move.l   d6,d7
                  eor.l    d1,d7
                  and.l    d2,d6
                  and.l    d3,d7
                  or.l     d7,d6
                  or.l     d6,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   4(a2),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  move.l   (a5)+,d6
                  and.l    d1,d6
                  move.l   d6,d7
                  eor.l    d1,d7
                  and.l    d2,d6
                  and.l    d3,d7
                  or.l     d7,d6
                  or.l     d6,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1

eblto_repl_d4:    move.w   d4,-(sp)
                  bmi.s    eblto_repl_emask
eblto_repl_loop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  movep.l  d0,0(a1)
                  move.l   (a5)+,d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d2,d0
                  and.l    d3,d1
                  or.l     d1,d0
                  movep.l  d0,1(a1)
                  addq.l   #8,a1
                  dbra     d4,eblto_repl_loop

eblto_repl_emask: move.w   (sp)+,d4
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a3),d1
                  or.l     d1,d0
                  eor.l    d1,d0
                  move.l   (a5)+,d6
                  and.l    d1,d6
                  move.l   d6,d7
                  eor.l    d1,d7
                  and.l    d2,d6
                  and.l    d3,d7
                  or.l     d7,d6
                  or.l     d6,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  or.l     d1,d0
                  eor.l    d1,d0
                  move.l   (a5)+,d6
                  and.l    d1,d6
                  move.l   d6,d7
                  eor.l    d1,d7

                  and.l    d2,d6
                  and.l    d3,d7
                  or.l     d7,d6
                  or.l     d6,d0
                  movep.l  d0,1(a1)

                  move.w   (sp)+,d7
                  move.w   (sp)+,d6
                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_repl
                  rts


eblto_trans_blk:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  or.l     d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  or.l     d0,d1
                  movep.l  d1,1(a1)
                  addq.l   #8,a1

eblto_trans_blkd4:move.w   d4,d1
                  bmi.s    eblto_tb_emask
eblto_trans_blk8: moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_tb_wht
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  or.l     (a5)+,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  or.l     (a5)+,d0
                  movep.l  d0,1(a1)
eblto_tb_wht:     addq.l   #8,a1

                  dbra     d1,eblto_trans_blk8

eblto_tb_emask:   moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  or.l     d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  or.l     d0,d1
                  movep.l  d1,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_trans_blk
                  rts


eblto_trans_cont: not.l    d2             ;Vordergrundfarbe negieren
                  beq.s    eblto_trans_blkd4 ;schwarz?
                  bra.s    eblto_trans_d4

eblto_trans:      not.l    d2             ;Vordergrundfarbe negieren
                  beq      eblto_trans_blk ;schwarz?

eblto_trans_bloop:moveq    #0,d0
                  move.b   (a0)+,d0

                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  or.l     d0,d1
                  and.l    d2,d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  or.l     d0,d1
                  and.l    d2,d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)
                  addq.l   #8,a1

eblto_trans_d4:   move.w   d4,d1
                  bmi.s    eblto_t_emask
eblto_trans8:     moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_tr_wht8
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5


                  movep.l  0(a1),d0
                  move.l   (a5)+,d3
                  or.l     d3,d0
                  and.l    d2,d3
                  eor.l    d3,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d3
                  or.l     d3,d0
                  and.l    d2,d3
                  eor.l    d3,d0
                  movep.l  d0,1(a1)
eblto_tr_wht8:    addq.l   #8,a1
                  dbra     d1,eblto_trans8

eblto_t_emask:    moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  or.l     d0,d1
                  and.l    d2,d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  or.l     d0,d1
                  and.l    d2,d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_trans_bloop
                  rts

eblto_eor:        moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)
                  addq.l   #8,a1

eblto_eor_cont:   move.w   d4,d1
                  bmi.s    eblto_eor_emask
eblto_eor8:       moveq    #0,d0
                  move.b   (a0)+,d0
                  beq.s    eblto_eor_wht8
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5
                  movep.l  0(a1),d0
                  move.l   (a5)+,d2
                  eor.l    d2,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d2
                  eor.l    d2,d0
                  movep.l  d0,1(a1)
eblto_eor_wht8:   addq.l   #8,a1
                  dbra     d1,eblto_eor8

eblto_eor_emask:  moveq    #0,d0
                  move.b   (a0)+,d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_eor
                  rts


eblto_rtr_cont:   not.l    d3             ;Vordergrundfarbe negieren
                  bra.s    eblto_rtrd4

eblto_rtr:        not.l    d3
eblto_rtr_bloop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a2),d0
                  or.l     d0,d1
                  and.l    d3,d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a2),d0
                  or.l     d0,d1
                  and.l    d3,d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)
                  addq.l   #8,a1

eblto_rtrd4:      move.w   d4,d1
                  bmi.s    eblto_rtr_emask
eblto_rtr8:       moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0
                  beq.s    eblto_rtr_wht8
                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d0
                  move.l   (a5)+,d2
                  or.l     d2,d0
                  and.l    d3,d2

                  eor.l    d2,d0
                  movep.l  d0,0(a1)
                  movep.l  1(a1),d0
                  move.l   (a5)+,d2
                  or.l     d2,d0
                  and.l    d3,d2
                  eor.l    d2,d0
                  movep.l  d0,1(a1)
eblto_rtr_wht8:   addq.l   #8,a1
                  dbra     d1,eblto_rtr8

eblto_rtr_emask:  moveq    #0,d0
                  move.b   (a0)+,d0
                  not.b    d0

                  lsl.w    #3,d0
                  movea.l  a4,a5
                  adda.w   d0,a5

                  movep.l  0(a1),d1
                  move.l   (a5)+,d0
                  and.l    (a3),d0
                  or.l     d0,d1
                  and.l    d3,d0
                  eor.l    d0,d1
                  movep.l  d1,0(a1)
                  movep.l  1(a1),d1
                  move.l   (a5)+,d0
                  and.l    4(a3),d0
                  or.l     d0,d1
                  and.l    d3,d0
                  eor.l    d0,d1
                  movep.l  d1,1(a1)

                  adda.w   d6,a0
                  adda.w   d7,a1
                  dbra     d5,eblto_rtr_bloop
                  rts


                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Bitblocktransfer'

                  ALIGN 16
                  DCB.B 6,0

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

bitblt_in:        ext.l    d0
                  ext.l    d2

                  move.w   a2,d6
                  mulu     d6,d1
                  add.l    d0,d1
                  adda.l   d1,a0          ;Quelladresse

                  move.w   a3,d6
                  mulu     d6,d3
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
                  adda.w   d4,a4          ;Quellendadresse
                  cmpa.l   a1,a4          ;Quellendadresse < Zieladresse?
                  bcs      bitblt_inc

                  addq.l   #1,a4          ;Quellendadresse + 1
                  add.l    a4,d1
                  sub.l    a0,d1

                  movea.l  a1,a5
                  move.w   a3,d6
                  mulu     d5,d6
                  adda.l   d6,a5
                  adda.w   d4,a5
                  addq.l   #1,a5          ;Zielendadresse + 1
                  add.l    a5,d3
                  sub.l    a1,d3

                  exg      a0,a4
                  exg      a1,a5

bitblt_dec:       cmp.w    #15,d4         ;zu kurz?
                  ble      blt_dec_byte2

                  move.w   d4,d6
                  addq.w   #1,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

                  move.w   cpu020(pc),d1  ;Wortzugriff auf ungerade Adresse moeglich?
                  bne.s    blt_dec_long

                  moveq    #1,d1
                  moveq    #1,d3
                  and.w    d0,d1
                  and.w    d2,d3
                  cmp.w    d1,d3          ;gleiche Grenze?
                  bne      blt_dec_byte

blt_dec_long:     moveq    #3,d6

                  move.w   d4,d2
                  add.w    d0,d2

                  subq.w   #1,d0
                  and.w    d6,d0
                  moveq    #3,d1
                  eor.w    d0,d1
                  sub.w    d1,d4
                  add.w    d0,d0          ;Offset fuer den Startsprung

                  addq.w   #1,d2
                  and.w    d6,d2
                  sub.w    d2,d4
                  eor.w    d6,d2
                  add.w    d2,d2          ;Offset fuer den Endsprung

                  addq.w   #1,d4
                  lsr.w    #2,d4          ;Anzahl der Langworte
                  subq.w   #1,d4
                  move.w   d4,d1
                  not.w    d1
                  and.w    d6,d1
                  add.w    d1,d1          ;Offset fuer den mittleren Sprung
                  lsr.w    #2,d4

                  add.w    d7,d7
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
                  move.w   d2,d7
                  add.w    d2,d2
                  add.w    d7,d2
                  bra.s    bltld_jmp

bltld_m4:         add.w    d0,d0
                  add.w    d1,d1
                  add.w    d2,d2

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

blt_dec_byte2:    move.w   d4,d6
                  addq.w   #1,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

blt_dec_byte:     move.w   d4,d0
                  lsr.w    #5,d4          ;Schleifenzaehler
                  not.w    d0
                  andi.w   #31,d0
                  add.w    d0,d0          ;Sprungoffset

                  add.w    d7,d7
                  add.w    d7,d7
                  lea      bltbd_tab(pc,d7.w),a4
                  move.w   (a4)+,d7
                  beq.s    bltbd_jmp
                  subq.w   #m4,d7
                  beq.s    bltbd_m4

                  move.w   d0,d7
                  add.w    d0,d0
                  add.w    d7,d0
                  bra.s    bltbd_jmp

bltbd_m4:         add.w    d0,d0
bltbd_jmp:        move.w   (a4)+,d7
                  jmp      bltbd_tab(pc,d7.w)

bltbd_tab:        DC.W m2,blt0bi-bltbd_tab
                  DC.W m4,blt1bd-bltbd_tab
                  DC.W m6,blt2bd-bltbd_tab
                  DC.W m2,blt3bd-bltbd_tab
                  DC.W m6,blt4bd-bltbd_tab
                  DC.W m2,blt5-bltbd_tab
                  DC.W m4,blt6bd-bltbd_tab
                  DC.W m4,blt7bd-bltbd_tab
                  DC.W m6,blt8bd-bltbd_tab
                  DC.W m6,blt9bd-bltbd_tab
                  DC.W m2,blt10bi-bltbd_tab
                  DC.W m6,blt11bd-bltbd_tab
                  DC.W m6,blt12bd-bltbd_tab
                  DC.W m6,blt13bd-bltbd_tab
                  DC.W m6,blt14bd-bltbd_tab
                  DC.W m2,blt15bi-bltbd_tab

blt1ld:           lea      blt1ld_jmp1(pc,d2.w),a4
                  lea      blt1ld_loop(pc,d1.w),a5
                  lea      blt1ld_jmp3(pc,d0.w),a6
blt1ld_bloop:     jmp      (a4)
blt1ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  and.b    d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt1ld_loop:      REPT 4
                  move.l   -(a0),d0
                  and.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt1ld_loop
                  jmp      (a6)
blt1ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  and.b    d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1ld_bloop
                  rts

blt2ld:           lea      blt2ld_jmp1(pc,d2.w),a4
                  lea      blt2ld_loop(pc,d1.w),a5
                  lea      blt2ld_jmp3(pc,d0.w),a6
blt2ld_bloop:     jmp      (a4)
blt2ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  not.b    (a1)
                  and.b    d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt2ld_loop:      REPT 4
                  move.l   -(a0),d0
                  not.l    (a1)
                  and.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt2ld_loop
                  jmp      (a6)
blt2ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  not.b    (a1)
                  and.b    d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2ld_bloop
                  rts

blt3ld:           lea      blt3ld_jmp1(pc,d2.w),a4
                  lea      blt3ld_loop(pc,d1.w),a5
                  lea      blt3ld_jmp3(pc,d0.w),a6

blt3ld_bloop:     jmp      (a4)
blt3ld_jmp1:      REPT 3
                  move.b   -(a0),-(a1)
                  ENDM

                  move.w   d4,d6
                  jmp      (a5)
blt3ld_loop:      REPT 4
                  move.l   -(a0),-(a1)
                  ENDM
                  dbra     d6,blt3ld_loop
                  
                  jmp      (a6)
blt3ld_jmp3:      REPT 3
                  move.b   -(a0),-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3ld_bloop
                  rts

blt4ld:           lea      blt4ld_jmp1(pc,d2.w),a4
                  lea      blt4ld_loop(pc,d1.w),a5
                  lea      blt4ld_jmp3(pc,d0.w),a6
blt4ld_bloop:     jmp      (a4)
blt4ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  and.b    d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt4ld_loop:      REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  and.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt4ld_loop
                  jmp      (a6)
blt4ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  and.b    d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4ld_bloop
blt5:             rts

blt6ld:           lea      blt6ld_jmp1(pc,d2.w),a4
                  lea      blt6ld_loop(pc,d1.w),a5
                  lea      blt6ld_jmp3(pc,d0.w),a6
blt6ld_bloop:     jmp      (a4)
blt6ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  eor.b    d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt6ld_loop:      REPT 4
                  move.l   -(a0),d0
                  eor.l    d0,-(a1)
                  ENDM
                  dbra     d6,blt6ld_loop
                  jmp      (a6)
blt6ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  eor.b    d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6ld_bloop
                  rts

blt7ld:           lea      blt7ld_jmp1(pc,d2.w),a4
                  lea      blt7ld_loop(pc,d1.w),a5
                  lea      blt7ld_jmp3(pc,d0.w),a6
blt7ld_bloop:     jmp      (a4)
blt7ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt7ld_loop:      REPT 4
                  move.l   -(a0),d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt7ld_loop
                  jmp      (a6)
blt7ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7ld_bloop
                  rts

blt8ld:           lea      blt8ld_jmp1(pc,d2.w),a4
                  lea      blt8ld_loop(pc,d1.w),a5
                  lea      blt8ld_jmp3(pc,d0.w),a6
blt8ld_bloop:     jmp      (a4)
blt8ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  or.b     d0,(a1)
                  not.b    -(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt8ld_loop:      REPT 4
                  move.l   -(a0),d0
                  or.l     d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt8ld_loop
                  jmp      (a6)
blt8ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  or.b     d0,(a1)
                  not.b    -(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile

                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8ld_bloop
                  rts

blt9ld:           lea      blt9ld_jmp1(pc,d2.w),a4
                  lea      blt9ld_loop(pc,d1.w),a5
                  lea      blt9ld_jmp3(pc,d0.w),a6
blt9ld_bloop:     jmp      (a4)
blt9ld_jmp1:      REPT 3
                  move.b   -(a0),d0
                  eor.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt9ld_loop:      REPT 4
                  move.l   -(a0),d0
                  eor.l    d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt9ld_loop
                  jmp      (a6)
blt9ld_jmp3:      REPT 3
                  move.b   -(a0),d0
                  eor.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9ld_bloop
                  rts

blt11ld:          lea      blt11ld_jmp1(pc,d2.w),a4
                  lea      blt11ld_loop(pc,d1.w),a5
                  lea      blt11ld_jmp3(pc,d0.w),a6
blt11ld_bloop:    jmp      (a4)
blt11ld_jmp1:     REPT 3
                  not.b    (a1)
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt11ld_loop:     REPT 4
                  not.l    (a1)
                  move.l   -(a0),d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt11ld_loop
                  jmp      (a6)
blt11ld_jmp3:     REPT 3
                  not.b    (a1)
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11ld_bloop
                  rts

blt12ld:          lea      blt12ld_jmp1(pc,d2.w),a4
                  lea      blt12ld_loop(pc,d1.w),a5
                  lea      blt12ld_jmp3(pc,d0.w),a6
blt12ld_bloop:    jmp      (a4)
blt12ld_jmp1:     REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  move.b   d0,-(a1)
                  ENDM

                  move.w   d4,d6
                  jmp      (a5)
blt12ld_loop:     REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  move.l   d0,-(a1)
                  ENDM
                  dbra     d6,blt12ld_loop
                  jmp      (a6)
blt12ld_jmp3:     REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  move.b   d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile

                  dbra     d5,blt12ld_bloop
                  rts

blt13ld:          lea      blt13ld_jmp1(pc,d2.w),a4
                  lea      blt13ld_loop(pc,d1.w),a5
                  lea      blt13ld_jmp3(pc,d0.w),a6
blt13ld_bloop:    jmp      (a4)
blt13ld_jmp1:     REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  or.b     d0,-(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt13ld_loop:     REPT 4
                  move.l   -(a0),d0
                  not.l    d0
                  or.l     d0,-(a1)
                  ENDM
                  dbra     d6,blt13ld_loop
                  jmp      (a6)
blt13ld_jmp3:     REPT 3
                  move.b   -(a0),d0
                  not.b    d0
                  or.b     d0,-(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13ld_bloop
                  rts


blt14ld:          lea      blt14ld_jmp1(pc,d2.w),a4

                  lea      blt14ld_loop(pc,d1.w),a5
                  lea      blt14ld_jmp3(pc,d0.w),a6
blt14ld_bloop:    jmp      (a4)
blt14ld_jmp1:     REPT 3
                  move.b   -(a0),d0
                  and.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt14ld_loop:     REPT 4
                  move.l   -(a0),d0
                  and.l    d0,(a1)
                  not.l    -(a1)
                  ENDM
                  dbra     d6,blt14ld_loop
                  jmp      (a6)
blt14ld_jmp3:     REPT 3
                  move.b   -(a0),d0
                  and.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14ld_bloop
                  rts

blt1bd:           lea      blt1bd_loop(pc,d0.w),a4
blt1bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt1bd_loop:      REPT 32
                  move.b   -(a0),d0
                  and.b    d0,-(a1)
                  ENDM
                  dbra     d6,blt1bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1bd_bloop
                  rts

blt2bd:           lea      blt2bd_loop(pc,d0.w),a4
blt2bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt2bd_loop:      REPT 32
                  move.b   -(a0),d0
                  not.b    (a1)
                  and.b    d0,-(a1)
                  ENDM
                  dbra     d6,blt2bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2bd_bloop
                  rts

blt3bd:           lea      blt3bd_loop(pc,d0.w),a4
blt3bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt3bd_loop:      REPT 32
                  move.b   -(a0),-(a1)
                  ENDM
                  dbra     d6,blt3bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3bd_bloop
                  rts

blt4bd:           lea      blt4bd_loop(pc,d0.w),a4
blt4bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt4bd_loop:      REPT 32
                  move.b   -(a0),d0
                  not.b    d0
                  and.b    d0,-(a1)
                  ENDM
                  dbra     d6,blt4bd_loop

                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4bd_bloop
                  rts

blt6bd:           lea      blt6bd_loop(pc,d0.w),a4
blt6bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt6bd_loop:      REPT 32
                  move.b   -(a0),d0
                  eor.b    d0,-(a1)
                  ENDM
                  dbra     d6,blt6bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6bd_bloop
                  rts

blt7bd:           lea      blt7bd_loop(pc,d0.w),a4
blt7bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt7bd_loop:      REPT 32
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  dbra     d6,blt7bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7bd_bloop
                  rts

blt8bd:           lea      blt8bd_loop(pc,d0.w),a4
blt8bd_bloop:     move.w   d4,d6

                  jmp      (a4)
blt8bd_loop:      REPT 32
                  move.b   -(a0),d0
                  or.b     d0,(a1)
                  not.b    -(a1)
                  ENDM
                  dbra     d6,blt8bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8bd_bloop
                  rts

blt9bd:           lea      blt9bd_loop(pc,d0.w),a4
blt9bd_bloop:     move.w   d4,d6
                  jmp      (a4)
blt9bd_loop:      REPT 32
                  move.b   -(a0),d0
                  eor.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  dbra     d6,blt9bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9bd_bloop
                  rts

blt11bd:          lea      blt11bd_loop(pc,d0.w),a4
blt11bd_bloop:    move.w   d4,d6
                  jmp      (a4)
blt11bd_loop:     REPT 32
                  not.b    (a1)
                  move.b   -(a0),d0
                  or.b     d0,-(a1)
                  ENDM
                  dbra     d6,blt11bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11bd_bloop
                  rts

blt12bd:          lea      blt12bd_loop(pc,d0.w),a4
blt12bd_bloop:    move.w   d4,d6
                  jmp      (a4)
blt12bd_loop:     REPT 32
                  move.b   -(a0),d0
                  not.b    d0
                  move.b   d0,-(a1)
                  ENDM
                  dbra     d6,blt12bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt12bd_bloop
                  rts

blt13bd:          lea      blt13bd_loop(pc,d0.w),a4
blt13bd_bloop:    move.w   d4,d6

                  jmp      (a4)

blt13bd_loop:     REPT 32
                  move.b   -(a0),d0
                  not.b    d0
                  or.b     d0,-(a1)
                  ENDM
                  dbra     d6,blt13bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13bd_bloop
                  rts

blt14bd:          lea      blt14bd_loop(pc,d0.w),a4
blt14bd_bloop:    move.w   d4,d6
                  jmp      (a4)
blt14bd_loop:     REPT 32
                  move.b   -(a0),d0
                  and.b    d0,(a1)
                  not.b    -(a1)
                  ENDM
                  dbra     d6,blt14bd_loop
                  suba.w   a2,a0          ;naechste Quellzeile

                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14bd_bloop
                  rts

bitblt_inc:       cmp.w    #3,d7             ;kopieren?
                  bne      bitblt_inc_0x0

                  move.w   cpu040(pc),d1     ;68040-Prozessor?
                  beq      bitblt_inc_0x0

                  cmp.w    #63,d4         ;zu kurz?
                  ble      bitblt_inc_0x0

                  moveq    #15,d6

                  move.w   a0,d1
                  move.w   a1,d3
                  and.w    d6,d1
                  and.w    d6,d3
                  cmp.w    d1,d3          ;gleiche Grenze?
                  bne      bitblt_inc_0x0

                  move.w   d4,d7
                  addq.w   #1,d7
                  suba.w   d7,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d7,a3          ;Abstand zur naechsten Zielzeile

                  move.w   d1,d0
                  bne.s    blt040_start_mis
                  
                  moveq    #-1,d0
                  bra.s    blt040_end
                                    
blt040_start_mis: not      d0
                  and.w    d6,d0          ;Anzahl der anfaenglich zu kopierenden Bytes - 1
                  
                  sub.w    d0,d4
                  subq.w   #1,d4
                  
blt040_end:       move.w   d4,d2
                  lsr.w    #4,d4
                  subq.w   #1,d4          ;Zaehler fuer move16

                  and.w    d6,d2          ;Anzahl der am Ende zu kopierenden Bytes - 1
                  cmp.w    d6,d2
                  bne.s    blt3li_040_bloop

                  moveq    #-1,d2
                  addq.w   #1,d4             
                  cmp.w    d0,d2          ;ein Vielfaches von 16 Bytes kopieren?
                  bne.s    blt3li_040_bloop
                  addq.w   #1,d5
                  bra.s    blt3li_040_16nxt
                  
                  MC68040
                  
                  ALIGN    16
                  DCB.B    6,0
                  
blt3li_040_16:    move16   (a0)+,(a1)+
                  dbra     d6,blt3li_040_16
                  
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
blt3li_040_16nxt: move.w   d4,d6
                  dbra     d5,blt3li_040_16
                  rts

                  ALIGN 16
                  DCB.B 10,0

blt3li_040_bloop: move.w   d0,d6
                  bmi.s    blt3li_move16
                  
blt3li_040_start: move.b   (a0)+,(a1)+
                  dbra     d6,blt3li_040_start
                                    
blt3li_move16:    move.w   d4,d6

blt3li_loop16:    move16   (a0)+,(a1)+
                  dbra     d6,blt3li_loop16

                  move.w   d2,d6
                  bmi.s    blt3li_040_next
blt3li_040_end:   move.b   (a0)+,(a1)+
                  dbra     d6,blt3li_040_end

blt3li_040_next:  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3li_040_bloop
                  rts

                  MC68000

bitblt_inc_0x0:   cmp.w    #15,d4         ;zu kurz?
                  ble      blt_inc_byte2

                  move.w   d4,d6
                  addq.w   #1,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

                  move.w   cpu020(pc),d1     ;Wortzugriff auf ungerade Adresse moeglich?
                  bne.s    blt_inc_long

                  moveq    #1,d1
                  moveq    #1,d3
                  and.w    d0,d1
                  and.w    d2,d3
                  cmp.w    d1,d3          ;gleiche Grenze?
                  bne      blt_inc_byte

blt_inc_long:     moveq    #3,d6

                  move.w   d4,d2
                  add.w    d0,d2

                  subq.w   #1,d0
                  and.w    d6,d0
                  moveq    #3,d1
                  eor.w    d0,d1
                  sub.w    d1,d4
                  add.w    d0,d0          ;Offset fuer den Startsprung

                  addq.w   #1,d2
                  and.w    d6,d2

                  sub.w    d2,d4
                  eor.w    d6,d2
                  add.w    d2,d2          ;Offset fuer den Endsprung

                  addq.w   #1,d4
                  lsr.w    #2,d4          ;Anzahl der Langworte
                  subq.w   #1,d4
                  move.w   d4,d1
                  not.w    d1
                  and.w    d6,d1
                  add.w    d1,d1          ;Offset fuer den mittleren Sprung
                  lsr.w    #2,d4

                  add.w    d7,d7
                  add.w    d7,d7
                  lea      bltli_tab(pc,d7.w),a4
                  move.w   (a4)+,d7
                  beq.s    bltli_jmp
                  subq.w   #m4,d7
                  beq.s    bltli_m4

                  move.w   d0,d7
                  add.w    d0,d0
                  add.w    d7,d0
                  move.w   d1,d7
                  add.w    d1,d1
                  add.w    d7,d1
                  move.w   d2,d7
                  add.w    d2,d2
                  add.w    d7,d2
                  bra.s    bltli_jmp

bltli_m4:         add.w    d0,d0
                  add.w    d1,d1
                  add.w    d2,d2

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

blt_inc_byte2:    move.w   d4,d6
                  addq.w   #1,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

blt_inc_byte:     move.w   d4,d0
                  lsr.w    #5,d4          ;Schleifenzaehler
                  not.w    d0
                  andi.w   #31,d0
                  add.w    d0,d0          ;Sprungoffset

                  add.w    d7,d7
                  add.w    d7,d7
                  lea      bltbi_tab(pc,d7.w),a4
                  move.w   (a4)+,d7
                  beq.s    bltbi_jmp
                  subq.w   #m4,d7
                  beq.s    bltbi_m4

                  move.w   d0,d7
                  add.w    d0,d0
                  add.w    d7,d0
                  bra.s    bltbi_jmp

bltbi_m4:         add.w    d0,d0
bltbi_jmp:        move.w   (a4)+,d7
                  jmp      bltbi_tab(pc,d7.w)

bltbi_tab:        DC.W m2,blt0bi-bltbi_tab
                  DC.W m4,blt1bi-bltbi_tab
                  DC.W m6,blt2bi-bltbi_tab
                  DC.W m2,blt3bi-bltbi_tab
                  DC.W m6,blt4bi-bltbi_tab
                  DC.W m2,blt5-bltbi_tab
                  DC.W m4,blt6bi-bltbi_tab
                  DC.W m4,blt7bi-bltbi_tab
                  DC.W m6,blt8bi-bltbi_tab
                  DC.W m6,blt9bi-bltbi_tab
                  DC.W m2,blt10bi-bltbi_tab
                  DC.W m6,blt11bi-bltbi_tab
                  DC.W m6,blt12bi-bltbi_tab
                  DC.W m6,blt13bi-bltbi_tab
                  DC.W m6,blt14bi-bltbi_tab
                  DC.W m2,blt15bi-bltbi_tab


blt15li:          moveq    #$ffffffff,d7
                  bra.s    blt0li_jmp
blt0li:           moveq    #0,d7
blt0li_jmp:       lea      blt0li_jmp1(pc,d0.w),a4
                  lea      blt0li_loop(pc,d1.w),a5
                  lea      blt0li_jmp3(pc,d2.w),a6
blt0li_bloop:     jmp      (a4)
blt0li_jmp1:      REPT 3
                  move.b   d7,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt0li_loop:      REPT 4
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d6,blt0li_loop
                  jmp      (a6)
blt0li_jmp3:      REPT 3
                  move.b   d7,(a1)+
                  ENDM
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt0li_bloop
                  rts

blt1li:           lea      blt1li_jmp1(pc,d0.w),a4
                  lea      blt1li_loop(pc,d1.w),a5
                  lea      blt1li_jmp3(pc,d2.w),a6
blt1li_bloop:     jmp      (a4)
blt1li_jmp1:      REPT 3

                  move.b   (a0)+,d0
                  and.b    d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt1li_loop:      REPT 4
                  move.l   (a0)+,d0
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt1li_loop
                  jmp      (a6)
blt1li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  and.b    d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1li_bloop
                  rts

blt2li:           lea      blt2li_jmp1(pc,d0.w),a4
                  lea      blt2li_loop(pc,d1.w),a5
                  lea      blt2li_jmp3(pc,d2.w),a6
blt2li_bloop:     jmp      (a4)
blt2li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  not.b    (a1)
                  and.b    d0,(a1)+

                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt2li_loop:      REPT 4
                  move.l   (a0)+,d0
                  not.l    (a1)
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt2li_loop
                  jmp      (a6)
blt2li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  not.b    (a1)
                  and.b    d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2li_bloop
                  rts

blt3li:           lea      blt3li_jmp1(pc,d0.w),a4
                  lea      blt3li_loop(pc,d1.w),a5
                  lea      blt3li_jmp3(pc,d2.w),a6

blt3li_bloop:     jmp      (a4)
blt3li_jmp1:      REPT 3
                  move.b   (a0)+,(a1)+
                  ENDM
                  
                  move.w   d4,d6
                  jmp      (a5)
                  
blt3li_loop:      REPT 4
                  move.l   (a0)+,(a1)+
                  ENDM
                  dbra     d6,blt3li_loop

                  jmp      (a6)
blt3li_jmp3:      REPT 3
                  move.b   (a0)+,(a1)+

                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3li_bloop

                  rts

blt4li:           lea      blt4li_jmp1(pc,d0.w),a4
                  lea      blt4li_loop(pc,d1.w),a5
                  lea      blt4li_jmp3(pc,d2.w),a6
blt4li_bloop:     jmp      (a4)
blt4li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  not.b    d0
                  and.b    d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt4li_loop:      REPT 4

                  move.l   (a0)+,d0
                  not.l    d0
                  and.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt4li_loop
                  jmp      (a6)
blt4li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  not.b    d0
                  and.b    d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4li_bloop
                  rts

blt6li:           lea      blt6li_jmp1(pc,d0.w),a4
                  lea      blt6li_loop(pc,d1.w),a5
                  lea      blt6li_jmp3(pc,d2.w),a6
blt6li_bloop:     jmp      (a4)
blt6li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt6li_loop:      REPT 4
                  move.l   (a0)+,d0
                  eor.l    d0,(a1)+
                  ENDM
                  dbra     d6,blt6li_loop
                  jmp      (a6)
blt6li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6li_bloop
                  rts

blt7li:           lea      blt7li_jmp1(pc,d0.w),a4
                  lea      blt7li_loop(pc,d1.w),a5
                  lea      blt7li_jmp3(pc,d2.w),a6
blt7li_bloop:     jmp      (a4)
blt7li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt7li_loop:      REPT 4
                  move.l   (a0)+,d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt7li_loop
                  jmp      (a6)
blt7li_jmp3:      REPT 3

                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7li_bloop
                  rts

blt8li:           lea      blt8li_jmp1(pc,d0.w),a4
                  lea      blt8li_loop(pc,d1.w),a5
                  lea      blt8li_jmp3(pc,d2.w),a6
blt8li_bloop:     jmp      (a4)
blt8li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  or.b     d0,(a1)
                  not.b    (a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt8li_loop:      REPT 4
                  move.l   (a0)+,d0
                  or.l     d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt8li_loop
                  jmp      (a6)
blt8li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  or.b     d0,(a1)
                  not.b    (a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8li_bloop
                  rts


blt9li:           lea      blt9li_jmp1(pc,d0.w),a4
                  lea      blt9li_loop(pc,d1.w),a5
                  lea      blt9li_jmp3(pc,d2.w),a6
blt9li_bloop:     jmp      (a4)
blt9li_jmp1:      REPT 3
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)
                  not.b    (a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt9li_loop:      REPT 4
                  move.l   (a0)+,d0
                  eor.l    d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt9li_loop

                  jmp      (a6)
blt9li_jmp3:      REPT 3
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)
                  not.b    (a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9li_bloop
                  rts

blt10li:          lea      blt10li_jmp1(pc,d0.w),a4
                  lea      blt10li_loop(pc,d1.w),a5
                  lea      blt10li_jmp3(pc,d2.w),a6
blt10li_bloop:    jmp      (a4)
blt10li_jmp1:     REPT 3
                  not.b    (a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt10li_loop:     REPT 4
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt10li_loop
                  jmp      (a6)
blt10li_jmp3:     REPT 3
                  not.b    (a1)+
                  ENDM
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt10li_bloop
                  rts

blt11li:          lea      blt11li_jmp1(pc,d0.w),a4
                  lea      blt11li_loop(pc,d1.w),a5

                  lea      blt11li_jmp3(pc,d2.w),a6
blt11li_bloop:    jmp      (a4)
blt11li_jmp1:     REPT 3
                  not.b    (a1)
                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt11li_loop:     REPT 4
                  not.l    (a1)
                  move.l   (a0)+,d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt11li_loop
                  jmp      (a6)
blt11li_jmp3:     REPT 3
                  not.b    (a1)
                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11li_bloop
                  rts

blt12li:          lea      blt12li_jmp1(pc,d0.w),a4
                  lea      blt12li_loop(pc,d1.w),a5
                  lea      blt12li_jmp3(pc,d2.w),a6
blt12li_bloop:    jmp      (a4)
blt12li_jmp1:     REPT 3
                  move.b   (a0)+,d0
                  not.b    d0
                  move.b   d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt12li_loop:     REPT 4
                  move.l   (a0)+,d0
                  not.l    d0
                  move.l   d0,(a1)+
                  ENDM
                  dbra     d6,blt12li_loop
                  jmp      (a6)
blt12li_jmp3:     REPT 3
                  move.b   (a0)+,d0
                  not.b    d0

                  move.b   d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt12li_bloop
                  rts

blt13li:          lea      blt13li_jmp1(pc,d0.w),a4
                  lea      blt13li_loop(pc,d1.w),a5
                  lea      blt13li_jmp3(pc,d2.w),a6
blt13li_bloop:    jmp      (a4)
blt13li_jmp1:     REPT 3
                  move.b   (a0)+,d0

                  not.b    d0
                  or.b     d0,(a1)+
                  ENDM
                  move.w   d4,d6
                  jmp      (a5)
blt13li_loop:     REPT 4
                  move.l   (a0)+,d0
                  not.l    d0
                  or.l     d0,(a1)+
                  ENDM
                  dbra     d6,blt13li_loop
                  jmp      (a6)

blt13li_jmp3:     REPT 3
                  move.b   (a0)+,d0
                  not.b    d0
                  or.b     d0,(a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13li_bloop
                  rts

blt14li:          lea      blt14li_jmp1(pc,d0.w),a4
                  lea      blt14li_loop(pc,d1.w),a5
                  lea      blt14li_jmp3(pc,d2.w),a6
blt14li_bloop:    jmp      (a4)
blt14li_jmp1:     REPT 3
                  move.b   (a0)+,d0
                  and.b    d0,(a1)
                  not.b    (a1)+
                  ENDM

                  move.w   d4,d6
                  jmp      (a5)
blt14li_loop:     REPT 4
                  move.l   (a0)+,d0
                  and.l    d0,(a1)
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt14li_loop
                  jmp      (a6)
blt14li_jmp3:     REPT 3
                  move.b   (a0)+,d0
                  and.b    d0,(a1)
                  not.b    (a1)+
                  ENDM
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14li_bloop
                  rts

blt15bi:          moveq    #$ffffffff,d7
                  bra.s    blt0bi_jmp
blt0bi:           moveq    #0,d7
blt0bi_jmp:       lea      blt0bi_loop(pc,d0.w),a4
blt0bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt0bi_loop:      REPT 32
                  move.b   d7,(a1)+
                  ENDM
                  dbra     d6,blt0bi_loop
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt0bi_bloop
                  rts

blt1bi:           lea      blt1bi_loop(pc,d0.w),a4
blt1bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt1bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  and.b    d0,(a1)+
                  ENDM
                  dbra     d6,blt1bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt1bi_bloop
                  rts

blt2bi:           lea      blt2bi_loop(pc,d0.w),a4
blt2bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt2bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  not.b    (a1)
                  and.b    d0,(a1)+
                  ENDM
                  dbra     d6,blt2bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt2bi_bloop
                  rts

blt3bi:           lea      blt3bi_loop(pc,d0.w),a4
blt3bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt3bi_loop:      REPT 32
                  move.b   (a0)+,(a1)+
                  ENDM
                  dbra     d6,blt3bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3bi_bloop
                  rts

blt4bi:           lea      blt4bi_loop(pc,d0.w),a4
blt4bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt4bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  not.b    d0
                  and.b    d0,(a1)+
                  ENDM
                  dbra     d6,blt4bi_loop

                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt4bi_bloop
                  rts

blt6bi:           lea      blt6bi_loop(pc,d0.w),a4
blt6bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt6bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)+
                  ENDM
                  dbra     d6,blt6bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt6bi_bloop
                  rts

blt7bi:           lea      blt7bi_loop(pc,d0.w),a4
blt7bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt7bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  dbra     d6,blt7bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt7bi_bloop
                  rts

blt8bi:           lea      blt8bi_loop(pc,d0.w),a4
blt8bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt8bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  or.b     d0,(a1)
                  not.b    (a1)+
                  ENDM
                  dbra     d6,blt8bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt8bi_bloop

                  rts

blt9bi:           lea      blt9bi_loop(pc,d0.w),a4
blt9bi_bloop:     move.w   d4,d6
                  jmp      (a4)
blt9bi_loop:      REPT 32
                  move.b   (a0)+,d0
                  eor.b    d0,(a1)
                  not.b    (a1)+
                  ENDM
                  dbra     d6,blt9bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt9bi_bloop
                  rts

blt10bi:          lea      blt10bi_loop(pc,d0.w),a4
blt10bi_bloop:    move.w   d4,d6
                  jmp      (a4)
blt10bi_loop:     REPT 32
                  not.b    (a1)+
                  ENDM
                  dbra     d6,blt10bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt10bi_bloop
                  rts

blt11bi:          lea      blt11bi_loop(pc,d0.w),a4
blt11bi_bloop:    move.w   d4,d6
                  jmp      (a4)
blt11bi_loop:     REPT 32
                  not.b    (a1)
                  move.b   (a0)+,d0
                  or.b     d0,(a1)+
                  ENDM
                  dbra     d6,blt11bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt11bi_bloop

                  rts

blt12bi:          lea      blt12bi_loop(pc,d0.w),a4
blt12bi_bloop:    move.w   d4,d6
                  jmp      (a4)
blt12bi_loop:     REPT 32
                  move.b   (a0)+,d0
                  not.b    d0
                  move.b   d0,(a1)+
                  ENDM
                  dbra     d6,blt12bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt12bi_bloop
                  rts

blt13bi:          lea      blt13bi_loop(pc,d0.w),a4
blt13bi_bloop:    move.w   d4,d6
                  jmp      (a4)
blt13bi_loop:     REPT 32
                  move.b   (a0)+,d0
                  not.b    d0
                  or.b     d0,(a1)+
                  ENDM
                  dbra     d6,blt13bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt13bi_bloop
                  rts

blt14bi:          lea      blt14bi_loop(pc,d0.w),a4
blt14bi_bloop:    move.w   d4,d6
                  jmp      (a4)
blt14bi_loop:     REPT 32
                  move.b   (a0)+,d0
                  and.b    d0,(a1)
                  not.b    (a1)+
                  ENDM
                  dbra     d6,blt14bi_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt14bi_bloop
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
                  add.w    #16,d0                           ;Bufferlaenge in Bytes

                  tst.w    r_splanes(a6)                    ;8 Bit?
                  bne.s    scale_buf_len
                  
                  lsr.w    #4,d0                            ;Anzahl der Worte
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
                  tst.w    r_splanes(a6)                    ;8 Bit?
                  bne.s    scale_init_addr
                  lsr.w    #4,d1
                  add.w    d1,d1
scale_init_addr:  adda.w   d1,a1                            ;Quelladresse

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

                  tst.w    r_splanes(a6)                    ;8 Bit?
                  bne.s    scale_init8

                  lea      scale_line1(pc),a1
                  lea      scale_line1_trans(pc),a2

                  movem.l  (sp)+,d0-d7
                  rts

scale_init8:      lea      scale_line8(pc),a1
                  lea      scale_line8_trans(pc),a2

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
scale_line8_trans:
scale_line8:      movem.w  (a2),d2-d3
                  movem.w  3*2(a2),a2-a3

                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line8                     ;verkleinern?

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
grow_line8:       move.b   (a0)+,d1                         ;Pixel einlesen
grow_line8_write: move.b   d1,(a1)+                         ;Pixel ausgeben
                  add.w    a3,d2                            ;+ ya, naechstes Zielpixel
                  bpl.s    grow_line8_next                  ;Fehler >= 0, naechstes Quellpixel?
                  dbra     d3,grow_line8_write              ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  rts

grow_line8_next:  sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  dbra     d3,grow_line8                    ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
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
shrink_line8:     move.b   (a0)+,d1
                  add.w    a2,d3                            ;+ xa, naechstes Quellpixel
                  bpl.s    shrink_line8_next                ;Fehler >= 0, naechstes Zielpixel?
                  dbra     d2,shrink_line8                  ;sind noch weitere Quellpixel vorhanden?
                  move.b   d1,(a1)+
                  rts

shrink_line8_next:move.b   d1,(a1)+
                  sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  dbra     d2,shrink_line8                  ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
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
                  adda.w   d2,a0                            ;Zieladresse
                  
                  tst.w    r_splanes(a6)                    ;8 Bit?
                  bne.s    write_line_init8
                  
                  moveq    #15,d0
                  and.w    d6,d0                            ;Anzahl der restlichen Pixel - 1
                  swap     d0
                  move.w   d6,d0
                  lsr.w    #4,d0                            ;Anzahl der Worte - 1
                  move.l   d0,(a2)+
                  
                  lea      color_map(pc),a1
                  move.w   r_fgcol(a6),d0
                  move.b   0(a1,d0.w),d0
                  move.b   d0,(a2)+
                  move.b   d0,(a2)+                         ;Vordergrundfarbe
                  move.w   r_bgcol(a6),d0
                  move.b   0(a1,d0.w),d0
                  move.b   d0,(a2)+
                  move.b   d0,(a2)+                         ;Hintergrundfarbe

                  moveq    #3,d0
                  and.w    r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   wl_1_8_tab(pc,d0.w),d0           ;Offset der Funktion
                  lea      wl_1_8_tab(pc,d0.w),a1           ;Zeiger auf Ausgabefunktion
                  movem.l  (sp)+,d0-d3
                  rts

wl_1_8_tab:       DC.W  wl_1_8_repl-wl_1_8_tab
                  DC.W  wl_1_8_trans-wl_1_8_tab
                  DC.W  wl_1_8_eor-wl_1_8_tab
                  DC.W  wl_1_8_rev_trans-wl_1_8_tab
                  
write_line_init8: moveq    #15,d0
                  and.w    r_wmode(a6),d0
               
                  cmp.w    #3,d0                            ;nicht ersetzend?
                  bne.s    write_line_byte8
                  
                  moveq    #3,d1
                  and.w    d6,d1
                  swap     d1
                  move.w   d6,d1
                  lsr.w    #2,d1

                  move.w   cpu020(pc),d2                    ;mindestens 68020?
                  bne.s    write_line_cnt8
                  
                  move.l   a1,d2                            ;Zieladresse
                  btst     #0,d2                            ;gerade Endadresse?
                  beq.s    write_line_cnt8
   
write_line_byte8: moveq    #0,d1
                  move.w   d6,d1
                  swap     d1

write_line_cnt8:  move.l   d1,(a2)+
                  
                  add.w    d0,d0
                  move.w   wl_8_8_tab(pc,d0.w),d0           ;Offset der Funktion
                  lea      wl_8_8_tab(pc,d0.w),a1           ;Zeiger auf Ausgabefunktion

                  movem.l  (sp)+,d0-d3
                  rts

wl_8_8_tab:       DC.W  wl_8_8_mode0-wl_8_8_tab
                  DC.W  wl_8_8_mode1-wl_8_8_tab
                  DC.W  wl_8_8_mode2-wl_8_8_tab
                  DC.W  wl_8_8_mode3-wl_8_8_tab
                  DC.W  wl_8_8_mode4-wl_8_8_tab
                  DC.W  wl_8_8_mode5-wl_8_8_tab
                  DC.W  wl_8_8_mode6-wl_8_8_tab
                  DC.W  wl_8_8_mode7-wl_8_8_tab
                  DC.W  wl_8_8_mode8-wl_8_8_tab
                  DC.W  wl_8_8_mode9-wl_8_8_tab
                  DC.W  wl_8_8_mode10-wl_8_8_tab
                  DC.W  wl_8_8_mode11-wl_8_8_tab
                  DC.W  wl_8_8_mode12-wl_8_8_tab
                  DC.W  wl_8_8_mode13-wl_8_8_tab
                  DC.W  wl_8_8_mode14-wl_8_8_tab
                  DC.W  wl_8_8_mode15-wl_8_8_tab
                              
;Zeile ausgeben, von 1 Bit auf 8 Bit expandieren, REPLACE
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_8_repl:      move.l   d4,a3                            ;d4 sichern
                  move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.w   (a2)+,d2                         ;Vordergrundfarbe
                  move.w   (a2)+,d3                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_8_rpl_end

wl_1_8_rpl_loop:  move.w   (a0)+,d1
                  moveq    #15,d4

wl_1_8_rpl_word:  add.w    d1,d1
                  bcc.s    wl_1_8_rpl_bg
                  move.b   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d4,wl_1_8_rpl_word
                  
                  dbra     d0,wl_1_8_rpl_loop
                  bra.s    wl_1_8_rpl_end

wl_1_8_rpl_bg:    move.b   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d4,wl_1_8_rpl_word
                  dbra     d0,wl_1_8_rpl_loop

wl_1_8_rpl_end:   swap     d0
                  move.w   (a0)+,d1

wl_1_8_rpl_endfg: add.w    d1,d1
                  bcc.s    wl_1_8_rpl_endbg
                  move.b   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d0,wl_1_8_rpl_endfg

                  move.l   a3,d4
                  rts

wl_1_8_rpl_endbg: move.b   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d0,wl_1_8_rpl_endfg

                  move.l   a3,d4
                  rts

;Zeile ausgeben, von 1 Bit auf 8 Bit expandieren, TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_8_trans:     move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.w   (a2)+,d2                         ;Vordergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_8_trn_end

wl_1_8_trn_loop:  move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_8_trn_word:  add.w    d1,d1
                  bcc.s    wl_1_8_trn_bg
                  move.b   d2,(a1)                          ;Vordergrundfarbe
wl_1_8_trn_bg:    addq.l   #1,a1
                  dbra     d3,wl_1_8_trn_word
                  dbra     d0,wl_1_8_trn_loop

wl_1_8_trn_end:   swap     d0
                  move.w   (a0)+,d1

wl_1_8_trn_endfg: add.w    d1,d1
                  bcc.s    wl_1_8_trn_endbg
                  move.b   d2,(a1)                          ;Vordergrundfarbe
wl_1_8_trn_endbg: addq.l   #1,a1
                  dbra     d0,wl_1_8_trn_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 8 Bit expandieren, EOR
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_8_eor:       move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_8_eor_end

wl_1_8_eor_loop:  move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_8_eor_word:  add.w    d1,d1
                  scs      d2
                  eor.b    d2,(a1)+
                  dbra     d3,wl_1_8_eor_word
                  dbra     d0,wl_1_8_eor_loop

wl_1_8_eor_end:   swap     d0
                  move.w   (a0)+,d1

wl_1_8_eor_endfg: add.w    d1,d1
                  scs      d2
                  eor.b    d2,(a1)+
                  dbra     d0,wl_1_8_eor_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 8 Bit expandieren, REVERS TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_8_rev_trans: move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.l   (a2)+,d2                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_8_rtr_end

wl_1_8_rtr_loop:  move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_8_rtr_word:  add.w    d1,d1
                  bcs.s    wl_1_8_rtr_fg
                  move.b   d2,(a1)                          ;Hintergrundfarbe
wl_1_8_rtr_fg:    addq.l   #1,a1
                  dbra     d3,wl_1_8_rtr_word
                  dbra     d0,wl_1_8_rtr_loop

wl_1_8_rtr_end:   swap     d0
                  move.w   (a0)+,d1

wl_1_8_rtr_endbg: add.w    d1,d1
                  bcs.s    wl_1_8_rtr_endfg
                  move.b   d2,(a1)                          ;Hintergrundfarbe
wl_1_8_rtr_endfg: addq.l   #1,a1
                  dbra     d0,wl_1_8_rtr_endbg

                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile ausgeben, Modus 0 (ALL_ZERO)
wl_8_8_mode0:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #0,d1
wl_8_8_m0_loop:   move.b   d1,(a1)+
                  dbra     d0,wl_8_8_m0_loop
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_8_8_mode1:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m1_loop:   move.b   (a0)+,d1
                  and.b    d1,(a1)+
                  dbra     d0,wl_8_8_m1_loop
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_8_8_mode2:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m2_loop:   move.b   (a0)+,d1
                  not.b    (a1)
                  and.b    d1,(a1)+
                  dbra     d0,wl_8_8_m2_loop
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_8_8_mode3:     move.w   (a2)+,d1
                  move.w   (a2)+,d0
                  subq.w   #1,d0
                  bmi.s    wl_8_8_m3_loopb
wl_8_8_m3_loopl:  move.l   (a0)+,(a1)+
                  dbra     d0,wl_8_8_m3_loopl
wl_8_8_m3_loopb:  move.b   (a0)+,(a1)+
                  dbra     d1,wl_8_8_m3_loopb
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_8_8_mode4:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m4_loop:   move.b   (a0)+,d1
                  not.b    d1
                  and.b    d1,(a1)+
                  dbra     d0,wl_8_8_m4_loop
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_8_8_mode5:     rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_8_8_mode6:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m6_loop:   move.b   (a0)+,d1
                  eor.b    d1,(a1)+
                  dbra     d0,wl_8_8_m6_loop
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_8_8_mode7:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m7_loop:   move.b   (a0)+,d1
                  or.b     d1,(a1)+
                  dbra     d0,wl_8_8_m7_loop
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_8_8_mode8:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m8_loop:   move.b   (a0)+,d1
                  or.b     d1,(a1)
                  not.b    (a1)+
                  dbra     d0,wl_8_8_m8_loop
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_8_8_mode9:     move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m9_loop:   move.b   (a0)+,d1
                  eor.b    d1,(a1)
                  not.b    (a1)+
                  dbra     d0,wl_8_8_m9_loop
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_8_8_mode10:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m10_loop:  not.b    (a1)+
                  dbra     d0,wl_8_8_m10_loop
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_8_8_mode11:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m11_loop:  move.b   (a0)+,d1
                  not.b    (a1)
                  or.b     d1,(a1)+
                  dbra     d0,wl_8_8_m11_loop
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_8_8_mode12:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m12_loop:  move.b   (a0)+,d1
                  not.b    d1
                  move.b   d1,(a1)+
                  dbra     d0,wl_8_8_m12_loop
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_8_8_mode13:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m13_loop:  move.b   (a0)+,d1
                  not.b    d1
                  or.b     d1,(a1)+
                  dbra     d0,wl_8_8_m13_loop
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_8_8_mode14:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_8_8_m14_loop:  move.b   (a0)+,d1
                  and.b    d1,(a1)
                  not.b    (a1)+
                  dbra     d0,wl_8_8_m14_loop
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_8_8_mode15:    move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #$ffffffff,d1
wl_8_8_m15_loop:  move.b   d1,(a1)+
                  dbra     d0,wl_8_8_m15_loop
                  rts

ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dummy:            rts

                  DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Relozierungs-Information'

relokation:
;Reloziert am: Tue May 16 12:47:18 1995

				dc.w relok0-start+2
				dc.w relok1-relok0
				dc.w relok2-relok1
				dc.w relok3-relok2
				dc.w relok4-relok3
				dc.w relok5-relok4
				dc.w relok6-relok5
				dc.w relok7-relok6
				dc.w relok8-relok7
				dc.w 0 /* end of data */
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Laufzeitdaten'
                  BSS

cpu020:           DS.W 1                  ;Prozessortyp
cpu040:           DS.W 1                  ;Prozessortyp

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0

;Farbumwandlungstabelle fuer 256 Farben
color_map:        DS.B 256
;Tabelle fuer die Umwandlung von Farbebenenflag zu Farbnummer
color_remap:      DS.B 256

expand_tab:       DS.L 512                ;Expandiertabelle
expand_tabo:      DS.L 512                ;Expandiertabelle fuer movep.l


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
