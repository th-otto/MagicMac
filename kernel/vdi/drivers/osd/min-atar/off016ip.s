; ph_branch = 0x601a
; ph_tlen = 0x00003ce2
; ph_dlen = 0x00000038
; ph_blen = 0x00000004
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000047

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0410                 cmpiw.l   #$0410,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 006c                 ori.b     #$6C,d1
[00010018] 0001 0178                 ori.b     #$78,d1
[0001001c] 0001 020e                 ori.b     #$0E,d1
[00010020] 0001 006e                 ori.b     #$6E,d1
[00010024] 0001 00b0                 ori.b     #$B0,d1
[00010028] 0001 00fe                 ori.b     #$FE,d1
[0001002c] 0001 0150                 ori.b     #$50,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0000 0010                 ori.b     #$10,d0
[00010044] 0004 0000                 ori.b     #$00,d4
[00010048] 0001 0000                 ori.b     #$00,d1
[0001004c] 0000 0000                 ori.b     #$00,d0
[00010050] 4e75                      rts
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 3d1a            move.l    a0,$00013D1A
[0001005c] 6100 00f4                 bsr       $00010152
[00010060] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010064] 203c 0000 02d8            move.l    #$000002D8,d0
[0001006a] 4e75                      rts
[0001006c] 4e75                      rts
[0001006e] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010072] 20ee 0010                 move.l    16(a6),(a0)+
[00010076] 4258                      clr.w     (a0)+
[00010078] 20ee 000c                 move.l    12(a6),(a0)+
[0001007c] 7027                      moveq.l   #39,d0
[0001007e] 247a 3c9a                 movea.l   $00013D1A(pc),a2
[00010082] 246a 002c                 movea.l   44(a2),a2
[00010086] 45ea 000a                 lea.l     10(a2),a2
[0001008a] 30da                      move.w    (a2)+,(a0)+
[0001008c] 51c8 fffc                 dbf       d0,$0001008A
[00010090] 317c 0010 ffc0            move.w    #$0010,-64(a0)
[00010096] 317c 0001 ffec            move.w    #$0001,-20(a0)
[0001009c] 317c 0010 fff4            move.w    #$0010,-12(a0)
[000100a2] 700b                      moveq.l   #11,d0
[000100a4] 32da                      move.w    (a2)+,(a1)+
[000100a6] 51c8 fffc                 dbf       d0,$000100A4
[000100aa] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100ae] 4e75                      rts
[000100b0] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[000100b4] 702c                      moveq.l   #44,d0
[000100b6] 247a 3c62                 movea.l   $00013D1A(pc),a2
[000100ba] 246a 0030                 movea.l   48(a2),a2
[000100be] 30da                      move.w    (a2)+,(a0)+
[000100c0] 51c8 fffc                 dbf       d0,$000100BE
[000100c4] 4268 ffa6                 clr.w     -90(a0)
[000100c8] 317c 0010 ffa8            move.w    #$0010,-88(a0)
[000100ce] 317c 0004 ffae            move.w    #$0004,-82(a0)
[000100d4] 4268 ffb0                 clr.w     -80(a0)
[000100d8] 317c 0898 ffb2            move.w    #$0898,-78(a0)
[000100de] 317c 0001 ffcc            move.w    #$0001,-52(a0)
[000100e4] 700b                      moveq.l   #11,d0
[000100e6] 32da                      move.w    (a2)+,(a1)+
[000100e8] 51c8 fffc                 dbf       d0,$000100E6
[000100ec] 45ee 0034                 lea.l     52(a6),a2
[000100f0] 235a ffe8                 move.l    (a2)+,-24(a1)
[000100f4] 235a ffec                 move.l    (a2)+,-20(a1)
[000100f8] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100fc] 4e75                      rts
[000100fe] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010102] 7000                      moveq.l   #0,d0
[00010104] 30fc 0000                 move.w    #$0000,(a0)+
[00010108] 30c0                      move.w    d0,(a0)+
[0001010a] 30fc 0004                 move.w    #$0004,(a0)+
[0001010e] 20fc 0000 0010            move.l    #$00000010,(a0)+
[00010114] 30ee 01b2                 move.w    434(a6),(a0)+
[00010118] 20ee 01ae                 move.l    430(a6),(a0)+
[0001011c] 30c0                      move.w    d0,(a0)+
[0001011e] 30c0                      move.w    d0,(a0)+
[00010120] 30c0                      move.w    d0,(a0)+
[00010122] 30c0                      move.w    d0,(a0)+
[00010124] 30c0                      move.w    d0,(a0)+
[00010126] 30c0                      move.w    d0,(a0)+
[00010128] 30fc 0001                 move.w    #$0001,(a0)+
[0001012c] 4258                      clr.w     (a0)+
[0001012e] 700f                      moveq.l   #15,d0
[00010130] 7200                      moveq.l   #0,d1
[00010132] 43fa 3bae                 lea.l     $00013CE2(pc),a1
[00010136] 1219                      move.b    (a1)+,d1
[00010138] 30c1                      move.w    d1,(a0)+
[0001013a] 51c8 fffa                 dbf       d0,$00010136
[0001013e] 303c 00ef                 move.w    #$00EF,d0
[00010142] 720f                      moveq.l   #15,d1
[00010144] 30c1                      move.w    d1,(a0)+
[00010146] 51c8 fffc                 dbf       d0,$00010144
[0001014a] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[0001014e] 4e75                      rts
[00010150] 4e75                      rts
[00010152] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010156] a000                      ALINE     #$0000
[00010158] 907c 2070                 sub.w     #$2070,d0
[0001015c] 6714                      beq.s     $00010172
[0001015e] 41fa fea0                 lea.l     $00010000(pc),a0
[00010162] 43f9 0001 3d02            lea.l     $00013D02,a1
[00010168] 3219                      move.w    (a1)+,d1
[0001016a] 6706                      beq.s     $00010172
[0001016c] d0c1                      adda.w    d1,a0
[0001016e] d150                      add.w     d0,(a0)
[00010170] 60f6                      bra.s     $00010168
[00010172] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010176] 4e75                      rts
[00010178] 3d7c 0003 01b4            move.w    #$0003,436(a6)
[0001017e] 3d7c 000f 0014            move.w    #$000F,20(a6)
[00010184] 2d7c 0001 2c2c 01f4       move.l    #$00012C2C,500(a6)
[0001018c] 2d7c 0001 3176 01f8       move.l    #$00013176,504(a6)
[00010194] 2d7c 0001 31e2 01fc       move.l    #$000131E2,508(a6)
[0001019c] 2d7c 0001 3436 0200       move.l    #$00013436,512(a6)
[000101a4] 2d7c 0001 359a 0204       move.l    #$0001359A,516(a6)
[000101ac] 2d7c 0001 038a 0208       move.l    #$0001038A,520(a6)
[000101b4] 2d7c 0001 035e 020c       move.l    #$0001035E,524(a6)
[000101bc] 2d7c 0001 38f6 0210       move.l    #$000138F6,528(a6)
[000101c4] 2d7c 0001 3bb4 0214       move.l    #$00013BB4,532(a6)
[000101cc] 2d7c 0001 0294 021c       move.l    #$00010294,540(a6)
[000101d4] 2d7c 0001 02da 0218       move.l    #$000102DA,536(a6)
[000101dc] 2d7c 0001 021a 0220       move.l    #$0001021A,544(a6)
[000101e4] 2d7c 0001 0326 0224       move.l    #$00010326,548(a6)
[000101ec] 2d7c 0001 0210 0228       move.l    #$00010210,552(a6)
[000101f4] 2d7c 0001 0212 022c       move.l    #$00010212,556(a6)
[000101fc] 2d7c 0001 034a 0230       move.l    #$0001034A,560(a6)
[00010204] 2d7c 0001 0354 0234       move.l    #$00010354,564(a6)
[0001020c] 4e75                      rts
[0001020e] 4e75                      rts
[00010210] 4e75                      rts
[00010212] 70ff                      moveq.l   #-1,d0
[00010214] 72ff                      moveq.l   #-1,d1
[00010216] 74ff                      moveq.l   #-1,d2
[00010218] 4e75                      rts
[0001021a] 7000                      moveq.l   #0,d0
[0001021c] 3028 000c                 move.w    12(a0),d0
[00010220] 3228 0006                 move.w    6(a0),d1
[00010224] c2e8 0008                 mulu.w    8(a0),d1
[00010228] 4a68 000a                 tst.w     10(a0)
[0001022c] 6608                      bne.s     $00010236
[0001022e] 337c 0001 000a            move.w    #$0001,10(a1)
[00010234] 6006                      bra.s     $0001023C
[00010236] 4269 000a                 clr.w     10(a1)
[0001023a] c141                      exg       d0,d1
[0001023c] 2050                      movea.l   (a0),a0
[0001023e] 2251                      movea.l   (a1),a1
[00010240] 5380                      subq.l    #1,d0
[00010242] 6b4e                      bmi.s     $00010292
[00010244] 2801                      move.l    d1,d4
[00010246] 5384                      subq.l    #1,d4
[00010248] 6b48                      bmi.s     $00010292
[0001024a] b3c8                      cmpa.l    a0,a1
[0001024c] 6716                      beq.s     $00010264
[0001024e] d281                      add.l     d1,d1
[00010250] 2449                      movea.l   a1,a2
[00010252] 2600                      move.l    d0,d3
[00010254] 3498                      move.w    (a0)+,(a2)
[00010256] d5c1                      adda.l    d1,a2
[00010258] 5383                      subq.l    #1,d3
[0001025a] 6af8                      bpl.s     $00010254
[0001025c] 5489                      addq.l    #2,a1
[0001025e] 5384                      subq.l    #1,d4
[00010260] 6aee                      bpl.s     $00010250
[00010262] 4e75                      rts
[00010264] 5384                      subq.l    #1,d4
[00010266] 6b2a                      bmi.s     $00010292
[00010268] 7400                      moveq.l   #0,d2
[0001026a] 2204                      move.l    d4,d1
[0001026c] d1c0                      adda.l    d0,a0
[0001026e] 41f0 0802                 lea.l     2(a0,d0.l),a0
[00010272] 3a10                      move.w    (a0),d5
[00010274] 2248                      movea.l   a0,a1
[00010276] 2448                      movea.l   a0,a2
[00010278] d480                      add.l     d0,d2
[0001027a] 2602                      move.l    d2,d3
[0001027c] 6004                      bra.s     $00010282
[0001027e] 2449                      movea.l   a1,a2
[00010280] 34a1                      move.w    -(a1),(a2)
[00010282] 5383                      subq.l    #1,d3
[00010284] 6af8                      bpl.s     $0001027E
[00010286] 3285                      move.w    d5,(a1)
[00010288] 5381                      subq.l    #1,d1
[0001028a] 6ae0                      bpl.s     $0001026C
[0001028c] 204a                      movea.l   a2,a0
[0001028e] 5380                      subq.l    #1,d0
[00010290] 6ad6                      bpl.s     $00010268
[00010292] 4e75                      rts
[00010294] 48e7 3000                 movem.l   d2-d3,-(a7)
[00010298] 4a6e 01b2                 tst.w     434(a6)
[0001029c] 670a                      beq.s     $000102A8
[0001029e] 206e 01ae                 movea.l   430(a6),a0
[000102a2] c3ee 01b2                 muls.w    434(a6),d1
[000102a6] 6008                      bra.s     $000102B0
[000102a8] 2078 044e                 movea.l   ($0000044E).w,a0
[000102ac] c3f8 206e                 muls.w    ($0000206E).w,d1
[000102b0] d1c1                      adda.l    d1,a0
[000102b2] 72f0                      moveq.l   #-16,d1
[000102b4] c240                      and.w     d0,d1
[000102b6] e249                      lsr.w     #1,d1
[000102b8] 5041                      addq.w    #8,d1
[000102ba] d0c1                      adda.w    d1,a0
[000102bc] 720f                      moveq.l   #15,d1
[000102be] 4640                      not.w     d0
[000102c0] c240                      and.w     d0,d1
[000102c2] 7403                      moveq.l   #3,d2
[000102c4] 7000                      moveq.l   #0,d0
[000102c6] 3620                      move.w    -(a0),d3
[000102c8] d040                      add.w     d0,d0
[000102ca] 0303                      btst      d1,d3
[000102cc] 6702                      beq.s     $000102D0
[000102ce] 5240                      addq.w    #1,d0
[000102d0] 51ca fff4                 dbf       d2,$000102C6
[000102d4] 4cdf 000c                 movem.l   (a7)+,d2-d3
[000102d8] 4e75                      rts
[000102da] 2f03                      move.l    d3,-(a7)
[000102dc] 4a6e 01b2                 tst.w     434(a6)
[000102e0] 670a                      beq.s     $000102EC
[000102e2] 206e 01ae                 movea.l   430(a6),a0
[000102e6] c3ee 01b2                 muls.w    434(a6),d1
[000102ea] 6008                      bra.s     $000102F4
[000102ec] 2078 044e                 movea.l   ($0000044E).w,a0
[000102f0] c3f8 206e                 muls.w    ($0000206E).w,d1
[000102f4] d1c1                      adda.l    d1,a0
[000102f6] 72f0                      moveq.l   #-16,d1
[000102f8] c240                      and.w     d0,d1
[000102fa] e249                      lsr.w     #1,d1
[000102fc] d0c1                      adda.w    d1,a0
[000102fe] 4640                      not.w     d0
[00010300] 0240 000f                 andi.w    #$000F,d0
[00010304] 7200                      moveq.l   #0,d1
[00010306] 01c1                      bset      d0,d1
[00010308] 3001                      move.w    d1,d0
[0001030a] 4640                      not.w     d0
[0001030c] 7603                      moveq.l   #3,d3
[0001030e] e25a                      ror.w     #1,d2
[00010310] 640a                      bcc.s     $0001031C
[00010312] 8358                      or.w      d1,(a0)+
[00010314] 51cb fff8                 dbf       d3,$0001030E
[00010318] 261f                      move.l    (a7)+,d3
[0001031a] 4e75                      rts
[0001031c] c158                      and.w     d0,(a0)+
[0001031e] 51cb ffee                 dbf       d3,$0001030E
[00010322] 261f                      move.l    (a7)+,d3
[00010324] 4e75                      rts
[00010326] e848                      lsr.w     #4,d0
[00010328] 5340                      subq.w    #1,d0
[0001032a] 6704                      beq.s     $00010330
[0001032c] 302e 01b4                 move.w    436(a6),d0
[00010330] 3f00                      move.w    d0,-(a7)
[00010332] 22d8                      move.l    (a0)+,(a1)+
[00010334] 22d8                      move.l    (a0)+,(a1)+
[00010336] 22d8                      move.l    (a0)+,(a1)+
[00010338] 22d8                      move.l    (a0)+,(a1)+
[0001033a] 22d8                      move.l    (a0)+,(a1)+
[0001033c] 22d8                      move.l    (a0)+,(a1)+
[0001033e] 22d8                      move.l    (a0)+,(a1)+
[00010340] 22d8                      move.l    (a0)+,(a1)+
[00010342] 51c8 ffee                 dbf       d0,$00010332
[00010346] 301f                      move.w    (a7)+,d0
[00010348] 4e75                      rts
[0001034a] 41fa 3996                 lea.l     $00013CE2(pc),a0
[0001034e] 1030 0000                 move.b    0(a0,d0.w),d0
[00010352] 4e75                      rts
[00010354] 41fa 399c                 lea.l     $00013CF2(pc),a0
[00010358] 1030 0000                 move.b    0(a0,d0.w),d0
[0001035c] 4e75                      rts
[0001035e] bc44                      cmp.w     d4,d6
[00010360] be45                      cmp.w     d5,d7
[00010362] 08ae 0004 01ef            bclr      #4,495(a6)
[00010368] 6620                      bne.s     $0001038A
[0001036a] 42ae 01ea                 clr.l     490(a6)
[0001036e] 7e0f                      moveq.l   #15,d7
[00010370] ce6e 01ee                 and.w     494(a6),d7
[00010374] 1d47 01ee                 move.b    d7,494(a6)
[00010378] 6038                      bra.s     $000103B2
[0001037a] 000c 030f                 ori.b     #$0F,a4 ; apollo only
[0001037e] 0404 0707                 subi.b    #$07,d4
[00010382] 0606 0606                 addi.b    #$06,d6
[00010386] 010d 010d                 movep.w   269(a5),d0
[0001038a] 7e03                      moveq.l   #3,d7
[0001038c] ce6e 01ee                 and.w     494(a6),d7
[00010390] de47                      add.w     d7,d7
[00010392] de47                      add.w     d7,d7
[00010394] 2d7b 70e4 01ee            move.l    $0001037A(pc,d7.w),494(a6)
[0001039a] 41fa 3946                 lea.l     $00013CE2(pc),a0
[0001039e] 3c2e 01ea                 move.w    490(a6),d6
[000103a2] 1d70 6000 01eb            move.b    0(a0,d6.w),491(a6)
[000103a8] 3c2e 01ec                 move.w    492(a6),d6
[000103ac] 1d70 6000 01ed            move.b    0(a0,d6.w),493(a6)
[000103b2] 3c2e 01c8                 move.w    456(a6),d6
[000103b6] 5246                      addq.w    #1,d6
[000103b8] dc46                      add.w     d6,d6
[000103ba] 3d46 01ca                 move.w    d6,458(a6)
[000103be] 3c2e 01dc                 move.w    476(a6),d6
[000103c2] 5246                      addq.w    #1,d6
[000103c4] dc46                      add.w     d6,d6
[000103c6] 3d46 01de                 move.w    d6,478(a6)
[000103ca] 206e 01c2                 movea.l   450(a6),a0
[000103ce] 226e 01d6                 movea.l   470(a6),a1
[000103d2] 346e 01c6                 movea.w   454(a6),a2
[000103d6] 366e 01da                 movea.w   474(a6),a3
[000103da] 3c0a                      move.w    a2,d6
[000103dc] ccc1                      mulu.w    d1,d6
[000103de] d1c6                      adda.l    d6,a0
[000103e0] 3c00                      move.w    d0,d6
[000103e2] e84e                      lsr.w     #4,d6
[000103e4] dc46                      add.w     d6,d6
[000103e6] 3e2e 01c8                 move.w    456(a6),d7
[000103ea] 5247                      addq.w    #1,d7
[000103ec] ccc7                      mulu.w    d7,d6
[000103ee] d1c6                      adda.l    d6,a0
[000103f0] 3c0b                      move.w    a3,d6
[000103f2] ccc3                      mulu.w    d3,d6
[000103f4] d3c6                      adda.l    d6,a1
[000103f6] 3c02                      move.w    d2,d6
[000103f8] e84e                      lsr.w     #4,d6
[000103fa] 48c6                      ext.l     d6
[000103fc] e78e                      lsl.l     #3,d6
[000103fe] d3c6                      adda.l    d6,a1
[00010400] b1c9                      cmpa.l    a1,a0
[00010402] 623c                      bhi.s     $00010440
[00010404] 6724                      beq.s     $0001042A
[00010406] d0ca                      adda.w    a2,a0
[00010408] b3c8                      cmpa.l    a0,a1
[0001040a] 6500 1560                 bcs       $0001196C
[0001040e] 90ca                      suba.w    a2,a0
[00010410] 3c0a                      move.w    a2,d6
[00010412] ccc5                      mulu.w    d5,d6
[00010414] d1c6                      adda.l    d6,a0
[00010416] 3c0b                      move.w    a3,d6
[00010418] ccc5                      mulu.w    d5,d6
[0001041a] d3c6                      adda.l    d6,a1
[0001041c] 3c0a                      move.w    a2,d6
[0001041e] 4446                      neg.w     d6
[00010420] 3446                      movea.w   d6,a2
[00010422] 3c0b                      move.w    a3,d6
[00010424] 4446                      neg.w     d6
[00010426] 3646                      movea.w   d6,a3
[00010428] 6016                      bra.s     $00010440
[0001042a] 7c0f                      moveq.l   #15,d6
[0001042c] 7e0f                      moveq.l   #15,d7
[0001042e] cc40                      and.w     d0,d6
[00010430] ce42                      and.w     d2,d7
[00010432] 9e46                      sub.w     d6,d7
[00010434] 6e00 1536                 bgt       $0001196C
[00010438] 6606                      bne.s     $00010440
[0001043a] b6ca                      cmpa.w    a2,a3
[0001043c] 6e00 152e                 bgt       $0001196C
[00010440] 7c0f                      moveq.l   #15,d6
[00010442] c046                      and.w     d6,d0
[00010444] 3e00                      move.w    d0,d7
[00010446] de44                      add.w     d4,d7
[00010448] e84f                      lsr.w     #4,d7
[0001044a] 3602                      move.w    d2,d3
[0001044c] c646                      and.w     d6,d3
[0001044e] 9043                      sub.w     d3,d0
[00010450] 3202                      move.w    d2,d1
[00010452] c246                      and.w     d6,d1
[00010454] d244                      add.w     d4,d1
[00010456] e849                      lsr.w     #4,d1
[00010458] 9e41                      sub.w     d1,d7
[0001045a] d842                      add.w     d2,d4
[0001045c] 4644                      not.w     d4
[0001045e] c846                      and.w     d6,d4
[00010460] 76ff                      moveq.l   #-1,d3
[00010462] e96b                      lsl.w     d4,d3
[00010464] cc42                      and.w     d2,d6
[00010466] 74ff                      moveq.l   #-1,d2
[00010468] ec6a                      lsr.w     d6,d2
[0001046a] 3801                      move.w    d1,d4
[0001046c] 3c04                      move.w    d4,d6
[0001046e] c8ee 01ca                 mulu.w    458(a6),d4
[00010472] ccee 01de                 mulu.w    478(a6),d6
[00010476] 94c4                      suba.w    d4,a2
[00010478] 96c6                      suba.w    d6,a3
[0001047a] 3807                      move.w    d7,d4
[0001047c] 7c04                      moveq.l   #4,d6
[0001047e] 7e00                      moveq.l   #0,d7
[00010480] 49fa 00ea                 lea.l     $0001056C(pc),a4
[00010484] 4a40                      tst.w     d0
[00010486] 6752                      beq.s     $000104DA
[00010488] 6d2e                      blt.s     $000104B8
[0001048a] 49fa 0160                 lea.l     $000105EC(pc),a4
[0001048e] 4a41                      tst.w     d1
[00010490] 6608                      bne.s     $0001049A
[00010492] 4a44                      tst.w     d4
[00010494] 6604                      bne.s     $0001049A
[00010496] 7c0c                      moveq.l   #12,d6
[00010498] 6040                      bra.s     $000104DA
[0001049a] 7c04                      moveq.l   #4,d6
[0001049c] 94ee 01ca                 suba.w    458(a6),a2
[000104a0] 4a44                      tst.w     d4
[000104a2] 6e02                      bgt.s     $000104A6
[000104a4] 7e02                      moveq.l   #2,d7
[000104a6] b07c 0008                 cmp.w     #$0008,d0
[000104aa] 6f2e                      ble.s     $000104DA
[000104ac] 49fa 01be                 lea.l     $0001066C(pc),a4
[000104b0] 5340                      subq.w    #1,d0
[000104b2] 0a40 000f                 eori.w    #$000F,d0
[000104b6] 6022                      bra.s     $000104DA
[000104b8] 49fa 01b2                 lea.l     $0001066C(pc),a4
[000104bc] 4440                      neg.w     d0
[000104be] 7c0a                      moveq.l   #10,d6
[000104c0] 4a41                      tst.w     d1
[000104c2] 6716                      beq.s     $000104DA
[000104c4] 4a44                      tst.w     d4
[000104c6] 6a02                      bpl.s     $000104CA
[000104c8] 7e02                      moveq.l   #2,d7
[000104ca] 0c40 0008                 cmpi.w    #$0008,d0
[000104ce] 6f0a                      ble.s     $000104DA
[000104d0] 49fa 011a                 lea.l     $000105EC(pc),a4
[000104d4] 5340                      subq.w    #1,d0
[000104d6] 0a40 000f                 eori.w    #$000F,d0
[000104da] 382e 01dc                 move.w    476(a6),d4
[000104de] b86e 01c8                 cmp.w     456(a6),d4
[000104e2] 6616                      bne.s     $000104FA
[000104e4] b87c 0003                 cmp.w     #$0003,d4
[000104e8] 6610                      bne.s     $000104FA
[000104ea] 4aae 01ea                 tst.l     490(a6)
[000104ee] 660a                      bne.s     $000104FA
[000104f0] 0c2e 0003 01ee            cmpi.b    #$03,494(a6)
[000104f6] 6700 0c9e                 beq       $00011196
[000104fa] 3d4a 01c6                 move.w    a2,454(a6)
[000104fe] 3d4b 01da                 move.w    a3,474(a6)
[00010502] 346e 01ca                 movea.w   458(a6),a2
[00010506] 366e 01de                 movea.w   478(a6),a3
[0001050a] 4a41                      tst.w     d1
[0001050c] 6610                      bne.s     $0001051E
[0001050e] c443                      and.w     d3,d2
[00010510] 360a                      move.w    a2,d3
[00010512] 976e 01c6                 sub.w     d3,454(a6)
[00010516] 360b                      move.w    a3,d3
[00010518] 976e 01da                 sub.w     d3,474(a6)
[0001051c] 7600                      moveq.l   #0,d3
[0001051e] 48e7 4fc8                 movem.l   d1/d4-d7/a0-a1/a4,-(a7)
[00010522] 4bee 01ea                 lea.l     490(a6),a5
[00010526] 7800                      moveq.l   #0,d4
[00010528] e2dd                      lsr.w     (a5)+
[0001052a] d944                      addx.w    d4,d4
[0001052c] e2dd                      lsr.w     (a5)+
[0001052e] d944                      addx.w    d4,d4
[00010530] 1835 4000                 move.b    0(a5,d4.w),d4
[00010534] e74c                      lsl.w     #3,d4
[00010536] 3a44                      movea.w   d4,a5
[00010538] dbcc                      adda.l    a4,a5
[0001053a] 381d                      move.w    (a5)+,d4
[0001053c] dc44                      add.w     d4,d6
[0001053e] de5d                      add.w     (a5)+,d7
[00010540] 4a41                      tst.w     d1
[00010542] 6602                      bne.s     $00010546
[00010544] 3e15                      move.w    (a5),d7
[00010546] 5541                      subq.w    #2,d1
[00010548] 49fa 0022                 lea.l     $0001056C(pc),a4
[0001054c] 4bfa 001e                 lea.l     $0001056C(pc),a5
[00010550] d8c6                      adda.w    d6,a4
[00010552] dac7                      adda.w    d7,a5
[00010554] 4ebb 4016                 jsr       $0001056C(pc,d4.w)
[00010558] 4cdf 13f2                 movem.l   (a7)+,d1/d4-d7/a0-a1/a4
[0001055c] 5489                      addq.l    #2,a1
[0001055e] 4a6e 01c8                 tst.w     456(a6)
[00010562] 6702                      beq.s     $00010566
[00010564] 5488                      addq.l    #2,a0
[00010566] 51cc ffb6                 dbf       d4,$0001051E
[0001056a] 4e75                      rts
[0001056c] 0180                      bclr      d0,d0
[0001056e] 0000 0000                 ori.b     #$00,d0
[00010572] 0000 01ba                 ori.b     #$BA,d0
[00010576] 01da                      bset      d0,(a2)+
[00010578] 01e4                      bset      d0,-(a4)
[0001057a] 0000 0294                 ori.b     #$94,d0
[0001057e] 02b8 02c4 0000 0380       andi.l    #$02C40000,($00000380).w
[00010586] 039e                      bclr      d1,(a6)+
[00010588] 03a8 0000                 bclr      d1,0(a0)
[0001058c] 0458 0478                 subi.w    #$0478,(a0)+
[00010590] 0480 0000 052c            subi.l    #$0000052C,d0
[00010596] 0000 0000                 ori.b     #$00,d0
[0001059a] 0000 052e                 ori.b     #$2E,d0
[0001059e] 054a 0550                 movep.l   1360(a2),d2
[000105a2] 0000 05f0                 ori.b     #$F0,d0
[000105a6] 060c 0612                 addi.b    #$12,a4 ; apollo only
[000105aa] 0000 06b2                 ori.b     #$B2,d0
[000105ae] 06d2 06da                 callm     #$06DA,(a2) ; 68020 only
[000105b2] 0000 0784                 ori.b     #$84,d0
[000105b6] 07a4                      bclr      d3,-(a4)
[000105b8] 07ac 0000                 bclr      d3,0(a4)
[000105bc] 0858 0000                 bchg      #0,(a0)+
[000105c0] 0000 0000                 ori.b     #$00,d0
[000105c4] 0886 08a6                 bclr      #2214,d6
[000105c8] 08ae 0000 095a            bclr      #0,2394(a6)
[000105ce] 0980                      bclr      d4,d0
[000105d0] 098e 0000                 movep.w   d4,0(a6)
[000105d4] 0a52 0a72                 eori.w    #$0A72,(a2)
[000105d8] 0a7a 0000 0b26            eori.w    #$0000,$00011100(pc) ; apollo only
[000105de] 0b46                      bchg      d5,d6
[000105e0] 0b4e 0000                 movep.l   0(a6),d5
[000105e4] 0bfa 0000                 bset      d5,$000105E6(pc) ; apollo only
[000105e8] 0000 0000                 ori.b     #$00,d0
[000105ec] 0180                      bclr      d0,d0
[000105ee] 0000 0000                 ori.b     #$00,d0
[000105f2] 0000 0242                 ori.b     #$42,d0
[000105f6] 0278 0286 0000            andi.w    #$0286,($00000000).w
[000105fc] 0328 0362                 btst      d1,866(a0)
[00010600] 0372 0000                 bchg      d1,0(a2,d0.w)
[00010604] 0406 043c                 subi.b    #$3C,d6
[00010608] 044a 0000                 subi.w    #$0000,a2 ; apollo only
[0001060c] 04dc                      dc.w      $04DC ; illegal
[0001060e] 0512                      btst      d2,(a2)
[00010610] 051e                      btst      d2,(a6)+
[00010612] 0000 052c                 ori.b     #$2C,d0
[00010616] 0000 0000                 ori.b     #$00,d0
[0001061a] 0000 05a6                 ori.b     #$A6,d0
[0001061e] 05d8                      bset      d2,(a0)+
[00010620] 05e2                      bset      d2,-(a2)
[00010622] 0000 0668                 ori.b     #$68,d0
[00010626] 069a 06a4 0000            addi.l    #$06A40000,(a2)+
[0001062c] 0734 076a 0776 0000       btst      d3,([$0776,a4,zd0.w*8],$0000) ; 68020+ only
[00010634] 0808 083e                 btst      #2110,a0
[00010638] 084a 0000                 bchg      #0,a2
[0001063c] 0858 0000                 bchg      #0,(a0)+
[00010640] 0000 0000                 ori.b     #$00,d0
[00010644] 090a 0940                 movep.w   2368(a2),d4
[00010648] 094c 0000                 movep.l   0(a4),d4
[0001064c] 09f6 0a32                 bset      d4,50(a6,d0.l*2) ; 68020+ only
[00010650] 0a44 0000                 eori.w    #$0000,d4
[00010654] 0ad6 0b0c                 cas.b     d4,d4,(a6) ; 68020+ only
[00010658] 0b18                      btst      d5,(a0)+
[0001065a] 0000 0baa                 ori.b     #$AA,d0
[0001065e] 0be0                      bset      d5,-(a0)
[00010660] 0bec 0000                 bset      d5,0(a4)
[00010664] 0bfa 0000                 bset      d5,$00010666(pc) ; apollo only
[00010668] 0000 0000                 ori.b     #$00,d0
[0001066c] 0180                      bclr      d0,d0
[0001066e] 0000 0000                 ori.b     #$00,d0
[00010672] 0000 01f2                 ori.b     #$F2,d0
[00010676] 0228 0234 0000            andi.b    #$34,0(a0)
[0001067c] 02d2 030c                 cmp2.w    (a2),d0 ; 68020+ only
[00010680] 031a                      btst      d1,(a2)+
[00010682] 0000 03b6                 ori.b     #$B6,d0
[00010686] 03ec 03f8                 bset      d1,1016(a4)
[0001068a] 0000 048e                 ori.b     #$8E,d0
[0001068e] 04c4                      ff1.l     d4 ; ColdFire isa_c only
[00010690] 04ce                      dc.w      $04CE ; illegal
[00010692] 0000 052c                 ori.b     #$2C,d0
[00010696] 0000 0000                 ori.b     #$00,d0
[0001069a] 0000 055e                 ori.b     #$5E,d0
[0001069e] 0590                      bclr      d2,(a0)
[000106a0] 0598                      bclr      d2,(a0)+
[000106a2] 0000 0620                 ori.b     #$20,d0
[000106a6] 0652 065a                 addi.w    #$065A,(a2)
[000106aa] 0000 06e8                 ori.b     #$E8,d0
[000106ae] 071c                      btst      d3,(a4)+
[000106b0] 0726                      btst      d3,-(a6)
[000106b2] 0000 07ba                 ori.b     #$BA,d0
[000106b6] 07f0 07fa 0000 0858 0000  bset      d3,([$00000858,zd0.w*8],$0000) ; 68020+ only
[000106c0] 0000 0000                 ori.b     #$00,d0
[000106c4] 08bc 08f2                 bclr      #2290,# ; illegal
[000106c8] 08fc 0000                 bset      #0,# ; illegal
[000106cc] 099c                      bclr      d4,(a4)+
[000106ce] 09d8                      bset      d4,(a0)+
[000106d0] 09e8 0000                 bset      d4,0(a0)
[000106d4] 0a88 0abe 0ac8            eori.l    #$0ABE0AC8,a0 ; apollo only
[000106da] 0000 0b5c                 ori.b     #$5C,d0
[000106de] 0b92                      bclr      d5,(a2)
[000106e0] 0b9c                      bclr      d5,(a4)+
[000106e2] 0000 0bfa                 ori.b     #$FA,d0
[000106e6] 0000 0000                 ori.b     #$00,d0
[000106ea] 0000 3e2e                 ori.b     #$2E,d0
[000106ee] 01da                      bset      d0,(a2)+
[000106f0] 4642                      not.w     d2
[000106f2] 4a43                      tst.w     d3
[000106f4] 660e                      bne.s     $00010704
[000106f6] de4b                      add.w     a3,d7
[000106f8] c551                      and.w     d2,(a1)
[000106fa] d2c7                      adda.w    d7,a1
[000106fc] 51cd fffa                 dbf       d5,$000106F8
[00010700] 4642                      not.w     d2
[00010702] 4e75                      rts
[00010704] 4643                      not.w     d3
[00010706] 7c00                      moveq.l   #0,d6
[00010708] c551                      and.w     d2,(a1)
[0001070a] d2cb                      adda.w    a3,a1
[0001070c] 3801                      move.w    d1,d4
[0001070e] 6b08                      bmi.s     $00010718
[00010710] 3286                      move.w    d6,(a1)
[00010712] d2cb                      adda.w    a3,a1
[00010714] 51cc fffa                 dbf       d4,$00010710
[00010718] c751                      and.w     d3,(a1)
[0001071a] d2c7                      adda.w    d7,a1
[0001071c] 51cd ffea                 dbf       d5,$00010708
[00010720] 4642                      not.w     d2
[00010722] 4643                      not.w     d3
[00010724] 4e75                      rts
[00010726] 3c10                      move.w    (a0),d6
[00010728] 4642                      not.w     d2
[0001072a] 8c42                      or.w      d2,d6
[0001072c] 4642                      not.w     d2
[0001072e] cd51                      and.w     d6,(a1)
[00010730] d0ca                      adda.w    a2,a0
[00010732] d2cb                      adda.w    a3,a1
[00010734] 3801                      move.w    d1,d4
[00010736] 6b0c                      bmi.s     $00010744
[00010738] 3c10                      move.w    (a0),d6
[0001073a] cd51                      and.w     d6,(a1)
[0001073c] d0ca                      adda.w    a2,a0
[0001073e] d2cb                      adda.w    a3,a1
[00010740] 51cc fff6                 dbf       d4,$00010738
[00010744] 4ed5                      jmp       (a5)
[00010746] 3c10                      move.w    (a0),d6
[00010748] 4643                      not.w     d3
[0001074a] 8c43                      or.w      d3,d6
[0001074c] 4643                      not.w     d3
[0001074e] cd51                      and.w     d6,(a1)
[00010750] d0ee 01c6                 adda.w    454(a6),a0
[00010754] d2ee 01da                 adda.w    474(a6),a1
[00010758] 51cd ffcc                 dbf       d5,$00010726
[0001075c] 4e75                      rts
[0001075e] 3c10                      move.w    (a0),d6
[00010760] 4ed4                      jmp       (a4)
[00010762] 4846                      swap      d6
[00010764] d0ca                      adda.w    a2,a0
[00010766] 3c10                      move.w    (a0),d6
[00010768] 3e06                      move.w    d6,d7
[0001076a] e0be                      ror.l     d0,d6
[0001076c] 4642                      not.w     d2
[0001076e] 8c42                      or.w      d2,d6
[00010770] 4642                      not.w     d2
[00010772] cd51                      and.w     d6,(a1)
[00010774] d0ca                      adda.w    a2,a0
[00010776] d2cb                      adda.w    a3,a1
[00010778] 3801                      move.w    d1,d4
[0001077a] 6b14                      bmi.s     $00010790
[0001077c] 3c07                      move.w    d7,d6
[0001077e] 4846                      swap      d6
[00010780] 3c10                      move.w    (a0),d6
[00010782] 3e06                      move.w    d6,d7
[00010784] e0be                      ror.l     d0,d6
[00010786] cd51                      and.w     d6,(a1)
[00010788] d0ca                      adda.w    a2,a0
[0001078a] d2cb                      adda.w    a3,a1
[0001078c] 51cc ffee                 dbf       d4,$0001077C
[00010790] 4847                      swap      d7
[00010792] 4ed5                      jmp       (a5)
[00010794] 3e10                      move.w    (a0),d7
[00010796] e0bf                      ror.l     d0,d7
[00010798] 4643                      not.w     d3
[0001079a] 8e43                      or.w      d3,d7
[0001079c] 4643                      not.w     d3
[0001079e] cf51                      and.w     d7,(a1)
[000107a0] d0ee 01c6                 adda.w    454(a6),a0
[000107a4] d2ee 01da                 adda.w    474(a6),a1
[000107a8] 51cd ffb4                 dbf       d5,$0001075E
[000107ac] 4e75                      rts
[000107ae] 3c10                      move.w    (a0),d6
[000107b0] 4ed4                      jmp       (a4)
[000107b2] 4846                      swap      d6
[000107b4] d0ca                      adda.w    a2,a0
[000107b6] 3c10                      move.w    (a0),d6
[000107b8] 4846                      swap      d6
[000107ba] 2e06                      move.l    d6,d7
[000107bc] e1be                      rol.l     d0,d6
[000107be] 4642                      not.w     d2
[000107c0] 8c42                      or.w      d2,d6
[000107c2] 4642                      not.w     d2
[000107c4] cd51                      and.w     d6,(a1)
[000107c6] d0ca                      adda.w    a2,a0
[000107c8] d2cb                      adda.w    a3,a1
[000107ca] 3801                      move.w    d1,d4
[000107cc] 6b14                      bmi.s     $000107E2
[000107ce] 2c07                      move.l    d7,d6
[000107d0] 3c10                      move.w    (a0),d6
[000107d2] 4846                      swap      d6
[000107d4] 2e06                      move.l    d6,d7
[000107d6] e1be                      rol.l     d0,d6
[000107d8] cd51                      and.w     d6,(a1)
[000107da] d0ca                      adda.w    a2,a0
[000107dc] d2cb                      adda.w    a3,a1
[000107de] 51cc ffee                 dbf       d4,$000107CE
[000107e2] 4ed5                      jmp       (a5)
[000107e4] 3e10                      move.w    (a0),d7
[000107e6] 4847                      swap      d7
[000107e8] e1bf                      rol.l     d0,d7
[000107ea] 4643                      not.w     d3
[000107ec] 8e43                      or.w      d3,d7
[000107ee] 4643                      not.w     d3
[000107f0] cf51                      and.w     d7,(a1)
[000107f2] d0ee 01c6                 adda.w    454(a6),a0
[000107f6] d2ee 01da                 adda.w    474(a6),a1
[000107fa] 51cd ffb2                 dbf       d5,$000107AE
[000107fe] 4e75                      rts
[00010800] 3c10                      move.w    (a0),d6
[00010802] b551                      eor.w     d2,(a1)
[00010804] 4642                      not.w     d2
[00010806] 8c42                      or.w      d2,d6
[00010808] 4642                      not.w     d2
[0001080a] cd51                      and.w     d6,(a1)
[0001080c] d0ca                      adda.w    a2,a0
[0001080e] d2cb                      adda.w    a3,a1
[00010810] 3801                      move.w    d1,d4
[00010812] 6b0e                      bmi.s     $00010822
[00010814] 3c10                      move.w    (a0),d6
[00010816] 4651                      not.w     (a1)
[00010818] cd51                      and.w     d6,(a1)
[0001081a] d0ca                      adda.w    a2,a0
[0001081c] d2cb                      adda.w    a3,a1
[0001081e] 51cc fff4                 dbf       d4,$00010814
[00010822] 4ed5                      jmp       (a5)
[00010824] 3c10                      move.w    (a0),d6
[00010826] b751                      eor.w     d3,(a1)
[00010828] 4643                      not.w     d3
[0001082a] 8c43                      or.w      d3,d6
[0001082c] 4643                      not.w     d3
[0001082e] cd51                      and.w     d6,(a1)
[00010830] d0ee 01c6                 adda.w    454(a6),a0
[00010834] d2ee 01da                 adda.w    474(a6),a1
[00010838] 51cd ffc6                 dbf       d5,$00010800
[0001083c] 4e75                      rts
[0001083e] 3c10                      move.w    (a0),d6
[00010840] 4ed4                      jmp       (a4)
[00010842] 4846                      swap      d6
[00010844] d0ca                      adda.w    a2,a0
[00010846] 3c10                      move.w    (a0),d6
[00010848] 3e06                      move.w    d6,d7
[0001084a] e0be                      ror.l     d0,d6
[0001084c] b551                      eor.w     d2,(a1)
[0001084e] 4642                      not.w     d2
[00010850] 8c42                      or.w      d2,d6
[00010852] 4642                      not.w     d2
[00010854] cd51                      and.w     d6,(a1)
[00010856] d0ca                      adda.w    a2,a0
[00010858] d2cb                      adda.w    a3,a1
[0001085a] 3801                      move.w    d1,d4
[0001085c] 6b16                      bmi.s     $00010874
[0001085e] 3c07                      move.w    d7,d6
[00010860] 4846                      swap      d6
[00010862] 3c10                      move.w    (a0),d6
[00010864] 3e06                      move.w    d6,d7
[00010866] e0be                      ror.l     d0,d6
[00010868] 4651                      not.w     (a1)
[0001086a] cd51                      and.w     d6,(a1)
[0001086c] d0ca                      adda.w    a2,a0
[0001086e] d2cb                      adda.w    a3,a1
[00010870] 51cc ffec                 dbf       d4,$0001085E
[00010874] 4847                      swap      d7
[00010876] 4ed5                      jmp       (a5)
[00010878] 3e10                      move.w    (a0),d7
[0001087a] e0bf                      ror.l     d0,d7
[0001087c] b751                      eor.w     d3,(a1)
[0001087e] 4643                      not.w     d3
[00010880] 8e43                      or.w      d3,d7
[00010882] 4643                      not.w     d3
[00010884] cf51                      and.w     d7,(a1)
[00010886] d0ee 01c6                 adda.w    454(a6),a0
[0001088a] d2ee 01da                 adda.w    474(a6),a1
[0001088e] 51cd ffae                 dbf       d5,$0001083E
[00010892] 4e75                      rts
[00010894] 3c10                      move.w    (a0),d6
[00010896] 4ed4                      jmp       (a4)
[00010898] 4846                      swap      d6
[0001089a] d0ca                      adda.w    a2,a0
[0001089c] 3c10                      move.w    (a0),d6
[0001089e] 4846                      swap      d6
[000108a0] 2e06                      move.l    d6,d7
[000108a2] e1be                      rol.l     d0,d6
[000108a4] b551                      eor.w     d2,(a1)
[000108a6] 4642                      not.w     d2
[000108a8] 8c42                      or.w      d2,d6
[000108aa] 4642                      not.w     d2
[000108ac] cd51                      and.w     d6,(a1)
[000108ae] d0ca                      adda.w    a2,a0
[000108b0] d2cb                      adda.w    a3,a1
[000108b2] 3801                      move.w    d1,d4
[000108b4] 6b16                      bmi.s     $000108CC
[000108b6] 2c07                      move.l    d7,d6
[000108b8] 3c10                      move.w    (a0),d6
[000108ba] 4846                      swap      d6
[000108bc] 2e06                      move.l    d6,d7
[000108be] e1be                      rol.l     d0,d6
[000108c0] 4651                      not.w     (a1)
[000108c2] cd51                      and.w     d6,(a1)
[000108c4] d0ca                      adda.w    a2,a0
[000108c6] d2cb                      adda.w    a3,a1
[000108c8] 51cc ffec                 dbf       d4,$000108B6
[000108cc] 4ed5                      jmp       (a5)
[000108ce] 3e10                      move.w    (a0),d7
[000108d0] 4847                      swap      d7
[000108d2] e1bf                      rol.l     d0,d7
[000108d4] b751                      eor.w     d3,(a1)
[000108d6] 4643                      not.w     d3
[000108d8] 8e43                      or.w      d3,d7
[000108da] 4643                      not.w     d3
[000108dc] cf51                      and.w     d7,(a1)
[000108de] d0ee 01c6                 adda.w    454(a6),a0
[000108e2] d2ee 01da                 adda.w    474(a6),a1
[000108e6] 51cd ffac                 dbf       d5,$00010894
[000108ea] 4e75                      rts
[000108ec] 3c10                      move.w    (a0),d6
[000108ee] 4646                      not.w     d6
[000108f0] cc42                      and.w     d2,d6
[000108f2] 8551                      or.w      d2,(a1)
[000108f4] bd51                      eor.w     d6,(a1)
[000108f6] d0ca                      adda.w    a2,a0
[000108f8] d2cb                      adda.w    a3,a1
[000108fa] 3801                      move.w    d1,d4
[000108fc] 6b0a                      bmi.s     $00010908
[000108fe] 3290                      move.w    (a0),(a1)
[00010900] d0ca                      adda.w    a2,a0
[00010902] d2cb                      adda.w    a3,a1
[00010904] 51cc fff8                 dbf       d4,$000108FE
[00010908] 4ed5                      jmp       (a5)
[0001090a] 3c10                      move.w    (a0),d6
[0001090c] 4646                      not.w     d6
[0001090e] cc43                      and.w     d3,d6
[00010910] 8751                      or.w      d3,(a1)
[00010912] bd51                      eor.w     d6,(a1)
[00010914] d0ee 01c6                 adda.w    454(a6),a0
[00010918] d2ee 01da                 adda.w    474(a6),a1
[0001091c] 51cd ffce                 dbf       d5,$000108EC
[00010920] 4e75                      rts
[00010922] 3c10                      move.w    (a0),d6
[00010924] 4ed4                      jmp       (a4)
[00010926] 4846                      swap      d6
[00010928] d0ca                      adda.w    a2,a0
[0001092a] 3c10                      move.w    (a0),d6
[0001092c] 3e06                      move.w    d6,d7
[0001092e] e0be                      ror.l     d0,d6
[00010930] 4646                      not.w     d6
[00010932] cc42                      and.w     d2,d6
[00010934] 8551                      or.w      d2,(a1)
[00010936] bd51                      eor.w     d6,(a1)
[00010938] d0ca                      adda.w    a2,a0
[0001093a] d2cb                      adda.w    a3,a1
[0001093c] 3801                      move.w    d1,d4
[0001093e] 6b14                      bmi.s     $00010954
[00010940] 3c07                      move.w    d7,d6
[00010942] 4846                      swap      d6
[00010944] 3c10                      move.w    (a0),d6
[00010946] 3e06                      move.w    d6,d7
[00010948] e0be                      ror.l     d0,d6
[0001094a] 3286                      move.w    d6,(a1)
[0001094c] d0ca                      adda.w    a2,a0
[0001094e] d2cb                      adda.w    a3,a1
[00010950] 51cc ffee                 dbf       d4,$00010940
[00010954] 4847                      swap      d7
[00010956] 4ed5                      jmp       (a5)
[00010958] 3e10                      move.w    (a0),d7
[0001095a] e0bf                      ror.l     d0,d7
[0001095c] 4647                      not.w     d7
[0001095e] ce43                      and.w     d3,d7
[00010960] 8751                      or.w      d3,(a1)
[00010962] bf51                      eor.w     d7,(a1)
[00010964] d0ee 01c6                 adda.w    454(a6),a0
[00010968] d2ee 01da                 adda.w    474(a6),a1
[0001096c] 51cd ffb4                 dbf       d5,$00010922
[00010970] 4e75                      rts
[00010972] 3c10                      move.w    (a0),d6
[00010974] 4ed4                      jmp       (a4)
[00010976] 4846                      swap      d6
[00010978] d0ca                      adda.w    a2,a0
[0001097a] 3c10                      move.w    (a0),d6
[0001097c] 4846                      swap      d6
[0001097e] 2e06                      move.l    d6,d7
[00010980] e1be                      rol.l     d0,d6
[00010982] 4646                      not.w     d6
[00010984] cc42                      and.w     d2,d6
[00010986] 8551                      or.w      d2,(a1)
[00010988] bd51                      eor.w     d6,(a1)
[0001098a] d0ca                      adda.w    a2,a0
[0001098c] d2cb                      adda.w    a3,a1
[0001098e] 3801                      move.w    d1,d4
[00010990] 6b14                      bmi.s     $000109A6
[00010992] 2c07                      move.l    d7,d6
[00010994] 3c10                      move.w    (a0),d6
[00010996] 4846                      swap      d6
[00010998] 2e06                      move.l    d6,d7
[0001099a] e1be                      rol.l     d0,d6
[0001099c] 3286                      move.w    d6,(a1)
[0001099e] d0ca                      adda.w    a2,a0
[000109a0] d2cb                      adda.w    a3,a1
[000109a2] 51cc ffee                 dbf       d4,$00010992
[000109a6] 4ed5                      jmp       (a5)
[000109a8] 3e10                      move.w    (a0),d7
[000109aa] 4847                      swap      d7
[000109ac] e1bf                      rol.l     d0,d7
[000109ae] 4647                      not.w     d7
[000109b0] ce43                      and.w     d3,d7
[000109b2] 8751                      or.w      d3,(a1)
[000109b4] bf51                      eor.w     d7,(a1)
[000109b6] d0ee 01c6                 adda.w    454(a6),a0
[000109ba] d2ee 01da                 adda.w    474(a6),a1
[000109be] 51cd ffb2                 dbf       d5,$00010972
[000109c2] 4e75                      rts
[000109c4] 3c10                      move.w    (a0),d6
[000109c6] cc42                      and.w     d2,d6
[000109c8] 4646                      not.w     d6
[000109ca] cd51                      and.w     d6,(a1)
[000109cc] d0ca                      adda.w    a2,a0
[000109ce] d2cb                      adda.w    a3,a1
[000109d0] 3801                      move.w    d1,d4
[000109d2] 6b0e                      bmi.s     $000109E2
[000109d4] 3c10                      move.w    (a0),d6
[000109d6] 4646                      not.w     d6
[000109d8] cd51                      and.w     d6,(a1)
[000109da] d0ca                      adda.w    a2,a0
[000109dc] d2cb                      adda.w    a3,a1
[000109de] 51cc fff4                 dbf       d4,$000109D4
[000109e2] 4ed5                      jmp       (a5)
[000109e4] 3c10                      move.w    (a0),d6
[000109e6] cc43                      and.w     d3,d6
[000109e8] 4646                      not.w     d6
[000109ea] cd51                      and.w     d6,(a1)
[000109ec] d0ee 01c6                 adda.w    454(a6),a0
[000109f0] d2ee 01da                 adda.w    474(a6),a1
[000109f4] 51cd ffce                 dbf       d5,$000109C4
[000109f8] 4e75                      rts
[000109fa] 3c10                      move.w    (a0),d6
[000109fc] 4ed4                      jmp       (a4)
[000109fe] 4846                      swap      d6
[00010a00] d0ca                      adda.w    a2,a0
[00010a02] 3c10                      move.w    (a0),d6
[00010a04] 3e06                      move.w    d6,d7
[00010a06] e0be                      ror.l     d0,d6
[00010a08] cc42                      and.w     d2,d6
[00010a0a] 4646                      not.w     d6
[00010a0c] cd51                      and.w     d6,(a1)
[00010a0e] d0ca                      adda.w    a2,a0
[00010a10] d2cb                      adda.w    a3,a1
[00010a12] 3801                      move.w    d1,d4
[00010a14] 6b16                      bmi.s     $00010A2C
[00010a16] 3c07                      move.w    d7,d6
[00010a18] 4846                      swap      d6
[00010a1a] 3c10                      move.w    (a0),d6
[00010a1c] 3e06                      move.w    d6,d7
[00010a1e] e0be                      ror.l     d0,d6
[00010a20] 4646                      not.w     d6
[00010a22] cd51                      and.w     d6,(a1)
[00010a24] d0ca                      adda.w    a2,a0
[00010a26] d2cb                      adda.w    a3,a1
[00010a28] 51cc ffec                 dbf       d4,$00010A16
[00010a2c] 4847                      swap      d7
[00010a2e] 4ed5                      jmp       (a5)
[00010a30] 3e10                      move.w    (a0),d7
[00010a32] e0bf                      ror.l     d0,d7
[00010a34] ce43                      and.w     d3,d7
[00010a36] 4647                      not.w     d7
[00010a38] cf51                      and.w     d7,(a1)
[00010a3a] d0ee 01c6                 adda.w    454(a6),a0
[00010a3e] d2ee 01da                 adda.w    474(a6),a1
[00010a42] 51cd ffb6                 dbf       d5,$000109FA
[00010a46] 4e75                      rts
[00010a48] 3c10                      move.w    (a0),d6
[00010a4a] 4ed4                      jmp       (a4)
[00010a4c] 4846                      swap      d6
[00010a4e] d0ca                      adda.w    a2,a0
[00010a50] 3c10                      move.w    (a0),d6
[00010a52] 4846                      swap      d6
[00010a54] 2e06                      move.l    d6,d7
[00010a56] e1be                      rol.l     d0,d6
[00010a58] cc42                      and.w     d2,d6
[00010a5a] 4646                      not.w     d6
[00010a5c] cd51                      and.w     d6,(a1)
[00010a5e] d0ca                      adda.w    a2,a0
[00010a60] d2cb                      adda.w    a3,a1
[00010a62] 3801                      move.w    d1,d4
[00010a64] 6b16                      bmi.s     $00010A7C
[00010a66] 2c07                      move.l    d7,d6
[00010a68] 3c10                      move.w    (a0),d6
[00010a6a] 4846                      swap      d6
[00010a6c] 2e06                      move.l    d6,d7
[00010a6e] e1be                      rol.l     d0,d6
[00010a70] 4646                      not.w     d6
[00010a72] cd51                      and.w     d6,(a1)
[00010a74] d0ca                      adda.w    a2,a0
[00010a76] d2cb                      adda.w    a3,a1
[00010a78] 51cc ffec                 dbf       d4,$00010A66
[00010a7c] 4ed5                      jmp       (a5)
[00010a7e] 3e10                      move.w    (a0),d7
[00010a80] 4847                      swap      d7
[00010a82] e1bf                      rol.l     d0,d7
[00010a84] ce43                      and.w     d3,d7
[00010a86] 4647                      not.w     d7
[00010a88] cf51                      and.w     d7,(a1)
[00010a8a] d0ee 01c6                 adda.w    454(a6),a0
[00010a8e] d2ee 01da                 adda.w    474(a6),a1
[00010a92] 51cd ffb4                 dbf       d5,$00010A48
[00010a96] 4e75                      rts
[00010a98] 4e75                      rts
[00010a9a] 3c10                      move.w    (a0),d6
[00010a9c] cc42                      and.w     d2,d6
[00010a9e] bd51                      eor.w     d6,(a1)
[00010aa0] d0ca                      adda.w    a2,a0
[00010aa2] d2cb                      adda.w    a3,a1
[00010aa4] 3801                      move.w    d1,d4
[00010aa6] 6b0c                      bmi.s     $00010AB4
[00010aa8] 3c10                      move.w    (a0),d6
[00010aaa] bd51                      eor.w     d6,(a1)
[00010aac] d0ca                      adda.w    a2,a0
[00010aae] d2cb                      adda.w    a3,a1
[00010ab0] 51cc fff6                 dbf       d4,$00010AA8
[00010ab4] 4ed5                      jmp       (a5)
[00010ab6] 3c10                      move.w    (a0),d6
[00010ab8] cc43                      and.w     d3,d6
[00010aba] bd51                      eor.w     d6,(a1)
[00010abc] d0ee 01c6                 adda.w    454(a6),a0
[00010ac0] d2ee 01da                 adda.w    474(a6),a1
[00010ac4] 51cd ffd4                 dbf       d5,$00010A9A
[00010ac8] 4e75                      rts
[00010aca] 3c10                      move.w    (a0),d6
[00010acc] 4ed4                      jmp       (a4)
[00010ace] 4846                      swap      d6
[00010ad0] d0ca                      adda.w    a2,a0
[00010ad2] 3c10                      move.w    (a0),d6
[00010ad4] 3e06                      move.w    d6,d7
[00010ad6] e0be                      ror.l     d0,d6
[00010ad8] cc42                      and.w     d2,d6
[00010ada] bd51                      eor.w     d6,(a1)
[00010adc] d0ca                      adda.w    a2,a0
[00010ade] d2cb                      adda.w    a3,a1
[00010ae0] 3801                      move.w    d1,d4
[00010ae2] 6b14                      bmi.s     $00010AF8
[00010ae4] 3c07                      move.w    d7,d6
[00010ae6] 4846                      swap      d6
[00010ae8] 3c10                      move.w    (a0),d6
[00010aea] 3e06                      move.w    d6,d7
[00010aec] e0be                      ror.l     d0,d6
[00010aee] bd51                      eor.w     d6,(a1)
[00010af0] d0ca                      adda.w    a2,a0
[00010af2] d2cb                      adda.w    a3,a1
[00010af4] 51cc ffee                 dbf       d4,$00010AE4
[00010af8] 4847                      swap      d7
[00010afa] 4ed5                      jmp       (a5)
[00010afc] 3e10                      move.w    (a0),d7
[00010afe] e0bf                      ror.l     d0,d7
[00010b00] ce43                      and.w     d3,d7
[00010b02] bf51                      eor.w     d7,(a1)
[00010b04] d0ee 01c6                 adda.w    454(a6),a0
[00010b08] d2ee 01da                 adda.w    474(a6),a1
[00010b0c] 51cd ffbc                 dbf       d5,$00010ACA
[00010b10] 4e75                      rts
[00010b12] 3c10                      move.w    (a0),d6
[00010b14] 4ed4                      jmp       (a4)
[00010b16] 4846                      swap      d6
[00010b18] d0ca                      adda.w    a2,a0
[00010b1a] 3c10                      move.w    (a0),d6
[00010b1c] 4846                      swap      d6
[00010b1e] 2e06                      move.l    d6,d7
[00010b20] e1be                      rol.l     d0,d6
[00010b22] cc42                      and.w     d2,d6
[00010b24] bd51                      eor.w     d6,(a1)
[00010b26] d0ca                      adda.w    a2,a0
[00010b28] d2cb                      adda.w    a3,a1
[00010b2a] 3801                      move.w    d1,d4
[00010b2c] 6b14                      bmi.s     $00010B42
[00010b2e] 2c07                      move.l    d7,d6
[00010b30] 3c10                      move.w    (a0),d6
[00010b32] 4846                      swap      d6
[00010b34] 2e06                      move.l    d6,d7
[00010b36] e1be                      rol.l     d0,d6
[00010b38] bd51                      eor.w     d6,(a1)
[00010b3a] d0ca                      adda.w    a2,a0
[00010b3c] d2cb                      adda.w    a3,a1
[00010b3e] 51cc ffee                 dbf       d4,$00010B2E
[00010b42] 4ed5                      jmp       (a5)
[00010b44] 3e10                      move.w    (a0),d7
[00010b46] 4847                      swap      d7
[00010b48] e1bf                      rol.l     d0,d7
[00010b4a] ce43                      and.w     d3,d7
[00010b4c] bf51                      eor.w     d7,(a1)
[00010b4e] d0ee 01c6                 adda.w    454(a6),a0
[00010b52] d2ee 01da                 adda.w    474(a6),a1
[00010b56] 51cd ffba                 dbf       d5,$00010B12
[00010b5a] 4e75                      rts
[00010b5c] 3c10                      move.w    (a0),d6
[00010b5e] cc42                      and.w     d2,d6
[00010b60] 8d51                      or.w      d6,(a1)
[00010b62] d0ca                      adda.w    a2,a0
[00010b64] d2cb                      adda.w    a3,a1
[00010b66] 3801                      move.w    d1,d4
[00010b68] 6b0c                      bmi.s     $00010B76
[00010b6a] 3c10                      move.w    (a0),d6
[00010b6c] 8d51                      or.w      d6,(a1)
[00010b6e] d0ca                      adda.w    a2,a0
[00010b70] d2cb                      adda.w    a3,a1
[00010b72] 51cc fff6                 dbf       d4,$00010B6A
[00010b76] 4ed5                      jmp       (a5)
[00010b78] 3c10                      move.w    (a0),d6
[00010b7a] cc43                      and.w     d3,d6
[00010b7c] 8d51                      or.w      d6,(a1)
[00010b7e] d0ee 01c6                 adda.w    454(a6),a0
[00010b82] d2ee 01da                 adda.w    474(a6),a1
[00010b86] 51cd ffd4                 dbf       d5,$00010B5C
[00010b8a] 4e75                      rts
[00010b8c] 3c10                      move.w    (a0),d6
[00010b8e] 4ed4                      jmp       (a4)
[00010b90] 4846                      swap      d6
[00010b92] d0ca                      adda.w    a2,a0
[00010b94] 3c10                      move.w    (a0),d6
[00010b96] 3e06                      move.w    d6,d7
[00010b98] e0be                      ror.l     d0,d6
[00010b9a] cc42                      and.w     d2,d6
[00010b9c] 8d51                      or.w      d6,(a1)
[00010b9e] d0ca                      adda.w    a2,a0
[00010ba0] d2cb                      adda.w    a3,a1
[00010ba2] 3801                      move.w    d1,d4
[00010ba4] 6b14                      bmi.s     $00010BBA
[00010ba6] 3c07                      move.w    d7,d6
[00010ba8] 4846                      swap      d6
[00010baa] 3c10                      move.w    (a0),d6
[00010bac] 3e06                      move.w    d6,d7
[00010bae] e0be                      ror.l     d0,d6
[00010bb0] 8d51                      or.w      d6,(a1)
[00010bb2] d0ca                      adda.w    a2,a0
[00010bb4] d2cb                      adda.w    a3,a1
[00010bb6] 51cc ffee                 dbf       d4,$00010BA6
[00010bba] 4847                      swap      d7
[00010bbc] 4ed5                      jmp       (a5)
[00010bbe] 3e10                      move.w    (a0),d7
[00010bc0] e0bf                      ror.l     d0,d7
[00010bc2] ce43                      and.w     d3,d7
[00010bc4] 8f51                      or.w      d7,(a1)
[00010bc6] d0ee 01c6                 adda.w    454(a6),a0
[00010bca] d2ee 01da                 adda.w    474(a6),a1
[00010bce] 51cd ffbc                 dbf       d5,$00010B8C
[00010bd2] 4e75                      rts
[00010bd4] 3c10                      move.w    (a0),d6
[00010bd6] 4ed4                      jmp       (a4)
[00010bd8] 4846                      swap      d6
[00010bda] d0ca                      adda.w    a2,a0
[00010bdc] 3c10                      move.w    (a0),d6
[00010bde] 4846                      swap      d6
[00010be0] 2e06                      move.l    d6,d7
[00010be2] e1be                      rol.l     d0,d6
[00010be4] cc42                      and.w     d2,d6
[00010be6] 8d51                      or.w      d6,(a1)
[00010be8] d0ca                      adda.w    a2,a0
[00010bea] d2cb                      adda.w    a3,a1
[00010bec] 3801                      move.w    d1,d4
[00010bee] 6b14                      bmi.s     $00010C04
[00010bf0] 2c07                      move.l    d7,d6
[00010bf2] 3c10                      move.w    (a0),d6
[00010bf4] 4846                      swap      d6
[00010bf6] 2e06                      move.l    d6,d7
[00010bf8] e1be                      rol.l     d0,d6
[00010bfa] 8d51                      or.w      d6,(a1)
[00010bfc] d0ca                      adda.w    a2,a0
[00010bfe] d2cb                      adda.w    a3,a1
[00010c00] 51cc ffee                 dbf       d4,$00010BF0
[00010c04] 4ed5                      jmp       (a5)
[00010c06] 3e10                      move.w    (a0),d7
[00010c08] 4847                      swap      d7
[00010c0a] e1bf                      rol.l     d0,d7
[00010c0c] ce43                      and.w     d3,d7
[00010c0e] 8f51                      or.w      d7,(a1)
[00010c10] d0ee 01c6                 adda.w    454(a6),a0
[00010c14] d2ee 01da                 adda.w    474(a6),a1
[00010c18] 51cd ffba                 dbf       d5,$00010BD4
[00010c1c] 4e75                      rts
[00010c1e] 3c10                      move.w    (a0),d6
[00010c20] cc42                      and.w     d2,d6
[00010c22] 8d51                      or.w      d6,(a1)
[00010c24] b551                      eor.w     d2,(a1)
[00010c26] d0ca                      adda.w    a2,a0
[00010c28] d2cb                      adda.w    a3,a1
[00010c2a] 3801                      move.w    d1,d4
[00010c2c] 6b0e                      bmi.s     $00010C3C
[00010c2e] 3c10                      move.w    (a0),d6
[00010c30] 8d51                      or.w      d6,(a1)
[00010c32] 4651                      not.w     (a1)
[00010c34] d0ca                      adda.w    a2,a0
[00010c36] d2cb                      adda.w    a3,a1
[00010c38] 51cc fff4                 dbf       d4,$00010C2E
[00010c3c] 4ed5                      jmp       (a5)
[00010c3e] 3c10                      move.w    (a0),d6
[00010c40] cc43                      and.w     d3,d6
[00010c42] 8d51                      or.w      d6,(a1)
[00010c44] b751                      eor.w     d3,(a1)
[00010c46] d0ee 01c6                 adda.w    454(a6),a0
[00010c4a] d2ee 01da                 adda.w    474(a6),a1
[00010c4e] 51cd ffce                 dbf       d5,$00010C1E
[00010c52] 4e75                      rts
[00010c54] 3c10                      move.w    (a0),d6
[00010c56] 4ed4                      jmp       (a4)
[00010c58] 4846                      swap      d6
[00010c5a] d0ca                      adda.w    a2,a0
[00010c5c] 3c10                      move.w    (a0),d6
[00010c5e] 3e06                      move.w    d6,d7
[00010c60] e0be                      ror.l     d0,d6
[00010c62] cc42                      and.w     d2,d6
[00010c64] 8d51                      or.w      d6,(a1)
[00010c66] b551                      eor.w     d2,(a1)
[00010c68] d0ca                      adda.w    a2,a0
[00010c6a] d2cb                      adda.w    a3,a1
[00010c6c] 3801                      move.w    d1,d4
[00010c6e] 6b14                      bmi.s     $00010C84
[00010c70] 3c07                      move.w    d7,d6
[00010c72] 4846                      swap      d6
[00010c74] 3c10                      move.w    (a0),d6
[00010c76] 3e06                      move.w    d6,d7
[00010c78] e0be                      ror.l     d0,d6
[00010c7a] 8d51                      or.w      d6,(a1)
[00010c7c] d0ca                      adda.w    a2,a0
[00010c7e] d2cb                      adda.w    a3,a1
[00010c80] 51cc ffee                 dbf       d4,$00010C70
[00010c84] 4847                      swap      d7
[00010c86] 4ed5                      jmp       (a5)
[00010c88] 3e10                      move.w    (a0),d7
[00010c8a] e0bf                      ror.l     d0,d7
[00010c8c] ce43                      and.w     d3,d7
[00010c8e] 8f51                      or.w      d7,(a1)
[00010c90] b751                      eor.w     d3,(a1)
[00010c92] d0ee 01c6                 adda.w    454(a6),a0
[00010c96] d2ee 01da                 adda.w    474(a6),a1
[00010c9a] 51cd ffb8                 dbf       d5,$00010C54
[00010c9e] 4e75                      rts
[00010ca0] 3c10                      move.w    (a0),d6
[00010ca2] 4ed4                      jmp       (a4)
[00010ca4] 4846                      swap      d6
[00010ca6] d0ca                      adda.w    a2,a0
[00010ca8] 3c10                      move.w    (a0),d6
[00010caa] 4846                      swap      d6
[00010cac] 2e06                      move.l    d6,d7
[00010cae] e1be                      rol.l     d0,d6
[00010cb0] cc42                      and.w     d2,d6
[00010cb2] 8d51                      or.w      d6,(a1)
[00010cb4] b551                      eor.w     d2,(a1)
[00010cb6] d0ca                      adda.w    a2,a0
[00010cb8] d2cb                      adda.w    a3,a1
[00010cba] 3801                      move.w    d1,d4
[00010cbc] 6b16                      bmi.s     $00010CD4
[00010cbe] 2c07                      move.l    d7,d6
[00010cc0] 3c10                      move.w    (a0),d6
[00010cc2] 4846                      swap      d6
[00010cc4] 2e06                      move.l    d6,d7
[00010cc6] e1be                      rol.l     d0,d6
[00010cc8] 8d51                      or.w      d6,(a1)
[00010cca] 4651                      not.w     (a1)
[00010ccc] d0ca                      adda.w    a2,a0
[00010cce] d2cb                      adda.w    a3,a1
[00010cd0] 51cc ffec                 dbf       d4,$00010CBE
[00010cd4] 4ed5                      jmp       (a5)
[00010cd6] 3e10                      move.w    (a0),d7
[00010cd8] 4847                      swap      d7
[00010cda] e1bf                      rol.l     d0,d7
[00010cdc] ce43                      and.w     d3,d7
[00010cde] 8f51                      or.w      d7,(a1)
[00010ce0] b751                      eor.w     d3,(a1)
[00010ce2] d0ee 01c6                 adda.w    454(a6),a0
[00010ce6] d2ee 01da                 adda.w    474(a6),a1
[00010cea] 51cd ffb4                 dbf       d5,$00010CA0
[00010cee] 4e75                      rts
[00010cf0] 3c10                      move.w    (a0),d6
[00010cf2] 4646                      not.w     d6
[00010cf4] cc42                      and.w     d2,d6
[00010cf6] bd51                      eor.w     d6,(a1)
[00010cf8] d0ca                      adda.w    a2,a0
[00010cfa] d2cb                      adda.w    a3,a1
[00010cfc] 3801                      move.w    d1,d4
[00010cfe] 6b0e                      bmi.s     $00010D0E
[00010d00] 3c10                      move.w    (a0),d6
[00010d02] 4646                      not.w     d6
[00010d04] bd51                      eor.w     d6,(a1)
[00010d06] d0ca                      adda.w    a2,a0
[00010d08] d2cb                      adda.w    a3,a1
[00010d0a] 51cc fff4                 dbf       d4,$00010D00
[00010d0e] 4ed5                      jmp       (a5)
[00010d10] 3c10                      move.w    (a0),d6
[00010d12] 4646                      not.w     d6
[00010d14] cc43                      and.w     d3,d6
[00010d16] bd51                      eor.w     d6,(a1)
[00010d18] d0ee 01c6                 adda.w    454(a6),a0
[00010d1c] d2ee 01da                 adda.w    474(a6),a1
[00010d20] 51cd ffce                 dbf       d5,$00010CF0
[00010d24] 4e75                      rts
[00010d26] 3c10                      move.w    (a0),d6
[00010d28] 4ed4                      jmp       (a4)
[00010d2a] 4846                      swap      d6
[00010d2c] d0ca                      adda.w    a2,a0
[00010d2e] 3c10                      move.w    (a0),d6
[00010d30] 3e06                      move.w    d6,d7
[00010d32] e0be                      ror.l     d0,d6
[00010d34] 4646                      not.w     d6
[00010d36] cc42                      and.w     d2,d6
[00010d38] bd51                      eor.w     d6,(a1)
[00010d3a] d0ca                      adda.w    a2,a0
[00010d3c] d2cb                      adda.w    a3,a1
[00010d3e] 3801                      move.w    d1,d4
[00010d40] 6b16                      bmi.s     $00010D58
[00010d42] 3c07                      move.w    d7,d6
[00010d44] 4846                      swap      d6
[00010d46] 3c10                      move.w    (a0),d6
[00010d48] 3e06                      move.w    d6,d7
[00010d4a] e0be                      ror.l     d0,d6
[00010d4c] 4646                      not.w     d6
[00010d4e] bd51                      eor.w     d6,(a1)
[00010d50] d0ca                      adda.w    a2,a0
[00010d52] d2cb                      adda.w    a3,a1
[00010d54] 51cc ffec                 dbf       d4,$00010D42
[00010d58] 4847                      swap      d7
[00010d5a] 4ed5                      jmp       (a5)
[00010d5c] 3e10                      move.w    (a0),d7
[00010d5e] e0bf                      ror.l     d0,d7
[00010d60] 4647                      not.w     d7
[00010d62] ce43                      and.w     d3,d7
[00010d64] bf51                      eor.w     d7,(a1)
[00010d66] d0ee 01c6                 adda.w    454(a6),a0
[00010d6a] d2ee 01da                 adda.w    474(a6),a1
[00010d6e] 51cd ffb6                 dbf       d5,$00010D26
[00010d72] 4e75                      rts
[00010d74] 3c10                      move.w    (a0),d6
[00010d76] 4ed4                      jmp       (a4)
[00010d78] 4846                      swap      d6
[00010d7a] d0ca                      adda.w    a2,a0
[00010d7c] 3c10                      move.w    (a0),d6
[00010d7e] 4846                      swap      d6
[00010d80] 2e06                      move.l    d6,d7
[00010d82] e1be                      rol.l     d0,d6
[00010d84] 4646                      not.w     d6
[00010d86] cc42                      and.w     d2,d6
[00010d88] bd51                      eor.w     d6,(a1)
[00010d8a] d0ca                      adda.w    a2,a0
[00010d8c] d2cb                      adda.w    a3,a1
[00010d8e] 3801                      move.w    d1,d4
[00010d90] 6b16                      bmi.s     $00010DA8
[00010d92] 2c07                      move.l    d7,d6
[00010d94] 3c10                      move.w    (a0),d6
[00010d96] 4846                      swap      d6
[00010d98] 2e06                      move.l    d6,d7
[00010d9a] e1be                      rol.l     d0,d6
[00010d9c] 4646                      not.w     d6
[00010d9e] bd51                      eor.w     d6,(a1)
[00010da0] d0ca                      adda.w    a2,a0
[00010da2] d2cb                      adda.w    a3,a1
[00010da4] 51cc ffec                 dbf       d4,$00010D92
[00010da8] 4ed5                      jmp       (a5)
[00010daa] 3e10                      move.w    (a0),d7
[00010dac] 4847                      swap      d7
[00010dae] e1bf                      rol.l     d0,d7
[00010db0] 4647                      not.w     d7
[00010db2] ce43                      and.w     d3,d7
[00010db4] bf51                      eor.w     d7,(a1)
[00010db6] d0ee 01c6                 adda.w    454(a6),a0
[00010dba] d2ee 01da                 adda.w    474(a6),a1
[00010dbe] 51cd ffb4                 dbf       d5,$00010D74
[00010dc2] 4e75                      rts
[00010dc4] 3e2e 01da                 move.w    474(a6),d7
[00010dc8] 4a43                      tst.w     d3
[00010dca] 660c                      bne.s     $00010DD8
[00010dcc] de4b                      add.w     a3,d7
[00010dce] b551                      eor.w     d2,(a1)
[00010dd0] d2c7                      adda.w    d7,a1
[00010dd2] 51cd fffa                 dbf       d5,$00010DCE
[00010dd6] 4e75                      rts
[00010dd8] b551                      eor.w     d2,(a1)
[00010dda] d2cb                      adda.w    a3,a1
[00010ddc] 3801                      move.w    d1,d4
[00010dde] 6b08                      bmi.s     $00010DE8
[00010de0] 4651                      not.w     (a1)
[00010de2] d2cb                      adda.w    a3,a1
[00010de4] 51cc fffa                 dbf       d4,$00010DE0
[00010de8] b751                      eor.w     d3,(a1)
[00010dea] d2c7                      adda.w    d7,a1
[00010dec] 51cd ffea                 dbf       d5,$00010DD8
[00010df0] 4e75                      rts
[00010df2] 3c10                      move.w    (a0),d6
[00010df4] cc42                      and.w     d2,d6
[00010df6] b551                      eor.w     d2,(a1)
[00010df8] 8d51                      or.w      d6,(a1)
[00010dfa] d0ca                      adda.w    a2,a0
[00010dfc] d2cb                      adda.w    a3,a1
[00010dfe] 3801                      move.w    d1,d4
[00010e00] 6b0e                      bmi.s     $00010E10
[00010e02] 3c10                      move.w    (a0),d6
[00010e04] 4651                      not.w     (a1)
[00010e06] 8d51                      or.w      d6,(a1)
[00010e08] d0ca                      adda.w    a2,a0
[00010e0a] d2cb                      adda.w    a3,a1
[00010e0c] 51cc fff4                 dbf       d4,$00010E02
[00010e10] 4ed5                      jmp       (a5)
[00010e12] 3c10                      move.w    (a0),d6
[00010e14] cc43                      and.w     d3,d6
[00010e16] b751                      eor.w     d3,(a1)
[00010e18] 8d51                      or.w      d6,(a1)
[00010e1a] d0ee 01c6                 adda.w    454(a6),a0
[00010e1e] d2ee 01da                 adda.w    474(a6),a1
[00010e22] 51cd ffce                 dbf       d5,$00010DF2
[00010e26] 4e75                      rts
[00010e28] 3c10                      move.w    (a0),d6
[00010e2a] 4ed4                      jmp       (a4)
[00010e2c] 4846                      swap      d6
[00010e2e] d0ca                      adda.w    a2,a0
[00010e30] 3c10                      move.w    (a0),d6
[00010e32] 3e06                      move.w    d6,d7
[00010e34] e0be                      ror.l     d0,d6
[00010e36] cc42                      and.w     d2,d6
[00010e38] b551                      eor.w     d2,(a1)
[00010e3a] 8d51                      or.w      d6,(a1)
[00010e3c] d0ca                      adda.w    a2,a0
[00010e3e] d2cb                      adda.w    a3,a1
[00010e40] 3801                      move.w    d1,d4
[00010e42] 6b16                      bmi.s     $00010E5A
[00010e44] 3c07                      move.w    d7,d6
[00010e46] 4846                      swap      d6
[00010e48] 3c10                      move.w    (a0),d6
[00010e4a] 3e06                      move.w    d6,d7
[00010e4c] e0be                      ror.l     d0,d6
[00010e4e] 4651                      not.w     (a1)
[00010e50] 8d51                      or.w      d6,(a1)
[00010e52] d0ca                      adda.w    a2,a0
[00010e54] d2cb                      adda.w    a3,a1
[00010e56] 51cc ffec                 dbf       d4,$00010E44
[00010e5a] 4847                      swap      d7
[00010e5c] 4ed5                      jmp       (a5)
[00010e5e] 3e10                      move.w    (a0),d7
[00010e60] e0bf                      ror.l     d0,d7
[00010e62] ce43                      and.w     d3,d7
[00010e64] b751                      eor.w     d3,(a1)
[00010e66] 8f51                      or.w      d7,(a1)
[00010e68] d0ee 01c6                 adda.w    454(a6),a0
[00010e6c] d2ee 01da                 adda.w    474(a6),a1
[00010e70] 51cd ffb6                 dbf       d5,$00010E28
[00010e74] 4e75                      rts
[00010e76] 3c10                      move.w    (a0),d6
[00010e78] 4ed4                      jmp       (a4)
[00010e7a] 4846                      swap      d6
[00010e7c] d0ca                      adda.w    a2,a0
[00010e7e] 3c10                      move.w    (a0),d6
[00010e80] 4846                      swap      d6
[00010e82] 2e06                      move.l    d6,d7
[00010e84] e1be                      rol.l     d0,d6
[00010e86] cc42                      and.w     d2,d6
[00010e88] b551                      eor.w     d2,(a1)
[00010e8a] 8d51                      or.w      d6,(a1)
[00010e8c] d0ca                      adda.w    a2,a0
[00010e8e] d2cb                      adda.w    a3,a1
[00010e90] 3801                      move.w    d1,d4
[00010e92] 6b16                      bmi.s     $00010EAA
[00010e94] 2c07                      move.l    d7,d6
[00010e96] 3c10                      move.w    (a0),d6
[00010e98] 4846                      swap      d6
[00010e9a] 2e06                      move.l    d6,d7
[00010e9c] e1be                      rol.l     d0,d6
[00010e9e] 4651                      not.w     (a1)
[00010ea0] 8d51                      or.w      d6,(a1)
[00010ea2] d0ca                      adda.w    a2,a0
[00010ea4] d2cb                      adda.w    a3,a1
[00010ea6] 51cc ffec                 dbf       d4,$00010E94
[00010eaa] 4ed5                      jmp       (a5)
[00010eac] 3e10                      move.w    (a0),d7
[00010eae] 4847                      swap      d7
[00010eb0] e1bf                      rol.l     d0,d7
[00010eb2] ce43                      and.w     d3,d7
[00010eb4] b751                      eor.w     d3,(a1)
[00010eb6] 8f51                      or.w      d7,(a1)
[00010eb8] d0ee 01c6                 adda.w    454(a6),a0
[00010ebc] d2ee 01da                 adda.w    474(a6),a1
[00010ec0] 51cd ffb4                 dbf       d5,$00010E76
[00010ec4] 4e75                      rts
[00010ec6] 3c10                      move.w    (a0),d6
[00010ec8] 4646                      not.w     d6
[00010eca] cc42                      and.w     d2,d6
[00010ecc] 4642                      not.w     d2
[00010ece] c551                      and.w     d2,(a1)
[00010ed0] 4642                      not.w     d2
[00010ed2] 8d51                      or.w      d6,(a1)
[00010ed4] d0ca                      adda.w    a2,a0
[00010ed6] d2cb                      adda.w    a3,a1
[00010ed8] 3801                      move.w    d1,d4
[00010eda] 6b0e                      bmi.s     $00010EEA
[00010edc] 3c10                      move.w    (a0),d6
[00010ede] 4646                      not.w     d6
[00010ee0] 3286                      move.w    d6,(a1)
[00010ee2] d0ca                      adda.w    a2,a0
[00010ee4] d2cb                      adda.w    a3,a1
[00010ee6] 51cc fff4                 dbf       d4,$00010EDC
[00010eea] 4ed5                      jmp       (a5)
[00010eec] 3c10                      move.w    (a0),d6
[00010eee] 4646                      not.w     d6
[00010ef0] cc43                      and.w     d3,d6
[00010ef2] 4643                      not.w     d3
[00010ef4] c751                      and.w     d3,(a1)
[00010ef6] 4643                      not.w     d3
[00010ef8] 8d51                      or.w      d6,(a1)
[00010efa] d0ee 01c6                 adda.w    454(a6),a0
[00010efe] d2ee 01da                 adda.w    474(a6),a1
[00010f02] 51cd ffc2                 dbf       d5,$00010EC6
[00010f06] 4e75                      rts
[00010f08] 3c10                      move.w    (a0),d6
[00010f0a] 4ed4                      jmp       (a4)
[00010f0c] 4846                      swap      d6
[00010f0e] d0ca                      adda.w    a2,a0
[00010f10] 3c10                      move.w    (a0),d6
[00010f12] 3e06                      move.w    d6,d7
[00010f14] e0be                      ror.l     d0,d6
[00010f16] 4646                      not.w     d6
[00010f18] cc42                      and.w     d2,d6
[00010f1a] 4642                      not.w     d2
[00010f1c] c551                      and.w     d2,(a1)
[00010f1e] 4642                      not.w     d2
[00010f20] 8d51                      or.w      d6,(a1)
[00010f22] d0ca                      adda.w    a2,a0
[00010f24] d2cb                      adda.w    a3,a1
[00010f26] 3801                      move.w    d1,d4
[00010f28] 6b16                      bmi.s     $00010F40
[00010f2a] 3c07                      move.w    d7,d6
[00010f2c] 4846                      swap      d6
[00010f2e] 3c10                      move.w    (a0),d6
[00010f30] 3e06                      move.w    d6,d7
[00010f32] e0be                      ror.l     d0,d6
[00010f34] 4646                      not.w     d6
[00010f36] 3286                      move.w    d6,(a1)
[00010f38] d0ca                      adda.w    a2,a0
[00010f3a] d2cb                      adda.w    a3,a1
[00010f3c] 51cc ffec                 dbf       d4,$00010F2A
[00010f40] 4847                      swap      d7
[00010f42] 4ed5                      jmp       (a5)
[00010f44] 3e10                      move.w    (a0),d7
[00010f46] e0bf                      ror.l     d0,d7
[00010f48] 4647                      not.w     d7
[00010f4a] ce43                      and.w     d3,d7
[00010f4c] 4643                      not.w     d3
[00010f4e] c751                      and.w     d3,(a1)
[00010f50] 4643                      not.w     d3
[00010f52] 8f51                      or.w      d7,(a1)
[00010f54] d0ee 01c6                 adda.w    454(a6),a0
[00010f58] d2ee 01da                 adda.w    474(a6),a1
[00010f5c] 51cd ffaa                 dbf       d5,$00010F08
[00010f60] 4e75                      rts
[00010f62] 3c10                      move.w    (a0),d6
[00010f64] 4ed4                      jmp       (a4)
[00010f66] 4846                      swap      d6
[00010f68] d0ca                      adda.w    a2,a0
[00010f6a] 3c10                      move.w    (a0),d6
[00010f6c] 4846                      swap      d6
[00010f6e] 2e06                      move.l    d6,d7
[00010f70] e1be                      rol.l     d0,d6
[00010f72] 4646                      not.w     d6
[00010f74] cc42                      and.w     d2,d6
[00010f76] 4642                      not.w     d2
[00010f78] c551                      and.w     d2,(a1)
[00010f7a] 4642                      not.w     d2
[00010f7c] 8d51                      or.w      d6,(a1)
[00010f7e] d0ca                      adda.w    a2,a0
[00010f80] d2cb                      adda.w    a3,a1
[00010f82] 3801                      move.w    d1,d4
[00010f84] 6b16                      bmi.s     $00010F9C
[00010f86] 2c07                      move.l    d7,d6
[00010f88] 3c10                      move.w    (a0),d6
[00010f8a] 4846                      swap      d6
[00010f8c] 2e06                      move.l    d6,d7
[00010f8e] e1be                      rol.l     d0,d6
[00010f90] 4646                      not.w     d6
[00010f92] 3286                      move.w    d6,(a1)
[00010f94] d0ca                      adda.w    a2,a0
[00010f96] d2cb                      adda.w    a3,a1
[00010f98] 51cc ffec                 dbf       d4,$00010F86
[00010f9c] 4ed5                      jmp       (a5)
[00010f9e] 3e10                      move.w    (a0),d7
[00010fa0] 4847                      swap      d7
[00010fa2] e1bf                      rol.l     d0,d7
[00010fa4] 4647                      not.w     d7
[00010fa6] ce43                      and.w     d3,d7
[00010fa8] 4643                      not.w     d3
[00010faa] c751                      and.w     d3,(a1)
[00010fac] 4643                      not.w     d3
[00010fae] 8f51                      or.w      d7,(a1)
[00010fb0] d0ee 01c6                 adda.w    454(a6),a0
[00010fb4] d2ee 01da                 adda.w    474(a6),a1
[00010fb8] 51cd ffa8                 dbf       d5,$00010F62
[00010fbc] 4e75                      rts
[00010fbe] 3c10                      move.w    (a0),d6
[00010fc0] 4646                      not.w     d6
[00010fc2] cc42                      and.w     d2,d6
[00010fc4] 8d51                      or.w      d6,(a1)
[00010fc6] d0ca                      adda.w    a2,a0
[00010fc8] d2cb                      adda.w    a3,a1
[00010fca] 3801                      move.w    d1,d4
[00010fcc] 6b0e                      bmi.s     $00010FDC
[00010fce] 3c10                      move.w    (a0),d6
[00010fd0] 4646                      not.w     d6
[00010fd2] 8d51                      or.w      d6,(a1)
[00010fd4] d0ca                      adda.w    a2,a0
[00010fd6] d2cb                      adda.w    a3,a1
[00010fd8] 51cc fff4                 dbf       d4,$00010FCE
[00010fdc] 4ed5                      jmp       (a5)
[00010fde] 3c10                      move.w    (a0),d6
[00010fe0] 4646                      not.w     d6
[00010fe2] cc43                      and.w     d3,d6
[00010fe4] 8d51                      or.w      d6,(a1)
[00010fe6] d0ee 01c6                 adda.w    454(a6),a0
[00010fea] d2ee 01da                 adda.w    474(a6),a1
[00010fee] 51cd ffce                 dbf       d5,$00010FBE
[00010ff2] 4e75                      rts
[00010ff4] 3c10                      move.w    (a0),d6
[00010ff6] 4ed4                      jmp       (a4)
[00010ff8] 4846                      swap      d6
[00010ffa] d0ca                      adda.w    a2,a0
[00010ffc] 3c10                      move.w    (a0),d6
[00010ffe] 3e06                      move.w    d6,d7
[00011000] e0be                      ror.l     d0,d6
[00011002] 4646                      not.w     d6
[00011004] cc42                      and.w     d2,d6
[00011006] 8d51                      or.w      d6,(a1)
[00011008] d0ca                      adda.w    a2,a0
[0001100a] d2cb                      adda.w    a3,a1
[0001100c] 3801                      move.w    d1,d4
[0001100e] 6b16                      bmi.s     $00011026
[00011010] 3c07                      move.w    d7,d6
[00011012] 4846                      swap      d6
[00011014] 3c10                      move.w    (a0),d6
[00011016] 3e06                      move.w    d6,d7
[00011018] e0be                      ror.l     d0,d6
[0001101a] 4646                      not.w     d6
[0001101c] 8d51                      or.w      d6,(a1)
[0001101e] d0ca                      adda.w    a2,a0
[00011020] d2cb                      adda.w    a3,a1
[00011022] 51cc ffec                 dbf       d4,$00011010
[00011026] 4847                      swap      d7
[00011028] 4ed5                      jmp       (a5)
[0001102a] 3e10                      move.w    (a0),d7
[0001102c] e0bf                      ror.l     d0,d7
[0001102e] 4647                      not.w     d7
[00011030] ce43                      and.w     d3,d7
[00011032] 8f51                      or.w      d7,(a1)
[00011034] d0ee 01c6                 adda.w    454(a6),a0
[00011038] d2ee 01da                 adda.w    474(a6),a1
[0001103c] 51cd ffb6                 dbf       d5,$00010FF4
[00011040] 4e75                      rts
[00011042] 3c10                      move.w    (a0),d6
[00011044] 4ed4                      jmp       (a4)
[00011046] 4846                      swap      d6
[00011048] d0ca                      adda.w    a2,a0
[0001104a] 3c10                      move.w    (a0),d6
[0001104c] 4846                      swap      d6
[0001104e] 2e06                      move.l    d6,d7
[00011050] e1be                      rol.l     d0,d6
[00011052] 4646                      not.w     d6
[00011054] cc42                      and.w     d2,d6
[00011056] 8d51                      or.w      d6,(a1)
[00011058] d0ca                      adda.w    a2,a0
[0001105a] d2cb                      adda.w    a3,a1
[0001105c] 3801                      move.w    d1,d4
[0001105e] 6b16                      bmi.s     $00011076
[00011060] 2c07                      move.l    d7,d6
[00011062] 3c10                      move.w    (a0),d6
[00011064] 4846                      swap      d6
[00011066] 2e06                      move.l    d6,d7
[00011068] e1be                      rol.l     d0,d6
[0001106a] 4646                      not.w     d6
[0001106c] 8d51                      or.w      d6,(a1)
[0001106e] d0ca                      adda.w    a2,a0
[00011070] d2cb                      adda.w    a3,a1
[00011072] 51cc ffec                 dbf       d4,$00011060
[00011076] 4ed5                      jmp       (a5)
[00011078] 3e10                      move.w    (a0),d7
[0001107a] 4847                      swap      d7
[0001107c] e1bf                      rol.l     d0,d7
[0001107e] 4647                      not.w     d7
[00011080] ce43                      and.w     d3,d7
[00011082] 8f51                      or.w      d7,(a1)
[00011084] d0ee 01c6                 adda.w    454(a6),a0
[00011088] d2ee 01da                 adda.w    474(a6),a1
[0001108c] 51cd ffb4                 dbf       d5,$00011042
[00011090] 4e75                      rts
[00011092] 3c10                      move.w    (a0),d6
[00011094] 8c42                      or.w      d2,d6
[00011096] cd51                      and.w     d6,(a1)
[00011098] 8551                      or.w      d2,(a1)
[0001109a] d0ca                      adda.w    a2,a0
[0001109c] d2cb                      adda.w    a3,a1
[0001109e] 3801                      move.w    d1,d4
[000110a0] 6b0e                      bmi.s     $000110B0
[000110a2] 3c10                      move.w    (a0),d6
[000110a4] cd51                      and.w     d6,(a1)
[000110a6] 4651                      not.w     (a1)
[000110a8] d0ca                      adda.w    a2,a0
[000110aa] d2cb                      adda.w    a3,a1
[000110ac] 51cc fff4                 dbf       d4,$000110A2
[000110b0] 4ed5                      jmp       (a5)
[000110b2] 3c10                      move.w    (a0),d6
[000110b4] 8c43                      or.w      d3,d6
[000110b6] cd51                      and.w     d6,(a1)
[000110b8] b751                      eor.w     d3,(a1)
[000110ba] d0ee 01c6                 adda.w    454(a6),a0
[000110be] d2ee 01da                 adda.w    474(a6),a1
[000110c2] 51cd ffce                 dbf       d5,$00011092
[000110c6] 4e75                      rts
[000110c8] 3c10                      move.w    (a0),d6
[000110ca] 4ed4                      jmp       (a4)
[000110cc] 4846                      swap      d6
[000110ce] d0ca                      adda.w    a2,a0
[000110d0] 3c10                      move.w    (a0),d6
[000110d2] 3e06                      move.w    d6,d7
[000110d4] e0be                      ror.l     d0,d6
[000110d6] 8c42                      or.w      d2,d6
[000110d8] cd51                      and.w     d6,(a1)
[000110da] 8551                      or.w      d2,(a1)
[000110dc] d0ca                      adda.w    a2,a0
[000110de] d2cb                      adda.w    a3,a1
[000110e0] 3801                      move.w    d1,d4
[000110e2] 6b16                      bmi.s     $000110FA
[000110e4] 3c07                      move.w    d7,d6
[000110e6] 4846                      swap      d6
[000110e8] 3c10                      move.w    (a0),d6
[000110ea] 3e06                      move.w    d6,d7
[000110ec] e0be                      ror.l     d0,d6
[000110ee] cd51                      and.w     d6,(a1)
[000110f0] 4651                      not.w     (a1)
[000110f2] d0ca                      adda.w    a2,a0
[000110f4] d2cb                      adda.w    a3,a1
[000110f6] 51cc ffec                 dbf       d4,$000110E4
[000110fa] 4847                      swap      d7
[000110fc] 4ed5                      jmp       (a5)
[000110fe] 3e10                      move.w    (a0),d7
[00011100] e0bf                      ror.l     d0,d7
[00011102] 8e43                      or.w      d3,d7
[00011104] cf51                      and.w     d7,(a1)
[00011106] b751                      eor.w     d3,(a1)
[00011108] d0ee 01c6                 adda.w    454(a6),a0
[0001110c] d2ee 01da                 adda.w    474(a6),a1
[00011110] 51cd ffb6                 dbf       d5,$000110C8
[00011114] 4e75                      rts
[00011116] 3c10                      move.w    (a0),d6
[00011118] 4ed4                      jmp       (a4)
[0001111a] 4846                      swap      d6
[0001111c] d0ca                      adda.w    a2,a0
[0001111e] 3c10                      move.w    (a0),d6
[00011120] 4846                      swap      d6
[00011122] 2e06                      move.l    d6,d7
[00011124] e1be                      rol.l     d0,d6
[00011126] 8c42                      or.w      d2,d6
[00011128] cd51                      and.w     d6,(a1)
[0001112a] 8551                      or.w      d2,(a1)
[0001112c] d0ca                      adda.w    a2,a0
[0001112e] d2cb                      adda.w    a3,a1
[00011130] 3801                      move.w    d1,d4
[00011132] 6b16                      bmi.s     $0001114A
[00011134] 2c07                      move.l    d7,d6
[00011136] 3c10                      move.w    (a0),d6
[00011138] 4846                      swap      d6
[0001113a] 2e06                      move.l    d6,d7
[0001113c] e1be                      rol.l     d0,d6
[0001113e] cd51                      and.w     d6,(a1)
[00011140] 4651                      not.w     (a1)
[00011142] d0ca                      adda.w    a2,a0
[00011144] d2cb                      adda.w    a3,a1
[00011146] 51cc ffec                 dbf       d4,$00011134
[0001114a] 4ed5                      jmp       (a5)
[0001114c] 3e10                      move.w    (a0),d7
[0001114e] 4847                      swap      d7
[00011150] e1bf                      rol.l     d0,d7
[00011152] 8e43                      or.w      d3,d7
[00011154] cf51                      and.w     d7,(a1)
[00011156] b751                      eor.w     d3,(a1)
[00011158] d0ee 01c6                 adda.w    454(a6),a0
[0001115c] d2ee 01da                 adda.w    474(a6),a1
[00011160] 51cd ffb4                 dbf       d5,$00011116
[00011164] 4e75                      rts
[00011166] 7cff                      moveq.l   #-1,d6
[00011168] 3e2e 01da                 move.w    474(a6),d7
[0001116c] 4a43                      tst.w     d3
[0001116e] 660c                      bne.s     $0001117C
[00011170] de4b                      add.w     a3,d7
[00011172] 8551                      or.w      d2,(a1)
[00011174] d2c7                      adda.w    d7,a1
[00011176] 51cd fffa                 dbf       d5,$00011172
[0001117a] 4e75                      rts
[0001117c] 8551                      or.w      d2,(a1)
[0001117e] d2cb                      adda.w    a3,a1
[00011180] 3801                      move.w    d1,d4
[00011182] 6b08                      bmi.s     $0001118C
[00011184] 3286                      move.w    d6,(a1)
[00011186] d2cb                      adda.w    a3,a1
[00011188] 51cc fffa                 dbf       d4,$00011184
[0001118c] 8751                      or.w      d3,(a1)
[0001118e] d2c7                      adda.w    d7,a1
[00011190] 51cd ffea                 dbf       d5,$0001117C
[00011194] 4e75                      rts
[00011196] 5541                      subq.w    #2,d1
[00011198] 514b                      subq.w    #8,a3
[0001119a] 4a40                      tst.w     d0
[0001119c] 6670                      bne.s     $0001120E
[0001119e] 3c02                      move.w    d2,d6
[000111a0] 4842                      swap      d2
[000111a2] 3406                      move.w    d6,d2
[000111a4] 3c03                      move.w    d3,d6
[000111a6] 4843                      swap      d3
[000111a8] 3606                      move.w    d6,d3
[000111aa] 2c02                      move.l    d2,d6
[000111ac] 2e03                      move.l    d3,d7
[000111ae] 4686                      not.l     d6
[000111b0] 4687                      not.l     d7
[000111b2] 514a                      subq.w    #8,a2
[000111b4] b27c fffe                 cmp.w     #$FFFE,d1
[000111b8] 6736                      beq.s     $000111F0
[000111ba] 2018                      move.l    (a0)+,d0
[000111bc] c082                      and.l     d2,d0
[000111be] cd91                      and.l     d6,(a1)
[000111c0] 8199                      or.l      d0,(a1)+
[000111c2] 2018                      move.l    (a0)+,d0
[000111c4] c082                      and.l     d2,d0
[000111c6] cd91                      and.l     d6,(a1)
[000111c8] 8199                      or.l      d0,(a1)+
[000111ca] 3801                      move.w    d1,d4
[000111cc] 6b08                      bmi.s     $000111D6
[000111ce] 22d8                      move.l    (a0)+,(a1)+
[000111d0] 22d8                      move.l    (a0)+,(a1)+
[000111d2] 51cc fffa                 dbf       d4,$000111CE
[000111d6] 2018                      move.l    (a0)+,d0
[000111d8] c083                      and.l     d3,d0
[000111da] cf91                      and.l     d7,(a1)
[000111dc] 8199                      or.l      d0,(a1)+
[000111de] 2018                      move.l    (a0)+,d0
[000111e0] c083                      and.l     d3,d0
[000111e2] cf91                      and.l     d7,(a1)
[000111e4] 8199                      or.l      d0,(a1)+
[000111e6] d0ca                      adda.w    a2,a0
[000111e8] d2cb                      adda.w    a3,a1
[000111ea] 51cd ffce                 dbf       d5,$000111BA
[000111ee] 4e75                      rts
[000111f0] c483                      and.l     d3,d2
[000111f2] 8c87                      or.l      d7,d6
[000111f4] 2018                      move.l    (a0)+,d0
[000111f6] c082                      and.l     d2,d0
[000111f8] cd91                      and.l     d6,(a1)
[000111fa] 8199                      or.l      d0,(a1)+
[000111fc] 2018                      move.l    (a0)+,d0
[000111fe] c082                      and.l     d2,d0
[00011200] cd91                      and.l     d6,(a1)
[00011202] 8199                      or.l      d0,(a1)+
[00011204] d0ca                      adda.w    a2,a0
[00011206] d2cb                      adda.w    a3,a1
[00011208] 51cd ffea                 dbf       d5,$000111F4
[0001120c] 4e75                      rts
[0001120e] b9fc 0001 066c            cmpa.l    #$0001066C,a4
[00011214] 6600 03ac                 bne       $000115C2
[00011218] bc7c 0004                 cmp.w     #$0004,d6
[0001121c] 6600 01f4                 bne       $00011412
[00011220] b27c fffe                 cmp.w     #$FFFE,d1
[00011224] 6700 019c                 beq       $000113C2
[00011228] 4a47                      tst.w     d7
[0001122a] 6600 00d4                 bne       $00011300
[0001122e] 3c18                      move.w    (a0)+,d6
[00011230] 4846                      swap      d6
[00011232] 3c28 0006                 move.w    6(a0),d6
[00011236] e0be                      ror.l     d0,d6
[00011238] 4646                      not.w     d6
[0001123a] cc42                      and.w     d2,d6
[0001123c] 8551                      or.w      d2,(a1)
[0001123e] bd59                      eor.w     d6,(a1)+
[00011240] 3c18                      move.w    (a0)+,d6
[00011242] 4846                      swap      d6
[00011244] 3c28 0006                 move.w    6(a0),d6
[00011248] e0be                      ror.l     d0,d6
[0001124a] 4646                      not.w     d6
[0001124c] cc42                      and.w     d2,d6
[0001124e] 8551                      or.w      d2,(a1)
[00011250] bd59                      eor.w     d6,(a1)+
[00011252] 3c18                      move.w    (a0)+,d6
[00011254] 4846                      swap      d6
[00011256] 3c28 0006                 move.w    6(a0),d6
[0001125a] e0be                      ror.l     d0,d6
[0001125c] 4646                      not.w     d6
[0001125e] cc42                      and.w     d2,d6
[00011260] 8551                      or.w      d2,(a1)
[00011262] bd59                      eor.w     d6,(a1)+
[00011264] 3c18                      move.w    (a0)+,d6
[00011266] 4846                      swap      d6
[00011268] 3c28 0006                 move.w    6(a0),d6
[0001126c] e0be                      ror.l     d0,d6
[0001126e] 4646                      not.w     d6
[00011270] cc42                      and.w     d2,d6
[00011272] 8551                      or.w      d2,(a1)
[00011274] bd59                      eor.w     d6,(a1)+
[00011276] 4845                      swap      d5
[00011278] 3a01                      move.w    d1,d5
[0001127a] 6b30                      bmi.s     $000112AC
[0001127c] 2c18                      move.l    (a0)+,d6
[0001127e] 4846                      swap      d6
[00011280] 3806                      move.w    d6,d4
[00011282] 2e28 0004                 move.l    4(a0),d7
[00011286] 3c07                      move.w    d7,d6
[00011288] 3e04                      move.w    d4,d7
[0001128a] e0be                      ror.l     d0,d6
[0001128c] e0bf                      ror.l     d0,d7
[0001128e] 3e06                      move.w    d6,d7
[00011290] 22c7                      move.l    d7,(a1)+
[00011292] 2c18                      move.l    (a0)+,d6
[00011294] 4846                      swap      d6
[00011296] 3806                      move.w    d6,d4
[00011298] 2e28 0004                 move.l    4(a0),d7
[0001129c] 3c07                      move.w    d7,d6
[0001129e] 3e04                      move.w    d4,d7
[000112a0] e0be                      ror.l     d0,d6
[000112a2] e0bf                      ror.l     d0,d7
[000112a4] 3e06                      move.w    d6,d7
[000112a6] 22c7                      move.l    d7,(a1)+
[000112a8] 51cd ffd2                 dbf       d5,$0001127C
[000112ac] 4845                      swap      d5
[000112ae] 3c18                      move.w    (a0)+,d6
[000112b0] 4846                      swap      d6
[000112b2] 3c28 0006                 move.w    6(a0),d6
[000112b6] e0be                      ror.l     d0,d6
[000112b8] 4646                      not.w     d6
[000112ba] cc43                      and.w     d3,d6
[000112bc] 8751                      or.w      d3,(a1)
[000112be] bd59                      eor.w     d6,(a1)+
[000112c0] 3c18                      move.w    (a0)+,d6
[000112c2] 4846                      swap      d6
[000112c4] 3c28 0006                 move.w    6(a0),d6
[000112c8] e0be                      ror.l     d0,d6
[000112ca] 4646                      not.w     d6
[000112cc] cc43                      and.w     d3,d6
[000112ce] 8751                      or.w      d3,(a1)
[000112d0] bd59                      eor.w     d6,(a1)+
[000112d2] 3c18                      move.w    (a0)+,d6
[000112d4] 4846                      swap      d6
[000112d6] 3c28 0006                 move.w    6(a0),d6
[000112da] e0be                      ror.l     d0,d6
[000112dc] 4646                      not.w     d6
[000112de] cc43                      and.w     d3,d6
[000112e0] 8751                      or.w      d3,(a1)
[000112e2] bd59                      eor.w     d6,(a1)+
[000112e4] 3c18                      move.w    (a0)+,d6
[000112e6] 4846                      swap      d6
[000112e8] 3c28 0006                 move.w    6(a0),d6
[000112ec] e0be                      ror.l     d0,d6
[000112ee] 4646                      not.w     d6
[000112f0] cc43                      and.w     d3,d6
[000112f2] 8751                      or.w      d3,(a1)
[000112f4] bd59                      eor.w     d6,(a1)+
[000112f6] d0ca                      adda.w    a2,a0
[000112f8] d2cb                      adda.w    a3,a1
[000112fa] 51cd ff32                 dbf       d5,$0001122E
[000112fe] 4e75                      rts
[00011300] 3c18                      move.w    (a0)+,d6
[00011302] 4846                      swap      d6
[00011304] 3c28 0006                 move.w    6(a0),d6
[00011308] e0be                      ror.l     d0,d6
[0001130a] 4646                      not.w     d6
[0001130c] cc42                      and.w     d2,d6
[0001130e] 8551                      or.w      d2,(a1)
[00011310] bd59                      eor.w     d6,(a1)+
[00011312] 3c18                      move.w    (a0)+,d6
[00011314] 4846                      swap      d6
[00011316] 3c28 0006                 move.w    6(a0),d6
[0001131a] e0be                      ror.l     d0,d6
[0001131c] 4646                      not.w     d6
[0001131e] cc42                      and.w     d2,d6
[00011320] 8551                      or.w      d2,(a1)
[00011322] bd59                      eor.w     d6,(a1)+
[00011324] 3c18                      move.w    (a0)+,d6
[00011326] 4846                      swap      d6
[00011328] 3c28 0006                 move.w    6(a0),d6
[0001132c] e0be                      ror.l     d0,d6
[0001132e] 4646                      not.w     d6
[00011330] cc42                      and.w     d2,d6
[00011332] 8551                      or.w      d2,(a1)
[00011334] bd59                      eor.w     d6,(a1)+
[00011336] 3c18                      move.w    (a0)+,d6
[00011338] 4846                      swap      d6
[0001133a] 3c28 0006                 move.w    6(a0),d6
[0001133e] e0be                      ror.l     d0,d6
[00011340] 4646                      not.w     d6
[00011342] cc42                      and.w     d2,d6
[00011344] 8551                      or.w      d2,(a1)
[00011346] bd59                      eor.w     d6,(a1)+
[00011348] 4845                      swap      d5
[0001134a] 3a01                      move.w    d1,d5
[0001134c] 6b30                      bmi.s     $0001137E
[0001134e] 2c18                      move.l    (a0)+,d6
[00011350] 4846                      swap      d6
[00011352] 3806                      move.w    d6,d4
[00011354] 2e28 0004                 move.l    4(a0),d7
[00011358] 3c07                      move.w    d7,d6
[0001135a] 3e04                      move.w    d4,d7
[0001135c] e0be                      ror.l     d0,d6
[0001135e] e0bf                      ror.l     d0,d7
[00011360] 3e06                      move.w    d6,d7
[00011362] 22c7                      move.l    d7,(a1)+
[00011364] 2c18                      move.l    (a0)+,d6
[00011366] 4846                      swap      d6
[00011368] 3806                      move.w    d6,d4
[0001136a] 2e28 0004                 move.l    4(a0),d7
[0001136e] 3c07                      move.w    d7,d6
[00011370] 3e04                      move.w    d4,d7
[00011372] e0be                      ror.l     d0,d6
[00011374] e0bf                      ror.l     d0,d7
[00011376] 3e06                      move.w    d6,d7
[00011378] 22c7                      move.l    d7,(a1)+
[0001137a] 51cd ffd2                 dbf       d5,$0001134E
[0001137e] 4845                      swap      d5
[00011380] 3c18                      move.w    (a0)+,d6
[00011382] 4846                      swap      d6
[00011384] e0be                      ror.l     d0,d6
[00011386] 4646                      not.w     d6
[00011388] cc43                      and.w     d3,d6
[0001138a] 8751                      or.w      d3,(a1)
[0001138c] bd59                      eor.w     d6,(a1)+
[0001138e] 3c18                      move.w    (a0)+,d6
[00011390] 4846                      swap      d6
[00011392] e0be                      ror.l     d0,d6
[00011394] 4646                      not.w     d6
[00011396] cc43                      and.w     d3,d6
[00011398] 8751                      or.w      d3,(a1)
[0001139a] bd59                      eor.w     d6,(a1)+
[0001139c] 3c18                      move.w    (a0)+,d6
[0001139e] 4846                      swap      d6
[000113a0] e0be                      ror.l     d0,d6
[000113a2] 4646                      not.w     d6
[000113a4] cc43                      and.w     d3,d6
[000113a6] 8751                      or.w      d3,(a1)
[000113a8] bd59                      eor.w     d6,(a1)+
[000113aa] 3c18                      move.w    (a0)+,d6
[000113ac] 4846                      swap      d6
[000113ae] e0be                      ror.l     d0,d6
[000113b0] 4646                      not.w     d6
[000113b2] cc43                      and.w     d3,d6
[000113b4] 8751                      or.w      d3,(a1)
[000113b6] bd59                      eor.w     d6,(a1)+
[000113b8] d0ca                      adda.w    a2,a0
[000113ba] d2cb                      adda.w    a3,a1
[000113bc] 51cd ff42                 dbf       d5,$00011300
[000113c0] 4e75                      rts
[000113c2] c443                      and.w     d3,d2
[000113c4] 3602                      move.w    d2,d3
[000113c6] 4643                      not.w     d3
[000113c8] 3c18                      move.w    (a0)+,d6
[000113ca] 4846                      swap      d6
[000113cc] 3c28 0006                 move.w    6(a0),d6
[000113d0] e0be                      ror.l     d0,d6
[000113d2] cc42                      and.w     d2,d6
[000113d4] c751                      and.w     d3,(a1)
[000113d6] 8d59                      or.w      d6,(a1)+
[000113d8] 3c18                      move.w    (a0)+,d6
[000113da] 4846                      swap      d6
[000113dc] 3c28 0006                 move.w    6(a0),d6
[000113e0] e0be                      ror.l     d0,d6
[000113e2] cc42                      and.w     d2,d6
[000113e4] c751                      and.w     d3,(a1)
[000113e6] 8d59                      or.w      d6,(a1)+
[000113e8] 3c18                      move.w    (a0)+,d6
[000113ea] 4846                      swap      d6
[000113ec] 3c28 0006                 move.w    6(a0),d6
[000113f0] e0be                      ror.l     d0,d6
[000113f2] cc42                      and.w     d2,d6
[000113f4] c751                      and.w     d3,(a1)
[000113f6] 8d59                      or.w      d6,(a1)+
[000113f8] 3c18                      move.w    (a0)+,d6
[000113fa] 4846                      swap      d6
[000113fc] 3c28 0006                 move.w    6(a0),d6
[00011400] e0be                      ror.l     d0,d6
[00011402] cc42                      and.w     d2,d6
[00011404] c751                      and.w     d3,(a1)
[00011406] 8d59                      or.w      d6,(a1)+
[00011408] d0ca                      adda.w    a2,a0
[0001140a] d2cb                      adda.w    a3,a1
[0001140c] 51cd ffba                 dbf       d5,$000113C8
[00011410] 4e75                      rts
[00011412] b27c fffe                 cmp.w     #$FFFE,d1
[00011416] 6700 0170                 beq       $00011588
[0001141a] 4a47                      tst.w     d7
[0001141c] 6600 00be                 bne       $000114DC
[00011420] 3c18                      move.w    (a0)+,d6
[00011422] e0be                      ror.l     d0,d6
[00011424] 4646                      not.w     d6
[00011426] cc42                      and.w     d2,d6
[00011428] 8551                      or.w      d2,(a1)
[0001142a] bd59                      eor.w     d6,(a1)+
[0001142c] 3c18                      move.w    (a0)+,d6
[0001142e] e0be                      ror.l     d0,d6
[00011430] 4646                      not.w     d6
[00011432] cc42                      and.w     d2,d6
[00011434] 8551                      or.w      d2,(a1)
[00011436] bd59                      eor.w     d6,(a1)+
[00011438] 3c18                      move.w    (a0)+,d6
[0001143a] e0be                      ror.l     d0,d6
[0001143c] 4646                      not.w     d6
[0001143e] cc42                      and.w     d2,d6
[00011440] 8551                      or.w      d2,(a1)
[00011442] bd59                      eor.w     d6,(a1)+
[00011444] 3c18                      move.w    (a0)+,d6
[00011446] e0be                      ror.l     d0,d6
[00011448] 4646                      not.w     d6
[0001144a] cc42                      and.w     d2,d6
[0001144c] 8551                      or.w      d2,(a1)
[0001144e] bd59                      eor.w     d6,(a1)+
[00011450] 5188                      subq.l    #8,a0
[00011452] 4845                      swap      d5
[00011454] 3a01                      move.w    d1,d5
[00011456] 6b30                      bmi.s     $00011488
[00011458] 2c18                      move.l    (a0)+,d6
[0001145a] 4846                      swap      d6
[0001145c] 3806                      move.w    d6,d4
[0001145e] 2e28 0004                 move.l    4(a0),d7
[00011462] 3c07                      move.w    d7,d6
[00011464] 3e04                      move.w    d4,d7
[00011466] e0be                      ror.l     d0,d6
[00011468] e0bf                      ror.l     d0,d7
[0001146a] 3e06                      move.w    d6,d7
[0001146c] 22c7                      move.l    d7,(a1)+
[0001146e] 2c18                      move.l    (a0)+,d6
[00011470] 4846                      swap      d6
[00011472] 3806                      move.w    d6,d4
[00011474] 2e28 0004                 move.l    4(a0),d7
[00011478] 3c07                      move.w    d7,d6
[0001147a] 3e04                      move.w    d4,d7
[0001147c] e0be                      ror.l     d0,d6
[0001147e] e0bf                      ror.l     d0,d7
[00011480] 3e06                      move.w    d6,d7
[00011482] 22c7                      move.l    d7,(a1)+
[00011484] 51cd ffd2                 dbf       d5,$00011458
[00011488] 4845                      swap      d5
[0001148a] 3c18                      move.w    (a0)+,d6
[0001148c] 4846                      swap      d6
[0001148e] 3c28 0006                 move.w    6(a0),d6
[00011492] e0be                      ror.l     d0,d6
[00011494] 4646                      not.w     d6
[00011496] cc43                      and.w     d3,d6
[00011498] 8751                      or.w      d3,(a1)
[0001149a] bd59                      eor.w     d6,(a1)+
[0001149c] 3c18                      move.w    (a0)+,d6
[0001149e] 4846                      swap      d6
[000114a0] 3c28 0006                 move.w    6(a0),d6
[000114a4] e0be                      ror.l     d0,d6
[000114a6] 4646                      not.w     d6
[000114a8] cc43                      and.w     d3,d6
[000114aa] 8751                      or.w      d3,(a1)
[000114ac] bd59                      eor.w     d6,(a1)+
[000114ae] 3c18                      move.w    (a0)+,d6
[000114b0] 4846                      swap      d6
[000114b2] 3c28 0006                 move.w    6(a0),d6
[000114b6] e0be                      ror.l     d0,d6
[000114b8] 4646                      not.w     d6
[000114ba] cc43                      and.w     d3,d6
[000114bc] 8751                      or.w      d3,(a1)
[000114be] bd59                      eor.w     d6,(a1)+
[000114c0] 3c18                      move.w    (a0)+,d6
[000114c2] 4846                      swap      d6
[000114c4] 3c28 0006                 move.w    6(a0),d6
[000114c8] e0be                      ror.l     d0,d6
[000114ca] 4646                      not.w     d6
[000114cc] cc43                      and.w     d3,d6
[000114ce] 8751                      or.w      d3,(a1)
[000114d0] bd59                      eor.w     d6,(a1)+
[000114d2] d0ca                      adda.w    a2,a0
[000114d4] d2cb                      adda.w    a3,a1
[000114d6] 51cd ff48                 dbf       d5,$00011420
[000114da] 4e75                      rts
[000114dc] 3c18                      move.w    (a0)+,d6
[000114de] e0be                      ror.l     d0,d6
[000114e0] 4646                      not.w     d6
[000114e2] cc42                      and.w     d2,d6
[000114e4] 8551                      or.w      d2,(a1)
[000114e6] bd59                      eor.w     d6,(a1)+
[000114e8] 3c18                      move.w    (a0)+,d6
[000114ea] e0be                      ror.l     d0,d6
[000114ec] 4646                      not.w     d6
[000114ee] cc42                      and.w     d2,d6
[000114f0] 8551                      or.w      d2,(a1)
[000114f2] bd59                      eor.w     d6,(a1)+
[000114f4] 3c18                      move.w    (a0)+,d6
[000114f6] e0be                      ror.l     d0,d6
[000114f8] 4646                      not.w     d6
[000114fa] cc42                      and.w     d2,d6
[000114fc] 8551                      or.w      d2,(a1)
[000114fe] bd59                      eor.w     d6,(a1)+
[00011500] 3c18                      move.w    (a0)+,d6
[00011502] e0be                      ror.l     d0,d6
[00011504] 4646                      not.w     d6
[00011506] cc42                      and.w     d2,d6
[00011508] 8551                      or.w      d2,(a1)
[0001150a] bd59                      eor.w     d6,(a1)+
[0001150c] 5188                      subq.l    #8,a0
[0001150e] 4845                      swap      d5
[00011510] 3a01                      move.w    d1,d5
[00011512] 6b30                      bmi.s     $00011544
[00011514] 2c18                      move.l    (a0)+,d6
[00011516] 4846                      swap      d6
[00011518] 3806                      move.w    d6,d4
[0001151a] 2e28 0004                 move.l    4(a0),d7
[0001151e] 3c07                      move.w    d7,d6
[00011520] 3e04                      move.w    d4,d7
[00011522] e0be                      ror.l     d0,d6
[00011524] e0bf                      ror.l     d0,d7
[00011526] 3e06                      move.w    d6,d7
[00011528] 22c7                      move.l    d7,(a1)+
[0001152a] 2c18                      move.l    (a0)+,d6
[0001152c] 4846                      swap      d6
[0001152e] 3806                      move.w    d6,d4
[00011530] 2e28 0004                 move.l    4(a0),d7
[00011534] 3c07                      move.w    d7,d6
[00011536] 3e04                      move.w    d4,d7
[00011538] e0be                      ror.l     d0,d6
[0001153a] e0bf                      ror.l     d0,d7
[0001153c] 3e06                      move.w    d6,d7
[0001153e] 22c7                      move.l    d7,(a1)+
[00011540] 51cd ffd2                 dbf       d5,$00011514
[00011544] 4845                      swap      d5
[00011546] 3c18                      move.w    (a0)+,d6
[00011548] 4846                      swap      d6
[0001154a] e0be                      ror.l     d0,d6
[0001154c] 4646                      not.w     d6
[0001154e] cc43                      and.w     d3,d6
[00011550] 8751                      or.w      d3,(a1)
[00011552] bd59                      eor.w     d6,(a1)+
[00011554] 3c18                      move.w    (a0)+,d6
[00011556] 4846                      swap      d6
[00011558] e0be                      ror.l     d0,d6
[0001155a] 4646                      not.w     d6
[0001155c] cc43                      and.w     d3,d6
[0001155e] 8751                      or.w      d3,(a1)
[00011560] bd59                      eor.w     d6,(a1)+
[00011562] 3c18                      move.w    (a0)+,d6
[00011564] 4846                      swap      d6
[00011566] e0be                      ror.l     d0,d6
[00011568] 4646                      not.w     d6
[0001156a] cc43                      and.w     d3,d6
[0001156c] 8751                      or.w      d3,(a1)
[0001156e] bd59                      eor.w     d6,(a1)+
[00011570] 3c18                      move.w    (a0)+,d6
[00011572] 4846                      swap      d6
[00011574] e0be                      ror.l     d0,d6
[00011576] 4646                      not.w     d6
[00011578] cc43                      and.w     d3,d6
[0001157a] 8751                      or.w      d3,(a1)
[0001157c] bd59                      eor.w     d6,(a1)+
[0001157e] d0ca                      adda.w    a2,a0
[00011580] d2cb                      adda.w    a3,a1
[00011582] 51cd ff58                 dbf       d5,$000114DC
[00011586] 4e75                      rts
[00011588] c443                      and.w     d3,d2
[0001158a] 3602                      move.w    d2,d3
[0001158c] 4643                      not.w     d3
[0001158e] 514a                      subq.w    #8,a2
[00011590] 3c18                      move.w    (a0)+,d6
[00011592] e0be                      ror.l     d0,d6
[00011594] cc42                      and.w     d2,d6
[00011596] c751                      and.w     d3,(a1)
[00011598] 8d59                      or.w      d6,(a1)+
[0001159a] 3c18                      move.w    (a0)+,d6
[0001159c] e0be                      ror.l     d0,d6
[0001159e] cc42                      and.w     d2,d6
[000115a0] c751                      and.w     d3,(a1)
[000115a2] 8d59                      or.w      d6,(a1)+
[000115a4] 3c18                      move.w    (a0)+,d6
[000115a6] e0be                      ror.l     d0,d6
[000115a8] cc42                      and.w     d2,d6
[000115aa] c751                      and.w     d3,(a1)
[000115ac] 8d59                      or.w      d6,(a1)+
[000115ae] 3c18                      move.w    (a0)+,d6
[000115b0] e0be                      ror.l     d0,d6
[000115b2] cc42                      and.w     d2,d6
[000115b4] c751                      and.w     d3,(a1)
[000115b6] 8d59                      or.w      d6,(a1)+
[000115b8] d0ca                      adda.w    a2,a0
[000115ba] d2cb                      adda.w    a3,a1
[000115bc] 51cd ffd2                 dbf       d5,$00011590
[000115c0] 4e75                      rts
[000115c2] bc7c 0004                 cmp.w     #$0004,d6
[000115c6] 6600 01ec                 bne       $000117B4
[000115ca] b27c fffe                 cmp.w     #$FFFE,d1
[000115ce] 6700 0194                 beq       $00011764
[000115d2] 4a47                      tst.w     d7
[000115d4] 6600 00d4                 bne       $000116AA
[000115d8] 3c28 0008                 move.w    8(a0),d6
[000115dc] 4846                      swap      d6
[000115de] 3c18                      move.w    (a0)+,d6
[000115e0] e1be                      rol.l     d0,d6
[000115e2] 4646                      not.w     d6
[000115e4] cc42                      and.w     d2,d6
[000115e6] 8551                      or.w      d2,(a1)
[000115e8] bd59                      eor.w     d6,(a1)+
[000115ea] 3c28 0008                 move.w    8(a0),d6
[000115ee] 4846                      swap      d6
[000115f0] 3c18                      move.w    (a0)+,d6
[000115f2] e1be                      rol.l     d0,d6
[000115f4] 4646                      not.w     d6
[000115f6] cc42                      and.w     d2,d6
[000115f8] 8551                      or.w      d2,(a1)
[000115fa] bd59                      eor.w     d6,(a1)+
[000115fc] 3c28 0008                 move.w    8(a0),d6
[00011600] 4846                      swap      d6
[00011602] 3c18                      move.w    (a0)+,d6
[00011604] e1be                      rol.l     d0,d6
[00011606] 4646                      not.w     d6
[00011608] cc42                      and.w     d2,d6
[0001160a] 8551                      or.w      d2,(a1)
[0001160c] bd59                      eor.w     d6,(a1)+
[0001160e] 3c28 0008                 move.w    8(a0),d6
[00011612] 4846                      swap      d6
[00011614] 3c18                      move.w    (a0)+,d6
[00011616] e1be                      rol.l     d0,d6
[00011618] 4646                      not.w     d6
[0001161a] cc42                      and.w     d2,d6
[0001161c] 8551                      or.w      d2,(a1)
[0001161e] bd59                      eor.w     d6,(a1)+
[00011620] 4845                      swap      d5
[00011622] 3a01                      move.w    d1,d5
[00011624] 6b30                      bmi.s     $00011656
[00011626] 2c18                      move.l    (a0)+,d6
[00011628] 2e28 0004                 move.l    4(a0),d7
[0001162c] 4847                      swap      d7
[0001162e] 2806                      move.l    d6,d4
[00011630] 3807                      move.w    d7,d4
[00011632] 3e06                      move.w    d6,d7
[00011634] e1bc                      rol.l     d0,d4
[00011636] e1bf                      rol.l     d0,d7
[00011638] 3807                      move.w    d7,d4
[0001163a] 22c4                      move.l    d4,(a1)+
[0001163c] 2c18                      move.l    (a0)+,d6
[0001163e] 2e28 0004                 move.l    4(a0),d7
[00011642] 4847                      swap      d7
[00011644] 2806                      move.l    d6,d4
[00011646] 3807                      move.w    d7,d4
[00011648] 3e06                      move.w    d6,d7
[0001164a] e1bc                      rol.l     d0,d4
[0001164c] e1bf                      rol.l     d0,d7
[0001164e] 3807                      move.w    d7,d4
[00011650] 22c4                      move.l    d4,(a1)+
[00011652] 51cd ffd2                 dbf       d5,$00011626
[00011656] 4845                      swap      d5
[00011658] 3c28 0008                 move.w    8(a0),d6
[0001165c] 4846                      swap      d6
[0001165e] 3c18                      move.w    (a0)+,d6
[00011660] e1be                      rol.l     d0,d6
[00011662] 4646                      not.w     d6
[00011664] cc43                      and.w     d3,d6
[00011666] 8751                      or.w      d3,(a1)
[00011668] bd59                      eor.w     d6,(a1)+
[0001166a] 3c28 0008                 move.w    8(a0),d6
[0001166e] 4846                      swap      d6
[00011670] 3c18                      move.w    (a0)+,d6
[00011672] e1be                      rol.l     d0,d6
[00011674] 4646                      not.w     d6
[00011676] cc43                      and.w     d3,d6
[00011678] 8751                      or.w      d3,(a1)
[0001167a] bd59                      eor.w     d6,(a1)+
[0001167c] 3c28 0008                 move.w    8(a0),d6
[00011680] 4846                      swap      d6
[00011682] 3c18                      move.w    (a0)+,d6
[00011684] e1be                      rol.l     d0,d6
[00011686] 4646                      not.w     d6
[00011688] cc43                      and.w     d3,d6
[0001168a] 8751                      or.w      d3,(a1)
[0001168c] bd59                      eor.w     d6,(a1)+
[0001168e] 3c28 0008                 move.w    8(a0),d6
[00011692] 4846                      swap      d6
[00011694] 3c18                      move.w    (a0)+,d6
[00011696] e1be                      rol.l     d0,d6
[00011698] 4646                      not.w     d6
[0001169a] cc43                      and.w     d3,d6
[0001169c] 8751                      or.w      d3,(a1)
[0001169e] bd59                      eor.w     d6,(a1)+
[000116a0] d0ca                      adda.w    a2,a0
[000116a2] d2cb                      adda.w    a3,a1
[000116a4] 51cd ff32                 dbf       d5,$000115D8
[000116a8] 4e75                      rts
[000116aa] 3c28 0008                 move.w    8(a0),d6
[000116ae] 4846                      swap      d6
[000116b0] 3c18                      move.w    (a0)+,d6
[000116b2] e1be                      rol.l     d0,d6
[000116b4] 4646                      not.w     d6
[000116b6] cc42                      and.w     d2,d6
[000116b8] 8551                      or.w      d2,(a1)
[000116ba] bd59                      eor.w     d6,(a1)+
[000116bc] 3c28 0008                 move.w    8(a0),d6
[000116c0] 4846                      swap      d6
[000116c2] 3c18                      move.w    (a0)+,d6
[000116c4] e1be                      rol.l     d0,d6
[000116c6] 4646                      not.w     d6
[000116c8] cc42                      and.w     d2,d6
[000116ca] 8551                      or.w      d2,(a1)
[000116cc] bd59                      eor.w     d6,(a1)+
[000116ce] 3c28 0008                 move.w    8(a0),d6
[000116d2] 4846                      swap      d6
[000116d4] 3c18                      move.w    (a0)+,d6
[000116d6] e1be                      rol.l     d0,d6
[000116d8] 4646                      not.w     d6
[000116da] cc42                      and.w     d2,d6
[000116dc] 8551                      or.w      d2,(a1)
[000116de] bd59                      eor.w     d6,(a1)+
[000116e0] 3c28 0008                 move.w    8(a0),d6
[000116e4] 4846                      swap      d6
[000116e6] 3c18                      move.w    (a0)+,d6
[000116e8] e1be                      rol.l     d0,d6
[000116ea] 4646                      not.w     d6
[000116ec] cc42                      and.w     d2,d6
[000116ee] 8551                      or.w      d2,(a1)
[000116f0] bd59                      eor.w     d6,(a1)+
[000116f2] 4845                      swap      d5
[000116f4] 3a01                      move.w    d1,d5
[000116f6] 6b30                      bmi.s     $00011728
[000116f8] 2c18                      move.l    (a0)+,d6
[000116fa] 2e28 0004                 move.l    4(a0),d7
[000116fe] 4847                      swap      d7
[00011700] 2806                      move.l    d6,d4
[00011702] 3807                      move.w    d7,d4
[00011704] 3e06                      move.w    d6,d7
[00011706] e1bc                      rol.l     d0,d4
[00011708] e1bf                      rol.l     d0,d7
[0001170a] 3807                      move.w    d7,d4
[0001170c] 22c4                      move.l    d4,(a1)+
[0001170e] 2c18                      move.l    (a0)+,d6
[00011710] 2e28 0004                 move.l    4(a0),d7
[00011714] 4847                      swap      d7
[00011716] 2806                      move.l    d6,d4
[00011718] 3807                      move.w    d7,d4
[0001171a] 3e06                      move.w    d6,d7
[0001171c] e1bc                      rol.l     d0,d4
[0001171e] e1bf                      rol.l     d0,d7
[00011720] 3807                      move.w    d7,d4
[00011722] 22c4                      move.l    d4,(a1)+
[00011724] 51cd ffd2                 dbf       d5,$000116F8
[00011728] 4845                      swap      d5
[0001172a] 3c18                      move.w    (a0)+,d6
[0001172c] e1be                      rol.l     d0,d6
[0001172e] 4646                      not.w     d6
[00011730] cc43                      and.w     d3,d6
[00011732] 8751                      or.w      d3,(a1)
[00011734] bd59                      eor.w     d6,(a1)+
[00011736] 3c18                      move.w    (a0)+,d6
[00011738] e1be                      rol.l     d0,d6
[0001173a] 4646                      not.w     d6
[0001173c] cc43                      and.w     d3,d6
[0001173e] 8751                      or.w      d3,(a1)
[00011740] bd59                      eor.w     d6,(a1)+
[00011742] 3c18                      move.w    (a0)+,d6
[00011744] e1be                      rol.l     d0,d6
[00011746] 4646                      not.w     d6
[00011748] cc43                      and.w     d3,d6
[0001174a] 8751                      or.w      d3,(a1)
[0001174c] bd59                      eor.w     d6,(a1)+
[0001174e] 3c18                      move.w    (a0)+,d6
[00011750] e1be                      rol.l     d0,d6
[00011752] 4646                      not.w     d6
[00011754] cc43                      and.w     d3,d6
[00011756] 8751                      or.w      d3,(a1)
[00011758] bd59                      eor.w     d6,(a1)+
[0001175a] d0ca                      adda.w    a2,a0
[0001175c] d2cb                      adda.w    a3,a1
[0001175e] 51cd ff4a                 dbf       d5,$000116AA
[00011762] 4e75                      rts
[00011764] c443                      and.w     d3,d2
[00011766] 3602                      move.w    d2,d3
[00011768] 4643                      not.w     d3
[0001176a] 3c28 0008                 move.w    8(a0),d6
[0001176e] 4846                      swap      d6
[00011770] 3c18                      move.w    (a0)+,d6
[00011772] e1be                      rol.l     d0,d6
[00011774] cc42                      and.w     d2,d6
[00011776] c751                      and.w     d3,(a1)
[00011778] 8d59                      or.w      d6,(a1)+
[0001177a] 3c28 0008                 move.w    8(a0),d6
[0001177e] 4846                      swap      d6
[00011780] 3c18                      move.w    (a0)+,d6
[00011782] e1be                      rol.l     d0,d6
[00011784] cc42                      and.w     d2,d6
[00011786] c751                      and.w     d3,(a1)
[00011788] 8d59                      or.w      d6,(a1)+
[0001178a] 3c28 0008                 move.w    8(a0),d6
[0001178e] 4846                      swap      d6
[00011790] 3c18                      move.w    (a0)+,d6
[00011792] e1be                      rol.l     d0,d6
[00011794] cc42                      and.w     d2,d6
[00011796] c751                      and.w     d3,(a1)
[00011798] 8d59                      or.w      d6,(a1)+
[0001179a] 3c28 0008                 move.w    8(a0),d6
[0001179e] 4846                      swap      d6
[000117a0] 3c18                      move.w    (a0)+,d6
[000117a2] e1be                      rol.l     d0,d6
[000117a4] cc42                      and.w     d2,d6
[000117a6] c751                      and.w     d3,(a1)
[000117a8] 8d59                      or.w      d6,(a1)+
[000117aa] d0ca                      adda.w    a2,a0
[000117ac] d2cb                      adda.w    a3,a1
[000117ae] 51cd ffba                 dbf       d5,$0001176A
[000117b2] 4e75                      rts
[000117b4] b27c fffe                 cmp.w     #$FFFE,d1
[000117b8] 6700 0178                 beq       $00011932
[000117bc] 4a47                      tst.w     d7
[000117be] 6600 00c6                 bne       $00011886
[000117c2] 3c18                      move.w    (a0)+,d6
[000117c4] 4846                      swap      d6
[000117c6] e1be                      rol.l     d0,d6
[000117c8] 4646                      not.w     d6
[000117ca] cc42                      and.w     d2,d6
[000117cc] 8551                      or.w      d2,(a1)
[000117ce] bd59                      eor.w     d6,(a1)+
[000117d0] 3c18                      move.w    (a0)+,d6
[000117d2] 4846                      swap      d6
[000117d4] e1be                      rol.l     d0,d6
[000117d6] 4646                      not.w     d6
[000117d8] cc42                      and.w     d2,d6
[000117da] 8551                      or.w      d2,(a1)
[000117dc] bd59                      eor.w     d6,(a1)+
[000117de] 3c18                      move.w    (a0)+,d6
[000117e0] 4846                      swap      d6
[000117e2] e1be                      rol.l     d0,d6
[000117e4] 4646                      not.w     d6
[000117e6] cc42                      and.w     d2,d6
[000117e8] 8551                      or.w      d2,(a1)
[000117ea] bd59                      eor.w     d6,(a1)+
[000117ec] 3c18                      move.w    (a0)+,d6
[000117ee] 4846                      swap      d6
[000117f0] e1be                      rol.l     d0,d6
[000117f2] 4646                      not.w     d6
[000117f4] cc42                      and.w     d2,d6
[000117f6] 8551                      or.w      d2,(a1)
[000117f8] bd59                      eor.w     d6,(a1)+
[000117fa] 5188                      subq.l    #8,a0
[000117fc] 4845                      swap      d5
[000117fe] 3a01                      move.w    d1,d5
[00011800] 6b30                      bmi.s     $00011832
[00011802] 2c18                      move.l    (a0)+,d6
[00011804] 2e28 0004                 move.l    4(a0),d7
[00011808] 4847                      swap      d7
[0001180a] 2806                      move.l    d6,d4
[0001180c] 3807                      move.w    d7,d4
[0001180e] 3e06                      move.w    d6,d7
[00011810] e1bc                      rol.l     d0,d4
[00011812] e1bf                      rol.l     d0,d7
[00011814] 3807                      move.w    d7,d4
[00011816] 22c4                      move.l    d4,(a1)+
[00011818] 2c18                      move.l    (a0)+,d6
[0001181a] 2e28 0004                 move.l    4(a0),d7
[0001181e] 4847                      swap      d7
[00011820] 2806                      move.l    d6,d4
[00011822] 3807                      move.w    d7,d4
[00011824] 3e06                      move.w    d6,d7
[00011826] e1bc                      rol.l     d0,d4
[00011828] e1bf                      rol.l     d0,d7
[0001182a] 3807                      move.w    d7,d4
[0001182c] 22c4                      move.l    d4,(a1)+
[0001182e] 51cd ffd2                 dbf       d5,$00011802
[00011832] 4845                      swap      d5
[00011834] 3c28 0008                 move.w    8(a0),d6
[00011838] 4846                      swap      d6
[0001183a] 3c18                      move.w    (a0)+,d6
[0001183c] e1be                      rol.l     d0,d6
[0001183e] 4646                      not.w     d6
[00011840] cc43                      and.w     d3,d6
[00011842] 8751                      or.w      d3,(a1)
[00011844] bd59                      eor.w     d6,(a1)+
[00011846] 3c28 0008                 move.w    8(a0),d6
[0001184a] 4846                      swap      d6
[0001184c] 3c18                      move.w    (a0)+,d6
[0001184e] e1be                      rol.l     d0,d6
[00011850] 4646                      not.w     d6
[00011852] cc43                      and.w     d3,d6
[00011854] 8751                      or.w      d3,(a1)
[00011856] bd59                      eor.w     d6,(a1)+
[00011858] 3c28 0008                 move.w    8(a0),d6
[0001185c] 4846                      swap      d6
[0001185e] 3c18                      move.w    (a0)+,d6
[00011860] e1be                      rol.l     d0,d6
[00011862] 4646                      not.w     d6
[00011864] cc43                      and.w     d3,d6
[00011866] 8751                      or.w      d3,(a1)
[00011868] bd59                      eor.w     d6,(a1)+
[0001186a] 3c28 0008                 move.w    8(a0),d6
[0001186e] 4846                      swap      d6
[00011870] 3c18                      move.w    (a0)+,d6
[00011872] e1be                      rol.l     d0,d6
[00011874] 4646                      not.w     d6
[00011876] cc43                      and.w     d3,d6
[00011878] 8751                      or.w      d3,(a1)
[0001187a] bd59                      eor.w     d6,(a1)+
[0001187c] d0ca                      adda.w    a2,a0
[0001187e] d2cb                      adda.w    a3,a1
[00011880] 51cd ff40                 dbf       d5,$000117C2
[00011884] 4e75                      rts
[00011886] 3c18                      move.w    (a0)+,d6
[00011888] 4846                      swap      d6
[0001188a] e1be                      rol.l     d0,d6
[0001188c] 4646                      not.w     d6
[0001188e] cc42                      and.w     d2,d6
[00011890] 8551                      or.w      d2,(a1)
[00011892] bd59                      eor.w     d6,(a1)+
[00011894] 3c18                      move.w    (a0)+,d6
[00011896] 4846                      swap      d6
[00011898] e1be                      rol.l     d0,d6
[0001189a] 4646                      not.w     d6
[0001189c] cc42                      and.w     d2,d6
[0001189e] 8551                      or.w      d2,(a1)
[000118a0] bd59                      eor.w     d6,(a1)+
[000118a2] 3c18                      move.w    (a0)+,d6
[000118a4] 4846                      swap      d6
[000118a6] e1be                      rol.l     d0,d6
[000118a8] 4646                      not.w     d6
[000118aa] cc42                      and.w     d2,d6
[000118ac] 8551                      or.w      d2,(a1)
[000118ae] bd59                      eor.w     d6,(a1)+
[000118b0] 3c18                      move.w    (a0)+,d6
[000118b2] 4846                      swap      d6
[000118b4] e1be                      rol.l     d0,d6
[000118b6] 4646                      not.w     d6
[000118b8] cc42                      and.w     d2,d6
[000118ba] 8551                      or.w      d2,(a1)
[000118bc] bd59                      eor.w     d6,(a1)+
[000118be] 5188                      subq.l    #8,a0
[000118c0] 4845                      swap      d5
[000118c2] 3a01                      move.w    d1,d5
[000118c4] 6b30                      bmi.s     $000118F6
[000118c6] 2c18                      move.l    (a0)+,d6
[000118c8] 2e28 0004                 move.l    4(a0),d7
[000118cc] 4847                      swap      d7
[000118ce] 2806                      move.l    d6,d4
[000118d0] 3807                      move.w    d7,d4
[000118d2] 3e06                      move.w    d6,d7
[000118d4] e1bc                      rol.l     d0,d4
[000118d6] e1bf                      rol.l     d0,d7
[000118d8] 3807                      move.w    d7,d4
[000118da] 22c4                      move.l    d4,(a1)+
[000118dc] 2c18                      move.l    (a0)+,d6
[000118de] 2e28 0004                 move.l    4(a0),d7
[000118e2] 4847                      swap      d7
[000118e4] 2806                      move.l    d6,d4
[000118e6] 3807                      move.w    d7,d4
[000118e8] 3e06                      move.w    d6,d7
[000118ea] e1bc                      rol.l     d0,d4
[000118ec] e1bf                      rol.l     d0,d7
[000118ee] 3807                      move.w    d7,d4
[000118f0] 22c4                      move.l    d4,(a1)+
[000118f2] 51cd ffd2                 dbf       d5,$000118C6
[000118f6] 4845                      swap      d5
[000118f8] 3c18                      move.w    (a0)+,d6
[000118fa] e1be                      rol.l     d0,d6
[000118fc] 4646                      not.w     d6
[000118fe] cc43                      and.w     d3,d6
[00011900] 8751                      or.w      d3,(a1)
[00011902] bd59                      eor.w     d6,(a1)+
[00011904] 3c18                      move.w    (a0)+,d6
[00011906] e1be                      rol.l     d0,d6
[00011908] 4646                      not.w     d6
[0001190a] cc43                      and.w     d3,d6
[0001190c] 8751                      or.w      d3,(a1)
[0001190e] bd59                      eor.w     d6,(a1)+
[00011910] 3c18                      move.w    (a0)+,d6
[00011912] e1be                      rol.l     d0,d6
[00011914] 4646                      not.w     d6
[00011916] cc43                      and.w     d3,d6
[00011918] 8751                      or.w      d3,(a1)
[0001191a] bd59                      eor.w     d6,(a1)+
[0001191c] 3c18                      move.w    (a0)+,d6
[0001191e] e1be                      rol.l     d0,d6
[00011920] 4646                      not.w     d6
[00011922] cc43                      and.w     d3,d6
[00011924] 8751                      or.w      d3,(a1)
[00011926] bd59                      eor.w     d6,(a1)+
[00011928] d0ca                      adda.w    a2,a0
[0001192a] d2cb                      adda.w    a3,a1
[0001192c] 51cd ff58                 dbf       d5,$00011886
[00011930] 4e75                      rts
[00011932] c443                      and.w     d3,d2
[00011934] 3602                      move.w    d2,d3
[00011936] 4643                      not.w     d3
[00011938] 514a                      subq.w    #8,a2
[0001193a] 3c18                      move.w    (a0)+,d6
[0001193c] e1be                      rol.l     d0,d6
[0001193e] cc42                      and.w     d2,d6
[00011940] c751                      and.w     d3,(a1)
[00011942] 8d59                      or.w      d6,(a1)+
[00011944] 3c18                      move.w    (a0)+,d6
[00011946] e1be                      rol.l     d0,d6
[00011948] cc42                      and.w     d2,d6
[0001194a] c751                      and.w     d3,(a1)
[0001194c] 8d59                      or.w      d6,(a1)+
[0001194e] 3c18                      move.w    (a0)+,d6
[00011950] e1be                      rol.l     d0,d6
[00011952] cc42                      and.w     d2,d6
[00011954] c751                      and.w     d3,(a1)
[00011956] 8d59                      or.w      d6,(a1)+
[00011958] 3c18                      move.w    (a0)+,d6
[0001195a] e1be                      rol.l     d0,d6
[0001195c] cc42                      and.w     d2,d6
[0001195e] c751                      and.w     d3,(a1)
[00011960] 8d59                      or.w      d6,(a1)+
[00011962] d0ca                      adda.w    a2,a0
[00011964] d2cb                      adda.w    a3,a1
[00011966] 51cd ffd2                 dbf       d5,$0001193A
[0001196a] 4e75                      rts
[0001196c] 206e 01c2                 movea.l   450(a6),a0
[00011970] 226e 01d6                 movea.l   470(a6),a1
[00011974] 3c0a                      move.w    a2,d6
[00011976] d245                      add.w     d5,d1
[00011978] ccc1                      mulu.w    d1,d6
[0001197a] d1c6                      adda.l    d6,a0
[0001197c] 3c00                      move.w    d0,d6
[0001197e] dc44                      add.w     d4,d6
[00011980] e84e                      lsr.w     #4,d6
[00011982] dc46                      add.w     d6,d6
[00011984] 3e2e 01c8                 move.w    456(a6),d7
[00011988] 5247                      addq.w    #1,d7
[0001198a] ccc7                      mulu.w    d7,d6
[0001198c] d1c6                      adda.l    d6,a0
[0001198e] 3c0b                      move.w    a3,d6
[00011990] d645                      add.w     d5,d3
[00011992] ccc3                      mulu.w    d3,d6
[00011994] d3c6                      adda.l    d6,a1
[00011996] 3c02                      move.w    d2,d6
[00011998] dc44                      add.w     d4,d6
[0001199a] e84e                      lsr.w     #4,d6
[0001199c] 48c6                      ext.l     d6
[0001199e] e78e                      lsl.l     #3,d6
[000119a0] d3c6                      adda.l    d6,a1
[000119a2] 7c0f                      moveq.l   #15,d6
[000119a4] 3e00                      move.w    d0,d7
[000119a6] ce46                      and.w     d6,d7
[000119a8] de44                      add.w     d4,d7
[000119aa] e84f                      lsr.w     #4,d7
[000119ac] 3602                      move.w    d2,d3
[000119ae] d644                      add.w     d4,d3
[000119b0] d044                      add.w     d4,d0
[000119b2] c046                      and.w     d6,d0
[000119b4] c646                      and.w     d6,d3
[000119b6] 9043                      sub.w     d3,d0
[000119b8] 3202                      move.w    d2,d1
[000119ba] c246                      and.w     d6,d1
[000119bc] d244                      add.w     d4,d1
[000119be] e849                      lsr.w     #4,d1
[000119c0] 9e41                      sub.w     d1,d7
[000119c2] d842                      add.w     d2,d4
[000119c4] 4644                      not.w     d4
[000119c6] c846                      and.w     d6,d4
[000119c8] 76ff                      moveq.l   #-1,d3
[000119ca] e96b                      lsl.w     d4,d3
[000119cc] cc42                      and.w     d2,d6
[000119ce] 74ff                      moveq.l   #-1,d2
[000119d0] ec6a                      lsr.w     d6,d2
[000119d2] 3801                      move.w    d1,d4
[000119d4] 3c04                      move.w    d4,d6
[000119d6] c8ee 01ca                 mulu.w    458(a6),d4
[000119da] ccee 01de                 mulu.w    478(a6),d6
[000119de] 94c4                      suba.w    d4,a2
[000119e0] 96c6                      suba.w    d6,a3
[000119e2] 3807                      move.w    d7,d4
[000119e4] 7c04                      moveq.l   #4,d6
[000119e6] 7e00                      moveq.l   #0,d7
[000119e8] 49fa 00e6                 lea.l     $00011AD0(pc),a4
[000119ec] 4a40                      tst.w     d0
[000119ee] 674e                      beq.s     $00011A3E
[000119f0] 6d1e                      blt.s     $00011A10
[000119f2] 49fa 015c                 lea.l     $00011B50(pc),a4
[000119f6] 7c0a                      moveq.l   #10,d6
[000119f8] 4a44                      tst.w     d4
[000119fa] 6a02                      bpl.s     $000119FE
[000119fc] 7e02                      moveq.l   #2,d7
[000119fe] 0c40 0008                 cmpi.w    #$0008,d0
[00011a02] 6f3a                      ble.s     $00011A3E
[00011a04] 49fa 01ca                 lea.l     $00011BD0(pc),a4
[00011a08] 5340                      subq.w    #1,d0
[00011a0a] 0a40 000f                 eori.w    #$000F,d0
[00011a0e] 602e                      bra.s     $00011A3E
[00011a10] 49fa 01be                 lea.l     $00011BD0(pc),a4
[00011a14] 4440                      neg.w     d0
[00011a16] 4a41                      tst.w     d1
[00011a18] 6608                      bne.s     $00011A22
[00011a1a] 4a44                      tst.w     d4
[00011a1c] 6604                      bne.s     $00011A22
[00011a1e] 7c0c                      moveq.l   #12,d6
[00011a20] 601c                      bra.s     $00011A3E
[00011a22] 7c04                      moveq.l   #4,d6
[00011a24] 94ee 01ca                 suba.w    458(a6),a2
[00011a28] 4a44                      tst.w     d4
[00011a2a] 6e02                      bgt.s     $00011A2E
[00011a2c] 7e02                      moveq.l   #2,d7
[00011a2e] 0c40 0008                 cmpi.w    #$0008,d0
[00011a32] 6f0a                      ble.s     $00011A3E
[00011a34] 49fa 011a                 lea.l     $00011B50(pc),a4
[00011a38] 5340                      subq.w    #1,d0
[00011a3a] 0a40 000f                 eori.w    #$000F,d0
[00011a3e] 382e 01dc                 move.w    476(a6),d4
[00011a42] b86e 01c8                 cmp.w     456(a6),d4
[00011a46] 6616                      bne.s     $00011A5E
[00011a48] b87c 0003                 cmp.w     #$0003,d4
[00011a4c] 6610                      bne.s     $00011A5E
[00011a4e] 4aae 01ea                 tst.l     490(a6)
[00011a52] 660a                      bne.s     $00011A5E
[00011a54] 0c2e 0003 01ee            cmpi.b    #$03,494(a6)
[00011a5a] 6700 0ca0                 beq       $000126FC
[00011a5e] 3d4a 01c6                 move.w    a2,454(a6)
[00011a62] 3d4b 01da                 move.w    a3,474(a6)
[00011a66] 346e 01ca                 movea.w   458(a6),a2
[00011a6a] 366e 01de                 movea.w   478(a6),a3
[00011a6e] 4a41                      tst.w     d1
[00011a70] 6610                      bne.s     $00011A82
[00011a72] c642                      and.w     d2,d3
[00011a74] 340a                      move.w    a2,d2
[00011a76] 956e 01c6                 sub.w     d2,454(a6)
[00011a7a] 340b                      move.w    a3,d2
[00011a7c] 956e 01da                 sub.w     d2,474(a6)
[00011a80] 7400                      moveq.l   #0,d2
[00011a82] 48e7 4fc8                 movem.l   d1/d4-d7/a0-a1/a4,-(a7)
[00011a86] 4bee 01ea                 lea.l     490(a6),a5
[00011a8a] 7800                      moveq.l   #0,d4
[00011a8c] e2dd                      lsr.w     (a5)+
[00011a8e] d944                      addx.w    d4,d4
[00011a90] e2dd                      lsr.w     (a5)+
[00011a92] d944                      addx.w    d4,d4
[00011a94] 1835 4000                 move.b    0(a5,d4.w),d4
[00011a98] e74c                      lsl.w     #3,d4
[00011a9a] 3a44                      movea.w   d4,a5
[00011a9c] dbcc                      adda.l    a4,a5
[00011a9e] 381d                      move.w    (a5)+,d4
[00011aa0] dc44                      add.w     d4,d6
[00011aa2] de5d                      add.w     (a5)+,d7
[00011aa4] 4a41                      tst.w     d1
[00011aa6] 6602                      bne.s     $00011AAA
[00011aa8] 3e15                      move.w    (a5),d7
[00011aaa] 5541                      subq.w    #2,d1
[00011aac] 49fa 0022                 lea.l     $00011AD0(pc),a4
[00011ab0] 4bfa 001e                 lea.l     $00011AD0(pc),a5
[00011ab4] d8c6                      adda.w    d6,a4
[00011ab6] dac7                      adda.w    d7,a5
[00011ab8] 4ebb 4016                 jsr       $00011AD0(pc,d4.w)
[00011abc] 4cdf 13f2                 movem.l   (a7)+,d1/d4-d7/a0-a1/a4
[00011ac0] 5489                      addq.l    #2,a1
[00011ac2] 4a6e 01c8                 tst.w     456(a6)
[00011ac6] 6702                      beq.s     $00011ACA
[00011ac8] 5488                      addq.l    #2,a0
[00011aca] 51cc ffb6                 dbf       d4,$00011A82
[00011ace] 4e75                      rts
[00011ad0] 0180                      bclr      d0,d0
[00011ad2] 0000 0000                 ori.b     #$00,d0
[00011ad6] 0000 01ba                 ori.b     #$BA,d0
[00011ada] 01da                      bset      d0,(a2)+
[00011adc] 01e4                      bset      d0,-(a4)
[00011ade] 0000 0294                 ori.b     #$94,d0
[00011ae2] 02b8 02c4 0000 0380       andi.l    #$02C40000,($00000380).w
[00011aea] 039e                      bclr      d1,(a6)+
[00011aec] 03a8 0000                 bclr      d1,0(a0)
[00011af0] 0458 0478                 subi.w    #$0478,(a0)+
[00011af4] 0480 0000 1a90            subi.l    #$00001A90,d0
[00011afa] 0000 0000                 ori.b     #$00,d0
[00011afe] 0000 052e                 ori.b     #$2E,d0
[00011b02] 054a 0550                 movep.l   1360(a2),d2
[00011b06] 0000 05f0                 ori.b     #$F0,d0
[00011b0a] 060c 0612                 addi.b    #$12,a4 ; apollo only
[00011b0e] 0000 06b2                 ori.b     #$B2,d0
[00011b12] 06d2 06da                 callm     #$06DA,(a2) ; 68020 only
[00011b16] 0000 0786                 ori.b     #$86,d0
[00011b1a] 07a6                      bclr      d3,-(a6)
[00011b1c] 07ae 0000                 bclr      d3,0(a6)
[00011b20] 1dbe 0000                 move.b    ???,0(a6,d0.w)
[00011b24] 0000 0000                 ori.b     #$00,d0
[00011b28] 0888 08a8                 bclr      #2216,a0
[00011b2c] 08b0 0000 095c            bclr      #0,([a0]) ; 68020+ only; reserved OD=0
[00011b32] 0982                      bclr      d4,d2
[00011b34] 0990                      bclr      d4,(a0)
[00011b36] 0000 0a54                 ori.b     #$54,d0
[00011b3a] 0a74 0a7c 0000            eori.w    #$0A7C,0(a4,d0.w)
[00011b40] 0b28 0b48                 btst      d5,2888(a0)
[00011b44] 0b50                      bchg      d5,(a0)
[00011b46] 0000 2160                 ori.b     #$60,d0
[00011b4a] 0000 0000                 ori.b     #$00,d0
[00011b4e] 0000 0180                 ori.b     #$80,d0
[00011b52] 0000 0000                 ori.b     #$00,d0
[00011b56] 0000 0244                 ori.b     #$44,d0
[00011b5a] 027a 0286 0000            andi.w    #$0286,$00011B5C(pc) ; apollo only
[00011b60] 032a 0364                 btst      d1,868(a2)
[00011b64] 0372 0000                 bchg      d1,0(a2,d0.w)
[00011b68] 0408 043e                 subi.b    #$3E,a0 ; apollo only
[00011b6c] 044a 0000                 subi.w    #$0000,a2 ; apollo only
[00011b70] 04de                      dc.w      $04DE ; illegal
[00011b72] 0514                      btst      d2,(a4)
[00011b74] 051e                      btst      d2,(a6)+
[00011b76] 0000 1a90                 ori.b     #$90,d0
[00011b7a] 0000 0000                 ori.b     #$00,d0
[00011b7e] 0000 05a8                 ori.b     #$A8,d0
[00011b82] 05da                      bset      d2,(a2)+
[00011b84] 05e2                      bset      d2,-(a2)
[00011b86] 0000 066a                 ori.b     #$6A,d0
[00011b8a] 069c 06a4 0000            addi.l    #$06A40000,(a4)+
[00011b90] 0738 076e                 btst      d3,($0000076E).w
[00011b94] 0778 0000                 bchg      d3,($00000000).w
[00011b98] 080c 0842                 btst      #2114,a4
[00011b9c] 084c 0000                 bchg      #0,a4
[00011ba0] 1dbe 0000                 move.b    ???,0(a6,d0.w)
[00011ba4] 0000 0000                 ori.b     #$00,d0
[00011ba8] 090e 0944                 movep.w   2372(a6),d4
[00011bac] 094e 0000                 movep.l   0(a6),d4
[00011bb0] 09fa 0a36                 bset      d4,$000125E8(pc) ; apollo only
[00011bb4] 0a46 0000                 eori.w    #$0000,d6
[00011bb8] 0ada 0b10                 cas.b     d0,d4,(a2)+ ; 68020+ only
[00011bbc] 0b1a                      btst      d5,(a2)+
[00011bbe] 0000 0bae                 ori.b     #$AE,d0
[00011bc2] 0be4                      bset      d5,-(a4)
[00011bc4] 0bee 0000                 bset      d5,0(a6)
[00011bc8] 2160 0000                 move.l    -(a0),0(a0)
[00011bcc] 0000 0000                 ori.b     #$00,d0
[00011bd0] 0180                      bclr      d0,d0
[00011bd2] 0000 0000                 ori.b     #$00,d0
[00011bd6] 0000 01f2                 ori.b     #$F2,d0
[00011bda] 0228 0236 0000            andi.b    #$36,0(a0)
[00011be0] 02d2 030c                 cmp2.w    (a2),d0 ; 68020+ only
[00011be4] 031c                      btst      d1,(a4)+
[00011be6] 0000 03b6                 ori.b     #$B6,d0
[00011bea] 03ec 03fa                 bset      d1,1018(a4)
[00011bee] 0000 048e                 ori.b     #$8E,d0
[00011bf2] 04c4                      ff1.l     d4 ; ColdFire isa_c only
[00011bf4] 04d0 0000                 cmp2.l    (a0),d0 ; 68020+ only
[00011bf8] 1a90                      move.b    (a0),(a5)
[00011bfa] 0000 0000                 ori.b     #$00,d0
[00011bfe] 0000 055e                 ori.b     #$5E,d0
[00011c02] 0590                      bclr      d2,(a0)
[00011c04] 059a                      bclr      d2,(a2)+
[00011c06] 0000 0620                 ori.b     #$20,d0
[00011c0a] 0652 065c                 addi.w    #$065C,(a2)
[00011c0e] 0000 06e8                 ori.b     #$E8,d0
[00011c12] 071e                      btst      d3,(a6)+
[00011c14] 072a 0000                 btst      d3,0(a2)
[00011c18] 07bc                      bclr      d3,# ; illegal
[00011c1a] 07f2 07fe 0000 1dbe 0000  bset      d3,([$00001DBE,za2],zd0.w*8,$0000) ; 68020+ only; reserved OD=2
[00011c24] 0000 0000                 ori.b     #$00,d0
[00011c28] 08be 08f4                 bclr      #2292,???
[00011c2c] 0900                      btst      d4,d0
[00011c2e] 0000 099e                 ori.b     #$9E,d0
[00011c32] 09da                      bset      d4,(a2)+
[00011c34] 09ec 0000                 bset      d4,0(a4)
[00011c38] 0a8a 0ac0 0acc            eori.l    #$0AC00ACC,a2 ; apollo only
[00011c3e] 0000 0b5e                 ori.b     #$5E,d0
[00011c42] 0b94                      bclr      d5,(a4)
[00011c44] 0ba0                      bclr      d5,-(a0)
[00011c46] 0000 2160                 ori.b     #$60,d0
[00011c4a] 0000 0000                 ori.b     #$00,d0
[00011c4e] 0000 3e2e                 ori.b     #$2E,d0
[00011c52] 01da                      bset      d0,(a2)+
[00011c54] 4643                      not.w     d3
[00011c56] 4a42                      tst.w     d2
[00011c58] 660e                      bne.s     $00011C68
[00011c5a] de4b                      add.w     a3,d7
[00011c5c] c751                      and.w     d3,(a1)
[00011c5e] 92c7                      suba.w    d7,a1
[00011c60] 51cd fffa                 dbf       d5,$00011C5C
[00011c64] 4643                      not.w     d3
[00011c66] 4e75                      rts
[00011c68] 4642                      not.w     d2
[00011c6a] 7c00                      moveq.l   #0,d6
[00011c6c] c751                      and.w     d3,(a1)
[00011c6e] 92cb                      suba.w    a3,a1
[00011c70] 3801                      move.w    d1,d4
[00011c72] 6b08                      bmi.s     $00011C7C
[00011c74] 3286                      move.w    d6,(a1)
[00011c76] 92cb                      suba.w    a3,a1
[00011c78] 51cc fffa                 dbf       d4,$00011C74
[00011c7c] c551                      and.w     d2,(a1)
[00011c7e] 92c7                      suba.w    d7,a1
[00011c80] 51cd ffea                 dbf       d5,$00011C6C
[00011c84] 4642                      not.w     d2
[00011c86] 4643                      not.w     d3
[00011c88] 4e75                      rts
[00011c8a] 3c10                      move.w    (a0),d6
[00011c8c] 4643                      not.w     d3
[00011c8e] 8c43                      or.w      d3,d6
[00011c90] 4643                      not.w     d3
[00011c92] cd51                      and.w     d6,(a1)
[00011c94] 3801                      move.w    d1,d4
[00011c96] 6b0c                      bmi.s     $00011CA4
[00011c98] 90ca                      suba.w    a2,a0
[00011c9a] 92cb                      suba.w    a3,a1
[00011c9c] 3c10                      move.w    (a0),d6
[00011c9e] cd51                      and.w     d6,(a1)
[00011ca0] 51cc fff6                 dbf       d4,$00011C98
[00011ca4] 90ca                      suba.w    a2,a0
[00011ca6] 92cb                      suba.w    a3,a1
[00011ca8] 4ed5                      jmp       (a5)
[00011caa] 3c10                      move.w    (a0),d6
[00011cac] 4642                      not.w     d2
[00011cae] 8c42                      or.w      d2,d6
[00011cb0] 4642                      not.w     d2
[00011cb2] cd51                      and.w     d6,(a1)
[00011cb4] 90ee 01c6                 suba.w    454(a6),a0
[00011cb8] 92ee 01da                 suba.w    474(a6),a1
[00011cbc] 51cd ffcc                 dbf       d5,$00011C8A
[00011cc0] 4e75                      rts
[00011cc2] 3c10                      move.w    (a0),d6
[00011cc4] 4ed4                      jmp       (a4)
[00011cc6] 4846                      swap      d6
[00011cc8] 90ca                      suba.w    a2,a0
[00011cca] 3c10                      move.w    (a0),d6
[00011ccc] 4846                      swap      d6
[00011cce] 2e06                      move.l    d6,d7
[00011cd0] e0be                      ror.l     d0,d6
[00011cd2] 4643                      not.w     d3
[00011cd4] 8c43                      or.w      d3,d6
[00011cd6] cd51                      and.w     d6,(a1)
[00011cd8] 4643                      not.w     d3
[00011cda] 3801                      move.w    d1,d4
[00011cdc] 6b14                      bmi.s     $00011CF2
[00011cde] 90ca                      suba.w    a2,a0
[00011ce0] 92cb                      suba.w    a3,a1
[00011ce2] 2c07                      move.l    d7,d6
[00011ce4] 3c10                      move.w    (a0),d6
[00011ce6] 4846                      swap      d6
[00011ce8] 2e06                      move.l    d6,d7
[00011cea] e0be                      ror.l     d0,d6
[00011cec] cd51                      and.w     d6,(a1)
[00011cee] 51cc ffee                 dbf       d4,$00011CDE
[00011cf2] 90ca                      suba.w    a2,a0
[00011cf4] 92cb                      suba.w    a3,a1
[00011cf6] 4ed5                      jmp       (a5)
[00011cf8] 3e10                      move.w    (a0),d7
[00011cfa] 4847                      swap      d7
[00011cfc] e0bf                      ror.l     d0,d7
[00011cfe] 4642                      not.w     d2
[00011d00] 8e42                      or.w      d2,d7
[00011d02] 4642                      not.w     d2
[00011d04] cf51                      and.w     d7,(a1)
[00011d06] 90ee 01c6                 suba.w    454(a6),a0
[00011d0a] 92ee 01da                 suba.w    474(a6),a1
[00011d0e] 51cd ffb2                 dbf       d5,$00011CC2
[00011d12] 4e75                      rts
[00011d14] 3c10                      move.w    (a0),d6
[00011d16] 4ed4                      jmp       (a4)
[00011d18] 4846                      swap      d6
[00011d1a] 90ca                      suba.w    a2,a0
[00011d1c] 3c10                      move.w    (a0),d6
[00011d1e] 3e06                      move.w    d6,d7
[00011d20] e1be                      rol.l     d0,d6
[00011d22] 4643                      not.w     d3
[00011d24] 8c43                      or.w      d3,d6
[00011d26] 4643                      not.w     d3
[00011d28] cd51                      and.w     d6,(a1)
[00011d2a] 3801                      move.w    d1,d4
[00011d2c] 6b14                      bmi.s     $00011D42
[00011d2e] 90ca                      suba.w    a2,a0
[00011d30] 92cb                      suba.w    a3,a1
[00011d32] 3c07                      move.w    d7,d6
[00011d34] 4846                      swap      d6
[00011d36] 3c10                      move.w    (a0),d6
[00011d38] 3e06                      move.w    d6,d7
[00011d3a] e1be                      rol.l     d0,d6
[00011d3c] cd51                      and.w     d6,(a1)
[00011d3e] 51cc ffee                 dbf       d4,$00011D2E
[00011d42] 90ca                      suba.w    a2,a0
[00011d44] 92cb                      suba.w    a3,a1
[00011d46] 4847                      swap      d7
[00011d48] 4ed5                      jmp       (a5)
[00011d4a] 3e10                      move.w    (a0),d7
[00011d4c] e1bf                      rol.l     d0,d7
[00011d4e] 4642                      not.w     d2
[00011d50] 8e42                      or.w      d2,d7
[00011d52] 4642                      not.w     d2
[00011d54] cf51                      and.w     d7,(a1)
[00011d56] 90ee 01c6                 suba.w    454(a6),a0
[00011d5a] 92ee 01da                 suba.w    474(a6),a1
[00011d5e] 51cd ffb4                 dbf       d5,$00011D14
[00011d62] 4e75                      rts
[00011d64] 3c10                      move.w    (a0),d6
[00011d66] b751                      eor.w     d3,(a1)
[00011d68] 4643                      not.w     d3
[00011d6a] 8c43                      or.w      d3,d6
[00011d6c] 4643                      not.w     d3
[00011d6e] cd51                      and.w     d6,(a1)
[00011d70] 3801                      move.w    d1,d4
[00011d72] 6b0e                      bmi.s     $00011D82
[00011d74] 90ca                      suba.w    a2,a0
[00011d76] 92cb                      suba.w    a3,a1
[00011d78] 3c10                      move.w    (a0),d6
[00011d7a] 4651                      not.w     (a1)
[00011d7c] cd51                      and.w     d6,(a1)
[00011d7e] 51cc fff4                 dbf       d4,$00011D74
[00011d82] 90ca                      suba.w    a2,a0
[00011d84] 92cb                      suba.w    a3,a1
[00011d86] 4ed5                      jmp       (a5)
[00011d88] 3c10                      move.w    (a0),d6
[00011d8a] b551                      eor.w     d2,(a1)
[00011d8c] 4642                      not.w     d2
[00011d8e] 8c42                      or.w      d2,d6
[00011d90] 4642                      not.w     d2
[00011d92] cd51                      and.w     d6,(a1)
[00011d94] 90ee 01c6                 suba.w    454(a6),a0
[00011d98] 92ee 01da                 suba.w    474(a6),a1
[00011d9c] 51cd ffc6                 dbf       d5,$00011D64
[00011da0] 4e75                      rts
[00011da2] 3c10                      move.w    (a0),d6
[00011da4] 4ed4                      jmp       (a4)
[00011da6] 4846                      swap      d6
[00011da8] 90ca                      suba.w    a2,a0
[00011daa] 3c10                      move.w    (a0),d6
[00011dac] 4846                      swap      d6
[00011dae] 2e06                      move.l    d6,d7
[00011db0] e0be                      ror.l     d0,d6
[00011db2] b751                      eor.w     d3,(a1)
[00011db4] 4643                      not.w     d3
[00011db6] 8c43                      or.w      d3,d6
[00011db8] 4643                      not.w     d3
[00011dba] cd51                      and.w     d6,(a1)
[00011dbc] 3801                      move.w    d1,d4
[00011dbe] 6b16                      bmi.s     $00011DD6
[00011dc0] 90ca                      suba.w    a2,a0
[00011dc2] 92cb                      suba.w    a3,a1
[00011dc4] 2c07                      move.l    d7,d6
[00011dc6] 3c10                      move.w    (a0),d6
[00011dc8] 4846                      swap      d6
[00011dca] 2e06                      move.l    d6,d7
[00011dcc] e0be                      ror.l     d0,d6
[00011dce] 4651                      not.w     (a1)
[00011dd0] cd51                      and.w     d6,(a1)
[00011dd2] 51cc ffec                 dbf       d4,$00011DC0
[00011dd6] 90ca                      suba.w    a2,a0
[00011dd8] 92cb                      suba.w    a3,a1
[00011dda] 4ed5                      jmp       (a5)
[00011ddc] 3e10                      move.w    (a0),d7
[00011dde] 4847                      swap      d7
[00011de0] e0bf                      ror.l     d0,d7
[00011de2] b551                      eor.w     d2,(a1)
[00011de4] 4642                      not.w     d2
[00011de6] 8e42                      or.w      d2,d7
[00011de8] 4642                      not.w     d2
[00011dea] cf51                      and.w     d7,(a1)
[00011dec] 90ee 01c6                 suba.w    454(a6),a0
[00011df0] 92ee 01da                 suba.w    474(a6),a1
[00011df4] 51cd ffac                 dbf       d5,$00011DA2
[00011df8] 4e75                      rts
[00011dfa] 3c10                      move.w    (a0),d6
[00011dfc] 4ed4                      jmp       (a4)
[00011dfe] 4846                      swap      d6
[00011e00] 90ca                      suba.w    a2,a0
[00011e02] 3c10                      move.w    (a0),d6
[00011e04] 3e06                      move.w    d6,d7
[00011e06] e1be                      rol.l     d0,d6
[00011e08] b751                      eor.w     d3,(a1)
[00011e0a] 4643                      not.w     d3
[00011e0c] 8c43                      or.w      d3,d6
[00011e0e] 4643                      not.w     d3
[00011e10] cd51                      and.w     d6,(a1)
[00011e12] 3801                      move.w    d1,d4
[00011e14] 6b16                      bmi.s     $00011E2C
[00011e16] 90ca                      suba.w    a2,a0
[00011e18] 92cb                      suba.w    a3,a1
[00011e1a] 3c07                      move.w    d7,d6
[00011e1c] 4846                      swap      d6
[00011e1e] 3c10                      move.w    (a0),d6
[00011e20] 3e06                      move.w    d6,d7
[00011e22] e1be                      rol.l     d0,d6
[00011e24] 4651                      not.w     (a1)
[00011e26] cd51                      and.w     d6,(a1)
[00011e28] 51cc ffec                 dbf       d4,$00011E16
[00011e2c] 90ca                      suba.w    a2,a0
[00011e2e] 92cb                      suba.w    a3,a1
[00011e30] 4847                      swap      d7
[00011e32] 4ed5                      jmp       (a5)
[00011e34] 3e10                      move.w    (a0),d7
[00011e36] e1bf                      rol.l     d0,d7
[00011e38] b551                      eor.w     d2,(a1)
[00011e3a] 4642                      not.w     d2
[00011e3c] 8e42                      or.w      d2,d7
[00011e3e] 4642                      not.w     d2
[00011e40] cf51                      and.w     d7,(a1)
[00011e42] 90ee 01c6                 suba.w    454(a6),a0
[00011e46] 92ee 01da                 suba.w    474(a6),a1
[00011e4a] 51cd ffae                 dbf       d5,$00011DFA
[00011e4e] 4e75                      rts
[00011e50] 3c10                      move.w    (a0),d6
[00011e52] 4646                      not.w     d6
[00011e54] cc43                      and.w     d3,d6
[00011e56] 8751                      or.w      d3,(a1)
[00011e58] bd51                      eor.w     d6,(a1)
[00011e5a] 3801                      move.w    d1,d4
[00011e5c] 6b0a                      bmi.s     $00011E68
[00011e5e] 90ca                      suba.w    a2,a0
[00011e60] 92cb                      suba.w    a3,a1
[00011e62] 3290                      move.w    (a0),(a1)
[00011e64] 51cc fff8                 dbf       d4,$00011E5E
[00011e68] 90ca                      suba.w    a2,a0
[00011e6a] 92cb                      suba.w    a3,a1
[00011e6c] 4ed5                      jmp       (a5)
[00011e6e] 3c10                      move.w    (a0),d6
[00011e70] 4646                      not.w     d6
[00011e72] cc42                      and.w     d2,d6
[00011e74] 8551                      or.w      d2,(a1)
[00011e76] bd51                      eor.w     d6,(a1)
[00011e78] 90ee 01c6                 suba.w    454(a6),a0
[00011e7c] 92ee 01da                 suba.w    474(a6),a1
[00011e80] 51cd ffce                 dbf       d5,$00011E50
[00011e84] 4e75                      rts
[00011e86] 3c10                      move.w    (a0),d6
[00011e88] 4ed4                      jmp       (a4)
[00011e8a] 4846                      swap      d6
[00011e8c] 90ca                      suba.w    a2,a0
[00011e8e] 3c10                      move.w    (a0),d6
[00011e90] 4846                      swap      d6
[00011e92] 2e06                      move.l    d6,d7
[00011e94] e0be                      ror.l     d0,d6
[00011e96] 4646                      not.w     d6
[00011e98] cc43                      and.w     d3,d6
[00011e9a] 8751                      or.w      d3,(a1)
[00011e9c] bd51                      eor.w     d6,(a1)
[00011e9e] 3801                      move.w    d1,d4
[00011ea0] 6b14                      bmi.s     $00011EB6
[00011ea2] 90ca                      suba.w    a2,a0
[00011ea4] 92cb                      suba.w    a3,a1
[00011ea6] 2c07                      move.l    d7,d6
[00011ea8] 3c10                      move.w    (a0),d6
[00011eaa] 4846                      swap      d6
[00011eac] 2e06                      move.l    d6,d7
[00011eae] e0be                      ror.l     d0,d6
[00011eb0] 3286                      move.w    d6,(a1)
[00011eb2] 51cc ffee                 dbf       d4,$00011EA2
[00011eb6] 90ca                      suba.w    a2,a0
[00011eb8] 92cb                      suba.w    a3,a1
[00011eba] 4ed5                      jmp       (a5)
[00011ebc] 3e10                      move.w    (a0),d7
[00011ebe] 4847                      swap      d7
[00011ec0] e0bf                      ror.l     d0,d7
[00011ec2] 4647                      not.w     d7
[00011ec4] ce42                      and.w     d2,d7
[00011ec6] 8551                      or.w      d2,(a1)
[00011ec8] bf51                      eor.w     d7,(a1)
[00011eca] 90ee 01c6                 suba.w    454(a6),a0
[00011ece] 92ee 01da                 suba.w    474(a6),a1
[00011ed2] 51cd ffb2                 dbf       d5,$00011E86
[00011ed6] 4e75                      rts
[00011ed8] 3c10                      move.w    (a0),d6
[00011eda] 4ed4                      jmp       (a4)
[00011edc] 4846                      swap      d6
[00011ede] 90ca                      suba.w    a2,a0
[00011ee0] 3c10                      move.w    (a0),d6
[00011ee2] 3e06                      move.w    d6,d7
[00011ee4] e1be                      rol.l     d0,d6
[00011ee6] 4646                      not.w     d6
[00011ee8] cc43                      and.w     d3,d6
[00011eea] 8751                      or.w      d3,(a1)
[00011eec] bd51                      eor.w     d6,(a1)
[00011eee] 3801                      move.w    d1,d4
[00011ef0] 6b14                      bmi.s     $00011F06
[00011ef2] 90ca                      suba.w    a2,a0
[00011ef4] 92cb                      suba.w    a3,a1
[00011ef6] 3c07                      move.w    d7,d6
[00011ef8] 4846                      swap      d6
[00011efa] 3c10                      move.w    (a0),d6
[00011efc] 3e06                      move.w    d6,d7
[00011efe] e1be                      rol.l     d0,d6
[00011f00] 3286                      move.w    d6,(a1)
[00011f02] 51cc ffee                 dbf       d4,$00011EF2
[00011f06] 90ca                      suba.w    a2,a0
[00011f08] 92cb                      suba.w    a3,a1
[00011f0a] 4847                      swap      d7
[00011f0c] 4ed5                      jmp       (a5)
[00011f0e] 3e10                      move.w    (a0),d7
[00011f10] e1bf                      rol.l     d0,d7
[00011f12] 4647                      not.w     d7
[00011f14] ce42                      and.w     d2,d7
[00011f16] 8551                      or.w      d2,(a1)
[00011f18] bf51                      eor.w     d7,(a1)
[00011f1a] 90ee 01c6                 suba.w    454(a6),a0
[00011f1e] 92ee 01da                 suba.w    474(a6),a1
[00011f22] 51cd ffb4                 dbf       d5,$00011ED8
[00011f26] 4e75                      rts
[00011f28] 3c10                      move.w    (a0),d6
[00011f2a] cc43                      and.w     d3,d6
[00011f2c] 4646                      not.w     d6
[00011f2e] cd51                      and.w     d6,(a1)
[00011f30] 3801                      move.w    d1,d4
[00011f32] 6b0e                      bmi.s     $00011F42
[00011f34] 90ca                      suba.w    a2,a0
[00011f36] 92cb                      suba.w    a3,a1
[00011f38] 3c10                      move.w    (a0),d6
[00011f3a] 4646                      not.w     d6
[00011f3c] cd51                      and.w     d6,(a1)
[00011f3e] 51cc fff4                 dbf       d4,$00011F34
[00011f42] 90ca                      suba.w    a2,a0
[00011f44] 92cb                      suba.w    a3,a1
[00011f46] 4ed5                      jmp       (a5)
[00011f48] 3c10                      move.w    (a0),d6
[00011f4a] cc42                      and.w     d2,d6
[00011f4c] 4646                      not.w     d6
[00011f4e] cd51                      and.w     d6,(a1)
[00011f50] 90ee 01c6                 suba.w    454(a6),a0
[00011f54] 92ee 01da                 suba.w    474(a6),a1
[00011f58] 51cd ffce                 dbf       d5,$00011F28
[00011f5c] 4e75                      rts
[00011f5e] 3c10                      move.w    (a0),d6
[00011f60] 4ed4                      jmp       (a4)
[00011f62] 4846                      swap      d6
[00011f64] 90ca                      suba.w    a2,a0
[00011f66] 3c10                      move.w    (a0),d6
[00011f68] 4846                      swap      d6
[00011f6a] 2e06                      move.l    d6,d7
[00011f6c] e0be                      ror.l     d0,d6
[00011f6e] cc43                      and.w     d3,d6
[00011f70] 4646                      not.w     d6
[00011f72] cd51                      and.w     d6,(a1)
[00011f74] 3801                      move.w    d1,d4
[00011f76] 6b16                      bmi.s     $00011F8E
[00011f78] 90ca                      suba.w    a2,a0
[00011f7a] 92cb                      suba.w    a3,a1
[00011f7c] 2c07                      move.l    d7,d6
[00011f7e] 3c10                      move.w    (a0),d6
[00011f80] 4846                      swap      d6
[00011f82] 2e06                      move.l    d6,d7
[00011f84] e0be                      ror.l     d0,d6
[00011f86] 4646                      not.w     d6
[00011f88] cd51                      and.w     d6,(a1)
[00011f8a] 51cc ffec                 dbf       d4,$00011F78
[00011f8e] 90ca                      suba.w    a2,a0
[00011f90] 92cb                      suba.w    a3,a1
[00011f92] 4ed5                      jmp       (a5)
[00011f94] 3e10                      move.w    (a0),d7
[00011f96] 4847                      swap      d7
[00011f98] e0bf                      ror.l     d0,d7
[00011f9a] ce42                      and.w     d2,d7
[00011f9c] 4647                      not.w     d7
[00011f9e] cf51                      and.w     d7,(a1)
[00011fa0] 90ee 01c6                 suba.w    454(a6),a0
[00011fa4] 92ee 01da                 suba.w    474(a6),a1
[00011fa8] 51cd ffb4                 dbf       d5,$00011F5E
[00011fac] 4e75                      rts
[00011fae] 3c10                      move.w    (a0),d6
[00011fb0] 4ed4                      jmp       (a4)
[00011fb2] 4846                      swap      d6
[00011fb4] 90ca                      suba.w    a2,a0
[00011fb6] 3c10                      move.w    (a0),d6
[00011fb8] 3e06                      move.w    d6,d7
[00011fba] e1be                      rol.l     d0,d6
[00011fbc] cc43                      and.w     d3,d6
[00011fbe] 4646                      not.w     d6
[00011fc0] cd51                      and.w     d6,(a1)
[00011fc2] 3801                      move.w    d1,d4
[00011fc4] 6b16                      bmi.s     $00011FDC
[00011fc6] 90ca                      suba.w    a2,a0
[00011fc8] 92cb                      suba.w    a3,a1
[00011fca] 3c07                      move.w    d7,d6
[00011fcc] 4846                      swap      d6
[00011fce] 3c10                      move.w    (a0),d6
[00011fd0] 3e06                      move.w    d6,d7
[00011fd2] e1be                      rol.l     d0,d6
[00011fd4] 4646                      not.w     d6
[00011fd6] cd51                      and.w     d6,(a1)
[00011fd8] 51cc ffec                 dbf       d4,$00011FC6
[00011fdc] 90ca                      suba.w    a2,a0
[00011fde] 92cb                      suba.w    a3,a1
[00011fe0] 4847                      swap      d7
[00011fe2] 4ed5                      jmp       (a5)
[00011fe4] 3e10                      move.w    (a0),d7
[00011fe6] e1bf                      rol.l     d0,d7
[00011fe8] ce42                      and.w     d2,d7
[00011fea] 4647                      not.w     d7
[00011fec] cf51                      and.w     d7,(a1)
[00011fee] 90ee 01c6                 suba.w    454(a6),a0
[00011ff2] 92ee 01da                 suba.w    474(a6),a1
[00011ff6] 51cd ffb6                 dbf       d5,$00011FAE
[00011ffa] 4e75                      rts
[00011ffc] 4e75                      rts
[00011ffe] 3c10                      move.w    (a0),d6
[00012000] cc43                      and.w     d3,d6
[00012002] bd51                      eor.w     d6,(a1)
[00012004] 3801                      move.w    d1,d4
[00012006] 6b0c                      bmi.s     $00012014
[00012008] 90ca                      suba.w    a2,a0
[0001200a] 92cb                      suba.w    a3,a1
[0001200c] 3c10                      move.w    (a0),d6
[0001200e] bd51                      eor.w     d6,(a1)
[00012010] 51cc fff6                 dbf       d4,$00012008
[00012014] 90ca                      suba.w    a2,a0
[00012016] 92cb                      suba.w    a3,a1
[00012018] 4ed5                      jmp       (a5)
[0001201a] 3c10                      move.w    (a0),d6
[0001201c] cc42                      and.w     d2,d6
[0001201e] bd51                      eor.w     d6,(a1)
[00012020] 90ee 01c6                 suba.w    454(a6),a0
[00012024] 92ee 01da                 suba.w    474(a6),a1
[00012028] 51cd ffd4                 dbf       d5,$00011FFE
[0001202c] 4e75                      rts
[0001202e] 3c10                      move.w    (a0),d6
[00012030] 4ed4                      jmp       (a4)
[00012032] 4846                      swap      d6
[00012034] 90ca                      suba.w    a2,a0
[00012036] 3c10                      move.w    (a0),d6
[00012038] 4846                      swap      d6
[0001203a] 2e06                      move.l    d6,d7
[0001203c] e0be                      ror.l     d0,d6
[0001203e] cc43                      and.w     d3,d6
[00012040] bd51                      eor.w     d6,(a1)
[00012042] 3801                      move.w    d1,d4
[00012044] 6b14                      bmi.s     $0001205A
[00012046] 90ca                      suba.w    a2,a0
[00012048] 92cb                      suba.w    a3,a1
[0001204a] 2c07                      move.l    d7,d6
[0001204c] 3c10                      move.w    (a0),d6
[0001204e] 4846                      swap      d6
[00012050] 2e06                      move.l    d6,d7
[00012052] e0be                      ror.l     d0,d6
[00012054] bd51                      eor.w     d6,(a1)
[00012056] 51cc ffee                 dbf       d4,$00012046
[0001205a] 90ca                      suba.w    a2,a0
[0001205c] 92cb                      suba.w    a3,a1
[0001205e] 4ed5                      jmp       (a5)
[00012060] 3e10                      move.w    (a0),d7
[00012062] 4847                      swap      d7
[00012064] e0bf                      ror.l     d0,d7
[00012066] ce42                      and.w     d2,d7
[00012068] bf51                      eor.w     d7,(a1)
[0001206a] 90ee 01c6                 suba.w    454(a6),a0
[0001206e] 92ee 01da                 suba.w    474(a6),a1
[00012072] 51cd ffba                 dbf       d5,$0001202E
[00012076] 4e75                      rts
[00012078] 3c10                      move.w    (a0),d6
[0001207a] 4ed4                      jmp       (a4)
[0001207c] 4846                      swap      d6
[0001207e] 90ca                      suba.w    a2,a0
[00012080] 3c10                      move.w    (a0),d6
[00012082] 3e06                      move.w    d6,d7
[00012084] e1be                      rol.l     d0,d6
[00012086] cc43                      and.w     d3,d6
[00012088] bd51                      eor.w     d6,(a1)
[0001208a] 3801                      move.w    d1,d4
[0001208c] 6b14                      bmi.s     $000120A2
[0001208e] 90ca                      suba.w    a2,a0
[00012090] 92cb                      suba.w    a3,a1
[00012092] 3c07                      move.w    d7,d6
[00012094] 4846                      swap      d6
[00012096] 3c10                      move.w    (a0),d6
[00012098] 3e06                      move.w    d6,d7
[0001209a] e1be                      rol.l     d0,d6
[0001209c] bd51                      eor.w     d6,(a1)
[0001209e] 51cc ffee                 dbf       d4,$0001208E
[000120a2] 90ca                      suba.w    a2,a0
[000120a4] 92cb                      suba.w    a3,a1
[000120a6] 4847                      swap      d7
[000120a8] 4ed5                      jmp       (a5)
[000120aa] 3e10                      move.w    (a0),d7
[000120ac] e1bf                      rol.l     d0,d7
[000120ae] ce42                      and.w     d2,d7
[000120b0] bf51                      eor.w     d7,(a1)
[000120b2] 90ee 01c6                 suba.w    454(a6),a0
[000120b6] 92ee 01da                 suba.w    474(a6),a1
[000120ba] 51cd ffbc                 dbf       d5,$00012078
[000120be] 4e75                      rts
[000120c0] 3c10                      move.w    (a0),d6
[000120c2] cc43                      and.w     d3,d6
[000120c4] 8d51                      or.w      d6,(a1)
[000120c6] 3801                      move.w    d1,d4
[000120c8] 6b0c                      bmi.s     $000120D6
[000120ca] 90ca                      suba.w    a2,a0
[000120cc] 92cb                      suba.w    a3,a1
[000120ce] 3c10                      move.w    (a0),d6
[000120d0] 8d51                      or.w      d6,(a1)
[000120d2] 51cc fff6                 dbf       d4,$000120CA
[000120d6] 90ca                      suba.w    a2,a0
[000120d8] 92cb                      suba.w    a3,a1
[000120da] 4ed5                      jmp       (a5)
[000120dc] 3c10                      move.w    (a0),d6
[000120de] cc42                      and.w     d2,d6
[000120e0] 8d51                      or.w      d6,(a1)
[000120e2] 90ee 01c6                 suba.w    454(a6),a0
[000120e6] 92ee 01da                 suba.w    474(a6),a1
[000120ea] 51cd ffd4                 dbf       d5,$000120C0
[000120ee] 4e75                      rts
[000120f0] 3c10                      move.w    (a0),d6
[000120f2] 4ed4                      jmp       (a4)
[000120f4] 4846                      swap      d6
[000120f6] 90ca                      suba.w    a2,a0
[000120f8] 3c10                      move.w    (a0),d6
[000120fa] 4846                      swap      d6
[000120fc] 2e06                      move.l    d6,d7
[000120fe] e0be                      ror.l     d0,d6
[00012100] cc43                      and.w     d3,d6
[00012102] 8d51                      or.w      d6,(a1)
[00012104] 3801                      move.w    d1,d4
[00012106] 6b14                      bmi.s     $0001211C
[00012108] 90ca                      suba.w    a2,a0
[0001210a] 92cb                      suba.w    a3,a1
[0001210c] 2c07                      move.l    d7,d6
[0001210e] 3c10                      move.w    (a0),d6
[00012110] 4846                      swap      d6
[00012112] 2e06                      move.l    d6,d7
[00012114] e0be                      ror.l     d0,d6
[00012116] 8d51                      or.w      d6,(a1)
[00012118] 51cc ffee                 dbf       d4,$00012108
[0001211c] 90ca                      suba.w    a2,a0
[0001211e] 92cb                      suba.w    a3,a1
[00012120] 4ed5                      jmp       (a5)
[00012122] 3e10                      move.w    (a0),d7
[00012124] 4847                      swap      d7
[00012126] e0bf                      ror.l     d0,d7
[00012128] ce42                      and.w     d2,d7
[0001212a] 8f51                      or.w      d7,(a1)
[0001212c] 90ee 01c6                 suba.w    454(a6),a0
[00012130] 92ee 01da                 suba.w    474(a6),a1
[00012134] 51cd ffba                 dbf       d5,$000120F0
[00012138] 4e75                      rts
[0001213a] 3c10                      move.w    (a0),d6
[0001213c] 4ed4                      jmp       (a4)
[0001213e] 4846                      swap      d6
[00012140] 90ca                      suba.w    a2,a0
[00012142] 3c10                      move.w    (a0),d6
[00012144] 3e06                      move.w    d6,d7
[00012146] e1be                      rol.l     d0,d6
[00012148] cc43                      and.w     d3,d6
[0001214a] 8d51                      or.w      d6,(a1)
[0001214c] 3801                      move.w    d1,d4
[0001214e] 6b14                      bmi.s     $00012164
[00012150] 90ca                      suba.w    a2,a0
[00012152] 92cb                      suba.w    a3,a1
[00012154] 3c07                      move.w    d7,d6
[00012156] 4846                      swap      d6
[00012158] 3c10                      move.w    (a0),d6
[0001215a] 3e06                      move.w    d6,d7
[0001215c] e1be                      rol.l     d0,d6
[0001215e] 8d51                      or.w      d6,(a1)
[00012160] 51cc ffee                 dbf       d4,$00012150
[00012164] 90ca                      suba.w    a2,a0
[00012166] 92cb                      suba.w    a3,a1
[00012168] 4847                      swap      d7
[0001216a] 4ed5                      jmp       (a5)
[0001216c] 3e10                      move.w    (a0),d7
[0001216e] e1bf                      rol.l     d0,d7
[00012170] ce42                      and.w     d2,d7
[00012172] 8f51                      or.w      d7,(a1)
[00012174] 90ee 01c6                 suba.w    454(a6),a0
[00012178] 92ee 01da                 suba.w    474(a6),a1
[0001217c] 51cd ffbc                 dbf       d5,$0001213A
[00012180] 4e75                      rts
[00012182] 3c10                      move.w    (a0),d6
[00012184] cc43                      and.w     d3,d6
[00012186] 8d51                      or.w      d6,(a1)
[00012188] b751                      eor.w     d3,(a1)
[0001218a] 3801                      move.w    d1,d4
[0001218c] 6b0e                      bmi.s     $0001219C
[0001218e] 90ca                      suba.w    a2,a0
[00012190] 92cb                      suba.w    a3,a1
[00012192] 3c10                      move.w    (a0),d6
[00012194] 8d51                      or.w      d6,(a1)
[00012196] 4651                      not.w     (a1)
[00012198] 51cc fff4                 dbf       d4,$0001218E
[0001219c] 90ca                      suba.w    a2,a0
[0001219e] 92cb                      suba.w    a3,a1
[000121a0] 4ed5                      jmp       (a5)
[000121a2] 3c10                      move.w    (a0),d6
[000121a4] cc42                      and.w     d2,d6
[000121a6] 8d51                      or.w      d6,(a1)
[000121a8] b551                      eor.w     d2,(a1)
[000121aa] 90ee 01c6                 suba.w    454(a6),a0
[000121ae] 92ee 01da                 suba.w    474(a6),a1
[000121b2] 51cd ffce                 dbf       d5,$00012182
[000121b6] 4e75                      rts
[000121b8] 3c10                      move.w    (a0),d6
[000121ba] 4ed4                      jmp       (a4)
[000121bc] 4846                      swap      d6
[000121be] 90ca                      suba.w    a2,a0
[000121c0] 3c10                      move.w    (a0),d6
[000121c2] 4846                      swap      d6
[000121c4] 2e06                      move.l    d6,d7
[000121c6] e0be                      ror.l     d0,d6
[000121c8] cc43                      and.w     d3,d6
[000121ca] 8d51                      or.w      d6,(a1)
[000121cc] b751                      eor.w     d3,(a1)
[000121ce] 3801                      move.w    d1,d4
[000121d0] 6b16                      bmi.s     $000121E8
[000121d2] 90ca                      suba.w    a2,a0
[000121d4] 92cb                      suba.w    a3,a1
[000121d6] 2c07                      move.l    d7,d6
[000121d8] 3c10                      move.w    (a0),d6
[000121da] 4846                      swap      d6
[000121dc] 2e06                      move.l    d6,d7
[000121de] e0be                      ror.l     d0,d6
[000121e0] 8d51                      or.w      d6,(a1)
[000121e2] 4651                      not.w     (a1)
[000121e4] 51cc ffec                 dbf       d4,$000121D2
[000121e8] 90ca                      suba.w    a2,a0
[000121ea] 92cb                      suba.w    a3,a1
[000121ec] 4ed5                      jmp       (a5)
[000121ee] 3e10                      move.w    (a0),d7
[000121f0] 4847                      swap      d7
[000121f2] e0bf                      ror.l     d0,d7
[000121f4] ce42                      and.w     d2,d7
[000121f6] 8f51                      or.w      d7,(a1)
[000121f8] b551                      eor.w     d2,(a1)
[000121fa] 90ee 01c6                 suba.w    454(a6),a0
[000121fe] 92ee 01da                 suba.w    474(a6),a1
[00012202] 51cd ffb4                 dbf       d5,$000121B8
[00012206] 4e75                      rts
[00012208] 3c10                      move.w    (a0),d6
[0001220a] 4ed4                      jmp       (a4)
[0001220c] 4846                      swap      d6
[0001220e] 90ca                      suba.w    a2,a0
[00012210] 3c10                      move.w    (a0),d6
[00012212] 3e06                      move.w    d6,d7
[00012214] e1be                      rol.l     d0,d6
[00012216] cc43                      and.w     d3,d6
[00012218] 8d51                      or.w      d6,(a1)
[0001221a] b751                      eor.w     d3,(a1)
[0001221c] 3801                      move.w    d1,d4
[0001221e] 6b16                      bmi.s     $00012236
[00012220] 90ca                      suba.w    a2,a0
[00012222] 92cb                      suba.w    a3,a1
[00012224] 3c07                      move.w    d7,d6
[00012226] 4846                      swap      d6
[00012228] 3c10                      move.w    (a0),d6
[0001222a] 3e06                      move.w    d6,d7
[0001222c] e1be                      rol.l     d0,d6
[0001222e] 8d51                      or.w      d6,(a1)
[00012230] 4651                      not.w     (a1)
[00012232] 51cc ffec                 dbf       d4,$00012220
[00012236] 90ca                      suba.w    a2,a0
[00012238] 92cb                      suba.w    a3,a1
[0001223a] 4847                      swap      d7
[0001223c] 4ed5                      jmp       (a5)
[0001223e] 3e10                      move.w    (a0),d7
[00012240] e1bf                      rol.l     d0,d7
[00012242] ce42                      and.w     d2,d7
[00012244] 8f51                      or.w      d7,(a1)
[00012246] b551                      eor.w     d2,(a1)
[00012248] 90ee 01c6                 suba.w    454(a6),a0
[0001224c] 92ee 01da                 suba.w    474(a6),a1
[00012250] 51cd ffb6                 dbf       d5,$00012208
[00012254] 4e75                      rts
[00012256] 3c10                      move.w    (a0),d6
[00012258] 4646                      not.w     d6
[0001225a] cc43                      and.w     d3,d6
[0001225c] bd51                      eor.w     d6,(a1)
[0001225e] 3801                      move.w    d1,d4
[00012260] 6b0e                      bmi.s     $00012270
[00012262] 90ca                      suba.w    a2,a0
[00012264] 92cb                      suba.w    a3,a1
[00012266] 3c10                      move.w    (a0),d6
[00012268] 4646                      not.w     d6
[0001226a] bd51                      eor.w     d6,(a1)
[0001226c] 51cc fff4                 dbf       d4,$00012262
[00012270] 90ca                      suba.w    a2,a0
[00012272] 92cb                      suba.w    a3,a1
[00012274] 4ed5                      jmp       (a5)
[00012276] 3c10                      move.w    (a0),d6
[00012278] 4646                      not.w     d6
[0001227a] cc42                      and.w     d2,d6
[0001227c] bd51                      eor.w     d6,(a1)
[0001227e] 90ee 01c6                 suba.w    454(a6),a0
[00012282] 92ee 01da                 suba.w    474(a6),a1
[00012286] 51cd ffce                 dbf       d5,$00012256
[0001228a] 4e75                      rts
[0001228c] 3c10                      move.w    (a0),d6
[0001228e] 4ed4                      jmp       (a4)
[00012290] 4846                      swap      d6
[00012292] 90ca                      suba.w    a2,a0
[00012294] 3c10                      move.w    (a0),d6
[00012296] 4846                      swap      d6
[00012298] 2e06                      move.l    d6,d7
[0001229a] e0be                      ror.l     d0,d6
[0001229c] 4646                      not.w     d6
[0001229e] cc43                      and.w     d3,d6
[000122a0] bd51                      eor.w     d6,(a1)
[000122a2] 3801                      move.w    d1,d4
[000122a4] 6b16                      bmi.s     $000122BC
[000122a6] 90ca                      suba.w    a2,a0
[000122a8] 92cb                      suba.w    a3,a1
[000122aa] 2c07                      move.l    d7,d6
[000122ac] 3c10                      move.w    (a0),d6
[000122ae] 4846                      swap      d6
[000122b0] 2e06                      move.l    d6,d7
[000122b2] e0be                      ror.l     d0,d6
[000122b4] 4646                      not.w     d6
[000122b6] bd51                      eor.w     d6,(a1)
[000122b8] 51cc ffec                 dbf       d4,$000122A6
[000122bc] 90ca                      suba.w    a2,a0
[000122be] 92cb                      suba.w    a3,a1
[000122c0] 4ed5                      jmp       (a5)
[000122c2] 3e10                      move.w    (a0),d7
[000122c4] 4847                      swap      d7
[000122c6] e0bf                      ror.l     d0,d7
[000122c8] 4647                      not.w     d7
[000122ca] ce42                      and.w     d2,d7
[000122cc] bf51                      eor.w     d7,(a1)
[000122ce] 90ee 01c6                 suba.w    454(a6),a0
[000122d2] 92ee 01da                 suba.w    474(a6),a1
[000122d6] 51cd ffb4                 dbf       d5,$0001228C
[000122da] 4e75                      rts
[000122dc] 3c10                      move.w    (a0),d6
[000122de] 4ed4                      jmp       (a4)
[000122e0] 4846                      swap      d6
[000122e2] 90ca                      suba.w    a2,a0
[000122e4] 3c10                      move.w    (a0),d6
[000122e6] 3e06                      move.w    d6,d7
[000122e8] e1be                      rol.l     d0,d6
[000122ea] 4646                      not.w     d6
[000122ec] cc43                      and.w     d3,d6
[000122ee] bd51                      eor.w     d6,(a1)
[000122f0] 3801                      move.w    d1,d4
[000122f2] 6b16                      bmi.s     $0001230A
[000122f4] 90ca                      suba.w    a2,a0
[000122f6] 92cb                      suba.w    a3,a1
[000122f8] 3c07                      move.w    d7,d6
[000122fa] 4846                      swap      d6
[000122fc] 3c10                      move.w    (a0),d6
[000122fe] 3e06                      move.w    d6,d7
[00012300] e1be                      rol.l     d0,d6
[00012302] 4646                      not.w     d6
[00012304] bd51                      eor.w     d6,(a1)
[00012306] 51cc ffec                 dbf       d4,$000122F4
[0001230a] 90ca                      suba.w    a2,a0
[0001230c] 92cb                      suba.w    a3,a1
[0001230e] 4847                      swap      d7
[00012310] 4ed5                      jmp       (a5)
[00012312] 3e10                      move.w    (a0),d7
[00012314] e1bf                      rol.l     d0,d7
[00012316] 4647                      not.w     d7
[00012318] ce42                      and.w     d2,d7
[0001231a] bf51                      eor.w     d7,(a1)
[0001231c] 90ee 01c6                 suba.w    454(a6),a0
[00012320] 92ee 01da                 suba.w    474(a6),a1
[00012324] 51cd ffb6                 dbf       d5,$000122DC
[00012328] 4e75                      rts
[0001232a] 3e2e 01da                 move.w    474(a6),d7
[0001232e] 4a42                      tst.w     d2
[00012330] 660c                      bne.s     $0001233E
[00012332] de4b                      add.w     a3,d7
[00012334] b751                      eor.w     d3,(a1)
[00012336] 92c7                      suba.w    d7,a1
[00012338] 51cd fffa                 dbf       d5,$00012334
[0001233c] 4e75                      rts
[0001233e] b751                      eor.w     d3,(a1)
[00012340] 92cb                      suba.w    a3,a1
[00012342] 3801                      move.w    d1,d4
[00012344] 6b08                      bmi.s     $0001234E
[00012346] 4651                      not.w     (a1)
[00012348] 92cb                      suba.w    a3,a1
[0001234a] 51cc fffa                 dbf       d4,$00012346
[0001234e] b551                      eor.w     d2,(a1)
[00012350] 92c7                      suba.w    d7,a1
[00012352] 51cd ffea                 dbf       d5,$0001233E
[00012356] 4e75                      rts
[00012358] 3c10                      move.w    (a0),d6
[0001235a] cc43                      and.w     d3,d6
[0001235c] b751                      eor.w     d3,(a1)
[0001235e] 8d51                      or.w      d6,(a1)
[00012360] 3801                      move.w    d1,d4
[00012362] 6b0e                      bmi.s     $00012372
[00012364] 90ca                      suba.w    a2,a0
[00012366] 92cb                      suba.w    a3,a1
[00012368] 3c10                      move.w    (a0),d6
[0001236a] 4651                      not.w     (a1)
[0001236c] 8d51                      or.w      d6,(a1)
[0001236e] 51cc fff4                 dbf       d4,$00012364
[00012372] 90ca                      suba.w    a2,a0
[00012374] 92cb                      suba.w    a3,a1
[00012376] 4ed5                      jmp       (a5)
[00012378] 3c10                      move.w    (a0),d6
[0001237a] cc42                      and.w     d2,d6
[0001237c] b551                      eor.w     d2,(a1)
[0001237e] 8d51                      or.w      d6,(a1)
[00012380] 90ee 01c6                 suba.w    454(a6),a0
[00012384] 92ee 01da                 suba.w    474(a6),a1
[00012388] 51cd ffce                 dbf       d5,$00012358
[0001238c] 4e75                      rts
[0001238e] 3c10                      move.w    (a0),d6
[00012390] 4ed4                      jmp       (a4)
[00012392] 4846                      swap      d6
[00012394] 90ca                      suba.w    a2,a0
[00012396] 3c10                      move.w    (a0),d6
[00012398] 4846                      swap      d6
[0001239a] 2e06                      move.l    d6,d7
[0001239c] e0be                      ror.l     d0,d6
[0001239e] cc43                      and.w     d3,d6
[000123a0] b751                      eor.w     d3,(a1)
[000123a2] 8d51                      or.w      d6,(a1)
[000123a4] 3801                      move.w    d1,d4
[000123a6] 6b16                      bmi.s     $000123BE
[000123a8] 90ca                      suba.w    a2,a0
[000123aa] 92cb                      suba.w    a3,a1
[000123ac] 2c07                      move.l    d7,d6
[000123ae] 3c10                      move.w    (a0),d6
[000123b0] 4846                      swap      d6
[000123b2] 2e06                      move.l    d6,d7
[000123b4] e0be                      ror.l     d0,d6
[000123b6] 4651                      not.w     (a1)
[000123b8] 8d51                      or.w      d6,(a1)
[000123ba] 51cc ffec                 dbf       d4,$000123A8
[000123be] 90ca                      suba.w    a2,a0
[000123c0] 92cb                      suba.w    a3,a1
[000123c2] 4ed5                      jmp       (a5)
[000123c4] 3e10                      move.w    (a0),d7
[000123c6] 4847                      swap      d7
[000123c8] e0bf                      ror.l     d0,d7
[000123ca] ce42                      and.w     d2,d7
[000123cc] b551                      eor.w     d2,(a1)
[000123ce] 8f51                      or.w      d7,(a1)
[000123d0] 90ee 01c6                 suba.w    454(a6),a0
[000123d4] 92ee 01da                 suba.w    474(a6),a1
[000123d8] 51cd ffb4                 dbf       d5,$0001238E
[000123dc] 4e75                      rts
[000123de] 3c10                      move.w    (a0),d6
[000123e0] 4ed4                      jmp       (a4)
[000123e2] 4846                      swap      d6
[000123e4] 90ca                      suba.w    a2,a0
[000123e6] 3c10                      move.w    (a0),d6
[000123e8] 3e06                      move.w    d6,d7
[000123ea] e1be                      rol.l     d0,d6
[000123ec] cc43                      and.w     d3,d6
[000123ee] b751                      eor.w     d3,(a1)
[000123f0] 8d51                      or.w      d6,(a1)
[000123f2] 3801                      move.w    d1,d4
[000123f4] 6b16                      bmi.s     $0001240C
[000123f6] 90ca                      suba.w    a2,a0
[000123f8] 92cb                      suba.w    a3,a1
[000123fa] 3c07                      move.w    d7,d6
[000123fc] 4846                      swap      d6
[000123fe] 3c10                      move.w    (a0),d6
[00012400] 3e06                      move.w    d6,d7
[00012402] e1be                      rol.l     d0,d6
[00012404] 4651                      not.w     (a1)
[00012406] 8d51                      or.w      d6,(a1)
[00012408] 51cc ffec                 dbf       d4,$000123F6
[0001240c] 90ca                      suba.w    a2,a0
[0001240e] 92cb                      suba.w    a3,a1
[00012410] 4847                      swap      d7
[00012412] 4ed5                      jmp       (a5)
[00012414] 3e10                      move.w    (a0),d7
[00012416] e1bf                      rol.l     d0,d7
[00012418] ce42                      and.w     d2,d7
[0001241a] b551                      eor.w     d2,(a1)
[0001241c] 8f51                      or.w      d7,(a1)
[0001241e] 90ee 01c6                 suba.w    454(a6),a0
[00012422] 92ee 01da                 suba.w    474(a6),a1
[00012426] 51cd ffb6                 dbf       d5,$000123DE
[0001242a] 4e75                      rts
[0001242c] 3c10                      move.w    (a0),d6
[0001242e] 4646                      not.w     d6
[00012430] cc43                      and.w     d3,d6
[00012432] 4643                      not.w     d3
[00012434] c751                      and.w     d3,(a1)
[00012436] 4643                      not.w     d3
[00012438] 8d51                      or.w      d6,(a1)
[0001243a] 3801                      move.w    d1,d4
[0001243c] 6b0e                      bmi.s     $0001244C
[0001243e] 90ca                      suba.w    a2,a0
[00012440] 92cb                      suba.w    a3,a1
[00012442] 3c10                      move.w    (a0),d6
[00012444] 4646                      not.w     d6
[00012446] 3286                      move.w    d6,(a1)
[00012448] 51cc fff4                 dbf       d4,$0001243E
[0001244c] 90ca                      suba.w    a2,a0
[0001244e] 92cb                      suba.w    a3,a1
[00012450] 4ed5                      jmp       (a5)
[00012452] 3c10                      move.w    (a0),d6
[00012454] 4646                      not.w     d6
[00012456] cc42                      and.w     d2,d6
[00012458] 4642                      not.w     d2
[0001245a] c551                      and.w     d2,(a1)
[0001245c] 4642                      not.w     d2
[0001245e] 8d51                      or.w      d6,(a1)
[00012460] 90ee 01c6                 suba.w    454(a6),a0
[00012464] 92ee 01da                 suba.w    474(a6),a1
[00012468] 51cd ffc2                 dbf       d5,$0001242C
[0001246c] 4e75                      rts
[0001246e] 3c10                      move.w    (a0),d6
[00012470] 4ed4                      jmp       (a4)
[00012472] 4846                      swap      d6
[00012474] 90ca                      suba.w    a2,a0
[00012476] 3c10                      move.w    (a0),d6
[00012478] 4846                      swap      d6
[0001247a] 2e06                      move.l    d6,d7
[0001247c] e0be                      ror.l     d0,d6
[0001247e] 4646                      not.w     d6
[00012480] cc43                      and.w     d3,d6
[00012482] 4643                      not.w     d3
[00012484] c751                      and.w     d3,(a1)
[00012486] 4643                      not.w     d3
[00012488] 8d51                      or.w      d6,(a1)
[0001248a] 3801                      move.w    d1,d4
[0001248c] 6b16                      bmi.s     $000124A4
[0001248e] 90ca                      suba.w    a2,a0
[00012490] 92cb                      suba.w    a3,a1
[00012492] 2c07                      move.l    d7,d6
[00012494] 3c10                      move.w    (a0),d6
[00012496] 4846                      swap      d6
[00012498] 2e06                      move.l    d6,d7
[0001249a] e0be                      ror.l     d0,d6
[0001249c] 4646                      not.w     d6
[0001249e] 3286                      move.w    d6,(a1)
[000124a0] 51cc ffec                 dbf       d4,$0001248E
[000124a4] 90ca                      suba.w    a2,a0
[000124a6] 92cb                      suba.w    a3,a1
[000124a8] 4ed5                      jmp       (a5)
[000124aa] 3e10                      move.w    (a0),d7
[000124ac] 4847                      swap      d7
[000124ae] e0bf                      ror.l     d0,d7
[000124b0] 4647                      not.w     d7
[000124b2] ce42                      and.w     d2,d7
[000124b4] 4642                      not.w     d2
[000124b6] c551                      and.w     d2,(a1)
[000124b8] 4642                      not.w     d2
[000124ba] 8f51                      or.w      d7,(a1)
[000124bc] 90ee 01c6                 suba.w    454(a6),a0
[000124c0] 92ee 01da                 suba.w    474(a6),a1
[000124c4] 51cd ffa8                 dbf       d5,$0001246E
[000124c8] 4e75                      rts
[000124ca] 3c10                      move.w    (a0),d6
[000124cc] 4ed4                      jmp       (a4)
[000124ce] 4846                      swap      d6
[000124d0] 90ca                      suba.w    a2,a0
[000124d2] 3c10                      move.w    (a0),d6
[000124d4] 3e06                      move.w    d6,d7
[000124d6] e1be                      rol.l     d0,d6
[000124d8] 4646                      not.w     d6
[000124da] cc43                      and.w     d3,d6
[000124dc] 4643                      not.w     d3
[000124de] c751                      and.w     d3,(a1)
[000124e0] 4643                      not.w     d3
[000124e2] 8d51                      or.w      d6,(a1)
[000124e4] 3801                      move.w    d1,d4
[000124e6] 6b16                      bmi.s     $000124FE
[000124e8] 90ca                      suba.w    a2,a0
[000124ea] 92cb                      suba.w    a3,a1
[000124ec] 3c07                      move.w    d7,d6
[000124ee] 4846                      swap      d6
[000124f0] 3c10                      move.w    (a0),d6
[000124f2] 3e06                      move.w    d6,d7
[000124f4] e1be                      rol.l     d0,d6
[000124f6] 4646                      not.w     d6
[000124f8] 3286                      move.w    d6,(a1)
[000124fa] 51cc ffec                 dbf       d4,$000124E8
[000124fe] 90ca                      suba.w    a2,a0
[00012500] 92cb                      suba.w    a3,a1
[00012502] 4847                      swap      d7
[00012504] 4ed5                      jmp       (a5)
[00012506] 3e10                      move.w    (a0),d7
[00012508] e1bf                      rol.l     d0,d7
[0001250a] 4647                      not.w     d7
[0001250c] ce42                      and.w     d2,d7
[0001250e] 4642                      not.w     d2
[00012510] c551                      and.w     d2,(a1)
[00012512] 4642                      not.w     d2
[00012514] 8f51                      or.w      d7,(a1)
[00012516] 90ee 01c6                 suba.w    454(a6),a0
[0001251a] 92ee 01da                 suba.w    474(a6),a1
[0001251e] 51cd ffaa                 dbf       d5,$000124CA
[00012522] 4e75                      rts
[00012524] 3c10                      move.w    (a0),d6
[00012526] 4646                      not.w     d6
[00012528] cc43                      and.w     d3,d6
[0001252a] 8d51                      or.w      d6,(a1)
[0001252c] 3801                      move.w    d1,d4
[0001252e] 6b0e                      bmi.s     $0001253E
[00012530] 90ca                      suba.w    a2,a0
[00012532] 92cb                      suba.w    a3,a1
[00012534] 3c10                      move.w    (a0),d6
[00012536] 4646                      not.w     d6
[00012538] 8d51                      or.w      d6,(a1)
[0001253a] 51cc fff4                 dbf       d4,$00012530
[0001253e] 90ca                      suba.w    a2,a0
[00012540] 92cb                      suba.w    a3,a1
[00012542] 4ed5                      jmp       (a5)
[00012544] 3c10                      move.w    (a0),d6
[00012546] 4646                      not.w     d6
[00012548] cc42                      and.w     d2,d6
[0001254a] 8d51                      or.w      d6,(a1)
[0001254c] 90ee 01c6                 suba.w    454(a6),a0
[00012550] 92ee 01da                 suba.w    474(a6),a1
[00012554] 51cd ffce                 dbf       d5,$00012524
[00012558] 4e75                      rts
[0001255a] 3c10                      move.w    (a0),d6
[0001255c] 4ed4                      jmp       (a4)
[0001255e] 4846                      swap      d6
[00012560] 90ca                      suba.w    a2,a0
[00012562] 3c10                      move.w    (a0),d6
[00012564] 4846                      swap      d6
[00012566] 2e06                      move.l    d6,d7
[00012568] e0be                      ror.l     d0,d6
[0001256a] 4646                      not.w     d6
[0001256c] cc43                      and.w     d3,d6
[0001256e] 8d51                      or.w      d6,(a1)
[00012570] 3801                      move.w    d1,d4
[00012572] 6b16                      bmi.s     $0001258A
[00012574] 90ca                      suba.w    a2,a0
[00012576] 92cb                      suba.w    a3,a1
[00012578] 2c07                      move.l    d7,d6
[0001257a] 3c10                      move.w    (a0),d6
[0001257c] 4846                      swap      d6
[0001257e] 2e06                      move.l    d6,d7
[00012580] e0be                      ror.l     d0,d6
[00012582] 4646                      not.w     d6
[00012584] 8d51                      or.w      d6,(a1)
[00012586] 51cc ffec                 dbf       d4,$00012574
[0001258a] 90ca                      suba.w    a2,a0
[0001258c] 92cb                      suba.w    a3,a1
[0001258e] 4ed5                      jmp       (a5)
[00012590] 3e10                      move.w    (a0),d7
[00012592] 4847                      swap      d7
[00012594] e0bf                      ror.l     d0,d7
[00012596] 4647                      not.w     d7
[00012598] ce42                      and.w     d2,d7
[0001259a] 8f51                      or.w      d7,(a1)
[0001259c] 90ee 01c6                 suba.w    454(a6),a0
[000125a0] 92ee 01da                 suba.w    474(a6),a1
[000125a4] 51cd ffb4                 dbf       d5,$0001255A
[000125a8] 4e75                      rts
[000125aa] 3c10                      move.w    (a0),d6
[000125ac] 4ed4                      jmp       (a4)
[000125ae] 4846                      swap      d6
[000125b0] 90ca                      suba.w    a2,a0
[000125b2] 3c10                      move.w    (a0),d6
[000125b4] 3e06                      move.w    d6,d7
[000125b6] e1be                      rol.l     d0,d6
[000125b8] 4646                      not.w     d6
[000125ba] cc43                      and.w     d3,d6
[000125bc] 8d51                      or.w      d6,(a1)
[000125be] 3801                      move.w    d1,d4
[000125c0] 6b16                      bmi.s     $000125D8
[000125c2] 90ca                      suba.w    a2,a0
[000125c4] 92cb                      suba.w    a3,a1
[000125c6] 3c07                      move.w    d7,d6
[000125c8] 4846                      swap      d6
[000125ca] 3c10                      move.w    (a0),d6
[000125cc] 3e06                      move.w    d6,d7
[000125ce] e1be                      rol.l     d0,d6
[000125d0] 4646                      not.w     d6
[000125d2] 8d51                      or.w      d6,(a1)
[000125d4] 51cc ffec                 dbf       d4,$000125C2
[000125d8] 90ca                      suba.w    a2,a0
[000125da] 92cb                      suba.w    a3,a1
[000125dc] 4847                      swap      d7
[000125de] 4ed5                      jmp       (a5)
[000125e0] 3e10                      move.w    (a0),d7
[000125e2] e1bf                      rol.l     d0,d7
[000125e4] 4647                      not.w     d7
[000125e6] ce42                      and.w     d2,d7
[000125e8] 8f51                      or.w      d7,(a1)
[000125ea] 90ee 01c6                 suba.w    454(a6),a0
[000125ee] 92ee 01da                 suba.w    474(a6),a1
[000125f2] 51cd ffb6                 dbf       d5,$000125AA
[000125f6] 4e75                      rts
[000125f8] 3c10                      move.w    (a0),d6
[000125fa] 8c43                      or.w      d3,d6
[000125fc] cd51                      and.w     d6,(a1)
[000125fe] b751                      eor.w     d3,(a1)
[00012600] 3801                      move.w    d1,d4
[00012602] 6b0e                      bmi.s     $00012612
[00012604] 90ca                      suba.w    a2,a0
[00012606] 92cb                      suba.w    a3,a1
[00012608] 3c10                      move.w    (a0),d6
[0001260a] cd51                      and.w     d6,(a1)
[0001260c] 4651                      not.w     (a1)
[0001260e] 51cc fff4                 dbf       d4,$00012604
[00012612] 90ca                      suba.w    a2,a0
[00012614] 92cb                      suba.w    a3,a1
[00012616] 4ed5                      jmp       (a5)
[00012618] 3c10                      move.w    (a0),d6
[0001261a] 8c42                      or.w      d2,d6
[0001261c] cd51                      and.w     d6,(a1)
[0001261e] 8551                      or.w      d2,(a1)
[00012620] 90ee 01c6                 suba.w    454(a6),a0
[00012624] 92ee 01da                 suba.w    474(a6),a1
[00012628] 51cd ffce                 dbf       d5,$000125F8
[0001262c] 4e75                      rts
[0001262e] 3c10                      move.w    (a0),d6
[00012630] 4ed4                      jmp       (a4)
[00012632] 4846                      swap      d6
[00012634] 90ca                      suba.w    a2,a0
[00012636] 3c10                      move.w    (a0),d6
[00012638] 4846                      swap      d6
[0001263a] 2e06                      move.l    d6,d7
[0001263c] e0be                      ror.l     d0,d6
[0001263e] 8c43                      or.w      d3,d6
[00012640] cd51                      and.w     d6,(a1)
[00012642] b751                      eor.w     d3,(a1)
[00012644] 3801                      move.w    d1,d4
[00012646] 6b16                      bmi.s     $0001265E
[00012648] 90ca                      suba.w    a2,a0
[0001264a] 92cb                      suba.w    a3,a1
[0001264c] 2c07                      move.l    d7,d6
[0001264e] 3c10                      move.w    (a0),d6
[00012650] 4846                      swap      d6
[00012652] 2e06                      move.l    d6,d7
[00012654] e0be                      ror.l     d0,d6
[00012656] cd51                      and.w     d6,(a1)
[00012658] 4651                      not.w     (a1)
[0001265a] 51cc ffec                 dbf       d4,$00012648
[0001265e] 90ca                      suba.w    a2,a0
[00012660] 92cb                      suba.w    a3,a1
[00012662] 4ed5                      jmp       (a5)
[00012664] 3e10                      move.w    (a0),d7
[00012666] 4847                      swap      d7
[00012668] e0bf                      ror.l     d0,d7
[0001266a] 8e42                      or.w      d2,d7
[0001266c] cf51                      and.w     d7,(a1)
[0001266e] 8551                      or.w      d2,(a1)
[00012670] 90ee 01c6                 suba.w    454(a6),a0
[00012674] 92ee 01da                 suba.w    474(a6),a1
[00012678] 51cd ffb4                 dbf       d5,$0001262E
[0001267c] 4e75                      rts
[0001267e] 3c10                      move.w    (a0),d6
[00012680] 4ed4                      jmp       (a4)
[00012682] 4846                      swap      d6
[00012684] 90ca                      suba.w    a2,a0
[00012686] 3c10                      move.w    (a0),d6
[00012688] 3e06                      move.w    d6,d7
[0001268a] e1be                      rol.l     d0,d6
[0001268c] 8c43                      or.w      d3,d6
[0001268e] cd51                      and.w     d6,(a1)
[00012690] b751                      eor.w     d3,(a1)
[00012692] 3801                      move.w    d1,d4
[00012694] 6b16                      bmi.s     $000126AC
[00012696] 90ca                      suba.w    a2,a0
[00012698] 92cb                      suba.w    a3,a1
[0001269a] 3c07                      move.w    d7,d6
[0001269c] 4846                      swap      d6
[0001269e] 3c10                      move.w    (a0),d6
[000126a0] 3e06                      move.w    d6,d7
[000126a2] e1be                      rol.l     d0,d6
[000126a4] cd51                      and.w     d6,(a1)
[000126a6] 4651                      not.w     (a1)
[000126a8] 51cc ffec                 dbf       d4,$00012696
[000126ac] 90ca                      suba.w    a2,a0
[000126ae] 92cb                      suba.w    a3,a1
[000126b0] 4847                      swap      d7
[000126b2] 4ed5                      jmp       (a5)
[000126b4] 3e10                      move.w    (a0),d7
[000126b6] e1bf                      rol.l     d0,d7
[000126b8] 8e42                      or.w      d2,d7
[000126ba] cf51                      and.w     d7,(a1)
[000126bc] 8551                      or.w      d2,(a1)
[000126be] 90ee 01c6                 suba.w    454(a6),a0
[000126c2] 92ee 01da                 suba.w    474(a6),a1
[000126c6] 51cd ffb6                 dbf       d5,$0001267E
[000126ca] 4e75                      rts
[000126cc] 7cff                      moveq.l   #-1,d6
[000126ce] 3e2e 01da                 move.w    474(a6),d7
[000126d2] 4a42                      tst.w     d2
[000126d4] 660c                      bne.s     $000126E2
[000126d6] de4b                      add.w     a3,d7
[000126d8] 8751                      or.w      d3,(a1)
[000126da] 92c7                      suba.w    d7,a1
[000126dc] 51cd fffa                 dbf       d5,$000126D8
[000126e0] 4e75                      rts
[000126e2] 8751                      or.w      d3,(a1)
[000126e4] 92cb                      suba.w    a3,a1
[000126e6] 3801                      move.w    d1,d4
[000126e8] 6b08                      bmi.s     $000126F2
[000126ea] 3286                      move.w    d6,(a1)
[000126ec] 92cb                      suba.w    a3,a1
[000126ee] 51cc fffa                 dbf       d4,$000126EA
[000126f2] 8551                      or.w      d2,(a1)
[000126f4] 92c7                      suba.w    d7,a1
[000126f6] 51cd ffea                 dbf       d5,$000126E2
[000126fa] 4e75                      rts
[000126fc] 5088                      addq.l    #8,a0
[000126fe] 5089                      addq.l    #8,a1
[00012700] 5541                      subq.w    #2,d1
[00012702] 4a40                      tst.w     d0
[00012704] 6674                      bne.s     $0001277A
[00012706] 3c02                      move.w    d2,d6
[00012708] 4842                      swap      d2
[0001270a] 3406                      move.w    d6,d2
[0001270c] 3c03                      move.w    d3,d6
[0001270e] 4843                      swap      d3
[00012710] 3606                      move.w    d6,d3
[00012712] 514a                      subq.w    #8,a2
[00012714] 514b                      subq.w    #8,a3
[00012716] b27c fffe                 cmp.w     #$FFFE,d1
[0001271a] 673e                      beq.s     $0001275A
[0001271c] 2c20                      move.l    -(a0),d6
[0001271e] 4686                      not.l     d6
[00012720] cc83                      and.l     d3,d6
[00012722] 87a1                      or.l      d3,-(a1)
[00012724] bd91                      eor.l     d6,(a1)
[00012726] 2c20                      move.l    -(a0),d6
[00012728] 4686                      not.l     d6
[0001272a] cc83                      and.l     d3,d6
[0001272c] 87a1                      or.l      d3,-(a1)
[0001272e] bd91                      eor.l     d6,(a1)
[00012730] 3801                      move.w    d1,d4
[00012732] 6b08                      bmi.s     $0001273C
[00012734] 2320                      move.l    -(a0),-(a1)
[00012736] 2320                      move.l    -(a0),-(a1)
[00012738] 51cc fffa                 dbf       d4,$00012734
[0001273c] 2c20                      move.l    -(a0),d6
[0001273e] 4686                      not.l     d6
[00012740] cc82                      and.l     d2,d6
[00012742] 85a1                      or.l      d2,-(a1)
[00012744] bd91                      eor.l     d6,(a1)
[00012746] 2c20                      move.l    -(a0),d6
[00012748] 4686                      not.l     d6
[0001274a] cc82                      and.l     d2,d6
[0001274c] 85a1                      or.l      d2,-(a1)
[0001274e] bd91                      eor.l     d6,(a1)
[00012750] 90ca                      suba.w    a2,a0
[00012752] 92cb                      suba.w    a3,a1
[00012754] 51cd ffc6                 dbf       d5,$0001271C
[00012758] 4e75                      rts
[0001275a] c483                      and.l     d3,d2
[0001275c] 2c20                      move.l    -(a0),d6
[0001275e] 4686                      not.l     d6
[00012760] cc82                      and.l     d2,d6
[00012762] 85a1                      or.l      d2,-(a1)
[00012764] bd91                      eor.l     d6,(a1)
[00012766] 2c20                      move.l    -(a0),d6
[00012768] 4686                      not.l     d6
[0001276a] cc82                      and.l     d2,d6
[0001276c] 85a1                      or.l      d2,-(a1)
[0001276e] bd91                      eor.l     d6,(a1)
[00012770] 90ca                      suba.w    a2,a0
[00012772] 92cb                      suba.w    a3,a1
[00012774] 51cd ffe6                 dbf       d5,$0001275C
[00012778] 4e75                      rts
[0001277a] 514b                      subq.w    #8,a3
[0001277c] b9fc 0001 1b50            cmpa.l    #$00011B50,a4
[00012782] 6600 017a                 bne       $000128FE
[00012786] 49fa 0028                 lea.l     $000127B0(pc),a4
[0001278a] bc7c 0004                 cmp.w     #$0004,d6
[0001278e] 6704                      beq.s     $00012794
[00012790] 49fa 006c                 lea.l     $000127FE(pc),a4
[00012794] b27c fffe                 cmp.w     #$FFFE,d1
[00012798] 6608                      bne.s     $000127A2
[0001279a] c642                      and.w     d2,d3
[0001279c] 4bfa 0114                 lea.l     $000128B2(pc),a5
[000127a0] 600c                      bra.s     $000127AE
[000127a2] 4bfa 00c6                 lea.l     $0001286A(pc),a5
[000127a6] 4a47                      tst.w     d7
[000127a8] 6704                      beq.s     $000127AE
[000127aa] 4bfa 0110                 lea.l     $000128BC(pc),a5
[000127ae] 4ed4                      jmp       (a4)
[000127b0] 3c20                      move.w    -(a0),d6
[000127b2] 4846                      swap      d6
[000127b4] 3c28 fff8                 move.w    -8(a0),d6
[000127b8] e1be                      rol.l     d0,d6
[000127ba] 4646                      not.w     d6
[000127bc] cc43                      and.w     d3,d6
[000127be] 8761                      or.w      d3,-(a1)
[000127c0] bd51                      eor.w     d6,(a1)
[000127c2] 3c20                      move.w    -(a0),d6
[000127c4] 4846                      swap      d6
[000127c6] 3c28 fff8                 move.w    -8(a0),d6
[000127ca] e1be                      rol.l     d0,d6
[000127cc] 4646                      not.w     d6
[000127ce] cc43                      and.w     d3,d6
[000127d0] 8761                      or.w      d3,-(a1)
[000127d2] bd51                      eor.w     d6,(a1)
[000127d4] 3c20                      move.w    -(a0),d6
[000127d6] 4846                      swap      d6
[000127d8] 3c28 fff8                 move.w    -8(a0),d6
[000127dc] e1be                      rol.l     d0,d6
[000127de] 4646                      not.w     d6
[000127e0] cc43                      and.w     d3,d6
[000127e2] 8761                      or.w      d3,-(a1)
[000127e4] bd51                      eor.w     d6,(a1)
[000127e6] 3c20                      move.w    -(a0),d6
[000127e8] 4846                      swap      d6
[000127ea] 3c28 fff8                 move.w    -8(a0),d6
[000127ee] e1be                      rol.l     d0,d6
[000127f0] 4646                      not.w     d6
[000127f2] cc43                      and.w     d3,d6
[000127f4] 8761                      or.w      d3,-(a1)
[000127f6] bd51                      eor.w     d6,(a1)
[000127f8] 3801                      move.w    d1,d4
[000127fa] 6a38                      bpl.s     $00012834
[000127fc] 6b6a                      bmi.s     $00012868
[000127fe] 3c20                      move.w    -(a0),d6
[00012800] e1be                      rol.l     d0,d6
[00012802] 4646                      not.w     d6
[00012804] cc43                      and.w     d3,d6
[00012806] 8761                      or.w      d3,-(a1)
[00012808] bd51                      eor.w     d6,(a1)
[0001280a] 3c20                      move.w    -(a0),d6
[0001280c] e1be                      rol.l     d0,d6
[0001280e] 4646                      not.w     d6
[00012810] cc43                      and.w     d3,d6
[00012812] 8761                      or.w      d3,-(a1)
[00012814] bd51                      eor.w     d6,(a1)
[00012816] 3c20                      move.w    -(a0),d6
[00012818] e1be                      rol.l     d0,d6
[0001281a] 4646                      not.w     d6
[0001281c] cc43                      and.w     d3,d6
[0001281e] 8761                      or.w      d3,-(a1)
[00012820] bd51                      eor.w     d6,(a1)
[00012822] 3c20                      move.w    -(a0),d6
[00012824] e1be                      rol.l     d0,d6
[00012826] 4646                      not.w     d6
[00012828] cc43                      and.w     d3,d6
[0001282a] 8761                      or.w      d3,-(a1)
[0001282c] bd51                      eor.w     d6,(a1)
[0001282e] 5088                      addq.l    #8,a0
[00012830] 3801                      move.w    d1,d4
[00012832] 6b34                      bmi.s     $00012868
[00012834] 3c20                      move.w    -(a0),d6
[00012836] 4846                      swap      d6
[00012838] 3c28 fff8                 move.w    -8(a0),d6
[0001283c] e1be                      rol.l     d0,d6
[0001283e] 3306                      move.w    d6,-(a1)
[00012840] 3c20                      move.w    -(a0),d6
[00012842] 4846                      swap      d6
[00012844] 3c28 fff8                 move.w    -8(a0),d6
[00012848] e1be                      rol.l     d0,d6
[0001284a] 3306                      move.w    d6,-(a1)
[0001284c] 3c20                      move.w    -(a0),d6
[0001284e] 4846                      swap      d6
[00012850] 3c28 fff8                 move.w    -8(a0),d6
[00012854] e1be                      rol.l     d0,d6
[00012856] 3306                      move.w    d6,-(a1)
[00012858] 3c20                      move.w    -(a0),d6
[0001285a] 4846                      swap      d6
[0001285c] 3c28 fff8                 move.w    -8(a0),d6
[00012860] e1be                      rol.l     d0,d6
[00012862] 3306                      move.w    d6,-(a1)
[00012864] 51cc ffce                 dbf       d4,$00012834
[00012868] 4ed5                      jmp       (a5)
[0001286a] 3c20                      move.w    -(a0),d6
[0001286c] 4846                      swap      d6
[0001286e] 3c28 fff8                 move.w    -8(a0),d6
[00012872] e1be                      rol.l     d0,d6
[00012874] 4646                      not.w     d6
[00012876] cc42                      and.w     d2,d6
[00012878] 8561                      or.w      d2,-(a1)
[0001287a] bd51                      eor.w     d6,(a1)
[0001287c] 3c20                      move.w    -(a0),d6
[0001287e] 4846                      swap      d6
[00012880] 3c28 fff8                 move.w    -8(a0),d6
[00012884] e1be                      rol.l     d0,d6
[00012886] 4646                      not.w     d6
[00012888] cc42                      and.w     d2,d6
[0001288a] 8561                      or.w      d2,-(a1)
[0001288c] bd51                      eor.w     d6,(a1)
[0001288e] 3c20                      move.w    -(a0),d6
[00012890] 4846                      swap      d6
[00012892] 3c28 fff8                 move.w    -8(a0),d6
[00012896] e1be                      rol.l     d0,d6
[00012898] 4646                      not.w     d6
[0001289a] cc42                      and.w     d2,d6
[0001289c] 8561                      or.w      d2,-(a1)
[0001289e] bd51                      eor.w     d6,(a1)
[000128a0] 3c20                      move.w    -(a0),d6
[000128a2] 4846                      swap      d6
[000128a4] 3c28 fff8                 move.w    -8(a0),d6
[000128a8] e1be                      rol.l     d0,d6
[000128aa] 4646                      not.w     d6
[000128ac] cc42                      and.w     d2,d6
[000128ae] 8561                      or.w      d2,-(a1)
[000128b0] bd51                      eor.w     d6,(a1)
[000128b2] 90ca                      suba.w    a2,a0
[000128b4] 92cb                      suba.w    a3,a1
[000128b6] 51cd fef6                 dbf       d5,$000127AE
[000128ba] 4e75                      rts
[000128bc] 3c20                      move.w    -(a0),d6
[000128be] 4846                      swap      d6
[000128c0] e1be                      rol.l     d0,d6
[000128c2] 4646                      not.w     d6
[000128c4] cc42                      and.w     d2,d6
[000128c6] 8561                      or.w      d2,-(a1)
[000128c8] bd51                      eor.w     d6,(a1)
[000128ca] 3c20                      move.w    -(a0),d6
[000128cc] 4846                      swap      d6
[000128ce] e1be                      rol.l     d0,d6
[000128d0] 4646                      not.w     d6
[000128d2] cc42                      and.w     d2,d6
[000128d4] 8561                      or.w      d2,-(a1)
[000128d6] bd51                      eor.w     d6,(a1)
[000128d8] 3c20                      move.w    -(a0),d6
[000128da] 4846                      swap      d6
[000128dc] e1be                      rol.l     d0,d6
[000128de] 4646                      not.w     d6
[000128e0] cc42                      and.w     d2,d6
[000128e2] 8561                      or.w      d2,-(a1)
[000128e4] bd51                      eor.w     d6,(a1)
[000128e6] 3c20                      move.w    -(a0),d6
[000128e8] 4846                      swap      d6
[000128ea] e1be                      rol.l     d0,d6
[000128ec] 4646                      not.w     d6
[000128ee] cc42                      and.w     d2,d6
[000128f0] 8561                      or.w      d2,-(a1)
[000128f2] bd51                      eor.w     d6,(a1)
[000128f4] 90ca                      suba.w    a2,a0
[000128f6] 92cb                      suba.w    a3,a1
[000128f8] 51cd feb4                 dbf       d5,$000127AE
[000128fc] 4e75                      rts
[000128fe] 49fa 0030                 lea.l     $00012930(pc),a4
[00012902] bc7c 0004                 cmp.w     #$0004,d6
[00012906] 6704                      beq.s     $0001290C
[00012908] 49fa 0074                 lea.l     $0001297E(pc),a4
[0001290c] b27c fffe                 cmp.w     #$FFFE,d1
[00012910] 6610                      bne.s     $00012922
[00012912] c642                      and.w     d2,d3
[00012914] 4bfa 0124                 lea.l     $00012A3A(pc),a5
[00012918] bc7c 000c                 cmp.w     #$000C,d6
[0001291c] 6700 0160                 beq       $00012A7E
[00012920] 600c                      bra.s     $0001292E
[00012922] 4bfa 00ce                 lea.l     $000129F2(pc),a5
[00012926] 4a47                      tst.w     d7
[00012928] 6704                      beq.s     $0001292E
[0001292a] 4bfa 0118                 lea.l     $00012A44(pc),a5
[0001292e] 4ed4                      jmp       (a4)
[00012930] 3c28 fff6                 move.w    -10(a0),d6
[00012934] 4846                      swap      d6
[00012936] 3c20                      move.w    -(a0),d6
[00012938] e0be                      ror.l     d0,d6
[0001293a] 4646                      not.w     d6
[0001293c] cc43                      and.w     d3,d6
[0001293e] 8761                      or.w      d3,-(a1)
[00012940] bd51                      eor.w     d6,(a1)
[00012942] 3c28 fff6                 move.w    -10(a0),d6
[00012946] 4846                      swap      d6
[00012948] 3c20                      move.w    -(a0),d6
[0001294a] e0be                      ror.l     d0,d6
[0001294c] 4646                      not.w     d6
[0001294e] cc43                      and.w     d3,d6
[00012950] 8761                      or.w      d3,-(a1)
[00012952] bd51                      eor.w     d6,(a1)
[00012954] 3c28 fff6                 move.w    -10(a0),d6
[00012958] 4846                      swap      d6
[0001295a] 3c20                      move.w    -(a0),d6
[0001295c] e0be                      ror.l     d0,d6
[0001295e] 4646                      not.w     d6
[00012960] cc43                      and.w     d3,d6
[00012962] 8761                      or.w      d3,-(a1)
[00012964] bd51                      eor.w     d6,(a1)
[00012966] 3c28 fff6                 move.w    -10(a0),d6
[0001296a] 4846                      swap      d6
[0001296c] 3c20                      move.w    -(a0),d6
[0001296e] e0be                      ror.l     d0,d6
[00012970] 4646                      not.w     d6
[00012972] cc43                      and.w     d3,d6
[00012974] 8761                      or.w      d3,-(a1)
[00012976] bd51                      eor.w     d6,(a1)
[00012978] 3801                      move.w    d1,d4
[0001297a] 6a40                      bpl.s     $000129BC
[0001297c] 6b72                      bmi.s     $000129F0
[0001297e] 3c20                      move.w    -(a0),d6
[00012980] 4846                      swap      d6
[00012982] e0be                      ror.l     d0,d6
[00012984] 4646                      not.w     d6
[00012986] cc43                      and.w     d3,d6
[00012988] 8761                      or.w      d3,-(a1)
[0001298a] bd51                      eor.w     d6,(a1)
[0001298c] 3c20                      move.w    -(a0),d6
[0001298e] 4846                      swap      d6
[00012990] e0be                      ror.l     d0,d6
[00012992] 4646                      not.w     d6
[00012994] cc43                      and.w     d3,d6
[00012996] 8761                      or.w      d3,-(a1)
[00012998] bd51                      eor.w     d6,(a1)
[0001299a] 3c20                      move.w    -(a0),d6
[0001299c] 4846                      swap      d6
[0001299e] e0be                      ror.l     d0,d6
[000129a0] 4646                      not.w     d6
[000129a2] cc43                      and.w     d3,d6
[000129a4] 8761                      or.w      d3,-(a1)
[000129a6] bd51                      eor.w     d6,(a1)
[000129a8] 3c20                      move.w    -(a0),d6
[000129aa] 4846                      swap      d6
[000129ac] e0be                      ror.l     d0,d6
[000129ae] 4646                      not.w     d6
[000129b0] cc43                      and.w     d3,d6
[000129b2] 8761                      or.w      d3,-(a1)
[000129b4] bd51                      eor.w     d6,(a1)
[000129b6] 5088                      addq.l    #8,a0
[000129b8] 3801                      move.w    d1,d4
[000129ba] 6b34                      bmi.s     $000129F0
[000129bc] 3c28 fff6                 move.w    -10(a0),d6
[000129c0] 4846                      swap      d6
[000129c2] 3c20                      move.w    -(a0),d6
[000129c4] e0be                      ror.l     d0,d6
[000129c6] 3306                      move.w    d6,-(a1)
[000129c8] 3c28 fff6                 move.w    -10(a0),d6
[000129cc] 4846                      swap      d6
[000129ce] 3c20                      move.w    -(a0),d6
[000129d0] e0be                      ror.l     d0,d6
[000129d2] 3306                      move.w    d6,-(a1)
[000129d4] 3c28 fff6                 move.w    -10(a0),d6
[000129d8] 4846                      swap      d6
[000129da] 3c20                      move.w    -(a0),d6
[000129dc] e0be                      ror.l     d0,d6
[000129de] 3306                      move.w    d6,-(a1)
[000129e0] 3c28 fff6                 move.w    -10(a0),d6
[000129e4] 4846                      swap      d6
[000129e6] 3c20                      move.w    -(a0),d6
[000129e8] e0be                      ror.l     d0,d6
[000129ea] 3306                      move.w    d6,-(a1)
[000129ec] 51cc ffce                 dbf       d4,$000129BC
[000129f0] 4ed5                      jmp       (a5)
[000129f2] 3c28 fff6                 move.w    -10(a0),d6
[000129f6] 4846                      swap      d6
[000129f8] 3c20                      move.w    -(a0),d6
[000129fa] e0be                      ror.l     d0,d6
[000129fc] 4646                      not.w     d6
[000129fe] cc42                      and.w     d2,d6
[00012a00] 8561                      or.w      d2,-(a1)
[00012a02] bd51                      eor.w     d6,(a1)
[00012a04] 3c28 fff6                 move.w    -10(a0),d6
[00012a08] 4846                      swap      d6
[00012a0a] 3c20                      move.w    -(a0),d6
[00012a0c] e0be                      ror.l     d0,d6
[00012a0e] 4646                      not.w     d6
[00012a10] cc42                      and.w     d2,d6
[00012a12] 8561                      or.w      d2,-(a1)
[00012a14] bd51                      eor.w     d6,(a1)
[00012a16] 3c28 fff6                 move.w    -10(a0),d6
[00012a1a] 4846                      swap      d6
[00012a1c] 3c20                      move.w    -(a0),d6
[00012a1e] e0be                      ror.l     d0,d6
[00012a20] 4646                      not.w     d6
[00012a22] cc42                      and.w     d2,d6
[00012a24] 8561                      or.w      d2,-(a1)
[00012a26] bd51                      eor.w     d6,(a1)
[00012a28] 3c28 fff6                 move.w    -10(a0),d6
[00012a2c] 4846                      swap      d6
[00012a2e] 3c20                      move.w    -(a0),d6
[00012a30] e0be                      ror.l     d0,d6
[00012a32] 4646                      not.w     d6
[00012a34] cc42                      and.w     d2,d6
[00012a36] 8561                      or.w      d2,-(a1)
[00012a38] bd51                      eor.w     d6,(a1)
[00012a3a] 90ca                      suba.w    a2,a0
[00012a3c] 92cb                      suba.w    a3,a1
[00012a3e] 51cd feee                 dbf       d5,$0001292E
[00012a42] 4e75                      rts
[00012a44] 3c20                      move.w    -(a0),d6
[00012a46] e0be                      ror.l     d0,d6
[00012a48] 4646                      not.w     d6
[00012a4a] cc42                      and.w     d2,d6
[00012a4c] 8561                      or.w      d2,-(a1)
[00012a4e] bd51                      eor.w     d6,(a1)
[00012a50] 3c20                      move.w    -(a0),d6
[00012a52] e0be                      ror.l     d0,d6
[00012a54] 4646                      not.w     d6
[00012a56] cc42                      and.w     d2,d6
[00012a58] 8561                      or.w      d2,-(a1)
[00012a5a] bd51                      eor.w     d6,(a1)
[00012a5c] 3c20                      move.w    -(a0),d6
[00012a5e] e0be                      ror.l     d0,d6
[00012a60] 4646                      not.w     d6
[00012a62] cc42                      and.w     d2,d6
[00012a64] 8561                      or.w      d2,-(a1)
[00012a66] bd51                      eor.w     d6,(a1)
[00012a68] 3c20                      move.w    -(a0),d6
[00012a6a] e0be                      ror.l     d0,d6
[00012a6c] 4646                      not.w     d6
[00012a6e] cc42                      and.w     d2,d6
[00012a70] 8561                      or.w      d2,-(a1)
[00012a72] bd51                      eor.w     d6,(a1)
[00012a74] 90ca                      suba.w    a2,a0
[00012a76] 92cb                      suba.w    a3,a1
[00012a78] 51cd feb4                 dbf       d5,$0001292E
[00012a7c] 4e75                      rts
[00012a7e] 3c20                      move.w    -(a0),d6
[00012a80] e0be                      ror.l     d0,d6
[00012a82] 4646                      not.w     d6
[00012a84] cc43                      and.w     d3,d6
[00012a86] 8761                      or.w      d3,-(a1)
[00012a88] bd51                      eor.w     d6,(a1)
[00012a8a] 3c20                      move.w    -(a0),d6
[00012a8c] e0be                      ror.l     d0,d6
[00012a8e] 4646                      not.w     d6
[00012a90] cc43                      and.w     d3,d6
[00012a92] 8761                      or.w      d3,-(a1)
[00012a94] bd51                      eor.w     d6,(a1)
[00012a96] 3c20                      move.w    -(a0),d6
[00012a98] e0be                      ror.l     d0,d6
[00012a9a] 4646                      not.w     d6
[00012a9c] cc43                      and.w     d3,d6
[00012a9e] 8761                      or.w      d3,-(a1)
[00012aa0] bd51                      eor.w     d6,(a1)
[00012aa2] 3c20                      move.w    -(a0),d6
[00012aa4] e0be                      ror.l     d0,d6
[00012aa6] 4646                      not.w     d6
[00012aa8] cc43                      and.w     d3,d6
[00012aaa] 8761                      or.w      d3,-(a1)
[00012aac] bd51                      eor.w     d6,(a1)
[00012aae] 5088                      addq.l    #8,a0
[00012ab0] 90ca                      suba.w    a2,a0
[00012ab2] 92cb                      suba.w    a3,a1
[00012ab4] 51cd ffc8                 dbf       d5,$00012A7E
[00012ab8] 4e75                      rts
[00012aba] ffff 7fff 3fff 1fff       vperm     #$3FFF1FFF,e23,e15,e23
[00012ac2] 0fff                      bset      d7,???
[00012ac4] 07ff                      bset      d3,???
[00012ac6] 03ff                      bset      d1,???
[00012ac8] 01ff                      bset      d0,???
[00012aca] 00ff 007f                 cmp2.b    ???,d0 ; 68020+ only
[00012ace] 003f 001f                 ori.b     #$1F,???
[00012ad2] 000f 0007                 ori.b     #$07,a7 ; apollo only
[00012ad6] 0003 0001                 ori.b     #$01,d3
[00012ada] 0000 2278                 ori.b     #$78,d0
[00012ade] 044e 3c38                 subi.w    #$3C38,a6 ; apollo only
[00012ae2] 206e 4a6e                 movea.l   19054(a6),a0
[00012ae6] 01b2 6708                 bclr      d0,(a2,d6.w*8) ; 68020+ only; reserved BD=0
[00012aea] 226e 01ae                 movea.l   430(a6),a1
[00012aee] 3c2e 01b2                 move.w    434(a6),d6
[00012af2] 9641                      sub.w     d1,d3
[00012af4] 780f                      moveq.l   #15,d4
[00012af6] 7a0f                      moveq.l   #15,d5
[00012af8] ca40                      and.w     d0,d5
[00012afa] c842                      and.w     d2,d4
[00012afc] 3e01                      move.w    d1,d7
[00012afe] cfc6                      muls.w    d6,d7
[00012b00] d3c7                      adda.l    d7,a1
[00012b02] 5146                      subq.w    #8,d6
[00012b04] 3646                      movea.w   d6,a3
[00012b06] e840                      asr.w     #4,d0
[00012b08] 3c00                      move.w    d0,d6
[00012b0a] e74e                      lsl.w     #3,d6
[00012b0c] d2c6                      adda.w    d6,a1
[00012b0e] d844                      add.w     d4,d4
[00012b10] da45                      add.w     d5,d5
[00012b12] 383b 40a8                 move.w    $00012ABC(pc,d4.w),d4
[00012b16] 4644                      not.w     d4
[00012b18] 4844                      swap      d4
[00012b1a] 383b 509e                 move.w    $00012ABA(pc,d5.w),d4
[00012b1e] e842                      asr.w     #4,d2
[00012b20] 9440                      sub.w     d0,d2
[00012b22] 6608                      bne.s     $00012B2C
[00012b24] 2a04                      move.l    d4,d5
[00012b26] 4245                      clr.w     d5
[00012b28] 4845                      swap      d5
[00012b2a] c885                      and.l     d5,d4
[00012b2c] 5542                      subq.w    #2,d2
[00012b2e] 286e 00c6                 movea.l   198(a6),a4
[00012b32] 700f                      moveq.l   #15,d0
[00012b34] c041                      and.w     d1,d0
[00012b36] 7a0f                      moveq.l   #15,d5
[00012b38] 9a40                      sub.w     d0,d5
[00012b3a] d040                      add.w     d0,d0
[00012b3c] d8c0                      adda.w    d0,a4
[00012b3e] 3e2e 003c                 move.w    60(a6),d7
[00012b42] de47                      add.w     d7,d7
[00012b44] 45fa 009a                 lea.l     $00012BE0(pc),a2
[00012b48] d4f2 7000                 adda.w    0(a2,d7.w),a2
[00012b4c] 302e 00be                 move.w    190(a6),d0
[00012b50] 41fa 1190                 lea.l     $00013CE2(pc),a0
[00012b54] 1030 0000                 move.b    0(a0,d0.w),d0
[00012b58] 7203                      moveq.l   #3,d1
[00012b5a] 3f01                      move.w    d1,-(a7)
[00012b5c] 3f00                      move.w    d0,-(a7)
[00012b5e] 2c4c                      movea.l   a4,a6
[00012b60] 3c1c                      move.w    (a4)+,d6
[00012b62] 4ed2                      jmp       (a2)
[00012b64] 4dee 0020                 lea.l     32(a6),a6
[00012b68] 3c16                      move.w    (a6),d6
[00012b6a] 487a 0010                 pea.l     $00012B7C(pc)
[00012b6e] 2049                      movea.l   a1,a0
[00012b70] 4646                      not.w     d6
[00012b72] e248                      lsr.w     #1,d0
[00012b74] 6500 0598                 bcs       $0001310E
[00012b78] 6000 05b4                 bra       $0001312E
[00012b7c] 51c9 ffe6                 dbf       d1,$00012B64
[00012b80] 6044                      bra.s     $00012BC6
[00012b82] 4dee 0020                 lea.l     32(a6),a6
[00012b86] 3c16                      move.w    (a6),d6
[00012b88] 2049                      movea.l   a1,a0
[00012b8a] 6100 05ca                 bsr       $00013156
[00012b8e] 51c9 fff2                 dbf       d1,$00012B82
[00012b92] 6032                      bra.s     $00012BC6
[00012b94] 4dee 0020                 lea.l     32(a6),a6
[00012b98] 3c16                      move.w    (a6),d6
[00012b9a] 487a 000e                 pea.l     $00012BAA(pc)
[00012b9e] 2049                      movea.l   a1,a0
[00012ba0] e248                      lsr.w     #1,d0
[00012ba2] 6500 056a                 bcs       $0001310E
[00012ba6] 6000 0586                 bra       $0001312E
[00012baa] 51c9 ffe8                 dbf       d1,$00012B94
[00012bae] 6016                      bra.s     $00012BC6
[00012bb0] 4dee 0020                 lea.l     32(a6),a6
[00012bb4] 3c16                      move.w    (a6),d6
[00012bb6] 2049                      movea.l   a1,a0
[00012bb8] e248                      lsr.w     #1,d0
[00012bba] 6502                      bcs.s     $00012BBE
[00012bbc] 4246                      clr.w     d6
[00012bbe] 6100 0526                 bsr       $000130E6
[00012bc2] 51c9 ffec                 dbf       d1,$00012BB0
[00012bc6] 3017                      move.w    (a7),d0
[00012bc8] 322f 0002                 move.w    2(a7),d1
[00012bcc] 51cd 0008                 dbf       d5,$00012BD6
[00012bd0] 7a0f                      moveq.l   #15,d5
[00012bd2] 49ec ffe0                 lea.l     -32(a4),a4
[00012bd6] d2cb                      adda.w    a3,a1
[00012bd8] 51cb ff84                 dbf       d3,$00012B5E
[00012bdc] 588f                      addq.l    #4,a7
[00012bde] 4e75                      rts
[00012be0] ffd6                      dc.w      $FFD6 ; illegal
[00012be2] ffba                      dc.w      $FFBA ; illegal
[00012be4] ffa8                      dc.w      $FFA8 ; illegal
[00012be6] ff8a                      dc.w      $FF8A ; illegal
[00012be8] ffff ffff 7fff 7fff       vperm     #$7FFF7FFF,e23,e23,e23
[00012bf0] 3fff                      move.w    ???,???
[00012bf2] 3fff                      move.w    ???,???
[00012bf4] 1fff                      move.b    ???,???
[00012bf6] 1fff                      move.b    ???,???
[00012bf8] 0fff                      bset      d7,???
[00012bfa] 0fff                      bset      d7,???
[00012bfc] 07ff                      bset      d3,???
[00012bfe] 07ff                      bset      d3,???
[00012c00] 03ff                      bset      d1,???
[00012c02] 03ff                      bset      d1,???
[00012c04] 01ff                      bset      d0,???
[00012c06] 01ff                      bset      d0,???
[00012c08] 00ff 00ff                 cmp2.b    ???,d0 ; 68020+ only
[00012c0c] 007f 007f                 ori.w     #$007F,???
[00012c10] 003f 003f                 ori.b     #$3F,???
[00012c14] 001f 001f                 ori.b     #$1F,(a7)+
[00012c18] 000f 000f                 ori.b     #$0F,a7 ; apollo only
[00012c1c] 0007 0007                 ori.b     #$07,d7
[00012c20] 0003 0003                 ori.b     #$03,d3
[00012c24] 0001 0001                 ori.b     #$01,d1
[00012c28] 0000 0000                 ori.b     #$00,d0
[00012c2c] 4a6e 00ca                 tst.w     202(a6)
[00012c30] 6600 feaa                 bne       $00012ADC
[00012c34] 2278 044e                 movea.l   ($0000044E).w,a1
[00012c38] 3838 206e                 move.w    ($0000206E).w,d4
[00012c3c] 4a6e 01b2                 tst.w     434(a6)
[00012c40] 6708                      beq.s     $00012C4A
[00012c42] 226e 01ae                 movea.l   430(a6),a1
[00012c46] 382e 01b2                 move.w    434(a6),d4
[00012c4a] 3644                      movea.w   d4,a3
[00012c4c] c9c1                      muls.w    d1,d4
[00012c4e] d3c4                      adda.l    d4,a1
[00012c50] 780f                      moveq.l   #15,d4
[00012c52] 7a0f                      moveq.l   #15,d5
[00012c54] c840                      and.w     d0,d4
[00012c56] ca42                      and.w     d2,d5
[00012c58] d844                      add.w     d4,d4
[00012c5a] d844                      add.w     d4,d4
[00012c5c] da45                      add.w     d5,d5
[00012c5e] da45                      add.w     d5,d5
[00012c60] 41fa ff86                 lea.l     $00012BE8(pc),a0
[00012c64] 2830 4000                 move.l    0(a0,d4.w),d4
[00012c68] 2a30 5004                 move.l    4(a0,d5.w),d5
[00012c6c] 0240 fff0                 andi.w    #$FFF0,d0
[00012c70] e240                      asr.w     #1,d0
[00012c72] d2c0                      adda.w    d0,a1
[00012c74] 9641                      sub.w     d1,d3
[00012c76] 0242 fff0                 andi.w    #$FFF0,d2
[00012c7a] e242                      asr.w     #1,d2
[00012c7c] 9440                      sub.w     d0,d2
[00012c7e] 3e2e 003c                 move.w    60(a6),d7
[00012c82] 660e                      bne.s     $00012C92
[00012c84] 4a6e 00be                 tst.w     190(a6)
[00012c88] 671c                      beq.s     $00012CA6
[00012c8a] 4a6e 00c0                 tst.w     192(a6)
[00012c8e] 6660                      bne.s     $00012CF0
[00012c90] 6014                      bra.s     $00012CA6
[00012c92] be7c 0001                 cmp.w     #$0001,d7
[00012c96] 6658                      bne.s     $00012CF0
[00012c98] 4a6e 00be                 tst.w     190(a6)
[00012c9c] 6652                      bne.s     $00012CF0
[00012c9e] 0c6e 0001 00c0            cmpi.w    #$0001,192(a6)
[00012ca4] 664a                      bne.s     $00012CF0
[00012ca6] 96c2                      suba.w    d2,a3
[00012ca8] 514b                      subq.w    #8,a3
[00012caa] e642                      asr.w     #3,d2
[00012cac] 4684                      not.l     d4
[00012cae] 5342                      subq.w    #1,d2
[00012cb0] 6b20                      bmi.s     $00012CD2
[00012cb2] 5342                      subq.w    #1,d2
[00012cb4] 6b2a                      bmi.s     $00012CE0
[00012cb6] 7c00                      moveq.l   #0,d6
[00012cb8] 3202                      move.w    d2,d1
[00012cba] c999                      and.l     d4,(a1)+
[00012cbc] c999                      and.l     d4,(a1)+
[00012cbe] 22c6                      move.l    d6,(a1)+
[00012cc0] 22c6                      move.l    d6,(a1)+
[00012cc2] 51c9 fffa                 dbf       d1,$00012CBE
[00012cc6] cb99                      and.l     d5,(a1)+
[00012cc8] cb99                      and.l     d5,(a1)+
[00012cca] d2cb                      adda.w    a3,a1
[00012ccc] 51cb ffea                 dbf       d3,$00012CB8
[00012cd0] 4e75                      rts
[00012cd2] 8885                      or.l      d5,d4
[00012cd4] c999                      and.l     d4,(a1)+
[00012cd6] c999                      and.l     d4,(a1)+
[00012cd8] d2cb                      adda.w    a3,a1
[00012cda] 51cb fff8                 dbf       d3,$00012CD4
[00012cde] 4e75                      rts
[00012ce0] c999                      and.l     d4,(a1)+
[00012ce2] c999                      and.l     d4,(a1)+
[00012ce4] cb99                      and.l     d5,(a1)+
[00012ce6] cb99                      and.l     d5,(a1)+
[00012ce8] d2cb                      adda.w    a3,a1
[00012cea] 51cb fff4                 dbf       d3,$00012CE0
[00012cee] 4e75                      rts
[00012cf0] 300b                      move.w    a3,d0
[00012cf2] e948                      lsl.w     #4,d0
[00012cf4] 9042                      sub.w     d2,d0
[00012cf6] 5140                      subq.w    #8,d0
[00012cf8] 3440                      movea.w   d0,a2
[00012cfa] e642                      asr.w     #3,d2
[00012cfc] 4685                      not.l     d5
[00012cfe] 206e 00c6                 movea.l   198(a6),a0
[00012d02] 700f                      moveq.l   #15,d0
[00012d04] c041                      and.w     d1,d0
[00012d06] 720f                      moveq.l   #15,d1
[00012d08] 9240                      sub.w     d0,d1
[00012d0a] d040                      add.w     d0,d0
[00012d0c] d0c0                      adda.w    d0,a0
[00012d0e] 5342                      subq.w    #1,d2
[00012d10] 6a06                      bpl.s     $00012D18
[00012d12] 514a                      subq.w    #8,a2
[00012d14] c885                      and.l     d5,d4
[00012d16] 7a00                      moveq.l   #0,d5
[00012d18] 5342                      subq.w    #1,d2
[00012d1a] 4a47                      tst.w     d7
[00012d1c] 6600 018e                 bne       $00012EAC
[00012d20] 3c2e 00c0                 move.w    192(a6),d6
[00012d24] 5346                      subq.w    #1,d6
[00012d26] 6700 0126                 beq       $00012E4E
[00012d2a] 5346                      subq.w    #1,d6
[00012d2c] 660a                      bne.s     $00012D38
[00012d2e] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[00012d34] 6700 0118                 beq       $00012E4E
[00012d38] 3c2e 00be                 move.w    190(a6),d6
[00012d3c] 5346                      subq.w    #1,d6
[00012d3e] 666c                      bne.s     $00012DAC
[00012d40] 700f                      moveq.l   #15,d0
[00012d42] b640                      cmp.w     d0,d3
[00012d44] 6c02                      bge.s     $00012D48
[00012d46] c043                      and.w     d3,d0
[00012d48] 4843                      swap      d3
[00012d4a] 3600                      move.w    d0,d3
[00012d4c] 4843                      swap      d3
[00012d4e] 2849                      movea.l   a1,a4
[00012d50] d2cb                      adda.w    a3,a1
[00012d52] 3003                      move.w    d3,d0
[00012d54] e848                      lsr.w     #4,d0
[00012d56] 2c10                      move.l    (a0),d6
[00012d58] 3c18                      move.w    (a0)+,d6
[00012d5a] 51c9 0008                 dbf       d1,$00012D64
[00012d5e] 720f                      moveq.l   #15,d1
[00012d60] 41e8 ffe0                 lea.l     -32(a0),a0
[00012d64] 2e06                      move.l    d6,d7
[00012d66] 4687                      not.l     d7
[00012d68] ce84                      and.l     d4,d7
[00012d6a] 8994                      or.l      d4,(a4)
[00012d6c] bf9c                      eor.l     d7,(a4)+
[00012d6e] 8994                      or.l      d4,(a4)
[00012d70] bf9c                      eor.l     d7,(a4)+
[00012d72] 3e02                      move.w    d2,d7
[00012d74] 6b08                      bmi.s     $00012D7E
[00012d76] 28c6                      move.l    d6,(a4)+
[00012d78] 28c6                      move.l    d6,(a4)+
[00012d7a] 51cf fffa                 dbf       d7,$00012D76
[00012d7e] 2e06                      move.l    d6,d7
[00012d80] 4687                      not.l     d7
[00012d82] ce85                      and.l     d5,d7
[00012d84] 8b94                      or.l      d5,(a4)
[00012d86] bf9c                      eor.l     d7,(a4)+
[00012d88] 8b94                      or.l      d5,(a4)
[00012d8a] bf9c                      eor.l     d7,(a4)+
[00012d8c] d8ca                      adda.w    a2,a4
[00012d8e] 51c8 ffd4                 dbf       d0,$00012D64
[00012d92] 5343                      subq.w    #1,d3
[00012d94] 4843                      swap      d3
[00012d96] 51cb ffb4                 dbf       d3,$00012D4C
[00012d9a] 4e75                      rts
[00012d9c] 0000 0000                 ori.b     #$00,d0
[00012da0] ffff 0000 0000 ffff       vperm     #$0000FFFF,e8,e8,e8
[00012da8] ffff ffff 700f b640       vperm     #$700FB640,e23,e23,e23
[00012db0] 6c02                      bge.s     $00012DB4
[00012db2] c043                      and.w     d3,d0
[00012db4] 4843                      swap      d3
[00012db6] 3600                      move.w    d0,d3
[00012db8] 4843                      swap      d3
[00012dba] 3003                      move.w    d3,d0
[00012dbc] e848                      lsr.w     #4,d0
[00012dbe] 2c10                      move.l    (a0),d6
[00012dc0] 3c18                      move.w    (a0)+,d6
[00012dc2] 2e06                      move.l    d6,d7
[00012dc4] 51c9 0008                 dbf       d1,$00012DCE
[00012dc8] 720f                      moveq.l   #15,d1
[00012dca] 41e8 ffe0                 lea.l     -32(a0),a0
[00012dce] 3f01                      move.w    d1,-(a7)
[00012dd0] 2f03                      move.l    d3,-(a7)
[00012dd2] 322e 00be                 move.w    190(a6),d1
[00012dd6] 49fa 0f0a                 lea.l     $00013CE2(pc),a4
[00012dda] 1234 1000                 move.b    0(a4,d1.w),d1
[00012dde] 7603                      moveq.l   #3,d3
[00012de0] c641                      and.w     d1,d3
[00012de2] d643                      add.w     d3,d3
[00012de4] d643                      add.w     d3,d3
[00012de6] 0241 000c                 andi.w    #$000C,d1
[00012dea] ccbb 30b0                 and.l     $00012D9C(pc,d3.w),d6
[00012dee] cebb 10ac                 and.l     $00012D9C(pc,d1.w),d7
[00012df2] 2849                      movea.l   a1,a4
[00012df4] d2cb                      adda.w    a3,a1
[00012df6] 2206                      move.l    d6,d1
[00012df8] 2607                      move.l    d7,d3
[00012dfa] 4681                      not.l     d1
[00012dfc] 4683                      not.l     d3
[00012dfe] c284                      and.l     d4,d1
[00012e00] c684                      and.l     d4,d3
[00012e02] 8994                      or.l      d4,(a4)
[00012e04] b39c                      eor.l     d1,(a4)+
[00012e06] 8994                      or.l      d4,(a4)
[00012e08] b79c                      eor.l     d3,(a4)+
[00012e0a] 3202                      move.w    d2,d1
[00012e0c] 6b08                      bmi.s     $00012E16
[00012e0e] 28c6                      move.l    d6,(a4)+
[00012e10] 28c7                      move.l    d7,(a4)+
[00012e12] 51c9 fffa                 dbf       d1,$00012E0E
[00012e16] 2206                      move.l    d6,d1
[00012e18] 2607                      move.l    d7,d3
[00012e1a] 4681                      not.l     d1
[00012e1c] 4683                      not.l     d3
[00012e1e] c285                      and.l     d5,d1
[00012e20] c685                      and.l     d5,d3
[00012e22] 8b94                      or.l      d5,(a4)
[00012e24] b39c                      eor.l     d1,(a4)+
[00012e26] 8b94                      or.l      d5,(a4)
[00012e28] b79c                      eor.l     d3,(a4)+
[00012e2a] d8ca                      adda.w    a2,a4
[00012e2c] 51c8 ffc8                 dbf       d0,$00012DF6
[00012e30] 261f                      move.l    (a7)+,d3
[00012e32] 321f                      move.w    (a7)+,d1
[00012e34] 5343                      subq.w    #1,d3
[00012e36] 4843                      swap      d3
[00012e38] 51cb ff7e                 dbf       d3,$00012DB8
[00012e3c] 4e75                      rts
[00012e3e] 0000 0000                 ori.b     #$00,d0
[00012e42] ffff 0000 0000 ffff       vperm     #$0000FFFF,e8,e8,e8
[00012e4a] ffff ffff 302e 00be       vperm     #$302E00BE,e23,e23,e23
[00012e52] 49fa 0e8e                 lea.l     $00013CE2(pc),a4
[00012e56] 1034 0000                 move.b    0(a4,d0.w),d0
[00012e5a] 7203                      moveq.l   #3,d1
[00012e5c] c240                      and.w     d0,d1
[00012e5e] d241                      add.w     d1,d1
[00012e60] d241                      add.w     d1,d1
[00012e62] 0240 000c                 andi.w    #$000C,d0
[00012e66] 2c3b 10d6                 move.l    $00012E3E(pc,d1.w),d6
[00012e6a] 2e3b 00d2                 move.l    $00012E3E(pc,d0.w),d7
[00012e6e] 2849                      movea.l   a1,a4
[00012e70] 2006                      move.l    d6,d0
[00012e72] 2207                      move.l    d7,d1
[00012e74] 4680                      not.l     d0
[00012e76] 4681                      not.l     d1
[00012e78] c084                      and.l     d4,d0
[00012e7a] c284                      and.l     d4,d1
[00012e7c] 8994                      or.l      d4,(a4)
[00012e7e] b19c                      eor.l     d0,(a4)+
[00012e80] 8994                      or.l      d4,(a4)
[00012e82] b39c                      eor.l     d1,(a4)+
[00012e84] 3202                      move.w    d2,d1
[00012e86] 6b08                      bmi.s     $00012E90
[00012e88] 28c6                      move.l    d6,(a4)+
[00012e8a] 28c7                      move.l    d7,(a4)+
[00012e8c] 51c9 fffa                 dbf       d1,$00012E88
[00012e90] 2006                      move.l    d6,d0
[00012e92] 2207                      move.l    d7,d1
[00012e94] 4680                      not.l     d0
[00012e96] 4681                      not.l     d1
[00012e98] c085                      and.l     d5,d0
[00012e9a] c285                      and.l     d5,d1
[00012e9c] 8b94                      or.l      d5,(a4)
[00012e9e] b19c                      eor.l     d0,(a4)+
[00012ea0] 8b94                      or.l      d5,(a4)
[00012ea2] b39c                      eor.l     d1,(a4)+
[00012ea4] d2cb                      adda.w    a3,a1
[00012ea6] 51cb ffc6                 dbf       d3,$00012E6E
[00012eaa] 4e75                      rts
[00012eac] 5547                      subq.w    #2,d7
[00012eae] 6650                      bne.s     $00012F00
[00012eb0] 700f                      moveq.l   #15,d0
[00012eb2] b640                      cmp.w     d0,d3
[00012eb4] 6c02                      bge.s     $00012EB8
[00012eb6] c043                      and.w     d3,d0
[00012eb8] 4843                      swap      d3
[00012eba] 3600                      move.w    d0,d3
[00012ebc] 4843                      swap      d3
[00012ebe] 2849                      movea.l   a1,a4
[00012ec0] d2cb                      adda.w    a3,a1
[00012ec2] 3003                      move.w    d3,d0
[00012ec4] e848                      lsr.w     #4,d0
[00012ec6] 2c10                      move.l    (a0),d6
[00012ec8] 3c18                      move.w    (a0)+,d6
[00012eca] 51c9 0008                 dbf       d1,$00012ED4
[00012ece] 720f                      moveq.l   #15,d1
[00012ed0] 41e8 ffe0                 lea.l     -32(a0),a0
[00012ed4] 2e06                      move.l    d6,d7
[00012ed6] ce84                      and.l     d4,d7
[00012ed8] bf9c                      eor.l     d7,(a4)+
[00012eda] bf9c                      eor.l     d7,(a4)+
[00012edc] 3e02                      move.w    d2,d7
[00012ede] 6b08                      bmi.s     $00012EE8
[00012ee0] bd9c                      eor.l     d6,(a4)+
[00012ee2] bd9c                      eor.l     d6,(a4)+
[00012ee4] 51cf fffa                 dbf       d7,$00012EE0
[00012ee8] 2e06                      move.l    d6,d7
[00012eea] ce85                      and.l     d5,d7
[00012eec] bf9c                      eor.l     d7,(a4)+
[00012eee] bf9c                      eor.l     d7,(a4)+
[00012ef0] d8ca                      adda.w    a2,a4
[00012ef2] 51c8 ffe0                 dbf       d0,$00012ED4
[00012ef6] 5343                      subq.w    #1,d3
[00012ef8] 4843                      swap      d3
[00012efa] 51cb ffc0                 dbf       d3,$00012EBC
[00012efe] 4e75                      rts
[00012f00] 4a47                      tst.w     d7
[00012f02] 6b3c                      bmi.s     $00012F40
[00012f04] 4a6e 00c0                 tst.w     192(a6)
[00012f08] 6700 fe16                 beq       $00012D20
[00012f0c] 2008                      move.l    a0,d0
[00012f0e] 206e 0020                 movea.l   32(a6),a0
[00012f12] 286e 00c6                 movea.l   198(a6),a4
[00012f16] 908c                      sub.l     a4,d0
[00012f18] 209c                      move.l    (a4)+,(a0)
[00012f1a] 4698                      not.l     (a0)+
[00012f1c] 209c                      move.l    (a4)+,(a0)
[00012f1e] 4698                      not.l     (a0)+
[00012f20] 209c                      move.l    (a4)+,(a0)
[00012f22] 4698                      not.l     (a0)+
[00012f24] 209c                      move.l    (a4)+,(a0)
[00012f26] 4698                      not.l     (a0)+
[00012f28] 209c                      move.l    (a4)+,(a0)
[00012f2a] 4698                      not.l     (a0)+
[00012f2c] 209c                      move.l    (a4)+,(a0)
[00012f2e] 4698                      not.l     (a0)+
[00012f30] 209c                      move.l    (a4)+,(a0)
[00012f32] 4698                      not.l     (a0)+
[00012f34] 209c                      move.l    (a4)+,(a0)
[00012f36] 4698                      not.l     (a0)+
[00012f38] 41e8 ffe0                 lea.l     -32(a0),a0
[00012f3c] d0c0                      adda.w    d0,a0
[00012f3e] 600a                      bra.s     $00012F4A
[00012f40] 0c6e 0001 00c0            cmpi.w    #$0001,192(a6)
[00012f46] 6700 fdd8                 beq       $00012D20
[00012f4a] 2f0d                      move.l    a5,-(a7)
[00012f4c] 300b                      move.w    a3,d0
[00012f4e] e948                      lsl.w     #4,d0
[00012f50] 5140                      subq.w    #8,d0
[00012f52] 3440                      movea.w   d0,a2
[00012f54] 700f                      moveq.l   #15,d0
[00012f56] b640                      cmp.w     d0,d3
[00012f58] 6c02                      bge.s     $00012F5C
[00012f5a] c043                      and.w     d3,d0
[00012f5c] 4843                      swap      d3
[00012f5e] 3600                      move.w    d0,d3
[00012f60] 4843                      swap      d3
[00012f62] 2a49                      movea.l   a1,a5
[00012f64] d2cb                      adda.w    a3,a1
[00012f66] 3003                      move.w    d3,d0
[00012f68] e848                      lsr.w     #4,d0
[00012f6a] 2c10                      move.l    (a0),d6
[00012f6c] 3c18                      move.w    (a0)+,d6
[00012f6e] 51c9 0008                 dbf       d1,$00012F78
[00012f72] 720f                      moveq.l   #15,d1
[00012f74] 41e8 ffe0                 lea.l     -32(a0),a0
[00012f78] 48a7 c000                 movem.w   d0-d1,-(a7)
[00012f7c] 6116                      bsr.s     $00012F94
[00012f7e] 4c9f 0003                 movem.w   (a7)+,d0-d1
[00012f82] daca                      adda.w    a2,a5
[00012f84] 51c8 fff2                 dbf       d0,$00012F78
[00012f88] 5343                      subq.w    #1,d3
[00012f8a] 4843                      swap      d3
[00012f8c] 51cb ffd2                 dbf       d3,$00012F60
[00012f90] 2a5f                      movea.l   (a7)+,a5
[00012f92] 4e75                      rts
[00012f94] 302e 00be                 move.w    190(a6),d0
[00012f98] 49fa 0d48                 lea.l     $00013CE2(pc),a4
[00012f9c] 1034 0000                 move.b    0(a4,d0.w),d0
[00012fa0] 7203                      moveq.l   #3,d1
[00012fa2] 284d                      movea.l   a5,a4
[00012fa4] e248                      lsr.w     #1,d0
[00012fa6] 6420                      bcc.s     $00012FC8
[00012fa8] 3e06                      move.w    d6,d7
[00012faa] ce44                      and.w     d4,d7
[00012fac] 8f5d                      or.w      d7,(a5)+
[00012fae] 3e02                      move.w    d2,d7
[00012fb0] 6b08                      bmi.s     $00012FBA
[00012fb2] 508c                      addq.l    #8,a4
[00012fb4] 8d54                      or.w      d6,(a4)
[00012fb6] 51cf fffa                 dbf       d7,$00012FB2
[00012fba] 508c                      addq.l    #8,a4
[00012fbc] 3e06                      move.w    d6,d7
[00012fbe] ce45                      and.w     d5,d7
[00012fc0] 8f54                      or.w      d7,(a4)
[00012fc2] 51c9 ffde                 dbf       d1,$00012FA2
[00012fc6] 4e75                      rts
[00012fc8] 3e06                      move.w    d6,d7
[00012fca] ce44                      and.w     d4,d7
[00012fcc] 4647                      not.w     d7
[00012fce] cf5d                      and.w     d7,(a5)+
[00012fd0] 4646                      not.w     d6
[00012fd2] 3e02                      move.w    d2,d7
[00012fd4] 6b08                      bmi.s     $00012FDE
[00012fd6] 508c                      addq.l    #8,a4
[00012fd8] cd54                      and.w     d6,(a4)
[00012fda] 51cf fffa                 dbf       d7,$00012FD6
[00012fde] 508c                      addq.l    #8,a4
[00012fe0] 4646                      not.w     d6
[00012fe2] 3e06                      move.w    d6,d7
[00012fe4] ce45                      and.w     d5,d7
[00012fe6] 4647                      not.w     d7
[00012fe8] cf54                      and.w     d7,(a4)
[00012fea] 51c9 ffb6                 dbf       d1,$00012FA2
[00012fee] 4e75                      rts
[00012ff0] ffff 7fff 3fff 1fff       vperm     #$3FFF1FFF,e23,e15,e23
[00012ff8] 0fff                      bset      d7,???
[00012ffa] 07ff                      bset      d3,???
[00012ffc] 03ff                      bset      d1,???
[00012ffe] 01ff                      bset      d0,???
[00013000] 00ff 007f                 cmp2.b    ???,d0 ; 68020+ only
[00013004] 003f 001f                 ori.b     #$1F,???
[00013008] 000f 0007                 ori.b     #$07,a7 ; apollo only
[0001300c] 0003 0001                 ori.b     #$01,d3
[00013010] 0000 48e7                 ori.b     #$E7,d0
[00013014] 00a0 246e 00c6            ori.l     #$246E00C6,-(a0)
[0001301a] 780f                      moveq.l   #15,d4
[0001301c] c841                      and.w     d1,d4
[0001301e] d844                      add.w     d4,d4
[00013020] d4c4                      adda.w    d4,a2
[00013022] 780f                      moveq.l   #15,d4
[00013024] 7a0f                      moveq.l   #15,d5
[00013026] ca40                      and.w     d0,d5
[00013028] c842                      and.w     d2,d4
[0001302a] 4a6e 01b2                 tst.w     434(a6)
[0001302e] 670a                      beq.s     $0001303A
[00013030] 226e 01ae                 movea.l   430(a6),a1
[00013034] c3ee 01b2                 muls.w    434(a6),d1
[00013038] 6008                      bra.s     $00013042
[0001303a] 2278 044e                 movea.l   ($0000044E).w,a1
[0001303e] c3f8 206e                 muls.w    ($0000206E).w,d1
[00013042] d3c1                      adda.l    d1,a1
[00013044] d844                      add.w     d4,d4
[00013046] da45                      add.w     d5,d5
[00013048] 383b 40a8                 move.w    $00012FF2(pc,d4.w),d4
[0001304c] 4644                      not.w     d4
[0001304e] 4844                      swap      d4
[00013050] 383b 509e                 move.w    $00012FF0(pc,d5.w),d4
[00013054] e840                      asr.w     #4,d0
[00013056] 3200                      move.w    d0,d1
[00013058] e749                      lsl.w     #3,d1
[0001305a] d2c1                      adda.w    d1,a1
[0001305c] e842                      asr.w     #4,d2
[0001305e] 9440                      sub.w     d0,d2
[00013060] 6608                      bne.s     $0001306A
[00013062] 2a04                      move.l    d4,d5
[00013064] 4245                      clr.w     d5
[00013066] 4845                      swap      d5
[00013068] c885                      and.l     d5,d4
[0001306a] 5542                      subq.w    #2,d2
[0001306c] 7203                      moveq.l   #3,d1
[0001306e] 41fa 0c72                 lea.l     $00013CE2(pc),a0
[00013072] 302e 00be                 move.w    190(a6),d0
[00013076] 1030 0000                 move.b    0(a0,d0.w),d0
[0001307a] 1e3b 700c                 move.b    $00013088(pc,d7.w),d7
[0001307e] 4ebb 7008                 jsr       $00013088(pc,d7.w)
[00013082] 4cdf 0500                 movem.l   (a7)+,a0/a2
[00013086] 4e75                      rts
[00013088] 041a 3244                 subi.b    #$44,(a2)+
[0001308c] 2049                      movea.l   a1,a0
[0001308e] 3c12                      move.w    (a2),d6
[00013090] 45ea 0020                 lea.l     32(a2),a2
[00013094] e248                      lsr.w     #1,d0
[00013096] 6502                      bcs.s     $0001309A
[00013098] 4246                      clr.w     d6
[0001309a] 614a                      bsr.s     $000130E6
[0001309c] 51c9 ffee                 dbf       d1,$0001308C
[000130a0] 4e75                      rts
[000130a2] 487a 0010                 pea.l     $000130B4(pc)
[000130a6] 3c12                      move.w    (a2),d6
[000130a8] 45ea 0020                 lea.l     32(a2),a2
[000130ac] 2049                      movea.l   a1,a0
[000130ae] e248                      lsr.w     #1,d0
[000130b0] 655c                      bcs.s     $0001310E
[000130b2] 607a                      bra.s     $0001312E
[000130b4] 51c9 ffec                 dbf       d1,$000130A2
[000130b8] 4e75                      rts
[000130ba] 2049                      movea.l   a1,a0
[000130bc] 3c12                      move.w    (a2),d6
[000130be] 45ea 0020                 lea.l     32(a2),a2
[000130c2] 6100 0092                 bsr       $00013156
[000130c6] 51c9 fff2                 dbf       d1,$000130BA
[000130ca] 4e75                      rts
[000130cc] 487a 0012                 pea.l     $000130E0(pc)
[000130d0] 3c12                      move.w    (a2),d6
[000130d2] 4646                      not.w     d6
[000130d4] 45ea 0020                 lea.l     32(a2),a2
[000130d8] 2049                      movea.l   a1,a0
[000130da] e248                      lsr.w     #1,d0
[000130dc] 6530                      bcs.s     $0001310E
[000130de] 604e                      bra.s     $0001312E
[000130e0] 51c9 ffea                 dbf       d1,$000130CC
[000130e4] 4e75                      rts
[000130e6] 3e06                      move.w    d6,d7
[000130e8] 4647                      not.w     d7
[000130ea] ce44                      and.w     d4,d7
[000130ec] 8951                      or.w      d4,(a1)
[000130ee] bf59                      eor.w     d7,(a1)+
[000130f0] 3e02                      move.w    d2,d7
[000130f2] 6b08                      bmi.s     $000130FC
[000130f4] 5088                      addq.l    #8,a0
[000130f6] 3086                      move.w    d6,(a0)
[000130f8] 51cf fffa                 dbf       d7,$000130F4
[000130fc] 5088                      addq.l    #8,a0
[000130fe] 4844                      swap      d4
[00013100] 3e06                      move.w    d6,d7
[00013102] 4647                      not.w     d7
[00013104] ce44                      and.w     d4,d7
[00013106] 8950                      or.w      d4,(a0)
[00013108] bf50                      eor.w     d7,(a0)
[0001310a] 4844                      swap      d4
[0001310c] 4e75                      rts
[0001310e] 3e06                      move.w    d6,d7
[00013110] ce44                      and.w     d4,d7
[00013112] 8f59                      or.w      d7,(a1)+
[00013114] 3e02                      move.w    d2,d7
[00013116] 6b08                      bmi.s     $00013120
[00013118] 5088                      addq.l    #8,a0
[0001311a] 8d50                      or.w      d6,(a0)
[0001311c] 51cf fffa                 dbf       d7,$00013118
[00013120] 5088                      addq.l    #8,a0
[00013122] 4844                      swap      d4
[00013124] 3e06                      move.w    d6,d7
[00013126] ce44                      and.w     d4,d7
[00013128] 8f50                      or.w      d7,(a0)
[0001312a] 4844                      swap      d4
[0001312c] 4e75                      rts
[0001312e] 3e06                      move.w    d6,d7
[00013130] ce44                      and.w     d4,d7
[00013132] 4647                      not.w     d7
[00013134] cf59                      and.w     d7,(a1)+
[00013136] 4646                      not.w     d6
[00013138] 3e02                      move.w    d2,d7
[0001313a] 6b08                      bmi.s     $00013144
[0001313c] 5088                      addq.l    #8,a0
[0001313e] cd50                      and.w     d6,(a0)
[00013140] 51cf fffa                 dbf       d7,$0001313C
[00013144] 5088                      addq.l    #8,a0
[00013146] 4844                      swap      d4
[00013148] 4646                      not.w     d6
[0001314a] 3e06                      move.w    d6,d7
[0001314c] ce44                      and.w     d4,d7
[0001314e] 4647                      not.w     d7
[00013150] cf50                      and.w     d7,(a0)
[00013152] 4844                      swap      d4
[00013154] 4e75                      rts
[00013156] 3e06                      move.w    d6,d7
[00013158] ce44                      and.w     d4,d7
[0001315a] bf59                      eor.w     d7,(a1)+
[0001315c] 3e02                      move.w    d2,d7
[0001315e] 6b08                      bmi.s     $00013168
[00013160] 5088                      addq.l    #8,a0
[00013162] bd50                      eor.w     d6,(a0)
[00013164] 51cf fffa                 dbf       d7,$00013160
[00013168] 5088                      addq.l    #8,a0
[0001316a] 4844                      swap      d4
[0001316c] 3e06                      move.w    d6,d7
[0001316e] ce44                      and.w     d4,d7
[00013170] bf50                      eor.w     d7,(a0)
[00013172] 4844                      swap      d4
[00013174] 4e75                      rts
[00013176] 4a6e 00ca                 tst.w     202(a6)
[0001317a] 6600 fe96                 bne       $00013012
[0001317e] 3f2e 0046                 move.w    70(a6),-(a7)
[00013182] 3d6e 00be 0046            move.w    190(a6),70(a6)
[00013188] 226e 00c6                 movea.l   198(a6),a1
[0001318c] 780f                      moveq.l   #15,d4
[0001318e] c841                      and.w     d1,d4
[00013190] d844                      add.w     d4,d4
[00013192] 3c31 4000                 move.w    0(a1,d4.w),d6
[00013196] 614a                      bsr.s     $000131E2
[00013198] 3d5f 0046                 move.w    (a7)+,70(a6)
[0001319c] 4e75                      rts
[0001319e] ffff ffff 7fff 7fff       vperm     #$7FFF7FFF,e23,e23,e23
[000131a6] 3fff                      move.w    ???,???
[000131a8] 3fff                      move.w    ???,???
[000131aa] 1fff                      move.b    ???,???
[000131ac] 1fff                      move.b    ???,???
[000131ae] 0fff                      bset      d7,???
[000131b0] 0fff                      bset      d7,???
[000131b2] 07ff                      bset      d3,???
[000131b4] 07ff                      bset      d3,???
[000131b6] 03ff                      bset      d1,???
[000131b8] 03ff                      bset      d1,???
[000131ba] 01ff                      bset      d0,???
[000131bc] 01ff                      bset      d0,???
[000131be] 00ff 00ff                 cmp2.b    ???,d0 ; 68020+ only
[000131c2] 007f 007f                 ori.w     #$007F,???
[000131c6] 003f 003f                 ori.b     #$3F,???
[000131ca] 001f 001f                 ori.b     #$1F,(a7)+
[000131ce] 000f 000f                 ori.b     #$0F,a7 ; apollo only
[000131d2] 0007 0007                 ori.b     #$07,d7
[000131d6] 0003 0003                 ori.b     #$03,d3
[000131da] 0001 0001                 ori.b     #$01,d1
[000131de] 0000 0000                 ori.b     #$00,d0
[000131e2] 4a6e 01b2                 tst.w     434(a6)
[000131e6] 670a                      beq.s     $000131F2
[000131e8] 226e 01ae                 movea.l   430(a6),a1
[000131ec] c3ee 01b2                 muls.w    434(a6),d1
[000131f0] 6008                      bra.s     $000131FA
[000131f2] 2278 044e                 movea.l   ($0000044E).w,a1
[000131f6] c3f8 206e                 muls.w    ($0000206E).w,d1
[000131fa] d3c1                      adda.l    d1,a1
[000131fc] 780f                      moveq.l   #15,d4
[000131fe] c840                      and.w     d0,d4
[00013200] 7a0f                      moveq.l   #15,d5
[00013202] ca42                      and.w     d2,d5
[00013204] 0240 fff0                 andi.w    #$FFF0,d0
[00013208] e240                      asr.w     #1,d0
[0001320a] d2c0                      adda.w    d0,a1
[0001320c] d844                      add.w     d4,d4
[0001320e] d844                      add.w     d4,d4
[00013210] 283b 408c                 move.l    $0001319E(pc,d4.w),d4
[00013214] da45                      add.w     d5,d5
[00013216] da45                      add.w     d5,d5
[00013218] 2a3b 5088                 move.l    $000131A2(pc,d5.w),d5
[0001321c] 4685                      not.l     d5
[0001321e] 0242 fff0                 andi.w    #$FFF0,d2
[00013222] e242                      asr.w     #1,d2
[00013224] 9440                      sub.w     d0,d2
[00013226] e642                      asr.w     #3,d2
[00013228] 5347                      subq.w    #1,d7
[0001322a] 6700 015e                 beq       $0001338A
[0001322e] 5547                      subq.w    #2,d7
[00013230] 6700 0156                 beq       $00013388
[00013234] 3206                      move.w    d6,d1
[00013236] 4846                      swap      d6
[00013238] 3c01                      move.w    d1,d6
[0001323a] 5247                      addq.w    #1,d7
[0001323c] 677a                      beq.s     $000132B8
[0001323e] 3e2e 0046                 move.w    70(a6),d7
[00013242] 5347                      subq.w    #1,d7
[00013244] 6600 00b8                 bne       $000132FE
[00013248] 5342                      subq.w    #1,d2
[0001324a] 6b40                      bmi.s     $0001328C
[0001324c] 5342                      subq.w    #1,d2
[0001324e] 6b4c                      bmi.s     $0001329C
[00013250] bc7c ffff                 cmp.w     #$FFFF,d6
[00013254] 6612                      bne.s     $00013268
[00013256] 8999                      or.l      d4,(a1)+
[00013258] 8999                      or.l      d4,(a1)+
[0001325a] 22c6                      move.l    d6,(a1)+
[0001325c] 22c6                      move.l    d6,(a1)+
[0001325e] 51ca fffa                 dbf       d2,$0001325A
[00013262] 8b99                      or.l      d5,(a1)+
[00013264] 8b91                      or.l      d5,(a1)
[00013266] 4e75                      rts
[00013268] 2e06                      move.l    d6,d7
[0001326a] ce84                      and.l     d4,d7
[0001326c] 4684                      not.l     d4
[0001326e] c991                      and.l     d4,(a1)
[00013270] 8f99                      or.l      d7,(a1)+
[00013272] c991                      and.l     d4,(a1)
[00013274] 8f99                      or.l      d7,(a1)+
[00013276] 22c6                      move.l    d6,(a1)+
[00013278] 22c6                      move.l    d6,(a1)+
[0001327a] 51ca fffa                 dbf       d2,$00013276
[0001327e] cc85                      and.l     d5,d6
[00013280] 4685                      not.l     d5
[00013282] cb91                      and.l     d5,(a1)
[00013284] 8d99                      or.l      d6,(a1)+
[00013286] cb91                      and.l     d5,(a1)
[00013288] 8d91                      or.l      d6,(a1)
[0001328a] 4e75                      rts
[0001328c] c885                      and.l     d5,d4
[0001328e] cc84                      and.l     d4,d6
[00013290] 4684                      not.l     d4
[00013292] c991                      and.l     d4,(a1)
[00013294] 8d99                      or.l      d6,(a1)+
[00013296] c991                      and.l     d4,(a1)
[00013298] 8d91                      or.l      d6,(a1)
[0001329a] 4e75                      rts
[0001329c] 2e06                      move.l    d6,d7
[0001329e] cc84                      and.l     d4,d6
[000132a0] ce85                      and.l     d5,d7
[000132a2] 4684                      not.l     d4
[000132a4] 4685                      not.l     d5
[000132a6] c991                      and.l     d4,(a1)
[000132a8] 8d99                      or.l      d6,(a1)+
[000132aa] c991                      and.l     d4,(a1)
[000132ac] 8d99                      or.l      d6,(a1)+
[000132ae] cb91                      and.l     d5,(a1)
[000132b0] 8f99                      or.l      d7,(a1)+
[000132b2] cb91                      and.l     d5,(a1)
[000132b4] 8f91                      or.l      d7,(a1)
[000132b6] 4e75                      rts
[000132b8] 5342                      subq.w    #1,d2
[000132ba] 6b1a                      bmi.s     $000132D6
[000132bc] 5342                      subq.w    #1,d2
[000132be] 6b20                      bmi.s     $000132E0
[000132c0] c886                      and.l     d6,d4
[000132c2] b999                      eor.l     d4,(a1)+
[000132c4] b999                      eor.l     d4,(a1)+
[000132c6] bd99                      eor.l     d6,(a1)+
[000132c8] bd99                      eor.l     d6,(a1)+
[000132ca] 51ca fffa                 dbf       d2,$000132C6
[000132ce] ca86                      and.l     d6,d5
[000132d0] bb99                      eor.l     d5,(a1)+
[000132d2] bb91                      eor.l     d5,(a1)
[000132d4] 4e75                      rts
[000132d6] c885                      and.l     d5,d4
[000132d8] c886                      and.l     d6,d4
[000132da] b999                      eor.l     d4,(a1)+
[000132dc] b991                      eor.l     d4,(a1)
[000132de] 4e75                      rts
[000132e0] c886                      and.l     d6,d4
[000132e2] ca86                      and.l     d6,d5
[000132e4] b999                      eor.l     d4,(a1)+
[000132e6] b999                      eor.l     d4,(a1)+
[000132e8] bb99                      eor.l     d5,(a1)+
[000132ea] bb91                      eor.l     d5,(a1)
[000132ec] 4e75                      rts
[000132ee] 0000 0000                 ori.b     #$00,d0
[000132f2] ffff 0000 0000 ffff       vperm     #$0000FFFF,e8,e8,e8
[000132fa] ffff ffff 7000 2209       vperm     #$70002209,e23,e23,e23
[00013302] 43fa 09de                 lea.l     $00013CE2(pc),a1
[00013306] 1031 7001                 move.b    1(a1,d7.w),d0
[0001330a] 2241                      movea.l   d1,a1
[0001330c] 7203                      moveq.l   #3,d1
[0001330e] c240                      and.w     d0,d1
[00013310] d241                      add.w     d1,d1
[00013312] d241                      add.w     d1,d1
[00013314] 0240 000c                 andi.w    #$000C,d0
[00013318] 2e06                      move.l    d6,d7
[0001331a] ccbb 10d2                 and.l     $000132EE(pc,d1.w),d6
[0001331e] cebb 00ce                 and.l     $000132EE(pc,d0.w),d7
[00013322] 5342                      subq.w    #1,d2
[00013324] 6b2e                      bmi.s     $00013354
[00013326] 5342                      subq.w    #1,d2
[00013328] 6b3c                      bmi.s     $00013366
[0001332a] 2006                      move.l    d6,d0
[0001332c] 2207                      move.l    d7,d1
[0001332e] c084                      and.l     d4,d0
[00013330] c284                      and.l     d4,d1
[00013332] 4684                      not.l     d4
[00013334] c991                      and.l     d4,(a1)
[00013336] 8199                      or.l      d0,(a1)+
[00013338] c991                      and.l     d4,(a1)
[0001333a] 8399                      or.l      d1,(a1)+
[0001333c] 22c6                      move.l    d6,(a1)+
[0001333e] 22c7                      move.l    d7,(a1)+
[00013340] 51ca fffa                 dbf       d2,$0001333C
[00013344] cc85                      and.l     d5,d6
[00013346] ce85                      and.l     d5,d7
[00013348] 4685                      not.l     d5
[0001334a] cb91                      and.l     d5,(a1)
[0001334c] 8d99                      or.l      d6,(a1)+
[0001334e] cb91                      and.l     d5,(a1)
[00013350] 8f91                      or.l      d7,(a1)
[00013352] 4e75                      rts
[00013354] c885                      and.l     d5,d4
[00013356] cc84                      and.l     d4,d6
[00013358] ce84                      and.l     d4,d7
[0001335a] 4684                      not.l     d4
[0001335c] c991                      and.l     d4,(a1)
[0001335e] 8d99                      or.l      d6,(a1)+
[00013360] c991                      and.l     d4,(a1)
[00013362] 8f91                      or.l      d7,(a1)
[00013364] 4e75                      rts
[00013366] 2006                      move.l    d6,d0
[00013368] 2207                      move.l    d7,d1
[0001336a] c084                      and.l     d4,d0
[0001336c] c284                      and.l     d4,d1
[0001336e] cc85                      and.l     d5,d6
[00013370] ce85                      and.l     d5,d7
[00013372] 4684                      not.l     d4
[00013374] 4685                      not.l     d5
[00013376] c991                      and.l     d4,(a1)
[00013378] 8199                      or.l      d0,(a1)+
[0001337a] c991                      and.l     d4,(a1)
[0001337c] 8399                      or.l      d1,(a1)+
[0001337e] cb91                      and.l     d5,(a1)
[00013380] 8d99                      or.l      d6,(a1)+
[00013382] cb91                      and.l     d5,(a1)
[00013384] 8f91                      or.l      d7,(a1)
[00013386] 4e75                      rts
[00013388] 4646                      not.w     d6
[0001338a] 2f08                      move.l    a0,-(a7)
[0001338c] 5342                      subq.w    #1,d2
[0001338e] 6a04                      bpl.s     $00013394
[00013390] c845                      and.w     d5,d4
[00013392] 7a00                      moveq.l   #0,d5
[00013394] 5342                      subq.w    #1,d2
[00013396] 302e 0046                 move.w    70(a6),d0
[0001339a] 41fa 0946                 lea.l     $00013CE2(pc),a0
[0001339e] 1030 0000                 move.b    0(a0,d0.w),d0
[000133a2] 7203                      moveq.l   #3,d1
[000133a4] 2049                      movea.l   a1,a0
[000133a6] e248                      lsr.w     #1,d0
[000133a8] 6422                      bcc.s     $000133CC
[000133aa] 3e06                      move.w    d6,d7
[000133ac] ce44                      and.w     d4,d7
[000133ae] 8f59                      or.w      d7,(a1)+
[000133b0] 3e02                      move.w    d2,d7
[000133b2] 6b08                      bmi.s     $000133BC
[000133b4] 5088                      addq.l    #8,a0
[000133b6] 8d50                      or.w      d6,(a0)
[000133b8] 51cf fffa                 dbf       d7,$000133B4
[000133bc] 5088                      addq.l    #8,a0
[000133be] 3e06                      move.w    d6,d7
[000133c0] ce45                      and.w     d5,d7
[000133c2] 8f50                      or.w      d7,(a0)
[000133c4] 51c9 ffde                 dbf       d1,$000133A4
[000133c8] 205f                      movea.l   (a7)+,a0
[000133ca] 4e75                      rts
[000133cc] 3e06                      move.w    d6,d7
[000133ce] ce44                      and.w     d4,d7
[000133d0] 4647                      not.w     d7
[000133d2] cf59                      and.w     d7,(a1)+
[000133d4] 4646                      not.w     d6
[000133d6] 3e02                      move.w    d2,d7
[000133d8] 6b08                      bmi.s     $000133E2
[000133da] 5088                      addq.l    #8,a0
[000133dc] cd50                      and.w     d6,(a0)
[000133de] 51cf fffa                 dbf       d7,$000133DA
[000133e2] 5088                      addq.l    #8,a0
[000133e4] 4646                      not.w     d6
[000133e6] 3e06                      move.w    d6,d7
[000133e8] ce45                      and.w     d5,d7
[000133ea] 4647                      not.w     d7
[000133ec] cf50                      and.w     d7,(a0)
[000133ee] 51c9 ffb4                 dbf       d1,$000133A4
[000133f2] 205f                      movea.l   (a7)+,a0
[000133f4] 4e75                      rts
[000133f6] 8000                      or.b      d0,d0
[000133f8] 8000                      or.b      d0,d0
[000133fa] 4000                      negx.b    d0
[000133fc] 4000                      negx.b    d0
[000133fe] 2000                      move.l    d0,d0
[00013400] 2000                      move.l    d0,d0
[00013402] 1000                      move.b    d0,d0
[00013404] 1000                      move.b    d0,d0
[00013406] 0800 0800                 btst      #2048,d0
[0001340a] 0400 0400                 subi.b    #$00,d0
[0001340e] 0200 0200                 andi.b    #$00,d0
[00013412] 0100                      btst      d0,d0
[00013414] 0100                      btst      d0,d0
[00013416] 0080 0080 0040            ori.l     #$00800040,d0
[0001341c] 0040 0020                 ori.w     #$0020,d0
[00013420] 0020 0010                 ori.b     #$10,-(a0)
[00013424] 0010 0008                 ori.b     #$08,(a0)
[00013428] 0008 0004                 ori.b     #$04,a0 ; apollo only
[0001342c] 0004 0002                 ori.b     #$02,d4
[00013430] 0002 0001                 ori.b     #$01,d2
[00013434] 0001 9641                 ori.b     #$41,d1
[00013438] 2278 044e                 movea.l   ($0000044E).w,a1
[0001343c] 3a38 206e                 move.w    ($0000206E).w,d5
[00013440] 4a6e 01b2                 tst.w     434(a6)
[00013444] 6708                      beq.s     $0001344E
[00013446] 226e 01ae                 movea.l   430(a6),a1
[0001344a] 3a2e 01b2                 move.w    434(a6),d5
[0001344e] c3c5                      muls.w    d5,d1
[00013450] d3c1                      adda.l    d1,a1
[00013452] 740f                      moveq.l   #15,d2
[00013454] c440                      and.w     d0,d2
[00013456] 0240 fff0                 andi.w    #$FFF0,d0
[0001345a] e240                      asr.w     #1,d0
[0001345c] d2c0                      adda.w    d0,a1
[0001345e] d442                      add.w     d2,d2
[00013460] d442                      add.w     d2,d2
[00013462] 243b 2092                 move.l    $000133F6(pc,d2.w),d2
[00013466] 4a47                      tst.w     d7
[00013468] 6600 009a                 bne       $00013504
[0001346c] 5945                      subq.w    #4,d5
[0001346e] 3e2e 0046                 move.w    70(a6),d7
[00013472] 671a                      beq.s     $0001348E
[00013474] 5347                      subq.w    #1,d7
[00013476] 6624                      bne.s     $0001349C
[00013478] bc7c ffff                 cmp.w     #$FFFF,d6
[0001347c] 660c                      bne.s     $0001348A
[0001347e] 8599                      or.l      d2,(a1)+
[00013480] 8591                      or.l      d2,(a1)
[00013482] d2c5                      adda.w    d5,a1
[00013484] 51cb fff8                 dbf       d3,$0001347E
[00013488] 4e75                      rts
[0001348a] 4a46                      tst.w     d6
[0001348c] 660e                      bne.s     $0001349C
[0001348e] 4682                      not.l     d2
[00013490] c599                      and.l     d2,(a1)+
[00013492] c591                      and.l     d2,(a1)
[00013494] d2c5                      adda.w    d5,a1
[00013496] 51cb fff8                 dbf       d3,$00013490
[0001349a] 4e75                      rts
[0001349c] 5845                      addq.w    #4,d5
[0001349e] 2f08                      move.l    a0,-(a7)
[000134a0] 3202                      move.w    d2,d1
[000134a2] 4641                      not.w     d1
[000134a4] 302e 0046                 move.w    70(a6),d0
[000134a8] 2e09                      move.l    a1,d7
[000134aa] 43fa 0836                 lea.l     $00013CE2(pc),a1
[000134ae] 1031 0000                 move.b    0(a1,d0.w),d0
[000134b2] 2247                      movea.l   d7,a1
[000134b4] 7e03                      moveq.l   #3,d7
[000134b6] 2049                      movea.l   a1,a0
[000134b8] 3803                      move.w    d3,d4
[000134ba] e248                      lsr.w     #1,d0
[000134bc] 6426                      bcc.s     $000134E4
[000134be] 4847                      swap      d7
[000134c0] 3e06                      move.w    d6,d7
[000134c2] e35f                      rol.w     #1,d7
[000134c4] 6414                      bcc.s     $000134DA
[000134c6] 8550                      or.w      d2,(a0)
[000134c8] d0c5                      adda.w    d5,a0
[000134ca] 51cc fff6                 dbf       d4,$000134C2
[000134ce] 4847                      swap      d7
[000134d0] 5489                      addq.l    #2,a1
[000134d2] 51cf ffe2                 dbf       d7,$000134B6
[000134d6] 205f                      movea.l   (a7)+,a0
[000134d8] 4e75                      rts
[000134da] c350                      and.w     d1,(a0)
[000134dc] d0c5                      adda.w    d5,a0
[000134de] 51cc ffe2                 dbf       d4,$000134C2
[000134e2] 60ea                      bra.s     $000134CE
[000134e4] c350                      and.w     d1,(a0)
[000134e6] d0c5                      adda.w    d5,a0
[000134e8] 51cc fffa                 dbf       d4,$000134E4
[000134ec] 4847                      swap      d7
[000134ee] 60de                      bra.s     $000134CE
[000134f0] c350                      and.w     d1,(a0)
[000134f2] d0c5                      adda.w    d5,a0
[000134f4] 51cc fffa                 dbf       d4,$000134F0
[000134f8] 4847                      swap      d7
[000134fa] 5489                      addq.l    #2,a1
[000134fc] 51cf ffb8                 dbf       d7,$000134B6
[00013500] 205f                      movea.l   (a7)+,a0
[00013502] 4e75                      rts
[00013504] 5547                      subq.w    #2,d7
[00013506] 6b3c                      bmi.s     $00013544
[00013508] 6e38                      bgt.s     $00013542
[0001350a] bc7c aaaa                 cmp.w     #$AAAA,d6
[0001350e] 6720                      beq.s     $00013530
[00013510] bc7c 5555                 cmp.w     #$5555,d6
[00013514] 6712                      beq.s     $00013528
[00013516] e35e                      rol.w     #1,d6
[00013518] 6406                      bcc.s     $00013520
[0001351a] b591                      eor.l     d2,(a1)
[0001351c] b5a9 0004                 eor.l     d2,4(a1)
[00013520] d2c5                      adda.w    d5,a1
[00013522] 51cb fff2                 dbf       d3,$00013516
[00013526] 4e75                      rts
[00013528] d2c5                      adda.w    d5,a1
[0001352a] 51cb 0004                 dbf       d3,$00013530
[0001352e] 4e75                      rts
[00013530] da45                      add.w     d5,d5
[00013532] 5945                      subq.w    #4,d5
[00013534] e24b                      lsr.w     #1,d3
[00013536] b599                      eor.l     d2,(a1)+
[00013538] b591                      eor.l     d2,(a1)
[0001353a] d2c5                      adda.w    d5,a1
[0001353c] 51cb fff8                 dbf       d3,$00013536
[00013540] 4e75                      rts
[00013542] 4646                      not.w     d6
[00013544] 2f08                      move.l    a0,-(a7)
[00013546] 3202                      move.w    d2,d1
[00013548] 4641                      not.w     d1
[0001354a] 302e 0046                 move.w    70(a6),d0
[0001354e] 2e09                      move.l    a1,d7
[00013550] 43fa 0790                 lea.l     $00013CE2(pc),a1
[00013554] 1031 0000                 move.b    0(a1,d0.w),d0
[00013558] 2247                      movea.l   d7,a1
[0001355a] 7e03                      moveq.l   #3,d7
[0001355c] 2049                      movea.l   a1,a0
[0001355e] 3803                      move.w    d3,d4
[00013560] 4847                      swap      d7
[00013562] 3e06                      move.w    d6,d7
[00013564] e248                      lsr.w     #1,d0
[00013566] 6418                      bcc.s     $00013580
[00013568] e35f                      rol.w     #1,d7
[0001356a] 6402                      bcc.s     $0001356E
[0001356c] 8550                      or.w      d2,(a0)
[0001356e] d0c5                      adda.w    d5,a0
[00013570] 51cc fff6                 dbf       d4,$00013568
[00013574] 4847                      swap      d7
[00013576] 5489                      addq.l    #2,a1
[00013578] 51cf ffe2                 dbf       d7,$0001355C
[0001357c] 205f                      movea.l   (a7)+,a0
[0001357e] 4e75                      rts
[00013580] e35f                      rol.w     #1,d7
[00013582] 6402                      bcc.s     $00013586
[00013584] c350                      and.w     d1,(a0)
[00013586] d0c5                      adda.w    d5,a0
[00013588] 51cc fff6                 dbf       d4,$00013580
[0001358c] 4847                      swap      d7
[0001358e] 5489                      addq.l    #2,a1
[00013590] 51cf ffca                 dbf       d7,$0001355C
[00013594] 205f                      movea.l   (a7)+,a0
[00013596] 4e75                      rts
[00013598] 4e75                      rts
[0001359a] 2278 044e                 movea.l   ($0000044E).w,a1
[0001359e] 3a38 206e                 move.w    ($0000206E).w,d5
[000135a2] 4a6e 01b2                 tst.w     434(a6)
[000135a6] 6708                      beq.s     $000135B0
[000135a8] 226e 01ae                 movea.l   430(a6),a1
[000135ac] 3a2e 01b2                 move.w    434(a6),d5
[000135b0] 3805                      move.w    d5,d4
[000135b2] c9c1                      muls.w    d1,d4
[000135b4] d3c4                      adda.l    d4,a1
[000135b6] 78f0                      moveq.l   #-16,d4
[000135b8] c840                      and.w     d0,d4
[000135ba] e244                      asr.w     #1,d4
[000135bc] d2c4                      adda.w    d4,a1
[000135be] 3806                      move.w    d6,d4
[000135c0] 4846                      swap      d6
[000135c2] 3c04                      move.w    d4,d6
[000135c4] 780f                      moveq.l   #15,d4
[000135c6] c840                      and.w     d0,d4
[000135c8] 9440                      sub.w     d0,d2
[000135ca] 6bcc                      bmi.s     $00013598
[000135cc] 9641                      sub.w     d1,d3
[000135ce] 6a04                      bpl.s     $000135D4
[000135d0] 4443                      neg.w     d3
[000135d2] 4445                      neg.w     d5
[000135d4] b443                      cmp.w     d3,d2
[000135d6] 6d00 0204                 blt       $000137DC
[000135da] 3004                      move.w    d4,d0
[000135dc] 283c 8000 8000            move.l    #$80008000,d4
[000135e2] e0ac                      lsr.l     d0,d4
[000135e4] 3002                      move.w    d2,d0
[000135e6] d06e 004e                 add.w     78(a6),d0
[000135ea] 6bac                      bmi.s     $00013598
[000135ec] d643                      add.w     d3,d3
[000135ee] 3203                      move.w    d3,d1
[000135f0] 9642                      sub.w     d2,d3
[000135f2] 4442                      neg.w     d2
[000135f4] d443                      add.w     d3,d2
[000135f6] 5145                      subq.w    #8,d5
[000135f8] 4a47                      tst.w     d7
[000135fa] 6600 00c6                 bne       $000136C2
[000135fe] 3e2e 0046                 move.w    70(a6),d7
[00013602] 5347                      subq.w    #1,d7
[00013604] 6608                      bne.s     $0001360E
[00013606] 4646                      not.w     d6
[00013608] 6700 009e                 beq       $000136A8
[0001360c] 4646                      not.w     d6
[0001360e] 48e7 0090                 movem.l   a0/a3,-(a7)
[00013612] 3645                      movea.w   d5,a3
[00013614] 41fa 06cc                 lea.l     $00013CE2(pc),a0
[00013618] 1a30 7001                 move.b    1(a0,d7.w),d5
[0001361c] 3041                      movea.w   d1,a0
[0001361e] 7203                      moveq.l   #3,d1
[00013620] c245                      and.w     d5,d1
[00013622] d241                      add.w     d1,d1
[00013624] d241                      add.w     d1,d1
[00013626] 0245 000c                 andi.w    #$000C,d5
[0001362a] 2e06                      move.l    d6,d7
[0001362c] ccbb 1008                 and.l     $00013636(pc,d1.w),d6
[00013630] cebb 5004                 and.l     $00013636(pc,d5.w),d7
[00013634] 6032                      bra.s     $00013668
[00013636] 0000 0000                 ori.b     #$00,d0
[0001363a] ffff 0000 0000 ffff       vperm     #$0000FFFF,e8,e8,e8
[00013642] ffff ffff d642 cb91       vperm     #$D642CB91,e23,e23,e23
[0001364a] 2205                      move.l    d5,d1
[0001364c] 4681                      not.l     d1
[0001364e] c286                      and.l     d6,d1
[00013650] 8399                      or.l      d1,(a1)+
[00013652] cb91                      and.l     d5,(a1)
[00013654] 4685                      not.l     d5
[00013656] ca87                      and.l     d7,d5
[00013658] 8b99                      or.l      d5,(a1)+
[0001365a] d2cb                      adda.w    a3,a1
[0001365c] e29c                      ror.l     #1,d4
[0001365e] 55c8 0008                 dbcs      d0,$00013668
[00013662] 5089                      addq.l    #8,a1
[00013664] 5340                      subq.w    #1,d0
[00013666] 6b26                      bmi.s     $0001368E
[00013668] 7aff                      moveq.l   #-1,d5
[0001366a] b985                      eor.l     d4,d5
[0001366c] 4a43                      tst.w     d3
[0001366e] 6ad6                      bpl.s     $00013646
[00013670] d648                      add.w     a0,d3
[00013672] e29c                      ror.l     #1,d4
[00013674] 55c8 fff4                 dbcs      d0,$0001366A
[00013678] cb91                      and.l     d5,(a1)
[0001367a] 2205                      move.l    d5,d1
[0001367c] 4681                      not.l     d1
[0001367e] c286                      and.l     d6,d1
[00013680] 8399                      or.l      d1,(a1)+
[00013682] cb91                      and.l     d5,(a1)
[00013684] 4685                      not.l     d5
[00013686] ca87                      and.l     d7,d5
[00013688] 8b99                      or.l      d5,(a1)+
[0001368a] 5340                      subq.w    #1,d0
[0001368c] 6ada                      bpl.s     $00013668
[0001368e] 4cdf 0900                 movem.l   (a7)+,a0/a3
[00013692] 4e75                      rts
[00013694] d642                      add.w     d2,d3
[00013696] 8f99                      or.l      d7,(a1)+
[00013698] 8f99                      or.l      d7,(a1)+
[0001369a] d2c5                      adda.w    d5,a1
[0001369c] e29c                      ror.l     #1,d4
[0001369e] 55c8 0008                 dbcs      d0,$000136A8
[000136a2] 5089                      addq.l    #8,a1
[000136a4] 5340                      subq.w    #1,d0
[000136a6] 6b18                      bmi.s     $000136C0
[000136a8] 7e00                      moveq.l   #0,d7
[000136aa] 8e84                      or.l      d4,d7
[000136ac] 4a43                      tst.w     d3
[000136ae] 6ae4                      bpl.s     $00013694
[000136b0] d641                      add.w     d1,d3
[000136b2] e29c                      ror.l     #1,d4
[000136b4] 55c8 fff4                 dbcs      d0,$000136AA
[000136b8] 8f99                      or.l      d7,(a1)+
[000136ba] 8f99                      or.l      d7,(a1)+
[000136bc] 5340                      subq.w    #1,d0
[000136be] 6ae8                      bpl.s     $000136A8
[000136c0] 4e75                      rts
[000136c2] 5547                      subq.w    #2,d7
[000136c4] 6b72                      bmi.s     $00013738
[000136c6] 6e6e                      bgt.s     $00013736
[000136c8] 6016                      bra.s     $000136E0
[000136ca] d642                      add.w     d2,d3
[000136cc] ce86                      and.l     d6,d7
[000136ce] bf99                      eor.l     d7,(a1)+
[000136d0] bf99                      eor.l     d7,(a1)+
[000136d2] d2c5                      adda.w    d5,a1
[000136d4] e29c                      ror.l     #1,d4
[000136d6] 55c8 0008                 dbcs      d0,$000136E0
[000136da] 5089                      addq.l    #8,a1
[000136dc] 5340                      subq.w    #1,d0
[000136de] 6b1a                      bmi.s     $000136FA
[000136e0] 7e00                      moveq.l   #0,d7
[000136e2] 8e84                      or.l      d4,d7
[000136e4] 4a43                      tst.w     d3
[000136e6] 6ae2                      bpl.s     $000136CA
[000136e8] d641                      add.w     d1,d3
[000136ea] e29c                      ror.l     #1,d4
[000136ec] 55c8 fff4                 dbcs      d0,$000136E2
[000136f0] ce86                      and.l     d6,d7
[000136f2] bf99                      eor.l     d7,(a1)+
[000136f4] bf99                      eor.l     d7,(a1)+
[000136f6] 5340                      subq.w    #1,d0
[000136f8] 6ae6                      bpl.s     $000136E0
[000136fa] 4e75                      rts
[000136fc] d642                      add.w     d2,d3
[000136fe] ce86                      and.l     d6,d7
[00013700] 2a07                      move.l    d7,d5
[00013702] 4687                      not.l     d7
[00013704] 4e90                      jsr       (a0)
[00013706] d2cb                      adda.w    a3,a1
[00013708] e29c                      ror.l     #1,d4
[0001370a] 55c8 0008                 dbcs      d0,$00013714
[0001370e] 5089                      addq.l    #8,a1
[00013710] 5340                      subq.w    #1,d0
[00013712] 6b1c                      bmi.s     $00013730
[00013714] 7e00                      moveq.l   #0,d7
[00013716] 8e84                      or.l      d4,d7
[00013718] 4a43                      tst.w     d3
[0001371a] 6ae0                      bpl.s     $000136FC
[0001371c] d641                      add.w     d1,d3
[0001371e] e29c                      ror.l     #1,d4
[00013720] 55c8 fff4                 dbcs      d0,$00013716
[00013724] ce86                      and.l     d6,d7
[00013726] 2a07                      move.l    d7,d5
[00013728] 4687                      not.l     d7
[0001372a] 4e90                      jsr       (a0)
[0001372c] 5340                      subq.w    #1,d0
[0001372e] 6ae4                      bpl.s     $00013714
[00013730] 4cdf 0900                 movem.l   (a7)+,a0/a3
[00013734] 4e75                      rts
[00013736] 4686                      not.l     d6
[00013738] 48e7 0090                 movem.l   a0/a3,-(a7)
[0001373c] 3645                      movea.w   d5,a3
[0001373e] 3e2e 0046                 move.w    70(a6),d7
[00013742] 41fa 0048                 lea.l     $0001378C(pc),a0
[00013746] 1e30 7000                 move.b    0(a0,d7.w),d7
[0001374a] 4887                      ext.w     d7
[0001374c] d0c7                      adda.w    d7,a0
[0001374e] 60c4                      bra.s     $00013714
[00013750] cf99                      and.l     d7,(a1)+
[00013752] cf99                      and.l     d7,(a1)+
[00013754] 4e75                      rts
[00013756] 8b99                      or.l      d5,(a1)+
[00013758] 8b99                      or.l      d5,(a1)+
[0001375a] 4e75                      rts
[0001375c] 8b59                      or.w      d5,(a1)+
[0001375e] cf59                      and.w     d7,(a1)+
[00013760] cf99                      and.l     d7,(a1)+
[00013762] 4e75                      rts
[00013764] cf59                      and.w     d7,(a1)+
[00013766] 8b59                      or.w      d5,(a1)+
[00013768] cf99                      and.l     d7,(a1)+
[0001376a] 4e75                      rts
[0001376c] cf99                      and.l     d7,(a1)+
[0001376e] 8b59                      or.w      d5,(a1)+
[00013770] cf59                      and.w     d7,(a1)+
[00013772] 4e75                      rts
[00013774] cf59                      and.w     d7,(a1)+
[00013776] 8b99                      or.l      d5,(a1)+
[00013778] cf59                      and.w     d7,(a1)+
[0001377a] 4e75                      rts
[0001377c] 8b99                      or.l      d5,(a1)+
[0001377e] cf99                      and.l     d7,(a1)+
[00013780] 4e75                      rts
[00013782] 8b59                      or.w      d5,(a1)+
[00013784] cf59                      and.w     d7,(a1)+
[00013786] 8b59                      or.w      d5,(a1)+
[00013788] cf59                      and.w     d7,(a1)+
[0001378a] 4e75                      rts
[0001378c] c4ca                      mulu.w    a2,d2
[0001378e] d0d8                      adda.w    (a0)+,a0
[00013790] e0e8 f0f6                 asr.w     -3850(a0)
[00013794] 1018                      move.b    (a0)+,d0
[00013796] 2028 3238                 move.l    12856(a0),d0
[0001379a] 4048                      negx.w    a0 ; apollo only
[0001379c] 8b99                      or.l      d5,(a1)+
[0001379e] 8b59                      or.w      d5,(a1)+
[000137a0] cf59                      and.w     d7,(a1)+
[000137a2] 4e75                      rts
[000137a4] cf99                      and.l     d7,(a1)+
[000137a6] cf59                      and.w     d7,(a1)+
[000137a8] 8b59                      or.w      d5,(a1)+
[000137aa] 4e75                      rts
[000137ac] 8b59                      or.w      d5,(a1)+
[000137ae] cf99                      and.l     d7,(a1)+
[000137b0] 8b59                      or.w      d5,(a1)+
[000137b2] 4e75                      rts
[000137b4] cf59                      and.w     d7,(a1)+
[000137b6] 8b59                      or.w      d5,(a1)+
[000137b8] cf59                      and.w     d7,(a1)+
[000137ba] 8b59                      or.w      d5,(a1)+
[000137bc] 4e75                      rts
[000137be] cf99                      and.l     d7,(a1)+
[000137c0] 8b99                      or.l      d5,(a1)+
[000137c2] 4e75                      rts
[000137c4] cf59                      and.w     d7,(a1)+
[000137c6] 8b59                      or.w      d5,(a1)+
[000137c8] 8b99                      or.l      d5,(a1)+
[000137ca] 4e75                      rts
[000137cc] 8b99                      or.l      d5,(a1)+
[000137ce] cf59                      and.w     d7,(a1)+
[000137d0] 8b59                      or.w      d5,(a1)+
[000137d2] 4e75                      rts
[000137d4] 8b59                      or.w      d5,(a1)+
[000137d6] cf59                      and.w     d7,(a1)+
[000137d8] 8b99                      or.l      d5,(a1)+
[000137da] 4e75                      rts
[000137dc] 3003                      move.w    d3,d0
[000137de] d06e 004e                 add.w     78(a6),d0
[000137e2] 6bf6                      bmi.s     $000137DA
[000137e4] d442                      add.w     d2,d2
[000137e6] 3202                      move.w    d2,d1
[000137e8] 9243                      sub.w     d3,d1
[000137ea] 9243                      sub.w     d3,d1
[000137ec] d641                      add.w     d1,d3
[000137ee] e97e                      rol.w     d4,d6
[000137f0] 2f0b                      move.l    a3,-(a7)
[000137f2] 3645                      movea.w   d5,a3
[000137f4] 2a3c 8000 8000            move.l    #$80008000,d5
[000137fa] e8ad                      lsr.l     d4,d5
[000137fc] 4a47                      tst.w     d7
[000137fe] 6600 0084                 bne       $00013884
[00013802] 514b                      subq.w    #8,a3
[00013804] 3e2e 0046                 move.w    70(a6),d7
[00013808] 5347                      subq.w    #1,d7
[0001380a] 6606                      bne.s     $00013812
[0001380c] 4646                      not.w     d6
[0001380e] 6760                      beq.s     $00013870
[00013810] 4646                      not.w     d6
[00013812] 380b                      move.w    a3,d4
[00013814] 47fa ff76                 lea.l     $0001378C(pc),a3
[00013818] 1e33 7001                 move.b    1(a3,d7.w),d7
[0001381c] 4887                      ext.w     d7
[0001381e] d6c7                      adda.w    d7,a3
[00013820] 600e                      bra.s     $00013830
[00013822] d641                      add.w     d1,d3
[00013824] e29d                      ror.l     #1,d5
[00013826] 55c8 0008                 dbcs      d0,$00013830
[0001382a] 5089                      addq.l    #8,a1
[0001382c] 5340                      subq.w    #1,d0
[0001382e] 6b16                      bmi.s     $00013846
[00013830] e35e                      rol.w     #1,d6
[00013832] 6416                      bcc.s     $0001384A
[00013834] 2e05                      move.l    d5,d7
[00013836] 4687                      not.l     d7
[00013838] 4e93                      jsr       (a3)
[0001383a] d2c4                      adda.w    d4,a1
[0001383c] 4a43                      tst.w     d3
[0001383e] 6ae2                      bpl.s     $00013822
[00013840] d642                      add.w     d2,d3
[00013842] 51c8 ffec                 dbf       d0,$00013830
[00013846] 265f                      movea.l   (a7)+,a3
[00013848] 4e75                      rts
[0001384a] 2e05                      move.l    d5,d7
[0001384c] 4687                      not.l     d7
[0001384e] cf99                      and.l     d7,(a1)+
[00013850] cf99                      and.l     d7,(a1)+
[00013852] d2c4                      adda.w    d4,a1
[00013854] 4a43                      tst.w     d3
[00013856] 6aca                      bpl.s     $00013822
[00013858] d642                      add.w     d2,d3
[0001385a] 51c8 ffd4                 dbf       d0,$00013830
[0001385e] 265f                      movea.l   (a7)+,a3
[00013860] 4e75                      rts
[00013862] d641                      add.w     d1,d3
[00013864] e29d                      ror.l     #1,d5
[00013866] 55c8 0008                 dbcs      d0,$00013870
[0001386a] 5089                      addq.l    #8,a1
[0001386c] 5340                      subq.w    #1,d0
[0001386e] 6b10                      bmi.s     $00013880
[00013870] 8b99                      or.l      d5,(a1)+
[00013872] 8b99                      or.l      d5,(a1)+
[00013874] d2cb                      adda.w    a3,a1
[00013876] 4a43                      tst.w     d3
[00013878] 6ae8                      bpl.s     $00013862
[0001387a] d642                      add.w     d2,d3
[0001387c] 51c8 fff2                 dbf       d0,$00013870
[00013880] 265f                      movea.l   (a7)+,a3
[00013882] 4e75                      rts
[00013884] 5547                      subq.w    #2,d7
[00013886] 6712                      beq.s     $0001389A
[00013888] 6b2c                      bmi.s     $000138B6
[0001388a] 6028                      bra.s     $000138B4
[0001388c] d641                      add.w     d1,d3
[0001388e] e29d                      ror.l     #1,d5
[00013890] 55c8 0008                 dbcs      d0,$0001389A
[00013894] 5089                      addq.l    #8,a1
[00013896] 5340                      subq.w    #1,d0
[00013898] 6b16                      bmi.s     $000138B0
[0001389a] e35e                      rol.w     #1,d6
[0001389c] 6406                      bcc.s     $000138A4
[0001389e] bb91                      eor.l     d5,(a1)
[000138a0] bba9 0004                 eor.l     d5,4(a1)
[000138a4] d2cb                      adda.w    a3,a1
[000138a6] 4a43                      tst.w     d3
[000138a8] 6ae2                      bpl.s     $0001388C
[000138aa] d642                      add.w     d2,d3
[000138ac] 51c8 ffec                 dbf       d0,$0001389A
[000138b0] 265f                      movea.l   (a7)+,a3
[000138b2] 4e75                      rts
[000138b4] 4646                      not.w     d6
[000138b6] 380b                      move.w    a3,d4
[000138b8] 47fa fed2                 lea.l     $0001378C(pc),a3
[000138bc] 3e2e 0046                 move.w    70(a6),d7
[000138c0] 1e33 7000                 move.b    0(a3,d7.w),d7
[000138c4] 4887                      ext.w     d7
[000138c6] d6c7                      adda.w    d7,a3
[000138c8] 600e                      bra.s     $000138D8
[000138ca] d641                      add.w     d1,d3
[000138cc] e29d                      ror.l     #1,d5
[000138ce] 55c8 0008                 dbcs      d0,$000138D8
[000138d2] 5089                      addq.l    #8,a1
[000138d4] 5340                      subq.w    #1,d0
[000138d6] 6b18                      bmi.s     $000138F0
[000138d8] e35e                      rol.w     #1,d6
[000138da] 6408                      bcc.s     $000138E4
[000138dc] 2e05                      move.l    d5,d7
[000138de] 4687                      not.l     d7
[000138e0] 4e93                      jsr       (a3)
[000138e2] 5189                      subq.l    #8,a1
[000138e4] d2c4                      adda.w    d4,a1
[000138e6] 4a43                      tst.w     d3
[000138e8] 6ae0                      bpl.s     $000138CA
[000138ea] d642                      add.w     d2,d3
[000138ec] 51c8 ffea                 dbf       d0,$000138D8
[000138f0] 265f                      movea.l   (a7)+,a3
[000138f2] 4e75                      rts
[000138f4] 4e75                      rts
[000138f6] 0c6e 0001 003c            cmpi.w    #$0001,60(a6)
[000138fc] 6e08                      bgt.s     $00013906
[000138fe] 0c6e 0001 0064            cmpi.w    #$0001,100(a6)
[00013904] 675a                      beq.s     $00013960
[00013906] 2278 044e                 movea.l   ($0000044E).w,a1
[0001390a] 3678 206e                 movea.w   ($0000206E).w,a3
[0001390e] 4a6e 01b2                 tst.w     434(a6)
[00013912] 6708                      beq.s     $0001391C
[00013914] 226e 01ae                 movea.l   430(a6),a1
[00013918] 366e 01b2                 movea.w   434(a6),a3
[0001391c] 2d48 01c2                 move.l    a0,450(a6)
[00013920] 2d49 01d6                 move.l    a1,470(a6)
[00013924] 3d4a 01c6                 move.w    a2,454(a6)
[00013928] 3d4b 01da                 move.w    a3,474(a6)
[0001392c] 3d7c 0000 01c8            move.w    #$0000,456(a6)
[00013932] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00013938] 426e 01ec                 clr.w     492(a6)
[0001393c] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[00013942] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[00013948] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[0001394e] 6600 ca3a                 bne       $0001038A
[00013952] 426e 01ea                 clr.w     490(a6)
[00013956] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[0001395c] 6000 ca2c                 bra       $0001038A
[00013960] 2278 044e                 movea.l   ($0000044E).w,a1
[00013964] 3678 206e                 movea.w   ($0000206E).w,a3
[00013968] 4a6e 01b2                 tst.w     434(a6)
[0001396c] 6708                      beq.s     $00013976
[0001396e] 226e 01ae                 movea.l   430(a6),a1
[00013972] 366e 01b2                 movea.w   434(a6),a3
[00013976] 3c0a                      move.w    a2,d6
[00013978] c2c6                      mulu.w    d6,d1
[0001397a] d1c1                      adda.l    d1,a0
[0001397c] 3200                      move.w    d0,d1
[0001397e] e849                      lsr.w     #4,d1
[00013980] d241                      add.w     d1,d1
[00013982] d0c1                      adda.w    d1,a0
[00013984] 320b                      move.w    a3,d1
[00013986] c2c3                      mulu.w    d3,d1
[00013988] d3c1                      adda.l    d1,a1
[0001398a] 72f0                      moveq.l   #-16,d1
[0001398c] c242                      and.w     d2,d1
[0001398e] e241                      asr.w     #1,d1
[00013990] d2c1                      adda.w    d1,a1
[00013992] 7c0f                      moveq.l   #15,d6
[00013994] c046                      and.w     d6,d0
[00013996] 3602                      move.w    d2,d3
[00013998] c646                      and.w     d6,d3
[0001399a] 9043                      sub.w     d3,d0
[0001399c] 3202                      move.w    d2,d1
[0001399e] c246                      and.w     d6,d1
[000139a0] d244                      add.w     d4,d1
[000139a2] e849                      lsr.w     #4,d1
[000139a4] d842                      add.w     d2,d4
[000139a6] c544                      exg       d2,d4
[000139a8] 4642                      not.w     d2
[000139aa] c446                      and.w     d6,d2
[000139ac] 76ff                      moveq.l   #-1,d3
[000139ae] e56b                      lsl.w     d2,d3
[000139b0] 74ff                      moveq.l   #-1,d2
[000139b2] c846                      and.w     d6,d4
[000139b4] e86a                      lsr.w     d4,d2
[000139b6] 3801                      move.w    d1,d4
[000139b8] 6606                      bne.s     $000139C0
[000139ba] c443                      and.w     d3,d2
[000139bc] 7600                      moveq.l   #0,d3
[000139be] 7801                      moveq.l   #1,d4
[000139c0] 5541                      subq.w    #2,d1
[000139c2] d844                      add.w     d4,d4
[000139c4] 94c4                      suba.w    d4,a2
[000139c6] 5444                      addq.w    #2,d4
[000139c8] d844                      add.w     d4,d4
[000139ca] d844                      add.w     d4,d4
[000139cc] 96c4                      suba.w    d4,a3
[000139ce] 4a40                      tst.w     d0
[000139d0] 6722                      beq.s     $000139F4
[000139d2] 6d0e                      blt.s     $000139E2
[000139d4] 0c40 0008                 cmpi.w    #$0008,d0
[000139d8] 6f00 00c4                 ble       $00013A9E
[000139dc] 5340                      subq.w    #1,d0
[000139de] bd40                      eor.w     d6,d0
[000139e0] 6062                      bra.s     $00013A44
[000139e2] 4440                      neg.w     d0
[000139e4] 5588                      subq.l    #2,a0
[000139e6] 0c40 0008                 cmpi.w    #$0008,d0
[000139ea] 6f58                      ble.s     $00013A44
[000139ec] 5340                      subq.w    #1,d0
[000139ee] bd40                      eor.w     d6,d0
[000139f0] 6000 00ac                 bra       $00013A9E
[000139f4] 4a6e 003c                 tst.w     60(a6)
[000139f8] 6600 0104                 bne       $00013AFE
[000139fc] 3c18                      move.w    (a0)+,d6
[000139fe] 4646                      not.w     d6
[00013a00] cc42                      and.w     d2,d6
[00013a02] 8551                      or.w      d2,(a1)
[00013a04] bd59                      eor.w     d6,(a1)+
[00013a06] 8551                      or.w      d2,(a1)
[00013a08] bd59                      eor.w     d6,(a1)+
[00013a0a] 8551                      or.w      d2,(a1)
[00013a0c] bd59                      eor.w     d6,(a1)+
[00013a0e] 8551                      or.w      d2,(a1)
[00013a10] bd59                      eor.w     d6,(a1)+
[00013a12] 3801                      move.w    d1,d4
[00013a14] 6b0e                      bmi.s     $00013A24
[00013a16] 3c18                      move.w    (a0)+,d6
[00013a18] 32c6                      move.w    d6,(a1)+
[00013a1a] 32c6                      move.w    d6,(a1)+
[00013a1c] 32c6                      move.w    d6,(a1)+
[00013a1e] 32c6                      move.w    d6,(a1)+
[00013a20] 51cc fff4                 dbf       d4,$00013A16
[00013a24] 3c10                      move.w    (a0),d6
[00013a26] 4646                      not.w     d6
[00013a28] cc43                      and.w     d3,d6
[00013a2a] 8751                      or.w      d3,(a1)
[00013a2c] bd59                      eor.w     d6,(a1)+
[00013a2e] 8751                      or.w      d3,(a1)
[00013a30] bd59                      eor.w     d6,(a1)+
[00013a32] 8751                      or.w      d3,(a1)
[00013a34] bd59                      eor.w     d6,(a1)+
[00013a36] 8751                      or.w      d3,(a1)
[00013a38] bd59                      eor.w     d6,(a1)+
[00013a3a] d0ca                      adda.w    a2,a0
[00013a3c] d2cb                      adda.w    a3,a1
[00013a3e] 51cd ffbc                 dbf       d5,$000139FC
[00013a42] 4e75                      rts
[00013a44] 4a6e 003c                 tst.w     60(a6)
[00013a48] 6600 00e8                 bne       $00013B32
[00013a4c] 2c10                      move.l    (a0),d6
[00013a4e] 5488                      addq.l    #2,a0
[00013a50] e0be                      ror.l     d0,d6
[00013a52] 4646                      not.w     d6
[00013a54] cc42                      and.w     d2,d6
[00013a56] 8551                      or.w      d2,(a1)
[00013a58] bd59                      eor.w     d6,(a1)+
[00013a5a] 8551                      or.w      d2,(a1)
[00013a5c] bd59                      eor.w     d6,(a1)+
[00013a5e] 8551                      or.w      d2,(a1)
[00013a60] bd59                      eor.w     d6,(a1)+
[00013a62] 8551                      or.w      d2,(a1)
[00013a64] bd59                      eor.w     d6,(a1)+
[00013a66] 3801                      move.w    d1,d4
[00013a68] 6b12                      bmi.s     $00013A7C
[00013a6a] 2c10                      move.l    (a0),d6
[00013a6c] 5488                      addq.l    #2,a0
[00013a6e] e0be                      ror.l     d0,d6
[00013a70] 32c6                      move.w    d6,(a1)+
[00013a72] 32c6                      move.w    d6,(a1)+
[00013a74] 32c6                      move.w    d6,(a1)+
[00013a76] 32c6                      move.w    d6,(a1)+
[00013a78] 51cc fff0                 dbf       d4,$00013A6A
[00013a7c] 2c10                      move.l    (a0),d6
[00013a7e] e0be                      ror.l     d0,d6
[00013a80] 4646                      not.w     d6
[00013a82] cc43                      and.w     d3,d6
[00013a84] 8751                      or.w      d3,(a1)
[00013a86] bd59                      eor.w     d6,(a1)+
[00013a88] 8751                      or.w      d3,(a1)
[00013a8a] bd59                      eor.w     d6,(a1)+
[00013a8c] 8751                      or.w      d3,(a1)
[00013a8e] bd59                      eor.w     d6,(a1)+
[00013a90] 8751                      or.w      d3,(a1)
[00013a92] bd59                      eor.w     d6,(a1)+
[00013a94] d0ca                      adda.w    a2,a0
[00013a96] d2cb                      adda.w    a3,a1
[00013a98] 51cd ffb2                 dbf       d5,$00013A4C
[00013a9c] 4e75                      rts
[00013a9e] 4a6e 003c                 tst.w     60(a6)
[00013aa2] 6600 00cc                 bne       $00013B70
[00013aa6] 2c10                      move.l    (a0),d6
[00013aa8] 5488                      addq.l    #2,a0
[00013aaa] 4846                      swap      d6
[00013aac] e1be                      rol.l     d0,d6
[00013aae] 4646                      not.w     d6
[00013ab0] cc42                      and.w     d2,d6
[00013ab2] 8551                      or.w      d2,(a1)
[00013ab4] bd59                      eor.w     d6,(a1)+
[00013ab6] 8551                      or.w      d2,(a1)
[00013ab8] bd59                      eor.w     d6,(a1)+
[00013aba] 8551                      or.w      d2,(a1)
[00013abc] bd59                      eor.w     d6,(a1)+
[00013abe] 8551                      or.w      d2,(a1)
[00013ac0] bd59                      eor.w     d6,(a1)+
[00013ac2] 3801                      move.w    d1,d4
[00013ac4] 6b14                      bmi.s     $00013ADA
[00013ac6] 2c10                      move.l    (a0),d6
[00013ac8] 5488                      addq.l    #2,a0
[00013aca] 4846                      swap      d6
[00013acc] e1be                      rol.l     d0,d6
[00013ace] 32c6                      move.w    d6,(a1)+
[00013ad0] 32c6                      move.w    d6,(a1)+
[00013ad2] 32c6                      move.w    d6,(a1)+
[00013ad4] 32c6                      move.w    d6,(a1)+
[00013ad6] 51cc ffee                 dbf       d4,$00013AC6
[00013ada] 2c10                      move.l    (a0),d6
[00013adc] 4846                      swap      d6
[00013ade] e1be                      rol.l     d0,d6
[00013ae0] 4646                      not.w     d6
[00013ae2] cc43                      and.w     d3,d6
[00013ae4] 8751                      or.w      d3,(a1)
[00013ae6] bd59                      eor.w     d6,(a1)+
[00013ae8] 8751                      or.w      d3,(a1)
[00013aea] bd59                      eor.w     d6,(a1)+
[00013aec] 8751                      or.w      d3,(a1)
[00013aee] bd59                      eor.w     d6,(a1)+
[00013af0] 8751                      or.w      d3,(a1)
[00013af2] bd59                      eor.w     d6,(a1)+
[00013af4] d0ca                      adda.w    a2,a0
[00013af6] d2cb                      adda.w    a3,a1
[00013af8] 51cd ffac                 dbf       d5,$00013AA6
[00013afc] 4e75                      rts
[00013afe] 3c18                      move.w    (a0)+,d6
[00013b00] cc42                      and.w     d2,d6
[00013b02] 8d59                      or.w      d6,(a1)+
[00013b04] 8d59                      or.w      d6,(a1)+
[00013b06] 8d59                      or.w      d6,(a1)+
[00013b08] 8d59                      or.w      d6,(a1)+
[00013b0a] 3801                      move.w    d1,d4
[00013b0c] 6b0e                      bmi.s     $00013B1C
[00013b0e] 3c18                      move.w    (a0)+,d6
[00013b10] 8d59                      or.w      d6,(a1)+
[00013b12] 8d59                      or.w      d6,(a1)+
[00013b14] 8d59                      or.w      d6,(a1)+
[00013b16] 8d59                      or.w      d6,(a1)+
[00013b18] 51cc fff4                 dbf       d4,$00013B0E
[00013b1c] 3c10                      move.w    (a0),d6
[00013b1e] cc43                      and.w     d3,d6
[00013b20] 8d59                      or.w      d6,(a1)+
[00013b22] 8d59                      or.w      d6,(a1)+
[00013b24] 8d59                      or.w      d6,(a1)+
[00013b26] 8d59                      or.w      d6,(a1)+
[00013b28] d0ca                      adda.w    a2,a0
[00013b2a] d2cb                      adda.w    a3,a1
[00013b2c] 51cd ffd0                 dbf       d5,$00013AFE
[00013b30] 4e75                      rts
[00013b32] 2c10                      move.l    (a0),d6
[00013b34] 5488                      addq.l    #2,a0
[00013b36] e0be                      ror.l     d0,d6
[00013b38] cc42                      and.w     d2,d6
[00013b3a] 8d59                      or.w      d6,(a1)+
[00013b3c] 8d59                      or.w      d6,(a1)+
[00013b3e] 8d59                      or.w      d6,(a1)+
[00013b40] 8d59                      or.w      d6,(a1)+
[00013b42] 3801                      move.w    d1,d4
[00013b44] 6b12                      bmi.s     $00013B58
[00013b46] 2c10                      move.l    (a0),d6
[00013b48] 5488                      addq.l    #2,a0
[00013b4a] e0be                      ror.l     d0,d6
[00013b4c] 8d59                      or.w      d6,(a1)+
[00013b4e] 8d59                      or.w      d6,(a1)+
[00013b50] 8d59                      or.w      d6,(a1)+
[00013b52] 8d59                      or.w      d6,(a1)+
[00013b54] 51cc fff0                 dbf       d4,$00013B46
[00013b58] 2c10                      move.l    (a0),d6
[00013b5a] e0be                      ror.l     d0,d6
[00013b5c] cc43                      and.w     d3,d6
[00013b5e] 8d59                      or.w      d6,(a1)+
[00013b60] 8d59                      or.w      d6,(a1)+
[00013b62] 8d59                      or.w      d6,(a1)+
[00013b64] 8d59                      or.w      d6,(a1)+
[00013b66] d0ca                      adda.w    a2,a0
[00013b68] d2cb                      adda.w    a3,a1
[00013b6a] 51cd ffc6                 dbf       d5,$00013B32
[00013b6e] 4e75                      rts
[00013b70] 2c10                      move.l    (a0),d6
[00013b72] 5488                      addq.l    #2,a0
[00013b74] 4846                      swap      d6
[00013b76] e1be                      rol.l     d0,d6
[00013b78] cc42                      and.w     d2,d6
[00013b7a] 8d59                      or.w      d6,(a1)+
[00013b7c] 8d59                      or.w      d6,(a1)+
[00013b7e] 8d59                      or.w      d6,(a1)+
[00013b80] 8d59                      or.w      d6,(a1)+
[00013b82] 3801                      move.w    d1,d4
[00013b84] 6b14                      bmi.s     $00013B9A
[00013b86] 2c10                      move.l    (a0),d6
[00013b88] 5488                      addq.l    #2,a0
[00013b8a] 4846                      swap      d6
[00013b8c] e1be                      rol.l     d0,d6
[00013b8e] 8d59                      or.w      d6,(a1)+
[00013b90] 8d59                      or.w      d6,(a1)+
[00013b92] 8d59                      or.w      d6,(a1)+
[00013b94] 8d59                      or.w      d6,(a1)+
[00013b96] 51cc ffee                 dbf       d4,$00013B86
[00013b9a] 2c10                      move.l    (a0),d6
[00013b9c] 4846                      swap      d6
[00013b9e] e1be                      rol.l     d0,d6
[00013ba0] cc43                      and.w     d3,d6
[00013ba2] 8d59                      or.w      d6,(a1)+
[00013ba4] 8d59                      or.w      d6,(a1)+
[00013ba6] 8d59                      or.w      d6,(a1)+
[00013ba8] 8d59                      or.w      d6,(a1)+
[00013baa] d0ca                      adda.w    a2,a0
[00013bac] d2cb                      adda.w    a3,a1
[00013bae] 51cd ffc0                 dbf       d5,$00013B70
[00013bb2] 4e75                      rts
[00013bb4] 48e7 0700                 movem.l   d5-d7,-(a7)
[00013bb8] 3600                      move.w    d0,d3
[00013bba] 4843                      swap      d3
[00013bbc] 3600                      move.w    d0,d3
[00013bbe] 4a6e 01b2                 tst.w     434(a6)
[00013bc2] 670a                      beq.s     $00013BCE
[00013bc4] 286e 01ae                 movea.l   430(a6),a4
[00013bc8] c3ee 01b2                 muls.w    434(a6),d1
[00013bcc] 6008                      bra.s     $00013BD6
[00013bce] 2878 044e                 movea.l   ($0000044E).w,a4
[00013bd2] c3f8 206e                 muls.w    ($0000206E).w,d1
[00013bd6] d9c1                      adda.l    d1,a4
[00013bd8] 78f0                      moveq.l   #-16,d4
[00013bda] c840                      and.w     d0,d4
[00013bdc] e244                      asr.w     #1,d4
[00013bde] d8c4                      adda.w    d4,a4
[00013be0] 4640                      not.w     d0
[00013be2] 780f                      moveq.l   #15,d4
[00013be4] c840                      and.w     d0,d4
[00013be6] 7000                      moveq.l   #0,d0
[00013be8] 09c0                      bset      d4,d0
[00013bea] 7c00                      moveq.l   #0,d6
[00013bec] 3e2e 01b4                 move.w    436(a6),d7
[00013bf0] 48e7 d800                 movem.l   d0-d1/d3-d4,-(a7)
[00013bf4] 264c                      movea.l   a4,a3
[00013bf6] e24e                      lsr.w     #1,d6
[00013bf8] 3213                      move.w    (a3),d1
[00013bfa] c240                      and.w     d0,d1
[00013bfc] 56c4                      sne       d4
[00013bfe] 6702                      beq.s     $00013C02
[00013c00] 5046                      addq.w    #8,d6
[00013c02] 4884                      ext.w     d4
[00013c04] b642                      cmp.w     d2,d3
[00013c06] 6e56                      bgt.s     $00013C5E
[00013c08] 3003                      move.w    d3,d0
[00013c0a] 0240 000f                 andi.w    #$000F,d0
[00013c0e] 3213                      move.w    (a3),d1
[00013c10] 508b                      addq.l    #8,a3
[00013c12] e169                      lsl.w     d0,d1
[00013c14] 3a04                      move.w    d4,d5
[00013c16] e16d                      lsl.w     d0,d5
[00013c18] ba41                      cmp.w     d1,d5
[00013c1a] 6712                      beq.s     $00013C2E
[00013c1c] d241                      add.w     d1,d1
[00013c1e] d241                      add.w     d1,d1
[00013c20] 55c0                      scs       d0
[00013c22] b800                      cmp.b     d0,d4
[00013c24] 6638                      bne.s     $00013C5E
[00013c26] 5243                      addq.w    #1,d3
[00013c28] b642                      cmp.w     d2,d3
[00013c2a] 6df2                      blt.s     $00013C1E
[00013c2c] 602e                      bra.s     $00013C5C
[00013c2e] 3003                      move.w    d3,d0
[00013c30] 4640                      not.w     d0
[00013c32] c07c 000f                 and.w     #$000F,d0
[00013c36] d640                      add.w     d0,d3
[00013c38] b642                      cmp.w     d2,d3
[00013c3a] 6c20                      bge.s     $00013C5C
[00013c3c] 3213                      move.w    (a3),d1
[00013c3e] 508b                      addq.l    #8,a3
[00013c40] b841                      cmp.w     d1,d4
[00013c42] 660a                      bne.s     $00013C4E
[00013c44] d67c 0010                 add.w     #$0010,d3
[00013c48] b642                      cmp.w     d2,d3
[00013c4a] 6df0                      blt.s     $00013C3C
[00013c4c] 600e                      bra.s     $00013C5C
[00013c4e] d241                      add.w     d1,d1
[00013c50] 55c0                      scs       d0
[00013c52] b800                      cmp.b     d0,d4
[00013c54] 6608                      bne.s     $00013C5E
[00013c56] 5243                      addq.w    #1,d3
[00013c58] b642                      cmp.w     d2,d3
[00013c5a] 6df2                      blt.s     $00013C4E
[00013c5c] 3602                      move.w    d2,d3
[00013c5e] 3283                      move.w    d3,(a1)
[00013c60] 4842                      swap      d2
[00013c62] 4843                      swap      d3
[00013c64] 264c                      movea.l   a4,a3
[00013c66] b642                      cmp.w     d2,d3
[00013c68] 6d54                      blt.s     $00013CBE
[00013c6a] 3003                      move.w    d3,d0
[00013c6c] 4640                      not.w     d0
[00013c6e] c07c 000f                 and.w     #$000F,d0
[00013c72] 3213                      move.w    (a3),d1
[00013c74] e069                      lsr.w     d0,d1
[00013c76] 3a04                      move.w    d4,d5
[00013c78] e06d                      lsr.w     d0,d5
[00013c7a] ba41                      cmp.w     d1,d5
[00013c7c] 6712                      beq.s     $00013C90
[00013c7e] e249                      lsr.w     #1,d1
[00013c80] e249                      lsr.w     #1,d1
[00013c82] 55c0                      scs       d0
[00013c84] b800                      cmp.b     d0,d4
[00013c86] 6636                      bne.s     $00013CBE
[00013c88] 5343                      subq.w    #1,d3
[00013c8a] b642                      cmp.w     d2,d3
[00013c8c] 6ef2                      bgt.s     $00013C80
[00013c8e] 602c                      bra.s     $00013CBC
[00013c90] 3003                      move.w    d3,d0
[00013c92] c07c 000f                 and.w     #$000F,d0
[00013c96] 9640                      sub.w     d0,d3
[00013c98] b642                      cmp.w     d2,d3
[00013c9a] 6f20                      ble.s     $00013CBC
[00013c9c] 518b                      subq.l    #8,a3
[00013c9e] 3213                      move.w    (a3),d1
[00013ca0] b841                      cmp.w     d1,d4
[00013ca2] 660a                      bne.s     $00013CAE
[00013ca4] 967c 0010                 sub.w     #$0010,d3
[00013ca8] b642                      cmp.w     d2,d3
[00013caa] 6ef0                      bgt.s     $00013C9C
[00013cac] 600e                      bra.s     $00013CBC
[00013cae] e249                      lsr.w     #1,d1
[00013cb0] 55c0                      scs       d0
[00013cb2] b800                      cmp.b     d0,d4
[00013cb4] 6608                      bne.s     $00013CBE
[00013cb6] 5343                      subq.w    #1,d3
[00013cb8] b642                      cmp.w     d2,d3
[00013cba] 6ef2                      bgt.s     $00013CAE
[00013cbc] 3602                      move.w    d2,d3
[00013cbe] 3083                      move.w    d3,(a0)
[00013cc0] 3410                      move.w    (a0),d2
[00013cc2] 4842                      swap      d2
[00013cc4] 3411                      move.w    (a1),d2
[00013cc6] 548c                      addq.l    #2,a4
[00013cc8] 4cdf 001b                 movem.l   (a7)+,d0-d1/d3-d4
[00013ccc] 51cf ff22                 dbf       d7,$00013BF0
[00013cd0] 3015                      move.w    (a5),d0
[00013cd2] bc6d 0004                 cmp.w     4(a5),d6
[00013cd6] 6704                      beq.s     $00013CDC
[00013cd8] 0a40 0001                 eori.w    #$0001,d0
[00013cdc] 4cdf 00e0                 movem.l   (a7)+,d5-d7
[00013ce0] 4e75                      rts

data:
[00013ce2]                           dc.w $000f
[00013ce4]                           dc.w $0102
[00013ce6]                           dc.w $0406
[00013ce8]                           dc.w $0305
[00013cea]                           dc.w $0708
[00013cec]                           dc.w $090a
[00013cee]                           dc.w $0c0e
[00013cf0]                           dc.w $0b0d
[00013cf2]                           dc.w $0002
[00013cf4]                           dc.w $0306
[00013cf6]                           dc.w $0407
[00013cf8]                           dc.w $0508
[00013cfa]                           dc.w $090a
[00013cfc]                           dc.w $0b0e
[00013cfe]                           dc.w $0c0f
[00013d00]                           dc.w $0d01
[00013d02]                           dc.w $02ae
[00013d04]                           dc.w $0044
[00013d06]                           dc.w $2e22
[00013d08]                           dc.w $0158
[00013d0a]                           dc.w $0406
[00013d0c]                           dc.w $01b8
[00013d0e]                           dc.w $0246
[00013d10]                           dc.w $0162
[00013d12]                           dc.w $036c
[00013d14]                           dc.w $005a
[00013d16]                           dc.w $026e
[00013d18]                           dc.w $0000
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
; $00000164
; $00000186
; $0000018e
; $00000196
; $0000019e
; $000001a6
; $000001ae
; $000001b6
; $000001be
; $000001c6
; $000001ce
; $000001d6
; $000001de
; $000001e6
; $000001ee
; $000001f6
; $000001fe
; $00000206
; $00000304
; $00000402
; $00000500
; $000005fe
; $000006fc
; $000007fa
; $000008f8
; $000009f6
; $00000af4
; $00000bf2
; $00000cf0
; $00000dee
; $00000eec
; $00000fea
; $000010e8
; $000011e6
; $00001210
; $0000130e
; $0000140c
; $0000150a
; $00001608
; $00001706
; $00001804
; $00001902
; $00001a00
; $00001afe
; $00001bfc
; $00001cfa
; $00001df8
; $00001ef6
; $00001ff4
; $000020f2
; $000021f0
; $000022ee
; $000023ec
; $000024ea
; $000025e8
; $000026e6
; $0000277e
