; ph_branch = 0x601a
; ph_tlen = 0x00002676
; ph_dlen = 0x00000014
; ph_blen = 0x00001d84
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000097

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0410                 cmpiw.l   #$0410,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 0088                 ori.b     #$88,d1
[00010018] 0001 063a                 ori.b     #$3A,d1
[0001001c] 0001 0702                 ori.b     #$02,d1
[00010020] 0001 008a                 ori.b     #$8A,d1
[00010024] 0001 00ca                 ori.b     #$CA,d1
[00010028] 0001 0118                 ori.b     #$18,d1
[0001002c] 0000 0000                 ori.b     #$00,d0
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0000 8000                 ori.b     #$00,d0
[00010044] 0010 0002                 ori.b     #$02,(a0)
[00010048] 0081 0000 0000            ori.l     #$00000000,d1
[0001004e] 0000 4e75                 ori.b     #$75,d0
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 268c            move.l    a0,$0001268C
[0001005c] 6100 053a                 bsr       $00010598
[00010060] 207a 262a                 movea.l   $0001268C(pc),a0
[00010064] 4279 0001 268a            clr.w     $0001268A
[0001006a] 6100 0122                 bsr       $0001018E
[0001006e] 6100 00fe                 bsr       $0001016E
[00010072] 7005                      moveq.l   #5,d0
[00010074] 7205                      moveq.l   #5,d1
[00010076] 7405                      moveq.l   #5,d2
[00010078] 6100 0544                 bsr       $000105BE
[0001007c] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010080] 203c 0000 0658            move.l    #$00000658,d0
[00010086] 4e75                      rts
[00010088] 4e75                      rts
[0001008a] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[0001008e] 20ee 0010                 move.l    16(a6),(a0)+
[00010092] 4258                      clr.w     (a0)+
[00010094] 20ee 000c                 move.l    12(a6),(a0)+
[00010098] 7027                      moveq.l   #39,d0
[0001009a] 247a 25f0                 movea.l   $0001268C(pc),a2
[0001009e] 246a 002c                 movea.l   44(a2),a2
[000100a2] 45ea 000a                 lea.l     10(a2),a2
[000100a6] 30da                      move.w    (a2)+,(a0)+
[000100a8] 51c8 fffc                 dbf       d0,$000100A6
[000100ac] 317c 0100 ffc0            move.w    #$0100,-64(a0)
[000100b2] 317c 0001 ffec            move.w    #$0001,-20(a0)
[000100b8] 4268 fff4                 clr.w     -12(a0)
[000100bc] 700b                      moveq.l   #11,d0
[000100be] 32da                      move.w    (a2)+,(a1)+
[000100c0] 51c8 fffc                 dbf       d0,$000100BE
[000100c4] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100c8] 4e75                      rts
[000100ca] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[000100ce] 702c                      moveq.l   #44,d0
[000100d0] 247a 25ba                 movea.l   $0001268C(pc),a2
[000100d4] 246a 0030                 movea.l   48(a2),a2
[000100d8] 30da                      move.w    (a2)+,(a0)+
[000100da] 51c8 fffc                 dbf       d0,$000100D8
[000100de] 4268 ffa6                 clr.w     -90(a0)
[000100e2] 4268 ffa8                 clr.w     -88(a0)
[000100e6] 317c 0010 ffae            move.w    #$0010,-82(a0)
[000100ec] 317c 0001 ffb0            move.w    #$0001,-80(a0)
[000100f2] 317c 0898 ffb2            move.w    #$0898,-78(a0)
[000100f8] 317c 0001 ffcc            move.w    #$0001,-52(a0)
[000100fe] 700b                      moveq.l   #11,d0
[00010100] 32da                      move.w    (a2)+,(a1)+
[00010102] 51c8 fffc                 dbf       d0,$00010100
[00010106] 45ee 0034                 lea.l     52(a6),a2
[0001010a] 235a ffe8                 move.l    (a2)+,-24(a1)
[0001010e] 235a ffec                 move.l    (a2)+,-20(a1)
[00010112] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010116] 4e75                      rts
[00010118] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[0001011c] 43fa 009a                 lea.l     $000101B8(pc),a1
[00010120] 30d9                      move.w    (a1)+,(a0)+
[00010122] 30d9                      move.w    (a1)+,(a0)+
[00010124] 30d9                      move.w    (a1)+,(a0)+
[00010126] 20d9                      move.l    (a1)+,(a0)+
[00010128] 30ee 01b2                 move.w    434(a6),(a0)+
[0001012c] 20ee 01ae                 move.l    430(a6),(a0)+
[00010130] 5c89                      addq.l    #6,a1
[00010132] 30d9                      move.w    (a1)+,(a0)+
[00010134] 30d9                      move.w    (a1)+,(a0)+
[00010136] 30d9                      move.w    (a1)+,(a0)+
[00010138] 30d9                      move.w    (a1)+,(a0)+
[0001013a] 30d9                      move.w    (a1)+,(a0)+
[0001013c] 30d9                      move.w    (a1)+,(a0)+
[0001013e] 30ee 01a2                 move.w    418(a6),(a0)+
[00010142] 30e9 0002                 move.w    2(a1),(a0)+
[00010146] 706f                      moveq.l   #111,d0
[00010148] 43fa 016e                 lea.l     $000102B8(pc),a1
[0001014c] 082e 0007 01a3            btst      #7,419(a6)
[00010152] 6704                      beq.s     $00010158
[00010154] 43fa 0082                 lea.l     $000101D8(pc),a1
[00010158] 30d9                      move.w    (a1)+,(a0)+
[0001015a] 51c8 fffc                 dbf       d0,$00010158
[0001015e] 303c 008f                 move.w    #$008F,d0
[00010162] 4258                      clr.w     (a0)+
[00010164] 51c8 fffc                 dbf       d0,$00010162
[00010168] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[0001016c] 4e75                      rts
[0001016e] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010172] 247a 2518                 movea.l   $0001268C(pc),a2
[00010176] 246a 0028                 movea.l   40(a2),a2
[0001017a] 2052                      movea.l   (a2),a0
[0001017c] 43fa 2512                 lea.l     $00012690(pc),a1
[00010180] 703f                      moveq.l   #63,d0
[00010182] 22d8                      move.l    (a0)+,(a1)+
[00010184] 51c8 fffc                 dbf       d0,$00010182
[00010188] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[0001018c] 4e75                      rts
[0001018e] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[00010192] 41fa 25fc                 lea.l     $00012790(pc),a0
[00010196] 7000                      moveq.l   #0,d0
[00010198] 3200                      move.w    d0,d1
[0001019a] 7407                      moveq.l   #7,d2
[0001019c] 4258                      clr.w     (a0)+
[0001019e] d201                      add.b     d1,d1
[000101a0] 6504                      bcs.s     $000101A6
[000101a2] 4668 fffe                 not.w     -2(a0)
[000101a6] 51ca fff4                 dbf       d2,$0001019C
[000101aa] 5240                      addq.w    #1,d0
[000101ac] b07c 0100                 cmp.w     #$0100,d0
[000101b0] 6de6                      blt.s     $00010198
[000101b2] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[000101b6] 4e75                      rts
[000101b8] 0002 0002                 ori.b     #$02,d2
[000101bc] 0010 0000                 ori.b     #$00,(a0)
[000101c0] 8000                      or.b      d0,d0
[000101c2] 0000 0000                 ori.b     #$00,d0
[000101c6] 0000 0005                 ori.b     #$05,d0
[000101ca] 0005 0005                 ori.b     #$05,d5
[000101ce] 0000 0000                 ori.b     #$00,d0
[000101d2] 0001 0001                 ori.b     #$01,d1
[000101d6] 0000 0002                 ori.b     #$02,d0
[000101da] 0003 0004                 ori.b     #$04,d3
[000101de] 0005 0006                 ori.b     #$06,d5
[000101e2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101ea] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101f2] ffff ffff ffff 000d       vperm     #$FFFF000D,e23,e23,e23
[000101fa] 000e 000f                 ori.b     #$0F,a6 ; apollo only
[000101fe] 0000 0001                 ori.b     #$01,d0
[00010202] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001020a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010212] ffff ffff ffff 0008       vperm     #$FFFF0008,e23,e23,e23
[0001021a] 0009 000a                 ori.b     #$0A,a1 ; apollo only
[0001021e] 000b 000c                 ori.b     #$0C,a3 ; apollo only
[00010222] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001022a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010232] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001023a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010242] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001024a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010252] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001025a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010262] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001026a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010272] ffff ffff ffff 0007       vperm     #$FFFF0007,e23,e23,e23
[0001027a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010282] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001028a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010292] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001029a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102a2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102aa] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102b2] ffff ffff ffff 000a       vperm     #$FFFF000A,e23,e23,e23
[000102ba] 000b 000c                 ori.b     #$0C,a3 ; apollo only
[000102be] 000d 000e                 ori.b     #$0E,a5 ; apollo only
[000102c2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ca] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102d2] ffff ffff ffff 0005       vperm     #$FFFF0005,e23,e23,e23
[000102da] 0006 0007                 ori.b     #$07,d6
[000102de] 0008 0009                 ori.b     #$09,a0 ; apollo only
[000102e2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ea] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102f2] ffff ffff ffff 0000       vperm     #$FFFF0000,e23,e23,e23
[000102fa] 0001 0002                 ori.b     #$02,d1
[000102fe] 0003 0004                 ori.b     #$04,d3
[00010302] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001030a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010312] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001031a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010322] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001032a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010332] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001033a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010342] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001034a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010352] ffff ffff ffff 000f       vperm     #$FFFF000F,e23,e23,e23
[0001035a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010362] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001036a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010372] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001037a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010382] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001038a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010392] ffff ffff ffff 7fff       vperm     #$FFFF7FFF,e23,e23,e23
[0001039a] 7800                      moveq.l   #0,d4
[0001039c] 0380                      bclr      d1,d0
[0001039e] 7fe0                      ???
[000103a0] 001e 70d3                 ori.b     #$D3,(a6)+
[000103a4] 0f37 6f7b 4210 4000 0200  btst      d7,([$42104000,a7,zd6.l*8],$02005A87) ; 68020+ only
[000103ae] 5a87
[000103b0] 0010 4010                 ori.b     #$10,(a0)
[000103b4] 0210 0c63                 andi.b    #$63,(a0)
[000103b8] 0006 000c                 ori.b     #$0C,d6
[000103bc] 0013 0019                 ori.b     #$19,(a3)
[000103c0] 001f 00c0                 ori.b     #$C0,(a7)+
[000103c4] 00c6                      bitrev.l  d6 ; ColdFire isa_c only
[000103c6] 00cc                      dc.w      $00CC ; illegal
[000103c8] 00d3 00d9                 cmp2.b    (a3),d0 ; 68020+ only
[000103cc] 00df                      dc.w      $00DF ; illegal
[000103ce] 0180                      bclr      d0,d0
[000103d0] 0186                      bclr      d0,d6
[000103d2] 018c 0193                 movep.w   d0,403(a4)
[000103d6] 0199                      bclr      d0,(a1)+
[000103d8] 019f                      bclr      d0,(a7)+
[000103da] 0260 0266                 andi.w    #$0266,-(a0)
[000103de] 026c 0273 0279            andi.w    #$0273,633(a4)
[000103e4] 027f 0320                 andi.w    #$0320,???
[000103e8] 0326                      btst      d1,-(a6)
[000103ea] 032c 0333                 btst      d1,819(a4)
[000103ee] 0339 033f 03e0            btst      d1,$033F03E0
[000103f4] 03e6                      bset      d1,-(a6)
[000103f6] 03ec 03f3                 bset      d1,1011(a4)
[000103fa] 03f9 03ff 1800            bset      d1,$03FF1800
[00010400] 1806                      move.b    d6,d4
[00010402] 180c                      move.l    b4,d4 ; apollo only
[00010404] 1813                      move.b    (a3),d4
[00010406] 1819                      move.b    (a1)+,d4
[00010408] 181f                      move.b    (a7)+,d4
[0001040a] 18c0                      move.b    d0,(a4)+
[0001040c] 18c6                      move.b    d6,(a4)+
[0001040e] 18cc                      move.l    b4,(a4)+ ; apollo only
[00010410] 0018 18d9                 ori.b     #$D9,(a0)+
[00010414] 18df                      move.b    (a7)+,(a4)+
[00010416] 1980 1986 198c            move.b    d0,([za4],d1.l,$198C) ; 68020+ only; reserved BD=0
[0001041c] 1993 1999                 move.b    (a3),([za4,d1.l]) ; 68020+ only
[00010420] 199f 1a60                 move.b    (a7)+,96(a4,d1.l*2) ; 68020+ only
[00010424] 1a66                      movea.l   -(a6),b5 ; apollo only
[00010426] 1a6c 1a73                 movea.l   6771(a4),b5 ; apollo only
[0001042a] 1a79 1a7f 1b20            movea.l   $1A7F1B20,b5 ; apollo only
[00010430] 1b26                      move.b    -(a6),-(a5)
[00010432] 1b2c 1b33                 move.b    6963(a4),-(a5)
[00010436] 1b39 1b3f 1be0            move.b    $1B3F1BE0,-(a5)
[0001043c] 1be6                      move.b    -(a6),???
[0001043e] 1bec 1bf3                 move.b    7155(a4),???
[00010442] 1bf9 1bff 3000            move.b    $1BFF3000,???
[00010448] 3006                      move.w    d6,d0
[0001044a] 300c                      move.w    a4,d0
[0001044c] 3013                      move.w    (a3),d0
[0001044e] 3019                      move.w    (a1)+,d0
[00010450] 301f                      move.w    (a7)+,d0
[00010452] 30c0                      move.w    d0,(a0)+
[00010454] 30c6                      move.w    d6,(a0)+
[00010456] 30cc                      move.w    a4,(a0)+
[00010458] 30d3                      move.w    (a3),(a0)+
[0001045a] 30d9                      move.w    (a1)+,(a0)+
[0001045c] 30df                      move.w    (a7)+,(a0)+
[0001045e] 3180 3186 318c            move.w    d0,([],d3.w,$318C) ; 68020+ only; reserved BD=0
[00010464] 3193 3199                 move.w    (a3),([d3.w]) ; 68020+ only
[00010468] 319f 3260                 move.w    (a7)+,96(a0,d3.w*2) ; 68020+ only
[0001046c] 3266                      movea.w   -(a6),a1
[0001046e] 326c 3273                 movea.w   12915(a4),a1
[00010472] 3279 327f 3320            movea.w   $327F3320,a1
[00010478] 3326                      move.w    -(a6),-(a1)
[0001047a] 332c 3333                 move.w    13107(a4),-(a1)
[0001047e] 3339 333f 33e0            move.w    $333F33E0,-(a1)
[00010484] 33e6 33ec 33f3            move.w    -(a6),$33EC33F3
[0001048a] 33f9 33ff 4c00 4c06 4c0c  move.w    $33FF4C00,$4C064C0C
[00010494] 4c13 4c19                 muls.l    (a3),a1:d4 ; apollo only
[00010498] 4c1f 4cc0                 muls.l    (a7)+,d0:d4 ; 68020+ only
[0001049c] 4cc6 4ccc                 perm      #$0CCC,d6,d4 ; apollo only
[000104a0] 4cd3 4cd9                 movem.l   (a3),d0/d3-d4/d6-d7/a2-a3/a6
[000104a4] 4cdf 4d80                 movem.l   (a7)+,d7/a0/a2-a3/a6
[000104a8] 4d86                      chk.w     d6,d6
[000104aa] 4d8c                      chk.w     a4,d6
[000104ac] 4d93                      chk.w     (a3),d6
[000104ae] 4d99                      chk.w     (a1)+,d6
[000104b0] 4d9f                      chk.w     (a7)+,d6
[000104b2] 4e60                      move.l    a0,usp
[000104b4] 4e66                      move.l    a6,usp
[000104b6] 4e6c                      move.l    usp,a4
[000104b8] 4e73                      rte
[000104ba] 4e79                      dc.w      $4E79 ; illegal
[000104bc] 4e7f                      dc.w      $4E7F ; illegal
[000104be] 4f20                      chk.l     -(a0),d7 ; 68020+ only
[000104c0] 4f26                      chk.l     -(a6),d7 ; 68020+ only
[000104c2] 4f2c 4f33                 chk.l     20275(a4),d7 ; 68020+ only
[000104c6] 4f39 4f3f 4fe0            chk.l     $4F3F4FE0,d7 ; 68020+ only
[000104cc] 4fe6                      lea.l     -(a6),a7
[000104ce] 4fec 4ff3                 lea.l     20467(a4),a7
[000104d2] 4ff9 4fff 6400            lea.l     $4FFF6400,a7
[000104d8] 6406                      bcc.s     $000104E0
[000104da] 640c                      bcc.s     $000104E8
[000104dc] 6413                      bcc.s     $000104F1
[000104de] 6419                      bcc.s     $000104F9
[000104e0] 641f                      bcc.s     $00010501
[000104e2] 64c0                      bcc.s     $000104A4
[000104e4] 64c6                      bcc.s     $000104AC
[000104e6] 64cc                      bcc.s     $000104B4
[000104e8] 64d3                      bcc.s     $000104BD
[000104ea] 64d9                      bcc.s     $000104C5
[000104ec] 64df                      bcc.s     $000104CD
[000104ee] 6580                      bcs.s     $00010470
[000104f0] 6586                      bcs.s     $00010478
[000104f2] 658c                      bcs.s     $00010480
[000104f4] 6593                      bcs.s     $00010489
[000104f6] 6599                      bcs.s     $00010491
[000104f8] 659f                      bcs.s     $00010499
[000104fa] 6660                      bne.s     $0001055C
[000104fc] 6666                      bne.s     $00010564
[000104fe] 666c                      bne.s     $0001056C
[00010500] 6673                      bne.s     $00010575
[00010502] 6679                      bne.s     $0001057D
[00010504] 667f                      bne.s     $00010585
[00010506] 6720                      beq.s     $00010528
[00010508] 6726                      beq.s     $00010530
[0001050a] 672c                      beq.s     $00010538
[0001050c] 6733                      beq.s     $00010541
[0001050e] 6739                      beq.s     $00010549
[00010510] 673f                      beq.s     $00010551
[00010512] 67e0                      beq.s     $000104F4
[00010514] 67e6                      beq.s     $000104FC
[00010516] 67ec                      beq.s     $00010504
[00010518] 67f3                      beq.s     $0001050D
[0001051a] 67f9                      beq.s     $00010515
[0001051c] 67ff 7c00 7c06            beq.l     $7C018124 ; 68020+ only
[00010522] 7c0c                      moveq.l   #12,d6
[00010524] 7c13                      moveq.l   #19,d6
[00010526] 7c19                      moveq.l   #25,d6
[00010528] 7c1f                      moveq.l   #31,d6
[0001052a] 7cc0                      moveq.l   #-64,d6
[0001052c] 7cc6                      moveq.l   #-58,d6
[0001052e] 7ccc                      moveq.l   #-52,d6
[00010530] 7cd3                      moveq.l   #-45,d6
[00010532] 7cd9                      moveq.l   #-39,d6
[00010534] 7cdf                      moveq.l   #-33,d6
[00010536] 7d80                      ???
[00010538] 7d86                      ???
[0001053a] 7d8c                      ???
[0001053c] 7d93                      ???
[0001053e] 7d99                      ???
[00010540] 7d9f                      ???
[00010542] 7e60                      moveq.l   #96,d7
[00010544] 7e66                      moveq.l   #102,d7
[00010546] 7e6c                      moveq.l   #108,d7
[00010548] 7e73                      moveq.l   #115,d7
[0001054a] 7e79                      moveq.l   #121,d7
[0001054c] 7e7f                      moveq.l   #127,d7
[0001054e] 7f20                      ???
[00010550] 7f26                      ???
[00010552] 7f2c                      ???
[00010554] 7f33                      ???
[00010556] 7f39                      ???
[00010558] 7f3f                      ???
[0001055a] 7fe0                      ???
[0001055c] 7fe6                      ???
[0001055e] 7fec                      ???
[00010560] 7ff3                      ???
[00010562] 7ff9                      ???
[00010564] 7800                      moveq.l   #0,d4
[00010566] 7000                      moveq.l   #0,d0
[00010568] 6000 5800                 bra       $00015D6A
[0001056c] 4000                      negx.b    d0
[0001056e] 2400                      move.l    d0,d2
[00010570] 0c00 03c0                 cmpi.b    #$C0,d0
[00010574] 0380                      bclr      d1,d0
[00010576] 0300                      btst      d1,d0
[00010578] 02c0                      byterev.l d0 ; ColdFire isa_c only
[0001057a] 0200 0120                 andi.b    #$20,d0
[0001057e] 0060 0003                 ori.w     #$0003,-(a0)
[00010582] 0009 0010                 ori.b     #$10,a1 ; apollo only
[00010586] 0016 18d3                 ori.b     #$D3,(a6)
[0001058a] 001c 7bde                 ori.b     #$DE,(a4)+
[0001058e] 739c                      ???
[00010590] 6318                      bls.s     $000105AA
[00010592] 5ad6                      spl       (a6)
[00010594] 2529 0000                 move.l    0(a1),-(a2)
[00010598] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[0001059c] a000                      ALINE     #$0000
[0001059e] 907c 2070                 sub.w     #$2070,d0
[000105a2] 6714                      beq.s     $000105B8
[000105a4] 41fa fa5a                 lea.l     $00010000(pc),a0
[000105a8] 43f9 0001 2676            lea.l     $00012676,a1
[000105ae] 3219                      move.w    (a1)+,d1
[000105b0] 6706                      beq.s     $000105B8
[000105b2] d0c1                      adda.w    d1,a0
[000105b4] d150                      add.w     d0,(a0)
[000105b6] 60f6                      bra.s     $000105AE
[000105b8] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[000105bc] 4e75                      rts
[000105be] 48e7 fec0                 movem.l   d0-d6/a0-a1,-(a7)
[000105c2] 7601                      moveq.l   #1,d3
[000105c4] e16b                      lsl.w     d0,d3
[000105c6] 5343                      subq.w    #1,d3
[000105c8] 3003                      move.w    d3,d0
[000105ca] 7601                      moveq.l   #1,d3
[000105cc] e36b                      lsl.w     d1,d3
[000105ce] 5343                      subq.w    #1,d3
[000105d0] 3203                      move.w    d3,d1
[000105d2] 7601                      moveq.l   #1,d3
[000105d4] e56b                      lsl.w     d2,d3
[000105d6] 5343                      subq.w    #1,d3
[000105d8] 3403                      move.w    d3,d2
[000105da] 48a7 e000                 movem.w   d0-d2,-(a7)
[000105de] 41fa 31b0                 lea.l     $00013790(pc),a0
[000105e2] 7a02                      moveq.l   #2,d5
[000105e4] 7600                      moveq.l   #0,d3
[000105e6] 3803                      move.w    d3,d4
[000105e8] c8c0                      mulu.w    d0,d4
[000105ea] d8bc 0000 01f4            add.l     #$000001F4,d4
[000105f0] 88fc 03e8                 divu.w    #$03E8,d4
[000105f4] 10c4                      move.b    d4,(a0)+
[000105f6] 5243                      addq.w    #1,d3
[000105f8] b67c 03e8                 cmp.w     #$03E8,d3
[000105fc] 6fe8                      ble.s     $000105E6
[000105fe] 3001                      move.w    d1,d0
[00010600] 3202                      move.w    d2,d1
[00010602] 5288                      addq.l    #1,a0
[00010604] 51cd ffde                 dbf       d5,$000105E4
[00010608] 4c9f 0007                 movem.w   (a7)+,d0-d2
[0001060c] 43fa 3d40                 lea.l     $0001434E(pc),a1
[00010610] 7c02                      moveq.l   #2,d6
[00010612] 7600                      moveq.l   #0,d3
[00010614] 3a00                      move.w    d0,d5
[00010616] e24d                      lsr.w     #1,d5
[00010618] 48c5                      ext.l     d5
[0001061a] 3803                      move.w    d3,d4
[0001061c] c8fc 03e8                 mulu.w    #$03E8,d4
[00010620] d885                      add.l     d5,d4
[00010622] 88c0                      divu.w    d0,d4
[00010624] 32c4                      move.w    d4,(a1)+
[00010626] 5243                      addq.w    #1,d3
[00010628] b640                      cmp.w     d0,d3
[0001062a] 6fee                      ble.s     $0001061A
[0001062c] 3001                      move.w    d1,d0
[0001062e] 3202                      move.w    d2,d1
[00010630] 51ce ffe0                 dbf       d6,$00010612
[00010634] 4cdf 037f                 movem.l   (a7)+,d0-d6/a0-a1
[00010638] 4e75                      rts
[0001063a] 48e7 c0e0                 movem.l   d0-d1/a0-a2,-(a7)
[0001063e] 3d7c 000f 01b4            move.w    #$000F,436(a6)
[00010644] 3d7c 00ff 0014            move.w    #$00FF,20(a6)
[0001064a] 2d7c 0001 11f0 01f4       move.l    #$000111F0,500(a6)
[00010652] 2d7c 0001 0b50 01f8       move.l    #$00010B50,504(a6)
[0001065a] 2d7c 0001 0be2 01fc       move.l    #$00010BE2,508(a6)
[00010662] 2d7c 0001 0e08 0200       move.l    #$00010E08,512(a6)
[0001066a] 2d7c 0001 1046 0204       move.l    #$00011046,516(a6)
[00010672] 2d7c 0001 1c22 0208       move.l    #$00011C22,520(a6)
[0001067a] 2d7c 0001 1e5e 020c       move.l    #$00011E5E,524(a6)
[00010682] 2d7c 0001 0b06 0210       move.l    #$00010B06,528(a6)
[0001068a] 2d7c 0001 2612 0214       move.l    #$00012612,532(a6)
[00010692] 2d7c 0001 0abe 021c       move.l    #$00010ABE,540(a6)
[0001069a] 2d7c 0001 0ae2 0218       move.l    #$00010AE2,536(a6)
[000106a2] 2d7c 0001 07ec 0220       move.l    #$000107EC,544(a6)
[000106aa] 2d7c 0001 0776 0224       move.l    #$00010776,548(a6)
[000106b2] 2d7c 0001 0704 0228       move.l    #$00010704,552(a6)
[000106ba] 2d7c 0001 0736 022c       move.l    #$00010736,556(a6)
[000106c2] 2d7c 0001 07da 0230       move.l    #$000107DA,560(a6)
[000106ca] 2d7c 0001 07e8 0234       move.l    #$000107E8,564(a6)
[000106d2] 41fa fcc4                 lea.l     $00010398(pc),a0
[000106d6] 43ee 0458                 lea.l     1112(a6),a1
[000106da] 45fa 1fb4                 lea.l     $00012690(pc),a2
[000106de] 323c 00ff                 move.w    #$00FF,d1
[000106e2] 7000                      moveq.l   #0,d0
[000106e4] 101a                      move.b    (a2)+,d0
[000106e6] d040                      add.w     d0,d0
[000106e8] 3030 0000                 move.w    0(a0,d0.w),d0
[000106ec] 082e 0007 01a3            btst      #7,419(a6)
[000106f2] 6702                      beq.s     $000106F6
[000106f4] e158                      rol.w     #8,d0
[000106f6] 32c0                      move.w    d0,(a1)+
[000106f8] 51c9 ffe8                 dbf       d1,$000106E2
[000106fc] 4cdf 0703                 movem.l   (a7)+,d0-d1/a0-a2
[00010700] 4e75                      rts
[00010702] 4e75                      rts
[00010704] 43ee 0458                 lea.l     1112(a6),a1
[00010708] d643                      add.w     d3,d3
[0001070a] d2c3                      adda.w    d3,a1
[0001070c] 41fa 3082                 lea.l     $00013790(pc),a0
[00010710] 1030 0000                 move.b    0(a0,d0.w),d0
[00010714] eb48                      lsl.w     #5,d0
[00010716] 41e8 03ea                 lea.l     1002(a0),a0
[0001071a] 8030 1000                 or.b      0(a0,d1.w),d0
[0001071e] eb48                      lsl.w     #5,d0
[00010720] 41e8 03ea                 lea.l     1002(a0),a0
[00010724] 8030 2000                 or.b      0(a0,d2.w),d0
[00010728] 082e 0007 01a3            btst      #7,419(a6)
[0001072e] 6702                      beq.s     $00010732
[00010730] e158                      rol.w     #8,d0
[00010732] 3280                      move.w    d0,(a1)
[00010734] 4e75                      rts
[00010736] 43ee 0458                 lea.l     1112(a6),a1
[0001073a] d040                      add.w     d0,d0
[0001073c] 3431 0000                 move.w    0(a1,d0.w),d2
[00010740] 082e 0007 01a3            btst      #7,419(a6)
[00010746] 6702                      beq.s     $0001074A
[00010748] e15a                      rol.w     #8,d2
[0001074a] 43fa 3c02                 lea.l     $0001434E(pc),a1
[0001074e] ef5a                      rol.w     #7,d2
[00010750] 703e                      moveq.l   #62,d0
[00010752] c042                      and.w     d2,d0
[00010754] 3031 0000                 move.w    0(a1,d0.w),d0
[00010758] 43e9 0040                 lea.l     64(a1),a1
[0001075c] eb5a                      rol.w     #5,d2
[0001075e] 723e                      moveq.l   #62,d1
[00010760] c242                      and.w     d2,d1
[00010762] 3231 1000                 move.w    0(a1,d1.w),d1
[00010766] 43e9 0040                 lea.l     64(a1),a1
[0001076a] eb5a                      rol.w     #5,d2
[0001076c] c47c 003e                 and.w     #$003E,d2
[00010770] 3431 2000                 move.w    0(a1,d2.w),d2
[00010774] 4e75                      rts
[00010776] b07c 0010                 cmp.w     #$0010,d0
[0001077a] 6614                      bne.s     $00010790
[0001077c] 22d8                      move.l    (a0)+,(a1)+
[0001077e] 22d8                      move.l    (a0)+,(a1)+
[00010780] 22d8                      move.l    (a0)+,(a1)+
[00010782] 22d8                      move.l    (a0)+,(a1)+
[00010784] 22d8                      move.l    (a0)+,(a1)+
[00010786] 22d8                      move.l    (a0)+,(a1)+
[00010788] 22d8                      move.l    (a0)+,(a1)+
[0001078a] 22d8                      move.l    (a0)+,(a1)+
[0001078c] 7000                      moveq.l   #0,d0
[0001078e] 4e75                      rts
[00010790] 48e7 6000                 movem.l   d1-d2,-(a7)
[00010794] 343c 00ff                 move.w    #$00FF,d2
[00010798] 082e 0007 01a3            btst      #7,419(a6)
[0001079e] 661c                      bne.s     $000107BC
[000107a0] 2018                      move.l    (a0)+,d0
[000107a2] 2200                      move.l    d0,d1
[000107a4] e689                      lsr.l     #3,d1
[000107a6] 3200                      move.w    d0,d1
[000107a8] e689                      lsr.l     #3,d1
[000107aa] 1200                      move.b    d0,d1
[000107ac] e689                      lsr.l     #3,d1
[000107ae] 32c1                      move.w    d1,(a1)+
[000107b0] 51ca ffee                 dbf       d2,$000107A0
[000107b4] 4cdf 0006                 movem.l   (a7)+,d1-d2
[000107b8] 700f                      moveq.l   #15,d0
[000107ba] 4e75                      rts
[000107bc] 2018                      move.l    (a0)+,d0
[000107be] 2200                      move.l    d0,d1
[000107c0] e689                      lsr.l     #3,d1
[000107c2] 3200                      move.w    d0,d1
[000107c4] e689                      lsr.l     #3,d1
[000107c6] 1200                      move.b    d0,d1
[000107c8] e689                      lsr.l     #3,d1
[000107ca] e159                      rol.w     #8,d1
[000107cc] 32c1                      move.w    d1,(a1)+
[000107ce] 51ca ffec                 dbf       d2,$000107BC
[000107d2] 4cdf 0006                 movem.l   (a7)+,d1-d2
[000107d6] 700f                      moveq.l   #15,d0
[000107d8] 4e75                      rts
[000107da] 41ee 0458                 lea.l     1112(a6),a0
[000107de] d040                      add.w     d0,d0
[000107e0] d0c0                      adda.w    d0,a0
[000107e2] 7000                      moveq.l   #0,d0
[000107e4] 3010                      move.w    (a0),d0
[000107e6] 4e75                      rts
[000107e8] 70ff                      moveq.l   #-1,d0
[000107ea] 4e75                      rts
[000107ec] 2f0e                      move.l    a6,-(a7)
[000107ee] 7000                      moveq.l   #0,d0
[000107f0] 3028 000c                 move.w    12(a0),d0
[000107f4] 3228 0006                 move.w    6(a0),d1
[000107f8] c2e8 0008                 mulu.w    8(a0),d1
[000107fc] 7400                      moveq.l   #0,d2
[000107fe] 4a68 000a                 tst.w     10(a0)
[00010802] 6602                      bne.s     $00010806
[00010804] 7401                      moveq.l   #1,d2
[00010806] 3342 000a                 move.w    d2,10(a1)
[0001080a] 2050                      movea.l   (a0),a0
[0001080c] 2251                      movea.l   (a1),a1
[0001080e] 5381                      subq.l    #1,d1
[00010810] 6b4e                      bmi.s     $00010860
[00010812] 5340                      subq.w    #1,d0
[00010814] 6700 0292                 beq       $00010AA8
[00010818] 907c 000f                 sub.w     #$000F,d0
[0001081c] 6642                      bne.s     $00010860
[0001081e] d442                      add.w     d2,d2
[00010820] d442                      add.w     d2,d2
[00010822] 247b 2040                 movea.l   $00010864(pc,d2.w),a2
[00010826] b3c8                      cmpa.l    a0,a1
[00010828] 6630                      bne.s     $0001085A
[0001082a] 2601                      move.l    d1,d3
[0001082c] 5283                      addq.l    #1,d3
[0001082e] eb8b                      lsl.l     #5,d3
[00010830] b6ae 0024                 cmp.l     36(a6),d3
[00010834] 6e1e                      bgt.s     $00010854
[00010836] 2f03                      move.l    d3,-(a7)
[00010838] 2f08                      move.l    a0,-(a7)
[0001083a] 226e 0020                 movea.l   32(a6),a1
[0001083e] 2f09                      move.l    a1,-(a7)
[00010840] 2001                      move.l    d1,d0
[00010842] 5280                      addq.l    #1,d0
[00010844] 4e92                      jsr       (a2)
[00010846] 205f                      movea.l   (a7)+,a0
[00010848] 225f                      movea.l   (a7)+,a1
[0001084a] 221f                      move.l    (a7)+,d1
[0001084c] e289                      lsr.l     #1,d1
[0001084e] 5381                      subq.l    #1,d1
[00010850] 6000 025a                 bra       $00010AAC
[00010854] 247b 2016                 movea.l   $0001086C(pc,d2.w),a2
[00010858] 6004                      bra.s     $0001085E
[0001085a] 2001                      move.l    d1,d0
[0001085c] 5280                      addq.l    #1,d0
[0001085e] 4e92                      jsr       (a2)
[00010860] 2c5f                      movea.l   (a7)+,a6
[00010862] 4e75                      rts
[00010864] 0001 0a2a                 ori.b     #$2A,d1
[00010868] 0001 09b0                 ori.b     #$B0,d1
[0001086c] 0001 0874                 ori.b     #$74,d1
[00010870] 0001 0946                 ori.b     #$46,d1
[00010874] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010878] 2001                      move.l    d1,d0
[0001087a] 780f                      moveq.l   #15,d4
[0001087c] 6100 0102                 bsr       $00010980
[00010880] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[00010884] 2c41                      movea.l   d1,a6
[00010886] 2f08                      move.l    a0,-(a7)
[00010888] 2f28 001c                 move.l    28(a0),-(a7)
[0001088c] 2f28 0018                 move.l    24(a0),-(a7)
[00010890] 2f28 0014                 move.l    20(a0),-(a7)
[00010894] 2f28 0010                 move.l    16(a0),-(a7)
[00010898] 2f09                      move.l    a1,-(a7)
[0001089a] 5289                      addq.l    #1,a1
[0001089c] 6118                      bsr.s     $000108B6
[0001089e] 225f                      movea.l   (a7)+,a1
[000108a0] 204f                      movea.l   a7,a0
[000108a2] 6112                      bsr.s     $000108B6
[000108a4] 4fef 0010                 lea.l     16(a7),a7
[000108a8] 205f                      movea.l   (a7)+,a0
[000108aa] 41e8 0020                 lea.l     32(a0),a0
[000108ae] 220e                      move.l    a6,d1
[000108b0] 5381                      subq.l    #1,d1
[000108b2] 6ad0                      bpl.s     $00010884
[000108b4] 4e75                      rts
[000108b6] 700f                      moveq.l   #15,d0
[000108b8] 4840                      swap      d0
[000108ba] 3e18                      move.w    (a0)+,d7
[000108bc] 3c18                      move.w    (a0)+,d6
[000108be] 3a18                      move.w    (a0)+,d5
[000108c0] 3818                      move.w    (a0)+,d4
[000108c2] 3618                      move.w    (a0)+,d3
[000108c4] 3418                      move.w    (a0)+,d2
[000108c6] 3218                      move.w    (a0)+,d1
[000108c8] 3018                      move.w    (a0)+,d0
[000108ca] 4840                      swap      d0
[000108cc] 4847                      swap      d7
[000108ce] 4840                      swap      d0
[000108d0] d040                      add.w     d0,d0
[000108d2] df07                      addx.b    d7,d7
[000108d4] d241                      add.w     d1,d1
[000108d6] df07                      addx.b    d7,d7
[000108d8] d442                      add.w     d2,d2
[000108da] df07                      addx.b    d7,d7
[000108dc] d643                      add.w     d3,d3
[000108de] df07                      addx.b    d7,d7
[000108e0] d844                      add.w     d4,d4
[000108e2] df07                      addx.b    d7,d7
[000108e4] da45                      add.w     d5,d5
[000108e6] df07                      addx.b    d7,d7
[000108e8] dc46                      add.w     d6,d6
[000108ea] df07                      addx.b    d7,d7
[000108ec] 4847                      swap      d7
[000108ee] de47                      add.w     d7,d7
[000108f0] 4847                      swap      d7
[000108f2] df07                      addx.b    d7,d7
[000108f4] 12c7                      move.b    d7,(a1)+
[000108f6] 5289                      addq.l    #1,a1
[000108f8] 4840                      swap      d0
[000108fa] 51c8 ffd2                 dbf       d0,$000108CE
[000108fe] 4e75                      rts
[00010900] 700f                      moveq.l   #15,d0
[00010902] 4840                      swap      d0
[00010904] 4847                      swap      d7
[00010906] 1e18                      move.b    (a0)+,d7
[00010908] 5288                      addq.l    #1,a0
[0001090a] de07                      add.b     d7,d7
[0001090c] d140                      addx.w    d0,d0
[0001090e] de07                      add.b     d7,d7
[00010910] d341                      addx.w    d1,d1
[00010912] de07                      add.b     d7,d7
[00010914] d542                      addx.w    d2,d2
[00010916] de07                      add.b     d7,d7
[00010918] d743                      addx.w    d3,d3
[0001091a] de07                      add.b     d7,d7
[0001091c] d944                      addx.w    d4,d4
[0001091e] de07                      add.b     d7,d7
[00010920] db45                      addx.w    d5,d5
[00010922] de07                      add.b     d7,d7
[00010924] dd46                      addx.w    d6,d6
[00010926] de07                      add.b     d7,d7
[00010928] 4847                      swap      d7
[0001092a] df47                      addx.w    d7,d7
[0001092c] 4840                      swap      d0
[0001092e] 51c8 ffd2                 dbf       d0,$00010902
[00010932] 4840                      swap      d0
[00010934] 32c7                      move.w    d7,(a1)+
[00010936] 32c6                      move.w    d6,(a1)+
[00010938] 32c5                      move.w    d5,(a1)+
[0001093a] 32c4                      move.w    d4,(a1)+
[0001093c] 32c3                      move.w    d3,(a1)+
[0001093e] 32c2                      move.w    d2,(a1)+
[00010940] 32c1                      move.w    d1,(a1)+
[00010942] 32c0                      move.w    d0,(a1)+
[00010944] 4e75                      rts
[00010946] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[0001094a] 2c41                      movea.l   d1,a6
[0001094c] 2f08                      move.l    a0,-(a7)
[0001094e] 45e8 0020                 lea.l     32(a0),a2
[00010952] 2f22                      move.l    -(a2),-(a7)
[00010954] 2f22                      move.l    -(a2),-(a7)
[00010956] 2f22                      move.l    -(a2),-(a7)
[00010958] 2f22                      move.l    -(a2),-(a7)
[0001095a] 2f22                      move.l    -(a2),-(a7)
[0001095c] 2f22                      move.l    -(a2),-(a7)
[0001095e] 2f22                      move.l    -(a2),-(a7)
[00010960] 2f22                      move.l    -(a2),-(a7)
[00010962] 5288                      addq.l    #1,a0
[00010964] 619a                      bsr.s     $00010900
[00010966] 204f                      movea.l   a7,a0
[00010968] 6196                      bsr.s     $00010900
[0001096a] 4fef 0020                 lea.l     32(a7),a7
[0001096e] 205f                      movea.l   (a7)+,a0
[00010970] 41e8 0020                 lea.l     32(a0),a0
[00010974] 220e                      move.l    a6,d1
[00010976] 5381                      subq.l    #1,d1
[00010978] 6ad0                      bpl.s     $0001094A
[0001097a] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[0001097e] 700f                      moveq.l   #15,d0
[00010980] 5384                      subq.l    #1,d4
[00010982] 6b2a                      bmi.s     $000109AE
[00010984] 7400                      moveq.l   #0,d2
[00010986] 2204                      move.l    d4,d1
[00010988] d1c0                      adda.l    d0,a0
[0001098a] 41f0 0802                 lea.l     2(a0,d0.l),a0
[0001098e] 3a10                      move.w    (a0),d5
[00010990] 2248                      movea.l   a0,a1
[00010992] 2448                      movea.l   a0,a2
[00010994] d480                      add.l     d0,d2
[00010996] 2602                      move.l    d2,d3
[00010998] 6004                      bra.s     $0001099E
[0001099a] 2449                      movea.l   a1,a2
[0001099c] 34a1                      move.w    -(a1),(a2)
[0001099e] 5383                      subq.l    #1,d3
[000109a0] 6af8                      bpl.s     $0001099A
[000109a2] 3285                      move.w    d5,(a1)
[000109a4] 5381                      subq.l    #1,d1
[000109a6] 6ae0                      bpl.s     $00010988
[000109a8] 204a                      movea.l   a2,a0
[000109aa] 5380                      subq.l    #1,d0
[000109ac] 6ad6                      bpl.s     $00010984
[000109ae] 4e75                      rts
[000109b0] d080                      add.l     d0,d0
[000109b2] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[000109b6] 5288                      addq.l    #1,a0
[000109b8] 610a                      bsr.s     $000109C4
[000109ba] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[000109be] 2400                      move.l    d0,d2
[000109c0] e78a                      lsl.l     #3,d2
[000109c2] d3c2                      adda.l    d2,a1
[000109c4] 45f1 0800                 lea.l     0(a1,d0.l),a2
[000109c8] 47f2 0800                 lea.l     0(a2,d0.l),a3
[000109cc] 49f3 0800                 lea.l     0(a3,d0.l),a4
[000109d0] e588                      lsl.l     #2,d0
[000109d2] 2a40                      movea.l   d0,a5
[000109d4] 2c41                      movea.l   d1,a6
[000109d6] 700f                      moveq.l   #15,d0
[000109d8] 4840                      swap      d0
[000109da] 4847                      swap      d7
[000109dc] 1e18                      move.b    (a0)+,d7
[000109de] 5288                      addq.l    #1,a0
[000109e0] de07                      add.b     d7,d7
[000109e2] d140                      addx.w    d0,d0
[000109e4] de07                      add.b     d7,d7
[000109e6] d341                      addx.w    d1,d1
[000109e8] de07                      add.b     d7,d7
[000109ea] d542                      addx.w    d2,d2
[000109ec] de07                      add.b     d7,d7
[000109ee] d743                      addx.w    d3,d3
[000109f0] de07                      add.b     d7,d7
[000109f2] d944                      addx.w    d4,d4
[000109f4] de07                      add.b     d7,d7
[000109f6] db45                      addx.w    d5,d5
[000109f8] de07                      add.b     d7,d7
[000109fa] dd46                      addx.w    d6,d6
[000109fc] de07                      add.b     d7,d7
[000109fe] 4847                      swap      d7
[00010a00] df47                      addx.w    d7,d7
[00010a02] 4840                      swap      d0
[00010a04] 51c8 ffd2                 dbf       d0,$000109D8
[00010a08] 4840                      swap      d0
[00010a0a] 32c7                      move.w    d7,(a1)+
[00010a0c] 34c6                      move.w    d6,(a2)+
[00010a0e] 36c5                      move.w    d5,(a3)+
[00010a10] 38c4                      move.w    d4,(a4)+
[00010a12] 3383 d8fe                 move.w    d3,-2(a1,a5.l)
[00010a16] 3582 d8fe                 move.w    d2,-2(a2,a5.l)
[00010a1a] 3781 d8fe                 move.w    d1,-2(a3,a5.l)
[00010a1e] 3980 d8fe                 move.w    d0,-2(a4,a5.l)
[00010a22] 220e                      move.l    a6,d1
[00010a24] 5381                      subq.l    #1,d1
[00010a26] 6aac                      bpl.s     $000109D4
[00010a28] 4e75                      rts
[00010a2a] d080                      add.l     d0,d0
[00010a2c] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010a30] 5289                      addq.l    #1,a1
[00010a32] 610a                      bsr.s     $00010A3E
[00010a34] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010a38] 2400                      move.l    d0,d2
[00010a3a] e78a                      lsl.l     #3,d2
[00010a3c] d1c2                      adda.l    d2,a0
[00010a3e] 45f0 0800                 lea.l     0(a0,d0.l),a2
[00010a42] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010a46] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010a4a] e588                      lsl.l     #2,d0
[00010a4c] 2a40                      movea.l   d0,a5
[00010a4e] 2c41                      movea.l   d1,a6
[00010a50] 700f                      moveq.l   #15,d0
[00010a52] 4840                      swap      d0
[00010a54] 3e18                      move.w    (a0)+,d7
[00010a56] 3c1a                      move.w    (a2)+,d6
[00010a58] 3a1b                      move.w    (a3)+,d5
[00010a5a] 381c                      move.w    (a4)+,d4
[00010a5c] 3630 d8fe                 move.w    -2(a0,a5.l),d3
[00010a60] 3432 d8fe                 move.w    -2(a2,a5.l),d2
[00010a64] 3233 d8fe                 move.w    -2(a3,a5.l),d1
[00010a68] 3034 d8fe                 move.w    -2(a4,a5.l),d0
[00010a6c] 4840                      swap      d0
[00010a6e] 4847                      swap      d7
[00010a70] 4840                      swap      d0
[00010a72] d040                      add.w     d0,d0
[00010a74] df07                      addx.b    d7,d7
[00010a76] d241                      add.w     d1,d1
[00010a78] df07                      addx.b    d7,d7
[00010a7a] d442                      add.w     d2,d2
[00010a7c] df07                      addx.b    d7,d7
[00010a7e] d643                      add.w     d3,d3
[00010a80] df07                      addx.b    d7,d7
[00010a82] d844                      add.w     d4,d4
[00010a84] df07                      addx.b    d7,d7
[00010a86] da45                      add.w     d5,d5
[00010a88] df07                      addx.b    d7,d7
[00010a8a] dc46                      add.w     d6,d6
[00010a8c] df07                      addx.b    d7,d7
[00010a8e] 4847                      swap      d7
[00010a90] de47                      add.w     d7,d7
[00010a92] 4847                      swap      d7
[00010a94] df07                      addx.b    d7,d7
[00010a96] 12c7                      move.b    d7,(a1)+
[00010a98] 5289                      addq.l    #1,a1
[00010a9a] 4840                      swap      d0
[00010a9c] 51c8 ffd2                 dbf       d0,$00010A70
[00010aa0] 220e                      move.l    a6,d1
[00010aa2] 5381                      subq.l    #1,d1
[00010aa4] 6aa8                      bpl.s     $00010A4E
[00010aa6] 4e75                      rts
[00010aa8] b3c8                      cmpa.l    a0,a1
[00010aaa] 670e                      beq.s     $00010ABA
[00010aac] e289                      lsr.l     #1,d1
[00010aae] 6504                      bcs.s     $00010AB4
[00010ab0] 32d8                      move.w    (a0)+,(a1)+
[00010ab2] 6002                      bra.s     $00010AB6
[00010ab4] 22d8                      move.l    (a0)+,(a1)+
[00010ab6] 5381                      subq.l    #1,d1
[00010ab8] 6afa                      bpl.s     $00010AB4
[00010aba] 2c5f                      movea.l   (a7)+,a6
[00010abc] 4e75                      rts
[00010abe] 4a6e 01b2                 tst.w     434(a6)
[00010ac2] 670a                      beq.s     $00010ACE
[00010ac4] 206e 01ae                 movea.l   430(a6),a0
[00010ac8] c3ee 01b2                 muls.w    434(a6),d1
[00010acc] 6008                      bra.s     $00010AD6
[00010ace] 2078 044e                 movea.l   ($0000044E).w,a0
[00010ad2] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010ad6] d1c1                      adda.l    d1,a0
[00010ad8] d040                      add.w     d0,d0
[00010ada] d0c0                      adda.w    d0,a0
[00010adc] 7000                      moveq.l   #0,d0
[00010ade] 3010                      move.w    (a0),d0
[00010ae0] 4e75                      rts
[00010ae2] 4a6e 01b2                 tst.w     434(a6)
[00010ae6] 670a                      beq.s     $00010AF2
[00010ae8] 206e 01ae                 movea.l   430(a6),a0
[00010aec] c3ee 01b2                 muls.w    434(a6),d1
[00010af0] 6008                      bra.s     $00010AFA
[00010af2] 2078 044e                 movea.l   ($0000044E).w,a0
[00010af6] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010afa] d1c1                      adda.l    d1,a0
[00010afc] d040                      add.w     d0,d0
[00010afe] d0c0                      adda.w    d0,a0
[00010b00] 3082                      move.w    d2,(a0)
[00010b02] 4e75                      rts
[00010b04] 4e75                      rts
[00010b06] 2278 044e                 movea.l   ($0000044E).w,a1
[00010b0a] 3678 206e                 movea.w   ($0000206E).w,a3
[00010b0e] 4a6e 01b2                 tst.w     434(a6)
[00010b12] 6708                      beq.s     $00010B1C
[00010b14] 226e 01ae                 movea.l   430(a6),a1
[00010b18] 366e 01b2                 movea.w   434(a6),a3
[00010b1c] 426e 01ec                 clr.w     492(a6)
[00010b20] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[00010b26] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[00010b2c] 3d7c 0000 01c8            move.w    #$0000,456(a6)
[00010b32] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00010b38] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[00010b3e] 6600 10f8                 bne       $00011C38
[00010b42] 426e 01ea                 clr.w     490(a6)
[00010b46] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[00010b4c] 6000 10ea                 bra       $00011C38
[00010b50] 4a6e 00ca                 tst.w     202(a6)
[00010b54] 675a                      beq.s     $00010BB0
[00010b56] 2f08                      move.l    a0,-(a7)
[00010b58] 206e 00c6                 movea.l   198(a6),a0
[00010b5c] 780f                      moveq.l   #15,d4
[00010b5e] c841                      and.w     d1,d4
[00010b60] eb4c                      lsl.w     #5,d4
[00010b62] d0c4                      adda.w    d4,a0
[00010b64] 3838 206e                 move.w    ($0000206E).w,d4
[00010b68] 2278 044e                 movea.l   ($0000044E).w,a1
[00010b6c] 4a6e 01b2                 tst.w     434(a6)
[00010b70] 6708                      beq.s     $00010B7A
[00010b72] 382e 01b2                 move.w    434(a6),d4
[00010b76] 226e 01ae                 movea.l   430(a6),a1
[00010b7a] 9440                      sub.w     d0,d2
[00010b7c] d040                      add.w     d0,d0
[00010b7e] c2c4                      mulu.w    d4,d1
[00010b80] 48c0                      ext.l     d0
[00010b82] d280                      add.l     d0,d1
[00010b84] 7e20                      moveq.l   #32,d7
[00010b86] 7c0f                      moveq.l   #15,d6
[00010b88] b446                      cmp.w     d6,d2
[00010b8a] 6c02                      bge.s     $00010B8E
[00010b8c] 3c02                      move.w    d2,d6
[00010b8e] 701f                      moveq.l   #31,d0
[00010b90] c041                      and.w     d1,d0
[00010b92] 3a30 0000                 move.w    0(a0,d0.w),d5
[00010b96] 3802                      move.w    d2,d4
[00010b98] e84c                      lsr.w     #4,d4
[00010b9a] 2241                      movea.l   d1,a1
[00010b9c] 3285                      move.w    d5,(a1)
[00010b9e] d2c7                      adda.w    d7,a1
[00010ba0] 51cc fffa                 dbf       d4,$00010B9C
[00010ba4] 5481                      addq.l    #2,d1
[00010ba6] 5342                      subq.w    #1,d2
[00010ba8] 51ce ffe4                 dbf       d6,$00010B8E
[00010bac] 205f                      movea.l   (a7)+,a0
[00010bae] 4e75                      rts
[00010bb0] 226e 00c6                 movea.l   198(a6),a1
[00010bb4] 780f                      moveq.l   #15,d4
[00010bb6] c841                      and.w     d1,d4
[00010bb8] d844                      add.w     d4,d4
[00010bba] 3c31 4000                 move.w    0(a1,d4.w),d6
[00010bbe] 43ee 0458                 lea.l     1112(a6),a1
[00010bc2] 3a2e 00be                 move.w    190(a6),d5
[00010bc6] da45                      add.w     d5,d5
[00010bc8] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010bcc] 3805                      move.w    d5,d4
[00010bce] 4844                      swap      d4
[00010bd0] 3805                      move.w    d5,d4
[00010bd2] 4a6e 01b2                 tst.w     434(a6)
[00010bd6] 672e                      beq.s     $00010C06
[00010bd8] 226e 01ae                 movea.l   430(a6),a1
[00010bdc] c3ee 01b2                 muls.w    434(a6),d1
[00010be0] 602c                      bra.s     $00010C0E
[00010be2] 43ee 0458                 lea.l     1112(a6),a1
[00010be6] 3a2e 0046                 move.w    70(a6),d5
[00010bea] da45                      add.w     d5,d5
[00010bec] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010bf0] 3805                      move.w    d5,d4
[00010bf2] 4844                      swap      d4
[00010bf4] 3805                      move.w    d5,d4
[00010bf6] 4a6e 01b2                 tst.w     434(a6)
[00010bfa] 670a                      beq.s     $00010C06
[00010bfc] 226e 01ae                 movea.l   430(a6),a1
[00010c00] c3ee 01b2                 muls.w    434(a6),d1
[00010c04] 6008                      bra.s     $00010C0E
[00010c06] 2278 044e                 movea.l   ($0000044E).w,a1
[00010c0a] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010c0e] 48c0                      ext.l     d0
[00010c10] d280                      add.l     d0,d1
[00010c12] d280                      add.l     d0,d1
[00010c14] d3c1                      adda.l    d1,a1
[00010c16] de47                      add.w     d7,d7
[00010c18] 3e3b 7008                 move.w    $00010C22(pc,d7.w),d7
[00010c1c] 4efb 7004                 jmp       $00010C22(pc,d7.w)
[00010c20] 4e75                      rts
[00010c22] 0008 009a                 ori.b     #$9A,a0 ; apollo only
[00010c26] 0144                      bchg      d0,d4
[00010c28] 0098 bc7c ffff            ori.l     #$BC7CFFFF,(a0)+
[00010c2e] 6700 01c4                 beq       $00010DF4
[00010c32] 2f0b                      move.l    a3,-(a7)
[00010c34] 3f05                      move.w    d5,-(a7)
[00010c36] 9440                      sub.w     d0,d2
[00010c38] c07c 000f                 and.w     #$000F,d0
[00010c3c] e17e                      rol.w     d0,d6
[00010c3e] 7220                      moveq.l   #32,d1
[00010c40] 700f                      moveq.l   #15,d0
[00010c42] b440                      cmp.w     d0,d2
[00010c44] 6c02                      bge.s     $00010C48
[00010c46] 3002                      move.w    d2,d0
[00010c48] dc46                      add.w     d6,d6
[00010c4a] 54c5                      scc       d5
[00010c4c] 4885                      ext.w     d5
[00010c4e] 8a57                      or.w      (a7),d5
[00010c50] 3802                      move.w    d2,d4
[00010c52] e84c                      lsr.w     #4,d4
[00010c54] 3e04                      move.w    d4,d7
[00010c56] e84c                      lsr.w     #4,d4
[00010c58] 4647                      not.w     d7
[00010c5a] 0247 000f                 andi.w    #$000F,d7
[00010c5e] de47                      add.w     d7,d7
[00010c60] de47                      add.w     d7,d7
[00010c62] 2649                      movea.l   a1,a3
[00010c64] 4efb 7002                 jmp       $00010C68(pc,d7.w)
[00010c68] 3685                      move.w    d5,(a3)
[00010c6a] d6c1                      adda.w    d1,a3
[00010c6c] 3685                      move.w    d5,(a3)
[00010c6e] d6c1                      adda.w    d1,a3
[00010c70] 3685                      move.w    d5,(a3)
[00010c72] d6c1                      adda.w    d1,a3
[00010c74] 3685                      move.w    d5,(a3)
[00010c76] d6c1                      adda.w    d1,a3
[00010c78] 3685                      move.w    d5,(a3)
[00010c7a] d6c1                      adda.w    d1,a3
[00010c7c] 3685                      move.w    d5,(a3)
[00010c7e] d6c1                      adda.w    d1,a3
[00010c80] 3685                      move.w    d5,(a3)
[00010c82] d6c1                      adda.w    d1,a3
[00010c84] 3685                      move.w    d5,(a3)
[00010c86] d6c1                      adda.w    d1,a3
[00010c88] 3685                      move.w    d5,(a3)
[00010c8a] d6c1                      adda.w    d1,a3
[00010c8c] 3685                      move.w    d5,(a3)
[00010c8e] d6c1                      adda.w    d1,a3
[00010c90] 3685                      move.w    d5,(a3)
[00010c92] d6c1                      adda.w    d1,a3
[00010c94] 3685                      move.w    d5,(a3)
[00010c96] d6c1                      adda.w    d1,a3
[00010c98] 3685                      move.w    d5,(a3)
[00010c9a] d6c1                      adda.w    d1,a3
[00010c9c] 3685                      move.w    d5,(a3)
[00010c9e] d6c1                      adda.w    d1,a3
[00010ca0] 3685                      move.w    d5,(a3)
[00010ca2] d6c1                      adda.w    d1,a3
[00010ca4] 3685                      move.w    d5,(a3)
[00010ca6] d6c1                      adda.w    d1,a3
[00010ca8] 51cc ffbe                 dbf       d4,$00010C68
[00010cac] 5489                      addq.l    #2,a1
[00010cae] 5342                      subq.w    #1,d2
[00010cb0] 51c8 ff96                 dbf       d0,$00010C48
[00010cb4] 3a1f                      move.w    (a7)+,d5
[00010cb6] 265f                      movea.l   (a7)+,a3
[00010cb8] 4e75                      rts
[00010cba] 4646                      not.w     d6
[00010cbc] bc7c ffff                 cmp.w     #$FFFF,d6
[00010cc0] 6700 0132                 beq       $00010DF4
[00010cc4] 2f0b                      move.l    a3,-(a7)
[00010cc6] 9440                      sub.w     d0,d2
[00010cc8] c07c 000f                 and.w     #$000F,d0
[00010ccc] e17e                      rol.w     d0,d6
[00010cce] 7220                      moveq.l   #32,d1
[00010cd0] 700f                      moveq.l   #15,d0
[00010cd2] b440                      cmp.w     d0,d2
[00010cd4] 6c02                      bge.s     $00010CD8
[00010cd6] 3002                      move.w    d2,d0
[00010cd8] dc46                      add.w     d6,d6
[00010cda] 645c                      bcc.s     $00010D38
[00010cdc] 3802                      move.w    d2,d4
[00010cde] e84c                      lsr.w     #4,d4
[00010ce0] 3e04                      move.w    d4,d7
[00010ce2] e84c                      lsr.w     #4,d4
[00010ce4] 4647                      not.w     d7
[00010ce6] 0247 000f                 andi.w    #$000F,d7
[00010cea] de47                      add.w     d7,d7
[00010cec] de47                      add.w     d7,d7
[00010cee] 2649                      movea.l   a1,a3
[00010cf0] 4efb 7002                 jmp       $00010CF4(pc,d7.w)
[00010cf4] 3685                      move.w    d5,(a3)
[00010cf6] d6c1                      adda.w    d1,a3
[00010cf8] 3685                      move.w    d5,(a3)
[00010cfa] d6c1                      adda.w    d1,a3
[00010cfc] 3685                      move.w    d5,(a3)
[00010cfe] d6c1                      adda.w    d1,a3
[00010d00] 3685                      move.w    d5,(a3)
[00010d02] d6c1                      adda.w    d1,a3
[00010d04] 3685                      move.w    d5,(a3)
[00010d06] d6c1                      adda.w    d1,a3
[00010d08] 3685                      move.w    d5,(a3)
[00010d0a] d6c1                      adda.w    d1,a3
[00010d0c] 3685                      move.w    d5,(a3)
[00010d0e] d6c1                      adda.w    d1,a3
[00010d10] 3685                      move.w    d5,(a3)
[00010d12] d6c1                      adda.w    d1,a3
[00010d14] 3685                      move.w    d5,(a3)
[00010d16] d6c1                      adda.w    d1,a3
[00010d18] 3685                      move.w    d5,(a3)
[00010d1a] d6c1                      adda.w    d1,a3
[00010d1c] 3685                      move.w    d5,(a3)
[00010d1e] d6c1                      adda.w    d1,a3
[00010d20] 3685                      move.w    d5,(a3)
[00010d22] d6c1                      adda.w    d1,a3
[00010d24] 3685                      move.w    d5,(a3)
[00010d26] d6c1                      adda.w    d1,a3
[00010d28] 3685                      move.w    d5,(a3)
[00010d2a] d6c1                      adda.w    d1,a3
[00010d2c] 3685                      move.w    d5,(a3)
[00010d2e] d6c1                      adda.w    d1,a3
[00010d30] 3685                      move.w    d5,(a3)
[00010d32] d6c1                      adda.w    d1,a3
[00010d34] 51cc ffbe                 dbf       d4,$00010CF4
[00010d38] 5489                      addq.l    #2,a1
[00010d3a] 5342                      subq.w    #1,d2
[00010d3c] 51c8 ff9a                 dbf       d0,$00010CD8
[00010d40] 265f                      movea.l   (a7)+,a3
[00010d42] 4e75                      rts
[00010d44] 5489                      addq.l    #2,a1
[00010d46] 51ca 0004                 dbf       d2,$00010D4C
[00010d4a] 4e75                      rts
[00010d4c] e24a                      lsr.w     #1,d2
[00010d4e] 78ff                      moveq.l   #-1,d4
[00010d50] 4644                      not.w     d4
[00010d52] 2009                      move.l    a1,d0
[00010d54] 0800 0001                 btst      #1,d0
[00010d58] 6704                      beq.s     $00010D5E
[00010d5a] 5589                      subq.l    #2,a1
[00010d5c] 4684                      not.l     d4
[00010d5e] b999                      eor.l     d4,(a1)+
[00010d60] 51ca fffc                 dbf       d2,$00010D5E
[00010d64] 4e75                      rts
[00010d66] 9440                      sub.w     d0,d2
[00010d68] c07c 000f                 and.w     #$000F,d0
[00010d6c] e17e                      rol.w     d0,d6
[00010d6e] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010d72] 67d8                      beq.s     $00010D4C
[00010d74] bc7c 5555                 cmp.w     #$5555,d6
[00010d78] 67ca                      beq.s     $00010D44
[00010d7a] 2f0b                      move.l    a3,-(a7)
[00010d7c] 7aff                      moveq.l   #-1,d5
[00010d7e] 7220                      moveq.l   #32,d1
[00010d80] 700f                      moveq.l   #15,d0
[00010d82] b440                      cmp.w     d0,d2
[00010d84] 6c02                      bge.s     $00010D88
[00010d86] 3002                      move.w    d2,d0
[00010d88] dc46                      add.w     d6,d6
[00010d8a] 645c                      bcc.s     $00010DE8
[00010d8c] 3802                      move.w    d2,d4
[00010d8e] e84c                      lsr.w     #4,d4
[00010d90] 3e04                      move.w    d4,d7
[00010d92] e84c                      lsr.w     #4,d4
[00010d94] 4647                      not.w     d7
[00010d96] 0247 000f                 andi.w    #$000F,d7
[00010d9a] de47                      add.w     d7,d7
[00010d9c] de47                      add.w     d7,d7
[00010d9e] 2649                      movea.l   a1,a3
[00010da0] 4efb 7002                 jmp       $00010DA4(pc,d7.w)
[00010da4] 4653                      not.w     (a3)
[00010da6] d6c1                      adda.w    d1,a3
[00010da8] 4653                      not.w     (a3)
[00010daa] d6c1                      adda.w    d1,a3
[00010dac] 4653                      not.w     (a3)
[00010dae] d6c1                      adda.w    d1,a3
[00010db0] 4653                      not.w     (a3)
[00010db2] d6c1                      adda.w    d1,a3
[00010db4] 4653                      not.w     (a3)
[00010db6] d6c1                      adda.w    d1,a3
[00010db8] 4653                      not.w     (a3)
[00010dba] d6c1                      adda.w    d1,a3
[00010dbc] 4653                      not.w     (a3)
[00010dbe] d6c1                      adda.w    d1,a3
[00010dc0] 4653                      not.w     (a3)
[00010dc2] d6c1                      adda.w    d1,a3
[00010dc4] 4653                      not.w     (a3)
[00010dc6] d6c1                      adda.w    d1,a3
[00010dc8] 4653                      not.w     (a3)
[00010dca] d6c1                      adda.w    d1,a3
[00010dcc] 4653                      not.w     (a3)
[00010dce] d6c1                      adda.w    d1,a3
[00010dd0] 4653                      not.w     (a3)
[00010dd2] d6c1                      adda.w    d1,a3
[00010dd4] 4653                      not.w     (a3)
[00010dd6] d6c1                      adda.w    d1,a3
[00010dd8] 4653                      not.w     (a3)
[00010dda] d6c1                      adda.w    d1,a3
[00010ddc] 4653                      not.w     (a3)
[00010dde] d6c1                      adda.w    d1,a3
[00010de0] 4653                      not.w     (a3)
[00010de2] d6c1                      adda.w    d1,a3
[00010de4] 51cc ffbe                 dbf       d4,$00010DA4
[00010de8] 5489                      addq.l    #2,a1
[00010dea] 5342                      subq.w    #1,d2
[00010dec] 51c8 ff9a                 dbf       d0,$00010D88
[00010df0] 265f                      movea.l   (a7)+,a3
[00010df2] 4e75                      rts
[00010df4] 9440                      sub.w     d0,d2
[00010df6] e24a                      lsr.w     #1,d2
[00010df8] 6506                      bcs.s     $00010E00
[00010dfa] 32c4                      move.w    d4,(a1)+
[00010dfc] 5342                      subq.w    #1,d2
[00010dfe] 6b06                      bmi.s     $00010E06
[00010e00] 22c4                      move.l    d4,(a1)+
[00010e02] 51ca fffc                 dbf       d2,$00010E00
[00010e06] 4e75                      rts
[00010e08] 9641                      sub.w     d1,d3
[00010e0a] 43ee 0458                 lea.l     1112(a6),a1
[00010e0e] 382e 0046                 move.w    70(a6),d4
[00010e12] d844                      add.w     d4,d4
[00010e14] 3831 4000                 move.w    0(a1,d4.w),d4
[00010e18] 2278 044e                 movea.l   ($0000044E).w,a1
[00010e1c] 3a38 206e                 move.w    ($0000206E).w,d5
[00010e20] 4a6e 01b2                 tst.w     434(a6)
[00010e24] 6708                      beq.s     $00010E2E
[00010e26] 226e 01ae                 movea.l   430(a6),a1
[00010e2a] 3a2e 01b2                 move.w    434(a6),d5
[00010e2e] c3c5                      muls.w    d5,d1
[00010e30] d3c1                      adda.l    d1,a1
[00010e32] d040                      add.w     d0,d0
[00010e34] d2c0                      adda.w    d0,a1
[00010e36] de47                      add.w     d7,d7
[00010e38] 3e3b 7006                 move.w    $00010E40(pc,d7.w),d7
[00010e3c] 4efb 7002                 jmp       $00010E40(pc,d7.w)
J1:
[00010e40] 0126                      dc.w $0126   ; $00010f66-$00010e40
[00010e42] 000a                      dc.w $000a   ; $00010e4a-$00010e40
[00010e44] 009c                      dc.w $009c   ; $00010edc-$00010e40
[00010e46] 0008                      dc.w $0008   ; $00010e48-$00010e40
[00010e48] 4646                      not.w     d6
[00010e4a] 3f05                      move.w    d5,-(a7)
[00010e4c] 48c5                      ext.l     d5
[00010e4e] e98d                      lsl.l     #4,d5
[00010e50] 700f                      moveq.l   #15,d0
[00010e52] b640                      cmp.w     d0,d3
[00010e54] 6c02                      bge.s     $00010E58
[00010e56] 3003                      move.w    d3,d0
[00010e58] 2409                      move.l    a1,d2
[00010e5a] dc46                      add.w     d6,d6
[00010e5c] 645a                      bcc.s     $00010EB8
[00010e5e] 3203                      move.w    d3,d1
[00010e60] e849                      lsr.w     #4,d1
[00010e62] 3e01                      move.w    d1,d7
[00010e64] e849                      lsr.w     #4,d1
[00010e66] 4647                      not.w     d7
[00010e68] 0247 000f                 andi.w    #$000F,d7
[00010e6c] de47                      add.w     d7,d7
[00010e6e] de47                      add.w     d7,d7
[00010e70] 4efb 7002                 jmp       $00010E74(pc,d7.w)
[00010e74] 3284                      move.w    d4,(a1)
[00010e76] d3c5                      adda.l    d5,a1
[00010e78] 3284                      move.w    d4,(a1)
[00010e7a] d3c5                      adda.l    d5,a1
[00010e7c] 3284                      move.w    d4,(a1)
[00010e7e] d3c5                      adda.l    d5,a1
[00010e80] 3284                      move.w    d4,(a1)
[00010e82] d3c5                      adda.l    d5,a1
[00010e84] 3284                      move.w    d4,(a1)
[00010e86] d3c5                      adda.l    d5,a1
[00010e88] 3284                      move.w    d4,(a1)
[00010e8a] d3c5                      adda.l    d5,a1
[00010e8c] 3284                      move.w    d4,(a1)
[00010e8e] d3c5                      adda.l    d5,a1
[00010e90] 3284                      move.w    d4,(a1)
[00010e92] d3c5                      adda.l    d5,a1
[00010e94] 3284                      move.w    d4,(a1)
[00010e96] d3c5                      adda.l    d5,a1
[00010e98] 3284                      move.w    d4,(a1)
[00010e9a] d3c5                      adda.l    d5,a1
[00010e9c] 3284                      move.w    d4,(a1)
[00010e9e] d3c5                      adda.l    d5,a1
[00010ea0] 3284                      move.w    d4,(a1)
[00010ea2] d3c5                      adda.l    d5,a1
[00010ea4] 3284                      move.w    d4,(a1)
[00010ea6] d3c5                      adda.l    d5,a1
[00010ea8] 3284                      move.w    d4,(a1)
[00010eaa] d3c5                      adda.l    d5,a1
[00010eac] 3284                      move.w    d4,(a1)
[00010eae] d3c5                      adda.l    d5,a1
[00010eb0] 3284                      move.w    d4,(a1)
[00010eb2] d3c5                      adda.l    d5,a1
[00010eb4] 51c9 ffbe                 dbf       d1,$00010E74
[00010eb8] 2242                      movea.l   d2,a1
[00010eba] d2d7                      adda.w    (a7),a1
[00010ebc] 5343                      subq.w    #1,d3
[00010ebe] 51c8 ff98                 dbf       d0,$00010E58
[00010ec2] 548f                      addq.l    #2,a7
[00010ec4] 4e75                      rts
[00010ec6] d2c5                      adda.w    d5,a1
[00010ec8] 51cb 0004                 dbf       d3,$00010ECE
[00010ecc] 4e75                      rts
[00010ece] da45                      add.w     d5,d5
[00010ed0] e24b                      lsr.w     #1,d3
[00010ed2] b951                      eor.w     d4,(a1)
[00010ed4] d2c5                      adda.w    d5,a1
[00010ed6] 51cb fffa                 dbf       d3,$00010ED2
[00010eda] 4e75                      rts
[00010edc] 78ff                      moveq.l   #-1,d4
[00010ede] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010ee2] 67ea                      beq.s     $00010ECE
[00010ee4] bc7c 5555                 cmp.w     #$5555,d6
[00010ee8] 67dc                      beq.s     $00010EC6
[00010eea] 3f05                      move.w    d5,-(a7)
[00010eec] 48c5                      ext.l     d5
[00010eee] e98d                      lsl.l     #4,d5
[00010ef0] 700f                      moveq.l   #15,d0
[00010ef2] b640                      cmp.w     d0,d3
[00010ef4] 6c02                      bge.s     $00010EF8
[00010ef6] 3003                      move.w    d3,d0
[00010ef8] 2409                      move.l    a1,d2
[00010efa] dc46                      add.w     d6,d6
[00010efc] 645a                      bcc.s     $00010F58
[00010efe] 3203                      move.w    d3,d1
[00010f00] e849                      lsr.w     #4,d1
[00010f02] 3e01                      move.w    d1,d7
[00010f04] e849                      lsr.w     #4,d1
[00010f06] 4647                      not.w     d7
[00010f08] 0247 000f                 andi.w    #$000F,d7
[00010f0c] de47                      add.w     d7,d7
[00010f0e] de47                      add.w     d7,d7
[00010f10] 4efb 7002                 jmp       $00010F14(pc,d7.w)
[00010f14] b951                      eor.w     d4,(a1)
[00010f16] d3c5                      adda.l    d5,a1
[00010f18] b951                      eor.w     d4,(a1)
[00010f1a] d3c5                      adda.l    d5,a1
[00010f1c] b951                      eor.w     d4,(a1)
[00010f1e] d3c5                      adda.l    d5,a1
[00010f20] b951                      eor.w     d4,(a1)
[00010f22] d3c5                      adda.l    d5,a1
[00010f24] b951                      eor.w     d4,(a1)
[00010f26] d3c5                      adda.l    d5,a1
[00010f28] b951                      eor.w     d4,(a1)
[00010f2a] d3c5                      adda.l    d5,a1
[00010f2c] b951                      eor.w     d4,(a1)
[00010f2e] d3c5                      adda.l    d5,a1
[00010f30] b951                      eor.w     d4,(a1)
[00010f32] d3c5                      adda.l    d5,a1
[00010f34] b951                      eor.w     d4,(a1)
[00010f36] d3c5                      adda.l    d5,a1
[00010f38] b951                      eor.w     d4,(a1)
[00010f3a] d3c5                      adda.l    d5,a1
[00010f3c] b951                      eor.w     d4,(a1)
[00010f3e] d3c5                      adda.l    d5,a1
[00010f40] b951                      eor.w     d4,(a1)
[00010f42] d3c5                      adda.l    d5,a1
[00010f44] b951                      eor.w     d4,(a1)
[00010f46] d3c5                      adda.l    d5,a1
[00010f48] b951                      eor.w     d4,(a1)
[00010f4a] d3c5                      adda.l    d5,a1
[00010f4c] b951                      eor.w     d4,(a1)
[00010f4e] d3c5                      adda.l    d5,a1
[00010f50] b951                      eor.w     d4,(a1)
[00010f52] d3c5                      adda.l    d5,a1
[00010f54] 51c9 ffbe                 dbf       d1,$00010F14
[00010f58] 2242                      movea.l   d2,a1
[00010f5a] d2d7                      adda.w    (a7),a1
[00010f5c] 5343                      subq.w    #1,d3
[00010f5e] 51c8 ff98                 dbf       d0,$00010EF8
[00010f62] 548f                      addq.l    #2,a7
[00010f64] 4e75                      rts
[00010f66] bc7c ffff                 cmp.w     #$FFFF,d6
[00010f6a] 6700 0082                 beq       $00010FEE
[00010f6e] 3f05                      move.w    d5,-(a7)
[00010f70] 48c5                      ext.l     d5
[00010f72] e98d                      lsl.l     #4,d5
[00010f74] 700f                      moveq.l   #15,d0
[00010f76] b640                      cmp.w     d0,d3
[00010f78] 6c02                      bge.s     $00010F7C
[00010f7a] 3003                      move.w    d3,d0
[00010f7c] 2f09                      move.l    a1,-(a7)
[00010f7e] dc46                      add.w     d6,d6
[00010f80] 54c2                      scc       d2
[00010f82] 4882                      ext.w     d2
[00010f84] 8444                      or.w      d4,d2
[00010f86] 3203                      move.w    d3,d1
[00010f88] e849                      lsr.w     #4,d1
[00010f8a] 3e01                      move.w    d1,d7
[00010f8c] e849                      lsr.w     #4,d1
[00010f8e] 4647                      not.w     d7
[00010f90] 0247 000f                 andi.w    #$000F,d7
[00010f94] de47                      add.w     d7,d7
[00010f96] de47                      add.w     d7,d7
[00010f98] 4efb 7002                 jmp       $00010F9C(pc,d7.w)
[00010f9c] 3282                      move.w    d2,(a1)
[00010f9e] d3c5                      adda.l    d5,a1
[00010fa0] 3282                      move.w    d2,(a1)
[00010fa2] d3c5                      adda.l    d5,a1
[00010fa4] 3282                      move.w    d2,(a1)
[00010fa6] d3c5                      adda.l    d5,a1
[00010fa8] 3282                      move.w    d2,(a1)
[00010faa] d3c5                      adda.l    d5,a1
[00010fac] 3282                      move.w    d2,(a1)
[00010fae] d3c5                      adda.l    d5,a1
[00010fb0] 3282                      move.w    d2,(a1)
[00010fb2] d3c5                      adda.l    d5,a1
[00010fb4] 3282                      move.w    d2,(a1)
[00010fb6] d3c5                      adda.l    d5,a1
[00010fb8] 3282                      move.w    d2,(a1)
[00010fba] d3c5                      adda.l    d5,a1
[00010fbc] 3282                      move.w    d2,(a1)
[00010fbe] d3c5                      adda.l    d5,a1
[00010fc0] 3282                      move.w    d2,(a1)
[00010fc2] d3c5                      adda.l    d5,a1
[00010fc4] 3282                      move.w    d2,(a1)
[00010fc6] d3c5                      adda.l    d5,a1
[00010fc8] 3282                      move.w    d2,(a1)
[00010fca] d3c5                      adda.l    d5,a1
[00010fcc] 3282                      move.w    d2,(a1)
[00010fce] d3c5                      adda.l    d5,a1
[00010fd0] 3282                      move.w    d2,(a1)
[00010fd2] d3c5                      adda.l    d5,a1
[00010fd4] 3282                      move.w    d2,(a1)
[00010fd6] d3c5                      adda.l    d5,a1
[00010fd8] 3282                      move.w    d2,(a1)
[00010fda] d3c5                      adda.l    d5,a1
[00010fdc] 51c9 ffbe                 dbf       d1,$00010F9C
[00010fe0] 225f                      movea.l   (a7)+,a1
[00010fe2] d2d7                      adda.w    (a7),a1
[00010fe4] 5343                      subq.w    #1,d3
[00010fe6] 51c8 ff94                 dbf       d0,$00010F7C
[00010fea] 548f                      addq.l    #2,a7
[00010fec] 4e75                      rts
[00010fee] 3403                      move.w    d3,d2
[00010ff0] 4642                      not.w     d2
[00010ff2] c47c 000f                 and.w     #$000F,d2
[00010ff6] d442                      add.w     d2,d2
[00010ff8] d442                      add.w     d2,d2
[00010ffa] e84b                      lsr.w     #4,d3
[00010ffc] 4efb 2002                 jmp       $00011000(pc,d2.w)
[00011000] 3284                      move.w    d4,(a1)
[00011002] d2c5                      adda.w    d5,a1
[00011004] 3284                      move.w    d4,(a1)
[00011006] d2c5                      adda.w    d5,a1
[00011008] 3284                      move.w    d4,(a1)
[0001100a] d2c5                      adda.w    d5,a1
[0001100c] 3284                      move.w    d4,(a1)
[0001100e] d2c5                      adda.w    d5,a1
[00011010] 3284                      move.w    d4,(a1)
[00011012] d2c5                      adda.w    d5,a1
[00011014] 3284                      move.w    d4,(a1)
[00011016] d2c5                      adda.w    d5,a1
[00011018] 3284                      move.w    d4,(a1)
[0001101a] d2c5                      adda.w    d5,a1
[0001101c] 3284                      move.w    d4,(a1)
[0001101e] d2c5                      adda.w    d5,a1
[00011020] 3284                      move.w    d4,(a1)
[00011022] d2c5                      adda.w    d5,a1
[00011024] 3284                      move.w    d4,(a1)
[00011026] d2c5                      adda.w    d5,a1
[00011028] 3284                      move.w    d4,(a1)
[0001102a] d2c5                      adda.w    d5,a1
[0001102c] 3284                      move.w    d4,(a1)
[0001102e] d2c5                      adda.w    d5,a1
[00011030] 3284                      move.w    d4,(a1)
[00011032] d2c5                      adda.w    d5,a1
[00011034] 3284                      move.w    d4,(a1)
[00011036] d2c5                      adda.w    d5,a1
[00011038] 3284                      move.w    d4,(a1)
[0001103a] d2c5                      adda.w    d5,a1
[0001103c] 3284                      move.w    d4,(a1)
[0001103e] d2c5                      adda.w    d5,a1
[00011040] 51cb ffbe                 dbf       d3,$00011000
[00011044] 4e75                      rts
[00011046] 2278 044e                 movea.l   ($0000044E).w,a1
[0001104a] 3a38 206e                 move.w    ($0000206E).w,d5
[0001104e] 4a6e 01b2                 tst.w     434(a6)
[00011052] 6708                      beq.s     $0001105C
[00011054] 226e 01ae                 movea.l   430(a6),a1
[00011058] 3a2e 01b2                 move.w    434(a6),d5
[0001105c] 3805                      move.w    d5,d4
[0001105e] c9c1                      muls.w    d1,d4
[00011060] d3c4                      adda.l    d4,a1
[00011062] d2c0                      adda.w    d0,a1
[00011064] d2c0                      adda.w    d0,a1
[00011066] 780f                      moveq.l   #15,d4
[00011068] c840                      and.w     d0,d4
[0001106a] e97e                      rol.w     d4,d6
[0001106c] 9440                      sub.w     d0,d2
[0001106e] 6b3a                      bmi.s     $000110AA
[00011070] 9641                      sub.w     d1,d3
[00011072] 6a04                      bpl.s     $00011078
[00011074] 4443                      neg.w     d3
[00011076] 4445                      neg.w     d5
[00011078] 2f08                      move.l    a0,-(a7)
[0001107a] 41ee 0458                 lea.l     1112(a6),a0
[0001107e] 382e 0046                 move.w    70(a6),d4
[00011082] d844                      add.w     d4,d4
[00011084] 3830 4000                 move.w    0(a0,d4.w),d4
[00011088] 205f                      movea.l   (a7)+,a0
[0001108a] b443                      cmp.w     d3,d2
[0001108c] 6d26                      blt.s     $000110B4
[0001108e] 3002                      move.w    d2,d0
[00011090] d06e 004e                 add.w     78(a6),d0
[00011094] 6b14                      bmi.s     $000110AA
[00011096] 3203                      move.w    d3,d1
[00011098] d241                      add.w     d1,d1
[0001109a] 4442                      neg.w     d2
[0001109c] 3602                      move.w    d2,d3
[0001109e] d442                      add.w     d2,d2
[000110a0] de47                      add.w     d7,d7
[000110a2] 3e3b 7008                 move.w    $000110AC(pc,d7.w),d7
[000110a6] 4efb 7004                 jmp       $000110AC(pc,d7.w)
[000110aa] 4e75                      rts
[000110ac] 002a 0070 0096            ori.b     #$70,150(a2)
[000110b2] 006e 3003 d06e            ori.w     #$3003,-12178(a6)
[000110b8] 004e 6bee                 ori.w     #$6BEE,a6 ; apollo only
[000110bc] 4443                      neg.w     d3
[000110be] 3203                      move.w    d3,d1
[000110c0] d241                      add.w     d1,d1
[000110c2] d442                      add.w     d2,d2
[000110c4] de47                      add.w     d7,d7
[000110c6] 3e3b 7006                 move.w    $000110CE(pc,d7.w),d7
[000110ca] 4efb 7002                 jmp       $000110CE(pc,d7.w)
J2:
[000110ce] 009c                      dc.w $009c   ; $0001116a-$000110ce
[000110d0] 00e8                      dc.w $00e8   ; $000111b6-$000110ce
[000110d2] 0104                      dc.w $0104   ; $000111d2-$000110ce
[000110d4] 00e6                      dc.w $00e6   ; $000111b4-$000110ce
[000110d6] bc7c                      dc.w $bc7c   ; $0000cd4a-$000110ce
[000110d8] ffff                      dc.w $ffff   ; $000110cd-$000110ce
[000110da] 6728                      dc.w $6728   ; $000177f6-$000110ce
[000110dc] 7eff                      dc.w $7eff   ; $00018fcd-$000110ce
[000110de] e35e                      dc.w $e35e   ; $0000f42c-$000110ce
[000110e0] 640c                      dc.w $640c   ; $000174da-$000110ce
[000110e2] 32c4                      dc.w $32c4   ; $00014392-$000110ce
[000110e4] d641                      dc.w $d641   ; $0000e70f-$000110ce
[000110e6] 6a12                      dc.w $6a12   ; $00017ae0-$000110ce
[000110e8] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[000110ea] fff4                      dc.w $fff4   ; $000110c2-$000110ce
[000110ec] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[000110ee] 32c7                      dc.w $32c7   ; $00014395-$000110ce
[000110f0] d641                      dc.w $d641   ; $0000e70f-$000110ce
[000110f2] 6a06                      dc.w $6a06   ; $00017ad4-$000110ce
[000110f4] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[000110f6] ffe8                      dc.w $ffe8   ; $000110b6-$000110ce
[000110f8] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[000110fa] d2c5                      dc.w $d2c5   ; $0000e393-$000110ce
[000110fc] d642                      dc.w $d642   ; $0000e710-$000110ce
[000110fe] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011100] ffde                      dc.w $ffde   ; $000110ac-$000110ce
[00011102] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011104] 32c4                      dc.w $32c4   ; $00014392-$000110ce
[00011106] d641                      dc.w $d641   ; $0000e70f-$000110ce
[00011108] 6a06                      dc.w $6a06   ; $00017ad4-$000110ce
[0001110a] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[0001110c] fff8                      dc.w $fff8   ; $000110c6-$000110ce
[0001110e] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011110] d2c5                      dc.w $d2c5   ; $0000e393-$000110ce
[00011112] d642                      dc.w $d642   ; $0000e710-$000110ce
[00011114] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011116] ffee                      dc.w $ffee   ; $000110bc-$000110ce
[00011118] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[0001111a] 4646                      dc.w $4646   ; $00015714-$000110ce
[0001111c] e35e                      dc.w $e35e   ; $0000f42c-$000110ce
[0001111e] 640c                      dc.w $640c   ; $000174da-$000110ce
[00011120] 32c4                      dc.w $32c4   ; $00014392-$000110ce
[00011122] d641                      dc.w $d641   ; $0000e70f-$000110ce
[00011124] 6a12                      dc.w $6a12   ; $00017ae0-$000110ce
[00011126] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011128] fff4                      dc.w $fff4   ; $000110c2-$000110ce
[0001112a] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[0001112c] 5489                      dc.w $5489   ; $00016557-$000110ce
[0001112e] d641                      dc.w $d641   ; $0000e70f-$000110ce
[00011130] 6a06                      dc.w $6a06   ; $00017ad4-$000110ce
[00011132] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011134] ffe8                      dc.w $ffe8   ; $000110b6-$000110ce
[00011136] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011138] d2c5                      dc.w $d2c5   ; $0000e393-$000110ce
[0001113a] d642                      dc.w $d642   ; $0000e710-$000110ce
[0001113c] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[0001113e] ffde                      dc.w $ffde   ; $000110ac-$000110ce
[00011140] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011142] 78ff                      dc.w $78ff   ; $000189cd-$000110ce
[00011144] e35e                      dc.w $e35e   ; $0000f42c-$000110ce
[00011146] 640c                      dc.w $640c   ; $000174da-$000110ce
[00011148] b959                      dc.w $b959   ; $0000ca27-$000110ce
[0001114a] d641                      dc.w $d641   ; $0000e70f-$000110ce
[0001114c] 6a12                      dc.w $6a12   ; $00017ae0-$000110ce
[0001114e] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011150] fff4                      dc.w $fff4   ; $000110c2-$000110ce
[00011152] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011154] 5489                      dc.w $5489   ; $00016557-$000110ce
[00011156] d641                      dc.w $d641   ; $0000e70f-$000110ce
[00011158] 6a06                      dc.w $6a06   ; $00017ad4-$000110ce
[0001115a] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[0001115c] ffe8                      dc.w $ffe8   ; $000110b6-$000110ce
[0001115e] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[00011160] d2c5                      dc.w $d2c5   ; $0000e393-$000110ce
[00011162] d642                      dc.w $d642   ; $0000e710-$000110ce
[00011164] 51c8                      dc.w $51c8   ; $00016296-$000110ce
[00011166] ffde                      dc.w $ffde   ; $000110ac-$000110ce
[00011168] 4e75                      dc.w $4e75   ; $00015f43-$000110ce
[0001116a] bc7c ffff                 cmp.w     #$FFFF,d6
[0001116e] 672c                      beq.s     $0001119C
[00011170] 7eff                      moveq.l   #-1,d7
[00011172] e35e                      rol.w     #1,d6
[00011174] 640e                      bcc.s     $00011184
[00011176] 3284                      move.w    d4,(a1)
[00011178] d2c5                      adda.w    d5,a1
[0001117a] d642                      add.w     d2,d3
[0001117c] 6a14                      bpl.s     $00011192
[0001117e] 51c8 fff2                 dbf       d0,$00011172
[00011182] 4e75                      rts
[00011184] 3287                      move.w    d7,(a1)
[00011186] d2c5                      adda.w    d5,a1
[00011188] d642                      add.w     d2,d3
[0001118a] 6a06                      bpl.s     $00011192
[0001118c] 51c8 ffe4                 dbf       d0,$00011172
[00011190] 4e75                      rts
[00011192] d641                      add.w     d1,d3
[00011194] 5489                      addq.l    #2,a1
[00011196] 51c8 ffda                 dbf       d0,$00011172
[0001119a] 4e75                      rts
[0001119c] 3284                      move.w    d4,(a1)
[0001119e] d2c5                      adda.w    d5,a1
[000111a0] d642                      add.w     d2,d3
[000111a2] 6a06                      bpl.s     $000111AA
[000111a4] 51c8 fff6                 dbf       d0,$0001119C
[000111a8] 4e75                      rts
[000111aa] d641                      add.w     d1,d3
[000111ac] 5489                      addq.l    #2,a1
[000111ae] 51c8 ffec                 dbf       d0,$0001119C
[000111b2] 4e75                      rts
[000111b4] 4646                      not.w     d6
[000111b6] e35e                      rol.w     #1,d6
[000111b8] 6402                      bcc.s     $000111BC
[000111ba] 3284                      move.w    d4,(a1)
[000111bc] d2c5                      adda.w    d5,a1
[000111be] d642                      add.w     d2,d3
[000111c0] 6a06                      bpl.s     $000111C8
[000111c2] 51c8 fff2                 dbf       d0,$000111B6
[000111c6] 4e75                      rts
[000111c8] d641                      add.w     d1,d3
[000111ca] 5489                      addq.l    #2,a1
[000111cc] 51c8 ffe8                 dbf       d0,$000111B6
[000111d0] 4e75                      rts
[000111d2] 78ff                      moveq.l   #-1,d4
[000111d4] e35e                      rol.w     #1,d6
[000111d6] 6402                      bcc.s     $000111DA
[000111d8] b951                      eor.w     d4,(a1)
[000111da] d2c5                      adda.w    d5,a1
[000111dc] d642                      add.w     d2,d3
[000111de] 6a06                      bpl.s     $000111E6
[000111e0] 51c8 fff2                 dbf       d0,$000111D4
[000111e4] 4e75                      rts
[000111e6] d641                      add.w     d1,d3
[000111e8] 5489                      addq.l    #2,a1
[000111ea] 51c8 ffe8                 dbf       d0,$000111D4
[000111ee] 4e75                      rts
[000111f0] 41ee 0458                 lea.l     1112(a6),a0
[000111f4] 3a2e 00be                 move.w    190(a6),d5
[000111f8] da45                      add.w     d5,d5
[000111fa] 3a30 5000                 move.w    0(a0,d5.w),d5
[000111fe] 2278 044e                 movea.l   ($0000044E).w,a1
[00011202] 3838 206e                 move.w    ($0000206E).w,d4
[00011206] 4a6e 01b2                 tst.w     434(a6)
[0001120a] 6708                      beq.s     $00011214
[0001120c] 226e 01ae                 movea.l   430(a6),a1
[00011210] 382e 01b2                 move.w    434(a6),d4
[00011214] 3e2e 003c                 move.w    60(a6),d7
[00011218] 286e 00c6                 movea.l   198(a6),a4
[0001121c] 206e 0020                 movea.l   32(a6),a0
[00011220] 9641                      sub.w     d1,d3
[00011222] 3c04                      move.w    d4,d6
[00011224] 3f06                      move.w    d6,-(a7)
[00011226] c9c1                      muls.w    d1,d4
[00011228] d3c4                      adda.l    d4,a1
[0001122a] d2c0                      adda.w    d0,a1
[0001122c] d2c0                      adda.w    d0,a1
[0001122e] 4a47                      tst.w     d7
[00011230] 6600 05c0                 bne       $000117F2
[00011234] 3e05                      move.w    d5,d7
[00011236] 4847                      swap      d7
[00011238] 3e05                      move.w    d5,d7
[0001123a] 3a2e 00c0                 move.w    192(a6),d5
[0001123e] 4a6e 00be                 tst.w     190(a6)
[00011242] 6700 04a6                 beq       $000116EA
[00011246] 4a46                      tst.w     d6
[00011248] 660a                      bne.s     $00011254
[0001124a] 2e3c 7fff 7fff            move.l    #$7FFF7FFF,d7
[00011250] 6000 0498                 bra       $000116EA
[00011254] 5345                      subq.w    #1,d5
[00011256] 6700 0492                 beq       $000116EA
[0001125a] 5345                      subq.w    #1,d5
[0001125c] 660a                      bne.s     $00011268
[0001125e] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[00011264] 6700 0484                 beq       $000116EA
[00011268] 7af0                      moveq.l   #-16,d5
[0001126a] ca42                      and.w     d2,d5
[0001126c] 9a40                      sub.w     d0,d5
[0001126e] da45                      add.w     d5,d5
[00011270] 48c6                      ext.l     d6
[00011272] e98e                      lsl.l     #4,d6
[00011274] 48c5                      ext.l     d5
[00011276] 9c85                      sub.l     d5,d6
[00011278] 2646                      movea.l   d6,a3
[0001127a] 2a48                      movea.l   a0,a5
[0001127c] 7c0f                      moveq.l   #15,d6
[0001127e] 4a6e 00ca                 tst.w     202(a6)
[00011282] 6740                      beq.s     $000112C4
[00011284] c246                      and.w     d6,d1
[00011286] 6724                      beq.s     $000112AC
[00011288] 2f0c                      move.l    a4,-(a7)
[0001128a] 3a01                      move.w    d1,d5
[0001128c] bd45                      eor.w     d6,d5
[0001128e] 3c01                      move.w    d1,d6
[00011290] 5346                      subq.w    #1,d6
[00011292] eb49                      lsl.w     #5,d1
[00011294] d8c1                      adda.w    d1,a4
[00011296] 2adc                      move.l    (a4)+,(a5)+
[00011298] 2adc                      move.l    (a4)+,(a5)+
[0001129a] 2adc                      move.l    (a4)+,(a5)+
[0001129c] 2adc                      move.l    (a4)+,(a5)+
[0001129e] 2adc                      move.l    (a4)+,(a5)+
[000112a0] 2adc                      move.l    (a4)+,(a5)+
[000112a2] 2adc                      move.l    (a4)+,(a5)+
[000112a4] 2adc                      move.l    (a4)+,(a5)+
[000112a6] 51cd ffee                 dbf       d5,$00011296
[000112aa] 285f                      movea.l   (a7)+,a4
[000112ac] 2adc                      move.l    (a4)+,(a5)+
[000112ae] 2adc                      move.l    (a4)+,(a5)+
[000112b0] 2adc                      move.l    (a4)+,(a5)+
[000112b2] 2adc                      move.l    (a4)+,(a5)+
[000112b4] 2adc                      move.l    (a4)+,(a5)+
[000112b6] 2adc                      move.l    (a4)+,(a5)+
[000112b8] 2adc                      move.l    (a4)+,(a5)+
[000112ba] 2adc                      move.l    (a4)+,(a5)+
[000112bc] 51ce ffee                 dbf       d6,$000112AC
[000112c0] 6000 00aa                 bra       $0001136C
[000112c4] 4dfa 14ca                 lea.l     $00012790(pc),a6
[000112c8] c246                      and.w     d6,d1
[000112ca] 6758                      beq.s     $00011324
[000112cc] 2f0c                      move.l    a4,-(a7)
[000112ce] 3a01                      move.w    d1,d5
[000112d0] bd45                      eor.w     d6,d5
[000112d2] 3c01                      move.w    d1,d6
[000112d4] 5346                      subq.w    #1,d6
[000112d6] d241                      add.w     d1,d1
[000112d8] d8c1                      adda.w    d1,a4
[000112da] 7200                      moveq.l   #0,d1
[000112dc] 121c                      move.b    (a4)+,d1
[000112de] e949                      lsl.w     #4,d1
[000112e0] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000112e4] 221a                      move.l    (a2)+,d1
[000112e6] 8287                      or.l      d7,d1
[000112e8] 2ac1                      move.l    d1,(a5)+
[000112ea] 221a                      move.l    (a2)+,d1
[000112ec] 8287                      or.l      d7,d1
[000112ee] 2ac1                      move.l    d1,(a5)+
[000112f0] 221a                      move.l    (a2)+,d1
[000112f2] 8287                      or.l      d7,d1
[000112f4] 2ac1                      move.l    d1,(a5)+
[000112f6] 221a                      move.l    (a2)+,d1
[000112f8] 8287                      or.l      d7,d1
[000112fa] 2ac1                      move.l    d1,(a5)+
[000112fc] 7200                      moveq.l   #0,d1
[000112fe] 121c                      move.b    (a4)+,d1
[00011300] e949                      lsl.w     #4,d1
[00011302] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011306] 221a                      move.l    (a2)+,d1
[00011308] 8287                      or.l      d7,d1
[0001130a] 2ac1                      move.l    d1,(a5)+
[0001130c] 221a                      move.l    (a2)+,d1
[0001130e] 8287                      or.l      d7,d1
[00011310] 2ac1                      move.l    d1,(a5)+
[00011312] 221a                      move.l    (a2)+,d1
[00011314] 8287                      or.l      d7,d1
[00011316] 2ac1                      move.l    d1,(a5)+
[00011318] 221a                      move.l    (a2)+,d1
[0001131a] 8287                      or.l      d7,d1
[0001131c] 2ac1                      move.l    d1,(a5)+
[0001131e] 51cd ffba                 dbf       d5,$000112DA
[00011322] 285f                      movea.l   (a7)+,a4
[00011324] 7200                      moveq.l   #0,d1
[00011326] 121c                      move.b    (a4)+,d1
[00011328] e949                      lsl.w     #4,d1
[0001132a] 45f6 1000                 lea.l     0(a6,d1.w),a2
[0001132e] 221a                      move.l    (a2)+,d1
[00011330] 8287                      or.l      d7,d1
[00011332] 2ac1                      move.l    d1,(a5)+
[00011334] 221a                      move.l    (a2)+,d1
[00011336] 8287                      or.l      d7,d1
[00011338] 2ac1                      move.l    d1,(a5)+
[0001133a] 221a                      move.l    (a2)+,d1
[0001133c] 8287                      or.l      d7,d1
[0001133e] 2ac1                      move.l    d1,(a5)+
[00011340] 221a                      move.l    (a2)+,d1
[00011342] 8287                      or.l      d7,d1
[00011344] 2ac1                      move.l    d1,(a5)+
[00011346] 7200                      moveq.l   #0,d1
[00011348] 121c                      move.b    (a4)+,d1
[0001134a] e949                      lsl.w     #4,d1
[0001134c] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011350] 221a                      move.l    (a2)+,d1
[00011352] 8287                      or.l      d7,d1
[00011354] 2ac1                      move.l    d1,(a5)+
[00011356] 221a                      move.l    (a2)+,d1
[00011358] 8287                      or.l      d7,d1
[0001135a] 2ac1                      move.l    d1,(a5)+
[0001135c] 221a                      move.l    (a2)+,d1
[0001135e] 8287                      or.l      d7,d1
[00011360] 2ac1                      move.l    d1,(a5)+
[00011362] 221a                      move.l    (a2)+,d1
[00011364] 8287                      or.l      d7,d1
[00011366] 2ac1                      move.l    d1,(a5)+
[00011368] 51ce ffba                 dbf       d6,$00011324
[0001136c] 3c02                      move.w    d2,d6
[0001136e] e84a                      lsr.w     #4,d2
[00011370] 3800                      move.w    d0,d4
[00011372] e84c                      lsr.w     #4,d4
[00011374] 9444                      sub.w     d4,d2
[00011376] 5342                      subq.w    #1,d2
[00011378] 6b00 031e                 bmi       $00011698
[0001137c] 383a 130c                 move.w    $0001268A(pc),d4
[00011380] 6712                      beq.s     $00011394
[00011382] 2809                      move.l    a1,d4
[00011384] 7a0f                      moveq.l   #15,d5
[00011386] ca40                      and.w     d0,d5
[00011388] da45                      add.w     d5,d5
[0001138a] 9845                      sub.w     d5,d4
[0001138c] c87c 000f                 and.w     #$000F,d4
[00011390] 6700 017a                 beq       $0001150C
[00011394] cc7c 000f                 and.w     #$000F,d6
[00011398] dc46                      add.w     d6,d6
[0001139a] 3846                      movea.w   d6,a4
[0001139c] 544c                      addq.w    #2,a4
[0001139e] c07c 000f                 and.w     #$000F,d0
[000113a2] d040                      add.w     d0,d0
[000113a4] d040                      add.w     d0,d0
[000113a6] dc46                      add.w     d6,d6
[000113a8] 247b 000a                 movea.l   $000113B4(pc,d0.w),a2
[000113ac] 2c7b 6046                 movea.l   $000113F4(pc,d6.w),a6
[000113b0] 6000 0082                 bra       $00011434
[000113b4] 0001 1482                 ori.b     #$82,d1
[000113b8] 0001 1462                 ori.b     #$62,d1
[000113bc] 0001 1484                 ori.b     #$84,d1
[000113c0] 0001 1466                 ori.b     #$66,d1
[000113c4] 0001 1486                 ori.b     #$86,d1
[000113c8] 0001 146a                 ori.b     #$6A,d1
[000113cc] 0001 1488                 ori.b     #$88,d1
[000113d0] 0001 146e                 ori.b     #$6E,d1
[000113d4] 0001 148a                 ori.b     #$8A,d1
[000113d8] 0001 1472                 ori.b     #$72,d1
[000113dc] 0001 148c                 ori.b     #$8C,d1
[000113e0] 0001 1476                 ori.b     #$76,d1
[000113e4] 0001 148e                 ori.b     #$8E,d1
[000113e8] 0001 147a                 ori.b     #$7A,d1
[000113ec] 0001 1490                 ori.b     #$90,d1
[000113f0] 0001 147e                 ori.b     #$7E,d1
[000113f4] 0001 14d2                 ori.b     #$D2,d1
[000113f8] 0001 14e8                 ori.b     #$E8,d1
[000113fc] 0001 14ca                 ori.b     #$CA,d1
[00011400] 0001 14e6                 ori.b     #$E6,d1
[00011404] 0001 14c2                 ori.b     #$C2,d1
[00011408] 0001 14e4                 ori.b     #$E4,d1
[0001140c] 0001 14ba                 ori.b     #$BA,d1
[00011410] 0001 14e2                 ori.b     #$E2,d1
[00011414] 0001 14b2                 ori.b     #$B2,d1
[00011418] 0001 14e0                 ori.b     #$E0,d1
[0001141c] 0001 14aa                 ori.b     #$AA,d1
[00011420] 0001 14de                 ori.b     #$DE,d1
[00011424] 0001 14a2                 ori.b     #$A2,d1
[00011428] 0001 14dc                 ori.b     #$DC,d1
[0001142c] 0001 149a                 ori.b     #$9A,d1
[00011430] 0001 14da                 ori.b     #$DA,d1
[00011434] 700f                      moveq.l   #15,d0
[00011436] b640                      cmp.w     d0,d3
[00011438] 6c02                      bge.s     $0001143C
[0001143a] 3003                      move.w    d3,d0
[0001143c] 4843                      swap      d3
[0001143e] 3600                      move.w    d0,d3
[00011440] 4843                      swap      d3
[00011442] 2f03                      move.l    d3,-(a7)
[00011444] e84b                      lsr.w     #4,d3
[00011446] 2f08                      move.l    a0,-(a7)
[00011448] 3f0c                      move.w    a4,-(a7)
[0001144a] 2018                      move.l    (a0)+,d0
[0001144c] 2218                      move.l    (a0)+,d1
[0001144e] 2818                      move.l    (a0)+,d4
[00011450] 2a18                      move.l    (a0)+,d5
[00011452] 2c18                      move.l    (a0)+,d6
[00011454] 2e18                      move.l    (a0)+,d7
[00011456] 2858                      movea.l   (a0)+,a4
[00011458] 2a58                      movea.l   (a0)+,a5
[0001145a] 305f                      movea.w   (a7)+,a0
[0001145c] 2f09                      move.l    a1,-(a7)
[0001145e] 3f02                      move.w    d2,-(a7)
[00011460] 4ed2                      jmp       (a2)
[00011462] 32c0                      move.w    d0,(a1)+
[00011464] 601e                      bra.s     $00011484
[00011466] 32c1                      move.w    d1,(a1)+
[00011468] 601c                      bra.s     $00011486
[0001146a] 32c4                      move.w    d4,(a1)+
[0001146c] 601a                      bra.s     $00011488
[0001146e] 32c5                      move.w    d5,(a1)+
[00011470] 6018                      bra.s     $0001148A
[00011472] 32c6                      move.w    d6,(a1)+
[00011474] 6016                      bra.s     $0001148C
[00011476] 32c7                      move.w    d7,(a1)+
[00011478] 6014                      bra.s     $0001148E
[0001147a] 32cc                      move.w    a4,(a1)+
[0001147c] 6012                      bra.s     $00011490
[0001147e] 32cd                      move.w    a5,(a1)+
[00011480] 6010                      bra.s     $00011492
[00011482] 22c0                      move.l    d0,(a1)+
[00011484] 22c1                      move.l    d1,(a1)+
[00011486] 22c4                      move.l    d4,(a1)+
[00011488] 22c5                      move.l    d5,(a1)+
[0001148a] 22c6                      move.l    d6,(a1)+
[0001148c] 22c7                      move.l    d7,(a1)+
[0001148e] 22cc                      move.l    a4,(a1)+
[00011490] 22cd                      move.l    a5,(a1)+
[00011492] 51ca ffee                 dbf       d2,$00011482
[00011496] d2c8                      adda.w    a0,a1
[00011498] 4ed6                      jmp       (a6)
[0001149a] 240d                      move.l    a5,d2
[0001149c] 4842                      swap      d2
[0001149e] 3302                      move.w    d2,-(a1)
[000114a0] 603a                      bra.s     $000114DC
[000114a2] 240c                      move.l    a4,d2
[000114a4] 4842                      swap      d2
[000114a6] 3302                      move.w    d2,-(a1)
[000114a8] 6034                      bra.s     $000114DE
[000114aa] 2407                      move.l    d7,d2
[000114ac] 4842                      swap      d2
[000114ae] 3302                      move.w    d2,-(a1)
[000114b0] 602e                      bra.s     $000114E0
[000114b2] 2406                      move.l    d6,d2
[000114b4] 4842                      swap      d2
[000114b6] 3302                      move.w    d2,-(a1)
[000114b8] 6028                      bra.s     $000114E2
[000114ba] 2405                      move.l    d5,d2
[000114bc] 4842                      swap      d2
[000114be] 3302                      move.w    d2,-(a1)
[000114c0] 6022                      bra.s     $000114E4
[000114c2] 2404                      move.l    d4,d2
[000114c4] 4842                      swap      d2
[000114c6] 3302                      move.w    d2,-(a1)
[000114c8] 601c                      bra.s     $000114E6
[000114ca] 2401                      move.l    d1,d2
[000114cc] 4842                      swap      d2
[000114ce] 3302                      move.w    d2,-(a1)
[000114d0] 6016                      bra.s     $000114E8
[000114d2] 2400                      move.l    d0,d2
[000114d4] 4842                      swap      d2
[000114d6] 3302                      move.w    d2,-(a1)
[000114d8] 6010                      bra.s     $000114EA
[000114da] 230d                      move.l    a5,-(a1)
[000114dc] 230c                      move.l    a4,-(a1)
[000114de] 2307                      move.l    d7,-(a1)
[000114e0] 2306                      move.l    d6,-(a1)
[000114e2] 2305                      move.l    d5,-(a1)
[000114e4] 2304                      move.l    d4,-(a1)
[000114e6] 2301                      move.l    d1,-(a1)
[000114e8] 2300                      move.l    d0,-(a1)
[000114ea] 341f                      move.w    (a7)+,d2
[000114ec] d3cb                      adda.l    a3,a1
[000114ee] 51cb ff6e                 dbf       d3,$0001145E
[000114f2] 225f                      movea.l   (a7)+,a1
[000114f4] 3848                      movea.w   a0,a4
[000114f6] 205f                      movea.l   (a7)+,a0
[000114f8] 41e8 0020                 lea.l     32(a0),a0
[000114fc] 261f                      move.l    (a7)+,d3
[000114fe] 5343                      subq.w    #1,d3
[00011500] 4843                      swap      d3
[00011502] d2d7                      adda.w    (a7),a1
[00011504] 51cb ff3a                 dbf       d3,$00011440
[00011508] 548f                      addq.l    #2,a7
[0001150a] 4e75                      rts
[0001150c] cc7c 000f                 and.w     #$000F,d6
[00011510] dc46                      add.w     d6,d6
[00011512] 3846                      movea.w   d6,a4
[00011514] 544c                      addq.w    #2,a4
[00011516] c07c 000f                 and.w     #$000F,d0
[0001151a] d040                      add.w     d0,d0
[0001151c] d040                      add.w     d0,d0
[0001151e] dc46                      add.w     d6,d6
[00011520] 247b 000a                 movea.l   $0001152C(pc,d0.w),a2
[00011524] 2c7b 6046                 movea.l   $0001156C(pc,d6.w),a6
[00011528] 6000 0082                 bra       $000115AC
[0001152c] 0001 15f6                 ori.b     #$F6,d1
[00011530] 0001 15d6                 ori.b     #$D6,d1
[00011534] 0001 15f8                 ori.b     #$F8,d1
[00011538] 0001 15da                 ori.b     #$DA,d1
[0001153c] 0001 15fa                 ori.b     #$FA,d1
[00011540] 0001 15de                 ori.b     #$DE,d1
[00011544] 0001 15fc                 ori.b     #$FC,d1
[00011548] 0001 15e2                 ori.b     #$E2,d1
[0001154c] 0001 15fe                 ori.b     #$FE,d1
[00011550] 0001 15e6                 ori.b     #$E6,d1
[00011554] 0001 1600                 ori.b     #$00,d1
[00011558] 0001 15ea                 ori.b     #$EA,d1
[0001155c] 0001 1602                 ori.b     #$02,d1
[00011560] 0001 15ee                 ori.b     #$EE,d1
[00011564] 0001 1604                 ori.b     #$04,d1
[00011568] 0001 15f2                 ori.b     #$F2,d1
[0001156c] 0001 1664                 ori.b     #$64,d1
[00011570] 0001 167a                 ori.b     #$7A,d1
[00011574] 0001 165c                 ori.b     #$5C,d1
[00011578] 0001 1678                 ori.b     #$78,d1
[0001157c] 0001 1654                 ori.b     #$54,d1
[00011580] 0001 1676                 ori.b     #$76,d1
[00011584] 0001 164c                 ori.b     #$4C,d1
[00011588] 0001 1674                 ori.b     #$74,d1
[0001158c] 0001 1644                 ori.b     #$44,d1
[00011590] 0001 1672                 ori.b     #$72,d1
[00011594] 0001 163c                 ori.b     #$3C,d1
[00011598] 0001 1670                 ori.b     #$70,d1
[0001159c] 0001 1634                 ori.b     #$34,d1
[000115a0] 0001 166e                 ori.b     #$6E,d1
[000115a4] 0001 162c                 ori.b     #$2C,d1
[000115a8] 0001 166c                 ori.b     #$6C,d1
[000115ac] 700f                      moveq.l   #15,d0
[000115ae] b640                      cmp.w     d0,d3
[000115b0] 6c02                      bge.s     $000115B4
[000115b2] 3003                      move.w    d3,d0
[000115b4] 4843                      swap      d3
[000115b6] 3600                      move.w    d0,d3
[000115b8] 4843                      swap      d3
[000115ba] 2f03                      move.l    d3,-(a7)
[000115bc] e84b                      lsr.w     #4,d3
[000115be] 3f0c                      move.w    a4,-(a7)
[000115c0] 2018                      move.l    (a0)+,d0
[000115c2] 2218                      move.l    (a0)+,d1
[000115c4] 2818                      move.l    (a0)+,d4
[000115c6] 2a18                      move.l    (a0)+,d5
[000115c8] 2c18                      move.l    (a0)+,d6
[000115ca] 2e18                      move.l    (a0)+,d7
[000115cc] 2858                      movea.l   (a0)+,a4
[000115ce] 2a58                      movea.l   (a0)+,a5
[000115d0] 2f09                      move.l    a1,-(a7)
[000115d2] 3f02                      move.w    d2,-(a7)
[000115d4] 4ed2                      jmp       (a2)
[000115d6] 32c0                      move.w    d0,(a1)+
[000115d8] 601e                      bra.s     $000115F8
[000115da] 32c1                      move.w    d1,(a1)+
[000115dc] 601c                      bra.s     $000115FA
[000115de] 32c4                      move.w    d4,(a1)+
[000115e0] 601a                      bra.s     $000115FC
[000115e2] 32c5                      move.w    d5,(a1)+
[000115e4] 6018                      bra.s     $000115FE
[000115e6] 32c6                      move.w    d6,(a1)+
[000115e8] 6016                      bra.s     $00011600
[000115ea] 32c7                      move.w    d7,(a1)+
[000115ec] 6014                      bra.s     $00011602
[000115ee] 32cc                      move.w    a4,(a1)+
[000115f0] 6012                      bra.s     $00011604
[000115f2] 32cd                      move.w    a5,(a1)+
[000115f4] 6010                      bra.s     $00011606
[000115f6] 22c0                      move.l    d0,(a1)+
[000115f8] 22c1                      move.l    d1,(a1)+
[000115fa] 22c4                      move.l    d4,(a1)+
[000115fc] 22c5                      move.l    d5,(a1)+
[000115fe] 22c6                      move.l    d6,(a1)+
[00011600] 22c7                      move.l    d7,(a1)+
[00011602] 22cc                      move.l    a4,(a1)+
[00011604] 22cd                      move.l    a5,(a1)+
[00011606] 5342                      subq.w    #1,d2
[00011608] 6b1c                      bmi.s     $00011626
[0001160a] 2f0a                      move.l    a2,-(a7)
[0001160c] 45e8 ffe0                 lea.l     -32(a0),a2
[00011610] 4a92                      tst.l     (a2)
[00011612] 4aaa 0010                 tst.l     16(a2)
[00011616] 204a                      movea.l   a2,a0
[00011618] f620 9000                 move16    (a0)+,(a1)+
[0001161c] f620 9000                 move16    (a0)+,(a1)+
[00011620] 51ca fff4                 dbf       d2,$00011616
[00011624] 245f                      movea.l   (a7)+,a2
[00011626] d2ef 0006                 adda.w    6(a7),a1
[0001162a] 4ed6                      jmp       (a6)
[0001162c] 240d                      move.l    a5,d2
[0001162e] 4842                      swap      d2
[00011630] 3302                      move.w    d2,-(a1)
[00011632] 603a                      bra.s     $0001166E
[00011634] 240c                      move.l    a4,d2
[00011636] 4842                      swap      d2
[00011638] 3302                      move.w    d2,-(a1)
[0001163a] 6034                      bra.s     $00011670
[0001163c] 2407                      move.l    d7,d2
[0001163e] 4842                      swap      d2
[00011640] 3302                      move.w    d2,-(a1)
[00011642] 602e                      bra.s     $00011672
[00011644] 2406                      move.l    d6,d2
[00011646] 4842                      swap      d2
[00011648] 3302                      move.w    d2,-(a1)
[0001164a] 6028                      bra.s     $00011674
[0001164c] 2405                      move.l    d5,d2
[0001164e] 4842                      swap      d2
[00011650] 3302                      move.w    d2,-(a1)
[00011652] 6022                      bra.s     $00011676
[00011654] 2404                      move.l    d4,d2
[00011656] 4842                      swap      d2
[00011658] 3302                      move.w    d2,-(a1)
[0001165a] 601c                      bra.s     $00011678
[0001165c] 2401                      move.l    d1,d2
[0001165e] 4842                      swap      d2
[00011660] 3302                      move.w    d2,-(a1)
[00011662] 6016                      bra.s     $0001167A
[00011664] 2400                      move.l    d0,d2
[00011666] 4842                      swap      d2
[00011668] 3302                      move.w    d2,-(a1)
[0001166a] 6010                      bra.s     $0001167C
[0001166c] 230d                      move.l    a5,-(a1)
[0001166e] 230c                      move.l    a4,-(a1)
[00011670] 2307                      move.l    d7,-(a1)
[00011672] 2306                      move.l    d6,-(a1)
[00011674] 2305                      move.l    d5,-(a1)
[00011676] 2304                      move.l    d4,-(a1)
[00011678] 2301                      move.l    d1,-(a1)
[0001167a] 2300                      move.l    d0,-(a1)
[0001167c] 341f                      move.w    (a7)+,d2
[0001167e] d3cb                      adda.l    a3,a1
[00011680] 51cb ff50                 dbf       d3,$000115D2
[00011684] 225f                      movea.l   (a7)+,a1
[00011686] 385f                      movea.w   (a7)+,a4
[00011688] 261f                      move.l    (a7)+,d3
[0001168a] 5343                      subq.w    #1,d3
[0001168c] 4843                      swap      d3
[0001168e] d2d7                      adda.w    (a7),a1
[00011690] 51cb ff26                 dbf       d3,$000115B8
[00011694] 548f                      addq.l    #2,a7
[00011696] 4e75                      rts
[00011698] 365f                      movea.w   (a7)+,a3
[0001169a] 720f                      moveq.l   #15,d1
[0001169c] 9c40                      sub.w     d0,d6
[0001169e] 96c6                      suba.w    d6,a3
[000116a0] 96c6                      suba.w    d6,a3
[000116a2] b346                      eor.w     d1,d6
[000116a4] dc46                      add.w     d6,d6
[000116a6] 45fb 601a                 lea.l     $000116C2(pc,d6.w),a2
[000116aa] c041                      and.w     d1,d0
[000116ac] d040                      add.w     d0,d0
[000116ae] d0c0                      adda.w    d0,a0
[000116b0] 2848                      movea.l   a0,a4
[000116b2] 41e8 0020                 lea.l     32(a0),a0
[000116b6] 51c9 0008                 dbf       d1,$000116C0
[000116ba] 720f                      moveq.l   #15,d1
[000116bc] 41e8 fe00                 lea.l     -512(a0),a0
[000116c0] 4ed2                      jmp       (a2)
[000116c2] 32dc                      move.w    (a4)+,(a1)+
[000116c4] 32dc                      move.w    (a4)+,(a1)+
[000116c6] 32dc                      move.w    (a4)+,(a1)+
[000116c8] 32dc                      move.w    (a4)+,(a1)+
[000116ca] 32dc                      move.w    (a4)+,(a1)+
[000116cc] 32dc                      move.w    (a4)+,(a1)+
[000116ce] 32dc                      move.w    (a4)+,(a1)+
[000116d0] 32dc                      move.w    (a4)+,(a1)+
[000116d2] 32dc                      move.w    (a4)+,(a1)+
[000116d4] 32dc                      move.w    (a4)+,(a1)+
[000116d6] 32dc                      move.w    (a4)+,(a1)+
[000116d8] 32dc                      move.w    (a4)+,(a1)+
[000116da] 32dc                      move.w    (a4)+,(a1)+
[000116dc] 32dc                      move.w    (a4)+,(a1)+
[000116de] 32dc                      move.w    (a4)+,(a1)+
[000116e0] 329c                      move.w    (a4)+,(a1)
[000116e2] d2cb                      adda.w    a3,a1
[000116e4] 51cb ffca                 dbf       d3,$000116B0
[000116e8] 4e75                      rts
[000116ea] 365f                      movea.w   (a7)+,a3
[000116ec] 3c02                      move.w    d2,d6
[000116ee] 9c40                      sub.w     d0,d6
[000116f0] 96c6                      suba.w    d6,a3
[000116f2] 96c6                      suba.w    d6,a3
[000116f4] 554b                      subq.w    #2,a3
[000116f6] bc7c 000f                 cmp.w     #$000F,d6
[000116fa] 6f00 00c2                 ble       $000117BE
[000116fe] 2809                      move.l    a1,d4
[00011700] 9840                      sub.w     d0,d4
[00011702] 9840                      sub.w     d0,d4
[00011704] c87c 000f                 and.w     #$000F,d4
[00011708] 6600 009a                 bne       $000117A4
[0001170c] 383a 0f7c                 move.w    $0001268A(pc),d4
[00011710] 6700 0092                 beq       $000117A4
[00011714] 7807                      moveq.l   #7,d4
[00011716] 7a07                      moveq.l   #7,d5
[00011718] c840                      and.w     d0,d4
[0001171a] ca42                      and.w     d2,d5
[0001171c] dc44                      add.w     d4,d6
[0001171e] e64e                      lsr.w     #3,d6
[00011720] 5546                      subq.w    #2,d6
[00011722] d844                      add.w     d4,d4
[00011724] 123b 4026                 move.b    $0001174C(pc,d4.w),d1
[00011728] 143b 4023                 move.b    $0001174D(pc,d4.w),d2
[0001172c] 4881                      ext.w     d1
[0001172e] 4882                      ext.w     d2
[00011730] da45                      add.w     d5,d5
[00011732] 183b 5029                 move.b    $0001175D(pc,d5.w),d4
[00011736] 1a3b 5024                 move.b    $0001175C(pc,d5.w),d5
[0001173a] 4884                      ext.w     d4
[0001173c] 4885                      ext.w     d5
[0001173e] 2448                      movea.l   a0,a2
[00011740] 20c7                      move.l    d7,(a0)+
[00011742] 20c7                      move.l    d7,(a0)+
[00011744] 20c7                      move.l    d7,(a0)+
[00011746] 20c7                      move.l    d7,(a0)+
[00011748] 204a                      movea.l   a2,a0
[0001174a] 6020                      bra.s     $0001176C
[0001174c] ff03 0002                 transhi.q e11-e14,d0:d1
[00011750] ff02 0001                 load.q    e10,d0
[00011754] ff01                      dc.w      $FF01 ; illegal
[00011756] 0000 ff00                 ori.b     #$00,d0
[0001175a] 00ff 00ff                 cmp2.b    ???,d0 ; 68020+ only
[0001175e] ff00                      dc.w      $FF00 ; illegal
[00011760] 0000 ff01                 ori.b     #$01,d0
[00011764] 0001 ff02                 ori.b     #$02,d1
[00011768] 0002 ff03                 ori.b     #$03,d2
[0001176c] 3001                      move.w    d1,d0
[0001176e] 6b02                      bmi.s     $00011772
[00011770] 32c7                      move.w    d7,(a1)+
[00011772] 3002                      move.w    d2,d0
[00011774] 6b06                      bmi.s     $0001177C
[00011776] 22c7                      move.l    d7,(a1)+
[00011778] 51c8 fffc                 dbf       d0,$00011776
[0001177c] 3006                      move.w    d6,d0
[0001177e] 6b0c                      bmi.s     $0001178C
[00011780] 2e10                      move.l    (a0),d7
[00011782] f620 9000                 move16    (a0)+,(a1)+
[00011786] 204a                      movea.l   a2,a0
[00011788] 51c8 fff8                 dbf       d0,$00011782
[0001178c] 3004                      move.w    d4,d0
[0001178e] 6b06                      bmi.s     $00011796
[00011790] 22c7                      move.l    d7,(a1)+
[00011792] 51c8 fffc                 dbf       d0,$00011790
[00011796] 3005                      move.w    d5,d0
[00011798] 6b02                      bmi.s     $0001179C
[0001179a] 32c7                      move.w    d7,(a1)+
[0001179c] d2cb                      adda.w    a3,a1
[0001179e] 51cb ffcc                 dbf       d3,$0001176C
[000117a2] 4e75                      rts
[000117a4] 3006                      move.w    d6,d0
[000117a6] e248                      lsr.w     #1,d0
[000117a8] 6506                      bcs.s     $000117B0
[000117aa] 32c7                      move.w    d7,(a1)+
[000117ac] 5340                      subq.w    #1,d0
[000117ae] 6b06                      bmi.s     $000117B6
[000117b0] 22c7                      move.l    d7,(a1)+
[000117b2] 51c8 fffc                 dbf       d0,$000117B0
[000117b6] d2cb                      adda.w    a3,a1
[000117b8] 51cb ffea                 dbf       d3,$000117A4
[000117bc] 4e75                      rts
[000117be] 0a46 000f                 eori.w    #$000F,d6
[000117c2] dc46                      add.w     d6,d6
[000117c4] 45fb 6004                 lea.l     $000117CA(pc,d6.w),a2
[000117c8] 4ed2                      jmp       (a2)
[000117ca] 32c7                      move.w    d7,(a1)+
[000117cc] 32c7                      move.w    d7,(a1)+
[000117ce] 32c7                      move.w    d7,(a1)+
[000117d0] 32c7                      move.w    d7,(a1)+
[000117d2] 32c7                      move.w    d7,(a1)+
[000117d4] 32c7                      move.w    d7,(a1)+
[000117d6] 32c7                      move.w    d7,(a1)+
[000117d8] 32c7                      move.w    d7,(a1)+
[000117da] 32c7                      move.w    d7,(a1)+
[000117dc] 32c7                      move.w    d7,(a1)+
[000117de] 32c7                      move.w    d7,(a1)+
[000117e0] 32c7                      move.w    d7,(a1)+
[000117e2] 32c7                      move.w    d7,(a1)+
[000117e4] 32c7                      move.w    d7,(a1)+
[000117e6] 32c7                      move.w    d7,(a1)+
[000117e8] 32c7                      move.w    d7,(a1)+
[000117ea] d2cb                      adda.w    a3,a1
[000117ec] 51cb ffda                 dbf       d3,$000117C8
[000117f0] 4e75                      rts
[000117f2] 5547                      subq.w    #2,d7
[000117f4] 6d00 034a                 blt       $00011B40
[000117f8] 6600 030a                 bne       $00011B04
[000117fc] 3e2e 00c0                 move.w    192(a6),d7
[00011800] 6700 022c                 beq       $00011A2E
[00011804] 5347                      subq.w    #1,d7
[00011806] 6700 029e                 beq       $00011AA6
[0001180a] 5347                      subq.w    #1,d7
[0001180c] 660a                      bne.s     $00011818
[0001180e] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[00011814] 6700 0290                 beq       $00011AA6
[00011818] 7af0                      moveq.l   #-16,d5
[0001181a] ca42                      and.w     d2,d5
[0001181c] 9a40                      sub.w     d0,d5
[0001181e] da45                      add.w     d5,d5
[00011820] 48c6                      ext.l     d6
[00011822] e94e                      lsl.w     #4,d6
[00011824] 48c5                      ext.l     d5
[00011826] 9c85                      sub.l     d5,d6
[00011828] 2646                      movea.l   d6,a3
[0001182a] 4dfa 0f64                 lea.l     $00012790(pc),a6
[0001182e] 2a48                      movea.l   a0,a5
[00011830] 7c0f                      moveq.l   #15,d6
[00011832] c246                      and.w     d6,d1
[00011834] 673c                      beq.s     $00011872
[00011836] 2f0c                      move.l    a4,-(a7)
[00011838] 3a01                      move.w    d1,d5
[0001183a] bd45                      eor.w     d6,d5
[0001183c] 3c01                      move.w    d1,d6
[0001183e] 5346                      subq.w    #1,d6
[00011840] d241                      add.w     d1,d1
[00011842] d8c1                      adda.w    d1,a4
[00011844] 7200                      moveq.l   #0,d1
[00011846] 121c                      move.b    (a4)+,d1
[00011848] 4601                      not.b     d1
[0001184a] e949                      lsl.w     #4,d1
[0001184c] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011850] 2ada                      move.l    (a2)+,(a5)+
[00011852] 2ada                      move.l    (a2)+,(a5)+
[00011854] 2ada                      move.l    (a2)+,(a5)+
[00011856] 2ada                      move.l    (a2)+,(a5)+
[00011858] 7200                      moveq.l   #0,d1
[0001185a] 121c                      move.b    (a4)+,d1
[0001185c] 4601                      not.b     d1
[0001185e] e949                      lsl.w     #4,d1
[00011860] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011864] 2ada                      move.l    (a2)+,(a5)+
[00011866] 2ada                      move.l    (a2)+,(a5)+
[00011868] 2ada                      move.l    (a2)+,(a5)+
[0001186a] 2ada                      move.l    (a2)+,(a5)+
[0001186c] 51cd ffd6                 dbf       d5,$00011844
[00011870] 285f                      movea.l   (a7)+,a4
[00011872] 7200                      moveq.l   #0,d1
[00011874] 121c                      move.b    (a4)+,d1
[00011876] 4601                      not.b     d1
[00011878] e949                      lsl.w     #4,d1
[0001187a] 45f6 1000                 lea.l     0(a6,d1.w),a2
[0001187e] 2ada                      move.l    (a2)+,(a5)+
[00011880] 2ada                      move.l    (a2)+,(a5)+
[00011882] 2ada                      move.l    (a2)+,(a5)+
[00011884] 2ada                      move.l    (a2)+,(a5)+
[00011886] 7200                      moveq.l   #0,d1
[00011888] 121c                      move.b    (a4)+,d1
[0001188a] 4601                      not.b     d1
[0001188c] e949                      lsl.w     #4,d1
[0001188e] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011892] 2ada                      move.l    (a2)+,(a5)+
[00011894] 2ada                      move.l    (a2)+,(a5)+
[00011896] 2ada                      move.l    (a2)+,(a5)+
[00011898] 2ada                      move.l    (a2)+,(a5)+
[0001189a] 51ce ffd6                 dbf       d6,$00011872
[0001189e] 3c02                      move.w    d2,d6
[000118a0] e84a                      lsr.w     #4,d2
[000118a2] 3800                      move.w    d0,d4
[000118a4] e84c                      lsr.w     #4,d4
[000118a6] 9444                      sub.w     d4,d2
[000118a8] 5342                      subq.w    #1,d2
[000118aa] 6b00 0186                 bmi       $00011A32
[000118ae] cc7c 000f                 and.w     #$000F,d6
[000118b2] dc46                      add.w     d6,d6
[000118b4] 3846                      movea.w   d6,a4
[000118b6] 544c                      addq.w    #2,a4
[000118b8] c07c 000f                 and.w     #$000F,d0
[000118bc] d040                      add.w     d0,d0
[000118be] d040                      add.w     d0,d0
[000118c0] dc46                      add.w     d6,d6
[000118c2] 247b 000a                 movea.l   $000118CE(pc,d0.w),a2
[000118c6] 2c7b 6046                 movea.l   $0001190E(pc,d6.w),a6
[000118ca] 6000 0082                 bra       $0001194E
[000118ce] 0001 19a2                 ori.b     #$A2,d1
[000118d2] 0001 1980                 ori.b     #$80,d1
[000118d6] 0001 19a4                 ori.b     #$A4,d1
[000118da] 0001 1984                 ori.b     #$84,d1
[000118de] 0001 19a6                 ori.b     #$A6,d1
[000118e2] 0001 1988                 ori.b     #$88,d1
[000118e6] 0001 19a8                 ori.b     #$A8,d1
[000118ea] 0001 198c                 ori.b     #$8C,d1
[000118ee] 0001 19aa                 ori.b     #$AA,d1
[000118f2] 0001 1990                 ori.b     #$90,d1
[000118f6] 0001 19ac                 ori.b     #$AC,d1
[000118fa] 0001 1994                 ori.b     #$94,d1
[000118fe] 0001 19ae                 ori.b     #$AE,d1
[00011902] 0001 1998                 ori.b     #$98,d1
[00011906] 0001 19b0                 ori.b     #$B0,d1
[0001190a] 0001 199c                 ori.b     #$9C,d1
[0001190e] 0001 19f4                 ori.b     #$F4,d1
[00011912] 0001 1a0c                 ori.b     #$0C,d1
[00011916] 0001 19ec                 ori.b     #$EC,d1
[0001191a] 0001 1a0a                 ori.b     #$0A,d1
[0001191e] 0001 19e4                 ori.b     #$E4,d1
[00011922] 0001 1a08                 ori.b     #$08,d1
[00011926] 0001 19dc                 ori.b     #$DC,d1
[0001192a] 0001 1a06                 ori.b     #$06,d1
[0001192e] 0001 19d4                 ori.b     #$D4,d1
[00011932] 0001 1a04                 ori.b     #$04,d1
[00011936] 0001 19cc                 ori.b     #$CC,d1
[0001193a] 0001 1a02                 ori.b     #$02,d1
[0001193e] 0001 19c4                 ori.b     #$C4,d1
[00011942] 0001 1a00                 ori.b     #$00,d1
[00011946] 0001 19bc                 ori.b     #$BC,d1
[0001194a] 0001 19fc                 ori.b     #$FC,d1
[0001194e] 700f                      moveq.l   #15,d0
[00011950] b640                      cmp.w     d0,d3
[00011952] 6c02                      bge.s     $00011956
[00011954] 3003                      move.w    d3,d0
[00011956] 4843                      swap      d3
[00011958] 3600                      move.w    d0,d3
[0001195a] 4843                      swap      d3
[0001195c] 2f03                      move.l    d3,-(a7)
[0001195e] e84b                      lsr.w     #4,d3
[00011960] 2f08                      move.l    a0,-(a7)
[00011962] 3f0c                      move.w    a4,-(a7)
[00011964] 2018                      move.l    (a0)+,d0
[00011966] 2218                      move.l    (a0)+,d1
[00011968] 2818                      move.l    (a0)+,d4
[0001196a] 2a18                      move.l    (a0)+,d5
[0001196c] 2c18                      move.l    (a0)+,d6
[0001196e] 2e18                      move.l    (a0)+,d7
[00011970] 2858                      movea.l   (a0)+,a4
[00011972] 2a58                      movea.l   (a0)+,a5
[00011974] 305f                      movea.w   (a7)+,a0
[00011976] 2f09                      move.l    a1,-(a7)
[00011978] 3f02                      move.w    d2,-(a7)
[0001197a] c78c                      exg       d3,a4
[0001197c] c58d                      exg       d2,a5
[0001197e] 4ed2                      jmp       (a2)
[00011980] b159                      eor.w     d0,(a1)+
[00011982] 6020                      bra.s     $000119A4
[00011984] b359                      eor.w     d1,(a1)+
[00011986] 601e                      bra.s     $000119A6
[00011988] b959                      eor.w     d4,(a1)+
[0001198a] 601c                      bra.s     $000119A8
[0001198c] bb59                      eor.w     d5,(a1)+
[0001198e] 601a                      bra.s     $000119AA
[00011990] bd59                      eor.w     d6,(a1)+
[00011992] 6018                      bra.s     $000119AC
[00011994] bf59                      eor.w     d7,(a1)+
[00011996] 6016                      bra.s     $000119AE
[00011998] b759                      eor.w     d3,(a1)+
[0001199a] 6014                      bra.s     $000119B0
[0001199c] 32c2                      move.w    d2,(a1)+
[0001199e] 6012                      bra.s     $000119B2
[000119a0] c58d                      exg       d2,a5
[000119a2] b199                      eor.l     d0,(a1)+
[000119a4] b399                      eor.l     d1,(a1)+
[000119a6] b999                      eor.l     d4,(a1)+
[000119a8] bb99                      eor.l     d5,(a1)+
[000119aa] bd99                      eor.l     d6,(a1)+
[000119ac] bf99                      eor.l     d7,(a1)+
[000119ae] b799                      eor.l     d3,(a1)+
[000119b0] b599                      eor.l     d2,(a1)+
[000119b2] c58d                      exg       d2,a5
[000119b4] 51ca ffea                 dbf       d2,$000119A0
[000119b8] d2c8                      adda.w    a0,a1
[000119ba] 4ed6                      jmp       (a6)
[000119bc] 240d                      move.l    a5,d2
[000119be] 4842                      swap      d2
[000119c0] b561                      eor.w     d2,-(a1)
[000119c2] 603c                      bra.s     $00011A00
[000119c4] 2403                      move.l    d3,d2
[000119c6] 4842                      swap      d2
[000119c8] b561                      eor.w     d2,-(a1)
[000119ca] 6036                      bra.s     $00011A02
[000119cc] 2407                      move.l    d7,d2
[000119ce] 4842                      swap      d2
[000119d0] b561                      eor.w     d2,-(a1)
[000119d2] 6030                      bra.s     $00011A04
[000119d4] 2406                      move.l    d6,d2
[000119d6] 4842                      swap      d2
[000119d8] b561                      eor.w     d2,-(a1)
[000119da] 602a                      bra.s     $00011A06
[000119dc] 2405                      move.l    d5,d2
[000119de] 4842                      swap      d2
[000119e0] b561                      eor.w     d2,-(a1)
[000119e2] 6024                      bra.s     $00011A08
[000119e4] 2404                      move.l    d4,d2
[000119e6] 4842                      swap      d2
[000119e8] b561                      eor.w     d2,-(a1)
[000119ea] 601e                      bra.s     $00011A0A
[000119ec] 2401                      move.l    d1,d2
[000119ee] 4842                      swap      d2
[000119f0] b561                      eor.w     d2,-(a1)
[000119f2] 6018                      bra.s     $00011A0C
[000119f4] 2400                      move.l    d0,d2
[000119f6] 4842                      swap      d2
[000119f8] b561                      eor.w     d2,-(a1)
[000119fa] 6012                      bra.s     $00011A0E
[000119fc] 240d                      move.l    a5,d2
[000119fe] b5a1                      eor.l     d2,-(a1)
[00011a00] b7a1                      eor.l     d3,-(a1)
[00011a02] bfa1                      eor.l     d7,-(a1)
[00011a04] bda1                      eor.l     d6,-(a1)
[00011a06] bba1                      eor.l     d5,-(a1)
[00011a08] b9a1                      eor.l     d4,-(a1)
[00011a0a] b3a1                      eor.l     d1,-(a1)
[00011a0c] b1a1                      eor.l     d0,-(a1)
[00011a0e] c78c                      exg       d3,a4
[00011a10] 341f                      move.w    (a7)+,d2
[00011a12] d3cb                      adda.l    a3,a1
[00011a14] 51cb ff62                 dbf       d3,$00011978
[00011a18] 225f                      movea.l   (a7)+,a1
[00011a1a] 3848                      movea.w   a0,a4
[00011a1c] 205f                      movea.l   (a7)+,a0
[00011a1e] 41e8 0020                 lea.l     32(a0),a0
[00011a22] 261f                      move.l    (a7)+,d3
[00011a24] 5343                      subq.w    #1,d3
[00011a26] 4843                      swap      d3
[00011a28] d2d7                      adda.w    (a7),a1
[00011a2a] 51cb ff2e                 dbf       d3,$0001195A
[00011a2e] 548f                      addq.l    #2,a7
[00011a30] 4e75                      rts
[00011a32] 365f                      movea.w   (a7)+,a3
[00011a34] 720f                      moveq.l   #15,d1
[00011a36] 9c40                      sub.w     d0,d6
[00011a38] 96c6                      suba.w    d6,a3
[00011a3a] 96c6                      suba.w    d6,a3
[00011a3c] b346                      eor.w     d1,d6
[00011a3e] dc46                      add.w     d6,d6
[00011a40] dc46                      add.w     d6,d6
[00011a42] 45fb 601a                 lea.l     $00011A5E(pc,d6.w),a2
[00011a46] c041                      and.w     d1,d0
[00011a48] d040                      add.w     d0,d0
[00011a4a] d0c0                      adda.w    d0,a0
[00011a4c] 2848                      movea.l   a0,a4
[00011a4e] 41e8 0020                 lea.l     32(a0),a0
[00011a52] 51c9 0008                 dbf       d1,$00011A5C
[00011a56] 720f                      moveq.l   #15,d1
[00011a58] 41e8 fe00                 lea.l     -512(a0),a0
[00011a5c] 4ed2                      jmp       (a2)
[00011a5e] 301c                      move.w    (a4)+,d0
[00011a60] b159                      eor.w     d0,(a1)+
[00011a62] 301c                      move.w    (a4)+,d0
[00011a64] b159                      eor.w     d0,(a1)+
[00011a66] 301c                      move.w    (a4)+,d0
[00011a68] b159                      eor.w     d0,(a1)+
[00011a6a] 301c                      move.w    (a4)+,d0
[00011a6c] b159                      eor.w     d0,(a1)+
[00011a6e] 301c                      move.w    (a4)+,d0
[00011a70] b159                      eor.w     d0,(a1)+
[00011a72] 301c                      move.w    (a4)+,d0
[00011a74] b159                      eor.w     d0,(a1)+
[00011a76] 301c                      move.w    (a4)+,d0
[00011a78] b159                      eor.w     d0,(a1)+
[00011a7a] 301c                      move.w    (a4)+,d0
[00011a7c] b159                      eor.w     d0,(a1)+
[00011a7e] 301c                      move.w    (a4)+,d0
[00011a80] b159                      eor.w     d0,(a1)+
[00011a82] 301c                      move.w    (a4)+,d0
[00011a84] b159                      eor.w     d0,(a1)+
[00011a86] 301c                      move.w    (a4)+,d0
[00011a88] b159                      eor.w     d0,(a1)+
[00011a8a] 301c                      move.w    (a4)+,d0
[00011a8c] b159                      eor.w     d0,(a1)+
[00011a8e] 301c                      move.w    (a4)+,d0
[00011a90] b159                      eor.w     d0,(a1)+
[00011a92] 301c                      move.w    (a4)+,d0
[00011a94] b159                      eor.w     d0,(a1)+
[00011a96] 301c                      move.w    (a4)+,d0
[00011a98] b159                      eor.w     d0,(a1)+
[00011a9a] 301c                      move.w    (a4)+,d0
[00011a9c] b151                      eor.w     d0,(a1)
[00011a9e] d2cb                      adda.w    a3,a1
[00011aa0] 51cb ffaa                 dbf       d3,$00011A4C
[00011aa4] 4e75                      rts
[00011aa6] 9440                      sub.w     d0,d2
[00011aa8] 9c42                      sub.w     d2,d6
[00011aaa] 9c42                      sub.w     d2,d6
[00011aac] 5546                      subq.w    #2,d6
[00011aae] 0802 0000                 btst      #0,d2
[00011ab2] 661c                      bne.s     $00011AD0
[00011ab4] 41fa 002c                 lea.l     $00011AE2(pc),a0
[00011ab8] 45fa 0040                 lea.l     $00011AFA(pc),a2
[00011abc] 5342                      subq.w    #1,d2
[00011abe] 6b1e                      bmi.s     $00011ADE
[00011ac0] 700e                      moveq.l   #14,d0
[00011ac2] c042                      and.w     d2,d0
[00011ac4] e84a                      lsr.w     #4,d2
[00011ac6] 0a40 000e                 eori.w    #$000E,d0
[00011aca] 45fb 001a                 lea.l     $00011AE6(pc,d0.w),a2
[00011ace] 600e                      bra.s     $00011ADE
[00011ad0] 700e                      moveq.l   #14,d0
[00011ad2] c042                      and.w     d2,d0
[00011ad4] e84a                      lsr.w     #4,d2
[00011ad6] 0a40 000e                 eori.w    #$000E,d0
[00011ada] 41fb 000a                 lea.l     $00011AE6(pc,d0.w),a0
[00011ade] 3002                      move.w    d2,d0
[00011ae0] 4ed0                      jmp       (a0)
[00011ae2] 4659                      not.w     (a1)+
[00011ae4] 4ed2                      jmp       (a2)
[00011ae6] 4699                      not.l     (a1)+
[00011ae8] 4699                      not.l     (a1)+
[00011aea] 4699                      not.l     (a1)+
[00011aec] 4699                      not.l     (a1)+
[00011aee] 4699                      not.l     (a1)+
[00011af0] 4699                      not.l     (a1)+
[00011af2] 4699                      not.l     (a1)+
[00011af4] 4699                      not.l     (a1)+
[00011af6] 51c8 ffee                 dbf       d0,$00011AE6
[00011afa] d2c6                      adda.w    d6,a1
[00011afc] 51cb ffe0                 dbf       d3,$00011ADE
[00011b00] 548f                      addq.l    #2,a7
[00011b02] 4e75                      rts
[00011b04] 9440                      sub.w     d0,d2
[00011b06] 48c6                      ext.l     d6
[00011b08] e98e                      lsl.l     #4,d6
[00011b0a] 2646                      movea.l   d6,a3
[00011b0c] 2a48                      movea.l   a0,a5
[00011b0e] 780f                      moveq.l   #15,d4
[00011b10] 7c0f                      moveq.l   #15,d6
[00011b12] c044                      and.w     d4,d0
[00011b14] c244                      and.w     d4,d1
[00011b16] 671a                      beq.s     $00011B32
[00011b18] 3e01                      move.w    d1,d7
[00011b1a] bd47                      eor.w     d6,d7
[00011b1c] 3c01                      move.w    d1,d6
[00011b1e] 5346                      subq.w    #1,d6
[00011b20] d241                      add.w     d1,d1
[00011b22] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011b26] 321a                      move.w    (a2)+,d1
[00011b28] 4641                      not.w     d1
[00011b2a] e179                      rol.w     d0,d1
[00011b2c] 3ac1                      move.w    d1,(a5)+
[00011b2e] 51cf fff6                 dbf       d7,$00011B26
[00011b32] 321c                      move.w    (a4)+,d1
[00011b34] 4641                      not.w     d1
[00011b36] e179                      rol.w     d0,d1
[00011b38] 3ac1                      move.w    d1,(a5)+
[00011b3a] 51ce fff6                 dbf       d6,$00011B32
[00011b3e] 6036                      bra.s     $00011B76
[00011b40] 9440                      sub.w     d0,d2
[00011b42] 48c6                      ext.l     d6
[00011b44] e98e                      lsl.l     #4,d6
[00011b46] 2646                      movea.l   d6,a3
[00011b48] 2a48                      movea.l   a0,a5
[00011b4a] 780f                      moveq.l   #15,d4
[00011b4c] 7c0f                      moveq.l   #15,d6
[00011b4e] c044                      and.w     d4,d0
[00011b50] c244                      and.w     d4,d1
[00011b52] 6718                      beq.s     $00011B6C
[00011b54] 3e01                      move.w    d1,d7
[00011b56] bd47                      eor.w     d6,d7
[00011b58] 3c01                      move.w    d1,d6
[00011b5a] 5346                      subq.w    #1,d6
[00011b5c] d241                      add.w     d1,d1
[00011b5e] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011b62] 321a                      move.w    (a2)+,d1
[00011b64] e179                      rol.w     d0,d1
[00011b66] 3ac1                      move.w    d1,(a5)+
[00011b68] 51cf fff8                 dbf       d7,$00011B62
[00011b6c] 321c                      move.w    (a4)+,d1
[00011b6e] e179                      rol.w     d0,d1
[00011b70] 3ac1                      move.w    d1,(a5)+
[00011b72] 51ce fff8                 dbf       d6,$00011B6C
[00011b76] 3e05                      move.w    d5,d7
[00011b78] b644                      cmp.w     d4,d3
[00011b7a] 6c02                      bge.s     $00011B7E
[00011b7c] 3803                      move.w    d3,d4
[00011b7e] 4843                      swap      d3
[00011b80] 3604                      move.w    d4,d3
[00011b82] 347c 0020                 movea.w   #$0020,a2
[00011b86] 7c0f                      moveq.l   #15,d6
[00011b88] b446                      cmp.w     d6,d2
[00011b8a] 6c02                      bge.s     $00011B8E
[00011b8c] 3c02                      move.w    d2,d6
[00011b8e] 3846                      movea.w   d6,a4
[00011b90] 9446                      sub.w     d6,d2
[00011b92] 5246                      addq.w    #1,d6
[00011b94] dc46                      add.w     d6,d6
[00011b96] 96c6                      suba.w    d6,a3
[00011b98] 4843                      swap      d3
[00011b9a] 3203                      move.w    d3,d1
[00011b9c] e849                      lsr.w     #4,d1
[00011b9e] 2a49                      movea.l   a1,a5
[00011ba0] 3c0c                      move.w    a4,d6
[00011ba2] 3010                      move.w    (a0),d0
[00011ba4] d040                      add.w     d0,d0
[00011ba6] 645e                      bcc.s     $00011C06
[00011ba8] 3802                      move.w    d2,d4
[00011baa] d846                      add.w     d6,d4
[00011bac] e84c                      lsr.w     #4,d4
[00011bae] 3a04                      move.w    d4,d5
[00011bb0] e84c                      lsr.w     #4,d4
[00011bb2] 4645                      not.w     d5
[00011bb4] 0245 000f                 andi.w    #$000F,d5
[00011bb8] da45                      add.w     d5,d5
[00011bba] da45                      add.w     d5,d5
[00011bbc] 2c4d                      movea.l   a5,a6
[00011bbe] 4efb 5002                 jmp       $00011BC2(pc,d5.w)
[00011bc2] 3c87                      move.w    d7,(a6)
[00011bc4] dcca                      adda.w    a2,a6
[00011bc6] 3c87                      move.w    d7,(a6)
[00011bc8] dcca                      adda.w    a2,a6
[00011bca] 3c87                      move.w    d7,(a6)
[00011bcc] dcca                      adda.w    a2,a6
[00011bce] 3c87                      move.w    d7,(a6)
[00011bd0] dcca                      adda.w    a2,a6
[00011bd2] 3c87                      move.w    d7,(a6)
[00011bd4] dcca                      adda.w    a2,a6
[00011bd6] 3c87                      move.w    d7,(a6)
[00011bd8] dcca                      adda.w    a2,a6
[00011bda] 3c87                      move.w    d7,(a6)
[00011bdc] dcca                      adda.w    a2,a6
[00011bde] 3c87                      move.w    d7,(a6)
[00011be0] dcca                      adda.w    a2,a6
[00011be2] 3c87                      move.w    d7,(a6)
[00011be4] dcca                      adda.w    a2,a6
[00011be6] 3c87                      move.w    d7,(a6)
[00011be8] dcca                      adda.w    a2,a6
[00011bea] 3c87                      move.w    d7,(a6)
[00011bec] dcca                      adda.w    a2,a6
[00011bee] 3c87                      move.w    d7,(a6)
[00011bf0] dcca                      adda.w    a2,a6
[00011bf2] 3c87                      move.w    d7,(a6)
[00011bf4] dcca                      adda.w    a2,a6
[00011bf6] 3c87                      move.w    d7,(a6)
[00011bf8] dcca                      adda.w    a2,a6
[00011bfa] 3c87                      move.w    d7,(a6)
[00011bfc] dcca                      adda.w    a2,a6
[00011bfe] 3c87                      move.w    d7,(a6)
[00011c00] dcca                      adda.w    a2,a6
[00011c02] 51cc ffbe                 dbf       d4,$00011BC2
[00011c06] 548d                      addq.l    #2,a5
[00011c08] 51ce ff9a                 dbf       d6,$00011BA4
[00011c0c] dbcb                      adda.l    a3,a5
[00011c0e] 51c9 ff90                 dbf       d1,$00011BA0
[00011c12] 5488                      addq.l    #2,a0
[00011c14] d2d7                      adda.w    (a7),a1
[00011c16] 5343                      subq.w    #1,d3
[00011c18] 4843                      swap      d3
[00011c1a] 51cb ff7c                 dbf       d3,$00011B98
[00011c1e] 548f                      addq.l    #2,a7
[00011c20] 4e75                      rts
[00011c22] 206e 01c2                 movea.l   450(a6),a0
[00011c26] 226e 01d6                 movea.l   470(a6),a1
[00011c2a] 346e 01c6                 movea.w   454(a6),a2
[00011c2e] 366e 01da                 movea.w   474(a6),a3
[00011c32] 026e 0003 01ee            andi.w    #$0003,494(a6)
[00011c38] 3c0a                      move.w    a2,d6
[00011c3a] 3e0b                      move.w    a3,d7
[00011c3c] c3c6                      muls.w    d6,d1
[00011c3e] d1c1                      adda.l    d1,a0
[00011c40] 3200                      move.w    d0,d1
[00011c42] e849                      lsr.w     #4,d1
[00011c44] d241                      add.w     d1,d1
[00011c46] d0c1                      adda.w    d1,a0
[00011c48] c7c7                      muls.w    d7,d3
[00011c4a] d3c3                      adda.l    d3,a1
[00011c4c] d442                      add.w     d2,d2
[00011c4e] d2c2                      adda.w    d2,a1
[00011c50] 720f                      moveq.l   #15,d1
[00011c52] c041                      and.w     d1,d0
[00011c54] b141                      eor.w     d0,d1
[00011c56] b841                      cmp.w     d1,d4
[00011c58] 6c02                      bge.s     $00011C5C
[00011c5a] 3204                      move.w    d4,d1
[00011c5c] 4840                      swap      d0
[00011c5e] 3001                      move.w    d1,d0
[00011c60] 4840                      swap      d0
[00011c62] 3400                      move.w    d0,d2
[00011c64] d444                      add.w     d4,d2
[00011c66] e84a                      lsr.w     #4,d2
[00011c68] d442                      add.w     d2,d2
[00011c6a] 5442                      addq.w    #2,d2
[00011c6c] 94c2                      suba.w    d2,a2
[00011c6e] 3404                      move.w    d4,d2
[00011c70] d442                      add.w     d2,d2
[00011c72] 5442                      addq.w    #2,d2
[00011c74] 96c2                      suba.w    d2,a3
[00011c76] 49ee 0458                 lea.l     1112(a6),a4
[00011c7a] 2a4c                      movea.l   a4,a5
[00011c7c] 3c2e 01ea                 move.w    490(a6),d6
[00011c80] dc46                      add.w     d6,d6
[00011c82] d8c6                      adda.w    d6,a4
[00011c84] 2c14                      move.l    (a4),d6
[00011c86] 3c14                      move.w    (a4),d6
[00011c88] 3e2e 01ec                 move.w    492(a6),d7
[00011c8c] de47                      add.w     d7,d7
[00011c8e] dac7                      adda.w    d7,a5
[00011c90] 2e15                      move.l    (a5),d7
[00011c92] 3e15                      move.w    (a5),d7
[00011c94] 342e 01ee                 move.w    494(a6),d2
[00011c98] d442                      add.w     d2,d2
[00011c9a] 343b 2006                 move.w    $00011CA2(pc,d2.w),d2
[00011c9e] 4efb 2002                 jmp       $00011CA2(pc,d2.w)
J3:
[00011ca2] 0008                      dc.w $0008   ; $00011caa-$00011ca2
[00011ca4] 007c                      dc.w $007c   ; $00011d1e-$00011ca2
[00011ca6] 00e6                      dc.w $00e6   ; $00011d88-$00011ca2
[00011ca8] 0150                      dc.w $0150   ; $00011df2-$00011ca2
[00011caa] 2406                      move.l    d6,d2
[00011cac] 3407                      move.w    d7,d2
[00011cae] 2842                      movea.l   d2,a4
[00011cb0] 2607                      move.l    d7,d3
[00011cb2] 3606                      move.w    d6,d3
[00011cb4] 2a43                      movea.l   d3,a5
[00011cb6] 3604                      move.w    d4,d3
[00011cb8] 3418                      move.w    (a0)+,d2
[00011cba] e17a                      rol.w     d0,d2
[00011cbc] 2200                      move.l    d0,d1
[00011cbe] 4841                      swap      d1
[00011cc0] 6002                      bra.s     $00011CC4
[00011cc2] 3418                      move.w    (a0)+,d2
[00011cc4] 9641                      sub.w     d1,d3
[00011cc6] 5343                      subq.w    #1,d3
[00011cc8] 5441                      addq.w    #2,d1
[00011cca] 600a                      bra.s     $00011CD6
[00011ccc] d442                      add.w     d2,d2
[00011cce] 6418                      bcc.s     $00011CE8
[00011cd0] d442                      add.w     d2,d2
[00011cd2] 640a                      bcc.s     $00011CDE
[00011cd4] 22c6                      move.l    d6,(a1)+
[00011cd6] 5541                      subq.w    #2,d1
[00011cd8] 6ef2                      bgt.s     $00011CCC
[00011cda] 6724                      beq.s     $00011D00
[00011cdc] 602c                      bra.s     $00011D0A
[00011cde] 22cc                      move.l    a4,(a1)+
[00011ce0] 5541                      subq.w    #2,d1
[00011ce2] 6ee8                      bgt.s     $00011CCC
[00011ce4] 671a                      beq.s     $00011D00
[00011ce6] 6022                      bra.s     $00011D0A
[00011ce8] d442                      add.w     d2,d2
[00011cea] 650a                      bcs.s     $00011CF6
[00011cec] 22c7                      move.l    d7,(a1)+
[00011cee] 5541                      subq.w    #2,d1
[00011cf0] 6eda                      bgt.s     $00011CCC
[00011cf2] 670c                      beq.s     $00011D00
[00011cf4] 6014                      bra.s     $00011D0A
[00011cf6] 22cd                      move.l    a5,(a1)+
[00011cf8] 5541                      subq.w    #2,d1
[00011cfa] 6ed0                      bgt.s     $00011CCC
[00011cfc] 6702                      beq.s     $00011D00
[00011cfe] 600a                      bra.s     $00011D0A
[00011d00] d442                      add.w     d2,d2
[00011d02] 6404                      bcc.s     $00011D08
[00011d04] 32c6                      move.w    d6,(a1)+
[00011d06] 6002                      bra.s     $00011D0A
[00011d08] 32c7                      move.w    d7,(a1)+
[00011d0a] 720f                      moveq.l   #15,d1
[00011d0c] b641                      cmp.w     d1,d3
[00011d0e] 6cb2                      bge.s     $00011CC2
[00011d10] 3203                      move.w    d3,d1
[00011d12] 6aae                      bpl.s     $00011CC2
[00011d14] d0ca                      adda.w    a2,a0
[00011d16] d2cb                      adda.w    a3,a1
[00011d18] 51cd ff9c                 dbf       d5,$00011CB6
[00011d1c] 4e75                      rts
[00011d1e] 3604                      move.w    d4,d3
[00011d20] 3418                      move.w    (a0)+,d2
[00011d22] e17a                      rol.w     d0,d2
[00011d24] 2200                      move.l    d0,d1
[00011d26] 4841                      swap      d1
[00011d28] 6002                      bra.s     $00011D2C
[00011d2a] 3418                      move.w    (a0)+,d2
[00011d2c] 9641                      sub.w     d1,d3
[00011d2e] 5343                      subq.w    #1,d3
[00011d30] 5441                      addq.w    #2,d1
[00011d32] 6024                      bra.s     $00011D58
[00011d34] d442                      add.w     d2,d2
[00011d36] 651a                      bcs.s     $00011D52
[00011d38] d442                      add.w     d2,d2
[00011d3a] 650a                      bcs.s     $00011D46
[00011d3c] 5889                      addq.l    #4,a1
[00011d3e] 5541                      subq.w    #2,d1
[00011d40] 6ef2                      bgt.s     $00011D34
[00011d42] 6728                      beq.s     $00011D6C
[00011d44] 602e                      bra.s     $00011D74
[00011d46] 5489                      addq.l    #2,a1
[00011d48] 32c6                      move.w    d6,(a1)+
[00011d4a] 5541                      subq.w    #2,d1
[00011d4c] 6ee6                      bgt.s     $00011D34
[00011d4e] 671c                      beq.s     $00011D6C
[00011d50] 6022                      bra.s     $00011D74
[00011d52] d442                      add.w     d2,d2
[00011d54] 640a                      bcc.s     $00011D60
[00011d56] 22c6                      move.l    d6,(a1)+
[00011d58] 5541                      subq.w    #2,d1
[00011d5a] 6ed8                      bgt.s     $00011D34
[00011d5c] 670e                      beq.s     $00011D6C
[00011d5e] 6014                      bra.s     $00011D74
[00011d60] 32c6                      move.w    d6,(a1)+
[00011d62] 5489                      addq.l    #2,a1
[00011d64] 5541                      subq.w    #2,d1
[00011d66] 6ecc                      bgt.s     $00011D34
[00011d68] 6702                      beq.s     $00011D6C
[00011d6a] 6008                      bra.s     $00011D74
[00011d6c] d442                      add.w     d2,d2
[00011d6e] 6402                      bcc.s     $00011D72
[00011d70] 3286                      move.w    d6,(a1)
[00011d72] 5489                      addq.l    #2,a1
[00011d74] 720f                      moveq.l   #15,d1
[00011d76] b641                      cmp.w     d1,d3
[00011d78] 6cb0                      bge.s     $00011D2A
[00011d7a] 3203                      move.w    d3,d1
[00011d7c] 6aac                      bpl.s     $00011D2A
[00011d7e] d0ca                      adda.w    a2,a0
[00011d80] d2cb                      adda.w    a3,a1
[00011d82] 51cd ff9a                 dbf       d5,$00011D1E
[00011d86] 4e75                      rts
[00011d88] 3604                      move.w    d4,d3
[00011d8a] 3418                      move.w    (a0)+,d2
[00011d8c] e17a                      rol.w     d0,d2
[00011d8e] 2200                      move.l    d0,d1
[00011d90] 4841                      swap      d1
[00011d92] 6002                      bra.s     $00011D96
[00011d94] 3418                      move.w    (a0)+,d2
[00011d96] 9641                      sub.w     d1,d3
[00011d98] 5343                      subq.w    #1,d3
[00011d9a] 5441                      addq.w    #2,d1
[00011d9c] 6024                      bra.s     $00011DC2
[00011d9e] d442                      add.w     d2,d2
[00011da0] 651a                      bcs.s     $00011DBC
[00011da2] d442                      add.w     d2,d2
[00011da4] 650a                      bcs.s     $00011DB0
[00011da6] 5889                      addq.l    #4,a1
[00011da8] 5541                      subq.w    #2,d1
[00011daa] 6ef2                      bgt.s     $00011D9E
[00011dac] 6728                      beq.s     $00011DD6
[00011dae] 602e                      bra.s     $00011DDE
[00011db0] 5489                      addq.l    #2,a1
[00011db2] 4659                      not.w     (a1)+
[00011db4] 5541                      subq.w    #2,d1
[00011db6] 6ee6                      bgt.s     $00011D9E
[00011db8] 671c                      beq.s     $00011DD6
[00011dba] 6022                      bra.s     $00011DDE
[00011dbc] d442                      add.w     d2,d2
[00011dbe] 640a                      bcc.s     $00011DCA
[00011dc0] 4699                      not.l     (a1)+
[00011dc2] 5541                      subq.w    #2,d1
[00011dc4] 6ed8                      bgt.s     $00011D9E
[00011dc6] 670e                      beq.s     $00011DD6
[00011dc8] 6014                      bra.s     $00011DDE
[00011dca] 4659                      not.w     (a1)+
[00011dcc] 5489                      addq.l    #2,a1
[00011dce] 5541                      subq.w    #2,d1
[00011dd0] 6ecc                      bgt.s     $00011D9E
[00011dd2] 6702                      beq.s     $00011DD6
[00011dd4] 6008                      bra.s     $00011DDE
[00011dd6] d442                      add.w     d2,d2
[00011dd8] 6402                      bcc.s     $00011DDC
[00011dda] 4651                      not.w     (a1)
[00011ddc] 5489                      addq.l    #2,a1
[00011dde] 720f                      moveq.l   #15,d1
[00011de0] b641                      cmp.w     d1,d3
[00011de2] 6cb0                      bge.s     $00011D94
[00011de4] 3203                      move.w    d3,d1
[00011de6] 6aac                      bpl.s     $00011D94
[00011de8] d0ca                      adda.w    a2,a0
[00011dea] d2cb                      adda.w    a3,a1
[00011dec] 51cd ff9a                 dbf       d5,$00011D88
[00011df0] 4e75                      rts
[00011df2] 3604                      move.w    d4,d3
[00011df4] 3418                      move.w    (a0)+,d2
[00011df6] e17a                      rol.w     d0,d2
[00011df8] 2200                      move.l    d0,d1
[00011dfa] 4841                      swap      d1
[00011dfc] 6002                      bra.s     $00011E00
[00011dfe] 3418                      move.w    (a0)+,d2
[00011e00] 9641                      sub.w     d1,d3
[00011e02] 5343                      subq.w    #1,d3
[00011e04] 5441                      addq.w    #2,d1
[00011e06] 600a                      bra.s     $00011E12
[00011e08] d442                      add.w     d2,d2
[00011e0a] 651a                      bcs.s     $00011E26
[00011e0c] d442                      add.w     d2,d2
[00011e0e] 650a                      bcs.s     $00011E1A
[00011e10] 22c7                      move.l    d7,(a1)+
[00011e12] 5541                      subq.w    #2,d1
[00011e14] 6ef2                      bgt.s     $00011E08
[00011e16] 6728                      beq.s     $00011E40
[00011e18] 602e                      bra.s     $00011E48
[00011e1a] 32c7                      move.w    d7,(a1)+
[00011e1c] 5489                      addq.l    #2,a1
[00011e1e] 5541                      subq.w    #2,d1
[00011e20] 6ee6                      bgt.s     $00011E08
[00011e22] 671c                      beq.s     $00011E40
[00011e24] 6022                      bra.s     $00011E48
[00011e26] d442                      add.w     d2,d2
[00011e28] 640a                      bcc.s     $00011E34
[00011e2a] 5889                      addq.l    #4,a1
[00011e2c] 5541                      subq.w    #2,d1
[00011e2e] 6ed8                      bgt.s     $00011E08
[00011e30] 670e                      beq.s     $00011E40
[00011e32] 6014                      bra.s     $00011E48
[00011e34] 5489                      addq.l    #2,a1
[00011e36] 32c7                      move.w    d7,(a1)+
[00011e38] 5541                      subq.w    #2,d1
[00011e3a] 6ecc                      bgt.s     $00011E08
[00011e3c] 6702                      beq.s     $00011E40
[00011e3e] 6008                      bra.s     $00011E48
[00011e40] d442                      add.w     d2,d2
[00011e42] 6502                      bcs.s     $00011E46
[00011e44] 3287                      move.w    d7,(a1)
[00011e46] 5489                      addq.l    #2,a1
[00011e48] 720f                      moveq.l   #15,d1
[00011e4a] b641                      cmp.w     d1,d3
[00011e4c] 6cb0                      bge.s     $00011DFE
[00011e4e] 3203                      move.w    d3,d1
[00011e50] 6aac                      bpl.s     $00011DFE
[00011e52] d0ca                      adda.w    a2,a0
[00011e54] d2cb                      adda.w    a3,a1
[00011e56] 51cd ff9a                 dbf       d5,$00011DF2
[00011e5a] 4e75                      rts
[00011e5c] 4e75                      rts
[00011e5e] bc44                      cmp.w     d4,d6
[00011e60] be45                      cmp.w     d5,d7
[00011e62] 08ae 0004 01ef            bclr      #4,495(a6)
[00011e68] 6600 fdb8                 bne       $00011C22
[00011e6c] 7e0f                      moveq.l   #15,d7
[00011e6e] ce6e 01ee                 and.w     494(a6),d7
[00011e72] 206e 01c2                 movea.l   450(a6),a0
[00011e76] 226e 01d6                 movea.l   470(a6),a1
[00011e7a] 346e 01c6                 movea.w   454(a6),a2
[00011e7e] 366e 01da                 movea.w   474(a6),a3
[00011e82] 3c2e 01c8                 move.w    456(a6),d6
[00011e86] bc6e 01dc                 cmp.w     476(a6),d6
[00011e8a] 66d0                      bne.s     $00011E5C
[00011e8c] 0446 000f                 subi.w    #$000F,d6
[00011e90] 66ca                      bne.s     $00011E5C
[00011e92] 48c0                      ext.l     d0
[00011e94] 48c2                      ext.l     d2
[00011e96] 3c0a                      move.w    a2,d6
[00011e98] c2c6                      mulu.w    d6,d1
[00011e9a] d280                      add.l     d0,d1
[00011e9c] d280                      add.l     d0,d1
[00011e9e] d1c1                      adda.l    d1,a0
[00011ea0] 3c0b                      move.w    a3,d6
[00011ea2] c6c6                      mulu.w    d6,d3
[00011ea4] d682                      add.l     d2,d3
[00011ea6] d682                      add.l     d2,d3
[00011ea8] d3c3                      adda.l    d3,a1
[00011eaa] b1c9                      cmpa.l    a1,a0
[00011eac] 6200 0350                 bhi       $000121FE
[00011eb0] 3c3c 8401                 move.w    #$8401,d6
[00011eb4] 0f06                      btst      d7,d6
[00011eb6] 6600 0346                 bne       $000121FE
[00011eba] 3c0a                      move.w    a2,d6
[00011ebc] ccc5                      mulu.w    d5,d6
[00011ebe] 2848                      movea.l   a0,a4
[00011ec0] d9c6                      adda.l    d6,a4
[00011ec2] d8c4                      adda.w    d4,a4
[00011ec4] d8c4                      adda.w    d4,a4
[00011ec6] b9c9                      cmpa.l    a1,a4
[00011ec8] 6500 0334                 bcs       $000121FE
[00011ecc] 548c                      addq.l    #2,a4
[00011ece] d28c                      add.l     a4,d1
[00011ed0] 9288                      sub.l     a0,d1
[00011ed2] 2a49                      movea.l   a1,a5
[00011ed4] 3c0b                      move.w    a3,d6
[00011ed6] ccc5                      mulu.w    d5,d6
[00011ed8] dbc6                      adda.l    d6,a5
[00011eda] dac4                      adda.w    d4,a5
[00011edc] dac4                      adda.w    d4,a5
[00011ede] 548d                      addq.l    #2,a5
[00011ee0] d68d                      add.l     a5,d3
[00011ee2] 9689                      sub.l     a1,d3
[00011ee4] c14c                      exg       a0,a4
[00011ee6] c34d                      exg       a1,a5
[00011ee8] 3c04                      move.w    d4,d6
[00011eea] 5246                      addq.w    #1,d6
[00011eec] dc46                      add.w     d6,d6
[00011eee] 94c6                      suba.w    d6,a2
[00011ef0] 96c6                      suba.w    d6,a3
[00011ef2] 7002                      moveq.l   #2,d0
[00011ef4] 0804 0000                 btst      #0,d4
[00011ef8] 6604                      bne.s     $00011EFE
[00011efa] 7000                      moveq.l   #0,d0
[00011efc] 5344                      subq.w    #1,d4
[00011efe] 7206                      moveq.l   #6,d1
[00011f00] c244                      and.w     d4,d1
[00011f02] 0a41 0006                 eori.w    #$0006,d1
[00011f06] e644                      asr.w     #3,d4
[00011f08] 4a44                      tst.w     d4
[00011f0a] 6a04                      bpl.s     $00011F10
[00011f0c] 7800                      moveq.l   #0,d4
[00011f0e] 7208                      moveq.l   #8,d1
[00011f10] de47                      add.w     d7,d7
[00011f12] de47                      add.w     d7,d7
[00011f14] 49fb 7022                 lea.l     $00011F38(pc,d7.w),a4
[00011f18] 3e1c                      move.w    (a4)+,d7
[00011f1a] 6716                      beq.s     $00011F32
[00011f1c] 5347                      subq.w    #1,d7
[00011f1e] 670e                      beq.s     $00011F2E
[00011f20] 3e00                      move.w    d0,d7
[00011f22] d040                      add.w     d0,d0
[00011f24] d047                      add.w     d7,d0
[00011f26] 3e01                      move.w    d1,d7
[00011f28] d241                      add.w     d1,d1
[00011f2a] d247                      add.w     d7,d1
[00011f2c] 6004                      bra.s     $00011F32
[00011f2e] d040                      add.w     d0,d0
[00011f30] d241                      add.w     d1,d1
[00011f32] 3e1c                      move.w    (a4)+,d7
[00011f34] 4efb 7002                 jmp       $00011F38(pc,d7.w)
[00011f38] 0000 040a                 ori.b     #$0A,d0
[00011f3c] 0001 0040                 ori.b     #$40,d1
[00011f40] 0002 0070                 ori.b     #$70,d2
[00011f44] 0000 00aa                 ori.b     #$AA,d0
[00011f48] 0002 00d0                 ori.b     #$D0,d2
[00011f4c] 0000 0108                 ori.b     #$08,d0
[00011f50] 0001 010a                 ori.b     #$0A,d1
[00011f54] 0001 013a                 ori.b     #$3A,d1
[00011f58] 0002 016a                 ori.b     #$6A,d2
[00011f5c] 0002 01a4                 ori.b     #$A4,d2
[00011f60] 0000 05ce                 ori.b     #$CE,d0
[00011f64] 0002 01de                 ori.b     #$DE,d2
[00011f68] 0002 0218                 ori.b     #$18,d2
[00011f6c] 0002 0252                 ori.b     #$52,d2
[00011f70] 0002 028c                 ori.b     #$8C,d2
[00011f74] 0000 0406                 ori.b     #$06,d0
[00011f78] 49fb 2008                 lea.l     $00011F82(pc,d2.w),a4
[00011f7c] 4bfb 100c                 lea.l     $00011F8A(pc,d1.w),a5
[00011f80] 4ed4                      jmp       (a4)
[00011f82] 3020                      move.w    -(a0),d0
[00011f84] c161                      and.w     d0,-(a1)
[00011f86] 3c04                      move.w    d4,d6
[00011f88] 4ed5                      jmp       (a5)
[00011f8a] 2020                      move.l    -(a0),d0
[00011f8c] c1a1                      and.l     d0,-(a1)
[00011f8e] 2020                      move.l    -(a0),d0
[00011f90] c1a1                      and.l     d0,-(a1)
[00011f92] 2020                      move.l    -(a0),d0
[00011f94] c1a1                      and.l     d0,-(a1)
[00011f96] 2020                      move.l    -(a0),d0
[00011f98] c1a1                      and.l     d0,-(a1)
[00011f9a] 51ce ffee                 dbf       d6,$00011F8A
[00011f9e] 90ca                      suba.w    a2,a0
[00011fa0] 92cb                      suba.w    a3,a1
[00011fa2] 51cd ffdc                 dbf       d5,$00011F80
[00011fa6] 4e75                      rts
[00011fa8] 49fb 0008                 lea.l     $00011FB2(pc,d0.w),a4
[00011fac] 4bfb 100e                 lea.l     $00011FBC(pc,d1.w),a5
[00011fb0] 4ed4                      jmp       (a4)
[00011fb2] 3020                      move.w    -(a0),d0
[00011fb4] 4651                      not.w     (a1)
[00011fb6] c161                      and.w     d0,-(a1)
[00011fb8] 3c04                      move.w    d4,d6
[00011fba] 4ed5                      jmp       (a5)
[00011fbc] 2020                      move.l    -(a0),d0
[00011fbe] 4691                      not.l     (a1)
[00011fc0] c1a1                      and.l     d0,-(a1)
[00011fc2] 2020                      move.l    -(a0),d0
[00011fc4] 4691                      not.l     (a1)
[00011fc6] c1a1                      and.l     d0,-(a1)
[00011fc8] 2020                      move.l    -(a0),d0
[00011fca] 4691                      not.l     (a1)
[00011fcc] c1a1                      and.l     d0,-(a1)
[00011fce] 2020                      move.l    -(a0),d0
[00011fd0] 4691                      not.l     (a1)
[00011fd2] c1a1                      and.l     d0,-(a1)
[00011fd4] 51ce ffe6                 dbf       d6,$00011FBC
[00011fd8] 90ca                      suba.w    a2,a0
[00011fda] 92cb                      suba.w    a3,a1
[00011fdc] 51cd ffd2                 dbf       d5,$00011FB0
[00011fe0] 4e75                      rts
[00011fe2] 49fb 0008                 lea.l     $00011FEC(pc,d0.w),a4
[00011fe6] 4bfb 100a                 lea.l     $00011FF2(pc,d1.w),a5
[00011fea] 4ed4                      jmp       (a4)
[00011fec] 3320                      move.w    -(a0),-(a1)
[00011fee] 3c04                      move.w    d4,d6
[00011ff0] 4ed5                      jmp       (a5)
[00011ff2] 2320                      move.l    -(a0),-(a1)
[00011ff4] 2320                      move.l    -(a0),-(a1)
[00011ff6] 2320                      move.l    -(a0),-(a1)
[00011ff8] 2320                      move.l    -(a0),-(a1)
[00011ffa] 51ce fff6                 dbf       d6,$00011FF2
[00011ffe] 90ca                      suba.w    a2,a0
[00012000] 92cb                      suba.w    a3,a1
[00012002] 51cd ffe6                 dbf       d5,$00011FEA
[00012006] 4e75                      rts
[00012008] 49fb 0008                 lea.l     $00012012(pc,d0.w),a4
[0001200c] 4bfb 100e                 lea.l     $0001201C(pc,d1.w),a5
[00012010] 4ed4                      jmp       (a4)
[00012012] 3020                      move.w    -(a0),d0
[00012014] 4640                      not.w     d0
[00012016] c161                      and.w     d0,-(a1)
[00012018] 3c04                      move.w    d4,d6
[0001201a] 4ed5                      jmp       (a5)
[0001201c] 2020                      move.l    -(a0),d0
[0001201e] 4680                      not.l     d0
[00012020] c1a1                      and.l     d0,-(a1)
[00012022] 2020                      move.l    -(a0),d0
[00012024] 4680                      not.l     d0
[00012026] c1a1                      and.l     d0,-(a1)
[00012028] 2020                      move.l    -(a0),d0
[0001202a] 4680                      not.l     d0
[0001202c] c1a1                      and.l     d0,-(a1)
[0001202e] 2020                      move.l    -(a0),d0
[00012030] 4680                      not.l     d0
[00012032] c1a1                      and.l     d0,-(a1)
[00012034] 51ce ffe6                 dbf       d6,$0001201C
[00012038] 90ca                      suba.w    a2,a0
[0001203a] 92cb                      suba.w    a3,a1
[0001203c] 51cd ffd2                 dbf       d5,$00012010
[00012040] 4e75                      rts
[00012042] 49fb 0008                 lea.l     $0001204C(pc,d0.w),a4
[00012046] 4bfb 100c                 lea.l     $00012054(pc,d1.w),a5
[0001204a] 4ed4                      jmp       (a4)
[0001204c] 3020                      move.w    -(a0),d0
[0001204e] b161                      eor.w     d0,-(a1)
[00012050] 3c04                      move.w    d4,d6
[00012052] 4ed5                      jmp       (a5)
[00012054] 2020                      move.l    -(a0),d0
[00012056] b1a1                      eor.l     d0,-(a1)
[00012058] 2020                      move.l    -(a0),d0
[0001205a] b1a1                      eor.l     d0,-(a1)
[0001205c] 2020                      move.l    -(a0),d0
[0001205e] b1a1                      eor.l     d0,-(a1)
[00012060] 2020                      move.l    -(a0),d0
[00012062] b1a1                      eor.l     d0,-(a1)
[00012064] 51ce ffee                 dbf       d6,$00012054
[00012068] 90ca                      suba.w    a2,a0
[0001206a] 92cb                      suba.w    a3,a1
[0001206c] 51cd ffdc                 dbf       d5,$0001204A
[00012070] 4e75                      rts
[00012072] 49fb 0008                 lea.l     $0001207C(pc,d0.w),a4
[00012076] 4bfb 100c                 lea.l     $00012084(pc,d1.w),a5
[0001207a] 4ed4                      jmp       (a4)
[0001207c] 3020                      move.w    -(a0),d0
[0001207e] 8161                      or.w      d0,-(a1)
[00012080] 3c04                      move.w    d4,d6
[00012082] 4ed5                      jmp       (a5)
[00012084] 2020                      move.l    -(a0),d0
[00012086] 81a1                      or.l      d0,-(a1)
[00012088] 2020                      move.l    -(a0),d0
[0001208a] 81a1                      or.l      d0,-(a1)
[0001208c] 2020                      move.l    -(a0),d0
[0001208e] 81a1                      or.l      d0,-(a1)
[00012090] 2020                      move.l    -(a0),d0
[00012092] 81a1                      or.l      d0,-(a1)
[00012094] 51ce ffee                 dbf       d6,$00012084
[00012098] 90ca                      suba.w    a2,a0
[0001209a] 92cb                      suba.w    a3,a1
[0001209c] 51cd ffdc                 dbf       d5,$0001207A
[000120a0] 4e75                      rts
[000120a2] 49fb 0008                 lea.l     $000120AC(pc,d0.w),a4
[000120a6] 4bfb 100e                 lea.l     $000120B6(pc,d1.w),a5
[000120aa] 4ed4                      jmp       (a4)
[000120ac] 3020                      move.w    -(a0),d0
[000120ae] 8151                      or.w      d0,(a1)
[000120b0] 4661                      not.w     -(a1)
[000120b2] 3c04                      move.w    d4,d6
[000120b4] 4ed5                      jmp       (a5)
[000120b6] 2020                      move.l    -(a0),d0
[000120b8] 8191                      or.l      d0,(a1)
[000120ba] 46a1                      not.l     -(a1)
[000120bc] 2020                      move.l    -(a0),d0
[000120be] 8191                      or.l      d0,(a1)
[000120c0] 46a1                      not.l     -(a1)
[000120c2] 2020                      move.l    -(a0),d0
[000120c4] 8191                      or.l      d0,(a1)
[000120c6] 46a1                      not.l     -(a1)
[000120c8] 2020                      move.l    -(a0),d0
[000120ca] 8191                      or.l      d0,(a1)
[000120cc] 46a1                      not.l     -(a1)
[000120ce] 51ce ffe6                 dbf       d6,$000120B6
[000120d2] 90ca                      suba.w    a2,a0
[000120d4] 92cb                      suba.w    a3,a1
[000120d6] 51cd ffd2                 dbf       d5,$000120AA
[000120da] 4e75                      rts
[000120dc] 49fb 0008                 lea.l     $000120E6(pc,d0.w),a4
[000120e0] 4bfb 100e                 lea.l     $000120F0(pc,d1.w),a5
[000120e4] 4ed4                      jmp       (a4)
[000120e6] 3020                      move.w    -(a0),d0
[000120e8] b151                      eor.w     d0,(a1)
[000120ea] 4661                      not.w     -(a1)
[000120ec] 3c04                      move.w    d4,d6
[000120ee] 4ed5                      jmp       (a5)
[000120f0] 2020                      move.l    -(a0),d0
[000120f2] b191                      eor.l     d0,(a1)
[000120f4] 46a1                      not.l     -(a1)
[000120f6] 2020                      move.l    -(a0),d0
[000120f8] b191                      eor.l     d0,(a1)
[000120fa] 46a1                      not.l     -(a1)
[000120fc] 2020                      move.l    -(a0),d0
[000120fe] b191                      eor.l     d0,(a1)
[00012100] 46a1                      not.l     -(a1)
[00012102] 2020                      move.l    -(a0),d0
[00012104] b191                      eor.l     d0,(a1)
[00012106] 46a1                      not.l     -(a1)
[00012108] 51ce ffe6                 dbf       d6,$000120F0
[0001210c] 90ca                      suba.w    a2,a0
[0001210e] 92cb                      suba.w    a3,a1
[00012110] 51cd ffd2                 dbf       d5,$000120E4
[00012114] 4e75                      rts
[00012116] 49fb 0008                 lea.l     $00012120(pc,d0.w),a4
[0001211a] 4bfb 100e                 lea.l     $0001212A(pc,d1.w),a5
[0001211e] 4ed4                      jmp       (a4)
[00012120] 4651                      not.w     (a1)
[00012122] 3020                      move.w    -(a0),d0
[00012124] 8161                      or.w      d0,-(a1)
[00012126] 3c04                      move.w    d4,d6
[00012128] 4ed5                      jmp       (a5)
[0001212a] 4691                      not.l     (a1)
[0001212c] 2020                      move.l    -(a0),d0
[0001212e] 81a1                      or.l      d0,-(a1)
[00012130] 4691                      not.l     (a1)
[00012132] 2020                      move.l    -(a0),d0
[00012134] 81a1                      or.l      d0,-(a1)
[00012136] 4691                      not.l     (a1)
[00012138] 2020                      move.l    -(a0),d0
[0001213a] 81a1                      or.l      d0,-(a1)
[0001213c] 4691                      not.l     (a1)
[0001213e] 2020                      move.l    -(a0),d0
[00012140] 81a1                      or.l      d0,-(a1)
[00012142] 51ce ffe6                 dbf       d6,$0001212A
[00012146] 90ca                      suba.w    a2,a0
[00012148] 92cb                      suba.w    a3,a1
[0001214a] 51cd ffd2                 dbf       d5,$0001211E
[0001214e] 4e75                      rts
[00012150] 49fb 0008                 lea.l     $0001215A(pc,d0.w),a4
[00012154] 4bfb 100e                 lea.l     $00012164(pc,d1.w),a5
[00012158] 4ed4                      jmp       (a4)
[0001215a] 3020                      move.w    -(a0),d0
[0001215c] 4640                      not.w     d0
[0001215e] 3300                      move.w    d0,-(a1)
[00012160] 3c04                      move.w    d4,d6
[00012162] 4ed5                      jmp       (a5)
[00012164] 2020                      move.l    -(a0),d0
[00012166] 4680                      not.l     d0
[00012168] 2300                      move.l    d0,-(a1)
[0001216a] 2020                      move.l    -(a0),d0
[0001216c] 4680                      not.l     d0
[0001216e] 2300                      move.l    d0,-(a1)
[00012170] 2020                      move.l    -(a0),d0
[00012172] 4680                      not.l     d0
[00012174] 2300                      move.l    d0,-(a1)
[00012176] 2020                      move.l    -(a0),d0
[00012178] 4680                      not.l     d0
[0001217a] 2300                      move.l    d0,-(a1)
[0001217c] 51ce ffe6                 dbf       d6,$00012164
[00012180] 90ca                      suba.w    a2,a0
[00012182] 92cb                      suba.w    a3,a1
[00012184] 51cd ffd2                 dbf       d5,$00012158
[00012188] 4e75                      rts
[0001218a] 49fb 0008                 lea.l     $00012194(pc,d0.w),a4
[0001218e] 4bfb 100e                 lea.l     $0001219E(pc,d1.w),a5
[00012192] 4ed4                      jmp       (a4)
[00012194] 3020                      move.w    -(a0),d0
[00012196] 4640                      not.w     d0
[00012198] 8161                      or.w      d0,-(a1)
[0001219a] 3c04                      move.w    d4,d6
[0001219c] 4ed5                      jmp       (a5)
[0001219e] 2020                      move.l    -(a0),d0
[000121a0] 4680                      not.l     d0
[000121a2] 81a1                      or.l      d0,-(a1)
[000121a4] 2020                      move.l    -(a0),d0
[000121a6] 4680                      not.l     d0
[000121a8] 81a1                      or.l      d0,-(a1)
[000121aa] 2020                      move.l    -(a0),d0
[000121ac] 4680                      not.l     d0
[000121ae] 81a1                      or.l      d0,-(a1)
[000121b0] 2020                      move.l    -(a0),d0
[000121b2] 4680                      not.l     d0
[000121b4] 81a1                      or.l      d0,-(a1)
[000121b6] 51ce ffe6                 dbf       d6,$0001219E
[000121ba] 90ca                      suba.w    a2,a0
[000121bc] 92cb                      suba.w    a3,a1
[000121be] 51cd ffd2                 dbf       d5,$00012192
[000121c2] 4e75                      rts
[000121c4] 49fb 0008                 lea.l     $000121CE(pc,d0.w),a4
[000121c8] 4bfb 100e                 lea.l     $000121D8(pc,d1.w),a5
[000121cc] 4ed4                      jmp       (a4)
[000121ce] 3020                      move.w    -(a0),d0
[000121d0] c151                      and.w     d0,(a1)
[000121d2] 4661                      not.w     -(a1)
[000121d4] 3c04                      move.w    d4,d6
[000121d6] 4ed5                      jmp       (a5)
[000121d8] 2020                      move.l    -(a0),d0
[000121da] c191                      and.l     d0,(a1)
[000121dc] 46a1                      not.l     -(a1)
[000121de] 2020                      move.l    -(a0),d0
[000121e0] c191                      and.l     d0,(a1)
[000121e2] 46a1                      not.l     -(a1)
[000121e4] 2020                      move.l    -(a0),d0
[000121e6] c191                      and.l     d0,(a1)
[000121e8] 46a1                      not.l     -(a1)
[000121ea] 2020                      move.l    -(a0),d0
[000121ec] c191                      and.l     d0,(a1)
[000121ee] 46a1                      not.l     -(a1)
[000121f0] 51ce ffe6                 dbf       d6,$000121D8
[000121f4] 90ca                      suba.w    a2,a0
[000121f6] 92cb                      suba.w    a3,a1
[000121f8] 51cd ffd2                 dbf       d5,$000121CC
[000121fc] 4e75                      rts
[000121fe] be7c 0003                 cmp.w     #$0003,d7
[00012202] 6600 00aa                 bne       $000122AE
[00012206] 323a 0482                 move.w    $0001268A(pc),d1
[0001220a] 6700 00a2                 beq       $000122AE
[0001220e] b87c 001f                 cmp.w     #$001F,d4
[00012212] 6f00 009a                 ble       $000122AE
[00012216] 7c0f                      moveq.l   #15,d6
[00012218] 3208                      move.w    a0,d1
[0001221a] 3609                      move.w    a1,d3
[0001221c] c246                      and.w     d6,d1
[0001221e] c646                      and.w     d6,d3
[00012220] b641                      cmp.w     d1,d3
[00012222] 6600 008a                 bne       $000122AE
[00012226] 3e04                      move.w    d4,d7
[00012228] 5247                      addq.w    #1,d7
[0001222a] de47                      add.w     d7,d7
[0001222c] 94c7                      suba.w    d7,a2
[0001222e] 96c7                      suba.w    d7,a3
[00012230] 7c07                      moveq.l   #7,d6
[00012232] e249                      lsr.w     #1,d1
[00012234] 3001                      move.w    d1,d0
[00012236] 6604                      bne.s     $0001223C
[00012238] 70ff                      moveq.l   #-1,d0
[0001223a] 6008                      bra.s     $00012244
[0001223c] 4640                      not.w     d0
[0001223e] c046                      and.w     d6,d0
[00012240] 9840                      sub.w     d0,d4
[00012242] 5344                      subq.w    #1,d4
[00012244] 3404                      move.w    d4,d2
[00012246] e64c                      lsr.w     #3,d4
[00012248] 5344                      subq.w    #1,d4
[0001224a] c446                      and.w     d6,d2
[0001224c] b446                      cmp.w     d6,d2
[0001224e] 6636                      bne.s     $00012286
[00012250] 74ff                      moveq.l   #-1,d2
[00012252] 5244                      addq.w    #1,d4
[00012254] b440                      cmp.w     d0,d2
[00012256] 662e                      bne.s     $00012286
[00012258] 5245                      addq.w    #1,d5
[0001225a] 6010                      bra.s     $0001226C
[0001225c] 0000 0000                 ori.b     #$00,d0
[00012260] f620 9000                 move16    (a0)+,(a1)+
[00012264] 51ce fffa                 dbf       d6,$00012260
[00012268] d0ca                      adda.w    a2,a0
[0001226a] d2cb                      adda.w    a3,a1
[0001226c] 3c04                      move.w    d4,d6
[0001226e] 51cd fff0                 dbf       d5,$00012260
[00012272] 4e75                      rts
[00012274] 0000 0000                 ori.b     #$00,d0
[00012278] 0000 0000                 ori.b     #$00,d0
[0001227c] 0000 0000                 ori.b     #$00,d0
[00012280] 4e71                      nop
[00012282] 4e71                      nop
[00012284] 4e71                      nop
[00012286] 3c00                      move.w    d0,d6
[00012288] 6b06                      bmi.s     $00012290
[0001228a] 32d8                      move.w    (a0)+,(a1)+
[0001228c] 51ce fffc                 dbf       d6,$0001228A
[00012290] 3c04                      move.w    d4,d6
[00012292] f620 9000                 move16    (a0)+,(a1)+
[00012296] 51ce fffa                 dbf       d6,$00012292
[0001229a] 3c02                      move.w    d2,d6
[0001229c] 6b06                      bmi.s     $000122A4
[0001229e] 32d8                      move.w    (a0)+,(a1)+
[000122a0] 51ce fffc                 dbf       d6,$0001229E
[000122a4] d0ca                      adda.w    a2,a0
[000122a6] d2cb                      adda.w    a3,a1
[000122a8] 51cd ffdc                 dbf       d5,$00012286
[000122ac] 4e75                      rts
[000122ae] 3c04                      move.w    d4,d6
[000122b0] 5246                      addq.w    #1,d6
[000122b2] dc46                      add.w     d6,d6
[000122b4] 94c6                      suba.w    d6,a2
[000122b6] 96c6                      suba.w    d6,a3
[000122b8] 7002                      moveq.l   #2,d0
[000122ba] 0804 0000                 btst      #0,d4
[000122be] 6604                      bne.s     $000122C4
[000122c0] 7000                      moveq.l   #0,d0
[000122c2] 5344                      subq.w    #1,d4
[000122c4] 7206                      moveq.l   #6,d1
[000122c6] c244                      and.w     d4,d1
[000122c8] 0a41 0006                 eori.w    #$0006,d1
[000122cc] e644                      asr.w     #3,d4
[000122ce] 4a44                      tst.w     d4
[000122d0] 6a04                      bpl.s     $000122D6
[000122d2] 7800                      moveq.l   #0,d4
[000122d4] 7208                      moveq.l   #8,d1
[000122d6] de47                      add.w     d7,d7
[000122d8] de47                      add.w     d7,d7
[000122da] 49fb 7022                 lea.l     $000122FE(pc,d7.w),a4
[000122de] 3e1c                      move.w    (a4)+,d7
[000122e0] 6716                      beq.s     $000122F8
[000122e2] 5347                      subq.w    #1,d7
[000122e4] 670e                      beq.s     $000122F4
[000122e6] 3e00                      move.w    d0,d7
[000122e8] d040                      add.w     d0,d0
[000122ea] d047                      add.w     d7,d0
[000122ec] 3e01                      move.w    d1,d7
[000122ee] d241                      add.w     d1,d1
[000122f0] d247                      add.w     d7,d1
[000122f2] 6004                      bra.s     $000122F8
[000122f4] d040                      add.w     d0,d0
[000122f6] d241                      add.w     d1,d1
[000122f8] 3e1c                      move.w    (a4)+,d7
[000122fa] 4efb 7002                 jmp       $000122FE(pc,d7.w)
[000122fe] 0000 0044                 ori.b     #$44,d0
[00012302] 0001 006a                 ori.b     #$6A,d1
[00012306] 0002 009a                 ori.b     #$9A,d2
[0001230a] 0000 00d4                 ori.b     #$D4,d0
[0001230e] 0002 00fa                 ori.b     #$FA,d2
[00012312] 0000 fd42                 ori.b     #$42,d0
[00012316] 0001 0134                 ori.b     #$34,d1
[0001231a] 0001 0164                 ori.b     #$64,d1
[0001231e] 0002 0194                 ori.b     #$94,d2
[00012322] 0002 01ce                 ori.b     #$CE,d2
[00012326] 0000 0208                 ori.b     #$08,d0
[0001232a] 0002 022c                 ori.b     #$2C,d2
[0001232e] 0002 0266                 ori.b     #$66,d2
[00012332] 0002 02a0                 ori.b     #$A0,d2
[00012336] 0002 02da                 ori.b     #$DA,d2
[0001233a] 0000 0040                 ori.b     #$40,d0
[0001233e] 7eff                      moveq.l   #-1,d7
[00012340] 6002                      bra.s     $00012344
[00012342] 7e00                      moveq.l   #0,d7
[00012344] 49fb 0008                 lea.l     $0001234E(pc,d0.w),a4
[00012348] 4bfb 100a                 lea.l     $00012354(pc,d1.w),a5
[0001234c] 4ed4                      jmp       (a4)
[0001234e] 32c7                      move.w    d7,(a1)+
[00012350] 3c04                      move.w    d4,d6
[00012352] 4ed5                      jmp       (a5)
[00012354] 22c7                      move.l    d7,(a1)+
[00012356] 22c7                      move.l    d7,(a1)+
[00012358] 22c7                      move.l    d7,(a1)+
[0001235a] 22c7                      move.l    d7,(a1)+
[0001235c] 51ce fff6                 dbf       d6,$00012354
[00012360] d2cb                      adda.w    a3,a1
[00012362] 51cd ffe8                 dbf       d5,$0001234C
[00012366] 4e75                      rts
[00012368] 49fb 0008                 lea.l     $00012372(pc,d0.w),a4
[0001236c] 4bfb 100c                 lea.l     $0001237A(pc,d1.w),a5
[00012370] 4ed4                      jmp       (a4)
[00012372] 3018                      move.w    (a0)+,d0
[00012374] c159                      and.w     d0,(a1)+
[00012376] 3c04                      move.w    d4,d6
[00012378] 4ed5                      jmp       (a5)
[0001237a] 2018                      move.l    (a0)+,d0
[0001237c] c199                      and.l     d0,(a1)+
[0001237e] 2018                      move.l    (a0)+,d0
[00012380] c199                      and.l     d0,(a1)+
[00012382] 2018                      move.l    (a0)+,d0
[00012384] c199                      and.l     d0,(a1)+
[00012386] 2018                      move.l    (a0)+,d0
[00012388] c199                      and.l     d0,(a1)+
[0001238a] 51ce ffee                 dbf       d6,$0001237A
[0001238e] d0ca                      adda.w    a2,a0
[00012390] d2cb                      adda.w    a3,a1
[00012392] 51cd ffdc                 dbf       d5,$00012370
[00012396] 4e75                      rts
[00012398] 49fb 0008                 lea.l     $000123A2(pc,d0.w),a4
[0001239c] 4bfb 100e                 lea.l     $000123AC(pc,d1.w),a5
[000123a0] 4ed4                      jmp       (a4)
[000123a2] 3018                      move.w    (a0)+,d0
[000123a4] 4651                      not.w     (a1)
[000123a6] c159                      and.w     d0,(a1)+
[000123a8] 3c04                      move.w    d4,d6
[000123aa] 4ed5                      jmp       (a5)
[000123ac] 2018                      move.l    (a0)+,d0
[000123ae] 4691                      not.l     (a1)
[000123b0] c199                      and.l     d0,(a1)+
[000123b2] 2018                      move.l    (a0)+,d0
[000123b4] 4691                      not.l     (a1)
[000123b6] c199                      and.l     d0,(a1)+
[000123b8] 2018                      move.l    (a0)+,d0
[000123ba] 4691                      not.l     (a1)
[000123bc] c199                      and.l     d0,(a1)+
[000123be] 2018                      move.l    (a0)+,d0
[000123c0] 4691                      not.l     (a1)
[000123c2] c199                      and.l     d0,(a1)+
[000123c4] 51ce ffe6                 dbf       d6,$000123AC
[000123c8] d0ca                      adda.w    a2,a0
[000123ca] d2cb                      adda.w    a3,a1
[000123cc] 51cd ffd2                 dbf       d5,$000123A0
[000123d0] 4e75                      rts
[000123d2] 49fb 0008                 lea.l     $000123DC(pc,d0.w),a4
[000123d6] 4bfb 100a                 lea.l     $000123E2(pc,d1.w),a5
[000123da] 4ed4                      jmp       (a4)
[000123dc] 32d8                      move.w    (a0)+,(a1)+
[000123de] 3c04                      move.w    d4,d6
[000123e0] 4ed5                      jmp       (a5)
[000123e2] 22d8                      move.l    (a0)+,(a1)+
[000123e4] 22d8                      move.l    (a0)+,(a1)+
[000123e6] 22d8                      move.l    (a0)+,(a1)+
[000123e8] 22d8                      move.l    (a0)+,(a1)+
[000123ea] 51ce fff6                 dbf       d6,$000123E2
[000123ee] d0ca                      adda.w    a2,a0
[000123f0] d2cb                      adda.w    a3,a1
[000123f2] 51cd ffe6                 dbf       d5,$000123DA
[000123f6] 4e75                      rts
[000123f8] 49fb 0008                 lea.l     $00012402(pc,d0.w),a4
[000123fc] 4bfb 100e                 lea.l     $0001240C(pc,d1.w),a5
[00012400] 4ed4                      jmp       (a4)
[00012402] 3018                      move.w    (a0)+,d0
[00012404] 4640                      not.w     d0
[00012406] c159                      and.w     d0,(a1)+
[00012408] 3c04                      move.w    d4,d6
[0001240a] 4ed5                      jmp       (a5)
[0001240c] 2018                      move.l    (a0)+,d0
[0001240e] 4680                      not.l     d0
[00012410] c199                      and.l     d0,(a1)+
[00012412] 2018                      move.l    (a0)+,d0
[00012414] 4680                      not.l     d0
[00012416] c199                      and.l     d0,(a1)+
[00012418] 2018                      move.l    (a0)+,d0
[0001241a] 4680                      not.l     d0
[0001241c] c199                      and.l     d0,(a1)+
[0001241e] 2018                      move.l    (a0)+,d0
[00012420] 4680                      not.l     d0
[00012422] c199                      and.l     d0,(a1)+
[00012424] 51ce ffe6                 dbf       d6,$0001240C
[00012428] d0ca                      adda.w    a2,a0
[0001242a] d2cb                      adda.w    a3,a1
[0001242c] 51cd ffd2                 dbf       d5,$00012400
[00012430] 4e75                      rts
[00012432] 49fb 0008                 lea.l     $0001243C(pc,d0.w),a4
[00012436] 4bfb 100c                 lea.l     $00012444(pc,d1.w),a5
[0001243a] 4ed4                      jmp       (a4)
[0001243c] 3018                      move.w    (a0)+,d0
[0001243e] b159                      eor.w     d0,(a1)+
[00012440] 3c04                      move.w    d4,d6
[00012442] 4ed5                      jmp       (a5)
[00012444] 2018                      move.l    (a0)+,d0
[00012446] b199                      eor.l     d0,(a1)+
[00012448] 2018                      move.l    (a0)+,d0
[0001244a] b199                      eor.l     d0,(a1)+
[0001244c] 2018                      move.l    (a0)+,d0
[0001244e] b199                      eor.l     d0,(a1)+
[00012450] 2018                      move.l    (a0)+,d0
[00012452] b199                      eor.l     d0,(a1)+
[00012454] 51ce ffee                 dbf       d6,$00012444
[00012458] d0ca                      adda.w    a2,a0
[0001245a] d2cb                      adda.w    a3,a1
[0001245c] 51cd ffdc                 dbf       d5,$0001243A
[00012460] 4e75                      rts
[00012462] 49fb 0008                 lea.l     $0001246C(pc,d0.w),a4
[00012466] 4bfb 100c                 lea.l     $00012474(pc,d1.w),a5
[0001246a] 4ed4                      jmp       (a4)
[0001246c] 3018                      move.w    (a0)+,d0
[0001246e] 8159                      or.w      d0,(a1)+
[00012470] 3c04                      move.w    d4,d6
[00012472] 4ed5                      jmp       (a5)
[00012474] 2018                      move.l    (a0)+,d0
[00012476] 8199                      or.l      d0,(a1)+
[00012478] 2018                      move.l    (a0)+,d0
[0001247a] 8199                      or.l      d0,(a1)+
[0001247c] 2018                      move.l    (a0)+,d0
[0001247e] 8199                      or.l      d0,(a1)+
[00012480] 2018                      move.l    (a0)+,d0
[00012482] 8199                      or.l      d0,(a1)+
[00012484] 51ce ffee                 dbf       d6,$00012474
[00012488] d0ca                      adda.w    a2,a0
[0001248a] d2cb                      adda.w    a3,a1
[0001248c] 51cd ffdc                 dbf       d5,$0001246A
[00012490] 4e75                      rts
[00012492] 49fb 0008                 lea.l     $0001249C(pc,d0.w),a4
[00012496] 4bfb 100e                 lea.l     $000124A6(pc,d1.w),a5
[0001249a] 4ed4                      jmp       (a4)
[0001249c] 3018                      move.w    (a0)+,d0
[0001249e] 8151                      or.w      d0,(a1)
[000124a0] 4659                      not.w     (a1)+
[000124a2] 3c04                      move.w    d4,d6
[000124a4] 4ed5                      jmp       (a5)
[000124a6] 2018                      move.l    (a0)+,d0
[000124a8] 8191                      or.l      d0,(a1)
[000124aa] 4699                      not.l     (a1)+
[000124ac] 2018                      move.l    (a0)+,d0
[000124ae] 8191                      or.l      d0,(a1)
[000124b0] 4699                      not.l     (a1)+
[000124b2] 2018                      move.l    (a0)+,d0
[000124b4] 8191                      or.l      d0,(a1)
[000124b6] 4699                      not.l     (a1)+
[000124b8] 2018                      move.l    (a0)+,d0
[000124ba] 8191                      or.l      d0,(a1)
[000124bc] 4699                      not.l     (a1)+
[000124be] 51ce ffe6                 dbf       d6,$000124A6
[000124c2] d0ca                      adda.w    a2,a0
[000124c4] d2cb                      adda.w    a3,a1
[000124c6] 51cd ffd2                 dbf       d5,$0001249A
[000124ca] 4e75                      rts
[000124cc] 49fb 0008                 lea.l     $000124D6(pc,d0.w),a4
[000124d0] 4bfb 100e                 lea.l     $000124E0(pc,d1.w),a5
[000124d4] 4ed4                      jmp       (a4)
[000124d6] 3018                      move.w    (a0)+,d0
[000124d8] b151                      eor.w     d0,(a1)
[000124da] 4659                      not.w     (a1)+
[000124dc] 3c04                      move.w    d4,d6
[000124de] 4ed5                      jmp       (a5)
[000124e0] 2018                      move.l    (a0)+,d0
[000124e2] b191                      eor.l     d0,(a1)
[000124e4] 4699                      not.l     (a1)+
[000124e6] 2018                      move.l    (a0)+,d0
[000124e8] b191                      eor.l     d0,(a1)
[000124ea] 4699                      not.l     (a1)+
[000124ec] 2018                      move.l    (a0)+,d0
[000124ee] b191                      eor.l     d0,(a1)
[000124f0] 4699                      not.l     (a1)+
[000124f2] 2018                      move.l    (a0)+,d0
[000124f4] b191                      eor.l     d0,(a1)
[000124f6] 4699                      not.l     (a1)+
[000124f8] 51ce ffe6                 dbf       d6,$000124E0
[000124fc] d0ca                      adda.w    a2,a0
[000124fe] d2cb                      adda.w    a3,a1
[00012500] 51cd ffd2                 dbf       d5,$000124D4
[00012504] 4e75                      rts
[00012506] 49fb 0008                 lea.l     $00012510(pc,d0.w),a4
[0001250a] 4bfb 100a                 lea.l     $00012516(pc,d1.w),a5
[0001250e] 4ed4                      jmp       (a4)
[00012510] 4659                      not.w     (a1)+
[00012512] 3c04                      move.w    d4,d6
[00012514] 4ed5                      jmp       (a5)
[00012516] 4699                      not.l     (a1)+
[00012518] 4699                      not.l     (a1)+
[0001251a] 4699                      not.l     (a1)+
[0001251c] 4699                      not.l     (a1)+
[0001251e] 51ce fff6                 dbf       d6,$00012516
[00012522] d2cb                      adda.w    a3,a1
[00012524] 51cd ffe8                 dbf       d5,$0001250E
[00012528] 4e75                      rts
[0001252a] 49fb 0008                 lea.l     $00012534(pc,d0.w),a4
[0001252e] 4bfb 100e                 lea.l     $0001253E(pc,d1.w),a5
[00012532] 4ed4                      jmp       (a4)
[00012534] 4651                      not.w     (a1)
[00012536] 3018                      move.w    (a0)+,d0
[00012538] 8159                      or.w      d0,(a1)+
[0001253a] 3c04                      move.w    d4,d6
[0001253c] 4ed5                      jmp       (a5)
[0001253e] 4691                      not.l     (a1)
[00012540] 2018                      move.l    (a0)+,d0
[00012542] 8199                      or.l      d0,(a1)+
[00012544] 4691                      not.l     (a1)
[00012546] 2018                      move.l    (a0)+,d0
[00012548] 8199                      or.l      d0,(a1)+
[0001254a] 4691                      not.l     (a1)
[0001254c] 2018                      move.l    (a0)+,d0
[0001254e] 8199                      or.l      d0,(a1)+
[00012550] 4691                      not.l     (a1)
[00012552] 2018                      move.l    (a0)+,d0
[00012554] 8199                      or.l      d0,(a1)+
[00012556] 51ce ffe6                 dbf       d6,$0001253E
[0001255a] d0ca                      adda.w    a2,a0
[0001255c] d2cb                      adda.w    a3,a1
[0001255e] 51cd ffd2                 dbf       d5,$00012532
[00012562] 4e75                      rts
[00012564] 49fb 0008                 lea.l     $0001256E(pc,d0.w),a4
[00012568] 4bfb 100e                 lea.l     $00012578(pc,d1.w),a5
[0001256c] 4ed4                      jmp       (a4)
[0001256e] 3018                      move.w    (a0)+,d0
[00012570] 4640                      not.w     d0
[00012572] 32c0                      move.w    d0,(a1)+
[00012574] 3c04                      move.w    d4,d6
[00012576] 4ed5                      jmp       (a5)
[00012578] 2018                      move.l    (a0)+,d0
[0001257a] 4680                      not.l     d0
[0001257c] 22c0                      move.l    d0,(a1)+
[0001257e] 2018                      move.l    (a0)+,d0
[00012580] 4680                      not.l     d0
[00012582] 22c0                      move.l    d0,(a1)+
[00012584] 2018                      move.l    (a0)+,d0
[00012586] 4680                      not.l     d0
[00012588] 22c0                      move.l    d0,(a1)+
[0001258a] 2018                      move.l    (a0)+,d0
[0001258c] 4680                      not.l     d0
[0001258e] 22c0                      move.l    d0,(a1)+
[00012590] 51ce ffe6                 dbf       d6,$00012578
[00012594] d0ca                      adda.w    a2,a0
[00012596] d2cb                      adda.w    a3,a1
[00012598] 51cd ffd2                 dbf       d5,$0001256C
[0001259c] 4e75                      rts
[0001259e] 49fb 0008                 lea.l     $000125A8(pc,d0.w),a4
[000125a2] 4bfb 100e                 lea.l     $000125B2(pc,d1.w),a5
[000125a6] 4ed4                      jmp       (a4)
[000125a8] 3018                      move.w    (a0)+,d0
[000125aa] 4640                      not.w     d0
[000125ac] 8159                      or.w      d0,(a1)+
[000125ae] 3c04                      move.w    d4,d6
[000125b0] 4ed5                      jmp       (a5)
[000125b2] 2018                      move.l    (a0)+,d0
[000125b4] 4680                      not.l     d0
[000125b6] 8199                      or.l      d0,(a1)+
[000125b8] 2018                      move.l    (a0)+,d0
[000125ba] 4680                      not.l     d0
[000125bc] 8199                      or.l      d0,(a1)+
[000125be] 2018                      move.l    (a0)+,d0
[000125c0] 4680                      not.l     d0
[000125c2] 8199                      or.l      d0,(a1)+
[000125c4] 2018                      move.l    (a0)+,d0
[000125c6] 4680                      not.l     d0
[000125c8] 8199                      or.l      d0,(a1)+
[000125ca] 51ce ffe6                 dbf       d6,$000125B2
[000125ce] d0ca                      adda.w    a2,a0
[000125d0] d2cb                      adda.w    a3,a1
[000125d2] 51cd ffd2                 dbf       d5,$000125A6
[000125d6] 4e75                      rts
[000125d8] 49fb 0008                 lea.l     $000125E2(pc,d0.w),a4
[000125dc] 4bfb 100e                 lea.l     $000125EC(pc,d1.w),a5
[000125e0] 4ed4                      jmp       (a4)
[000125e2] 3018                      move.w    (a0)+,d0
[000125e4] c151                      and.w     d0,(a1)
[000125e6] 4659                      not.w     (a1)+
[000125e8] 3c04                      move.w    d4,d6
[000125ea] 4ed5                      jmp       (a5)
[000125ec] 2018                      move.l    (a0)+,d0
[000125ee] c191                      and.l     d0,(a1)
[000125f0] 4699                      not.l     (a1)+
[000125f2] 2018                      move.l    (a0)+,d0
[000125f4] c191                      and.l     d0,(a1)
[000125f6] 4699                      not.l     (a1)+
[000125f8] 2018                      move.l    (a0)+,d0
[000125fa] c191                      and.l     d0,(a1)
[000125fc] 4699                      not.l     (a1)+
[000125fe] 2018                      move.l    (a0)+,d0
[00012600] c191                      and.l     d0,(a1)
[00012602] 4699                      not.l     (a1)+
[00012604] 51ce ffe6                 dbf       d6,$000125EC
[00012608] d0ca                      adda.w    a2,a0
[0001260a] d2cb                      adda.w    a3,a1
[0001260c] 51cd ffd2                 dbf       d5,$000125E0
[00012610] 4e75                      rts
[00012612] 3600                      move.w    d0,d3
[00012614] 4843                      swap      d3
[00012616] 3600                      move.w    d0,d3
[00012618] 4a6e 01b2                 tst.w     434(a6)
[0001261c] 670a                      beq.s     $00012628
[0001261e] 266e 01ae                 movea.l   430(a6),a3
[00012622] c3ee 01b2                 muls.w    434(a6),d1
[00012626] 6008                      bra.s     $00012630
[00012628] 2678 044e                 movea.l   ($0000044E).w,a3
[0001262c] c3f8 206e                 muls.w    ($0000206E).w,d1
[00012630] d7c1                      adda.l    d1,a3
[00012632] d6c0                      adda.w    d0,a3
[00012634] d6c0                      adda.w    d0,a3
[00012636] 284b                      movea.l   a3,a4
[00012638] 3813                      move.w    (a3),d4
[0001263a] b642                      cmp.w     d2,d3
[0001263c] 6e0e                      bgt.s     $0001264C
[0001263e] 548b                      addq.l    #2,a3
[00012640] b85b                      cmp.w     (a3)+,d4
[00012642] 6608                      bne.s     $0001264C
[00012644] 5243                      addq.w    #1,d3
[00012646] b642                      cmp.w     d2,d3
[00012648] 6df6                      blt.s     $00012640
[0001264a] 3602                      move.w    d2,d3
[0001264c] 3283                      move.w    d3,(a1)
[0001264e] 4842                      swap      d2
[00012650] 4843                      swap      d3
[00012652] 264c                      movea.l   a4,a3
[00012654] b642                      cmp.w     d2,d3
[00012656] 6f0e                      ble.s     $00012666
[00012658] 3003                      move.w    d3,d0
[0001265a] b863                      cmp.w     -(a3),d4
[0001265c] 6608                      bne.s     $00012666
[0001265e] 5343                      subq.w    #1,d3
[00012660] b642                      cmp.w     d2,d3
[00012662] 6ef6                      bgt.s     $0001265A
[00012664] 3602                      move.w    d2,d3
[00012666] 3083                      move.w    d3,(a0)
[00012668] 3015                      move.w    (a5),d0
[0001266a] b86d 0004                 cmp.w     4(a5),d4
[0001266e] 6704                      beq.s     $00012674
[00012670] 0a40 0001                 eori.w    #$0001,d0
[00012674] 4e75                      rts

data:
[00012676]                           dc.w $0ae0
[00012678]                           dc.w $0024
[0001267a]                           dc.w $0014
[0001267c]                           dc.w $005a
[0001267e]                           dc.w $00a6
[00012680]                           dc.w $0212
[00012682]                           dc.w $022e
[00012684]                           dc.w $01b8
[00012686]                           dc.w $194a
[00012688]                           dc.w $0000
; TPA Relocations:
; $00000010
; $00000014
; $00000018
; $0000001c
; $00000020
; $00000024
; $00000028
; $00000058
; $00000066
; $00000164
; $00000262
; $00000360
; $0000045e
; $0000055c
; $000005aa
; $0000064c
; $00000654
; $0000065c
; $00000664
; $0000066c
; $00000674
; $0000067c
; $00000684
; $0000068c
; $00000694
; $0000069c
; $000006a4
; $000006ac
; $000006b4
; $000006bc
; $000006c4
; $000006cc
; $000007ca
; $00000864
; $00000868
; $0000086c
; $00000870
; $0000096e
; $00000a6c
; $00000b6a
; $00000c68
; $00000d66
; $00000e64
; $00000f62
; $00001060
; $0000115e
; $0000125c
; $0000135a
; $000013b4
; $000013b8
; $000013bc
; $000013c0
; $000013c4
; $000013c8
; $000013cc
; $000013d0
; $000013d4
; $000013d8
; $000013dc
; $000013e0
; $000013e4
; $000013e8
; $000013ec
; $000013f0
; $000013f4
; $000013f8
; $000013fc
; $00001400
; $00001404
; $00001408
; $0000140c
; $00001410
; $00001414
; $00001418
; $0000141c
; $00001420
; $00001424
; $00001428
; $0000142c
; $00001430
; $0000152c
; $00001530
; $00001534
; $00001538
; $0000153c
; $00001540
; $00001544
; $00001548
; $0000154c
; $00001550
; $00001554
; $00001558
; $0000155c
; $00001560
; $00001564
; $00001568
; $0000156c
; $00001570
; $00001574
; $00001578
; $0000157c
; $00001580
; $00001584
; $00001588
; $0000158c
; $00001590
; $00001594
; $00001598
; $0000159c
; $000015a0
; $000015a4
; $000015a8
; $000016a6
; $000017a4
; $000018a2
; $000018ce
; $000018d2
; $000018d6
; $000018da
; $000018de
; $000018e2
; $000018e6
; $000018ea
; $000018ee
; $000018f2
; $000018f6
; $000018fa
; $000018fe
; $00001902
; $00001906
; $0000190a
; $0000190e
; $00001912
; $00001916
; $0000191a
; $0000191e
; $00001922
; $00001926
; $0000192a
; $0000192e
; $00001932
; $00001936
; $0000193a
; $0000193e
; $00001942
; $00001946
; $0000194a
