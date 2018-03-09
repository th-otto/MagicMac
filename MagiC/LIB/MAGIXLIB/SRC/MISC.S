* Bibliotheksmodul fÅr MAGIX.LIB

	INCLUDE	"MAGILIB.INC"

	   XREF	__aes


	   XDEF	scrp_clear			; GEM 2.x
	   XDEF	graf_xhandle			; KAOS 1.4

 IFNE	TOS14
	   XDEF	wind_new				; TOS 1.4
	   XDEF	fsel_exinput			; TOS 1.4
 ENDIF



**********************************************************************
*
* int scrp_clear( void )
*

scrp_clear:
 move.l	#$52000100,d0
 bra 	__aes


 IFNE	TOS14
**********************************************************************
*
* int wind_new( void )
*

wind_new:
 move.l	#$6d000000,d0
 bra 	__aes


**********************************************************************
*
* int fsel_exinput( a0 = char *path, a1 = char *fname,
*				int *but, char *title )
*

fsel_exinput:
 move.l	a0,-(sp)				; path
 lea 	_GemParB+ADDRIN,a0
 move.l	(sp)+,(a0)+			; addrin[0] = path
 move.l	a1,(a0)+				; addrin[1] = fname
 move.l	8(sp),(a0)			; addrin[2] = title
 move.l	#$5b000203,d0
 bsr 	__aes
 movea.l	4(sp),a1				; but
 move.w	(a0),(a1) 			; *but = intout[1]
 rts

 ENDIF


**********************************************************************
*
* int graf_xhandle( a0 = int *wchar, a1 = int *hchar,
*				int *wbox, int *hbox, int *device )
*

graf_xhandle:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	#$4d000600,d0
 bsr		__aes
 move.l	(sp)+,a1
 move.w	(a0)+,(a1)			; *wchar  = intout[1]
 move.l	(sp)+,a1
 move.w	(a0)+,(a1)			; *hchar  = intout[2]
 move.l	4(sp),a1
 move.w	(a0)+,(a1)			; *wbox   = intout[3]
 move.l	8(sp),a1
 move.w	(a0)+,(a1)			; *hbox   = intout[4]
 move.l	12(sp),a1
 move.w	(a0),(a1)				; *device = intout[5]
 rts


	   END

