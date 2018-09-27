* Bibliotheksmodul fÅr MAGIX.LIB

	INCLUDE	"MAGILIB.INC"

	   XREF	__aes


	   XDEF	menu_unregister		; GEM 2.x
	   XDEF	menu_click			; GEM/3



**********************************************************************
*
* int menu_unregister ( d0 = int menu_id )
*

menu_unregister:
 move.w	d0,_GemParB+INTIN
 move.l	#$24010100,d0
 bra 	__aes


**********************************************************************
*
* int menu_click( d0 = int val, d1 = int setit )
*

menu_click:
 lea		_GemParB+INTIN,a0
 move.w	d0,(a0)+
 move.w	d1,(a0)
 move.l	#$25020100,d0
 bra		__aes

	   END

