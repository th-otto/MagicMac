* Bibliotheksmodul fÅr MAGIX.LIB


	INCLUDE	"MAGILIB.INC"

	   XREF	__aes


	   XDEF	form_xdo				; (MAGIX)
	   XDEF	form_xdial			; (MAGIX)
	   XDEF	form_popup			; MAGIX
	   XDEF	form_xerr				; MAGIX



**********************************************************************
*
* int form_xdo( a0 = OBJECT *tree, d0 = int startob,
*			 a1 = int *lastcrsr,
*			 SCANX *scantab[2], void *flydial )
*

form_xdo:
 move.l	a1,-(sp)
 move.w	d0,_GemParB+INTIN		; intin[0] = startob
 lea		_GemParB+ADDRIN,a1
 move.l	a0,(a1)+				; addrin[0] = tree
 move.l	8(sp),(a1)+			; addrin[1] = scantab
 move.l	12(sp),(a1)			; addrin[2] = flydial
 move.l	#$32010203,d0
 bsr		__aes
 move.l	(sp)+,a1
 move.w	(a0),(a1)				; *lastcrsr = intout[1]
 rts


**********************************************************************
*
* int form_xdial( d0 = int flag,
*			   d1 = int lx, d2 = int ly, int lw, int lh,
*			   int bx, int by, int bw, int bh,
*			   a0 = void **flydial )
*

form_xdial:
 move.l	a0,_GemParB+ADDRIN		; addrin[0] = flydial
 clr.l	_GemParB+ADDRIN+4		; addrin[1] = NULL
 lea		_GemParB+INTIN,a0
 move.w	d0,(a0)+				; intin[0] = flag
 move.w	d1,(a0)+				; intin[1] = lx
 move.w	d2,(a0)+				; intin[2] = ly
 lea		4(sp),a1
 move.l	(a1)+,(a0)+			; intin[3] = lw
							; intin[4] = lh
 move.l	(a1)+,(a0)+			; intin[5] = bx
							; intin[6] = by
 move.l	(a1),(a0)				; intin[7] = bw
							; intin[8] = bh
 move.l	#$33090102,d0
 bra		__aes


**********************************************************************
*
* int form_popup( a0 = OBJECT *tree, d0 = int x, d1 = int y )
*

form_popup:
 move.l	a0,_GemParB+ADDRIN
 lea 	_GemParB+INTIN,a0
 move.w	d0,(a0)+				; intin[0] = x
 move.w	d1,(a0)				; intin[1] = y
 move.l	#$87020101,d0
 bra 	__aes


**********************************************************************
*
* int form_xerr( d0 = long errcode, a0 = char *errfile )
*

form_xerr:
 move.l	d0,_GemParB+INTIN
 move.l	a0,_GemParB+ADDRIN
 move.l	#$88020101,d0
 bra		__aes

	   END

