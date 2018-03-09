* GEMDOS¿ Disassembler, ½ 22.12.88 Andreas Kromke

* Datei:  T.PRG


* TEXT :   $000116
* DATA :   $000000
* BSS  :   $000000


        TEXT

 cmp2.w   4(a0),d1            ;000000=02e810000004
 cmp2.w   4(a0),a2            ;000006=02e8a0000004
 bra      lblF8               ;00000C=600000ea
 chk2.w   4(a0),d1            ;000010=02e818000004
 chk2.w   4(a0),a2            ;000016=02e8a8000004
 bra      lblFA               ;00001C=600000dc
 cas.w    d3,d4,5(a0)         ;000020=0ce801030005
 cas2.w   d1:d2,d3:d4,(a6):(d5) ;000026=0cfce0c15102
 bra      lblFC               ;00002C=600000ce
 moves.w  d6,5(a0)            ;000030=0e6868000005
 moves.w  7(a4),sp            ;000036=0e6cf0000007
 bra      lblFE               ;00003C=600000c0
 chk.l    7(a5),d5            ;000040=4b2d0007
 bra      lbl100              ;000044=600000ba
 move     ccr,d7              ;000048=42c7
 bra      lbl102              ;00004A=600000b6
 link.l   a0,#$12345678       ;00004E=480812345678
 bra      lbl104              ;000054=600000ae
 bkpt     #5                  ;000058=484d
 bra      lbl106              ;00005A=600000aa
 extb.l   d7                  ;00005E=49c7
 bra      lbl108              ;000060=600000a6
 muls.l   5(a4),d5            ;000064=4c2c58000005
 mulu.l   5(a4),d5:d6         ;00006A=4c2c64050005
 bra      lbl10A              ;000070=60000098
 divu.l   4(a4),d3            ;000074=4c6c30030004
 divu.l   4(a4),d4:d7         ;00007A=4c6c74040004
 divul.l  4(a4),d4:d7         ;000080=4c6c70040004
 bra      lbl10C              ;000086=60000084
 rtd      #5                  ;00008A=4e740005
 movec    cacr,d7             ;00008E=4e7a7002
 movec    d7,cacr             ;000092=4e7b7002
 movec    d7,vbr              ;000096=4e7b7801
 bra.b    lbl10E              ;00009A=6072
 trapne                       ;00009C=56fc
 trapeq.w #6                  ;00009E=57fa0006
 trapcs.l #6                  ;0000A2=55fb00000006
 bra.l    lbl110              ;0000A8=60ff00000066
 pack     -(a4),-(a5),#$12    ;0000AE=8b4c0012
 pack     d4,d5,#$12          ;0000B2=8b440012
 unpk     -(a4),-(a5),#$12    ;0000B6=8b8c0012
 unpk     d4,d5,#$12          ;0000BA=8b840012
 bra.b    lbl112              ;0000BE=6052
 bfchg    $12{7:8}            ;0000C0=eaf801c80012
 bfchg    $12{d7:d2}          ;0000C6=eaf809e20012
 bfclr    $12{d7:d2}          ;0000CC=ecf809e20012
 bfexts   $12{d7:d2},d6       ;0000D2=ebf869e20012
 bfextu   $12{d7:d2},d6       ;0000D8=e9f869e20012
 bfffo    $12{d7:d2},d6       ;0000DE=edf869e20012
 bfins    d5,$12{d7:d2}       ;0000E4=eff859e20012
 bfset    $12{d7:d2}          ;0000EA=eef809e20012
 bftst    $12{d7:d2}          ;0000F0=e8f809e20012
 bra.b    lbl114              ;0000F6=601c
lblF8:
 nop                          ;0000F8=4e71
lblFA:
 nop                          ;0000FA=4e71
lblFC:
 nop                          ;0000FC=4e71
lblFE:
 nop                          ;0000FE=4e71
lbl100:
 nop                          ;000100=4e71
lbl102:
 nop                          ;000102=4e71
lbl104:
 nop                          ;000104=4e71
lbl106:
 nop                          ;000106=4e71
lbl108:
 nop                          ;000108=4e71
lbl10A:
 nop                          ;00010A=4e71
lbl10C:
 nop                          ;00010C=4e71
lbl10E:
 nop                          ;00010E=4e71
lbl110:
 nop                          ;000110=4e71
lbl112:
 nop                          ;000112=4e71
lbl114:
 nop                          ;000114=4e71

        END

