* NOFAST
* ======
*
* Meldet das FastRAM ab
*

     INCLUDE "osbind.inc"

 clr.l    -(sp)
 gemdos   Super
 clr.l    ramtop
 gemdos   Pterm0
