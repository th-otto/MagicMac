;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                   2-Farb-Offscreen-Treiber fuer NVDI 4.1                   *;
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
                  
PATTERN_LENGTH    EQU 32                  ;minimale Fuellmusterlaenge

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
organisation:     DC.L  2                 ;Farben
                  DC.W  1                 ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  1                 ;Bitorganisation
                  DC.W  0,0,0
header_end:

continue:      
                  rts

;Initialisierungsfunktion
;Eingaben
;a0.l nvdi_struct
;Ausgaben
;d0.l Laenge der Workstation
init:             movem.l  d0-d2/a0-a2,-(sp)

                  move.l   a0,nvdi_struct
                  move.w   _nvdi_cpu020(a0),cpu020

                  bsr      make_relo      ;Treiber relozieren

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
                     
                  move.w   #2,26-90(a0)   ;work_out[13]: Anzahl der Farben
                  move.w   #1,70-90(a0)   ;work_out[35]: Farbe ist vorhanden
                  move.w   #2,78-90(a0)   ;work_out[39]: 2 Farbabstufungen

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
                  move.w   #2,2-90(a0)       ;work_out[1]: 2 Farbabstufungen
                  move.w   #1,8-90(a0)       ;work_out[4]: Anzahl der Farbebenen
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
                  move.w   #1,(a0)+       ;[2] Anzahl der Ebenen
                  move.l   #2,(a0)+       ;[3/4] Farbanzahl
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

                  clr.w    (a0)+          ;[16] Farbeindex 0
                  move.w   #254,d0
                  moveq    #1,d1
scrninfo_loop:    move.w   d1,(a0)+
                  dbra     d0,scrninfo_loop

                  movem.l  (sp)+,d0-d1/a0-a1
                  rts

;Eingaben:
;a0.l Zeiger auf resinfo-Struktur
get_resinfo:      rts

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
                  move.w   #0,r_planes(a6)   ;Anzahl der Bildebenen -1
                  move.w   #1,colors(a6) ;hoechste Farbnummer

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

                  tst.w    cpu020               ;Prozessor mit Cache?
                  beq.s    wk_defaults_exit
                  move.l   #fbox_tt,p_fbox(a6)
                  move.l   #fline_tt,p_fline(a6)
                  move.l   #hline_tt,p_hline(a6)

wk_defaults_exit: rts

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
get_pixel:        tst.w    bitmap_width(a6)
                  beq.s    get_pixel_screen
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    get_pixel_line
get_pixel_screen: movea.l  v_bas_ad.w,a0
relok0:
                  muls     BYTES_LIN.w,d1
get_pixel_line:   add.l    d1,a0
                  move.w   d0,d1
                  lsr.w    #3,d0
                  adda.w   d0,a0
                  not.w    d1
                  and.w    #7,d1
                  moveq    #0,d0
                  btst     d1,(a0)
                  beq.s    get_pixel_exit
                  addq.w   #1,d0 
get_pixel_exit:   rts

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
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    set_pixel_line
set_pixel_screen: movea.l  v_bas_ad.w,a0
relok1:
                  muls     BYTES_LIN.w,d1
set_pixel_line:   add.l    d1,a0
                  move.w   d0,d1
                  lsr.w    #3,d0
                  adda.w   d0,a0
                  not.w    d1
                  and.w    #7,d1
                  ror.w    #1,d2
                  bcc.s    set_pixel_clear
                  bset     d1,(a0)
                  rts
set_pixel_clear:  bclr     d1,(a0)
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
set_pattern:      REPT     8
                  move.l   (a0)+,(a1)+
                  ENDM
                  moveq    #0,d0          ;1 Ebene
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
vdi_to_color:     rts

;Farbwert in VDI-Farbindex umsetzen
;Vorgaben:
;Register d0/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l Farbwert
;a6.l Workstation
;Ausgaben:
;d0.w VDI-Farbindex
color_to_vdi:     rts
               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'Bitblocktransfer'


textblt_box:      move.w   a3,r_dwidth(a6) ;Breite der Zielzeile in Bytes
                  move.l   a1,r_daddr(a6) ;Zeiladresse
                  moveq    #0,d7

;Bitblocktransfer per Software
;Eingaben
;d0.w x-Quelle
;d1.w y-Quelle
;d2.w x-Ziel
;d3.w y-Ziel
;d4.w dx
;d5.w dy
;a6.l Workstationstruktur
;Ausgaben
;d0-a5 werden zerstoert
bltbox:           cmpi.w   #5,d7          ;Modus 5, nichts ?
                  beq.s    blt_exit

                  move.w   d2,d0          ;x1
                  move.w   d3,d1          ;y1
                  add.w    d4,d2          ;x2
                  add.w    d5,d3          ;y2

                  move.w   r_dwidth(a6),d4 ;Breite der Zielzeile in Bytes
                  movea.l  r_daddr(a6),a1 ;Zeiladresse

                  tst.w    d7             ;white
                  beq      fbox_screen_tt

bltbox_m10:       lea      fill1(pc),a0
                  cmpi.w   #10,d7         ;not
                  beq      fbox_screen_tt
bltbox_m15:       cmp.w    #15,d7
                  bne.s    blt_exit
                  moveq    #2,d7
                  bra      fbox_screen_tt

blt_exit:         rts

;Bitblocktransfer ohne Clipping
;Vorgaben:
;Register d0-d7/a0-a6 koennen veraendert werden
;Eingaben:
;Vorgaben:
;Register d0-d7/a0-a5 koennen veraendert werden
;Eingaben:
;d0.w xq (linke x-Koordinate des Quellrechtecks)
;d1.w yq (obere y-Koordinate des Quellrechtecks)
;d2.w xz (linke x-Koordinate des Zielrechtecks)
;d3.w yz (obere y-Koordinate des Zielrechtecks)
;d4.w dx (Breite -1)
;d5.w dy (Hoehe -1)
;a6.l Workstation
bitblt:           cmp.w    d4,d6                            ;horizontal skalieren?
;                 bne      bitblt_scale
                  cmp.w    d5,d7                            ;vertikal skalieren?
;                 bne      bitblt_scale

                  bclr     #4,r_wmode+1(a6)                 ;vrt_cpyfm mit Schreibmodus 0-3?
                  bne.s    expblt

                  clr.l    r_fgcol(a6)    ;r_fgcol/r_bgcol
                  moveq    #15,d7
                  and.w    r_wmode(a6),d7
                  bra.s    bitblt_planes

expblt_modes:     DC.B 0,12,3,15          ;REPLACE
                  DC.B 4,4,7,7            ;OR
                  DC.B 6,6,6,6            ;EOR
                  DC.B 1,13,1,13          ;NOT OR

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
;a6.l r_wmode, r_fgcol, r_bgcol, r_saddr, r_daddr, r_swidth, r_wwidth, r_dplanes
;Ausgaben:
;-
expblt:           moveq    #3,d7
                  and.w    r_wmode(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  lea      r_fgcol(a6),a0
                  move.w   (a0)+,d6       ;r_fgcol
                  add.w    d6,d6          ;* 2
                  add.w    (a0)+,d6       ;+ r_bgcol
                  add.w    d7,d6
                  move.b   expblt_modes(pc,d6.w),d7

bitblt_planes:    move.w   r_splanes(a6),d6
                  or.w     r_dplanes(a6),d6 ;beide nur eine Plane - 1?
                  bne.s    blt_exit

                  move.w   #%1000010000100001,d6
                  btst     d7,d6
                  bne      bltbox

                  subq.w   #1,d7          ;Modus -1
                  lsl.w    #3,d7          ;*8

                  movea.l  r_saddr(a6),a0 ;Quelladresse
                  movea.l  r_daddr(a6),a1 ;Zieladresse
                  movea.w  r_swidth(a6),a2 ;Bytes pro Quellzeile
                  movea.w  r_dwidth(a6),a3 ;Bytes pro Zielzeile

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
                  movea.w  d6,a4
                  moveq    #15,d6
                  and.w    d2,d6
                  sub.w    a4,d6
                  bgt      bitblt_dec
                  bne.s    bitblt_inc
                  cmpa.w   a2,a3
                  bgt      bitblt_dec

bitblt_inc:       movea.w  d7,a5          ;(Verknuepfung -1) * 8

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

blt_inc_tab:      DC.W blt_inc_1-blt_inc_tab,blt_inc_last_1-blt_inc_tab,blt_inc_next_1-blt_inc_tab,0
                  DC.W blt_inc_2-blt_inc_tab,blt_inc_last_2-blt_inc_tab,blt_inc_next_2-blt_inc_tab,0
                  DC.W blt_inc_3-blt_inc_tab,0,0,0
                  DC.W blt_inc_4-blt_inc_tab,blt_inc_last_4-blt_inc_tab,blt_inc_next_4-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_6-blt_inc_tab,blt_inc_last_6-blt_inc_tab,blt_inc_next_6-blt_inc_tab,0
                  DC.W blt_inc_7-blt_inc_tab,blt_inc_last_7-blt_inc_tab,blt_inc_next_7-blt_inc_tab,0
                  DC.W blt_inc_8-blt_inc_tab,blt_inc_last_8-blt_inc_tab,blt_inc_next_8-blt_inc_tab,0
                  DC.W blt_inc_9-blt_inc_tab,blt_inc_last_9-blt_inc_tab,blt_inc_next_9-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_11-blt_inc_tab,blt_inc_last_11-blt_inc_tab,blt_inc_next_11-blt_inc_tab,0
                  DC.W blt_inc_12-blt_inc_tab,blt_inc_last_12-blt_inc_tab,blt_inc_next_12-blt_inc_tab,0
                  DC.W blt_inc_13-blt_inc_tab,blt_inc_last_13-blt_inc_tab,blt_inc_next_13-blt_inc_tab,0
                  DC.W blt_inc_14-blt_inc_tab,blt_inc_last_14-blt_inc_tab,blt_inc_next_14-blt_inc_tab,0

blt_inc_l_tab:    DC.W blt_inc_l1-blt_inc_tab,blt_inc_last_l1-blt_inc_tab,blt_inc_next_l1-blt_inc_tab,0
                  DC.W blt_inc_l2-blt_inc_tab,blt_inc_last_l2-blt_inc_tab,blt_inc_next_l2-blt_inc_tab,0
                  DC.W blt_inc_l3-blt_inc_tab,blt_inc_last_l3-blt_inc_tab,blt_inc_next_l3-blt_inc_tab,0
                  DC.W blt_inc_l4-blt_inc_tab,blt_inc_last_l4-blt_inc_tab,blt_inc_next_l4-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_l6-blt_inc_tab,blt_inc_last_l6-blt_inc_tab,blt_inc_next_l6-blt_inc_tab,0
                  DC.W blt_inc_l7-blt_inc_tab,blt_inc_last_l7-blt_inc_tab,blt_inc_next_l7-blt_inc_tab,0
                  DC.W blt_inc_l8-blt_inc_tab,blt_inc_last_l8-blt_inc_tab,blt_inc_next_l8-blt_inc_tab,0
                  DC.W blt_inc_l9-blt_inc_tab,blt_inc_last_l9-blt_inc_tab,blt_inc_next_l9-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_l11-blt_inc_tab,blt_inc_last_l11-blt_inc_tab,blt_inc_next_l11-blt_inc_tab,0
                  DC.W blt_inc_l12-blt_inc_tab,blt_inc_last_l12-blt_inc_tab,blt_inc_next_l12-blt_inc_tab,0
                  DC.W blt_inc_l13-blt_inc_tab,blt_inc_last_l13-blt_inc_tab,blt_inc_next_l13-blt_inc_tab,0
                  DC.W blt_inc_l14-blt_inc_tab,blt_inc_last_l14-blt_inc_tab,blt_inc_next_l14-blt_inc_tab,0

blt_inc_r_tab:    DC.W blt_inc_r1-blt_inc_tab,blt_inc_last_r1-blt_inc_tab,blt_inc_next_r1-blt_inc_tab,0
                  DC.W blt_inc_r2-blt_inc_tab,blt_inc_last_r2-blt_inc_tab,blt_inc_next_r2-blt_inc_tab,0
                  DC.W blt_inc_r3-blt_inc_tab,blt_inc_last_r3-blt_inc_tab,blt_inc_next_r3-blt_inc_tab,0
                  DC.W blt_inc_r4-blt_inc_tab,blt_inc_last_r4-blt_inc_tab,blt_inc_next_r4-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_r6-blt_inc_tab,blt_inc_last_r6-blt_inc_tab,blt_inc_next_r6-blt_inc_tab,0
                  DC.W blt_inc_r7-blt_inc_tab,blt_inc_last_r7-blt_inc_tab,blt_inc_next_r7-blt_inc_tab,0
                  DC.W blt_inc_r8-blt_inc_tab,blt_inc_last_r8-blt_inc_tab,blt_inc_next_r8-blt_inc_tab,0
                  DC.W blt_inc_r9-blt_inc_tab,blt_inc_last_r9-blt_inc_tab,blt_inc_next_r9-blt_inc_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_inc_r11-blt_inc_tab,blt_inc_last_r11-blt_inc_tab,blt_inc_next_r11-blt_inc_tab,0
                  DC.W blt_inc_r12-blt_inc_tab,blt_inc_last_r12-blt_inc_tab,blt_inc_next_r12-blt_inc_tab,0
                  DC.W blt_inc_r13-blt_inc_tab,blt_inc_last_r13-blt_inc_tab,blt_inc_next_r13-blt_inc_tab,0
                  DC.W blt_inc_r14-blt_inc_tab,blt_inc_last_r14-blt_inc_tab,blt_inc_next_r14-blt_inc_tab,0

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

bitblt_dec:       movea.w  d7,a5          ;(Verknuepfung - 1) * 8

                  movea.l  r_saddr(a6),a0 ;Quelladresse
                  movea.l  r_daddr(a6),a1 ;Zieladresse

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

blt_dec_tab:      DC.W blt_dec_1-blt_dec_tab,blt_dec_last_1-blt_dec_tab,blt_dec_next_1-blt_dec_tab,0
                  DC.W blt_dec_2-blt_dec_tab,blt_dec_last_2-blt_dec_tab,blt_dec_next_2-blt_dec_tab,0
                  DC.W blt_dec_3-blt_dec_tab,0,0,0
                  DC.W blt_dec_4-blt_dec_tab,blt_dec_last_4-blt_dec_tab,blt_dec_next_4-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_6-blt_dec_tab,blt_dec_last_6-blt_dec_tab,blt_dec_next_6-blt_dec_tab,0
                  DC.W blt_dec_7-blt_dec_tab,blt_dec_last_7-blt_dec_tab,blt_dec_next_7-blt_dec_tab,0
                  DC.W blt_dec_8-blt_dec_tab,blt_dec_last_8-blt_dec_tab,blt_dec_next_8-blt_dec_tab,0
                  DC.W blt_dec_9-blt_dec_tab,blt_dec_last_9-blt_dec_tab,blt_dec_next_9-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_11-blt_dec_tab,blt_dec_last_11-blt_dec_tab,blt_dec_next_11-blt_dec_tab,0
                  DC.W blt_dec_12-blt_dec_tab,blt_dec_last_12-blt_dec_tab,blt_dec_next_12-blt_dec_tab,0
                  DC.W blt_dec_13-blt_dec_tab,blt_dec_last_13-blt_dec_tab,blt_dec_next_13-blt_dec_tab,0
                  DC.W blt_dec_14-blt_dec_tab,blt_dec_last_14-blt_dec_tab,blt_dec_next_14-blt_dec_tab,0

blt_dec_l_tab:    DC.W blt_dec_l1-blt_dec_tab,blt_dec_last_l1-blt_dec_tab,blt_dec_next_l1-blt_dec_tab,0
                  DC.W blt_dec_l2-blt_dec_tab,blt_dec_last_l2-blt_dec_tab,blt_dec_next_l2-blt_dec_tab,0
                  DC.W blt_dec_l3-blt_dec_tab,blt_dec_last_l3-blt_dec_tab,blt_dec_next_l3-blt_dec_tab,0
                  DC.W blt_dec_l4-blt_dec_tab,blt_dec_last_l4-blt_dec_tab,blt_dec_next_l4-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_l6-blt_dec_tab,blt_dec_last_l6-blt_dec_tab,blt_dec_next_l6-blt_dec_tab,0
                  DC.W blt_dec_l7-blt_dec_tab,blt_dec_last_l7-blt_dec_tab,blt_dec_next_l7-blt_dec_tab,0
                  DC.W blt_dec_l8-blt_dec_tab,blt_dec_last_l8-blt_dec_tab,blt_dec_next_l8-blt_dec_tab,0
                  DC.W blt_dec_l9-blt_dec_tab,blt_dec_last_l9-blt_dec_tab,blt_dec_next_l9-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_l11-blt_dec_tab,blt_dec_last_l11-blt_dec_tab,blt_dec_next_l11-blt_dec_tab,0
                  DC.W blt_dec_l12-blt_dec_tab,blt_dec_last_l12-blt_dec_tab,blt_dec_next_l12-blt_dec_tab,0
                  DC.W blt_dec_l13-blt_dec_tab,blt_dec_last_l13-blt_dec_tab,blt_dec_next_l13-blt_dec_tab,0
                  DC.W blt_dec_l14-blt_dec_tab,blt_dec_last_l14-blt_dec_tab,blt_dec_next_l14-blt_dec_tab,0

blt_dec_r_tab:    DC.W blt_dec_r1-blt_dec_tab,blt_dec_last_r1-blt_dec_tab,blt_dec_next_r1-blt_dec_tab,0
                  DC.W blt_dec_r2-blt_dec_tab,blt_dec_last_r2-blt_dec_tab,blt_dec_next_r2-blt_dec_tab,0
                  DC.W blt_dec_r3-blt_dec_tab,blt_dec_last_r3-blt_dec_tab,blt_dec_next_r3-blt_dec_tab,0
                  DC.W blt_dec_r4-blt_dec_tab,blt_dec_last_r4-blt_dec_tab,blt_dec_next_r4-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_r6-blt_dec_tab,blt_dec_last_r6-blt_dec_tab,blt_dec_next_r6-blt_dec_tab,0
                  DC.W blt_dec_r7-blt_dec_tab,blt_dec_last_r7-blt_dec_tab,blt_dec_next_r7-blt_dec_tab,0
                  DC.W blt_dec_r8-blt_dec_tab,blt_dec_last_r8-blt_dec_tab,blt_dec_next_r8-blt_dec_tab,0
                  DC.W blt_dec_r9-blt_dec_tab,blt_dec_last_r9-blt_dec_tab,blt_dec_next_r9-blt_dec_tab,0
                  DC.W 0,0,0,0
                  DC.W blt_dec_r11-blt_dec_tab,blt_dec_last_r11-blt_dec_tab,blt_dec_next_r11-blt_dec_tab,0
                  DC.W blt_dec_r12-blt_dec_tab,blt_dec_last_r12-blt_dec_tab,blt_dec_next_r12-blt_dec_tab,0
                  DC.W blt_dec_r13-blt_dec_tab,blt_dec_last_r13-blt_dec_tab,blt_dec_next_r13-blt_dec_tab,0
                  DC.W blt_dec_r14-blt_dec_tab,blt_dec_last_r14-blt_dec_tab,blt_dec_next_r14-blt_dec_tab,0

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
                  add.w    d1,d1
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
                  add.w    d3,d3
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

                  moveq    #31,d0
                  and.w    r_wmode(a6),d0
                  cmp.w    #16,d0                           ;logische Verknuepfung?
                  blt.s    write_line_mode
                  
                  and.w    #3,d0                            ;Schreibmodus
                  add.w    d0,d0
                  add.w    d0,d0
                  lea      r_fgcol(a6),a1
                  move.w   (a1)+,d1                         ;r_fgcol
                  add.w    d1,d1                            ;* 2
                  add.w    (a1)+,d1                         ;+ r_bgcol
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
wl_1_1_mode0:     movem.w  (a2),d0/d2-d3

                  moveq    #0,d1
                  and.w    d2,(a1)+                         ;Ziel maskieren

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m0_2nd
                  
wl_1_1_m0_loop:   move.w   d1,(a1)+                         ;Zwischenteil kopieren
                  dbra     d0,wl_1_1_m0_loop

wl_1_1_m0_end:    and.w    d3,(a1)+                         ;Ziel maskieren
                  rts

wl_1_1_m0_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m0_end
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_1_1_mode1:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m1_2nd
                  
wl_1_1_m1_loop:   move.w   (a0)+,d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_1_1_m1_loop

wl_1_1_m1_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m1_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m1_end
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_1_1_mode2:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1                            ;Quelle maskieren
                  not.w    d2
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m2_2nd
                  
wl_1_1_m2_loop:   move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  and.w    d1,(a1)+
                  dbra     d0,wl_1_1_m2_loop

wl_1_1_m2_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1                            ;Quelle maskieren
                  not.w    d3
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m2_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m2_end
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_1_1_mode3:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m3_2nd
                  
wl_1_1_m3_loop:   move.w   (a0)+,(a1)+                      ;Zwischenteil kopieren
                  dbra     d0,wl_1_1_m3_loop

wl_1_1_m3_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m3_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m3_end
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_1_1_mode4:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d2,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m4_2nd
                  
wl_1_1_m4_loop:   move.w   (a0)+,d1
                  not.w    d1
                  and.w    d1,(a1)+
                  dbra     d0,wl_1_1_m4_loop

wl_1_1_m4_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  not.w    d1
                  or.w     d3,d1                            ;Quelle maskieren
                  and.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m4_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m4_end
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_1_1_mode5:     rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_1_1_mode6:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m6_2nd
                  
wl_1_1_m6_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)+
                  dbra     d0,wl_1_1_m6_loop

wl_1_1_m6_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m6_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m6_end
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_1_1_mode7:     movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m7_2nd
                  
wl_1_1_m7_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_1_1_m7_loop

wl_1_1_m7_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m7_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m7_end
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_1_1_mode8:     movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m8_2nd
                  
wl_1_1_m8_loop:   move.w   (a0)+,d1
                  or.w     d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_1_1_m8_loop

wl_1_1_m8_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d1,(a1)
                  eor.w    d3,(a1)+
                  rts

wl_1_1_m8_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m8_end
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_1_1_mode9:     movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m9_2nd
                  
wl_1_1_m9_loop:   move.w   (a0)+,d1
                  eor.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_1_1_m9_loop

wl_1_1_m9_end:    move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d1,(a1)
                  eor.w    d3,(a1)+
                  rts

wl_1_1_m9_2nd:    addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m9_end
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_1_1_mode10:    movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m10_2nd
                  
wl_1_1_m10_loop:  not.w    (a1)+
                  dbra     d0,wl_1_1_m10_loop

wl_1_1_m10_end:   eor.w    d3,(a1)+
                  rts

wl_1_1_m10_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m10_end
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_1_1_mode11:    movem.w  (a2),d0/d2-d3

                  not.w    d2
                  not.w    d3
                  
                  move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d2,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m11_2nd
                  
wl_1_1_m11_loop:  move.w   (a0)+,d1
                  not.w    (a1)                             ;Ziel invertieren
                  or.w     d1,(a1)+
                  dbra     d0,wl_1_1_m11_loop

wl_1_1_m11_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  eor.w    d3,(a1)                          ;Ziel invertieren
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m11_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m11_end
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_1_1_mode12:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d2,(a1)                          ;Ziel maskieren
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m12_2nd
                  
wl_1_1_m12_loop:  move.w   (a0)+,d1
                  not.w    d1
                  move.w   d1,(a1)+
                  dbra     d0,wl_1_1_m12_loop

wl_1_1_m12_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  and.w    d3,(a1)                          ;Ziel maskieren
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m12_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m12_end
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_1_1_mode13:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m13_2nd
                  
wl_1_1_m13_loop:  move.w   (a0)+,d1
                  not.w    d1
                  or.w     d1,(a1)+
                  dbra     d0,wl_1_1_m13_loop

wl_1_1_m13_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  not.w    d1
                  or.w     d1,(a1)+                         ;Wort ausgeben
                  rts

wl_1_1_m13_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m13_end
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_1_1_mode14:    movem.w  (a2),d0/d2-d3

                  move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d2,d1
                  and.w    d1,(a1)
                  not.w    d2
                  eor.w    d2,(a1)+

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m14_2nd
                  
wl_1_1_m14_loop:  move.w   (a0)+,d1
                  and.w    d1,(a1)
                  not.w    (a1)+
                  dbra     d0,wl_1_1_m14_loop

wl_1_1_m14_end:   move.w   (a0)+,d1                         ;Wort einlesen
                  or.w     d3,d1
                  and.w    d1,(a1)
                  not.w    d3
                  eor.w    d3,(a1)+
                  rts

wl_1_1_m14_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m14_end
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_1_1_mode15:    movem.w  (a2),d0/d2-d3

                  moveq    #$ffffffff,d1
                  not.w    d2
                  not.w    d3
                  or.w     d2,(a1)+                         ;Ziel maskieren

                  subq.w   #2,d0                            ;Zwischenteil vorhanden?
                  bmi.s    wl_1_1_m15_2nd
                  
wl_1_1_m15_loop:  move.w   d1,(a1)+                         ;Zwischenteil kopieren
                  dbra     d0,wl_1_1_m15_loop

wl_1_1_m15_end:   or.w     d3,(a1)+                         ;Ziel maskieren
                  rts

wl_1_1_m15_2nd:   addq.w   #1,d0                            ;Endwort ausgeben
                  beq.s    wl_1_1_m15_end
                  rts
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'gefuelltes Rechteck'

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
fbox_tt:          move.w   wr_mode(a6),d7
                  add.w    d7,d7
                  add.w    f_color(a6),d7
                  add.w    d7,d7

                  movea.l  f_pointer(a6),a0 ;Zeiger auf das Fuellmuster

                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok2:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_screen_tt
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1)+,d3       ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile
fbox_screen_tt:   movea.w  d4,a3
                  muls     d1,d4
                  adda.l   d4,a1
                  move.w   d0,d5          ;x1 sichern
                  asr.w    #5,d0          ;x1 / 32
                  move.w   d0,d4
                  add.w    d4,d4
                  add.w    d4,d4
                  adda.w   d4,a1          ;Startadresse

                  sub.w    d1,d3          ;Zeilenzaehler (y2 - y1)

                  moveq    #31,d6
                  and.w    d6,d5
                  moveq    #$ffffffff,d4
                  lsr.l    d5,d4
                  and.w    d2,d6
                  eori.w   #31,d6
                  moveq    #$ffffffff,d5
                  lsl.l    d6,d5

                  moveq    #15,d6
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
                  and.w    d6,d1
                  adda.w   d1,a0
                  adda.w   d1,a0          ;Musterstartadresse
                  eor.w    d6,d1          ;Musterzeilenzaehler

                  asr.w    #5,d2          ;x2 / 32
                  sub.w    d0,d2          ;(x2 / 32) - (x1 / 32) = Langwortanzahl
                  beq.s    fbox_long_tt   ;nur ein Langwort ?
                  move.w   d2,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  suba.w   d0,a3          ;Byterest pro Zeile
                  subq.w   #1,d2
                  move.w   fbox_tab_tt(pc,d7.w),d7
                  jmp      fbox_tab_tt(pc,d7.w)

fbox_tab_tt:      DC.W fbox4_tt-fbox_tab_tt
                  DC.W fbox0_tt-fbox_tab_tt
                  DC.W fbox5_tt-fbox_tab_tt
                  DC.W fbox1_tt-fbox_tab_tt
                  DC.W fbox2_tt-fbox_tab_tt
                  DC.W fbox2_tt-fbox_tab_tt
                  DC.W fbox7_tt-fbox_tab_tt
                  DC.W fbox3_tt-fbox_tab_tt

;Routinen fuer ein einziges Long
fbox_long_tt:     and.l    d5,d4
                  move.l   d4,d5
                  not.l    d5
                  bra      fbox_long_in

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
fbox0_tt:         move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7
                  not.l    d6
                  and.l    d4,d6
                  or.l     d4,(a1)
                  eor.l    d6,(a1)+
                  bra.s    fbox_next0_tt
fbox_loop0_tt:    move.l   d7,(a1)+
fbox_next0_tt:    dbra     d0,fbox_loop0_tt
                  not.l    d7
                  and.l    d5,d7
                  or.l     d5,(a1)
                  eor.l    d7,(a1)
                  adda.w   a3,a1
                  dbra     d1,fbox_dbf0_tt
                  moveq    #15,d1
                  lea      -32(a0),a0
fbox_dbf0_tt:     dbra     d3,fbox0_tt
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox3_tt:         move.l   a0,d0
                  movea.l  buffer_addr(a6),a0
                  movea.l  f_pointer(a6),a6
                  sub.l    a6,d0
                  REPT 8
                  move.l   (a6)+,(a0)
                  not.l    (a0)+
                  ENDM
                  lea      -32(a0),a0
                  adda.w   d0,a0

;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox1_tt:         move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7
                  and.l    d4,d6
                  or.l     d6,(a1)+
                  bra.s    fbox_next1_tt
fbox_loop1_tt:    or.l     d7,(a1)+
fbox_next1_tt:    dbra     d0,fbox_loop1_tt
                  and.l    d5,d7
                  or.l     d7,(a1)
                  adda.w   a3,a1
                  dbra     d1,fbox_dbf1_tt
                  moveq    #15,d1
                  lea      -32(a0),a0
fbox_dbf1_tt:     dbra     d3,fbox1_tt
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox2_tt:         move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7
                  and.l    d4,d6
                  eor.l    d6,(a1)+
                  bra.s    fbox_next2_tt
fbox_loop2_tt:    eor.l    d7,(a1)+
fbox_next2_tt:    dbra     d0,fbox_loop2_tt
                  and.l    d5,d7
                  eor.l    d7,(a1)
                  adda.w   a3,a1
                  dbra     d1,fbox_dbf2_tt
                  moveq    #15,d1
                  lea      -32(a0),a0
fbox_dbf2_tt:     dbra     d3,fbox2_tt

                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; WHITE ;;;;;;;;;;;;;;;;;;;;;;;;;
fbox4_tt:         moveq    #0,d7
                  not.l    d4
                  not.l    d5
fbox44_tt:        move.w   d2,d0
                  and.l    d4,(a1)+
                  bra.s    fbox_next4_tt
fbox_loop4_tt:    move.l   d7,(a1)+
fbox_next4_tt:    dbra     d0,fbox_loop4_tt
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox44_tt
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;  NOT AND ;;;;;;;;;;;;;;;;;;;;;;;;;
fbox5_tt:         move.l   a0,d0
                  movea.l  buffer_addr(a6),a0
                  movea.l  f_pointer(a6),a6
                  sub.l    a6,d0
                  REPT 8
                  move.l   (a6)+,(a0)
                  not.l    (a0)+
                  ENDM
                  lea      -32(a0),a0
                  adda.w   d0,a0
;;;;;;;;;;;;;;;;;;;;;;;;;; AND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox7_tt:         not.l    d4

                  not.l    d5
fbox_bloop7_tt:   move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7
                  or.l     d4,d6
                  and.l    d6,(a1)+
                  bra.s    fbox_next7_tt
fbox_loop7_tt:    and.l    d7,(a1)+
fbox_next7_tt:    dbra     d0,fbox_loop7_tt
                  or.l     d5,d7
                  and.l    d7,(a1)
                  adda.w   a3,a1
                  dbra     d1,fbox_dbf7_tt
                  moveq    #15,d1
                  lea      -32(a0),a0
fbox_dbf7_tt:     dbra     d3,fbox_bloop7_tt
                  rts

fbox_mask1:       DC.W %1111111111111111
fbox_mask2:       DC.W %111111111111111
                  DC.W %11111111111111
                  DC.W %1111111111111
                  DC.W %111111111111
                  DC.W %11111111111
                  DC.W %1111111111
                  DC.W %111111111
                  DC.W %11111111
                  DC.W %1111111
                  DC.W %111111
                  DC.W %11111
                  DC.W %1111
                  DC.W %111
                  DC.W %11
                  DC.W %1
                  DC.W %0

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
fbox:             move.w   wr_mode(a6),d7
                  add.w    d7,d7
                  add.w    f_color(a6),d7
                  beq      fbox_white
                  tst.w    f_interior(a6)
                  bne.s    fbox_mode
                  subq.w   #1,d7          ;Replace ?
                  beq      fbox_white
                  addq.w   #1,d7

fbox_mode:        add.w    d7,d7

fbox_pointer:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok3:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  move.w   bitmap_width(a6),d5 ;Off-Screen-Bitmap?
                  beq.s    fbox_screen
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1),d3        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   d5,d4          ;Bytes pro Zeile
fbox_screen:      movea.w  d4,a3
                  muls     d1,d4
                  adda.l   d4,a1
                  move.w   d0,d4          ;x1 sichern
                  asr.w    #4,d0          ;x1 / 16
                  adda.w   d0,a1
                  adda.w   d0,a1          ;Startadresse

                  moveq    #15,d6
                  move.w   d2,d5
                  and.w    d6,d4
                  and.w    d6,d5
                  add.w    d4,d4
                  add.w    d5,d5
                  move.w   fbox_mask1(pc,d4.w),d4 ;Startmaske
                  move.w   fbox_mask2(pc,d5.w),d5
                  not.w    d5             ;Endmaske

                  sub.w    d1,d3          ;Zeilenzaehler (y2 - y1)

                  movea.l  f_pointer(a6),a0 ;Zeiger auf das Fuellmuster
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
                  and.w    d6,d1
                  adda.w   d1,a0
                  adda.w   d1,a0          ;Musterstartadresse
                  eor.w    d6,d1          ;Musterzeilenzaehler

fbox_count:       asr.w    #4,d2          ;x2 / 16
                  sub.w    d0,d2          ;(x2 / 16) - (x1 / 16) = Wortanzahl
                  move.w   d2,d0
                  beq      fbox_word      ;nur ein Wort ?
                  subq.w   #2,d2          ;nur ein Langwort ?
                  bmi      fbox_long

                  add.w    d0,d0
                  suba.w   d0,a3          ;Byterest pro Zeile
                  move.w   d7,d6
                  add.w    d6,d6
                  move.w   d2,d0
                  lsr.w    #1,d2          ;Wortzaehler / 2 = Langwortzaehler
                  bcs.s    fbox_hcount    ;nur Langworte ?
                  movea.l  fbox_word_tab(pc,d6.w),a2
                  bne.s    fbox_pre       ;nur ein Wort dazwischen ?
                  moveq    #0,d2
                  movea.l  fbox_loop_tab(pc,d6.w),a4
                  lea      68(a4),a4      ;+ Offset innerhalb der Schleife
                  move.w   fbox_tab(pc,d7.w),d7
                  jmp      fbox_tab(pc,d7.w)
fbox_pre:         subq.w   #1,d2
                  lsr.w    #5,d2
                  subq.w   #2,d0
                  not.w    d0
                  andi.w   #62,d0
                  movea.l  fbox_loop_tab(pc,d6.w),a4
                  adda.w   d0,a4          ;+ Offset innerhalb der Schleife
                  move.w   fbox_tab(pc,d7.w),d7
                  jmp      fbox_tab(pc,d7.w)
fbox_exit:        rts

fbox_hcount:      lsr.w    #5,d2
                  not.w    d0
                  andi.w   #62,d0
                  movea.l  fbox_loop_tab(pc,d6.w),a2

                  adda.w   d0,a2
                  move.w   fbox_tab(pc,d7.w),d7
                  jmp      fbox_tab(pc,d7.w)

fbox_tab:         DC.W 0
                  DC.W fbox0-fbox_tab
                  DC.W fbox5-fbox_tab
                  DC.W fbox1-fbox_tab
                  DC.W fbox2-fbox_tab
                  DC.W fbox2-fbox_tab
                  DC.W fbox7-fbox_tab
                  DC.W fbox3-fbox_tab

fbox_word_tab:    DC.L 0
                  DC.L fbox_word0
                  DC.L fbox_word7
                  DC.L fbox_word1
                  DC.L fbox_word2
                  DC.L fbox_word2
                  DC.L fbox_word7
                  DC.L fbox_word1

fbox_loop_tab:    DC.L 0
                  DC.L fbox_loop0
                  DC.L fbox_loop7
                  DC.L fbox_loop1
                  DC.L fbox_loop2
                  DC.L fbox_loop2
                  DC.L fbox_loop7
                  DC.L fbox_loop1

;Routinen fuer ein einziges Wort
fbox_word:        and.w    d5,d4          ;neue Maske
                  move.w   d4,d5
                  not.w    d5
                  move.w   fboxw_tab(pc,d7.w),d7
                  jmp      fboxw_tab(pc,d7.w)

fboxw_tab:        DC.W fboxw4-fboxw_tab
                  DC.W fboxw0-fboxw_tab
                  DC.W fboxw5-fboxw_tab
                  DC.W fboxw1-fboxw_tab
                  DC.W fboxw2-fboxw_tab
                  DC.W fboxw2-fboxw_tab
                  DC.W fboxw7-fboxw_tab
                  DC.W fboxw3-fboxw_tab

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw0:           move.w   (a0)+,d6
                  and.w    d4,d6
                  and.w    d5,(a1)
                  or.w     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf0
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf0:       dbra     d3,fboxw0
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw1:           move.w   (a0)+,d6
                  and.w    d4,d6
                  or.w     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf1
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf1:       dbra     d3,fboxw1
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw2:           move.w   (a0)+,d6
                  and.w    d4,d6
                  eor.w    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf2
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf2:       dbra     d3,fboxw2
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw3:           move.w   (a0)+,d6
                  not.w    d6
                  and.w    d4,d6
                  or.w     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf3
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf3:       dbra     d3,fboxw3
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; WHITE ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw4:           and.w    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fboxw4
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;  NOT AND ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw5:           move.w   (a0)+,d6
                  not.w    d6
                  or.w     d5,d6
                  and.w    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf5
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf5:       dbra     d3,fboxw5
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;; AND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxw7:           move.w   (a0)+,d6
                  or.w     d5,d6
                  and.w    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxw_dbf7
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxw_dbf7:       dbra     d3,fboxw7
                  rts

;Routinen fuer ein einziges Long
fbox_long:        swap     d4
                  move.w   d5,d4
                  move.l   d4,d5
                  not.l    d5
fbox_long_in:     move.w   fbox_ltab(pc,d7.w),d7
                  jmp      fbox_ltab(pc,d7.w)

fbox_ltab:        DC.W fboxl4-fbox_ltab
                  DC.W fboxl0-fbox_ltab
                  DC.W fboxl5-fbox_ltab
                  DC.W fboxl1-fbox_ltab
                  DC.W fboxl2-fbox_ltab
                  DC.W fboxl2-fbox_ltab
                  DC.W fboxl7-fbox_ltab
                  DC.W fboxl3-fbox_ltab

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl0:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  and.l    d4,d6
                  and.l    d5,(a1)
                  or.l     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf0
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf0:       dbra     d3,fboxl0
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl1:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  and.l    d4,d6
                  or.l     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf1
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf1:       dbra     d3,fboxl1
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl2:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  and.l    d4,d6
                  eor.l    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf2
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf2:       dbra     d3,fboxl2
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl3:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  not.l    d6
                  and.l    d4,d6
                  or.l     d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf3
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf3:       dbra     d3,fboxl3
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; WHITE ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl4:           and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fboxl4
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;  NOT AND ;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl5:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  not.l    d6
                  or.l     d5,d6
                  and.l    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf5
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf5:       dbra     d3,fboxl5
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;; AND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fboxl7:           move.l   (a0),d6
                  move.w   (a0)+,d6
                  or.l     d5,d6
                  and.l    d6,(a1)
                  adda.w   a3,a1
                  dbra     d1,fboxl_dbf7
                  moveq    #15,d1
                  lea      -32(a0),a0
fboxl_dbf7:       dbra     d3,fboxl7
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
fbox0:            move.w   d2,d0

                  move.l   (a0),d6

                  move.w   (a0)+,d6
                  move.l   d6,d7

                  not.w    d6
                  and.w    d4,d6
                  or.w     d4,(a1)
                  eor.w    d6,(a1)+

                  jmp      (a2)
fbox_word0:       move.w   d7,(a1)+

                  jmp      (a4)
fbox_loop0:       REPT 32
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d0,fbox_loop0

fbox_last0:       not.w    d7
                  and.w    d5,d7
                  or.w     d5,(a1)
                  eor.w    d7,(a1)

                  adda.w   a3,a1

                  dbra     d1,fbox_dbf0
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_dbf0:        dbra     d3,fbox0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox3:            move.l   a0,d0
                  movea.l  buffer_addr(a6),a0
                  movea.l  f_pointer(a6),a6
                  sub.l    a6,d0
                  REPT 8
                  move.l   (a6)+,(a0)
                  not.l    (a0)+
                  ENDM
                  lea      -32(a0),a0
                  adda.w   d0,a0
;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox1:            move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7

                  and.w    d4,d6
                  or.w     d6,(a1)+

                  jmp      (a2)
fbox_word1:       or.w     d7,(a1)+
                  jmp      (a4)
fbox_loop1:       REPT 32
                  or.l     d7,(a1)+
                  ENDM
                  dbra     d0,fbox_loop1

fbox_last1:       and.w    d5,d7
                  or.w     d7,(a1)

                  adda.w   a3,a1

                  dbra     d1,fbox_dbf1
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_dbf1:        dbra     d3,fbox1
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox2:            move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7

                  and.w    d4,d6
                  eor.w    d6,(a1)+

                  jmp      (a2)
fbox_word2:       eor.w    d7,(a1)+
                  jmp      (a4)
fbox_loop2:       REPT 32
                  eor.l    d7,(a1)+
                  ENDM
                  dbra     d0,fbox_loop2

fbox_last2:       and.w    d5,d7
                  eor.w    d7,(a1)

                  adda.w   a3,a1

                  dbra     d1,fbox_dbf2
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_dbf2:        dbra     d3,fbox2
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;  NOT AND ;;;;;;;;;;;;;;;;;;;;;;;;;
fbox5:            move.l   a0,d0
                  movea.l  buffer_addr(a6),a0
                  movea.l  f_pointer(a6),a6
                  sub.l    a6,d0
                  REPT 8
                  move.l   (a6)+,(a0)
                  not.l    (a0)+
                  ENDM
                  lea      -32(a0),a0
                  adda.w   d0,a0
;;;;;;;;;;;;;;;;;;;;;;;;;; AND ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fbox7:            not.w    d4
                  not.w    d5

fbox_bloop7:      move.w   d2,d0
                  move.l   (a0),d6
                  move.w   (a0)+,d6
                  move.l   d6,d7

                  or.w     d4,d6
                  and.w    d6,(a1)+

                  jmp      (a2)
fbox_word7:       and.w    d7,(a1)+
                  jmp      (a4)
fbox_loop7:       REPT 32
                  and.l    d7,(a1)+
                  ENDM
                  dbra     d0,fbox_loop7

fbox_last7:       or.w     d5,d7
                  and.w    d7,(a1)

                  adda.w   a3,a1

                  dbra     d1,fbox_dbf7
                  moveq    #15,d1
                  lea      -32(a0),a0

fbox_dbf7:        dbra     d3,fbox_bloop7
                  rts


fbox_white:       movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok4:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_white_screen
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1),d3        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse des Bildschirms
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile
fbox_white_screen:movea.w  d4,a3          ;Bytes pro Zeile
                  muls     d1,d4
                  adda.l   d4,a1
                  move.w   d0,d7
                  andi.w   #$ffe0,d0
                  asr.w    #3,d0
                  adda.w   d0,a1          ;Startadresse

                  sub.w    d1,d3          ;Zeilenzaehler

                  moveq    #31,d6
                  moveq    #$ffffffff,d4
                  moveq    #$ffffffff,d5

                  and.w    d6,d7
                  lsr.l    d7,d4
                  move.w   d2,d7
                  not.w    d7
                  and.w    d6,d7
                  lsl.l    d7,d5
                  not.l    d4             ;Startmaske
                  not.l    d5             ;Endmaske

                  asr.w    #2,d0          ;x1/32
                  asr.w    #5,d2          ;x2/32
                  sub.w    d0,d2
                  move.w   d2,d0          ;Langwortzaehler
                  add.w    d0,d0          ;Wortzaehler
                  cmpi.w   #19,d2         ;mehr als 20 Langworte ?
                  bgt.s    fbox_whitexx
                  move.w   fbox_wtab(pc,d0.w),d7
                  add.w    d0,d0          ;Bytezaehler
                  suba.w   d0,a3          ;Bytes pro Zeile - Bytezaehler
                  subq.w   #7,d2          ;weniger als 8 Langworte ?
                  bmi.s    fbox_whitew7
                  adda.w   d0,a1          ;wegen pre-Dekrement bei movem
                  add.w    d0,d0
                  adda.w   d0,a3          ;Bytes pro Zeile + Bytezaehler
                  moveq    #0,d1
                  moveq    #0,d2
                  moveq    #0,d6
                  movea.l  d1,a0
                  movea.l  d1,a2
                  movea.l  d1,a4
                  movea.l  d1,a6
fbox_whitew7:     moveq    #0,d0
                  jmp      fbox_wtab(pc,d7.w)

fbox_whitexx:     move.l   a5,-(sp)
                  subq.w   #2,d2          ;Langwortzaehler -2 (ohne Masken)
                  ext.l    d2             ;erweitern
                  divu     #9,d2
                  subq.w   #1,d2          ;wegen des dbf
                  swap     d3
                  move.w   d2,d3
                  swap     d3
                  swap     d2
                  add.w    d2,d2          ;Offset in der Tabelle
                  add.w    d0,d0          ;Bytezaehler
                  adda.w   d0,a1          ;wegen pre-Dekrement bei movem
                  adda.w   d0,a3          ;Bytes pro Zeile + Offset
                  moveq    #0,d0
                  moveq    #0,d1
                  moveq    #0,d6
                  moveq    #0,d7
                  movea.l  d0,a0
                  movea.l  d0,a2
                  movea.l  d0,a4
                  movea.l  d0,a5
                  movea.l  d0,a6
                  move.w   fbox_wtab2(pc,d2.w),d2
                  jsr      fbox_wtab(pc,d2.w)
                  movea.l  (sp)+,a5
                  rts

fbox_wtab:        DC.W fbox_white0-fbox_wtab
                  DC.W fbox_white1-fbox_wtab
                  DC.W fbox_white2-fbox_wtab
                  DC.W fbox_white3-fbox_wtab
                  DC.W fbox_white4-fbox_wtab
                  DC.W fbox_white5-fbox_wtab
                  DC.W fbox_white6-fbox_wtab
                  DC.W fbox_white7-fbox_wtab
                  DC.W fbox_white8-fbox_wtab
                  DC.W fbox_white9-fbox_wtab
                  DC.W fbox_white10-fbox_wtab
                  DC.W fbox_white11-fbox_wtab
                  DC.W fbox_white12-fbox_wtab
                  DC.W fbox_white13-fbox_wtab
                  DC.W fbox_white14-fbox_wtab
                  DC.W fbox_white15-fbox_wtab
                  DC.W fbox_white16-fbox_wtab
                  DC.W fbox_white17-fbox_wtab
                  DC.W fbox_white18-fbox_wtab
                  DC.W fbox_white19-fbox_wtab
fbox_wtab2:       DC.W fbox_white20-fbox_wtab
                  DC.W fbox_white21-fbox_wtab
                  DC.W fbox_white22-fbox_wtab
                  DC.W fbox_white23-fbox_wtab
                  DC.W fbox_white24-fbox_wtab
                  DC.W fbox_white25-fbox_wtab
                  DC.W fbox_white26-fbox_wtab
                  DC.W fbox_white27-fbox_wtab
                  DC.W fbox_white28-fbox_wtab

fbox_white0:      or.l     d5,d4
fbox_whitel0:     and.l    d4,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_whitel0
                  rts
fbox_white1:      lsr.w    #1,d3
                  bcc.s    wfboxwhiteu1
fbox_whitel1:     and.l    d4,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
wfboxwhiteu1:     and.l    d4,(a1)+
                  and.l    d5,(a1)

                  adda.w   a3,a1
                  dbra     d3,fbox_whitel1
                  rts
fbox_white2:      lsr.w    #1,d3
                  bcc.s    wfboxwhiteu2
fbox_whitel2:     and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
wfboxwhiteu2:     and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_whitel2
                  rts
fbox_white3:      and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white3
                  rts
fbox_white4:      and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white4
                  rts
fbox_white5:      and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white5
                  rts
fbox_white6:      and.l    d4,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  move.l   d0,(a1)+
                  and.l    d5,(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white6
                  rts
fbox_white7:      and.l    d5,(a1)
                  movem.l  d0-d1/d6/a0/a2/a4,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1

                  dbra     d3,fbox_white7
                  rts
fbox_white8:      and.l    d5,(a1)
                  movem.l  d0-d1/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white8
                  rts
fbox_white9:      and.l    d5,(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white9
                  rts
fbox_white10:     moveq    #0,d7
fbox_whitel10:    and.l    d5,(a1)
                  movem.l  d0-d2/d6-a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_whitel10
                  rts
fbox_white11:     and.l    d5,(a1)
                  movem.l  d0-d1,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white11
                  rts
fbox_white12:     and.l    d5,(a1)
                  movem.l  d0-d2,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white12
                  rts
fbox_white13:     and.l    d5,(a1)
                  movem.l  d0-d2/d6,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white13
                  rts
fbox_white14:     and.l    d5,(a1)
                  movem.l  d0-d2/d6/a0,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white14
                  rts
fbox_white15:     and.l    d5,(a1)
                  movem.l  d0-d2/d6/a0/a2,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white15
                  rts
fbox_white16:     and.l    d5,(a1)
                  movem.l  d0-d2/d6/a0/a2/a4,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white16
                  rts
fbox_white17:     and.l    d5,(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  movem.l  d0-d2/d6/a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white17
                  rts
fbox_white18:     moveq    #0,d7
fbox_whitel18:    and.l    d5,(a1)
                  movem.l  d0-d2/d6-a0/a2/a4,-(a1)
                  movem.l  d0-d2/d6-a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_whitel18
                  rts
fbox_white19:     moveq    #0,d7
fbox_whitel19:    and.l    d5,(a1)
                  movem.l  d0-d2/d6-a0/a2/a4/a6,-(a1)
                  movem.l  d0-d2/d6-a0/a2/a4/a6,-(a1)
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_whitel19
                  rts

fbox_white20:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  move.l   d0,-(a1)
fbox_whiteb20:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb20
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white20
                  rts

fbox_white21:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1,-(a1)
fbox_whiteb21:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb21
                  and.l    d4,-(a1)

                  adda.w   a3,a1
                  dbra     d3,fbox_white21
                  rts


fbox_white22:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6,-(a1)
fbox_whiteb22:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb22
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white22
                  rts

fbox_white23:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-d7,-(a1)
fbox_whiteb23:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb23

                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white23
                  rts

fbox_white24:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-a0,-(a1)
fbox_whiteb24:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb24
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white24
                  rts

fbox_white25:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-a0/a2,-(a1)
fbox_whiteb25:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb25
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white25
                  rts

fbox_white26:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-a0/a2/a4,-(a1)
fbox_whiteb26:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb26
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white26
                  rts

fbox_white27:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-a0/a2/a4-a5,-(a1)
fbox_whiteb27:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb27
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white27
                  rts

fbox_white28:     move.l   d3,d2
                  swap     d2
                  and.l    d5,(a1)
                  movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
fbox_whiteb28:    movem.l  d0-d1/d6-a0/a2/a4-a6,-(a1)
                  dbra     d2,fbox_whiteb28
                  and.l    d4,-(a1)
                  adda.w   a3,a1
                  dbra     d3,fbox_white28
                  rts


                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'horizontale  Linie'

fline_tt:         movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6
                  add.w    d7,d7
                  add.w    f_color(a6),d7
                  add.w    d7,d7
                  bra.s    hline_saddr_tt

;horizontalen Linie ohne Clipping zeichnen
;Eingaben
;d0 x1
;d1 y
;d2 x2
;d6 Linienstil
;d7 Schreibmodus
;a6 Zeiger auf die Workstation
;Ausgaben
;d0-d2/d4-d7/a1 werden zerstoert
hline_tt:         add.w    d7,d7
                  add.w    l_color(a6),d7
                  add.w    d7,d7          ;wr_mode*4+l_color*2

hline_saddr_tt:   move.w   bitmap_width(a6),d4 ;Off-Screen-Bitmap?
                  beq.s    hline_screen_tt
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     d4,d1
                  bra.s    hline_laddr_tt
hline_screen_tt:  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok5:
                  muls     BYTES_LIN.w,d1
hline_laddr_tt:   adda.l   d1,a1          ;Zeilenadresse
                  move.w   d0,d1          ;x1 sichern
                  andi.w   #$ffe0,d0
                  asr.w    #3,d0
                  adda.w   d0,a1          ;Adresse des ersten Langwortes

                  move.w   d6,d5
                  swap     d6
                  move.w   d5,d6          ;32-Bit-Linienmuster

                  moveq    #31,d5
                  and.w    d5,d1          ;Anzahl der Shifts
                  moveq    #$ffffffff,d4
                  lsr.l    d1,d4          ;Startmaske
                  move.w   d2,d1
                  not.w    d1
                  and.w    d5,d1          ;Anzahl der Shifts
                  moveq    #$ffffffff,d5
                  lsl.l    d1,d5          ;Endmaske

                  asr.w    #3,d2
                  sub.w    d0,d2
                  asr.w    #2,d2          ;Anzahl der Langworte
                  subq.w   #1,d2
                  bmi      hlinell1       ;ein Langwort
                  beq      hlinell2       ;zwei Langworte
                  subq.w   #1,d2
                  move.w   htab_tt(pc,d7.w),d7
                  jmp      htab_tt(pc,d7.w)

hline_exit:       rts

;Tabelle mit Sprungadressen der Subroutinen fuer mehr als zwei Longs
htab_tt:          DC.W hline4_tt-htab_tt  ;weiss ersetzend
                  DC.W hline0_tt-htab_tt  ;ersetzend
                  DC.W hline5_tt-htab_tt  ;verundend
                  DC.W hline1_tt-htab_tt  ;and
                  DC.W hline2_tt-htab_tt  ;exlusiv verodernd
                  DC.W hline2_tt-htab_tt  ;exlusiv verodernd
                  DC.W hline7_tt-htab_tt  ;invers verodernd
                  DC.W hline3_tt-htab_tt  ;invers verodernd

;;;;;;;;;;;;; Subroutinen fuer die Grafikmodi ;;;;;;;;;;;;;;
;                        Parameter                        ;
;                   d0                Sprungoffset        ;
;                   d2                Zaehler              ;
;                   d4                Startmaske          ;
;                   d5                Endmaske            ;
;                   d6                Linienstil 1        ;
;                   a1                Adresse             ;
;                                                         ;
;                   veraenderte Register                   ;
;                   d2                Zaehler              ;
;                   d4                Startmaske          ;
;                   d5                Endmaske            ;
;                   d6                Linienstil 1        ;
;                   d7                Linienstil 2        ;
;                   a1                Adresse             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
hline4_tt:        moveq    #0,d6
                  not.l    d4             ;Start- und
                  not.l    d5             ;Endmaske invertieren
                  and.l    d4,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop4_tt:        move.l   d6,(a1)+
                  dbra     d2,hloop4_tt
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
hline0_tt:        cmp.w    #$ffff,d6
                  bne.s    hline00_tt
hline8_tt:        or.l     d4,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop8_tt:        move.l   d6,(a1)+
                  dbra     d2,hloop8_tt
                  or.l     d5,(a1)
                  rts

hline00_tt:       move.l   d6,d7
                  and.l    d4,d7
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d7,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop0_tt:        move.l   d6,(a1)+
                  dbra     d2,hloop0_tt
                  and.l    d5,d6          ;Linienstil maskieren
                  not.l    d5             ;Endmaske invertieren
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d6,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;
hline3_tt:        not.l    d6             ;Linienstil invertieren
;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erstes Langwort ausgeben
hline1_tt:        cmp.w    #$ffff,d6
                  beq.s    hline8_tt
                  and.l    d6,d4
                  or.l     d4,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop1_tt:        or.l     d6,(a1)+
                  dbra     d2,hloop1_tt
                  and.l    d6,d5          ;Linienstil maskieren
                  or.l     d5,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erstes Langwort ausgeben
hline2_tt:        and.l    d6,d4
                  eor.l    d4,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop2_tt:        eor.l    d6,(a1)+
                  dbra     d2,hloop2_tt
                  and.l    d6,d5          ;Linienstil maskieren
                  eor.l    d5,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erstes Langwort ausgeben
hline5_tt:        not.l    d6
hline7_tt:        not.l    d4
                  or.l     d6,d4          ;Linienstil maskieren
                  and.l    d4,(a1)+
;Linienmuster ausgeben und Zaehler dekrementieren
hloop5_tt:        and.l    d6,(a1)+
                  dbra     d2,hloop5_tt
                  not.l    d5
                  or.l     d6,d5
                  and.l    d5,(a1)
                  rts

hlinell1:         and.l    d5,d4
                  move.w   htab1(pc,d7.w),d7
                  jmp      htab1(pc,d7.w)

htab1:            DC.W hlinel4-htab1      ;weiss ersetzend
                  DC.W hlinel0-htab1      ;ersetzend
                  DC.W hlinel5-htab1      ;verundend
                  DC.W hlinel1-htab1      ;and
                  DC.W hlinel2-htab1      ;exlusiv verodernd
                  DC.W hlinel2-htab1      ;exlusiv verodernd
                  DC.W hlinel7-htab1      ;invers verodernd
                  DC.W hlinel3-htab1      ;invers verodernd

hlinel4:          not.l    d4
                  and.l    d4,(a1)
                  rts
hlinel0:          cmp.w    #$ffff,d6
                  beq.s    hlinel8
                  and.l    d4,d6
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d6,(a1)
                  rts
hlinel8:          or.l     d4,(a1)+
                  rts
hlinel3:          not.l    d6             ;Linienstil invertieren
hlinel1:          cmp.w    #$ffff,d6
                  beq.s    hlinel8
                  and.l    d6,d4
                  or.l     d4,(a1)
                  rts
hlinel2:          and.l    d6,d4
                  eor.l    d4,(a1)

                  rts
hlinel5:          not.l    d6
hlinel7:          not.l    d4
                  or.l     d6,d4
                  and.l    d4,(a1)
                  rts


hlinell2:         move.w   htab2(pc,d7.w),d7
                  jmp      htab2(pc,d7.w)

htab2:            DC.W hlinel24-htab2     ;weiss ersetzend
                  DC.W hlinel20-htab2     ;ersetzend
                  DC.W hlinel25-htab2     ;verundend
                  DC.W hlinel21-htab2     ;and
                  DC.W hlinel22-htab2     ;exlusiv verodernd
                  DC.W hlinel22-htab2     ;exlusiv verodernd
                  DC.W hlinel27-htab2     ;invers verodernd
                  DC.W hlinel23-htab2     ;invers verodernd

hlinel24:         not.l    d4
                  not.l    d5
                  and.l    d4,(a1)+
                  and.l    d5,(a1)
                  rts
hlinel20:         cmp.w    #$ffff,d6
                  beq.s    hlinel28
                  move.l   d6,d7
                  and.l    d4,d7
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d7,(a1)+
                  and.l    d5,d6
                  not.l    d5
                  and.l    d5,(a1)
                  or.l     d6,(a1)
                  rts
hlinel28:         or.l     d4,(a1)+
                  or.l     d5,(a1)
                  rts
hlinel23:         not.l    d6             ;Linienstil invertieren
hlinel21:         cmp.w    #$ffff,d6
                  beq.s    hlinel28
                  and.l    d6,d4
                  or.l     d4,(a1)+
                  and.l    d6,d5
                  or.l     d5,(a1)
                  rts
hlinel22:         and.l    d6,d4
                  eor.l    d4,(a1)+
                  and.l    d6,d5
                  eor.l    d5,(a1)
                  rts
hlinel25:         not.l    d6
hlinel27:         not.l    d4
                  or.l     d6,d4
                  and.l    d4,(a1)+
                  not.l    d5
                  or.l     d6,d5
                  and.l    d5,(a1)
                  rts

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
fline:            movea.l  f_pointer(a6),a1
                  moveq    #15,d4
                  and.w    d1,d4
                  add.w    d4,d4
                  move.w   0(a1,d4.w),d6
                  add.w    d7,d7
                  add.w    f_color(a6),d7
                  add.w    d7,d7
                  bra.s    hline_saddr

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
hline:            add.w    d7,d7
                  add.w    l_color(a6),d7
                  add.w    d7,d7          ;wr_mode*4+l_color*2

hline_saddr:      move.w   bitmap_width(a6),d4 ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     d4,d1
                  bra.s    hline_laddr
hline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok6:
                  muls     BYTES_LIN.w,d1
hline_laddr:      adda.l   d1,a1          ;Zeilenadresse
                  move.w   d0,d1          ;x1 sichern
                  andi.w   #$ffe0,d0
                  asr.w    #3,d0
                  adda.w   d0,a1          ;Adresse des ersten Langwortes

                  move.w   d6,d5
                  swap     d6
                  move.w   d5,d6          ;32-Bit-Linienmuster

                  moveq    #31,d5
                  and.w    d5,d1          ;Anzahl der Shifts
                  moveq    #$ffffffff,d4
                  lsr.l    d1,d4          ;Startmaske
                  move.w   d2,d1
                  not.w    d1
                  and.w    d5,d1          ;Anzahl der Shifts
                  moveq    #$ffffffff,d5
                  lsl.l    d1,d5          ;Endmaske

                  asr.w    #3,d2
                  sub.w    d0,d2
                  asr.w    #2,d2          ;Anzahl der Langworte
                  subq.w   #1,d2
                  bmi      hlinell1       ;ein Langwort
                  beq      hlinell2       ;zwei Langworte
                  subq.w   #1,d2
                  move.w   d2,d0
                  lsr.w    #5,d2          ;Schleifenzaehler
                  not.w    d0
                  andi.w   #31,d0
                  add.w    d0,d0          ;Sprungoffset

                  move.w   htab(pc,d7.w),d7
                  jmp      htab(pc,d7.w)

;Tabelle mit Sprungadressen der Subroutinen fuer mehr als zwei Longs
htab:
                  DC.W hline4-htab        ;weiss ersetzend
                  DC.W hline0-htab        ;ersetzend
                  DC.W hline5-htab        ;verundend
                  DC.W hline1-htab        ;and
                  DC.W hline2-htab        ;exlusiv verodernd
                  DC.W hline2-htab        ;exlusiv verodernd
                  DC.W hline7-htab        ;invers verodernd
                  DC.W hline3-htab        ;invers verodernd

;;;;;;;;;;;;; Subroutinen fuer die Grafikmodi ;;;;;;;;;;;;;;
;                        Parameter                        ;
;                   d0                Sprungoffset        ;
;                   d2                Zaehler              ;
;                   d4                Startmaske          ;
;                   d5                Endmaske            ;
;                   d6                Linienstil 1        ;
;                   a1                Adresse             ;
;                                                         ;
;                   veraenderte Register                   ;
;                   d2                Zaehler              ;
;                   d4                Startmaske          ;
;                   d5                Endmaske            ;
;                   d6                Linienstil 1        ;
;                   d7                Linienstil 2        ;
;                   a1                Adresse             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
hline4:           moveq    #0,d6
                  not.l    d4             ;Start- und
                  not.l    d5             ;Endmaske invertieren
                  and.l    d4,(a1)+
                  jmp      hloop4(pc,d0.w) ;relativ einspringen
;Linienmuster ausgeben und Zaehler dekrementieren
hloop4:           REPT 32
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d2,hloop4
;letztes Langwort ausgeben
hlastw4:          and.l    d5,(a1)        ;Bildinhalt maskieren
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;
hline0:           cmp.w    #$ffff,d6
                  bne.s    hline00
;erstes Langwort ausgeben
hline8:           or.l     d4,(a1)+
                  jmp      hloop8(pc,d0.w) ;relativ einspringen
;Linienmuster ausgeben und Zaehler dekrementieren
hloop8:           REPT 32
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d2,hloop8
;letztes Langwort ausgeben
hlastw8:          or.l     d5,(a1)
                  rts

hline00:          move.l   d6,d7
                  and.l    d4,d7
                  not.l    d4
                  and.l    d4,(a1)
                  or.l     d7,(a1)+
                  jmp      hloop0(pc,d0.w) ;relativ einspringen
;Linienmuster ausgeben und Zaehler dekrementieren
hloop0:           REPT 32
                  move.l   d6,(a1)+
                  ENDM
                  dbra     d2,hloop0
;letztes Langwort ausgeben
hlastw0:          and.l    d5,d6          ;Linienstil maskieren
                  not.l    d5             ;Endmaske invertieren
                  and.l    d5,(a1)        ;Bildinhalt maskieren
                  or.l     d6,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;
hline3:           not.l    d6             ;Linienstil invertieren
;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;

;erstes Langwort ausgeben
hline1:           cmp.w    #$ffff,d6
;   beq.s   hline8
                  beq      hline8
                  and.l    d6,d4
                  or.l     d4,(a1)+
                  jmp      hloop1(pc,d0.w)

;Linienmuster ausgeben und Zaehler dekrementieren
hloop1:           REPT 32
                  or.l     d6,(a1)+
                  ENDM
                  dbra     d2,hloop1
;letztes Langwort ausgeben
hlastw1:          and.l    d6,d5          ;Linienstil maskieren
                  or.l     d5,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erstes Langwort ausgeben
hline2:           and.l    d6,d4
                  eor.l    d4,(a1)+
                  jmp      hloop2(pc,d0.w)
;Linienmuster ausgeben und Zaehler dekrementieren
hloop2:           REPT 32
                  eor.l    d6,(a1)+
                  ENDM
                  dbra     d2,hloop2
;letztes Langwort ausgeben
hlastw2:          and.l    d6,d5          ;Linienstil maskieren
                  eor.l    d5,(a1)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erstes Langwort ausgeben
hline5:           not.l    d6
hline7:           not.l    d4
                  or.l     d6,d4          ;Linienstil maskieren
                  and.l    d4,(a1)+
                  jmp      hloop5(pc,d0.w)
;Linienmuster ausgeben und Zaehler dekrementieren
hloop5:           REPT 32
                  and.l    d6,(a1)+
                  ENDM
                  dbra     d2,hloop5
;letztes Langwort ausgeben
hlastw5:          not.l    d5
                  or.l     d6,d5
                  and.l    d5,(a1)
                  rts


                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'vertikale Linie'

;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;;
vline0:           addq.w   #1,d6
                  beq      vline10
                  subq.w   #1,d6
vline00:          rol.w    #1,d6
                  bcc.s    vline_white0
vline_black0:     or.b     d1,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline00
                  rts
vline_loop0:      rol.w    #1,d6
                  bcs.s    vline_black0
vline_white0:     and.b    d2,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline_loop0
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
vline3:           not.w    d6
;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vline1:           addq.w   #1,d6
                  beq      vline10
                  subq.w   #1,d6
vline11:          rol.w    #1,d6
                  bcc.s    vl_dbf1
                  or.b     d1,(a1)        ;schwarzen Punkt setzen
vl_dbf1:          adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline11
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;; EOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vline2:           cmpi.w   #$aaaa,d6
                  beq.s    vline8
                  cmpi.w   #$5555,d6
                  beq.s    vline9


vline12:          rol.w    #1,d6
                  bcc.s    vl_dbf2
                  eor.b    d1,(a1)        ;schwarzen Punkt setzen
vl_dbf2:          adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline12
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;; REPLACE ;;;;;;;;;;;;;;;;;;;;;;;;;;
vline4:           and.b    d2,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline4
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;; OR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vline5:           not.w    d6
;;;;;;;;;;;;;;;;;;;;;;;;;; NOT OR ;;;;;;;;;;;;;;;;;;;;;;;;;;
vline7:           rol.w    #1,d6
                  bcs.s    vline_black7
                  and.b    d2,(a1)        ;weissen Punkt setzen
vline_black7:     adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline7
                  rts




vline9:           adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vline8

                  rts
;Schnelle Routinen fuer GROW-SHRINK-BOXEN
vline8_tt:        lsr.w    #1,d3
vline_loop8_tt:   eor.b    d1,(a1)
                  adda.w   d5,a1

                  dbra     d3,vline_loop8_tt
                  rts
;Schnelle Routinen fuer GROW-SHRINK-BOXEN
vline8:           add.w    d5,d5
                  move.w   cpu020(pc),d0     ;Prozessor mit Cache ?
                  bne.s    vline8_tt
                  move.w   d3,d2
                  lsr.w    #5,d3
                  not.w    d2
                  andi.w   #30,d2
                  add.w    d2,d2
                  jmp      vline_loop8(pc,d2.w)
vline_loop8:      REPT 16
                  eor.b    d1,(a1)
                  adda.w   d5,a1
                  ENDM
                  dbra     d3,vline_loop8
                  rts

vline10_tt:       or.b     d1,(a1)
                  adda.w   d5,a1
                  dbra     d3,vline10_tt
                  rts

vline10:          move.w   cpu020(pc),d0     ;Prozessor mit Cache ?
                  bne.s    vline10_tt
                  move.w   d3,d2
                  lsr.w    #5,d3
                  not.w    d2
                  and.w    #31,d2
                  add.w    d2,d2
                  add.w    d2,d2
                  jmp      vline_loop10(pc,d2.w)
vline_loop10:     REPT 32
                  or.b     d1,(a1)
                  adda.w   d5,a1
                  ENDM
                  dbra     d3,vline_loop10
                  rts

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

;Startadresse berechnen
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok7:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  move.w   d0,d2
                  asr.w    #3,d2
                  adda.w   d2,a1          ;Startadresse

;Masken erzeugen
                  not.w    d0
                  and.w    #7,d0
                  moveq    #0,d1
                  bset     d0,d1          ;Punktmaske
                  move.b   d1,d2
                  not.b    d2             ;Hintergrundmaske
;Sprungadresse heraussuchen
                  add.w    d7,d7
                  add.w    l_color(a6),d7
                  add.w    d7,d7
                  move.w   vline_tab(pc,d7.w),d7
                  jmp      vline_tab(pc,d7.w)

vline_tab:        DC.W vline4-vline_tab
                  DC.W vline0-vline_tab
                  DC.W vline5-vline_tab
                  DC.W vline1-vline_tab
                  DC.W vline2-vline_tab
                  DC.W vline2-vline_tab
                  DC.W vline7-vline_tab
                  DC.W vline3-vline_tab

                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'schraege Linie'

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
relok8:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  move.w   bitmap_width(a6),d4 ;Off-Screen-Bitmap?
                  beq.s    line_laddr
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1),d3        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   d4,d5          ;Bytes pro Zeile
line_laddr:       move.w   d5,d4
                  muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse
                  moveq    #$fffffff0,d4
                  and.w    d0,d4
                  asr.w    #3,d4
                  adda.w   d4,a1          ;Startadresse

                  moveq    #$0f,d4
                  and.w    d0,d4          ;Shifts der Maske

                  sub.w    d0,d2          ;dx
                  bmi.s    line_exit
                  sub.w    d1,d3          ;dy
                  bpl.s    line_mode      ;negativ?

                  neg.w    d3
                  neg.w    d5             ;vertikale Schrittrichtung aendern

line_mode:        add.w    d7,d7
                  add.w    l_color(a6),d7

                  btst     d7,#%1010      ;REPLACE oder TRANSPARENT?
                  beq.s    line_angle

                  cmpi.w   #$ffff,d6      ;durchgehendes Muster?
                  bne.s    line_angle

                  moveq    #8,d7          ;schnelle schwarze Linie ziehen

line_angle:       cmp.w    d3,d2          ;Winkel > 44 degree ?
                  blt.s    line_angle45

                  move.w   d4,d0
                  move.w   #$8000,d4
                  lsr.w    d0,d4          ;Punktmaske

                  move.w   d2,d0
                  add.w    l_lastpix(a6),d0 ;Punktezaehler
                  bmi.s    line_exit

                  move.w   d3,d1
                  add.w    d1,d1          ;xa = 2dy
                  neg.w    d2
                  move.w   d2,d3          ;e  = -dx
                  add.w    d2,d2          ;ya = -2dx

                  add.w    d7,d7
                  move.w   line_tab(pc,d7.w),d7 ;Sprungadresse
                  jmp      line_tab(pc,d7.w) ;Linie zeichnen
line_exit:        rts

line_tab:         DC.W line_replace_w-line_tab ;REPLACE, Weiss
                  DC.W line_replace_b-line_tab ;REPLACE, Schwarz
                  DC.W line_trans_w-line_tab ;TRANSPARENT, Weiss
                  DC.W line_trans_b-line_tab ;TRANSPARENT, Schwarz
                  DC.W line_eor-line_tab  ;EOR
                  DC.W line_eor-line_tab  ;EOR
                  DC.W line_rtrans_w-line_tab ;REV. TRANS, Weiss
                  DC.W line_rtrans_b-line_tab ;REV. TRANS, Schwarz
                  DC.W line_black-line_tab ;REPLACE, Schwarz durchgehend

line_angle45:     move.w   d3,d0
                  add.w    l_lastpix(a6),d0 ;Punktezaehler
                  bmi.s    line_exit

                  neg.w    d3             ;e  = -dy
                  move.w   d3,d1
                  add.w    d1,d1          ;xa = -2dy
                  add.w    d2,d2          ;ya = 2dx

                  rol.w    d4,d6          ;rotierter Linienstil

                  move.l   a2,-(sp)
                  movea.w  d7,a2
                  move.w   #$8000,d7
                  lsr.w    d4,d7          ;schwarze Punktmaske
                  move.w   d7,d4
                  not.w    d4             ;weisse Punktmaske
                  adda.w   a2,a2
                  movea.w  line_tab45(pc,a2.w),a2
                  jsr      line_tab45(pc,a2.w) ;Linie zeichnen
                  movea.l  (sp)+,a2
                  rts

line_tab45:
                  DC.W line_replace_w45-line_tab45 ;REPLACE, Weiss
                  DC.W line_replace_b45-line_tab45 ;REPLACE, Schwarz
                  DC.W line_trans_w45-line_tab45 ;TRANSPARENT, Weiss
                  DC.W line_trans_b45-line_tab45 ;TRANSPARENT, Schwarz
                  DC.W line_eor_45-line_tab45 ;EOR
                  DC.W line_eor_45-line_tab45 ;EOR
                  DC.W line_rtrans_w45-line_tab45 ;REV. TRANS, Weiss
                  DC.W line_rtrans_b45-line_tab45 ;REV. TRANS, Schwarz
                  DC.W line_black45-line_tab45 ;REPLACE, Schwarz durchgehend

line_replace_w:   moveq    #0,d6          ;weisses Linienmuster
                  bra.s    line_replace_b

line_rep_ystep:   add.w    d2,d3          ;e + ya; vertikaler Schritt
                  and.w    d7,(a1)
                  not.w    d7
                  and.w    d6,d7
                  or.w     d7,(a1)        ;Linienteilstueck ausgeben
                  adda.w   d5,a1          ;naechste Zeile
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_replace_b ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_rep_exit
line_replace_b:   moveq    #$ffffffff,d7  ;neue Maske
line_rep_loop:    eor.w    d4,d7          ;Punkt in der Maske loeschen
                  add.w    d1,d3          ;e + xa
                  bpl.s    line_rep_ystep ;e > 0; vertikaler Schritt?
                  ror.w    #1,d4          ;naechster Punkt
                  dbcs     d0,line_rep_loop
                  and.w    d7,(a1)
                  not.w    d7
                  and.w    d6,d7
                  or.w     d7,(a1)+       ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_replace_b
line_rep_exit:    rts

line_rtrans_b:    not.w    d6
                  bra.s    line_trans_b

line_tr_ystep:    add.w    d2,d3          ;e + ya; vertikaler Schritt
                  and.w    d6,d7
                  or.w     d7,(a1)        ;Linienteilstueck ausgeben
                  adda.w   d5,a1          ;naechste Zeile
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_trans_b ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_trans_exit
line_trans_b:     moveq    #0,d7          ;neue Maske
line_trans_loop:  or.w     d4,d7          ;Punkt in der Maske setzen
                  add.w    d1,d3          ;e + xa
                  bpl.s    line_tr_ystep  ;e > 0; vertikaler Schritt?
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_trans_loop
                  and.w    d6,d7
                  or.w     d7,(a1)+       ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_trans_b
line_trans_exit:  rts

line_eor_ystep:   add.w    d2,d3          ;e + ya; vertikaler Schritt
                  and.w    d6,d7
                  eor.w    d7,(a1)        ;Linienteilstueck ausgeben
                  adda.w   d5,a1          ;naechste Zeile
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_eor    ;Wortgrenze ueberschritten
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_eor_exit
line_eor:         moveq    #0,d7          ;neue Maske
line_eor_loop:    or.w     d4,d7          ;Punkt in der Maske setzen
                  add.w    d1,d3          ;e + xa
                  bpl.s    line_eor_ystep ;e > 0; vertikaler Schritt?
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_eor_loop
                  and.w    d6,d7
                  eor.w    d7,(a1)+       ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_eor
line_eor_exit:    rts

line_trans_w:     not.w    d6
                  bra.s    line_rtrans_w

line_rtr_ystep:   add.w    d2,d3          ;e + ya; vertikaler Schritt
                  or.w     d6,d7
                  and.w    d7,(a1)        ;Linienteilstueck ausgeben
                  adda.w   d5,a1          ;naechste Zeile
                  ror.w    #1,d4          ;naechster Punkt fuer die Maske
                  dbcs     d0,line_rtrans_w ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_rtr_exit
line_rtrans_w:    moveq    #$ffffffff,d7  ;neue Maske
line_rtr_loop:    eor.w    d4,d7          ;Punkt in der Maske setzen
                  add.w    d1,d3          ;e + xa
                  bpl.s    line_rtr_ystep ;e > 0; vertikaler Schritt?
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_rtr_loop
                  or.w     d6,d7
                  and.w    d7,(a1)+       ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_rtrans_w
line_rtr_exit:    rts

line_blk_ystep:   add.w    d2,d3          ;e + ya; vertikaler Schritt
                  or.w     d7,(a1)        ;Linienteilstueck ausgeben
                  adda.w   d5,a1          ;naechste Zeile
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_black  ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_blk_exit
line_black:       moveq    #0,d7          ;neue Maske
line_blk_loop:    or.w     d4,d7          ;Punkt in der Maske setzen
                  add.w    d1,d3          ;e + xa
                  bpl.s    line_blk_ystep ;e > 0; vertikaler Schritt?
                  ror.w    #1,d4          ;neue Punktmaske
                  dbcs     d0,line_blk_loop
                  or.w     d7,(a1)+       ;Linienteilstueck ausgeben
                  subq.w   #1,d0
                  bpl.s    line_black
line_blk_exit:    rts

line_replace_w45: moveq    #0,d6
                  bra.s    line_replace_b45

line_rep_xstep:   add.w    d1,d3          ;e + xa; horizontaler Schritt
                  ror.w    #1,d4          ;neue weisse Punktmaske
                  ror.w    #1,d7          ;neue schwarze Punktmaske
                  dbcs     d0,line_replace_b45 ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_rep_exit45
line_replace_b45: rol.w    #1,d6          ;Punkt setzen?
                  bcc.s    line_rep_w45
line_rep_blk45:   or.w     d7,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + ya
                  bpl.s    line_rep_xstep ;e > 0; horizontaler Schritt?
                  dbra     d0,line_replace_b45
line_rep_exit45:  rts
line_rep_wtst45:  rol.w    #1,d6          ;Punkt loeschen?
                  bcs.s    line_rep_blk45
line_rep_w45:     and.w    d4,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + ya
                  bpl.s    line_rep_xstep ;e > 0; horizontaler Schritt?
                  dbra     d0,line_rep_wtst45
                  rts

line_rtrans_b45:  not.w    d6             ;Linienstil invertieren
                  bra.s    line_trans_b45

line_tr_xstep:    add.w    d1,d3          ;e + xa; horizontaler Schritt
                  ror.w    #1,d7          ;neue Punktmaske
                  dbcs     d0,line_trans_b45 ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_tr_exit45
line_trans_b45:   rol.w    #1,d6          ;Punkt setzen?
                  bcc.s    line_tr_next45
                  or.w     d7,(a1)        ;schwarzen Punkt setzen
line_tr_next45:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + ya
                  bpl.s    line_tr_xstep  ;e > 0; horizontaler Schritt?
                  dbra     d0,line_trans_b45
line_tr_exit45:   rts

line_eor_xstep:   add.w    d1,d3          ;e + xa; horizontaler Schritt
                  ror.w    #1,d7          ;neue Punktmaske
                  dbcs     d0,line_eor_45 ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_eor_exit45
line_eor_45:      rol.w    #1,d6          ;Punkt setzen?
                  bcc.s    line_eor_next45
                  eor.w    d7,(a1)        ;schwarzen Punkt setzen
line_eor_next45:  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + ya
                  bpl.s    line_eor_xstep ;e > 0; horizontaler Schritt?
                  dbra     d0,line_eor_45
line_eor_exit45:  rts

line_trans_w45:   not.w    d6
                  bra.s    line_rtrans_w45

line_rtr_xstep:   add.w    d1,d3          ;e + xa; horizontaler Schritt
                  ror.w    #1,d4          ;neue weisse Punktmaske
                  dbcc     d0,line_rtrans_w45 ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_rtr_exit45
line_rtrans_w45:  rol.w    #1,d6          ;Punkt loeschen?
                  bcs.s    line_rtr_next45
                  and.w    d4,(a1)
line_rtr_next45:  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + ya
                  bpl.s    line_rtr_xstep ;e > 0; horizontaler Schritt?
                  dbra     d0,line_rtrans_w45
line_rtr_exit45:  rts

line_blk_xstep:   add.w    d1,d3          ;e + xa; horizontaler Schritt
                  ror.w    #1,d7          ;neue Punktmaske
                  dbcs     d0,line_black45 ;Wortgrenze ueberschritten?
                  addq.l   #2,a1          ;naechstes Wort
                  subq.w   #1,d0
                  bmi.s    line_blk_exit45
line_black45:     or.w     d7,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + xa
                  bpl.s    line_blk_xstep ;e > 0; horizontaler Schritt?
                  dbra     d0,line_black45
line_blk_exit45:  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'allgemeine Textausgabe'

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
relok9:
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zeile
                  move.w   bitmap_width(a6),d6 ;Off-Screen-Bitmap
                  beq.s    textblt_smode
                  sub.w    bitmap_off_x(a6),d2  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d3  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  movea.w  d6,a3          ;Bytes pro Zeile
textblt_smode:    move.w   wr_mode(a6),d7 ;Verknuepfungsmodus
                  add.w    d7,d7
                  add.w    t_color(a6),d7 ;Textfarbe
                  beq      textblt_box
                  subq.w   #1,d7
                  lsl.w    #3,d7          ;(Verknuepfung - 1) * 8

                  move.w   a2,d6          ;Bytes pro Quellzeile
                  mulu     d6,d1          ;* y-Quelle
                  adda.l   d1,a0          ;Zeilenadresse
                  move.w   d0,d1          ;xs1
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a0          ;Quelladresse

                  move.w   a3,d1          ;Bytes pro Zielzeile
                  mulu     d3,d1          ;* y-Ziel
                  adda.l   d1,a1          ;Zeilenadresse
                  move.w   d2,d1          ;xd1
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a1          ;Zieladresse

                  movea.w  d7,a5          ;(Verknuepfung -1) * 8

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

                  lea      textblt_tab(pc),a4

                  tst.w    d0             ;keine Shifts?
                  beq.s    textblt_jmp
                  blt.s    textblt_right

textblt_left:     lea      textblt_l_tab(pc),a4


                  tst.w    d1             ;nur ein Zielwort?
                  bne.s    textblt_l_end
                  tst.w    d4             ;nur ein Quellwort?
                  bne.s    textblt_l_end
                  moveq    #10,d6         ;dann nur ein Startwort einlesen
                  bra.s    textblt_jmp

textblt_l_end:    moveq    #4,d6          ;zwei Startwoerter einlesen
                  subq.w   #2,a2          ;daher 2 zusaetzliche Quellbytes
                  tst.w    d4             ;mehr Quell- als Zielworte?
                  bgt.s    textblt_l_shifts
                  moveq    #2,d7          ;bei gleicher Wortanzahl kein Endwort einlesen
textblt_l_shifts: cmp.w    #8,d0          ;nicht mehr als 8 Verschiebungen nach links?
                  ble.s    textblt_jmp

                  lea      textblt_r_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebung nach rechts
                  bra.s    textblt_jmp

textblt_right:    lea      textblt_r_tab(pc),a4
                  neg.w    d0             ;Verschiebungen nach rechts
                  moveq    #8,d6          ;nur ein Startwort einlesen
                  tst.w    d4
                  bpl.s    textblt_r_shifts
                  moveq    #2,d7          ;kein Endwort einlesen, wenn mehr Zielbytes vorhanden sind
textblt_r_shifts: cmpi.w   #8,d0          ;nicht mehr als 8 Verschiebungen nach rechts?
                  ble.s    textblt_jmp

                  lea      textblt_l_tab(pc),a4
                  subq.w   #1,d0
                  eori.w   #15,d0         ;Verschiebung nach links

textblt_jmp:      adda.l   a4,a5          ;Zeiger in Abstandstabelle

                  move.w   (a5)+,d4       ;Abstand zur BitBlt-Funktion
                  add.w    d4,d6          ;Offset fuer den ersten Sprung
                  add.w    (a5)+,d7       ;Offset fuer den zweiten Sprung

                  tst.w    d1             ;nur ein Wort verschieben ?
                  bne.s    textblt_offsets

                  move.w   (a5),d7        ;kein Endwort lesen und schreiben

                  and.w    d3,d2          ;Start- und Endmaske
                  moveq    #0,d3
                  moveq    #0,d1          ;Wortzaehler
                  subq.w   #2,a2
                  subq.w   #2,a3

textblt_offsets:  subq.w   #2,d1
                  lea      textblt_tab(pc),a4
                  lea      textblt_tab(pc),a5
                  adda.w   d6,a4
                  adda.w   d7,a5

                  jmp      textblt_tab(pc,d4.w)

textblt_tab:      DC.W blt_inc_3-textblt_tab,0,0,0
                  DC.W blt_inc_4-textblt_tab,blt_inc_last_4-textblt_tab,blt_inc_next_4-textblt_tab,0
                  DC.W blt_inc_7-textblt_tab,blt_inc_last_7-textblt_tab,blt_inc_next_7-textblt_tab,0
                  DC.W blt_inc_6-textblt_tab,blt_inc_last_6-textblt_tab,blt_inc_next_6-textblt_tab,0
                  DC.W blt_inc_6-textblt_tab,blt_inc_last_6-textblt_tab,blt_inc_next_6-textblt_tab,0
                  DC.W blt_inc_1-textblt_tab,blt_inc_last_1-textblt_tab,blt_inc_next_1-textblt_tab,0
                  DC.W blt_inc_13-textblt_tab,blt_inc_last_13-textblt_tab,blt_inc_next_13-textblt_tab,0

textblt_l_tab:    DC.W blt_inc_l3-textblt_tab,blt_inc_last_l3-textblt_tab,blt_inc_next_l3-textblt_tab,0
                  DC.W blt_inc_l4-textblt_tab,blt_inc_last_l4-textblt_tab,blt_inc_next_l4-textblt_tab,0
                  DC.W blt_inc_l7-textblt_tab,blt_inc_last_l7-textblt_tab,blt_inc_next_l7-textblt_tab,0
                  DC.W blt_inc_l6-textblt_tab,blt_inc_last_l6-textblt_tab,blt_inc_next_l6-textblt_tab,0
                  DC.W blt_inc_l6-textblt_tab,blt_inc_last_l6-textblt_tab,blt_inc_next_l6-textblt_tab,0
                  DC.W blt_inc_l1-textblt_tab,blt_inc_last_l1-textblt_tab,blt_inc_next_l1-textblt_tab,0
                  DC.W blt_inc_l13-textblt_tab,blt_inc_last_l13-textblt_tab,blt_inc_next_l13-textblt_tab,0

textblt_r_tab:    DC.W blt_inc_r3-textblt_tab,blt_inc_last_r3-textblt_tab,blt_inc_next_r3-textblt_tab,0
                  DC.W blt_inc_r4-textblt_tab,blt_inc_last_r4-textblt_tab,blt_inc_next_r4-textblt_tab,0
                  DC.W blt_inc_r7-textblt_tab,blt_inc_last_r7-textblt_tab,blt_inc_next_r7-textblt_tab,0
                  DC.W blt_inc_r6-textblt_tab,blt_inc_last_r6-textblt_tab,blt_inc_next_r6-textblt_tab,0
                  DC.W blt_inc_r6-textblt_tab,blt_inc_last_r6-textblt_tab,blt_inc_next_r6-textblt_tab,0
                  DC.W blt_inc_r1-textblt_tab,blt_inc_last_r1-textblt_tab,blt_inc_next_r1-textblt_tab,0
                  DC.W blt_inc_r13-textblt_tab,blt_inc_last_r13-textblt_tab,blt_inc_next_r13-textblt_tab,0

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
scanline:         move.l   d5,-(sp)

                  move.w   d0,d3          ;X-Start merken
                  swap     d3
                  move.w   d0,d3          ;wird 2 mal gebraucht

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    scanline_screen
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a3 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    scanline_laddr
scanline_screen:  movea.l  v_bas_ad.w,a3  ;Adresse des Bildschirms
relok10:
                  muls     BYTES_LIN.w,d1
scanline_laddr:   adda.l   d1,a3          ;Zeilenadresse
                  move.w   d0,d4          ;x1
                  asr.w    #4,d0          ;Bytes pro Zeile
                  add.w    d0,d0
                  adda.w   d0,a3          ;Bildschirmanfang+Y-Zeile+ Zeilenoffset
                  not.w    d4

                  andi.w   #15,d4         ;X-Bit
                  clr.w    d0
                  bset     d4,d0          ;Maske
                  movea.l  a3,a4          ;Pos. des Start-Words sichern

                  move.w   (a3),d1
                  and.w    d0,d1
                  sne      d4             ;Farbe des Startp. 0:weiss, $ff:schwarz
                  ext.w    d4
; Startwort
                  cmp.w    d2,d3
                  bgt.s    try_l
                  move.w   d3,d0          ;X-Start
                  andi.w   #15,d0         ;X-Bits
                  move.w   (a3)+,d1
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
rs_wd:            move.w   (a3)+,d1       ;naechstes Wort
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
ls_wd:            move.w   -(a3),d1
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

                  move.w   (a5),d0
                  and.w    #$01,d4        ;nur s/w zulassen !!
                  cmp.w    v_1e+2(a5),d4
                  beq.s    lblE0
                  eori.w   #1,d0
lblE0:            move.l   (sp)+,d5
                  move.w   bitmap_off_x(a6),d1
                  add.w    d1,(a0)        ;Verschiebung des Ursprung bei den Ausgabe-
                  add.w    d1,(a1)        ;x-Koordinaten korrigieren
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  DATA

;schwarzes Fuellmuster
fill1:            DC.L -1,-1,-1,-1,-1,-1,-1,-1

;Die Relokationsinformation
relokation:
;Reloziert am: Sun Jan 21 20:38:22 1996

				dc.w relok0-start+2
				dc.w relok1-relok0
				dc.w relok2-relok1
				dc.w relok3-relok2
				dc.w relok4-relok3
				dc.w relok5-relok4
				dc.w relok6-relok5
				dc.w relok7-relok6
				dc.w relok8-relok7
				dc.w relok9-relok8
				dc.w relok10-relok9
				dc.w 0 /* end of data */

                  BSS

nvdi_struct:      DS.L 1
cpu020:           DS.W 1                  ;Prozessorflag

                  END
