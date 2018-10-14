* NOFAST
* ======
*
* Meldet das FastRAM ab
*

     INCLUDE "osbind.inc"

 clr.l    -(sp)
 gemdos   Super
 clr.l    fstrm_top
 gemdos   Pterm0
