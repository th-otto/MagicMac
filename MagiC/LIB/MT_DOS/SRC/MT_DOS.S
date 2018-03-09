/*
*
* MT-sicheres Binding fÅr GEMDOS-Aufrufe, die in der
* PCTOSLIB von PureC fehlen.
*
* Andreas Kromke
* 18.7.98
*
* Tabulatorweite: 5
*
* 15.1.2000:	Tmalarm() hinzugefÅgt
*
*/

	EXPORT	Slbopen
	EXPORT	Slbclose
	EXPORT	Dxreaddir
	EXPORT	Dreadlabel
	EXPORT	Dwritelabel
	EXPORT	Tmalarm

/*****************************************************************
*
* Funktion 0x16 (22)
*
* LONG Slbopen(
*			a0 = char *name,
*			a1 = char *path,
*			d0 = LONG min_ver,
*			SHARED_LIB *sl,
*			SLB_EXEC *fn,
*			d1 = LONG param
*			);
*
*****************************************************************/

	MODULE Slbopen
 move.l	d1,-(sp)			; param
 move.l	8+4(sp),-(sp)		; fn
 move.l	4+8(sp),-(sp)		; sl
 move.l	d0,-(sp)			; min_ver
 move.l	a1,-(sp)			; path
 move.l	a0,-(sp)			; name
 move.w	#$16,-(sp)
 trap	#1				; gemdos Slbopen
 lea		26(sp),sp
 rts
	ENDMOD


/*****************************************************************
*
* Funktion 0x17 (23)
*
* LONG Slbclose( a0 = SHARED_LIB *sl );
*
*****************************************************************/

	MODULE Slbclose
 move.l	a0,-(sp)			; sl
 move.w	#$17,-(sp)
 trap	#1				; gemdos Slbclose
 addq.l	#6,sp
 rts
	ENDMOD


/*****************************************************************
*
* Funktion 0x13d (317)
*
* LONG Tmalarm( d0 = LONG millisecs );
*
*****************************************************************/

	MODULE Tmalarm
 move.l	d0,-(sp)			; millisecs
 move.w	#$13d,-(sp)
 trap	#1				; gemdos Tmalarm
 addq.l	#6,sp
 rts
	ENDMOD


/*****************************************************************
*
* Funktion 0x142 (322)
*
* LONG Dxreaddir(
*			d0 = WORD len,
*			d1 = LONG dirhandle,
*			a0 = char *buf,
*			a1 = XATTR *xattr,
*			LONG *xr
*			);
*
*****************************************************************/

	MODULE Dxreaddir
 move.l	4(sp),-(sp)		; xr
 move.l	a1,-(sp)			; xattr
 move.l	a0,-(sp)			; buf
 move.l	d1,-(sp)			; dirhandle
 move.w	d0,-(sp)			; len
 move.w	#$142,-(sp)
 trap	#1				; gemdos Dxreaddir
 lea		20(sp),sp
 rts
	ENDMOD


/******************************************************************
*
* Funktion 0x152 (338)
*
* LONG Dreadlabel(
*			a0 = char *path,
*			a1 = char *buf,
*			d0 = WORD len
*			);
*
******************************************************************/

	MODULE Dreadlabel
 move.w	d0,-(sp)			; len
 move.l	a1,-(sp)			; buf
 move.l	a0,-(sp)			; path
 move.w	#$152,-(sp)
 trap	#1				; gemdos Dreadlabel
 lea		12(sp),sp
 rts
	ENDMOD


/******************************************************************
*
* Funktion 0x153 (339)
*
* LONG Dwritelabel(
*			a0 = char *path,
*			a1 = char *name
*			);
*
******************************************************************/

	MODULE Dwritelabel
 move.l	a1,-(sp)			; buf
 move.l	a0,-(sp)			; path
 move.w	#$153,-(sp)
 trap	#1				; gemdos Dwritelabel
 lea		10(sp),sp
 rts
	ENDMOD
