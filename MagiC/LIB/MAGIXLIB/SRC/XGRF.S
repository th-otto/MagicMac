* Bibliotheksmodul fÅr MAGIX.LIB


	INCLUDE	"MAGILIB.INC"

	   XREF	__aes


	   XDEF	xgrf_stepcalc			; GEM 2.x
	   XDEF	xgrf_2box				; GEM 2.x



**********************************************************************
*
* int xgrf_stepcalc( d0 = int orgw, d1 = int orgh,
*				 d2 = int x, int y, int w, int h,
*				 a0 = int *cx, a1 = int *cy,
*				 int	*cnt, int *xstep, int *ystep )
*

xgrf_stepcalc:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 lea 	_GemParB+INTIN,a0
 move.w	d0,(a0)+
 move.w	d1,(a0)+
 move.w	d2,(a0)+
 move.l	$c(sp),(a0)+
 move.w	$10(sp),(a0)
 move.l	#$82060600,d0
 bsr 	__aes
 movea.l	(sp)+,a1
 move.w	(a0)+,(a1)			; *cx = intout[1]
 movea.l	(sp)+,a1
 move.w	(a0)+,(a1)			; *cy = intout[2]
 movea.l	$a(sp),a1
 move.w	(a0)+,(a1)			; *cnt = intout[3]
 movea.l	$e(sp),a1
 move.w	(a0)+,(a1)			; *xstep = intout[4]
 movea.l	$12(sp),a1
 move.w	(a0),(a1)				; *ystep = intout[5]
 rts


**********************************************************************
*
* int xgrf_2box( d0 = int startx, d1 = int starty,
*			  d2 = int startw, int starth,
*			  int corners, int cnt, int xstep, int ystep, int doubled )
*

xgrf_2box:
 lea 	_GemParB+INTIN,a0
 lea		8(sp),a1
 move.l	(a1)+,(a0)+			; intin[0] = cnt
							; intin[1] = xstep
 move.w	(a1)+,(a0)+			; intin[2] = ystep
 move.w	6(sp),(a0)+			; intin[3] = corners
 move.w	(a1),(a0)+			; intin[4] = doubled
 move.w	d0,(a0)+				; intin[5] = startx
 move.w	d1,(a0)+				; intin[6] = starty
 move.w	d2,(a0)+				; intin[7] = startw
 move.w	4(sp),(a0)			; intin[8] = starth
 move.l	#$83090100,d0
 bra 	__aes


	   END

