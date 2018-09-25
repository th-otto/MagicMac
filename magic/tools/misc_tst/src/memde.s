 INCLUDE "OSBIND.INC"

 movea.l  4(sp),a1
 lea      stack(pc),sp
 movea.w  #$100,a0                 ; Programml„nge + $100
 adda.l   $c(a1),a0
 adda.l   $14(a1),a0
 adda.l   $1c(a1),a0
 move.l   a0,-(sp)
 move.l   a1,-(sp)
 clr.w    -(sp)
 gemdos   Mshrink
 adda.w   #$c,sp
 tst.l    d0                       ; KAOS liefert Fehlermeldung bei Mshrink()
 bmi      exit

 move.l   #100,-(sp)
 gemdos   Malloc
 addq.l   #6,sp
 tst.l    d0
 ble.b    exit

 move.l   d0,a0
 lea      100(a0),a0
 clr.l    (a0)+
 clr.l    (a0)+
 clr.l    (a0)+
 clr.l    (a0)+
 clr.l    (a0)+

 move.l   d0,-(sp)
 gemdos   Mfree
 addq.l   #6,sp
exit:
 gemdos   Pterm0

 DS.W     500
stack:
 END