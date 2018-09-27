_p_cookies EQU $5a0


 move.l	#'huhu',d0
 move.l	#'hihi',d1
 bsr.b	putcookie
 illegal
 

**********************************************************************
*
* EQ/NE d0 = long putcookie( d0 = long key, d1 = long val )
*
* RÅckgabe:         d0 = 0    Cookie geÑndert
*				d0 = 1	Cookie installiert
*                   d0 = -1	Cookie Jar voll
*

putcookie:
 move.l	_p_cookies.w,d2		; Zeiger auf die Cookies
 beq.b    pco_err				; keine Cookies?
 movea.l  d2,a0
pco_loop:
 move.l	(a0)+,d2				; Cookie-ID
 beq.b	pco_endloop			; Tabellenende
 cmp.l	d0,d2				; gefunden?
 beq.b	pco_found
 addq.l	#4,a0				; Daten Åberspringen
 bra.b	pco_loop
pco_found:
 move.l	d1,(a0)				; Cookie geÑndert
 moveq	#0,d0
 rts
pco_endloop:
 move.l	a0,d2
 addq.l	#4,d2				; Hinter den Leercookie
 sub.l	_p_cookies,d2			; -Anfang der Cookies
 lsr.l	#3,d2				; 8 Bytes pro Cookie
 cmp.l	(a0),d2				; Platz im Cookie
 bcc.b	pco_err
 move.l	d0,-4(a0)				; neuer Wert statt Null
 move.l	(a0),8(a0)
 move.l	d1,(a0)+
 clr.l	(a0)
 moveq	#1,d0
 rts
pco_err:
 moveq    #-1,d0
 rts

