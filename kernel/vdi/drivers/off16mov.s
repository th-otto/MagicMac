;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************;
;*                                                                            *;
;*                 True Color-Offscreen-Treiber fuer NVDI 4.1                 *;
;*                                                                            *;
;******************************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tabulatorgroesse:  3
;Kommentare:                                                ;ab Spalte 60


;Labels und Konstanten
                  ;Header'

ENABLE_040        EQU   0                                   ;1: Funktionen fuer 040er ansprechen

VERSION           EQU $0413

INCLUDE "..\include\linea.inc"
INCLUDE "..\include\tos.inc"
INCLUDE "..\include\seedfill.inc"

INCLUDE "..\include\nvdi_wk.inc"
INCLUDE "..\include\vdi.inc"

INCLUDE "..\include\driver.inc"

PATTERN_LENGTH    EQU (32*32)             ;Fuellmusterlaenge bei 32 Ebenen

PAL_LENGTH        EQU 1024                ;Laenge der Pseudo-Palette

c_palette         EQU f_saddr+PATTERN_LENGTH ;Startadresse der Pseudo-Palette

m2                EQU 0                   ;Offset mit 2 multiplizieren
m4                EQU 1                   ;Offset mit 4 multiplizieren
m6                EQU 2                   ;Offset mit 6 multiplizieren

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;NVDI-Treiber initialisieren'
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
organisation:     DC.L  16777216          ;Farben
                  DC.W  32                ;Planes
                  DC.W  2                 ;Pixelformat
                  DC.W  128+1             ;Bitverteilung
                  DC.W  0,0,0             ;reserviert
header_end:


continue:         rts

init:             movem.l  d0-d2/a0-a2,-(sp)

                  move.l   a0,nvdi_struct
                  bsr      make_relo      ;Treiber relozieren

                  movea.l  nvdi_struct(pc),a0

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
                  moveq    #8,d0          ;8 Bit Rot-Anteil
                  moveq    #8,d1          ;8 Bit Gruen-Anteil
                  moveq    #8,d2          ;8 Bit Blau-Anteil
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
                     
                  move.w   #256,26-90(a0) ;work_out[13]: Anzahl der Farbstifte
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
                  move.w   #32,8-90(a0)      ;work_out[4]: Anzahl der Farbebenen
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
                  move.w   bitmap_flags(a6),(a0)+  ;[14] Bitorganisation
                  move.w   2(a1),(a0)+    ;[15] unbenutzt

                  moveq    #111,d0
                  lea      scrninfo_mot(pc),a1  ;Daten fuers Motorola-Format
                  btst     #7,bitmap_flags+1(a6)
                  beq.s    scrninfo_loop
                  lea      scrninfo_int(pc),a1  ;Daten fuers Intel-Format
scrninfo_loop:    move.w   (a1)+,(a0)+
                  dbf      d0,scrninfo_loop

                  move.w   #143,d0
scrninfo_clr:     clr.w    (a0)+
                  dbf      d0,scrninfo_clr

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

scrninfo_mot:     DC.W 16,17,18,19,20,21,22,23 ;Bits der Rot-Intensitaet
                  DCB.W 8,-1
                  DC.W 8,9,10,11,12,13,14,15 ;Bits der Gruen-Intensitaet
                  DCB.W 8,-1
                  DC.W 0,1,2,3,4,5,6,7    ;Bits der Blau-Intensitaet
                  DCB.W 8,-1
                  DC.W  24,25,26,27,28,29,30,31 ;Bits fuer den Alpha-Channel
                  DCB.W 8,-1              
                  DCB.W 16,-1             ;keine Bits fuer Genlock
                  DCB.W 32,-1             ;unbenutzte Bits

scrninfo_int:     DC.W  8,9,10,11,12,13,14,15 ;Bits der Rot-Intensitaet
                  DCB.W 8,-1
                  DC.W  16,17,18,19,20,21,22,23 ;Bits der Gruen-Intensitaet
                  DCB.W 8,-1
                  DC.W  24,25,26,27,28,29,30,31    ;Bits der Blau-Intensitaet
                  DCB.W 8,-1
                  DC.W  0,1,2,3,4,5,6,7   ;Bits fuer den Alpha-Channel
                  DCB.W 8,-1              
                  DCB.W 16,-1             ;keine Bits fuer Genlock
                  DCB.W 32,-1             ;unbenutzte Bits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Farbpalette'

palette_data:
DC.l $00ffffff, $00f20000, $0000e600, $00ffff00, $000000f2, $00e63399, $001acbbb, $00d9d9d9
DC.l $00808080, $00800000, $00008000, $00b6a239, $00000080, $00800080, $00008080, $001a1a1a
DC.l $00000033, $00000066, $00000099, $000000cc, $000000ff, $00003300, $00003333, $00003366
DC.l $00003399, $000033cc, $000033ff, $00006600, $00006633, $00006666, $00006699, $000066cc
DC.l $000066ff, $00009900, $00009933, $00009966, $00009999, $000099cc, $000099ff, $0000cc00
DC.l $0000cc33, $0000cc66, $0000cc99, $0000cccc, $0000ccff, $0000ff00, $0000ff33, $0000ff66
DC.l $0000ff99, $0000ffcc, $0000ffff, $00330000, $00330033, $00330066, $00330099, $003300cc
DC.l $003300ff, $00333300, $00333333, $00333366, $000000c0, $003333cc, $003333ff, $00336600
DC.l $00336633, $00336666, $00336699, $003366cc, $003366ff, $00339900, $00339933, $00339966
DC.l $00339999, $003399cc, $003399ff, $0033cc00, $0033cc33, $0033cc66, $0033cc99, $0033cccc
DC.l $0033ccff, $0033ff00, $0033ff33, $0033ff66, $0033ff99, $0033ffcc, $0033ffff, $00660000
DC.l $00660033, $00660066, $00660099, $006600cc, $006600ff, $00663300, $00663333, $00663366
DC.l $00663399, $006633cc, $006633ff, $00666600, $00666633, $00666666, $00666699, $006666cc
DC.l $006666ff, $00669900, $00669933, $00669966, $00669999, $006699cc, $006699ff, $0066cc00
DC.l $0066cc33, $0066cc66, $0066cc99, $0066cccc, $0066ccff, $0066ff00, $0066ff33, $0066ff66
DC.l $0066ff99, $0066ffcc, $0066ffff, $00990000, $00990033, $00990066, $00990099, $009900cc
DC.l $009900ff, $00993300, $00993333, $00993366, $00993399, $009933cc, $009933ff, $00996600
DC.l $00996633, $00996666, $00996699, $009966cc, $009966ff, $00999900, $00999933, $00999966
DC.l $00999999, $009999cc, $009999ff, $0099cc00, $0099cc33, $0099cc66, $0099cc99, $0099cccc
DC.l $0099ccff, $0099ff00, $0099ff33, $0099ff66, $0099ff99, $0099ffcc, $0099ffff, $00cc0000
DC.l $00cc0033, $00cc0066, $00cc0099, $00cc00cc, $00cc00ff, $00cc3300, $00cc3333, $00cc3366
DC.l $00cc3399, $00cc33cc, $00cc33ff, $00cc6600, $00cc6633, $00cc6666, $00cc6699, $00cc66cc
DC.l $00cc66ff, $00cc9900, $00cc9933, $00cc9966, $00cc9999, $00cc99cc, $00cc99ff, $00cccc00
DC.l $00cccc33, $00cccc66, $00cccc99, $00cccccc, $00ccccff, $00ccff00, $00ccff33, $00ccff66
DC.l $00ccff99, $00ccffcc, $00ccffff, $00ff0000, $00ff0033, $00ff0066, $00ff0099, $00ff00cc
DC.l $00ff00ff, $00ff3300, $00ff3333, $00ff3366, $00ff3399, $00ff33cc, $00ff33ff, $00ff6600
DC.l $00ff6633, $00ff6666, $00ff6699, $00ff66cc, $00ff66ff, $00ff9900, $00ff9933, $00ff9966
DC.l $00ff9999, $00ff99cc, $00ff99ff, $00ffcc00, $00ffcc33, $00ffcc66, $00ffcc99, $00ffcccc
DC.l $00ffccff, $00ffff00, $00ffff33, $00ffff66, $00ffff99, $00ffffcc, $00f20000, $00e60000
DC.l $00c00000, $00b30000, $00800000, $004d0000, $001a0000, $0000f200, $0000e600, $0000c000
DC.l $0000b300, $00008000, $00004d00, $00001a00, $0000001a, $0000004d, $00000080, $000000b3
DC.l $00333399, $000000e6, $00f2f2f2, $00e6e6e6, $00c0c0c0, $00b3b3b3, $004d4d4d, $00000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Relozierungsroutine'
make_relo:        movem.l  d0-d2/a0-a2,-(sp)
                  DC.W $a000
                  sub.w    #CMP_BASE,d0   ;Differenz der Line-A-Adressen

                  beq.s    relo_exit      ;keine Relokation noetig ?
                  lea      start(pc),a0   ;Start des Textsegments
                  lea      relokation(pc),a1 ;Relokationsinformation

relo_loop:        move.w   (a1)+,d1       ;Adress-Offset
                  beq.s    relo_exit
                  adda.w   d1,a0
                  add.w    d0,(a0)        ;relozieren
                  bra.s    relo_loop
relo_exit:        movem.l  (sp)+,d0-d2/a0-a2
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Initialisierung'

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
build_exp_loop:   clr.l    (a0)+
                  add.b    d1,d1          ;Bit gesetzt?
                  bcs.s    build_exp_next
                  not.l    -4(a0)
build_exp_next:   dbra     d2,build_exp_loop
                  addq.w   #1,d0
                  cmp.w    #256,d0        ;alle 256 Bitmuster durch?
                  blt.s    build_exp_bloop
                  movem.l  (sp)+,d0-d2/a0-a1
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
                  ;v_contourfill'

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
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a3 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    scanline_laddr
scanline_screen:  movea.l  v_bas_ad.w,a3  ;Adresse des Bildschirms
relok0:
                  muls     BYTES_LIN.w,d1 ;Y1
scanline_laddr:   adda.l   d1,a3
                  asl.w    #2,d0
                  adda.w   d0,a3          ;Bildschirmanfang+Y-Zeile+ Zeilenoffset
                  asr.w    #2,d0
                  movea.l  a3,a4          ;Pos. des Start-Words sichern

                  move.l   (a3),d4        ;Farbe des Startpunkts sichern

; Startwort
                  cmp.w    d2,d3          ;innerhalb der Clippinggrenzen?
                  bgt.s    try_l

                  addq.l   #4,a3          ;Startpunkt ueberspringen

r_word:           cmp.l    (a3)+,d4
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


l_word:           cmp.l    -(a3),d4
                  bne.s    fnd_limits
                  subq.w   #1,d3
                  cmp.w    d2,d3          ;noch innerhalb Cliprect ?
                  bgt.s    l_word

e_limits:         move.w   d2,d3          ;X=clip_xmin

fnd_limits:       move.w   d3,(a0)        ;linke Begrenzung

                  move.w   (a5),d0

                  cmp.l    v_1e(a5),d4
                  beq.s    lblE0
                  eori.w   #1,d0
lblE0:            move.w   bitmap_off_x(a6),d1
                  add.w    d1,(a0)        ;Verschiebung des Ursprung bei den Ausgabe-
                  add.w    d1,(a1)        ;x-Koordinaten korrigieren
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ; '1. Kontrollfunktionen'

;WK-Tabelle intialisieren
;Eingaben
;a6.l Workstation
;Ausgaben
;Die Workstation wird initialisert
wk_init:          movem.l  d0-d1/a0-a2,-(sp)

                  move.w   #31,r_planes(a6)  ;Anzahl der Bildebenen -1
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
                  add.w    d0,d0
                  btst     #7,bitmap_flags+1(a6)   ;Intel-Format?
                  beq.s    set_palette_mot         ;nein

                  move.b   3(a0,d0.w),(a1)+
                  move.b   2(a0,d0.w),(a1)+
                  move.b   1(a0,d0.w),(a1)+
                  move.b   0(a0,d0.w),(a1)+
                  bra.s    set_palette_next
                  
set_palette_mot:  move.l   0(a0,d0.w),(a1)+
set_palette_next: dbra     d1,set_palette

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
                  add.w    d3,d3
                  
                  btst     #7,bitmap_flags+1(a6)   ;Intel-Format, umgekehrte Bytereihenfolge?
                  beq.s    set_col_rgb_mot

                  lea      3(a1,d3),a1
                  lea      rgb_in_tab(pc),a0
                  move.b   0(a0,d0.w),-(a1)
                  lea      1002(a0),a0    ;Gruen-Tabelle
                  move.b   0(a0,d1.w),-(a1)
                  lea      1002(a0),a0    ;Blau-Tabelle
                  move.b   0(a0,d2.w),-(a1)
                  rts

set_col_rgb_mot:  lea      1(a1,d3),a1

                  lea      rgb_in_tab(pc),a0
                  move.b   0(a0,d0.w),(a1)+
                  lea      1002(a0),a0    ;Gruen-Tabelle
                  move.b   0(a0,d1.w),(a1)+
                  lea      1002(a0),a0    ;Blau-Tabelle
                  move.b   0(a0,d2.w),(a1)+
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
get_color_rgb:    lea      c_palette(a6),a0
                  add.w    d0,d0
                  add.w    d0,d0
                  
                  btst     #7,bitmap_flags+1(a6)   ;Intel-Format, umgekehrte Bytereihenfolge?
                  beq.s    get_col_rgb_mot

                  lea      3(a0,d0.w),a0
                  lea      rgb_out_tab(pc),a1
                  moveq    #0,d0
                  move.b   -(a0),d0
                  add.w    d0,d0
                  move.w   0(a1,d0.w),d0  ;Rot-Intensitaet in Promille
                  lea      512(a1),a1
                  moveq    #0,d1
                  move.b   -(a0),d1
                  add.w    d1,d1
                  move.w   0(a1,d1.w),d1  ;Gruen-Intensitaet in Promille
                  lea      512(a1),a1
                  moveq    #0,d2
                  move.b   -(a0),d2
                  add.w    d2,d2
                  move.w   0(a1,d2.w),d2  ;Blau-Intensitaet in Promille
                  rts

get_col_rgb_mot:  lea      1(a0,d0.w),a0
                  lea      rgb_out_tab(pc),a1
                  moveq    #0,d0
                  move.b   (a0)+,d0
                  add.w    d0,d0
                  move.w   0(a1,d0.w),d0  ;Rot-Intensitaet in Promille
                  lea      512(a1),a1
                  moveq    #0,d1
                  move.b   (a0)+,d1
                  add.w    d1,d1
                  move.w   0(a1,d1.w),d1  ;Gruen-Intensitaet in Promille
                  lea      512(a1),a1
                  moveq    #0,d2
                  move.b   (a0)+,d2
                  add.w    d2,d2
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

set_pattern_col:  move.w   #255,d0        ;Pixelzaehler
                  btst     #7,bitmap_flags+1(a6)   ;Intel-Format?
                  bne.s    set_pattern_swap
                  
set_pattern_loop: move.l   (a0)+,(a1)+
                  dbra     d0,set_pattern_loop
                                    
                  moveq    #31,d0         ;Fuellmuster mit 32 Ebenen
                  rts

set_pattern_swap: move.l   d1,-(sp)

set_pat_swp_loop: move.w   (a0)+,d1       ;xr
                  rol.w    #8,d1          ;rx
                  swap     d1
                  move.w   (a0)+,d1       ;rxgb
                  rol.w    #8,d1          ;rxbg
                  swap     d1             ;bgrx
                  move.l   d1,(a1)+
                  dbra     d0,set_pat_swp_loop
                  
                  move.l   (sp)+,d1
                  moveq    #31,d0         ;Fuellmuster mit 32 Ebenen
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
                  add.w    d0,d0
                  adda.w   d0,a0
                  move.l   (a0),d0
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
                  ;4. Rasterfunktionen'

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
                  sub.w    #32-1,d0       ;32 Ebenen?
                  bne.s    vr_trnfm_exit

                  add.w    d2,d2
                  add.w    d2,d2
                  movea.l  vr_tr_tab(pc,d2.w),a2 ;Zeiger auf die Wandlungsroutine

                  cmpa.l   a0,a1          ;Quell- und Zieladresse gleich?
                  bne.s    vr_trnfm_diff

                  move.l   d1,d3
                  addq.l   #1,d3          ;Wortanzahl pro Ebene
                  lsl.l    #6,d3          ;Speicherbedarf des Blocks (Wortanzahl * 2 * 32)
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
                  moveq    #31,d4         ;Anzahl der Ebenen - 1
                  bsr      vr_trnfm_interl ;Block in interleaved Planes wandeln
                  movem.l  (sp)+,d1/a0-a1
vr_trnfm_sdev1:   movea.l  d1,a6
                  move.l   a0,-(sp)
                  lea      64(a0),a0
                  REPT 12                 ;Ebenen 8-31 auf dem Stack sichern
                  move.l   -(a0),-(sp)
                  ENDM
                  lea      -16(a0),a0
                  move.l   a1,-(sp)
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 7-0 ausgeben
                  movea.l  (sp)+,a1
                  addq.l   #1,a1
                  movea.l  sp,a0
                  move.l   a1,-(sp)
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 15-8 ausgeben
                  movea.l  (sp)+,a1
                  lea      16(sp),sp
                  addq.l   #1,a1
                  movea.l  sp,a0
                  move.l   a1,-(sp)
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 23-16 ausgeben
                  movea.l  (sp)+,a1
                  lea      16(sp),sp
                  addq.l   #1,a1
                  movea.l  sp,a0
                  bsr.s    vr_trnfm_sdev2 ;Ebenen 31-24 ausgeben
                  lea      16(sp),sp
                  movea.l  (sp)+,a0
                  lea      64(a0),a0      ;16 Pixel weiter
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sdev1
                  rts
vr_trnfm_sdev2:   moveq    #15,d0
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
                  move.b   d7,(a1)        ;Byte im geraetespezifischen Format ausgeben
                  addq.l   #4,a1          ;4 Bytes weiter
                  swap     d0
                  dbra     d0,vr_trnfm_sdev3
                  rts

vr_trnfm_sstd2:   moveq    #15,d0         ;16 Pixel bearbeiten
vr_trnfm_sstd3:   swap     d0
                  swap     d7
                  move.b   (a0),d7
                  addq.l   #4,a0          ;4 Bytes weiter
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
                  move.w   d7,(a1)+       ;Ebene 0
                  move.w   d6,(a1)+       ;Ebene 1
                  move.w   d5,(a1)+       ;Ebene 2
                  move.w   d4,(a1)+       ;Ebene 3
                  move.w   d3,(a1)+       ;Ebene 4
                  move.w   d2,(a1)+       ;Ebene 5
                  move.w   d1,(a1)+       ;Ebene 6
                  move.w   d0,(a1)+       ;Ebene 7
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
                  lea      64(a0),a0      ;16 Pixel weiter
                  move.l   a0,-(sp)
                  REPT 16
                  move.l   -(a0),-(sp)    ;16 Pixel sichern
                  ENDM
                  bsr.s    vr_trnfm_sstd2 ;Ebenen 0-7 Bearbeiten
                  movea.l  sp,a0
                  addq.l   #1,a0
                  bsr.s    vr_trnfm_sstd2 ;Ebenen 15-8 bearbeiten
                  movea.l  sp,a0
                  addq.l   #2,a0
                  bsr.s    vr_trnfm_sstd2 ;Ebenen 23-16 bearbeiten
                  movea.l  sp,a0
                  addq.l   #3,a0
                  bsr      vr_trnfm_sstd2 ;Ebenen 31-24 bearbeiten
                  lea      64(sp),sp
                  movea.l  (sp)+,a0
                  move.l   a6,d1
                  subq.l   #1,d1
                  bpl.s    vr_trnfm_sstd1
                  movem.l  (sp)+,d4/a0-a1
                  moveq    #31,d0         ;interleaved Planes ins Standardformat wandeln

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
                  bsr.s    vr_trnfm_stand2 ;Ebenen 7-0 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  addq.l   #1,a0          ;Ebenen 15-8
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a1          ;Zeiger auf Ebene 8
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_stand2 ;Ebenen 15-8 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  addq.l   #1,a0          ;Ebenen 23-16
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a1          ;Zeiger auf Ebene 16
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_stand2 ;Ebenen 23-16 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  addq.l   #1,a0          ;Ebenen 31-24
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a1          ;Zeiger auf Ebene 24
vr_trnfm_stand2:  lea      0(a1,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

vr_trnfm_sbloop:  movea.l  d1,a6
                  moveq    #15,d0         ;16 Pixel bearbeiten
vr_trnfm_sloop:   swap     d0
                  swap     d7
                  move.b   (a0),d7
                  addq.l   #4,a0          ;4 Bytes weiter
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
                  bsr.s    vr_trnfm_dev2  ;Ebenen 7-0 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a0          ;Zeiger auf Ebene 8
                  addq.l   #1,a1          ;Ebenen 15-8
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_dev2  ;Ebenen 15-8 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a0          ;Zeiger auf Ebene 16
                  addq.l   #1,a1          ;Ebenen 23-16
                  movem.l  d0-d1/a0-a1,-(sp)
                  bsr.s    vr_trnfm_dev2  ;Ebenen 23-16 transformieren
                  movem.l  (sp)+,d0-d1/a0-a1
                  move.l   d0,d2
                  lsl.l    #3,d2
                  adda.l   d2,a0          ;Zeiger auf Ebene 24
                  addq.l   #1,a1          ;Ebenen 31-24 transformieren

vr_trnfm_dev2:    lea      0(a0,d0.l),a2  ;Zeiger auf Ebene 1
                  lea      0(a2,d0.l),a3  ;Zeiger auf Ebene 2
                  lea      0(a3,d0.l),a4  ;Zeiger auf Ebene 3
                  lsl.l    #2,d0          ;Laenge von vier Ebenen
                  movea.l  d0,a5

vr_trnfm_dbloop:  movea.l  d1,a6
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
                  move.b   d7,(a1)        ;Byte im geraetespezifischen Format ausgeben
                  addq.l   #4,a1          ;4 Bytes ueberspringen
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
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    get_pixel_line
get_pixel_screen: movea.l  v_bas_ad.w,a0
relok1:
                  muls     BYTES_LIN.w,d1
get_pixel_line:   add.l    d1,a0
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a0
                  move.l   (a0),d0
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
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a0
                  muls     bitmap_width(a6),d1
                  bra.s    set_pixel_line
set_pixel_screen: movea.l  v_bas_ad.w,a0
relok2:
                  muls     BYTES_LIN.w,d1
set_pixel_line:   add.l    d1,a0
                  add.w    d0,d0
                  add.w    d0,d0
                  add.w    d0,a0
                  move.l   d2,(a0)
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;horizontale Linie'


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
                  lsl.w    #6,d4
                  adda.w   d4,a0          ;Zeiger auf die Musterzeile

relok3:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
                  
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fline_laddr

                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs

                  move.w   bitmap_width(a6),d4  ;Bytes pro Zeile
                  movea.l  bitmap_addr(a6),a1   ;Adresse der Bitmap
                  
fline_laddr:      sub.w    d0,d2          ;dx
                  add.w    d0,d0          
                  add.w    d0,d0          ;Abstand vom Zeilenanfang in Bytes
                  mulu     d4,d1          
                  ext.l    d0
                  add.l    d0,d1          ;Zieladresse

                  move.l   a1,-(sp)
                  moveq    #64,d7         ;Abstand identischer Punkte des Musters
                  
                  moveq    #15,d6         ;Punktezaehler fuers Muster
                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fline_color
                  move.w   d2,d6

fline_color:      moveq    #63,d0
                  and.w    d1,d0
                  move.l   0(a0,d0.w),d5

                  move.w   d2,d4
                  lsr.w    #4,d4
                  movea.l  (sp),a1
                  adda.l   d1,a1          ;Offset addieren
fline_color_loop: move.l   d5,(a1)
                  adda.w   d7,a1
                  dbra     d4,fline_color_loop
               
                  addq.l   #4,d1          ;zum naechsten Punkt des Musters
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
                  add.w    d5,d5
                  move.l   0(a1,d5.w),d5  ;RGB-Farbwert

                  tst.w    bitmap_width(a6)  ;Off-Screen-Bitmap?
                  beq.s    hline_screen

                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs

                  movea.l  bitmap_addr(a6),a1   ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr

;horizontalen Linie ohne Clipping zeichnen
;Vorgaben:
;d0-d2/d4-d7/a1 duerfen veraendert werden
;Eingaben
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
                  add.w    d5,d5
                  move.l   0(a1,d5.w),d5  ;RGB-Farbwert

                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    hline_screen
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  muls     bitmap_width(a6),d1
                  bra.s    hline_laddr
hline_screen:     movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok4:
                  muls     BYTES_LIN.w,d1
hline_laddr:      move.w   d0,d4
                  add.w    d4,d4
                  add.w    d4,d4
                  adda.l   d1,a1
                  adda.w   d4,a1          ;Zieladresse

                  sub.w    d0,d2          ;dx
                  and.w    #15,d0
                  rol.w    d0,d6          ;Linienmuster rotieren

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

                  moveq    #64,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_repl_loop
                  move.w   d2,d0

hline_repl_loop:  add.w    d6,d6          ;Punkt gesetzt?
                  scc      d7
                  ext.w    d7
                  ext.l    d7
                  or.l     d5,d7

                  move.w   d2,d4
                  lsr.w    #4,d4

                  movea.l  a1,a3

hline_repl_set:   move.l   d7,(a3)
                  adda.w   d1,a3
                  dbra     d4,hline_repl_set

                  addq.l   #4,a1
                  subq.w   #1,d2
                  dbra     d0,hline_repl_loop
                  movea.l  (sp)+,a3
                  rts

hline_rev_trans:  not.w    d6
hline_trans:      cmp.w    #$ffff,d6
                  beq      hline_solid

                  move.l   a3,-(sp)

                  moveq    #64,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_tr_loop
                  move.w   d2,d0

hline_tr_loop:    add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    hline_tr_next

                  move.w   d2,d4
                  lsr.w    #4,d4

                  movea.l  a1,a3

hline_tr_points:  move.l   d5,(a3)
                  adda.w   d1,a3
                  dbra     d4,hline_tr_points

hline_tr_next:    addq.l   #4,a1

                  subq.w   #1,d2
                  dbra     d0,hline_tr_loop
                  movea.l  (sp)+,a3
                  rts

hline_eor_grow2:  addq.l   #4,a1
                  dbra     d2,hline_eor_grow
                  rts
hline_eor_grow:   lsr.w    #1,d2
hline_grow_loop:  not.l    (a1)+
                  addq.l   #4,a1
                  dbra     d2,hline_grow_loop
                  rts

hline_eor:        cmp.w    #$aaaa,d6
                  beq.s    hline_eor_grow
                  cmp.w    #$5555,d6
                  beq.s    hline_eor_grow2

                  move.l   a3,-(sp)

                  moveq    #64,d1         ;Abstand identischer Punkte des Musters

                  moveq    #15,d0         ;Punktezaehler fuers Muster
                  cmp.w    d0,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    hline_eor_loop
                  move.w   d2,d0

hline_eor_loop:   add.w    d6,d6          ;Punkt gesetzt?
                  bcc.s    hline_eor_next

                  move.w   d2,d4
                  lsr.w    #4,d4

                  movea.l  a1,a3

hline_eor_points: not.l    (a3)
                  adda.w   d1,a3
                  dbra     d4,hline_eor_points

hline_eor_next:   addq.l   #4,a1
                  subq.w   #1,d2
                  dbra     d0,hline_eor_loop
                  movea.l  (sp)+,a3
                  rts

hline_solid:      move.l   d5,(a1)+
                  dbra     d2,hline_solid
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;vertikale Linie'

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
vline_saddr:      lea      c_palette(a6),a1
                  move.w   l_color(a6),d4
                  add.w    d4,d4
                  add.w    d4,d4
                  move.l   0(a1,d4.w),d4  ;RGB-Farbwert

                  movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok5:
                  move.w   BYTES_LIN.w,d5 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    vline_laddr
                  sub.w    bitmap_off_x(a6),d0  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
vline_laddr:      muls     d5,d1
                  adda.l   d1,a1          ;Zeilenadresse
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a1          ;Startadresse

                  ext.l    d5
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
                  move.l   d4,(a1)
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
vloop_eor_grow:   not.l    (a1)
                  adda.w   d5,a1          ;naechste Zeile
                  dbra     d3,vloop_eor_grow
                  rts

vline_eor:        cmp.w    #$aaaa,d6
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
                  not.l    (a1)
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

                  add.w    d6,d6          ;Punkt gesetzt?
                  scc      d2

                  ext.w    d2
                  ext.l    d2
                  or.l     d4,d2

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
                  move.l   d2,(a1)
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
                  move.l   d4,(a1)
                  adda.w   d5,a1          ;naechste Zeile
                  ENDM
                  dbra     d3,vline_sld_loop
vline_solid_exit: rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;schraege Linie'

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
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1),d3        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d5 ;Bytes pro Zeile
line_laddr:       move.w   d5,d4
                  muls     d1,d4          ;Bytes pro Zeile * y1
                  adda.l   d4,a1          ;Zeilenadresse
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a1          ;Startadresse
                  asr.w    #2,d0

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
                  add.w    d4,d4
                  move.l   0(a0,d4.w),d4
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
                  move.l   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_rep_loop
                  rts
line_rep_white:   move.l   d7,(a1)+       ;weissen Punkt setzen
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_rep_ystep ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop
                  rts
line_rep_ystep:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e - 2dx
                  dbra     d0,line_rep_loop ;Punktezaehler dekrementieren
line_rep_exit:    rts

line_solid:       move.l   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_sl_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_solid
                  rts
line_sl_ystep:    adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e - 2dx
                  dbra     d0,line_solid  ;Punktezaehler dekrementieren
                  rts

line_rev_trans:   not.w    d6
line_trans:       rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_trans_next ;nicht gesetzt ?
                  move.l   d4,(a1)+       ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_tr_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_trans
                  rts
line_trans_next:  addq.l   #4,a1          ;naechster Punkt
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_tr_ystep  ;wenn ja; Schritt nach unten
                  dbra     d0,line_trans
                  rts
;vertikaler Schritt
line_tr_ystep:    adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e - 2dx
                  dbra     d0,line_trans  ;Punktezaehler dekrementieren
line_tr_exit:     rts

line_eor:         moveq    #$ffffffff,d4
line_eor_loop:    rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_next  ;nicht gesetzt ?
                  not.l    (a1)+          ;schwarzen Punkt setzen
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_eor_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_eor_loop
                  rts
line_eor_next:    addq.l   #4,a1          ;naechster Punkt
                  add.w    d1,d3          ;e + 2dy
                  bpl.s    line_eor_ystep ;wenn ja; Schritt nach unten
                  dbra     d0,line_eor_loop
                  rts
line_eor_ystep:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e - 2dx
                  dbra     d0,line_eor_loop ;Punktezaehler dekrementieren
line_eor_exit:    rts

line_rep45:       cmp.w    #$ffff,d6      ;durchgehend schwarz?
                  beq.s    line_solid45
                  moveq    #$ffffffff,d7
line_rep_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_rep_w45   ;nicht gesetzt ?
                  move.l   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
line_rep_w45:     move.l   d7,(a1)        ;weissen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_rep_x45   ;wenn ja; Schritt nach oben oder unten
                  dbra     d0,line_rep_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_rep_x45:     add.w    d1,d3          ;e - 2dy
                  addq.l   #4,a1          ;naechster Punkt
                  dbra     d0,line_rep_loop45
                  rts

line_solid45:     move.l   d4,(a1)        ;schwarzen Punkt setzen
                  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_solid_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_solid45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_solid_x45:   add.w    d1,d3          ;e - 2dy
                  addq.l   #4,a1          ;naechster Punkt
                  dbra     d0,line_solid45
                  rts

line_rev_trans45: not.w    d6             ;Linienstil invertieren
line_trans45:     rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_tr_next45 ;nicht gesetzt ?
                  move.l   d4,(a1)        ;schwarzen Punkt setzen
line_tr_next45:   adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_trans_x45 ;wenn ja; Schritt nach rechts
                  dbra     d0,line_trans45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_trans_x45:   add.w    d1,d3          ;e - 2dy
                  addq.l   #4,a1          ;naechster Punkt
                  dbra     d0,line_trans45
                  rts

line_eor45:       moveq    #$ffffffff,d4
line_eor_loop45:  rol.w    #1,d6          ;Punkt im Linienstil
                  bcc.s    line_eor_next45 ;nicht gesetzt ?
                  not.l    (a1)           ;schwarzen Punkt setzen
line_eor_next45:  adda.w   d5,a1          ;naechste Zeile
                  add.w    d2,d3          ;e + 2dx
                  bpl.s    line_eor_x45   ;wenn ja; Schritt nach rechts
                  dbra     d0,line_eor_loop45 ;Punktezaehler dekrementieren
                  rts
;horizontaler Schritt
line_eor_x45:     add.w    d1,d3          ;e - 2dy
                  addq.l   #4,a1          ;naechster Punkt
                  dbra     d0,line_eor_loop45
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Rechteck'

Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;d3.w y2
;d4.w Bytes pro Zeile
;d5.w RGB-Farbwert
;a1.l Adresse
fbox_solid:       sub.w    d1,d3          ;dy

                  muls     d4,d1
                  move.w   d0,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  ext.l    d6
                  add.l    d6,d1
                  adda.l   d1,a1

                  sub.w    d0,d2
                  move.w   d2,d0
                  addq.w   #1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  sub.w    d0,d4          ;Abstand zur naechsten Zeile

fbox_sld_scnt:    moveq    #$07,d0
                  and.w    d2,d0
                  eori.w   #$07,d0
                  add.w    d0,d0
                  lsr.w    #3,d2          ;8-Pixel-Zaehler
                  lea      fbox_sld_sloop(pc,d0.w),a0

fbox_sld_sbloop:  move.w   d2,d0
                  jmp      (a0)
fbox_sld_sloop:   REPT 8
                  move.l   d5,(a1)+
                  ENDM
                  dbra     d0,fbox_sld_sloop
fbox_sld_snxt:    adda.w   d4,a1
                  dbra     d3,fbox_sld_sbloop
fbox_sld_sexit:   rts

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
                  add.w    d5,d5
                  move.l   0(a0,d5.w),d5  ;RGB-Farbwert

                  movea.l  v_bas_ad.w,a1  ;Bildadresse
relok7:
                  move.w   BYTES_LIN.w,d4 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    fbox_universal
                  
                  lea      bitmap_off_x(a6),a1
                  sub.w    (a1),d0        ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1)+,d2       ;bitmap_off_x: horizontale Verschiebung des Ursprungs
                  sub.w    (a1),d1        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  sub.w    (a1),d3        ;bitmap_off_y: vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  move.w   bitmap_width(a6),d4 ;Bytes pro Zeile

fbox_universal:   move.w   f_interior(a6),d6
                  move.w   wr_mode(a6),d7
                  bne.s    fbox_buffer

                  tst.w    f_color(a6)
                  beq      fbox_solid
                  cmpi.w   #F_SOLID,f_interior(a6)
                  beq      fbox_solid
                  cmpi.w   #F_PATTERN,f_interior(a6)
                  bne.s    fbox_buffer
                  cmpi.w   #8,f_style(a6)
                  beq      fbox_solid


cnt               EQU 0
vcount            EQU 2
start_jmp_off     EQU 4
start_pat_off     EQU 6
end_jmp_off       EQU 8
end_pat_off       EQU 10
end_addr_off      EQU 12
next_line16       EQU 14
line_addr         EQU 18
next_line         EQU 22
pat_count         EQU 24
loadstack         EQU 28

;d0.w
;d1.w
;d2.w
;d3.w
;d4.w
;d5.l
;d7.w
;a1.l
fbox_buffer:      movea.l  f_pointer(a6),a4 ;Zeiger aufs Fuellmuster

                  movea.l  buffer_addr(a6),a0 ;Bufferadresse
                  sub.w    d1,d3          ;Zeilenzaehler in d3
                  move.w   d4,d6
                  ext.l    d6

                  muls     d1,d4
                  adda.l   d4,a1          ;Zeilenadresse
                  move.w   d0,d4
                  add.w    d4,d4
                  add.w    d4,d4
                  adda.w   d4,a1          ;Langwortadresse

                  tst.w    d7             ;REPLACE?
                  bne      fbox_eor

                  lea      -loadstack(sp),sp
                  move.w   d6,next_line(sp)

                  moveq    #$fffffff0,d4
                  and.w    d2,d4
                  sub.w    d0,d4
                  add.w    d4,d4
                  add.w    d4,d4
                  lsl.l    #4,d6          ;Bytes pro 16 Zeilen
                  ext.l    d4
                  sub.l    d4,d6
                  move.l   d6,next_line16(sp) ;Abstand zu 17. Zeile

                  movea.l  a0,a5          ;Bufferadresse

                  moveq    #31,d6
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
                  add.w    d1,d1

                  tst.w    f_planes(a6)      ;Farbmuster?
                  beq      fbox_repl_mono

                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_cfill2

                  move.l   a4,a3
                  
                  move.w   d1,d5
                  eor.w    d6,d5
                  move.w   d1,d6
                  subq.w   #1,d6
                  lsl.w    #5,d1
                  adda.w   d1,a3

fbox_repl_cfill1: REPT     8
                  move.l   (a3)+,(a5)+
                  ENDM
                  dbra     d5,fbox_repl_cfill1

fbox_repl_cfill2: REPT     8
                  move.l   (a4)+,(a5)+
                  ENDM
                  dbra     d6,fbox_repl_cfill2
                  
                  bra      fbox_repl_x2

fbox_repl_mono:   lea      expand_tab(pc),a6
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_repl_fill2

                  movea.l  a4,a3
                  adda.w   d1,a3
                  move.w   d1,d6
                  eori.w   #31,d1
                  subq.w   #1,d6

fbox_repl_fill1:  moveq    #0,d7
                  move.b   (a3)+,d7
                  lsl.w    #5,d7
                  lea      0(a6,d7.w),a2
                  REPT 8
                  move.l   (a2)+,d7
                  or.l     d5,d7          ;ausmaskieren
                  move.l   d7,(a5)+
                  ENDM
                  dbra     d1,fbox_repl_fill1

fbox_repl_fill2:  moveq    #0,d7
                  move.b   (a4)+,d7
                  lsl.w    #5,d7
                  lea      0(a6,d7.w),a2
                  REPT 8
                  move.l   (a2)+,d7
                  or.l     d5,d7          ;ausmaskieren
                  move.l   d7,(a5)+
                  ENDM
                  dbra     d6,fbox_repl_fill2

fbox_repl_x2:     move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1
                  beq      fbox_repl_short ;kombinierte Start- und Endmaske?

                  subq.w   #2,d2
                  move.w   d2,(sp)        ;16pixelweiser Zaehler

                  moveq    #$1e,d5

                  add.w    d0,d0          ;x1 * 2
                  and.w    d5,d0
                  move.w   d0,start_jmp_off(sp) ;Offset fuer den Einsprung beim Schreiben der Startmaske
                  moveq    #0,d7
                  sub.w    #24,d0
                  bmi.s    fbox_repl_spo
                  move.w   d0,d7
                  add.w    d7,d7          ;Offset fuer die Musteradresse beim Schreiben der Startmaske
fbox_repl_spo:    move.w   d7,start_pat_off(sp)

                  add.w    d6,d6          ;x2 * 2
                  and.w    d5,d6
                  move.w   d6,d7
                  add.w    d7,d7
                  addq.w   #4,d7
                  move.w   d7,end_addr_off(sp) ;Wert fuer die Addition beim Schreiben der Endmaske

                  eor.w    d5,d6
                  move.w   d6,end_jmp_off(sp) ;Offset fuer den Einsprung beim Schreiben der Endmaske
                  moveq    #16,d7
                  subq.w   #8,d6          ;werden move.l -(a0),-(a1) angesprungen?
                  bpl.s    fbox_repl_epo
                  add.w    d6,d6
                  add.w    d6,d7
fbox_repl_epo:    move.w   d7,end_pat_off(sp) ;Offset fuer die Musteradresse beim Schreiben der Endmaske

fbox_repl_mask:   moveq    #15,d0
                  cmp.w    d0,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_replace2
                  move.w   d3,d0

fbox_replace2:    move.w   d0,pat_count(sp)
                  move.w   d3,vcount(sp)

fbox_repl_bloop:  move.l   a1,line_addr(sp)
                  move.w   vcount(sp),d0

                  lsr.w    #4,d0

                  move.l   (a0)+,d1
                  move.l   (a0)+,d2
                  move.l   (a0)+,d3
                  move.l   (a0)+,d4
                  move.l   (a0)+,d5
                  move.l   (a0)+,d6
                  move.l   (a0)+,d7
                  movea.l  (a0)+,a2
                  movea.l  (a0)+,a3
                  movea.l  (a0)+,a4
                  movea.l  (a0)+,a5
                  movea.l  (a0)+,a6

fbox_repl_line:   swap     d0
                  adda.w   start_pat_off(sp),a0
                  move.w   start_jmp_off(sp),d0
                  jmp      fbox_repl_sm(pc,d0.w)

fbox_repl_sm:     move.l   d1,(a1)+
                  move.l   d2,(a1)+
                  move.l   d3,(a1)+
                  move.l   d4,(a1)+
                  move.l   d5,(a1)+
                  move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  move.l   a2,(a1)+
                  move.l   a3,(a1)+
                  move.l   a4,(a1)+
                  move.l   a5,(a1)+
                  move.l   a6,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+

                  move.w   (sp),d0
                  bmi.s    fbox_repl_ejmp

fbox_repl_loop:   lea      -16(a0),a0
                  move.l   d1,(a1)+
                  move.l   d2,(a1)+
                  move.l   d3,(a1)+
                  move.l   d4,(a1)+
                  move.l   d5,(a1)+
                  move.l   d6,(a1)+
                  move.l   d7,(a1)+
                  move.l   a2,(a1)+
                  move.l   a3,(a1)+
                  move.l   a4,(a1)+
                  move.l   a5,(a1)+
                  move.l   a6,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  move.l   (a0)+,(a1)+
                  dbra     d0,fbox_repl_loop

fbox_repl_ejmp:   suba.w   end_pat_off(sp),a0
                  adda.w   end_addr_off(sp),a1

                  move.w   end_jmp_off(sp),d0
                  jmp      fbox_repl_em(pc,d0.w)

fbox_repl_em:     move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  move.l   -(a0),-(a1)
                  move.l   a6,-(a1)
                  move.l   a5,-(a1)
                  move.l   a4,-(a1)
                  move.l   a3,-(a1)
                  move.l   a2,-(a1)
                  move.l   d7,-(a1)
                  move.l   d6,-(a1)
                  move.l   d5,-(a1)
                  move.l   d4,-(a1)
                  move.l   d3,-(a1)
                  move.l   d2,-(a1)
                  move.l   d1,-(a1)

                  adda.l   next_line16(sp),a1 ;16 Zeilen weiter

                  swap     d0
                  dbra     d0,fbox_repl_line

                  lea      16(a0),a0      ;naechste Musterzeile
                  movea.l  line_addr(sp),a1
                  adda.w   next_line(sp),a1 ;naechste Rechteckzeile

                  subq.w   #1,vcount(sp)
                  subq.w   #1,pat_count(sp)
                  bpl      fbox_repl_bloop

                  lea      loadstack(sp),sp
                  rts


fbox_repl_short:  movea.w  next_line(sp),a3 ;Bytes pro Zeile
                  lea      loadstack(sp),sp

                  moveq    #15,d1

                  sub.w    d0,d6          ;dx
                  move.w   d6,d7
                  add.w    d7,d7
                  add.w    d7,d7
                  suba.w   d7,a3          ;Zeilenbreite angleichen
                  eor.w    d1,d6
                  add.w    d6,d6
                  lea      fbox_repl_shrt2(pc,d6.w),a2

                  and.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a0          ;Quelladresse

fbox_repl_shrt0:  movea.l  a0,a4
                  lea      64(a0),a0
                  dbra     d1,fbox_repl_shrt1
                  moveq    #15,d1
                  lea      -1024(a0),a0

fbox_repl_shrt1:  jmp      (a2)
fbox_repl_shrt2:  REPT 15
                  move.l   (a4)+,(a1)+
                  ENDM
                  move.l   (a4)+,(a1)
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

fbox_eor_buf:     move.w   d6,-(sp)       ;Bytes pro Zeile

                  lea      expand_tab(pc),a6

                  movea.l  a0,a5          ;Bufferadresse

                  moveq    #31,d6
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
                  add.w    d1,d1
                  and.w    d6,d1          ;y1 & 15
                  beq.s    fbox_eor_fill2

                  movea.l  a4,a3
                  adda.w   d1,a3
                  move.w   d1,d6
                  eori.w   #31,d1
                  subq.w   #1,d6

fbox_eor_fill1:   moveq    #0,d7
                  move.b   (a3)+,d7
                  not.b    d7
                  lsl.w    #5,d7
                  lea      0(a6,d7.w),a2
                  REPT 8
                  move.l   (a2)+,(a5)+
                  ENDM
                  dbra     d1,fbox_eor_fill1

fbox_eor_fill2:   moveq    #0,d7
                  move.b   (a4)+,d7
                  not.b    d7
                  lsl.w    #5,d7
                  lea      0(a6,d7.w),a2
                  REPT 8
                  move.l   (a2)+,(a5)+
                  ENDM
                  dbra     d6,fbox_eor_fill2

                  movea.w  (sp)+,a3

                  move.w   d2,d6          ;x2
                  lsr.w    #4,d2          ;x2 / 16
                  move.w   d0,d4
                  lsr.w    #4,d4          ;x1 / 16
                  sub.w    d4,d2          ;(Laenge in 16 Pixeln) - 1

                  moveq    #%1111,d1

                  move.w   d6,d7
                  sub.w    d0,d7          ;dx
                  add.w    d7,d7
                  add.w    d7,d7
                  addq.w   #4,d7
                  suba.w   d7,a3          ;Zeilenbreite angleichen

                  and.w    d1,d0
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a0          ;Quelladresse

                  subq.w   #1,d2          ;kein Zwischenteil?
                  bpl.s    fbox_eor_long
                  subq.w   #4,d7
                  eori.w   #%111100,d7
                  lea      fbox_eor_endmask(pc,d7.w),a2
                  bra.s    fbox_eor_bloop

fbox_eor_long:    lea      fbox_eor_loop(pc,d0.w),a2

                  and.w    d1,d6
                  eor.w    d1,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  lea      fbox_eor_endmask(pc,d6.w),a5

fbox_eor_bloop:   movea.l  a0,a4
                  lea      64(a0),a0
                  dbra     d1,fbox_eor_line
                  moveq    #15,d1

                  lea      -1024(a0),a0

fbox_eor_line:    move.w   d2,d4
                  jmp      (a2)
fbox_eor_loop:    REPT 16
                  move.l   (a4)+,d0
                  eor.l    d0,(a1)+
                  ENDM
                  lea      -64(a4),a4
                  dbra     d4,fbox_eor_loop

                  jmp      (a5)
fbox_eor_endmask: REPT 16
                  move.l   (a4)+,d0
                  eor.l    d0,(a1)+
                  ENDM

                  adda.w   a3,a1          ;naechste Zeile
                  dbra     d3,fbox_eor_bloop
fbox_eor_exit:    rts

fbox_not:         sub.w    d0,d2          ;dx
                  move.w   d2,d1
                  addq.w   #1,d1
                  add.w    d1,d1
                  add.w    d1,d1
                  sub.w    d1,d6          ;Abstand zur naechsten Zeile

                  moveq    #$0f,d0
                  and.w    d2,d0
                  lsr.w    #4,d2          ;16-Pixel-Zaehler
                  eori.w   #$0f,d0
                  add.w    d0,d0
                  lea      fbox_not_loop(pc,d0.w),a0

fbox_not_bloop:   move.w   d2,d0
                  jmp      (a0)
fbox_not_loop:    REPT 16
                  not.l    (a1)+
                  ENDM
                  dbra     d0,fbox_not_loop
fbox_not_next:    adda.w   d6,a1          ;naechste Zeile
                  dbra     d3,fbox_not_bloop
                  rts

fbox_rev_trans:   sub.w    d0,d2          ;dx

                  move.w   d6,-(sp)
                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0          ;x1 & 15
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
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

                  move.w   d6,-(sp)
                  lsl.l    #4,d6
                  movea.l  d6,a3          ;Bytes pro 16 Zeilen

                  movea.l  a0,a5          ;Bufferadresse
                  moveq    #15,d4         ;zum Ausmaskieren
                  moveq    #15,d6
                  and.w    d4,d0
                  add.w    bitmap_off_y(a6),d1  ;vertikale Verschiebung beruecksichtigen
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

fbox_tr_color:    move.l   d5,d7          ;RGB-Farbwert

                  cmp.w    d4,d3          ;wenigstens 16 Zeilen?
                  bge.s    fbox_tr_vcount
                  move.w   d3,d4
fbox_tr_vcount:   swap     d3
                  move.w   d4,d3

                  movea.w  #64,a2         ;Abstand identischer Punkte des Musters

                  moveq    #15,d6         ;Punktezaehler fuers Muster

                  cmp.w    d6,d2          ;mindestens 16 Punkte zeichnen?
                  bge.s    fbox_tr_hcount
                  move.w   d2,d6

fbox_tr_hcount:   movea.w  d6,a4          ;Punktezaehler
                  sub.w    d6,d2
                  addq.w   #1,d6
                  add.w    d6,d6
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
                  move.l   d7,(a6)
                  adda.w   a2,a6
                  ENDM
                  dbra     d4,fbox_tr_points

fbox_tr_next:     addq.l   #4,a5
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
                  ; 'Text fuer 9 und 10 Punkte'

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
textblt:          movea.l  v_bas_ad.w,a1  ;Adresse des Bildschirms
relok8:
                  movea.w  BYTES_LIN.w,a3 ;Bytes pro Zeile
                  tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  beq.s    textblt_color
                  sub.w    bitmap_off_x(a6),d2  ;horizontale Verschiebung des Ursprungs
                  sub.w    bitmap_off_y(a6),d3  ;vertikale Verschiebung des Ursprungs
                  movea.l  bitmap_addr(a6),a1 ;Adresse der Bitmap
                  movea.w  bitmap_width(a6),a3 ;Bytes pro Zeile
textblt_color:    clr.w    r_bgcol(a6)
                  move.w   t_color(a6),r_fgcol(a6)
                  move.w   wr_mode(a6),r_wmode(a6)
                  clr.w    r_splanes(a6)                    ;hier stand vorher move.w #0,r_splanes(a6) => habe ich ersetzt, weil ich unten das bra.s expand_blt eingefuegt habe
                  move.w   r_planes(a6),r_dplanes(a6)
                  cmpi.w   #MD_ERASE-MD_REPLACE,r_wmode(a6) ;REVERS TRANSPARENT?
                  bne.s    expand_blt
                  clr.w    r_fgcol(a6)    ;r_wmode nur wortweise nutzen!
                  move.w   t_color(a6),r_bgcol(a6) ;Textfarbe
                  bra.s    expand_blt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Expand-Blt'

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
;a6.l r_wmode, r_fgcol, r_bgcol, r_saddr, r_daddr, r_swidth, r_wwidth, r_dplanes
expblt:           movea.l  r_saddr(a6),a0
                  movea.l  r_daddr(a6),a1
                  movea.w  r_swidth(a6),a2
                  movea.w  r_dwidth(a6),a3

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
expand_blt:       move.w   a2,d6                            ;Bytes pro Quellzeile
                  move.w   a3,d7                            ;Bytes pro Zielzeile

                  muls     d6,d1
                  adda.l   d1,a0
                  move.w   d0,d1
                  lsr.w    #4,d1                            ;qx / 16
                  add.w    d1,d1
                  adda.w   d1,a0                            ;Quelladresse

                  muls     d7,d3
                  adda.l   d3,a1                            ;Zielzeilenadresse
                  add.w    d2,d2
                  add.w    d2,d2                            ;zx * 4
                  adda.w   d2,a1                            ;Zieladresse

                  moveq    #15,d1
                  and.w    d1,d0                            ;Shifts nach links fuer das erste Wort
                  eor.w    d0,d1                            ;Schleifenzaehler fuer das erste Wort
                  
                  cmp.w    d1,d4                            ;Schleifenzaehler groesser als die Breite?
                  bge.s    expand_blt_wcnt
                  move.w   d4,d1                            ;Schleifenzaehler begrenzen

expand_blt_wcnt:  swap     d0
                  move.w   d1,d0
                  swap     d0                               ;Schleifenzaehler / Shifts nach links

                  move.w   d0,d2                            ;qx & 15
                  add.w    d4,d2                            ;dx
                  lsr.w    #4,d2                            ;/ 16 = Anzahl der einzulesenden Worte - 1
                  add.w    d2,d2
                  addq.w   #2,d2
                  suba.w   d2,a2                            ;Abstand zur naechsten Quellzeile

                  move.w   d4,d2                            ;dx
                  add.w    d2,d2
                  add.w    d2,d2
                  addq.w   #4,d2
                  suba.w   d2,a3                            ;Abstand zur naechsten Zielzeile

                  sub.w    d1,d4                            ;dx + 1 - Anzahl der Pixel im ersten Wort

                  lea      c_palette(a6),a4                 ;Zeiger auf die virtuelle Palette
                  move.w   r_fgcol(a6),d6                   ;Vordergrundfarbe
                  add.w    d6,d6
                  add.w    d6,d6
                  move.l   0(a4,d6.w),d6                    ;Vordergrundfarbe

                  move.w   r_bgcol(a6),d7
                  add.w    d7,d7
                  add.w    d7,d7
                  move.l   0(a4,d7.w),d7                    ;Hintergrundfarbe

                  moveq    #3,d2
                  and.w    r_wmode(a6),d2
                  add.w    d2,d2
                  move.w   eblt_tab(pc,d2.w),d2
                  jmp      eblt_tab(pc,d2.w)
                  
eblt_tab:         DC.W     eblt_repl-eblt_tab
                  DC.W     eblt_trans-eblt_tab
                  DC.W     eblt_eor-eblt_tab
                  DC.W     eblt_rev_trans-eblt_tab

eblt_repl:
eblt_repl_line:   move.w   d4,d3                            ;dx + 1 - Anzahl der Pixel im ersten Wort

                  move.w   (a0)+,d2                         ;erstes Wort einlesen
                  rol.w    d0,d2                            ;ueberzaehlige Pixel wegrotieren
                  move.l   d0,d1
                  swap     d1                               ;Anzahl der auszugebenden Pixel im ersten Wort - 1
                  bra.s    eblt_repl_loop
                  
eblt_repl_read:   move.w   (a0)+,d2                         ;Quellwort einlesen
eblt_repl_loop:   add.w    d2,d2                            ;Pixel gesetzt?
                  bcc.s    eblt_repl_bg
                  move.l   d6,(a1)+                         ;Vordergrundfarbe
                  dbra     d1,eblt_repl_loop
                  bra.s    eblt_repl_next
                  
eblt_repl_bg:     move.l   d7,(a1)+                         ;Hintergrundfarbe
                  dbra     d1,eblt_repl_loop

eblt_repl_next:   moveq    #15,d1
                  subq.w   #1,d3
                  sub.w    d1,d3                            ;muessen noch mindestens 16 Pixel ausgegeben werden?
                  bpl.s    eblt_repl_read
                  add.w    d3,d1                            ;Anzahl der Pixel im letzten Wort - 1
                  bpl.s    eblt_repl_read
                  
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_repl_line
                  rts

eblt_trans:
eblt_trans_line:  move.w   d4,d3                            ;dx + 1 - Anzahl der Pixel im ersten Wort

                  move.w   (a0)+,d2                         ;erstes Wort einlesen
                  rol.w    d0,d2                            ;ueberzaehlige Pixel wegrotieren
                  move.l   d0,d1
                  swap     d1                               ;Anzahl der auszugebenden Pixel im ersten Wort - 1
                  bra.s    eblt_trans_loop
                  
eblt_trans_read:  move.w   (a0)+,d2                         ;Quellwort einlesen
eblt_trans_loop:  add.w    d2,d2                            ;Pixel gesetzt?
                  bcc.s    eblt_trans_bg
                  move.l   d6,(a1)+                         ;Vordergrundfarbe
                  dbra     d1,eblt_trans_loop
                  bra.s    eblt_trans_next
                  
eblt_trans_bg:    addq.l   #4,a1
                  dbra     d1,eblt_trans_loop

eblt_trans_next:  moveq    #15,d1
                  subq.w   #1,d3
                  sub.w    d1,d3                            ;muessen noch mindestens 16 Pixel ausgegeben werden?
                  bpl.s    eblt_trans_read
                  add.w    d3,d1                            ;Anzahl der Pixel im letzten Wort - 1
                  bpl.s    eblt_trans_read
                  
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_trans_line
                  rts

eblt_eor:
eblt_eor_line:    move.w   d4,d3                            ;dx + 1 - Anzahl der Pixel im ersten Wort

                  move.w   (a0)+,d2                         ;erstes Wort einlesen
                  rol.w    d0,d2                            ;ueberzaehlige Pixel wegrotieren
                  move.l   d0,d1
                  swap     d1                               ;Anzahl der auszugebenden Pixel im ersten Wort - 1
                  bra.s    eblt_eor_loop
                  
eblt_eor_read:    move.w   (a0)+,d2                         ;Quellwort einlesen
eblt_eor_loop:    add.w    d2,d2                            ;Pixel gesetzt?
                  bcc.s    eblt_eor_bg
                  not.l    (a1)+
                  dbra     d1,eblt_eor_loop
                  bra.s    eblt_eor_next
                  
eblt_eor_bg:      addq.l   #4,a1
                  dbra     d1,eblt_eor_loop

eblt_eor_next:    moveq    #15,d1
                  subq.w   #1,d3
                  sub.w    d1,d3                            ;muessen noch mindestens 16 Pixel ausgegeben werden?
                  bpl.s    eblt_eor_read
                  add.w    d3,d1                            ;Anzahl der Pixel im letzten Wort - 1
                  bpl.s    eblt_eor_read
                  
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_eor_line
                  rts

eblt_rev_trans:
eblt_rtr_line:    move.w   d4,d3                            ;dx + 1 - Anzahl der Pixel im ersten Wort

                  move.w   (a0)+,d2                         ;erstes Wort einlesen
                  rol.w    d0,d2                            ;ueberzaehlige Pixel wegrotieren
                  move.l   d0,d1
                  swap     d1                               ;Anzahl der auszugebenden Pixel im ersten Wort - 1
                  bra.s    eblt_rtr_loop
                  
eblt_rtr_read:    move.w   (a0)+,d2                         ;Quellwort einlesen
eblt_rtr_loop:    add.w    d2,d2                            ;Pixel nicht gesetzt?
                  bcs.s    eblt_rtr_fg
                  move.l   d7,(a1)+                         ;Hintergrundfarbe
                  dbra     d1,eblt_rtr_loop
                  bra.s    eblt_rtr_next
                  
eblt_rtr_fg:      addq.l   #4,a1
                  dbra     d1,eblt_rtr_loop

eblt_rtr_next:    moveq    #15,d1
                  subq.w   #1,d3
                  sub.w    d1,d3                            ;muessen noch mindestens 16 Pixel ausgegeben werden?
                  bpl.s    eblt_rtr_read
                  add.w    d3,d1                            ;Anzahl der Pixel im letzten Wort - 1
                  bpl.s    eblt_rtr_read
                  
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,eblt_rtr_line
                  rts
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Bitblocktransfer'

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

                  ext.l    d0
                  ext.l    d2

                  move.w   a2,d6
                  mulu     d6,d1
                  add.l    d0,d0
                  add.l    d0,d0
                  add.l    d0,d1
                  asr.l    #2,d0
                  adda.l   d1,a0          ;Quelladresse

                  move.w   a3,d6
                  mulu     d6,d3
                  add.l    d2,d2
                  add.l    d2,d2
                  add.l    d2,d3
                  asr.l    #2,d2
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
                  add.w    d4,d4
                  add.w    d4,d4
                  adda.w   d4,a4          ;Quellendadresse
                  lsr.w    #2,d4
                  cmpa.l   a1,a4          ;Quellendadresse < Zieladresse?
                  bcs      bitblt_inc

                  addq.l   #4,a4          ;Quellendadresse + 12
                  add.l    a4,d1
                  sub.l    a0,d1

                  movea.l  a1,a5
                  move.w   a3,d6
                  mulu     d5,d6
                  adda.l   d6,a5
                  add.w    d4,d4
                  add.w    d4,d4
                  adda.w   d4,a5
                  lsr.w    #2,d4
                  addq.l   #4,a5          ;Zielendadresse + 2
                  add.l    a5,d3
                  sub.l    a1,d3

                  exg      a0,a4
                  exg      a1,a5

bitblt_dec:       move.w   d4,d6
                  addq.w   #1,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

                  moveq    #3,d1
                  and.w    d4,d1          ;Wortzahl
                  eori.w   #3,d1
                  add.w    d1,d1

                  asr.w    #2,d4          ;8-Wortzaehler

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

                  move.w   d1,d7
                  add.w    d1,d1
                  add.w    d7,d1
                  bra.s    bltld_jmp

bltld_m4:         add.w    d1,d1

bltld_jmp:        move.w   (a4)+,d7
                  jmp      bltld_tab(pc,d7.w)
bitblt_exit:      rts

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


blt1ld:           lea      blt1ld_loop(pc,d1.w),a5
blt1ld_bloop:     move.w   d4,d6
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

blt2ld:           lea      blt2ld_loop(pc,d1.w),a5
blt2ld_bloop:     move.w   d4,d6
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

blt3ld:           lea      blt3ld_loop(pc,d1.w),a5
blt3ld_bloop:     move.w   d4,d6
                  jmp      (a5)
blt3ld_loop:      REPT 4
                  move.l   -(a0),-(a1)
                  ENDM
                  dbra     d6,blt3ld_loop
                  suba.w   a2,a0          ;naechste Quellzeile
                  suba.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3ld_bloop
                  rts

blt4ld:           lea      blt4ld_loop(pc,d1.w),a5
blt4ld_bloop:     move.w   d4,d6
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

blt6ld:           lea      blt6ld_loop(pc,d1.w),a5
blt6ld_bloop:     move.w   d4,d6
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

blt7ld:           lea      blt7ld_loop(pc,d1.w),a5
blt7ld_bloop:     move.w   d4,d6
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

blt8ld:           lea      blt8ld_loop(pc,d1.w),a5
blt8ld_bloop:     move.w   d4,d6
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

blt9ld:           lea      blt9ld_loop(pc,d1.w),a5
blt9ld_bloop:     move.w   d4,d6
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

blt11ld:          lea      blt11ld_loop(pc,d1.w),a5
blt11ld_bloop:    move.w   d4,d6
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

blt12ld:          lea      blt12ld_loop(pc,d1.w),a5
blt12ld_bloop:    move.w   d4,d6
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

blt13ld:          lea      blt13ld_loop(pc,d1.w),a5
blt13ld_bloop:    move.w   d4,d6
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

blt14ld:          lea      blt14ld_loop(pc,d1.w),a5
blt14ld_bloop:    move.w   d4,d6
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

bitblt_inc:       cmp.w    #3,d7             ;kopieren?
                  bne      bitblt_inc_0x0

                  move.w   cpu040(pc),d1     ;68040-Prozessor?
                  beq      bitblt_inc_0x0

                  cmp.w    #15,d4         ;zu kurz?
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
                  add.w    d7,d7
                  add.w    d7,d7
                  suba.w   d7,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d7,a3          ;Abstand zur naechsten Zielzeile

                  moveq    #3,d6
                  lsr.w    #2,d1
                  move.w   d1,d0
                  bne.s    blt040_start_mis
                  
                  moveq    #-1,d0
                  bra.s    blt040_end
                                    
blt040_start_mis: not      d0
                  and.w    d6,d0          ;Anzahl der anfaenglich zu kopierenden Langworte - 1
                  
                  sub.w    d0,d4
                  subq.w   #1,d4
                  
blt040_end:       move.w   d4,d2
                  lsr.w    #2,d4
                  subq.w   #1,d4          ;Zaehler fuer move16

                  and.w    d6,d2          ;Anzahl der am Ende zu kopierenden Langworte - 1
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
                  
blt3li_040_16:    move16   (a0)+,(a1)+
                  dbra     d6,blt3li_040_16
                  
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
blt3li_040_16nxt: move.w   d4,d6
                  dbra     d5,blt3li_040_16
                  rts

                  ALIGN 16

                  nop
                  nop
                  nop

blt3li_040_bloop: move.w   d0,d6
                  bmi.s    blt3li_move16
                  
blt3li_040_start: move.l   (a0)+,(a1)+
                  dbra     d6,blt3li_040_start
                  
blt3li_move16:    move.w   d4,d6

blt3li_loop16:    move16   (a0)+,(a1)+
                  dbra     d6,blt3li_loop16

                  move.w   d2,d6
                  bmi.s    blt3li_040_next
blt3li_040_end:   move.l   (a0)+,(a1)+
                  dbra     d6,blt3li_040_end

blt3li_040_next:  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3li_040_bloop
                  rts

                  MC68000

bitblt_inc_0x0:   move.w   d4,d6
                  addq.w   #1,d6
                  add.w    d6,d6
                  add.w    d6,d6
                  suba.w   d6,a2          ;Abstand zur naechsten Quellzeile
                  suba.w   d6,a3          ;Abstand zur naechsten Zielzeile

                  moveq    #3,d1
                  and.w    d4,d1          ;Wortzahl
                  eori.w   #3,d1
                  add.w    d1,d1
                  asr.w    #2,d4          ;8-Wortzaehler

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

                  move.w   d1,d7
                  add.w    d1,d1
                  add.w    d7,d1
                  bra.s    bltli_jmp

bltli_m4:         add.w    d1,d1

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

blt15li:          moveq    #0,d7
                  bra.s    blt0li_jmp
blt0li:           moveq    #$ffffffff,d7
blt0li_jmp:       lea      blt0li_loop(pc,d1.w),a5
blt0li_bloop:     move.w   d4,d6
                  jmp      (a5)
blt0li_loop:      REPT 4
                  move.l   d7,(a1)+
                  ENDM
                  dbra     d6,blt0li_loop
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt0li_bloop
                  rts

blt1li:           lea      blt1li_loop(pc,d1.w),a5
blt1li_bloop:     move.w   d4,d6
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

blt2li:           lea      blt2li_loop(pc,d1.w),a5
blt2li_bloop:     move.w   d4,d6
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

blt3li:           lea      blt3li_loop(pc,d1.w),a5
blt3li_bloop:     move.w   d4,d6
                  jmp      (a5)
blt3li_loop:      REPT 4
                  move.l   (a0)+,(a1)+
                  ENDM
                  dbra     d6,blt3li_loop
                  adda.w   a2,a0          ;naechste Quellzeile
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt3li_bloop
                  rts

blt4li:           lea      blt4li_loop(pc,d1.w),a5
blt4li_bloop:     move.w   d4,d6
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

blt6li:           lea      blt6li_loop(pc,d1.w),a5
blt6li_bloop:     move.w   d4,d6
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

blt7li:           lea      blt7li_loop(pc,d1.w),a5
blt7li_bloop:     move.w   d4,d6
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

blt8li:           lea      blt8li_loop(pc,d1.w),a5
blt8li_bloop:     move.w   d4,d6
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

blt9li:           lea      blt9li_loop(pc,d1.w),a5
blt9li_bloop:     move.w   d4,d6
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

blt10li:          lea      blt10li_loop(pc,d1.w),a5
blt10li_bloop:    move.w   d4,d6
                  jmp      (a5)
blt10li_loop:     REPT 4
                  not.l    (a1)+
                  ENDM
                  dbra     d6,blt10li_loop
                  adda.w   a3,a1          ;naechste Zielzeile
                  dbra     d5,blt10li_bloop
                  rts

blt11li:          lea      blt11li_loop(pc,d1.w),a5
blt11li_bloop:    move.w   d4,d6
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

blt12li:          lea      blt12li_loop(pc,d1.w),a5
blt12li_bloop:    move.w   d4,d6
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

blt13li:          lea      blt13li_loop(pc,d1.w),a5
blt13li_bloop:    move.w   d4,d6
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

blt14li:          lea      blt14li_loop(pc,d1.w),a5
blt14li_bloop:    move.w   d4,d6
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
                  add.l    d0,d0
                  add.l    d0,d0                            ;Bufferlaenge in Bytes

                  tst.w    r_splanes(a6)                    ;32 Bit?
                  bne.s    scale_buf_len
                  
                  lsr.l    #6,d0                            ;Anzahl der Worte
                  addq.l   #1,d0                            ;Anzahl der Worte + 1
                  add.l    d0,d0                            ;Anzahl der Bytes + 2
                  
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
                  add.l    d1,d1
                  tst.w    r_splanes(a6)                    ;32 Bit?
                  bne.s    scale_init_addr
                  asr.l    #6,d1
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

                  tst.w    r_splanes(a6)                    ;32 Bit?
                  bne.s    scale_init32

                  lea      scale_line1(pc),a1
                  lea      scale_line1_trans(pc),a2

                  movem.l  (sp)+,d0-d7
                  rts

scale_init32:     lea      scale_line32(pc),a1
                  lea      scale_line32_trans(pc),a2

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
scale_line32_trans:
scale_line32:     movem.w  (a2),d2-d3
                  movem.w  3*2(a2),a2-a3

                  cmpa.w   a3,a2                            ;(a2 = Zielbreite) - (a3 = Quellbreite)
                  ble.s    shrink_line32                    ;verkleinern?

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
grow_line32:      move.l   (a0)+,d1                         ;Pixel einlesen
grow_line32_wr:   move.l   d1,(a1)+                         ;Pixel ausgeben
                  add.w    a3,d2                            ;+ ya, naechstes Zielpixel
                  bpl.s    grow_line32_next                 ;Fehler >= 0, naechstes Quellpixel?
                  dbra     d3,grow_line32_wr                ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
                  rts

grow_line32_next: sub.w    a2,d2                            ;- xa, naechstes Quellpixel
                  dbra     d3,grow_line32                   ;sind noch weitere Zielpixel vorhanden, muss ein Wort ausgegeben werden?
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
shrink_line32:    move.l   (a0)+,d1
                  add.w    a2,d3                            ;+ xa, naechstes Quellpixel
                  bpl.s    shrink_line32_nx                 ;Fehler >= 0, naechstes Zielpixel?
                  dbra     d2,shrink_line32                 ;sind noch weitere Quellpixel vorhanden?
                  move.l   d1,(a1)+
                  rts

shrink_line32_nx: move.l   d1,(a1)+
                  sub.w    a3,d3                            ;- ya, naechstes Zielpixel
                  dbra     d2,shrink_line32                 ;sind noch weitere Quellpixel vorhanden, muss evtl. ein Wort ausgegeben werden?
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
                  ext.l    d2
                  add.l    d2,d2
                  add.l    d2,d2                
                  adda.l   d2,a0                            ;Zieladresse
                  
                  tst.w    r_splanes(a6)                    ;32 Bit?
                  bne.s    write_line_init32
                  
                  moveq    #15,d0
                  and.w    d6,d0                            ;Anzahl der restlichen Pixel - 1
                  swap     d0
                  move.w   d6,d0
                  lsr.w    #4,d0                            ;Anzahl der Worte - 1
                  move.l   d0,(a2)+
                  
                  lea      c_palette(a6),a1
                  move.w   r_fgcol(a6),d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a1,d0.w),(a2)+                 ;Vordergrundfarbe
                  move.w   r_bgcol(a6),d0
                  add.w    d0,d0
                  add.w    d0,d0
                  move.l   0(a1,d0.w),(a2)+                 ;Hintergrundfarbe

                  moveq    #3,d0
                  and.w    r_wmode(a6),d0
                  add.w    d0,d0
                  move.w   wl_1_32_tab(pc,d0.w),d0          ;Offset der Funktion
                  lea      wl_1_32_tab(pc,d0.w),a1          ;Zeiger auf Ausgabefunktion
                  movem.l  (sp)+,d0-d3
                  rts

wl_1_32_tab:      DC.W  wl_1_32_repl-wl_1_32_tab
                  DC.W  wl_1_32_trans-wl_1_32_tab
                  DC.W  wl_1_32_eor-wl_1_32_tab
                  DC.W  wl_1_32_rev_trans-wl_1_32_tab
                  
write_line_init32:move.w   d6,(a2)+
                  moveq    #15,d0
                  and.w    r_wmode(a6),d0
                  
                  add.w    d0,d0
                  move.w   wl_32_32_tab(pc,d0.w),d0         ;Offset der Funktion
                  lea      wl_32_32_tab(pc,d0.w),a1         ;Zeiger auf Ausgabefunktion

                  movem.l  (sp)+,d0-d3
                  rts

wl_32_32_tab:     DC.W  wl_32_32_mode0-wl_32_32_tab
                  DC.W  wl_32_32_mode1-wl_32_32_tab
                  DC.W  wl_32_32_mode2-wl_32_32_tab
                  DC.W  wl_32_32_mode3-wl_32_32_tab
                  DC.W  wl_32_32_mode4-wl_32_32_tab
                  DC.W  wl_32_32_mode5-wl_32_32_tab
                  DC.W  wl_32_32_mode6-wl_32_32_tab
                  DC.W  wl_32_32_mode7-wl_32_32_tab
                  DC.W  wl_32_32_mode8-wl_32_32_tab
                  DC.W  wl_32_32_mode9-wl_32_32_tab
                  DC.W  wl_32_32_mode10-wl_32_32_tab
                  DC.W  wl_32_32_mode11-wl_32_32_tab
                  DC.W  wl_32_32_mode12-wl_32_32_tab
                  DC.W  wl_32_32_mode13-wl_32_32_tab
                  DC.W  wl_32_32_mode14-wl_32_32_tab
                  DC.W  wl_32_32_mode15-wl_32_32_tab
                              
;Zeile ausgeben, von 1 Bit auf 32 Bit expandieren, REPLACE
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_32_repl:     move.l   d4,a3                            ;d4 sichern
                  move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.l   (a2)+,d2                         ;Vordergrundfarbe
                  move.l   (a2)+,d3                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_32_rpl_end

wl_1_32_rpl_loop: move.w   (a0)+,d1
                  moveq    #15,d4

wl_1_32_rpl_word: add.w    d1,d1
                  bcc.s    wl_1_32_rpl_bg
                  move.l   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d4,wl_1_32_rpl_word
                  
                  dbra     d0,wl_1_32_rpl_loop
                  bra.s    wl_1_32_rpl_end

wl_1_32_rpl_bg:   move.l   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d4,wl_1_32_rpl_word
                  dbra     d0,wl_1_32_rpl_loop

wl_1_32_rpl_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_32_rpl_endfg:add.w    d1,d1
                  bcc.s    wl_1_32_rpl_endbg
                  move.l   d2,(a1)+                         ;Vordergrundfarbe
                  dbra     d0,wl_1_32_rpl_endfg

                  move.l   a3,d4
                  rts

wl_1_32_rpl_endbg:move.l   d3,(a1)+                         ;Hintergrundfarbe
                  dbra     d0,wl_1_32_rpl_endfg

                  move.l   a3,d4
                  rts

;Zeile ausgeben, von 1 Bit auf 32 Bit expandieren, TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_32_trans:    move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.l   (a2)+,d2                         ;Vordergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_32_trn_end

wl_1_32_trn_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_32_trn_word: add.w    d1,d1
                  bcc.s    wl_1_32_trn_bg
                  move.l   d2,(a1)                          ;Vordergrundfarbe
wl_1_32_trn_bg:   addq.l   #4,a1
                  dbra     d3,wl_1_32_trn_word
                  dbra     d0,wl_1_32_trn_loop

wl_1_32_trn_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_32_trn_endfg:add.w    d1,d1
                  bcc.s    wl_1_32_trn_endbg
                  move.l   d2,(a1)                          ;Vordergrundfarbe
wl_1_32_trn_endbg:addq.l   #4,a1
                  dbra     d0,wl_1_32_trn_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 32 Bit expandieren, EOR
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_32_eor:      move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_32_eor_end

wl_1_32_eor_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_32_eor_word: add.w    d1,d1
                  scs      d2
                  ext.w    d2
                  ext.l    d2
                  eor.l    d2,(a1)+
                  dbra     d3,wl_1_32_eor_word
                  dbra     d0,wl_1_32_eor_loop

wl_1_32_eor_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_32_eor_endfg:add.w    d1,d1
                  scs      d2
                  ext.w    d2
                  ext.l    d2
                  eor.l    d2,(a1)+
                  dbra     d0,wl_1_32_eor_endfg

                  rts

;Zeile ausgeben, von 1 Bit auf 32 Bit expandieren, REVERS TRANSPARENT
;Vorgaben:
;Register d0-d3/a0-a2 werden veraendert
;Eingaben:
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Zeiger auf den Parameter-Buffer
;Ausgaben:
;-
wl_1_32_rev_trans:move.l   (a2)+,d0                         ;Anzahl der restlichen Pixel - 1 / Anzahl der Worte
                  move.l   4(a2),d2                         ;Hintergrundfarbe
                  subq.w   #1,d0                            ;mindestens 1 Wort?
                  bmi.s    wl_1_32_rtr_end

wl_1_32_rtr_loop: move.w   (a0)+,d1
                  moveq    #15,d3

wl_1_32_rtr_word: add.w    d1,d1
                  bcs.s    wl_1_32_rtr_fg
                  move.l   d2,(a1)+                         ;Hintergrundfarbe
wl_1_32_rtr_fg:   addq.l   #4,a1
                  dbra     d3,wl_1_32_rtr_word
                  dbra     d0,wl_1_32_rtr_loop

wl_1_32_rtr_end:  swap     d0
                  move.w   (a0)+,d1

wl_1_32_rtr_endbg:add.w    d1,d1
                  bcs.s    wl_1_32_rtr_endfg
                  move.l   d2,(a1)                          ;Hintergrundfarbe
wl_1_32_rtr_endfg:addq.l   #4,a1
                  dbra     d0,wl_1_32_rtr_endbg

                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Zeile ausgeben, Modus 0 (ALL_ZERO)
wl_32_32_mode0:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #0,d1
wl_32_32_m0_loop: move.l   d1,(a1)+
                  dbra     d0,wl_32_32_m0_loop
                  rts

;Zeile ausgeben, Modus 1 (S_AND_D)
wl_32_32_mode1:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m1_loop: move.l   (a0)+,d1
                  and.l    d1,(a1)+
                  dbra     d0,wl_32_32_m1_loop
                  rts

;Zeile ausgeben, Modus 2 (S_AND_NOT_D)
wl_32_32_mode2:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m2_loop: move.l   (a0)+,d1
                  not.l    (a1)
                  and.l    d1,(a1)+
                  dbra     d0,wl_32_32_m2_loop
                  rts

;Zeile ausgeben, Modus 3 (S_ONLY)
wl_32_32_mode3:   move.w   (a2)+,d0
wl_32_32_m3_loop: move.l   (a0)+,(a1)+
                  dbra     d0,wl_32_32_m3_loop
                  rts

;Zeile ausgeben, Modus 4 (NOT_S_AND_D)
wl_32_32_mode4:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m4_loop: move.l   (a0)+,d1
                  not.l    d1
                  and.l    d1,(a1)+
                  dbra     d0,wl_32_32_m4_loop
                  rts

;Zeile ausgeben, Modus 5 (D_ONLY)
wl_32_32_mode5:   rts                                       ;keine Ausgaben

;Zeile ausgeben, Modus 6 (S_EOR_D)
wl_32_32_mode6:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m6_loop: move.l   (a0)+,d1
                  eor.l    d1,(a1)+
                  dbra     d0,wl_32_32_m6_loop
                  rts

;Zeile ausgeben, Modus 7 (S_OR_D)
wl_32_32_mode7:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m7_loop: move.l   (a0)+,d1
                  or.l     d1,(a1)+
                  dbra     d0,wl_32_32_m7_loop
                  rts

;Zeile ausgeben, Modus 8 (NOT_(S_OR_D))
wl_32_32_mode8:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m8_loop: move.l   (a0)+,d1
                  or.l     d1,(a1)
                  not.l    (a1)+
                  dbra     d0,wl_32_32_m8_loop
                  rts

;Zeile ausgeben, Modus 9 (NOT_(S_EOR_D))
wl_32_32_mode9:   move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m9_loop: move.l   (a0)+,d1
                  eor.l    d1,(a1)
                  not.l    (a1)+
                  dbra     d0,wl_32_32_m9_loop
                  rts

;Zeile ausgeben, Modus 10 (NOT_D)
wl_32_32_mode10:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m10_loop:not.l    (a1)+
                  dbra     d0,wl_32_32_m10_loop
                  rts

;Zeile ausgeben, Modus 11 (S_OR_NOT_D)
wl_32_32_mode11:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m11_loop:move.l   (a0)+,d1
                  not.l    (a1)
                  or.l     d1,(a1)+
                  dbra     d0,wl_32_32_m11_loop
                  rts

;Zeile ausgeben, Modus 12 (NOT_S)
wl_32_32_mode12:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m12_loop:move.l   (a0)+,d1
                  not.l    d1
                  move.l   d1,(a1)+
                  dbra     d0,wl_32_32_m12_loop
                  rts

;Zeile ausgeben, Modus 13 (NOT_S_OR_D)
wl_32_32_mode13:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m13_loop:move.l   (a0)+,d1
                  not.l    d1
                  or.l     d1,(a1)+
                  dbra     d0,wl_32_32_m13_loop
                  rts

;Zeile ausgeben, Modus 14 (NOT_(S_AND_D))
wl_32_32_mode14:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
wl_32_32_m14_loop:move.l   (a0)+,d1
                  and.l    d1,(a1)
                  not.l    (a1)+
                  dbra     d0,wl_32_32_m14_loop
                  rts

;Zeile ausgeben, Modus 15  (ALL_ONE)
wl_32_32_mode15:  move.w   (a2),d0                          ;Anzahl der Pixel - 1
                  moveq    #$ffffffff,d1
wl_32_32_m15_loop:move.l   d1,(a1)+
                  dbra     d0,wl_32_32_m15_loop
                  rts
ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dummy:            rts
                  DATA
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;Relozierungs-Information'
relokation:
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
                  ;Laufzeitdaten'

                  BSS

cpu040:           DS.W 1                  ;Prozessortyp

nvdi_struct:      DS.L 1                  ;Zeiger auf nvdi_struct oder 0

;Farbumwandlungstabelle fuer 256 Farben
color_map:        DS.B 256

expand_tab:       DS.B 32*256

rgb_in_tab:       DS.B  3006              ;UBYTE   rgb_in_tab[3][1002];
rgb_out_tab:      DS.W  768               ;UWORD   rgb_out_tab[3][256];

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                  END
