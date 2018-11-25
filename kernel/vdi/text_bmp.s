;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						;'allgemeine Textausgabe'

;teilweise Textausgabe
text_partitial:
						move.l	t_image(a6),-(sp)

						exg		d0,d2
						exg		d1,d3
						move.w	t_rotation(a6),d7 ;0 Grad ?
						beq.s 	text_part_loop
						subq.w	#T_ROT_90,d7	;90 Grad ?
						beq.s 	text_part_loop
						exg		d1,d3
						subq.w	#T_ROT_180-T_ROT_90,d7 ;180 Grad ?
						beq.s 	text_part_loop
						exg		d1,d3
						exg		d0,d2

text_part_loop:

						move.w	t_act_line(a6),d0 ;Zeichenzeile ohne Effekte
						move.w	t_cheight(a6),d1 ;Zeichenzellenhoehe

						btst		#T_OUTLINED_BIT,t_effects+1(a6)
						beq.s 	text_part_line
						moveq 	#16,d5			;Zeilenanzahl - 1
						tst.w 	d0 				;die obersten Zeilen ?
						beq.s 	text_part_clipy
						subq.w	#1,d0
						sub.w 	d0,d1
						cmp.w 	d5,d1 			;die letzten Zeilen ?
						ble.s 	text_part_clipy
						moveq 	#17,d5			;Zeilenanzahl - 1
						bra.s 	text_part_clipy

text_part_line:	moveq 	#15,d5			;Zeilenanzahl - 1
						sub.w 	d0,d1
						cmp.w 	d5,d1
						bgt.s 	text_part_clipy
						subq.w	#1,d1
						move.w	d1,d5 			;Zeilenanzahl - 1

text_part_clipy:	move.w	d3,d4
						add.w 	d5,d4

						movea.l	(sp),a1			;t_image
						movem.w	d2-d3,-(sp) 	;x/y auf den Stack
						move.w	d6,-(sp) 		;Zeichenzaehler
						move.w	a3,-(sp) 		;Bufferanfangsbreite
						move.l	a5,-(sp) 		;intin

						mulu		t_iheight(a6),d0
						divu		t_cheight(a6),d0
						mulu		t_iwidth(a6),d0
						adda.l	d0,a1
						move.l	a1,t_image(a6)

text_part_fill:

						move.w	t_space_kind(a6),-(sp)
						move.w	t_add_length(a6),-(sp)
						bsr		fill_text_buf	;alles in den Buffer kopieren
						move.w	(sp)+,t_add_length(a6)
						move.w	(sp)+,t_space_kind(a6)

;d4 Bufferbreite - 1
;d5 Bufferhoehe - 1
						movea.l	buffer_addr(a6),a0 ;Adresse des Textbuffers
						movea.w	a3,a2 			;Breite des Textbuffers in Bytes

						move.w	t_effects(a6),d7
						beq.s 	text_part_output
text_part_bold:	btst		#T_BOLD_BIT,d7 ;fett ?
						beq.s 	text_part_underlined
						bsr		bold
text_part_underlined:btst	#T_UNDERLINED_BIT,t_effects+1(a6) ;unterstrichen ?
						beq.s 	text_part_outlined
						pea		text_part_outlined(pc)
						btst		#T_OUTLINED_BIT,t_effects+1(a6)
						beq		underline
						addq.l	#4,sp 			;Stack korrigieren
						adda.w	a2,a0
						bsr		underline
						suba.w	a2,a0
text_part_outlined:btst 	#T_OUTLINED_BIT,1+t_effects(a6) ;umrandet ?
						beq.s 	text_part_lightend
						bsr		outline
						subq.w	#2,d5
						move.w	t_act_line(a6),d0 ;die obersten Zeilen ?
						beq.s 	text_part_lightend
						adda.w	a2,a0
						adda.w	a2,a0 			;die obersten Zeilen ignorieren !
						addi.w	#16,d0			;Text komplett ausgegeben ?
						cmp.w 	t_cheight(a6),d0 ;die letzten Zeilen ?
						bge.s 	text_part_lightend
						subq.w	#2,d5
text_part_lightend:btst 	#T_LIGHT_BIT,1+t_effects(a6) ;hell ?
						beq.s 	text_part_output
						bsr		light

text_part_output: movea.l	(sp)+,a5
						movea.w	(sp)+,a3
						move.w	(sp)+,d6
						movem.w	(sp)+,d2-d3 	;x/y
						move.w	t_rotation(a6),d7 ;Textdrehung ?
						bne.s 	textp_rot90
text_part_rot0:	btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						bne.s 	text_part_ital0
						movem.l	d2-d6/a1/a3/a5,-(sp)
						bsr		textblt_xs0
						movem.l	(sp)+,d2-d6/a1/a3/a5

text_part_next:	addq.w	#1,d5
						add.w 	d5,d3
						moveq 	#16,d1
						add.w 	t_act_line(a6),d1
						move.w	d1,t_act_line(a6)
						move.w	t_cheight(a6),d5
						sub.w 	d1,d5 			;noch Zeilen auszugeben ?
						bgt		text_part_loop
text_part_exit:	move.l	(sp)+,t_image(a6)
						rts

text_part_ital0:	movem.w	d3/d5-d6,-(sp)
						tst.w 	t_act_line(a6)
						bne.s 	text_part_skew0
						sub.w 	t_left_off(a6),d2
						add.w 	t_whole_off(a6),d2
text_part_skew0:	move.w	#$5555,d6	;t_skew_mask

						moveq 	#0,d1
						move.w	d5,d7
textp_ital_loop0: moveq 	#0,d5
						movem.l	d1-a5,-(sp)
						moveq 	#0,d0
						bsr		textblt
						movem.l	(sp)+,d1-a5
						ror.w 	#1,d6
						bcc.s 	textp_ital_next0
						subq.w	#1,d2
textp_ital_next0: addq.w	#1,d3 			;naechste Zielzeile
						addq.w	#1,d1 			;naechste Quellzeile
						dbra		d7,textp_ital_loop0
						movem.w	(sp)+,d3/d5-d6
						bra.s 	text_part_next

textp_rot90:		subq.w	#T_ROT_90,d7	;Textdrehung um 90 degree ?
						bne.s 	textp_rot180

						movem.l	d6/a3/a5,-(sp)
						bsr		rotate90 		;Zeichen um 90 degree drehen
						movem.l	(sp)+,d6/a3/a5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						bne.s 	textp_ital90
						movem.l	d2-d6/a3/a5,-(sp)
						bsr		textblt_xs0
						movem.l	(sp)+,d2-d6/a3/a5

text_part_next90: addq.w	#1,d4
						add.w 	d4,d2
						moveq 	#16,d1
						add.w 	t_act_line(a6),d1
						move.w	d1,t_act_line(a6)
						move.w	t_cheight(a6),d5
						sub.w 	d1,d5 			;noch Zeilen auszugeben ?
						bgt		text_part_loop

						move.l	(sp)+,t_image(a6)
						rts

textp_ital90:		movem.w	d2/d4-d6,-(sp)
						tst.w 	t_act_line(a6)
						bne.s 	text_part_skew90
						add.w 	t_left_off(a6),d3
						sub.w 	t_whole_off(a6),d3
text_part_skew90: move.w	#$5555,d6		;t_skew_mask
						moveq 	#0,d0
						move.w	d4,d7
textp_ital_loop90:moveq 	#0,d4
						movem.l	d0/d2-a5,-(sp)
						bsr		textblt_ys0
						movem.l	(sp)+,d0/d2-a5
						ror.w 	#1,d6
						bcc.s 	textp_ital_next90
						addq.w	#1,d3
textp_ital_next90:addq.w	#1,d2
						addq.w	#1,d0 			;naechste Quellzeile
						dbra		d7,textp_ital_loop90
						movem.w	(sp)+,d2/d4-d6
						bra.s 	text_part_next90

textp_rot180:		subq.w	#T_ROT_180-T_ROT_90,d7 ;Textdrehung um 180 degree ?
						bne.s 	textp_rot270
						movem.l	d6/a3/a5,-(sp)
						bsr		rotate180		;Zeichen um 180 degree drehen
						movem.l	(sp)+,d6/a3/a5
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						bne.s 	textp_ital180
						sub.w 	d5,d3
						movem.l	d2-d6/a3/a5,-(sp)
						bsr		textblt_xs0
						movem.l	(sp)+,d2-d6/a3/a5

						subq.w	#1,d3
text_part_next180:moveq 	#16,d1
						add.w 	t_act_line(a6),d1
						move.w	d1,t_act_line(a6)
						move.w	t_cheight(a6),d5
						sub.w 	d1,d5 			;noch Zeilen auszugeben ?
						bgt		text_part_loop
						move.l	(sp)+,t_image(a6)
						rts

textp_ital180: 	movem.w	d5-d6,-(sp)
						tst.w 	t_act_line(a6)
						bne.s 	text_part_skew180
						add.w 	t_left_off(a6),d2
						sub.w 	t_whole_off(a6),d2
text_part_skew180:move.w	#$5555,d6		;t_skew_mask
						move.w	d5,d7
						move.w	d5,d1
textp_ital_loop180:moveq	#0,d5
						movem.l	d1-a5,-(sp)

						moveq 	#0,d0
						bsr		textblt
						movem.l	(sp)+,d1-a5
						ror.w 	#1,d6
						bcc.s 	textp_ital_next180
						addq.w	#1,d2
textp_ital_next180:subq.w	#1,d3
						subq.w	#1,d1 			;naechste Quellzeile
						dbra		d7,textp_ital_loop180
						movem.w	(sp)+,d5-d6
						bra.s 	text_part_next180

textp_rot270:

						movem.l	d6/a3/a5,-(sp)
						bsr		rotate270		;Zeichen um 270 degree drehen
						movem.l	(sp)+,d6/a3/a5
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						bne.s 	textp_ital270
						sub.w 	d4,d2
						movem.l	d2-d6/a3/a5,-(sp)
						bsr		textblt_xs0
						movem.l	(sp)+,d2-d6/a3/a5

						subq.w	#1,d2
text_part_next270:moveq 	#16,d1
						add.w 	t_act_line(a6),d1
						move.w	d1,t_act_line(a6)
						move.w	t_cheight(a6),d5
						sub.w 	d1,d5 			;noch Zeilen auszugeben ?
						bgt		text_part_loop


						move.l	(sp)+,t_image(a6)
						rts
textp_ital270: 	movem.w	d5-d6,-(sp)
						tst.w 	t_act_line(a6)
						bne.s 	text_part_skew270
						sub.w 	t_left_off(a6),d3
						add.w 	t_whole_off(a6),d3

text_part_skew270:move.w	#$5555,d6		;t_skew_mask(a6)
						move.w	d4,d0
						move.w	d4,d7
textp_ital_loop270:moveq	#0,d4
						movem.l	d0/d2-a5,-(sp)
						bsr		textblt_ys0
						movem.l	(sp)+,d0/d2-a5
						ror.w 	#1,d6
						bcc.s 	textp_ital_next270
						subq.w	#1,d3
textp_ital_next270:subq.w	#1,d2
						subq.w	#1,d0 			;naechste Quellzeile
						dbra		d7,textp_ital_loop270
						movem.w	(sp)+,d5-d6
						bra.s 	text_part_next270

;Allgemeine Textroutine
;Eingaben
;a1 contrl
;a2 intin
;a3 ptsin
;a6 Zeiger auf die Workstation
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
text: 				move.w	n_intin(a1),d6 ;Zeichenanzahl
						ble.s 	text_exit		;genuegend ?
						subq.w	#1,d6 			;Zeichenzaehler

						clr.l 	t_act_line(a6) ;t_act_line/t_add_length loeschen

						moveq 	#0,d5
						move.w	t_effects(a6),d0
						btst		#T_BOLD_BIT,d0 ;fett ?
						beq.s 	text_eff_out
						move.w	t_thicken(a6),d5 ;Verbreiterung durch Fettschrift
text_eff_out:		btst		#T_OUTLINED_BIT,d0 ;umrandet?
						beq.s 	text_thicken
						addq.w	#2,d5 			;Verbreiterung durch die Umrandung
text_thicken:		move.w	d5,t_eff_thicken(a6) ;Verbreiterung durch Effekte

						movea.l	t_fonthdr(a6),a0
						move.l	dat_table(a0),t_image(a6) ;Adresse des Fontimage
						movea.l	a2,a5 			;Adresse von intin
						movea.l	t_offtab(a6),a4 ;Adresse der Zeichenoffsets

						tst.b 	t_prop(a6)		;Proportionalschrift ?
						beq.s 	text_mono

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						moveq 	#-1,d4			;Gesambreite vorbesetzen
						move.w	d6,d7 			;Zeichenzaehler

text_width: 		move.w	(a2)+,d2 		;Zeichennummer
						sub.w 	d0,d2
						cmp.w 	d1,d2 			;Zeichen vorhanden ?
						bls.s 	text_width_char
						move.w	t_unknown_index(a6),d2
text_width_char:	add.w 	d2,d2
						move.w	2(a4,d2.w),d3
						sub.w 	0(a4,d2.w),d3	;Zeichenbreite ohne Vergroesserung
						tst.b 	t_grow(a6)		;Vergroesserung ?
						beq.s 	text_width_add
						mulu		t_cheight(a6),d3 ;* Zeichenhoehe
						divu		t_iheight(a6),d3 ;/ vorhandene Hoehe
text_width_add:	add.w 	d5,d3 			;+ Verbreiterung durch Effekte
						add.w 	d3,d4
						dbra		d7,text_width
						tst.w 	d4 				;mindestens 1 Pixel breit ?
						bpl.s 	text_position
text_exit:			rts

text_mono:			move.w	t_cwidth(a6),d4 ;Zeichenbreite
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						addq.w	#1,d6
						mulu		d6,d4 			;* Zeichenanzahl
						subq.w	#1,d6
						subq.w	#1,d4 			;Breite aller Zeichen -1

text_position: 	move.w	(a3)+,d0 		;x
						move.w	(a3)+,d1 		;y


						move.w	t_ver(a6),d3	;vertikale Ausrichtung
						add.w 	d3,d3
						move.w	t_base(a6,d3.w),d3 ;Verschiebung nach oben

						move.w	t_cheight(a6),d5
						subq.w	#1,d5 			;Zeichenhoehe in Zeilen -1

						btst		#T_OUTLINED_BIT,t_effects+1(a6) ;umrandet ?
						beq.s 	text_alignment
						addq.w	#1,d3 			;um eine Zeile weiter nach oben
						addq.w	#2,d5 			;2 Zeilen hoeher

text_alignment:	moveq 	#0,d2 			;Verschiebung nach links
						move.w	t_hor(a6),d7	;horizontale Ausrichtung
						beq.s 	text_left		;linksjustiert ?
						subq.w	#T_MID_ALIGN,d7 ;zentriert ?
						bne.s 	text_right
						move.w	d4,d2
						addq.w	#1,d2
						asr.w 	#1,d2
						bra.s 	text_left
text_right: 		move.w	d4,d2 			;rechtsjustiert
text_left:			move.w	t_rotation(a6),d7 ;Textdrehung ?
						beq		text_clip_rot0
						subq.w	#T_ROT_90,d7	;90 Grad ?
						bne		text_clip_rot180

						tst.w 	t_add_length(a6) ;Dehnung ?
						beq.s 	text_cl900_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl900_x1
						sub.w 	t_left_off(a6),d1 ;Verschiebung nach oben

text_cl900_x1: 	sub.w 	d3,d0 			;x1
						add.w 	d2,d1
						move.w	d0,d2
						move.w	d1,d3 			;y2
						add.w 	d5,d2 			;x2
						sub.w 	d4,d1 			;y1

						cmp.w 	clip_xmax(a6),d0 ;zu weit rechts ?
						bgt.s 	text_exit
						cmp.w 	clip_xmin(a6),d2 ;zu weit links ?
						blt.s 	text_exit

						cmp.w 	clip_ymax(a6),d1 ;zu weit unten ?
						ble.s 	text_cl90_top
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d1,d7
						add.w 	t_left_off(a6),d7
						sub.w 	t_whole_off(a6),d7
						cmp.w 	clip_ymax(a6),d7
						bgt		text_exit

text_cl90_top: 	cmp.w 	clip_ymin(a6),d3 ;zu weit oben ?
						bge.s 	text_cl90_y1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d3,d7
						add.w 	t_left_off(a6),d7
						cmp.w 	clip_ymin(a6),d7
						blt		text_exit

text_cl90_y1:		cmp.w 	clip_ymin(a6),d1
						bge		text_cl90_y2

						movem.w	d0/d2-d5,-(sp)

						movem.w	t_first_ade(a6),d2-d3 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte
						move.w	d6,d7 			;Zeichenzaehler
						add.w 	d7,d7
						lea		2(a5,d7.w),a2

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl90_y1_loop
						add.w 	t_left_off(a6),d1 ;linke Zeichengrenze

text_cl90_y1_loop:move.w	-(a2),d0 		;Zeichennummer
						sub.w 	d2,d0
						cmp.w 	d3,d0 			;Zeichen vorhanden ?
						bls.s 	text_cl90_y1_width
						move.w	t_unknown_index(a6),d2
text_cl90_y1_width:add.w	d0,d0
						move.w	2(a4,d0.w),d4
						sub.w 	0(a4,d0.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						add.w 	d4,d1

						cmp.w 	clip_ymin(a6),d1 ;ausserhalb des Clipping-Rechtecks ?
						bgt.s 	text_cl90_y1_end
						tst.w 	d6
						beq.s 	text_cl90_y1_end

						move.w	t_add_length(a6),d7 ;Dehnung ?

						beq.s 	text_cl90_y1_next
						ext.l 	d7
						move.w	t_space_kind(a6),d0 ;zeichenweise Dehnung ?
						bmi.s 	text_cl90_y1_char
						cmpi.w	#SPACE,(a2) 	;Leerzeichen ?
						bne.s 	text_cl90_y1_next
						divs		d0,d7
						add.w 	d7,d1
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl90_y1_loop ;Zeichenzaehler dekrementieren
text_cl90_y1_char:divs		d6,d7
						sub.w 	d7,t_add_length(a6)
						add.w 	d7,d1
text_cl90_y1_next:dbra		d6,text_cl90_y1_loop

text_cl90_y1_end: sub.w 	d4,d1
						movem.w	(sp)+,d0/d2-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl90_y2
						sub.w 	t_left_off(a6),d1 ;linke Zeichengrenze

text_cl90_y2:		cmp.w 	clip_ymax(a6),d3
						ble		text_cl270_width


						movem.w	d0-d2/d4-d5,-(sp)

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl90_y2_loop
						add.w 	t_left_off(a6),d3
						sub.w 	t_whole_off(a6),d3 ;rechte Zeichengrenze

text_cl90_y2_loop:move.w	(a5)+,d2 		;Zeichennummer
						sub.w 	d0,d2
						cmp.w 	d1,d2 			;Zeichen vorhanden ?
						bls.s 	text_cl90_y2_width
						move.w	t_unknown_index(a6),d2
text_cl90_y2_width:add.w	d2,d2
						move.w	2(a4,d2.w),d4
						sub.w 	0(a4,d2.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						sub.w 	d4,d3

						cmp.w 	clip_ymax(a6),d3 ;innerhalb des Clipping-Rechtecks ?
						blt.s 	text_cl90_y2_end
						tst.w 	d6
						beq.s 	text_cl90_y2_end

						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl90_y2_next
						ext.l 	d7
						move.w	t_space_kind(a6),d2 ;zeichenweise Dehnung ?
						bmi.s 	text_cl90_y2_char
						cmpi.w	#SPACE,-2(a5)	;Leerzeichen ?
						bne.s 	text_cl90_y2_next
						divs		d2,d7
						sub.w 	d7,d3
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl90_y2_loop ;Zeichenzaehler dekrementieren
text_cl90_y2_char:divs		d6,d7
						sub.w 	d7,t_add_length(a6)
						sub.w 	d7,d3
text_cl90_y2_next:dbra		d6,text_cl90_y2_loop ;Zeichenzaehler dekrementieren

text_cl90_y2_end: add.w 	d4,d3 			;Ausgabeposition
						subq.l	#2,a5 			;erstes auszugebendes Zeichen
						movem.w	(sp)+,d0-d2/d4-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_cl270_width
						sub.w 	t_left_off(a6),d3
						add.w 	t_whole_off(a6),d3
						bra		text_cl270_width

text_clip_rot180: subq.w	#T_ROT_180-T_ROT_90,d7 ;180 Grad ?
						bne		text270

						tst.w 	t_add_length(a6) ;Dehnung ?
						beq.s 	text_cl1800_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl1800_x1
						sub.w 	t_left_off(a6),d0 ;Verschiebung nach links

text_cl1800_x1:	add.w 	d2,d0
						add.w 	d3,d1
						move.w	d0,d2 			;x2
						move.w	d1,d3 			;y2
						sub.w 	d4,d0 			;x1
						sub.w 	d5,d1 			;y1

						cmp.w 	clip_ymax(a6),d1 ;zu weit unten ?
						bgt		text_exit
						cmp.w 	clip_ymin(a6),d3 ;zu weit oben ?
						blt		text_exit

						cmp.w 	clip_xmax(a6),d0 ;zu weit rechts ?
						ble.s 	text_cl180_left
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d0,d7
						add.w 	t_left_off(a6),d7
						sub.w 	t_whole_off(a6),d7
						cmp.w 	clip_xmax(a6),d7
						bgt		text_exit

text_cl180_left:	cmp.w 	clip_xmin(a6),d2 ;zu weit links ?
						bge.s 	text_cl180_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d2,d7
						add.w 	t_left_off(a6),d7
						cmp.w 	clip_xmin(a6),d7
						blt		text_exit

text_cl180_x1: 	cmp.w 	clip_xmin(a6),d0
						bge		text_cl180_x2


						movem.w	d1-d5,-(sp)

						movem.w	t_first_ade(a6),d2-d3 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte
						move.w	d6,d7
						add.w 	d7,d7

						lea		2(a5,d7.w),a2

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl180_x1_loop
						add.w 	t_left_off(a6),d0 ;linke Zeichengrenze

text_cl180_x1_loop:move.w	-(a2),d1 		;Zeichennummer
						sub.w 	d2,d1
						cmp.w 	d3,d1 			;Zeichen vorhanden ?
						bls.s 	text_cl180_x1_width
						move.w	t_unknown_index(a6),d1
text_cl180_x1_width:add.w	d1,d1
						move.w	2(a4,d1.w),d4
						sub.w 	0(a4,d1.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						add.w 	d4,d0

						cmp.w 	clip_xmin(a6),d0 ;ausserhalb des Clipping-Rechtecks ?
						bgt.s 	text_cl180_x1_end


						tst.w 	d6
						beq.s 	text_cl180_x1_end
						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl180_x1_next
						ext.l 	d7
						move.w	t_space_kind(a6),d1 ;zeichenweise Dehnung ?
						bmi.s 	text_cl180_x1_char
						cmpi.w	#SPACE,(a2) 	;Leerzeichen ?
						bne.s 	text_cl180_x1_next
						divs		d1,d7
						add.w 	d7,d0
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl180_x1_loop ;Zeichenzaehler dekrementieren
text_cl180_x1_char:divs 	d6,d7
						sub.w 	d7,t_add_length(a6)
						add.w 	d7,d0

text_cl180_x1_next:dbra 	d6,text_cl180_x1_loop

text_cl180_x1_end:sub.w 	d4,d0
						movem.w	(sp)+,d1-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl180_x2
						sub.w 	t_left_off(a6),d0 ;linke Zeichengrenze

text_cl180_x2: 	cmp.w 	clip_xmax(a6),d2
						ble		text_cl0_width

						movem.w	d0-d1/d3-d5,-(sp)

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl180_x2_loop
						add.w 	t_left_off(a6),d2
						sub.w 	t_whole_off(a6),d2 ;rechte Zeichengrenze

text_cl180_x2_loop:move.w	(a5)+,d3 		;Zeichennummer
						sub.w 	d0,d3
						cmp.w 	d1,d3 			;Zeichen vorhanden ?
						bls.s 	text_cl180_x2_width
						move.w	t_unknown_index(a6),d3
text_cl180_x2_width:add.w	d3,d3
						move.w	2(a4,d3.w),d4
						sub.w 	0(a4,d3.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						sub.w 	d4,d2

						cmp.w 	clip_xmax(a6),d2 ;innerhalb des Clipping-Rechtecks ?
						blt.s 	text_cl180_x2_end

						tst.w 	d6
						beq.s 	text_cl180_x2_end
						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl180_x2_next
						ext.l 	d7
						move.w	t_space_kind(a6),d3 ;zeichenweise Dehnung ?
						bmi.s 	text_cl180_x2_char
						cmpi.w	#SPACE,-2(a5)	;Leerzeichen ?
						bne.s 	text_cl180_x2_next
						divs		d3,d7
						sub.w 	d7,d2
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl180_x2_loop ;Zeichenzaehler dekrementieren
text_cl180_x2_char:divs 	d6,d7
						sub.w 	d7,t_add_length(a6)
						sub.w 	d7,d2
text_cl180_x2_next:dbra 	d6,text_cl180_x2_loop ;Zeichenzaehler dekrementieren

text_cl180_x2_end:add.w 	d4,d2 			;Ausgabeposition
						subq.l	#2,a5 			;erstes auszugebendes Zeichen
						movem.w	(sp)+,d0-d1/d3-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_cl0_width
						sub.w 	t_left_off(a6),d2
						add.w 	t_whole_off(a6),d2 ;rechte Zeichengrenze
						bra		text_cl0_width

text270: 			tst.w 	t_add_length(a6) ;Dehnung ?
						beq.s 	text_cl2700_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl2700_x1
						add.w 	t_left_off(a6),d1 ;Verschiebung nach unten

text_cl2700_x1:	add.w 	d3,d0
						sub.w 	d2,d1 			;y1

						move.w	d0,d2 			;x2
						move.w	d1,d3

						sub.w 	d5,d0 			;x1
						add.w 	d4,d3 			;y2

						cmp.w 	clip_xmax(a6),d0 ;zu weit rechts ?
						bgt		text_exit
						cmp.w 	clip_xmin(a6),d2 ;zu weit links ?
						blt		text_exit

						cmp.w 	clip_ymax(a6),d1 ;zu weit unten ?
						ble.s 	text_cl270_top
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d1,d7
						sub.w 	t_left_off(a6),d7
						cmp.w 	clip_ymax(a6),d7
						bgt		text_exit

text_cl270_top:	cmp.w 	clip_ymin(a6),d3 ;zu weit oben ?
						bge.s 	text_cl270_y1

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d3,d7
						sub.w 	t_left_off(a6),d7
						add.w 	t_whole_off(a6),d7
						cmp.w 	clip_ymin(a6),d7
						blt		text_exit

text_cl270_y1: 	cmp.w 	clip_ymin(a6),d1
						bge		text_cl270_y2

						movem.w	d0/d2-d5,-(sp)

						movem.w	t_first_ade(a6),d2-d3 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?

						beq.s 	text_cl270_y1_loop
						sub.w 	t_left_off(a6),d1
						add.w 	t_whole_off(a6),d1 ;rechte Zeichengrenze

text_cl270_y1_loop:move.w	(a5)+,d0 		;Zeichennummer
						sub.w 	d2,d0
						cmp.w 	d3,d0 			;Zeichen vorhanden ?
						bls.s 	text_cl270_y1_width
						move.w	t_unknown_index(a6),d0
text_cl270_y1_width:add.w	d0,d0
						move.w	2(a4,d0.w),d4
						sub.w 	0(a4,d0.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						add.w 	d4,d1


						cmp.w 	clip_ymin(a6),d1 ;innerhalb des Clipping-Rechtecks ?
						bgt.s 	text_cl270_y1_end
						tst.w 	d6
						beq.s 	text_cl270_y1_end

						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl270_y1_next
						ext.l 	d7
						move.w	t_space_kind(a6),d0 ;zeichenweise Dehnung ?
						bmi.s 	text_cl270_y1_char
						cmpi.w	#SPACE,-2(a5)	;Leerzeichen ?
						bne.s 	text_cl270_y1_next
						divs		d0,d7
						add.w 	d7,d1
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl270_y1_loop ;Zeichenzaehler dekrementieren
text_cl270_y1_char:divs 	d6,d7
						sub.w 	d7,t_add_length(a6)
						add.w 	d7,d1
text_cl270_y1_next:dbra 	d6,text_cl270_y1_loop ;Zeichenzaehler dekrementieren

text_cl270_y1_end:sub.w 	d4,d1 			;Ausgabeposition
						subq.l	#2,a5 			;erstes auszugebendes Zeichen
						movem.w	(sp)+,d0/d2-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl270_y2
						add.w 	t_left_off(a6),d1
						sub.w 	t_whole_off(a6),d1 ;rechte Zeichengrenze

text_cl270_y2: 	cmp.w 	clip_ymax(a6),d3
						ble		text_cl270_width

						movem.w	d0-d2/d4-d5,-(sp)

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte
						move.w	d6,d7 			;Zeichenzaehler
						add.w 	d7,d7
						lea		2(a5,d7.w),a2	;Ende von intin

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl270_y2_loop
						sub.w 	t_left_off(a6),d3 ;linke Zeichengrenze

text_cl270_y2_loop:move.w	-(a2),d2 		;Zeichennummer
						sub.w 	d0,d2
						cmp.w 	d1,d2 			;Zeichen vorhanden ?
						bls.s 	text_cl270_y2_width
						move.w	t_unknown_index(a6),d2
text_cl270_y2_width:add.w	d2,d2
						move.w	2(a4,d2.w),d4
						sub.w 	0(a4,d2.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						sub.w 	d4,d3

						cmp.w 	clip_ymax(a6),d3 ;ausserhalb des Clipping-Rechtecks ?
						blt.s 	text_cl270_y2_end
						tst.w 	d6
						beq.s 	text_cl270_y2_end

						move.w	t_add_length(a6),d7 ;Dehnung ?

						beq.s 	text_cl270_y2_next
						ext.l 	d7
						move.w	t_space_kind(a6),d2 ;zeichenweise Dehnung ?
						bmi.s 	text_cl270_y2_char
						cmpi.w	#SPACE,(a2) 	;Leerzeichen ?
						bne.s 	text_cl270_y2_next
						divs		d2,d7
						sub.w 	d7,d3
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl270_y2_loop ;Zeichenzaehler dekrementieren
text_cl270_y2_char:divs 	d6,d7
						sub.w 	d7,t_add_length(a6)
						sub.w 	d7,d3
text_cl270_y2_next:dbra 	d6,text_cl270_y2_loop

text_cl270_y2_end:add.w 	d4,d3
						movem.w	(sp)+,d0-d2/d4-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl270_width
						add.w 	t_left_off(a6),d3 ;linke Zeichengrenze

text_cl270_width: move.w	d3,d4
						sub.w 	d1,d4 			;Bufferbreite in Pixeln -1
						bra		text_buf_width

text_clip_rot0:	tst.w 	t_add_length(a6) ;Dehnung ?
						beq.s 	text_cl00_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl00_x1
						add.w 	t_left_off(a6),d0 ;Verschiebung nach rechts

text_cl00_x1:		sub.w 	d2,d0 			;x1 des Textrechtecks
						sub.w 	d3,d1 			;y1 des Textrechtecks
						move.w	d0,d2
						move.w	d1,d3
						add.w 	d4,d2 			;x2 des Textrechtecks
						add.w 	d5,d3 			;y2 des Textrechtecks

						cmp.w 	clip_ymax(a6),d1 ;zu weit unten ?
						bgt		text_exit
						cmp.w 	clip_ymin(a6),d3 ;zu weit oben ?
						blt		text_exit

						cmp.w 	clip_xmax(a6),d0 ;zu weit rechts ?
						ble.s 	text_clip0_left
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d0,d7
						sub.w 	t_left_off(a6),d7
						cmp.w 	clip_xmax(a6),d7
						bgt		text_exit

text_clip0_left:	cmp.w 	clip_xmin(a6),d2 ;zu weit links ?
						bge.s 	text_cl0_x1
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		text_exit
						move.w	d2,d7
						sub.w 	t_left_off(a6),d7
						add.w 	t_whole_off(a6),d7
						cmp.w 	clip_xmin(a6),d7
						blt		text_exit

text_cl0_x1:		cmp.w 	clip_xmin(a6),d0 ;links clippen ?
						bge		text_cl0_x2

						movem.w	d1-d5,-(sp)

						movem.w	t_first_ade(a6),d2-d3 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl0_x1_loop
						sub.w 	t_left_off(a6),d0
						add.w 	t_whole_off(a6),d0 ;rechte Zeichengrenze

text_cl0_x1_loop: move.w	(a5)+,d1 		;Zeichennummer
						sub.w 	d2,d1
						cmp.w 	d3,d1 			;Zeichen vorhanden ?
						bls.s 	text_cl0_x1_width
						move.w	t_unknown_index(a6),d1
text_cl0_x1_width:add.w 	d1,d1
						move.w	2(a4,d1.w),d4
						sub.w 	0(a4,d1.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						add.w 	d4,d0

						cmp.w 	clip_xmin(a6),d0 ;innerhalb des Clipping-Rechtecks ?
						bgt.s 	text_cl0_x1_end

						tst.w 	d6 				;letztes Zeichen ?
						beq.s 	text_cl0_x1_end

						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl0_x1_next
						ext.l 	d7
						move.w	t_space_kind(a6),d1 ;zeichenweise Dehnung ?
						bmi.s 	text_cl0_x1_char
						cmpi.w	#SPACE,-2(a5)	;Leerzeichen ?
						bne.s 	text_cl0_x1_next
						divs		d1,d7
						add.w 	d7,d0
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl0_x1_loop ;Zeichenzaehler dekrementieren
text_cl0_x1_char: divs		d6,d7
						sub.w 	d7,t_add_length(a6)
						add.w 	d7,d0
text_cl0_x1_next: dbra		d6,text_cl0_x1_loop ;Zeichenzaehler dekrementieren

text_cl0_x1_end:	sub.w 	d4,d0 			;Ausgabeposition
						subq.l	#2,a5 			;erstes auszugebendes Zeichen
						movem.w	(sp)+,d1-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl0_x2
						add.w 	t_left_off(a6),d0
						sub.w 	t_whole_off(a6),d0

text_cl0_x2:		cmp.w 	clip_xmax(a6),d2 ;rechts clippen ?
						ble		text_cl0_width

						movem.w	d0-d1/d3-d5,-(sp) ;Register sichern
						move.w	d6,d7
						add.w 	d7,d7
						lea		2(a5,d7.w),a2

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						move.w	t_eff_thicken(a6),d5 ;Verbreiterung durch Effekte

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl0_x2_loop
						sub.w 	t_left_off(a6),d2 ;linke Zeichengrenze

text_cl0_x2_loop: move.w	-(a2),d3 		;Zeichennummer
						sub.w 	d0,d3
						cmp.w 	d1,d3 			;Zeichen vorhanden ?
						bls.s 	text_cl0_x2_width
						move.w	t_unknown_index(a6),d3
text_cl0_x2_width:add.w 	d3,d3
						move.w	2(a4,d3.w),d4
						sub.w 	0(a4,d3.w),d4
						mulu		t_cheight(a6),d4 ;* Zeichenhoehe
						divu		t_iheight(a6),d4 ;/ vorhandene Hoehe
						add.w 	d5,d4 			;+ Verbreiterung durch Effekte
						sub.w 	d4,d2

						cmp.w 	clip_xmax(a6),d2 ;innerhalb des Clipping-Rechtecks ?
						blt.s 	text_cl0_x2_end

						tst.w 	d6 				;letztes Zeichen ?
						beq.s 	text_cl0_x2_end
						move.w	t_add_length(a6),d7 ;Dehnung ?
						beq.s 	text_cl0_x2_next
						ext.l 	d7
						move.w	t_space_kind(a6),d3 ;zeichenweise Dehnung ?
						bmi.s 	text_cl0_x2_char
						cmpi.w	#SPACE,(a2) 	;Leerzeichen ?
						bne.s 	text_cl0_x2_next
						divs		d3,d7
						sub.w 	d7,d2
						sub.w 	d7,t_add_length(a6)
						subq.w	#1,t_space_kind(a6) ;ein Wort weniger
						dbra		d6,text_cl0_x2_loop ;Zeichenzaehler dekrementieren
text_cl0_x2_char: divs		d6,d7
						sub.w 	d7,t_add_length(a6)
						sub.w 	d7,d2
text_cl0_x2_next: dbra		d6,text_cl0_x2_loop ;Zeichenzaehler dekrementieren

text_cl0_x2_end:	add.w 	d4,d2
						movem.w	(sp)+,d0-d1/d3-d5

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq.s 	text_cl0_width
						add.w 	t_left_off(a6),d2 ;linke Zeichengrenze

text_cl0_width:	move.w	d2,d4
						sub.w 	d0,d4 			;Bufferbreite in Pixeln -1

text_buf_width:	addi.w	#16,d4
						lsr.w 	#4,d4
						add.w 	d4,d4
						movea.w	d4,a3 			;Bufferbreite in Bytes
						move.w	d5,d7
						addq.w	#1,d7 			;Bufferhoehe in Zeilen

						tst.w 	t_rotation(a6) ;Textdrehung ?
						beq.s 	text_buf_size
						addi.w	#15,d7
						andi.w	#$fff0,d7


text_buf_size: 	mulu		d4,d7 			;benoetigte Buffergroesse

						move.l	buffer_len(a6),d4 ;Buffergroesse

						btst		#T_OUTLINED_BIT,t_effects+1(a6) ;umrandet ?
						bne.s 	text_buf_shrink
						tst.w 	t_rotation(a6) ;Textdrehung ?
						beq.s 	text_buf_cmp
text_buf_shrink:	lsr.l 	#1,d4 			;halbiert wegen bestimmter Effekte
text_buf_cmp:		cmp.l 	d4,d7 			;passt alles in den Buffer ?
						bgt		text_partitial

						movem.w	d0-d1,-(sp) 	;x/y auf den Stack

						move.w	t_cheight(a6),d5 ;Textbufferhoehe
						subq.w	#1,d5

						bsr		fill_text_buf	;Textbuffer fuellen

						movea.l	buffer_addr(a6),a0 ;Adresse des Textbuffers
						movea.w	a3,a2 			;Breite des Textbuffers in Bytes

						move.w	t_effects(a6),d7
						beq.s 	text_output
text_bold:			btst		#T_BOLD_BIT,d7 ;fett ?
						beq.s 	text_underlined
						bsr		bold
text_underlined:	btst		#T_UNDERLINED_BIT,t_effects+1(a6) ;unterstrichen ?
						beq.s 	text_outlined
						bsr		underline
text_outlined: 	btst		#T_OUTLINED_BIT,1+t_effects(a6) ;umrandet ?
						beq.s 	text_lightend

						bsr		outline
text_lightend: 	btst		#T_LIGHT_BIT,1+t_effects(a6) ;hell ?
						beq.s 	text_output
						bsr		light

text_output:		movem.w	(sp)+,d2-d3 	;x/y

						move.w	t_rotation(a6),d7 ;Textdrehung ?
						bne.s 	text_rot90
text_rot0:			btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		textblt_xs0
text_ital0: 		sub.w 	t_left_off(a6),d2
						add.w 	t_whole_off(a6),d2
text_ital180:		move.w	#$5555,d6		;t_skew_mask(a6)
						moveq 	#0,d1
						move.w	d5,d7
text_ital_loop0:	movem.w	d1-d4/d6-d7/a2-a3,-(sp)
						move.l	a0,-(sp)
						moveq 	#0,d0 			;erste Quellspalte
						moveq 	#0,d5 			;eine Zeile
						bsr		textblt
						movea.l	(sp)+,a0
						movem.w	(sp)+,d1-d4/d6-d7/a2-a3
						ror.w 	#1,d6
						bcc.s 	text_ital_next0
						subq.w	#1,d2
text_ital_next0:	addq.w	#1,d1 			;naechste Quellzeile
						addq.w	#1,d3 			;naechste Zielzeile
						dbra		d7,text_ital_loop0
						rts

text_rot90: 		subq.w	#T_ROT_90,d7	;Textdrehung um 90 degree ?
						bne.s 	text_rot180
						bsr		rotate90 		;Zeichen um 90 degree drehen
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		textblt_xs0
text_ital90:		add.w 	t_left_off(a6),d3
						sub.w 	t_whole_off(a6),d3
text_ital270:		move.w	#$5555,d6		;t_skew_mask(a6)
						move.w	d4,d7
text_ital_loop90: movem.w	d0/d2-d3/d5-d7/a2-a3,-(sp)
						move.l	a0,-(sp)
						moveq 	#0,d1 			;erste Quellzeile
						moveq 	#0,d4 			;eine Spalte
						bsr		textblt
						movea.l	(sp)+,a0
						movem.w	(sp)+,d0/d2-d3/d5-d7/a2-a3
						ror.w 	#1,d6
						bcc.s 	text_ital_next90
						addq.w	#1,d3
text_ital_next90: addq.w	#1,d0 			;naechste Quellspalte
						addq.w	#1,d2 			;naechste Zielspalte
						dbra		d7,text_ital_loop90
						rts

text_rot180:		subq.w	#T_ROT_180-T_ROT_90,d7 ;Textdrehung um 180 degree ?

						bne.s 	text_rot270
						bsr		rotate180		;Zeichen um 180 degree drehen
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		textblt_xs0
						add.w 	t_left_off(a6),d2
						bra		text_ital180

text_rot270:		bsr		rotate270		;Zeichen um 270 degree drehen
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						beq		textblt_xs0
						sub.w 	t_left_off(a6),d3
						bra.s 	text_ital270

;Unterstreichung erzeugen
;Eingaben
;d4.w Breite -1
;d5.w Hoehe -1
;a0.l Bufferadresse
;a2.w Bufferbreite in Bytes
;a6.l Workstation
;Ausgaben
;d0-d3/d6/a1/a3 werden zerstoert
;d4.w Breite -1
;d5.w Hoehe -1
;a0.l Bufferadresse
;a2.w Bufferbreite in Bytes
;a6.l Workstation
underline:			move.w	t_act_line(a6),d0 ;Startzeile des Ausschnitts
						move.w	d0,d1
						add.w 	d5,d1 			;Endzeile des Ausschnitts
						move.w	t_uline(a6),d2 ;Dicke der Unterstreichung
						move.w	t_base(a6),d3
						addq.w	#2,d3 			;Startzeile der Unterstreichung
						move.w	t_cheight(a6),d7
						subq.w	#1,d7
						cmp.w 	d7,d3
						ble.s 	underline_width
						move.w	d7,d3
underline_width:	add.w 	d3,d2 			;Endzeile der Unterstreichung
						cmp.w 	d7,d2
						ble.s 	underline_top
						move.w	d7,d2
underline_top: 	cmp.w 	d1,d3 			;zu weit oben ?
						bgt.s 	underline_exit
						cmp.w 	d0,d2 			;zu weit unten ?
						blt.s 	underline_exit
						cmp.w 	d1,d2
						ble.s 	underline_clip
						move.w	d1,d2
underline_clip:	cmp.w 	d0,d3
						bge.s 	underline_count
						move.w	d0,d3
underline_count:	sub.w 	d3,d2
						bmi.s 	underline_exit
						sub.w 	d0,d3
						move.w	a2,d0 			;Bytes pro Zeile
						mulu		d3,d0
						movea.l	a0,a1
						adda.w	d0,a1 			;Startadresse der Unterstreichung
						move.w	d4,d0 			;Breite -1
						lsr.w 	#4,d0 			;Wortzaehler
						moveq 	#$ffffffff,d1	;Fuellwert
						moveq 	#15,d3
						and.w 	d4,d3 			;Bitposition
						add.w 	d3,d3

						move.w	underline_mask(pc,d3.w),d3 ;Maske fuers letzte Wort
						movea.w	a2,a3
						suba.w	d0,a3
						suba.w	d0,a3
						subq.w	#2,a3 			;Offset zur naechsten Bufferzeile
underline_loop1:	move.w	d0,d6 			;Wortzaehler
underline_loop2:	move.w	d1,(a1)+
						dbra		d6,underline_loop2
						and.w 	d3,-2(a1)		;ausmaskieren

						adda.w	a3,a1 			;naechste Zeile
						dbra		d2,underline_loop1
underline_exit:	rts

underline_mask:	DC.W %1000000000000000
						DC.W %1100000000000000
						DC.W %1110000000000000
						DC.W %1111000000000000
						DC.W %1111100000000000
						DC.W %1111110000000000
						DC.W %1111111000000000
						DC.W %1111111100000000
						DC.W %1111111110000000
						DC.W %1111111111000000
						DC.W %1111111111100000
						DC.W %1111111111110000
						DC.W %1111111111111000
						DC.W %1111111111111100
						DC.W %1111111111111110
						DC.W %1111111111111111

;Fette Schrift erzeugen
;Eingaben
;d4.w Breite -1
;d5.w Hoehe -1
;a0.l Bufferadresse

;a2.w Bytes pro Bufferzeile
;a6.l Workstation
;Ausgaben
;d0-d3/d6-d7/a4 werden zerstoert
;d4.w Breite -1
;d5.w Hoehe -1
;a0.l Bufferadresse
;a2.w Bytes pro Bufferzeile
;a6.l Workstation
bold: 				move.w	d5,-(sp)

						movea.l	a0,a4 			;Bufferadresse
						move.w	a2,d6 			;Bufferbreite in Bytes
						lsr.w 	#1,d6
						subq.w	#1,d6 			;Wortzaehler
						move.w	t_thicken(a6),d2 ;Verbreiterung
						beq.s 	bold_loop		;aequidistanter Font?
						add.w 	d2,d4 			;neue Breite
						subq.w	#1,d2

bold_loop:			move.w	d6,d7 			;Zaehler innerhalb der Zeile
						move.w	(a4)+,d0 		;die ersten Daten holen
bold_fetch: 		swap		d0
						clr.w 	d0
						move.l	d0,d1
						move.w	d2,d3 			;Verbreiterungszaehler
bold_thicken:		ror.l 	#1,d0
						or.l		d0,d1
						dbra		d3,bold_thicken
						move.w	(a4)+,d0 		;naechsten Daten
						or.l		d1,-4(a4)
						dbra		d7,bold_fetch
						move.w	d0,-(a4) 		;Startwort der naechsten Zeile
						dbra		d5,bold_loop
						move.w	(sp)+,d5
						rts

;Umrandung erzeugen
;Eingaben
;
;Ausgaben
;
outline:
						movea.l	a0,a1
						move.l	buffer_len(a6),d0
						lsr.l 	#1,d0
						adda.l	d0,a1

						move.l	a0,-(sp)
						move.l	a1,-(sp)
						move.w	a2,d2
						lsr.w 	#1,d2
						subq.w	#1,d2 			;Zaehler
						moveq 	#16,d0
						addq.w	#2,d4

						add.w 	d4,d0
						lsr.w 	#4,d0
						add.w 	d0,d0
						movea.w	d0,a2 			;neue Zeilenbreite
						movea.w	d0,a3
						adda.w	d0,a3 			;doppelte Zeilenbreite
						move.w	d5,d1
						addq.w	#3,d1
						mulu		d1,d0
						lsr.w 	#2,d0 			;Langwortzaehler
						moveq 	#0,d1 			;Fuellwert
						movea.l	a1,a4 			;Zielbufferadresse

outlined_clear:	move.l	d1,(a4)+
						dbra		d0,outlined_clear

						move.w	d5,d6 			;Zeilenzaehler
outlined_loop1:	move.w	d2,d3
						movea.l	a1,a4

outlined_loop2:	moveq 	#0,d0
						move.w	(a0)+,d0 		;Quellwort
						swap		d0
						move.l	d0,d1
						ror.l 	#1,d1
						or.l		d1,d0
						ror.l 	#1,d1
						or.l		d1,d0
						or.l		d0,(a4)
						or.l		d0,0(a4,a2.w)
						or.l		d0,0(a4,a3.w)


						addq.l	#2,a4
						dbra		d3,outlined_loop2
						adda.w	a2,a1 			;naechste Zielzeile
						dbra		d6,outlined_loop1
						movea.l	(sp),a1
						movea.l	4(sp),a0

						move.w	d5,d6 			;Zeilenzaehler
						adda.w	a2,a1
outlined_loop3:	move.w	d2,d3
						movea.l	a1,a4

outlined_loop4:	moveq 	#0,d0
						move.w	(a0)+,d0
						swap		d0
						ror.l 	#1,d0
						eor.l 	d0,(a4)
						addq.l	#2,a4
						dbra		d3,outlined_loop4
						adda.w	a2,a1
						dbra		d6,outlined_loop3

						movea.l	(sp)+,a0
						movea.l	(sp)+,a1
						addq.w	#2,d5
						rts

;Helle Schrift erzeugen
;Eingaben
;d5.w Hoehe -1
;a0.l Bufferadresse
;a2.w Bytes pro Bufferzeile
;a6.l Workstationpointer
;Ausgaben
;d0-d2/d6-d7/a3 werden zerstoert
light:				move.w	#$5555,d0 		;t_light_mask Maske fuer helle Schrift
						moveq 	#15,d6
						and.w 	t_act_line(a6),d6 ;relative Ausgabezeile
						ror.w 	d6,d0 			;Maske entsprechend shiften
						movea.l	a0,a3 			;Bufferadresse
						move.w	a2,d1 			;Bytes pro Zeile
						lsr.w 	#1,d1 			;Zaehler
						subq.w	#1,d1
						move.w	d5,d7 			;Zeilenzaehler

						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv ?
						bne.s 	light_italics
light_loop1:		move.w	d1,d6
light_loop2:		and.w 	d0,(a3)+
						dbra		d6,light_loop2
						ror.w 	#1,d0
						dbra		d7,light_loop1
						rts
light_italics: 	move.w	#$5555,d2 		;t_skew_mask(a6)Schiebe-Maske fuer Kursivschrift
						ror.w 	d6,d2 			;Maske ensprechend relativer Zeile
light_i_loop1: 	move.w	d1,d6 			;Wortzaehler
light_i_loop2: 	and.w 	d0,(a3)+
						dbra		d6,light_i_loop2
						ror.w 	#1,d0 			;Hell-Maske rotieren
						ror.w 	#1,d2 			;Kursiv-Maske rotieren
						bcc.s 	light_i_next	;Kursivschrift ?
						ror.w 	#1,d0
light_i_next:		dbra		d7,light_i_loop1
						rts

;Zeichen um 90 degree drehen

rotate90:
						movea.l	a0,a1
						move.l	buffer_len(a6),d0
						lsr.l 	#1,d0
						adda.l	d0,a1
						cmpa.l	buffer_addr(a6),a0
						beq.s 	rotate90_save
						movea.l	buffer_addr(a6),a1

rotate90_save: 	move.l	a0,-(sp)
						move.l	a1,-(sp)
						movem.w	d2-d3/d5,-(sp)

						moveq 	#16,d6			;Vorbesetzung

						move.w	d5,d0 			;Hoehe
						add.w 	d6,d0
						andi.w	#$fff0,d0
						move.w	d0,d7
						add.w 	d7,d7 			;Bytes pro 16 Zeilen
						lsr.w 	#3,d0
						movea.w	d0,a3 			;Bytes pro Zeile

						movea.l	a1,a4 			;Zeiger auf erste Bufferzeile
						mulu		d4,d0
						adda.w	d0,a1 			;Zeiger auf letzte Bufferzeile
						add.w 	a3,d0
						lsr.w 	#4,d0 			;Zaehler
						moveq 	#0,d1 			;Fuellwert
rotate90_clear:	move.l	d1,(a4)+ 		;Buffer loeschen
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						dbra		d0,rotate90_clear

						move.w	#$8000,d2		;Punktmuster

rotate90_bloop:	move.w	d4,d3 			;Pixelzaehler
						movea.l	a0,a4
						movea.l	a1,a5
						adda.w	a2,a0
						bra.s 	rotate90_read
rotate90_loop: 	dbra		d1,rotate90_test
rotate90_read: 	moveq 	#15,d1			;Bitzaehler
						move.w	(a4)+,d0 		;Quellwort einlesen
						bne.s 	rotate90_test	;weiss ?
						sub.w 	d6,d3 			;16 Pixel weniger
						bmi.s 	rotate90_shift
						move.w	(a4)+,d0 		;neues Quellwort
						suba.w	d7,a5 			;16 Zeilen weiter
rotate90_test: 	add.w 	d0,d0 			;Bit gesetzt ?
						bcc.s 	rotate90_white
						or.w		d2,(a5)			;Bit setzen
rotate90_white:	suba.w	a3,a5 			;naechste Zielzeile
						dbra		d3,rotate90_loop
rotate90_shift:	ror.w 	#1,d2 			;naechste Punktmaske
						bcc.s 	rotate90_next
						addq.l	#2,a1 			;naechstes Zielwort
rotate90_next: 	dbra		d5,rotate90_bloop
						movem.w	(sp)+,d2-d3/d5
						movea.l	(sp)+,a0 		;neue Quelladresse
						movea.l	(sp)+,a1 		;neue Zieladresse
						exg		d4,d5 			;Breite und Hoehe vertauschen
						movea.w	a3,a2 			;neue Zeilenbreite
						rts

;Zeichen um 180 degree drehen
rotate180:
						movea.l	a0,a1
						move.l	buffer_len(a6),d0
						lsr.l 	#1,d0
						adda.l	d0,a1
						cmpa.l	buffer_addr(a6),a0
						beq.s 	rotate180_save
						movea.l	buffer_addr(a6),a1

rotate180_save:
						move.l	a0,-(sp)
						move.l	a1,-(sp)
						movem.w	d2-d3/d5,-(sp)

						moveq 	#16,d6			;Vorbesetzung
						movea.l	a1,a4 			;Zeiger auf erste Bufferzeile
						move.w	a2,d0
						mulu		d5,d0
						add.w 	a2,d0
						adda.w	d0,a1 			;Zeiger hinter letzte Bufferzeile
						lsr.w 	#4,d0 			;Zaehler
						moveq 	#0,d1 			;Fuellwert
rotate180_clear:	move.l	d1,(a4)+ 		;Buffer loeschen
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						dbra		d0,rotate180_clear


						moveq 	#15,d0
						and.w 	d4,d0
						move.w	#$8000,d2
						lsr.w 	d0,d2 			;Punktmaske
						movea.w	d2,a4

rotate180_bloop:	move.w	a4,d2 			;Punktmaske
						move.w	d4,d3 			;Zaehler
						moveq 	#0,d7
						bra.s 	rotate180_read
rotate180_loop:	dbra		d1,rotate180_test
rotate180_read:	moveq 	#15,d1			;Bitzaehler
						move.w	(a0)+,d0 		;Quellwort
						bne.s 	rotate180_test ;weiss ?
						move.w	d7,-(a1) 		;naechstes Zielwort
						sub.w 	d6,d3 			;16 Pixel weiter
						bmi.s 	rotate180_next
						move.w	(a0)+,d0 		;naechstes Quellwort
						moveq 	#0,d7
rotate180_test:	add.w 	d0,d0 			;Bit gesetzt ?
						bcc.s 	rotate180_white
						or.w		d2,d7 			;Bit setzen
rotate180_white:	add.w 	d2,d2 			;Punktmaske verschieben
						bcc.s 	rotate180_dbra
						moveq 	#1,d2 			;Punktmaske
						move.w	d7,-(a1) 		;naechstes Zielwort
						moveq 	#0,d7

rotate180_dbra:	dbra		d3,rotate180_loop
rotate180_next:	dbra		d5,rotate180_bloop

						movem.w	(sp)+,d2-d3/d5
						movea.l	(sp)+,a0 		;neue Quelladresse
						movea.l	(sp)+,a1 		;neue Zieladresse
						rts

;Zeichen um 270 degree drehen
rotate270:

						movea.l	a0,a1
						move.l	buffer_len(a6),d0
						lsr.l 	#1,d0
						adda.l	d0,a1

						cmpa.l	buffer_addr(a6),a0
						beq.s 	rotate270_save
						movea.l	buffer_addr(a6),a1

rotate270_save:	move.l	a0,-(sp)
						move.l	a1,-(sp)

						movem.w	d2-d3/d5,-(sp)

						moveq 	#16,d6

						move.w	d5,d0 			;Hoehe
						add.w 	d6,d0
						andi.w	#$fff0,d0
						move.w	d0,d7
						add.w 	d7,d7 			;Bytes pro 16 Zeilen
						lsr.w 	#3,d0
						movea.w	d0,a3 			;Bytes pro Bufferzeile

						movea.l	a1,a4 			;Zeiger auf erste Bufferzeile

						mulu		d4,d0
						add.w 	a3,d0
						lsr.w 	#4,d0 			;Zaehler
						moveq 	#0,d1 			;Fuellwert
rotate270_clear:	move.l	d1,(a4)+ 		;Buffer loeschen
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						move.l	d1,(a4)+
						dbra		d0,rotate270_clear

						move.w	#$8000,d2		;Punktmuster
						move.w	a2,d0
						mulu		d5,d0
						adda.w	d0,a0 			;Zeiger auf letzte Quellzeile

rotate270_bloop:	move.w	d4,d3 			;Zaehler
						movea.l	a0,a4
						movea.l	a1,a5

						bra.s 	rotate270_read
rotate270_loop:	dbra		d1,rotate270_test
rotate270_read:	moveq 	#15,d1			;Bitzaehler
						move.w	(a4)+,d0 		;Quellwort einlesen
						bne.s 	rotate270_test
						sub.w 	d6,d3 			;16 Pixel weiter
						bmi.s 	rotate270_shift
						move.w	(a4)+,d0 		;neues Quellwort
						adda.w	d7,a5 			;16 Zeilen weiter
rotate270_test:	add.w 	d0,d0 			;Bit gesetzt ?
						bcc.s 	rotate270_white
						or.w		d2,(a5)			;Bit setzen
rotate270_white:	adda.w	a3,a5 			;naechste Zielzeile
						dbra		d3,rotate270_loop
rotate270_shift:	suba.w	a2,a0 			;naechste Quellzeile
						ror.w 	#1,d2 			;naechste Punktmaske
						bcc.s 	rotate270_next
						addq.l	#2,a1 			;naechstes Zielwort

rotate270_next:	dbra		d5,rotate270_bloop

						movem.w	(sp)+,d2-d3/d5
						movea.l	(sp)+,a0 		;neue Quelladresse
						movea.l	(sp)+,a1 		;neue Zieladresse
						exg		d4,d5 			;Breite und Hoehe vertauschen
						movea.w	a3,a2 			;neue Zeilenbreite
						rts

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
textblt_xs0:		moveq 	#0,d0
textblt_ys0:		moveq 	#0,d1 			;y-Quellkoordinate = 0
textblt: 			move.w	d5,d7
						add.w 	d2,d4 			;xd2
						add.w 	d3,d5 			;yd2

						lea		clip_xmin(a6),a1
						cmp.w 	(a1)+,d2 		;xd1 zu klein ?
						bge.s 	textblt_clipy1
						sub.w 	d2,d0
						move.w	-2(a1),d2		;xd1 = clip_xmin
						add.w 	d2,d0 			;xs1 = xs1 - xd1 + clip_xmin
textblt_clipy1:	cmp.w 	(a1)+,d3 		;yd1 zu klein ?
						bge.s 	textblt_clipx2
						sub.w 	d3,d1
						move.w	-2(a1),d3		;yd1 = clip_ymin
						add.w 	d3,d1 			;ys1 = ys1 - yd1 + clip_ymin
textblt_clipx2:	cmp.w 	(a1)+,d4 		;xd2 zu gross ?
						ble.s 	textblt_clipy2
						move.w	-2(a1),d4		;xd2 = clip_xmax
textblt_clipy2:	cmp.w 	(a1),d5			;yd2 zu gross ?
						ble.s 	textblt_cmp
						move.w	(a1),d5			;yd2 = clip_ymax
textblt_cmp:		sub.w 	d2,d4
						bmi.s 	textblt_exit
						sub.w 	d3,d5
						bmi.s 	textblt_exit

						movea.l	p_textblt(a6),a4
						jmp		(a4)

textblt_exit:		rts

;Textbuffer fuellen
;Eingaben
;d5.w Zeichenhoehe - 1
;a3.w Bufferbreite in Bytes
;a5.l intin
;Ausgaben
;d0-d3/d6/d7/a0-a2/a4-a5 werden zerstoert
;d4.w Bufferbreite -1
;d5.w Bufferhoehe -1
;a3.w Bytes pro Bufferzeile
fill_text_buf: 	movea.w	t_iwidth(a6),a2 ;Breite des Fontimage
						movea.l	t_offtab(a6),a4 ;Zeichenabstandstabelle

ftb_eff: 			move.w	a3,d0 			;Bufferbreite in Bytes
						mulu		d5,d0 			;* Bufferhoehe
						add.w 	a3,d0 			;Platzbedarf des Buffers in Bytes
						lsr.w 	#4,d0 			;16-Byte-Zaehler
						moveq 	#0,d1 			;Fuellwert
						movea.l	buffer_addr(a6),a1
ftb_clear:			REPT 4
						move.l	d1,(a1)+

						ENDM
						dbra		d0,ftb_clear

						movea.l	buffer_addr(a6),a1 ;Bufferadresse

						moveq 	#0,d2 			;Startposition
						moveq 	#15,d7			;Wert fuers ausmaskieren
						move.w	t_eff_thicken(a6),d3 ;Verbreiterung durch Effekte
						addq.w	#1,d3 			;+ Abstand zum naechsten Zeichen

						tst.b 	t_grow(a6)		;Vergroesserung ?
						bne		ftb_grow_loop

ftb_loop:			move.w	(a5)+,d0 		;Zeichennummer
						sub.w 	t_first_ade(a6),d0
						cmp.w 	t_ades(a6),d0	;Zeichen vorhanden ?
						bls.s 	ftb_position
						move.w	t_unknown_index(a6),d0
ftb_position:		add.w 	d0,d0
						movem.w	0(a4,d0.w),d0/d4
						sub.w 	d0,d4
						subq.w	#1,d4 			;Zeichenbreite in Pixeln - 1
						bmi.s 	ftb_next
						movea.l	t_image(a6),a0
						move.w	d0,d1 			;Quellkoordinate
						lsr.w 	#4,d1
						add.w 	d1,d1
						adda.w	d1,a0 			;Quelladresse
						and.w 	d7,d0 			;Shifts der Quelle

						movem.w	d3/d5-d6/a2-a3,-(sp)
						add.w 	d2,d3
						add.w 	d4,d3
						move.w	d3,-(sp)
						move.l	a1,-(sp)
						bsr.s 	copy_to_buf 	;Zeichen in den Buffer kopieren
						movea.l	(sp)+,a1
						movem.w	(sp)+,d2-d3/d5-d6/a2-a3

						tst.w 	t_add_length(a6) ;Textstreckung ?
						beq.s 	ftb_no_offset

						bsr.s 	text_offset 	;evtl. Offset in d4 zurueckgeben

ftb_no_offset: 	cmp.w 	d7,d2 			;mehr als 15 Shifts ?
						ble.s 	ftb_next
						move.w	d2,d4
						lsr.w 	#4,d4
						add.w 	d4,d4
						adda.w	d4,a1 			;Zieladresse erhoehen
						and.w 	d7,d2 			;neue Shiftanzahl

ftb_next:			dbra		d6,ftb_loop 	;naechstes Zeichen kopieren
						move.l	a1,d4
						sub.l 	buffer_addr(a6),d4
						lsl.w 	#3,d4
						add.w 	d2,d4
						sub.w 	d3,d4 			;Breite in Pixeln
						rts

;Offset fuers naechste Zeichen berechnen
;Eingaben
;d6.w Anzahl der verbleibenden Zeichen
;a1.l Zieladresse
;a5.l Zeiger auf das naechste Zeichen
;a6.l Zeiger auf die Workstation
;Ausgaben
;d0/d4 werden zerstoert
;d2.w Zielschifts
;a1.l Zieladresse
text_offset:		move.w	d6,d0 			;verbleibende Zeichenanzahl
						beq.s 	text_offset_exit
						move.w	t_space_kind(a6),d4 ;Wortweise Dehnung ?
						bmi.s 	text_offset_calc
						cmpi.w	#32,-2(a5)		;Leerzeichen ?
						bne.s 	text_offset_exit
						subq.w	#1,t_space_kind(a6) ;Wortanzahl dekrementieren
						move.w	d4,d0 			;noch vorhandene Wortanzahl
text_offset_calc: move.w	t_add_length(a6),d4
						ext.l 	d4
						divs		d0,d4
						sub.w 	d4,t_add_length(a6)
						add.w 	d4,d2 			;neue Position
						bpl.s 	text_offset_exit
						move.w	d2,d4
						neg.w 	d4
						lsr.w 	#4,d4
						addq.w	#1,d4
						add.w 	d4,d4
						suba.w	d4,a1
						and.w 	d7,d2 			;ausmaskieren
						cmpa.l	buffer_addr(a6),a1
						bpl.s 	text_offset_exit
						movea.l	buffer_addr(a6),a1
						moveq 	#0,d2
text_offset_exit: rts

;Bereich kopieren
;Eingaben
;d0.w Shiftanzahl der Quelldaten
;d2.w Shiftanzahl der Zieldaten
;d4.w Breite - 1
;d5.w Hoehe - 1
;d7.w 15 (zum ausmaskieren)
;a0.l Quelladresse
;a1.l Zieladresse
;a2.w Bytes pro Quellzeile
;a3.w Bytes pro Zielzeile
;Ausgaben
;d3-d6/a0-a3 werden zerstoert (?)
copy_to_buf:		cmp.w 	#7,d4 			;Bytebreite ?
						bne.s 	cptb_no_byte
						tst.w 	d0
						beq		cptb_byte
						cmp.w 	#8,d0
						beq		cptb_byte8

cptb_no_byte:		sub.w 	d2,d0 			;Shifts


;Zaehler
;d1
;d3
						move.w	d2,d1
						add.w 	d4,d1
						lsr.w 	#4,d1 			;/16


						add.w 	d2,d4
						not.w 	d4
						and.w 	d7,d4
						moveq 	#$ffffffff,d3
						lsr.w 	d2,d3 			;Startmaske
						moveq 	#$ffffffff,d2
						lsl.w 	d4,d2 			;Endmaske

						subq.w	#1,d1
						bmi		cptb_1word
						beq		cptb_1long

						move.w	d1,d4
						addq.w	#1,d4
						add.w 	d4,d4
						suba.w	d4,a2
						suba.w	d4,a3

						subq.w	#1,d1

						tst.w 	d0
						beq.s 	cptb_multiple
						blt.s 	cptbm_r
						cmpi.w	#8,d0
						ble.s 	cptb_multiple_l
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_multiple_r
cptbm_r: 			neg.w 	d0
						subq.l	#2,a0
						cmpi.w	#8,d0
						ble.s 	cptb_multiple_r
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_multiple_l

cptb_multiple: 	move.w	d1,d4
						move.w	(a0)+,d6 		;Buffer

						and.w 	d3,d6
						or.w		d6,(a1)+
cptbm_loop: 		move.w	(a0)+,(a1)+
						dbra		d4,cptbm_loop
						move.w	(a0),d6			;Buffer

						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_multiple
						rts

cptb_multiple_r:	move.w	d1,d4
						move.l	(a0),d6			;Buffer
						addq.l	#2,a0
						ror.l 	d0,d6
						and.w 	d3,d6
						or.w		d6,(a1)+
cptbm_loop_r:		move.l	(a0),d6			;Buffer
						addq.l	#2,a0
						ror.l 	d0,d6
						move.w	d6,(a1)+
						dbra		d4,cptbm_loop_r
						move.l	(a0),d6			;Buffer
						ror.l 	d0,d6
						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_multiple_r
						rts

cptb_multiple_l:	move.w	d1,d4
						move.l	(a0),d6			;Buffer
						addq.l	#2,a0
						swap		d6
						rol.l 	d0,d6
						and.w 	d3,d6
						or.w		d6,(a1)+
cptbm_loop_l:		move.l	(a0),d6			;Buffer
						addq.l	#2,a0
						swap		d6
						rol.l 	d0,d6
						move.w	d6,(a1)+
						dbra		d4,cptbm_loop_l
						move.l	(a0),d6			;Buffer
						swap		d6
						rol.l 	d0,d6
						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_multiple_l
						rts


cptb_1word: 		and.w 	d3,d2
						move.w	d2,d3
						not.w 	d3

						tst.w 	d0
						beq.s 	cptb_word
						blt.s 	cptb_wr

						cmpi.w	#8,d0

						ble.s 	cptb_word_l
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_word_r

cptb_wr: 			neg.w 	d0
						subq.l	#2,a0
						cmpi.w	#8,d0
						ble.s 	cptb_word_r
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_word_l


cptb_word:			move.w	(a0),d6
						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_word
						rts
cptb_word_r:		move.l	(a0),d6
						ror.l 	d0,d6
						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_word_r
						rts
cptb_word_l:		move.l	(a0),d6
						swap		d6
						rol.l 	d0,d6
						and.w 	d2,d6
						or.w		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_word_l
						rts

cptb_1long: 		swap		d3
						move.w	d2,d3
						move.l	d3,d2
						not.l 	d3

						tst.w 	d0
						beq.s 	cptb_long
						blt.s 	cptb_lr

						cmpi.w	#8,d0
						ble.s 	cptb_long_l
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_long_r

cptb_lr: 			neg.w 	d0

						subq.l	#2,a0

						cmpi.w	#8,d0
						ble.s 	cptb_long_r
						subq.w	#1,d0
						eor.w 	d7,d0
						bra.s 	cptb_long_l

cptb_long:			move.l	(a0),d6
						and.l 	d2,d6
						or.l		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_long
						rts
cptb_long_r:		move.l	(a0),d6
						ror.l 	d0,d6
						swap		d6
						move.l	2(a0),d4

						ror.l 	d0,d4
						move.w	d4,d6
						and.l 	d2,d6
						or.l		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_long_r
						rts
cptb_long_l:		move.l	(a0),d6
						rol.l 	d0,d6
						move.l	2(a0),d4
						swap		d4
						rol.l 	d0,d4
						move.w	d4,d6
						and.l 	d2,d6
						or.l		d6,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_long_l
						rts

cptb_byte8: 		addq.l	#1,a0
cptb_byte:			not.w 	d2
						and.w 	d7,d2
						addq.w	#1,d2
cptb_byte_loop:	moveq 	#0,d0
						movep.w	0(a0),d0
						clr.b 	d0
						lsl.l 	d2,d0
						or.l		d0,(a1)
						adda.w	a2,a0
						adda.w	a3,a1
						dbra		d5,cptb_byte_loop
						rts



ftb_grow_loop: 	move.w	(a5)+,d0
						sub.w 	t_first_ade(a6),d0
						cmp.w 	t_ades(a6),d0	;Zeichen vorhanden ?
						bls.s 	ftb_grow_position
						move.w	t_unknown_index(a6),d0
ftb_grow_position:add.w 	d0,d0
						movem.w	0(a4,d0.w),d0/d4
						sub.w 	d0,d4
						subq.w	#1,d4 			;Zeichenbreite in Pixeln - 1
						bmi.s 	ftb_grow_next
						movea.l	t_image(a6),a0
						move.w	d0,d1 			;x-Quelle
						lsr.w 	#4,d1
						add.w 	d1,d1
						adda.w	d1,a0 			;Quelladresse
						and.w 	d7,d0 			;Shifts der Quelle

						movem.w	d2-d3/d5-d6/a2-a3,-(sp)
						movem.l	a1/a4-a6,-(sp)
						pea		ftb_return(pc)
						tst.b 	t_grow(a6)		;Vergroesserung notwendig ?
						bmi		grow_char
						bra		shrink_char
ftb_return: 		movem.l	(sp)+,a1/a4-a6
						movem.w	(sp)+,d2-d3/d5-d6/a2-a3
						add.w 	d3,d2
						add.w 	d4,d2

						tst.w 	t_add_length(a6)
						beq.s 	ftbg_no_offset

						bsr		text_offset 	;evtl. Offset in d4 zurueckgeben

ftbg_no_offset:	cmp.w 	d7,d2 			;mehr als 15 Shifts ?
						ble.s 	ftb_grow_next
						move.w	d2,d4
						lsr.w 	#4,d4
						add.w 	d4,d4
						adda.w	d4,a1 			;Zieladresse erhoehen
						and.w 	d7,d2 			;neue Shiftanzahl

ftb_grow_next: 	dbra		d6,ftb_grow_loop ;naechstes Zeichen kopieren
						move.l	a1,d4
						sub.l 	buffer_addr(a6),d4
						lsl.w 	#3,d4
						add.w 	d2,d4
						sub.w 	d3,d4 			;Breite
						rts

;doppelte Vergroesserung von bytebreiten Zeichen ohne Shifts
grow_byte2: 		addq.l	#1,a0
grow_byte:			moveq 	#15,d4			;neue Breite
grow_byte_bloop:	moveq 	#0,d1
						move.b	(a0),d0			;Quellwort einlesen
						adda.w	a2,a0 			;naechste Quellzeile
						beq.s 	grow_byte_out
						moveq 	#7,d3 			;Bitzaehler
grow_byte_loop:	add.w 	d1,d1 			;Platz schaffen
						add.w 	d1,d1
						add.b 	d0,d0 			;Bit gesetzt ?
						bcc.s 	grow_byte_next
						addq.w	#3,d1 			;2 Bits setzen
grow_byte_next:	dbra		d3,grow_byte_loop
						move.w	d1,(a1)			;Zielwort ausgeben
						adda.w	a3,a1 			;naechste Zielzeile
						move.w	d1,(a1)
						adda.w	a3,a1
						dbra		d5,grow_byte_bloop
						rts
grow_byte_out: 	adda.w	a3,a1
						adda.w	a3,a1
						dbra		d5,grow_byte_bloop
						rts

;Doppelte Vergroesserung von Zeichen
grow_char2: 		lsr.w 	#1,d5
						cmp.w 	#7,d4
						bne.s 	grow_char_db
						tst.w 	d2
						bne.s 	grow_char_db
						tst.w 	d0 				;kein Quellshift ?
						beq.s 	grow_byte
						cmp.w 	#8,d0 			;8 Quellshifts ?
						beq.s 	grow_byte2
grow_char_db:		move.w	d2,d3 			;Anzahl der Zielshifts
						move.w	d0,d2 			;Anzahl der Quellshifts
						eor.w 	d7,d2
						subq.w	#7,d2
						bgt.s 	grow_db_lloop
						addq.l	#1,a0
						addq.w	#8,d2
grow_db_lloop: 	movea.l	a0,a4 			;Quelladresse
						movea.l	a1,a5 			;Zieladresse
						move.w	d4,d7
grow_db_bloop: 	moveq 	#7,d6
						cmp.w 	d6,d7
						bge.s 	grow_db_read
						move.w	d7,d6
grow_db_read:		subq.w	#8,d7
						moveq 	#0,d1 			;Zielwort
						movep.w	0(a4),d0
						addq.l	#1,a4
						move.b	(a4),d0
						lsr.w 	d2,d0
grow_db_loop:		add.w 	d1,d1 			;Platz schaffen
						add.w 	d1,d1
						add.b 	d0,d0
						bcc.s 	grow_db_white
						addq.w	#3,d1 			;2 Bits setzen
grow_db_white: 	dbra		d6,grow_db_loop

						tst.w 	d7
						bpl.s 	grow_db_out
						move.w	d7,d6
						addq.w	#1,d6
						neg.w 	d6
						add.w 	d6,d6
						lsl.w 	d6,d1
grow_db_out:		ror.l 	d3,d1
						swap		d1
						or.l		d1,(a5)
						or.l		d1,0(a5,a3.w)
						addq.l	#2,a5
						tst.w 	d7
						bpl.s 	grow_db_bloop
						adda.w	a2,a0
						adda.w	a3,a1
						adda.w	a3,a1
						dbra		d5,grow_db_lloop
						add.w 	d4,d4
						addq.w	#1,d4
						moveq 	#15,d7
						rts


;Zeichenvergroesserung
;Eingaben
;d0 Shiftanzahl der Quelldaten
;d2 Shiftanzahl der Zieldaten
;d4 Breite - 1
;d5 vergroesserte Hoehe - 1
;d7 15 (zum ausmaskieren)
;a0 Quelladresse
;a1 Zieladresse
;a2 Bytes pro Quellzeile
;a3 Bytes pro Zielzeile
;a6 Workstation
;Ausgabe
;d4 vergroesserte Breite - 1
;d0-d3/d5-d6/a0-a6 werden zerstoert
grow_char:			move.w	t_iheight(a6),d1
						add.w 	d1,d1
						move.w	t_cheight(a6),d6
						cmp.w 	d6,d1 			;doppelte Vergroesserung ?
						beq		grow_char2
						move.w	d5,-(sp)
						swap		d2
						move.w	d0,d2

						move.w	t_iheight(a6),d5
						addq.w	#1,d4
						mulu		d6,d4
						divu		d5,d4
						subq.w	#1,d4 			;vergroesserte Breite in Pixeln

						moveq 	#16,d1
						add.w 	d4,d1
						swap		d2
						add.w 	d2,d1
						swap		d2
						lsr.w 	#4,d1
						subq.w	#1,d1 			;Wortzaehler fuers kopieren
						swap		d1
						moveq 	#$ffffffff,d7
						swap		d2
						lsr.w 	d2,d7
						swap		d2
						move.w	d7,d1 			;Maske fuers kopieren

						movea.w	d5,a4 			;xs=dy
						sub.w 	d6,d5
						movea.w	d5,a5 			;ys=dy-dx
						move.w	d5,d3 			;e=dy-dx
						swap		d3
						move.w	d5,d3 			;e=dy-dx
						move.w	(sp)+,d5 		;Hoehe in Zeilen
pte_grow_loop: 	bsr.s 	grow_line
						adda.w	a2,a0

						swap		d3
						tst.w 	d3
						bmi.s 	grow_height
pte_grow_next: 	add.w 	a5,d3 			;+ys
						swap		d3
						adda.w	a3,a1
						dbra		d5,pte_grow_loop
						bra.s 	pte_grow_exit
grow_loop2: 		tst.w 	d3
						bpl.s 	pte_grow_next
grow_height:		move.l	d1,d7
						swap		d7 				;Wortzaehler
						movea.l	a1,a6
						adda.w	a3,a6 			;Adresse der naechsten Zielzeile
						move.l	a6,-(sp)
						move.w	(a1)+,d6
						and.w 	d1,d6 			;maskieren
						or.w		d6,(a6)+
						bra.s 	grow_next3
grow_loop3: 		move.w	(a1)+,(a6)+
grow_next3: 		dbra		d7,grow_loop3
						movea.l	(sp)+,a1
						add.w 	a4,d3 			;+xs
						dbra		d5,grow_loop2
pte_grow_exit: 	moveq 	#15,d7
						rts

grow_line:			move.l	a0,-(sp)
						move.l	a1,-(sp)
						move.l	d1,-(sp)
						move.w	d3,-(sp)
						move.w	d4,-(sp)
						move.w	#$8000,d6
						moveq 	#0,d7
						bra.s 	grow_read
grow_next:			add.w 	a5,d3 			;+ys
						ror.w 	#1,d6
						dbcs		d4,grow_loop
						swap		d2
						ror.l 	d2,d7
						swap		d2
						swap		d7
						or.l		d7,(a1)
						addq.l	#2,a1
						moveq 	#0,d7

						subq.w	#1,d4
						bmi.s 	grow_exit
grow_loop:			dbra		d0,grow_test
grow_read:			moveq 	#15,d0
						move.l	(a0),d1

						addq.l	#2,a0
						lsl.l 	d2,d1
						swap		d1
grow_test:			btst		d0,d1
						beq.s 	grow_white
						or.w		d6,d7
grow_white: 		tst.w 	d3
						bpl.s 	grow_next
						add.w 	a4,d3 			;+xs
						ror.w 	#1,d6
						dbcs		d4,grow_test
						swap		d2
						ror.l 	d2,d7
						swap		d2
						swap		d7
						or.l		d7,(a1)
						addq.l	#2,a1
						moveq 	#0,d7
						subq.w	#1,d4

						bpl.s 	grow_test
grow_exit:			move.w	(sp)+,d4
						move.w	(sp)+,d3
						move.l	(sp)+,d1
						movea.l	(sp)+,a1
						movea.l	(sp)+,a0
						rts

;Zeichenverkleinerung
;Eingaben
;d0 Shiftanzahl der Quelldaten
;d2 Shiftanzahl der Zieldaten
;d4 Breite - 1
;d5 verkleinerte Hoehe - 1
;d7 15 (zum ausmaskieren)
;a0 Quelladresse
;a1 Zieladresse
;a2 Bytes pro Quellzeile
;a3 Bytes pro Zielzeile
;a6 Workstation
;Ausgabe
;d4 verkleinerte Breite - 1
;d0-d3/d5-d6/a0-a6 werden zerstoert
shrink_char:		addq.w	#1,d5 			;Bufferhoehe in Pixeln
						move.w	t_cheight(a6),d7
						mulu		t_iheight(a6),d5
						divu		d7,d5
						subq.w	#1,d5
						move.w	d5,-(sp)
						swap		d2
						move.w	d0,d2

						move.w	t_iheight(a6),d5
						addq.w	#1,d4
						mulu		d7,d4
						divu		d5,d4
						subq.w	#1,d4 			;Breite in Pixeln
						bpl.s 	shrink_plus2
						move.w	(sp)+,d5
						bra.s 	shrink_char_exit
shrink_plus2:		movea.w	d7,a4 			;xs=dx
						sub.w 	d5,d7
						movea.w	d7,a5 			;ys=dx-dy
						move.w	d7,d3 			;e=dx-dy
						swap		d3

						move.w	d7,d3 			;e=dx-dy
						move.w	(sp)+,d5 		;Zeilenzaehler fuers Quellimage
shrink_char_loop: bsr.s 	shrink_line
						adda.w	a2,a0
						adda.w	a3,a1
						swap		d3
						tst.w 	d3
						bpl.s 	shrink_height
						add.w 	a4,d3 			;+xs
						suba.w	a3,a1
						swap		d3
						dbra		d5,shrink_char_loop
						bra.s 	shrink_char_exit
shrink_height: 	add.w 	a5,d3 			;+ys
						swap		d3
						dbra		d5,shrink_char_loop
shrink_char_exit: moveq 	#15,d7
						rts

shrink_line:		move.l	a0,-(sp)
						move.l	a1,-(sp)
						move.w	d1,-(sp)
						move.w	d3,-(sp)
						move.w	d4,-(sp)
						move.w	#$8000,d6
						moveq 	#0,d7
						bra.s 	shrink_read
shrink_next:		add.w 	a5,d3 			;+ys
						ror.w 	#1,d6
						dbcs		d4,shrink_loop
						swap		d2
						ror.l 	d2,d7
						swap		d2
						swap		d7
						or.l		d7,(a1)
						addq.l	#2,a1
						moveq 	#0,d7
						subq.w	#1,d4
						bmi.s 	shrink_exit

shrink_loop:		dbra		d0,shrink_test
shrink_read:		moveq 	#15,d0
						move.l	(a0),d1
						addq.l	#2,a0
						lsl.l 	d2,d1
						swap		d1
shrink_test:		btst		d0,d1
						beq.s 	shrink_white
						or.w		d6,d7
shrink_white:		tst.w 	d3
						bpl.s 	shrink_next
						add.w 	a4,d3 			;+xs
						bra.s 	shrink_loop
shrink_exit:		move.w	(sp)+,d4
						move.w	(sp)+,d3
						move.w	(sp)+,d1
						movea.l	(sp)+,a1
						movea.l	(sp)+,a0
						rts

						
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						;'gestreckte Textausgabe'

;Einsprung von v_justified
;Eingaben
;a1.l contrl
;a2.l &intin[2]
;a3.l ptsin
;a6.l Zeiger auf die Workstation
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
text_justified:	move.w	n_intin(a1),d6 ;Zeichenanzahl
						subq.w	#3,d6
						cmp.w 	#32764,d6		;genuegend Zeichen?
						bhi		text_exit

						clr.w 	t_act_line(a6) ;Zeichenzeile 0
						move.w	-2(a2),d3		;char_space
						sne		d3
						ext.w 	d3 				;	-1  => zeichenweise Dehnung

						move.w	d3,t_space_kind(a6) ;	0	=> wortweise Dehnung

						moveq 	#0,d5
						move.w	t_effects(a6),d0
						btst		#T_BOLD_BIT,d0 ;fett?
						beq.s 	textj_outlined
						move.w	t_thicken(a6),d5 ;Verbreiterung durch Fettschrift
textj_outlined:	btst		#T_OUTLINED_BIT,d0 ;umrandet?
						beq.s 	textj_thicken
						addq.w	#2,d5 			;Verbreiterung durch die Umrandung
textj_thicken: 	move.w	d5,t_eff_thicken(a6) ;Verbreiterung durch Effekte

						movem.w	t_first_ade(a6),d0-d1 ;t_first_ade/t_ades
						moveq 	#-1,d4			;Gesambreite vorbesetzen
						move.w	d6,d7 			;Zeichenzaehler
						movea.l	t_fonthdr(a6),a0
						move.l	dat_table(a0),t_image(a6) ;Adresse des Fontimage
						movea.l	a2,a5 			;Adresse von intin
						movea.l	t_offtab(a6),a4 ;Adresse der Zeichenoffsets

textj_width_loop: move.w	(a2)+,d2 		;Zeichennummer
						tst.w 	d3 				;Wortdehnung ?
						bmi.s 	textj_char
						cmp.w 	#SPACE,d2		;Leerzeichen, neues Wort ?
						bne.s 	textj_char
						addq.w	#1,t_space_kind(a6) ;Leerzeichenanzahl erhoehen
textj_char: 		sub.w 	d0,d2
						cmp.w 	d1,d2 			;Zeichen vorhanden ?
						bls.s 	textj_width
						move.w	t_unknown_index(a6),d2
textj_width:		add.w 	d2,d2
						lea		2(a4,d2.w),a0
						move.w	(a0),d2
						sub.w 	-(a0),d2 		;Zeichenbreite ohne Vergroesserung
						tst.b 	t_grow(a6)		;Vergroesserung ?
						beq.s 	textj_add
						mulu		t_cheight(a6),d2 ;* Zeichenhoehe
						divu		t_iheight(a6),d2 ;/ vorhandene Hoehe
textj_add:			add.w 	d5,d2 			;+ Verbreiterung durch Effekte
						add.w 	d2,d4
						dbra		d7,textj_width_loop
						tst.w 	d4 				;mindestens 1 Pixel breit ?
						bmi		text_exit

textj_length:		move.w	4(a3),d3 		;Textlaenge in Pixeln
						btst		#T_ITALICS_BIT,t_effects+1(a6) ;kursiv?
						beq.s 	textj_spacing
						sub.w 	t_whole_off(a6),d3 ;Kursiv-Verbreiterung abziehen

textj_spacing: 	tst.w 	t_space_kind(a6) ;zeichenweise Dehunng?
						bpl.s 	textj_difference
						cmp.w 	t_cwidth(a6),d3 ;Platz fuers breiteste Zeichen ?
						bge.s 	textj_difference
						move.w	t_cwidth(a6),d3
textj_difference: subq.w	#1,d3 			;gewuenschte Textlaenge -1
						neg.w 	d4
						add.w 	d3,d4
						move.w	d4,t_add_length(a6) ;Laengendifferenz
						move.w	d3,d4

						move.w	t_space_kind(a6),d7 ;zeichenweise Dehnung?
						bmi		text_position
						move.w	t_add_length(a6),d2 ;Streckung?
						bpl		text_position

						move.w	t_space_index(a6),d0
						add.w 	d0,d0
						lea		2(a4,d0.w),a0
						move.w	(a0),d0
						sub.w 	-(a0),d0
						mulu		t_cheight(a6),d0
						divu		t_iheight(a6),d0 ;Breite eines Leerzeichens
						mulu		d7,d0 			;Breite aller Leerzeichen
						neg.w 	d0
						cmp.w 	d2,d0 			;Stauchung zu gross?
						ble		text_position
						sub.w 	d2,d4 			;Breite ohne Stauchung
						add.w 	d0,d4
						move.w	d0,t_add_length(a6) ;neue Textlaengendifferenz
						bra		text_position
