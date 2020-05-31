;VDI-Ausgabefunktionen
;letzte Aenderung am 12.06.94

;pts_start-Struktur
nxt_ptsin         EQU 0                   ;zeigt auf die naechsten ptsin-Elemente
x_start           EQU 4                   ;X-Startkoordinate fuer die Linie
y_start           EQU 6                   ;Y-Startkoordinate fuer die Linie
x_end             EQU 8                   ;X-Endkoordinate fuer die Linie
y_end             EQU 10                  ;Y-Endkoordinate fuer die Linie
n_pts             EQU 12                  ;nach Abtesten des ptsin[] aktuelle Koord.zahl
_dx               EQU 14
_dy               EQU 16
_dx_sign          EQU 18                  ;Vorzeichen: 0 pos, -1 neg.
_dy_sign          EQU 20
ptsin_chgd        EQU 22                  ;Flag: ptsin-Koord. geaendert: Bit 0 Startk., Bit 1 Endk.

;Dicke v_plines mit Start- und Endstil zeichnen
;Vorgaben:
;Register d0/a0-a1 werden veraendert
;Innerhalb der Routinen gelten die TC-Konventionen
;Eingaben:
;a0.l pb
;a6.l Workstation
;Ausgaben:
;-
v_pline_thick:    movem.l  d1-d5/a2-a5,-(sp)

                  lea.l    -24(sp),sp
                  movea.l  sp,a3          ;Zeiger auf pts_start-Struktur
                  movea.l  a0,a2          ;pb sichern
                  move.l   pb_ptsin(a2),(a3) ;nxt_ptsin
                  movea.l  (a2),a0        ;contrl
                  move.w   n_ptsin(a0),n_pts(a3)

                  moveq.l  #0,d3          ;Voreinst.: ptsin unveraendert

                  tst.w    l_start(a6)
                  beq.s    no_startfm

                  move.w   n_ptsin(a0),d0
                  movea.l  pb_ptsin(a2),a0
                  movea.l  a3,a1

                  bsr      dr_startfm

                  moveq.l  #1,d3          ;ptsin[0/1] veraendert
                  movea.l  pb_ptsin(a2),a5
                  movea.l  (a3),a4        ;nxt_ptsin
                  cmpa.l   a4,a5          ;zeigen beide auf 1. ptsin-Paar ?
                  beq.s    first_ptsin    ;ja
                  subq.l   #4,a4          ;Koord.-paar vor nxt_ptsin[] sichern
                  move.l   a4,(a3)        ;ptsin-Start fuer fat_line()

first_ptsin:      move.l   (a4),d4        ;x1,y1 sichern
                  move.l   x_start(a3),(a4) ;aus pts_start in ptsin kopieren

no_startfm:       tst.w    l_end(a6)
                  beq.s    no_endfm

                  movea.l  (a2),a0        ;contrl
                  move.w   n_ptsin(a0),d0
                  movea.l  pb_ptsin(a2),a0
                  movea.l  a3,a1

                  bsr      dr_endfm

                  addq.w   #2,d3          ;ptsin[n-1/n] veraendert
                  movea.l  (a2),a0        ;contrl
                  move.w   n_ptsin(a0),d0
                  subq.w   #1,d0
                  ext.l    d0
                  asl.l    #2,d0          ;*4
                  movea.l  pb_ptsin(a2),a5
                  adda.l   d0,a5
                  move.l   (a5),d5        ;xn,yn sichern
                  move.l   x_end(a3),(a5) ;aus pts_start in ptsin kopieren

no_endfm:         move.w   n_pts(a3),d0
                  movea.l  (a3),a0        ;aktuelles ptsin

                  bsr.s    fat_line

                  tst.w    d3
                  beq.s    exit_vplth

                  btst     #0,d3
                  beq.s    _rest_xyn
                  move.l   d4,(a4)        ;alte Startpos. zurueck

_rest_xyn:        btst     #1,d3
                  beq.s    exit_vplth
                  move.l   d5,(a5)        ;alte Endpos. zurueck

exit_vplth:       lea.l    24(sp),sp      ;Stack korrigieren
                  movem.l  (sp)+,d1-d5/a2-a5
                  rts

;
; small_line zeichnet 1 Pixel dicke Linien ohne Effekte
;
;a0.l ptsin
;d0.w n_ptsin
;
small_line:       movem.l  d1-d7/a2-a3,-(sp)
                  movea.l  a0,a3          ;ptsin
                  move.w   d0,d4
                  subq.w   #2,d4          ;Linienzaehler
                  bpl      v_plines_in
                  movem.l  (sp)+,d1-d7/a2-a3
                  rts
;
; fat_line zeichnet nur Linien ohne Effekte
;
; a0: ptsin
; d0: n_ptsin
;
fat_line:         cmpi.w   #1,l_width(a6) ;Sonderbehandlung
                  beq.s    small_line     ;Linie mit 1 Pix Dicke

                  movem.l  d3-d6/a2-a4,-(sp)

                  subq.w   #2,d0
                  bmi.s    exit_fat_line

                  lea.l    -16(sp),sp     ;int[8]
                  movea.l  sp,a4          ;*PTS_RECT

                  movea.l  a0,a2
                  move.w   d0,d3          ;sichern

                  tst.w    res_ratio(a6)
                  beq.s    fat_qpix       ;qu. Pixel, keine Transf. notwendig

                  lea.l    -8(sp),sp      ;int[4]
                  movea.l  sp,a3          ;*tmp_pts

                  move.w   l_width(a6),d6
                  move.w   d6,d4          ;x_radius
                  cmpi.w   #1,res_ratio(a6)
                  bne.s    _fat_STMID

                  move.w   d4,d5          ;y_radius
                  asr.w    #1,d4
                  add.w    d6,d6
                  bra.s    fat_TT_LOW

_fat_STMID:       asr.w    #1,d4
                  move.w   d4,d5
                  asr.w    #1,d5

fat_TT_LOW:       movea.l  a2,a0          ;ptsin
                  movea.l  a3,a1          ;tmp_pts
                  bsr      conv_pix2q     ;Auf qu. Pixel umrechnen

                  movea.l  a3,a0          ;tmp_pts
                  movea.l  a4,a1          ;PTS_RECT
                  move.w   d6,d0          ;Liniendicke
                  bsr      calc_line

                  movea.l  a4,a0          ;PTS_RECT: Source
                  movea.l  a0,a1          ;Destination
                  bsr      conv_q2pix     ;auf Bildschirm zurueckrechnen

                  moveq.l  #4,d0
                  movea.l  a4,a0          ;PTS_RECT
                  bsr      v_fillline
                  addq.l   #4,a2          ;naechstes Koordinatenpaar

                  cmpi.w   #3,l_width(a6) ;Linie dicker als 3 Pixel?
                  ble.s    _fat_while     ;nein

                  tst.w    d3
                  ble.s    _fat_while

                  move.w   d3,-(sp)       ;Zaehler sichern
                  movem.w  (a2),d0-d1     ;x-start,y-start

                  move.w   d4,d2          ;x_radius
                  move.w   d5,d3          ;y_radius
                  bsr      v_fillpie
                  move.w   (sp)+,d3

_fat_while:       dbra     d3,fat_TT_LOW  ;bis n_ptsin < 2
                  lea.l    8+16(sp),sp    ;Stack korrigieren
exit_fat_line:    movem.l  (sp)+,d3-d6/a2-a4
                  rts

;
; Quadratische Pixel
;
fat_qpix:         move.w   l_width(a6),d4

_fat_qpix:        movea.l  a2,a0          ;ptsin
                  movea.l  a4,a1          ;PTS_RECT
                  move.w   d4,d0          ;Liniendicke
                  bsr      calc_line

                  moveq.l  #4,d0          ;ptsin-Eintraege
                  movea.l  a4,a0          ;PTS_RECT
                  bsr      v_fillline
                  addq.l   #4,a2          ;naechste Koordinatenpaar

                  cmp.w    #3,d4          ;Linie dicker als 3 Pixel?
                  ble.s    _fat_qwhile    ;nein

                  tst.w    d3
                  ble.s    _fat_qwhile

                  move.w   d3,-(sp)       ;Zaehler sichern
                  movem.w  (a2),d0-d1     ;x-start,y-start
                  move.w   d4,d3
                  asr.w    #1,d3          ;y_radius
                  move.w   d3,d2          ;x_radius
                  bsr      v_fillpie
                  move.w   (sp)+,d3

_fat_qwhile:      dbra     d3,_fat_qpix   ;bis n_ptsin < 2
                  lea.l    16(sp),sp      ;Stack korrigieren
                  movem.l  (sp)+,d3-d6/a2-a4
                  rts

;
; Gegebene Koordinaten in ein 'virtuelles' Bild mit quadratischen
; Pixeln umrechnen
;
; a0: *src
; a1: *dst
conv_pix2q:       move.w   res_ratio(a6),d0
                  cmpi.w   #-1,d0
                  bne.s    _pix2q_TTLOW

                  move.l   (a0)+,d0       ;x1, y1

                  add.w    d0,d0          ;y1 * 2
                  move.l   d0,(a1)+

                  move.l   (a0)+,d0       ;x2, y2
                  add.w    d0,d0          ;y2 * 2
                  move.l   d0,(a1)
                  rts

_pix2q_TTLOW:     cmp.w    #1,d0
                  bne.s    exit_pix2q

                  move.w   (a0)+,d0       ;x1
                  add.w    d0,d0          ;x1 * 2
                  move.w   d0,(a1)+
                  move.l   (a0)+,d0       ;y1, x2
                  add.w    d0,d0          ;x2 * 2
                  move.l   d0,(a1)+
                  move.w   (a0),(a1)      ;y2

exit_pix2q:       rts

;
; Vier errechnete Koordinaten des 'virtuellen' Bildes entsprechend den
; reellen Pixelgroessen zurueckrechnen
;
; a0: *src
; a1: *dst
conv_q2pix:       move.w   res_ratio(a6),d0
                  cmpi.w   #-1,d0
                  bne.s    _q2pix_TTLOW

                  move.l   (a0)+,d0       ;x1, y1
                  asr.w    #1,d0          ;y1 / 2
                  move.l   d0,(a1)+

                  move.l   (a0)+,d0       ;x2, y2
                  asr.w    #1,d0          ;y2 / 2
                  move.l   d0,(a1)+

                  move.l   (a0)+,d0       ;x3, y3
                  asr.w    #1,d0          ;y3 / 2
                  move.l   d0,(a1)+

                  move.l   (a0)+,d0       ;x4, y4
                  asr.w    #1,d0          ;y4 / 2
                  move.l   d0,(a1)
                  rts

_q2pix_TTLOW:     cmp.w    #1,d0
                  bne.s    exit_q2pix

                  move.w   (a0)+,d0       ;x1
                  asr.w    #1,d0          ;x1 / 2
                  move.w   d0,(a1)+
                  move.l   (a0)+,d0       ;y1, x2
                  asr.w    #1,d0          ;x2 / 2
                  move.l   d0,(a1)+
                  move.l   (a0)+,d0       ;y2, x3
                  asr.w    #1,d0          ;x3 / 2
                  move.l   d0,(a1)+
                  move.l   (a0)+,d0       ;y3, x4
                  asr.w    #1,d0          ;x4 / 2
                  move.l   d0,(a1)+
                  move.w   (a0),(a1)      ;y4
exit_q2pix:       rts

;
; Berechne die vier Eckpunkte einer dicken Linie
;
; a0: *ptsin
; a1: *PTS_RECT
; d0: l_width
;
calc_line:        movem.l  d3-d7/a2-a3,-(sp)
                  move.w   d0,d3          ;Liniendicke
                  movea.l  a0,a2

                  movea.l  a1,a3          ;sichern

                  move.w   (a0)+,d1       ;ptsin[0]
                  ext.l    d1
                  move.w   (a0)+,d2       ;ptsin[1]
                  ext.l    d2
                  move.w   (a0)+,d0       ;ptsin[2]
                  ext.l    d0
                  sub.l    d1,d0          ;dx
                  move.w   (a0)+,d1       ;ptsin[3]
                  ext.l    d1
                  sub.l    d2,d1          ;dy

                  move.l   d0,d6          ;dx sichern
                  move.l   d1,d7          ;dy sichern
                  tst.l    d0
                  bpl.s    calc_dx_pos    ;Betraege bilden
                  neg.l    d0

calc_dx_pos:      tst.l    d1
                  bpl.s    calc_dy_pos
                  neg.l    d1

calc_dy_pos:      move.l   d0,d4          ;Betraege sichern
                  move.l   d1,d5

                  cmp.w    #255,d4
                  bgt.s    gross_hyp
                  cmp.w    #255,d5
                  bgt.s    gross_hyp
; dx,dy -> Hypothenuse klein. Also hochshiften, um Genauigkeit zu vergroessern
                  lsl.w    #7,d5
                  lsl.w    #7,d4
                  move.w   d4,d0
                  move.w   d5,d1

gross_hyp:        bsr.s    hypot          ;Hypothenuse in d0.l zurueck

                  mulu.w   d3,d5          ;dy * l_width = t_x
                  mulu.w   d3,d4          ;dx * l_width = t_y

                  divu.w   d0,d5          ;t_x/hyp = t_x
                  lsr.w    #1,d5
                  ext.l    d5

                  tst.l    d7             ;war dy pos. ?
                  bpl.s    calc_dx_was
                  neg.l    d5

calc_dx_was:      divu.w   d0,d4          ;t_y/hyp = t_y
                  lsr.w    #1,d4
                  ext.l    d4

                  tst.l    d6             ;war dx pos. ?
                  bpl.s    calc_dy_was
                  neg.l    d4

calc_dy_was:      movea.l  a2,a0          ;ptsin
                  move.w   (a0)+,d0       ;ptsin[0]
                  sub.w    d5,d0          ;- t_x
                  move.w   (a0)+,d1       ;ptsin[1]
                  add.w    d4,d1          ;+ t_y
                  move.w   (a2)+,d2       ;ptsin[0]
                  add.w    d5,d2          ;+ t_x
                  move.w   (a2)+,d3       ;ptsin[1]
                  sub.w    d4,d3          ;- t_y
                  movem.w  d0-d3,(a3)

                  addq.l   #8,a3

                  move.w   (a0)+,d0       ;ptsin[2]

                  add.w    d5,d0          ;+ t_x
                  move.w   (a0),d1        ;ptsin[3]
                  sub.w    d4,d1          ;- t_y
                  move.w   (a2)+,d2       ;ptsin[2]
                  sub.w    d5,d2          ;- t_x
                  move.w   (a2),d3        ;ptsin[3]
                  add.w    d4,d3          ;+ t_y
                  movem.w  d0-d3,(a3)
                  movem.l  (sp)+,d3-d7/a2-a3
                  rts

;
; Berechnung der Hypothenuse
;
; d0.w: (UNSIGNED) dx
; d1.w: (UNSIGNED) dy
; liefert Hypothenuse in d0.l
;
hypot:            move.l   d3,-(sp)
                  mulu.w   d0,d0          ;A*A
                  mulu.w   d1,d1          ;B*B
                  add.l    d0,d1          ;=x
                  bne.s    sqrt           ;x <> 1
;x = 0 abfangen
                  moveq.l  #1,d0 ; WTF? sqrt(0) = 1?
                  addq.l   #4,sp
                  rts

sqrt:             moveq.l  #0,d0          ;xroot
                  move.l   #$10000000,d2  ;m2

lblA:             move.l   d0,d3          ;x2 = xroot +
                  add.l    d2,d3          ;     + m2
                  lsr.l    #1,d0          ;xroot/2

                  cmp.l    d3,d1          ;x2 =< x ?
                  bcs.s    lbl18          ;nein
                  sub.l    d3,d1          ;x -= x2
                  add.l    d2,d0          ;xroot += m2

lbl18:            lsr.l    #2,d2          ;m2 / 4
                  bne.s    lblA           ;> 0

                  cmp.l    d0,d1          ;xroot < x ?
                  bls.s    exit_hypot     ;nein
                  addq.l   #1,d0          ;xroot += 1

exit_hypot:       move.l   (sp)+,d3
                  rts
;
; Zeichne Anfang der Linie mit Kreis oder Pfeil
;
; a0: *ptsin
; a1: &pts_start, zeigt auf die Struktur, die nachher auf aktuellen
;                 Start von ptsin[], x_start, y_start und n_pts weist
; d0: n_ptsin
;
dr_startfm:       movem.l  d3-d7/a2-a3,-(sp)
                  movea.l  a0,a2
                  movea.l  a1,a3
                  move.w   d0,d3          ;sichern

                  move.w   l_start(a6),d0
                  cmp.w    #ROUND,d0
                  bne.s    _strtfm_ARR

;               move.w  d3,n_pts(a3)
                  move.l   (a2),x_start(a3) ;x_start=ptsin[0], y_start=ptsin[1]

                  move.w   l_width(a6),d2
                  cmp.w    #3,d2          ;Linie mit 1 Pixel Dicke
                  ble.s    exit_strtfm    ;Kreisfunktion nicht aufrufen

                  asr.w    #1,d2          ;x_radius
                  move.w   d2,d3          ;y_radius

                  tst.w    res_ratio(a6)
                  beq.s    _strt_ell
                  bpl.s    _st_ell_TT
                  asr.w    #1,d3          ;ST-MID Hoehe  halbieren
                  bra.s    _strt_ell

_st_ell_TT:       asl.w    #1,d3          ;TT-LOW Hoehe verdoppeln

_strt_ell:        movem.w  (a2),d0-d1     ;x- , y-Start

                  bsr      v_fillpie
exit_strtfm:      movem.l  (sp)+,d3-d7/a2-a3
                  rts

_strtfm_ARR:      cmp.w    #ARROW,d0
                  bne.s    exit_strtfm
                  move.w   d3,d0          ;a0, a1 siehe oben
                  bsr      tstlin_fwd

                  move.w   _dx(a3),d0
                  move.w   _dy(a3),d1
                  bsr      hypot          ;Hypothenus in d0.l

                  move.w   l_width(a6),d2
                  cmp.w    #1,d2          ;dicker als 1 Pixel?
                  bgt.s    _strtfm_TTl
                  moveq.l  #9,d2          ;Pfeilhoehe 9 Pixel vorgeben
                  bra.s    _strtfm_calc

_strtfm_TTl:                              ; cmpi.w  #TT_LOWRES,res_ratio(a6)
; bne.s   _strtfm
                  tst.w    res_ratio(a6)
                  ble.s    _strtfm

                  add.w    d2,d2          ;in TT-LOW Liniendicke verdoppeln

_strtfm:          move.w   d2,d3
                  add.w    d2,d2
                  add.w    d3,d2          ;l_width * 3

_strtfm_calc:     move.w   d2,d3
                  mulu.w   _dx(a3),d2     ;dx * l_width * 3
                  mulu.w   _dy(a3),d3     ;dy * l_iwdth * 3
                  divu.w   d0,d2          ;= t_x
                  divu.w   d0,d3          ;= t_y

                  tst.w    _dx_sign(a3)
                  beq.s    strt_dx_pos
                  neg.w    d2             ;t_x negieren

strt_dx_pos:      tst.w    _dy_sign(a3)
                  beq.s    strt_dy_pos
                  neg.w    d3             ;t_y negieren

strt_dy_pos:      lea.l    -16(sp),sp     ;int[8]
                  movea.l  sp,a0          ;*PTS_RECT

                  move.w   (a2)+,d0       ;ptsin[0]
                  move.w   (a2),d1        ;ptsin[1]

                  tst.w    res_ratio(a6)  ;muss auf virtuellen Schirm
                  beq.s    _strt_qpix
                  bmi.s    _strt_STMID
;also liegt TT-LOW vor
                  add.w    d0,d0
                  bra.s    _strt_qpix

_strt_STMID:      add.w    d1,d1          ;y * 2

_strt_qpix:       move.w   d0,(a0)+       ;x1
                  move.w   d1,(a0)+       ;y1
                  add.w    d2,d0          ;= x_start
                  add.w    d3,d1          ;= y_start
                  move.w   d0,d6
                  move.w   d1,d7

                  move.w   d0,d4          ;... x3
                  move.w   d1,d5          ;... y3

                  asr.w    #1,d2          ;t_x / 2
                  asr.w    #1,d3          ;t_y / 2
                  add.w    d3,d0          ;= x2
                  sub.w    d2,d1          ;= y2
                  sub.w    d3,d4          ;= x3
                  add.w    d2,d5          ;= y3

                  movem.w  d0-d1/d4-d7,(a0) ;in Struktur eintragen

                  movea.l  sp,a0
                  movea.l  a0,a1
                  bsr      conv_q2pix     ;auf Bildschirmpixel zurueck

                  moveq.l  #3,d0
                  movea.l  sp,a0

                  move.l   12(a0),x_start(a3) ;konvertierte Startkoord. sichern

                  bsr      v_fillline

                  lea.l    16(sp),sp      ;Stack korrigieren
                  movem.l  (sp)+,d3-d7/a2-a3
                  rts
;
; Zeichne Ende der Linie mit Kreis oder Pfeil
;
; a0: *ptsin
; a1: &pts_start, zeigt auf die Struktur, die nachher auf aktuellen
;                 Start von ptsin[], x_end, y_end und n_pts weist
; d0: n_ptsin
;
dr_endfm:         movem.l  d3-d7/a2-a3,-(sp)
                  move.w   d0,d3

                  subq.w   #1,d0

                  ext.l    d0
                  asl.l    #2,d0          ;*4
                  adda.l   d0,a0          ;auf das letzte Koord.-paar im ptsin

                  movea.l  a0,a2
                  movea.l  a1,a3          ;sichern
                  move.w   l_end(a6),d0
                  cmp.w    #ROUND,d0
                  bne.s    _endfm_ARR

                  move.l   (a0),x_end(a3)

                  move.w   l_width(a6),d2
                  cmp.w    #3,d2          ;Linie mit 1 Pixel Dicke
                  ble.s    exit_endfm     ;Kreisfunktion nicht aufrufen

                  asr.w    #1,d2          ;x_radius
                  move.w   d2,d3          ;y_radius

                  tst.w    res_ratio(a6)
                  beq.s    _end_ell
                  bpl.s    _end_ell_TT
                  asr.w    #1,d3          ;ST-MID Hoehe  halbieren
                  bra.s    _end_ell

_end_ell_TT:      asl.w    #1,d3          ;TT-LOW Hoehe verdoppeln

_end_ell:         move.w   (a0)+,d0       ;x-Start
                  move.w   (a0)+,d1       ;y-Start
                  bsr      v_fillpie

exit_endfm:       movem.l  (sp)+,d3-d7/a2-a3
                  rts

_endfm_ARR:       cmp.w    #ARROW,d0
                  bne.s    exit_endfm

                  move.w   n_pts(a1),d0   ;a0, a1 siehe oben
                  bsr      tstlin_bk

                  move.w   _dx(a3),d0
                  move.w   _dy(a3),d1
                  bsr      hypot          ;Hypothenus in d0.l

                  move.w   l_width(a6),d2
                  cmp.w    #1,d2          ;dicker als 1 Pixel?
                  bgt.s    _endfm_TTl
                  moveq.l  #9,d2          ;Pfeilhoehe 9 Pixel vorgeben
                  bra.s    _endfm_calc

_endfm_TTl:                               ;  cmpi.w  #TT_LOWRES,res_ratio(a6)
;                bne.s   _endfm
                  tst.w    res_ratio(a6)
                  ble.s    _endfm

                  add.w    d2,d2          ;in TT-LOW Liniendicke verdoppeln

_endfm:           move.w   d2,d3
                  add.w    d2,d2
                  add.w    d3,d2          ;l_width * 3
_endfm_calc:      move.w   d2,d3
                  mulu.w   _dx(a3),d2     ;dx * l_width * 3
                  mulu.w   _dy(a3),d3     ;dy * l_iwdth * 3
                  divu.w   d0,d2          ;= t_x
                  divu.w   d0,d3          ;= t_y

                  tst.w    _dx_sign(a3)
                  beq.s    end_dx_pos
                  neg.w    d2             ;t_x negieren

end_dx_pos:       tst.w    _dy_sign(a3)
                  beq.s    end_dy_pos
                  neg.w    d3             ;t_y negieren

end_dy_pos:       lea.l    -16(sp),sp     ;int[8]
                  movea.l  sp,a0          ;*PTS_RECT

                  move.w   (a2)+,d0
                  move.w   (a2),d1

                  tst.w    res_ratio(a6)  ;muss auf virtuellen Schirm
                  beq.s    _end_qpix
                  bmi.s    _end_STMID
;also liegt TT-LOW vor
                  add.w    d0,d0          ;x * 2
                  bra.s    _end_qpix

_end_STMID:       add.w    d1,d1          ;y * 2

_end_qpix:        move.w   d0,(a0)+       ;xn
                  move.w   d1,(a0)+       ;yn
                  add.w    d2,d0          ;= x_end
                  add.w    d3,d1          ;= y_end
                  move.w   d0,d6
                  move.w   d1,d7

                  move.w   d0,d4          ;... x3
                  move.w   d1,d5          ;... y3

                  asr.w    #1,d2          ;t_x / 2
                  asr.w    #1,d3          ;t_y / 2
                  add.w    d3,d0          ;= x2
                  sub.w    d2,d1          ;= y2
                  sub.w    d3,d4          ;= x3
                  add.w    d2,d5          ;= y3

                  movem.w  d0-d1/d4-d7,(a0) ;in Struktur eintragen

                  movea.l  sp,a0
                  movea.l  a0,a1
                  bsr      conv_q2pix     ;auf Bildschirmpixel zurueck

                  moveq.l  #3,d0
                  movea.l  sp,a0
                  move.l   12(a0),x_end(a3) ;konvertierte Endkoord. sichern

                  bsr      v_fillline

                  lea.l    16(sp),sp      ;Stack korrigieren
                  movem.l  (sp)+,d3-d7/a2-a3
                  rts

;
; a0: *ptsin
; a1: *pts_start
; d0: n_ptsin
tstlin_fwd:       movem.l  d3-d7,-(sp)
                  move.w   d0,d5          ;sichern
; Vorbesetzung der pts_start-Struktur fuer den etwaigen Fehlerfall
                  move.l   a0,(a1)        ;nxt_ptsin
                  move.w   d0,n_pts(a1)

                  move.w   l_width(a6),d4
                  add.w    d4,d4
                  add.w    l_width(a6),d4 ;Liniendicke * 3
                  ext.l    d4             ;Vergleichswert

                  movem.w  (a0)+,d0-d1    ;x1,y1 VORZEICHENERWEITERT
                  subq.w   #2,d5

_fwd_loop:        moveq.l  #0,d6          ;dx/dy- Vorzeichn pos.
                  moveq.l  #0,d7

                  movem.w  (a0)+,d2-d3    ;xn,yn
                  sub.l    d0,d2          ;dx
                  bpl.s    _fwd_posdx
                  neg.l    d2             ;positiv machen
                  moveq.l  #-1,d6         ;dx-Vorzeichen neg.
_fwd_posdx:
                  sub.l    d1,d3          ;dy
                  bpl.s    _fwd_posdy
                  neg.l    d3
                  moveq.l  #-1,d7         ;dy-Vorzeichen neg.


; Jetzt ein ausreichend grosses dx, dy finden, damit die Pfeilrichtung
; vernuenftig ermittelt werden kann
_fwd_posdy:
                  cmp.l    d4,d2
                  bge.s    _fwd_found     ;dx >= Vergleichswert

                  cmp.l    d4,d3
                  bge.s    _fwd_found     ;dy >= Vergleichswert

_fwd_cntr:        dbra     d5,_fwd_loop
                  addq.w   #1,d5

_fwd_found:       subq.l   #4,a0          ;letzte Pos. des ptsin-Zeigers
                  move.l   a0,(a1)

                  move.w   res_ratio(a6),d0 ;ggf. Steigung auf 'virtuelles Bild' umrechnen
;                cmpi.w  #ST_MIDRES,d0
;                bne.s   _fwd_TTLOW
                  bpl.s    _fwd_TTLOW

                  add.w    d3,d3          ;_dy * 2
                  bra.s    exit_fwd

_fwd_TTLOW:
;                cmp.w   #TT_LOWRES,d0
;                bne.s   exit_fwd
                  ble.s    exit_fwd

                  add.w    d2,d2          ;_dx * 2

exit_fwd:         movem.w  d2-d3/d6-d7,_dx(a1) ;_dx/_dy und dx/dy-Vorzeichen eintragen
                  addq.w   #2,d5
                  move.w   d5,n_pts(a1)
                  movem.l  (sp)+,d3-d7
                  rts

;
; a0: *ptsin; hier: Zeiger auf das LETZTE ptsin-Paar !
; a1: *pts_start
; d0.w: n_ptsin
tstlin_bk:        movem.l  d3-d7,-(sp)
                  move.w   d0,d5          ;sichern

                  move.w   l_width(a6),d4
                  add.w    d4,d4
                  add.w    l_width(a6),d4 ;Liniendicke * 3
                  ext.l    d4             ;Vergleichswert

                  movem.w  (a0),d0-d1     ;x1, y1 VORZEICHENERWEITERT
                  subq.w   #2,d5

_bk_loop:         moveq.l  #0,d6          ;dx/dy- Vorzeichn pos.
                  moveq.l  #0,d7

                  subq.l   #4,a0
                  movem.w  (a0),d2-d3     ;xn,yn VORZEICHENERWEITERT
                  sub.l    d0,d2          ;dx
                  bpl.s    _bk_posdx
                  neg.l    d2             ;positiv machen
                  moveq.l  #-1,d6         ;dx-Vorzeichen neg.
_bk_posdx:
                  sub.l    d1,d3          ;dy
                  bpl.s    _bk_posdy
                  neg.l    d3
                  moveq.l  #-1,d7         ;dy-Vorzeichen neg.

; Jetzt ein ausreichend grosses dx, dy finden, damit die Pfeilrichtung
; vernuenftig ermittelt werden kann
_bk_posdy:
                  cmp.l    d4,d2
                  bge.s    _bk_found      ;dx >= Vergleichswert

                  cmp.l    d4,d3
                  bge.s    _bk_found      ;dy >= Vergleichswert

_bk_cntr:         dbra     d5,_bk_loop
                  addq.w   #1,d5

_bk_found:        move.w   res_ratio(a6),d0 ;ggf. Steigung auf 'virtuelles Bild' umrechnen
;                cmpi.w  #ST_MIDRES,d0
;                bne.s   _bk_TTLOW
                  bpl.s    _bk_TTLOW

                  add.w    d3,d3          ;_dy * 2
                  bra.s    exit_bk

_bk_TTLOW:
;                cmp.w   #TT_LOWRES,d0
;                bne.s   exit_bk
                  ble.s    exit_bk

                  add.w    d2,d2          ;_dx * 2

exit_bk:          movem.w  d2-d3/d6-d7,_dx(a1) ;_dx/_dy und dx/dy-Vorzeichen eintragen
                  addq.w   #2,d5
                  move.w   d5,n_pts(a1)
                  movem.l  (sp)+,d3-d7
                  rts

v_pline_eff:      tst.w    n_intin(a1)    ;bezarr vorhanden?
                  beq      v_pline_thick
                  cmpi.w   #13,opcode2(a1) ;Bezier-Aufruf?
                  beq      v_bez
                  tst.w    bez_on(a6)
                  bne      v_bez
                  bra      v_pline_thick  ;Linie

; POLYLINE (VDI 6)
v_pline:          movea.l  pb_control(a0),a1
                  movep.w  l_start+1(a6),d0 ;Linienendstile ?
                  add.w    l_width(a6),d0 ;breite Linie?
                  add.w    n_intin(a1),d0 ;bezarr vorhanden?
                  subq.w   #1,d0          ;irgendwelche Effekte?
                  bne.s    v_pline_eff

;duenne v_plines zeichnen
;Vorgaben:
;d0/a0-a1 werden veraendert
;Eingaben:
;a0.l pb
;a1.l contrl
;a6.l Workstation
;Ausgaben:
;-
v_pline_thin:     move.w   n_ptsin(a1),d0 ;Zaehler
                  subq.w   #2,d0
                  bne.s    v_plines       ;nur eine Linie ?
v_pline1:         movem.l  d2-d7,-(sp)
                  pea.l    v_pline_ret1(pc) ;Ruecksprungadresse
                  move.w   l_style(a6),d0 ;Linienstilnummer
                  add.w    d0,d0
                  move.w   l_styles(a6,d0.w),d6 ;Linienmuster
                  movea.l  pb_ptsin(a0),a1 ;ptsin
                  movem.w  (a1),d0-d3
                  cmp.w    d1,d3
                  beq      hline
                  cmp.w    d0,d2
                  beq      vline
                  bra      line
v_pline_ret1:     movem.l  (sp)+,d2-d7
                  move.l   a0,d1          ;d1 restaurieren (pblock)
                  rts

v_plines:         bmi.s    v_pline_exit
                  movem.l  d1-d7/a2-a3,-(sp)
                  movea.l  pb_ptsin(a0),a3 ;ptsin
                  move.w   d0,d4          ;Linienzaehler
v_plines_in:      move.w   l_style(a6),d0 ;Linienstilnummer
                  add.w    d0,d0
                  movea.w  l_styles(a6,d0.w),a2 ;Linienmuster
                  cmpi.w   #EX_OR-1,wr_mode(a6)
                  bne.s    v_pline_loop
                  not.w    l_lastpix(a6)  ;-1, letzen Punkt nicht setzen
v_pline_loop:     movea.w  d4,a0
                  movem.w  (a3),d0-d3
                  addq.l   #4,a3
                  move.w   a2,d6          ;Linienstil
                  pea.l    v_pline_ret2(pc)
                  cmp.w    d1,d3
                  beq      hline
                  cmp.w    d0,d2
                  beq      vline
                  bra      line
v_pline_ret2:     move.w   a0,d4
                  dbra     d4,v_pline_loop
                  movem.l  (sp)+,d1-d7/a2-a3
v_pline_exit:     clr.w    l_lastpix(a6)  ;0, letzten Punkt setzen
                  rts

;minimale und maximale Koordinaten speichern
;Eingaben:
;d0.w Koordinatenpaaranzahl
;a0.l ptsin
;a3.l ptsout
search_min_max:   movem.l  d0/d2-d7/a0,-(sp)
                  subq.w   #1,d0
                  movem.w  (a3),d4-d7
min_max_loop:     move.w   (a0)+,d2
                  move.w   (a0)+,d3
                  cmp.w    d2,d4          ;Minimum?
                  ble.s    search_min_y
                  move.w   d2,d4
search_min_y:     cmp.w    d3,d5          ;Minimum?
                  ble.s    search_max_x
                  move.w   d3,d5
search_max_x:     cmp.w    d2,d6          ;Maximum?
                  bge.s    search_max_y
                  move.w   d2,d6
search_max_y:     cmp.w    d3,d7          ;Maximum?
                  bge.s    search_mm_next
                  move.w   d3,d7
search_mm_next:   dbra     d0,min_max_loop
                  movem.w  d4-d7,(a3)
                  movem.l  (sp)+,d0/d2-d7/a0
                  rts

;Beziers zeichnen
;Vorgaben:
;Register d0/a0-a1 werden veraendert
;Eingaben:
;a0.l pb
;a6.l Workstation
;Ausgaben:
;intout[0..1], ptsout[0..3]
v_bez:            movem.l  d1-d7/a2-a5,-(sp)
                  move.l   a0,-(sp)
                  move.l   l_start(a6),-(sp) ;l_start/l_end sichern

                  moveq.l  #0,d5          ;Punktzaehler insgesamt
                  moveq.l  #0,d6          ;Zaehler fuer Jump-Points
                  movea.l  (a0),a1        ;contrl
                  move.w   n_ptsin(a1),d7 ;Zaehler
                  ble      v_bez_exit

                  moveq.l  #-1,d2
                  subq.w   #1,d7          ;Punktezaehler

                  movea.l  pb_ptsout(a0),a3 ;Zeiger auf intout
                  move.l   res_x(a6),(a3)
                  clr.l    4(a3)
                  movea.l  pb_ptsin(a0),a4 ;ptsin
                  movea.l  pb_intin(a0),a5 ;bezarr

                  move.w   #ROUND,l_end(a6)

v_bez_loop:       addq.w   #1,d2          ;Zaehler inkrementieren

                  move.w   a5,d3
                  moveq.l  #1,d0
                  and.w    #1,d3
                  beq.s    v_bezarr_mask
                  moveq.l  #-1,d0
v_bezarr_mask:    moveq.l  #3,d3
                  tst.w    d7             ;letzter Punkt?
                  bne.s    v_bez_arrp
                  move.w   2(sp),l_end(a6) ;Endstil setzen
                  and.b    0(a5,d0.w),d3
                  bra.s    v_bez_draw
v_bez_arrp:       and.b    0(a5,d0.w),d3  ;Jump-Point oder Bezier?
                  beq      v_bez_next

v_bez_draw:       addq.w   #1,d2          ;Anzahl der Punkte im Linienzug
                  move.w   d2,d0
                  movea.l  a4,a0
                  add.w    d2,d2
                  add.w    d2,d2
                  adda.w   d2,a4          ;um n Koordinatenpaare weiter

                  moveq.l  #-1,d2         ;Zaehler neu setzen

                  btst     #1,d3          ;Jump-Point?
                  beq.s    v_bez_lines
                  subq.w   #1,d0          ;keine Linie zum letzten Punkt ziehen
                  addq.w   #1,d6          ;ein weiterer Jump-Point

                  cmp.w    #3,d3          ;auch Bezier-Startpunkt?
                  beq.s    v_bez_lines
                  moveq.l  #0,d2
                  subq.l   #4,a4          ;letzten Punkt als neuen Startpunkt benutzen

v_bez_lines:      cmp.w    #2,d0          ;weniger als zwei Punkte?
                  blt.s    v_bez_bez

                  add.w    d0,d5          ;Punktezaehler erhoehen
                  bsr      search_min_max
                  bsr.s    bez_lines      ;Linienzug ziehen
                  move.w   #ROUND,l_start(a6)

v_bez_bez:        and.w    #1,d3          ;Bezier-Start?
                  beq.s    v_bez_next
                  subq.w   #3,d7          ;mindestens 3 weitere Punkte vorhanden?
                  blt.s    v_bez_exit
                  bne.s    v_bez_save     ;letzer Punkt?
                  move.w   2(sp),l_end(a6) ;Endstil

v_bez_save:       movem.w  d5-d7,-(sp)

                  movem.w  -4(a4),d0-d7   ;ax, ay, bx, by, cx, cy, dx, dy
                  movea.w  bez_qual(a6),a0
                  movea.l  buffer_addr(a6),a2 ;Buffer fuer Rekursionsdaten
                  lea.l    1024(a2),a1    ;Buffer fuer Bezier Koordinaten
                  bsr      calc_bez       ;Bezier berechnen

                  movem.w  (sp)+,d5-d7
                  add.w    d0,d5          ;Punktanzahl erhoehen

                  movea.l  buffer_addr(a6),a0
                  lea.l    1024(a0),a0
                  bsr      search_min_max
                  bsr.s    bez_lines      ;Linienzug ziehen

                  move.w   #ROUND,l_start(a6)
                  moveq.l  #-1,d2
                  addq.w   #1,d7          ;Zaehler korrigieren, da Bezier-Ende Start des naechsten Linienzugs ist

                  addq.l   #2,a5          ;2 Eintraege weiter
                  lea.l    8(a4),a4       ;2 Koordinatenpaare weiter

v_bez_next:       addq.l   #1,a5          ;naechster bezarr-Eintrag
                  dbra     d7,v_bez_loop

v_bez_exit:       move.l   (sp)+,l_start(a6) ;l_start/l_end

                  movea.l  (sp)+,a0
                  movea.l  pb_intout(a0),a1
                  move.w   d5,(a1)+       ;Anzahl der Punkte
                  move.w   d6,(a1)+       ;Anzahl der Jump-Points

                  movem.l  (sp)+,d1-d7/a2-a5
                  rts



;Linien ziehen unter Beachtung von l_width, l_style, l_start, l_end
;Vorgaben:
;Register d0-d1/a0-a1 werden veraendert
;Eingaben:
;d0.w Punktanzahl
;a0.l ptsin
;a6.l Workstation
;Ausgaben:
;-
bez_lines:        cmpi.b   #DRIVER_NVDI,driver_type(a6) ;NVDI-Treiber?
                  bne.s    gdos_lines

nvdi_lines:       lea.l    -sizeof_PB-sizeof_contrl(sp),sp
                  lea.l    sizeof_PB(sp),a1     ;contrl
                  move.l   a0,pb_ptsin(sp)      ;Adresse von ptsin
                  move.l   a1,(sp)              ;Adresse von contrl
                  move.l   sp,d1                ;pb
                  movea.l  d1,a0                ;pb
                  move.w   d0,n_ptsin(a1)       ;Anzahl der Koordinatenpaare

                  pea.l    nvdi_lines_ret(pc)

                  movep.w  l_start+1(a6),d0 ;Linienendstile ?
                  add.w    l_width(a6),d0 ;breite Linie?
                  subq.w   #1,d0
                  bne      v_pline_thick  ;v_pline fuer Effekte
                  bra      v_pline_thin

nvdi_lines_ret:   lea.l    sizeof_contrl+sizeof_PB(sp),sp
                  rts

gdos_lines:       movem.l  d2/a2,-(sp)
                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer lokalen pb und contrl
                  lea.l    sizeof_PB(sp),a1     ;contrl
                  move.l   sp,d1                ;pb

                  move.l   a0,-(sp)             ;Zeiger auf ptsin
                  move.w   d0,-(sp)             ;Anzahl der Koordinatenpaare

                  movea.l  d1,a0                ;pb
                  move.l   a1,(a0)+             ;pb_control
                  lea.l    l_start(a6),a2
                  move.l   a2,(a0)+             ;pb_intin: Linienanfangs- und Endstil
                  lea.l    sizeof_contrl(a1),a2
                  move.l   a2,(a0)+             ;pb_ptsin: Dummy
                  move.l   a2,(a0)+             ;pb_intout: Dummy
                  move.l   a2,(a0)+             ;pb_ptsout: Dummy

                  move.w   #VSL_ENDS,(a1)+      ;Funktionsnummer
                  clr.l    (a1)+                ;n_ptsin/n_ptsout
                  move.w   #2,(a1)+             ;n_intin
                  clr.l    (a1)+                ;n_intout/opcode2
                  move.w   wk_handle(a6),(a1)   ;Treiber-Handle
                  movea.l  disp_addr2(a6),a0    ;Zeiger auf den Treiber-Dispatcher
                  jsr      (a0)                 ;vsl_ends() aufrufen

                  move.w   (sp)+,d0             ;Anzahl der Koordinatenpaare
                  movea.l  (sp)+,a2             ;Zeiger auf ptsin

                  move.l   sp,d1                ;pb
                  movea.l  d1,a0                ;pb
                  move.l   a2,pb_ptsin(a0)      ;ptsin
                  lea.l    sizeof_PB(a0),a1     ;contrl

                  move.w   #V_PLINE,(a1)+       ;Funktionsnummer
                  move.w   d0,(a1)+             ;n_ptsin: Anzahl der Koordinatenpaare
                  clr.l    (a1)+                ;n_ptsout/n_intin
                  clr.l    (a1)+                ;n_intout/opcode2
                  move.w   wk_handle(a6),(a1)   ;Treiber-Handle
                  movea.l  disp_addr2(a6),a0    ;Zeiger auf den Treiber-Dispatcher
                  jsr      (a0)                 ;v_pline() aufrufen

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp   ;Platz fuer pb und contrl zurueckgeben
                  movem.l  (sp)+,d2/a2
                  rts

;Array, das zur jeweiligen Bezier-Qualitaet (0-5) die minimale Laenge des Linienzugs beinhaltet
bez_max_tab:      DC.W 4,7,13,25,49,97

;4-Punkt-Bezier berechenen
;Vorgaben:
;Register d0-d7 werden veraendert
;Eingaben:
;d0.w ax
;d1.w bx
;d2.w bx
;d3.w by
;d4.w cx
;d5.w cy
;d6.w dx
;d7.w dy
;a0.w Qualitaet (0-7)
;a1.l ptsout
;a2.l Zeiger auf 1K Puffer fuer Rekursionsdaten
;Ausgaben
;d0.w Anzahl der Punkte
calc_bez:         move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  move.l   a2,-(sp)
                  lea.l    1024(a2),a2
                  movem.w  d0-d7,(a1)

                  moveq.l  #0,d0
                  moveq.l  #5,d3

calc_bez_len:     move.w   (a1)+,d1
                  ext.l    d1
                  move.w   2(a1),d2
                  ext.l    d2
                  sub.l    d1,d2          ;Differenz bilden
                  bpl.s    calc_bez_add
                  neg.l    d2
calc_bez_add:     add.l    d2,d0
                  dbra     d3,calc_bez_len

                  cmp.l    #97,d0         ;Linienzug laenger als 97 Pixel?
                  bge.s    calc_bez_addr

                  move.w   a0,d2          ;gewuenschte Qualitaet
                  move.w   d2,d1
                  add.w    d1,d1
                  lea.l    bez_max_tab+2(pc,d1.w),a0

calc_bq_loop:     cmp.w    -(a0),d0       ;Laenge des Linienzugs ausreichend?
                  bge.s    calc_bez_qual
                  dbra     d2,calc_bq_loop ;Qualitaet herabsetzen
                  moveq.l  #0,d2
calc_bez_qual:    movea.w  d2,a0          ;neue Qualitaet

calc_bez_addr:    subq.l   #12-4,a1
                  movem.w  -4(a1),d0-d3   ;Register wieder herrichten

                  swap     d0
                  swap     d1
                  swap     d2
                  swap     d3
                  swap     d4
                  swap     d5
                  swap     d6
                  swap     d7

                  move.w   #$8000,d0      ;fuer die Rundung
                  move.w   d0,d1
                  move.w   d0,d2
                  move.w   d0,d3
                  move.w   d0,d4
                  move.w   d0,d5
                  move.w   d0,d6
                  move.w   d0,d7

                  asr.l    #1,d0
                  asr.l    #1,d1
                  asr.l    #1,d2
                  asr.l    #1,d3
                  asr.l    #1,d4
                  asr.l    #1,d5
                  asr.l    #1,d6
                  asr.l    #1,d7

                  bsr.s    generate_bez

                  movea.l  (sp)+,a2
                  move.l   a1,d0
                  sub.l    (sp)+,d0
                  lsr.w    #2,d0          ;Punktanzahl
                  cmp.w    #1,d0          ;nur ein Punkt?
                  bgt.s    call_bez_exit
                  move.l   -4(a1),(a1)+
                  addq.w   #1,d0
call_bez_exit:    movea.l  (sp)+,a0
                  rts

;Bezier generieren
;Eingaben:
;d0.l ax << 15
;d1.l ay << 15
;d2.l bx << 15
;d3.l by << 15
;d4.l cx << 15
;d5.l cy << 15
;d6.l dx << 15
;d7.l dy << 15
;a0.w Qualitaet
;a1.l Ziel-Feld
;a2.l Zeiger auf Buffer fuer Rekursionsdaten
;Ausgaben:
;-
generate_bez:     cmpa.w   #0,a0          ;Qualitaet = 0, Rekursionsende?
                  beq.s    bez_out

                  subq.w   #1,a0          ;Qualitaet fuer naechsten Durchgang dekrementieren

                  movem.l  d6-d7,-(a2)    ;dx, dy

                  add.l    d4,d6
                  asr.l    #1,d6          ;xcd
                  add.l    d5,d7
                  asr.l    #1,d7          ;ycd
                  add.l    d2,d4
                  asr.l    #1,d4          ;xbc
                  add.l    d3,d5
                  asr.l    #1,d5          ;ybc
                  add.l    d0,d2
                  asr.l    #1,d2          ;xab
                  add.l    d1,d3
                  asr.l    #1,d3          ;yab
                  movem.l  d6-d7,-(a2)    ;xcd, ycd

                  add.l    d4,d6
                  asr.l    #1,d6          ;xbcd
                  add.l    d5,d7
                  asr.l    #1,d7          ;ybcd
                  add.l    d2,d4
                  asr.l    #1,d4          ;xabc
                  add.l    d3,d5
                  asr.l    #1,d5          ;yabc
                  movem.l  d6-d7,-(a2)    ;xbcd, ybcd

                  add.l    d4,d6
                  asr.l    #1,d6          ;xabcd
                  add.l    d5,d7
                  asr.l    #1,d7          ;yabcd
                  movem.l  d6-d7,-(a2)    ;xabcd, yabcd

                  bsr.s    generate_bez   ;ax, ay, xab, yab, xabc, yabc, xabcd, yabcd

                  movem.l  (a2)+,d0-d7
                  bsr.s    generate_bez   ;xabcd, yabcd, xbcd, ybcd, xcd, ycd, dx ,dy

                  addq.w   #1,a0          ;Qualitaet wieder inkrementieren

                  rts

bez_out:          swap     d2
                  rol.l    #1,d2
                  move.w   d2,(a1)+
                  swap     d3
                  rol.l    #1,d3
                  move.w   d3,(a1)+
                  swap     d2
                  move.w   d3,d2
                  cmp.l    -8(a1),d2
                  bne.s    bez_out_cxy
                  subq.l   #4,a1
bez_out_cxy:      swap     d4
                  rol.l    #1,d4
                  move.w   d4,(a1)+
                  swap     d5
                  rol.l    #1,d5
                  move.w   d5,(a1)+
                  swap     d4
                  move.w   d5,d4
                  cmp.l    -8(a1),d4
                  bne.s    bez_out_dxy
                  subq.l   #4,a1
bez_out_dxy:      swap     d6
                  rol.l    #1,d6
                  move.w   d6,(a1)+
                  swap     d7
                  rol.l    #1,d7
                  move.w   d7,(a1)+
                  swap     d6
                  move.w   d7,d6
                  cmp.l    -8(a1),d6
                  bne.s    bez_out_exit
                  subq.l   #4,a1
bez_out_exit:     rts

; POLYMARKER (VDI 7)
v_pmarker:        movem.l  d1-d7/a2,-(sp)
                  move.w   l_color(a6),-(sp)
                  move.w   m_color(a6),l_color(a6)
                  movem.l  (a0),a0-a2     ;contrl/intin/ptsin
                  move.w   n_ptsin(a0),d5 ;Anzahl der Polymarker
                  subq.w   #1,d5          ;wegen dbf
                  bmi.s    v_pm_exit
                  tst.w    m_type(a6)     ;Punkt?
                  beq.s    v_pmarker_dot
                  movea.l  m_data(a6),a0  ;Zeiger auf Markerdaten
                  lea.l    -64(sp),sp
                  movea.l  sp,a1
                  bsr      v_pmbuild      ;Markerdaten auf dem Stack aufbauen

v_pmarker_loop1:  move.w   (a2)+,d0       ;x1
                  move.w   (a2)+,d1       ;y1
                  move.w   d0,d2          ;x2
                  move.w   d1,d3          ;y2
                  movea.l  sp,a0          ;Buffer fuer Markerdaten auf dem Stack
                  move.w   (a0)+,d4       ;Anzahl der Linien
                  move.w   d5,-(sp)
v_pmarker_loop2:  movem.w  d0-d4,-(sp)
                  add.w    (a0)+,d0
                  add.w    (a0)+,d1
                  add.w    (a0)+,d2
                  add.w    (a0)+,d3
                  moveq.l  #-1,d6         ;durchgezogene Linie
                  bsr      line
                  movem.w  (sp)+,d0-d4
                  dbra     d4,v_pmarker_loop2
                  move.w   (sp)+,d5
                  dbra     d5,v_pmarker_loop1
                  lea.l    64(sp),sp      ;Stack korrigieren
v_pm_exit:        move.w   (sp)+,l_color(a6)

                  movem.l  (sp)+,d1-d7/a2
                  rts

v_pmarker_dot:    move.w   d5,-(sp)
                  move.w   (a2)+,d0       ;x1
                  move.w   (a2)+,d1       ;y1
                  move.w   d1,d3
                  moveq.l  #-1,d6         ;durchgezogene Linie
                  bsr      vline
                  move.w   (sp)+,d5
                  dbra     d5,v_pmarker_dot
                  move.w   (sp)+,l_color(a6)
                  movem.l  (sp)+,d1-d7/a2
                  rts

;Markerdaten fuer eine bestimmte Markerbreite generieren
;Vorgaben:
;Register d0-d4/a0-a1 werden veraendert
;Eingaben:
;a0.l Markerdaten
;a1.l Zielbuffer
;a6.l Workstation (m_width)
;Ausgaben:
;-
v_pmbuild:        move.w   (a0)+,d0       ;Linienanzahl
                  subq.w   #1,d0          ;Linienzaehler
                  move.w   d0,(a1)+
                  add.w    d0,d0
                  addq.w   #1,d0
                  addq.l   #2,a0
                  move.w   m_width(a6),d1 ;Breite des Markers
                  move.w   (a0)+,d2
                  mulu.w   d1,d2
                  swap     d2             ;Hot-Spot-x
                  move.w   (a0)+,d3
                  mulu.w   d1,d3
                  swap     d3             ;Hot-Spot-y
v_pmbuild_loop:   move.w   (a0)+,d4
                  mulu.w   d1,d4          ;* Breite
                  swap     d4
                  sub.w    d2,d4          ;- Hot-Spot-x
                  move.w   d4,(a1)+
                  move.w   (a0)+,d4
                  mulu.w   d1,d4          ;* Breite
                  swap     d4
                  sub.w    d3,d4          ;- Hot-Spot-y
                  move.w   d4,(a1)+
                  dbra     d0,v_pmbuild_loop
                  rts

; TEXT (VDI 8)
v_gtext:          movem.l  d1-d7/a2-a5,-(sp)
v_gtext_in:       movem.l  (a0),a1-a3

v_gtext_bmp:      movea.l  p_gtext(a6),a4
                  jsr      (a4)
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

;gefuellte Ellipse fuer dicke v_plines zeichnen
;Eingaben
;d0.w x
;d1.w y
;d2.w Radius a
;d3.w Radius b
;a6.l Wk-Zeiger
;Ausgaben
v_fillpie:        movem.l  d3-d7/a2-a5,-(sp)
                  move.l   f_color(a6),-(sp) ;f_color/f_interior
                  move.w   f_planes(a6),-(sp)
                  move.l   f_pointer(a6),-(sp)
                  move.w   l_color(a6),f_color(a6)
                  move.w   #F_SOLID,f_interior(a6)
                  clr.w    f_planes(a6)
                  move.l   f_fill1(a6),f_pointer(a6) ;Zeiger auf fill_1
                  bsr      fellipse
                  move.l   (sp)+,f_pointer(a6)
                  move.w   (sp)+,f_planes(a6)
                  move.l   (sp)+,f_color(a6)
                  movem.l  (sp)+,d3-d7/a2-a5
                  rts

;Gefuelltes Polygon fuer v_pline zeichnen
;d0.w Anzahl der Koordinatenpaare
;a0.l Zeiger aufs ptsin
v_fillline:       move.l   f_color(a6),-(sp) ;f_color/f_interior
                  move.w   f_perimeter(a6),-(sp)
                  move.w   f_planes(a6),-(sp)
                  move.l   f_pointer(a6),-(sp)
                  movem.l  d1-d7/a2-a5,-(sp)
                  move.w   l_color(a6),f_color(a6)
                  moveq.l  #1,d1
                  move.w   d1,f_interior(a6)
                  move.w   d1,f_perimeter(a6)   ;Perimeter an
                  clr.w    f_planes(a6)
                  move.l   f_fill1(a6),f_pointer(a6) ;Zeiger auf fill_1
                  movea.l  a0,a3          ;ptsin
                  move.w   d0,d4
                  subq.w   #1,d4
                  bsr.s    v_fillarea3
                  movem.l  (sp)+,d1-d7/a2-a5
                  move.l   (sp)+,f_pointer(a6)
                  move.w   (sp)+,f_planes(a6)
                  move.w   (sp)+,f_perimeter(a6)
                  move.l   (sp)+,f_color(a6)
                  rts

; FILLED AREA (VDI 9)
v_fillarea:       movea.l  (a0),a1        ;contrl
                  tst.w    n_intin(a1)    ;bezarr vorhanden?
                  beq.s    v_fillarea_no_bez
                  cmpi.w   #13,opcode2(a1) ;Bezierfunktion benutzen ?
                  beq      v_bez_fill
                  tst.w    bez_on(a6)
                  bne      v_bez_fill

v_fillarea_no_bez:movem.l  d1-d7/a2-a5,-(sp)
                  pea.l    vdi_fktret(pc)
                  movem.l  (a0),a1-a3

                  move.w   n_ptsin(a1),d0
                  subq.w   #1,d0          ;wg. dbf
                  ble      fpoly_exit
                  cmpi.w   #1,d0          ;nur eine Linie ?
                  beq      v_fae_line
                  cmpi.w   #3,d0          ;Rechteck ?
                  beq      v_fae_box
                  cmpi.w   #4,d0          ;Rechteck ?
                  beq      v_fae_box2
v_fillarea2:      move.w   n_ptsin(a1),d4
                  subq.w   #1,d4

;gefuelltes Polygon zeichnen                 
;Vorgaben:
;Register d0-d7/a0-a5 werden veraendert
;Eingaben:
;d4.w Punktanzahl - 1
;a3.l Zeiger auf die Koordinaten
;a6.l Wk
;Ausgaben:
;-                
v_fillarea3:      cmpi.w   #MAX_PTS-1,d4
                  bhi      fpoly_exit

                  subq.w   #1,d4
                  move.w   d4,d6
                  movea.l  buffer_addr(a6),a5

                  move.w   #$7fff,d5
                  moveq.l  #0,d7

                  movea.l  (a3),a4

vfa_minmax:       move.l   (a3)+,d0
                  cmp.w    d0,d5          ;Minimum?
                  ble.s    vfa_max
                  move.w   d0,d5
vfa_max:          cmp.w    d0,d7          ;Maximum?
                  bge.s    vfa_x2_y2
                  move.w   d0,d7
vfa_x2_y2:        move.l   (a3),d2
                  cmp.w    d0,d2
                  bge.s    vfa_x1_y1
                  exg      d0,d2
vfa_x1_y1:        move.l   d0,(a5)+
                  move.w   d2,d3
                  sub.w    d0,d3          ;dy
                  swap     d0
                  swap     d2
                  sub.w    d0,d2          ;dx
                  add.w    d2,d2          ;*2
                  move.w   d2,(a5)+       ;dx
                  move.w   d3,(a5)+       ;dy
                  dbra     d6,vfa_minmax

                  move.l   (a3)+,d0
                  cmp.w    d0,d5
                  ble.s    vfa_max2
                  move.w   d0,d5
vfa_max2:         cmp.w    d0,d7
                  bge.s    vfa_last_point
                  move.w   d0,d7

vfa_last_point:   cmpa.l   d0,a4          ;erster und letzer Punkt identisch?
                  beq.s    vfa_call_fpoly

                  move.l   a4,d2          ;erstes x/y-Paar

                  cmp.w    d0,d2
                  bpl.s    vfill_ssave2
                  exg      d0,d2
vfill_ssave2:     move.l   d0,(a5)+
                  move.w   d2,d3
                  sub.w    d0,d3          ;dy
                  swap     d0
                  swap     d2
                  sub.w    d0,d2          ;dx
                  add.w    d2,d2          ;*2
                  move.w   d2,(a5)+       ;dx
                  move.w   d3,(a5)+       ;dy
                  addq.w   #1,d4

vfa_call_fpoly:   movea.l  buffer_addr(a6),a4

;gefuelltes Polygon zeichenen
;Eingaben:
;d4.w Punktanzahl -1
;d5.w minimale y-Koordinte
;d7.w maximale y-Koordinate
;a4.l Zeiger auf den Quellbuffer
;a5.l Zeiger auf den Zielbuffer
fpoly:            move.w   clip_ymin(a6),d1
                  move.w   clip_ymax(a6),d3
                  cmp.w    d3,d5
                  bgt.s    fpoly_exit
                  cmp.w    d1,d7
                  blt.s    fpoly_exit
                  cmp.w    d1,d5
                  bge.s    fpoly_clipy2
                  move.w   d1,d5
fpoly_clipy2:     cmp.w    d3,d7
                  ble.s    fpoly_count
                  move.w   d3,d7

fpoly_count:      sub.w    d5,d7          ;Zeilenzaehler
fpoly_loop:       movea.l  a4,a0          ;Quellbuffer
                  movea.l  a5,a1          ;Zielbuffer
                  movem.w  d4-d5/d7,-(sp)
                  bsr.s    fpoly_hline
                  movem.w  (sp)+,d4-d5/d7
                  addq.w   #1,d5          ;naechste Zeile
                  dbra     d7,fpoly_loop

                  tst.w    f_perimeter(a6) ;Umrahmung?
                  beq.s    fpoly_exit

                  move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  cmpi.w   #EX_OR-REPLACE,wr_mode(a6)
                  bne.s    fpoly_border

                  not.w    l_lastpix(a6)  ;- 1, letzten Punkt nicht setzen
fpoly_border:     movea.w  d4,a0
                  movem.w  (a4)+,d0-d3
                  asr.w    #1,d2
                  add.w    d0,d2
                  add.w    d1,d3
                  moveq.l  #-1,d6
                  pea.l    fpoly_brdr_next(pc)
                  cmp.w    d1,d3
                  beq      hline
                  cmp.w    d0,d2
                  beq      vline
                  bra      line
fpoly_brdr_next:  move.w   a0,d4
                  dbra     d4,fpoly_border
                  clr.w    l_lastpix(a6)  ;0, letzten Punkt setzen
                  move.w   (sp)+,l_color(a6)
fpoly_exit:       rts


;Zeile eines gefuellten Polygons zeichnen
;Vorgaben:
;Register d0-d7/a0-a3 werden veraendert
;Eingaben:
;d4.w Anzahl der Geraden - 1
;d5.w zu zeichnende Zeile
;a0.l Zeiger auf den Quellbuffer im Format x|y|dx|dy
;a1.l Zeiger auf den Zielbuffer fuer x-Koordinaten
;a6.l Zeiger auf die Workstation
;Ausgaben:
;-
fpoly_hline:      movea.l  a1,a3          ;Zielbufferadresse sichern
fpoly_calc:       move.w   d5,d1
                  move.w   (a0)+,d0       ;x1
                  sub.w    (a0)+,d1       ;y - y1
                  move.w   (a0)+,d2       ;dx * 2
                  move.w   (a0)+,d3       ;dy
                  beq.s    fpoly_next     ;Steigung nicht definiert?

                  cmp.w    d1,d3          ;aktuelle Zeile nicht im Bereich der Linie?
                  bls.s    fpoly_next

                  muls.w   d1,d2          ;* (y-y1)
                  divs.w   d3,d2          ;/ dy
                  bmi.s    fpoly_save
                  addq.w   #1,d2          ;runden
fpoly_save:       asr.w    #1,d2          ;/ 2
                  add.w    d0,d2          ;+ x1
                  move.w   d2,(a1)+       ;x-Koordinate speichern
fpoly_next:       dbra     d4,fpoly_calc

                  move.l   a1,d6
                  sub.l    a3,d6          ;Laenge der gespeicherten Koordinaten
                  subq.w   #4,d6          ;mehr als zwei Punkte?
                  bne.s    fpoly_points

                  move.w   (a3)+,d0       ;x1
                  move.w   (a3)+,d2       ;x2
                  move.w   d5,d1          ;y
                  bra      fline

fpoly_points:
                  tst.w    d6
                  bmi.s    fpoly_hl_exit  ;keine Schnittpunkte?
                  addq.w   #4,d6
                  lsr.w    #1,d6
                  move.w   d6,d1
                  subq.w   #2,d1

fpoly_bubble1:    move.w   d1,d0
                  movea.l  a3,a1
fpoly_bubble2:    move.w   (a1)+,d2
                  cmp.w    (a1),d2
                  ble.s    fpoly_bubble3
                  move.w   (a1),-2(a1)
                  move.w   d2,(a1)
fpoly_bubble3:    dbra     d0,fpoly_bubble2
                  dbra     d1,fpoly_bubble1

                  movea.w  d5,a2
                  lsr.w    #1,d6
                  subq.w   #1,d6
fpoly_draw_line:  movea.w  d6,a0
                  move.w   (a3)+,d0       ;x1
                  move.w   (a3)+,d2       ;x2
                  move.w   a2,d1          ;y
                  bsr      fline
                  move.w   a0,d6
                  dbra     d6,fpoly_draw_line
fpoly_hl_exit:    rts

v_fae_box2:       move.l   (a3),d0
                  sub.l    16(a3),d0
                  bne      v_fillarea2
;Parameter fuer die Box heraussuchen
v_fae_box:        movem.w  (a3),d0-d7     ;ptsin[0...7]
                  cmp.w    d1,d3
                  bne.s    v_fa_test2
                  cmp.w    d0,d6
                  bne      v_fillarea2
                  cmp.w    d2,d4
                  bne      v_fillarea2
                  cmp.w    d5,d7

                  bne      v_fillarea2
                  move.w   d5,d3
                  bra.s    v_fa_perim

v_fa_test2:       cmp.w    d0,d2
                  bne      v_fillarea2
                  cmp.w    d1,d7
                  bne      v_fillarea2
                  cmp.w    d4,d6
                  bne      v_fillarea2
                  cmp.w    d3,d5
                  bne      v_fillarea2
                  move.w   d4,d2

;Umrahmung ??
v_fa_perim:       cmp.w    d1,d3
                  bge.s    v_fa_perim2
                  exg      d1,d3
v_fa_perim2:      tst.w    f_perimeter(a6)
                  bne      v_bar2
;Achtung:  wegen eines Fehlers im alten v_fillarea !!
                  cmp.w    d1,d3          ;gleiche Koordinaten?
                  beq      fbox
                  addq.w   #1,d1
                  subq.w   #1,d3
                  bra      fbox
v_fae_line:       movem.w  (a3),d0-d3
                  movea.l  f_pointer(a6),a0
                  move.w   (a0),d6
                  move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  bsr      line
                  move.w   (sp)+,l_color(a6)

; CELL ARRAY (VDI 10)
v_cellarray:      rts

bez_pnt_tab:      DC.W 4,7,13,25,49,97

;gefuellte Beziers zeichnen
;Vorgaben:
;Register d0/a0-a1 werden veraendert
;Eingaben:
;a0.l pb
;a6.l Workstation
;Ausgaben:
;intout[0..1], ptsout[0..3]
v_bez_fill:       movem.l  d1-d7/a2-a5,-(sp)

                  movea.l  (a0),a1        ;contrl
                  moveq.l  #0,d7          ;Highword loeschen
                  move.w   n_ptsin(a1),d7 ;Zaehler
                  cmp.w    #3,d7          ;mindestens 3 Koordinatenpaare?
                  blt      v_bezf_exit

                  move.l   bez_buf_len(a6),d0 ;Bezier-Buffer vorhanden?
                  bne.s    v_bezf_mem

                  movea.l  buffer_addr(a6),a1
                  move.l   buffer_len(a6),d0

v_bezf_mem:       move.l   d7,d1
                  lsl.l    #3,d1          ;8 Bytes pro Koordinatenpaar
                  add.l    d7,d1          ;+ 1 Byte pro bezarr-Eintrag
                  add.l    #1024,d1       ;+ 1024 Bytes fuer den Bezier-Generator = minimaler Platzbedarf

                  cmp.l    d0,d1          ;genuegend Platz vorhanden?
                  ble.s    v_bezf_saveq

                  move.l   d0,d7
                  sub.l    #1024,d7       ;1024 Bytes fuer den Bezier-Generator abziehen
                  divu.w   #9,d7          ;maximale Koordinatenanzahl

v_bezf_saveq:     move.w   bez_qual(a6),-(sp) ;Bezier-Qualitaet sichern

                  movea.l  pb_ptsin(a0),a4 ;ptsin
                  movea.l  pb_intin(a0),a0 ;intin (bezarr)

                  movea.l  a1,a2
                  adda.l   d0,a2          ;Zeiger hinter den Buffer
                  lea.l    -1024(a2),a2   ;Buffer fuer Bezier-Generator
                  movea.l  a2,a5
                  move.w   d7,d0
                  addq.w   #1,d0
                  and.w    #$fffe,d0
                  suba.w   d0,a5          ;Zeiger auf eigenes bezarr

                  subq.w   #1,d7          ;Punktezaehler
                  move.w   d7,d0
                  lsr.w    #1,d0          ;Wortzaehler fuer intin
                  movea.l  a5,a3          ;Zeiger auf eigenes bezarr

v_bezf_swap:      move.w   (a0)+,d1
                  and.w    #$0303,d1      ;ausmaskieren
                  rol.w    #8,d1          ;High- und Low-Byte tauschen
                  move.w   d1,(a3)+
                  dbra     d0,v_bezf_swap

                  movea.l  a5,a0          ;bezarr
                  move.w   d7,d0          ;Punktezaehler
                  moveq.l  #0,d2
                  move.w   d7,d2
                  addq.w   #1,d2          ;Zaehler fuer Punkte
                  moveq.l  #0,d3          ;Zaehler fuer Beziers

v_bezf_points:    moveq.l  #1,d1
                  and.b    (a0)+,d1       ;Bezierkurve?
                  beq.s    v_bezf_pts_nxt
                  subq.w   #2,d0          ;zu wenig Punkte?
                  bmi.s    v_bezfq_calc
                  subq.w   #3,d2          ;3 Punkte weniger
                  addq.w   #1,d3          ;1 Bezierkurve mehr
                  addq.l   #2,a0          ;3 Punkte weiter
v_bezf_pts_nxt:   dbra     d0,v_bezf_points

v_bezfq_calc:     move.w   bez_qual(a6),d0 ;gewuenschte Bezier-Qualitaet
                  move.l   a5,d4
                  sub.l    a1,d4          ;nutzbare Bufferlaenge
                  lsl.l    #3,d2          ;Platzverbrauch eines Koordinatenpaares
                  sub.l    d2,d4          ;Anzahl der Linien-Koordinaten
                  lea.l    bez_pnt_tab(pc),a0 ;Tabelle mit Punktanzahlen der Bezier-Qualitaeten

v_bezf_qual:      move.w   d0,d1          ;Bezier-Qualitaet
                  add.w    d1,d1
                  move.w   0(a0,d1.w),d1  ;maximale Punktanzahl fuer die Rekursionstiefe
                  mulu.w   d3,d1
                  lsl.l    #3,d1          ;Laenge der Bezier-Koordinatenpaare
                  cmp.l    d4,d1          ;Buffergroesse ausreichend?
                  ble.s    v_bezf_set_qual
                  subq.w   #1,d0          ;Bezierqualitaet heruntersetzen
                  bpl.s    v_bezf_qual
                  moveq.l  #0,d0

v_bezf_set_qual:  move.w   d0,bez_qual(a6) ;realisierbare Bezier-Qualitaet

                  moveq.l  #0,d6          ;Zaehler fuer Jump-Points
                  movea.l  a4,a3          ;Startadresse des Polygonzugs
                  andi.b   #1,(a5)        ;erster Punkt ist kein Jump-Point

v_bezf_loop:      move.l   (a4)+,d0       ;x1|y1
                  move.l   (a4),d2        ;x2|y2
                  tst.w    d7             ;letzter Punkt?
                  bne.s    v_bezf_cmp
                  move.l   (a3),d2        ;Koordinatenpaar des letzten Jump-Points
                  move.l   a4,d4
                  subq.l   #8,d4
                  cmp.l    a3,d4
                  beq.s    v_bezf_cmp
                  cmp.l    d0,d2
                  beq      v_bezf_next

v_bezf_cmp:       cmp.w    d0,d2          ;Koordinatenpaare tauschen?
                  bge.s    v_bezf_dx_dy
                  exg      d0,d2

v_bezf_dx_dy:     move.l   d0,(a1)+       ;x1|y1
                  sub.w    d0,d2          ;dy
                  swap     d0
                  swap     d2
                  sub.w    d0,d2
                  add.w    d2,d2          ;2dx
                  swap     d2
                  move.l   d2,(a1)+       ;2dx|dy

                  move.b   (a5)+,d4       ;Jump-Point oder Bezier?
                  beq      v_bezf_next

                  bclr     #1,d4          ;Jump-Point?
                  beq.s    v_bezf_lines

                  addq.w   #1,d6          ;ein weiterer Jump-Point
                  move.w   (a3)+,d2
                  move.w   (a3)+,d3
                  movea.l  a4,a3
                  subq.l   #4,a3          ;Zeiger auf Anfang des Polygonzugs

                  movem.w  -8(a4),d0-d1

                  cmp.w    d1,d3          ;Koordinatenpaare tauschen?
                  bge.s    v_bezf_dx_dy2
                  exg      d0,d2
                  exg      d1,d3
v_bezf_dx_dy2:    sub.w    d0,d2
                  add.w    d2,d2          ;2dx
                  sub.w    d1,d3          ;dy
                  movem.w  d0-d3,-16(a1)  ;Linienzug schliessen

                  tst.w    d7             ;letzter Punkt ist Jump-Point?
                  bne.s    v_bezf_lines
                  subq.l   #8,a1          ;dann die letzte Linie nicht ziehen

v_bezf_lines:     subq.b   #1,d4          ;Bezier-Start?
                  bne.s    v_bezf_next
                  subq.w   #3,d7          ;mindestens 3 weitere Punkte vorhanden?
                  blt.s    v_bezf_few

                  movem.w  d6-d7,-(sp)
                  move.l   a2,-(sp)
                  subq.l   #8,a1
                  move.l   a1,-(sp)

                  move.w   bez_qual(a6),d0
                  lea.l    bez_pnt_tab(pc),a0
                  add.w    d0,d0
                  move.w   0(a0,d0.w),d0
                  add.w    d0,d0
                  add.w    d0,d0
                  adda.w   d0,a1

                  move.l   a1,-(sp)

                  movem.w  -4(a4),d0-d7   ;ax, ay, bx, by, cx, cy, dx, dy
                  movea.w  bez_qual(a6),a0

                  bsr      calc_bez

                  movea.l  (sp)+,a0
                  movea.l  (sp)+,a1
                  movea.l  (sp)+,a2
                  movem.w  (sp)+,d6-d7

                  subq.w   #2,d0

v_bezf_bez:       move.l   (a0)+,d2       ;x1|y1
                  move.l   (a0),d3        ;x2|y2
                  cmp.w    d2,d3          ;Koordinatenpaare tauschen?
                  bge.s    v_bezf_dx_dy3
                  exg      d2,d3
v_bezf_dx_dy3:    move.l   d2,(a1)+       ;x1|y1
                  sub.w    d2,d3          ;dy
                  swap     d2
                  swap     d3
                  sub.w    d2,d3
                  add.w    d3,d3          ;2dx
                  swap     d3
                  move.l   d3,(a1)+       ;2dx|dy
                  dbra     d0,v_bezf_bez

                  addq.l   #8,a4          ;2 Koordinatenpaare weiter
                  addq.l   #2,a5          ;2 Eintraege weiter
                  andi.b   #1,(a5)        ;Jump-Point nicht moeglich!
                  bra      v_bezf_loop    ;naechster Durchgang

v_bezf_few:       move.w   d7,d0          ;Punktanzahl
                  beq.s    v_bezf_next
                  subq.w   #2,d0          ;noch 2 Punkte vorhanden?
                  bne.s    v_bezf_bezln
                  clr.b    1(a5)
v_bezf_bezln:     clr.b    (a5)

v_bezf_next:      dbra     d7,v_bezf_loop

                  move.w   (sp)+,bez_qual(a6)
                  movea.l  (sp),a0        ;pb

                  movea.l  bez_buffer(a6),a4 ;Quellbuffer
                  movea.l  buffer_addr(a6),a5 ;Zielbuffer
                  move.l   a4,d0          ;Bezier-Buffer vorhanden?
                  bne.s    v_bezf_pts
                  movea.l  buffer_addr(a6),a4
                  movea.l  a1,a5          ;Zielbuffer

v_bezf_pts:       move.l   a1,d4
                  sub.l    a4,d4
                  lsr.l    #3,d4          ;Punktanzahl
                  cmp.w    #2,d4          ;mindestens 2 Punkte?
                  blt.s    v_bezf_exit

                  movea.l  pb_ptsout(a0),a1 ;ptsout: extent[0..3]
                  movea.l  a4,a0          ;Koordinatenpaare
                  move.w   d4,d0          ;Punktanzahl
                  bsr.s    fsearch_min_max

                  move.l   (a1)+,d5       ;minimale y-Koordinate
                  move.l   (a1),d7        ;maximale y-Koordinate
                  subq.w   #1,d4          ;Punktezaehler

                  pea.l    v_bezf_exit(pc)

                  cmpi.b   #DRIVER_NVDI,driver_type(a6) ;NVDI-Treiber?
                  beq      fpoly
                  bra.s    gpoly

v_bezf_exit:      movem.l  (sp)+,d1-d7/a2-a5
                  rts

;minimale und maximale Koordinaten speichern
;Register werden nicht veraendert
;Eingaben:
;d0.w Koordinatenpaaranzahl
;a0.l ptsin
;a1.l ptsout
;Ausgaben:
;a1.l ptsout[0..3]
fsearch_min_max:  movem.l  d0-d7/a0,-(sp)
                  subq.w   #1,d0
                  movem.w  res_x(a6),d4-d5
                  moveq.l  #0,d6
                  moveq.l  #0,d7
fmin_max_loop:    move.w   (a0)+,d2
                  move.w   (a0)+,d3
                  cmp.w    d2,d4          ;Minimum?
                  ble.s    fsearch_min_y
                  move.w   d2,d4
fsearch_min_y:    cmp.w    d3,d5          ;Minimum?
                  ble.s    fsearch_max_x
                  move.w   d3,d5
fsearch_max_x:    cmp.w    d2,d6          ;Maximum?
                  bge.s    fsearch_max_y
                  move.w   d2,d6
fsearch_max_y:    cmp.w    d3,d7          ;Maximum?
                  bge.s    fsearch_mm_next
                  move.w   d3,d7
fsearch_mm_next:  move.w   (a0)+,d1
                  asr.w    #1,d1
                  add.w    d1,d2
                  add.w    (a0)+,d3
                  cmp.w    d2,d4          ;Minimum?
                  ble.s    fsearch_min_y2
                  move.w   d2,d4
fsearch_min_y2:   cmp.w    d3,d5          ;Minimum?
                  ble.s    fsearch_max_x2
                  move.w   d3,d5
fsearch_max_x2:   cmp.w    d2,d6          ;Maximum?
                  bge.s    fsearch_max_y2
                  move.w   d2,d6
fsearch_max_y2:   cmp.w    d3,d7          ;Maximum?
                  bge.s    fsearch_mm_next2
                  move.w   d3,d7
fsearch_mm_next2: dbra     d0,fmin_max_loop
                  movem.w  d4-d7,(a1)
                  movem.l  (sp)+,d0-d7/a0
                  rts

;gefuelltes Polygon ueber VDI-Treiber zeichenen
;Eingaben:
;d4.w Punktanzahl -1
;d5.w minimale y-Koordinte
;d7.w maximale y-Koordinate
;a4.l Zeiger auf den Quellbuffer
;a5.l Zeiger auf den Zielbuffer
gpoly:            move.w   clip_ymin(a6),d1
                  move.w   clip_ymax(a6),d3
                  cmp.w    d3,d5
                  bgt      gpoly_exit
                  cmp.w    d1,d7
                  blt      gpoly_exit
                  cmp.w    d1,d5
                  bge.s    gpoly_clipy2
                  move.w   d1,d5
gpoly_clipy2:     cmp.w    d3,d7
                  ble.s    gpoly_count
                  move.w   d3,d7

gpoly_count:      sub.w    d5,d7          ;Zeilenzaehler

                  moveq.l  #0,d0
                  bsr      gperimeter     ;Umrahmung ausschalten

gpoly_loop:       movea.l  a4,a0          ;Quellbuffer
                  movea.l  a5,a1          ;Zielbuffer
                  movem.w  d4-d5/d7,-(sp)
                  bsr.s    gpoly_hline
                  movem.w  (sp)+,d4-d5/d7
                  addq.w   #1,d5          ;naechste Zeile
                  dbra     d7,gpoly_loop

                  move.w   f_perimeter(a6),d0 ;Umrahmung?
                  beq.s    gpoly_exit
                  bsr      gperimeter     ;Umrahmung einschalten
                  bsr      gdos_get_lattr ;Linienattribute sichern
                  bsr      gdos_line_std  ;Attribute fuer Umrahmung setzen

                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer pb und contrl
                  lea.l    sizeof_PB+sizeof_contrl(sp),a2
                  lea.l    sizeof_PB(sp),a1
                  movea.l  sp,a0
                  move.l   a1,(a0)+             ;pb_control
                  move.l   a2,(a0)+             ;pb_intin
                  move.l   a2,(a0)+             ;pb_ptsin
                  move.l   a2,(a0)+             ;pb_intout
                  move.l   a2,(a0)+             ;pb_ptsout

gpoly_border:     lea.l    sizeof_PB(sp),a1
                  move.w   #V_PLINE,(a1)+       ;Funktionsnummer
                  move.w   #2,(a1)+             ;n_ptsin: Anzahl der Koordinatenpaare
                  clr.l    (a1)+                ;n_ptsout/n_intin: 0
                  clr.l    (a1)+                ;n_intout/n_opcode2: 0
                  move.w   wk_handle(a6),(a1)   ;Treiber-Handle
                  move.l   a1,(sp)              ;pb_control: contrl
                  move.l   a4,pb_ptsin(sp)      ;pb_ptsin: ptsin
                  movem.w  (a4)+,d0-d3          ;x1, y1, 2*dx, dy
                  asr.w    #1,d2
                  add.w    d0,d2                ;x2
                  add.w    d1,d3                ;y2
                  movem.w  d2-d3,-4(a4)
                  move.l   sp,d1                ;pb
                  movea.l  disp_addr2(a6),a0    ;Zeiger auf den Treiber-Dispatcher
                  jsr      (a0)                 ;Achtung: Druckertreiber veraendern anscheinend contrl!
                  dbra     d4,gpoly_border

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp

                  bsr      gdos_set_lattr       ;gesicherte Linienattribute setzen

gpoly_exit:       rts


;Zeile eines gefuellten Polygons zeichnen
;Vorgaben:
;Register d0-d7/a0-a3 werden veraendert
;Eingaben:
;d4.w Anzahl der Geraden - 1
;d5.w zu zeichnende Zeile
;a0.l Zeiger auf den Quellbuffer im Format x|y|dx|dy
;a1.l Zeiger auf den Zielbuffer fuer x-Koordinaten
;a6.l Zeiger auf die Workstation
;Ausgaben:
;-
gpoly_hline:      movea.l  a1,a3          ;Zielbufferadresse sichern
gpoly_calc:       move.w   d5,d1
                  move.w   (a0)+,d0       ;x1
                  sub.w    (a0)+,d1       ;y - y1
                  move.w   (a0)+,d2       ;dx * 2
                  move.w   (a0)+,d3       ;dy
                  beq.s    gpoly_next     ;Steigung nicht definiert?

                  cmp.w    d1,d3          ;aktuelle Zeile nicht im Bereich der Linie?
                  bls.s    gpoly_next

                  muls.w   d1,d2          ;* (y-y1)
                  divs.w   d3,d2          ;/ dy
                  bmi.s    gpoly_save
                  addq.w   #1,d2          ;runden
gpoly_save:       asr.w    #1,d2          ;/ 2
                  add.w    d0,d2          ;+ x1
                  move.w   d2,(a1)+       ;x-Koordinate speichern
gpoly_next:       dbra     d4,gpoly_calc

                  move.l   a1,d6
                  sub.l    a3,d6          ;Laenge der gespeicherten Koordinaten
                  subq.w   #4,d6          ;mehr als zwei Punkte?
                  bne.s    gpoly_points

                  move.w   (a3)+,d0       ;x1
                  move.w   (a3)+,d2       ;x2
                  move.w   d5,d1          ;y
                  bra.s    gdos_fline

gpoly_points:     tst.w    d6
                  bmi.s    gpoly_hl_exit  ;keine Schnittpunkte?
                  addq.w   #4,d6
                  lsr.w    #1,d6
                  move.w   d6,d1
                  subq.w   #2,d1

gpoly_bubble1:    move.w   d1,d0
                  movea.l  a3,a1
gpoly_bubble2:    move.w   (a1)+,d2
                  cmp.w    (a1),d2
                  ble.s    gpoly_bubble3
                  move.w   (a1),-2(a1)
                  move.w   d2,(a1)
gpoly_bubble3:    dbra     d0,gpoly_bubble2
                  dbra     d1,gpoly_bubble1

                  lsr.w    #1,d6
                  subq.w   #1,d6
gpoly_draw_line:  move.w   d6,-(sp)
                  move.w   (a3)+,d0       ;x1
                  move.w   (a3)+,d2       ;x2
                  move.w   d5,d1          ;y
                  bsr.s    gdos_fline
                  move.w   (sp)+,d6
                  dbra     d6,gpoly_draw_line
gpoly_hl_exit:    rts

;Horizontale Linie mit Fuellmuster ueber VDI-Treiber zeichnen
;Vorgaben:
;d0-d2/a0-a2 werden veraendert
;Register
;Eingaben:
;d0.w x1
;d1.w y1
;d2.w x2
;a6.l Workstation
;Ausgaben:
;a6.l Workstation
gdos_fline:       lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp
                  lea.l    sizeof_PB+sizeof_contrl(sp),a2   ;ptsin
                  lea.l    sizeof_PB(sp),a1     ;contrl
                  movea.l  sp,a0                ;pb
                  move.l   a1,(a0)+             ;pb_control
                  move.l   a2,(a0)+             ;pb_intin: Dummy
                  move.l   a2,(a0)+             ;pb_ptsin
                  move.l   a2,(a0)+             ;pb_intout: Dummy
                  move.l   a2,(a0)+             ;pb_ptsout: Dummy

                  move.w   #VR_RECFL,(a1)       ;Funktionsnummer
                  move.w   #2,n_ptsin(a1)       ;Anzahl der Koordinatenpaare
                  clr.w    n_intin(a1)          ;keine Integers
                  move.w   wk_handle(a6),handle(a1) ;Treiber-Handle
                  move.w   d0,(a2)+             ;x1
                  move.w   d1,(a2)+             ;y
                  move.w   d2,(a2)+             ;x2
                  move.w   d1,(a2)+             ;y2
                  move.l   sp,d1                ;pb
                  movea.l  disp_addr2(a6),a0    ;Zeiger auf den Treiber-Dispatcher
                  cmpi.w   #SCREEN9,driver_id(a6) ;Bildschirmtreiber?
                  bls.s    gdos_fline_jsr
                  move.w   #V_GDP,(a1)          ;Funktionsnummer
                  move.w   #V_BAR,opcode2(a1)   ;Unterfunktion
                  addq.w   #1,-(a2)             ;wegen eines Fehlers in Druckertreibern
                  subq.w   #1,-4(a2)            ;eine groessere v_bar() zeichnen
gdos_fline_jsr:   jsr      (a0)
                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp
                  rts

;Fuer VDI-Treiber vsf_perimter() aufrufen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;d0.w Flag
;a6.l Workstation
;Ausgaben:
;-
gperimeter:       movem.l  d0-d2/a0-a2,-(sp)
                  lea.l    2(sp),a2             ;Zeiger auf d0.w
                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer lokalen pb und contrl
                  lea.l    sizeof_PB(sp),a1     ;contrl
                  move.l   sp,d1                ;pb

                  movea.l  d1,a0                ;pb
                  move.l   a1,(a0)+             ;pb_control
                  move.l   a2,(a0)+             ;pb_intin: 1
                  lea.l    sizeof_contrl(a1),a2
                  move.l   a2,(a0)+             ;pb_ptsin: Dummy
                  move.l   a2,(a0)+             ;pb_intout: Dummy
                  move.l   a2,(a0)+             ;pb_ptsout: Dummy

                  move.w   #VSF_PERIMETER,(a1)+ ;Funktionsnummer
                  clr.l    (a1)+                ;n_ptsin/n_ptsout
                  move.w   #1,(a1)              ;n_intin
                  move.w   wk_handle(a6),handle-n_intin(a1) ;Treiber-Handle
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp   ;Platz fuer lokalen pb und contrl
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Linienattribute eines VDI-Treibers erfragen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;a6.l Workstation
;Ausgaben
;a6.l Workstation: l_style/l_color/l_width
gdos_get_lattr:   movem.l  d0-d2/a0-a2,-(sp)
                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer lokalen pb, contrl, intout, ptsout
                  lea.l    sizeof_PB(sp),a1     ;contrl
                  move.l   sp,d1                ;pb
                  movea.l  d1,a0                ;pb

                  move.l   a1,(a0)+             ;pb_control
                  lea.l    sizeof_contrl(a1),a2
                  move.l   a2,(a0)+             ;pb_intin: Dummy
                  move.l   a2,(a0)+             ;pb_ptsin: Dummy
                  move.l   a2,(a0)+             ;pb_intout
                  lea.l    32(a2),a2
                  move.l   a2,(a0)              ;pb_ptsout

                  move.w   #VQL_ATTRIBUTES,(a1) ;Funktionsnummer
                  clr.w    n_ptsin(a1)
                  clr.w    n_intin(a1)
                  move.w   wk_handle(a6),handle(a1) ;Treiber-Handle
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)                 ;vql_attributes() aufrufen

                  lea.l    sizeof_PB+sizeof_contrl(sp),a1   ;intout
                  move.w   (a1)+,l_style(a6)    ;Linientyp
                  move.w   (a1)+,l_color(a6)    ;Linienfarbe
                  lea.l    32-4(a1),a1          ;ptsout
                  move.w   (a1),l_width(a6)     ;Linienbreite

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp   ;Platz fuer lokalen pb, contrl, intout, ptsout
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

;Standard-Linienattribute fuer Umrahmung setzen
;Vorgaben:
;kein Register wird veraendert;
;die Linienattribute l_color, l_start, l_end, l_width und l_style werden veraendert
;Eingaben:
;a6.l Workstation
;Ausgaben
;a6.l Workstation
gdos_line_std:    movem.l  d0-d2/a0-a4,-(sp)
                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer lokalen pb, contrl, intin, ptsin, intout, ptsout
                  lea.l    sizeof_PB(sp),a3     ;contrl
                  move.l   sp,d1                ;pb
                  movea.l  d1,a0                ;pb

                  move.l   a3,(a0)+             ;pb_control
                  lea.l    sizeof_contrl(a3),a4 ;intin/ptsin
                  move.l   a4,(a0)+             ;pb_intin
                  move.l   a4,(a0)+             ;pb_ptsin
                  lea.l    32(a4),a2            ;intout/ptsout
                  move.l   a2,(a0)+             ;pb_intout
                  move.l   a2,(a0)              ;pb_ptsout

                  move.w   wk_handle(a6),handle(a3) ;Treiber-Handle
                  move.w   #VQF_ATTRIBUTES,(a3) ;Funktionsnummer
                  clr.w    n_ptsin(a3)
                  clr.w    n_intin(a3)
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)                 ;vqf_attributes() aufrufen
                  move.w   sizeof_PB+sizeof_contrl+32+2(sp),d0
                  move.w   d0,f_color(a6)       ;aktuelle Fuellfarbe

                  move.w   #VSL_COLOR,(a3)      ;Linienfarbe setzen
                  move.w   #1,n_intin(a3)
                  move.w   d0,(a4)              ;intin[0] = Linienfarbe
                  move.l   sp,d1                ;n_ptsin ist 0
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)                 ;vsl_color() aufrufen

                  move.w   #VSL_TYPE,(a3)       ;Linientyp setzen
                  move.w   #L_SOLID,(a4)        ;intin[0] = durchgehende Linie
                  move.l   sp,d1                ;n_intin ist 1, n_ptsin 0
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  move.w   #VSL_ENDS,(a3)       ;Linienenden setzen
                  move.w   #2,n_intin(a3)
                  clr.l    (a4)                 ;intin[0/1] =  Start und Ende eckig
                  move.l   sp,d1                ;n_ptsin ist 0
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)                 ;vsl_ends() aufrufen

                  move.w   #VSL_WIDTH,(a3)      ;Linienbreite setzen
                  move.w   #1,n_ptsin(a3)
                  clr.w    n_intin(a3)
                  move.w   #1,(a4)              ;ptsin[0] = Breite 1
                  move.l   sp,d1
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)                 ;vsl_width() aufrufen

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp   ;Platz fuer lokalen pb, contrl, intin, ptsin, intout, ptsout
                  movem.l  (sp)+,d0-d2/a0-a4
                  rts

;In der Workstation gespeicherte Linienattribute setzen
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;a6.l Work_station: l_color, l_start, l_end, l_width und l_style
;Ausgaben:
;a6.l Workstation
gdos_set_lattr:   movem.l  d0-d2/a0-a4,-(sp)
                  lea.l    -sizeof_PB-sizeof_contrl-64(sp),sp  ;Platz fuer lokalen pb, contrl, intin, ptsin, intout, ptsout
                  lea.l    sizeof_PB(sp),a3     ;contrl
                  move.l   sp,d1                ;pb
                  movea.l  d1,a0                ;pb

                  move.l   a3,(a0)+             ;pb_control
                  lea.l    sizeof_contrl(a3),a4 ;intin/ptsin
                  move.l   a4,(a0)+             ;pb_intin
                  move.l   a4,(a0)+             ;pb_ptsin
                  lea.l    32(a4),a2            ;intout/ptsout
                  move.l   a2,(a0)+             ;pb_intout
                  move.l   a2,(a0)              ;pb_ptsout

                  move.w   wk_handle(a6),handle(a3) ;Treiber-Handle
                  move.w   #VSL_WIDTH,(a3)      ;Funktionsnummer
                  move.w   #1,n_ptsin(a3)
                  clr.w    n_intin(a3)
                  move.w   l_width(a6),(a4)     ;ptsin[0] = Linienbreite
                  move.l   sp,d1
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  move.w   #VSL_ENDS,(a3)       ;Funktionsnummer
                  clr.w    n_ptsin(a3)
                  move.w   #2,n_intin(a3)
                  move.l   l_start(a6),(a4)     ;intin[0/1] = Linienenden
                  move.l   sp,d1
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  move.w   #VSL_COLOR,(a3)      ;Funktionsnummer
                  move.w   #1,n_intin(a3)
                  move.w   l_color(a6),(a4)     ;intin[0] = Linienfarbe
                  move.l   sp,d1                ;n_ptsin ist 0
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  move.w   #VSL_TYPE,(a3)       ;Funktionsnummer
                  move.w   l_style(a6),(a4)     ;intin[0] = Linienstil
                  move.l   sp,d1                ;n_intin ist 1, n_ptsin ist 0
                  movea.l  disp_addr2(a6),a0
                  jsr      (a0)

                  lea.l    sizeof_PB+sizeof_contrl+64(sp),sp   ;Platz fuer lokalen pb, contrl, intin, ptsin, intout, ptsout
                  movem.l  (sp)+,d0-d2/a0-a4
                  rts

; CONTOUR FILL (VDI 103)
v_contourfill:    movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a3
                  bsr      v_contourfill_in
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

; FILL RECTANGLE (VDI 114)
vr_recfl:         movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  pb_ptsin(a0),a0
                  movem.w  (a0),d0-d3     ;x1,y1,x2,y2
                  bsr      fbox_noreg
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts


; GENRALIZED DRAWING PRIMITIVE (GDP) (VDI 11)
v_gdp:            movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a3
                  move.w   opcode2(a1),d0 ;Unteropcode
                  subq.w   #V_BAR,d0
                  cmpi.w   #V_BEZ_ONOFF-V_BAR,d0
                  bhi.s    v_gdp_err
                  add.w    d0,d0
                  move.w   v_gdp_tab(pc,d0.w),d0
                  jsr      v_gdp_tab(pc,d0.w)
v_gdp_err:        movem.l  (sp)+,d1-d7/a2-a5
v_gdp_exit:       rts

v_gdp_tab:        DC.W v_bar-v_gdp_tab
                  DC.W v_arc-v_gdp_tab
                  DC.W v_pieslice-v_gdp_tab
                  DC.W v_circle-v_gdp_tab
                  DC.W v_ellipse-v_gdp_tab
                  DC.W v_ellarc-v_gdp_tab
                  DC.W v_ellpie-v_gdp_tab
                  DC.W v_rbox-v_gdp_tab
                  DC.W v_rfbox-v_gdp_tab
                  DC.W v_justified-v_gdp_tab
                  DC.W v_gdp_exit-v_gdp_tab
                  DC.W v_gdp_exit-v_gdp_tab
                  DC.W v_bez_on-v_gdp_tab

; BAR (VDI 11, GDP 1)
v_bar:            movem.w  (a3),d0-d3     ;x1,y1,x2,y2
v_bar2:           bsr      fbox
                  tst.w    f_perimeter(a6) ;Umrahmung ?
                  beq.s    v_bar_exit
                  cmp.w    d1,d3
                  bge.s    v_bar_out
                  exg      d1,d3
v_bar_out:        move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  bsr.s    hline_fill
                  cmp.w    d1,d3
                  beq.s    v_bar_exit2
                  exg      d1,d3
                  bsr.s    hline_fill
                  subq.w   #1,d1
                  addq.w   #1,d3
                  bsr.s    vline_fill
                  exg      d0,d2
                  cmp.w    d0,d2
                  beq.s    v_bar_exit2
                  bsr.s    vline_fill
v_bar_exit2:      move.w   (sp)+,l_color(a6)
v_bar_exit:       rts

hline_fill:       movem.w  d0-d3,-(sp)
                  moveq.l  #-1,d6
                  bsr      hline
                  movem.w  (sp)+,d0-d3
                  rts

vline_fill:       movem.w  d0-d3,-(sp)
                  moveq.l  #-1,d6
                  bsr      vline
                  movem.w  (sp)+,d0-d3
                  rts

; PIE (VDI 11, GDP 3)
v_pieslice:       move.w   (a3)+,d0       ;x
                  move.w   (a3)+,d1       ;y
                  move.w   (a2)+,d4       ;Anfangswinkel
                  move.w   (a2)+,d5       ;Endwinkel
                  move.w   8(a3),d2       ;xr
                  move.w   d2,d3          ;yr = xr;
                  move.w   res_ratio(a6),d6 ;keine Dehnung ?
                  beq      fellipse_arc
                  add.w    d3,d3
                  tst.w    d6             ;320*480 ?
                  bgt      fellipse_arc
                  asr.w    #2,d3          ;640*200
                  bra      fellipse_arc

; CIRCLE (VDI 11, GDP 4)
v_circle:         move.w   (a3)+,d0       ;x
                  move.w   (a3)+,d1       ;y
                  move.w   4(a3),d2       ;xr
                  move.w   d2,d3          ;yr = xr;
                  move.w   res_ratio(a6),d6 ;keine Dehnung ?
                  beq.s    v_ellipse2
                  add.w    d3,d3
                  tst.w    d6             ;320*480 ?
                  bgt.s    v_ellipse2
                  asr.w    #2,d3          ;640*200
                  bra.s    v_ellipse2

; ELLISE (VDI 11, GDP 5)
v_ellipse:        movem.w  (a3),d0-d3     ;x,y,xr,yr
v_ellipse2:       bra      fellipse2

; ARC (VDI 11, GDP 2)
v_arc:            move.w   (a3)+,d0       ;x
                  move.w   (a3)+,d1       ;y
                  move.w   8(a3),d2       ;xr
                  move.w   d2,d3          ;yr = xr;
                  move.w   res_ratio(a6),d6 ;keine Dehnung ?
                  beq.s    v_ellarc2
                  add.w    d3,d3
                  tst.w    d6             ;320*480 ?
                  bgt.s    v_ellarc2
                  asr.w    #2,d3          ;640*200
                  bra.s    v_ellarc2

; ELLIPTICAL ARC (VDI 11, GDP 6)
v_ellarc:         movem.w  (a3),d0-d3     ;x,y,xr,yr
v_ellarc2:        move.w   (a2)+,d4       ;Anfangswinkel
                  move.w   (a2)+,d5       ;Endwinkel
                  move.l   buffer_len(a6),-(sp)
                  move.l   buffer_addr(a6),-(sp)
                  bsr      ellipse_calc
                  move.l   a1,d1          ;erste unbenutze Bufferadresse
                  movea.l  (sp),a0
                  sub.l    a0,d1          ;neue Bufferlaenge
                  move.l   d1,buffer_len(a6)
                  move.l   a1,buffer_addr(a6)
                  bsr      nvdi_lines
                  move.l   (sp)+,buffer_addr(a6)
                  move.l   (sp)+,buffer_len(a6)
                  rts

; ELLIPTICAL PIE (VDI 11, GDP 7)
v_ellpie:         movem.w  (a3),d0-d3     ;x,y,xr,yr
                  move.w   (a2)+,d4       ;Anfangswinkel
                  move.w   (a2)+,d5       ;Endwinkel
                  bra      fellipse_arc

; ROUNDED RECTANGLE (VDI 11, GDP 8)
v_rbox:           movem.w  (a3),d0-d3
                  move.l   buffer_len(a6),-(sp)
                  move.l   buffer_addr(a6),-(sp)
                  bsr      rbox_calc
                  move.l   a3,d0
                  sub.l    (sp),d0
                  move.l   d0,buffer_len(a6)
                  move.l   a3,buffer_addr(a6)
                  movea.l  (sp),a0
                  move.l   l_start(a6),-(sp)
                  clr.l    l_start(a6)
                  move.w   d4,d0
                  bsr      nvdi_lines
                  move.l   (sp)+,l_start(a6)
                  move.l   (sp)+,buffer_addr(a6)
                  move.l   (sp)+,buffer_len(a6)
                  rts

; FILL ROUNDED RECTANGLE (VDI 11, GDP 9)
v_rfbox:          movem.w  (a3),d0-d3     ;x1,y1,x2,y2
                  tst.w    f_perimeter(a6) ;Umrahmung ?
                  beq      frbox
                  bsr      frbox
                  bsr      rbox_calc
                  movea.l  buffer_addr(a6),a3

v_pline_fill:     subq.w   #2,d4          ;weniger als zwei Punkte?
                  bmi.s    vpfl_ex
                  move.w   l_color(a6),-(sp)
                  move.w   f_color(a6),l_color(a6)
                  cmpi.w   #EX_OR-REPLACE,wr_mode(a6)
                  bne.s    v_plfill_loop2
                  not.w    l_lastpix(a6)  ;- 1, letzten Punkt nicht setzen
v_plfill_loop2:   movea.w  d4,a0
                  movem.w  (a3),d0-d3
                  addq.l   #4,a3
                  moveq.l  #-1,d6
                  pea.l    v_plfill_ret2(pc)
                  cmp.w    d1,d3
                  beq      hline
                  cmp.w    d0,d2
                  beq      vline
                  bra      line
v_plfill_ret2:    move.w   a0,d4
                  dbra     d4,v_plfill_loop2
                  clr.w    l_lastpix(a6)  ;0, letzten Punkt setzen
                  move.w   (sp)+,l_color(a6)
vpfl_ex:          rts

; JUSTIFIED GRAPHICS TEXT (VDI 11, GDP 10)
v_justified:      tst.l    (a2)+             ;keine Dehnung ?
                  bne.s    v_justified2
                  subq.w   #2,n_intin(a1)
                  move.l   a1,-(sp)
                  movea.l  p_gtext(a6),a4
                  jsr      (a4)
                  movea.l  (sp)+,a1
                  addq.w   #2,n_intin(a1)    ;korrigieren
                  rts
v_justified2:     bra      text_justified

; BEZIER ON/BEZIER OFF (VDI 11,GDP 13)
v_bez_on:         movea.l  pb_intout(a0),a0
                  tst.w    n_ptsin(a1)
                  bne.s    v_bez_on2
                  clr.w    bez_on(a6)
                  clr.w    (a0)
v_bez_oo_exit:    rts

v_bez_on2:        move.w   #5,bez_qual(a6)
                  move.w   #7,(a0)
                  move.w   #1,bez_on(a6)
                  rts
