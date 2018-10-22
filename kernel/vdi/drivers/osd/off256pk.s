; ph_branch = 0x601a
; ph_tlen = 0x000043ce
; ph_dlen = 0x00000014
; ph_blen = 0x00001206
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x0000f007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x0000004c

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0302                 cmpiw.l   #$0302,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 0080                 ori.b     #$80,d1
[00010018] 0001 01ee                 ori.b     #$EE,d1
[0001001c] 0001 0284                 ori.b     #$84,d1
[00010020] 0001 0082                 ori.b     #$82,d1
[00010024] 0001 00c4                 ori.b     #$C4,d1
[00010028] 0001 0112                 ori.b     #$12,d1
[0001002c] 0001 015a                 ori.b     #$5A,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0000 0100                 ori.b     #$00,d0
[00010044] 0008 0002                 ori.b     #$02,a0 ; apollo only
[00010048] 0001 0000                 ori.b     #$00,d1
[0001004c] 0000 0000                 ori.b     #$00,d0
[00010050] 4e75                      rts
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 43e4            move.l    a0,$000143E4
[0001005c] 6100 016a                 bsr       $000101C8
[00010060] 207a 4382                 movea.l   $000143E4(pc),a0
[00010064] 33e8 006a 0001 43e2       move.w    106(a0),$000143E2
[0001006c] 6100 0120                 bsr       $0001018E
[00010070] 6100 00ea                 bsr       $0001015C
[00010074] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010078] 203c 0000 0358            move.l    #$00000358,d0
[0001007e] 4e75                      rts
[00010080] 4e75                      rts
[00010082] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010086] 20ee 0010                 move.l    16(a6),(a0)+
[0001008a] 4258                      clr.w     (a0)+
[0001008c] 20ee 000c                 move.l    12(a6),(a0)+
[00010090] 7027                      moveq.l   #39,d0
[00010092] 247a 4350                 movea.l   $000143E4(pc),a2
[00010096] 246a 002c                 movea.l   44(a2),a2
[0001009a] 45ea 000a                 lea.l     10(a2),a2
[0001009e] 30da                      move.w    (a2)+,(a0)+
[000100a0] 51c8 fffc                 dbf       d0,$0001009E
[000100a4] 317c 0100 ffc0            move.w    #$0100,-64(a0)
[000100aa] 317c 0001 ffec            move.w    #$0001,-20(a0)
[000100b0] 317c 0100 fff4            move.w    #$0100,-12(a0)
[000100b6] 700b                      moveq.l   #11,d0
[000100b8] 32da                      move.w    (a2)+,(a1)+
[000100ba] 51c8 fffc                 dbf       d0,$000100B8
[000100be] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100c2] 4e75                      rts
[000100c4] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[000100c8] 702c                      moveq.l   #44,d0
[000100ca] 247a 4318                 movea.l   $000143E4(pc),a2
[000100ce] 246a 0030                 movea.l   48(a2),a2
[000100d2] 30da                      move.w    (a2)+,(a0)+
[000100d4] 51c8 fffc                 dbf       d0,$000100D2
[000100d8] 4268 ffa6                 clr.w     -90(a0)
[000100dc] 317c 0100 ffa8            move.w    #$0100,-88(a0)
[000100e2] 317c 0008 ffae            move.w    #$0008,-82(a0)
[000100e8] 4268 ffb0                 clr.w     -80(a0)
[000100ec] 317c 0898 ffb2            move.w    #$0898,-78(a0)
[000100f2] 317c 0001 ffcc            move.w    #$0001,-52(a0)
[000100f8] 700b                      moveq.l   #11,d0
[000100fa] 32da                      move.w    (a2)+,(a1)+
[000100fc] 51c8 fffc                 dbf       d0,$000100FA
[00010100] 45ee 0034                 lea.l     52(a6),a2
[00010104] 235a ffe8                 move.l    (a2)+,-24(a1)
[00010108] 235a ffec                 move.l    (a2)+,-20(a1)
[0001010c] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010110] 4e75                      rts
[00010112] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010116] 7000                      moveq.l   #0,d0
[00010118] 30fc 0002                 move.w    #$0002,(a0)+
[0001011c] 30c0                      move.w    d0,(a0)+
[0001011e] 30fc 0008                 move.w    #$0008,(a0)+
[00010122] 20fc 0000 0100            move.l    #$00000100,(a0)+
[00010128] 30ee 01b2                 move.w    434(a6),(a0)+
[0001012c] 20ee 01ae                 move.l    430(a6),(a0)+
[00010130] 30c0                      move.w    d0,(a0)+
[00010132] 30c0                      move.w    d0,(a0)+
[00010134] 30c0                      move.w    d0,(a0)+
[00010136] 30c0                      move.w    d0,(a0)+
[00010138] 30c0                      move.w    d0,(a0)+
[0001013a] 30c0                      move.w    d0,(a0)+
[0001013c] 30fc 0001                 move.w    #$0001,(a0)+
[00010140] 4258                      clr.w     (a0)+
[00010142] 303c 00ff                 move.w    #$00FF,d0
[00010146] 43fa 42a0                 lea.l     $000143E8(pc),a1
[0001014a] 7200                      moveq.l   #0,d1
[0001014c] 1219                      move.b    (a1)+,d1
[0001014e] 30c1                      move.w    d1,(a0)+
[00010150] 51c8 fff8                 dbf       d0,$0001014A
[00010154] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010158] 4e75                      rts
[0001015a] 4e75                      rts
[0001015c] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010160] 247a 4282                 movea.l   $000143E4(pc),a2
[00010164] 246a 0028                 movea.l   40(a2),a2
[00010168] 2052                      movea.l   (a2),a0
[0001016a] 43f9 0001 43e8            lea.l     $000143E8,a1
[00010170] 703f                      moveq.l   #63,d0
[00010172] 22d8                      move.l    (a0)+,(a1)+
[00010174] 51c8 fffc                 dbf       d0,$00010172
[00010178] 206a 0004                 movea.l   4(a2),a0
[0001017c] 43fa 436a                 lea.l     $000144E8(pc),a1
[00010180] 703f                      moveq.l   #63,d0
[00010182] 22d8                      move.l    (a0)+,(a1)+
[00010184] 51c8 fffc                 dbf       d0,$00010182
[00010188] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[0001018c] 4e75                      rts
[0001018e] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[00010192] 41fa 4454                 lea.l     $000145E8(pc),a0
[00010196] 43fa 4c50                 lea.l     $00014DE8(pc),a1
[0001019a] 7000                      moveq.l   #0,d0
[0001019c] 3200                      move.w    d0,d1
[0001019e] 7407                      moveq.l   #7,d2
[000101a0] 4210                      clr.b     (a0)
[000101a2] d201                      add.b     d1,d1
[000101a4] 6402                      bcc.s     $000101A8
[000101a6] 4610                      not.b     (a0)
[000101a8] 5288                      addq.l    #1,a0
[000101aa] 51ca fff4                 dbf       d2,$000101A0
[000101ae] 0348 fff8                 movep.l   -8(a0),d1
[000101b2] 22c1                      move.l    d1,(a1)+
[000101b4] 0348 fff9                 movep.l   -7(a0),d1
[000101b8] 22c1                      move.l    d1,(a1)+
[000101ba] 5240                      addq.w    #1,d0
[000101bc] b07c 0100                 cmp.w     #$0100,d0
[000101c0] 6dda                      blt.s     $0001019C
[000101c2] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[000101c6] 4e75                      rts
[000101c8] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[000101cc] a000                      ALINE     #$0000
[000101ce] 907c 2070                 sub.w     #$2070,d0
[000101d2] 6714                      beq.s     $000101E8
[000101d4] 41fa fe2a                 lea.l     $00010000(pc),a0
[000101d8] 43f9 0001 43ce            lea.l     $000143CE,a1
[000101de] 3219                      move.w    (a1)+,d1
[000101e0] 6706                      beq.s     $000101E8
[000101e2] d0c1                      adda.w    d1,a0
[000101e4] d150                      add.w     d0,(a0)
[000101e6] 60f6                      bra.s     $000101DE
[000101e8] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[000101ec] 4e75                      rts
[000101ee] 3d7c 0007 01b4            move.w    #$0007,436(a6)
[000101f4] 3d7c 00ff 0014            move.w    #$00FF,20(a6)
[000101fa] 2d7c 0001 0da4 01f4       move.l    #$00010DA4,500(a6)
[00010202] 2d7c 0001 07ca 01f8       move.l    #$000107CA,504(a6)
[0001020a] 2d7c 0001 05cc 01fc       move.l    #$000105CC,508(a6)
[00010212] 2d7c 0001 09cc 0200       move.l    #$000109CC,512(a6)
[0001021a] 2d7c 0001 0bfe 0204       move.l    #$00010BFE,516(a6)
[00010222] 2d7c 0001 161c 0208       move.l    #$0001161C,520(a6)
[0001022a] 2d7c 0001 264c 020c       move.l    #$0001264C,524(a6)
[00010232] 2d7c 0001 15d8 0210       move.l    #$000115D8,528(a6)
[0001023a] 2d7c 0001 0290 0214       move.l    #$00010290,532(a6)
[00010242] 2d7c 0001 0572 021c       move.l    #$00010572,540(a6)
[0001024a] 2d7c 0001 0594 0218       move.l    #$00010594,536(a6)
[00010252] 2d7c 0001 0322 0220       move.l    #$00010322,544(a6)
[0001025a] 2d7c 0001 02f4 0224       move.l    #$000102F4,548(a6)
[00010262] 2d7c 0001 0286 0228       move.l    #$00010286,552(a6)
[0001026a] 2d7c 0001 0288 022c       move.l    #$00010288,556(a6)
[00010272] 2d7c 0001 05b4 0230       move.l    #$000105B4,560(a6)
[0001027a] 2d7c 0001 05c0 0234       move.l    #$000105C0,564(a6)
[00010282] 4e75                      rts
[00010284] 4e75                      rts
[00010286] 4e75                      rts
[00010288] 70ff                      moveq.l   #-1,d0
[0001028a] 72ff                      moveq.l   #-1,d1
[0001028c] 74ff                      moveq.l   #-1,d2
[0001028e] 4e75                      rts
[00010290] 3600                      move.w    d0,d3
[00010292] 4843                      swap      d3
[00010294] 3600                      move.w    d0,d3
[00010296] 4a6e 01b2                 tst.w     434(a6)
[0001029a] 670a                      beq.s     $000102A6
[0001029c] 266e 01ae                 movea.l   430(a6),a3
[000102a0] c3ee 01b2                 muls.w    434(a6),d1
[000102a4] 6008                      bra.s     $000102AE
[000102a6] 2678 044e                 movea.l   ($0000044E).w,a3
[000102aa] c3f8 206e                 muls.w    ($0000206E).w,d1
[000102ae] d7c1                      adda.l    d1,a3
[000102b0] d6c0                      adda.w    d0,a3
[000102b2] 284b                      movea.l   a3,a4
[000102b4] 7800                      moveq.l   #0,d4
[000102b6] 1813                      move.b    (a3),d4
[000102b8] b642                      cmp.w     d2,d3
[000102ba] 6e0e                      bgt.s     $000102CA
[000102bc] 528b                      addq.l    #1,a3
[000102be] b81b                      cmp.b     (a3)+,d4
[000102c0] 6608                      bne.s     $000102CA
[000102c2] 5243                      addq.w    #1,d3
[000102c4] b642                      cmp.w     d2,d3
[000102c6] 6df6                      blt.s     $000102BE
[000102c8] 3602                      move.w    d2,d3
[000102ca] 3283                      move.w    d3,(a1)
[000102cc] 4842                      swap      d2
[000102ce] 4843                      swap      d3
[000102d0] 264c                      movea.l   a4,a3
[000102d2] b642                      cmp.w     d2,d3
[000102d4] 6f0e                      ble.s     $000102E4
[000102d6] 3003                      move.w    d3,d0
[000102d8] b823                      cmp.b     -(a3),d4
[000102da] 6608                      bne.s     $000102E4
[000102dc] 5343                      subq.w    #1,d3
[000102de] b642                      cmp.w     d2,d3
[000102e0] 6ef6                      bgt.s     $000102D8
[000102e2] 3602                      move.w    d2,d3
[000102e4] 3083                      move.w    d3,(a0)
[000102e6] 3015                      move.w    (a5),d0
[000102e8] b8ad 0002                 cmp.l     2(a5),d4
[000102ec] 6704                      beq.s     $000102F2
[000102ee] 0a40 0001                 eori.w    #$0001,d0
[000102f2] 4e75                      rts
[000102f4] b07c 0010                 cmp.w     #$0010,d0
[000102f8] 6714                      beq.s     $0001030E
[000102fa] 48e7 7f3e                 movem.l   d1-d7/a2-a6,-(a7)
[000102fe] 7010                      moveq.l   #16,d0
[00010300] 720f                      moveq.l   #15,d1
[00010302] 6100 01ee                 bsr       $000104F2
[00010306] 4cdf 7cfe                 movem.l   (a7)+,d1-d7/a2-a6
[0001030a] 7007                      moveq.l   #7,d0
[0001030c] 4e75                      rts
[0001030e] 22d8                      move.l    (a0)+,(a1)+
[00010310] 22d8                      move.l    (a0)+,(a1)+
[00010312] 22d8                      move.l    (a0)+,(a1)+
[00010314] 22d8                      move.l    (a0)+,(a1)+
[00010316] 22d8                      move.l    (a0)+,(a1)+
[00010318] 22d8                      move.l    (a0)+,(a1)+
[0001031a] 22d8                      move.l    (a0)+,(a1)+
[0001031c] 22d8                      move.l    (a0)+,(a1)+
[0001031e] 7000                      moveq.l   #0,d0
[00010320] 4e75                      rts
[00010322] 2f0e                      move.l    a6,-(a7)
[00010324] 7000                      moveq.l   #0,d0
[00010326] 3028 000c                 move.w    12(a0),d0
[0001032a] 3228 0006                 move.w    6(a0),d1
[0001032e] c2e8 0008                 mulu.w    8(a0),d1
[00010332] 7400                      moveq.l   #0,d2
[00010334] 4a68 000a                 tst.w     10(a0)
[00010338] 6602                      bne.s     $0001033C
[0001033a] 7401                      moveq.l   #1,d2
[0001033c] 3342 000a                 move.w    d2,10(a1)
[00010340] 2050                      movea.l   (a0),a0
[00010342] 2251                      movea.l   (a1),a1
[00010344] 5381                      subq.l    #1,d1
[00010346] 6b4c                      bmi.s     $00010394
[00010348] 5340                      subq.w    #1,d0
[0001034a] 6700 0210                 beq       $0001055C
[0001034e] 5f40                      subq.w    #7,d0
[00010350] 6642                      bne.s     $00010394
[00010352] d442                      add.w     d2,d2
[00010354] d442                      add.w     d2,d2
[00010356] 247b 2040                 movea.l   $00010398(pc,d2.w),a2
[0001035a] b3c8                      cmpa.l    a0,a1
[0001035c] 6630                      bne.s     $0001038E
[0001035e] 2601                      move.l    d1,d3
[00010360] 5283                      addq.l    #1,d3
[00010362] e98b                      lsl.l     #4,d3
[00010364] b6ae 0024                 cmp.l     36(a6),d3
[00010368] 6e1e                      bgt.s     $00010388
[0001036a] 2f03                      move.l    d3,-(a7)
[0001036c] 2f08                      move.l    a0,-(a7)
[0001036e] 226e 0020                 movea.l   32(a6),a1
[00010372] 2f09                      move.l    a1,-(a7)
[00010374] 2001                      move.l    d1,d0
[00010376] 5280                      addq.l    #1,d0
[00010378] 4e92                      jsr       (a2)
[0001037a] 205f                      movea.l   (a7)+,a0
[0001037c] 225f                      movea.l   (a7)+,a1
[0001037e] 221f                      move.l    (a7)+,d1
[00010380] e289                      lsr.l     #1,d1
[00010382] 5381                      subq.l    #1,d1
[00010384] 6000 01da                 bra       $00010560
[00010388] 247b 2016                 movea.l   $000103A0(pc,d2.w),a2
[0001038c] 6004                      bra.s     $00010392
[0001038e] 2001                      move.l    d1,d0
[00010390] 5280                      addq.l    #1,d0
[00010392] 4e92                      jsr       (a2)
[00010394] 2c5f                      movea.l   (a7)+,a6
[00010396] 4e75                      rts
[00010398] 0001 04f2                 ori.b     #$F2,d1
[0001039c] 0001 048c                 ori.b     #$8C,d1
[000103a0] 0001 03a8                 ori.b     #$A8,d1
[000103a4] 0001 0408                 ori.b     #$08,d1
[000103a8] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[000103ac] 2001                      move.l    d1,d0
[000103ae] 7807                      moveq.l   #7,d4
[000103b0] 6100 00aa                 bsr       $0001045C
[000103b4] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[000103b8] 2c41                      movea.l   d1,a6
[000103ba] 700f                      moveq.l   #15,d0
[000103bc] 4840                      swap      d0
[000103be] 3e18                      move.w    (a0)+,d7
[000103c0] 3c18                      move.w    (a0)+,d6
[000103c2] 3a18                      move.w    (a0)+,d5
[000103c4] 3818                      move.w    (a0)+,d4
[000103c6] 3618                      move.w    (a0)+,d3
[000103c8] 3418                      move.w    (a0)+,d2
[000103ca] 3218                      move.w    (a0)+,d1
[000103cc] 3018                      move.w    (a0)+,d0
[000103ce] 4840                      swap      d0
[000103d0] 4847                      swap      d7
[000103d2] 4840                      swap      d0
[000103d4] d040                      add.w     d0,d0
[000103d6] df07                      addx.b    d7,d7
[000103d8] d241                      add.w     d1,d1
[000103da] df07                      addx.b    d7,d7
[000103dc] d442                      add.w     d2,d2
[000103de] df07                      addx.b    d7,d7
[000103e0] d643                      add.w     d3,d3
[000103e2] df07                      addx.b    d7,d7
[000103e4] d844                      add.w     d4,d4
[000103e6] df07                      addx.b    d7,d7
[000103e8] da45                      add.w     d5,d5
[000103ea] df07                      addx.b    d7,d7
[000103ec] dc46                      add.w     d6,d6
[000103ee] df07                      addx.b    d7,d7
[000103f0] 4847                      swap      d7
[000103f2] de47                      add.w     d7,d7
[000103f4] 4847                      swap      d7
[000103f6] df07                      addx.b    d7,d7
[000103f8] 12c7                      move.b    d7,(a1)+
[000103fa] 4840                      swap      d0
[000103fc] 51c8 ffd4                 dbf       d0,$000103D2
[00010400] 220e                      move.l    a6,d1
[00010402] 5381                      subq.l    #1,d1
[00010404] 6ab2                      bpl.s     $000103B8
[00010406] 4e75                      rts
[00010408] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[0001040c] 2c41                      movea.l   d1,a6
[0001040e] 700f                      moveq.l   #15,d0
[00010410] 4840                      swap      d0
[00010412] 4847                      swap      d7
[00010414] 1e18                      move.b    (a0)+,d7
[00010416] de07                      add.b     d7,d7
[00010418] d140                      addx.w    d0,d0
[0001041a] de07                      add.b     d7,d7
[0001041c] d341                      addx.w    d1,d1
[0001041e] de07                      add.b     d7,d7
[00010420] d542                      addx.w    d2,d2
[00010422] de07                      add.b     d7,d7
[00010424] d743                      addx.w    d3,d3
[00010426] de07                      add.b     d7,d7
[00010428] d944                      addx.w    d4,d4
[0001042a] de07                      add.b     d7,d7
[0001042c] db45                      addx.w    d5,d5
[0001042e] de07                      add.b     d7,d7
[00010430] dd46                      addx.w    d6,d6
[00010432] de07                      add.b     d7,d7
[00010434] 4847                      swap      d7
[00010436] df47                      addx.w    d7,d7
[00010438] 4840                      swap      d0
[0001043a] 51c8 ffd4                 dbf       d0,$00010410
[0001043e] 4840                      swap      d0
[00010440] 32c7                      move.w    d7,(a1)+
[00010442] 32c6                      move.w    d6,(a1)+
[00010444] 32c5                      move.w    d5,(a1)+
[00010446] 32c4                      move.w    d4,(a1)+
[00010448] 32c3                      move.w    d3,(a1)+
[0001044a] 32c2                      move.w    d2,(a1)+
[0001044c] 32c1                      move.w    d1,(a1)+
[0001044e] 32c0                      move.w    d0,(a1)+
[00010450] 220e                      move.l    a6,d1
[00010452] 5381                      subq.l    #1,d1
[00010454] 6ab6                      bpl.s     $0001040C
[00010456] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[0001045a] 7007                      moveq.l   #7,d0
[0001045c] 5384                      subq.l    #1,d4
[0001045e] 6b2a                      bmi.s     $0001048A
[00010460] 7400                      moveq.l   #0,d2
[00010462] 2204                      move.l    d4,d1
[00010464] d1c0                      adda.l    d0,a0
[00010466] 41f0 0802                 lea.l     2(a0,d0.l),a0
[0001046a] 3a10                      move.w    (a0),d5
[0001046c] 2248                      movea.l   a0,a1
[0001046e] 2448                      movea.l   a0,a2
[00010470] d480                      add.l     d0,d2
[00010472] 2602                      move.l    d2,d3
[00010474] 6004                      bra.s     $0001047A
[00010476] 2449                      movea.l   a1,a2
[00010478] 34a1                      move.w    -(a1),(a2)
[0001047a] 5383                      subq.l    #1,d3
[0001047c] 6af8                      bpl.s     $00010476
[0001047e] 3285                      move.w    d5,(a1)
[00010480] 5381                      subq.l    #1,d1
[00010482] 6ae0                      bpl.s     $00010464
[00010484] 204a                      movea.l   a2,a0
[00010486] 5380                      subq.l    #1,d0
[00010488] 6ad6                      bpl.s     $00010460
[0001048a] 4e75                      rts
[0001048c] d080                      add.l     d0,d0
[0001048e] 45f1 0800                 lea.l     0(a1,d0.l),a2
[00010492] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010496] 49f3 0800                 lea.l     0(a3,d0.l),a4
[0001049a] e588                      lsl.l     #2,d0
[0001049c] 2a40                      movea.l   d0,a5
[0001049e] 2c41                      movea.l   d1,a6
[000104a0] 700f                      moveq.l   #15,d0
[000104a2] 4840                      swap      d0
[000104a4] 4847                      swap      d7
[000104a6] 1e18                      move.b    (a0)+,d7
[000104a8] de07                      add.b     d7,d7
[000104aa] d140                      addx.w    d0,d0
[000104ac] de07                      add.b     d7,d7
[000104ae] d341                      addx.w    d1,d1
[000104b0] de07                      add.b     d7,d7
[000104b2] d542                      addx.w    d2,d2
[000104b4] de07                      add.b     d7,d7
[000104b6] d743                      addx.w    d3,d3
[000104b8] de07                      add.b     d7,d7
[000104ba] d944                      addx.w    d4,d4
[000104bc] de07                      add.b     d7,d7
[000104be] db45                      addx.w    d5,d5
[000104c0] de07                      add.b     d7,d7
[000104c2] dd46                      addx.w    d6,d6
[000104c4] de07                      add.b     d7,d7
[000104c6] 4847                      swap      d7
[000104c8] df47                      addx.w    d7,d7
[000104ca] 4840                      swap      d0
[000104cc] 51c8 ffd4                 dbf       d0,$000104A2
[000104d0] 4840                      swap      d0
[000104d2] 32c7                      move.w    d7,(a1)+
[000104d4] 34c6                      move.w    d6,(a2)+
[000104d6] 36c5                      move.w    d5,(a3)+
[000104d8] 38c4                      move.w    d4,(a4)+
[000104da] 3383 d8fe                 move.w    d3,-2(a1,a5.l)
[000104de] 3582 d8fe                 move.w    d2,-2(a2,a5.l)
[000104e2] 3781 d8fe                 move.w    d1,-2(a3,a5.l)
[000104e6] 3980 d8fe                 move.w    d0,-2(a4,a5.l)
[000104ea] 220e                      move.l    a6,d1
[000104ec] 5381                      subq.l    #1,d1
[000104ee] 6aae                      bpl.s     $0001049E
[000104f0] 4e75                      rts
[000104f2] d080                      add.l     d0,d0
[000104f4] 45f0 0800                 lea.l     0(a0,d0.l),a2
[000104f8] 47f2 0800                 lea.l     0(a2,d0.l),a3
[000104fc] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010500] e588                      lsl.l     #2,d0
[00010502] 2a40                      movea.l   d0,a5
[00010504] 2c41                      movea.l   d1,a6
[00010506] 700f                      moveq.l   #15,d0
[00010508] 4840                      swap      d0
[0001050a] 3e18                      move.w    (a0)+,d7
[0001050c] 3c1a                      move.w    (a2)+,d6
[0001050e] 3a1b                      move.w    (a3)+,d5
[00010510] 381c                      move.w    (a4)+,d4
[00010512] 3630 d8fe                 move.w    -2(a0,a5.l),d3
[00010516] 3432 d8fe                 move.w    -2(a2,a5.l),d2
[0001051a] 3233 d8fe                 move.w    -2(a3,a5.l),d1
[0001051e] 3034 d8fe                 move.w    -2(a4,a5.l),d0
[00010522] 4840                      swap      d0
[00010524] 4847                      swap      d7
[00010526] 4840                      swap      d0
[00010528] d040                      add.w     d0,d0
[0001052a] df07                      addx.b    d7,d7
[0001052c] d241                      add.w     d1,d1
[0001052e] df07                      addx.b    d7,d7
[00010530] d442                      add.w     d2,d2
[00010532] df07                      addx.b    d7,d7
[00010534] d643                      add.w     d3,d3
[00010536] df07                      addx.b    d7,d7
[00010538] d844                      add.w     d4,d4
[0001053a] df07                      addx.b    d7,d7
[0001053c] da45                      add.w     d5,d5
[0001053e] df07                      addx.b    d7,d7
[00010540] dc46                      add.w     d6,d6
[00010542] df07                      addx.b    d7,d7
[00010544] 4847                      swap      d7
[00010546] de47                      add.w     d7,d7
[00010548] 4847                      swap      d7
[0001054a] df07                      addx.b    d7,d7
[0001054c] 12c7                      move.b    d7,(a1)+
[0001054e] 4840                      swap      d0
[00010550] 51c8 ffd4                 dbf       d0,$00010526
[00010554] 220e                      move.l    a6,d1
[00010556] 5381                      subq.l    #1,d1
[00010558] 6aaa                      bpl.s     $00010504
[0001055a] 4e75                      rts
[0001055c] b3c8                      cmpa.l    a0,a1
[0001055e] 670e                      beq.s     $0001056E
[00010560] e289                      lsr.l     #1,d1
[00010562] 6504                      bcs.s     $00010568
[00010564] 32d8                      move.w    (a0)+,(a1)+
[00010566] 6002                      bra.s     $0001056A
[00010568] 22d8                      move.l    (a0)+,(a1)+
[0001056a] 5381                      subq.l    #1,d1
[0001056c] 6afa                      bpl.s     $00010568
[0001056e] 2c5f                      movea.l   (a7)+,a6
[00010570] 4e75                      rts
[00010572] 4a6e 01b2                 tst.w     434(a6)
[00010576] 670a                      beq.s     $00010582
[00010578] 206e 01ae                 movea.l   430(a6),a0
[0001057c] c3ee 01b2                 muls.w    434(a6),d1
[00010580] 6008                      bra.s     $0001058A
[00010582] 2078 044e                 movea.l   ($0000044E).w,a0
[00010586] c3f8 206e                 muls.w    ($0000206E).w,d1
[0001058a] d1c1                      adda.l    d1,a0
[0001058c] d0c0                      adda.w    d0,a0
[0001058e] 7000                      moveq.l   #0,d0
[00010590] 1010                      move.b    (a0),d0
[00010592] 4e75                      rts
[00010594] 4a6e 01b2                 tst.w     434(a6)
[00010598] 670a                      beq.s     $000105A4
[0001059a] 206e 01ae                 movea.l   430(a6),a0
[0001059e] c3ee 01b2                 muls.w    434(a6),d1
[000105a2] 6008                      bra.s     $000105AC
[000105a4] 2078 044e                 movea.l   ($0000044E).w,a0
[000105a8] c3f8 206e                 muls.w    ($0000206E).w,d1
[000105ac] d1c1                      adda.l    d1,a0
[000105ae] d0c0                      adda.w    d0,a0
[000105b0] 1082                      move.b    d2,(a0)
[000105b2] 4e75                      rts
[000105b4] 41fa 3e32                 lea.l     $000143E8(pc),a0
[000105b8] d0c0                      adda.w    d0,a0
[000105ba] 7000                      moveq.l   #0,d0
[000105bc] 1010                      move.b    (a0),d0
[000105be] 4e75                      rts
[000105c0] 41fa 3f26                 lea.l     $000144E8(pc),a0
[000105c4] d0c0                      adda.w    d0,a0
[000105c6] 7000                      moveq.l   #0,d0
[000105c8] 1010                      move.b    (a0),d0
[000105ca] 4e75                      rts
[000105cc] 43fa 3e1a                 lea.l     $000143E8(pc),a1
[000105d0] d2ee 0046                 adda.w    70(a6),a1
[000105d4] 0b09 0000                 movep.w   0(a1),d5
[000105d8] 1a11                      move.b    (a1),d5
[000105da] 3805                      move.w    d5,d4
[000105dc] 4844                      swap      d4
[000105de] 3805                      move.w    d5,d4
[000105e0] 4a6e 01ae                 tst.w     430(a6)
[000105e4] 670a                      beq.s     $000105F0
[000105e6] 226e 01ae                 movea.l   430(a6),a1
[000105ea] c3ee 01b2                 muls.w    434(a6),d1
[000105ee] 6008                      bra.s     $000105F8
[000105f0] 2278 044e                 movea.l   ($0000044E).w,a1
[000105f4] c3f8 206e                 muls.w    ($0000206E).w,d1
[000105f8] 48c0                      ext.l     d0
[000105fa] d280                      add.l     d0,d1
[000105fc] d3c1                      adda.l    d1,a1
[000105fe] de47                      add.w     d7,d7
[00010600] 3e3b 7008                 move.w    $0001060A(pc,d7.w),d7
[00010604] 4efb 7004                 jmp       $0001060A(pc,d7.w)
[00010608] 4e75                      rts
[0001060a] 0008 0090                 ori.b     #$90,a0 ; apollo only
[0001060e] 0132 008e                 btst      d0,-114(a2,d0.w)
[00010612] 2f0b                      move.l    a3,-(a7)
[00010614] 3f05                      move.w    d5,-(a7)
[00010616] 9440                      sub.w     d0,d2
[00010618] c07c 000f                 and.w     #$000F,d0
[0001061c] e17e                      rol.w     d0,d6
[0001061e] 7210                      moveq.l   #16,d1
[00010620] 700f                      moveq.l   #15,d0
[00010622] b440                      cmp.w     d0,d2
[00010624] 6c02                      bge.s     $00010628
[00010626] 3002                      move.w    d2,d0
[00010628] dc46                      add.w     d6,d6
[0001062a] 55c5                      scs       d5
[0001062c] ca57                      and.w     (a7),d5
[0001062e] 3802                      move.w    d2,d4
[00010630] e84c                      lsr.w     #4,d4
[00010632] 3e04                      move.w    d4,d7
[00010634] e84c                      lsr.w     #4,d4
[00010636] 4647                      not.w     d7
[00010638] 0247 000f                 andi.w    #$000F,d7
[0001063c] de47                      add.w     d7,d7
[0001063e] de47                      add.w     d7,d7
[00010640] 2649                      movea.l   a1,a3
[00010642] 4efb 7002                 jmp       $00010646(pc,d7.w)
[00010646] 1685                      move.b    d5,(a3)
[00010648] d6c1                      adda.w    d1,a3
[0001064a] 1685                      move.b    d5,(a3)
[0001064c] d6c1                      adda.w    d1,a3
[0001064e] 1685                      move.b    d5,(a3)
[00010650] d6c1                      adda.w    d1,a3
[00010652] 1685                      move.b    d5,(a3)
[00010654] d6c1                      adda.w    d1,a3
[00010656] 1685                      move.b    d5,(a3)
[00010658] d6c1                      adda.w    d1,a3
[0001065a] 1685                      move.b    d5,(a3)
[0001065c] d6c1                      adda.w    d1,a3
[0001065e] 1685                      move.b    d5,(a3)
[00010660] d6c1                      adda.w    d1,a3
[00010662] 1685                      move.b    d5,(a3)
[00010664] d6c1                      adda.w    d1,a3
[00010666] 1685                      move.b    d5,(a3)
[00010668] d6c1                      adda.w    d1,a3
[0001066a] 1685                      move.b    d5,(a3)
[0001066c] d6c1                      adda.w    d1,a3
[0001066e] 1685                      move.b    d5,(a3)
[00010670] d6c1                      adda.w    d1,a3
[00010672] 1685                      move.b    d5,(a3)
[00010674] d6c1                      adda.w    d1,a3
[00010676] 1685                      move.b    d5,(a3)
[00010678] d6c1                      adda.w    d1,a3
[0001067a] 1685                      move.b    d5,(a3)
[0001067c] d6c1                      adda.w    d1,a3
[0001067e] 1685                      move.b    d5,(a3)
[00010680] d6c1                      adda.w    d1,a3
[00010682] 1685                      move.b    d5,(a3)
[00010684] d6c1                      adda.w    d1,a3
[00010686] 51cc ffbe                 dbf       d4,$00010646
[0001068a] 5289                      addq.l    #1,a1
[0001068c] 5342                      subq.w    #1,d2
[0001068e] 51c8 ff98                 dbf       d0,$00010628
[00010692] 3a1f                      move.w    (a7)+,d5
[00010694] 265f                      movea.l   (a7)+,a3
[00010696] 4e75                      rts
[00010698] 4646                      not.w     d6
[0001069a] 2f0b                      move.l    a3,-(a7)
[0001069c] 9440                      sub.w     d0,d2
[0001069e] c07c 000f                 and.w     #$000F,d0
[000106a2] e17e                      rol.w     d0,d6
[000106a4] 7210                      moveq.l   #16,d1
[000106a6] 700f                      moveq.l   #15,d0
[000106a8] b440                      cmp.w     d0,d2
[000106aa] 6c02                      bge.s     $000106AE
[000106ac] 3002                      move.w    d2,d0
[000106ae] dc46                      add.w     d6,d6
[000106b0] 645c                      bcc.s     $0001070E
[000106b2] 3802                      move.w    d2,d4
[000106b4] e84c                      lsr.w     #4,d4
[000106b6] 3e04                      move.w    d4,d7
[000106b8] e84c                      lsr.w     #4,d4
[000106ba] 4647                      not.w     d7
[000106bc] 0247 000f                 andi.w    #$000F,d7
[000106c0] de47                      add.w     d7,d7
[000106c2] de47                      add.w     d7,d7
[000106c4] 2649                      movea.l   a1,a3
[000106c6] 4efb 7002                 jmp       $000106CA(pc,d7.w)
[000106ca] 1685                      move.b    d5,(a3)
[000106cc] d6c1                      adda.w    d1,a3
[000106ce] 1685                      move.b    d5,(a3)
[000106d0] d6c1                      adda.w    d1,a3
[000106d2] 1685                      move.b    d5,(a3)
[000106d4] d6c1                      adda.w    d1,a3
[000106d6] 1685                      move.b    d5,(a3)
[000106d8] d6c1                      adda.w    d1,a3
[000106da] 1685                      move.b    d5,(a3)
[000106dc] d6c1                      adda.w    d1,a3
[000106de] 1685                      move.b    d5,(a3)
[000106e0] d6c1                      adda.w    d1,a3
[000106e2] 1685                      move.b    d5,(a3)
[000106e4] d6c1                      adda.w    d1,a3
[000106e6] 1685                      move.b    d5,(a3)
[000106e8] d6c1                      adda.w    d1,a3
[000106ea] 1685                      move.b    d5,(a3)
[000106ec] d6c1                      adda.w    d1,a3
[000106ee] 1685                      move.b    d5,(a3)
[000106f0] d6c1                      adda.w    d1,a3
[000106f2] 1685                      move.b    d5,(a3)
[000106f4] d6c1                      adda.w    d1,a3
[000106f6] 1685                      move.b    d5,(a3)
[000106f8] d6c1                      adda.w    d1,a3
[000106fa] 1685                      move.b    d5,(a3)
[000106fc] d6c1                      adda.w    d1,a3
[000106fe] 1685                      move.b    d5,(a3)
[00010700] d6c1                      adda.w    d1,a3
[00010702] 1685                      move.b    d5,(a3)
[00010704] d6c1                      adda.w    d1,a3
[00010706] 1685                      move.b    d5,(a3)
[00010708] d6c1                      adda.w    d1,a3
[0001070a] 51cc ffbe                 dbf       d4,$000106CA
[0001070e] 5289                      addq.l    #1,a1
[00010710] 5342                      subq.w    #1,d2
[00010712] 51c8 ff9a                 dbf       d0,$000106AE
[00010716] 265f                      movea.l   (a7)+,a3
[00010718] 4e75                      rts
[0001071a] 5289                      addq.l    #1,a1
[0001071c] 51ca 0004                 dbf       d2,$00010722
[00010720] 4e75                      rts
[00010722] e24a                      lsr.w     #1,d2
[00010724] 383c ff00                 move.w    #$FF00,d4
[00010728] 2009                      move.l    a1,d0
[0001072a] 0800 0000                 btst      #0,d0
[0001072e] 6704                      beq.s     $00010734
[00010730] 5389                      subq.l    #1,a1
[00010732] 4644                      not.w     d4
[00010734] b959                      eor.w     d4,(a1)+
[00010736] 51ca fffc                 dbf       d2,$00010734
[0001073a] 4e75                      rts
[0001073c] 9440                      sub.w     d0,d2
[0001073e] c07c 000f                 and.w     #$000F,d0
[00010742] e17e                      rol.w     d0,d6
[00010744] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010748] 67d8                      beq.s     $00010722
[0001074a] bc7c 5555                 cmp.w     #$5555,d6
[0001074e] 67ca                      beq.s     $0001071A
[00010750] 2f0b                      move.l    a3,-(a7)
[00010752] 7aff                      moveq.l   #-1,d5
[00010754] 7210                      moveq.l   #16,d1
[00010756] 700f                      moveq.l   #15,d0
[00010758] b440                      cmp.w     d0,d2
[0001075a] 6c02                      bge.s     $0001075E
[0001075c] 3002                      move.w    d2,d0
[0001075e] dc46                      add.w     d6,d6
[00010760] 645c                      bcc.s     $000107BE
[00010762] 3802                      move.w    d2,d4
[00010764] e84c                      lsr.w     #4,d4
[00010766] 3e04                      move.w    d4,d7
[00010768] e84c                      lsr.w     #4,d4
[0001076a] 4647                      not.w     d7
[0001076c] 0247 000f                 andi.w    #$000F,d7
[00010770] de47                      add.w     d7,d7
[00010772] de47                      add.w     d7,d7
[00010774] 2649                      movea.l   a1,a3
[00010776] 4efb 7002                 jmp       $0001077A(pc,d7.w)
[0001077a] bb13                      eor.b     d5,(a3)
[0001077c] d6c1                      adda.w    d1,a3
[0001077e] bb13                      eor.b     d5,(a3)
[00010780] d6c1                      adda.w    d1,a3
[00010782] bb13                      eor.b     d5,(a3)
[00010784] d6c1                      adda.w    d1,a3
[00010786] bb13                      eor.b     d5,(a3)
[00010788] d6c1                      adda.w    d1,a3
[0001078a] bb13                      eor.b     d5,(a3)
[0001078c] d6c1                      adda.w    d1,a3
[0001078e] bb13                      eor.b     d5,(a3)
[00010790] d6c1                      adda.w    d1,a3
[00010792] bb13                      eor.b     d5,(a3)
[00010794] d6c1                      adda.w    d1,a3
[00010796] bb13                      eor.b     d5,(a3)
[00010798] d6c1                      adda.w    d1,a3
[0001079a] bb13                      eor.b     d5,(a3)
[0001079c] d6c1                      adda.w    d1,a3
[0001079e] bb13                      eor.b     d5,(a3)
[000107a0] d6c1                      adda.w    d1,a3
[000107a2] bb13                      eor.b     d5,(a3)
[000107a4] d6c1                      adda.w    d1,a3
[000107a6] bb13                      eor.b     d5,(a3)
[000107a8] d6c1                      adda.w    d1,a3
[000107aa] bb13                      eor.b     d5,(a3)
[000107ac] d6c1                      adda.w    d1,a3
[000107ae] bb13                      eor.b     d5,(a3)
[000107b0] d6c1                      adda.w    d1,a3
[000107b2] bb13                      eor.b     d5,(a3)
[000107b4] d6c1                      adda.w    d1,a3
[000107b6] bb13                      eor.b     d5,(a3)
[000107b8] d6c1                      adda.w    d1,a3
[000107ba] 51cc ffbe                 dbf       d4,$0001077A
[000107be] 5289                      addq.l    #1,a1
[000107c0] 5342                      subq.w    #1,d2
[000107c2] 51c8 ff9a                 dbf       d0,$0001075E
[000107c6] 265f                      movea.l   (a7)+,a3
[000107c8] 4e75                      rts
[000107ca] 4a6e 00ca                 tst.w     202(a6)
[000107ce] 661c                      bne.s     $000107EC
[000107d0] 226e 00c6                 movea.l   198(a6),a1
[000107d4] 780f                      moveq.l   #15,d4
[000107d6] c841                      and.w     d1,d4
[000107d8] d844                      add.w     d4,d4
[000107da] 3c31 4000                 move.w    0(a1,d4.w),d6
[000107de] 43fa 3c08                 lea.l     $000143E8(pc),a1
[000107e2] d2ee 00be                 adda.w    190(a6),a1
[000107e6] 6000 fdec                 bra       $000105D4
[000107ea] 4e75                      rts
[000107ec] 2f08                      move.l    a0,-(a7)
[000107ee] 2f0b                      move.l    a3,-(a7)
[000107f0] 206e 00c6                 movea.l   198(a6),a0
[000107f4] 780f                      moveq.l   #15,d4
[000107f6] c841                      and.w     d1,d4
[000107f8] e94c                      lsl.w     #4,d4
[000107fa] d0c4                      adda.w    d4,a0
[000107fc] 43fa 3bea                 lea.l     $000143E8(pc),a1
[00010800] d2ee 00be                 adda.w    190(a6),a1
[00010804] 0b09 0000                 movep.w   0(a1),d5
[00010808] 1a11                      move.b    (a1),d5
[0001080a] 3805                      move.w    d5,d4
[0001080c] 4844                      swap      d4
[0001080e] 3805                      move.w    d5,d4
[00010810] 4a6e 01b2                 tst.w     434(a6)
[00010814] 670a                      beq.s     $00010820
[00010816] 226e 01ae                 movea.l   430(a6),a1
[0001081a] c3ee 01b2                 muls.w    434(a6),d1
[0001081e] 6008                      bra.s     $00010828
[00010820] 2278 044e                 movea.l   ($0000044E).w,a1
[00010824] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010828] 48c0                      ext.l     d0
[0001082a] d280                      add.l     d0,d1
[0001082c] d3c1                      adda.l    d1,a1
[0001082e] 9440                      sub.w     d0,d2
[00010830] 7210                      moveq.l   #16,d1
[00010832] 7c0f                      moveq.l   #15,d6
[00010834] b446                      cmp.w     d6,d2
[00010836] 6c02                      bge.s     $0001083A
[00010838] 3c02                      move.w    d2,d6
[0001083a] de47                      add.w     d7,d7
[0001083c] 3e3b 700c                 move.w    $0001084A(pc,d7.w),d7
[00010840] 4ebb 7008                 jsr       $0001084A(pc,d7.w)
[00010844] 265f                      movea.l   (a7)+,a3
[00010846] 205f                      movea.l   (a7)+,a0
[00010848] 4e75                      rts
[0001084a] 0008 009e                 ori.b     #$9E,a0 ; apollo only
[0001084e] 0110                      btst      d0,(a0)
[00010850] 007e 3f05                 ori.w     #$3F05,???
[00010854] 0240 000f                 andi.w    #$000F,d0
[00010858] 1a30 0000                 move.b    0(a0,d0.w),d5
[0001085c] ca57                      and.w     (a7),d5
[0001085e] 3802                      move.w    d2,d4
[00010860] e84c                      lsr.w     #4,d4
[00010862] 3e04                      move.w    d4,d7
[00010864] e84c                      lsr.w     #4,d4
[00010866] 4647                      not.w     d7
[00010868] 0247 000f                 andi.w    #$000F,d7
[0001086c] de47                      add.w     d7,d7
[0001086e] de47                      add.w     d7,d7
[00010870] 2649                      movea.l   a1,a3
[00010872] 4efb 7002                 jmp       $00010876(pc,d7.w)
[00010876] 1685                      move.b    d5,(a3)
[00010878] d6c1                      adda.w    d1,a3
[0001087a] 1685                      move.b    d5,(a3)
[0001087c] d6c1                      adda.w    d1,a3
[0001087e] 1685                      move.b    d5,(a3)
[00010880] d6c1                      adda.w    d1,a3
[00010882] 1685                      move.b    d5,(a3)
[00010884] d6c1                      adda.w    d1,a3
[00010886] 1685                      move.b    d5,(a3)
[00010888] d6c1                      adda.w    d1,a3
[0001088a] 1685                      move.b    d5,(a3)
[0001088c] d6c1                      adda.w    d1,a3
[0001088e] 1685                      move.b    d5,(a3)
[00010890] d6c1                      adda.w    d1,a3
[00010892] 1685                      move.b    d5,(a3)
[00010894] d6c1                      adda.w    d1,a3
[00010896] 1685                      move.b    d5,(a3)
[00010898] d6c1                      adda.w    d1,a3
[0001089a] 1685                      move.b    d5,(a3)
[0001089c] d6c1                      adda.w    d1,a3
[0001089e] 1685                      move.b    d5,(a3)
[000108a0] d6c1                      adda.w    d1,a3
[000108a2] 1685                      move.b    d5,(a3)
[000108a4] d6c1                      adda.w    d1,a3
[000108a6] 1685                      move.b    d5,(a3)
[000108a8] d6c1                      adda.w    d1,a3
[000108aa] 1685                      move.b    d5,(a3)
[000108ac] d6c1                      adda.w    d1,a3
[000108ae] 1685                      move.b    d5,(a3)
[000108b0] d6c1                      adda.w    d1,a3
[000108b2] 1685                      move.b    d5,(a3)
[000108b4] d6c1                      adda.w    d1,a3
[000108b6] 51cc ffbe                 dbf       d4,$00010876
[000108ba] 5289                      addq.l    #1,a1
[000108bc] 5342                      subq.w    #1,d2
[000108be] 5240                      addq.w    #1,d0
[000108c0] 51ce ff92                 dbf       d6,$00010854
[000108c4] 3a1f                      move.w    (a7)+,d5
[000108c6] 4e75                      rts
[000108c8] 266e 0020                 movea.l   32(a6),a3
[000108cc] 2218                      move.l    (a0)+,d1
[000108ce] 4681                      not.l     d1
[000108d0] 26c1                      move.l    d1,(a3)+
[000108d2] 2218                      move.l    (a0)+,d1
[000108d4] 4681                      not.l     d1
[000108d6] 26c1                      move.l    d1,(a3)+
[000108d8] 2218                      move.l    (a0)+,d1
[000108da] 4681                      not.l     d1
[000108dc] 26c1                      move.l    d1,(a3)+
[000108de] 2218                      move.l    (a0)+,d1
[000108e0] 4681                      not.l     d1
[000108e2] 26c1                      move.l    d1,(a3)+
[000108e4] 206e 0020                 movea.l   32(a6),a0
[000108e8] 0240 000f                 andi.w    #$000F,d0
[000108ec] 4a30 0000                 tst.b     0(a0,d0.w)
[000108f0] 675c                      beq.s     $0001094E
[000108f2] 3802                      move.w    d2,d4
[000108f4] e84c                      lsr.w     #4,d4
[000108f6] 3e04                      move.w    d4,d7
[000108f8] e84c                      lsr.w     #4,d4
[000108fa] 4647                      not.w     d7
[000108fc] 0247 000f                 andi.w    #$000F,d7
[00010900] de47                      add.w     d7,d7
[00010902] de47                      add.w     d7,d7
[00010904] 2649                      movea.l   a1,a3
[00010906] 4efb 7002                 jmp       $0001090A(pc,d7.w)
[0001090a] 1685                      move.b    d5,(a3)
[0001090c] d6c1                      adda.w    d1,a3
[0001090e] 1685                      move.b    d5,(a3)
[00010910] d6c1                      adda.w    d1,a3
[00010912] 1685                      move.b    d5,(a3)
[00010914] d6c1                      adda.w    d1,a3
[00010916] 1685                      move.b    d5,(a3)
[00010918] d6c1                      adda.w    d1,a3
[0001091a] 1685                      move.b    d5,(a3)
[0001091c] d6c1                      adda.w    d1,a3
[0001091e] 1685                      move.b    d5,(a3)
[00010920] d6c1                      adda.w    d1,a3
[00010922] 1685                      move.b    d5,(a3)
[00010924] d6c1                      adda.w    d1,a3
[00010926] 1685                      move.b    d5,(a3)
[00010928] d6c1                      adda.w    d1,a3
[0001092a] 1685                      move.b    d5,(a3)
[0001092c] d6c1                      adda.w    d1,a3
[0001092e] 1685                      move.b    d5,(a3)
[00010930] d6c1                      adda.w    d1,a3
[00010932] 1685                      move.b    d5,(a3)
[00010934] d6c1                      adda.w    d1,a3
[00010936] 1685                      move.b    d5,(a3)
[00010938] d6c1                      adda.w    d1,a3
[0001093a] 1685                      move.b    d5,(a3)
[0001093c] d6c1                      adda.w    d1,a3
[0001093e] 1685                      move.b    d5,(a3)
[00010940] d6c1                      adda.w    d1,a3
[00010942] 1685                      move.b    d5,(a3)
[00010944] d6c1                      adda.w    d1,a3
[00010946] 1685                      move.b    d5,(a3)
[00010948] d6c1                      adda.w    d1,a3
[0001094a] 51cc ffbe                 dbf       d4,$0001090A
[0001094e] 5289                      addq.l    #1,a1
[00010950] 5342                      subq.w    #1,d2
[00010952] 5240                      addq.w    #1,d0
[00010954] 51ce ff92                 dbf       d6,$000108E8
[00010958] 4e75                      rts
[0001095a] 0240 000f                 andi.w    #$000F,d0
[0001095e] 1a30 0000                 move.b    0(a0,d0.w),d5
[00010962] 675c                      beq.s     $000109C0
[00010964] 3802                      move.w    d2,d4
[00010966] e84c                      lsr.w     #4,d4
[00010968] 3e04                      move.w    d4,d7
[0001096a] e84c                      lsr.w     #4,d4
[0001096c] 4647                      not.w     d7
[0001096e] 0247 000f                 andi.w    #$000F,d7
[00010972] de47                      add.w     d7,d7
[00010974] de47                      add.w     d7,d7
[00010976] 2649                      movea.l   a1,a3
[00010978] 4efb 7002                 jmp       $0001097C(pc,d7.w)
[0001097c] bb13                      eor.b     d5,(a3)
[0001097e] d6c1                      adda.w    d1,a3
[00010980] bb13                      eor.b     d5,(a3)
[00010982] d6c1                      adda.w    d1,a3
[00010984] bb13                      eor.b     d5,(a3)
[00010986] d6c1                      adda.w    d1,a3
[00010988] bb13                      eor.b     d5,(a3)
[0001098a] d6c1                      adda.w    d1,a3
[0001098c] bb13                      eor.b     d5,(a3)
[0001098e] d6c1                      adda.w    d1,a3
[00010990] bb13                      eor.b     d5,(a3)
[00010992] d6c1                      adda.w    d1,a3
[00010994] bb13                      eor.b     d5,(a3)
[00010996] d6c1                      adda.w    d1,a3
[00010998] bb13                      eor.b     d5,(a3)
[0001099a] d6c1                      adda.w    d1,a3
[0001099c] bb13                      eor.b     d5,(a3)
[0001099e] d6c1                      adda.w    d1,a3
[000109a0] bb13                      eor.b     d5,(a3)
[000109a2] d6c1                      adda.w    d1,a3
[000109a4] bb13                      eor.b     d5,(a3)
[000109a6] d6c1                      adda.w    d1,a3
[000109a8] bb13                      eor.b     d5,(a3)
[000109aa] d6c1                      adda.w    d1,a3
[000109ac] bb13                      eor.b     d5,(a3)
[000109ae] d6c1                      adda.w    d1,a3
[000109b0] bb13                      eor.b     d5,(a3)
[000109b2] d6c1                      adda.w    d1,a3
[000109b4] bb13                      eor.b     d5,(a3)
[000109b6] d6c1                      adda.w    d1,a3
[000109b8] bb13                      eor.b     d5,(a3)
[000109ba] d6c1                      adda.w    d1,a3
[000109bc] 51cc ffbe                 dbf       d4,$0001097C
[000109c0] 5289                      addq.l    #1,a1
[000109c2] 5342                      subq.w    #1,d2
[000109c4] 5240                      addq.w    #1,d0
[000109c6] 51ce ff92                 dbf       d6,$0001095A
[000109ca] 4e75                      rts
[000109cc] 9641                      sub.w     d1,d3
[000109ce] 382e 0046                 move.w    70(a6),d4
[000109d2] 43fa 3a14                 lea.l     $000143E8(pc),a1
[000109d6] 1831 4000                 move.b    0(a1,d4.w),d4
[000109da] 2278 044e                 movea.l   ($0000044E).w,a1
[000109de] 7a00                      moveq.l   #0,d5
[000109e0] 3a38 206e                 move.w    ($0000206E).w,d5
[000109e4] 4a6e 01b2                 tst.w     434(a6)
[000109e8] 6708                      beq.s     $000109F2
[000109ea] 226e 01ae                 movea.l   430(a6),a1
[000109ee] 3a2e 01b2                 move.w    434(a6),d5
[000109f2] c3c5                      muls.w    d5,d1
[000109f4] d3c1                      adda.l    d1,a1
[000109f6] d2c0                      adda.w    d0,a1
[000109f8] de47                      add.w     d7,d7
[000109fa] 3e3b 7006                 move.w    $00010A02(pc,d7.w),d7
[000109fe] 4efb 7002                 jmp       $00010A02(pc,d7.w)
J1:
[00010a02] 0122                      dc.w $0122   ; $00010b24-$00010a02
[00010a04] 000a                      dc.w $000a   ; $00010a0c-$00010a02
[00010a06] 009a                      dc.w $009a   ; $00010a9c-$00010a02
[00010a08] 0008                      dc.w $0008   ; $00010a0a-$00010a02
[00010a0a] 4646                      not.w     d6
[00010a0c] 3f05                      move.w    d5,-(a7)
[00010a0e] e94d                      lsl.w     #4,d5
[00010a10] 700f                      moveq.l   #15,d0
[00010a12] b640                      cmp.w     d0,d3
[00010a14] 6c02                      bge.s     $00010A18
[00010a16] 3003                      move.w    d3,d0
[00010a18] 2409                      move.l    a1,d2
[00010a1a] dc46                      add.w     d6,d6
[00010a1c] 645a                      bcc.s     $00010A78
[00010a1e] 3203                      move.w    d3,d1
[00010a20] e849                      lsr.w     #4,d1
[00010a22] 3e01                      move.w    d1,d7
[00010a24] e849                      lsr.w     #4,d1
[00010a26] 4647                      not.w     d7
[00010a28] 0247 000f                 andi.w    #$000F,d7
[00010a2c] de47                      add.w     d7,d7
[00010a2e] de47                      add.w     d7,d7
[00010a30] 4efb 7002                 jmp       $00010A34(pc,d7.w)
[00010a34] 1284                      move.b    d4,(a1)
[00010a36] d3c5                      adda.l    d5,a1
[00010a38] 1284                      move.b    d4,(a1)
[00010a3a] d3c5                      adda.l    d5,a1
[00010a3c] 1284                      move.b    d4,(a1)
[00010a3e] d3c5                      adda.l    d5,a1
[00010a40] 1284                      move.b    d4,(a1)
[00010a42] d3c5                      adda.l    d5,a1
[00010a44] 1284                      move.b    d4,(a1)
[00010a46] d3c5                      adda.l    d5,a1
[00010a48] 1284                      move.b    d4,(a1)
[00010a4a] d3c5                      adda.l    d5,a1
[00010a4c] 1284                      move.b    d4,(a1)
[00010a4e] d3c5                      adda.l    d5,a1
[00010a50] 1284                      move.b    d4,(a1)
[00010a52] d3c5                      adda.l    d5,a1
[00010a54] 1284                      move.b    d4,(a1)
[00010a56] d3c5                      adda.l    d5,a1
[00010a58] 1284                      move.b    d4,(a1)
[00010a5a] d3c5                      adda.l    d5,a1
[00010a5c] 1284                      move.b    d4,(a1)
[00010a5e] d3c5                      adda.l    d5,a1
[00010a60] 1284                      move.b    d4,(a1)
[00010a62] d3c5                      adda.l    d5,a1
[00010a64] 1284                      move.b    d4,(a1)
[00010a66] d3c5                      adda.l    d5,a1
[00010a68] 1284                      move.b    d4,(a1)
[00010a6a] d3c5                      adda.l    d5,a1
[00010a6c] 1284                      move.b    d4,(a1)
[00010a6e] d3c5                      adda.l    d5,a1
[00010a70] 1284                      move.b    d4,(a1)
[00010a72] d3c5                      adda.l    d5,a1
[00010a74] 51c9 ffbe                 dbf       d1,$00010A34
[00010a78] 2242                      movea.l   d2,a1
[00010a7a] d2d7                      adda.w    (a7),a1
[00010a7c] 5343                      subq.w    #1,d3
[00010a7e] 51c8 ff98                 dbf       d0,$00010A18
[00010a82] 548f                      addq.l    #2,a7
[00010a84] 4e75                      rts
[00010a86] d2c5                      adda.w    d5,a1
[00010a88] 51cb 0004                 dbf       d3,$00010A8E
[00010a8c] 4e75                      rts
[00010a8e] da45                      add.w     d5,d5
[00010a90] e24b                      lsr.w     #1,d3
[00010a92] b911                      eor.b     d4,(a1)
[00010a94] d2c5                      adda.w    d5,a1
[00010a96] 51cb fffa                 dbf       d3,$00010A92
[00010a9a] 4e75                      rts
[00010a9c] 78ff                      moveq.l   #-1,d4
[00010a9e] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010aa2] 67ea                      beq.s     $00010A8E
[00010aa4] bc7c 5555                 cmp.w     #$5555,d6
[00010aa8] 67dc                      beq.s     $00010A86
[00010aaa] 3f05                      move.w    d5,-(a7)
[00010aac] e94d                      lsl.w     #4,d5
[00010aae] 700f                      moveq.l   #15,d0
[00010ab0] b640                      cmp.w     d0,d3
[00010ab2] 6c02                      bge.s     $00010AB6
[00010ab4] 3003                      move.w    d3,d0
[00010ab6] 2409                      move.l    a1,d2
[00010ab8] dc46                      add.w     d6,d6
[00010aba] 645a                      bcc.s     $00010B16
[00010abc] 3203                      move.w    d3,d1
[00010abe] e849                      lsr.w     #4,d1
[00010ac0] 3e01                      move.w    d1,d7
[00010ac2] e849                      lsr.w     #4,d1
[00010ac4] 4647                      not.w     d7
[00010ac6] 0247 000f                 andi.w    #$000F,d7
[00010aca] de47                      add.w     d7,d7
[00010acc] de47                      add.w     d7,d7
[00010ace] 4efb 7002                 jmp       $00010AD2(pc,d7.w)
[00010ad2] b911                      eor.b     d4,(a1)
[00010ad4] d3c5                      adda.l    d5,a1
[00010ad6] b911                      eor.b     d4,(a1)
[00010ad8] d3c5                      adda.l    d5,a1
[00010ada] b911                      eor.b     d4,(a1)
[00010adc] d3c5                      adda.l    d5,a1
[00010ade] b911                      eor.b     d4,(a1)
[00010ae0] d3c5                      adda.l    d5,a1
[00010ae2] b911                      eor.b     d4,(a1)
[00010ae4] d3c5                      adda.l    d5,a1
[00010ae6] b911                      eor.b     d4,(a1)
[00010ae8] d3c5                      adda.l    d5,a1
[00010aea] b911                      eor.b     d4,(a1)
[00010aec] d3c5                      adda.l    d5,a1
[00010aee] b911                      eor.b     d4,(a1)
[00010af0] d3c5                      adda.l    d5,a1
[00010af2] b911                      eor.b     d4,(a1)
[00010af4] d3c5                      adda.l    d5,a1
[00010af6] b911                      eor.b     d4,(a1)
[00010af8] d3c5                      adda.l    d5,a1
[00010afa] b911                      eor.b     d4,(a1)
[00010afc] d3c5                      adda.l    d5,a1
[00010afe] b911                      eor.b     d4,(a1)
[00010b00] d3c5                      adda.l    d5,a1
[00010b02] b911                      eor.b     d4,(a1)
[00010b04] d3c5                      adda.l    d5,a1
[00010b06] b911                      eor.b     d4,(a1)
[00010b08] d3c5                      adda.l    d5,a1
[00010b0a] b911                      eor.b     d4,(a1)
[00010b0c] d3c5                      adda.l    d5,a1
[00010b0e] b911                      eor.b     d4,(a1)
[00010b10] d3c5                      adda.l    d5,a1
[00010b12] 51c9 ffbe                 dbf       d1,$00010AD2
[00010b16] 2242                      movea.l   d2,a1
[00010b18] d2d7                      adda.w    (a7),a1
[00010b1a] 5343                      subq.w    #1,d3
[00010b1c] 51c8 ff98                 dbf       d0,$00010AB6
[00010b20] 548f                      addq.l    #2,a7
[00010b22] 4e75                      rts
[00010b24] bc7c ffff                 cmp.w     #$FFFF,d6
[00010b28] 677c                      beq.s     $00010BA6
[00010b2a] 3f05                      move.w    d5,-(a7)
[00010b2c] e94d                      lsl.w     #4,d5
[00010b2e] 700f                      moveq.l   #15,d0
[00010b30] b640                      cmp.w     d0,d3
[00010b32] 6c02                      bge.s     $00010B36
[00010b34] 3003                      move.w    d3,d0
[00010b36] 2f09                      move.l    a1,-(a7)
[00010b38] dc46                      add.w     d6,d6
[00010b3a] 55c2                      scs       d2
[00010b3c] c444                      and.w     d4,d2
[00010b3e] 3203                      move.w    d3,d1
[00010b40] e849                      lsr.w     #4,d1
[00010b42] 3e01                      move.w    d1,d7
[00010b44] e849                      lsr.w     #4,d1
[00010b46] 4647                      not.w     d7
[00010b48] 0247 000f                 andi.w    #$000F,d7
[00010b4c] de47                      add.w     d7,d7
[00010b4e] de47                      add.w     d7,d7
[00010b50] 4efb 7002                 jmp       $00010B54(pc,d7.w)
[00010b54] 1282                      move.b    d2,(a1)
[00010b56] d3c5                      adda.l    d5,a1
[00010b58] 1282                      move.b    d2,(a1)
[00010b5a] d3c5                      adda.l    d5,a1
[00010b5c] 1282                      move.b    d2,(a1)
[00010b5e] d3c5                      adda.l    d5,a1
[00010b60] 1282                      move.b    d2,(a1)
[00010b62] d3c5                      adda.l    d5,a1
[00010b64] 1282                      move.b    d2,(a1)
[00010b66] d3c5                      adda.l    d5,a1
[00010b68] 1282                      move.b    d2,(a1)
[00010b6a] d3c5                      adda.l    d5,a1
[00010b6c] 1282                      move.b    d2,(a1)
[00010b6e] d3c5                      adda.l    d5,a1
[00010b70] 1282                      move.b    d2,(a1)
[00010b72] d3c5                      adda.l    d5,a1
[00010b74] 1282                      move.b    d2,(a1)
[00010b76] d3c5                      adda.l    d5,a1
[00010b78] 1282                      move.b    d2,(a1)
[00010b7a] d3c5                      adda.l    d5,a1
[00010b7c] 1282                      move.b    d2,(a1)
[00010b7e] d3c5                      adda.l    d5,a1
[00010b80] 1282                      move.b    d2,(a1)
[00010b82] d3c5                      adda.l    d5,a1
[00010b84] 1282                      move.b    d2,(a1)
[00010b86] d3c5                      adda.l    d5,a1
[00010b88] 1282                      move.b    d2,(a1)
[00010b8a] d3c5                      adda.l    d5,a1
[00010b8c] 1282                      move.b    d2,(a1)
[00010b8e] d3c5                      adda.l    d5,a1
[00010b90] 1282                      move.b    d2,(a1)
[00010b92] d3c5                      adda.l    d5,a1
[00010b94] 51c9 ffbe                 dbf       d1,$00010B54
[00010b98] 225f                      movea.l   (a7)+,a1
[00010b9a] d2d7                      adda.w    (a7),a1
[00010b9c] 5343                      subq.w    #1,d3
[00010b9e] 51c8 ff96                 dbf       d0,$00010B36
[00010ba2] 548f                      addq.l    #2,a7
[00010ba4] 4e75                      rts
[00010ba6] 3403                      move.w    d3,d2
[00010ba8] 4642                      not.w     d2
[00010baa] c47c 000f                 and.w     #$000F,d2
[00010bae] d442                      add.w     d2,d2
[00010bb0] d442                      add.w     d2,d2
[00010bb2] e84b                      lsr.w     #4,d3
[00010bb4] 4efb 2002                 jmp       $00010BB8(pc,d2.w)
[00010bb8] 1284                      move.b    d4,(a1)
[00010bba] d2c5                      adda.w    d5,a1
[00010bbc] 1284                      move.b    d4,(a1)
[00010bbe] d2c5                      adda.w    d5,a1
[00010bc0] 1284                      move.b    d4,(a1)
[00010bc2] d2c5                      adda.w    d5,a1
[00010bc4] 1284                      move.b    d4,(a1)
[00010bc6] d2c5                      adda.w    d5,a1
[00010bc8] 1284                      move.b    d4,(a1)
[00010bca] d2c5                      adda.w    d5,a1
[00010bcc] 1284                      move.b    d4,(a1)
[00010bce] d2c5                      adda.w    d5,a1
[00010bd0] 1284                      move.b    d4,(a1)
[00010bd2] d2c5                      adda.w    d5,a1
[00010bd4] 1284                      move.b    d4,(a1)
[00010bd6] d2c5                      adda.w    d5,a1
[00010bd8] 1284                      move.b    d4,(a1)
[00010bda] d2c5                      adda.w    d5,a1
[00010bdc] 1284                      move.b    d4,(a1)
[00010bde] d2c5                      adda.w    d5,a1
[00010be0] 1284                      move.b    d4,(a1)
[00010be2] d2c5                      adda.w    d5,a1
[00010be4] 1284                      move.b    d4,(a1)
[00010be6] d2c5                      adda.w    d5,a1
[00010be8] 1284                      move.b    d4,(a1)
[00010bea] d2c5                      adda.w    d5,a1
[00010bec] 1284                      move.b    d4,(a1)
[00010bee] d2c5                      adda.w    d5,a1
[00010bf0] 1284                      move.b    d4,(a1)
[00010bf2] d2c5                      adda.w    d5,a1
[00010bf4] 1284                      move.b    d4,(a1)
[00010bf6] d2c5                      adda.w    d5,a1
[00010bf8] 51cb ffbe                 dbf       d3,$00010BB8
[00010bfc] 4e75                      rts
[00010bfe] 2278 044e                 movea.l   ($0000044E).w,a1
[00010c02] 3a38 206e                 move.w    ($0000206E).w,d5
[00010c06] 4a6e 01b2                 tst.w     434(a6)
[00010c0a] 6708                      beq.s     $00010C14
[00010c0c] 226e 01ae                 movea.l   430(a6),a1
[00010c10] 3a2e 01b2                 move.w    434(a6),d5
[00010c14] 3805                      move.w    d5,d4
[00010c16] c9c1                      muls.w    d1,d4
[00010c18] d3c4                      adda.l    d4,a1
[00010c1a] d2c0                      adda.w    d0,a1
[00010c1c] 780f                      moveq.l   #15,d4
[00010c1e] c840                      and.w     d0,d4
[00010c20] e97e                      rol.w     d4,d6
[00010c22] 9440                      sub.w     d0,d2
[00010c24] 6b38                      bmi.s     $00010C5E
[00010c26] 9641                      sub.w     d1,d3
[00010c28] 6a04                      bpl.s     $00010C2E
[00010c2a] 4443                      neg.w     d3
[00010c2c] 4445                      neg.w     d5
[00010c2e] 2f08                      move.l    a0,-(a7)
[00010c30] 382e 0046                 move.w    70(a6),d4
[00010c34] 41fa 37b2                 lea.l     $000143E8(pc),a0
[00010c38] 1830 4000                 move.b    0(a0,d4.w),d4
[00010c3c] 205f                      movea.l   (a7)+,a0
[00010c3e] b443                      cmp.w     d3,d2
[00010c40] 6d26                      blt.s     $00010C68
[00010c42] 3002                      move.w    d2,d0
[00010c44] d06e 004e                 add.w     78(a6),d0
[00010c48] 6b14                      bmi.s     $00010C5E
[00010c4a] 3203                      move.w    d3,d1
[00010c4c] d241                      add.w     d1,d1
[00010c4e] 4442                      neg.w     d2
[00010c50] 3602                      move.w    d2,d3
[00010c52] d442                      add.w     d2,d2
[00010c54] de47                      add.w     d7,d7
[00010c56] 3e3b 7008                 move.w    $00010C60(pc,d7.w),d7
[00010c5a] 4efb 7004                 jmp       $00010C60(pc,d7.w)
[00010c5e] 4e75                      rts
[00010c60] 002a 0070 0096            ori.b     #$70,150(a2)
[00010c66] 006e 3003 d06e            ori.w     #$3003,-12178(a6)
[00010c6c] 004e 6bee                 ori.w     #$6BEE,a6 ; apollo only
[00010c70] 4443                      neg.w     d3
[00010c72] 3203                      move.w    d3,d1
[00010c74] d241                      add.w     d1,d1
[00010c76] d442                      add.w     d2,d2
[00010c78] de47                      add.w     d7,d7
[00010c7a] 3e3b 7006                 move.w    $00010C82(pc,d7.w),d7
[00010c7e] 4efb 7002                 jmp       $00010C82(pc,d7.w)
J2:
[00010c82] 009c                      dc.w $009c   ; $00010d1e-$00010c82
[00010c84] 00e8                      dc.w $00e8   ; $00010d6a-$00010c82
[00010c86] 0104                      dc.w $0104   ; $00010d86-$00010c82
[00010c88] 00e6                      dc.w $00e6   ; $00010d68-$00010c82
[00010c8a] bc7c                      dc.w $bc7c   ; $0000c8fe-$00010c82
[00010c8c] ffff                      dc.w $ffff   ; $00010c81-$00010c82
[00010c8e] 6728                      dc.w $6728   ; $000173aa-$00010c82
[00010c90] 7e00                      dc.w $7e00   ; $00018a82-$00010c82
[00010c92] e35e                      dc.w $e35e   ; $0000efe0-$00010c82
[00010c94] 640c                      dc.w $640c   ; $0001708e-$00010c82
[00010c96] 12c4                      dc.w $12c4   ; $00011f46-$00010c82
[00010c98] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010c9a] 6a12                      dc.w $6a12   ; $00017694-$00010c82
[00010c9c] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010c9e] fff4                      dc.w $fff4   ; $00010c76-$00010c82
[00010ca0] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010ca2] 12c7                      dc.w $12c7   ; $00011f49-$00010c82
[00010ca4] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010ca6] 6a06                      dc.w $6a06   ; $00017688-$00010c82
[00010ca8] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010caa] ffe8                      dc.w $ffe8   ; $00010c6a-$00010c82
[00010cac] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cae] d2c5                      dc.w $d2c5   ; $0000df47-$00010c82
[00010cb0] d642                      dc.w $d642   ; $0000e2c4-$00010c82
[00010cb2] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010cb4] ffde                      dc.w $ffde   ; $00010c60-$00010c82
[00010cb6] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cb8] 12c4                      dc.w $12c4   ; $00011f46-$00010c82
[00010cba] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010cbc] 6a06                      dc.w $6a06   ; $00017688-$00010c82
[00010cbe] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010cc0] fff8                      dc.w $fff8   ; $00010c7a-$00010c82
[00010cc2] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cc4] d2c5                      dc.w $d2c5   ; $0000df47-$00010c82
[00010cc6] d642                      dc.w $d642   ; $0000e2c4-$00010c82
[00010cc8] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010cca] ffee                      dc.w $ffee   ; $00010c70-$00010c82
[00010ccc] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cce] 4646                      dc.w $4646   ; $000152c8-$00010c82
[00010cd0] e35e                      dc.w $e35e   ; $0000efe0-$00010c82
[00010cd2] 640c                      dc.w $640c   ; $0001708e-$00010c82
[00010cd4] 12c4                      dc.w $12c4   ; $00011f46-$00010c82
[00010cd6] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010cd8] 6a12                      dc.w $6a12   ; $00017694-$00010c82
[00010cda] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010cdc] fff4                      dc.w $fff4   ; $00010c76-$00010c82
[00010cde] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010ce0] 5289                      dc.w $5289   ; $00015f0b-$00010c82
[00010ce2] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010ce4] 6a06                      dc.w $6a06   ; $00017688-$00010c82
[00010ce6] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010ce8] ffe8                      dc.w $ffe8   ; $00010c6a-$00010c82
[00010cea] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cec] d2c5                      dc.w $d2c5   ; $0000df47-$00010c82
[00010cee] d642                      dc.w $d642   ; $0000e2c4-$00010c82
[00010cf0] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010cf2] ffde                      dc.w $ffde   ; $00010c60-$00010c82
[00010cf4] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010cf6] 78ff                      dc.w $78ff   ; $00018581-$00010c82
[00010cf8] e35e                      dc.w $e35e   ; $0000efe0-$00010c82
[00010cfa] 640c                      dc.w $640c   ; $0001708e-$00010c82
[00010cfc] b919                      dc.w $b919   ; $0000c59b-$00010c82
[00010cfe] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010d00] 6a12                      dc.w $6a12   ; $00017694-$00010c82
[00010d02] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010d04] fff4                      dc.w $fff4   ; $00010c76-$00010c82
[00010d06] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010d08] 5289                      dc.w $5289   ; $00015f0b-$00010c82
[00010d0a] d641                      dc.w $d641   ; $0000e2c3-$00010c82
[00010d0c] 6a06                      dc.w $6a06   ; $00017688-$00010c82
[00010d0e] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010d10] ffe8                      dc.w $ffe8   ; $00010c6a-$00010c82
[00010d12] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010d14] d2c5                      dc.w $d2c5   ; $0000df47-$00010c82
[00010d16] d642                      dc.w $d642   ; $0000e2c4-$00010c82
[00010d18] 51c8                      dc.w $51c8   ; $00015e4a-$00010c82
[00010d1a] ffde                      dc.w $ffde   ; $00010c60-$00010c82
[00010d1c] 4e75                      dc.w $4e75   ; $00015af7-$00010c82
[00010d1e] bc7c ffff                 cmp.w     #$FFFF,d6
[00010d22] 672c                      beq.s     $00010D50
[00010d24] 7e00                      moveq.l   #0,d7
[00010d26] e35e                      rol.w     #1,d6
[00010d28] 640e                      bcc.s     $00010D38
[00010d2a] 1284                      move.b    d4,(a1)
[00010d2c] d2c5                      adda.w    d5,a1
[00010d2e] d642                      add.w     d2,d3
[00010d30] 6a14                      bpl.s     $00010D46
[00010d32] 51c8 fff2                 dbf       d0,$00010D26
[00010d36] 4e75                      rts
[00010d38] 1287                      move.b    d7,(a1)
[00010d3a] d2c5                      adda.w    d5,a1
[00010d3c] d642                      add.w     d2,d3
[00010d3e] 6a06                      bpl.s     $00010D46
[00010d40] 51c8 ffe4                 dbf       d0,$00010D26
[00010d44] 4e75                      rts
[00010d46] d641                      add.w     d1,d3
[00010d48] 5289                      addq.l    #1,a1
[00010d4a] 51c8 ffda                 dbf       d0,$00010D26
[00010d4e] 4e75                      rts
[00010d50] 1284                      move.b    d4,(a1)
[00010d52] d2c5                      adda.w    d5,a1
[00010d54] d642                      add.w     d2,d3
[00010d56] 6a06                      bpl.s     $00010D5E
[00010d58] 51c8 fff6                 dbf       d0,$00010D50
[00010d5c] 4e75                      rts
[00010d5e] d641                      add.w     d1,d3
[00010d60] 5289                      addq.l    #1,a1
[00010d62] 51c8 ffec                 dbf       d0,$00010D50
[00010d66] 4e75                      rts
[00010d68] 4646                      not.w     d6
[00010d6a] e35e                      rol.w     #1,d6
[00010d6c] 6402                      bcc.s     $00010D70
[00010d6e] 1284                      move.b    d4,(a1)
[00010d70] d2c5                      adda.w    d5,a1
[00010d72] d642                      add.w     d2,d3
[00010d74] 6a06                      bpl.s     $00010D7C
[00010d76] 51c8 fff2                 dbf       d0,$00010D6A
[00010d7a] 4e75                      rts
[00010d7c] d641                      add.w     d1,d3
[00010d7e] 5289                      addq.l    #1,a1
[00010d80] 51c8 ffe8                 dbf       d0,$00010D6A
[00010d84] 4e75                      rts
[00010d86] 78ff                      moveq.l   #-1,d4
[00010d88] e35e                      rol.w     #1,d6
[00010d8a] 6402                      bcc.s     $00010D8E
[00010d8c] b911                      eor.b     d4,(a1)
[00010d8e] d2c5                      adda.w    d5,a1
[00010d90] d642                      add.w     d2,d3
[00010d92] 6a06                      bpl.s     $00010D9A
[00010d94] 51c8 fff2                 dbf       d0,$00010D88
[00010d98] 4e75                      rts
[00010d9a] d641                      add.w     d1,d3
[00010d9c] 5289                      addq.l    #1,a1
[00010d9e] 51c8 ffe8                 dbf       d0,$00010D88
[00010da2] 4e75                      rts
[00010da4] 286e 00c6                 movea.l   198(a6),a4
[00010da8] 2278 044e                 movea.l   ($0000044E).w,a1
[00010dac] 3838 206e                 move.w    ($0000206E).w,d4
[00010db0] 4a6e 01b2                 tst.w     434(a6)
[00010db4] 6708                      beq.s     $00010DBE
[00010db6] 226e 01ae                 movea.l   430(a6),a1
[00010dba] 382e 01b2                 move.w    434(a6),d4
[00010dbe] 206e 0020                 movea.l   32(a6),a0
[00010dc2] 9641                      sub.w     d1,d3
[00010dc4] 7c00                      moveq.l   #0,d6
[00010dc6] 3c04                      move.w    d4,d6
[00010dc8] c9c1                      muls.w    d1,d4
[00010dca] d3c4                      adda.l    d4,a1
[00010dcc] 3f06                      move.w    d6,-(a7)
[00010dce] 3e2e 003c                 move.w    60(a6),d7
[00010dd2] 5347                      subq.w    #1,d7
[00010dd4] 6700 0590                 beq       $00011366
[00010dd8] 5547                      subq.w    #2,d7
[00010dda] 6700 076c                 beq       $00011548
[00010dde] 78fc                      moveq.l   #-4,d4
[00010de0] c840                      and.w     d0,d4
[00010de2] d2c4                      adda.w    d4,a1
[00010de4] 7afc                      moveq.l   #-4,d5
[00010de6] ca42                      and.w     d2,d5
[00010de8] 9a44                      sub.w     d4,d5
[00010dea] e94e                      lsl.w     #4,d6
[00010dec] 9c45                      sub.w     d5,d6
[00010dee] 2646                      movea.l   d6,a3
[00010df0] 5247                      addq.w    #1,d7
[00010df2] 6700 0250                 beq       $00011044
[00010df6] 4bfa 35f0                 lea.l     $000143E8(pc),a5
[00010dfa] daee 00be                 adda.w    190(a6),a5
[00010dfe] 0f0d 0000                 movep.w   0(a5),d7
[00010e02] 1e15                      move.b    (a5),d7
[00010e04] 3c07                      move.w    d7,d6
[00010e06] 4847                      swap      d7
[00010e08] 3e06                      move.w    d6,d7
[00010e0a] 2f08                      move.l    a0,-(a7)
[00010e0c] 4a6e 00ca                 tst.w     202(a6)
[00010e10] 674e                      beq.s     $00010E60
[00010e12] 7c0f                      moveq.l   #15,d6
[00010e14] c246                      and.w     d6,d1
[00010e16] 672a                      beq.s     $00010E42
[00010e18] 3a01                      move.w    d1,d5
[00010e1a] bd45                      eor.w     d6,d5
[00010e1c] 3c01                      move.w    d1,d6
[00010e1e] 5346                      subq.w    #1,d6
[00010e20] e949                      lsl.w     #4,d1
[00010e22] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00010e26] 221a                      move.l    (a2)+,d1
[00010e28] c287                      and.l     d7,d1
[00010e2a] 20c1                      move.l    d1,(a0)+
[00010e2c] 221a                      move.l    (a2)+,d1
[00010e2e] c287                      and.l     d7,d1
[00010e30] 20c1                      move.l    d1,(a0)+
[00010e32] 221a                      move.l    (a2)+,d1
[00010e34] c287                      and.l     d7,d1
[00010e36] 20c1                      move.l    d1,(a0)+
[00010e38] 221a                      move.l    (a2)+,d1
[00010e3a] c287                      and.l     d7,d1
[00010e3c] 20c1                      move.l    d1,(a0)+
[00010e3e] 51cd ffe6                 dbf       d5,$00010E26
[00010e42] 221c                      move.l    (a4)+,d1
[00010e44] c287                      and.l     d7,d1
[00010e46] 20c1                      move.l    d1,(a0)+
[00010e48] 221c                      move.l    (a4)+,d1
[00010e4a] c287                      and.l     d7,d1
[00010e4c] 20c1                      move.l    d1,(a0)+
[00010e4e] 221c                      move.l    (a4)+,d1
[00010e50] c287                      and.l     d7,d1
[00010e52] 20c1                      move.l    d1,(a0)+
[00010e54] 221c                      move.l    (a4)+,d1
[00010e56] c287                      and.l     d7,d1
[00010e58] 20c1                      move.l    d1,(a0)+
[00010e5a] 51ce ffe6                 dbf       d6,$00010E42
[00010e5e] 6078                      bra.s     $00010ED8
[00010e60] 4dfa 3786                 lea.l     $000145E8(pc),a6
[00010e64] 7c0f                      moveq.l   #15,d6
[00010e66] c246                      and.w     d6,d1
[00010e68] 673e                      beq.s     $00010EA8
[00010e6a] 3a01                      move.w    d1,d5
[00010e6c] bd45                      eor.w     d6,d5
[00010e6e] 3c01                      move.w    d1,d6
[00010e70] 5346                      subq.w    #1,d6
[00010e72] d241                      add.w     d1,d1
[00010e74] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00010e78] 7200                      moveq.l   #0,d1
[00010e7a] 121a                      move.b    (a2)+,d1
[00010e7c] e749                      lsl.w     #3,d1
[00010e7e] 2a4e                      movea.l   a6,a5
[00010e80] dac1                      adda.w    d1,a5
[00010e82] 221d                      move.l    (a5)+,d1
[00010e84] c287                      and.l     d7,d1
[00010e86] 20c1                      move.l    d1,(a0)+
[00010e88] 221d                      move.l    (a5)+,d1
[00010e8a] c287                      and.l     d7,d1
[00010e8c] 20c1                      move.l    d1,(a0)+
[00010e8e] 7200                      moveq.l   #0,d1
[00010e90] 121a                      move.b    (a2)+,d1
[00010e92] e749                      lsl.w     #3,d1
[00010e94] 2a4e                      movea.l   a6,a5
[00010e96] dac1                      adda.w    d1,a5
[00010e98] 221d                      move.l    (a5)+,d1
[00010e9a] c287                      and.l     d7,d1
[00010e9c] 20c1                      move.l    d1,(a0)+
[00010e9e] 221d                      move.l    (a5)+,d1
[00010ea0] c287                      and.l     d7,d1
[00010ea2] 20c1                      move.l    d1,(a0)+
[00010ea4] 51cd ffd2                 dbf       d5,$00010E78
[00010ea8] 7200                      moveq.l   #0,d1
[00010eaa] 121c                      move.b    (a4)+,d1
[00010eac] e749                      lsl.w     #3,d1
[00010eae] 2a4e                      movea.l   a6,a5
[00010eb0] dac1                      adda.w    d1,a5
[00010eb2] 221d                      move.l    (a5)+,d1
[00010eb4] c287                      and.l     d7,d1
[00010eb6] 20c1                      move.l    d1,(a0)+
[00010eb8] 221d                      move.l    (a5)+,d1
[00010eba] c287                      and.l     d7,d1
[00010ebc] 20c1                      move.l    d1,(a0)+
[00010ebe] 7200                      moveq.l   #0,d1
[00010ec0] 121c                      move.b    (a4)+,d1
[00010ec2] e749                      lsl.w     #3,d1
[00010ec4] 2a4e                      movea.l   a6,a5
[00010ec6] dac1                      adda.w    d1,a5
[00010ec8] 221d                      move.l    (a5)+,d1
[00010eca] c287                      and.l     d7,d1
[00010ecc] 20c1                      move.l    d1,(a0)+
[00010ece] 221d                      move.l    (a5)+,d1
[00010ed0] c287                      and.l     d7,d1
[00010ed2] 20c1                      move.l    d1,(a0)+
[00010ed4] 51ce ffd2                 dbf       d6,$00010EA8
[00010ed8] 205f                      movea.l   (a7)+,a0
[00010eda] 3c02                      move.w    d2,d6
[00010edc] e84a                      lsr.w     #4,d2
[00010ede] 3800                      move.w    d0,d4
[00010ee0] e84c                      lsr.w     #4,d4
[00010ee2] 9444                      sub.w     d4,d2
[00010ee4] 5342                      subq.w    #1,d2
[00010ee6] 6b00 0108                 bmi       $00010FF0
[00010eea] 780c                      moveq.l   #12,d4
[00010eec] c840                      and.w     d0,d4
[00010eee] 247b 400c                 movea.l   $00010EFC(pc,d4.w),a2
[00010ef2] 7a0c                      moveq.l   #12,d5
[00010ef4] ca46                      and.w     d6,d5
[00010ef6] 2c7b 5014                 movea.l   $00010F0C(pc,d5.w),a6
[00010efa] 6040                      bra.s     $00010F3C
[00010efc] 0001 0f94                 ori.b     #$94,d1
[00010f00] 0001 0f88                 ori.b     #$88,d1
[00010f04] 0001 0f7c                 ori.b     #$7C,d1
[00010f08] 0001 0f70                 ori.b     #$70,d1
[00010f0c] 0001 0fb8                 ori.b     #$B8,d1
[00010f10] 0001 0fbc                 ori.b     #$BC,d1
[00010f14] 0001 0fc2                 ori.b     #$C2,d1
[00010f18] 0001 0fca                 ori.b     #$CA,d1
[00010f1c] ffff ffff 00ff ffff       vperm     #$00FFFFFF,e23,e23,e23
[00010f24] 0000 ffff                 ori.b     #$FF,d0
[00010f28] 0000 00ff                 ori.b     #$FF,d0
[00010f2c] ff00                      dc.w      $FF00 ; illegal
[00010f2e] 0000 ffff                 ori.b     #$FF,d0
[00010f32] 0000 ffff                 ori.b     #$FF,d0
[00010f36] ff00                      dc.w      $FF00 ; illegal
[00010f38] ffff ffff 7803 c044       vperm     #$7803C044,e23,e23,e23
[00010f40] cc44                      and.w     d4,d6
[00010f42] d040                      add.w     d0,d0
[00010f44] d040                      add.w     d0,d0
[00010f46] dc46                      add.w     d6,d6
[00010f48] dc46                      add.w     d6,d6
[00010f4a] 283b 00d0                 move.l    $00010F1C(pc,d0.w),d4
[00010f4e] 2a3b 60dc                 move.l    $00010F2C(pc,d6.w),d5
[00010f52] 700f                      moveq.l   #15,d0
[00010f54] b640                      cmp.w     d0,d3
[00010f56] 6c02                      bge.s     $00010F5A
[00010f58] 3003                      move.w    d3,d0
[00010f5a] 4843                      swap      d3
[00010f5c] 3600                      move.w    d0,d3
[00010f5e] 4843                      swap      d3
[00010f60] 3203                      move.w    d3,d1
[00010f62] e849                      lsr.w     #4,d1
[00010f64] 2858                      movea.l   (a0)+,a4
[00010f66] 2a58                      movea.l   (a0)+,a5
[00010f68] 2c18                      move.l    (a0)+,d6
[00010f6a] 2e18                      move.l    (a0)+,d7
[00010f6c] 2f09                      move.l    a1,-(a7)
[00010f6e] 4ed2                      jmp       (a2)
[00010f70] 8991                      or.l      d4,(a1)
[00010f72] 2007                      move.l    d7,d0
[00010f74] 4680                      not.l     d0
[00010f76] c084                      and.l     d4,d0
[00010f78] b199                      eor.l     d0,(a1)+
[00010f7a] 6028                      bra.s     $00010FA4
[00010f7c] 8991                      or.l      d4,(a1)
[00010f7e] 2006                      move.l    d6,d0
[00010f80] 4680                      not.l     d0
[00010f82] c084                      and.l     d4,d0
[00010f84] b199                      eor.l     d0,(a1)+
[00010f86] 601a                      bra.s     $00010FA2
[00010f88] 8991                      or.l      d4,(a1)
[00010f8a] 200d                      move.l    a5,d0
[00010f8c] 4680                      not.l     d0
[00010f8e] c084                      and.l     d4,d0
[00010f90] b199                      eor.l     d0,(a1)+
[00010f92] 600c                      bra.s     $00010FA0
[00010f94] 8991                      or.l      d4,(a1)
[00010f96] 200c                      move.l    a4,d0
[00010f98] 4680                      not.l     d0
[00010f9a] c084                      and.l     d4,d0
[00010f9c] b199                      eor.l     d0,(a1)+
[00010f9e] 22cd                      move.l    a5,(a1)+
[00010fa0] 22c6                      move.l    d6,(a1)+
[00010fa2] 22c7                      move.l    d7,(a1)+
[00010fa4] 3002                      move.w    d2,d0
[00010fa6] 5340                      subq.w    #1,d0
[00010fa8] 6b0c                      bmi.s     $00010FB6
[00010faa] 22cc                      move.l    a4,(a1)+
[00010fac] 22cd                      move.l    a5,(a1)+
[00010fae] 22c6                      move.l    d6,(a1)+
[00010fb0] 22c7                      move.l    d7,(a1)+
[00010fb2] 51c8 fff6                 dbf       d0,$00010FAA
[00010fb6] 4ed6                      jmp       (a6)
[00010fb8] 200c                      move.l    a4,d0
[00010fba] 6016                      bra.s     $00010FD2
[00010fbc] 22cc                      move.l    a4,(a1)+
[00010fbe] 200d                      move.l    a5,d0
[00010fc0] 6010                      bra.s     $00010FD2
[00010fc2] 22cc                      move.l    a4,(a1)+
[00010fc4] 22cd                      move.l    a5,(a1)+
[00010fc6] 2006                      move.l    d6,d0
[00010fc8] 6008                      bra.s     $00010FD2
[00010fca] 22cc                      move.l    a4,(a1)+
[00010fcc] 22cd                      move.l    a5,(a1)+
[00010fce] 22c6                      move.l    d6,(a1)+
[00010fd0] 2007                      move.l    d7,d0
[00010fd2] 8b91                      or.l      d5,(a1)
[00010fd4] 4680                      not.l     d0
[00010fd6] c085                      and.l     d5,d0
[00010fd8] b191                      eor.l     d0,(a1)
[00010fda] d3cb                      adda.l    a3,a1
[00010fdc] 51c9 ff90                 dbf       d1,$00010F6E
[00010fe0] 225f                      movea.l   (a7)+,a1
[00010fe2] d2d7                      adda.w    (a7),a1
[00010fe4] 5343                      subq.w    #1,d3
[00010fe6] 4843                      swap      d3
[00010fe8] 51cb ff74                 dbf       d3,$00010F5E
[00010fec] 548f                      addq.l    #2,a7
[00010fee] 4e75                      rts
[00010ff0] 365f                      movea.w   (a7)+,a3
[00010ff2] 720f                      moveq.l   #15,d1
[00010ff4] 9c40                      sub.w     d0,d6
[00010ff6] 96c6                      suba.w    d6,a3
[00010ff8] b346                      eor.w     d1,d6
[00010ffa] dc46                      add.w     d6,d6
[00010ffc] 45fb 601e                 lea.l     $0001101C(pc,d6.w),a2
[00011000] c041                      and.w     d1,d0
[00011002] d0c0                      adda.w    d0,a0
[00011004] c07c 0003                 and.w     #$0003,d0
[00011008] d2c0                      adda.w    d0,a1
[0001100a] 2848                      movea.l   a0,a4
[0001100c] 41e8 0010                 lea.l     16(a0),a0
[00011010] 51c9 0008                 dbf       d1,$0001101A
[00011014] 720f                      moveq.l   #15,d1
[00011016] 41e8 ff00                 lea.l     -256(a0),a0
[0001101a] 4ed2                      jmp       (a2)
[0001101c] 12dc                      move.b    (a4)+,(a1)+
[0001101e] 12dc                      move.b    (a4)+,(a1)+
[00011020] 12dc                      move.b    (a4)+,(a1)+
[00011022] 12dc                      move.b    (a4)+,(a1)+
[00011024] 12dc                      move.b    (a4)+,(a1)+
[00011026] 12dc                      move.b    (a4)+,(a1)+
[00011028] 12dc                      move.b    (a4)+,(a1)+
[0001102a] 12dc                      move.b    (a4)+,(a1)+
[0001102c] 12dc                      move.b    (a4)+,(a1)+
[0001102e] 12dc                      move.b    (a4)+,(a1)+
[00011030] 12dc                      move.b    (a4)+,(a1)+
[00011032] 12dc                      move.b    (a4)+,(a1)+
[00011034] 12dc                      move.b    (a4)+,(a1)+
[00011036] 12dc                      move.b    (a4)+,(a1)+
[00011038] 12dc                      move.b    (a4)+,(a1)+
[0001103a] 129c                      move.b    (a4)+,(a1)
[0001103c] d2cb                      adda.w    a3,a1
[0001103e] 51cb ffca                 dbf       d3,$0001100A
[00011042] 4e75                      rts
[00011044] 3c2e 00c0                 move.w    192(a6),d6
[00011048] 6700 01aa                 beq       $000111F4
[0001104c] 5346                      subq.w    #1,d6
[0001104e] 6700 021e                 beq       $0001126E
[00011052] 5346                      subq.w    #1,d6
[00011054] 660a                      bne.s     $00011060
[00011056] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[0001105c] 6700 0210                 beq       $0001126E
[00011060] 2a48                      movea.l   a0,a5
[00011062] 4a6e 00ca                 tst.w     202(a6)
[00011066] 672e                      beq.s     $00011096
[00011068] 7c0f                      moveq.l   #15,d6
[0001106a] c246                      and.w     d6,d1
[0001106c] 671a                      beq.s     $00011088
[0001106e] 3a01                      move.w    d1,d5
[00011070] bd45                      eor.w     d6,d5
[00011072] 3c01                      move.w    d1,d6
[00011074] 5346                      subq.w    #1,d6
[00011076] e949                      lsl.w     #4,d1
[00011078] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001107c] 2ada                      move.l    (a2)+,(a5)+
[0001107e] 2ada                      move.l    (a2)+,(a5)+
[00011080] 2ada                      move.l    (a2)+,(a5)+
[00011082] 2ada                      move.l    (a2)+,(a5)+
[00011084] 51cd fff6                 dbf       d5,$0001107C
[00011088] 2adc                      move.l    (a4)+,(a5)+
[0001108a] 2adc                      move.l    (a4)+,(a5)+
[0001108c] 2adc                      move.l    (a4)+,(a5)+
[0001108e] 2adc                      move.l    (a4)+,(a5)+
[00011090] 51ce fff6                 dbf       d6,$00011088
[00011094] 6058                      bra.s     $000110EE
[00011096] 4dfa 3550                 lea.l     $000145E8(pc),a6
[0001109a] 7c0f                      moveq.l   #15,d6
[0001109c] c246                      and.w     d6,d1
[0001109e] 672e                      beq.s     $000110CE
[000110a0] 3a01                      move.w    d1,d5
[000110a2] bd45                      eor.w     d6,d5
[000110a4] 3c01                      move.w    d1,d6
[000110a6] 5346                      subq.w    #1,d6
[000110a8] d241                      add.w     d1,d1
[000110aa] 45f4 1000                 lea.l     0(a4,d1.w),a2
[000110ae] 7200                      moveq.l   #0,d1
[000110b0] 121a                      move.b    (a2)+,d1
[000110b2] e749                      lsl.w     #3,d1
[000110b4] 2af6 1000                 move.l    0(a6,d1.w),(a5)+
[000110b8] 2af6 1004                 move.l    4(a6,d1.w),(a5)+
[000110bc] 7200                      moveq.l   #0,d1
[000110be] 121a                      move.b    (a2)+,d1
[000110c0] e749                      lsl.w     #3,d1
[000110c2] 2af6 1000                 move.l    0(a6,d1.w),(a5)+
[000110c6] 2af6 1004                 move.l    4(a6,d1.w),(a5)+
[000110ca] 51cd ffe2                 dbf       d5,$000110AE
[000110ce] 7200                      moveq.l   #0,d1
[000110d0] 121c                      move.b    (a4)+,d1
[000110d2] e749                      lsl.w     #3,d1
[000110d4] 2af6 1000                 move.l    0(a6,d1.w),(a5)+
[000110d8] 2af6 1004                 move.l    4(a6,d1.w),(a5)+
[000110dc] 7200                      moveq.l   #0,d1
[000110de] 121c                      move.b    (a4)+,d1
[000110e0] e749                      lsl.w     #3,d1
[000110e2] 2af6 1000                 move.l    0(a6,d1.w),(a5)+
[000110e6] 2af6 1004                 move.l    4(a6,d1.w),(a5)+
[000110ea] 51ce ffe2                 dbf       d6,$000110CE
[000110ee] 3c02                      move.w    d2,d6
[000110f0] e84a                      lsr.w     #4,d2
[000110f2] 3800                      move.w    d0,d4
[000110f4] e84c                      lsr.w     #4,d4
[000110f6] 9444                      sub.w     d4,d2
[000110f8] 5342                      subq.w    #1,d2
[000110fa] 6b00 00fc                 bmi       $000111F8
[000110fe] 780c                      moveq.l   #12,d4
[00011100] c840                      and.w     d0,d4
[00011102] 247b 400c                 movea.l   $00011110(pc,d4.w),a2
[00011106] 7a0c                      moveq.l   #12,d5
[00011108] ca46                      and.w     d6,d5
[0001110a] 2c7b 5014                 movea.l   $00011120(pc,d5.w),a6
[0001110e] 6040                      bra.s     $00011150
[00011110] 0001 11a0                 ori.b     #$A0,d1
[00011114] 0001 1198                 ori.b     #$98,d1
[00011118] 0001 1190                 ori.b     #$90,d1
[0001111c] 0001 1188                 ori.b     #$88,d1
[00011120] 0001 11c0                 ori.b     #$C0,d1
[00011124] 0001 11c4                 ori.b     #$C4,d1
[00011128] 0001 11ca                 ori.b     #$CA,d1
[0001112c] 0001 11d2                 ori.b     #$D2,d1
[00011130] ffff ffff 00ff ffff       vperm     #$00FFFFFF,e23,e23,e23
[00011138] 0000 ffff                 ori.b     #$FF,d0
[0001113c] 0000 00ff                 ori.b     #$FF,d0
[00011140] ff00                      dc.w      $FF00 ; illegal
[00011142] 0000 ffff                 ori.b     #$FF,d0
[00011146] 0000 ffff                 ori.b     #$FF,d0
[0001114a] ff00                      dc.w      $FF00 ; illegal
[0001114c] ffff ffff 7803 c044       vperm     #$7803C044,e23,e23,e23
[00011154] cc44                      and.w     d4,d6
[00011156] d040                      add.w     d0,d0
[00011158] d040                      add.w     d0,d0
[0001115a] dc46                      add.w     d6,d6
[0001115c] dc46                      add.w     d6,d6
[0001115e] 283b 00d0                 move.l    $00011130(pc,d0.w),d4
[00011162] 2a3b 60dc                 move.l    $00011140(pc,d6.w),d5
[00011166] 700f                      moveq.l   #15,d0
[00011168] b640                      cmp.w     d0,d3
[0001116a] 6c02                      bge.s     $0001116E
[0001116c] 3003                      move.w    d3,d0
[0001116e] 4843                      swap      d3
[00011170] 3600                      move.w    d0,d3
[00011172] 4843                      swap      d3
[00011174] 3203                      move.w    d3,d1
[00011176] e849                      lsr.w     #4,d1
[00011178] 2f03                      move.l    d3,-(a7)
[0001117a] 2f09                      move.l    a1,-(a7)
[0001117c] 3f02                      move.w    d2,-(a7)
[0001117e] 2418                      move.l    (a0)+,d2
[00011180] 2618                      move.l    (a0)+,d3
[00011182] 2c18                      move.l    (a0)+,d6
[00011184] 2e18                      move.l    (a0)+,d7
[00011186] 4ed2                      jmp       (a2)
[00011188] 2007                      move.l    d7,d0
[0001118a] c084                      and.l     d4,d0
[0001118c] b199                      eor.l     d0,(a1)+
[0001118e] 601c                      bra.s     $000111AC
[00011190] 2006                      move.l    d6,d0
[00011192] c084                      and.l     d4,d0
[00011194] b199                      eor.l     d0,(a1)+
[00011196] 6012                      bra.s     $000111AA
[00011198] 2003                      move.l    d3,d0
[0001119a] c084                      and.l     d4,d0
[0001119c] b199                      eor.l     d0,(a1)+
[0001119e] 6008                      bra.s     $000111A8
[000111a0] 2002                      move.l    d2,d0
[000111a2] c084                      and.l     d4,d0
[000111a4] b199                      eor.l     d0,(a1)+
[000111a6] b799                      eor.l     d3,(a1)+
[000111a8] bd99                      eor.l     d6,(a1)+
[000111aa] bf99                      eor.l     d7,(a1)+
[000111ac] 3017                      move.w    (a7),d0
[000111ae] 5340                      subq.w    #1,d0
[000111b0] 6b0c                      bmi.s     $000111BE
[000111b2] b599                      eor.l     d2,(a1)+
[000111b4] b799                      eor.l     d3,(a1)+
[000111b6] bd99                      eor.l     d6,(a1)+
[000111b8] bf99                      eor.l     d7,(a1)+
[000111ba] 51c8 fff6                 dbf       d0,$000111B2
[000111be] 4ed6                      jmp       (a6)
[000111c0] 2002                      move.l    d2,d0
[000111c2] 6016                      bra.s     $000111DA
[000111c4] b599                      eor.l     d2,(a1)+
[000111c6] 2003                      move.l    d3,d0
[000111c8] 6010                      bra.s     $000111DA
[000111ca] b599                      eor.l     d2,(a1)+
[000111cc] b799                      eor.l     d3,(a1)+
[000111ce] 2006                      move.l    d6,d0
[000111d0] 6008                      bra.s     $000111DA
[000111d2] b599                      eor.l     d2,(a1)+
[000111d4] b799                      eor.l     d3,(a1)+
[000111d6] bd99                      eor.l     d6,(a1)+
[000111d8] 2007                      move.l    d7,d0
[000111da] c085                      and.l     d5,d0
[000111dc] b191                      eor.l     d0,(a1)
[000111de] d3cb                      adda.l    a3,a1
[000111e0] 51c9 ffa4                 dbf       d1,$00011186
[000111e4] 341f                      move.w    (a7)+,d2
[000111e6] 225f                      movea.l   (a7)+,a1
[000111e8] 261f                      move.l    (a7)+,d3
[000111ea] d2d7                      adda.w    (a7),a1
[000111ec] 5343                      subq.w    #1,d3
[000111ee] 4843                      swap      d3
[000111f0] 51cb ff80                 dbf       d3,$00011172
[000111f4] 548f                      addq.l    #2,a7
[000111f6] 4e75                      rts
[000111f8] 365f                      movea.w   (a7)+,a3
[000111fa] 720f                      moveq.l   #15,d1
[000111fc] 9c40                      sub.w     d0,d6
[000111fe] 96c6                      suba.w    d6,a3
[00011200] b346                      eor.w     d1,d6
[00011202] dc46                      add.w     d6,d6
[00011204] dc46                      add.w     d6,d6
[00011206] 45fb 601e                 lea.l     $00011226(pc,d6.w),a2
[0001120a] c041                      and.w     d1,d0
[0001120c] d0c0                      adda.w    d0,a0
[0001120e] c07c 0003                 and.w     #$0003,d0
[00011212] d2c0                      adda.w    d0,a1
[00011214] 2848                      movea.l   a0,a4
[00011216] 41e8 0010                 lea.l     16(a0),a0
[0001121a] 51c9 0008                 dbf       d1,$00011224
[0001121e] 720f                      moveq.l   #15,d1
[00011220] 41e8 ff00                 lea.l     -256(a0),a0
[00011224] 4ed2                      jmp       (a2)
[00011226] 101c                      move.b    (a4)+,d0
[00011228] b119                      eor.b     d0,(a1)+
[0001122a] 101c                      move.b    (a4)+,d0
[0001122c] b119                      eor.b     d0,(a1)+
[0001122e] 101c                      move.b    (a4)+,d0
[00011230] b119                      eor.b     d0,(a1)+
[00011232] 101c                      move.b    (a4)+,d0
[00011234] b119                      eor.b     d0,(a1)+
[00011236] 101c                      move.b    (a4)+,d0
[00011238] b119                      eor.b     d0,(a1)+
[0001123a] 101c                      move.b    (a4)+,d0
[0001123c] b119                      eor.b     d0,(a1)+
[0001123e] 101c                      move.b    (a4)+,d0
[00011240] b119                      eor.b     d0,(a1)+
[00011242] 101c                      move.b    (a4)+,d0
[00011244] b119                      eor.b     d0,(a1)+
[00011246] 101c                      move.b    (a4)+,d0
[00011248] b119                      eor.b     d0,(a1)+
[0001124a] 101c                      move.b    (a4)+,d0
[0001124c] b119                      eor.b     d0,(a1)+
[0001124e] 101c                      move.b    (a4)+,d0
[00011250] b119                      eor.b     d0,(a1)+
[00011252] 101c                      move.b    (a4)+,d0
[00011254] b119                      eor.b     d0,(a1)+
[00011256] 101c                      move.b    (a4)+,d0
[00011258] b119                      eor.b     d0,(a1)+
[0001125a] 101c                      move.b    (a4)+,d0
[0001125c] b119                      eor.b     d0,(a1)+
[0001125e] 101c                      move.b    (a4)+,d0
[00011260] b119                      eor.b     d0,(a1)+
[00011262] 101c                      move.b    (a4)+,d0
[00011264] b111                      eor.b     d0,(a1)
[00011266] d2cb                      adda.w    a3,a1
[00011268] 51cb ffaa                 dbf       d3,$00011214
[0001126c] 4e75                      rts
[0001126e] 7e00                      moveq.l   #0,d7
[00011270] 3e1f                      move.w    (a7)+,d7
[00011272] 2c07                      move.l    d7,d6
[00011274] e98e                      lsl.l     #4,d6
[00011276] 9c87                      sub.l     d7,d6
[00011278] 97c6                      suba.l    d6,a3
[0001127a] 3c02                      move.w    d2,d6
[0001127c] e84a                      lsr.w     #4,d2
[0001127e] 3800                      move.w    d0,d4
[00011280] e84c                      lsr.w     #4,d4
[00011282] 9444                      sub.w     d4,d2
[00011284] 5342                      subq.w    #1,d2
[00011286] 6b00 0098                 bmi       $00011320
[0001128a] 780c                      moveq.l   #12,d4
[0001128c] c840                      and.w     d0,d4
[0001128e] 247b 400c                 movea.l   $0001129C(pc,d4.w),a2
[00011292] 7a0c                      moveq.l   #12,d5
[00011294] ca46                      and.w     d6,d5
[00011296] 2c7b 5014                 movea.l   $000112AC(pc,d5.w),a6
[0001129a] 6040                      bra.s     $000112DC
[0001129c] 0001 12f6                 ori.b     #$F6,d1
[000112a0] 0001 12f8                 ori.b     #$F8,d1
[000112a4] 0001 12fa                 ori.b     #$FA,d1
[000112a8] 0001 12fc                 ori.b     #$FC,d1
[000112ac] 0001 1316                 ori.b     #$16,d1
[000112b0] 0001 1314                 ori.b     #$14,d1
[000112b4] 0001 1312                 ori.b     #$12,d1
[000112b8] 0001 1310                 ori.b     #$10,d1
[000112bc] ffff ffff 00ff ffff       vperm     #$00FFFFFF,e23,e23,e23
[000112c4] 0000 ffff                 ori.b     #$FF,d0
[000112c8] 0000 00ff                 ori.b     #$FF,d0
[000112cc] ff00                      dc.w      $FF00 ; illegal
[000112ce] 0000 ffff                 ori.b     #$FF,d0
[000112d2] 0000 ffff                 ori.b     #$FF,d0
[000112d6] ff00                      dc.w      $FF00 ; illegal
[000112d8] ffff ffff 7803 c044       vperm     #$7803C044,e23,e23,e23
[000112e0] cc44                      and.w     d4,d6
[000112e2] d040                      add.w     d0,d0
[000112e4] d040                      add.w     d0,d0
[000112e6] dc46                      add.w     d6,d6
[000112e8] dc46                      add.w     d6,d6
[000112ea] 283b 00d0                 move.l    $000112BC(pc,d0.w),d4
[000112ee] 2a3b 60dc                 move.l    $000112CC(pc,d6.w),d5
[000112f2] b999                      eor.l     d4,(a1)+
[000112f4] 4ed2                      jmp       (a2)
[000112f6] 4699                      not.l     (a1)+
[000112f8] 4699                      not.l     (a1)+
[000112fa] 4699                      not.l     (a1)+
[000112fc] 3002                      move.w    d2,d0
[000112fe] 5340                      subq.w    #1,d0
[00011300] 6b0c                      bmi.s     $0001130E
[00011302] 4699                      not.l     (a1)+
[00011304] 4699                      not.l     (a1)+
[00011306] 4699                      not.l     (a1)+
[00011308] 4699                      not.l     (a1)+
[0001130a] 51c8 fff6                 dbf       d0,$00011302
[0001130e] 4ed6                      jmp       (a6)
[00011310] 4699                      not.l     (a1)+
[00011312] 4699                      not.l     (a1)+
[00011314] 4699                      not.l     (a1)+
[00011316] bb91                      eor.l     d5,(a1)
[00011318] d2cb                      adda.w    a3,a1
[0001131a] 51cb ffd6                 dbf       d3,$000112F2
[0001131e] 4e75                      rts
[00011320] 3647                      movea.w   d7,a3
[00011322] 720f                      moveq.l   #15,d1
[00011324] 9c40                      sub.w     d0,d6
[00011326] 96c6                      suba.w    d6,a3
[00011328] 534b                      subq.w    #1,a3
[0001132a] b346                      eor.w     d1,d6
[0001132c] dc46                      add.w     d6,d6
[0001132e] 45fb 600e                 lea.l     $0001133E(pc,d6.w),a2
[00011332] c041                      and.w     d1,d0
[00011334] d0c0                      adda.w    d0,a0
[00011336] c07c 0003                 and.w     #$0003,d0
[0001133a] d2c0                      adda.w    d0,a1
[0001133c] 4ed2                      jmp       (a2)
[0001133e] 4619                      not.b     (a1)+
[00011340] 4619                      not.b     (a1)+
[00011342] 4619                      not.b     (a1)+
[00011344] 4619                      not.b     (a1)+
[00011346] 4619                      not.b     (a1)+
[00011348] 4619                      not.b     (a1)+
[0001134a] 4619                      not.b     (a1)+
[0001134c] 4619                      not.b     (a1)+
[0001134e] 4619                      not.b     (a1)+
[00011350] 4619                      not.b     (a1)+
[00011352] 4619                      not.b     (a1)+
[00011354] 4619                      not.b     (a1)+
[00011356] 4619                      not.b     (a1)+
[00011358] 4619                      not.b     (a1)+
[0001135a] 4619                      not.b     (a1)+
[0001135c] 4619                      not.b     (a1)+
[0001135e] d2cb                      adda.w    a3,a1
[00011360] 51cb ffda                 dbf       d3,$0001133C
[00011364] 4e75                      rts
[00011366] d2c0                      adda.w    d0,a1
[00011368] 9440                      sub.w     d0,d2
[0001136a] e98e                      lsl.l     #4,d6
[0001136c] 2646                      movea.l   d6,a3
[0001136e] 4bfa 3078                 lea.l     $000143E8(pc),a5
[00011372] daee 00be                 adda.w    190(a6),a5
[00011376] 1e15                      move.b    (a5),d7
[00011378] 2a48                      movea.l   a0,a5
[0001137a] 780f                      moveq.l   #15,d4
[0001137c] 7c0f                      moveq.l   #15,d6
[0001137e] c044                      and.w     d4,d0
[00011380] 4a6e 00ca                 tst.w     202(a6)
[00011384] 6600 00d2                 bne       $00011458
[00011388] c244                      and.w     d4,d1
[0001138a] 6718                      beq.s     $000113A4
[0001138c] 3a01                      move.w    d1,d5
[0001138e] bd45                      eor.w     d6,d5
[00011390] 3c01                      move.w    d1,d6
[00011392] 5346                      subq.w    #1,d6
[00011394] d241                      add.w     d1,d1
[00011396] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001139a] 321a                      move.w    (a2)+,d1
[0001139c] e179                      rol.w     d0,d1
[0001139e] 3ac1                      move.w    d1,(a5)+
[000113a0] 51cd fff8                 dbf       d5,$0001139A
[000113a4] 321c                      move.w    (a4)+,d1
[000113a6] e179                      rol.w     d0,d1
[000113a8] 3ac1                      move.w    d1,(a5)+
[000113aa] 51ce fff8                 dbf       d6,$000113A4
[000113ae] 700f                      moveq.l   #15,d0
[000113b0] b640                      cmp.w     d0,d3
[000113b2] 6c02                      bge.s     $000113B6
[000113b4] 3003                      move.w    d3,d0
[000113b6] 4843                      swap      d3
[000113b8] 3600                      move.w    d0,d3
[000113ba] 347c 0010                 movea.w   #$0010,a2
[000113be] 7c0f                      moveq.l   #15,d6
[000113c0] b446                      cmp.w     d6,d2
[000113c2] 6c02                      bge.s     $000113C6
[000113c4] 3c02                      move.w    d2,d6
[000113c6] 9446                      sub.w     d6,d2
[000113c8] 97c6                      suba.l    d6,a3
[000113ca] 538b                      subq.l    #1,a3
[000113cc] 3846                      movea.w   d6,a4
[000113ce] 4843                      swap      d3
[000113d0] 3203                      move.w    d3,d1
[000113d2] e849                      lsr.w     #4,d1
[000113d4] 2a49                      movea.l   a1,a5
[000113d6] 3c0c                      move.w    a4,d6
[000113d8] 3010                      move.w    (a0),d0
[000113da] d040                      add.w     d0,d0
[000113dc] 645e                      bcc.s     $0001143C
[000113de] 3802                      move.w    d2,d4
[000113e0] d846                      add.w     d6,d4
[000113e2] e84c                      lsr.w     #4,d4
[000113e4] 3a04                      move.w    d4,d5
[000113e6] e84c                      lsr.w     #4,d4
[000113e8] 4645                      not.w     d5
[000113ea] 0245 000f                 andi.w    #$000F,d5
[000113ee] da45                      add.w     d5,d5
[000113f0] da45                      add.w     d5,d5
[000113f2] 2c4d                      movea.l   a5,a6
[000113f4] 4efb 5002                 jmp       $000113F8(pc,d5.w)
[000113f8] 1c87                      move.b    d7,(a6)
[000113fa] dcca                      adda.w    a2,a6
[000113fc] 1c87                      move.b    d7,(a6)
[000113fe] dcca                      adda.w    a2,a6
[00011400] 1c87                      move.b    d7,(a6)
[00011402] dcca                      adda.w    a2,a6
[00011404] 1c87                      move.b    d7,(a6)
[00011406] dcca                      adda.w    a2,a6
[00011408] 1c87                      move.b    d7,(a6)
[0001140a] dcca                      adda.w    a2,a6
[0001140c] 1c87                      move.b    d7,(a6)
[0001140e] dcca                      adda.w    a2,a6
[00011410] 1c87                      move.b    d7,(a6)
[00011412] dcca                      adda.w    a2,a6
[00011414] 1c87                      move.b    d7,(a6)
[00011416] dcca                      adda.w    a2,a6
[00011418] 1c87                      move.b    d7,(a6)
[0001141a] dcca                      adda.w    a2,a6
[0001141c] 1c87                      move.b    d7,(a6)
[0001141e] dcca                      adda.w    a2,a6
[00011420] 1c87                      move.b    d7,(a6)
[00011422] dcca                      adda.w    a2,a6
[00011424] 1c87                      move.b    d7,(a6)
[00011426] dcca                      adda.w    a2,a6
[00011428] 1c87                      move.b    d7,(a6)
[0001142a] dcca                      adda.w    a2,a6
[0001142c] 1c87                      move.b    d7,(a6)
[0001142e] dcca                      adda.w    a2,a6
[00011430] 1c87                      move.b    d7,(a6)
[00011432] dcca                      adda.w    a2,a6
[00011434] 1c87                      move.b    d7,(a6)
[00011436] dcca                      adda.w    a2,a6
[00011438] 51cc ffbe                 dbf       d4,$000113F8
[0001143c] 528d                      addq.l    #1,a5
[0001143e] 51ce ff9a                 dbf       d6,$000113DA
[00011442] dbcb                      adda.l    a3,a5
[00011444] 51c9 ff90                 dbf       d1,$000113D6
[00011448] 5488                      addq.l    #2,a0
[0001144a] d2d7                      adda.w    (a7),a1
[0001144c] 5343                      subq.w    #1,d3
[0001144e] 4843                      swap      d3
[00011450] 51cb ff7c                 dbf       d3,$000113CE
[00011454] 548f                      addq.l    #2,a7
[00011456] 4e75                      rts
[00011458] c244                      and.w     d4,d1
[0001145a] 6724                      beq.s     $00011480
[0001145c] 3a01                      move.w    d1,d5
[0001145e] bd45                      eor.w     d6,d5
[00011460] 3c01                      move.w    d1,d6
[00011462] 5346                      subq.w    #1,d6
[00011464] e949                      lsl.w     #4,d1
[00011466] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001146a] 720f                      moveq.l   #15,d1
[0001146c] 1af2 0000                 move.b    0(a2,d0.w),(a5)+
[00011470] 5240                      addq.w    #1,d0
[00011472] c044                      and.w     d4,d0
[00011474] 51c9 fff6                 dbf       d1,$0001146C
[00011478] 45ea 0010                 lea.l     16(a2),a2
[0001147c] 51cd ffec                 dbf       d5,$0001146A
[00011480] 720f                      moveq.l   #15,d1
[00011482] 1af4 0000                 move.b    0(a4,d0.w),(a5)+
[00011486] 5240                      addq.w    #1,d0
[00011488] c044                      and.w     d4,d0
[0001148a] 51c9 fff6                 dbf       d1,$00011482
[0001148e] 49ec 0010                 lea.l     16(a4),a4
[00011492] 51ce ffec                 dbf       d6,$00011480
[00011496] 700f                      moveq.l   #15,d0
[00011498] b640                      cmp.w     d0,d3
[0001149a] 6c02                      bge.s     $0001149E
[0001149c] 3003                      move.w    d3,d0
[0001149e] 4843                      swap      d3
[000114a0] 3600                      move.w    d0,d3
[000114a2] 347c 0010                 movea.w   #$0010,a2
[000114a6] 7c0f                      moveq.l   #15,d6
[000114a8] b446                      cmp.w     d6,d2
[000114aa] 6c02                      bge.s     $000114AE
[000114ac] 3c02                      move.w    d2,d6
[000114ae] 9446                      sub.w     d6,d2
[000114b0] 97c6                      suba.l    d6,a3
[000114b2] 538b                      subq.l    #1,a3
[000114b4] 4843                      swap      d3
[000114b6] 3203                      move.w    d3,d1
[000114b8] e849                      lsr.w     #4,d1
[000114ba] 2a49                      movea.l   a1,a5
[000114bc] 3006                      move.w    d6,d0
[000114be] 2848                      movea.l   a0,a4
[000114c0] 4a1c                      tst.b     (a4)+
[000114c2] 6766                      beq.s     $0001152A
[000114c4] 3f07                      move.w    d7,-(a7)
[000114c6] ce2c ffff                 and.b     -1(a4),d7
[000114ca] 3802                      move.w    d2,d4
[000114cc] d840                      add.w     d0,d4
[000114ce] e84c                      lsr.w     #4,d4
[000114d0] 3a04                      move.w    d4,d5
[000114d2] e84c                      lsr.w     #4,d4
[000114d4] 4645                      not.w     d5
[000114d6] 0245 000f                 andi.w    #$000F,d5
[000114da] da45                      add.w     d5,d5
[000114dc] da45                      add.w     d5,d5
[000114de] 2c4d                      movea.l   a5,a6
[000114e0] 4efb 5002                 jmp       $000114E4(pc,d5.w)
[000114e4] 1c87                      move.b    d7,(a6)
[000114e6] dcca                      adda.w    a2,a6
[000114e8] 1c87                      move.b    d7,(a6)
[000114ea] dcca                      adda.w    a2,a6
[000114ec] 1c87                      move.b    d7,(a6)
[000114ee] dcca                      adda.w    a2,a6
[000114f0] 1c87                      move.b    d7,(a6)
[000114f2] dcca                      adda.w    a2,a6
[000114f4] 1c87                      move.b    d7,(a6)
[000114f6] dcca                      adda.w    a2,a6
[000114f8] 1c87                      move.b    d7,(a6)
[000114fa] dcca                      adda.w    a2,a6
[000114fc] 1c87                      move.b    d7,(a6)
[000114fe] dcca                      adda.w    a2,a6
[00011500] 1c87                      move.b    d7,(a6)
[00011502] dcca                      adda.w    a2,a6
[00011504] 1c87                      move.b    d7,(a6)
[00011506] dcca                      adda.w    a2,a6
[00011508] 1c87                      move.b    d7,(a6)
[0001150a] dcca                      adda.w    a2,a6
[0001150c] 1c87                      move.b    d7,(a6)
[0001150e] dcca                      adda.w    a2,a6
[00011510] 1c87                      move.b    d7,(a6)
[00011512] dcca                      adda.w    a2,a6
[00011514] 1c87                      move.b    d7,(a6)
[00011516] dcca                      adda.w    a2,a6
[00011518] 1c87                      move.b    d7,(a6)
[0001151a] dcca                      adda.w    a2,a6
[0001151c] 1c87                      move.b    d7,(a6)
[0001151e] dcca                      adda.w    a2,a6
[00011520] 1c87                      move.b    d7,(a6)
[00011522] dcca                      adda.w    a2,a6
[00011524] 51cc ffbe                 dbf       d4,$000114E4
[00011528] 3e1f                      move.w    (a7)+,d7
[0001152a] 528d                      addq.l    #1,a5
[0001152c] 51c8 ff92                 dbf       d0,$000114C0
[00011530] dbcb                      adda.l    a3,a5
[00011532] 51c9 ff88                 dbf       d1,$000114BC
[00011536] 41e8 0010                 lea.l     16(a0),a0
[0001153a] d2d7                      adda.w    (a7),a1
[0001153c] 5343                      subq.w    #1,d3
[0001153e] 4843                      swap      d3
[00011540] 51cb ff72                 dbf       d3,$000114B4
[00011544] 548f                      addq.l    #2,a7
[00011546] 4e75                      rts
[00011548] d2c0                      adda.w    d0,a1
[0001154a] 9440                      sub.w     d0,d2
[0001154c] e98e                      lsl.l     #4,d6
[0001154e] 2646                      movea.l   d6,a3
[00011550] 4bfa 2e96                 lea.l     $000143E8(pc),a5
[00011554] daee 00be                 adda.w    190(a6),a5
[00011558] 1e15                      move.b    (a5),d7
[0001155a] 2a48                      movea.l   a0,a5
[0001155c] 780f                      moveq.l   #15,d4
[0001155e] 7c0f                      moveq.l   #15,d6
[00011560] c044                      and.w     d4,d0
[00011562] 4a6e 00ca                 tst.w     202(a6)
[00011566] 662a                      bne.s     $00011592
[00011568] c244                      and.w     d4,d1
[0001156a] 670e                      beq.s     $0001157A
[0001156c] 3a01                      move.w    d1,d5
[0001156e] bd45                      eor.w     d6,d5
[00011570] 3c01                      move.w    d1,d6
[00011572] 5346                      subq.w    #1,d6
[00011574] d241                      add.w     d1,d1
[00011576] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001157a] 321a                      move.w    (a2)+,d1
[0001157c] e179                      rol.w     d0,d1
[0001157e] 3ac1                      move.w    d1,(a5)+
[00011580] 51cd fff8                 dbf       d5,$0001157A
[00011584] 321c                      move.w    (a4)+,d1
[00011586] e179                      rol.w     d0,d1
[00011588] 3ac1                      move.w    d1,(a5)+
[0001158a] 51ce fff8                 dbf       d6,$00011584
[0001158e] 6000 fe1e                 bra       $000113AE
[00011592] c244                      and.w     d4,d1
[00011594] 6726                      beq.s     $000115BC
[00011596] 3a01                      move.w    d1,d5
[00011598] bd45                      eor.w     d6,d5
[0001159a] 3c01                      move.w    d1,d6
[0001159c] 5346                      subq.w    #1,d6
[0001159e] e949                      lsl.w     #4,d1
[000115a0] 45f4 1000                 lea.l     0(a4,d1.w),a2
[000115a4] 720f                      moveq.l   #15,d1
[000115a6] 1ab2 0000                 move.b    0(a2,d0.w),(a5)
[000115aa] 461d                      not.b     (a5)+
[000115ac] 5240                      addq.w    #1,d0
[000115ae] c044                      and.w     d4,d0
[000115b0] 51c9 fff4                 dbf       d1,$000115A6
[000115b4] 45ea 0010                 lea.l     16(a2),a2
[000115b8] 51cd ffea                 dbf       d5,$000115A4
[000115bc] 720f                      moveq.l   #15,d1
[000115be] 1ab4 0000                 move.b    0(a4,d0.w),(a5)
[000115c2] 461d                      not.b     (a5)+
[000115c4] 5240                      addq.w    #1,d0
[000115c6] c044                      and.w     d4,d0
[000115c8] 51c9 fff4                 dbf       d1,$000115BE
[000115cc] 49ec 0010                 lea.l     16(a4),a4
[000115d0] 51ce ffea                 dbf       d6,$000115BC
[000115d4] 6000 fec0                 bra       $00011496
[000115d8] 2278 044e                 movea.l   ($0000044E).w,a1
[000115dc] 3678 206e                 movea.w   ($0000206E).w,a3
[000115e0] 4a6e 01b2                 tst.w     434(a6)
[000115e4] 6708                      beq.s     $000115EE
[000115e6] 226e 01ae                 movea.l   430(a6),a1
[000115ea] 366e 01b2                 movea.w   434(a6),a3
[000115ee] 426e 01ec                 clr.w     492(a6)
[000115f2] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[000115f8] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[000115fe] 426e 01c8                 clr.w     456(a6)
[00011602] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00011608] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[0001160e] 661c                      bne.s     $0001162C
[00011610] 426e 01ea                 clr.w     490(a6)
[00011614] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[0001161a] 6010                      bra.s     $0001162C
[0001161c] 206e 01c2                 movea.l   450(a6),a0
[00011620] 226e 01d6                 movea.l   470(a6),a1
[00011624] 346e 01c6                 movea.w   454(a6),a2
[00011628] 366e 01da                 movea.w   474(a6),a3
[0001162c] 49fa 2dba                 lea.l     $000143E8(pc),a4
[00011630] 2a49                      movea.l   a1,a5
[00011632] 3c0a                      move.w    a2,d6
[00011634] 3e0b                      move.w    a3,d7
[00011636] c7c7                      muls.w    d7,d3
[00011638] d3c3                      adda.l    d3,a1
[0001163a] c3c6                      muls.w    d6,d1
[0001163c] d1c1                      adda.l    d1,a0
[0001163e] 3200                      move.w    d0,d1
[00011640] e649                      lsr.w     #3,d1
[00011642] d0c1                      adda.w    d1,a0
[00011644] 7207                      moveq.l   #7,d1
[00011646] c240                      and.w     d0,d1
[00011648] 9441                      sub.w     d1,d2
[0001164a] d2c2                      adda.w    d2,a1
[0001164c] 363a 2d94                 move.w    $000143E2(pc),d3
[00011650] 6608                      bne.s     $0001165A
[00011652] 0802 0000                 btst      #0,d2
[00011656] 6600 07ec                 bne       $00011E44
[0001165a] 4a41                      tst.w     d1
[0001165c] 6646                      bne.s     $000116A4
[0001165e] 7607                      moveq.l   #7,d3
[00011660] c644                      and.w     d4,d3
[00011662] 5f43                      subq.w    #7,d3
[00011664] 663e                      bne.s     $000116A4
[00011666] 302e 01ee                 move.w    494(a6),d0
[0001166a] 6708                      beq.s     $00011674
[0001166c] 5540                      subq.w    #2,d0
[0001166e] 6d0a                      blt.s     $0001167A
[00011670] 6710                      beq.s     $00011682
[00011672] 6030                      bra.s     $000116A4
[00011674] 4a6e 01ec                 tst.w     492(a6)
[00011678] 662a                      bne.s     $000116A4
[0001167a] 0c6e 0001 01ea            cmpi.w    #$0001,490(a6)
[00011680] 6622                      bne.s     $000116A4
[00011682] 5244                      addq.w    #1,d4
[00011684] 9e44                      sub.w     d4,d7
[00011686] e64c                      lsr.w     #3,d4
[00011688] 9c44                      sub.w     d4,d6
[0001168a] 5344                      subq.w    #1,d4
[0001168c] 49fa 2f5a                 lea.l     $000145E8(pc),a4
[00011690] 302e 01ee                 move.w    494(a6),d0
[00011694] d040                      add.w     d0,d0
[00011696] 303b 0006                 move.w    $0001169E(pc,d0.w),d0
[0001169a] 4efb 0002                 jmp       $0001169E(pc,d0.w)
J3:
[0001169e] 0144                      dc.w $0144   ; $000117e2-$0001169e
[000116a0] 0176                      dc.w $0176   ; $00011814-$0001169e
[000116a2] 01aa                      dc.w $01aa   ; $00011848-$0001169e
[000116a4] 45fa                      dc.w $45fa   ; $00015c98-$0001169e
[000116a6] 069e                      dc.w $069e   ; $00011d3c-$0001169e
[000116a8] 47fa                      dc.w $47fa   ; $00015e98-$0001169e
[000116aa] 06da                      dc.w $06da   ; $00011d78-$0001169e
[000116ac] 7608                      dc.w $7608   ; $00018ca6-$0001169e
[000116ae] 9641                      dc.w $9641   ; $0000acdf-$0001169e
[000116b0] 9843                      dc.w $9843   ; $0000aee1-$0001169e
[000116b2] 6b00                      dc.w $6b00   ; $0001819e-$0001169e
[000116b4] 0098                      dc.w $0098   ; $00011736-$0001169e
[000116b6] e749                      dc.w $e749   ; $0000fde7-$0001169e
[000116b8] d4c1                      dc.w $d4c1   ; $0000eb5f-$0001169e
[000116ba] 7007                      dc.w $7007   ; $000186a5-$0001169e
[000116bc] c044                      dc.w $c044   ; $0000d6e2-$0001169e
[000116be] 9840                      dc.w $9840   ; $0000aede-$0001169e
[000116c0] e748                      dc.w $e748   ; $0000fde6-$0001169e
[000116c2] d6c0                      dc.w $d6c0   ; $0000ed5e-$0001169e
[000116c4] 9e44                      dc.w $9e44   ; $0000b4e2-$0001169e
[000116c6] 0447                      dc.w $0447   ; $00011ae5-$0001169e
[000116c8] 0010                      dc.w $0010   ; $000116ae-$0001169e
[000116ca] e64c                      lsr.w     #3,d4
[000116cc] 9c44                      sub.w     d4,d6
[000116ce] 5546                      subq.w    #2,d6
[000116d0] 5344                      subq.w    #1,d4
[000116d2] 200c                      move.l    a4,d0
[000116d4] d8ee 01ea                 adda.w    490(a6),a4
[000116d8] 050c 0000                 movep.w   0(a4),d2
[000116dc] 1414                      move.b    (a4),d2
[000116de] 3202                      move.w    d2,d1
[000116e0] 4842                      swap      d2
[000116e2] 3401                      move.w    d1,d2
[000116e4] 2840                      movea.l   d0,a4
[000116e6] d8ee 01ec                 adda.w    492(a6),a4
[000116ea] 070c 0000                 movep.w   0(a4),d3
[000116ee] 1614                      move.b    (a4),d3
[000116f0] 3203                      move.w    d3,d1
[000116f2] 4843                      swap      d3
[000116f4] 3601                      move.w    d1,d3
[000116f6] 49fa 2ef0                 lea.l     $000145E8(pc),a4
[000116fa] bbc9                      cmpa.l    a1,a5
[000116fc] 6e16                      bgt.s     $00011714
[000116fe] 302e 01ee                 move.w    494(a6),d0
[00011702] d040                      add.w     d0,d0
[00011704] 303b 0006                 move.w    $0001170C(pc,d0.w),d0
[00011708] 4efb 0002                 jmp       $0001170C(pc,d0.w)
J4:
[0001170c] 029e                      dc.w $029e   ; $000119aa-$0001170c
[0001170e] 04de                      dc.w $04de   ; $00011bea-$0001170c
[00011710] 0558                      dc.w $0558   ; $00011c64-$0001170c
[00011712] 05ba                      dc.w $05ba   ; $00011cc6-$0001170c
[00011714] 220d                      dc.w $220d   ; $00013919-$0001170c
[00011716] 9289                      dc.w $9289   ; $0000a995-$0001170c
[00011718] 1018                      dc.w $1018   ; $00012724-$0001170c
[0001171a] e328                      dc.w $e328   ; $0000fa34-$0001170c
[0001171c] 4441                      dc.w $4441   ; $00015b4d-$0001170c
[0001171e] 5e41                      dc.w $5e41   ; $0001754d-$0001170c
[00011720] 224d                      dc.w $224d   ; $00013959-$0001170c
[00011722] 3a6e                      dc.w $3a6e   ; $0001517a-$0001170c
[00011724] 01ee                      dc.w $01ee   ; $000118fa-$0001170c
[00011726] dacd                      dc.w $dacd   ; $0000f1d9-$0001170c
[00011728] 3f0d                      dc.w $3f0d   ; $00015619-$0001170c
[0001172a] 3a7b                      dc.w $3a7b   ; $00015187-$0001170c
[0001172c] d010                      dc.w $d010   ; $0000e71c-$0001170c
[0001172e] 4ebb                      dc.w $4ebb   ; $000165c7-$0001170c
[00011730] d00c                      dc.w $d00c   ; $0000e718-$0001170c
[00011732] 301f                      dc.w $301f   ; $0001472b-$0001170c
[00011734] 303b                      dc.w $303b   ; $00014747-$0001170c
[00011736] 000e                      dc.w $000e   ; $0001171a-$0001170c
[00011738] 4efb 000a                 jmp       $00011744(pc,d0.w)
[0001173c] 0140                      bchg      d0,d0
[0001173e] 0154                      bchg      d0,(a4)
[00011740] 0162                      bchg      d0,-(a2)
[00011742] 0170 0256                 bchg      d0,86(a0,d0.w*2) ; 68020+ only
[00011746] 04a0 0538 057e            subi.l    #$0538057E,-(a0)
[0001174c] 3001                      move.w    d1,d0
[0001174e] e749                      lsl.w     #3,d1
[00011750] d843                      add.w     d3,d4
[00011752] d044                      add.w     d4,d0
[00011754] e748                      lsl.w     #3,d0
[00011756] d4c1                      adda.w    d1,a2
[00011758] d6c0                      adda.w    d0,a3
[0001175a] 241a                      move.l    (a2)+,d2
[0001175c] c49b                      and.l     (a3)+,d2
[0001175e] 2613                      move.l    (a3),d3
[00011760] c692                      and.l     (a2),d3
[00011762] 5147                      subq.w    #8,d7
[00011764] 3446                      movea.w   d6,a2
[00011766] 3647                      movea.w   d7,a3
[00011768] 2c02                      move.l    d2,d6
[0001176a] 2e03                      move.l    d3,d7
[0001176c] 200c                      move.l    a4,d0
[0001176e] d8ee 01ea                 adda.w    490(a6),a4
[00011772] 050c 0000                 movep.w   0(a4),d2
[00011776] 1414                      move.b    (a4),d2
[00011778] 3202                      move.w    d2,d1
[0001177a] 4842                      swap      d2
[0001177c] 3401                      move.w    d1,d2
[0001177e] 2840                      movea.l   d0,a4
[00011780] d8ee 01ec                 adda.w    492(a6),a4
[00011784] 070c 0000                 movep.w   0(a4),d3
[00011788] 1614                      move.b    (a4),d3
[0001178a] 3203                      move.w    d3,d1
[0001178c] 4843                      swap      d3
[0001178e] 3601                      move.w    d1,d3
[00011790] bbc9                      cmpa.l    a1,a5
[00011792] 6f2a                      ble.s     $000117BE
[00011794] 2f09                      move.l    a1,-(a7)
[00011796] 220d                      move.l    a5,d1
[00011798] 9289                      sub.l     a1,d1
[0001179a] 1010                      move.b    (a0),d0
[0001179c] e328                      lsl.b     d1,d0
[0001179e] 3204                      move.w    d4,d1
[000117a0] 224d                      movea.l   a5,a1
[000117a2] 3a6e 01ee                 movea.w   494(a6),a5
[000117a6] dacd                      adda.w    a5,a5
[000117a8] 3a7b d092                 movea.w   $0001173C(pc,a5.w),a5
[000117ac] 4ebb d08e                 jsr       $0001173C(pc,a5.w)
[000117b0] 225f                      movea.l   (a7)+,a1
[000117b2] 5089                      addq.l    #8,a1
[000117b4] d0ca                      adda.w    a2,a0
[000117b6] d2cb                      adda.w    a3,a1
[000117b8] 5345                      subq.w    #1,d5
[000117ba] 6a02                      bpl.s     $000117BE
[000117bc] 4e75                      rts
[000117be] 3205                      move.w    d5,d1
[000117c0] 2806                      move.l    d6,d4
[000117c2] 2a07                      move.l    d7,d5
[000117c4] 4684                      not.l     d4
[000117c6] 4685                      not.l     d5
[000117c8] 49fa 2e1e                 lea.l     $000145E8(pc),a4
[000117cc] 302e 01ee                 move.w    494(a6),d0
[000117d0] d040                      add.w     d0,d0
[000117d2] 303b 0006                 move.w    $000117DA(pc,d0.w),d0
[000117d6] 4efb 0002                 jmp       $000117DA(pc,d0.w)
J5:
[000117da] 0104                      dc.w $0104   ; $000118de-$000117da
[000117dc] 014a                      dc.w $014a   ; $00011924-$000117da
[000117de] 0174                      dc.w $0174   ; $0001194e-$000117da
[000117e0] 0194                      dc.w $0194   ; $0001196e-$000117da
[000117e2] 3204                      dc.w $3204   ; $000149de-$000117da
[000117e4] 7000                      dc.w $7000   ; $000187da-$000117da
[000117e6] 1018                      dc.w $1018   ; $000127f2-$000117da
[000117e8] 6718                      dc.w $6718   ; $00017ef2-$000117da
[000117ea] e748                      dc.w $e748   ; $0000ff22-$000117da
[000117ec] 2a4c                      dc.w $2a4c   ; $00014226-$000117da
[000117ee] dac0                      dc.w $dac0   ; $0000f29a-$000117da
[000117f0] 22dd                      dc.w $22dd   ; $00013ab7-$000117da
[000117f2] 22dd                      dc.w $22dd   ; $00013ab7-$000117da
[000117f4] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[000117f6] ffee                      dc.w $ffee   ; $000117c8-$000117da
[000117f8] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[000117fa] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[000117fc] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[000117fe] ffe4                      dc.w $ffe4   ; $000117be-$000117da
[00011800] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011802] 22c0                      dc.w $22c0   ; $00013a9a-$000117da
[00011804] 22c0                      dc.w $22c0   ; $00013a9a-$000117da
[00011806] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[00011808] ffdc                      dc.w $ffdc   ; $000117b6-$000117da
[0001180a] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[0001180c] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[0001180e] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[00011810] ffd2                      dc.w $ffd2   ; $000117ac-$000117da
[00011812] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011814] 3204                      dc.w $3204   ; $000149de-$000117da
[00011816] 7000                      dc.w $7000   ; $000187da-$000117da
[00011818] 1018                      dc.w $1018   ; $000127f2-$000117da
[0001181a] 671c                      dc.w $671c   ; $00017ef6-$000117da
[0001181c] e748                      dc.w $e748   ; $0000ff22-$000117da
[0001181e] 2a4c                      dc.w $2a4c   ; $00014226-$000117da
[00011820] dac0                      dc.w $dac0   ; $0000f29a-$000117da
[00011822] 201d                      dc.w $201d   ; $000137f7-$000117da
[00011824] 8199                      dc.w $8199   ; $00009973-$000117da
[00011826] 201d                      dc.w $201d   ; $000137f7-$000117da
[00011828] 8199                      dc.w $8199   ; $00009973-$000117da
[0001182a] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[0001182c] ffea                      dc.w $ffea   ; $000117c4-$000117da
[0001182e] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[00011830] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[00011832] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[00011834] ffe0                      dc.w $ffe0   ; $000117ba-$000117da
[00011836] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011838] 5089                      dc.w $5089   ; $00016863-$000117da
[0001183a] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[0001183c] ffda                      dc.w $ffda   ; $000117b4-$000117da
[0001183e] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[00011840] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[00011842] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[00011844] ffd0                      dc.w $ffd0   ; $000117aa-$000117da
[00011846] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011848] 3204                      dc.w $3204   ; $000149de-$000117da
[0001184a] 7000                      dc.w $7000   ; $000187da-$000117da
[0001184c] 1018                      dc.w $1018   ; $000127f2-$000117da
[0001184e] 671c                      dc.w $671c   ; $00017ef6-$000117da
[00011850] e748                      dc.w $e748   ; $0000ff22-$000117da
[00011852] 2a4c                      dc.w $2a4c   ; $00014226-$000117da
[00011854] dac0                      dc.w $dac0   ; $0000f29a-$000117da
[00011856] 201d                      dc.w $201d   ; $000137f7-$000117da
[00011858] b199                      dc.w $b199   ; $0000c973-$000117da
[0001185a] 201d                      dc.w $201d   ; $000137f7-$000117da
[0001185c] b199                      dc.w $b199   ; $0000c973-$000117da
[0001185e] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[00011860] ffea                      dc.w $ffea   ; $000117c4-$000117da
[00011862] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[00011864] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[00011866] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[00011868] ffe0                      dc.w $ffe0   ; $000117ba-$000117da
[0001186a] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[0001186c] 5089                      dc.w $5089   ; $00016863-$000117da
[0001186e] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[00011870] ffda                      dc.w $ffda   ; $000117b4-$000117da
[00011872] d0c6                      dc.w $d0c6   ; $0000e8a0-$000117da
[00011874] d2c7                      dc.w $d2c7   ; $0000eaa1-$000117da
[00011876] 51cd                      dc.w $51cd   ; $000169a7-$000117da
[00011878] ffd0                      dc.w $ffd0   ; $000117aa-$000117da
[0001187a] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[0001187c] d000                      dc.w $d000   ; $0000e7da-$000117da
[0001187e] 6408                      dc.w $6408   ; $00017be2-$000117da
[00011880] 12c2                      dc.w $12c2   ; $00012a9c-$000117da
[00011882] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[00011884] fff8                      dc.w $fff8   ; $000117d2-$000117da
[00011886] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011888] 12c3                      dc.w $12c3   ; $00012a9d-$000117da
[0001188a] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[0001188c] fff0                      dc.w $fff0   ; $000117ca-$000117da
[0001188e] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[00011890] d000                      dc.w $d000   ; $0000e7da-$000117da
[00011892] 6402                      dc.w $6402   ; $00017bdc-$000117da
[00011894] 1282                      dc.w $1282   ; $00012a5c-$000117da
[00011896] 5289                      dc.w $5289   ; $00016a63-$000117da
[00011898] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[0001189a] fff6                      dc.w $fff6   ; $000117d0-$000117da
[0001189c] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[0001189e] d000                      dc.w $d000   ; $0000e7da-$000117da
[000118a0] 6402                      dc.w $6402   ; $00017bdc-$000117da
[000118a2] 4611                      dc.w $4611   ; $00015deb-$000117da
[000118a4] 5289                      dc.w $5289   ; $00016a63-$000117da
[000118a6] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[000118a8] fff6                      dc.w $fff6   ; $000117d0-$000117da
[000118aa] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[000118ac] d000                      dc.w $d000   ; $0000e7da-$000117da
[000118ae] 6502                      dc.w $6502   ; $00017cdc-$000117da
[000118b0] 1283                      dc.w $1283   ; $00012a5d-$000117da
[000118b2] 5289                      dc.w $5289   ; $00016a63-$000117da
[000118b4] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[000118b6] fff6                      dc.w $fff6   ; $000117d0-$000117da
[000118b8] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[000118ba] 7000                      dc.w $7000   ; $000187da-$000117da
[000118bc] 1010                      dc.w $1010   ; $000127ea-$000117da
[000118be] e748                      dc.w $e748   ; $0000ff22-$000117da
[000118c0] 2a4c                      dc.w $2a4c   ; $00014226-$000117da
[000118c2] dac0                      dc.w $dac0   ; $0000f29a-$000117da
[000118c4] c991                      dc.w $c991   ; $0000e16b-$000117da
[000118c6] 201d                      dc.w $201d   ; $000137f7-$000117da
[000118c8] c086                      dc.w $c086   ; $0000d860-$000117da
[000118ca] 8199                      dc.w $8199   ; $00009973-$000117da
[000118cc] cb91                      dc.w $cb91   ; $0000e36b-$000117da
[000118ce] 201d                      dc.w $201d   ; $000137f7-$000117da
[000118d0] c087                      dc.w $c087   ; $0000d861-$000117da
[000118d2] 8199                      dc.w $8199   ; $00009973-$000117da
[000118d4] d0ca                      dc.w $d0ca   ; $0000e8a4-$000117da
[000118d6] d2cb                      dc.w $d2cb   ; $0000eaa5-$000117da
[000118d8] 51c9                      dc.w $51c9   ; $000169a3-$000117da
[000118da] ffe0                      dc.w $ffe0   ; $000117ba-$000117da
[000118dc] 4e75                      dc.w $4e75   ; $0001664f-$000117da
[000118de] 4a43                      tst.w     d3
[000118e0] 6606                      bne.s     $000118E8
[000118e2] 3002                      move.w    d2,d0
[000118e4] 4640                      not.w     d0
[000118e6] 67d2                      beq.s     $000118BA
[000118e8] 3f01                      move.w    d1,-(a7)
[000118ea] 7000                      moveq.l   #0,d0
[000118ec] 1010                      move.b    (a0),d0
[000118ee] e748                      lsl.w     #3,d0
[000118f0] 2a4c                      movea.l   a4,a5
[000118f2] dac0                      adda.w    d0,a5
[000118f4] c991                      and.l     d4,(a1)
[000118f6] 201d                      move.l    (a5)+,d0
[000118f8] 2200                      move.l    d0,d1
[000118fa] 4681                      not.l     d1
[000118fc] c082                      and.l     d2,d0
[000118fe] c283                      and.l     d3,d1
[00011900] 8081                      or.l      d1,d0
[00011902] c086                      and.l     d6,d0
[00011904] 8199                      or.l      d0,(a1)+
[00011906] cb91                      and.l     d5,(a1)
[00011908] 201d                      move.l    (a5)+,d0
[0001190a] 2200                      move.l    d0,d1
[0001190c] 4681                      not.l     d1
[0001190e] c082                      and.l     d2,d0
[00011910] c283                      and.l     d3,d1
[00011912] 8081                      or.l      d1,d0
[00011914] c087                      and.l     d7,d0
[00011916] 8199                      or.l      d0,(a1)+
[00011918] d0ca                      adda.w    a2,a0
[0001191a] d2cb                      adda.w    a3,a1
[0001191c] 321f                      move.w    (a7)+,d1
[0001191e] 51c9 ffc8                 dbf       d1,$000118E8
[00011922] 4e75                      rts
[00011924] 4682                      not.l     d2
[00011926] 7000                      moveq.l   #0,d0
[00011928] 1010                      move.b    (a0),d0
[0001192a] e748                      lsl.w     #3,d0
[0001192c] 2a4c                      movea.l   a4,a5
[0001192e] dac0                      adda.w    d0,a5
[00011930] 201d                      move.l    (a5)+,d0
[00011932] c086                      and.l     d6,d0
[00011934] 8191                      or.l      d0,(a1)
[00011936] c082                      and.l     d2,d0
[00011938] b199                      eor.l     d0,(a1)+
[0001193a] 201d                      move.l    (a5)+,d0
[0001193c] c087                      and.l     d7,d0
[0001193e] 8191                      or.l      d0,(a1)
[00011940] c082                      and.l     d2,d0
[00011942] b199                      eor.l     d0,(a1)+
[00011944] d0ca                      adda.w    a2,a0
[00011946] d2cb                      adda.w    a3,a1
[00011948] 51c9 ffdc                 dbf       d1,$00011926
[0001194c] 4e75                      rts
[0001194e] 7000                      moveq.l   #0,d0
[00011950] 1010                      move.b    (a0),d0
[00011952] e748                      lsl.w     #3,d0
[00011954] 2a4c                      movea.l   a4,a5
[00011956] dac0                      adda.w    d0,a5
[00011958] 201d                      move.l    (a5)+,d0
[0001195a] c086                      and.l     d6,d0
[0001195c] b199                      eor.l     d0,(a1)+
[0001195e] 201d                      move.l    (a5)+,d0
[00011960] c087                      and.l     d7,d0
[00011962] b199                      eor.l     d0,(a1)+
[00011964] d0ca                      adda.w    a2,a0
[00011966] d2cb                      adda.w    a3,a1
[00011968] 51c9 ffe4                 dbf       d1,$0001194E
[0001196c] 4e75                      rts
[0001196e] 4683                      not.l     d3
[00011970] 7000                      moveq.l   #0,d0
[00011972] 1010                      move.b    (a0),d0
[00011974] 4600                      not.b     d0
[00011976] e748                      lsl.w     #3,d0
[00011978] 2a4c                      movea.l   a4,a5
[0001197a] dac0                      adda.w    d0,a5
[0001197c] 201d                      move.l    (a5)+,d0
[0001197e] c086                      and.l     d6,d0
[00011980] 8191                      or.l      d0,(a1)
[00011982] c083                      and.l     d3,d0
[00011984] b199                      eor.l     d0,(a1)+
[00011986] 201d                      move.l    (a5)+,d0
[00011988] c087                      and.l     d7,d0
[0001198a] 8191                      or.l      d0,(a1)
[0001198c] c083                      and.l     d3,d0
[0001198e] b199                      eor.l     d0,(a1)+
[00011990] d0ca                      adda.w    a2,a0
[00011992] d2cb                      adda.w    a3,a1
[00011994] 51c9 ffda                 dbf       d1,$00011970
[00011998] 4e75                      rts
[0001199a] 4a43                      tst.w     d3
[0001199c] 6600 0170                 bne       $00011B0E
[000119a0] 3602                      move.w    d2,d3
[000119a2] 4643                      not.w     d3
[000119a4] 6600 00c6                 bne       $00011A6C
[000119a8] 603a                      bra.s     $000119E4
[000119aa] 4a43                      tst.w     d3
[000119ac] 6600 0122                 bne       $00011AD0
[000119b0] 3602                      move.w    d2,d3
[000119b2] 4643                      not.w     d3
[000119b4] 6600 0086                 bne       $00011A3C
[000119b8] 7000                      moveq.l   #0,d0
[000119ba] 1018                      move.b    (a0)+,d0
[000119bc] e748                      lsl.w     #3,d0
[000119be] 2a4c                      movea.l   a4,a5
[000119c0] dac0                      adda.w    d0,a5
[000119c2] 2012                      move.l    (a2),d0
[000119c4] 2211                      move.l    (a1),d1
[000119c6] 4681                      not.l     d1
[000119c8] 8280                      or.l      d0,d1
[000119ca] c09d                      and.l     (a5)+,d0
[000119cc] 4680                      not.l     d0
[000119ce] b181                      eor.l     d0,d1
[000119d0] 22c1                      move.l    d1,(a1)+
[000119d2] 202a 0004                 move.l    4(a2),d0
[000119d6] 2211                      move.l    (a1),d1
[000119d8] 4681                      not.l     d1
[000119da] 8280                      or.l      d0,d1
[000119dc] c09d                      and.l     (a5)+,d0
[000119de] 4680                      not.l     d0
[000119e0] b181                      eor.l     d0,d1
[000119e2] 22c1                      move.l    d1,(a1)+
[000119e4] 3204                      move.w    d4,d1
[000119e6] 6b1e                      bmi.s     $00011A06
[000119e8] 7000                      moveq.l   #0,d0
[000119ea] 1018                      move.b    (a0)+,d0
[000119ec] 6710                      beq.s     $000119FE
[000119ee] e748                      lsl.w     #3,d0
[000119f0] 2a4c                      movea.l   a4,a5
[000119f2] dac0                      adda.w    d0,a5
[000119f4] 22dd                      move.l    (a5)+,(a1)+
[000119f6] 22dd                      move.l    (a5)+,(a1)+
[000119f8] 51c9 ffee                 dbf       d1,$000119E8
[000119fc] 6008                      bra.s     $00011A06
[000119fe] 22c0                      move.l    d0,(a1)+
[00011a00] 22c0                      move.l    d0,(a1)+
[00011a02] 51c9 ffe4                 dbf       d1,$000119E8
[00011a06] 7000                      moveq.l   #0,d0
[00011a08] 1018                      move.b    (a0)+,d0
[00011a0a] e748                      lsl.w     #3,d0
[00011a0c] 2a4c                      movea.l   a4,a5
[00011a0e] dac0                      adda.w    d0,a5
[00011a10] 2013                      move.l    (a3),d0
[00011a12] 2211                      move.l    (a1),d1
[00011a14] 4681                      not.l     d1
[00011a16] 8280                      or.l      d0,d1
[00011a18] c09d                      and.l     (a5)+,d0
[00011a1a] 4680                      not.l     d0
[00011a1c] b181                      eor.l     d0,d1
[00011a1e] 22c1                      move.l    d1,(a1)+
[00011a20] 202b 0004                 move.l    4(a3),d0
[00011a24] 2211                      move.l    (a1),d1
[00011a26] 4681                      not.l     d1
[00011a28] 8280                      or.l      d0,d1
[00011a2a] c09d                      and.l     (a5)+,d0
[00011a2c] 4680                      not.l     d0
[00011a2e] b181                      eor.l     d0,d1
[00011a30] 22c1                      move.l    d1,(a1)+
[00011a32] d0c6                      adda.w    d6,a0
[00011a34] d2c7                      adda.w    d7,a1
[00011a36] 51cd ff80                 dbf       d5,$000119B8
[00011a3a] 4e75                      rts
[00011a3c] 7000                      moveq.l   #0,d0
[00011a3e] 1018                      move.b    (a0)+,d0
[00011a40] e748                      lsl.w     #3,d0
[00011a42] 2a4c                      movea.l   a4,a5
[00011a44] dac0                      adda.w    d0,a5
[00011a46] 2012                      move.l    (a2),d0
[00011a48] 2211                      move.l    (a1),d1
[00011a4a] 4681                      not.l     d1
[00011a4c] 8280                      or.l      d0,d1
[00011a4e] c09d                      and.l     (a5)+,d0
[00011a50] c082                      and.l     d2,d0
[00011a52] 4680                      not.l     d0
[00011a54] b181                      eor.l     d0,d1
[00011a56] 22c1                      move.l    d1,(a1)+
[00011a58] 202a 0004                 move.l    4(a2),d0
[00011a5c] 2211                      move.l    (a1),d1
[00011a5e] 4681                      not.l     d1
[00011a60] 8280                      or.l      d0,d1
[00011a62] c09d                      and.l     (a5)+,d0
[00011a64] c082                      and.l     d2,d0
[00011a66] 4680                      not.l     d0
[00011a68] b181                      eor.l     d0,d1
[00011a6a] 22c1                      move.l    d1,(a1)+
[00011a6c] 3204                      move.w    d4,d1
[00011a6e] 6b26                      bmi.s     $00011A96
[00011a70] 7000                      moveq.l   #0,d0
[00011a72] 1018                      move.b    (a0)+,d0
[00011a74] 6718                      beq.s     $00011A8E
[00011a76] e748                      lsl.w     #3,d0
[00011a78] 2a4c                      movea.l   a4,a5
[00011a7a] dac0                      adda.w    d0,a5
[00011a7c] 201d                      move.l    (a5)+,d0
[00011a7e] c082                      and.l     d2,d0
[00011a80] 22c0                      move.l    d0,(a1)+
[00011a82] 201d                      move.l    (a5)+,d0
[00011a84] c082                      and.l     d2,d0
[00011a86] 22c0                      move.l    d0,(a1)+
[00011a88] 51c9 ffe6                 dbf       d1,$00011A70
[00011a8c] 6008                      bra.s     $00011A96
[00011a8e] 22c0                      move.l    d0,(a1)+
[00011a90] 22c0                      move.l    d0,(a1)+
[00011a92] 51c9 ffdc                 dbf       d1,$00011A70
[00011a96] 7000                      moveq.l   #0,d0
[00011a98] 1018                      move.b    (a0)+,d0
[00011a9a] e748                      lsl.w     #3,d0
[00011a9c] 2a4c                      movea.l   a4,a5
[00011a9e] dac0                      adda.w    d0,a5
[00011aa0] 2013                      move.l    (a3),d0
[00011aa2] 2211                      move.l    (a1),d1
[00011aa4] 4681                      not.l     d1
[00011aa6] 8280                      or.l      d0,d1
[00011aa8] c09d                      and.l     (a5)+,d0
[00011aaa] c082                      and.l     d2,d0
[00011aac] 4680                      not.l     d0
[00011aae] b181                      eor.l     d0,d1
[00011ab0] 22c1                      move.l    d1,(a1)+
[00011ab2] 202b 0004                 move.l    4(a3),d0
[00011ab6] 2211                      move.l    (a1),d1
[00011ab8] 4681                      not.l     d1
[00011aba] 8280                      or.l      d0,d1
[00011abc] c09d                      and.l     (a5)+,d0
[00011abe] c082                      and.l     d2,d0
[00011ac0] 4680                      not.l     d0
[00011ac2] b181                      eor.l     d0,d1
[00011ac4] 22c1                      move.l    d1,(a1)+
[00011ac6] d0c6                      adda.w    d6,a0
[00011ac8] d2c7                      adda.w    d7,a1
[00011aca] 51cd ff70                 dbf       d5,$00011A3C
[00011ace] 4e75                      rts
[00011ad0] 7000                      moveq.l   #0,d0
[00011ad2] 1018                      move.b    (a0)+,d0
[00011ad4] e748                      lsl.w     #3,d0
[00011ad6] 2a4c                      movea.l   a4,a5
[00011ad8] dac0                      adda.w    d0,a5
[00011ada] 2012                      move.l    (a2),d0
[00011adc] 4680                      not.l     d0
[00011ade] c191                      and.l     d0,(a1)
[00011ae0] 221d                      move.l    (a5)+,d1
[00011ae2] 4680                      not.l     d0
[00011ae4] c081                      and.l     d1,d0
[00011ae6] c082                      and.l     d2,d0
[00011ae8] 4681                      not.l     d1
[00011aea] c292                      and.l     (a2),d1
[00011aec] c283                      and.l     d3,d1
[00011aee] 8081                      or.l      d1,d0
[00011af0] 8199                      or.l      d0,(a1)+
[00011af2] 202a 0004                 move.l    4(a2),d0
[00011af6] 4680                      not.l     d0
[00011af8] c191                      and.l     d0,(a1)
[00011afa] 221d                      move.l    (a5)+,d1
[00011afc] 4680                      not.l     d0
[00011afe] c081                      and.l     d1,d0
[00011b00] c082                      and.l     d2,d0
[00011b02] 4681                      not.l     d1
[00011b04] c2aa 0004                 and.l     4(a2),d1
[00011b08] c283                      and.l     d3,d1
[00011b0a] 8081                      or.l      d1,d0
[00011b0c] 8199                      or.l      d0,(a1)+
[00011b0e] 3f04                      move.w    d4,-(a7)
[00011b10] 6b2a                      bmi.s     $00011B3C
[00011b12] 7000                      moveq.l   #0,d0
[00011b14] 1018                      move.b    (a0)+,d0
[00011b16] e748                      lsl.w     #3,d0
[00011b18] 2a4c                      movea.l   a4,a5
[00011b1a] dac0                      adda.w    d0,a5
[00011b1c] 201d                      move.l    (a5)+,d0
[00011b1e] 2200                      move.l    d0,d1
[00011b20] 4681                      not.l     d1
[00011b22] c082                      and.l     d2,d0
[00011b24] c283                      and.l     d3,d1
[00011b26] 8081                      or.l      d1,d0
[00011b28] 22c0                      move.l    d0,(a1)+
[00011b2a] 201d                      move.l    (a5)+,d0
[00011b2c] 2200                      move.l    d0,d1
[00011b2e] 4681                      not.l     d1
[00011b30] c082                      and.l     d2,d0
[00011b32] c283                      and.l     d3,d1
[00011b34] 8081                      or.l      d1,d0
[00011b36] 22c0                      move.l    d0,(a1)+
[00011b38] 51cc ffd8                 dbf       d4,$00011B12
[00011b3c] 381f                      move.w    (a7)+,d4
[00011b3e] 7000                      moveq.l   #0,d0
[00011b40] 1018                      move.b    (a0)+,d0
[00011b42] e748                      lsl.w     #3,d0
[00011b44] 2a4c                      movea.l   a4,a5
[00011b46] dac0                      adda.w    d0,a5
[00011b48] 2013                      move.l    (a3),d0
[00011b4a] 4680                      not.l     d0
[00011b4c] c191                      and.l     d0,(a1)
[00011b4e] 221d                      move.l    (a5)+,d1
[00011b50] 4680                      not.l     d0
[00011b52] c081                      and.l     d1,d0
[00011b54] c082                      and.l     d2,d0
[00011b56] 4681                      not.l     d1
[00011b58] c293                      and.l     (a3),d1
[00011b5a] c283                      and.l     d3,d1
[00011b5c] 8081                      or.l      d1,d0
[00011b5e] 8199                      or.l      d0,(a1)+
[00011b60] 202b 0004                 move.l    4(a3),d0
[00011b64] 4680                      not.l     d0
[00011b66] c191                      and.l     d0,(a1)
[00011b68] 221d                      move.l    (a5)+,d1
[00011b6a] 4680                      not.l     d0
[00011b6c] c081                      and.l     d1,d0
[00011b6e] c082                      and.l     d2,d0
[00011b70] 4681                      not.l     d1
[00011b72] c2ab 0004                 and.l     4(a3),d1
[00011b76] c283                      and.l     d3,d1
[00011b78] 8081                      or.l      d1,d0
[00011b7a] 8199                      or.l      d0,(a1)+
[00011b7c] d0c6                      adda.w    d6,a0
[00011b7e] d2c7                      adda.w    d7,a1
[00011b80] 51cd ff4e                 dbf       d5,$00011AD0
[00011b84] 4e75                      rts
[00011b86] 7000                      moveq.l   #0,d0
[00011b88] 1018                      move.b    (a0)+,d0
[00011b8a] e748                      lsl.w     #3,d0
[00011b8c] 2a4c                      movea.l   a4,a5
[00011b8e] dac0                      adda.w    d0,a5
[00011b90] 201d                      move.l    (a5)+,d0
[00011b92] c092                      and.l     (a2),d0
[00011b94] 8199                      or.l      d0,(a1)+
[00011b96] 201d                      move.l    (a5)+,d0
[00011b98] c0aa 0004                 and.l     4(a2),d0
[00011b9c] 8199                      or.l      d0,(a1)+
[00011b9e] 3204                      move.w    d4,d1
[00011ba0] 6b20                      bmi.s     $00011BC2
[00011ba2] 7000                      moveq.l   #0,d0
[00011ba4] 1018                      move.b    (a0)+,d0
[00011ba6] 6714                      beq.s     $00011BBC
[00011ba8] e748                      lsl.w     #3,d0
[00011baa] 2a4c                      movea.l   a4,a5
[00011bac] dac0                      adda.w    d0,a5
[00011bae] 201d                      move.l    (a5)+,d0
[00011bb0] 8199                      or.l      d0,(a1)+
[00011bb2] 201d                      move.l    (a5)+,d0
[00011bb4] 8199                      or.l      d0,(a1)+
[00011bb6] 51c9 ffea                 dbf       d1,$00011BA2
[00011bba] 6006                      bra.s     $00011BC2
[00011bbc] 5089                      addq.l    #8,a1
[00011bbe] 51c9 ffe2                 dbf       d1,$00011BA2
[00011bc2] 7000                      moveq.l   #0,d0
[00011bc4] 1018                      move.b    (a0)+,d0
[00011bc6] e748                      lsl.w     #3,d0
[00011bc8] 2a4c                      movea.l   a4,a5
[00011bca] dac0                      adda.w    d0,a5
[00011bcc] 201d                      move.l    (a5)+,d0
[00011bce] c093                      and.l     (a3),d0
[00011bd0] 8199                      or.l      d0,(a1)+
[00011bd2] 201d                      move.l    (a5)+,d0
[00011bd4] c0ab 0004                 and.l     4(a3),d0
[00011bd8] 8199                      or.l      d0,(a1)+
[00011bda] d0c6                      adda.w    d6,a0
[00011bdc] d2c7                      adda.w    d7,a1
[00011bde] 51cd ffa6                 dbf       d5,$00011B86
[00011be2] 4e75                      rts
[00011be4] 4682                      not.l     d2
[00011be6] 67b6                      beq.s     $00011B9E
[00011be8] 6024                      bra.s     $00011C0E
[00011bea] 4682                      not.l     d2
[00011bec] 6798                      beq.s     $00011B86
[00011bee] 7000                      moveq.l   #0,d0
[00011bf0] 1018                      move.b    (a0)+,d0
[00011bf2] e748                      lsl.w     #3,d0
[00011bf4] 2a4c                      movea.l   a4,a5
[00011bf6] dac0                      adda.w    d0,a5
[00011bf8] 201d                      move.l    (a5)+,d0
[00011bfa] c092                      and.l     (a2),d0
[00011bfc] 8191                      or.l      d0,(a1)
[00011bfe] c082                      and.l     d2,d0
[00011c00] b199                      eor.l     d0,(a1)+
[00011c02] 201d                      move.l    (a5)+,d0
[00011c04] c0aa 0004                 and.l     4(a2),d0
[00011c08] 8191                      or.l      d0,(a1)
[00011c0a] c082                      and.l     d2,d0
[00011c0c] b199                      eor.l     d0,(a1)+
[00011c0e] 3204                      move.w    d4,d1
[00011c10] 6b28                      bmi.s     $00011C3A
[00011c12] 7000                      moveq.l   #0,d0
[00011c14] 1018                      move.b    (a0)+,d0
[00011c16] 671c                      beq.s     $00011C34
[00011c18] e748                      lsl.w     #3,d0
[00011c1a] 2a4c                      movea.l   a4,a5
[00011c1c] dac0                      adda.w    d0,a5
[00011c1e] 201d                      move.l    (a5)+,d0
[00011c20] 8191                      or.l      d0,(a1)
[00011c22] c082                      and.l     d2,d0
[00011c24] b199                      eor.l     d0,(a1)+
[00011c26] 201d                      move.l    (a5)+,d0
[00011c28] 8191                      or.l      d0,(a1)
[00011c2a] c082                      and.l     d2,d0
[00011c2c] b199                      eor.l     d0,(a1)+
[00011c2e] 51c9 ffe2                 dbf       d1,$00011C12
[00011c32] 6006                      bra.s     $00011C3A
[00011c34] 5089                      addq.l    #8,a1
[00011c36] 51c9 ffda                 dbf       d1,$00011C12
[00011c3a] 7000                      moveq.l   #0,d0
[00011c3c] 1018                      move.b    (a0)+,d0
[00011c3e] e748                      lsl.w     #3,d0
[00011c40] 2a4c                      movea.l   a4,a5
[00011c42] dac0                      adda.w    d0,a5
[00011c44] 201d                      move.l    (a5)+,d0
[00011c46] c093                      and.l     (a3),d0
[00011c48] 8191                      or.l      d0,(a1)
[00011c4a] c082                      and.l     d2,d0
[00011c4c] b199                      eor.l     d0,(a1)+
[00011c4e] 201d                      move.l    (a5)+,d0
[00011c50] c0ab 0004                 and.l     4(a3),d0
[00011c54] 8191                      or.l      d0,(a1)
[00011c56] c082                      and.l     d2,d0
[00011c58] b199                      eor.l     d0,(a1)+
[00011c5a] d0c6                      adda.w    d6,a0
[00011c5c] d2c7                      adda.w    d7,a1
[00011c5e] 51cd ff8e                 dbf       d5,$00011BEE
[00011c62] 4e75                      rts
[00011c64] 7000                      moveq.l   #0,d0
[00011c66] 1018                      move.b    (a0)+,d0
[00011c68] e748                      lsl.w     #3,d0
[00011c6a] 2a4c                      movea.l   a4,a5
[00011c6c] dac0                      adda.w    d0,a5
[00011c6e] 201d                      move.l    (a5)+,d0
[00011c70] c092                      and.l     (a2),d0
[00011c72] b199                      eor.l     d0,(a1)+
[00011c74] 201d                      move.l    (a5)+,d0
[00011c76] c0aa 0004                 and.l     4(a2),d0
[00011c7a] b199                      eor.l     d0,(a1)+
[00011c7c] 3204                      move.w    d4,d1
[00011c7e] 6b20                      bmi.s     $00011CA0
[00011c80] 7000                      moveq.l   #0,d0
[00011c82] 1018                      move.b    (a0)+,d0
[00011c84] 6714                      beq.s     $00011C9A
[00011c86] e748                      lsl.w     #3,d0
[00011c88] 2a4c                      movea.l   a4,a5
[00011c8a] dac0                      adda.w    d0,a5
[00011c8c] 201d                      move.l    (a5)+,d0
[00011c8e] b199                      eor.l     d0,(a1)+
[00011c90] 201d                      move.l    (a5)+,d0
[00011c92] b199                      eor.l     d0,(a1)+
[00011c94] 51c9 ffea                 dbf       d1,$00011C80
[00011c98] 6006                      bra.s     $00011CA0
[00011c9a] 5089                      addq.l    #8,a1
[00011c9c] 51c9 ffe2                 dbf       d1,$00011C80
[00011ca0] 7000                      moveq.l   #0,d0
[00011ca2] 1018                      move.b    (a0)+,d0
[00011ca4] e748                      lsl.w     #3,d0
[00011ca6] 2a4c                      movea.l   a4,a5
[00011ca8] dac0                      adda.w    d0,a5
[00011caa] 201d                      move.l    (a5)+,d0
[00011cac] c093                      and.l     (a3),d0
[00011cae] b199                      eor.l     d0,(a1)+
[00011cb0] 201d                      move.l    (a5)+,d0
[00011cb2] c0ab 0004                 and.l     4(a3),d0
[00011cb6] b199                      eor.l     d0,(a1)+
[00011cb8] d0c6                      adda.w    d6,a0
[00011cba] d2c7                      adda.w    d7,a1
[00011cbc] 51cd ffa6                 dbf       d5,$00011C64
[00011cc0] 4e75                      rts
[00011cc2] 4683                      not.l     d3
[00011cc4] 6024                      bra.s     $00011CEA
[00011cc6] 4683                      not.l     d3
[00011cc8] 7000                      moveq.l   #0,d0
[00011cca] 1018                      move.b    (a0)+,d0
[00011ccc] 4600                      not.b     d0
[00011cce] e748                      lsl.w     #3,d0
[00011cd0] 2a4c                      movea.l   a4,a5
[00011cd2] dac0                      adda.w    d0,a5
[00011cd4] 201d                      move.l    (a5)+,d0
[00011cd6] c092                      and.l     (a2),d0
[00011cd8] 8191                      or.l      d0,(a1)
[00011cda] c083                      and.l     d3,d0
[00011cdc] b199                      eor.l     d0,(a1)+
[00011cde] 201d                      move.l    (a5)+,d0
[00011ce0] c0aa 0004                 and.l     4(a2),d0
[00011ce4] 8191                      or.l      d0,(a1)
[00011ce6] c083                      and.l     d3,d0
[00011ce8] b199                      eor.l     d0,(a1)+
[00011cea] 3204                      move.w    d4,d1
[00011cec] 6b2a                      bmi.s     $00011D18
[00011cee] 7000                      moveq.l   #0,d0
[00011cf0] 1018                      move.b    (a0)+,d0
[00011cf2] 4600                      not.b     d0
[00011cf4] 671c                      beq.s     $00011D12
[00011cf6] e748                      lsl.w     #3,d0
[00011cf8] 2a4c                      movea.l   a4,a5
[00011cfa] dac0                      adda.w    d0,a5
[00011cfc] 201d                      move.l    (a5)+,d0
[00011cfe] 8191                      or.l      d0,(a1)
[00011d00] c083                      and.l     d3,d0
[00011d02] b199                      eor.l     d0,(a1)+
[00011d04] 201d                      move.l    (a5)+,d0
[00011d06] 8191                      or.l      d0,(a1)
[00011d08] c083                      and.l     d3,d0
[00011d0a] b199                      eor.l     d0,(a1)+
[00011d0c] 51c9 ffe0                 dbf       d1,$00011CEE
[00011d10] 6006                      bra.s     $00011D18
[00011d12] 5089                      addq.l    #8,a1
[00011d14] 51c9 ffd8                 dbf       d1,$00011CEE
[00011d18] 7000                      moveq.l   #0,d0
[00011d1a] 1018                      move.b    (a0)+,d0
[00011d1c] 4600                      not.b     d0
[00011d1e] e748                      lsl.w     #3,d0
[00011d20] 2a4c                      movea.l   a4,a5
[00011d22] dac0                      adda.w    d0,a5
[00011d24] 201d                      move.l    (a5)+,d0
[00011d26] c093                      and.l     (a3),d0
[00011d28] 8191                      or.l      d0,(a1)
[00011d2a] c083                      and.l     d3,d0
[00011d2c] b199                      eor.l     d0,(a1)+
[00011d2e] 201d                      move.l    (a5)+,d0
[00011d30] c0ab 0004                 and.l     4(a3),d0
[00011d34] 8191                      or.l      d0,(a1)
[00011d36] c083                      and.l     d3,d0
[00011d38] b199                      eor.l     d0,(a1)+
[00011d3a] d0c6                      adda.w    d6,a0
[00011d3c] d2c7                      adda.w    d7,a1
[00011d3e] 51cd ff88                 dbf       d5,$00011CC8
[00011d42] 4e75                      rts
[00011d44] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00011d4c] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011d50] ffff ffff 0000 ffff       vperm     #$0000FFFF,e23,e23,e23
[00011d58] ffff ffff 0000 00ff       vperm     #$000000FF,e23,e23,e23
[00011d60] ffff ffff 0000 0000       vperm     #$00000000,e23,e23,e23
[00011d68] ffff ffff 0000 0000       vperm     #$00000000,e23,e23,e23
[00011d70] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011d74] 0000 0000                 ori.b     #$00,d0
[00011d78] 0000 ffff                 ori.b     #$FF,d0
[00011d7c] 0000 0000                 ori.b     #$00,d0
[00011d80] 0000 00ff                 ori.b     #$FF,d0
[00011d84] ff00                      dc.w      $FF00 ; illegal
[00011d86] 0000 0000                 ori.b     #$00,d0
[00011d8a] 0000 ffff                 ori.b     #$FF,d0
[00011d8e] 0000 0000                 ori.b     #$00,d0
[00011d92] 0000 ffff                 ori.b     #$FF,d0
[00011d96] ff00                      dc.w      $FF00 ; illegal
[00011d98] 0000 0000                 ori.b     #$00,d0
[00011d9c] ffff ffff 0000 0000       vperm     #$00000000,e23,e23,e23
[00011da4] ffff ffff ff00 0000       vperm     #$FF000000,e23,e23,e23
[00011dac] ffff ffff ffff 0000       vperm     #$FFFF0000,e23,e23,e23
[00011db4] ffff ffff ffff ff00       vperm     #$FFFFFF00,e23,e23,e23
[00011dbc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00011dc4] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00011dcc] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011dd0] ffff ffff 00ff ffff       vperm     #$00FFFFFF,e23,e23,e23
[00011dd8] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011ddc] 0000 ffff                 ori.b     #$FF,d0
[00011de0] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011de4] 0000 ffff                 ori.b     #$FF,d0
[00011de8] 0000 ffff                 ori.b     #$FF,d0
[00011dec] 0000 00ff                 ori.b     #$FF,d0
[00011df0] 0000 ffff                 ori.b     #$FF,d0
[00011df4] 0000 00ff                 ori.b     #$FF,d0
[00011df8] 0000 00ff                 ori.b     #$FF,d0
[00011dfc] 0000 0000                 ori.b     #$00,d0
[00011e00] 0000 00ff                 ori.b     #$FF,d0
[00011e04] ff00                      dc.w      $FF00 ; illegal
[00011e06] 0000 0000                 ori.b     #$00,d0
[00011e0a] 0000 ff00                 ori.b     #$00,d0
[00011e0e] 0000 ff00                 ori.b     #$00,d0
[00011e12] 0000 ffff                 ori.b     #$FF,d0
[00011e16] 0000 ff00                 ori.b     #$00,d0
[00011e1a] 0000 ffff                 ori.b     #$FF,d0
[00011e1e] 0000 ffff                 ori.b     #$FF,d0
[00011e22] 0000 ffff                 ori.b     #$FF,d0
[00011e26] ff00                      dc.w      $FF00 ; illegal
[00011e28] ffff 0000 ffff ff00       vperm     #$FFFFFF00,e8,e8,e8
[00011e30] ffff ff00 ffff ffff       vperm     #$FFFFFFFF,e8,e23,e23
[00011e38] ffff ff00 ffff ffff       vperm     #$FFFFFFFF,e8,e23,e23
[00011e40] ffff ffff 4a41 6646       vperm     #$4A416646,e23,e23,e23
[00011e48] 7607                      moveq.l   #7,d3
[00011e4a] c644                      and.w     d4,d3
[00011e4c] 5f43                      subq.w    #7,d3
[00011e4e] 663e                      bne.s     $00011E8E
[00011e50] 302e 01ee                 move.w    494(a6),d0
[00011e54] 6708                      beq.s     $00011E5E
[00011e56] 5540                      subq.w    #2,d0
[00011e58] 6d0a                      blt.s     $00011E64
[00011e5a] 6710                      beq.s     $00011E6C
[00011e5c] 6030                      bra.s     $00011E8E
[00011e5e] 4a6e 01ec                 tst.w     492(a6)
[00011e62] 662a                      bne.s     $00011E8E
[00011e64] 0c6e 0001 01ea            cmpi.w    #$0001,490(a6)
[00011e6a] 6622                      bne.s     $00011E8E
[00011e6c] 5244                      addq.w    #1,d4
[00011e6e] 9e44                      sub.w     d4,d7
[00011e70] e64c                      lsr.w     #3,d4
[00011e72] 9c44                      sub.w     d4,d6
[00011e74] 5344                      subq.w    #1,d4
[00011e76] 49fa 2f70                 lea.l     $00014DE8(pc),a4
[00011e7a] 302e 01ee                 move.w    494(a6),d0
[00011e7e] d040                      add.w     d0,d0
[00011e80] 303b 0006                 move.w    $00011E88(pc,d0.w),d0
[00011e84] 4efb 0002                 jmp       $00011E88(pc,d0.w)
J6:
[00011e88] 0140                      dc.w $0140   ; $00011fc8-$00011e88
[00011e8a] 0182                      dc.w $0182   ; $0001200a-$00011e88
[00011e8c] 01b4                      dc.w $01b4   ; $0001203c-$00011e88
[00011e8e] 45fa                      dc.w $45fa   ; $00016482-$00011e88
[00011e90] ff34                      dc.w $ff34   ; $00011dbc-$00011e88
[00011e92] 47fa                      dc.w $47fa   ; $00016682-$00011e88
[00011e94] ff70                      dc.w $ff70   ; $00011df8-$00011e88
[00011e96] 7608                      dc.w $7608   ; $00019490-$00011e88
[00011e98] 9641                      dc.w $9641   ; $0000b4c9-$00011e88
[00011e9a] 9843                      dc.w $9843   ; $0000b6cb-$00011e88
[00011e9c] 6b00                      dc.w $6b00   ; $00018988-$00011e88
[00011e9e] 0096                      dc.w $0096   ; $00011f1e-$00011e88
[00011ea0] e749                      dc.w $e749   ; $000105d1-$00011e88
[00011ea2] d4c1                      dc.w $d4c1   ; $0000f349-$00011e88
[00011ea4] 7007                      dc.w $7007   ; $00018e8f-$00011e88
[00011ea6] c044                      dc.w $c044   ; $0000decc-$00011e88
[00011ea8] 9840                      dc.w $9840   ; $0000b6c8-$00011e88
[00011eaa] e748                      dc.w $e748   ; $000105d0-$00011e88
[00011eac] d6c0                      dc.w $d6c0   ; $0000f548-$00011e88
[00011eae] 9e44                      dc.w $9e44   ; $0000bccc-$00011e88
[00011eb0] 5147                      dc.w $5147   ; $00016fcf-$00011e88
[00011eb2] e64c                      dc.w $e64c   ; $000104d4-$00011e88
[00011eb4] 9c44                      dc.w $9c44   ; $0000bacc-$00011e88
[00011eb6] 5546                      dc.w $5546   ; $000173ce-$00011e88
[00011eb8] 5344                      dc.w $5344   ; $000171cc-$00011e88
[00011eba] 200c                      dc.w $200c   ; $00013e94-$00011e88
[00011ebc] d8ee                      dc.w $d8ee   ; $0000f776-$00011e88
[00011ebe] 01ea                      dc.w $01ea   ; $00012072-$00011e88
[00011ec0] 050c                      dc.w $050c   ; $00012394-$00011e88
[00011ec2] 0000                      dc.w $0000   ; $00011e88-$00011e88
[00011ec4] 1414                      dc.w $1414   ; $0001329c-$00011e88
[00011ec6] 3202                      dc.w $3202   ; $0001508a-$00011e88
[00011ec8] 4842                      dc.w $4842   ; $000166ca-$00011e88
[00011eca] 3401                      dc.w $3401   ; $00015289-$00011e88
[00011ecc] 2840                      dc.w $2840   ; $000146c8-$00011e88
[00011ece] d8ee                      dc.w $d8ee   ; $0000f776-$00011e88
[00011ed0] 01ec                      dc.w $01ec   ; $00012074-$00011e88
[00011ed2] 070c                      dc.w $070c   ; $00012594-$00011e88
[00011ed4] 0000                      dc.w $0000   ; $00011e88-$00011e88
[00011ed6] 1614                      dc.w $1614   ; $0001349c-$00011e88
[00011ed8] 3203                      dc.w $3203   ; $0001508b-$00011e88
[00011eda] 4843                      dc.w $4843   ; $000166cb-$00011e88
[00011edc] 3601                      dc.w $3601   ; $00015489-$00011e88
[00011ede] 49fa                      dc.w $49fa   ; $00016882-$00011e88
[00011ee0] 2f08                      dc.w $2f08   ; $00014d90-$00011e88
[00011ee2] bbc9                      dc.w $bbc9   ; $0000da51-$00011e88
[00011ee4] 6e16                      dc.w $6e16   ; $00018c9e-$00011e88
[00011ee6] 302e                      dc.w $302e   ; $00014eb6-$00011e88
[00011ee8] 01ee                      dc.w $01ee   ; $00012076-$00011e88
[00011eea] d040                      dc.w $d040   ; $0000eec8-$00011e88
[00011eec] 303b                      dc.w $303b   ; $00014ec3-$00011e88
[00011eee] 0006                      dc.w $0006   ; $00011e8e-$00011e88
[00011ef0] 4efb 0002                 jmp       $00011EF4(pc,d0.w)
[00011ef4] 02be 0576 061e            andi.l    #$0576061E,???
[00011efa] 06ac 220d 9289 1018       addi.l    #$220D9289,4120(a4)
[00011f02] e328                      lsl.b     d1,d0
[00011f04] 4441                      neg.w     d1
[00011f06] 5e41                      addq.w    #7,d1
[00011f08] 224d                      movea.l   a5,a1
[00011f0a] 3a6e 01ee                 movea.w   494(a6),a5
[00011f0e] dacd                      adda.w    a5,a5
[00011f10] 3f0d                      move.w    a5,-(a7)
[00011f12] 3a7b d010                 movea.w   $00011F24(pc,a5.w),a5
[00011f16] 4ebb d00c                 jsr       $00011F24(pc,a5.w)
[00011f1a] 301f                      move.w    (a7)+,d0
[00011f1c] 303b 000e                 move.w    $00011F2C(pc,d0.w),d0
[00011f20] 4efb 000a                 jmp       $00011F2C(pc,d0.w)
[00011f24] f958                      dc.w      $F958 ; illegal
[00011f26] f96c                      dc.w      $F96C ; illegal
[00011f28] f97a                      dc.w      $F97A ; illegal
[00011f2a] f988                      dc.w      $F988 ; illegal
[00011f2c] 0276 0538 0610            andi.w    #$0538,16(a6,d0.w*8) ; 68020+ only
[00011f32] fd96                      dc.w      $FD96 ; illegal
[00011f34] 3001                      move.w    d1,d0
[00011f36] e749                      lsl.w     #3,d1
[00011f38] d843                      add.w     d3,d4
[00011f3a] d044                      add.w     d4,d0
[00011f3c] e748                      lsl.w     #3,d0
[00011f3e] d4c1                      adda.w    d1,a2
[00011f40] d6c0                      adda.w    d0,a3
[00011f42] 241a                      move.l    (a2)+,d2
[00011f44] c49b                      and.l     (a3)+,d2
[00011f46] 2613                      move.l    (a3),d3
[00011f48] c692                      and.l     (a2),d3
[00011f4a] 3446                      movea.w   d6,a2
[00011f4c] 3647                      movea.w   d7,a3
[00011f4e] 2c02                      move.l    d2,d6
[00011f50] 2e03                      move.l    d3,d7
[00011f52] 200c                      move.l    a4,d0
[00011f54] d8ee 01ea                 adda.w    490(a6),a4
[00011f58] 050c 0000                 movep.w   0(a4),d2
[00011f5c] 1414                      move.b    (a4),d2
[00011f5e] 3202                      move.w    d2,d1
[00011f60] 4842                      swap      d2
[00011f62] 3401                      move.w    d1,d2
[00011f64] 2840                      movea.l   d0,a4
[00011f66] d8ee 01ec                 adda.w    492(a6),a4
[00011f6a] 070c 0000                 movep.w   0(a4),d3
[00011f6e] 1614                      move.b    (a4),d3
[00011f70] 3203                      move.w    d3,d1
[00011f72] 4843                      swap      d3
[00011f74] 3601                      move.w    d1,d3
[00011f76] bbc9                      cmpa.l    a1,a5
[00011f78] 6f2a                      ble.s     $00011FA4
[00011f7a] 2f09                      move.l    a1,-(a7)
[00011f7c] 220d                      move.l    a5,d1
[00011f7e] 9289                      sub.l     a1,d1
[00011f80] 1010                      move.b    (a0),d0
[00011f82] e328                      lsl.b     d1,d0
[00011f84] 3204                      move.w    d4,d1
[00011f86] 224d                      movea.l   a5,a1
[00011f88] 3a6e 01ee                 movea.w   494(a6),a5
[00011f8c] dacd                      adda.w    a5,a5
[00011f8e] 3a7b d094                 movea.w   $00011F24(pc,a5.w),a5
[00011f92] 4ebb d090                 jsr       $00011F24(pc,a5.w)
[00011f96] 225f                      movea.l   (a7)+,a1
[00011f98] 5089                      addq.l    #8,a1
[00011f9a] d0ca                      adda.w    a2,a0
[00011f9c] d2cb                      adda.w    a3,a1
[00011f9e] 5345                      subq.w    #1,d5
[00011fa0] 6a02                      bpl.s     $00011FA4
[00011fa2] 4e75                      rts
[00011fa4] 3205                      move.w    d5,d1
[00011fa6] 2806                      move.l    d6,d4
[00011fa8] 2a07                      move.l    d7,d5
[00011faa] 4684                      not.l     d4
[00011fac] 4685                      not.l     d5
[00011fae] 49fa 2e38                 lea.l     $00014DE8(pc),a4
[00011fb2] 302e 01ee                 move.w    494(a6),d0
[00011fb6] d040                      add.w     d0,d0
[00011fb8] 303b 0006                 move.w    $00011FC0(pc,d0.w),d0
[00011fbc] 4efb 0002                 jmp       $00011FC0(pc,d0.w)
J7:
[00011fc0] 00e6                      dc.w $00e6   ; $000120a6-$00011fc0
[00011fc2] 013c                      dc.w $013c   ; $000120fc-$00011fc0
[00011fc4] 0176                      dc.w $0176   ; $00012136-$00011fc0
[00011fc6] 01a6                      dc.w $01a6   ; $00012166-$00011fc0
[00011fc8] 3204                      dc.w $3204   ; $000151c4-$00011fc0
[00011fca] 7000                      dc.w $7000   ; $00018fc0-$00011fc0
[00011fcc] 1018                      dc.w $1018   ; $00012fd8-$00011fc0
[00011fce] 6722                      dc.w $6722   ; $000186e2-$00011fc0
[00011fd0] e748                      dc.w $e748   ; $00010708-$00011fc0
[00011fd2] 2a4c                      dc.w $2a4c   ; $00014a0c-$00011fc0
[00011fd4] dac0                      dc.w $dac0   ; $0000fa80-$00011fc0
[00011fd6] 201d                      dc.w $201d   ; $00013fdd-$00011fc0
[00011fd8] 01c9                      dc.w $01c9   ; $00012189-$00011fc0
[00011fda] 0000                      dc.w $0000   ; $00011fc0-$00011fc0
[00011fdc] 201d                      dc.w $201d   ; $00013fdd-$00011fc0
[00011fde] 01c9                      dc.w $01c9   ; $00012189-$00011fc0
[00011fe0] 0001                      dc.w $0001   ; $00011fc1-$00011fc0
[00011fe2] 5089                      addq.l    #8,a1
[00011fe4] 51c9 ffe4                 dbf       d1,$00011FCA
[00011fe8] d0c6                      adda.w    d6,a0
[00011fea] d2c7                      adda.w    d7,a1
[00011fec] 51cd ffda                 dbf       d5,$00011FC8
[00011ff0] 4e75                      rts
[00011ff2] 01c9 0000                 movep.l   d0,0(a1)
[00011ff6] 01c9 0001                 movep.l   d0,1(a1)
[00011ffa] 5089                      addq.l    #8,a1
[00011ffc] 51c9 ffcc                 dbf       d1,$00011FCA
[00012000] d0c6                      adda.w    d6,a0
[00012002] d2c7                      adda.w    d7,a1
[00012004] 51cd ffc2                 dbf       d5,$00011FC8
[00012008] 4e75                      rts
[0001200a] 3204                      move.w    d4,d1
[0001200c] 7000                      moveq.l   #0,d0
[0001200e] 1018                      move.b    (a0)+,d0
[00012010] 671a                      beq.s     $0001202C
[00012012] e748                      lsl.w     #3,d0
[00012014] 2a4c                      movea.l   a4,a5
[00012016] dac0                      adda.w    d0,a5
[00012018] 0149 0000                 movep.l   0(a1),d0
[0001201c] 809d                      or.l      (a5)+,d0
[0001201e] 01c9 0000                 movep.l   d0,0(a1)
[00012022] 0149 0001                 movep.l   1(a1),d0
[00012026] 809d                      or.l      (a5)+,d0
[00012028] 01c9 0001                 movep.l   d0,1(a1)
[0001202c] 5089                      addq.l    #8,a1
[0001202e] 51c9 ffdc                 dbf       d1,$0001200C
[00012032] d0c6                      adda.w    d6,a0
[00012034] d2c7                      adda.w    d7,a1
[00012036] 51cd ffd2                 dbf       d5,$0001200A
[0001203a] 4e75                      rts
[0001203c] 3204                      move.w    d4,d1
[0001203e] 7000                      moveq.l   #0,d0
[00012040] 1018                      move.b    (a0)+,d0
[00012042] 671e                      beq.s     $00012062
[00012044] e748                      lsl.w     #3,d0
[00012046] 2a4c                      movea.l   a4,a5
[00012048] dac0                      adda.w    d0,a5
[0001204a] 0149 0000                 movep.l   0(a1),d0
[0001204e] 241d                      move.l    (a5)+,d2
[00012050] b580                      eor.l     d2,d0
[00012052] 01c9 0000                 movep.l   d0,0(a1)
[00012056] 0149 0001                 movep.l   1(a1),d0
[0001205a] 241d                      move.l    (a5)+,d2
[0001205c] b580                      eor.l     d2,d0
[0001205e] 01c9 0001                 movep.l   d0,1(a1)
[00012062] 5089                      addq.l    #8,a1
[00012064] 51c9 ffd8                 dbf       d1,$0001203E
[00012068] d0c6                      adda.w    d6,a0
[0001206a] d2c7                      adda.w    d7,a1
[0001206c] 51cd ffce                 dbf       d5,$0001203C
[00012070] 4e75                      rts
[00012072] 7000                      moveq.l   #0,d0
[00012074] 1010                      move.b    (a0),d0
[00012076] e748                      lsl.w     #3,d0
[00012078] 2a4c                      movea.l   a4,a5
[0001207a] dac0                      adda.w    d0,a5
[0001207c] 0149 0000                 movep.l   0(a1),d0
[00012080] c084                      and.l     d4,d0
[00012082] 241d                      move.l    (a5)+,d2
[00012084] c486                      and.l     d6,d2
[00012086] 8082                      or.l      d2,d0
[00012088] 01c9 0000                 movep.l   d0,0(a1)
[0001208c] 0149 0001                 movep.l   1(a1),d0
[00012090] c085                      and.l     d5,d0
[00012092] 241d                      move.l    (a5)+,d2
[00012094] c487                      and.l     d7,d2
[00012096] 8082                      or.l      d2,d0
[00012098] 01c9 0001                 movep.l   d0,1(a1)
[0001209c] d0ca                      adda.w    a2,a0
[0001209e] d2cb                      adda.w    a3,a1
[000120a0] 51c9 ffd0                 dbf       d1,$00012072
[000120a4] 4e75                      rts
[000120a6] 4a43                      tst.w     d3
[000120a8] 6606                      bne.s     $000120B0
[000120aa] 3002                      move.w    d2,d0
[000120ac] 4640                      not.w     d0
[000120ae] 67c2                      beq.s     $00012072
[000120b0] 7000                      moveq.l   #0,d0
[000120b2] 1010                      move.b    (a0),d0
[000120b4] e748                      lsl.w     #3,d0
[000120b6] 2a4c                      movea.l   a4,a5
[000120b8] dac0                      adda.w    d0,a5
[000120ba] 0149 0000                 movep.l   0(a1),d0
[000120be] 8086                      or.l      d6,d0
[000120c0] bd80                      eor.l     d6,d0
[000120c2] 281d                      move.l    (a5)+,d4
[000120c4] c886                      and.l     d6,d4
[000120c6] 2a04                      move.l    d4,d5
[000120c8] bd85                      eor.l     d6,d5
[000120ca] c882                      and.l     d2,d4
[000120cc] ca83                      and.l     d3,d5
[000120ce] 8885                      or.l      d5,d4
[000120d0] 8084                      or.l      d4,d0
[000120d2] 01c9 0000                 movep.l   d0,0(a1)
[000120d6] 0149 0001                 movep.l   1(a1),d0
[000120da] 8087                      or.l      d7,d0
[000120dc] bf80                      eor.l     d7,d0
[000120de] 281d                      move.l    (a5)+,d4
[000120e0] c887                      and.l     d7,d4
[000120e2] 2a04                      move.l    d4,d5
[000120e4] bf85                      eor.l     d7,d5
[000120e6] c882                      and.l     d2,d4
[000120e8] ca83                      and.l     d3,d5
[000120ea] 8885                      or.l      d5,d4
[000120ec] 8084                      or.l      d4,d0
[000120ee] 01c9 0001                 movep.l   d0,1(a1)
[000120f2] d0ca                      adda.w    a2,a0
[000120f4] d2cb                      adda.w    a3,a1
[000120f6] 51c9 ffb8                 dbf       d1,$000120B0
[000120fa] 4e75                      rts
[000120fc] 4682                      not.l     d2
[000120fe] 7000                      moveq.l   #0,d0
[00012100] 1010                      move.b    (a0),d0
[00012102] e748                      lsl.w     #3,d0
[00012104] 2a4c                      movea.l   a4,a5
[00012106] dac0                      adda.w    d0,a5
[00012108] 0149 0000                 movep.l   0(a1),d0
[0001210c] 281d                      move.l    (a5)+,d4
[0001210e] c886                      and.l     d6,d4
[00012110] 8084                      or.l      d4,d0
[00012112] c882                      and.l     d2,d4
[00012114] b980                      eor.l     d4,d0
[00012116] 01c9 0000                 movep.l   d0,0(a1)
[0001211a] 0149 0001                 movep.l   1(a1),d0
[0001211e] 281d                      move.l    (a5)+,d4
[00012120] c887                      and.l     d7,d4
[00012122] 8084                      or.l      d4,d0
[00012124] c882                      and.l     d2,d4
[00012126] b980                      eor.l     d4,d0
[00012128] 01c9 0001                 movep.l   d0,1(a1)
[0001212c] d0ca                      adda.w    a2,a0
[0001212e] d2cb                      adda.w    a3,a1
[00012130] 51c9 ffcc                 dbf       d1,$000120FE
[00012134] 4e75                      rts
[00012136] 7000                      moveq.l   #0,d0
[00012138] 1018                      move.b    (a0)+,d0
[0001213a] e748                      lsl.w     #3,d0
[0001213c] 2a4c                      movea.l   a4,a5
[0001213e] dac0                      adda.w    d0,a5
[00012140] 0149 0000                 movep.l   0(a1),d0
[00012144] 281d                      move.l    (a5)+,d4
[00012146] c886                      and.l     d6,d4
[00012148] b980                      eor.l     d4,d0
[0001214a] 01c9 0000                 movep.l   d0,0(a1)
[0001214e] 0149 0001                 movep.l   1(a1),d0
[00012152] 281d                      move.l    (a5)+,d4
[00012154] c887                      and.l     d7,d4
[00012156] b980                      eor.l     d4,d0
[00012158] 01c9 0001                 movep.l   d0,1(a1)
[0001215c] d0ca                      adda.w    a2,a0
[0001215e] d2cb                      adda.w    a3,a1
[00012160] 51c9 ffd4                 dbf       d1,$00012136
[00012164] 4e75                      rts
[00012166] 4683                      not.l     d3
[00012168] 7000                      moveq.l   #0,d0
[0001216a] 1010                      move.b    (a0),d0
[0001216c] 4600                      not.b     d0
[0001216e] e748                      lsl.w     #3,d0
[00012170] 2a4c                      movea.l   a4,a5
[00012172] dac0                      adda.w    d0,a5
[00012174] 0149 0000                 movep.l   0(a1),d0
[00012178] 281d                      move.l    (a5)+,d4
[0001217a] c886                      and.l     d6,d4
[0001217c] 8084                      or.l      d4,d0
[0001217e] c883                      and.l     d3,d4
[00012180] b980                      eor.l     d4,d0
[00012182] 01c9 0000                 movep.l   d0,0(a1)
[00012186] 0149 0001                 movep.l   1(a1),d0
[0001218a] 281d                      move.l    (a5)+,d4
[0001218c] c887                      and.l     d7,d4
[0001218e] 8084                      or.l      d4,d0
[00012190] c883                      and.l     d3,d4
[00012192] b980                      eor.l     d4,d0
[00012194] 01c9 0001                 movep.l   d0,1(a1)
[00012198] d0ca                      adda.w    a2,a0
[0001219a] d2cb                      adda.w    a3,a1
[0001219c] 51c9 ffca                 dbf       d1,$00012168
[000121a0] 4e75                      rts
[000121a2] 4a43                      tst.w     d3
[000121a4] 6600 01b0                 bne       $00012356
[000121a8] 3602                      move.w    d2,d3
[000121aa] 4643                      not.w     d3
[000121ac] 6600 00e6                 bne       $00012294
[000121b0] 6040                      bra.s     $000121F2
[000121b2] 4a43                      tst.w     d3
[000121b4] 6600 0152                 bne       $00012308
[000121b8] 3602                      move.w    d2,d3
[000121ba] 4643                      not.w     d3
[000121bc] 6600 00a0                 bne       $0001225E
[000121c0] 7000                      moveq.l   #0,d0
[000121c2] 1018                      move.b    (a0)+,d0
[000121c4] e748                      lsl.w     #3,d0
[000121c6] 2a4c                      movea.l   a4,a5
[000121c8] dac0                      adda.w    d0,a5
[000121ca] 0149 0000                 movep.l   0(a1),d0
[000121ce] 2212                      move.l    (a2),d1
[000121d0] 8081                      or.l      d1,d0
[000121d2] b380                      eor.l     d1,d0
[000121d4] c29d                      and.l     (a5)+,d1
[000121d6] 8081                      or.l      d1,d0
[000121d8] 01c9 0000                 movep.l   d0,0(a1)
[000121dc] 0149 0001                 movep.l   1(a1),d0
[000121e0] 222a 0004                 move.l    4(a2),d1
[000121e4] 8081                      or.l      d1,d0
[000121e6] b380                      eor.l     d1,d0
[000121e8] c29d                      and.l     (a5)+,d1
[000121ea] 8081                      or.l      d1,d0
[000121ec] 01c9 0001                 movep.l   d0,1(a1)
[000121f0] 5089                      addq.l    #8,a1
[000121f2] 3204                      move.w    d4,d1
[000121f4] 6b2e                      bmi.s     $00012224
[000121f6] 7000                      moveq.l   #0,d0
[000121f8] 1018                      move.b    (a0)+,d0
[000121fa] 671a                      beq.s     $00012216
[000121fc] e748                      lsl.w     #3,d0
[000121fe] 2a4c                      movea.l   a4,a5
[00012200] dac0                      adda.w    d0,a5
[00012202] 201d                      move.l    (a5)+,d0
[00012204] 01c9 0000                 movep.l   d0,0(a1)
[00012208] 201d                      move.l    (a5)+,d0
[0001220a] 01c9 0001                 movep.l   d0,1(a1)
[0001220e] 5089                      addq.l    #8,a1
[00012210] 51c9 ffe4                 dbf       d1,$000121F6
[00012214] 600e                      bra.s     $00012224
[00012216] 01c9 0000                 movep.l   d0,0(a1)
[0001221a] 01c9 0001                 movep.l   d0,1(a1)
[0001221e] 5089                      addq.l    #8,a1
[00012220] 51c9 ffd4                 dbf       d1,$000121F6
[00012224] 7000                      moveq.l   #0,d0
[00012226] 1018                      move.b    (a0)+,d0
[00012228] e748                      lsl.w     #3,d0
[0001222a] 2a4c                      movea.l   a4,a5
[0001222c] dac0                      adda.w    d0,a5
[0001222e] 0149 0000                 movep.l   0(a1),d0
[00012232] 2213                      move.l    (a3),d1
[00012234] 8081                      or.l      d1,d0
[00012236] b380                      eor.l     d1,d0
[00012238] c29d                      and.l     (a5)+,d1
[0001223a] 8081                      or.l      d1,d0
[0001223c] 01c9 0000                 movep.l   d0,0(a1)
[00012240] 0149 0001                 movep.l   1(a1),d0
[00012244] 222b 0004                 move.l    4(a3),d1
[00012248] 8081                      or.l      d1,d0
[0001224a] b380                      eor.l     d1,d0
[0001224c] c29d                      and.l     (a5)+,d1
[0001224e] 8081                      or.l      d1,d0
[00012250] 01c9 0001                 movep.l   d0,1(a1)
[00012254] d0c6                      adda.w    d6,a0
[00012256] d2c7                      adda.w    d7,a1
[00012258] 51cd ff66                 dbf       d5,$000121C0
[0001225c] 4e75                      rts
[0001225e] 7000                      moveq.l   #0,d0
[00012260] 1018                      move.b    (a0)+,d0
[00012262] e748                      lsl.w     #3,d0
[00012264] 2a4c                      movea.l   a4,a5
[00012266] dac0                      adda.w    d0,a5
[00012268] 0149 0000                 movep.l   0(a1),d0
[0001226c] 2212                      move.l    (a2),d1
[0001226e] 8081                      or.l      d1,d0
[00012270] b380                      eor.l     d1,d0
[00012272] c29d                      and.l     (a5)+,d1
[00012274] c282                      and.l     d2,d1
[00012276] 8081                      or.l      d1,d0
[00012278] 01c9 0000                 movep.l   d0,0(a1)
[0001227c] 0149 0001                 movep.l   1(a1),d0
[00012280] 222a 0004                 move.l    4(a2),d1
[00012284] 8081                      or.l      d1,d0
[00012286] b380                      eor.l     d1,d0
[00012288] c29d                      and.l     (a5)+,d1
[0001228a] c282                      and.l     d2,d1
[0001228c] 8081                      or.l      d1,d0
[0001228e] 01c9 0001                 movep.l   d0,1(a1)
[00012292] 5089                      addq.l    #8,a1
[00012294] 3204                      move.w    d4,d1
[00012296] 6b32                      bmi.s     $000122CA
[00012298] 7000                      moveq.l   #0,d0
[0001229a] 1018                      move.b    (a0)+,d0
[0001229c] 671e                      beq.s     $000122BC
[0001229e] e748                      lsl.w     #3,d0
[000122a0] 2a4c                      movea.l   a4,a5
[000122a2] dac0                      adda.w    d0,a5
[000122a4] 201d                      move.l    (a5)+,d0
[000122a6] c082                      and.l     d2,d0
[000122a8] 01c9 0000                 movep.l   d0,0(a1)
[000122ac] 201d                      move.l    (a5)+,d0
[000122ae] c082                      and.l     d2,d0
[000122b0] 01c9 0001                 movep.l   d0,1(a1)
[000122b4] 5089                      addq.l    #8,a1
[000122b6] 51c9 ffe0                 dbf       d1,$00012298
[000122ba] 600e                      bra.s     $000122CA
[000122bc] 01c9 0000                 movep.l   d0,0(a1)
[000122c0] 01c9 0001                 movep.l   d0,1(a1)
[000122c4] 5089                      addq.l    #8,a1
[000122c6] 51c9 ffd0                 dbf       d1,$00012298
[000122ca] 7000                      moveq.l   #0,d0
[000122cc] 1018                      move.b    (a0)+,d0
[000122ce] e748                      lsl.w     #3,d0
[000122d0] 2a4c                      movea.l   a4,a5
[000122d2] dac0                      adda.w    d0,a5
[000122d4] 0149 0000                 movep.l   0(a1),d0
[000122d8] 2213                      move.l    (a3),d1
[000122da] 8081                      or.l      d1,d0
[000122dc] b380                      eor.l     d1,d0
[000122de] c29d                      and.l     (a5)+,d1
[000122e0] c282                      and.l     d2,d1
[000122e2] 8081                      or.l      d1,d0
[000122e4] 01c9 0000                 movep.l   d0,0(a1)
[000122e8] 0149 0001                 movep.l   1(a1),d0
[000122ec] 222b 0004                 move.l    4(a3),d1
[000122f0] 8081                      or.l      d1,d0
[000122f2] b380                      eor.l     d1,d0
[000122f4] c29d                      and.l     (a5)+,d1
[000122f6] c282                      and.l     d2,d1
[000122f8] 8081                      or.l      d1,d0
[000122fa] 01c9 0001                 movep.l   d0,1(a1)
[000122fe] d0c6                      adda.w    d6,a0
[00012300] d2c7                      adda.w    d7,a1
[00012302] 51cd ff5a                 dbf       d5,$0001225E
[00012306] 4e75                      rts
[00012308] 3f06                      move.w    d6,-(a7)
[0001230a] 3f07                      move.w    d7,-(a7)
[0001230c] 7000                      moveq.l   #0,d0
[0001230e] 1018                      move.b    (a0)+,d0
[00012310] e748                      lsl.w     #3,d0
[00012312] 2a4c                      movea.l   a4,a5
[00012314] dac0                      adda.w    d0,a5
[00012316] 0149 0000                 movep.l   0(a1),d0
[0001231a] 2212                      move.l    (a2),d1
[0001231c] 8081                      or.l      d1,d0
[0001231e] b380                      eor.l     d1,d0
[00012320] 2c1d                      move.l    (a5)+,d6
[00012322] cc81                      and.l     d1,d6
[00012324] 2e06                      move.l    d6,d7
[00012326] b387                      eor.l     d1,d7
[00012328] cc82                      and.l     d2,d6
[0001232a] ce83                      and.l     d3,d7
[0001232c] 8c87                      or.l      d7,d6
[0001232e] 8086                      or.l      d6,d0
[00012330] 01c9 0000                 movep.l   d0,0(a1)
[00012334] 0149 0001                 movep.l   1(a1),d0
[00012338] 222a 0004                 move.l    4(a2),d1
[0001233c] 8081                      or.l      d1,d0
[0001233e] b380                      eor.l     d1,d0
[00012340] 2c1d                      move.l    (a5)+,d6
[00012342] cc81                      and.l     d1,d6
[00012344] 2e06                      move.l    d6,d7
[00012346] b387                      eor.l     d1,d7
[00012348] cc82                      and.l     d2,d6
[0001234a] ce83                      and.l     d3,d7
[0001234c] 8c87                      or.l      d7,d6
[0001234e] 8086                      or.l      d6,d0
[00012350] 01c9 0001                 movep.l   d0,1(a1)
[00012354] 5089                      addq.l    #8,a1
[00012356] 3f04                      move.w    d4,-(a7)
[00012358] 6b30                      bmi.s     $0001238A
[0001235a] 7000                      moveq.l   #0,d0
[0001235c] 1018                      move.b    (a0)+,d0
[0001235e] e748                      lsl.w     #3,d0
[00012360] 2a4c                      movea.l   a4,a5
[00012362] dac0                      adda.w    d0,a5
[00012364] 201d                      move.l    (a5)+,d0
[00012366] 2200                      move.l    d0,d1
[00012368] 4681                      not.l     d1
[0001236a] c082                      and.l     d2,d0
[0001236c] c283                      and.l     d3,d1
[0001236e] 8081                      or.l      d1,d0
[00012370] 01c9 0000                 movep.l   d0,0(a1)
[00012374] 201d                      move.l    (a5)+,d0
[00012376] 2200                      move.l    d0,d1
[00012378] 4681                      not.l     d1
[0001237a] c082                      and.l     d2,d0
[0001237c] c283                      and.l     d3,d1
[0001237e] 8081                      or.l      d1,d0
[00012380] 01c9 0001                 movep.l   d0,1(a1)
[00012384] 5089                      addq.l    #8,a1
[00012386] 51cc ffd2                 dbf       d4,$0001235A
[0001238a] 381f                      move.w    (a7)+,d4
[0001238c] 7000                      moveq.l   #0,d0
[0001238e] 1018                      move.b    (a0)+,d0
[00012390] e748                      lsl.w     #3,d0
[00012392] 2a4c                      movea.l   a4,a5
[00012394] dac0                      adda.w    d0,a5
[00012396] 0149 0000                 movep.l   0(a1),d0
[0001239a] 2213                      move.l    (a3),d1
[0001239c] 8081                      or.l      d1,d0
[0001239e] b380                      eor.l     d1,d0
[000123a0] 2c1d                      move.l    (a5)+,d6
[000123a2] cc81                      and.l     d1,d6
[000123a4] 2e06                      move.l    d6,d7
[000123a6] b387                      eor.l     d1,d7
[000123a8] cc82                      and.l     d2,d6
[000123aa] ce83                      and.l     d3,d7
[000123ac] 8c87                      or.l      d7,d6
[000123ae] 8086                      or.l      d6,d0
[000123b0] 01c9 0000                 movep.l   d0,0(a1)
[000123b4] 0149 0001                 movep.l   1(a1),d0
[000123b8] 8081                      or.l      d1,d0
[000123ba] b380                      eor.l     d1,d0
[000123bc] 2c1d                      move.l    (a5)+,d6
[000123be] cc81                      and.l     d1,d6
[000123c0] 2e06                      move.l    d6,d7
[000123c2] b387                      eor.l     d1,d7
[000123c4] cc82                      and.l     d2,d6
[000123c6] ce83                      and.l     d3,d7
[000123c8] 8c87                      or.l      d7,d6
[000123ca] 8086                      or.l      d6,d0
[000123cc] 01c9 0001                 movep.l   d0,1(a1)
[000123d0] 3e1f                      move.w    (a7)+,d7
[000123d2] 3c1f                      move.w    (a7)+,d6
[000123d4] d0c6                      adda.w    d6,a0
[000123d6] d2c7                      adda.w    d7,a1
[000123d8] 51cd ff2e                 dbf       d5,$00012308
[000123dc] 4e75                      rts
[000123de] 7000                      moveq.l   #0,d0
[000123e0] 1018                      move.b    (a0)+,d0
[000123e2] e748                      lsl.w     #3,d0
[000123e4] 2a4c                      movea.l   a4,a5
[000123e6] dac0                      adda.w    d0,a5
[000123e8] 0349 0000                 movep.l   0(a1),d1
[000123ec] 201d                      move.l    (a5)+,d0
[000123ee] c092                      and.l     (a2),d0
[000123f0] 8280                      or.l      d0,d1
[000123f2] 03c9 0000                 movep.l   d1,0(a1)
[000123f6] 0349 0001                 movep.l   1(a1),d1
[000123fa] 201d                      move.l    (a5)+,d0
[000123fc] c0aa 0004                 and.l     4(a2),d0
[00012400] 8280                      or.l      d0,d1
[00012402] 03c9 0001                 movep.l   d1,1(a1)
[00012406] 5089                      addq.l    #8,a1
[00012408] 3204                      move.w    d4,d1
[0001240a] 6b26                      bmi.s     $00012432
[0001240c] 7000                      moveq.l   #0,d0
[0001240e] 1018                      move.b    (a0)+,d0
[00012410] 671a                      beq.s     $0001242C
[00012412] e748                      lsl.w     #3,d0
[00012414] 2a4c                      movea.l   a4,a5
[00012416] dac0                      adda.w    d0,a5
[00012418] 0149 0000                 movep.l   0(a1),d0
[0001241c] 809d                      or.l      (a5)+,d0
[0001241e] 01c9 0000                 movep.l   d0,0(a1)
[00012422] 0149 0001                 movep.l   1(a1),d0
[00012426] 809d                      or.l      (a5)+,d0
[00012428] 01c9 0001                 movep.l   d0,1(a1)
[0001242c] 5089                      addq.l    #8,a1
[0001242e] 51c9 ffdc                 dbf       d1,$0001240C
[00012432] 7000                      moveq.l   #0,d0
[00012434] 1018                      move.b    (a0)+,d0
[00012436] e748                      lsl.w     #3,d0
[00012438] 2a4c                      movea.l   a4,a5
[0001243a] dac0                      adda.w    d0,a5
[0001243c] 0349 0000                 movep.l   0(a1),d1
[00012440] 201d                      move.l    (a5)+,d0
[00012442] c093                      and.l     (a3),d0
[00012444] 8280                      or.l      d0,d1
[00012446] 03c9 0000                 movep.l   d1,0(a1)
[0001244a] 0349 0001                 movep.l   1(a1),d1
[0001244e] 201d                      move.l    (a5)+,d0
[00012450] c0ab 0004                 and.l     4(a3),d0
[00012454] 8280                      or.l      d0,d1
[00012456] 03c9 0001                 movep.l   d1,1(a1)
[0001245a] d0c6                      adda.w    d6,a0
[0001245c] d2c7                      adda.w    d7,a1
[0001245e] 51cd ff7e                 dbf       d5,$000123DE
[00012462] 4e75                      rts
[00012464] 4682                      not.l     d2
[00012466] 67a0                      beq.s     $00012408
[00012468] 6038                      bra.s     $000124A2
[0001246a] 4682                      not.l     d2
[0001246c] 6700 ff70                 beq       $000123DE
[00012470] 7000                      moveq.l   #0,d0
[00012472] 1018                      move.b    (a0)+,d0
[00012474] e748                      lsl.w     #3,d0
[00012476] 2a4c                      movea.l   a4,a5
[00012478] dac0                      adda.w    d0,a5
[0001247a] 0349 0000                 movep.l   0(a1),d1
[0001247e] 201d                      move.l    (a5)+,d0
[00012480] c092                      and.l     (a2),d0
[00012482] 8280                      or.l      d0,d1
[00012484] c082                      and.l     d2,d0
[00012486] b181                      eor.l     d0,d1
[00012488] 03c9 0000                 movep.l   d1,0(a1)
[0001248c] 0349 0001                 movep.l   1(a1),d1
[00012490] 201d                      move.l    (a5)+,d0
[00012492] c0aa 0004                 and.l     4(a2),d0
[00012496] 8280                      or.l      d0,d1
[00012498] c082                      and.l     d2,d0
[0001249a] b181                      eor.l     d0,d1
[0001249c] 03c9 0001                 movep.l   d1,1(a1)
[000124a0] 5089                      addq.l    #8,a1
[000124a2] 3204                      move.w    d4,d1
[000124a4] 6b32                      bmi.s     $000124D8
[000124a6] 7000                      moveq.l   #0,d0
[000124a8] 1018                      move.b    (a0)+,d0
[000124aa] 6726                      beq.s     $000124D2
[000124ac] e748                      lsl.w     #3,d0
[000124ae] 2a4c                      movea.l   a4,a5
[000124b0] dac0                      adda.w    d0,a5
[000124b2] 0149 0000                 movep.l   0(a1),d0
[000124b6] 261d                      move.l    (a5)+,d3
[000124b8] 8083                      or.l      d3,d0
[000124ba] c682                      and.l     d2,d3
[000124bc] b780                      eor.l     d3,d0
[000124be] 01c9 0000                 movep.l   d0,0(a1)
[000124c2] 0149 0001                 movep.l   1(a1),d0
[000124c6] 261d                      move.l    (a5)+,d3
[000124c8] 8083                      or.l      d3,d0
[000124ca] c682                      and.l     d2,d3
[000124cc] b780                      eor.l     d3,d0
[000124ce] 01c9 0001                 movep.l   d0,1(a1)
[000124d2] 5089                      addq.l    #8,a1
[000124d4] 51c9 ffd0                 dbf       d1,$000124A6
[000124d8] 7000                      moveq.l   #0,d0
[000124da] 1018                      move.b    (a0)+,d0
[000124dc] e748                      lsl.w     #3,d0
[000124de] 2a4c                      movea.l   a4,a5
[000124e0] dac0                      adda.w    d0,a5
[000124e2] 0349 0000                 movep.l   0(a1),d1
[000124e6] 201d                      move.l    (a5)+,d0
[000124e8] c093                      and.l     (a3),d0
[000124ea] 8280                      or.l      d0,d1
[000124ec] c082                      and.l     d2,d0
[000124ee] b181                      eor.l     d0,d1
[000124f0] 03c9 0000                 movep.l   d1,0(a1)
[000124f4] 0349 0001                 movep.l   1(a1),d1
[000124f8] 201d                      move.l    (a5)+,d0
[000124fa] c0ab 0004                 and.l     4(a3),d0
[000124fe] 8280                      or.l      d0,d1
[00012500] c082                      and.l     d2,d0
[00012502] b181                      eor.l     d0,d1
[00012504] 03c9 0001                 movep.l   d1,1(a1)
[00012508] d0c6                      adda.w    d6,a0
[0001250a] d2c7                      adda.w    d7,a1
[0001250c] 51cd ff62                 dbf       d5,$00012470
[00012510] 4e75                      rts
[00012512] 7000                      moveq.l   #0,d0
[00012514] 1018                      move.b    (a0)+,d0
[00012516] e748                      lsl.w     #3,d0
[00012518] 2a4c                      movea.l   a4,a5
[0001251a] dac0                      adda.w    d0,a5
[0001251c] 0349 0000                 movep.l   0(a1),d1
[00012520] 201d                      move.l    (a5)+,d0
[00012522] c092                      and.l     (a2),d0
[00012524] b181                      eor.l     d0,d1
[00012526] 03c9 0000                 movep.l   d1,0(a1)
[0001252a] 0349 0001                 movep.l   1(a1),d1
[0001252e] 201d                      move.l    (a5)+,d0
[00012530] c0aa 0004                 and.l     4(a2),d0
[00012534] b181                      eor.l     d0,d1
[00012536] 03c9 0001                 movep.l   d1,1(a1)
[0001253a] 5089                      addq.l    #8,a1
[0001253c] 3204                      move.w    d4,d1
[0001253e] 6b2a                      bmi.s     $0001256A
[00012540] 7000                      moveq.l   #0,d0
[00012542] 1018                      move.b    (a0)+,d0
[00012544] 671e                      beq.s     $00012564
[00012546] e748                      lsl.w     #3,d0
[00012548] 2a4c                      movea.l   a4,a5
[0001254a] dac0                      adda.w    d0,a5
[0001254c] 0149 0000                 movep.l   0(a1),d0
[00012550] 241d                      move.l    (a5)+,d2
[00012552] b580                      eor.l     d2,d0
[00012554] 01c9 0000                 movep.l   d0,0(a1)
[00012558] 0149 0001                 movep.l   1(a1),d0
[0001255c] 241d                      move.l    (a5)+,d2
[0001255e] b580                      eor.l     d2,d0
[00012560] 01c9 0001                 movep.l   d0,1(a1)
[00012564] 5089                      addq.l    #8,a1
[00012566] 51c9 ffd8                 dbf       d1,$00012540
[0001256a] 7000                      moveq.l   #0,d0
[0001256c] 1018                      move.b    (a0)+,d0
[0001256e] e748                      lsl.w     #3,d0
[00012570] 2a4c                      movea.l   a4,a5
[00012572] dac0                      adda.w    d0,a5
[00012574] 0349 0000                 movep.l   0(a1),d1
[00012578] 201d                      move.l    (a5)+,d0
[0001257a] c093                      and.l     (a3),d0
[0001257c] b181                      eor.l     d0,d1
[0001257e] 03c9 0000                 movep.l   d1,0(a1)
[00012582] 0349 0001                 movep.l   1(a1),d1
[00012586] 201d                      move.l    (a5)+,d0
[00012588] c0ab 0004                 and.l     4(a3),d0
[0001258c] b181                      eor.l     d0,d1
[0001258e] 03c9 0001                 movep.l   d1,1(a1)
[00012592] d0c6                      adda.w    d6,a0
[00012594] d2c7                      adda.w    d7,a1
[00012596] 51cd ff7a                 dbf       d5,$00012512
[0001259a] 4e75                      rts
[0001259c] 4683                      not.l     d3
[0001259e] 6036                      bra.s     $000125D6
[000125a0] 4683                      not.l     d3
[000125a2] 7000                      moveq.l   #0,d0
[000125a4] 1018                      move.b    (a0)+,d0
[000125a6] 4600                      not.b     d0
[000125a8] e748                      lsl.w     #3,d0
[000125aa] 2a4c                      movea.l   a4,a5
[000125ac] dac0                      adda.w    d0,a5
[000125ae] 0349 0000                 movep.l   0(a1),d1
[000125b2] 201d                      move.l    (a5)+,d0
[000125b4] c092                      and.l     (a2),d0
[000125b6] 8280                      or.l      d0,d1
[000125b8] c083                      and.l     d3,d0
[000125ba] b181                      eor.l     d0,d1
[000125bc] 03c9 0000                 movep.l   d1,0(a1)
[000125c0] 0349 0001                 movep.l   1(a1),d1
[000125c4] 201d                      move.l    (a5)+,d0
[000125c6] c0aa 0004                 and.l     4(a2),d0
[000125ca] 8280                      or.l      d0,d1
[000125cc] c083                      and.l     d3,d0
[000125ce] b181                      eor.l     d0,d1
[000125d0] 03c9 0001                 movep.l   d1,1(a1)
[000125d4] 5089                      addq.l    #8,a1
[000125d6] 3204                      move.w    d4,d1
[000125d8] 6b34                      bmi.s     $0001260E
[000125da] 7000                      moveq.l   #0,d0
[000125dc] 1018                      move.b    (a0)+,d0
[000125de] 4600                      not.b     d0
[000125e0] 6726                      beq.s     $00012608
[000125e2] e748                      lsl.w     #3,d0
[000125e4] 2a4c                      movea.l   a4,a5
[000125e6] dac0                      adda.w    d0,a5
[000125e8] 0149 0000                 movep.l   0(a1),d0
[000125ec] 241d                      move.l    (a5)+,d2
[000125ee] 8082                      or.l      d2,d0
[000125f0] c483                      and.l     d3,d2
[000125f2] b580                      eor.l     d2,d0
[000125f4] 01c9 0000                 movep.l   d0,0(a1)
[000125f8] 0149 0001                 movep.l   1(a1),d0
[000125fc] 241d                      move.l    (a5)+,d2
[000125fe] 8082                      or.l      d2,d0
[00012600] c483                      and.l     d3,d2
[00012602] b580                      eor.l     d2,d0
[00012604] 01c9 0001                 movep.l   d0,1(a1)
[00012608] 5089                      addq.l    #8,a1
[0001260a] 51c9 ffce                 dbf       d1,$000125DA
[0001260e] 7000                      moveq.l   #0,d0
[00012610] 1018                      move.b    (a0)+,d0
[00012612] 4600                      not.b     d0
[00012614] e748                      lsl.w     #3,d0
[00012616] 2a4c                      movea.l   a4,a5
[00012618] dac0                      adda.w    d0,a5
[0001261a] 0349 0000                 movep.l   0(a1),d1
[0001261e] 201d                      move.l    (a5)+,d0
[00012620] c093                      and.l     (a3),d0
[00012622] 8280                      or.l      d0,d1
[00012624] c083                      and.l     d3,d0
[00012626] b181                      eor.l     d0,d1
[00012628] 03c9 0000                 movep.l   d1,0(a1)
[0001262c] 0349 0001                 movep.l   1(a1),d1
[00012630] 201d                      move.l    (a5)+,d0
[00012632] c0ab 0004                 and.l     4(a3),d0
[00012636] 8280                      or.l      d0,d1
[00012638] c083                      and.l     d3,d0
[0001263a] b181                      eor.l     d0,d1
[0001263c] 03c9 0001                 movep.l   d1,1(a1)
[00012640] d0c6                      adda.w    d6,a0
[00012642] d2c7                      adda.w    d7,a1
[00012644] 51cd ff5c                 dbf       d5,$000125A2
[00012648] 4e75                      rts
[0001264a] 4e75                      rts
[0001264c] 3e2e 01ee                 move.w    494(a6),d7
[00012650] 206e 01c2                 movea.l   450(a6),a0
[00012654] 226e 01d6                 movea.l   470(a6),a1
[00012658] 346e 01c6                 movea.w   454(a6),a2
[0001265c] 366e 01da                 movea.w   474(a6),a3
[00012660] 48c0                      ext.l     d0
[00012662] 48c2                      ext.l     d2
[00012664] 3c0a                      move.w    a2,d6
[00012666] c2c6                      mulu.w    d6,d1
[00012668] d280                      add.l     d0,d1
[0001266a] d1c1                      adda.l    d1,a0
[0001266c] 3c0b                      move.w    a3,d6
[0001266e] c6c6                      mulu.w    d6,d3
[00012670] d682                      add.l     d2,d3
[00012672] d3c3                      adda.l    d3,a1
[00012674] b1c9                      cmpa.l    a1,a0
[00012676] 6200 0e36                 bhi       $000134AE
[0001267a] 3c3c 8401                 move.w    #$8401,d6
[0001267e] 0f06                      btst      d7,d6
[00012680] 6600 0e2c                 bne       $000134AE
[00012684] 3c0a                      move.w    a2,d6
[00012686] ccc5                      mulu.w    d5,d6
[00012688] 2848                      movea.l   a0,a4
[0001268a] d9c6                      adda.l    d6,a4
[0001268c] d8c4                      adda.w    d4,a4
[0001268e] b9c9                      cmpa.l    a1,a4
[00012690] 6500 0e1c                 bcs       $000134AE
[00012694] 528c                      addq.l    #1,a4
[00012696] d28c                      add.l     a4,d1
[00012698] 9288                      sub.l     a0,d1
[0001269a] 2a49                      movea.l   a1,a5
[0001269c] 3c0b                      move.w    a3,d6
[0001269e] ccc5                      mulu.w    d5,d6
[000126a0] dbc6                      adda.l    d6,a5
[000126a2] dac4                      adda.w    d4,a5
[000126a4] 528d                      addq.l    #1,a5
[000126a6] d68d                      add.l     a5,d3
[000126a8] 9689                      sub.l     a1,d3
[000126aa] c14c                      exg       a0,a4
[000126ac] c34d                      exg       a1,a5
[000126ae] b87c 000f                 cmp.w     #$000F,d4
[000126b2] 6f00 00ba                 ble       $0001276E
[000126b6] 3c04                      move.w    d4,d6
[000126b8] 5246                      addq.w    #1,d6
[000126ba] 94c6                      suba.w    d6,a2
[000126bc] 96c6                      suba.w    d6,a3
[000126be] 323a 1d22                 move.w    $000143E2(pc),d1
[000126c2] 660e                      bne.s     $000126D2
[000126c4] 7201                      moveq.l   #1,d1
[000126c6] 7601                      moveq.l   #1,d3
[000126c8] c240                      and.w     d0,d1
[000126ca] c642                      and.w     d2,d3
[000126cc] b641                      cmp.w     d1,d3
[000126ce] 6600 00a6                 bne       $00012776
[000126d2] 7c03                      moveq.l   #3,d6
[000126d4] 3404                      move.w    d4,d2
[000126d6] d440                      add.w     d0,d2
[000126d8] 5340                      subq.w    #1,d0
[000126da] c046                      and.w     d6,d0
[000126dc] 7203                      moveq.l   #3,d1
[000126de] b141                      eor.w     d0,d1
[000126e0] 9841                      sub.w     d1,d4
[000126e2] d040                      add.w     d0,d0
[000126e4] 5242                      addq.w    #1,d2
[000126e6] c446                      and.w     d6,d2
[000126e8] 9842                      sub.w     d2,d4
[000126ea] bd42                      eor.w     d6,d2
[000126ec] d442                      add.w     d2,d2
[000126ee] 5244                      addq.w    #1,d4
[000126f0] e44c                      lsr.w     #2,d4
[000126f2] 5344                      subq.w    #1,d4
[000126f4] 3204                      move.w    d4,d1
[000126f6] 4641                      not.w     d1
[000126f8] c246                      and.w     d6,d1
[000126fa] d241                      add.w     d1,d1
[000126fc] e44c                      lsr.w     #2,d4
[000126fe] de47                      add.w     d7,d7
[00012700] de47                      add.w     d7,d7
[00012702] 49fb 702a                 lea.l     $0001272E(pc,d7.w),a4
[00012706] 3e1c                      move.w    (a4)+,d7
[00012708] 671e                      beq.s     $00012728
[0001270a] 5347                      subq.w    #1,d7
[0001270c] 6714                      beq.s     $00012722
[0001270e] 3e00                      move.w    d0,d7
[00012710] d040                      add.w     d0,d0
[00012712] d047                      add.w     d7,d0
[00012714] 3e01                      move.w    d1,d7
[00012716] d241                      add.w     d1,d1
[00012718] d247                      add.w     d7,d1
[0001271a] 3e02                      move.w    d2,d7
[0001271c] d442                      add.w     d2,d2
[0001271e] d447                      add.w     d7,d2
[00012720] 6006                      bra.s     $00012728
[00012722] d040                      add.w     d0,d0
[00012724] d241                      add.w     d1,d1
[00012726] d442                      add.w     d2,d2
[00012728] 3e1c                      move.w    (a4)+,d7
[0001272a] 4efb 7002                 jmp       $0001272E(pc,d7.w)
[0001272e] 0000 0eb8                 ori.b     #$B8,d0
[00012732] 0001 00b4                 ori.b     #$B4,d1
[00012736] 0002 00fe                 ori.b     #$FE,d2
[0001273a] 0000 015c                 ori.b     #$5C,d0
[0001273e] 0002 0192                 ori.b     #$92,d2
[00012742] 0000 01ee                 ori.b     #$EE,d0
[00012746] 0001 01f0                 ori.b     #$F0,d1
[0001274a] 0001 023a                 ori.b     #$3A,d1
[0001274e] 0002 0284                 ori.b     #$84,d2
[00012752] 0002 02e2                 ori.b     #$E2,d2
[00012756] 0000 117a                 ori.b     #$7A,d0
[0001275a] 0002 0340                 ori.b     #$40,d2
[0001275e] 0002 039e                 ori.b     #$9E,d2
[00012762] 0002 03fc                 ori.b     #$FC,d2
[00012766] 0002 045a                 ori.b     #$5A,d2
[0001276a] 0000 0eb4                 ori.b     #$B4,d0
[0001276e] 3c04                      move.w    d4,d6
[00012770] 5246                      addq.w    #1,d6
[00012772] 94c6                      suba.w    d6,a2
[00012774] 96c6                      suba.w    d6,a3
[00012776] 3004                      move.w    d4,d0
[00012778] ea4c                      lsr.w     #5,d4
[0001277a] 4640                      not.w     d0
[0001277c] 0240 001f                 andi.w    #$001F,d0
[00012780] d040                      add.w     d0,d0
[00012782] de47                      add.w     d7,d7
[00012784] de47                      add.w     d7,d7
[00012786] 49fb 701a                 lea.l     $000127A2(pc,d7.w),a4
[0001278a] 3e1c                      move.w    (a4)+,d7
[0001278c] 670e                      beq.s     $0001279C
[0001278e] 5347                      subq.w    #1,d7
[00012790] 6708                      beq.s     $0001279A
[00012792] 3e00                      move.w    d0,d7
[00012794] d040                      add.w     d0,d0
[00012796] d047                      add.w     d7,d0
[00012798] 6002                      bra.s     $0001279C
[0001279a] d040                      add.w     d0,d0
[0001279c] 3e1c                      move.w    (a4)+,d7
[0001279e] 4efb 7002                 jmp       $000127A2(pc,d7.w)
[000127a2] 0000 12b6                 ori.b     #$B6,d0
[000127a6] 0001 0444                 ori.b     #$44,d1
[000127aa] 0002 04da                 ori.b     #$DA,d2
[000127ae] 0000 05b0                 ori.b     #$B0,d0
[000127b2] 0002 0606                 ori.b     #$06,d2
[000127b6] 0000 017a                 ori.b     #$7A,d0
[000127ba] 0001 06dc                 ori.b     #$DC,d1
[000127be] 0001 0772                 ori.b     #$72,d1
[000127c2] 0002 0808                 ori.b     #$08,d2
[000127c6] 0002 08de                 ori.b     #$DE,d2
[000127ca] 0000 187c                 ori.b     #$7C,d0
[000127ce] 0002 09b4                 ori.b     #$B4,d2
[000127d2] 0002 0a8a                 ori.b     #$8A,d2
[000127d6] 0002 0b60                 ori.b     #$60,d2
[000127da] 0002 0c36                 ori.b     #$36,d2
[000127de] 0000 12b2                 ori.b     #$B2,d0
[000127e2] 49fb 200c                 lea.l     $000127F0(pc,d2.w),a4
[000127e6] 4bfb 1018                 lea.l     $00012800(pc,d1.w),a5
[000127ea] 4dfb 002a                 lea.l     $00012816(pc,d0.w),a6
[000127ee] 4ed4                      jmp       (a4)
[000127f0] 1020                      move.b    -(a0),d0
[000127f2] c121                      and.b     d0,-(a1)
[000127f4] 1020                      move.b    -(a0),d0
[000127f6] c121                      and.b     d0,-(a1)
[000127f8] 1020                      move.b    -(a0),d0
[000127fa] c121                      and.b     d0,-(a1)
[000127fc] 3c04                      move.w    d4,d6
[000127fe] 4ed5                      jmp       (a5)
[00012800] 2020                      move.l    -(a0),d0
[00012802] c1a1                      and.l     d0,-(a1)
[00012804] 2020                      move.l    -(a0),d0
[00012806] c1a1                      and.l     d0,-(a1)
[00012808] 2020                      move.l    -(a0),d0
[0001280a] c1a1                      and.l     d0,-(a1)
[0001280c] 2020                      move.l    -(a0),d0
[0001280e] c1a1                      and.l     d0,-(a1)
[00012810] 51ce ffee                 dbf       d6,$00012800
[00012814] 4ed6                      jmp       (a6)
[00012816] 1020                      move.b    -(a0),d0
[00012818] c121                      and.b     d0,-(a1)
[0001281a] 1020                      move.b    -(a0),d0
[0001281c] c121                      and.b     d0,-(a1)
[0001281e] 1020                      move.b    -(a0),d0
[00012820] c121                      and.b     d0,-(a1)
[00012822] 90ca                      suba.w    a2,a0
[00012824] 92cb                      suba.w    a3,a1
[00012826] 51cd ffc6                 dbf       d5,$000127EE
[0001282a] 4e75                      rts
[0001282c] 49fb 200c                 lea.l     $0001283A(pc,d2.w),a4
[00012830] 4bfb 101e                 lea.l     $00012850(pc,d1.w),a5
[00012834] 4dfb 0038                 lea.l     $0001286E(pc,d0.w),a6
[00012838] 4ed4                      jmp       (a4)
[0001283a] 1020                      move.b    -(a0),d0
[0001283c] 4611                      not.b     (a1)
[0001283e] c121                      and.b     d0,-(a1)
[00012840] 1020                      move.b    -(a0),d0
[00012842] 4611                      not.b     (a1)
[00012844] c121                      and.b     d0,-(a1)
[00012846] 1020                      move.b    -(a0),d0
[00012848] 4611                      not.b     (a1)
[0001284a] c121                      and.b     d0,-(a1)
[0001284c] 3c04                      move.w    d4,d6
[0001284e] 4ed5                      jmp       (a5)
[00012850] 2020                      move.l    -(a0),d0
[00012852] 4691                      not.l     (a1)
[00012854] c1a1                      and.l     d0,-(a1)
[00012856] 2020                      move.l    -(a0),d0
[00012858] 4691                      not.l     (a1)
[0001285a] c1a1                      and.l     d0,-(a1)
[0001285c] 2020                      move.l    -(a0),d0
[0001285e] 4691                      not.l     (a1)
[00012860] c1a1                      and.l     d0,-(a1)
[00012862] 2020                      move.l    -(a0),d0
[00012864] 4691                      not.l     (a1)
[00012866] c1a1                      and.l     d0,-(a1)
[00012868] 51ce ffe6                 dbf       d6,$00012850
[0001286c] 4ed6                      jmp       (a6)
[0001286e] 1020                      move.b    -(a0),d0
[00012870] 4611                      not.b     (a1)
[00012872] c121                      and.b     d0,-(a1)
[00012874] 1020                      move.b    -(a0),d0
[00012876] 4611                      not.b     (a1)
[00012878] c121                      and.b     d0,-(a1)
[0001287a] 1020                      move.b    -(a0),d0
[0001287c] 4611                      not.b     (a1)
[0001287e] c121                      and.b     d0,-(a1)
[00012880] 90ca                      suba.w    a2,a0
[00012882] 92cb                      suba.w    a3,a1
[00012884] 51cd ffb2                 dbf       d5,$00012838
[00012888] 4e75                      rts
[0001288a] 49fb 200c                 lea.l     $00012898(pc,d2.w),a4
[0001288e] 4bfb 1012                 lea.l     $000128A2(pc,d1.w),a5
[00012892] 4dfb 001c                 lea.l     $000128B0(pc,d0.w),a6
[00012896] 4ed4                      jmp       (a4)
[00012898] 1320                      move.b    -(a0),-(a1)
[0001289a] 1320                      move.b    -(a0),-(a1)
[0001289c] 1320                      move.b    -(a0),-(a1)
[0001289e] 3c04                      move.w    d4,d6
[000128a0] 4ed5                      jmp       (a5)
[000128a2] 2320                      move.l    -(a0),-(a1)
[000128a4] 2320                      move.l    -(a0),-(a1)
[000128a6] 2320                      move.l    -(a0),-(a1)
[000128a8] 2320                      move.l    -(a0),-(a1)
[000128aa] 51ce fff6                 dbf       d6,$000128A2
[000128ae] 4ed6                      jmp       (a6)
[000128b0] 1320                      move.b    -(a0),-(a1)
[000128b2] 1320                      move.b    -(a0),-(a1)
[000128b4] 1320                      move.b    -(a0),-(a1)
[000128b6] 90ca                      suba.w    a2,a0
[000128b8] 92cb                      suba.w    a3,a1
[000128ba] 51cd ffda                 dbf       d5,$00012896
[000128be] 4e75                      rts
[000128c0] 49fb 200c                 lea.l     $000128CE(pc,d2.w),a4
[000128c4] 4bfb 101e                 lea.l     $000128E4(pc,d1.w),a5
[000128c8] 4dfb 0038                 lea.l     $00012902(pc,d0.w),a6
[000128cc] 4ed4                      jmp       (a4)
[000128ce] 1020                      move.b    -(a0),d0
[000128d0] 4600                      not.b     d0
[000128d2] c121                      and.b     d0,-(a1)
[000128d4] 1020                      move.b    -(a0),d0
[000128d6] 4600                      not.b     d0
[000128d8] c121                      and.b     d0,-(a1)
[000128da] 1020                      move.b    -(a0),d0
[000128dc] 4600                      not.b     d0
[000128de] c121                      and.b     d0,-(a1)
[000128e0] 3c04                      move.w    d4,d6
[000128e2] 4ed5                      jmp       (a5)
[000128e4] 2020                      move.l    -(a0),d0
[000128e6] 4680                      not.l     d0
[000128e8] c1a1                      and.l     d0,-(a1)
[000128ea] 2020                      move.l    -(a0),d0
[000128ec] 4680                      not.l     d0
[000128ee] c1a1                      and.l     d0,-(a1)
[000128f0] 2020                      move.l    -(a0),d0
[000128f2] 4680                      not.l     d0
[000128f4] c1a1                      and.l     d0,-(a1)
[000128f6] 2020                      move.l    -(a0),d0
[000128f8] 4680                      not.l     d0
[000128fa] c1a1                      and.l     d0,-(a1)
[000128fc] 51ce ffe6                 dbf       d6,$000128E4
[00012900] 4ed6                      jmp       (a6)
[00012902] 1020                      move.b    -(a0),d0
[00012904] 4600                      not.b     d0
[00012906] c121                      and.b     d0,-(a1)
[00012908] 1020                      move.b    -(a0),d0
[0001290a] 4600                      not.b     d0
[0001290c] c121                      and.b     d0,-(a1)
[0001290e] 1020                      move.b    -(a0),d0
[00012910] 4600                      not.b     d0
[00012912] c121                      and.b     d0,-(a1)
[00012914] 90ca                      suba.w    a2,a0
[00012916] 92cb                      suba.w    a3,a1
[00012918] 51cd ffb2                 dbf       d5,$000128CC
[0001291c] 4e75                      rts
[0001291e] 49fb 200c                 lea.l     $0001292C(pc,d2.w),a4
[00012922] 4bfb 1018                 lea.l     $0001293C(pc,d1.w),a5
[00012926] 4dfb 002a                 lea.l     $00012952(pc,d0.w),a6
[0001292a] 4ed4                      jmp       (a4)
[0001292c] 1020                      move.b    -(a0),d0
[0001292e] b121                      eor.b     d0,-(a1)
[00012930] 1020                      move.b    -(a0),d0
[00012932] b121                      eor.b     d0,-(a1)
[00012934] 1020                      move.b    -(a0),d0
[00012936] b121                      eor.b     d0,-(a1)
[00012938] 3c04                      move.w    d4,d6
[0001293a] 4ed5                      jmp       (a5)
[0001293c] 2020                      move.l    -(a0),d0
[0001293e] b1a1                      eor.l     d0,-(a1)
[00012940] 2020                      move.l    -(a0),d0
[00012942] b1a1                      eor.l     d0,-(a1)
[00012944] 2020                      move.l    -(a0),d0
[00012946] b1a1                      eor.l     d0,-(a1)
[00012948] 2020                      move.l    -(a0),d0
[0001294a] b1a1                      eor.l     d0,-(a1)
[0001294c] 51ce ffee                 dbf       d6,$0001293C
[00012950] 4ed6                      jmp       (a6)
[00012952] 1020                      move.b    -(a0),d0
[00012954] b121                      eor.b     d0,-(a1)
[00012956] 1020                      move.b    -(a0),d0
[00012958] b121                      eor.b     d0,-(a1)
[0001295a] 1020                      move.b    -(a0),d0
[0001295c] b121                      eor.b     d0,-(a1)
[0001295e] 90ca                      suba.w    a2,a0
[00012960] 92cb                      suba.w    a3,a1
[00012962] 51cd ffc6                 dbf       d5,$0001292A
[00012966] 4e75                      rts
[00012968] 49fb 200c                 lea.l     $00012976(pc,d2.w),a4
[0001296c] 4bfb 1018                 lea.l     $00012986(pc,d1.w),a5
[00012970] 4dfb 002a                 lea.l     $0001299C(pc,d0.w),a6
[00012974] 4ed4                      jmp       (a4)
[00012976] 1020                      move.b    -(a0),d0
[00012978] 8121                      or.b      d0,-(a1)
[0001297a] 1020                      move.b    -(a0),d0
[0001297c] 8121                      or.b      d0,-(a1)
[0001297e] 1020                      move.b    -(a0),d0
[00012980] 8121                      or.b      d0,-(a1)
[00012982] 3c04                      move.w    d4,d6
[00012984] 4ed5                      jmp       (a5)
[00012986] 2020                      move.l    -(a0),d0
[00012988] 81a1                      or.l      d0,-(a1)
[0001298a] 2020                      move.l    -(a0),d0
[0001298c] 81a1                      or.l      d0,-(a1)
[0001298e] 2020                      move.l    -(a0),d0
[00012990] 81a1                      or.l      d0,-(a1)
[00012992] 2020                      move.l    -(a0),d0
[00012994] 81a1                      or.l      d0,-(a1)
[00012996] 51ce ffee                 dbf       d6,$00012986
[0001299a] 4ed6                      jmp       (a6)
[0001299c] 1020                      move.b    -(a0),d0
[0001299e] 8121                      or.b      d0,-(a1)
[000129a0] 1020                      move.b    -(a0),d0
[000129a2] 8121                      or.b      d0,-(a1)
[000129a4] 1020                      move.b    -(a0),d0
[000129a6] 8121                      or.b      d0,-(a1)
[000129a8] 90ca                      suba.w    a2,a0
[000129aa] 92cb                      suba.w    a3,a1
[000129ac] 51cd ffc6                 dbf       d5,$00012974
[000129b0] 4e75                      rts
[000129b2] 49fb 200c                 lea.l     $000129C0(pc,d2.w),a4
[000129b6] 4bfb 101e                 lea.l     $000129D6(pc,d1.w),a5
[000129ba] 4dfb 0038                 lea.l     $000129F4(pc,d0.w),a6
[000129be] 4ed4                      jmp       (a4)
[000129c0] 1020                      move.b    -(a0),d0
[000129c2] 8111                      or.b      d0,(a1)
[000129c4] 4621                      not.b     -(a1)
[000129c6] 1020                      move.b    -(a0),d0
[000129c8] 8111                      or.b      d0,(a1)
[000129ca] 4621                      not.b     -(a1)
[000129cc] 1020                      move.b    -(a0),d0
[000129ce] 8111                      or.b      d0,(a1)
[000129d0] 4621                      not.b     -(a1)
[000129d2] 3c04                      move.w    d4,d6
[000129d4] 4ed5                      jmp       (a5)
[000129d6] 2020                      move.l    -(a0),d0
[000129d8] 8191                      or.l      d0,(a1)
[000129da] 46a1                      not.l     -(a1)
[000129dc] 2020                      move.l    -(a0),d0
[000129de] 8191                      or.l      d0,(a1)
[000129e0] 46a1                      not.l     -(a1)
[000129e2] 2020                      move.l    -(a0),d0
[000129e4] 8191                      or.l      d0,(a1)
[000129e6] 46a1                      not.l     -(a1)
[000129e8] 2020                      move.l    -(a0),d0
[000129ea] 8191                      or.l      d0,(a1)
[000129ec] 46a1                      not.l     -(a1)
[000129ee] 51ce ffe6                 dbf       d6,$000129D6
[000129f2] 4ed6                      jmp       (a6)
[000129f4] 1020                      move.b    -(a0),d0
[000129f6] 8111                      or.b      d0,(a1)
[000129f8] 4621                      not.b     -(a1)
[000129fa] 1020                      move.b    -(a0),d0
[000129fc] 8111                      or.b      d0,(a1)
[000129fe] 4621                      not.b     -(a1)
[00012a00] 1020                      move.b    -(a0),d0
[00012a02] 8111                      or.b      d0,(a1)
[00012a04] 4621                      not.b     -(a1)
[00012a06] 90ca                      suba.w    a2,a0
[00012a08] 92cb                      suba.w    a3,a1
[00012a0a] 51cd ffb2                 dbf       d5,$000129BE
[00012a0e] 4e75                      rts
[00012a10] 49fb 200c                 lea.l     $00012A1E(pc,d2.w),a4
[00012a14] 4bfb 101e                 lea.l     $00012A34(pc,d1.w),a5
[00012a18] 4dfb 0038                 lea.l     $00012A52(pc,d0.w),a6
[00012a1c] 4ed4                      jmp       (a4)
[00012a1e] 1020                      move.b    -(a0),d0
[00012a20] b111                      eor.b     d0,(a1)
[00012a22] 4621                      not.b     -(a1)
[00012a24] 1020                      move.b    -(a0),d0
[00012a26] b111                      eor.b     d0,(a1)
[00012a28] 4621                      not.b     -(a1)
[00012a2a] 1020                      move.b    -(a0),d0
[00012a2c] b111                      eor.b     d0,(a1)
[00012a2e] 4621                      not.b     -(a1)
[00012a30] 3c04                      move.w    d4,d6
[00012a32] 4ed5                      jmp       (a5)
[00012a34] 2020                      move.l    -(a0),d0
[00012a36] b191                      eor.l     d0,(a1)
[00012a38] 46a1                      not.l     -(a1)
[00012a3a] 2020                      move.l    -(a0),d0
[00012a3c] b191                      eor.l     d0,(a1)
[00012a3e] 46a1                      not.l     -(a1)
[00012a40] 2020                      move.l    -(a0),d0
[00012a42] b191                      eor.l     d0,(a1)
[00012a44] 46a1                      not.l     -(a1)
[00012a46] 2020                      move.l    -(a0),d0
[00012a48] b191                      eor.l     d0,(a1)
[00012a4a] 46a1                      not.l     -(a1)
[00012a4c] 51ce ffe6                 dbf       d6,$00012A34
[00012a50] 4ed6                      jmp       (a6)
[00012a52] 1020                      move.b    -(a0),d0
[00012a54] b111                      eor.b     d0,(a1)
[00012a56] 4621                      not.b     -(a1)
[00012a58] 1020                      move.b    -(a0),d0
[00012a5a] b111                      eor.b     d0,(a1)
[00012a5c] 4621                      not.b     -(a1)
[00012a5e] 1020                      move.b    -(a0),d0
[00012a60] b111                      eor.b     d0,(a1)
[00012a62] 4621                      not.b     -(a1)
[00012a64] 90ca                      suba.w    a2,a0
[00012a66] 92cb                      suba.w    a3,a1
[00012a68] 51cd ffb2                 dbf       d5,$00012A1C
[00012a6c] 4e75                      rts
[00012a6e] 49fb 200c                 lea.l     $00012A7C(pc,d2.w),a4
[00012a72] 4bfb 101e                 lea.l     $00012A92(pc,d1.w),a5
[00012a76] 4dfb 0038                 lea.l     $00012AB0(pc,d0.w),a6
[00012a7a] 4ed4                      jmp       (a4)
[00012a7c] 4611                      not.b     (a1)
[00012a7e] 1020                      move.b    -(a0),d0
[00012a80] 8121                      or.b      d0,-(a1)
[00012a82] 4611                      not.b     (a1)
[00012a84] 1020                      move.b    -(a0),d0
[00012a86] 8121                      or.b      d0,-(a1)
[00012a88] 4611                      not.b     (a1)
[00012a8a] 1020                      move.b    -(a0),d0
[00012a8c] 8121                      or.b      d0,-(a1)
[00012a8e] 3c04                      move.w    d4,d6
[00012a90] 4ed5                      jmp       (a5)
[00012a92] 4691                      not.l     (a1)
[00012a94] 2020                      move.l    -(a0),d0
[00012a96] 81a1                      or.l      d0,-(a1)
[00012a98] 4691                      not.l     (a1)
[00012a9a] 2020                      move.l    -(a0),d0
[00012a9c] 81a1                      or.l      d0,-(a1)
[00012a9e] 4691                      not.l     (a1)
[00012aa0] 2020                      move.l    -(a0),d0
[00012aa2] 81a1                      or.l      d0,-(a1)
[00012aa4] 4691                      not.l     (a1)
[00012aa6] 2020                      move.l    -(a0),d0
[00012aa8] 81a1                      or.l      d0,-(a1)
[00012aaa] 51ce ffe6                 dbf       d6,$00012A92
[00012aae] 4ed6                      jmp       (a6)
[00012ab0] 4611                      not.b     (a1)
[00012ab2] 1020                      move.b    -(a0),d0
[00012ab4] 8121                      or.b      d0,-(a1)
[00012ab6] 4611                      not.b     (a1)
[00012ab8] 1020                      move.b    -(a0),d0
[00012aba] 8121                      or.b      d0,-(a1)
[00012abc] 4611                      not.b     (a1)
[00012abe] 1020                      move.b    -(a0),d0
[00012ac0] 8121                      or.b      d0,-(a1)
[00012ac2] 90ca                      suba.w    a2,a0
[00012ac4] 92cb                      suba.w    a3,a1
[00012ac6] 51cd ffb2                 dbf       d5,$00012A7A
[00012aca] 4e75                      rts
[00012acc] 49fb 200c                 lea.l     $00012ADA(pc,d2.w),a4
[00012ad0] 4bfb 101e                 lea.l     $00012AF0(pc,d1.w),a5
[00012ad4] 4dfb 0038                 lea.l     $00012B0E(pc,d0.w),a6
[00012ad8] 4ed4                      jmp       (a4)
[00012ada] 1020                      move.b    -(a0),d0
[00012adc] 4600                      not.b     d0
[00012ade] 1300                      move.b    d0,-(a1)
[00012ae0] 1020                      move.b    -(a0),d0
[00012ae2] 4600                      not.b     d0
[00012ae4] 1300                      move.b    d0,-(a1)
[00012ae6] 1020                      move.b    -(a0),d0
[00012ae8] 4600                      not.b     d0
[00012aea] 1300                      move.b    d0,-(a1)
[00012aec] 3c04                      move.w    d4,d6
[00012aee] 4ed5                      jmp       (a5)
[00012af0] 2020                      move.l    -(a0),d0
[00012af2] 4680                      not.l     d0
[00012af4] 2300                      move.l    d0,-(a1)
[00012af6] 2020                      move.l    -(a0),d0
[00012af8] 4680                      not.l     d0
[00012afa] 2300                      move.l    d0,-(a1)
[00012afc] 2020                      move.l    -(a0),d0
[00012afe] 4680                      not.l     d0
[00012b00] 2300                      move.l    d0,-(a1)
[00012b02] 2020                      move.l    -(a0),d0
[00012b04] 4680                      not.l     d0
[00012b06] 2300                      move.l    d0,-(a1)
[00012b08] 51ce ffe6                 dbf       d6,$00012AF0
[00012b0c] 4ed6                      jmp       (a6)
[00012b0e] 1020                      move.b    -(a0),d0
[00012b10] 4600                      not.b     d0
[00012b12] 1300                      move.b    d0,-(a1)
[00012b14] 1020                      move.b    -(a0),d0
[00012b16] 4600                      not.b     d0
[00012b18] 1300                      move.b    d0,-(a1)
[00012b1a] 1020                      move.b    -(a0),d0
[00012b1c] 4600                      not.b     d0
[00012b1e] 1300                      move.b    d0,-(a1)
[00012b20] 90ca                      suba.w    a2,a0
[00012b22] 92cb                      suba.w    a3,a1
[00012b24] 51cd ffb2                 dbf       d5,$00012AD8
[00012b28] 4e75                      rts
[00012b2a] 49fb 200c                 lea.l     $00012B38(pc,d2.w),a4
[00012b2e] 4bfb 101e                 lea.l     $00012B4E(pc,d1.w),a5
[00012b32] 4dfb 0038                 lea.l     $00012B6C(pc,d0.w),a6
[00012b36] 4ed4                      jmp       (a4)
[00012b38] 1020                      move.b    -(a0),d0
[00012b3a] 4600                      not.b     d0
[00012b3c] 8121                      or.b      d0,-(a1)
[00012b3e] 1020                      move.b    -(a0),d0
[00012b40] 4600                      not.b     d0
[00012b42] 8121                      or.b      d0,-(a1)
[00012b44] 1020                      move.b    -(a0),d0
[00012b46] 4600                      not.b     d0
[00012b48] 8121                      or.b      d0,-(a1)
[00012b4a] 3c04                      move.w    d4,d6
[00012b4c] 4ed5                      jmp       (a5)
[00012b4e] 2020                      move.l    -(a0),d0
[00012b50] 4680                      not.l     d0
[00012b52] 81a1                      or.l      d0,-(a1)
[00012b54] 2020                      move.l    -(a0),d0
[00012b56] 4680                      not.l     d0
[00012b58] 81a1                      or.l      d0,-(a1)
[00012b5a] 2020                      move.l    -(a0),d0
[00012b5c] 4680                      not.l     d0
[00012b5e] 81a1                      or.l      d0,-(a1)
[00012b60] 2020                      move.l    -(a0),d0
[00012b62] 4680                      not.l     d0
[00012b64] 81a1                      or.l      d0,-(a1)
[00012b66] 51ce ffe6                 dbf       d6,$00012B4E
[00012b6a] 4ed6                      jmp       (a6)
[00012b6c] 1020                      move.b    -(a0),d0
[00012b6e] 4600                      not.b     d0
[00012b70] 8121                      or.b      d0,-(a1)
[00012b72] 1020                      move.b    -(a0),d0
[00012b74] 4600                      not.b     d0
[00012b76] 8121                      or.b      d0,-(a1)
[00012b78] 1020                      move.b    -(a0),d0
[00012b7a] 4600                      not.b     d0
[00012b7c] 8121                      or.b      d0,-(a1)
[00012b7e] 90ca                      suba.w    a2,a0
[00012b80] 92cb                      suba.w    a3,a1
[00012b82] 51cd ffb2                 dbf       d5,$00012B36
[00012b86] 4e75                      rts
[00012b88] 49fb 200c                 lea.l     $00012B96(pc,d2.w),a4
[00012b8c] 4bfb 101e                 lea.l     $00012BAC(pc,d1.w),a5
[00012b90] 4dfb 0038                 lea.l     $00012BCA(pc,d0.w),a6
[00012b94] 4ed4                      jmp       (a4)
[00012b96] 1020                      move.b    -(a0),d0
[00012b98] c111                      and.b     d0,(a1)
[00012b9a] 4621                      not.b     -(a1)
[00012b9c] 1020                      move.b    -(a0),d0
[00012b9e] c111                      and.b     d0,(a1)
[00012ba0] 4621                      not.b     -(a1)
[00012ba2] 1020                      move.b    -(a0),d0
[00012ba4] c111                      and.b     d0,(a1)
[00012ba6] 4621                      not.b     -(a1)
[00012ba8] 3c04                      move.w    d4,d6
[00012baa] 4ed5                      jmp       (a5)
[00012bac] 2020                      move.l    -(a0),d0
[00012bae] c191                      and.l     d0,(a1)
[00012bb0] 46a1                      not.l     -(a1)
[00012bb2] 2020                      move.l    -(a0),d0
[00012bb4] c191                      and.l     d0,(a1)
[00012bb6] 46a1                      not.l     -(a1)
[00012bb8] 2020                      move.l    -(a0),d0
[00012bba] c191                      and.l     d0,(a1)
[00012bbc] 46a1                      not.l     -(a1)
[00012bbe] 2020                      move.l    -(a0),d0
[00012bc0] c191                      and.l     d0,(a1)
[00012bc2] 46a1                      not.l     -(a1)
[00012bc4] 51ce ffe6                 dbf       d6,$00012BAC
[00012bc8] 4ed6                      jmp       (a6)
[00012bca] 1020                      move.b    -(a0),d0
[00012bcc] c111                      and.b     d0,(a1)
[00012bce] 4621                      not.b     -(a1)
[00012bd0] 1020                      move.b    -(a0),d0
[00012bd2] c111                      and.b     d0,(a1)
[00012bd4] 4621                      not.b     -(a1)
[00012bd6] 1020                      move.b    -(a0),d0
[00012bd8] c111                      and.b     d0,(a1)
[00012bda] 4621                      not.b     -(a1)
[00012bdc] 90ca                      suba.w    a2,a0
[00012bde] 92cb                      suba.w    a3,a1
[00012be0] 51cd ffb2                 dbf       d5,$00012B94
[00012be4] 4e75                      rts
[00012be6] 49fb 0006                 lea.l     $00012BEE(pc,d0.w),a4
[00012bea] 3c04                      move.w    d4,d6
[00012bec] 4ed4                      jmp       (a4)
[00012bee] 1020                      move.b    -(a0),d0
[00012bf0] c121                      and.b     d0,-(a1)
[00012bf2] 1020                      move.b    -(a0),d0
[00012bf4] c121                      and.b     d0,-(a1)
[00012bf6] 1020                      move.b    -(a0),d0
[00012bf8] c121                      and.b     d0,-(a1)
[00012bfa] 1020                      move.b    -(a0),d0
[00012bfc] c121                      and.b     d0,-(a1)
[00012bfe] 1020                      move.b    -(a0),d0
[00012c00] c121                      and.b     d0,-(a1)
[00012c02] 1020                      move.b    -(a0),d0
[00012c04] c121                      and.b     d0,-(a1)
[00012c06] 1020                      move.b    -(a0),d0
[00012c08] c121                      and.b     d0,-(a1)
[00012c0a] 1020                      move.b    -(a0),d0
[00012c0c] c121                      and.b     d0,-(a1)
[00012c0e] 1020                      move.b    -(a0),d0
[00012c10] c121                      and.b     d0,-(a1)
[00012c12] 1020                      move.b    -(a0),d0
[00012c14] c121                      and.b     d0,-(a1)
[00012c16] 1020                      move.b    -(a0),d0
[00012c18] c121                      and.b     d0,-(a1)
[00012c1a] 1020                      move.b    -(a0),d0
[00012c1c] c121                      and.b     d0,-(a1)
[00012c1e] 1020                      move.b    -(a0),d0
[00012c20] c121                      and.b     d0,-(a1)
[00012c22] 1020                      move.b    -(a0),d0
[00012c24] c121                      and.b     d0,-(a1)
[00012c26] 1020                      move.b    -(a0),d0
[00012c28] c121                      and.b     d0,-(a1)
[00012c2a] 1020                      move.b    -(a0),d0
[00012c2c] c121                      and.b     d0,-(a1)
[00012c2e] 1020                      move.b    -(a0),d0
[00012c30] c121                      and.b     d0,-(a1)
[00012c32] 1020                      move.b    -(a0),d0
[00012c34] c121                      and.b     d0,-(a1)
[00012c36] 1020                      move.b    -(a0),d0
[00012c38] c121                      and.b     d0,-(a1)
[00012c3a] 1020                      move.b    -(a0),d0
[00012c3c] c121                      and.b     d0,-(a1)
[00012c3e] 1020                      move.b    -(a0),d0
[00012c40] c121                      and.b     d0,-(a1)
[00012c42] 1020                      move.b    -(a0),d0
[00012c44] c121                      and.b     d0,-(a1)
[00012c46] 1020                      move.b    -(a0),d0
[00012c48] c121                      and.b     d0,-(a1)
[00012c4a] 1020                      move.b    -(a0),d0
[00012c4c] c121                      and.b     d0,-(a1)
[00012c4e] 1020                      move.b    -(a0),d0
[00012c50] c121                      and.b     d0,-(a1)
[00012c52] 1020                      move.b    -(a0),d0
[00012c54] c121                      and.b     d0,-(a1)
[00012c56] 1020                      move.b    -(a0),d0
[00012c58] c121                      and.b     d0,-(a1)
[00012c5a] 1020                      move.b    -(a0),d0
[00012c5c] c121                      and.b     d0,-(a1)
[00012c5e] 1020                      move.b    -(a0),d0
[00012c60] c121                      and.b     d0,-(a1)
[00012c62] 1020                      move.b    -(a0),d0
[00012c64] c121                      and.b     d0,-(a1)
[00012c66] 1020                      move.b    -(a0),d0
[00012c68] c121                      and.b     d0,-(a1)
[00012c6a] 1020                      move.b    -(a0),d0
[00012c6c] c121                      and.b     d0,-(a1)
[00012c6e] 51ce ff7e                 dbf       d6,$00012BEE
[00012c72] 90ca                      suba.w    a2,a0
[00012c74] 92cb                      suba.w    a3,a1
[00012c76] 51cd ff72                 dbf       d5,$00012BEA
[00012c7a] 4e75                      rts
[00012c7c] 49fb 0006                 lea.l     $00012C84(pc,d0.w),a4
[00012c80] 3c04                      move.w    d4,d6
[00012c82] 4ed4                      jmp       (a4)
[00012c84] 1020                      move.b    -(a0),d0
[00012c86] 4611                      not.b     (a1)
[00012c88] c121                      and.b     d0,-(a1)
[00012c8a] 1020                      move.b    -(a0),d0
[00012c8c] 4611                      not.b     (a1)
[00012c8e] c121                      and.b     d0,-(a1)
[00012c90] 1020                      move.b    -(a0),d0
[00012c92] 4611                      not.b     (a1)
[00012c94] c121                      and.b     d0,-(a1)
[00012c96] 1020                      move.b    -(a0),d0
[00012c98] 4611                      not.b     (a1)
[00012c9a] c121                      and.b     d0,-(a1)
[00012c9c] 1020                      move.b    -(a0),d0
[00012c9e] 4611                      not.b     (a1)
[00012ca0] c121                      and.b     d0,-(a1)
[00012ca2] 1020                      move.b    -(a0),d0
[00012ca4] 4611                      not.b     (a1)
[00012ca6] c121                      and.b     d0,-(a1)
[00012ca8] 1020                      move.b    -(a0),d0
[00012caa] 4611                      not.b     (a1)
[00012cac] c121                      and.b     d0,-(a1)
[00012cae] 1020                      move.b    -(a0),d0
[00012cb0] 4611                      not.b     (a1)
[00012cb2] c121                      and.b     d0,-(a1)
[00012cb4] 1020                      move.b    -(a0),d0
[00012cb6] 4611                      not.b     (a1)
[00012cb8] c121                      and.b     d0,-(a1)
[00012cba] 1020                      move.b    -(a0),d0
[00012cbc] 4611                      not.b     (a1)
[00012cbe] c121                      and.b     d0,-(a1)
[00012cc0] 1020                      move.b    -(a0),d0
[00012cc2] 4611                      not.b     (a1)
[00012cc4] c121                      and.b     d0,-(a1)
[00012cc6] 1020                      move.b    -(a0),d0
[00012cc8] 4611                      not.b     (a1)
[00012cca] c121                      and.b     d0,-(a1)
[00012ccc] 1020                      move.b    -(a0),d0
[00012cce] 4611                      not.b     (a1)
[00012cd0] c121                      and.b     d0,-(a1)
[00012cd2] 1020                      move.b    -(a0),d0
[00012cd4] 4611                      not.b     (a1)
[00012cd6] c121                      and.b     d0,-(a1)
[00012cd8] 1020                      move.b    -(a0),d0
[00012cda] 4611                      not.b     (a1)
[00012cdc] c121                      and.b     d0,-(a1)
[00012cde] 1020                      move.b    -(a0),d0
[00012ce0] 4611                      not.b     (a1)
[00012ce2] c121                      and.b     d0,-(a1)
[00012ce4] 1020                      move.b    -(a0),d0
[00012ce6] 4611                      not.b     (a1)
[00012ce8] c121                      and.b     d0,-(a1)
[00012cea] 1020                      move.b    -(a0),d0
[00012cec] 4611                      not.b     (a1)
[00012cee] c121                      and.b     d0,-(a1)
[00012cf0] 1020                      move.b    -(a0),d0
[00012cf2] 4611                      not.b     (a1)
[00012cf4] c121                      and.b     d0,-(a1)
[00012cf6] 1020                      move.b    -(a0),d0
[00012cf8] 4611                      not.b     (a1)
[00012cfa] c121                      and.b     d0,-(a1)
[00012cfc] 1020                      move.b    -(a0),d0
[00012cfe] 4611                      not.b     (a1)
[00012d00] c121                      and.b     d0,-(a1)
[00012d02] 1020                      move.b    -(a0),d0
[00012d04] 4611                      not.b     (a1)
[00012d06] c121                      and.b     d0,-(a1)
[00012d08] 1020                      move.b    -(a0),d0
[00012d0a] 4611                      not.b     (a1)
[00012d0c] c121                      and.b     d0,-(a1)
[00012d0e] 1020                      move.b    -(a0),d0
[00012d10] 4611                      not.b     (a1)
[00012d12] c121                      and.b     d0,-(a1)
[00012d14] 1020                      move.b    -(a0),d0
[00012d16] 4611                      not.b     (a1)
[00012d18] c121                      and.b     d0,-(a1)
[00012d1a] 1020                      move.b    -(a0),d0
[00012d1c] 4611                      not.b     (a1)
[00012d1e] c121                      and.b     d0,-(a1)
[00012d20] 1020                      move.b    -(a0),d0
[00012d22] 4611                      not.b     (a1)
[00012d24] c121                      and.b     d0,-(a1)
[00012d26] 1020                      move.b    -(a0),d0
[00012d28] 4611                      not.b     (a1)
[00012d2a] c121                      and.b     d0,-(a1)
[00012d2c] 1020                      move.b    -(a0),d0
[00012d2e] 4611                      not.b     (a1)
[00012d30] c121                      and.b     d0,-(a1)
[00012d32] 1020                      move.b    -(a0),d0
[00012d34] 4611                      not.b     (a1)
[00012d36] c121                      and.b     d0,-(a1)
[00012d38] 1020                      move.b    -(a0),d0
[00012d3a] 4611                      not.b     (a1)
[00012d3c] c121                      and.b     d0,-(a1)
[00012d3e] 1020                      move.b    -(a0),d0
[00012d40] 4611                      not.b     (a1)
[00012d42] c121                      and.b     d0,-(a1)
[00012d44] 51ce ff3e                 dbf       d6,$00012C84
[00012d48] 90ca                      suba.w    a2,a0
[00012d4a] 92cb                      suba.w    a3,a1
[00012d4c] 51cd ff32                 dbf       d5,$00012C80
[00012d50] 4e75                      rts
[00012d52] 49fb 0006                 lea.l     $00012D5A(pc,d0.w),a4
[00012d56] 3c04                      move.w    d4,d6
[00012d58] 4ed4                      jmp       (a4)
[00012d5a] 1320                      move.b    -(a0),-(a1)
[00012d5c] 1320                      move.b    -(a0),-(a1)
[00012d5e] 1320                      move.b    -(a0),-(a1)
[00012d60] 1320                      move.b    -(a0),-(a1)
[00012d62] 1320                      move.b    -(a0),-(a1)
[00012d64] 1320                      move.b    -(a0),-(a1)
[00012d66] 1320                      move.b    -(a0),-(a1)
[00012d68] 1320                      move.b    -(a0),-(a1)
[00012d6a] 1320                      move.b    -(a0),-(a1)
[00012d6c] 1320                      move.b    -(a0),-(a1)
[00012d6e] 1320                      move.b    -(a0),-(a1)
[00012d70] 1320                      move.b    -(a0),-(a1)
[00012d72] 1320                      move.b    -(a0),-(a1)
[00012d74] 1320                      move.b    -(a0),-(a1)
[00012d76] 1320                      move.b    -(a0),-(a1)
[00012d78] 1320                      move.b    -(a0),-(a1)
[00012d7a] 1320                      move.b    -(a0),-(a1)
[00012d7c] 1320                      move.b    -(a0),-(a1)
[00012d7e] 1320                      move.b    -(a0),-(a1)
[00012d80] 1320                      move.b    -(a0),-(a1)
[00012d82] 1320                      move.b    -(a0),-(a1)
[00012d84] 1320                      move.b    -(a0),-(a1)
[00012d86] 1320                      move.b    -(a0),-(a1)
[00012d88] 1320                      move.b    -(a0),-(a1)
[00012d8a] 1320                      move.b    -(a0),-(a1)
[00012d8c] 1320                      move.b    -(a0),-(a1)
[00012d8e] 1320                      move.b    -(a0),-(a1)
[00012d90] 1320                      move.b    -(a0),-(a1)
[00012d92] 1320                      move.b    -(a0),-(a1)
[00012d94] 1320                      move.b    -(a0),-(a1)
[00012d96] 1320                      move.b    -(a0),-(a1)
[00012d98] 1320                      move.b    -(a0),-(a1)
[00012d9a] 51ce ffbe                 dbf       d6,$00012D5A
[00012d9e] 90ca                      suba.w    a2,a0
[00012da0] 92cb                      suba.w    a3,a1
[00012da2] 51cd ffb2                 dbf       d5,$00012D56
[00012da6] 4e75                      rts
[00012da8] 49fb 0006                 lea.l     $00012DB0(pc,d0.w),a4
[00012dac] 3c04                      move.w    d4,d6
[00012dae] 4ed4                      jmp       (a4)
[00012db0] 1020                      move.b    -(a0),d0
[00012db2] 4600                      not.b     d0
[00012db4] c121                      and.b     d0,-(a1)
[00012db6] 1020                      move.b    -(a0),d0
[00012db8] 4600                      not.b     d0
[00012dba] c121                      and.b     d0,-(a1)
[00012dbc] 1020                      move.b    -(a0),d0
[00012dbe] 4600                      not.b     d0
[00012dc0] c121                      and.b     d0,-(a1)
[00012dc2] 1020                      move.b    -(a0),d0
[00012dc4] 4600                      not.b     d0
[00012dc6] c121                      and.b     d0,-(a1)
[00012dc8] 1020                      move.b    -(a0),d0
[00012dca] 4600                      not.b     d0
[00012dcc] c121                      and.b     d0,-(a1)
[00012dce] 1020                      move.b    -(a0),d0
[00012dd0] 4600                      not.b     d0
[00012dd2] c121                      and.b     d0,-(a1)
[00012dd4] 1020                      move.b    -(a0),d0
[00012dd6] 4600                      not.b     d0
[00012dd8] c121                      and.b     d0,-(a1)
[00012dda] 1020                      move.b    -(a0),d0
[00012ddc] 4600                      not.b     d0
[00012dde] c121                      and.b     d0,-(a1)
[00012de0] 1020                      move.b    -(a0),d0
[00012de2] 4600                      not.b     d0
[00012de4] c121                      and.b     d0,-(a1)
[00012de6] 1020                      move.b    -(a0),d0
[00012de8] 4600                      not.b     d0
[00012dea] c121                      and.b     d0,-(a1)
[00012dec] 1020                      move.b    -(a0),d0
[00012dee] 4600                      not.b     d0
[00012df0] c121                      and.b     d0,-(a1)
[00012df2] 1020                      move.b    -(a0),d0
[00012df4] 4600                      not.b     d0
[00012df6] c121                      and.b     d0,-(a1)
[00012df8] 1020                      move.b    -(a0),d0
[00012dfa] 4600                      not.b     d0
[00012dfc] c121                      and.b     d0,-(a1)
[00012dfe] 1020                      move.b    -(a0),d0
[00012e00] 4600                      not.b     d0
[00012e02] c121                      and.b     d0,-(a1)
[00012e04] 1020                      move.b    -(a0),d0
[00012e06] 4600                      not.b     d0
[00012e08] c121                      and.b     d0,-(a1)
[00012e0a] 1020                      move.b    -(a0),d0
[00012e0c] 4600                      not.b     d0
[00012e0e] c121                      and.b     d0,-(a1)
[00012e10] 1020                      move.b    -(a0),d0
[00012e12] 4600                      not.b     d0
[00012e14] c121                      and.b     d0,-(a1)
[00012e16] 1020                      move.b    -(a0),d0
[00012e18] 4600                      not.b     d0
[00012e1a] c121                      and.b     d0,-(a1)
[00012e1c] 1020                      move.b    -(a0),d0
[00012e1e] 4600                      not.b     d0
[00012e20] c121                      and.b     d0,-(a1)
[00012e22] 1020                      move.b    -(a0),d0
[00012e24] 4600                      not.b     d0
[00012e26] c121                      and.b     d0,-(a1)
[00012e28] 1020                      move.b    -(a0),d0
[00012e2a] 4600                      not.b     d0
[00012e2c] c121                      and.b     d0,-(a1)
[00012e2e] 1020                      move.b    -(a0),d0
[00012e30] 4600                      not.b     d0
[00012e32] c121                      and.b     d0,-(a1)
[00012e34] 1020                      move.b    -(a0),d0
[00012e36] 4600                      not.b     d0
[00012e38] c121                      and.b     d0,-(a1)
[00012e3a] 1020                      move.b    -(a0),d0
[00012e3c] 4600                      not.b     d0
[00012e3e] c121                      and.b     d0,-(a1)
[00012e40] 1020                      move.b    -(a0),d0
[00012e42] 4600                      not.b     d0
[00012e44] c121                      and.b     d0,-(a1)
[00012e46] 1020                      move.b    -(a0),d0
[00012e48] 4600                      not.b     d0
[00012e4a] c121                      and.b     d0,-(a1)
[00012e4c] 1020                      move.b    -(a0),d0
[00012e4e] 4600                      not.b     d0
[00012e50] c121                      and.b     d0,-(a1)
[00012e52] 1020                      move.b    -(a0),d0
[00012e54] 4600                      not.b     d0
[00012e56] c121                      and.b     d0,-(a1)
[00012e58] 1020                      move.b    -(a0),d0
[00012e5a] 4600                      not.b     d0
[00012e5c] c121                      and.b     d0,-(a1)
[00012e5e] 1020                      move.b    -(a0),d0
[00012e60] 4600                      not.b     d0
[00012e62] c121                      and.b     d0,-(a1)
[00012e64] 1020                      move.b    -(a0),d0
[00012e66] 4600                      not.b     d0
[00012e68] c121                      and.b     d0,-(a1)
[00012e6a] 1020                      move.b    -(a0),d0
[00012e6c] 4600                      not.b     d0
[00012e6e] c121                      and.b     d0,-(a1)
[00012e70] 51ce ff3e                 dbf       d6,$00012DB0
[00012e74] 90ca                      suba.w    a2,a0
[00012e76] 92cb                      suba.w    a3,a1
[00012e78] 51cd ff32                 dbf       d5,$00012DAC
[00012e7c] 4e75                      rts
[00012e7e] 49fb 0006                 lea.l     $00012E86(pc,d0.w),a4
[00012e82] 3c04                      move.w    d4,d6
[00012e84] 4ed4                      jmp       (a4)
[00012e86] 1020                      move.b    -(a0),d0
[00012e88] b121                      eor.b     d0,-(a1)
[00012e8a] 1020                      move.b    -(a0),d0
[00012e8c] b121                      eor.b     d0,-(a1)
[00012e8e] 1020                      move.b    -(a0),d0
[00012e90] b121                      eor.b     d0,-(a1)
[00012e92] 1020                      move.b    -(a0),d0
[00012e94] b121                      eor.b     d0,-(a1)
[00012e96] 1020                      move.b    -(a0),d0
[00012e98] b121                      eor.b     d0,-(a1)
[00012e9a] 1020                      move.b    -(a0),d0
[00012e9c] b121                      eor.b     d0,-(a1)
[00012e9e] 1020                      move.b    -(a0),d0
[00012ea0] b121                      eor.b     d0,-(a1)
[00012ea2] 1020                      move.b    -(a0),d0
[00012ea4] b121                      eor.b     d0,-(a1)
[00012ea6] 1020                      move.b    -(a0),d0
[00012ea8] b121                      eor.b     d0,-(a1)
[00012eaa] 1020                      move.b    -(a0),d0
[00012eac] b121                      eor.b     d0,-(a1)
[00012eae] 1020                      move.b    -(a0),d0
[00012eb0] b121                      eor.b     d0,-(a1)
[00012eb2] 1020                      move.b    -(a0),d0
[00012eb4] b121                      eor.b     d0,-(a1)
[00012eb6] 1020                      move.b    -(a0),d0
[00012eb8] b121                      eor.b     d0,-(a1)
[00012eba] 1020                      move.b    -(a0),d0
[00012ebc] b121                      eor.b     d0,-(a1)
[00012ebe] 1020                      move.b    -(a0),d0
[00012ec0] b121                      eor.b     d0,-(a1)
[00012ec2] 1020                      move.b    -(a0),d0
[00012ec4] b121                      eor.b     d0,-(a1)
[00012ec6] 1020                      move.b    -(a0),d0
[00012ec8] b121                      eor.b     d0,-(a1)
[00012eca] 1020                      move.b    -(a0),d0
[00012ecc] b121                      eor.b     d0,-(a1)
[00012ece] 1020                      move.b    -(a0),d0
[00012ed0] b121                      eor.b     d0,-(a1)
[00012ed2] 1020                      move.b    -(a0),d0
[00012ed4] b121                      eor.b     d0,-(a1)
[00012ed6] 1020                      move.b    -(a0),d0
[00012ed8] b121                      eor.b     d0,-(a1)
[00012eda] 1020                      move.b    -(a0),d0
[00012edc] b121                      eor.b     d0,-(a1)
[00012ede] 1020                      move.b    -(a0),d0
[00012ee0] b121                      eor.b     d0,-(a1)
[00012ee2] 1020                      move.b    -(a0),d0
[00012ee4] b121                      eor.b     d0,-(a1)
[00012ee6] 1020                      move.b    -(a0),d0
[00012ee8] b121                      eor.b     d0,-(a1)
[00012eea] 1020                      move.b    -(a0),d0
[00012eec] b121                      eor.b     d0,-(a1)
[00012eee] 1020                      move.b    -(a0),d0
[00012ef0] b121                      eor.b     d0,-(a1)
[00012ef2] 1020                      move.b    -(a0),d0
[00012ef4] b121                      eor.b     d0,-(a1)
[00012ef6] 1020                      move.b    -(a0),d0
[00012ef8] b121                      eor.b     d0,-(a1)
[00012efa] 1020                      move.b    -(a0),d0
[00012efc] b121                      eor.b     d0,-(a1)
[00012efe] 1020                      move.b    -(a0),d0
[00012f00] b121                      eor.b     d0,-(a1)
[00012f02] 1020                      move.b    -(a0),d0
[00012f04] b121                      eor.b     d0,-(a1)
[00012f06] 51ce ff7e                 dbf       d6,$00012E86
[00012f0a] 90ca                      suba.w    a2,a0
[00012f0c] 92cb                      suba.w    a3,a1
[00012f0e] 51cd ff72                 dbf       d5,$00012E82
[00012f12] 4e75                      rts
[00012f14] 49fb 0006                 lea.l     $00012F1C(pc,d0.w),a4
[00012f18] 3c04                      move.w    d4,d6
[00012f1a] 4ed4                      jmp       (a4)
[00012f1c] 1020                      move.b    -(a0),d0
[00012f1e] 8121                      or.b      d0,-(a1)
[00012f20] 1020                      move.b    -(a0),d0
[00012f22] 8121                      or.b      d0,-(a1)
[00012f24] 1020                      move.b    -(a0),d0
[00012f26] 8121                      or.b      d0,-(a1)
[00012f28] 1020                      move.b    -(a0),d0
[00012f2a] 8121                      or.b      d0,-(a1)
[00012f2c] 1020                      move.b    -(a0),d0
[00012f2e] 8121                      or.b      d0,-(a1)
[00012f30] 1020                      move.b    -(a0),d0
[00012f32] 8121                      or.b      d0,-(a1)
[00012f34] 1020                      move.b    -(a0),d0
[00012f36] 8121                      or.b      d0,-(a1)
[00012f38] 1020                      move.b    -(a0),d0
[00012f3a] 8121                      or.b      d0,-(a1)
[00012f3c] 1020                      move.b    -(a0),d0
[00012f3e] 8121                      or.b      d0,-(a1)
[00012f40] 1020                      move.b    -(a0),d0
[00012f42] 8121                      or.b      d0,-(a1)
[00012f44] 1020                      move.b    -(a0),d0
[00012f46] 8121                      or.b      d0,-(a1)
[00012f48] 1020                      move.b    -(a0),d0
[00012f4a] 8121                      or.b      d0,-(a1)
[00012f4c] 1020                      move.b    -(a0),d0
[00012f4e] 8121                      or.b      d0,-(a1)
[00012f50] 1020                      move.b    -(a0),d0
[00012f52] 8121                      or.b      d0,-(a1)
[00012f54] 1020                      move.b    -(a0),d0
[00012f56] 8121                      or.b      d0,-(a1)
[00012f58] 1020                      move.b    -(a0),d0
[00012f5a] 8121                      or.b      d0,-(a1)
[00012f5c] 1020                      move.b    -(a0),d0
[00012f5e] 8121                      or.b      d0,-(a1)
[00012f60] 1020                      move.b    -(a0),d0
[00012f62] 8121                      or.b      d0,-(a1)
[00012f64] 1020                      move.b    -(a0),d0
[00012f66] 8121                      or.b      d0,-(a1)
[00012f68] 1020                      move.b    -(a0),d0
[00012f6a] 8121                      or.b      d0,-(a1)
[00012f6c] 1020                      move.b    -(a0),d0
[00012f6e] 8121                      or.b      d0,-(a1)
[00012f70] 1020                      move.b    -(a0),d0
[00012f72] 8121                      or.b      d0,-(a1)
[00012f74] 1020                      move.b    -(a0),d0
[00012f76] 8121                      or.b      d0,-(a1)
[00012f78] 1020                      move.b    -(a0),d0
[00012f7a] 8121                      or.b      d0,-(a1)
[00012f7c] 1020                      move.b    -(a0),d0
[00012f7e] 8121                      or.b      d0,-(a1)
[00012f80] 1020                      move.b    -(a0),d0
[00012f82] 8121                      or.b      d0,-(a1)
[00012f84] 1020                      move.b    -(a0),d0
[00012f86] 8121                      or.b      d0,-(a1)
[00012f88] 1020                      move.b    -(a0),d0
[00012f8a] 8121                      or.b      d0,-(a1)
[00012f8c] 1020                      move.b    -(a0),d0
[00012f8e] 8121                      or.b      d0,-(a1)
[00012f90] 1020                      move.b    -(a0),d0
[00012f92] 8121                      or.b      d0,-(a1)
[00012f94] 1020                      move.b    -(a0),d0
[00012f96] 8121                      or.b      d0,-(a1)
[00012f98] 1020                      move.b    -(a0),d0
[00012f9a] 8121                      or.b      d0,-(a1)
[00012f9c] 51ce ff7e                 dbf       d6,$00012F1C
[00012fa0] 90ca                      suba.w    a2,a0
[00012fa2] 92cb                      suba.w    a3,a1
[00012fa4] 51cd ff72                 dbf       d5,$00012F18
[00012fa8] 4e75                      rts
[00012faa] 49fb 0006                 lea.l     $00012FB2(pc,d0.w),a4
[00012fae] 3c04                      move.w    d4,d6
[00012fb0] 4ed4                      jmp       (a4)
[00012fb2] 1020                      move.b    -(a0),d0
[00012fb4] 8111                      or.b      d0,(a1)
[00012fb6] 4621                      not.b     -(a1)
[00012fb8] 1020                      move.b    -(a0),d0
[00012fba] 8111                      or.b      d0,(a1)
[00012fbc] 4621                      not.b     -(a1)
[00012fbe] 1020                      move.b    -(a0),d0
[00012fc0] 8111                      or.b      d0,(a1)
[00012fc2] 4621                      not.b     -(a1)
[00012fc4] 1020                      move.b    -(a0),d0
[00012fc6] 8111                      or.b      d0,(a1)
[00012fc8] 4621                      not.b     -(a1)
[00012fca] 1020                      move.b    -(a0),d0
[00012fcc] 8111                      or.b      d0,(a1)
[00012fce] 4621                      not.b     -(a1)
[00012fd0] 1020                      move.b    -(a0),d0
[00012fd2] 8111                      or.b      d0,(a1)
[00012fd4] 4621                      not.b     -(a1)
[00012fd6] 1020                      move.b    -(a0),d0
[00012fd8] 8111                      or.b      d0,(a1)
[00012fda] 4621                      not.b     -(a1)
[00012fdc] 1020                      move.b    -(a0),d0
[00012fde] 8111                      or.b      d0,(a1)
[00012fe0] 4621                      not.b     -(a1)
[00012fe2] 1020                      move.b    -(a0),d0
[00012fe4] 8111                      or.b      d0,(a1)
[00012fe6] 4621                      not.b     -(a1)
[00012fe8] 1020                      move.b    -(a0),d0
[00012fea] 8111                      or.b      d0,(a1)
[00012fec] 4621                      not.b     -(a1)
[00012fee] 1020                      move.b    -(a0),d0
[00012ff0] 8111                      or.b      d0,(a1)
[00012ff2] 4621                      not.b     -(a1)
[00012ff4] 1020                      move.b    -(a0),d0
[00012ff6] 8111                      or.b      d0,(a1)
[00012ff8] 4621                      not.b     -(a1)
[00012ffa] 1020                      move.b    -(a0),d0
[00012ffc] 8111                      or.b      d0,(a1)
[00012ffe] 4621                      not.b     -(a1)
[00013000] 1020                      move.b    -(a0),d0
[00013002] 8111                      or.b      d0,(a1)
[00013004] 4621                      not.b     -(a1)
[00013006] 1020                      move.b    -(a0),d0
[00013008] 8111                      or.b      d0,(a1)
[0001300a] 4621                      not.b     -(a1)
[0001300c] 1020                      move.b    -(a0),d0
[0001300e] 8111                      or.b      d0,(a1)
[00013010] 4621                      not.b     -(a1)
[00013012] 1020                      move.b    -(a0),d0
[00013014] 8111                      or.b      d0,(a1)
[00013016] 4621                      not.b     -(a1)
[00013018] 1020                      move.b    -(a0),d0
[0001301a] 8111                      or.b      d0,(a1)
[0001301c] 4621                      not.b     -(a1)
[0001301e] 1020                      move.b    -(a0),d0
[00013020] 8111                      or.b      d0,(a1)
[00013022] 4621                      not.b     -(a1)
[00013024] 1020                      move.b    -(a0),d0
[00013026] 8111                      or.b      d0,(a1)
[00013028] 4621                      not.b     -(a1)
[0001302a] 1020                      move.b    -(a0),d0
[0001302c] 8111                      or.b      d0,(a1)
[0001302e] 4621                      not.b     -(a1)
[00013030] 1020                      move.b    -(a0),d0
[00013032] 8111                      or.b      d0,(a1)
[00013034] 4621                      not.b     -(a1)
[00013036] 1020                      move.b    -(a0),d0
[00013038] 8111                      or.b      d0,(a1)
[0001303a] 4621                      not.b     -(a1)
[0001303c] 1020                      move.b    -(a0),d0
[0001303e] 8111                      or.b      d0,(a1)
[00013040] 4621                      not.b     -(a1)
[00013042] 1020                      move.b    -(a0),d0
[00013044] 8111                      or.b      d0,(a1)
[00013046] 4621                      not.b     -(a1)
[00013048] 1020                      move.b    -(a0),d0
[0001304a] 8111                      or.b      d0,(a1)
[0001304c] 4621                      not.b     -(a1)
[0001304e] 1020                      move.b    -(a0),d0
[00013050] 8111                      or.b      d0,(a1)
[00013052] 4621                      not.b     -(a1)
[00013054] 1020                      move.b    -(a0),d0
[00013056] 8111                      or.b      d0,(a1)
[00013058] 4621                      not.b     -(a1)
[0001305a] 1020                      move.b    -(a0),d0
[0001305c] 8111                      or.b      d0,(a1)
[0001305e] 4621                      not.b     -(a1)
[00013060] 1020                      move.b    -(a0),d0
[00013062] 8111                      or.b      d0,(a1)
[00013064] 4621                      not.b     -(a1)
[00013066] 1020                      move.b    -(a0),d0
[00013068] 8111                      or.b      d0,(a1)
[0001306a] 4621                      not.b     -(a1)
[0001306c] 1020                      move.b    -(a0),d0
[0001306e] 8111                      or.b      d0,(a1)
[00013070] 4621                      not.b     -(a1)
[00013072] 51ce ff3e                 dbf       d6,$00012FB2
[00013076] 90ca                      suba.w    a2,a0
[00013078] 92cb                      suba.w    a3,a1
[0001307a] 51cd ff32                 dbf       d5,$00012FAE
[0001307e] 4e75                      rts
[00013080] 49fb 0006                 lea.l     $00013088(pc,d0.w),a4
[00013084] 3c04                      move.w    d4,d6
[00013086] 4ed4                      jmp       (a4)
[00013088] 1020                      move.b    -(a0),d0
[0001308a] b111                      eor.b     d0,(a1)
[0001308c] 4621                      not.b     -(a1)
[0001308e] 1020                      move.b    -(a0),d0
[00013090] b111                      eor.b     d0,(a1)
[00013092] 4621                      not.b     -(a1)
[00013094] 1020                      move.b    -(a0),d0
[00013096] b111                      eor.b     d0,(a1)
[00013098] 4621                      not.b     -(a1)
[0001309a] 1020                      move.b    -(a0),d0
[0001309c] b111                      eor.b     d0,(a1)
[0001309e] 4621                      not.b     -(a1)
[000130a0] 1020                      move.b    -(a0),d0
[000130a2] b111                      eor.b     d0,(a1)
[000130a4] 4621                      not.b     -(a1)
[000130a6] 1020                      move.b    -(a0),d0
[000130a8] b111                      eor.b     d0,(a1)
[000130aa] 4621                      not.b     -(a1)
[000130ac] 1020                      move.b    -(a0),d0
[000130ae] b111                      eor.b     d0,(a1)
[000130b0] 4621                      not.b     -(a1)
[000130b2] 1020                      move.b    -(a0),d0
[000130b4] b111                      eor.b     d0,(a1)
[000130b6] 4621                      not.b     -(a1)
[000130b8] 1020                      move.b    -(a0),d0
[000130ba] b111                      eor.b     d0,(a1)
[000130bc] 4621                      not.b     -(a1)
[000130be] 1020                      move.b    -(a0),d0
[000130c0] b111                      eor.b     d0,(a1)
[000130c2] 4621                      not.b     -(a1)
[000130c4] 1020                      move.b    -(a0),d0
[000130c6] b111                      eor.b     d0,(a1)
[000130c8] 4621                      not.b     -(a1)
[000130ca] 1020                      move.b    -(a0),d0
[000130cc] b111                      eor.b     d0,(a1)
[000130ce] 4621                      not.b     -(a1)
[000130d0] 1020                      move.b    -(a0),d0
[000130d2] b111                      eor.b     d0,(a1)
[000130d4] 4621                      not.b     -(a1)
[000130d6] 1020                      move.b    -(a0),d0
[000130d8] b111                      eor.b     d0,(a1)
[000130da] 4621                      not.b     -(a1)
[000130dc] 1020                      move.b    -(a0),d0
[000130de] b111                      eor.b     d0,(a1)
[000130e0] 4621                      not.b     -(a1)
[000130e2] 1020                      move.b    -(a0),d0
[000130e4] b111                      eor.b     d0,(a1)
[000130e6] 4621                      not.b     -(a1)
[000130e8] 1020                      move.b    -(a0),d0
[000130ea] b111                      eor.b     d0,(a1)
[000130ec] 4621                      not.b     -(a1)
[000130ee] 1020                      move.b    -(a0),d0
[000130f0] b111                      eor.b     d0,(a1)
[000130f2] 4621                      not.b     -(a1)
[000130f4] 1020                      move.b    -(a0),d0
[000130f6] b111                      eor.b     d0,(a1)
[000130f8] 4621                      not.b     -(a1)
[000130fa] 1020                      move.b    -(a0),d0
[000130fc] b111                      eor.b     d0,(a1)
[000130fe] 4621                      not.b     -(a1)
[00013100] 1020                      move.b    -(a0),d0
[00013102] b111                      eor.b     d0,(a1)
[00013104] 4621                      not.b     -(a1)
[00013106] 1020                      move.b    -(a0),d0
[00013108] b111                      eor.b     d0,(a1)
[0001310a] 4621                      not.b     -(a1)
[0001310c] 1020                      move.b    -(a0),d0
[0001310e] b111                      eor.b     d0,(a1)
[00013110] 4621                      not.b     -(a1)
[00013112] 1020                      move.b    -(a0),d0
[00013114] b111                      eor.b     d0,(a1)
[00013116] 4621                      not.b     -(a1)
[00013118] 1020                      move.b    -(a0),d0
[0001311a] b111                      eor.b     d0,(a1)
[0001311c] 4621                      not.b     -(a1)
[0001311e] 1020                      move.b    -(a0),d0
[00013120] b111                      eor.b     d0,(a1)
[00013122] 4621                      not.b     -(a1)
[00013124] 1020                      move.b    -(a0),d0
[00013126] b111                      eor.b     d0,(a1)
[00013128] 4621                      not.b     -(a1)
[0001312a] 1020                      move.b    -(a0),d0
[0001312c] b111                      eor.b     d0,(a1)
[0001312e] 4621                      not.b     -(a1)
[00013130] 1020                      move.b    -(a0),d0
[00013132] b111                      eor.b     d0,(a1)
[00013134] 4621                      not.b     -(a1)
[00013136] 1020                      move.b    -(a0),d0
[00013138] b111                      eor.b     d0,(a1)
[0001313a] 4621                      not.b     -(a1)
[0001313c] 1020                      move.b    -(a0),d0
[0001313e] b111                      eor.b     d0,(a1)
[00013140] 4621                      not.b     -(a1)
[00013142] 1020                      move.b    -(a0),d0
[00013144] b111                      eor.b     d0,(a1)
[00013146] 4621                      not.b     -(a1)
[00013148] 51ce ff3e                 dbf       d6,$00013088
[0001314c] 90ca                      suba.w    a2,a0
[0001314e] 92cb                      suba.w    a3,a1
[00013150] 51cd ff32                 dbf       d5,$00013084
[00013154] 4e75                      rts
[00013156] 49fb 0006                 lea.l     $0001315E(pc,d0.w),a4
[0001315a] 3c04                      move.w    d4,d6
[0001315c] 4ed4                      jmp       (a4)
[0001315e] 4611                      not.b     (a1)
[00013160] 1020                      move.b    -(a0),d0
[00013162] 8121                      or.b      d0,-(a1)
[00013164] 4611                      not.b     (a1)
[00013166] 1020                      move.b    -(a0),d0
[00013168] 8121                      or.b      d0,-(a1)
[0001316a] 4611                      not.b     (a1)
[0001316c] 1020                      move.b    -(a0),d0
[0001316e] 8121                      or.b      d0,-(a1)
[00013170] 4611                      not.b     (a1)
[00013172] 1020                      move.b    -(a0),d0
[00013174] 8121                      or.b      d0,-(a1)
[00013176] 4611                      not.b     (a1)
[00013178] 1020                      move.b    -(a0),d0
[0001317a] 8121                      or.b      d0,-(a1)
[0001317c] 4611                      not.b     (a1)
[0001317e] 1020                      move.b    -(a0),d0
[00013180] 8121                      or.b      d0,-(a1)
[00013182] 4611                      not.b     (a1)
[00013184] 1020                      move.b    -(a0),d0
[00013186] 8121                      or.b      d0,-(a1)
[00013188] 4611                      not.b     (a1)
[0001318a] 1020                      move.b    -(a0),d0
[0001318c] 8121                      or.b      d0,-(a1)
[0001318e] 4611                      not.b     (a1)
[00013190] 1020                      move.b    -(a0),d0
[00013192] 8121                      or.b      d0,-(a1)
[00013194] 4611                      not.b     (a1)
[00013196] 1020                      move.b    -(a0),d0
[00013198] 8121                      or.b      d0,-(a1)
[0001319a] 4611                      not.b     (a1)
[0001319c] 1020                      move.b    -(a0),d0
[0001319e] 8121                      or.b      d0,-(a1)
[000131a0] 4611                      not.b     (a1)
[000131a2] 1020                      move.b    -(a0),d0
[000131a4] 8121                      or.b      d0,-(a1)
[000131a6] 4611                      not.b     (a1)
[000131a8] 1020                      move.b    -(a0),d0
[000131aa] 8121                      or.b      d0,-(a1)
[000131ac] 4611                      not.b     (a1)
[000131ae] 1020                      move.b    -(a0),d0
[000131b0] 8121                      or.b      d0,-(a1)
[000131b2] 4611                      not.b     (a1)
[000131b4] 1020                      move.b    -(a0),d0
[000131b6] 8121                      or.b      d0,-(a1)
[000131b8] 4611                      not.b     (a1)
[000131ba] 1020                      move.b    -(a0),d0
[000131bc] 8121                      or.b      d0,-(a1)
[000131be] 4611                      not.b     (a1)
[000131c0] 1020                      move.b    -(a0),d0
[000131c2] 8121                      or.b      d0,-(a1)
[000131c4] 4611                      not.b     (a1)
[000131c6] 1020                      move.b    -(a0),d0
[000131c8] 8121                      or.b      d0,-(a1)
[000131ca] 4611                      not.b     (a1)
[000131cc] 1020                      move.b    -(a0),d0
[000131ce] 8121                      or.b      d0,-(a1)
[000131d0] 4611                      not.b     (a1)
[000131d2] 1020                      move.b    -(a0),d0
[000131d4] 8121                      or.b      d0,-(a1)
[000131d6] 4611                      not.b     (a1)
[000131d8] 1020                      move.b    -(a0),d0
[000131da] 8121                      or.b      d0,-(a1)
[000131dc] 4611                      not.b     (a1)
[000131de] 1020                      move.b    -(a0),d0
[000131e0] 8121                      or.b      d0,-(a1)
[000131e2] 4611                      not.b     (a1)
[000131e4] 1020                      move.b    -(a0),d0
[000131e6] 8121                      or.b      d0,-(a1)
[000131e8] 4611                      not.b     (a1)
[000131ea] 1020                      move.b    -(a0),d0
[000131ec] 8121                      or.b      d0,-(a1)
[000131ee] 4611                      not.b     (a1)
[000131f0] 1020                      move.b    -(a0),d0
[000131f2] 8121                      or.b      d0,-(a1)
[000131f4] 4611                      not.b     (a1)
[000131f6] 1020                      move.b    -(a0),d0
[000131f8] 8121                      or.b      d0,-(a1)
[000131fa] 4611                      not.b     (a1)
[000131fc] 1020                      move.b    -(a0),d0
[000131fe] 8121                      or.b      d0,-(a1)
[00013200] 4611                      not.b     (a1)
[00013202] 1020                      move.b    -(a0),d0
[00013204] 8121                      or.b      d0,-(a1)
[00013206] 4611                      not.b     (a1)
[00013208] 1020                      move.b    -(a0),d0
[0001320a] 8121                      or.b      d0,-(a1)
[0001320c] 4611                      not.b     (a1)
[0001320e] 1020                      move.b    -(a0),d0
[00013210] 8121                      or.b      d0,-(a1)
[00013212] 4611                      not.b     (a1)
[00013214] 1020                      move.b    -(a0),d0
[00013216] 8121                      or.b      d0,-(a1)
[00013218] 4611                      not.b     (a1)
[0001321a] 1020                      move.b    -(a0),d0
[0001321c] 8121                      or.b      d0,-(a1)
[0001321e] 51ce ff3e                 dbf       d6,$0001315E
[00013222] 90ca                      suba.w    a2,a0
[00013224] 92cb                      suba.w    a3,a1
[00013226] 51cd ff32                 dbf       d5,$0001315A
[0001322a] 4e75                      rts
[0001322c] 49fb 0006                 lea.l     $00013234(pc,d0.w),a4
[00013230] 3c04                      move.w    d4,d6
[00013232] 4ed4                      jmp       (a4)
[00013234] 1020                      move.b    -(a0),d0
[00013236] 4600                      not.b     d0
[00013238] 1300                      move.b    d0,-(a1)
[0001323a] 1020                      move.b    -(a0),d0
[0001323c] 4600                      not.b     d0
[0001323e] 1300                      move.b    d0,-(a1)
[00013240] 1020                      move.b    -(a0),d0
[00013242] 4600                      not.b     d0
[00013244] 1300                      move.b    d0,-(a1)
[00013246] 1020                      move.b    -(a0),d0
[00013248] 4600                      not.b     d0
[0001324a] 1300                      move.b    d0,-(a1)
[0001324c] 1020                      move.b    -(a0),d0
[0001324e] 4600                      not.b     d0
[00013250] 1300                      move.b    d0,-(a1)
[00013252] 1020                      move.b    -(a0),d0
[00013254] 4600                      not.b     d0
[00013256] 1300                      move.b    d0,-(a1)
[00013258] 1020                      move.b    -(a0),d0
[0001325a] 4600                      not.b     d0
[0001325c] 1300                      move.b    d0,-(a1)
[0001325e] 1020                      move.b    -(a0),d0
[00013260] 4600                      not.b     d0
[00013262] 1300                      move.b    d0,-(a1)
[00013264] 1020                      move.b    -(a0),d0
[00013266] 4600                      not.b     d0
[00013268] 1300                      move.b    d0,-(a1)
[0001326a] 1020                      move.b    -(a0),d0
[0001326c] 4600                      not.b     d0
[0001326e] 1300                      move.b    d0,-(a1)
[00013270] 1020                      move.b    -(a0),d0
[00013272] 4600                      not.b     d0
[00013274] 1300                      move.b    d0,-(a1)
[00013276] 1020                      move.b    -(a0),d0
[00013278] 4600                      not.b     d0
[0001327a] 1300                      move.b    d0,-(a1)
[0001327c] 1020                      move.b    -(a0),d0
[0001327e] 4600                      not.b     d0
[00013280] 1300                      move.b    d0,-(a1)
[00013282] 1020                      move.b    -(a0),d0
[00013284] 4600                      not.b     d0
[00013286] 1300                      move.b    d0,-(a1)
[00013288] 1020                      move.b    -(a0),d0
[0001328a] 4600                      not.b     d0
[0001328c] 1300                      move.b    d0,-(a1)
[0001328e] 1020                      move.b    -(a0),d0
[00013290] 4600                      not.b     d0
[00013292] 1300                      move.b    d0,-(a1)
[00013294] 1020                      move.b    -(a0),d0
[00013296] 4600                      not.b     d0
[00013298] 1300                      move.b    d0,-(a1)
[0001329a] 1020                      move.b    -(a0),d0
[0001329c] 4600                      not.b     d0
[0001329e] 1300                      move.b    d0,-(a1)
[000132a0] 1020                      move.b    -(a0),d0
[000132a2] 4600                      not.b     d0
[000132a4] 1300                      move.b    d0,-(a1)
[000132a6] 1020                      move.b    -(a0),d0
[000132a8] 4600                      not.b     d0
[000132aa] 1300                      move.b    d0,-(a1)
[000132ac] 1020                      move.b    -(a0),d0
[000132ae] 4600                      not.b     d0
[000132b0] 1300                      move.b    d0,-(a1)
[000132b2] 1020                      move.b    -(a0),d0
[000132b4] 4600                      not.b     d0
[000132b6] 1300                      move.b    d0,-(a1)
[000132b8] 1020                      move.b    -(a0),d0
[000132ba] 4600                      not.b     d0
[000132bc] 1300                      move.b    d0,-(a1)
[000132be] 1020                      move.b    -(a0),d0
[000132c0] 4600                      not.b     d0
[000132c2] 1300                      move.b    d0,-(a1)
[000132c4] 1020                      move.b    -(a0),d0
[000132c6] 4600                      not.b     d0
[000132c8] 1300                      move.b    d0,-(a1)
[000132ca] 1020                      move.b    -(a0),d0
[000132cc] 4600                      not.b     d0
[000132ce] 1300                      move.b    d0,-(a1)
[000132d0] 1020                      move.b    -(a0),d0
[000132d2] 4600                      not.b     d0
[000132d4] 1300                      move.b    d0,-(a1)
[000132d6] 1020                      move.b    -(a0),d0
[000132d8] 4600                      not.b     d0
[000132da] 1300                      move.b    d0,-(a1)
[000132dc] 1020                      move.b    -(a0),d0
[000132de] 4600                      not.b     d0
[000132e0] 1300                      move.b    d0,-(a1)
[000132e2] 1020                      move.b    -(a0),d0
[000132e4] 4600                      not.b     d0
[000132e6] 1300                      move.b    d0,-(a1)
[000132e8] 1020                      move.b    -(a0),d0
[000132ea] 4600                      not.b     d0
[000132ec] 1300                      move.b    d0,-(a1)
[000132ee] 1020                      move.b    -(a0),d0
[000132f0] 4600                      not.b     d0
[000132f2] 1300                      move.b    d0,-(a1)
[000132f4] 51ce ff3e                 dbf       d6,$00013234
[000132f8] 90ca                      suba.w    a2,a0
[000132fa] 92cb                      suba.w    a3,a1
[000132fc] 51cd ff32                 dbf       d5,$00013230
[00013300] 4e75                      rts
[00013302] 49fb 0006                 lea.l     $0001330A(pc,d0.w),a4
[00013306] 3c04                      move.w    d4,d6
[00013308] 4ed4                      jmp       (a4)
[0001330a] 1020                      move.b    -(a0),d0
[0001330c] 4600                      not.b     d0
[0001330e] 8121                      or.b      d0,-(a1)
[00013310] 1020                      move.b    -(a0),d0
[00013312] 4600                      not.b     d0
[00013314] 8121                      or.b      d0,-(a1)
[00013316] 1020                      move.b    -(a0),d0
[00013318] 4600                      not.b     d0
[0001331a] 8121                      or.b      d0,-(a1)
[0001331c] 1020                      move.b    -(a0),d0
[0001331e] 4600                      not.b     d0
[00013320] 8121                      or.b      d0,-(a1)
[00013322] 1020                      move.b    -(a0),d0
[00013324] 4600                      not.b     d0
[00013326] 8121                      or.b      d0,-(a1)
[00013328] 1020                      move.b    -(a0),d0
[0001332a] 4600                      not.b     d0
[0001332c] 8121                      or.b      d0,-(a1)
[0001332e] 1020                      move.b    -(a0),d0
[00013330] 4600                      not.b     d0
[00013332] 8121                      or.b      d0,-(a1)
[00013334] 1020                      move.b    -(a0),d0
[00013336] 4600                      not.b     d0
[00013338] 8121                      or.b      d0,-(a1)
[0001333a] 1020                      move.b    -(a0),d0
[0001333c] 4600                      not.b     d0
[0001333e] 8121                      or.b      d0,-(a1)
[00013340] 1020                      move.b    -(a0),d0
[00013342] 4600                      not.b     d0
[00013344] 8121                      or.b      d0,-(a1)
[00013346] 1020                      move.b    -(a0),d0
[00013348] 4600                      not.b     d0
[0001334a] 8121                      or.b      d0,-(a1)
[0001334c] 1020                      move.b    -(a0),d0
[0001334e] 4600                      not.b     d0
[00013350] 8121                      or.b      d0,-(a1)
[00013352] 1020                      move.b    -(a0),d0
[00013354] 4600                      not.b     d0
[00013356] 8121                      or.b      d0,-(a1)
[00013358] 1020                      move.b    -(a0),d0
[0001335a] 4600                      not.b     d0
[0001335c] 8121                      or.b      d0,-(a1)
[0001335e] 1020                      move.b    -(a0),d0
[00013360] 4600                      not.b     d0
[00013362] 8121                      or.b      d0,-(a1)
[00013364] 1020                      move.b    -(a0),d0
[00013366] 4600                      not.b     d0
[00013368] 8121                      or.b      d0,-(a1)
[0001336a] 1020                      move.b    -(a0),d0
[0001336c] 4600                      not.b     d0
[0001336e] 8121                      or.b      d0,-(a1)
[00013370] 1020                      move.b    -(a0),d0
[00013372] 4600                      not.b     d0
[00013374] 8121                      or.b      d0,-(a1)
[00013376] 1020                      move.b    -(a0),d0
[00013378] 4600                      not.b     d0
[0001337a] 8121                      or.b      d0,-(a1)
[0001337c] 1020                      move.b    -(a0),d0
[0001337e] 4600                      not.b     d0
[00013380] 8121                      or.b      d0,-(a1)
[00013382] 1020                      move.b    -(a0),d0
[00013384] 4600                      not.b     d0
[00013386] 8121                      or.b      d0,-(a1)
[00013388] 1020                      move.b    -(a0),d0
[0001338a] 4600                      not.b     d0
[0001338c] 8121                      or.b      d0,-(a1)
[0001338e] 1020                      move.b    -(a0),d0
[00013390] 4600                      not.b     d0
[00013392] 8121                      or.b      d0,-(a1)
[00013394] 1020                      move.b    -(a0),d0
[00013396] 4600                      not.b     d0
[00013398] 8121                      or.b      d0,-(a1)
[0001339a] 1020                      move.b    -(a0),d0
[0001339c] 4600                      not.b     d0
[0001339e] 8121                      or.b      d0,-(a1)
[000133a0] 1020                      move.b    -(a0),d0
[000133a2] 4600                      not.b     d0
[000133a4] 8121                      or.b      d0,-(a1)
[000133a6] 1020                      move.b    -(a0),d0
[000133a8] 4600                      not.b     d0
[000133aa] 8121                      or.b      d0,-(a1)
[000133ac] 1020                      move.b    -(a0),d0
[000133ae] 4600                      not.b     d0
[000133b0] 8121                      or.b      d0,-(a1)
[000133b2] 1020                      move.b    -(a0),d0
[000133b4] 4600                      not.b     d0
[000133b6] 8121                      or.b      d0,-(a1)
[000133b8] 1020                      move.b    -(a0),d0
[000133ba] 4600                      not.b     d0
[000133bc] 8121                      or.b      d0,-(a1)
[000133be] 1020                      move.b    -(a0),d0
[000133c0] 4600                      not.b     d0
[000133c2] 8121                      or.b      d0,-(a1)
[000133c4] 1020                      move.b    -(a0),d0
[000133c6] 4600                      not.b     d0
[000133c8] 8121                      or.b      d0,-(a1)
[000133ca] 51ce ff3e                 dbf       d6,$0001330A
[000133ce] 90ca                      suba.w    a2,a0
[000133d0] 92cb                      suba.w    a3,a1
[000133d2] 51cd ff32                 dbf       d5,$00013306
[000133d6] 4e75                      rts
[000133d8] 49fb 0006                 lea.l     $000133E0(pc,d0.w),a4
[000133dc] 3c04                      move.w    d4,d6
[000133de] 4ed4                      jmp       (a4)
[000133e0] 1020                      move.b    -(a0),d0
[000133e2] c111                      and.b     d0,(a1)
[000133e4] 4621                      not.b     -(a1)
[000133e6] 1020                      move.b    -(a0),d0
[000133e8] c111                      and.b     d0,(a1)
[000133ea] 4621                      not.b     -(a1)
[000133ec] 1020                      move.b    -(a0),d0
[000133ee] c111                      and.b     d0,(a1)
[000133f0] 4621                      not.b     -(a1)
[000133f2] 1020                      move.b    -(a0),d0
[000133f4] c111                      and.b     d0,(a1)
[000133f6] 4621                      not.b     -(a1)
[000133f8] 1020                      move.b    -(a0),d0
[000133fa] c111                      and.b     d0,(a1)
[000133fc] 4621                      not.b     -(a1)
[000133fe] 1020                      move.b    -(a0),d0
[00013400] c111                      and.b     d0,(a1)
[00013402] 4621                      not.b     -(a1)
[00013404] 1020                      move.b    -(a0),d0
[00013406] c111                      and.b     d0,(a1)
[00013408] 4621                      not.b     -(a1)
[0001340a] 1020                      move.b    -(a0),d0
[0001340c] c111                      and.b     d0,(a1)
[0001340e] 4621                      not.b     -(a1)
[00013410] 1020                      move.b    -(a0),d0
[00013412] c111                      and.b     d0,(a1)
[00013414] 4621                      not.b     -(a1)
[00013416] 1020                      move.b    -(a0),d0
[00013418] c111                      and.b     d0,(a1)
[0001341a] 4621                      not.b     -(a1)
[0001341c] 1020                      move.b    -(a0),d0
[0001341e] c111                      and.b     d0,(a1)
[00013420] 4621                      not.b     -(a1)
[00013422] 1020                      move.b    -(a0),d0
[00013424] c111                      and.b     d0,(a1)
[00013426] 4621                      not.b     -(a1)
[00013428] 1020                      move.b    -(a0),d0
[0001342a] c111                      and.b     d0,(a1)
[0001342c] 4621                      not.b     -(a1)
[0001342e] 1020                      move.b    -(a0),d0
[00013430] c111                      and.b     d0,(a1)
[00013432] 4621                      not.b     -(a1)
[00013434] 1020                      move.b    -(a0),d0
[00013436] c111                      and.b     d0,(a1)
[00013438] 4621                      not.b     -(a1)
[0001343a] 1020                      move.b    -(a0),d0
[0001343c] c111                      and.b     d0,(a1)
[0001343e] 4621                      not.b     -(a1)
[00013440] 1020                      move.b    -(a0),d0
[00013442] c111                      and.b     d0,(a1)
[00013444] 4621                      not.b     -(a1)
[00013446] 1020                      move.b    -(a0),d0
[00013448] c111                      and.b     d0,(a1)
[0001344a] 4621                      not.b     -(a1)
[0001344c] 1020                      move.b    -(a0),d0
[0001344e] c111                      and.b     d0,(a1)
[00013450] 4621                      not.b     -(a1)
[00013452] 1020                      move.b    -(a0),d0
[00013454] c111                      and.b     d0,(a1)
[00013456] 4621                      not.b     -(a1)
[00013458] 1020                      move.b    -(a0),d0
[0001345a] c111                      and.b     d0,(a1)
[0001345c] 4621                      not.b     -(a1)
[0001345e] 1020                      move.b    -(a0),d0
[00013460] c111                      and.b     d0,(a1)
[00013462] 4621                      not.b     -(a1)
[00013464] 1020                      move.b    -(a0),d0
[00013466] c111                      and.b     d0,(a1)
[00013468] 4621                      not.b     -(a1)
[0001346a] 1020                      move.b    -(a0),d0
[0001346c] c111                      and.b     d0,(a1)
[0001346e] 4621                      not.b     -(a1)
[00013470] 1020                      move.b    -(a0),d0
[00013472] c111                      and.b     d0,(a1)
[00013474] 4621                      not.b     -(a1)
[00013476] 1020                      move.b    -(a0),d0
[00013478] c111                      and.b     d0,(a1)
[0001347a] 4621                      not.b     -(a1)
[0001347c] 1020                      move.b    -(a0),d0
[0001347e] c111                      and.b     d0,(a1)
[00013480] 4621                      not.b     -(a1)
[00013482] 1020                      move.b    -(a0),d0
[00013484] c111                      and.b     d0,(a1)
[00013486] 4621                      not.b     -(a1)
[00013488] 1020                      move.b    -(a0),d0
[0001348a] c111                      and.b     d0,(a1)
[0001348c] 4621                      not.b     -(a1)
[0001348e] 1020                      move.b    -(a0),d0
[00013490] c111                      and.b     d0,(a1)
[00013492] 4621                      not.b     -(a1)
[00013494] 1020                      move.b    -(a0),d0
[00013496] c111                      and.b     d0,(a1)
[00013498] 4621                      not.b     -(a1)
[0001349a] 1020                      move.b    -(a0),d0
[0001349c] c111                      and.b     d0,(a1)
[0001349e] 4621                      not.b     -(a1)
[000134a0] 51ce ff3e                 dbf       d6,$000133E0
[000134a4] 90ca                      suba.w    a2,a0
[000134a6] 92cb                      suba.w    a3,a1
[000134a8] 51cd ff32                 dbf       d5,$000133DC
[000134ac] 4e75                      rts
[000134ae] b87c 000f                 cmp.w     #$000F,d4
[000134b2] 6f00 00ba                 ble       $0001356E
[000134b6] 3c04                      move.w    d4,d6
[000134b8] 5246                      addq.w    #1,d6
[000134ba] 94c6                      suba.w    d6,a2
[000134bc] 96c6                      suba.w    d6,a3
[000134be] 323a 0f22                 move.w    $000143E2(pc),d1
[000134c2] 660e                      bne.s     $000134D2
[000134c4] 7201                      moveq.l   #1,d1
[000134c6] 7601                      moveq.l   #1,d3
[000134c8] c240                      and.w     d0,d1
[000134ca] c642                      and.w     d2,d3
[000134cc] b641                      cmp.w     d1,d3
[000134ce] 6600 00a6                 bne       $00013576
[000134d2] 7c03                      moveq.l   #3,d6
[000134d4] 3404                      move.w    d4,d2
[000134d6] d440                      add.w     d0,d2
[000134d8] 5340                      subq.w    #1,d0
[000134da] c046                      and.w     d6,d0
[000134dc] 7203                      moveq.l   #3,d1
[000134de] b141                      eor.w     d0,d1
[000134e0] 9841                      sub.w     d1,d4
[000134e2] d040                      add.w     d0,d0
[000134e4] 5242                      addq.w    #1,d2
[000134e6] c446                      and.w     d6,d2
[000134e8] 9842                      sub.w     d2,d4
[000134ea] bd42                      eor.w     d6,d2
[000134ec] d442                      add.w     d2,d2
[000134ee] 5244                      addq.w    #1,d4
[000134f0] e44c                      lsr.w     #2,d4
[000134f2] 5344                      subq.w    #1,d4
[000134f4] 3204                      move.w    d4,d1
[000134f6] 4641                      not.w     d1
[000134f8] c246                      and.w     d6,d1
[000134fa] d241                      add.w     d1,d1
[000134fc] e44c                      lsr.w     #2,d4
[000134fe] de47                      add.w     d7,d7
[00013500] de47                      add.w     d7,d7
[00013502] 49fb 702a                 lea.l     $0001352E(pc,d7.w),a4
[00013506] 3e1c                      move.w    (a4)+,d7
[00013508] 671e                      beq.s     $00013528
[0001350a] 5347                      subq.w    #1,d7
[0001350c] 6714                      beq.s     $00013522
[0001350e] 3e00                      move.w    d0,d7
[00013510] d040                      add.w     d0,d0
[00013512] d047                      add.w     d7,d0
[00013514] 3e01                      move.w    d1,d7
[00013516] d241                      add.w     d1,d1
[00013518] d247                      add.w     d7,d1
[0001351a] 3e02                      move.w    d2,d7
[0001351c] d442                      add.w     d2,d2
[0001351e] d447                      add.w     d7,d2
[00013520] 6006                      bra.s     $00013528
[00013522] d040                      add.w     d0,d0
[00013524] d241                      add.w     d1,d1
[00013526] d442                      add.w     d2,d2
[00013528] 3e1c                      move.w    (a4)+,d7
[0001352a] 4efb 7002                 jmp       $0001352E(pc,d7.w)
[0001352e] 0000 00b8                 ori.b     #$B8,d0
[00013532] 0001 00ee                 ori.b     #$EE,d1
[00013536] 0002 0138                 ori.b     #$38,d2
[0001353a] 0000 0196                 ori.b     #$96,d0
[0001353e] 0002 01cc                 ori.b     #$CC,d2
[00013542] 0000 f3ee                 ori.b     #$EE,d0
[00013546] 0001 022a                 ori.b     #$2A,d1
[0001354a] 0001 0274                 ori.b     #$74,d1
[0001354e] 0002 02be                 ori.b     #$BE,d2
[00013552] 0002 031c                 ori.b     #$1C,d2
[00013556] 0000 037a                 ori.b     #$7A,d0
[0001355a] 0002 03ae                 ori.b     #$AE,d2
[0001355e] 0002 040c                 ori.b     #$0C,d2
[00013562] 0002 046a                 ori.b     #$6A,d2
[00013566] 0002 04c8                 ori.b     #$C8,d2
[0001356a] 0000 00b4                 ori.b     #$B4,d0
[0001356e] 3c04                      move.w    d4,d6
[00013570] 5246                      addq.w    #1,d6
[00013572] 94c6                      suba.w    d6,a2
[00013574] 96c6                      suba.w    d6,a3
[00013576] 3004                      move.w    d4,d0
[00013578] ea4c                      lsr.w     #5,d4
[0001357a] 4640                      not.w     d0
[0001357c] 0240 001f                 andi.w    #$001F,d0
[00013580] d040                      add.w     d0,d0
[00013582] de47                      add.w     d7,d7
[00013584] de47                      add.w     d7,d7
[00013586] 49fb 701a                 lea.l     $000135A2(pc,d7.w),a4
[0001358a] 3e1c                      move.w    (a4)+,d7
[0001358c] 670e                      beq.s     $0001359C
[0001358e] 5347                      subq.w    #1,d7
[00013590] 6708                      beq.s     $0001359A
[00013592] 3e00                      move.w    d0,d7
[00013594] d040                      add.w     d0,d0
[00013596] d047                      add.w     d7,d0
[00013598] 6002                      bra.s     $0001359C
[0001359a] d040                      add.w     d0,d0
[0001359c] 3e1c                      move.w    (a4)+,d7
[0001359e] 4efb 7002                 jmp       $000135A2(pc,d7.w)
[000135a2] 0000 04b6                 ori.b     #$B6,d0
[000135a6] 0001 050c                 ori.b     #$0C,d1
[000135aa] 0002 05a2                 ori.b     #$A2,d2
[000135ae] 0000 0678                 ori.b     #$78,d0
[000135b2] 0002 06ce                 ori.b     #$CE,d2
[000135b6] 0000 f37a                 ori.b     #$7A,d0
[000135ba] 0001 07a4                 ori.b     #$A4,d1
[000135be] 0001 083a                 ori.b     #$3A,d1
[000135c2] 0002 08d0                 ori.b     #$D0,d2
[000135c6] 0002 09a6                 ori.b     #$A6,d2
[000135ca] 0000 0a7c                 ori.b     #$7C,d0
[000135ce] 0002 0ad2                 ori.b     #$D2,d2
[000135d2] 0002 0ba8                 ori.b     #$A8,d2
[000135d6] 0002 0c7e                 ori.b     #$7E,d2
[000135da] 0002 0d54                 ori.b     #$54,d2
[000135de] 0000 04b2                 ori.b     #$B2,d0
[000135e2] 7eff                      moveq.l   #-1,d7
[000135e4] 6002                      bra.s     $000135E8
[000135e6] 7e00                      moveq.l   #0,d7
[000135e8] 49fb 000c                 lea.l     $000135F6(pc,d0.w),a4
[000135ec] 4bfb 1012                 lea.l     $00013600(pc,d1.w),a5
[000135f0] 4dfb 201c                 lea.l     $0001360E(pc,d2.w),a6
[000135f4] 4ed4                      jmp       (a4)
[000135f6] 12c7                      move.b    d7,(a1)+
[000135f8] 12c7                      move.b    d7,(a1)+
[000135fa] 12c7                      move.b    d7,(a1)+
[000135fc] 3c04                      move.w    d4,d6
[000135fe] 4ed5                      jmp       (a5)
[00013600] 22c7                      move.l    d7,(a1)+
[00013602] 22c7                      move.l    d7,(a1)+
[00013604] 22c7                      move.l    d7,(a1)+
[00013606] 22c7                      move.l    d7,(a1)+
[00013608] 51ce fff6                 dbf       d6,$00013600
[0001360c] 4ed6                      jmp       (a6)
[0001360e] 12c7                      move.b    d7,(a1)+
[00013610] 12c7                      move.b    d7,(a1)+
[00013612] 12c7                      move.b    d7,(a1)+
[00013614] d2cb                      adda.w    a3,a1
[00013616] 51cd ffdc                 dbf       d5,$000135F4
[0001361a] 4e75                      rts
[0001361c] 49fb 000c                 lea.l     $0001362A(pc,d0.w),a4
[00013620] 4bfb 1018                 lea.l     $0001363A(pc,d1.w),a5
[00013624] 4dfb 202a                 lea.l     $00013650(pc,d2.w),a6
[00013628] 4ed4                      jmp       (a4)
[0001362a] 1018                      move.b    (a0)+,d0
[0001362c] c119                      and.b     d0,(a1)+
[0001362e] 1018                      move.b    (a0)+,d0
[00013630] c119                      and.b     d0,(a1)+
[00013632] 1018                      move.b    (a0)+,d0
[00013634] c119                      and.b     d0,(a1)+
[00013636] 3c04                      move.w    d4,d6
[00013638] 4ed5                      jmp       (a5)
[0001363a] 2018                      move.l    (a0)+,d0
[0001363c] c199                      and.l     d0,(a1)+
[0001363e] 2018                      move.l    (a0)+,d0
[00013640] c199                      and.l     d0,(a1)+
[00013642] 2018                      move.l    (a0)+,d0
[00013644] c199                      and.l     d0,(a1)+
[00013646] 2018                      move.l    (a0)+,d0
[00013648] c199                      and.l     d0,(a1)+
[0001364a] 51ce ffee                 dbf       d6,$0001363A
[0001364e] 4ed6                      jmp       (a6)
[00013650] 1018                      move.b    (a0)+,d0
[00013652] c119                      and.b     d0,(a1)+
[00013654] 1018                      move.b    (a0)+,d0
[00013656] c119                      and.b     d0,(a1)+
[00013658] 1018                      move.b    (a0)+,d0
[0001365a] c119                      and.b     d0,(a1)+
[0001365c] d0ca                      adda.w    a2,a0
[0001365e] d2cb                      adda.w    a3,a1
[00013660] 51cd ffc6                 dbf       d5,$00013628
[00013664] 4e75                      rts
[00013666] 49fb 000c                 lea.l     $00013674(pc,d0.w),a4
[0001366a] 4bfb 101e                 lea.l     $0001368A(pc,d1.w),a5
[0001366e] 4dfb 2038                 lea.l     $000136A8(pc,d2.w),a6
[00013672] 4ed4                      jmp       (a4)
[00013674] 1018                      move.b    (a0)+,d0
[00013676] 4611                      not.b     (a1)
[00013678] c119                      and.b     d0,(a1)+
[0001367a] 1018                      move.b    (a0)+,d0
[0001367c] 4611                      not.b     (a1)
[0001367e] c119                      and.b     d0,(a1)+
[00013680] 1018                      move.b    (a0)+,d0
[00013682] 4611                      not.b     (a1)
[00013684] c119                      and.b     d0,(a1)+
[00013686] 3c04                      move.w    d4,d6
[00013688] 4ed5                      jmp       (a5)
[0001368a] 2018                      move.l    (a0)+,d0
[0001368c] 4691                      not.l     (a1)
[0001368e] c199                      and.l     d0,(a1)+
[00013690] 2018                      move.l    (a0)+,d0
[00013692] 4691                      not.l     (a1)
[00013694] c199                      and.l     d0,(a1)+
[00013696] 2018                      move.l    (a0)+,d0
[00013698] 4691                      not.l     (a1)
[0001369a] c199                      and.l     d0,(a1)+
[0001369c] 2018                      move.l    (a0)+,d0
[0001369e] 4691                      not.l     (a1)
[000136a0] c199                      and.l     d0,(a1)+
[000136a2] 51ce ffe6                 dbf       d6,$0001368A
[000136a6] 4ed6                      jmp       (a6)
[000136a8] 1018                      move.b    (a0)+,d0
[000136aa] 4611                      not.b     (a1)
[000136ac] c119                      and.b     d0,(a1)+
[000136ae] 1018                      move.b    (a0)+,d0
[000136b0] 4611                      not.b     (a1)
[000136b2] c119                      and.b     d0,(a1)+
[000136b4] 1018                      move.b    (a0)+,d0
[000136b6] 4611                      not.b     (a1)
[000136b8] c119                      and.b     d0,(a1)+
[000136ba] d0ca                      adda.w    a2,a0
[000136bc] d2cb                      adda.w    a3,a1
[000136be] 51cd ffb2                 dbf       d5,$00013672
[000136c2] 4e75                      rts
[000136c4] 49fb 000c                 lea.l     $000136D2(pc,d0.w),a4
[000136c8] 4bfb 1012                 lea.l     $000136DC(pc,d1.w),a5
[000136cc] 4dfb 201c                 lea.l     $000136EA(pc,d2.w),a6
[000136d0] 4ed4                      jmp       (a4)
[000136d2] 12d8                      move.b    (a0)+,(a1)+
[000136d4] 12d8                      move.b    (a0)+,(a1)+
[000136d6] 12d8                      move.b    (a0)+,(a1)+
[000136d8] 3c04                      move.w    d4,d6
[000136da] 4ed5                      jmp       (a5)
[000136dc] 22d8                      move.l    (a0)+,(a1)+
[000136de] 22d8                      move.l    (a0)+,(a1)+
[000136e0] 22d8                      move.l    (a0)+,(a1)+
[000136e2] 22d8                      move.l    (a0)+,(a1)+
[000136e4] 51ce fff6                 dbf       d6,$000136DC
[000136e8] 4ed6                      jmp       (a6)
[000136ea] 12d8                      move.b    (a0)+,(a1)+
[000136ec] 12d8                      move.b    (a0)+,(a1)+
[000136ee] 12d8                      move.b    (a0)+,(a1)+
[000136f0] d0ca                      adda.w    a2,a0
[000136f2] d2cb                      adda.w    a3,a1
[000136f4] 51cd ffda                 dbf       d5,$000136D0
[000136f8] 4e75                      rts
[000136fa] 49fb 000c                 lea.l     $00013708(pc,d0.w),a4
[000136fe] 4bfb 101e                 lea.l     $0001371E(pc,d1.w),a5
[00013702] 4dfb 2038                 lea.l     $0001373C(pc,d2.w),a6
[00013706] 4ed4                      jmp       (a4)
[00013708] 1018                      move.b    (a0)+,d0
[0001370a] 4600                      not.b     d0
[0001370c] c119                      and.b     d0,(a1)+
[0001370e] 1018                      move.b    (a0)+,d0
[00013710] 4600                      not.b     d0
[00013712] c119                      and.b     d0,(a1)+
[00013714] 1018                      move.b    (a0)+,d0
[00013716] 4600                      not.b     d0
[00013718] c119                      and.b     d0,(a1)+
[0001371a] 3c04                      move.w    d4,d6
[0001371c] 4ed5                      jmp       (a5)
[0001371e] 2018                      move.l    (a0)+,d0
[00013720] 4680                      not.l     d0
[00013722] c199                      and.l     d0,(a1)+
[00013724] 2018                      move.l    (a0)+,d0
[00013726] 4680                      not.l     d0
[00013728] c199                      and.l     d0,(a1)+
[0001372a] 2018                      move.l    (a0)+,d0
[0001372c] 4680                      not.l     d0
[0001372e] c199                      and.l     d0,(a1)+
[00013730] 2018                      move.l    (a0)+,d0
[00013732] 4680                      not.l     d0
[00013734] c199                      and.l     d0,(a1)+
[00013736] 51ce ffe6                 dbf       d6,$0001371E
[0001373a] 4ed6                      jmp       (a6)
[0001373c] 1018                      move.b    (a0)+,d0
[0001373e] 4600                      not.b     d0
[00013740] c119                      and.b     d0,(a1)+
[00013742] 1018                      move.b    (a0)+,d0
[00013744] 4600                      not.b     d0
[00013746] c119                      and.b     d0,(a1)+
[00013748] 1018                      move.b    (a0)+,d0
[0001374a] 4600                      not.b     d0
[0001374c] c119                      and.b     d0,(a1)+
[0001374e] d0ca                      adda.w    a2,a0
[00013750] d2cb                      adda.w    a3,a1
[00013752] 51cd ffb2                 dbf       d5,$00013706
[00013756] 4e75                      rts
[00013758] 49fb 000c                 lea.l     $00013766(pc,d0.w),a4
[0001375c] 4bfb 1018                 lea.l     $00013776(pc,d1.w),a5
[00013760] 4dfb 202a                 lea.l     $0001378C(pc,d2.w),a6
[00013764] 4ed4                      jmp       (a4)
[00013766] 1018                      move.b    (a0)+,d0
[00013768] b119                      eor.b     d0,(a1)+
[0001376a] 1018                      move.b    (a0)+,d0
[0001376c] b119                      eor.b     d0,(a1)+
[0001376e] 1018                      move.b    (a0)+,d0
[00013770] b119                      eor.b     d0,(a1)+
[00013772] 3c04                      move.w    d4,d6
[00013774] 4ed5                      jmp       (a5)
[00013776] 2018                      move.l    (a0)+,d0
[00013778] b199                      eor.l     d0,(a1)+
[0001377a] 2018                      move.l    (a0)+,d0
[0001377c] b199                      eor.l     d0,(a1)+
[0001377e] 2018                      move.l    (a0)+,d0
[00013780] b199                      eor.l     d0,(a1)+
[00013782] 2018                      move.l    (a0)+,d0
[00013784] b199                      eor.l     d0,(a1)+
[00013786] 51ce ffee                 dbf       d6,$00013776
[0001378a] 4ed6                      jmp       (a6)
[0001378c] 1018                      move.b    (a0)+,d0
[0001378e] b119                      eor.b     d0,(a1)+
[00013790] 1018                      move.b    (a0)+,d0
[00013792] b119                      eor.b     d0,(a1)+
[00013794] 1018                      move.b    (a0)+,d0
[00013796] b119                      eor.b     d0,(a1)+
[00013798] d0ca                      adda.w    a2,a0
[0001379a] d2cb                      adda.w    a3,a1
[0001379c] 51cd ffc6                 dbf       d5,$00013764
[000137a0] 4e75                      rts
[000137a2] 49fb 000c                 lea.l     $000137B0(pc,d0.w),a4
[000137a6] 4bfb 1018                 lea.l     $000137C0(pc,d1.w),a5
[000137aa] 4dfb 202a                 lea.l     $000137D6(pc,d2.w),a6
[000137ae] 4ed4                      jmp       (a4)
[000137b0] 1018                      move.b    (a0)+,d0
[000137b2] 8119                      or.b      d0,(a1)+
[000137b4] 1018                      move.b    (a0)+,d0
[000137b6] 8119                      or.b      d0,(a1)+
[000137b8] 1018                      move.b    (a0)+,d0
[000137ba] 8119                      or.b      d0,(a1)+
[000137bc] 3c04                      move.w    d4,d6
[000137be] 4ed5                      jmp       (a5)
[000137c0] 2018                      move.l    (a0)+,d0
[000137c2] 8199                      or.l      d0,(a1)+
[000137c4] 2018                      move.l    (a0)+,d0
[000137c6] 8199                      or.l      d0,(a1)+
[000137c8] 2018                      move.l    (a0)+,d0
[000137ca] 8199                      or.l      d0,(a1)+
[000137cc] 2018                      move.l    (a0)+,d0
[000137ce] 8199                      or.l      d0,(a1)+
[000137d0] 51ce ffee                 dbf       d6,$000137C0
[000137d4] 4ed6                      jmp       (a6)
[000137d6] 1018                      move.b    (a0)+,d0
[000137d8] 8119                      or.b      d0,(a1)+
[000137da] 1018                      move.b    (a0)+,d0
[000137dc] 8119                      or.b      d0,(a1)+
[000137de] 1018                      move.b    (a0)+,d0
[000137e0] 8119                      or.b      d0,(a1)+
[000137e2] d0ca                      adda.w    a2,a0
[000137e4] d2cb                      adda.w    a3,a1
[000137e6] 51cd ffc6                 dbf       d5,$000137AE
[000137ea] 4e75                      rts
[000137ec] 49fb 000c                 lea.l     $000137FA(pc,d0.w),a4
[000137f0] 4bfb 101e                 lea.l     $00013810(pc,d1.w),a5
[000137f4] 4dfb 2038                 lea.l     $0001382E(pc,d2.w),a6
[000137f8] 4ed4                      jmp       (a4)
[000137fa] 1018                      move.b    (a0)+,d0
[000137fc] 8111                      or.b      d0,(a1)
[000137fe] 4619                      not.b     (a1)+
[00013800] 1018                      move.b    (a0)+,d0
[00013802] 8111                      or.b      d0,(a1)
[00013804] 4619                      not.b     (a1)+
[00013806] 1018                      move.b    (a0)+,d0
[00013808] 8111                      or.b      d0,(a1)
[0001380a] 4619                      not.b     (a1)+
[0001380c] 3c04                      move.w    d4,d6
[0001380e] 4ed5                      jmp       (a5)
[00013810] 2018                      move.l    (a0)+,d0
[00013812] 8191                      or.l      d0,(a1)
[00013814] 4699                      not.l     (a1)+
[00013816] 2018                      move.l    (a0)+,d0
[00013818] 8191                      or.l      d0,(a1)
[0001381a] 4699                      not.l     (a1)+
[0001381c] 2018                      move.l    (a0)+,d0
[0001381e] 8191                      or.l      d0,(a1)
[00013820] 4699                      not.l     (a1)+
[00013822] 2018                      move.l    (a0)+,d0
[00013824] 8191                      or.l      d0,(a1)
[00013826] 4699                      not.l     (a1)+
[00013828] 51ce ffe6                 dbf       d6,$00013810
[0001382c] 4ed6                      jmp       (a6)
[0001382e] 1018                      move.b    (a0)+,d0
[00013830] 8111                      or.b      d0,(a1)
[00013832] 4619                      not.b     (a1)+
[00013834] 1018                      move.b    (a0)+,d0
[00013836] 8111                      or.b      d0,(a1)
[00013838] 4619                      not.b     (a1)+
[0001383a] 1018                      move.b    (a0)+,d0
[0001383c] 8111                      or.b      d0,(a1)
[0001383e] 4619                      not.b     (a1)+
[00013840] d0ca                      adda.w    a2,a0
[00013842] d2cb                      adda.w    a3,a1
[00013844] 51cd ffb2                 dbf       d5,$000137F8
[00013848] 4e75                      rts
[0001384a] 49fb 000c                 lea.l     $00013858(pc,d0.w),a4
[0001384e] 4bfb 101e                 lea.l     $0001386E(pc,d1.w),a5
[00013852] 4dfb 2038                 lea.l     $0001388C(pc,d2.w),a6
[00013856] 4ed4                      jmp       (a4)
[00013858] 1018                      move.b    (a0)+,d0
[0001385a] b111                      eor.b     d0,(a1)
[0001385c] 4619                      not.b     (a1)+
[0001385e] 1018                      move.b    (a0)+,d0
[00013860] b111                      eor.b     d0,(a1)
[00013862] 4619                      not.b     (a1)+
[00013864] 1018                      move.b    (a0)+,d0
[00013866] b111                      eor.b     d0,(a1)
[00013868] 4619                      not.b     (a1)+
[0001386a] 3c04                      move.w    d4,d6
[0001386c] 4ed5                      jmp       (a5)
[0001386e] 2018                      move.l    (a0)+,d0
[00013870] b191                      eor.l     d0,(a1)
[00013872] 4699                      not.l     (a1)+
[00013874] 2018                      move.l    (a0)+,d0
[00013876] b191                      eor.l     d0,(a1)
[00013878] 4699                      not.l     (a1)+
[0001387a] 2018                      move.l    (a0)+,d0
[0001387c] b191                      eor.l     d0,(a1)
[0001387e] 4699                      not.l     (a1)+
[00013880] 2018                      move.l    (a0)+,d0
[00013882] b191                      eor.l     d0,(a1)
[00013884] 4699                      not.l     (a1)+
[00013886] 51ce ffe6                 dbf       d6,$0001386E
[0001388a] 4ed6                      jmp       (a6)
[0001388c] 1018                      move.b    (a0)+,d0
[0001388e] b111                      eor.b     d0,(a1)
[00013890] 4619                      not.b     (a1)+
[00013892] 1018                      move.b    (a0)+,d0
[00013894] b111                      eor.b     d0,(a1)
[00013896] 4619                      not.b     (a1)+
[00013898] 1018                      move.b    (a0)+,d0
[0001389a] b111                      eor.b     d0,(a1)
[0001389c] 4619                      not.b     (a1)+
[0001389e] d0ca                      adda.w    a2,a0
[000138a0] d2cb                      adda.w    a3,a1
[000138a2] 51cd ffb2                 dbf       d5,$00013856
[000138a6] 4e75                      rts
[000138a8] 49fb 000c                 lea.l     $000138B6(pc,d0.w),a4
[000138ac] 4bfb 1012                 lea.l     $000138C0(pc,d1.w),a5
[000138b0] 4dfb 201c                 lea.l     $000138CE(pc,d2.w),a6
[000138b4] 4ed4                      jmp       (a4)
[000138b6] 4619                      not.b     (a1)+
[000138b8] 4619                      not.b     (a1)+
[000138ba] 4619                      not.b     (a1)+
[000138bc] 3c04                      move.w    d4,d6
[000138be] 4ed5                      jmp       (a5)
[000138c0] 4699                      not.l     (a1)+
[000138c2] 4699                      not.l     (a1)+
[000138c4] 4699                      not.l     (a1)+
[000138c6] 4699                      not.l     (a1)+
[000138c8] 51ce fff6                 dbf       d6,$000138C0
[000138cc] 4ed6                      jmp       (a6)
[000138ce] 4619                      not.b     (a1)+
[000138d0] 4619                      not.b     (a1)+
[000138d2] 4619                      not.b     (a1)+
[000138d4] d2cb                      adda.w    a3,a1
[000138d6] 51cd ffdc                 dbf       d5,$000138B4
[000138da] 4e75                      rts
[000138dc] 49fb 000c                 lea.l     $000138EA(pc,d0.w),a4
[000138e0] 4bfb 101e                 lea.l     $00013900(pc,d1.w),a5
[000138e4] 4dfb 2038                 lea.l     $0001391E(pc,d2.w),a6
[000138e8] 4ed4                      jmp       (a4)
[000138ea] 4611                      not.b     (a1)
[000138ec] 1018                      move.b    (a0)+,d0
[000138ee] 8119                      or.b      d0,(a1)+
[000138f0] 4611                      not.b     (a1)
[000138f2] 1018                      move.b    (a0)+,d0
[000138f4] 8119                      or.b      d0,(a1)+
[000138f6] 4611                      not.b     (a1)
[000138f8] 1018                      move.b    (a0)+,d0
[000138fa] 8119                      or.b      d0,(a1)+
[000138fc] 3c04                      move.w    d4,d6
[000138fe] 4ed5                      jmp       (a5)
[00013900] 4691                      not.l     (a1)
[00013902] 2018                      move.l    (a0)+,d0
[00013904] 8199                      or.l      d0,(a1)+
[00013906] 4691                      not.l     (a1)
[00013908] 2018                      move.l    (a0)+,d0
[0001390a] 8199                      or.l      d0,(a1)+
[0001390c] 4691                      not.l     (a1)
[0001390e] 2018                      move.l    (a0)+,d0
[00013910] 8199                      or.l      d0,(a1)+
[00013912] 4691                      not.l     (a1)
[00013914] 2018                      move.l    (a0)+,d0
[00013916] 8199                      or.l      d0,(a1)+
[00013918] 51ce ffe6                 dbf       d6,$00013900
[0001391c] 4ed6                      jmp       (a6)
[0001391e] 4611                      not.b     (a1)
[00013920] 1018                      move.b    (a0)+,d0
[00013922] 8119                      or.b      d0,(a1)+
[00013924] 4611                      not.b     (a1)
[00013926] 1018                      move.b    (a0)+,d0
[00013928] 8119                      or.b      d0,(a1)+
[0001392a] 4611                      not.b     (a1)
[0001392c] 1018                      move.b    (a0)+,d0
[0001392e] 8119                      or.b      d0,(a1)+
[00013930] d0ca                      adda.w    a2,a0
[00013932] d2cb                      adda.w    a3,a1
[00013934] 51cd ffb2                 dbf       d5,$000138E8
[00013938] 4e75                      rts
[0001393a] 49fb 000c                 lea.l     $00013948(pc,d0.w),a4
[0001393e] 4bfb 101e                 lea.l     $0001395E(pc,d1.w),a5
[00013942] 4dfb 2038                 lea.l     $0001397C(pc,d2.w),a6
[00013946] 4ed4                      jmp       (a4)
[00013948] 1018                      move.b    (a0)+,d0
[0001394a] 4600                      not.b     d0
[0001394c] 12c0                      move.b    d0,(a1)+
[0001394e] 1018                      move.b    (a0)+,d0
[00013950] 4600                      not.b     d0
[00013952] 12c0                      move.b    d0,(a1)+
[00013954] 1018                      move.b    (a0)+,d0
[00013956] 4600                      not.b     d0
[00013958] 12c0                      move.b    d0,(a1)+
[0001395a] 3c04                      move.w    d4,d6
[0001395c] 4ed5                      jmp       (a5)
[0001395e] 2018                      move.l    (a0)+,d0
[00013960] 4680                      not.l     d0
[00013962] 22c0                      move.l    d0,(a1)+
[00013964] 2018                      move.l    (a0)+,d0
[00013966] 4680                      not.l     d0
[00013968] 22c0                      move.l    d0,(a1)+
[0001396a] 2018                      move.l    (a0)+,d0
[0001396c] 4680                      not.l     d0
[0001396e] 22c0                      move.l    d0,(a1)+
[00013970] 2018                      move.l    (a0)+,d0
[00013972] 4680                      not.l     d0
[00013974] 22c0                      move.l    d0,(a1)+
[00013976] 51ce ffe6                 dbf       d6,$0001395E
[0001397a] 4ed6                      jmp       (a6)
[0001397c] 1018                      move.b    (a0)+,d0
[0001397e] 4600                      not.b     d0
[00013980] 12c0                      move.b    d0,(a1)+
[00013982] 1018                      move.b    (a0)+,d0
[00013984] 4600                      not.b     d0
[00013986] 12c0                      move.b    d0,(a1)+
[00013988] 1018                      move.b    (a0)+,d0
[0001398a] 4600                      not.b     d0
[0001398c] 12c0                      move.b    d0,(a1)+
[0001398e] d0ca                      adda.w    a2,a0
[00013990] d2cb                      adda.w    a3,a1
[00013992] 51cd ffb2                 dbf       d5,$00013946
[00013996] 4e75                      rts
[00013998] 49fb 000c                 lea.l     $000139A6(pc,d0.w),a4
[0001399c] 4bfb 101e                 lea.l     $000139BC(pc,d1.w),a5
[000139a0] 4dfb 2038                 lea.l     $000139DA(pc,d2.w),a6
[000139a4] 4ed4                      jmp       (a4)
[000139a6] 1018                      move.b    (a0)+,d0
[000139a8] 4600                      not.b     d0
[000139aa] 8119                      or.b      d0,(a1)+
[000139ac] 1018                      move.b    (a0)+,d0
[000139ae] 4600                      not.b     d0
[000139b0] 8119                      or.b      d0,(a1)+
[000139b2] 1018                      move.b    (a0)+,d0
[000139b4] 4600                      not.b     d0
[000139b6] 8119                      or.b      d0,(a1)+
[000139b8] 3c04                      move.w    d4,d6
[000139ba] 4ed5                      jmp       (a5)
[000139bc] 2018                      move.l    (a0)+,d0
[000139be] 4680                      not.l     d0
[000139c0] 8199                      or.l      d0,(a1)+
[000139c2] 2018                      move.l    (a0)+,d0
[000139c4] 4680                      not.l     d0
[000139c6] 8199                      or.l      d0,(a1)+
[000139c8] 2018                      move.l    (a0)+,d0
[000139ca] 4680                      not.l     d0
[000139cc] 8199                      or.l      d0,(a1)+
[000139ce] 2018                      move.l    (a0)+,d0
[000139d0] 4680                      not.l     d0
[000139d2] 8199                      or.l      d0,(a1)+
[000139d4] 51ce ffe6                 dbf       d6,$000139BC
[000139d8] 4ed6                      jmp       (a6)
[000139da] 1018                      move.b    (a0)+,d0
[000139dc] 4600                      not.b     d0
[000139de] 8119                      or.b      d0,(a1)+
[000139e0] 1018                      move.b    (a0)+,d0
[000139e2] 4600                      not.b     d0
[000139e4] 8119                      or.b      d0,(a1)+
[000139e6] 1018                      move.b    (a0)+,d0
[000139e8] 4600                      not.b     d0
[000139ea] 8119                      or.b      d0,(a1)+
[000139ec] d0ca                      adda.w    a2,a0
[000139ee] d2cb                      adda.w    a3,a1
[000139f0] 51cd ffb2                 dbf       d5,$000139A4
[000139f4] 4e75                      rts
[000139f6] 49fb 000c                 lea.l     $00013A04(pc,d0.w),a4
[000139fa] 4bfb 101e                 lea.l     $00013A1A(pc,d1.w),a5
[000139fe] 4dfb 2038                 lea.l     $00013A38(pc,d2.w),a6
[00013a02] 4ed4                      jmp       (a4)
[00013a04] 1018                      move.b    (a0)+,d0
[00013a06] c111                      and.b     d0,(a1)
[00013a08] 4619                      not.b     (a1)+
[00013a0a] 1018                      move.b    (a0)+,d0
[00013a0c] c111                      and.b     d0,(a1)
[00013a0e] 4619                      not.b     (a1)+
[00013a10] 1018                      move.b    (a0)+,d0
[00013a12] c111                      and.b     d0,(a1)
[00013a14] 4619                      not.b     (a1)+
[00013a16] 3c04                      move.w    d4,d6
[00013a18] 4ed5                      jmp       (a5)
[00013a1a] 2018                      move.l    (a0)+,d0
[00013a1c] c191                      and.l     d0,(a1)
[00013a1e] 4699                      not.l     (a1)+
[00013a20] 2018                      move.l    (a0)+,d0
[00013a22] c191                      and.l     d0,(a1)
[00013a24] 4699                      not.l     (a1)+
[00013a26] 2018                      move.l    (a0)+,d0
[00013a28] c191                      and.l     d0,(a1)
[00013a2a] 4699                      not.l     (a1)+
[00013a2c] 2018                      move.l    (a0)+,d0
[00013a2e] c191                      and.l     d0,(a1)
[00013a30] 4699                      not.l     (a1)+
[00013a32] 51ce ffe6                 dbf       d6,$00013A1A
[00013a36] 4ed6                      jmp       (a6)
[00013a38] 1018                      move.b    (a0)+,d0
[00013a3a] c111                      and.b     d0,(a1)
[00013a3c] 4619                      not.b     (a1)+
[00013a3e] 1018                      move.b    (a0)+,d0
[00013a40] c111                      and.b     d0,(a1)
[00013a42] 4619                      not.b     (a1)+
[00013a44] 1018                      move.b    (a0)+,d0
[00013a46] c111                      and.b     d0,(a1)
[00013a48] 4619                      not.b     (a1)+
[00013a4a] d0ca                      adda.w    a2,a0
[00013a4c] d2cb                      adda.w    a3,a1
[00013a4e] 51cd ffb2                 dbf       d5,$00013A02
[00013a52] 4e75                      rts
[00013a54] 7eff                      moveq.l   #-1,d7
[00013a56] 6002                      bra.s     $00013A5A
[00013a58] 7e00                      moveq.l   #0,d7
[00013a5a] 49fb 0006                 lea.l     $00013A62(pc,d0.w),a4
[00013a5e] 3c04                      move.w    d4,d6
[00013a60] 4ed4                      jmp       (a4)
[00013a62] 12c7                      move.b    d7,(a1)+
[00013a64] 12c7                      move.b    d7,(a1)+
[00013a66] 12c7                      move.b    d7,(a1)+
[00013a68] 12c7                      move.b    d7,(a1)+
[00013a6a] 12c7                      move.b    d7,(a1)+
[00013a6c] 12c7                      move.b    d7,(a1)+
[00013a6e] 12c7                      move.b    d7,(a1)+
[00013a70] 12c7                      move.b    d7,(a1)+
[00013a72] 12c7                      move.b    d7,(a1)+
[00013a74] 12c7                      move.b    d7,(a1)+
[00013a76] 12c7                      move.b    d7,(a1)+
[00013a78] 12c7                      move.b    d7,(a1)+
[00013a7a] 12c7                      move.b    d7,(a1)+
[00013a7c] 12c7                      move.b    d7,(a1)+
[00013a7e] 12c7                      move.b    d7,(a1)+
[00013a80] 12c7                      move.b    d7,(a1)+
[00013a82] 12c7                      move.b    d7,(a1)+
[00013a84] 12c7                      move.b    d7,(a1)+
[00013a86] 12c7                      move.b    d7,(a1)+
[00013a88] 12c7                      move.b    d7,(a1)+
[00013a8a] 12c7                      move.b    d7,(a1)+
[00013a8c] 12c7                      move.b    d7,(a1)+
[00013a8e] 12c7                      move.b    d7,(a1)+
[00013a90] 12c7                      move.b    d7,(a1)+
[00013a92] 12c7                      move.b    d7,(a1)+
[00013a94] 12c7                      move.b    d7,(a1)+
[00013a96] 12c7                      move.b    d7,(a1)+
[00013a98] 12c7                      move.b    d7,(a1)+
[00013a9a] 12c7                      move.b    d7,(a1)+
[00013a9c] 12c7                      move.b    d7,(a1)+
[00013a9e] 12c7                      move.b    d7,(a1)+
[00013aa0] 12c7                      move.b    d7,(a1)+
[00013aa2] 51ce ffbe                 dbf       d6,$00013A62
[00013aa6] d2cb                      adda.w    a3,a1
[00013aa8] 51cd ffb4                 dbf       d5,$00013A5E
[00013aac] 4e75                      rts
[00013aae] 49fb 0006                 lea.l     $00013AB6(pc,d0.w),a4
[00013ab2] 3c04                      move.w    d4,d6
[00013ab4] 4ed4                      jmp       (a4)
[00013ab6] 1018                      move.b    (a0)+,d0
[00013ab8] c119                      and.b     d0,(a1)+
[00013aba] 1018                      move.b    (a0)+,d0
[00013abc] c119                      and.b     d0,(a1)+
[00013abe] 1018                      move.b    (a0)+,d0
[00013ac0] c119                      and.b     d0,(a1)+
[00013ac2] 1018                      move.b    (a0)+,d0
[00013ac4] c119                      and.b     d0,(a1)+
[00013ac6] 1018                      move.b    (a0)+,d0
[00013ac8] c119                      and.b     d0,(a1)+
[00013aca] 1018                      move.b    (a0)+,d0
[00013acc] c119                      and.b     d0,(a1)+
[00013ace] 1018                      move.b    (a0)+,d0
[00013ad0] c119                      and.b     d0,(a1)+
[00013ad2] 1018                      move.b    (a0)+,d0
[00013ad4] c119                      and.b     d0,(a1)+
[00013ad6] 1018                      move.b    (a0)+,d0
[00013ad8] c119                      and.b     d0,(a1)+
[00013ada] 1018                      move.b    (a0)+,d0
[00013adc] c119                      and.b     d0,(a1)+
[00013ade] 1018                      move.b    (a0)+,d0
[00013ae0] c119                      and.b     d0,(a1)+
[00013ae2] 1018                      move.b    (a0)+,d0
[00013ae4] c119                      and.b     d0,(a1)+
[00013ae6] 1018                      move.b    (a0)+,d0
[00013ae8] c119                      and.b     d0,(a1)+
[00013aea] 1018                      move.b    (a0)+,d0
[00013aec] c119                      and.b     d0,(a1)+
[00013aee] 1018                      move.b    (a0)+,d0
[00013af0] c119                      and.b     d0,(a1)+
[00013af2] 1018                      move.b    (a0)+,d0
[00013af4] c119                      and.b     d0,(a1)+
[00013af6] 1018                      move.b    (a0)+,d0
[00013af8] c119                      and.b     d0,(a1)+
[00013afa] 1018                      move.b    (a0)+,d0
[00013afc] c119                      and.b     d0,(a1)+
[00013afe] 1018                      move.b    (a0)+,d0
[00013b00] c119                      and.b     d0,(a1)+
[00013b02] 1018                      move.b    (a0)+,d0
[00013b04] c119                      and.b     d0,(a1)+
[00013b06] 1018                      move.b    (a0)+,d0
[00013b08] c119                      and.b     d0,(a1)+
[00013b0a] 1018                      move.b    (a0)+,d0
[00013b0c] c119                      and.b     d0,(a1)+
[00013b0e] 1018                      move.b    (a0)+,d0
[00013b10] c119                      and.b     d0,(a1)+
[00013b12] 1018                      move.b    (a0)+,d0
[00013b14] c119                      and.b     d0,(a1)+
[00013b16] 1018                      move.b    (a0)+,d0
[00013b18] c119                      and.b     d0,(a1)+
[00013b1a] 1018                      move.b    (a0)+,d0
[00013b1c] c119                      and.b     d0,(a1)+
[00013b1e] 1018                      move.b    (a0)+,d0
[00013b20] c119                      and.b     d0,(a1)+
[00013b22] 1018                      move.b    (a0)+,d0
[00013b24] c119                      and.b     d0,(a1)+
[00013b26] 1018                      move.b    (a0)+,d0
[00013b28] c119                      and.b     d0,(a1)+
[00013b2a] 1018                      move.b    (a0)+,d0
[00013b2c] c119                      and.b     d0,(a1)+
[00013b2e] 1018                      move.b    (a0)+,d0
[00013b30] c119                      and.b     d0,(a1)+
[00013b32] 1018                      move.b    (a0)+,d0
[00013b34] c119                      and.b     d0,(a1)+
[00013b36] 51ce ff7e                 dbf       d6,$00013AB6
[00013b3a] d0ca                      adda.w    a2,a0
[00013b3c] d2cb                      adda.w    a3,a1
[00013b3e] 51cd ff72                 dbf       d5,$00013AB2
[00013b42] 4e75                      rts
[00013b44] 49fb 0006                 lea.l     $00013B4C(pc,d0.w),a4
[00013b48] 3c04                      move.w    d4,d6
[00013b4a] 4ed4                      jmp       (a4)
[00013b4c] 1018                      move.b    (a0)+,d0
[00013b4e] 4611                      not.b     (a1)
[00013b50] c119                      and.b     d0,(a1)+
[00013b52] 1018                      move.b    (a0)+,d0
[00013b54] 4611                      not.b     (a1)
[00013b56] c119                      and.b     d0,(a1)+
[00013b58] 1018                      move.b    (a0)+,d0
[00013b5a] 4611                      not.b     (a1)
[00013b5c] c119                      and.b     d0,(a1)+
[00013b5e] 1018                      move.b    (a0)+,d0
[00013b60] 4611                      not.b     (a1)
[00013b62] c119                      and.b     d0,(a1)+
[00013b64] 1018                      move.b    (a0)+,d0
[00013b66] 4611                      not.b     (a1)
[00013b68] c119                      and.b     d0,(a1)+
[00013b6a] 1018                      move.b    (a0)+,d0
[00013b6c] 4611                      not.b     (a1)
[00013b6e] c119                      and.b     d0,(a1)+
[00013b70] 1018                      move.b    (a0)+,d0
[00013b72] 4611                      not.b     (a1)
[00013b74] c119                      and.b     d0,(a1)+
[00013b76] 1018                      move.b    (a0)+,d0
[00013b78] 4611                      not.b     (a1)
[00013b7a] c119                      and.b     d0,(a1)+
[00013b7c] 1018                      move.b    (a0)+,d0
[00013b7e] 4611                      not.b     (a1)
[00013b80] c119                      and.b     d0,(a1)+
[00013b82] 1018                      move.b    (a0)+,d0
[00013b84] 4611                      not.b     (a1)
[00013b86] c119                      and.b     d0,(a1)+
[00013b88] 1018                      move.b    (a0)+,d0
[00013b8a] 4611                      not.b     (a1)
[00013b8c] c119                      and.b     d0,(a1)+
[00013b8e] 1018                      move.b    (a0)+,d0
[00013b90] 4611                      not.b     (a1)
[00013b92] c119                      and.b     d0,(a1)+
[00013b94] 1018                      move.b    (a0)+,d0
[00013b96] 4611                      not.b     (a1)
[00013b98] c119                      and.b     d0,(a1)+
[00013b9a] 1018                      move.b    (a0)+,d0
[00013b9c] 4611                      not.b     (a1)
[00013b9e] c119                      and.b     d0,(a1)+
[00013ba0] 1018                      move.b    (a0)+,d0
[00013ba2] 4611                      not.b     (a1)
[00013ba4] c119                      and.b     d0,(a1)+
[00013ba6] 1018                      move.b    (a0)+,d0
[00013ba8] 4611                      not.b     (a1)
[00013baa] c119                      and.b     d0,(a1)+
[00013bac] 1018                      move.b    (a0)+,d0
[00013bae] 4611                      not.b     (a1)
[00013bb0] c119                      and.b     d0,(a1)+
[00013bb2] 1018                      move.b    (a0)+,d0
[00013bb4] 4611                      not.b     (a1)
[00013bb6] c119                      and.b     d0,(a1)+
[00013bb8] 1018                      move.b    (a0)+,d0
[00013bba] 4611                      not.b     (a1)
[00013bbc] c119                      and.b     d0,(a1)+
[00013bbe] 1018                      move.b    (a0)+,d0
[00013bc0] 4611                      not.b     (a1)
[00013bc2] c119                      and.b     d0,(a1)+
[00013bc4] 1018                      move.b    (a0)+,d0
[00013bc6] 4611                      not.b     (a1)
[00013bc8] c119                      and.b     d0,(a1)+
[00013bca] 1018                      move.b    (a0)+,d0
[00013bcc] 4611                      not.b     (a1)
[00013bce] c119                      and.b     d0,(a1)+
[00013bd0] 1018                      move.b    (a0)+,d0
[00013bd2] 4611                      not.b     (a1)
[00013bd4] c119                      and.b     d0,(a1)+
[00013bd6] 1018                      move.b    (a0)+,d0
[00013bd8] 4611                      not.b     (a1)
[00013bda] c119                      and.b     d0,(a1)+
[00013bdc] 1018                      move.b    (a0)+,d0
[00013bde] 4611                      not.b     (a1)
[00013be0] c119                      and.b     d0,(a1)+
[00013be2] 1018                      move.b    (a0)+,d0
[00013be4] 4611                      not.b     (a1)
[00013be6] c119                      and.b     d0,(a1)+
[00013be8] 1018                      move.b    (a0)+,d0
[00013bea] 4611                      not.b     (a1)
[00013bec] c119                      and.b     d0,(a1)+
[00013bee] 1018                      move.b    (a0)+,d0
[00013bf0] 4611                      not.b     (a1)
[00013bf2] c119                      and.b     d0,(a1)+
[00013bf4] 1018                      move.b    (a0)+,d0
[00013bf6] 4611                      not.b     (a1)
[00013bf8] c119                      and.b     d0,(a1)+
[00013bfa] 1018                      move.b    (a0)+,d0
[00013bfc] 4611                      not.b     (a1)
[00013bfe] c119                      and.b     d0,(a1)+
[00013c00] 1018                      move.b    (a0)+,d0
[00013c02] 4611                      not.b     (a1)
[00013c04] c119                      and.b     d0,(a1)+
[00013c06] 1018                      move.b    (a0)+,d0
[00013c08] 4611                      not.b     (a1)
[00013c0a] c119                      and.b     d0,(a1)+
[00013c0c] 51ce ff3e                 dbf       d6,$00013B4C
[00013c10] d0ca                      adda.w    a2,a0
[00013c12] d2cb                      adda.w    a3,a1
[00013c14] 51cd ff32                 dbf       d5,$00013B48
[00013c18] 4e75                      rts
[00013c1a] 49fb 0006                 lea.l     $00013C22(pc,d0.w),a4
[00013c1e] 3c04                      move.w    d4,d6
[00013c20] 4ed4                      jmp       (a4)
[00013c22] 12d8                      move.b    (a0)+,(a1)+
[00013c24] 12d8                      move.b    (a0)+,(a1)+
[00013c26] 12d8                      move.b    (a0)+,(a1)+
[00013c28] 12d8                      move.b    (a0)+,(a1)+
[00013c2a] 12d8                      move.b    (a0)+,(a1)+
[00013c2c] 12d8                      move.b    (a0)+,(a1)+
[00013c2e] 12d8                      move.b    (a0)+,(a1)+
[00013c30] 12d8                      move.b    (a0)+,(a1)+
[00013c32] 12d8                      move.b    (a0)+,(a1)+
[00013c34] 12d8                      move.b    (a0)+,(a1)+
[00013c36] 12d8                      move.b    (a0)+,(a1)+
[00013c38] 12d8                      move.b    (a0)+,(a1)+
[00013c3a] 12d8                      move.b    (a0)+,(a1)+
[00013c3c] 12d8                      move.b    (a0)+,(a1)+
[00013c3e] 12d8                      move.b    (a0)+,(a1)+
[00013c40] 12d8                      move.b    (a0)+,(a1)+
[00013c42] 12d8                      move.b    (a0)+,(a1)+
[00013c44] 12d8                      move.b    (a0)+,(a1)+
[00013c46] 12d8                      move.b    (a0)+,(a1)+
[00013c48] 12d8                      move.b    (a0)+,(a1)+
[00013c4a] 12d8                      move.b    (a0)+,(a1)+
[00013c4c] 12d8                      move.b    (a0)+,(a1)+
[00013c4e] 12d8                      move.b    (a0)+,(a1)+
[00013c50] 12d8                      move.b    (a0)+,(a1)+
[00013c52] 12d8                      move.b    (a0)+,(a1)+
[00013c54] 12d8                      move.b    (a0)+,(a1)+
[00013c56] 12d8                      move.b    (a0)+,(a1)+
[00013c58] 12d8                      move.b    (a0)+,(a1)+
[00013c5a] 12d8                      move.b    (a0)+,(a1)+
[00013c5c] 12d8                      move.b    (a0)+,(a1)+
[00013c5e] 12d8                      move.b    (a0)+,(a1)+
[00013c60] 12d8                      move.b    (a0)+,(a1)+
[00013c62] 51ce ffbe                 dbf       d6,$00013C22
[00013c66] d0ca                      adda.w    a2,a0
[00013c68] d2cb                      adda.w    a3,a1
[00013c6a] 51cd ffb2                 dbf       d5,$00013C1E
[00013c6e] 4e75                      rts
[00013c70] 49fb 0006                 lea.l     $00013C78(pc,d0.w),a4
[00013c74] 3c04                      move.w    d4,d6
[00013c76] 4ed4                      jmp       (a4)
[00013c78] 1018                      move.b    (a0)+,d0
[00013c7a] 4600                      not.b     d0
[00013c7c] c119                      and.b     d0,(a1)+
[00013c7e] 1018                      move.b    (a0)+,d0
[00013c80] 4600                      not.b     d0
[00013c82] c119                      and.b     d0,(a1)+
[00013c84] 1018                      move.b    (a0)+,d0
[00013c86] 4600                      not.b     d0
[00013c88] c119                      and.b     d0,(a1)+
[00013c8a] 1018                      move.b    (a0)+,d0
[00013c8c] 4600                      not.b     d0
[00013c8e] c119                      and.b     d0,(a1)+
[00013c90] 1018                      move.b    (a0)+,d0
[00013c92] 4600                      not.b     d0
[00013c94] c119                      and.b     d0,(a1)+
[00013c96] 1018                      move.b    (a0)+,d0
[00013c98] 4600                      not.b     d0
[00013c9a] c119                      and.b     d0,(a1)+
[00013c9c] 1018                      move.b    (a0)+,d0
[00013c9e] 4600                      not.b     d0
[00013ca0] c119                      and.b     d0,(a1)+
[00013ca2] 1018                      move.b    (a0)+,d0
[00013ca4] 4600                      not.b     d0
[00013ca6] c119                      and.b     d0,(a1)+
[00013ca8] 1018                      move.b    (a0)+,d0
[00013caa] 4600                      not.b     d0
[00013cac] c119                      and.b     d0,(a1)+
[00013cae] 1018                      move.b    (a0)+,d0
[00013cb0] 4600                      not.b     d0
[00013cb2] c119                      and.b     d0,(a1)+
[00013cb4] 1018                      move.b    (a0)+,d0
[00013cb6] 4600                      not.b     d0
[00013cb8] c119                      and.b     d0,(a1)+
[00013cba] 1018                      move.b    (a0)+,d0
[00013cbc] 4600                      not.b     d0
[00013cbe] c119                      and.b     d0,(a1)+
[00013cc0] 1018                      move.b    (a0)+,d0
[00013cc2] 4600                      not.b     d0
[00013cc4] c119                      and.b     d0,(a1)+
[00013cc6] 1018                      move.b    (a0)+,d0
[00013cc8] 4600                      not.b     d0
[00013cca] c119                      and.b     d0,(a1)+
[00013ccc] 1018                      move.b    (a0)+,d0
[00013cce] 4600                      not.b     d0
[00013cd0] c119                      and.b     d0,(a1)+
[00013cd2] 1018                      move.b    (a0)+,d0
[00013cd4] 4600                      not.b     d0
[00013cd6] c119                      and.b     d0,(a1)+
[00013cd8] 1018                      move.b    (a0)+,d0
[00013cda] 4600                      not.b     d0
[00013cdc] c119                      and.b     d0,(a1)+
[00013cde] 1018                      move.b    (a0)+,d0
[00013ce0] 4600                      not.b     d0
[00013ce2] c119                      and.b     d0,(a1)+
[00013ce4] 1018                      move.b    (a0)+,d0
[00013ce6] 4600                      not.b     d0
[00013ce8] c119                      and.b     d0,(a1)+
[00013cea] 1018                      move.b    (a0)+,d0
[00013cec] 4600                      not.b     d0
[00013cee] c119                      and.b     d0,(a1)+
[00013cf0] 1018                      move.b    (a0)+,d0
[00013cf2] 4600                      not.b     d0
[00013cf4] c119                      and.b     d0,(a1)+
[00013cf6] 1018                      move.b    (a0)+,d0
[00013cf8] 4600                      not.b     d0
[00013cfa] c119                      and.b     d0,(a1)+
[00013cfc] 1018                      move.b    (a0)+,d0
[00013cfe] 4600                      not.b     d0
[00013d00] c119                      and.b     d0,(a1)+
[00013d02] 1018                      move.b    (a0)+,d0
[00013d04] 4600                      not.b     d0
[00013d06] c119                      and.b     d0,(a1)+
[00013d08] 1018                      move.b    (a0)+,d0
[00013d0a] 4600                      not.b     d0
[00013d0c] c119                      and.b     d0,(a1)+
[00013d0e] 1018                      move.b    (a0)+,d0
[00013d10] 4600                      not.b     d0
[00013d12] c119                      and.b     d0,(a1)+
[00013d14] 1018                      move.b    (a0)+,d0
[00013d16] 4600                      not.b     d0
[00013d18] c119                      and.b     d0,(a1)+
[00013d1a] 1018                      move.b    (a0)+,d0
[00013d1c] 4600                      not.b     d0
[00013d1e] c119                      and.b     d0,(a1)+
[00013d20] 1018                      move.b    (a0)+,d0
[00013d22] 4600                      not.b     d0
[00013d24] c119                      and.b     d0,(a1)+
[00013d26] 1018                      move.b    (a0)+,d0
[00013d28] 4600                      not.b     d0
[00013d2a] c119                      and.b     d0,(a1)+
[00013d2c] 1018                      move.b    (a0)+,d0
[00013d2e] 4600                      not.b     d0
[00013d30] c119                      and.b     d0,(a1)+
[00013d32] 1018                      move.b    (a0)+,d0
[00013d34] 4600                      not.b     d0
[00013d36] c119                      and.b     d0,(a1)+
[00013d38] 51ce ff3e                 dbf       d6,$00013C78
[00013d3c] d0ca                      adda.w    a2,a0
[00013d3e] d2cb                      adda.w    a3,a1
[00013d40] 51cd ff32                 dbf       d5,$00013C74
[00013d44] 4e75                      rts
[00013d46] 49fb 0006                 lea.l     $00013D4E(pc,d0.w),a4
[00013d4a] 3c04                      move.w    d4,d6
[00013d4c] 4ed4                      jmp       (a4)
[00013d4e] 1018                      move.b    (a0)+,d0
[00013d50] b119                      eor.b     d0,(a1)+
[00013d52] 1018                      move.b    (a0)+,d0
[00013d54] b119                      eor.b     d0,(a1)+
[00013d56] 1018                      move.b    (a0)+,d0
[00013d58] b119                      eor.b     d0,(a1)+
[00013d5a] 1018                      move.b    (a0)+,d0
[00013d5c] b119                      eor.b     d0,(a1)+
[00013d5e] 1018                      move.b    (a0)+,d0
[00013d60] b119                      eor.b     d0,(a1)+
[00013d62] 1018                      move.b    (a0)+,d0
[00013d64] b119                      eor.b     d0,(a1)+
[00013d66] 1018                      move.b    (a0)+,d0
[00013d68] b119                      eor.b     d0,(a1)+
[00013d6a] 1018                      move.b    (a0)+,d0
[00013d6c] b119                      eor.b     d0,(a1)+
[00013d6e] 1018                      move.b    (a0)+,d0
[00013d70] b119                      eor.b     d0,(a1)+
[00013d72] 1018                      move.b    (a0)+,d0
[00013d74] b119                      eor.b     d0,(a1)+
[00013d76] 1018                      move.b    (a0)+,d0
[00013d78] b119                      eor.b     d0,(a1)+
[00013d7a] 1018                      move.b    (a0)+,d0
[00013d7c] b119                      eor.b     d0,(a1)+
[00013d7e] 1018                      move.b    (a0)+,d0
[00013d80] b119                      eor.b     d0,(a1)+
[00013d82] 1018                      move.b    (a0)+,d0
[00013d84] b119                      eor.b     d0,(a1)+
[00013d86] 1018                      move.b    (a0)+,d0
[00013d88] b119                      eor.b     d0,(a1)+
[00013d8a] 1018                      move.b    (a0)+,d0
[00013d8c] b119                      eor.b     d0,(a1)+
[00013d8e] 1018                      move.b    (a0)+,d0
[00013d90] b119                      eor.b     d0,(a1)+
[00013d92] 1018                      move.b    (a0)+,d0
[00013d94] b119                      eor.b     d0,(a1)+
[00013d96] 1018                      move.b    (a0)+,d0
[00013d98] b119                      eor.b     d0,(a1)+
[00013d9a] 1018                      move.b    (a0)+,d0
[00013d9c] b119                      eor.b     d0,(a1)+
[00013d9e] 1018                      move.b    (a0)+,d0
[00013da0] b119                      eor.b     d0,(a1)+
[00013da2] 1018                      move.b    (a0)+,d0
[00013da4] b119                      eor.b     d0,(a1)+
[00013da6] 1018                      move.b    (a0)+,d0
[00013da8] b119                      eor.b     d0,(a1)+
[00013daa] 1018                      move.b    (a0)+,d0
[00013dac] b119                      eor.b     d0,(a1)+
[00013dae] 1018                      move.b    (a0)+,d0
[00013db0] b119                      eor.b     d0,(a1)+
[00013db2] 1018                      move.b    (a0)+,d0
[00013db4] b119                      eor.b     d0,(a1)+
[00013db6] 1018                      move.b    (a0)+,d0
[00013db8] b119                      eor.b     d0,(a1)+
[00013dba] 1018                      move.b    (a0)+,d0
[00013dbc] b119                      eor.b     d0,(a1)+
[00013dbe] 1018                      move.b    (a0)+,d0
[00013dc0] b119                      eor.b     d0,(a1)+
[00013dc2] 1018                      move.b    (a0)+,d0
[00013dc4] b119                      eor.b     d0,(a1)+
[00013dc6] 1018                      move.b    (a0)+,d0
[00013dc8] b119                      eor.b     d0,(a1)+
[00013dca] 1018                      move.b    (a0)+,d0
[00013dcc] b119                      eor.b     d0,(a1)+
[00013dce] 51ce ff7e                 dbf       d6,$00013D4E
[00013dd2] d0ca                      adda.w    a2,a0
[00013dd4] d2cb                      adda.w    a3,a1
[00013dd6] 51cd ff72                 dbf       d5,$00013D4A
[00013dda] 4e75                      rts
[00013ddc] 49fb 0006                 lea.l     $00013DE4(pc,d0.w),a4
[00013de0] 3c04                      move.w    d4,d6
[00013de2] 4ed4                      jmp       (a4)
[00013de4] 1018                      move.b    (a0)+,d0
[00013de6] 8119                      or.b      d0,(a1)+
[00013de8] 1018                      move.b    (a0)+,d0
[00013dea] 8119                      or.b      d0,(a1)+
[00013dec] 1018                      move.b    (a0)+,d0
[00013dee] 8119                      or.b      d0,(a1)+
[00013df0] 1018                      move.b    (a0)+,d0
[00013df2] 8119                      or.b      d0,(a1)+
[00013df4] 1018                      move.b    (a0)+,d0
[00013df6] 8119                      or.b      d0,(a1)+
[00013df8] 1018                      move.b    (a0)+,d0
[00013dfa] 8119                      or.b      d0,(a1)+
[00013dfc] 1018                      move.b    (a0)+,d0
[00013dfe] 8119                      or.b      d0,(a1)+
[00013e00] 1018                      move.b    (a0)+,d0
[00013e02] 8119                      or.b      d0,(a1)+
[00013e04] 1018                      move.b    (a0)+,d0
[00013e06] 8119                      or.b      d0,(a1)+
[00013e08] 1018                      move.b    (a0)+,d0
[00013e0a] 8119                      or.b      d0,(a1)+
[00013e0c] 1018                      move.b    (a0)+,d0
[00013e0e] 8119                      or.b      d0,(a1)+
[00013e10] 1018                      move.b    (a0)+,d0
[00013e12] 8119                      or.b      d0,(a1)+
[00013e14] 1018                      move.b    (a0)+,d0
[00013e16] 8119                      or.b      d0,(a1)+
[00013e18] 1018                      move.b    (a0)+,d0
[00013e1a] 8119                      or.b      d0,(a1)+
[00013e1c] 1018                      move.b    (a0)+,d0
[00013e1e] 8119                      or.b      d0,(a1)+
[00013e20] 1018                      move.b    (a0)+,d0
[00013e22] 8119                      or.b      d0,(a1)+
[00013e24] 1018                      move.b    (a0)+,d0
[00013e26] 8119                      or.b      d0,(a1)+
[00013e28] 1018                      move.b    (a0)+,d0
[00013e2a] 8119                      or.b      d0,(a1)+
[00013e2c] 1018                      move.b    (a0)+,d0
[00013e2e] 8119                      or.b      d0,(a1)+
[00013e30] 1018                      move.b    (a0)+,d0
[00013e32] 8119                      or.b      d0,(a1)+
[00013e34] 1018                      move.b    (a0)+,d0
[00013e36] 8119                      or.b      d0,(a1)+
[00013e38] 1018                      move.b    (a0)+,d0
[00013e3a] 8119                      or.b      d0,(a1)+
[00013e3c] 1018                      move.b    (a0)+,d0
[00013e3e] 8119                      or.b      d0,(a1)+
[00013e40] 1018                      move.b    (a0)+,d0
[00013e42] 8119                      or.b      d0,(a1)+
[00013e44] 1018                      move.b    (a0)+,d0
[00013e46] 8119                      or.b      d0,(a1)+
[00013e48] 1018                      move.b    (a0)+,d0
[00013e4a] 8119                      or.b      d0,(a1)+
[00013e4c] 1018                      move.b    (a0)+,d0
[00013e4e] 8119                      or.b      d0,(a1)+
[00013e50] 1018                      move.b    (a0)+,d0
[00013e52] 8119                      or.b      d0,(a1)+
[00013e54] 1018                      move.b    (a0)+,d0
[00013e56] 8119                      or.b      d0,(a1)+
[00013e58] 1018                      move.b    (a0)+,d0
[00013e5a] 8119                      or.b      d0,(a1)+
[00013e5c] 1018                      move.b    (a0)+,d0
[00013e5e] 8119                      or.b      d0,(a1)+
[00013e60] 1018                      move.b    (a0)+,d0
[00013e62] 8119                      or.b      d0,(a1)+
[00013e64] 51ce ff7e                 dbf       d6,$00013DE4
[00013e68] d0ca                      adda.w    a2,a0
[00013e6a] d2cb                      adda.w    a3,a1
[00013e6c] 51cd ff72                 dbf       d5,$00013DE0
[00013e70] 4e75                      rts
[00013e72] 49fb 0006                 lea.l     $00013E7A(pc,d0.w),a4
[00013e76] 3c04                      move.w    d4,d6
[00013e78] 4ed4                      jmp       (a4)
[00013e7a] 1018                      move.b    (a0)+,d0
[00013e7c] 8111                      or.b      d0,(a1)
[00013e7e] 4619                      not.b     (a1)+
[00013e80] 1018                      move.b    (a0)+,d0
[00013e82] 8111                      or.b      d0,(a1)
[00013e84] 4619                      not.b     (a1)+
[00013e86] 1018                      move.b    (a0)+,d0
[00013e88] 8111                      or.b      d0,(a1)
[00013e8a] 4619                      not.b     (a1)+
[00013e8c] 1018                      move.b    (a0)+,d0
[00013e8e] 8111                      or.b      d0,(a1)
[00013e90] 4619                      not.b     (a1)+
[00013e92] 1018                      move.b    (a0)+,d0
[00013e94] 8111                      or.b      d0,(a1)
[00013e96] 4619                      not.b     (a1)+
[00013e98] 1018                      move.b    (a0)+,d0
[00013e9a] 8111                      or.b      d0,(a1)
[00013e9c] 4619                      not.b     (a1)+
[00013e9e] 1018                      move.b    (a0)+,d0
[00013ea0] 8111                      or.b      d0,(a1)
[00013ea2] 4619                      not.b     (a1)+
[00013ea4] 1018                      move.b    (a0)+,d0
[00013ea6] 8111                      or.b      d0,(a1)
[00013ea8] 4619                      not.b     (a1)+
[00013eaa] 1018                      move.b    (a0)+,d0
[00013eac] 8111                      or.b      d0,(a1)
[00013eae] 4619                      not.b     (a1)+
[00013eb0] 1018                      move.b    (a0)+,d0
[00013eb2] 8111                      or.b      d0,(a1)
[00013eb4] 4619                      not.b     (a1)+
[00013eb6] 1018                      move.b    (a0)+,d0
[00013eb8] 8111                      or.b      d0,(a1)
[00013eba] 4619                      not.b     (a1)+
[00013ebc] 1018                      move.b    (a0)+,d0
[00013ebe] 8111                      or.b      d0,(a1)
[00013ec0] 4619                      not.b     (a1)+
[00013ec2] 1018                      move.b    (a0)+,d0
[00013ec4] 8111                      or.b      d0,(a1)
[00013ec6] 4619                      not.b     (a1)+
[00013ec8] 1018                      move.b    (a0)+,d0
[00013eca] 8111                      or.b      d0,(a1)
[00013ecc] 4619                      not.b     (a1)+
[00013ece] 1018                      move.b    (a0)+,d0
[00013ed0] 8111                      or.b      d0,(a1)
[00013ed2] 4619                      not.b     (a1)+
[00013ed4] 1018                      move.b    (a0)+,d0
[00013ed6] 8111                      or.b      d0,(a1)
[00013ed8] 4619                      not.b     (a1)+
[00013eda] 1018                      move.b    (a0)+,d0
[00013edc] 8111                      or.b      d0,(a1)
[00013ede] 4619                      not.b     (a1)+
[00013ee0] 1018                      move.b    (a0)+,d0
[00013ee2] 8111                      or.b      d0,(a1)
[00013ee4] 4619                      not.b     (a1)+
[00013ee6] 1018                      move.b    (a0)+,d0
[00013ee8] 8111                      or.b      d0,(a1)
[00013eea] 4619                      not.b     (a1)+
[00013eec] 1018                      move.b    (a0)+,d0
[00013eee] 8111                      or.b      d0,(a1)
[00013ef0] 4619                      not.b     (a1)+
[00013ef2] 1018                      move.b    (a0)+,d0
[00013ef4] 8111                      or.b      d0,(a1)
[00013ef6] 4619                      not.b     (a1)+
[00013ef8] 1018                      move.b    (a0)+,d0
[00013efa] 8111                      or.b      d0,(a1)
[00013efc] 4619                      not.b     (a1)+
[00013efe] 1018                      move.b    (a0)+,d0
[00013f00] 8111                      or.b      d0,(a1)
[00013f02] 4619                      not.b     (a1)+
[00013f04] 1018                      move.b    (a0)+,d0
[00013f06] 8111                      or.b      d0,(a1)
[00013f08] 4619                      not.b     (a1)+
[00013f0a] 1018                      move.b    (a0)+,d0
[00013f0c] 8111                      or.b      d0,(a1)
[00013f0e] 4619                      not.b     (a1)+
[00013f10] 1018                      move.b    (a0)+,d0
[00013f12] 8111                      or.b      d0,(a1)
[00013f14] 4619                      not.b     (a1)+
[00013f16] 1018                      move.b    (a0)+,d0
[00013f18] 8111                      or.b      d0,(a1)
[00013f1a] 4619                      not.b     (a1)+
[00013f1c] 1018                      move.b    (a0)+,d0
[00013f1e] 8111                      or.b      d0,(a1)
[00013f20] 4619                      not.b     (a1)+
[00013f22] 1018                      move.b    (a0)+,d0
[00013f24] 8111                      or.b      d0,(a1)
[00013f26] 4619                      not.b     (a1)+
[00013f28] 1018                      move.b    (a0)+,d0
[00013f2a] 8111                      or.b      d0,(a1)
[00013f2c] 4619                      not.b     (a1)+
[00013f2e] 1018                      move.b    (a0)+,d0
[00013f30] 8111                      or.b      d0,(a1)
[00013f32] 4619                      not.b     (a1)+
[00013f34] 1018                      move.b    (a0)+,d0
[00013f36] 8111                      or.b      d0,(a1)
[00013f38] 4619                      not.b     (a1)+
[00013f3a] 51ce ff3e                 dbf       d6,$00013E7A
[00013f3e] d0ca                      adda.w    a2,a0
[00013f40] d2cb                      adda.w    a3,a1
[00013f42] 51cd ff32                 dbf       d5,$00013E76
[00013f46] 4e75                      rts
[00013f48] 49fb 0006                 lea.l     $00013F50(pc,d0.w),a4
[00013f4c] 3c04                      move.w    d4,d6
[00013f4e] 4ed4                      jmp       (a4)
[00013f50] 1018                      move.b    (a0)+,d0
[00013f52] b111                      eor.b     d0,(a1)
[00013f54] 4619                      not.b     (a1)+
[00013f56] 1018                      move.b    (a0)+,d0
[00013f58] b111                      eor.b     d0,(a1)
[00013f5a] 4619                      not.b     (a1)+
[00013f5c] 1018                      move.b    (a0)+,d0
[00013f5e] b111                      eor.b     d0,(a1)
[00013f60] 4619                      not.b     (a1)+
[00013f62] 1018                      move.b    (a0)+,d0
[00013f64] b111                      eor.b     d0,(a1)
[00013f66] 4619                      not.b     (a1)+
[00013f68] 1018                      move.b    (a0)+,d0
[00013f6a] b111                      eor.b     d0,(a1)
[00013f6c] 4619                      not.b     (a1)+
[00013f6e] 1018                      move.b    (a0)+,d0
[00013f70] b111                      eor.b     d0,(a1)
[00013f72] 4619                      not.b     (a1)+
[00013f74] 1018                      move.b    (a0)+,d0
[00013f76] b111                      eor.b     d0,(a1)
[00013f78] 4619                      not.b     (a1)+
[00013f7a] 1018                      move.b    (a0)+,d0
[00013f7c] b111                      eor.b     d0,(a1)
[00013f7e] 4619                      not.b     (a1)+
[00013f80] 1018                      move.b    (a0)+,d0
[00013f82] b111                      eor.b     d0,(a1)
[00013f84] 4619                      not.b     (a1)+
[00013f86] 1018                      move.b    (a0)+,d0
[00013f88] b111                      eor.b     d0,(a1)
[00013f8a] 4619                      not.b     (a1)+
[00013f8c] 1018                      move.b    (a0)+,d0
[00013f8e] b111                      eor.b     d0,(a1)
[00013f90] 4619                      not.b     (a1)+
[00013f92] 1018                      move.b    (a0)+,d0
[00013f94] b111                      eor.b     d0,(a1)
[00013f96] 4619                      not.b     (a1)+
[00013f98] 1018                      move.b    (a0)+,d0
[00013f9a] b111                      eor.b     d0,(a1)
[00013f9c] 4619                      not.b     (a1)+
[00013f9e] 1018                      move.b    (a0)+,d0
[00013fa0] b111                      eor.b     d0,(a1)
[00013fa2] 4619                      not.b     (a1)+
[00013fa4] 1018                      move.b    (a0)+,d0
[00013fa6] b111                      eor.b     d0,(a1)
[00013fa8] 4619                      not.b     (a1)+
[00013faa] 1018                      move.b    (a0)+,d0
[00013fac] b111                      eor.b     d0,(a1)
[00013fae] 4619                      not.b     (a1)+
[00013fb0] 1018                      move.b    (a0)+,d0
[00013fb2] b111                      eor.b     d0,(a1)
[00013fb4] 4619                      not.b     (a1)+
[00013fb6] 1018                      move.b    (a0)+,d0
[00013fb8] b111                      eor.b     d0,(a1)
[00013fba] 4619                      not.b     (a1)+
[00013fbc] 1018                      move.b    (a0)+,d0
[00013fbe] b111                      eor.b     d0,(a1)
[00013fc0] 4619                      not.b     (a1)+
[00013fc2] 1018                      move.b    (a0)+,d0
[00013fc4] b111                      eor.b     d0,(a1)
[00013fc6] 4619                      not.b     (a1)+
[00013fc8] 1018                      move.b    (a0)+,d0
[00013fca] b111                      eor.b     d0,(a1)
[00013fcc] 4619                      not.b     (a1)+
[00013fce] 1018                      move.b    (a0)+,d0
[00013fd0] b111                      eor.b     d0,(a1)
[00013fd2] 4619                      not.b     (a1)+
[00013fd4] 1018                      move.b    (a0)+,d0
[00013fd6] b111                      eor.b     d0,(a1)
[00013fd8] 4619                      not.b     (a1)+
[00013fda] 1018                      move.b    (a0)+,d0
[00013fdc] b111                      eor.b     d0,(a1)
[00013fde] 4619                      not.b     (a1)+
[00013fe0] 1018                      move.b    (a0)+,d0
[00013fe2] b111                      eor.b     d0,(a1)
[00013fe4] 4619                      not.b     (a1)+
[00013fe6] 1018                      move.b    (a0)+,d0
[00013fe8] b111                      eor.b     d0,(a1)
[00013fea] 4619                      not.b     (a1)+
[00013fec] 1018                      move.b    (a0)+,d0
[00013fee] b111                      eor.b     d0,(a1)
[00013ff0] 4619                      not.b     (a1)+
[00013ff2] 1018                      move.b    (a0)+,d0
[00013ff4] b111                      eor.b     d0,(a1)
[00013ff6] 4619                      not.b     (a1)+
[00013ff8] 1018                      move.b    (a0)+,d0
[00013ffa] b111                      eor.b     d0,(a1)
[00013ffc] 4619                      not.b     (a1)+
[00013ffe] 1018                      move.b    (a0)+,d0
[00014000] b111                      eor.b     d0,(a1)
[00014002] 4619                      not.b     (a1)+
[00014004] 1018                      move.b    (a0)+,d0
[00014006] b111                      eor.b     d0,(a1)
[00014008] 4619                      not.b     (a1)+
[0001400a] 1018                      move.b    (a0)+,d0
[0001400c] b111                      eor.b     d0,(a1)
[0001400e] 4619                      not.b     (a1)+
[00014010] 51ce ff3e                 dbf       d6,$00013F50
[00014014] d0ca                      adda.w    a2,a0
[00014016] d2cb                      adda.w    a3,a1
[00014018] 51cd ff32                 dbf       d5,$00013F4C
[0001401c] 4e75                      rts
[0001401e] 49fb 0006                 lea.l     $00014026(pc,d0.w),a4
[00014022] 3c04                      move.w    d4,d6
[00014024] 4ed4                      jmp       (a4)
[00014026] 4619                      not.b     (a1)+
[00014028] 4619                      not.b     (a1)+
[0001402a] 4619                      not.b     (a1)+
[0001402c] 4619                      not.b     (a1)+
[0001402e] 4619                      not.b     (a1)+
[00014030] 4619                      not.b     (a1)+
[00014032] 4619                      not.b     (a1)+
[00014034] 4619                      not.b     (a1)+
[00014036] 4619                      not.b     (a1)+
[00014038] 4619                      not.b     (a1)+
[0001403a] 4619                      not.b     (a1)+
[0001403c] 4619                      not.b     (a1)+
[0001403e] 4619                      not.b     (a1)+
[00014040] 4619                      not.b     (a1)+
[00014042] 4619                      not.b     (a1)+
[00014044] 4619                      not.b     (a1)+
[00014046] 4619                      not.b     (a1)+
[00014048] 4619                      not.b     (a1)+
[0001404a] 4619                      not.b     (a1)+
[0001404c] 4619                      not.b     (a1)+
[0001404e] 4619                      not.b     (a1)+
[00014050] 4619                      not.b     (a1)+
[00014052] 4619                      not.b     (a1)+
[00014054] 4619                      not.b     (a1)+
[00014056] 4619                      not.b     (a1)+
[00014058] 4619                      not.b     (a1)+
[0001405a] 4619                      not.b     (a1)+
[0001405c] 4619                      not.b     (a1)+
[0001405e] 4619                      not.b     (a1)+
[00014060] 4619                      not.b     (a1)+
[00014062] 4619                      not.b     (a1)+
[00014064] 4619                      not.b     (a1)+
[00014066] 51ce ffbe                 dbf       d6,$00014026
[0001406a] d0ca                      adda.w    a2,a0
[0001406c] d2cb                      adda.w    a3,a1
[0001406e] 51cd ffb2                 dbf       d5,$00014022
[00014072] 4e75                      rts
[00014074] 49fb 0006                 lea.l     $0001407C(pc,d0.w),a4
[00014078] 3c04                      move.w    d4,d6
[0001407a] 4ed4                      jmp       (a4)
[0001407c] 4611                      not.b     (a1)
[0001407e] 1018                      move.b    (a0)+,d0
[00014080] 8119                      or.b      d0,(a1)+
[00014082] 4611                      not.b     (a1)
[00014084] 1018                      move.b    (a0)+,d0
[00014086] 8119                      or.b      d0,(a1)+
[00014088] 4611                      not.b     (a1)
[0001408a] 1018                      move.b    (a0)+,d0
[0001408c] 8119                      or.b      d0,(a1)+
[0001408e] 4611                      not.b     (a1)
[00014090] 1018                      move.b    (a0)+,d0
[00014092] 8119                      or.b      d0,(a1)+
[00014094] 4611                      not.b     (a1)
[00014096] 1018                      move.b    (a0)+,d0
[00014098] 8119                      or.b      d0,(a1)+
[0001409a] 4611                      not.b     (a1)
[0001409c] 1018                      move.b    (a0)+,d0
[0001409e] 8119                      or.b      d0,(a1)+
[000140a0] 4611                      not.b     (a1)
[000140a2] 1018                      move.b    (a0)+,d0
[000140a4] 8119                      or.b      d0,(a1)+
[000140a6] 4611                      not.b     (a1)
[000140a8] 1018                      move.b    (a0)+,d0
[000140aa] 8119                      or.b      d0,(a1)+
[000140ac] 4611                      not.b     (a1)
[000140ae] 1018                      move.b    (a0)+,d0
[000140b0] 8119                      or.b      d0,(a1)+
[000140b2] 4611                      not.b     (a1)
[000140b4] 1018                      move.b    (a0)+,d0
[000140b6] 8119                      or.b      d0,(a1)+
[000140b8] 4611                      not.b     (a1)
[000140ba] 1018                      move.b    (a0)+,d0
[000140bc] 8119                      or.b      d0,(a1)+
[000140be] 4611                      not.b     (a1)
[000140c0] 1018                      move.b    (a0)+,d0
[000140c2] 8119                      or.b      d0,(a1)+
[000140c4] 4611                      not.b     (a1)
[000140c6] 1018                      move.b    (a0)+,d0
[000140c8] 8119                      or.b      d0,(a1)+
[000140ca] 4611                      not.b     (a1)
[000140cc] 1018                      move.b    (a0)+,d0
[000140ce] 8119                      or.b      d0,(a1)+
[000140d0] 4611                      not.b     (a1)
[000140d2] 1018                      move.b    (a0)+,d0
[000140d4] 8119                      or.b      d0,(a1)+
[000140d6] 4611                      not.b     (a1)
[000140d8] 1018                      move.b    (a0)+,d0
[000140da] 8119                      or.b      d0,(a1)+
[000140dc] 4611                      not.b     (a1)
[000140de] 1018                      move.b    (a0)+,d0
[000140e0] 8119                      or.b      d0,(a1)+
[000140e2] 4611                      not.b     (a1)
[000140e4] 1018                      move.b    (a0)+,d0
[000140e6] 8119                      or.b      d0,(a1)+
[000140e8] 4611                      not.b     (a1)
[000140ea] 1018                      move.b    (a0)+,d0
[000140ec] 8119                      or.b      d0,(a1)+
[000140ee] 4611                      not.b     (a1)
[000140f0] 1018                      move.b    (a0)+,d0
[000140f2] 8119                      or.b      d0,(a1)+
[000140f4] 4611                      not.b     (a1)
[000140f6] 1018                      move.b    (a0)+,d0
[000140f8] 8119                      or.b      d0,(a1)+
[000140fa] 4611                      not.b     (a1)
[000140fc] 1018                      move.b    (a0)+,d0
[000140fe] 8119                      or.b      d0,(a1)+
[00014100] 4611                      not.b     (a1)
[00014102] 1018                      move.b    (a0)+,d0
[00014104] 8119                      or.b      d0,(a1)+
[00014106] 4611                      not.b     (a1)
[00014108] 1018                      move.b    (a0)+,d0
[0001410a] 8119                      or.b      d0,(a1)+
[0001410c] 4611                      not.b     (a1)
[0001410e] 1018                      move.b    (a0)+,d0
[00014110] 8119                      or.b      d0,(a1)+
[00014112] 4611                      not.b     (a1)
[00014114] 1018                      move.b    (a0)+,d0
[00014116] 8119                      or.b      d0,(a1)+
[00014118] 4611                      not.b     (a1)
[0001411a] 1018                      move.b    (a0)+,d0
[0001411c] 8119                      or.b      d0,(a1)+
[0001411e] 4611                      not.b     (a1)
[00014120] 1018                      move.b    (a0)+,d0
[00014122] 8119                      or.b      d0,(a1)+
[00014124] 4611                      not.b     (a1)
[00014126] 1018                      move.b    (a0)+,d0
[00014128] 8119                      or.b      d0,(a1)+
[0001412a] 4611                      not.b     (a1)
[0001412c] 1018                      move.b    (a0)+,d0
[0001412e] 8119                      or.b      d0,(a1)+
[00014130] 4611                      not.b     (a1)
[00014132] 1018                      move.b    (a0)+,d0
[00014134] 8119                      or.b      d0,(a1)+
[00014136] 4611                      not.b     (a1)
[00014138] 1018                      move.b    (a0)+,d0
[0001413a] 8119                      or.b      d0,(a1)+
[0001413c] 51ce ff3e                 dbf       d6,$0001407C
[00014140] d0ca                      adda.w    a2,a0
[00014142] d2cb                      adda.w    a3,a1
[00014144] 51cd ff32                 dbf       d5,$00014078
[00014148] 4e75                      rts
[0001414a] 49fb 0006                 lea.l     $00014152(pc,d0.w),a4
[0001414e] 3c04                      move.w    d4,d6
[00014150] 4ed4                      jmp       (a4)
[00014152] 1018                      move.b    (a0)+,d0
[00014154] 4600                      not.b     d0
[00014156] 12c0                      move.b    d0,(a1)+
[00014158] 1018                      move.b    (a0)+,d0
[0001415a] 4600                      not.b     d0
[0001415c] 12c0                      move.b    d0,(a1)+
[0001415e] 1018                      move.b    (a0)+,d0
[00014160] 4600                      not.b     d0
[00014162] 12c0                      move.b    d0,(a1)+
[00014164] 1018                      move.b    (a0)+,d0
[00014166] 4600                      not.b     d0
[00014168] 12c0                      move.b    d0,(a1)+
[0001416a] 1018                      move.b    (a0)+,d0
[0001416c] 4600                      not.b     d0
[0001416e] 12c0                      move.b    d0,(a1)+
[00014170] 1018                      move.b    (a0)+,d0
[00014172] 4600                      not.b     d0
[00014174] 12c0                      move.b    d0,(a1)+
[00014176] 1018                      move.b    (a0)+,d0
[00014178] 4600                      not.b     d0
[0001417a] 12c0                      move.b    d0,(a1)+
[0001417c] 1018                      move.b    (a0)+,d0
[0001417e] 4600                      not.b     d0
[00014180] 12c0                      move.b    d0,(a1)+
[00014182] 1018                      move.b    (a0)+,d0
[00014184] 4600                      not.b     d0
[00014186] 12c0                      move.b    d0,(a1)+
[00014188] 1018                      move.b    (a0)+,d0
[0001418a] 4600                      not.b     d0
[0001418c] 12c0                      move.b    d0,(a1)+
[0001418e] 1018                      move.b    (a0)+,d0
[00014190] 4600                      not.b     d0
[00014192] 12c0                      move.b    d0,(a1)+
[00014194] 1018                      move.b    (a0)+,d0
[00014196] 4600                      not.b     d0
[00014198] 12c0                      move.b    d0,(a1)+
[0001419a] 1018                      move.b    (a0)+,d0
[0001419c] 4600                      not.b     d0
[0001419e] 12c0                      move.b    d0,(a1)+
[000141a0] 1018                      move.b    (a0)+,d0
[000141a2] 4600                      not.b     d0
[000141a4] 12c0                      move.b    d0,(a1)+
[000141a6] 1018                      move.b    (a0)+,d0
[000141a8] 4600                      not.b     d0
[000141aa] 12c0                      move.b    d0,(a1)+
[000141ac] 1018                      move.b    (a0)+,d0
[000141ae] 4600                      not.b     d0
[000141b0] 12c0                      move.b    d0,(a1)+
[000141b2] 1018                      move.b    (a0)+,d0
[000141b4] 4600                      not.b     d0
[000141b6] 12c0                      move.b    d0,(a1)+
[000141b8] 1018                      move.b    (a0)+,d0
[000141ba] 4600                      not.b     d0
[000141bc] 12c0                      move.b    d0,(a1)+
[000141be] 1018                      move.b    (a0)+,d0
[000141c0] 4600                      not.b     d0
[000141c2] 12c0                      move.b    d0,(a1)+
[000141c4] 1018                      move.b    (a0)+,d0
[000141c6] 4600                      not.b     d0
[000141c8] 12c0                      move.b    d0,(a1)+
[000141ca] 1018                      move.b    (a0)+,d0
[000141cc] 4600                      not.b     d0
[000141ce] 12c0                      move.b    d0,(a1)+
[000141d0] 1018                      move.b    (a0)+,d0
[000141d2] 4600                      not.b     d0
[000141d4] 12c0                      move.b    d0,(a1)+
[000141d6] 1018                      move.b    (a0)+,d0
[000141d8] 4600                      not.b     d0
[000141da] 12c0                      move.b    d0,(a1)+
[000141dc] 1018                      move.b    (a0)+,d0
[000141de] 4600                      not.b     d0
[000141e0] 12c0                      move.b    d0,(a1)+
[000141e2] 1018                      move.b    (a0)+,d0
[000141e4] 4600                      not.b     d0
[000141e6] 12c0                      move.b    d0,(a1)+
[000141e8] 1018                      move.b    (a0)+,d0
[000141ea] 4600                      not.b     d0
[000141ec] 12c0                      move.b    d0,(a1)+
[000141ee] 1018                      move.b    (a0)+,d0
[000141f0] 4600                      not.b     d0
[000141f2] 12c0                      move.b    d0,(a1)+
[000141f4] 1018                      move.b    (a0)+,d0
[000141f6] 4600                      not.b     d0
[000141f8] 12c0                      move.b    d0,(a1)+
[000141fa] 1018                      move.b    (a0)+,d0
[000141fc] 4600                      not.b     d0
[000141fe] 12c0                      move.b    d0,(a1)+
[00014200] 1018                      move.b    (a0)+,d0
[00014202] 4600                      not.b     d0
[00014204] 12c0                      move.b    d0,(a1)+
[00014206] 1018                      move.b    (a0)+,d0
[00014208] 4600                      not.b     d0
[0001420a] 12c0                      move.b    d0,(a1)+
[0001420c] 1018                      move.b    (a0)+,d0
[0001420e] 4600                      not.b     d0
[00014210] 12c0                      move.b    d0,(a1)+
[00014212] 51ce ff3e                 dbf       d6,$00014152
[00014216] d0ca                      adda.w    a2,a0
[00014218] d2cb                      adda.w    a3,a1
[0001421a] 51cd ff32                 dbf       d5,$0001414E
[0001421e] 4e75                      rts
[00014220] 49fb 0006                 lea.l     $00014228(pc,d0.w),a4
[00014224] 3c04                      move.w    d4,d6
[00014226] 4ed4                      jmp       (a4)
[00014228] 1018                      move.b    (a0)+,d0
[0001422a] 4600                      not.b     d0
[0001422c] 8119                      or.b      d0,(a1)+
[0001422e] 1018                      move.b    (a0)+,d0
[00014230] 4600                      not.b     d0
[00014232] 8119                      or.b      d0,(a1)+
[00014234] 1018                      move.b    (a0)+,d0
[00014236] 4600                      not.b     d0
[00014238] 8119                      or.b      d0,(a1)+
[0001423a] 1018                      move.b    (a0)+,d0
[0001423c] 4600                      not.b     d0
[0001423e] 8119                      or.b      d0,(a1)+
[00014240] 1018                      move.b    (a0)+,d0
[00014242] 4600                      not.b     d0
[00014244] 8119                      or.b      d0,(a1)+
[00014246] 1018                      move.b    (a0)+,d0
[00014248] 4600                      not.b     d0
[0001424a] 8119                      or.b      d0,(a1)+
[0001424c] 1018                      move.b    (a0)+,d0
[0001424e] 4600                      not.b     d0
[00014250] 8119                      or.b      d0,(a1)+
[00014252] 1018                      move.b    (a0)+,d0
[00014254] 4600                      not.b     d0
[00014256] 8119                      or.b      d0,(a1)+
[00014258] 1018                      move.b    (a0)+,d0
[0001425a] 4600                      not.b     d0
[0001425c] 8119                      or.b      d0,(a1)+
[0001425e] 1018                      move.b    (a0)+,d0
[00014260] 4600                      not.b     d0
[00014262] 8119                      or.b      d0,(a1)+
[00014264] 1018                      move.b    (a0)+,d0
[00014266] 4600                      not.b     d0
[00014268] 8119                      or.b      d0,(a1)+
[0001426a] 1018                      move.b    (a0)+,d0
[0001426c] 4600                      not.b     d0
[0001426e] 8119                      or.b      d0,(a1)+
[00014270] 1018                      move.b    (a0)+,d0
[00014272] 4600                      not.b     d0
[00014274] 8119                      or.b      d0,(a1)+
[00014276] 1018                      move.b    (a0)+,d0
[00014278] 4600                      not.b     d0
[0001427a] 8119                      or.b      d0,(a1)+
[0001427c] 1018                      move.b    (a0)+,d0
[0001427e] 4600                      not.b     d0
[00014280] 8119                      or.b      d0,(a1)+
[00014282] 1018                      move.b    (a0)+,d0
[00014284] 4600                      not.b     d0
[00014286] 8119                      or.b      d0,(a1)+
[00014288] 1018                      move.b    (a0)+,d0
[0001428a] 4600                      not.b     d0
[0001428c] 8119                      or.b      d0,(a1)+
[0001428e] 1018                      move.b    (a0)+,d0
[00014290] 4600                      not.b     d0
[00014292] 8119                      or.b      d0,(a1)+
[00014294] 1018                      move.b    (a0)+,d0
[00014296] 4600                      not.b     d0
[00014298] 8119                      or.b      d0,(a1)+
[0001429a] 1018                      move.b    (a0)+,d0
[0001429c] 4600                      not.b     d0
[0001429e] 8119                      or.b      d0,(a1)+
[000142a0] 1018                      move.b    (a0)+,d0
[000142a2] 4600                      not.b     d0
[000142a4] 8119                      or.b      d0,(a1)+
[000142a6] 1018                      move.b    (a0)+,d0
[000142a8] 4600                      not.b     d0
[000142aa] 8119                      or.b      d0,(a1)+
[000142ac] 1018                      move.b    (a0)+,d0
[000142ae] 4600                      not.b     d0
[000142b0] 8119                      or.b      d0,(a1)+
[000142b2] 1018                      move.b    (a0)+,d0
[000142b4] 4600                      not.b     d0
[000142b6] 8119                      or.b      d0,(a1)+
[000142b8] 1018                      move.b    (a0)+,d0
[000142ba] 4600                      not.b     d0
[000142bc] 8119                      or.b      d0,(a1)+
[000142be] 1018                      move.b    (a0)+,d0
[000142c0] 4600                      not.b     d0
[000142c2] 8119                      or.b      d0,(a1)+
[000142c4] 1018                      move.b    (a0)+,d0
[000142c6] 4600                      not.b     d0
[000142c8] 8119                      or.b      d0,(a1)+
[000142ca] 1018                      move.b    (a0)+,d0
[000142cc] 4600                      not.b     d0
[000142ce] 8119                      or.b      d0,(a1)+
[000142d0] 1018                      move.b    (a0)+,d0
[000142d2] 4600                      not.b     d0
[000142d4] 8119                      or.b      d0,(a1)+
[000142d6] 1018                      move.b    (a0)+,d0
[000142d8] 4600                      not.b     d0
[000142da] 8119                      or.b      d0,(a1)+
[000142dc] 1018                      move.b    (a0)+,d0
[000142de] 4600                      not.b     d0
[000142e0] 8119                      or.b      d0,(a1)+
[000142e2] 1018                      move.b    (a0)+,d0
[000142e4] 4600                      not.b     d0
[000142e6] 8119                      or.b      d0,(a1)+
[000142e8] 51ce ff3e                 dbf       d6,$00014228
[000142ec] d0ca                      adda.w    a2,a0
[000142ee] d2cb                      adda.w    a3,a1
[000142f0] 51cd ff32                 dbf       d5,$00014224
[000142f4] 4e75                      rts
[000142f6] 49fb 0006                 lea.l     $000142FE(pc,d0.w),a4
[000142fa] 3c04                      move.w    d4,d6
[000142fc] 4ed4                      jmp       (a4)
[000142fe] 1018                      move.b    (a0)+,d0
[00014300] c111                      and.b     d0,(a1)
[00014302] 4619                      not.b     (a1)+
[00014304] 1018                      move.b    (a0)+,d0
[00014306] c111                      and.b     d0,(a1)
[00014308] 4619                      not.b     (a1)+
[0001430a] 1018                      move.b    (a0)+,d0
[0001430c] c111                      and.b     d0,(a1)
[0001430e] 4619                      not.b     (a1)+
[00014310] 1018                      move.b    (a0)+,d0
[00014312] c111                      and.b     d0,(a1)
[00014314] 4619                      not.b     (a1)+
[00014316] 1018                      move.b    (a0)+,d0
[00014318] c111                      and.b     d0,(a1)
[0001431a] 4619                      not.b     (a1)+
[0001431c] 1018                      move.b    (a0)+,d0
[0001431e] c111                      and.b     d0,(a1)
[00014320] 4619                      not.b     (a1)+
[00014322] 1018                      move.b    (a0)+,d0
[00014324] c111                      and.b     d0,(a1)
[00014326] 4619                      not.b     (a1)+
[00014328] 1018                      move.b    (a0)+,d0
[0001432a] c111                      and.b     d0,(a1)
[0001432c] 4619                      not.b     (a1)+
[0001432e] 1018                      move.b    (a0)+,d0
[00014330] c111                      and.b     d0,(a1)
[00014332] 4619                      not.b     (a1)+
[00014334] 1018                      move.b    (a0)+,d0
[00014336] c111                      and.b     d0,(a1)
[00014338] 4619                      not.b     (a1)+
[0001433a] 1018                      move.b    (a0)+,d0
[0001433c] c111                      and.b     d0,(a1)
[0001433e] 4619                      not.b     (a1)+
[00014340] 1018                      move.b    (a0)+,d0
[00014342] c111                      and.b     d0,(a1)
[00014344] 4619                      not.b     (a1)+
[00014346] 1018                      move.b    (a0)+,d0
[00014348] c111                      and.b     d0,(a1)
[0001434a] 4619                      not.b     (a1)+
[0001434c] 1018                      move.b    (a0)+,d0
[0001434e] c111                      and.b     d0,(a1)
[00014350] 4619                      not.b     (a1)+
[00014352] 1018                      move.b    (a0)+,d0
[00014354] c111                      and.b     d0,(a1)
[00014356] 4619                      not.b     (a1)+
[00014358] 1018                      move.b    (a0)+,d0
[0001435a] c111                      and.b     d0,(a1)
[0001435c] 4619                      not.b     (a1)+
[0001435e] 1018                      move.b    (a0)+,d0
[00014360] c111                      and.b     d0,(a1)
[00014362] 4619                      not.b     (a1)+
[00014364] 1018                      move.b    (a0)+,d0
[00014366] c111                      and.b     d0,(a1)
[00014368] 4619                      not.b     (a1)+
[0001436a] 1018                      move.b    (a0)+,d0
[0001436c] c111                      and.b     d0,(a1)
[0001436e] 4619                      not.b     (a1)+
[00014370] 1018                      move.b    (a0)+,d0
[00014372] c111                      and.b     d0,(a1)
[00014374] 4619                      not.b     (a1)+
[00014376] 1018                      move.b    (a0)+,d0
[00014378] c111                      and.b     d0,(a1)
[0001437a] 4619                      not.b     (a1)+
[0001437c] 1018                      move.b    (a0)+,d0
[0001437e] c111                      and.b     d0,(a1)
[00014380] 4619                      not.b     (a1)+
[00014382] 1018                      move.b    (a0)+,d0
[00014384] c111                      and.b     d0,(a1)
[00014386] 4619                      not.b     (a1)+
[00014388] 1018                      move.b    (a0)+,d0
[0001438a] c111                      and.b     d0,(a1)
[0001438c] 4619                      not.b     (a1)+
[0001438e] 1018                      move.b    (a0)+,d0
[00014390] c111                      and.b     d0,(a1)
[00014392] 4619                      not.b     (a1)+
[00014394] 1018                      move.b    (a0)+,d0
[00014396] c111                      and.b     d0,(a1)
[00014398] 4619                      not.b     (a1)+
[0001439a] 1018                      move.b    (a0)+,d0
[0001439c] c111                      and.b     d0,(a1)
[0001439e] 4619                      not.b     (a1)+
[000143a0] 1018                      move.b    (a0)+,d0
[000143a2] c111                      and.b     d0,(a1)
[000143a4] 4619                      not.b     (a1)+
[000143a6] 1018                      move.b    (a0)+,d0
[000143a8] c111                      and.b     d0,(a1)
[000143aa] 4619                      not.b     (a1)+
[000143ac] 1018                      move.b    (a0)+,d0
[000143ae] c111                      and.b     d0,(a1)
[000143b0] 4619                      not.b     (a1)+
[000143b2] 1018                      move.b    (a0)+,d0
[000143b4] c111                      and.b     d0,(a1)
[000143b6] 4619                      not.b     (a1)+
[000143b8] 1018                      move.b    (a0)+,d0
[000143ba] c111                      and.b     d0,(a1)
[000143bc] 4619                      not.b     (a1)+
[000143be] 51ce ff3e                 dbf       d6,$000142FE
[000143c2] d0ca                      adda.w    a2,a0
[000143c4] d2cb                      adda.w    a3,a1
[000143c6] 51cd ff32                 dbf       d5,$000142FA
[000143ca] 4e75                      rts
[000143cc] 4e75                      rts

data:
[000143ce]                           dc.w $02ac
[000143d0]                           dc.w $02dc
[000143d2]                           dc.w $0022
[000143d4]                           dc.w $004c
[000143d6]                           dc.w $0230
[000143d8]                           dc.w $01bc
[000143da]                           dc.w $0222
[000143dc]                           dc.w $01aa
[000143de]                           dc.w $0830
[000143e0]                           dc.w $0000
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
; $00000068
; $00000166
; $0000016c
; $000001da
; $000001fc
; $00000204
; $0000020c
; $00000214
; $0000021c
; $00000224
; $0000022c
; $00000234
; $0000023c
; $00000244
; $0000024c
; $00000254
; $0000025c
; $00000264
; $0000026c
; $00000274
; $0000027c
; $0000037a
; $00000398
; $0000039c
; $000003a0
; $000003a4
; $000004a2
; $000005a0
; $0000069e
; $0000079c
; $0000089a
; $00000998
; $00000a96
; $00000b94
; $00000c92
; $00000d90
; $00000e8e
; $00000efc
; $00000f00
; $00000f04
; $00000f08
; $00000f0c
; $00000f10
; $00000f14
; $00000f18
; $00001016
; $00001110
; $00001114
; $00001118
; $0000111c
; $00001120
; $00001124
; $00001128
; $0000112c
; $0000122a
; $0000129c
; $000012a0
; $000012a4
; $000012a8
; $000012ac
; $000012b0
; $000012b4
; $000012b8
