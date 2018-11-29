;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                   256-Farb-Offscreen-Treiber fuer NVDI 4.1                 *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Labels und Konstanten
                  ;'Header'

VERSION           EQU $0410

INCLUDE "..\include\linea.inc"
INCLUDE "..\include\tos.inc"
INCLUDE "..\include\seedfill.inc"

INCLUDE "..\include\nvdi_wk.inc"
INCLUDE "..\include\vdi.inc"

INCLUDE "..\include\driver.inc"

PATTERN_LENGTH    EQU (32*8)              ;Fuellmusterlaenge bei 8 Ebenen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Initialisierung'
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
                  DC.W  0                 ;Pixelformat
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
                  bsr      make_relo      ;Treiber relozieren
                  bsr      build_color_maps

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
                  move.l   (a2)+,0-24(a1)    ;work_out[46/47]: clip_xmin/clip_ymin
                  move.l   (a2)+,4-24(a1)    ;work_out[48/49]: clip_xmax/clip_ymax

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
                  
                  move.w   #0,(a0)+       ;[0] Interleaved Planes
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
                  moveq    #0,d1
                  lea      color_map(pc),a1
scrninfo_loop:    move.b   (a1)+,d1
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
                  lea      color_map(pc),a1
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

                  move.l   #expblt_soft,p_expblt(a6)
                  move.l   #bitblt_soft,p_bitblt(a6)
                  move.l   #textblt_soft,p_textblt(a6)

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

;Raster transformieren
;Vorgaben:
;Register d0-d7/a0-a5 koennen veraendert werden
;Eingaben:
;a0.l Zeiger auf den Quell-MFDB
;a1.l Zeiger auf den Ziel-MFDB
;a6.l Workstation
;Ausgaben:
;-
transform:        moveq    #0,d0          ;Langwort loeschen
                  move.w   fd_nplanes(a0),d0 ;Anzahl der Quellebenen
                  move.w   fd_h(a0),d1    ;Anzahl der Quellzeilen
                  mulu     fd_wdwidth(a0),d1 ;Wortanzahl des Quellbocks pro Ebene
                  tst.w    fd_stand(a0)   ;geraeteabhaengiges Quellformat ?
                  bne.s    vr_trnfm_dep
                  move.w   #1,fd_stand(a1) ;standardisiertes Zielformat
                  bra.s    vr_trnfm_addr
vr_trnfm_dep:     clr.w    fd_stand(a1)   ;geraeteabhaengiges Zielformat
                  exg      d0,d1          ;Planes und Worte tauschen
vr_trnfm_addr:    movea.l  (a0),a0        ;Quellblockadresse
                  movea.l  (a1),a1        ;Zielblockadresse
                  subq.l   #1,d0          ;mindestens eine Ebene/Wort ?
                  bmi.s    vr_trnfm_exit
                  move.l   d1,d4
                  subq.l   #1,d4          ;Wort-/Ebenenzaehler
                  bmi.s    vr_trnfm_exit
                  cmpa.l   a0,a1          ;Ziel- und Quelladresse gleich ?
                  beq.s    vr_trnfm_same

                  add.l    d1,d1          ;Abstand zum naechsten Wort/Ebene
vr_trnfm_diff:    movea.l  a1,a2
                  move.l   d0,d3
vr_trnfm_d_copy:  move.w   (a0)+,(a2)
                  adda.l   d1,a2          ;naechstes Zielwort
                  subq.l   #1,d3
                  bpl.s    vr_trnfm_d_copy
                  addq.l   #2,a1          ;naechste Ebene
                  subq.l   #1,d4
                  bpl.s    vr_trnfm_diff
                  rts

vr_trnfm_same:    subq.l   #1,d4          ;nur eine Ebene/Wort ?
                  bmi.s    vr_trnfm_exit
vr_trnfm_s_loop:  moveq    #0,d2
                  move.l   d4,d1          ;Wort-/Ebenenzaehler
vr_trnfm_bls:     adda.l   d0,a0
                  lea      2(a0,d0.l),a0
                  move.w   (a0),d5
                  movea.l  a0,a1
                  movea.l  a0,a2
                  add.l    d0,d2
                  move.l   d2,d3
                  bra.s    vr_trnfm_s_next
vr_trnfm_s_copy:  movea.l  a1,a2
                  move.w   -(a1),(a2)     ;alles um ein Wort verschieben
vr_trnfm_s_next:  subq.l   #1,d3
                  bpl.s    vr_trnfm_s_copy
                  move.w   d5,(a1)
vr_trnfm_dbfs:    subq.l   #1,d1
                  bpl.s    vr_trnfm_bls
                  movea.l  a2,a0
                  subq.l   #1,d0
                  bpl.s    vr_trnfm_s_loop
vr_trnfm_exit:    rts

;Pixel auslesen
;Vorgaben:
;Register d0-d1/a0 koennen veraendert werden
;Eingaben:
;d0.w x
;d1.w y
;a6.l Workstation
;Ausgaben:
;d0.l Farbwert
get_pixel:        movem.l  d2-d3,-(sp)
                  tst.w    bitmap_width(a6)
                  beq.s    get_pixel_screen
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    get_pixel_line
get_pixel_screen: movea.l  v_bas_ad.w,a0
                  muls     BYTES_LIN.w,d1
get_pixel_line:   add.l    d1,a0
                  moveq    #$fffffff0,d1
                  and.w    d0,d1
                  adda.w   d1,a0
                  lea      16(a0),a0      ;Zeiger hinter die hoechstwertigste Plane
                  moveq    #15,d1
                  not.w    d0
                  and.w    d0,d1          ;Bitnummer
                  moveq    #7,d2          ;Planezaehler
                  moveq    #0,d0
get_pixel_loop:   move.w   -(a0),d3
                  add.w    d0,d0
                  btst     d1,d3          ;Bit in der Ebene gesetzt?
                  beq.s    get_pixel_next
                  addq.w   #1,d0
get_pixel_next:   dbra     d2,get_pixel_loop
                  movem.l  (sp)+,d2-d3
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
set_pixel:        move.l   d3,-(sp)
                  tst.w    bitmap_width(a6)
                  beq.s    set_pixel_screen
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    set_pixel_line
set_pixel_screen: movea.l  v_bas_ad.w,a0
                  muls     BYTES_LIN.w,d1
set_pixel_line:   add.l    d1,a0
                  moveq    #$fffffff0,d1
                  and.w    d0,d1
                  adda.w   d1,a0          ;Zeiger auf die niederwertigste Plane
                  not.w    d0
                  andi.w   #15,d0
                  moveq    #0,d1
                  bset     d0,d1
                  move.w   d1,d0
                  not.w    d0

                  moveq    #7,d3          ;Planezaehler
set_pixel_loop:   ror.w    #1,d2
                  bcc.s    set_pixel_white
                  or.w     d1,(a0)+
                  dbra     d3,set_pixel_loop
                  move.l   (sp)+,d3
                  rts
set_pixel_white:  and.w    d0,(a0)+
                  dbra     d3,set_pixel_loop
                  move.l   (sp)+,d3
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
set_pattern:      lsr.w    #4,d0
                  subq.w   #1,d0
                  beq.s    set_pattern_mono  ;nur eine Farbebene ?
                  move.w   r_planes(a6),d0   ;Anzahl der Ebenen - 1
set_pattern_mono: move.w   d0,-(sp)
set_pattern_loop: REPT 8
                  move.l   (a0)+,(a1)+
                  ENDM
                  dbra     d0,set_pattern_loop
                  move.w   (sp)+,d0       ;Anzahl der Ebenen - 1
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
                  ;'Bitblocktransfer'

bitblt_soft:      cmp.w    d4,d6                            ;horizontal skalieren?
;                 bne      bitblt_scale
                  cmp.w    d5,d7                            ;vertikal skalieren?
;                 bne      bitblt_scale

                  bclr     #4,r_wmode+1(a6)                 ;vrt_cpyfm mit Schreibmodus 0-3?
                  bne.s    expblt_soft

                  clr.l    r_fgcol(a6)                      ;r_fgcol/r_bgcol
                  moveq    #15,d7
                  and.w    r_wmode(a6),d7
                  move.b   d7,r_wmode(a6)
                  bra.s    bitblt_planes

expblt_modes:     DC.B 0,12,3,15          ;REPLACE
                  DC.B 4,4,7,7            ;OR
                  DC.B 6,6,6,6            ;EOR
                  DC.B 1,13,1,13          ;NOT OR

expblt_soft:      moveq    #3,d7
                  and.w    r_wmode(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   expblt_modes(pc,d7.w),r_wmode(a6) ;Op_tab
                  lea      color_map(pc),a0
                  move.w   r_fgcol(a6),d6
                  move.b   0(a0,d6.w),r_fgcol+1(a6) ;Ebenenzuordnung
                  move.w   r_bgcol(a6),d6
                  move.b   0(a0,d6.w),r_bgcol+1(a6)

bitblt_planes:    addq.w   #1,r_splanes(a6)
                  addq.w   #1,r_dplanes(a6)
                  move.w   r_splanes(a6),d6
                  add.w    d6,d6
                  move.w   d6,r_snxtword(a6)
                  move.w   r_dplanes(a6),d6
                  add.w    d6,d6
                  move.w   d6,r_dnxtword(a6)

                  movea.l  r_saddr(a6),a0 ;Quelladresse
                  movea.l  r_daddr(a6),a1 ;Zieladresse
                  movea.w  r_swidth(a6),a2 ;Bytes pro Quellzeile
                  movea.w  r_dwidth(a6),a3 ;Bytes pro Zielzeile

                  move.w   a2,d6
                  mulu     d1,d6          ;* y-Quelle
                  adda.l   d6,a0          ;Zeilenanfang
                  move.w   d0,d6          ;x-Quelle
                  lsr.w    #4,d6
                  add.w    d6,d6
                  mulu     r_splanes(a6),d6
                  adda.l   d6,a0          ;Quelladresse

                  move.w   a3,d6          ;Bytes pro Zeile
                  mulu     d3,d6          ;* y-Ziel
                  adda.l   d6,a1          ;Zeilenanfang
                  move.w   d2,d6          ;x-Ziel
                  lsr.w    #4,d6
                  add.w    d6,d6
                  mulu     r_dplanes(a6),d6
                  adda.l   d6,a1          ;Zieladresse

                  cmpa.l   a1,a0          ;Quelladresse > Zieladresse
                  bhi.s    bitblt_inc
                  beq.s    bitblt_equal

                  adda.w   a2,a0
                  cmpa.l   a0,a1          ;innerhalb einer Zeile verschieben?
                  bcs      bitblt_dec
                  suba.w   a2,a0

                  move.w   a2,d6
                  mulu     d5,d6
                  adda.l   d6,a0          ;letzte Zeile des Quellblocks
                  move.w   a3,d6
                  mulu     d5,d6
                  adda.l   d6,a1          ;letzte Zeile des Zielblocks

                  move.w   a2,d6
                  neg.w    d6
                  movea.w  d6,a2          ;Zeilenbreite negativeren
                  move.w   a3,d6
                  neg.w    d6
                  movea.w  d6,a3          ;Zeilenbreite negativieren
                  bra.s    bitblt_inc

bitblt_equal:     moveq    #15,d6
                  moveq    #15,d7
                  and.w    d0,d6
                  and.w    d2,d7
                  sub.w    d6,d7
                  bgt      bitblt_dec     ;Predekrement, wenn Verschiebung nach rechts
                  bne.s    bitblt_inc
                  cmpa.w   a2,a3
                  bgt      bitblt_dec

bitblt_inc:       moveq    #15,d6         ;zum ausmaskieren

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
                  move.w   d4,d6
                  mulu     r_snxtword(a6),d4
                  mulu     r_dnxtword(a6),d6
                  suba.w   d4,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

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
                  moveq    #12,d6         ;dann nur ein Startwort einlesen
                  bra.s    blt_inc_jmp

blt_inc_l_end:    moveq    #4,d6          ;zwei Startwoerter einlesen
                  suba.w   r_snxtword(a6),a2 ;daher 2 zusaetzliche Quellbytes
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
                  moveq    #10,d6         ;nur ein Startwort einlesen
                  tst.w    d1             ;nur ein Zielwort?
                  beq.s    blt_inc_jmp
                  tst.w    d4             ;weniger Ziel- als Quellworte?
                  bpl.s    blt_inc_r_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mehr Zielbytes vorhanden sind
blt_inc_r_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach rechts?
                  ble.s    blt_inc_jmp

                  lea      blt_inc_l_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebung nach links

blt_inc_jmp:      move.w   r_dplanes(a6),d4
                  cmp.w    r_splanes(a6),d4
                  bne.s    blt_inc_cnt
                  cmp.w    #8,d4          ;8 Ebenen kopieren?
                  bne.s    blt_inc_cnt
                  tst.l    r_fgcol(a6)
                  bne.s    blt_inc_cnt
                  cmpi.b   #3,r_wmode(a6)
                  beq      copy_inc

blt_inc_cnt:      subq.w   #1,d4          ;Zielebenenzaehler

                  move.w   a2,r_swidth(a6)
                  move.w   a3,r_dwidth(a6)

                  movea.w  r_snxtword(a6),a2
                  movea.w  r_dnxtword(a6),a3

                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_inc_loop

                  and.w    d3,d2          ;Start- und Endmaske
                  move.w   a2,d3
                  sub.w    d3,r_swidth(a6)
                  move.w   a3,d3
                  sub.w    d3,r_dwidth(a6)
                  moveq    #0,d3

blt_inc_loop:     movem.l  d1/d4-a1/a4,-(sp)
                  lea      r_fgcol(a6),a5
                  moveq    #0,d4
                  lsr.w    (a5)+          ;Vordergrundfarbbit
                  addx.w   d4,d4
                  lsr.w    (a5)+          ;Hintergrundfarbbit
                  addx.w   d4,d4
                  move.b   0(a5,d4.w),d4  ;Verknuepfung
                  lsl.w    #3,d4
                  movea.w  d4,a5
                  adda.l   a4,a5          ;Zeiger in Abstandstabelle
                  move.w   (a5)+,d4       ;Abstand zur BitBlt-Funktion
                  add.w    d4,d6          ;Offset fuer den ersten Sprung
                  add.w    (a5)+,d7       ;Offset fuer den zweiten Sprung
                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_inc_offsets
                  move.w   (a5),d7        ;kein Endwort lesen und schreiben
blt_inc_offsets:  subq.w   #2,d1
                  lea      blt_inc_tab(pc),a4
                  lea      blt_inc_tab(pc),a5
                  adda.w   d6,a4
                  adda.w   d7,a5
                  jsr      blt_inc_tab(pc,d4.w)
                  movem.l  (sp)+,d1/d4-a1/a4
                  addq.l   #2,a1          ;naechste Zielebene
                  cmpi.w   #1,r_splanes(a6) ;vrt_cpyfm()?
                  beq.s    blt_inc_next
                  addq.l   #2,a0          ;naechste Quelleebene
blt_inc_next:     dbra     d4,blt_inc_loop
                  rts

blt_inc_tab:      DC.W blt_inc_0-blt_inc_tab,0,0,0
                  DC.W blt_inc_1-blt_inc_tab,blt_inc_last_1-blt_inc_tab,blt_inc_next_1-blt_inc_tab,0
                  DC.W blt_inc_2-blt_inc_tab,blt_inc_last_2-blt_inc_tab,blt_inc_next_2-blt_inc_tab,0
                  DC.W blt_inc_3-blt_inc_tab,blt_inc_last_3-blt_inc_tab,blt_inc_next_3-blt_inc_tab,0
                  DC.W blt_inc_4-blt_inc_tab,blt_inc_last_4-blt_inc_tab,blt_inc_next_4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,0,0,0
                  DC.W blt_inc_6-blt_inc_tab,blt_inc_last_6-blt_inc_tab,blt_inc_next_6-blt_inc_tab,0
                  DC.W blt_inc_7-blt_inc_tab,blt_inc_last_7-blt_inc_tab,blt_inc_next_7-blt_inc_tab,0
                  DC.W blt_inc_8-blt_inc_tab,blt_inc_last_8-blt_inc_tab,blt_inc_next_8-blt_inc_tab,0
                  DC.W blt_inc_9-blt_inc_tab,blt_inc_last_9-blt_inc_tab,blt_inc_next_9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,0,0,0
                  DC.W blt_inc_11-blt_inc_tab,blt_inc_last_11-blt_inc_tab,blt_inc_next_11-blt_inc_tab,0
                  DC.W blt_inc_12-blt_inc_tab,blt_inc_last_12-blt_inc_tab,blt_inc_next_12-blt_inc_tab,0
                  DC.W blt_inc_13-blt_inc_tab,blt_inc_last_13-blt_inc_tab,blt_inc_next_13-blt_inc_tab,0
                  DC.W blt_inc_14-blt_inc_tab,blt_inc_last_14-blt_inc_tab,blt_inc_next_14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,0,0,0

blt_inc_l_tab:    DC.W blt_inc_0-blt_inc_tab,0,0,0
                  DC.W blt_inc_l1-blt_inc_tab,blt_inc_last_l1-blt_inc_tab,blt_inc_next_l1-blt_inc_tab,0
                  DC.W blt_inc_l2-blt_inc_tab,blt_inc_last_l2-blt_inc_tab,blt_inc_next_l2-blt_inc_tab,0
                  DC.W blt_inc_l3-blt_inc_tab,blt_inc_last_l3-blt_inc_tab,blt_inc_next_l3-blt_inc_tab,0
                  DC.W blt_inc_l4-blt_inc_tab,blt_inc_last_l4-blt_inc_tab,blt_inc_next_l4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,0,0,0
                  DC.W blt_inc_l6-blt_inc_tab,blt_inc_last_l6-blt_inc_tab,blt_inc_next_l6-blt_inc_tab,0
                  DC.W blt_inc_l7-blt_inc_tab,blt_inc_last_l7-blt_inc_tab,blt_inc_next_l7-blt_inc_tab,0
                  DC.W blt_inc_l8-blt_inc_tab,blt_inc_last_l8-blt_inc_tab,blt_inc_next_l8-blt_inc_tab,0
                  DC.W blt_inc_l9-blt_inc_tab,blt_inc_last_l9-blt_inc_tab,blt_inc_next_l9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,0,0,0
                  DC.W blt_inc_l11-blt_inc_tab,blt_inc_last_l11-blt_inc_tab,blt_inc_next_l11-blt_inc_tab,0
                  DC.W blt_inc_l12-blt_inc_tab,blt_inc_last_l12-blt_inc_tab,blt_inc_next_l12-blt_inc_tab,0
                  DC.W blt_inc_l13-blt_inc_tab,blt_inc_last_l13-blt_inc_tab,blt_inc_next_l13-blt_inc_tab,0
                  DC.W blt_inc_l14-blt_inc_tab,blt_inc_last_l14-blt_inc_tab,blt_inc_next_l14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,0,0,0

blt_inc_r_tab:    DC.W blt_inc_0-blt_inc_tab,0,0,0
                  DC.W blt_inc_r1-blt_inc_tab,blt_inc_last_r1-blt_inc_tab,blt_inc_next_r1-blt_inc_tab,0
                  DC.W blt_inc_r2-blt_inc_tab,blt_inc_last_r2-blt_inc_tab,blt_inc_next_r2-blt_inc_tab,0
                  DC.W blt_inc_r3-blt_inc_tab,blt_inc_last_r3-blt_inc_tab,blt_inc_next_r3-blt_inc_tab,0
                  DC.W blt_inc_r4-blt_inc_tab,blt_inc_last_r4-blt_inc_tab,blt_inc_next_r4-blt_inc_tab,0
                  DC.W blt_inc_5-blt_inc_tab,0,0,0
                  DC.W blt_inc_r6-blt_inc_tab,blt_inc_last_r6-blt_inc_tab,blt_inc_next_r6-blt_inc_tab,0
                  DC.W blt_inc_r7-blt_inc_tab,blt_inc_last_r7-blt_inc_tab,blt_inc_next_r7-blt_inc_tab,0
                  DC.W blt_inc_r8-blt_inc_tab,blt_inc_last_r8-blt_inc_tab,blt_inc_next_r8-blt_inc_tab,0
                  DC.W blt_inc_r9-blt_inc_tab,blt_inc_last_r9-blt_inc_tab,blt_inc_next_r9-blt_inc_tab,0
                  DC.W blt_inc_10-blt_inc_tab,0,0,0
                  DC.W blt_inc_r11-blt_inc_tab,blt_inc_last_r11-blt_inc_tab,blt_inc_next_r11-blt_inc_tab,0
                  DC.W blt_inc_r12-blt_inc_tab,blt_inc_last_r12-blt_inc_tab,blt_inc_next_r12-blt_inc_tab,0
                  DC.W blt_inc_r13-blt_inc_tab,blt_inc_last_r13-blt_inc_tab,blt_inc_next_r13-blt_inc_tab,0
                  DC.W blt_inc_r14-blt_inc_tab,blt_inc_last_r14-blt_inc_tab,blt_inc_next_r14-blt_inc_tab,0
                  DC.W blt_inc_15-blt_inc_tab,0,0,0

blt_inc_0:        move.w   r_dwidth(a6),d7
                  not.w    d2
                  tst.w    d3             ;nur ein Wort ausgeben?
                  bne.s    blt_inc_more_0
                  add.w    a3,d7
blt_inc_word_0:   and.w    d2,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_word_0
                  not.w    d2
                  rts
blt_inc_more_0:   not.w    d3
                  moveq    #0,d6
blt_inc_bloop_0:  and.w    d2,(a1)
                  adda.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_0
blt_inc_loop_0:   move.w   d6,(a1)
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_0
blt_inc_jmp_0:    and.w    d3,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_bloop_0
                  not.w    d2
                  not.w    d3
                  rts

blt_inc_1:        move.w   (a0),d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_1

blt_inc_loop_1:   move.w   (a0),d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_1

blt_inc_jmp_1:    jmp      (a5)
blt_inc_last_1:   move.w   (a0),d6
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

blt_inc_next_1:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_1
                  rts

blt_inc_r1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r1

blt_inc_loop_r1:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r1

blt_inc_jmp_r1:   swap     d7
                  jmp      (a5)
blt_inc_last_r1:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)

blt_inc_next_r1:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r1
                  rts

blt_inc_l1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l1

blt_inc_loop_l1:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l1

blt_inc_jmp_l1:   jmp      (a5)
blt_inc_last_l1:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d3
                  or.w     d3,d7
                  not.w    d3
                  and.w    d7,(a1)


blt_inc_next_l1:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l1
                  rts

blt_inc_2:        move.w   (a0),d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_2

blt_inc_loop_2:   move.w   (a0),d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_2

blt_inc_jmp_2:    jmp      (a5)
blt_inc_last_2:   move.w   (a0),d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

blt_inc_next_2:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_2
                  rts

blt_inc_r2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r2

blt_inc_loop_r2:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
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

blt_inc_next_r2:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r2
                  rts

blt_inc_l2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l2

blt_inc_loop_l2:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
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

blt_inc_next_l2:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l2
                  rts

blt_inc_3:        move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_3

blt_inc_loop_3:   move.w   (a0),(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_3

blt_inc_jmp_3:    jmp      (a5)
blt_inc_last_3:   move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

blt_inc_next_3:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_3
                  rts

blt_inc_r3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r3

blt_inc_loop_r3:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  move.w   d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r3

blt_inc_jmp_r3:   swap     d7
                  jmp      (a5)
blt_inc_last_r3:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d3,(a1)
                  eor.w    d7,(a1)

blt_inc_next_r3:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r3
                  rts

blt_inc_l3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l3

blt_inc_loop_l3:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  move.w   d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l3

blt_inc_jmp_l3:   jmp      (a5)
blt_inc_last_l3:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d3,(a1)
                  eor.w    d7,(a1)

blt_inc_next_l3:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l3
                  rts

blt_inc_4:        move.w   (a0),d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_4

blt_inc_loop_4:   move.w   (a0),d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_4

blt_inc_jmp_4:    jmp      (a5)
blt_inc_last_4:   move.w   (a0),d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

blt_inc_next_4:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_4
                  rts

blt_inc_r4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r4

blt_inc_loop_r4:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r4

blt_inc_jmp_r4:   swap     d7
                  jmp      (a5)
blt_inc_last_r4:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_inc_next_r4:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r4
                  rts

blt_inc_l4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l4

blt_inc_loop_l4:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l4

blt_inc_jmp_l4:   jmp      (a5)
blt_inc_last_l4:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_inc_next_l4:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l4
                  rts

blt_inc_5:        rts

blt_inc_6:        move.w   (a0),d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_6

blt_inc_loop_6:   move.w   (a0),d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_6

blt_inc_jmp_6:    jmp      (a5)
blt_inc_last_6:   move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

blt_inc_next_6:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_6
                  rts

blt_inc_r6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r6

blt_inc_loop_r6:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r6

blt_inc_jmp_r6:   swap     d7
                  jmp      (a5)
blt_inc_last_r6:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_r6:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r6
                  rts

blt_inc_l6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l6

blt_inc_loop_l6:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l6

blt_inc_jmp_l6:   jmp      (a5)
blt_inc_last_l6:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_l6:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l6
                  rts

blt_inc_7:        move.w   (a0),d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_7

blt_inc_loop_7:   move.w   (a0),d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_7

blt_inc_jmp_7:    jmp      (a5)
blt_inc_last_7:   move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)

blt_inc_next_7:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_7
                  rts

blt_inc_r7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r7

blt_inc_loop_r7:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r7

blt_inc_jmp_r7:   swap     d7
                  jmp      (a5)
blt_inc_last_r7:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_r7:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r7
                  rts

blt_inc_l7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l7

blt_inc_loop_l7:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l7

blt_inc_jmp_l7:   jmp      (a5)
blt_inc_last_l7:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_l7:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l7
                  rts

blt_inc_8:        move.w   (a0),d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_8

blt_inc_loop_8:   move.w   (a0),d6
                  or.w     d6,(a1)
                  not.w    (a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_8

blt_inc_jmp_8:    jmp      (a5)
blt_inc_last_8:   move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

blt_inc_next_8:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_8
                  rts

blt_inc_r8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r8

blt_inc_loop_r8:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r8

blt_inc_jmp_r8:   swap     d7
                  jmp      (a5)
blt_inc_last_r8:  move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_r8:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r8
                  rts


blt_inc_l8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l8

blt_inc_loop_l8:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  or.w     d6,(a1)
                  not.w    (a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l8

blt_inc_jmp_l8:   jmp      (a5)
blt_inc_last_l8:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  or.w     d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_l8:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l8
                  rts


blt_inc_9:        move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_9

blt_inc_loop_9:   move.w   (a0),d6
                  not.w    d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_9

blt_inc_jmp_9:    jmp      (a5)
blt_inc_last_9:   move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

blt_inc_next_9:   adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_9
                  rts

blt_inc_r9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r9

blt_inc_loop_r9:  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r9

blt_inc_jmp_r9:   swap     d7
                  jmp      (a5)
blt_inc_last_r9:  move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_r9:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r9
                  rts

blt_inc_l9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l9

blt_inc_loop_l9:  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  dbra     d4,blt_inc_loop_l9

blt_inc_jmp_l9:   jmp      (a5)
blt_inc_last_l9:  move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  eor.w    d7,(a1)

blt_inc_next_l9:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l9
                  rts

blt_inc_10:       move.w   r_dwidth(a6),d7
                  tst.w    d3             ;nur ein Wort ausgeben?
                  bne.s    blt_inc_bloop_10
                  add.w    a3,d7
blt_inc_word_10:  eor.w    d2,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_word_10
                  rts
blt_inc_bloop_10: eor.w    d2,(a1)
                  adda.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_10
blt_inc_loop_10:  not.w    (a1)
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_10
blt_inc_jmp_10:   eor.w    d3,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_bloop_10
                  rts

blt_inc_11:       move.w   (a0),d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_11

blt_inc_loop_11:  move.w   (a0),d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_11

blt_inc_jmp_11:   jmp      (a5)
blt_inc_last_11:  move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

blt_inc_next_11:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_11
                  rts

blt_inc_r11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r11

blt_inc_loop_r11: move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r11

blt_inc_jmp_r11:  swap     d7
                  jmp      (a5)
blt_inc_last_r11: move.w   (a0),d7
                  ror.l    d0,d7
                  and.w    d3,d7
                  eor.w    d3,(a1)
                  or.w     d7,(a1)

blt_inc_next_r11: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r11
                  rts

blt_inc_l11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l11

blt_inc_loop_l11: move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l11

blt_inc_jmp_l11:  jmp      (a5)
blt_inc_last_l11: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  and.w    d3,d7
                  eor.w    d3,(a1)
                  or.w     d7,(a1)

blt_inc_next_l11: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l11
                  rts

blt_inc_12:       move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_12

blt_inc_loop_12:  move.w   (a0),d6
                  not.w    d6
                  move.w   d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_12

blt_inc_jmp_12:   jmp      (a5)
blt_inc_last_12:  move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  not.w    d3
                  and.w    d3,(a1)
                  not.w    d3
                  or.w     d6,(a1)

blt_inc_next_12:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_12
                  rts

blt_inc_r12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r12

blt_inc_loop_r12: move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
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

blt_inc_next_r12: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r12
                  rts

blt_inc_l12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l12

blt_inc_loop_l12: move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
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

blt_inc_next_l12: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l12
                  rts

blt_inc_13:       move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_13

blt_inc_loop_13:  move.w   (a0),d6
                  not.w    d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_13

blt_inc_jmp_13:   jmp      (a5)
blt_inc_last_13:  move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

blt_inc_next_13:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_13
                  rts

blt_inc_r13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r13

blt_inc_loop_r13: move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r13

blt_inc_jmp_r13:  swap     d7
                  jmp      (a5)
blt_inc_last_r13: move.w   (a0),d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_r13: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r13
                  rts

blt_inc_l13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l13

blt_inc_loop_l13: move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l13

blt_inc_jmp_l13:  jmp      (a5)
blt_inc_last_l13: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d3,d7
                  or.w     d7,(a1)

blt_inc_next_l13: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l13
                  rts

blt_inc_14:       move.w   (a0),d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_14

blt_inc_loop_14:  move.w   (a0),d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_14

blt_inc_jmp_14:   jmp      (a5)
blt_inc_last_14:  move.w   (a0),d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

blt_inc_next_14:  adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_14
                  rts

blt_inc_r14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_r14

blt_inc_loop_r14: move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_r14

blt_inc_jmp_r14:  swap     d7
                  jmp      (a5)
blt_inc_last_r14: move.w   (a0),d7
                  ror.l    d0,d7
                  or.w     d3,d7
                  and.w    d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_r14: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_r14
                  rts

blt_inc_l14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  adda.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1

                  move.w   d1,d4
                  bmi.s    blt_inc_jmp_l14

blt_inc_loop_l14: move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_l14

blt_inc_jmp_l14:  jmp      (a5)
blt_inc_last_l14: move.w   (a0),d7
                  swap     d7
                  rol.l    d0,d7
                  or.w     d3,d7
                  and.w    d7,(a1)
                  eor.w    d3,(a1)

blt_inc_next_l14: adda.w   r_swidth(a6),a0
                  adda.w   r_dwidth(a6),a1
                  dbra     d5,blt_inc_l14
                  rts

blt_inc_15:       moveq    #$ffffffff,d6
                  move.w   r_dwidth(a6),d7
                  tst.w    d3             ;nur ein Wort ausgeben?
                  bne.s    blt_inc_bloop_15
                  add.w    a3,d7
blt_inc_word_15:  or.w     d2,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_word_15
                  rts
blt_inc_bloop_15: or.w     d2,(a1)
                  adda.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_inc_last_15
blt_inc_loop_15:  move.w   d6,(a1)
                  adda.w   a3,a1
                  dbra     d4,blt_inc_loop_15
blt_inc_last_15:  or.w     d3,(a1)
                  adda.w   d7,a1
                  dbra     d5,blt_inc_bloop_15
                  rts

copy_inc:         subq.w   #2,d1
                  lea      -16(a3),a3
                  tst.w    d0             ;Shifts?
                  bne      copy_inc_shift

                  move.w   d2,d6
                  swap     d2
                  move.w   d6,d2
                  move.w   d3,d6
                  swap     d3
                  move.w   d6,d3
                  move.l   d2,d6
                  move.l   d3,d7
                  not.l    d6
                  not.l    d7

                  lea      -16(a2),a2

                  cmp.w    #-2,d1         ;nur ein Wort?
                  beq.s    copy_inc_word

copy_inc_bloop:   REPT 4
                  move.l   (a0)+,d0
                  and.l    d2,d0
                  and.l    d6,(a1)
                  or.l     d0,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    copy_inc_last

copy_inc_loop:    move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  dbra     d4,copy_inc_loop

copy_inc_last:    REPT 4
                  move.l   (a0)+,d0
                  and.l    d3,d0
                  and.l    d7,(a1)
                  or.l     d0,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_inc_bloop
                  rts

copy_inc_word:    and.l    d3,d2
                  or.l     d7,d6
copy_inc_word2:   REPT 4
                  move.l   (a0)+,d0
                  and.l    d2,d0
                  and.l    d6,(a1)
                  or.l     d0,(a1)+
                  ENDM
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_inc_word2
                  rts

copy_inc_shift:   cmpa.l   #blt_inc_r_tab,a4 ;nach rechts verschieben?
                  bne      copy_inc_left

copy_inc_right:   cmp.w    #4,d6          ;zwei Startworte lesen?
                  bne      copy_inc_fword_r
                  cmp.w    #-2,d1         ;nur ein Wort ausgeben?
                  beq      copy_il_right
                  tst.w    d7
                  bne      copy_ilw_r     ;kein zusaetzliches Endwort lesen

copy_ill_r:       REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  move.w   14(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_ill_last_r

copy_ill_loop_r:  REPT 4
                  move.l   (a0)+,d6
                  swap     d6
                  move.w   d6,d4
                  move.l   12(a0),d7
                  move.w   d7,d6
                  move.w   d4,d7
                  ror.l    d0,d6
                  ror.l    d0,d7
                  move.w   d6,d7
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d5,copy_ill_loop_r

copy_ill_last_r:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  move.w   14(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_ill_r
                  rts

copy_ilw_r:       REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  move.w   14(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_ilw_last_r

copy_ilw_loop_r:  REPT 4
                  move.l   (a0)+,d6
                  swap     d6
                  move.w   d6,d4
                  move.l   12(a0),d7
                  move.w   d7,d6
                  move.w   d4,d7
                  ror.l    d0,d6
                  ror.l    d0,d7
                  move.w   d6,d7
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d5,copy_ilw_loop_r

copy_ilw_last_r:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_ilw_r
                  rts

copy_il_right:    and.w    d3,d2
                  move.w   d2,d3
                  not.w    d3
copy_il_r:        REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  move.w   14(a0),d6
                  ror.l    d0,d6
                  and.w    d2,d6
                  and.w    d3,(a1)
                  or.w     d6,(a1)+
                  ENDM
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_il_r
                  rts

copy_inc_fword_r: cmp.w    #-2,d1         ;nur ein Wort ausgeben?
                  beq      copy_iw_right
                  tst.w    d7
                  bne      copy_iww_r     ;kein zusaetzliches Endwort lesen

copy_iwl_r:       REPT 8
                  move.w   (a0)+,d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM
                  lea      -16(a0),a0

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_iwl_last_r

copy_iwl_loop_r:  REPT 4
                  move.l   (a0)+,d6
                  swap     d6
                  move.w   d6,d4
                  move.l   12(a0),d7
                  move.w   d7,d6
                  move.w   d4,d7
                  ror.l    d0,d6
                  ror.l    d0,d7
                  move.w   d6,d7
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d5,copy_iwl_loop_r

copy_iwl_last_r:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  move.w   14(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iwl_r
                  rts

copy_iww_r:       REPT 8
                  move.w   (a0)+,d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM
                  lea      -16(a0),a0

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_iww_last_r

copy_iww_loop_r:  REPT 4
                  move.l   (a0)+,d6
                  swap     d6
                  move.w   d6,d4
                  move.l   12(a0),d7
                  move.w   d7,d6
                  move.w   d4,d7
                  ror.l    d0,d6
                  ror.l    d0,d7
                  move.w   d6,d7
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d5,copy_iww_loop_r

copy_iww_last_r:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iww_r
                  rts

copy_iw_right:    and.w    d3,d2
                  move.w   d2,d3
                  not.w    d3
                  lea      -16(a2),a2
copy_iw_r:        REPT 8
                  move.w   (a0)+,d6
                  ror.l    d0,d6
                  and.w    d2,d6
                  and.w    d3,(a1)
                  or.w     d6,(a1)+
                  ENDM
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iw_r
                  rts

copy_inc_left:    cmp.w    #4,d6          ;zwei Startworte lesen?
                  bne      copy_inc_fword_l
                  cmp.w    #-2,d1         ;nur ein Wort ausgeben?
                  beq      copy_il_left
                  tst.w    d7
                  bne      copy_ilw_l     ;kein zusaetzliches Endwort lesen

copy_ill_l:       REPT 8
                  move.w   16(a0),d6
                  swap     d6
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_ill_last_l

copy_ill_loop_l:  REPT 4
                  move.l   (a0)+,d6
                  move.l   12(a0),d7
                  swap     d7
                  move.l   d6,d4
                  move.w   d7,d4
                  move.w   d6,d7
                  rol.l    d0,d4
                  rol.l    d0,d7
                  move.w   d7,d4
                  move.l   d4,(a1)+
                  ENDM
                  dbra     d5,copy_ill_loop_l

copy_ill_last_l:  swap     d5
                  REPT 8
                  move.w   16(a0),d6
                  swap     d6
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_ill_l
                  rts

copy_ilw_l:       REPT 8
                  move.w   16(a0),d6
                  swap     d6
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_ilw_last_l

copy_ilw_loop_l:  REPT 4
                  move.l   (a0)+,d6
                  move.l   12(a0),d7
                  swap     d7
                  move.l   d6,d4
                  move.w   d7,d4
                  move.w   d6,d7
                  rol.l    d0,d4
                  rol.l    d0,d7
                  move.w   d7,d4
                  move.l   d4,(a1)+
                  ENDM
                  dbra     d5,copy_ilw_loop_l

copy_ilw_last_l:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_ilw_l
                  rts

copy_il_left:     and.w    d3,d2
                  move.w   d2,d3
                  not.w    d3
copy_il_l:        REPT 8
                  move.w   16(a0),d6
                  swap     d6
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  and.w    d2,d6
                  and.w    d3,(a1)
                  or.w     d6,(a1)+
                  ENDM
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_il_l
                  rts

copy_inc_fword_l: cmp.w    #-2,d1         ;nur ein Wort ausgeben?
                  beq      copy_iw_left
                  tst.w    d7
                  bne      copy_iww_l     ;kein zusaetzliches Endwort lesen

copy_iwl_l:       REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM
                  lea      -16(a0),a0

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_iwl_last_l

copy_iwl_loop_l:  REPT 4
                  move.l   (a0)+,d6
                  move.l   12(a0),d7
                  swap     d7
                  move.l   d6,d4
                  move.w   d7,d4
                  move.w   d6,d7
                  rol.l    d0,d4
                  rol.l    d0,d7
                  move.w   d7,d4
                  move.l   d4,(a1)+
                  ENDM
                  dbra     d5,copy_iwl_loop_l

copy_iwl_last_l:  swap     d5
                  REPT 8
                  move.w   16(a0),d6
                  swap     d6
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iwl_l
                  rts

copy_iww_l:       REPT 8
                  move.w   (a0)+,d6
                  swap     d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)+
                  ENDM
                  lea      -16(a0),a0

                  swap     d5
                  move.w   d1,d5
                  bmi.s    copy_iww_last_l

copy_iww_loop_l:  REPT 4
                  move.l   (a0)+,d6
                  move.l   12(a0),d7
                  swap     d7
                  move.l   d6,d4
                  move.w   d7,d4
                  move.w   d6,d7
                  rol.l    d0,d4
                  rol.l    d0,d7
                  move.w   d7,d4
                  move.l   d4,(a1)+
                  ENDM
                  dbra     d5,copy_iww_loop_l

copy_iww_last_l:  swap     d5
                  REPT 8
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iww_l
                  rts

copy_iw_left:     and.w    d3,d2
                  move.w   d2,d3
                  not.w    d3
                  lea      -16(a2),a2
copy_iw_l:        REPT 8
                  move.w   (a0)+,d6
                  rol.l    d0,d6
                  and.w    d2,d6
                  and.w    d3,(a1)
                  or.w     d6,(a1)+
                  ENDM
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,copy_iw_l
                  rts

bitblt_dec:       movea.l  r_saddr(a6),a0 ;Quelladresse
                  movea.l  r_daddr(a6),a1 ;Zieladresse

                  move.w   a2,d6          ;Bytes pro Zeile
                  add.w    d5,d1
                  mulu     d1,d6          ;* y-Quelle
                  adda.l   d6,a0          ;Zeilenanfang
                  move.w   d0,d6          ;x-Quelle
                  add.w    d4,d6
                  lsr.w    #4,d6
                  add.w    d6,d6
                  mulu     r_splanes(a6),d6
                  adda.l   d6,a0          ;Quellendadresse

                  move.w   a3,d6          ;Bytes pro Zeile
                  add.w    d5,d3
                  mulu     d3,d6          ;* y-Ziel
                  adda.l   d6,a1          ;Zeilenanfang
                  move.w   d2,d6          ;x-Ziel
                  add.w    d4,d6
                  lsr.w    #4,d6
                  add.w    d6,d6
                  mulu     r_dplanes(a6),d6
                  adda.l   d6,a1          ;Zielendadresse

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
                  move.w   d4,d6
                  mulu     r_snxtword(a6),d4
                  mulu     r_dnxtword(a6),d6
                  suba.w   d4,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

                  move.w   d7,d4          ;Quellwortanzahl - Zielwortanzahl

                  moveq    #4,d6          ;Sprungoffset fuers Einlesen des Startwort
                  moveq    #0,d7          ;Sprungoffset fuers Einlesen des Endworts
                  lea      blt_dec_tab(pc),a4

                  tst.w    d0             ;keine Shifts
                  beq.s    blt_dec_jmp
                  blt.s    blt_dec_right

blt_dec_left:     lea      blt_dec_l_tab(pc),a4

                  moveq    #10,d6         ;nur ein Endwort lesen

                  tst.w    d4
                  bpl.s    blt_dec_l_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mehr Ziel- als Quellbytes vorhanden sind

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
                  moveq    #12,d6         ;dann nur ein Quellwort einlesen
                  bra.s    blt_dec_jmp

blt_dec_r_end:    moveq    #4,d6          ;zwei Startworte einlesen
                  suba.w   r_snxtword(a6),a2 ;daher zwei zusaetzliche Quellbytes

                  tst.w    d4
                  bgt.s    blt_dec_r_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mindestens so viele Ziel- wie Quellbytes vorhanden sind

blt_dec_r_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach rechts?
                  ble.s    blt_dec_jmp

                  lea      blt_dec_l_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebungen nach links

blt_dec_jmp:      move.w   r_dplanes(a6),d4
                  cmp.w    r_splanes(a6),d4
                  bne.s    blt_dec_cnt
                  cmp.w    #8,d4          ;8 Ebenen kopieren?
                  bne.s    blt_dec_cnt
                  tst.l    r_fgcol(a6)
                  bne.s    blt_dec_cnt
                  cmpi.b   #3,r_wmode(a6)
                  beq      copy_dec

blt_dec_cnt:      subq.w   #1,d4          ;Zielebenenzaehler

                  move.w   a2,r_swidth(a6)
                  move.w   a3,r_dwidth(a6)

                  movea.w  r_snxtword(a6),a2
                  movea.w  r_dnxtword(a6),a3

                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_dec_loop

                  and.w    d2,d3          ;Start- und Endmaske
                  move.w   a2,d2
                  sub.w    d2,r_swidth(a6)
                  move.w   a3,d2
                  sub.w    d2,r_dwidth(a6)
                  moveq    #0,d2

blt_dec_loop:     movem.l  d1/d4-a1/a4,-(sp)
                  lea      r_fgcol(a6),a5
                  moveq    #0,d4
                  lsr.w    (a5)+
                  addx.w   d4,d4
                  lsr.w    (a5)+
                  addx.w   d4,d4
                  move.b   0(a5,d4.w),d4
                  lsl.w    #3,d4
                  movea.w  d4,a5
                  adda.l   a4,a5          ;Zeiger in Abstandstabelle
                  move.w   (a5)+,d4       ;Abstand zur BitBlt-Funktion
                  add.w    d4,d6          ;Offset fuer den ersten Sprung
                  add.w    (a5)+,d7       ;Offset fuer den zweiten Sprung
                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    blt_dec_offsets
                  move.w   (a5),d7        ;kein Endwort lesen und schreiben
blt_dec_offsets:  subq.w   #2,d1
                  lea      blt_dec_tab(pc),a4
                  lea      blt_dec_tab(pc),a5
                  adda.w   d6,a4
                  adda.w   d7,a5
                  jsr      blt_dec_tab(pc,d4.w)
                  movem.l  (sp)+,d1/d4-a1/a4
                  addq.l   #2,a1          ;naechste Zielebene
                  cmpi.w   #1,r_splanes(a6) ;vrt_cpyfm()?
                  beq.s    blt_dec_next
                  addq.l   #2,a0          ;naechste Quelleebene
blt_dec_next:     dbra     d4,blt_dec_loop
                  rts

blt_dec_tab:      DC.W blt_dec_0-blt_dec_tab,0,0,0
                  DC.W blt_dec_1-blt_dec_tab,blt_dec_last_1-blt_dec_tab,blt_dec_next_1-blt_dec_tab,0
                  DC.W blt_dec_2-blt_dec_tab,blt_dec_last_2-blt_dec_tab,blt_dec_next_2-blt_dec_tab,0
                  DC.W blt_dec_3-blt_dec_tab,blt_dec_last_3-blt_dec_tab,blt_dec_next_3-blt_dec_tab,0
                  DC.W blt_dec_4-blt_dec_tab,blt_dec_last_4-blt_dec_tab,blt_dec_next_4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_inc_tab,0,0,0
                  DC.W blt_dec_6-blt_dec_tab,blt_dec_last_6-blt_dec_tab,blt_dec_next_6-blt_dec_tab,0
                  DC.W blt_dec_7-blt_dec_tab,blt_dec_last_7-blt_dec_tab,blt_dec_next_7-blt_dec_tab,0
                  DC.W blt_dec_8-blt_dec_tab,blt_dec_last_8-blt_dec_tab,blt_dec_next_8-blt_dec_tab,0
                  DC.W blt_dec_9-blt_dec_tab,blt_dec_last_9-blt_dec_tab,blt_dec_next_9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_inc_tab,0,0,0
                  DC.W blt_dec_11-blt_dec_tab,blt_dec_last_11-blt_dec_tab,blt_dec_next_11-blt_dec_tab,0
                  DC.W blt_dec_12-blt_dec_tab,blt_dec_last_12-blt_dec_tab,blt_dec_next_12-blt_dec_tab,0
                  DC.W blt_dec_13-blt_dec_tab,blt_dec_last_13-blt_dec_tab,blt_dec_next_13-blt_dec_tab,0
                  DC.W blt_dec_14-blt_dec_tab,blt_dec_last_14-blt_dec_tab,blt_dec_next_14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_inc_tab,0,0,0

blt_dec_l_tab:    DC.W blt_dec_0-blt_dec_tab,0,0,0
                  DC.W blt_dec_l1-blt_dec_tab,blt_dec_last_l1-blt_dec_tab,blt_dec_next_l1-blt_dec_tab,0
                  DC.W blt_dec_l2-blt_dec_tab,blt_dec_last_l2-blt_dec_tab,blt_dec_next_l2-blt_dec_tab,0
                  DC.W blt_dec_l3-blt_dec_tab,blt_dec_last_l3-blt_dec_tab,blt_dec_next_l3-blt_dec_tab,0
                  DC.W blt_dec_l4-blt_dec_tab,blt_dec_last_l4-blt_dec_tab,blt_dec_next_l4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_inc_tab,0,0,0
                  DC.W blt_dec_l6-blt_dec_tab,blt_dec_last_l6-blt_dec_tab,blt_dec_next_l6-blt_dec_tab,0
                  DC.W blt_dec_l7-blt_dec_tab,blt_dec_last_l7-blt_dec_tab,blt_dec_next_l7-blt_dec_tab,0
                  DC.W blt_dec_l8-blt_dec_tab,blt_dec_last_l8-blt_dec_tab,blt_dec_next_l8-blt_dec_tab,0
                  DC.W blt_dec_l9-blt_dec_tab,blt_dec_last_l9-blt_dec_tab,blt_dec_next_l9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_inc_tab,0,0,0
                  DC.W blt_dec_l11-blt_dec_tab,blt_dec_last_l11-blt_dec_tab,blt_dec_next_l11-blt_dec_tab,0
                  DC.W blt_dec_l12-blt_dec_tab,blt_dec_last_l12-blt_dec_tab,blt_dec_next_l12-blt_dec_tab,0
                  DC.W blt_dec_l13-blt_dec_tab,blt_dec_last_l13-blt_dec_tab,blt_dec_next_l13-blt_dec_tab,0
                  DC.W blt_dec_l14-blt_dec_tab,blt_dec_last_l14-blt_dec_tab,blt_dec_next_l14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_inc_tab,0,0,0

blt_dec_r_tab:    DC.W blt_dec_0-blt_dec_tab,0,0,0
                  DC.W blt_dec_r1-blt_dec_tab,blt_dec_last_r1-blt_dec_tab,blt_dec_next_r1-blt_dec_tab,0
                  DC.W blt_dec_r2-blt_dec_tab,blt_dec_last_r2-blt_dec_tab,blt_dec_next_r2-blt_dec_tab,0
                  DC.W blt_dec_r3-blt_dec_tab,blt_dec_last_r3-blt_dec_tab,blt_dec_next_r3-blt_dec_tab,0
                  DC.W blt_dec_r4-blt_dec_tab,blt_dec_last_r4-blt_dec_tab,blt_dec_next_r4-blt_dec_tab,0
                  DC.W blt_dec_5-blt_inc_tab,0,0,0
                  DC.W blt_dec_r6-blt_dec_tab,blt_dec_last_r6-blt_dec_tab,blt_dec_next_r6-blt_dec_tab,0
                  DC.W blt_dec_r7-blt_dec_tab,blt_dec_last_r7-blt_dec_tab,blt_dec_next_r7-blt_dec_tab,0
                  DC.W blt_dec_r8-blt_dec_tab,blt_dec_last_r8-blt_dec_tab,blt_dec_next_r8-blt_dec_tab,0
                  DC.W blt_dec_r9-blt_dec_tab,blt_dec_last_r9-blt_dec_tab,blt_dec_next_r9-blt_dec_tab,0
                  DC.W blt_dec_10-blt_inc_tab,0,0,0
                  DC.W blt_dec_r11-blt_dec_tab,blt_dec_last_r11-blt_dec_tab,blt_dec_next_r11-blt_dec_tab,0
                  DC.W blt_dec_r12-blt_dec_tab,blt_dec_last_r12-blt_dec_tab,blt_dec_next_r12-blt_dec_tab,0
                  DC.W blt_dec_r13-blt_dec_tab,blt_dec_last_r13-blt_dec_tab,blt_dec_next_r13-blt_dec_tab,0
                  DC.W blt_dec_r14-blt_dec_tab,blt_dec_last_r14-blt_dec_tab,blt_dec_next_r14-blt_dec_tab,0
                  DC.W blt_dec_15-blt_inc_tab,0,0,0

blt_dec_0:        move.w   r_dwidth(a6),d7
                  not.w    d3
                  tst.w    d2             ;nur ein Wort ausgeben?
                  bne.s    blt_dec_more_0
                  add.w    a3,d7
blt_dec_word_0:   and.w    d3,(a1)
                  suba.w   d7,a1
                  dbra     d5,blt_dec_word_0
                  not.w    d3
                  rts
blt_dec_more_0:   not.w    d2
                  moveq    #0,d6
blt_dec_bloop_0:  and.w    d3,(a1)
                  suba.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_0
blt_dec_loop_0:   move.w   d6,(a1)
                  suba.w   a3,a1
                  dbra     d4,blt_dec_loop_0
blt_dec_jmp_0:    and.w    d2,(a1)
                  suba.w   d7,a1
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

blt_dec_loop_1:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  and.w    d6,(a1)

                  dbra     d4,blt_dec_loop_1

blt_dec_jmp_1:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_1:   move.w   (a0),d6
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)

blt_dec_next_1:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_1
                  rts

blt_dec_r1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d3
                  or.w     d3,d6
                  and.w    d6,(a1)
                  not.w    d3

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r1

blt_dec_loop_r1:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r1

blt_dec_jmp_r1:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r1:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_r1:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r1
                  rts

blt_dec_l1:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l1

blt_dec_loop_l1:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l1

blt_dec_jmp_l1:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l1:  move.w   (a0),d7
                  rol.l    d0,d7
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_l1:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
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

blt_dec_loop_2:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_2

blt_dec_jmp_2:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_2:   move.w   (a0),d6
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d6
                  not.w    d2
                  and.w    d6,(a1)

blt_dec_next_2:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_2
                  rts

blt_dec_r2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
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

blt_dec_loop_r2:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r2

blt_dec_jmp_r2:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r2:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_r2:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r2
                  rts

blt_dec_l2:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  eor.w    d3,(a1)
                  not.w    d3
                  or.w     d3,d6
                  not.w    d3
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l2

blt_dec_loop_l2:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l2

blt_dec_jmp_l2:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l2:  move.w   (a0),d7
                  rol.l    d0,d7
                  eor.w    d2,(a1)
                  not.w    d2
                  or.w     d2,d7
                  not.w    d2
                  and.w    d7,(a1)

blt_dec_next_l2:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l2
                  rts

blt_dec_3:        move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_3

blt_dec_loop_3:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),(a1)
                  dbra     d4,blt_dec_loop_3

blt_dec_jmp_3:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_3:   move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,(a1)
                  eor.w    d6,(a1)

blt_dec_next_3:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_3
                  rts

blt_dec_r3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r3

blt_dec_loop_r3:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  move.w   d6,(a1)
                  dbra     d4,blt_dec_loop_r3

blt_dec_jmp_r3:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r3:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d2,(a1)
                  eor.w    d7,(a1)

blt_dec_next_r3:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r3
                  rts

blt_dec_l3:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,(a1)
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l3

blt_dec_loop_l3:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  move.w   d6,(a1)
                  dbra     d4,blt_dec_loop_l3

blt_dec_jmp_l3:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l3:  move.w   (a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d2,(a1)
                  eor.w    d7,(a1)

blt_dec_next_l3:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l3
                  rts

blt_dec_4:        move.w   (a0),d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_4

blt_dec_loop_4:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    d6
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_4

blt_dec_jmp_4:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_4:   move.w   (a0),d6
                  and.w    d2,d6
                  not.w    d6
                  and.w    d6,(a1)

blt_dec_next_4:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_4
                  rts

blt_dec_r4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r4

blt_dec_loop_r4:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r4

blt_dec_jmp_r4:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r4:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_dec_next_r4:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r4
                  rts

blt_dec_l4:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  not.w    d6
                  and.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l4

blt_dec_loop_l4:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l4

blt_dec_jmp_l4:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l4:  move.w   (a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  not.w    d7
                  and.w    d7,(a1)

blt_dec_next_l4:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l4
                  rts

blt_dec_5:        rts

blt_dec_6:        move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_6

blt_dec_loop_6:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_6

blt_dec_jmp_6:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_6:   move.w   (a0),d6
                  and.w    d2,d6
                  eor.w    d6,(a1)

blt_dec_next_6:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_6
                  rts

blt_dec_r6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r6

blt_dec_loop_r6:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r6

blt_dec_jmp_r6:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r6:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  eor.w    d7,(a1)

blt_dec_next_r6:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r6
                  rts

blt_dec_l6:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l6

blt_dec_loop_l6:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l6

blt_dec_jmp_l6:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l6:  move.w   (a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  eor.w    d7,(a1)

blt_dec_next_l6:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l6
                  rts

blt_dec_7:        move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_7


blt_dec_loop_7:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_7

blt_dec_jmp_7:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_7:   move.w   (a0),d6
                  and.w    d2,d6
                  or.w     d6,(a1)

blt_dec_next_7:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_7
                  rts

blt_dec_r7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r7

blt_dec_loop_r7:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_r7

blt_dec_jmp_r7:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r7:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,(a1)

blt_dec_next_r7:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r7
                  rts

blt_dec_l7:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l7

blt_dec_loop_l7:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_l7

blt_dec_jmp_l7:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l7:  move.w   (a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,(a1)

blt_dec_next_l7:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l7
                  rts

blt_dec_8:        move.w   (a0),d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_8

blt_dec_loop_8:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  or.w     d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_8

blt_dec_jmp_8:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_8:   move.w   (a0),d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  eor.w    d2,(a1)

blt_dec_next_8:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_8
                  rts

blt_dec_r8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r8

blt_dec_loop_r8:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_r8

blt_dec_jmp_r8:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r8:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,(a1)
                  eor.w    d2,(a1)

blt_dec_next_r8:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r8
                  rts

blt_dec_l8:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l8

blt_dec_loop_l8:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_l8

blt_dec_jmp_l8:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l8:  move.w   (a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  or.w     d7,(a1)
                  eor.w    d2,(a1)

blt_dec_next_l8:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l8
                  rts

blt_dec_9:        move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_9

blt_dec_loop_9:   suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_9

blt_dec_jmp_9:    suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_9:   move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  eor.w    d6,(a1)

blt_dec_next_9:   suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_9
                  rts

blt_dec_r9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r9

blt_dec_loop_r9:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_r9

blt_dec_jmp_r9:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r9:  move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  eor.w    d7,(a1)

blt_dec_next_r9:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r9
                  rts

blt_dec_l9:       move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  eor.w    d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l9

blt_dec_loop_l9:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  eor.w    d6,(a1)
                  dbra     d4,blt_dec_loop_l9

blt_dec_jmp_l9:   suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l9:  move.w   (a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  eor.w    d7,(a1)

blt_dec_next_l9:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l9
                  rts


blt_dec_10:       move.w   r_dwidth(a6),d7
                  tst.w    d2             ;nur ein Wort ausgeben?
                  bne.s    blt_dec_bloop_10
                  add.w    a3,d7
blt_dec_word_10:  eor.w    d3,(a1)
                  suba.w   d7,a1
                  dbra     d5,blt_dec_word_10
                  rts
blt_dec_bloop_10: eor.w    d3,(a1)
                  suba.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_dec_last_10
blt_dec_loop_10:  not.w    (a1)
                  suba.w   a3,a1
                  dbra     d4,blt_dec_loop_10
blt_dec_last_10:  eor.w    d2,(a1)
                  suba.w   d7,a1
                  dbra     d5,blt_dec_bloop_10
                  rts

blt_dec_11:       move.w   (a0),d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_11

blt_dec_loop_11:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_11

blt_dec_jmp_11:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_11:  move.w   (a0),d6
                  and.w    d2,d6
                  eor.w    d2,(a1)
                  or.w     d6,(a1)

blt_dec_next_11:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_11
                  rts

blt_dec_r11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r11

blt_dec_loop_r11: suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_r11

blt_dec_jmp_r11:  suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r11: move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  and.w    d2,d7
                  eor.w    d2,(a1)
                  or.w     d7,(a1)

blt_dec_next_r11: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r11
                  rts

blt_dec_l11:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d3,d6
                  eor.w    d3,(a1)
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l11

blt_dec_loop_l11: suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    (a1)
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_l11

blt_dec_jmp_l11:  suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l11: move.w   (a0),d7
                  rol.l    d0,d7
                  and.w    d2,d7
                  eor.w    d2,(a1)
                  or.w     d7,(a1)

blt_dec_next_l11: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
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

blt_dec_loop_12:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    d6
                  move.w   d6,(a1)
                  dbra     d4,blt_dec_loop_12

blt_dec_jmp_12:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_12:  move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d6,(a1)

blt_dec_next_12:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_12
                  rts

blt_dec_r12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
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

blt_dec_loop_r12: suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)
                  dbra     d4,blt_dec_loop_r12

blt_dec_jmp_r12:  suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r12: move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d7,(a1)

blt_dec_next_r12: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r12
                  rts

blt_dec_l12:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
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

blt_dec_loop_l12: suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  move.w   d6,(a1)
                  dbra     d4,blt_dec_loop_l12

blt_dec_jmp_l12:  suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l12: move.w   (a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  not.w    d2
                  and.w    d2,(a1)
                  not.w    d2
                  or.w     d7,(a1)

blt_dec_next_l12: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l12
                  rts

blt_dec_13:       move.w   (a0),d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_13

blt_dec_loop_13:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  not.w    d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_13

blt_dec_jmp_13:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_13:  move.w   (a0),d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d6,(a1)

blt_dec_next_13:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_13
                  rts

blt_dec_r13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r13

blt_dec_loop_r13: suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_r13

blt_dec_jmp_r13:  suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r13: move.w   (a0),d7
                  swap     d7
                  ror.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d7,(a1)

blt_dec_next_r13: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r13
                  rts

blt_dec_l13:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d6,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l13

blt_dec_loop_l13: suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  not.w    d6
                  or.w     d6,(a1)
                  dbra     d4,blt_dec_loop_l13

blt_dec_jmp_l13:  suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l13: move.w   (a0),d7
                  rol.l    d0,d7
                  not.w    d7
                  and.w    d2,d7
                  or.w     d7,(a1)

blt_dec_next_l13: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l13
                  rts

blt_dec_14:       move.w   (a0),d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_14

blt_dec_loop_14:  suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   (a0),d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_14

blt_dec_jmp_14:   suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_14:  move.w   (a0),d6
                  or.w     d2,d6
                  and.w    d6,(a1)
                  or.w     d2,(a1)

blt_dec_next_14:  suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_14
                  rts

blt_dec_r14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_r14

blt_dec_loop_r14: suba.w   a2,a0
                  suba.w   a3,a1
                  move.l   d7,d6
                  move.w   (a0),d6
                  swap     d6
                  move.l   d6,d7
                  ror.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_r14

blt_dec_jmp_r14:  suba.w   a2,a0
                  suba.w   a3,a1
                  jmp      (a5)
blt_dec_last_r14: move.w   (a0),d7

                  swap     d7
                  ror.l    d0,d7
                  or.w     d2,d7
                  and.w    d7,(a1)
                  or.w     d2,(a1)

blt_dec_next_r14: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_r14
                  rts

blt_dec_l14:      move.w   (a0),d6
                  jmp      (a4)
                  swap     d6
                  suba.w   a2,a0
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  or.w     d3,d6
                  and.w    d6,(a1)
                  eor.w    d3,(a1)

                  move.w   d1,d4
                  bmi.s    blt_dec_jmp_l14

blt_dec_loop_l14: suba.w   a2,a0
                  suba.w   a3,a1
                  move.w   d7,d6
                  swap     d6
                  move.w   (a0),d6
                  move.w   d6,d7
                  rol.l    d0,d6
                  and.w    d6,(a1)
                  not.w    (a1)
                  dbra     d4,blt_dec_loop_l14

blt_dec_jmp_l14:  suba.w   a2,a0
                  suba.w   a3,a1
                  swap     d7
                  jmp      (a5)
blt_dec_last_l14: move.w   (a0),d7
                  rol.l    d0,d7
                  or.w     d2,d7
                  and.w    d7,(a1)
                  or.w     d2,(a1)

blt_dec_next_l14: suba.w   r_swidth(a6),a0
                  suba.w   r_dwidth(a6),a1
                  dbra     d5,blt_dec_l14
                  rts

blt_dec_15:       moveq    #$ffffffff,d6
                  move.w   r_dwidth(a6),d7
                  tst.w    d2             ;nur ein Wort ausgeben?
                  bne.s    blt_dec_bloop_15
                  add.w    a3,d7
blt_dec_word_15:  or.w     d3,(a1)
                  suba.w   d7,a1
                  dbra     d5,blt_dec_word_15
                  rts
blt_dec_bloop_15: or.w     d3,(a1)
                  suba.w   a3,a1
                  move.w   d1,d4
                  bmi.s    blt_dec_last_15
blt_dec_loop_15:  move.w   d6,(a1)
                  suba.w   a3,a1
                  dbra     d4,blt_dec_loop_15
blt_dec_last_15:  or.w     d2,(a1)
                  suba.w   d7,a1
                  dbra     d5,blt_dec_bloop_15
                  rts


copy_dec:         lea      16(a0),a0
                  lea      16(a1),a1
                  lea      -16(a3),a3

                  subq.w   #2,d1
                  tst.w    d0             ;Shifts?
                  bne      copyd_shift

                  move.w   d2,d6
                  swap     d2
                  move.w   d6,d2
                  move.w   d3,d6
                  swap     d3
                  move.w   d6,d3

                  lea      -16(a2),a2

                  cmp.w    #-2,d1         ;nur ein Wort?
                  beq.s    copyd_word_3

copyd_3:          REPT 4
                  move.l   -(a0),d6
                  not.l    d6
                  and.l    d3,d6
                  or.l     d3,-(a1)
                  eor.l    d6,(a1)
                  ENDM

                  move.w   d1,d4
                  bmi.s    copyd_last_3

copyd_loop_3:     move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  dbra     d4,copyd_loop_3

copyd_last_3:     REPT 4
                  move.l   -(a0),d6
                  not.l    d6
                  and.l    d2,d6
                  or.l     d2,-(a1)
                  eor.l    d6,(a1)
                  ENDM

                  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_3
                  rts

copyd_word_3:     and.l    d3,d2
copyd_word_loop_3:REPT 4
                  move.l   -(a0),d6
                  not.l    d6
                  and.l    d2,d6
                  or.l     d2,-(a1)
                  eor.l    d6,(a1)
                  ENDM

                  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_word_loop_3
                  rts

copyd_shift:      cmpa.l   #blt_dec_l_tab,a4
                  bne      copyd_right

copyd_left:       lea      copyd_flong_l3(pc),a4
                  cmp.w    #4,d6
                  beq.s    copyd_left_last
                  lea      copyd_fword_l3(pc),a4
copyd_left_last:  cmp.w    #-2,d1
                  bne.s    copyd_left_d7
                  and.w    d2,d3
                  lea      copyd_next_l3(pc),a5
                  bra.s    copyd_l3
copyd_left_d7:    lea      copyd_llong_l3(pc),a5
                  tst.w    d7
                  beq.s    copyd_l3
                  lea      copyd_lword_l3(pc),a5

copyd_l3:         jmp      (a4)

copyd_flong_l3:   REPT 8
                  move.w   -(a0),d6
                  swap     d6
                  move.w   -16(a0),d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,-(a1)
                  eor.w    d6,(a1)
                  ENDM

                  move.w   d1,d4
                  bpl.s    copyd_loop_l3
                  bmi      copyd_last_l3

copyd_fword_l3:   REPT 8
                  move.w   -(a0),d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,-(a1)
                  eor.w    d6,(a1)
                  ENDM
                  lea      16(a0),a0

                  move.w   d1,d4
                  bmi.s    copyd_last_l3

copyd_loop_l3:    REPT 8
                  move.w   -(a0),d6
                  swap     d6
                  move.w   -16(a0),d6
                  rol.l    d0,d6
                  move.w   d6,-(a1)
                  ENDM
                  dbra     d4,copyd_loop_l3

copyd_last_l3:    jmp      (a5)

copyd_llong_l3:   REPT 8
                  move.w   -(a0),d6
                  swap     d6
                  move.w   -16(a0),d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,-(a1)
                  eor.w    d6,(a1)
                  ENDM

copyd_next_l3:    suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_l3
                  rts

copyd_lword_l3:   REPT 8
                  move.w   -(a0),d6
                  swap     d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,-(a1)
                  eor.w    d6,(a1)
                  ENDM

                  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_l3
                  rts

copyd_right:      lea      copyd_flong_r3(pc),a4
                  cmp.w    #4,d6
                  beq.s    copyd_right_last
                  lea      copyd_fword_r3(pc),a4
copyd_right_last: cmp.w    #-2,d1         ;nur ein Wort ausgeben?
                  bne.s    copyd_right_d7
                  and.w    d2,d3
                  lea      copyd_next_r3(pc),a5
                  cmp.w    #12,d6         ;nur ein einziges Wort lesen?
                  beq      copyd_word_r3
                  bra.s    copyd_r3
copyd_right_d7:   lea      copyd_llong_r3(pc),a5
                  tst.w    d7
                  beq.s    copyd_r3
                  lea      copyd_lword_r3(pc),a5

copyd_r3:         jmp      (a4)
copyd_flong_r3:   REPT 8
                  move.w   -18(a0),d6
                  swap     d6
                  move.w   -(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,-(a1)
                  eor.w    d6,(a1)
                  ENDM

                  move.w   d1,d4
                  bpl.s    copyd_loop_r3
                  bmi      copyd_last_r3

copyd_fword_r3:   REPT 8
                  move.w   -(a0),d6
                  swap     d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,-(a1)
                  eor.w    d6,(a1)
                  ENDM
                  lea      16(a0),a0

                  move.w   d1,d4
                  bmi.s    copyd_last_r3

copyd_loop_r3:    REPT 8
                  move.w   -18(a0),d6
                  swap     d6
                  move.w   -(a0),d6
                  ror.l    d0,d6
                  move.w   d6,-(a1)
                  ENDM
                  dbra     d4,copyd_loop_r3

copyd_last_r3:    jmp      (a5)

copyd_llong_r3:   REPT 8
                  move.w   -18(a0),d6
                  swap     d6
                  move.w   -(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,-(a1)
                  eor.w    d6,(a1)
                  ENDM

copyd_next_r3:    suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_r3
                  rts

copyd_lword_r3:   REPT 8
                  move.w   -(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  or.w     d2,-(a1)
                  eor.w    d6,(a1)
                  ENDM

                  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_r3
                  rts

copyd_word_r3:    REPT 8
                  move.w   -(a0),d6
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  or.w     d3,-(a1)
                  eor.w    d6,(a1)
                  ENDM
                  lea      16(a0),a0
                  suba.w   a2,a0
                  suba.w   a3,a1
                  dbra     d5,copyd_word_r3
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

                  move.w   r_dplanes(a6),d0
scale_ver_loop:   movem.l  d0-d1/d3-d7/a4-a5,-(sp)
                  bsr      scale_ver
                  movem.l  (sp)+,d0-d1/d3-d7/a4-a5
                  tst.w    r_splanes(a6)                    ;nur eine Quellebene?
                  beq.s    scale_ver_nxdes
                  addq.l   #2,a4                            ;naechste Quellebene
scale_ver_nxdes:  addq.l   #2,a5                            ;naechste Zielebene
                  dbra     d0,scale_ver_loop

                  movea.l  (sp),a0                          ;Zeiger auf den Buffer
                  lea      SCALE_STACK(sp),sp
                  movea.l  (sp)+,a1                         ;Zeiger auf scale_buf_reset
                  jmp      (a1)                             ;Buffer freigeben


SP_OFFSET         EQU      10*4                             ;Register d0-d1/d3-d7/a4-a5 und eine Ruecksprungadresse

scale_ver:        cmp.w    d7,d6                            ;dy <= dx?
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

grow_ver_loop:    lea      SP_OFFSET+scale_registers(sp),a2 ;Zeiger auf Registerbuffer
                  movea.l  a4,a0                            ;Quelladresse
                  movea.l  SP_OFFSET+scale_buffer(sp),a1    ;Zeiger auf Zwischenbuffer
                  movea.l  SP_OFFSET+scale_jump(sp),a3      ;Zeiger auf scale_line
                  jsr      (a3)                             ;Zeile skalieren

grow_ver_test:    lea      SP_OFFSET+write_buffer(sp),a2
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

grow_ver_exit:    rts

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

shrink_ver_loop:  movea.l  SP_OFFSET+scale_jump(sp),a3      ;Zeiger auf scale_line
                  bra.s    shrink_ver_reg

shrink_ver_trans: movea.l  SP_OFFSET+scale_jump_trans(sp),a3   ;Zeiger auf scale_line_trans
shrink_ver_reg:   lea      SP_OFFSET+scale_registers(sp),a2    ;Zeiger auf Registerbuffer
                  movea.l  a4,a0                            ;Quelladresse
                  movea.l  SP_OFFSET+scale_buffer(sp),a1    ;Zeiger auf Zwischenbuffer
                  jsr      (a3)                             ;Zeile skalieren

shrink_ver_err:   adda.w   r_swidth(a6),a4                  ;naechste Quellzeile
                  add.w    d6,d5                            ;+ xa, naechste Quellzeile
                  bpl.s    shrink_ver_next                  ;Fehler >= 0, naechste Zielzeile?
                  dbra     d4,shrink_ver_trans              ;sind noch weitere Quellzeilen vorhanden?
   
                  moveq    #0,d4                            ;Zeile ausgeben und Funktion verlassen

shrink_ver_next:  lea      SP_OFFSET+write_buffer(sp),a2
                  movea.l  (a2)+,a0                         ;Zeiger auf den Zwischenbuffer
                  movea.l  a5,a1                            ;Zieladresse
                  movea.l  (a2)+,a3                         ;Zeiger auf write_line, a2 zeigt auf Registerbuffer
                  jsr      (a3)                             ;Zeile ausgeben

                  sub.w    d7,d5                            ;- ya, naechste Zielzeile
                  adda.w   r_dwidth(a6),a5                  ;naechste Zielzeile
                  dbra     d4,shrink_ver_loop               ;sind noch weitere Quellzeilen vorhanden?

                  rts

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
                  lsr.w    #4,d0                            ;Anzahl der Worte - 1
                  addq.w   #2,d0                            ;Anzahl der Worte + 1
                  add.w    d0,d0                            ;Anzahl der Bytes + 2
                  
                  movea.l  nvdi_struct(pc),a0
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

scale_addr_shft:  DC.B  1                                   ;1 Ebene
                  DC.B  2                                   ;2 Ebenen
                  DC.B  0
                  DC.B  3                                   ;4 Ebenen
                  DC.B  0
                  DC.B  0
                  DC.B  0
                  DC.B  4                                   ;8 Ebenen
                  
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
                  lsr.w    #4,d1
                  move.w   r_splanes(a6),d3
                  move.b   scale_addr_shft(pc,d3.w),d3
                  lsl.w    d3,d1
                  adda.w   d1,a1                            ;Quelladresse

scale_init_zx:    move.w   d2,d7                            ;zx
                  
                  move.w   d4,d2                            ;qdx
                  move.w   d6,d3                            ;zdx
                  
                  move.w   d0,d6                            ;qx
                  moveq    #15,d4
                  and.w    d6,d4                            ;Verschiebung der Quelldaten nach links
                  moveq    #15,d5
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
                  move.w   r_splanes(a6),d0
                  addq.w   #1,d0
                  add.w    d0,d0
                  move.w   d0,6*2(a2)                       ;Abstand zum naechsten Quellwort der gleichen Ebene
                  movea.l  a1,a0                            ;Quelladresse

                  lea      scale_line1(pc),a1
                  lea      scale_line1_trans(pc),a2

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
                  move.l   a4,-(sp)

                  movem.w  (a2),d2-d5/a2-a4                 ;Register besetzen
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
;d5.w Verschiebung der Zieldaten nach rechts (xd & 15)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w xa = Zielbreite = dy  (Fehler fuer Schritt zum naechsten Quellpixel)
;a3.w ya = Quellbreite = dx (Fehler fuer Schritt zum naechsten Zielpixel)
;a4.w Abstand zum naechsten Quellpixel der gleichen Ebene
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
                  move.w   (a0),d1
                  adda.w   a4,a0                            ;Adresse des naechsten Worts der gleichen Ebene
                  swap     d1
                  move.w   (a0),d1
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
grow_line1_exit:  movea.l  (sp)+,a4
                  movem.w  (sp)+,d4-d7
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
;a4.w Abstand zum naechsten Quellpixel der gleichen Ebene
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
                  move.w   (a0),d1
                  adda.w   a4,a0                            ;Adresse des naechsten Worts der gleichen Ebene
                  swap     d1
                  move.w   (a0),d1
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
shrink_line1_exit:movea.l  (sp)+,a4
                  movem.w  (sp)+,d4-d7
                  rts

write_addr_shft:  DC.B  1                                   ;1 Ebene
                  DC.B  2                                   ;2 Ebenen
                  DC.B  0
                  DC.B  3                                   ;4 Ebenen
                  DC.B  0
                  DC.B  0
                  DC.B  0
                  DC.B  4                                   ;8 Ebenen

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
                  move.w   d2,d3
                  lsr.w    #4,d3
                  move.w   r_dplanes(a6),d1
                  move.b   write_addr_shft(pc,d1.w),d1
                  lsl.w    d1,d3
                  adda.w   d3,a0                            ;Zieladresse
                  
                  move.w   d2,d0                            ;x1
                  move.w   d2,d1
                  add.w    d6,d1                            ;x2
                  
                  moveq    #15,d3
                  and.w    d3,d2
                  add.w    d2,d2
                  move.w   write_start_mask(pc,d2.w),d2
                  not.w    d2                               ;Startmaske

                  and.w    d1,d3
                  add.w    d3,d3
                  move.w   write_end_mask(pc,d3.w),d3       ;Endmaske
                  
                  lsr.w    #4,d0
                  lsr.w    #4,d1
                  neg.w    d0
                  add.w    d1,d0                            ;Anzahl der Worte - 1
                  
                  movem.w  d0/d2-d3,(a2)
                  move.w   r_dplanes(a6),d0
                  addq.w   #1,d0
                  add.w    d0,d0
                  move.w   d0,3*2(a2)                       ;Abstand zum naechsten Zielwort der gleichen Ebene
                  
                  moveq    #31,d0
                  and.w    r_wmode(a6),d0
                  cmp.w    #16,d0                           ;logische Verknuepfung?
                  blt.s    write_line_mode
                  
                  and.w    #3,d0                            ;Schreibmodus
                  add.w    d0,d0
                  add.w    d0,d0

                  moveq    #0,d1
                  lea      r_fgcol(a6),a1
                  lsr.w    (a1)+
                  addx.w   d1,d1                            ;Bit der Vordergrundfarbe
                  lsr.w    (a1)+
                  addx.w   d1,d1                            ;Bit der Hintergrundfarbe
                  add.w    d0,d1
                  move.b   wl_exp_modes(pc,d1.w),d0         ;logische Verknuepfung

write_line_mode:  add.w    d0,d0
                  move.w   wl_1_1_tab(pc,d0.w),d0           ;Offset der Funktion
                  lea      wl_1_1_tab(pc,d0.w),a1           ;Zeiger auf Ausgabefunktion
                  
                  movem.l  (sp)+,d0-d3
                  rts

wl_exp_modes:     DC.B 0,12,3,15          ;REPLACE
                  DC.B 4,4,7,7            ;OR
                  DC.B 6,6,6,6            ;EOR
                  DC.B 1,13,1,13          ;NOT OR

write_start_mask: DC.W %1111111111111111
write_end_mask:   DC.W %0111111111111111
                  DC.W %0011111111111111
                  DC.W %0001111111111111
                  DC.W %0000111111111111
                  DC.W %0000011111111111
                  DC.W %0000001111111111
                  DC.W %0000000111111111
                  DC.W %0000000011111111
                  DC.W %0000000001111111
                  DC.W %0000000000111111
                  DC.W %0000000000011111
                  DC.W %0000000000001111
                  DC.W %0000000000000111
                  DC.W %0000000000000011
                  DC.W %0000000000000001
                  DC.W %0000000000000000

wl_1_1_tab:       DC.W  wl_1_1_mode0-wl_1_1_tab
                  DC.W  wl_1_1_mode1-wl_1_1_tab
                  DC.W  wl_1_1_mode2-wl_1_1_tab
                  DC.W  wl_1_1_mode3-wl_1_1_tab
                  DC.W  wl_1_1_mode4-wl_1_1_tab
                  DC.W  wl_1_1_mode5-wl_1_1_tab
                  DC.W  wl_1_1_mode6-wl_1_1_tab
                  DC.W  wl_1_1_mode7-wl_1_1_tab
                  DC.W  wl_1_1_mode8-wl_1_1_tab
                  DC.W  wl_1_1_mode9-wl_1_1_tab
                  DC.W  wl_1_1_mode10-wl_1_1_tab
                  DC.W  wl_1_1_mode11-wl_1_1_tab
                  DC.W  wl_1_1_mode12-wl_1_1_tab
                  DC.W  wl_1_1_mode13-wl_1_1_tab
                  DC.W  wl_1_1_mode14-wl_1_1_tab
                  DC.W  wl_1_1_mode15-wl_1_1_tab

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile ausgeben, Modus 0 (ALL_ZERO)
wl_1_1_mode0:     movem.w  (a2),d0/d2-d3/a3

                  moveq    #0,d1
                  and.w    d2,(a1)                          ;Ziel maskieren
                  adda.w   a3,a1
                  
                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m0_2nd
                  
wl_1_1_m0_loop:   move.w   d1,(a1)                          ;Zwischenteil kopieren
                  adda.w   a3,a1 
                  dbra     d0,wl_1_1_m0_loop

wl_1_1_m0_end:    and.w    d3,(a1)                          ;Ziel maskieren
                  rts

wl_1_1_m0_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m0_end
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_1_1_mode1:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m1_2nd
                  
wl_1_1_m1_loop:   move.w   (a0)+,d1
                  and.w    d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m1_loop

wl_1_1_m1_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m1_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m1_end
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_1_1_mode2:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  not.w    d2
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m2_2nd
                  
wl_1_1_m2_loop:   move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  and.w    d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m2_loop

wl_1_1_m2_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  not.w    d3
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m2_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m2_end
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_1_1_mode3:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m3_2nd
                  
wl_1_1_m3_loop:   move.w   (a0)+,(a1)                       ;Zwischenteil kopieren
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m3_loop

wl_1_1_m3_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m3_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m3_end
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_1_1_mode4:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m4_2nd
                  
wl_1_1_m4_loop:   move.w   (a0)+,d1
                  not.w    d1
                  and.w    d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m4_loop

wl_1_1_m4_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m4_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m4_end
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_1_1_mode5:     rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_1_1_mode6:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m6_2nd
                  
wl_1_1_m6_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m6_loop

wl_1_1_m6_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m6_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m6_end
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_1_1_mode7:     movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m7_2nd
                  
wl_1_1_m7_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m7_loop

wl_1_1_m7_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m7_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m7_end
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_1_1_mode8:     movem.w  (a2),d0/d2-d3/a3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d2,(a1)
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m8_2nd
                  
wl_1_1_m8_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)
                  not.w    (a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m8_loop

wl_1_1_m8_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d3,(a1)
                  rts

wl_1_1_m8_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m8_end
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_1_1_mode9:     movem.w  (a2),d0/d2-d3/a3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d2,(a1)
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m9_2nd
                  
wl_1_1_m9_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)
                  not.w    (a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m9_loop

wl_1_1_m9_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d3,(a1)
                  rts

wl_1_1_m9_2nd:    addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m9_end
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_1_1_mode10:    movem.w  (a2),d0/d2-d3/a3

                  not.w    d2
                  not.w    d3
                  eor.w    d2,(a1)
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m10_2nd
                  
wl_1_1_m10_loop:  not.w    (a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m10_loop

wl_1_1_m10_end:   eor.w    d3,(a1)
                  rts

wl_1_1_m10_2nd:   addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m10_end
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_1_1_mode11:    movem.w  (a2),d0/d2-d3/a3

                  not.w    d2
                  not.w    d3
                  
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m11_2nd
                  
wl_1_1_m11_loop:  move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  or.w     d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m11_loop

wl_1_1_m11_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m11_2nd:   addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m11_end
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_1_1_mode12:    movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m12_2nd
                  
wl_1_1_m12_loop:  move.w   (a0)+,d1
                  not.w    d1
                  move.w   d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m12_loop

wl_1_1_m12_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m12_2nd:   addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m12_end
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_1_1_mode13:    movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)                          ;Wort ausgeben
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m13_2nd
                  
wl_1_1_m13_loop:  move.w   (a0)+,d1
                  not.w    d1
                  or.w     d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m13_loop

wl_1_1_m13_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)                          ;Wort ausgeben
                  rts

wl_1_1_m13_2nd:   addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m13_end
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_1_1_mode14:    movem.w  (a2),d0/d2-d3/a3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  and.w    d1,(a1)
                  not.w    d2
                  eor.w    d2,(a1)
                  adda.w   a3,a1

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m14_2nd
                  
wl_1_1_m14_loop:  move.w   (a0)+,d1
                  and.w    d1,(a1)
                  not.w    (a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m14_loop

wl_1_1_m14_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  and.w    d1,(a1)
                  not.w    d3
                  eor.w    d3,(a1)
                  rts

wl_1_1_m14_2nd:   addq.w   #1,d0                            ;Endwort ausgeben`
                  beq.s    wl_1_1_m14_end
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_1_1_mode15:    movem.w  (a2),d0/d2-d3/a3

                  moveq    #$ffffffff,d1
                  not.w    d2
                  not.w    d3
                  or.w     d2,(a1)                          ;Ziel maskieren

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m15_2nd
                  
wl_1_1_m15_loop:  move.w   d1,(a1)
                  adda.w   a3,a1
                  dbra     d0,wl_1_1_m15_loop

wl_1_1_m15_end:   or.w     d3,(a1)                          ;Ziel maskieren
                  rts

wl_1_1_m15_2nd:   addq.w   #1,d0                            ;Endwort ausgeben?
                  beq.s    wl_1_1_m15_end
                  rts
ENDIF
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'gefuelltes Rechteck'

;Start -und Endmasken
fboxm_mask:       DC.W $ffff
fboxm_mask2:      DC.W $7fff
                  DC.W $3fff
                  DC.W $1fff
                  DC.W $0fff
                  DC.W $07ff
                  DC.W $03ff
                  DC.W $01ff
                  DC.W $ff
                  DC.W $7f
                  DC.W $3f
                  DC.W $1f
                  DC.W $0f
                  DC.W $07
                  DC.W $03
                  DC.W $01
                  DC.W $00

;gefuelltes Reckteck ohne Clipping per Software zeichnen
;Eingaben
;d0 x1
;d1 y1
;d2 x2
;d3 y2
;a6 Zeiger auf die Workstation
;Ausgaben
;d0-d7/a0-a4/a6 werden zerstoert
fbox_mplane:      sub.w    d1,d3          ;Zeilenzaehler
                  moveq    #15,d4
                  moveq    #15,d5
                  and.w    d0,d5          ;Anzahl der Shifts fuer Startmaske
                  and.w    d2,d4          ;Anzahl der Shifts fuer Zielmaske

                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  move.w   BYTES_LIN.w,d6 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_mp_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d6 ;Bytes pro Zeile
fbox_mp_laddr:    move.w   d1,d7
                  muls     d6,d7
                  adda.l   d7,a1          ;Zeilenadresse
                  move.w   PLANES.w,d7
                  add.w    d7,d7
                  sub.w    d7,d6
                  movea.w  d6,a3          ;Bytes zur naechsten Zeile - Ebenen*2
                  asr.w    #4,d0
                  move.w   d0,d6
                  muls     d7,d6
                  adda.w   d6,a1          ;Startadresse

                  add.w    d4,d4
                  add.w    d5,d5
                  move.w   fboxm_mask2(pc,d4.w),d4 ;Endmaske
                  not.w    d4
                  swap     d4
                  move.w   fboxm_mask(pc,d5.w),d4 ;Startmaske

                  asr.w    #4,d2
                  sub.w    d0,d2          ;Anzahl der Worte -1
                  bne.s    fboxm_count
                  move.l   d4,d5
                  clr.w    d5
                  swap     d5
                  and.l    d5,d4

fboxm_count:      subq.w   #2,d2

                  movea.l  f_pointer(a6),a4
                  moveq    #15,d0
                  and.w    d1,d0
                  moveq    #15,d5
                  sub.w    d0,d5
                  add.w    d0,d0
                  adda.w   d0,a4

                  move.w   wr_mode(a6),d7
                  add.w    d7,d7
                  lea      fboxm_tab(pc),a2
                  adda.w   0(a2,d7.w),a2

                  move.w   f_color(a6),d0
                  lea      color_map(pc),a0
                  move.b   0(a0,d0.w),d0

                  move.w   PLANES.w,d1
                  subq.w   #1,d1
                  move.w   d1,-(sp)
                  move.w   d0,-(sp)
fboxm_loop:       swap     d3
                  movea.l  a4,a6
                  move.w   #16,d3         ;Abstand zum naechsten Wort der gleichen Ebene
                  move.w   (a4)+,d6

                  jmp      (a2)

fboxm_rtr_loop:   lea      32(a6),a6
                  move.w   (a6),d6
fboxm_rev_trans:  pea      fboxm_rtr_next(pc)
                  movea.l  a1,a0
                  not.w    d6
                  lsr.w    #1,d0          ;Ebene weiss oder schwarz?
                  bcs      fline_or
                  bra      fline_and
fboxm_rtr_next:   dbra     d1,fboxm_rtr_loop ;naechste Ebene
                  bra.s    fboxm_cont

fboxm_eor_loop:   lea      32(a6),a6
                  move.w   (a6),d6
fboxm_eor:        movea.l  a1,a0
                  bsr      fline_eor
                  dbra     d1,fboxm_eor_loop ;naechste Ebene
                  bra.s    fboxm_cont

fboxm_trans_loop: lea      32(a6),a6
                  move.w   (a6),d6
fboxm_trans:      pea      fboxm_trans_next(pc)
                  movea.l  a1,a0
                  lsr.w    #1,d0          ;Ebene weiss oder schwarz?
                  bcs      fline_or
                  bra      fline_and
fboxm_trans_next: dbra     d1,fboxm_trans_loop ;naechste Ebene
                  bra.s    fboxm_cont

fboxm_repl_loop:  lea      32(a6),a6
                  move.w   (a6),d6
fboxm_replace:    movea.l  a1,a0
                  lsr.w    #1,d0          ;Ebene weiss oder schwarz?
                  bcs.s    fboxm_repl_draw
                  clr.w    d6
fboxm_repl_draw:  bsr      fline_repl
                  dbra     d1,fboxm_repl_loop ;naechste Ebene

fboxm_cont:       swap     d3
                  move.w   (sp),d0
                  move.w   2(sp),d1

                  dbra     d5,fboxm_next
                  moveq    #15,d5
                  lea      -32(a4),a4

fboxm_next:       adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fboxm_loop
                  addq.l   #4,sp
                  rts


fboxm_tab:        DC.W fboxm_replace-fboxm_tab
                  DC.W fboxm_trans-fboxm_tab
                  DC.W fboxm_eor-fboxm_tab
                  DC.W fboxm_rev_trans-fboxm_tab

;Start -und Endmasken
fbox_mask:        DC.L $ffffffff
fbox_mask2:       DC.L $7fff7fff
                  DC.L $3fff3fff
                  DC.L $1fff1fff
                  DC.L $0fff0fff
                  DC.L $07ff07ff
                  DC.L $03ff03ff
                  DC.L $01ff01ff
                  DC.L $ff00ff
                  DC.L $7f007f
                  DC.L $3f003f
                  DC.L $1f001f
                  DC.L $0f000f
                  DC.L $070007
                  DC.L $030003
                  DC.L $010001
                  DC.L $00

;gefuelltes Reckteck ohne Clipping per Software zeichnen
;Vorgaben:
;d0-d7/a0-a4/a6 duerfen veraendert werden
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;a6.l Zeiger auf die Attributdaten
;Ausgaben:
;d0-d7/a0-a4/a6 werden veraendert
fbox:             tst.w    f_planes(a6)   ;mehrfarbiges Muster?
                  bne      fbox_mplane
fbox_saddr:       movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  move.w   BYTES_LIN.w,d6 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_build_masks
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d6 ;Bytes pro Zeile
fbox_build_masks: moveq    #15,d4
                  moveq    #15,d5
                  and.w    d0,d4          ;Anzahl der Shifts fuer Startmaske
                  and.w    d2,d5          ;Anzahl der Shifts fuer Zielmaske

                  add.w    d4,d4
                  add.w    d4,d4
                  add.w    d5,d5
                  add.w    d5,d5
                  lea      fbox_mask(pc),a0
                  move.l   0(a0,d4.w),d4  ;Starmaske
                  move.l   4(a0,d5.w),d5  ;Endmaske

                  movea.w  d6,a3          ;Bytes pro Zeile
                  muls     d1,d6
                  adda.l   d6,a1
                  andi.w   #$fff0,d0
                  adda.w   d0,a1          ;Startadresse

                  sub.w    d1,d3          ;Zeilenzaehler

                  andi.w   #$fff0,d2
                  sub.w    d0,d2          ;Anzahl der Bytes -8

                  move.w   wr_mode(a6),d7
                  bne.s    fbox_mode2
                  tst.w    f_color(a6)    ;weiss als Farbe ?
                  beq.s    fbox_white
                  tst.w    f_interior(a6)
                  bne.s    fbox_usual
                  bra.s    fbox_white

fbox_mode2:       cmp.w    #TRANSPARENT-REPLACE,d7
                  bne.s    fbox_usual
                  tst.w    f_color(a6)
                  bne.s    fbox_usual
                  cmpi.w   #F_SOLID,f_interior(a6)
                  bne.s    fbox_usual

fbox_white:       suba.w   d2,a3
                  suba.w   #16,a3
                  asr.w    #4,d2          ;Anzahl der Bytes pro Ebene -1
                  not.l    d4             ;Startmaske

                  subq.w   #1,d2          ;ein Wort pro Ebene ?
                  bmi.s    fbox_white1
                  subq.w   #1,d2          ;zwei Worte pro Ebene?
                  bmi.s    fbox_white2
                  moveq    #0,d6

fbox_white_bloop: move.w   d2,d1
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
fbox_white_loop:  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  dbra     d1,fbox_white_loop
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  adda.w   a3,a1
                  dbra     d3,fbox_white_bloop
                  rts

fbox_white1:      or.l     d5,d4
fbox_white1_loop: and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  adda.w   a3,a1
                  dbra     d3,fbox_white1_loop
                  rts

fbox_white2:      and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d4,(a1)+
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  and.l    d5,(a1)+
                  adda.w   a3,a1
                  dbra     d3,fbox_white2
                  rts

fbox_usual:       move.w   a3,d0          ;Bytes pro Zeile
                  lsl.w    #4,d0          ;Bytes pro 16 Zeilen
                  sub.w    d2,d0
                  sub.w    #16,d0         ;- Laenge der Linie in Bytes
                  movea.w  d0,a2
                  asr.w    #4,d2          ;Anzahl der Bytes pro Ebene -1

                  not.l    d5             ;Endmaske
                  movea.l  f_pointer(a6),a0
                  moveq    #15,d0
                  and.w    d1,d0
                  moveq    #15,d1
                  sub.w    d0,d1
                  add.w    d0,d0
                  adda.w   d0,a0

                  subq.w   #1,d2
                  bpl.s    fbox_mode

                  suba.w   #16,a2
                  and.l    d5,d4
                  moveq    #0,d5

fbox_mode:        subq.w   #1,d2

                  move.w   wr_mode(a6),d7 ;Replace
                  bne      fbox_eor

fbox_repl_sld:    move.w   f_interior(a6),d6
                  subq.w   #F_SOLID,d6    ;volles Muster?
                  beq      fbox_solid
                  subq.w   #F_PATTERN-F_SOLID,d6
                  bne.s    fbox_repl_col
                  cmpi.w   #8,f_style(a6) ;volles Muster?
                  beq      fbox_solid
fbox_repl_col:    move.w   f_color(a6),d6
                  subq.w   #BLACK,d6
                  bne      fbox_replace

                  moveq    #15,d0
                  cmp.w    d0,d3
                  bge.s    fbox_black2
                  and.w    d3,d0
fbox_black2:      swap     d3
                  move.w   d0,d3

fbox_black:       swap     d3

                  movea.l  a1,a4
                  adda.w   a3,a1          ;eine Zeile weiter

                  move.w   d3,d0
                  lsr.w    #4,d0

                  move.l   (a0),d6
                  move.w   (a0)+,d6

                  dbra     d1,fbox_black_bloop
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_black_bloop: move.l   d6,d7
                  not.l    d7
                  and.l    d4,d7
                  REPT 4
                  or.l     d4,(a4)
                  eor.l    d7,(a4)+
                  ENDM
                  move.w   d2,d7
                  bmi.s    fbox_black_last
fbox_black_loop:  REPT 4
                  move.l   d6,(a4)+
                  ENDM
                  dbra     d7,fbox_black_loop
fbox_black_last:  move.l   d6,d7
                  not.l    d7             ;Endmaske invertieren
                  and.l    d5,d7          ;Linienstil maskieren
                  REPT 4
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d7,(a4)+
                  ENDM
                  adda.w   a2,a4          ;16 Zeilen weiter
                  dbra     d0,fbox_black_bloop

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_black
                  rts

fbox_col_mask:    DC.L 0
                  DC.L $ffff0000
                  DC.L $ffff
                  DC.L $ffffffff

fbox_replace:     moveq    #15,d0
                  cmp.w    d0,d3
                  bge.s    fbox_replace2
                  and.w    d3,d0
fbox_replace2:    swap     d3
                  move.w   d0,d3

fbox_replace3:    swap     d3

                  move.w   d3,d0
                  lsr.w    #4,d0

                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7
                  dbra     d1,fbox_replace_col
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_replace_col:
                  movea.l  a1,a4
                  adda.w   a3,a1          ;eine Zeile weiter

                  move.w   d1,-(sp)
                  move.l   d3,-(sp)
                  move.l   a0,-(sp)
                  move.w   d0,-(sp)

                  move.w   f_color(a6),d0
                  lea      color_map(pc),a0
                  move.b   0(a0,d0.w),d0  ;Ebenenzuordnung
                  move.l   d6,d7          ;Linienstil duplizieren
                  move.l   d6,d3
                  movea.l  d6,a0
                  moveq    #3,d1
                  and.w    d0,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  and.l    fbox_col_mask(pc,d1.w),d6 ;Ebenen 0 und 1
                  moveq    #12,d1
                  and.w    d0,d1
                  and.l    fbox_col_mask(pc,d1.w),d7 ;Ebenen 2 und 3
                  moveq    #12,d1
                  lsr.w    #2,d0
                  and.w    d0,d1
                  and.l    fbox_col_mask(pc,d1.w),d3 ;Ebenen 4 und 5
                  lsr.w    #2,d0
                  and.w    #12,d0
                  move.l   a0,d1
                  and.l    fbox_col_mask(pc,d0.w),d1 ;Ebenen 6 und 7
                  movea.l  d1,a0
                  move.w   (sp)+,d0

fbox_replace_bloop:move.l  d6,d1
                  not.l    d1
                  and.l    d4,d1
                  or.l     d4,(a4)
                  eor.l    d1,(a4)+
                  move.l   d7,d1
                  not.l    d1
                  and.l    d4,d1
                  or.l     d4,(a4)
                  eor.l    d1,(a4)+
                  move.l   d3,d1
                  not.l    d1
                  and.l    d4,d1
                  or.l     d4,(a4)
                  eor.l    d1,(a4)+
                  move.l   a0,d1
                  not.l    d1
                  and.l    d4,d1
                  or.l     d4,(a4)
                  eor.l    d1,(a4)+
                  move.w   d2,d1
                  bmi.s    fbox_replace_last
fbox_replace_loop:move.l   d6,(a4)+
                  move.l   d7,(a4)+
                  move.l   d3,(a4)+
                  move.l   a0,(a4)+
                  dbra     d1,fbox_replace_loop
fbox_replace_last:
                  move.l   d6,d1
                  not.l    d1             ;Endmaske invertieren
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d1,(a4)+

                  move.l   d7,d1
                  not.l    d1             ;Endmaske invertieren
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d1,(a4)+
                  move.l   d3,d1
                  not.l    d1             ;Endmaske invertieren
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d1,(a4)+
                  move.l   a0,d1
                  not.l    d1             ;Endmaske invertieren
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d1,(a4)+
                  adda.w   a2,a4          ;16 Zeilen weiter
                  dbra     d0,fbox_replace_bloop

                  movea.l  (sp)+,a0
                  move.l   (sp)+,d3
                  move.w   (sp)+,d1

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_replace3
                  rts

fbox_scol_mask:   DC.L 0
                  DC.L $ffff0000
                  DC.L $ffff
                  DC.L $ffffffff

fbox_solid:       move.w   f_color(a6),d0
                  lea      color_map(pc),a0
                  move.b   0(a0,d0.w),d0  ;Ebenenzuordnung
                  moveq    #3,d1
                  and.w    d0,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  move.l   fbox_scol_mask(pc,d1.w),d6 ;Ebenen 0 und 1
                  moveq    #12,d1
                  and.w    d0,d1
                  move.l   fbox_scol_mask(pc,d1.w),d7 ;Ebenen 2 und 3
                  moveq    #12,d1
                  lsr.w    #2,d0
                  and.w    d0,d1
                  move.l   fbox_scol_mask(pc,d1.w),d1 ;Ebenen 4 und 5
                  lsr.w    #2,d0
                  and.w    #12,d0
                  movea.l  fbox_scol_mask(pc,d0.w),a0 ;Ebenen 6 und 7

fbox_solid_bloop: movea.l  a1,a4

                  move.l   d6,d0
                  not.l    d0
                  and.l    d4,d0
                  or.l     d4,(a4)
                  eor.l    d0,(a4)+
                  move.l   d7,d0
                  not.l    d0
                  and.l    d4,d0
                  or.l     d4,(a4)
                  eor.l    d0,(a4)+
                  move.l   d1,d0
                  not.l    d0
                  and.l    d4,d0
                  or.l     d4,(a4)
                  eor.l    d0,(a4)+
                  move.l   a0,d0
                  not.l    d0
                  and.l    d4,d0
                  or.l     d4,(a4)
                  eor.l    d0,(a4)+
                  move.w   d2,d0
                  bmi.s    fbox_solid_last
fbox_solid_loop:  move.l   d6,(a4)+
                  move.l   d7,(a4)+
                  move.l   d1,(a4)+
                  move.l   a0,(a4)+
                  dbra     d0,fbox_solid_loop

fbox_solid_last:  move.l   d6,d0
                  not.l    d0             ;Endmaske invertieren
                  and.l    d5,d0          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d0,(a4)+
                  move.l   d7,d0
                  not.l    d0             ;Endmaske invertieren
                  and.l    d5,d0          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d0,(a4)+
                  move.l   d1,d0
                  not.l    d0             ;Endmaske invertieren
                  and.l    d5,d0          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d0,(a4)+
                  move.l   a0,d0
                  not.l    d0             ;Endmaske invertieren
                  and.l    d5,d0          ;Linienstil maskieren
                  or.l     d5,(a4)        ;Bildinhalt maskieren
                  eor.l    d0,(a4)+

                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_solid_bloop

                  rts


fbox_eor:         subq.w   #EX_OR-REPLACE,d7
                  bne.s    fbox_rev_trans

                  moveq    #15,d0
                  cmp.w    d0,d3
                  bge.s    fbox_eor2
                  and.w    d3,d0
fbox_eor2:        swap     d3
                  move.w   d0,d3

fbox_eor_bloop:   swap     d3

                  movea.l  a1,a4
                  adda.w   a3,a1          ;eine Zeile weiter

                  move.w   d3,d0
                  lsr.w    #4,d0

                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  dbra     d1,fbox_eor_loop16
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_eor_loop16:  move.l   d6,d7
                  and.l    d4,d7
                  REPT 4
                  eor.l    d7,(a4)+
                  ENDM
                  move.w   d2,d7
                  bmi.s    fbox_eor_last
fbox_eor_loop:    REPT 4
                  eor.l    d6,(a4)+
                  ENDM
                  dbra     d7,fbox_eor_loop
fbox_eor_last:    move.l   d6,d7
                  and.l    d5,d7          ;Linienstil maskieren
                  REPT 4
                  eor.l    d7,(a4)+
                  ENDM
                  adda.w   a2,a4          ;16 Zeilen weiter
                  dbra     d0,fbox_eor_loop16

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_eor_bloop
                  rts

fbox_rev_trans:   tst.w    d7
                  bmi.s    fbox_trans
                  tst.w    f_interior(a6)
                  beq      fbox_repl_sld
                  move.l   a0,d0
                  movea.l  buffer_addr(a6),a0
                  movea.l  f_pointer(a6),a4
                  sub.l    a4,d0
                  REPT 8
                  move.l   (a4)+,(a0)
                  not.l    (a0)+
                  ENDM
                  lea      -32(a0),a0
                  adda.w   d0,a0
                  bra.s    fbox_trans_save
fbox_trans:       cmpi.w   #F_SOLID,f_interior(a6)
                  beq      fbox_repl_sld

fbox_trans_save:  move.l   a5,-(sp)

                  move.w   a3,d0
                  lsl.w    #4,d0
                  sub.w    #16,d0
                  movea.w  d0,a2

                  moveq    #15,d0
                  cmp.w    d0,d3
                  bge.s    fbox_trans2
                  and.w    d3,d0
fbox_trans2:      swap     d3
                  move.w   d0,d3

fbox_trans3:      swap     d3

                  movea.l  a1,a5
                  adda.w   a3,a1

                  move.w   d3,d0
                  lsr.w    #4,d0

                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  dbra     d1,fbox_trans_bloop
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_trans_bloop: movem.w  d0-d1,-(sp)
                  bsr.s    fbox_trans_line
                  movem.w  (sp)+,d0-d1

                  adda.w   a2,a5          ;16 Zeilen weiter
                  dbra     d0,fbox_trans_bloop

                  subq.w   #1,d3
                  swap     d3
                  dbra     d3,fbox_trans3
                  movea.l  (sp)+,a5
                  rts

fbox_trans_line:  move.w   f_color(a6),d0
                  lea      color_map(pc),a4
                  move.b   0(a4,d0.w),d0
                  moveq    #7,d1          ;Anzahl der Ebenen

fbox_trans_loop:  movea.l  a5,a4
                  lsr.w    #1,d0
                  bcc.s    fbox_and

                  move.w   d6,d7
                  and.w    d4,d7
                  or.w     d7,(a5)+       ;1 Plane weiter
                  move.w   d2,d7

                  bmi.s    fbox_or_last
fbox_or_loop:     lea      16(a4),a4
                  or.w     d6,(a4)
                  dbra     d7,fbox_or_loop
fbox_or_last:     lea      16(a4),a4
                  move.w   d6,d7
                  and.w    d5,d7
                  or.w     d7,(a4)
                  dbra     d1,fbox_trans_loop ;naechste Plane
                  rts

fbox_and:         move.w   d6,d7
                  and.w    d4,d7
                  not.w    d7
                  and.w    d7,(a5)+       ;1 Plane weiter
                  not.w    d6
                  move.w   d2,d7
                  bmi.s    fbox_and_last
fbox_and_loop:    lea      16(a4),a4
                  and.w    d6,(a4)
                  dbra     d7,fbox_and_loop
fbox_and_last:    lea      16(a4),a4
                  not.w    d6
                  move.w   d6,d7
                  and.w    d5,d7
                  not.w    d7
                  and.w    d7,(a4)
                  dbra     d1,fbox_trans_loop ;naechste Plane
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'horizontale Linie'

;Start -und Endmasken
fline_mask:       DC.W $ffff
fline_mask2:      DC.W $7fff
                  DC.W $3fff
                  DC.W $1fff
                  DC.W $0fff
                  DC.W $07ff
                  DC.W $03ff
                  DC.W $01ff
                  DC.W $ff
                  DC.W $7f
                  DC.W $3f
                  DC.W $1f
                  DC.W $0f
                  DC.W $07
                  DC.W $03
                  DC.W $01
                  DC.W $00

fline_saddr_pat:  movem.l  d3/a0/a2,-(sp)
                  movea.l  f_pointer(a6),a2
                  moveq    #15,d3
                  and.w    d1,d3
                  add.w    d3,d3
                  adda.w   d3,a2

                  moveq    #15,d4
                  moveq    #15,d5
                  and.w    d0,d5          ;Anzahl der Shifts der Startmaske
                  and.w    d2,d4          ;Anzahl der Shifts der Endmaske

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap
                  beq.s    fline_pat_screen
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    fbox_pat_masks
fline_pat_screen: movea.l  v_bas_ad.w,a1  ;Adresse des Bilschirms
                  muls     BYTES_LIN.w,d1
fbox_pat_masks:   add.w    d4,d4
                  add.w    d5,d5
                  move.w   fline_mask2(pc,d4.w),d4 ;Endmaske
                  not.w    d4
                  swap     d4
                  move.w   fline_mask(pc,d5.w),d4 ;Startmaske

                  adda.l   d1,a1          ;Zeilenadresse
                  moveq    #$fffffff0,d1
                  and.w    d0,d1
                  adda.w   d1,a1          ;Adresse des ersten Wortes

                  asr.w    #4,d0
                  asr.w    #4,d2
                  sub.w    d0,d2          ;Anzahl der Worte pro Ebene -1
                  bne.s    fline_count_pat ;nur ein Wort pro Ebene?

                  move.l   d4,d5
                  clr.w    d5
                  swap     d5
                  and.l    d5,d4

fline_count_pat:  subq.w   #2,d2          ;Wortzaehler

                  moveq    #7,d1          ;Ebenenzaehler
                  moveq    #16,d3         ;Bytes zum naechsten Wort der Ebene

                  lea      color_map(pc),a0
                  move.w   f_color(a6),d0 ;Musterfarbe
                  move.b   0(a0,d0.w),d0  ;Ebenenzuordnung

                  move.b   fline_pat_tab(pc,d7.w),d7
                  jsr      fline_pat_tab(pc,d7.w)

                  movem.l  (sp)+,d3/a0/a2
                  rts

fline_pat_tab:    DC.B fline_repl_pat-fline_pat_tab
                  DC.B fline_trans_pat-fline_pat_tab
                  DC.B fline_xor_pat-fline_pat_tab
                  DC.B fline_rtr_pat-fline_pat_tab

fline_repl_pat:   movea.l  a1,a0
                  move.w   (a2),d6
                  lea      32(a2),a2      ;naechste Musterebene
                  lsr.w    #1,d0
                  bcs.s    fline_r_pat
                  clr.w    d6
fline_r_pat:      bsr.s    fline_repl
                  dbra     d1,fline_repl_pat ;naechste Ebene
                  rts

fline_trans_pat:  pea      fline_trp_next(pc)
                  move.w   (a2),d6
                  lea      32(a2),a2      ;naechste Musterebene
                  movea.l  a1,a0
                  lsr.w    #1,d0
                  bcs.s    fline_or
                  bra.s    fline_and
fline_trp_next:   dbra     d1,fline_trans_pat ;naechste Ebene
                  rts
fline_xor_pat:    movea.l  a1,a0
                  move.w   (a2),d6
                  lea      32(a2),a2      ;naechste Musterebene
                  bsr      fline_eor
                  dbra     d1,fline_xor_pat ;naechste Ebene
                  rts
fline_rtr_pat:    pea      fline_rtrp_next(pc)
                  move.w   (a2),d6
                  not.w    d6
                  lea      32(a2),a2      ;naechste Musterebene
                  movea.l  a1,a0
                  lsr.w    #1,d0
                  bcs.s    fline_or
                  bra.s    fline_and
fline_rtrp_next:  dbra     d1,fline_rtr_pat ;naechste Ebene
                  rts
;Eingaben
;d2.w Wortzaehler
;d3.w Abstand zum naechsten Wort der Ebene
;d4.w Startmaske
;d5.w Endmaske
;d6.w Linienmuster
;a0.l Startadresse
;a1.l Startadresse
;Ausgaben
;d2.w Wortzaehler
;d3.w Abstand zum naechsten Wort der Ebene
;d4.w Startmaske
;d5.w Endmaske
;d6.w Linienmuster
;a1.l Startadresse+2
;d7/a0 werden zerstoert
fline_repl:       move.w   d6,d7
                  not.w    d7
                  and.w    d4,d7
                  or.w     d4,(a1)
                  eor.w    d7,(a1)+       ;1 Ebene weiter
                  move.w   d2,d7
                  bmi.s    fline_r_last
fline_r_loop:     adda.w   d3,a0          ;naechstes Wort der Ebene
                  move.w   d6,(a0)
                  dbra     d7,fline_r_loop
fline_r_last:     adda.w   d3,a0
                  swap     d4
                  move.w   d6,d7
                  not.w    d7
                  and.w    d4,d7
                  or.w     d4,(a0)
                  eor.w    d7,(a0)
                  swap     d4
                  rts

fline_or:         move.w   d6,d7
                  and.w    d4,d7
                  or.w     d7,(a1)+       ;1 Ebene weiter
                  move.w   d2,d7
                  bmi.s    fline_or_last
fline_or_loop:    adda.w   d3,a0          ;naechstes Wort der Ebene
                  or.w     d6,(a0)
                  dbra     d7,fline_or_loop
fline_or_last:    adda.w   d3,a0          ;naechstes Wort der Ebene
                  swap     d4
                  move.w   d6,d7
                  and.w    d4,d7
                  or.w     d7,(a0)
                  swap     d4
                  rts

fline_and:        move.w   d6,d7
                  and.w    d4,d7
                  not.w    d7
                  and.w    d7,(a1)+       ;1 Ebene weiter
                  not.w    d6
                  move.w   d2,d7
                  bmi.s    fline_and_last
fline_and_loop:   adda.w   d3,a0          ;naechstes Wort der Ebene
                  and.w    d6,(a0)
                  dbra     d7,fline_and_loop
fline_and_last:   adda.w   d3,a0          ;naechstes Wort der Ebene
                  swap     d4
                  not.w    d6
                  move.w   d6,d7
                  and.w    d4,d7
                  not.w    d7
                  and.w    d7,(a0)
                  swap     d4
                  rts

fline_eor:        move.w   d6,d7
                  and.w    d4,d7
                  eor.w    d7,(a1)+       ;1 Ebene weiter
                  move.w   d2,d7
                  bmi.s    fline_eor_last
fline_eor_loop:   adda.w   d3,a0          ;naechstes Wort der Ebene
                  eor.w    d6,(a0)
                  dbra     d7,fline_eor_loop
fline_eor_last:   adda.w   d3,a0          ;naechstes Wort der Ebene
                  swap     d4
                  move.w   d6,d7
                  and.w    d4,d7
                  eor.w    d7,(a0)
                  swap     d4
                  rts

fline:            tst.w    f_planes(a6)
                  bne      fline_saddr_pat
fline_mono:       move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6
                  bsr.s    hline
                  move.w   (sp)+,l_color(a6)
                  rts

;Start -und Endmasken
hline_mask:       DC.L $ffffffff
hline_mask2:      DC.L $7fff7fff
                  DC.L $3fff3fff
                  DC.L $1fff1fff
                  DC.L $0fff0fff
                  DC.L $07ff07ff
                  DC.L $03ff03ff
                  DC.L $01ff01ff
                  DC.L $ff00ff
                  DC.L $7f007f
                  DC.L $3f003f
                  DC.L $1f001f
                  DC.L $0f000f
                  DC.L $070007
                  DC.L $030003
                  DC.L $010001
                  DC.L $00

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
hline:            tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr
hline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bilschirms
                  muls     BYTES_LIN.w,d1
hline_laddr:      adda.l   d1,a1          ;Zeilenadresse
                  moveq    #15,d4
                  and.w    d0,d4          ;Anzahl der Shifts der Startmaske
                  moveq    #15,d5
                  and.w    d2,d5          ;Anzahl der Shifts der Endmaske
                  andi.w   #$fff0,d0
                  adda.w   d0,a1          ;Adresse des ersten Wortes

                  add.w    d4,d4
                  add.w    d4,d4
                  move.l   hline_mask(pc,d4.w),d4 ;Startmaske
                  add.w    d5,d5
                  add.w    d5,d5
                  move.l   hline_mask2(pc,d5.w),d5
                  not.l    d5             ;Endmaske

                  andi.w   #$fff0,d2
                  sub.w    d0,d2          ;Anzahl der Bytes - 8
                  asr.w    #4,d2          ;Anzahl der Worte pro Ebene - 1

                  subq.w   #TRANSPARENT-REPLACE,d7 ;TRANSPARENT ?
                  beq      hline_trans
                  subq.w   #REV_TRANS-TRANSPARENT,d7 ;REVERS TRANSPARENT ?
                  beq      hline_rev_trans

                  move.w   d6,d1
                  swap     d6
                  move.w   d1,d6          ;32-Bit-Linienmuster

                  addq.w   #REV_TRANS-EX_OR,d7 ;EOR ?
                  beq      hline_eor

                  move.w   l_color(a6),d7
                  subq.w   #BLACK,d7      ;schwarz ?
                  bne      hline_replace

                  subq.w   #1,d2
                  bmi.s    hline_blackw1  ;ein Wort ?
                  subq.w   #1,d2
                  bmi.s    hline_blackw2  ;zwei Worte ?

                  cmp.w    #$ffff,d6      ;durchgehend ?
                  bne.s    hline_black

                  or.l     d4,(a1)+
                  or.l     d4,(a1)+
                  or.l     d4,(a1)+
                  or.l     d4,(a1)+
hloop_solid:      move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  dbra     d2,hloop_solid
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)
                  rts

hline_black:      move.l   d6,d7
                  and.l    d4,d7          ;Linienmuster maskieren
                  not.l    d4             ;Startmaske invertieren
                  REPT 4
                  and.l    d4,(a1)        ;Bildinhalt maskieren
                  or.l     d7,(a1)+       ;Linienstil ausgeben
                  ENDM
hloop_black:      move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  move.l   d6,(a1)+
                  dbra     d2,hloop_black
                  and.l    d5,d6          ;Linienmuster maskieren
                  not.l    d5             ;Endmaske invertieren
                  REPT 4
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d6,(a1)+       ;Linienmuster ausgeben
                  ENDM
                  rts

hline_blackw1:    and.l    d5,d4
                  and.l    d4,d6
                  not.l    d4
                  REPT 4
                  and.l    d4,(a1)
                  or.l     d6,(a1)+
                  ENDM
                  rts
hline_blackw2:    move.l   d6,d7
                  and.l    d4,d6
                  and.l    d5,d7
                  not.l    d4
                  not.l    d5
                  REPT 4
                  and.l    d4,(a1)
                  or.l     d6,(a1)+
                  ENDM
                  REPT 4
                  and.l    d5,(a1)
                  or.l     d7,(a1)+
                  ENDM
                  rts

hline_eor:        subq.w   #1,d2
                  bmi.s    hline_eor_w1   ;ein Wort ?
                  subq.w   #1,d2
                  bmi.s    hline_eor_w2   ;zwei Worte ?

                  and.l    d6,d4
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
hloop_eor:        eor.l    d6,(a1)+
                  eor.l    d6,(a1)+
                  eor.l    d6,(a1)+
                  eor.l    d6,(a1)+
                  dbra     d2,hloop_eor
                  and.l    d6,d5
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)
                  rts

hline_eor_w1:     and.l    d5,d4
                  and.l    d6,d4
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)
                  rts
hline_eor_w2:     and.l    d6,d4
                  and.l    d6,d5
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d4,(a1)+
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)
                  rts

hline_col_mask:   DC.L 0
                  DC.L $ffff0000
                  DC.L $ffff
                  DC.L $ffffffff

hline_replace:    move.l   d3,-(sp)
                  move.l   a0,-(sp)
                  lea      color_map(pc),a0
                  move.b   1(a0,d7.w),d0  ;Ebenenzuordnung

                  move.l   d6,d7          ;Linienstil duplizieren
                  move.l   d6,d3
                  movea.l  d6,a0
                  moveq    #3,d1
                  and.w    d0,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  and.l    hline_col_mask(pc,d1.w),d6 ;Ebenen 0 und 1
                  moveq    #12,d1
                  and.w    d0,d1
                  and.l    hline_col_mask(pc,d1.w),d7 ;Ebenen 2 und 3
                  moveq    #12,d1
                  lsr.w    #2,d0
                  and.w    d0,d1
                  and.l    hline_col_mask(pc,d1.w),d3 ;Ebenen 4 und 5
                  lsr.w    #2,d0
                  and.w    #12,d0
                  move.l   a0,d1
                  and.l    hline_col_mask(pc,d0.w),d1 ;Ebenen 6 und 7
                  movea.l  d1,a0

                  subq.w   #1,d2
                  bmi.s    hline_replace_w1 ;ein Wort?
                  subq.w   #1,d2
                  bmi.s    hline_replace_w2 ;zwei Worte?

                  move.l   d6,d0
                  move.l   d7,d1
                  and.l    d4,d0
                  and.l    d4,d1
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d0,(a1)+
                  and.l    d4,(a1)
                  or.l     d1,(a1)+
                  not.l    d4
                  move.l   d3,d0
                  move.l   a0,d1
                  and.l    d4,d0
                  and.l    d4,d1
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d0,(a1)+
                  and.l    d4,(a1)
                  or.l     d1,(a1)+
hloop_replace:    move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  move.l   d3,(a1)+
                  move.l   a0,(a1)+
                  dbra     d2,hloop_replace
                  and.l    d5,d6          ;Linienstil maskieren
                  and.l    d5,d7          ;Linienstil maskieren
                  and.l    d5,d3
                  not.l    d5             ;Endmaske invertieren
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d6,(a1)+
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d7,(a1)+
                  and.l    d5,(a1)
                  or.l     d3,(a1)+
                  and.l    d5,(a1)
                  not.l    d5
                  move.l   a0,d1
                  and.l    d5,d1
                  or.l     d1,(a1)
                  movea.l  (sp)+,a0
                  move.l   (sp)+,d3
                  rts

hline_replace_w1: and.l    d5,d4
                  and.l    d4,d6
                  and.l    d4,d7
                  and.l    d4,d3
                  and.l    d4,d1
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d6,(a1)+
                  and.l    d4,(a1)
                  or.l     d7,(a1)+
                  and.l    d4,(a1)
                  or.l     d3,(a1)+
                  and.l    d4,(a1)
                  or.l     d1,(a1)
                  movea.l  (sp)+,a0
                  move.l   (sp)+,d3
                  rts
hline_replace_w2: move.l   d6,d0
                  move.l   d7,d1
                  and.l    d4,d0
                  and.l    d4,d1
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d0,(a1)+
                  and.l    d4,(a1)
                  or.l     d1,(a1)+
                  not.l    d4
                  move.l   d3,d0
                  move.l   a0,d1
                  and.l    d4,d0
                  and.l    d4,d1
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d0,(a1)+
                  and.l    d4,(a1)
                  or.l     d1,(a1)+
                  and.l    d5,d6          ;Linienstil maskieren
                  and.l    d5,d7          ;Linienstil maskieren
                  and.l    d5,d3
                  not.l    d5             ;Endmaske invertieren
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d6,(a1)+
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d7,(a1)+
                  and.l    d5,(a1)
                  or.l     d3,(a1)+
                  and.l    d5,(a1)
                  not.l    d5
                  move.l   a0,d1
                  and.l    d5,d1
                  or.l     d1,(a1)
                  movea.l  (sp)+,a0
                  move.l   (sp)+,d3
                  rts

hline_rev_trans:  not.w    d6
hline_trans:      move.l   a0,-(sp)

                  subq.w   #1,d2          ;nur ein Wort pro Plane ?
                  bpl.s    hline_t_color

                  and.w    d5,d4
                  moveq    #0,d5

hline_t_color:    subq.w   #1,d2
                  move.w   l_color(a6),d0
                  lea      color_map(pc),a0
                  move.b   0(a0,d0.w),d0
                  moveq    #7,d1          ;Anzahl der Ebenen

hline_trans_loop: movea.l  a1,a0
                  lsr.w    #1,d0
                  bcc.s    hline_and

                  move.w   d6,d7
                  and.w    d4,d7
                  or.w     d7,(a1)+       ;1 Plane weiter
                  move.w   d2,d7
                  bmi.s    hline_or_last
hline_or_loop:    lea      16(a0),a0
                  or.w     d6,(a0)

                  dbra     d7,hline_or_loop
hline_or_last:    lea      16(a0),a0
                  move.w   d6,d7
                  and.w    d5,d7
                  or.w     d7,(a0)
                  dbra     d1,hline_trans_loop ;naechste Plane
                  movea.l  (sp)+,a0
                  rts

hline_and:        move.w   d6,d7
                  and.w    d4,d7
                  not.w    d7
                  and.w    d7,(a1)+       ;1 Plane weiter
                  not.w    d6
                  move.w   d2,d7
                  bmi.s    hline_and_last
hline_and_loop:   lea      16(a0),a0
                  and.w    d6,(a0)
                  dbra     d7,hline_and_loop
hline_and_last:   lea      16(a0),a0
                  not.w    d6
                  move.w   d6,d7
                  and.w    d5,d7
                  not.w    d7
                  and.w    d7,(a0)
                  dbra     d1,hline_trans_loop ;naechste Plane
                  movea.l  (sp)+,a0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'vertikale Linie'

vline_mask:       DC.L $80008000
                  DC.L $40004000
                  DC.L $20002000
                  DC.L $10001000
                  DC.L $08000800
                  DC.L $04000400
                  DC.L $02000200
                  DC.L $01000100
                  DC.L $800080
                  DC.L $400040
                  DC.L $200020
                  DC.L $100010
                  DC.L $080008
                  DC.L $040004
                  DC.L $020002
                  DC.L $010001

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
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  moveq    #15,d2
                  and.w    d0,d2          ;Anzahl der Shifts
                  andi.w   #$fff0,d0
                  adda.w   d0,a1          ;Startadresse

;Masken erzeugen
                  add.w    d2,d2
                  add.w    d2,d2
                  move.l   vline_mask(pc,d2.w),d2 ;Punktmaske

                  tst.w    d7             ;REPLACE ?
                  bne      vline_eor
                  sub.w    #12,d5
                  move.w   l_color(a6),d7
                  beq.s    vline_white2
                  subq.w   #BLACK,d7      ;schwarz ?
                  bne.s    vline_replace
                  cmp.w    #$ffff,d6      ;durchgehend ?
                  bne.s    vline_white

vline_solid:      or.l     d2,(a1)+
                  or.l     d2,(a1)+
                  or.l     d2,(a1)+
                  or.l     d2,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline_solid
                  rts


vline_white:      tst.w    d6
                  bne.s    vline_replace
vline_white2:     not.l    d2
vline_white_loop: and.l    d2,(a1)+
                  and.l    d2,(a1)+
                  and.l    d2,(a1)+
                  and.l    d2,(a1)
                  adda.w   d5,a1
                  dbra     d3,vline_white_loop
                  rts

vline_replace:    add.w    #12,d5
                  move.l   a0,-(sp)
                  move.w   d2,d1
                  not.w    d1

                  move.w   l_color(a6),d0
                  move.l   a1,d7
                  lea      color_map(pc),a1
                  move.b   0(a1,d0.w),d0  ;Ebenenzuordnung
                  movea.l  d7,a1
                  moveq    #7,d7          ;Anzahl der Ebenen

vline_r_bloop:    movea.l  a1,a0
                  move.w   d3,d4
                  lsr.w    #1,d0
                  bcc.s    vlinexw_loop
                  swap     d7
                  move.w   d6,d7
vline_r_loop:     rol.w    #1,d7
                  bcc.s    vline_rw
                  or.w     d2,(a0)
                  adda.w   d5,a0
                  dbra     d4,vline_r_loop
vline_r_next:     swap     d7
                  addq.l   #2,a1
                  dbra     d7,vline_r_bloop
                  movea.l  (sp)+,a0
                  rts
vline_rw:         and.w    d1,(a0)
                  adda.w   d5,a0
                  dbra     d4,vline_r_loop
                  bra.s    vline_r_next

vlinexw_loop:     and.w    d1,(a0)
                  adda.w   d5,a0
                  dbra     d4,vlinexw_loop
                  swap     d7
                  bra.s    vline_r_next

vline_rw_loop:    and.w    d1,(a0)
                  adda.w   d5,a0
                  dbra     d4,vline_rw_loop
                  swap     d7
                  addq.l   #2,a1
                  dbra     d7,vline_r_bloop
                  movea.l  (sp)+,a0
                  rts

vline_eor:        subq.w   #EX_OR-REPLACE,d7
                  bmi.s    vline_trans
                  bgt.s    vline_rev_trans
                  cmp.w    #$aaaa,d6
                  beq.s    vline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    vline_eor_grow2
vloop_eor:        rol.w    #1,d6
                  bcc.s    vline_eor_next
                  eor.l    d2,(a1)+
                  eor.l    d2,(a1)+
                  eor.l    d2,(a1)+
                  eor.l    d2,(a1)
                  lea      -12(a1),a1
vline_eor_next:   adda.w   d5,a1
                  dbra     d3,vloop_eor
                  rts

vline_eor_grow2:  adda.w   d5,a1
                  dbra     d3,vline_eor_grow
                  rts
vline_eor_grow:   add.w    d5,d5
                  sub.w    #12,d5
                  lsr.w    #1,d3
vloop_eor_grow:   eor.l    d2,(a1)+
                  eor.l    d2,(a1)+
                  eor.l    d2,(a1)+
                  eor.l    d2,(a1)
                  adda.w   d5,a1
                  dbra     d3,vloop_eor_grow
                  rts

vline_rev_trans:  not.w    d6
vline_trans:      move.l   a0,-(sp)
                  move.w   d2,d1
                  not.w    d1

                  move.w   l_color(a6),d0
                  move.l   a1,d7
                  lea      color_map(pc),a1
                  move.b   0(a1,d0.w),d0  ;Ebenenzuordnung
                  movea.l  d7,a1
                  moveq    #7,d7          ;Anzahl der Ebenen

vline_t_loop:     movea.l  a1,a0
                  move.w   d3,d4
                  swap     d7
                  move.w   d6,d7
                  lsr.w    #1,d0
                  bcc.s    vline_and_loop
vline_or_loop:    rol.w    #1,d7
                  bcc.s    vline_or_next
                  or.w     d2,(a0)
vline_or_next:    adda.w   d5,a0
                  dbra     d4,vline_or_loop
                  swap     d7
                  addq.l   #2,a1
                  dbra     d7,vline_t_loop
                  movea.l  (sp)+,a0
                  rts
vline_and_loop:   rol.w    #1,d7
                  bcc.s    vline_and_next
                  and.w    d1,(a0)
vline_and_next:   adda.w   d5,a0
                  dbra     d4,vline_and_loop
                  swap     d7
                  addq.l   #2,a1
                  dbra     d7,vline_t_loop
                  movea.l  (sp)+,a0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'schraege Linie'

line_exit:        rts
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
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    line_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
line_laddr:       move.w   d5,d4
                  muls     d1,d4          ;Bytes pro Zeile * y1
                  adda.l   d4,a1          ;Zeilenadresse
                  moveq    #$fffffff0,d4
                  and.w    d0,d4          ;x1
                  adda.w   d4,a1          ;Startadresse

                  move.w   d6,d4
                  swap     d6
                  move.w   d4,d6          ;32-Bit-Linienmuster

                  moveq    #$0f,d4
                  and.w    d0,d4          ;Shifts fuer die Maske

                  sub.w    d0,d2          ;dx
                  bmi.s    line_exit      ;Murks ?
                  sub.w    d1,d3          ;dy
                  bpl.s    line_angle     ;dy negativ ?

                  neg.w    d3
                  neg.w    d5             ;vertikale Schrittrichtung aendern

line_angle:       cmp.w    d3,d2          ;Winkel > 44 degree ?
                  blt      line_angle45

                  move.w   d4,d0
                  move.l   #$80008000,d4  ;Punktmaske
                  lsr.l    d0,d4          ;shiften

                  move.w   d2,d0          ;Punktezaehler
                  add.w    l_lastpix(a6),d0 ;letztes nicht setzen ?
                  bmi.s    line_exit

                  add.w    d3,d3
                  move.w   d3,d1          ;Additionswert beim x-Schritt(2dy)
                  sub.w    d2,d3          ;e(2dy-dx)
                  neg.w    d2
                  add.w    d3,d2          ;Additionswert beim y-Schritt(2dy-2dx)

                  sub.w    #16,d5

                  tst.w    d7             ;Replace ?
                  bne      line_eor
                  move.w   l_color(a6),d7
                  subq.w   #BLACK,d7      ;schwarz ?
                  bne.s    line_replace
                  not.w    d6             ;durchgehend ?
                  beq      line_black
                  not.w    d6

line_replace:     movem.l  a0/a3-a5,-(sp)
                  movea.w  d5,a3          ;Abstand zur naechsten Zeile
                  lea      color_map(pc),a0
                  move.b   1(a0,d7.w),d5  ;im Highbyte ist Muell!
                  movea.w  d1,a0
                  move.l   d6,d7          ;Linienstil duplizieren
                  movea.l  d6,a4
                  movea.l  d6,a5
                  moveq    #3,d1
                  and.w    d5,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  and.l    line_col_mask(pc,d1.w),d6 ;Ebenen 0 und 1
                  moveq    #12,d1
                  and.w    d5,d1
                  and.l    line_col_mask(pc,d1.w),d7 ;Ebenen 2 und 3
                  exg      a4,d6
                  exg      a5,d7
                  moveq    #12,d1
                  lsr.w    #2,d5
                  and.w    d5,d1
                  and.l    line_col_mask(pc,d1.w),d6 ;Ebenen 4 und 5
                  lsr.w    #2,d5
                  and.w    #12,d5
                  and.l    line_col_mask(pc,d5.w),d7 ;Ebenen 6 und 7
                  exg      a4,d6
                  exg      a5,d7
                  bra.s    line_rep_mask

line_col_mask:    DC.L 0
                  DC.L $ffff0000
                  DC.L $ffff
                  DC.L $ffffffff

line_rep_ystep:   add.w    d2,d3          ;e + 2dy-2dx (vertikaler Schritt
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   d5,d1
                  not.l    d1
                  and.l    d6,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   d5,d1
                  not.l    d1
                  and.l    d7,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   a4,d1
                  not.l    d5
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  move.l   a5,d1
                  and.l    d5,d1          ;Linienstil maskieren
                  not.l    d5
                  and.l    d5,(a1)
                  or.l     d1,(a1)+       ;und ausgeben

                  adda.w   a3,a1          ;naechste Zeile
                  ror.l    #1,d4          ;naechster Punkt fuer die Maske
                  dbcs     d0,line_rep_mask ;Wortgrenze ?
                  lea      16(a1),a1      ;naechstes Wort der Ebene
                  subq.w   #1,d0
                  bmi.s    line_rep_exit
line_rep_mask:    moveq    #$ffffffff,d5  ;neue Maske
line_rep_loop:    eor.l    d4,d5          ;Punkt in der Maske loeschen
                  tst.w    d3             ;vertikaler Schritt ?
                  bpl.s    line_rep_ystep
                  add.w    a0,d3          ;e + 2dy (horizontaler Schritt)
                  ror.l    #1,d4          ;naechster Punkt
                  dbcs     d0,line_rep_loop ;Wortgrenze ?
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   d5,d1
                  not.l    d1
                  and.l    d6,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   d5,d1
                  not.l    d1
                  and.l    d7,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  move.l   a4,d1
                  not.l    d5
                  and.l    d5,d1          ;Linienstil maskieren
                  or.l     d1,(a1)+       ;und ausgeben
                  move.l   a5,d1
                  and.l    d5,d1          ;Linienstil maskieren
                  not.l    d5
                  and.l    d5,(a1)
                  or.l     d1,(a1)+       ;und ausgeben
                  subq.w   #1,d0
                  bpl.s    line_rep_mask
line_rep_exit:    movem.l  (sp)+,a0/a3-a5
                  rts

line_black_ystep: add.w    d2,d3          ;e + 2dy-2dx (vertikaler Schritt)
                  or.l     d7,(a1)+       ;Linienteilstueck ausgeben
                  or.l     d7,(a1)+
                  or.l     d7,(a1)+       ;Linienteilstueck ausgeben
                  or.l     d7,(a1)+
                  adda.w   d5,a1          ;naechste Zeile
                  ror.l    #1,d4          ;naechster Punkt fuer die Maske
                  dbcs     d0,line_black  ;Wortgrenze ?
                  lea      16(a1),a1      ;naechstes Wort der Ebene
                  subq.w   #1,d0
                  bmi.s    line_black_exit
line_black:       moveq    #0,d7          ;neue Maske
line_black_loop:  or.l     d4,d7          ;Punkt in der Maske setzen
                  tst.w    d3             ;vertikaler Schritt ?
                  bpl.s    line_black_ystep
                  add.w    d1,d3          ;e + 2dy (horizontaler Schritt)
                  ror.l    #1,d4          ;naechster Punkt
                  dbcs     d0,line_black_loop ;Wortgrenze ?
                  or.l     d7,(a1)+       ;Linienteilstueck ausgeben
                  or.l     d7,(a1)+
                  or.l     d7,(a1)+       ;Linienteilstueck ausgeben
                  or.l     d7,(a1)+
                  subq.w   #1,d0
                  bpl.s    line_black
line_black_exit:  rts

line_eor:         subq.w   #EX_OR-REPLACE,d7 ;Eor ?
                  bmi.s    line_trans
                  bgt.s    line_rev_trans
                  bra.s    line_eor_mask

line_eor_ystep:   add.w    d2,d3          ;e + 2dy-2dx (vertikaler Schritt)
                  and.l    d6,d7          ;Linienstil maskieren
                  eor.l    d7,(a1)+       ;Linienteilstueck ausgeben
                  eor.l    d7,(a1)+
                  eor.l    d7,(a1)+       ;Linienteilstueck ausgeben
                  eor.l    d7,(a1)+
                  adda.w   d5,a1          ;naechste Zeile
                  ror.l    #1,d4          ;naechster Punkt fuer die Maske
                  dbcs     d0,line_eor_mask
                  lea      16(a1),a1      ;naechstes Wort der Ebene
                  subq.w   #1,d0
                  bmi.s    line_eor_exit
line_eor_mask:    moveq    #0,d7          ;neue Maske
line_eor_loop:    or.l     d4,d7          ;Punkt in der Maske setzen
                  tst.w    d3             ;vertikaler Schritt ?
                  bpl.s    line_eor_ystep
                  add.w    d1,d3          ;e + 2dy (horizontaler Schritt)
                  ror.l    #1,d4          ;naechster Punkt
                  dbcs     d0,line_eor_loop ;Wortgrenze ?
                  and.l    d6,d7          ;Linienstil maskieren
                  eor.l    d7,(a1)+       ;Linienteilstueck ausgeben
                  eor.l    d7,(a1)+
                  eor.l    d7,(a1)+       ;Linienteilstueck ausgeben
                  eor.l    d7,(a1)+
                  subq.w   #1,d0
                  bpl.s    line_eor_mask
line_eor_exit:    rts

line_trans_ystep: add.w    d2,d3          ;e + 2dy-2dx (vertikaler Schritt)
                  and.l    d6,d7          ;Linienstil maskieren
                  move.l   d7,d5          ;fuers verodern
                  not.l    d7             ;fuers verunden
                  jsr      (a0)           ;Linienteilstueck ausgeben
                  adda.w   a3,a1          ;naechste Zeile
                  ror.l    #1,d4          ;naechster Punkt fuer die Maske
                  dbcs     d0,line_trans_mask ;Wortgrenze ?
                  lea      16(a1),a1      ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_trans_exit
line_trans_mask:  moveq    #0,d7          ;neue Maske
line_trans_loop:  or.l     d4,d7          ;Punkt in der Maske setzen
                  tst.w    d3             ;vertikaler Schritt ?
                  bpl.s    line_trans_ystep
                  add.w    d1,d3          ;e + 2dy (horizontaler Schritt)
                  ror.l    #1,d4          ;naechster Punkt
                  dbcs     d0,line_trans_loop ;Wortgrenze ?
                  and.l    d6,d7          ;Linienstil maskieren
                  move.l   d7,d5
                  not.l    d7
                  jsr      (a0)           ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_trans_mask
line_trans_exit:  movem.l  (sp)+,a0/a3
                  rts

line_rev_trans:   not.l    d6
line_trans:       movem.l  a0/a3,-(sp)
                  movea.w  d5,a3
                  move.w   l_color(a6),d7
                  add.w    d7,d7
                  lea      line_trans_tab(pc),a0
                  adda.w   0(a0,d7.w),a0
                  bra.s    line_trans_mask

line_trans_tab:   DC.W line_trans0-line_trans_tab
                  DC.W line_trans1-line_trans_tab
                  DC.W line_trans2-line_trans_tab
                  DC.W line_trans3-line_trans_tab
                  DC.W line_trans4-line_trans_tab
                  DC.W line_trans5-line_trans_tab
                  DC.W line_trans6-line_trans_tab
                  DC.W line_trans7-line_trans_tab
                  DC.W line_trans8-line_trans_tab
                  DC.W line_trans9-line_trans_tab
                  DC.W line_trans10-line_trans_tab
                  DC.W line_trans11-line_trans_tab
                  DC.W line_trans12-line_trans_tab
                  DC.W line_trans13-line_trans_tab
                  DC.W line_trans14-line_trans_tab
                  DC.W line_trans15-line_trans_tab
                  DC.W line_trans16-line_trans_tab
                  DC.W line_trans17-line_trans_tab
                  DC.W line_trans18-line_trans_tab
                  DC.W line_trans19-line_trans_tab
                  DC.W line_trans20-line_trans_tab
                  DC.W line_trans21-line_trans_tab
                  DC.W line_trans22-line_trans_tab
                  DC.W line_trans23-line_trans_tab
                  DC.W line_trans24-line_trans_tab
                  DC.W line_trans25-line_trans_tab
                  DC.W line_trans26-line_trans_tab
                  DC.W line_trans27-line_trans_tab
                  DC.W line_trans28-line_trans_tab
                  DC.W line_trans29-line_trans_tab
                  DC.W line_trans30-line_trans_tab
                  DC.W line_trans31-line_trans_tab
                  DC.W line_trans32-line_trans_tab
                  DC.W line_trans33-line_trans_tab
                  DC.W line_trans34-line_trans_tab
                  DC.W line_trans35-line_trans_tab
                  DC.W line_trans36-line_trans_tab
                  DC.W line_trans37-line_trans_tab
                  DC.W line_trans38-line_trans_tab
                  DC.W line_trans39-line_trans_tab
                  DC.W line_trans40-line_trans_tab
                  DC.W line_trans41-line_trans_tab
                  DC.W line_trans42-line_trans_tab
                  DC.W line_trans43-line_trans_tab
                  DC.W line_trans44-line_trans_tab
                  DC.W line_trans45_-line_trans_tab
                  DC.W line_trans46-line_trans_tab
                  DC.W line_trans47-line_trans_tab
                  DC.W line_trans48-line_trans_tab
                  DC.W line_trans49-line_trans_tab
                  DC.W line_trans50-line_trans_tab
                  DC.W line_trans51-line_trans_tab
                  DC.W line_trans52-line_trans_tab
                  DC.W line_trans53-line_trans_tab
                  DC.W line_trans54-line_trans_tab
                  DC.W line_trans55-line_trans_tab
                  DC.W line_trans56-line_trans_tab
                  DC.W line_trans57-line_trans_tab
                  DC.W line_trans58-line_trans_tab
                  DC.W line_trans59-line_trans_tab
                  DC.W line_trans60-line_trans_tab
                  DC.W line_trans61-line_trans_tab
                  DC.W line_trans62-line_trans_tab
                  DC.W line_trans63-line_trans_tab
                  DC.W line_trans64-line_trans_tab
                  DC.W line_trans65-line_trans_tab
                  DC.W line_trans66-line_trans_tab
                  DC.W line_trans67-line_trans_tab
                  DC.W line_trans68-line_trans_tab
                  DC.W line_trans69-line_trans_tab
                  DC.W line_trans70-line_trans_tab
                  DC.W line_trans71-line_trans_tab
                  DC.W line_trans72-line_trans_tab
                  DC.W line_trans73-line_trans_tab
                  DC.W line_trans74-line_trans_tab
                  DC.W line_trans75-line_trans_tab
                  DC.W line_trans76-line_trans_tab
                  DC.W line_trans77-line_trans_tab
                  DC.W line_trans78-line_trans_tab
                  DC.W line_trans79-line_trans_tab
                  DC.W line_trans80-line_trans_tab
                  DC.W line_trans81-line_trans_tab
                  DC.W line_trans82-line_trans_tab
                  DC.W line_trans83-line_trans_tab
                  DC.W line_trans84-line_trans_tab
                  DC.W line_trans85-line_trans_tab
                  DC.W line_trans86-line_trans_tab
                  DC.W line_trans87-line_trans_tab
                  DC.W line_trans88-line_trans_tab
                  DC.W line_trans89-line_trans_tab
                  DC.W line_trans90-line_trans_tab
                  DC.W line_trans91-line_trans_tab
                  DC.W line_trans92-line_trans_tab
                  DC.W line_trans93-line_trans_tab
                  DC.W line_trans94-line_trans_tab
                  DC.W line_trans95-line_trans_tab
                  DC.W line_trans96-line_trans_tab
                  DC.W line_trans97-line_trans_tab
                  DC.W line_trans98-line_trans_tab
                  DC.W line_trans99-line_trans_tab
                  DC.W line_trans100-line_trans_tab
                  DC.W line_trans101-line_trans_tab
                  DC.W line_trans102-line_trans_tab
                  DC.W line_trans103-line_trans_tab
                  DC.W line_trans104-line_trans_tab
                  DC.W line_trans105-line_trans_tab
                  DC.W line_trans106-line_trans_tab
                  DC.W line_trans107-line_trans_tab
                  DC.W line_trans108-line_trans_tab
                  DC.W line_trans109-line_trans_tab
                  DC.W line_trans110-line_trans_tab
                  DC.W line_trans111-line_trans_tab
                  DC.W line_trans112-line_trans_tab
                  DC.W line_trans113-line_trans_tab
                  DC.W line_trans114-line_trans_tab
                  DC.W line_trans115-line_trans_tab
                  DC.W line_trans116-line_trans_tab
                  DC.W line_trans117-line_trans_tab
                  DC.W line_trans118-line_trans_tab
                  DC.W line_trans119-line_trans_tab
                  DC.W line_trans120-line_trans_tab
                  DC.W line_trans121-line_trans_tab
                  DC.W line_trans122-line_trans_tab
                  DC.W line_trans123-line_trans_tab
                  DC.W line_trans124-line_trans_tab
                  DC.W line_trans125-line_trans_tab
                  DC.W line_trans126-line_trans_tab
                  DC.W line_trans127-line_trans_tab
                  DC.W line_trans128-line_trans_tab
                  DC.W line_trans129-line_trans_tab
                  DC.W line_trans130-line_trans_tab
                  DC.W line_trans131-line_trans_tab
                  DC.W line_trans132-line_trans_tab
                  DC.W line_trans133-line_trans_tab
                  DC.W line_trans134-line_trans_tab
                  DC.W line_trans135-line_trans_tab
                  DC.W line_trans136-line_trans_tab
                  DC.W line_trans137-line_trans_tab
                  DC.W line_trans138-line_trans_tab
                  DC.W line_trans139-line_trans_tab
                  DC.W line_trans140-line_trans_tab
                  DC.W line_trans141-line_trans_tab
                  DC.W line_trans142-line_trans_tab
                  DC.W line_trans143-line_trans_tab
                  DC.W line_trans144-line_trans_tab
                  DC.W line_trans145-line_trans_tab
                  DC.W line_trans146-line_trans_tab
                  DC.W line_trans147-line_trans_tab
                  DC.W line_trans148-line_trans_tab
                  DC.W line_trans149-line_trans_tab
                  DC.W line_trans150-line_trans_tab
                  DC.W line_trans151-line_trans_tab
                  DC.W line_trans152-line_trans_tab
                  DC.W line_trans153-line_trans_tab
                  DC.W line_trans154-line_trans_tab
                  DC.W line_trans155-line_trans_tab
                  DC.W line_trans156-line_trans_tab
                  DC.W line_trans157-line_trans_tab
                  DC.W line_trans158-line_trans_tab
                  DC.W line_trans159-line_trans_tab
                  DC.W line_trans160-line_trans_tab
                  DC.W line_trans161-line_trans_tab
                  DC.W line_trans162-line_trans_tab
                  DC.W line_trans163-line_trans_tab
                  DC.W line_trans164-line_trans_tab
                  DC.W line_trans165-line_trans_tab
                  DC.W line_trans166-line_trans_tab
                  DC.W line_trans167-line_trans_tab
                  DC.W line_trans168-line_trans_tab
                  DC.W line_trans169-line_trans_tab
                  DC.W line_trans170-line_trans_tab
                  DC.W line_trans171-line_trans_tab
                  DC.W line_trans172-line_trans_tab
                  DC.W line_trans173-line_trans_tab
                  DC.W line_trans174-line_trans_tab
                  DC.W line_trans175-line_trans_tab
                  DC.W line_trans176-line_trans_tab
                  DC.W line_trans177-line_trans_tab
                  DC.W line_trans178-line_trans_tab
                  DC.W line_trans179-line_trans_tab
                  DC.W line_trans180-line_trans_tab
                  DC.W line_trans181-line_trans_tab
                  DC.W line_trans182-line_trans_tab
                  DC.W line_trans183-line_trans_tab
                  DC.W line_trans184-line_trans_tab
                  DC.W line_trans185-line_trans_tab
                  DC.W line_trans186-line_trans_tab
                  DC.W line_trans187-line_trans_tab
                  DC.W line_trans188-line_trans_tab
                  DC.W line_trans189-line_trans_tab
                  DC.W line_trans190-line_trans_tab
                  DC.W line_trans191-line_trans_tab
                  DC.W line_trans192-line_trans_tab
                  DC.W line_trans193-line_trans_tab
                  DC.W line_trans194-line_trans_tab
                  DC.W line_trans195-line_trans_tab
                  DC.W line_trans196-line_trans_tab
                  DC.W line_trans197-line_trans_tab
                  DC.W line_trans198-line_trans_tab
                  DC.W line_trans199-line_trans_tab
                  DC.W line_trans200-line_trans_tab
                  DC.W line_trans201-line_trans_tab
                  DC.W line_trans202-line_trans_tab
                  DC.W line_trans203-line_trans_tab
                  DC.W line_trans204-line_trans_tab
                  DC.W line_trans205-line_trans_tab
                  DC.W line_trans206-line_trans_tab
                  DC.W line_trans207-line_trans_tab
                  DC.W line_trans208-line_trans_tab
                  DC.W line_trans209-line_trans_tab
                  DC.W line_trans210-line_trans_tab
                  DC.W line_trans211-line_trans_tab
                  DC.W line_trans212-line_trans_tab
                  DC.W line_trans213-line_trans_tab
                  DC.W line_trans214-line_trans_tab
                  DC.W line_trans215-line_trans_tab
                  DC.W line_trans216-line_trans_tab
                  DC.W line_trans217-line_trans_tab
                  DC.W line_trans218-line_trans_tab
                  DC.W line_trans219-line_trans_tab
                  DC.W line_trans220-line_trans_tab
                  DC.W line_trans221-line_trans_tab
                  DC.W line_trans222-line_trans_tab
                  DC.W line_trans223-line_trans_tab
                  DC.W line_trans224-line_trans_tab
                  DC.W line_trans225-line_trans_tab
                  DC.W line_trans226-line_trans_tab
                  DC.W line_trans227-line_trans_tab
                  DC.W line_trans228-line_trans_tab
                  DC.W line_trans229-line_trans_tab
                  DC.W line_trans230-line_trans_tab
                  DC.W line_trans231-line_trans_tab
                  DC.W line_trans232-line_trans_tab
                  DC.W line_trans233-line_trans_tab
                  DC.W line_trans234-line_trans_tab
                  DC.W line_trans235-line_trans_tab
                  DC.W line_trans236-line_trans_tab
                  DC.W line_trans237-line_trans_tab
                  DC.W line_trans238-line_trans_tab
                  DC.W line_trans239-line_trans_tab
                  DC.W line_trans240-line_trans_tab
                  DC.W line_trans241-line_trans_tab
                  DC.W line_trans242-line_trans_tab
                  DC.W line_trans243-line_trans_tab
                  DC.W line_trans244-line_trans_tab
                  DC.W line_trans245-line_trans_tab
                  DC.W line_trans246-line_trans_tab
                  DC.W line_trans247-line_trans_tab
                  DC.W line_trans248-line_trans_tab
                  DC.W line_trans249-line_trans_tab
                  DC.W line_trans250-line_trans_tab
                  DC.W line_trans251-line_trans_tab
                  DC.W line_trans252-line_trans_tab
                  DC.W line_trans253-line_trans_tab
                  DC.W line_trans254-line_trans_tab
                  DC.W line_trans255-line_trans_tab

line_exit45:      rts

line_angle45:     move.w   d3,d0          ;Punktezaehler
                  add.w    l_lastpix(a6),d0 ;letztes Pixel nicht setzen ?
                  bmi.s    line_exit45

                  add.w    d2,d2          ;Additionswert beim y-Schritt(2dx)
                  move.w   d2,d1
                  sub.w    d3,d1
                  sub.w    d3,d1          ;Additionswert beim x-Schritt(2dx-2dy)
                  add.w    d1,d3          ;e(2dy-dx)

                  rol.w    d4,d6          ;Linienmuster rotieren

                  move.l   a3,-(sp)
                  movea.w  d5,a3          ;Bytes pro Zeile
                  move.l   #$80008000,d5
                  lsr.l    d4,d5          ;schwarze Punktmaske

                  tst.w    d7             ;Replace ?
                  bne      line_eor45
                  suba.w   #16,a3
                  move.w   l_color(a6),d7
                  subq.w   #BLACK,d7      ;schwarz ?
                  bne.s    line_replace45
                  not.w    d6             ;durchgehend ?
                  beq.s    line_black45
                  not.w    d6

line_replace45:   move.w   a3,d4          ;Abstand zur naechsten Zeile
                  lea      line_trans_tab(pc),a3
                  add.w    d7,d7
                  adda.w   2(a3,d7.w),a3  ;Zeiger auf die Ausgaberoutine
                  bra.s    line_rep45_rot

line_rep45_xstep: add.w    d1,d3          ;e + 2dx-2dy (horizontaler Schritt)
                  ror.l    #1,d5          ;Maske fuer den naechsten schwarzen Punkt
                  dbcs     d0,line_rep45_rot
                  lea      16(a1),a1      ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_rep45_exit
line_rep45_rot:   rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep45_white ;nicht gesetzt ?
                  move.l   d5,d7
                  not.l    d7             ;fuers verunden
                  jsr      (a3)           ;Linienteilstueck ausgeben
                  adda.w   d4,a1          ;naechste Zeile
                  tst.w    d3             ;horizontaler Schritt ?
                  bpl.s    line_rep45_xstep
                  add.w    d2,d3          ;e + 2dx (vertikaler Schritt)
                  dbra     d0,line_rep45_rot ;Punktezaehler dekrementieren
line_rep45_exit:  movea.l  (sp)+,a3
                  rts
line_rep45_white: move.l   d5,d7
                  not.l    d7
                  and.l    d7,(a1)+       ;weissen Punkt setzen
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+       ;weissen Punkt setzen
                  and.l    d7,(a1)+
                  adda.w   d4,a1          ;naechste Zeile
                  tst.w    d3             ;horizontaler Schritt ?
                  bpl.s    line_rep45_xstep
                  add.w    d2,d3          ;e + 2dx (vertikaler Schritt)
                  dbra     d0,line_rep45_rot ;Punktezaehler dekrementieren
                  movea.l  (sp)+,a3
                  rts

line_bl45_xstep:  add.w    d1,d3          ;e + 2dx-2dy (horizontaler Schritt)
                  ror.l    #1,d5          ;Maske fuer den naechsten Punkt
                  dbcs     d0,line_black45
                  lea      16(a1),a1
                  subq.w   #1,d0
                  bmi.s    line_bl45_exit
line_black45:     or.l     d5,(a1)+       ;schwarzen Punkt setzen
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+       ;schwarzen Punkt setzen
                  or.l     d5,(a1)+
                  adda.w   a3,a1          ;naechste Zeile
                  tst.w    d3             ;horizontaler Schritt ?
                  bpl.s    line_bl45_xstep
                  add.w    d2,d3          ;e + 2dx (vertikaler Schritt)
                  dbra     d0,line_black45 ;Punktezaehler dekrementieren
line_bl45_exit:   movea.l  (sp)+,a3
                  rts

line_eor45:       subq.w   #EX_OR-REPLACE,d7 ;Eor ?
                  beq.s    line_eor45_rot
                  bmi.s    line_trans45
                  bra.s    line_rev_trans45

line_eor45_xstep: add.w    d1,d3          ;e + 2dx-2dy (horizontaler Schritt)
                  ror.l    #1,d5          ;Maske fuer den naechsten schwarzen Punkt
                  dbcs     d0,line_eor45_rot ;wenn Wortgrenze nicht ueberschritten
                  lea      16(a1),a1      ;Zeiger aufs naechste Wort
                  subq.w   #1,d0
                  bmi.s    line_eor45_exit
line_eor45_rot:   rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor45_next ;nicht gesetzt ?
                  eor.l    d5,(a1)+       ;schwarzen Punkt setzen
                  eor.l    d5,(a1)+
                  eor.l    d5,(a1)+       ;schwarzen Punkt setzen
                  eor.l    d5,(a1)
                  lea      -12(a1),a1
line_eor45_next:  adda.w   a3,a1          ;naechste Zeile
                  tst.w    d3             ;e > 0 ?
                  bpl.s    line_eor45_xstep ;wenn ja; Schritt nach rechts
                  add.w    d2,d3          ;e + 2dx (vertikaler Schritt)
                  dbra     d0,line_eor45_rot ;Punktezaehler dekrementieren
line_eor45_exit:  movea.l  (sp)+,a3
                  rts

line_rev_trans45: not.w    d6
line_trans45:     move.w   a3,d4          ;Abstand zur naechsten Zeile
                  lea      line_trans_tab(pc),a3
                  move.w   l_color(a6),d7
                  add.w    d7,d7
                  adda.w   0(a3,d7.w),a3  ;Zeiger auf die Ausgaberoutine
                  bra.s    line_trn45_rot

line_trn45_xstep: add.w    d1,d3          ;e + 2dx-2dy (horizontaler Schritt)
                  ror.l    #1,d5          ;Maske des naechsten Punktes
                  dbcs     d0,line_trn45_rot ;Wortgrenze ?
                  lea      16(a1),a1      ;naechstew Wort der Ebene
                  subq.w   #1,d0
                  bmi.s    line_trn45_exit
line_trn45_rot:   rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_trn45_next ;nicht gesetzt ?
                  move.l   d5,d7
                  not.l    d7             ;fuers verunden
                  jsr      (a3)           ;Linienteilstueck ausgeben
                  lea      -16(a1),a1
line_trn45_next:  adda.w   d4,a1          ;naechste Zeile
                  tst.w    d3             ;horizontaler Schritt ?
                  bpl.s    line_trn45_xstep
                  add.w    d2,d3          ;e + 2dx (vertikaler Schritt)
                  dbra     d0,line_trn45_rot ;Punktezaehler dekrementieren
line_trn45_exit:  movea.l  (sp)+,a3
                  rts

line_trans0:      and.l    d7,(a1)+       ;0
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans1:      or.l     d5,(a1)+       ;255
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans2:      or.w     d5,(a1)+       ;1
                  and.w    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans3:      and.w    d7,(a1)+       ;2
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans4:      and.l    d7,(a1)+       ;4
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans5:      and.w    d7,(a1)+       ;6
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans6:      or.l     d5,(a1)+       ;3
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans7:      or.w     d5,(a1)+       ;5
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans8:      or.l     d5,(a1)+       ;7
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans9:      and.l    d7,(a1)+       ;8
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans10:     or.w     d5,(a1)+       ;9
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans11:     and.w    d7,(a1)+       ;10
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans12:     and.l    d7,(a1)+       ;12
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans13:     and.w    d7,(a1)+       ;14
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans14:     or.l     d5,(a1)+       ;11
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans15:     or.w     d5,(a1)+       ;13
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans16:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans17:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans18:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans19:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans20:     and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans21:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans22:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans23:     or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans24:     and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans25:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans26:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans27:     or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+

                  and.w    d7,(a1)+
                  rts
line_trans28:     and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans29:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans30:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans31:     or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans32:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans33:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans34:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans35:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans36:     and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans37:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans38:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans39:     or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans40:     and.l    d7,(a1)+

                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+

                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans41:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans42:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans43:     or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans44:     and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans45_:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans46:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans47:     or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans48:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans49:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans50:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans51:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans52:     and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans53:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans54:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans55:     or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans56:     and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans57:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans58:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans59:     or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans60:     and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans61:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans62:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans63:     or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  rts
line_trans64:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans65:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans66:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans67:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans68:     and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans69:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans70:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans71:     or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans72:     and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans73:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans74:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans75:     or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans76:     and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans77:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans78:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans79:     or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans80:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans81:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans82:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans83:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans84:     and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans85:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans86:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans87:     or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans88:     and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans89:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans90:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans91:     or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans92:     and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans93:     or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans94:     and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans95:     or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans96:     and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans97:     or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans98:     and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans99:     or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans100:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans101:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans102:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans103:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans104:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans105:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans106:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans107:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans108:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts

line_trans109:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans110:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans111:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans112:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans113:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans114:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans115:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans116:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans117:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans118:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans119:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans120:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans121:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans122:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans123:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+

                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans124:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans125:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans126:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans127:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  rts
line_trans128:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans129:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans130:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans131:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans132:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans133:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans134:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans135:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans136:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans137:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans138:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans139:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans140:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans141:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans142:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans143:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans144:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans145:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans146:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans147:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+

                  or.w     d5,(a1)+
                  rts
line_trans148:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans149:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans150:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans151:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans152:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans153:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans154:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans155:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans156:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans157:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans158:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans159:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans160:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans161:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans162:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans163:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans164:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans165:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans166:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans167:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans168:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans169:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans170:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans171:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans172:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans173:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans174:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans175:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans176:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans177:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans178:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans179:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans180:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans181:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans182:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans183:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans184:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans185:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans186:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans187:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans188:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans189:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans190:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans191:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans192:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans193:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans194:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans195:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans196:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans197:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans198:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans199:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans200:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans201:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans202:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans203:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans204:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans205:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans206:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans207:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans208:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans209:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+

                  rts
line_trans210:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans211:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans212:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans213:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans214:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans215:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans216:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans217:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans218:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans219:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans220:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans221:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans222:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans223:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans224:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans225:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans226:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+

                  or.w     d5,(a1)+
                  rts
line_trans227:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans228:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans229:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans230:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans231:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans232:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans233:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans234:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans235:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans236:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans237:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+

                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans238:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans239:    or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans240:    and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans241:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans242:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans243:    or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans244:    and.l    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans245:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans246:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans247:    or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans248:    and.l    d7,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans249:    or.w     d5,(a1)+
                  and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans250:    and.w    d7,(a1)+
                  or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans251:    or.l     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts

line_trans252:    and.l    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans253:    or.w     d5,(a1)+
                  and.w    d7,(a1)+
                  or.l     d5,(a1)+

                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  rts
line_trans254:    and.w    d7,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.l     d5,(a1)+
                  or.w     d5,(a1)+
                  rts
line_trans255:    or.l     d5,(a1)+       ;15
                  or.l     d5,(a1)+
                  and.l    d7,(a1)+
                  and.l    d7,(a1)+
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Text fuer 9 und 10 Punkte'

textblt_exit:     rts

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
textblt_soft:     cmpi.w   #1,wr_mode(a6) ;REPLACE oder TRANSPARENT?
                  bgt.s    textblt_soft_vb
                  cmpi.w   #BLACK,t_color(a6)
                  beq.s    textblt_black

textblt_soft_vb:  movea.l  v_bas_ad.w,a1  ;Adresse des Bilschirms
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    textblt_soft_ad
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  movea.w  bitmap_width(a6),a3 ;Bytes pro Zeile
textblt_soft_ad:  move.l   a0,r_saddr(a6) ;Quelladresse
                  move.l   a1,r_daddr(a6) ;Zielblockadresse
                  move.w   a2,r_swidth(a6) ;Bytes pro Quellzeile
                  move.w   a3,r_dwidth(a6) ;Bytes pro Zielzeile
                  move.w   #0,r_splanes(a6) ;Ebenenanzahl des Quellblocks - 1
                  move.w   r_planes(a6),r_dplanes(a6) ;Ebenenanzahl des Zielblocks - 1
                  clr.w    r_bgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_fgcol(a6) ;Textfarbe
                  move.w   wr_mode(a6),r_wmode(a6)
                  cmpi.w   #REV_TRANS-REPLACE,r_wmode(a6) ;REVERS TRANSPARENT?
                  bne      expblt_soft
                  clr.w    r_fgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_bgcol(a6) ;Textfarbe
                  bra      expblt_soft

textblt_black:    movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    textblt_blk_laddr
                  movea.l  bitmap_addr(a6),a1 ;Adresse des Bildschirms

                  movea.w  bitmap_width(a6),a3 ;Bytes pro Zeile
                  tst.w    r_planes(a6)      ;monochrome Bitmap?
                  beq.s    textblt_soft_ad
textblt_blk_laddr:move.w   a2,d6          ;Bytes pro Quellzeile
                  mulu     d6,d1          ;* y-Quelle
                  adda.l   d1,a0          ;Zeilenadresse
                  move.w   d0,d1          ;xs1
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a0          ;Quelladresse

                  move.w   a3,d1          ;Bytes pro Zielzeile
                  mulu     d3,d1          ;* y-Ziel
                  adda.l   d1,a1          ;Zeilenadresse
                  moveq    #$fffffff0,d1
                  and.w    d2,d1          ;xd1
                  adda.w   d1,a1          ;Zieladresse

                  moveq    #15,d6         ;zum ausmaskieren

                  and.w    d6,d0
                  move.w   d2,d3
                  and.w    d6,d3
                  sub.w    d3,d0          ;Shifts nach links

                  move.w   d2,d1
                  and.w    d6,d1          ;Pixelueberhang
                  add.w    d4,d1
                  lsr.w    #4,d1          ;Wortzaehler

                  add.w    d2,d4          ;xd2
                  exg      d2,d4
                  not.w    d2
                  and.w    d6,d2
                  moveq    #$ffffffff,d3
                  lsl.w    d2,d3          ;Endmaske
                  swap     d3
                  lsl.w    d2,d3          ;Endmaske
                  moveq    #$ffffffff,d2
                  and.w    d6,d4
                  lsr.w    d4,d2          ;Startmaske
                  swap     d2
                  lsr.w    d4,d2          ;Startmaske

                  move.w   d1,d4
                  bne.s    textblt_offset ;nur ein Wort verschieben ?

                  and.l    d3,d2          ;Start- und Endmaske
                  moveq    #0,d3
                  moveq    #1,d4

textblt_offset:   subq.w   #2,d1          ;Schleifenzaehler
                  add.w    d4,d4
                  suba.w   d4,a2          ;Abstand zur naechsten Quellzeile
                  addq.w   #2,d4
                  lsl.w    #3,d4
                  suba.w   d4,a3          ;Abstand zur naechsten Zielzeile

                  tst.w    d0
                  beq.s    textblt3
                  blt.s    textblt_right

textblt_left:     cmpi.w   #8,d0
                  ble      textblt_l3
                  subq.w   #1,d0
                  eor.w    d6,d0
                  bra.s    textblt_r3

textblt_right:    neg.w    d0
                  subq.l   #2,a0
                  cmpi.w   #8,d0
                  ble.s    textblt_r3
                  subq.w   #1,d0
                  eor.w    d6,d0
                  bra      textblt_l3

textblt3:         tst.w    wr_mode(a6)
                  bne      textblt1

textblt_bloop3:   move.w   (a0)+,d6       ;Buffer
                  not.w    d6
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d2,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last3

textblt_loop3:    move.w   (a0)+,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d4,textblt_loop3

textblt_last3:    move.w   (a0),d6        ;Buffer
                  not.w    d6
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d3,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt_bloop3
                  rts

textblt_r3:       tst.w    wr_mode(a6)
                  bne      textblt_r1
textblt_bloop_r3: move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d2,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last_r3

textblt_loop_r3:  move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  ror.l    d0,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  move.l   d6,(a1)+
                  ENDM

                  dbra     d4,textblt_loop_r3

textblt_last_r3:  move.l   (a0),d6        ;Buffer
                  ror.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d3,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt_bloop_r3
                  rts

textblt_l3:       tst.w    wr_mode(a6)
                  bne      textblt_l1
textblt_bloop_l3: move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d2,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last_l3

textblt_loop_l3:  move.l   (a0),d6
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d4,textblt_loop_l3

textblt_last_l3:  move.l   (a0),d6        ;Buffer
                  swap     d6
                  rol.l    d0,d6
                  not.w    d6
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d3,(a1)
                  eor.l    d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt_bloop_l3
                  rts

textblt1:         move.w   (a0)+,d6       ;Buffer
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last1

textblt_loop1:    move.w   (a0)+,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM
                  dbra     d4,textblt_loop1

textblt_last1:    move.w   (a0),d6        ;Buffer
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt1
                  rts

textblt_r1:       move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  ror.l    d0,d6
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last_r1

textblt_loop_r1:  move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  ror.l    d0,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  dbra     d4,textblt_loop_r1

textblt_last_r1:  move.l   (a0),d6        ;Buffer
                  ror.l    d0,d6
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt_r1
                  rts

textblt_l1:       move.l   (a0),d6        ;Buffer
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  and.w    d2,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  move.w   d1,d4
                  bmi.s    textblt_last_l1

textblt_loop_l1:  move.l   (a0),d6
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM
                  dbra     d4,textblt_loop_l1

textblt_last_l1:  move.l   (a0),d6        ;Buffer
                  swap     d6
                  rol.l    d0,d6
                  and.w    d3,d6
                  move.w   d6,d7
                  swap     d6
                  move.w   d7,d6
                  REPT 4
                  or.l     d6,(a1)+
                  ENDM

                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,textblt_l1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Flaechenfuellung'

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
scanline:         movem.l  d5-d7,-(sp)    ;Register sichern
                  move.w   d0,d3          ;X-Start merken
                  swap     d3
                  move.w   d0,d3          ;wird 2 mal gebraucht

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    scanline_screen
                  movea.l  bitmap_addr(a6),a4 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    scanline_laddr
scanline_screen:  movea.l  v_bas_ad.w,a4  ;Adresse des Bildschirms
                  muls     BYTES_LIN.w,d1 ;y1
scanline_laddr:   adda.l   d1,a4          ;Zeilenadresse
                  moveq    #$fffffff0,d4
                  and.w    d0,d4          ;Bytes pro Zeile
                  adda.w   d4,a4          ;Bildschirmanfang+Y-Zeile+ Zeilenoffset
                  not.w    d0
                  moveq    #15,d4
                  and.w    d0,d4          ;Bitnummer
                  moveq    #0,d0
                  bset     d4,d0          ;Maske

                  moveq    #0,d6          ;Ebenenzuordnung
                  move.w   r_planes(a6),d7   ;Ebenenzaehler

scanline_loop:
                  movem.l  d0-d1/d3-d4,-(sp)

                  movea.l  a4,a3          ;Startposition

                  lsr.w    #1,d6
                  move.w   (a3),d1
                  and.w    d0,d1
                  sne      d4             ;Farbe des Startp. 0:weiss, $ff:schwarz
                  beq.s    scan_ext
                  addi.w   #128,d6
scan_ext:         ext.w    d4

; Startwort
                  cmp.w    d2,d3
                  bgt.s    try_l
                  move.w   d3,d0          ;X-Start
                  andi.w   #15,d0         ;X-Bits
                  move.w   (a3),d1
                  lea      16(a3),a3
                  lsl.w    d0,d1
                  move.w   d4,d5
                  lsl.w    d0,d5          ;Maske ebenfalls verschieben
                  cmp.w    d1,d5
                  beq.s    r_wgr          ;Bits bis zur Wortgrenze ok

; zwischen Startpunkt und Wortgrenze liegen noch Bits
                  add.w    d1,d1          ;Startpunkt ueberspringen (WICHTIGST)
r_1wd:            add.w    d1,d1          ;Wort shiften bis Grenze im Carry
                  scs      d0             ;Farbe ermitteln
                  cmp.b    d0,d4          ;mit Startpunkt vergleichen
                  bne.s    try_l          ;Begrenzung erreicht
                  addq.w   #1,d3          ;eine X-Pos. weiter
                  cmp.w    d2,d3
                  blt.s    r_1wd
                  bra.s    etry_l         ;Cliprect erreicht !

r_wgr:            move.w   d3,d0          ;X-Start
                  not.w    d0             ;Abstand Startpkt./rechte Wortgrenze
                  and.w    #15,d0         ;ermitteln
                  add.w    d0,d3          ;X-Pos. bis zum Wortrand erhoehen
                  cmp.w    d2,d3          ;innerhalb Cliprect ?
                  bge.s    etry_l         ;also clip_xmax setzen

; nun wortweise abtesten
rs_wd:            move.w   (a3),d1        ;naechstes Wort
                  lea      16(a3),a3
                  cmp.w    d1,d4          ;Farbe id. Startpunkt ?
                  bne.s    rs_ew          ;Bits im Endwort abtesten
                  add.w    #16,d3         ;X-Pos
                  cmp.w    d2,d3
                  blt.s    rs_wd          ;innerhalb des Cliprect
                  bra.s    etry_l         ;Clipgrenze setzen

; letztes Wort bearbeiten
rs_ew:            add.w    d1,d1          ;Wort shiften bis Grenze im Carry
                  scs      d0             ;Farbe ermitteln
                  cmp.b    d0,d4          ;mit Startpunkt vergleichen
                  bne.s    try_l          ;Begrenzung erreicht
                  addq.w   #1,d3          ;eine X-Pos. weiter
                  cmp.w    d2,d3          ;innerhalb Cliprect ?
                  blt.s    rs_ew

etry_l:           move.w   d2,d3          ;X=clip_xmax

try_l:            move.w   d3,(a1)        ;rechte Begrenzung
                  swap     d2
                  swap     d3             ;X-Start holen
                  movea.l  a4,a3          ;alte Startadr.

scan_l:           cmp.w    d2,d3
                  blt.s    fnd_limits
                  move.w   d3,d0          ;X-Start
                  not.w    d0             ;Shifts, damit Startpunkt
                  and.w    #15,d0         ;niederwertigstes Bit
                  move.w   (a3),d1
                  lsr.w    d0,d1
                  move.w   d4,d5          ;Farbe des Startpkt.
                  lsr.w    d0,d5
                  cmp.w    d1,d5
                  beq.s    l_wgr          ;Bits bis zur Wortgrenze ok

; zwischen Start und Wortgrenze liegen noch Bits
                  lsr.w    #1,d1          ;Startpunkt ueberspringen
l_1wd:            lsr.w    #1,d1          ;shiften, bis Grenzeim Carry
                  scs      d0
                  cmp.b    d0,d4
                  bne.s    fnd_limits
                  subq.w   #1,d3
                  cmp.w    d2,d3          ;noch innerhalb Cliprect ?
                  bgt.s    l_1wd
                  bra.s    e_limits

l_wgr:            move.w   d3,d0          ;X-Start
                  and.w    #15,d0         ;Abstand Startpkt./linke Wortgrenze
                  sub.w    d0,d3
                  cmp.w    d2,d3          ;innerhalb Cliprect ?
                  ble.s    e_limits
; nun wortweise abtesten
ls_wd:            lea      -16(a3),a3
                  move.w   (a3),d1
                  cmp.w    d1,d4
                  bne.s    ls_ew          ;Bits im Endwort abtesten

                  sub.w    #16,d3
                  cmp.w    d2,d3          ;innerhalb Cliprect ?
                  bgt.s    ls_wd
                  bra.s    e_limits       ;Clipgrenze setzen
; letztes Wort bearbeiten
ls_ew:            lsr.w    #1,d1          ;shiften bis Grenze
                  scs      d0             ;auftaucht (Farbwechsel)
                  cmp.b    d0,d4
                  bne.s    fnd_limits
                  subq.w   #1,d3
                  cmp.w    d2,d3
                  bgt.s    ls_ew

e_limits:         move.w   d2,d3          ;X=clip_xmin

fnd_limits:       move.w   d3,(a0)        ;linke Begrenzung
                  move.w   (a0),d2        ;linke Begrenzung
                  swap     d2
                  move.w   (a1),d2        ;rechte Begrenzung

                  addq.l   #2,a4          ;naechste Ebenen
                  movem.l  (sp)+,d0-d1/d3-d4
                  dbra     d7,scanline_loop

                  move.w   (a5),d0

                  cmp.w    v_1e+2(a5),d6
                  beq.s    scanline_exit
                  eori.w   #1,d0
scanline_exit:    movem.l  (sp)+,d5-d7
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  DATA

;Die Relokationsinformation
relokation:
;Reloziert am: Sun Jan 21 20:46:48 1996

DC.w 728,68,14178,24,92,236,1248,442,794,376
DC.w 4726,90,740

                  DC.W 0                  ;Ende der Daten
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  BSS

nvdi_struct:      DS.L 1

color_map:        DS.B  256
color_remap:      DS.B  256

                  END
