;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'6. Auskunftsfunktionen'

/*
 * EXTENDED INQUIRE FUNCTION (VDI 102)
 */
vq_extnd:         movea.l  (a0),a1        ;contrl
                  cmpi.w   #1,opcode2(a1) ;vq_scrninfo?
                  bne.s    vq_extnd2
                  movea.l  pb_intin(a0),a1 ;intin
                  cmpi.w   #2,(a1)        ;vq_scrninfo?
                  beq.s    vq_scrninfo
vq_extnd2:        movem.l  a2-a5,-(sp)
                  movea.l  pb_intin(a0),a4
                  movem.l  pb_intout(a0),a0-a1
                  move.l   device_drvr(a6),d0   ;Geraetetreiber?
                  beq.s    vq_extnd_off
                  movea.l  d0,a2
                  movea.l  driver_addr(a2),a2   ;Zeiger auf den Treiberanfang
                  bra.s    vq_extnd_what
vq_extnd_off:     movea.l  bitmap_drvr(a6),a2   ;Offscreen-Treiber
                  movea.l  DRIVER_code(a2),a2   ;Zeiger auf den Treiberanfang
vq_extnd_what:    movea.l  DRVR_extndinfo(a2),a3
                  tst.w    (a4)                 ;erweiterte Informationen?
                  bne.s    vq_extnd_call
                  movea.l  DRVR_opnwkinfo(a2),a3   ;opnwk-Infos zurueckgeben
vq_extnd_call:    jsr      (a3)
vq_extnd_exit:    movem.l  (sp)+,a2-a5
                  rts

; INQUIRE SCREEN INFORMATION (VDI 102,1)
vq_scrninfo:      move.l   a2,-(sp)
                  movea.l  (a0),a1        ;contrl
                  move.w   #272,n_intout(a1)
                  clr.w    n_ptsout(a1)
                  movea.l  pb_intout(a0),a0 ;intout
                  move.l   device_drvr(a6),d0   ;Geraetetreiber?
                  beq.s    vq_scrninfo_off
                  movea.l  d0,a2
                  movea.l  driver_addr(a2),a2   ;Zeiger auf den Treiberanfang
                  bra.s    vq_scrninfo_call
vq_scrninfo_off:  movea.l  bitmap_drvr(a6),a2   ;Offscreen-Treiber
                  movea.l  DRIVER_code(a2),a2   ;Zeiger auf den Treiberanfang
vq_scrninfo_call: movea.l  DRVR_scrninfo(a2),a2
                  jsr      (a2)
vq_scrninfo_exit: movea.l  (sp)+,a2
                  rts

; INQUIRE COLOR REPRESENTATION (VDI 26)
vq_color:         movea.l  pb_intout(a0),a1 ;intout
                  movea.l  pb_intin(a0),a0 ;intin
                  move.w   (a0)+,d0       ;Farbnummer
                  cmp.w    colors(a6),d0  ;vorhanden ?
                  bhi.s    vq_color_err
                  move.w   d0,(a1)+       ;intout[0] = Farbnummer
                  movem.l  d1-d2,-(sp)
                  move.w   (a0)+,d1
                  movea.l  p_get_color_rgb(a6),a0
                  move.l   a1,-(sp)
                  jsr      (a0)
                  movea.l  (sp)+,a1
                  move.w   d0,(a1)+       ;intout[1]: Rot-Intensitaet
                  move.w   d1,(a1)+       ;intout[2]: Gruen-Intensitaet
                  move.w   d2,(a1)+       ;intout[3]: Blau-Intensitaet
                  movem.l  (sp)+,d1-d2
                  rts
vq_color_err:     move.w   #-1,(a1)       ;intout[0] = Fehler;
                  rts

/*
 *  INQUIRE CURRENT POLYLINE ATTRIBUTES (VDI 35)
 */
vql_attributes:   movem.l  pb_intout(a0),a0-a1   /* intout->a0, ptsout->a1 */
                  move.w   l_style(a6),d0
                  addq.w   #L_SOLID,d0
                  move.w   d0,(a0)+              /* intout[0] = line style */
                  move.w   l_color(a6),(a0)+     /* intout[1] = line color */
                  move.w   wr_mode(a6),d0
                  addq.w   #REPLACE,d0           /* intout[2] = graphic mode */
                  move.w   d0,(a0)+
                  move.l   l_start(a6),(a0)+     /* intout[3/4] = line ends */
                  move.w   l_width(a6),(a1)      /* ptsout[0] = line width */
                  rts

/*
 * INQUIRE CURRENT POLYMARKER ATTRIBUTES (VDI 36)
 */
vqm_attributes:   movem.l  pb_intout(a0),a0-a1   /* intout->a0, ptsout->a1 */
                  move.w   m_type(a6),d0
                  addq.w   #M_DOT,d0
                  move.w   d0,(a0)+              /* intout[0] = marker type */
                  move.w   m_color(a6),(a0)+     /* intout[1] = marker color */
                  move.w   wr_mode(a6),d0
                  addq.w   #REPLACE,d0
                  move.w   d0,(a0)+              /* intout[2] = graphic mode */
                  move.w   m_width(a6),(a1)+     /* ptsout[0] = marker width */
                  move.w   m_height(a6),(a1)     /* ptsout[1] = marker height */
                  rts

/*
 * INQUIRE CURRENT FILL AREA ATTRIBUTES (VDI 37)
 */
vqf_attributes:   movea.l  pb_intout(a0),a1      /* intout */
                  move.w   f_interior(a6),(a1)+  /* intout[0] = fill type */
                  move.w   f_color(a6),(a1)+     /* intout[1] = fill color */
                  move.w   f_style(a6),(a1)+     /* intout[2] = fill style */
                  move.w   wr_mode(a6),d0
                  addq.w   #REPLACE,d0
                  move.w   d0,(a1)+              /* intout[3] = graphic mode */
                  move.w   f_perimeter(a6),(a1)+ /* intout[4] = outline flag */
                  rts

/*
 * INQUIRE CURRENT GRAPHIC TEXT ATTRIBUTES (VDI 38)
 */
vqt_attributes:   movem.l  pb_intout(a0),a0-a1   /* intout->a0, ptsout->a1 */
                  move.w   t_number(a6),(a0)+    /* intout[0] = font number */
                  move.w   t_color(a6),(a0)+     /* intout[1] = text color */
                  move.w   t_rotation(a6),d0
                  tst.b    t_font_type(a6)       /* vectorfont? then value is in 1/10 degree */
                  bne.s    vqt_attr_rot
                  mulu.w   #900,d0
vqt_attr_rot:     move.w   d0,(a0)+              /* intout[2] = text rotation */
                  move.l   t_hor(a6),(a0)+       /* intout[3/4] = h./v. orientation */
                  move.w   wr_mode(a6),d0
                  addq.w   #REPLACE,d0           /* note: not done by TOS VDI */
                  move.w   d0,(a0)               /* intout[5] = graphic mode */
                  move.l   t_width(a6),(a1)+     /* ptsout[0/1] t_width / t_height */
                  move.l   t_cwidth(a6),(a1)     /* ptsout[2/3] t_cwidth / t_cheight */
                  rts

/*
 * INQUIRE TEXT EXTENT (VDI 116)
 */
vqt_extent:       movem.l  d1-d3/a2,-(sp)
                  movea.l  (a0)+,a1       ;contrl
                  move.w   n_intin(a1),d0 ;Zeichenanzahl
                  movea.l  (a0),a1        ;intin
                  movea.l  pb_ptsout-pb_intin(a0),a0 ;ptsout
                  moveq.l  #0,d1
                  moveq.l  #0,d2
                  moveq.l  #0,d3
                  subq.w   #1,d0
                  bmi.s    vqt_ext_height
                  movea.l  t_offtab(a6),a2 ;Tabelle mit Zeichenoffsets
                  tst.b    t_grow(a6)
                  beq.s    vqt_ext_loop2
                  move.w   t_iheight(a6),d1
                  add.w    d1,d1
                  cmp.w    t_cheight(a6),d1 ;doppelte Vergroesserung ?
                  beq.s    vqt_ext_loop2
                  movem.l  d4-d6,-(sp)

                  move.w   t_cheight(a6),d5
                  move.w   t_iheight(a6),d6
vqt_ext_loop1:    move.w   (a1)+,d1       ;Zeichennummer
                  sub.w    t_first_ade(a6),d1 ;Zeichen
                  cmp.w    t_ades(a6),d1  ;vorhanden ?
                  bls.s    vqt_ext_index1
                  move.w   t_unknown_index(a6),d1
vqt_ext_index1:   add.w    d1,d1
                  move.w   2(a2,d1.w),d4
                  sub.w    0(a2,d1.w),d4
                  mulu.w   d5,d4
                  divu.w   d6,d4
                  add.w    d4,d2          ;Breite insgesamt
                  addq.w   #2,d3
vqt_ext_next1:    dbra     d0,vqt_ext_loop1
                  movem.l  (sp)+,d4-d6
                  bra.s    vqt_ext_height

vqt_ext_loop2:    move.w   (a1)+,d1       ;Zeichennummer
                  sub.w    t_first_ade(a6),d1 ;Zeichen
                  cmp.w    t_ades(a6),d1  ;vorhanden ?
                  bls.s    vqt_ext_index2
                  move.w   t_unknown_index(a6),d1
vqt_ext_index2:   add.w    d1,d1
                  add.w    2(a2,d1.w),d2
                  sub.w    0(a2,d1.w),d2  ;Breite insgesamt
                  addq.w   #2,d3
vqt_ext_next2:    dbra     d0,vqt_ext_loop2
                  tst.b    t_grow(a6)
                  beq.s    vqt_ext_height
                  add.w    d2,d2          ;doppelte Vergroesserung
vqt_ext_height:   move.w   t_cheight(a6),d1

;Breite und Hoehe unter Beachtung der Texteffekte veraendern

                  move.w   t_effects(a6),d0
                  btst     #T_OUTLINED_BIT,d0 ;umrandet ?
                  beq.s    vqt_ext_italics
                  add.w    d3,d2          ;2 Pixel Verbreiterung pro Zeichen
                  addq.w   #2,d1          ;und 2 Pixel Erhoehung
vqt_ext_italics:  btst     #T_ITALICS_BIT,d0 ;kursiv ?
                  beq.s    vqt_ext_bold
                  add.w    t_whole_off(a6),d2 ;zusaetzliche Breite
vqt_ext_bold:     btst     #T_BOLD_BIT,d0 ;fett ?
                  beq.s    vqt_ext_rot
                  lsr.w    #1,d3
                  mulu.w   t_thicken(a6),d3
                  add.w    d3,d2
vqt_ext_rot:      moveq.l  #0,d0
                  swap     d2
                  clr.w    d2
                  swap     d2
                  move.w   t_rotation(a6),d3
                  bne.s    vqt_ext90
vqt_ext0:         move.l   d0,(a0)+       ;extent[0...1]
                  move.w   d2,(a0)+       ;extent[2]
                  move.l   d2,(a0)+       ;extent[3...4]
                  move.w   d1,(a0)+       ;extent[5]
                  move.l   d1,(a0)+       ;extent[6...7]
                  movem.l  (sp)+,d1-d3/a2
                  rts
vqt_ext90:        subq.w   #1,d3
                  bne.s    vqt_ext180
                  move.w   d1,(a0)+
                  move.l   d1,(a0)+
                  move.w   d2,(a0)+
                  move.l   d2,(a0)+
                  move.l   d0,(a0)+
                  movem.l  (sp)+,d1-d3/a2
                  rts
vqt_ext180:       subq.w   #1,d3
                  bne.s    vqt_ext270
                  move.w   d2,(a0)+
                  move.w   d1,(a0)+
                  move.l   d1,(a0)+
                  move.l   d0,(a0)+
                  move.w   d2,(a0)+
                  move.w   d0,(a0)+
                  movem.l  (sp)+,d1-d3/a2
                  rts
vqt_ext270:       move.l   d2,(a0)+
                  move.l   d0,(a0)+
                  move.w   d1,(a0)+
                  move.l   d1,(a0)+
                  move.w   d2,(a0)+
                  movem.l  (sp)+,d1-d3/a2
                  rts

; INQUIRE CHARACTER CELL WIDTH (VDI 117)
vqt_width:        movea.l  pb_intin(a0),a1
                  move.w   (a1),d0        ;Zeichennummer = intin[0];
                  movem.l  pb_intout(a0),a0-a1 ;intout/ptsout
                  move.w   d0,(a0)        ;intout[0] = status;
                  sub.w    t_first_ade(a6),d0
                  cmp.w    t_ades(a6),d0  ;Zeichen vorhanden?
                  bls.s    vqt_width_type
                  move.w   #ERROR,(a0)    ;intout[0] = -1; (Fehler)
                  move.w   t_unknown_index(a6),d0
vqt_width_type:   movea.l  t_offtab(a6),a0 ;Zeiger auf Charoffset-table
                  add.w    d0,d0          ;Zeichennummer * 2
                  adda.w   d0,a0
                  moveq.l  #0,d0
                  sub.w    (a0)+,d0
                  add.w    (a0),d0        ;Zeichenbreite
                  tst.b    t_grow(a6)     ;Vergroesserung ?
                  beq.s    vqt_width_cell
                  mulu.w   t_cheight(a6),d0
                  divu.w   t_iheight(a6),d0
                  and.l    #$0000ffff,d0  ;oberes Wort loeschen
vqt_width_cell:   swap     d0             ;ptsout[1] = 0;
                  move.l   d0,(a1)+       ;ptsout[0] = cell_width;
                  moveq.l  #0,d0
                  move.l   d0,(a1)+       ;ptsout[2..3] = 0;
                  move.l   d0,(a1)+       ;ptsout[4..5] = 0;
                  rts

; INQUIRE FACE NAME AND INDEX (VDI 130)
vqt_name:         move.l   d1,-(sp)
                  move.l   d2,-(sp)
                  movea.l  pb_intin(a0),a1
                  move.w   (a1),d0        ;gewuenschter Zeichensatz = intin[0];
                  movea.l  pb_intout(a0),a1
                  moveq.l  #1,d1          ;Zeichensatznummer
                  lea.l    (font_hdr1).w,a0
                  subq.w   #1,d0
                  ble.s    vqt_name_found ;Systemzeichensatz oder Fehler ?
                  subq.w   #1,d0          ;wegen dbra
                  move.l   t_bitmap_fonts(a6),d2 ;Zeichensaetze per GDOS geladen ?
                  bne.s    vqt_name_addr
vqt_name_search:  move.l   next_font(a0),d2 ;Zeiger auf naechsten Font
                  beq.s    vqt_name_err
vqt_name_addr:    movea.l  d2,a0          ;Adresse des Fontheaders
                  cmp.w    (a0),d1        ;noch der gleiche Zeichensatz ?
                  beq.s    vqt_name_search
vqt_name_index:   move.w   (a0),d1        ;neue Zeichensatznummer
                  dbra     d0,vqt_name_search
vqt_name_found:   move.w   d1,(a1)+       ;Fontnummer
                  moveq.l  #7,d0          ;Zaehler
                  addq.l   #name,a0       ;Zeiger auf den Fontnamen
                  moveq.l  #0,d2
vqt_name_copy:    move.l   (a0)+,d1
                  move.l   d2,(a1)+
                  move.l   d2,(a1)+
                  movep.l  d1,-7(a1)      ;4 Bytes des Namens uebertragen
                  dbra     d0,vqt_name_copy
                  move.l   (sp)+,d2
                  move.l   (sp)+,d1
                  rts

vqt_name_err:     moveq.l  #1,d1          ;Default-Zeichensatznummer
                  lea.l    (font_hdr1).w,a0
                  bra.s    vqt_name_found

; INQUIRE CELL ARRAY (VDI 27)
vq_cellarray:     rts                     ;nicht existent

; INQUIRE INPUT MODE (VDI 115)
vqin_mode:        movea.l  pb_intin(a0),a1 ;intin
                  move.w   (a1),d0        ;Eingabeeinheit = intin[0];
                  movea.l  pb_intout(a0),a1 ;intout
                  subq.w   #I_MOUSE,d0
                  cmpi.w   #I_KEYBOARD-I_MOUSE,d0 ;Eingabeeinheit 1-4 ?
                  bhi.s    vqin_mode_exit
                  moveq.l  #I_REQUEST,d1
                  btst     d0,input_mode(a6)
                  beq.s    vqin_write_mode
                  moveq.l  #I_SAMPLE,d1
vqin_write_mode:  move.w   d1,(a1)        ;intout[0] = Eingabemodus;
                  move.l   a0,d1          ;pblock
vqin_mode_exit:   rts

/*
 * INQUIRE CURRENT FACE INFORMATION (VDI 131)
 */
vqt_fontinfo:     movem.l  d1-d4,-(sp)
                  movem.l  pb_intout(a0),a1
                  move.l   t_first_ade(a6),d0
                  add.w    first_ade(a6),d0 ; BUG? first_ade is fonthdr offset, but a6 points to WK and buffer_len is accessed here
                  move.l   d0,(a1)+       ;intout[0/1] = min./max. Index;
                  movea.l  pb_ptsout(a0),a1
                  lea.l    t_height(a6),a0
                  moveq.l  #0,d0
                  moveq.l  #0,d1
                  moveq.l  #0,d4
                  move.w   (a0)+,d4       ;Basislinie<->Zellenobergrenze
                  move.w   (a0)+,(a1)+    ;ptsout[0] = Zellenbreite;
                  lea.l    t_half(a6),a0
                  move.l   d4,d2
                  move.w   d4,d3
                  sub.w    (a0)+,d2       ;Basislinie<->Zeichenhalblinie
                  sub.w    (a0)+,d3       ;Basislinie<->Zeichenobergrenze
                  move.w   (a0)+,d0
                  move.w   (a0)+,d1
                  sub.w    d4,d0          ;Basislinie<->Zellenuntergrenze
                  bpl.s    vqt_fi_base_bot
                  moveq.l  #0,d0          ;fuer Sonderfall t_height = 1
vqt_fi_base_bot:  sub.w    d4,d1          ;Basislinie<->Zeichenuntergrenze
                  swap     d0
                  swap     d1
                  swap     d2
                  btst     #T_BOLD_BIT,t_effects+1(a6) ;fett ?
                  beq.s    vqt_fi_italics
                  move.w   t_thicken(a6),d0 ;Verbreiterungsfaktor
vqt_fi_italics:   btst     #T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
                  beq.s    vqt_fi_save
                  move.w   t_left_off(a6),d1 ;linker Rand;
                  move.w   t_whole_off(a6),d2
                  sub.w    d1,d2          ;rechter Rand;
vqt_fi_save:      move.l   d0,(a1)+
                  move.l   d1,(a1)+
                  move.l   d2,(a1)+
                  move.w   d3,(a1)+
                  move.l   d4,(a1)+
                  movem.l  (sp)+,d1-d4
                  rts
