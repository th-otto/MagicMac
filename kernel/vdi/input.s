;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;'5. Eingabefunktionen'


; SET INPUT MODE (VDI 33)
vsin_mode:        movea.l  pb_intin(a0),a1 ;intin
                  move.w   (a1)+,d0       ;Einheit = intin[0];
                  move.w   (a1),d1        ;Modus = intin[1];
                  movea.l  pb_intout(a0),a1 ;intout
                  subq.w   #I_MOUSE,d0
                  cmp.w    #I_KEYBOARD-I_MOUSE,d0 ;Einheit 1-4 ?
                  bhi.s    vsin_mode_exit
                  move.w   d1,(a1)        ;intout[0] = set_mode;
                  subq.w   #I_REQUEST,d1
                  beq.s    vsin_mode_req
                  move.w   #I_SAMPLE,(a1)
                  bset     d0,input_mode(a6)    ;Sample-Modus
                  move.l   a0,d1          ;d1 restaurieren (pblock)
                  rts
vsin_mode_req:    move.w   #I_REQUEST,(a1)
                  bclr     d0,input_mode(a6) ;REQUEST-Modus
vsin_mode_exit:   move.l   a0,d1          ;d1 restaurieren (pblock)
                  rts

; INPUT LOCATOR (VDI 28)
v_locator:        movea.l  pb_ptsin(a0),a1 ;ptsin
v_loc_clipx1:     move.w   (a1)+,d0       ;ptsin[0];
                  bpl.s    v_loc_clipx2
                  moveq.l  #0,d0
v_loc_clipx2:     cmp.w    (DEV_TAB0).w,d0
                  ble.s    v_loc_clipy1
                  move.w   (DEV_TAB0).w,d0
v_loc_clipy1:     move.w   (a1)+,d1       ;ptsin[1];
                  bpl.s    v_loc_clipy2
                  moveq.l  #0,d1
v_loc_clipy2:     cmp.w    (DEV_TAB1).w,d1
                  ble.s    v_loc_savexy
                  move.w   (DEV_TAB1).w,d1
v_loc_savexy:     movem.w  d0-d1,(GCURX).w  ;Koordinaten setzen
                  move.l   a0,d1          ;d1 restaurieren (pblock)
                  movem.l  pb_intout(a0),a0-a1 ;intout/ptsout
                  btst     #I_MOUSE-1,input_mode(a6)
                  beq.s    vrq_locator
;Sample-Modus
vsm_locator:      move.w   sr,d0
                  ori.w    #$0700,sr
                  move.l   (GCURX).w,(a1) ;ptsout[0/1] = Maus-x/-y;
                  move.w   (MOUSE_BT).w,(a0) ;intout[0] = Tastenstatus
                  addi.w   #31,(a0)       ;ist noetig
                  movea.l  d1,a0
                  movea.l  (a0),a1        ;contrl
                  tst.w    (MOUSE_BT).w
                  beq.s    vsm_move
                  move.w   #1,v_nintout(a1) ;Eintraege in intout
vsm_move:         btst     #5,(CUR_MS_STAT).w
                  beq.s    vsm_l_exit
                  move.w   #1,v_nptsout(a1) ;Eintraege in ptsout
vsm_l_exit:       andi.b   #3,(CUR_MS_STAT).w
                  move.w   d0,sr
                  rts
;Request-Modus
vrq_locator:      move.w   (MOUSE_BT).w,d0  ;Mausbutton gedrueckt ?
                  beq.s    vrq_locator
                  move.l   (GCURX).w,(a1)   ;ptsout[0/1] = Maus-x/-y;
                  addi.w   #31,d0
                  move.w   d0,(a0)        ;intout[0] = Tastenstatus +31
                  rts

; INPUT VALUATOR (VDI 29) nicht vorhanden
v_valuator:       rts

; INPUT CHOICE (VDI 30)
v_choice:         movem.l  d1-d2/a2-a4,-(sp)
                  movea.l  (a0),a3        ;contrl
                  movea.l  pb_intout(a0),a4 ;intout
                  btst     #I_FUNCTION_KEY-1,input_mode(a6)
                  beq.s    vrq_choice
;Sample-Modus
vsm_choice:       bsr.s    v_status
                  tst.w    d0             ;Zeichen verfuegbar ?
                  beq.s    vsm_choice_n
;Request-Modus
vrq_choice:       bsr.s    v_input        ;Zeichen einlesen
                  move.l   d0,d1
                  swap     d1             ;Tasten-Scancode
                  subi.b   #$3b,d1        ;Funktionstate von 1 bis 10 ?
                  cmpi.b   #9,d1
                  bhi.s    v_choice_out
                  addq.b   #1,d1
                  move.b   d1,d0          ;Funktionstastennummer
v_choice_out:     move.w   d0,(a4)
                  movem.l  (sp)+,d1-d2/a2-a4
                  rts
vsm_choice_n:     clr.w    v_nintout(a3)
                  movem.l  (sp)+,d1-d2/a2-a4
                  rts

;Zeichen verfuegbar ?
v_status:         move.w   #CON,-(sp)     ;Zeichen verfuegbar ?
                  move.w   #BCONSTAT,-(sp)
                  trap     #BIOS
                  addq.l   #4,sp
                  rts

;Zeichencode einlesen
v_input:          move.w   #CON,-(sp)
                  move.w   #BCONIN,-(sp)
                  trap     #BIOS
                  addq.l   #4,sp
                  move.l   d0,d1          ;Bit 0-7  : ASCII-Code
                  swap     d1
                  lsl.w    #8,d1
                  or.w     d1,d0          ;Bit 8-15 : Scancode
                  rts

; INPUT STRING (VDI 31)
v_string:         movem.l  d1-d5/a2-a4,-(sp)
                  movea.l  (a0)+,a3       ;contrl
                  movea.l  (a0)+,a2       ;intin
                  movea.l  pb_intout-pb_ptsin(a0),a4 ;intout

                  move.w   #255,d3        ;Maske
                  move.w   (a2),d4        ;max_length = intin[0]
                  bpl.s    v_string_pos
                  neg.w    d4
                  moveq.l  #-1,d3         ;Scan-Code durchlassen !
v_string_pos:     move.w   d4,d5
                  subq.w   #1,d4          ;Zaehler
                  btst     #I_KEYBOARD-1,input_mode(a6)
                  beq.s    vrq_string
;Sample-Modus
vsm_string:       bsr.s    v_status
                  tst.w    d0
                  beq.s    vsm_str_nos    ;Zeichen verfuegbar ?
                  bsr.s    v_input        ;Zeichen einlesen
                  and.w    d3,d0
                  move.w   d0,(a4)+       ;intout++ = Tastencode;
                  cmpi.b   #13,d0         ;RETURN gedrueckt ?
                  beq.s    vsm_str_ret
                  dbra     d4,vsm_string
vsm_str_nos:      addq.w   #1,d4
vsm_str_ret:      sub.w    d4,d5

                  move.w   d5,v_nintout(a3) ;Zeichenanzahl
                  movem.l  (sp)+,d1-d5/a2-a4
                  rts

;Request-Modus
vrq_string:       bsr.s    v_input        ;Zeichen einlesen
                  and.w    d3,d0
                  move.w   d0,(a4)+       ;intout++ = Tastencode;
                  cmpi.b   #13,d0         ;RETURN gedrueckt ?
                  beq.s    vrq_str_ret
                  dbra     d4,vrq_string
                  addq.w   #1,d4
vrq_str_ret:      sub.w    d4,d5
                  move.w   d5,v_nintout(a3) ;Zeichenanzahl
                  movem.l  (sp)+,d1-d5/a2-a4
                  rts

; SET MOUSE FORM (VDI 111)
vsc_form:         movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a4

                  tst.w    v_nintin(a1)   ;Mausform ausgeben ?
                  bne.s    vsc_form_in
;Mausform in intout ausgeben
vsc_form_out:     move.w   #37,v_nintout(a1)
                  lea.l    (M_POS_HX).w,a0
                  movea.l  a4,a1
                  movem.w  (a0)+,d0-d4
                  movem.w  d0-d4,(a1)
                  lea.l    10(a1),a1
                  movem.w  (a0)+,d0-d7/a2-a5
                  movem.w  d0/d2/d4/d6/a2/a4,(a1) ;Hintergrundmaske
                  movem.w  d1/d3/d5/d7/a3/a5,32(a1) ;Vordergrundmaske
                  movem.w  (a0)+,d0-d7/a2-a5
                  movem.w  d0/d2/d4/d6/a2/a4,12(a1)
                  movem.w  d1/d3/d5/d7/a3/a5,44(a1)
                  movem.w  (a0)+,d0-d7
                  movem.w  d0/d2/d4/d6,24(a1)
                  movem.w  d1/d3/d5/d7,56(a1)
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

;Mausform eintragen
vsc_form_in:      move.w   colors(a6),d5  ;hoechste Farbnummer
vsc_form_in2:     addq.b   #1,(MOUSE_FLAG).w ;Maus darf nicht gezeichnet werden
                  movem.w  (a2)+,d0-d4
vsc_form_bg:      cmp.w    d5,d3          ;ungueltige Hintergrundfarbe ?
                  bls.s    vsc_form_fg
                  moveq.l  #1,d3
vsc_form_fg:      cmp.w    d5,d4          ;ungueltige Vordergrundfarbe ?
                  bls.s    vsc_form_colors
                  moveq.l  #1,d4
vsc_form_colors:  moveq.l  #15,d5
                  and.w    d5,d0          ;Hot-Spot-x
                  and.w    d5,d1          ;Hot-Spot-y
                  movea.l  color_map_tables+_color_map_ptr,a1
                  move.b   0(a1,d3.w),d3  ;Bildebenenzuordnung
                  move.b   0(a1,d4.w),d4  ;Bildebenenzuordnung
                  movem.w  d0-d4,(M_POS_HX).w
                  lea.l    32(a2),a3
                  movem.w  (a2)+,d0/d2/d4/d6/a0/a4 ;Hintergrundmaske
                  movem.w  (a3)+,d1/d3/d5/d7/a1/a5 ;Vordergrundmaske
                  movem.w  d0-d7/a0-a1/a4-a5,(MASK_FORM).w
                  movem.w  (a2)+,d0/d2/d4/d6/a0/a4
                  movem.w  (a3)+,d1/d3/d5/d7/a1/a5
                  movem.w  d0-d7/a0-a1/a4-a5,(MASK_FORM+24).w
                  movem.w  (a2)+,d0/d2/d4/d6
                  movem.w  (a3)+,d1/d3/d5/d7
                  movem.w  d0-d7,(MASK_FORM+48).w
                  move.w   sr,d0
                  ori.w    #$0700,sr      ;Interrupts sperren
                  move.l   (GCURX).w,(CUR_X).w ;Mausposition aktualisieren
                  clr.b    (CUR_FLAG).w     ;beim naechsten VBL Maus zeichnen
                  move.w   d0,sr
                  subq.b   #1,(MOUSE_FLAG).w ;Maus darf gezeichnet werden
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

; EXCHANGE TIMER INTERRUPT VECTOR (VDI 118)
vex_timv:         movea.l  (a0),a1        ;contrl
                  movea.l  pb_intout(a0),a0 ;intout
                  move.w   sr,d0
                  ori.w    #$0700,sr      ;Interrupts sperren
                  move.l   (USER_TIM).w,d_addr(a1) ;contrl[9/10] = USER_TIM;
                  move.l   s_addr(a1),(USER_TIM).w ;USER_TIM = contrl[7/8];
                  move.w   d0,sr          ;altes sr
                  move.w   (timer_ms).w,(a0) ;intout[0] = Timer-Intervall;
                  rts

;SHOW CURSOR (VDI 122)
v_show_c:         tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  bne.s    v_show_c_exit3
                  movea.l  pb_intin(a0),a1
;v_show_c_in:
                  tst.w    (a1)           ;Maus sofort anschalten ?
                  bne.s    v_show_c2
                  tst.w    (M_HID_CNT).w  ;Maus schon an ?
                  beq.s    v_show_c_exit3
                  move.w   #1,(M_HID_CNT).w ;Maus an
v_show_c2:        cmpi.w   #1,(M_HID_CNT).w ;darf die Maus gezeichnet werden ?
                  bgt.s    v_show_c_exit
                  blt.s    v_show_c_exit2
                  movem.l  d1-d7/a2-a5,-(sp)

                  move.w   sr,d2
                  ori.w    #$0700,sr      ;Interrupts sperren
                  movem.w  (GCURX).w,d0-d1  ;GCURX UND GCURY geladen
                  clr.b    (CUR_FLAG).w
                  move.w   d2,sr          ;altes sr
                  lea.l    (M_POS_HX).w,a0
                  movea.l  mouse_tab+_mouse_buffer,a2
                  bsr      draw_sprite    ;Maus zeichnen

                  movem.l  (sp)+,d1-d7/a2-a5
v_show_c_exit:    subq.w   #1,(M_HID_CNT).w
                  rts
v_show_c_exit2:   clr.w    (M_HID_CNT).w     ;Maus darf gezeichnet werden
v_show_c_exit3:   rts

;HIDE CURSOR (VDI 123)
v_hide_c:         tst.w    bitmap_width(a6) ;Off-Screen-Bitmap?
                  bne.s    v_hide_c_exit
                  movem.l  d1-d7/a2-a5,-(sp)
                  lea.l    (M_HID_CNT).w,a2
                  addq.w   #1,(a2)
                  cmpi.w   #1,(a2)        ;Maus noch vorhanden?
                  bne.s    v_hide_c_exit2
                  movea.l  mouse_tab+_mouse_buffer,a2
                  bsr      undraw_sprite  ;Hintergrund zurueckschreiben
v_hide_c_exit2:   movem.l  (sp)+,d1-d7/a2-a5
v_hide_c_exit:    rts

; SAMPLE MOUSE BUTTON STATE (VDI 124)
vq_mouse:         movem.l  pb_intout(a0),a0-a1 ;intout/ptsout
                  move.w   sr,d0
                  ori.w    #$0700,sr
                  move.l   (GCURX).w,(a1) ;ptsout[0] = x; ptsout[1] = y;
                  move.w   (MOUSE_BT).w,(a0) ;intout[0] = Tastenstatus;
                  move.w   d0,sr
                  rts

; EXCHANGE BUTTON CHANGE VECTOR (VDI 125)
vex_butv:         movea.l  (a0),a1        ;contrl
                  move.l   (USER_BUT).w,d_addr(a1) ;contrl[9/10] = USER_BUT;
                  move.l   s_addr(a1),(USER_BUT).w ;USER_BUT = contrl[7/8];
                  rts

; EXCHANGE MOUSE MOVEMENT VECTOR (VDI 126)
vex_motv:         movea.l  (a0),a1        ;contrl
                  move.l   (USER_MOT).w,d_addr(a1) ;contrl[9/10] = USER_MOT;
                  move.l   s_addr(a1),(USER_MOT).w ;USER_MOT = contrl[7/8];
                  rts

; EXCHANGE CURCOR CHANGE VECTOR (VDI 127)
vex_curv:         movea.l  (a0),a1        ;contrl
                  move.l   (USER_CUR).w,d_addr(a1) ;contrl[9/10] = USER_CUR;
                  move.l   s_addr(a1),(USER_CUR).w ;USER_CUR = contrl[7/8];
                  rts

; SAMPLE KEYBOARD STATE INFORMATION (VDI 128)
vq_key_s:         movea.l  pb_intout(a0),a1 ;intout
                  movea.l  (key_state).w,a0
                  moveq.l  #15,d0
                  and.b    (a0),d0
                  move.w   d0,(a1)        ;intout[0] = Tastenstatus
                  rts
