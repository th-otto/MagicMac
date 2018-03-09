; Schaltet Daten und Befehlscache des 68040
; ab und startet den PureDebugger mit der
; Åbergebenen Kommandozeile.
; Schaltet anschlieûend den Cache wieder ein.

	MC68040
	SUPER

	INCLUDE "INC\OSBIND.INC"

; Mshrink()
 movea.l  4(sp),a6				; a6 = Basepage
 lea      stack(pc),sp
 movea.w  #$100,a0                 ; ProgrammlÑnge + $100
 adda.l   $c(a6),a0
 adda.l   $14(a6),a0
 adda.l   $1c(a6),a0
 move.l   a0,-(sp)				; len
 move.l   a6,-(sp)				; block
 clr.w    -(sp)
 gemdos   Mshrink
 adda.w   #$c,sp
 tst.l    d0                       ; KAOS liefert Fehlermeldung bei Mshrink()
 bmi      exit

; Cache aus
 pea		cache_off(pc)
 xbios	Supexec
 addq.l	#6,sp

; PureDebugger starten

 clr.l	-(sp)				; Environment vererben
 pea		128(a6)				; cmdline
 pea		path(pc)
 clr.w	-(sp)				; load&go
 gemdos	Pexec
 adda.w	#16,sp
 move.w	d0,-(sp)				; RÅckgabewert retten

; Cache ein
 pea		cache_on(pc)
 xbios	Supexec
 addq.l	#6,sp

; Pterm()
exit:
 gemdos	Pterm

cache_off:
 DC.W	$f4f8				; cpusha (alle Caches lîschen)
 movec	cacr,d0
 bclr	#31,d0
 bclr	#15,d0
 bclr	#8,d0
 movec	d0,cacr
 rts

cache_on:
 movec	cacr,d0
 bset	#31,d0
 bset	#15,d0
 bset	#8,d0
 movec	d0,cacr
 rts

path:
 DC.B	"C:\PC\PD_ORI.PRG",0
 EVEN

 DS.W     500
stack:
 END
