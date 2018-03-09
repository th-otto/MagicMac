* GEMDOS¿ Disassembler, ½ 22.12.88 Andreas Kromke

* Datei:  U.O


* TEXT :   $000060
* DATA :   $000000
* BSS  :   $000000



        TEXT

 ploadr   dfc,(a0)            ;000000=f0102201
 ploadw   dfc,(a0)            ;000004=f0102001
 ploadw   sfc,(a0)            ;000008=f0102000
 ploadw   d0,(a0)             ;00000C=f0102008
 ploadw   d7,(a0)             ;000010=f010200f
 ploadw   #7,(a0)             ;000014=f0102017
 ploadw   #7,(sp)             ;000018=f0172017
 ploadw   #7,$f(sp)           ;00001C=f02f2017000f
 pflush   dfc,#0              ;000022=f0003001
 pflush   dfc,#7              ;000026=f00030e1
 pflush   dfc,#$f             ;00002A=f00031e1
 bra.b    lbl1                ;00002E=6030
 pflush   sfc,#7              ;000030=f00030e0
 bra.b    lbl1                ;000034=602a
 pflush   d0,#7               ;000036=f00030e8
 bra.b    lbl1                ;00003A=6024
 pflush   d7,#7               ;00003C=f00030ef
 bra.b    lbl1                ;000040=601e
 pflush   #0,#7               ;000042=f00030f0
 pflush   #7,#7               ;000046=f00030f7
 bra.b    lbl1                ;00004A=6014
 DC.W     $f028               ;00004C='ð(8÷'
 DC.W     8                   ;000050='..'
 bra.b    lbl1                ;000052=600c
 DC.W     $f02f               ;000054='ð/8÷'
 DC.W     8                   ;000058='..'
 bra.b    lbl1                ;00005A=6004
 DC.W     $f017               ;00005C='ð.8÷'

        END


* set label $60
