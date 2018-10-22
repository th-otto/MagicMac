; ph_branch = 0x601a
; ph_tlen = 0x000021ae
; ph_dlen = 0x00000014
; ph_blen = 0x00001d82
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000075

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0410                 cmpiw.l   #$0410,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 007e                 ori.b     #$7E,d1
[00010018] 0001 0542                 ori.b     #$42,d1
[0001001c] 0001 0604                 ori.b     #$04,d1
[00010020] 0001 0080                 ori.b     #$80,d1
[00010024] 0001 00c0                 ori.b     #$C0,d1
[00010028] 0001 010e                 ori.b     #$0E,d1
[0001002c] 0001 0154                 ori.b     #$54,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0000 8000                 ori.b     #$00,d0
[00010044] 0010 0002                 ori.b     #$02,(a0)
[00010048] 0002 0000                 ori.b     #$00,d2
[0001004c] 0000 0000                 ori.b     #$00,d0
[00010050] 4e75                      rts
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 21c2            move.l    a0,$000121C2
[0001005c] 6100 0442                 bsr       $000104A0
[00010060] 6100 0114                 bsr       $00010176
[00010064] 6100 00f0                 bsr       $00010156
[00010068] 7005                      moveq.l   #5,d0
[0001006a] 7205                      moveq.l   #5,d1
[0001006c] 7405                      moveq.l   #5,d2
[0001006e] 6100 0456                 bsr       $000104C6
[00010072] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010076] 203c 0000 0658            move.l    #$00000658,d0
[0001007c] 4e75                      rts
[0001007e] 4e75                      rts
[00010080] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010084] 20ee 0010                 move.l    16(a6),(a0)+
[00010088] 4258                      clr.w     (a0)+
[0001008a] 20ee 000c                 move.l    12(a6),(a0)+
[0001008e] 7027                      moveq.l   #39,d0
[00010090] 247a 2130                 movea.l   $000121C2(pc),a2
[00010094] 246a 002c                 movea.l   44(a2),a2
[00010098] 45ea 000a                 lea.l     10(a2),a2
[0001009c] 30da                      move.w    (a2)+,(a0)+
[0001009e] 51c8 fffc                 dbf       d0,$0001009C
[000100a2] 317c 0100 ffc0            move.w    #$0100,-64(a0)
[000100a8] 317c 0001 ffec            move.w    #$0001,-20(a0)
[000100ae] 4268 fff4                 clr.w     -12(a0)
[000100b2] 700b                      moveq.l   #11,d0
[000100b4] 32da                      move.w    (a2)+,(a1)+
[000100b6] 51c8 fffc                 dbf       d0,$000100B4
[000100ba] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100be] 4e75                      rts
[000100c0] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[000100c4] 702c                      moveq.l   #44,d0
[000100c6] 247a 20fa                 movea.l   $000121C2(pc),a2
[000100ca] 246a 0030                 movea.l   48(a2),a2
[000100ce] 30da                      move.w    (a2)+,(a0)+
[000100d0] 51c8 fffc                 dbf       d0,$000100CE
[000100d4] 4268 ffa6                 clr.w     -90(a0)
[000100d8] 4268 ffa8                 clr.w     -88(a0)
[000100dc] 317c 0010 ffae            move.w    #$0010,-82(a0)
[000100e2] 317c 0001 ffb0            move.w    #$0001,-80(a0)
[000100e8] 317c 0898 ffb2            move.w    #$0898,-78(a0)
[000100ee] 317c 0001 ffcc            move.w    #$0001,-52(a0)
[000100f4] 700b                      moveq.l   #11,d0
[000100f6] 32da                      move.w    (a2)+,(a1)+
[000100f8] 51c8 fffc                 dbf       d0,$000100F6
[000100fc] 45ee 0034                 lea.l     52(a6),a2
[00010100] 235a ffe8                 move.l    (a2)+,-24(a1)
[00010104] 235a ffec                 move.l    (a2)+,-20(a1)
[00010108] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[0001010c] 4e75                      rts
[0001010e] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010112] 43fa 008c                 lea.l     $000101A0(pc),a1
[00010116] 30d9                      move.w    (a1)+,(a0)+
[00010118] 30d9                      move.w    (a1)+,(a0)+
[0001011a] 30d9                      move.w    (a1)+,(a0)+
[0001011c] 20d9                      move.l    (a1)+,(a0)+
[0001011e] 30ee 01b2                 move.w    434(a6),(a0)+
[00010122] 20ee 01ae                 move.l    430(a6),(a0)+
[00010126] 5c89                      addq.l    #6,a1
[00010128] 30d9                      move.w    (a1)+,(a0)+
[0001012a] 30d9                      move.w    (a1)+,(a0)+
[0001012c] 30d9                      move.w    (a1)+,(a0)+
[0001012e] 30d9                      move.w    (a1)+,(a0)+
[00010130] 30d9                      move.w    (a1)+,(a0)+
[00010132] 30d9                      move.w    (a1)+,(a0)+
[00010134] 30d9                      move.w    (a1)+,(a0)+
[00010136] 30d9                      move.w    (a1)+,(a0)+
[00010138] 706f                      moveq.l   #111,d0
[0001013a] 43fa 0084                 lea.l     $000101C0(pc),a1
[0001013e] 30d9                      move.w    (a1)+,(a0)+
[00010140] 51c8 fffc                 dbf       d0,$0001013E
[00010144] 303c 008f                 move.w    #$008F,d0
[00010148] 4258                      clr.w     (a0)+
[0001014a] 51c8 fffc                 dbf       d0,$00010148
[0001014e] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010152] 4e75                      rts
[00010154] 4e75                      rts
[00010156] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[0001015a] 247a 2066                 movea.l   $000121C2(pc),a2
[0001015e] 246a 0028                 movea.l   40(a2),a2
[00010162] 2052                      movea.l   (a2),a0
[00010164] 43fa 2060                 lea.l     $000121C6(pc),a1
[00010168] 703f                      moveq.l   #63,d0
[0001016a] 22d8                      move.l    (a0)+,(a1)+
[0001016c] 51c8 fffc                 dbf       d0,$0001016A
[00010170] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010174] 4e75                      rts
[00010176] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[0001017a] 41fa 214a                 lea.l     $000122C6(pc),a0
[0001017e] 7000                      moveq.l   #0,d0
[00010180] 3200                      move.w    d0,d1
[00010182] 7407                      moveq.l   #7,d2
[00010184] 4258                      clr.w     (a0)+
[00010186] d201                      add.b     d1,d1
[00010188] 6504                      bcs.s     $0001018E
[0001018a] 4668 fffe                 not.w     -2(a0)
[0001018e] 51ca fff4                 dbf       d2,$00010184
[00010192] 5240                      addq.w    #1,d0
[00010194] b07c 0100                 cmp.w     #$0100,d0
[00010198] 6de6                      blt.s     $00010180
[0001019a] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[0001019e] 4e75                      rts
[000101a0] 0002 0002                 ori.b     #$02,d2
[000101a4] 0010 0000                 ori.b     #$00,(a0)
[000101a8] 8000                      or.b      d0,d0
[000101aa] 0000 0000                 ori.b     #$00,d0
[000101ae] 0000 0005                 ori.b     #$05,d0
[000101b2] 0005 0005                 ori.b     #$05,d5
[000101b6] 0000 0000                 ori.b     #$00,d0
[000101ba] 0001 0002                 ori.b     #$02,d1
[000101be] 0000 000b                 ori.b     #$0B,d0
[000101c2] 000c 000d                 ori.b     #$0D,a4 ; apollo only
[000101c6] 000e 000f                 ori.b     #$0F,a6 ; apollo only
[000101ca] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101d2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101da] ffff ffff ffff 0006       vperm     #$FFFF0006,e23,e23,e23
[000101e2] 0007 0008                 ori.b     #$08,d7
[000101e6] 0009 000a                 ori.b     #$0A,a1 ; apollo only
[000101ea] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101f2] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101fa] ffff ffff ffff 0000       vperm     #$FFFF0000,e23,e23,e23
[00010202] 0001 0002                 ori.b     #$02,d1
[00010206] 0003 0004                 ori.b     #$04,d3
[0001020a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010212] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001021a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010222] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001022a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010232] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001023a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010242] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001024a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010252] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001025a] ffff ffff ffff 0005       vperm     #$FFFF0005,e23,e23,e23
[00010262] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001026a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010272] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001027a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010282] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001028a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010292] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001029a] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102a2] f000 0720                 pmovefd.l ???,d0
[000102a6] ffe0 001e                 unpack1632.q-(b0),e8 ; apollo only
[000102aa] e193                      roxl.l    #8,d3
[000102ac] 1e57                      movea.l   (a7),b7 ; apollo only
[000102ae] dedb                      adda.w    (a3)+,a7
[000102b0] 8410                      or.b      (a0),d2
[000102b2] 8000                      or.b      d0,d0
[000102b4] 0400 b507                 subi.b    #$07,d0
[000102b8] 0010 8010                 ori.b     #$10,(a0)
[000102bc] 0410 18c3                 subi.b    #$C3,(a0)
[000102c0] 0006 000c                 ori.b     #$0C,d6
[000102c4] 0013 0019                 ori.b     #$19,(a3)
[000102c8] 001f 0180                 ori.b     #$80,(a7)+
[000102cc] 0186                      bclr      d0,d6
[000102ce] 018c 0193                 movep.w   d0,403(a4)
[000102d2] 0199                      bclr      d0,(a1)+
[000102d4] 019f                      bclr      d0,(a7)+
[000102d6] 0320                      btst      d1,-(a0)
[000102d8] 0326                      btst      d1,-(a6)
[000102da] 032c 0333                 btst      d1,819(a4)
[000102de] 0339 033f 04c0            btst      d1,$033F04C0
[000102e4] 04c6                      ff1.l     d6 ; ColdFire isa_c only
[000102e6] 04cc                      dc.w      $04CC ; illegal
[000102e8] 04d3 04d9                 cmp2.l    (a3),d0 ; 68020+ only
[000102ec] 04df                      dc.w      $04DF ; illegal
[000102ee] 0660 0666                 addi.w    #$0666,-(a0)
[000102f2] 066c 0673 0679            addi.w    #$0673,1657(a4)
[000102f8] 067f 07e0                 addi.w    #$07E0,???
[000102fc] 07e6                      bset      d3,-(a6)
[000102fe] 07ec 07f3                 bset      d3,2035(a4)
[00010302] 07f9 07ff 3000            bset      d3,$07FF3000
[00010308] 3006                      move.w    d6,d0
[0001030a] 300c                      move.w    a4,d0
[0001030c] 3013                      move.w    (a3),d0
[0001030e] 3019                      move.w    (a1)+,d0
[00010310] 301f                      move.w    (a7)+,d0
[00010312] 3180 3186 318c            move.w    d0,([],d3.w,$318C) ; 68020+ only; reserved BD=0
[00010318] 0018 3199                 ori.b     #$99,(a0)+
[0001031c] 319f 3320 3326            move.w    (a7)+,($3326,a0,d3.w*2) ; 68020+ only
[00010322] 332c 3333                 move.w    13107(a4),-(a1)
[00010326] 3339 333f 34c0            move.w    $333F34C0,-(a1)
[0001032c] 34c6                      move.w    d6,(a2)+
[0001032e] 34cc                      move.w    a4,(a2)+
[00010330] 34d3                      move.w    (a3),(a2)+
[00010332] 34d9                      move.w    (a1)+,(a2)+
[00010334] 34df                      move.w    (a7)+,(a2)+
[00010336] 3660                      movea.w   -(a0),a3
[00010338] 3666                      movea.w   -(a6),a3
[0001033a] 366c 3673                 movea.w   13939(a4),a3
[0001033e] 3679 367f 37e0            movea.w   $367F37E0,a3
[00010344] 37e6 37ec 37f3            move.w    -(a6),([$37F3,zpc],zd3.w*8) ; 68020+ only; reserved OD=0
[0001034a] 37f9 37ff 6000 6006       move.w    $37FF6000,$00010352(pc,d6.w) ; apollo only
[00010352] 600c                      bra.s     $00010360
[00010354] 6013                      bra.s     $00010369
[00010356] 6019                      bra.s     $00010371
[00010358] 601f                      bra.s     $00010379
[0001035a] 6180                      bsr.s     $000102DC
[0001035c] 6186                      bsr.s     $000102E4
[0001035e] 618c                      bsr.s     $000102EC
[00010360] 6193                      bsr.s     $000102F5
[00010362] 6199                      bsr.s     $000102FD
[00010364] 619f                      bsr.s     $00010305
[00010366] 6320                      bls.s     $00010388
[00010368] 6326                      bls.s     $00010390
[0001036a] 632c                      bls.s     $00010398
[0001036c] 6333                      bls.s     $000103A1
[0001036e] 6339                      bls.s     $000103A9
[00010370] 633f                      bls.s     $000103B1
[00010372] 64c0                      bcc.s     $00010334
[00010374] 64c6                      bcc.s     $0001033C
[00010376] 64cc                      bcc.s     $00010344
[00010378] 64d3                      bcc.s     $0001034D
[0001037a] 64d9                      bcc.s     $00010355
[0001037c] 64df                      bcc.s     $0001035D
[0001037e] 6660                      bne.s     $000103E0
[00010380] 6666                      bne.s     $000103E8
[00010382] 666c                      bne.s     $000103F0
[00010384] 6673                      bne.s     $000103F9
[00010386] 6679                      bne.s     $00010401
[00010388] 667f                      bne.s     $00010409
[0001038a] 67e0                      beq.s     $0001036C
[0001038c] 67e6                      beq.s     $00010374
[0001038e] 67ec                      beq.s     $0001037C
[00010390] 67f3                      beq.s     $00010385
[00010392] 67f9                      beq.s     $0001038D
[00010394] 67ff 9800 9806            beq.l     $98019B9C ; 68020+ only
[0001039a] 980c                      sub.b     a4,d4
[0001039c] 9813                      sub.b     (a3),d4
[0001039e] 9819                      sub.b     (a1)+,d4
[000103a0] 981f                      sub.b     (a7)+,d4
[000103a2] 9980                      subx.l    d0,d4
[000103a4] 9986                      subx.l    d6,d4
[000103a6] 998c                      subx.l    -(a4),-(a4)
[000103a8] 9993                      sub.l     d4,(a3)
[000103aa] 9999                      sub.l     d4,(a1)+
[000103ac] 999f                      sub.l     d4,(a7)+
[000103ae] 9b20                      sub.b     d5,-(a0)
[000103b0] 9b26                      sub.b     d5,-(a6)
[000103b2] 9b2c 9b33                 sub.b     d5,-25805(a4)
[000103b6] 9b39 9b3f 9cc0            sub.b     d5,$9B3F9CC0
[000103bc] 9cc6                      suba.w    d6,a6
[000103be] 9ccc                      suba.w    a4,a6
[000103c0] 9cd3                      suba.w    (a3),a6
[000103c2] 9cd9                      suba.w    (a1)+,a6
[000103c4] 9cdf                      suba.w    (a7)+,a6
[000103c6] 9e60                      sub.w     -(a0),d7
[000103c8] 9e66                      sub.w     -(a6),d7
[000103ca] 9e6c 9e73                 sub.w     -24973(a4),d7
[000103ce] 9e79 9e7f 9fe0            sub.w     $9E7F9FE0,d7
[000103d4] 9fe6                      suba.l    -(a6),a7
[000103d6] 9fec 9ff3                 suba.l    -24589(a4),a7
[000103da] 9ff9 9fff c800            suba.l    $9FFFC800,a7
[000103e0] c806                      and.b     d6,d4
[000103e2] c80c                      and.b     a4,d4 ; apollo only
[000103e4] c813                      and.b     (a3),d4
[000103e6] c819                      and.b     (a1)+,d4
[000103e8] c81f                      and.b     (a7)+,d4
[000103ea] c980                      cmp.l     b0,d4 ; apollo only
[000103ec] c986                      cmp.l     b6,d4 ; apollo only
[000103ee] c98c                      exg       d4,a4
[000103f0] c993                      and.l     d4,(a3)
[000103f2] c999                      and.l     d4,(a1)+
[000103f4] c99f                      and.l     d4,(a7)+
[000103f6] cb20                      and.b     d5,-(a0)
[000103f8] cb26                      and.b     d5,-(a6)
[000103fa] cb2c cb33                 and.b     d5,-13517(a4)
[000103fe] cb39 cb3f ccc0            and.b     d5,$CB3FCCC0
[00010404] ccc6                      mulu.w    d6,d6
[00010406] cccc                      mulu.w    a4,d6
[00010408] ccd3                      mulu.w    (a3),d6
[0001040a] ccd9                      mulu.w    (a1)+,d6
[0001040c] ccdf                      mulu.w    (a7)+,d6
[0001040e] ce60                      and.w     -(a0),d7
[00010410] ce66                      and.w     -(a6),d7
[00010412] ce6c ce73                 and.w     -12685(a4),d7
[00010416] ce79 ce7f cfe0            and.w     $CE7FCFE0,d7
[0001041c] cfe6                      muls.w    -(a6),d7
[0001041e] cfec cff3                 muls.w    -12301(a4),d7
[00010422] cff9 cfff f800            muls.w    $CFFFF800,d7
[00010428] f806 f80c f813            lpGEN     #$F813,d6
[0001042e] f819 f81f f980            lpGEN     #$F980,(a1)+
[00010434] f986                      dc.w      $F986 ; illegal
[00010436] f98c                      dc.w      $F98C ; illegal
[00010438] f993                      dc.w      $F993 ; illegal
[0001043a] f999                      dc.w      $F999 ; illegal
[0001043c] f99f                      dc.w      $F99F ; illegal
[0001043e] fb20                      wddata.b  -(a0)
[00010440] fb26                      wddata.b  -(a6)
[00010442] fb2c fb33                 wddata.b  -1229(a4)
[00010446] fb39 fb3f fcc0            wddata.b  $FB3FFCC0
[0001044c] fcc6 fccc fcd3            cp6B??.l  $FCCE0121
[00010452] fcd9 fcdf fe60            cp6B??.l  $FCE102B4
[00010458] fe66 fe6c                 nfS??     -(a6)
[0001045c] fe73 fe79 fe7f            nfS??     127(a3,a7.l*8) ; 68020+ only
[00010462] ffe0                      dc.w      $FFE0 ; illegal
[00010464] ffe6                      dc.w      $FFE6 ; illegal
[00010466] ffec                      dc.w      $FFEC ; illegal
[00010468] fff3                      dc.w      $FFF3 ; illegal
[0001046a] fff9                      dc.w      $FFF9 ; illegal
[0001046c] f000                      dc.w      $F000 ; illegal
[0001046e] e000                      asr.b     #8,d0
[00010470] c000                      and.b     d0,d0
[00010472] b000                      cmp.b     d0,d0
[00010474] 8000                      or.b      d0,d0
[00010476] 4800                      nbcd      d0
[00010478] 1800                      move.b    d0,d4
[0001047a] 0780                      bclr      d3,d0
[0001047c] 0720                      btst      d3,-(a0)
[0001047e] 0600 0580                 addi.b    #$80,d0
[00010482] 0400 0260                 subi.b    #$60,d0
[00010486] 00c0                      bitrev.l  d0 ; ColdFire isa_c only
[00010488] 0003 0009                 ori.b     #$09,d3
[0001048c] 0010 0016                 ori.b     #$16,(a0)
[00010490] 3193 001c                 move.w    (a3),28(a0,d0.w)
[00010494] f79e                      dc.w      $F79E ; illegal
[00010496] e73c                      rol.b     d3,d4
[00010498] c618                      and.b     (a0)+,d3
[0001049a] b596                      eor.l     d2,(a6)
[0001049c] 4a69 0000                 tst.w     0(a1)
[000104a0] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[000104a4] a000                      ALINE     #$0000
[000104a6] 907c 2070                 sub.w     #$2070,d0
[000104aa] 6714                      beq.s     $000104C0
[000104ac] 41fa fb52                 lea.l     $00010000(pc),a0
[000104b0] 43f9 0001 21ae            lea.l     $000121AE,a1
[000104b6] 3219                      move.w    (a1)+,d1
[000104b8] 6706                      beq.s     $000104C0
[000104ba] d0c1                      adda.w    d1,a0
[000104bc] d150                      add.w     d0,(a0)
[000104be] 60f6                      bra.s     $000104B6
[000104c0] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[000104c4] 4e75                      rts
[000104c6] 48e7 fec0                 movem.l   d0-d6/a0-a1,-(a7)
[000104ca] 7601                      moveq.l   #1,d3
[000104cc] e16b                      lsl.w     d0,d3
[000104ce] 5343                      subq.w    #1,d3
[000104d0] 3003                      move.w    d3,d0
[000104d2] 7601                      moveq.l   #1,d3
[000104d4] e36b                      lsl.w     d1,d3
[000104d6] 5343                      subq.w    #1,d3
[000104d8] 3203                      move.w    d3,d1
[000104da] 7601                      moveq.l   #1,d3
[000104dc] e56b                      lsl.w     d2,d3
[000104de] 5343                      subq.w    #1,d3
[000104e0] 3403                      move.w    d3,d2
[000104e2] 48a7 e000                 movem.w   d0-d2,-(a7)
[000104e6] 41fa 2dde                 lea.l     $000132C6(pc),a0
[000104ea] 7a02                      moveq.l   #2,d5
[000104ec] 7600                      moveq.l   #0,d3
[000104ee] 3803                      move.w    d3,d4
[000104f0] c8c0                      mulu.w    d0,d4
[000104f2] d8bc 0000 01f4            add.l     #$000001F4,d4
[000104f8] 88fc 03e8                 divu.w    #$03E8,d4
[000104fc] 10c4                      move.b    d4,(a0)+
[000104fe] 5243                      addq.w    #1,d3
[00010500] b67c 03e8                 cmp.w     #$03E8,d3
[00010504] 6fe8                      ble.s     $000104EE
[00010506] 3001                      move.w    d1,d0
[00010508] 3202                      move.w    d2,d1
[0001050a] 5288                      addq.l    #1,a0
[0001050c] 51cd ffde                 dbf       d5,$000104EC
[00010510] 4c9f 0007                 movem.w   (a7)+,d0-d2
[00010514] 43fa 396e                 lea.l     $00013E84(pc),a1
[00010518] 7c02                      moveq.l   #2,d6
[0001051a] 7600                      moveq.l   #0,d3
[0001051c] 3a00                      move.w    d0,d5
[0001051e] e24d                      lsr.w     #1,d5
[00010520] 48c5                      ext.l     d5
[00010522] 3803                      move.w    d3,d4
[00010524] c8fc 03e8                 mulu.w    #$03E8,d4
[00010528] d885                      add.l     d5,d4
[0001052a] 88c0                      divu.w    d0,d4
[0001052c] 32c4                      move.w    d4,(a1)+
[0001052e] 5243                      addq.w    #1,d3
[00010530] b640                      cmp.w     d0,d3
[00010532] 6fee                      ble.s     $00010522
[00010534] 3001                      move.w    d1,d0
[00010536] 3202                      move.w    d2,d1
[00010538] 51ce ffe0                 dbf       d6,$0001051A
[0001053c] 4cdf 037f                 movem.l   (a7)+,d0-d6/a0-a1
[00010540] 4e75                      rts
[00010542] 48e7 c0e0                 movem.l   d0-d1/a0-a2,-(a7)
[00010546] 3d7c 000f 01b4            move.w    #$000F,436(a6)
[0001054c] 3d7c 00ff 0014            move.w    #$00FF,20(a6)
[00010552] 2d7c 0001 10b2 01f4       move.l    #$000110B2,500(a6)
[0001055a] 2d7c 0001 0a1c 01f8       move.l    #$00010A1C,504(a6)
[00010562] 2d7c 0001 0aae 01fc       move.l    #$00010AAE,508(a6)
[0001056a] 2d7c 0001 0cca 0200       move.l    #$00010CCA,512(a6)
[00010572] 2d7c 0001 0f08 0204       move.l    #$00010F08,516(a6)
[0001057a] 2d7c 0001 180a 0208       move.l    #$0001180A,520(a6)
[00010582] 2d7c 0001 1a46 020c       move.l    #$00011A46,524(a6)
[0001058a] 2d7c 0001 09d2 0210       move.l    #$000109D2,528(a6)
[00010592] 2d7c 0001 214a 0214       move.l    #$0001214A,532(a6)
[0001059a] 2d7c 0001 098c 021c       move.l    #$0001098C,540(a6)
[000105a2] 2d7c 0001 09b0 0218       move.l    #$000109B0,536(a6)
[000105aa] 2d7c 0001 06ba 0220       move.l    #$000106BA,544(a6)
[000105b2] 2d7c 0001 0664 0224       move.l    #$00010664,548(a6)
[000105ba] 2d7c 0001 0606 0228       move.l    #$00010606,552(a6)
[000105c2] 2d7c 0001 062e 022c       move.l    #$0001062E,556(a6)
[000105ca] 2d7c 0001 06a8 0230       move.l    #$000106A8,560(a6)
[000105d2] 2d7c 0001 06b6 0234       move.l    #$000106B6,564(a6)
[000105da] 41fa fcc4                 lea.l     $000102A0(pc),a0
[000105de] 43ee 0458                 lea.l     1112(a6),a1
[000105e2] 45fa 1be2                 lea.l     $000121C6(pc),a2
[000105e6] 323c 00ff                 move.w    #$00FF,d1
[000105ea] 7000                      moveq.l   #0,d0
[000105ec] 101a                      move.b    (a2)+,d0
[000105ee] d040                      add.w     d0,d0
[000105f0] 3030 0000                 move.w    0(a0,d0.w),d0
[000105f4] c07c ffdf                 and.w     #$FFDF,d0
[000105f8] 32c0                      move.w    d0,(a1)+
[000105fa] 51c9 ffee                 dbf       d1,$000105EA
[000105fe] 4cdf 0703                 movem.l   (a7)+,d0-d1/a0-a2
[00010602] 4e75                      rts
[00010604] 4e75                      rts
[00010606] 43ee 0458                 lea.l     1112(a6),a1
[0001060a] d643                      add.w     d3,d3
[0001060c] d2c3                      adda.w    d3,a1
[0001060e] 41fa 2cb6                 lea.l     $000132C6(pc),a0
[00010612] 1030 0000                 move.b    0(a0,d0.w),d0
[00010616] eb48                      lsl.w     #5,d0
[00010618] 41e8 03ea                 lea.l     1002(a0),a0
[0001061c] 8030 1000                 or.b      0(a0,d1.w),d0
[00010620] ed48                      lsl.w     #6,d0
[00010622] 41e8 03ea                 lea.l     1002(a0),a0
[00010626] 8030 2000                 or.b      0(a0,d2.w),d0
[0001062a] 3280                      move.w    d0,(a1)
[0001062c] 4e75                      rts
[0001062e] 43ee 0458                 lea.l     1112(a6),a1
[00010632] d040                      add.w     d0,d0
[00010634] 3431 0000                 move.w    0(a1,d0.w),d2
[00010638] 43fa 384a                 lea.l     $00013E84(pc),a1
[0001063c] ed5a                      rol.w     #6,d2
[0001063e] 703e                      moveq.l   #62,d0
[00010640] c042                      and.w     d2,d0
[00010642] 3031 0000                 move.w    0(a1,d0.w),d0
[00010646] 43e9 0040                 lea.l     64(a1),a1
[0001064a] eb5a                      rol.w     #5,d2
[0001064c] 723e                      moveq.l   #62,d1
[0001064e] c242                      and.w     d2,d1
[00010650] 3231 1000                 move.w    0(a1,d1.w),d1
[00010654] 43e9 0040                 lea.l     64(a1),a1
[00010658] ed5a                      rol.w     #6,d2
[0001065a] c47c 003e                 and.w     #$003E,d2
[0001065e] 3431 2000                 move.w    0(a1,d2.w),d2
[00010662] 4e75                      rts
[00010664] b07c 0010                 cmp.w     #$0010,d0
[00010668] 6614                      bne.s     $0001067E
[0001066a] 22d8                      move.l    (a0)+,(a1)+
[0001066c] 22d8                      move.l    (a0)+,(a1)+
[0001066e] 22d8                      move.l    (a0)+,(a1)+
[00010670] 22d8                      move.l    (a0)+,(a1)+
[00010672] 22d8                      move.l    (a0)+,(a1)+
[00010674] 22d8                      move.l    (a0)+,(a1)+
[00010676] 22d8                      move.l    (a0)+,(a1)+
[00010678] 22d8                      move.l    (a0)+,(a1)+
[0001067a] 7000                      moveq.l   #0,d0
[0001067c] 4e75                      rts
[0001067e] 48e7 6000                 movem.l   d1-d2,-(a7)
[00010682] 343c 00ff                 move.w    #$00FF,d2
[00010686] 2018                      move.l    (a0)+,d0
[00010688] 2200                      move.l    d0,d1
[0001068a] e689                      lsr.l     #3,d1
[0001068c] 3200                      move.w    d0,d1
[0001068e] e489                      lsr.l     #2,d1
[00010690] c2bc ffff fe00            and.l     #$FFFFFE00,d1
[00010696] 1200                      move.b    d0,d1
[00010698] e689                      lsr.l     #3,d1
[0001069a] 32c1                      move.w    d1,(a1)+
[0001069c] 51ca ffe8                 dbf       d2,$00010686
[000106a0] 4cdf 0006                 movem.l   (a7)+,d1-d2
[000106a4] 700f                      moveq.l   #15,d0
[000106a6] 4e75                      rts
[000106a8] 41ee 0458                 lea.l     1112(a6),a0
[000106ac] d040                      add.w     d0,d0
[000106ae] d0c0                      adda.w    d0,a0
[000106b0] 7000                      moveq.l   #0,d0
[000106b2] 3010                      move.w    (a0),d0
[000106b4] 4e75                      rts
[000106b6] 70ff                      moveq.l   #-1,d0
[000106b8] 4e75                      rts
[000106ba] 2f0e                      move.l    a6,-(a7)
[000106bc] 7000                      moveq.l   #0,d0
[000106be] 3028 000c                 move.w    12(a0),d0
[000106c2] 3228 0006                 move.w    6(a0),d1
[000106c6] c2e8 0008                 mulu.w    8(a0),d1
[000106ca] 7400                      moveq.l   #0,d2
[000106cc] 4a68 000a                 tst.w     10(a0)
[000106d0] 6602                      bne.s     $000106D4
[000106d2] 7401                      moveq.l   #1,d2
[000106d4] 3342 000a                 move.w    d2,10(a1)
[000106d8] 2050                      movea.l   (a0),a0
[000106da] 2251                      movea.l   (a1),a1
[000106dc] 5381                      subq.l    #1,d1
[000106de] 6b4e                      bmi.s     $0001072E
[000106e0] 5340                      subq.w    #1,d0
[000106e2] 6700 0292                 beq       $00010976
[000106e6] 907c 000f                 sub.w     #$000F,d0
[000106ea] 6642                      bne.s     $0001072E
[000106ec] d442                      add.w     d2,d2
[000106ee] d442                      add.w     d2,d2
[000106f0] 247b 2040                 movea.l   $00010732(pc,d2.w),a2
[000106f4] b3c8                      cmpa.l    a0,a1
[000106f6] 6630                      bne.s     $00010728
[000106f8] 2601                      move.l    d1,d3
[000106fa] 5283                      addq.l    #1,d3
[000106fc] eb8b                      lsl.l     #5,d3
[000106fe] b6ae 0024                 cmp.l     36(a6),d3
[00010702] 6e1e                      bgt.s     $00010722
[00010704] 2f03                      move.l    d3,-(a7)
[00010706] 2f08                      move.l    a0,-(a7)
[00010708] 226e 0020                 movea.l   32(a6),a1
[0001070c] 2f09                      move.l    a1,-(a7)
[0001070e] 2001                      move.l    d1,d0
[00010710] 5280                      addq.l    #1,d0
[00010712] 4e92                      jsr       (a2)
[00010714] 205f                      movea.l   (a7)+,a0
[00010716] 225f                      movea.l   (a7)+,a1
[00010718] 221f                      move.l    (a7)+,d1
[0001071a] e289                      lsr.l     #1,d1
[0001071c] 5381                      subq.l    #1,d1
[0001071e] 6000 025a                 bra       $0001097A
[00010722] 247b 2016                 movea.l   $0001073A(pc,d2.w),a2
[00010726] 6004                      bra.s     $0001072C
[00010728] 2001                      move.l    d1,d0
[0001072a] 5280                      addq.l    #1,d0
[0001072c] 4e92                      jsr       (a2)
[0001072e] 2c5f                      movea.l   (a7)+,a6
[00010730] 4e75                      rts
[00010732] 0001 08f8                 ori.b     #$F8,d1
[00010736] 0001 087e                 ori.b     #$7E,d1
[0001073a] 0001 0742                 ori.b     #$42,d1
[0001073e] 0001 0814                 ori.b     #$14,d1
[00010742] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010746] 2001                      move.l    d1,d0
[00010748] 780f                      moveq.l   #15,d4
[0001074a] 6100 0102                 bsr       $0001084E
[0001074e] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[00010752] 2c41                      movea.l   d1,a6
[00010754] 2f08                      move.l    a0,-(a7)
[00010756] 2f28 001c                 move.l    28(a0),-(a7)
[0001075a] 2f28 0018                 move.l    24(a0),-(a7)
[0001075e] 2f28 0014                 move.l    20(a0),-(a7)
[00010762] 2f28 0010                 move.l    16(a0),-(a7)
[00010766] 2f09                      move.l    a1,-(a7)
[00010768] 611a                      bsr.s     $00010784
[0001076a] 225f                      movea.l   (a7)+,a1
[0001076c] 204f                      movea.l   a7,a0
[0001076e] 5289                      addq.l    #1,a1
[00010770] 6112                      bsr.s     $00010784
[00010772] 4fef 0010                 lea.l     16(a7),a7
[00010776] 205f                      movea.l   (a7)+,a0
[00010778] 41e8 0020                 lea.l     32(a0),a0
[0001077c] 220e                      move.l    a6,d1
[0001077e] 5381                      subq.l    #1,d1
[00010780] 6ad0                      bpl.s     $00010752
[00010782] 4e75                      rts
[00010784] 700f                      moveq.l   #15,d0
[00010786] 4840                      swap      d0
[00010788] 3018                      move.w    (a0)+,d0
[0001078a] 3218                      move.w    (a0)+,d1
[0001078c] 3418                      move.w    (a0)+,d2
[0001078e] 3618                      move.w    (a0)+,d3
[00010790] 3818                      move.w    (a0)+,d4
[00010792] 3a18                      move.w    (a0)+,d5
[00010794] 3c18                      move.w    (a0)+,d6
[00010796] 3e18                      move.w    (a0)+,d7
[00010798] 4840                      swap      d0
[0001079a] 4847                      swap      d7
[0001079c] 4840                      swap      d0
[0001079e] d040                      add.w     d0,d0
[000107a0] df07                      addx.b    d7,d7
[000107a2] d241                      add.w     d1,d1
[000107a4] df07                      addx.b    d7,d7
[000107a6] d442                      add.w     d2,d2
[000107a8] df07                      addx.b    d7,d7
[000107aa] d643                      add.w     d3,d3
[000107ac] df07                      addx.b    d7,d7
[000107ae] d844                      add.w     d4,d4
[000107b0] df07                      addx.b    d7,d7
[000107b2] da45                      add.w     d5,d5
[000107b4] df07                      addx.b    d7,d7
[000107b6] dc46                      add.w     d6,d6
[000107b8] df07                      addx.b    d7,d7
[000107ba] 4847                      swap      d7
[000107bc] de47                      add.w     d7,d7
[000107be] 4847                      swap      d7
[000107c0] df07                      addx.b    d7,d7
[000107c2] 12c7                      move.b    d7,(a1)+
[000107c4] 5289                      addq.l    #1,a1
[000107c6] 4840                      swap      d0
[000107c8] 51c8 ffd2                 dbf       d0,$0001079C
[000107cc] 4e75                      rts
[000107ce] 700f                      moveq.l   #15,d0
[000107d0] 4840                      swap      d0
[000107d2] 4847                      swap      d7
[000107d4] 1e18                      move.b    (a0)+,d7
[000107d6] 5288                      addq.l    #1,a0
[000107d8] de07                      add.b     d7,d7
[000107da] d140                      addx.w    d0,d0
[000107dc] de07                      add.b     d7,d7
[000107de] d341                      addx.w    d1,d1
[000107e0] de07                      add.b     d7,d7
[000107e2] d542                      addx.w    d2,d2
[000107e4] de07                      add.b     d7,d7
[000107e6] d743                      addx.w    d3,d3
[000107e8] de07                      add.b     d7,d7
[000107ea] d944                      addx.w    d4,d4
[000107ec] de07                      add.b     d7,d7
[000107ee] db45                      addx.w    d5,d5
[000107f0] de07                      add.b     d7,d7
[000107f2] dd46                      addx.w    d6,d6
[000107f4] de07                      add.b     d7,d7
[000107f6] 4847                      swap      d7
[000107f8] df47                      addx.w    d7,d7
[000107fa] 4840                      swap      d0
[000107fc] 51c8 ffd2                 dbf       d0,$000107D0
[00010800] 4840                      swap      d0
[00010802] 32c0                      move.w    d0,(a1)+
[00010804] 32c1                      move.w    d1,(a1)+
[00010806] 32c2                      move.w    d2,(a1)+
[00010808] 32c3                      move.w    d3,(a1)+
[0001080a] 32c4                      move.w    d4,(a1)+
[0001080c] 32c5                      move.w    d5,(a1)+
[0001080e] 32c6                      move.w    d6,(a1)+
[00010810] 32c7                      move.w    d7,(a1)+
[00010812] 4e75                      rts
[00010814] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010818] 2c41                      movea.l   d1,a6
[0001081a] 2f08                      move.l    a0,-(a7)
[0001081c] 45e8 0020                 lea.l     32(a0),a2
[00010820] 2f22                      move.l    -(a2),-(a7)
[00010822] 2f22                      move.l    -(a2),-(a7)
[00010824] 2f22                      move.l    -(a2),-(a7)
[00010826] 2f22                      move.l    -(a2),-(a7)
[00010828] 2f22                      move.l    -(a2),-(a7)
[0001082a] 2f22                      move.l    -(a2),-(a7)
[0001082c] 2f22                      move.l    -(a2),-(a7)
[0001082e] 2f22                      move.l    -(a2),-(a7)
[00010830] 619c                      bsr.s     $000107CE
[00010832] 204f                      movea.l   a7,a0
[00010834] 5288                      addq.l    #1,a0
[00010836] 6196                      bsr.s     $000107CE
[00010838] 4fef 0020                 lea.l     32(a7),a7
[0001083c] 205f                      movea.l   (a7)+,a0
[0001083e] 41e8 0020                 lea.l     32(a0),a0
[00010842] 220e                      move.l    a6,d1
[00010844] 5381                      subq.l    #1,d1
[00010846] 6ad0                      bpl.s     $00010818
[00010848] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[0001084c] 700f                      moveq.l   #15,d0
[0001084e] 5384                      subq.l    #1,d4
[00010850] 6b2a                      bmi.s     $0001087C
[00010852] 7400                      moveq.l   #0,d2
[00010854] 2204                      move.l    d4,d1
[00010856] d1c0                      adda.l    d0,a0
[00010858] 41f0 0802                 lea.l     2(a0,d0.l),a0
[0001085c] 3a10                      move.w    (a0),d5
[0001085e] 2248                      movea.l   a0,a1
[00010860] 2448                      movea.l   a0,a2
[00010862] d480                      add.l     d0,d2
[00010864] 2602                      move.l    d2,d3
[00010866] 6004                      bra.s     $0001086C
[00010868] 2449                      movea.l   a1,a2
[0001086a] 34a1                      move.w    -(a1),(a2)
[0001086c] 5383                      subq.l    #1,d3
[0001086e] 6af8                      bpl.s     $00010868
[00010870] 3285                      move.w    d5,(a1)
[00010872] 5381                      subq.l    #1,d1
[00010874] 6ae0                      bpl.s     $00010856
[00010876] 204a                      movea.l   a2,a0
[00010878] 5380                      subq.l    #1,d0
[0001087a] 6ad6                      bpl.s     $00010852
[0001087c] 4e75                      rts
[0001087e] d080                      add.l     d0,d0
[00010880] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010884] 610c                      bsr.s     $00010892
[00010886] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[0001088a] 5288                      addq.l    #1,a0
[0001088c] 2400                      move.l    d0,d2
[0001088e] e78a                      lsl.l     #3,d2
[00010890] d3c2                      adda.l    d2,a1
[00010892] 45f1 0800                 lea.l     0(a1,d0.l),a2
[00010896] 47f2 0800                 lea.l     0(a2,d0.l),a3
[0001089a] 49f3 0800                 lea.l     0(a3,d0.l),a4
[0001089e] e588                      lsl.l     #2,d0
[000108a0] 2a40                      movea.l   d0,a5
[000108a2] 2c41                      movea.l   d1,a6
[000108a4] 700f                      moveq.l   #15,d0
[000108a6] 4840                      swap      d0
[000108a8] 4847                      swap      d7
[000108aa] 1e18                      move.b    (a0)+,d7
[000108ac] 5288                      addq.l    #1,a0
[000108ae] de07                      add.b     d7,d7
[000108b0] d140                      addx.w    d0,d0
[000108b2] de07                      add.b     d7,d7
[000108b4] d341                      addx.w    d1,d1
[000108b6] de07                      add.b     d7,d7
[000108b8] d542                      addx.w    d2,d2
[000108ba] de07                      add.b     d7,d7
[000108bc] d743                      addx.w    d3,d3
[000108be] de07                      add.b     d7,d7
[000108c0] d944                      addx.w    d4,d4
[000108c2] de07                      add.b     d7,d7
[000108c4] db45                      addx.w    d5,d5
[000108c6] de07                      add.b     d7,d7
[000108c8] dd46                      addx.w    d6,d6
[000108ca] de07                      add.b     d7,d7
[000108cc] 4847                      swap      d7
[000108ce] df47                      addx.w    d7,d7
[000108d0] 4840                      swap      d0
[000108d2] 51c8 ffd2                 dbf       d0,$000108A6
[000108d6] 4840                      swap      d0
[000108d8] 32c0                      move.w    d0,(a1)+
[000108da] 34c1                      move.w    d1,(a2)+
[000108dc] 36c2                      move.w    d2,(a3)+
[000108de] 38c3                      move.w    d3,(a4)+
[000108e0] 3384 d8fe                 move.w    d4,-2(a1,a5.l)
[000108e4] 3585 d8fe                 move.w    d5,-2(a2,a5.l)
[000108e8] 3786 d8fe                 move.w    d6,-2(a3,a5.l)
[000108ec] 3987 d8fe                 move.w    d7,-2(a4,a5.l)
[000108f0] 220e                      move.l    a6,d1
[000108f2] 5381                      subq.l    #1,d1
[000108f4] 6aac                      bpl.s     $000108A2
[000108f6] 4e75                      rts
[000108f8] d080                      add.l     d0,d0
[000108fa] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[000108fe] 610c                      bsr.s     $0001090C
[00010900] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010904] 5289                      addq.l    #1,a1
[00010906] 2400                      move.l    d0,d2
[00010908] e78a                      lsl.l     #3,d2
[0001090a] d1c2                      adda.l    d2,a0
[0001090c] 45f0 0800                 lea.l     0(a0,d0.l),a2
[00010910] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010914] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010918] e588                      lsl.l     #2,d0
[0001091a] 2a40                      movea.l   d0,a5
[0001091c] 2c41                      movea.l   d1,a6
[0001091e] 700f                      moveq.l   #15,d0
[00010920] 4840                      swap      d0
[00010922] 3018                      move.w    (a0)+,d0
[00010924] 321a                      move.w    (a2)+,d1
[00010926] 341b                      move.w    (a3)+,d2
[00010928] 361c                      move.w    (a4)+,d3
[0001092a] 3830 d8fe                 move.w    -2(a0,a5.l),d4
[0001092e] 3a32 d8fe                 move.w    -2(a2,a5.l),d5
[00010932] 3c33 d8fe                 move.w    -2(a3,a5.l),d6
[00010936] 3e34 d8fe                 move.w    -2(a4,a5.l),d7
[0001093a] 4840                      swap      d0
[0001093c] 4847                      swap      d7
[0001093e] 4840                      swap      d0
[00010940] d040                      add.w     d0,d0
[00010942] df07                      addx.b    d7,d7
[00010944] d241                      add.w     d1,d1
[00010946] df07                      addx.b    d7,d7
[00010948] d442                      add.w     d2,d2
[0001094a] df07                      addx.b    d7,d7
[0001094c] d643                      add.w     d3,d3
[0001094e] df07                      addx.b    d7,d7
[00010950] d844                      add.w     d4,d4
[00010952] df07                      addx.b    d7,d7
[00010954] da45                      add.w     d5,d5
[00010956] df07                      addx.b    d7,d7
[00010958] dc46                      add.w     d6,d6
[0001095a] df07                      addx.b    d7,d7
[0001095c] 4847                      swap      d7
[0001095e] de47                      add.w     d7,d7
[00010960] 4847                      swap      d7
[00010962] df07                      addx.b    d7,d7
[00010964] 12c7                      move.b    d7,(a1)+
[00010966] 5289                      addq.l    #1,a1
[00010968] 4840                      swap      d0
[0001096a] 51c8 ffd2                 dbf       d0,$0001093E
[0001096e] 220e                      move.l    a6,d1
[00010970] 5381                      subq.l    #1,d1
[00010972] 6aa8                      bpl.s     $0001091C
[00010974] 4e75                      rts
[00010976] b3c8                      cmpa.l    a0,a1
[00010978] 670e                      beq.s     $00010988
[0001097a] e289                      lsr.l     #1,d1
[0001097c] 6504                      bcs.s     $00010982
[0001097e] 32d8                      move.w    (a0)+,(a1)+
[00010980] 6002                      bra.s     $00010984
[00010982] 22d8                      move.l    (a0)+,(a1)+
[00010984] 5381                      subq.l    #1,d1
[00010986] 6afa                      bpl.s     $00010982
[00010988] 2c5f                      movea.l   (a7)+,a6
[0001098a] 4e75                      rts
[0001098c] 4a6e 01b2                 tst.w     434(a6)
[00010990] 670a                      beq.s     $0001099C
[00010992] 206e 01ae                 movea.l   430(a6),a0
[00010996] c3ee 01b2                 muls.w    434(a6),d1
[0001099a] 6008                      bra.s     $000109A4
[0001099c] 2078 044e                 movea.l   ($0000044E).w,a0
[000109a0] c3f8 206e                 muls.w    ($0000206E).w,d1
[000109a4] d1c1                      adda.l    d1,a0
[000109a6] d040                      add.w     d0,d0
[000109a8] d0c0                      adda.w    d0,a0
[000109aa] 7000                      moveq.l   #0,d0
[000109ac] 3010                      move.w    (a0),d0
[000109ae] 4e75                      rts
[000109b0] 4a6e 01b2                 tst.w     434(a6)
[000109b4] 670a                      beq.s     $000109C0
[000109b6] 206e 01ae                 movea.l   430(a6),a0
[000109ba] c3ee 01b2                 muls.w    434(a6),d1
[000109be] 6008                      bra.s     $000109C8
[000109c0] 2078 044e                 movea.l   ($0000044E).w,a0
[000109c4] c3f8 206e                 muls.w    ($0000206E).w,d1
[000109c8] d1c1                      adda.l    d1,a0
[000109ca] d040                      add.w     d0,d0
[000109cc] d0c0                      adda.w    d0,a0
[000109ce] 3082                      move.w    d2,(a0)
[000109d0] 4e75                      rts
[000109d2] 2278 044e                 movea.l   ($0000044E).w,a1
[000109d6] 3678 206e                 movea.w   ($0000206E).w,a3
[000109da] 4a6e 01b2                 tst.w     434(a6)
[000109de] 6708                      beq.s     $000109E8
[000109e0] 226e 01ae                 movea.l   430(a6),a1
[000109e4] 366e 01b2                 movea.w   434(a6),a3
[000109e8] 426e 01ec                 clr.w     492(a6)
[000109ec] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[000109f2] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[000109f8] 3d7c 0000 01c8            move.w    #$0000,456(a6)
[000109fe] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00010a04] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[00010a0a] 6600 0e14                 bne       $00011820
[00010a0e] 426e 01ea                 clr.w     490(a6)
[00010a12] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[00010a18] 6000 0e06                 bra       $00011820
[00010a1c] 4a6e 00ca                 tst.w     202(a6)
[00010a20] 675a                      beq.s     $00010A7C
[00010a22] 2f08                      move.l    a0,-(a7)
[00010a24] 206e 00c6                 movea.l   198(a6),a0
[00010a28] 780f                      moveq.l   #15,d4
[00010a2a] c841                      and.w     d1,d4
[00010a2c] eb4c                      lsl.w     #5,d4
[00010a2e] d0c4                      adda.w    d4,a0
[00010a30] 3838 206e                 move.w    ($0000206E).w,d4
[00010a34] 2278 044e                 movea.l   ($0000044E).w,a1
[00010a38] 4a6e 01b2                 tst.w     434(a6)
[00010a3c] 6708                      beq.s     $00010A46
[00010a3e] 382e 01b2                 move.w    434(a6),d4
[00010a42] 226e 01ae                 movea.l   430(a6),a1
[00010a46] 9440                      sub.w     d0,d2
[00010a48] d040                      add.w     d0,d0
[00010a4a] c2c4                      mulu.w    d4,d1
[00010a4c] 48c0                      ext.l     d0
[00010a4e] d280                      add.l     d0,d1
[00010a50] 7e20                      moveq.l   #32,d7
[00010a52] 7c0f                      moveq.l   #15,d6
[00010a54] b446                      cmp.w     d6,d2
[00010a56] 6c02                      bge.s     $00010A5A
[00010a58] 3c02                      move.w    d2,d6
[00010a5a] 701f                      moveq.l   #31,d0
[00010a5c] c041                      and.w     d1,d0
[00010a5e] 3a30 0000                 move.w    0(a0,d0.w),d5
[00010a62] 3802                      move.w    d2,d4
[00010a64] e84c                      lsr.w     #4,d4
[00010a66] 2241                      movea.l   d1,a1
[00010a68] 3285                      move.w    d5,(a1)
[00010a6a] d2c7                      adda.w    d7,a1
[00010a6c] 51cc fffa                 dbf       d4,$00010A68
[00010a70] 5481                      addq.l    #2,d1
[00010a72] 5342                      subq.w    #1,d2
[00010a74] 51ce ffe4                 dbf       d6,$00010A5A
[00010a78] 205f                      movea.l   (a7)+,a0
[00010a7a] 4e75                      rts
[00010a7c] 226e 00c6                 movea.l   198(a6),a1
[00010a80] 780f                      moveq.l   #15,d4
[00010a82] c841                      and.w     d1,d4
[00010a84] d844                      add.w     d4,d4
[00010a86] 3c31 4000                 move.w    0(a1,d4.w),d6
[00010a8a] 43ee 0458                 lea.l     1112(a6),a1
[00010a8e] 3a2e 00be                 move.w    190(a6),d5
[00010a92] da45                      add.w     d5,d5
[00010a94] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010a98] 3805                      move.w    d5,d4
[00010a9a] 4844                      swap      d4
[00010a9c] 3805                      move.w    d5,d4
[00010a9e] 4a6e 01b2                 tst.w     434(a6)
[00010aa2] 672e                      beq.s     $00010AD2
[00010aa4] 226e 01ae                 movea.l   430(a6),a1
[00010aa8] c3ee 01b2                 muls.w    434(a6),d1
[00010aac] 602c                      bra.s     $00010ADA
[00010aae] 43ee 0458                 lea.l     1112(a6),a1
[00010ab2] 3a2e 0046                 move.w    70(a6),d5
[00010ab6] da45                      add.w     d5,d5
[00010ab8] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010abc] 3805                      move.w    d5,d4
[00010abe] 4844                      swap      d4
[00010ac0] 3805                      move.w    d5,d4
[00010ac2] 4a6e 01b2                 tst.w     434(a6)
[00010ac6] 670a                      beq.s     $00010AD2
[00010ac8] 226e 01ae                 movea.l   430(a6),a1
[00010acc] c3ee 01b2                 muls.w    434(a6),d1
[00010ad0] 6008                      bra.s     $00010ADA
[00010ad2] 2278 044e                 movea.l   ($0000044E).w,a1
[00010ad6] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010ada] 48c0                      ext.l     d0
[00010adc] d280                      add.l     d0,d1
[00010ade] d280                      add.l     d0,d1
[00010ae0] d3c1                      adda.l    d1,a1
[00010ae2] de47                      add.w     d7,d7
[00010ae4] 3e3b 7008                 move.w    $00010AEE(pc,d7.w),d7
[00010ae8] 4efb 7004                 jmp       $00010AEE(pc,d7.w)
[00010aec] 4e75                      rts
[00010aee] 0008 009a                 ori.b     #$9A,a0 ; apollo only
[00010af2] 0144                      bchg      d0,d4
[00010af4] 0098 bc7c ffff            ori.l     #$BC7CFFFF,(a0)+
[00010afa] 6700 01c4                 beq       $00010CC0
[00010afe] 2f0b                      move.l    a3,-(a7)
[00010b00] 3f05                      move.w    d5,-(a7)
[00010b02] 9440                      sub.w     d0,d2
[00010b04] c07c 000f                 and.w     #$000F,d0
[00010b08] e17e                      rol.w     d0,d6
[00010b0a] 7220                      moveq.l   #32,d1
[00010b0c] 700f                      moveq.l   #15,d0
[00010b0e] b440                      cmp.w     d0,d2
[00010b10] 6c02                      bge.s     $00010B14
[00010b12] 3002                      move.w    d2,d0
[00010b14] dc46                      add.w     d6,d6
[00010b16] 54c5                      scc       d5
[00010b18] 4885                      ext.w     d5
[00010b1a] 8a57                      or.w      (a7),d5
[00010b1c] 3802                      move.w    d2,d4
[00010b1e] e84c                      lsr.w     #4,d4
[00010b20] 3e04                      move.w    d4,d7
[00010b22] e84c                      lsr.w     #4,d4
[00010b24] 4647                      not.w     d7
[00010b26] 0247 000f                 andi.w    #$000F,d7
[00010b2a] de47                      add.w     d7,d7
[00010b2c] de47                      add.w     d7,d7
[00010b2e] 2649                      movea.l   a1,a3
[00010b30] 4efb 7002                 jmp       $00010B34(pc,d7.w)
[00010b34] 3685                      move.w    d5,(a3)
[00010b36] d6c1                      adda.w    d1,a3
[00010b38] 3685                      move.w    d5,(a3)
[00010b3a] d6c1                      adda.w    d1,a3
[00010b3c] 3685                      move.w    d5,(a3)
[00010b3e] d6c1                      adda.w    d1,a3
[00010b40] 3685                      move.w    d5,(a3)
[00010b42] d6c1                      adda.w    d1,a3
[00010b44] 3685                      move.w    d5,(a3)
[00010b46] d6c1                      adda.w    d1,a3
[00010b48] 3685                      move.w    d5,(a3)
[00010b4a] d6c1                      adda.w    d1,a3
[00010b4c] 3685                      move.w    d5,(a3)
[00010b4e] d6c1                      adda.w    d1,a3
[00010b50] 3685                      move.w    d5,(a3)
[00010b52] d6c1                      adda.w    d1,a3
[00010b54] 3685                      move.w    d5,(a3)
[00010b56] d6c1                      adda.w    d1,a3
[00010b58] 3685                      move.w    d5,(a3)
[00010b5a] d6c1                      adda.w    d1,a3
[00010b5c] 3685                      move.w    d5,(a3)
[00010b5e] d6c1                      adda.w    d1,a3
[00010b60] 3685                      move.w    d5,(a3)
[00010b62] d6c1                      adda.w    d1,a3
[00010b64] 3685                      move.w    d5,(a3)
[00010b66] d6c1                      adda.w    d1,a3
[00010b68] 3685                      move.w    d5,(a3)
[00010b6a] d6c1                      adda.w    d1,a3
[00010b6c] 3685                      move.w    d5,(a3)
[00010b6e] d6c1                      adda.w    d1,a3
[00010b70] 3685                      move.w    d5,(a3)
[00010b72] d6c1                      adda.w    d1,a3
[00010b74] 51cc ffbe                 dbf       d4,$00010B34
[00010b78] 5489                      addq.l    #2,a1
[00010b7a] 5342                      subq.w    #1,d2
[00010b7c] 51c8 ff96                 dbf       d0,$00010B14
[00010b80] 3a1f                      move.w    (a7)+,d5
[00010b82] 265f                      movea.l   (a7)+,a3
[00010b84] 4e75                      rts
[00010b86] 4646                      not.w     d6
[00010b88] bc7c ffff                 cmp.w     #$FFFF,d6
[00010b8c] 6700 0132                 beq       $00010CC0
[00010b90] 2f0b                      move.l    a3,-(a7)
[00010b92] 9440                      sub.w     d0,d2
[00010b94] c07c 000f                 and.w     #$000F,d0
[00010b98] e17e                      rol.w     d0,d6
[00010b9a] 7220                      moveq.l   #32,d1
[00010b9c] 700f                      moveq.l   #15,d0
[00010b9e] b440                      cmp.w     d0,d2
[00010ba0] 6c02                      bge.s     $00010BA4
[00010ba2] 3002                      move.w    d2,d0
[00010ba4] dc46                      add.w     d6,d6
[00010ba6] 645c                      bcc.s     $00010C04
[00010ba8] 3802                      move.w    d2,d4
[00010baa] e84c                      lsr.w     #4,d4
[00010bac] 3e04                      move.w    d4,d7
[00010bae] e84c                      lsr.w     #4,d4
[00010bb0] 4647                      not.w     d7
[00010bb2] 0247 000f                 andi.w    #$000F,d7
[00010bb6] de47                      add.w     d7,d7
[00010bb8] de47                      add.w     d7,d7
[00010bba] 2649                      movea.l   a1,a3
[00010bbc] 4efb 7002                 jmp       $00010BC0(pc,d7.w)
[00010bc0] 3685                      move.w    d5,(a3)
[00010bc2] d6c1                      adda.w    d1,a3
[00010bc4] 3685                      move.w    d5,(a3)
[00010bc6] d6c1                      adda.w    d1,a3
[00010bc8] 3685                      move.w    d5,(a3)
[00010bca] d6c1                      adda.w    d1,a3
[00010bcc] 3685                      move.w    d5,(a3)
[00010bce] d6c1                      adda.w    d1,a3
[00010bd0] 3685                      move.w    d5,(a3)
[00010bd2] d6c1                      adda.w    d1,a3
[00010bd4] 3685                      move.w    d5,(a3)
[00010bd6] d6c1                      adda.w    d1,a3
[00010bd8] 3685                      move.w    d5,(a3)
[00010bda] d6c1                      adda.w    d1,a3
[00010bdc] 3685                      move.w    d5,(a3)
[00010bde] d6c1                      adda.w    d1,a3
[00010be0] 3685                      move.w    d5,(a3)
[00010be2] d6c1                      adda.w    d1,a3
[00010be4] 3685                      move.w    d5,(a3)
[00010be6] d6c1                      adda.w    d1,a3
[00010be8] 3685                      move.w    d5,(a3)
[00010bea] d6c1                      adda.w    d1,a3
[00010bec] 3685                      move.w    d5,(a3)
[00010bee] d6c1                      adda.w    d1,a3
[00010bf0] 3685                      move.w    d5,(a3)
[00010bf2] d6c1                      adda.w    d1,a3
[00010bf4] 3685                      move.w    d5,(a3)
[00010bf6] d6c1                      adda.w    d1,a3
[00010bf8] 3685                      move.w    d5,(a3)
[00010bfa] d6c1                      adda.w    d1,a3
[00010bfc] 3685                      move.w    d5,(a3)
[00010bfe] d6c1                      adda.w    d1,a3
[00010c00] 51cc ffbe                 dbf       d4,$00010BC0
[00010c04] 5489                      addq.l    #2,a1
[00010c06] 5342                      subq.w    #1,d2
[00010c08] 51c8 ff9a                 dbf       d0,$00010BA4
[00010c0c] 265f                      movea.l   (a7)+,a3
[00010c0e] 4e75                      rts
[00010c10] 5489                      addq.l    #2,a1
[00010c12] 51ca 0004                 dbf       d2,$00010C18
[00010c16] 4e75                      rts
[00010c18] e24a                      lsr.w     #1,d2
[00010c1a] 78ff                      moveq.l   #-1,d4
[00010c1c] 4644                      not.w     d4
[00010c1e] 2009                      move.l    a1,d0
[00010c20] 0800 0001                 btst      #1,d0
[00010c24] 6704                      beq.s     $00010C2A
[00010c26] 5589                      subq.l    #2,a1
[00010c28] 4684                      not.l     d4
[00010c2a] b999                      eor.l     d4,(a1)+
[00010c2c] 51ca fffc                 dbf       d2,$00010C2A
[00010c30] 4e75                      rts
[00010c32] 9440                      sub.w     d0,d2
[00010c34] c07c 000f                 and.w     #$000F,d0
[00010c38] e17e                      rol.w     d0,d6
[00010c3a] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010c3e] 67d8                      beq.s     $00010C18
[00010c40] bc7c 5555                 cmp.w     #$5555,d6
[00010c44] 67ca                      beq.s     $00010C10
[00010c46] 2f0b                      move.l    a3,-(a7)
[00010c48] 7aff                      moveq.l   #-1,d5
[00010c4a] 7220                      moveq.l   #32,d1
[00010c4c] 700f                      moveq.l   #15,d0
[00010c4e] b440                      cmp.w     d0,d2
[00010c50] 6c02                      bge.s     $00010C54
[00010c52] 3002                      move.w    d2,d0
[00010c54] dc46                      add.w     d6,d6
[00010c56] 645c                      bcc.s     $00010CB4
[00010c58] 3802                      move.w    d2,d4
[00010c5a] e84c                      lsr.w     #4,d4
[00010c5c] 3e04                      move.w    d4,d7
[00010c5e] e84c                      lsr.w     #4,d4
[00010c60] 4647                      not.w     d7
[00010c62] 0247 000f                 andi.w    #$000F,d7
[00010c66] de47                      add.w     d7,d7
[00010c68] de47                      add.w     d7,d7
[00010c6a] 2649                      movea.l   a1,a3
[00010c6c] 4efb 7002                 jmp       $00010C70(pc,d7.w)
[00010c70] 4653                      not.w     (a3)
[00010c72] d6c1                      adda.w    d1,a3
[00010c74] 4653                      not.w     (a3)
[00010c76] d6c1                      adda.w    d1,a3
[00010c78] 4653                      not.w     (a3)
[00010c7a] d6c1                      adda.w    d1,a3
[00010c7c] 4653                      not.w     (a3)
[00010c7e] d6c1                      adda.w    d1,a3
[00010c80] 4653                      not.w     (a3)
[00010c82] d6c1                      adda.w    d1,a3
[00010c84] 4653                      not.w     (a3)
[00010c86] d6c1                      adda.w    d1,a3
[00010c88] 4653                      not.w     (a3)
[00010c8a] d6c1                      adda.w    d1,a3
[00010c8c] 4653                      not.w     (a3)
[00010c8e] d6c1                      adda.w    d1,a3
[00010c90] 4653                      not.w     (a3)
[00010c92] d6c1                      adda.w    d1,a3
[00010c94] 4653                      not.w     (a3)
[00010c96] d6c1                      adda.w    d1,a3
[00010c98] 4653                      not.w     (a3)
[00010c9a] d6c1                      adda.w    d1,a3
[00010c9c] 4653                      not.w     (a3)
[00010c9e] d6c1                      adda.w    d1,a3
[00010ca0] 4653                      not.w     (a3)
[00010ca2] d6c1                      adda.w    d1,a3
[00010ca4] 4653                      not.w     (a3)
[00010ca6] d6c1                      adda.w    d1,a3
[00010ca8] 4653                      not.w     (a3)
[00010caa] d6c1                      adda.w    d1,a3
[00010cac] 4653                      not.w     (a3)
[00010cae] d6c1                      adda.w    d1,a3
[00010cb0] 51cc ffbe                 dbf       d4,$00010C70
[00010cb4] 5489                      addq.l    #2,a1
[00010cb6] 5342                      subq.w    #1,d2
[00010cb8] 51c8 ff9a                 dbf       d0,$00010C54
[00010cbc] 265f                      movea.l   (a7)+,a3
[00010cbe] 4e75                      rts
[00010cc0] 9440                      sub.w     d0,d2
[00010cc2] 32c4                      move.w    d4,(a1)+
[00010cc4] 51ca fffc                 dbf       d2,$00010CC2
[00010cc8] 4e75                      rts
[00010cca] 9641                      sub.w     d1,d3
[00010ccc] 43ee 0458                 lea.l     1112(a6),a1
[00010cd0] 382e 0046                 move.w    70(a6),d4
[00010cd4] d844                      add.w     d4,d4
[00010cd6] 3831 4000                 move.w    0(a1,d4.w),d4
[00010cda] 2278 044e                 movea.l   ($0000044E).w,a1
[00010cde] 3a38 206e                 move.w    ($0000206E).w,d5
[00010ce2] 4a6e 01b2                 tst.w     434(a6)
[00010ce6] 6708                      beq.s     $00010CF0
[00010ce8] 226e 01ae                 movea.l   430(a6),a1
[00010cec] 3a2e 01b2                 move.w    434(a6),d5
[00010cf0] c3c5                      muls.w    d5,d1
[00010cf2] d3c1                      adda.l    d1,a1
[00010cf4] d040                      add.w     d0,d0
[00010cf6] d2c0                      adda.w    d0,a1
[00010cf8] de47                      add.w     d7,d7
[00010cfa] 3e3b 7006                 move.w    $00010D02(pc,d7.w),d7
[00010cfe] 4efb 7002                 jmp       $00010D02(pc,d7.w)
J1:
[00010d02] 0126                      dc.w $0126   ; $00010e28-$00010d02
[00010d04] 000a                      dc.w $000a   ; $00010d0c-$00010d02
[00010d06] 009c                      dc.w $009c   ; $00010d9e-$00010d02
[00010d08] 0008                      dc.w $0008   ; $00010d0a-$00010d02
[00010d0a] 4646                      not.w     d6
[00010d0c] 3f05                      move.w    d5,-(a7)
[00010d0e] 48c5                      ext.l     d5
[00010d10] e98d                      lsl.l     #4,d5
[00010d12] 700f                      moveq.l   #15,d0
[00010d14] b640                      cmp.w     d0,d3
[00010d16] 6c02                      bge.s     $00010D1A
[00010d18] 3003                      move.w    d3,d0
[00010d1a] 2409                      move.l    a1,d2
[00010d1c] dc46                      add.w     d6,d6
[00010d1e] 645a                      bcc.s     $00010D7A
[00010d20] 3203                      move.w    d3,d1
[00010d22] e849                      lsr.w     #4,d1
[00010d24] 3e01                      move.w    d1,d7
[00010d26] e849                      lsr.w     #4,d1
[00010d28] 4647                      not.w     d7
[00010d2a] 0247 000f                 andi.w    #$000F,d7
[00010d2e] de47                      add.w     d7,d7
[00010d30] de47                      add.w     d7,d7
[00010d32] 4efb 7002                 jmp       $00010D36(pc,d7.w)
[00010d36] 3284                      move.w    d4,(a1)
[00010d38] d3c5                      adda.l    d5,a1
[00010d3a] 3284                      move.w    d4,(a1)
[00010d3c] d3c5                      adda.l    d5,a1
[00010d3e] 3284                      move.w    d4,(a1)
[00010d40] d3c5                      adda.l    d5,a1
[00010d42] 3284                      move.w    d4,(a1)
[00010d44] d3c5                      adda.l    d5,a1
[00010d46] 3284                      move.w    d4,(a1)
[00010d48] d3c5                      adda.l    d5,a1
[00010d4a] 3284                      move.w    d4,(a1)
[00010d4c] d3c5                      adda.l    d5,a1
[00010d4e] 3284                      move.w    d4,(a1)
[00010d50] d3c5                      adda.l    d5,a1
[00010d52] 3284                      move.w    d4,(a1)
[00010d54] d3c5                      adda.l    d5,a1
[00010d56] 3284                      move.w    d4,(a1)
[00010d58] d3c5                      adda.l    d5,a1
[00010d5a] 3284                      move.w    d4,(a1)
[00010d5c] d3c5                      adda.l    d5,a1
[00010d5e] 3284                      move.w    d4,(a1)
[00010d60] d3c5                      adda.l    d5,a1
[00010d62] 3284                      move.w    d4,(a1)
[00010d64] d3c5                      adda.l    d5,a1
[00010d66] 3284                      move.w    d4,(a1)
[00010d68] d3c5                      adda.l    d5,a1
[00010d6a] 3284                      move.w    d4,(a1)
[00010d6c] d3c5                      adda.l    d5,a1
[00010d6e] 3284                      move.w    d4,(a1)
[00010d70] d3c5                      adda.l    d5,a1
[00010d72] 3284                      move.w    d4,(a1)
[00010d74] d3c5                      adda.l    d5,a1
[00010d76] 51c9 ffbe                 dbf       d1,$00010D36
[00010d7a] 2242                      movea.l   d2,a1
[00010d7c] d2d7                      adda.w    (a7),a1
[00010d7e] 5343                      subq.w    #1,d3
[00010d80] 51c8 ff98                 dbf       d0,$00010D1A
[00010d84] 548f                      addq.l    #2,a7
[00010d86] 4e75                      rts
[00010d88] d2c5                      adda.w    d5,a1
[00010d8a] 51cb 0004                 dbf       d3,$00010D90
[00010d8e] 4e75                      rts
[00010d90] da45                      add.w     d5,d5
[00010d92] e24b                      lsr.w     #1,d3
[00010d94] b951                      eor.w     d4,(a1)
[00010d96] d2c5                      adda.w    d5,a1
[00010d98] 51cb fffa                 dbf       d3,$00010D94
[00010d9c] 4e75                      rts
[00010d9e] 78ff                      moveq.l   #-1,d4
[00010da0] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010da4] 67ea                      beq.s     $00010D90
[00010da6] bc7c 5555                 cmp.w     #$5555,d6
[00010daa] 67dc                      beq.s     $00010D88
[00010dac] 3f05                      move.w    d5,-(a7)
[00010dae] 48c5                      ext.l     d5
[00010db0] e98d                      lsl.l     #4,d5
[00010db2] 700f                      moveq.l   #15,d0
[00010db4] b640                      cmp.w     d0,d3
[00010db6] 6c02                      bge.s     $00010DBA
[00010db8] 3003                      move.w    d3,d0
[00010dba] 2409                      move.l    a1,d2
[00010dbc] dc46                      add.w     d6,d6
[00010dbe] 645a                      bcc.s     $00010E1A
[00010dc0] 3203                      move.w    d3,d1
[00010dc2] e849                      lsr.w     #4,d1
[00010dc4] 3e01                      move.w    d1,d7
[00010dc6] e849                      lsr.w     #4,d1
[00010dc8] 4647                      not.w     d7
[00010dca] 0247 000f                 andi.w    #$000F,d7
[00010dce] de47                      add.w     d7,d7
[00010dd0] de47                      add.w     d7,d7
[00010dd2] 4efb 7002                 jmp       $00010DD6(pc,d7.w)
[00010dd6] b951                      eor.w     d4,(a1)
[00010dd8] d3c5                      adda.l    d5,a1
[00010dda] b951                      eor.w     d4,(a1)
[00010ddc] d3c5                      adda.l    d5,a1
[00010dde] b951                      eor.w     d4,(a1)
[00010de0] d3c5                      adda.l    d5,a1
[00010de2] b951                      eor.w     d4,(a1)
[00010de4] d3c5                      adda.l    d5,a1
[00010de6] b951                      eor.w     d4,(a1)
[00010de8] d3c5                      adda.l    d5,a1
[00010dea] b951                      eor.w     d4,(a1)
[00010dec] d3c5                      adda.l    d5,a1
[00010dee] b951                      eor.w     d4,(a1)
[00010df0] d3c5                      adda.l    d5,a1
[00010df2] b951                      eor.w     d4,(a1)
[00010df4] d3c5                      adda.l    d5,a1
[00010df6] b951                      eor.w     d4,(a1)
[00010df8] d3c5                      adda.l    d5,a1
[00010dfa] b951                      eor.w     d4,(a1)
[00010dfc] d3c5                      adda.l    d5,a1
[00010dfe] b951                      eor.w     d4,(a1)
[00010e00] d3c5                      adda.l    d5,a1
[00010e02] b951                      eor.w     d4,(a1)
[00010e04] d3c5                      adda.l    d5,a1
[00010e06] b951                      eor.w     d4,(a1)
[00010e08] d3c5                      adda.l    d5,a1
[00010e0a] b951                      eor.w     d4,(a1)
[00010e0c] d3c5                      adda.l    d5,a1
[00010e0e] b951                      eor.w     d4,(a1)
[00010e10] d3c5                      adda.l    d5,a1
[00010e12] b951                      eor.w     d4,(a1)
[00010e14] d3c5                      adda.l    d5,a1
[00010e16] 51c9 ffbe                 dbf       d1,$00010DD6
[00010e1a] 2242                      movea.l   d2,a1
[00010e1c] d2d7                      adda.w    (a7),a1
[00010e1e] 5343                      subq.w    #1,d3
[00010e20] 51c8 ff98                 dbf       d0,$00010DBA
[00010e24] 548f                      addq.l    #2,a7
[00010e26] 4e75                      rts
[00010e28] bc7c ffff                 cmp.w     #$FFFF,d6
[00010e2c] 6700 0082                 beq       $00010EB0
[00010e30] 3f05                      move.w    d5,-(a7)
[00010e32] 48c5                      ext.l     d5
[00010e34] e98d                      lsl.l     #4,d5
[00010e36] 700f                      moveq.l   #15,d0
[00010e38] b640                      cmp.w     d0,d3
[00010e3a] 6c02                      bge.s     $00010E3E
[00010e3c] 3003                      move.w    d3,d0
[00010e3e] 2f09                      move.l    a1,-(a7)
[00010e40] dc46                      add.w     d6,d6
[00010e42] 54c2                      scc       d2
[00010e44] 4882                      ext.w     d2
[00010e46] 8444                      or.w      d4,d2
[00010e48] 3203                      move.w    d3,d1
[00010e4a] e849                      lsr.w     #4,d1
[00010e4c] 3e01                      move.w    d1,d7
[00010e4e] e849                      lsr.w     #4,d1
[00010e50] 4647                      not.w     d7
[00010e52] 0247 000f                 andi.w    #$000F,d7
[00010e56] de47                      add.w     d7,d7
[00010e58] de47                      add.w     d7,d7
[00010e5a] 4efb 7002                 jmp       $00010E5E(pc,d7.w)
[00010e5e] 3282                      move.w    d2,(a1)
[00010e60] d3c5                      adda.l    d5,a1
[00010e62] 3282                      move.w    d2,(a1)
[00010e64] d3c5                      adda.l    d5,a1
[00010e66] 3282                      move.w    d2,(a1)
[00010e68] d3c5                      adda.l    d5,a1
[00010e6a] 3282                      move.w    d2,(a1)
[00010e6c] d3c5                      adda.l    d5,a1
[00010e6e] 3282                      move.w    d2,(a1)
[00010e70] d3c5                      adda.l    d5,a1
[00010e72] 3282                      move.w    d2,(a1)
[00010e74] d3c5                      adda.l    d5,a1
[00010e76] 3282                      move.w    d2,(a1)
[00010e78] d3c5                      adda.l    d5,a1
[00010e7a] 3282                      move.w    d2,(a1)
[00010e7c] d3c5                      adda.l    d5,a1
[00010e7e] 3282                      move.w    d2,(a1)
[00010e80] d3c5                      adda.l    d5,a1
[00010e82] 3282                      move.w    d2,(a1)
[00010e84] d3c5                      adda.l    d5,a1
[00010e86] 3282                      move.w    d2,(a1)
[00010e88] d3c5                      adda.l    d5,a1
[00010e8a] 3282                      move.w    d2,(a1)
[00010e8c] d3c5                      adda.l    d5,a1
[00010e8e] 3282                      move.w    d2,(a1)
[00010e90] d3c5                      adda.l    d5,a1
[00010e92] 3282                      move.w    d2,(a1)
[00010e94] d3c5                      adda.l    d5,a1
[00010e96] 3282                      move.w    d2,(a1)
[00010e98] d3c5                      adda.l    d5,a1
[00010e9a] 3282                      move.w    d2,(a1)
[00010e9c] d3c5                      adda.l    d5,a1
[00010e9e] 51c9 ffbe                 dbf       d1,$00010E5E
[00010ea2] 225f                      movea.l   (a7)+,a1
[00010ea4] d2d7                      adda.w    (a7),a1
[00010ea6] 5343                      subq.w    #1,d3
[00010ea8] 51c8 ff94                 dbf       d0,$00010E3E
[00010eac] 548f                      addq.l    #2,a7
[00010eae] 4e75                      rts
[00010eb0] 3403                      move.w    d3,d2
[00010eb2] 4642                      not.w     d2
[00010eb4] c47c 000f                 and.w     #$000F,d2
[00010eb8] d442                      add.w     d2,d2
[00010eba] d442                      add.w     d2,d2
[00010ebc] e84b                      lsr.w     #4,d3
[00010ebe] 4efb 2002                 jmp       $00010EC2(pc,d2.w)
[00010ec2] 3284                      move.w    d4,(a1)
[00010ec4] d2c5                      adda.w    d5,a1
[00010ec6] 3284                      move.w    d4,(a1)
[00010ec8] d2c5                      adda.w    d5,a1
[00010eca] 3284                      move.w    d4,(a1)
[00010ecc] d2c5                      adda.w    d5,a1
[00010ece] 3284                      move.w    d4,(a1)
[00010ed0] d2c5                      adda.w    d5,a1
[00010ed2] 3284                      move.w    d4,(a1)
[00010ed4] d2c5                      adda.w    d5,a1
[00010ed6] 3284                      move.w    d4,(a1)
[00010ed8] d2c5                      adda.w    d5,a1
[00010eda] 3284                      move.w    d4,(a1)
[00010edc] d2c5                      adda.w    d5,a1
[00010ede] 3284                      move.w    d4,(a1)
[00010ee0] d2c5                      adda.w    d5,a1
[00010ee2] 3284                      move.w    d4,(a1)
[00010ee4] d2c5                      adda.w    d5,a1
[00010ee6] 3284                      move.w    d4,(a1)
[00010ee8] d2c5                      adda.w    d5,a1
[00010eea] 3284                      move.w    d4,(a1)
[00010eec] d2c5                      adda.w    d5,a1
[00010eee] 3284                      move.w    d4,(a1)
[00010ef0] d2c5                      adda.w    d5,a1
[00010ef2] 3284                      move.w    d4,(a1)
[00010ef4] d2c5                      adda.w    d5,a1
[00010ef6] 3284                      move.w    d4,(a1)
[00010ef8] d2c5                      adda.w    d5,a1
[00010efa] 3284                      move.w    d4,(a1)
[00010efc] d2c5                      adda.w    d5,a1
[00010efe] 3284                      move.w    d4,(a1)
[00010f00] d2c5                      adda.w    d5,a1
[00010f02] 51cb ffbe                 dbf       d3,$00010EC2
[00010f06] 4e75                      rts
[00010f08] 2278 044e                 movea.l   ($0000044E).w,a1
[00010f0c] 3a38 206e                 move.w    ($0000206E).w,d5
[00010f10] 4a6e 01b2                 tst.w     434(a6)
[00010f14] 6708                      beq.s     $00010F1E
[00010f16] 226e 01ae                 movea.l   430(a6),a1
[00010f1a] 3a2e 01b2                 move.w    434(a6),d5
[00010f1e] 3805                      move.w    d5,d4
[00010f20] c9c1                      muls.w    d1,d4
[00010f22] d3c4                      adda.l    d4,a1
[00010f24] d2c0                      adda.w    d0,a1
[00010f26] d2c0                      adda.w    d0,a1
[00010f28] 780f                      moveq.l   #15,d4
[00010f2a] c840                      and.w     d0,d4
[00010f2c] e97e                      rol.w     d4,d6
[00010f2e] 9440                      sub.w     d0,d2
[00010f30] 6b3a                      bmi.s     $00010F6C
[00010f32] 9641                      sub.w     d1,d3
[00010f34] 6a04                      bpl.s     $00010F3A
[00010f36] 4443                      neg.w     d3
[00010f38] 4445                      neg.w     d5
[00010f3a] 2f08                      move.l    a0,-(a7)
[00010f3c] 41ee 0458                 lea.l     1112(a6),a0
[00010f40] 382e 0046                 move.w    70(a6),d4
[00010f44] d844                      add.w     d4,d4
[00010f46] 3830 4000                 move.w    0(a0,d4.w),d4
[00010f4a] 205f                      movea.l   (a7)+,a0
[00010f4c] b443                      cmp.w     d3,d2
[00010f4e] 6d26                      blt.s     $00010F76
[00010f50] 3002                      move.w    d2,d0
[00010f52] d06e 004e                 add.w     78(a6),d0
[00010f56] 6b14                      bmi.s     $00010F6C
[00010f58] 3203                      move.w    d3,d1
[00010f5a] d241                      add.w     d1,d1
[00010f5c] 4442                      neg.w     d2
[00010f5e] 3602                      move.w    d2,d3
[00010f60] d442                      add.w     d2,d2
[00010f62] de47                      add.w     d7,d7
[00010f64] 3e3b 7008                 move.w    $00010F6E(pc,d7.w),d7
[00010f68] 4efb 7004                 jmp       $00010F6E(pc,d7.w)
[00010f6c] 4e75                      rts
[00010f6e] 002a 0070 0096            ori.b     #$70,150(a2)
[00010f74] 006e 3003 d06e            ori.w     #$3003,-12178(a6)
[00010f7a] 004e 6bee                 ori.w     #$6BEE,a6 ; apollo only
[00010f7e] 4443                      neg.w     d3
[00010f80] 3203                      move.w    d3,d1
[00010f82] d241                      add.w     d1,d1
[00010f84] d442                      add.w     d2,d2
[00010f86] de47                      add.w     d7,d7
[00010f88] 3e3b 7006                 move.w    $00010F90(pc,d7.w),d7
[00010f8c] 4efb 7002                 jmp       $00010F90(pc,d7.w)
J2:
[00010f90] 009c                      dc.w $009c   ; $0001102c-$00010f90
[00010f92] 00e8                      dc.w $00e8   ; $00011078-$00010f90
[00010f94] 0104                      dc.w $0104   ; $00011094-$00010f90
[00010f96] 00e6                      dc.w $00e6   ; $00011076-$00010f90
[00010f98] bc7c                      dc.w $bc7c   ; $0000cc0c-$00010f90
[00010f9a] ffff                      dc.w $ffff   ; $00010f8f-$00010f90
[00010f9c] 6728                      dc.w $6728   ; $000176b8-$00010f90
[00010f9e] 7eff                      dc.w $7eff   ; $00018e8f-$00010f90
[00010fa0] e35e                      dc.w $e35e   ; $0000f2ee-$00010f90
[00010fa2] 640c                      dc.w $640c   ; $0001739c-$00010f90
[00010fa4] 32c4                      dc.w $32c4   ; $00014254-$00010f90
[00010fa6] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[00010fa8] 6a12                      dc.w $6a12   ; $000179a2-$00010f90
[00010faa] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fac] fff4                      dc.w $fff4   ; $00010f84-$00010f90
[00010fae] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fb0] 32c7                      dc.w $32c7   ; $00014257-$00010f90
[00010fb2] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[00010fb4] 6a06                      dc.w $6a06   ; $00017996-$00010f90
[00010fb6] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fb8] ffe8                      dc.w $ffe8   ; $00010f78-$00010f90
[00010fba] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fbc] d2c5                      dc.w $d2c5   ; $0000e255-$00010f90
[00010fbe] d642                      dc.w $d642   ; $0000e5d2-$00010f90
[00010fc0] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fc2] ffde                      dc.w $ffde   ; $00010f6e-$00010f90
[00010fc4] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fc6] 32c4                      dc.w $32c4   ; $00014254-$00010f90
[00010fc8] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[00010fca] 6a06                      dc.w $6a06   ; $00017996-$00010f90
[00010fcc] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fce] fff8                      dc.w $fff8   ; $00010f88-$00010f90
[00010fd0] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fd2] d2c5                      dc.w $d2c5   ; $0000e255-$00010f90
[00010fd4] d642                      dc.w $d642   ; $0000e5d2-$00010f90
[00010fd6] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fd8] ffee                      dc.w $ffee   ; $00010f7e-$00010f90
[00010fda] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fdc] 4646                      dc.w $4646   ; $000155d6-$00010f90
[00010fde] e35e                      dc.w $e35e   ; $0000f2ee-$00010f90
[00010fe0] 640c                      dc.w $640c   ; $0001739c-$00010f90
[00010fe2] 32c4                      dc.w $32c4   ; $00014254-$00010f90
[00010fe4] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[00010fe6] 6a12                      dc.w $6a12   ; $000179a2-$00010f90
[00010fe8] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010fea] fff4                      dc.w $fff4   ; $00010f84-$00010f90
[00010fec] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010fee] 5489                      dc.w $5489   ; $00016419-$00010f90
[00010ff0] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[00010ff2] 6a06                      dc.w $6a06   ; $00017996-$00010f90
[00010ff4] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00010ff6] ffe8                      dc.w $ffe8   ; $00010f78-$00010f90
[00010ff8] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00010ffa] d2c5                      dc.w $d2c5   ; $0000e255-$00010f90
[00010ffc] d642                      dc.w $d642   ; $0000e5d2-$00010f90
[00010ffe] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00011000] ffde                      dc.w $ffde   ; $00010f6e-$00010f90
[00011002] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00011004] 78ff                      dc.w $78ff   ; $0001888f-$00010f90
[00011006] e35e                      dc.w $e35e   ; $0000f2ee-$00010f90
[00011008] 640c                      dc.w $640c   ; $0001739c-$00010f90
[0001100a] b959                      dc.w $b959   ; $0000c8e9-$00010f90
[0001100c] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[0001100e] 6a12                      dc.w $6a12   ; $000179a2-$00010f90
[00011010] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00011012] fff4                      dc.w $fff4   ; $00010f84-$00010f90
[00011014] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00011016] 5489                      dc.w $5489   ; $00016419-$00010f90
[00011018] d641                      dc.w $d641   ; $0000e5d1-$00010f90
[0001101a] 6a06                      dc.w $6a06   ; $00017996-$00010f90
[0001101c] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[0001101e] ffe8                      dc.w $ffe8   ; $00010f78-$00010f90
[00011020] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[00011022] d2c5                      dc.w $d2c5   ; $0000e255-$00010f90
[00011024] d642                      dc.w $d642   ; $0000e5d2-$00010f90
[00011026] 51c8                      dc.w $51c8   ; $00016158-$00010f90
[00011028] ffde                      dc.w $ffde   ; $00010f6e-$00010f90
[0001102a] 4e75                      dc.w $4e75   ; $00015e05-$00010f90
[0001102c] bc7c ffff                 cmp.w     #$FFFF,d6
[00011030] 672c                      beq.s     $0001105E
[00011032] 7eff                      moveq.l   #-1,d7
[00011034] e35e                      rol.w     #1,d6
[00011036] 640e                      bcc.s     $00011046
[00011038] 3284                      move.w    d4,(a1)
[0001103a] d2c5                      adda.w    d5,a1
[0001103c] d642                      add.w     d2,d3
[0001103e] 6a14                      bpl.s     $00011054
[00011040] 51c8 fff2                 dbf       d0,$00011034
[00011044] 4e75                      rts
[00011046] 3287                      move.w    d7,(a1)
[00011048] d2c5                      adda.w    d5,a1
[0001104a] d642                      add.w     d2,d3
[0001104c] 6a06                      bpl.s     $00011054
[0001104e] 51c8 ffe4                 dbf       d0,$00011034
[00011052] 4e75                      rts
[00011054] d641                      add.w     d1,d3
[00011056] 5489                      addq.l    #2,a1
[00011058] 51c8 ffda                 dbf       d0,$00011034
[0001105c] 4e75                      rts
[0001105e] 3284                      move.w    d4,(a1)
[00011060] d2c5                      adda.w    d5,a1
[00011062] d642                      add.w     d2,d3
[00011064] 6a06                      bpl.s     $0001106C
[00011066] 51c8 fff6                 dbf       d0,$0001105E
[0001106a] 4e75                      rts
[0001106c] d641                      add.w     d1,d3
[0001106e] 5489                      addq.l    #2,a1
[00011070] 51c8 ffec                 dbf       d0,$0001105E
[00011074] 4e75                      rts
[00011076] 4646                      not.w     d6
[00011078] e35e                      rol.w     #1,d6
[0001107a] 6402                      bcc.s     $0001107E
[0001107c] 3284                      move.w    d4,(a1)
[0001107e] d2c5                      adda.w    d5,a1
[00011080] d642                      add.w     d2,d3
[00011082] 6a06                      bpl.s     $0001108A
[00011084] 51c8 fff2                 dbf       d0,$00011078
[00011088] 4e75                      rts
[0001108a] d641                      add.w     d1,d3
[0001108c] 5489                      addq.l    #2,a1
[0001108e] 51c8 ffe8                 dbf       d0,$00011078
[00011092] 4e75                      rts
[00011094] 78ff                      moveq.l   #-1,d4
[00011096] e35e                      rol.w     #1,d6
[00011098] 6402                      bcc.s     $0001109C
[0001109a] b951                      eor.w     d4,(a1)
[0001109c] d2c5                      adda.w    d5,a1
[0001109e] d642                      add.w     d2,d3
[000110a0] 6a06                      bpl.s     $000110A8
[000110a2] 51c8 fff2                 dbf       d0,$00011096
[000110a6] 4e75                      rts
[000110a8] d641                      add.w     d1,d3
[000110aa] 5489                      addq.l    #2,a1
[000110ac] 51c8 ffe8                 dbf       d0,$00011096
[000110b0] 4e75                      rts
[000110b2] 41ee 0458                 lea.l     1112(a6),a0
[000110b6] 3a2e 00be                 move.w    190(a6),d5
[000110ba] da45                      add.w     d5,d5
[000110bc] 3a30 5000                 move.w    0(a0,d5.w),d5
[000110c0] 2278 044e                 movea.l   ($0000044E).w,a1
[000110c4] 3838 206e                 move.w    ($0000206E).w,d4
[000110c8] 4a6e 01b2                 tst.w     434(a6)
[000110cc] 6708                      beq.s     $000110D6
[000110ce] 226e 01ae                 movea.l   430(a6),a1
[000110d2] 382e 01b2                 move.w    434(a6),d4
[000110d6] 3e2e 003c                 move.w    60(a6),d7
[000110da] 286e 00c6                 movea.l   198(a6),a4
[000110de] 206e 0020                 movea.l   32(a6),a0
[000110e2] 9641                      sub.w     d1,d3
[000110e4] 3c04                      move.w    d4,d6
[000110e6] 3f06                      move.w    d6,-(a7)
[000110e8] c9c1                      muls.w    d1,d4
[000110ea] d3c4                      adda.l    d4,a1
[000110ec] d2c0                      adda.w    d0,a1
[000110ee] d2c0                      adda.w    d0,a1
[000110f0] 4a47                      tst.w     d7
[000110f2] 6600 02e6                 bne       $000113DA
[000110f6] 3e05                      move.w    d5,d7
[000110f8] 4847                      swap      d7
[000110fa] 3e05                      move.w    d5,d7
[000110fc] 7af0                      moveq.l   #-16,d5
[000110fe] ca42                      and.w     d2,d5
[00011100] 9a40                      sub.w     d0,d5
[00011102] da45                      add.w     d5,d5
[00011104] 48c6                      ext.l     d6
[00011106] e98e                      lsl.l     #4,d6
[00011108] 48c5                      ext.l     d5
[0001110a] 9c85                      sub.l     d5,d6
[0001110c] 2646                      movea.l   d6,a3
[0001110e] 2a48                      movea.l   a0,a5
[00011110] 7c0f                      moveq.l   #15,d6
[00011112] 4a6e 00ca                 tst.w     202(a6)
[00011116] 6740                      beq.s     $00011158
[00011118] c246                      and.w     d6,d1
[0001111a] 6724                      beq.s     $00011140
[0001111c] 2f0c                      move.l    a4,-(a7)
[0001111e] 3a01                      move.w    d1,d5
[00011120] bd45                      eor.w     d6,d5
[00011122] 3c01                      move.w    d1,d6
[00011124] 5346                      subq.w    #1,d6
[00011126] eb49                      lsl.w     #5,d1
[00011128] d8c1                      adda.w    d1,a4
[0001112a] 2adc                      move.l    (a4)+,(a5)+
[0001112c] 2adc                      move.l    (a4)+,(a5)+
[0001112e] 2adc                      move.l    (a4)+,(a5)+
[00011130] 2adc                      move.l    (a4)+,(a5)+
[00011132] 2adc                      move.l    (a4)+,(a5)+
[00011134] 2adc                      move.l    (a4)+,(a5)+
[00011136] 2adc                      move.l    (a4)+,(a5)+
[00011138] 2adc                      move.l    (a4)+,(a5)+
[0001113a] 51cd ffee                 dbf       d5,$0001112A
[0001113e] 285f                      movea.l   (a7)+,a4
[00011140] 2adc                      move.l    (a4)+,(a5)+
[00011142] 2adc                      move.l    (a4)+,(a5)+
[00011144] 2adc                      move.l    (a4)+,(a5)+
[00011146] 2adc                      move.l    (a4)+,(a5)+
[00011148] 2adc                      move.l    (a4)+,(a5)+
[0001114a] 2adc                      move.l    (a4)+,(a5)+
[0001114c] 2adc                      move.l    (a4)+,(a5)+
[0001114e] 2adc                      move.l    (a4)+,(a5)+
[00011150] 51ce ffee                 dbf       d6,$00011140
[00011154] 6000 00aa                 bra       $00011200
[00011158] 4dfa 116c                 lea.l     $000122C6(pc),a6
[0001115c] c246                      and.w     d6,d1
[0001115e] 6758                      beq.s     $000111B8
[00011160] 2f0c                      move.l    a4,-(a7)
[00011162] 3a01                      move.w    d1,d5
[00011164] bd45                      eor.w     d6,d5
[00011166] 3c01                      move.w    d1,d6
[00011168] 5346                      subq.w    #1,d6
[0001116a] d241                      add.w     d1,d1
[0001116c] d8c1                      adda.w    d1,a4
[0001116e] 7200                      moveq.l   #0,d1
[00011170] 121c                      move.b    (a4)+,d1
[00011172] e949                      lsl.w     #4,d1
[00011174] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011178] 221a                      move.l    (a2)+,d1
[0001117a] 8287                      or.l      d7,d1
[0001117c] 2ac1                      move.l    d1,(a5)+
[0001117e] 221a                      move.l    (a2)+,d1
[00011180] 8287                      or.l      d7,d1
[00011182] 2ac1                      move.l    d1,(a5)+
[00011184] 221a                      move.l    (a2)+,d1
[00011186] 8287                      or.l      d7,d1
[00011188] 2ac1                      move.l    d1,(a5)+
[0001118a] 221a                      move.l    (a2)+,d1
[0001118c] 8287                      or.l      d7,d1
[0001118e] 2ac1                      move.l    d1,(a5)+
[00011190] 7200                      moveq.l   #0,d1
[00011192] 121c                      move.b    (a4)+,d1
[00011194] e949                      lsl.w     #4,d1
[00011196] 45f6 1000                 lea.l     0(a6,d1.w),a2
[0001119a] 221a                      move.l    (a2)+,d1
[0001119c] 8287                      or.l      d7,d1
[0001119e] 2ac1                      move.l    d1,(a5)+
[000111a0] 221a                      move.l    (a2)+,d1
[000111a2] 8287                      or.l      d7,d1
[000111a4] 2ac1                      move.l    d1,(a5)+
[000111a6] 221a                      move.l    (a2)+,d1
[000111a8] 8287                      or.l      d7,d1
[000111aa] 2ac1                      move.l    d1,(a5)+
[000111ac] 221a                      move.l    (a2)+,d1
[000111ae] 8287                      or.l      d7,d1
[000111b0] 2ac1                      move.l    d1,(a5)+
[000111b2] 51cd ffba                 dbf       d5,$0001116E
[000111b6] 285f                      movea.l   (a7)+,a4
[000111b8] 7200                      moveq.l   #0,d1
[000111ba] 121c                      move.b    (a4)+,d1
[000111bc] e949                      lsl.w     #4,d1
[000111be] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000111c2] 221a                      move.l    (a2)+,d1
[000111c4] 8287                      or.l      d7,d1
[000111c6] 2ac1                      move.l    d1,(a5)+
[000111c8] 221a                      move.l    (a2)+,d1
[000111ca] 8287                      or.l      d7,d1
[000111cc] 2ac1                      move.l    d1,(a5)+
[000111ce] 221a                      move.l    (a2)+,d1
[000111d0] 8287                      or.l      d7,d1
[000111d2] 2ac1                      move.l    d1,(a5)+
[000111d4] 221a                      move.l    (a2)+,d1
[000111d6] 8287                      or.l      d7,d1
[000111d8] 2ac1                      move.l    d1,(a5)+
[000111da] 7200                      moveq.l   #0,d1
[000111dc] 121c                      move.b    (a4)+,d1
[000111de] e949                      lsl.w     #4,d1
[000111e0] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000111e4] 221a                      move.l    (a2)+,d1
[000111e6] 8287                      or.l      d7,d1
[000111e8] 2ac1                      move.l    d1,(a5)+
[000111ea] 221a                      move.l    (a2)+,d1
[000111ec] 8287                      or.l      d7,d1
[000111ee] 2ac1                      move.l    d1,(a5)+
[000111f0] 221a                      move.l    (a2)+,d1
[000111f2] 8287                      or.l      d7,d1
[000111f4] 2ac1                      move.l    d1,(a5)+
[000111f6] 221a                      move.l    (a2)+,d1
[000111f8] 8287                      or.l      d7,d1
[000111fa] 2ac1                      move.l    d1,(a5)+
[000111fc] 51ce ffba                 dbf       d6,$000111B8
[00011200] 3c02                      move.w    d2,d6
[00011202] e84a                      lsr.w     #4,d2
[00011204] 3800                      move.w    d0,d4
[00011206] e84c                      lsr.w     #4,d4
[00011208] 9444                      sub.w     d4,d2
[0001120a] 5342                      subq.w    #1,d2
[0001120c] 6b00 017a                 bmi       $00011388
[00011210] cc7c 000f                 and.w     #$000F,d6
[00011214] dc46                      add.w     d6,d6
[00011216] 3846                      movea.w   d6,a4
[00011218] 544c                      addq.w    #2,a4
[0001121a] c07c 000f                 and.w     #$000F,d0
[0001121e] d040                      add.w     d0,d0
[00011220] d040                      add.w     d0,d0
[00011222] dc46                      add.w     d6,d6
[00011224] 247b 000a                 movea.l   $00011230(pc,d0.w),a2
[00011228] 2c7b 6046                 movea.l   $00011270(pc,d6.w),a6
[0001122c] 6000 0082                 bra       $000112B0
[00011230] 0001 12fe                 ori.b     #$FE,d1
[00011234] 0001 12de                 ori.b     #$DE,d1
[00011238] 0001 1300                 ori.b     #$00,d1
[0001123c] 0001 12e2                 ori.b     #$E2,d1
[00011240] 0001 1302                 ori.b     #$02,d1
[00011244] 0001 12e6                 ori.b     #$E6,d1
[00011248] 0001 1304                 ori.b     #$04,d1
[0001124c] 0001 12ea                 ori.b     #$EA,d1
[00011250] 0001 1306                 ori.b     #$06,d1
[00011254] 0001 12ee                 ori.b     #$EE,d1
[00011258] 0001 1308                 ori.b     #$08,d1
[0001125c] 0001 12f2                 ori.b     #$F2,d1
[00011260] 0001 130a                 ori.b     #$0A,d1
[00011264] 0001 12f6                 ori.b     #$F6,d1
[00011268] 0001 130c                 ori.b     #$0C,d1
[0001126c] 0001 12fa                 ori.b     #$FA,d1
[00011270] 0001 134e                 ori.b     #$4E,d1
[00011274] 0001 1364                 ori.b     #$64,d1
[00011278] 0001 1346                 ori.b     #$46,d1
[0001127c] 0001 1362                 ori.b     #$62,d1
[00011280] 0001 133e                 ori.b     #$3E,d1
[00011284] 0001 1360                 ori.b     #$60,d1
[00011288] 0001 1336                 ori.b     #$36,d1
[0001128c] 0001 135e                 ori.b     #$5E,d1
[00011290] 0001 132e                 ori.b     #$2E,d1
[00011294] 0001 135c                 ori.b     #$5C,d1
[00011298] 0001 1326                 ori.b     #$26,d1
[0001129c] 0001 135a                 ori.b     #$5A,d1
[000112a0] 0001 131e                 ori.b     #$1E,d1
[000112a4] 0001 1358                 ori.b     #$58,d1
[000112a8] 0001 1316                 ori.b     #$16,d1
[000112ac] 0001 1356                 ori.b     #$56,d1
[000112b0] 700f                      moveq.l   #15,d0
[000112b2] b640                      cmp.w     d0,d3
[000112b4] 6c02                      bge.s     $000112B8
[000112b6] 3003                      move.w    d3,d0
[000112b8] 4843                      swap      d3
[000112ba] 3600                      move.w    d0,d3
[000112bc] 4843                      swap      d3
[000112be] 2f03                      move.l    d3,-(a7)
[000112c0] e84b                      lsr.w     #4,d3
[000112c2] 2f08                      move.l    a0,-(a7)
[000112c4] 3f0c                      move.w    a4,-(a7)
[000112c6] 2018                      move.l    (a0)+,d0
[000112c8] 2218                      move.l    (a0)+,d1
[000112ca] 2818                      move.l    (a0)+,d4
[000112cc] 2a18                      move.l    (a0)+,d5
[000112ce] 2c18                      move.l    (a0)+,d6
[000112d0] 2e18                      move.l    (a0)+,d7
[000112d2] 2858                      movea.l   (a0)+,a4
[000112d4] 2a58                      movea.l   (a0)+,a5
[000112d6] 305f                      movea.w   (a7)+,a0
[000112d8] 2f09                      move.l    a1,-(a7)
[000112da] 3f02                      move.w    d2,-(a7)
[000112dc] 4ed2                      jmp       (a2)
[000112de] 32c0                      move.w    d0,(a1)+
[000112e0] 601e                      bra.s     $00011300
[000112e2] 32c1                      move.w    d1,(a1)+
[000112e4] 601c                      bra.s     $00011302
[000112e6] 32c4                      move.w    d4,(a1)+
[000112e8] 601a                      bra.s     $00011304
[000112ea] 32c5                      move.w    d5,(a1)+
[000112ec] 6018                      bra.s     $00011306
[000112ee] 32c6                      move.w    d6,(a1)+
[000112f0] 6016                      bra.s     $00011308
[000112f2] 32c7                      move.w    d7,(a1)+
[000112f4] 6014                      bra.s     $0001130A
[000112f6] 32cc                      move.w    a4,(a1)+
[000112f8] 6012                      bra.s     $0001130C
[000112fa] 32cd                      move.w    a5,(a1)+
[000112fc] 6010                      bra.s     $0001130E
[000112fe] 22c0                      move.l    d0,(a1)+
[00011300] 22c1                      move.l    d1,(a1)+
[00011302] 22c4                      move.l    d4,(a1)+
[00011304] 22c5                      move.l    d5,(a1)+
[00011306] 22c6                      move.l    d6,(a1)+
[00011308] 22c7                      move.l    d7,(a1)+
[0001130a] 22cc                      move.l    a4,(a1)+
[0001130c] 22cd                      move.l    a5,(a1)+
[0001130e] 51ca ffee                 dbf       d2,$000112FE
[00011312] d2c8                      adda.w    a0,a1
[00011314] 4ed6                      jmp       (a6)
[00011316] 240d                      move.l    a5,d2
[00011318] 4842                      swap      d2
[0001131a] 3302                      move.w    d2,-(a1)
[0001131c] 603a                      bra.s     $00011358
[0001131e] 240c                      move.l    a4,d2
[00011320] 4842                      swap      d2
[00011322] 3302                      move.w    d2,-(a1)
[00011324] 6034                      bra.s     $0001135A
[00011326] 2407                      move.l    d7,d2
[00011328] 4842                      swap      d2
[0001132a] 3302                      move.w    d2,-(a1)
[0001132c] 602e                      bra.s     $0001135C
[0001132e] 2406                      move.l    d6,d2
[00011330] 4842                      swap      d2
[00011332] 3302                      move.w    d2,-(a1)
[00011334] 6028                      bra.s     $0001135E
[00011336] 2405                      move.l    d5,d2
[00011338] 4842                      swap      d2
[0001133a] 3302                      move.w    d2,-(a1)
[0001133c] 6022                      bra.s     $00011360
[0001133e] 2404                      move.l    d4,d2
[00011340] 4842                      swap      d2
[00011342] 3302                      move.w    d2,-(a1)
[00011344] 601c                      bra.s     $00011362
[00011346] 2401                      move.l    d1,d2
[00011348] 4842                      swap      d2
[0001134a] 3302                      move.w    d2,-(a1)
[0001134c] 6016                      bra.s     $00011364
[0001134e] 2400                      move.l    d0,d2
[00011350] 4842                      swap      d2
[00011352] 3302                      move.w    d2,-(a1)
[00011354] 6010                      bra.s     $00011366
[00011356] 230d                      move.l    a5,-(a1)
[00011358] 230c                      move.l    a4,-(a1)
[0001135a] 2307                      move.l    d7,-(a1)
[0001135c] 2306                      move.l    d6,-(a1)
[0001135e] 2305                      move.l    d5,-(a1)
[00011360] 2304                      move.l    d4,-(a1)
[00011362] 2301                      move.l    d1,-(a1)
[00011364] 2300                      move.l    d0,-(a1)
[00011366] 341f                      move.w    (a7)+,d2
[00011368] d3cb                      adda.l    a3,a1
[0001136a] 51cb ff6e                 dbf       d3,$000112DA
[0001136e] 225f                      movea.l   (a7)+,a1
[00011370] 3848                      movea.w   a0,a4
[00011372] 205f                      movea.l   (a7)+,a0
[00011374] 41e8 0020                 lea.l     32(a0),a0
[00011378] 261f                      move.l    (a7)+,d3
[0001137a] 5343                      subq.w    #1,d3
[0001137c] 4843                      swap      d3
[0001137e] d2d7                      adda.w    (a7),a1
[00011380] 51cb ff3a                 dbf       d3,$000112BC
[00011384] 548f                      addq.l    #2,a7
[00011386] 4e75                      rts
[00011388] 365f                      movea.w   (a7)+,a3
[0001138a] 720f                      moveq.l   #15,d1
[0001138c] 9c40                      sub.w     d0,d6
[0001138e] 96c6                      suba.w    d6,a3
[00011390] 96c6                      suba.w    d6,a3
[00011392] b346                      eor.w     d1,d6
[00011394] dc46                      add.w     d6,d6
[00011396] 45fb 601a                 lea.l     $000113B2(pc,d6.w),a2
[0001139a] c041                      and.w     d1,d0
[0001139c] d040                      add.w     d0,d0
[0001139e] d0c0                      adda.w    d0,a0
[000113a0] 2848                      movea.l   a0,a4
[000113a2] 41e8 0020                 lea.l     32(a0),a0
[000113a6] 51c9 0008                 dbf       d1,$000113B0
[000113aa] 720f                      moveq.l   #15,d1
[000113ac] 41e8 fe00                 lea.l     -512(a0),a0
[000113b0] 4ed2                      jmp       (a2)
[000113b2] 32dc                      move.w    (a4)+,(a1)+
[000113b4] 32dc                      move.w    (a4)+,(a1)+
[000113b6] 32dc                      move.w    (a4)+,(a1)+
[000113b8] 32dc                      move.w    (a4)+,(a1)+
[000113ba] 32dc                      move.w    (a4)+,(a1)+
[000113bc] 32dc                      move.w    (a4)+,(a1)+
[000113be] 32dc                      move.w    (a4)+,(a1)+
[000113c0] 32dc                      move.w    (a4)+,(a1)+
[000113c2] 32dc                      move.w    (a4)+,(a1)+
[000113c4] 32dc                      move.w    (a4)+,(a1)+
[000113c6] 32dc                      move.w    (a4)+,(a1)+
[000113c8] 32dc                      move.w    (a4)+,(a1)+
[000113ca] 32dc                      move.w    (a4)+,(a1)+
[000113cc] 32dc                      move.w    (a4)+,(a1)+
[000113ce] 32dc                      move.w    (a4)+,(a1)+
[000113d0] 329c                      move.w    (a4)+,(a1)
[000113d2] d2cb                      adda.w    a3,a1
[000113d4] 51cb ffca                 dbf       d3,$000113A0
[000113d8] 4e75                      rts
[000113da] 5547                      subq.w    #2,d7
[000113dc] 6d00 034a                 blt       $00011728
[000113e0] 6600 030a                 bne       $000116EC
[000113e4] 3e2e 00c0                 move.w    192(a6),d7
[000113e8] 6700 022c                 beq       $00011616
[000113ec] 5347                      subq.w    #1,d7
[000113ee] 6700 029e                 beq       $0001168E
[000113f2] 5347                      subq.w    #1,d7
[000113f4] 660a                      bne.s     $00011400
[000113f6] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[000113fc] 6700 0290                 beq       $0001168E
[00011400] 7af0                      moveq.l   #-16,d5
[00011402] ca42                      and.w     d2,d5
[00011404] 9a40                      sub.w     d0,d5
[00011406] da45                      add.w     d5,d5
[00011408] 48c6                      ext.l     d6
[0001140a] e94e                      lsl.w     #4,d6
[0001140c] 48c5                      ext.l     d5
[0001140e] 9c85                      sub.l     d5,d6
[00011410] 2646                      movea.l   d6,a3
[00011412] 4dfa 0eb2                 lea.l     $000122C6(pc),a6
[00011416] 2a48                      movea.l   a0,a5
[00011418] 7c0f                      moveq.l   #15,d6
[0001141a] c246                      and.w     d6,d1
[0001141c] 673c                      beq.s     $0001145A
[0001141e] 2f0c                      move.l    a4,-(a7)
[00011420] 3a01                      move.w    d1,d5
[00011422] bd45                      eor.w     d6,d5
[00011424] 3c01                      move.w    d1,d6
[00011426] 5346                      subq.w    #1,d6
[00011428] d241                      add.w     d1,d1
[0001142a] d8c1                      adda.w    d1,a4
[0001142c] 7200                      moveq.l   #0,d1
[0001142e] 121c                      move.b    (a4)+,d1
[00011430] 4601                      not.b     d1
[00011432] e949                      lsl.w     #4,d1
[00011434] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011438] 2ada                      move.l    (a2)+,(a5)+
[0001143a] 2ada                      move.l    (a2)+,(a5)+
[0001143c] 2ada                      move.l    (a2)+,(a5)+
[0001143e] 2ada                      move.l    (a2)+,(a5)+
[00011440] 7200                      moveq.l   #0,d1
[00011442] 121c                      move.b    (a4)+,d1
[00011444] 4601                      not.b     d1
[00011446] e949                      lsl.w     #4,d1
[00011448] 45f6 1000                 lea.l     0(a6,d1.w),a2
[0001144c] 2ada                      move.l    (a2)+,(a5)+
[0001144e] 2ada                      move.l    (a2)+,(a5)+
[00011450] 2ada                      move.l    (a2)+,(a5)+
[00011452] 2ada                      move.l    (a2)+,(a5)+
[00011454] 51cd ffd6                 dbf       d5,$0001142C
[00011458] 285f                      movea.l   (a7)+,a4
[0001145a] 7200                      moveq.l   #0,d1
[0001145c] 121c                      move.b    (a4)+,d1
[0001145e] 4601                      not.b     d1
[00011460] e949                      lsl.w     #4,d1
[00011462] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011466] 2ada                      move.l    (a2)+,(a5)+
[00011468] 2ada                      move.l    (a2)+,(a5)+
[0001146a] 2ada                      move.l    (a2)+,(a5)+
[0001146c] 2ada                      move.l    (a2)+,(a5)+
[0001146e] 7200                      moveq.l   #0,d1
[00011470] 121c                      move.b    (a4)+,d1
[00011472] 4601                      not.b     d1
[00011474] e949                      lsl.w     #4,d1
[00011476] 45f6 1000                 lea.l     0(a6,d1.w),a2
[0001147a] 2ada                      move.l    (a2)+,(a5)+
[0001147c] 2ada                      move.l    (a2)+,(a5)+
[0001147e] 2ada                      move.l    (a2)+,(a5)+
[00011480] 2ada                      move.l    (a2)+,(a5)+
[00011482] 51ce ffd6                 dbf       d6,$0001145A
[00011486] 3c02                      move.w    d2,d6
[00011488] e84a                      lsr.w     #4,d2
[0001148a] 3800                      move.w    d0,d4
[0001148c] e84c                      lsr.w     #4,d4
[0001148e] 9444                      sub.w     d4,d2
[00011490] 5342                      subq.w    #1,d2
[00011492] 6b00 0186                 bmi       $0001161A
[00011496] cc7c 000f                 and.w     #$000F,d6
[0001149a] dc46                      add.w     d6,d6
[0001149c] 3846                      movea.w   d6,a4
[0001149e] 544c                      addq.w    #2,a4
[000114a0] c07c 000f                 and.w     #$000F,d0
[000114a4] d040                      add.w     d0,d0
[000114a6] d040                      add.w     d0,d0
[000114a8] dc46                      add.w     d6,d6
[000114aa] 247b 000a                 movea.l   $000114B6(pc,d0.w),a2
[000114ae] 2c7b 6046                 movea.l   $000114F6(pc,d6.w),a6
[000114b2] 6000 0082                 bra       $00011536
[000114b6] 0001 158a                 ori.b     #$8A,d1
[000114ba] 0001 1568                 ori.b     #$68,d1
[000114be] 0001 158c                 ori.b     #$8C,d1
[000114c2] 0001 156c                 ori.b     #$6C,d1
[000114c6] 0001 158e                 ori.b     #$8E,d1
[000114ca] 0001 1570                 ori.b     #$70,d1
[000114ce] 0001 1590                 ori.b     #$90,d1
[000114d2] 0001 1574                 ori.b     #$74,d1
[000114d6] 0001 1592                 ori.b     #$92,d1
[000114da] 0001 1578                 ori.b     #$78,d1
[000114de] 0001 1594                 ori.b     #$94,d1
[000114e2] 0001 157c                 ori.b     #$7C,d1
[000114e6] 0001 1596                 ori.b     #$96,d1
[000114ea] 0001 1580                 ori.b     #$80,d1
[000114ee] 0001 1598                 ori.b     #$98,d1
[000114f2] 0001 1584                 ori.b     #$84,d1
[000114f6] 0001 15dc                 ori.b     #$DC,d1
[000114fa] 0001 15f4                 ori.b     #$F4,d1
[000114fe] 0001 15d4                 ori.b     #$D4,d1
[00011502] 0001 15f2                 ori.b     #$F2,d1
[00011506] 0001 15cc                 ori.b     #$CC,d1
[0001150a] 0001 15f0                 ori.b     #$F0,d1
[0001150e] 0001 15c4                 ori.b     #$C4,d1
[00011512] 0001 15ee                 ori.b     #$EE,d1
[00011516] 0001 15bc                 ori.b     #$BC,d1
[0001151a] 0001 15ec                 ori.b     #$EC,d1
[0001151e] 0001 15b4                 ori.b     #$B4,d1
[00011522] 0001 15ea                 ori.b     #$EA,d1
[00011526] 0001 15ac                 ori.b     #$AC,d1
[0001152a] 0001 15e8                 ori.b     #$E8,d1
[0001152e] 0001 15a4                 ori.b     #$A4,d1
[00011532] 0001 15e4                 ori.b     #$E4,d1
[00011536] 700f                      moveq.l   #15,d0
[00011538] b640                      cmp.w     d0,d3
[0001153a] 6c02                      bge.s     $0001153E
[0001153c] 3003                      move.w    d3,d0
[0001153e] 4843                      swap      d3
[00011540] 3600                      move.w    d0,d3
[00011542] 4843                      swap      d3
[00011544] 2f03                      move.l    d3,-(a7)
[00011546] e84b                      lsr.w     #4,d3
[00011548] 2f08                      move.l    a0,-(a7)
[0001154a] 3f0c                      move.w    a4,-(a7)
[0001154c] 2018                      move.l    (a0)+,d0
[0001154e] 2218                      move.l    (a0)+,d1
[00011550] 2818                      move.l    (a0)+,d4
[00011552] 2a18                      move.l    (a0)+,d5
[00011554] 2c18                      move.l    (a0)+,d6
[00011556] 2e18                      move.l    (a0)+,d7
[00011558] 2858                      movea.l   (a0)+,a4
[0001155a] 2a58                      movea.l   (a0)+,a5
[0001155c] 305f                      movea.w   (a7)+,a0
[0001155e] 2f09                      move.l    a1,-(a7)
[00011560] 3f02                      move.w    d2,-(a7)
[00011562] c78c                      exg       d3,a4
[00011564] c58d                      exg       d2,a5
[00011566] 4ed2                      jmp       (a2)
[00011568] b159                      eor.w     d0,(a1)+
[0001156a] 6020                      bra.s     $0001158C
[0001156c] b359                      eor.w     d1,(a1)+
[0001156e] 601e                      bra.s     $0001158E
[00011570] b959                      eor.w     d4,(a1)+
[00011572] 601c                      bra.s     $00011590
[00011574] bb59                      eor.w     d5,(a1)+
[00011576] 601a                      bra.s     $00011592
[00011578] bd59                      eor.w     d6,(a1)+
[0001157a] 6018                      bra.s     $00011594
[0001157c] bf59                      eor.w     d7,(a1)+
[0001157e] 6016                      bra.s     $00011596
[00011580] b759                      eor.w     d3,(a1)+
[00011582] 6014                      bra.s     $00011598
[00011584] 32c2                      move.w    d2,(a1)+
[00011586] 6012                      bra.s     $0001159A
[00011588] c58d                      exg       d2,a5
[0001158a] b199                      eor.l     d0,(a1)+
[0001158c] b399                      eor.l     d1,(a1)+
[0001158e] b999                      eor.l     d4,(a1)+
[00011590] bb99                      eor.l     d5,(a1)+
[00011592] bd99                      eor.l     d6,(a1)+
[00011594] bf99                      eor.l     d7,(a1)+
[00011596] b799                      eor.l     d3,(a1)+
[00011598] b599                      eor.l     d2,(a1)+
[0001159a] c58d                      exg       d2,a5
[0001159c] 51ca ffea                 dbf       d2,$00011588
[000115a0] d2c8                      adda.w    a0,a1
[000115a2] 4ed6                      jmp       (a6)
[000115a4] 240d                      move.l    a5,d2
[000115a6] 4842                      swap      d2
[000115a8] b561                      eor.w     d2,-(a1)
[000115aa] 603c                      bra.s     $000115E8
[000115ac] 2403                      move.l    d3,d2
[000115ae] 4842                      swap      d2
[000115b0] b561                      eor.w     d2,-(a1)
[000115b2] 6036                      bra.s     $000115EA
[000115b4] 2407                      move.l    d7,d2
[000115b6] 4842                      swap      d2
[000115b8] b561                      eor.w     d2,-(a1)
[000115ba] 6030                      bra.s     $000115EC
[000115bc] 2406                      move.l    d6,d2
[000115be] 4842                      swap      d2
[000115c0] b561                      eor.w     d2,-(a1)
[000115c2] 602a                      bra.s     $000115EE
[000115c4] 2405                      move.l    d5,d2
[000115c6] 4842                      swap      d2
[000115c8] b561                      eor.w     d2,-(a1)
[000115ca] 6024                      bra.s     $000115F0
[000115cc] 2404                      move.l    d4,d2
[000115ce] 4842                      swap      d2
[000115d0] b561                      eor.w     d2,-(a1)
[000115d2] 601e                      bra.s     $000115F2
[000115d4] 2401                      move.l    d1,d2
[000115d6] 4842                      swap      d2
[000115d8] b561                      eor.w     d2,-(a1)
[000115da] 6018                      bra.s     $000115F4
[000115dc] 2400                      move.l    d0,d2
[000115de] 4842                      swap      d2
[000115e0] b561                      eor.w     d2,-(a1)
[000115e2] 6012                      bra.s     $000115F6
[000115e4] 240d                      move.l    a5,d2
[000115e6] b5a1                      eor.l     d2,-(a1)
[000115e8] b7a1                      eor.l     d3,-(a1)
[000115ea] bfa1                      eor.l     d7,-(a1)
[000115ec] bda1                      eor.l     d6,-(a1)
[000115ee] bba1                      eor.l     d5,-(a1)
[000115f0] b9a1                      eor.l     d4,-(a1)
[000115f2] b3a1                      eor.l     d1,-(a1)
[000115f4] b1a1                      eor.l     d0,-(a1)
[000115f6] c78c                      exg       d3,a4
[000115f8] 341f                      move.w    (a7)+,d2
[000115fa] d3cb                      adda.l    a3,a1
[000115fc] 51cb ff62                 dbf       d3,$00011560
[00011600] 225f                      movea.l   (a7)+,a1
[00011602] 3848                      movea.w   a0,a4
[00011604] 205f                      movea.l   (a7)+,a0
[00011606] 41e8 0020                 lea.l     32(a0),a0
[0001160a] 261f                      move.l    (a7)+,d3
[0001160c] 5343                      subq.w    #1,d3
[0001160e] 4843                      swap      d3
[00011610] d2d7                      adda.w    (a7),a1
[00011612] 51cb ff2e                 dbf       d3,$00011542
[00011616] 548f                      addq.l    #2,a7
[00011618] 4e75                      rts
[0001161a] 365f                      movea.w   (a7)+,a3
[0001161c] 720f                      moveq.l   #15,d1
[0001161e] 9c40                      sub.w     d0,d6
[00011620] 96c6                      suba.w    d6,a3
[00011622] 96c6                      suba.w    d6,a3
[00011624] b346                      eor.w     d1,d6
[00011626] dc46                      add.w     d6,d6
[00011628] dc46                      add.w     d6,d6
[0001162a] 45fb 601a                 lea.l     $00011646(pc,d6.w),a2
[0001162e] c041                      and.w     d1,d0
[00011630] d040                      add.w     d0,d0
[00011632] d0c0                      adda.w    d0,a0
[00011634] 2848                      movea.l   a0,a4
[00011636] 41e8 0020                 lea.l     32(a0),a0
[0001163a] 51c9 0008                 dbf       d1,$00011644
[0001163e] 720f                      moveq.l   #15,d1
[00011640] 41e8 fe00                 lea.l     -512(a0),a0
[00011644] 4ed2                      jmp       (a2)
[00011646] 301c                      move.w    (a4)+,d0
[00011648] b159                      eor.w     d0,(a1)+
[0001164a] 301c                      move.w    (a4)+,d0
[0001164c] b159                      eor.w     d0,(a1)+
[0001164e] 301c                      move.w    (a4)+,d0
[00011650] b159                      eor.w     d0,(a1)+
[00011652] 301c                      move.w    (a4)+,d0
[00011654] b159                      eor.w     d0,(a1)+
[00011656] 301c                      move.w    (a4)+,d0
[00011658] b159                      eor.w     d0,(a1)+
[0001165a] 301c                      move.w    (a4)+,d0
[0001165c] b159                      eor.w     d0,(a1)+
[0001165e] 301c                      move.w    (a4)+,d0
[00011660] b159                      eor.w     d0,(a1)+
[00011662] 301c                      move.w    (a4)+,d0
[00011664] b159                      eor.w     d0,(a1)+
[00011666] 301c                      move.w    (a4)+,d0
[00011668] b159                      eor.w     d0,(a1)+
[0001166a] 301c                      move.w    (a4)+,d0
[0001166c] b159                      eor.w     d0,(a1)+
[0001166e] 301c                      move.w    (a4)+,d0
[00011670] b159                      eor.w     d0,(a1)+
[00011672] 301c                      move.w    (a4)+,d0
[00011674] b159                      eor.w     d0,(a1)+
[00011676] 301c                      move.w    (a4)+,d0
[00011678] b159                      eor.w     d0,(a1)+
[0001167a] 301c                      move.w    (a4)+,d0
[0001167c] b159                      eor.w     d0,(a1)+
[0001167e] 301c                      move.w    (a4)+,d0
[00011680] b159                      eor.w     d0,(a1)+
[00011682] 301c                      move.w    (a4)+,d0
[00011684] b151                      eor.w     d0,(a1)
[00011686] d2cb                      adda.w    a3,a1
[00011688] 51cb ffaa                 dbf       d3,$00011634
[0001168c] 4e75                      rts
[0001168e] 9440                      sub.w     d0,d2
[00011690] 9c42                      sub.w     d2,d6
[00011692] 9c42                      sub.w     d2,d6
[00011694] 5546                      subq.w    #2,d6
[00011696] 0802 0000                 btst      #0,d2
[0001169a] 661c                      bne.s     $000116B8
[0001169c] 41fa 002c                 lea.l     $000116CA(pc),a0
[000116a0] 45fa 0040                 lea.l     $000116E2(pc),a2
[000116a4] 5342                      subq.w    #1,d2
[000116a6] 6b1e                      bmi.s     $000116C6
[000116a8] 700e                      moveq.l   #14,d0
[000116aa] c042                      and.w     d2,d0
[000116ac] e84a                      lsr.w     #4,d2
[000116ae] 0a40 000e                 eori.w    #$000E,d0
[000116b2] 45fb 001a                 lea.l     $000116CE(pc,d0.w),a2
[000116b6] 600e                      bra.s     $000116C6
[000116b8] 700e                      moveq.l   #14,d0
[000116ba] c042                      and.w     d2,d0
[000116bc] e84a                      lsr.w     #4,d2
[000116be] 0a40 000e                 eori.w    #$000E,d0
[000116c2] 41fb 000a                 lea.l     $000116CE(pc,d0.w),a0
[000116c6] 3002                      move.w    d2,d0
[000116c8] 4ed0                      jmp       (a0)
[000116ca] 4659                      not.w     (a1)+
[000116cc] 4ed2                      jmp       (a2)
[000116ce] 4699                      not.l     (a1)+
[000116d0] 4699                      not.l     (a1)+
[000116d2] 4699                      not.l     (a1)+
[000116d4] 4699                      not.l     (a1)+
[000116d6] 4699                      not.l     (a1)+
[000116d8] 4699                      not.l     (a1)+
[000116da] 4699                      not.l     (a1)+
[000116dc] 4699                      not.l     (a1)+
[000116de] 51c8 ffee                 dbf       d0,$000116CE
[000116e2] d2c6                      adda.w    d6,a1
[000116e4] 51cb ffe0                 dbf       d3,$000116C6
[000116e8] 548f                      addq.l    #2,a7
[000116ea] 4e75                      rts
[000116ec] 9440                      sub.w     d0,d2
[000116ee] 48c6                      ext.l     d6
[000116f0] e98e                      lsl.l     #4,d6
[000116f2] 2646                      movea.l   d6,a3
[000116f4] 2a48                      movea.l   a0,a5
[000116f6] 780f                      moveq.l   #15,d4
[000116f8] 7c0f                      moveq.l   #15,d6
[000116fa] c044                      and.w     d4,d0
[000116fc] c244                      and.w     d4,d1
[000116fe] 671a                      beq.s     $0001171A
[00011700] 3e01                      move.w    d1,d7
[00011702] bd47                      eor.w     d6,d7
[00011704] 3c01                      move.w    d1,d6
[00011706] 5346                      subq.w    #1,d6
[00011708] d241                      add.w     d1,d1
[0001170a] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001170e] 321a                      move.w    (a2)+,d1
[00011710] 4641                      not.w     d1
[00011712] e179                      rol.w     d0,d1
[00011714] 3ac1                      move.w    d1,(a5)+
[00011716] 51cf fff6                 dbf       d7,$0001170E
[0001171a] 321c                      move.w    (a4)+,d1
[0001171c] 4641                      not.w     d1
[0001171e] e179                      rol.w     d0,d1
[00011720] 3ac1                      move.w    d1,(a5)+
[00011722] 51ce fff6                 dbf       d6,$0001171A
[00011726] 6036                      bra.s     $0001175E
[00011728] 9440                      sub.w     d0,d2
[0001172a] 48c6                      ext.l     d6
[0001172c] e98e                      lsl.l     #4,d6
[0001172e] 2646                      movea.l   d6,a3
[00011730] 2a48                      movea.l   a0,a5
[00011732] 780f                      moveq.l   #15,d4
[00011734] 7c0f                      moveq.l   #15,d6
[00011736] c044                      and.w     d4,d0
[00011738] c244                      and.w     d4,d1
[0001173a] 6718                      beq.s     $00011754
[0001173c] 3e01                      move.w    d1,d7
[0001173e] bd47                      eor.w     d6,d7
[00011740] 3c01                      move.w    d1,d6
[00011742] 5346                      subq.w    #1,d6
[00011744] d241                      add.w     d1,d1
[00011746] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001174a] 321a                      move.w    (a2)+,d1
[0001174c] e179                      rol.w     d0,d1
[0001174e] 3ac1                      move.w    d1,(a5)+
[00011750] 51cf fff8                 dbf       d7,$0001174A
[00011754] 321c                      move.w    (a4)+,d1
[00011756] e179                      rol.w     d0,d1
[00011758] 3ac1                      move.w    d1,(a5)+
[0001175a] 51ce fff8                 dbf       d6,$00011754
[0001175e] 3e05                      move.w    d5,d7
[00011760] b644                      cmp.w     d4,d3
[00011762] 6c02                      bge.s     $00011766
[00011764] 3803                      move.w    d3,d4
[00011766] 4843                      swap      d3
[00011768] 3604                      move.w    d4,d3
[0001176a] 347c 0020                 movea.w   #$0020,a2
[0001176e] 7c0f                      moveq.l   #15,d6
[00011770] b446                      cmp.w     d6,d2
[00011772] 6c02                      bge.s     $00011776
[00011774] 3c02                      move.w    d2,d6
[00011776] 3846                      movea.w   d6,a4
[00011778] 9446                      sub.w     d6,d2
[0001177a] 5246                      addq.w    #1,d6
[0001177c] dc46                      add.w     d6,d6
[0001177e] 96c6                      suba.w    d6,a3
[00011780] 4843                      swap      d3
[00011782] 3203                      move.w    d3,d1
[00011784] e849                      lsr.w     #4,d1
[00011786] 2a49                      movea.l   a1,a5
[00011788] 3c0c                      move.w    a4,d6
[0001178a] 3010                      move.w    (a0),d0
[0001178c] d040                      add.w     d0,d0
[0001178e] 645e                      bcc.s     $000117EE
[00011790] 3802                      move.w    d2,d4
[00011792] d846                      add.w     d6,d4
[00011794] e84c                      lsr.w     #4,d4
[00011796] 3a04                      move.w    d4,d5
[00011798] e84c                      lsr.w     #4,d4
[0001179a] 4645                      not.w     d5
[0001179c] 0245 000f                 andi.w    #$000F,d5
[000117a0] da45                      add.w     d5,d5
[000117a2] da45                      add.w     d5,d5
[000117a4] 2c4d                      movea.l   a5,a6
[000117a6] 4efb 5002                 jmp       $000117AA(pc,d5.w)
[000117aa] 3c87                      move.w    d7,(a6)
[000117ac] dcca                      adda.w    a2,a6
[000117ae] 3c87                      move.w    d7,(a6)
[000117b0] dcca                      adda.w    a2,a6
[000117b2] 3c87                      move.w    d7,(a6)
[000117b4] dcca                      adda.w    a2,a6
[000117b6] 3c87                      move.w    d7,(a6)
[000117b8] dcca                      adda.w    a2,a6
[000117ba] 3c87                      move.w    d7,(a6)
[000117bc] dcca                      adda.w    a2,a6
[000117be] 3c87                      move.w    d7,(a6)
[000117c0] dcca                      adda.w    a2,a6
[000117c2] 3c87                      move.w    d7,(a6)
[000117c4] dcca                      adda.w    a2,a6
[000117c6] 3c87                      move.w    d7,(a6)
[000117c8] dcca                      adda.w    a2,a6
[000117ca] 3c87                      move.w    d7,(a6)
[000117cc] dcca                      adda.w    a2,a6
[000117ce] 3c87                      move.w    d7,(a6)
[000117d0] dcca                      adda.w    a2,a6
[000117d2] 3c87                      move.w    d7,(a6)
[000117d4] dcca                      adda.w    a2,a6
[000117d6] 3c87                      move.w    d7,(a6)
[000117d8] dcca                      adda.w    a2,a6
[000117da] 3c87                      move.w    d7,(a6)
[000117dc] dcca                      adda.w    a2,a6
[000117de] 3c87                      move.w    d7,(a6)
[000117e0] dcca                      adda.w    a2,a6
[000117e2] 3c87                      move.w    d7,(a6)
[000117e4] dcca                      adda.w    a2,a6
[000117e6] 3c87                      move.w    d7,(a6)
[000117e8] dcca                      adda.w    a2,a6
[000117ea] 51cc ffbe                 dbf       d4,$000117AA
[000117ee] 548d                      addq.l    #2,a5
[000117f0] 51ce ff9a                 dbf       d6,$0001178C
[000117f4] dbcb                      adda.l    a3,a5
[000117f6] 51c9 ff90                 dbf       d1,$00011788
[000117fa] 5488                      addq.l    #2,a0
[000117fc] d2d7                      adda.w    (a7),a1
[000117fe] 5343                      subq.w    #1,d3
[00011800] 4843                      swap      d3
[00011802] 51cb ff7c                 dbf       d3,$00011780
[00011806] 548f                      addq.l    #2,a7
[00011808] 4e75                      rts
[0001180a] 206e 01c2                 movea.l   450(a6),a0
[0001180e] 226e 01d6                 movea.l   470(a6),a1
[00011812] 346e 01c6                 movea.w   454(a6),a2
[00011816] 366e 01da                 movea.w   474(a6),a3
[0001181a] 026e 0003 01ee            andi.w    #$0003,494(a6)
[00011820] 3c0a                      move.w    a2,d6
[00011822] 3e0b                      move.w    a3,d7
[00011824] c3c6                      muls.w    d6,d1
[00011826] d1c1                      adda.l    d1,a0
[00011828] 3200                      move.w    d0,d1
[0001182a] e849                      lsr.w     #4,d1
[0001182c] d241                      add.w     d1,d1
[0001182e] d0c1                      adda.w    d1,a0
[00011830] c7c7                      muls.w    d7,d3
[00011832] d3c3                      adda.l    d3,a1
[00011834] d442                      add.w     d2,d2
[00011836] d2c2                      adda.w    d2,a1
[00011838] 720f                      moveq.l   #15,d1
[0001183a] c041                      and.w     d1,d0
[0001183c] b141                      eor.w     d0,d1
[0001183e] b841                      cmp.w     d1,d4
[00011840] 6c02                      bge.s     $00011844
[00011842] 3204                      move.w    d4,d1
[00011844] 4840                      swap      d0
[00011846] 3001                      move.w    d1,d0
[00011848] 4840                      swap      d0
[0001184a] 3400                      move.w    d0,d2
[0001184c] d444                      add.w     d4,d2
[0001184e] e84a                      lsr.w     #4,d2
[00011850] d442                      add.w     d2,d2
[00011852] 5442                      addq.w    #2,d2
[00011854] 94c2                      suba.w    d2,a2
[00011856] 3404                      move.w    d4,d2
[00011858] d442                      add.w     d2,d2
[0001185a] 5442                      addq.w    #2,d2
[0001185c] 96c2                      suba.w    d2,a3
[0001185e] 49ee 0458                 lea.l     1112(a6),a4
[00011862] 2a4c                      movea.l   a4,a5
[00011864] 3c2e 01ea                 move.w    490(a6),d6
[00011868] dc46                      add.w     d6,d6
[0001186a] d8c6                      adda.w    d6,a4
[0001186c] 2c14                      move.l    (a4),d6
[0001186e] 3c14                      move.w    (a4),d6
[00011870] 3e2e 01ec                 move.w    492(a6),d7
[00011874] de47                      add.w     d7,d7
[00011876] dac7                      adda.w    d7,a5
[00011878] 2e15                      move.l    (a5),d7
[0001187a] 3e15                      move.w    (a5),d7
[0001187c] 342e 01ee                 move.w    494(a6),d2
[00011880] d442                      add.w     d2,d2
[00011882] 343b 2006                 move.w    $0001188A(pc,d2.w),d2
[00011886] 4efb 2002                 jmp       $0001188A(pc,d2.w)
J3:
[0001188a] 0008                      dc.w $0008   ; $00011892-$0001188a
[0001188c] 007c                      dc.w $007c   ; $00011906-$0001188a
[0001188e] 00e6                      dc.w $00e6   ; $00011970-$0001188a
[00011890] 0150                      dc.w $0150   ; $000119da-$0001188a
[00011892] 2406                      move.l    d6,d2
[00011894] 3407                      move.w    d7,d2
[00011896] 2842                      movea.l   d2,a4
[00011898] 2607                      move.l    d7,d3
[0001189a] 3606                      move.w    d6,d3
[0001189c] 2a43                      movea.l   d3,a5
[0001189e] 3604                      move.w    d4,d3
[000118a0] 3418                      move.w    (a0)+,d2
[000118a2] e17a                      rol.w     d0,d2
[000118a4] 2200                      move.l    d0,d1
[000118a6] 4841                      swap      d1
[000118a8] 6002                      bra.s     $000118AC
[000118aa] 3418                      move.w    (a0)+,d2
[000118ac] 9641                      sub.w     d1,d3
[000118ae] 5343                      subq.w    #1,d3
[000118b0] 5441                      addq.w    #2,d1
[000118b2] 600a                      bra.s     $000118BE
[000118b4] d442                      add.w     d2,d2
[000118b6] 6418                      bcc.s     $000118D0
[000118b8] d442                      add.w     d2,d2
[000118ba] 640a                      bcc.s     $000118C6
[000118bc] 22c6                      move.l    d6,(a1)+
[000118be] 5541                      subq.w    #2,d1
[000118c0] 6ef2                      bgt.s     $000118B4
[000118c2] 6724                      beq.s     $000118E8
[000118c4] 602c                      bra.s     $000118F2
[000118c6] 22cc                      move.l    a4,(a1)+
[000118c8] 5541                      subq.w    #2,d1
[000118ca] 6ee8                      bgt.s     $000118B4
[000118cc] 671a                      beq.s     $000118E8
[000118ce] 6022                      bra.s     $000118F2
[000118d0] d442                      add.w     d2,d2
[000118d2] 650a                      bcs.s     $000118DE
[000118d4] 22c7                      move.l    d7,(a1)+
[000118d6] 5541                      subq.w    #2,d1
[000118d8] 6eda                      bgt.s     $000118B4
[000118da] 670c                      beq.s     $000118E8
[000118dc] 6014                      bra.s     $000118F2
[000118de] 22cd                      move.l    a5,(a1)+
[000118e0] 5541                      subq.w    #2,d1
[000118e2] 6ed0                      bgt.s     $000118B4
[000118e4] 6702                      beq.s     $000118E8
[000118e6] 600a                      bra.s     $000118F2
[000118e8] d442                      add.w     d2,d2
[000118ea] 6404                      bcc.s     $000118F0
[000118ec] 32c6                      move.w    d6,(a1)+
[000118ee] 6002                      bra.s     $000118F2
[000118f0] 32c7                      move.w    d7,(a1)+
[000118f2] 720f                      moveq.l   #15,d1
[000118f4] b641                      cmp.w     d1,d3
[000118f6] 6cb2                      bge.s     $000118AA
[000118f8] 3203                      move.w    d3,d1
[000118fa] 6aae                      bpl.s     $000118AA
[000118fc] d0ca                      adda.w    a2,a0
[000118fe] d2cb                      adda.w    a3,a1
[00011900] 51cd ff9c                 dbf       d5,$0001189E
[00011904] 4e75                      rts
[00011906] 3604                      move.w    d4,d3
[00011908] 3418                      move.w    (a0)+,d2
[0001190a] e17a                      rol.w     d0,d2
[0001190c] 2200                      move.l    d0,d1
[0001190e] 4841                      swap      d1
[00011910] 6002                      bra.s     $00011914
[00011912] 3418                      move.w    (a0)+,d2
[00011914] 9641                      sub.w     d1,d3
[00011916] 5343                      subq.w    #1,d3
[00011918] 5441                      addq.w    #2,d1
[0001191a] 6024                      bra.s     $00011940
[0001191c] d442                      add.w     d2,d2
[0001191e] 651a                      bcs.s     $0001193A
[00011920] d442                      add.w     d2,d2
[00011922] 650a                      bcs.s     $0001192E
[00011924] 5889                      addq.l    #4,a1
[00011926] 5541                      subq.w    #2,d1
[00011928] 6ef2                      bgt.s     $0001191C
[0001192a] 6728                      beq.s     $00011954
[0001192c] 602e                      bra.s     $0001195C
[0001192e] 5489                      addq.l    #2,a1
[00011930] 32c6                      move.w    d6,(a1)+
[00011932] 5541                      subq.w    #2,d1
[00011934] 6ee6                      bgt.s     $0001191C
[00011936] 671c                      beq.s     $00011954
[00011938] 6022                      bra.s     $0001195C
[0001193a] d442                      add.w     d2,d2
[0001193c] 640a                      bcc.s     $00011948
[0001193e] 22c6                      move.l    d6,(a1)+
[00011940] 5541                      subq.w    #2,d1
[00011942] 6ed8                      bgt.s     $0001191C
[00011944] 670e                      beq.s     $00011954
[00011946] 6014                      bra.s     $0001195C
[00011948] 32c6                      move.w    d6,(a1)+
[0001194a] 5489                      addq.l    #2,a1
[0001194c] 5541                      subq.w    #2,d1
[0001194e] 6ecc                      bgt.s     $0001191C
[00011950] 6702                      beq.s     $00011954
[00011952] 6008                      bra.s     $0001195C
[00011954] d442                      add.w     d2,d2
[00011956] 6402                      bcc.s     $0001195A
[00011958] 3286                      move.w    d6,(a1)
[0001195a] 5489                      addq.l    #2,a1
[0001195c] 720f                      moveq.l   #15,d1
[0001195e] b641                      cmp.w     d1,d3
[00011960] 6cb0                      bge.s     $00011912
[00011962] 3203                      move.w    d3,d1
[00011964] 6aac                      bpl.s     $00011912
[00011966] d0ca                      adda.w    a2,a0
[00011968] d2cb                      adda.w    a3,a1
[0001196a] 51cd ff9a                 dbf       d5,$00011906
[0001196e] 4e75                      rts
[00011970] 3604                      move.w    d4,d3
[00011972] 3418                      move.w    (a0)+,d2
[00011974] e17a                      rol.w     d0,d2
[00011976] 2200                      move.l    d0,d1
[00011978] 4841                      swap      d1
[0001197a] 6002                      bra.s     $0001197E
[0001197c] 3418                      move.w    (a0)+,d2
[0001197e] 9641                      sub.w     d1,d3
[00011980] 5343                      subq.w    #1,d3
[00011982] 5441                      addq.w    #2,d1
[00011984] 6024                      bra.s     $000119AA
[00011986] d442                      add.w     d2,d2
[00011988] 651a                      bcs.s     $000119A4
[0001198a] d442                      add.w     d2,d2
[0001198c] 650a                      bcs.s     $00011998
[0001198e] 5889                      addq.l    #4,a1
[00011990] 5541                      subq.w    #2,d1
[00011992] 6ef2                      bgt.s     $00011986
[00011994] 6728                      beq.s     $000119BE
[00011996] 602e                      bra.s     $000119C6
[00011998] 5489                      addq.l    #2,a1
[0001199a] 4659                      not.w     (a1)+
[0001199c] 5541                      subq.w    #2,d1
[0001199e] 6ee6                      bgt.s     $00011986
[000119a0] 671c                      beq.s     $000119BE
[000119a2] 6022                      bra.s     $000119C6
[000119a4] d442                      add.w     d2,d2
[000119a6] 640a                      bcc.s     $000119B2
[000119a8] 4699                      not.l     (a1)+
[000119aa] 5541                      subq.w    #2,d1
[000119ac] 6ed8                      bgt.s     $00011986
[000119ae] 670e                      beq.s     $000119BE
[000119b0] 6014                      bra.s     $000119C6
[000119b2] 4659                      not.w     (a1)+
[000119b4] 5489                      addq.l    #2,a1
[000119b6] 5541                      subq.w    #2,d1
[000119b8] 6ecc                      bgt.s     $00011986
[000119ba] 6702                      beq.s     $000119BE
[000119bc] 6008                      bra.s     $000119C6
[000119be] d442                      add.w     d2,d2
[000119c0] 6402                      bcc.s     $000119C4
[000119c2] 4651                      not.w     (a1)
[000119c4] 5489                      addq.l    #2,a1
[000119c6] 720f                      moveq.l   #15,d1
[000119c8] b641                      cmp.w     d1,d3
[000119ca] 6cb0                      bge.s     $0001197C
[000119cc] 3203                      move.w    d3,d1
[000119ce] 6aac                      bpl.s     $0001197C
[000119d0] d0ca                      adda.w    a2,a0
[000119d2] d2cb                      adda.w    a3,a1
[000119d4] 51cd ff9a                 dbf       d5,$00011970
[000119d8] 4e75                      rts
[000119da] 3604                      move.w    d4,d3
[000119dc] 3418                      move.w    (a0)+,d2
[000119de] e17a                      rol.w     d0,d2
[000119e0] 2200                      move.l    d0,d1
[000119e2] 4841                      swap      d1
[000119e4] 6002                      bra.s     $000119E8
[000119e6] 3418                      move.w    (a0)+,d2
[000119e8] 9641                      sub.w     d1,d3
[000119ea] 5343                      subq.w    #1,d3
[000119ec] 5441                      addq.w    #2,d1
[000119ee] 600a                      bra.s     $000119FA
[000119f0] d442                      add.w     d2,d2
[000119f2] 651a                      bcs.s     $00011A0E
[000119f4] d442                      add.w     d2,d2
[000119f6] 650a                      bcs.s     $00011A02
[000119f8] 22c7                      move.l    d7,(a1)+
[000119fa] 5541                      subq.w    #2,d1
[000119fc] 6ef2                      bgt.s     $000119F0
[000119fe] 6728                      beq.s     $00011A28
[00011a00] 602e                      bra.s     $00011A30
[00011a02] 32c7                      move.w    d7,(a1)+
[00011a04] 5489                      addq.l    #2,a1
[00011a06] 5541                      subq.w    #2,d1
[00011a08] 6ee6                      bgt.s     $000119F0
[00011a0a] 671c                      beq.s     $00011A28
[00011a0c] 6022                      bra.s     $00011A30
[00011a0e] d442                      add.w     d2,d2
[00011a10] 640a                      bcc.s     $00011A1C
[00011a12] 5889                      addq.l    #4,a1
[00011a14] 5541                      subq.w    #2,d1
[00011a16] 6ed8                      bgt.s     $000119F0
[00011a18] 670e                      beq.s     $00011A28
[00011a1a] 6014                      bra.s     $00011A30
[00011a1c] 5489                      addq.l    #2,a1
[00011a1e] 32c7                      move.w    d7,(a1)+
[00011a20] 5541                      subq.w    #2,d1
[00011a22] 6ecc                      bgt.s     $000119F0
[00011a24] 6702                      beq.s     $00011A28
[00011a26] 6008                      bra.s     $00011A30
[00011a28] d442                      add.w     d2,d2
[00011a2a] 6502                      bcs.s     $00011A2E
[00011a2c] 3287                      move.w    d7,(a1)
[00011a2e] 5489                      addq.l    #2,a1
[00011a30] 720f                      moveq.l   #15,d1
[00011a32] b641                      cmp.w     d1,d3
[00011a34] 6cb0                      bge.s     $000119E6
[00011a36] 3203                      move.w    d3,d1
[00011a38] 6aac                      bpl.s     $000119E6
[00011a3a] d0ca                      adda.w    a2,a0
[00011a3c] d2cb                      adda.w    a3,a1
[00011a3e] 51cd ff9a                 dbf       d5,$000119DA
[00011a42] 4e75                      rts
[00011a44] 4e75                      rts
[00011a46] bc44                      cmp.w     d4,d6
[00011a48] be45                      cmp.w     d5,d7
[00011a4a] 08ae 0004 01ef            bclr      #4,495(a6)
[00011a50] 6600 fdb8                 bne       $0001180A
[00011a54] 7e0f                      moveq.l   #15,d7
[00011a56] ce6e 01ee                 and.w     494(a6),d7
[00011a5a] 206e 01c2                 movea.l   450(a6),a0
[00011a5e] 226e 01d6                 movea.l   470(a6),a1
[00011a62] 346e 01c6                 movea.w   454(a6),a2
[00011a66] 366e 01da                 movea.w   474(a6),a3
[00011a6a] 3c2e 01c8                 move.w    456(a6),d6
[00011a6e] bc6e 01dc                 cmp.w     476(a6),d6
[00011a72] 66d0                      bne.s     $00011A44
[00011a74] 0446 000f                 subi.w    #$000F,d6
[00011a78] 66ca                      bne.s     $00011A44
[00011a7a] 48c0                      ext.l     d0
[00011a7c] 48c2                      ext.l     d2
[00011a7e] 3c0a                      move.w    a2,d6
[00011a80] c2c6                      mulu.w    d6,d1
[00011a82] d280                      add.l     d0,d1
[00011a84] d280                      add.l     d0,d1
[00011a86] d1c1                      adda.l    d1,a0
[00011a88] 3c0b                      move.w    a3,d6
[00011a8a] c6c6                      mulu.w    d6,d3
[00011a8c] d682                      add.l     d2,d3
[00011a8e] d682                      add.l     d2,d3
[00011a90] d3c3                      adda.l    d3,a1
[00011a92] b1c9                      cmpa.l    a1,a0
[00011a94] 6200 0350                 bhi       $00011DE6
[00011a98] 3c3c 8401                 move.w    #$8401,d6
[00011a9c] 0f06                      btst      d7,d6
[00011a9e] 6600 0346                 bne       $00011DE6
[00011aa2] 3c0a                      move.w    a2,d6
[00011aa4] ccc5                      mulu.w    d5,d6
[00011aa6] 2848                      movea.l   a0,a4
[00011aa8] d9c6                      adda.l    d6,a4
[00011aaa] d8c4                      adda.w    d4,a4
[00011aac] d8c4                      adda.w    d4,a4
[00011aae] b9c9                      cmpa.l    a1,a4
[00011ab0] 6500 0334                 bcs       $00011DE6
[00011ab4] 548c                      addq.l    #2,a4
[00011ab6] d28c                      add.l     a4,d1
[00011ab8] 9288                      sub.l     a0,d1
[00011aba] 2a49                      movea.l   a1,a5
[00011abc] 3c0b                      move.w    a3,d6
[00011abe] ccc5                      mulu.w    d5,d6
[00011ac0] dbc6                      adda.l    d6,a5
[00011ac2] dac4                      adda.w    d4,a5
[00011ac4] dac4                      adda.w    d4,a5
[00011ac6] 548d                      addq.l    #2,a5
[00011ac8] d68d                      add.l     a5,d3
[00011aca] 9689                      sub.l     a1,d3
[00011acc] c14c                      exg       a0,a4
[00011ace] c34d                      exg       a1,a5
[00011ad0] 3c04                      move.w    d4,d6
[00011ad2] 5246                      addq.w    #1,d6
[00011ad4] dc46                      add.w     d6,d6
[00011ad6] 94c6                      suba.w    d6,a2
[00011ad8] 96c6                      suba.w    d6,a3
[00011ada] 7002                      moveq.l   #2,d0
[00011adc] 0804 0000                 btst      #0,d4
[00011ae0] 6604                      bne.s     $00011AE6
[00011ae2] 7000                      moveq.l   #0,d0
[00011ae4] 5344                      subq.w    #1,d4
[00011ae6] 7206                      moveq.l   #6,d1
[00011ae8] c244                      and.w     d4,d1
[00011aea] 0a41 0006                 eori.w    #$0006,d1
[00011aee] e644                      asr.w     #3,d4
[00011af0] 4a44                      tst.w     d4
[00011af2] 6a04                      bpl.s     $00011AF8
[00011af4] 7800                      moveq.l   #0,d4
[00011af6] 7208                      moveq.l   #8,d1
[00011af8] de47                      add.w     d7,d7
[00011afa] de47                      add.w     d7,d7
[00011afc] 49fb 7022                 lea.l     $00011B20(pc,d7.w),a4
[00011b00] 3e1c                      move.w    (a4)+,d7
[00011b02] 6716                      beq.s     $00011B1A
[00011b04] 5347                      subq.w    #1,d7
[00011b06] 670e                      beq.s     $00011B16
[00011b08] 3e00                      move.w    d0,d7
[00011b0a] d040                      add.w     d0,d0
[00011b0c] d047                      add.w     d7,d0
[00011b0e] 3e01                      move.w    d1,d7
[00011b10] d241                      add.w     d1,d1
[00011b12] d247                      add.w     d7,d1
[00011b14] 6004                      bra.s     $00011B1A
[00011b16] d040                      add.w     d0,d0
[00011b18] d241                      add.w     d1,d1
[00011b1a] 3e1c                      move.w    (a4)+,d7
[00011b1c] 4efb 7002                 jmp       $00011B20(pc,d7.w)
[00011b20] 0000 035a                 ori.b     #$5A,d0
[00011b24] 0001 0040                 ori.b     #$40,d1
[00011b28] 0002 0070                 ori.b     #$70,d2
[00011b2c] 0000 00aa                 ori.b     #$AA,d0
[00011b30] 0002 00d0                 ori.b     #$D0,d2
[00011b34] 0000 0108                 ori.b     #$08,d0
[00011b38] 0001 010a                 ori.b     #$0A,d1
[00011b3c] 0001 013a                 ori.b     #$3A,d1
[00011b40] 0002 016a                 ori.b     #$6A,d2
[00011b44] 0002 01a4                 ori.b     #$A4,d2
[00011b48] 0000 051e                 ori.b     #$1E,d0
[00011b4c] 0002 01de                 ori.b     #$DE,d2
[00011b50] 0002 0218                 ori.b     #$18,d2
[00011b54] 0002 0252                 ori.b     #$52,d2
[00011b58] 0002 028c                 ori.b     #$8C,d2
[00011b5c] 0000 0356                 ori.b     #$56,d0
[00011b60] 49fb 2008                 lea.l     $00011B6A(pc,d2.w),a4
[00011b64] 4bfb 100c                 lea.l     $00011B72(pc,d1.w),a5
[00011b68] 4ed4                      jmp       (a4)
[00011b6a] 3020                      move.w    -(a0),d0
[00011b6c] c161                      and.w     d0,-(a1)
[00011b6e] 3c04                      move.w    d4,d6
[00011b70] 4ed5                      jmp       (a5)
[00011b72] 2020                      move.l    -(a0),d0
[00011b74] c1a1                      and.l     d0,-(a1)
[00011b76] 2020                      move.l    -(a0),d0
[00011b78] c1a1                      and.l     d0,-(a1)
[00011b7a] 2020                      move.l    -(a0),d0
[00011b7c] c1a1                      and.l     d0,-(a1)
[00011b7e] 2020                      move.l    -(a0),d0
[00011b80] c1a1                      and.l     d0,-(a1)
[00011b82] 51ce ffee                 dbf       d6,$00011B72
[00011b86] 90ca                      suba.w    a2,a0
[00011b88] 92cb                      suba.w    a3,a1
[00011b8a] 51cd ffdc                 dbf       d5,$00011B68
[00011b8e] 4e75                      rts
[00011b90] 49fb 0008                 lea.l     $00011B9A(pc,d0.w),a4
[00011b94] 4bfb 100e                 lea.l     $00011BA4(pc,d1.w),a5
[00011b98] 4ed4                      jmp       (a4)
[00011b9a] 3020                      move.w    -(a0),d0
[00011b9c] 4651                      not.w     (a1)
[00011b9e] c161                      and.w     d0,-(a1)
[00011ba0] 3c04                      move.w    d4,d6
[00011ba2] 4ed5                      jmp       (a5)
[00011ba4] 2020                      move.l    -(a0),d0
[00011ba6] 4691                      not.l     (a1)
[00011ba8] c1a1                      and.l     d0,-(a1)
[00011baa] 2020                      move.l    -(a0),d0
[00011bac] 4691                      not.l     (a1)
[00011bae] c1a1                      and.l     d0,-(a1)
[00011bb0] 2020                      move.l    -(a0),d0
[00011bb2] 4691                      not.l     (a1)
[00011bb4] c1a1                      and.l     d0,-(a1)
[00011bb6] 2020                      move.l    -(a0),d0
[00011bb8] 4691                      not.l     (a1)
[00011bba] c1a1                      and.l     d0,-(a1)
[00011bbc] 51ce ffe6                 dbf       d6,$00011BA4
[00011bc0] 90ca                      suba.w    a2,a0
[00011bc2] 92cb                      suba.w    a3,a1
[00011bc4] 51cd ffd2                 dbf       d5,$00011B98
[00011bc8] 4e75                      rts
[00011bca] 49fb 0008                 lea.l     $00011BD4(pc,d0.w),a4
[00011bce] 4bfb 100a                 lea.l     $00011BDA(pc,d1.w),a5
[00011bd2] 4ed4                      jmp       (a4)
[00011bd4] 3320                      move.w    -(a0),-(a1)
[00011bd6] 3c04                      move.w    d4,d6
[00011bd8] 4ed5                      jmp       (a5)
[00011bda] 2320                      move.l    -(a0),-(a1)
[00011bdc] 2320                      move.l    -(a0),-(a1)
[00011bde] 2320                      move.l    -(a0),-(a1)
[00011be0] 2320                      move.l    -(a0),-(a1)
[00011be2] 51ce fff6                 dbf       d6,$00011BDA
[00011be6] 90ca                      suba.w    a2,a0
[00011be8] 92cb                      suba.w    a3,a1
[00011bea] 51cd ffe6                 dbf       d5,$00011BD2
[00011bee] 4e75                      rts
[00011bf0] 49fb 0008                 lea.l     $00011BFA(pc,d0.w),a4
[00011bf4] 4bfb 100e                 lea.l     $00011C04(pc,d1.w),a5
[00011bf8] 4ed4                      jmp       (a4)
[00011bfa] 3020                      move.w    -(a0),d0
[00011bfc] 4640                      not.w     d0
[00011bfe] c161                      and.w     d0,-(a1)
[00011c00] 3c04                      move.w    d4,d6
[00011c02] 4ed5                      jmp       (a5)
[00011c04] 2020                      move.l    -(a0),d0
[00011c06] 4680                      not.l     d0
[00011c08] c1a1                      and.l     d0,-(a1)
[00011c0a] 2020                      move.l    -(a0),d0
[00011c0c] 4680                      not.l     d0
[00011c0e] c1a1                      and.l     d0,-(a1)
[00011c10] 2020                      move.l    -(a0),d0
[00011c12] 4680                      not.l     d0
[00011c14] c1a1                      and.l     d0,-(a1)
[00011c16] 2020                      move.l    -(a0),d0
[00011c18] 4680                      not.l     d0
[00011c1a] c1a1                      and.l     d0,-(a1)
[00011c1c] 51ce ffe6                 dbf       d6,$00011C04
[00011c20] 90ca                      suba.w    a2,a0
[00011c22] 92cb                      suba.w    a3,a1
[00011c24] 51cd ffd2                 dbf       d5,$00011BF8
[00011c28] 4e75                      rts
[00011c2a] 49fb 0008                 lea.l     $00011C34(pc,d0.w),a4
[00011c2e] 4bfb 100c                 lea.l     $00011C3C(pc,d1.w),a5
[00011c32] 4ed4                      jmp       (a4)
[00011c34] 3020                      move.w    -(a0),d0
[00011c36] b161                      eor.w     d0,-(a1)
[00011c38] 3c04                      move.w    d4,d6
[00011c3a] 4ed5                      jmp       (a5)
[00011c3c] 2020                      move.l    -(a0),d0
[00011c3e] b1a1                      eor.l     d0,-(a1)
[00011c40] 2020                      move.l    -(a0),d0
[00011c42] b1a1                      eor.l     d0,-(a1)
[00011c44] 2020                      move.l    -(a0),d0
[00011c46] b1a1                      eor.l     d0,-(a1)
[00011c48] 2020                      move.l    -(a0),d0
[00011c4a] b1a1                      eor.l     d0,-(a1)
[00011c4c] 51ce ffee                 dbf       d6,$00011C3C
[00011c50] 90ca                      suba.w    a2,a0
[00011c52] 92cb                      suba.w    a3,a1
[00011c54] 51cd ffdc                 dbf       d5,$00011C32
[00011c58] 4e75                      rts
[00011c5a] 49fb 0008                 lea.l     $00011C64(pc,d0.w),a4
[00011c5e] 4bfb 100c                 lea.l     $00011C6C(pc,d1.w),a5
[00011c62] 4ed4                      jmp       (a4)
[00011c64] 3020                      move.w    -(a0),d0
[00011c66] 8161                      or.w      d0,-(a1)
[00011c68] 3c04                      move.w    d4,d6
[00011c6a] 4ed5                      jmp       (a5)
[00011c6c] 2020                      move.l    -(a0),d0
[00011c6e] 81a1                      or.l      d0,-(a1)
[00011c70] 2020                      move.l    -(a0),d0
[00011c72] 81a1                      or.l      d0,-(a1)
[00011c74] 2020                      move.l    -(a0),d0
[00011c76] 81a1                      or.l      d0,-(a1)
[00011c78] 2020                      move.l    -(a0),d0
[00011c7a] 81a1                      or.l      d0,-(a1)
[00011c7c] 51ce ffee                 dbf       d6,$00011C6C
[00011c80] 90ca                      suba.w    a2,a0
[00011c82] 92cb                      suba.w    a3,a1
[00011c84] 51cd ffdc                 dbf       d5,$00011C62
[00011c88] 4e75                      rts
[00011c8a] 49fb 0008                 lea.l     $00011C94(pc,d0.w),a4
[00011c8e] 4bfb 100e                 lea.l     $00011C9E(pc,d1.w),a5
[00011c92] 4ed4                      jmp       (a4)
[00011c94] 3020                      move.w    -(a0),d0
[00011c96] 8151                      or.w      d0,(a1)
[00011c98] 4661                      not.w     -(a1)
[00011c9a] 3c04                      move.w    d4,d6
[00011c9c] 4ed5                      jmp       (a5)
[00011c9e] 2020                      move.l    -(a0),d0
[00011ca0] 8191                      or.l      d0,(a1)
[00011ca2] 46a1                      not.l     -(a1)
[00011ca4] 2020                      move.l    -(a0),d0
[00011ca6] 8191                      or.l      d0,(a1)
[00011ca8] 46a1                      not.l     -(a1)
[00011caa] 2020                      move.l    -(a0),d0
[00011cac] 8191                      or.l      d0,(a1)
[00011cae] 46a1                      not.l     -(a1)
[00011cb0] 2020                      move.l    -(a0),d0
[00011cb2] 8191                      or.l      d0,(a1)
[00011cb4] 46a1                      not.l     -(a1)
[00011cb6] 51ce ffe6                 dbf       d6,$00011C9E
[00011cba] 90ca                      suba.w    a2,a0
[00011cbc] 92cb                      suba.w    a3,a1
[00011cbe] 51cd ffd2                 dbf       d5,$00011C92
[00011cc2] 4e75                      rts
[00011cc4] 49fb 0008                 lea.l     $00011CCE(pc,d0.w),a4
[00011cc8] 4bfb 100e                 lea.l     $00011CD8(pc,d1.w),a5
[00011ccc] 4ed4                      jmp       (a4)
[00011cce] 3020                      move.w    -(a0),d0
[00011cd0] b151                      eor.w     d0,(a1)
[00011cd2] 4661                      not.w     -(a1)
[00011cd4] 3c04                      move.w    d4,d6
[00011cd6] 4ed5                      jmp       (a5)
[00011cd8] 2020                      move.l    -(a0),d0
[00011cda] b191                      eor.l     d0,(a1)
[00011cdc] 46a1                      not.l     -(a1)
[00011cde] 2020                      move.l    -(a0),d0
[00011ce0] b191                      eor.l     d0,(a1)
[00011ce2] 46a1                      not.l     -(a1)
[00011ce4] 2020                      move.l    -(a0),d0
[00011ce6] b191                      eor.l     d0,(a1)
[00011ce8] 46a1                      not.l     -(a1)
[00011cea] 2020                      move.l    -(a0),d0
[00011cec] b191                      eor.l     d0,(a1)
[00011cee] 46a1                      not.l     -(a1)
[00011cf0] 51ce ffe6                 dbf       d6,$00011CD8
[00011cf4] 90ca                      suba.w    a2,a0
[00011cf6] 92cb                      suba.w    a3,a1
[00011cf8] 51cd ffd2                 dbf       d5,$00011CCC
[00011cfc] 4e75                      rts
[00011cfe] 49fb 0008                 lea.l     $00011D08(pc,d0.w),a4
[00011d02] 4bfb 100e                 lea.l     $00011D12(pc,d1.w),a5
[00011d06] 4ed4                      jmp       (a4)
[00011d08] 4651                      not.w     (a1)
[00011d0a] 3020                      move.w    -(a0),d0
[00011d0c] 8161                      or.w      d0,-(a1)
[00011d0e] 3c04                      move.w    d4,d6
[00011d10] 4ed5                      jmp       (a5)
[00011d12] 4691                      not.l     (a1)
[00011d14] 2020                      move.l    -(a0),d0
[00011d16] 81a1                      or.l      d0,-(a1)
[00011d18] 4691                      not.l     (a1)
[00011d1a] 2020                      move.l    -(a0),d0
[00011d1c] 81a1                      or.l      d0,-(a1)
[00011d1e] 4691                      not.l     (a1)
[00011d20] 2020                      move.l    -(a0),d0
[00011d22] 81a1                      or.l      d0,-(a1)
[00011d24] 4691                      not.l     (a1)
[00011d26] 2020                      move.l    -(a0),d0
[00011d28] 81a1                      or.l      d0,-(a1)
[00011d2a] 51ce ffe6                 dbf       d6,$00011D12
[00011d2e] 90ca                      suba.w    a2,a0
[00011d30] 92cb                      suba.w    a3,a1
[00011d32] 51cd ffd2                 dbf       d5,$00011D06
[00011d36] 4e75                      rts
[00011d38] 49fb 0008                 lea.l     $00011D42(pc,d0.w),a4
[00011d3c] 4bfb 100e                 lea.l     $00011D4C(pc,d1.w),a5
[00011d40] 4ed4                      jmp       (a4)
[00011d42] 3020                      move.w    -(a0),d0
[00011d44] 4640                      not.w     d0
[00011d46] 3300                      move.w    d0,-(a1)
[00011d48] 3c04                      move.w    d4,d6
[00011d4a] 4ed5                      jmp       (a5)
[00011d4c] 2020                      move.l    -(a0),d0
[00011d4e] 4680                      not.l     d0
[00011d50] 2300                      move.l    d0,-(a1)
[00011d52] 2020                      move.l    -(a0),d0
[00011d54] 4680                      not.l     d0
[00011d56] 2300                      move.l    d0,-(a1)
[00011d58] 2020                      move.l    -(a0),d0
[00011d5a] 4680                      not.l     d0
[00011d5c] 2300                      move.l    d0,-(a1)
[00011d5e] 2020                      move.l    -(a0),d0
[00011d60] 4680                      not.l     d0
[00011d62] 2300                      move.l    d0,-(a1)
[00011d64] 51ce ffe6                 dbf       d6,$00011D4C
[00011d68] 90ca                      suba.w    a2,a0
[00011d6a] 92cb                      suba.w    a3,a1
[00011d6c] 51cd ffd2                 dbf       d5,$00011D40
[00011d70] 4e75                      rts
[00011d72] 49fb 0008                 lea.l     $00011D7C(pc,d0.w),a4
[00011d76] 4bfb 100e                 lea.l     $00011D86(pc,d1.w),a5
[00011d7a] 4ed4                      jmp       (a4)
[00011d7c] 3020                      move.w    -(a0),d0
[00011d7e] 4640                      not.w     d0
[00011d80] 8161                      or.w      d0,-(a1)
[00011d82] 3c04                      move.w    d4,d6
[00011d84] 4ed5                      jmp       (a5)
[00011d86] 2020                      move.l    -(a0),d0
[00011d88] 4680                      not.l     d0
[00011d8a] 81a1                      or.l      d0,-(a1)
[00011d8c] 2020                      move.l    -(a0),d0
[00011d8e] 4680                      not.l     d0
[00011d90] 81a1                      or.l      d0,-(a1)
[00011d92] 2020                      move.l    -(a0),d0
[00011d94] 4680                      not.l     d0
[00011d96] 81a1                      or.l      d0,-(a1)
[00011d98] 2020                      move.l    -(a0),d0
[00011d9a] 4680                      not.l     d0
[00011d9c] 81a1                      or.l      d0,-(a1)
[00011d9e] 51ce ffe6                 dbf       d6,$00011D86
[00011da2] 90ca                      suba.w    a2,a0
[00011da4] 92cb                      suba.w    a3,a1
[00011da6] 51cd ffd2                 dbf       d5,$00011D7A
[00011daa] 4e75                      rts
[00011dac] 49fb 0008                 lea.l     $00011DB6(pc,d0.w),a4
[00011db0] 4bfb 100e                 lea.l     $00011DC0(pc,d1.w),a5
[00011db4] 4ed4                      jmp       (a4)
[00011db6] 3020                      move.w    -(a0),d0
[00011db8] c151                      and.w     d0,(a1)
[00011dba] 4661                      not.w     -(a1)
[00011dbc] 3c04                      move.w    d4,d6
[00011dbe] 4ed5                      jmp       (a5)
[00011dc0] 2020                      move.l    -(a0),d0
[00011dc2] c191                      and.l     d0,(a1)
[00011dc4] 46a1                      not.l     -(a1)
[00011dc6] 2020                      move.l    -(a0),d0
[00011dc8] c191                      and.l     d0,(a1)
[00011dca] 46a1                      not.l     -(a1)
[00011dcc] 2020                      move.l    -(a0),d0
[00011dce] c191                      and.l     d0,(a1)
[00011dd0] 46a1                      not.l     -(a1)
[00011dd2] 2020                      move.l    -(a0),d0
[00011dd4] c191                      and.l     d0,(a1)
[00011dd6] 46a1                      not.l     -(a1)
[00011dd8] 51ce ffe6                 dbf       d6,$00011DC0
[00011ddc] 90ca                      suba.w    a2,a0
[00011dde] 92cb                      suba.w    a3,a1
[00011de0] 51cd ffd2                 dbf       d5,$00011DB4
[00011de4] 4e75                      rts
[00011de6] 3c04                      move.w    d4,d6
[00011de8] 5246                      addq.w    #1,d6
[00011dea] dc46                      add.w     d6,d6
[00011dec] 94c6                      suba.w    d6,a2
[00011dee] 96c6                      suba.w    d6,a3
[00011df0] 7002                      moveq.l   #2,d0
[00011df2] 0804 0000                 btst      #0,d4
[00011df6] 6604                      bne.s     $00011DFC
[00011df8] 7000                      moveq.l   #0,d0
[00011dfa] 5344                      subq.w    #1,d4
[00011dfc] 7206                      moveq.l   #6,d1
[00011dfe] c244                      and.w     d4,d1
[00011e00] 0a41 0006                 eori.w    #$0006,d1
[00011e04] e644                      asr.w     #3,d4
[00011e06] 4a44                      tst.w     d4
[00011e08] 6a04                      bpl.s     $00011E0E
[00011e0a] 7800                      moveq.l   #0,d4
[00011e0c] 7208                      moveq.l   #8,d1
[00011e0e] de47                      add.w     d7,d7
[00011e10] de47                      add.w     d7,d7
[00011e12] 49fb 7022                 lea.l     $00011E36(pc,d7.w),a4
[00011e16] 3e1c                      move.w    (a4)+,d7
[00011e18] 6716                      beq.s     $00011E30
[00011e1a] 5347                      subq.w    #1,d7
[00011e1c] 670e                      beq.s     $00011E2C
[00011e1e] 3e00                      move.w    d0,d7
[00011e20] d040                      add.w     d0,d0
[00011e22] d047                      add.w     d7,d0
[00011e24] 3e01                      move.w    d1,d7
[00011e26] d241                      add.w     d1,d1
[00011e28] d247                      add.w     d7,d1
[00011e2a] 6004                      bra.s     $00011E30
[00011e2c] d040                      add.w     d0,d0
[00011e2e] d241                      add.w     d1,d1
[00011e30] 3e1c                      move.w    (a4)+,d7
[00011e32] 4efb 7002                 jmp       $00011E36(pc,d7.w)
[00011e36] 0000 0044                 ori.b     #$44,d0
[00011e3a] 0001 006a                 ori.b     #$6A,d1
[00011e3e] 0002 009a                 ori.b     #$9A,d2
[00011e42] 0000 00d4                 ori.b     #$D4,d0
[00011e46] 0002 00fa                 ori.b     #$FA,d2
[00011e4a] 0000 fdf2                 ori.b     #$F2,d0
[00011e4e] 0001 0134                 ori.b     #$34,d1
[00011e52] 0001 0164                 ori.b     #$64,d1
[00011e56] 0002 0194                 ori.b     #$94,d2
[00011e5a] 0002 01ce                 ori.b     #$CE,d2
[00011e5e] 0000 0208                 ori.b     #$08,d0
[00011e62] 0002 022c                 ori.b     #$2C,d2
[00011e66] 0002 0266                 ori.b     #$66,d2
[00011e6a] 0002 02a0                 ori.b     #$A0,d2
[00011e6e] 0002 02da                 ori.b     #$DA,d2
[00011e72] 0000 0040                 ori.b     #$40,d0
[00011e76] 7eff                      moveq.l   #-1,d7
[00011e78] 6002                      bra.s     $00011E7C
[00011e7a] 7e00                      moveq.l   #0,d7
[00011e7c] 49fb 0008                 lea.l     $00011E86(pc,d0.w),a4
[00011e80] 4bfb 100a                 lea.l     $00011E8C(pc,d1.w),a5
[00011e84] 4ed4                      jmp       (a4)
[00011e86] 32c7                      move.w    d7,(a1)+
[00011e88] 3c04                      move.w    d4,d6
[00011e8a] 4ed5                      jmp       (a5)
[00011e8c] 22c7                      move.l    d7,(a1)+
[00011e8e] 22c7                      move.l    d7,(a1)+
[00011e90] 22c7                      move.l    d7,(a1)+
[00011e92] 22c7                      move.l    d7,(a1)+
[00011e94] 51ce fff6                 dbf       d6,$00011E8C
[00011e98] d2cb                      adda.w    a3,a1
[00011e9a] 51cd ffe8                 dbf       d5,$00011E84
[00011e9e] 4e75                      rts
[00011ea0] 49fb 0008                 lea.l     $00011EAA(pc,d0.w),a4
[00011ea4] 4bfb 100c                 lea.l     $00011EB2(pc,d1.w),a5
[00011ea8] 4ed4                      jmp       (a4)
[00011eaa] 3018                      move.w    (a0)+,d0
[00011eac] c159                      and.w     d0,(a1)+
[00011eae] 3c04                      move.w    d4,d6
[00011eb0] 4ed5                      jmp       (a5)
[00011eb2] 2018                      move.l    (a0)+,d0
[00011eb4] c199                      and.l     d0,(a1)+
[00011eb6] 2018                      move.l    (a0)+,d0
[00011eb8] c199                      and.l     d0,(a1)+
[00011eba] 2018                      move.l    (a0)+,d0
[00011ebc] c199                      and.l     d0,(a1)+
[00011ebe] 2018                      move.l    (a0)+,d0
[00011ec0] c199                      and.l     d0,(a1)+
[00011ec2] 51ce ffee                 dbf       d6,$00011EB2
[00011ec6] d0ca                      adda.w    a2,a0
[00011ec8] d2cb                      adda.w    a3,a1
[00011eca] 51cd ffdc                 dbf       d5,$00011EA8
[00011ece] 4e75                      rts
[00011ed0] 49fb 0008                 lea.l     $00011EDA(pc,d0.w),a4
[00011ed4] 4bfb 100e                 lea.l     $00011EE4(pc,d1.w),a5
[00011ed8] 4ed4                      jmp       (a4)
[00011eda] 3018                      move.w    (a0)+,d0
[00011edc] 4651                      not.w     (a1)
[00011ede] c159                      and.w     d0,(a1)+
[00011ee0] 3c04                      move.w    d4,d6
[00011ee2] 4ed5                      jmp       (a5)
[00011ee4] 2018                      move.l    (a0)+,d0
[00011ee6] 4691                      not.l     (a1)
[00011ee8] c199                      and.l     d0,(a1)+
[00011eea] 2018                      move.l    (a0)+,d0
[00011eec] 4691                      not.l     (a1)
[00011eee] c199                      and.l     d0,(a1)+
[00011ef0] 2018                      move.l    (a0)+,d0
[00011ef2] 4691                      not.l     (a1)
[00011ef4] c199                      and.l     d0,(a1)+
[00011ef6] 2018                      move.l    (a0)+,d0
[00011ef8] 4691                      not.l     (a1)
[00011efa] c199                      and.l     d0,(a1)+
[00011efc] 51ce ffe6                 dbf       d6,$00011EE4
[00011f00] d0ca                      adda.w    a2,a0
[00011f02] d2cb                      adda.w    a3,a1
[00011f04] 51cd ffd2                 dbf       d5,$00011ED8
[00011f08] 4e75                      rts
[00011f0a] 49fb 0008                 lea.l     $00011F14(pc,d0.w),a4
[00011f0e] 4bfb 100a                 lea.l     $00011F1A(pc,d1.w),a5
[00011f12] 4ed4                      jmp       (a4)
[00011f14] 32d8                      move.w    (a0)+,(a1)+
[00011f16] 3c04                      move.w    d4,d6
[00011f18] 4ed5                      jmp       (a5)
[00011f1a] 22d8                      move.l    (a0)+,(a1)+
[00011f1c] 22d8                      move.l    (a0)+,(a1)+
[00011f1e] 22d8                      move.l    (a0)+,(a1)+
[00011f20] 22d8                      move.l    (a0)+,(a1)+
[00011f22] 51ce fff6                 dbf       d6,$00011F1A
[00011f26] d0ca                      adda.w    a2,a0
[00011f28] d2cb                      adda.w    a3,a1
[00011f2a] 51cd ffe6                 dbf       d5,$00011F12
[00011f2e] 4e75                      rts
[00011f30] 49fb 0008                 lea.l     $00011F3A(pc,d0.w),a4
[00011f34] 4bfb 100e                 lea.l     $00011F44(pc,d1.w),a5
[00011f38] 4ed4                      jmp       (a4)
[00011f3a] 3018                      move.w    (a0)+,d0
[00011f3c] 4640                      not.w     d0
[00011f3e] c159                      and.w     d0,(a1)+
[00011f40] 3c04                      move.w    d4,d6
[00011f42] 4ed5                      jmp       (a5)
[00011f44] 2018                      move.l    (a0)+,d0
[00011f46] 4680                      not.l     d0
[00011f48] c199                      and.l     d0,(a1)+
[00011f4a] 2018                      move.l    (a0)+,d0
[00011f4c] 4680                      not.l     d0
[00011f4e] c199                      and.l     d0,(a1)+
[00011f50] 2018                      move.l    (a0)+,d0
[00011f52] 4680                      not.l     d0
[00011f54] c199                      and.l     d0,(a1)+
[00011f56] 2018                      move.l    (a0)+,d0
[00011f58] 4680                      not.l     d0
[00011f5a] c199                      and.l     d0,(a1)+
[00011f5c] 51ce ffe6                 dbf       d6,$00011F44
[00011f60] d0ca                      adda.w    a2,a0
[00011f62] d2cb                      adda.w    a3,a1
[00011f64] 51cd ffd2                 dbf       d5,$00011F38
[00011f68] 4e75                      rts
[00011f6a] 49fb 0008                 lea.l     $00011F74(pc,d0.w),a4
[00011f6e] 4bfb 100c                 lea.l     $00011F7C(pc,d1.w),a5
[00011f72] 4ed4                      jmp       (a4)
[00011f74] 3018                      move.w    (a0)+,d0
[00011f76] b159                      eor.w     d0,(a1)+
[00011f78] 3c04                      move.w    d4,d6
[00011f7a] 4ed5                      jmp       (a5)
[00011f7c] 2018                      move.l    (a0)+,d0
[00011f7e] b199                      eor.l     d0,(a1)+
[00011f80] 2018                      move.l    (a0)+,d0
[00011f82] b199                      eor.l     d0,(a1)+
[00011f84] 2018                      move.l    (a0)+,d0
[00011f86] b199                      eor.l     d0,(a1)+
[00011f88] 2018                      move.l    (a0)+,d0
[00011f8a] b199                      eor.l     d0,(a1)+
[00011f8c] 51ce ffee                 dbf       d6,$00011F7C
[00011f90] d0ca                      adda.w    a2,a0
[00011f92] d2cb                      adda.w    a3,a1
[00011f94] 51cd ffdc                 dbf       d5,$00011F72
[00011f98] 4e75                      rts
[00011f9a] 49fb 0008                 lea.l     $00011FA4(pc,d0.w),a4
[00011f9e] 4bfb 100c                 lea.l     $00011FAC(pc,d1.w),a5
[00011fa2] 4ed4                      jmp       (a4)
[00011fa4] 3018                      move.w    (a0)+,d0
[00011fa6] 8159                      or.w      d0,(a1)+
[00011fa8] 3c04                      move.w    d4,d6
[00011faa] 4ed5                      jmp       (a5)
[00011fac] 2018                      move.l    (a0)+,d0
[00011fae] 8199                      or.l      d0,(a1)+
[00011fb0] 2018                      move.l    (a0)+,d0
[00011fb2] 8199                      or.l      d0,(a1)+
[00011fb4] 2018                      move.l    (a0)+,d0
[00011fb6] 8199                      or.l      d0,(a1)+
[00011fb8] 2018                      move.l    (a0)+,d0
[00011fba] 8199                      or.l      d0,(a1)+
[00011fbc] 51ce ffee                 dbf       d6,$00011FAC
[00011fc0] d0ca                      adda.w    a2,a0
[00011fc2] d2cb                      adda.w    a3,a1
[00011fc4] 51cd ffdc                 dbf       d5,$00011FA2
[00011fc8] 4e75                      rts
[00011fca] 49fb 0008                 lea.l     $00011FD4(pc,d0.w),a4
[00011fce] 4bfb 100e                 lea.l     $00011FDE(pc,d1.w),a5
[00011fd2] 4ed4                      jmp       (a4)
[00011fd4] 3018                      move.w    (a0)+,d0
[00011fd6] 8151                      or.w      d0,(a1)
[00011fd8] 4659                      not.w     (a1)+
[00011fda] 3c04                      move.w    d4,d6
[00011fdc] 4ed5                      jmp       (a5)
[00011fde] 2018                      move.l    (a0)+,d0
[00011fe0] 8191                      or.l      d0,(a1)
[00011fe2] 4699                      not.l     (a1)+
[00011fe4] 2018                      move.l    (a0)+,d0
[00011fe6] 8191                      or.l      d0,(a1)
[00011fe8] 4699                      not.l     (a1)+
[00011fea] 2018                      move.l    (a0)+,d0
[00011fec] 8191                      or.l      d0,(a1)
[00011fee] 4699                      not.l     (a1)+
[00011ff0] 2018                      move.l    (a0)+,d0
[00011ff2] 8191                      or.l      d0,(a1)
[00011ff4] 4699                      not.l     (a1)+
[00011ff6] 51ce ffe6                 dbf       d6,$00011FDE
[00011ffa] d0ca                      adda.w    a2,a0
[00011ffc] d2cb                      adda.w    a3,a1
[00011ffe] 51cd ffd2                 dbf       d5,$00011FD2
[00012002] 4e75                      rts
[00012004] 49fb 0008                 lea.l     $0001200E(pc,d0.w),a4
[00012008] 4bfb 100e                 lea.l     $00012018(pc,d1.w),a5
[0001200c] 4ed4                      jmp       (a4)
[0001200e] 3018                      move.w    (a0)+,d0
[00012010] b151                      eor.w     d0,(a1)
[00012012] 4659                      not.w     (a1)+
[00012014] 3c04                      move.w    d4,d6
[00012016] 4ed5                      jmp       (a5)
[00012018] 2018                      move.l    (a0)+,d0
[0001201a] b191                      eor.l     d0,(a1)
[0001201c] 4699                      not.l     (a1)+
[0001201e] 2018                      move.l    (a0)+,d0
[00012020] b191                      eor.l     d0,(a1)
[00012022] 4699                      not.l     (a1)+
[00012024] 2018                      move.l    (a0)+,d0
[00012026] b191                      eor.l     d0,(a1)
[00012028] 4699                      not.l     (a1)+
[0001202a] 2018                      move.l    (a0)+,d0
[0001202c] b191                      eor.l     d0,(a1)
[0001202e] 4699                      not.l     (a1)+
[00012030] 51ce ffe6                 dbf       d6,$00012018
[00012034] d0ca                      adda.w    a2,a0
[00012036] d2cb                      adda.w    a3,a1
[00012038] 51cd ffd2                 dbf       d5,$0001200C
[0001203c] 4e75                      rts
[0001203e] 49fb 0008                 lea.l     $00012048(pc,d0.w),a4
[00012042] 4bfb 100a                 lea.l     $0001204E(pc,d1.w),a5
[00012046] 4ed4                      jmp       (a4)
[00012048] 4659                      not.w     (a1)+
[0001204a] 3c04                      move.w    d4,d6
[0001204c] 4ed5                      jmp       (a5)
[0001204e] 4699                      not.l     (a1)+
[00012050] 4699                      not.l     (a1)+
[00012052] 4699                      not.l     (a1)+
[00012054] 4699                      not.l     (a1)+
[00012056] 51ce fff6                 dbf       d6,$0001204E
[0001205a] d2cb                      adda.w    a3,a1
[0001205c] 51cd ffe8                 dbf       d5,$00012046
[00012060] 4e75                      rts
[00012062] 49fb 0008                 lea.l     $0001206C(pc,d0.w),a4
[00012066] 4bfb 100e                 lea.l     $00012076(pc,d1.w),a5
[0001206a] 4ed4                      jmp       (a4)
[0001206c] 4651                      not.w     (a1)
[0001206e] 3018                      move.w    (a0)+,d0
[00012070] 8159                      or.w      d0,(a1)+
[00012072] 3c04                      move.w    d4,d6
[00012074] 4ed5                      jmp       (a5)
[00012076] 4691                      not.l     (a1)
[00012078] 2018                      move.l    (a0)+,d0
[0001207a] 8199                      or.l      d0,(a1)+
[0001207c] 4691                      not.l     (a1)
[0001207e] 2018                      move.l    (a0)+,d0
[00012080] 8199                      or.l      d0,(a1)+
[00012082] 4691                      not.l     (a1)
[00012084] 2018                      move.l    (a0)+,d0
[00012086] 8199                      or.l      d0,(a1)+
[00012088] 4691                      not.l     (a1)
[0001208a] 2018                      move.l    (a0)+,d0
[0001208c] 8199                      or.l      d0,(a1)+
[0001208e] 51ce ffe6                 dbf       d6,$00012076
[00012092] d0ca                      adda.w    a2,a0
[00012094] d2cb                      adda.w    a3,a1
[00012096] 51cd ffd2                 dbf       d5,$0001206A
[0001209a] 4e75                      rts
[0001209c] 49fb 0008                 lea.l     $000120A6(pc,d0.w),a4
[000120a0] 4bfb 100e                 lea.l     $000120B0(pc,d1.w),a5
[000120a4] 4ed4                      jmp       (a4)
[000120a6] 3018                      move.w    (a0)+,d0
[000120a8] 4640                      not.w     d0
[000120aa] 32c0                      move.w    d0,(a1)+
[000120ac] 3c04                      move.w    d4,d6
[000120ae] 4ed5                      jmp       (a5)
[000120b0] 2018                      move.l    (a0)+,d0
[000120b2] 4680                      not.l     d0
[000120b4] 22c0                      move.l    d0,(a1)+
[000120b6] 2018                      move.l    (a0)+,d0
[000120b8] 4680                      not.l     d0
[000120ba] 22c0                      move.l    d0,(a1)+
[000120bc] 2018                      move.l    (a0)+,d0
[000120be] 4680                      not.l     d0
[000120c0] 22c0                      move.l    d0,(a1)+
[000120c2] 2018                      move.l    (a0)+,d0
[000120c4] 4680                      not.l     d0
[000120c6] 22c0                      move.l    d0,(a1)+
[000120c8] 51ce ffe6                 dbf       d6,$000120B0
[000120cc] d0ca                      adda.w    a2,a0
[000120ce] d2cb                      adda.w    a3,a1
[000120d0] 51cd ffd2                 dbf       d5,$000120A4
[000120d4] 4e75                      rts
[000120d6] 49fb 0008                 lea.l     $000120E0(pc,d0.w),a4
[000120da] 4bfb 100e                 lea.l     $000120EA(pc,d1.w),a5
[000120de] 4ed4                      jmp       (a4)
[000120e0] 3018                      move.w    (a0)+,d0
[000120e2] 4640                      not.w     d0
[000120e4] 8159                      or.w      d0,(a1)+
[000120e6] 3c04                      move.w    d4,d6
[000120e8] 4ed5                      jmp       (a5)
[000120ea] 2018                      move.l    (a0)+,d0
[000120ec] 4680                      not.l     d0
[000120ee] 8199                      or.l      d0,(a1)+
[000120f0] 2018                      move.l    (a0)+,d0
[000120f2] 4680                      not.l     d0
[000120f4] 8199                      or.l      d0,(a1)+
[000120f6] 2018                      move.l    (a0)+,d0
[000120f8] 4680                      not.l     d0
[000120fa] 8199                      or.l      d0,(a1)+
[000120fc] 2018                      move.l    (a0)+,d0
[000120fe] 4680                      not.l     d0
[00012100] 8199                      or.l      d0,(a1)+
[00012102] 51ce ffe6                 dbf       d6,$000120EA
[00012106] d0ca                      adda.w    a2,a0
[00012108] d2cb                      adda.w    a3,a1
[0001210a] 51cd ffd2                 dbf       d5,$000120DE
[0001210e] 4e75                      rts
[00012110] 49fb 0008                 lea.l     $0001211A(pc,d0.w),a4
[00012114] 4bfb 100e                 lea.l     $00012124(pc,d1.w),a5
[00012118] 4ed4                      jmp       (a4)
[0001211a] 3018                      move.w    (a0)+,d0
[0001211c] c151                      and.w     d0,(a1)
[0001211e] 4659                      not.w     (a1)+
[00012120] 3c04                      move.w    d4,d6
[00012122] 4ed5                      jmp       (a5)
[00012124] 2018                      move.l    (a0)+,d0
[00012126] c191                      and.l     d0,(a1)
[00012128] 4699                      not.l     (a1)+
[0001212a] 2018                      move.l    (a0)+,d0
[0001212c] c191                      and.l     d0,(a1)
[0001212e] 4699                      not.l     (a1)+
[00012130] 2018                      move.l    (a0)+,d0
[00012132] c191                      and.l     d0,(a1)
[00012134] 4699                      not.l     (a1)+
[00012136] 2018                      move.l    (a0)+,d0
[00012138] c191                      and.l     d0,(a1)
[0001213a] 4699                      not.l     (a1)+
[0001213c] 51ce ffe6                 dbf       d6,$00012124
[00012140] d0ca                      adda.w    a2,a0
[00012142] d2cb                      adda.w    a3,a1
[00012144] 51cd ffd2                 dbf       d5,$00012118
[00012148] 4e75                      rts
[0001214a] 3600                      move.w    d0,d3
[0001214c] 4843                      swap      d3
[0001214e] 3600                      move.w    d0,d3
[00012150] 4a6e 01b2                 tst.w     434(a6)
[00012154] 670a                      beq.s     $00012160
[00012156] 266e 01ae                 movea.l   430(a6),a3
[0001215a] c3ee 01b2                 muls.w    434(a6),d1
[0001215e] 6008                      bra.s     $00012168
[00012160] 2678 044e                 movea.l   ($0000044E).w,a3
[00012164] c3f8 206e                 muls.w    ($0000206E).w,d1
[00012168] d7c1                      adda.l    d1,a3
[0001216a] d6c0                      adda.w    d0,a3
[0001216c] d6c0                      adda.w    d0,a3
[0001216e] 284b                      movea.l   a3,a4
[00012170] 3813                      move.w    (a3),d4
[00012172] b642                      cmp.w     d2,d3
[00012174] 6e0e                      bgt.s     $00012184
[00012176] 548b                      addq.l    #2,a3
[00012178] b85b                      cmp.w     (a3)+,d4
[0001217a] 6608                      bne.s     $00012184
[0001217c] 5243                      addq.w    #1,d3
[0001217e] b642                      cmp.w     d2,d3
[00012180] 6df6                      blt.s     $00012178
[00012182] 3602                      move.w    d2,d3
[00012184] 3283                      move.w    d3,(a1)
[00012186] 4842                      swap      d2
[00012188] 4843                      swap      d3
[0001218a] 264c                      movea.l   a4,a3
[0001218c] b642                      cmp.w     d2,d3
[0001218e] 6f0e                      ble.s     $0001219E
[00012190] 3003                      move.w    d3,d0
[00012192] b863                      cmp.w     -(a3),d4
[00012194] 6608                      bne.s     $0001219E
[00012196] 5343                      subq.w    #1,d3
[00012198] b642                      cmp.w     d2,d3
[0001219a] 6ef6                      bgt.s     $00012192
[0001219c] 3602                      move.w    d2,d3
[0001219e] 3083                      move.w    d3,(a0)
[000121a0] 3015                      move.w    (a5),d0
[000121a2] b86d 0004                 cmp.w     4(a5),d4
[000121a6] 6704                      beq.s     $000121AC
[000121a8] 0a40 0001                 eori.w    #$0001,d0
[000121ac] 4e75                      rts

data:
[000121ae]                           dc.w $099c
[000121b0]                           dc.w $0024
[000121b2]                           dc.w $0012
[000121b4]                           dc.w $005a
[000121b6]                           dc.w $00a6
[000121b8]                           dc.w $0208
[000121ba]                           dc.w $022e
[000121bc]                           dc.w $01b8
[000121be]                           dc.w $15c4
[000121c0]                           dc.w $0000
; TPA Relocations:
; $00000010
; $00000014
; $00000018
; $0000001c
; $00000020
; $00000024
; $00000028
; $0000002c
; $00000058
; $00000156
; $00000254
; $00000352
; $00000450
; $000004b2
; $00000554
; $0000055c
; $00000564
; $0000056c
; $00000574
; $0000057c
; $00000584
; $0000058c
; $00000594
; $0000059c
; $000005a4
; $000005ac
; $000005b4
; $000005bc
; $000005c4
; $000005cc
; $000005d4
; $000006d2
; $00000732
; $00000736
; $0000073a
; $0000073e
; $0000083c
; $0000093a
; $00000a38
; $00000b36
; $00000c34
; $00000d32
; $00000e30
; $00000f2e
; $0000102c
; $0000112a
; $00001228
; $00001230
; $00001234
; $00001238
; $0000123c
; $00001240
; $00001244
; $00001248
; $0000124c
; $00001250
; $00001254
; $00001258
; $0000125c
; $00001260
; $00001264
; $00001268
; $0000126c
; $00001270
; $00001274
; $00001278
; $0000127c
; $00001280
; $00001284
; $00001288
; $0000128c
; $00001290
; $00001294
; $00001298
; $0000129c
; $000012a0
; $000012a4
; $000012a8
; $000012ac
; $000013aa
; $000014a8
; $000014b6
; $000014ba
; $000014be
; $000014c2
; $000014c6
; $000014ca
; $000014ce
; $000014d2
; $000014d6
; $000014da
; $000014de
; $000014e2
; $000014e6
; $000014ea
; $000014ee
; $000014f2
; $000014f6
; $000014fa
; $000014fe
; $00001502
; $00001506
; $0000150a
; $0000150e
; $00001512
; $00001516
; $0000151a
; $0000151e
; $00001522
; $00001526
; $0000152a
; $0000152e
; $00001532
