* Bibliotheksmodul zur Erg„nzung von TCGEMLIB.LIB, das die AES- Funktionen
* von GEM/3, KAOS 1.4 und MAGIX enth„lt


	INCLUDE	"MAGILIB.INC"


	   XDEF	__aes


	   TEXT

**********************************************************************
*
* AES Handler
*

__aes:
 lea 	_GemParB+CONTRL,a0
 clr.l	(a0)
 clr.l	4(a0)
 movep	d0,5(a0)
 swap	d0
 movep	d0,1(a0)
 move.w	#$c8,d0
 move.l	#aespb,d1
 trap	#2
 lea 	_GemParB+INTOUT,a0
 move.w	(a0)+,d0
 rts

aespb:
 DC.L	_GemParB+CONTRL
 DC.L	_GemParB+GLOBAL
 DC.L	_GemParB+INTIN
 DC.L	_GemParB+INTOUT
 DC.L	_GemParB+ADDRIN
 DC.L	_GemParB+ADDROUT

	   END

