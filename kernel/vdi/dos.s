SCROLL_LINE			EQU	320

;GEMDOS/BIOS/XBIOS


Blitmode:			move.w	(a0),d0			;Status nur erfragen?
						bmi.s 	Blitmode_nvdi
						lea		blitter,a0
						btst		#1,1(a0) 		;Blitter vorhanden?
						beq.s 	Blitmode_nvdi
						and.w 	#1,d0
						andi.w	#$fffe,(a0)
						or.w		d0,(a0)			;neuen Blitterstatus setzen

Blitmode_nvdi: 	move.w	blitter,d0 ;Blitter-Status
						rte

vdi_cursor:			tst.w 	V_HID_CNT.w					;Cursor ein ?
						bne.s 	vbl_cursor_exit
						subq.b	#1,V_CUR_CT.w				;Cursor zeichnen ?
						bne.s 	vbl_cursor_exit
						move.b	V_PERIOD.w,V_CUR_CT.w	;Blinkdauer
						move.l	cursor_vbl_vec,-(sp)
vbl_cursor_exit:	rts

;Bconout (RAWCON)
vdi_rawout:
rawcon:				lea		6(sp),a0			;Achtung: hier muss lea 6(sp) stehen, da MagiC diese Stelle evtl. ueberspringt
						move.w	(a0),d1
						and.w 	#$ff,d1
						movea.l	rawcon_vec,a0
						jmp		(a0)

;Bconout(CON)
vdi_conout:
bconout:				lea		6(sp),a0			;Achtung: hier muss lea 6(sp) stehen, da MagiC diese Stelle evtl. ueberspringt
						move.w	(a0),d1
						and.w 	#$ff,d1
						movea.l	con_state.w,a0
						jmp		(a0)

;Cursor positionieren
;Eingabe
;d0 Textspalte
;d1 Textzeile
;Ausgabe
;a1 Cursoradresse
;zerstoert werden d0-d2
set_cursor_xy: 	bsr		cursor_off
set_cur_clipx1:	move.w	V_CEL_MX.w,d2
						tst.w 	d0
						bpl.s 	set_cur_clipx2
						moveq 	#0,d0
set_cur_clipx2:	cmp.w 	d2,d0
						ble.s 	set_cur_clipy1
						move.w	d2,d0
set_cur_clipy1:	move.w	V_CEL_MY.w,d2
						tst.w 	d1
						bpl.s 	set_cur_clipy2
						moveq 	#0,d1
set_cur_clipy2:	cmp.w 	d2,d1
						ble.s 	set_cursor
						move.w	d2,d1
set_cursor: 		movem.w	d0-d1,V_CUR_XY0.w
						movea.l	v_bas_ad.w,a1
						mulu		V_CEL_WR.w,d1
						adda.l	d1,a1 			;Zeilenadresse
						moveq		#1,d1
						and.w		d0,d1
						and.w 	#$fffe,d0
						mulu		PLANES.w,d0
						add.w		d1,d0
						adda.w	d0,a1 			;Cursoradresse
						adda.w	V_CUR_OF.w,a1	;Offset
						move.l	a1,V_CUR_AD.w
						bra.s 	cursor_on

;Cursor ausschalten
cursor_off: 		addq.w	#1,V_HID_CNT.w	;Hochzaehlen
						cmpi.w	#1,V_HID_CNT.w
						bne.s 	cursor_off_exit
						bclr		#CURSOR_STATE,RESERVED.w ;Cursor sichtbar ?
						bne.s 	cursor
cursor_off_exit:	rts

;Cursor einschalten
cursor_on:			cmpi.w	#1,V_HID_CNT.w
						bcs.s 	cursor_on_exit2
						bhi.s 	cursor_on_exit1
						move.b	V_PERIOD.w,V_CUR_CT.w
						bsr.s 	cursor
						bset		#CURSOR_STATE,RESERVED.w ;Cursor sichtbar
cursor_on_exit1:	subq.w	#1,V_HID_CNT.w
cursor_on_exit2:	rts


vbl_cursor: 		btst		#CURSOR_BL,RESERVED.w ;Blinken ein ?
						beq.s 	vbl_no_bl
						bchg		#CURSOR_STATE,RESERVED.w
						bra.s 	cursor
vbl_no_bl:			bset		#CURSOR_STATE,RESERVED.w
						beq.s 	cursor
						rts

;Cursor zeichnen
cursor:				movem.l	d0-d2/a0-a2,-(sp)
						move.w	PLANES.w,d0 	;Planezaehler
						subq.w	#1,d0
						move.w 	V_CEL_HT.w,d2
						subq.w	#1,d2
						movea.l	V_CUR_AD.w,a0		;Cursoradresse
						movea.w	BYTES_LIN.w,a2		;Bytes pro Zeile
cursor_bloop:		movea.l	a0,a1
						move.w	d2,d1
cursor_loop:		not.b 	(a1)
						adda.w	a2,a1					;naechste Zeile
						dbra		d1,cursor_loop
						addq.l	#2,a0 				;naechste Plane
						dbra		d0,cursor_bloop	;Bildebenen abarbeiten
						movem.l	(sp)+,d0-d2/a0-a2
cursor_exit:		rts

;BEL, Klingelzeichen
vt_bel:				btst		#2,conterm.w	;Glocke an ?
						beq.s 	cursor_exit
						movea.l	bell_hook.w,a0
						jmp		(a0)


;Glocke erzeugen
make_pling:			pea		pling(pc)		;Sequenz fuer Yamaha-Chip
						move.w	#DOSOUND,-(sp)
						trap		#XBIOS
						addq.l	#6,sp
						rts
pling:				DC.B $00,$34,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
						DC.B $08,$10,$09,$00,$0a,$00,$0b,$00,$0c,$10,$0d,$09,$ff,$00


;BACKSPACE, ein Zeichen zurueck
;d0 Textspalte
;d1 Textzeile
vt_bs:				movem.w	V_CUR_XY0.w,d0-d1
						subq.w	#1,d0 			;eine Spalte zurueck
						bra		set_cursor_xy

;HT
;d0 Textspalte
;d1 Textzeile
vt_ht:				andi.w	#$fff8,d0		;maskieren
						addq.w	#8,d0 			;naechster Tabulator
						bra		set_cursor_xy

;LINEFEED, naechste Zeile
;d1 Textzeile
vt_lf:				pea		cursor_on(pc)
						bsr		cursor_off
						sub.w 	V_CEL_MY.w,d1
						beq		scroll_up_page
						move.w	V_CEL_WR.w,d1	;d1: High-Word=0 ! (durch movem.w)
						add.l 	d1,V_CUR_AD.w	;naechste Textzeile
						addq.w	#1,V_CUR_XY1.w
						rts

;RETURN, Zeilenanfang
;d0 Textspalte
vt_cr:				bsr		cursor_off
						pea		cursor_on(pc)
						movea.l	V_CUR_AD.w,a1

;Cursor an den Zeilenanfang setzen
;Eingabe
;d0 Cursorspalte
;a1 Cursoradresse
;Ausgabe
;a1 neue Cursoradresse
;zerstoert werden d0/d2
set_x0:				move.w	PLANES.w,d2
						btst		#0,d0				;Wortgrenze oder Byteposition?
						beq.s		set_x0_even		
						subq.w	#1,d0
						mulu		d2,d0
						addq.l	#1,d0
						bra.s		set_x0_addr
set_x0_even:		mulu		d2,d0
set_x0_addr:		suba.l	d0,a1
						move.l	a1,V_CUR_AD.w
						clr.w 	V_CUR_XY0.w
						rts

;ESC
vt_esc:				move.l	#vt_esc_seq,con_state.w ;Sprungadresse
						rts

vt_control: 		cmpi.w	#27,d1
						beq.s 	vt_esc
						subq.w	#7,d1
						subq.w	#6,d1
						bhi.s 	vt_c_exit
						move.l	#vt_con,con_state.w ;Sprungadresse
						add.w 	d1,d1
						move.w	vt_c_tab(pc,d1.w),d2
						movem.w	V_CUR_XY0.w,d0-d1 ;Textspalte/-zeile
						jmp		vt_c_tab(pc,d2.w)
vt_c_exit:			rts

						DC.W vt_bel-vt_c_tab 	;7  BEL
						DC.W vt_bs-vt_c_tab		;8  BS
						DC.W vt_ht-vt_c_tab		;9  HT
						DC.W vt_lf-vt_c_tab		;10 LF
						DC.W vt_lf-vt_c_tab		;11 VT
						DC.W vt_lf-vt_c_tab		;12 FF
vt_c_tab:			DC.W vt_cr-vt_c_tab		;13 CR

vt_con: 				cmpi.w	#32,d1			;Steuerzeichen ?
						blt		vt_control
vt_rawcon: 			move.l	d3,-(sp)
						move.w	V_CEL_HT.w,d0
						subq.w	#1,d0
						movea.l	V_FNT_AD.w,a0	;Fontimageadresse
						movea.l	V_CUR_AD.w,a1	;Cursoradresse
						movea.w	BYTES_LIN.w,a2 ;Bytes pro Zeile
						adda.w	d1,a0 			;Adresse des Zeichens(-Offset)
						move.w	PLANES.w,d2
						subq.w	#1,d2 			;Planezaehler
						move.l	V_COL_BG.w,d3	;Hintergrundfarbe/Vordergrundfarbe
						move.b	#4,V_CUR_CT.w	;Blinkzaehler hochsetzen -> kein Cursor
						bclr		#CURSOR_STATE,RESERVED.w ;Cursor nicht sichtbar
						btst		#INVERSE,RESERVED.w ;invertieren ?
						beq.s 	vtc_char_loop
						swap		d3 				;Hinter- und Vordergrundfarbe tauschen
vtc_char_loop: 	movem.l	d0/a0-a1,-(sp)
						pea		vtc_char_next(pc)
						lsr.l 	#1,d3 			;Vordergrundfarbe ?
						bcc.s 	vtc_char_fg0
						btst		#15,d3
						beq		vtc_charx
						bra		vtc_bg_black
vtc_char_fg0:		btst		#15,d3			;Hintergrundfarbe ?
						bne		vtc_charrev
						bra		vtc_bg_white
vtc_char_next:		movem.l	(sp)+,d0/a0-a1
						addq.l	#2,a1 			;naechste Plane
						dbra		d2,vtc_char_loop
						move.l	(sp)+,d3
						move.w	V_CUR_XY0.w,d0
						cmp.w 	V_CEL_MX.w,d0	;letzte Spalte ?
						bge.s 	vtc_l_column
						addq.w	#1,V_CUR_XY0.w ;naechste Spalte
						lsr.w 	#1,d0 			;Planeoffset dazu ?
						bcs.s 	vtc_n_column
						addq.l	#1,V_CUR_AD.w	;naechste Spalte
						rts
vtc_n_column:		subq.l	#1,a1
						move.l	a1,V_CUR_AD.w
						rts
vtc_l_column:		btst		#WRAP,RESERVED.w ;Wrapping ein ?
						beq.s 	vtc_con_exit1
						addq.w	#1,V_HID_CNT.w	;Cursor sperren
						subq.w	#1,d0
						mulu		PLANES.w,d0

						addq.w	#1,d0
						movea.l	V_CUR_AD.w,a1
						suba.w	d0,a1
						move.l	a1,V_CUR_AD.w	;Zeilenanfang
						clr.w 	V_CUR_XY0.w
						move.w	V_CUR_XY1.w,d1

						pea		vtc_con_exit2(pc)
						cmp.w 	V_CEL_MY.w,d1	;letzte Zeile (Scrolling) ?
						bge		scroll_up_page
						addq.l	#4,sp 			;Stack korriegieren
						adda.w	V_CEL_WR.w,a1	;naechste Zeile
						move.l	a1,V_CUR_AD.w
						addq.w	#1,V_CUR_XY1.w
vtc_con_exit2: 	subq.w	#1,V_HID_CNT.w	;Cursor zulassen
vtc_con_exit1: 	rts

vtc_charx:			move.b	(a0),(a1)
						lea		256(a0),a0		;naechste Fontzeile
						adda.w	a2,a1 			;naechste Bilschirmzeile
						dbra		d0,vtc_charx
						rts						

vtc_charrev:		move.b	(a0),d1
						not.b		d1
						move.b	d1,(a1)
						lea		256(a0),a0		;naechste Fontzeile
						adda.w	a2,a1 			;naechste Bilschirmzeile
						dbra		d0,vtc_charrev
						rts						

;d0 Zeichenoehe - 1
;a1 Cursoradresse
;a2 Bytes pro Zeile
vtc_bg_white:		moveq 	#0,d1
						bra.s 	vtc_bg
vtc_bg_black:		moveq 	#$ffffffff,d1
vtc_bg:				move.b	d1,(a1)
						adda.w	a2,a1
						dbra		d0,vtc_bg
						rts

;;;;;;;;;;;;;;;;;;;;;;;
;ESC SEQUENZ abarbeiten
;;;;;;;;;;;;;;;;;;;;;;;
vt_esc_seq: 		cmpi.w	#89,d1			;ESC Y ?
						beq		vt_seq_Y
						move.w	d1,d2

						movem.w	V_CUR_XY0.w,d0-d1 ;Textspalte/-zeile
						movea.l	V_CUR_AD.w,a1	;Cursoradresse
						movea.w	BYTES_LIN.w,a2 ;Bytes pro Zeile
						move.l	#vt_con,con_state.w ;Sprungadresse

vt_seq_tA:			subi.w	#65,d2			;>=65 & <= 77 ?
						cmpi.w	#12,d2
						bhi.s 	vt_seq_tb
						add.w 	d2,d2
						move.w	vt_seq_tab1(pc,d2.w),d2
						jmp		vt_seq_tab1(pc,d2.w)

vt_seq_tb:			subi.w	#33,d2			;>=98 & <= 119 ?
						cmpi.w	#21,d2
						bhi.s 	vt_seq_exit
						add.w 	d2,d2
						move.w	vt_seq_tab2(pc,d2.w),d2
						jmp		vt_seq_tab2(pc,d2.w)
;Beendet bei falschen Opcode
vt_seq_exit:		rts

vt_seq_tab1:		DC.W vt_seq_A-vt_seq_tab1
						DC.W vt_seq_B-vt_seq_tab1
						DC.W vt_seq_C-vt_seq_tab1
						DC.W vt_seq_D-vt_seq_tab1
						DC.W vt_seq_E-vt_seq_tab1
						DC.W vt_seq_exit-vt_seq_tab1
						DC.W vt_seq_exit-vt_seq_tab1
						DC.W vt_seq_H-vt_seq_tab1
						DC.W vt_seq_I-vt_seq_tab1
						DC.W vt_seq_J-vt_seq_tab1
						DC.W vt_seq_K-vt_seq_tab1
						DC.W vt_seq_L-vt_seq_tab1
						DC.W vt_seq_M-vt_seq_tab1

vt_seq_tab2:		DC.W vt_seq_b-vt_seq_tab2
						DC.W vt_seq_c-vt_seq_tab2
						DC.W vt_seq_d-vt_seq_tab2
						DC.W vt_seq_e-vt_seq_tab2
						DC.W vt_seq_f-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_j-vt_seq_tab2
						DC.W vt_seq_k-vt_seq_tab2
						DC.W vt_seq_l-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_o-vt_seq_tab2
						DC.W vt_seq_p-vt_seq_tab2
						DC.W vt_seq_q-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_exit-vt_seq_tab2
						DC.W vt_seq_v-vt_seq_tab2
						DC.W vt_seq_w-vt_seq_tab2

;d0 Textspalte
;d1 Textzeile
;a1 Cursoradresse
;a2 Bytes pro Zeile

; ALPHA CURSOR UP (VDI 5, ESCAPE 4)/ Cursor up (VT 52 ESC A)
v_curup:
vt_seq_A:			subq.w	#1,d1
						bra		set_cursor_xy

;ALPHA CURSOR DOWN (VDI 5,ESCAPE 5)/ Cursor down (VT52 ESC B)
v_curdown:
vt_seq_B:			addq.w	#1,d1
						bra		set_cursor_xy

; ALPHA CURSOR RIGHT (VDI 5, ESCAPE 6)/ Cursor right (VT52 ESC C)
v_curright:
vt_seq_C:			addq.w	#1,d0
						bra		set_cursor_xy

; ALPHA CURSOR LEFT (VDI 5, ESCAPE 7)/ Cursor left (VT52 ESC D)
v_curleft:
vt_seq_D:			subq.w	#1,d0
						bra		set_cursor_xy

;Clear screen (VT52 ESC E)
vt_seq_E:			bsr		cursor_off
						bsr		clear_screen
						bra.s 	vt_seq_H_in

; HOME ALPHA CURSOR (VDI 5, ESCAPE 8)/ Home Cursor (VT52 ESC H)
v_curhome:
vt_seq_H:			bsr		cursor_off
vt_seq_H_in:		clr.l 	V_CUR_XY0.w
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1
						move.l	a1,V_CUR_AD.w
						bra		cursor_on

;Cursor up and insert (VT52 ESC I)
vt_seq_I:			pea		cursor_on(pc)
						bsr		cursor_off
						subq.w	#1,d1 			;Cursor bereits in der obersten Zeile ?
						blt		scroll_down_page
						suba.w	V_CEL_WR.w,a1	;eine Zeile nach oben
						move.l	a1,V_CUR_AD.w
						move.w	d1,V_CUR_XY1.w
						rts

; ERASE TO END OF ALPHA SRCEEN (VDI 5, ESCAPE 9)/ Erase to end of page (VT52 ESC J)
v_eeos:
vt_seq_J:			bsr.s 	vt_seq_K 		;Bis zum Zeilenende loeschen
						move.w	V_CUR_XY1.w,d1 ;Textzeile
						move.w	V_CEL_MY.w,d2	;maximale Textzeile
						sub.w 	d1,d2 			;Anzahl der zu loeschenden Textzeilen
						beq.s 	vt_seq_J_exit
						movem.l	d2-d7/a1-a6,-(sp)
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1
						addq.w	#1,d1
						mulu		V_CEL_WR.w,d1
						adda.l	d1,a1 			;Startadresse
						move.w	d2,d7
						mulu		V_CEL_HT.w,d7
						subq.w	#1,d7 			;Anzahl der zu loeschenden Bildzeilen -1
						bra		clear_lines 	;Zeilen loeschen/Register zurueck
vt_seq_J_exit: 	rts

; ERASE TO END OF ALPHA TEXT LINE (VDI 5, ESCAPE 10)
v_eeol:
;Clear to end of line (VT52 ESC K)
vt_seq_K:			bsr		cursor_off
						move.w	V_CEL_MX.w,d2
						sub.w 	d0,d2 			;Anzahl der zu loeschenden Zeichen - 1
						bsr		clear_line_part
						bra		cursor_on

;Insert line (VT52 ESC I)
vt_seq_L:			pea		cursor_on(pc)
						bsr		cursor_off
						bsr		set_x0			;Cursor an Zeilenanfang
						movem.l	d2-d7/a1-a6,-(sp) ;Register sichern

						move.w	V_CEL_MY.w,d7
						move.w	d7,d5
						sub.w 	d1,d7 			;letzte Zeile ?
						beq.s 	vt_seq_L_exit
						move.w	V_CEL_WR.w,d6	;Bytes pro Textzeile
						mulu		d6,d5
						movea.l	v_bas_ad.w,a0
						adda.w	V_CUR_OF.w,a0
						adda.l	d5,a0 			;Quelladresse
						lea		0(a0,d6.w),a1	;Zieladresse
						mulu		d6,d7 			;Anzahl der Bytes
						divu		#SCROLL_LINE,d7 ;320-Byte-Zaehler
						subq.w	#1,d7 			;wegen dbf
						bsr		scroll_down
vt_seq_L_exit: 	movea.l	V_CUR_AD.w,a1	;Startadresse
						bra		clear_line2 	;Zeile loeschen/ Register zurueck

;Delete Line (VT52 ESC M)
vt_seq_M:			pea		cursor_on(pc)
						bsr		cursor_off
						bsr		set_x0			;Cursor an Zeilenanfang
						movem.l	d2-d7/a1-a6,-(sp) ;Register sichern
						move.w	V_CEL_MY.w,d7
						sub.w 	d1,d7 			;nur letzte Zeile loeschen ?
						beq		clear_line2
						move.w	V_CEL_WR.w,d6	;Bytes pro Buchstabenzeile
						lea		0(a1,d6.w),a0	;Quelladresse
						mulu		d6,d7 			;Anzahl der Bytes
						divu		#SCROLL_LINE,d7 ;320-Byte-Zaehler
						subq.w	#1,d7 			;wegen dbf
						bra		scroll_up2		;Scrollen/loeschen/Register/Cursor an

;Set cursor position (VT52 ESC Y)
vt_seq_Y:			move.l	#vt_set_y,con_state.w ;Sprungadresse
						rts

;y-Koordinate setzen
vt_set_y:			subi.w	#32,d1
						move.w	V_CUR_XY0.w,d0
						move.l	#vt_set_x,con_state.w ;Sprungadresse
						bra		set_cursor_xy

;x-Koordinate setzen
vt_set_x:			subi.w	#32,d1
						move.w	d1,d0
						move.w	V_CUR_XY1.w,d1
						move.l	#vt_con,con_state.w ;Sprungadresse
						bra		set_cursor_xy

;Foreground color (VT52 ESC b)
vt_seq_b:			move.l	#vt_set_b,con_state.w
						rts

vt_set_b:			moveq		#15,d0
						and.w		d0,d1
						cmp.w		d0,d1
						bne.s		vt_set_b_exit
						moveq		#$ffffffff,d1
vt_set_b_exit: 	move.w	d1,V_COL_FG.w	;Vordergrundfarbe
						move.l	#vt_con,con_state.w ;Sprungadresse
						rts

;Background color (VT52 ESC c)
vt_seq_c:			move.l	#vt_set_c,con_state.w
						rts

vt_set_c:			moveq		#15,d0
						and.w 	d0,d1
						cmp.w		d0,d1
						bne.s		vt_set_c_exit
						moveq		#$ffffffff,d1
vt_set_c_exit: 	move.w	d1,V_COL_BG.w	;Vordergrundfarbe
						move.l	#vt_con,con_state.w ;Sprungadresse
						rts

;Erase to start of page (VT52 ESC d)
vt_seq_d:			bsr.s 	vt_seq_o 		;ab Zeilenanfang loeschen
						move.w	V_CUR_XY1.w,d1 ;Textzeile
						beq.s 	vt_seq_d_exit
						movem.l	d2-d7/a1-a6,-(sp)
						mulu		V_CEL_HT.w,d1
						move.w	d1,d7
						subq.w	#1,d7 			;Zeilenzaehler
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1	;Seitenanfang
						bra		clear_lines 	;loeschen/Register zurueck
vt_seq_d_exit: 	rts

;Show cursor (VT52 ESC e)
vt_seq_e:			tst.w 	V_HID_CNT.w
						beq.s 	vt_seq_e_exit
						move.w	#1,V_HID_CNT.w
						bra		cursor_on
vt_seq_e_exit: 	rts

;Hide cursor (VT52 ESC f)
vt_seq_f:			bra		cursor_off

;Save cursor (VT52 ESC j)
vt_seq_j:			bset		#CURSOR_SAVED,RESERVED.w
						move.l	V_CUR_XY0.w,V_SAV_XY.w
						rts

;Restore cursor (VT52 ESC k)
vt_seq_k:			movem.w	V_SAV_XY.w,d0-d1

						bclr		#CURSOR_SAVED,RESERVED.w
						bne		set_cursor_xy
						moveq 	#0,d0
						moveq 	#0,d1
						bra		set_cursor_xy

;Erase line (VT52 ESC l)
vt_seq_l:			bsr		cursor_off
						bsr		set_x0			;Zeilenanfang
						bsr		clear_line
						bra		cursor_on

;Erase to line start (VT52 ESC o)
vt_seq_o:			move.w	d0,d2
						subq.w	#1,d2 			;Spaltenanzahl -1
						bmi.s 	vt_seq_o_exit
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1
						mulu		V_CEL_WR.w,d1
						adda.l	d1,a1 			;Zeilenanfang
						bra		clear_line_part
vt_seq_o_exit: 	rts

;REVERSE VIDEO ON (VDI 5, ESCAPE 13)/Reverse video (VT52 ESC p)
v_rvon:
vt_seq_p:			bset		#INVERSE,RESERVED.w
						rts

; REVERSE VIDEO OFF (VDI 5, ESCAPE 14)/Normal Video (VT52 ESC q)
v_rvoff:
vt_seq_q:			bclr		#INVERSE,RESERVED.w
						rts

;Wrap at end of line (VT52 ESC v)
vt_seq_v:			bset		#WRAP,RESERVED.w
						rts

;Discard end of line (VT52 ESC w)
vt_seq_w:			bclr		#WRAP,RESERVED.w
						rts

scroll_up_page:	movem.l	d2-d7/a1-a6,-(sp)
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1
						movea.l	a1,a0
						move.w	V_CEL_WR.w,d7	;Bytes pro Textzeile
						adda.w	d7,a0
						mulu		V_CEL_MY.w,d7	;* Zeilenanzahl
						divu		#SCROLL_LINE,d7
						subq.w	#1,d7 			;wegen dbf
scroll_up2: 		pea		clear_line2(pc)
scroll_up:			REPT 4
						movem.l	(a0)+,d2-d6/a2-a6
						movem.l	d2-d6/a2-a6,(a1)
						movem.l	(a0)+,d2-d6/a2-a6
						movem.l	d2-d6/a2-a6,40(a1)

						lea		80(a1),a1
						ENDM
						dbra		d7,scroll_up
						swap		d7
						lsr.w 	#1,d7
						dbra		d7,scroll_upw
						rts
scroll_upw: 		move.w	(a0)+,(a1)+
						dbra		d7,scroll_upw
						rts

scroll_down_page: movem.l	d2-d7/a1-a6,-(sp)
						movea.l	v_bas_ad.w,a0
						adda.w	V_CUR_OF.w,a0
						move.w	V_CEL_WR.w,d6	;Bytes pro Textzeile
						move.w	V_CEL_MY.w,d7	;zu scrollenden Textzeilenanzahl
						mulu		d6,d7 			;zu verschiebende Byteanzahl
						lea		-40(a0,d7.l),a0 ;Ende der vorletzten Textzeile -40
						lea		40(a0,d6.w),a1 ;Ende der letzten Textzeile
						divu		#SCROLL_LINE,d7
						subq.w	#1,d7 			;wegen dbf
						bsr.s 	scroll_down2
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1
						bra.s 	clear_line2
scroll_down:		lea		-40(a0),a0
scroll_down2:		REPT 4
						movem.l	(a0),d2-d6/a2-a6
						movem.l	d2-d6/a2-a6,-(a1)
						movem.l	-40(a0),d2-d6/a2-a6
						movem.l	d2-d6/a2-a6,-(a1)
						lea		-80(a0),a0
						ENDM
						dbra		d7,scroll_down2
						swap		d7
						lea		40(a0),a0		;um die -40 zu korrigieren !
						lsr.w 	#1,d7
						dbra		d7,scroll_downw
						rts
scroll_downw:		move.w	-(a0),-(a1)
						dbra		d7,scroll_downw
						rts

;Eingabe
;a1 Zeilenadresse
clear_line: 		movem.l	d2-d7/a1-a6,-(sp)
clear_line2:		move.w	V_CEL_HT.w,d7
						subq.w	#1,d7
clear_lines:		move.w	V_CEL_MX.w,d5
						addq.w	#1,d5
						move.w	V_COL_BG.w,d6
						movea.w	BYTES_LIN.w,a2
						move.w	PLANES.w,d2
						cmp.w 	#8,d2 			;mehr als 8 Planes?
						bgt		clear_line_uni
						add.w 	d2,d2
						move.w	clear_tab(pc,d2.w),d2
						jmp		clear_tab(pc,d2.w)

clear_tab:			DC.W clear_lines_ex-clear_tab
						DC.W clear_mono-clear_tab
						DC.W clear_color2-clear_tab
						DC.W clear_lines_ex-clear_tab
						DC.W clear_color4-clear_tab
						DC.W clear_lines_ex-clear_tab
						DC.W clear_lines_ex-clear_tab
						DC.W clear_lines_ex-clear_tab
						DC.W clear_color8-clear_tab

clear_mono: 		moveq 	#0,d2
						lsr.w 	#1,d6
						negx.l	d2 				;je nach V_COL_BG schwarz oder weiss
						suba.w	d5,a2
						subq.w	#4,d5
						lsr.w 	#2,d5 			;/4
						bcc.s 	clear_mono2
						lea		clear_scr_word(pc),a3
						move.w	d5,d6
						lsr.w 	#7,d5 			;/128 Zaehler

						not.w 	d6
						and.w 	#127,d6
						add.w 	d6,d6
						lea		clear_scr_mono(pc,d6.w),a4 ;Sprungadresse
						move.w	d5,d6
						jmp		(a3)
clear_mono2:		move.w	d5,d6
						lsr.w 	#7,d5 			;/128 Zaehler
						not.w 	d6
						and.w 	#127,d6
						add.w 	d6,d6
						lea		clear_scr_mono(pc,d6.w),a3 ;Sprungadresse
;d5 Zaehler innerhalb der Zeile
;d7 Zeilenzaehler
;a2 Differenz bis zur naechsten Zeile
;a3 Sprungadresse
clear_scrm_loop:	move.w	d5,d6
						jmp		(a3)
clear_scr_word:	move.w	d2,(a1)+
						jmp		(a4)
clear_scr_mono:	REPT 128
						move.l	d2,(a1)+
						ENDM
						dbra		d6,clear_scr_mono
						adda.w	a2,a1 			;naechste Zeile
						dbra		d7,clear_scrm_loop
clear_lines_ex:	movem.l	(sp)+,d2-d7/a1-a6
						rts

clear_color2:		add.w 	d5,d5
						moveq 	#0,d2
						lsr.w 	#1,d6
						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
						swap		d2
						lsr.w 	#1,d6
						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
clear_regs2:		move.l	d2,d3
clear_regs4:		move.l	d2,d4
						movea.l	d3,a4
clear_regs8:		suba.w	d5,a2
						subq.w	#1,d5
						lsr.w 	#2,d5 			;/4
						move.w	d5,d6
						lsr.w 	#7,d5 			;/128 Zaehler
						not.w 	d6
						and.w 	#127,d6
						add.w 	d6,d6
						lea		clear_scr_line(pc,d6.w),a3 ;Sprungadresse
;d5 Zaehler innerhalb der Zeile
;d7 Zeilenzaehler
;a2 Differenz bis zur naechsten Zeile
;a3 Sprungadresse
clear_scr_loop:	move.w	d5,d6
						jmp		(a3)

clear_scr_line:	REPT 32
						move.l	d2,(a1)+
						move.l	d3,(a1)+
						move.l	d4,(a1)+
						move.l	a4,(a1)+
						ENDM
						dbra		d6,clear_scr_line
						adda.w	a2,a1 			;naechste Zeile
						dbra		d7,clear_scr_loop
						movem.l	(sp)+,d2-d7/a1-a6
						rts
clear_color4:		add.w 	d5,d5
						add.w 	d5,d5
						moveq 	#0,d2
						moveq 	#0,d3
						lsr.w 	#1,d6
						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
						swap		d2
						lsr.w 	#1,d6

						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
						lsr.w 	#1,d6
						negx.w	d3 				;je nach V_COL_BG schwarz oder weiss
						swap		d3
						lsr.w 	#1,d6
						negx.w	d3 				;je nach V_COL_BG schwarz oder weiss
						bra		clear_regs4
clear_color8:		moveq 	#0,d2
						moveq 	#0,d3
						moveq 	#0,d4
						moveq 	#0,d5
						lsr.w 	#1,d6
						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
						swap		d2
						lsr.w 	#1,d6
						negx.w	d2 				;je nach V_COL_BG schwarz oder weiss
						lsr.w 	#1,d6
						negx.w	d3 				;je nach V_COL_BG schwarz oder weiss
						swap		d3
						lsr.w 	#1,d6
						negx.w	d3 				;je nach V_COL_BG schwarz oder weiss
						lsr.w 	#1,d6
						negx.w	d4 				;je nach V_COL_BG schwarz oder weiss
						swap		d4
						lsr.w 	#1,d6
						negx.w	d4 				;je nach V_COL_BG schwarz oder weiss
						lsr.w 	#1,d6
						negx.w	d5 				;je nach V_COL_BG schwarz oder weiss
						swap		d5
						lsr.w 	#1,d6
						negx.w	d5 				;je nach V_COL_BG schwarz oder weiss
						movea.l	d5,a4
						move.w	V_CEL_MX.w,d5
						addq.w	#1,d5
						lsl.w 	#3,d5
						bra		clear_regs8

clear_line_uni:	addq.w	#1,d7 			;Zeilenanzahl
						mulu		BYTES_LIN.w,d7
						lsr.l 	#5,d7
						subq.l	#1,d7
						moveq 	#$ffffffff,d6
clear_uni_loop:	REPT 8
						move.l	d6,(a1)+
						ENDM
						subq.l	#1,d7
						bpl.s 	clear_uni_loop

						movem.l	(sp)+,d2-d7/a1-a6
						rts

;Bildschirm loeschen
;Eingaben
; -
;Ausgaben
;kein Register wird zerstoert
clear_screen:		movem.l	d2-d7/a1-a6,-(sp)
						move.w	V_CEL_MY.w,d7	;Textzeilenanzahl -1
						addq.w	#1,d7
						mulu		V_CEL_HT.w,d7
						subq.w	#1,d7 			;Zeilenanzahl -1
						movea.l	v_bas_ad.w,a1
						adda.w	V_CUR_OF.w,a1	;Startadresse
						bra		clear_lines

;Bereich einer Textzeile loeschen
;Eingaben
;d2.w Spaltenanzahl -1
;a1.l Adresse
;a2.w Bytes pro Zeile
;Ausgaben
;d0-d2/a0-a1 werden zerstoert
clear_line_part:	movem.l	d3-d6/a3-a4,-(sp)
						move.w	V_COL_BG.w,d4	;Hintergrundfarbe
						move.w	PLANES.w,d5
						move.w	d5,d6
						add.w 	d5,d5 			;Planeoffset
						subq.w	#1,d6 			;Planezaehler
						movea.l	a1,a3
clear_lp_bloop:	move.w	d2,d3
						movea.l	a3,a0
						lea		vtc_bg_white(pc),a4
						lsr.w 	#1,d4
						bcc.s 	clear_lp_loop
						lea		vtc_bg_black(pc),a4
clear_lp_loop: 	movea.l	a0,a1
						move.w 	V_CEL_HT.w,d0
						subq.w	#1,d0				;Zeilen - 1
						jsr		(a4)
						addq.l	#1,a0
						move.l	a0,d1
						lsr.w 	#1,d1
						bcs.s 	clear_lp_dbf
						subq.l	#2,a0
						adda.w	d5,a0				
clear_lp_dbf:		dbra		d3,clear_lp_loop
						addq.l	#2,a3 			;naechste Plane
						dbra		d6,clear_lp_bloop
						movem.l	(sp)+,d3-d6/a3-a4
						rts

