;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                      16-Farb-Offscreen-Treiber fuer NVDI 4.1               *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ; 'Header'

VERSION           EQU $0410

INCLUDE "..\include\linea.inc"
INCLUDE "..\include\tos.inc"
INCLUDE "..\include\seedfill.inc"

INCLUDE "..\include\nvdi_wk.inc"
INCLUDE "..\include\vdi.inc"

INCLUDE "..\include\driver.inc"

PATTERN_LENGTH    EQU (32*4)              ;Fuellmusterlaenge bei 4 Ebenen

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
organisation:     DC.L  16                ;Farben
                  DC.W  4                 ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  1                 ;Bitorganisation
                  DC.W  0,0,0
header_end:

continue:         rts

;Initialisierungsfunktion
;Eingaben
;a0.l nvdi_struct
;Ausgaben
;d0.l Laenge der Workstation
init:             movem.l  d0-d2/a0-a2,-(sp)

                  move.l   a0,nvdi_struct
                  move.w   _nvdi_cpu020(a0),cpu020

                  bsr      make_relo      ;Treiber relozieren

                  bsr      build_exp      ;Expandier-Tabelle erstellen

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
                  move.l   res_x(a6),(a0)+   ;adressierbare Rasterbreite/hoehe
                  clr.w    (a0)+          ;genaue Skalierung moeglich !
                  move.l   pixel_width(a6),(a0)+      ;Pixelbreite/Pixelhoehe
                  moveq    #39,d0         ;40 Elemente kopieren
                  movea.l  nvdi_struct(pc),a2
                  movea.l  _nvdi_opnwk_work_out(a2),a2
                  lea      10(a2),a2      ;work_out + 5
work_out_int:     move.w   (a2)+,(a0)+
                  dbra     d0,work_out_int
                     
                  move.w   #16,26-90(a0)  ;work_out[13]: Anzahl der Farben
                  move.w   #1,70-90(a0)   ;work_out[35]: Farbe ist vorhanden
                  move.w   #16,78-90(a0)  ;work_out[39]: 16 Farbabstufungen in der Palette

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
                  move.w   #16,2-90(a0)      ;work_out[1]: 16 Farbabstufungen
                  move.w   #4,8-90(a0)       ;work_out[4]: Anzahl der Farbebenen
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
                  
                  move.w   #2,(a0)+       ;[0] Packed
                  move.w   d0,(a0)+       ;[1] keine CLUT
                  move.w   #4,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #16,(a0)+      ;[3/4] Farbanzahl
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

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

;Eingaben:
;a0.l Zeiger auf resinfo-Struktur
get_resinfo:      rts
                  
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

build_exp:        movem.l  d0-d2/a0-a1,-(sp)
                  lea      expand_tab(pc),a0
                  moveq    #0,d0          ;Zaehler
build_exp_bloop:  move.w   d0,d1          ;Bitmuster
                  moveq    #3,d2
build_exp_loop:   clr.b    (a0)
                  add.b    d1,d1          ;Bit gesetzt?
                  bcc.s    build_exp_nib2
                  eori.b   #$f0,(a0)
build_exp_nib2:   add.b    d1,d1          ;Bit gesetzt?
                  bcc.s    build_exp_next
                  eori.b   #$0f,(a0)
build_exp_next:   addq.l   #1,a0
                  dbra     d2,build_exp_loop
                  addq.w   #1,d0
                  cmp.w    #256,d0        ;alle 256 Kombinationen durch?
                  blt.s    build_exp_bloop
                  movem.l  (sp)+,d0-d2/a0-a1
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;WK-Tabelle intialisieren
;Eingaben
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:
                  move.w   #3,r_planes(a6)   ;Anzahl der Bildebenen -1
                  move.w   #15,colors(a6) ;hoechste Farbnummer

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

;VDI-Farbindex in realen Farbwert umsetzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w VDI-Farbindex
;a6.l Workstation
;Ausgaben:
;d0.l Farbwert
vdi_to_color:     lea      color_map(pc),a0
                  move.b   0(a0,d0.w),d0
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
                  move.b   0(a0,d0.w),d0
                  rts
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'v_contourfill'

;Zeile fuer v_contourfill absuchen
;
;Diese Routine ermittelt die Farbe des Startpunktes (x,y) und sucht dann
;links und rechts davon solange, bis ein Farbwechsel auftritt. Diese Grenzen
;werden ueber die Pointer (a0/a1) gesichert
;
;d5-d7/a0-a2/a5/a6 duerfen nicht veraendert werden
;Eingaben
;d0.w x
;d1.w y
;a0.l Adresse der linken Grenze
;a1.l Adresse der rechten Grenze
;Ausgaben
;d0.w Rueckgabewert
;d0-d4/a3/a4 werden zerstoert
scanline:         move.l   d5,-(sp)
                  move.w   d0,d3          ;X-Start merken
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

                  cmp.w    v_1e+2(a5),d4
                  beq.s    lblE0
                  eori.w   #1,d0
lblE0:            move.l   (sp)+,d5
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '3. Attributfunktionen'

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
                  bsr      vr_trnfm_dev
                  movem.l  (sp)+,d1-d7/a2-a6
                  moveq    #3,d0          ;4 Farbebenen
                  rts

set_pattern_mono: REPT     8
                  move.l   (a0)+,(a1)+
                  ENDM
                  moveq    #0,d0          ;1 Ebene
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
                  bne.s    vr_trnfm_frmt
                  moveq    #1,d2          ;standardisiertes Zielformat
vr_trnfm_frmt:    move.w   d2,fd_stand(a1) ;Format des Zielblocks eintragen

                  movea.l  (a0),a0        ;Quellblockadresse
                  movea.l  (a1),a1        ;Zielblockadresse
                  subq.l   #1,d1          ;mindestens ein Wort?
                  bmi.s    vr_trnfm_exit

                  subq.w   #1,d0          ;nur eine Ebene, monochrom?
                  beq      vr_trnfm_mono
                  subq.w   #4-1,d0        ;4 Ebenen?
                  bne.s    vr_trnfm_exit

                  add.w    d2,d2
                  add.w    d2,d2
                  movea.l  vr_tr_tab(pc,d2.w),a2 ;Zeiger auf die Wandlungsroutine

                  cmpa.l   a0,a1          ;Quell- und Zieladresse gleich?
                  bne.s    vr_trnfm_diff

                  move.l   d1,d3
                  addq.l   #1,d3          ;Wortanzahl pro Ebene
                  lsl.l    #3,d3          ;Speicherbedarf des Blocks (Wortanzahl * 2 * 4)
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
                  moveq    #3,d4          ;Anzahl der Ebenen - 1
                  bsr.s    vr_trnfm_interl ;Block in interleaved Planes wandeln
                  movem.l  (sp)+,d1/a0-a1
vr_trnfm_sdev1:   moveq    #7,d0
                  move.w   (a0)+,d5       ;Ebene 0
                  move.w   (a0)+,d4       ;Ebene 1
                  move.w   (a0)+,d3       ;Ebene 2
                  move.w   (a0)+,d2       ;Ebene 3
vr_trnfm_sdev2:   REPT 2
                  add.w    d2,d2
                  addx.b   d7,d7
                  add.w    d3,d3
                  addx.b   d7,d7
                  add.w    d4,d4
                  addx.b   d7,d7
                  add.w    d5,d5
                  addx.b   d7,d7
                  ENDM
                  move.b   d7,(a1)+       ;Byte im geraetespezifischen Format ausgeben
                  dbra     d0,vr_trnfm_sdev2
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sdev1
                  rts

;Block mit gleicher Quell- und Zieladresse ins Standardformat wandeln
;Eingaben
;d1.l Worte pro Ebene - 1
;a0.l Quelladresse
;a1.l Zieladresse (gleich der Quelladresse)
;Ausgaben
;Register d0-d4/a0-a2 werden veraendert
vr_trnfm_sames:   movem.l  d1/a0-a1,-(sp)
vr_trnfm_sstd1:   moveq    #7,d0          ;16 Pixel bearbeiten
vr_trnfm_sstd2:   move.b   (a0)+,d7
                  REPT 2
                  add.b    d7,d7
                  addx.w   d2,d2
                  add.b    d7,d7
                  addx.w   d3,d3
                  add.b    d7,d7
                  addx.w   d4,d4
                  add.b    d7,d7
                  addx.w   d5,d5
                  ENDM
                  dbra     d0,vr_trnfm_sstd2
                  move.w   d5,(a1)+       ;Ebene 0
                  move.w   d4,(a1)+       ;Ebene 1
                  move.w   d3,(a1)+       ;Ebene 2
                  move.w   d2,(a1)+       ;Ebene 3
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sstd1
                  movem.l  (sp)+,d4/a0-a1
                  moveq    #3,d0          ;interleaved Planes ins Standardformat wandeln

;Block vom Standardformat ins interleaved Bitplane-Format wandeln oder umgekehrt
;Eingaben
;d0.l Anzahl der Ebenen des Standardformats oder Anzahl der Worte pro Ebene - 1
;d4.l Anzahl der Worte pro Eben oder Anzahl der Ebenen - 1
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
                  lea      0(a1,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3

vr_trnfm_sbloop:  moveq    #7,d0          ;16 Pixel bearbeiten
vr_trnfm_sloop:   move.b   (a0)+,d7
                  REPT 2
                  add.b    d7,d7
                  addx.w   d2,d2
                  add.b    d7,d7
                  addx.w   d3,d3
                  add.b    d7,d7
                  addx.w   d4,d4
                  add.b    d7,d7
                  addx.w   d5,d5
                  ENDM

                  dbra     d0,vr_trnfm_sloop
                  move.w   d5,(a1)+       ;Ebene 0
                  move.w   d4,(a2)+       ;Ebene 1
                  move.w   d3,(a3)+       ;Ebene 2
                  move.w   d2,(a4)+       ;Ebene 3
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
                  lea      0(a0,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3

vr_trnfm_dbloop:  moveq    #7,d0
                  move.w   (a0)+,d5       ;Ebene 0
                  move.w   (a2)+,d4       ;Ebene 1
                  move.w   (a3)+,d3       ;Ebene 2
                  move.w   (a4)+,d2       ;Ebene 3

vr_trnfm_dloop:   REPT 2
                  add.w    d2,d2
                  addx.b   d7,d7
                  add.w    d3,d3
                  addx.b   d7,d7
                  add.w    d4,d4
                  addx.b   d7,d7
                  add.w    d5,d5
                  addx.b   d7,d7
                  ENDM
                  move.b   d7,(a1)+       ;Byte im geraetespezifischen Format ausgeben
                  dbra     d0,vr_trnfm_dloop
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
get_pixel:        move.l   d2,-(sp)
                  movea.l  bitmap_addr(a6),a0
                  move.w   bitmap_width(a6),d2
                  bne.s    get_pixel_addr 
                  movea.l  v_bas_ad.w,a0
relok1:
                  move.w   BYTES_LIN.w,d2
get_pixel_addr:   muls     d2,d1
                  adda.l   d1,a0          ;Zeilenadresse
                  move.w   d0,d1
                  lsr.w    #1,d0
                  adda.w   d0,a0
                  moveq    #0,d0
                  move.b   (a0),d0        ;Bitmuster
                  btst     #0,d1          ;oberes Nibble?
                  bne.s    get_pixel_mask
                  lsr.w    #4,d0
get_pixel_mask:   and.w    #15,d0
                  move.l   (sp)+,d2
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
set_pixel:        movem.l  d2-d3,-(sp)
                  movea.l  bitmap_addr(a6),a0
                  move.w   bitmap_width(a6),d3
                  bne.s    set_pixel_addr 
                  movea.l  v_bas_ad.w,a0
relok2:
                  move.w   BYTES_LIN.w,d3
set_pixel_addr:   muls     d3,d1
                  adda.l   d1,a0          ;Zeilenadresse
                  move.w   d0,d1
                  lsr.w    #1,d0
                  adda.w   d0,a0
                  moveq    #0,d0
                  moveq    #$0f,d0
                  btst     #0,d1          ;oberes Nibble?
                  beq.s    set_pixel_mask
                  lsl.w    #4,d0
                  lsl.l    #4,d2
set_pixel_mask:   not.b    d0
                  and.b    d0,(a0)
                  or.b     d2,(a0)
                  movem.l  (sp)+,d2-d3
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
relok3:
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
                  bne      expand_blt
                  clr.w    r_fgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_bgcol(a6) ;Textfarbe
                  bra      expand_blt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'horizontale Linie'

;horizontalen Linie ohne Clipping zeichnen
;d0-d2/d4-d7/a1 duerfen zerstoert werden
;Eingaben
;d0 x1
;d1 y
;d2 x2
;d6 Linienstil
;d7 Schreibmodus
;a6 Zeiger auf die Workstation
;Ausgaben
;d0-d2/d4-d7/a1 werden zerstoert
hline:            movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok4:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    hline_dy

                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

hline_dy:         muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse
                  moveq    #$fffffff8,d4
                  and.w    d0,d4
                  lsr.w    #1,d4
                  adda.w   d4,a1          ;Langwortadresse

                  movem.l  d3/a2-a3,-(sp)

                  lea      color_map_long(pc),a2
                  move.w   l_color(a6),d1
                  add.w    d1,d1
                  add.w    d1,d1
                  move.l   0(a2,d1.w),d1

                  move.w   d7,d5

                  lea      expand_tab(pc),a2

                  move.w   d6,d7
                  lsr.w    #8,d6
                  and.w    #$ff,d7
                  add.w    d6,d6
                  add.w    d6,d6
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a2,d6.w),d6
                  move.l   0(a2,d7.w),d7

hline_in:         move.w   d2,d3          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  subq.w   #MD_TRANS-1,d5
                  beq      hline_trans
                  subq.w   #MD_XOR-MD_TRANS,d5 ;EOR?
                  beq      hline_eor
                  subq.w   #MD_ERASE-MD_XOR,d5
                  beq      hline_rev_trans

                  moveq    #8,d4
                  and.w    d0,d4
                  movea.l  hline_repl_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d3,d5
                  movea.l  hline_repl_emtab(pc,d5.w),a3 ;Endmaskenausgabe

                  bra.s    hline_repl_mask

hline_repl_smtab: DC.L hline_repl_sm0
                  DC.L 0
                  DC.L hline_repl_sm1

hline_repl_emtab: DC.L hline_repl_em1
                  DC.L 0
                  DC.L hline_repl_em0

hline_repl_sms:   DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

hline_repl_ems:   DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

hline_repl_mask:  moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d3
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d3,d3
                  add.w    d3,d3
                  move.l   hline_repl_sms(pc,d0.w),d4 ;Startmaske
                  move.l   hline_repl_ems(pc,d3.w),d5 ;Endmaske

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    hline_repl_vcnt2

                  cmpa.l   #hline_repl_sm0,a2
                  beq.s    hline_repl_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  bra.s    hline_repl_sh

hline_repl_se:    cmpa.l   #hline_repl_em0,a3
                  beq.s    hline_repl_sh
                  and.l    d5,d4
                  moveq    #0,d5

hline_repl_sh:    lea      hline_repl_m1(pc),a2

hline_repl_vcnt2: and.l    d1,d6

                  and.l    d1,d7

hline_repl_line:  jmp      (a2)

hline_repl_m1:    or.l     d4,(a1)
                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0
                  bra.s    hline_repl_next

hline_repl_sm1:   or.l     d4,(a1)
                  move.l   d7,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    hline_repl_hcount

hline_repl_sm0:   or.l     d4,(a1)
                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

hline_repl_sd7:   move.l   d7,(a1)+

hline_repl_hcount:subq.w   #1,d2
                  bmi.s    hline_repl_ejmp
hline_repl_loop:  move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  dbra     d2,hline_repl_loop

hline_repl_ejmp:  jmp      (a3)

hline_repl_em1:   move.l   d6,d0
                  bra.s    hline_repl_next

hline_repl_em0:   move.l   d6,(a1)+
                  move.l   d7,d0

hline_repl_next:  or.l     d5,(a1)
                  not.l    d0
                  and.l    d5,d0
                  eor.l    d0,(a1)

                  movem.l  (sp)+,d3/a2-a3
hline_exit:       rts

hline_rev_trans:  not.l    d6
                  not.l    d7
hline_trans:      moveq    #8,d4
                  and.w    d0,d4
                  movea.l  hline_trans_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d3,d5
                  movea.l  hline_trans_emtab(pc,d5.w),a3 ;Endmaskenausgabe

                  bra.s    hline_trans_mask

hline_trans_smtab:DC.L hline_trans_sm0
                  DC.L 0
                  DC.L hline_trans_sm1

hline_trans_emtab:DC.L hline_trans_em1
                  DC.L 0
                  DC.L hline_trans_em0

hline_trans_sms:  DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

hline_trans_ems:  DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

hline_trans_mask: moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d3
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d3,d3
                  add.w    d3,d3
                  move.l   hline_trans_sms(pc,d0.w),d4 ;Startmaske
                  move.l   hline_trans_ems(pc,d3.w),d5 ;Endmaske

                  not.l    d1

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    hline_trans_vcnt2

                  cmpa.l   #hline_trans_sm0,a2
                  beq.s    hline_trans_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  bra.s    hline_trans_sh

hline_trans_se:   cmpa.l   #hline_trans_em0,a3
                  beq.s    hline_trans_sh
                  and.l    d5,d4
                  moveq    #0,d5

hline_trans_sh:   lea      hline_trans_m1(pc),a2

hline_trans_vcnt2:

hline_trans_line: jmp      (a2)

hline_trans_m1:   and.l    d6,d4
                  or.l     d4,(a1)
                  and.l    d1,d4
                  eor.l    d4,(a1)+
                  move.l   d7,d0
                  bra.s    hline_trans_next

hline_trans_sm1:  and.l    d7,d4
                  or.l     d4,(a1)
                  and.l    d1,d4
                  eor.l    d4,(a1)+
                  bra.s    hline_trans_hcount

hline_trans_sm0:  move.l   d4,d0
                  and.l    d6,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)+

hline_trans_sd7:  or.l     d7,(a1)
                  move.l   d7,d0
                  and.l    d1,d0
                  eor.l    d0,(a1)+

hline_trans_hcount:move.l  d1,d0
                  move.l   d1,d4
                  and.l    d6,d0
                  and.l    d7,d4
                  subq.w   #1,d2
                  bmi.s    hline_trans_ejmp
hline_trans_loop: or.l     d6,(a1)
                  eor.l    d0,(a1)+
                  or.l     d7,(a1)
                  eor.l    d4,(a1)+
                  dbra     d2,hline_trans_loop

hline_trans_ejmp: jmp      (a3)

hline_trans_em1:  move.l   d6,d0
                  bra.s    hline_trans_next

hline_trans_em0:  or.l     d6,(a1)
                  move.l   d6,d0
                  and.l    d1,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0

hline_trans_next: and.l    d5,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)

                  movem.l  (sp)+,d3/a2-a3
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
;a3.l Abstand von 16 Zeilen abzueglich des zu zeichnenden Linie
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
hline_eor:        moveq    #8,d4
                  and.w    d0,d4
                  movea.l  hline_eor_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d3,d5
                  movea.l  hline_eor_emtab(pc,d5.w),a3 ;Endmaskenausgabe

                  bra.s    hline_eor_mask

hline_eor_smtab:  DC.L hline_eor_sm0
                  DC.L 0
                  DC.L hline_eor_sm1

hline_eor_emtab:  DC.L hline_eor_em1
                  DC.L 0
                  DC.L hline_eor_em0

hline_eor_sms:    DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

hline_eor_ems:    DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

hline_eor_mask:   moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d3
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d3,d3
                  add.w    d3,d3
                  move.l   hline_eor_sms(pc,d0.w),d4 ;Startmaske
                  move.l   hline_eor_ems(pc,d3.w),d5 ;Endmaske

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    hline_eor_vcnt2

                  cmpa.l   #hline_eor_sm0,a2
                  beq.s    hline_eor_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  bra.s    hline_eor_sh

hline_eor_se:     cmpa.l   #hline_eor_em0,a3
                  beq.s    hline_eor_sh
                  and.l    d5,d4
                  moveq    #0,d5

hline_eor_sh:     lea      hline_eor_m1(pc),a2

hline_eor_vcnt2:
hline_eor_line:   jmp      (a2)

hline_eor_m1:     and.l    d6,d4
                  eor.l    d4,(a1)+
                  and.l    d7,d5
                  bra.s    hline_eor_next

hline_eor_sm1:    and.l    d7,d4
                  eor.l    d4,(a1)+
                  bra.s    hline_eor_hcount

hline_eor_sm0:    move.l   d6,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

hline_eor_sd7:    eor.l    d7,(a1)+

hline_eor_hcount: subq.w   #1,d2
                  bmi.s    hline_eor_ejmp
hline_eor_loop:   eor.l    d6,(a1)+
                  eor.l    d7,(a1)+
                  dbra     d2,hline_eor_loop

hline_eor_ejmp:   jmp      (a3)

hline_eor_em1:    and.l    d6,d5
                  bra.s    hline_eor_next

hline_eor_em0:    eor.l    d6,(a1)+
                  and.l    d7,d5

hline_eor_next:   eor.l    d5,(a1)

                  movem.l  (sp)+,d3/a2-a3
                  rts

;horizontalen Linie ohne Clipping zeichnen
;d0-d2/d4-d7/a1 duerfen zerstoert werden
;Eingaben
;d0 x1
;d1 y
;d2 x2
;d6 Linienstil

;d7 Schreibmodus
;a6 Zeiger auf die Workstation
;Ausgaben
;d0-d2/d4-d7/a1 werden zerstoert
fline:            tst.w    f_planes(a6)   ;mehrere Ebenen?
                  bne.s    fline_save

fline_mono_pat:   movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6  ;Linienstil

                  move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  bsr      hline
                  move.w   (sp)+,l_color(a6)
                  rts

fline_save:       movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok5:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fline_dy

                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

fline_dy:         muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse
                  moveq    #$fffffff8,d4
                  and.w    d0,d4
                  lsr.w    #1,d4
                  adda.w   d4,a1          ;Langwortadresse

                  movem.l  d3/a2-a3,-(sp)

                  move.w   d7,d5

                  movea.l  f_pointer(a6),a2
                  moveq    #15,d4
                  and.w    d1,d4
                  lsl.w    #3,d4
                  adda.w   d4,a2
                  move.l   (a2)+,d6
                  move.l   (a2)+,d7

                  lea      color_map_long(pc),a2
                  move.w   f_color(a6),d1
                  add.w    d1,d1
                  add.w    d1,d1
                  move.l   0(a2,d1.w),d1

                  bra      hline_in
fline_exit:       rts

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
                  lea      color_map(pc),a1
                  adda.w   l_color(a6),a1
                  move.b   0(a1),d4       ;Ebenenzuordnung

;Startadresse berechnen
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  moveq    #0,d5          ;auf Langwort erweitern
relok6:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  move.w   #$f0,d1
                  lsr.w    #1,d0
                  bcs.s    vline_low_nibble
                  moveq    #15,d1
                  lsl.w    #4,d4
vline_low_nibble: adda.w   d0,a1          ;Startadresse

                  add.w    d7,d7
                  move.w   vline_tab(pc,d7.w),d7
                  jmp      vline_tab(pc,d7.w)

vline_tab:        DC.W vline_replace-vline_tab
                  DC.W vline_trans-vline_tab
                  DC.W vline_eor-vline_tab
                  DC.W vline_rev_trans-vline_tab

vline_rev_trans:  not.w    d6
vline_trans:      move.w   d5,-(sp)
                  lsl.l    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_tr_loop
                  move.w   d3,d0

vline_tr_loop:    move.l   a1,d2
                  add.w    d6,d6          ;Punkt gesetzt?
                  bcc      vline_tr_next

                  move.w   d3,-(sp)
                  lsr.w    #4,d3
                  move.w   d3,d7
                  lsr.w    #4,d3
                  not.w    d7
                  andi.w   #15,d7
                  swap     d0
                  move.w   d7,d0
                  add.w    d7,d7
                  add.w    d0,d7
                  swap     d0
                  add.w    d7,d7
                  jmp      vline_tr_points(pc,d7.w)

vline_tr_points:  REPT 16
                  and.b    d1,(a1)
                  or.b     d4,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d3,vline_tr_points
                  move.w   (sp)+,d3

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
vloop_eor_grow:   eor.b    d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vloop_eor_grow
                  rts

vline_eor:        move.w   d1,d4
                  not.w    d4
                  cmp.w    #$aaaa,d6
                  beq.s    vline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    vline_eor_grow2

                  move.w   d5,-(sp)
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
                  eor.b    d4,(a1)
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
                  lsl.l    #4,d5          ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d3          ;mindestens 16 Punkte zeichnen?
                  bge.s    vline_repl_loop
                  move.w   d3,d0

vline_repl_loop:  move.l   a1,-(sp)
                  move.w   d3,-(sp)

                  add.w    d6,d6          ;Punkt gesetzt?
                  scs      d2
                  and.w    d4,d2

                  lsr.w    #4,d3
                  move.w   d3,d7
                  lsr.w    #4,d3
                  not.w    d7
                  andi.w   #15,d7
                  swap     d0
                  move.w   d7,d0
                  add.w    d7,d7
                  add.w    d0,d7
                  swap     d0
                  add.w    d7,d7
                  jmp      vline_repl_points(pc,d7.w)

vline_repl_points:REPT 16
                  and.b    d1,(a1)
                  or.b     d2,(a1)
                  adda.l   d5,a1
                  ENDM
                  dbra     d3,vline_repl_points

                  move.w   (sp)+,d3
                  movea.l  (sp)+,a1
                  adda.w   (sp),a1
                  subq.w   #1,d3
                  dbra     d0,vline_repl_loop
                  addq.l   #2,sp
                  rts

vline_solid:      move.w   d3,d2
                  not.w    d2
                  and.w    #15,d2
                  cmp.w    #$0f,d4
                  beq.s    vline_blk
                  cmp.w    #$f0,d4
                  beq.s    vline_blk
                  move.w   d2,d6
                  add.w    d2,d2
                  add.w    d6,d2
                  add.w    d2,d2
                  lsr.w    #4,d3
                  jmp      vline_sld_loop(pc,d2.w)
vline_sld_loop:   REPT 16
                  and.b    d1,(a1)
                  or.b     d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  ENDM
                  dbra     d3,vline_sld_loop
vline_solid_exit: rts

vline_blk:        add.w    d2,d2
                  add.w    d2,d2
                  lsr.w    #4,d3
                  jmp      vline_blk_loop(pc,d2.w)
vline_blk_loop:   REPT 16
                  or.b     d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  ENDM
                  dbra     d3,vline_blk_loop
                  rts

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
relok7:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    line_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
line_laddr:       move.l   a3,-(sp)

                  move.w   d5,d4
                  muls     d1,d4          ;Bytes pro Zeile * y1
                  adda.l   d4,a1          ;Zeilenadresse
                  move.w   d0,d4
                  lsr.w    #1,d4
                  adda.w   d4,a1          ;Startadresse

                  moveq    #$0f,d4
                  and.w    d0,d4
                  rol.w    d4,d6          ;Muster rotieren

                  sub.w    d0,d2          ;dx
                  bmi.s    line_exit
                  sub.w    d1,d3          ;dy
                  bpl.s    line_color     ;negativ ?

                  neg.w    d3
                  neg.w    d5             ;vertikale Schrittrichtung aendern

line_color:       move.w   l_color(a6),d4
                  lea      color_map(pc),a3
                  move.b   0(a3,d4.w),d4
                  movea.w  d5,a3

                  moveq    #1,d5
                  and.w    d0,d5
                  beq.s    line_high
                  moveq    #$fffffff0,d5
                  bra.s    line_angle

line_high:        moveq    #$0f,d5
                  lsl.w    #4,d4

line_angle:       cmp.w    d3,d2          ;Winkel > 44 degree ?
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
                  jsr      line_tab0(pc,d7.w) ;Linie zeichnen
line_exit:        movea.l  (sp)+,a3
                  rts

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
                  jsr      line_tab45(pc,d7.w) ;Linie zeichnen

                  movea.l  (sp)+,a3
                  rts

line_tab45:       DC.W line_rep45-line_tab45
                  DC.W line_trans45-line_tab45
                  DC.W line_eor45-line_tab45
                  DC.W line_rev_trans45-line_tab45

line_rep:         cmp.w    #$ffff,d6      ;durchgehend schwarz?
                  beq.s    line_solid
line_rep_loop:    and.b    d5,(a1)
                  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_white ;nicht gesetzt ?
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
line_rep_white:   ror.b    #4,d4
                  not.b    d5
                  cmp.b    #$0f,d5
                  bne.s    line_rep_add
                  addq.l   #1,a1
line_rep_add:     add.w    d1,d3          ;e + 2dx-2dy
                  bmi.s    line_rep_next  ;wenn nein; Schritt nach unten
                  adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
line_rep_next:    dbra     d0,line_rep_loop
                  rts

line_solid:       and.b    d5,(a1)
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
                  ror.b    #4,d4
                  not.b    d5
                  cmp.b    #$0f,d5
                  bne.s    line_sld_add
                  addq.l   #1,a1
line_sld_add:     add.w    d1,d3          ;e + 2dx-2dy
                  bmi.s    line_sld_next  ;wenn nein; Schritt nach unten
                  adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
line_sld_next:    dbra     d0,line_solid
                  rts

line_rev_trans:   not.w    d6
line_trans:       rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_trans_white ;nicht gesetzt ?
                  and.b    d5,(a1)
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
line_trans_white: ror.b    #4,d4
                  not.b    d5
                  cmp.b    #$0f,d5
                  bne.s    line_trans_add
                  addq.l   #1,a1
line_trans_add:   add.w    d1,d3          ;e + 2dx-2dy
                  bmi.s    line_trans_next ;wenn nein; Schritt nach unten
                  adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
line_trans_next:  dbra     d0,line_trans
                  rts

line_eor:         not.b    d5
                  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_white ;nicht gesetzt ?
                  eor.b    d5,(a1)        ;schwarzen Punkt setzen
line_eor_white:   cmp.b    #$0f,d5
                  bne.s    line_eor_add
                  addq.l   #1,a1
line_eor_add:     add.w    d1,d3          ;e + 2dx-2dy
                  bmi.s    line_eor_next  ;wenn nein; Schritt nach unten
                  adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
line_eor_next:    dbra     d0,line_eor
                  rts


line_rep45:       cmp.w    #$ffff,d6      ;durchgehend schwarz?
                  beq.s    line_solid45
line_rep_loop45:  and.b    d5,(a1)
                  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_w45   ;nicht gesetzt ?
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
line_rep_w45:     adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_rep_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  ror.b    #4,d4
                  not.w    d5
                  cmp.b    #$0f,d5
                  bne.s    line_rep_next45
                  addq.l   #1,a1          ;naechster Punkt
line_rep_next45:  dbra     d0,line_rep_loop45
                  rts

line_solid45:     and.b    d5,(a1)
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_sld_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_solid45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_sld_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  ror.b    #4,d4
                  not.w    d5
                  cmp.b    #$0f,d5
                  bne.s    line_sld_next45
                  addq.l   #1,a1          ;naechster Punkt
line_sld_next45:  dbra     d0,line_solid45
                  rts

line_rev_trans45: not.w    d6             ;Linienstil invertieren
line_trans45:     rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_trans_w45 ;nicht gesetzt ?
                  and.b    d5,(a1)
                  or.b     d4,(a1)        ;schwarzen Punkt setzen
line_trans_w45:   adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_trans_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_trans45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_trans_x45:   add.w    d1,d3          ;e + 2dx-2dy
                  ror.b    #4,d4
                  not.w    d5
                  cmp.b    #$0f,d5
                  bne.s    line_trans_next45
                  addq.l   #1,a1          ;naechster Punkt
line_trans_next45:dbra     d0,line_trans45
                  rts

line_eor45:       not.b    d5
line_eor45_loop:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_w45   ;nicht gesetzt ?
                  eor.b    d5,(a1)
line_eor_w45:     adda.w   a3,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_eor_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_eor45_loop ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_eor_x45:     add.w    d1,d3          ;e + 2dx-2dy
                  not.b    d5
                  cmp.b    #$f0,d5
                  bne.s    line_eor_next45
                  addq.l   #1,a1          ;naechster Punkt
line_eor_next45:  dbra     d0,line_eor45_loop
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
fbox:             movea.l  v_bas_ad.w,a1  ;Bildadresse
relok8:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_universal

                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

fbox_universal:   sub.w    d1,d3          ;Zeilenzaehler

                  movea.l  buffer_addr(a6),a0 ;Bufferadresse
                  movea.l  f_pointer(a6),a4 ;Zeiger aufs Fuellmuster
                  move.w   d4,d6
                  muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse

                  move.w   wr_mode(a6),d7
                  bne.s    fbox_lwidth

                  tst.w    f_interior(a6) ;leeres Fuellmuster?
                  beq      fbox_white
                  cmpi.w   #F_SOLID,f_interior(a6)
                  beq      fbox_solid

fbox_lwidth:      move.w   d6,-(sp)       ;Bytes pro Zeile

                  moveq    #$fffffff8,d4
                  and.w    d0,d4
                  lsr.w    #1,d4
                  adda.w   d4,a1          ;Langwortadresse

                  moveq    #$fffffff8,d5
                  and.w    d2,d5
                  lsr.w    #1,d5
                  sub.w    d4,d5
                  ext.l    d5
                  ext.l    d6
                  lsl.w    #4,d6          ;Bytes pro 16 Zeilen
                  sub.w    d5,d6
                  movea.l  d6,a3          ;Abstand zu 17. Zeile

                  subq.w   #MD_TRANS-1,d7
                  beq      fbox_trans
                  subq.w   #MD_XOR-MD_TRANS,d7 ;EOR?
                  beq      fbox_eor
                  subq.w   #MD_ERASE-MD_XOR,d7
                  beq      fbox_rev_trans

                  lea      color_map_long(pc),a5
                  move.w   f_color(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a5,d7.w),d7  ;Farbmaske

                  move.l   a0,-(sp)       ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_repl_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #3,d1          ;*8
                  lea      0(a4,d1.w),a2

fbox_repl_fill1:  REPT 2
                  move.l   (a2)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_repl_fill1

fbox_repl_fill2:  REPT 2
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
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,d1
                  and.l    d7,d1          ;ausmaskieren
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_repl_fill3

fbox_repl_fill4:  REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
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


                  moveq    #8,d4
                  and.w    d0,d4
                  movea.l  fbox_repl_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d6,d5
                  movea.l  fbox_repl_emtab(pc,d5.w),a6 ;Endmaskenausgabe

                  bra.s    fbox_repl_mask

fbox_repl_smtab:  DC.L fbox_repl_sm0
                  DC.L 0
                  DC.L fbox_repl_sm1

fbox_repl_emtab:  DC.L fbox_repl_em1
                  DC.L 0
                  DC.L fbox_repl_em0

fbox_repl_sms:    DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

fbox_repl_ems:    DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

fbox_repl_mask:   moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_repl_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_repl_ems(pc,d6.w),d5 ;Endmaske

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    fbox_repl_vcnt2

                  cmpa.l   #fbox_repl_sm0,a2
                  beq.s    fbox_repl_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  subq.l   #4,a3
                  bra.s    fbox_repl_sh

fbox_repl_se:     cmpa.l   #fbox_repl_em0,a6
                  beq.s    fbox_repl_sh
                  and.l    d5,d4
                  moveq    #0,d5
                  subq.l   #4,a3

fbox_repl_sh:     lea      fbox_repl_m1(pc),a2

fbox_repl_vcnt2:  moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_repl_vcnt
                  move.w   d3,d0
fbox_repl_vcnt:   swap     d3
                  move.w   d0,d3

fbox_repl_bloop:  swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1


                  move.l   (a0)+,d6
                  move.l   (a0)+,d7

                  move.l   a1,-(sp)

fbox_repl_line:   jmp      (a2)

fbox_repl_m1:     or.l     d4,(a1)
                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0
                  bra.s    fbox_repl_next

fbox_repl_sm1:    or.l     d4,(a1)
                  move.l   d7,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_repl_hcount

fbox_repl_sm0:    or.l     d4,(a1)
                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

fbox_repl_sd7:    move.l   d7,(a1)+

fbox_repl_hcount: move.w   d2,d0
                  subq.w   #1,d0
                  bmi.s    fbox_repl_ejmp
fbox_repl_loop:   move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  dbra     d0,fbox_repl_loop

fbox_repl_ejmp:   jmp      (a6)

fbox_repl_em1:    move.l   d6,d0
                  bra.s    fbox_repl_next

fbox_repl_em0:    move.l   d6,(a1)+
                  move.l   d7,d0

fbox_repl_next:   or.l     d5,(a1)
                  not.l    d0
                  and.l    d5,d0
                  eor.l    d0,(a1)

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d1,fbox_repl_line

                  movea.l  (sp)+,a1
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_repl_bloop ;naechste Fuellmusterzeile

                  addq.l   #2,sp          ;Stackpointer korrigieren
                  rts


fbox_white:       moveq    #0,d7
                  bra.s    fbox_sld_addr
;a1.l Zieladresse
fbox_solid:       lea      color_map_long(pc),a5
                  move.w   f_color(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a5,d7.w),d7  ;Farbmaske

fbox_sld_addr:    moveq    #$fffffff8,d4
                  and.w    d0,d4
                  lsr.w    #1,d4
                  adda.w   d4,a1          ;Langwortadresse

                  movea.w  d6,a3

                  move.w   d2,d6          ;x2
                  lsr.w    #3,d2          ;x2 / 8
                  move.w   d0,d4
                  lsr.w    #3,d4          ;x1 / 8
                  sub.w    d4,d2          ;(Laenge in 8 Pixeln) - 1

                  bra.s    fbox_sld_mask

fbox_sld_sms:     DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

fbox_sld_ems:     DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

fbox_sld_mask:    moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_sld_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_sld_ems(pc,d6.w),d5 ;Endmaske

                  lea      fbox_sld_loop(pc),a2
                  move.w   d2,d0
                  subq.w   #2,d2
                  lsr.w    #1,d2
                  bcs.s    fbox_sld_cnt
                  addq.l   #2,a2
fbox_sld_cnt:     move.w   d0,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  suba.w   d1,a3
                  subq.w   #2,d0
                  bpl.s    fbox_sld_bloop

                  lea      fbox_sld_em(pc),a2
                  addq.w   #1,d0
                  beq.s    fbox_sld_bloop
                  subq.w   #4,a3
                  and.l    d5,d4
                  lea      fbox_sld_next(pc),a2

fbox_sld_bloop:
fbox_sld_line:    or.l     d4,(a1)
                  move.l   d7,d0
                  not.l    d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

                  move.w   d2,d0
                  jmp      (a2)

fbox_sld_loop:    move.l   d7,(a1)+
                  move.l   d7,(a1)+
                  dbra     d0,fbox_sld_loop

fbox_sld_em:      move.l   d7,d0
                  or.l     d5,(a1)
                  not.l    d0
                  and.l    d5,d0
                  eor.l    d0,(a1)

fbox_sld_next:    adda.w   a3,a1          ;naechste Zeile

                  dbra     d3,fbox_sld_bloop ;naechste Fuellmusterzeile

                  rts

fbox_trans:       lea      color_map_long(pc),a5
                  move.w   f_color(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a5,d7.w),d7

                  move.l   a0,-(sp)       ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_trans_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_trans_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #3,d1          ;*8
                  lea      0(a4,d1.w),a2

fbox_trans_fill1: REPT 2
                  move.l   (a2)+,(a0)+
                  ENDM
                  dbra     d5,fbox_trans_fill1

fbox_trans_fill2: REPT 2
                  move.l   (a4)+,(a0)+
                  ENDM
                  dbra     d6,fbox_trans_fill2
                  bra.s    fbox_trans_x2

fbox_trans_mono:  lea      expand_tab(pc),a6

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_trans_fill4

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_trans_fill3: REPT 2
                  moveq    #0,d1
                  move.b   (a2)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,(a0)+
                  ENDM
                  dbra     d5,fbox_trans_fill3

fbox_trans_fill4: REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,(a0)+
                  ENDM
                  dbra     d6,fbox_trans_fill4

fbox_trans_x2:    movea.l  (sp)+,a0

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  moveq    #8,d4
                  and.w    d0,d4
                  movea.l  fbox_trans_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d6,d5
                  movea.l  fbox_trans_emtab(pc,d5.w),a6 ;Endmaskenausgabe

                  bra.s    fbox_trans_mask

fbox_trans_smtab: DC.L fbox_trans_sm0
                  DC.L 0
                  DC.L fbox_trans_sm1

fbox_trans_emtab: DC.L fbox_trans_em1
                  DC.L 0
                  DC.L fbox_trans_em0

fbox_trans_sms:   DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

fbox_trans_ems:   DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

fbox_trans_mask:  moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_trans_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_trans_ems(pc,d6.w),d5 ;Endmaske

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    fbox_trans_vcnt2

                  cmpa.l   #fbox_trans_sm0,a2
                  beq.s    fbox_trans_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  subq.l   #4,a3
                  bra.s    fbox_trans_sh

fbox_trans_se:    cmpa.l   #fbox_trans_em0,a6
                  beq.s    fbox_trans_sh
                  and.l    d5,d4
                  moveq    #0,d5
                  subq.l   #4,a3

fbox_trans_sh:    lea      fbox_trans_m1(pc),a2

fbox_trans_vcnt2: moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_trans_vcnt
                  move.w   d3,d0
fbox_trans_vcnt:  swap     d3
                  move.w   d0,d3
                  move.l   d7,d1
                  not.l    d1

fbox_trans_bloop: swap     d3
                  move.w   d3,-(sp)
                  lsr.w    #4,d3

                  move.l   (a0)+,d6
                  move.l   (a0)+,d7

                  move.l   a1,-(sp)

fbox_trans_line:  jmp      (a2)

fbox_trans_m1:    move.l   d4,d0
                  and.l    d6,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0
                  bra.s    fbox_trans_next

fbox_trans_sm1:   move.l   d4,d0
                  and.l    d7,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_trans_hcount

fbox_trans_sm0:   move.l   d4,d0
                  and.l    d6,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)+

fbox_trans_sd7:   or.l     d7,(a1)
                  move.l   d7,d0
                  and.l    d1,d0
                  eor.l    d0,(a1)+

fbox_trans_hcount:move.l   d1,-(sp)
                  move.l   d1,d0
                  and.l    d6,d0
                  and.l    d7,d1
                  move.w   d2,-(sp)
                  subq.w   #1,d2
                  bmi.s    fbox_trans_ejmp
fbox_trans_loop:  or.l     d6,(a1)
                  eor.l    d0,(a1)+
                  or.l     d7,(a1)
                  eor.l    d1,(a1)+
                  dbra     d2,fbox_trans_loop

fbox_trans_ejmp:  move.w   (sp)+,d2
                  move.l   (sp)+,d1
                  jmp      (a6)

fbox_trans_em1:   move.l   d6,d0
                  bra.s    fbox_trans_next

fbox_trans_em0:   or.l     d6,(a1)
                  move.l   d6,d0
                  and.l    d1,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0

fbox_trans_next:  and.l    d5,d0
                  or.l     d0,(a1)
                  and.l    d1,d0
                  eor.l    d0,(a1)

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d3,fbox_trans_line
                  movea.l  (sp)+,a1
                  move.w   (sp)+,d3

                  adda.w   (sp),a1        ;naechste Zeile
                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_trans_bloop ;naechste Fuellmusterzeile

                  addq.l   #2,sp          ;Stackpointer korrigieren
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
;a3.l Abstand von 16 Zeilen abzueglich des zu zeichnenden Linie
;a6.l Workstation
;(sp).w Bytes pro Zeile
;Ausgaben:
;-
fbox_eor:         move.w   f_interior(a6),d6
                  beq      fbox_eor_exit  ;leer?

                  move.l   a0,-(sp)       ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_eor_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_eor_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #3,d1          ;*8
                  lea      0(a4,d1.w),a2

fbox_eor_fill1:   REPT 2
                  move.l   (a2)+,(a0)+
                  ENDM
                  dbra     d5,fbox_eor_fill1

fbox_eor_fill2:   REPT 2
                  move.l   (a4)+,(a0)+
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
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,(a0)+
                  ENDM
                  dbra     d5,fbox_eor_fill3

fbox_eor_fill4:   REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,(a0)+
                  ENDM
                  dbra     d6,fbox_eor_fill4

fbox_eor_x2:      movea.l  (sp)+,a0

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  moveq    #8,d4
                  and.w    d0,d4
                  movea.l  fbox_eor_smtab(pc,d4.w),a2 ;Startmaskenausgabe
                  moveq    #8,d5
                  and.w    d6,d5
                  movea.l  fbox_eor_emtab(pc,d5.w),a6 ;Endmaskenausgabe

                  bra.s    fbox_eor_mask

fbox_eor_smtab:   DC.L fbox_eor_sm0
                  DC.L 0
                  DC.L fbox_eor_sm1

fbox_eor_emtab:   DC.L fbox_eor_em1
                  DC.L 0
                  DC.L fbox_eor_em0

fbox_eor_sms:     DC.L $ffffffff

                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

fbox_eor_ems:     DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

fbox_eor_mask:    moveq    #7,d4
                  and.w    d4,d0
                  and.w    d4,d6
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   fbox_eor_sms(pc,d0.w),d4 ;Startmaske
                  move.l   fbox_eor_ems(pc,d6.w),d5 ;Endmaske

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    fbox_eor_vcnt2

                  cmpa.l   #fbox_eor_sm0,a2
                  beq.s    fbox_eor_se
                  and.l    d4,d5
                  moveq    #0,d4
                  subq.l   #4,a1
                  subq.l   #4,a3
                  bra.s    fbox_eor_sh

fbox_eor_se:      cmpa.l   #fbox_eor_em0,a6
                  beq.s    fbox_eor_sh
                  and.l    d5,d4
                  moveq    #0,d5
                  subq.l   #4,a3

fbox_eor_sh:      lea      fbox_eor_m1(pc),a2

fbox_eor_vcnt2:   moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_eor_vcnt
                  move.w   d3,d0
fbox_eor_vcnt:    swap     d3
                  move.w   d0,d3

fbox_eor_bloop:   swap     d3
                  move.w   d3,d1
                  lsr.w    #4,d1

                  move.l   (a0)+,d6
                  move.l   (a0)+,d7

                  move.l   a1,-(sp)

fbox_eor_line:    jmp      (a2)

fbox_eor_m1:      move.l   d6,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  move.l   d7,d0
                  bra.s    fbox_eor_next

fbox_eor_sm1:     move.l   d7,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+
                  bra.s    fbox_eor_hcount

fbox_eor_sm0:     move.l   d6,d0
                  and.l    d4,d0
                  eor.l    d0,(a1)+

fbox_eor_sd7:     eor.l    d7,(a1)+

fbox_eor_hcount:  move.w   d2,d0
                  subq.w   #1,d0
                  bmi.s    fbox_eor_ejmp
fbox_eor_loop:    eor.l    d6,(a1)+
                  eor.l    d7,(a1)+
                  dbra     d0,fbox_eor_loop

fbox_eor_ejmp:    jmp      (a6)

fbox_eor_em1:     move.l   d6,d0
                  bra.s    fbox_eor_next

fbox_eor_em0:     eor.l    d6,(a1)+
                  move.l   d7,d0


fbox_eor_next:    and.l    d5,d0
                  eor.l    d0,(a1)

                  adda.l   a3,a1          ;16 Zeilen weiter
                  dbra     d1,fbox_eor_line

                  movea.l  (sp)+,a1
                  adda.w   (sp),a1        ;naechste Zeile

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_eor_bloop ;naechste Fuellmusterzeile

fbox_eor_exit:    addq.l   #2,sp          ;Stackpointer korrigieren
                  rts

fbox_rev_trans:   lea      color_map_long(pc),a5
                  move.w   f_color(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a5,d7.w),d7

                  move.l   a0,-(sp)       ;Bufferadresse

                  tst.w    f_planes(a6)   ;mehrere Ebenen?
                  beq.s    fbox_rtr_mono

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_rtr_fill2

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #3,d1          ;*8
                  lea      0(a4,d1.w),a2

fbox_rtr_fill1:   REPT 2
                  move.l   (a2)+,d1
                  not.l    d1
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_rtr_fill1

fbox_rtr_fill2:   REPT 2
                  move.l   (a4)+,d1
                  not.l    d1
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d6,fbox_rtr_fill2
                  bra      fbox_trans_x2

fbox_rtr_mono:    lea      expand_tab(pc),a6

                  moveq    #15,d6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_rtr_fill4

                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  add.w    d1,d1
                  lea      0(a4,d1.w),a2

fbox_rtr_fill3:   REPT 2
                  moveq    #0,d1
                  move.b   (a2)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,d1
                  not.l    d1
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d5,fbox_rtr_fill3

fbox_rtr_fill4:   REPT 2
                  moveq    #0,d1
                  move.b   (a4)+,d1
                  lsl.w    #2,d1
                  movea.l  a6,a5
                  adda.w   d1,a5
                  move.l   (a5)+,d1
                  not.l    d1
                  move.l   d1,(a0)+
                  ENDM
                  dbra     d6,fbox_rtr_fill4

                  bra      fbox_trans_x2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Expand-Blt'

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
;a6.l r_wmode, r_fgcol, r_bgcol, r_saddr, r_daddr, r_swidth, r_dwidth, r_dplanes
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
expand_blt:       move.w   a2,d6
                  muls     d6,d1
                  adda.l   d1,a0          ;Quellzeilenadresse
                  move.w   d0,d1
                  lsr.w    #3,d1
                  adda.w   d1,a0          ;Quelladresse

                  moveq    #7,d6
                  moveq    #7,d7

                  and.w    d7,d0
                  and.w    d2,d6
                  sub.w    d6,d0          ;Shifts der Quelle nach links
                  add.w    d2,d4          ;zx2
                  and.w    d4,d7

                  moveq    #$fffffff8,d1
                  and.w    d1,d2
                  lsr.w    #1,d2          ;Abstand zum Zeilenanfang in Bytes (auf Langwortgrenze)
                  and.w    d1,d4
                  lsr.w    #1,d4

                  move.w   a3,d1
                  muls     d1,d3
                  adda.l   d3,a1          ;Zielzeilenadresse
                  adda.w   d2,a1          ;Zieladresse

                  sub.w    d2,d4          ;Byteanzahl - 1
                  suba.w   d4,a3
                  subq.w   #4,a3          ;Abstand zur naechsten Zielzeile

                  lsr.w    #2,d4          ;Langwortanzahl - 1
                  suba.w   d4,a2
                  subq.w   #1,a2          ;Abstand zur naechsten Quellzeile

                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   eblt_smask(pc,d6.w),d2 ;Startmaske
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   eblt_emask(pc,d7.w),d3 ;Endmaske

                  subq.w   #1,d4
                  bpl.s    exp_tab
                  and.l    d3,d2
                  moveq    #0,d3

exp_tab:          lea      expand_tab(pc),a4

                  lea      color_map_long(pc),a5
                  move.w   r_fgcol(a6),d6
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   0(a5,d6.w),d6
                  move.w   r_bgcol(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a5,d7.w),d7

                  move.w   d0,d1
                  bmi.s    eblt_right
                  bne.s    eblt_left

                  move.w   r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   eblt_tab(pc,d0.w),d0
                  jmp      eblt_tab(pc,d0.w)

eblt_tab:         DC.W eblt_repl-eblt_tab
                  DC.W eblt_trans-eblt_tab
                  DC.W eblt_eor-eblt_tab
                  DC.W eblt_rtr-eblt_tab

eblt_smask:       DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

eblt_emask:       DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

eblt_left:        eori.w   #7,d1
                  addq.w   #1,d1

                  move.w   r_wmode(a6),d0
                  add.w    d0,d0
                  tst.w    cpu020
                  beq.s    eblt_left_o
                  move.w   eblt_tab_l(pc,d0.w),d0
                  jmp      eblt_tab_l(pc,d0.w)

eblt_tab_l:       DC.W eblt_repl_l-eblt_tab_l
                  DC.W eblt_trans_l-eblt_tab_l
                  DC.W eblt_eor_l-eblt_tab_l
                  DC.W eblt_rtr_l-eblt_tab_l

eblt_right:       neg.w    d1

                  move.w   r_wmode(a6),d0
                  add.w    d0,d0
                  tst.w    cpu020
                  beq.s    eblt_right_o
                  move.w   eblt_tab_r(pc,d0.w),d0
                  jmp      eblt_tab_r(pc,d0.w)

eblt_tab_r:       DC.W eblt_repl_r-eblt_tab_r
                  DC.W eblt_trans_r-eblt_tab_r
                  DC.W eblt_eor_r-eblt_tab_r
                  DC.W eblt_rtr_r-eblt_tab_r

eblt_left_o:      move.w   eblto_tab_l(pc,d0.w),d0
                  jmp      eblto_tab_l(pc,d0.w)

eblto_tab_l:      DC.W eblto_repl_l-eblto_tab_l
                  DC.W eblto_trans_l-eblto_tab_l
                  DC.W eblto_eor_l-eblto_tab_l
                  DC.W eblto_rtr_l-eblto_tab_l

eblt_right_o:     tst.w    d4
                  bpl.s    eblt_right_off
                  addq.w   #1,a2
eblt_right_off:   move.w   eblto_tab_r(pc,d0.w),d0
                  jmp      eblto_tab_r(pc,d0.w)

eblto_tab_r:      DC.W eblto_repl_r-eblto_tab_r
                  DC.W eblto_trans_r-eblto_tab_r
                  DC.W eblto_eor_r-eblto_tab_r
                  DC.W eblto_rtr_r-eblto_tab_r

eblt_repl:        tst.w    d7
                  bne      eblt_repl_bloop
                  cmp.w    #$ffff,d6
                  bne      eblt_repl_bloop

eblt_blk_bloop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_black_next
                  subq.w   #1,d6
                  bmi.s    eblt_black_em
eblt_blk_loop:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),(a1)+
                  dbra     d6,eblt_blk_loop

eblt_black_em:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_black_next:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_blk_bloop
                  rts

eblt_repl_l:      movea.l  d6,a5
                  tst.w    d7
                  bne      eblt_repl_bloop_l
                  cmp.w    #$ffff,d6
                  bne      eblt_repl_bloop_l

eblt_blk_bloop_l: move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_black_next_l
                  subq.w   #1,d6
                  bmi.s    eblt_black_em_l
eblt_blk_loop_l:  move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),(a1)+
                  dbra     d6,eblt_blk_loop_l

eblt_black_em_l:  move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_black_next_l:adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_blk_bloop_l
                  rts

eblt_repl_r:      movea.l  d6,a5
                  tst.w    d7
                  bne      eblt_repl_bloop_r
                  cmp.w    #$ffff,d6
                  bne      eblt_repl_bloop_r

eblt_blk_bloop_r: moveq    #0,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_black_next_r
                  subq.w   #1,d6
                  bmi.s    eblt_black_em_r
eblt_blk_loop_r:  subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),(a1)+
                  dbra     d6,eblt_blk_loop_r

eblt_black_em_r:  subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_black_next_r:adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_blk_bloop_r
                  rts

eblt_repl_bloop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,-(sp)
                  bmi.s    eblt_repl_next
                  subq.w   #1,d4
                  bmi.s    eblt_repl_em
eblt_repl_loop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblt_repl_loop

eblt_repl_em:     moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_repl_next:   adda.w   a2,a0
                  adda.w   a3,a1
                  move.w   (sp)+,d4
                  dbra     d5,eblt_repl_bloop
                  rts

eblt_repl_bloop_l:move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,-(sp)
                  bmi.s    eblt_repl_next_l
                  subq.w   #1,d4
                  bmi.s    eblt_repl_em_l
eblt_repl_loop_l: move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblt_repl_loop_l

eblt_repl_em_l:   move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_repl_next_l: adda.w   a2,a0
                  adda.w   a3,a1
                  move.w   (sp)+,d4
                  dbra     d5,eblt_repl_bloop_l
                  rts

eblt_repl_bloop_r:moveq    #0,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,-(sp)
                  bmi.s    eblt_repl_next_r
                  subq.w   #1,d4
                  bmi.s    eblt_repl_em_r
eblt_repl_loop_r: subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblt_repl_loop_r

eblt_repl_em_r:   subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_repl_next_r: adda.w   a2,a0
                  adda.w   a3,a1
                  move.w   (sp)+,d4
                  dbra     d5,eblt_repl_bloop_r
                  rts

eblt_trans:       not.l    d6
eblt_trans_bloop: moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    eblt_trans_next
                  subq.w   #1,d7
                  bmi.s    eblt_trans_em
eblt_trans_loop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,eblt_trans_loop

eblt_trans_em:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

eblt_trans_next:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_trans_bloop
                  rts

eblt_trans_l:     not.l    d6
eblt_trans_bloop_l:move.w  (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    eblt_trans_next_l
                  subq.w   #1,d7
                  bmi.s    eblt_trans_em_l
eblt_trans_loop_l:move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,eblt_trans_loop_l

eblt_trans_em_l:  move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

eblt_trans_next_l:adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_trans_bloop_l
                  rts

eblt_trans_r:     not.l    d6
eblt_trans_bloop_r:moveq   #0,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    eblt_trans_next_r
                  subq.w   #1,d7
                  bmi.s    eblt_trans_em_r
eblt_trans_loop_r:subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,eblt_trans_loop_r

eblt_trans_em_r:  subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

eblt_trans_next_r:adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_trans_bloop_r
                  rts

eblt_eor:         moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_eor_next
                  subq.w   #1,d6
                  bmi.s    eblt_eor_em
eblt_eor_loop:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_eor_loop

eblt_eor_em:      moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_eor_next:    adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_eor
                  rts

eblt_eor_l:       move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_eor_next_l
                  subq.w   #1,d6
                  bmi.s    eblt_eor_em_l
eblt_eor_loop_l:  move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_eor_loop_l

eblt_eor_em_l:    move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_eor_next_l:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_eor_l
                  rts

eblt_eor_r:       moveq    #0,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_eor_next_r
                  subq.w   #1,d6
                  bmi.s    eblt_eor_em_r
eblt_eor_loop_r:  subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_eor_loop_r

eblt_eor_em_r:    subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblt_eor_next_r:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_eor_r
                  rts

eblt_rtr:         not.l    d7
eblt_rtr_bloop:   moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_rtr_next
                  subq.w   #1,d6
                  bmi.s    eblt_rtr_em
eblt_rtr_loop:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_rtr_loop

eblt_rtr_em:      moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

eblt_rtr_next:    adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_rtr_bloop
                  rts

eblt_rtr_l:       not.l    d7
eblt_rtr_bloop_l: move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_rtr_next_l
                  subq.w   #1,d6
                  bmi.s    eblt_rtr_em_l
eblt_rtr_loop_l:  move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_rtr_loop_l

eblt_rtr_em_l:    move.w   (a0),d0
                  addq.l   #1,a0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

eblt_rtr_next_l:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_rtr_bloop_l
                  rts

eblt_rtr_r:       not.l    d7
eblt_rtr_bloop_r: moveq    #0,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblt_rtr_next_r
                  subq.w   #1,d6
                  bmi.s    eblt_rtr_em_r
eblt_rtr_loop_r:  subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblt_rtr_loop_r

eblt_rtr_em_r:    subq.l   #1,a0
                  move.w   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

eblt_rtr_next_r:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_rtr_bloop_r
                  rts


eblto_repl_l:     movea.l  d6,a5
                  tst.w    d7
                  bne      eblto_repl_bloop_l
                  cmp.w    #$ffff,d6
                  bne      eblto_repl_bloop_l

eblto_blk_bloop_l:move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_black_next_l
                  subq.w   #1,d6
                  bmi.s    eblto_black_em_l
eblto_blk_loop_l: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),(a1)+
                  dbra     d6,eblto_blk_loop_l

eblto_black_em_l: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_black_next_l:adda.w  a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_blk_bloop_l
                  rts

eblto_repl_r:     movea.l  d6,a5
                  tst.w    d7
                  bne      eblto_repl_bloop_r
                  cmp.w    #$ffff,d6
                  bne      eblto_repl_bloop_r

eblto_blk_bloop_r:moveq    #0,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_black_next_r
                  subq.w   #1,d6
                  bmi.s    eblto_black_em_r
eblto_blk_loop_r: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),(a1)+
                  dbra     d6,eblto_blk_loop_r

eblto_black_em_r: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0

                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_black_next_r:adda.w  a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_blk_bloop_r
                  rts

eblto_repl_bloop_l:move.b  (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,-(sp)
                  bmi.s    eblto_repl_next_l
                  subq.w   #1,d4
                  bmi.s    eblto_repl_em_l
eblto_repl_loop_l:move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblto_repl_loop_l

eblto_repl_em_l:  move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_repl_next_l:adda.w   a2,a0
                  adda.w   a3,a1
                  move.w   (sp)+,d4
                  dbra     d5,eblto_repl_bloop_l
                  rts

eblto_repl_bloop_r:moveq   #0,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,-(sp)
                  bmi.s    eblto_repl_next_r
                  subq.w   #1,d4
                  bmi.s    eblto_repl_em_r
eblto_repl_loop_r:move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  move.l   d0,(a1)+
                  dbra     d4,eblto_repl_loop_r

eblto_repl_em_r:  move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  move.l   a5,d6
                  and.l    d0,d6
                  not.l    d0
                  and.l    d7,d0
                  or.l     d6,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_repl_next_r:adda.w   a2,a0
                  adda.w   a3,a1
                  move.w   (sp)+,d4
                  dbra     d5,eblto_repl_bloop_r
                  rts

eblto_trans_l:    not.l    d6
eblto_trans_bloop_l:move.b (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    eblto_trans_next_l
                  subq.w   #1,d7
                  bmi.s    eblto_trans_em_l
eblto_trans_loop_l:move.b  (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,eblto_trans_loop_l

eblto_trans_em_l: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

eblto_trans_next_l:adda.w  a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_trans_bloop_l
                  rts

eblto_trans_r:    not.l    d6
eblto_trans_bloop_r:moveq  #0,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    eblto_trans_next_r
                  subq.w   #1,d7
                  bmi.s    eblto_trans_em_r
eblto_trans_loop_r:move.b  (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,eblto_trans_loop_r

eblto_trans_em_r: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

eblto_trans_next_r:adda.w  a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_trans_bloop_r
                  rts

eblto_eor_l:      move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_eor_next_l
                  subq.w   #1,d6
                  bmi.s    eblto_eor_em_l
eblto_eor_loop_l: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblto_eor_loop_l

eblto_eor_em_l:   move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_eor_next_l: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_eor_l
                  rts

eblto_eor_r:      moveq    #0,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_eor_next_r
                  subq.w   #1,d6
                  bmi.s    eblto_eor_em_r
eblto_eor_loop_r: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblto_eor_loop_r

eblto_eor_em_r:   move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

eblto_eor_next_r: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_eor_r
                  rts

eblto_rtr_l:      not.l    d7
eblto_rtr_bloop_l:move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_rtr_next_l
                  subq.w   #1,d6
                  bmi.s    eblto_rtr_em_l
eblto_rtr_loop_l: move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblto_rtr_loop_l

eblto_rtr_em_l:   move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

eblto_rtr_next_l: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_rtr_bloop_l
                  rts

eblto_rtr_r:      not.l    d7
eblto_rtr_bloop_r:moveq    #0,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    eblto_rtr_next_r
                  subq.w   #1,d6
                  bmi.s    eblto_rtr_em_r
eblto_rtr_loop_r: move.b   (a0)+,d0

                  lsl.w    #8,d0
                  move.b   (a0),d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,eblto_rtr_loop_r

eblto_rtr_em_r:   move.b   (a0)+,d0
                  lsl.w    #8,d0
                  move.b   (a0)+,d0
                  lsr.w    d1,d0
                  and.w    #$ff,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a4,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

eblto_rtr_next_r: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblto_rtr_bloop_r
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
                  bne.s    bitblt_exit

bitblt_in:        add.w    d0,d0
                  add.w    d0,d0
                  add.w    d2,d2
                  add.w    d2,d2
                  add.w    d4,d4
                  add.w    d4,d4
                  addq.w   #3,d4

;Bitblocktransfer von Byte-Pixeln
;Vorgaben:
;Register d0-a6 werden veraendert
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
bitblt_mono:      lsl.w    #3,d7          ;*8

                  movea.l  a0,a4
                  movea.l  a1,a5

;Quelladresse berechnen
                  move.w   a2,d6          ;Bytes pro Zeile
                  mulu     d1,d6          ;* y-Quelle
                  adda.l   d6,a0          ;Zeilenanfang
                  move.w   d0,d6          ;x-Quelle
                  lsr.w    #4,d6
                  add.w    d6,d6
                  adda.w   d6,a0          ;Startadresse

;Zieladresse berechnen
                  move.w   a3,d6          ;Bytes pro Zeile
                  mulu     d3,d6          ;* y-Ziel
                  adda.l   d6,a1          ;Zeilenanfang
                  move.w   d2,d6          ;x-Ziel
                  lsr.w    #4,d6
                  add.w    d6,d6
                  adda.w   d6,a1          ;Startadresse

                  cmpa.l   a1,a0          ;Quelladresse > Zieladresse
                  bhi.s    bitblt_inc
                  beq.s    bitblt_equal

                  adda.w   a2,a0
                  cmpa.l   a0,a1
                  bcs      bitblt_dec
                  suba.w   a2,a0

                  move.w   a2,d6
                  mulu     d5,d6
                  adda.l   d6,a0
                  move.w   a3,d6
                  mulu     d5,d6
                  adda.l   d6,a1

                  move.w   a2,d6
                  neg.w    d6
                  movea.w  d6,a2
                  move.w   a3,d6
                  neg.w    d6
                  movea.w  d6,a3
                  bra.s    bitblt_inc

bitblt_equal:     moveq    #15,d6
                  and.w    d0,d6
                  move.w   d6,-(sp)
                  moveq    #15,d6
                  and.w    d2,d6
                  sub.w    (sp)+,d6
                  bgt      bitblt_dec
                  bne.s    bitblt_inc
                  cmpa.w   a2,a3
                  bgt      bitblt_dec

bitblt_inc:       movea.w  d7,a5          ;Verknuepfung * 8

                  moveq    #15,d6         ;zum ausmaskieren

                  and.w    d6,d0
                  move.w   d0,d7
                  add.w    d4,d7
                  lsr.w    #4,d7          ;Quellwortanzahl -1

                  move.w   d2,d3
                  and.w    d6,d3
                  sub.w    d3,d0          ;Shifts nach links

                  move.w   d2,d1
                  and.w    d6,d1
                  add.w    d4,d1
                  lsr.w    #4,d1          ;Zielwortanzahl -1

                  sub.w    d1,d7          ;Quellwortanzahl - Zielwortanzahl

                  add.w    d2,d4
                  not.w    d4
                  and.w    d6,d4
                  moveq    #$ffffffff,d3
                  lsl.w    d4,d3          ;Endmaske
                  and.w    d2,d6
                  moveq    #$ffffffff,d2
                  lsr.w    d6,d2          ;Startmaske

                  move.w   d1,d4
                  add.w    d4,d4          ;Zielbyteanzahl - 2
                  suba.w   d4,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d4,a3          ;Abstand zur naechsten Zielzeile

                  move.w   d7,d4          ;Quellwortanzahl - Zielwortanzahl

                  moveq    #4,d6          ;Sprungoffset fuers Einlesen des Startwort
                  moveq    #0,d7          ;Sprungoffset fuers Einlesen des Endworts

                  lea      blt_inc_tab(pc),a4

                  tst.w    d0             ;keine Shifts?
                  beq.s    blt_inc_jmp
                  blt.s    blt_inc_right

blt_inc_left:     lea      blt_inc_l_tab(pc),a4

                  tst.w    d1             ;nur ein Zielwort?
                  bne.s    blt_inc_l_end
                  tst.w    d4             ;nur ein Quellwort?
                  bne.s    blt_inc_l_end
                  moveq    #10,d6         ;dann nur ein Startwort einlesen
                  bra.s    blt_inc_jmp

blt_inc_l_end:    moveq    #4,d6          ;zwei Startwoerter einlesen
                  subq.w   #2,a2          ;daher 2 zusaetzliche Quellbytes
                  tst.w    d4             ;mehr Quell- als Zielworte?
                  bgt.s    blt_inc_l_shifts
                  moveq    #2,d7          ;bei gleicher Wortanzahl kein Endwort einlesen
blt_inc_l_shifts: cmp.w    #8,d0          ;nicht mehr als 8 Verschiebungen nach links?
                  ble.s    blt_inc_jmp

                  lea      blt_inc_r_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebung nach rechts
                  bra.s    blt_inc_jmp

blt_inc_right:    lea      blt_inc_r_tab(pc),a4
                  neg.w    d0             ;Verschiebungen nach rechts
                  moveq    #8,d6          ;nur ein Startwort einlesen
                  tst.w    d4
                  bpl.s    blt_inc_r_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mehr Zielbytes vorhanden sind
blt_inc_r_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach rechts?
                  ble.s    blt_inc_jmp

                  lea      blt_inc_l_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebung nach links

blt_inc_jmp:      adda.l   a4,a5          ;Zeiger in Abstandstabelle

                  move.w   (a5)+,d4       ;Abstand zur BitBlt-Funktion
                  add.w    d4,d6          ;Offset fuer den ersten Sprung
                  add.w    (a5)+,d7       ;Offset fuer den zweiten Sprung

                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_inc_offsets

                  move.w   (a5),d7        ;kein Endwort lesen und schreiben

                  and.w    d3,d2          ;Start- und Endmaske
                  moveq    #0,d3
                  moveq    #0,d1          ;Wortzaehler
                  subq.w   #2,a2
                  subq.w   #2,a3

blt_inc_offsets:  subq.w   #2,d1
                  lea      blt_inc_tab(pc),a4
                  lea      blt_inc_tab(pc),a5
                  adda.w   d6,a4
                  adda.w   d7,a5

                  jmp      blt_inc_tab(pc,d4.w)

blt_inc_tab:      DC.W blt_inc_0-blt_inc_tab,blt_inc_last_0-blt_inc_tab,blt_inc_next_0-blt_inc_tab,0
                  DC.W blt_inc_1-blt_inc_tab,blt_inc_last_1-blt_inc_tab,blt_inc_next_1-blt_inc_tab,0
                  DC.W blt_inc_2-blt_inc_tab,blt_inc_last_2-blt_inc_tab,blt_inc_next_2-blt_inc_tab,0
                  DC.W blt_inc_3-blt_inc_tab,0,0,0
                  DC.W blt_inc_4-blt_inc_tab,blt_inc_last_4-blt_inc_tab,blt_inc_next_4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,blt_inc_last_5-blt_inc_tab,blt_inc_next_5-blt_inc_tab,0
                  DC.W blt_inc_6-blt_inc_tab,blt_inc_last_6-blt_inc_tab,blt_inc_next_6-blt_inc_tab,0

                  DC.W blt_inc_7-blt_inc_tab,blt_inc_last_7-blt_inc_tab,blt_inc_next_7-blt_inc_tab,0
                  DC.W blt_inc_8-blt_inc_tab,blt_inc_last_8-blt_inc_tab,blt_inc_next_8-blt_inc_tab,0
                  DC.W blt_inc_9-blt_inc_tab,blt_inc_last_9-blt_inc_tab,blt_inc_next_9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,blt_inc_last_10-blt_inc_tab,blt_inc_next_10-blt_inc_tab,0
                  DC.W blt_inc_11-blt_inc_tab,blt_inc_last_11-blt_inc_tab,blt_inc_next_11-blt_inc_tab,0
                  DC.W blt_inc_12-blt_inc_tab,blt_inc_last_12-blt_inc_tab,blt_inc_next_12-blt_inc_tab,0
                  DC.W blt_inc_13-blt_inc_tab,blt_inc_last_13-blt_inc_tab,blt_inc_next_13-blt_inc_tab,0
                  DC.W blt_inc_14-blt_inc_tab,blt_inc_last_14-blt_inc_tab,blt_inc_next_14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,blt_inc_last_15-blt_inc_tab,blt_inc_next_15-blt_inc_tab,0

blt_inc_l_tab:    DC.W blt_inc_0-blt_inc_tab,blt_inc_last_0-blt_inc_tab,blt_inc_next_0-blt_inc_tab,0
                  DC.W blt_inc_l1-blt_inc_tab,blt_inc_last_l1-blt_inc_tab,blt_inc_next_l1-blt_inc_tab,0
                  DC.W blt_inc_l2-blt_inc_tab,blt_inc_last_l2-blt_inc_tab,blt_inc_next_l2-blt_inc_tab,0
                  DC.W blt_inc_l3-blt_inc_tab,blt_inc_last_l3-blt_inc_tab,blt_inc_next_l3-blt_inc_tab,0
                  DC.W blt_inc_l4-blt_inc_tab,blt_inc_last_l4-blt_inc_tab,blt_inc_next_l4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,blt_inc_last_5-blt_inc_tab,blt_inc_next_5-blt_inc_tab,0
                  DC.W blt_inc_l6-blt_inc_tab,blt_inc_last_l6-blt_inc_tab,blt_inc_next_l6-blt_inc_tab,0
                  DC.W blt_inc_l7-blt_inc_tab,blt_inc_last_l7-blt_inc_tab,blt_inc_next_l7-blt_inc_tab,0
                  DC.W blt_inc_l8-blt_inc_tab,blt_inc_last_l8-blt_inc_tab,blt_inc_next_l8-blt_inc_tab,0
                  DC.W blt_inc_l9-blt_inc_tab,blt_inc_last_l9-blt_inc_tab,blt_inc_next_l9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,blt_inc_last_10-blt_inc_tab,blt_inc_next_10-blt_inc_tab,0
                  DC.W blt_inc_l11-blt_inc_tab,blt_inc_last_l11-blt_inc_tab,blt_inc_next_l11-blt_inc_tab,0
                  DC.W blt_inc_l12-blt_inc_tab,blt_inc_last_l12-blt_inc_tab,blt_inc_next_l12-blt_inc_tab,0
                  DC.W blt_inc_l13-blt_inc_tab,blt_inc_last_l13-blt_inc_tab,blt_inc_next_l13-blt_inc_tab,0
                  DC.W blt_inc_l14-blt_inc_tab,blt_inc_last_l14-blt_inc_tab,blt_inc_next_l14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,blt_inc_last_15-blt_inc_tab,blt_inc_next_15-blt_inc_tab,0

blt_inc_r_tab:    DC.W blt_inc_0-blt_inc_tab,blt_inc_last_0-blt_inc_tab,blt_inc_next_0-blt_inc_tab,0
                  DC.W blt_inc_r1-blt_inc_tab,blt_inc_last_r1-blt_inc_tab,blt_inc_next_r1-blt_inc_tab,0
                  DC.W blt_inc_r2-blt_inc_tab,blt_inc_last_r2-blt_inc_tab,blt_inc_next_r2-blt_inc_tab,0
                  DC.W blt_inc_r3-blt_inc_tab,blt_inc_last_r3-blt_inc_tab,blt_inc_next_r3-blt_inc_tab,0
                  DC.W blt_inc_r4-blt_inc_tab,blt_inc_last_r4-blt_inc_tab,blt_inc_next_r4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,blt_inc_last_5-blt_inc_tab,blt_inc_next_5-blt_inc_tab,0
                  DC.W blt_inc_r6-blt_inc_tab,blt_inc_last_r6-blt_inc_tab,blt_inc_next_r6-blt_inc_tab,0
                  DC.W blt_inc_r7-blt_inc_tab,blt_inc_last_r7-blt_inc_tab,blt_inc_next_r7-blt_inc_tab,0
                  DC.W blt_inc_r8-blt_inc_tab,blt_inc_last_r8-blt_inc_tab,blt_inc_next_r8-blt_inc_tab,0
                  DC.W blt_inc_r9-blt_inc_tab,blt_inc_last_r9-blt_inc_tab,blt_inc_next_r9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,blt_inc_last_10-blt_inc_tab,blt_inc_next_10-blt_inc_tab,0
                  DC.W blt_inc_r11-blt_inc_tab,blt_inc_last_r11-blt_inc_tab,blt_inc_next_r11-blt_inc_tab,0
                  DC.W blt_inc_r12-blt_inc_tab,blt_inc_last_r12-blt_inc_tab,blt_inc_next_r12-blt_inc_tab,0
                  DC.W blt_inc_r13-blt_inc_tab,blt_inc_last_r13-blt_inc_tab,blt_inc_next_r13-blt_inc_tab,0
                  DC.W blt_inc_r14-blt_inc_tab,blt_inc_last_r14-blt_inc_tab,blt_inc_next_r14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,blt_inc_last_15-blt_inc_tab,blt_inc_next_15-blt_inc_tab,0

blt_inc_0:        not.w    d2
                  not.w    d3
                  moveq    #0,d7
                  lea      blt_inc_next_0(pc),a5
                  cmp.w    #$ffff,d3
                  beq.s    blt_inc_bloop_0
                  lea      blt_inc_last_0(pc),a5

blt_inc_bloop_0:  and.w    d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_0

blt_inc_loop_0:   move.w   d7,(a1)+
                  dbra     d4,blt_inc_loop_0

blt_inc_jmp_0:    jmp      (a5)
blt_inc_last_0:   and.w    d3,(a1)

blt_inc_next_0:   adda.w   a3,a1
                  dbra     d5,blt_inc_bloop_0
                  not.w    d2
                  not.w    d3
                  rts

blt_inc_1:        move.w   (a0)+,d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_1

blt_inc_loop_1:   move.w   (a0)+,d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_1

blt_inc_jmp_1:    jmp      (a5)
blt_inc_last_1:   move.w   (a0),d6
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

blt_inc_next_1:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_1
                  rts

blt_inc_r1:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r1

blt_inc_loop_r1:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_r1

blt_inc_jmp_r1:   swap     d7
                  jmp      (a5)
blt_inc_last_r1:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)

blt_inc_next_r1:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r1
                  rts

blt_inc_l1:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l1

blt_inc_loop_l1:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_l1

blt_inc_jmp_l1:   jmp      (a5)
blt_inc_last_l1:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)

blt_inc_next_l1:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l1
                  rts

blt_inc_2:        move.w   (a0)+,d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_2

blt_inc_loop_2:   move.w   (a0)+,d6
                  not.w    (a1)
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_2

blt_inc_jmp_2:    jmp      (a5)
blt_inc_last_2:   move.w   (a0),d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

blt_inc_next_2:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_2
                  rts

blt_inc_r2:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r2

blt_inc_loop_r2:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_r2

blt_inc_jmp_r2:   swap     d7
                  jmp      (a5)
blt_inc_last_r2:  move.w   (a0),d7
                  ror.l    d0,d7
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)

blt_inc_next_r2:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r2
                  rts

blt_inc_l2:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l2

blt_inc_loop_l2:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_l2

blt_inc_jmp_l2:   jmp      (a5)
blt_inc_last_l2:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)

blt_inc_next_l2:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l2
                  rts

blt_inc_3:        move.w   d1,d4
                  bmi      blt_inc_long_3

                  lsr.w    #1,d4
                  bcs.s    blt_inc_count_3
                  lea      blt_inc_aword_3(pc),a4
                  bne.s    blt_inc_word_off_3

                  lea      blt_inc_last_3(pc),a5
                  bra.s    blt_inc_bloop_3

blt_inc_word_off_3:subq.w  #1,d4
                  move.w   d4,d0
                  lsr.w    #4,d4
                  move.w   d4,d1
                  not.w    d0
                  andi.w   #15,d0
                  add.w    d0,d0
                  lea      blt_inc_loop_3(pc,d0.w),a5
                  bra.s    blt_inc_bloop_3

blt_inc_count_3:  move.w   d4,d0
                  lsr.w    #4,d4
                  move.w   d4,d1
                  not.w    d0
                  andi.w   #15,d0
                  add.w    d0,d0
                  lea      blt_inc_loop_3(pc,d0.w),a4

blt_inc_bloop_3:  move.w   (a0)+,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+

                  move.w   d1,d4

                  jmp      (a4)
blt_inc_aword_3:  move.w   (a0)+,(a1)+
                  jmp      (a5)
blt_inc_loop_3:   REPT 16
                  move.l   (a0)+,(a1)+
                  ENDM
                  dbra     d4,blt_inc_loop_3

blt_inc_last_3:   move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_bloop_3
                  rts

blt_inc_long_3:   addq.w   #2,a2
                  addq.w   #2,a3
                  tst.w    d3
                  beq.s    blt_inc_word_3
                  swap     d2
                  move.w   d3,d2
                  move.l   d2,d3
                  not.l    d3

blt_inc_loopl_3:  move.l   (a0),d6
                  and.l    d2,d6
                  and.l    d3,(a1)
                  or.l     d6,(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_loopl_3
                  rts

blt_inc_word_3:   move.w   d2,d3
                  not.w    d3
blt_inc_loopw_3:  move.w   (a0),d6
                  and.w    d2,d6
                  and.w    d3,(a1)
                  or.w     d6,(a1)

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_loopw_3
                  rts

blt_inc_r3:       move.w   (a0)+,d6

                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  swap     d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+

                  swap     d5
                  move.w   d1,d5
                  bmi.s    blt_inc_swap_r3
                  lsr.w    #1,d5
                  bcs.s    blt_inc_loop_r3

                  move.w   (a0)+,d7
                  move.l   d7,d6
                  swap     d7
                  ror.l    d0,d6
                  move.w   d6,(a1)+
                  subq.w   #1,d5
                  bmi.s    blt_inc_swap_r3

blt_inc_loop_r3:  move.l   d7,d6
                  move.l   (a0)+,d7
                  move.l   d7,d4
                  swap     d7
                  move.w   d7,d6
                  ror.l    d0,d6
                  ror.l    d0,d4
                  swap     d6
                  move.w   d4,d6
                  move.l   d6,(a1)+
                  dbra     d5,blt_inc_loop_r3

blt_inc_swap_r3:  swap     d5
                  jmp      (a5)
blt_inc_last_r3:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d3,(a1)
                  eor.w    d7,(a1)

blt_inc_next_r3:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r3
                  rts

blt_inc_l3:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+

                  swap     d5
                  move.w   d1,d5
                  bmi.s    blt_inc_swap_l3
                  lsr.w    #1,d5
                  bcs.s    blt_inc_loop_l3

                  move.w   (a0)+,d7
                  swap     d7
                  move.l   d7,d6
                  rol.l    d0,d6
                  move.w   d6,(a1)+
                  subq.w   #1,d5
                  bmi.s    blt_inc_swap_l3

blt_inc_loop_l3:  move.l   d7,d6
                  move.l   (a0)+,d7
                  swap     d7
                  move.w   d7,d6
                  move.l   d7,d4
                  rol.l    d0,d6
                  rol.l    d0,d4
                  move.w   d4,d6
                  move.l   d6,(a1)+
                  dbra     d5,blt_inc_loop_l3

blt_inc_swap_l3:  swap     d5
                  jmp      (a5)
blt_inc_last_l3:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d3,(a1)
                  eor.w    d7,(a1)

blt_inc_next_l3:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l3
                  rts

blt_inc_4:        move.w   (a0)+,d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_4

blt_inc_loop_4:   move.w   (a0)+,d6
                  not.w    d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_4

blt_inc_jmp_4:    jmp      (a5)
blt_inc_last_4:   move.w   (a0),d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

blt_inc_next_4:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_4
                  rts

blt_inc_r4:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r4

blt_inc_loop_r4:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_r4

blt_inc_jmp_r4:   swap     d7
                  jmp      (a5)
blt_inc_last_r4:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_inc_next_r4:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r4
                  rts

blt_inc_l4:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l4

blt_inc_loop_l4:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_l4

blt_inc_jmp_l4:   jmp      (a5)
blt_inc_last_l4:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_inc_next_l4:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l4
                  rts

blt_inc_5:
blt_inc_last_5:
blt_inc_next_5:   rts

blt_inc_6:        move.w   (a0)+,d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4

                  bmi.s    blt_inc_jmp_6

blt_inc_loop_6:   move.w   (a0)+,d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_6

blt_inc_jmp_6:    jmp      (a5)
blt_inc_last_6:   move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

blt_inc_next_6:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_6
                  rts

blt_inc_r6:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r6

blt_inc_loop_r6:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_r6

blt_inc_jmp_r6:   swap     d7
                  jmp      (a5)
blt_inc_last_r6:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_r6:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r6
                  rts

blt_inc_l6:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l6

blt_inc_loop_l6:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_l6

blt_inc_jmp_l6:   jmp      (a5)
blt_inc_last_l6:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_l6:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l6
                  rts

blt_inc_7:        move.w   (a0)+,d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_7

blt_inc_loop_7:   move.w   (a0)+,d6
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_7

blt_inc_jmp_7:    jmp      (a5)
blt_inc_last_7:   move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)

blt_inc_next_7:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_7
                  rts

blt_inc_r7:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  swap     d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  swap     d5
                  move.w   d1,d5
                  bmi.s    blt_inc_swap_r7
                  lsr.w    #1,d5
                  bcs.s    blt_inc_loop_r7

                  move.w   (a0)+,d7
                  move.l   d7,d6
                  swap     d7
                  ror.l    d0,d6
                  or.w     d6,(a1)+
                  subq.w   #1,d5
                  bmi.s    blt_inc_swap_r7

blt_inc_loop_r7:  move.l   d7,d6
                  move.l   (a0)+,d7
                  move.l   d7,d4
                  swap     d7
                  move.w   d7,d6
                  ror.l    d0,d6
                  ror.l    d0,d4
                  swap     d6
                  move.w   d4,d6
                  or.l     d6,(a1)+
                  dbra     d5,blt_inc_loop_r7

blt_inc_swap_r7:  swap     d5
                  jmp      (a5)
blt_inc_last_r7:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_r7:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r7
                  rts

blt_inc_l7:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  swap     d5
                  move.w   d1,d5
                  bmi.s    blt_inc_swap_l7
                  lsr.w    #1,d5
                  bcs.s    blt_inc_loop_l7

                  move.w   (a0)+,d7
                  swap     d7
                  move.l   d7,d6
                  rol.l    d0,d6
                  or.w     d6,(a1)+
                  subq.w   #1,d5
                  bmi.s    blt_inc_swap_l7

blt_inc_loop_l7:  move.l   d7,d6
                  move.l   (a0)+,d7
                  swap     d7
                  move.w   d7,d6
                  move.l   d7,d4
                  rol.l    d0,d6
                  rol.l    d0,d4
                  move.w   d4,d6
                  or.l     d6,(a1)+
                  dbra     d5,blt_inc_loop_l7

blt_inc_swap_l7:  swap     d5
                  jmp      (a5)
blt_inc_last_l7:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_l7:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l7
                  rts

blt_inc_8:        move.w   (a0)+,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_8

blt_inc_loop_8:   move.w   (a0)+,d6
                  or.w     d6,(a1)
                  not.w    (a1)+
                  dbra     d4,blt_inc_loop_8

blt_inc_jmp_8:    jmp      (a5)
blt_inc_last_8:   move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

blt_inc_next_8:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_8
                  rts

blt_inc_r8:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r8

blt_inc_loop_r8:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_r8

blt_inc_jmp_r8:   swap     d7
                  jmp      (a5)
blt_inc_last_r8:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_r8:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r8
                  rts

blt_inc_l8:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l8

blt_inc_loop_l8:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  or.w     d6,(a1)
                  not.w    (a1)+
                  dbra     d4,blt_inc_loop_l8

blt_inc_jmp_l8:   jmp      (a5)
blt_inc_last_l8:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_l8:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l8
                  rts

blt_inc_9:        move.w   (a0)+,d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_9

blt_inc_loop_9:   move.w   (a0)+,d6
                  not.w    d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_9

blt_inc_jmp_9:    jmp      (a5)
blt_inc_last_9:   move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

blt_inc_next_9:   adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_9
                  rts

blt_inc_r9:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r9

blt_inc_loop_r9:  move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_r9

blt_inc_jmp_r9:   swap     d7
                  jmp      (a5)
blt_inc_last_r9:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_r9:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r9
                  rts

blt_inc_l9:       move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l9

blt_inc_loop_l9:  move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)+
                  dbra     d4,blt_inc_loop_l9

blt_inc_jmp_l9:   jmp      (a5)
blt_inc_last_l9:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_l9:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l9
                  rts

blt_inc_10:       lea      blt_inc_next_10(pc),a5
                  tst.w    d3
                  beq.s    blt_inc_bloop_10
                  lea      blt_inc_last_10(pc),a5

blt_inc_bloop_10: eor.w    d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_10

blt_inc_loop_10:  not.w    (a1)+
                  dbra     d4,blt_inc_loop_10

blt_inc_jmp_10:   jmp      (a5)
                  nop
blt_inc_last_10:  eor.w    d3,(a1)

blt_inc_next_10:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_bloop_10
                  rts

blt_inc_11:       move.w   (a0)+,d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_11

blt_inc_loop_11:  move.w   (a0)+,d6
                  not.w    (a1)
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_11

blt_inc_jmp_11:   jmp      (a5)
blt_inc_last_11:  move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

blt_inc_next_11:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_11
                  rts

blt_inc_r11:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r11

blt_inc_loop_r11: move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_r11

blt_inc_jmp_r11:  swap     d7
                  jmp      (a5)
blt_inc_last_r11: move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  eor.w    d3,(a1)
                  or.w     d7,(a1)

blt_inc_next_r11: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r11
                  rts

blt_inc_l11:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l11

blt_inc_loop_l11: move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_l11

blt_inc_jmp_l11:  jmp      (a5)
blt_inc_last_l11: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  eor.w    d3,(a1)
                  or.w     d7,(a1)

blt_inc_next_l11: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l11
                  rts

blt_inc_12:       move.w   (a0)+,d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_12

blt_inc_loop_12:  move.w   (a0)+,d6
                  not.w    d6
                  move.w   d6,(a1)+
                  dbra     d4,blt_inc_loop_12

blt_inc_jmp_12:   jmp      (a5)
blt_inc_last_12:  move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d6,(a1)

blt_inc_next_12:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_12
                  rts

blt_inc_r12:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r12

blt_inc_loop_r12: move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)+
                  dbra     d4,blt_inc_loop_r12

blt_inc_jmp_r12:  swap     d7
                  jmp      (a5)
blt_inc_last_r12: move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d7,(a1)

blt_inc_next_r12: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r12
                  rts

blt_inc_l12:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l12

blt_inc_loop_l12: move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)+
                  dbra     d4,blt_inc_loop_l12

blt_inc_jmp_l12:  jmp      (a5)
blt_inc_last_l12: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d7,(a1)

blt_inc_next_l12: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l12
                  rts

blt_inc_13:       move.w   (a0)+,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_13

blt_inc_loop_13:  move.w   (a0)+,d6
                  not.w    d6
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_13

blt_inc_jmp_13:   jmp      (a5)
blt_inc_last_13:  move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

blt_inc_next_13:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_13
                  rts

blt_inc_r13:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r13

blt_inc_loop_r13: move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_r13

blt_inc_jmp_r13:  swap     d7
                  jmp      (a5)
blt_inc_last_r13: move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_r13: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r13
                  rts

blt_inc_l13:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l13

blt_inc_loop_l13: move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)+
                  dbra     d4,blt_inc_loop_l13

blt_inc_jmp_l13:  jmp      (a5)
blt_inc_last_l13: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_l13: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l13
                  rts

blt_inc_14:       move.w   (a0)+,d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_14

blt_inc_loop_14:  move.w   (a0)+,d6
                  and.w    d6,(a1)
                  not.w    (a1)+
                  dbra     d4,blt_inc_loop_14

blt_inc_jmp_14:   jmp      (a5)
blt_inc_last_14:  move.w   (a0),d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

blt_inc_next_14:  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_14
                  rts

blt_inc_r14:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r14

blt_inc_loop_r14: move.w   d7,d6
                  swap     d6
                  move.w   (a0)+,d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)+
                  dbra     d4,blt_inc_loop_r14

blt_inc_jmp_r14:  swap     d7
                  jmp      (a5)
blt_inc_last_r14: move.w   (a0),d7
                  ror.l    d0,d7
                  or.w     d3,d7
                  and.w    d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_r14: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_r14
                  rts

blt_inc_l14:      move.w   (a0)+,d6
                  jmp      (a4)
                  swap     d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l14

blt_inc_loop_l14: move.l   d7,d6
                  move.w   (a0)+,d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)+
                  dbra     d4,blt_inc_loop_l14

blt_inc_jmp_l14:  jmp      (a5)
blt_inc_last_l14: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  or.w     d3,d7
                  and.w    d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_l14: adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,blt_inc_l14
                  rts

blt_inc_15:       moveq    #$ffffffff,d7
                  lea      blt_inc_last_15(pc),a5
                  tst.w    d3
                  bne.s    blt_inc_bloop_15
                  lea      blt_inc_next_15(pc),a5

blt_inc_bloop_15: or.w     d2,(a1)+

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_15

blt_inc_loop_15:  move.w   d7,(a1)+
                  dbra     d4,blt_inc_loop_15

blt_inc_jmp_15:   jmp      (a5)
blt_inc_last_15:  or.w     d3,(a1)

blt_inc_next_15:  adda.w   a3,a1
                  dbra     d5,blt_inc_bloop_15
                  rts

bitblt_dec:       movea.l  a4,a0          ;Quelladresse
                  movea.l  a5,a1          ;Zieladresse

                  movea.w  d7,a5          ;Verknuepfung * 8

                  move.w   a2,d6          ;Bytes pro Zeile
                  add.w    d5,d1
                  mulu     d1,d6          ;* y-Quelle
                  adda.l   d6,a0          ;Zeilenanfang
                  move.w   d0,d6          ;x-Quelle
                  add.w    d4,d6
                  lsr.w    #4,d6
                  add.w    d6,d6
                  adda.w   d6,a0          ;Quellendadresse

                  move.w   a3,d6          ;Bytes pro Zeile
                  add.w    d5,d3
                  mulu     d3,d6          ;* y-Ziel
                  adda.l   d6,a1          ;Zeilenanfang
                  move.w   d2,d6          ;x-Ziel
                  add.w    d4,d6
                  lsr.w    #4,d6
                  add.w    d6,d6
                  adda.w   d6,a1          ;Zielendadresse

                  moveq    #15,d6         ;zum ausmaskieren

                  move.w   d0,d7
                  and.w    d6,d7
                  add.w    d4,d7
                  lsr.w    #4,d7          ;Quellwortanzahl - 1

                  move.w   d2,d3
                  add.w    d4,d3
                  add.w    d4,d0
                  and.w    d6,d0
                  and.w    d6,d3
                  sub.w    d3,d0          ;Shifts nach links

                  move.w   d2,d1
                  and.w    d6,d1
                  add.w    d4,d1
                  lsr.w    #4,d1          ;Zielwortanzahl -1

                  sub.w    d1,d7          ;Quellwortanzahl - Zielwortanzahl

                  add.w    d2,d4
                  not.w    d4
                  and.w    d6,d4
                  moveq    #$ffffffff,d3
                  lsl.w    d4,d3          ;Startmaske
                  and.w    d2,d6
                  moveq    #$ffffffff,d2
                  lsr.w    d6,d2          ;Endmaske

                  move.w   d1,d4
                  add.w    d4,d4          ;Zielbyteanzahl - 2
                  suba.w   d4,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d4,a3          ;Abstand zur naechsten Zielzeile

                  move.w   d7,d4          ;Quellwortanzahl - Zielwortanzahl

                  moveq    #4,d6          ;Sprungoffset fuers Einlesen des Startwort
                  moveq    #0,d7          ;Sprungoffset fuers Einlesen des Endworts
                  lea      blt_dec_tab(pc),a4

                  tst.w    d0             ;keine Shifts
                  beq.s    blt_dec_jmp
                  blt.s    blt_dec_right

blt_dec_left:     lea      blt_dec_l_tab(pc),a4

                  moveq    #8,d6          ;nur ein Endwort lesen

                  tst.w    d4
                  bpl.s    blt_dec_l_shifts
                  moveq    #2,d7          ;kein Endowrt einlesen, wenn mehr Ziel-
                  addq.w   #2,a2          ;als Quellbytes vorhanden sind
blt_dec_l_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach links
                  ble.s    blt_dec_jmp

                  lea      blt_dec_r_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebungen nach rechts
                  bra.s    blt_dec_jmp

blt_dec_right:    lea      blt_dec_r_tab(pc),a4
                  neg.w    d0             ;Verschiebungen nach rechts

                  tst.w    d1             ;nur ein Zielwort?
                  bne.s    blt_dec_r_end
                  tst.w    d4             ;nur ein Quellwort?
                  bne.s    blt_dec_r_end
                  moveq    #10,d6         ;dann nur ein Quellwort einlesen
                  bra.s    blt_dec_jmp

blt_dec_r_end:    moveq    #4,d6          ;zwei Startworte einlesen
                  subq.w   #2,a2          ;daher zwei zusaetzliche Quellbytes

                  tst.w    d4
                  bgt.s    blt_dec_r_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mindestens so
                  addq.w   #2,a2          ;viele Ziel- wie Quellbytes vorhanden sind

blt_dec_r_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach rechts?
                  ble.s    blt_dec_jmp

                  lea      blt_dec_l_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebungen nach links

blt_dec_jmp:      adda.l   a4,a5

                  move.w   (a5)+,d4
                  add.w    d4,d6          ;Offset fuer den ersten Sprung
                  add.w    (a5)+,d7       ;Offset fuer den zweiten Sprung

                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_dec_offsets

                  and.w    d2,d3          ;Start- und Endmaske
                  moveq    #0,d2
                  moveq    #0,d1          ;Wortzaehler

                  move.w   (a5),d7        ;kein Endwort lesen und schreiben

blt_dec_offsets:  subq.w   #2,d1
                  lea      blt_dec_tab(pc),a4
                  lea      blt_dec_tab(pc),a5
                  adda.w   d6,a4
                  adda.w   d7,a5

                  jmp      blt_dec_tab(pc,d4.w)

blt_dec_tab:      DC.W blt_dec_0-blt_dec_tab,blt_dec_last_0-blt_dec_tab,blt_dec_next_0-blt_dec_tab,0
                  DC.W blt_dec_1-blt_dec_tab,blt_dec_last_1-blt_dec_tab,blt_dec_next_1-blt_dec_tab,0
                  DC.W blt_dec_2-blt_dec_tab,blt_dec_last_2-blt_dec_tab,blt_dec_next_2-blt_dec_tab,0
                  DC.W blt_dec_3-blt_dec_tab,0,0,0
                  DC.W blt_dec_4-blt_dec_tab,blt_dec_last_4-blt_dec_tab,blt_dec_next_4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_dec_tab,blt_dec_last_5-blt_dec_tab,blt_dec_next_5-blt_dec_tab,0
                  DC.W blt_dec_6-blt_dec_tab,blt_dec_last_6-blt_dec_tab,blt_dec_next_6-blt_dec_tab,0
                  DC.W blt_dec_7-blt_dec_tab,blt_dec_last_7-blt_dec_tab,blt_dec_next_7-blt_dec_tab,0
                  DC.W blt_dec_8-blt_dec_tab,blt_dec_last_8-blt_dec_tab,blt_dec_next_8-blt_dec_tab,0
                  DC.W blt_dec_9-blt_dec_tab,blt_dec_last_9-blt_dec_tab,blt_dec_next_9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_dec_tab,blt_dec_last_10-blt_dec_tab,blt_dec_next_10-blt_dec_tab,0
                  DC.W blt_dec_11-blt_dec_tab,blt_dec_last_11-blt_dec_tab,blt_dec_next_11-blt_dec_tab,0
                  DC.W blt_dec_12-blt_dec_tab,blt_dec_last_12-blt_dec_tab,blt_dec_next_12-blt_dec_tab,0
                  DC.W blt_dec_13-blt_dec_tab,blt_dec_last_13-blt_dec_tab,blt_dec_next_13-blt_dec_tab,0
                  DC.W blt_dec_14-blt_dec_tab,blt_dec_last_14-blt_dec_tab,blt_dec_next_14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_dec_tab,blt_dec_last_15-blt_dec_tab,blt_dec_next_15-blt_dec_tab,0

blt_dec_l_tab:    DC.W blt_dec_0-blt_dec_tab,blt_dec_last_0-blt_dec_tab,blt_dec_next_0-blt_dec_tab,0
                  DC.W blt_dec_l1-blt_dec_tab,blt_dec_last_l1-blt_dec_tab,blt_dec_next_l1-blt_dec_tab,0
                  DC.W blt_dec_l2-blt_dec_tab,blt_dec_last_l2-blt_dec_tab,blt_dec_next_l2-blt_dec_tab,0
                  DC.W blt_dec_l3-blt_dec_tab,blt_dec_last_l3-blt_dec_tab,blt_dec_next_l3-blt_dec_tab,0
                  DC.W blt_dec_l4-blt_dec_tab,blt_dec_last_l4-blt_dec_tab,blt_dec_next_l4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_dec_tab,blt_dec_last_5-blt_dec_tab,blt_dec_next_5-blt_dec_tab,0
                  DC.W blt_dec_l6-blt_dec_tab,blt_dec_last_l6-blt_dec_tab,blt_dec_next_l6-blt_dec_tab,0
                  DC.W blt_dec_l7-blt_dec_tab,blt_dec_last_l7-blt_dec_tab,blt_dec_next_l7-blt_dec_tab,0
                  DC.W blt_dec_l8-blt_dec_tab,blt_dec_last_l8-blt_dec_tab,blt_dec_next_l8-blt_dec_tab,0
                  DC.W blt_dec_l9-blt_dec_tab,blt_dec_last_l9-blt_dec_tab,blt_dec_next_l9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_dec_tab,blt_dec_last_10-blt_dec_tab,blt_dec_next_10-blt_dec_tab,0
                  DC.W blt_dec_l11-blt_dec_tab,blt_dec_last_l11-blt_dec_tab,blt_dec_next_l11-blt_dec_tab,0
                  DC.W blt_dec_l12-blt_dec_tab,blt_dec_last_l12-blt_dec_tab,blt_dec_next_l12-blt_dec_tab,0
                  DC.W blt_dec_l13-blt_dec_tab,blt_dec_last_l13-blt_dec_tab,blt_dec_next_l13-blt_dec_tab,0
                  DC.W blt_dec_l14-blt_dec_tab,blt_dec_last_l14-blt_dec_tab,blt_dec_next_l14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_dec_tab,blt_dec_last_15-blt_dec_tab,blt_dec_next_15-blt_dec_tab,0

blt_dec_r_tab:    DC.W blt_dec_0-blt_dec_tab,blt_dec_last_0-blt_dec_tab,blt_dec_next_0-blt_dec_tab,0
                  DC.W blt_dec_r1-blt_dec_tab,blt_dec_last_r1-blt_dec_tab,blt_dec_next_r1-blt_dec_tab,0
                  DC.W blt_dec_r2-blt_dec_tab,blt_dec_last_r2-blt_dec_tab,blt_dec_next_r2-blt_dec_tab,0
                  DC.W blt_dec_r3-blt_dec_tab,blt_dec_last_r3-blt_dec_tab,blt_dec_next_r3-blt_dec_tab,0
                  DC.W blt_dec_r4-blt_dec_tab,blt_dec_last_r4-blt_dec_tab,blt_dec_next_r4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_dec_tab,blt_dec_last_5-blt_dec_tab,blt_dec_next_5-blt_dec_tab,0
                  DC.W blt_dec_r6-blt_dec_tab,blt_dec_last_r6-blt_dec_tab,blt_dec_next_r6-blt_dec_tab,0
                  DC.W blt_dec_r7-blt_dec_tab,blt_dec_last_r7-blt_dec_tab,blt_dec_next_r7-blt_dec_tab,0
                  DC.W blt_dec_r8-blt_dec_tab,blt_dec_last_r8-blt_dec_tab,blt_dec_next_r8-blt_dec_tab,0
                  DC.W blt_dec_r9-blt_dec_tab,blt_dec_last_r9-blt_dec_tab,blt_dec_next_r9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_dec_tab,blt_dec_last_10-blt_dec_tab,blt_dec_next_10-blt_dec_tab,0
                  DC.W blt_dec_r11-blt_dec_tab,blt_dec_last_r11-blt_dec_tab,blt_dec_next_r11-blt_dec_tab,0
                  DC.W blt_dec_r12-blt_dec_tab,blt_dec_last_r12-blt_dec_tab,blt_dec_next_r12-blt_dec_tab,0
                  DC.W blt_dec_r13-blt_dec_tab,blt_dec_last_r13-blt_dec_tab,blt_dec_next_r13-blt_dec_tab,0
                  DC.W blt_dec_r14-blt_dec_tab,blt_dec_last_r14-blt_dec_tab,blt_dec_next_r14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_dec_tab,blt_dec_last_15-blt_dec_tab,blt_dec_next_15-blt_dec_tab,0

blt_dec_0:        not.w    d2
                  not.w    d3
                  moveq    #0,d7
                  lea      blt_dec_next_0(pc),a5
                  cmp.w    #$ffff,d2
                  beq.s    blt_dec_bloop_0
                  lea      blt_dec_last_0(pc),a5

blt_dec_bloop_0:  and.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_0

blt_dec_loop_0:   move.w   d7,-(a1)
                  dbra     d4,blt_dec_loop_0

blt_dec_jmp_0:    jmp      (a5)
blt_dec_last_0:   and.w    d2,-(a1)

blt_dec_next_0:   suba.w   a3,a1
                  dbra     d5,blt_dec_bloop_0
                  not.w    d2
                  not.w    d3
                  rts

blt_dec_1:        move.w   (a0),d6
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_1

blt_dec_loop_1:   move.w   -(a0),d6
                  and.w    d6,-(a1)

                  dbra     d4,blt_dec_loop_1

blt_dec_jmp_1:    jmp      (a5)
blt_dec_last_1:   move.w   -(a0),d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,-(a1)

blt_dec_next_1:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_1
                  rts

blt_dec_r1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d3
                  or.w     d3,d6
                  and.w    d6,(a1)
                  not.w    d3

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r1

blt_dec_loop_r1:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_r1

blt_dec_jmp_r1:   jmp      (a5)
blt_dec_last_r1:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,-(a1)

blt_dec_next_r1:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r1
                  rts

blt_dec_l1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l1

blt_dec_loop_l1:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_l1

blt_dec_jmp_l1:   swap     d7
                  jmp      (a5)
blt_dec_last_l1:  move.w   -(a0),d7
                  rol.l    d0,d7
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,-(a1)

blt_dec_next_l1:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l1
                  rts

blt_dec_2:        move.w   (a0),d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_2

blt_dec_loop_2:   move.w   -(a0),d6
                  not.w    -(a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_2

blt_dec_jmp_2:    jmp      (a5)
blt_dec_last_2:   move.w   -(a0),d6
                  eor.w    d2,-(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)

blt_dec_next_2:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_2
                  rts

blt_dec_r2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r2

blt_dec_loop_r2:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    -(a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r2

blt_dec_jmp_r2:   jmp      (a5)
blt_dec_last_r2:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  eor.w    d2,-(a1)
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_r2:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r2
                  rts

blt_dec_l2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l2

blt_dec_loop_l2:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    -(a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l2

blt_dec_jmp_l2:   swap     d7
                  jmp      (a5)
blt_dec_last_l2:  move.w   -(a0),d7
                  rol.l    d0,d7
                  eor.w    d2,-(a1)
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_l2:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l2
                  rts

blt_dec_3:        move.w   d1,d4
                  bmi      blt_dec_long_3

                  lsr.w    #1,d4
                  bcs.s    blt_dec_count_3
                  lea      blt_dec_aword_3(pc),a4
                  bne.s    blt_dec_word_off_3

                  lea      blt_dec_last_3(pc),a5
                  bra.s    blt_dec_bloop_3

blt_dec_word_off_3:subq.w  #1,d4
                  move.w   d4,d0
                  lsr.w    #4,d4
                  move.w   d4,d1
                  not.w    d0
                  andi.w   #15,d0
                  add.w    d0,d0
                  lea      blt_dec_loop_3(pc,d0.w),a5
                  bra.s    blt_dec_bloop_3

blt_dec_count_3:  move.w   d4,d0
                  lsr.w    #4,d4
                  move.w   d4,d1
                  not.w    d0
                  andi.w   #15,d0
                  add.w    d0,d0
                  lea      blt_dec_loop_3(pc,d0.w),a4

blt_dec_bloop_3:  move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4

                  jmp      (a4)
blt_dec_aword_3:  move.w   -(a0),-(a1)
                  jmp      (a5)
blt_dec_loop_3:   REPT 16
                  move.l   -(a0),-(a1)
                  ENDM
                  dbra     d4,blt_dec_loop_3

blt_dec_last_3:   move.w   -(a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,-(a1)
                  eor.w    d6,(a1)

                  suba.w   a2,a0
                  suba.w   a3,a1

                  dbra     d5,blt_dec_bloop_3
                  rts

blt_dec_long_3:   tst.w    d2
                  beq.s    blt_dec_word_3
                  subq.l   #2,a0
                  subq.l   #2,a1
                  swap     d2
                  move.w   d3,d2
                  move.l   d2,d3
                  not.l    d3
                  addq.w   #2,a2
                  addq.w   #2,a3
                  move.w   a2,d6
                  neg.w    d6
                  movea.w  d6,a2
                  move.w   a3,d6
                  neg.w    d6
                  movea.w  d6,a3
                  bra      blt_inc_loopl_3

blt_dec_word_3:   move.w   d3,d2
                  not.w    d3
                  move.w   a2,d6

                  neg.w    d6
                  movea.w  d6,a2
                  move.w   a3,d6
                  neg.w    d6
                  movea.w  d6,a3
                  bra      blt_inc_loopw_3

blt_dec_r3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r3

blt_dec_loop_r3:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  move.w   d6,-(a1)
                  dbra     d4,blt_dec_loop_r3

blt_dec_jmp_r3:   jmp      (a5)
blt_dec_last_r3:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d2,-(a1)
                  eor.w    d7,(a1)

blt_dec_next_r3:  suba.w   a2,a0
                  suba.w   a3,a1

                  dbra     d5,blt_dec_r3
                  rts

blt_dec_l3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l3

blt_dec_loop_l3:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  move.w   d6,-(a1)
                  dbra     d4,blt_dec_loop_l3

blt_dec_jmp_l3:   swap     d7
                  jmp      (a5)
blt_dec_last_l3:  move.w   -(a0),d7

                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d2,-(a1)
                  eor.w    d7,(a1)

blt_dec_next_l3:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l3
                  rts

blt_dec_4:        move.w   (a0),d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_4

blt_dec_loop_4:   move.w   -(a0),d6
                  not.w    d6
                  and.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_4

blt_dec_jmp_4:    jmp      (a5)
blt_dec_last_4:   move.w   -(a0),d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,-(a1)

blt_dec_next_4:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_4
                  rts

blt_dec_r4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r4

blt_dec_loop_r4:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_r4

blt_dec_jmp_r4:   jmp      (a5)
blt_dec_last_r4:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  not.w    d7
                  and.w    d7,-(a1)

blt_dec_next_r4:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r4
                  rts

blt_dec_l4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l4

blt_dec_loop_l4:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_l4

blt_dec_jmp_l4:   swap     d7
                  jmp      (a5)
blt_dec_last_l4:  move.w   -(a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  not.w    d7
                  and.w    d7,-(a1)

blt_dec_next_l4:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l4
                  rts

blt_dec_5:
blt_dec_last_5:
blt_dec_next_5:   rts

blt_dec_6:        move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_6

blt_dec_loop_6:   move.w   -(a0),d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_6

blt_dec_jmp_6:    jmp      (a5)
blt_dec_last_6:   move.w   -(a0),d6
                  and.w    d2,d6
                  eor.w    d6,-(a1)

blt_dec_next_6:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_6
                  rts

blt_dec_r6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r6

blt_dec_loop_r6:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_r6

blt_dec_jmp_r6:   jmp      (a5)
blt_dec_last_r6:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  eor.w    d7,-(a1)

blt_dec_next_r6:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r6
                  rts

blt_dec_l6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l6

blt_dec_loop_l6:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_l6

blt_dec_jmp_l6:   swap     d7
                  jmp      (a5)
blt_dec_last_l6:  move.w   -(a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  eor.w    d7,-(a1)

blt_dec_next_l6:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l6
                  rts

blt_dec_7:        move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_7

blt_dec_loop_7:   move.w   -(a0),d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_7

blt_dec_jmp_7:    jmp      (a5)
blt_dec_last_7:   move.w   -(a0),d6
                  and.w    d2,d6
                  or.w     d6,-(a1)

blt_dec_next_7:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_7
                  rts

blt_dec_r7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r7

blt_dec_loop_r7:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_r7

blt_dec_jmp_r7:   jmp      (a5)
blt_dec_last_r7:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,-(a1)

blt_dec_next_r7:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r7
                  rts

blt_dec_l7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l7

blt_dec_loop_l7:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_l7

blt_dec_jmp_l7:   swap     d7
                  jmp      (a5)
blt_dec_last_l7:  move.w   -(a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,-(a1)

blt_dec_next_l7:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l7
                  rts

blt_dec_8:        move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_8

blt_dec_loop_8:   move.w   -(a0),d6
                  or.w     d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_8

blt_dec_jmp_8:    jmp      (a5)
blt_dec_last_8:   move.w   -(a0),d6
                  and.w    d2,d6
                  or.w     d6,-(a1)
                  eor.w    d2,(a1)

blt_dec_next_8:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_8
                  rts

blt_dec_r8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r8

blt_dec_loop_r8:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_r8

blt_dec_jmp_r8:   jmp      (a5)
blt_dec_last_r8:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,-(a1)
                  eor.w    d2,(a1)

blt_dec_next_r8:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r8
                  rts

blt_dec_l8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l8

blt_dec_loop_l8:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_l8

blt_dec_jmp_l8:   swap     d7
                  jmp      (a5)
blt_dec_last_l8:  move.w   -(a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,-(a1)
                  eor.w    d2,(a1)

blt_dec_next_l8:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l8
                  rts

blt_dec_9:        move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_9

blt_dec_loop_9:   move.w   -(a0),d6
                  not.w    d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_9

blt_dec_jmp_9:    jmp      (a5)
blt_dec_last_9:   move.w   -(a0),d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,-(a1)

blt_dec_next_9:   suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_9
                  rts

blt_dec_r9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r9

blt_dec_loop_r9:  move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_r9

blt_dec_jmp_r9:   jmp      (a5)
blt_dec_last_r9:  move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  eor.w    d7,-(a1)

blt_dec_next_r9:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r9
                  rts

blt_dec_l9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l9

blt_dec_loop_l9:  move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  eor.w    d6,-(a1)
                  dbra     d4,blt_dec_loop_l9

blt_dec_jmp_l9:   swap     d7
                  jmp      (a5)
blt_dec_last_l9:  move.w   -(a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  eor.w    d7,-(a1)

blt_dec_next_l9:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l9
                  rts

blt_dec_10:       lea      blt_dec_next_10(pc),a5
                  tst.w    d2
                  beq.s    blt_dec_bloop_10
                  lea      blt_dec_last_10(pc),a5

blt_dec_bloop_10: eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_10

blt_dec_loop_10:  not.w    -(a1)
                  dbra     d4,blt_dec_loop_10

blt_dec_jmp_10:   jmp      (a5)
                  nop
blt_dec_last_10:  eor.w    d2,-(a1)

blt_dec_next_10:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_bloop_10
                  rts

blt_dec_11:       move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_11

blt_dec_loop_11:  move.w   -(a0),d6
                  not.w    -(a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_11

blt_dec_jmp_11:   jmp      (a5)
blt_dec_last_11:  move.w   -(a0),d6
                  and.w    d2,d6
                  eor.w    d2,-(a1)
                  or.w     d6,(a1)

blt_dec_next_11:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_11
                  rts

blt_dec_r11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r11

blt_dec_loop_r11: move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    -(a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_r11

blt_dec_jmp_r11:  jmp      (a5)
blt_dec_last_r11: move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  eor.w    d2,-(a1)
                  or.w     d7,(a1)

blt_dec_next_r11: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r11
                  rts

blt_dec_l11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l11

blt_dec_loop_l11: move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    -(a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_l11

blt_dec_jmp_l11:  swap     d7
                  jmp      (a5)
blt_dec_last_l11: move.w   -(a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  eor.w    d2,-(a1)
                  or.w     d7,(a1)

blt_dec_next_l11: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l11
                  rts

blt_dec_12:       move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_12

blt_dec_loop_12:  move.w   -(a0),d6
                  not.w    d6
                  move.w   d6,-(a1)
                  dbra     d4,blt_dec_loop_12

blt_dec_jmp_12:   jmp      (a5)
blt_dec_last_12:  move.w   -(a0),d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,-(a1)
                  not.w    d2
                  or.w     d6,(a1)

blt_dec_next_12:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_12
                  rts

blt_dec_r12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r12

blt_dec_loop_r12: move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  move.w   d6,-(a1)
                  dbra     d4,blt_dec_loop_r12

blt_dec_jmp_r12:  jmp      (a5)
blt_dec_last_r12: move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  not.w    d2
                  and.w    d2,-(a1)
                  not.w    d2
                  or.w     d7,(a1)

blt_dec_next_r12: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r12
                  rts

blt_dec_l12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l12

blt_dec_loop_l12: move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  move.w   d6,-(a1)
                  dbra     d4,blt_dec_loop_l12

blt_dec_jmp_l12:  swap     d7
                  jmp      (a5)
blt_dec_last_l12: move.w   -(a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  not.w    d2
                  and.w    d2,-(a1)
                  not.w    d2
                  or.w     d7,(a1)

blt_dec_next_l12: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l12
                  rts

blt_dec_13:       move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_13

blt_dec_loop_13:  move.w   -(a0),d6
                  not.w    d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_13

blt_dec_jmp_13:   jmp      (a5)
blt_dec_last_13:  move.w   -(a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,-(a1)

blt_dec_next_13:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_13
                  rts

blt_dec_r13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r13

blt_dec_loop_r13: move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_r13

blt_dec_jmp_r13:  jmp      (a5)
blt_dec_last_r13: move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d7,-(a1)

blt_dec_next_r13: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r13
                  rts

blt_dec_l13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l13

blt_dec_loop_l13: move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  or.w     d6,-(a1)
                  dbra     d4,blt_dec_loop_l13

blt_dec_jmp_l13:  swap     d7
                  jmp      (a5)
blt_dec_last_l13: move.w   -(a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d7,-(a1)

blt_dec_next_l13: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l13
                  rts

blt_dec_14:       move.w   (a0),d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_14

blt_dec_loop_14:  move.w   -(a0),d6
                  and.w    d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_14

blt_dec_jmp_14:   jmp      (a5)
blt_dec_last_14:  move.w   -(a0),d6
                  or.w     d2,d6
                  and.w    d6,-(a1)
                  or.w     d2,(a1)

blt_dec_next_14:  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_14
                  rts

blt_dec_r14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r14

blt_dec_loop_r14: move.l   d7,d6
                  move.w   -(a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_r14

blt_dec_jmp_r14:  jmp      (a5)
blt_dec_last_r14: move.w   -(a0),d7
                  swap     d7
                  ror.l    d0,d7
                  or.w     d2,d7
                  and.w    d7,-(a1)
                  or.w     d2,(a1)

blt_dec_next_r14: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_r14
                  rts

blt_dec_l14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l14

blt_dec_loop_l14: move.w   d7,d6
                  swap     d6
                  move.w   -(a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d6,-(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_l14

blt_dec_jmp_l14:  swap     d7
                  jmp      (a5)
blt_dec_last_l14: move.w   -(a0),d7
                  rol.l    d0,d7
                  or.w     d2,d7
                  and.w    d7,-(a1)
                  or.w     d2,(a1)

blt_dec_next_l14: suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,blt_dec_l14
                  rts

blt_dec_15:       moveq    #$ffffffff,d7
                  lea      blt_dec_last_15(pc),a5
                  tst.w    d2
                  bne.s    blt_dec_bloop_15
                  lea      blt_dec_next_15(pc),a5

blt_dec_bloop_15: or.w     d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_15

blt_dec_loop_15:  move.w   d7,-(a1)
                  dbra     d4,blt_dec_loop_15

blt_dec_jmp_15:   jmp      (a5)
blt_dec_last_15:  or.w     d2,-(a1)

blt_dec_next_15:  suba.w   a3,a1
                  dbra     d5,blt_dec_bloop_15
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

                  lsr.w    #1,d0
                  
                  tst.w    r_splanes(a6)                    ;4 Bit?
                  bne.s    scale_buf_len
                  
                  lsr.w    #3,d0                            ;Anzahl der Worte
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

                  tst.w    r_splanes(a6)                    ;4 Bit?
                  bne      scale_line_init4

                  movea.l  r_saddr(a6),a1
                  muls     r_swidth(a6),d1
                  adda.l   d1,a1
                  move.w   d0,d1
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a1                            ;Quelladresse

scale_init_zx:    move.w   d2,d7                            ;zx
                  
                  move.w   d4,d2                            ;qdx
                  move.w   d6,d3                            ;zdx
                  
                  move.w   d0,d6                            ;qx
                  moveq    #15,d4
                  and.w    d6,d4                            ;Verschiebung der Quelldaten nach links
                  
                  moveq    #7,d5
                  and.w    d7,d5                            ;Verscheibung der Zieldaten nach rechts

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
                  
                  movem.w  d2-d7,(a2)                       ;Register sichern
                  movea.l  a1,a0                            ;Quelladresse

                  lea      scale_line1(pc),a1
                  lea      scale_line1_trans(pc),a2

                  movem.l  (sp)+,d0-d7
                  rts

scale_line_init4: movea.l  r_saddr(a6),a1
                  muls     r_swidth(a6),d1
                  adda.l   d1,a1
                  move.w   d0,d1
                  lsr.w    #1,d1
                  adda.w   d1,a1                            ;Quelladresse

scale_init4_zx:   move.w   d2,d7                            ;zx
                  
                  move.w   d4,d2                            ;qdx
                  move.w   d6,d3                            ;zdx
                  
                  move.w   d0,d6                            ;qx
                  moveq    #1,d4
                  and.w    d6,d4
                  eor.w    #1,d4                            ;Anzahl der Pixel im ersten Quellbyte - 1
                  
                  moveq    #3,d5
                  and.w    d7,d5
                  eor.w    #3,d5                            ;Anzahl der Pixel im ersten Zielwort - 1

                  sub.w    (a0),d6                          ;Verschiebung der qx-Koordinate durch Clipping
                  sub.w    2*2(a0),d7                       ;Verschiebung der zx-Koordinate durch Clipping

                  move.w   4*2(a0),d0                       ;qdx ohne Clipping
                  move.w   6*2(a0),d1                       ;zdx ohne Clipping
                  
                  cmp.w    #32767,d0                        ;zu gross?
                  bhs.s    scale_init4_half
                  cmp.w    #32767,d1                        ;zu gross?
                  blo.s    scale_init4_width

scale_init4_half: lsr.w    #1,d0                            ;halbieren, um ueberlauf zu vermeiden
                  lsr.w    #1,d1                            ;halbieren, um ueberlauf zu vermeiden

scale_init4_width:addq.w   #1,d0                            ;Breite der Quelle ohne Clipping
                  addq.w   #1,d1                            ;Breite des Ziels ohne Clipping

scale_init4_cmp:  cmp.w    d0,d1
                  ble.s    scale_init4_shr                  ;verkleinern?
                  
                  move.w   d1,d2
                  neg.w    d2                               ;e = - Zielbreite = - dy
                  ext.l    d2
                  
                  tst.w    d6                               ;Verschiebung der qx-Koordinate durch Clipping?
                  beq.s    scale_init4_gya
                  mulu     d1,d6                            ;Verschiebung * xa
                  sub.l    d6,d2                            ;e korrigieren

scale_init4_gya:  tst.w    d7                               ;Verschiebung der zx-Koordinate durch Clipping?
                  beq.s    scale_init4_exit
                  mulu     d0,d7                            ;Verschiebung * ya
                  add.l    d7,d2                            ;e korrigieren
                  bra.s    scale_init4_exit

scale_init4_shr:  move.w   d0,d3
                  neg.w    d3                               ;e = - Quellbreite = - dx
                  ext.l    d3

                  tst.w    d6                               ;Verschiebung der qx-Koordinate durch Clipping?
                  beq.s    scale_init4_sya
                  mulu     d1,d6                            ;Verschiebung * xa
                  add.l    d6,d3                            ;e korrigieren

scale_init4_sya:  tst.w    d7                               ;Verschiebung der zx-Koordinate durch Clipping?
                  beq.s    scale_init4_exit
                  mulu     d0,d7                            ;Verschiebung * ya
                  sub.l    d7,d3                            ;e korrigieren
                  
scale_init4_exit: move.w   d1,d6                            ;xa = Zielbreite = dy + 1
                  move.w   d0,d7                            ;ya = Quellbreite = dx + 1
                  
                  movem.w  d2-d7,(a2)                       ;Register sichern
                  movea.l  a1,a0                            ;Quelladresse

                  lea      scale_line4(pc),a1
                  lea      scale_line4_trans(pc),a2

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
scale_line1:      movem.w  d4-d7,-(sp)                      ;Register sichern

                  movem.w  (a2),d2-d5/a2-a3                 ;Register besetzen
                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line1                        ;verkleinern?

;Zeile verbreitern (Quellbreite <= Zielbreite, entspricht Linie mit dx <= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w e = - Zielbreite = - dy
;d3.w Anzahl der auszugebenden Pixel - 1
;d4.w Verschiebung der Quelldaten nach links (xs & 15)
;d5.w Verschiebung der Zieldaten nach rechts (xd & 15)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
grow_line1:       move.w   #$8000,d6
                  moveq    #0,d7
                  clr.w    (a1)                             ;erstes Wort loeschen
                  bra.s    grow_line1_read

grow_line1_next:  sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  ror.w    #1,d6                            ;Maske um ein Pixel verschieben
                  dbcs     d3,grow_line1_loop               ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  ror.l    d5,d7
                  or.w     d7,(a1)+                         ;vorhergehendes Wort nicht ueberschreiben
                  swap     d7
                  move.w   d7,(a1)
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
                  ror.l    d5,d7
                  or.w     d7,(a1)+                         ;vorhergehendes Wort nicht ueberschreiben
                  swap     d7
                  move.w   d7,(a1)
                  moveq    #0,d7
                  subq.w   #1,d3                            ;sind noch weitere Zielpixel vorhanden
                  bpl.s    grow_line1_test
grow_line1_exit:  movem.w  (sp)+,d4-d7
                  rts

;Zeile verkleinern (Quellbreite >= Zielbreite, entspricht Linie mit dx >= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w Anzahl der einzulesenden Pixel - 1
;d3.w e = - Quellbreite = - dx
;d4.w Verschiebung der Quelldaten nach links (xs & 15)
;d5.w Verschiebung der Zieldaten nach rechts (xd & 15)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
shrink_line1:     move.w   #$8000,d6
                  moveq    #0,d7
                  clr.w    (a1)                             ;erstes Wort loeschen
                  bra.s    shrink_line1_read
                  
shrink_line1_next:sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  ror.w    #1,d6
                  dbcs     d2,shrink_line1_loop             ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
                  ror.l    d5,d7                            ;nach rechts schieben
                  or.w     d7,(a1)+                         ;vorhergehendes Wort nicht ueberschreiben
                  swap     d7
                  move.w   d7,(a1)
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
                  ror.l    d5,d7                            ;nach rechts schieben
                  or.w     d7,(a1)+                         ;vorhergehendes Wort nicht ueberschreiben
                  swap     d7
                  move.w   d7,(a1)
shrink_line1_exit:movem.w  (sp)+,d4-d7
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
scale_line4_trans:
scale_line4:      movem.w  d4-d6,-(sp)

                  movem.w  (a2),d2-d5/a2-a3

                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line4                     ;verkleinern?

;Zeile verbreitern (Quellbreite <= Zielbreite, entspricht Linie mit dx <= dy)
;Vorgaben:
;Register d4-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w e = - Zielbreite = - dy
;d3.w Anzahl der auszugebenden Pixel - 1
;d4.w Anzahl der mit dem ersten Byte eingelesenen Pixel - 1
;d5.w Anzahl der im ersten Wort auszugebenden Pixel - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
grow_line4:       moveq    #0,d1                            ;Ausgabewort loeschen

                  move.b   (a0)+,d0                         ;erstes Byte einlesen
                  tst.w    d0
                  bne.s    grow_line4_rol                   ;2 Pixel benutzen?
                  bra.s    grow_line4_pix                   ;nur ein Pixel benutzen

grow_line4_read:  dbra     d4,grow_line4_rol
                  move.b   (a0)+,d0                         ;2 Pixel einlesen
                  moveq    #1,d4
grow_line4_rol:   rol.b    #4,d0
grow_line4_pix:   moveq    #15,d6
                  and.w    d0,d6

grow_line4_write: lsl.w    #4,d1                            ;Platz im Ausgabewort schaffen
                  or.w     d6,d1
                  dbra     d5,grow_line4_err                ;ist das Ausgabewort voll?
                  move.w   d1,(a1)+
                  moveq    #0,d1                            ;Ausgabewort loeschen
                  moveq    #3,d5
grow_line4_err:   add.w    a3,d2                            ;+ ya, naechstes Zielpixel
                  bpl.s    grow_line4_next                  ;Fehler >= 0, naechstes Quellpixel?
                  dbra     d3,grow_line4_write              ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?

grow_line4_end:   cmpi.w   #3,d5                            ;muessen noch Pixel ausgegeben werden?
                  beq.s    grow_line4_exit

                  addq.w   #1,d5                            ;Anzahl der Pixel, um die nach links verschoben werden muss
                  add.w    d5,d5
                  add.w    d5,d5
                  lsl.w    d5,d1
                  move.w   d1,(a1)

grow_line4_exit:  movem.w  (sp)+,d4-d6
                  rts

grow_line4_next:  sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  dbra     d3,grow_line4_read               ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden
                  bra.s    grow_line4_end

;Zeile verkleinern (Quellbreite >= Zielbreite, entspricht Linie mit dx >= dy)
;Vorgaben:
;Register dx-d7.w befinden sich gesichert auf dem Stack
;Register d0-d3/d6-d7/a0-a1 werden veraendert
;Eingaben:
;d2.w Anzahl der einzulesenden Pixel - 1
;d3.w e = - Quellbreite = - dx
;d4.w Anzahl der mit dem ersten Byte eingelesenen Pixel - 1
;d5.w Anzahl der im ersten Wort auszugebenden Pixel - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;Ausgaben:
;-
shrink_line4:     moveq    #0,d1                            ;Ausgabewort loeschen

                  move.b   (a0)+,d0                         ;erstes Byte einlesen
                  tst.w    d0
                  bne.s    shrink_line4_rol                 ;2 Pixel benutzen?
                  bra.s    shrink_line4_pix                 ;nur ein Pixel benutzen

shrink_line4_read:dbra     d4,shrink_line4_rol
                  move.b   (a0)+,d0                         ;2 Pixel einlesen
                  moveq    #1,d4
shrink_line4_rol: rol.b    #4,d0
shrink_line4_pix: add.w    a2,d3                            ;+ xa, naechstes Quellpixel
                  bpl.s    shrink_line4_next                ;Fehler >= 0, naechstes Zielpixel?
                  dbra     d2,shrink_line4_read             ;sind noch weitere Quellpixel vorhanden?

shrink_line4_end: cmpi.w   #3,d5                            ;muessen noch Pixel ausgegeben werden?
                  beq.s    shrink_line4_exit

                  addq.w   #1,d5                            ;Anzahl der Pixel, um die nach links verschoben werden muss
                  add.w    d5,d5
                  add.w    d5,d5
                  lsl.w    d5,d1
                  move.w   d1,(a1)

shrink_line4_exit:movem.w  (sp)+,d4-d6
                  rts
                     
shrink_line4_next:moveq    #15,d6
                  and.w    d0,d6
                  lsl.w    #4,d1                            ;Platz im Ausgabewort schaffen
                  or.w     d6,d1
                  dbra     d5,shrink_line4_err              ;ist das Ausgabewort voll?
                  move.w   d1,(a1)+
                  moveq    #0,d1                            ;Ausgabewort loeschen
                  moveq    #3,d5
shrink_line4_err: sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  dbra     d2,shrink_line4_read             ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
                  bra.s    shrink_line4_end

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
write_line_init:  movem.l  d0-d7,-(sp)

                  movea.l  r_daddr(a6),a0
                  muls     r_dwidth(a6),d3
                  adda.l   d3,a0

                  tst.w    r_splanes(a6)                    ;4 Bit?
                  bne      write_line_init4

                  moveq    #7,d5
                  moveq    #7,d7

                  and.w    d2,d5
                  move.w   d6,d4
                  add.w    d2,d4                            ;zx2
                  and.w    d4,d7

                  moveq    #$fffffff8,d1
                  and.w    d1,d2
                  lsr.w    #1,d2                            ;Abstand zum Zeilenanfang in Bytes (auf Langwortgrenze)
                  and.w    d1,d4
                  lsr.w    #1,d4

                  adda.w   d2,a0                            ;Zieladresse

                  sub.w    d2,d4                            ;Byteanzahl - 1
                  lsr.w    #2,d4                            ;Langwortanzahl - 1

                  add.w    d5,d5
                  add.w    d5,d5
                  move.l   wl_1_4_smask(pc,d5.w),d2         ;Startmaske
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   wl_1_4_emask(pc,d7.w),d3         ;Endmaske

                  subq.w   #1,d4                            ;Anzahl der auszugebenden Langworte - 2
                  bpl.s    write_line_tab
                  and.l    d3,d2                            ;Start- und Endmaske kombinieren
                  moveq    #0,d3                            ;kein zweites Langwort ausgeben

write_line_tab:   lea      color_map_long(pc),a3
                  move.w   r_fgcol(a6),d6
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   0(a3,d6.w),d6                    ;Vordergrundfarbe
                  move.w   r_bgcol(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a3,d7.w),d7                    ;Hintergrundfarbe

                  lea      expand_tab(pc),a3                ;Zeiger auf die Expandiertabelle

                  movem.l  d2-d4/d6-d7/a3,(a2)

                  moveq    #3,d0
                  and.w    r_wmode(a6),d0                   ;Schreibmodus
                  add.w    d0,d0
                  move.w   wl_1_4_tab(pc,d0.w),d0
                  lea      wl_1_4_tab(pc,d0.w),a1           ;Zeiger auf Ausgabefunktion

                  movem.l  (sp)+,d0-d7
                  rts

wl_1_4_tab:       DC.W wl_1_4_repl-wl_1_4_tab
                  DC.W wl_1_4_trans-wl_1_4_tab
                  DC.W wl_1_4_eor-wl_1_4_tab
                  DC.W wl_1_4_rtr-wl_1_4_tab

wl_1_4_smask:     DC.L $ffffffff
                  DC.L $0fffffff
                  DC.L $ffffff
                  DC.L $0fffff
                  DC.L $ffff
                  DC.L $0fff
                  DC.L $ff
                  DC.L $0f

wl_1_4_emask:     DC.L $f0000000
                  DC.L $ff000000
                  DC.L $fff00000
                  DC.L $ffff0000
                  DC.L $fffff000
                  DC.L $ffffff00
                  DC.L $fffffff0
                  DC.L $ffffffff

write_line_init4: move.w   d2,d3
                  lsr.w    #2,d3
                  add.w    d3,d3
                  adda.w   d3,a0                            ;Zieladresse
                  
                  move.w   d2,d0                            ;x1
                  move.w   d2,d1
                  add.w    d6,d1                            ;x2
                  
                  moveq    #3,d3
                  and.w    d3,d2
                  add.w    d2,d2
                  move.w   write_start_mask(pc,d2.w),d2
                  not.w    d2                               ;Startmaske

                  and.w    d1,d3
                  add.w    d3,d3
                  move.w   write_end_mask(pc,d3.w),d3       ;Endmaske
                  
                  lsr.w    #2,d0
                  lsr.w    #2,d1
                  neg.w    d0
                  add.w    d1,d0                            ;Anzahl der Worte - 1
                  
                  movem.w  d0/d2-d3,(a2)

                  moveq    #15,d0
                  and.w    r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   wl_4_4_tab(pc,d0.w),d0           ;Offset der Funktion
                  lea      wl_4_4_tab(pc,d0.w),a1           ;Zeiger auf Ausgabefunktion
                  
                  movem.l  (sp)+,d0-d7
                  rts

write_start_mask: DC.W %1111111111111111
write_end_mask:   DC.W %0000111111111111
                  DC.W %0000000011111111
                  DC.W %0000000000001111
                  DC.W %0000000000000000

wl_4_4_tab:       DC.W  wl_4_4_mode0-wl_4_4_tab
                  DC.W  wl_4_4_mode1-wl_4_4_tab
                  DC.W  wl_4_4_mode2-wl_4_4_tab
                  DC.W  wl_4_4_mode3-wl_4_4_tab
                  DC.W  wl_4_4_mode4-wl_4_4_tab
                  DC.W  wl_4_4_mode5-wl_4_4_tab
                  DC.W  wl_4_4_mode6-wl_4_4_tab
                  DC.W  wl_4_4_mode7-wl_4_4_tab
                  DC.W  wl_4_4_mode8-wl_4_4_tab
                  DC.W  wl_4_4_mode9-wl_4_4_tab
                  DC.W  wl_4_4_mode10-wl_4_4_tab
                  DC.W  wl_4_4_mode11-wl_4_4_tab
                  DC.W  wl_4_4_mode12-wl_4_4_tab
                  DC.W  wl_4_4_mode13-wl_4_4_tab
                  DC.W  wl_4_4_mode14-wl_4_4_tab
                  DC.W  wl_4_4_mode15-wl_4_4_tab

;d2.l Startmaske
;d3.l Endmaske
;d4.w Langwortzaehler
;d6.l Vordergrundfarbe
;d7.l Hintergrundfarbe
;a0.l Quelladresse
;a1.l Zieladresse
;a3.l Zeiger auf die Expandiertabelle
                              
;Zeile ausgeben, von 1 Bit auf 4 Bit expandieren, REPLACE
;Vorgaben:
;Register d4-d7.w/a4-a6.l duerfen nicht veraendert oder muessen gesichert werden
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer (Bestueckung siehe write_line_init)
;Ausgaben:
;-
wl_1_4_repl:      movem.w  d4/d6-d7,-(sp)
                  movem.l  (a2),d2-d4/d6-d7/a3
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  or.l     d2,(a1)
                  not.l    d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  tst.w    d4
                  bmi.s    wl_1_4_repl_next
                  subq.w   #1,d4
                  bmi.s    wl_1_4_repl_em
wl_1_4_repl_loop: moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  move.l   d0,(a1)+
                  dbra     d4,wl_1_4_repl_loop

wl_1_4_repl_em:   moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  move.l   d0,d1
                  not.l    d1
                  and.l    d6,d0
                  and.l    d7,d1
                  or.l     d1,d0
                  or.l     d3,(a1)
                  not.l    d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

wl_1_4_repl_next: movem.w  (sp)+,d4/d6-d7
                  rts

;Zeile ausgeben, von 1 Bit auf 4 Bit expandieren, TRANSPARENT
;Vorgaben:
;Register d4-d7.w/a4-a6.l duerfen nicht veraendert oder muessen gesichert werden
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer (Bestueckung siehe write_line_init)
;Ausgaben:
;-
wl_1_4_trans:     movem.w  d4/d6-d7,-(sp)
                  movem.l  (a2),d2-d4/d6-d7/a3
                  not.l    d6
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d7
                  bmi.s    wl_1_4_trans_next
                  subq.w   #1,d7
                  bmi.s    wl_1_4_trans_em
wl_1_4_trans_loop:moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
                  dbra     d7,wl_1_4_trans_loop

wl_1_4_trans_em:  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d6,d0
                  eor.l    d0,(a1)+
wl_1_4_trans_next:movem.w  (sp)+,d4/d6-d7
                  rts

;Zeile ausgeben, von 1 Bit auf 4 Bit expandieren, EOR
;Vorgaben:
;Register d4-d7.w/a4-a6.l duerfen nicht veraendert oder muessen gesichert werden
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer (Bestueckung siehe write_line_init)
;Ausgaben:
;-
wl_1_4_eor:       movem.w  d4/d6-d7,-(sp)
                  movem.l  (a2),d2-d4/d6-d7/a3
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  and.l    d2,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    wl_1_4_eor_next
                  subq.w   #1,d6
                  bmi.s    wl_1_4_eor_em
wl_1_4_eor_loop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  eor.l    d0,(a1)+
                  dbra     d6,wl_1_4_eor_loop

wl_1_4_eor_em:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  and.l    d3,d0
                  eor.l    d0,(a1)+

wl_1_4_eor_next:  movem.w  (sp)+,d4/d6-d7
                  rts

;Zeile ausgeben, von 1 Bit auf 4 Bit expandieren, REVERS TRANSPARENT
;Vorgaben:
;Register d4-d7.w/a4-a6.l duerfen nicht veraendert oder muessen gesichert werden
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer (Bestueckung siehe write_line_init)
;Ausgaben:
;-
wl_1_4_rtr:       movem.w  d4/d6-d7,-(sp)
                  movem.l  (a2),d2-d4/d6-d7/a3
                  not.l    d7
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  not.l    d0
                  and.l    d2,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

                  move.w   d4,d6
                  bmi.s    wl_1_4_rtr_next
                  subq.w   #1,d6
                  bmi.s    wl_1_4_rtr_em
wl_1_4_rtr_loop:  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  not.l    d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+
                  dbra     d6,wl_1_4_rtr_loop

wl_1_4_rtr_em:    moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a3,d0.w),d0
                  not.l    d0
                  and.l    d3,d0
                  or.l     d0,(a1)
                  and.l    d7,d0
                  eor.l    d0,(a1)+

wl_1_4_rtr_next:  movem.w  (sp)+,d4/d6-d7
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile ausgeben, Modus 0 (ALL_ZERO)
wl_4_4_mode0:     movem.w  (a2),d0/d2-d3

                  moveq    #0,d1
                  and.w    d2,(a1)+                         ;Ziel maskieren

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m0_2nd
                  
wl_4_4_m0_loop:   move.w   d1,(a1)+                         ;Zwischenteil kopieren
                  dbra     d0,wl_4_4_m0_loop

wl_4_4_m0_end:    and.w    d3,(a1)+                         ;Ziel maskieren
                  rts

wl_4_4_m0_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m0_end
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_4_4_mode1:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m1_2nd
                  
wl_4_4_m1_loop:   move.w   (a0)+,d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_4_4_m1_loop

wl_4_4_m1_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m1_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m1_end
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_4_4_mode2:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  not.w    d2
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m2_2nd
                  
wl_4_4_m2_loop:   move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  and.w    d1,(a1)+
                  dbra     d0,wl_4_4_m2_loop

wl_4_4_m2_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  not.w    d3
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m2_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m2_end
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_4_4_mode3:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m3_2nd
                  
wl_4_4_m3_loop:   move.w   (a0)+,(a1)+                      ;Zwischenteil kopieren
                  dbra     d0,wl_4_4_m3_loop

wl_4_4_m3_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m3_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m3_end
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_4_4_mode4:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m4_2nd
                  
wl_4_4_m4_loop:   move.w   (a0)+,d1
                  not.w    d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_4_4_m4_loop

wl_4_4_m4_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m4_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m4_end
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_4_4_mode5:     rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_4_4_mode6:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m6_2nd
                  
wl_4_4_m6_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)+
                  dbra     d0,wl_4_4_m6_loop

wl_4_4_m6_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m6_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m6_end
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_4_4_mode7:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m7_2nd
                  
wl_4_4_m7_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_4_4_m7_loop

wl_4_4_m7_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m7_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m7_end
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_4_4_mode8:     movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m8_2nd
                  
wl_4_4_m8_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_4_4_m8_loop

wl_4_4_m8_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d3,(a1)+
                  rts

wl_4_4_m8_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m8_end
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_4_4_mode9:     movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m9_2nd
                  
wl_4_4_m9_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_4_4_m9_loop

wl_4_4_m9_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d3,(a1)+
                  rts

wl_4_4_m9_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m9_end
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_4_4_mode10:    movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m10_2nd
                  
wl_4_4_m10_loop:  not.w    (a1)+
                  dbra     d0,wl_4_4_m10_loop

wl_4_4_m10_end:   eor.w    d3,(a1)+
                  rts

wl_4_4_m10_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m10_end
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_4_4_mode11:    movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m11_2nd
                  
wl_4_4_m11_loop:  move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  or.w     d1,(a1)+
                  dbra     d0,wl_4_4_m11_loop

wl_4_4_m11_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m11_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m11_end
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_4_4_mode12:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m12_2nd
                  
wl_4_4_m12_loop:  move.w   (a0)+,d1
                  not.w    d1
                  move.w   d1,(a1)+
                  dbra     d0,wl_4_4_m12_loop

wl_4_4_m12_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m12_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m12_end
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_4_4_mode13:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m13_2nd
                  
wl_4_4_m13_loop:  move.w   (a0)+,d1
                  not.w    d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_4_4_m13_loop

wl_4_4_m13_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_4_4_m13_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m13_end
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_4_4_mode14:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  and.w    d1,(a1)
                  not.w    d2
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m14_2nd
                  
wl_4_4_m14_loop:  move.w   (a0)+,d1
                  and.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_4_4_m14_loop

wl_4_4_m14_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  and.w    d1,(a1)
                  not.w    d3
                  eor.w    d3,(a1)+
                  rts

wl_4_4_m14_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m14_end
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_4_4_mode15:    movem.w  (a2),d0/d2-d3

                  moveq    #$ffffffff,d1
                  not.w    d2
                  not.w    d3
                  or.w     d2,(a1)+                         ;Ziel maskieren

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_4_4_m15_2nd
                  
wl_4_4_m15_loop:  move.w   d1,(a1)+                         ;Zwischenteil kopieren
                  dbra     d0,wl_4_4_m15_loop

wl_4_4_m15_end:   or.w     d3,(a1)+                         ;Ziel maskieren
                  rts

wl_4_4_m15_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_4_4_m15_end
                  rts
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dummy:            rts
                  DATA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Relozierungs-Information'
relokation:
;Reloziert am: Sun Jan 21 20:42:48 1996

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
                  ; 'Farbtabellen'

color_map:        DC.B 0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
color_remap:      DC.B 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1

color_map_byte:   DC.B $00,$ff,$11,$22
                  DC.B $44,$66,$33,$55
                  DC.B $77,$88,$99,$aa
                  DC.B $cc,$ee,$bb,$dd

color_map_word:   DC.W $00,$ffff,$1111,$2222
                  DC.W $4444,$6666,$3333,$5555
                  DC.W $7777,$8888,$9999,$aaaa
                  DC.W $cccc,$eeee,$bbbb,$dddd

color_map_long:   DC.L $00,$ffffffff,$11111111,$22222222
                  DC.L $44444444,$66666666,$33333333,$55555555
                  DC.L $77777777,$88888888,$99999999,$aaaaaaaa
                  DC.L $cccccccc,$eeeeeeee,$bbbbbbbb,$dddddddd

value_long:       DC.L $00,$11111111,$22222222,$33333333
                  DC.L $44444444,$55555555,$66666666,$77777777
                  DC.L $88888888,$99999999,$aaaaaaaa,$bbbbbbbb
                  DC.L $cccccccc,$dddddddd,$eeeeeeee,$ffffffff
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; 'Laufzeitdaten'
                  BSS

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0

cpu020:           DS.W 1                  ;Prozessortyp

expand_tab:       DS.L 256                ;Expandiertabelle
expand_tabo:      DS.L 256                ;Expandiertabelle fuer movep.l

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
