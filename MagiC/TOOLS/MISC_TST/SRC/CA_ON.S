; Soll eigentlich Daten und Befehlscache des 68040
; abschalten (damit der PureDebugger l„uft)
; Scheint aber nicht zu funktionieren

	MC68040
	SUPER

 pea		cache(pc)
 move.w	#38,-(sp)
 trap	#14
 addq.l	#6,sp
 clr.w	-(sp)
 trap	#1

cache:
 movec	cacr,d0
 bset	#31,d0
 bset	#15,d0
 bset	#8,d0
 movec	d0,cacr
 rts
