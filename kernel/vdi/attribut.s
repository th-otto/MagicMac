                  ;'3. Attributfunktionen'

/*
 * SET WRITING MODE (VDI 32)
 */
vswr_mode:        movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;Grafikmodus
vswr_mode_set:    move.w   d0,(a0)        ;intout[0] = Grafikmodus;
                  subq.w   #REPLACE,d0
                  move.w   d0,wr_mode(a6) ;Grafikmodus eintragen
                  subq.w   #REV_TRANS-REPLACE,d0
                  bhi.s    vswr_mode_err
                  rts
vswr_mode_err:    moveq.l  #REPLACE,d0    ;intout[0] = REPLACE;
                  bra.s    vswr_mode_set

/*
 * SET COLOR REPRESENTATION (VDI 14)
 */
vs_color:         movem.l  d1-d4,-(sp)
                  movem.l  pb_intin(a0),a0 ;intin
                  move.w   (a0)+,d3       ;Farbindex
                  cmp.w    colors(a6),d3  ;zulaessig ?
                  bhi.s    vs_color_exit

                  move.w   #1000,d4       ;hoechste VDI-Intensitaet

vs_color_red:     move.w   (a0)+,d0       ;Rot-Intensitaet in Promille (0-1000)
                  bpl.s    vs_color_maxr
                  moveq.l  #0,d0
vs_color_maxr:    cmp.w    d4,d0
                  ble.s    vs_color_green
                  move.w   d4,d0

vs_color_green:   move.w   (a0)+,d1       ;Gruen-Intensitaet in Promille (0-1000)
                  bpl.s    vs_color_maxg
                  moveq.l  #0,d1
vs_color_maxg:    cmp.w    d4,d1
                  ble.s    vs_color_blue
                  move.w   d4,d1

vs_color_blue:    move.w   (a0)+,d2       ;Blau-Intensitaet in Promille (0-1000)
                  bpl.s    vs_color_maxb
                  moveq.l  #0,d2
vs_color_maxb:    cmp.w    d4,d2
                  ble.s    vs_color_call
                  move.w   d4,d2

vs_color_call:    movea.l  p_set_color_rgb(a6),a0
                  jsr      (a0)

vs_color_exit:    movem.l  (sp)+,d1-d4
                  rts


/*
 * SET POLYLINE LINE TYPE (VDI 15)
 */
vsl_type:         movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;intin[0] = Linienstil
vsl_type_set:     move.w   d0,(a0)        ;intout[0] = neuer Linienstil;
                  subq.w   #L_SOLID,d0
                  move.w   d0,l_style(a6) ;Linienstil eintragen
                  subq.w   #L_USER_DEF-L_SOLID,d0
                  bhi.s    vsl_type_err
                  rts
vsl_type_err:     moveq.l  #L_SOLID,d0    ;intout[0] = L_SOLID;
                  bra.s    vsl_type_set

; SET USER-DEFINED LINE STYLE PATTERN (VDI 113)

vsl_udsty:        movea.l  pb_intin(a0),a1 ;intin
                  move.w   (a1),l_udstyle(a6) ;eigenen Linienstil eintragen
                  rts

; SET POLYLINE LINE WIDTH (VDI 16)
vsl_width:        movea.l  pb_ptsin(a0),a1 ;ptsin
                  movea.l  pb_ptsout(a0),a0 ;ptsout
                  move.w   (a1),d0        ;Linienbreite
                  subq.w   #L_WIDTH_MIN,d0
                  cmpi.w   #L_WIDTH_MAX-L_WIDTH_MIN,d0
                  bhi.s    vsl_width_min
                  or.w     #L_WIDTH_MIN,d0 ;nur ungerade Breiten!
vsl_width_set:    move.w   d0,(a0)        ;ptsout[0] = neue Linienbreite;
                  move.w   d0,l_width(a6) ;neue Linienbreite eintragen
                  rts
vsl_width_min:    tst.w    d0
                  bpl.s    vsl_width_max
                  moveq.l  #L_WIDTH_MIN,d0
                  bra.s    vsl_width_set
vsl_width_max:    moveq.l  #L_WIDTH_MAX,d0
                  bra.s    vsl_width_set

; SET POLYLINE COLOR INDEX (VDI 17)
vsl_color:        movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0
                  cmp.w    colors(a6),d0
                  bhi.s    vsl_color_err
vsl_color_set:    move.w   d0,(a0)        ;intout[0] = neue Linienfarbe
                  move.w   d0,l_color(a6) ;gesetzte Linienfarbe
                  rts
vsl_color_err:    moveq.l  #BLACK,d0      ;intout[0] = BLACK;
                  bra.s    vsl_color_set

; SET POLYLINE END STYLES (VDI 108)
vsl_ends:         movea.l  pb_intin(a0),a1 ;intin
                  move.w   (a1)+,d0       ;Linienanfang
                  cmp.w    #L_ROUNDED,d0  ;richtige Angabe ?
                  bls.s    vsl_ends_start
                  moveq.l  #L_SQUARED,d0
vsl_ends_start:   move.w   d0,l_start(a6) ;Linienanfang eintragen
                  move.w   (a1),d0        ;Linienende
                  cmp.w    #L_ROUNDED,d0  ;richtige Angabe ?
                  bls.s    vsl_ends_end
                  moveq.l  #L_SQUARED,d0

vsl_ends_end:     move.w   d0,l_end(a6)   ;Linienende eintragen
                  rts

; SET POLYMARKER TYPE (VDI 18)
vsm_type:         movea.l  pb_intin(a0),a1
                  move.w   (a1),d0        ;Symbol = intin[1]
                  movea.l  pb_intout(a0),a1
                  move.w   d0,(a1)        ;intout[0] = Polymarkertyp;
                  subq.w   #M_DOT,d0
                  cmpi.w   #M_DIAMOND-M_DOT,d0
                  bls.s    vsm_type_set
                  move.w   #M_ASTERISK,(a1)
                  moveq.l  #M_ASTERISK-M_DOT,d0
vsm_type_set:     move.w   m_height(a6),d1 ;Markerhoehe
                  move.w   d0,m_type(a6)
                  add.w    d0,d0
                  add.w    d0,d0
                  bne.s    vsm_type_addr  ;Punkt?
                  moveq.l  #1,d1          ;Hoehe immer 1
vsm_type_addr:    move.l   marker_addrs(pc,d0.w),a1 ;Zeiger auf Struktur
                  move.l   a1,m_data(a6)  ;Zeiger auf die Markerdaten
                  move.w   MARKER_ADDWIDTH(a1),d0
                  mulu.w   d1,d0
                  swap     d0
                  add.w    d1,d0
                  move.w   d0,m_width(a6) ;Markerbreite
                  move.l   a0,d1
                  rts

;Zeiger auf die Polymarker-Strukturen
marker_addrs:     DC.L     m_dot
                  DC.L     m_plus
                  DC.L     m_asterisk
                  DC.L     m_square
                  DC.L     m_cross
                  DC.L     m_diamond

; SET POLYMARKER HEIGHT (VDI 19)
vsm_height:       movea.l  pb_ptsin(a0),a1
                  move.l   (a1),d1        ;Polymarkerhoehe = ptsin[1];
                  subq.w   #1,d1
                  or.w     #1,d1          ;eventuell abrunden
                  bgt.s    vsm_height_plus
                  moveq.l  #M_HEIGHT_MIN,d1
vsm_height_plus:  cmp.w    #M_HEIGHT_MAX,d1
                  ble.s    vsm_height_set
                  move.w   #M_HEIGHT_MAX,d1
vsm_height_set:   move.w   d1,m_height(a6)   ;Markerhoehe
                  move.w   m_type(a6),d0  ;Markertyp
                  add.w    d0,d0
                  add.w    d0,d0
                  bne.s    vsm_height_addr   ;Punkt?
                  moveq.l  #1,d1          ;Hoehe immer 1
vsm_height_addr:  move.l   marker_addrs(pc,d0.w),a1 ;Zeiger auf Struktur
                  move.w   MARKER_ADDWIDTH(a1),d0
                  mulu.w   d1,d0
                  swap     d0
                  add.w    d1,d0
                  move.w   d0,m_width(a6) ;Markerbreite
                  movea.l  pb_ptsout(a0),a1
                  move.w   d0,(a1)+       ;ptsout[0] = Polymarkerbreite;
                  move.w   m_height(a6),(a1)       ;ptsout[1] = Polymarkerhoehe;
                  move.l   a0,d1
                  rts

/*
 * SET POLYMARKER COLOR INDEX (VDI 20)
 */
vsm_color:        movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0
                  cmp.w    colors(a6),d0
                  bls.s    vsm_color_set
                  moveq.l  #BLACK,d0
vsm_color_set:    move.w   d0,(a0)        ;intout[0] = neue Markerfarbe
                  move.w   d0,m_color(a6) ;gesetzte Markerfarbe
                  rts

vdi_fktret:       movem.l  (sp)+,d1-d7/a2-a5
                  rts

vst_height6:      movea.l  pb_ptsout(a0),a1 ;ptsout
                  move.l   #$00070006,d0  /* character width/height */
                  movea.l  #$00080008,a0  /* cell width/height */
                  move.l   d0,(a1)+       /* character width/height */
                  move.l   a0,(a1)+       /* cell width/height */
                  lea.l    t_width(a6),a1
                  move.l   d0,(a1)+       /* t_width / t_height */
                  move.l   a0,(a1)+       /* t_cwidth / t_cheight */
                  lea.l    t_base(a6),a1
                  move.l   #$00060002,(a1)+ /* t_base=6, t_half=2 */
                  moveq.l  #7,d0
                  move.l   d0,(a1)+       /* t_descent=0, t_bottom=7 */
                  swap     d0
                  move.l   d0,(a1)+       /* t_ascent=7, t_top=0 */
                  addq.l   #(t_left_off-t_top-2),a1
                  move.l   #$00010008,(a1)+ /* t_left_off=1, t_whole_off=8 */
                  moveq.l  #0,d0
                  move.l   d0,(a1)+       /* t_thicken=0, t_uline=0 */
                  move.w   d0,t_prop(a6)  /* t_prop=0, t_grow=0 */
                  lea.l    (font_hdr2).w,a0   /* address of fontheader */
                  lea.l    t_fonthdr(a6),a1
                  move.l   a0,(a1)+       /* t_fonthdr */
                  move.l   a0,(CUR_FONT).w  /* compatibility */
                  lea.l    off_table(a0),a0
                  move.l   (a0)+,(a1)+    /* off_table->t_offtab */
                  move.l   (a0)+,(a1)+    /* dat_table->t_image */
                  move.l   (a0)+,(a1)+    /* form_width/form_height -> t_iwidth/t_iheight */
                  rts

vst_height13:     movea.l  pb_ptsout(a0),a1 ;ptsout
                  move.l   #$0007000d,d0  /* character width/height */
                  movea.l  #$00080010,a0  /* cell width/height */
                  move.l   d0,(a1)+       /* character width/height */
                  move.l   a0,(a1)+       /* cell width/height */
                  lea.l    t_width(a6),a1
                  move.l   d0,(a1)+       /* t_width / t_height */
                  move.l   a0,(a1)+       /* t_cwidth / t_cheight */
                  lea.l    t_base(a6),a1
                  move.l   #$000d0005,(a1)+ /* t_base=13, t_half=5 */
                  move.l   #$0002000f,(a1)+ /* t_descent=2, t_bottom=15 */
                  move.l   #$000f0000,(a1)+ /* t_ascent=15, t_top=0 */
                  addq.l   #(t_left_off-t_top-2),a1
                  moveq.l  #0,d0
                  move.l   #$00010008,(a1)+ /* t_left_off=1, t_whole_off=8 */
                  move.l   d0,(a1)+       /* t_thicken=0, t_uline=0 */
                  move.w   d0,t_prop(a6)  /* t_prop=0, t_grow=0 */
                  lea.l    (font_hdr3).w,a0 /* address of fontheader */
                  lea.l    t_fonthdr(a6),a1
                  move.l   a0,(a1)+       /* t_fonthdr */
                  move.l   a0,(CUR_FONT).w  /* compatibility */
                  lea.l    off_table(a0),a0
                  move.l   (a0)+,(a1)+    /* off_table->t_offtab */
                  move.l   (a0)+,(a1)+    /* dat_table->t_image */
                  move.l   (a0)+,(a1)+    /* form_width/form_height -> t_iwidth/t_iheight */
                  rts

/*
 * SET CHARACTER HEIGHT, ABSOLUTE MODE (VDI 12)
 */
vst_height:       movea.l  pb_ptsin(a0),a1 ;ptsin
                  move.l   (a1),d0        /* text height = ptsin[1] */
                  clr.w    t_point_last(a6)
                  cmp.w    t_height(a6),d0
                  beq      vst_h_err
vst_h_save_regs:  movem.l  d1-d7/a2,-(sp)
                  movea.l  pb_ptsout(a0),a2
                  move.w   d0,d1          ;Zeichenhoehe
                  move.w   t_number(a6),d0 ;Zeichensatznummer
                  move.w   d1,d7          ;zu kleine Zeichenhoehe ?
                  bgt.s    vst_h_start
                  moveq.l  #1,d7
vst_h_start:      movea.l  t_pointer(a6),a0
vst_height_in:    movea.l  a0,a1
                  sub.w    top(a1),d1     ;Texthoehendifferenz
                  beq.s    vst_h_calc     ;kein Unterschied ?
                  bpl.s    vst_h_loop     ;negative Hoehendifferenz ?
                  neg.w    d1
vst_h_loop:       move.l   next_font(a1),d2
                  beq.s    vst_h_calc     ;weiterer Font vorhanden ?
                  movea.l  d2,a1          ;Fontzeiger
                  cmp.w    font_id(a1),d0 ;gleicher Zeichensatz ?
                  bne.s    vst_h_calc
                  move.w   d7,d3          ;gewuenschte Hoehe
                  sub.w    top(a1),d3     ;Texthoehendifferenz
                  bpl.s    vst_h_pos
                  neg.w    d3
vst_h_pos:        cmp.w    d1,d3          ;Hoehendifferenz kleiner ?
                  bgt.s    vst_h_loop
                  movea.l  a1,a0          ;Fontzeiger
                  move.w   d3,d1          ;neue Texthoehendifferenz
                  bne.s    vst_h_loop     ;kein Unterschied ?
vst_h_calc:       move.l   a0,t_fonthdr(a6) ;Adresse des Fonts
                  move.l   a0,(CUR_FONT).w  ;Kompatibilitaet
                  movem.l  off_table(a0),d0-d2
                  movem.l  d0-d2,t_offtab(a6) ;t_offtab/t_image/t_iwidth/t_iheight
                  movem.w  first_ade(a0),d2-d3/d6 ; d2=first_ade, d3=last_ade, d6=top
                  btst     #T_MONO_BIT,flags+1(a0)
                  seq      d0             ;Mono-Spaced bzw. Proportional
                  move.b   d0,t_prop(a6)
                  moveq.l  #0,d0
                  move.w   d6,d1
                  sub.w    d7,d1          ;Vergroesserung bzw. Verkleinerung
                  beq.s    vst_h_no_chars
                  moveq.l  #1,d0          ;Vergroesserung
                  tst.w    d1
                  bpl.s    vst_h_no_chars
                  moveq.l  #-1,d0         ;Verkleinerung
vst_h_no_chars:   move.b   d0,t_grow(a6)
                  sub.w    d2,d3          ;Zeichenanzahl
                  movem.w  d2-d3,t_first_ade(a6)   ;t_first_ade/t_ades
                  moveq.l  #'?',d0        ;Zeichen fuer nicht vorhandenen Index
                  sub.w    d2,d0
                  cmp.w    d3,d0
                  bls.s    vst_h_unknown
                  moveq.l  #0,d0
vst_h_unknown:    move.w   d0,t_unknown_index(a6)
                  moveq.l  #' ',d0        ;Index des Leerzeichens
                  sub.w    d2,d0
                  cmp.w    d3,d0
                  bls.s    vst_h_space
                  moveq.l  #0,d0
vst_h_space:      move.w   d0,t_space_index(a6)
                  move.w   left_offset(a0),d0
                  move.w   form_height(a0),d5
                  mulu.w   d7,d5
                  divu.w   d6,d5
                  move.w   d5,d4          ;Zeichenzellenhoehe
                  move.w   d5,d1
                  lsr.w    #1,d1          ;Verbreiterung durch kursiv
                  movem.w  thicken(a0),d2-d3
                  cmp.w    d6,d7          ;Vergroesserung ?
                  beq.s    vst_h_thicken
                  mulu.w   d7,d0
                  mulu.w   d7,d2
                  mulu.w   d7,d3
                  divu.w   d6,d0          ;linker Offset bei Kursivschrift
                  divu.w   d6,d2          ;Verbreiterung bei Fettschrift
                  divu.w   d6,d3          ;Breite der Unterstreichung
vst_h_thicken:    tst.b    t_prop(a6)     ;Font proportional?
                  bne.s    vst_h_thicken2
                  moveq.l  #0,d2
vst_h_thicken2:   cmp.w    #15,d2
                  ble.s    vst_h_ul_size
                  moveq.l  #15,d2
vst_h_ul_size:    subq.w   #1,d3
                  bpl.s    vst_h_offsets
                  moveq.l  #0,d3
vst_h_offsets:    movem.w  d0-d3,t_left_off(a6) ;t_left_off / t_whole_off / t_thicken / t_uline
                  movem.w  max_char_width(a0),d1/d3 ;Zeichenbreite/Zellenbreite
                  move.w   d7,d2          ;Zeichenhoehe
                  cmp.w    d6,d7          ;Vergroesserung ?
                  beq.s    vst_h_ptsout
                  mulu.w   d7,d1
                  mulu.w   d7,d3
                  divu.w   d6,d1          ;neue Zeichenbreite
                  divu.w   d6,d3          ;neue Zeichenzellenbreite
vst_h_ptsout:     movem.w  d1-d4,(a2)     ;ptsout[0...1]
                  movem.w  d1-d4,t_width(a6)

                  move.w   d7,d0          ;Oberkante<->Basislinie
                  move.w   d6,d1
                  sub.w    half(a0),d1    ;Oberkante<->Halblinie
                  move.w   d6,d2
                  sub.w    ascent(a0),d2  ;Oberkante<->Buchstabenoberkante
                  move.w   d4,d3

                  subq.w   #1,d3          ;Oberkante<->Unterkante
                  move.w   d6,d4
                  add.w    descent(a0),d4 ;Oberkante<->Buchstabenunterkante
                  moveq.l  #0,d5          ;Oberkante<->Oberkante
                  cmp.w    d6,d7          ;Vergroesserung ?
                  beq.s    vst_h_exit
                  mulu.w   d7,d1
                  mulu.w   d7,d2
                  mulu.w   d7,d4
                  divu.w   d6,d1
                  divu.w   d6,d2
                  divu.w   d6,d4
vst_h_exit:       movem.w  d0-d5,t_base(a6)
                  movem.l  (sp)+,d1-d7/a2
                  rts
vst_h_err:        movea.l  pb_ptsout(a0),a1
                  move.l   t_width(a6),(a1)+    ;t_width / t_height
                  move.l   t_cwidth(a6),(a1)+   ;t_cwidth / t_cheight
                  rts

vst_point_same:   tst.w    d0
                  ble.s    vst_point0
                  movem.l  pb_intout(a0),a0-a1
                  move.w   d0,(a0)        ;intout[0] = eingestellte Punkthoehe
                  move.l   t_width(a6),(a1)+    ;t_width / t_height
                  move.l   t_cwidth(a6),(a1)+   ;t_cwidth / t_cheight
                  rts

/*
 * SET CHARACTER HEIGHT, POINTS MODE (VDI 107)
 */
vst_point:        movea.l  pb_intin(a0),a1 ;intin
                  move.w   (a1),d0        ;Texthoehe = intin[0];
                  cmp.w    t_point_last(a6),d0
                  beq.s    vst_point_same
vst_point0:       movem.l  d1-d7/a2,-(sp)
                  movea.l  d1,a2
                  move.w   t_number(a6),d0
                  moveq.l  #0,d1
                  move.w   (a1),d1
                  bgt.s    vst_point1        ;zu klein ?
                  moveq.l  #1,d1
                  move.w   d1,t_point_last(a6)
vst_point1:       movea.l  t_pointer(a6),a1  ;Adresse des ersten Fonts
                  moveq.l  #-1,d3
vst_p_loop:       move.l   d1,d5             ;gewuenschte Hoehe
                  move.w   point(a1),d2
                  sub.w    d2,d5
                  bmi.s    vst_p_next        ;zu gross ?
                  cmp.w    d2,d5             ;Vergroesserung noetig ?
                  blt.s    vst_p_cmp
                  sub.w    d2,d5
                  bset     #16,d5            ;Flag fuer Vergroesserung
vst_p_cmp:        cmp.w    d3,d5             ;Punkthoehendifferenz kleiner ?
                  bhi.s    vst_p_next
                  bne.s    vst_p_save
                  btst     #16,d5
                  bne.s    vst_p_next
vst_p_save:       movea.l  a1,a0             ;Fontzeiger
                  move.l   d5,d3
                  beq.s    vst_p_pos         ;Punkthoehendifferenz = 0 ?
vst_p_next:       move.l   next_font(a1),d2
                  beq.s    vst_p_calc        ;kein weiterer Font vorhanden ?
                  movea.l  d2,a1             ;Fontzeiger
                  cmp.w    (a1),d0           ;gleicher Zeichensatz ?
                  beq.s    vst_p_loop
vst_p_calc:       addq.l   #1,d3             ;kleinster Font ?
                  bne.s    vst_p_pos
                  movea.l  t_pointer(a6),a0
                  movea.l  a0,a1
                  move.w   point(a0),d5      ;Hoehe in Punkten
vst_p_small:      move.l   next_font(a1),d2
                  beq.s    vst_p_pos
                  movea.l  d2,a1
                  cmp.w    (a1),d0           ;gleiche Fontnummer ?
                  bne.s    vst_p_pos
                  cmp.w    point(a1),d5      ;kleiner ?
                  ble.s    vst_p_small
                  move.w   (a1),d5
                  movea.l  a1,a0
                  bra.s    vst_p_small
vst_p_pos:        move.w   point(a0),d0
                  move.w   top(a0),d7        ;Zeichenhoehe in Pixeln
                  btst     #16,d3            ;Vergroesserung ?
                  beq.s    vst_set_point
                  add.w    d0,d0
                  add.w    d7,d7
vst_set_point:    movem.l  pb_intout(a2),a1-a2
                  move.w   d0,(a1)           ;intout[0] = set_point;
                  move.w   d0,t_point_last(a6) ;eingestellte Hoehe in Punkten
                  bra      vst_h_calc

; SET CHARACTER BASELINE VECTOR (VDI 13)
vst_rotation:     movea.l  pb_intout(a0),a1  ;intout
                  movea.l  pb_intin(a0),a0   ;intin
                  move.w   (a0),d0        ;Rotationswinkel
                  ext.l    d0
                  divs.w   #3600,d0
                  swap     d0             ;Restwinkel
                  ext.l    d0             ;negativer Winkel ?
                  bpl.s    vst_rot_pos
                  addi.l   #3600,d0
vst_rot_pos:      addi.w   #450,d0        ;Rundung !
                  divu.w   #900,d0        ;0=>0 degree, 1=>90 degree, 2=>180 degree, 3=>270 degree
                  move.w   d0,t_rotation(a6)
                  mulu.w   #900,d0
                  move.w   d0,(a1)
                  rts

; SET TEXT FACE (VDI 21)
vst_font:         movea.l  pb_intin(a0),a1
                  move.w   (a1),d0        ;Zeichensatznummer = intin[0]
                  movea.l  pb_intout(a0),a1
                  move.w   d0,(a1)        ;intout[0] = Zeichensatznummer
                  cmp.w    t_number(a6),d0 ;Zeichensatz schon eingestellt ?
                  beq.s    vst_font_exit

                  movem.l  d1-d7/a2,-(sp) ;Register sichern

                  lea.l    (font_hdr1).w,a0 ;Header des ersten Systemfonts
                  cmp.w    #T_SYSTEM_FACE,d0 ;Systemzeichensatz ?
                  beq.s    vst_font_found
                  move.l   t_bitmap_fonts(a6),d1 ;wurden Fonts per GDOS zugeladen ?
                  beq.s    vst_font_loop
                  movea.l  d1,a0          ;Adresse des ersten zugeladenen Fonts
vst_font_loop:    cmp.w    font_id(a0),d0 ;Zeichensatz gefunden ?
                  beq.s    vst_font_found
                  movea.l  next_font(a0),a0
                  move.l   a0,d1          ;weitere Eintraege ?
                  bne.s    vst_font_loop
                  moveq.l  #T_SYSTEM_FACE,d0
                  lea.l    (font_hdr1).w,a0 ;Systemzeichensatzadresse
                  move.w   d0,(a1)        ;Zeichensatznummer 1
vst_font_found:   move.l   a0,t_pointer(a6)
                  move.l   a0,(CUR_FONT).w  ;der Kompatibilitaet wegen
                  lea.l    (ptsout).w,a2   ;ptsout-Dummy
                  move.w   d0,t_number(a6)
                  clr.b    t_font_type(a6)   ;Bitmap-Font
                  moveq.l  #0,d1
                  move.w   t_point_last(a6),d1 ;letzte Einstellung in Punkten ?
                  bne.s    vst_font_point
                  move.w   t_height(a6),d1 ;einzustellende Zeichenhoehe
                  move.w   d1,d7
                  bra      vst_height_in
vst_font_point:   lea.l    (vdipb).w,a2
                  move.l   #intout,pb_intout(a2) ;intout und ptsout umsetzten
                  move.l   #ptsout,pb_ptsout(a2) ;(gegen ungewollte Ausgaben)
                  bra      vst_point1
vst_font_exit:    rts

; SET GRAPHIC TEXT COLOR INDEX (VDI 22)
vst_color:        movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;Textfarbe
                  cmp.w    colors(a6),d0
                  bhi.s    vst_color_err
vst_color_set:    move.w   d0,(a0)        ;intout[0] = neue Linienfarbe
                  move.w   d0,t_color(a6) ;gesetzte Linienfarbe
                  rts
vst_color_err:    moveq.l  #BLACK,d0      ;intout[0] = BLACK;
                  bra.s    vst_color_set

; SET GRAPHIC TEXT SPECIAL EFFECTS (VDI 106)
vst_effects:      movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  moveq.l  #T_OUTLINED+T_UNDERLINED+T_ITALICS+T_LIGHT+T_BOLD,d0
                  and.w    (a1),d0        ;ausmaskieren
                  move.w   d0,(a0)        ;intout[0] = eingestellter Texteffekt
vst_effects_exit: move.w   d0,t_effects(a6)
                  rts

; SET GRAPHIC TEXT ALIGNMENT (VDI 39)
vst_alignment:    movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1)+,d0       ;horizontale Ausrichtung
                  cmpi.w   #T_RIGHT_ALIGN,d0
                  bls.s    vst_v_alignment
                  moveq.l  #T_LEFT_ALIGN,d0
vst_v_alignment:  swap     d0
                  move.w   (a1),d0        ;vertikale Ausrichtung
                  cmp.w    #T_TOP_ALIGN,d0
                  bls.s    vst_set_align
                  clr.w    d0             ;V_BASE_ALIGN
vst_set_align:    move.l   d0,t_hor(a6)
                  move.l   d0,(a0)
                  rts

;Fehler, falscher Fuelltyp
vsf_int_err:      moveq.l  #F_HOLLOW,d0
                  move.w   d0,(a0)        ;intout[0] = neuer Fuelltyp;
                  move.w   d0,f_interior(a6) ;neuer Fuelltyp
                  lea.l    f_planes(a6),a0
                  clr.w    (a0)
                  bra.s    vsf_int_hollow

/*
 * SET FILL INTERIOR INDEX (VDI 23)
 */
vsf_interior:     movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;Fuelltyp = intin[0];
vsf_int_set:      move.w   d0,(a0)        ;intout[0] = neuer Fuelltyp;
                  move.w   d0,f_interior(a6) ;neuer Fuelltyp
                  subq.w   #F_USER_DEF,d0 ;ungueltiger Fuelltyp ?
                  bhi.s    vsf_int_err
                  lea.l    f_planes(a6),a0
                  clr.w    (a0)
                  move.b   vsf_int_tab+F_USER_DEF(pc,d0.w),d0
                  jmp      vsf_int_user_def(pc,d0.w)

vsf_int_tab:      DC.B vsf_int_hollow-vsf_int_user_def
                  DC.B vsf_int_solid-vsf_int_user_def
                  DC.B vsf_int_pattern-vsf_int_user_def
                  DC.B vsf_int_hatch-vsf_int_user_def
                  DC.B vsf_int_user_def-vsf_int_user_def
                  DC.B 0

;Subroutinen von vsf_interior (Rueckgabewerte: a1 = Musterzeiger)
vsf_int_hollow:   move.l   f_fill0(a6),-(a0) ;Zeiger aufs weisse Fuellmuster -> f_pointer
                  rts
vsf_int_solid:    move.l   f_fill1(a6),-(a0) ;Zeiger aufs schwarze Fuellmuster -> f_pointer
                  rts
vsf_int_pattern:  movea.l  f_fill2(a6),a1 ;Zeiger aufs erste Graustufenmuster
                  move.w   f_style(a6),d0 ;Musterindex
                  subq.w   #1,d0
                  lsl.w    #5,d0          ;*32 wegen Musterauswahl
                  adda.w   d0,a1          ;Zeiger aufs Fuellmuster
                  move.l   a1,-(a0)       ; -> f_pointer
                  rts
vsf_int_hatch:    movea.l  f_fill3(a6),a1 ;Zeiger aufs erste Schraffurmuster
                  move.w   f_style(a6),d0 ;Musterindex
                  subq.w   #1,d0
                  lsl.w    #5,d0          ;*32 wegen Musterauswahl
                  adda.w   d0,a1          ;Zeiger aufs Fuellmuster
                  move.l   a1,-(a0)       ; -> f_pointer
                  rts
vsf_int_user_def: move.w   f_splanes(a6),(a0)   ;Zahl der Planes
                  move.l   f_spointer(a6),-(a0) ;Zeiger aufs selbstdefinierte Muster -> f_pointer
                  rts

/*
 *  SET FILL STYLE INDEX (VDI 24)
 */
vsf_style:        movea.l  pb_intin(a0),a1   ;intin
                  movea.l  pb_intout(a0),a0  ;intout
                  move.w   f_interior(a6),d0 ;Highbyte von d0.w ist sauber !
                  move.b   vsf_style_tab(pc,d0.w),d0
                  jmp      vsf_style_tab(pc,d0.w)

;Tabelle der Subroutinen
vsf_style_tab:    DC.B vsf_sty_hollow-vsf_style_tab
                  DC.B vsf_sty_solid-vsf_style_tab
                  DC.B vsf_sty_pattern-vsf_style_tab
                  DC.B vsf_sty_hatch-vsf_style_tab
                  DC.B vsf_sty_user_def-vsf_style_tab
                  DC.B 0

;Subroutinen von vsf_style
vsf_sty_hollow:
vsf_sty_solid:
vsf_sty_user_def: move.w   (a1),d0        ;Musterindex = intin[0];
                  move.w   d0,(a0)        ;intout[0] = neuer Musterindex;
                  move.w   d0,f_style(a6) ;Musterindex
                  rts
vsf_sty_pattern:  move.w   (a1),d0        ;Musterindex = intin[0];
vsf_sty_pat_save: move.w   d0,(a0)        ;intout[0] = neuer Musterindex;
                  move.w   d0,f_style(a6) ;Musterindex
                  subq.w   #1,d0
                  cmpi.w   #23,d0         ;falscher Musterindex ?
                  bhi.s    vsf_sty_pat_err
                  movea.l  f_fill2(a6),a0 ;Zeiger aufs erste Graustufenmuster
                  lsl.w    #5,d0          ;*32 wegen Musterauswahl
                  adda.w   d0,a0          ;Zeiger aufs Fuellmuster
                  move.l   a0,f_pointer(a6)
                  rts
vsf_sty_pat_err:  moveq.l  #1,d0          ;Musterindex = 1;
                  bra.s    vsf_sty_pat_save

vsf_sty_hatch:    move.w   (a1),d0        ;Musterindex = intin[0];
vsf_sty_hat_save: move.w   d0,(a0)        ;intout[0] = neuer Musterindex;
                  move.w   d0,f_style(a6) ;Musterindex
                  subq.w   #1,d0
                  cmpi.w   #21,d0         ;falscher Musterindex ?
                  bhi.s    vsf_sty_hat_err
                  movea.l  f_fill3(a6),a0 ;Zeiger aufs erste Graustufenmuster
                  lsl.w    #5,d0          ;*32 wegen Musterauswahl
                  adda.w   d0,a0          ;Zeiger aufs Fuellmuster
                  move.l   a0,f_pointer(a6)
                  rts
vsf_sty_hat_err:  moveq.l  #1,d0          ;Musterindex = 1;
                  bra.s    vsf_sty_hat_save

/*
 * SET FILL COLOR INDEX (VDI 25)
 */
vsf_color:        movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;Fuellfarbe
                  cmp.w    colors(a6),d0
                  bhi.s    vsf_color_err
vsf_color_set:    move.w   d0,(a0)        ;intout[0] = neue Musterfarbe
                  move.w   d0,f_color(a6) ;gesetzte Musterfarbe
                  rts
vsf_color_err:    moveq.l  #BLACK,d0      ;intout[0] = BLACK;
                  bra.s    vsf_color_set

/*
 * SET FILL PERIMETER VISIBILITY (VDI 104)
 */
vsf_perimeter:    movea.l  pb_intin(a0),a1 ;intin
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   (a1),d0        ;Flag = intin[0];
                  move.w   d0,f_perimeter(a6)
                  move.w   d0,(a0)        ;intout[0] = Flag;
                  rts

/*
 * SET USER-DEFINED FILL PATTERN (VDI 112)
 */
vsf_udpat:        move.l   a2,-(sp)
                  movea.l  (a0),a1        ;contrl
                  move.w   n_intin(a1),d0 ;Eintraege in intin
                  movea.l  pb_intin(a0),a0   ;intin
                  movea.l  f_spointer(a6),a1
                  movea.l  p_set_pattern(a6),a2
                  jsr      (a2)
                  move.w   d0,f_splanes(a6)
                  cmp.w    #F_USER_DEF,f_interior(a6) ;benutzerdefiniertes Muster eingestellt?
                  bne.s    vsf_udpat_exit
                  move.w   d0,f_planes(a6)   ;Anzahl der Ebenen - 1 des eingestellten Musters
vsf_udpat_exit:   movea.l  (sp)+,a2
                  rts

/*
 * SET GRAY OVERRIDE (VDI 133)
 */
/* BUG: not in dispatch table */
vs_grayoverride:  movea.l  pb_intin(a0),a0 ;intin
                  moveq.l  #0,d0
                  move.w   (a0),d0        ;Grauwert
                  bpl.s    vs_gor_max
                  moveq.l  #0,d0
vs_gor_max:       cmp.w    #1000,d0
                  ble.s    vs_gor_set
                  move.w   #1000,d0
vs_gor_set:       add.w    #62,d0         ;runden (1000/16)
                  divu.w   #125,d0
                  bne.s    vs_gor_addr
                  move.l   f_fill0(a6),f_pointer(a6)
                  clr.w    f_planes(a6)
                  clr.w    f_interior(a6)
                  rts
                  beq.s    vs_gor_addr
                  addq.w   #4,d0          ;die erste Fuellmusteradresse ueberspringen
vs_gor_addr:      move.w   #F_PATTERN,f_interior(a6)
                  move.w   d0,f_style(a6)
                  move.l   f_fill2(a6),a0
                  subq.w   #1,d0
                  lsl.w    #5,d0
                  adda.w   d0,a0
                  move.l   a0,f_pointer(a6)
                  clr.w    f_planes(a6)
                  rts

/*
 * SET RED,GREEN,BLUE INTENSITY (VDI 138)
 */
v_setrgb:
                  rts

;unbekannt (VDI 140)
v140:
;unbekannt (VDI 142)
v142:
                  rts
