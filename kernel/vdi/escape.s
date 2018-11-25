						;'7. Escape-Funktionen'

; ESCAPE (VDI 5)
v_escape:			move.l	p_escapes(a6),-(sp)
						rts

v_escape_in:		tst.w 	bitmap_width(a6) ;Off-Screen-Bitmap?
						bne 		v_escape_unof
						movea.l	(a0),a1			;contrl
						move.w	opcode2(a1),d0 ;Unteropcode
;Opcodebereich pruefen
						cmp.w 	#V_RMCUR,d0
						bhi.s 	v_escape_unof
						movem.l	d1-d7/a2-a5,-(sp)
						movem.l	pb_intin(a0),a2-a5
						add.w 	d0,d0
						move.w	v_escape_tab(pc,d0.w),d2
						movea.l	a2,a5
						movea.l	a1,a0
						movem.w	V_CUR_XY0.w,d0-d1
						movea.l	V_CUR_AD.w,a1
						movea.w	BYTES_LIN.w,a2
						jsr		v_escape_tab(pc,d2.w)
						movem.l	(sp)+,d1-d7/a2-a5
v_escape_exit: 	rts
v_escape_unof: 	rts

v_escape_tab:		DC.W v_escape_exit-v_escape_tab
						DC.W vq_chcells-v_escape_tab ;1
						DC.W v_exit-v_escape_tab ;2
						DC.W v_enter_cur-v_escape_tab ;3
						DC.W v_curup-v_escape_tab ;4
						DC.W v_curdown-v_escape_tab ;5
						DC.W v_curright-v_escape_tab ;6
						DC.W v_curleft-v_escape_tab ;7
						DC.W v_curhome-v_escape_tab ;8
						DC.W v_eeos-v_escape_tab ;9
						DC.W v_eeol-v_escape_tab ;10
						DC.W v_curaddress-v_escape_tab ;11
						DC.W v_curtext-v_escape_tab ;12
						DC.W v_rvon-v_escape_tab ;13
						DC.W v_rvoff-v_escape_tab ;14
						DC.W vq_curaddress-v_escape_tab ;15
						DC.W vq_tabstatus-v_escape_tab ;16
						DC.W v_hardcopy-v_escape_tab ;17
						DC.W v_dspcur-v_escape_tab ;18
						DC.W v_rmcur-v_escape_tab ;19

; INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS (VDI 5, ESCAPE 1)
vq_chcells: 		move.l	V_CEL_MX.w,d3	;Spalten / Zeilen
						addi.l	#$010001,d3
						swap		d3
						move.l	d3,(a4)
						move.w	#2,n_intout(a0) ;Eintraege in intout
						rts

; EXIT ALPHA MODE (VDI 5, ESCAPE 2)
v_exit:				addq.w	#1,V_HID_CNT.w	;Cursor aus
						bclr		#CURSOR_STATE,RESERVED.w
						bra		clear_screen	;Bildschirm loeschen

; ENTER ALPHA MODE (VDI 5, ESCAPE 3)
v_enter_cur:		clr.l 	V_CUR_XY0.w 	;Spalte 0/Zeile 0
						move.l	v_bas_ad.w,V_CUR_AD.w ;Adresse des Cursors
						move.l	con_vec,con_state.w	;Zeiger auf VT-Routine
						jsr		clear_screen	;Bildschirm loeschen
						bclr		#CURSOR_STATE,RESERVED.w
						move.w	#1,V_HID_CNT.w
						bra		cursor_on		;Cursor an

; DIRECT ALPHA CURSOR ADDRESS (VDI 5, ESCAPE 11)
v_curaddress:		move.w	(a5)+,d1 		;Zeile
						move.w	(a5)+,d0 		;Spalte
						subq.w	#1,d0
						subq.w	#1,d1
						bra		set_cursor_xy

; OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
v_curtext:			moveq 	#0,d1
						move.w	n_intin(a0),d1 ;Zeichenanzahl
						subq.w	#1,d1 			;zu wenig Zeichen ?
						bmi.s 	v_curtext_exit
						movea.l	buffer_addr(a6),a0
						movea.l	a0,a1 			;Bufferadresse
						move.l	buffer_len(a6),d0
						subq.l	#1,d0
						sub.l 	d1,d0 			;zu viele Zeichen ?
						bgt.s 	v_curtext_copy
						add.l 	d1,d0
						move.l	d0,d1 			;Maximalanzahl
v_curtext_copy:	move.w	(a5)+,d0 		;Zeichen einlesen
						move.b	d0,(a1)+ 		;und kopieren
						dbra		d1,v_curtext_copy
						clr.b 	(a1)+ 			;Stringende

						move.l	a0,-(sp) 		;Stringadresse
						move.w	#CCONWS,-(sp)
						trap		#GEMDOS
						addq.l	#6,sp
						
v_curtext_exit:	rts

; INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15)
vq_curaddress: 	addq.w	#1,d0
						addq.w	#1,d1
						move.w	d1,(a4)+ 		;intout[0] = Zeile;
						move.w	d0,(a4)+ 		;intout[1] = Spalte;
						move.w	#2,n_intout(a0) ;Eintraege in intout
						rts

; INQUIRE TABLET STATUS (VDI 5, ESCAPE 16)
vq_tabstatus:		move.w	#1,(a4)			;Maus verfuegbar
						move.w	#1,n_intout(a0)
						rts


v_dspcur:											; PLACE GRAPHIC CURSOR AT LOCATION (VDI 5, ESCAPE 18)
v_rmcur: 											; REMOVE LAST GRAPHIC CURSOR (VDI 5, ESCAPE 19)
						rts
						
; HARD COPY (VDI 5, ESCAPE 17)
v_hardcopy: 		move.w	#SCRDMP,-(sp)
						trap		#XBIOS
						addq.l	#2,sp
						rts

						
						
