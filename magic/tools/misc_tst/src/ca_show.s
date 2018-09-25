; Zeigt das cacr des 68040

	MC68040
	SUPER

	INCLUDE "INC\OSBIND.INC"

 pea		cache(pc)
 xbios	Supexec
 addq.l	#6,sp

 move.l	d0,d7			; cacr merken
 moveq	#8-1,d6			; Schleifenz„hler
loop:
 rol.l	#4,d7			; obere 4 Bit ganz nach unten
 move.b	d7,d0
 andi.w	#$0f,d0			; untere 4 Bit
 bsr		wr4
 dbra	d6,loop

 gemdos	Pterm0

cache:
 movec	cacr,d0
 rts

* zeigt die unteren 4 Bit von d0 als HEX an

wr4:
 addi.b	#'0',d0			; umrechnen auf Zeichen
 cmpi.b	#'9',d0
 bls.b	weiter1
 addi.b	#'A'-'0',d0
weiter1:
 move.w	d0,-(sp)
 gemdos	Cconout
 addq.l	#4,sp
 rts
