* NOFAST
* ======
*
* Meldet das FastRAM ab
*

     INCLUDE "OSBIND.INC"

 clr.l    -(sp)
 gemdos   Super
 clr.l    fstrm_top
 gemdos   Pterm0
