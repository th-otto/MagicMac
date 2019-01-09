; ph_branch = 0x601a
; ph_tlen = 0x000038f8
; ph_dlen = 0x000000e4
; ph_blen = 0x00000806
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000059

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0410                 cmpiw.l   #$0410,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 0078                 ori.b     #$78,d1
[00010018] 0001 01b8                 ori.b     #$B8,d1
[0001001c] 0001 024e                 ori.b     #$4E,d1
[00010020] 0001 007a                 ori.b     #$7A,d1
[00010024] 0001 00bc                 ori.b     #$BC,d1
[00010028] 0001 010a                 ori.b     #$0A,d1
[0001002c] 0001 015c                 ori.b     #$5C,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0000 0010                 ori.b     #$10,d0
[00010044] 0004 0002                 ori.b     #$02,d4
[00010048] 0001 0000                 ori.b     #$00,d1
[0001004c] 0000 0000                 ori.b     #$00,d0
[00010050] 4e75                      rts
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 39dc            move.l    a0,$000139DC
[0001005c] 33e8 006a 0001 39e0       move.w    106(a0),$000139E0
[00010064] 6100 00f8                 bsr       $0001015E
[00010068] 6100 011a                 bsr       $00010184
[0001006c] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010070] 203c 0000 02d8            move.l    #$000002D8,d0
[00010076] 4e75                      rts
[00010078] 4e75                      rts
[0001007a] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[0001007e] 20ee 0010                 move.l    16(a6),(a0)+
[00010082] 4258                      clr.w     (a0)+
[00010084] 20ee 000c                 move.l    12(a6),(a0)+
[00010088] 7027                      moveq.l   #39,d0
[0001008a] 247a 3950                 movea.l   $000139DC(pc),a2
[0001008e] 246a 002c                 movea.l   44(a2),a2
[00010092] 45ea 000a                 lea.l     10(a2),a2
[00010096] 30da                      move.w    (a2)+,(a0)+
[00010098] 51c8 fffc                 dbf       d0,$00010096
[0001009c] 317c 0010 ffc0            move.w    #$0010,-64(a0)
[000100a2] 317c 0001 ffec            move.w    #$0001,-20(a0)
[000100a8] 317c 0010 fff4            move.w    #$0010,-12(a0)
[000100ae] 700b                      moveq.l   #11,d0
[000100b0] 32da                      move.w    (a2)+,(a1)+
[000100b2] 51c8 fffc                 dbf       d0,$000100B0
[000100b6] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[000100ba] 4e75                      rts
[000100bc] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[000100c0] 702c                      moveq.l   #44,d0
[000100c2] 247a 3918                 movea.l   $000139DC(pc),a2
[000100c6] 246a 0030                 movea.l   48(a2),a2
[000100ca] 30da                      move.w    (a2)+,(a0)+
[000100cc] 51c8 fffc                 dbf       d0,$000100CA
[000100d0] 4268 ffa6                 clr.w     -90(a0)
[000100d4] 317c 0010 ffa8            move.w    #$0010,-88(a0)
[000100da] 317c 0004 ffae            move.w    #$0004,-82(a0)
[000100e0] 4268 ffb0                 clr.w     -80(a0)
[000100e4] 317c 0898 ffb2            move.w    #$0898,-78(a0)
[000100ea] 317c 0001 ffcc            move.w    #$0001,-52(a0)
[000100f0] 700b                      moveq.l   #11,d0
[000100f2] 32da                      move.w    (a2)+,(a1)+
[000100f4] 51c8 fffc                 dbf       d0,$000100F2
[000100f8] 45ee 0034                 lea.l     52(a6),a2
[000100fc] 235a ffe8                 move.l    (a2)+,-24(a1)
[00010100] 235a ffec                 move.l    (a2)+,-20(a1)
[00010104] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010108] 4e75                      rts
[0001010a] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[0001010e] 7000                      moveq.l   #0,d0
[00010110] 30fc 0002                 move.w    #$0002,(a0)+
[00010114] 30c0                      move.w    d0,(a0)+
[00010116] 30fc 0004                 move.w    #$0004,(a0)+
[0001011a] 20fc 0000 0010            move.l    #$00000010,(a0)+
[00010120] 30ee 01b2                 move.w    434(a6),(a0)+
[00010124] 20ee 01ae                 move.l    430(a6),(a0)+
[00010128] 30c0                      move.w    d0,(a0)+
[0001012a] 30c0                      move.w    d0,(a0)+
[0001012c] 30c0                      move.w    d0,(a0)+
[0001012e] 30c0                      move.w    d0,(a0)+
[00010130] 30c0                      move.w    d0,(a0)+
[00010132] 30c0                      move.w    d0,(a0)+
[00010134] 30fc 0001                 move.w    #$0001,(a0)+
[00010138] 4258                      clr.w     (a0)+
[0001013a] 700f                      moveq.l   #15,d0
[0001013c] 7200                      moveq.l   #0,d1
[0001013e] 43fa 37cc                 lea.l     $0001390C(pc),a1
[00010142] 1219                      move.b    (a1)+,d1
[00010144] 30c1                      move.w    d1,(a0)+
[00010146] 51c8 fffa                 dbf       d0,$00010142
[0001014a] 303c 00ef                 move.w    #$00EF,d0
[0001014e] 720f                      moveq.l   #15,d1
[00010150] 30c1                      move.w    d1,(a0)+
[00010152] 51c8 fffc                 dbf       d0,$00010150
[00010156] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[0001015a] 4e75                      rts
[0001015c] 4e75                      rts
[0001015e] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010162] a000                      ALINE     #$0000
[00010164] 907c 2070                 sub.w     #$2070,d0
[00010168] 6714                      beq.s     $0001017E
[0001016a] 41fa fe94                 lea.l     $00010000(pc),a0
[0001016e] 43f9 0001 38f8            lea.l     $000138F8,a1
[00010174] 3219                      move.w    (a1)+,d1
[00010176] 6706                      beq.s     $0001017E
[00010178] d0c1                      adda.w    d1,a0
[0001017a] d150                      add.w     d0,(a0)
[0001017c] 60f6                      bra.s     $00010174
[0001017e] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010182] 4e75                      rts
[00010184] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[00010188] 41fa 3858                 lea.l     $000139E2(pc),a0
[0001018c] 7000                      moveq.l   #0,d0
[0001018e] 3200                      move.w    d0,d1
[00010190] 7403                      moveq.l   #3,d2
[00010192] 4210                      clr.b     (a0)
[00010194] d201                      add.b     d1,d1
[00010196] 6404                      bcc.s     $0001019C
[00010198] 0a10 00f0                 eori.b    #$F0,(a0)
[0001019c] d201                      add.b     d1,d1
[0001019e] 6404                      bcc.s     $000101A4
[000101a0] 0a10 000f                 eori.b    #$0F,(a0)
[000101a4] 5288                      addq.l    #1,a0
[000101a6] 51ca ffea                 dbf       d2,$00010192
[000101aa] 5240                      addq.w    #1,d0
[000101ac] b07c 0100                 cmp.w     #$0100,d0
[000101b0] 6ddc                      blt.s     $0001018E
[000101b2] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[000101b6] 4e75                      rts
[000101b8] 3d7c 0003 01b4            move.w    #$0003,436(a6)
[000101be] 3d7c 000f 0014            move.w    #$000F,20(a6)
[000101c4] 2d7c 0001 0e30 01f4       move.l    #$00010E30,500(a6)
[000101cc] 2d7c 0001 08d6 01f8       move.l    #$000108D6,504(a6)
[000101d4] 2d7c 0001 058e 01fc       move.l    #$0001058E,508(a6)
[000101dc] 2d7c 0001 094c 0200       move.l    #$0001094C,512(a6)
[000101e4] 2d7c 0001 0c62 0204       move.l    #$00010C62,516(a6)
[000101ec] 2d7c 0001 1574 0208       move.l    #$00011574,520(a6)
[000101f4] 2d7c 0001 20b6 020c       move.l    #$000120B6,524(a6)
[000101fc] 2d7c 0001 0546 0210       move.l    #$00010546,528(a6)
[00010204] 2d7c 0001 026e 0214       move.l    #$0001026E,532(a6)
[0001020c] 2d7c 0001 04da 021c       move.l    #$000104DA,540(a6)
[00010214] 2d7c 0001 050c 0218       move.l    #$0001050C,536(a6)
[0001021c] 2d7c 0001 0304 0220       move.l    #$00010304,544(a6)
[00010224] 2d7c 0001 02d6 0224       move.l    #$000102D6,548(a6)
[0001022c] 2d7c 0001 0250 0228       move.l    #$00010250,552(a6)
[00010234] 2d7c 0001 0252 022c       move.l    #$00010252,556(a6)
[0001023c] 2d7c 0001 025a 0230       move.l    #$0001025A,560(a6)
[00010244] 2d7c 0001 0264 0234       move.l    #$00010264,564(a6)
[0001024c] 4e75                      rts
[0001024e] 4e75                      rts
[00010250] 4e75                      rts
[00010252] 70ff                      moveq.l   #-1,d0
[00010254] 72ff                      moveq.l   #-1,d1
[00010256] 74ff                      moveq.l   #-1,d2
[00010258] 4e75                      rts
[0001025a] 41fa 36b0                 lea.l     $0001390C(pc),a0
[0001025e] 1030 0000                 move.b    0(a0,d0.w),d0
[00010262] 4e75                      rts
[00010264] 41fa 36b6                 lea.l     $0001391C(pc),a0
[00010268] 1030 0000                 move.b    0(a0,d0.w),d0
[0001026c] 4e75                      rts
[0001026e] 2f05                      move.l    d5,-(a7)
[00010270] 3600                      move.w    d0,d3
[00010272] 4843                      swap      d3
[00010274] 3600                      move.w    d0,d3
[00010276] 4a6e 01b2                 tst.w     434(a6)
[0001027a] 670a                      beq.s     $00010286
[0001027c] 266e 01ae                 movea.l   430(a6),a3
[00010280] c3ee 01b2                 muls.w    434(a6),d1
[00010284] 6008                      bra.s     $0001028E
[00010286] 2678 044e                 movea.l   ($0000044E).w,a3
[0001028a] c3f8 206e                 muls.w    ($0000206E).w,d1
[0001028e] d7c1                      adda.l    d1,a3
[00010290] d6c0                      adda.w    d0,a3
[00010292] 284b                      movea.l   a3,a4
[00010294] 7800                      moveq.l   #0,d4
[00010296] 1813                      move.b    (a3),d4
[00010298] b642                      cmp.w     d2,d3
[0001029a] 6e0e                      bgt.s     $000102AA
[0001029c] 528b                      addq.l    #1,a3
[0001029e] b81b                      cmp.b     (a3)+,d4
[000102a0] 6608                      bne.s     $000102AA
[000102a2] 5243                      addq.w    #1,d3
[000102a4] b642                      cmp.w     d2,d3
[000102a6] 6df6                      blt.s     $0001029E
[000102a8] 3602                      move.w    d2,d3
[000102aa] 3283                      move.w    d3,(a1)
[000102ac] 4842                      swap      d2
[000102ae] 4843                      swap      d3
[000102b0] 264c                      movea.l   a4,a3
[000102b2] b642                      cmp.w     d2,d3
[000102b4] 6f0e                      ble.s     $000102C4
[000102b6] 3003                      move.w    d3,d0
[000102b8] b823                      cmp.b     -(a3),d4
[000102ba] 6608                      bne.s     $000102C4
[000102bc] 5343                      subq.w    #1,d3
[000102be] b642                      cmp.w     d2,d3
[000102c0] 6ef6                      bgt.s     $000102B8
[000102c2] 3602                      move.w    d2,d3
[000102c4] 3083                      move.w    d3,(a0)
[000102c6] 3015                      move.w    (a5),d0
[000102c8] b86d 0004                 cmp.w     4(a5),d4
[000102cc] 6704                      beq.s     $000102D2
[000102ce] 0a40 0001                 eori.w    #$0001,d0
[000102d2] 2a1f                      move.l    (a7)+,d5
[000102d4] 4e75                      rts
[000102d6] b07c 0010                 cmp.w     #$0010,d0
[000102da] 6714                      beq.s     $000102F0
[000102dc] 48e7 7f3e                 movem.l   d1-d7/a2-a6,-(a7)
[000102e0] 7010                      moveq.l   #16,d0
[000102e2] 720f                      moveq.l   #15,d1
[000102e4] 6100 019a                 bsr       $00010480
[000102e8] 4cdf 7cfe                 movem.l   (a7)+,d1-d7/a2-a6
[000102ec] 7003                      moveq.l   #3,d0
[000102ee] 4e75                      rts
[000102f0] 22d8                      move.l    (a0)+,(a1)+
[000102f2] 22d8                      move.l    (a0)+,(a1)+
[000102f4] 22d8                      move.l    (a0)+,(a1)+
[000102f6] 22d8                      move.l    (a0)+,(a1)+
[000102f8] 22d8                      move.l    (a0)+,(a1)+
[000102fa] 22d8                      move.l    (a0)+,(a1)+
[000102fc] 22d8                      move.l    (a0)+,(a1)+
[000102fe] 22d8                      move.l    (a0)+,(a1)+
[00010300] 7000                      moveq.l   #0,d0
[00010302] 4e75                      rts
[00010304] 2f0e                      move.l    a6,-(a7)
[00010306] 7000                      moveq.l   #0,d0
[00010308] 3028 000c                 move.w    12(a0),d0
[0001030c] 3228 0006                 move.w    6(a0),d1
[00010310] c2e8 0008                 mulu.w    8(a0),d1
[00010314] 7400                      moveq.l   #0,d2
[00010316] 4a68 000a                 tst.w     10(a0)
[0001031a] 6602                      bne.s     $0001031E
[0001031c] 7401                      moveq.l   #1,d2
[0001031e] 3342 000a                 move.w    d2,10(a1)
[00010322] 2050                      movea.l   (a0),a0
[00010324] 2251                      movea.l   (a1),a1
[00010326] 5381                      subq.l    #1,d1
[00010328] 6b4c                      bmi.s     $00010376
[0001032a] 5340                      subq.w    #1,d0
[0001032c] 6700 0196                 beq       $000104C4
[00010330] 5740                      subq.w    #3,d0
[00010332] 6642                      bne.s     $00010376
[00010334] d442                      add.w     d2,d2
[00010336] d442                      add.w     d2,d2
[00010338] 247b 2040                 movea.l   $0001037A(pc,d2.w),a2
[0001033c] b3c8                      cmpa.l    a0,a1
[0001033e] 6630                      bne.s     $00010370
[00010340] 2601                      move.l    d1,d3
[00010342] 5283                      addq.l    #1,d3
[00010344] e78b                      lsl.l     #3,d3
[00010346] b6ae 0024                 cmp.l     36(a6),d3
[0001034a] 6e1e                      bgt.s     $0001036A
[0001034c] 2f03                      move.l    d3,-(a7)
[0001034e] 2f08                      move.l    a0,-(a7)
[00010350] 226e 0020                 movea.l   32(a6),a1
[00010354] 2f09                      move.l    a1,-(a7)
[00010356] 2001                      move.l    d1,d0
[00010358] 5280                      addq.l    #1,d0
[0001035a] 4e92                      jsr       (a2)
[0001035c] 205f                      movea.l   (a7)+,a0
[0001035e] 225f                      movea.l   (a7)+,a1
[00010360] 221f                      move.l    (a7)+,d1
[00010362] e289                      lsr.l     #1,d1
[00010364] 5381                      subq.l    #1,d1
[00010366] 6000 0160                 bra       $000104C8
[0001036a] 247b 2016                 movea.l   $00010382(pc,d2.w),a2
[0001036e] 6004                      bra.s     $00010374
[00010370] 2001                      move.l    d1,d0
[00010372] 5280                      addq.l    #1,d0
[00010374] 4e92                      jsr       (a2)
[00010376] 2c5f                      movea.l   (a7)+,a6
[00010378] 4e75                      rts
[0001037a] 0001 0480                 ori.b     #$80,d1
[0001037e] 0001 043c                 ori.b     #$3C,d1
[00010382] 0001 038a                 ori.b     #$8A,d1
[00010386] 0001 03ce                 ori.b     #$CE,d1
[0001038a] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[0001038e] 2001                      move.l    d1,d0
[00010390] 7803                      moveq.l   #3,d4
[00010392] 6178                      bsr.s     $0001040C
[00010394] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[00010398] 7007                      moveq.l   #7,d0
[0001039a] 3a18                      move.w    (a0)+,d5
[0001039c] 3818                      move.w    (a0)+,d4
[0001039e] 3618                      move.w    (a0)+,d3
[000103a0] 3418                      move.w    (a0)+,d2
[000103a2] d442                      add.w     d2,d2
[000103a4] df07                      addx.b    d7,d7
[000103a6] d643                      add.w     d3,d3
[000103a8] df07                      addx.b    d7,d7
[000103aa] d844                      add.w     d4,d4
[000103ac] df07                      addx.b    d7,d7
[000103ae] da45                      add.w     d5,d5
[000103b0] df07                      addx.b    d7,d7
[000103b2] d442                      add.w     d2,d2
[000103b4] df07                      addx.b    d7,d7
[000103b6] d643                      add.w     d3,d3
[000103b8] df07                      addx.b    d7,d7
[000103ba] d844                      add.w     d4,d4
[000103bc] df07                      addx.b    d7,d7
[000103be] da45                      add.w     d5,d5
[000103c0] df07                      addx.b    d7,d7
[000103c2] 12c7                      move.b    d7,(a1)+
[000103c4] 51c8 ffdc                 dbf       d0,$000103A2
[000103c8] 5381                      subq.l    #1,d1
[000103ca] 6acc                      bpl.s     $00010398
[000103cc] 4e75                      rts
[000103ce] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[000103d2] 7007                      moveq.l   #7,d0
[000103d4] 1e18                      move.b    (a0)+,d7
[000103d6] de07                      add.b     d7,d7
[000103d8] d542                      addx.w    d2,d2
[000103da] de07                      add.b     d7,d7
[000103dc] d743                      addx.w    d3,d3
[000103de] de07                      add.b     d7,d7
[000103e0] d944                      addx.w    d4,d4
[000103e2] de07                      add.b     d7,d7
[000103e4] db45                      addx.w    d5,d5
[000103e6] de07                      add.b     d7,d7
[000103e8] d542                      addx.w    d2,d2
[000103ea] de07                      add.b     d7,d7
[000103ec] d743                      addx.w    d3,d3
[000103ee] de07                      add.b     d7,d7
[000103f0] d944                      addx.w    d4,d4
[000103f2] de07                      add.b     d7,d7
[000103f4] db45                      addx.w    d5,d5
[000103f6] 51c8 ffdc                 dbf       d0,$000103D4
[000103fa] 32c5                      move.w    d5,(a1)+
[000103fc] 32c4                      move.w    d4,(a1)+
[000103fe] 32c3                      move.w    d3,(a1)+
[00010400] 32c2                      move.w    d2,(a1)+
[00010402] 5381                      subq.l    #1,d1
[00010404] 6acc                      bpl.s     $000103D2
[00010406] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[0001040a] 7003                      moveq.l   #3,d0
[0001040c] 5384                      subq.l    #1,d4
[0001040e] 6b2a                      bmi.s     $0001043A
[00010410] 7400                      moveq.l   #0,d2
[00010412] 2204                      move.l    d4,d1
[00010414] d1c0                      adda.l    d0,a0
[00010416] 41f0 0802                 lea.l     2(a0,d0.l),a0
[0001041a] 3a10                      move.w    (a0),d5
[0001041c] 2248                      movea.l   a0,a1
[0001041e] 2448                      movea.l   a0,a2
[00010420] d480                      add.l     d0,d2
[00010422] 2602                      move.l    d2,d3
[00010424] 6004                      bra.s     $0001042A
[00010426] 2449                      movea.l   a1,a2
[00010428] 34a1                      move.w    -(a1),(a2)
[0001042a] 5383                      subq.l    #1,d3
[0001042c] 6af8                      bpl.s     $00010426
[0001042e] 3285                      move.w    d5,(a1)
[00010430] 5381                      subq.l    #1,d1
[00010432] 6ae0                      bpl.s     $00010414
[00010434] 204a                      movea.l   a2,a0
[00010436] 5380                      subq.l    #1,d0
[00010438] 6ad6                      bpl.s     $00010410
[0001043a] 4e75                      rts
[0001043c] d080                      add.l     d0,d0
[0001043e] 45f1 0800                 lea.l     0(a1,d0.l),a2
[00010442] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010446] 49f3 0800                 lea.l     0(a3,d0.l),a4
[0001044a] 7007                      moveq.l   #7,d0
[0001044c] 1e18                      move.b    (a0)+,d7
[0001044e] de07                      add.b     d7,d7
[00010450] d542                      addx.w    d2,d2
[00010452] de07                      add.b     d7,d7
[00010454] d743                      addx.w    d3,d3
[00010456] de07                      add.b     d7,d7
[00010458] d944                      addx.w    d4,d4
[0001045a] de07                      add.b     d7,d7
[0001045c] db45                      addx.w    d5,d5
[0001045e] de07                      add.b     d7,d7
[00010460] d542                      addx.w    d2,d2
[00010462] de07                      add.b     d7,d7
[00010464] d743                      addx.w    d3,d3
[00010466] de07                      add.b     d7,d7
[00010468] d944                      addx.w    d4,d4
[0001046a] de07                      add.b     d7,d7
[0001046c] db45                      addx.w    d5,d5
[0001046e] 51c8 ffdc                 dbf       d0,$0001044C
[00010472] 32c5                      move.w    d5,(a1)+
[00010474] 34c4                      move.w    d4,(a2)+
[00010476] 36c3                      move.w    d3,(a3)+
[00010478] 38c2                      move.w    d2,(a4)+
[0001047a] 5381                      subq.l    #1,d1
[0001047c] 6acc                      bpl.s     $0001044A
[0001047e] 4e75                      rts
[00010480] d080                      add.l     d0,d0
[00010482] 45f0 0800                 lea.l     0(a0,d0.l),a2
[00010486] 47f2 0800                 lea.l     0(a2,d0.l),a3
[0001048a] 49f3 0800                 lea.l     0(a3,d0.l),a4
[0001048e] 7007                      moveq.l   #7,d0
[00010490] 3a18                      move.w    (a0)+,d5
[00010492] 381a                      move.w    (a2)+,d4
[00010494] 361b                      move.w    (a3)+,d3
[00010496] 341c                      move.w    (a4)+,d2
[00010498] d442                      add.w     d2,d2
[0001049a] df07                      addx.b    d7,d7
[0001049c] d643                      add.w     d3,d3
[0001049e] df07                      addx.b    d7,d7
[000104a0] d844                      add.w     d4,d4
[000104a2] df07                      addx.b    d7,d7
[000104a4] da45                      add.w     d5,d5
[000104a6] df07                      addx.b    d7,d7
[000104a8] d442                      add.w     d2,d2
[000104aa] df07                      addx.b    d7,d7
[000104ac] d643                      add.w     d3,d3
[000104ae] df07                      addx.b    d7,d7
[000104b0] d844                      add.w     d4,d4
[000104b2] df07                      addx.b    d7,d7
[000104b4] da45                      add.w     d5,d5
[000104b6] df07                      addx.b    d7,d7
[000104b8] 12c7                      move.b    d7,(a1)+
[000104ba] 51c8 ffdc                 dbf       d0,$00010498
[000104be] 5381                      subq.l    #1,d1
[000104c0] 6acc                      bpl.s     $0001048E
[000104c2] 4e75                      rts
[000104c4] b3c8                      cmpa.l    a0,a1
[000104c6] 670e                      beq.s     $000104D6
[000104c8] e289                      lsr.l     #1,d1
[000104ca] 6504                      bcs.s     $000104D0
[000104cc] 32d8                      move.w    (a0)+,(a1)+
[000104ce] 6002                      bra.s     $000104D2
[000104d0] 22d8                      move.l    (a0)+,(a1)+
[000104d2] 5381                      subq.l    #1,d1
[000104d4] 6afa                      bpl.s     $000104D0
[000104d6] 2c5f                      movea.l   (a7)+,a6
[000104d8] 4e75                      rts
[000104da] 2f02                      move.l    d2,-(a7)
[000104dc] 206e 01ae                 movea.l   430(a6),a0
[000104e0] 342e 01b2                 move.w    434(a6),d2
[000104e4] 6608                      bne.s     $000104EE
[000104e6] 2078 044e                 movea.l   ($0000044E).w,a0
[000104ea] 3438 206e                 move.w    ($0000206E).w,d2
[000104ee] c3c2                      muls.w    d2,d1
[000104f0] d1c1                      adda.l    d1,a0
[000104f2] 3200                      move.w    d0,d1
[000104f4] e248                      lsr.w     #1,d0
[000104f6] d0c0                      adda.w    d0,a0
[000104f8] 7000                      moveq.l   #0,d0
[000104fa] 1010                      move.b    (a0),d0
[000104fc] 0801 0000                 btst      #0,d1
[00010500] 6602                      bne.s     $00010504
[00010502] e848                      lsr.w     #4,d0
[00010504] c07c 000f                 and.w     #$000F,d0
[00010508] 241f                      move.l    (a7)+,d2
[0001050a] 4e75                      rts
[0001050c] 48e7 3000                 movem.l   d2-d3,-(a7)
[00010510] 206e 01ae                 movea.l   430(a6),a0
[00010514] 362e 01b2                 move.w    434(a6),d3
[00010518] 6608                      bne.s     $00010522
[0001051a] 2078 044e                 movea.l   ($0000044E).w,a0
[0001051e] 3638 206e                 move.w    ($0000206E).w,d3
[00010522] c3c3                      muls.w    d3,d1
[00010524] d1c1                      adda.l    d1,a0
[00010526] 3200                      move.w    d0,d1
[00010528] e248                      lsr.w     #1,d0
[0001052a] d0c0                      adda.w    d0,a0
[0001052c] 7000                      moveq.l   #0,d0
[0001052e] 700f                      moveq.l   #15,d0
[00010530] 0801 0000                 btst      #0,d1
[00010534] 6704                      beq.s     $0001053A
[00010536] e948                      lsl.w     #4,d0
[00010538] e98a                      lsl.l     #4,d2
[0001053a] 4600                      not.b     d0
[0001053c] c110                      and.b     d0,(a0)
[0001053e] 8510                      or.b      d2,(a0)
[00010540] 4cdf 000c                 movem.l   (a7)+,d2-d3
[00010544] 4e75                      rts
[00010546] 2278 044e                 movea.l   ($0000044E).w,a1
[0001054a] 3678 206e                 movea.w   ($0000206E).w,a3
[0001054e] 4a6e 01b2                 tst.w     434(a6)
[00010552] 6708                      beq.s     $0001055C
[00010554] 226e 01ae                 movea.l   430(a6),a1
[00010558] 366e 01b2                 movea.w   434(a6),a3
[0001055c] 426e 01ec                 clr.w     492(a6)
[00010560] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[00010566] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[0001056c] 426e 01c8                 clr.w     456(a6)
[00010570] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00010576] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[0001057c] 6600 100c                 bne       $0001158A
[00010580] 426e 01ea                 clr.w     490(a6)
[00010584] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[0001058a] 6000 0ffe                 bra       $0001158A
[0001058e] 2278 044e                 movea.l   ($0000044E).w,a1
[00010592] 3838 206e                 move.w    ($0000206E).w,d4
[00010596] 4a6e 01b2                 tst.w     434(a6)
[0001059a] 6708                      beq.s     $000105A4
[0001059c] 226e 01ae                 movea.l   430(a6),a1
[000105a0] 382e 01b2                 move.w    434(a6),d4
[000105a4] c9c1                      muls.w    d1,d4
[000105a6] d3c4                      adda.l    d4,a1
[000105a8] 78f8                      moveq.l   #-8,d4
[000105aa] c840                      and.w     d0,d4
[000105ac] e24c                      lsr.w     #1,d4
[000105ae] d2c4                      adda.w    d4,a1
[000105b0] 48e7 1030                 movem.l   d3/a2-a3,-(a7)
[000105b4] 45fa 33a6                 lea.l     $0001395C(pc),a2
[000105b8] 322e 0046                 move.w    70(a6),d1
[000105bc] d241                      add.w     d1,d1
[000105be] d241                      add.w     d1,d1
[000105c0] 2232 1000                 move.l    0(a2,d1.w),d1
[000105c4] 3a07                      move.w    d7,d5
[000105c6] 45fa 341a                 lea.l     $000139E2(pc),a2
[000105ca] 3e06                      move.w    d6,d7
[000105cc] e04e                      lsr.w     #8,d6
[000105ce] ce7c 00ff                 and.w     #$00FF,d7
[000105d2] dc46                      add.w     d6,d6
[000105d4] dc46                      add.w     d6,d6
[000105d6] de47                      add.w     d7,d7
[000105d8] de47                      add.w     d7,d7
[000105da] 2c32 6000                 move.l    0(a2,d6.w),d6
[000105de] 2e32 7000                 move.l    0(a2,d7.w),d7
[000105e2] 3602                      move.w    d2,d3
[000105e4] e84a                      lsr.w     #4,d2
[000105e6] 3800                      move.w    d0,d4
[000105e8] e84c                      lsr.w     #4,d4
[000105ea] 9444                      sub.w     d4,d2
[000105ec] 5345                      subq.w    #1,d5
[000105ee] 6700 0106                 beq       $000106F6
[000105f2] 5345                      subq.w    #1,d5
[000105f4] 6700 0206                 beq       $000107FC
[000105f8] 5345                      subq.w    #1,d5
[000105fa] 6700 00f6                 beq       $000106F2
[000105fe] 7808                      moveq.l   #8,d4
[00010600] c840                      and.w     d0,d4
[00010602] 247b 400c                 movea.l   $00010610(pc,d4.w),a2
[00010606] 7a08                      moveq.l   #8,d5
[00010608] ca43                      and.w     d3,d5
[0001060a] 267b 5010                 movea.l   $0001061C(pc,d5.w),a3
[0001060e] 6058                      bra.s     $00010668
[00010610] 0001 06c2                 ori.b     #$C2,d1
[00010614] 0000 0000                 ori.b     #$00,d0
[00010618] 0001 06b6                 ori.b     #$B6,d1
[0001061c] 0001 06dc                 ori.b     #$DC,d1
[00010620] 0000 0000                 ori.b     #$00,d0
[00010624] 0001 06e0                 ori.b     #$E0,d1
[00010628] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[00010630] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00010634] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[00010638] 0000 ffff                 ori.b     #$FF,d0
[0001063c] 0000 0fff                 ori.b     #$FF,d0
[00010640] 0000 00ff                 ori.b     #$FF,d0
[00010644] 0000 000f                 ori.b     #$0F,d0
[00010648] f000 0000                 pmove.l   d0,???
[0001064c] ff00                      dc.w      $FF00 ; illegal
[0001064e] 0000 fff0                 ori.b     #$F0,d0
[00010652] 0000 ffff                 ori.b     #$FF,d0
[00010656] 0000 ffff                 ori.b     #$FF,d0
[0001065a] f000                      dc.w      $F000 ; illegal
[0001065c] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00010664] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[0001066c] c644                      and.w     d4,d3
[0001066e] d040                      add.w     d0,d0
[00010670] d040                      add.w     d0,d0
[00010672] d643                      add.w     d3,d3
[00010674] d643                      add.w     d3,d3
[00010676] 283b 00b0                 move.l    $00010628(pc,d0.w),d4
[0001067a] 2a3b 30cc                 move.l    $00010648(pc,d3.w),d5
[0001067e] 5342                      subq.w    #1,d2
[00010680] 6a20                      bpl.s     $000106A2
[00010682] b5fc 0001 06c2            cmpa.l    #$000106C2,a2
[00010688] 6708                      beq.s     $00010692
[0001068a] ca84                      and.l     d4,d5
[0001068c] 7800                      moveq.l   #0,d4
[0001068e] 5989                      subq.l    #4,a1
[00010690] 600c                      bra.s     $0001069E
[00010692] b7fc 0001 06e0            cmpa.l    #$000106E0,a3
[00010698] 6704                      beq.s     $0001069E
[0001069a] c885                      and.l     d5,d4
[0001069c] 7a00                      moveq.l   #0,d5
[0001069e] 45fa 0008                 lea.l     $000106A8(pc),a2
[000106a2] cc81                      and.l     d1,d6
[000106a4] ce81                      and.l     d1,d7
[000106a6] 4ed2                      jmp       (a2)
[000106a8] 8991                      or.l      d4,(a1)
[000106aa] 2006                      move.l    d6,d0
[000106ac] 4680                      not.l     d0
[000106ae] c084                      and.l     d4,d0
[000106b0] b199                      eor.l     d0,(a1)+
[000106b2] 2007                      move.l    d7,d0
[000106b4] 602e                      bra.s     $000106E4
[000106b6] 8991                      or.l      d4,(a1)
[000106b8] 2007                      move.l    d7,d0
[000106ba] 4680                      not.l     d0
[000106bc] c084                      and.l     d4,d0
[000106be] b199                      eor.l     d0,(a1)+
[000106c0] 600c                      bra.s     $000106CE
[000106c2] 8991                      or.l      d4,(a1)
[000106c4] 2006                      move.l    d6,d0
[000106c6] 4680                      not.l     d0
[000106c8] c084                      and.l     d4,d0
[000106ca] b199                      eor.l     d0,(a1)+
[000106cc] 22c7                      move.l    d7,(a1)+
[000106ce] 5342                      subq.w    #1,d2
[000106d0] 6b08                      bmi.s     $000106DA
[000106d2] 22c6                      move.l    d6,(a1)+
[000106d4] 22c7                      move.l    d7,(a1)+
[000106d6] 51ca fffa                 dbf       d2,$000106D2
[000106da] 4ed3                      jmp       (a3)
[000106dc] 2006                      move.l    d6,d0
[000106de] 6004                      bra.s     $000106E4
[000106e0] 22c6                      move.l    d6,(a1)+
[000106e2] 2007                      move.l    d7,d0
[000106e4] 8b91                      or.l      d5,(a1)
[000106e6] 4680                      not.l     d0
[000106e8] c085                      and.l     d5,d0
[000106ea] b191                      eor.l     d0,(a1)
[000106ec] 4cdf 0c08                 movem.l   (a7)+,d3/a2-a3
[000106f0] 4e75                      rts
[000106f2] 4686                      not.l     d6
[000106f4] 4687                      not.l     d7
[000106f6] 7808                      moveq.l   #8,d4
[000106f8] c840                      and.w     d0,d4
[000106fa] 247b 400c                 movea.l   $00010708(pc,d4.w),a2
[000106fe] 7a08                      moveq.l   #8,d5
[00010700] ca43                      and.w     d3,d5
[00010702] 267b 5010                 movea.l   $00010714(pc,d5.w),a3
[00010706] 6058                      bra.s     $00010760
[00010708] 0001 07b4                 ori.b     #$B4,d1
[0001070c] 0000 0000                 ori.b     #$00,d0
[00010710] 0001 07aa                 ori.b     #$AA,d1
[00010714] 0001 07e0                 ori.b     #$E0,d1
[00010718] 0000 0000                 ori.b     #$00,d0
[0001071c] 0001 07e4                 ori.b     #$E4,d1
[00010720] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[00010728] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[0001072c] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[00010730] 0000 ffff                 ori.b     #$FF,d0
[00010734] 0000 0fff                 ori.b     #$FF,d0
[00010738] 0000 00ff                 ori.b     #$FF,d0
[0001073c] 0000 000f                 ori.b     #$0F,d0
[00010740] f000 0000                 pmove.l   d0,???
[00010744] ff00                      dc.w      $FF00 ; illegal
[00010746] 0000 fff0                 ori.b     #$F0,d0
[0001074a] 0000 ffff                 ori.b     #$FF,d0
[0001074e] 0000 ffff                 ori.b     #$FF,d0
[00010752] f000                      dc.w      $F000 ; illegal
[00010754] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[0001075c] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[00010764] c644                      and.w     d4,d3
[00010766] d040                      add.w     d0,d0
[00010768] d040                      add.w     d0,d0
[0001076a] d643                      add.w     d3,d3
[0001076c] d643                      add.w     d3,d3
[0001076e] 283b 00b0                 move.l    $00010720(pc,d0.w),d4
[00010772] 2a3b 30cc                 move.l    $00010740(pc,d3.w),d5
[00010776] 4681                      not.l     d1
[00010778] 5342                      subq.w    #1,d2
[0001077a] 6a20                      bpl.s     $0001079C
[0001077c] b5fc 0001 07b4            cmpa.l    #$000107B4,a2
[00010782] 6708                      beq.s     $0001078C
[00010784] ca84                      and.l     d4,d5
[00010786] 7800                      moveq.l   #0,d4
[00010788] 5989                      subq.l    #4,a1
[0001078a] 600c                      bra.s     $00010798
[0001078c] b7fc 0001 07e4            cmpa.l    #$000107E4,a3
[00010792] 6704                      beq.s     $00010798
[00010794] c885                      and.l     d5,d4
[00010796] 7a00                      moveq.l   #0,d5
[00010798] 45fa 0004                 lea.l     $0001079E(pc),a2
[0001079c] 4ed2                      jmp       (a2)
[0001079e] c886                      and.l     d6,d4
[000107a0] 8991                      or.l      d4,(a1)
[000107a2] c881                      and.l     d1,d4
[000107a4] b999                      eor.l     d4,(a1)+
[000107a6] 2007                      move.l    d7,d0
[000107a8] 6044                      bra.s     $000107EE
[000107aa] c887                      and.l     d7,d4
[000107ac] 8991                      or.l      d4,(a1)
[000107ae] c881                      and.l     d1,d4
[000107b0] b999                      eor.l     d4,(a1)+
[000107b2] 6012                      bra.s     $000107C6
[000107b4] 2004                      move.l    d4,d0
[000107b6] c086                      and.l     d6,d0
[000107b8] 8191                      or.l      d0,(a1)
[000107ba] c081                      and.l     d1,d0
[000107bc] b199                      eor.l     d0,(a1)+
[000107be] 8f91                      or.l      d7,(a1)
[000107c0] 2007                      move.l    d7,d0
[000107c2] c081                      and.l     d1,d0
[000107c4] b199                      eor.l     d0,(a1)+
[000107c6] 2001                      move.l    d1,d0
[000107c8] 2801                      move.l    d1,d4
[000107ca] c086                      and.l     d6,d0
[000107cc] c887                      and.l     d7,d4
[000107ce] 5342                      subq.w    #1,d2
[000107d0] 6b0c                      bmi.s     $000107DE
[000107d2] 8d91                      or.l      d6,(a1)
[000107d4] b199                      eor.l     d0,(a1)+
[000107d6] 8f91                      or.l      d7,(a1)
[000107d8] b999                      eor.l     d4,(a1)+
[000107da] 51ca fff6                 dbf       d2,$000107D2
[000107de] 4ed3                      jmp       (a3)
[000107e0] 2006                      move.l    d6,d0
[000107e2] 600a                      bra.s     $000107EE
[000107e4] 8d91                      or.l      d6,(a1)
[000107e6] 2006                      move.l    d6,d0
[000107e8] c081                      and.l     d1,d0
[000107ea] b199                      eor.l     d0,(a1)+
[000107ec] 2007                      move.l    d7,d0
[000107ee] c085                      and.l     d5,d0
[000107f0] 8191                      or.l      d0,(a1)
[000107f2] c081                      and.l     d1,d0
[000107f4] b191                      eor.l     d0,(a1)
[000107f6] 4cdf 0c08                 movem.l   (a7)+,d3/a2-a3
[000107fa] 4e75                      rts
[000107fc] 7808                      moveq.l   #8,d4
[000107fe] c840                      and.w     d0,d4
[00010800] 247b 400c                 movea.l   $0001080E(pc,d4.w),a2
[00010804] 7a08                      moveq.l   #8,d5
[00010806] ca43                      and.w     d3,d5
[00010808] 267b 5010                 movea.l   $0001081A(pc,d5.w),a3
[0001080c] 6058                      bra.s     $00010866
[0001080e] 0001 08b0                 ori.b     #$B0,d1
[00010812] 0000 0000                 ori.b     #$00,d0
[00010816] 0001 08aa                 ori.b     #$AA,d1
[0001081a] 0001 08c6                 ori.b     #$C6,d1
[0001081e] 0000 0000                 ori.b     #$00,d0
[00010822] 0001 08ca                 ori.b     #$CA,d1
[00010826] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[0001082e] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00010832] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[00010836] 0000 ffff                 ori.b     #$FF,d0
[0001083a] 0000 0fff                 ori.b     #$FF,d0
[0001083e] 0000 00ff                 ori.b     #$FF,d0
[00010842] 0000 000f                 ori.b     #$0F,d0
[00010846] f000 0000                 pmove.l   d0,???
[0001084a] ff00                      dc.w      $FF00 ; illegal
[0001084c] 0000 fff0                 ori.b     #$F0,d0
[00010850] 0000 ffff                 ori.b     #$FF,d0
[00010854] 0000 ffff                 ori.b     #$FF,d0
[00010858] f000                      dc.w      $F000 ; illegal
[0001085a] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00010862] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[0001086a] c644                      and.w     d4,d3
[0001086c] d040                      add.w     d0,d0
[0001086e] d040                      add.w     d0,d0
[00010870] d643                      add.w     d3,d3
[00010872] d643                      add.w     d3,d3
[00010874] 283b 00b0                 move.l    $00010826(pc,d0.w),d4
[00010878] 2a3b 30cc                 move.l    $00010846(pc,d3.w),d5
[0001087c] 5342                      subq.w    #1,d2
[0001087e] 6a20                      bpl.s     $000108A0
[00010880] b5fc 0001 08b0            cmpa.l    #$000108B0,a2
[00010886] 6708                      beq.s     $00010890
[00010888] ca84                      and.l     d4,d5
[0001088a] 7800                      moveq.l   #0,d4
[0001088c] 5989                      subq.l    #4,a1
[0001088e] 600c                      bra.s     $0001089C
[00010890] b7fc 0001 08ca            cmpa.l    #$000108CA,a3
[00010896] 6704                      beq.s     $0001089C
[00010898] c885                      and.l     d5,d4
[0001089a] 7a00                      moveq.l   #0,d5
[0001089c] 45fa 0004                 lea.l     $000108A2(pc),a2
[000108a0] 4ed2                      jmp       (a2)
[000108a2] c886                      and.l     d6,d4
[000108a4] b999                      eor.l     d4,(a1)+
[000108a6] ca87                      and.l     d7,d5
[000108a8] 6024                      bra.s     $000108CE
[000108aa] c887                      and.l     d7,d4
[000108ac] b999                      eor.l     d4,(a1)+
[000108ae] 6008                      bra.s     $000108B8
[000108b0] 2006                      move.l    d6,d0
[000108b2] c084                      and.l     d4,d0
[000108b4] b199                      eor.l     d0,(a1)+
[000108b6] bf99                      eor.l     d7,(a1)+
[000108b8] 5342                      subq.w    #1,d2
[000108ba] 6b08                      bmi.s     $000108C4
[000108bc] bd99                      eor.l     d6,(a1)+
[000108be] bf99                      eor.l     d7,(a1)+
[000108c0] 51ca fffa                 dbf       d2,$000108BC
[000108c4] 4ed3                      jmp       (a3)
[000108c6] ca86                      and.l     d6,d5
[000108c8] 6004                      bra.s     $000108CE
[000108ca] bd99                      eor.l     d6,(a1)+
[000108cc] ca87                      and.l     d7,d5
[000108ce] bb91                      eor.l     d5,(a1)
[000108d0] 4cdf 0c08                 movem.l   (a7)+,d3/a2-a3
[000108d4] 4e75                      rts
[000108d6] 4a6e 00ca                 tst.w     202(a6)
[000108da] 6622                      bne.s     $000108FE
[000108dc] 226e 00c6                 movea.l   198(a6),a1
[000108e0] 780f                      moveq.l   #15,d4
[000108e2] c841                      and.w     d1,d4
[000108e4] d844                      add.w     d4,d4
[000108e6] 3c31 4000                 move.w    0(a1,d4.w),d6
[000108ea] 3f2e 0046                 move.w    70(a6),-(a7)
[000108ee] 3d6e 00be 0046            move.w    190(a6),70(a6)
[000108f4] 6100 fc98                 bsr       $0001058E
[000108f8] 3d5f 0046                 move.w    (a7)+,70(a6)
[000108fc] 4e75                      rts
[000108fe] 2278 044e                 movea.l   ($0000044E).w,a1
[00010902] 3838 206e                 move.w    ($0000206E).w,d4
[00010906] 4a6e 01b2                 tst.w     434(a6)
[0001090a] 6708                      beq.s     $00010914
[0001090c] 226e 01ae                 movea.l   430(a6),a1
[00010910] 382e 01b2                 move.w    434(a6),d4
[00010914] c9c1                      muls.w    d1,d4
[00010916] d3c4                      adda.l    d4,a1
[00010918] 78f8                      moveq.l   #-8,d4
[0001091a] c840                      and.w     d0,d4
[0001091c] e24c                      lsr.w     #1,d4
[0001091e] d2c4                      adda.w    d4,a1
[00010920] 48e7 1030                 movem.l   d3/a2-a3,-(a7)
[00010924] 3a07                      move.w    d7,d5
[00010926] 246e 00c6                 movea.l   198(a6),a2
[0001092a] 780f                      moveq.l   #15,d4
[0001092c] c841                      and.w     d1,d4
[0001092e] e74c                      lsl.w     #3,d4
[00010930] d4c4                      adda.w    d4,a2
[00010932] 2c1a                      move.l    (a2)+,d6
[00010934] 2e1a                      move.l    (a2)+,d7
[00010936] 45fa 3024                 lea.l     $0001395C(pc),a2
[0001093a] 322e 00be                 move.w    190(a6),d1
[0001093e] d241                      add.w     d1,d1
[00010940] d241                      add.w     d1,d1
[00010942] 2232 1000                 move.l    0(a2,d1.w),d1
[00010946] 6000 fc9a                 bra       $000105E2
[0001094a] 4e75                      rts
[0001094c] 9641                      sub.w     d1,d3
[0001094e] 43fa 2fbc                 lea.l     $0001390C(pc),a1
[00010952] d2ee 0046                 adda.w    70(a6),a1
[00010956] 1811                      move.b    (a1),d4
[00010958] 2278 044e                 movea.l   ($0000044E).w,a1
[0001095c] 7a00                      moveq.l   #0,d5
[0001095e] 3a38 206e                 move.w    ($0000206E).w,d5
[00010962] 4a6e 01b2                 tst.w     434(a6)
[00010966] 6708                      beq.s     $00010970
[00010968] 226e 01ae                 movea.l   430(a6),a1
[0001096c] 3a2e 01b2                 move.w    434(a6),d5
[00010970] c3c5                      muls.w    d5,d1
[00010972] d3c1                      adda.l    d1,a1
[00010974] 323c 00f0                 move.w    #$00F0,d1
[00010978] e248                      lsr.w     #1,d0
[0001097a] 6504                      bcs.s     $00010980
[0001097c] 720f                      moveq.l   #15,d1
[0001097e] e94c                      lsl.w     #4,d4
[00010980] d2c0                      adda.w    d0,a1
[00010982] de47                      add.w     d7,d7
[00010984] 3e3b 7006                 move.w    $0001098C(pc,d7.w),d7
[00010988] 4efb 7002                 jmp       $0001098C(pc,d7.w)
J1:
[0001098c] 0150                      dc.w $0150   ; $00010adc-$0001098c
[0001098e] 000a                      dc.w $000a   ; $00010996-$0001098c
[00010990] 00c6                      dc.w $00c6   ; $00010a52-$0001098c
[00010992] 0008                      dc.w $0008   ; $00010994-$0001098c
[00010994] 4646                      not.w     d6
[00010996] 3f05                      move.w    d5,-(a7)
[00010998] e98d                      lsl.l     #4,d5
[0001099a] 700f                      moveq.l   #15,d0
[0001099c] b640                      cmp.w     d0,d3
[0001099e] 6c02                      bge.s     $000109A2
[000109a0] 3003                      move.w    d3,d0
[000109a2] 2409                      move.l    a1,d2
[000109a4] dc46                      add.w     d6,d6
[000109a6] 6400 0086                 bcc       $00010A2E
[000109aa] 3f03                      move.w    d3,-(a7)
[000109ac] e84b                      lsr.w     #4,d3
[000109ae] 3e03                      move.w    d3,d7
[000109b0] e84b                      lsr.w     #4,d3
[000109b2] 4647                      not.w     d7
[000109b4] 0247 000f                 andi.w    #$000F,d7
[000109b8] 4840                      swap      d0
[000109ba] 3007                      move.w    d7,d0
[000109bc] de47                      add.w     d7,d7
[000109be] de40                      add.w     d0,d7
[000109c0] 4840                      swap      d0
[000109c2] de47                      add.w     d7,d7
[000109c4] 4efb 7002                 jmp       $000109C8(pc,d7.w)
[000109c8] c311                      and.b     d1,(a1)
[000109ca] 8911                      or.b      d4,(a1)
[000109cc] d3c5                      adda.l    d5,a1
[000109ce] c311                      and.b     d1,(a1)
[000109d0] 8911                      or.b      d4,(a1)
[000109d2] d3c5                      adda.l    d5,a1
[000109d4] c311                      and.b     d1,(a1)
[000109d6] 8911                      or.b      d4,(a1)
[000109d8] d3c5                      adda.l    d5,a1
[000109da] c311                      and.b     d1,(a1)
[000109dc] 8911                      or.b      d4,(a1)
[000109de] d3c5                      adda.l    d5,a1
[000109e0] c311                      and.b     d1,(a1)
[000109e2] 8911                      or.b      d4,(a1)
[000109e4] d3c5                      adda.l    d5,a1
[000109e6] c311                      and.b     d1,(a1)
[000109e8] 8911                      or.b      d4,(a1)
[000109ea] d3c5                      adda.l    d5,a1
[000109ec] c311                      and.b     d1,(a1)
[000109ee] 8911                      or.b      d4,(a1)
[000109f0] d3c5                      adda.l    d5,a1
[000109f2] c311                      and.b     d1,(a1)
[000109f4] 8911                      or.b      d4,(a1)
[000109f6] d3c5                      adda.l    d5,a1
[000109f8] c311                      and.b     d1,(a1)
[000109fa] 8911                      or.b      d4,(a1)
[000109fc] d3c5                      adda.l    d5,a1
[000109fe] c311                      and.b     d1,(a1)
[00010a00] 8911                      or.b      d4,(a1)
[00010a02] d3c5                      adda.l    d5,a1
[00010a04] c311                      and.b     d1,(a1)
[00010a06] 8911                      or.b      d4,(a1)
[00010a08] d3c5                      adda.l    d5,a1
[00010a0a] c311                      and.b     d1,(a1)
[00010a0c] 8911                      or.b      d4,(a1)
[00010a0e] d3c5                      adda.l    d5,a1
[00010a10] c311                      and.b     d1,(a1)
[00010a12] 8911                      or.b      d4,(a1)
[00010a14] d3c5                      adda.l    d5,a1
[00010a16] c311                      and.b     d1,(a1)
[00010a18] 8911                      or.b      d4,(a1)
[00010a1a] d3c5                      adda.l    d5,a1
[00010a1c] c311                      and.b     d1,(a1)
[00010a1e] 8911                      or.b      d4,(a1)
[00010a20] d3c5                      adda.l    d5,a1
[00010a22] c311                      and.b     d1,(a1)
[00010a24] 8911                      or.b      d4,(a1)
[00010a26] d3c5                      adda.l    d5,a1
[00010a28] 51cb ff9e                 dbf       d3,$000109C8
[00010a2c] 361f                      move.w    (a7)+,d3
[00010a2e] 2242                      movea.l   d2,a1
[00010a30] d2d7                      adda.w    (a7),a1
[00010a32] 5343                      subq.w    #1,d3
[00010a34] 51c8 ff6c                 dbf       d0,$000109A2
[00010a38] 548f                      addq.l    #2,a7
[00010a3a] 4e75                      rts
[00010a3c] d2c5                      adda.w    d5,a1
[00010a3e] 51cb 0004                 dbf       d3,$00010A44
[00010a42] 4e75                      rts
[00010a44] da45                      add.w     d5,d5
[00010a46] e24b                      lsr.w     #1,d3
[00010a48] b911                      eor.b     d4,(a1)
[00010a4a] d2c5                      adda.w    d5,a1
[00010a4c] 51cb fffa                 dbf       d3,$00010A48
[00010a50] 4e75                      rts
[00010a52] 3801                      move.w    d1,d4
[00010a54] 4644                      not.w     d4
[00010a56] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010a5a] 67e8                      beq.s     $00010A44
[00010a5c] bc7c 5555                 cmp.w     #$5555,d6
[00010a60] 67da                      beq.s     $00010A3C
[00010a62] 3f05                      move.w    d5,-(a7)
[00010a64] e98d                      lsl.l     #4,d5
[00010a66] 700f                      moveq.l   #15,d0
[00010a68] b640                      cmp.w     d0,d3
[00010a6a] 6c02                      bge.s     $00010A6E
[00010a6c] 3003                      move.w    d3,d0
[00010a6e] 2409                      move.l    a1,d2
[00010a70] dc46                      add.w     d6,d6
[00010a72] 645a                      bcc.s     $00010ACE
[00010a74] 3203                      move.w    d3,d1
[00010a76] e849                      lsr.w     #4,d1
[00010a78] 3e01                      move.w    d1,d7
[00010a7a] e849                      lsr.w     #4,d1
[00010a7c] 4647                      not.w     d7
[00010a7e] 0247 000f                 andi.w    #$000F,d7
[00010a82] de47                      add.w     d7,d7
[00010a84] de47                      add.w     d7,d7
[00010a86] 4efb 7002                 jmp       $00010A8A(pc,d7.w)
[00010a8a] b911                      eor.b     d4,(a1)
[00010a8c] d3c5                      adda.l    d5,a1
[00010a8e] b911                      eor.b     d4,(a1)
[00010a90] d3c5                      adda.l    d5,a1
[00010a92] b911                      eor.b     d4,(a1)
[00010a94] d3c5                      adda.l    d5,a1
[00010a96] b911                      eor.b     d4,(a1)
[00010a98] d3c5                      adda.l    d5,a1
[00010a9a] b911                      eor.b     d4,(a1)
[00010a9c] d3c5                      adda.l    d5,a1
[00010a9e] b911                      eor.b     d4,(a1)
[00010aa0] d3c5                      adda.l    d5,a1
[00010aa2] b911                      eor.b     d4,(a1)
[00010aa4] d3c5                      adda.l    d5,a1
[00010aa6] b911                      eor.b     d4,(a1)
[00010aa8] d3c5                      adda.l    d5,a1
[00010aaa] b911                      eor.b     d4,(a1)
[00010aac] d3c5                      adda.l    d5,a1
[00010aae] b911                      eor.b     d4,(a1)
[00010ab0] d3c5                      adda.l    d5,a1
[00010ab2] b911                      eor.b     d4,(a1)
[00010ab4] d3c5                      adda.l    d5,a1
[00010ab6] b911                      eor.b     d4,(a1)
[00010ab8] d3c5                      adda.l    d5,a1
[00010aba] b911                      eor.b     d4,(a1)
[00010abc] d3c5                      adda.l    d5,a1
[00010abe] b911                      eor.b     d4,(a1)
[00010ac0] d3c5                      adda.l    d5,a1
[00010ac2] b911                      eor.b     d4,(a1)
[00010ac4] d3c5                      adda.l    d5,a1
[00010ac6] b911                      eor.b     d4,(a1)
[00010ac8] d3c5                      adda.l    d5,a1
[00010aca] 51c9 ffbe                 dbf       d1,$00010A8A
[00010ace] 2242                      movea.l   d2,a1
[00010ad0] d2d7                      adda.w    (a7),a1
[00010ad2] 5343                      subq.w    #1,d3
[00010ad4] 51c8 ff98                 dbf       d0,$00010A6E
[00010ad8] 548f                      addq.l    #2,a7
[00010ada] 4e75                      rts
[00010adc] bc7c ffff                 cmp.w     #$FFFF,d6
[00010ae0] 6700 00a8                 beq       $00010B8A
[00010ae4] 3f05                      move.w    d5,-(a7)
[00010ae6] e98d                      lsl.l     #4,d5
[00010ae8] 700f                      moveq.l   #15,d0
[00010aea] b640                      cmp.w     d0,d3
[00010aec] 6c02                      bge.s     $00010AF0
[00010aee] 3003                      move.w    d3,d0
[00010af0] 2f09                      move.l    a1,-(a7)
[00010af2] 3f03                      move.w    d3,-(a7)
[00010af4] dc46                      add.w     d6,d6
[00010af6] 55c2                      scs       d2
[00010af8] c444                      and.w     d4,d2
[00010afa] e84b                      lsr.w     #4,d3
[00010afc] 3e03                      move.w    d3,d7
[00010afe] e84b                      lsr.w     #4,d3
[00010b00] 4647                      not.w     d7
[00010b02] 0247 000f                 andi.w    #$000F,d7
[00010b06] 4840                      swap      d0
[00010b08] 3007                      move.w    d7,d0
[00010b0a] de47                      add.w     d7,d7
[00010b0c] de40                      add.w     d0,d7
[00010b0e] 4840                      swap      d0
[00010b10] de47                      add.w     d7,d7
[00010b12] 4efb 7002                 jmp       $00010B16(pc,d7.w)
[00010b16] c311                      and.b     d1,(a1)
[00010b18] 8511                      or.b      d2,(a1)
[00010b1a] d3c5                      adda.l    d5,a1
[00010b1c] c311                      and.b     d1,(a1)
[00010b1e] 8511                      or.b      d2,(a1)
[00010b20] d3c5                      adda.l    d5,a1
[00010b22] c311                      and.b     d1,(a1)
[00010b24] 8511                      or.b      d2,(a1)
[00010b26] d3c5                      adda.l    d5,a1
[00010b28] c311                      and.b     d1,(a1)
[00010b2a] 8511                      or.b      d2,(a1)
[00010b2c] d3c5                      adda.l    d5,a1
[00010b2e] c311                      and.b     d1,(a1)
[00010b30] 8511                      or.b      d2,(a1)
[00010b32] d3c5                      adda.l    d5,a1
[00010b34] c311                      and.b     d1,(a1)
[00010b36] 8511                      or.b      d2,(a1)
[00010b38] d3c5                      adda.l    d5,a1
[00010b3a] c311                      and.b     d1,(a1)
[00010b3c] 8511                      or.b      d2,(a1)
[00010b3e] d3c5                      adda.l    d5,a1
[00010b40] c311                      and.b     d1,(a1)
[00010b42] 8511                      or.b      d2,(a1)
[00010b44] d3c5                      adda.l    d5,a1
[00010b46] c311                      and.b     d1,(a1)
[00010b48] 8511                      or.b      d2,(a1)
[00010b4a] d3c5                      adda.l    d5,a1
[00010b4c] c311                      and.b     d1,(a1)
[00010b4e] 8511                      or.b      d2,(a1)
[00010b50] d3c5                      adda.l    d5,a1
[00010b52] c311                      and.b     d1,(a1)
[00010b54] 8511                      or.b      d2,(a1)
[00010b56] d3c5                      adda.l    d5,a1
[00010b58] c311                      and.b     d1,(a1)
[00010b5a] 8511                      or.b      d2,(a1)
[00010b5c] d3c5                      adda.l    d5,a1
[00010b5e] c311                      and.b     d1,(a1)
[00010b60] 8511                      or.b      d2,(a1)
[00010b62] d3c5                      adda.l    d5,a1
[00010b64] c311                      and.b     d1,(a1)
[00010b66] 8511                      or.b      d2,(a1)
[00010b68] d3c5                      adda.l    d5,a1
[00010b6a] c311                      and.b     d1,(a1)
[00010b6c] 8511                      or.b      d2,(a1)
[00010b6e] d3c5                      adda.l    d5,a1
[00010b70] c311                      and.b     d1,(a1)
[00010b72] 8511                      or.b      d2,(a1)
[00010b74] d3c5                      adda.l    d5,a1
[00010b76] 51cb ff9e                 dbf       d3,$00010B16
[00010b7a] 361f                      move.w    (a7)+,d3
[00010b7c] 225f                      movea.l   (a7)+,a1
[00010b7e] d2d7                      adda.w    (a7),a1
[00010b80] 5343                      subq.w    #1,d3
[00010b82] 51c8 ff6c                 dbf       d0,$00010AF0
[00010b86] 548f                      addq.l    #2,a7
[00010b88] 4e75                      rts
[00010b8a] 3403                      move.w    d3,d2
[00010b8c] 4642                      not.w     d2
[00010b8e] c47c 000f                 and.w     #$000F,d2
[00010b92] b87c 000f                 cmp.w     #$000F,d4
[00010b96] 677a                      beq.s     $00010C12
[00010b98] b87c 00f0                 cmp.w     #$00F0,d4
[00010b9c] 6774                      beq.s     $00010C12
[00010b9e] 3c02                      move.w    d2,d6
[00010ba0] d442                      add.w     d2,d2
[00010ba2] d446                      add.w     d6,d2
[00010ba4] d442                      add.w     d2,d2
[00010ba6] e84b                      lsr.w     #4,d3
[00010ba8] 4efb 2002                 jmp       $00010BAC(pc,d2.w)
[00010bac] c311                      and.b     d1,(a1)
[00010bae] 8911                      or.b      d4,(a1)
[00010bb0] d2c5                      adda.w    d5,a1
[00010bb2] c311                      and.b     d1,(a1)
[00010bb4] 8911                      or.b      d4,(a1)
[00010bb6] d2c5                      adda.w    d5,a1
[00010bb8] c311                      and.b     d1,(a1)
[00010bba] 8911                      or.b      d4,(a1)
[00010bbc] d2c5                      adda.w    d5,a1
[00010bbe] c311                      and.b     d1,(a1)
[00010bc0] 8911                      or.b      d4,(a1)
[00010bc2] d2c5                      adda.w    d5,a1
[00010bc4] c311                      and.b     d1,(a1)
[00010bc6] 8911                      or.b      d4,(a1)
[00010bc8] d2c5                      adda.w    d5,a1
[00010bca] c311                      and.b     d1,(a1)
[00010bcc] 8911                      or.b      d4,(a1)
[00010bce] d2c5                      adda.w    d5,a1
[00010bd0] c311                      and.b     d1,(a1)
[00010bd2] 8911                      or.b      d4,(a1)
[00010bd4] d2c5                      adda.w    d5,a1
[00010bd6] c311                      and.b     d1,(a1)
[00010bd8] 8911                      or.b      d4,(a1)
[00010bda] d2c5                      adda.w    d5,a1
[00010bdc] c311                      and.b     d1,(a1)
[00010bde] 8911                      or.b      d4,(a1)
[00010be0] d2c5                      adda.w    d5,a1
[00010be2] c311                      and.b     d1,(a1)
[00010be4] 8911                      or.b      d4,(a1)
[00010be6] d2c5                      adda.w    d5,a1
[00010be8] c311                      and.b     d1,(a1)
[00010bea] 8911                      or.b      d4,(a1)
[00010bec] d2c5                      adda.w    d5,a1
[00010bee] c311                      and.b     d1,(a1)
[00010bf0] 8911                      or.b      d4,(a1)
[00010bf2] d2c5                      adda.w    d5,a1
[00010bf4] c311                      and.b     d1,(a1)
[00010bf6] 8911                      or.b      d4,(a1)
[00010bf8] d2c5                      adda.w    d5,a1
[00010bfa] c311                      and.b     d1,(a1)
[00010bfc] 8911                      or.b      d4,(a1)
[00010bfe] d2c5                      adda.w    d5,a1
[00010c00] c311                      and.b     d1,(a1)
[00010c02] 8911                      or.b      d4,(a1)
[00010c04] d2c5                      adda.w    d5,a1
[00010c06] c311                      and.b     d1,(a1)
[00010c08] 8911                      or.b      d4,(a1)
[00010c0a] d2c5                      adda.w    d5,a1
[00010c0c] 51cb ff9e                 dbf       d3,$00010BAC
[00010c10] 4e75                      rts
[00010c12] d442                      add.w     d2,d2
[00010c14] d442                      add.w     d2,d2
[00010c16] e84b                      lsr.w     #4,d3
[00010c18] 4efb 2002                 jmp       $00010C1C(pc,d2.w)
[00010c1c] 8911                      or.b      d4,(a1)
[00010c1e] d2c5                      adda.w    d5,a1
[00010c20] 8911                      or.b      d4,(a1)
[00010c22] d2c5                      adda.w    d5,a1
[00010c24] 8911                      or.b      d4,(a1)
[00010c26] d2c5                      adda.w    d5,a1
[00010c28] 8911                      or.b      d4,(a1)
[00010c2a] d2c5                      adda.w    d5,a1
[00010c2c] 8911                      or.b      d4,(a1)
[00010c2e] d2c5                      adda.w    d5,a1
[00010c30] 8911                      or.b      d4,(a1)
[00010c32] d2c5                      adda.w    d5,a1
[00010c34] 8911                      or.b      d4,(a1)
[00010c36] d2c5                      adda.w    d5,a1
[00010c38] 8911                      or.b      d4,(a1)
[00010c3a] d2c5                      adda.w    d5,a1
[00010c3c] 8911                      or.b      d4,(a1)
[00010c3e] d2c5                      adda.w    d5,a1
[00010c40] 8911                      or.b      d4,(a1)
[00010c42] d2c5                      adda.w    d5,a1
[00010c44] 8911                      or.b      d4,(a1)
[00010c46] d2c5                      adda.w    d5,a1
[00010c48] 8911                      or.b      d4,(a1)
[00010c4a] d2c5                      adda.w    d5,a1
[00010c4c] 8911                      or.b      d4,(a1)
[00010c4e] d2c5                      adda.w    d5,a1
[00010c50] 8911                      or.b      d4,(a1)
[00010c52] d2c5                      adda.w    d5,a1
[00010c54] 8911                      or.b      d4,(a1)
[00010c56] d2c5                      adda.w    d5,a1
[00010c58] 8911                      or.b      d4,(a1)
[00010c5a] d2c5                      adda.w    d5,a1
[00010c5c] 51cb ffbe                 dbf       d3,$00010C1C
[00010c60] 4e75                      rts
[00010c62] 2278 044e                 movea.l   ($0000044E).w,a1
[00010c66] 3a38 206e                 move.w    ($0000206E).w,d5
[00010c6a] 4a6e 01b2                 tst.w     434(a6)
[00010c6e] 6708                      beq.s     $00010C78
[00010c70] 226e 01ae                 movea.l   430(a6),a1
[00010c74] 3a2e 01b2                 move.w    434(a6),d5
[00010c78] 2f0b                      move.l    a3,-(a7)
[00010c7a] 3805                      move.w    d5,d4
[00010c7c] c9c1                      muls.w    d1,d4
[00010c7e] d3c4                      adda.l    d4,a1
[00010c80] 3800                      move.w    d0,d4
[00010c82] e24c                      lsr.w     #1,d4
[00010c84] d2c4                      adda.w    d4,a1
[00010c86] 780f                      moveq.l   #15,d4
[00010c88] c840                      and.w     d0,d4
[00010c8a] e97e                      rol.w     d4,d6
[00010c8c] 9440                      sub.w     d0,d2
[00010c8e] 6b44                      bmi.s     $00010CD4
[00010c90] 9641                      sub.w     d1,d3
[00010c92] 6a04                      bpl.s     $00010C98
[00010c94] 4443                      neg.w     d3
[00010c96] 4445                      neg.w     d5
[00010c98] 382e 0046                 move.w    70(a6),d4
[00010c9c] 47fa 2c6e                 lea.l     $0001390C(pc),a3
[00010ca0] 1833 4000                 move.b    0(a3,d4.w),d4
[00010ca4] 3645                      movea.w   d5,a3
[00010ca6] 7a01                      moveq.l   #1,d5
[00010ca8] ca40                      and.w     d0,d5
[00010caa] 6704                      beq.s     $00010CB0
[00010cac] 7af0                      moveq.l   #-16,d5
[00010cae] 6004                      bra.s     $00010CB4
[00010cb0] 7a0f                      moveq.l   #15,d5
[00010cb2] e94c                      lsl.w     #4,d4
[00010cb4] b443                      cmp.w     d3,d2
[00010cb6] 6d28                      blt.s     $00010CE0
[00010cb8] 3002                      move.w    d2,d0
[00010cba] d06e 004e                 add.w     78(a6),d0
[00010cbe] 6b14                      bmi.s     $00010CD4
[00010cc0] 3203                      move.w    d3,d1
[00010cc2] d241                      add.w     d1,d1
[00010cc4] 4442                      neg.w     d2
[00010cc6] 3602                      move.w    d2,d3
[00010cc8] d442                      add.w     d2,d2
[00010cca] de47                      add.w     d7,d7
[00010ccc] 3e3b 700a                 move.w    $00010CD8(pc,d7.w),d7
[00010cd0] 4ebb 7006                 jsr       $00010CD8(pc,d7.w)
[00010cd4] 265f                      movea.l   (a7)+,a3
[00010cd6] 4e75                      rts
[00010cd8] 002e 0076 0098            ori.b     #$76,152(a6)
[00010cde] 0074 3003 d06e            ori.w     #$3003,110(a4,a5.w)
[00010ce4] 004e 6bec                 ori.w     #$6BEC,a6 ; apollo only
[00010ce8] 4443                      neg.w     d3
[00010cea] 3203                      move.w    d3,d1
[00010cec] d241                      add.w     d1,d1
[00010cee] d442                      add.w     d2,d2
[00010cf0] de47                      add.w     d7,d7
[00010cf2] 3e3b 700a                 move.w    $00010CFE(pc,d7.w),d7
[00010cf6] 4ebb 7006                 jsr       $00010CFE(pc,d7.w)
[00010cfa] 265f                      movea.l   (a7)+,a3
[00010cfc] 4e75                      rts
[00010cfe] 0090 00e4 010c            ori.l     #$00E4010C,(a0)
[00010d04] 00e2                      dc.w      $00E2 ; illegal
[00010d06] bc7c ffff                 cmp.w     #$FFFF,d6
[00010d0a] 6722                      beq.s     $00010D2E
[00010d0c] cb11                      and.b     d5,(a1)
[00010d0e] e35e                      rol.w     #1,d6
[00010d10] 6402                      bcc.s     $00010D14
[00010d12] 8911                      or.b      d4,(a1)
[00010d14] e81c                      ror.b     #4,d4
[00010d16] 4605                      not.b     d5
[00010d18] ba3c 000f                 cmp.b     #$0F,d5
[00010d1c] 6602                      bne.s     $00010D20
[00010d1e] 5289                      addq.l    #1,a1
[00010d20] d641                      add.w     d1,d3
[00010d22] 6b04                      bmi.s     $00010D28
[00010d24] d2cb                      adda.w    a3,a1
[00010d26] d642                      add.w     d2,d3
[00010d28] 51c8 ffe2                 dbf       d0,$00010D0C
[00010d2c] 4e75                      rts
[00010d2e] cb11                      and.b     d5,(a1)
[00010d30] 8911                      or.b      d4,(a1)
[00010d32] e81c                      ror.b     #4,d4
[00010d34] 4605                      not.b     d5
[00010d36] ba3c 000f                 cmp.b     #$0F,d5
[00010d3a] 6602                      bne.s     $00010D3E
[00010d3c] 5289                      addq.l    #1,a1
[00010d3e] d641                      add.w     d1,d3
[00010d40] 6b04                      bmi.s     $00010D46
[00010d42] d2cb                      adda.w    a3,a1
[00010d44] d642                      add.w     d2,d3
[00010d46] 51c8 ffe6                 dbf       d0,$00010D2E
[00010d4a] 4e75                      rts
[00010d4c] 4646                      not.w     d6
[00010d4e] e35e                      rol.w     #1,d6
[00010d50] 6404                      bcc.s     $00010D56
[00010d52] cb11                      and.b     d5,(a1)
[00010d54] 8911                      or.b      d4,(a1)
[00010d56] e81c                      ror.b     #4,d4
[00010d58] 4605                      not.b     d5
[00010d5a] ba3c 000f                 cmp.b     #$0F,d5
[00010d5e] 6602                      bne.s     $00010D62
[00010d60] 5289                      addq.l    #1,a1
[00010d62] d641                      add.w     d1,d3
[00010d64] 6b04                      bmi.s     $00010D6A
[00010d66] d2cb                      adda.w    a3,a1
[00010d68] d642                      add.w     d2,d3
[00010d6a] 51c8 ffe2                 dbf       d0,$00010D4E
[00010d6e] 4e75                      rts
[00010d70] 4605                      not.b     d5
[00010d72] e35e                      rol.w     #1,d6
[00010d74] 6402                      bcc.s     $00010D78
[00010d76] bb11                      eor.b     d5,(a1)
[00010d78] ba3c 000f                 cmp.b     #$0F,d5
[00010d7c] 6602                      bne.s     $00010D80
[00010d7e] 5289                      addq.l    #1,a1
[00010d80] d641                      add.w     d1,d3
[00010d82] 6b04                      bmi.s     $00010D88
[00010d84] d2cb                      adda.w    a3,a1
[00010d86] d642                      add.w     d2,d3
[00010d88] 51c8 ffe6                 dbf       d0,$00010D70
[00010d8c] 4e75                      rts
[00010d8e] bc7c ffff                 cmp.w     #$FFFF,d6
[00010d92] 6728                      beq.s     $00010DBC
[00010d94] cb11                      and.b     d5,(a1)
[00010d96] e35e                      rol.w     #1,d6
[00010d98] 6402                      bcc.s     $00010D9C
[00010d9a] 8911                      or.b      d4,(a1)
[00010d9c] d2cb                      adda.w    a3,a1
[00010d9e] d642                      add.w     d2,d3
[00010da0] 6a06                      bpl.s     $00010DA8
[00010da2] 51c8 fff0                 dbf       d0,$00010D94
[00010da6] 4e75                      rts
[00010da8] d641                      add.w     d1,d3
[00010daa] e81c                      ror.b     #4,d4
[00010dac] 4645                      not.w     d5
[00010dae] ba3c 000f                 cmp.b     #$0F,d5
[00010db2] 6602                      bne.s     $00010DB6
[00010db4] 5289                      addq.l    #1,a1
[00010db6] 51c8 ffdc                 dbf       d0,$00010D94
[00010dba] 4e75                      rts
[00010dbc] cb11                      and.b     d5,(a1)
[00010dbe] 8911                      or.b      d4,(a1)
[00010dc0] d2cb                      adda.w    a3,a1
[00010dc2] d642                      add.w     d2,d3
[00010dc4] 6a06                      bpl.s     $00010DCC
[00010dc6] 51c8 fff4                 dbf       d0,$00010DBC
[00010dca] 4e75                      rts
[00010dcc] d641                      add.w     d1,d3
[00010dce] e81c                      ror.b     #4,d4
[00010dd0] 4645                      not.w     d5
[00010dd2] ba3c 000f                 cmp.b     #$0F,d5
[00010dd6] 6602                      bne.s     $00010DDA
[00010dd8] 5289                      addq.l    #1,a1
[00010dda] 51c8 ffe0                 dbf       d0,$00010DBC
[00010dde] 4e75                      rts
[00010de0] 4646                      not.w     d6
[00010de2] e35e                      rol.w     #1,d6
[00010de4] 6404                      bcc.s     $00010DEA
[00010de6] cb11                      and.b     d5,(a1)
[00010de8] 8911                      or.b      d4,(a1)
[00010dea] d2cb                      adda.w    a3,a1
[00010dec] d642                      add.w     d2,d3
[00010dee] 6a06                      bpl.s     $00010DF6
[00010df0] 51c8 fff0                 dbf       d0,$00010DE2
[00010df4] 4e75                      rts
[00010df6] d641                      add.w     d1,d3
[00010df8] e81c                      ror.b     #4,d4
[00010dfa] 4645                      not.w     d5
[00010dfc] ba3c 000f                 cmp.b     #$0F,d5
[00010e00] 6602                      bne.s     $00010E04
[00010e02] 5289                      addq.l    #1,a1
[00010e04] 51c8 ffdc                 dbf       d0,$00010DE2
[00010e08] 4e75                      rts
[00010e0a] 4605                      not.b     d5
[00010e0c] e35e                      rol.w     #1,d6
[00010e0e] 6402                      bcc.s     $00010E12
[00010e10] bb11                      eor.b     d5,(a1)
[00010e12] d2cb                      adda.w    a3,a1
[00010e14] d642                      add.w     d2,d3
[00010e16] 6a06                      bpl.s     $00010E1E
[00010e18] 51c8 fff2                 dbf       d0,$00010E0C
[00010e1c] 4e75                      rts
[00010e1e] d641                      add.w     d1,d3
[00010e20] 4605                      not.b     d5
[00010e22] ba3c 00f0                 cmp.b     #$F0,d5
[00010e26] 6602                      bne.s     $00010E2A
[00010e28] 5289                      addq.l    #1,a1
[00010e2a] 51c8 ffe0                 dbf       d0,$00010E0C
[00010e2e] 4e75                      rts
[00010e30] 2278 044e                 movea.l   ($0000044E).w,a1
[00010e34] 3838 206e                 move.w    ($0000206E).w,d4
[00010e38] 4a6e 01b2                 tst.w     434(a6)
[00010e3c] 6708                      beq.s     $00010E46
[00010e3e] 226e 01ae                 movea.l   430(a6),a1
[00010e42] 382e 01b2                 move.w    434(a6),d4
[00010e46] 9641                      sub.w     d1,d3
[00010e48] 206e 0020                 movea.l   32(a6),a0
[00010e4c] 286e 00c6                 movea.l   198(a6),a4
[00010e50] 3c04                      move.w    d4,d6
[00010e52] c9c1                      muls.w    d1,d4
[00010e54] d3c4                      adda.l    d4,a1
[00010e56] 3e2e 003c                 move.w    60(a6),d7
[00010e5a] 6612                      bne.s     $00010E6E
[00010e5c] 4a6e 00c0                 tst.w     192(a6)
[00010e60] 6700 0212                 beq       $00011074
[00010e64] 0c6e 0001 00c0            cmpi.w    #$0001,192(a6)
[00010e6a] 6700 020c                 beq       $00011078
[00010e6e] 3f06                      move.w    d6,-(a7)
[00010e70] 78f8                      moveq.l   #-8,d4
[00010e72] c840                      and.w     d0,d4
[00010e74] e24c                      lsr.w     #1,d4
[00010e76] d2c4                      adda.w    d4,a1
[00010e78] 7af8                      moveq.l   #-8,d5
[00010e7a] ca42                      and.w     d2,d5
[00010e7c] e24d                      lsr.w     #1,d5
[00010e7e] 9a44                      sub.w     d4,d5
[00010e80] 48c5                      ext.l     d5
[00010e82] 48c6                      ext.l     d6
[00010e84] e94e                      lsl.w     #4,d6
[00010e86] 9c45                      sub.w     d5,d6
[00010e88] 2646                      movea.l   d6,a3
[00010e8a] 5347                      subq.w    #1,d7
[00010e8c] 6700 02b8                 beq       $00011146
[00010e90] 5347                      subq.w    #1,d7
[00010e92] 6700 048c                 beq       $00011320
[00010e96] 5347                      subq.w    #1,d7
[00010e98] 6700 0626                 beq       $000114C0
[00010e9c] 4bfa 2abe                 lea.l     $0001395C(pc),a5
[00010ea0] 3e2e 00be                 move.w    190(a6),d7
[00010ea4] de47                      add.w     d7,d7
[00010ea6] de47                      add.w     d7,d7
[00010ea8] 2e35 7000                 move.l    0(a5,d7.w),d7
[00010eac] 2f08                      move.l    a0,-(a7)
[00010eae] 4a6e 00ca                 tst.w     202(a6)
[00010eb2] 6736                      beq.s     $00010EEA
[00010eb4] 7c0f                      moveq.l   #15,d6
[00010eb6] c246                      and.w     d6,d1
[00010eb8] 671e                      beq.s     $00010ED8
[00010eba] 3a01                      move.w    d1,d5
[00010ebc] bd45                      eor.w     d6,d5
[00010ebe] 3c01                      move.w    d1,d6
[00010ec0] 5346                      subq.w    #1,d6
[00010ec2] e749                      lsl.w     #3,d1
[00010ec4] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00010ec8] 221a                      move.l    (a2)+,d1
[00010eca] c287                      and.l     d7,d1
[00010ecc] 20c1                      move.l    d1,(a0)+
[00010ece] 221a                      move.l    (a2)+,d1
[00010ed0] c287                      and.l     d7,d1
[00010ed2] 20c1                      move.l    d1,(a0)+
[00010ed4] 51cd fff2                 dbf       d5,$00010EC8
[00010ed8] 221c                      move.l    (a4)+,d1
[00010eda] c287                      and.l     d7,d1
[00010edc] 20c1                      move.l    d1,(a0)+
[00010ede] 221c                      move.l    (a4)+,d1
[00010ee0] c287                      and.l     d7,d1
[00010ee2] 20c1                      move.l    d1,(a0)+
[00010ee4] 51ce fff2                 dbf       d6,$00010ED8
[00010ee8] 6060                      bra.s     $00010F4A
[00010eea] 4dfa 2af6                 lea.l     $000139E2(pc),a6
[00010eee] 7c0f                      moveq.l   #15,d6
[00010ef0] c246                      and.w     d6,d1
[00010ef2] 6732                      beq.s     $00010F26
[00010ef4] 3a01                      move.w    d1,d5
[00010ef6] bd45                      eor.w     d6,d5
[00010ef8] 3c01                      move.w    d1,d6
[00010efa] 5346                      subq.w    #1,d6
[00010efc] d241                      add.w     d1,d1
[00010efe] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00010f02] 7200                      moveq.l   #0,d1
[00010f04] 121a                      move.b    (a2)+,d1
[00010f06] e549                      lsl.w     #2,d1
[00010f08] 2a4e                      movea.l   a6,a5
[00010f0a] dac1                      adda.w    d1,a5
[00010f0c] 221d                      move.l    (a5)+,d1
[00010f0e] c287                      and.l     d7,d1
[00010f10] 20c1                      move.l    d1,(a0)+
[00010f12] 7200                      moveq.l   #0,d1
[00010f14] 121a                      move.b    (a2)+,d1
[00010f16] e549                      lsl.w     #2,d1
[00010f18] 2a4e                      movea.l   a6,a5
[00010f1a] dac1                      adda.w    d1,a5
[00010f1c] 221d                      move.l    (a5)+,d1
[00010f1e] c287                      and.l     d7,d1
[00010f20] 20c1                      move.l    d1,(a0)+
[00010f22] 51cd ffde                 dbf       d5,$00010F02
[00010f26] 7200                      moveq.l   #0,d1
[00010f28] 121c                      move.b    (a4)+,d1
[00010f2a] e549                      lsl.w     #2,d1
[00010f2c] 2a4e                      movea.l   a6,a5
[00010f2e] dac1                      adda.w    d1,a5
[00010f30] 221d                      move.l    (a5)+,d1
[00010f32] c287                      and.l     d7,d1
[00010f34] 20c1                      move.l    d1,(a0)+
[00010f36] 7200                      moveq.l   #0,d1
[00010f38] 121c                      move.b    (a4)+,d1
[00010f3a] e549                      lsl.w     #2,d1
[00010f3c] 2a4e                      movea.l   a6,a5
[00010f3e] dac1                      adda.w    d1,a5
[00010f40] 221d                      move.l    (a5)+,d1
[00010f42] c287                      and.l     d7,d1
[00010f44] 20c1                      move.l    d1,(a0)+
[00010f46] 51ce ffde                 dbf       d6,$00010F26
[00010f4a] 205f                      movea.l   (a7)+,a0
[00010f4c] 3c02                      move.w    d2,d6
[00010f4e] e84a                      lsr.w     #4,d2
[00010f50] 3800                      move.w    d0,d4
[00010f52] e84c                      lsr.w     #4,d4
[00010f54] 9444                      sub.w     d4,d2
[00010f56] 7808                      moveq.l   #8,d4
[00010f58] c840                      and.w     d0,d4
[00010f5a] 247b 400c                 movea.l   $00010F68(pc,d4.w),a2
[00010f5e] 7a08                      moveq.l   #8,d5
[00010f60] ca46                      and.w     d6,d5
[00010f62] 2c7b 5010                 movea.l   $00010F74(pc,d5.w),a6
[00010f66] 6058                      bra.s     $00010FC0
[00010f68] 0001 1032                 ori.b     #$32,d1
[00010f6c] 0000 0000                 ori.b     #$00,d0
[00010f70] 0001 1026                 ori.b     #$26,d1
[00010f74] 0001 104e                 ori.b     #$4E,d1
[00010f78] 0000 0000                 ori.b     #$00,d0
[00010f7c] 0001 1052                 ori.b     #$52,d1
[00010f80] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[00010f88] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00010f8c] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[00010f90] 0000 ffff                 ori.b     #$FF,d0
[00010f94] 0000 0fff                 ori.b     #$FF,d0
[00010f98] 0000 00ff                 ori.b     #$FF,d0
[00010f9c] 0000 000f                 ori.b     #$0F,d0
[00010fa0] f000 0000                 pmove.l   d0,???
[00010fa4] ff00                      dc.w      $FF00 ; illegal
[00010fa6] 0000 fff0                 ori.b     #$F0,d0
[00010faa] 0000 ffff                 ori.b     #$FF,d0
[00010fae] 0000 ffff                 ori.b     #$FF,d0
[00010fb2] f000                      dc.w      $F000 ; illegal
[00010fb4] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00010fbc] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[00010fc4] cc44                      and.w     d4,d6
[00010fc6] d040                      add.w     d0,d0
[00010fc8] d040                      add.w     d0,d0
[00010fca] dc46                      add.w     d6,d6
[00010fcc] dc46                      add.w     d6,d6
[00010fce] 283b 00b0                 move.l    $00010F80(pc,d0.w),d4
[00010fd2] 2a3b 60cc                 move.l    $00010FA0(pc,d6.w),d5
[00010fd6] 5342                      subq.w    #1,d2
[00010fd8] 6a24                      bpl.s     $00010FFE
[00010fda] b5fc 0001 1032            cmpa.l    #$00011032,a2
[00010fe0] 670a                      beq.s     $00010FEC
[00010fe2] ca84                      and.l     d4,d5
[00010fe4] 7800                      moveq.l   #0,d4
[00010fe6] 5989                      subq.l    #4,a1
[00010fe8] 598b                      subq.l    #4,a3
[00010fea] 600e                      bra.s     $00010FFA
[00010fec] bdfc 0001 1052            cmpa.l    #$00011052,a6
[00010ff2] 6706                      beq.s     $00010FFA
[00010ff4] c885                      and.l     d5,d4
[00010ff6] 7a00                      moveq.l   #0,d5
[00010ff8] 598b                      subq.l    #4,a3
[00010ffa] 45fa 001c                 lea.l     $00011018(pc),a2
[00010ffe] 700f                      moveq.l   #15,d0
[00011000] b640                      cmp.w     d0,d3
[00011002] 6c02                      bge.s     $00011006
[00011004] 3003                      move.w    d3,d0
[00011006] 4843                      swap      d3
[00011008] 3600                      move.w    d0,d3
[0001100a] 4843                      swap      d3
[0001100c] 3203                      move.w    d3,d1
[0001100e] e849                      lsr.w     #4,d1
[00011010] 2c18                      move.l    (a0)+,d6
[00011012] 2e18                      move.l    (a0)+,d7
[00011014] 2f09                      move.l    a1,-(a7)
[00011016] 4ed2                      jmp       (a2)
[00011018] 8991                      or.l      d4,(a1)
[0001101a] 2006                      move.l    d6,d0
[0001101c] 4680                      not.l     d0
[0001101e] c084                      and.l     d4,d0
[00011020] b199                      eor.l     d0,(a1)+
[00011022] 2007                      move.l    d7,d0
[00011024] 6030                      bra.s     $00011056
[00011026] 8991                      or.l      d4,(a1)
[00011028] 2007                      move.l    d7,d0
[0001102a] 4680                      not.l     d0
[0001102c] c084                      and.l     d4,d0
[0001102e] b199                      eor.l     d0,(a1)+
[00011030] 600c                      bra.s     $0001103E
[00011032] 8991                      or.l      d4,(a1)
[00011034] 2006                      move.l    d6,d0
[00011036] 4680                      not.l     d0
[00011038] c084                      and.l     d4,d0
[0001103a] b199                      eor.l     d0,(a1)+
[0001103c] 22c7                      move.l    d7,(a1)+
[0001103e] 3002                      move.w    d2,d0
[00011040] 5340                      subq.w    #1,d0
[00011042] 6b08                      bmi.s     $0001104C
[00011044] 22c6                      move.l    d6,(a1)+
[00011046] 22c7                      move.l    d7,(a1)+
[00011048] 51c8 fffa                 dbf       d0,$00011044
[0001104c] 4ed6                      jmp       (a6)
[0001104e] 2006                      move.l    d6,d0
[00011050] 6004                      bra.s     $00011056
[00011052] 22c6                      move.l    d6,(a1)+
[00011054] 2007                      move.l    d7,d0
[00011056] 8b91                      or.l      d5,(a1)
[00011058] 4680                      not.l     d0
[0001105a] c085                      and.l     d5,d0
[0001105c] b191                      eor.l     d0,(a1)
[0001105e] d3cb                      adda.l    a3,a1
[00011060] 51c9 ffb4                 dbf       d1,$00011016
[00011064] 225f                      movea.l   (a7)+,a1
[00011066] d2d7                      adda.w    (a7),a1
[00011068] 5343                      subq.w    #1,d3
[0001106a] 4843                      swap      d3
[0001106c] 51cb ff9c                 dbf       d3,$0001100A
[00011070] 548f                      addq.l    #2,a7
[00011072] 4e75                      rts
[00011074] 7e00                      moveq.l   #0,d7
[00011076] 6010                      bra.s     $00011088
[00011078] 4bfa 28e2                 lea.l     $0001395C(pc),a5
[0001107c] 3e2e 00be                 move.w    190(a6),d7
[00011080] de47                      add.w     d7,d7
[00011082] de47                      add.w     d7,d7
[00011084] 2e35 7000                 move.l    0(a5,d7.w),d7
[00011088] 78f8                      moveq.l   #-8,d4
[0001108a] c840                      and.w     d0,d4
[0001108c] e24c                      lsr.w     #1,d4
[0001108e] d2c4                      adda.w    d4,a1
[00011090] 3646                      movea.w   d6,a3
[00011092] 3c02                      move.w    d2,d6
[00011094] e64a                      lsr.w     #3,d2
[00011096] 3800                      move.w    d0,d4
[00011098] e64c                      lsr.w     #3,d4
[0001109a] 9444                      sub.w     d4,d2
[0001109c] 6040                      bra.s     $000110DE
[0001109e] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[000110a6] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[000110aa] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[000110ae] 0000 ffff                 ori.b     #$FF,d0
[000110b2] 0000 0fff                 ori.b     #$FF,d0
[000110b6] 0000 00ff                 ori.b     #$FF,d0
[000110ba] 0000 000f                 ori.b     #$0F,d0
[000110be] f000 0000                 pmove.l   d0,???
[000110c2] ff00                      dc.w      $FF00 ; illegal
[000110c4] 0000 fff0                 ori.b     #$F0,d0
[000110c8] 0000 ffff                 ori.b     #$FF,d0
[000110cc] 0000 ffff                 ori.b     #$FF,d0
[000110d0] f000                      dc.w      $F000 ; illegal
[000110d2] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[000110da] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[000110e2] cc44                      and.w     d4,d6
[000110e4] d040                      add.w     d0,d0
[000110e6] d040                      add.w     d0,d0
[000110e8] dc46                      add.w     d6,d6
[000110ea] dc46                      add.w     d6,d6
[000110ec] 283b 00b0                 move.l    $0001109E(pc,d0.w),d4
[000110f0] 2a3b 60cc                 move.l    $000110BE(pc,d6.w),d5
[000110f4] 45fa 0036                 lea.l     $0001112C(pc),a2
[000110f8] 3002                      move.w    d2,d0
[000110fa] 5542                      subq.w    #2,d2
[000110fc] e24a                      lsr.w     #1,d2
[000110fe] 6502                      bcs.s     $00011102
[00011100] 548a                      addq.l    #2,a2
[00011102] 3200                      move.w    d0,d1
[00011104] d241                      add.w     d1,d1
[00011106] d241                      add.w     d1,d1
[00011108] 96c1                      suba.w    d1,a3
[0001110a] 5540                      subq.w    #2,d0
[0001110c] 6a10                      bpl.s     $0001111E
[0001110e] 45fa 0024                 lea.l     $00011134(pc),a2
[00011112] 5240                      addq.w    #1,d0
[00011114] 6708                      beq.s     $0001111E
[00011116] 594b                      subq.w    #4,a3
[00011118] c885                      and.l     d5,d4
[0001111a] 45fa 0022                 lea.l     $0001113E(pc),a2
[0001111e] 8991                      or.l      d4,(a1)
[00011120] 2007                      move.l    d7,d0
[00011122] 4680                      not.l     d0
[00011124] c084                      and.l     d4,d0
[00011126] b199                      eor.l     d0,(a1)+
[00011128] 3002                      move.w    d2,d0
[0001112a] 4ed2                      jmp       (a2)
[0001112c] 22c7                      move.l    d7,(a1)+
[0001112e] 22c7                      move.l    d7,(a1)+
[00011130] 51c8 fffa                 dbf       d0,$0001112C
[00011134] 2007                      move.l    d7,d0
[00011136] 8b91                      or.l      d5,(a1)
[00011138] 4680                      not.l     d0
[0001113a] c085                      and.l     d5,d0
[0001113c] b191                      eor.l     d0,(a1)
[0001113e] d2cb                      adda.w    a3,a1
[00011140] 51cb ffdc                 dbf       d3,$0001111E
[00011144] 4e75                      rts
[00011146] 4bfa 2814                 lea.l     $0001395C(pc),a5
[0001114a] 3e2e 00be                 move.w    190(a6),d7
[0001114e] de47                      add.w     d7,d7
[00011150] de47                      add.w     d7,d7
[00011152] 2e35 7000                 move.l    0(a5,d7.w),d7
[00011156] 2f08                      move.l    a0,-(a7)
[00011158] 4a6e 00ca                 tst.w     202(a6)
[0001115c] 6726                      beq.s     $00011184
[0001115e] 7c0f                      moveq.l   #15,d6
[00011160] c246                      and.w     d6,d1
[00011162] 6716                      beq.s     $0001117A
[00011164] 3a01                      move.w    d1,d5
[00011166] bd45                      eor.w     d6,d5
[00011168] 3c01                      move.w    d1,d6
[0001116a] 5346                      subq.w    #1,d6
[0001116c] e749                      lsl.w     #3,d1
[0001116e] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011172] 20da                      move.l    (a2)+,(a0)+
[00011174] 20da                      move.l    (a2)+,(a0)+
[00011176] 51cd fffa                 dbf       d5,$00011172
[0001117a] 20dc                      move.l    (a4)+,(a0)+
[0001117c] 20dc                      move.l    (a4)+,(a0)+
[0001117e] 51ce fffa                 dbf       d6,$0001117A
[00011182] 6050                      bra.s     $000111D4
[00011184] 4dfa 285c                 lea.l     $000139E2(pc),a6
[00011188] 7c0f                      moveq.l   #15,d6
[0001118a] c246                      and.w     d6,d1
[0001118c] 672a                      beq.s     $000111B8
[0001118e] 3a01                      move.w    d1,d5
[00011190] bd45                      eor.w     d6,d5
[00011192] 3c01                      move.w    d1,d6
[00011194] 5346                      subq.w    #1,d6
[00011196] d241                      add.w     d1,d1
[00011198] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001119c] 7200                      moveq.l   #0,d1
[0001119e] 121a                      move.b    (a2)+,d1
[000111a0] e549                      lsl.w     #2,d1
[000111a2] 2a4e                      movea.l   a6,a5
[000111a4] dac1                      adda.w    d1,a5
[000111a6] 20dd                      move.l    (a5)+,(a0)+
[000111a8] 7200                      moveq.l   #0,d1
[000111aa] 121a                      move.b    (a2)+,d1
[000111ac] e549                      lsl.w     #2,d1
[000111ae] 2a4e                      movea.l   a6,a5
[000111b0] dac1                      adda.w    d1,a5
[000111b2] 20dd                      move.l    (a5)+,(a0)+
[000111b4] 51cd ffe6                 dbf       d5,$0001119C
[000111b8] 7200                      moveq.l   #0,d1
[000111ba] 121c                      move.b    (a4)+,d1
[000111bc] e549                      lsl.w     #2,d1
[000111be] 2a4e                      movea.l   a6,a5
[000111c0] dac1                      adda.w    d1,a5
[000111c2] 20dd                      move.l    (a5)+,(a0)+
[000111c4] 7200                      moveq.l   #0,d1
[000111c6] 121c                      move.b    (a4)+,d1
[000111c8] e549                      lsl.w     #2,d1
[000111ca] 2a4e                      movea.l   a6,a5
[000111cc] dac1                      adda.w    d1,a5
[000111ce] 20dd                      move.l    (a5)+,(a0)+
[000111d0] 51ce ffe6                 dbf       d6,$000111B8
[000111d4] 205f                      movea.l   (a7)+,a0
[000111d6] 3c02                      move.w    d2,d6
[000111d8] e84a                      lsr.w     #4,d2
[000111da] 3800                      move.w    d0,d4
[000111dc] e84c                      lsr.w     #4,d4
[000111de] 9444                      sub.w     d4,d2
[000111e0] 7808                      moveq.l   #8,d4
[000111e2] c840                      and.w     d0,d4
[000111e4] 247b 400c                 movea.l   $000111F2(pc,d4.w),a2
[000111e8] 7a08                      moveq.l   #8,d5
[000111ea] ca46                      and.w     d6,d5
[000111ec] 2c7b 5010                 movea.l   $000111FE(pc,d5.w),a6
[000111f0] 6058                      bra.s     $0001124A
[000111f2] 0001 12c0                 ori.b     #$C0,d1
[000111f6] 0000 0000                 ori.b     #$00,d0
[000111fa] 0001 12b4                 ori.b     #$B4,d1
[000111fe] 0001 12f2                 ori.b     #$F2,d1
[00011202] 0000 0000                 ori.b     #$00,d0
[00011206] 0001 12f6                 ori.b     #$F6,d1
[0001120a] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[00011212] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[00011216] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[0001121a] 0000 ffff                 ori.b     #$FF,d0
[0001121e] 0000 0fff                 ori.b     #$FF,d0
[00011222] 0000 00ff                 ori.b     #$FF,d0
[00011226] 0000 000f                 ori.b     #$0F,d0
[0001122a] f000 0000                 pmove.l   d0,???
[0001122e] ff00                      dc.w      $FF00 ; illegal
[00011230] 0000 fff0                 ori.b     #$F0,d0
[00011234] 0000 ffff                 ori.b     #$FF,d0
[00011238] 0000 ffff                 ori.b     #$FF,d0
[0001123c] f000                      dc.w      $F000 ; illegal
[0001123e] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00011246] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[0001124e] cc44                      and.w     d4,d6
[00011250] d040                      add.w     d0,d0
[00011252] d040                      add.w     d0,d0
[00011254] dc46                      add.w     d6,d6
[00011256] dc46                      add.w     d6,d6
[00011258] 283b 00b0                 move.l    $0001120A(pc,d0.w),d4
[0001125c] 2a3b 60cc                 move.l    $0001122A(pc,d6.w),d5
[00011260] 5342                      subq.w    #1,d2
[00011262] 6a24                      bpl.s     $00011288
[00011264] b5fc 0001 12c0            cmpa.l    #$000112C0,a2
[0001126a] 670a                      beq.s     $00011276
[0001126c] ca84                      and.l     d4,d5
[0001126e] 7800                      moveq.l   #0,d4
[00011270] 5989                      subq.l    #4,a1
[00011272] 598b                      subq.l    #4,a3
[00011274] 600e                      bra.s     $00011284
[00011276] bdfc 0001 12f6            cmpa.l    #$000112F6,a6
[0001127c] 6706                      beq.s     $00011284
[0001127e] c885                      and.l     d5,d4
[00011280] 7a00                      moveq.l   #0,d5
[00011282] 598b                      subq.l    #4,a3
[00011284] 45fa 0020                 lea.l     $000112A6(pc),a2
[00011288] 700f                      moveq.l   #15,d0
[0001128a] b640                      cmp.w     d0,d3
[0001128c] 6c02                      bge.s     $00011290
[0001128e] 3003                      move.w    d3,d0
[00011290] 4843                      swap      d3
[00011292] 3600                      move.w    d0,d3
[00011294] 2207                      move.l    d7,d1
[00011296] 4681                      not.l     d1
[00011298] 4843                      swap      d3
[0001129a] 3f03                      move.w    d3,-(a7)
[0001129c] e84b                      lsr.w     #4,d3
[0001129e] 2c18                      move.l    (a0)+,d6
[000112a0] 2e18                      move.l    (a0)+,d7
[000112a2] 2f09                      move.l    a1,-(a7)
[000112a4] 4ed2                      jmp       (a2)
[000112a6] 2004                      move.l    d4,d0
[000112a8] c086                      and.l     d6,d0
[000112aa] 8191                      or.l      d0,(a1)
[000112ac] c081                      and.l     d1,d0
[000112ae] b199                      eor.l     d0,(a1)+
[000112b0] 2007                      move.l    d7,d0
[000112b2] 604c                      bra.s     $00011300
[000112b4] 2004                      move.l    d4,d0
[000112b6] c087                      and.l     d7,d0
[000112b8] 8191                      or.l      d0,(a1)
[000112ba] c081                      and.l     d1,d0
[000112bc] b199                      eor.l     d0,(a1)+
[000112be] 6012                      bra.s     $000112D2
[000112c0] 2004                      move.l    d4,d0
[000112c2] c086                      and.l     d6,d0
[000112c4] 8191                      or.l      d0,(a1)
[000112c6] c081                      and.l     d1,d0
[000112c8] b199                      eor.l     d0,(a1)+
[000112ca] 8f91                      or.l      d7,(a1)
[000112cc] 2007                      move.l    d7,d0
[000112ce] c081                      and.l     d1,d0
[000112d0] b199                      eor.l     d0,(a1)+
[000112d2] 2f01                      move.l    d1,-(a7)
[000112d4] 2001                      move.l    d1,d0
[000112d6] c086                      and.l     d6,d0
[000112d8] c287                      and.l     d7,d1
[000112da] 3f02                      move.w    d2,-(a7)
[000112dc] 5342                      subq.w    #1,d2
[000112de] 6b0c                      bmi.s     $000112EC
[000112e0] 8d91                      or.l      d6,(a1)
[000112e2] b199                      eor.l     d0,(a1)+
[000112e4] 8f91                      or.l      d7,(a1)
[000112e6] b399                      eor.l     d1,(a1)+
[000112e8] 51ca fff6                 dbf       d2,$000112E0
[000112ec] 341f                      move.w    (a7)+,d2
[000112ee] 221f                      move.l    (a7)+,d1
[000112f0] 4ed6                      jmp       (a6)
[000112f2] 2006                      move.l    d6,d0
[000112f4] 600a                      bra.s     $00011300
[000112f6] 8d91                      or.l      d6,(a1)
[000112f8] 2006                      move.l    d6,d0
[000112fa] c081                      and.l     d1,d0
[000112fc] b199                      eor.l     d0,(a1)+
[000112fe] 2007                      move.l    d7,d0
[00011300] c085                      and.l     d5,d0
[00011302] 8191                      or.l      d0,(a1)
[00011304] c081                      and.l     d1,d0
[00011306] b191                      eor.l     d0,(a1)
[00011308] d3cb                      adda.l    a3,a1
[0001130a] 51cb ff98                 dbf       d3,$000112A4
[0001130e] 225f                      movea.l   (a7)+,a1
[00011310] 361f                      move.w    (a7)+,d3
[00011312] d2d7                      adda.w    (a7),a1
[00011314] 5343                      subq.w    #1,d3
[00011316] 4843                      swap      d3
[00011318] 51cb ff7e                 dbf       d3,$00011298
[0001131c] 548f                      addq.l    #2,a7
[0001131e] 4e75                      rts
[00011320] 3c2e 00c0                 move.w    192(a6),d6
[00011324] 6700 0196                 beq       $000114BC
[00011328] 2f08                      move.l    a0,-(a7)
[0001132a] 4a6e 00ca                 tst.w     202(a6)
[0001132e] 6726                      beq.s     $00011356
[00011330] 7c0f                      moveq.l   #15,d6
[00011332] c246                      and.w     d6,d1
[00011334] 6716                      beq.s     $0001134C
[00011336] 3a01                      move.w    d1,d5
[00011338] bd45                      eor.w     d6,d5
[0001133a] 3c01                      move.w    d1,d6
[0001133c] 5346                      subq.w    #1,d6
[0001133e] e749                      lsl.w     #3,d1
[00011340] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011344] 20da                      move.l    (a2)+,(a0)+
[00011346] 20da                      move.l    (a2)+,(a0)+
[00011348] 51cd fffa                 dbf       d5,$00011344
[0001134c] 20dc                      move.l    (a4)+,(a0)+
[0001134e] 20dc                      move.l    (a4)+,(a0)+
[00011350] 51ce fffa                 dbf       d6,$0001134C
[00011354] 6050                      bra.s     $000113A6
[00011356] 4dfa 268a                 lea.l     $000139E2(pc),a6
[0001135a] 7c0f                      moveq.l   #15,d6
[0001135c] c246                      and.w     d6,d1
[0001135e] 672a                      beq.s     $0001138A
[00011360] 3a01                      move.w    d1,d5
[00011362] bd45                      eor.w     d6,d5
[00011364] 3c01                      move.w    d1,d6
[00011366] 5346                      subq.w    #1,d6
[00011368] d241                      add.w     d1,d1
[0001136a] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001136e] 7200                      moveq.l   #0,d1
[00011370] 121a                      move.b    (a2)+,d1
[00011372] e549                      lsl.w     #2,d1
[00011374] 2a4e                      movea.l   a6,a5
[00011376] dac1                      adda.w    d1,a5
[00011378] 20dd                      move.l    (a5)+,(a0)+
[0001137a] 7200                      moveq.l   #0,d1
[0001137c] 121a                      move.b    (a2)+,d1
[0001137e] e549                      lsl.w     #2,d1
[00011380] 2a4e                      movea.l   a6,a5
[00011382] dac1                      adda.w    d1,a5
[00011384] 20dd                      move.l    (a5)+,(a0)+
[00011386] 51cd ffe6                 dbf       d5,$0001136E
[0001138a] 7200                      moveq.l   #0,d1
[0001138c] 121c                      move.b    (a4)+,d1
[0001138e] e549                      lsl.w     #2,d1
[00011390] 2a4e                      movea.l   a6,a5
[00011392] dac1                      adda.w    d1,a5
[00011394] 20dd                      move.l    (a5)+,(a0)+
[00011396] 7200                      moveq.l   #0,d1
[00011398] 121c                      move.b    (a4)+,d1
[0001139a] e549                      lsl.w     #2,d1
[0001139c] 2a4e                      movea.l   a6,a5
[0001139e] dac1                      adda.w    d1,a5
[000113a0] 20dd                      move.l    (a5)+,(a0)+
[000113a2] 51ce ffe6                 dbf       d6,$0001138A
[000113a6] 205f                      movea.l   (a7)+,a0
[000113a8] 3c02                      move.w    d2,d6
[000113aa] e84a                      lsr.w     #4,d2
[000113ac] 3800                      move.w    d0,d4
[000113ae] e84c                      lsr.w     #4,d4
[000113b0] 9444                      sub.w     d4,d2
[000113b2] 7808                      moveq.l   #8,d4
[000113b4] c840                      and.w     d0,d4
[000113b6] 247b 400c                 movea.l   $000113C4(pc,d4.w),a2
[000113ba] 7a08                      moveq.l   #8,d5
[000113bc] ca46                      and.w     d6,d5
[000113be] 2c7b 5010                 movea.l   $000113D0(pc,d5.w),a6
[000113c2] 6058                      bra.s     $0001141C
[000113c4] 0001 1486                 ori.b     #$86,d1
[000113c8] 0000 0000                 ori.b     #$00,d0
[000113cc] 0001 147e                 ori.b     #$7E,d1
[000113d0] 0001 149e                 ori.b     #$9E,d1
[000113d4] 0000 0000                 ori.b     #$00,d0
[000113d8] 0001 14a2                 ori.b     #$A2,d1
[000113dc] ffff ffff 0fff ffff       vperm     #$0FFFFFFF,e23,e23,e23
[000113e4] 00ff ffff                 chk2.b    ???,a7 ; 68020+ only
[000113e8] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[000113ec] 0000 ffff                 ori.b     #$FF,d0
[000113f0] 0000 0fff                 ori.b     #$FF,d0
[000113f4] 0000 00ff                 ori.b     #$FF,d0
[000113f8] 0000 000f                 ori.b     #$0F,d0
[000113fc] f000 0000                 pmove.l   d0,???
[00011400] ff00                      dc.w      $FF00 ; illegal
[00011402] 0000 fff0                 ori.b     #$F0,d0
[00011406] 0000 ffff                 ori.b     #$FF,d0
[0001140a] 0000 ffff                 ori.b     #$FF,d0
[0001140e] f000                      dc.w      $F000 ; illegal
[00011410] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00011418] ffff ffff 7807 c044       vperm     #$7807C044,e23,e23,e23
[00011420] cc44                      and.w     d4,d6
[00011422] d040                      add.w     d0,d0
[00011424] d040                      add.w     d0,d0
[00011426] dc46                      add.w     d6,d6
[00011428] dc46                      add.w     d6,d6
[0001142a] 283b 00b0                 move.l    $000113DC(pc,d0.w),d4
[0001142e] 2a3b 60cc                 move.l    $000113FC(pc,d6.w),d5
[00011432] 5342                      subq.w    #1,d2
[00011434] 6a24                      bpl.s     $0001145A
[00011436] b5fc 0001 1486            cmpa.l    #$00011486,a2
[0001143c] 670a                      beq.s     $00011448
[0001143e] ca84                      and.l     d4,d5
[00011440] 7800                      moveq.l   #0,d4
[00011442] 5989                      subq.l    #4,a1
[00011444] 598b                      subq.l    #4,a3
[00011446] 600e                      bra.s     $00011456
[00011448] bdfc 0001 14a2            cmpa.l    #$000114A2,a6
[0001144e] 6706                      beq.s     $00011456
[00011450] c885                      and.l     d5,d4
[00011452] 7a00                      moveq.l   #0,d5
[00011454] 598b                      subq.l    #4,a3
[00011456] 45fa 001c                 lea.l     $00011474(pc),a2
[0001145a] 700f                      moveq.l   #15,d0
[0001145c] b640                      cmp.w     d0,d3
[0001145e] 6c02                      bge.s     $00011462
[00011460] 3003                      move.w    d3,d0
[00011462] 4843                      swap      d3
[00011464] 3600                      move.w    d0,d3
[00011466] 4843                      swap      d3
[00011468] 3203                      move.w    d3,d1
[0001146a] e849                      lsr.w     #4,d1
[0001146c] 2c18                      move.l    (a0)+,d6
[0001146e] 2e18                      move.l    (a0)+,d7
[00011470] 2f09                      move.l    a1,-(a7)
[00011472] 4ed2                      jmp       (a2)
[00011474] 2006                      move.l    d6,d0
[00011476] c084                      and.l     d4,d0
[00011478] b199                      eor.l     d0,(a1)+
[0001147a] 2007                      move.l    d7,d0
[0001147c] 6028                      bra.s     $000114A6
[0001147e] 2007                      move.l    d7,d0
[00011480] c084                      and.l     d4,d0
[00011482] b199                      eor.l     d0,(a1)+
[00011484] 6008                      bra.s     $0001148E
[00011486] 2006                      move.l    d6,d0
[00011488] c084                      and.l     d4,d0
[0001148a] b199                      eor.l     d0,(a1)+
[0001148c] bf99                      eor.l     d7,(a1)+
[0001148e] 3002                      move.w    d2,d0
[00011490] 5340                      subq.w    #1,d0
[00011492] 6b08                      bmi.s     $0001149C
[00011494] bd99                      eor.l     d6,(a1)+
[00011496] bf99                      eor.l     d7,(a1)+
[00011498] 51c8 fffa                 dbf       d0,$00011494
[0001149c] 4ed6                      jmp       (a6)
[0001149e] 2006                      move.l    d6,d0
[000114a0] 6004                      bra.s     $000114A6
[000114a2] bd99                      eor.l     d6,(a1)+
[000114a4] 2007                      move.l    d7,d0
[000114a6] c085                      and.l     d5,d0
[000114a8] b191                      eor.l     d0,(a1)
[000114aa] d3cb                      adda.l    a3,a1
[000114ac] 51c9 ffc4                 dbf       d1,$00011472
[000114b0] 225f                      movea.l   (a7)+,a1
[000114b2] d2d7                      adda.w    (a7),a1
[000114b4] 5343                      subq.w    #1,d3
[000114b6] 4843                      swap      d3
[000114b8] 51cb ffac                 dbf       d3,$00011466
[000114bc] 548f                      addq.l    #2,a7
[000114be] 4e75                      rts
[000114c0] 4bfa 249a                 lea.l     $0001395C(pc),a5
[000114c4] 3e2e 00be                 move.w    190(a6),d7
[000114c8] de47                      add.w     d7,d7
[000114ca] de47                      add.w     d7,d7
[000114cc] 2e35 7000                 move.l    0(a5,d7.w),d7
[000114d0] 2f08                      move.l    a0,-(a7)
[000114d2] 4a6e 00ca                 tst.w     202(a6)
[000114d6] 6738                      beq.s     $00011510
[000114d8] 7c0f                      moveq.l   #15,d6
[000114da] c246                      and.w     d6,d1
[000114dc] 671e                      beq.s     $000114FC
[000114de] 3a01                      move.w    d1,d5
[000114e0] bd45                      eor.w     d6,d5
[000114e2] 3c01                      move.w    d1,d6
[000114e4] 5346                      subq.w    #1,d6
[000114e6] e749                      lsl.w     #3,d1
[000114e8] 45f4 1000                 lea.l     0(a4,d1.w),a2
[000114ec] 221a                      move.l    (a2)+,d1
[000114ee] 4681                      not.l     d1
[000114f0] 20c1                      move.l    d1,(a0)+
[000114f2] 221a                      move.l    (a2)+,d1
[000114f4] 4681                      not.l     d1
[000114f6] 20c1                      move.l    d1,(a0)+
[000114f8] 51cd fff2                 dbf       d5,$000114EC
[000114fc] 221c                      move.l    (a4)+,d1
[000114fe] 4681                      not.l     d1
[00011500] 20c1                      move.l    d1,(a0)+
[00011502] 221c                      move.l    (a4)+,d1
[00011504] 4681                      not.l     d1
[00011506] 20c1                      move.l    d1,(a0)+
[00011508] 51ce fff2                 dbf       d6,$000114FC
[0001150c] 6000 fcc6                 bra       $000111D4
[00011510] 4dfa 24d0                 lea.l     $000139E2(pc),a6
[00011514] 7c0f                      moveq.l   #15,d6
[00011516] c246                      and.w     d6,d1
[00011518] 6732                      beq.s     $0001154C
[0001151a] 3a01                      move.w    d1,d5
[0001151c] bd45                      eor.w     d6,d5
[0001151e] 3c01                      move.w    d1,d6
[00011520] 5346                      subq.w    #1,d6
[00011522] d241                      add.w     d1,d1
[00011524] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011528] 7200                      moveq.l   #0,d1
[0001152a] 121a                      move.b    (a2)+,d1
[0001152c] e549                      lsl.w     #2,d1
[0001152e] 2a4e                      movea.l   a6,a5
[00011530] dac1                      adda.w    d1,a5
[00011532] 221d                      move.l    (a5)+,d1
[00011534] 4681                      not.l     d1
[00011536] 20c1                      move.l    d1,(a0)+
[00011538] 7200                      moveq.l   #0,d1
[0001153a] 121a                      move.b    (a2)+,d1
[0001153c] e549                      lsl.w     #2,d1
[0001153e] 2a4e                      movea.l   a6,a5
[00011540] dac1                      adda.w    d1,a5
[00011542] 221d                      move.l    (a5)+,d1
[00011544] 4681                      not.l     d1
[00011546] 20c1                      move.l    d1,(a0)+
[00011548] 51cd ffde                 dbf       d5,$00011528
[0001154c] 7200                      moveq.l   #0,d1
[0001154e] 121c                      move.b    (a4)+,d1
[00011550] e549                      lsl.w     #2,d1
[00011552] 2a4e                      movea.l   a6,a5
[00011554] dac1                      adda.w    d1,a5
[00011556] 221d                      move.l    (a5)+,d1
[00011558] 4681                      not.l     d1
[0001155a] 20c1                      move.l    d1,(a0)+
[0001155c] 7200                      moveq.l   #0,d1
[0001155e] 121c                      move.b    (a4)+,d1
[00011560] e549                      lsl.w     #2,d1
[00011562] 2a4e                      movea.l   a6,a5
[00011564] dac1                      adda.w    d1,a5
[00011566] 221d                      move.l    (a5)+,d1
[00011568] 4681                      not.l     d1
[0001156a] 20c1                      move.l    d1,(a0)+
[0001156c] 51ce ffde                 dbf       d6,$0001154C
[00011570] 6000 fc62                 bra       $000111D4
[00011574] 206e 01c2                 movea.l   450(a6),a0
[00011578] 226e 01d6                 movea.l   470(a6),a1
[0001157c] 346e 01c6                 movea.w   454(a6),a2
[00011580] 366e 01da                 movea.w   474(a6),a3
[00011584] 026e 0003 01ee            andi.w    #$0003,494(a6)
[0001158a] 3c0a                      move.w    a2,d6
[0001158c] c3c6                      muls.w    d6,d1
[0001158e] d1c1                      adda.l    d1,a0
[00011590] 3200                      move.w    d0,d1
[00011592] e649                      lsr.w     #3,d1
[00011594] d0c1                      adda.w    d1,a0
[00011596] 7c07                      moveq.l   #7,d6
[00011598] 7e07                      moveq.l   #7,d7
[0001159a] c047                      and.w     d7,d0
[0001159c] cc42                      and.w     d2,d6
[0001159e] 9046                      sub.w     d6,d0
[000115a0] d842                      add.w     d2,d4
[000115a2] ce44                      and.w     d4,d7
[000115a4] 72f8                      moveq.l   #-8,d1
[000115a6] c441                      and.w     d1,d2
[000115a8] e24a                      lsr.w     #1,d2
[000115aa] c841                      and.w     d1,d4
[000115ac] e24c                      lsr.w     #1,d4
[000115ae] 320b                      move.w    a3,d1
[000115b0] c7c1                      muls.w    d1,d3
[000115b2] d3c3                      adda.l    d3,a1
[000115b4] d2c2                      adda.w    d2,a1
[000115b6] 9842                      sub.w     d2,d4
[000115b8] 96c4                      suba.w    d4,a3
[000115ba] 594b                      subq.w    #4,a3
[000115bc] e44c                      lsr.w     #2,d4
[000115be] 94c4                      suba.w    d4,a2
[000115c0] 534a                      subq.w    #1,a2
[000115c2] dc46                      add.w     d6,d6
[000115c4] dc46                      add.w     d6,d6
[000115c6] 243b 604e                 move.l    $00011616(pc,d6.w),d2
[000115ca] de47                      add.w     d7,d7
[000115cc] de47                      add.w     d7,d7
[000115ce] 263b 7066                 move.l    $00011636(pc,d7.w),d3
[000115d2] 5344                      subq.w    #1,d4
[000115d4] 6a04                      bpl.s     $000115DA
[000115d6] c483                      and.l     d3,d2
[000115d8] 7600                      moveq.l   #0,d3
[000115da] 49fa 2406                 lea.l     $000139E2(pc),a4
[000115de] 4bfa 237c                 lea.l     $0001395C(pc),a5
[000115e2] 3c2e 01ea                 move.w    490(a6),d6
[000115e6] dc46                      add.w     d6,d6
[000115e8] dc46                      add.w     d6,d6
[000115ea] 2c35 6000                 move.l    0(a5,d6.w),d6
[000115ee] 3e2e 01ec                 move.w    492(a6),d7
[000115f2] de47                      add.w     d7,d7
[000115f4] de47                      add.w     d7,d7
[000115f6] 2e35 7000                 move.l    0(a5,d7.w),d7
[000115fa] 3200                      move.w    d0,d1
[000115fc] 6b7c                      bmi.s     $0001167A
[000115fe] 6656                      bne.s     $00011656
[00011600] 302e 01ee                 move.w    494(a6),d0
[00011604] d040                      add.w     d0,d0
[00011606] 303b 0006                 move.w    $0001160E(pc,d0.w),d0
[0001160a] 4efb 0002                 jmp       $0001160E(pc,d0.w)
J2:
[0001160e] 00b2                      dc.w $00b2   ; $000116c0-$0001160e
[00011610] 0342                      dc.w $0342   ; $00011950-$0001160e
[00011612] 0458                      dc.w $0458   ; $00011a66-$0001160e
[00011614] 0544                      dc.w $0544   ; $00011b52-$0001160e
[00011616] ffff                      dc.w $ffff   ; $0001160d-$0001160e
[00011618] ffff                      dc.w $ffff   ; $0001160d-$0001160e
[0001161a] 0fff                      dc.w $0fff   ; $0001260d-$0001160e
[0001161c] ffff                      dc.w $ffff   ; $0001160d-$0001160e
[0001161e] 00ff                      dc.w $00ff   ; $0001170d-$0001160e
[00011620] ffff                      dc.w $ffff   ; $0001160d-$0001160e
[00011622] 000f                      dc.w $000f   ; $0001161d-$0001160e
[00011624] ffff 0000 ffff 0000       vperm     #$FFFF0000,e8,e8,e8
[0001162c] 0fff                      bset      d7,???
[0001162e] 0000 00ff                 ori.b     #$FF,d0
[00011632] 0000 000f                 ori.b     #$0F,d0
[00011636] f000 0000                 pmove.l   d0,???
[0001163a] ff00                      dc.w      $FF00 ; illegal
[0001163c] 0000 fff0                 ori.b     #$F0,d0
[00011640] 0000 ffff                 ori.b     #$FF,d0
[00011644] 0000 ffff                 ori.b     #$FF,d0
[00011648] f000                      dc.w      $F000 ; illegal
[0001164a] ffff ff00 ffff fff0       vperm     #$FFFFFFF0,e8,e23,e23
[00011652] ffff ffff 0a41 0007       vperm     #$0A410007,e23,e23,e23
[0001165a] 5241                      addq.w    #1,d1
[0001165c] 302e 01ee                 move.w    494(a6),d0
[00011660] d040                      add.w     d0,d0
[00011662] 4a79 0001 39e0            tst.w     $000139E0
[00011668] 6730                      beq.s     $0001169A
[0001166a] 303b 0006                 move.w    $00011672(pc,d0.w),d0
[0001166e] 4efb 0002                 jmp       $00011672(pc,d0.w)
J3:
[00011672] 00a6                      dc.w $00a6   ; $00011718-$00011672
[00011674] 0330                      dc.w $0330   ; $000119a2-$00011672
[00011676] 0438                      dc.w $0438   ; $00011aaa-$00011672
[00011678] 0538                      dc.w $0538   ; $00011baa-$00011672
[0001167a] 4441                      dc.w $4441   ; $00015ab3-$00011672
[0001167c] 302e                      dc.w $302e   ; $000146a0-$00011672
[0001167e] 01ee                      dc.w $01ee   ; $00011860-$00011672
[00011680] d040                      dc.w $d040   ; $0000e6b2-$00011672
[00011682] 4a79                      dc.w $4a79   ; $000160eb-$00011672
[00011684] 0001                      dc.w $0001   ; $00011673-$00011672
[00011686] 39e0                      move.w    -(a0),# ; illegal
[00011688] 6720                      beq.s     $000116AA
[0001168a] 303b 0006                 move.w    $00011692(pc,d0.w),d0
[0001168e] 4efb 0002                 jmp       $00011692(pc,d0.w)
J4:
[00011692] 00f2                      dc.w $00f2   ; $00011784-$00011692
[00011694] 0374                      dc.w $0374   ; $00011a06-$00011692
[00011696] 046e                      dc.w $046e   ; $00011b00-$00011692
[00011698] 0582                      dc.w $0582   ; $00011c14-$00011692
[0001169a] 303b                      dc.w $303b   ; $000146cd-$00011692
[0001169c] 0006                      dc.w $0006   ; $00011698-$00011692
[0001169e] 4efb 0002                 jmp       $000116A2(pc,d0.w)
[000116a2] 05d8                      bset      d2,(a0)+
[000116a4] 07b8 0886                 bclr      d3,($00000886).w
[000116a8] 0938 4a44                 btst      d4,($00004A44).w
[000116ac] 6a02                      bpl.s     $000116B0
[000116ae] 524a                      addq.w    #1,a2
[000116b0] 303b 0006                 move.w    $000116B8(pc,d0.w),d0
[000116b4] 4efb 0002                 jmp       $000116B8(pc,d0.w)
J5:
[000116b8] 0634                      dc.w $0634   ; $00011cec-$000116b8
[000116ba] 080c                      dc.w $080c   ; $00011ec4-$000116b8
[000116bc] 08cc                      dc.w $08cc   ; $00011f84-$000116b8
[000116be] 0992                      dc.w $0992   ; $0001204a-$000116b8
[000116c0] 4a47                      dc.w $4a47   ; $000160ff-$000116b8
[000116c2] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[000116c4] 0128                      dc.w $0128   ; $000117e0-$000116b8
[000116c6] bc7c                      dc.w $bc7c   ; $0000d334-$000116b8
[000116c8] ffff                      dc.w $ffff   ; $000116b7-$000116b8
[000116ca] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[000116cc] 0120                      dc.w $0120   ; $000117d8-$000116b8
[000116ce] 7000                      dc.w $7000   ; $000186b8-$000116b8
[000116d0] 1018                      dc.w $1018   ; $000126d0-$000116b8
[000116d2] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[000116d4] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[000116d6] 2034                      dc.w $2034   ; $000136ec-$000116b8
[000116d8] 0000                      dc.w $0000   ; $000116b8-$000116b8
[000116da] 8591                      dc.w $8591   ; $00009c49-$000116b8
[000116dc] 4680                      dc.w $4680   ; $00015d38-$000116b8
[000116de] c082                      dc.w $c082   ; $0000d73a-$000116b8
[000116e0] b199                      dc.w $b199   ; $0000c851-$000116b8
[000116e2] 3c04                      dc.w $3c04   ; $000152bc-$000116b8
[000116e4] 6b28                      dc.w $6b28   ; $000181e0-$000116b8
[000116e6] 5346                      dc.w $5346   ; $000169fe-$000116b8
[000116e8] 6b10                      dc.w $6b10   ; $000181c8-$000116b8
[000116ea] 7000                      dc.w $7000   ; $000186b8-$000116b8
[000116ec] 1018                      dc.w $1018   ; $000126d0-$000116b8
[000116ee] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[000116f0] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[000116f2] 22f4                      dc.w $22f4   ; $000139ac-$000116b8
[000116f4] 0000                      dc.w $0000   ; $000116b8-$000116b8
[000116f6] 51ce                      dc.w $51ce   ; $00016886-$000116b8
[000116f8] fff2                      dc.w $fff2   ; $000116aa-$000116b8
[000116fa] 7000                      dc.w $7000   ; $000186b8-$000116b8
[000116fc] 1018                      dc.w $1018   ; $000126d0-$000116b8
[000116fe] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011700] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011702] 2034                      dc.w $2034   ; $000136ec-$000116b8
[00011704] 0000                      dc.w $0000   ; $000116b8-$000116b8
[00011706] 8791                      dc.w $8791   ; $00009e49-$000116b8
[00011708] 4680                      dc.w $4680   ; $00015d38-$000116b8
[0001170a] c083                      dc.w $c083   ; $0000d73b-$000116b8
[0001170c] b199                      dc.w $b199   ; $0000c851-$000116b8
[0001170e] d0ca                      dc.w $d0ca   ; $0000e782-$000116b8
[00011710] d2cb                      dc.w $d2cb   ; $0000e983-$000116b8
[00011712] 51cd                      dc.w $51cd   ; $00016885-$000116b8
[00011714] ffba                      dc.w $ffba   ; $00011672-$000116b8
[00011716] 4e75                      dc.w $4e75   ; $0001652d-$000116b8
[00011718] 2a46                      dc.w $2a46   ; $000140fe-$000116b8
[0001171a] 4a47                      dc.w $4a47   ; $000160ff-$000116b8
[0001171c] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[0001171e] 013a                      dc.w $013a   ; $000117f2-$000116b8
[00011720] bc7c                      dc.w $bc7c   ; $0000d334-$000116b8
[00011722] ffff                      dc.w $ffff   ; $000116b7-$000116b8
[00011724] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[00011726] 0132                      dc.w $0132   ; $000117ea-$000116b8
[00011728] 3010                      dc.w $3010   ; $000146c8-$000116b8
[0001172a] 5288                      dc.w $5288   ; $00016940-$000116b8
[0001172c] e268                      dc.w $e268   ; $0000f920-$000116b8
[0001172e] c07c                      dc.w $c07c   ; $0000d734-$000116b8
[00011730] 00ff                      dc.w $00ff   ; $000117b7-$000116b8
[00011732] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011734] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011736] 2034                      dc.w $2034   ; $000136ec-$000116b8
[00011738] 0000                      dc.w $0000   ; $000116b8-$000116b8
[0001173a] 8591                      dc.w $8591   ; $00009c49-$000116b8
[0001173c] 4680                      dc.w $4680   ; $00015d38-$000116b8
[0001173e] c082                      dc.w $c082   ; $0000d73a-$000116b8
[00011740] b199                      dc.w $b199   ; $0000c851-$000116b8
[00011742] 3c04                      dc.w $3c04   ; $000152bc-$000116b8
[00011744] 6b34                      dc.w $6b34   ; $000181ec-$000116b8
[00011746] 5346                      dc.w $5346   ; $000169fe-$000116b8
[00011748] 6b16                      dc.w $6b16   ; $000181ce-$000116b8
[0001174a] 3010                      dc.w $3010   ; $000146c8-$000116b8
[0001174c] 5288                      dc.w $5288   ; $00016940-$000116b8
[0001174e] e268                      dc.w $e268   ; $0000f920-$000116b8
[00011750] c07c                      dc.w $c07c   ; $0000d734-$000116b8
[00011752] 00ff                      dc.w $00ff   ; $000117b7-$000116b8
[00011754] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011756] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[00011758] 22f4                      dc.w $22f4   ; $000139ac-$000116b8
[0001175a] 0000                      dc.w $0000   ; $000116b8-$000116b8
[0001175c] 51ce                      dc.w $51ce   ; $00016886-$000116b8
[0001175e] ffec                      dc.w $ffec   ; $000116a4-$000116b8
[00011760] 3010                      dc.w $3010   ; $000146c8-$000116b8
[00011762] 5288                      dc.w $5288   ; $00016940-$000116b8
[00011764] e268                      dc.w $e268   ; $0000f920-$000116b8
[00011766] c07c                      dc.w $c07c   ; $0000d734-$000116b8
[00011768] 00ff                      dc.w $00ff   ; $000117b7-$000116b8
[0001176a] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[0001176c] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[0001176e] 2034                      dc.w $2034   ; $000136ec-$000116b8
[00011770] 0000                      dc.w $0000   ; $000116b8-$000116b8
[00011772] 8791                      dc.w $8791   ; $00009e49-$000116b8
[00011774] 4680                      dc.w $4680   ; $00015d38-$000116b8
[00011776] c083                      dc.w $c083   ; $0000d73b-$000116b8
[00011778] b199                      dc.w $b199   ; $0000c851-$000116b8
[0001177a] d0ca                      dc.w $d0ca   ; $0000e782-$000116b8
[0001177c] d2cb                      dc.w $d2cb   ; $0000e983-$000116b8
[0001177e] 51cd                      dc.w $51cd   ; $00016885-$000116b8
[00011780] ffa8                      dc.w $ffa8   ; $00011660-$000116b8
[00011782] 4e75                      dc.w $4e75   ; $0001652d-$000116b8
[00011784] 2a46                      dc.w $2a46   ; $000140fe-$000116b8
[00011786] 4a47                      dc.w $4a47   ; $000160ff-$000116b8
[00011788] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[0001178a] 014c                      dc.w $014c   ; $00011804-$000116b8
[0001178c] bc7c                      dc.w $bc7c   ; $0000d334-$000116b8
[0001178e] ffff                      dc.w $ffff   ; $000116b7-$000116b8
[00011790] 6600                      dc.w $6600   ; $00017cb8-$000116b8
[00011792] 0144                      dc.w $0144   ; $000117fc-$000116b8
[00011794] 7000                      dc.w $7000   ; $000186b8-$000116b8
[00011796] 1018                      dc.w $1018   ; $000126d0-$000116b8
[00011798] e268                      dc.w $e268   ; $0000f920-$000116b8
[0001179a] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[0001179c] d040                      dc.w $d040   ; $0000e6f8-$000116b8
[0001179e] 2034                      dc.w $2034   ; $000136ec-$000116b8
[000117a0] 0000                      dc.w $0000   ; $000116b8-$000116b8
[000117a2] 8591                      dc.w $8591   ; $00009c49-$000116b8
[000117a4] 4680                      dc.w $4680   ; $00015d38-$000116b8
[000117a6] c082                      dc.w $c082   ; $0000d73a-$000116b8
[000117a8] b199                      dc.w $b199   ; $0000c851-$000116b8
[000117aa] 3c04                      dc.w $3c04   ; $000152bc-$000116b8
[000117ac] 6b34                      dc.w $6b34   ; $000181ec-$000116b8
[000117ae] 5346                      dc.w $5346   ; $000169fe-$000116b8
[000117b0] 6b16                      dc.w $6b16   ; $000181ce-$000116b8
[000117b2] 5388                      dc.w $5388   ; $00016a40-$000116b8
[000117b4] 3018                      dc.w $3018   ; $000146d0-$000116b8
[000117b6] e268                      dc.w $e268   ; $0000f920-$000116b8
[000117b8] c07c 00ff                 and.w     #$00FF,d0
[000117bc] d040                      add.w     d0,d0
[000117be] d040                      add.w     d0,d0
[000117c0] 22f4 0000                 move.l    0(a4,d0.w),(a1)+
[000117c4] 51ce ffec                 dbf       d6,$000117B2
[000117c8] 5388                      subq.l    #1,a0
[000117ca] 3018                      move.w    (a0)+,d0
[000117cc] e268                      lsr.w     d1,d0
[000117ce] c07c 00ff                 and.w     #$00FF,d0
[000117d2] d040                      add.w     d0,d0
[000117d4] d040                      add.w     d0,d0
[000117d6] 2034 0000                 move.l    0(a4,d0.w),d0
[000117da] 8791                      or.l      d3,(a1)
[000117dc] 4680                      not.l     d0
[000117de] c083                      and.l     d3,d0
[000117e0] b199                      eor.l     d0,(a1)+
[000117e2] d0ca                      adda.w    a2,a0
[000117e4] d2cb                      adda.w    a3,a1
[000117e6] 51cd ffac                 dbf       d5,$00011794
[000117ea] 4e75                      rts
[000117ec] 7000                      moveq.l   #0,d0
[000117ee] 1018                      move.b    (a0)+,d0
[000117f0] d040                      add.w     d0,d0
[000117f2] d040                      add.w     d0,d0
[000117f4] 2034 0000                 move.l    0(a4,d0.w),d0
[000117f8] 2200                      move.l    d0,d1
[000117fa] 4681                      not.l     d1
[000117fc] c086                      and.l     d6,d0
[000117fe] c287                      and.l     d7,d1
[00011800] 8081                      or.l      d1,d0
[00011802] 8591                      or.l      d2,(a1)
[00011804] 4680                      not.l     d0
[00011806] c082                      and.l     d2,d0
[00011808] b199                      eor.l     d0,(a1)+
[0001180a] 3f04                      move.w    d4,-(a7)
[0001180c] 6b3e                      bmi.s     $0001184C
[0001180e] 5344                      subq.w    #1,d4
[00011810] 6b1c                      bmi.s     $0001182E
[00011812] 7000                      moveq.l   #0,d0
[00011814] 1018                      move.b    (a0)+,d0
[00011816] d040                      add.w     d0,d0
[00011818] d040                      add.w     d0,d0
[0001181a] 2034 0000                 move.l    0(a4,d0.w),d0
[0001181e] 2200                      move.l    d0,d1
[00011820] 4681                      not.l     d1
[00011822] c086                      and.l     d6,d0
[00011824] c287                      and.l     d7,d1
[00011826] 8081                      or.l      d1,d0
[00011828] 22c0                      move.l    d0,(a1)+
[0001182a] 51cc ffe6                 dbf       d4,$00011812
[0001182e] 7000                      moveq.l   #0,d0
[00011830] 1018                      move.b    (a0)+,d0
[00011832] d040                      add.w     d0,d0
[00011834] d040                      add.w     d0,d0
[00011836] 2034 0000                 move.l    0(a4,d0.w),d0
[0001183a] 2200                      move.l    d0,d1
[0001183c] 4681                      not.l     d1
[0001183e] c086                      and.l     d6,d0
[00011840] c287                      and.l     d7,d1
[00011842] 8081                      or.l      d1,d0
[00011844] 8791                      or.l      d3,(a1)
[00011846] 4680                      not.l     d0
[00011848] c083                      and.l     d3,d0
[0001184a] b199                      eor.l     d0,(a1)+
[0001184c] d0ca                      adda.w    a2,a0
[0001184e] d2cb                      adda.w    a3,a1
[00011850] 381f                      move.w    (a7)+,d4
[00011852] 51cd ff98                 dbf       d5,$000117EC
[00011856] 4e75                      rts
[00011858] 3010                      move.w    (a0),d0
[0001185a] 5288                      addq.l    #1,a0
[0001185c] e268                      lsr.w     d1,d0
[0001185e] c07c 00ff                 and.w     #$00FF,d0
[00011862] d040                      add.w     d0,d0
[00011864] d040                      add.w     d0,d0
[00011866] 2034 0000                 move.l    0(a4,d0.w),d0
[0001186a] 2c0d                      move.l    a5,d6
[0001186c] cc80                      and.l     d0,d6
[0001186e] 4680                      not.l     d0
[00011870] c087                      and.l     d7,d0
[00011872] 8086                      or.l      d6,d0
[00011874] 8591                      or.l      d2,(a1)
[00011876] 4680                      not.l     d0
[00011878] c082                      and.l     d2,d0
[0001187a] b199                      eor.l     d0,(a1)+
[0001187c] 3f04                      move.w    d4,-(a7)
[0001187e] 6b4a                      bmi.s     $000118CA
[00011880] 5344                      subq.w    #1,d4
[00011882] 6b22                      bmi.s     $000118A6
[00011884] 3010                      move.w    (a0),d0
[00011886] 5288                      addq.l    #1,a0
[00011888] e268                      lsr.w     d1,d0
[0001188a] c07c 00ff                 and.w     #$00FF,d0
[0001188e] d040                      add.w     d0,d0
[00011890] d040                      add.w     d0,d0
[00011892] 2034 0000                 move.l    0(a4,d0.w),d0
[00011896] 2c0d                      move.l    a5,d6
[00011898] cc80                      and.l     d0,d6
[0001189a] 4680                      not.l     d0
[0001189c] c087                      and.l     d7,d0
[0001189e] 8086                      or.l      d6,d0
[000118a0] 22c0                      move.l    d0,(a1)+
[000118a2] 51cc ffe0                 dbf       d4,$00011884
[000118a6] 3010                      move.w    (a0),d0
[000118a8] 5288                      addq.l    #1,a0
[000118aa] e268                      lsr.w     d1,d0
[000118ac] c07c 00ff                 and.w     #$00FF,d0
[000118b0] d040                      add.w     d0,d0
[000118b2] d040                      add.w     d0,d0
[000118b4] 2034 0000                 move.l    0(a4,d0.w),d0
[000118b8] 2c0d                      move.l    a5,d6
[000118ba] cc80                      and.l     d0,d6
[000118bc] 4680                      not.l     d0
[000118be] c087                      and.l     d7,d0
[000118c0] 8086                      or.l      d6,d0
[000118c2] 8791                      or.l      d3,(a1)
[000118c4] 4680                      not.l     d0
[000118c6] c083                      and.l     d3,d0
[000118c8] b199                      eor.l     d0,(a1)+
[000118ca] d0ca                      adda.w    a2,a0
[000118cc] d2cb                      adda.w    a3,a1
[000118ce] 381f                      move.w    (a7)+,d4
[000118d0] 51cd ff86                 dbf       d5,$00011858
[000118d4] 4e75                      rts
[000118d6] 7000                      moveq.l   #0,d0
[000118d8] 1018                      move.b    (a0)+,d0
[000118da] e268                      lsr.w     d1,d0
[000118dc] d040                      add.w     d0,d0
[000118de] d040                      add.w     d0,d0
[000118e0] 2034 0000                 move.l    0(a4,d0.w),d0
[000118e4] 2c0d                      move.l    a5,d6
[000118e6] cc80                      and.l     d0,d6
[000118e8] 4680                      not.l     d0
[000118ea] c087                      and.l     d7,d0
[000118ec] 8086                      or.l      d6,d0
[000118ee] 8591                      or.l      d2,(a1)
[000118f0] 4680                      not.l     d0
[000118f2] c082                      and.l     d2,d0
[000118f4] b199                      eor.l     d0,(a1)+
[000118f6] 3f04                      move.w    d4,-(a7)
[000118f8] 6b4a                      bmi.s     $00011944
[000118fa] 5344                      subq.w    #1,d4
[000118fc] 6b22                      bmi.s     $00011920
[000118fe] 5388                      subq.l    #1,a0
[00011900] 3018                      move.w    (a0)+,d0
[00011902] e268                      lsr.w     d1,d0
[00011904] c07c 00ff                 and.w     #$00FF,d0
[00011908] d040                      add.w     d0,d0
[0001190a] d040                      add.w     d0,d0
[0001190c] 2034 0000                 move.l    0(a4,d0.w),d0
[00011910] 2c0d                      move.l    a5,d6
[00011912] cc80                      and.l     d0,d6
[00011914] 4680                      not.l     d0
[00011916] c087                      and.l     d7,d0
[00011918] 8086                      or.l      d6,d0
[0001191a] 22c0                      move.l    d0,(a1)+
[0001191c] 51cc ffe0                 dbf       d4,$000118FE
[00011920] 5388                      subq.l    #1,a0
[00011922] 3018                      move.w    (a0)+,d0
[00011924] e268                      lsr.w     d1,d0
[00011926] c07c 00ff                 and.w     #$00FF,d0
[0001192a] d040                      add.w     d0,d0
[0001192c] d040                      add.w     d0,d0
[0001192e] 2034 0000                 move.l    0(a4,d0.w),d0
[00011932] 2c0d                      move.l    a5,d6
[00011934] cc80                      and.l     d0,d6
[00011936] 4680                      not.l     d0
[00011938] c087                      and.l     d7,d0
[0001193a] 8086                      or.l      d6,d0
[0001193c] 8791                      or.l      d3,(a1)
[0001193e] 4680                      not.l     d0
[00011940] c083                      and.l     d3,d0
[00011942] b199                      eor.l     d0,(a1)+
[00011944] d0ca                      adda.w    a2,a0
[00011946] d2cb                      adda.w    a3,a1
[00011948] 381f                      move.w    (a7)+,d4
[0001194a] 51cd ff8a                 dbf       d5,$000118D6
[0001194e] 4e75                      rts
[00011950] 4686                      not.l     d6
[00011952] 7000                      moveq.l   #0,d0
[00011954] 1018                      move.b    (a0)+,d0
[00011956] d040                      add.w     d0,d0
[00011958] d040                      add.w     d0,d0
[0001195a] 2034 0000                 move.l    0(a4,d0.w),d0
[0001195e] c082                      and.l     d2,d0
[00011960] 8191                      or.l      d0,(a1)
[00011962] c086                      and.l     d6,d0
[00011964] b199                      eor.l     d0,(a1)+
[00011966] 3e04                      move.w    d4,d7
[00011968] 6b2e                      bmi.s     $00011998
[0001196a] 5347                      subq.w    #1,d7
[0001196c] 6b16                      bmi.s     $00011984
[0001196e] 7000                      moveq.l   #0,d0
[00011970] 1018                      move.b    (a0)+,d0
[00011972] d040                      add.w     d0,d0
[00011974] d040                      add.w     d0,d0
[00011976] 2034 0000                 move.l    0(a4,d0.w),d0
[0001197a] 8191                      or.l      d0,(a1)
[0001197c] c086                      and.l     d6,d0
[0001197e] b199                      eor.l     d0,(a1)+
[00011980] 51cf ffec                 dbf       d7,$0001196E
[00011984] 7000                      moveq.l   #0,d0
[00011986] 1018                      move.b    (a0)+,d0
[00011988] d040                      add.w     d0,d0
[0001198a] d040                      add.w     d0,d0
[0001198c] 2034 0000                 move.l    0(a4,d0.w),d0
[00011990] c083                      and.l     d3,d0
[00011992] 8191                      or.l      d0,(a1)
[00011994] c086                      and.l     d6,d0
[00011996] b199                      eor.l     d0,(a1)+
[00011998] d0ca                      adda.w    a2,a0
[0001199a] d2cb                      adda.w    a3,a1
[0001199c] 51cd ffb4                 dbf       d5,$00011952
[000119a0] 4e75                      rts
[000119a2] 4686                      not.l     d6
[000119a4] 3010                      move.w    (a0),d0
[000119a6] 5288                      addq.l    #1,a0
[000119a8] e268                      lsr.w     d1,d0
[000119aa] c07c 00ff                 and.w     #$00FF,d0
[000119ae] d040                      add.w     d0,d0
[000119b0] d040                      add.w     d0,d0
[000119b2] 2034 0000                 move.l    0(a4,d0.w),d0
[000119b6] c082                      and.l     d2,d0
[000119b8] 8191                      or.l      d0,(a1)
[000119ba] c086                      and.l     d6,d0
[000119bc] b199                      eor.l     d0,(a1)+
[000119be] 3e04                      move.w    d4,d7
[000119c0] 6b3a                      bmi.s     $000119FC
[000119c2] 5347                      subq.w    #1,d7
[000119c4] 6b1c                      bmi.s     $000119E2
[000119c6] 3010                      move.w    (a0),d0
[000119c8] 5288                      addq.l    #1,a0
[000119ca] e268                      lsr.w     d1,d0
[000119cc] c07c 00ff                 and.w     #$00FF,d0
[000119d0] d040                      add.w     d0,d0
[000119d2] d040                      add.w     d0,d0
[000119d4] 2034 0000                 move.l    0(a4,d0.w),d0
[000119d8] 8191                      or.l      d0,(a1)
[000119da] c086                      and.l     d6,d0
[000119dc] b199                      eor.l     d0,(a1)+
[000119de] 51cf ffe6                 dbf       d7,$000119C6
[000119e2] 3010                      move.w    (a0),d0
[000119e4] 5288                      addq.l    #1,a0
[000119e6] e268                      lsr.w     d1,d0
[000119e8] c07c 00ff                 and.w     #$00FF,d0
[000119ec] d040                      add.w     d0,d0
[000119ee] d040                      add.w     d0,d0
[000119f0] 2034 0000                 move.l    0(a4,d0.w),d0
[000119f4] c083                      and.l     d3,d0
[000119f6] 8191                      or.l      d0,(a1)
[000119f8] c086                      and.l     d6,d0
[000119fa] b199                      eor.l     d0,(a1)+
[000119fc] d0ca                      adda.w    a2,a0
[000119fe] d2cb                      adda.w    a3,a1
[00011a00] 51cd ffa2                 dbf       d5,$000119A4
[00011a04] 4e75                      rts
[00011a06] 4686                      not.l     d6
[00011a08] 7000                      moveq.l   #0,d0
[00011a0a] 1018                      move.b    (a0)+,d0
[00011a0c] e268                      lsr.w     d1,d0
[00011a0e] d040                      add.w     d0,d0
[00011a10] d040                      add.w     d0,d0
[00011a12] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a16] c082                      and.l     d2,d0
[00011a18] 8191                      or.l      d0,(a1)
[00011a1a] c086                      and.l     d6,d0
[00011a1c] b199                      eor.l     d0,(a1)+
[00011a1e] 3e04                      move.w    d4,d7
[00011a20] 6b3a                      bmi.s     $00011A5C
[00011a22] 5347                      subq.w    #1,d7
[00011a24] 6b1c                      bmi.s     $00011A42
[00011a26] 5388                      subq.l    #1,a0
[00011a28] 3018                      move.w    (a0)+,d0
[00011a2a] e268                      lsr.w     d1,d0
[00011a2c] c07c 00ff                 and.w     #$00FF,d0
[00011a30] d040                      add.w     d0,d0
[00011a32] d040                      add.w     d0,d0
[00011a34] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a38] 8191                      or.l      d0,(a1)
[00011a3a] c086                      and.l     d6,d0
[00011a3c] b199                      eor.l     d0,(a1)+
[00011a3e] 51cf ffe6                 dbf       d7,$00011A26
[00011a42] 5388                      subq.l    #1,a0
[00011a44] 3018                      move.w    (a0)+,d0
[00011a46] e268                      lsr.w     d1,d0
[00011a48] c07c 00ff                 and.w     #$00FF,d0
[00011a4c] d040                      add.w     d0,d0
[00011a4e] d040                      add.w     d0,d0
[00011a50] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a54] c083                      and.l     d3,d0
[00011a56] 8191                      or.l      d0,(a1)
[00011a58] c086                      and.l     d6,d0
[00011a5a] b199                      eor.l     d0,(a1)+
[00011a5c] d0ca                      adda.w    a2,a0
[00011a5e] d2cb                      adda.w    a3,a1
[00011a60] 51cd ffa6                 dbf       d5,$00011A08
[00011a64] 4e75                      rts
[00011a66] 7000                      moveq.l   #0,d0
[00011a68] 1018                      move.b    (a0)+,d0
[00011a6a] d040                      add.w     d0,d0
[00011a6c] d040                      add.w     d0,d0
[00011a6e] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a72] c082                      and.l     d2,d0
[00011a74] b199                      eor.l     d0,(a1)+
[00011a76] 3c04                      move.w    d4,d6
[00011a78] 6b26                      bmi.s     $00011AA0
[00011a7a] 5346                      subq.w    #1,d6
[00011a7c] 6b12                      bmi.s     $00011A90
[00011a7e] 7000                      moveq.l   #0,d0
[00011a80] 1018                      move.b    (a0)+,d0
[00011a82] d040                      add.w     d0,d0
[00011a84] d040                      add.w     d0,d0
[00011a86] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a8a] b199                      eor.l     d0,(a1)+
[00011a8c] 51ce fff0                 dbf       d6,$00011A7E
[00011a90] 7000                      moveq.l   #0,d0
[00011a92] 1018                      move.b    (a0)+,d0
[00011a94] d040                      add.w     d0,d0
[00011a96] d040                      add.w     d0,d0
[00011a98] 2034 0000                 move.l    0(a4,d0.w),d0
[00011a9c] c083                      and.l     d3,d0
[00011a9e] b199                      eor.l     d0,(a1)+
[00011aa0] d0ca                      adda.w    a2,a0
[00011aa2] d2cb                      adda.w    a3,a1
[00011aa4] 51cd ffc0                 dbf       d5,$00011A66
[00011aa8] 4e75                      rts
[00011aaa] 3010                      move.w    (a0),d0
[00011aac] 5288                      addq.l    #1,a0
[00011aae] e268                      lsr.w     d1,d0
[00011ab0] c07c 00ff                 and.w     #$00FF,d0
[00011ab4] d040                      add.w     d0,d0
[00011ab6] d040                      add.w     d0,d0
[00011ab8] 2034 0000                 move.l    0(a4,d0.w),d0
[00011abc] c082                      and.l     d2,d0
[00011abe] b199                      eor.l     d0,(a1)+
[00011ac0] 3c04                      move.w    d4,d6
[00011ac2] 6b32                      bmi.s     $00011AF6
[00011ac4] 5346                      subq.w    #1,d6
[00011ac6] 6b18                      bmi.s     $00011AE0
[00011ac8] 3010                      move.w    (a0),d0
[00011aca] 5288                      addq.l    #1,a0
[00011acc] e268                      lsr.w     d1,d0
[00011ace] c07c 00ff                 and.w     #$00FF,d0
[00011ad2] d040                      add.w     d0,d0
[00011ad4] d040                      add.w     d0,d0
[00011ad6] 2034 0000                 move.l    0(a4,d0.w),d0
[00011ada] b199                      eor.l     d0,(a1)+
[00011adc] 51ce ffea                 dbf       d6,$00011AC8
[00011ae0] 3010                      move.w    (a0),d0
[00011ae2] 5288                      addq.l    #1,a0
[00011ae4] e268                      lsr.w     d1,d0
[00011ae6] c07c 00ff                 and.w     #$00FF,d0
[00011aea] d040                      add.w     d0,d0
[00011aec] d040                      add.w     d0,d0
[00011aee] 2034 0000                 move.l    0(a4,d0.w),d0
[00011af2] c083                      and.l     d3,d0
[00011af4] b199                      eor.l     d0,(a1)+
[00011af6] d0ca                      adda.w    a2,a0
[00011af8] d2cb                      adda.w    a3,a1
[00011afa] 51cd ffae                 dbf       d5,$00011AAA
[00011afe] 4e75                      rts
[00011b00] 7000                      moveq.l   #0,d0
[00011b02] 1018                      move.b    (a0)+,d0
[00011b04] e268                      lsr.w     d1,d0
[00011b06] d040                      add.w     d0,d0
[00011b08] d040                      add.w     d0,d0
[00011b0a] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b0e] c082                      and.l     d2,d0
[00011b10] b199                      eor.l     d0,(a1)+
[00011b12] 3c04                      move.w    d4,d6
[00011b14] 6b32                      bmi.s     $00011B48
[00011b16] 5346                      subq.w    #1,d6
[00011b18] 6b18                      bmi.s     $00011B32
[00011b1a] 5388                      subq.l    #1,a0
[00011b1c] 3018                      move.w    (a0)+,d0
[00011b1e] e268                      lsr.w     d1,d0
[00011b20] c07c 00ff                 and.w     #$00FF,d0
[00011b24] d040                      add.w     d0,d0
[00011b26] d040                      add.w     d0,d0
[00011b28] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b2c] b199                      eor.l     d0,(a1)+
[00011b2e] 51ce ffea                 dbf       d6,$00011B1A
[00011b32] 5388                      subq.l    #1,a0
[00011b34] 3018                      move.w    (a0)+,d0
[00011b36] e268                      lsr.w     d1,d0
[00011b38] c07c 00ff                 and.w     #$00FF,d0
[00011b3c] d040                      add.w     d0,d0
[00011b3e] d040                      add.w     d0,d0
[00011b40] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b44] c083                      and.l     d3,d0
[00011b46] b199                      eor.l     d0,(a1)+
[00011b48] d0ca                      adda.w    a2,a0
[00011b4a] d2cb                      adda.w    a3,a1
[00011b4c] 51cd ffb2                 dbf       d5,$00011B00
[00011b50] 4e75                      rts
[00011b52] 4687                      not.l     d7
[00011b54] 7000                      moveq.l   #0,d0
[00011b56] 1018                      move.b    (a0)+,d0
[00011b58] d040                      add.w     d0,d0
[00011b5a] d040                      add.w     d0,d0
[00011b5c] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b60] 4680                      not.l     d0
[00011b62] c082                      and.l     d2,d0
[00011b64] 8191                      or.l      d0,(a1)
[00011b66] c087                      and.l     d7,d0
[00011b68] b199                      eor.l     d0,(a1)+
[00011b6a] 3c04                      move.w    d4,d6
[00011b6c] 6b32                      bmi.s     $00011BA0
[00011b6e] 5346                      subq.w    #1,d6
[00011b70] 6b18                      bmi.s     $00011B8A
[00011b72] 7000                      moveq.l   #0,d0
[00011b74] 1018                      move.b    (a0)+,d0
[00011b76] d040                      add.w     d0,d0
[00011b78] d040                      add.w     d0,d0
[00011b7a] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b7e] 4680                      not.l     d0
[00011b80] 8191                      or.l      d0,(a1)
[00011b82] c087                      and.l     d7,d0
[00011b84] b199                      eor.l     d0,(a1)+
[00011b86] 51ce ffea                 dbf       d6,$00011B72
[00011b8a] 7000                      moveq.l   #0,d0
[00011b8c] 1018                      move.b    (a0)+,d0
[00011b8e] d040                      add.w     d0,d0
[00011b90] d040                      add.w     d0,d0
[00011b92] 2034 0000                 move.l    0(a4,d0.w),d0
[00011b96] 4680                      not.l     d0
[00011b98] c083                      and.l     d3,d0
[00011b9a] 8191                      or.l      d0,(a1)
[00011b9c] c087                      and.l     d7,d0
[00011b9e] b199                      eor.l     d0,(a1)+
[00011ba0] d0ca                      adda.w    a2,a0
[00011ba2] d2cb                      adda.w    a3,a1
[00011ba4] 51cd ffae                 dbf       d5,$00011B54
[00011ba8] 4e75                      rts
[00011baa] 4687                      not.l     d7
[00011bac] 3010                      move.w    (a0),d0
[00011bae] 5288                      addq.l    #1,a0
[00011bb0] e268                      lsr.w     d1,d0
[00011bb2] c07c 00ff                 and.w     #$00FF,d0
[00011bb6] d040                      add.w     d0,d0
[00011bb8] d040                      add.w     d0,d0
[00011bba] 2034 0000                 move.l    0(a4,d0.w),d0
[00011bbe] 4680                      not.l     d0
[00011bc0] c082                      and.l     d2,d0
[00011bc2] 8191                      or.l      d0,(a1)
[00011bc4] c087                      and.l     d7,d0
[00011bc6] b199                      eor.l     d0,(a1)+
[00011bc8] 3c04                      move.w    d4,d6
[00011bca] 6b3e                      bmi.s     $00011C0A
[00011bcc] 5346                      subq.w    #1,d6
[00011bce] 6b1e                      bmi.s     $00011BEE
[00011bd0] 3010                      move.w    (a0),d0
[00011bd2] 5288                      addq.l    #1,a0
[00011bd4] e268                      lsr.w     d1,d0
[00011bd6] c07c 00ff                 and.w     #$00FF,d0
[00011bda] d040                      add.w     d0,d0
[00011bdc] d040                      add.w     d0,d0
[00011bde] 2034 0000                 move.l    0(a4,d0.w),d0
[00011be2] 4680                      not.l     d0
[00011be4] 8191                      or.l      d0,(a1)
[00011be6] c087                      and.l     d7,d0
[00011be8] b199                      eor.l     d0,(a1)+
[00011bea] 51ce ffe4                 dbf       d6,$00011BD0
[00011bee] 3010                      move.w    (a0),d0
[00011bf0] 5288                      addq.l    #1,a0
[00011bf2] e268                      lsr.w     d1,d0
[00011bf4] c07c 00ff                 and.w     #$00FF,d0
[00011bf8] d040                      add.w     d0,d0
[00011bfa] d040                      add.w     d0,d0
[00011bfc] 2034 0000                 move.l    0(a4,d0.w),d0
[00011c00] 4680                      not.l     d0
[00011c02] c083                      and.l     d3,d0
[00011c04] 8191                      or.l      d0,(a1)
[00011c06] c087                      and.l     d7,d0
[00011c08] b199                      eor.l     d0,(a1)+
[00011c0a] d0ca                      adda.w    a2,a0
[00011c0c] d2cb                      adda.w    a3,a1
[00011c0e] 51cd ff9c                 dbf       d5,$00011BAC
[00011c12] 4e75                      rts
[00011c14] 4687                      not.l     d7
[00011c16] 7000                      moveq.l   #0,d0
[00011c18] 1018                      move.b    (a0)+,d0
[00011c1a] e268                      lsr.w     d1,d0
[00011c1c] d040                      add.w     d0,d0
[00011c1e] d040                      add.w     d0,d0
[00011c20] 2034 0000                 move.l    0(a4,d0.w),d0
[00011c24] 4680                      not.l     d0
[00011c26] c082                      and.l     d2,d0
[00011c28] 8191                      or.l      d0,(a1)
[00011c2a] c087                      and.l     d7,d0
[00011c2c] b199                      eor.l     d0,(a1)+
[00011c2e] 3c04                      move.w    d4,d6
[00011c30] 6b3e                      bmi.s     $00011C70
[00011c32] 5346                      subq.w    #1,d6
[00011c34] 6b1e                      bmi.s     $00011C54
[00011c36] 5388                      subq.l    #1,a0
[00011c38] 3018                      move.w    (a0)+,d0
[00011c3a] e268                      lsr.w     d1,d0
[00011c3c] c07c 00ff                 and.w     #$00FF,d0
[00011c40] d040                      add.w     d0,d0
[00011c42] d040                      add.w     d0,d0
[00011c44] 2034 0000                 move.l    0(a4,d0.w),d0
[00011c48] 4680                      not.l     d0
[00011c4a] 8191                      or.l      d0,(a1)
[00011c4c] c087                      and.l     d7,d0
[00011c4e] b199                      eor.l     d0,(a1)+
[00011c50] 51ce ffe4                 dbf       d6,$00011C36
[00011c54] 5388                      subq.l    #1,a0
[00011c56] 3018                      move.w    (a0)+,d0
[00011c58] e268                      lsr.w     d1,d0
[00011c5a] c07c 00ff                 and.w     #$00FF,d0
[00011c5e] d040                      add.w     d0,d0
[00011c60] d040                      add.w     d0,d0
[00011c62] 2034 0000                 move.l    0(a4,d0.w),d0
[00011c66] 4680                      not.l     d0
[00011c68] c083                      and.l     d3,d0
[00011c6a] 8191                      or.l      d0,(a1)
[00011c6c] c087                      and.l     d7,d0
[00011c6e] b199                      eor.l     d0,(a1)+
[00011c70] d0ca                      adda.w    a2,a0
[00011c72] d2cb                      adda.w    a3,a1
[00011c74] 51cd ffa0                 dbf       d5,$00011C16
[00011c78] 4e75                      rts
[00011c7a] 2a46                      movea.l   d6,a5
[00011c7c] 4a47                      tst.w     d7
[00011c7e] 6600 00d8                 bne       $00011D58
[00011c82] bc7c ffff                 cmp.w     #$FFFF,d6
[00011c86] 6600 00d0                 bne       $00011D58
[00011c8a] 1018                      move.b    (a0)+,d0
[00011c8c] e148                      lsl.w     #8,d0
[00011c8e] 1010                      move.b    (a0),d0
[00011c90] e268                      lsr.w     d1,d0
[00011c92] c07c 00ff                 and.w     #$00FF,d0
[00011c96] d040                      add.w     d0,d0
[00011c98] d040                      add.w     d0,d0
[00011c9a] 2034 0000                 move.l    0(a4,d0.w),d0
[00011c9e] 8591                      or.l      d2,(a1)
[00011ca0] 4680                      not.l     d0
[00011ca2] c082                      and.l     d2,d0
[00011ca4] b199                      eor.l     d0,(a1)+
[00011ca6] 3c04                      move.w    d4,d6
[00011ca8] 6b38                      bmi.s     $00011CE2
[00011caa] 5346                      subq.w    #1,d6
[00011cac] 6b18                      bmi.s     $00011CC6
[00011cae] 1018                      move.b    (a0)+,d0
[00011cb0] e148                      lsl.w     #8,d0
[00011cb2] 1010                      move.b    (a0),d0
[00011cb4] e268                      lsr.w     d1,d0
[00011cb6] c07c 00ff                 and.w     #$00FF,d0
[00011cba] d040                      add.w     d0,d0
[00011cbc] d040                      add.w     d0,d0
[00011cbe] 22f4 0000                 move.l    0(a4,d0.w),(a1)+
[00011cc2] 51ce ffea                 dbf       d6,$00011CAE
[00011cc6] 1018                      move.b    (a0)+,d0
[00011cc8] e148                      lsl.w     #8,d0
[00011cca] 1010                      move.b    (a0),d0
[00011ccc] e268                      lsr.w     d1,d0
[00011cce] c07c 00ff                 and.w     #$00FF,d0
[00011cd2] d040                      add.w     d0,d0
[00011cd4] d040                      add.w     d0,d0
[00011cd6] 2034 0000                 move.l    0(a4,d0.w),d0
[00011cda] 8791                      or.l      d3,(a1)
[00011cdc] 4680                      not.l     d0
[00011cde] c083                      and.l     d3,d0
[00011ce0] b199                      eor.l     d0,(a1)+
[00011ce2] d0ca                      adda.w    a2,a0
[00011ce4] d2cb                      adda.w    a3,a1
[00011ce6] 51cd ffa2                 dbf       d5,$00011C8A
[00011cea] 4e75                      rts
[00011cec] 2a46                      movea.l   d6,a5
[00011cee] 4a47                      tst.w     d7
[00011cf0] 6600 00ea                 bne       $00011DDC
[00011cf4] bc7c ffff                 cmp.w     #$FFFF,d6
[00011cf8] 6600 00e2                 bne       $00011DDC
[00011cfc] 7000                      moveq.l   #0,d0
[00011cfe] 1010                      move.b    (a0),d0
[00011d00] e268                      lsr.w     d1,d0
[00011d02] d040                      add.w     d0,d0
[00011d04] d040                      add.w     d0,d0
[00011d06] 2034 0000                 move.l    0(a4,d0.w),d0
[00011d0a] 8591                      or.l      d2,(a1)
[00011d0c] 4680                      not.l     d0
[00011d0e] c082                      and.l     d2,d0
[00011d10] b199                      eor.l     d0,(a1)+
[00011d12] 3c04                      move.w    d4,d6
[00011d14] 6b38                      bmi.s     $00011D4E
[00011d16] 5346                      subq.w    #1,d6
[00011d18] 6b18                      bmi.s     $00011D32
[00011d1a] 1018                      move.b    (a0)+,d0
[00011d1c] e148                      lsl.w     #8,d0
[00011d1e] 1010                      move.b    (a0),d0
[00011d20] e268                      lsr.w     d1,d0
[00011d22] c07c 00ff                 and.w     #$00FF,d0
[00011d26] d040                      add.w     d0,d0
[00011d28] d040                      add.w     d0,d0
[00011d2a] 22f4 0000                 move.l    0(a4,d0.w),(a1)+
[00011d2e] 51ce ffea                 dbf       d6,$00011D1A
[00011d32] 1018                      move.b    (a0)+,d0
[00011d34] e148                      lsl.w     #8,d0
[00011d36] 1018                      move.b    (a0)+,d0
[00011d38] e268                      lsr.w     d1,d0
[00011d3a] c07c 00ff                 and.w     #$00FF,d0
[00011d3e] d040                      add.w     d0,d0
[00011d40] d040                      add.w     d0,d0
[00011d42] 2034 0000                 move.l    0(a4,d0.w),d0
[00011d46] 8791                      or.l      d3,(a1)
[00011d48] 4680                      not.l     d0
[00011d4a] c083                      and.l     d3,d0
[00011d4c] b199                      eor.l     d0,(a1)+
[00011d4e] d0ca                      adda.w    a2,a0
[00011d50] d2cb                      adda.w    a3,a1
[00011d52] 51cd ffa8                 dbf       d5,$00011CFC
[00011d56] 4e75                      rts
[00011d58] 1018                      move.b    (a0)+,d0
[00011d5a] e148                      lsl.w     #8,d0
[00011d5c] 1010                      move.b    (a0),d0
[00011d5e] e268                      lsr.w     d1,d0
[00011d60] c07c 00ff                 and.w     #$00FF,d0
[00011d64] d040                      add.w     d0,d0
[00011d66] d040                      add.w     d0,d0
[00011d68] 2034 0000                 move.l    0(a4,d0.w),d0
[00011d6c] 2c0d                      move.l    a5,d6
[00011d6e] cc80                      and.l     d0,d6
[00011d70] 4680                      not.l     d0
[00011d72] c087                      and.l     d7,d0
[00011d74] 8086                      or.l      d6,d0
[00011d76] 8591                      or.l      d2,(a1)
[00011d78] 4680                      not.l     d0
[00011d7a] c082                      and.l     d2,d0
[00011d7c] b199                      eor.l     d0,(a1)+
[00011d7e] 3f04                      move.w    d4,-(a7)
[00011d80] 6b4e                      bmi.s     $00011DD0
[00011d82] 5344                      subq.w    #1,d4
[00011d84] 6b24                      bmi.s     $00011DAA
[00011d86] 1018                      move.b    (a0)+,d0
[00011d88] e148                      lsl.w     #8,d0
[00011d8a] 1010                      move.b    (a0),d0
[00011d8c] e268                      lsr.w     d1,d0
[00011d8e] c07c 00ff                 and.w     #$00FF,d0
[00011d92] d040                      add.w     d0,d0
[00011d94] d040                      add.w     d0,d0
[00011d96] 2034 0000                 move.l    0(a4,d0.w),d0
[00011d9a] 2c0d                      move.l    a5,d6
[00011d9c] cc80                      and.l     d0,d6
[00011d9e] 4680                      not.l     d0
[00011da0] c087                      and.l     d7,d0
[00011da2] 8086                      or.l      d6,d0
[00011da4] 22c0                      move.l    d0,(a1)+
[00011da6] 51cc ffde                 dbf       d4,$00011D86
[00011daa] 1018                      move.b    (a0)+,d0
[00011dac] e148                      lsl.w     #8,d0
[00011dae] 1010                      move.b    (a0),d0
[00011db0] e268                      lsr.w     d1,d0
[00011db2] c07c 00ff                 and.w     #$00FF,d0
[00011db6] d040                      add.w     d0,d0
[00011db8] d040                      add.w     d0,d0
[00011dba] 2034 0000                 move.l    0(a4,d0.w),d0
[00011dbe] 2c0d                      move.l    a5,d6
[00011dc0] cc80                      and.l     d0,d6
[00011dc2] 4680                      not.l     d0
[00011dc4] c087                      and.l     d7,d0
[00011dc6] 8086                      or.l      d6,d0
[00011dc8] 8791                      or.l      d3,(a1)
[00011dca] 4680                      not.l     d0
[00011dcc] c083                      and.l     d3,d0
[00011dce] b199                      eor.l     d0,(a1)+
[00011dd0] d0ca                      adda.w    a2,a0
[00011dd2] d2cb                      adda.w    a3,a1
[00011dd4] 381f                      move.w    (a7)+,d4
[00011dd6] 51cd ff80                 dbf       d5,$00011D58
[00011dda] 4e75                      rts
[00011ddc] 7000                      moveq.l   #0,d0
[00011dde] 1010                      move.b    (a0),d0
[00011de0] e268                      lsr.w     d1,d0
[00011de2] d040                      add.w     d0,d0
[00011de4] d040                      add.w     d0,d0
[00011de6] 2034 0000                 move.l    0(a4,d0.w),d0
[00011dea] 2c0d                      move.l    a5,d6
[00011dec] cc80                      and.l     d0,d6
[00011dee] 4680                      not.l     d0
[00011df0] c087                      and.l     d7,d0
[00011df2] 8086                      or.l      d6,d0
[00011df4] 8591                      or.l      d2,(a1)
[00011df6] 4680                      not.l     d0
[00011df8] c082                      and.l     d2,d0
[00011dfa] b199                      eor.l     d0,(a1)+
[00011dfc] 3f04                      move.w    d4,-(a7)
[00011dfe] 6b4e                      bmi.s     $00011E4E
[00011e00] 5344                      subq.w    #1,d4
[00011e02] 6b24                      bmi.s     $00011E28
[00011e04] 1018                      move.b    (a0)+,d0
[00011e06] e148                      lsl.w     #8,d0
[00011e08] 1010                      move.b    (a0),d0
[00011e0a] e268                      lsr.w     d1,d0
[00011e0c] c07c 00ff                 and.w     #$00FF,d0
[00011e10] d040                      add.w     d0,d0
[00011e12] d040                      add.w     d0,d0
[00011e14] 2034 0000                 move.l    0(a4,d0.w),d0
[00011e18] 2c0d                      move.l    a5,d6
[00011e1a] cc80                      and.l     d0,d6
[00011e1c] 4680                      not.l     d0
[00011e1e] c087                      and.l     d7,d0
[00011e20] 8086                      or.l      d6,d0
[00011e22] 22c0                      move.l    d0,(a1)+
[00011e24] 51cc ffde                 dbf       d4,$00011E04
[00011e28] 1018                      move.b    (a0)+,d0
[00011e2a] e148                      lsl.w     #8,d0
[00011e2c] 1018                      move.b    (a0)+,d0
[00011e2e] e268                      lsr.w     d1,d0
[00011e30] c07c 00ff                 and.w     #$00FF,d0
[00011e34] d040                      add.w     d0,d0
[00011e36] d040                      add.w     d0,d0
[00011e38] 2034 0000                 move.l    0(a4,d0.w),d0
[00011e3c] 2c0d                      move.l    a5,d6
[00011e3e] cc80                      and.l     d0,d6
[00011e40] 4680                      not.l     d0
[00011e42] c087                      and.l     d7,d0
[00011e44] 8086                      or.l      d6,d0
[00011e46] 8791                      or.l      d3,(a1)
[00011e48] 4680                      not.l     d0
[00011e4a] c083                      and.l     d3,d0
[00011e4c] b199                      eor.l     d0,(a1)+
[00011e4e] d0ca                      adda.w    a2,a0
[00011e50] d2cb                      adda.w    a3,a1
[00011e52] 381f                      move.w    (a7)+,d4
[00011e54] 51cd ff86                 dbf       d5,$00011DDC
[00011e58] 4e75                      rts
[00011e5a] 4686                      not.l     d6
[00011e5c] 1018                      move.b    (a0)+,d0
[00011e5e] e148                      lsl.w     #8,d0
[00011e60] 1010                      move.b    (a0),d0
[00011e62] e268                      lsr.w     d1,d0
[00011e64] c07c 00ff                 and.w     #$00FF,d0
[00011e68] d040                      add.w     d0,d0
[00011e6a] d040                      add.w     d0,d0
[00011e6c] 2034 0000                 move.l    0(a4,d0.w),d0
[00011e70] c082                      and.l     d2,d0
[00011e72] 8191                      or.l      d0,(a1)
[00011e74] c086                      and.l     d6,d0
[00011e76] b199                      eor.l     d0,(a1)+
[00011e78] 3e04                      move.w    d4,d7
[00011e7a] 6b3e                      bmi.s     $00011EBA
[00011e7c] 5347                      subq.w    #1,d7
[00011e7e] 6b1e                      bmi.s     $00011E9E
[00011e80] 1018                      move.b    (a0)+,d0
[00011e82] e148                      lsl.w     #8,d0
[00011e84] 1010                      move.b    (a0),d0
[00011e86] e268                      lsr.w     d1,d0
[00011e88] c07c 00ff                 and.w     #$00FF,d0
[00011e8c] d040                      add.w     d0,d0
[00011e8e] d040                      add.w     d0,d0
[00011e90] 2034 0000                 move.l    0(a4,d0.w),d0
[00011e94] 8191                      or.l      d0,(a1)
[00011e96] c086                      and.l     d6,d0
[00011e98] b199                      eor.l     d0,(a1)+
[00011e9a] 51cf ffe4                 dbf       d7,$00011E80
[00011e9e] 1018                      move.b    (a0)+,d0
[00011ea0] e148                      lsl.w     #8,d0
[00011ea2] 1010                      move.b    (a0),d0
[00011ea4] e268                      lsr.w     d1,d0
[00011ea6] c07c 00ff                 and.w     #$00FF,d0
[00011eaa] d040                      add.w     d0,d0
[00011eac] d040                      add.w     d0,d0
[00011eae] 2034 0000                 move.l    0(a4,d0.w),d0
[00011eb2] c083                      and.l     d3,d0
[00011eb4] 8191                      or.l      d0,(a1)
[00011eb6] c086                      and.l     d6,d0
[00011eb8] b199                      eor.l     d0,(a1)+
[00011eba] d0ca                      adda.w    a2,a0
[00011ebc] d2cb                      adda.w    a3,a1
[00011ebe] 51cd ff9c                 dbf       d5,$00011E5C
[00011ec2] 4e75                      rts
[00011ec4] 4686                      not.l     d6
[00011ec6] 7000                      moveq.l   #0,d0
[00011ec8] 1010                      move.b    (a0),d0
[00011eca] e268                      lsr.w     d1,d0
[00011ecc] d040                      add.w     d0,d0
[00011ece] d040                      add.w     d0,d0
[00011ed0] 2034 0000                 move.l    0(a4,d0.w),d0
[00011ed4] c082                      and.l     d2,d0
[00011ed6] 8191                      or.l      d0,(a1)
[00011ed8] c086                      and.l     d6,d0
[00011eda] b199                      eor.l     d0,(a1)+
[00011edc] 3e04                      move.w    d4,d7
[00011ede] 6b3e                      bmi.s     $00011F1E
[00011ee0] 5347                      subq.w    #1,d7
[00011ee2] 6b1e                      bmi.s     $00011F02
[00011ee4] 1018                      move.b    (a0)+,d0
[00011ee6] e148                      lsl.w     #8,d0
[00011ee8] 1010                      move.b    (a0),d0
[00011eea] e268                      lsr.w     d1,d0
[00011eec] c07c 00ff                 and.w     #$00FF,d0
[00011ef0] d040                      add.w     d0,d0
[00011ef2] d040                      add.w     d0,d0
[00011ef4] 2034 0000                 move.l    0(a4,d0.w),d0
[00011ef8] 8191                      or.l      d0,(a1)
[00011efa] c086                      and.l     d6,d0
[00011efc] b199                      eor.l     d0,(a1)+
[00011efe] 51cf ffe4                 dbf       d7,$00011EE4
[00011f02] 1018                      move.b    (a0)+,d0
[00011f04] e148                      lsl.w     #8,d0
[00011f06] 1018                      move.b    (a0)+,d0
[00011f08] e268                      lsr.w     d1,d0
[00011f0a] c07c 00ff                 and.w     #$00FF,d0
[00011f0e] d040                      add.w     d0,d0
[00011f10] d040                      add.w     d0,d0
[00011f12] 2034 0000                 move.l    0(a4,d0.w),d0
[00011f16] c083                      and.l     d3,d0
[00011f18] 8191                      or.l      d0,(a1)
[00011f1a] c086                      and.l     d6,d0
[00011f1c] b199                      eor.l     d0,(a1)+
[00011f1e] d0ca                      adda.w    a2,a0
[00011f20] d2cb                      adda.w    a3,a1
[00011f22] 51cd ffa2                 dbf       d5,$00011EC6
[00011f26] 4e75                      rts
[00011f28] 1018                      move.b    (a0)+,d0
[00011f2a] e148                      lsl.w     #8,d0
[00011f2c] 1010                      move.b    (a0),d0
[00011f2e] e268                      lsr.w     d1,d0
[00011f30] c07c 00ff                 and.w     #$00FF,d0
[00011f34] d040                      add.w     d0,d0
[00011f36] d040                      add.w     d0,d0
[00011f38] 2034 0000                 move.l    0(a4,d0.w),d0
[00011f3c] c082                      and.l     d2,d0
[00011f3e] b199                      eor.l     d0,(a1)+
[00011f40] 3c04                      move.w    d4,d6
[00011f42] 6b36                      bmi.s     $00011F7A
[00011f44] 5346                      subq.w    #1,d6
[00011f46] 6b1a                      bmi.s     $00011F62
[00011f48] 1018                      move.b    (a0)+,d0
[00011f4a] e148                      lsl.w     #8,d0
[00011f4c] 1010                      move.b    (a0),d0
[00011f4e] e268                      lsr.w     d1,d0
[00011f50] c07c 00ff                 and.w     #$00FF,d0
[00011f54] d040                      add.w     d0,d0
[00011f56] d040                      add.w     d0,d0
[00011f58] 2034 0000                 move.l    0(a4,d0.w),d0
[00011f5c] b199                      eor.l     d0,(a1)+
[00011f5e] 51ce ffe8                 dbf       d6,$00011F48
[00011f62] 1018                      move.b    (a0)+,d0
[00011f64] e148                      lsl.w     #8,d0
[00011f66] 1010                      move.b    (a0),d0
[00011f68] e268                      lsr.w     d1,d0
[00011f6a] c07c 00ff                 and.w     #$00FF,d0
[00011f6e] d040                      add.w     d0,d0
[00011f70] d040                      add.w     d0,d0
[00011f72] 2034 0000                 move.l    0(a4,d0.w),d0
[00011f76] c083                      and.l     d3,d0
[00011f78] b199                      eor.l     d0,(a1)+
[00011f7a] d0ca                      adda.w    a2,a0
[00011f7c] d2cb                      adda.w    a3,a1
[00011f7e] 51cd ffa8                 dbf       d5,$00011F28
[00011f82] 4e75                      rts
[00011f84] 7000                      moveq.l   #0,d0
[00011f86] 1010                      move.b    (a0),d0
[00011f88] e268                      lsr.w     d1,d0
[00011f8a] d040                      add.w     d0,d0
[00011f8c] d040                      add.w     d0,d0
[00011f8e] 2034 0000                 move.l    0(a4,d0.w),d0
[00011f92] c082                      and.l     d2,d0
[00011f94] b199                      eor.l     d0,(a1)+
[00011f96] 3c04                      move.w    d4,d6
[00011f98] 6b36                      bmi.s     $00011FD0
[00011f9a] 5346                      subq.w    #1,d6
[00011f9c] 6b1a                      bmi.s     $00011FB8
[00011f9e] 1018                      move.b    (a0)+,d0
[00011fa0] e148                      lsl.w     #8,d0
[00011fa2] 1010                      move.b    (a0),d0
[00011fa4] e268                      lsr.w     d1,d0
[00011fa6] c07c 00ff                 and.w     #$00FF,d0
[00011faa] d040                      add.w     d0,d0
[00011fac] d040                      add.w     d0,d0
[00011fae] 2034 0000                 move.l    0(a4,d0.w),d0
[00011fb2] b199                      eor.l     d0,(a1)+
[00011fb4] 51ce ffe8                 dbf       d6,$00011F9E
[00011fb8] 1018                      move.b    (a0)+,d0
[00011fba] e148                      lsl.w     #8,d0
[00011fbc] 1018                      move.b    (a0)+,d0
[00011fbe] e268                      lsr.w     d1,d0
[00011fc0] c07c 00ff                 and.w     #$00FF,d0
[00011fc4] d040                      add.w     d0,d0
[00011fc6] d040                      add.w     d0,d0
[00011fc8] 2034 0000                 move.l    0(a4,d0.w),d0
[00011fcc] c083                      and.l     d3,d0
[00011fce] b199                      eor.l     d0,(a1)+
[00011fd0] d0ca                      adda.w    a2,a0
[00011fd2] d2cb                      adda.w    a3,a1
[00011fd4] 51cd ffae                 dbf       d5,$00011F84
[00011fd8] 4e75                      rts
[00011fda] 4687                      not.l     d7
[00011fdc] 1018                      move.b    (a0)+,d0
[00011fde] e148                      lsl.w     #8,d0
[00011fe0] 1010                      move.b    (a0),d0
[00011fe2] e268                      lsr.w     d1,d0
[00011fe4] c07c 00ff                 and.w     #$00FF,d0
[00011fe8] d040                      add.w     d0,d0
[00011fea] d040                      add.w     d0,d0
[00011fec] 2034 0000                 move.l    0(a4,d0.w),d0
[00011ff0] 4680                      not.l     d0
[00011ff2] c082                      and.l     d2,d0
[00011ff4] 8191                      or.l      d0,(a1)
[00011ff6] c087                      and.l     d7,d0
[00011ff8] b199                      eor.l     d0,(a1)+
[00011ffa] 3c04                      move.w    d4,d6
[00011ffc] 6b42                      bmi.s     $00012040
[00011ffe] 5346                      subq.w    #1,d6
[00012000] 6b20                      bmi.s     $00012022
[00012002] 1018                      move.b    (a0)+,d0
[00012004] e148                      lsl.w     #8,d0
[00012006] 1010                      move.b    (a0),d0
[00012008] e268                      lsr.w     d1,d0
[0001200a] c07c 00ff                 and.w     #$00FF,d0
[0001200e] d040                      add.w     d0,d0
[00012010] d040                      add.w     d0,d0
[00012012] 2034 0000                 move.l    0(a4,d0.w),d0
[00012016] 4680                      not.l     d0
[00012018] 8191                      or.l      d0,(a1)
[0001201a] c087                      and.l     d7,d0
[0001201c] b199                      eor.l     d0,(a1)+
[0001201e] 51ce ffe2                 dbf       d6,$00012002
[00012022] 1018                      move.b    (a0)+,d0
[00012024] e148                      lsl.w     #8,d0
[00012026] 1010                      move.b    (a0),d0
[00012028] e268                      lsr.w     d1,d0
[0001202a] c07c 00ff                 and.w     #$00FF,d0
[0001202e] d040                      add.w     d0,d0
[00012030] d040                      add.w     d0,d0
[00012032] 2034 0000                 move.l    0(a4,d0.w),d0
[00012036] 4680                      not.l     d0
[00012038] c083                      and.l     d3,d0
[0001203a] 8191                      or.l      d0,(a1)
[0001203c] c087                      and.l     d7,d0
[0001203e] b199                      eor.l     d0,(a1)+
[00012040] d0ca                      adda.w    a2,a0
[00012042] d2cb                      adda.w    a3,a1
[00012044] 51cd ff96                 dbf       d5,$00011FDC
[00012048] 4e75                      rts
[0001204a] 4687                      not.l     d7
[0001204c] 7000                      moveq.l   #0,d0
[0001204e] 1010                      move.b    (a0),d0
[00012050] e268                      lsr.w     d1,d0
[00012052] d040                      add.w     d0,d0
[00012054] d040                      add.w     d0,d0
[00012056] 2034 0000                 move.l    0(a4,d0.w),d0
[0001205a] 4680                      not.l     d0
[0001205c] c082                      and.l     d2,d0
[0001205e] 8191                      or.l      d0,(a1)
[00012060] c087                      and.l     d7,d0
[00012062] b199                      eor.l     d0,(a1)+
[00012064] 3c04                      move.w    d4,d6
[00012066] 6b42                      bmi.s     $000120AA
[00012068] 5346                      subq.w    #1,d6
[0001206a] 6b20                      bmi.s     $0001208C
[0001206c] 1018                      move.b    (a0)+,d0
[0001206e] e148                      lsl.w     #8,d0
[00012070] 1010                      move.b    (a0),d0
[00012072] e268                      lsr.w     d1,d0
[00012074] c07c 00ff                 and.w     #$00FF,d0
[00012078] d040                      add.w     d0,d0
[0001207a] d040                      add.w     d0,d0
[0001207c] 2034 0000                 move.l    0(a4,d0.w),d0
[00012080] 4680                      not.l     d0
[00012082] 8191                      or.l      d0,(a1)
[00012084] c087                      and.l     d7,d0
[00012086] b199                      eor.l     d0,(a1)+
[00012088] 51ce ffe2                 dbf       d6,$0001206C
[0001208c] 1018                      move.b    (a0)+,d0
[0001208e] e148                      lsl.w     #8,d0
[00012090] 1018                      move.b    (a0)+,d0
[00012092] e268                      lsr.w     d1,d0
[00012094] c07c 00ff                 and.w     #$00FF,d0
[00012098] d040                      add.w     d0,d0
[0001209a] d040                      add.w     d0,d0
[0001209c] 2034 0000                 move.l    0(a4,d0.w),d0
[000120a0] 4680                      not.l     d0
[000120a2] c083                      and.l     d3,d0
[000120a4] 8191                      or.l      d0,(a1)
[000120a6] c087                      and.l     d7,d0
[000120a8] b199                      eor.l     d0,(a1)+
[000120aa] d0ca                      adda.w    a2,a0
[000120ac] d2cb                      adda.w    a3,a1
[000120ae] 51cd ff9c                 dbf       d5,$0001204C
[000120b2] 4e75                      rts
[000120b4] 4e75                      rts
[000120b6] bc44                      cmp.w     d4,d6
[000120b8] be45                      cmp.w     d5,d7
[000120ba] 08ae 0004 01ef            bclr      #4,495(a6)
[000120c0] 6600 f4b2                 bne       $00011574
[000120c4] 7e0f                      moveq.l   #15,d7
[000120c6] ce6e 01ee                 and.w     494(a6),d7
[000120ca] 206e 01c2                 movea.l   450(a6),a0
[000120ce] 226e 01d6                 movea.l   470(a6),a1
[000120d2] 346e 01c6                 movea.w   454(a6),a2
[000120d6] 366e 01da                 movea.w   474(a6),a3
[000120da] 3c2e 01c8                 move.w    456(a6),d6
[000120de] bc6e 01dc                 cmp.w     476(a6),d6
[000120e2] 66d0                      bne.s     $000120B4
[000120e4] d040                      add.w     d0,d0
[000120e6] d040                      add.w     d0,d0
[000120e8] d442                      add.w     d2,d2
[000120ea] d442                      add.w     d2,d2
[000120ec] d844                      add.w     d4,d4
[000120ee] d844                      add.w     d4,d4
[000120f0] 5644                      addq.w    #3,d4
[000120f2] e74f                      lsl.w     #3,d7
[000120f4] 2848                      movea.l   a0,a4
[000120f6] 2a49                      movea.l   a1,a5
[000120f8] 3c0a                      move.w    a2,d6
[000120fa] ccc1                      mulu.w    d1,d6
[000120fc] d1c6                      adda.l    d6,a0
[000120fe] 3c00                      move.w    d0,d6
[00012100] e84e                      lsr.w     #4,d6
[00012102] dc46                      add.w     d6,d6
[00012104] d0c6                      adda.w    d6,a0
[00012106] 3c0b                      move.w    a3,d6
[00012108] ccc3                      mulu.w    d3,d6
[0001210a] d3c6                      adda.l    d6,a1
[0001210c] 3c02                      move.w    d2,d6
[0001210e] e84e                      lsr.w     #4,d6
[00012110] dc46                      add.w     d6,d6
[00012112] d2c6                      adda.w    d6,a1
[00012114] b1c9                      cmpa.l    a1,a0
[00012116] 623e                      bhi.s     $00012156
[00012118] 6724                      beq.s     $0001213E
[0001211a] d0ca                      adda.w    a2,a0
[0001211c] b3c8                      cmpa.l    a0,a1
[0001211e] 6500 0c28                 bcs       $00012D48
[00012122] 90ca                      suba.w    a2,a0
[00012124] 3c0a                      move.w    a2,d6
[00012126] ccc5                      mulu.w    d5,d6
[00012128] d1c6                      adda.l    d6,a0
[0001212a] 3c0b                      move.w    a3,d6
[0001212c] ccc5                      mulu.w    d5,d6
[0001212e] d3c6                      adda.l    d6,a1
[00012130] 3c0a                      move.w    a2,d6
[00012132] 4446                      neg.w     d6
[00012134] 3446                      movea.w   d6,a2
[00012136] 3c0b                      move.w    a3,d6
[00012138] 4446                      neg.w     d6
[0001213a] 3646                      movea.w   d6,a3
[0001213c] 6018                      bra.s     $00012156
[0001213e] 7c0f                      moveq.l   #15,d6
[00012140] cc40                      and.w     d0,d6
[00012142] 3f06                      move.w    d6,-(a7)
[00012144] 7c0f                      moveq.l   #15,d6
[00012146] cc42                      and.w     d2,d6
[00012148] 9c5f                      sub.w     (a7)+,d6
[0001214a] 6e00 0bfc                 bgt       $00012D48
[0001214e] 6606                      bne.s     $00012156
[00012150] b6ca                      cmpa.w    a2,a3
[00012152] 6e00 0bf4                 bgt       $00012D48
[00012156] 3a47                      movea.w   d7,a5
[00012158] 7c0f                      moveq.l   #15,d6
[0001215a] c046                      and.w     d6,d0
[0001215c] 3e00                      move.w    d0,d7
[0001215e] de44                      add.w     d4,d7
[00012160] e84f                      lsr.w     #4,d7
[00012162] 3602                      move.w    d2,d3
[00012164] c646                      and.w     d6,d3
[00012166] 9043                      sub.w     d3,d0
[00012168] 3202                      move.w    d2,d1
[0001216a] c246                      and.w     d6,d1
[0001216c] d244                      add.w     d4,d1
[0001216e] e849                      lsr.w     #4,d1
[00012170] 9e41                      sub.w     d1,d7
[00012172] d842                      add.w     d2,d4
[00012174] 4644                      not.w     d4
[00012176] c846                      and.w     d6,d4
[00012178] 76ff                      moveq.l   #-1,d3
[0001217a] e96b                      lsl.w     d4,d3
[0001217c] cc42                      and.w     d2,d6
[0001217e] 74ff                      moveq.l   #-1,d2
[00012180] ec6a                      lsr.w     d6,d2
[00012182] 3801                      move.w    d1,d4
[00012184] d844                      add.w     d4,d4
[00012186] 94c4                      suba.w    d4,a2
[00012188] 96c4                      suba.w    d4,a3
[0001218a] 3807                      move.w    d7,d4
[0001218c] 7c04                      moveq.l   #4,d6
[0001218e] 7e00                      moveq.l   #0,d7
[00012190] 49fa 007c                 lea.l     $0001220E(pc),a4
[00012194] 4a40                      tst.w     d0
[00012196] 674c                      beq.s     $000121E4
[00012198] 6d2c                      blt.s     $000121C6
[0001219a] 49fa 00f2                 lea.l     $0001228E(pc),a4
[0001219e] 4a41                      tst.w     d1
[000121a0] 6608                      bne.s     $000121AA
[000121a2] 4a44                      tst.w     d4
[000121a4] 6604                      bne.s     $000121AA
[000121a6] 7c0a                      moveq.l   #10,d6
[000121a8] 603a                      bra.s     $000121E4
[000121aa] 7c04                      moveq.l   #4,d6
[000121ac] 554a                      subq.w    #2,a2
[000121ae] 4a44                      tst.w     d4
[000121b0] 6e02                      bgt.s     $000121B4
[000121b2] 7e02                      moveq.l   #2,d7
[000121b4] b07c 0008                 cmp.w     #$0008,d0
[000121b8] 6f2a                      ble.s     $000121E4
[000121ba] 49fa 0152                 lea.l     $0001230E(pc),a4
[000121be] 5340                      subq.w    #1,d0
[000121c0] 0a40 000f                 eori.w    #$000F,d0
[000121c4] 601e                      bra.s     $000121E4
[000121c6] 49fa 0146                 lea.l     $0001230E(pc),a4
[000121ca] 4440                      neg.w     d0
[000121cc] 7c08                      moveq.l   #8,d6
[000121ce] 4a44                      tst.w     d4
[000121d0] 6a02                      bpl.s     $000121D4
[000121d2] 7e02                      moveq.l   #2,d7
[000121d4] 0c40 0008                 cmpi.w    #$0008,d0
[000121d8] 6f0a                      ble.s     $000121E4
[000121da] 49fa 00b2                 lea.l     $0001228E(pc),a4
[000121de] 5340                      subq.w    #1,d0
[000121e0] 0a40 000f                 eori.w    #$000F,d0
[000121e4] dbcc                      adda.l    a4,a5
[000121e6] 381d                      move.w    (a5)+,d4
[000121e8] dc44                      add.w     d4,d6
[000121ea] de5d                      add.w     (a5)+,d7
[000121ec] 4a41                      tst.w     d1
[000121ee] 660c                      bne.s     $000121FC
[000121f0] 3e15                      move.w    (a5),d7
[000121f2] c443                      and.w     d3,d2
[000121f4] 7600                      moveq.l   #0,d3
[000121f6] 7200                      moveq.l   #0,d1
[000121f8] 554a                      subq.w    #2,a2
[000121fa] 554b                      subq.w    #2,a3
[000121fc] 5541                      subq.w    #2,d1
[000121fe] 49fa 000e                 lea.l     $0001220E(pc),a4
[00012202] 4bfa 000a                 lea.l     $0001220E(pc),a5
[00012206] d8c6                      adda.w    d6,a4
[00012208] dac7                      adda.w    d7,a5
[0001220a] 4efb 4002                 jmp       $0001220E(pc,d4.w)
[0001220e] 0180                      bclr      d0,d0
[00012210] 01a2                      bclr      d0,-(a2)
[00012212] 01a4                      bclr      d0,-(a4)
[00012214] 0000 01b0                 ori.b     #$B0,d0
[00012218] 01c8 01d2                 movep.l   d0,466(a0)
[0001221c] 0000 0262                 ori.b     #$62,d0
[00012220] 027e 028a                 andi.w    #$028A,???
[00012224] 0000 0326                 ori.b     #$26,d0
[00012228] 0000 0000                 ori.b     #$00,d0
[0001222c] 0000 04a6                 ori.b     #$A6,d0
[00012230] 04be 04c6 0000            subi.l    #$04C60000,???
[00012236] 0552                      bchg      d2,(a2)
[00012238] 0552                      bchg      d2,(a2)
[0001223a] 0552                      bchg      d2,(a2)
[0001223c] 0000 0554                 ori.b     #$54,d0
[00012240] 0568 056e                 bchg      d2,1390(a0)
[00012244] 0000 05ee                 ori.b     #$EE,d0
[00012248] 0602 0608                 addi.b    #$08,d2
[0001224c] 0000 06c2                 ori.b     #$C2,d0
[00012250] 06da 06e2                 callm     #$06E2,(a2)+ ; 68020 only
[00012254] 0000 076c                 ori.b     #$6C,d0
[00012258] 0784                      bclr      d3,d4
[0001225a] 078c 0000                 movep.w   d3,0(a4)
[0001225e] 0818 0834                 btst      #2100,(a0)+
[00012262] 0836 0000 0840            btst      #0,64(a6,d0.l)
[00012268] 0858 0860                 bchg      #2144,(a0)+
[0001226c] 0000 08ec                 ori.b     #$EC,d0
[00012270] 090a 0918                 movep.w   2328(a2),d4
[00012274] 0000 09bc                 ori.b     #$BC,d0
[00012278] 09d4                      bset      d4,(a4)
[0001227a] 09dc                      bset      d4,(a4)+
[0001227c] 0000 0a68                 ori.b     #$68,d0
[00012280] 0a80 0a88 0000            eori.l    #$0A880000,d0
[00012286] 0b14                      btst      d5,(a4)
[00012288] 0b30 0b32 0000 0180 01a2  btst      d5,([$00000180,a0,d0.l*2],$01A2) ; 68020+ only
[00012292] 01a4                      bclr      d0,-(a4)
[00012294] 0000 021e                 ori.b     #$1E,d0
[00012298] 024a 0258                 andi.w    #$0258,a2 ; apollo only
[0001229c] 0000 02dc                 ori.b     #$DC,d0
[000122a0] 030c 031c                 movep.w   796(a4),d1
[000122a4] 0000 0446                 ori.b     #$46,d0
[000122a8] 048e 049c 0000            subi.l    #$049C0000,a6 ; apollo only
[000122ae] 0510                      btst      d2,(a0)
[000122b0] 053c                      btst      d2,#
[000122b2] 0548 0000                 movep.l   0(a0),d2
[000122b6] 0552                      bchg      d2,(a2)
[000122b8] 0552                      bchg      d2,(a2)
[000122ba] 0552                      bchg      d2,(a2)
[000122bc] 0000 05b2                 ori.b     #$B2,d0
[000122c0] 05da                      bset      d2,(a2)+
[000122c2] 05e4                      bset      d2,-(a4)
[000122c4] 0000 066a                 ori.b     #$6A,d0
[000122c8] 06ae 06b8 0000 072a       addi.l    #$06B80000,1834(a6)
[000122d0] 0756                      bchg      d3,(a6)
[000122d2] 0762                      bchg      d3,-(a2)
[000122d4] 0000 07d6                 ori.b     #$D6,d0
[000122d8] 0802 080e                 btst      #2062,d2
[000122dc] 0000 0818                 ori.b     #$18,d0
[000122e0] 0834 0836 0000            btst      #2102,0(a4,d0.w)
[000122e6] 08aa 08d6 08e2            bclr      #2262,2274(a2)
[000122ec] 0000 096e                 ori.b     #$6E,d0
[000122f0] 09a0                      bclr      d4,-(a0)
[000122f2] 09b2 0000                 bclr      d4,0(a2,d0.w)
[000122f6] 0a26 0a52                 eori.b    #$52,-(a6)
[000122fa] 0a5e 0000                 eori.w    #$0000,(a6)+
[000122fe] 0ad2 0afe                 cas.b     d6,d3,(a2) ; 68020+ only
[00012302] 0b0a 0000                 movep.w   0(a2),d5
[00012306] 0b14                      btst      d5,(a4)
[00012308] 0b30 0b32 0000 0180 01a2  btst      d5,([$00000180,a0,d0.l*2],$01A2) ; 68020+ only
[00012312] 01a4                      bclr      d0,-(a4)
[00012314] 0000 01dc                 ori.b     #$DC,d0
[00012318] 0208 0214                 andi.b    #$14,a0 ; apollo only
[0001231c] 0000 0294                 ori.b     #$94,d0
[00012320] 02c4                      byterev.l d4 ; ColdFire isa_c only
[00012322] 02d2 0000                 cmp2.w    (a2),d0 ; 68020+ only
[00012326] 03e6                      bset      d1,-(a6)
[00012328] 0430 043c 0000            subi.b    #$3C,0(a0,d0.w)
[0001232e] 04d0 04fc                 cmp2.l    (a0),d0 ; 68020+ only
[00012332] 0506                      btst      d2,d6
[00012334] 0000 0552                 ori.b     #$52,d0
[00012338] 0552                      bchg      d2,(a2)
[0001233a] 0552                      bchg      d2,(a2)
[0001233c] 0000 0578                 ori.b     #$78,d0
[00012340] 05a0                      bclr      d2,-(a0)
[00012342] 05a8 0000                 bclr      d2,0(a0)
[00012346] 0612 0658                 addi.b    #$58,(a2)
[0001234a] 0660 0000                 addi.w    #$0000,-(a0)
[0001234e] 06ec 0716 0720            callm     #$0716,1824(a4) ; 68020 only
[00012354] 0000 0796                 ori.b     #$96,d0
[00012358] 07c2                      bset      d3,d2
[0001235a] 07cc 0000                 movep.l   d3,0(a4)
[0001235e] 0818 0834                 btst      #2100,(a0)+
[00012362] 0836 0000 086a            btst      #0,106(a6,d0.l)
[00012368] 0896 08a0                 bclr      #2208,(a6)
[0001236c] 0000 0922                 ori.b     #$22,d0
[00012370] 0954                      bchg      d4,(a4)
[00012372] 0964                      bchg      d4,-(a4)
[00012374] 0000 09e6                 ori.b     #$E6,d0
[00012378] 0a12 0a1c                 eori.b    #$1C,(a2)
[0001237c] 0000 0a92                 ori.b     #$92,d0
[00012380] 0abe 0ac8 0000            eori.l    #$0AC80000,???
[00012386] 0b14                      btst      d5,(a4)
[00012388] 0b30 0b32 0000 4642 4643  btst      d5,([$00004642,a0,d0.l*2],$4643) ; 68020+ only
[00012392] 7e00                      moveq.l   #0,d7
[00012394] 4bfa 001c                 lea.l     $000123B2(pc),a5
[00012398] b67c ffff                 cmp.w     #$FFFF,d3
[0001239c] 6704                      beq.s     $000123A2
[0001239e] 4bfa 0010                 lea.l     $000123B0(pc),a5
[000123a2] c559                      and.w     d2,(a1)+
[000123a4] 3801                      move.w    d1,d4
[000123a6] 6b06                      bmi.s     $000123AE
[000123a8] 32c7                      move.w    d7,(a1)+
[000123aa] 51cc fffc                 dbf       d4,$000123A8
[000123ae] 4ed5                      jmp       (a5)
[000123b0] c751                      and.w     d3,(a1)
[000123b2] d2cb                      adda.w    a3,a1
[000123b4] 51cd ffec                 dbf       d5,$000123A2
[000123b8] 4642                      not.w     d2
[000123ba] 4643                      not.w     d3
[000123bc] 4e75                      rts
[000123be] 3c18                      move.w    (a0)+,d6
[000123c0] 4642                      not.w     d2
[000123c2] 8c42                      or.w      d2,d6
[000123c4] 4642                      not.w     d2
[000123c6] cd59                      and.w     d6,(a1)+
[000123c8] 3801                      move.w    d1,d4
[000123ca] 6b08                      bmi.s     $000123D4
[000123cc] 3c18                      move.w    (a0)+,d6
[000123ce] cd59                      and.w     d6,(a1)+
[000123d0] 51cc fffa                 dbf       d4,$000123CC
[000123d4] 4ed5                      jmp       (a5)
[000123d6] 3c10                      move.w    (a0),d6
[000123d8] 4643                      not.w     d3
[000123da] 8c43                      or.w      d3,d6
[000123dc] 4643                      not.w     d3
[000123de] cd51                      and.w     d6,(a1)
[000123e0] d0ca                      adda.w    a2,a0
[000123e2] d2cb                      adda.w    a3,a1
[000123e4] 51cd ffd8                 dbf       d5,$000123BE
[000123e8] 4e75                      rts
[000123ea] 3c18                      move.w    (a0)+,d6
[000123ec] 4ed4                      jmp       (a4)
[000123ee] 4846                      swap      d6
[000123f0] 3c18                      move.w    (a0)+,d6
[000123f2] 3e06                      move.w    d6,d7
[000123f4] e0be                      ror.l     d0,d6
[000123f6] 4642                      not.w     d2
[000123f8] 8c42                      or.w      d2,d6
[000123fa] 4642                      not.w     d2
[000123fc] cd59                      and.w     d6,(a1)+
[000123fe] 3801                      move.w    d1,d4
[00012400] 6b10                      bmi.s     $00012412
[00012402] 3c07                      move.w    d7,d6
[00012404] 4846                      swap      d6
[00012406] 3c18                      move.w    (a0)+,d6
[00012408] 3e06                      move.w    d6,d7
[0001240a] e0be                      ror.l     d0,d6
[0001240c] cd59                      and.w     d6,(a1)+
[0001240e] 51cc fff2                 dbf       d4,$00012402
[00012412] 4847                      swap      d7
[00012414] 4ed5                      jmp       (a5)
[00012416] 3e10                      move.w    (a0),d7
[00012418] e0bf                      ror.l     d0,d7
[0001241a] 4643                      not.w     d3
[0001241c] 8e43                      or.w      d3,d7
[0001241e] 4643                      not.w     d3
[00012420] cf51                      and.w     d7,(a1)
[00012422] d0ca                      adda.w    a2,a0
[00012424] d2cb                      adda.w    a3,a1
[00012426] 51cd ffc2                 dbf       d5,$000123EA
[0001242a] 4e75                      rts
[0001242c] 3c18                      move.w    (a0)+,d6
[0001242e] 4ed4                      jmp       (a4)
[00012430] 4846                      swap      d6
[00012432] 3c18                      move.w    (a0)+,d6
[00012434] 4846                      swap      d6
[00012436] 2e06                      move.l    d6,d7
[00012438] e1be                      rol.l     d0,d6
[0001243a] 4642                      not.w     d2
[0001243c] 8c42                      or.w      d2,d6
[0001243e] 4642                      not.w     d2
[00012440] cd59                      and.w     d6,(a1)+
[00012442] 3801                      move.w    d1,d4
[00012444] 6b10                      bmi.s     $00012456
[00012446] 2c07                      move.l    d7,d6
[00012448] 3c18                      move.w    (a0)+,d6
[0001244a] 4846                      swap      d6
[0001244c] 2e06                      move.l    d6,d7
[0001244e] e1be                      rol.l     d0,d6
[00012450] cd59                      and.w     d6,(a1)+
[00012452] 51cc fff2                 dbf       d4,$00012446
[00012456] 4ed5                      jmp       (a5)
[00012458] 3e10                      move.w    (a0),d7
[0001245a] 4847                      swap      d7
[0001245c] e1bf                      rol.l     d0,d7
[0001245e] 4643                      not.w     d3
[00012460] 8e43                      or.w      d3,d7
[00012462] 4643                      not.w     d3
[00012464] cf51                      and.w     d7,(a1)
[00012466] d0ca                      adda.w    a2,a0
[00012468] d2cb                      adda.w    a3,a1
[0001246a] 51cd ffc0                 dbf       d5,$0001242C
[0001246e] 4e75                      rts
[00012470] 3c18                      move.w    (a0)+,d6
[00012472] b551                      eor.w     d2,(a1)
[00012474] 4642                      not.w     d2
[00012476] 8c42                      or.w      d2,d6
[00012478] 4642                      not.w     d2
[0001247a] cd59                      and.w     d6,(a1)+
[0001247c] 3801                      move.w    d1,d4
[0001247e] 6b0a                      bmi.s     $0001248A
[00012480] 3c18                      move.w    (a0)+,d6
[00012482] 4651                      not.w     (a1)
[00012484] cd59                      and.w     d6,(a1)+
[00012486] 51cc fff8                 dbf       d4,$00012480
[0001248a] 4ed5                      jmp       (a5)
[0001248c] 3c10                      move.w    (a0),d6
[0001248e] b751                      eor.w     d3,(a1)
[00012490] 4643                      not.w     d3
[00012492] 8c43                      or.w      d3,d6
[00012494] 4643                      not.w     d3
[00012496] cd51                      and.w     d6,(a1)
[00012498] d0ca                      adda.w    a2,a0
[0001249a] d2cb                      adda.w    a3,a1
[0001249c] 51cd ffd2                 dbf       d5,$00012470
[000124a0] 4e75                      rts
[000124a2] 3c18                      move.w    (a0)+,d6
[000124a4] 4ed4                      jmp       (a4)
[000124a6] 4846                      swap      d6
[000124a8] 3c18                      move.w    (a0)+,d6
[000124aa] 3e06                      move.w    d6,d7
[000124ac] e0be                      ror.l     d0,d6
[000124ae] b551                      eor.w     d2,(a1)
[000124b0] 4642                      not.w     d2
[000124b2] 8c42                      or.w      d2,d6
[000124b4] 4642                      not.w     d2
[000124b6] cd59                      and.w     d6,(a1)+
[000124b8] 3801                      move.w    d1,d4
[000124ba] 6b12                      bmi.s     $000124CE
[000124bc] 3c07                      move.w    d7,d6
[000124be] 4846                      swap      d6
[000124c0] 3c18                      move.w    (a0)+,d6
[000124c2] 3e06                      move.w    d6,d7
[000124c4] e0be                      ror.l     d0,d6
[000124c6] 4651                      not.w     (a1)
[000124c8] cd59                      and.w     d6,(a1)+
[000124ca] 51cc fff0                 dbf       d4,$000124BC
[000124ce] 4847                      swap      d7
[000124d0] 4ed5                      jmp       (a5)
[000124d2] 3e10                      move.w    (a0),d7
[000124d4] e0bf                      ror.l     d0,d7
[000124d6] b751                      eor.w     d3,(a1)
[000124d8] 4643                      not.w     d3
[000124da] 8e43                      or.w      d3,d7
[000124dc] 4643                      not.w     d3
[000124de] cf51                      and.w     d7,(a1)
[000124e0] d0ca                      adda.w    a2,a0
[000124e2] d2cb                      adda.w    a3,a1
[000124e4] 51cd ffbc                 dbf       d5,$000124A2
[000124e8] 4e75                      rts
[000124ea] 3c18                      move.w    (a0)+,d6
[000124ec] 4ed4                      jmp       (a4)
[000124ee] 4846                      swap      d6
[000124f0] 3c18                      move.w    (a0)+,d6
[000124f2] 4846                      swap      d6
[000124f4] 2e06                      move.l    d6,d7
[000124f6] e1be                      rol.l     d0,d6
[000124f8] b551                      eor.w     d2,(a1)
[000124fa] 4642                      not.w     d2
[000124fc] 8c42                      or.w      d2,d6
[000124fe] 4642                      not.w     d2
[00012500] cd59                      and.w     d6,(a1)+
[00012502] 3801                      move.w    d1,d4
[00012504] 6b12                      bmi.s     $00012518
[00012506] 2c07                      move.l    d7,d6
[00012508] 3c18                      move.w    (a0)+,d6
[0001250a] 4846                      swap      d6
[0001250c] 2e06                      move.l    d6,d7
[0001250e] e1be                      rol.l     d0,d6
[00012510] 4651                      not.w     (a1)
[00012512] cd59                      and.w     d6,(a1)+
[00012514] 51cc fff0                 dbf       d4,$00012506
[00012518] 4ed5                      jmp       (a5)
[0001251a] 3e10                      move.w    (a0),d7
[0001251c] 4847                      swap      d7
[0001251e] e1bf                      rol.l     d0,d7
[00012520] b751                      eor.w     d3,(a1)
[00012522] 4643                      not.w     d3
[00012524] 8e43                      or.w      d3,d7
[00012526] 4643                      not.w     d3
[00012528] cf51                      and.w     d7,(a1)
[0001252a] d0ca                      adda.w    a2,a0
[0001252c] d2cb                      adda.w    a3,a1
[0001252e] 51cd ffba                 dbf       d5,$000124EA
[00012532] 4e75                      rts
[00012534] 3801                      move.w    d1,d4
[00012536] 6b00 0084                 bmi       $000125BC
[0001253a] e24c                      lsr.w     #1,d4
[0001253c] 6522                      bcs.s     $00012560
[0001253e] 49fa 0040                 lea.l     $00012580(pc),a4
[00012542] 6606                      bne.s     $0001254A
[00012544] 4bfa 0062                 lea.l     $000125A8(pc),a5
[00012548] 6028                      bra.s     $00012572
[0001254a] 5344                      subq.w    #1,d4
[0001254c] 3004                      move.w    d4,d0
[0001254e] e84c                      lsr.w     #4,d4
[00012550] 3204                      move.w    d4,d1
[00012552] 4640                      not.w     d0
[00012554] 0240 000f                 andi.w    #$000F,d0
[00012558] d040                      add.w     d0,d0
[0001255a] 4bfb 0028                 lea.l     $00012584(pc,d0.w),a5
[0001255e] 6012                      bra.s     $00012572
[00012560] 3004                      move.w    d4,d0
[00012562] e84c                      lsr.w     #4,d4
[00012564] 3204                      move.w    d4,d1
[00012566] 4640                      not.w     d0
[00012568] 0240 000f                 andi.w    #$000F,d0
[0001256c] d040                      add.w     d0,d0
[0001256e] 49fb 0014                 lea.l     $00012584(pc,d0.w),a4
[00012572] 3c18                      move.w    (a0)+,d6
[00012574] 4646                      not.w     d6
[00012576] cc42                      and.w     d2,d6
[00012578] 8551                      or.w      d2,(a1)
[0001257a] bd59                      eor.w     d6,(a1)+
[0001257c] 3801                      move.w    d1,d4
[0001257e] 4ed4                      jmp       (a4)
[00012580] 32d8                      move.w    (a0)+,(a1)+
[00012582] 4ed5                      jmp       (a5)
[00012584] 22d8                      move.l    (a0)+,(a1)+
[00012586] 22d8                      move.l    (a0)+,(a1)+
[00012588] 22d8                      move.l    (a0)+,(a1)+
[0001258a] 22d8                      move.l    (a0)+,(a1)+
[0001258c] 22d8                      move.l    (a0)+,(a1)+
[0001258e] 22d8                      move.l    (a0)+,(a1)+
[00012590] 22d8                      move.l    (a0)+,(a1)+
[00012592] 22d8                      move.l    (a0)+,(a1)+
[00012594] 22d8                      move.l    (a0)+,(a1)+
[00012596] 22d8                      move.l    (a0)+,(a1)+
[00012598] 22d8                      move.l    (a0)+,(a1)+
[0001259a] 22d8                      move.l    (a0)+,(a1)+
[0001259c] 22d8                      move.l    (a0)+,(a1)+
[0001259e] 22d8                      move.l    (a0)+,(a1)+
[000125a0] 22d8                      move.l    (a0)+,(a1)+
[000125a2] 22d8                      move.l    (a0)+,(a1)+
[000125a4] 51cc ffde                 dbf       d4,$00012584
[000125a8] 3c10                      move.w    (a0),d6
[000125aa] 4646                      not.w     d6
[000125ac] cc43                      and.w     d3,d6
[000125ae] 8751                      or.w      d3,(a1)
[000125b0] bd51                      eor.w     d6,(a1)
[000125b2] d0ca                      adda.w    a2,a0
[000125b4] d2cb                      adda.w    a3,a1
[000125b6] 51cd ffba                 dbf       d5,$00012572
[000125ba] 4e75                      rts
[000125bc] 544a                      addq.w    #2,a2
[000125be] 544b                      addq.w    #2,a3
[000125c0] 4a43                      tst.w     d3
[000125c2] 671a                      beq.s     $000125DE
[000125c4] 4842                      swap      d2
[000125c6] 3403                      move.w    d3,d2
[000125c8] 2602                      move.l    d2,d3
[000125ca] 4683                      not.l     d3
[000125cc] 2c10                      move.l    (a0),d6
[000125ce] cc82                      and.l     d2,d6
[000125d0] c791                      and.l     d3,(a1)
[000125d2] 8d91                      or.l      d6,(a1)
[000125d4] d0ca                      adda.w    a2,a0
[000125d6] d2cb                      adda.w    a3,a1
[000125d8] 51cd fff2                 dbf       d5,$000125CC
[000125dc] 4e75                      rts
[000125de] 3602                      move.w    d2,d3
[000125e0] 4643                      not.w     d3
[000125e2] 3c10                      move.w    (a0),d6
[000125e4] cc42                      and.w     d2,d6
[000125e6] c751                      and.w     d3,(a1)
[000125e8] 8d51                      or.w      d6,(a1)
[000125ea] d0ca                      adda.w    a2,a0
[000125ec] d2cb                      adda.w    a3,a1
[000125ee] 51cd fff2                 dbf       d5,$000125E2
[000125f2] 4e75                      rts
[000125f4] 3c18                      move.w    (a0)+,d6
[000125f6] 4ed4                      jmp       (a4)
[000125f8] 4846                      swap      d6
[000125fa] 3c18                      move.w    (a0)+,d6
[000125fc] 3e06                      move.w    d6,d7
[000125fe] 4847                      swap      d7
[00012600] e0be                      ror.l     d0,d6
[00012602] 4646                      not.w     d6
[00012604] cc42                      and.w     d2,d6
[00012606] 8551                      or.w      d2,(a1)
[00012608] bd59                      eor.w     d6,(a1)+
[0001260a] 4845                      swap      d5
[0001260c] 3a01                      move.w    d1,d5
[0001260e] 6b2a                      bmi.s     $0001263A
[00012610] e24d                      lsr.w     #1,d5
[00012612] 650e                      bcs.s     $00012622
[00012614] 3e18                      move.w    (a0)+,d7
[00012616] 2c07                      move.l    d7,d6
[00012618] 4847                      swap      d7
[0001261a] e0be                      ror.l     d0,d6
[0001261c] 32c6                      move.w    d6,(a1)+
[0001261e] 5345                      subq.w    #1,d5
[00012620] 6b18                      bmi.s     $0001263A
[00012622] 2c07                      move.l    d7,d6
[00012624] 2e18                      move.l    (a0)+,d7
[00012626] 2807                      move.l    d7,d4
[00012628] 4847                      swap      d7
[0001262a] 3c07                      move.w    d7,d6
[0001262c] e0be                      ror.l     d0,d6
[0001262e] e0bc                      ror.l     d0,d4
[00012630] 4846                      swap      d6
[00012632] 3c04                      move.w    d4,d6
[00012634] 22c6                      move.l    d6,(a1)+
[00012636] 51cd ffea                 dbf       d5,$00012622
[0001263a] 4845                      swap      d5
[0001263c] 4ed5                      jmp       (a5)
[0001263e] 3e10                      move.w    (a0),d7
[00012640] e0bf                      ror.l     d0,d7
[00012642] 4647                      not.w     d7
[00012644] ce43                      and.w     d3,d7
[00012646] 8751                      or.w      d3,(a1)
[00012648] bf51                      eor.w     d7,(a1)
[0001264a] d0ca                      adda.w    a2,a0
[0001264c] d2cb                      adda.w    a3,a1
[0001264e] 51cd ffa4                 dbf       d5,$000125F4
[00012652] 4e75                      rts
[00012654] 3c18                      move.w    (a0)+,d6
[00012656] 4ed4                      jmp       (a4)
[00012658] 4846                      swap      d6
[0001265a] 3c18                      move.w    (a0)+,d6
[0001265c] 4846                      swap      d6
[0001265e] 2e06                      move.l    d6,d7
[00012660] e1be                      rol.l     d0,d6
[00012662] 4646                      not.w     d6
[00012664] cc42                      and.w     d2,d6
[00012666] 8551                      or.w      d2,(a1)
[00012668] bd59                      eor.w     d6,(a1)+
[0001266a] 4845                      swap      d5
[0001266c] 3a01                      move.w    d1,d5
[0001266e] 6b28                      bmi.s     $00012698
[00012670] e24d                      lsr.w     #1,d5
[00012672] 650e                      bcs.s     $00012682
[00012674] 3e18                      move.w    (a0)+,d7
[00012676] 4847                      swap      d7
[00012678] 2c07                      move.l    d7,d6
[0001267a] e1be                      rol.l     d0,d6
[0001267c] 32c6                      move.w    d6,(a1)+
[0001267e] 5345                      subq.w    #1,d5
[00012680] 6b16                      bmi.s     $00012698
[00012682] 2c07                      move.l    d7,d6
[00012684] 2e18                      move.l    (a0)+,d7
[00012686] 4847                      swap      d7
[00012688] 3c07                      move.w    d7,d6
[0001268a] 2807                      move.l    d7,d4
[0001268c] e1be                      rol.l     d0,d6
[0001268e] e1bc                      rol.l     d0,d4
[00012690] 3c04                      move.w    d4,d6
[00012692] 22c6                      move.l    d6,(a1)+
[00012694] 51cd ffec                 dbf       d5,$00012682
[00012698] 4845                      swap      d5
[0001269a] 4ed5                      jmp       (a5)
[0001269c] 3e10                      move.w    (a0),d7
[0001269e] 4847                      swap      d7
[000126a0] e1bf                      rol.l     d0,d7
[000126a2] 4647                      not.w     d7
[000126a4] ce43                      and.w     d3,d7
[000126a6] 8751                      or.w      d3,(a1)
[000126a8] bf51                      eor.w     d7,(a1)
[000126aa] d0ca                      adda.w    a2,a0
[000126ac] d2cb                      adda.w    a3,a1
[000126ae] 51cd ffa4                 dbf       d5,$00012654
[000126b2] 4e75                      rts
[000126b4] 3c18                      move.w    (a0)+,d6
[000126b6] cc42                      and.w     d2,d6
[000126b8] 4646                      not.w     d6
[000126ba] cd59                      and.w     d6,(a1)+
[000126bc] 3801                      move.w    d1,d4
[000126be] 6b0a                      bmi.s     $000126CA
[000126c0] 3c18                      move.w    (a0)+,d6
[000126c2] 4646                      not.w     d6
[000126c4] cd59                      and.w     d6,(a1)+
[000126c6] 51cc fff8                 dbf       d4,$000126C0
[000126ca] 4ed5                      jmp       (a5)
[000126cc] 3c10                      move.w    (a0),d6
[000126ce] cc43                      and.w     d3,d6
[000126d0] 4646                      not.w     d6
[000126d2] cd51                      and.w     d6,(a1)
[000126d4] d0ca                      adda.w    a2,a0
[000126d6] d2cb                      adda.w    a3,a1
[000126d8] 51cd ffda                 dbf       d5,$000126B4
[000126dc] 4e75                      rts
[000126de] 3c18                      move.w    (a0)+,d6
[000126e0] 4ed4                      jmp       (a4)
[000126e2] 4846                      swap      d6
[000126e4] 3c18                      move.w    (a0)+,d6
[000126e6] 3e06                      move.w    d6,d7
[000126e8] e0be                      ror.l     d0,d6
[000126ea] cc42                      and.w     d2,d6
[000126ec] 4646                      not.w     d6
[000126ee] cd59                      and.w     d6,(a1)+
[000126f0] 3801                      move.w    d1,d4
[000126f2] 6b12                      bmi.s     $00012706
[000126f4] 3c07                      move.w    d7,d6
[000126f6] 4846                      swap      d6
[000126f8] 3c18                      move.w    (a0)+,d6
[000126fa] 3e06                      move.w    d6,d7
[000126fc] e0be                      ror.l     d0,d6
[000126fe] 4646                      not.w     d6
[00012700] cd59                      and.w     d6,(a1)+
[00012702] 51cc fff0                 dbf       d4,$000126F4
[00012706] 4847                      swap      d7
[00012708] 4ed5                      jmp       (a5)
[0001270a] 3e10                      move.w    (a0),d7
[0001270c] e0bf                      ror.l     d0,d7
[0001270e] ce43                      and.w     d3,d7
[00012710] 4647                      not.w     d7
[00012712] cf51                      and.w     d7,(a1)
[00012714] d0ca                      adda.w    a2,a0
[00012716] d2cb                      adda.w    a3,a1
[00012718] 51cd ffc4                 dbf       d5,$000126DE
[0001271c] 4e75                      rts
[0001271e] 3c18                      move.w    (a0)+,d6
[00012720] 4ed4                      jmp       (a4)
[00012722] 4846                      swap      d6
[00012724] 3c18                      move.w    (a0)+,d6
[00012726] 4846                      swap      d6
[00012728] 2e06                      move.l    d6,d7
[0001272a] e1be                      rol.l     d0,d6
[0001272c] cc42                      and.w     d2,d6
[0001272e] 4646                      not.w     d6
[00012730] cd59                      and.w     d6,(a1)+
[00012732] 3801                      move.w    d1,d4
[00012734] 6b12                      bmi.s     $00012748
[00012736] 2c07                      move.l    d7,d6
[00012738] 3c18                      move.w    (a0)+,d6
[0001273a] 4846                      swap      d6
[0001273c] 2e06                      move.l    d6,d7
[0001273e] e1be                      rol.l     d0,d6
[00012740] 4646                      not.w     d6
[00012742] cd59                      and.w     d6,(a1)+
[00012744] 51cc fff0                 dbf       d4,$00012736
[00012748] 4ed5                      jmp       (a5)
[0001274a] 3e10                      move.w    (a0),d7
[0001274c] 4847                      swap      d7
[0001274e] e1bf                      rol.l     d0,d7
[00012750] ce43                      and.w     d3,d7
[00012752] 4647                      not.w     d7
[00012754] cf51                      and.w     d7,(a1)
[00012756] d0ca                      adda.w    a2,a0
[00012758] d2cb                      adda.w    a3,a1
[0001275a] 51cd ffc2                 dbf       d5,$0001271E
[0001275e] 4e75                      rts
[00012760] 4e75                      rts
[00012762] 3c18                      move.w    (a0)+,d6
[00012764] cc42                      and.w     d2,d6
[00012766] bd59                      eor.w     d6,(a1)+
[00012768] 3801                      move.w    d1,d4
[0001276a] 6b08                      bmi.s     $00012774
[0001276c] 3c18                      move.w    (a0)+,d6
[0001276e] bd59                      eor.w     d6,(a1)+
[00012770] 51cc fffa                 dbf       d4,$0001276C
[00012774] 4ed5                      jmp       (a5)
[00012776] 3c10                      move.w    (a0),d6
[00012778] cc43                      and.w     d3,d6
[0001277a] bd51                      eor.w     d6,(a1)
[0001277c] d0ca                      adda.w    a2,a0
[0001277e] d2cb                      adda.w    a3,a1
[00012780] 51cd ffe0                 dbf       d5,$00012762
[00012784] 4e75                      rts
[00012786] 3c18                      move.w    (a0)+,d6
[00012788] 4ed4                      jmp       (a4)
[0001278a] 4846                      swap      d6
[0001278c] 3c18                      move.w    (a0)+,d6
[0001278e] 3e06                      move.w    d6,d7
[00012790] e0be                      ror.l     d0,d6
[00012792] cc42                      and.w     d2,d6
[00012794] bd59                      eor.w     d6,(a1)+
[00012796] 3801                      move.w    d1,d4
[00012798] 6b10                      bmi.s     $000127AA
[0001279a] 3c07                      move.w    d7,d6
[0001279c] 4846                      swap      d6
[0001279e] 3c18                      move.w    (a0)+,d6
[000127a0] 3e06                      move.w    d6,d7
[000127a2] e0be                      ror.l     d0,d6
[000127a4] bd59                      eor.w     d6,(a1)+
[000127a6] 51cc fff2                 dbf       d4,$0001279A
[000127aa] 4847                      swap      d7
[000127ac] 4ed5                      jmp       (a5)
[000127ae] 3e10                      move.w    (a0),d7
[000127b0] e0bf                      ror.l     d0,d7
[000127b2] ce43                      and.w     d3,d7
[000127b4] bf51                      eor.w     d7,(a1)
[000127b6] d0ca                      adda.w    a2,a0
[000127b8] d2cb                      adda.w    a3,a1
[000127ba] 51cd ffca                 dbf       d5,$00012786
[000127be] 4e75                      rts
[000127c0] 3c18                      move.w    (a0)+,d6
[000127c2] 4ed4                      jmp       (a4)
[000127c4] 4846                      swap      d6
[000127c6] 3c18                      move.w    (a0)+,d6
[000127c8] 4846                      swap      d6
[000127ca] 2e06                      move.l    d6,d7
[000127cc] e1be                      rol.l     d0,d6
[000127ce] cc42                      and.w     d2,d6
[000127d0] bd59                      eor.w     d6,(a1)+
[000127d2] 3801                      move.w    d1,d4
[000127d4] 6b10                      bmi.s     $000127E6
[000127d6] 2c07                      move.l    d7,d6
[000127d8] 3c18                      move.w    (a0)+,d6
[000127da] 4846                      swap      d6
[000127dc] 2e06                      move.l    d6,d7
[000127de] e1be                      rol.l     d0,d6
[000127e0] bd59                      eor.w     d6,(a1)+
[000127e2] 51cc fff2                 dbf       d4,$000127D6
[000127e6] 4ed5                      jmp       (a5)
[000127e8] 3e10                      move.w    (a0),d7
[000127ea] 4847                      swap      d7
[000127ec] e1bf                      rol.l     d0,d7
[000127ee] ce43                      and.w     d3,d7
[000127f0] bf51                      eor.w     d7,(a1)
[000127f2] d0ca                      adda.w    a2,a0
[000127f4] d2cb                      adda.w    a3,a1
[000127f6] 51cd ffc8                 dbf       d5,$000127C0
[000127fa] 4e75                      rts
[000127fc] 3c18                      move.w    (a0)+,d6
[000127fe] cc42                      and.w     d2,d6
[00012800] 8d59                      or.w      d6,(a1)+
[00012802] 3801                      move.w    d1,d4
[00012804] 6b08                      bmi.s     $0001280E
[00012806] 3c18                      move.w    (a0)+,d6
[00012808] 8d59                      or.w      d6,(a1)+
[0001280a] 51cc fffa                 dbf       d4,$00012806
[0001280e] 4ed5                      jmp       (a5)
[00012810] 3c10                      move.w    (a0),d6
[00012812] cc43                      and.w     d3,d6
[00012814] 8d51                      or.w      d6,(a1)
[00012816] d0ca                      adda.w    a2,a0
[00012818] d2cb                      adda.w    a3,a1
[0001281a] 51cd ffe0                 dbf       d5,$000127FC
[0001281e] 4e75                      rts
[00012820] 3c18                      move.w    (a0)+,d6
[00012822] 4ed4                      jmp       (a4)
[00012824] 4846                      swap      d6
[00012826] 3c18                      move.w    (a0)+,d6
[00012828] 3e06                      move.w    d6,d7
[0001282a] 4847                      swap      d7
[0001282c] e0be                      ror.l     d0,d6
[0001282e] cc42                      and.w     d2,d6
[00012830] 8d59                      or.w      d6,(a1)+
[00012832] 4845                      swap      d5
[00012834] 3a01                      move.w    d1,d5
[00012836] 6b2a                      bmi.s     $00012862
[00012838] e24d                      lsr.w     #1,d5
[0001283a] 650e                      bcs.s     $0001284A
[0001283c] 3e18                      move.w    (a0)+,d7
[0001283e] 2c07                      move.l    d7,d6
[00012840] 4847                      swap      d7
[00012842] e0be                      ror.l     d0,d6
[00012844] 8d59                      or.w      d6,(a1)+
[00012846] 5345                      subq.w    #1,d5
[00012848] 6b18                      bmi.s     $00012862
[0001284a] 2c07                      move.l    d7,d6
[0001284c] 2e18                      move.l    (a0)+,d7
[0001284e] 2807                      move.l    d7,d4
[00012850] 4847                      swap      d7
[00012852] 3c07                      move.w    d7,d6
[00012854] e0be                      ror.l     d0,d6
[00012856] e0bc                      ror.l     d0,d4
[00012858] 4846                      swap      d6
[0001285a] 3c04                      move.w    d4,d6
[0001285c] 8d99                      or.l      d6,(a1)+
[0001285e] 51cd ffea                 dbf       d5,$0001284A
[00012862] 4845                      swap      d5
[00012864] 4ed5                      jmp       (a5)
[00012866] 3e10                      move.w    (a0),d7
[00012868] e0bf                      ror.l     d0,d7
[0001286a] ce43                      and.w     d3,d7
[0001286c] 8f51                      or.w      d7,(a1)
[0001286e] d0ca                      adda.w    a2,a0
[00012870] d2cb                      adda.w    a3,a1
[00012872] 51cd ffac                 dbf       d5,$00012820
[00012876] 4e75                      rts
[00012878] 3c18                      move.w    (a0)+,d6
[0001287a] 4ed4                      jmp       (a4)
[0001287c] 4846                      swap      d6
[0001287e] 3c18                      move.w    (a0)+,d6
[00012880] 4846                      swap      d6
[00012882] 2e06                      move.l    d6,d7
[00012884] e1be                      rol.l     d0,d6
[00012886] cc42                      and.w     d2,d6
[00012888] 8d59                      or.w      d6,(a1)+
[0001288a] 4845                      swap      d5
[0001288c] 3a01                      move.w    d1,d5
[0001288e] 6b28                      bmi.s     $000128B8
[00012890] e24d                      lsr.w     #1,d5
[00012892] 650e                      bcs.s     $000128A2
[00012894] 3e18                      move.w    (a0)+,d7
[00012896] 4847                      swap      d7
[00012898] 2c07                      move.l    d7,d6
[0001289a] e1be                      rol.l     d0,d6
[0001289c] 8d59                      or.w      d6,(a1)+
[0001289e] 5345                      subq.w    #1,d5
[000128a0] 6b16                      bmi.s     $000128B8
[000128a2] 2c07                      move.l    d7,d6
[000128a4] 2e18                      move.l    (a0)+,d7
[000128a6] 4847                      swap      d7
[000128a8] 3c07                      move.w    d7,d6
[000128aa] 2807                      move.l    d7,d4
[000128ac] e1be                      rol.l     d0,d6
[000128ae] e1bc                      rol.l     d0,d4
[000128b0] 3c04                      move.w    d4,d6
[000128b2] 8d99                      or.l      d6,(a1)+
[000128b4] 51cd ffec                 dbf       d5,$000128A2
[000128b8] 4845                      swap      d5
[000128ba] 4ed5                      jmp       (a5)
[000128bc] 3e10                      move.w    (a0),d7
[000128be] 4847                      swap      d7
[000128c0] e1bf                      rol.l     d0,d7
[000128c2] ce43                      and.w     d3,d7
[000128c4] 8f51                      or.w      d7,(a1)
[000128c6] d0ca                      adda.w    a2,a0
[000128c8] d2cb                      adda.w    a3,a1
[000128ca] 51cd ffac                 dbf       d5,$00012878
[000128ce] 4e75                      rts
[000128d0] 3c18                      move.w    (a0)+,d6
[000128d2] cc42                      and.w     d2,d6
[000128d4] 8d51                      or.w      d6,(a1)
[000128d6] b559                      eor.w     d2,(a1)+
[000128d8] 3801                      move.w    d1,d4
[000128da] 6b0a                      bmi.s     $000128E6
[000128dc] 3c18                      move.w    (a0)+,d6
[000128de] 8d51                      or.w      d6,(a1)
[000128e0] 4659                      not.w     (a1)+
[000128e2] 51cc fff8                 dbf       d4,$000128DC
[000128e6] 4ed5                      jmp       (a5)
[000128e8] 3c10                      move.w    (a0),d6
[000128ea] cc43                      and.w     d3,d6
[000128ec] 8d51                      or.w      d6,(a1)
[000128ee] b751                      eor.w     d3,(a1)
[000128f0] d0ca                      adda.w    a2,a0
[000128f2] d2cb                      adda.w    a3,a1
[000128f4] 51cd ffda                 dbf       d5,$000128D0
[000128f8] 4e75                      rts
[000128fa] 3c18                      move.w    (a0)+,d6
[000128fc] 4ed4                      jmp       (a4)
[000128fe] 4846                      swap      d6
[00012900] 3c18                      move.w    (a0)+,d6
[00012902] 3e06                      move.w    d6,d7
[00012904] e0be                      ror.l     d0,d6
[00012906] cc42                      and.w     d2,d6
[00012908] 8d51                      or.w      d6,(a1)
[0001290a] b559                      eor.w     d2,(a1)+
[0001290c] 3801                      move.w    d1,d4
[0001290e] 6b10                      bmi.s     $00012920
[00012910] 3c07                      move.w    d7,d6
[00012912] 4846                      swap      d6
[00012914] 3c18                      move.w    (a0)+,d6
[00012916] 3e06                      move.w    d6,d7
[00012918] e0be                      ror.l     d0,d6
[0001291a] 8d59                      or.w      d6,(a1)+
[0001291c] 51cc fff2                 dbf       d4,$00012910
[00012920] 4847                      swap      d7
[00012922] 4ed5                      jmp       (a5)
[00012924] 3e10                      move.w    (a0),d7
[00012926] e0bf                      ror.l     d0,d7
[00012928] ce43                      and.w     d3,d7
[0001292a] 8f51                      or.w      d7,(a1)
[0001292c] b751                      eor.w     d3,(a1)
[0001292e] d0ca                      adda.w    a2,a0
[00012930] d2cb                      adda.w    a3,a1
[00012932] 51cd ffc6                 dbf       d5,$000128FA
[00012936] 4e75                      rts
[00012938] 3c18                      move.w    (a0)+,d6
[0001293a] 4ed4                      jmp       (a4)
[0001293c] 4846                      swap      d6
[0001293e] 3c18                      move.w    (a0)+,d6
[00012940] 4846                      swap      d6
[00012942] 2e06                      move.l    d6,d7
[00012944] e1be                      rol.l     d0,d6
[00012946] cc42                      and.w     d2,d6
[00012948] 8d51                      or.w      d6,(a1)
[0001294a] b559                      eor.w     d2,(a1)+
[0001294c] 3801                      move.w    d1,d4
[0001294e] 6b12                      bmi.s     $00012962
[00012950] 2c07                      move.l    d7,d6
[00012952] 3c18                      move.w    (a0)+,d6
[00012954] 4846                      swap      d6
[00012956] 2e06                      move.l    d6,d7
[00012958] e1be                      rol.l     d0,d6
[0001295a] 8d51                      or.w      d6,(a1)
[0001295c] 4659                      not.w     (a1)+
[0001295e] 51cc fff0                 dbf       d4,$00012950
[00012962] 4ed5                      jmp       (a5)
[00012964] 3e10                      move.w    (a0),d7
[00012966] 4847                      swap      d7
[00012968] e1bf                      rol.l     d0,d7
[0001296a] ce43                      and.w     d3,d7
[0001296c] 8f51                      or.w      d7,(a1)
[0001296e] b751                      eor.w     d3,(a1)
[00012970] d0ca                      adda.w    a2,a0
[00012972] d2cb                      adda.w    a3,a1
[00012974] 51cd ffc2                 dbf       d5,$00012938
[00012978] 4e75                      rts
[0001297a] 3c18                      move.w    (a0)+,d6
[0001297c] 4646                      not.w     d6
[0001297e] cc42                      and.w     d2,d6
[00012980] bd59                      eor.w     d6,(a1)+
[00012982] 3801                      move.w    d1,d4
[00012984] 6b0a                      bmi.s     $00012990
[00012986] 3c18                      move.w    (a0)+,d6
[00012988] 4646                      not.w     d6
[0001298a] bd59                      eor.w     d6,(a1)+
[0001298c] 51cc fff8                 dbf       d4,$00012986
[00012990] 4ed5                      jmp       (a5)
[00012992] 3c10                      move.w    (a0),d6
[00012994] 4646                      not.w     d6
[00012996] cc43                      and.w     d3,d6
[00012998] bd51                      eor.w     d6,(a1)
[0001299a] d0ca                      adda.w    a2,a0
[0001299c] d2cb                      adda.w    a3,a1
[0001299e] 51cd ffda                 dbf       d5,$0001297A
[000129a2] 4e75                      rts
[000129a4] 3c18                      move.w    (a0)+,d6
[000129a6] 4ed4                      jmp       (a4)
[000129a8] 4846                      swap      d6
[000129aa] 3c18                      move.w    (a0)+,d6
[000129ac] 3e06                      move.w    d6,d7
[000129ae] e0be                      ror.l     d0,d6
[000129b0] 4646                      not.w     d6
[000129b2] cc42                      and.w     d2,d6
[000129b4] bd59                      eor.w     d6,(a1)+
[000129b6] 3801                      move.w    d1,d4
[000129b8] 6b12                      bmi.s     $000129CC
[000129ba] 3c07                      move.w    d7,d6
[000129bc] 4846                      swap      d6
[000129be] 3c18                      move.w    (a0)+,d6
[000129c0] 3e06                      move.w    d6,d7
[000129c2] e0be                      ror.l     d0,d6
[000129c4] 4646                      not.w     d6
[000129c6] bd59                      eor.w     d6,(a1)+
[000129c8] 51cc fff0                 dbf       d4,$000129BA
[000129cc] 4847                      swap      d7
[000129ce] 4ed5                      jmp       (a5)
[000129d0] 3e10                      move.w    (a0),d7
[000129d2] e0bf                      ror.l     d0,d7
[000129d4] 4647                      not.w     d7
[000129d6] ce43                      and.w     d3,d7
[000129d8] bf51                      eor.w     d7,(a1)
[000129da] d0ca                      adda.w    a2,a0
[000129dc] d2cb                      adda.w    a3,a1
[000129de] 51cd ffc4                 dbf       d5,$000129A4
[000129e2] 4e75                      rts
[000129e4] 3c18                      move.w    (a0)+,d6
[000129e6] 4ed4                      jmp       (a4)
[000129e8] 4846                      swap      d6
[000129ea] 3c18                      move.w    (a0)+,d6
[000129ec] 4846                      swap      d6
[000129ee] 2e06                      move.l    d6,d7
[000129f0] e1be                      rol.l     d0,d6
[000129f2] 4646                      not.w     d6
[000129f4] cc42                      and.w     d2,d6
[000129f6] bd59                      eor.w     d6,(a1)+
[000129f8] 3801                      move.w    d1,d4
[000129fa] 6b12                      bmi.s     $00012A0E
[000129fc] 2c07                      move.l    d7,d6
[000129fe] 3c18                      move.w    (a0)+,d6
[00012a00] 4846                      swap      d6
[00012a02] 2e06                      move.l    d6,d7
[00012a04] e1be                      rol.l     d0,d6
[00012a06] 4646                      not.w     d6
[00012a08] bd59                      eor.w     d6,(a1)+
[00012a0a] 51cc fff0                 dbf       d4,$000129FC
[00012a0e] 4ed5                      jmp       (a5)
[00012a10] 3e10                      move.w    (a0),d7
[00012a12] 4847                      swap      d7
[00012a14] e1bf                      rol.l     d0,d7
[00012a16] 4647                      not.w     d7
[00012a18] ce43                      and.w     d3,d7
[00012a1a] bf51                      eor.w     d7,(a1)
[00012a1c] d0ca                      adda.w    a2,a0
[00012a1e] d2cb                      adda.w    a3,a1
[00012a20] 51cd ffc2                 dbf       d5,$000129E4
[00012a24] 4e75                      rts
[00012a26] 4bfa 001c                 lea.l     $00012A44(pc),a5
[00012a2a] 4a43                      tst.w     d3
[00012a2c] 6704                      beq.s     $00012A32
[00012a2e] 4bfa 0012                 lea.l     $00012A42(pc),a5
[00012a32] b559                      eor.w     d2,(a1)+
[00012a34] 3801                      move.w    d1,d4
[00012a36] 6b06                      bmi.s     $00012A3E
[00012a38] 4659                      not.w     (a1)+
[00012a3a] 51cc fffc                 dbf       d4,$00012A38
[00012a3e] 4ed5                      jmp       (a5)
[00012a40] 4e71                      nop
[00012a42] b751                      eor.w     d3,(a1)
[00012a44] d0ca                      adda.w    a2,a0
[00012a46] d2cb                      adda.w    a3,a1
[00012a48] 51cd ffe8                 dbf       d5,$00012A32
[00012a4c] 4e75                      rts
[00012a4e] 3c18                      move.w    (a0)+,d6
[00012a50] cc42                      and.w     d2,d6
[00012a52] b551                      eor.w     d2,(a1)
[00012a54] 8d59                      or.w      d6,(a1)+
[00012a56] 3801                      move.w    d1,d4
[00012a58] 6b0a                      bmi.s     $00012A64
[00012a5a] 3c18                      move.w    (a0)+,d6
[00012a5c] 4651                      not.w     (a1)
[00012a5e] 8d59                      or.w      d6,(a1)+
[00012a60] 51cc fff8                 dbf       d4,$00012A5A
[00012a64] 4ed5                      jmp       (a5)
[00012a66] 3c10                      move.w    (a0),d6
[00012a68] cc43                      and.w     d3,d6
[00012a6a] b751                      eor.w     d3,(a1)
[00012a6c] 8d51                      or.w      d6,(a1)
[00012a6e] d0ca                      adda.w    a2,a0
[00012a70] d2cb                      adda.w    a3,a1
[00012a72] 51cd ffda                 dbf       d5,$00012A4E
[00012a76] 4e75                      rts
[00012a78] 3c18                      move.w    (a0)+,d6
[00012a7a] 4ed4                      jmp       (a4)
[00012a7c] 4846                      swap      d6
[00012a7e] 3c18                      move.w    (a0)+,d6
[00012a80] 3e06                      move.w    d6,d7
[00012a82] e0be                      ror.l     d0,d6
[00012a84] cc42                      and.w     d2,d6
[00012a86] b551                      eor.w     d2,(a1)
[00012a88] 8d59                      or.w      d6,(a1)+
[00012a8a] 3801                      move.w    d1,d4
[00012a8c] 6b12                      bmi.s     $00012AA0
[00012a8e] 3c07                      move.w    d7,d6
[00012a90] 4846                      swap      d6
[00012a92] 3c18                      move.w    (a0)+,d6
[00012a94] 3e06                      move.w    d6,d7
[00012a96] e0be                      ror.l     d0,d6
[00012a98] 4651                      not.w     (a1)
[00012a9a] 8d59                      or.w      d6,(a1)+
[00012a9c] 51cc fff0                 dbf       d4,$00012A8E
[00012aa0] 4847                      swap      d7
[00012aa2] 4ed5                      jmp       (a5)
[00012aa4] 3e10                      move.w    (a0),d7
[00012aa6] e0bf                      ror.l     d0,d7
[00012aa8] ce43                      and.w     d3,d7
[00012aaa] b751                      eor.w     d3,(a1)
[00012aac] 8f51                      or.w      d7,(a1)
[00012aae] d0ca                      adda.w    a2,a0
[00012ab0] d2cb                      adda.w    a3,a1
[00012ab2] 51cd ffc4                 dbf       d5,$00012A78
[00012ab6] 4e75                      rts
[00012ab8] 3c18                      move.w    (a0)+,d6
[00012aba] 4ed4                      jmp       (a4)
[00012abc] 4846                      swap      d6
[00012abe] 3c18                      move.w    (a0)+,d6
[00012ac0] 4846                      swap      d6
[00012ac2] 2e06                      move.l    d6,d7
[00012ac4] e1be                      rol.l     d0,d6
[00012ac6] cc42                      and.w     d2,d6
[00012ac8] b551                      eor.w     d2,(a1)
[00012aca] 8d59                      or.w      d6,(a1)+
[00012acc] 3801                      move.w    d1,d4
[00012ace] 6b12                      bmi.s     $00012AE2
[00012ad0] 2c07                      move.l    d7,d6
[00012ad2] 3c18                      move.w    (a0)+,d6
[00012ad4] 4846                      swap      d6
[00012ad6] 2e06                      move.l    d6,d7
[00012ad8] e1be                      rol.l     d0,d6
[00012ada] 4651                      not.w     (a1)
[00012adc] 8d59                      or.w      d6,(a1)+
[00012ade] 51cc fff0                 dbf       d4,$00012AD0
[00012ae2] 4ed5                      jmp       (a5)
[00012ae4] 3e10                      move.w    (a0),d7
[00012ae6] 4847                      swap      d7
[00012ae8] e1bf                      rol.l     d0,d7
[00012aea] ce43                      and.w     d3,d7
[00012aec] b751                      eor.w     d3,(a1)
[00012aee] 8f51                      or.w      d7,(a1)
[00012af0] d0ca                      adda.w    a2,a0
[00012af2] d2cb                      adda.w    a3,a1
[00012af4] 51cd ffc2                 dbf       d5,$00012AB8
[00012af8] 4e75                      rts
[00012afa] 3c18                      move.w    (a0)+,d6
[00012afc] 4646                      not.w     d6
[00012afe] cc42                      and.w     d2,d6
[00012b00] 4642                      not.w     d2
[00012b02] c551                      and.w     d2,(a1)
[00012b04] 4642                      not.w     d2
[00012b06] 8d59                      or.w      d6,(a1)+
[00012b08] 3801                      move.w    d1,d4
[00012b0a] 6b0a                      bmi.s     $00012B16
[00012b0c] 3c18                      move.w    (a0)+,d6
[00012b0e] 4646                      not.w     d6
[00012b10] 32c6                      move.w    d6,(a1)+
[00012b12] 51cc fff8                 dbf       d4,$00012B0C
[00012b16] 4ed5                      jmp       (a5)
[00012b18] 3c10                      move.w    (a0),d6
[00012b1a] 4646                      not.w     d6
[00012b1c] cc43                      and.w     d3,d6
[00012b1e] 4643                      not.w     d3
[00012b20] c751                      and.w     d3,(a1)
[00012b22] 4643                      not.w     d3
[00012b24] 8d51                      or.w      d6,(a1)
[00012b26] d0ca                      adda.w    a2,a0
[00012b28] d2cb                      adda.w    a3,a1
[00012b2a] 51cd ffce                 dbf       d5,$00012AFA
[00012b2e] 4e75                      rts
[00012b30] 3c18                      move.w    (a0)+,d6
[00012b32] 4ed4                      jmp       (a4)
[00012b34] 4846                      swap      d6
[00012b36] 3c18                      move.w    (a0)+,d6
[00012b38] 3e06                      move.w    d6,d7
[00012b3a] e0be                      ror.l     d0,d6
[00012b3c] 4646                      not.w     d6
[00012b3e] cc42                      and.w     d2,d6
[00012b40] 4642                      not.w     d2
[00012b42] c551                      and.w     d2,(a1)
[00012b44] 4642                      not.w     d2
[00012b46] 8d59                      or.w      d6,(a1)+
[00012b48] 3801                      move.w    d1,d4
[00012b4a] 6b12                      bmi.s     $00012B5E
[00012b4c] 3c07                      move.w    d7,d6
[00012b4e] 4846                      swap      d6
[00012b50] 3c18                      move.w    (a0)+,d6
[00012b52] 3e06                      move.w    d6,d7
[00012b54] e0be                      ror.l     d0,d6
[00012b56] 4646                      not.w     d6
[00012b58] 32c6                      move.w    d6,(a1)+
[00012b5a] 51cc fff0                 dbf       d4,$00012B4C
[00012b5e] 4847                      swap      d7
[00012b60] 4ed5                      jmp       (a5)
[00012b62] 3e10                      move.w    (a0),d7
[00012b64] e0bf                      ror.l     d0,d7
[00012b66] 4647                      not.w     d7
[00012b68] ce43                      and.w     d3,d7
[00012b6a] 4643                      not.w     d3
[00012b6c] c751                      and.w     d3,(a1)
[00012b6e] 4643                      not.w     d3
[00012b70] 8f51                      or.w      d7,(a1)
[00012b72] d0ca                      adda.w    a2,a0
[00012b74] d2cb                      adda.w    a3,a1
[00012b76] 51cd ffb8                 dbf       d5,$00012B30
[00012b7a] 4e75                      rts
[00012b7c] 3c18                      move.w    (a0)+,d6
[00012b7e] 4ed4                      jmp       (a4)
[00012b80] 4846                      swap      d6
[00012b82] 3c18                      move.w    (a0)+,d6
[00012b84] 4846                      swap      d6
[00012b86] 2e06                      move.l    d6,d7
[00012b88] e1be                      rol.l     d0,d6
[00012b8a] 4646                      not.w     d6
[00012b8c] cc42                      and.w     d2,d6
[00012b8e] 4642                      not.w     d2
[00012b90] c551                      and.w     d2,(a1)
[00012b92] 4642                      not.w     d2
[00012b94] 8d59                      or.w      d6,(a1)+
[00012b96] 3801                      move.w    d1,d4
[00012b98] 6b12                      bmi.s     $00012BAC
[00012b9a] 2c07                      move.l    d7,d6
[00012b9c] 3c18                      move.w    (a0)+,d6
[00012b9e] 4846                      swap      d6
[00012ba0] 2e06                      move.l    d6,d7
[00012ba2] e1be                      rol.l     d0,d6
[00012ba4] 4646                      not.w     d6
[00012ba6] 32c6                      move.w    d6,(a1)+
[00012ba8] 51cc fff0                 dbf       d4,$00012B9A
[00012bac] 4ed5                      jmp       (a5)
[00012bae] 3e10                      move.w    (a0),d7
[00012bb0] 4847                      swap      d7
[00012bb2] e1bf                      rol.l     d0,d7
[00012bb4] 4647                      not.w     d7
[00012bb6] ce43                      and.w     d3,d7
[00012bb8] 4643                      not.w     d3
[00012bba] c751                      and.w     d3,(a1)
[00012bbc] 4643                      not.w     d3
[00012bbe] 8f51                      or.w      d7,(a1)
[00012bc0] d0ca                      adda.w    a2,a0
[00012bc2] d2cb                      adda.w    a3,a1
[00012bc4] 51cd ffb6                 dbf       d5,$00012B7C
[00012bc8] 4e75                      rts
[00012bca] 3c18                      move.w    (a0)+,d6
[00012bcc] 4646                      not.w     d6
[00012bce] cc42                      and.w     d2,d6
[00012bd0] 8d59                      or.w      d6,(a1)+
[00012bd2] 3801                      move.w    d1,d4
[00012bd4] 6b0a                      bmi.s     $00012BE0
[00012bd6] 3c18                      move.w    (a0)+,d6
[00012bd8] 4646                      not.w     d6
[00012bda] 8d59                      or.w      d6,(a1)+
[00012bdc] 51cc fff8                 dbf       d4,$00012BD6
[00012be0] 4ed5                      jmp       (a5)
[00012be2] 3c10                      move.w    (a0),d6
[00012be4] 4646                      not.w     d6
[00012be6] cc43                      and.w     d3,d6
[00012be8] 8d51                      or.w      d6,(a1)
[00012bea] d0ca                      adda.w    a2,a0
[00012bec] d2cb                      adda.w    a3,a1
[00012bee] 51cd ffda                 dbf       d5,$00012BCA
[00012bf2] 4e75                      rts
[00012bf4] 3c18                      move.w    (a0)+,d6
[00012bf6] 4ed4                      jmp       (a4)
[00012bf8] 4846                      swap      d6
[00012bfa] 3c18                      move.w    (a0)+,d6
[00012bfc] 3e06                      move.w    d6,d7
[00012bfe] e0be                      ror.l     d0,d6
[00012c00] 4646                      not.w     d6
[00012c02] cc42                      and.w     d2,d6
[00012c04] 8d59                      or.w      d6,(a1)+
[00012c06] 3801                      move.w    d1,d4
[00012c08] 6b12                      bmi.s     $00012C1C
[00012c0a] 3c07                      move.w    d7,d6
[00012c0c] 4846                      swap      d6
[00012c0e] 3c18                      move.w    (a0)+,d6
[00012c10] 3e06                      move.w    d6,d7
[00012c12] e0be                      ror.l     d0,d6
[00012c14] 4646                      not.w     d6
[00012c16] 8d59                      or.w      d6,(a1)+
[00012c18] 51cc fff0                 dbf       d4,$00012C0A
[00012c1c] 4847                      swap      d7
[00012c1e] 4ed5                      jmp       (a5)
[00012c20] 3e10                      move.w    (a0),d7
[00012c22] e0bf                      ror.l     d0,d7
[00012c24] 4647                      not.w     d7
[00012c26] ce43                      and.w     d3,d7
[00012c28] 8f51                      or.w      d7,(a1)
[00012c2a] d0ca                      adda.w    a2,a0
[00012c2c] d2cb                      adda.w    a3,a1
[00012c2e] 51cd ffc4                 dbf       d5,$00012BF4
[00012c32] 4e75                      rts
[00012c34] 3c18                      move.w    (a0)+,d6
[00012c36] 4ed4                      jmp       (a4)
[00012c38] 4846                      swap      d6
[00012c3a] 3c18                      move.w    (a0)+,d6
[00012c3c] 4846                      swap      d6
[00012c3e] 2e06                      move.l    d6,d7
[00012c40] e1be                      rol.l     d0,d6
[00012c42] 4646                      not.w     d6
[00012c44] cc42                      and.w     d2,d6
[00012c46] 8d59                      or.w      d6,(a1)+
[00012c48] 3801                      move.w    d1,d4
[00012c4a] 6b12                      bmi.s     $00012C5E
[00012c4c] 2c07                      move.l    d7,d6
[00012c4e] 3c18                      move.w    (a0)+,d6
[00012c50] 4846                      swap      d6
[00012c52] 2e06                      move.l    d6,d7
[00012c54] e1be                      rol.l     d0,d6
[00012c56] 4646                      not.w     d6
[00012c58] 8d59                      or.w      d6,(a1)+
[00012c5a] 51cc fff0                 dbf       d4,$00012C4C
[00012c5e] 4ed5                      jmp       (a5)
[00012c60] 3e10                      move.w    (a0),d7
[00012c62] 4847                      swap      d7
[00012c64] e1bf                      rol.l     d0,d7
[00012c66] 4647                      not.w     d7
[00012c68] ce43                      and.w     d3,d7
[00012c6a] 8f51                      or.w      d7,(a1)
[00012c6c] d0ca                      adda.w    a2,a0
[00012c6e] d2cb                      adda.w    a3,a1
[00012c70] 51cd ffc2                 dbf       d5,$00012C34
[00012c74] 4e75                      rts
[00012c76] 3c18                      move.w    (a0)+,d6
[00012c78] 8c42                      or.w      d2,d6
[00012c7a] cd51                      and.w     d6,(a1)
[00012c7c] 8559                      or.w      d2,(a1)+
[00012c7e] 3801                      move.w    d1,d4
[00012c80] 6b0a                      bmi.s     $00012C8C
[00012c82] 3c18                      move.w    (a0)+,d6
[00012c84] cd51                      and.w     d6,(a1)
[00012c86] 4659                      not.w     (a1)+
[00012c88] 51cc fff8                 dbf       d4,$00012C82
[00012c8c] 4ed5                      jmp       (a5)
[00012c8e] 3c10                      move.w    (a0),d6
[00012c90] 8c43                      or.w      d3,d6
[00012c92] cd51                      and.w     d6,(a1)
[00012c94] b751                      eor.w     d3,(a1)
[00012c96] d0ca                      adda.w    a2,a0
[00012c98] d2cb                      adda.w    a3,a1
[00012c9a] 51cd ffda                 dbf       d5,$00012C76
[00012c9e] 4e75                      rts
[00012ca0] 3c18                      move.w    (a0)+,d6
[00012ca2] 4ed4                      jmp       (a4)
[00012ca4] 4846                      swap      d6
[00012ca6] 3c18                      move.w    (a0)+,d6
[00012ca8] 3e06                      move.w    d6,d7
[00012caa] e0be                      ror.l     d0,d6
[00012cac] 8c42                      or.w      d2,d6
[00012cae] cd51                      and.w     d6,(a1)
[00012cb0] 8559                      or.w      d2,(a1)+
[00012cb2] 3801                      move.w    d1,d4
[00012cb4] 6b12                      bmi.s     $00012CC8
[00012cb6] 3c07                      move.w    d7,d6
[00012cb8] 4846                      swap      d6
[00012cba] 3c18                      move.w    (a0)+,d6
[00012cbc] 3e06                      move.w    d6,d7
[00012cbe] e0be                      ror.l     d0,d6
[00012cc0] cd51                      and.w     d6,(a1)
[00012cc2] 4659                      not.w     (a1)+
[00012cc4] 51cc fff0                 dbf       d4,$00012CB6
[00012cc8] 4847                      swap      d7
[00012cca] 4ed5                      jmp       (a5)
[00012ccc] 3e10                      move.w    (a0),d7
[00012cce] e0bf                      ror.l     d0,d7
[00012cd0] 8e43                      or.w      d3,d7
[00012cd2] cf51                      and.w     d7,(a1)
[00012cd4] b751                      eor.w     d3,(a1)
[00012cd6] d0ca                      adda.w    a2,a0
[00012cd8] d2cb                      adda.w    a3,a1
[00012cda] 51cd ffc4                 dbf       d5,$00012CA0
[00012cde] 4e75                      rts
[00012ce0] 3c18                      move.w    (a0)+,d6
[00012ce2] 4ed4                      jmp       (a4)
[00012ce4] 4846                      swap      d6
[00012ce6] 3c18                      move.w    (a0)+,d6
[00012ce8] 4846                      swap      d6
[00012cea] 2e06                      move.l    d6,d7
[00012cec] e1be                      rol.l     d0,d6
[00012cee] 8c42                      or.w      d2,d6
[00012cf0] cd51                      and.w     d6,(a1)
[00012cf2] 8559                      or.w      d2,(a1)+
[00012cf4] 3801                      move.w    d1,d4
[00012cf6] 6b12                      bmi.s     $00012D0A
[00012cf8] 2c07                      move.l    d7,d6
[00012cfa] 3c18                      move.w    (a0)+,d6
[00012cfc] 4846                      swap      d6
[00012cfe] 2e06                      move.l    d6,d7
[00012d00] e1be                      rol.l     d0,d6
[00012d02] cd51                      and.w     d6,(a1)
[00012d04] 4659                      not.w     (a1)+
[00012d06] 51cc fff0                 dbf       d4,$00012CF8
[00012d0a] 4ed5                      jmp       (a5)
[00012d0c] 3e10                      move.w    (a0),d7
[00012d0e] 4847                      swap      d7
[00012d10] e1bf                      rol.l     d0,d7
[00012d12] 8e43                      or.w      d3,d7
[00012d14] cf51                      and.w     d7,(a1)
[00012d16] b751                      eor.w     d3,(a1)
[00012d18] d0ca                      adda.w    a2,a0
[00012d1a] d2cb                      adda.w    a3,a1
[00012d1c] 51cd ffc2                 dbf       d5,$00012CE0
[00012d20] 4e75                      rts
[00012d22] 7eff                      moveq.l   #-1,d7
[00012d24] 4bfa 0018                 lea.l     $00012D3E(pc),a5
[00012d28] 4a43                      tst.w     d3
[00012d2a] 6604                      bne.s     $00012D30
[00012d2c] 4bfa 0012                 lea.l     $00012D40(pc),a5
[00012d30] 8559                      or.w      d2,(a1)+
[00012d32] 3801                      move.w    d1,d4
[00012d34] 6b06                      bmi.s     $00012D3C
[00012d36] 32c7                      move.w    d7,(a1)+
[00012d38] 51cc fffc                 dbf       d4,$00012D36
[00012d3c] 4ed5                      jmp       (a5)
[00012d3e] 8751                      or.w      d3,(a1)
[00012d40] d2cb                      adda.w    a3,a1
[00012d42] 51cd ffec                 dbf       d5,$00012D30
[00012d46] 4e75                      rts
[00012d48] 204c                      movea.l   a4,a0
[00012d4a] 224d                      movea.l   a5,a1
[00012d4c] 3a47                      movea.w   d7,a5
[00012d4e] 3c0a                      move.w    a2,d6
[00012d50] d245                      add.w     d5,d1
[00012d52] ccc1                      mulu.w    d1,d6
[00012d54] d1c6                      adda.l    d6,a0
[00012d56] 3c00                      move.w    d0,d6
[00012d58] dc44                      add.w     d4,d6
[00012d5a] e84e                      lsr.w     #4,d6
[00012d5c] dc46                      add.w     d6,d6
[00012d5e] d0c6                      adda.w    d6,a0
[00012d60] 3c0b                      move.w    a3,d6
[00012d62] d645                      add.w     d5,d3
[00012d64] ccc3                      mulu.w    d3,d6
[00012d66] d3c6                      adda.l    d6,a1
[00012d68] 3c02                      move.w    d2,d6
[00012d6a] dc44                      add.w     d4,d6
[00012d6c] e84e                      lsr.w     #4,d6
[00012d6e] dc46                      add.w     d6,d6
[00012d70] d2c6                      adda.w    d6,a1
[00012d72] 7c0f                      moveq.l   #15,d6
[00012d74] 3e00                      move.w    d0,d7
[00012d76] ce46                      and.w     d6,d7
[00012d78] de44                      add.w     d4,d7
[00012d7a] e84f                      lsr.w     #4,d7
[00012d7c] 3602                      move.w    d2,d3
[00012d7e] d644                      add.w     d4,d3
[00012d80] d044                      add.w     d4,d0
[00012d82] c046                      and.w     d6,d0
[00012d84] c646                      and.w     d6,d3
[00012d86] 9043                      sub.w     d3,d0
[00012d88] 3202                      move.w    d2,d1
[00012d8a] c246                      and.w     d6,d1
[00012d8c] d244                      add.w     d4,d1
[00012d8e] e849                      lsr.w     #4,d1
[00012d90] 9e41                      sub.w     d1,d7
[00012d92] d842                      add.w     d2,d4
[00012d94] 4644                      not.w     d4
[00012d96] c846                      and.w     d6,d4
[00012d98] 76ff                      moveq.l   #-1,d3
[00012d9a] e96b                      lsl.w     d4,d3
[00012d9c] cc42                      and.w     d2,d6
[00012d9e] 74ff                      moveq.l   #-1,d2
[00012da0] ec6a                      lsr.w     d6,d2
[00012da2] 3801                      move.w    d1,d4
[00012da4] d844                      add.w     d4,d4
[00012da6] 94c4                      suba.w    d4,a2
[00012da8] 96c4                      suba.w    d4,a3
[00012daa] 3807                      move.w    d7,d4
[00012dac] 7c04                      moveq.l   #4,d6
[00012dae] 7e00                      moveq.l   #0,d7
[00012db0] 49fa 007c                 lea.l     $00012E2E(pc),a4
[00012db4] 4a40                      tst.w     d0
[00012db6] 6750                      beq.s     $00012E08
[00012db8] 6d20                      blt.s     $00012DDA
[00012dba] 49fa 00f2                 lea.l     $00012EAE(pc),a4
[00012dbe] 7c08                      moveq.l   #8,d6
[00012dc0] 4a44                      tst.w     d4
[00012dc2] 6a04                      bpl.s     $00012DC8
[00012dc4] 7e02                      moveq.l   #2,d7
[00012dc6] 544a                      addq.w    #2,a2
[00012dc8] 0c40 0008                 cmpi.w    #$0008,d0
[00012dcc] 6f3a                      ble.s     $00012E08
[00012dce] 49fa 015e                 lea.l     $00012F2E(pc),a4
[00012dd2] 5340                      subq.w    #1,d0
[00012dd4] 0a40 000f                 eori.w    #$000F,d0
[00012dd8] 602e                      bra.s     $00012E08
[00012dda] 49fa 0152                 lea.l     $00012F2E(pc),a4
[00012dde] 4440                      neg.w     d0
[00012de0] 4a41                      tst.w     d1
[00012de2] 6608                      bne.s     $00012DEC
[00012de4] 4a44                      tst.w     d4
[00012de6] 6604                      bne.s     $00012DEC
[00012de8] 7c0a                      moveq.l   #10,d6
[00012dea] 601c                      bra.s     $00012E08
[00012dec] 7c04                      moveq.l   #4,d6
[00012dee] 554a                      subq.w    #2,a2
[00012df0] 4a44                      tst.w     d4
[00012df2] 6e04                      bgt.s     $00012DF8
[00012df4] 7e02                      moveq.l   #2,d7
[00012df6] 544a                      addq.w    #2,a2
[00012df8] 0c40 0008                 cmpi.w    #$0008,d0
[00012dfc] 6f0a                      ble.s     $00012E08
[00012dfe] 49fa 00ae                 lea.l     $00012EAE(pc),a4
[00012e02] 5340                      subq.w    #1,d0
[00012e04] 0a40 000f                 eori.w    #$000F,d0
[00012e08] dbcc                      adda.l    a4,a5
[00012e0a] 381d                      move.w    (a5)+,d4
[00012e0c] dc44                      add.w     d4,d6
[00012e0e] de5d                      add.w     (a5)+,d7
[00012e10] 4a41                      tst.w     d1
[00012e12] 6608                      bne.s     $00012E1C
[00012e14] c642                      and.w     d2,d3
[00012e16] 7400                      moveq.l   #0,d2
[00012e18] 7200                      moveq.l   #0,d1
[00012e1a] 3e15                      move.w    (a5),d7
[00012e1c] 5541                      subq.w    #2,d1
[00012e1e] 49fa 000e                 lea.l     $00012E2E(pc),a4
[00012e22] 4bfa 000a                 lea.l     $00012E2E(pc),a5
[00012e26] d8c6                      adda.w    d6,a4
[00012e28] dac7                      adda.w    d7,a5
[00012e2a] 4efb 4002                 jmp       $00012E2E(pc,d4.w)
[00012e2e] 0180                      bclr      d0,d0
[00012e30] 01a2                      bclr      d0,-(a2)
[00012e32] 01a4                      bclr      d0,-(a4)
[00012e34] 0000 01b0                 ori.b     #$B0,d0
[00012e38] 01c8 01d2                 movep.l   d0,466(a0)
[00012e3c] 0000 0262                 ori.b     #$62,d0
[00012e40] 027e 028a                 andi.w    #$028A,???
[00012e44] 0000 0326                 ori.b     #$26,d0
[00012e48] 0000 0000                 ori.b     #$00,d0
[00012e4c] 0000 046c                 ori.b     #$6C,d0
[00012e50] 0484 048c 0000            subi.l    #$048C0000,d4
[00012e56] 0518                      btst      d2,(a0)+
[00012e58] 0518                      btst      d2,(a0)+
[00012e5a] 0518                      btst      d2,(a0)+
[00012e5c] 0000 051a                 ori.b     #$1A,d0
[00012e60] 052e 0534                 btst      d2,1332(a6)
[00012e64] 0000 05b4                 ori.b     #$B4,d0
[00012e68] 05c8 05ce                 movep.l   d2,1486(a0)
[00012e6c] 0000 064e                 ori.b     #$4E,d0
[00012e70] 0666 066e                 addi.w    #$066E,-(a6)
[00012e74] 0000 06fa                 ori.b     #$FA,d0
[00012e78] 0712                      btst      d3,(a2)
[00012e7a] 071a                      btst      d3,(a2)+
[00012e7c] 0000 07a6                 ori.b     #$A6,d0
[00012e80] 07c2                      bset      d3,d2
[00012e82] 07c4                      bset      d3,d4
[00012e84] 0000 07ce                 ori.b     #$CE,d0
[00012e88] 07e6                      bset      d3,-(a6)
[00012e8a] 07ee 0000                 bset      d3,0(a6)
[00012e8e] 087a 0898 08a6            bchg      #2200,$00013736(pc) ; apollo only
[00012e94] 0000 094a                 ori.b     #$4A,d0
[00012e98] 0962                      bchg      d4,-(a2)
[00012e9a] 096a 0000                 bchg      d4,0(a2)
[00012e9e] 09f6 0a0e                 bset      d4,14(a6,d0.l*2) ; 68020+ only
[00012ea2] 0a16 0000                 eori.b    #$00,(a6)
[00012ea6] 0aa2 0abe 0ac0            eori.l    #$0ABE0AC0,-(a2)
[00012eac] 0000 0180                 ori.b     #$80,d0
[00012eb0] 01a2                      bclr      d0,-(a2)
[00012eb2] 01a4                      bclr      d0,-(a4)
[00012eb4] 0000 0220                 ori.b     #$20,d0
[00012eb8] 024c 0258                 andi.w    #$0258,a4 ; apollo only
[00012ebc] 0000 02de                 ori.b     #$DE,d0
[00012ec0] 030e 031c                 movep.w   796(a6),d1
[00012ec4] 0000 042a                 ori.b     #$2A,d0
[00012ec8] 0456 0462                 subi.w    #$0462,(a6)
[00012ecc] 0000 04d8                 ori.b     #$D8,d0
[00012ed0] 0504                      btst      d2,d4
[00012ed2] 050e 0000                 movep.w   0(a6),d2
[00012ed6] 0518                      btst      d2,(a0)+
[00012ed8] 0518                      btst      d2,(a0)+
[00012eda] 0518                      btst      d2,(a0)+
[00012edc] 0000 057a                 ori.b     #$7A,d0
[00012ee0] 05a2                      bclr      d2,-(a2)
[00012ee2] 05aa 0000                 bclr      d2,0(a2)
[00012ee6] 0614 063c                 addi.b    #$3C,(a4)
[00012eea] 0644 0000                 addi.w    #$0000,d4
[00012eee] 06ba 06e6 06f0 0000       addi.l    #$06E606F0,$00012EF0(pc) ; apollo only
[00012ef6] 0766                      bchg      d3,-(a6)
[00012ef8] 0792                      bclr      d3,(a2)
[00012efa] 079c                      bclr      d3,(a4)+
[00012efc] 0000 07a6                 ori.b     #$A6,d0
[00012f00] 07c2                      bset      d3,d2
[00012f02] 07c4                      bset      d3,d4
[00012f04] 0000 083a                 ori.b     #$3A,d0
[00012f08] 0866 0870                 bchg      #2160,-(a6)
[00012f0c] 0000 08fe                 ori.b     #$FE,d0
[00012f10] 0930 0940                 btst      d4,(a0) ; 68020+ only; reserved BD=0
[00012f14] 0000 09b6                 ori.b     #$B6,d0
[00012f18] 09e2                      bset      d4,-(a2)
[00012f1a] 09ec 0000                 bset      d4,0(a4)
[00012f1e] 0a62 0a8e                 eori.w    #$0A8E,-(a2)
[00012f22] 0a98 0000 0aa2            eori.l    #$00000AA2,(a0)+
[00012f28] 0abe 0ac0 0000            eori.l    #$0AC00000,???
[00012f2e] 0180                      bclr      d0,d0
[00012f30] 01a2                      bclr      d0,-(a2)
[00012f32] 01a4                      bclr      d0,-(a4)
[00012f34] 0000 01dc                 ori.b     #$DC,d0
[00012f38] 0208 0216                 andi.b    #$16,a0 ; apollo only
[00012f3c] 0000 0294                 ori.b     #$94,d0
[00012f40] 02c4                      byterev.l d4 ; ColdFire isa_c only
[00012f42] 02d4 0000                 cmp2.w    (a4),d0 ; 68020+ only
[00012f46] 03e6                      bset      d1,-(a6)
[00012f48] 0412 0420                 subi.b    #$20,(a2)
[00012f4c] 0000 0496                 ori.b     #$96,d0
[00012f50] 04c2                      ff1.l     d2 ; ColdFire isa_c only
[00012f52] 04ce                      dc.w      $04CE ; illegal
[00012f54] 0000 0518                 ori.b     #$18,d0
[00012f58] 0518                      btst      d2,(a0)+
[00012f5a] 0518                      btst      d2,(a0)+
[00012f5c] 0000 053e                 ori.b     #$3E,d0
[00012f60] 0566                      bchg      d2,-(a6)
[00012f62] 0570 0000                 bchg      d2,0(a0,d0.w)
[00012f66] 05d8                      bset      d2,(a0)+
[00012f68] 0600 060a                 addi.b    #$0A,d0
[00012f6c] 0000 0678                 ori.b     #$78,d0
[00012f70] 06a4 06b0 0000            addi.l    #$06B00000,-(a4)
[00012f76] 0724                      btst      d3,-(a4)
[00012f78] 0750                      bchg      d3,(a0)
[00012f7a] 075c                      bchg      d3,(a4)+
[00012f7c] 0000 07a6                 ori.b     #$A6,d0
[00012f80] 07c2                      bset      d3,d2
[00012f82] 07c4                      bset      d3,d4
[00012f84] 0000 07f8                 ori.b     #$F8,d0
[00012f88] 0824 0830                 btst      #2096,-(a4)
[00012f8c] 0000 08b0                 ori.b     #$B0,d0
[00012f90] 08e2 08f4                 bset      #2292,-(a2)
[00012f94] 0000 0974                 ori.b     #$74,d0
[00012f98] 09a0                      bclr      d4,-(a0)
[00012f9a] 09ac 0000                 bclr      d4,0(a4)
[00012f9e] 0a20 0a4c                 eori.b    #$4C,-(a0)
[00012fa2] 0a58 0000                 eori.w    #$0000,(a0)+
[00012fa6] 0aa2 0abe 0ac0            eori.l    #$0ABE0AC0,-(a2)
[00012fac] 0000 4642                 ori.b     #$42,d0
[00012fb0] 4643                      not.w     d3
[00012fb2] 7e00                      moveq.l   #0,d7
[00012fb4] 4bfa 001c                 lea.l     $00012FD2(pc),a5
[00012fb8] b47c ffff                 cmp.w     #$FFFF,d2
[00012fbc] 6704                      beq.s     $00012FC2
[00012fbe] 4bfa 0010                 lea.l     $00012FD0(pc),a5
[00012fc2] c751                      and.w     d3,(a1)
[00012fc4] 3801                      move.w    d1,d4
[00012fc6] 6b06                      bmi.s     $00012FCE
[00012fc8] 3307                      move.w    d7,-(a1)
[00012fca] 51cc fffc                 dbf       d4,$00012FC8
[00012fce] 4ed5                      jmp       (a5)
[00012fd0] c561                      and.w     d2,-(a1)
[00012fd2] 92cb                      suba.w    a3,a1
[00012fd4] 51cd ffec                 dbf       d5,$00012FC2
[00012fd8] 4642                      not.w     d2
[00012fda] 4643                      not.w     d3
[00012fdc] 4e75                      rts
[00012fde] 3c10                      move.w    (a0),d6
[00012fe0] 4643                      not.w     d3
[00012fe2] 8c43                      or.w      d3,d6
[00012fe4] 4643                      not.w     d3
[00012fe6] cd51                      and.w     d6,(a1)
[00012fe8] 3801                      move.w    d1,d4
[00012fea] 6b08                      bmi.s     $00012FF4
[00012fec] 3c20                      move.w    -(a0),d6
[00012fee] cd61                      and.w     d6,-(a1)
[00012ff0] 51cc fffa                 dbf       d4,$00012FEC
[00012ff4] 4ed5                      jmp       (a5)
[00012ff6] 3c20                      move.w    -(a0),d6
[00012ff8] 4642                      not.w     d2
[00012ffa] 8c42                      or.w      d2,d6
[00012ffc] 4642                      not.w     d2
[00012ffe] cd61                      and.w     d6,-(a1)
[00013000] 90ca                      suba.w    a2,a0
[00013002] 92cb                      suba.w    a3,a1
[00013004] 51cd ffd8                 dbf       d5,$00012FDE
[00013008] 4e75                      rts
[0001300a] 3c10                      move.w    (a0),d6
[0001300c] 4ed4                      jmp       (a4)
[0001300e] 4846                      swap      d6
[00013010] 3c20                      move.w    -(a0),d6
[00013012] 4846                      swap      d6
[00013014] 2e06                      move.l    d6,d7
[00013016] e0be                      ror.l     d0,d6
[00013018] 4643                      not.w     d3
[0001301a] 8c43                      or.w      d3,d6
[0001301c] cd51                      and.w     d6,(a1)
[0001301e] 4643                      not.w     d3
[00013020] 3801                      move.w    d1,d4
[00013022] 6b10                      bmi.s     $00013034
[00013024] 2c07                      move.l    d7,d6
[00013026] 3c20                      move.w    -(a0),d6
[00013028] 4846                      swap      d6
[0001302a] 2e06                      move.l    d6,d7
[0001302c] e0be                      ror.l     d0,d6
[0001302e] cd61                      and.w     d6,-(a1)
[00013030] 51cc fff2                 dbf       d4,$00013024
[00013034] 4ed5                      jmp       (a5)
[00013036] 3e20                      move.w    -(a0),d7
[00013038] 4847                      swap      d7
[0001303a] e0bf                      ror.l     d0,d7
[0001303c] 4642                      not.w     d2
[0001303e] 8e42                      or.w      d2,d7
[00013040] 4642                      not.w     d2
[00013042] cf61                      and.w     d7,-(a1)
[00013044] 90ca                      suba.w    a2,a0
[00013046] 92cb                      suba.w    a3,a1
[00013048] 51cd ffc0                 dbf       d5,$0001300A
[0001304c] 4e75                      rts
[0001304e] 3c10                      move.w    (a0),d6
[00013050] 4ed4                      jmp       (a4)
[00013052] 4846                      swap      d6
[00013054] 3c20                      move.w    -(a0),d6
[00013056] 3e06                      move.w    d6,d7
[00013058] e1be                      rol.l     d0,d6
[0001305a] 4643                      not.w     d3
[0001305c] 8c43                      or.w      d3,d6
[0001305e] 4643                      not.w     d3
[00013060] cd51                      and.w     d6,(a1)
[00013062] 3801                      move.w    d1,d4
[00013064] 6b10                      bmi.s     $00013076
[00013066] 3c07                      move.w    d7,d6
[00013068] 4846                      swap      d6
[0001306a] 3c20                      move.w    -(a0),d6
[0001306c] 3e06                      move.w    d6,d7
[0001306e] e1be                      rol.l     d0,d6
[00013070] cd61                      and.w     d6,-(a1)
[00013072] 51cc fff2                 dbf       d4,$00013066
[00013076] 4847                      swap      d7
[00013078] 4ed5                      jmp       (a5)
[0001307a] 3e20                      move.w    -(a0),d7
[0001307c] e1bf                      rol.l     d0,d7
[0001307e] 4642                      not.w     d2
[00013080] 8e42                      or.w      d2,d7
[00013082] 4642                      not.w     d2
[00013084] cf61                      and.w     d7,-(a1)
[00013086] 90ca                      suba.w    a2,a0
[00013088] 92cb                      suba.w    a3,a1
[0001308a] 51cd ffc2                 dbf       d5,$0001304E
[0001308e] 4e75                      rts
[00013090] 3c10                      move.w    (a0),d6
[00013092] b751                      eor.w     d3,(a1)
[00013094] 4643                      not.w     d3
[00013096] 8c43                      or.w      d3,d6
[00013098] 4643                      not.w     d3
[0001309a] cd51                      and.w     d6,(a1)
[0001309c] 3801                      move.w    d1,d4
[0001309e] 6b0a                      bmi.s     $000130AA
[000130a0] 3c20                      move.w    -(a0),d6
[000130a2] 4661                      not.w     -(a1)
[000130a4] cd51                      and.w     d6,(a1)
[000130a6] 51cc fff8                 dbf       d4,$000130A0
[000130aa] 4ed5                      jmp       (a5)
[000130ac] 3c20                      move.w    -(a0),d6
[000130ae] b561                      eor.w     d2,-(a1)
[000130b0] 4642                      not.w     d2
[000130b2] 8c42                      or.w      d2,d6
[000130b4] 4642                      not.w     d2
[000130b6] cd51                      and.w     d6,(a1)
[000130b8] 90ca                      suba.w    a2,a0
[000130ba] 92cb                      suba.w    a3,a1
[000130bc] 51cd ffd2                 dbf       d5,$00013090
[000130c0] 4e75                      rts
[000130c2] 3c10                      move.w    (a0),d6
[000130c4] 4ed4                      jmp       (a4)
[000130c6] 4846                      swap      d6
[000130c8] 3c20                      move.w    -(a0),d6
[000130ca] 4846                      swap      d6
[000130cc] 2e06                      move.l    d6,d7
[000130ce] e0be                      ror.l     d0,d6
[000130d0] b751                      eor.w     d3,(a1)
[000130d2] 4643                      not.w     d3
[000130d4] 8c43                      or.w      d3,d6
[000130d6] 4643                      not.w     d3
[000130d8] cd51                      and.w     d6,(a1)
[000130da] 3801                      move.w    d1,d4
[000130dc] 6b12                      bmi.s     $000130F0
[000130de] 2c07                      move.l    d7,d6
[000130e0] 3c20                      move.w    -(a0),d6
[000130e2] 4846                      swap      d6
[000130e4] 2e06                      move.l    d6,d7
[000130e6] e0be                      ror.l     d0,d6
[000130e8] 4661                      not.w     -(a1)
[000130ea] cd51                      and.w     d6,(a1)
[000130ec] 51cc fff0                 dbf       d4,$000130DE
[000130f0] 4ed5                      jmp       (a5)
[000130f2] 3e20                      move.w    -(a0),d7
[000130f4] 4847                      swap      d7
[000130f6] e0bf                      ror.l     d0,d7
[000130f8] b561                      eor.w     d2,-(a1)
[000130fa] 4642                      not.w     d2
[000130fc] 8e42                      or.w      d2,d7
[000130fe] 4642                      not.w     d2
[00013100] cf51                      and.w     d7,(a1)
[00013102] 90ca                      suba.w    a2,a0
[00013104] 92cb                      suba.w    a3,a1
[00013106] 51cd ffba                 dbf       d5,$000130C2
[0001310a] 4e75                      rts
[0001310c] 3c10                      move.w    (a0),d6
[0001310e] 4ed4                      jmp       (a4)
[00013110] 4846                      swap      d6
[00013112] 3c20                      move.w    -(a0),d6
[00013114] 3e06                      move.w    d6,d7
[00013116] e1be                      rol.l     d0,d6
[00013118] b751                      eor.w     d3,(a1)
[0001311a] 4643                      not.w     d3
[0001311c] 8c43                      or.w      d3,d6
[0001311e] 4643                      not.w     d3
[00013120] cd51                      and.w     d6,(a1)
[00013122] 3801                      move.w    d1,d4
[00013124] 6b12                      bmi.s     $00013138
[00013126] 3c07                      move.w    d7,d6
[00013128] 4846                      swap      d6
[0001312a] 3c20                      move.w    -(a0),d6
[0001312c] 3e06                      move.w    d6,d7
[0001312e] e1be                      rol.l     d0,d6
[00013130] 4661                      not.w     -(a1)
[00013132] cd51                      and.w     d6,(a1)
[00013134] 51cc fff0                 dbf       d4,$00013126
[00013138] 4847                      swap      d7
[0001313a] 4ed5                      jmp       (a5)
[0001313c] 3e20                      move.w    -(a0),d7
[0001313e] e1bf                      rol.l     d0,d7
[00013140] b561                      eor.w     d2,-(a1)
[00013142] 4642                      not.w     d2
[00013144] 8e42                      or.w      d2,d7
[00013146] 4642                      not.w     d2
[00013148] cf51                      and.w     d7,(a1)
[0001314a] 90ca                      suba.w    a2,a0
[0001314c] 92cb                      suba.w    a3,a1
[0001314e] 51cd ffbc                 dbf       d5,$0001310C
[00013152] 4e75                      rts
[00013154] 3801                      move.w    d1,d4
[00013156] 6b00 0084                 bmi       $000131DC
[0001315a] e24c                      lsr.w     #1,d4
[0001315c] 6522                      bcs.s     $00013180
[0001315e] 49fa 0040                 lea.l     $000131A0(pc),a4
[00013162] 6606                      bne.s     $0001316A
[00013164] 4bfa 0062                 lea.l     $000131C8(pc),a5
[00013168] 6028                      bra.s     $00013192
[0001316a] 5344                      subq.w    #1,d4
[0001316c] 3004                      move.w    d4,d0
[0001316e] e84c                      lsr.w     #4,d4
[00013170] 3204                      move.w    d4,d1
[00013172] 4640                      not.w     d0
[00013174] 0240 000f                 andi.w    #$000F,d0
[00013178] d040                      add.w     d0,d0
[0001317a] 4bfb 0028                 lea.l     $000131A4(pc,d0.w),a5
[0001317e] 6012                      bra.s     $00013192
[00013180] 3004                      move.w    d4,d0
[00013182] e84c                      lsr.w     #4,d4
[00013184] 3204                      move.w    d4,d1
[00013186] 4640                      not.w     d0
[00013188] 0240 000f                 andi.w    #$000F,d0
[0001318c] d040                      add.w     d0,d0
[0001318e] 49fb 0014                 lea.l     $000131A4(pc,d0.w),a4
[00013192] 3c10                      move.w    (a0),d6
[00013194] 4646                      not.w     d6
[00013196] cc43                      and.w     d3,d6
[00013198] 8751                      or.w      d3,(a1)
[0001319a] bd51                      eor.w     d6,(a1)
[0001319c] 3801                      move.w    d1,d4
[0001319e] 4ed4                      jmp       (a4)
[000131a0] 3320                      move.w    -(a0),-(a1)
[000131a2] 4ed5                      jmp       (a5)
[000131a4] 2320                      move.l    -(a0),-(a1)
[000131a6] 2320                      move.l    -(a0),-(a1)
[000131a8] 2320                      move.l    -(a0),-(a1)
[000131aa] 2320                      move.l    -(a0),-(a1)
[000131ac] 2320                      move.l    -(a0),-(a1)
[000131ae] 2320                      move.l    -(a0),-(a1)
[000131b0] 2320                      move.l    -(a0),-(a1)
[000131b2] 2320                      move.l    -(a0),-(a1)
[000131b4] 2320                      move.l    -(a0),-(a1)
[000131b6] 2320                      move.l    -(a0),-(a1)
[000131b8] 2320                      move.l    -(a0),-(a1)
[000131ba] 2320                      move.l    -(a0),-(a1)
[000131bc] 2320                      move.l    -(a0),-(a1)
[000131be] 2320                      move.l    -(a0),-(a1)
[000131c0] 2320                      move.l    -(a0),-(a1)
[000131c2] 2320                      move.l    -(a0),-(a1)
[000131c4] 51cc ffde                 dbf       d4,$000131A4
[000131c8] 3c20                      move.w    -(a0),d6
[000131ca] 4646                      not.w     d6
[000131cc] cc42                      and.w     d2,d6
[000131ce] 8561                      or.w      d2,-(a1)
[000131d0] bd51                      eor.w     d6,(a1)
[000131d2] 90ca                      suba.w    a2,a0
[000131d4] 92cb                      suba.w    a3,a1
[000131d6] 51cd ffba                 dbf       d5,$00013192
[000131da] 4e75                      rts
[000131dc] 4a42                      tst.w     d2
[000131de] 6720                      beq.s     $00013200
[000131e0] 5588                      subq.l    #2,a0
[000131e2] 5589                      subq.l    #2,a1
[000131e4] 4842                      swap      d2
[000131e6] 3403                      move.w    d3,d2
[000131e8] 2602                      move.l    d2,d3
[000131ea] 4683                      not.l     d3
[000131ec] 544a                      addq.w    #2,a2
[000131ee] 544b                      addq.w    #2,a3
[000131f0] 3c0a                      move.w    a2,d6
[000131f2] 4446                      neg.w     d6
[000131f4] 3446                      movea.w   d6,a2
[000131f6] 3c0b                      move.w    a3,d6
[000131f8] 4446                      neg.w     d6
[000131fa] 3646                      movea.w   d6,a3
[000131fc] 6000 f3ce                 bra       $000125CC
[00013200] 3403                      move.w    d3,d2
[00013202] 4643                      not.w     d3
[00013204] 3c0a                      move.w    a2,d6
[00013206] 4446                      neg.w     d6
[00013208] 3446                      movea.w   d6,a2
[0001320a] 3c0b                      move.w    a3,d6
[0001320c] 4446                      neg.w     d6
[0001320e] 3646                      movea.w   d6,a3
[00013210] 6000 f3d0                 bra       $000125E2
[00013214] 3c10                      move.w    (a0),d6
[00013216] 4ed4                      jmp       (a4)
[00013218] 4846                      swap      d6
[0001321a] 3c20                      move.w    -(a0),d6
[0001321c] 4846                      swap      d6
[0001321e] 2e06                      move.l    d6,d7
[00013220] e0be                      ror.l     d0,d6
[00013222] 4646                      not.w     d6
[00013224] cc43                      and.w     d3,d6
[00013226] 8751                      or.w      d3,(a1)
[00013228] bd51                      eor.w     d6,(a1)
[0001322a] 3801                      move.w    d1,d4
[0001322c] 6b10                      bmi.s     $0001323E
[0001322e] 2c07                      move.l    d7,d6
[00013230] 3c20                      move.w    -(a0),d6
[00013232] 4846                      swap      d6
[00013234] 2e06                      move.l    d6,d7
[00013236] e0be                      ror.l     d0,d6
[00013238] 3306                      move.w    d6,-(a1)
[0001323a] 51cc fff2                 dbf       d4,$0001322E
[0001323e] 4ed5                      jmp       (a5)
[00013240] 3e20                      move.w    -(a0),d7
[00013242] 4847                      swap      d7
[00013244] e0bf                      ror.l     d0,d7
[00013246] 4647                      not.w     d7
[00013248] ce42                      and.w     d2,d7
[0001324a] 8561                      or.w      d2,-(a1)
[0001324c] bf51                      eor.w     d7,(a1)
[0001324e] 90ca                      suba.w    a2,a0
[00013250] 92cb                      suba.w    a3,a1
[00013252] 51cd ffc0                 dbf       d5,$00013214
[00013256] 4e75                      rts
[00013258] 3c10                      move.w    (a0),d6
[0001325a] 4ed4                      jmp       (a4)
[0001325c] 4846                      swap      d6
[0001325e] 3c20                      move.w    -(a0),d6
[00013260] 3e06                      move.w    d6,d7
[00013262] e1be                      rol.l     d0,d6
[00013264] 4646                      not.w     d6
[00013266] cc43                      and.w     d3,d6
[00013268] 8751                      or.w      d3,(a1)
[0001326a] bd51                      eor.w     d6,(a1)
[0001326c] 3801                      move.w    d1,d4
[0001326e] 6b10                      bmi.s     $00013280
[00013270] 3c07                      move.w    d7,d6
[00013272] 4846                      swap      d6
[00013274] 3c20                      move.w    -(a0),d6
[00013276] 3e06                      move.w    d6,d7
[00013278] e1be                      rol.l     d0,d6
[0001327a] 3306                      move.w    d6,-(a1)
[0001327c] 51cc fff2                 dbf       d4,$00013270
[00013280] 4847                      swap      d7
[00013282] 4ed5                      jmp       (a5)
[00013284] 3e20                      move.w    -(a0),d7
[00013286] e1bf                      rol.l     d0,d7
[00013288] 4647                      not.w     d7
[0001328a] ce42                      and.w     d2,d7
[0001328c] 8561                      or.w      d2,-(a1)
[0001328e] bf51                      eor.w     d7,(a1)
[00013290] 90ca                      suba.w    a2,a0
[00013292] 92cb                      suba.w    a3,a1
[00013294] 51cd ffc2                 dbf       d5,$00013258
[00013298] 4e75                      rts
[0001329a] 3c10                      move.w    (a0),d6
[0001329c] cc43                      and.w     d3,d6
[0001329e] 4646                      not.w     d6
[000132a0] cd51                      and.w     d6,(a1)
[000132a2] 3801                      move.w    d1,d4
[000132a4] 6b0a                      bmi.s     $000132B0
[000132a6] 3c20                      move.w    -(a0),d6
[000132a8] 4646                      not.w     d6
[000132aa] cd61                      and.w     d6,-(a1)
[000132ac] 51cc fff8                 dbf       d4,$000132A6
[000132b0] 4ed5                      jmp       (a5)
[000132b2] 3c20                      move.w    -(a0),d6
[000132b4] cc42                      and.w     d2,d6
[000132b6] 4646                      not.w     d6
[000132b8] cd61                      and.w     d6,-(a1)
[000132ba] 90ca                      suba.w    a2,a0
[000132bc] 92cb                      suba.w    a3,a1
[000132be] 51cd ffda                 dbf       d5,$0001329A
[000132c2] 4e75                      rts
[000132c4] 3c10                      move.w    (a0),d6
[000132c6] 4ed4                      jmp       (a4)
[000132c8] 4846                      swap      d6
[000132ca] 3c20                      move.w    -(a0),d6
[000132cc] 4846                      swap      d6
[000132ce] 2e06                      move.l    d6,d7
[000132d0] e0be                      ror.l     d0,d6
[000132d2] cc43                      and.w     d3,d6
[000132d4] 4646                      not.w     d6
[000132d6] cd51                      and.w     d6,(a1)
[000132d8] 3801                      move.w    d1,d4
[000132da] 6b12                      bmi.s     $000132EE
[000132dc] 2c07                      move.l    d7,d6
[000132de] 3c20                      move.w    -(a0),d6
[000132e0] 4846                      swap      d6
[000132e2] 2e06                      move.l    d6,d7
[000132e4] e0be                      ror.l     d0,d6
[000132e6] 4646                      not.w     d6
[000132e8] cd61                      and.w     d6,-(a1)
[000132ea] 51cc fff0                 dbf       d4,$000132DC
[000132ee] 4ed5                      jmp       (a5)
[000132f0] 3e20                      move.w    -(a0),d7
[000132f2] 4847                      swap      d7
[000132f4] e0bf                      ror.l     d0,d7
[000132f6] ce42                      and.w     d2,d7
[000132f8] 4647                      not.w     d7
[000132fa] cf61                      and.w     d7,-(a1)
[000132fc] 90ca                      suba.w    a2,a0
[000132fe] 92cb                      suba.w    a3,a1
[00013300] 51cd ffc2                 dbf       d5,$000132C4
[00013304] 4e75                      rts
[00013306] 3c10                      move.w    (a0),d6
[00013308] 4ed4                      jmp       (a4)
[0001330a] 4846                      swap      d6
[0001330c] 3c20                      move.w    -(a0),d6
[0001330e] 3e06                      move.w    d6,d7
[00013310] e1be                      rol.l     d0,d6
[00013312] cc43                      and.w     d3,d6
[00013314] 4646                      not.w     d6
[00013316] cd51                      and.w     d6,(a1)
[00013318] 3801                      move.w    d1,d4
[0001331a] 6b12                      bmi.s     $0001332E
[0001331c] 3c07                      move.w    d7,d6
[0001331e] 4846                      swap      d6
[00013320] 3c20                      move.w    -(a0),d6
[00013322] 3e06                      move.w    d6,d7
[00013324] e1be                      rol.l     d0,d6
[00013326] 4646                      not.w     d6
[00013328] cd61                      and.w     d6,-(a1)
[0001332a] 51cc fff0                 dbf       d4,$0001331C
[0001332e] 4847                      swap      d7
[00013330] 4ed5                      jmp       (a5)
[00013332] 3e20                      move.w    -(a0),d7
[00013334] e1bf                      rol.l     d0,d7
[00013336] ce42                      and.w     d2,d7
[00013338] 4647                      not.w     d7
[0001333a] cf61                      and.w     d7,-(a1)
[0001333c] 90ca                      suba.w    a2,a0
[0001333e] 92cb                      suba.w    a3,a1
[00013340] 51cd ffc4                 dbf       d5,$00013306
[00013344] 4e75                      rts
[00013346] 4e75                      rts
[00013348] 3c10                      move.w    (a0),d6
[0001334a] cc43                      and.w     d3,d6
[0001334c] bd51                      eor.w     d6,(a1)
[0001334e] 3801                      move.w    d1,d4
[00013350] 6b08                      bmi.s     $0001335A
[00013352] 3c20                      move.w    -(a0),d6
[00013354] bd61                      eor.w     d6,-(a1)
[00013356] 51cc fffa                 dbf       d4,$00013352
[0001335a] 4ed5                      jmp       (a5)
[0001335c] 3c20                      move.w    -(a0),d6
[0001335e] cc42                      and.w     d2,d6
[00013360] bd61                      eor.w     d6,-(a1)
[00013362] 90ca                      suba.w    a2,a0
[00013364] 92cb                      suba.w    a3,a1
[00013366] 51cd ffe0                 dbf       d5,$00013348
[0001336a] 4e75                      rts
[0001336c] 3c10                      move.w    (a0),d6
[0001336e] 4ed4                      jmp       (a4)
[00013370] 4846                      swap      d6
[00013372] 3c20                      move.w    -(a0),d6
[00013374] 4846                      swap      d6
[00013376] 2e06                      move.l    d6,d7
[00013378] e0be                      ror.l     d0,d6
[0001337a] cc43                      and.w     d3,d6
[0001337c] bd51                      eor.w     d6,(a1)
[0001337e] 3801                      move.w    d1,d4
[00013380] 6b10                      bmi.s     $00013392
[00013382] 2c07                      move.l    d7,d6
[00013384] 3c20                      move.w    -(a0),d6
[00013386] 4846                      swap      d6
[00013388] 2e06                      move.l    d6,d7
[0001338a] e0be                      ror.l     d0,d6
[0001338c] bd61                      eor.w     d6,-(a1)
[0001338e] 51cc fff2                 dbf       d4,$00013382
[00013392] 4ed5                      jmp       (a5)
[00013394] 3e20                      move.w    -(a0),d7
[00013396] 4847                      swap      d7
[00013398] e0bf                      ror.l     d0,d7
[0001339a] ce42                      and.w     d2,d7
[0001339c] bf61                      eor.w     d7,-(a1)
[0001339e] 90ca                      suba.w    a2,a0
[000133a0] 92cb                      suba.w    a3,a1
[000133a2] 51cd ffc8                 dbf       d5,$0001336C
[000133a6] 4e75                      rts
[000133a8] 3c10                      move.w    (a0),d6
[000133aa] 4ed4                      jmp       (a4)
[000133ac] 4846                      swap      d6
[000133ae] 3c20                      move.w    -(a0),d6
[000133b0] 3e06                      move.w    d6,d7
[000133b2] e1be                      rol.l     d0,d6
[000133b4] cc43                      and.w     d3,d6
[000133b6] bd51                      eor.w     d6,(a1)
[000133b8] 3801                      move.w    d1,d4
[000133ba] 6b10                      bmi.s     $000133CC
[000133bc] 3c07                      move.w    d7,d6
[000133be] 4846                      swap      d6
[000133c0] 3c20                      move.w    -(a0),d6
[000133c2] 3e06                      move.w    d6,d7
[000133c4] e1be                      rol.l     d0,d6
[000133c6] bd61                      eor.w     d6,-(a1)
[000133c8] 51cc fff2                 dbf       d4,$000133BC
[000133cc] 4847                      swap      d7
[000133ce] 4ed5                      jmp       (a5)
[000133d0] 3e20                      move.w    -(a0),d7
[000133d2] e1bf                      rol.l     d0,d7
[000133d4] ce42                      and.w     d2,d7
[000133d6] bf61                      eor.w     d7,-(a1)
[000133d8] 90ca                      suba.w    a2,a0
[000133da] 92cb                      suba.w    a3,a1
[000133dc] 51cd ffca                 dbf       d5,$000133A8
[000133e0] 4e75                      rts
[000133e2] 3c10                      move.w    (a0),d6
[000133e4] cc43                      and.w     d3,d6
[000133e6] 8d51                      or.w      d6,(a1)
[000133e8] 3801                      move.w    d1,d4
[000133ea] 6b08                      bmi.s     $000133F4
[000133ec] 3c20                      move.w    -(a0),d6
[000133ee] 8d61                      or.w      d6,-(a1)
[000133f0] 51cc fffa                 dbf       d4,$000133EC
[000133f4] 4ed5                      jmp       (a5)
[000133f6] 3c20                      move.w    -(a0),d6
[000133f8] cc42                      and.w     d2,d6
[000133fa] 8d61                      or.w      d6,-(a1)
[000133fc] 90ca                      suba.w    a2,a0
[000133fe] 92cb                      suba.w    a3,a1
[00013400] 51cd ffe0                 dbf       d5,$000133E2
[00013404] 4e75                      rts
[00013406] 3c10                      move.w    (a0),d6
[00013408] 4ed4                      jmp       (a4)
[0001340a] 4846                      swap      d6
[0001340c] 3c20                      move.w    -(a0),d6
[0001340e] 4846                      swap      d6
[00013410] 2e06                      move.l    d6,d7
[00013412] e0be                      ror.l     d0,d6
[00013414] cc43                      and.w     d3,d6
[00013416] 8d51                      or.w      d6,(a1)
[00013418] 3801                      move.w    d1,d4
[0001341a] 6b10                      bmi.s     $0001342C
[0001341c] 2c07                      move.l    d7,d6
[0001341e] 3c20                      move.w    -(a0),d6
[00013420] 4846                      swap      d6
[00013422] 2e06                      move.l    d6,d7
[00013424] e0be                      ror.l     d0,d6
[00013426] 8d61                      or.w      d6,-(a1)
[00013428] 51cc fff2                 dbf       d4,$0001341C
[0001342c] 4ed5                      jmp       (a5)
[0001342e] 3e20                      move.w    -(a0),d7
[00013430] 4847                      swap      d7
[00013432] e0bf                      ror.l     d0,d7
[00013434] ce42                      and.w     d2,d7
[00013436] 8f61                      or.w      d7,-(a1)
[00013438] 90ca                      suba.w    a2,a0
[0001343a] 92cb                      suba.w    a3,a1
[0001343c] 51cd ffc8                 dbf       d5,$00013406
[00013440] 4e75                      rts
[00013442] 3c10                      move.w    (a0),d6
[00013444] 4ed4                      jmp       (a4)
[00013446] 4846                      swap      d6
[00013448] 3c20                      move.w    -(a0),d6
[0001344a] 3e06                      move.w    d6,d7
[0001344c] e1be                      rol.l     d0,d6
[0001344e] cc43                      and.w     d3,d6
[00013450] 8d51                      or.w      d6,(a1)
[00013452] 3801                      move.w    d1,d4
[00013454] 6b10                      bmi.s     $00013466
[00013456] 3c07                      move.w    d7,d6
[00013458] 4846                      swap      d6
[0001345a] 3c20                      move.w    -(a0),d6
[0001345c] 3e06                      move.w    d6,d7
[0001345e] e1be                      rol.l     d0,d6
[00013460] 8d61                      or.w      d6,-(a1)
[00013462] 51cc fff2                 dbf       d4,$00013456
[00013466] 4847                      swap      d7
[00013468] 4ed5                      jmp       (a5)
[0001346a] 3e20                      move.w    -(a0),d7
[0001346c] e1bf                      rol.l     d0,d7
[0001346e] ce42                      and.w     d2,d7
[00013470] 8f61                      or.w      d7,-(a1)
[00013472] 90ca                      suba.w    a2,a0
[00013474] 92cb                      suba.w    a3,a1
[00013476] 51cd ffca                 dbf       d5,$00013442
[0001347a] 4e75                      rts
[0001347c] 3c10                      move.w    (a0),d6
[0001347e] cc43                      and.w     d3,d6
[00013480] 8d51                      or.w      d6,(a1)
[00013482] b751                      eor.w     d3,(a1)
[00013484] 3801                      move.w    d1,d4
[00013486] 6b0a                      bmi.s     $00013492
[00013488] 3c20                      move.w    -(a0),d6
[0001348a] 8d61                      or.w      d6,-(a1)
[0001348c] 4651                      not.w     (a1)
[0001348e] 51cc fff8                 dbf       d4,$00013488
[00013492] 4ed5                      jmp       (a5)
[00013494] 3c20                      move.w    -(a0),d6
[00013496] cc42                      and.w     d2,d6
[00013498] 8d61                      or.w      d6,-(a1)
[0001349a] b551                      eor.w     d2,(a1)
[0001349c] 90ca                      suba.w    a2,a0
[0001349e] 92cb                      suba.w    a3,a1
[000134a0] 51cd ffda                 dbf       d5,$0001347C
[000134a4] 4e75                      rts
[000134a6] 3c10                      move.w    (a0),d6
[000134a8] 4ed4                      jmp       (a4)
[000134aa] 4846                      swap      d6
[000134ac] 3c20                      move.w    -(a0),d6
[000134ae] 4846                      swap      d6
[000134b0] 2e06                      move.l    d6,d7
[000134b2] e0be                      ror.l     d0,d6
[000134b4] cc43                      and.w     d3,d6
[000134b6] 8d51                      or.w      d6,(a1)
[000134b8] b751                      eor.w     d3,(a1)
[000134ba] 3801                      move.w    d1,d4
[000134bc] 6b12                      bmi.s     $000134D0
[000134be] 2c07                      move.l    d7,d6
[000134c0] 3c20                      move.w    -(a0),d6
[000134c2] 4846                      swap      d6
[000134c4] 2e06                      move.l    d6,d7
[000134c6] e0be                      ror.l     d0,d6
[000134c8] 8d61                      or.w      d6,-(a1)
[000134ca] 4651                      not.w     (a1)
[000134cc] 51cc fff0                 dbf       d4,$000134BE
[000134d0] 4ed5                      jmp       (a5)
[000134d2] 3e20                      move.w    -(a0),d7
[000134d4] 4847                      swap      d7
[000134d6] e0bf                      ror.l     d0,d7
[000134d8] ce42                      and.w     d2,d7
[000134da] 8f61                      or.w      d7,-(a1)
[000134dc] b551                      eor.w     d2,(a1)
[000134de] 90ca                      suba.w    a2,a0
[000134e0] 92cb                      suba.w    a3,a1
[000134e2] 51cd ffc2                 dbf       d5,$000134A6
[000134e6] 4e75                      rts
[000134e8] 3c10                      move.w    (a0),d6
[000134ea] 4ed4                      jmp       (a4)
[000134ec] 4846                      swap      d6
[000134ee] 3c20                      move.w    -(a0),d6
[000134f0] 3e06                      move.w    d6,d7
[000134f2] e1be                      rol.l     d0,d6
[000134f4] cc43                      and.w     d3,d6
[000134f6] 8d51                      or.w      d6,(a1)
[000134f8] b751                      eor.w     d3,(a1)
[000134fa] 3801                      move.w    d1,d4
[000134fc] 6b12                      bmi.s     $00013510
[000134fe] 3c07                      move.w    d7,d6
[00013500] 4846                      swap      d6
[00013502] 3c20                      move.w    -(a0),d6
[00013504] 3e06                      move.w    d6,d7
[00013506] e1be                      rol.l     d0,d6
[00013508] 8d61                      or.w      d6,-(a1)
[0001350a] 4651                      not.w     (a1)
[0001350c] 51cc fff0                 dbf       d4,$000134FE
[00013510] 4847                      swap      d7
[00013512] 4ed5                      jmp       (a5)
[00013514] 3e20                      move.w    -(a0),d7
[00013516] e1bf                      rol.l     d0,d7
[00013518] ce42                      and.w     d2,d7
[0001351a] 8f61                      or.w      d7,-(a1)
[0001351c] b551                      eor.w     d2,(a1)
[0001351e] 90ca                      suba.w    a2,a0
[00013520] 92cb                      suba.w    a3,a1
[00013522] 51cd ffc4                 dbf       d5,$000134E8
[00013526] 4e75                      rts
[00013528] 3c10                      move.w    (a0),d6
[0001352a] 4646                      not.w     d6
[0001352c] cc43                      and.w     d3,d6
[0001352e] bd51                      eor.w     d6,(a1)
[00013530] 3801                      move.w    d1,d4
[00013532] 6b0a                      bmi.s     $0001353E
[00013534] 3c20                      move.w    -(a0),d6
[00013536] 4646                      not.w     d6
[00013538] bd61                      eor.w     d6,-(a1)
[0001353a] 51cc fff8                 dbf       d4,$00013534
[0001353e] 4ed5                      jmp       (a5)
[00013540] 3c20                      move.w    -(a0),d6
[00013542] 4646                      not.w     d6
[00013544] cc42                      and.w     d2,d6
[00013546] bd61                      eor.w     d6,-(a1)
[00013548] 90ca                      suba.w    a2,a0
[0001354a] 92cb                      suba.w    a3,a1
[0001354c] 51cd ffda                 dbf       d5,$00013528
[00013550] 4e75                      rts
[00013552] 3c10                      move.w    (a0),d6
[00013554] 4ed4                      jmp       (a4)
[00013556] 4846                      swap      d6
[00013558] 3c20                      move.w    -(a0),d6
[0001355a] 4846                      swap      d6
[0001355c] 2e06                      move.l    d6,d7
[0001355e] e0be                      ror.l     d0,d6
[00013560] 4646                      not.w     d6
[00013562] cc43                      and.w     d3,d6
[00013564] bd51                      eor.w     d6,(a1)
[00013566] 3801                      move.w    d1,d4
[00013568] 6b12                      bmi.s     $0001357C
[0001356a] 2c07                      move.l    d7,d6
[0001356c] 3c20                      move.w    -(a0),d6
[0001356e] 4846                      swap      d6
[00013570] 2e06                      move.l    d6,d7
[00013572] e0be                      ror.l     d0,d6
[00013574] 4646                      not.w     d6
[00013576] bd61                      eor.w     d6,-(a1)
[00013578] 51cc fff0                 dbf       d4,$0001356A
[0001357c] 4ed5                      jmp       (a5)
[0001357e] 3e20                      move.w    -(a0),d7
[00013580] 4847                      swap      d7
[00013582] e0bf                      ror.l     d0,d7
[00013584] 4647                      not.w     d7
[00013586] ce42                      and.w     d2,d7
[00013588] bf61                      eor.w     d7,-(a1)
[0001358a] 90ca                      suba.w    a2,a0
[0001358c] 92cb                      suba.w    a3,a1
[0001358e] 51cd ffc2                 dbf       d5,$00013552
[00013592] 4e75                      rts
[00013594] 3c10                      move.w    (a0),d6
[00013596] 4ed4                      jmp       (a4)
[00013598] 4846                      swap      d6
[0001359a] 3c20                      move.w    -(a0),d6
[0001359c] 3e06                      move.w    d6,d7
[0001359e] e1be                      rol.l     d0,d6
[000135a0] 4646                      not.w     d6
[000135a2] cc43                      and.w     d3,d6
[000135a4] bd51                      eor.w     d6,(a1)
[000135a6] 3801                      move.w    d1,d4
[000135a8] 6b12                      bmi.s     $000135BC
[000135aa] 3c07                      move.w    d7,d6
[000135ac] 4846                      swap      d6
[000135ae] 3c20                      move.w    -(a0),d6
[000135b0] 3e06                      move.w    d6,d7
[000135b2] e1be                      rol.l     d0,d6
[000135b4] 4646                      not.w     d6
[000135b6] bd61                      eor.w     d6,-(a1)
[000135b8] 51cc fff0                 dbf       d4,$000135AA
[000135bc] 4847                      swap      d7
[000135be] 4ed5                      jmp       (a5)
[000135c0] 3e20                      move.w    -(a0),d7
[000135c2] e1bf                      rol.l     d0,d7
[000135c4] 4647                      not.w     d7
[000135c6] ce42                      and.w     d2,d7
[000135c8] bf61                      eor.w     d7,-(a1)
[000135ca] 90ca                      suba.w    a2,a0
[000135cc] 92cb                      suba.w    a3,a1
[000135ce] 51cd ffc4                 dbf       d5,$00013594
[000135d2] 4e75                      rts
[000135d4] 4bfa 001c                 lea.l     $000135F2(pc),a5
[000135d8] 4a42                      tst.w     d2
[000135da] 6704                      beq.s     $000135E0
[000135dc] 4bfa 0012                 lea.l     $000135F0(pc),a5
[000135e0] b751                      eor.w     d3,(a1)
[000135e2] 3801                      move.w    d1,d4
[000135e4] 6b06                      bmi.s     $000135EC
[000135e6] 4661                      not.w     -(a1)
[000135e8] 51cc fffc                 dbf       d4,$000135E6
[000135ec] 4ed5                      jmp       (a5)
[000135ee] 4e71                      nop
[000135f0] b561                      eor.w     d2,-(a1)
[000135f2] 90ca                      suba.w    a2,a0
[000135f4] 92cb                      suba.w    a3,a1
[000135f6] 51cd ffe8                 dbf       d5,$000135E0
[000135fa] 4e75                      rts
[000135fc] 3c10                      move.w    (a0),d6
[000135fe] cc43                      and.w     d3,d6
[00013600] b751                      eor.w     d3,(a1)
[00013602] 8d51                      or.w      d6,(a1)
[00013604] 3801                      move.w    d1,d4
[00013606] 6b0a                      bmi.s     $00013612
[00013608] 3c20                      move.w    -(a0),d6
[0001360a] 4661                      not.w     -(a1)
[0001360c] 8d51                      or.w      d6,(a1)
[0001360e] 51cc fff8                 dbf       d4,$00013608
[00013612] 4ed5                      jmp       (a5)
[00013614] 3c20                      move.w    -(a0),d6
[00013616] cc42                      and.w     d2,d6
[00013618] b561                      eor.w     d2,-(a1)
[0001361a] 8d51                      or.w      d6,(a1)
[0001361c] 90ca                      suba.w    a2,a0
[0001361e] 92cb                      suba.w    a3,a1
[00013620] 51cd ffda                 dbf       d5,$000135FC
[00013624] 4e75                      rts
[00013626] 3c10                      move.w    (a0),d6
[00013628] 4ed4                      jmp       (a4)
[0001362a] 4846                      swap      d6
[0001362c] 3c20                      move.w    -(a0),d6
[0001362e] 4846                      swap      d6
[00013630] 2e06                      move.l    d6,d7
[00013632] e0be                      ror.l     d0,d6
[00013634] cc43                      and.w     d3,d6
[00013636] b751                      eor.w     d3,(a1)
[00013638] 8d51                      or.w      d6,(a1)
[0001363a] 3801                      move.w    d1,d4
[0001363c] 6b12                      bmi.s     $00013650
[0001363e] 2c07                      move.l    d7,d6
[00013640] 3c20                      move.w    -(a0),d6
[00013642] 4846                      swap      d6
[00013644] 2e06                      move.l    d6,d7
[00013646] e0be                      ror.l     d0,d6
[00013648] 4661                      not.w     -(a1)
[0001364a] 8d51                      or.w      d6,(a1)
[0001364c] 51cc fff0                 dbf       d4,$0001363E
[00013650] 4ed5                      jmp       (a5)
[00013652] 3e20                      move.w    -(a0),d7
[00013654] 4847                      swap      d7
[00013656] e0bf                      ror.l     d0,d7
[00013658] ce42                      and.w     d2,d7
[0001365a] b561                      eor.w     d2,-(a1)
[0001365c] 8f51                      or.w      d7,(a1)
[0001365e] 90ca                      suba.w    a2,a0
[00013660] 92cb                      suba.w    a3,a1
[00013662] 51cd ffc2                 dbf       d5,$00013626
[00013666] 4e75                      rts
[00013668] 3c10                      move.w    (a0),d6
[0001366a] 4ed4                      jmp       (a4)
[0001366c] 4846                      swap      d6
[0001366e] 3c20                      move.w    -(a0),d6
[00013670] 3e06                      move.w    d6,d7
[00013672] e1be                      rol.l     d0,d6
[00013674] cc43                      and.w     d3,d6
[00013676] b751                      eor.w     d3,(a1)
[00013678] 8d51                      or.w      d6,(a1)
[0001367a] 3801                      move.w    d1,d4
[0001367c] 6b12                      bmi.s     $00013690
[0001367e] 3c07                      move.w    d7,d6
[00013680] 4846                      swap      d6
[00013682] 3c20                      move.w    -(a0),d6
[00013684] 3e06                      move.w    d6,d7
[00013686] e1be                      rol.l     d0,d6
[00013688] 4661                      not.w     -(a1)
[0001368a] 8d51                      or.w      d6,(a1)
[0001368c] 51cc fff0                 dbf       d4,$0001367E
[00013690] 4847                      swap      d7
[00013692] 4ed5                      jmp       (a5)
[00013694] 3e20                      move.w    -(a0),d7
[00013696] e1bf                      rol.l     d0,d7
[00013698] ce42                      and.w     d2,d7
[0001369a] b561                      eor.w     d2,-(a1)
[0001369c] 8f51                      or.w      d7,(a1)
[0001369e] 90ca                      suba.w    a2,a0
[000136a0] 92cb                      suba.w    a3,a1
[000136a2] 51cd ffc4                 dbf       d5,$00013668
[000136a6] 4e75                      rts
[000136a8] 3c10                      move.w    (a0),d6
[000136aa] 4646                      not.w     d6
[000136ac] cc43                      and.w     d3,d6
[000136ae] 4643                      not.w     d3
[000136b0] c751                      and.w     d3,(a1)
[000136b2] 4643                      not.w     d3
[000136b4] 8d51                      or.w      d6,(a1)
[000136b6] 3801                      move.w    d1,d4
[000136b8] 6b0a                      bmi.s     $000136C4
[000136ba] 3c20                      move.w    -(a0),d6
[000136bc] 4646                      not.w     d6
[000136be] 3306                      move.w    d6,-(a1)
[000136c0] 51cc fff8                 dbf       d4,$000136BA
[000136c4] 4ed5                      jmp       (a5)
[000136c6] 3c20                      move.w    -(a0),d6
[000136c8] 4646                      not.w     d6
[000136ca] cc42                      and.w     d2,d6
[000136cc] 4642                      not.w     d2
[000136ce] c561                      and.w     d2,-(a1)
[000136d0] 4642                      not.w     d2
[000136d2] 8d51                      or.w      d6,(a1)
[000136d4] 90ca                      suba.w    a2,a0
[000136d6] 92cb                      suba.w    a3,a1
[000136d8] 51cd ffce                 dbf       d5,$000136A8
[000136dc] 4e75                      rts
[000136de] 3c10                      move.w    (a0),d6
[000136e0] 4ed4                      jmp       (a4)
[000136e2] 4846                      swap      d6
[000136e4] 3c20                      move.w    -(a0),d6
[000136e6] 4846                      swap      d6
[000136e8] 2e06                      move.l    d6,d7
[000136ea] e0be                      ror.l     d0,d6
[000136ec] 4646                      not.w     d6
[000136ee] cc43                      and.w     d3,d6
[000136f0] 4643                      not.w     d3
[000136f2] c751                      and.w     d3,(a1)
[000136f4] 4643                      not.w     d3
[000136f6] 8d51                      or.w      d6,(a1)
[000136f8] 3801                      move.w    d1,d4
[000136fa] 6b12                      bmi.s     $0001370E
[000136fc] 2c07                      move.l    d7,d6
[000136fe] 3c20                      move.w    -(a0),d6
[00013700] 4846                      swap      d6
[00013702] 2e06                      move.l    d6,d7
[00013704] e0be                      ror.l     d0,d6
[00013706] 4646                      not.w     d6
[00013708] 3306                      move.w    d6,-(a1)
[0001370a] 51cc fff0                 dbf       d4,$000136FC
[0001370e] 4ed5                      jmp       (a5)
[00013710] 3e20                      move.w    -(a0),d7
[00013712] 4847                      swap      d7
[00013714] e0bf                      ror.l     d0,d7
[00013716] 4647                      not.w     d7
[00013718] ce42                      and.w     d2,d7
[0001371a] 4642                      not.w     d2
[0001371c] c561                      and.w     d2,-(a1)
[0001371e] 4642                      not.w     d2
[00013720] 8f51                      or.w      d7,(a1)
[00013722] 90ca                      suba.w    a2,a0
[00013724] 92cb                      suba.w    a3,a1
[00013726] 51cd ffb6                 dbf       d5,$000136DE
[0001372a] 4e75                      rts
[0001372c] 3c10                      move.w    (a0),d6
[0001372e] 4ed4                      jmp       (a4)
[00013730] 4846                      swap      d6
[00013732] 3c20                      move.w    -(a0),d6
[00013734] 3e06                      move.w    d6,d7
[00013736] e1be                      rol.l     d0,d6
[00013738] 4646                      not.w     d6
[0001373a] cc43                      and.w     d3,d6
[0001373c] 4643                      not.w     d3
[0001373e] c751                      and.w     d3,(a1)
[00013740] 4643                      not.w     d3
[00013742] 8d51                      or.w      d6,(a1)
[00013744] 3801                      move.w    d1,d4
[00013746] 6b12                      bmi.s     $0001375A
[00013748] 3c07                      move.w    d7,d6
[0001374a] 4846                      swap      d6
[0001374c] 3c20                      move.w    -(a0),d6
[0001374e] 3e06                      move.w    d6,d7
[00013750] e1be                      rol.l     d0,d6
[00013752] 4646                      not.w     d6
[00013754] 3306                      move.w    d6,-(a1)
[00013756] 51cc fff0                 dbf       d4,$00013748
[0001375a] 4847                      swap      d7
[0001375c] 4ed5                      jmp       (a5)
[0001375e] 3e20                      move.w    -(a0),d7
[00013760] e1bf                      rol.l     d0,d7
[00013762] 4647                      not.w     d7
[00013764] ce42                      and.w     d2,d7
[00013766] 4642                      not.w     d2
[00013768] c561                      and.w     d2,-(a1)
[0001376a] 4642                      not.w     d2
[0001376c] 8f51                      or.w      d7,(a1)
[0001376e] 90ca                      suba.w    a2,a0
[00013770] 92cb                      suba.w    a3,a1
[00013772] 51cd ffb8                 dbf       d5,$0001372C
[00013776] 4e75                      rts
[00013778] 3c10                      move.w    (a0),d6
[0001377a] 4646                      not.w     d6
[0001377c] cc43                      and.w     d3,d6
[0001377e] 8d51                      or.w      d6,(a1)
[00013780] 3801                      move.w    d1,d4
[00013782] 6b0a                      bmi.s     $0001378E
[00013784] 3c20                      move.w    -(a0),d6
[00013786] 4646                      not.w     d6
[00013788] 8d61                      or.w      d6,-(a1)
[0001378a] 51cc fff8                 dbf       d4,$00013784
[0001378e] 4ed5                      jmp       (a5)
[00013790] 3c20                      move.w    -(a0),d6
[00013792] 4646                      not.w     d6
[00013794] cc42                      and.w     d2,d6
[00013796] 8d61                      or.w      d6,-(a1)
[00013798] 90ca                      suba.w    a2,a0
[0001379a] 92cb                      suba.w    a3,a1
[0001379c] 51cd ffda                 dbf       d5,$00013778
[000137a0] 4e75                      rts
[000137a2] 3c10                      move.w    (a0),d6
[000137a4] 4ed4                      jmp       (a4)
[000137a6] 4846                      swap      d6
[000137a8] 3c20                      move.w    -(a0),d6
[000137aa] 4846                      swap      d6
[000137ac] 2e06                      move.l    d6,d7
[000137ae] e0be                      ror.l     d0,d6
[000137b0] 4646                      not.w     d6
[000137b2] cc43                      and.w     d3,d6
[000137b4] 8d51                      or.w      d6,(a1)
[000137b6] 3801                      move.w    d1,d4
[000137b8] 6b12                      bmi.s     $000137CC
[000137ba] 2c07                      move.l    d7,d6
[000137bc] 3c20                      move.w    -(a0),d6
[000137be] 4846                      swap      d6
[000137c0] 2e06                      move.l    d6,d7
[000137c2] e0be                      ror.l     d0,d6
[000137c4] 4646                      not.w     d6
[000137c6] 8d61                      or.w      d6,-(a1)
[000137c8] 51cc fff0                 dbf       d4,$000137BA
[000137cc] 4ed5                      jmp       (a5)
[000137ce] 3e20                      move.w    -(a0),d7
[000137d0] 4847                      swap      d7
[000137d2] e0bf                      ror.l     d0,d7
[000137d4] 4647                      not.w     d7
[000137d6] ce42                      and.w     d2,d7
[000137d8] 8f61                      or.w      d7,-(a1)
[000137da] 90ca                      suba.w    a2,a0
[000137dc] 92cb                      suba.w    a3,a1
[000137de] 51cd ffc2                 dbf       d5,$000137A2
[000137e2] 4e75                      rts
[000137e4] 3c10                      move.w    (a0),d6
[000137e6] 4ed4                      jmp       (a4)
[000137e8] 4846                      swap      d6
[000137ea] 3c20                      move.w    -(a0),d6
[000137ec] 3e06                      move.w    d6,d7
[000137ee] e1be                      rol.l     d0,d6
[000137f0] 4646                      not.w     d6
[000137f2] cc43                      and.w     d3,d6
[000137f4] 8d51                      or.w      d6,(a1)
[000137f6] 3801                      move.w    d1,d4
[000137f8] 6b12                      bmi.s     $0001380C
[000137fa] 3c07                      move.w    d7,d6
[000137fc] 4846                      swap      d6
[000137fe] 3c20                      move.w    -(a0),d6
[00013800] 3e06                      move.w    d6,d7
[00013802] e1be                      rol.l     d0,d6
[00013804] 4646                      not.w     d6
[00013806] 8d61                      or.w      d6,-(a1)
[00013808] 51cc fff0                 dbf       d4,$000137FA
[0001380c] 4847                      swap      d7
[0001380e] 4ed5                      jmp       (a5)
[00013810] 3e20                      move.w    -(a0),d7
[00013812] e1bf                      rol.l     d0,d7
[00013814] 4647                      not.w     d7
[00013816] ce42                      and.w     d2,d7
[00013818] 8f61                      or.w      d7,-(a1)
[0001381a] 90ca                      suba.w    a2,a0
[0001381c] 92cb                      suba.w    a3,a1
[0001381e] 51cd ffc4                 dbf       d5,$000137E4
[00013822] 4e75                      rts
[00013824] 3c10                      move.w    (a0),d6
[00013826] 8c43                      or.w      d3,d6
[00013828] cd51                      and.w     d6,(a1)
[0001382a] b751                      eor.w     d3,(a1)
[0001382c] 3801                      move.w    d1,d4
[0001382e] 6b0a                      bmi.s     $0001383A
[00013830] 3c20                      move.w    -(a0),d6
[00013832] cd61                      and.w     d6,-(a1)
[00013834] 4651                      not.w     (a1)
[00013836] 51cc fff8                 dbf       d4,$00013830
[0001383a] 4ed5                      jmp       (a5)
[0001383c] 3c20                      move.w    -(a0),d6
[0001383e] 8c42                      or.w      d2,d6
[00013840] cd61                      and.w     d6,-(a1)
[00013842] 8551                      or.w      d2,(a1)
[00013844] 90ca                      suba.w    a2,a0
[00013846] 92cb                      suba.w    a3,a1
[00013848] 51cd ffda                 dbf       d5,$00013824
[0001384c] 4e75                      rts
[0001384e] 3c10                      move.w    (a0),d6
[00013850] 4ed4                      jmp       (a4)
[00013852] 4846                      swap      d6
[00013854] 3c20                      move.w    -(a0),d6
[00013856] 4846                      swap      d6
[00013858] 2e06                      move.l    d6,d7
[0001385a] e0be                      ror.l     d0,d6
[0001385c] 8c43                      or.w      d3,d6
[0001385e] cd51                      and.w     d6,(a1)
[00013860] b751                      eor.w     d3,(a1)
[00013862] 3801                      move.w    d1,d4
[00013864] 6b12                      bmi.s     $00013878
[00013866] 2c07                      move.l    d7,d6
[00013868] 3c20                      move.w    -(a0),d6
[0001386a] 4846                      swap      d6
[0001386c] 2e06                      move.l    d6,d7
[0001386e] e0be                      ror.l     d0,d6
[00013870] cd61                      and.w     d6,-(a1)
[00013872] 4651                      not.w     (a1)
[00013874] 51cc fff0                 dbf       d4,$00013866
[00013878] 4ed5                      jmp       (a5)
[0001387a] 3e20                      move.w    -(a0),d7
[0001387c] 4847                      swap      d7
[0001387e] e0bf                      ror.l     d0,d7
[00013880] 8e42                      or.w      d2,d7
[00013882] cf61                      and.w     d7,-(a1)
[00013884] 8551                      or.w      d2,(a1)
[00013886] 90ca                      suba.w    a2,a0
[00013888] 92cb                      suba.w    a3,a1
[0001388a] 51cd ffc2                 dbf       d5,$0001384E
[0001388e] 4e75                      rts
[00013890] 3c10                      move.w    (a0),d6
[00013892] 4ed4                      jmp       (a4)
[00013894] 4846                      swap      d6
[00013896] 3c20                      move.w    -(a0),d6
[00013898] 3e06                      move.w    d6,d7
[0001389a] e1be                      rol.l     d0,d6
[0001389c] 8c43                      or.w      d3,d6
[0001389e] cd51                      and.w     d6,(a1)
[000138a0] b751                      eor.w     d3,(a1)
[000138a2] 3801                      move.w    d1,d4
[000138a4] 6b12                      bmi.s     $000138B8
[000138a6] 3c07                      move.w    d7,d6
[000138a8] 4846                      swap      d6
[000138aa] 3c20                      move.w    -(a0),d6
[000138ac] 3e06                      move.w    d6,d7
[000138ae] e1be                      rol.l     d0,d6
[000138b0] cd61                      and.w     d6,-(a1)
[000138b2] 4651                      not.w     (a1)
[000138b4] 51cc fff0                 dbf       d4,$000138A6
[000138b8] 4847                      swap      d7
[000138ba] 4ed5                      jmp       (a5)
[000138bc] 3e20                      move.w    -(a0),d7
[000138be] e1bf                      rol.l     d0,d7
[000138c0] 8e42                      or.w      d2,d7
[000138c2] cf61                      and.w     d7,-(a1)
[000138c4] 8551                      or.w      d2,(a1)
[000138c6] 90ca                      suba.w    a2,a0
[000138c8] 92cb                      suba.w    a3,a1
[000138ca] 51cd ffc4                 dbf       d5,$00013890
[000138ce] 4e75                      rts
[000138d0] 7eff                      moveq.l   #-1,d7
[000138d2] 4bfa 0018                 lea.l     $000138EC(pc),a5
[000138d6] 4a42                      tst.w     d2
[000138d8] 6604                      bne.s     $000138DE
[000138da] 4bfa 0012                 lea.l     $000138EE(pc),a5
[000138de] 8751                      or.w      d3,(a1)
[000138e0] 3801                      move.w    d1,d4
[000138e2] 6b06                      bmi.s     $000138EA
[000138e4] 3307                      move.w    d7,-(a1)
[000138e6] 51cc fffc                 dbf       d4,$000138E4
[000138ea] 4ed5                      jmp       (a5)
[000138ec] 8561                      or.w      d2,-(a1)
[000138ee] 92cb                      suba.w    a3,a1
[000138f0] 51cd ffec                 dbf       d5,$000138DE
[000138f4] 4e75                      rts
[000138f6] 4e75                      rts

data:
[000138f8]                           dc.w $028c
[000138fa]                           dc.w $0260
[000138fc]                           dc.w $0034
[000138fe]                           dc.w $002c
[00013900]                           dc.w $0048
[00013902]                           dc.w $0370
[00013904]                           dc.w $005c
[00013906]                           dc.w $0308
[00013908]                           dc.w $01ce
[0001390a]                           dc.w $0000
[0001390c]                           dc.w $000f
[0001390e]                           dc.w $0102
[00013910]                           dc.w $0406
[00013912]                           dc.w $0305
[00013914]                           dc.w $0708
[00013916]                           dc.w $090a
[00013918]                           dc.w $0c0e
[0001391a]                           dc.w $0b0d
[0001391c]                           dc.w $0002
[0001391e]                           dc.w $0306
[00013920]                           dc.w $0407
[00013922]                           dc.w $0508
[00013924]                           dc.w $090a
[00013926]                           dc.w $0b0e
[00013928]                           dc.w $0c0f
[0001392a]                           dc.w $0d01
[0001392c]                           dc.w $00ff
[0001392e]                           dc.w $1122
[00013930]                           dc.b 'Df3Uw'
[00013935]                           dc.b $88
[00013936]                           dc.w $99aa
[00013938]                           dc.w $ccee
[0001393a]                           dc.w $bbdd
[0001393c]                           dc.w $0000
[0001393e]                           dc.w $ffff
[00013940]                           dc.w $1111
[00013942]                           dc.b '""DDff33UUww'
[0001394e]                           dc.w $8888
[00013950]                           dc.w $9999
[00013952]                           dc.w $aaaa
[00013954]                           dc.w $cccc
[00013956]                           dc.w $eeee
[00013958]                           dc.w $bbbb
[0001395a]                           dc.w $dddd
[0001395c]                           dc.w $0000
[0001395e]                           dc.w $0000
[00013960]                           dc.w $ffff
[00013962]                           dc.w $ffff
[00013964]                           dc.w $1111
[00013966]                           dc.w $1111
[00013968]                           dc.b '""""DDDDffff3333UUUUwwww'
[00013980]                           dc.w $8888
[00013982]                           dc.w $8888
[00013984]                           dc.w $9999
[00013986]                           dc.w $9999
[00013988]                           dc.w $aaaa
[0001398a]                           dc.w $aaaa
[0001398c]                           dc.w $cccc
[0001398e]                           dc.w $cccc
[00013990]                           dc.w $eeee
[00013992]                           dc.w $eeee
[00013994]                           dc.w $bbbb
[00013996]                           dc.w $bbbb
[00013998]                           dc.w $dddd
[0001399a]                           dc.w $dddd
[0001399c]                           dc.w $0000
[0001399e]                           dc.w $0000
[000139a0]                           dc.w $1111
[000139a2]                           dc.w $1111
[000139a4]                           dc.b '""""3333DDDDUUUUffffwwww'
[000139bc]                           dc.w $8888
[000139be]                           dc.w $8888
[000139c0]                           dc.w $9999
[000139c2]                           dc.w $9999
[000139c4]                           dc.w $aaaa
[000139c6]                           dc.w $aaaa
[000139c8]                           dc.w $bbbb
[000139ca]                           dc.w $bbbb
[000139cc]                           dc.w $cccc
[000139ce]                           dc.w $cccc
[000139d0]                           dc.w $dddd
[000139d2]                           dc.w $dddd
[000139d4]                           dc.w $eeee
[000139d6]                           dc.w $eeee
[000139d8]                           dc.w $ffff
[000139da]                           dc.w $ffff
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
; $00000060
; $0000015e
; $00000170
; $000001c6
; $000001ce
; $000001d6
; $000001de
; $000001e6
; $000001ee
; $000001f6
; $000001fe
; $00000206
; $0000020e
; $00000216
; $0000021e
; $00000226
; $0000022e
; $00000236
; $0000023e
; $00000246
; $00000344
; $0000037a
; $0000037e
; $00000382
; $00000386
; $00000484
; $00000582
; $00000610
; $00000618
; $0000061c
; $00000624
; $00000684
; $00000694
; $00000708
; $00000710
; $00000714
; $0000071c
; $0000077e
; $0000078e
; $0000080e
; $00000816
; $0000081a
; $00000822
; $00000882
; $00000892
; $00000990
; $00000a8e
; $00000b8c
; $00000c8a
; $00000d88
; $00000e86
; $00000f68
; $00000f70
; $00000f74
; $00000f7c
; $00000fdc
; $00000fee
; $000010ec
; $000011ea
; $000011f2
; $000011fa
; $000011fe
; $00001206
; $00001266
; $00001278
; $00001376
; $000013c4
; $000013cc
; $000013d0
; $000013d8
; $00001438
; $0000144a
; $00001548
; $00001646
; $00001664
; $00001684
