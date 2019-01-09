; ph_branch = 0x601a
; ph_tlen = 0x0000228e
; ph_dlen = 0x00000014
; ph_blen = 0x000032c4
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x0000002c

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0413                 cmpiw.l   #$0413,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 0088                 ori.b     #$88,d1
[00010018] 0001 08b0                 ori.b     #$B0,d1
[0001001c] 0001 0988                 ori.b     #$88,d1
[00010020] 0001 008a                 ori.b     #$8A,d1
[00010024] 0001 00ca                 ori.b     #$CA,d1
[00010028] 0001 0118                 ori.b     #$18,d1
[0001002c] 0001 0772                 ori.b     #$72,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0100                      btst      d0,d0
[00010042] 0000 0020                 ori.b     #$20,d0
[00010046] 0002 0081                 ori.b     #$81,d2
[0001004a] 0000 0000                 ori.b     #$00,d0
[0001004e] 0000 4e75                 ori.b     #$75,d0
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 22a4            move.l    a0,$000122A4
[0001005c] 6100 06f0                 bsr       $0001074E
[00010060] 207a 2242                 movea.l   $000122A4(pc),a0
[00010064] 4279 0001 22a2            clr.w     $000122A2
[0001006a] 6100 0728                 bsr       $00010794
[0001006e] 6100 0704                 bsr       $00010774
[00010072] 7008                      moveq.l   #8,d0
[00010074] 7208                      moveq.l   #8,d1
[00010076] 7408                      moveq.l   #8,d2
[00010078] 6100 0744                 bsr       $000107BE
[0001007c] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010080] 203c 0000 0a58            move.l    #$00000A58,d0
[00010086] 4e75                      rts
[00010088] 4e75                      rts
[0001008a] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[0001008e] 20ee 0010                 move.l    16(a6),(a0)+
[00010092] 4258                      clr.w     (a0)+
[00010094] 20ee 000c                 move.l    12(a6),(a0)+
[00010098] 7027                      moveq.l   #39,d0
[0001009a] 247a 2208                 movea.l   $000122A4(pc),a2
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
[000100d0] 247a 21d2                 movea.l   $000122A4(pc),a2
[000100d4] 246a 0030                 movea.l   48(a2),a2
[000100d8] 30da                      move.w    (a2)+,(a0)+
[000100da] 51c8 fffc                 dbf       d0,$000100D8
[000100de] 4268 ffa6                 clr.w     -90(a0)
[000100e2] 4268 ffa8                 clr.w     -88(a0)
[000100e6] 317c 0020 ffae            move.w    #$0020,-82(a0)
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
[0001011c] 43fa 0050                 lea.l     $0001016E(pc),a1
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
[00010148] 43fa 0044                 lea.l     $0001018E(pc),a1
[0001014c] 082e 0007 01a3            btst      #7,419(a6)
[00010152] 6704                      beq.s     $00010158
[00010154] 43fa 0118                 lea.l     $0001026E(pc),a1
[00010158] 30d9                      move.w    (a1)+,(a0)+
[0001015a] 51c8 fffc                 dbf       d0,$00010158
[0001015e] 303c 008f                 move.w    #$008F,d0
[00010162] 4258                      clr.w     (a0)+
[00010164] 51c8 fffc                 dbf       d0,$00010162
[00010168] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[0001016c] 4e75                      rts
[0001016e] 0002 0002                 ori.b     #$02,d2
[00010172] 0020 0100                 ori.b     #$00,-(a0)
[00010176] 0000 0000                 ori.b     #$00,d0
[0001017a] 0000 0000                 ori.b     #$00,d0
[0001017e] 0008 0008                 ori.b     #$08,a0 ; apollo only
[00010182] 0008 0008                 ori.b     #$08,a0 ; apollo only
[00010186] 0000 0000                 ori.b     #$00,d0
[0001018a] 0001 0000                 ori.b     #$00,d1
[0001018e] 0010 0011                 ori.b     #$11,(a0)
[00010192] 0012 0013                 ori.b     #$13,(a2)
[00010196] 0014 0015                 ori.b     #$15,(a4)
[0001019a] 0016 0017                 ori.b     #$17,(a6)
[0001019e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101a6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101ae] 0008 0009                 ori.b     #$09,a0 ; apollo only
[000101b2] 000a 000b                 ori.b     #$0B,a2 ; apollo only
[000101b6] 000c 000d                 ori.b     #$0D,a4 ; apollo only
[000101ba] 000e 000f                 ori.b     #$0F,a6 ; apollo only
[000101be] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101c6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101ce] 0000 0001                 ori.b     #$01,d0
[000101d2] 0002 0003                 ori.b     #$03,d2
[000101d6] 0004 0005                 ori.b     #$05,d4
[000101da] 0006 0007                 ori.b     #$07,d6
[000101de] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101e6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101ee] 0018 0019                 ori.b     #$19,(a0)+
[000101f2] 001a 001b                 ori.b     #$1B,(a2)+
[000101f6] 001c 001d                 ori.b     #$1D,(a4)+
[000101fa] 001e 001f                 ori.b     #$1F,(a6)+
[000101fe] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010206] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001020e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010216] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001021e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010226] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001022e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010236] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001023e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010246] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001024e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010256] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001025e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010266] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001026e] 0008 0009                 ori.b     #$09,a0 ; apollo only
[00010272] 000a 000b                 ori.b     #$0B,a2 ; apollo only
[00010276] 000c 000d                 ori.b     #$0D,a4 ; apollo only
[0001027a] 000e 000f                 ori.b     #$0F,a6 ; apollo only
[0001027e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010286] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001028e] 0010 0011                 ori.b     #$11,(a0)
[00010292] 0012 0013                 ori.b     #$13,(a2)
[00010296] 0014 0015                 ori.b     #$15,(a4)
[0001029a] 0016 0017                 ori.b     #$17,(a6)
[0001029e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102a6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ae] 0018 0019                 ori.b     #$19,(a0)+
[000102b2] 001a 001b                 ori.b     #$1B,(a2)+
[000102b6] 001c 001d                 ori.b     #$1D,(a4)+
[000102ba] 001e 001f                 ori.b     #$1F,(a6)+
[000102be] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102c6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ce] 0000 0001                 ori.b     #$01,d0
[000102d2] 0002 0003                 ori.b     #$03,d2
[000102d6] 0004 0005                 ori.b     #$05,d4
[000102da] 0006 0007                 ori.b     #$07,d6
[000102de] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102e6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ee] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102f6] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102fe] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010306] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001030e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010316] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001031e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010326] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001032e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010336] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001033e] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010346] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001034e] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00010352] 00f2 0000 0000            cmp2.b    0(a2,d0.w),d0 ; 68020+ only
[00010358] e600                      asr.b     #3,d0
[0001035a] 00ff ff00                 chk2.b    ???,a7 ; 68020+ only
[0001035e] 0000 00f2                 ori.b     #$F2,d0
[00010362] 00e6                      dc.w      $00E6 ; illegal
[00010364] 3399 001a                 move.w    (a1)+,26(a1,d0.w)
[00010368] cbbb 00d9                 and.l     d5,$00010343(pc,d0.w) ; apollo only
[0001036c] d9d9                      adda.l    (a1)+,a4
[0001036e] 0080 8080 0080            ori.l     #$80800080,d0
[00010374] 0000 0000                 ori.b     #$00,d0
[00010378] 8000                      or.b      d0,d0
[0001037a] 00b6 a239 0000 0080       ori.l     #$A2390000,-128(a6,d0.w)
[00010382] 0080 0080 0000            ori.l     #$00800000,d0
[00010388] 8080                      or.l      d0,d0
[0001038a] 001a 1a1a                 ori.b     #$1A,(a2)+
[0001038e] 0000 0033                 ori.b     #$33,d0
[00010392] 0000 0066                 ori.b     #$66,d0
[00010396] 0000 0099                 ori.b     #$99,d0
[0001039a] 0000 00cc                 ori.b     #$CC,d0
[0001039e] 0000 00ff                 ori.b     #$FF,d0
[000103a2] 0000 3300                 ori.b     #$00,d0
[000103a6] 0000 3333                 ori.b     #$33,d0
[000103aa] 0000 3366                 ori.b     #$66,d0
[000103ae] 0000 3399                 ori.b     #$99,d0
[000103b2] 0000 33cc                 ori.b     #$CC,d0
[000103b6] 0000 33ff                 ori.b     #$FF,d0
[000103ba] 0000 6600                 ori.b     #$00,d0
[000103be] 0000 6633                 ori.b     #$33,d0
[000103c2] 0000 6666                 ori.b     #$66,d0
[000103c6] 0000 6699                 ori.b     #$99,d0
[000103ca] 0000 66cc                 ori.b     #$CC,d0
[000103ce] 0000 66ff                 ori.b     #$FF,d0
[000103d2] 0000 9900                 ori.b     #$00,d0
[000103d6] 0000 9933                 ori.b     #$33,d0
[000103da] 0000 9966                 ori.b     #$66,d0
[000103de] 0000 9999                 ori.b     #$99,d0
[000103e2] 0000 99cc                 ori.b     #$CC,d0
[000103e6] 0000 99ff                 ori.b     #$FF,d0
[000103ea] 0000 cc00                 ori.b     #$00,d0
[000103ee] 0000 cc33                 ori.b     #$33,d0
[000103f2] 0000 cc66                 ori.b     #$66,d0
[000103f6] 0000 cc99                 ori.b     #$99,d0
[000103fa] 0000 cccc                 ori.b     #$CC,d0
[000103fe] 0000 ccff                 ori.b     #$FF,d0
[00010402] 0000 ff00                 ori.b     #$00,d0
[00010406] 0000 ff33                 ori.b     #$33,d0
[0001040a] 0000 ff66                 ori.b     #$66,d0
[0001040e] 0000 ff99                 ori.b     #$99,d0
[00010412] 0000 ffcc                 ori.b     #$CC,d0
[00010416] 0000 ffff                 ori.b     #$FF,d0
[0001041a] 0033 0000 0033            ori.b     #$00,51(a3,d0.w)
[00010420] 0033 0033 0066            ori.b     #$33,102(a3,d0.w)
[00010426] 0033 0099 0033            ori.b     #$99,51(a3,d0.w)
[0001042c] 00cc                      dc.w      $00CC ; illegal
[0001042e] 0033 00ff 0033            ori.b     #$FF,51(a3,d0.w)
[00010434] 3300                      move.w    d0,-(a1)
[00010436] 0033 3333 0033            ori.b     #$33,51(a3,d0.w)
[0001043c] 3366 0000                 move.w    -(a6),0(a1)
[00010440] 00c0                      bitrev.l  d0 ; ColdFire isa_c only
[00010442] 0033 33cc 0033            ori.b     #$CC,51(a3,d0.w)
[00010448] 33ff 0033 6600            move.w    ???,$00336600
[0001044e] 0033 6633 0033            ori.b     #$33,51(a3,d0.w)
[00010454] 6666                      bne.s     $000104BC
[00010456] 0033 6699 0033            ori.b     #$99,51(a3,d0.w)
[0001045c] 66cc                      bne.s     $0001042A
[0001045e] 0033 66ff 0033            ori.b     #$FF,51(a3,d0.w)
[00010464] 9900                      subx.b    d0,d4
[00010466] 0033 9933 0033            ori.b     #$33,51(a3,d0.w)
[0001046c] 9966                      sub.w     d4,-(a6)
[0001046e] 0033 9999 0033            ori.b     #$99,51(a3,d0.w)
[00010474] 99cc                      suba.l    a4,a4
[00010476] 0033 99ff 0033            ori.b     #$FF,51(a3,d0.w)
[0001047c] cc00                      and.b     d0,d6
[0001047e] 0033 cc33 0033            ori.b     #$33,51(a3,d0.w)
[00010484] cc66                      and.w     -(a6),d6
[00010486] 0033 cc99 0033            ori.b     #$99,51(a3,d0.w)
[0001048c] cccc                      mulu.w    a4,d6
[0001048e] 0033 ccff 0033            ori.b     #$FF,51(a3,d0.w)
[00010494] ff00 0033                 pminuw.q  e8,d0,d0
[00010498] ff33 0033 ff66            pminuw.q  ,d0,d0 ; illegal
[0001049e] 0033 ff99 0033            ori.b     #$99,51(a3,d0.w)
[000104a4] ffcc 0033                 pminuw.q  e20,e8,e8
[000104a8] ffff 0066 0000 0066       vperm     #$00000066,e14,e8,e8
[000104b0] 0033 0066 0066            ori.b     #$66,102(a3,d0.w)
[000104b6] 0066 0099                 ori.w     #$0099,-(a6)
[000104ba] 0066 00cc                 ori.w     #$00CC,-(a6)
[000104be] 0066 00ff                 ori.w     #$00FF,-(a6)
[000104c2] 0066 3300                 ori.w     #$3300,-(a6)
[000104c6] 0066 3333                 ori.w     #$3333,-(a6)
[000104ca] 0066 3366                 ori.w     #$3366,-(a6)
[000104ce] 0066 3399                 ori.w     #$3399,-(a6)
[000104d2] 0066 33cc                 ori.w     #$33CC,-(a6)
[000104d6] 0066 33ff                 ori.w     #$33FF,-(a6)
[000104da] 0066 6600                 ori.w     #$6600,-(a6)
[000104de] 0066 6633                 ori.w     #$6633,-(a6)
[000104e2] 0066 6666                 ori.w     #$6666,-(a6)
[000104e6] 0066 6699                 ori.w     #$6699,-(a6)
[000104ea] 0066 66cc                 ori.w     #$66CC,-(a6)
[000104ee] 0066 66ff                 ori.w     #$66FF,-(a6)
[000104f2] 0066 9900                 ori.w     #$9900,-(a6)
[000104f6] 0066 9933                 ori.w     #$9933,-(a6)
[000104fa] 0066 9966                 ori.w     #$9966,-(a6)
[000104fe] 0066 9999                 ori.w     #$9999,-(a6)
[00010502] 0066 99cc                 ori.w     #$99CC,-(a6)
[00010506] 0066 99ff                 ori.w     #$99FF,-(a6)
[0001050a] 0066 cc00                 ori.w     #$CC00,-(a6)
[0001050e] 0066 cc33                 ori.w     #$CC33,-(a6)
[00010512] 0066 cc66                 ori.w     #$CC66,-(a6)
[00010516] 0066 cc99                 ori.w     #$CC99,-(a6)
[0001051a] 0066 cccc                 ori.w     #$CCCC,-(a6)
[0001051e] 0066 ccff                 ori.w     #$CCFF,-(a6)
[00010522] 0066 ff00                 ori.w     #$FF00,-(a6)
[00010526] 0066 ff33                 ori.w     #$FF33,-(a6)
[0001052a] 0066 ff66                 ori.w     #$FF66,-(a6)
[0001052e] 0066 ff99                 ori.w     #$FF99,-(a6)
[00010532] 0066 ffcc                 ori.w     #$FFCC,-(a6)
[00010536] 0066 ffff                 ori.w     #$FFFF,-(a6)
[0001053a] 0099 0000 0099            ori.l     #$00000099,(a1)+
[00010540] 0033 0099 0066            ori.b     #$99,102(a3,d0.w)
[00010546] 0099 0099 0099            ori.l     #$00990099,(a1)+
[0001054c] 00cc                      dc.w      $00CC ; illegal
[0001054e] 0099 00ff 0099            ori.l     #$00FF0099,(a1)+
[00010554] 3300                      move.w    d0,-(a1)
[00010556] 0099 3333 0099            ori.l     #$33330099,(a1)+
[0001055c] 3366 0099                 move.w    -(a6),153(a1)
[00010560] 3399 0099                 move.w    (a1)+,-103(a1,d0.w)
[00010564] 33cc 0099 33ff            move.w    a4,$009933FF
[0001056a] 0099 6600 0099            ori.l     #$66000099,(a1)+
[00010570] 6633                      bne.s     $000105A5
[00010572] 0099 6666 0099            ori.l     #$66660099,(a1)+
[00010578] 6699                      bne.s     $00010513
[0001057a] 0099 66cc 0099            ori.l     #$66CC0099,(a1)+
[00010580] 66ff 0099 9900            bne.l     $009A9E82 ; 68020+ only
[00010586] 0099 9933 0099            ori.l     #$99330099,(a1)+
[0001058c] 9966                      sub.w     d4,-(a6)
[0001058e] 0099 9999 0099            ori.l     #$99990099,(a1)+
[00010594] 99cc                      suba.l    a4,a4
[00010596] 0099 99ff 0099            ori.l     #$99FF0099,(a1)+
[0001059c] cc00                      and.b     d0,d6
[0001059e] 0099 cc33 0099            ori.l     #$CC330099,(a1)+
[000105a4] cc66                      and.w     -(a6),d6
[000105a6] 0099 cc99 0099            ori.l     #$CC990099,(a1)+
[000105ac] cccc                      mulu.w    a4,d6
[000105ae] 0099 ccff 0099            ori.l     #$CCFF0099,(a1)+
[000105b4] ff00                      dc.w      $FF00 ; illegal
[000105b6] 0099 ff33 0099            ori.l     #$FF330099,(a1)+
[000105bc] ff66                      dc.w      $FF66 ; illegal
[000105be] 0099 ff99 0099            ori.l     #$FF990099,(a1)+
[000105c4] ffcc                      dc.w      $FFCC ; illegal
[000105c6] 0099 ffff 00cc            ori.l     #$FFFF00CC,(a1)+
[000105cc] 0000 00cc                 ori.b     #$CC,d0
[000105d0] 0033 00cc 0066            ori.b     #$CC,102(a3,d0.w)
[000105d6] 00cc                      dc.w      $00CC ; illegal
[000105d8] 0099 00cc 00cc            ori.l     #$00CC00CC,(a1)+
[000105de] 00cc                      dc.w      $00CC ; illegal
[000105e0] 00ff 00cc                 cmp2.b    ???,d0 ; 68020+ only
[000105e4] 3300                      move.w    d0,-(a1)
[000105e6] 00cc                      dc.w      $00CC ; illegal
[000105e8] 3333 00cc                 move.w    -52(a3,d0.w),-(a1)
[000105ec] 3366 00cc                 move.w    -(a6),204(a1)
[000105f0] 3399 00cc                 move.w    (a1)+,-52(a1,d0.w)
[000105f4] 33cc 00cc 33ff            move.w    a4,$00CC33FF
[000105fa] 00cc                      dc.w      $00CC ; illegal
[000105fc] 6600 00cc                 bne       $000106CA
[00010600] 6633                      bne.s     $00010635
[00010602] 00cc                      dc.w      $00CC ; illegal
[00010604] 6666                      bne.s     $0001066C
[00010606] 00cc                      dc.w      $00CC ; illegal
[00010608] 6699                      bne.s     $000105A3
[0001060a] 00cc                      dc.w      $00CC ; illegal
[0001060c] 66cc                      bne.s     $000105DA
[0001060e] 00cc                      dc.w      $00CC ; illegal
[00010610] 66ff 00cc 9900            bne.l     $00CD9F12 ; 68020+ only
[00010616] 00cc                      dc.w      $00CC ; illegal
[00010618] 9933 00cc                 sub.b     d4,-52(a3,d0.w)
[0001061c] 9966                      sub.w     d4,-(a6)
[0001061e] 00cc                      dc.w      $00CC ; illegal
[00010620] 9999                      sub.l     d4,(a1)+
[00010622] 00cc                      dc.w      $00CC ; illegal
[00010624] 99cc                      suba.l    a4,a4
[00010626] 00cc                      dc.w      $00CC ; illegal
[00010628] 99ff                      suba.l    ???,a4
[0001062a] 00cc                      dc.w      $00CC ; illegal
[0001062c] cc00                      and.b     d0,d6
[0001062e] 00cc                      dc.w      $00CC ; illegal
[00010630] cc33 00cc                 and.b     -52(a3,d0.w),d6
[00010634] cc66                      and.w     -(a6),d6
[00010636] 00cc                      dc.w      $00CC ; illegal
[00010638] cc99                      and.l     (a1)+,d6
[0001063a] 00cc                      dc.w      $00CC ; illegal
[0001063c] cccc                      mulu.w    a4,d6
[0001063e] 00cc                      dc.w      $00CC ; illegal
[00010640] ccff                      mulu.w    ???,d6
[00010642] 00cc                      dc.w      $00CC ; illegal
[00010644] ff00                      dc.w      $FF00 ; illegal
[00010646] 00cc                      dc.w      $00CC ; illegal
[00010648] ff33                      dc.w      $FF33 ; illegal
[0001064a] 00cc                      dc.w      $00CC ; illegal
[0001064c] ff66                      dc.w      $FF66 ; illegal
[0001064e] 00cc                      dc.w      $00CC ; illegal
[00010650] ff99                      dc.w      $FF99 ; illegal
[00010652] 00cc                      dc.w      $00CC ; illegal
[00010654] ffcc                      dc.w      $FFCC ; illegal
[00010656] 00cc                      dc.w      $00CC ; illegal
[00010658] ffff 00ff 0000 00ff       vperm     #$000000FF,e23,e8,e8
[00010660] 0033 00ff 0066            ori.b     #$FF,102(a3,d0.w)
[00010666] 00ff 0099                 cmp2.b    ???,d0 ; 68020+ only
[0001066a] 00ff 00cc                 cmp2.b    ???,d0 ; 68020+ only
[0001066e] 00ff 00ff                 cmp2.b    ???,d0 ; 68020+ only
[00010672] 00ff 3300                 cmp2.b    ???,d3 ; 68020+ only
[00010676] 00ff 3333                 cmp2.b    ???,d3 ; 68020+ only
[0001067a] 00ff 3366                 cmp2.b    ???,d3 ; 68020+ only
[0001067e] 00ff 3399                 cmp2.b    ???,d3 ; 68020+ only
[00010682] 00ff 33cc                 cmp2.b    ???,d3 ; 68020+ only
[00010686] 00ff 33ff                 cmp2.b    ???,d3 ; 68020+ only
[0001068a] 00ff 6600                 cmp2.b    ???,d6 ; 68020+ only
[0001068e] 00ff 6633                 cmp2.b    ???,d6 ; 68020+ only
[00010692] 00ff 6666                 cmp2.b    ???,d6 ; 68020+ only
[00010696] 00ff 6699                 cmp2.b    ???,d6 ; 68020+ only
[0001069a] 00ff 66cc                 cmp2.b    ???,d6 ; 68020+ only
[0001069e] 00ff 66ff                 cmp2.b    ???,d6 ; 68020+ only
[000106a2] 00ff 9900                 chk2.b    ???,a1 ; 68020+ only
[000106a6] 00ff 9933                 chk2.b    ???,a1 ; 68020+ only
[000106aa] 00ff 9966                 chk2.b    ???,a1 ; 68020+ only
[000106ae] 00ff 9999                 chk2.b    ???,a1 ; 68020+ only
[000106b2] 00ff 99cc                 chk2.b    ???,a1 ; 68020+ only
[000106b6] 00ff 99ff                 chk2.b    ???,a1 ; 68020+ only
[000106ba] 00ff cc00                 chk2.b    ???,a4 ; 68020+ only
[000106be] 00ff cc33                 chk2.b    ???,a4 ; 68020+ only
[000106c2] 00ff cc66                 chk2.b    ???,a4 ; 68020+ only
[000106c6] 00ff cc99                 chk2.b    ???,a4 ; 68020+ only
[000106ca] 00ff cccc                 chk2.b    ???,a4 ; 68020+ only
[000106ce] 00ff ccff                 chk2.b    ???,a4 ; 68020+ only
[000106d2] 00ff ff00                 chk2.b    ???,a7 ; 68020+ only
[000106d6] 00ff ff33                 chk2.b    ???,a7 ; 68020+ only
[000106da] 00ff ff66                 chk2.b    ???,a7 ; 68020+ only
[000106de] 00ff ff99                 chk2.b    ???,a7 ; 68020+ only
[000106e2] 00ff ffcc                 chk2.b    ???,a7 ; 68020+ only
[000106e6] 00f2 0000 00e6            cmp2.b    -26(a2,d0.w),d0 ; 68020+ only
[000106ec] 0000 00c0                 ori.b     #$C0,d0
[000106f0] 0000 00b3                 ori.b     #$B3,d0
[000106f4] 0000 0080                 ori.b     #$80,d0
[000106f8] 0000 004d                 ori.b     #$4D,d0
[000106fc] 0000 001a                 ori.b     #$1A,d0
[00010700] 0000 0000                 ori.b     #$00,d0
[00010704] f200 0000                 fmove.x   fp0,fp0
[00010708] e600                      asr.b     #3,d0
[0001070a] 0000 c000                 ori.b     #$00,d0
[0001070e] 0000 b300                 ori.b     #$00,d0
[00010712] 0000 8000                 ori.b     #$00,d0
[00010716] 0000 4d00                 ori.b     #$00,d0
[0001071a] 0000 1a00                 ori.b     #$00,d0
[0001071e] 0000 001a                 ori.b     #$1A,d0
[00010722] 0000 004d                 ori.b     #$4D,d0
[00010726] 0000 0080                 ori.b     #$80,d0
[0001072a] 0000 00b3                 ori.b     #$B3,d0
[0001072e] 0033 3399 0000            ori.b     #$99,0(a3,d0.w)
[00010734] 00e6                      dc.w      $00E6 ; illegal
[00010736] 00f2 f2f2 00e6            cmp2.b    -26(a2,d0.w),a7 ; 68020+ only
[0001073c] e6e6                      ror.w     -(a6)
[0001073e] 00c0                      bitrev.l  d0 ; ColdFire isa_c only
[00010740] c0c0                      mulu.w    d0,d0
[00010742] 00b3 b3b3 004d 4d4d       ori.l     #$B3B3004D,([a3],zd4.l*4) ; 68020+ only; reserved BD=0; reserved OD=1
[0001074a] 0000 0000                 ori.b     #$00,d0
[0001074e] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010752] a000                      ALINE     #$0000
[00010754] 907c 2070                 sub.w     #$2070,d0
[00010758] 6712                      beq.s     $0001076C
[0001075a] 41fa f8a4                 lea.l     $00010000(pc),a0
[0001075e] 43fa 1b2e                 lea.l     $0001228E(pc),a1
[00010762] 3219                      move.w    (a1)+,d1
[00010764] 6706                      beq.s     $0001076C
[00010766] d0c1                      adda.w    d1,a0
[00010768] d150                      add.w     d0,(a0)
[0001076a] 60f6                      bra.s     $00010762
[0001076c] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010770] 4e75                      rts
[00010772] 4e75                      rts
[00010774] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010778] 247a 1b2a                 movea.l   $000122A4(pc),a2
[0001077c] 246a 0028                 movea.l   40(a2),a2
[00010780] 2052                      movea.l   (a2),a0
[00010782] 43fa 1b24                 lea.l     $000122A8(pc),a1
[00010786] 703f                      moveq.l   #63,d0
[00010788] 22d8                      move.l    (a0)+,(a1)+
[0001078a] 51c8 fffc                 dbf       d0,$00010788
[0001078e] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010792] 4e75                      rts
[00010794] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[00010798] 41fa 1c0e                 lea.l     $000123A8(pc),a0
[0001079c] 7000                      moveq.l   #0,d0
[0001079e] 3200                      move.w    d0,d1
[000107a0] 7407                      moveq.l   #7,d2
[000107a2] 4298                      clr.l     (a0)+
[000107a4] d201                      add.b     d1,d1
[000107a6] 6504                      bcs.s     $000107AC
[000107a8] 46a8 fffc                 not.l     -4(a0)
[000107ac] 51ca fff4                 dbf       d2,$000107A2
[000107b0] 5240                      addq.w    #1,d0
[000107b2] b07c 0100                 cmp.w     #$0100,d0
[000107b6] 6de6                      blt.s     $0001079E
[000107b8] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[000107bc] 4e75                      rts
[000107be] 48e7 fec0                 movem.l   d0-d6/a0-a1,-(a7)
[000107c2] 7601                      moveq.l   #1,d3
[000107c4] e16b                      lsl.w     d0,d3
[000107c6] 5343                      subq.w    #1,d3
[000107c8] 3003                      move.w    d3,d0
[000107ca] 7601                      moveq.l   #1,d3
[000107cc] e36b                      lsl.w     d1,d3
[000107ce] 5343                      subq.w    #1,d3
[000107d0] 3203                      move.w    d3,d1
[000107d2] 7601                      moveq.l   #1,d3
[000107d4] e56b                      lsl.w     d2,d3
[000107d6] 5343                      subq.w    #1,d3
[000107d8] 3403                      move.w    d3,d2
[000107da] 48a7 e000                 movem.w   d0-d2,-(a7)
[000107de] 41fa 3bc8                 lea.l     $000143A8(pc),a0
[000107e2] 7a02                      moveq.l   #2,d5
[000107e4] 7600                      moveq.l   #0,d3
[000107e6] 3803                      move.w    d3,d4
[000107e8] c8c0                      mulu.w    d0,d4
[000107ea] d8bc 0000 01f4            add.l     #$000001F4,d4
[000107f0] 88fc 03e8                 divu.w    #$03E8,d4
[000107f4] 10c4                      move.b    d4,(a0)+
[000107f6] 5243                      addq.w    #1,d3
[000107f8] b67c 03e8                 cmp.w     #$03E8,d3
[000107fc] 6fe8                      ble.s     $000107E6
[000107fe] 3001                      move.w    d1,d0
[00010800] 3202                      move.w    d2,d1
[00010802] 5288                      addq.l    #1,a0
[00010804] 51cd ffde                 dbf       d5,$000107E4
[00010808] 4c9f 0007                 movem.w   (a7)+,d0-d2
[0001080c] 43fa 4758                 lea.l     $00014F66(pc),a1
[00010810] 7c02                      moveq.l   #2,d6
[00010812] 7600                      moveq.l   #0,d3
[00010814] 3a00                      move.w    d0,d5
[00010816] e24d                      lsr.w     #1,d5
[00010818] 48c5                      ext.l     d5
[0001081a] 3803                      move.w    d3,d4
[0001081c] c8fc 03e8                 mulu.w    #$03E8,d4
[00010820] d885                      add.l     d5,d4
[00010822] 88c0                      divu.w    d0,d4
[00010824] 32c4                      move.w    d4,(a1)+
[00010826] 5243                      addq.w    #1,d3
[00010828] b640                      cmp.w     d0,d3
[0001082a] 6fee                      ble.s     $0001081A
[0001082c] 3001                      move.w    d1,d0
[0001082e] 3202                      move.w    d2,d1
[00010830] 51ce ffe0                 dbf       d6,$00010812
[00010834] 4cdf 037f                 movem.l   (a7)+,d0-d6/a0-a1
[00010838] 4e75                      rts
[0001083a] 3600                      move.w    d0,d3
[0001083c] 4843                      swap      d3
[0001083e] 3600                      move.w    d0,d3
[00010840] 4a6e 01b2                 tst.w     434(a6)
[00010844] 6712                      beq.s     $00010858
[00010846] 906e 01b6                 sub.w     438(a6),d0
[0001084a] 926e 01b8                 sub.w     440(a6),d1
[0001084e] 266e 01ae                 movea.l   430(a6),a3
[00010852] c3ee 01b2                 muls.w    434(a6),d1
[00010856] 6008                      bra.s     $00010860
[00010858] 2678 044e                 movea.l   ($0000044E).w,a3
[0001085c] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010860] d7c1                      adda.l    d1,a3
[00010862] e540                      asl.w     #2,d0
[00010864] d6c0                      adda.w    d0,a3
[00010866] e440                      asr.w     #2,d0
[00010868] 284b                      movea.l   a3,a4
[0001086a] 2813                      move.l    (a3),d4
[0001086c] b642                      cmp.w     d2,d3
[0001086e] 6e0e                      bgt.s     $0001087E
[00010870] 588b                      addq.l    #4,a3
[00010872] b89b                      cmp.l     (a3)+,d4
[00010874] 6608                      bne.s     $0001087E
[00010876] 5243                      addq.w    #1,d3
[00010878] b642                      cmp.w     d2,d3
[0001087a] 6df6                      blt.s     $00010872
[0001087c] 3602                      move.w    d2,d3
[0001087e] 3283                      move.w    d3,(a1)
[00010880] 4842                      swap      d2
[00010882] 4843                      swap      d3
[00010884] 264c                      movea.l   a4,a3
[00010886] b642                      cmp.w     d2,d3
[00010888] 6f0e                      ble.s     $00010898
[0001088a] 3003                      move.w    d3,d0
[0001088c] b8a3                      cmp.l     -(a3),d4
[0001088e] 6608                      bne.s     $00010898
[00010890] 5343                      subq.w    #1,d3
[00010892] b642                      cmp.w     d2,d3
[00010894] 6ef6                      bgt.s     $0001088C
[00010896] 3602                      move.w    d2,d3
[00010898] 3083                      move.w    d3,(a0)
[0001089a] 3015                      move.w    (a5),d0
[0001089c] b8ad 0002                 cmp.l     2(a5),d4
[000108a0] 6704                      beq.s     $000108A6
[000108a2] 0a40 0001                 eori.w    #$0001,d0
[000108a6] 322e 01b6                 move.w    438(a6),d1
[000108aa] d350                      add.w     d1,(a0)
[000108ac] d351                      add.w     d1,(a1)
[000108ae] 4e75                      rts
[000108b0] 48e7 c0e0                 movem.l   d0-d1/a0-a2,-(a7)
[000108b4] 3d7c 001f 01b4            move.w    #$001F,436(a6)
[000108ba] 3d7c 00ff 0014            move.w    #$00FF,20(a6)
[000108c0] 2d7c 0001 1460 01f4       move.l    #$00011460,500(a6)
[000108c8] 2d7c 0001 0e5a 01f8       move.l    #$00010E5A,504(a6)
[000108d0] 2d7c 0001 0efe 01fc       move.l    #$00010EFE,508(a6)
[000108d8] 2d7c 0001 1012 0200       move.l    #$00011012,512(a6)
[000108e0] 2d7c 0001 1258 0204       move.l    #$00011258,516(a6)
[000108e8] 2d7c 0001 1a9a 0208       move.l    #$00011A9A,520(a6)
[000108f0] 2d7c 0001 1bfa 020c       move.l    #$00011BFA,524(a6)
[000108f8] 2d7c 0001 1a4e 0210       move.l    #$00011A4E,528(a6)
[00010900] 2d7c 0001 083a 0214       move.l    #$0001083A,532(a6)
[00010908] 2d7c 0001 0e02 021c       move.l    #$00010E02,540(a6)
[00010910] 2d7c 0001 0e2e 0218       move.l    #$00010E2E,536(a6)
[00010918] 2d7c 0001 0aa2 0220       move.l    #$00010AA2,544(a6)
[00010920] 2d7c 0001 0a46 0224       move.l    #$00010A46,548(a6)
[00010928] 2d7c 0001 098a 0228       move.l    #$0001098A,552(a6)
[00010930] 2d7c 0001 09d6 022c       move.l    #$000109D6,556(a6)
[00010938] 2d7c 0001 0a90 0230       move.l    #$00010A90,560(a6)
[00010940] 2d7c 0001 0a9e 0234       move.l    #$00010A9E,564(a6)
[00010948] 41fa fa04                 lea.l     $0001034E(pc),a0
[0001094c] 43ee 0658                 lea.l     1624(a6),a1
[00010950] 45fa 1956                 lea.l     $000122A8(pc),a2
[00010954] 323c 00ff                 move.w    #$00FF,d1
[00010958] 7000                      moveq.l   #0,d0
[0001095a] 101a                      move.b    (a2)+,d0
[0001095c] d040                      add.w     d0,d0
[0001095e] d040                      add.w     d0,d0
[00010960] 082e 0007 01a3            btst      #7,419(a6)
[00010966] 6712                      beq.s     $0001097A
[00010968] 12f0 0003                 move.b    3(a0,d0.w),(a1)+
[0001096c] 12f0 0002                 move.b    2(a0,d0.w),(a1)+
[00010970] 12f0 0001                 move.b    1(a0,d0.w),(a1)+
[00010974] 12f0 0000                 move.b    0(a0,d0.w),(a1)+
[00010978] 6004                      bra.s     $0001097E
[0001097a] 22f0 0000                 move.l    0(a0,d0.w),(a1)+
[0001097e] 51c9 ffd8                 dbf       d1,$00010958
[00010982] 4cdf 0703                 movem.l   (a7)+,d0-d1/a0-a2
[00010986] 4e75                      rts
[00010988] 4e75                      rts
[0001098a] 43ee 0658                 lea.l     1624(a6),a1
[0001098e] d643                      add.w     d3,d3
[00010990] d643                      add.w     d3,d3
[00010992] 082e 0007 01a3            btst      #7,419(a6)
[00010998] 671e                      beq.s     $000109B8
[0001099a] 43f1 3003                 lea.l     3(a1,d3.w),a1
[0001099e] 41fa 3a08                 lea.l     $000143A8(pc),a0
[000109a2] 1330 0000                 move.b    0(a0,d0.w),-(a1)
[000109a6] 41e8 03ea                 lea.l     1002(a0),a0
[000109aa] 1330 1000                 move.b    0(a0,d1.w),-(a1)
[000109ae] 41e8 03ea                 lea.l     1002(a0),a0
[000109b2] 1330 2000                 move.b    0(a0,d2.w),-(a1)
[000109b6] 4e75                      rts
[000109b8] 43f1 3001                 lea.l     1(a1,d3.w),a1
[000109bc] 41fa 39ea                 lea.l     $000143A8(pc),a0
[000109c0] 12f0 0000                 move.b    0(a0,d0.w),(a1)+
[000109c4] 41e8 03ea                 lea.l     1002(a0),a0
[000109c8] 12f0 1000                 move.b    0(a0,d1.w),(a1)+
[000109cc] 41e8 03ea                 lea.l     1002(a0),a0
[000109d0] 12f0 2000                 move.b    0(a0,d2.w),(a1)+
[000109d4] 4e75                      rts
[000109d6] 41ee 0658                 lea.l     1624(a6),a0
[000109da] d040                      add.w     d0,d0
[000109dc] d040                      add.w     d0,d0
[000109de] 082e 0007 01a3            btst      #7,419(a6)
[000109e4] 6730                      beq.s     $00010A16
[000109e6] 41f0 0003                 lea.l     3(a0,d0.w),a0
[000109ea] 43fa 457a                 lea.l     $00014F66(pc),a1
[000109ee] 7000                      moveq.l   #0,d0
[000109f0] 1020                      move.b    -(a0),d0
[000109f2] d040                      add.w     d0,d0
[000109f4] 3031 0000                 move.w    0(a1,d0.w),d0
[000109f8] 43e9 0200                 lea.l     512(a1),a1
[000109fc] 7200                      moveq.l   #0,d1
[000109fe] 1220                      move.b    -(a0),d1
[00010a00] d241                      add.w     d1,d1
[00010a02] 3231 1000                 move.w    0(a1,d1.w),d1
[00010a06] 43e9 0200                 lea.l     512(a1),a1
[00010a0a] 7400                      moveq.l   #0,d2
[00010a0c] 1420                      move.b    -(a0),d2
[00010a0e] d442                      add.w     d2,d2
[00010a10] 3431 2000                 move.w    0(a1,d2.w),d2
[00010a14] 4e75                      rts
[00010a16] 41f0 0001                 lea.l     1(a0,d0.w),a0
[00010a1a] 43fa 454a                 lea.l     $00014F66(pc),a1
[00010a1e] 7000                      moveq.l   #0,d0
[00010a20] 1018                      move.b    (a0)+,d0
[00010a22] d040                      add.w     d0,d0
[00010a24] 3031 0000                 move.w    0(a1,d0.w),d0
[00010a28] 43e9 0200                 lea.l     512(a1),a1
[00010a2c] 7200                      moveq.l   #0,d1
[00010a2e] 1218                      move.b    (a0)+,d1
[00010a30] d241                      add.w     d1,d1
[00010a32] 3231 1000                 move.w    0(a1,d1.w),d1
[00010a36] 43e9 0200                 lea.l     512(a1),a1
[00010a3a] 7400                      moveq.l   #0,d2
[00010a3c] 1418                      move.b    (a0)+,d2
[00010a3e] d442                      add.w     d2,d2
[00010a40] 3431 2000                 move.w    0(a1,d2.w),d2
[00010a44] 4e75                      rts
[00010a46] b07c 0010                 cmp.w     #$0010,d0
[00010a4a] 6614                      bne.s     $00010A60
[00010a4c] 22d8                      move.l    (a0)+,(a1)+
[00010a4e] 22d8                      move.l    (a0)+,(a1)+
[00010a50] 22d8                      move.l    (a0)+,(a1)+
[00010a52] 22d8                      move.l    (a0)+,(a1)+
[00010a54] 22d8                      move.l    (a0)+,(a1)+
[00010a56] 22d8                      move.l    (a0)+,(a1)+
[00010a58] 22d8                      move.l    (a0)+,(a1)+
[00010a5a] 22d8                      move.l    (a0)+,(a1)+
[00010a5c] 7000                      moveq.l   #0,d0
[00010a5e] 4e75                      rts
[00010a60] 303c 00ff                 move.w    #$00FF,d0
[00010a64] 082e 0007 01a3            btst      #7,419(a6)
[00010a6a] 660a                      bne.s     $00010A76
[00010a6c] 22d8                      move.l    (a0)+,(a1)+
[00010a6e] 51c8 fffc                 dbf       d0,$00010A6C
[00010a72] 701f                      moveq.l   #31,d0
[00010a74] 4e75                      rts
[00010a76] 2f01                      move.l    d1,-(a7)
[00010a78] 3218                      move.w    (a0)+,d1
[00010a7a] e159                      rol.w     #8,d1
[00010a7c] 4841                      swap      d1
[00010a7e] 3218                      move.w    (a0)+,d1
[00010a80] e159                      rol.w     #8,d1
[00010a82] 4841                      swap      d1
[00010a84] 22c1                      move.l    d1,(a1)+
[00010a86] 51c8 fff0                 dbf       d0,$00010A78
[00010a8a] 221f                      move.l    (a7)+,d1
[00010a8c] 701f                      moveq.l   #31,d0
[00010a8e] 4e75                      rts
[00010a90] 41ee 0658                 lea.l     1624(a6),a0
[00010a94] d040                      add.w     d0,d0
[00010a96] d040                      add.w     d0,d0
[00010a98] d0c0                      adda.w    d0,a0
[00010a9a] 2010                      move.l    (a0),d0
[00010a9c] 4e75                      rts
[00010a9e] 70ff                      moveq.l   #-1,d0
[00010aa0] 4e75                      rts
[00010aa2] 2f0e                      move.l    a6,-(a7)
[00010aa4] 7000                      moveq.l   #0,d0
[00010aa6] 3028 000c                 move.w    12(a0),d0
[00010aaa] 3228 0006                 move.w    6(a0),d1
[00010aae] c2e8 0008                 mulu.w    8(a0),d1
[00010ab2] 7400                      moveq.l   #0,d2
[00010ab4] 4a68 000a                 tst.w     10(a0)
[00010ab8] 6602                      bne.s     $00010ABC
[00010aba] 7401                      moveq.l   #1,d2
[00010abc] 3342 000a                 move.w    d2,10(a1)
[00010ac0] 2050                      movea.l   (a0),a0
[00010ac2] 2251                      movea.l   (a1),a1
[00010ac4] 5381                      subq.l    #1,d1
[00010ac6] 6b4e                      bmi.s     $00010B16
[00010ac8] 5340                      subq.w    #1,d0
[00010aca] 6700 0320                 beq       $00010DEC
[00010ace] 907c 001f                 sub.w     #$001F,d0
[00010ad2] 6642                      bne.s     $00010B16
[00010ad4] d442                      add.w     d2,d2
[00010ad6] d442                      add.w     d2,d2
[00010ad8] 247b 2040                 movea.l   $00010B1A(pc,d2.w),a2
[00010adc] b3c8                      cmpa.l    a0,a1
[00010ade] 6630                      bne.s     $00010B10
[00010ae0] 2601                      move.l    d1,d3
[00010ae2] 5283                      addq.l    #1,d3
[00010ae4] ed8b                      lsl.l     #6,d3
[00010ae6] b6ae 0024                 cmp.l     36(a6),d3
[00010aea] 6e1e                      bgt.s     $00010B0A
[00010aec] 2f03                      move.l    d3,-(a7)
[00010aee] 2f08                      move.l    a0,-(a7)
[00010af0] 226e 0020                 movea.l   32(a6),a1
[00010af4] 2f09                      move.l    a1,-(a7)
[00010af6] 2001                      move.l    d1,d0
[00010af8] 5280                      addq.l    #1,d0
[00010afa] 4e92                      jsr       (a2)
[00010afc] 205f                      movea.l   (a7)+,a0
[00010afe] 225f                      movea.l   (a7)+,a1
[00010b00] 221f                      move.l    (a7)+,d1
[00010b02] e289                      lsr.l     #1,d1
[00010b04] 5381                      subq.l    #1,d1
[00010b06] 6000 02e8                 bra       $00010DF0
[00010b0a] 247b 2016                 movea.l   $00010B22(pc,d2.w),a2
[00010b0e] 6004                      bra.s     $00010B14
[00010b10] 2001                      move.l    d1,d0
[00010b12] 5280                      addq.l    #1,d0
[00010b14] 4e92                      jsr       (a2)
[00010b16] 2c5f                      movea.l   (a7)+,a6
[00010b18] 4e75                      rts
[00010b1a] 0001 0d4a                 ori.b     #$4A,d1
[00010b1e] 0001 0cac                 ori.b     #$AC,d1
[00010b22] 0001 0b2a                 ori.b     #$2A,d1
[00010b26] 0001 0c28                 ori.b     #$28,d1
[00010b2a] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010b2e] 2001                      move.l    d1,d0
[00010b30] 781f                      moveq.l   #31,d4
[00010b32] 6100 0148                 bsr       $00010C7C
[00010b36] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[00010b3a] 2c41                      movea.l   d1,a6
[00010b3c] 2f08                      move.l    a0,-(a7)
[00010b3e] 41e8 0040                 lea.l     64(a0),a0
[00010b42] 2f20                      move.l    -(a0),-(a7)
[00010b44] 2f20                      move.l    -(a0),-(a7)
[00010b46] 2f20                      move.l    -(a0),-(a7)
[00010b48] 2f20                      move.l    -(a0),-(a7)
[00010b4a] 2f20                      move.l    -(a0),-(a7)
[00010b4c] 2f20                      move.l    -(a0),-(a7)
[00010b4e] 2f20                      move.l    -(a0),-(a7)
[00010b50] 2f20                      move.l    -(a0),-(a7)
[00010b52] 2f20                      move.l    -(a0),-(a7)
[00010b54] 2f20                      move.l    -(a0),-(a7)
[00010b56] 2f20                      move.l    -(a0),-(a7)
[00010b58] 2f20                      move.l    -(a0),-(a7)
[00010b5a] 41e8 fff0                 lea.l     -16(a0),a0
[00010b5e] 2f09                      move.l    a1,-(a7)
[00010b60] 6136                      bsr.s     $00010B98
[00010b62] 225f                      movea.l   (a7)+,a1
[00010b64] 5289                      addq.l    #1,a1
[00010b66] 204f                      movea.l   a7,a0
[00010b68] 2f09                      move.l    a1,-(a7)
[00010b6a] 612c                      bsr.s     $00010B98
[00010b6c] 225f                      movea.l   (a7)+,a1
[00010b6e] 4fef 0010                 lea.l     16(a7),a7
[00010b72] 5289                      addq.l    #1,a1
[00010b74] 204f                      movea.l   a7,a0
[00010b76] 2f09                      move.l    a1,-(a7)
[00010b78] 611e                      bsr.s     $00010B98
[00010b7a] 225f                      movea.l   (a7)+,a1
[00010b7c] 4fef 0010                 lea.l     16(a7),a7
[00010b80] 5289                      addq.l    #1,a1
[00010b82] 204f                      movea.l   a7,a0
[00010b84] 6112                      bsr.s     $00010B98
[00010b86] 4fef 0010                 lea.l     16(a7),a7
[00010b8a] 205f                      movea.l   (a7)+,a0
[00010b8c] 41e8 0040                 lea.l     64(a0),a0
[00010b90] 220e                      move.l    a6,d1
[00010b92] 5381                      subq.l    #1,d1
[00010b94] 6aa4                      bpl.s     $00010B3A
[00010b96] 4e75                      rts
[00010b98] 700f                      moveq.l   #15,d0
[00010b9a] 4840                      swap      d0
[00010b9c] 3e18                      move.w    (a0)+,d7
[00010b9e] 3c18                      move.w    (a0)+,d6
[00010ba0] 3a18                      move.w    (a0)+,d5
[00010ba2] 3818                      move.w    (a0)+,d4
[00010ba4] 3618                      move.w    (a0)+,d3
[00010ba6] 3418                      move.w    (a0)+,d2
[00010ba8] 3218                      move.w    (a0)+,d1
[00010baa] 3018                      move.w    (a0)+,d0
[00010bac] 4840                      swap      d0
[00010bae] 4847                      swap      d7
[00010bb0] 4840                      swap      d0
[00010bb2] d040                      add.w     d0,d0
[00010bb4] df07                      addx.b    d7,d7
[00010bb6] d241                      add.w     d1,d1
[00010bb8] df07                      addx.b    d7,d7
[00010bba] d442                      add.w     d2,d2
[00010bbc] df07                      addx.b    d7,d7
[00010bbe] d643                      add.w     d3,d3
[00010bc0] df07                      addx.b    d7,d7
[00010bc2] d844                      add.w     d4,d4
[00010bc4] df07                      addx.b    d7,d7
[00010bc6] da45                      add.w     d5,d5
[00010bc8] df07                      addx.b    d7,d7
[00010bca] dc46                      add.w     d6,d6
[00010bcc] df07                      addx.b    d7,d7
[00010bce] 4847                      swap      d7
[00010bd0] de47                      add.w     d7,d7
[00010bd2] 4847                      swap      d7
[00010bd4] df07                      addx.b    d7,d7
[00010bd6] 1287                      move.b    d7,(a1)
[00010bd8] 5889                      addq.l    #4,a1
[00010bda] 4840                      swap      d0
[00010bdc] 51c8 ffd2                 dbf       d0,$00010BB0
[00010be0] 4e75                      rts
[00010be2] 700f                      moveq.l   #15,d0
[00010be4] 4840                      swap      d0
[00010be6] 4847                      swap      d7
[00010be8] 1e10                      move.b    (a0),d7
[00010bea] 5888                      addq.l    #4,a0
[00010bec] de07                      add.b     d7,d7
[00010bee] d140                      addx.w    d0,d0
[00010bf0] de07                      add.b     d7,d7
[00010bf2] d341                      addx.w    d1,d1
[00010bf4] de07                      add.b     d7,d7
[00010bf6] d542                      addx.w    d2,d2
[00010bf8] de07                      add.b     d7,d7
[00010bfa] d743                      addx.w    d3,d3
[00010bfc] de07                      add.b     d7,d7
[00010bfe] d944                      addx.w    d4,d4
[00010c00] de07                      add.b     d7,d7
[00010c02] db45                      addx.w    d5,d5
[00010c04] de07                      add.b     d7,d7
[00010c06] dd46                      addx.w    d6,d6
[00010c08] de07                      add.b     d7,d7
[00010c0a] 4847                      swap      d7
[00010c0c] df47                      addx.w    d7,d7
[00010c0e] 4840                      swap      d0
[00010c10] 51c8 ffd2                 dbf       d0,$00010BE4
[00010c14] 4840                      swap      d0
[00010c16] 32c7                      move.w    d7,(a1)+
[00010c18] 32c6                      move.w    d6,(a1)+
[00010c1a] 32c5                      move.w    d5,(a1)+
[00010c1c] 32c4                      move.w    d4,(a1)+
[00010c1e] 32c3                      move.w    d3,(a1)+
[00010c20] 32c2                      move.w    d2,(a1)+
[00010c22] 32c1                      move.w    d1,(a1)+
[00010c24] 32c0                      move.w    d0,(a1)+
[00010c26] 4e75                      rts
[00010c28] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010c2c] 2c41                      movea.l   d1,a6
[00010c2e] 41e8 0040                 lea.l     64(a0),a0
[00010c32] 2f08                      move.l    a0,-(a7)
[00010c34] 2f20                      move.l    -(a0),-(a7)
[00010c36] 2f20                      move.l    -(a0),-(a7)
[00010c38] 2f20                      move.l    -(a0),-(a7)
[00010c3a] 2f20                      move.l    -(a0),-(a7)
[00010c3c] 2f20                      move.l    -(a0),-(a7)
[00010c3e] 2f20                      move.l    -(a0),-(a7)
[00010c40] 2f20                      move.l    -(a0),-(a7)
[00010c42] 2f20                      move.l    -(a0),-(a7)
[00010c44] 2f20                      move.l    -(a0),-(a7)
[00010c46] 2f20                      move.l    -(a0),-(a7)
[00010c48] 2f20                      move.l    -(a0),-(a7)
[00010c4a] 2f20                      move.l    -(a0),-(a7)
[00010c4c] 2f20                      move.l    -(a0),-(a7)
[00010c4e] 2f20                      move.l    -(a0),-(a7)
[00010c50] 2f20                      move.l    -(a0),-(a7)
[00010c52] 2f20                      move.l    -(a0),-(a7)
[00010c54] 618c                      bsr.s     $00010BE2
[00010c56] 204f                      movea.l   a7,a0
[00010c58] 5288                      addq.l    #1,a0
[00010c5a] 6186                      bsr.s     $00010BE2
[00010c5c] 204f                      movea.l   a7,a0
[00010c5e] 5488                      addq.l    #2,a0
[00010c60] 6180                      bsr.s     $00010BE2
[00010c62] 204f                      movea.l   a7,a0
[00010c64] 5688                      addq.l    #3,a0
[00010c66] 6100 ff7a                 bsr       $00010BE2
[00010c6a] 4fef 0040                 lea.l     64(a7),a7
[00010c6e] 205f                      movea.l   (a7)+,a0
[00010c70] 220e                      move.l    a6,d1
[00010c72] 5381                      subq.l    #1,d1
[00010c74] 6ab6                      bpl.s     $00010C2C
[00010c76] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[00010c7a] 701f                      moveq.l   #31,d0
[00010c7c] 5384                      subq.l    #1,d4
[00010c7e] 6b2a                      bmi.s     $00010CAA
[00010c80] 7400                      moveq.l   #0,d2
[00010c82] 2204                      move.l    d4,d1
[00010c84] d1c0                      adda.l    d0,a0
[00010c86] 41f0 0802                 lea.l     2(a0,d0.l),a0
[00010c8a] 3a10                      move.w    (a0),d5
[00010c8c] 2248                      movea.l   a0,a1
[00010c8e] 2448                      movea.l   a0,a2
[00010c90] d480                      add.l     d0,d2
[00010c92] 2602                      move.l    d2,d3
[00010c94] 6004                      bra.s     $00010C9A
[00010c96] 2449                      movea.l   a1,a2
[00010c98] 34a1                      move.w    -(a1),(a2)
[00010c9a] 5383                      subq.l    #1,d3
[00010c9c] 6af8                      bpl.s     $00010C96
[00010c9e] 3285                      move.w    d5,(a1)
[00010ca0] 5381                      subq.l    #1,d1
[00010ca2] 6ae0                      bpl.s     $00010C84
[00010ca4] 204a                      movea.l   a2,a0
[00010ca6] 5380                      subq.l    #1,d0
[00010ca8] 6ad6                      bpl.s     $00010C80
[00010caa] 4e75                      rts
[00010cac] d080                      add.l     d0,d0
[00010cae] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010cb2] 6130                      bsr.s     $00010CE4
[00010cb4] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010cb8] 5288                      addq.l    #1,a0
[00010cba] 2400                      move.l    d0,d2
[00010cbc] e78a                      lsl.l     #3,d2
[00010cbe] d3c2                      adda.l    d2,a1
[00010cc0] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010cc4] 611e                      bsr.s     $00010CE4
[00010cc6] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010cca] 5288                      addq.l    #1,a0
[00010ccc] 2400                      move.l    d0,d2
[00010cce] e78a                      lsl.l     #3,d2
[00010cd0] d3c2                      adda.l    d2,a1
[00010cd2] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010cd6] 610c                      bsr.s     $00010CE4
[00010cd8] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010cdc] 5288                      addq.l    #1,a0
[00010cde] 2400                      move.l    d0,d2
[00010ce0] e78a                      lsl.l     #3,d2
[00010ce2] d3c2                      adda.l    d2,a1
[00010ce4] 45f1 0800                 lea.l     0(a1,d0.l),a2
[00010ce8] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010cec] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010cf0] e588                      lsl.l     #2,d0
[00010cf2] 2a40                      movea.l   d0,a5
[00010cf4] 2c41                      movea.l   d1,a6
[00010cf6] 700f                      moveq.l   #15,d0
[00010cf8] 4840                      swap      d0
[00010cfa] 4847                      swap      d7
[00010cfc] 1e10                      move.b    (a0),d7
[00010cfe] 5888                      addq.l    #4,a0
[00010d00] de07                      add.b     d7,d7
[00010d02] d140                      addx.w    d0,d0
[00010d04] de07                      add.b     d7,d7
[00010d06] d341                      addx.w    d1,d1
[00010d08] de07                      add.b     d7,d7
[00010d0a] d542                      addx.w    d2,d2
[00010d0c] de07                      add.b     d7,d7
[00010d0e] d743                      addx.w    d3,d3
[00010d10] de07                      add.b     d7,d7
[00010d12] d944                      addx.w    d4,d4
[00010d14] de07                      add.b     d7,d7
[00010d16] db45                      addx.w    d5,d5
[00010d18] de07                      add.b     d7,d7
[00010d1a] dd46                      addx.w    d6,d6
[00010d1c] de07                      add.b     d7,d7
[00010d1e] 4847                      swap      d7
[00010d20] df47                      addx.w    d7,d7
[00010d22] 4840                      swap      d0
[00010d24] 51c8 ffd2                 dbf       d0,$00010CF8
[00010d28] 4840                      swap      d0
[00010d2a] 32c7                      move.w    d7,(a1)+
[00010d2c] 34c6                      move.w    d6,(a2)+
[00010d2e] 36c5                      move.w    d5,(a3)+
[00010d30] 38c4                      move.w    d4,(a4)+
[00010d32] 3383 d8fe                 move.w    d3,-2(a1,a5.l)
[00010d36] 3582 d8fe                 move.w    d2,-2(a2,a5.l)
[00010d3a] 3781 d8fe                 move.w    d1,-2(a3,a5.l)
[00010d3e] 3980 d8fe                 move.w    d0,-2(a4,a5.l)
[00010d42] 220e                      move.l    a6,d1
[00010d44] 5381                      subq.l    #1,d1
[00010d46] 6aac                      bpl.s     $00010CF4
[00010d48] 4e75                      rts
[00010d4a] d080                      add.l     d0,d0
[00010d4c] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010d50] 6130                      bsr.s     $00010D82
[00010d52] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010d56] 2400                      move.l    d0,d2
[00010d58] e78a                      lsl.l     #3,d2
[00010d5a] d1c2                      adda.l    d2,a0
[00010d5c] 5289                      addq.l    #1,a1
[00010d5e] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010d62] 611e                      bsr.s     $00010D82
[00010d64] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010d68] 2400                      move.l    d0,d2
[00010d6a] e78a                      lsl.l     #3,d2
[00010d6c] d1c2                      adda.l    d2,a0
[00010d6e] 5289                      addq.l    #1,a1
[00010d70] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010d74] 610c                      bsr.s     $00010D82
[00010d76] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010d7a] 2400                      move.l    d0,d2
[00010d7c] e78a                      lsl.l     #3,d2
[00010d7e] d1c2                      adda.l    d2,a0
[00010d80] 5289                      addq.l    #1,a1
[00010d82] 45f0 0800                 lea.l     0(a0,d0.l),a2
[00010d86] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010d8a] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010d8e] e588                      lsl.l     #2,d0
[00010d90] 2a40                      movea.l   d0,a5
[00010d92] 2c41                      movea.l   d1,a6
[00010d94] 700f                      moveq.l   #15,d0
[00010d96] 4840                      swap      d0
[00010d98] 3e18                      move.w    (a0)+,d7
[00010d9a] 3c1a                      move.w    (a2)+,d6
[00010d9c] 3a1b                      move.w    (a3)+,d5
[00010d9e] 381c                      move.w    (a4)+,d4
[00010da0] 3630 d8fe                 move.w    -2(a0,a5.l),d3
[00010da4] 3432 d8fe                 move.w    -2(a2,a5.l),d2
[00010da8] 3233 d8fe                 move.w    -2(a3,a5.l),d1
[00010dac] 3034 d8fe                 move.w    -2(a4,a5.l),d0
[00010db0] 4840                      swap      d0
[00010db2] 4847                      swap      d7
[00010db4] 4840                      swap      d0
[00010db6] d040                      add.w     d0,d0
[00010db8] df07                      addx.b    d7,d7
[00010dba] d241                      add.w     d1,d1
[00010dbc] df07                      addx.b    d7,d7
[00010dbe] d442                      add.w     d2,d2
[00010dc0] df07                      addx.b    d7,d7
[00010dc2] d643                      add.w     d3,d3
[00010dc4] df07                      addx.b    d7,d7
[00010dc6] d844                      add.w     d4,d4
[00010dc8] df07                      addx.b    d7,d7
[00010dca] da45                      add.w     d5,d5
[00010dcc] df07                      addx.b    d7,d7
[00010dce] dc46                      add.w     d6,d6
[00010dd0] df07                      addx.b    d7,d7
[00010dd2] 4847                      swap      d7
[00010dd4] de47                      add.w     d7,d7
[00010dd6] 4847                      swap      d7
[00010dd8] df07                      addx.b    d7,d7
[00010dda] 1287                      move.b    d7,(a1)
[00010ddc] 5889                      addq.l    #4,a1
[00010dde] 4840                      swap      d0
[00010de0] 51c8 ffd2                 dbf       d0,$00010DB4
[00010de4] 220e                      move.l    a6,d1
[00010de6] 5381                      subq.l    #1,d1
[00010de8] 6aa8                      bpl.s     $00010D92
[00010dea] 4e75                      rts
[00010dec] b3c8                      cmpa.l    a0,a1
[00010dee] 670e                      beq.s     $00010DFE
[00010df0] e289                      lsr.l     #1,d1
[00010df2] 6504                      bcs.s     $00010DF8
[00010df4] 32d8                      move.w    (a0)+,(a1)+
[00010df6] 6002                      bra.s     $00010DFA
[00010df8] 22d8                      move.l    (a0)+,(a1)+
[00010dfa] 5381                      subq.l    #1,d1
[00010dfc] 6afa                      bpl.s     $00010DF8
[00010dfe] 2c5f                      movea.l   (a7)+,a6
[00010e00] 4e75                      rts
[00010e02] 4a6e 01b2                 tst.w     434(a6)
[00010e06] 6712                      beq.s     $00010E1A
[00010e08] 906e 01b6                 sub.w     438(a6),d0
[00010e0c] 926e 01b8                 sub.w     440(a6),d1
[00010e10] 206e 01ae                 movea.l   430(a6),a0
[00010e14] c3ee 01b2                 muls.w    434(a6),d1
[00010e18] 6008                      bra.s     $00010E22
[00010e1a] 2078 044e                 movea.l   ($0000044E).w,a0
[00010e1e] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010e22] d1c1                      adda.l    d1,a0
[00010e24] d040                      add.w     d0,d0
[00010e26] d040                      add.w     d0,d0
[00010e28] d0c0                      adda.w    d0,a0
[00010e2a] 2010                      move.l    (a0),d0
[00010e2c] 4e75                      rts
[00010e2e] 4a6e 01b2                 tst.w     434(a6)
[00010e32] 6712                      beq.s     $00010E46
[00010e34] 906e 01b6                 sub.w     438(a6),d0
[00010e38] 926e 01b8                 sub.w     440(a6),d1
[00010e3c] 206e 01ae                 movea.l   430(a6),a0
[00010e40] c3ee 01b2                 muls.w    434(a6),d1
[00010e44] 6008                      bra.s     $00010E4E
[00010e46] 2078 044e                 movea.l   ($0000044E).w,a0
[00010e4a] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010e4e] d1c1                      adda.l    d1,a0
[00010e50] d040                      add.w     d0,d0
[00010e52] d040                      add.w     d0,d0
[00010e54] d0c0                      adda.w    d0,a0
[00010e56] 2082                      move.l    d2,(a0)
[00010e58] 4e75                      rts
[00010e5a] 4a6e 00ca                 tst.w     202(a6)
[00010e5e] 6766                      beq.s     $00010EC6
[00010e60] 2f08                      move.l    a0,-(a7)
[00010e62] 206e 00c6                 movea.l   198(a6),a0
[00010e66] 780f                      moveq.l   #15,d4
[00010e68] c841                      and.w     d1,d4
[00010e6a] ed4c                      lsl.w     #6,d4
[00010e6c] d0c4                      adda.w    d4,a0
[00010e6e] 3838 206e                 move.w    ($0000206E).w,d4
[00010e72] 2278 044e                 movea.l   ($0000044E).w,a1
[00010e76] 4a6e 01b2                 tst.w     434(a6)
[00010e7a] 6712                      beq.s     $00010E8E
[00010e7c] 43ee 01b6                 lea.l     438(a6),a1
[00010e80] 9051                      sub.w     (a1),d0
[00010e82] 9459                      sub.w     (a1)+,d2
[00010e84] 9251                      sub.w     (a1),d1
[00010e86] 382e 01b2                 move.w    434(a6),d4
[00010e8a] 226e 01ae                 movea.l   430(a6),a1
[00010e8e] 9440                      sub.w     d0,d2
[00010e90] d040                      add.w     d0,d0
[00010e92] d040                      add.w     d0,d0
[00010e94] c2c4                      mulu.w    d4,d1
[00010e96] 48c0                      ext.l     d0
[00010e98] d280                      add.l     d0,d1
[00010e9a] 7e40                      moveq.l   #64,d7
[00010e9c] 7c0f                      moveq.l   #15,d6
[00010e9e] b446                      cmp.w     d6,d2
[00010ea0] 6c02                      bge.s     $00010EA4
[00010ea2] 3c02                      move.w    d2,d6
[00010ea4] 703f                      moveq.l   #63,d0
[00010ea6] c041                      and.w     d1,d0
[00010ea8] 2a30 0000                 move.l    0(a0,d0.w),d5
[00010eac] 3802                      move.w    d2,d4
[00010eae] e84c                      lsr.w     #4,d4
[00010eb0] 2241                      movea.l   d1,a1
[00010eb2] 2285                      move.l    d5,(a1)
[00010eb4] d2c7                      adda.w    d7,a1
[00010eb6] 51cc fffa                 dbf       d4,$00010EB2
[00010eba] 5881                      addq.l    #4,d1
[00010ebc] 5342                      subq.w    #1,d2
[00010ebe] 51ce ffe4                 dbf       d6,$00010EA4
[00010ec2] 205f                      movea.l   (a7)+,a0
[00010ec4] 4e75                      rts
[00010ec6] 226e 00c6                 movea.l   198(a6),a1
[00010eca] 780f                      moveq.l   #15,d4
[00010ecc] c841                      and.w     d1,d4
[00010ece] d844                      add.w     d4,d4
[00010ed0] 3c31 4000                 move.w    0(a1,d4.w),d6
[00010ed4] 43ee 0658                 lea.l     1624(a6),a1
[00010ed8] 3a2e 00be                 move.w    190(a6),d5
[00010edc] da45                      add.w     d5,d5
[00010ede] da45                      add.w     d5,d5
[00010ee0] 2a31 5000                 move.l    0(a1,d5.w),d5
[00010ee4] 4a6e 01b2                 tst.w     434(a6)
[00010ee8] 673e                      beq.s     $00010F28
[00010eea] 43ee 01b6                 lea.l     438(a6),a1
[00010eee] 9051                      sub.w     (a1),d0
[00010ef0] 9459                      sub.w     (a1)+,d2
[00010ef2] 9251                      sub.w     (a1),d1
[00010ef4] 226e 01ae                 movea.l   430(a6),a1
[00010ef8] c3ee 01b2                 muls.w    434(a6),d1
[00010efc] 6032                      bra.s     $00010F30
[00010efe] 43ee 0658                 lea.l     1624(a6),a1
[00010f02] 3a2e 0046                 move.w    70(a6),d5
[00010f06] da45                      add.w     d5,d5
[00010f08] da45                      add.w     d5,d5
[00010f0a] 2a31 5000                 move.l    0(a1,d5.w),d5
[00010f0e] 4a6e 01b2                 tst.w     434(a6)
[00010f12] 6714                      beq.s     $00010F28
[00010f14] 43ee 01b6                 lea.l     438(a6),a1
[00010f18] 9051                      sub.w     (a1),d0
[00010f1a] 9459                      sub.w     (a1)+,d2
[00010f1c] 9251                      sub.w     (a1),d1
[00010f1e] 226e 01ae                 movea.l   430(a6),a1
[00010f22] c3ee 01b2                 muls.w    434(a6),d1
[00010f26] 6008                      bra.s     $00010F30
[00010f28] 2278 044e                 movea.l   ($0000044E).w,a1
[00010f2c] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010f30] 3800                      move.w    d0,d4
[00010f32] d844                      add.w     d4,d4
[00010f34] d844                      add.w     d4,d4
[00010f36] d3c1                      adda.l    d1,a1
[00010f38] d2c4                      adda.w    d4,a1
[00010f3a] 9440                      sub.w     d0,d2
[00010f3c] c07c 000f                 and.w     #$000F,d0
[00010f40] e17e                      rol.w     d0,d6
[00010f42] de47                      add.w     d7,d7
[00010f44] 3e3b 7008                 move.w    $00010F4E(pc,d7.w),d7
[00010f48] 4efb 7004                 jmp       $00010F4E(pc,d7.w)
[00010f4c] 4e75                      rts
[00010f4e] 0008 0042                 ori.b     #$42,a0 ; apollo only
[00010f52] 0086 0040 bc7c            ori.l     #$0040BC7C,d6
[00010f58] ffff 6700 00ae 2f0b       vperm     #$00AE2F0B,e8,e14,e15
[00010f60] 7240                      moveq.l   #64,d1
[00010f62] 700f                      moveq.l   #15,d0
[00010f64] b440                      cmp.w     d0,d2
[00010f66] 6c02                      bge.s     $00010F6A
[00010f68] 3002                      move.w    d2,d0
[00010f6a] dc46                      add.w     d6,d6
[00010f6c] 54c7                      scc       d7
[00010f6e] 4887                      ext.w     d7
[00010f70] 48c7                      ext.l     d7
[00010f72] 8e85                      or.l      d5,d7
[00010f74] 3802                      move.w    d2,d4
[00010f76] e84c                      lsr.w     #4,d4
[00010f78] 2649                      movea.l   a1,a3
[00010f7a] 2687                      move.l    d7,(a3)
[00010f7c] d6c1                      adda.w    d1,a3
[00010f7e] 51cc fffa                 dbf       d4,$00010F7A
[00010f82] 5889                      addq.l    #4,a1
[00010f84] 5342                      subq.w    #1,d2
[00010f86] 51c8 ffe2                 dbf       d0,$00010F6A
[00010f8a] 265f                      movea.l   (a7)+,a3
[00010f8c] 4e75                      rts
[00010f8e] 4646                      not.w     d6
[00010f90] bc7c ffff                 cmp.w     #$FFFF,d6
[00010f94] 6774                      beq.s     $0001100A
[00010f96] 2f0b                      move.l    a3,-(a7)
[00010f98] 7240                      moveq.l   #64,d1
[00010f9a] 700f                      moveq.l   #15,d0
[00010f9c] b440                      cmp.w     d0,d2
[00010f9e] 6c02                      bge.s     $00010FA2
[00010fa0] 3002                      move.w    d2,d0
[00010fa2] dc46                      add.w     d6,d6
[00010fa4] 640e                      bcc.s     $00010FB4
[00010fa6] 3802                      move.w    d2,d4
[00010fa8] e84c                      lsr.w     #4,d4
[00010faa] 2649                      movea.l   a1,a3
[00010fac] 2685                      move.l    d5,(a3)
[00010fae] d6c1                      adda.w    d1,a3
[00010fb0] 51cc fffa                 dbf       d4,$00010FAC
[00010fb4] 5889                      addq.l    #4,a1
[00010fb6] 5342                      subq.w    #1,d2
[00010fb8] 51c8 ffe8                 dbf       d0,$00010FA2
[00010fbc] 265f                      movea.l   (a7)+,a3
[00010fbe] 4e75                      rts
[00010fc0] 5889                      addq.l    #4,a1
[00010fc2] 51ca 0004                 dbf       d2,$00010FC8
[00010fc6] 4e75                      rts
[00010fc8] e24a                      lsr.w     #1,d2
[00010fca] 4699                      not.l     (a1)+
[00010fcc] 5889                      addq.l    #4,a1
[00010fce] 51ca fffa                 dbf       d2,$00010FCA
[00010fd2] 4e75                      rts
[00010fd4] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010fd8] 67ee                      beq.s     $00010FC8
[00010fda] bc7c 5555                 cmp.w     #$5555,d6
[00010fde] 67e0                      beq.s     $00010FC0
[00010fe0] 2f0b                      move.l    a3,-(a7)
[00010fe2] 7240                      moveq.l   #64,d1
[00010fe4] 700f                      moveq.l   #15,d0
[00010fe6] b440                      cmp.w     d0,d2
[00010fe8] 6c02                      bge.s     $00010FEC
[00010fea] 3002                      move.w    d2,d0
[00010fec] dc46                      add.w     d6,d6
[00010fee] 640e                      bcc.s     $00010FFE
[00010ff0] 3802                      move.w    d2,d4
[00010ff2] e84c                      lsr.w     #4,d4
[00010ff4] 2649                      movea.l   a1,a3
[00010ff6] 4693                      not.l     (a3)
[00010ff8] d6c1                      adda.w    d1,a3
[00010ffa] 51cc fffa                 dbf       d4,$00010FF6
[00010ffe] 5889                      addq.l    #4,a1
[00011000] 5342                      subq.w    #1,d2
[00011002] 51c8 ffe8                 dbf       d0,$00010FEC
[00011006] 265f                      movea.l   (a7)+,a3
[00011008] 4e75                      rts
[0001100a] 22c5                      move.l    d5,(a1)+
[0001100c] 51ca fffc                 dbf       d2,$0001100A
[00011010] 4e75                      rts
[00011012] 9641                      sub.w     d1,d3
[00011014] 43ee 0658                 lea.l     1624(a6),a1
[00011018] 382e 0046                 move.w    70(a6),d4
[0001101c] d844                      add.w     d4,d4
[0001101e] d844                      add.w     d4,d4
[00011020] 2831 4000                 move.l    0(a1,d4.w),d4
[00011024] 2278 044e                 movea.l   ($0000044E).w,a1
[00011028] 3a38 206e                 move.w    ($0000206E).w,d5
[0001102c] 4a6e 01b2                 tst.w     434(a6)
[00011030] 6710                      beq.s     $00011042
[00011032] 906e 01b6                 sub.w     438(a6),d0
[00011036] 926e 01b8                 sub.w     440(a6),d1
[0001103a] 226e 01ae                 movea.l   430(a6),a1
[0001103e] 3a2e 01b2                 move.w    434(a6),d5
[00011042] c3c5                      muls.w    d5,d1
[00011044] d3c1                      adda.l    d1,a1
[00011046] d040                      add.w     d0,d0
[00011048] d040                      add.w     d0,d0
[0001104a] d2c0                      adda.w    d0,a1
[0001104c] 48c5                      ext.l     d5
[0001104e] de47                      add.w     d7,d7
[00011050] 3e3b 7006                 move.w    $00011058(pc,d7.w),d7
[00011054] 4efb 7002                 jmp       $00011058(pc,d7.w)
J1:
[00011058] 0120                      dc.w $0120   ; $00011178-$00011058
[0001105a] 000a                      dc.w $000a   ; $00011062-$00011058
[0001105c] 009a                      dc.w $009a   ; $000110f2-$00011058
[0001105e] 0008                      dc.w $0008   ; $00011060-$00011058
[00011060] 4646                      not.w     d6
[00011062] 3f05                      move.w    d5,-(a7)
[00011064] e98d                      lsl.l     #4,d5
[00011066] 700f                      moveq.l   #15,d0
[00011068] b640                      cmp.w     d0,d3
[0001106a] 6c02                      bge.s     $0001106E
[0001106c] 3003                      move.w    d3,d0
[0001106e] 2409                      move.l    a1,d2
[00011070] dc46                      add.w     d6,d6
[00011072] 645a                      bcc.s     $000110CE
[00011074] 3203                      move.w    d3,d1
[00011076] e849                      lsr.w     #4,d1
[00011078] 3e01                      move.w    d1,d7
[0001107a] e849                      lsr.w     #4,d1
[0001107c] 4647                      not.w     d7
[0001107e] 0247 000f                 andi.w    #$000F,d7
[00011082] de47                      add.w     d7,d7
[00011084] de47                      add.w     d7,d7
[00011086] 4efb 7002                 jmp       $0001108A(pc,d7.w)
[0001108a] 2284                      move.l    d4,(a1)
[0001108c] d3c5                      adda.l    d5,a1
[0001108e] 2284                      move.l    d4,(a1)
[00011090] d3c5                      adda.l    d5,a1
[00011092] 2284                      move.l    d4,(a1)
[00011094] d3c5                      adda.l    d5,a1
[00011096] 2284                      move.l    d4,(a1)
[00011098] d3c5                      adda.l    d5,a1
[0001109a] 2284                      move.l    d4,(a1)
[0001109c] d3c5                      adda.l    d5,a1
[0001109e] 2284                      move.l    d4,(a1)
[000110a0] d3c5                      adda.l    d5,a1
[000110a2] 2284                      move.l    d4,(a1)
[000110a4] d3c5                      adda.l    d5,a1
[000110a6] 2284                      move.l    d4,(a1)
[000110a8] d3c5                      adda.l    d5,a1
[000110aa] 2284                      move.l    d4,(a1)
[000110ac] d3c5                      adda.l    d5,a1
[000110ae] 2284                      move.l    d4,(a1)
[000110b0] d3c5                      adda.l    d5,a1
[000110b2] 2284                      move.l    d4,(a1)
[000110b4] d3c5                      adda.l    d5,a1
[000110b6] 2284                      move.l    d4,(a1)
[000110b8] d3c5                      adda.l    d5,a1
[000110ba] 2284                      move.l    d4,(a1)
[000110bc] d3c5                      adda.l    d5,a1
[000110be] 2284                      move.l    d4,(a1)
[000110c0] d3c5                      adda.l    d5,a1
[000110c2] 2284                      move.l    d4,(a1)
[000110c4] d3c5                      adda.l    d5,a1
[000110c6] 2284                      move.l    d4,(a1)
[000110c8] d3c5                      adda.l    d5,a1
[000110ca] 51c9 ffbe                 dbf       d1,$0001108A
[000110ce] 2242                      movea.l   d2,a1
[000110d0] d2d7                      adda.w    (a7),a1
[000110d2] 5343                      subq.w    #1,d3
[000110d4] 51c8 ff98                 dbf       d0,$0001106E
[000110d8] 548f                      addq.l    #2,a7
[000110da] 4e75                      rts
[000110dc] d2c5                      adda.w    d5,a1
[000110de] 51cb 0004                 dbf       d3,$000110E4
[000110e2] 4e75                      rts
[000110e4] da45                      add.w     d5,d5
[000110e6] e24b                      lsr.w     #1,d3
[000110e8] 4691                      not.l     (a1)
[000110ea] d2c5                      adda.w    d5,a1
[000110ec] 51cb fffa                 dbf       d3,$000110E8
[000110f0] 4e75                      rts
[000110f2] bc7c aaaa                 cmp.w     #$AAAA,d6
[000110f6] 67ec                      beq.s     $000110E4
[000110f8] bc7c 5555                 cmp.w     #$5555,d6
[000110fc] 67de                      beq.s     $000110DC
[000110fe] 3f05                      move.w    d5,-(a7)
[00011100] e98d                      lsl.l     #4,d5
[00011102] 700f                      moveq.l   #15,d0
[00011104] b640                      cmp.w     d0,d3
[00011106] 6c02                      bge.s     $0001110A
[00011108] 3003                      move.w    d3,d0
[0001110a] 2409                      move.l    a1,d2
[0001110c] dc46                      add.w     d6,d6
[0001110e] 645a                      bcc.s     $0001116A
[00011110] 3203                      move.w    d3,d1
[00011112] e849                      lsr.w     #4,d1
[00011114] 3e01                      move.w    d1,d7
[00011116] e849                      lsr.w     #4,d1
[00011118] 4647                      not.w     d7
[0001111a] 0247 000f                 andi.w    #$000F,d7
[0001111e] de47                      add.w     d7,d7
[00011120] de47                      add.w     d7,d7
[00011122] 4efb 7002                 jmp       $00011126(pc,d7.w)
[00011126] 4691                      not.l     (a1)
[00011128] d3c5                      adda.l    d5,a1
[0001112a] 4691                      not.l     (a1)
[0001112c] d3c5                      adda.l    d5,a1
[0001112e] 4691                      not.l     (a1)
[00011130] d3c5                      adda.l    d5,a1
[00011132] 4691                      not.l     (a1)
[00011134] d3c5                      adda.l    d5,a1
[00011136] 4691                      not.l     (a1)
[00011138] d3c5                      adda.l    d5,a1
[0001113a] 4691                      not.l     (a1)
[0001113c] d3c5                      adda.l    d5,a1
[0001113e] 4691                      not.l     (a1)
[00011140] d3c5                      adda.l    d5,a1
[00011142] 4691                      not.l     (a1)
[00011144] d3c5                      adda.l    d5,a1
[00011146] 4691                      not.l     (a1)
[00011148] d3c5                      adda.l    d5,a1
[0001114a] 4691                      not.l     (a1)
[0001114c] d3c5                      adda.l    d5,a1
[0001114e] 4691                      not.l     (a1)
[00011150] d3c5                      adda.l    d5,a1
[00011152] 4691                      not.l     (a1)
[00011154] d3c5                      adda.l    d5,a1
[00011156] 4691                      not.l     (a1)
[00011158] d3c5                      adda.l    d5,a1
[0001115a] 4691                      not.l     (a1)
[0001115c] d3c5                      adda.l    d5,a1
[0001115e] 4691                      not.l     (a1)
[00011160] d3c5                      adda.l    d5,a1
[00011162] 4691                      not.l     (a1)
[00011164] d3c5                      adda.l    d5,a1
[00011166] 51c9 ffbe                 dbf       d1,$00011126
[0001116a] 2242                      movea.l   d2,a1
[0001116c] d2d7                      adda.w    (a7),a1
[0001116e] 5343                      subq.w    #1,d3
[00011170] 51c8 ff98                 dbf       d0,$0001110A
[00011174] 548f                      addq.l    #2,a7
[00011176] 4e75                      rts
[00011178] bc7c ffff                 cmp.w     #$FFFF,d6
[0001117c] 6700 0082                 beq       $00011200
[00011180] 3f05                      move.w    d5,-(a7)
[00011182] e98d                      lsl.l     #4,d5
[00011184] 700f                      moveq.l   #15,d0
[00011186] b640                      cmp.w     d0,d3
[00011188] 6c02                      bge.s     $0001118C
[0001118a] 3003                      move.w    d3,d0
[0001118c] 2f09                      move.l    a1,-(a7)
[0001118e] dc46                      add.w     d6,d6
[00011190] 54c2                      scc       d2
[00011192] 4882                      ext.w     d2
[00011194] 48c2                      ext.l     d2
[00011196] 8484                      or.l      d4,d2
[00011198] 3203                      move.w    d3,d1
[0001119a] e849                      lsr.w     #4,d1
[0001119c] 3e01                      move.w    d1,d7
[0001119e] e849                      lsr.w     #4,d1
[000111a0] 4647                      not.w     d7
[000111a2] 0247 000f                 andi.w    #$000F,d7
[000111a6] de47                      add.w     d7,d7
[000111a8] de47                      add.w     d7,d7
[000111aa] 4efb 7002                 jmp       $000111AE(pc,d7.w)
[000111ae] 2282                      move.l    d2,(a1)
[000111b0] d3c5                      adda.l    d5,a1
[000111b2] 2282                      move.l    d2,(a1)
[000111b4] d3c5                      adda.l    d5,a1
[000111b6] 2282                      move.l    d2,(a1)
[000111b8] d3c5                      adda.l    d5,a1
[000111ba] 2282                      move.l    d2,(a1)
[000111bc] d3c5                      adda.l    d5,a1
[000111be] 2282                      move.l    d2,(a1)
[000111c0] d3c5                      adda.l    d5,a1
[000111c2] 2282                      move.l    d2,(a1)
[000111c4] d3c5                      adda.l    d5,a1
[000111c6] 2282                      move.l    d2,(a1)
[000111c8] d3c5                      adda.l    d5,a1
[000111ca] 2282                      move.l    d2,(a1)
[000111cc] d3c5                      adda.l    d5,a1
[000111ce] 2282                      move.l    d2,(a1)
[000111d0] d3c5                      adda.l    d5,a1
[000111d2] 2282                      move.l    d2,(a1)
[000111d4] d3c5                      adda.l    d5,a1
[000111d6] 2282                      move.l    d2,(a1)
[000111d8] d3c5                      adda.l    d5,a1
[000111da] 2282                      move.l    d2,(a1)
[000111dc] d3c5                      adda.l    d5,a1
[000111de] 2282                      move.l    d2,(a1)
[000111e0] d3c5                      adda.l    d5,a1
[000111e2] 2282                      move.l    d2,(a1)
[000111e4] d3c5                      adda.l    d5,a1
[000111e6] 2282                      move.l    d2,(a1)
[000111e8] d3c5                      adda.l    d5,a1
[000111ea] 2282                      move.l    d2,(a1)
[000111ec] d3c5                      adda.l    d5,a1
[000111ee] 51c9 ffbe                 dbf       d1,$000111AE
[000111f2] 225f                      movea.l   (a7)+,a1
[000111f4] d2d7                      adda.w    (a7),a1
[000111f6] 5343                      subq.w    #1,d3
[000111f8] 51c8 ff92                 dbf       d0,$0001118C
[000111fc] 548f                      addq.l    #2,a7
[000111fe] 4e75                      rts
[00011200] 3403                      move.w    d3,d2
[00011202] 4642                      not.w     d2
[00011204] c47c 000f                 and.w     #$000F,d2
[00011208] d442                      add.w     d2,d2
[0001120a] d442                      add.w     d2,d2
[0001120c] e84b                      lsr.w     #4,d3
[0001120e] 4efb 2002                 jmp       $00011212(pc,d2.w)
[00011212] 2284                      move.l    d4,(a1)
[00011214] d2c5                      adda.w    d5,a1
[00011216] 2284                      move.l    d4,(a1)
[00011218] d2c5                      adda.w    d5,a1
[0001121a] 2284                      move.l    d4,(a1)
[0001121c] d2c5                      adda.w    d5,a1
[0001121e] 2284                      move.l    d4,(a1)
[00011220] d2c5                      adda.w    d5,a1
[00011222] 2284                      move.l    d4,(a1)
[00011224] d2c5                      adda.w    d5,a1
[00011226] 2284                      move.l    d4,(a1)
[00011228] d2c5                      adda.w    d5,a1
[0001122a] 2284                      move.l    d4,(a1)
[0001122c] d2c5                      adda.w    d5,a1
[0001122e] 2284                      move.l    d4,(a1)
[00011230] d2c5                      adda.w    d5,a1
[00011232] 2284                      move.l    d4,(a1)
[00011234] d2c5                      adda.w    d5,a1
[00011236] 2284                      move.l    d4,(a1)
[00011238] d2c5                      adda.w    d5,a1
[0001123a] 2284                      move.l    d4,(a1)
[0001123c] d2c5                      adda.w    d5,a1
[0001123e] 2284                      move.l    d4,(a1)
[00011240] d2c5                      adda.w    d5,a1
[00011242] 2284                      move.l    d4,(a1)
[00011244] d2c5                      adda.w    d5,a1
[00011246] 2284                      move.l    d4,(a1)
[00011248] d2c5                      adda.w    d5,a1
[0001124a] 2284                      move.l    d4,(a1)
[0001124c] d2c5                      adda.w    d5,a1
[0001124e] 2284                      move.l    d4,(a1)
[00011250] d2c5                      adda.w    d5,a1
[00011252] 51cb ffbe                 dbf       d3,$00011212
[00011256] 4e75                      rts
[00011258] 2278 044e                 movea.l   ($0000044E).w,a1
[0001125c] 3a38 206e                 move.w    ($0000206E).w,d5
[00011260] 4a6e 01b2                 tst.w     434(a6)
[00011264] 6714                      beq.s     $0001127A
[00011266] 43ee 01b6                 lea.l     438(a6),a1
[0001126a] 9051                      sub.w     (a1),d0
[0001126c] 9459                      sub.w     (a1)+,d2
[0001126e] 9251                      sub.w     (a1),d1
[00011270] 9651                      sub.w     (a1),d3
[00011272] 226e 01ae                 movea.l   430(a6),a1
[00011276] 3a2e 01b2                 move.w    434(a6),d5
[0001127a] 3805                      move.w    d5,d4
[0001127c] c9c1                      muls.w    d1,d4
[0001127e] d3c4                      adda.l    d4,a1
[00011280] d040                      add.w     d0,d0
[00011282] d040                      add.w     d0,d0
[00011284] d2c0                      adda.w    d0,a1
[00011286] e440                      asr.w     #2,d0
[00011288] 780f                      moveq.l   #15,d4
[0001128a] c840                      and.w     d0,d4
[0001128c] e97e                      rol.w     d4,d6
[0001128e] 9440                      sub.w     d0,d2
[00011290] 6b3c                      bmi.s     $000112CE
[00011292] 9641                      sub.w     d1,d3
[00011294] 6a04                      bpl.s     $0001129A
[00011296] 4443                      neg.w     d3
[00011298] 4445                      neg.w     d5
[0001129a] 2f08                      move.l    a0,-(a7)
[0001129c] 41ee 0658                 lea.l     1624(a6),a0
[000112a0] 382e 0046                 move.w    70(a6),d4
[000112a4] d844                      add.w     d4,d4
[000112a6] d844                      add.w     d4,d4
[000112a8] 2830 4000                 move.l    0(a0,d4.w),d4
[000112ac] 205f                      movea.l   (a7)+,a0
[000112ae] b443                      cmp.w     d3,d2
[000112b0] 6d26                      blt.s     $000112D8
[000112b2] 3002                      move.w    d2,d0
[000112b4] d06e 004e                 add.w     78(a6),d0
[000112b8] 6b14                      bmi.s     $000112CE
[000112ba] 3203                      move.w    d3,d1
[000112bc] d241                      add.w     d1,d1
[000112be] 4442                      neg.w     d2
[000112c0] 3602                      move.w    d2,d3
[000112c2] d442                      add.w     d2,d2
[000112c4] de47                      add.w     d7,d7
[000112c6] 3e3b 7008                 move.w    $000112D0(pc,d7.w),d7
[000112ca] 4efb 7004                 jmp       $000112D0(pc,d7.w)
[000112ce] 4e75                      rts
[000112d0] 002a 0070 0096            ori.b     #$70,150(a2)
[000112d6] 006e 3003 d06e            ori.w     #$3003,-12178(a6)
[000112dc] 004e 6bee                 ori.w     #$6BEE,a6 ; apollo only
[000112e0] 4443                      neg.w     d3
[000112e2] 3203                      move.w    d3,d1
[000112e4] d241                      add.w     d1,d1
[000112e6] d442                      add.w     d2,d2
[000112e8] de47                      add.w     d7,d7
[000112ea] 3e3b 7006                 move.w    $000112F2(pc,d7.w),d7
[000112ee] 4efb 7002                 jmp       $000112F2(pc,d7.w)
J2:
[000112f2] 009c                      dc.w $009c   ; $0001138e-$000112f2
[000112f4] 00e8                      dc.w $00e8   ; $000113da-$000112f2
[000112f6] 0104                      dc.w $0104   ; $000113f6-$000112f2
[000112f8] 00e6                      dc.w $00e6   ; $000113d8-$000112f2
[000112fa] bc7c                      dc.w $bc7c   ; $0000cf6e-$000112f2
[000112fc] ffff                      dc.w $ffff   ; $000112f1-$000112f2
[000112fe] 6728                      dc.w $6728   ; $00017a1a-$000112f2
[00011300] 7eff                      dc.w $7eff   ; $000191f1-$000112f2
[00011302] e35e                      dc.w $e35e   ; $0000f650-$000112f2
[00011304] 640c                      dc.w $640c   ; $000176fe-$000112f2
[00011306] 22c4                      dc.w $22c4   ; $000135b6-$000112f2
[00011308] d641                      dc.w $d641   ; $0000e933-$000112f2
[0001130a] 6a12                      dc.w $6a12   ; $00017d04-$000112f2
[0001130c] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[0001130e] fff4                      dc.w $fff4   ; $000112e6-$000112f2
[00011310] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011312] 22c7                      dc.w $22c7   ; $000135b9-$000112f2
[00011314] d641                      dc.w $d641   ; $0000e933-$000112f2
[00011316] 6a06                      dc.w $6a06   ; $00017cf8-$000112f2
[00011318] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[0001131a] ffe8                      dc.w $ffe8   ; $000112da-$000112f2
[0001131c] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[0001131e] d2c5                      dc.w $d2c5   ; $0000e5b7-$000112f2
[00011320] d642                      dc.w $d642   ; $0000e934-$000112f2
[00011322] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011324] ffde                      dc.w $ffde   ; $000112d0-$000112f2
[00011326] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011328] 22c4                      dc.w $22c4   ; $000135b6-$000112f2
[0001132a] d641                      dc.w $d641   ; $0000e933-$000112f2
[0001132c] 6a06                      dc.w $6a06   ; $00017cf8-$000112f2
[0001132e] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011330] fff8                      dc.w $fff8   ; $000112ea-$000112f2
[00011332] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011334] d2c5                      dc.w $d2c5   ; $0000e5b7-$000112f2
[00011336] d642                      dc.w $d642   ; $0000e934-$000112f2
[00011338] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[0001133a] ffee                      dc.w $ffee   ; $000112e0-$000112f2
[0001133c] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[0001133e] 4646                      dc.w $4646   ; $00015938-$000112f2
[00011340] e35e                      dc.w $e35e   ; $0000f650-$000112f2
[00011342] 640c                      dc.w $640c   ; $000176fe-$000112f2
[00011344] 22c4                      dc.w $22c4   ; $000135b6-$000112f2
[00011346] d641                      dc.w $d641   ; $0000e933-$000112f2
[00011348] 6a12                      dc.w $6a12   ; $00017d04-$000112f2
[0001134a] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[0001134c] fff4                      dc.w $fff4   ; $000112e6-$000112f2
[0001134e] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011350] 5889                      dc.w $5889   ; $00016b7b-$000112f2
[00011352] d641                      dc.w $d641   ; $0000e933-$000112f2
[00011354] 6a06                      dc.w $6a06   ; $00017cf8-$000112f2
[00011356] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011358] ffe8                      dc.w $ffe8   ; $000112da-$000112f2
[0001135a] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[0001135c] d2c5                      dc.w $d2c5   ; $0000e5b7-$000112f2
[0001135e] d642                      dc.w $d642   ; $0000e934-$000112f2
[00011360] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011362] ffde                      dc.w $ffde   ; $000112d0-$000112f2
[00011364] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011366] 78ff                      dc.w $78ff   ; $00018bf1-$000112f2
[00011368] e35e                      dc.w $e35e   ; $0000f650-$000112f2
[0001136a] 640c                      dc.w $640c   ; $000176fe-$000112f2
[0001136c] 4699                      dc.w $4699   ; $0001598b-$000112f2
[0001136e] d641                      dc.w $d641   ; $0000e933-$000112f2
[00011370] 6a12                      dc.w $6a12   ; $00017d04-$000112f2
[00011372] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011374] fff4                      dc.w $fff4   ; $000112e6-$000112f2
[00011376] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011378] 5889                      dc.w $5889   ; $00016b7b-$000112f2
[0001137a] d641                      dc.w $d641   ; $0000e933-$000112f2
[0001137c] 6a06                      dc.w $6a06   ; $00017cf8-$000112f2
[0001137e] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[00011380] ffe8                      dc.w $ffe8   ; $000112da-$000112f2
[00011382] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[00011384] d2c5                      dc.w $d2c5   ; $0000e5b7-$000112f2
[00011386] d642                      dc.w $d642   ; $0000e934-$000112f2
[00011388] 51c8                      dc.w $51c8   ; $000164ba-$000112f2
[0001138a] ffde                      dc.w $ffde   ; $000112d0-$000112f2
[0001138c] 4e75                      dc.w $4e75   ; $00016167-$000112f2
[0001138e] bc7c ffff                 cmp.w     #$FFFF,d6
[00011392] 672c                      beq.s     $000113C0
[00011394] 7eff                      moveq.l   #-1,d7
[00011396] e35e                      rol.w     #1,d6
[00011398] 640e                      bcc.s     $000113A8
[0001139a] 2284                      move.l    d4,(a1)
[0001139c] d2c5                      adda.w    d5,a1
[0001139e] d642                      add.w     d2,d3
[000113a0] 6a14                      bpl.s     $000113B6
[000113a2] 51c8 fff2                 dbf       d0,$00011396
[000113a6] 4e75                      rts
[000113a8] 2287                      move.l    d7,(a1)
[000113aa] d2c5                      adda.w    d5,a1
[000113ac] d642                      add.w     d2,d3
[000113ae] 6a06                      bpl.s     $000113B6
[000113b0] 51c8 ffe4                 dbf       d0,$00011396
[000113b4] 4e75                      rts
[000113b6] d641                      add.w     d1,d3
[000113b8] 5889                      addq.l    #4,a1
[000113ba] 51c8 ffda                 dbf       d0,$00011396
[000113be] 4e75                      rts
[000113c0] 2284                      move.l    d4,(a1)
[000113c2] d2c5                      adda.w    d5,a1
[000113c4] d642                      add.w     d2,d3
[000113c6] 6a06                      bpl.s     $000113CE
[000113c8] 51c8 fff6                 dbf       d0,$000113C0
[000113cc] 4e75                      rts
[000113ce] d641                      add.w     d1,d3
[000113d0] 5889                      addq.l    #4,a1
[000113d2] 51c8 ffec                 dbf       d0,$000113C0
[000113d6] 4e75                      rts
[000113d8] 4646                      not.w     d6
[000113da] e35e                      rol.w     #1,d6
[000113dc] 6402                      bcc.s     $000113E0
[000113de] 2284                      move.l    d4,(a1)
[000113e0] d2c5                      adda.w    d5,a1
[000113e2] d642                      add.w     d2,d3
[000113e4] 6a06                      bpl.s     $000113EC
[000113e6] 51c8 fff2                 dbf       d0,$000113DA
[000113ea] 4e75                      rts
[000113ec] d641                      add.w     d1,d3
[000113ee] 5889                      addq.l    #4,a1
[000113f0] 51c8 ffe8                 dbf       d0,$000113DA
[000113f4] 4e75                      rts
[000113f6] 78ff                      moveq.l   #-1,d4
[000113f8] e35e                      rol.w     #1,d6
[000113fa] 6402                      bcc.s     $000113FE
[000113fc] 4691                      not.l     (a1)
[000113fe] d2c5                      adda.w    d5,a1
[00011400] d642                      add.w     d2,d3
[00011402] 6a06                      bpl.s     $0001140A
[00011404] 51c8 fff2                 dbf       d0,$000113F8
[00011408] 4e75                      rts
[0001140a] d641                      add.w     d1,d3
[0001140c] 5889                      addq.l    #4,a1
[0001140e] 51c8 ffe8                 dbf       d0,$000113F8
[00011412] 4e75                      rts
[00011414] 9641                      sub.w     d1,d3
[00011416] c3c4                      muls.w    d4,d1
[00011418] 3c00                      move.w    d0,d6
[0001141a] dc46                      add.w     d6,d6
[0001141c] dc46                      add.w     d6,d6
[0001141e] 48c6                      ext.l     d6
[00011420] d286                      add.l     d6,d1
[00011422] d3c1                      adda.l    d1,a1
[00011424] 9440                      sub.w     d0,d2
[00011426] 3002                      move.w    d2,d0
[00011428] 5240                      addq.w    #1,d0
[0001142a] d040                      add.w     d0,d0
[0001142c] d040                      add.w     d0,d0
[0001142e] 9840                      sub.w     d0,d4
[00011430] 7007                      moveq.l   #7,d0
[00011432] c042                      and.w     d2,d0
[00011434] 0a40 0007                 eori.w    #$0007,d0
[00011438] d040                      add.w     d0,d0
[0001143a] e64a                      lsr.w     #3,d2
[0001143c] 41fb 0006                 lea.l     $00011444(pc,d0.w),a0
[00011440] 3002                      move.w    d2,d0
[00011442] 4ed0                      jmp       (a0)
[00011444] 22c5                      move.l    d5,(a1)+
[00011446] 22c5                      move.l    d5,(a1)+
[00011448] 22c5                      move.l    d5,(a1)+
[0001144a] 22c5                      move.l    d5,(a1)+
[0001144c] 22c5                      move.l    d5,(a1)+
[0001144e] 22c5                      move.l    d5,(a1)+
[00011450] 22c5                      move.l    d5,(a1)+
[00011452] 22c5                      move.l    d5,(a1)+
[00011454] 51c8 ffee                 dbf       d0,$00011444
[00011458] d2c4                      adda.w    d4,a1
[0001145a] 51cb ffe4                 dbf       d3,$00011440
[0001145e] 4e75                      rts
[00011460] 41ee 0658                 lea.l     1624(a6),a0
[00011464] 3a2e 00be                 move.w    190(a6),d5
[00011468] da45                      add.w     d5,d5
[0001146a] da45                      add.w     d5,d5
[0001146c] 2a30 5000                 move.l    0(a0,d5.w),d5
[00011470] 2278 044e                 movea.l   ($0000044E).w,a1
[00011474] 3838 206e                 move.w    ($0000206E).w,d4
[00011478] 4a6e 01b2                 tst.w     434(a6)
[0001147c] 6714                      beq.s     $00011492
[0001147e] 43ee 01b6                 lea.l     438(a6),a1
[00011482] 9051                      sub.w     (a1),d0
[00011484] 9459                      sub.w     (a1)+,d2
[00011486] 9251                      sub.w     (a1),d1
[00011488] 9651                      sub.w     (a1),d3
[0001148a] 226e 01ae                 movea.l   430(a6),a1
[0001148e] 382e 01b2                 move.w    434(a6),d4
[00011492] 3c2e 00c0                 move.w    192(a6),d6
[00011496] 3e2e 003c                 move.w    60(a6),d7
[0001149a] 6624                      bne.s     $000114C0
[0001149c] 4a6e 00be                 tst.w     190(a6)
[000114a0] 6700 ff72                 beq       $00011414
[000114a4] 0c6e 0001 00c0            cmpi.w    #$0001,192(a6)
[000114aa] 6700 ff68                 beq       $00011414
[000114ae] 0c6e 0002 00c0            cmpi.w    #$0002,192(a6)
[000114b4] 660a                      bne.s     $000114C0
[000114b6] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[000114bc] 6700 ff56                 beq       $00011414
[000114c0] 286e 00c6                 movea.l   198(a6),a4
[000114c4] 206e 0020                 movea.l   32(a6),a0
[000114c8] 9641                      sub.w     d1,d3
[000114ca] 3c04                      move.w    d4,d6
[000114cc] 48c6                      ext.l     d6
[000114ce] c9c1                      muls.w    d1,d4
[000114d0] d3c4                      adda.l    d4,a1
[000114d2] 3800                      move.w    d0,d4
[000114d4] d844                      add.w     d4,d4
[000114d6] d844                      add.w     d4,d4
[000114d8] d2c4                      adda.w    d4,a1
[000114da] 4a47                      tst.w     d7
[000114dc] 6600 028c                 bne       $0001176A
[000114e0] 4fef ffe4                 lea.l     -28(a7),a7
[000114e4] 3f46 0016                 move.w    d6,22(a7)
[000114e8] 78f0                      moveq.l   #-16,d4
[000114ea] c842                      and.w     d2,d4
[000114ec] 9840                      sub.w     d0,d4
[000114ee] d844                      add.w     d4,d4
[000114f0] d844                      add.w     d4,d4
[000114f2] e98e                      lsl.l     #4,d6
[000114f4] 48c4                      ext.l     d4
[000114f6] 9c84                      sub.l     d4,d6
[000114f8] 2f46 000e                 move.l    d6,14(a7)
[000114fc] 2a48                      movea.l   a0,a5
[000114fe] 7c1f                      moveq.l   #31,d6
[00011500] d26e 01b8                 add.w     440(a6),d1
[00011504] d241                      add.w     d1,d1
[00011506] 4a6e 00ca                 tst.w     202(a6)
[0001150a] 673e                      beq.s     $0001154A
[0001150c] c246                      and.w     d6,d1
[0001150e] 6722                      beq.s     $00011532
[00011510] 264c                      movea.l   a4,a3
[00011512] 3a01                      move.w    d1,d5
[00011514] bd45                      eor.w     d6,d5
[00011516] 3c01                      move.w    d1,d6
[00011518] 5346                      subq.w    #1,d6
[0001151a] eb49                      lsl.w     #5,d1
[0001151c] d6c1                      adda.w    d1,a3
[0001151e] 2adb                      move.l    (a3)+,(a5)+
[00011520] 2adb                      move.l    (a3)+,(a5)+
[00011522] 2adb                      move.l    (a3)+,(a5)+
[00011524] 2adb                      move.l    (a3)+,(a5)+
[00011526] 2adb                      move.l    (a3)+,(a5)+
[00011528] 2adb                      move.l    (a3)+,(a5)+
[0001152a] 2adb                      move.l    (a3)+,(a5)+
[0001152c] 2adb                      move.l    (a3)+,(a5)+
[0001152e] 51cd ffee                 dbf       d5,$0001151E
[00011532] 2adc                      move.l    (a4)+,(a5)+
[00011534] 2adc                      move.l    (a4)+,(a5)+
[00011536] 2adc                      move.l    (a4)+,(a5)+
[00011538] 2adc                      move.l    (a4)+,(a5)+
[0001153a] 2adc                      move.l    (a4)+,(a5)+
[0001153c] 2adc                      move.l    (a4)+,(a5)+
[0001153e] 2adc                      move.l    (a4)+,(a5)+
[00011540] 2adc                      move.l    (a4)+,(a5)+
[00011542] 51ce ffee                 dbf       d6,$00011532
[00011546] 6000 0092                 bra       $000115DA
[0001154a] 4dfa 0e5c                 lea.l     $000123A8(pc),a6
[0001154e] c246                      and.w     d6,d1
[00011550] 674a                      beq.s     $0001159C
[00011552] 264c                      movea.l   a4,a3
[00011554] d6c1                      adda.w    d1,a3
[00011556] 3c01                      move.w    d1,d6
[00011558] 0a41 001f                 eori.w    #$001F,d1
[0001155c] 5346                      subq.w    #1,d6
[0001155e] 7e00                      moveq.l   #0,d7
[00011560] 1e1b                      move.b    (a3)+,d7
[00011562] eb4f                      lsl.w     #5,d7
[00011564] 45f6 7000                 lea.l     0(a6,d7.w),a2
[00011568] 2e1a                      move.l    (a2)+,d7
[0001156a] 8e85                      or.l      d5,d7
[0001156c] 2ac7                      move.l    d7,(a5)+
[0001156e] 2e1a                      move.l    (a2)+,d7
[00011570] 8e85                      or.l      d5,d7
[00011572] 2ac7                      move.l    d7,(a5)+
[00011574] 2e1a                      move.l    (a2)+,d7
[00011576] 8e85                      or.l      d5,d7
[00011578] 2ac7                      move.l    d7,(a5)+
[0001157a] 2e1a                      move.l    (a2)+,d7
[0001157c] 8e85                      or.l      d5,d7
[0001157e] 2ac7                      move.l    d7,(a5)+
[00011580] 2e1a                      move.l    (a2)+,d7
[00011582] 8e85                      or.l      d5,d7
[00011584] 2ac7                      move.l    d7,(a5)+
[00011586] 2e1a                      move.l    (a2)+,d7
[00011588] 8e85                      or.l      d5,d7
[0001158a] 2ac7                      move.l    d7,(a5)+
[0001158c] 2e1a                      move.l    (a2)+,d7
[0001158e] 8e85                      or.l      d5,d7
[00011590] 2ac7                      move.l    d7,(a5)+
[00011592] 2e1a                      move.l    (a2)+,d7
[00011594] 8e85                      or.l      d5,d7
[00011596] 2ac7                      move.l    d7,(a5)+
[00011598] 51c9 ffc4                 dbf       d1,$0001155E
[0001159c] 7e00                      moveq.l   #0,d7
[0001159e] 1e1c                      move.b    (a4)+,d7
[000115a0] eb4f                      lsl.w     #5,d7
[000115a2] 45f6 7000                 lea.l     0(a6,d7.w),a2
[000115a6] 2e1a                      move.l    (a2)+,d7
[000115a8] 8e85                      or.l      d5,d7
[000115aa] 2ac7                      move.l    d7,(a5)+
[000115ac] 2e1a                      move.l    (a2)+,d7
[000115ae] 8e85                      or.l      d5,d7
[000115b0] 2ac7                      move.l    d7,(a5)+
[000115b2] 2e1a                      move.l    (a2)+,d7
[000115b4] 8e85                      or.l      d5,d7
[000115b6] 2ac7                      move.l    d7,(a5)+
[000115b8] 2e1a                      move.l    (a2)+,d7
[000115ba] 8e85                      or.l      d5,d7
[000115bc] 2ac7                      move.l    d7,(a5)+
[000115be] 2e1a                      move.l    (a2)+,d7
[000115c0] 8e85                      or.l      d5,d7
[000115c2] 2ac7                      move.l    d7,(a5)+
[000115c4] 2e1a                      move.l    (a2)+,d7
[000115c6] 8e85                      or.l      d5,d7
[000115c8] 2ac7                      move.l    d7,(a5)+
[000115ca] 2e1a                      move.l    (a2)+,d7
[000115cc] 8e85                      or.l      d5,d7
[000115ce] 2ac7                      move.l    d7,(a5)+
[000115d0] 2e1a                      move.l    (a2)+,d7
[000115d2] 8e85                      or.l      d5,d7
[000115d4] 2ac7                      move.l    d7,(a5)+
[000115d6] 51ce ffc4                 dbf       d6,$0001159C
[000115da] 3c02                      move.w    d2,d6
[000115dc] e84a                      lsr.w     #4,d2
[000115de] 3800                      move.w    d0,d4
[000115e0] e84c                      lsr.w     #4,d4
[000115e2] 9444                      sub.w     d4,d2
[000115e4] 6700 0126                 beq       $0001170C
[000115e8] 5542                      subq.w    #2,d2
[000115ea] 3e82                      move.w    d2,(a7)
[000115ec] 7a1e                      moveq.l   #30,d5
[000115ee] d040                      add.w     d0,d0
[000115f0] c045                      and.w     d5,d0
[000115f2] 3f40 0004                 move.w    d0,4(a7)
[000115f6] 7e00                      moveq.l   #0,d7
[000115f8] 907c 0018                 sub.w     #$0018,d0
[000115fc] 6b04                      bmi.s     $00011602
[000115fe] 3e00                      move.w    d0,d7
[00011600] de47                      add.w     d7,d7
[00011602] 3f47 0006                 move.w    d7,6(a7)
[00011606] dc46                      add.w     d6,d6
[00011608] cc45                      and.w     d5,d6
[0001160a] 3e06                      move.w    d6,d7
[0001160c] de47                      add.w     d7,d7
[0001160e] 5847                      addq.w    #4,d7
[00011610] 3f47 000c                 move.w    d7,12(a7)
[00011614] bb46                      eor.w     d5,d6
[00011616] 3f46 0008                 move.w    d6,8(a7)
[0001161a] 7e10                      moveq.l   #16,d7
[0001161c] 5146                      subq.w    #8,d6
[0001161e] 6a04                      bpl.s     $00011624
[00011620] dc46                      add.w     d6,d6
[00011622] de46                      add.w     d6,d7
[00011624] 3f47 000a                 move.w    d7,10(a7)
[00011628] 700f                      moveq.l   #15,d0
[0001162a] b640                      cmp.w     d0,d3
[0001162c] 6c02                      bge.s     $00011630
[0001162e] 3003                      move.w    d3,d0
[00011630] 3f40 0018                 move.w    d0,24(a7)
[00011634] 3f43 0002                 move.w    d3,2(a7)
[00011638] 2f49 0012                 move.l    a1,18(a7)
[0001163c] 302f 0002                 move.w    2(a7),d0
[00011640] e848                      lsr.w     #4,d0
[00011642] 2218                      move.l    (a0)+,d1
[00011644] 2418                      move.l    (a0)+,d2
[00011646] 2618                      move.l    (a0)+,d3
[00011648] 2818                      move.l    (a0)+,d4
[0001164a] 2a18                      move.l    (a0)+,d5
[0001164c] 2c18                      move.l    (a0)+,d6
[0001164e] 2e18                      move.l    (a0)+,d7
[00011650] 2458                      movea.l   (a0)+,a2
[00011652] 2658                      movea.l   (a0)+,a3
[00011654] 2858                      movea.l   (a0)+,a4
[00011656] 2a58                      movea.l   (a0)+,a5
[00011658] 2c58                      movea.l   (a0)+,a6
[0001165a] 4840                      swap      d0
[0001165c] d0ef 0006                 adda.w    6(a7),a0
[00011660] 302f 0004                 move.w    4(a7),d0
[00011664] 4efb 0002                 jmp       $00011668(pc,d0.w)
[00011668] 22c1                      move.l    d1,(a1)+
[0001166a] 22c2                      move.l    d2,(a1)+
[0001166c] 22c3                      move.l    d3,(a1)+
[0001166e] 22c4                      move.l    d4,(a1)+
[00011670] 22c5                      move.l    d5,(a1)+
[00011672] 22c6                      move.l    d6,(a1)+
[00011674] 22c7                      move.l    d7,(a1)+
[00011676] 22ca                      move.l    a2,(a1)+
[00011678] 22cb                      move.l    a3,(a1)+
[0001167a] 22cc                      move.l    a4,(a1)+
[0001167c] 22cd                      move.l    a5,(a1)+
[0001167e] 22ce                      move.l    a6,(a1)+
[00011680] 22d8                      move.l    (a0)+,(a1)+
[00011682] 22d8                      move.l    (a0)+,(a1)+
[00011684] 22d8                      move.l    (a0)+,(a1)+
[00011686] 22d8                      move.l    (a0)+,(a1)+
[00011688] 3017                      move.w    (a7),d0
[0001168a] 6b28                      bmi.s     $000116B4
[0001168c] 41e8 fff0                 lea.l     -16(a0),a0
[00011690] 22c1                      move.l    d1,(a1)+
[00011692] 22c2                      move.l    d2,(a1)+
[00011694] 22c3                      move.l    d3,(a1)+
[00011696] 22c4                      move.l    d4,(a1)+
[00011698] 22c5                      move.l    d5,(a1)+
[0001169a] 22c6                      move.l    d6,(a1)+
[0001169c] 22c7                      move.l    d7,(a1)+
[0001169e] 22ca                      move.l    a2,(a1)+
[000116a0] 22cb                      move.l    a3,(a1)+
[000116a2] 22cc                      move.l    a4,(a1)+
[000116a4] 22cd                      move.l    a5,(a1)+
[000116a6] 22ce                      move.l    a6,(a1)+
[000116a8] 22d8                      move.l    (a0)+,(a1)+
[000116aa] 22d8                      move.l    (a0)+,(a1)+
[000116ac] 22d8                      move.l    (a0)+,(a1)+
[000116ae] 22d8                      move.l    (a0)+,(a1)+
[000116b0] 51c8 ffda                 dbf       d0,$0001168C
[000116b4] 90ef 000a                 suba.w    10(a7),a0
[000116b8] d2ef 000c                 adda.w    12(a7),a1
[000116bc] 302f 0008                 move.w    8(a7),d0
[000116c0] 4efb 0002                 jmp       $000116C4(pc,d0.w)
[000116c4] 2320                      move.l    -(a0),-(a1)
[000116c6] 2320                      move.l    -(a0),-(a1)
[000116c8] 2320                      move.l    -(a0),-(a1)
[000116ca] 2320                      move.l    -(a0),-(a1)
[000116cc] 230e                      move.l    a6,-(a1)
[000116ce] 230d                      move.l    a5,-(a1)
[000116d0] 230c                      move.l    a4,-(a1)
[000116d2] 230b                      move.l    a3,-(a1)
[000116d4] 230a                      move.l    a2,-(a1)
[000116d6] 2307                      move.l    d7,-(a1)
[000116d8] 2306                      move.l    d6,-(a1)
[000116da] 2305                      move.l    d5,-(a1)
[000116dc] 2304                      move.l    d4,-(a1)
[000116de] 2303                      move.l    d3,-(a1)
[000116e0] 2302                      move.l    d2,-(a1)
[000116e2] 2301                      move.l    d1,-(a1)
[000116e4] d3ef 000e                 adda.l    14(a7),a1
[000116e8] 4840                      swap      d0
[000116ea] 51c8 ff6e                 dbf       d0,$0001165A
[000116ee] 41e8 0010                 lea.l     16(a0),a0
[000116f2] 226f 0012                 movea.l   18(a7),a1
[000116f6] d2ef 0016                 adda.w    22(a7),a1
[000116fa] 536f 0002                 subq.w    #1,2(a7)
[000116fe] 536f 0018                 subq.w    #1,24(a7)
[00011702] 6a00 ff34                 bpl       $00011638
[00011706] 4fef 001c                 lea.l     28(a7),a7
[0001170a] 4e75                      rts
[0001170c] 366f 0016                 movea.w   22(a7),a3
[00011710] 4fef 001c                 lea.l     28(a7),a7
[00011714] 720f                      moveq.l   #15,d1
[00011716] 9c40                      sub.w     d0,d6
[00011718] 3e06                      move.w    d6,d7
[0001171a] de47                      add.w     d7,d7
[0001171c] de47                      add.w     d7,d7
[0001171e] 96c7                      suba.w    d7,a3
[00011720] b346                      eor.w     d1,d6
[00011722] dc46                      add.w     d6,d6
[00011724] 45fb 601c                 lea.l     $00011742(pc,d6.w),a2
[00011728] c041                      and.w     d1,d0
[0001172a] d040                      add.w     d0,d0
[0001172c] d040                      add.w     d0,d0
[0001172e] d0c0                      adda.w    d0,a0
[00011730] 2848                      movea.l   a0,a4
[00011732] 41e8 0040                 lea.l     64(a0),a0
[00011736] 51c9 0008                 dbf       d1,$00011740
[0001173a] 720f                      moveq.l   #15,d1
[0001173c] 41e8 fc00                 lea.l     -1024(a0),a0
[00011740] 4ed2                      jmp       (a2)
[00011742] 22dc                      move.l    (a4)+,(a1)+
[00011744] 22dc                      move.l    (a4)+,(a1)+
[00011746] 22dc                      move.l    (a4)+,(a1)+
[00011748] 22dc                      move.l    (a4)+,(a1)+
[0001174a] 22dc                      move.l    (a4)+,(a1)+
[0001174c] 22dc                      move.l    (a4)+,(a1)+
[0001174e] 22dc                      move.l    (a4)+,(a1)+
[00011750] 22dc                      move.l    (a4)+,(a1)+
[00011752] 22dc                      move.l    (a4)+,(a1)+
[00011754] 22dc                      move.l    (a4)+,(a1)+
[00011756] 22dc                      move.l    (a4)+,(a1)+
[00011758] 22dc                      move.l    (a4)+,(a1)+
[0001175a] 22dc                      move.l    (a4)+,(a1)+
[0001175c] 22dc                      move.l    (a4)+,(a1)+
[0001175e] 22dc                      move.l    (a4)+,(a1)+
[00011760] 229c                      move.l    (a4)+,(a1)
[00011762] d2cb                      adda.w    a3,a1
[00011764] 51cb ffca                 dbf       d3,$00011730
[00011768] 4e75                      rts
[0001176a] 5547                      subq.w    #2,d7
[0001176c] 6d00 01f6                 blt       $00011964
[00011770] 6600 01b2                 bne       $00011924
[00011774] 3e2e 00c0                 move.w    192(a6),d7
[00011778] 6700 015c                 beq       $000118D6
[0001177c] 5347                      subq.w    #1,d7
[0001177e] 6700 0158                 beq       $000118D8
[00011782] 5347                      subq.w    #1,d7
[00011784] 660a                      bne.s     $00011790
[00011786] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[0001178c] 6700 014a                 beq       $000118D8
[00011790] 3f06                      move.w    d6,-(a7)
[00011792] 4dfa 0c14                 lea.l     $000123A8(pc),a6
[00011796] 2a48                      movea.l   a0,a5
[00011798] 7c1f                      moveq.l   #31,d6
[0001179a] d26e 01b8                 add.w     440(a6),d1
[0001179e] d241                      add.w     d1,d1
[000117a0] c246                      and.w     d6,d1
[000117a2] 672c                      beq.s     $000117D0
[000117a4] 264c                      movea.l   a4,a3
[000117a6] d6c1                      adda.w    d1,a3
[000117a8] 3c01                      move.w    d1,d6
[000117aa] 0a41 001f                 eori.w    #$001F,d1
[000117ae] 5346                      subq.w    #1,d6
[000117b0] 7e00                      moveq.l   #0,d7
[000117b2] 1e1b                      move.b    (a3)+,d7
[000117b4] 4607                      not.b     d7
[000117b6] eb4f                      lsl.w     #5,d7
[000117b8] 45f6 7000                 lea.l     0(a6,d7.w),a2
[000117bc] 2ada                      move.l    (a2)+,(a5)+
[000117be] 2ada                      move.l    (a2)+,(a5)+
[000117c0] 2ada                      move.l    (a2)+,(a5)+
[000117c2] 2ada                      move.l    (a2)+,(a5)+
[000117c4] 2ada                      move.l    (a2)+,(a5)+
[000117c6] 2ada                      move.l    (a2)+,(a5)+
[000117c8] 2ada                      move.l    (a2)+,(a5)+
[000117ca] 2ada                      move.l    (a2)+,(a5)+
[000117cc] 51c9 ffe2                 dbf       d1,$000117B0
[000117d0] 7e00                      moveq.l   #0,d7
[000117d2] 1e1c                      move.b    (a4)+,d7
[000117d4] 4607                      not.b     d7
[000117d6] eb4f                      lsl.w     #5,d7
[000117d8] 45f6 7000                 lea.l     0(a6,d7.w),a2
[000117dc] 2ada                      move.l    (a2)+,(a5)+
[000117de] 2ada                      move.l    (a2)+,(a5)+
[000117e0] 2ada                      move.l    (a2)+,(a5)+
[000117e2] 2ada                      move.l    (a2)+,(a5)+
[000117e4] 2ada                      move.l    (a2)+,(a5)+
[000117e6] 2ada                      move.l    (a2)+,(a5)+
[000117e8] 2ada                      move.l    (a2)+,(a5)+
[000117ea] 2ada                      move.l    (a2)+,(a5)+
[000117ec] 51ce ffe2                 dbf       d6,$000117D0
[000117f0] 365f                      movea.w   (a7)+,a3
[000117f2] 3c02                      move.w    d2,d6
[000117f4] e84a                      lsr.w     #4,d2
[000117f6] 3800                      move.w    d0,d4
[000117f8] e84c                      lsr.w     #4,d4
[000117fa] 9444                      sub.w     d4,d2
[000117fc] 720f                      moveq.l   #15,d1
[000117fe] 3e06                      move.w    d6,d7
[00011800] 9e40                      sub.w     d0,d7
[00011802] de47                      add.w     d7,d7
[00011804] de47                      add.w     d7,d7
[00011806] 5847                      addq.w    #4,d7
[00011808] 96c7                      suba.w    d7,a3
[0001180a] c041                      and.w     d1,d0
[0001180c] d040                      add.w     d0,d0
[0001180e] d040                      add.w     d0,d0
[00011810] d0c0                      adda.w    d0,a0
[00011812] 5342                      subq.w    #1,d2
[00011814] 6a0c                      bpl.s     $00011822
[00011816] 5947                      subq.w    #4,d7
[00011818] 0a47 003c                 eori.w    #$003C,d7
[0001181c] 45fb 7072                 lea.l     $00011890(pc,d7.w),a2
[00011820] 6010                      bra.s     $00011832
[00011822] 45fb 0022                 lea.l     $00011846(pc,d0.w),a2
[00011826] cc41                      and.w     d1,d6
[00011828] b346                      eor.w     d1,d6
[0001182a] dc46                      add.w     d6,d6
[0001182c] dc46                      add.w     d6,d6
[0001182e] 4bfb 6060                 lea.l     $00011890(pc,d6.w),a5
[00011832] 2848                      movea.l   a0,a4
[00011834] 41e8 0040                 lea.l     64(a0),a0
[00011838] 51c9 0008                 dbf       d1,$00011842
[0001183c] 720f                      moveq.l   #15,d1
[0001183e] 41e8 fc00                 lea.l     -1024(a0),a0
[00011842] 3802                      move.w    d2,d4
[00011844] 4ed2                      jmp       (a2)
[00011846] 201c                      move.l    (a4)+,d0
[00011848] b199                      eor.l     d0,(a1)+
[0001184a] 201c                      move.l    (a4)+,d0
[0001184c] b199                      eor.l     d0,(a1)+
[0001184e] 201c                      move.l    (a4)+,d0
[00011850] b199                      eor.l     d0,(a1)+
[00011852] 201c                      move.l    (a4)+,d0
[00011854] b199                      eor.l     d0,(a1)+
[00011856] 201c                      move.l    (a4)+,d0
[00011858] b199                      eor.l     d0,(a1)+
[0001185a] 201c                      move.l    (a4)+,d0
[0001185c] b199                      eor.l     d0,(a1)+
[0001185e] 201c                      move.l    (a4)+,d0
[00011860] b199                      eor.l     d0,(a1)+
[00011862] 201c                      move.l    (a4)+,d0
[00011864] b199                      eor.l     d0,(a1)+
[00011866] 201c                      move.l    (a4)+,d0
[00011868] b199                      eor.l     d0,(a1)+
[0001186a] 201c                      move.l    (a4)+,d0
[0001186c] b199                      eor.l     d0,(a1)+
[0001186e] 201c                      move.l    (a4)+,d0
[00011870] b199                      eor.l     d0,(a1)+
[00011872] 201c                      move.l    (a4)+,d0
[00011874] b199                      eor.l     d0,(a1)+
[00011876] 201c                      move.l    (a4)+,d0
[00011878] b199                      eor.l     d0,(a1)+
[0001187a] 201c                      move.l    (a4)+,d0
[0001187c] b199                      eor.l     d0,(a1)+
[0001187e] 201c                      move.l    (a4)+,d0
[00011880] b199                      eor.l     d0,(a1)+
[00011882] 201c                      move.l    (a4)+,d0
[00011884] b199                      eor.l     d0,(a1)+
[00011886] 49ec ffc0                 lea.l     -64(a4),a4
[0001188a] 51cc ffba                 dbf       d4,$00011846
[0001188e] 4ed5                      jmp       (a5)
[00011890] 201c                      move.l    (a4)+,d0
[00011892] b199                      eor.l     d0,(a1)+
[00011894] 201c                      move.l    (a4)+,d0
[00011896] b199                      eor.l     d0,(a1)+
[00011898] 201c                      move.l    (a4)+,d0
[0001189a] b199                      eor.l     d0,(a1)+
[0001189c] 201c                      move.l    (a4)+,d0
[0001189e] b199                      eor.l     d0,(a1)+
[000118a0] 201c                      move.l    (a4)+,d0
[000118a2] b199                      eor.l     d0,(a1)+
[000118a4] 201c                      move.l    (a4)+,d0
[000118a6] b199                      eor.l     d0,(a1)+
[000118a8] 201c                      move.l    (a4)+,d0
[000118aa] b199                      eor.l     d0,(a1)+
[000118ac] 201c                      move.l    (a4)+,d0
[000118ae] b199                      eor.l     d0,(a1)+
[000118b0] 201c                      move.l    (a4)+,d0
[000118b2] b199                      eor.l     d0,(a1)+
[000118b4] 201c                      move.l    (a4)+,d0
[000118b6] b199                      eor.l     d0,(a1)+
[000118b8] 201c                      move.l    (a4)+,d0
[000118ba] b199                      eor.l     d0,(a1)+
[000118bc] 201c                      move.l    (a4)+,d0
[000118be] b199                      eor.l     d0,(a1)+
[000118c0] 201c                      move.l    (a4)+,d0
[000118c2] b199                      eor.l     d0,(a1)+
[000118c4] 201c                      move.l    (a4)+,d0
[000118c6] b199                      eor.l     d0,(a1)+
[000118c8] 201c                      move.l    (a4)+,d0
[000118ca] b199                      eor.l     d0,(a1)+
[000118cc] 201c                      move.l    (a4)+,d0
[000118ce] b199                      eor.l     d0,(a1)+
[000118d0] d2cb                      adda.w    a3,a1
[000118d2] 51cb ff5e                 dbf       d3,$00011832
[000118d6] 4e75                      rts
[000118d8] 9440                      sub.w     d0,d2
[000118da] 3202                      move.w    d2,d1
[000118dc] 5241                      addq.w    #1,d1
[000118de] d241                      add.w     d1,d1
[000118e0] d241                      add.w     d1,d1
[000118e2] 9c41                      sub.w     d1,d6
[000118e4] 700f                      moveq.l   #15,d0
[000118e6] c042                      and.w     d2,d0
[000118e8] e84a                      lsr.w     #4,d2
[000118ea] 0a40 000f                 eori.w    #$000F,d0
[000118ee] d040                      add.w     d0,d0
[000118f0] 41fb 0006                 lea.l     $000118F8(pc,d0.w),a0
[000118f4] 3002                      move.w    d2,d0
[000118f6] 4ed0                      jmp       (a0)
[000118f8] 4699                      not.l     (a1)+
[000118fa] 4699                      not.l     (a1)+
[000118fc] 4699                      not.l     (a1)+
[000118fe] 4699                      not.l     (a1)+
[00011900] 4699                      not.l     (a1)+
[00011902] 4699                      not.l     (a1)+
[00011904] 4699                      not.l     (a1)+
[00011906] 4699                      not.l     (a1)+
[00011908] 4699                      not.l     (a1)+
[0001190a] 4699                      not.l     (a1)+
[0001190c] 4699                      not.l     (a1)+
[0001190e] 4699                      not.l     (a1)+
[00011910] 4699                      not.l     (a1)+
[00011912] 4699                      not.l     (a1)+
[00011914] 4699                      not.l     (a1)+
[00011916] 4699                      not.l     (a1)+
[00011918] 51c8 ffde                 dbf       d0,$000118F8
[0001191c] d2c6                      adda.w    d6,a1
[0001191e] 51cb ffd4                 dbf       d3,$000118F4
[00011922] 4e75                      rts
[00011924] 9440                      sub.w     d0,d2
[00011926] 3f06                      move.w    d6,-(a7)
[00011928] e98e                      lsl.l     #4,d6
[0001192a] 2646                      movea.l   d6,a3
[0001192c] 2a48                      movea.l   a0,a5
[0001192e] 780f                      moveq.l   #15,d4
[00011930] 7c0f                      moveq.l   #15,d6
[00011932] c044                      and.w     d4,d0
[00011934] d26e 01b8                 add.w     440(a6),d1
[00011938] c244                      and.w     d4,d1
[0001193a] 671a                      beq.s     $00011956
[0001193c] 3e01                      move.w    d1,d7
[0001193e] bd47                      eor.w     d6,d7
[00011940] 3c01                      move.w    d1,d6
[00011942] 5346                      subq.w    #1,d6
[00011944] d241                      add.w     d1,d1
[00011946] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001194a] 321a                      move.w    (a2)+,d1
[0001194c] 4641                      not.w     d1
[0001194e] e179                      rol.w     d0,d1
[00011950] 3ac1                      move.w    d1,(a5)+
[00011952] 51cf fff6                 dbf       d7,$0001194A
[00011956] 321c                      move.w    (a4)+,d1
[00011958] 4641                      not.w     d1
[0001195a] e179                      rol.w     d0,d1
[0001195c] 3ac1                      move.w    d1,(a5)+
[0001195e] 51ce fff6                 dbf       d6,$00011956
[00011962] 603a                      bra.s     $0001199E
[00011964] 9440                      sub.w     d0,d2
[00011966] 3f06                      move.w    d6,-(a7)
[00011968] e98e                      lsl.l     #4,d6
[0001196a] 2646                      movea.l   d6,a3
[0001196c] 2a48                      movea.l   a0,a5
[0001196e] 780f                      moveq.l   #15,d4
[00011970] 7c0f                      moveq.l   #15,d6
[00011972] c044                      and.w     d4,d0
[00011974] d26e 01b8                 add.w     440(a6),d1
[00011978] c244                      and.w     d4,d1
[0001197a] 6718                      beq.s     $00011994
[0001197c] 3e01                      move.w    d1,d7
[0001197e] bd47                      eor.w     d6,d7
[00011980] 3c01                      move.w    d1,d6
[00011982] 5346                      subq.w    #1,d6
[00011984] d241                      add.w     d1,d1
[00011986] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001198a] 321a                      move.w    (a2)+,d1
[0001198c] e179                      rol.w     d0,d1
[0001198e] 3ac1                      move.w    d1,(a5)+
[00011990] 51cf fff8                 dbf       d7,$0001198A
[00011994] 321c                      move.w    (a4)+,d1
[00011996] e179                      rol.w     d0,d1
[00011998] 3ac1                      move.w    d1,(a5)+
[0001199a] 51ce fff8                 dbf       d6,$00011994
[0001199e] 2e05                      move.l    d5,d7
[000119a0] b644                      cmp.w     d4,d3
[000119a2] 6c02                      bge.s     $000119A6
[000119a4] 3803                      move.w    d3,d4
[000119a6] 4843                      swap      d3
[000119a8] 3604                      move.w    d4,d3
[000119aa] 347c 0040                 movea.w   #$0040,a2
[000119ae] 7c0f                      moveq.l   #15,d6
[000119b0] b446                      cmp.w     d6,d2
[000119b2] 6c02                      bge.s     $000119B6
[000119b4] 3c02                      move.w    d2,d6
[000119b6] 3846                      movea.w   d6,a4
[000119b8] 9446                      sub.w     d6,d2
[000119ba] 5246                      addq.w    #1,d6
[000119bc] dc46                      add.w     d6,d6
[000119be] dc46                      add.w     d6,d6
[000119c0] 96c6                      suba.w    d6,a3
[000119c2] 4843                      swap      d3
[000119c4] 3203                      move.w    d3,d1
[000119c6] e849                      lsr.w     #4,d1
[000119c8] 2a49                      movea.l   a1,a5
[000119ca] 3c0c                      move.w    a4,d6
[000119cc] 3010                      move.w    (a0),d0
[000119ce] d040                      add.w     d0,d0
[000119d0] 645e                      bcc.s     $00011A30
[000119d2] 3802                      move.w    d2,d4
[000119d4] d846                      add.w     d6,d4
[000119d6] e84c                      lsr.w     #4,d4
[000119d8] 3a04                      move.w    d4,d5
[000119da] e84c                      lsr.w     #4,d4
[000119dc] 4645                      not.w     d5
[000119de] 0245 000f                 andi.w    #$000F,d5
[000119e2] da45                      add.w     d5,d5
[000119e4] da45                      add.w     d5,d5
[000119e6] 2c4d                      movea.l   a5,a6
[000119e8] 4efb 5002                 jmp       $000119EC(pc,d5.w)
[000119ec] 2c87                      move.l    d7,(a6)
[000119ee] dcca                      adda.w    a2,a6
[000119f0] 2c87                      move.l    d7,(a6)
[000119f2] dcca                      adda.w    a2,a6
[000119f4] 2c87                      move.l    d7,(a6)
[000119f6] dcca                      adda.w    a2,a6
[000119f8] 2c87                      move.l    d7,(a6)
[000119fa] dcca                      adda.w    a2,a6
[000119fc] 2c87                      move.l    d7,(a6)
[000119fe] dcca                      adda.w    a2,a6
[00011a00] 2c87                      move.l    d7,(a6)
[00011a02] dcca                      adda.w    a2,a6
[00011a04] 2c87                      move.l    d7,(a6)
[00011a06] dcca                      adda.w    a2,a6
[00011a08] 2c87                      move.l    d7,(a6)
[00011a0a] dcca                      adda.w    a2,a6
[00011a0c] 2c87                      move.l    d7,(a6)
[00011a0e] dcca                      adda.w    a2,a6
[00011a10] 2c87                      move.l    d7,(a6)
[00011a12] dcca                      adda.w    a2,a6
[00011a14] 2c87                      move.l    d7,(a6)
[00011a16] dcca                      adda.w    a2,a6
[00011a18] 2c87                      move.l    d7,(a6)
[00011a1a] dcca                      adda.w    a2,a6
[00011a1c] 2c87                      move.l    d7,(a6)
[00011a1e] dcca                      adda.w    a2,a6
[00011a20] 2c87                      move.l    d7,(a6)
[00011a22] dcca                      adda.w    a2,a6
[00011a24] 2c87                      move.l    d7,(a6)
[00011a26] dcca                      adda.w    a2,a6
[00011a28] 2c87                      move.l    d7,(a6)
[00011a2a] dcca                      adda.w    a2,a6
[00011a2c] 51cc ffbe                 dbf       d4,$000119EC
[00011a30] 588d                      addq.l    #4,a5
[00011a32] 51ce ff9a                 dbf       d6,$000119CE
[00011a36] dbcb                      adda.l    a3,a5
[00011a38] 51c9 ff90                 dbf       d1,$000119CA
[00011a3c] 5488                      addq.l    #2,a0
[00011a3e] d2d7                      adda.w    (a7),a1
[00011a40] 5343                      subq.w    #1,d3
[00011a42] 4843                      swap      d3
[00011a44] 51cb ff7c                 dbf       d3,$000119C2
[00011a48] 548f                      addq.l    #2,a7
[00011a4a] 4e75                      rts
[00011a4c] 4e75                      rts
[00011a4e] 2278 044e                 movea.l   ($0000044E).w,a1
[00011a52] 3678 206e                 movea.w   ($0000206E).w,a3
[00011a56] 4a6e 01b2                 tst.w     434(a6)
[00011a5a] 6710                      beq.s     $00011A6C
[00011a5c] 946e 01b6                 sub.w     438(a6),d2
[00011a60] 966e 01b8                 sub.w     440(a6),d3
[00011a64] 226e 01ae                 movea.l   430(a6),a1
[00011a68] 366e 01b2                 movea.w   434(a6),a3
[00011a6c] 426e 01ec                 clr.w     492(a6)
[00011a70] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[00011a76] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[00011a7c] 426e 01c8                 clr.w     456(a6)
[00011a80] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00011a86] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[00011a8c] 661c                      bne.s     $00011AAA
[00011a8e] 426e 01ea                 clr.w     490(a6)
[00011a92] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[00011a98] 6010                      bra.s     $00011AAA
[00011a9a] 206e 01c2                 movea.l   450(a6),a0
[00011a9e] 226e 01d6                 movea.l   470(a6),a1
[00011aa2] 346e 01c6                 movea.w   454(a6),a2
[00011aa6] 366e 01da                 movea.w   474(a6),a3
[00011aaa] 3c0a                      move.w    a2,d6
[00011aac] 3e0b                      move.w    a3,d7
[00011aae] c3c6                      muls.w    d6,d1
[00011ab0] d1c1                      adda.l    d1,a0
[00011ab2] 3200                      move.w    d0,d1
[00011ab4] e849                      lsr.w     #4,d1
[00011ab6] d241                      add.w     d1,d1
[00011ab8] d0c1                      adda.w    d1,a0
[00011aba] c7c7                      muls.w    d7,d3
[00011abc] d3c3                      adda.l    d3,a1
[00011abe] d442                      add.w     d2,d2
[00011ac0] d442                      add.w     d2,d2
[00011ac2] d2c2                      adda.w    d2,a1
[00011ac4] 720f                      moveq.l   #15,d1
[00011ac6] c041                      and.w     d1,d0
[00011ac8] b141                      eor.w     d0,d1
[00011aca] b841                      cmp.w     d1,d4
[00011acc] 6c02                      bge.s     $00011AD0
[00011ace] 3204                      move.w    d4,d1
[00011ad0] 4840                      swap      d0
[00011ad2] 3001                      move.w    d1,d0
[00011ad4] 4840                      swap      d0
[00011ad6] 3400                      move.w    d0,d2
[00011ad8] d444                      add.w     d4,d2
[00011ada] e84a                      lsr.w     #4,d2
[00011adc] d442                      add.w     d2,d2
[00011ade] 5442                      addq.w    #2,d2
[00011ae0] 94c2                      suba.w    d2,a2
[00011ae2] 3404                      move.w    d4,d2
[00011ae4] d442                      add.w     d2,d2
[00011ae6] d442                      add.w     d2,d2
[00011ae8] 5842                      addq.w    #4,d2
[00011aea] 96c2                      suba.w    d2,a3
[00011aec] 9841                      sub.w     d1,d4
[00011aee] 49ee 0658                 lea.l     1624(a6),a4
[00011af2] 3c2e 01ea                 move.w    490(a6),d6
[00011af6] dc46                      add.w     d6,d6
[00011af8] dc46                      add.w     d6,d6
[00011afa] 2c34 6000                 move.l    0(a4,d6.w),d6
[00011afe] 3e2e 01ec                 move.w    492(a6),d7
[00011b02] de47                      add.w     d7,d7
[00011b04] de47                      add.w     d7,d7
[00011b06] 2e34 7000                 move.l    0(a4,d7.w),d7
[00011b0a] 7403                      moveq.l   #3,d2
[00011b0c] c46e 01ee                 and.w     494(a6),d2
[00011b10] d442                      add.w     d2,d2
[00011b12] 343b 2006                 move.w    $00011B1A(pc,d2.w),d2
[00011b16] 4efb 2002                 jmp       $00011B1A(pc,d2.w)
J3:
[00011b1a] 0008                      dc.w $0008   ; $00011b22-$00011b1a
[00011b1c] 003e                      dc.w $003e   ; $00011b58-$00011b1a
[00011b1e] 0074                      dc.w $0074   ; $00011b8e-$00011b1a
[00011b20] 00aa                      dc.w $00aa   ; $00011bc4-$00011b1a
[00011b22] 3604                      move.w    d4,d3
[00011b24] 3418                      move.w    (a0)+,d2
[00011b26] e17a                      rol.w     d0,d2
[00011b28] 2200                      move.l    d0,d1
[00011b2a] 4841                      swap      d1
[00011b2c] 6002                      bra.s     $00011B30
[00011b2e] 3418                      move.w    (a0)+,d2
[00011b30] d442                      add.w     d2,d2
[00011b32] 6408                      bcc.s     $00011B3C
[00011b34] 22c6                      move.l    d6,(a1)+
[00011b36] 51c9 fff8                 dbf       d1,$00011B30
[00011b3a] 6006                      bra.s     $00011B42
[00011b3c] 22c7                      move.l    d7,(a1)+
[00011b3e] 51c9 fff0                 dbf       d1,$00011B30
[00011b42] 720f                      moveq.l   #15,d1
[00011b44] 5343                      subq.w    #1,d3
[00011b46] 9641                      sub.w     d1,d3
[00011b48] 6ae4                      bpl.s     $00011B2E
[00011b4a] d243                      add.w     d3,d1
[00011b4c] 6ae0                      bpl.s     $00011B2E
[00011b4e] d0ca                      adda.w    a2,a0
[00011b50] d2cb                      adda.w    a3,a1
[00011b52] 51cd ffce                 dbf       d5,$00011B22
[00011b56] 4e75                      rts
[00011b58] 3604                      move.w    d4,d3
[00011b5a] 3418                      move.w    (a0)+,d2
[00011b5c] e17a                      rol.w     d0,d2
[00011b5e] 2200                      move.l    d0,d1
[00011b60] 4841                      swap      d1
[00011b62] 6002                      bra.s     $00011B66
[00011b64] 3418                      move.w    (a0)+,d2
[00011b66] d442                      add.w     d2,d2
[00011b68] 6408                      bcc.s     $00011B72
[00011b6a] 22c6                      move.l    d6,(a1)+
[00011b6c] 51c9 fff8                 dbf       d1,$00011B66
[00011b70] 6006                      bra.s     $00011B78
[00011b72] 5889                      addq.l    #4,a1
[00011b74] 51c9 fff0                 dbf       d1,$00011B66
[00011b78] 720f                      moveq.l   #15,d1
[00011b7a] 5343                      subq.w    #1,d3
[00011b7c] 9641                      sub.w     d1,d3
[00011b7e] 6ae4                      bpl.s     $00011B64
[00011b80] d243                      add.w     d3,d1
[00011b82] 6ae0                      bpl.s     $00011B64
[00011b84] d0ca                      adda.w    a2,a0
[00011b86] d2cb                      adda.w    a3,a1
[00011b88] 51cd ffce                 dbf       d5,$00011B58
[00011b8c] 4e75                      rts
[00011b8e] 3604                      move.w    d4,d3
[00011b90] 3418                      move.w    (a0)+,d2
[00011b92] e17a                      rol.w     d0,d2
[00011b94] 2200                      move.l    d0,d1
[00011b96] 4841                      swap      d1
[00011b98] 6002                      bra.s     $00011B9C
[00011b9a] 3418                      move.w    (a0)+,d2
[00011b9c] d442                      add.w     d2,d2
[00011b9e] 6408                      bcc.s     $00011BA8
[00011ba0] 4699                      not.l     (a1)+
[00011ba2] 51c9 fff8                 dbf       d1,$00011B9C
[00011ba6] 6006                      bra.s     $00011BAE
[00011ba8] 5889                      addq.l    #4,a1
[00011baa] 51c9 fff0                 dbf       d1,$00011B9C
[00011bae] 720f                      moveq.l   #15,d1
[00011bb0] 5343                      subq.w    #1,d3
[00011bb2] 9641                      sub.w     d1,d3
[00011bb4] 6ae4                      bpl.s     $00011B9A
[00011bb6] d243                      add.w     d3,d1
[00011bb8] 6ae0                      bpl.s     $00011B9A
[00011bba] d0ca                      adda.w    a2,a0
[00011bbc] d2cb                      adda.w    a3,a1
[00011bbe] 51cd ffce                 dbf       d5,$00011B8E
[00011bc2] 4e75                      rts
[00011bc4] 3604                      move.w    d4,d3
[00011bc6] 3418                      move.w    (a0)+,d2
[00011bc8] e17a                      rol.w     d0,d2
[00011bca] 2200                      move.l    d0,d1
[00011bcc] 4841                      swap      d1
[00011bce] 6002                      bra.s     $00011BD2
[00011bd0] 3418                      move.w    (a0)+,d2
[00011bd2] d442                      add.w     d2,d2
[00011bd4] 6508                      bcs.s     $00011BDE
[00011bd6] 22c7                      move.l    d7,(a1)+
[00011bd8] 51c9 fff8                 dbf       d1,$00011BD2
[00011bdc] 6006                      bra.s     $00011BE4
[00011bde] 5889                      addq.l    #4,a1
[00011be0] 51c9 fff0                 dbf       d1,$00011BD2
[00011be4] 720f                      moveq.l   #15,d1
[00011be6] 5343                      subq.w    #1,d3
[00011be8] 9641                      sub.w     d1,d3
[00011bea] 6ae4                      bpl.s     $00011BD0
[00011bec] d243                      add.w     d3,d1
[00011bee] 6ae0                      bpl.s     $00011BD0
[00011bf0] d0ca                      adda.w    a2,a0
[00011bf2] d2cb                      adda.w    a3,a1
[00011bf4] 51cd ffce                 dbf       d5,$00011BC4
[00011bf8] 4e75                      rts
[00011bfa] bc44                      cmp.w     d4,d6
[00011bfc] be45                      cmp.w     d5,d7
[00011bfe] 08ae 0004 01ef            bclr      #4,495(a6)
[00011c04] 6600 fe94                 bne       $00011A9A
[00011c08] 7e0f                      moveq.l   #15,d7
[00011c0a] ce6e 01ee                 and.w     494(a6),d7
[00011c0e] 206e 01c2                 movea.l   450(a6),a0
[00011c12] 226e 01d6                 movea.l   470(a6),a1
[00011c16] 346e 01c6                 movea.w   454(a6),a2
[00011c1a] 366e 01da                 movea.w   474(a6),a3
[00011c1e] 3c2e 01c8                 move.w    456(a6),d6
[00011c22] bc6e 01dc                 cmp.w     476(a6),d6
[00011c26] 6600 00a8                 bne       $00011CD0
[00011c2a] 48c0                      ext.l     d0
[00011c2c] 48c2                      ext.l     d2
[00011c2e] 3c0a                      move.w    a2,d6
[00011c30] c2c6                      mulu.w    d6,d1
[00011c32] d080                      add.l     d0,d0
[00011c34] d080                      add.l     d0,d0
[00011c36] d280                      add.l     d0,d1
[00011c38] e480                      asr.l     #2,d0
[00011c3a] d1c1                      adda.l    d1,a0
[00011c3c] 3c0b                      move.w    a3,d6
[00011c3e] c6c6                      mulu.w    d6,d3
[00011c40] d482                      add.l     d2,d2
[00011c42] d482                      add.l     d2,d2
[00011c44] d682                      add.l     d2,d3
[00011c46] e482                      asr.l     #2,d2
[00011c48] d3c3                      adda.l    d3,a1
[00011c4a] b1c9                      cmpa.l    a1,a0
[00011c4c] 6200 02c4                 bhi       $00011F12
[00011c50] 3c3c 8401                 move.w    #$8401,d6
[00011c54] 0f06                      btst      d7,d6
[00011c56] 6600 02ba                 bne       $00011F12
[00011c5a] 3c0a                      move.w    a2,d6
[00011c5c] ccc5                      mulu.w    d5,d6
[00011c5e] 2848                      movea.l   a0,a4
[00011c60] d9c6                      adda.l    d6,a4
[00011c62] d844                      add.w     d4,d4
[00011c64] d844                      add.w     d4,d4
[00011c66] d8c4                      adda.w    d4,a4
[00011c68] e44c                      lsr.w     #2,d4
[00011c6a] b9c9                      cmpa.l    a1,a4
[00011c6c] 6500 02a4                 bcs       $00011F12
[00011c70] 588c                      addq.l    #4,a4
[00011c72] d28c                      add.l     a4,d1
[00011c74] 9288                      sub.l     a0,d1
[00011c76] 2a49                      movea.l   a1,a5
[00011c78] 3c0b                      move.w    a3,d6
[00011c7a] ccc5                      mulu.w    d5,d6
[00011c7c] dbc6                      adda.l    d6,a5
[00011c7e] d844                      add.w     d4,d4
[00011c80] d844                      add.w     d4,d4
[00011c82] dac4                      adda.w    d4,a5
[00011c84] e44c                      lsr.w     #2,d4
[00011c86] 588d                      addq.l    #4,a5
[00011c88] d68d                      add.l     a5,d3
[00011c8a] 9689                      sub.l     a1,d3
[00011c8c] c14c                      exg       a0,a4
[00011c8e] c34d                      exg       a1,a5
[00011c90] 3c04                      move.w    d4,d6
[00011c92] 5246                      addq.w    #1,d6
[00011c94] dc46                      add.w     d6,d6
[00011c96] dc46                      add.w     d6,d6
[00011c98] 94c6                      suba.w    d6,a2
[00011c9a] 96c6                      suba.w    d6,a3
[00011c9c] 7203                      moveq.l   #3,d1
[00011c9e] c244                      and.w     d4,d1
[00011ca0] 0a41 0003                 eori.w    #$0003,d1
[00011ca4] d241                      add.w     d1,d1
[00011ca6] e444                      asr.w     #2,d4
[00011ca8] 4a44                      tst.w     d4
[00011caa] 6a04                      bpl.s     $00011CB0
[00011cac] 7800                      moveq.l   #0,d4
[00011cae] 7208                      moveq.l   #8,d1
[00011cb0] de47                      add.w     d7,d7
[00011cb2] de47                      add.w     d7,d7
[00011cb4] 49fb 701c                 lea.l     $00011CD2(pc,d7.w),a4
[00011cb8] 3e1c                      move.w    (a4)+,d7
[00011cba] 670e                      beq.s     $00011CCA
[00011cbc] 5347                      subq.w    #1,d7
[00011cbe] 6708                      beq.s     $00011CC8
[00011cc0] 3e01                      move.w    d1,d7
[00011cc2] d241                      add.w     d1,d1
[00011cc4] d247                      add.w     d7,d1
[00011cc6] 6002                      bra.s     $00011CCA
[00011cc8] d241                      add.w     d1,d1
[00011cca] 3e1c                      move.w    (a4)+,d7
[00011ccc] 4efb 7004                 jmp       $00011CD2(pc,d7.w)
[00011cd0] 4e75                      rts
[00011cd2] 0000 0380                 ori.b     #$80,d0
[00011cd6] 0001 0040                 ori.b     #$40,d1
[00011cda] 0002 0066                 ori.b     #$66,d2
[00011cde] 0000 0094                 ori.b     #$94,d0
[00011ce2] 0002 00b2                 ori.b     #$B2,d2
[00011ce6] 0000 00de                 ori.b     #$DE,d0
[00011cea] 0001 00e0                 ori.b     #$E0,d1
[00011cee] 0001 0106                 ori.b     #$06,d1
[00011cf2] 0002 012c                 ori.b     #$2C,d2
[00011cf6] 0002 015a                 ori.b     #$5A,d2
[00011cfa] 0000 04e6                 ori.b     #$E6,d0
[00011cfe] 0002 0188                 ori.b     #$88,d2
[00011d02] 0002 01b6                 ori.b     #$B6,d2
[00011d06] 0002 01e4                 ori.b     #$E4,d2
[00011d0a] 0002 0212                 ori.b     #$12,d2
[00011d0e] 0000 037c                 ori.b     #$7C,d0
[00011d12] 4bfb 1006                 lea.l     $00011D1A(pc,d1.w),a5
[00011d16] 3c04                      move.w    d4,d6
[00011d18] 4ed5                      jmp       (a5)
[00011d1a] 2020                      move.l    -(a0),d0
[00011d1c] c1a1                      and.l     d0,-(a1)
[00011d1e] 2020                      move.l    -(a0),d0
[00011d20] c1a1                      and.l     d0,-(a1)
[00011d22] 2020                      move.l    -(a0),d0
[00011d24] c1a1                      and.l     d0,-(a1)
[00011d26] 2020                      move.l    -(a0),d0
[00011d28] c1a1                      and.l     d0,-(a1)
[00011d2a] 51ce ffee                 dbf       d6,$00011D1A
[00011d2e] 90ca                      suba.w    a2,a0
[00011d30] 92cb                      suba.w    a3,a1
[00011d32] 51cd ffe2                 dbf       d5,$00011D16
[00011d36] 4e75                      rts
[00011d38] 4bfb 1006                 lea.l     $00011D40(pc,d1.w),a5
[00011d3c] 3c04                      move.w    d4,d6
[00011d3e] 4ed5                      jmp       (a5)
[00011d40] 2020                      move.l    -(a0),d0
[00011d42] 4691                      not.l     (a1)
[00011d44] c1a1                      and.l     d0,-(a1)
[00011d46] 2020                      move.l    -(a0),d0
[00011d48] 4691                      not.l     (a1)
[00011d4a] c1a1                      and.l     d0,-(a1)
[00011d4c] 2020                      move.l    -(a0),d0
[00011d4e] 4691                      not.l     (a1)
[00011d50] c1a1                      and.l     d0,-(a1)
[00011d52] 2020                      move.l    -(a0),d0
[00011d54] 4691                      not.l     (a1)
[00011d56] c1a1                      and.l     d0,-(a1)
[00011d58] 51ce ffe6                 dbf       d6,$00011D40
[00011d5c] 90ca                      suba.w    a2,a0
[00011d5e] 92cb                      suba.w    a3,a1
[00011d60] 51cd ffda                 dbf       d5,$00011D3C
[00011d64] 4e75                      rts
[00011d66] 4bfb 1006                 lea.l     $00011D6E(pc,d1.w),a5
[00011d6a] 3c04                      move.w    d4,d6
[00011d6c] 4ed5                      jmp       (a5)
[00011d6e] 2320                      move.l    -(a0),-(a1)
[00011d70] 2320                      move.l    -(a0),-(a1)
[00011d72] 2320                      move.l    -(a0),-(a1)
[00011d74] 2320                      move.l    -(a0),-(a1)
[00011d76] 51ce fff6                 dbf       d6,$00011D6E
[00011d7a] 90ca                      suba.w    a2,a0
[00011d7c] 92cb                      suba.w    a3,a1
[00011d7e] 51cd ffea                 dbf       d5,$00011D6A
[00011d82] 4e75                      rts
[00011d84] 4bfb 1006                 lea.l     $00011D8C(pc,d1.w),a5
[00011d88] 3c04                      move.w    d4,d6
[00011d8a] 4ed5                      jmp       (a5)
[00011d8c] 2020                      move.l    -(a0),d0
[00011d8e] 4680                      not.l     d0
[00011d90] c1a1                      and.l     d0,-(a1)
[00011d92] 2020                      move.l    -(a0),d0
[00011d94] 4680                      not.l     d0
[00011d96] c1a1                      and.l     d0,-(a1)
[00011d98] 2020                      move.l    -(a0),d0
[00011d9a] 4680                      not.l     d0
[00011d9c] c1a1                      and.l     d0,-(a1)
[00011d9e] 2020                      move.l    -(a0),d0
[00011da0] 4680                      not.l     d0
[00011da2] c1a1                      and.l     d0,-(a1)
[00011da4] 51ce ffe6                 dbf       d6,$00011D8C
[00011da8] 90ca                      suba.w    a2,a0
[00011daa] 92cb                      suba.w    a3,a1
[00011dac] 51cd ffda                 dbf       d5,$00011D88
[00011db0] 4e75                      rts
[00011db2] 4bfb 1006                 lea.l     $00011DBA(pc,d1.w),a5
[00011db6] 3c04                      move.w    d4,d6
[00011db8] 4ed5                      jmp       (a5)
[00011dba] 2020                      move.l    -(a0),d0
[00011dbc] b1a1                      eor.l     d0,-(a1)
[00011dbe] 2020                      move.l    -(a0),d0
[00011dc0] b1a1                      eor.l     d0,-(a1)
[00011dc2] 2020                      move.l    -(a0),d0
[00011dc4] b1a1                      eor.l     d0,-(a1)
[00011dc6] 2020                      move.l    -(a0),d0
[00011dc8] b1a1                      eor.l     d0,-(a1)
[00011dca] 51ce ffee                 dbf       d6,$00011DBA
[00011dce] 90ca                      suba.w    a2,a0
[00011dd0] 92cb                      suba.w    a3,a1
[00011dd2] 51cd ffe2                 dbf       d5,$00011DB6
[00011dd6] 4e75                      rts
[00011dd8] 4bfb 1006                 lea.l     $00011DE0(pc,d1.w),a5
[00011ddc] 3c04                      move.w    d4,d6
[00011dde] 4ed5                      jmp       (a5)
[00011de0] 2020                      move.l    -(a0),d0
[00011de2] 81a1                      or.l      d0,-(a1)
[00011de4] 2020                      move.l    -(a0),d0
[00011de6] 81a1                      or.l      d0,-(a1)
[00011de8] 2020                      move.l    -(a0),d0
[00011dea] 81a1                      or.l      d0,-(a1)
[00011dec] 2020                      move.l    -(a0),d0
[00011dee] 81a1                      or.l      d0,-(a1)
[00011df0] 51ce ffee                 dbf       d6,$00011DE0
[00011df4] 90ca                      suba.w    a2,a0
[00011df6] 92cb                      suba.w    a3,a1
[00011df8] 51cd ffe2                 dbf       d5,$00011DDC
[00011dfc] 4e75                      rts
[00011dfe] 4bfb 1006                 lea.l     $00011E06(pc,d1.w),a5
[00011e02] 3c04                      move.w    d4,d6
[00011e04] 4ed5                      jmp       (a5)
[00011e06] 2020                      move.l    -(a0),d0
[00011e08] 8191                      or.l      d0,(a1)
[00011e0a] 46a1                      not.l     -(a1)
[00011e0c] 2020                      move.l    -(a0),d0
[00011e0e] 8191                      or.l      d0,(a1)
[00011e10] 46a1                      not.l     -(a1)
[00011e12] 2020                      move.l    -(a0),d0
[00011e14] 8191                      or.l      d0,(a1)
[00011e16] 46a1                      not.l     -(a1)
[00011e18] 2020                      move.l    -(a0),d0
[00011e1a] 8191                      or.l      d0,(a1)
[00011e1c] 46a1                      not.l     -(a1)
[00011e1e] 51ce ffe6                 dbf       d6,$00011E06
[00011e22] 90ca                      suba.w    a2,a0
[00011e24] 92cb                      suba.w    a3,a1
[00011e26] 51cd ffda                 dbf       d5,$00011E02
[00011e2a] 4e75                      rts
[00011e2c] 4bfb 1006                 lea.l     $00011E34(pc,d1.w),a5
[00011e30] 3c04                      move.w    d4,d6
[00011e32] 4ed5                      jmp       (a5)
[00011e34] 2020                      move.l    -(a0),d0
[00011e36] b191                      eor.l     d0,(a1)
[00011e38] 46a1                      not.l     -(a1)
[00011e3a] 2020                      move.l    -(a0),d0
[00011e3c] b191                      eor.l     d0,(a1)
[00011e3e] 46a1                      not.l     -(a1)
[00011e40] 2020                      move.l    -(a0),d0
[00011e42] b191                      eor.l     d0,(a1)
[00011e44] 46a1                      not.l     -(a1)
[00011e46] 2020                      move.l    -(a0),d0
[00011e48] b191                      eor.l     d0,(a1)
[00011e4a] 46a1                      not.l     -(a1)
[00011e4c] 51ce ffe6                 dbf       d6,$00011E34
[00011e50] 90ca                      suba.w    a2,a0
[00011e52] 92cb                      suba.w    a3,a1
[00011e54] 51cd ffda                 dbf       d5,$00011E30
[00011e58] 4e75                      rts
[00011e5a] 4bfb 1006                 lea.l     $00011E62(pc,d1.w),a5
[00011e5e] 3c04                      move.w    d4,d6
[00011e60] 4ed5                      jmp       (a5)
[00011e62] 4691                      not.l     (a1)
[00011e64] 2020                      move.l    -(a0),d0
[00011e66] 81a1                      or.l      d0,-(a1)
[00011e68] 4691                      not.l     (a1)
[00011e6a] 2020                      move.l    -(a0),d0
[00011e6c] 81a1                      or.l      d0,-(a1)
[00011e6e] 4691                      not.l     (a1)
[00011e70] 2020                      move.l    -(a0),d0
[00011e72] 81a1                      or.l      d0,-(a1)
[00011e74] 4691                      not.l     (a1)
[00011e76] 2020                      move.l    -(a0),d0
[00011e78] 81a1                      or.l      d0,-(a1)
[00011e7a] 51ce ffe6                 dbf       d6,$00011E62
[00011e7e] 90ca                      suba.w    a2,a0
[00011e80] 92cb                      suba.w    a3,a1
[00011e82] 51cd ffda                 dbf       d5,$00011E5E
[00011e86] 4e75                      rts
[00011e88] 4bfb 1006                 lea.l     $00011E90(pc,d1.w),a5
[00011e8c] 3c04                      move.w    d4,d6
[00011e8e] 4ed5                      jmp       (a5)
[00011e90] 2020                      move.l    -(a0),d0
[00011e92] 4680                      not.l     d0
[00011e94] 2300                      move.l    d0,-(a1)
[00011e96] 2020                      move.l    -(a0),d0
[00011e98] 4680                      not.l     d0
[00011e9a] 2300                      move.l    d0,-(a1)
[00011e9c] 2020                      move.l    -(a0),d0
[00011e9e] 4680                      not.l     d0
[00011ea0] 2300                      move.l    d0,-(a1)
[00011ea2] 2020                      move.l    -(a0),d0
[00011ea4] 4680                      not.l     d0
[00011ea6] 2300                      move.l    d0,-(a1)
[00011ea8] 51ce ffe6                 dbf       d6,$00011E90
[00011eac] 90ca                      suba.w    a2,a0
[00011eae] 92cb                      suba.w    a3,a1
[00011eb0] 51cd ffda                 dbf       d5,$00011E8C
[00011eb4] 4e75                      rts
[00011eb6] 4bfb 1006                 lea.l     $00011EBE(pc,d1.w),a5
[00011eba] 3c04                      move.w    d4,d6
[00011ebc] 4ed5                      jmp       (a5)
[00011ebe] 2020                      move.l    -(a0),d0
[00011ec0] 4680                      not.l     d0
[00011ec2] 81a1                      or.l      d0,-(a1)
[00011ec4] 2020                      move.l    -(a0),d0
[00011ec6] 4680                      not.l     d0
[00011ec8] 81a1                      or.l      d0,-(a1)
[00011eca] 2020                      move.l    -(a0),d0
[00011ecc] 4680                      not.l     d0
[00011ece] 81a1                      or.l      d0,-(a1)
[00011ed0] 2020                      move.l    -(a0),d0
[00011ed2] 4680                      not.l     d0
[00011ed4] 81a1                      or.l      d0,-(a1)
[00011ed6] 51ce ffe6                 dbf       d6,$00011EBE
[00011eda] 90ca                      suba.w    a2,a0
[00011edc] 92cb                      suba.w    a3,a1
[00011ede] 51cd ffda                 dbf       d5,$00011EBA
[00011ee2] 4e75                      rts
[00011ee4] 4bfb 1006                 lea.l     $00011EEC(pc,d1.w),a5
[00011ee8] 3c04                      move.w    d4,d6
[00011eea] 4ed5                      jmp       (a5)
[00011eec] 2020                      move.l    -(a0),d0
[00011eee] c191                      and.l     d0,(a1)
[00011ef0] 46a1                      not.l     -(a1)
[00011ef2] 2020                      move.l    -(a0),d0
[00011ef4] c191                      and.l     d0,(a1)
[00011ef6] 46a1                      not.l     -(a1)
[00011ef8] 2020                      move.l    -(a0),d0
[00011efa] c191                      and.l     d0,(a1)
[00011efc] 46a1                      not.l     -(a1)
[00011efe] 2020                      move.l    -(a0),d0
[00011f00] c191                      and.l     d0,(a1)
[00011f02] 46a1                      not.l     -(a1)
[00011f04] 51ce ffe6                 dbf       d6,$00011EEC
[00011f08] 90ca                      suba.w    a2,a0
[00011f0a] 92cb                      suba.w    a3,a1
[00011f0c] 51cd ffda                 dbf       d5,$00011EE8
[00011f10] 4e75                      rts
[00011f12] be7c 0003                 cmp.w     #$0003,d7
[00011f16] 6600 00b6                 bne       $00011FCE
[00011f1a] 323a 0386                 move.w    $000122A2(pc),d1
[00011f1e] 6700 00ae                 beq       $00011FCE
[00011f22] b87c 000f                 cmp.w     #$000F,d4
[00011f26] 6f00 00a6                 ble       $00011FCE
[00011f2a] 7c0f                      moveq.l   #15,d6
[00011f2c] 3208                      move.w    a0,d1
[00011f2e] 3609                      move.w    a1,d3
[00011f30] c246                      and.w     d6,d1
[00011f32] c646                      and.w     d6,d3
[00011f34] b641                      cmp.w     d1,d3
[00011f36] 6600 0096                 bne       $00011FCE
[00011f3a] 3e04                      move.w    d4,d7
[00011f3c] 5247                      addq.w    #1,d7
[00011f3e] de47                      add.w     d7,d7
[00011f40] de47                      add.w     d7,d7
[00011f42] 94c7                      suba.w    d7,a2
[00011f44] 96c7                      suba.w    d7,a3
[00011f46] 7c03                      moveq.l   #3,d6
[00011f48] e449                      lsr.w     #2,d1
[00011f4a] 3001                      move.w    d1,d0
[00011f4c] 6604                      bne.s     $00011F52
[00011f4e] 70ff                      moveq.l   #-1,d0
[00011f50] 6008                      bra.s     $00011F5A
[00011f52] 4640                      not.w     d0
[00011f54] c046                      and.w     d6,d0
[00011f56] 9840                      sub.w     d0,d4
[00011f58] 5344                      subq.w    #1,d4
[00011f5a] 3404                      move.w    d4,d2
[00011f5c] e44c                      lsr.w     #2,d4
[00011f5e] 5344                      subq.w    #1,d4
[00011f60] c446                      and.w     d6,d2
[00011f62] b446                      cmp.w     d6,d2
[00011f64] 6640                      bne.s     $00011FA6
[00011f66] 74ff                      moveq.l   #-1,d2
[00011f68] 5244                      addq.w    #1,d4
[00011f6a] b440                      cmp.w     d0,d2
[00011f6c] 6638                      bne.s     $00011FA6
[00011f6e] 5245                      addq.w    #1,d5
[00011f70] 601a                      bra.s     $00011F8C
[00011f72] 0000 0000                 ori.b     #$00,d0
[00011f76] 0000 0000                 ori.b     #$00,d0
[00011f7a] 0000 0000                 ori.b     #$00,d0
[00011f7e] 0000 f620                 ori.b     #$20,d0
[00011f82] 9000                      sub.b     d0,d0
[00011f84] 51ce fffa                 dbf       d6,$00011F80
[00011f88] d0ca                      adda.w    a2,a0
[00011f8a] d2cb                      adda.w    a3,a1
[00011f8c] 3c04                      move.w    d4,d6
[00011f8e] 51cd fff0                 dbf       d5,$00011F80
[00011f92] 4e75                      rts
[00011f94] 0000 0000                 ori.b     #$00,d0
[00011f98] 0000 0000                 ori.b     #$00,d0
[00011f9c] 0000 0000                 ori.b     #$00,d0
[00011fa0] 4e71                      nop
[00011fa2] 4e71                      nop
[00011fa4] 4e71                      nop
[00011fa6] 3c00                      move.w    d0,d6
[00011fa8] 6b06                      bmi.s     $00011FB0
[00011faa] 22d8                      move.l    (a0)+,(a1)+
[00011fac] 51ce fffc                 dbf       d6,$00011FAA
[00011fb0] 3c04                      move.w    d4,d6
[00011fb2] f620 9000                 move16    (a0)+,(a1)+
[00011fb6] 51ce fffa                 dbf       d6,$00011FB2
[00011fba] 3c02                      move.w    d2,d6
[00011fbc] 6b06                      bmi.s     $00011FC4
[00011fbe] 22d8                      move.l    (a0)+,(a1)+
[00011fc0] 51ce fffc                 dbf       d6,$00011FBE
[00011fc4] d0ca                      adda.w    a2,a0
[00011fc6] d2cb                      adda.w    a3,a1
[00011fc8] 51cd ffdc                 dbf       d5,$00011FA6
[00011fcc] 4e75                      rts
[00011fce] 3c04                      move.w    d4,d6
[00011fd0] 5246                      addq.w    #1,d6
[00011fd2] dc46                      add.w     d6,d6
[00011fd4] dc46                      add.w     d6,d6
[00011fd6] 94c6                      suba.w    d6,a2
[00011fd8] 96c6                      suba.w    d6,a3
[00011fda] 7203                      moveq.l   #3,d1
[00011fdc] c244                      and.w     d4,d1
[00011fde] 0a41 0003                 eori.w    #$0003,d1
[00011fe2] d241                      add.w     d1,d1
[00011fe4] e444                      asr.w     #2,d4
[00011fe6] 4a44                      tst.w     d4
[00011fe8] 6a04                      bpl.s     $00011FEE
[00011fea] 7800                      moveq.l   #0,d4
[00011fec] 7208                      moveq.l   #8,d1
[00011fee] de47                      add.w     d7,d7
[00011ff0] de47                      add.w     d7,d7
[00011ff2] 49fb 701a                 lea.l     $0001200E(pc,d7.w),a4
[00011ff6] 3e1c                      move.w    (a4)+,d7
[00011ff8] 670e                      beq.s     $00012008
[00011ffa] 5347                      subq.w    #1,d7
[00011ffc] 6708                      beq.s     $00012006
[00011ffe] 3e01                      move.w    d1,d7
[00012000] d241                      add.w     d1,d1
[00012002] d247                      add.w     d7,d1
[00012004] 6002                      bra.s     $00012008
[00012006] d241                      add.w     d1,d1
[00012008] 3e1c                      move.w    (a4)+,d7
[0001200a] 4efb 7002                 jmp       $0001200E(pc,d7.w)
[0001200e] 0000 0044                 ori.b     #$44,d0
[00012012] 0001 0062                 ori.b     #$62,d1
[00012016] 0002 0088                 ori.b     #$88,d2
[0001201a] 0000 00b6                 ori.b     #$B6,d0
[0001201e] 0002 00d4                 ori.b     #$D4,d2
[00012022] 0000 fda2                 ori.b     #$A2,d0
[00012026] 0001 0102                 ori.b     #$02,d1
[0001202a] 0001 0128                 ori.b     #$28,d1
[0001202e] 0002 014e                 ori.b     #$4E,d2
[00012032] 0002 017c                 ori.b     #$7C,d2
[00012036] 0000 01aa                 ori.b     #$AA,d0
[0001203a] 0002 01c6                 ori.b     #$C6,d2
[0001203e] 0002 01f4                 ori.b     #$F4,d2
[00012042] 0002 0222                 ori.b     #$22,d2
[00012046] 0002 0250                 ori.b     #$50,d2
[0001204a] 0000 0040                 ori.b     #$40,d0
[0001204e] 7e00                      moveq.l   #0,d7
[00012050] 6002                      bra.s     $00012054
[00012052] 7eff                      moveq.l   #-1,d7
[00012054] 4bfb 1006                 lea.l     $0001205C(pc,d1.w),a5
[00012058] 3c04                      move.w    d4,d6
[0001205a] 4ed5                      jmp       (a5)
[0001205c] 22c7                      move.l    d7,(a1)+
[0001205e] 22c7                      move.l    d7,(a1)+
[00012060] 22c7                      move.l    d7,(a1)+
[00012062] 22c7                      move.l    d7,(a1)+
[00012064] 51ce fff6                 dbf       d6,$0001205C
[00012068] d2cb                      adda.w    a3,a1
[0001206a] 51cd ffec                 dbf       d5,$00012058
[0001206e] 4e75                      rts
[00012070] 4bfb 1006                 lea.l     $00012078(pc,d1.w),a5
[00012074] 3c04                      move.w    d4,d6
[00012076] 4ed5                      jmp       (a5)
[00012078] 2018                      move.l    (a0)+,d0
[0001207a] c199                      and.l     d0,(a1)+
[0001207c] 2018                      move.l    (a0)+,d0
[0001207e] c199                      and.l     d0,(a1)+
[00012080] 2018                      move.l    (a0)+,d0
[00012082] c199                      and.l     d0,(a1)+
[00012084] 2018                      move.l    (a0)+,d0
[00012086] c199                      and.l     d0,(a1)+
[00012088] 51ce ffee                 dbf       d6,$00012078
[0001208c] d0ca                      adda.w    a2,a0
[0001208e] d2cb                      adda.w    a3,a1
[00012090] 51cd ffe2                 dbf       d5,$00012074
[00012094] 4e75                      rts
[00012096] 4bfb 1006                 lea.l     $0001209E(pc,d1.w),a5
[0001209a] 3c04                      move.w    d4,d6
[0001209c] 4ed5                      jmp       (a5)
[0001209e] 2018                      move.l    (a0)+,d0
[000120a0] 4691                      not.l     (a1)
[000120a2] c199                      and.l     d0,(a1)+
[000120a4] 2018                      move.l    (a0)+,d0
[000120a6] 4691                      not.l     (a1)
[000120a8] c199                      and.l     d0,(a1)+
[000120aa] 2018                      move.l    (a0)+,d0
[000120ac] 4691                      not.l     (a1)
[000120ae] c199                      and.l     d0,(a1)+
[000120b0] 2018                      move.l    (a0)+,d0
[000120b2] 4691                      not.l     (a1)
[000120b4] c199                      and.l     d0,(a1)+
[000120b6] 51ce ffe6                 dbf       d6,$0001209E
[000120ba] d0ca                      adda.w    a2,a0
[000120bc] d2cb                      adda.w    a3,a1
[000120be] 51cd ffda                 dbf       d5,$0001209A
[000120c2] 4e75                      rts
[000120c4] 4bfb 1006                 lea.l     $000120CC(pc,d1.w),a5
[000120c8] 3c04                      move.w    d4,d6
[000120ca] 4ed5                      jmp       (a5)
[000120cc] 22d8                      move.l    (a0)+,(a1)+
[000120ce] 22d8                      move.l    (a0)+,(a1)+
[000120d0] 22d8                      move.l    (a0)+,(a1)+
[000120d2] 22d8                      move.l    (a0)+,(a1)+
[000120d4] 51ce fff6                 dbf       d6,$000120CC
[000120d8] d0ca                      adda.w    a2,a0
[000120da] d2cb                      adda.w    a3,a1
[000120dc] 51cd ffea                 dbf       d5,$000120C8
[000120e0] 4e75                      rts
[000120e2] 4bfb 1006                 lea.l     $000120EA(pc,d1.w),a5
[000120e6] 3c04                      move.w    d4,d6
[000120e8] 4ed5                      jmp       (a5)
[000120ea] 2018                      move.l    (a0)+,d0
[000120ec] 4680                      not.l     d0
[000120ee] c199                      and.l     d0,(a1)+
[000120f0] 2018                      move.l    (a0)+,d0
[000120f2] 4680                      not.l     d0
[000120f4] c199                      and.l     d0,(a1)+
[000120f6] 2018                      move.l    (a0)+,d0
[000120f8] 4680                      not.l     d0
[000120fa] c199                      and.l     d0,(a1)+
[000120fc] 2018                      move.l    (a0)+,d0
[000120fe] 4680                      not.l     d0
[00012100] c199                      and.l     d0,(a1)+
[00012102] 51ce ffe6                 dbf       d6,$000120EA
[00012106] d0ca                      adda.w    a2,a0
[00012108] d2cb                      adda.w    a3,a1
[0001210a] 51cd ffda                 dbf       d5,$000120E6
[0001210e] 4e75                      rts
[00012110] 4bfb 1006                 lea.l     $00012118(pc,d1.w),a5
[00012114] 3c04                      move.w    d4,d6
[00012116] 4ed5                      jmp       (a5)
[00012118] 2018                      move.l    (a0)+,d0
[0001211a] b199                      eor.l     d0,(a1)+
[0001211c] 2018                      move.l    (a0)+,d0
[0001211e] b199                      eor.l     d0,(a1)+
[00012120] 2018                      move.l    (a0)+,d0
[00012122] b199                      eor.l     d0,(a1)+
[00012124] 2018                      move.l    (a0)+,d0
[00012126] b199                      eor.l     d0,(a1)+
[00012128] 51ce ffee                 dbf       d6,$00012118
[0001212c] d0ca                      adda.w    a2,a0
[0001212e] d2cb                      adda.w    a3,a1
[00012130] 51cd ffe2                 dbf       d5,$00012114
[00012134] 4e75                      rts
[00012136] 4bfb 1006                 lea.l     $0001213E(pc,d1.w),a5
[0001213a] 3c04                      move.w    d4,d6
[0001213c] 4ed5                      jmp       (a5)
[0001213e] 2018                      move.l    (a0)+,d0
[00012140] 8199                      or.l      d0,(a1)+
[00012142] 2018                      move.l    (a0)+,d0
[00012144] 8199                      or.l      d0,(a1)+
[00012146] 2018                      move.l    (a0)+,d0
[00012148] 8199                      or.l      d0,(a1)+
[0001214a] 2018                      move.l    (a0)+,d0
[0001214c] 8199                      or.l      d0,(a1)+
[0001214e] 51ce ffee                 dbf       d6,$0001213E
[00012152] d0ca                      adda.w    a2,a0
[00012154] d2cb                      adda.w    a3,a1
[00012156] 51cd ffe2                 dbf       d5,$0001213A
[0001215a] 4e75                      rts
[0001215c] 4bfb 1006                 lea.l     $00012164(pc,d1.w),a5
[00012160] 3c04                      move.w    d4,d6
[00012162] 4ed5                      jmp       (a5)
[00012164] 2018                      move.l    (a0)+,d0
[00012166] 8191                      or.l      d0,(a1)
[00012168] 4699                      not.l     (a1)+
[0001216a] 2018                      move.l    (a0)+,d0
[0001216c] 8191                      or.l      d0,(a1)
[0001216e] 4699                      not.l     (a1)+
[00012170] 2018                      move.l    (a0)+,d0
[00012172] 8191                      or.l      d0,(a1)
[00012174] 4699                      not.l     (a1)+
[00012176] 2018                      move.l    (a0)+,d0
[00012178] 8191                      or.l      d0,(a1)
[0001217a] 4699                      not.l     (a1)+
[0001217c] 51ce ffe6                 dbf       d6,$00012164
[00012180] d0ca                      adda.w    a2,a0
[00012182] d2cb                      adda.w    a3,a1
[00012184] 51cd ffda                 dbf       d5,$00012160
[00012188] 4e75                      rts
[0001218a] 4bfb 1006                 lea.l     $00012192(pc,d1.w),a5
[0001218e] 3c04                      move.w    d4,d6
[00012190] 4ed5                      jmp       (a5)
[00012192] 2018                      move.l    (a0)+,d0
[00012194] b191                      eor.l     d0,(a1)
[00012196] 4699                      not.l     (a1)+
[00012198] 2018                      move.l    (a0)+,d0
[0001219a] b191                      eor.l     d0,(a1)
[0001219c] 4699                      not.l     (a1)+
[0001219e] 2018                      move.l    (a0)+,d0
[000121a0] b191                      eor.l     d0,(a1)
[000121a2] 4699                      not.l     (a1)+
[000121a4] 2018                      move.l    (a0)+,d0
[000121a6] b191                      eor.l     d0,(a1)
[000121a8] 4699                      not.l     (a1)+
[000121aa] 51ce ffe6                 dbf       d6,$00012192
[000121ae] d0ca                      adda.w    a2,a0
[000121b0] d2cb                      adda.w    a3,a1
[000121b2] 51cd ffda                 dbf       d5,$0001218E
[000121b6] 4e75                      rts
[000121b8] 4bfb 1006                 lea.l     $000121C0(pc,d1.w),a5
[000121bc] 3c04                      move.w    d4,d6
[000121be] 4ed5                      jmp       (a5)
[000121c0] 4699                      not.l     (a1)+
[000121c2] 4699                      not.l     (a1)+
[000121c4] 4699                      not.l     (a1)+
[000121c6] 4699                      not.l     (a1)+
[000121c8] 51ce fff6                 dbf       d6,$000121C0
[000121cc] d2cb                      adda.w    a3,a1
[000121ce] 51cd ffec                 dbf       d5,$000121BC
[000121d2] 4e75                      rts
[000121d4] 4bfb 1006                 lea.l     $000121DC(pc,d1.w),a5
[000121d8] 3c04                      move.w    d4,d6
[000121da] 4ed5                      jmp       (a5)
[000121dc] 4691                      not.l     (a1)
[000121de] 2018                      move.l    (a0)+,d0
[000121e0] 8199                      or.l      d0,(a1)+
[000121e2] 4691                      not.l     (a1)
[000121e4] 2018                      move.l    (a0)+,d0
[000121e6] 8199                      or.l      d0,(a1)+
[000121e8] 4691                      not.l     (a1)
[000121ea] 2018                      move.l    (a0)+,d0
[000121ec] 8199                      or.l      d0,(a1)+
[000121ee] 4691                      not.l     (a1)
[000121f0] 2018                      move.l    (a0)+,d0
[000121f2] 8199                      or.l      d0,(a1)+
[000121f4] 51ce ffe6                 dbf       d6,$000121DC
[000121f8] d0ca                      adda.w    a2,a0
[000121fa] d2cb                      adda.w    a3,a1
[000121fc] 51cd ffda                 dbf       d5,$000121D8
[00012200] 4e75                      rts
[00012202] 4bfb 1006                 lea.l     $0001220A(pc,d1.w),a5
[00012206] 3c04                      move.w    d4,d6
[00012208] 4ed5                      jmp       (a5)
[0001220a] 2018                      move.l    (a0)+,d0
[0001220c] 4680                      not.l     d0
[0001220e] 22c0                      move.l    d0,(a1)+
[00012210] 2018                      move.l    (a0)+,d0
[00012212] 4680                      not.l     d0
[00012214] 22c0                      move.l    d0,(a1)+
[00012216] 2018                      move.l    (a0)+,d0
[00012218] 4680                      not.l     d0
[0001221a] 22c0                      move.l    d0,(a1)+
[0001221c] 2018                      move.l    (a0)+,d0
[0001221e] 4680                      not.l     d0
[00012220] 22c0                      move.l    d0,(a1)+
[00012222] 51ce ffe6                 dbf       d6,$0001220A
[00012226] d0ca                      adda.w    a2,a0
[00012228] d2cb                      adda.w    a3,a1
[0001222a] 51cd ffda                 dbf       d5,$00012206
[0001222e] 4e75                      rts
[00012230] 4bfb 1006                 lea.l     $00012238(pc,d1.w),a5
[00012234] 3c04                      move.w    d4,d6
[00012236] 4ed5                      jmp       (a5)
[00012238] 2018                      move.l    (a0)+,d0
[0001223a] 4680                      not.l     d0
[0001223c] 8199                      or.l      d0,(a1)+
[0001223e] 2018                      move.l    (a0)+,d0
[00012240] 4680                      not.l     d0
[00012242] 8199                      or.l      d0,(a1)+
[00012244] 2018                      move.l    (a0)+,d0
[00012246] 4680                      not.l     d0
[00012248] 8199                      or.l      d0,(a1)+
[0001224a] 2018                      move.l    (a0)+,d0
[0001224c] 4680                      not.l     d0
[0001224e] 8199                      or.l      d0,(a1)+
[00012250] 51ce ffe6                 dbf       d6,$00012238
[00012254] d0ca                      adda.w    a2,a0
[00012256] d2cb                      adda.w    a3,a1
[00012258] 51cd ffda                 dbf       d5,$00012234
[0001225c] 4e75                      rts
[0001225e] 4bfb 1006                 lea.l     $00012266(pc,d1.w),a5
[00012262] 3c04                      move.w    d4,d6
[00012264] 4ed5                      jmp       (a5)
[00012266] 2018                      move.l    (a0)+,d0
[00012268] c191                      and.l     d0,(a1)
[0001226a] 4699                      not.l     (a1)+
[0001226c] 2018                      move.l    (a0)+,d0
[0001226e] c191                      and.l     d0,(a1)
[00012270] 4699                      not.l     (a1)+
[00012272] 2018                      move.l    (a0)+,d0
[00012274] c191                      and.l     d0,(a1)
[00012276] 4699                      not.l     (a1)+
[00012278] 2018                      move.l    (a0)+,d0
[0001227a] c191                      and.l     d0,(a1)
[0001227c] 4699                      not.l     (a1)+
[0001227e] 51ce ffe6                 dbf       d6,$00012266
[00012282] d0ca                      adda.w    a2,a0
[00012284] d2cb                      adda.w    a3,a1
[00012286] 51cd ffda                 dbf       d5,$00012262
[0001228a] 4e75                      rts
[0001228c] 4e75                      rts

data:
[0001228e]                           dc.w $086a
[00012290]                           dc.w $05c2
[00012292]                           dc.w $002c
[00012294]                           dc.w $0024
[00012296]                           dc.w $00be
[00012298]                           dc.w $00fc
[0001229a]                           dc.w $0234
[0001229c]                           dc.w $0218
[0001229e]                           dc.w $05de
[000122a0]                           dc.w $0000
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
; $00000066
; $00000164
; $00000262
; $00000360
; $0000045e
; $0000055c
; $0000065a
; $00000758
; $00000856
; $000008c2
; $000008ca
; $000008d2
; $000008da
; $000008e2
; $000008ea
; $000008f2
; $000008fa
; $00000902
; $0000090a
; $00000912
; $0000091a
; $00000922
; $0000092a
; $00000932
; $0000093a
; $00000942
; $00000a40
; $00000b1a
; $00000b1e
; $00000b22
; $00000b26
