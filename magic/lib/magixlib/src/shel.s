* Bibliotheksmodul fÅr MAGIX.LIB


	INCLUDE	"MAGILIB.INC"

	   XREF	__aes


	   XDEF	appl_bvset			; GEM 2.x
	   XDEF	shel_rdef				; GEM 2.x
	   XDEF	shel_wdef				; GEM 2.x



**********************************************************************
*
* int appl_bvset( d0 = int dsk, d1 = int hrd )
*

appl_bvset:
 lea 	_GemParB+INTIN,a0
 move.w	d0,(a0)+
 move.w	d1,(a0)
 move.l	#$10020100,d0
 bra 	__aes


**********************************************************************
*
* int shel_rdef( a0 = char *fname, a1 = char *dir )
*

shel_rdef:
 move.l	#$7e000102,d0
__shel_xdef:
 move.l	a0,_GemParB+ADDRIN
 move.l	a1,_GemParB+ADDRIN+4
 bra 	__aes


**********************************************************************
*
* int shel_wdef( a0 = char *fname, a1 = char *dir )
*

shel_wdef:
 move.l	#$7f000002,d0
 bra 	__shel_xdef

	   END

