;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						;'LINEA'

a_dummy:				rts

linea_tab:			DC.L linea_init			;A-init				($a000)
						DC.L put_pixel 			;Put pixel			($a001)
						DC.L get_pixel 			;Get pixel			($a002)
						DC.L linea_line			;Arbitrary Line	($a003)
						DC.L linea_hline			;Horizontal line	($a004)
						DC.L linea_rect			;Filled rectangle ($a005)
						DC.L a_dummy				;Filled polygon	($a006)
						DC.L linea_bitblt			;Bitblt				($a007)
						DC.L linea_textblt		;TextBlt 			($a008)
						DC.L show_mouse			;Show mouse 		($a009)
						DC.L hide_mouse			;Hide mouse 		($a00a)
						DC.L transform 			;Transform mouse	($a00b)
						DC.L undraw_sprite		;Undraw sprite 	($a00c)
						DC.L draw_sprite			;Draw sprite		($a00d)
						DC.L linea_cpyfm			;Copy raster form ($a00e)
linea_a00f: 		DC.L a_dummy				;Seedfill			($a00f)

; Line-A  Trap-Dispatcher
;Vorgaben:
;Register d0-d2/a0-a2 koennen veraendert werden
;d0-d1/a0/a2 duerfen aber nicht im Dispatcher benutzt werden
;Eingaben:
;d0.w evtl. x-Koordinate
;d1.w evtl. y-Koordinate
;a0.l evtl. Zeiger auf Spritedefinition
;a2.l evtl. Zeiger auf den Hintergrundbuffer
;Ausgaben:
;-
int_linea:
linea_disp: 		movea.l	2(sp),a1
						move.w	(a1)+,d2 		;Funktionsnummer
						move.l	a1,2(sp)
						subi.w	#$a00f,d2		;Funktion vorhanden?
						bgt.s 	linea_exit
						cmp.w		#-$f,d2			;Linea-Init?
						beq.s 	linea_get_addr
						movea.l	linea_wk_ptr,a1
						movea.w	planes(a1),a1
						addq.w	#1,a1
						cmpa.w	PLANES.w,a1		;andere Plane-Anzahl als in der LINEA-WK?
						bne.s		planes_changed
linea_get_addr:	add.w 	d2,d2
						add.w 	d2,d2
						movea.l	linea_a00f(pc,d2.w),a1
						movem.l	d3-d7/a3-a5,-(sp)
						jsr		(a1)
						movem.l	(sp)+,d3-d7/a3-a5
linea_exit: 		rte

planes_changed:	rte

;INIT ($A000)
;Eingaben
; -
;Ausgaben
;d0.l LineA-Basisadresse
;a0.l LineA-Basisadresse
;a1.l LineA-Fonttabelle
;a2.l LineA-Funktionstabelle
linea_init: 		lea		LINE_A_BASE.w,a0
						move.l	a0,d0
						lea		linea_font_tab,a1
						lea		linea_tab(pc),a2
						rts

set_lclip_off: 	lea		clip_xmin(a6),a1
						clr.l 	(a1)+ 			;clip_xmin,clip_ymin
						move.l	#$7fff7fff,(a1)+	;clip_xmax/clip_ymax
						move.w	WMODE.w,(a1)	;wr_mode
						move.w	PLANES.w,d0
						subq.w	#1,d0
						move.w	d0,planes(a6)	;Anzahl der Bildebenen -1
						rts

set_lclip_on: 		tst.w		CLIP.w
						beq.s		set_lclip_off
						lea		clip_xmin(a6),a1
						move.l	XMINCL.w,(a1)+	;clip_xmin,clip_ymin
						move.l	XMAXCL.w,(a1)+	;clip_xmax/clip_ymax
						move.w	WMODE.w,(a1)	;wr_mode
						move.w	PLANES.w,d0
						subq.w	#1,d0
						move.w	d0,planes(a6)	;Anzahl der Bildebenen -1
						rts

;VDI-Farbnummer aus den COLBITs erzeugen
;Eingaben
;a6.l Zeiger auf die Workstation
;Ausgaben
;d1 wird zerstoert
;d0.w VDI-Farbnummer
;a6.l Zeiger auf die Workstation
get_linea_color:	moveq 	#0,d0
						moveq 	#3,d1
						lea		COLBIT3+2.w,a0
linea_color:		add.w 	d0,d0
						tst.w 	-(a0)
						beq.s 	linea_col_next
						add.w 	#1,d0
linea_col_next:	dbra		d1,linea_color
						moveq		#15,d1
						and.w		colors(a6),d1	;Farbanzahl
						and.w 	d1,d0 			;maskieren
						cmp.w 	d0,d1 			;alle Ebenen, Schwarz ?
						bne.s 	linea_color16
linea_col_black:	moveq 	#1,d0 			;VDI-Farbe 1
						rts
linea_color16:		lea		color_remap,a0
						move.b	0(a0,d0.w),d0
						rts

;LineA-Fuellmuster in 16zeiliges VDI-Muster umwandeln
;Vorgaben:
;d0-d2/a0-a2 duerfen veraendert werden
;Eingaben:
;a6.l Zeiger auf die Attributdaten: f_pointer,f_spointer,f_saddr,f_planes,planes
;Ausgaben:
;veraendert werden d0-d2/a0-a2
get_linea_pat: 	movea.l	PATPTR.w,a0 	;Musterzeiger
						lea		f_saddr(a6),a1
						move.w	#F_USER_DEF,f_interior(a6)
						move.l	a1,f_pointer(a6)
						move.w	MFILL.w,f_splanes(a6)
						bne.s 	get_lpat_color
						movea.l	buffer_ptr,a1		;Buffer fuers Muster
						move.w	PATMSK.w,d0
						addq.w	#1,d0 			;Anzahl der Musterzeilen
						moveq 	#16,d2
						divu		d0,d2
						subq.w	#1,d0 			;Musterzeilenzaehler
						subq.w	#1,d2
						bpl.s 	get_lpat_mono
						moveq 	#15,d0
						moveq 	#0,d2
get_lpat_mono: 	move.w	d0,d1
						movea.l	a0,a2
get_lpat_mono2:	move.w	(a2)+,(a1)+
						dbra		d1,get_lpat_mono2
						dbra		d2,get_lpat_mono
						movea.l	buffer_ptr,a0		;Buffer fuers Muster
						moveq		#0,d0						
						bra.s		get_lpat_call		
get_lpat_color:	move.w	planes(a6),d0	;Ebenenzaehler
get_lpat_call:		addq.w	#1,d0
						lsl		#4,d0
						movea.l	f_spointer(a6),a1
						movea.l	p_set_pattern(a6),a2
						jmp		(a2)				;Muster setzen

; Put Pixel ($a001)
;Eingaben
;INTIN.l Zeiger auf intin
;PTSIN.l Zeiger auf ptsin
;intin[0].w Bitmuster
;ptsin[0].w x
;ptsin[1].w y
;Ausgaben
;Register d0-d1/a1-a3.l werden veraendert
put_pixel:			move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						movea.l	INTIN.w,a0
						move.w	(a0)+,d2
						movea.l	PTSIN.w,a0
						move.w	(a0)+,d0
						move.w	(a0)+,d1
						movea.l	p_set_pixel(a6),a0
						jsr		(a0)
						movea.l	(sp)+,a6
						rts
						

; Get Pixel ($a002)
;Eingaben
;PTSIN.l Adresse des ptsin-Arrays, darin ptsin[0/1]
;Ausgaben
;d0.w Bitnummer
get_pixel:			move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						movea.l	PTSIN.w,a0
						move.w	(a0)+,d0
						move.w	(a0),d1
						movea.l	p_get_pixel(a6),a0
						jsr		(a0)
						movea.l	(sp)+,a6
						rts

;ARBITRARY LINE ($A003)
linea_line: 		move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						bsr		set_lclip_off
						bsr		get_linea_color
						move.w	d0,l_color(a6) ;Linienfarbe
						movem.w	X1.w,d0-d3		;Koordinaten
						move.w	LNMASK.w,d6 	;Linienmuster
						tst.w 	LSTLIN.w 		;letztes Pixel setzen?
						seq		d4
						ext.w 	d4
						move.w	d4,l_lastpix(a6)
						pea		linea_line_exit(pc)
						cmp.w 	d1,d3
						beq		hline
						cmp.w 	d0,d2
						beq		vline
						bra		line
linea_line_exit:	clr.w 	l_lastpix(a6)
						movea.l	(sp)+,a6
						rts

;HORIZONTAL LINE ($A004)
linea_hline:		move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						bsr		set_lclip_off
						bsr		get_linea_color
						move.w	d0,f_color(a6) ;Linienfarbe
						bsr	 	get_linea_pat
						movem.w	X1.w,d0-d2		;Koordinaten
						bsr		fline
						movea.l	(sp)+,a6
						rts

;FILLED RECTANGLE ($A005)
linea_rect: 		move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						bsr		set_lclip_on
						bsr		get_linea_color
						move.w	d0,f_color(a6) ;Linienfarbe
						bsr		get_linea_pat
						movem.w	X1.w,d0-d3		;Koordinaten
						bsr		fbox
						movea.l	(sp)+,a6
						rts

;BITBLT ($A007)
linea_bitblt:		move.l	a6,-(sp)
						movea.l	a6,a5								;Zeiger auf die Bitblt-Struktur
						movea.l	linea_wk_ptr,a6
						
						move.l	S_FORM(a5),r_saddr(a6)		;Quelladresse
						move.w	S_NXLN(a5),r_swidth(a6)		;Bytes pro Quellzeile
						move.w	S_NXPL(a5),d0					;mehrere Quellebenen?
						beq.s		linea_blt_spl
						move.w	PLANE_CT(a5),d0
						subq.w	#1,d0
linea_blt_spl:		move.w	d0,r_splanes(a6)				;Anzahl der Quellebenen - 1
						
						move.l	D_FORM(a5),r_daddr(a6)		;Zieladresse
						move.w	D_NXLN(a5),r_dwidth(a6)		;Bytes pro Zielzeile
						move.w	D_NXPL(a5),d0					;mehrere Zielebenen?
						beq.s		linea_blt_dpl
						move.w	PLANE_CT(a5),d0
						subq.w	#1,d0
linea_blt_dpl:		move.w	d0,r_dplanes(a6)				;Anzahl der Zielebenen - 1
						
						move.w	S_XMIN(a5),d0					;xq
						move.w	S_YMIN(a5),d1					;yq
						move.w	D_XMIN(a5),d2					;xz
						move.w	D_YMIN(a5),d3					;yz
						move.w	B_WD(a5),d4
						subq.w	#1,d4								;dx
						move.w	B_HT(a5),d5
						subq.w	#1,d5								;dy
						
						move.w	FG_COL(a5),d6
						move.w	BG_COL(a5),d7
						move.w	d6,r_fgcol(a6)					;Vordergrundfarbe
						move.w	d7,r_bgcol(a6)					;Hintergrundfarbe

						and.w		#1,d6
						and.w		#1,d7
						add.w		d6,d6
						add.w		d7,d6
						move.b	OP_TAB(a5,d6.w),d7
						move.w	d7,r_wmode(a6)					;logische Verknuepfung
												
						cmp.w		#1,PLANE_CT(a5)				;monochromes Raster?
						bne.s		linea_bitblt_blt
						
						movea.l	mono_bitblt,a0
						jsr		(a0)								;monochromes Bitblt ausfuehren
						
						bra.s		linea_blt_exit
						
linea_bitblt_blt: move.w	r_splanes(a6),d6
						cmp.w		r_dplanes(a6),d6				;bitblt oder expblt?
						bne.s		linea_bitblt_exp
						
						movea.l	p_bitblt(a6),a0
						jsr		(a0)
						
						bra.s		linea_blt_exit
						
linea_bitblt_exp:	move.l	OP_TAB(a5),d6
						moveq		#3,d7
						cmp.l		#$010d010d,d6					;Verknuepfungen fuer REVERS TRANSPARENT?
						beq.s		linea_exp_mode
						moveq		#2,d7
						cmp.l		#$06060606,d6					;Verknuepfungen fuer XOR?
						beq.s		linea_exp_mode
						moveq		#1,d7
						cmp.l		#$04040707,d6					;Verknuepfungen fuer TRANSPARENT?
						beq.s		linea_exp_mode
						moveq		#0,d7								;REPLACE
linea_exp_mode:	move.w	d7,r_wmode(a6)
						
						movea.l	p_expblt(a6),a0
						jsr		(a0)

linea_blt_exit:	movea.l	(sp)+,a6
						lea		$4c(a6),a6					;aus Kompatibilitaetsgruenden
						rts

;TEXTBLT ($A008)
linea_textblt: 	move.l	a6,-(sp)
						lea		-sizeof_contrl-2-4-4-sizeof_FONT_HDR(sp),sp

						movea.l	linea_wk_ptr,a6						;LineA-Workstation
						bsr		set_lclip_on							;Clipping setzen

						movea.l	sp,a1										;contrl
						lea		sizeof_contrl(a1),a2					;intin, Zeiger auf temporaeren String
						lea		2(a2),a3									;ptsin, Zeiger auf temporaeres Koordinatenpaar
						lea		4(a3),a4									;off_table, Zeiger auf temporaere Offset-Tabelle
						lea		4(a4),a5									;font_hdr, Zeiger auf temporaeren Fontheader

						lea		color_remap,a0
						move.w	TEXTFG.w,d0								;Vordergrundfarbe
						moveq		#15,d1
						and.w		colors(a6),d1
						and.w		d1,d0
						move.w	#1,t_color(a6)
						cmp.w		d0,d1										;alle Bits gesetzt, schwarz?
						beq.s		atext_init			
						move.b	0(a0,d0.w),t_color(a6)				;VDI-Textfarbe

atext_init:			clr.b		t_mapping(a6)							;kein Mapping
						clr.w		t_first_ade(a6)						;erster Index
						clr.w		t_ades(a6)								;Anzahl der Zeichen - 1
						clr.w		t_space_index(a6)						;Index des Leerzeichens
						clr.w		t_unknown_index(a6)					;Index fuer ein nicht bekanntes Zeichen
						move.b	#1,t_prop(a6)							;Font ist proportional
						clr.b		t_grow(a6)								;keine Vergroesserung oder Verkleinerung
						clr.w		t_no_kern(a6)							;keine Kerning-Paare
						clr.w		t_no_track(a6)							;kein Track-Kerning
						
						clr.l		t_hor(a6)								;t_hor/t_ver
						clr.l		t_base(a6)								;t_base/t_half
						clr.l		t_descent(a6)							;t_descent/t_bottom
						clr.l		t_ascent(a6)							;t_ascent/t_top

						clr.l		t_left_off(a6)							;t_left_off/t_whole_off

						move.w	WEIGHT.w,d0								;WEIGHT, Verbreiterung
						tst.w 	MONO.w									;Font aequidistant?
						beq.s 	atext_thckn
						moveq 	#0,d0
atext_thckn:		cmp.w 	#15,d0									;Verbreiterung zu hoch?
						bls.s 	atext_thckn_save
						moveq 	#15,d0
atext_thckn_save: move.w	d0,t_thicken(a6) 						;Verbreiterung
						
						move.l	a5,t_pointer(a6)						;Zeiger auf temporaeren Fontheader
						move.l	a5,t_fonthdr(a6)						;Zeiger auf temporaeren Fontheader

						move.l	a4,t_offtab(a6)						;Zeiger auf die Offsettabelle
						move.w	SOURCEX.w,d0
						move.w	d0,(a4) 									;off_table[0]: x-Koordinate des Zeichens
						add.w 	DELX.w,d0
						move.w	d0,2(a4) 								;off_table[1]: x-Koordinate des Zeichens + Breite

						movem.w	DESTX.w,d2-d5 							;DESTX, DESTY, DELX, DELY
						
						move.w	FWIDTH.w,d0 							;FWIDTH, Breite des Fontimage
						move.w	d0,t_iwidth(a6)						;Breite des Fontimage
						mulu		SOURCEY.w,d0 							;SOURCEY * FWIDTH
						movea.l	FBASE.w,a0 								;FBASE, Adresse des Fontimage
						adda.l	d0,a0
						move.l	a0,t_image(a6) 						;Adresse des Fontimage
						move.w	d5,t_iheight(a6)

						move.l	a4,off_table(a5)						;Zeiger auf Offsettabelle im Fontheader eintragen
						move.l	t_image(a6),a0
						move.l	a0,dat_table(a5)						;Zeiger auf das Image im Fontheader eintragen
						move.w	t_iwidth(a6),form_width(a5)		;Breite des Images in Bytes
						move.w	t_iheight(a6),form_height(a5)		;Hoehe des Images in Zeilen
						clr.l		next_font(a5)							;kein weiterer Font

						move.w	STYLE.w,d0 								;STYLE, Texteffekte
						bclr		#T_UNDERLINED_BIT,d0					;keine Unterstreichung
						move.w	d0,t_effects(a6) 						;Texteffekte
						move.w	SCALE.w,d6 								;SCALE, Vergroesserung?
						beq.s 	atext_set_height
						
						move.w	DDAINC.w,d1
						mulu		d5,d1										;* tatsaechliche Hoehe
						swap		d1											;/ 65536
						moveq 	#-1,d6 									;Vergroesserung
						tst.w 	SCALDIR.w								;Vergroesserung?
						bgt.s 	atext_height
						moveq 	#1,d6										;Verkleinerung
						moveq 	#0,d5										;d5 loeschen, da d1 die Hoehe enthaelt
atext_height:		add.w 	d1,d5
atext_set_height: move.w	d5,t_cheight(a6)						;Ausgabezeichenhoehe
						move.b	d6,t_grow(a6)							;Flag fuer Vergroesserung, Verkleinerung, keine Skalierung
						move.w	d5,d0
						lsr.w 	#1,d0
						move.w	d0,t_whole_off(a6)					;Verschiebung bei Kursivschrift

						mulu		d5,d4										;DELX * t_cheight
						divu		DELY.w,d4								;/ DELY
						move.w	d4,t_cwidth(a6)						;Ausgabezeichenbreite
						
						move.w	t_effects(a6),d0
						btst		#T_BOLD_BIT,d0 						;fett ?
						beq.s 	atext_outlined
						add.w		t_thicken(a6),d4						;Verbreiterung addieren

atext_outlined:	btst		#T_OUTLINED_BIT,d0					;umrandet ?
						beq.s 	atext_rotation
						addq.w	#2,d4										;2 Pixel breiter
						addq.w	#2,d5										;2 Zeilen hoeher

atext_rotation:	moveq 	#0,d0
						move.w	CHUP.w,d0 								;CHUP, Drehung
						divu		#900,d0
						move.w	d0,t_rotation(a6) 					;Textdrehung
						bne.s 	atext_rot90
						add.w 	d4,DESTX.w								;x-Koordinate des naechsten Zeichens
						bra.s		atext_call

atext_rot90:		subq.w	#T_ROT_90,d0							;Textdrehung um 90 degree ?
						bne.s 	atext_rot180
						sub.w 	d4,DESTY.w								;y-Koordinate des naechsten Zeichens
						bra.s		atext_call

atext_rot180:		subq.w	#T_ROT_180-T_ROT_90,d0 				;Textdrehung um 180 degree ?
						bne.s 	atext_rot270
						sub.w 	d4,DESTX.w								;x-Koordinate des naechsten Zeichens
						bra.s		atext_call
						
atext_rot270:		add.w 	d4,DESTY.w								;y-Koordinate des naechsten Zeichens

atext_call:			move.w	#1,n_intin(a1)							;1 Zeichen
						clr.w		(a2)										;intin[0]: Index 0
						movem.w	d2-d3,(a3)								;ptsin[0/1]: x, y
						bsr		text
						
						lea		sizeof_contrl+2+4+4+sizeof_FONT_HDR(sp),sp
						movea.l	(sp)+,a6
						rts

;SHOW MOUSE ($A009)
show_mouse: 		move.l	a6,-(sp)
						moveq 	#V_SHOW_C,d0
						lea		INTIN-pb_intin.w,a0
						move.l	a0,d1 			;pb
						movea.l	linea_wk_ptr,a6
						bsr		call_nvdi_fkt
						movea.l	(sp)+,a6
						rts

;HIDE MOUSE ($A00A)
hide_mouse: 		move.l	a6,-(sp)
						moveq 	#V_HIDE_C,d0
						lea		INTIN-pb_intin.w,a0
						move.l	a0,d1 			;pb
						movea.l	linea_wk_ptr,a6
						bsr		call_nvdi_fkt
						movea.l	(sp)+,a6
						rts

;TRANSFORM MOUSE ($A00B)
transform:			movea.l	INTIN.w,a2
transform_in:		move.w	DEV_TAB13.w,d5
						subq.w	#1,d5 			;hoechste Farbnummer
						lea		-44(sp),sp		;statt movem d1-d7/a2-a5
						bra		vsc_form_in2

;Undraw Sprite ($A00C)
;Eingaben
;a2.l Zeiger auf den Sprite-Save-Block
;Ausgaben
;d0-d2/a1-a3 werden zerstoert
undraw_sprite: 	move.l	undraw_spr_vec,-(sp)
						rts
undraw_sprite_in: move.w	(a2)+,d2
						subq.w	#1,d2 			;Sprite-Zeilen - 1 wg. dbf
						bmi.s 	undraw_exit

						cmpi.w	#M68030,cpu 	;68030?
						bne.s 	undraw_spr_addr
						btst		#0,blitter+1	;Blitter eingeschaltet?
						beq.s 	undraw_spr_addr
						MC68020
						movec.l	cacr,d0			;DC.L $4e7a0002 
						bset		#11,d0			;Daten-Cache loeschen
						movec.l	d0,cacr			;DC.L $4e7b0002
						MC68000
undraw_spr_addr:	movea.l	(a2)+,a1 		;Zieladresse
						bclr		#0,(a2)			;Bereich gesichert ?
						beq.s 	undraw_exit
						movea.w	BYTES_LIN.w,a3
						addq.l	#2,a2 			;Adresse des Hintergrunds
						move.w	PLANES.w,d0
						moveq 	#0,d1
						move.b	undraw_tab-1(pc,d0.w),d1
						add.w 	d0,d0
						add.w 	d0,d0
						suba.w	d0,a3
						jmp		undraw_tab(pc,d1.w)

undraw_tab: 		DC.B undraw_1_plane-undraw_tab
						DC.B undraw_2_planes-undraw_tab
						DC.B undraw_exit-undraw_tab
						DC.B undraw_4_planes-undraw_tab
						DC.B undraw_exit-undraw_tab
						DC.B undraw_exit-undraw_tab
						DC.B undraw_exit-undraw_tab
						DC.B undraw_8_planes-undraw_tab

undraw_1_plane:	move.l	(a2)+,(a1)+
						adda.w	a3,a1 			;naechste Zeile
						dbra		d2,undraw_1_plane
undraw_exit:		rts
undraw_2_planes:	move.l	(a2)+,(a1)+
						move.l	(a2)+,(a1)+
						adda.w	a3,a1 			;naechste Zeile
						dbra		d2,undraw_2_planes
						rts
undraw_4_planes:	REPT 4
						move.l	(a2)+,(a1)+
						ENDM
						adda.w	a3,a1 			;naechste Zeile
						dbra		d2,undraw_4_planes
						rts
undraw_8_planes:	REPT 8
						move.l	(a2)+,(a1)+
						ENDM
						adda.w	a3,a1 			;naechste Zeile
						dbra		d2,undraw_8_planes
vbl_mouse_exit:	rts

;Interruptroutine in der VBL-Queue
vbl_mouse:			tst.w 	M_HID_CT.w		;Darf die Maus gezeichnet werden ?
						bne.s 	vbl_mouse_exit
						tst.b 	MOUSE_FLAG.w
						bne.s 	vbl_mouse_exit
						bclr		#0,CUR_FLAG.w
						beq.s 	vbl_mouse_exit
						movea.l	mouse_buffer,a2
						move.l	a2,-(sp)
						bsr		undraw_sprite	;Hintergrund zurueckschreiben
						movea.l	(sp)+,a2 		;Bufferadress
						movem.w	CUR_X.w,d0-d1	;Koordinaten des Mauszeigers
						lea		M_POS_HX.w,a0	;Adresse des Mauszeigers

;Draw Sprite ($A00D)
;Eingaben
;d0.w x
;d1.w y
;a0.l Zeiger auf die Spritedefinition
;a2.l Zeiger auf den Hintergrundbuffer
;Ausgaben
;d0-d7/a0-a5 werden zerstoert
draw_sprite:		move.l	draw_spr_vec,-(sp)
						rts
draw_sprite_in:	move.l	a6,-(sp)
						move.w	6(a0),-(sp) 	;Hintergrundfarbe
						move.w	8(a0),-(sp) 	;Vordergrundfarbe
						clr.w 	d2
						tst.w 	4(a0) 			;intform
						bge.s 	vdi_form 		;+1-> VDI-Format
						moveq 	#16,d2			;-1-> XOR-Format

vdi_form:			move.w	d2,-(sp) 		;Offset fuer VDI/XOR-Routinen
						clr.w 	d2 				;Offset fuer MOVE-Routinen
						sub.w 	(a0),d0			;X_Koord - intxhot
						bcs.s 	Xko_lt_intxh	;X_Koord < intxhot

						move.w	DEV_TAB0.w,d3	;WORK_OUT[0] max. Rasterbreite
						subi.w	#15,d3
						cmp.w 	d3,d0
						bhi.s 	X_am_rRand		;X_koord > Rasterbreite-15
						bra.s 	get_yhot

Xko_lt_intxh:		addi.w	#16,d0			;X_koord+16
						moveq 	#4,d2 			;Offset fuer MOVE-Routinen
						bra.s 	get_yhot

X_am_rRand: 		moveq 	#8,d2
get_yhot:			sub.w 	2(a0),d1 		;Y_Koord - intyhot
						lea		10(a0),a0		;Zeiger auf das Sprite-Image
						bcs.s 	Y_am_oRand		;Y_koord < intyhot

						move.w	DEV_TAB1.w,d3	;max. Rasterhoehe
						subi.w	#15,d3			;Rasterhoehe - 15
						cmp.w 	d3,d1

						bhi.s 	Y_am_uRand		;Y_Koord > Rasterhoehe-15
						moveq 	#16,d5
						bra.s 	hole_Koord

Y_am_oRand: 		move.w	d1,d5
						addi.w	#16,d5
						asl.w 	#2,d1
						suba.w	d1,a0
						clr.w 	d1
						bra.s 	hole_Koord

Y_am_uRand: 		move.w	DEV_TAB1.w,d5	;max. Rasterhoehe
						sub.w 	d1,d5
						addq.w	#1,d5

hole_Koord: 		bsr		calc_addr
						andi.w	#15,d0

						lea		draw_sprite_right(pc),a3
						move.w	d0,d6 			;Xbit sichern
						cmpi.w	#8,d6
						bcs.s 	load_drrout 	;Xbit < 8

;mindendestens 8 ROR-> daher ueber ROL gehen
						lea		draw_sprite_left(pc),a3
						move.w	#16,d6
						sub.w 	d0,d6 			;16 - ROR-Anzahl

load_drrout:		movea.l	draw_spr_tab1(pc,d2.w),a5
						movea.l	draw_spr_tab2(pc,d2.w),a6

						move.w	PLANES.w,d7
						move.w	d7,d3
						add.w 	d3,d3 			;PLANES*2
						ext.l 	d3
						move.w	BYTES_LIN.w,d4 ;Bytes pro Pixelzeile

						cmpi.w	#M68030,cpu 	;68030?
						bne.s 	draw_spr_h
						btst		#0,blitter+1	;Blitter eingeschaltet?
						beq.s 	draw_spr_h
						MC68020
						movec.l	cacr,d0			;DC.L $4e7a0002 
						bset		#11,d0			;Daten-Cache loeschen
						movec.l	d0,cacr			;DC.L $4e7b0002 			
						MC68000
draw_spr_h: 		move.w	d5,(a2)+ 		;Zeilenanzahl
						move.l	a1,(a2)+ 		;Quelladresse
						cmpa.l	#draw_spr_word2,a6
						bne.s 	draw_x_ok
						sub.l 	d3,-4(a2)
draw_x_ok:			move.w	#$0300,(a2)+	;Information in Langworten
						subq.w	#1,d5
						bpl.s 	draw_spr_next	;Verknuepfungsmode waehlen
						bra.s 	draw_spr_exit

draw_spr_tab1: 	DC.L draw_spr_long
						DC.L draw_spr_left
						DC.L draw_spr_right
draw_spr_tab2: 	DC.L draw_spr
						DC.L draw_spr_word1
						DC.L draw_spr_word2

draw_spr_loop: 	clr.w 	d0
						lsr.w 	2(sp) 			;Vordergrundfarbe
						addx.w	d0,d0
						lsr.w 	4(sp) 			;Hintergrundfarbe
						roxl.w	#3,d0
						add.w 	(sp),d0			;Offset fuer VDI/XOR-Rout. addieren
						movea.l	draw_spr_link(pc,d0.w),a4 ;Sprungadresse

						move.w	d5,-(sp)
						movem.l	a0-a2,-(sp)
						jsr		(a6)				;Bildebene ausgeben
						movem.l	(sp)+,a0-a2
						move.w	(sp)+,d5

						addq.l	#2,a1 			;naechste Bildebene
						addq.l	#2,a2 			;naechste Bufferebene

draw_spr_next: 	dbra		d7,draw_spr_loop
draw_spr_exit: 	addq.l	#6,sp
						movea.l	(sp)+,a6
						rts
; Adressen der Verknuepfungsroutinen
draw_spr_link: 	DC.L draw_spr_vdi0
						DC.L draw_spr_vdi1
						DC.L draw_spr_vdi2
						DC.L draw_spr_vdi3
						DC.L draw_spr_eor0
						DC.L draw_spr_eor1
						DC.L draw_spr_eor2
						DC.L draw_spr_eor3

;Hauptschleife, um eine Bildebenen auszugeben
;Eingaben
;d3.w Abstand zum naechsten Wort der Bildebene
;a1.l Zieladresse
;a2.l Sprite-Save-Buffer
;a3.l Adresse der Rotierroutine

;Ausgaben
;d2.l Hintergrund
draw_spr:			move.w	(a1),d2
						move.w	d2,(a2)
						adda.w	d3,a2
						swap		d2
						move.w	0(a1,d3.w),d2
						move.w	d2,(a2)
						adda.w	d3,a2
						jmp		(a3)
draw_spr_long: 	move.w	d2,0(a1,d3.w)
						swap		d2
						move.w	d2,(a1)
						adda.w	d4,a1 			;naechste Zeile
						dbra		d5,draw_spr
						rts

draw_spr_word1:	move.w	(a1),d2
						move.w	d2,(a2)
						adda.w	d3,a2
						move.w	0(a1,d3.w),(a2)
						adda.w	d3,a2
						jmp		(a3)
draw_spr_left: 	move.w	d2,(a1)
						adda.w	d4,a1 			;naechste Zeile
						dbra		d5,draw_spr_word1
						rts

draw_spr_word2:	move.w	(a1),d2
						neg.w 	d3
						move.w	0(a1,d3.w),(a2)
						neg.w 	d3
						adda.w	d3,a2
						move.w	d2,(a2)
						adda.w	d3,a2
						swap		d2
						jmp		(a3)
draw_spr_right:	swap		d2
						move.w	d2,(a1)
						adda.w	d4,a1 			;naechste Zeile
						dbra		d5,draw_spr_word2
						rts

;Spritezeile auslesen und rotieren
;Eingaben
;d6.l Shiftanzahl

;a0.l Zeiger auf Vorder- und Hintergrundmaske
;a4.l Adresse der Verknuepfenden Routine
;Ausgaben
;d0.l Vordergrundmaske
;d1.l Hintergrundmaske
draw_sprite_left: moveq 	#0,d0
						moveq 	#0,d1
						move.w	(a0)+,d0 		;Sprite
						move.w	(a0)+,d1 		;Maske
						rol.l 	d6,d0 			;um Xbit rotieren
						rol.l 	d6,d1 			;um Xbit rotieren
						jmp		(a4)				;je nach Verknuepfung LINK-Rout. anspringen

draw_sprite_right:move.l	(a0)+,d0 		;Sprite/Maske
						move.w	d0,d1
						swap		d1
						clr.w 	d0 				;Sprite
						clr.w 	d1 				;Maske
						ror.l 	d6,d0 			;um Xbit rotieren
						ror.l 	d6,d1 			;um Xbit rotieren
						jmp		(a4)				;je nach Verknuepfung LINK-Rout. anspringen

;Verknuepfungsroutinen
;Eingaben
;d0.l Vordergrundmaske
;d1.l Hintergrundmaske
;d2.l Bildausschnitt
;a5.l Adresse der ausgebenden Routine
;Ausgaben
;d2.l Ausgabezeile
draw_spr_vdi0: 	or.l		d1,d0
						not.l 	d0
						and.l 	d0,d2
						jmp		(a5)
draw_spr_vdi1: 	or.l		d0,d2
						not.l 	d1
						and.l 	d1,d2
						jmp		(a5)
draw_spr_vdi2: 	not.l 	d0
						and.l 	d0,d2
						or.l		d1,d2
						jmp		(a5)
draw_spr_vdi3: 	or.l		d0,d2
						or.l		d1,d2
						jmp		(a5)
draw_spr_eor0: 	eor.l 	d1,d2
						not.l 	d0
						and.l 	d0,d2
						jmp		(a5)
draw_spr_eor1: 	or.l		d0,d2
						eor.l 	d1,d2
						jmp		(a5)
draw_spr_eor2: 	not.l 	d0
						and.l 	d0,d2
						eor.l 	d1,d2
						jmp		(a5)
draw_spr_eor3: 	eor.l 	d0,d2
						or.l		d1,d2
						jmp		(a5)

;Adresse aufloesungsunabhaengig berechnen
;Eingaben
;d0.w x
;d1.w y
;Ausgaben
;d0.w x
;d1.w y
;a1.l Adresse
calc_addr:			move.w	d0,-(sp)
						move.w	d1,-(sp)

						movea.l	v_bas_ad.w,a1
						muls		BYTES_LIN.w,d1
						adda.l	d1,a1 			;Zeilenadresse
						and.w 	#$fff0,d0
						asr.w		#3,d0
						mulu		PLANES.w,d0		;Anzahl der Bytes
						adda.w	d0,a1 			;Zieladresse
						move.w	(sp)+,d1
						move.w	(sp)+,d0
						rts

;COPY RASTER ($A00E)
linea_cpyfm:		move.l	a6,-(sp)
						movea.l	linea_wk_ptr,a6
						lea		clip_xmin(a6),a0
						clr.l 	(a0)+ 			;clip_xmin,clip_ymin
						move.l	#$7fff7fff,(a0)+ ;clip_xmax/clip_ymax
						move.w	DEV_TAB13.w,d0
						subq.w	#1,d0
						move.w	d0,colors(a6)	;hoechste Farbnummer
						lea		CONTRL.w,a0 	;Zeiger auf den PB
						move.l	a0,d1
						pea		linea_cf_exit(pc)
						tst.w 	COPYTRAN.w
						beq		vro_cpyfm
						bra		vrt_cpyfm
linea_cf_exit: 	movea.l	(sp)+,a6
						rts

;Maus-Interruptroutine
;Vorgaben:
;kein Register wird veraendert
;Eingaben:
;a0.l Zeiger auf ein Datenpaket
;Ausgaben:
;-
mouse_int_lower:	move		sr,-(sp)
						movem.l	d0-d3/a0-a1,-(sp)

						ori		#$0700,sr
						andi		#$fdff,sr		;auf IPL 5 herunterschalten

mouse_int_but: 	move.b	(a0)+,d0
						move.b	d0,d1
						moveq 	#$fffffff8,d2
						and.b 	d2,d1
						sub.b 	d2,d1 			;Datenpaket der Maus?
						bne.s 	mouse_exit
						moveq 	#3,d2
						and.w 	d2,d0 			;Status der Maustasten (Bit 0 und 1 sind vertauscht)
						lsr.w 	#1,d0 			;rechte Maustaste gedrueckt?
						bcc.s 	mouse_but
						addq.w	#2,d0 			;wenn ja dann Bit 1 setzen
mouse_but:			move.b	CUR_MS_STAT.w,d1
						and.w 	d2,d1 			;Maustasten ausmaskieren
						cmp.w 	d1,d0 			;hat sich der Tastenstatus veraendert?
						beq.s 	mouse_no_but
						movea.l	USER_BUT.w,a1
						move.w	d1,-(sp)
						jsr		(a1)
						move.w	(sp)+,d1
						move.w	d0,MOUSE_BT.w
						eor.b 	d0,d1
						ror.b 	#2,d1
						or.b		d0,d1 			;Veraenderung des Tastenstatus (Bit 6 und 7)
mouse_no_but:		move.b	d1,CUR_MS_STAT.w
						move.b	(a0)+,d2 		;Bewegung in x-Richtung
						move.b	(a0)+,d3 		;Bewegung in y-Richtung
						move.b	d2,d0
						or.b		d3,d0 			;wurde die Maus bewegt?
						beq.s 	mouse_exit
						ext.w 	d2
						ext.w 	d3
						movem.w	GCURX.w,d0-d1	;letzte Maus-Koordinaten
						add.w 	d2,d0
						add.w 	d3,d1
						bsr.s 	clip_mouse		;Clipping der Maus-Koordinaten
						cmp.w 	GCURX.w,d0		;x-Koordinate veraendert?
						bne.s 	mouse_user_mot
						cmp.w 	GCURY.w,d1		;y-Koordinate veraendert?
						beq.s 	mouse_exit
mouse_user_mot:	bset		#5,CUR_MS_STAT.w ;Maus wurde bewegt
						movem.w	d0-d1,-(sp)
						movea.l	USER_MOT.w,a1
						jsr		(a1)
						movem.w	(sp)+,d2-d3
						sub.w 	d0,d2
						sub.w 	d1,d3
						or.w		d2,d3
						beq.s 	mouse_savexy
						bsr.s 	clip_mouse		;Cliping der Maus-Koordinaten
mouse_savexy:		movem.w	d0-d1,GCURX.w
						movea.l	USER_CUR.w,a1
						jsr		(a1)
mouse_exit: 		movem.l	(sp)+,d0-d3/a0-a1
						move		(sp)+,sr
						rts

clip_mouse: 		tst.w 	d0
						bpl.s 	clip_mouse_x2
						moveq 	#0,d0
						bra.s 	clip_mouse_y1
clip_mouse_x2: 	cmp.w 	V_REZ_HZ.w,d0
						blt.s 	clip_mouse_y1
						move.w	V_REZ_HZ.w,d0
						subq.w	#1,d0
clip_mouse_y1: 	tst.w 	d1
						bpl.s 	clip_mouse_y2
						moveq 	#0,d1
						rts
clip_mouse_y2: 	cmp.w 	V_REZ_VT.w,d1
						blt.s 	clip_mouse_exit
						move.w	V_REZ_VT.w,d1
						subq.w	#1,d1
clip_mouse_exit:	rts

;USER_CUR
user_cur:			move		sr,-(sp)
						ori		#$0700,sr
						move.w	d0,CUR_X.w		;x-Koordinate der Maus
						move.w	d1,CUR_Y.w		;y-Koordinate der Maus
						bset		#0,CUR_FLAG.w	;Maus muss beim naechsten VBL gezeichnet werden
						move		(sp)+,sr
						rts

;Interruptroutine, die bei etv_timer eingeklinkt ist
sys_timer:			move.l	NEXT_TIM.w,-(sp) ;USER_TIM springt NEXT_TIM an
						move.l	USER_TIM.w,-(sp)
						rts							;USER_TIM anspringen

