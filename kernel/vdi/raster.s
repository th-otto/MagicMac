						;'4. Rasterfunktionen'

; COPY RASTER, OPAQUE (VDI 109)
vro_cpyfm:			movem.l	d1-d7/a2-a5,-(sp)
						movem.l	(a0),a1-a3		;contrl,intin,ptsin

						move.w	(a2),d0			;Modus
						cmp.w 	#15,d0			;gueltig ?
						bhi		vro_cpyfm_exit
						move.w	d0,r_wmode(a6)

vro_cpyfm2: 		movem.l	s_addr(a1),a4-a5 ;psrcMFDB/pdesMFDB
						movem.w	(a3),d0-d7

vro_sx:				cmp.w 	d0,d2 			;xq1 > xq2?
						bge.s 	vro_sy
						exg		d0,d2				;Koordinaten tauschen
vro_sy:				cmp.w 	d1,d3				;yq1 > yq2?
						bge.s 	vro_dx
						exg		d1,d3				;Koordinaten tauschen
vro_dx:				cmp.w 	d4,d6				;xz1 > xz2?
						bge.s 	vro_dy
						exg		d4,d6				;Koordinaten tauschen
vro_dy:				cmp.w 	d5,d7				;yz1 > yz2?
						bge.s 	vro_src
						exg		d5,d7				;Koordinaten tauschen

vro_src: 			move.l	(a4),r_saddr(a6) ;Quelladresse
						beq.s 	vro_src_screen

						move.w	fd_nplanes(a4),d7
						subq.w	#1,d7
						cmp.w		#7,d7					;sollen 8 Planes kopiert werden?
						bne.s		vro_src_planes
						cmp.w		planes(a6),d7		;Geraet mit mehr als 8 Planes?
						bge.s		vro_src_planes
						move.w	planes(a6),d7		;AES-Fehler korrigieren
vro_src_planes:	move.w	d7,r_splanes(a6) ;Anzahl der Bildebenen - 1
						addq.w	#1,d7
						mulu		fd_wdwidth(a4),d7
						add.w 	d7,d7
						move.w	d7,r_swidth(a6) ;Bytes pro Quellzeile
						mulu		fd_h(a4),d7
						move.l	d7,r_splane_len(a6)

						move.l	v_bas_ad.w,d7
						cmp.l 	r_saddr(a6),d7 ;Adresse wie beim Bildschirm?
						bne.s 	vro_des
						move.w	fd_w(a4),d7
						cmp.w 	V_REZ_HZ.w,d7	;Breite in Pixeln wie beim Bildschirm?
						bne.s 	vro_des
						move.w	PLANES.w,d7
						subq.w	#1,d7
						cmp.w 	r_splanes(a6),d7	;Planeanzahl wie beim Bildschirm?
						bne.s 	vro_des

vro_src_screen:	move.l	v_bas_ad.w,r_saddr(a6) ;Bildadresse
						move.w	BYTES_LIN.w,r_swidth(a6) ;Breite einer Bildzeile in Bytes
						move.l	bitmap_len(a6),r_splane_len(a6)
						move.w	planes(a6),r_splanes(a6) ;Planes - 1
						tst.w 	bitmap_width(a6) ;Off-Screen-Bitmap?
						beq.s 	vro_des
						move.l	bitmap_addr(a6),r_saddr(a6) ;Adresse der Bitmap
						move.w	bitmap_width(a6),r_swidth(a6) ;Bytes pro Zeile
						sub.w		bitmap_off_x(a6),d0
						sub.w		bitmap_off_y(a6),d1
						sub.w		bitmap_off_x(a6),d2
						sub.w		bitmap_off_y(a6),d3
						
vro_des: 			move.l	(a5),r_daddr(a6) ;Zieladresse
						beq.s 	vro_des_screen

						move.w	fd_nplanes(a5),d7
						subq.w	#1,d7
						cmp.w		#7,d7					;sollen 8 Planes kopiert werden?
						bne.s		vro_des_planes
						cmp.w		planes(a6),d7		;Geraet mit mehr als 8 Planes?
						bge.s		vro_des_planes
						move.w	planes(a6),d7		;AES-Fehler korrigieren
vro_des_planes:	move.w	d7,r_dplanes(a6) ;Anzahl der Bildebenen - 1
						addq.w	#1,d7
						mulu		fd_wdwidth(a5),d7
						add.w 	d7,d7
						move.w	d7,r_dwidth(a6) ;Bytes pro Zielzeile
						mulu		fd_h(a5),d7
						move.l	d7,r_dplane_len(a6)

						move.l	v_bas_ad.w,d7
						cmp.l 	r_daddr(a6),d7 ;Adresse wie beim Bildschirm?
						bne	 	vro_width
						move.w	fd_w(a5),d7
						cmp.w 	V_REZ_HZ.w,d7	;Breite in Pixeln wie beim Bildschirm?
						bne.s 	vro_width
						move.w	PLANES.w,d7
						subq.w	#1,d7
						cmp.w 	r_dplanes(a6),d7	;Planeanzahl wie beim Bildschirm?
						bne.s 	vro_width
						move.w	BYTES_LIN.w,r_dwidth(a6) ;richtige Breite einsetzen
						bra.s 	vro_width

vro_des_screen:	move.w	d2,d6 			;xq2
						move.w	d3,d7 			;yq2
						sub.w 	d0,d6 			;- xq1 = Breite -1
						sub.w 	d1,d7 			;- yq1 = Hoehe -1
						add.w 	d4,d6 			;+ xz1 = xz2
						add.w 	d5,d7 			;+ yz1 = yz2

						lea		clip_xmin(a6),a1
						cmp.w 	(a1)+,d4 		;xz1 < clip_xmin?
						bge.s 	vro_clipdy1
						sub.w 	-(a1),d4
						sub.w 	d4,d0				;xq1 korrigieren
						move.w	(a1)+,d4
vro_clipdy1:		cmp.w 	(a1)+,d5 		;yz1 < clip_ymin?
						bge.s 	vro_clipdx2
						sub.w 	-(a1),d5
						sub.w 	d5,d1				;yq1 korrigieren
						move.w	(a1)+,d5
vro_clipdx2:		sub.w 	(a1)+,d6 		;xz2 > clip_xmax?
						ble.s 	vro_clipdy2
						sub.w 	d6,d2				;xq2 korrigieren
vro_clipdy2:		sub.w 	(a1),d7			;yz2 > clip_ymax?
						ble.s 	vro_desaddr
						sub.w 	d7,d3				;yq2 korrigieren

vro_desaddr:		move.l	v_bas_ad.w,r_daddr(a6) ;Bildadresse
						move.w	BYTES_LIN.w,r_dwidth(a6) ;Breite einer Bildzeile in Bytes
						move.l	bitmap_len(a6),r_dplane_len(a6)
						move.w	planes(a6),r_dplanes(a6)	;Planes - 1

						move.w 	bitmap_width(a6),d7 ;Off-Screen-Bitmap?
						beq.s 	vro_width

						move.l	bitmap_addr(a6),r_daddr(a6) ;Adresse der Bitmap
						move.w	d7,r_dwidth(a6) ;Bytes pro Zeile
						sub.w		bitmap_off_x(a6),d4
						sub.w		bitmap_off_y(a6),d5

;ausserhalb des Clipping-Rechtecks ?
vro_width:			exg		d2,d4
						exg		d3,d5

						sub.w 	d0,d4 			;Breite der Quelle - 1
						bmi.s 	vro_cpyfm_exit
						sub.w 	d1,d5 			;Hoehe der Quelle - 1
						bmi.s 	vro_cpyfm_exit

						move.w	r_dplanes(a6),d6
						cmp.w		planes(a6),d6	;Planeanzahl abweichend von der des Geraets?
						bne.s		vro_cpyfm_mono
						
						movea.l	p_bitblt(a6),a0
						jsr		(a0)

vro_cpyfm_exit:	movem.l	(sp)+,d1-d7/a2-a5
						rts

vro_cpyfm_mono:	tst.w		d6					;monochrom?
						bne.s		vro_cpyfm_exit

						move.l	mono_bitblt,d6	;Treiber vorhanden?
						beq.s		vro_cpyfm_exit
						movea.l	d6,a0
						jsr		(a0)

						movem.l	(sp)+,d1-d7/a2-a5
						rts



; COPY RASTER, TRANSPARENT (VDI 121)
vrt_cpyfm:			movem.l	d1-d7/a2-a5,-(sp)
						movem.l	(a0),a1-a3
						move.w	(a2)+,d0
						subq.w	#REPLACE,d0
						cmpi.w	#REV_TRANS-REPLACE,d0
						bhi.s 	vro_cpyfm_exit
						move.w	d0,r_wmode(a6)
						move.w	(a2)+,d0 		;fg_col
						move.w	(a2)+,d1 		;bg_col
						cmp.w 	colors(a6),d0	;zu hohe Farbnummer ?
						bls.s 	vrt_cpyfm_bg
						moveq 	#BLACK,d0
vrt_cpyfm_bg:		cmp.w 	colors(a6),d1	;zu hohe Farbnummer ?
						bls.s 	vrt_cpyfm_fbg
						moveq 	#BLACK,d1
vrt_cpyfm_fbg: 	move.w	d0,r_fgcol(a6) ;fg_col
						move.w	d1,r_bgcol(a6) ;bg_col

						movem.l	s_addr(a1),a4-a5 ;psrcMFDB/pdesMFDB
						movem.w	(a3),d0-d7

vrt_sx:				cmp.w 	d0,d2 			;Koordinaten tauschen ?
						bge.s 	vrt_sy
						exg		d0,d2
vrt_sy:				cmp.w 	d1,d3
						bge.s 	vrt_dx
						exg		d1,d3
vrt_dx:				cmp.w 	d4,d6
						bge.s 	vrt_dy
						exg		d4,d6
vrt_dy:				cmp.w 	d5,d7
						bge.s 	vrt_src
						exg		d5,d7

vrt_src: 			move.l	(a4),r_saddr(a6) ;Quelladresse
						bne.s 	vrt_src_width

						move.l	v_bas_ad.w,r_saddr(a6) ;Bildadresse
						move.w	BYTES_LIN.w,r_swidth(a6) ;Breite einer Bildzeile in Bytes
						move.w	planes(a6),d7
clr.w d7
						tst.w 	bitmap_width(a6) ;Off-Screen-Bitmap?
						beq.s 	vrt_src_planes
						move.l	bitmap_addr(a6),r_daddr(a6) ;Adresse der Bitmap
						move.w	bitmap_width(a6),r_dwidth(a6) ;Bytes pro Zeile
						sub.w		bitmap_off_x(a6),d0
						sub.w		bitmap_off_y(a6),d1
						sub.w		bitmap_off_x(a6),d2
						sub.w		bitmap_off_y(a6),d3
						bra.s 	vrt_src_planes

vrt_src_width: 	move.w	fd_wdwidth(a4),d7
						add.w 	d7,d7
						move.w	d7,r_swidth(a6) ;Bytes pro Quellzeile
						mulu		fd_h(a4),d7
						move.l	d7,r_splane_len(a6)
						move.w	fd_nplanes(a4),d7
						subq.w 	#1,d7
vrt_src_planes:	move.w	d7,r_splanes(a6) ;Anzahl der Bildebenen - 1
						bne		vrt_cpyfm_exit

						move.l	(a5),r_daddr(a6) ;Zieladresse
						beq.s 	vrt_des_screen

						move.w	fd_nplanes(a5),d7
						subq.w	#1,d7
						cmp.w		#7,d7					;sollen 8 Planes kopiert werden?
						bne.s		vrt_des_planes
						cmp.w		planes(a6),d7		;Geraet mit mehr als 8 Planes?
						bge.s		vrt_des_planes
						move.w	planes(a6),d7		;AES-Fehler korrigieren
vrt_des_planes:	move.w	d7,r_dplanes(a6) ;Anzahl der Bildebenen - 1
						addq.w	#1,d7
						mulu		fd_wdwidth(a5),d7
						add.w 	d7,d7
						move.w	d7,r_dwidth(a6) ;Bytes pro Zielzeile
						mulu		fd_h(a5),d7
						move.l	d7,r_dplane_len(a6)

						move.l	v_bas_ad.w,d7
						cmp.l 	r_daddr(a6),d7 ;Abfrage fuer OVERSCAN
						bne.s 	vrt_width
						move.w	fd_w(a5),d7
						cmp.w 	V_REZ_HZ.w,d7	;Bildschirmbreite in Pixeln ?
						bne.s 	vrt_width
						move.w	BYTES_LIN.w,r_dwidth(a6) ;richtige Breite einsetzen
						bra.s 	vrt_width

vrt_des_screen:	move.w	d2,d6 			;xq2
						move.w	d3,d7 			;yq2
						sub.w 	d0,d6 			;- xq1 = Breite -1
						sub.w 	d1,d7 			;- yq1 = Hoehe -1
						add.w 	d4,d6 			;+ xz1 = xz2
						add.w 	d5,d7 			;+ yz1 = yz2

						lea		clip_xmin(a6),a1
						cmp.w 	(a1)+,d4 		;xz1 < clip_xmin?
						bge.s 	vrt_clipdy1
						sub.w 	-(a1),d4
						sub.w 	d4,d0				;xq1 korrigieren
						move.w	(a1)+,d4
vrt_clipdy1:		cmp.w 	(a1)+,d5 		;yz1 < clip_ymin?
						bge.s 	vrt_clipdx2
						sub.w 	-(a1),d5
						sub.w 	d5,d1				;yq1 korrigieren
						move.w	(a1)+,d5
vrt_clipdx2:		sub.w 	(a1)+,d6 		;xz2 > clip_xmax?
						ble.s 	vrt_clipdy2
						sub.w 	d6,d2				;xq2 korrigieren
vrt_clipdy2:		sub.w 	(a1),d7			;yz2 > clip_ymax?
						ble.s 	vrt_desaddr
						sub.w 	d7,d3				;yq2 korrigieren

vrt_desaddr:		move.l	v_bas_ad.w,r_daddr(a6) ;Bildadresse
						move.w	BYTES_LIN.w,r_dwidth(a6) ;Breite einer Bildzeile in Bytes
						move.w	planes(a6),r_dplanes(a6)	;Planes - 1
						move.l	bitmap_len(a6),r_dplane_len(a6)
						move.w 	bitmap_width(a6),d7 ;Off-Screen-Bitmap?
						beq.s 	vrt_width
						move.l	bitmap_addr(a6),r_daddr(a6) ;Adresse der Bitmap
						move.w	d7,r_dwidth(a6) ;Bytes pro Zeile
						sub.w		bitmap_off_x(a6),d4
						sub.w		bitmap_off_y(a6),d5

;ausserhalb des Clipping-Rechtecks ?
vrt_width:			exg		d2,d4
						exg		d3,d5

						sub.w 	d0,d4 			;Breite der Quelle - 1
						bmi.s 	vrt_cpyfm_exit
						sub.w 	d1,d5 			;Hoehe der Quelle - 1
						bmi.s 	vrt_cpyfm_exit

						move.w	r_dplanes(a6),d6
						cmp.w		planes(a6),d6	;Planeanzahl abweichend von der des Geraets?
						bne.s		vrt_cpyfm_mono

						movea.l	p_expblt(a6),a0
						jsr		(a0)

vrt_cpyfm_exit:	movem.l	(sp)+,d1-d7/a2-a5
						rts
						
vrt_cpyfm_mono:	tst.w		d6					;monochromes vrt_cpyfm?
						bne.s		vrt_cpyfm_exit
						
						move.l	mono_expblt,d6	;Treiber vorhanden?
						beq.s		vrt_cpyfm_exit
						movea.l	d6,a0
						jsr		(a0)

						movem.l	(sp)+,d1-d7/a2-a5
						rts

; TRANSFORM FORM (VDI 110)
vr_trnfm:			movem.l	d1-d7/a2-a5,-(sp)
						movea.l	(a0),a1				;contrl
						movem.l	s_addr(a1),a0-a1	;Zeiger auf psrcMFDB/pdesMFDB
						movea.l	p_transform(a6),a2
						jsr		(a2)
						movem.l	(sp)+,d1-d7/a2-a5
						rts

; GET PIXEL (VDI 105)
v_get_pixel:		movem.l	d1-d2/a2,-(sp)
						movea.l	pb_intout(a0),a2
						movea.l	pb_ptsin(a0),a0
						
						move.w	(a0)+,d0
						move.w	(a0)+,d1
						movea.l	p_get_pixel(a6),a0
						jsr		(a0)

						cmp.w		#15,planes(a6)	;mehr als 16 Bit?
						bgt.s		v_get_pixel_tc
						
						move.w	d0,(a2)+			;intout[0] = Pixelzustand
						movea.l	p_color_to_vdi(a6),a0
						jsr		(a0)
						move.w	d0,(a2)+			;intout[1] = VDI-Farbindex
						
						movem.l	(sp)+,d1-d2/a2
						rts

v_get_pixel_tc:	swap		d0
						move.l	d0,(a2)+

						movem.l	(sp)+,d1-d2/a2
						rts

