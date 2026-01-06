; ph_branch = 0x601a
; ph_tlen = 0x0000390e
; ph_dlen = 0x00000014
; ph_blen = 0x00002004
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x0000003a

[00010000] 604e                      bra.s      $00010050
[00010002] 4f46                      lea.l      d6,b7 ; apollo only
[00010004] 4653                      not.w      (a3)
[00010006] 4352                      lea.l      (a2),b1 ; apollo only
[00010008] 4e00 0500                 cmpiw.l    #$0500,d0 ; apollo only
[0001000c] 0050 0000                 ori.w      #$0000,(a0)
[00010010] 0001 0052                 ori.b      #$52,d1
[00010014] 0001 0070                 ori.b      #$70,d1
[00010018] 0001 03fa                 ori.b      #$FA,d1
[0001001c] 0001 0488                 ori.b      #$88,d1
[00010020] 0001 0072                 ori.b      #$72,d1
[00010024] 0001 00b2                 ori.b      #$B2,d1
[00010028] 0001 0100                 ori.b      #$00,d1
[0001002c] 0000                      dc.w       $0000
[0001002e] 0000                      dc.w       $0000
[00010030] 0000                      dc.w       $0000
[00010032] 0000                      dc.w       $0000
[00010034] 0000                      dc.w       $0000
[00010036] 0000                      dc.w       $0000
[00010038] 0000                      dc.w       $0000
[0001003a] 0000                      dc.w       $0000
[0001003c] 0000                      dc.w       $0000
[0001003e] 0000 0100                 ori.b      #$00,d0
[00010042] 0000 0018                 ori.b      #$18,d0
[00010046] 0002 0081                 ori.b      #$81,d2
[0001004a] 0000                      dc.w       $0000
[0001004c] 0000                      dc.w       $0000
[0001004e] 0000 4e75                 ori.b      #$75,d0
[00010052] 48e7 e0e0                 movem.l    d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 3922            move.l     a0,$00013922
[0001005c] 6100 02d8                 bsr        $00010336
[00010060] 6100 02fa                 bsr        $0001035C
[00010064] 4cdf 0707                 movem.l    (a7)+,d0-d2/a0-a2
[00010068] 203c 0000 0b20            move.l     #$00000B20,d0
[0001006e] 4e75                      rts
[00010070] 4e75                      rts
[00010072] 48e7 80e0                 movem.l    d0/a0-a2,-(a7)
[00010076] 20ee 0010                 move.l     16(a6),(a0)+
[0001007a] 4258                      clr.w      (a0)+
[0001007c] 20ee 000c                 move.l     12(a6),(a0)+
[00010080] 7027                      moveq.l    #39,d0
[00010082] 247a 389e                 movea.l    $00013922(pc),a2
[00010086] 246a 002c                 movea.l    44(a2),a2
[0001008a] 45ea 000a                 lea.l      10(a2),a2
[0001008e] 30da                      move.w     (a2)+,(a0)+
[00010090] 51c8 fffc                 dbf        d0,$0001008E
[00010094] 317c 0100 ffc0            move.w     #$0100,-64(a0)
[0001009a] 317c 0001 ffec            move.w     #$0001,-20(a0)
[000100a0] 4268 fff4                 clr.w      -12(a0)
[000100a4] 700b                      moveq.l    #11,d0
[000100a6] 32da                      move.w     (a2)+,(a1)+
[000100a8] 51c8 fffc                 dbf        d0,$000100A6
[000100ac] 4cdf 0701                 movem.l    (a7)+,d0/a0-a2
[000100b0] 4e75                      rts
[000100b2] 48e7 80e0                 movem.l    d0/a0-a2,-(a7)
[000100b6] 702c                      moveq.l    #44,d0
[000100b8] 247a 3868                 movea.l    $00013922(pc),a2
[000100bc] 246a 0030                 movea.l    48(a2),a2
[000100c0] 30da                      move.w     (a2)+,(a0)+
[000100c2] 51c8 fffc                 dbf        d0,$000100C0
[000100c6] 4268 ffa6                 clr.w      -90(a0)
[000100ca] 4268 ffa8                 clr.w      -88(a0)
[000100ce] 317c 0018 ffae            move.w     #$0018,-82(a0)
[000100d4] 317c 0001 ffb0            move.w     #$0001,-80(a0)
[000100da] 317c 0898 ffb2            move.w     #$0898,-78(a0)
[000100e0] 317c 0001 ffcc            move.w     #$0001,-52(a0)
[000100e6] 700b                      moveq.l    #11,d0
[000100e8] 32da                      move.w     (a2)+,(a1)+
[000100ea] 51c8 fffc                 dbf        d0,$000100E8
[000100ee] 45ee 0034                 lea.l      52(a6),a2
[000100f2] 235a ffe8                 move.l     (a2)+,-24(a1)
[000100f6] 235a ffec                 move.l     (a2)+,-20(a1)
[000100fa] 4cdf 0701                 movem.l    (a7)+,d0/a0-a2
[000100fe] 4e75                      rts
[00010100] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010104] 43fa 0050                 lea.l      $00010156(pc),a1
[00010108] 30d9                      move.w     (a1)+,(a0)+
[0001010a] 30d9                      move.w     (a1)+,(a0)+
[0001010c] 30d9                      move.w     (a1)+,(a0)+
[0001010e] 20d9                      move.l     (a1)+,(a0)+
[00010110] 30ee 01b2                 move.w     434(a6),(a0)+
[00010114] 20ee 01ae                 move.l     430(a6),(a0)+
[00010118] 5c89                      addq.l     #6,a1
[0001011a] 30d9                      move.w     (a1)+,(a0)+
[0001011c] 30d9                      move.w     (a1)+,(a0)+
[0001011e] 30d9                      move.w     (a1)+,(a0)+
[00010120] 30d9                      move.w     (a1)+,(a0)+
[00010122] 30d9                      move.w     (a1)+,(a0)+
[00010124] 30d9                      move.w     (a1)+,(a0)+
[00010126] 30ee 01a2                 move.w     418(a6),(a0)+
[0001012a] 30e9 0002                 move.w     2(a1),(a0)+
[0001012e] 706f                      moveq.l    #111,d0
[00010130] 43fa 0044                 lea.l      $00010176(pc),a1
[00010134] 082e 0007 01a3            btst       #7,419(a6)
[0001013a] 6704                      beq.s      $00010140
[0001013c] 43fa 0118                 lea.l      $00010256(pc),a1
[00010140] 30d9                      move.w     (a1)+,(a0)+
[00010142] 51c8 fffc                 dbf        d0,$00010140
[00010146] 303c 008f                 move.w     #$008F,d0
[0001014a] 4258                      clr.w      (a0)+
[0001014c] 51c8 fffc                 dbf        d0,$0001014A
[00010150] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010154] 4e75                      rts
[00010156] 0002 0002                 ori.b      #$02,d2
[0001015a] 0018 0100                 ori.b      #$00,(a0)+
[0001015e] 0000                      dc.w       $0000
[00010160] 0000                      dc.w       $0000
[00010162] 0000                      dc.w       $0000
[00010164] 0000 0008                 ori.b      #$08,d0
[00010168] 0008 0008                 ori.b      #$08,a0 ; apollo only
[0001016c] 0000                      dc.w       $0000
[0001016e] 0000                      dc.w       $0000
[00010170] 0000                      dc.w       $0000
[00010172] 0000                      dc.w       $0000
[00010174] 0000 0010                 ori.b      #$10,d0
[00010178] 0011 0012                 ori.b      #$12,(a1)
[0001017c] 0013 0014                 ori.b      #$14,(a3)
[00010180] 0015 0016                 ori.b      #$16,(a5)
[00010184] 0017 ffff                 ori.b      #$FF,(a7)
[00010188] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010190] ffff ffff ffff 0008       vperm      #$FFFF0008,e23,e23,e23
[00010198] 0009 000a                 ori.b      #$0A,a1 ; apollo only
[0001019c] 000b 000c                 ori.b      #$0C,a3 ; apollo only
[000101a0] 000d 000e                 ori.b      #$0E,a5 ; apollo only
[000101a4] 000f ffff                 ori.b      #$FF,a7 ; apollo only
[000101a8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101b0] ffff ffff ffff 0000       vperm      #$FFFF0000,e23,e23,e23
[000101b8] 0001 0002                 ori.b      #$02,d1
[000101bc] 0003 0004                 ori.b      #$04,d3
[000101c0] 0005 0006                 ori.b      #$06,d5
[000101c4] 0007 ffff                 ori.b      #$FF,d7
[000101c8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101d0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101d8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101e0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101e8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101f0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101f8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010200] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010208] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010210] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010218] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010220] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010228] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010230] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010238] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010240] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010248] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010250] ffff ffff ffff 0000       vperm      #$FFFF0000,e23,e23,e23
[00010258] 0001 0002                 ori.b      #$02,d1
[0001025c] 0003 0004                 ori.b      #$04,d3
[00010260] 0005 0006                 ori.b      #$06,d5
[00010264] 0007 ffff                 ori.b      #$FF,d7
[00010268] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010270] ffff ffff ffff 0008       vperm      #$FFFF0008,e23,e23,e23
[00010278] 0009 000a                 ori.b      #$0A,a1 ; apollo only
[0001027c] 000b 000c                 ori.b      #$0C,a3 ; apollo only
[00010280] 000d 000e                 ori.b      #$0E,a5 ; apollo only
[00010284] 000f ffff                 ori.b      #$FF,a7 ; apollo only
[00010288] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010290] ffff ffff ffff 0010       vperm      #$FFFF0010,e23,e23,e23
[00010298] 0011 0012                 ori.b      #$12,(a1)
[0001029c] 0013 0014                 ori.b      #$14,(a3)
[000102a0] 0015 0016                 ori.b      #$16,(a5)
[000102a4] 0017 ffff                 ori.b      #$FF,(a7)
[000102a8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102b0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102b8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102c0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102c8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102d0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102d8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102e0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102e8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102f0] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102f8] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010300] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010308] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010310] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010318] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010320] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010328] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010330] ffff ffff ffff 48e7       vperm      #$FFFF48E7,e23,e23,e23
[00010338] e0e0                      asr.w      -(a0)
[0001033a] a000                      ALINE      #$0000
[0001033c] 907c 2070                 sub.w      #$2070,d0
[00010340] 6714                      beq.s      $00010356
[00010342] 41fa fcbc                 lea.l      $00010000(pc),a0
[00010346] 43f9 0001 390e            lea.l      $0001390E,a1
[0001034c] 3219                      move.w     (a1)+,d1
[0001034e] 6706                      beq.s      $00010356
[00010350] d0c1                      adda.w     d1,a0
[00010352] d150                      add.w      d0,(a0)
[00010354] 60f6                      bra.s      $0001034C
[00010356] 4cdf 0707                 movem.l    (a7)+,d0-d2/a0-a2
[0001035a] 4e75                      rts
[0001035c] 48e7 e0c0                 movem.l    d0-d2/a0-a1,-(a7)
[00010360] 41fa 35c4                 lea.l      $00013926(pc),a0
[00010364] 7000                      moveq.l    #0,d0
[00010366] 3200                      move.w     d0,d1
[00010368] 7407                      moveq.l    #7,d2
[0001036a] 4218                      clr.b      (a0)+
[0001036c] 4218                      clr.b      (a0)+
[0001036e] 4218                      clr.b      (a0)+
[00010370] d201                      add.b      d1,d1
[00010372] 650c                      bcs.s      $00010380
[00010374] 4628 fffd                 not.b      -3(a0)
[00010378] 4628 fffe                 not.b      -2(a0)
[0001037c] 4628 ffff                 not.b      -1(a0)
[00010380] 51ca ffe8                 dbf        d2,$0001036A
[00010384] 5088                      addq.l     #8,a0
[00010386] 5240                      addq.w     #1,d0
[00010388] b07c 0100                 cmp.w      #$0100,d0
[0001038c] 6dd8                      blt.s      $00010366
[0001038e] 4cdf 0307                 movem.l    (a7)+,d0-d2/a0-a1
[00010392] 4e75                      rts
[00010394] 3600                      move.w     d0,d3
[00010396] 4843                      swap       d3
[00010398] 3600                      move.w     d0,d3
[0001039a] 4a6e 01b2                 tst.w      434(a6)
[0001039e] 670a                      beq.s      $000103AA
[000103a0] 266e 01ae                 movea.l    430(a6),a3
[000103a4] c3ee 01b2                 muls.w     434(a6),d1
[000103a8] 6008                      bra.s      $000103B2
[000103aa] 2678 044e                 movea.l    ($0000044E).w,a3
[000103ae] c3f8 206e                 muls.w     ($0000206E).w,d1
[000103b2] d7c1                      adda.l     d1,a3
[000103b4] e540                      asl.w      #2,d0
[000103b6] d6c0                      adda.w     d0,a3
[000103b8] e440                      asr.w      #2,d0
[000103ba] 284b                      movea.l    a3,a4
[000103bc] 2813                      move.l     (a3),d4
[000103be] b642                      cmp.w      d2,d3
[000103c0] 6e0e                      bgt.s      $000103D0
[000103c2] 588b                      addq.l     #4,a3
[000103c4] b89b                      cmp.l      (a3)+,d4
[000103c6] 6608                      bne.s      $000103D0
[000103c8] 5243                      addq.w     #1,d3
[000103ca] b642                      cmp.w      d2,d3
[000103cc] 6df6                      blt.s      $000103C4
[000103ce] 3602                      move.w     d2,d3
[000103d0] 3283                      move.w     d3,(a1)
[000103d2] 4842                      swap       d2
[000103d4] 4843                      swap       d3
[000103d6] 264c                      movea.l    a4,a3
[000103d8] b642                      cmp.w      d2,d3
[000103da] 6f0e                      ble.s      $000103EA
[000103dc] 3003                      move.w     d3,d0
[000103de] b8a3                      cmp.l      -(a3),d4
[000103e0] 6608                      bne.s      $000103EA
[000103e2] 5343                      subq.w     #1,d3
[000103e4] b642                      cmp.w      d2,d3
[000103e6] 6ef6                      bgt.s      $000103DE
[000103e8] 3602                      move.w     d2,d3
[000103ea] 3083                      move.w     d3,(a0)
[000103ec] 3015                      move.w     (a5),d0
[000103ee] b8ad 0002                 cmp.l      2(a5),d4
[000103f2] 6704                      beq.s      $000103F8
[000103f4] 0a40 0001                 eori.w     #$0001,d0
[000103f8] 4e75                      rts
[000103fa] 48e7 e0e0                 movem.l    d0-d2/a0-a2,-(a7)
[000103fe] 3d7c 0017 01b4            move.w     #$0017,436(a6)
[00010404] 3d7c 00ff 0014            move.w     #$00FF,20(a6)
[0001040a] 2d7c 0001 1174 01f4       move.l     #$00011174,500(a6)
[00010412] 2d7c 0001 08de 01f8       move.l     #$000108DE,504(a6)
[0001041a] 2d7c 0001 0968 01fc       move.l     #$00010968,508(a6)
[00010422] 2d7c 0001 0b18 0200       move.l     #$00010B18,512(a6)
[0001042a] 2d7c 0001 0d44 0204       move.l     #$00010D44,516(a6)
[00010432] 2d7c 0001 17b2 0208       move.l     #$000117B2,520(a6)
[0001043a] 2d7c 0001 1aa6 020c       move.l     #$00011AA6,524(a6)
[00010442] 2d7c 0001 08ac 0210       move.l     #$000108AC,528(a6)
[0001044a] 2d7c 0001 0394 0214       move.l     #$00010394,532(a6)
[00010452] 2d7c 0001 084c 021c       move.l     #$0001084C,540(a6)
[0001045a] 2d7c 0001 087c 0218       move.l     #$0001087C,536(a6)
[00010462] 2d7c 0001 050e 0220       move.l     #$0001050E,544(a6)
[0001046a] 2d7c 0001 048a 0224       move.l     #$0001048A,548(a6)
[00010472] 2d7c 0001 04d2 0230       move.l     #$000104D2,560(a6)
[0001047a] 2d7c 0001 050a 0234       move.l     #$0001050A,564(a6)
[00010482] 4cdf 0707                 movem.l    (a7)+,d0-d2/a0-a2
[00010486] 4e75                      rts
[00010488] 4e75                      rts
[0001048a] b07c 0010                 cmp.w      #$0010,d0
[0001048e] 6614                      bne.s      $000104A4
[00010490] 22d8                      move.l     (a0)+,(a1)+
[00010492] 22d8                      move.l     (a0)+,(a1)+
[00010494] 22d8                      move.l     (a0)+,(a1)+
[00010496] 22d8                      move.l     (a0)+,(a1)+
[00010498] 22d8                      move.l     (a0)+,(a1)+
[0001049a] 22d8                      move.l     (a0)+,(a1)+
[0001049c] 22d8                      move.l     (a0)+,(a1)+
[0001049e] 22d8                      move.l     (a0)+,(a1)+
[000104a0] 7000                      moveq.l    #0,d0
[000104a2] 4e75                      rts
[000104a4] 303c 00ff                 move.w     #$00FF,d0
[000104a8] 082e 0007 01a3            btst       #7,419(a6)
[000104ae] 660a                      bne.s      $000104BA
[000104b0] 22d8                      move.l     (a0)+,(a1)+
[000104b2] 51c8 fffc                 dbf        d0,$000104B0
[000104b6] 7017                      moveq.l    #23,d0
[000104b8] 4e75                      rts
[000104ba] 1298                      move.b     (a0)+,(a1)
[000104bc] 1358 0003                 move.b     (a0)+,3(a1)
[000104c0] 1358 0002                 move.b     (a0)+,2(a1)
[000104c4] 1358 0001                 move.b     (a0)+,1(a1)
[000104c8] 5889                      addq.l     #4,a1
[000104ca] 51c8 ffee                 dbf        d0,$000104BA
[000104ce] 7017                      moveq.l    #23,d0
[000104d0] 4e75                      rts
[000104d2] 207a 344e                 movea.l    $00013922(pc),a0
[000104d6] 2068 0028                 movea.l    40(a0),a0
[000104da] 2050                      movea.l    (a0),a0
[000104dc] 1030 0000                 move.b     0(a0,d0.w),d0
[000104e0] 206e 0278                 movea.l    632(a6),a0
[000104e4] e748                      lsl.w      #3,d0
[000104e6] 41f0 0830                 lea.l      48(a0,d0.l),a0
[000104ea] 7000                      moveq.l    #0,d0
[000104ec] 1028 0002                 move.b     2(a0),d0
[000104f0] 5888                      addq.l     #4,a0
[000104f2] 4840                      swap       d0
[000104f4] 3018                      move.w     (a0)+,d0
[000104f6] 1010                      move.b     (a0),d0
[000104f8] 082e 0007 01a3            btst       #7,419(a6)
[000104fe] 6708                      beq.s      $00010508
[00010500] e158                      rol.w      #8,d0
[00010502] 4840                      swap       d0
[00010504] e148                      lsl.w      #8,d0
[00010506] e088                      lsr.l      #8,d0
[00010508] 4e75                      rts
[0001050a] 70ff                      moveq.l    #-1,d0
[0001050c] 4e75                      rts
[0001050e] 2f0e                      move.l     a6,-(a7)
[00010510] 7000                      moveq.l    #0,d0
[00010512] 3028 000c                 move.w     12(a0),d0
[00010516] 3228 0006                 move.w     6(a0),d1
[0001051a] c2e8 0008                 mulu.w     8(a0),d1
[0001051e] 7400                      moveq.l    #0,d2
[00010520] 4a68 000a                 tst.w      10(a0)
[00010524] 6602                      bne.s      $00010528
[00010526] 7401                      moveq.l    #1,d2
[00010528] 3342 000a                 move.w     d2,10(a1)
[0001052c] 2050                      movea.l    (a0),a0
[0001052e] 2251                      movea.l    (a1),a1
[00010530] 5381                      subq.l     #1,d1
[00010532] 6b76                      bmi.s      $000105AA
[00010534] 5340                      subq.w     #1,d0
[00010536] 6700 02fe                 beq        $00010836
[0001053a] 907c 0017                 sub.w      #$0017,d0
[0001053e] 666a                      bne.s      $000105AA
[00010540] d442                      add.w      d2,d2
[00010542] d442                      add.w      d2,d2
[00010544] 247b 2068                 movea.l    $000105AE(pc,d2.w),a2
[00010548] b3c8                      cmpa.l     a0,a1
[0001054a] 6658                      bne.s      $000105A4
[0001054c] 2601                      move.l     d1,d3
[0001054e] 5283                      addq.l     #1,d3
[00010550] ed8b                      lsl.l      #6,d3
[00010552] b6bc 0000 4000            cmp.l      #$00004000,d3
[00010558] 6e44                      bgt.s      $0001059E
[0001055a] 2003                      move.l     d3,d0
[0001055c] 207a 33c4                 movea.l    $00013922(pc),a0
[00010560] 2068 008c                 movea.l    140(a0),a0
[00010564] 4e90                      jsr        (a0)
[00010566] 2008                      move.l     a0,d0
[00010568] 6734                      beq.s      $0001059E
[0001056a] c149                      exg        a0,a1
[0001056c] 2f09                      move.l     a1,-(a7)
[0001056e] 2f03                      move.l     d3,-(a7)
[00010570] 2f08                      move.l     a0,-(a7)
[00010572] 2001                      move.l     d1,d0
[00010574] 5280                      addq.l     #1,d0
[00010576] 4e92                      jsr        (a2)
[00010578] 225f                      movea.l    (a7)+,a1
[0001057a] 221f                      move.l     (a7)+,d1
[0001057c] 205f                      movea.l    (a7)+,a0
[0001057e] e289                      lsr.l      #1,d1
[00010580] 5381                      subq.l     #1,d1
[00010582] 2c5f                      movea.l    (a7)+,a6
[00010584] 2f08                      move.l     a0,-(a7)
[00010586] 487a 0008                 pea.l      $00010590(pc)
[0001058a] 2f0e                      move.l     a6,-(a7)
[0001058c] 6000 02ac                 bra        $0001083A
[00010590] 205f                      movea.l    (a7)+,a0
[00010592] 227a 338e                 movea.l    $00013922(pc),a1
[00010596] 2269 0090                 movea.l    144(a1),a1
[0001059a] 4e91                      jsr        (a1)
[0001059c] 4e75                      rts
[0001059e] 247b 2016                 movea.l    $000105B6(pc,d2.w),a2
[000105a2] 6004                      bra.s      $000105A8
[000105a4] 2001                      move.l     d1,d0
[000105a6] 5280                      addq.l     #1,d0
[000105a8] 4e92                      jsr        (a2)
[000105aa] 2c5f                      movea.l    (a7)+,a6
[000105ac] 4e75                      rts
[000105ae] 0001 07a6                 ori.b      #$A6,d1
[000105b2] 0001 071a                 ori.b      #$1A,d1
[000105b6] 0001 05be                 ori.b      #$BE,d1
[000105ba] 0001 06a6                 ori.b      #$A6,d1
[000105be] 48e7 40c0                 movem.l    d1/a0-a1,-(a7)
[000105c2] 2001                      move.l     d1,d0
[000105c4] 7817                      moveq.l    #23,d4
[000105c6] 6100 0122                 bsr        $000106EA
[000105ca] 4cdf 0302                 movem.l    (a7)+,d1/a0-a1
[000105ce] 2c41                      movea.l    d1,a6
[000105d0] 2f08                      move.l     a0,-(a7)
[000105d2] 41e8 0030                 lea.l      48(a0),a0
[000105d6] 2f20                      move.l     -(a0),-(a7)
[000105d8] 2f20                      move.l     -(a0),-(a7)
[000105da] 2f20                      move.l     -(a0),-(a7)
[000105dc] 2f20                      move.l     -(a0),-(a7)
[000105de] 2f20                      move.l     -(a0),-(a7)
[000105e0] 2f20                      move.l     -(a0),-(a7)
[000105e2] 2f20                      move.l     -(a0),-(a7)
[000105e4] 2f20                      move.l     -(a0),-(a7)
[000105e6] 41e8 fff0                 lea.l      -16(a0),a0
[000105ea] 2f09                      move.l     a1,-(a7)
[000105ec] 6128                      bsr.s      $00010616
[000105ee] 225f                      movea.l    (a7)+,a1
[000105f0] 5289                      addq.l     #1,a1
[000105f2] 204f                      movea.l    a7,a0
[000105f4] 2f09                      move.l     a1,-(a7)
[000105f6] 611e                      bsr.s      $00010616
[000105f8] 225f                      movea.l    (a7)+,a1
[000105fa] 4fef 0010                 lea.l      16(a7),a7
[000105fe] 5289                      addq.l     #1,a1
[00010600] 204f                      movea.l    a7,a0
[00010602] 6112                      bsr.s      $00010616
[00010604] 4fef 0010                 lea.l      16(a7),a7
[00010608] 205f                      movea.l    (a7)+,a0
[0001060a] 41e8 0030                 lea.l      48(a0),a0
[0001060e] 220e                      move.l     a6,d1
[00010610] 5381                      subq.l     #1,d1
[00010612] 6aba                      bpl.s      $000105CE
[00010614] 4e75                      rts
[00010616] 700f                      moveq.l    #15,d0
[00010618] 4840                      swap       d0
[0001061a] 3e18                      move.w     (a0)+,d7
[0001061c] 3c18                      move.w     (a0)+,d6
[0001061e] 3a18                      move.w     (a0)+,d5
[00010620] 3818                      move.w     (a0)+,d4
[00010622] 3618                      move.w     (a0)+,d3
[00010624] 3418                      move.w     (a0)+,d2
[00010626] 3218                      move.w     (a0)+,d1
[00010628] 3018                      move.w     (a0)+,d0
[0001062a] 4840                      swap       d0
[0001062c] 4847                      swap       d7
[0001062e] 4840                      swap       d0
[00010630] d040                      add.w      d0,d0
[00010632] df07                      addx.b     d7,d7
[00010634] d241                      add.w      d1,d1
[00010636] df07                      addx.b     d7,d7
[00010638] d442                      add.w      d2,d2
[0001063a] df07                      addx.b     d7,d7
[0001063c] d643                      add.w      d3,d3
[0001063e] df07                      addx.b     d7,d7
[00010640] d844                      add.w      d4,d4
[00010642] df07                      addx.b     d7,d7
[00010644] da45                      add.w      d5,d5
[00010646] df07                      addx.b     d7,d7
[00010648] dc46                      add.w      d6,d6
[0001064a] df07                      addx.b     d7,d7
[0001064c] 4847                      swap       d7
[0001064e] de47                      add.w      d7,d7
[00010650] 4847                      swap       d7
[00010652] df07                      addx.b     d7,d7
[00010654] 1287                      move.b     d7,(a1)
[00010656] 5689                      addq.l     #3,a1
[00010658] 4840                      swap       d0
[0001065a] 51c8 ffd2                 dbf        d0,$0001062E
[0001065e] 4e75                      rts
[00010660] 700f                      moveq.l    #15,d0
[00010662] 4840                      swap       d0
[00010664] 4847                      swap       d7
[00010666] 1e10                      move.b     (a0),d7
[00010668] 5688                      addq.l     #3,a0
[0001066a] de07                      add.b      d7,d7
[0001066c] d140                      addx.w     d0,d0
[0001066e] de07                      add.b      d7,d7
[00010670] d341                      addx.w     d1,d1
[00010672] de07                      add.b      d7,d7
[00010674] d542                      addx.w     d2,d2
[00010676] de07                      add.b      d7,d7
[00010678] d743                      addx.w     d3,d3
[0001067a] de07                      add.b      d7,d7
[0001067c] d944                      addx.w     d4,d4
[0001067e] de07                      add.b      d7,d7
[00010680] db45                      addx.w     d5,d5
[00010682] de07                      add.b      d7,d7
[00010684] dd46                      addx.w     d6,d6
[00010686] de07                      add.b      d7,d7
[00010688] 4847                      swap       d7
[0001068a] df47                      addx.w     d7,d7
[0001068c] 4840                      swap       d0
[0001068e] 51c8 ffd2                 dbf        d0,$00010662
[00010692] 4840                      swap       d0
[00010694] 32c7                      move.w     d7,(a1)+
[00010696] 32c6                      move.w     d6,(a1)+
[00010698] 32c5                      move.w     d5,(a1)+
[0001069a] 32c4                      move.w     d4,(a1)+
[0001069c] 32c3                      move.w     d3,(a1)+
[0001069e] 32c2                      move.w     d2,(a1)+
[000106a0] 32c1                      move.w     d1,(a1)+
[000106a2] 32c0                      move.w     d0,(a1)+
[000106a4] 4e75                      rts
[000106a6] 48e7 40c0                 movem.l    d1/a0-a1,-(a7)
[000106aa] 2c41                      movea.l    d1,a6
[000106ac] 41e8 0030                 lea.l      48(a0),a0
[000106b0] 2f08                      move.l     a0,-(a7)
[000106b2] 2f20                      move.l     -(a0),-(a7)
[000106b4] 2f20                      move.l     -(a0),-(a7)
[000106b6] 2f20                      move.l     -(a0),-(a7)
[000106b8] 2f20                      move.l     -(a0),-(a7)
[000106ba] 2f20                      move.l     -(a0),-(a7)
[000106bc] 2f20                      move.l     -(a0),-(a7)
[000106be] 2f20                      move.l     -(a0),-(a7)
[000106c0] 2f20                      move.l     -(a0),-(a7)
[000106c2] 2f20                      move.l     -(a0),-(a7)
[000106c4] 2f20                      move.l     -(a0),-(a7)
[000106c6] 2f20                      move.l     -(a0),-(a7)
[000106c8] 2f20                      move.l     -(a0),-(a7)
[000106ca] 6194                      bsr.s      $00010660
[000106cc] 204f                      movea.l    a7,a0
[000106ce] 5288                      addq.l     #1,a0
[000106d0] 618e                      bsr.s      $00010660
[000106d2] 204f                      movea.l    a7,a0
[000106d4] 5488                      addq.l     #2,a0
[000106d6] 6188                      bsr.s      $00010660
[000106d8] 4fef 0030                 lea.l      48(a7),a7
[000106dc] 205f                      movea.l    (a7)+,a0
[000106de] 220e                      move.l     a6,d1
[000106e0] 5381                      subq.l     #1,d1
[000106e2] 6ac6                      bpl.s      $000106AA
[000106e4] 4cdf 0310                 movem.l    (a7)+,d4/a0-a1
[000106e8] 7017                      moveq.l    #23,d0
[000106ea] 5384                      subq.l     #1,d4
[000106ec] 6b2a                      bmi.s      $00010718
[000106ee] 7400                      moveq.l    #0,d2
[000106f0] 2204                      move.l     d4,d1
[000106f2] d1c0                      adda.l     d0,a0
[000106f4] 41f0 0802                 lea.l      2(a0,d0.l),a0
[000106f8] 3a10                      move.w     (a0),d5
[000106fa] 2248                      movea.l    a0,a1
[000106fc] 2448                      movea.l    a0,a2
[000106fe] d480                      add.l      d0,d2
[00010700] 2602                      move.l     d2,d3
[00010702] 6004                      bra.s      $00010708
[00010704] 2449                      movea.l    a1,a2
[00010706] 34a1                      move.w     -(a1),(a2)
[00010708] 5383                      subq.l     #1,d3
[0001070a] 6af8                      bpl.s      $00010704
[0001070c] 3285                      move.w     d5,(a1)
[0001070e] 5381                      subq.l     #1,d1
[00010710] 6ae0                      bpl.s      $000106F2
[00010712] 204a                      movea.l    a2,a0
[00010714] 5380                      subq.l     #1,d0
[00010716] 6ad6                      bpl.s      $000106EE
[00010718] 4e75                      rts
[0001071a] d080                      add.l      d0,d0
[0001071c] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010720] 611e                      bsr.s      $00010740
[00010722] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010726] 5288                      addq.l     #1,a0
[00010728] 2400                      move.l     d0,d2
[0001072a] e78a                      lsl.l      #3,d2
[0001072c] d3c2                      adda.l     d2,a1
[0001072e] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010732] 610c                      bsr.s      $00010740
[00010734] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010738] 5288                      addq.l     #1,a0
[0001073a] 2400                      move.l     d0,d2
[0001073c] e78a                      lsl.l      #3,d2
[0001073e] d3c2                      adda.l     d2,a1
[00010740] 45f1 0800                 lea.l      0(a1,d0.l),a2
[00010744] 47f2 0800                 lea.l      0(a2,d0.l),a3
[00010748] 49f3 0800                 lea.l      0(a3,d0.l),a4
[0001074c] e588                      lsl.l      #2,d0
[0001074e] 2a40                      movea.l    d0,a5
[00010750] 2c41                      movea.l    d1,a6
[00010752] 700f                      moveq.l    #15,d0
[00010754] 4840                      swap       d0
[00010756] 4847                      swap       d7
[00010758] 1e10                      move.b     (a0),d7
[0001075a] 5688                      addq.l     #3,a0
[0001075c] de07                      add.b      d7,d7
[0001075e] d140                      addx.w     d0,d0
[00010760] de07                      add.b      d7,d7
[00010762] d341                      addx.w     d1,d1
[00010764] de07                      add.b      d7,d7
[00010766] d542                      addx.w     d2,d2
[00010768] de07                      add.b      d7,d7
[0001076a] d743                      addx.w     d3,d3
[0001076c] de07                      add.b      d7,d7
[0001076e] d944                      addx.w     d4,d4
[00010770] de07                      add.b      d7,d7
[00010772] db45                      addx.w     d5,d5
[00010774] de07                      add.b      d7,d7
[00010776] dd46                      addx.w     d6,d6
[00010778] de07                      add.b      d7,d7
[0001077a] 4847                      swap       d7
[0001077c] df47                      addx.w     d7,d7
[0001077e] 4840                      swap       d0
[00010780] 51c8 ffd2                 dbf        d0,$00010754
[00010784] 4840                      swap       d0
[00010786] 32c7                      move.w     d7,(a1)+
[00010788] 34c6                      move.w     d6,(a2)+
[0001078a] 36c5                      move.w     d5,(a3)+
[0001078c] 38c4                      move.w     d4,(a4)+
[0001078e] 3383 d8fe                 move.w     d3,-2(a1,a5.l)
[00010792] 3582 d8fe                 move.w     d2,-2(a2,a5.l)
[00010796] 3781 d8fe                 move.w     d1,-2(a3,a5.l)
[0001079a] 3980 d8fe                 move.w     d0,-2(a4,a5.l)
[0001079e] 220e                      move.l     a6,d1
[000107a0] 5381                      subq.l     #1,d1
[000107a2] 6aac                      bpl.s      $00010750
[000107a4] 4e75                      rts
[000107a6] d080                      add.l      d0,d0
[000107a8] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[000107ac] 611e                      bsr.s      $000107CC
[000107ae] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[000107b2] 2400                      move.l     d0,d2
[000107b4] e78a                      lsl.l      #3,d2
[000107b6] d1c2                      adda.l     d2,a0
[000107b8] 5289                      addq.l     #1,a1
[000107ba] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[000107be] 610c                      bsr.s      $000107CC
[000107c0] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[000107c4] 2400                      move.l     d0,d2
[000107c6] e78a                      lsl.l      #3,d2
[000107c8] d1c2                      adda.l     d2,a0
[000107ca] 5289                      addq.l     #1,a1
[000107cc] 45f0 0800                 lea.l      0(a0,d0.l),a2
[000107d0] 47f2 0800                 lea.l      0(a2,d0.l),a3
[000107d4] 49f3 0800                 lea.l      0(a3,d0.l),a4
[000107d8] e588                      lsl.l      #2,d0
[000107da] 2a40                      movea.l    d0,a5
[000107dc] 2c41                      movea.l    d1,a6
[000107de] 700f                      moveq.l    #15,d0
[000107e0] 4840                      swap       d0
[000107e2] 3e18                      move.w     (a0)+,d7
[000107e4] 3c1a                      move.w     (a2)+,d6
[000107e6] 3a1b                      move.w     (a3)+,d5
[000107e8] 381c                      move.w     (a4)+,d4
[000107ea] 3630 d8fe                 move.w     -2(a0,a5.l),d3
[000107ee] 3432 d8fe                 move.w     -2(a2,a5.l),d2
[000107f2] 3233 d8fe                 move.w     -2(a3,a5.l),d1
[000107f6] 3034 d8fe                 move.w     -2(a4,a5.l),d0
[000107fa] 4840                      swap       d0
[000107fc] 4847                      swap       d7
[000107fe] 4840                      swap       d0
[00010800] d040                      add.w      d0,d0
[00010802] df07                      addx.b     d7,d7
[00010804] d241                      add.w      d1,d1
[00010806] df07                      addx.b     d7,d7
[00010808] d442                      add.w      d2,d2
[0001080a] df07                      addx.b     d7,d7
[0001080c] d643                      add.w      d3,d3
[0001080e] df07                      addx.b     d7,d7
[00010810] d844                      add.w      d4,d4
[00010812] df07                      addx.b     d7,d7
[00010814] da45                      add.w      d5,d5
[00010816] df07                      addx.b     d7,d7
[00010818] dc46                      add.w      d6,d6
[0001081a] df07                      addx.b     d7,d7
[0001081c] 4847                      swap       d7
[0001081e] de47                      add.w      d7,d7
[00010820] 4847                      swap       d7
[00010822] df07                      addx.b     d7,d7
[00010824] 1287                      move.b     d7,(a1)
[00010826] 5689                      addq.l     #3,a1
[00010828] 4840                      swap       d0
[0001082a] 51c8 ffd2                 dbf        d0,$000107FE
[0001082e] 220e                      move.l     a6,d1
[00010830] 5381                      subq.l     #1,d1
[00010832] 6aa8                      bpl.s      $000107DC
[00010834] 4e75                      rts
[00010836] b3c8                      cmpa.l     a0,a1
[00010838] 670e                      beq.s      $00010848
[0001083a] e289                      lsr.l      #1,d1
[0001083c] 6504                      bcs.s      $00010842
[0001083e] 32d8                      move.w     (a0)+,(a1)+
[00010840] 6002                      bra.s      $00010844
[00010842] 22d8                      move.l     (a0)+,(a1)+
[00010844] 5381                      subq.l     #1,d1
[00010846] 6afa                      bpl.s      $00010842
[00010848] 2c5f                      movea.l    (a7)+,a6
[0001084a] 4e75                      rts
[0001084c] 4a6e 01b2                 tst.w      434(a6)
[00010850] 670a                      beq.s      $0001085C
[00010852] 206e 01ae                 movea.l    430(a6),a0
[00010856] c3ee 01b2                 muls.w     434(a6),d1
[0001085a] 6008                      bra.s      $00010864
[0001085c] 2078 044e                 movea.l    ($0000044E).w,a0
[00010860] c3f8 206e                 muls.w     ($0000206E).w,d1
[00010864] d1c1                      adda.l     d1,a0
[00010866] 3200                      move.w     d0,d1
[00010868] d040                      add.w      d0,d0
[0001086a] d041                      add.w      d1,d0
[0001086c] d0c0                      adda.w     d0,a0
[0001086e] 7000                      moveq.l    #0,d0
[00010870] 1018                      move.b     (a0)+,d0
[00010872] 4840                      swap       d0
[00010874] 1018                      move.b     (a0)+,d0
[00010876] e148                      lsl.w      #8,d0
[00010878] 1018                      move.b     (a0)+,d0
[0001087a] 4e75                      rts
[0001087c] 4a6e 01b2                 tst.w      434(a6)
[00010880] 670a                      beq.s      $0001088C
[00010882] 206e 01ae                 movea.l    430(a6),a0
[00010886] c3ee 01b2                 muls.w     434(a6),d1
[0001088a] 6008                      bra.s      $00010894
[0001088c] 2078 044e                 movea.l    ($0000044E).w,a0
[00010890] c3f8 206e                 muls.w     ($0000206E).w,d1
[00010894] d1c1                      adda.l     d1,a0
[00010896] 3200                      move.w     d0,d1
[00010898] d040                      add.w      d0,d0
[0001089a] d041                      add.w      d1,d0
[0001089c] d0c0                      adda.w     d0,a0
[0001089e] 4842                      swap       d2
[000108a0] 10c2                      move.b     d2,(a0)+
[000108a2] e19a                      rol.l      #8,d2
[000108a4] 10c2                      move.b     d2,(a0)+
[000108a6] e19a                      rol.l      #8,d2
[000108a8] 10c2                      move.b     d2,(a0)+
[000108aa] 4e75                      rts
[000108ac] 2278 044e                 movea.l    ($0000044E).w,a1
[000108b0] 3678 206e                 movea.w    ($0000206E).w,a3
[000108b4] 4a6e 01b2                 tst.w      434(a6)
[000108b8] 6710                      beq.s      $000108CA
[000108ba] 226e 01ae                 movea.l    430(a6),a1
[000108be] 366e 01b2                 movea.w    434(a6),a3
[000108c2] 946e 01b6                 sub.w      438(a6),d2
[000108c6] 966e 01b8                 sub.w      440(a6),d3
[000108ca] 3d6e 003c 01ee            move.w     60(a6),494(a6)
[000108d0] 426e 01c8                 clr.w      456(a6)
[000108d4] 3d6e 01b4 01dc            move.w     436(a6),476(a6)
[000108da] 6000 0ee6                 bra        $000117C2
[000108de] 4a6e 00ca                 tst.w      202(a6)
[000108e2] 675c                      beq.s      $00010940
[000108e4] 2f08                      move.l     a0,-(a7)
[000108e6] 206e 00c6                 movea.l    198(a6),a0
[000108ea] 780f                      moveq.l    #15,d4
[000108ec] c841                      and.w      d1,d4
[000108ee] ed4c                      lsl.w      #6,d4
[000108f0] d0c4                      adda.w     d4,a0
[000108f2] 3838 206e                 move.w     ($0000206E).w,d4
[000108f6] 2278 044e                 movea.l    ($0000044E).w,a1
[000108fa] 4a6e 01b2                 tst.w      434(a6)
[000108fe] 6708                      beq.s      $00010908
[00010900] 382e 01b2                 move.w     434(a6),d4
[00010904] 226e 01ae                 movea.l    430(a6),a1
[00010908] 9440                      sub.w      d0,d2
[0001090a] d040                      add.w      d0,d0
[0001090c] d040                      add.w      d0,d0
[0001090e] c2c4                      mulu.w     d4,d1
[00010910] 48c0                      ext.l      d0
[00010912] d280                      add.l      d0,d1
[00010914] 7e40                      moveq.l    #64,d7
[00010916] 7c0f                      moveq.l    #15,d6
[00010918] b446                      cmp.w      d6,d2
[0001091a] 6c02                      bge.s      $0001091E
[0001091c] 3c02                      move.w     d2,d6
[0001091e] 703f                      moveq.l    #63,d0
[00010920] c041                      and.w      d1,d0
[00010922] 2a30 0000                 move.l     0(a0,d0.w),d5
[00010926] 3802                      move.w     d2,d4
[00010928] e84c                      lsr.w      #4,d4
[0001092a] 2241                      movea.l    d1,a1
[0001092c] 2285                      move.l     d5,(a1)
[0001092e] d2c7                      adda.w     d7,a1
[00010930] 51cc fffa                 dbf        d4,$0001092C
[00010934] 5881                      addq.l     #4,d1
[00010936] 5342                      subq.w     #1,d2
[00010938] 51ce ffe4                 dbf        d6,$0001091E
[0001093c] 205f                      movea.l    (a7)+,a0
[0001093e] 4e75                      rts
[00010940] 226e 00c6                 movea.l    198(a6),a1
[00010944] 780f                      moveq.l    #15,d4
[00010946] c841                      and.w      d1,d4
[00010948] d844                      add.w      d4,d4
[0001094a] 3e31 4000                 move.w     0(a1,d4.w),d7
[0001094e] 780f                      moveq.l    #15,d4
[00010950] c840                      and.w      d0,d4
[00010952] e97f                      rol.w      d4,d7
[00010954] 2a2e 00f2                 move.l     242(a6),d5
[00010958] 4a6e 01b2                 tst.w      434(a6)
[0001095c] 671e                      beq.s      $0001097C
[0001095e] 226e 01ae                 movea.l    430(a6),a1
[00010962] c3ee 01b2                 muls.w     434(a6),d1
[00010966] 601c                      bra.s      $00010984
[00010968] 2a2e 00f2                 move.l     242(a6),d5
[0001096c] 4a6e 01b2                 tst.w      434(a6)
[00010970] 670a                      beq.s      $0001097C
[00010972] 226e 01ae                 movea.l    430(a6),a1
[00010976] c3ee 01b2                 muls.w     434(a6),d1
[0001097a] 6008                      bra.s      $00010984
[0001097c] 2278 044e                 movea.l    ($0000044E).w,a1
[00010980] c3f8 206e                 muls.w     ($0000206E).w,d1
[00010984] 3800                      move.w     d0,d4
[00010986] d844                      add.w      d4,d4
[00010988] d840                      add.w      d0,d4
[0001098a] d3c1                      adda.l     d1,a1
[0001098c] d2c4                      adda.w     d4,a1
[0001098e] 9440                      sub.w      d0,d2
[00010990] 3c2e 003c                 move.w     60(a6),d6
[00010994] dc46                      add.w      d6,d6
[00010996] 3c3b 6008                 move.w     $000109A0(pc,d6.w),d6
[0001099a] 4efb 6004                 jmp        $000109A0(pc,d6.w)
[0001099e] 4e75                      rts
J1:
[000109a0] 0008                      dc.w $0008   ; $000109a8-J1
[000109a2] 00ac                      dc.w $00ac   ; $00010a4c-J1
[000109a4] 012c                      dc.w $012c   ; $00010acc-J1
[000109a6] 00a4                      dc.w $00a4   ; $00010a44-J1
[000109a8] be7c ffff                 cmp.w      #$FFFF,d7
[000109ac] 6754                      beq.s      $00010A02
[000109ae] 2f0b                      move.l     a3,-(a7)
[000109b0] 3f03                      move.w     d3,-(a7)
[000109b2] 722d                      moveq.l    #45,d1
[000109b4] 700f                      moveq.l    #15,d0
[000109b6] b440                      cmp.w      d0,d2
[000109b8] 6c02                      bge.s      $000109BC
[000109ba] 3002                      move.w     d2,d0
[000109bc] 2a2e 00f2                 move.l     242(a6),d5
[000109c0] de47                      add.w      d7,d7
[000109c2] 6504                      bcs.s      $000109C8
[000109c4] 2a2e 00f6                 move.l     246(a6),d5
[000109c8] 3802                      move.w     d2,d4
[000109ca] e84c                      lsr.w      #4,d4
[000109cc] 2649                      movea.l    a1,a3
[000109ce] 3c09                      move.w     a1,d6
[000109d0] cc7c 0001                 and.w      #$0001,d6
[000109d4] 6610                      bne.s      $000109E6
[000109d6] 1c05                      move.b     d5,d6
[000109d8] e08d                      lsr.l      #8,d5
[000109da] 36c5                      move.w     d5,(a3)+
[000109dc] 16c6                      move.b     d6,(a3)+
[000109de] d6c1                      adda.w     d1,a3
[000109e0] 51cc fff8                 dbf        d4,$000109DA
[000109e4] 600e                      bra.s      $000109F4
[000109e6] 3c05                      move.w     d5,d6
[000109e8] 4845                      swap       d5
[000109ea] 16c5                      move.b     d5,(a3)+
[000109ec] 36c6                      move.w     d6,(a3)+
[000109ee] d6c1                      adda.w     d1,a3
[000109f0] 51cc fff8                 dbf        d4,$000109EA
[000109f4] 5689                      addq.l     #3,a1
[000109f6] 5342                      subq.w     #1,d2
[000109f8] 51c8 ffc2                 dbf        d0,$000109BC
[000109fc] 361f                      move.w     (a7)+,d3
[000109fe] 265f                      movea.l    (a7)+,a3
[00010a00] 4e75                      rts
[00010a02] 2a2e 00f2                 move.l     242(a6),d5
[00010a06] 7001                      moveq.l    #1,d0
[00010a08] 3c05                      move.w     d5,d6
[00010a0a] 4845                      swap       d5
[00010a0c] 3209                      move.w     a1,d1
[00010a0e] c240                      and.w      d0,d1
[00010a10] 670a                      beq.s      $00010A1C
[00010a12] 12c5                      move.b     d5,(a1)+
[00010a14] 32c6                      move.w     d6,(a1)+
[00010a16] 51ca 0004                 dbf        d2,$00010A1C
[00010a1a] 4e75                      rts
[00010a1c] 1205                      move.b     d5,d1
[00010a1e] e09d                      ror.l      #8,d5
[00010a20] 1a01                      move.b     d1,d5
[00010a22] e06a                      lsr.w      d0,d2
[00010a24] 640a                      bcc.s      $00010A30
[00010a26] 22c5                      move.l     d5,(a1)+
[00010a28] 32c6                      move.w     d6,(a1)+
[00010a2a] 51ca fffa                 dbf        d2,$00010A26
[00010a2e] 4e75                      rts
[00010a30] 5342                      subq.w     #1,d2
[00010a32] 6b08                      bmi.s      $00010A3C
[00010a34] 22c5                      move.l     d5,(a1)+
[00010a36] 32c6                      move.w     d6,(a1)+
[00010a38] 51ca fffa                 dbf        d2,$00010A34
[00010a3c] 4845                      swap       d5
[00010a3e] 32c5                      move.w     d5,(a1)+
[00010a40] 12c6                      move.b     d6,(a1)+
[00010a42] 4e75                      rts
[00010a44] 4647                      not.w      d7
[00010a46] 2a2e 00f6                 move.l     246(a6),d5
[00010a4a] 6004                      bra.s      $00010A50
[00010a4c] 2a2e 00f2                 move.l     242(a6),d5
[00010a50] be7c ffff                 cmp.w      #$FFFF,d7
[00010a54] 67b0                      beq.s      $00010A06
[00010a56] 2f0b                      move.l     a3,-(a7)
[00010a58] 722d                      moveq.l    #45,d1
[00010a5a] 3c05                      move.w     d5,d6
[00010a5c] 4845                      swap       d5
[00010a5e] 700f                      moveq.l    #15,d0
[00010a60] b440                      cmp.w      d0,d2
[00010a62] 6c02                      bge.s      $00010A66
[00010a64] 3002                      move.w     d2,d0
[00010a66] de47                      add.w      d7,d7
[00010a68] 642c                      bcc.s      $00010A96
[00010a6a] 2649                      movea.l    a1,a3
[00010a6c] 3809                      move.w     a1,d4
[00010a6e] c87c 0001                 and.w      #$0001,d4
[00010a72] 6714                      beq.s      $00010A88
[00010a74] 3802                      move.w     d2,d4
[00010a76] e84c                      lsr.w      #4,d4
[00010a78] e19d                      rol.l      #8,d5
[00010a7a] 36c5                      move.w     d5,(a3)+
[00010a7c] 16c6                      move.b     d6,(a3)+
[00010a7e] d6c1                      adda.w     d1,a3
[00010a80] 51cc fff8                 dbf        d4,$00010A7A
[00010a84] e09d                      ror.l      #8,d5
[00010a86] 600e                      bra.s      $00010A96
[00010a88] 3802                      move.w     d2,d4
[00010a8a] e84c                      lsr.w      #4,d4
[00010a8c] 16c5                      move.b     d5,(a3)+
[00010a8e] 36c6                      move.w     d6,(a3)+
[00010a90] d6c1                      adda.w     d1,a3
[00010a92] 51cc fff8                 dbf        d4,$00010A8C
[00010a96] 5689                      addq.l     #3,a1
[00010a98] 5342                      subq.w     #1,d2
[00010a9a] 51c8 ffca                 dbf        d0,$00010A66
[00010a9e] 265f                      movea.l    (a7)+,a3
[00010aa0] 4e75                      rts
[00010aa2] 5689                      addq.l     #3,a1
[00010aa4] 51ca 0004                 dbf        d2,$00010AAA
[00010aa8] 4e75                      rts
[00010aaa] e24a                      lsr.w      #1,d2
[00010aac] 3009                      move.w     a1,d0
[00010aae] c07c 0001                 and.w      #$0001,d0
[00010ab2] 660c                      bne.s      $00010AC0
[00010ab4] 4659                      not.w      (a1)+
[00010ab6] 4619                      not.b      (a1)+
[00010ab8] 5689                      addq.l     #3,a1
[00010aba] 51ca fff8                 dbf        d2,$00010AB4
[00010abe] 4e75                      rts
[00010ac0] 4619                      not.b      (a1)+
[00010ac2] 4659                      not.w      (a1)+
[00010ac4] 5689                      addq.l     #3,a1
[00010ac6] 51ca fff8                 dbf        d2,$00010AC0
[00010aca] 4e75                      rts
[00010acc] be7c aaaa                 cmp.w      #$AAAA,d7
[00010ad0] 67d8                      beq.s      $00010AAA
[00010ad2] be7c 5555                 cmp.w      #$5555,d7
[00010ad6] 67ca                      beq.s      $00010AA2
[00010ad8] 2f0b                      move.l     a3,-(a7)
[00010ada] 722d                      moveq.l    #45,d1
[00010adc] 700f                      moveq.l    #15,d0
[00010ade] b440                      cmp.w      d0,d2
[00010ae0] 6c02                      bge.s      $00010AE4
[00010ae2] 3002                      move.w     d2,d0
[00010ae4] de47                      add.w      d7,d7
[00010ae6] 6424                      bcc.s      $00010B0C
[00010ae8] 3802                      move.w     d2,d4
[00010aea] e84c                      lsr.w      #4,d4
[00010aec] 2649                      movea.l    a1,a3
[00010aee] 3c09                      move.w     a1,d6
[00010af0] cc7c 0001                 and.w      #$0001,d6
[00010af4] 660c                      bne.s      $00010B02
[00010af6] 465b                      not.w      (a3)+
[00010af8] 461b                      not.b      (a3)+
[00010afa] d6c1                      adda.w     d1,a3
[00010afc] 51cc fff8                 dbf        d4,$00010AF6
[00010b00] 600a                      bra.s      $00010B0C
[00010b02] 461b                      not.b      (a3)+
[00010b04] 465b                      not.w      (a3)+
[00010b06] d6c1                      adda.w     d1,a3
[00010b08] 51cc fff8                 dbf        d4,$00010B02
[00010b0c] 5689                      addq.l     #3,a1
[00010b0e] 5342                      subq.w     #1,d2
[00010b10] 51c8 ffd2                 dbf        d0,$00010AE4
[00010b14] 265f                      movea.l    (a7)+,a3
[00010b16] 4e75                      rts
[00010b18] 7a00                      moveq.l    #0,d5
[00010b1a] 3a2e 01b2                 move.w     434(a6),d5
[00010b1e] 670e                      beq.s      $00010B2E
[00010b20] 226e 01ae                 movea.l    430(a6),a1
[00010b24] 906e 01b6                 sub.w      438(a6),d0
[00010b28] 926e 01b8                 sub.w      440(a6),d1
[00010b2c] 6008                      bra.s      $00010B36
[00010b2e] 2278 044e                 movea.l    ($0000044E).w,a1
[00010b32] 3a38 206e                 move.w     ($0000206E).w,d5
[00010b36] c3c5                      muls.w     d5,d1
[00010b38] d3c1                      adda.l     d1,a1
[00010b3a] 3200                      move.w     d0,d1
[00010b3c] d040                      add.w      d0,d0
[00010b3e] d041                      add.w      d1,d0
[00010b40] d2c0                      adda.w     d0,a1
[00010b42] 3c2e 003c                 move.w     60(a6),d6
[00010b46] dc46                      add.w      d6,d6
[00010b48] c07c 0001                 and.w      #$0001,d0
[00010b4c] dc40                      add.w      d0,d6
[00010b4e] dc46                      add.w      d6,d6
[00010b50] 3c3b 6006                 move.w     $00010B58(pc,d6.w),d6
[00010b54] 4efb 6002                 jmp        $00010B58(pc,d6.w)
J2:
[00010b58] 0010                      dc.w $0010   ; $00010b68-J2
[00010b5a] 0068                      dc.w $0068   ; $00010bc0-J2
[00010b5c] 00c8                      dc.w $00c8   ; $00010c20-J2
[00010b5e] 0108                      dc.w $0108   ; $00010c60-J2
[00010b60] 015a                      dc.w $015a   ; $00010cb2-J2
[00010b62] 01b0                      dc.w $01b0   ; $00010d08-J2
[00010b64] 00c0                      dc.w $00c0   ; $00010c18-J2
[00010b66] 0100                      dc.w $0100   ; $00010c58-J2
[00010b68] be7c ffff                 cmp.w      #$FFFF,d7
[00010b6c] 673c                      beq.s      $00010BAA
[00010b6e] 3f05                      move.w     d5,-(a7)
[00010b70] e98d                      lsl.l      #4,d5
[00010b72] 5785                      subq.l     #3,d5
[00010b74] 700f                      moveq.l    #15,d0
[00010b76] b440                      cmp.w      d0,d2
[00010b78] 6c02                      bge.s      $00010B7C
[00010b7a] 3002                      move.w     d2,d0
[00010b7c] 2f09                      move.l     a1,-(a7)
[00010b7e] 262e 00f2                 move.l     242(a6),d3
[00010b82] de47                      add.w      d7,d7
[00010b84] 6504                      bcs.s      $00010B8A
[00010b86] 262e 00f6                 move.l     246(a6),d3
[00010b8a] 1c03                      move.b     d3,d6
[00010b8c] e08b                      lsr.l      #8,d3
[00010b8e] 3202                      move.w     d2,d1
[00010b90] e849                      lsr.w      #4,d1
[00010b92] 32c3                      move.w     d3,(a1)+
[00010b94] 12c6                      move.b     d6,(a1)+
[00010b96] d3c5                      adda.l     d5,a1
[00010b98] 51c9 fff8                 dbf        d1,$00010B92
[00010b9c] 225f                      movea.l    (a7)+,a1
[00010b9e] d2d7                      adda.w     (a7),a1
[00010ba0] 5342                      subq.w     #1,d2
[00010ba2] 51c8 ffd8                 dbf        d0,$00010B7C
[00010ba6] 548f                      addq.l     #2,a7
[00010ba8] 4e75                      rts
[00010baa] 282e 00f2                 move.l     242(a6),d4
[00010bae] 5745                      subq.w     #3,d5
[00010bb0] 1e04                      move.b     d4,d7
[00010bb2] e08c                      lsr.l      #8,d4
[00010bb4] 32c4                      move.w     d4,(a1)+
[00010bb6] 12c7                      move.b     d7,(a1)+
[00010bb8] d2c5                      adda.w     d5,a1
[00010bba] 51ca fff8                 dbf        d2,$00010BB4
[00010bbe] 4e75                      rts
[00010bc0] be7c ffff                 cmp.w      #$FFFF,d7
[00010bc4] 673c                      beq.s      $00010C02
[00010bc6] 3f05                      move.w     d5,-(a7)
[00010bc8] e98d                      lsl.l      #4,d5
[00010bca] 5785                      subq.l     #3,d5
[00010bcc] 700f                      moveq.l    #15,d0
[00010bce] b440                      cmp.w      d0,d2
[00010bd0] 6c02                      bge.s      $00010BD4
[00010bd2] 3002                      move.w     d2,d0
[00010bd4] 2f09                      move.l     a1,-(a7)
[00010bd6] 262e 00f2                 move.l     242(a6),d3
[00010bda] de47                      add.w      d7,d7
[00010bdc] 6504                      bcs.s      $00010BE2
[00010bde] 262e 00f6                 move.l     246(a6),d3
[00010be2] 3c03                      move.w     d3,d6
[00010be4] 4843                      swap       d3
[00010be6] 3202                      move.w     d2,d1
[00010be8] e849                      lsr.w      #4,d1
[00010bea] 12c3                      move.b     d3,(a1)+
[00010bec] 32c6                      move.w     d6,(a1)+
[00010bee] d3c5                      adda.l     d5,a1
[00010bf0] 51c9 fff8                 dbf        d1,$00010BEA
[00010bf4] 225f                      movea.l    (a7)+,a1
[00010bf6] d2d7                      adda.w     (a7),a1
[00010bf8] 5342                      subq.w     #1,d2
[00010bfa] 51c8 ffd8                 dbf        d0,$00010BD4
[00010bfe] 548f                      addq.l     #2,a7
[00010c00] 4e75                      rts
[00010c02] 282e 00f2                 move.l     242(a6),d4
[00010c06] 5745                      subq.w     #3,d5
[00010c08] 3e04                      move.w     d4,d7
[00010c0a] 4844                      swap       d4
[00010c0c] 12c4                      move.b     d4,(a1)+
[00010c0e] 32c7                      move.w     d7,(a1)+
[00010c10] d2c5                      adda.w     d5,a1
[00010c12] 51ca fff8                 dbf        d2,$00010C0C
[00010c16] 4e75                      rts
[00010c18] 4647                      not.w      d7
[00010c1a] 282e 00f6                 move.l     246(a6),d4
[00010c1e] 6004                      bra.s      $00010C24
[00010c20] 282e 00f2                 move.l     242(a6),d4
[00010c24] 3f05                      move.w     d5,-(a7)
[00010c26] e98d                      lsl.l      #4,d5
[00010c28] 5785                      subq.l     #3,d5
[00010c2a] 1c04                      move.b     d4,d6
[00010c2c] e08c                      lsr.l      #8,d4
[00010c2e] 700f                      moveq.l    #15,d0
[00010c30] b440                      cmp.w      d0,d2
[00010c32] 6c02                      bge.s      $00010C36
[00010c34] 3002                      move.w     d2,d0
[00010c36] 2609                      move.l     a1,d3
[00010c38] de47                      add.w      d7,d7
[00010c3a] 640e                      bcc.s      $00010C4A
[00010c3c] 3202                      move.w     d2,d1
[00010c3e] e849                      lsr.w      #4,d1
[00010c40] 32c4                      move.w     d4,(a1)+
[00010c42] 12c6                      move.b     d6,(a1)+
[00010c44] d3c5                      adda.l     d5,a1
[00010c46] 51c9 fff8                 dbf        d1,$00010C40
[00010c4a] 2243                      movea.l    d3,a1
[00010c4c] d2d7                      adda.w     (a7),a1
[00010c4e] 5342                      subq.w     #1,d2
[00010c50] 51c8 ffe4                 dbf        d0,$00010C36
[00010c54] 548f                      addq.l     #2,a7
[00010c56] 4e75                      rts
[00010c58] 4647                      not.w      d7
[00010c5a] 282e 00f6                 move.l     246(a6),d4
[00010c5e] 6004                      bra.s      $00010C64
[00010c60] 282e 00f2                 move.l     242(a6),d4
[00010c64] 3f05                      move.w     d5,-(a7)
[00010c66] e98d                      lsl.l      #4,d5
[00010c68] 5785                      subq.l     #3,d5
[00010c6a] 3c04                      move.w     d4,d6
[00010c6c] 4844                      swap       d4
[00010c6e] 700f                      moveq.l    #15,d0
[00010c70] b440                      cmp.w      d0,d2
[00010c72] 6c02                      bge.s      $00010C76
[00010c74] 3002                      move.w     d2,d0
[00010c76] 2609                      move.l     a1,d3
[00010c78] de47                      add.w      d7,d7
[00010c7a] 640e                      bcc.s      $00010C8A
[00010c7c] 3202                      move.w     d2,d1
[00010c7e] e849                      lsr.w      #4,d1
[00010c80] 12c4                      move.b     d4,(a1)+
[00010c82] 32c6                      move.w     d6,(a1)+
[00010c84] d3c5                      adda.l     d5,a1
[00010c86] 51c9 fff8                 dbf        d1,$00010C80
[00010c8a] 2243                      movea.l    d3,a1
[00010c8c] d2d7                      adda.w     (a7),a1
[00010c8e] 5342                      subq.w     #1,d2
[00010c90] 51c8 ffe4                 dbf        d0,$00010C76
[00010c94] 548f                      addq.l     #2,a7
[00010c96] 4e75                      rts
[00010c98] d2c5                      adda.w     d5,a1
[00010c9a] 51ca 0004                 dbf        d2,$00010CA0
[00010c9e] 4e75                      rts
[00010ca0] da45                      add.w      d5,d5
[00010ca2] 5745                      subq.w     #3,d5
[00010ca4] e24a                      lsr.w      #1,d2
[00010ca6] 4659                      not.w      (a1)+
[00010ca8] 4619                      not.b      (a1)+
[00010caa] d2c5                      adda.w     d5,a1
[00010cac] 51ca fff8                 dbf        d2,$00010CA6
[00010cb0] 4e75                      rts
[00010cb2] be7c aaaa                 cmp.w      #$AAAA,d7
[00010cb6] 67e8                      beq.s      $00010CA0
[00010cb8] be7c 5555                 cmp.w      #$5555,d7
[00010cbc] 67da                      beq.s      $00010C98
[00010cbe] 3f05                      move.w     d5,-(a7)
[00010cc0] e98d                      lsl.l      #4,d5
[00010cc2] 5785                      subq.l     #3,d5
[00010cc4] 700f                      moveq.l    #15,d0
[00010cc6] b440                      cmp.w      d0,d2
[00010cc8] 6c02                      bge.s      $00010CCC
[00010cca] 3002                      move.w     d2,d0
[00010ccc] 2609                      move.l     a1,d3
[00010cce] de47                      add.w      d7,d7
[00010cd0] 640e                      bcc.s      $00010CE0
[00010cd2] 3202                      move.w     d2,d1
[00010cd4] e849                      lsr.w      #4,d1
[00010cd6] 4659                      not.w      (a1)+
[00010cd8] 4619                      not.b      (a1)+
[00010cda] d3c5                      adda.l     d5,a1
[00010cdc] 51c9 fff8                 dbf        d1,$00010CD6
[00010ce0] 2243                      movea.l    d3,a1
[00010ce2] d2d7                      adda.w     (a7),a1
[00010ce4] 5342                      subq.w     #1,d2
[00010ce6] 51c8 ffe4                 dbf        d0,$00010CCC
[00010cea] 548f                      addq.l     #2,a7
[00010cec] 4e75                      rts
[00010cee] d2c5                      adda.w     d5,a1
[00010cf0] 51ca 0004                 dbf        d2,$00010CF6
[00010cf4] 4e75                      rts
[00010cf6] da45                      add.w      d5,d5
[00010cf8] 5745                      subq.w     #3,d5
[00010cfa] e24a                      lsr.w      #1,d2
[00010cfc] 4619                      not.b      (a1)+
[00010cfe] 4659                      not.w      (a1)+
[00010d00] d2c5                      adda.w     d5,a1
[00010d02] 51ca fff8                 dbf        d2,$00010CFC
[00010d06] 4e75                      rts
[00010d08] be7c aaaa                 cmp.w      #$AAAA,d7
[00010d0c] 67e8                      beq.s      $00010CF6
[00010d0e] be7c 5555                 cmp.w      #$5555,d7
[00010d12] 67da                      beq.s      $00010CEE
[00010d14] 3f05                      move.w     d5,-(a7)
[00010d16] e98d                      lsl.l      #4,d5
[00010d18] 5785                      subq.l     #3,d5
[00010d1a] 700f                      moveq.l    #15,d0
[00010d1c] b440                      cmp.w      d0,d2
[00010d1e] 6c02                      bge.s      $00010D22
[00010d20] 3002                      move.w     d2,d0
[00010d22] 2609                      move.l     a1,d3
[00010d24] de47                      add.w      d7,d7
[00010d26] 640e                      bcc.s      $00010D36
[00010d28] 3202                      move.w     d2,d1
[00010d2a] e849                      lsr.w      #4,d1
[00010d2c] 4619                      not.b      (a1)+
[00010d2e] 4659                      not.w      (a1)+
[00010d30] d3c5                      adda.l     d5,a1
[00010d32] 51c9 fff8                 dbf        d1,$00010D2C
[00010d36] 2243                      movea.l    d3,a1
[00010d38] d2d7                      adda.w     (a7),a1
[00010d3a] 5342                      subq.w     #1,d2
[00010d3c] 51c8 ffe4                 dbf        d0,$00010D22
[00010d40] 548f                      addq.l     #2,a7
[00010d42] 4e75                      rts
[00010d44] 3c2e 01b2                 move.w     434(a6),d6
[00010d48] 670e                      beq.s      $00010D58
[00010d4a] 226e 01ae                 movea.l    430(a6),a1
[00010d4e] 906e 01b6                 sub.w      438(a6),d0
[00010d52] 926e 01b8                 sub.w      440(a6),d1
[00010d56] 6008                      bra.s      $00010D60
[00010d58] 2278 044e                 movea.l    ($0000044E).w,a1
[00010d5c] 3c38 206e                 move.w     ($0000206E).w,d6
[00010d60] c3c6                      muls.w     d6,d1
[00010d62] d3c1                      adda.l     d1,a1
[00010d64] d3c0                      adda.l     d0,a1
[00010d66] d080                      add.l      d0,d0
[00010d68] d3c0                      adda.l     d0,a1
[00010d6a] 4a86                      tst.l      d6
[00010d6c] 6a02                      bpl.s      $00010D70
[00010d6e] 4446                      neg.w      d6
[00010d70] 202e 00f2                 move.l     242(a6),d0
[00010d74] 322e 003c                 move.w     60(a6),d1
[00010d78] ba44                      cmp.w      d4,d5
[00010d7a] 6302                      bls.s      $00010D7E
[00010d7c] 5841                      addq.w     #4,d1
[00010d7e] d241                      add.w      d1,d1
[00010d80] 4a78 059e                 tst.w      ($0000059E).w
[00010d84] 6708                      beq.s      $00010D8E
[00010d86] 323b 100e                 move.w     $00010D96(pc,d1.w),d1
[00010d8a] 4efb 100a                 jmp        $00010D96(pc,d1.w)
[00010d8e] 323b 1016                 move.w     $00010DA6(pc,d1.w),d1
[00010d92] 4efb 1002                 jmp        $00010D96(pc,d1.w)
J3:
[00010d96] 0020                      dc.w $0020   ; $00010db6-J3+16
[00010d98] 007e                      dc.w $007e   ; $00010e14-J3+16
[00010d9a] 00aa                      dc.w $00aa   ; $00010e40-J3+16
[00010d9c] 0078                      dc.w $0078   ; $00010e0e-J3+16
[00010d9e] 00d4                      dc.w $00d4   ; $00010e6a-J3+16
[00010da0] 013e                      dc.w $013e   ; $00010ed4-J3+16
[00010da2] 0162                      dc.w $0162   ; $00010ef8-J3+16
[00010da4] 0138                      dc.w $0138   ; $00010ece-J3+16
[00010da6] 0184                      dc.w $0184   ; $00010f1a-J3+16
[00010da8] 01f6                      dc.w $01f6   ; $00010f8c-J3+16
[00010daa] 022c                      dc.w $022c   ; $00010fc2-J3+16
[00010dac] 01f0                      dc.w $01f0   ; $00010f86-J3+16
[00010dae] 025c                      dc.w $025c   ; $00010ff2-J3+16
[00010db0] 02e0                      dc.w $02e0   ; $00011076-J3+16
[00010db2] 030e                      dc.w $030e   ; $000110a4-J3+16
[00010db4] 02da                      dc.w $02da   ; $00011070-J3+16
[00010db6] be7c ffff                 cmp.w      #$FFFF,d7
[00010dba] 6736                      beq.s      $00010DF2
[00010dbc] 222e 00f6                 move.l     246(a6),d1
[00010dc0] e35f                      rol.w      #1,d7
[00010dc2] 6412                      bcc.s      $00010DD6
[00010dc4] 4840                      swap       d0
[00010dc6] 12c0                      move.b     d0,(a1)+
[00010dc8] 4840                      swap       d0
[00010dca] 32c0                      move.w     d0,(a1)+
[00010dcc] d645                      add.w      d5,d3
[00010dce] 6a18                      bpl.s      $00010DE8
[00010dd0] 51ca ffee                 dbf        d2,$00010DC0
[00010dd4] 4e75                      rts
[00010dd6] 4841                      swap       d1
[00010dd8] 12c1                      move.b     d1,(a1)+
[00010dda] 4841                      swap       d1
[00010ddc] 32c1                      move.w     d1,(a1)+
[00010dde] d645                      add.w      d5,d3
[00010de0] 6a06                      bpl.s      $00010DE8
[00010de2] 51ca ffdc                 dbf        d2,$00010DC0
[00010de6] 4e75                      rts
[00010de8] d2c6                      adda.w     d6,a1
[00010dea] 9644                      sub.w      d4,d3
[00010dec] 51ca ffd2                 dbf        d2,$00010DC0
[00010df0] 4e75                      rts
[00010df2] 4840                      swap       d0
[00010df4] 12c0                      move.b     d0,(a1)+
[00010df6] 4840                      swap       d0
[00010df8] 32c0                      move.w     d0,(a1)+
[00010dfa] d645                      add.w      d5,d3
[00010dfc] 6a06                      bpl.s      $00010E04
[00010dfe] 51ca fff2                 dbf        d2,$00010DF2
[00010e02] 4e75                      rts
[00010e04] d2c6                      adda.w     d6,a1
[00010e06] 9644                      sub.w      d4,d3
[00010e08] 51ca ffe8                 dbf        d2,$00010DF2
[00010e0c] 4e75                      rts
[00010e0e] 4647                      not.w      d7
[00010e10] 202e 00f6                 move.l     246(a6),d0
[00010e14] e35f                      rol.w      #1,d7
[00010e16] 6412                      bcc.s      $00010E2A
[00010e18] 4840                      swap       d0
[00010e1a] 12c0                      move.b     d0,(a1)+
[00010e1c] 4840                      swap       d0
[00010e1e] 32c0                      move.w     d0,(a1)+
[00010e20] d645                      add.w      d5,d3
[00010e22] 6a12                      bpl.s      $00010E36
[00010e24] 51ca ffee                 dbf        d2,$00010E14
[00010e28] 4e75                      rts
[00010e2a] 5689                      addq.l     #3,a1
[00010e2c] d645                      add.w      d5,d3
[00010e2e] 6a06                      bpl.s      $00010E36
[00010e30] 51ca ffe2                 dbf        d2,$00010E14
[00010e34] 4e75                      rts
[00010e36] d2c6                      adda.w     d6,a1
[00010e38] 9644                      sub.w      d4,d3
[00010e3a] 51ca ffd8                 dbf        d2,$00010E14
[00010e3e] 4e75                      rts
[00010e40] 70ff                      moveq.l    #-1,d0
[00010e42] e35f                      rol.w      #1,d7
[00010e44] 640e                      bcc.s      $00010E54
[00010e46] 4619                      not.b      (a1)+
[00010e48] 4659                      not.w      (a1)+
[00010e4a] d645                      add.w      d5,d3
[00010e4c] 6a12                      bpl.s      $00010E60
[00010e4e] 51ca fff2                 dbf        d2,$00010E42
[00010e52] 4e75                      rts
[00010e54] 5689                      addq.l     #3,a1
[00010e56] d645                      add.w      d5,d3
[00010e58] 6a06                      bpl.s      $00010E60
[00010e5a] 51ca ffe6                 dbf        d2,$00010E42
[00010e5e] 4e75                      rts
[00010e60] d2c6                      adda.w     d6,a1
[00010e62] 9644                      sub.w      d4,d3
[00010e64] 51ca ffdc                 dbf        d2,$00010E42
[00010e68] 4e75                      rts
[00010e6a] be7c ffff                 cmp.w      #$FFFF,d7
[00010e6e] 673e                      beq.s      $00010EAE
[00010e70] 222e 00f6                 move.l     246(a6),d1
[00010e74] e35f                      rol.w      #1,d7
[00010e76] 6416                      bcc.s      $00010E8E
[00010e78] 4840                      swap       d0
[00010e7a] 1280                      move.b     d0,(a1)
[00010e7c] 4840                      swap       d0
[00010e7e] 3340 0001                 move.w     d0,1(a1)
[00010e82] d2c6                      adda.w     d6,a1
[00010e84] d644                      add.w      d4,d3
[00010e86] 6a1c                      bpl.s      $00010EA4
[00010e88] 51ca ffea                 dbf        d2,$00010E74
[00010e8c] 4e75                      rts
[00010e8e] 4841                      swap       d1
[00010e90] 1281                      move.b     d1,(a1)
[00010e92] 4841                      swap       d1
[00010e94] 3341 0001                 move.w     d1,1(a1)
[00010e98] d2c6                      adda.w     d6,a1
[00010e9a] d644                      add.w      d4,d3
[00010e9c] 6a06                      bpl.s      $00010EA4
[00010e9e] 51ca ffd4                 dbf        d2,$00010E74
[00010ea2] 4e75                      rts
[00010ea4] 9645                      sub.w      d5,d3
[00010ea6] 5689                      addq.l     #3,a1
[00010ea8] 51ca ffca                 dbf        d2,$00010E74
[00010eac] 4e75                      rts
[00010eae] 4840                      swap       d0
[00010eb0] 1280                      move.b     d0,(a1)
[00010eb2] 4840                      swap       d0
[00010eb4] 3340 0001                 move.w     d0,1(a1)
[00010eb8] d2c6                      adda.w     d6,a1
[00010eba] d644                      add.w      d4,d3
[00010ebc] 6a06                      bpl.s      $00010EC4
[00010ebe] 51ca ffee                 dbf        d2,$00010EAE
[00010ec2] 4e75                      rts
[00010ec4] 9645                      sub.w      d5,d3
[00010ec6] 5689                      addq.l     #3,a1
[00010ec8] 51ca ffe4                 dbf        d2,$00010EAE
[00010ecc] 4e75                      rts
[00010ece] 4647                      not.w      d7
[00010ed0] 202e 00f6                 move.l     246(a6),d0
[00010ed4] e35f                      rol.w      #1,d7
[00010ed6] 640a                      bcc.s      $00010EE2
[00010ed8] 4840                      swap       d0
[00010eda] 1280                      move.b     d0,(a1)
[00010edc] 4840                      swap       d0
[00010ede] 3340 0001                 move.w     d0,1(a1)
[00010ee2] d2c6                      adda.w     d6,a1
[00010ee4] d644                      add.w      d4,d3
[00010ee6] 6a06                      bpl.s      $00010EEE
[00010ee8] 51ca ffea                 dbf        d2,$00010ED4
[00010eec] 4e75                      rts
[00010eee] 9645                      sub.w      d5,d3
[00010ef0] 5689                      addq.l     #3,a1
[00010ef2] 51ca ffe0                 dbf        d2,$00010ED4
[00010ef6] 4e75                      rts
[00010ef8] 70ff                      moveq.l    #-1,d0
[00010efa] e35f                      rol.w      #1,d7
[00010efc] 6406                      bcc.s      $00010F04
[00010efe] 4611                      not.b      (a1)
[00010f00] 4669 0001                 not.w      1(a1)
[00010f04] d2c6                      adda.w     d6,a1
[00010f06] d644                      add.w      d4,d3
[00010f08] 6a06                      bpl.s      $00010F10
[00010f0a] 51ca ffee                 dbf        d2,$00010EFA
[00010f0e] 4e75                      rts
[00010f10] 9645                      sub.w      d5,d3
[00010f12] 5689                      addq.l     #3,a1
[00010f14] 51ca ffe4                 dbf        d2,$00010EFA
[00010f18] 4e75                      rts
[00010f1a] 3f00                      move.w     d0,-(a7)
[00010f1c] 4840                      swap       d0
[00010f1e] be7c ffff                 cmp.w      #$FFFF,d7
[00010f22] 6742                      beq.s      $00010F66
[00010f24] 222e 00f6                 move.l     246(a6),d1
[00010f28] 3f01                      move.w     d1,-(a7)
[00010f2a] 4841                      swap       d1
[00010f2c] e35f                      rol.w      #1,d7
[00010f2e] 6416                      bcc.s      $00010F46
[00010f30] 12c0                      move.b     d0,(a1)+
[00010f32] 12ef 0002                 move.b     2(a7),(a1)+
[00010f36] 12ef 0003                 move.b     3(a7),(a1)+
[00010f3a] d645                      add.w      d5,d3
[00010f3c] 6a1c                      bpl.s      $00010F5A
[00010f3e] 51ca ffec                 dbf        d2,$00010F2C
[00010f42] 588f                      addq.l     #4,a7
[00010f44] 4e75                      rts
[00010f46] 12c1                      move.b     d1,(a1)+
[00010f48] 12d7                      move.b     (a7),(a1)+
[00010f4a] 12ef 0001                 move.b     1(a7),(a1)+
[00010f4e] d645                      add.w      d5,d3
[00010f50] 6a08                      bpl.s      $00010F5A
[00010f52] 51ca ffd8                 dbf        d2,$00010F2C
[00010f56] 588f                      addq.l     #4,a7
[00010f58] 4e75                      rts
[00010f5a] d2c6                      adda.w     d6,a1
[00010f5c] 9644                      sub.w      d4,d3
[00010f5e] 51ca ffcc                 dbf        d2,$00010F2C
[00010f62] 588f                      addq.l     #4,a7
[00010f64] 4e75                      rts
[00010f66] 12c0                      move.b     d0,(a1)+
[00010f68] 12d7                      move.b     (a7),(a1)+
[00010f6a] 12ef 0001                 move.b     1(a7),(a1)+
[00010f6e] d645                      add.w      d5,d3
[00010f70] 6a08                      bpl.s      $00010F7A
[00010f72] 51ca fff2                 dbf        d2,$00010F66
[00010f76] 548f                      addq.l     #2,a7
[00010f78] 4e75                      rts
[00010f7a] d2c6                      adda.w     d6,a1
[00010f7c] 9644                      sub.w      d4,d3
[00010f7e] 51ca ffe6                 dbf        d2,$00010F66
[00010f82] 548f                      addq.l     #2,a7
[00010f84] 4e75                      rts
[00010f86] 4647                      not.w      d7
[00010f88] 202e 00f6                 move.l     246(a6),d0
[00010f8c] 3f00                      move.w     d0,-(a7)
[00010f8e] 4840                      swap       d0
[00010f90] e35f                      rol.w      #1,d7
[00010f92] 6414                      bcc.s      $00010FA8
[00010f94] 12c0                      move.b     d0,(a1)+
[00010f96] 12d7                      move.b     (a7),(a1)+
[00010f98] 12ef 0001                 move.b     1(a7),(a1)+
[00010f9c] d645                      add.w      d5,d3
[00010f9e] 6a16                      bpl.s      $00010FB6
[00010fa0] 51ca ffee                 dbf        d2,$00010F90
[00010fa4] 548f                      addq.l     #2,a7
[00010fa6] 4e75                      rts
[00010fa8] 5689                      addq.l     #3,a1
[00010faa] d645                      add.w      d5,d3
[00010fac] 6a08                      bpl.s      $00010FB6
[00010fae] 51ca ffe0                 dbf        d2,$00010F90
[00010fb2] 548f                      addq.l     #2,a7
[00010fb4] 4e75                      rts
[00010fb6] d2c6                      adda.w     d6,a1
[00010fb8] 9644                      sub.w      d4,d3
[00010fba] 51ca ffd4                 dbf        d2,$00010F90
[00010fbe] 548f                      addq.l     #2,a7
[00010fc0] 4e75                      rts
[00010fc2] e35f                      rol.w      #1,d7
[00010fc4] 6412                      bcc.s      $00010FD8
[00010fc6] 4619                      not.b      (a1)+
[00010fc8] 4619                      not.b      (a1)+
[00010fca] 4619                      not.b      (a1)+
[00010fcc] d645                      add.w      d5,d3
[00010fce] 6a16                      bpl.s      $00010FE6
[00010fd0] 51ca fff0                 dbf        d2,$00010FC2
[00010fd4] 548f                      addq.l     #2,a7
[00010fd6] 4e75                      rts
[00010fd8] 5689                      addq.l     #3,a1
[00010fda] d645                      add.w      d5,d3
[00010fdc] 6a08                      bpl.s      $00010FE6
[00010fde] 51ca ffe2                 dbf        d2,$00010FC2
[00010fe2] 548f                      addq.l     #2,a7
[00010fe4] 4e75                      rts
[00010fe6] d2c6                      adda.w     d6,a1
[00010fe8] 9644                      sub.w      d4,d3
[00010fea] 51ca ffd6                 dbf        d2,$00010FC2
[00010fee] 548f                      addq.l     #2,a7
[00010ff0] 4e75                      rts
[00010ff2] 3f00                      move.w     d0,-(a7)
[00010ff4] 4840                      swap       d0
[00010ff6] be7c ffff                 cmp.w      #$FFFF,d7
[00010ffa] 674e                      beq.s      $0001104A
[00010ffc] 222e 00f6                 move.l     246(a6),d1
[00011000] 3f01                      move.w     d1,-(a7)
[00011002] 4841                      swap       d1
[00011004] e35f                      rol.w      #1,d7
[00011006] 641c                      bcc.s      $00011024
[00011008] 1280                      move.b     d0,(a1)
[0001100a] 136f 0002 0001            move.b     2(a7),1(a1)
[00011010] 136f 0003 0002            move.b     3(a7),2(a1)
[00011016] d2c6                      adda.w     d6,a1
[00011018] d644                      add.w      d4,d3
[0001101a] 6a22                      bpl.s      $0001103E
[0001101c] 51ca ffe6                 dbf        d2,$00011004
[00011020] 588f                      addq.l     #4,a7
[00011022] 4e75                      rts
[00011024] 1281                      move.b     d1,(a1)
[00011026] 1357 0001                 move.b     (a7),1(a1)
[0001102a] 136f 0001 0002            move.b     1(a7),2(a1)
[00011030] d2c6                      adda.w     d6,a1
[00011032] d644                      add.w      d4,d3
[00011034] 6a08                      bpl.s      $0001103E
[00011036] 51ca ffcc                 dbf        d2,$00011004
[0001103a] 588f                      addq.l     #4,a7
[0001103c] 4e75                      rts
[0001103e] 9645                      sub.w      d5,d3
[00011040] 5689                      addq.l     #3,a1
[00011042] 51ca ffc0                 dbf        d2,$00011004
[00011046] 588f                      addq.l     #4,a7
[00011048] 4e75                      rts
[0001104a] 1280                      move.b     d0,(a1)
[0001104c] 1357 0001                 move.b     (a7),1(a1)
[00011050] 136f 0001 0002            move.b     1(a7),2(a1)
[00011056] d2c6                      adda.w     d6,a1
[00011058] d644                      add.w      d4,d3
[0001105a] 6a08                      bpl.s      $00011064
[0001105c] 51ca ffec                 dbf        d2,$0001104A
[00011060] 548f                      addq.l     #2,a7
[00011062] 4e75                      rts
[00011064] 9645                      sub.w      d5,d3
[00011066] 5689                      addq.l     #3,a1
[00011068] 51ca ffe0                 dbf        d2,$0001104A
[0001106c] 548f                      addq.l     #2,a7
[0001106e] 4e75                      rts
[00011070] 4647                      not.w      d7
[00011072] 202e 00f6                 move.l     246(a6),d0
[00011076] 3f00                      move.w     d0,-(a7)
[00011078] 4840                      swap       d0
[0001107a] e35f                      rol.w      #1,d7
[0001107c] 640c                      bcc.s      $0001108A
[0001107e] 1280                      move.b     d0,(a1)
[00011080] 1357 0001                 move.b     (a7),1(a1)
[00011084] 136f 0001 0002            move.b     1(a7),2(a1)
[0001108a] d2c6                      adda.w     d6,a1
[0001108c] d644                      add.w      d4,d3
[0001108e] 6a08                      bpl.s      $00011098
[00011090] 51ca ffe8                 dbf        d2,$0001107A
[00011094] 548f                      addq.l     #2,a7
[00011096] 4e75                      rts
[00011098] 9645                      sub.w      d5,d3
[0001109a] 5689                      addq.l     #3,a1
[0001109c] 51ca ffdc                 dbf        d2,$0001107A
[000110a0] 548f                      addq.l     #2,a7
[000110a2] 4e75                      rts
[000110a4] e35f                      rol.w      #1,d7
[000110a6] 640a                      bcc.s      $000110B2
[000110a8] 4611                      not.b      (a1)
[000110aa] 4629 0001                 not.b      1(a1)
[000110ae] 4629 0002                 not.b      2(a1)
[000110b2] d2c6                      adda.w     d6,a1
[000110b4] d644                      add.w      d4,d3
[000110b6] 6a08                      bpl.s      $000110C0
[000110b8] 51ca ffea                 dbf        d2,$000110A4
[000110bc] 548f                      addq.l     #2,a7
[000110be] 4e75                      rts
[000110c0] 9645                      sub.w      d5,d3
[000110c2] 5689                      addq.l     #3,a1
[000110c4] 51ca ffde                 dbf        d2,$000110A4
[000110c8] 548f                      addq.l     #2,a7
[000110ca] 4e75                      rts
[000110cc] 9641                      sub.w      d1,d3
[000110ce] c3c4                      muls.w     d4,d1
[000110d0] 3c00                      move.w     d0,d6
[000110d2] dc46                      add.w      d6,d6
[000110d4] dc40                      add.w      d0,d6
[000110d6] 48c6                      ext.l      d6
[000110d8] d286                      add.l      d6,d1
[000110da] d3c1                      adda.l     d1,a1
[000110dc] 9440                      sub.w      d0,d2
[000110de] 3c02                      move.w     d2,d6
[000110e0] dc46                      add.w      d6,d6
[000110e2] dc42                      add.w      d2,d6
[000110e4] 5646                      addq.w     #3,d6
[000110e6] 9846                      sub.w      d6,d4
[000110e8] 3644                      movea.w    d4,a3
[000110ea] 2c05                      move.l     d5,d6
[000110ec] 2e05                      move.l     d5,d7
[000110ee] e18d                      lsl.l      #8,d5
[000110f0] 4846                      swap       d6
[000110f2] 1a06                      move.b     d6,d5
[000110f4] 4845                      swap       d5
[000110f6] 3c05                      move.w     d5,d6
[000110f8] 4845                      swap       d5
[000110fa] 4847                      swap       d7
[000110fc] 3e05                      move.w     d5,d7
[000110fe] 4847                      swap       d7
[00011100] 41fa 002e                 lea.l      $00011130(pc),a0
[00011104] c07c 0001                 and.w      #$0001,d0
[00011108] 6710                      beq.s      $0001111A
[0001110a] 41fa 0020                 lea.l      $0001112C(pc),a0
[0001110e] 5342                      subq.w     #1,d2
[00011110] 6a08                      bpl.s      $0001111A
[00011112] 45fa 0046                 lea.l      $0001115A(pc),a2
[00011116] 74ff                      moveq.l    #-1,d2
[00011118] 6010                      bra.s      $0001112A
[0001111a] 7003                      moveq.l    #3,d0
[0001111c] c042                      and.w      d2,d0
[0001111e] d040                      add.w      d0,d0
[00011120] d040                      add.w      d0,d0
[00011122] 247b 003e                 movea.l    $00011162(pc,d0.w),a2
[00011126] e44a                      lsr.w      #2,d2
[00011128] 5342                      subq.w     #1,d2
[0001112a] 4ed0                      jmp        (a0)
[0001112c] 12c5                      move.b     d5,(a1)+
[0001112e] 32c7                      move.w     d7,(a1)+
[00011130] 3002                      move.w     d2,d0
[00011132] 6b0a                      bmi.s      $0001113E
[00011134] 22c5                      move.l     d5,(a1)+
[00011136] 22c6                      move.l     d6,(a1)+
[00011138] 22c7                      move.l     d7,(a1)+
[0001113a] 51c8 fff8                 dbf        d0,$00011134
[0001113e] 4ed2                      jmp        (a2)
[00011140] 32c6                      move.w     d6,(a1)+
[00011142] 12c7                      move.b     d7,(a1)+
[00011144] 6014                      bra.s      $0001115A
[00011146] 22c5                      move.l     d5,(a1)+
[00011148] 32c7                      move.w     d7,(a1)+
[0001114a] 600e                      bra.s      $0001115A
[0001114c] 22c5                      move.l     d5,(a1)+
[0001114e] 22c6                      move.l     d6,(a1)+
[00011150] 12c7                      move.b     d7,(a1)+
[00011152] 6006                      bra.s      $0001115A
[00011154] 22c5                      move.l     d5,(a1)+
[00011156] 22c6                      move.l     d6,(a1)+
[00011158] 22c7                      move.l     d7,(a1)+
[0001115a] d2cb                      adda.w     a3,a1
[0001115c] 51cb ffcc                 dbf        d3,$0001112A
[00011160] 4e75                      rts
[00011162] 0001 1140                 ori.b      #$40,d1
[00011166] 0001 1146                 ori.b      #$46,d1
[0001116a] 0001 114c                 ori.b      #$4C,d1
[0001116e] 0001 1154                 ori.b      #$54,d1
[00011172] 4e75                      rts
[00011174] 2a2e 00f2                 move.l     242(a6),d5
[00011178] 2278 044e                 movea.l    ($0000044E).w,a1
[0001117c] 3838 206e                 move.w     ($0000206E).w,d4
[00011180] 4a6e 01b2                 tst.w      434(a6)
[00011184] 6708                      beq.s      $0001118E
[00011186] 226e 01ae                 movea.l    430(a6),a1
[0001118a] 382e 01b2                 move.w     434(a6),d4
[0001118e] 3e2e 003c                 move.w     60(a6),d7
[00011192] 662c                      bne.s      $000111C0
[00011194] 2c2e 0030                 move.l     48(a6),d6
[00011198] bcae 00f6                 cmp.l      246(a6),d6
[0001119c] 6622                      bne.s      $000111C0
[0001119e] ba86                      cmp.l      d6,d5
[000111a0] 6700 ff2a                 beq        $000110CC
[000111a4] 0c6e 0001 00c0            cmpi.w     #$0001,192(a6)
[000111aa] 6700 ff20                 beq        $000110CC
[000111ae] 0c6e 0002 00c0            cmpi.w     #$0002,192(a6)
[000111b4] 660a                      bne.s      $000111C0
[000111b6] 0c6e 0008 00c2            cmpi.w     #$0008,194(a6)
[000111bc] 6700 ff0e                 beq        $000110CC
[000111c0] 286e 00c6                 movea.l    198(a6),a4
[000111c4] 206e 00e2                 movea.l    226(a6),a0
[000111c8] 9641                      sub.w      d1,d3
[000111ca] 3c04                      move.w     d4,d6
[000111cc] 48c6                      ext.l      d6
[000111ce] c9c1                      muls.w     d1,d4
[000111d0] d3c4                      adda.l     d4,a1
[000111d2] 3800                      move.w     d0,d4
[000111d4] d844                      add.w      d4,d4
[000111d6] d840                      add.w      d0,d4
[000111d8] d2c4                      adda.w     d4,a1
[000111da] 4a47                      tst.w      d7
[000111dc] 6600 02e2                 bne        $000114C0
[000111e0] 4fef ffe4                 lea.l      -28(a7),a7
[000111e4] 3f46 0016                 move.w     d6,22(a7)
[000111e8] 3802                      move.w     d2,d4
[000111ea] 9840                      sub.w      d0,d4
[000111ec] 5244                      addq.w     #1,d4
[000111ee] 3e04                      move.w     d4,d7
[000111f0] d844                      add.w      d4,d4
[000111f2] d847                      add.w      d7,d4
[000111f4] e98e                      lsl.l      #4,d6
[000111f6] 48c4                      ext.l      d4
[000111f8] 9c84                      sub.l      d4,d6
[000111fa] 2f46 000e                 move.l     d6,14(a7)
[000111fe] 2a48                      movea.l    a0,a5
[00011200] 7c1f                      moveq.l    #31,d6
[00011202] d241                      add.w      d1,d1
[00011204] 4a6e 00ca                 tst.w      202(a6)
[00011208] 673c                      beq.s      $00011246
[0001120a] c246                      and.w      d6,d1
[0001120c] 6724                      beq.s      $00011232
[0001120e] 264c                      movea.l    a4,a3
[00011210] 3a01                      move.w     d1,d5
[00011212] bd45                      eor.w      d6,d5
[00011214] 3c01                      move.w     d1,d6
[00011216] 5346                      subq.w     #1,d6
[00011218] e749                      lsl.w      #3,d1
[0001121a] 3e01                      move.w     d1,d7
[0001121c] d241                      add.w      d1,d1
[0001121e] d247                      add.w      d7,d1
[00011220] d6c1                      adda.w     d1,a3
[00011222] 2adb                      move.l     (a3)+,(a5)+
[00011224] 2adb                      move.l     (a3)+,(a5)+
[00011226] 2adb                      move.l     (a3)+,(a5)+
[00011228] 2adb                      move.l     (a3)+,(a5)+
[0001122a] 2adb                      move.l     (a3)+,(a5)+
[0001122c] 2adb                      move.l     (a3)+,(a5)+
[0001122e] 51cd fff2                 dbf        d5,$00011222
[00011232] 2adc                      move.l     (a4)+,(a5)+
[00011234] 2adc                      move.l     (a4)+,(a5)+
[00011236] 2adc                      move.l     (a4)+,(a5)+
[00011238] 2adc                      move.l     (a4)+,(a5)+
[0001123a] 2adc                      move.l     (a4)+,(a5)+
[0001123c] 2adc                      move.l     (a4)+,(a5)+
[0001123e] 51ce fff2                 dbf        d6,$00011232
[00011242] 6000 00fe                 bra        $00011342
[00011246] 2e2e 0030                 move.l     48(a6),d7
[0001124a] beae 00f6                 cmp.l      246(a6),d7
[0001124e] 6700 0094                 beq        $000112E4
[00011252] 2f0e                      move.l     a6,-(a7)
[00011254] 4dfa 26d0                 lea.l      $00013926(pc),a6
[00011258] c246                      and.w      d6,d1
[0001125a] 6726                      beq.s      $00011282
[0001125c] 264c                      movea.l    a4,a3
[0001125e] d6c1                      adda.w     d1,a3
[00011260] 3c01                      move.w     d1,d6
[00011262] 0a41 001f                 eori.w     #$001F,d1
[00011266] 5346                      subq.w     #1,d6
[00011268] 7e00                      moveq.l    #0,d7
[0001126a] 1e1b                      move.b     (a3)+,d7
[0001126c] eb4f                      lsl.w      #5,d7
[0001126e] 45f6 7000                 lea.l      0(a6,d7.w),a2
[00011272] 2ada                      move.l     (a2)+,(a5)+
[00011274] 2ada                      move.l     (a2)+,(a5)+
[00011276] 2ada                      move.l     (a2)+,(a5)+
[00011278] 2ada                      move.l     (a2)+,(a5)+
[0001127a] 2ada                      move.l     (a2)+,(a5)+
[0001127c] 2ada                      move.l     (a2)+,(a5)+
[0001127e] 51c9 ffe8                 dbf        d1,$00011268
[00011282] 7e00                      moveq.l    #0,d7
[00011284] 1e1c                      move.b     (a4)+,d7
[00011286] eb4f                      lsl.w      #5,d7
[00011288] 45f6 7000                 lea.l      0(a6,d7.w),a2
[0001128c] 2ada                      move.l     (a2)+,(a5)+
[0001128e] 2ada                      move.l     (a2)+,(a5)+
[00011290] 2ada                      move.l     (a2)+,(a5)+
[00011292] 2ada                      move.l     (a2)+,(a5)+
[00011294] 2ada                      move.l     (a2)+,(a5)+
[00011296] 2ada                      move.l     (a2)+,(a5)+
[00011298] 51ce ffe8                 dbf        d6,$00011282
[0001129c] 2c5f                      movea.l    (a7)+,a6
[0001129e] 48e7 9300                 movem.l    d0/d3/d6-d7,-(a7)
[000112a2] 202e 00f6                 move.l     246(a6),d0
[000112a6] 2600                      move.l     d0,d3
[000112a8] e188                      lsl.l      #8,d0
[000112aa] 4843                      swap       d3
[000112ac] 1003                      move.b     d3,d0
[000112ae] 4843                      swap       d3
[000112b0] 2805                      move.l     d5,d4
[000112b2] e18c                      lsl.l      #8,d4
[000112b4] 4845                      swap       d5
[000112b6] 1805                      move.b     d5,d4
[000112b8] 4845                      swap       d5
[000112ba] 2a48                      movea.l    a0,a5
[000112bc] 727f                      moveq.l    #127,d1
[000112be] 2c15                      move.l     (a5),d6
[000112c0] 2e06                      move.l     d6,d7
[000112c2] 8c84                      or.l       d4,d6
[000112c4] 4687                      not.l      d7
[000112c6] 8e80                      or.l       d0,d7
[000112c8] cc87                      and.l      d7,d6
[000112ca] 2ac7                      move.l     d7,(a5)+
[000112cc] 3c15                      move.w     (a5),d6
[000112ce] 3e06                      move.w     d6,d7
[000112d0] 8c45                      or.w       d5,d6
[000112d2] 4647                      not.w      d7
[000112d4] 8e43                      or.w       d3,d7
[000112d6] cc47                      and.w      d7,d6
[000112d8] 3ac6                      move.w     d6,(a5)+
[000112da] 51c9 ffe2                 dbf        d1,$000112BE
[000112de] 4cdf 00c9                 movem.l    (a7)+,d0/d3/d6-d7
[000112e2] 605e                      bra.s      $00011342
[000112e4] 4dfa 2640                 lea.l      $00013926(pc),a6
[000112e8] c246                      and.w      d6,d1
[000112ea] 6726                      beq.s      $00011312
[000112ec] 264c                      movea.l    a4,a3
[000112ee] d6c1                      adda.w     d1,a3
[000112f0] 3c01                      move.w     d1,d6
[000112f2] 0a41 001f                 eori.w     #$001F,d1
[000112f6] 5346                      subq.w     #1,d6
[000112f8] 7e00                      moveq.l    #0,d7
[000112fa] 1e1b                      move.b     (a3)+,d7
[000112fc] eb4f                      lsl.w      #5,d7
[000112fe] 45f6 7000                 lea.l      0(a6,d7.w),a2
[00011302] 2ada                      move.l     (a2)+,(a5)+
[00011304] 2ada                      move.l     (a2)+,(a5)+
[00011306] 2ada                      move.l     (a2)+,(a5)+
[00011308] 2ada                      move.l     (a2)+,(a5)+
[0001130a] 2ada                      move.l     (a2)+,(a5)+
[0001130c] 2ada                      move.l     (a2)+,(a5)+
[0001130e] 51c9 ffe8                 dbf        d1,$000112F8
[00011312] 7e00                      moveq.l    #0,d7
[00011314] 1e1c                      move.b     (a4)+,d7
[00011316] eb4f                      lsl.w      #5,d7
[00011318] 45f6 7000                 lea.l      0(a6,d7.w),a2
[0001131c] 2ada                      move.l     (a2)+,(a5)+
[0001131e] 2ada                      move.l     (a2)+,(a5)+
[00011320] 2ada                      move.l     (a2)+,(a5)+
[00011322] 2ada                      move.l     (a2)+,(a5)+
[00011324] 2ada                      move.l     (a2)+,(a5)+
[00011326] 2ada                      move.l     (a2)+,(a5)+
[00011328] 51ce ffe8                 dbf        d6,$00011312
[0001132c] 2805                      move.l     d5,d4
[0001132e] e18c                      lsl.l      #8,d4
[00011330] 4845                      swap       d5
[00011332] 1805                      move.b     d5,d4
[00011334] 4845                      swap       d5
[00011336] 2a48                      movea.l    a0,a5
[00011338] 727f                      moveq.l    #127,d1
[0001133a] 899d                      or.l       d4,(a5)+
[0001133c] 8b5d                      or.w       d5,(a5)+
[0001133e] 51c9 fffa                 dbf        d1,$0001133A
[00011342] 3c02                      move.w     d2,d6
[00011344] e84a                      lsr.w      #4,d2
[00011346] 3800                      move.w     d0,d4
[00011348] e84c                      lsr.w      #4,d4
[0001134a] 9444                      sub.w      d4,d2
[0001134c] 6700 00ca                 beq        $00011418
[00011350] 5542                      subq.w     #2,d2
[00011352] 3e82                      move.w     d2,(a7)
[00011354] 7a0f                      moveq.l    #15,d5
[00011356] c045                      and.w      d5,d0
[00011358] b145                      eor.w      d0,d5
[0001135a] 3f45 0004                 move.w     d5,4(a7)
[0001135e] 3a00                      move.w     d0,d5
[00011360] da45                      add.w      d5,d5
[00011362] da40                      add.w      d0,d5
[00011364] 3f45 0006                 move.w     d5,6(a7)
[00011368] cc7c 000f                 and.w      #$000F,d6
[0001136c] 3f46 0008                 move.w     d6,8(a7)
[00011370] 700f                      moveq.l    #15,d0
[00011372] b640                      cmp.w      d0,d3
[00011374] 6c02                      bge.s      $00011378
[00011376] 3003                      move.w     d3,d0
[00011378] 3f40 0018                 move.w     d0,24(a7)
[0001137c] 3f43 0002                 move.w     d3,2(a7)
[00011380] 2f49 0012                 move.l     a1,18(a7)
[00011384] 302f 0002                 move.w     2(a7),d0
[00011388] e848                      lsr.w      #4,d0
[0001138a] 2218                      move.l     (a0)+,d1
[0001138c] 2418                      move.l     (a0)+,d2
[0001138e] 2618                      move.l     (a0)+,d3
[00011390] 2818                      move.l     (a0)+,d4
[00011392] 2a18                      move.l     (a0)+,d5
[00011394] 2c18                      move.l     (a0)+,d6
[00011396] 2e18                      move.l     (a0)+,d7
[00011398] 2458                      movea.l    (a0)+,a2
[0001139a] 2658                      movea.l    (a0)+,a3
[0001139c] 2858                      movea.l    (a0)+,a4
[0001139e] 2a58                      movea.l    (a0)+,a5
[000113a0] 2c58                      movea.l    (a0)+,a6
[000113a2] 41e8 ffd0                 lea.l      -48(a0),a0
[000113a6] 4840                      swap       d0
[000113a8] d0ef 0006                 adda.w     6(a7),a0
[000113ac] 302f 0004                 move.w     4(a7),d0
[000113b0] 12d8                      move.b     (a0)+,(a1)+
[000113b2] 12d8                      move.b     (a0)+,(a1)+
[000113b4] 12d8                      move.b     (a0)+,(a1)+
[000113b6] 51c8 fff8                 dbf        d0,$000113B0
[000113ba] 41e8 ffd0                 lea.l      -48(a0),a0
[000113be] 3017                      move.w     (a7),d0
[000113c0] 6b1c                      bmi.s      $000113DE
[000113c2] 22c1                      move.l     d1,(a1)+
[000113c4] 22c2                      move.l     d2,(a1)+
[000113c6] 22c3                      move.l     d3,(a1)+
[000113c8] 22c4                      move.l     d4,(a1)+
[000113ca] 22c5                      move.l     d5,(a1)+
[000113cc] 22c6                      move.l     d6,(a1)+
[000113ce] 22c7                      move.l     d7,(a1)+
[000113d0] 22ca                      move.l     a2,(a1)+
[000113d2] 22cb                      move.l     a3,(a1)+
[000113d4] 22cc                      move.l     a4,(a1)+
[000113d6] 22cd                      move.l     a5,(a1)+
[000113d8] 22ce                      move.l     a6,(a1)+
[000113da] 51c8 ffe6                 dbf        d0,$000113C2
[000113de] 302f 0008                 move.w     8(a7),d0
[000113e2] 2f08                      move.l     a0,-(a7)
[000113e4] 12d8                      move.b     (a0)+,(a1)+
[000113e6] 12d8                      move.b     (a0)+,(a1)+
[000113e8] 12d8                      move.b     (a0)+,(a1)+
[000113ea] 51c8 fff8                 dbf        d0,$000113E4
[000113ee] 205f                      movea.l    (a7)+,a0
[000113f0] d3ef 000e                 adda.l     14(a7),a1
[000113f4] 4840                      swap       d0
[000113f6] 51c8 ffae                 dbf        d0,$000113A6
[000113fa] 41e8 0030                 lea.l      48(a0),a0
[000113fe] 226f 0012                 movea.l    18(a7),a1
[00011402] d2ef 0016                 adda.w     22(a7),a1
[00011406] 536f 0002                 subq.w     #1,2(a7)
[0001140a] 536f 0018                 subq.w     #1,24(a7)
[0001140e] 6a00 ff70                 bpl        $00011380
[00011412] 4fef 001c                 lea.l      28(a7),a7
[00011416] 4e75                      rts
[00011418] 366f 0016                 movea.w    22(a7),a3
[0001141c] 4fef 001c                 lea.l      28(a7),a7
[00011420] 720f                      moveq.l    #15,d1
[00011422] 9c40                      sub.w      d0,d6
[00011424] 3e06                      move.w     d6,d7
[00011426] de47                      add.w      d7,d7
[00011428] de46                      add.w      d6,d7
[0001142a] 5647                      addq.w     #3,d7
[0001142c] 96c7                      suba.w     d7,a3
[0001142e] b346                      eor.w      d1,d6
[00011430] dc46                      add.w      d6,d6
[00011432] 3406                      move.w     d6,d2
[00011434] dc46                      add.w      d6,d6
[00011436] dc42                      add.w      d2,d6
[00011438] 45fb 601e                 lea.l      $00011458(pc,d6.w),a2
[0001143c] c041                      and.w      d1,d0
[0001143e] 3400                      move.w     d0,d2
[00011440] d040                      add.w      d0,d0
[00011442] d042                      add.w      d2,d0
[00011444] d0c0                      adda.w     d0,a0
[00011446] 2848                      movea.l    a0,a4
[00011448] 41e8 0030                 lea.l      48(a0),a0
[0001144c] 51c9 0008                 dbf        d1,$00011456
[00011450] 720f                      moveq.l    #15,d1
[00011452] 41e8 fd00                 lea.l      -768(a0),a0
[00011456] 4ed2                      jmp        (a2)
[00011458] 12dc                      move.b     (a4)+,(a1)+
[0001145a] 12dc                      move.b     (a4)+,(a1)+
[0001145c] 12dc                      move.b     (a4)+,(a1)+
[0001145e] 12dc                      move.b     (a4)+,(a1)+
[00011460] 12dc                      move.b     (a4)+,(a1)+
[00011462] 12dc                      move.b     (a4)+,(a1)+
[00011464] 12dc                      move.b     (a4)+,(a1)+
[00011466] 12dc                      move.b     (a4)+,(a1)+
[00011468] 12dc                      move.b     (a4)+,(a1)+
[0001146a] 12dc                      move.b     (a4)+,(a1)+
[0001146c] 12dc                      move.b     (a4)+,(a1)+
[0001146e] 12dc                      move.b     (a4)+,(a1)+
[00011470] 12dc                      move.b     (a4)+,(a1)+
[00011472] 12dc                      move.b     (a4)+,(a1)+
[00011474] 12dc                      move.b     (a4)+,(a1)+
[00011476] 12dc                      move.b     (a4)+,(a1)+
[00011478] 12dc                      move.b     (a4)+,(a1)+
[0001147a] 12dc                      move.b     (a4)+,(a1)+
[0001147c] 12dc                      move.b     (a4)+,(a1)+
[0001147e] 12dc                      move.b     (a4)+,(a1)+
[00011480] 12dc                      move.b     (a4)+,(a1)+
[00011482] 12dc                      move.b     (a4)+,(a1)+
[00011484] 12dc                      move.b     (a4)+,(a1)+
[00011486] 12dc                      move.b     (a4)+,(a1)+
[00011488] 12dc                      move.b     (a4)+,(a1)+
[0001148a] 12dc                      move.b     (a4)+,(a1)+
[0001148c] 12dc                      move.b     (a4)+,(a1)+
[0001148e] 12dc                      move.b     (a4)+,(a1)+
[00011490] 12dc                      move.b     (a4)+,(a1)+
[00011492] 12dc                      move.b     (a4)+,(a1)+
[00011494] 12dc                      move.b     (a4)+,(a1)+
[00011496] 12dc                      move.b     (a4)+,(a1)+
[00011498] 12dc                      move.b     (a4)+,(a1)+
[0001149a] 12dc                      move.b     (a4)+,(a1)+
[0001149c] 12dc                      move.b     (a4)+,(a1)+
[0001149e] 12dc                      move.b     (a4)+,(a1)+
[000114a0] 12dc                      move.b     (a4)+,(a1)+
[000114a2] 12dc                      move.b     (a4)+,(a1)+
[000114a4] 12dc                      move.b     (a4)+,(a1)+
[000114a6] 12dc                      move.b     (a4)+,(a1)+
[000114a8] 12dc                      move.b     (a4)+,(a1)+
[000114aa] 12dc                      move.b     (a4)+,(a1)+
[000114ac] 12dc                      move.b     (a4)+,(a1)+
[000114ae] 12dc                      move.b     (a4)+,(a1)+
[000114b0] 12dc                      move.b     (a4)+,(a1)+
[000114b2] 12dc                      move.b     (a4)+,(a1)+
[000114b4] 12dc                      move.b     (a4)+,(a1)+
[000114b6] 12dc                      move.b     (a4)+,(a1)+
[000114b8] d2cb                      adda.w     a3,a1
[000114ba] 51cb ff8a                 dbf        d3,$00011446
[000114be] 4e75                      rts
[000114c0] 5547                      subq.w     #2,d7
[000114c2] 6d00 01c0                 blt        $00011684
[000114c6] 6600 017c                 bne        $00011644
[000114ca] 3e2e 00c0                 move.w     192(a6),d7
[000114ce] 6700 fca2                 beq        $00011172
[000114d2] 5347                      subq.w     #1,d7
[000114d4] 6700 00ec                 beq        $000115C2
[000114d8] 5347                      subq.w     #1,d7
[000114da] 660a                      bne.s      $000114E6
[000114dc] 0c6e 0008 00c2            cmpi.w     #$0008,194(a6)
[000114e2] 6700 00de                 beq        $000115C2
[000114e6] 9440                      sub.w      d0,d2
[000114e8] 3f06                      move.w     d6,-(a7)
[000114ea] e98e                      lsl.l      #4,d6
[000114ec] 2646                      movea.l    d6,a3
[000114ee] 2a48                      movea.l    a0,a5
[000114f0] 780f                      moveq.l    #15,d4
[000114f2] 7c0f                      moveq.l    #15,d6
[000114f4] c044                      and.w      d4,d0
[000114f6] c244                      and.w      d4,d1
[000114f8] 6718                      beq.s      $00011512
[000114fa] 3e01                      move.w     d1,d7
[000114fc] bd47                      eor.w      d6,d7
[000114fe] 3c01                      move.w     d1,d6
[00011500] 5346                      subq.w     #1,d6
[00011502] d241                      add.w      d1,d1
[00011504] 45f4 1000                 lea.l      0(a4,d1.w),a2
[00011508] 321a                      move.w     (a2)+,d1
[0001150a] e179                      rol.w      d0,d1
[0001150c] 3ac1                      move.w     d1,(a5)+
[0001150e] 51cf fff8                 dbf        d7,$00011508
[00011512] 321c                      move.w     (a4)+,d1
[00011514] e179                      rol.w      d0,d1
[00011516] 3ac1                      move.w     d1,(a5)+
[00011518] 51ce fff8                 dbf        d6,$00011512
[0001151c] 2e05                      move.l     d5,d7
[0001151e] e18f                      lsl.l      #8,d7
[00011520] b644                      cmp.w      d4,d3
[00011522] 6c02                      bge.s      $00011526
[00011524] 3803                      move.w     d3,d4
[00011526] 4843                      swap       d3
[00011528] 3604                      move.w     d4,d3
[0001152a] 347c 0030                 movea.w    #$0030,a2
[0001152e] 7c0f                      moveq.l    #15,d6
[00011530] b446                      cmp.w      d6,d2
[00011532] 6c02                      bge.s      $00011536
[00011534] 3c02                      move.w     d2,d6
[00011536] 3846                      movea.w    d6,a4
[00011538] 9446                      sub.w      d6,d2
[0001153a] 5246                      addq.w     #1,d6
[0001153c] 3a06                      move.w     d6,d5
[0001153e] dc46                      add.w      d6,d6
[00011540] dc45                      add.w      d5,d6
[00011542] 96c6                      suba.w     d6,a3
[00011544] 4843                      swap       d3
[00011546] 3203                      move.w     d3,d1
[00011548] e849                      lsr.w      #4,d1
[0001154a] 2a49                      movea.l    a1,a5
[0001154c] 3c0c                      move.w     a4,d6
[0001154e] 3010                      move.w     (a0),d0
[00011550] d040                      add.w      d0,d0
[00011552] 6452                      bcc.s      $000115A6
[00011554] 3802                      move.w     d2,d4
[00011556] d846                      add.w      d6,d4
[00011558] e84c                      lsr.w      #4,d4
[0001155a] 3a04                      move.w     d4,d5
[0001155c] e64c                      lsr.w      #3,d4
[0001155e] 4645                      not.w      d5
[00011560] 0245 0007                 andi.w     #$0007,d5
[00011564] da45                      add.w      d5,d5
[00011566] da45                      add.w      d5,d5
[00011568] 7eff                      moveq.l    #-1,d7
[0001156a] 4607                      not.b      d7
[0001156c] 2c4d                      movea.l    a5,a6
[0001156e] 4846                      swap       d6
[00011570] 3c0e                      move.w     a6,d6
[00011572] cc7c 0001                 and.w      #$0001,d6
[00011576] 6704                      beq.s      $0001157C
[00011578] 538e                      subq.l     #1,a6
[0001157a] e08f                      lsr.l      #8,d7
[0001157c] 4846                      swap       d6
[0001157e] 4efb 5002                 jmp        $00011582(pc,d5.w)
[00011582] bf96                      eor.l      d7,(a6)
[00011584] dcca                      adda.w     a2,a6
[00011586] bf96                      eor.l      d7,(a6)
[00011588] dcca                      adda.w     a2,a6
[0001158a] bf96                      eor.l      d7,(a6)
[0001158c] dcca                      adda.w     a2,a6
[0001158e] bf96                      eor.l      d7,(a6)
[00011590] dcca                      adda.w     a2,a6
[00011592] bf96                      eor.l      d7,(a6)
[00011594] dcca                      adda.w     a2,a6
[00011596] bf96                      eor.l      d7,(a6)
[00011598] dcca                      adda.w     a2,a6
[0001159a] bf96                      eor.l      d7,(a6)
[0001159c] dcca                      adda.w     a2,a6
[0001159e] bf96                      eor.l      d7,(a6)
[000115a0] dcca                      adda.w     a2,a6
[000115a2] 51cc ffde                 dbf        d4,$00011582
[000115a6] 568d                      addq.l     #3,a5
[000115a8] 51ce ffa6                 dbf        d6,$00011550
[000115ac] dbcb                      adda.l     a3,a5
[000115ae] 51c9 ff9c                 dbf        d1,$0001154C
[000115b2] 5488                      addq.l     #2,a0
[000115b4] d2d7                      adda.w     (a7),a1
[000115b6] 5343                      subq.w     #1,d3
[000115b8] 4843                      swap       d3
[000115ba] 51cb ff88                 dbf        d3,$00011544
[000115be] 548f                      addq.l     #2,a7
[000115c0] 4e75                      rts
[000115c2] 3806                      move.w     d6,d4
[000115c4] 9440                      sub.w      d0,d2
[000115c6] 3c02                      move.w     d2,d6
[000115c8] dc46                      add.w      d6,d6
[000115ca] dc42                      add.w      d2,d6
[000115cc] 5646                      addq.w     #3,d6
[000115ce] 9846                      sub.w      d6,d4
[000115d0] 3644                      movea.w    d4,a3
[000115d2] 41fa 002e                 lea.l      $00011602(pc),a0
[000115d6] c07c 0001                 and.w      #$0001,d0
[000115da] 6710                      beq.s      $000115EC
[000115dc] 41fa 0020                 lea.l      $000115FE(pc),a0
[000115e0] 5342                      subq.w     #1,d2
[000115e2] 6a08                      bpl.s      $000115EC
[000115e4] 45fa 0046                 lea.l      $0001162C(pc),a2
[000115e8] 74ff                      moveq.l    #-1,d2
[000115ea] 6010                      bra.s      $000115FC
[000115ec] 7003                      moveq.l    #3,d0
[000115ee] c042                      and.w      d2,d0
[000115f0] d040                      add.w      d0,d0
[000115f2] d040                      add.w      d0,d0
[000115f4] 247b 003e                 movea.l    $00011634(pc,d0.w),a2
[000115f8] e44a                      lsr.w      #2,d2
[000115fa] 5342                      subq.w     #1,d2
[000115fc] 4ed0                      jmp        (a0)
[000115fe] 4619                      not.b      (a1)+
[00011600] 4659                      not.w      (a1)+
[00011602] 3002                      move.w     d2,d0
[00011604] 6b0a                      bmi.s      $00011610
[00011606] 4699                      not.l      (a1)+
[00011608] 4699                      not.l      (a1)+
[0001160a] 4699                      not.l      (a1)+
[0001160c] 51c8 fff8                 dbf        d0,$00011606
[00011610] 4ed2                      jmp        (a2)
[00011612] 4659                      not.w      (a1)+
[00011614] 4619                      not.b      (a1)+
[00011616] 6014                      bra.s      $0001162C
[00011618] 4699                      not.l      (a1)+
[0001161a] 4659                      not.w      (a1)+
[0001161c] 600e                      bra.s      $0001162C
[0001161e] 4699                      not.l      (a1)+
[00011620] 4699                      not.l      (a1)+
[00011622] 4619                      not.b      (a1)+
[00011624] 6006                      bra.s      $0001162C
[00011626] 4699                      not.l      (a1)+
[00011628] 4699                      not.l      (a1)+
[0001162a] 4699                      not.l      (a1)+
[0001162c] d2cb                      adda.w     a3,a1
[0001162e] 51cb ffcc                 dbf        d3,$000115FC
[00011632] 4e75                      rts
[00011634] 0001 1612                 ori.b      #$12,d1
[00011638] 0001 1618                 ori.b      #$18,d1
[0001163c] 0001 161e                 ori.b      #$1E,d1
[00011640] 0001 1626                 ori.b      #$26,d1
[00011644] 2a2e 00f6                 move.l     246(a6),d5
[00011648] 9440                      sub.w      d0,d2
[0001164a] 3f06                      move.w     d6,-(a7)
[0001164c] e98e                      lsl.l      #4,d6
[0001164e] 2646                      movea.l    d6,a3
[00011650] 2a48                      movea.l    a0,a5
[00011652] 780f                      moveq.l    #15,d4
[00011654] 7c0f                      moveq.l    #15,d6
[00011656] c044                      and.w      d4,d0
[00011658] c244                      and.w      d4,d1
[0001165a] 671a                      beq.s      $00011676
[0001165c] 3e01                      move.w     d1,d7
[0001165e] bd47                      eor.w      d6,d7
[00011660] 3c01                      move.w     d1,d6
[00011662] 5346                      subq.w     #1,d6
[00011664] d241                      add.w      d1,d1
[00011666] 45f4 1000                 lea.l      0(a4,d1.w),a2
[0001166a] 321a                      move.w     (a2)+,d1
[0001166c] 4641                      not.w      d1
[0001166e] e179                      rol.w      d0,d1
[00011670] 3ac1                      move.w     d1,(a5)+
[00011672] 51cf fff6                 dbf        d7,$0001166A
[00011676] 321c                      move.w     (a4)+,d1
[00011678] 4641                      not.w      d1
[0001167a] e179                      rol.w      d0,d1
[0001167c] 3ac1                      move.w     d1,(a5)+
[0001167e] 51ce fff6                 dbf        d6,$00011676
[00011682] 603a                      bra.s      $000116BE
[00011684] 2a2e 00f2                 move.l     242(a6),d5
[00011688] 9440                      sub.w      d0,d2
[0001168a] 3f06                      move.w     d6,-(a7)
[0001168c] e98e                      lsl.l      #4,d6
[0001168e] 2646                      movea.l    d6,a3
[00011690] 2a48                      movea.l    a0,a5
[00011692] 780f                      moveq.l    #15,d4
[00011694] 7c0f                      moveq.l    #15,d6
[00011696] c044                      and.w      d4,d0
[00011698] c244                      and.w      d4,d1
[0001169a] 6718                      beq.s      $000116B4
[0001169c] 3e01                      move.w     d1,d7
[0001169e] bd47                      eor.w      d6,d7
[000116a0] 3c01                      move.w     d1,d6
[000116a2] 5346                      subq.w     #1,d6
[000116a4] d241                      add.w      d1,d1
[000116a6] 45f4 1000                 lea.l      0(a4,d1.w),a2
[000116aa] 321a                      move.w     (a2)+,d1
[000116ac] e179                      rol.w      d0,d1
[000116ae] 3ac1                      move.w     d1,(a5)+
[000116b0] 51cf fff8                 dbf        d7,$000116AA
[000116b4] 321c                      move.w     (a4)+,d1
[000116b6] e179                      rol.w      d0,d1
[000116b8] 3ac1                      move.w     d1,(a5)+
[000116ba] 51ce fff8                 dbf        d6,$000116B4
[000116be] 2e05                      move.l     d5,d7
[000116c0] b644                      cmp.w      d4,d3
[000116c2] 6c02                      bge.s      $000116C6
[000116c4] 3803                      move.w     d3,d4
[000116c6] 4843                      swap       d3
[000116c8] 3604                      move.w     d4,d3
[000116ca] 347c 002d                 movea.w    #$002D,a2
[000116ce] 7c0f                      moveq.l    #15,d6
[000116d0] b446                      cmp.w      d6,d2
[000116d2] 6c02                      bge.s      $000116D6
[000116d4] 3c02                      move.w     d2,d6
[000116d6] 3846                      movea.w    d6,a4
[000116d8] 9446                      sub.w      d6,d2
[000116da] 5246                      addq.w     #1,d6
[000116dc] 3a06                      move.w     d6,d5
[000116de] dc46                      add.w      d6,d6
[000116e0] dc45                      add.w      d5,d6
[000116e2] 96c6                      suba.w     d6,a3
[000116e4] 4843                      swap       d3
[000116e6] 3203                      move.w     d3,d1
[000116e8] e849                      lsr.w      #4,d1
[000116ea] 2a49                      movea.l    a1,a5
[000116ec] 3c0c                      move.w     a4,d6
[000116ee] 3010                      move.w     (a0),d0
[000116f0] d040                      add.w      d0,d0
[000116f2] 6400 00a2                 bcc        $00011796
[000116f6] 3f06                      move.w     d6,-(a7)
[000116f8] 3802                      move.w     d2,d4
[000116fa] d846                      add.w      d6,d4
[000116fc] e84c                      lsr.w      #4,d4
[000116fe] 3a04                      move.w     d4,d5
[00011700] e64c                      lsr.w      #3,d4
[00011702] 4645                      not.w      d5
[00011704] 0245 0007                 andi.w     #$0007,d5
[00011708] da45                      add.w      d5,d5
[0001170a] 3c05                      move.w     d5,d6
[0001170c] da45                      add.w      d5,d5
[0001170e] da46                      add.w      d6,d5
[00011710] 2c4d                      movea.l    a5,a6
[00011712] 3c0e                      move.w     a6,d6
[00011714] cc7c 0001                 and.w      #$0001,d6
[00011718] 663e                      bne.s      $00011758
[0001171a] 2c07                      move.l     d7,d6
[0001171c] e09e                      ror.l      #8,d6
[0001171e] 4efb 5002                 jmp        $00011722(pc,d5.w)
[00011722] 3cc6                      move.w     d6,(a6)+
[00011724] 1cc7                      move.b     d7,(a6)+
[00011726] dcca                      adda.w     a2,a6
[00011728] 3cc6                      move.w     d6,(a6)+
[0001172a] 1cc7                      move.b     d7,(a6)+
[0001172c] dcca                      adda.w     a2,a6
[0001172e] 3cc6                      move.w     d6,(a6)+
[00011730] 1cc7                      move.b     d7,(a6)+
[00011732] dcca                      adda.w     a2,a6
[00011734] 3cc6                      move.w     d6,(a6)+
[00011736] 1cc7                      move.b     d7,(a6)+
[00011738] dcca                      adda.w     a2,a6
[0001173a] 3cc6                      move.w     d6,(a6)+
[0001173c] 1cc7                      move.b     d7,(a6)+
[0001173e] dcca                      adda.w     a2,a6
[00011740] 3cc6                      move.w     d6,(a6)+
[00011742] 1cc7                      move.b     d7,(a6)+
[00011744] dcca                      adda.w     a2,a6
[00011746] 3cc6                      move.w     d6,(a6)+
[00011748] 1cc7                      move.b     d7,(a6)+
[0001174a] dcca                      adda.w     a2,a6
[0001174c] 3cc6                      move.w     d6,(a6)+
[0001174e] 1cc7                      move.b     d7,(a6)+
[00011750] dcca                      adda.w     a2,a6
[00011752] 51cc ffce                 dbf        d4,$00011722
[00011756] 603c                      bra.s      $00011794
[00011758] 2c07                      move.l     d7,d6
[0001175a] 4846                      swap       d6
[0001175c] 4efb 5002                 jmp        $00011760(pc,d5.w)
[00011760] 1cc6                      move.b     d6,(a6)+
[00011762] 3cc7                      move.w     d7,(a6)+
[00011764] dcca                      adda.w     a2,a6
[00011766] 1cc6                      move.b     d6,(a6)+
[00011768] 3cc7                      move.w     d7,(a6)+
[0001176a] dcca                      adda.w     a2,a6
[0001176c] 1cc6                      move.b     d6,(a6)+
[0001176e] 3cc7                      move.w     d7,(a6)+
[00011770] dcca                      adda.w     a2,a6
[00011772] 1cc6                      move.b     d6,(a6)+
[00011774] 3cc7                      move.w     d7,(a6)+
[00011776] dcca                      adda.w     a2,a6
[00011778] 1cc6                      move.b     d6,(a6)+
[0001177a] 3cc7                      move.w     d7,(a6)+
[0001177c] dcca                      adda.w     a2,a6
[0001177e] 1cc6                      move.b     d6,(a6)+
[00011780] 3cc7                      move.w     d7,(a6)+
[00011782] dcca                      adda.w     a2,a6
[00011784] 1cc6                      move.b     d6,(a6)+
[00011786] 3cc7                      move.w     d7,(a6)+
[00011788] dcca                      adda.w     a2,a6
[0001178a] 1cc6                      move.b     d6,(a6)+
[0001178c] 3cc7                      move.w     d7,(a6)+
[0001178e] dcca                      adda.w     a2,a6
[00011790] 51cc ffce                 dbf        d4,$00011760
[00011794] 3c1f                      move.w     (a7)+,d6
[00011796] 568d                      addq.l     #3,a5
[00011798] 51ce ff56                 dbf        d6,$000116F0
[0001179c] dbcb                      adda.l     a3,a5
[0001179e] 51c9 ff4c                 dbf        d1,$000116EC
[000117a2] 5488                      addq.l     #2,a0
[000117a4] d2d7                      adda.w     (a7),a1
[000117a6] 5343                      subq.w     #1,d3
[000117a8] 4843                      swap       d3
[000117aa] 51cb ff38                 dbf        d3,$000116E4
[000117ae] 548f                      addq.l     #2,a7
[000117b0] 4e75                      rts
[000117b2] 206e 01c2                 movea.l    450(a6),a0
[000117b6] 226e 01d6                 movea.l    470(a6),a1
[000117ba] 346e 01c6                 movea.w    454(a6),a2
[000117be] 366e 01da                 movea.w    474(a6),a3
[000117c2] 3c0a                      move.w     a2,d6
[000117c4] 3e0b                      move.w     a3,d7
[000117c6] c3c6                      muls.w     d6,d1
[000117c8] d1c1                      adda.l     d1,a0
[000117ca] 3200                      move.w     d0,d1
[000117cc] e849                      lsr.w      #4,d1
[000117ce] d241                      add.w      d1,d1
[000117d0] d0c1                      adda.w     d1,a0
[000117d2] c7c7                      muls.w     d7,d3
[000117d4] d3c3                      adda.l     d3,a1
[000117d6] 3202                      move.w     d2,d1
[000117d8] d442                      add.w      d2,d2
[000117da] d441                      add.w      d1,d2
[000117dc] d2c2                      adda.w     d2,a1
[000117de] 720f                      moveq.l    #15,d1
[000117e0] c041                      and.w      d1,d0
[000117e2] b141                      eor.w      d0,d1
[000117e4] b841                      cmp.w      d1,d4
[000117e6] 6c02                      bge.s      $000117EA
[000117e8] 3204                      move.w     d4,d1
[000117ea] 4840                      swap       d0
[000117ec] 3001                      move.w     d1,d0
[000117ee] 4840                      swap       d0
[000117f0] 3400                      move.w     d0,d2
[000117f2] d444                      add.w      d4,d2
[000117f4] e84a                      lsr.w      #4,d2
[000117f6] d442                      add.w      d2,d2
[000117f8] 5442                      addq.w     #2,d2
[000117fa] 94c2                      suba.w     d2,a2
[000117fc] 3404                      move.w     d4,d2
[000117fe] d442                      add.w      d2,d2
[00011800] d444                      add.w      d4,d2
[00011802] 5642                      addq.w     #3,d2
[00011804] 96c2                      suba.w     d2,a3
[00011806] 2c2e 00f2                 move.l     242(a6),d6
[0001180a] e18e                      lsl.l      #8,d6
[0001180c] 1c2e 00f5                 move.b     245(a6),d6
[00011810] 4846                      swap       d6
[00011812] 3846                      movea.w    d6,a4
[00011814] e19e                      rol.l      #8,d6
[00011816] 2e2e 00f6                 move.l     246(a6),d7
[0001181a] e18f                      lsl.l      #8,d7
[0001181c] 1e2e 00f9                 move.b     249(a6),d7
[00011820] 4847                      swap       d7
[00011822] 3a47                      movea.w    d7,a5
[00011824] e19f                      rol.l      #8,d7
[00011826] 7403                      moveq.l    #3,d2
[00011828] c46e 01ee                 and.w      494(a6),d2
[0001182c] d442                      add.w      d2,d2
[0001182e] 343b 2006                 move.w     $00011836(pc,d2.w),d2
[00011832] 4efb 2002                 jmp        $00011836(pc,d2.w)
J4:
[00011836] 0008                      dc.w $0008   ; $0001183e-J4
[00011838] 00bc                      dc.w $00bc   ; $000118f2-J4
[0001183a] 014e                      dc.w $014e   ; $00011984-J4
[0001183c] 01dc                      dc.w $01dc   ; $00011a12-J4
[0001183e] 3f0a                      move.w     a2,-(a7)
[00011840] 3f0b                      move.w     a3,-(a7)
[00011842] 2406                      move.l     d6,d2
[00011844] 2607                      move.l     d7,d3
[00011846] e18a                      lsl.l      #8,d2
[00011848] e18b                      lsl.l      #8,d3
[0001184a] 1606                      move.b     d6,d3
[0001184c] 1407                      move.b     d7,d2
[0001184e] e09a                      ror.l      #8,d2
[00011850] e09b                      ror.l      #8,d3
[00011852] 2442                      movea.l    d2,a2
[00011854] 2643                      movea.l    d3,a3
[00011856] 3604                      move.w     d4,d3
[00011858] 3418                      move.w     (a0)+,d2
[0001185a] e17a                      rol.w      d0,d2
[0001185c] 2200                      move.l     d0,d1
[0001185e] 6004                      bra.s      $00011864
[00011860] 3418                      move.w     (a0)+,d2
[00011862] 4841                      swap       d1
[00011864] 3209                      move.w     a1,d1
[00011866] c27c 0001                 and.w      #$0001,d1
[0001186a] 6604                      bne.s      $00011870
[0001186c] 4841                      swap       d1
[0001186e] 601c                      bra.s      $0001188C
[00011870] 4841                      swap       d1
[00011872] 5341                      subq.w     #1,d1
[00011874] 5343                      subq.w     #1,d3
[00011876] d442                      add.w      d2,d2
[00011878] 640a                      bcc.s      $00011884
[0001187a] 4846                      swap       d6
[0001187c] 12c6                      move.b     d6,(a1)+
[0001187e] 4846                      swap       d6
[00011880] 32c6                      move.w     d6,(a1)+
[00011882] 6008                      bra.s      $0001188C
[00011884] 4847                      swap       d7
[00011886] 12c7                      move.b     d7,(a1)+
[00011888] 4847                      swap       d7
[0001188a] 32c7                      move.w     d7,(a1)+
[0001188c] 9641                      sub.w      d1,d3
[0001188e] 5343                      subq.w     #1,d3
[00011890] 5441                      addq.w     #2,d1
[00011892] 600c                      bra.s      $000118A0
[00011894] d442                      add.w      d2,d2
[00011896] 641a                      bcc.s      $000118B2
[00011898] 32cc                      move.w     a4,(a1)+
[0001189a] d442                      add.w      d2,d2
[0001189c] 640a                      bcc.s      $000118A8
[0001189e] 22c6                      move.l     d6,(a1)+
[000118a0] 5541                      subq.w     #2,d1
[000118a2] 6ef0                      bgt.s      $00011894
[000118a4] 6724                      beq.s      $000118CA
[000118a6] 6030                      bra.s      $000118D8
[000118a8] 22cb                      move.l     a3,(a1)+
[000118aa] 5541                      subq.w     #2,d1
[000118ac] 6ee6                      bgt.s      $00011894
[000118ae] 671a                      beq.s      $000118CA
[000118b0] 6026                      bra.s      $000118D8
[000118b2] 32cd                      move.w     a5,(a1)+
[000118b4] d442                      add.w      d2,d2
[000118b6] 650a                      bcs.s      $000118C2
[000118b8] 22c7                      move.l     d7,(a1)+
[000118ba] 5541                      subq.w     #2,d1
[000118bc] 6ed6                      bgt.s      $00011894
[000118be] 670a                      beq.s      $000118CA
[000118c0] 6016                      bra.s      $000118D8
[000118c2] 22ca                      move.l     a2,(a1)+
[000118c4] 5541                      subq.w     #2,d1
[000118c6] 6ecc                      bgt.s      $00011894
[000118c8] 660e                      bne.s      $000118D8
[000118ca] d442                      add.w      d2,d2
[000118cc] 6406                      bcc.s      $000118D4
[000118ce] 32cc                      move.w     a4,(a1)+
[000118d0] 12c6                      move.b     d6,(a1)+
[000118d2] 6004                      bra.s      $000118D8
[000118d4] 32cd                      move.w     a5,(a1)+
[000118d6] 12c7                      move.b     d7,(a1)+
[000118d8] 720f                      moveq.l    #15,d1
[000118da] b641                      cmp.w      d1,d3
[000118dc] 6c82                      bge.s      $00011860
[000118de] 3203                      move.w     d3,d1
[000118e0] 6a00 ff7e                 bpl        $00011860
[000118e4] d0ef 0002                 adda.w     2(a7),a0
[000118e8] d2d7                      adda.w     (a7),a1
[000118ea] 51cd ff6a                 dbf        d5,$00011856
[000118ee] 588f                      addq.l     #4,a7
[000118f0] 4e75                      rts
[000118f2] 2e06                      move.l     d6,d7
[000118f4] 4847                      swap       d7
[000118f6] 3604                      move.w     d4,d3
[000118f8] 3418                      move.w     (a0)+,d2
[000118fa] e17a                      rol.w      d0,d2
[000118fc] 2200                      move.l     d0,d1
[000118fe] 6004                      bra.s      $00011904
[00011900] 3418                      move.w     (a0)+,d2
[00011902] 4841                      swap       d1
[00011904] 3209                      move.w     a1,d1
[00011906] c27c 0001                 and.w      #$0001,d1
[0001190a] 6604                      bne.s      $00011910
[0001190c] 4841                      swap       d1
[0001190e] 6012                      bra.s      $00011922
[00011910] 4841                      swap       d1
[00011912] 5341                      subq.w     #1,d1
[00011914] 5343                      subq.w     #1,d3
[00011916] d442                      add.w      d2,d2
[00011918] 6406                      bcc.s      $00011920
[0001191a] 1287                      move.b     d7,(a1)
[0001191c] 3346 0001                 move.w     d6,1(a1)
[00011920] 5689                      addq.l     #3,a1
[00011922] 9641                      sub.w      d1,d3
[00011924] 5343                      subq.w     #1,d3
[00011926] 5441                      addq.w     #2,d1
[00011928] 6028                      bra.s      $00011952
[0001192a] d442                      add.w      d2,d2
[0001192c] 651c                      bcs.s      $0001194A
[0001192e] d442                      add.w      d2,d2
[00011930] 650a                      bcs.s      $0001193C
[00011932] 5c89                      addq.l     #6,a1
[00011934] 5541                      subq.w     #2,d1
[00011936] 6ef2                      bgt.s      $0001192A
[00011938] 672a                      beq.s      $00011964
[0001193a] 6034                      bra.s      $00011970
[0001193c] 5689                      addq.l     #3,a1
[0001193e] 12c7                      move.b     d7,(a1)+
[00011940] 32c6                      move.w     d6,(a1)+
[00011942] 5541                      subq.w     #2,d1
[00011944] 6ee4                      bgt.s      $0001192A
[00011946] 671c                      beq.s      $00011964
[00011948] 6026                      bra.s      $00011970
[0001194a] 32cc                      move.w     a4,(a1)+
[0001194c] d442                      add.w      d2,d2
[0001194e] 640a                      bcc.s      $0001195A
[00011950] 22c6                      move.l     d6,(a1)+
[00011952] 5541                      subq.w     #2,d1
[00011954] 6ed4                      bgt.s      $0001192A
[00011956] 670c                      beq.s      $00011964
[00011958] 6016                      bra.s      $00011970
[0001195a] 12c6                      move.b     d6,(a1)+
[0001195c] 5689                      addq.l     #3,a1
[0001195e] 5541                      subq.w     #2,d1
[00011960] 6ec8                      bgt.s      $0001192A
[00011962] 660c                      bne.s      $00011970
[00011964] d442                      add.w      d2,d2
[00011966] 6406                      bcc.s      $0001196E
[00011968] 328c                      move.w     a4,(a1)
[0001196a] 1346 0002                 move.b     d6,2(a1)
[0001196e] 5689                      addq.l     #3,a1
[00011970] 720f                      moveq.l    #15,d1
[00011972] b641                      cmp.w      d1,d3
[00011974] 6c8a                      bge.s      $00011900
[00011976] 3203                      move.w     d3,d1
[00011978] 6a86                      bpl.s      $00011900
[0001197a] d0ca                      adda.w     a2,a0
[0001197c] d2cb                      adda.w     a3,a1
[0001197e] 51cd ff76                 dbf        d5,$000118F6
[00011982] 4e75                      rts
[00011984] 3604                      move.w     d4,d3
[00011986] 3418                      move.w     (a0)+,d2
[00011988] e17a                      rol.w      d0,d2
[0001198a] 2200                      move.l     d0,d1
[0001198c] 6004                      bra.s      $00011992
[0001198e] 3418                      move.w     (a0)+,d2
[00011990] 4841                      swap       d1
[00011992] 3209                      move.w     a1,d1
[00011994] c27c 0001                 and.w      #$0001,d1
[00011998] 6604                      bne.s      $0001199E
[0001199a] 4841                      swap       d1
[0001199c] 6012                      bra.s      $000119B0
[0001199e] 4841                      swap       d1
[000119a0] 5341                      subq.w     #1,d1
[000119a2] 5343                      subq.w     #1,d3
[000119a4] d442                      add.w      d2,d2
[000119a6] 6406                      bcc.s      $000119AE
[000119a8] 4611                      not.b      (a1)
[000119aa] 4669 0001                 not.w      1(a1)
[000119ae] 5689                      addq.l     #3,a1
[000119b0] 9641                      sub.w      d1,d3
[000119b2] 5343                      subq.w     #1,d3
[000119b4] 5441                      addq.w     #2,d1
[000119b6] 6028                      bra.s      $000119E0
[000119b8] d442                      add.w      d2,d2
[000119ba] 651c                      bcs.s      $000119D8
[000119bc] d442                      add.w      d2,d2
[000119be] 650a                      bcs.s      $000119CA
[000119c0] 5c89                      addq.l     #6,a1
[000119c2] 5541                      subq.w     #2,d1
[000119c4] 6ef2                      bgt.s      $000119B8
[000119c6] 672a                      beq.s      $000119F2
[000119c8] 6034                      bra.s      $000119FE
[000119ca] 5689                      addq.l     #3,a1
[000119cc] 4619                      not.b      (a1)+
[000119ce] 4659                      not.w      (a1)+
[000119d0] 5541                      subq.w     #2,d1
[000119d2] 6ee4                      bgt.s      $000119B8
[000119d4] 671c                      beq.s      $000119F2
[000119d6] 6026                      bra.s      $000119FE
[000119d8] 4659                      not.w      (a1)+
[000119da] d442                      add.w      d2,d2
[000119dc] 640a                      bcc.s      $000119E8
[000119de] 4699                      not.l      (a1)+
[000119e0] 5541                      subq.w     #2,d1
[000119e2] 6ed4                      bgt.s      $000119B8
[000119e4] 670c                      beq.s      $000119F2
[000119e6] 6016                      bra.s      $000119FE
[000119e8] 4619                      not.b      (a1)+
[000119ea] 5689                      addq.l     #3,a1
[000119ec] 5541                      subq.w     #2,d1
[000119ee] 6ec8                      bgt.s      $000119B8
[000119f0] 660c                      bne.s      $000119FE
[000119f2] d442                      add.w      d2,d2
[000119f4] 6406                      bcc.s      $000119FC
[000119f6] 4651                      not.w      (a1)
[000119f8] 4629 0002                 not.b      2(a1)
[000119fc] 5689                      addq.l     #3,a1
[000119fe] 720f                      moveq.l    #15,d1
[00011a00] b641                      cmp.w      d1,d3
[00011a02] 6c8a                      bge.s      $0001198E
[00011a04] 3203                      move.w     d3,d1
[00011a06] 6a86                      bpl.s      $0001198E
[00011a08] d0ca                      adda.w     a2,a0
[00011a0a] d2cb                      adda.w     a3,a1
[00011a0c] 51cd ff76                 dbf        d5,$00011984
[00011a10] 4e75                      rts
[00011a12] 2c07                      move.l     d7,d6
[00011a14] 4846                      swap       d6
[00011a16] 3604                      move.w     d4,d3
[00011a18] 3418                      move.w     (a0)+,d2
[00011a1a] e17a                      rol.w      d0,d2
[00011a1c] 2200                      move.l     d0,d1
[00011a1e] 6004                      bra.s      $00011A24
[00011a20] 3418                      move.w     (a0)+,d2
[00011a22] 4841                      swap       d1
[00011a24] 3209                      move.w     a1,d1
[00011a26] c27c 0001                 and.w      #$0001,d1
[00011a2a] 6604                      bne.s      $00011A30
[00011a2c] 4841                      swap       d1
[00011a2e] 6012                      bra.s      $00011A42
[00011a30] 4841                      swap       d1
[00011a32] 5341                      subq.w     #1,d1
[00011a34] 5343                      subq.w     #1,d3
[00011a36] d442                      add.w      d2,d2
[00011a38] 6506                      bcs.s      $00011A40
[00011a3a] 1286                      move.b     d6,(a1)
[00011a3c] 3347 0001                 move.w     d7,1(a1)
[00011a40] 5689                      addq.l     #3,a1
[00011a42] 9641                      sub.w      d1,d3
[00011a44] 5343                      subq.w     #1,d3
[00011a46] 5441                      addq.w     #2,d1
[00011a48] 600c                      bra.s      $00011A56
[00011a4a] d442                      add.w      d2,d2
[00011a4c] 651c                      bcs.s      $00011A6A
[00011a4e] 32cd                      move.w     a5,(a1)+
[00011a50] d442                      add.w      d2,d2
[00011a52] 650a                      bcs.s      $00011A5E
[00011a54] 22c7                      move.l     d7,(a1)+
[00011a56] 5541                      subq.w     #2,d1
[00011a58] 6ef0                      bgt.s      $00011A4A
[00011a5a] 6728                      beq.s      $00011A84
[00011a5c] 6032                      bra.s      $00011A90
[00011a5e] 12c7                      move.b     d7,(a1)+
[00011a60] 5689                      addq.l     #3,a1
[00011a62] 5541                      subq.w     #2,d1
[00011a64] 6ee4                      bgt.s      $00011A4A
[00011a66] 671c                      beq.s      $00011A84
[00011a68] 6026                      bra.s      $00011A90
[00011a6a] d442                      add.w      d2,d2
[00011a6c] 640a                      bcc.s      $00011A78
[00011a6e] 5c89                      addq.l     #6,a1
[00011a70] 5541                      subq.w     #2,d1
[00011a72] 6ed6                      bgt.s      $00011A4A
[00011a74] 670e                      beq.s      $00011A84
[00011a76] 6018                      bra.s      $00011A90
[00011a78] 5689                      addq.l     #3,a1
[00011a7a] 12c6                      move.b     d6,(a1)+
[00011a7c] 32c7                      move.w     d7,(a1)+
[00011a7e] 5541                      subq.w     #2,d1
[00011a80] 6ec8                      bgt.s      $00011A4A
[00011a82] 660c                      bne.s      $00011A90
[00011a84] d442                      add.w      d2,d2
[00011a86] 6506                      bcs.s      $00011A8E
[00011a88] 328d                      move.w     a5,(a1)
[00011a8a] 1347 0002                 move.b     d7,2(a1)
[00011a8e] 5689                      addq.l     #3,a1
[00011a90] 720f                      moveq.l    #15,d1
[00011a92] b641                      cmp.w      d1,d3
[00011a94] 6c8a                      bge.s      $00011A20
[00011a96] 3203                      move.w     d3,d1
[00011a98] 6a86                      bpl.s      $00011A20
[00011a9a] d0ca                      adda.w     a2,a0
[00011a9c] d2cb                      adda.w     a3,a1
[00011a9e] 51cd ff76                 dbf        d5,$00011A16
[00011aa2] 4e75                      rts
[00011aa4] 4e75                      rts
[00011aa6] bc44                      cmp.w      d4,d6
[00011aa8] 6600 184c                 bne        $000132F6
[00011aac] be45                      cmp.w      d5,d7
[00011aae] 6600 1846                 bne        $000132F6
[00011ab2] 08ae 0004 01ef            bclr       #4,495(a6)
[00011ab8] 6600 fcf8                 bne        $000117B2
[00011abc] 7e0f                      moveq.l    #15,d7
[00011abe] ce6e 01ee                 and.w      494(a6),d7
[00011ac2] 206e 01c2                 movea.l    450(a6),a0
[00011ac6] 226e 01d6                 movea.l    470(a6),a1
[00011aca] 346e 01c6                 movea.w    454(a6),a2
[00011ace] 366e 01da                 movea.w    474(a6),a3
[00011ad2] 3c2e 01c8                 move.w     456(a6),d6
[00011ad6] bc6e 01dc                 cmp.w      476(a6),d6
[00011ada] 66c8                      bne.s      $00011AA4
[00011adc] c0fc 0018                 mulu.w     #$0018,d0
[00011ae0] c4fc 0018                 mulu.w     #$0018,d2
[00011ae4] 5244                      addq.w     #1,d4
[00011ae6] c8fc 0018                 mulu.w     #$0018,d4
[00011aea] 5344                      subq.w     #1,d4
[00011aec] e74f                      lsl.w      #3,d7
[00011aee] 2848                      movea.l    a0,a4
[00011af0] 2a49                      movea.l    a1,a5
[00011af2] 3c0a                      move.w     a2,d6
[00011af4] ccc1                      mulu.w     d1,d6
[00011af6] d1c6                      adda.l     d6,a0
[00011af8] 3c00                      move.w     d0,d6
[00011afa] e84e                      lsr.w      #4,d6
[00011afc] dc46                      add.w      d6,d6
[00011afe] d0c6                      adda.w     d6,a0
[00011b00] 3c0b                      move.w     a3,d6
[00011b02] ccc3                      mulu.w     d3,d6
[00011b04] d3c6                      adda.l     d6,a1
[00011b06] 3c02                      move.w     d2,d6
[00011b08] e84e                      lsr.w      #4,d6
[00011b0a] dc46                      add.w      d6,d6
[00011b0c] d2c6                      adda.w     d6,a1
[00011b0e] b1c9                      cmpa.l     a1,a0
[00011b10] 623e                      bhi.s      $00011B50
[00011b12] 6724                      beq.s      $00011B38
[00011b14] d0ca                      adda.w     a2,a0
[00011b16] b3c8                      cmpa.l     a0,a1
[00011b18] 6500 0c28                 bcs        $00012742
[00011b1c] 90ca                      suba.w     a2,a0
[00011b1e] 3c0a                      move.w     a2,d6
[00011b20] ccc5                      mulu.w     d5,d6
[00011b22] d1c6                      adda.l     d6,a0
[00011b24] 3c0b                      move.w     a3,d6
[00011b26] ccc5                      mulu.w     d5,d6
[00011b28] d3c6                      adda.l     d6,a1
[00011b2a] 3c0a                      move.w     a2,d6
[00011b2c] 4446                      neg.w      d6
[00011b2e] 3446                      movea.w    d6,a2
[00011b30] 3c0b                      move.w     a3,d6
[00011b32] 4446                      neg.w      d6
[00011b34] 3646                      movea.w    d6,a3
[00011b36] 6018                      bra.s      $00011B50
[00011b38] 7c0f                      moveq.l    #15,d6
[00011b3a] cc40                      and.w      d0,d6
[00011b3c] 3f06                      move.w     d6,-(a7)
[00011b3e] 7c0f                      moveq.l    #15,d6
[00011b40] cc42                      and.w      d2,d6
[00011b42] 9c5f                      sub.w      (a7)+,d6
[00011b44] 6e00 0bfc                 bgt        $00012742
[00011b48] 6606                      bne.s      $00011B50
[00011b4a] b6ca                      cmpa.w     a2,a3
[00011b4c] 6e00 0bf4                 bgt        $00012742
[00011b50] 3a47                      movea.w    d7,a5
[00011b52] 7c0f                      moveq.l    #15,d6
[00011b54] c046                      and.w      d6,d0
[00011b56] 3e00                      move.w     d0,d7
[00011b58] de44                      add.w      d4,d7
[00011b5a] e84f                      lsr.w      #4,d7
[00011b5c] 3602                      move.w     d2,d3
[00011b5e] c646                      and.w      d6,d3
[00011b60] 9043                      sub.w      d3,d0
[00011b62] 3202                      move.w     d2,d1
[00011b64] c246                      and.w      d6,d1
[00011b66] d244                      add.w      d4,d1
[00011b68] e849                      lsr.w      #4,d1
[00011b6a] 9e41                      sub.w      d1,d7
[00011b6c] d842                      add.w      d2,d4
[00011b6e] 4644                      not.w      d4
[00011b70] c846                      and.w      d6,d4
[00011b72] 76ff                      moveq.l    #-1,d3
[00011b74] e96b                      lsl.w      d4,d3
[00011b76] cc42                      and.w      d2,d6
[00011b78] 74ff                      moveq.l    #-1,d2
[00011b7a] ec6a                      lsr.w      d6,d2
[00011b7c] 3801                      move.w     d1,d4
[00011b7e] d844                      add.w      d4,d4
[00011b80] 94c4                      suba.w     d4,a2
[00011b82] 96c4                      suba.w     d4,a3
[00011b84] 3807                      move.w     d7,d4
[00011b86] 7c04                      moveq.l    #4,d6
[00011b88] 7e00                      moveq.l    #0,d7
[00011b8a] 49fa 007c                 lea.l      $00011C08(pc),a4
[00011b8e] 4a40                      tst.w      d0
[00011b90] 674c                      beq.s      $00011BDE
[00011b92] 6d2c                      blt.s      $00011BC0
[00011b94] 49fa 00f2                 lea.l      $00011C88(pc),a4
[00011b98] 4a41                      tst.w      d1
[00011b9a] 6608                      bne.s      $00011BA4
[00011b9c] 4a44                      tst.w      d4
[00011b9e] 6604                      bne.s      $00011BA4
[00011ba0] 7c0a                      moveq.l    #10,d6
[00011ba2] 603a                      bra.s      $00011BDE
[00011ba4] 7c04                      moveq.l    #4,d6
[00011ba6] 554a                      subq.w     #2,a2
[00011ba8] 4a44                      tst.w      d4
[00011baa] 6e02                      bgt.s      $00011BAE
[00011bac] 7e02                      moveq.l    #2,d7
[00011bae] b07c 0008                 cmp.w      #$0008,d0
[00011bb2] 6f2a                      ble.s      $00011BDE
[00011bb4] 49fa 0152                 lea.l      $00011D08(pc),a4
[00011bb8] 5340                      subq.w     #1,d0
[00011bba] 0a40 000f                 eori.w     #$000F,d0
[00011bbe] 601e                      bra.s      $00011BDE
[00011bc0] 49fa 0146                 lea.l      $00011D08(pc),a4
[00011bc4] 4440                      neg.w      d0
[00011bc6] 7c08                      moveq.l    #8,d6
[00011bc8] 4a44                      tst.w      d4
[00011bca] 6a02                      bpl.s      $00011BCE
[00011bcc] 7e02                      moveq.l    #2,d7
[00011bce] 0c40 0008                 cmpi.w     #$0008,d0
[00011bd2] 6f0a                      ble.s      $00011BDE
[00011bd4] 49fa 00b2                 lea.l      $00011C88(pc),a4
[00011bd8] 5340                      subq.w     #1,d0
[00011bda] 0a40 000f                 eori.w     #$000F,d0
[00011bde] dbcc                      adda.l     a4,a5
[00011be0] 381d                      move.w     (a5)+,d4
[00011be2] dc44                      add.w      d4,d6
[00011be4] de5d                      add.w      (a5)+,d7
[00011be6] 4a41                      tst.w      d1
[00011be8] 660c                      bne.s      $00011BF6
[00011bea] 3e15                      move.w     (a5),d7
[00011bec] c443                      and.w      d3,d2
[00011bee] 7600                      moveq.l    #0,d3
[00011bf0] 7200                      moveq.l    #0,d1
[00011bf2] 554a                      subq.w     #2,a2
[00011bf4] 554b                      subq.w     #2,a3
[00011bf6] 5541                      subq.w     #2,d1
[00011bf8] 49fa 000e                 lea.l      $00011C08(pc),a4
[00011bfc] 4bfa 000a                 lea.l      $00011C08(pc),a5
[00011c00] d8c6                      adda.w     d6,a4
[00011c02] dac7                      adda.w     d7,a5
[00011c04] 4efb 4002                 jmp        $00011C08(pc,d4.w)
[00011c08] 0180                      bclr       d0,d0
[00011c0a] 01a2                      bclr       d0,-(a2)
[00011c0c] 01a4                      bclr       d0,-(a4)
[00011c0e] 0000 01b0                 ori.b      #$B0,d0
[00011c12] 01c8 01d2                 movep.l    d0,466(a0)
[00011c16] 0000 0262                 ori.b      #$62,d0
[00011c1a] 027e 028a                 andi.w     #$028A,???
[00011c1e] 0000 0326                 ori.b      #$26,d0
[00011c22] 0000                      dc.w       $0000
[00011c24] 0000                      dc.w       $0000
[00011c26] 0000 04a6                 ori.b      #$A6,d0
[00011c2a] 04be 04c6 0000            subi.l     #$04C60000,???
[00011c30] 0552                      bchg       d2,(a2)
[00011c32] 0552                      bchg       d2,(a2)
[00011c34] 0552                      bchg       d2,(a2)
[00011c36] 0000 0554                 ori.b      #$54,d0
[00011c3a] 0568 056e                 bchg       d2,1390(a0)
[00011c3e] 0000 05ee                 ori.b      #$EE,d0
[00011c42] 0602 0608                 addi.b     #$08,d2
[00011c46] 0000 06c2                 ori.b      #$C2,d0
[00011c4a] 06da 06e2                 callm      #$06E2,(a2)+ ; 68020 only
[00011c4e] 0000 076c                 ori.b      #$6C,d0
[00011c52] 0784                      bclr       d3,d4
[00011c54] 078c 0000                 movep.w    d3,0(a4)
[00011c58] 0818 0834                 btst       #2100,(a0)+
[00011c5c] 0836 0000 0840            btst       #0,64(a6,d0.l)
[00011c62] 0858 0860                 bchg       #2144,(a0)+
[00011c66] 0000 08ec                 ori.b      #$EC,d0
[00011c6a] 090a 0918                 movep.w    2328(a2),d4
[00011c6e] 0000 09bc                 ori.b      #$BC,d0
[00011c72] 09d4                      bset       d4,(a4)
[00011c74] 09dc                      bset       d4,(a4)+
[00011c76] 0000 0a68                 ori.b      #$68,d0
[00011c7a] 0a80 0a88 0000            eori.l     #$0A880000,d0
[00011c80] 0b14                      btst       d5,(a4)
[00011c82] 0b30 0b32 0000 0180 01a2  btst       d5,([$00000180,a0,d0.l*2],$01A2) ; 68020+ only
[00011c8c] 01a4                      bclr       d0,-(a4)
[00011c8e] 0000 021e                 ori.b      #$1E,d0
[00011c92] 024a 0258                 andi.w     #$0258,a2 ; apollo only
[00011c96] 0000 02dc                 ori.b      #$DC,d0
[00011c9a] 030c 031c                 movep.w    796(a4),d1
[00011c9e] 0000 0446                 ori.b      #$46,d0
[00011ca2] 048e 049c 0000            subi.l     #$049C0000,a6 ; apollo only
[00011ca8] 0510                      btst       d2,(a0)
[00011caa] 053c 0548                 btst       d2,#$48
[00011cae] 0000 0552                 ori.b      #$52,d0
[00011cb2] 0552                      bchg       d2,(a2)
[00011cb4] 0552                      bchg       d2,(a2)
[00011cb6] 0000 05b2                 ori.b      #$B2,d0
[00011cba] 05da                      bset       d2,(a2)+
[00011cbc] 05e4                      bset       d2,-(a4)
[00011cbe] 0000 066a                 ori.b      #$6A,d0
[00011cc2] 06ae 06b8 0000 072a       addi.l     #$06B80000,1834(a6)
[00011cca] 0756                      bchg       d3,(a6)
[00011ccc] 0762                      bchg       d3,-(a2)
[00011cce] 0000 07d6                 ori.b      #$D6,d0
[00011cd2] 0802 080e                 btst       #2062,d2
[00011cd6] 0000 0818                 ori.b      #$18,d0
[00011cda] 0834 0836 0000            btst       #2102,0(a4,d0.w)
[00011ce0] 08aa 08d6 08e2            bclr       #2262,2274(a2)
[00011ce6] 0000 096e                 ori.b      #$6E,d0
[00011cea] 09a0                      bclr       d4,-(a0)
[00011cec] 09b2 0000                 bclr       d4,0(a2,d0.w)
[00011cf0] 0a26 0a52                 eori.b     #$52,-(a6)
[00011cf4] 0a5e 0000                 eori.w     #$0000,(a6)+
[00011cf8] 0ad2 0afe                 cas.b      d6,d3,(a2) ; 68020+ only
[00011cfc] 0b0a 0000                 movep.w    0(a2),d5
[00011d00] 0b14                      btst       d5,(a4)
[00011d02] 0b30 0b32 0000 0180 01a2  btst       d5,([$00000180,a0,d0.l*2],$01A2) ; 68020+ only
[00011d0c] 01a4                      bclr       d0,-(a4)
[00011d0e] 0000 01dc                 ori.b      #$DC,d0
[00011d12] 0208 0214                 andi.b     #$14,a0 ; apollo only
[00011d16] 0000 0294                 ori.b      #$94,d0
[00011d1a] 02c4                      byterev.l  d4 ; ColdFire isa_c only
[00011d1c] 02d2 0000                 cmp2.w     (a2),d0 ; 68020+ only
[00011d20] 03e6                      bset       d1,-(a6)
[00011d22] 0430 043c 0000            subi.b     #$3C,0(a0,d0.w)
[00011d28] 04d0 04fc                 cmp2.l     (a0),d0 ; 68020+ only
[00011d2c] 0506                      btst       d2,d6
[00011d2e] 0000 0552                 ori.b      #$52,d0
[00011d32] 0552                      bchg       d2,(a2)
[00011d34] 0552                      bchg       d2,(a2)
[00011d36] 0000 0578                 ori.b      #$78,d0
[00011d3a] 05a0                      bclr       d2,-(a0)
[00011d3c] 05a8 0000                 bclr       d2,0(a0)
[00011d40] 0612 0658                 addi.b     #$58,(a2)
[00011d44] 0660 0000                 addi.w     #$0000,-(a0)
[00011d48] 06ec 0716 0720            callm      #$0716,1824(a4) ; 68020 only
[00011d4e] 0000 0796                 ori.b      #$96,d0
[00011d52] 07c2                      bset       d3,d2
[00011d54] 07cc 0000                 movep.l    d3,0(a4)
[00011d58] 0818 0834                 btst       #2100,(a0)+
[00011d5c] 0836 0000 086a            btst       #0,106(a6,d0.l)
[00011d62] 0896 08a0                 bclr       #2208,(a6)
[00011d66] 0000 0922                 ori.b      #$22,d0
[00011d6a] 0954                      bchg       d4,(a4)
[00011d6c] 0964                      bchg       d4,-(a4)
[00011d6e] 0000 09e6                 ori.b      #$E6,d0
[00011d72] 0a12 0a1c                 eori.b     #$1C,(a2)
[00011d76] 0000 0a92                 ori.b      #$92,d0
[00011d7a] 0abe 0ac8 0000            eori.l     #$0AC80000,???
[00011d80] 0b14                      btst       d5,(a4)
[00011d82] 0b30 0b32 0000 4642 4643  btst       d5,([$00004642,a0,d0.l*2],$4643) ; 68020+ only
[00011d8c] 7e00                      moveq.l    #0,d7
[00011d8e] 4bfa 001c                 lea.l      $00011DAC(pc),a5
[00011d92] b67c ffff                 cmp.w      #$FFFF,d3
[00011d96] 6704                      beq.s      $00011D9C
[00011d98] 4bfa 0010                 lea.l      $00011DAA(pc),a5
[00011d9c] c559                      and.w      d2,(a1)+
[00011d9e] 3801                      move.w     d1,d4
[00011da0] 6b06                      bmi.s      $00011DA8
[00011da2] 32c7                      move.w     d7,(a1)+
[00011da4] 51cc fffc                 dbf        d4,$00011DA2
[00011da8] 4ed5                      jmp        (a5)
[00011daa] c751                      and.w      d3,(a1)
[00011dac] d2cb                      adda.w     a3,a1
[00011dae] 51cd ffec                 dbf        d5,$00011D9C
[00011db2] 4642                      not.w      d2
[00011db4] 4643                      not.w      d3
[00011db6] 4e75                      rts
[00011db8] 3c18                      move.w     (a0)+,d6
[00011dba] 4642                      not.w      d2
[00011dbc] 8c42                      or.w       d2,d6
[00011dbe] 4642                      not.w      d2
[00011dc0] cd59                      and.w      d6,(a1)+
[00011dc2] 3801                      move.w     d1,d4
[00011dc4] 6b08                      bmi.s      $00011DCE
[00011dc6] 3c18                      move.w     (a0)+,d6
[00011dc8] cd59                      and.w      d6,(a1)+
[00011dca] 51cc fffa                 dbf        d4,$00011DC6
[00011dce] 4ed5                      jmp        (a5)
[00011dd0] 3c10                      move.w     (a0),d6
[00011dd2] 4643                      not.w      d3
[00011dd4] 8c43                      or.w       d3,d6
[00011dd6] 4643                      not.w      d3
[00011dd8] cd51                      and.w      d6,(a1)
[00011dda] d0ca                      adda.w     a2,a0
[00011ddc] d2cb                      adda.w     a3,a1
[00011dde] 51cd ffd8                 dbf        d5,$00011DB8
[00011de2] 4e75                      rts
[00011de4] 3c18                      move.w     (a0)+,d6
[00011de6] 4ed4                      jmp        (a4)
[00011de8] 4846                      swap       d6
[00011dea] 3c18                      move.w     (a0)+,d6
[00011dec] 3e06                      move.w     d6,d7
[00011dee] e0be                      ror.l      d0,d6
[00011df0] 4642                      not.w      d2
[00011df2] 8c42                      or.w       d2,d6
[00011df4] 4642                      not.w      d2
[00011df6] cd59                      and.w      d6,(a1)+
[00011df8] 3801                      move.w     d1,d4
[00011dfa] 6b10                      bmi.s      $00011E0C
[00011dfc] 3c07                      move.w     d7,d6
[00011dfe] 4846                      swap       d6
[00011e00] 3c18                      move.w     (a0)+,d6
[00011e02] 3e06                      move.w     d6,d7
[00011e04] e0be                      ror.l      d0,d6
[00011e06] cd59                      and.w      d6,(a1)+
[00011e08] 51cc fff2                 dbf        d4,$00011DFC
[00011e0c] 4847                      swap       d7
[00011e0e] 4ed5                      jmp        (a5)
[00011e10] 3e10                      move.w     (a0),d7
[00011e12] e0bf                      ror.l      d0,d7
[00011e14] 4643                      not.w      d3
[00011e16] 8e43                      or.w       d3,d7
[00011e18] 4643                      not.w      d3
[00011e1a] cf51                      and.w      d7,(a1)
[00011e1c] d0ca                      adda.w     a2,a0
[00011e1e] d2cb                      adda.w     a3,a1
[00011e20] 51cd ffc2                 dbf        d5,$00011DE4
[00011e24] 4e75                      rts
[00011e26] 3c18                      move.w     (a0)+,d6
[00011e28] 4ed4                      jmp        (a4)
[00011e2a] 4846                      swap       d6
[00011e2c] 3c18                      move.w     (a0)+,d6
[00011e2e] 4846                      swap       d6
[00011e30] 2e06                      move.l     d6,d7
[00011e32] e1be                      rol.l      d0,d6
[00011e34] 4642                      not.w      d2
[00011e36] 8c42                      or.w       d2,d6
[00011e38] 4642                      not.w      d2
[00011e3a] cd59                      and.w      d6,(a1)+
[00011e3c] 3801                      move.w     d1,d4
[00011e3e] 6b10                      bmi.s      $00011E50
[00011e40] 2c07                      move.l     d7,d6
[00011e42] 3c18                      move.w     (a0)+,d6
[00011e44] 4846                      swap       d6
[00011e46] 2e06                      move.l     d6,d7
[00011e48] e1be                      rol.l      d0,d6
[00011e4a] cd59                      and.w      d6,(a1)+
[00011e4c] 51cc fff2                 dbf        d4,$00011E40
[00011e50] 4ed5                      jmp        (a5)
[00011e52] 3e10                      move.w     (a0),d7
[00011e54] 4847                      swap       d7
[00011e56] e1bf                      rol.l      d0,d7
[00011e58] 4643                      not.w      d3
[00011e5a] 8e43                      or.w       d3,d7
[00011e5c] 4643                      not.w      d3
[00011e5e] cf51                      and.w      d7,(a1)
[00011e60] d0ca                      adda.w     a2,a0
[00011e62] d2cb                      adda.w     a3,a1
[00011e64] 51cd ffc0                 dbf        d5,$00011E26
[00011e68] 4e75                      rts
[00011e6a] 3c18                      move.w     (a0)+,d6
[00011e6c] b551                      eor.w      d2,(a1)
[00011e6e] 4642                      not.w      d2
[00011e70] 8c42                      or.w       d2,d6
[00011e72] 4642                      not.w      d2
[00011e74] cd59                      and.w      d6,(a1)+
[00011e76] 3801                      move.w     d1,d4
[00011e78] 6b0a                      bmi.s      $00011E84
[00011e7a] 3c18                      move.w     (a0)+,d6
[00011e7c] 4651                      not.w      (a1)
[00011e7e] cd59                      and.w      d6,(a1)+
[00011e80] 51cc fff8                 dbf        d4,$00011E7A
[00011e84] 4ed5                      jmp        (a5)
[00011e86] 3c10                      move.w     (a0),d6
[00011e88] b751                      eor.w      d3,(a1)
[00011e8a] 4643                      not.w      d3
[00011e8c] 8c43                      or.w       d3,d6
[00011e8e] 4643                      not.w      d3
[00011e90] cd51                      and.w      d6,(a1)
[00011e92] d0ca                      adda.w     a2,a0
[00011e94] d2cb                      adda.w     a3,a1
[00011e96] 51cd ffd2                 dbf        d5,$00011E6A
[00011e9a] 4e75                      rts
[00011e9c] 3c18                      move.w     (a0)+,d6
[00011e9e] 4ed4                      jmp        (a4)
[00011ea0] 4846                      swap       d6
[00011ea2] 3c18                      move.w     (a0)+,d6
[00011ea4] 3e06                      move.w     d6,d7
[00011ea6] e0be                      ror.l      d0,d6
[00011ea8] b551                      eor.w      d2,(a1)
[00011eaa] 4642                      not.w      d2
[00011eac] 8c42                      or.w       d2,d6
[00011eae] 4642                      not.w      d2
[00011eb0] cd59                      and.w      d6,(a1)+
[00011eb2] 3801                      move.w     d1,d4
[00011eb4] 6b12                      bmi.s      $00011EC8
[00011eb6] 3c07                      move.w     d7,d6
[00011eb8] 4846                      swap       d6
[00011eba] 3c18                      move.w     (a0)+,d6
[00011ebc] 3e06                      move.w     d6,d7
[00011ebe] e0be                      ror.l      d0,d6
[00011ec0] 4651                      not.w      (a1)
[00011ec2] cd59                      and.w      d6,(a1)+
[00011ec4] 51cc fff0                 dbf        d4,$00011EB6
[00011ec8] 4847                      swap       d7
[00011eca] 4ed5                      jmp        (a5)
[00011ecc] 3e10                      move.w     (a0),d7
[00011ece] e0bf                      ror.l      d0,d7
[00011ed0] b751                      eor.w      d3,(a1)
[00011ed2] 4643                      not.w      d3
[00011ed4] 8e43                      or.w       d3,d7
[00011ed6] 4643                      not.w      d3
[00011ed8] cf51                      and.w      d7,(a1)
[00011eda] d0ca                      adda.w     a2,a0
[00011edc] d2cb                      adda.w     a3,a1
[00011ede] 51cd ffbc                 dbf        d5,$00011E9C
[00011ee2] 4e75                      rts
[00011ee4] 3c18                      move.w     (a0)+,d6
[00011ee6] 4ed4                      jmp        (a4)
[00011ee8] 4846                      swap       d6
[00011eea] 3c18                      move.w     (a0)+,d6
[00011eec] 4846                      swap       d6
[00011eee] 2e06                      move.l     d6,d7
[00011ef0] e1be                      rol.l      d0,d6
[00011ef2] b551                      eor.w      d2,(a1)
[00011ef4] 4642                      not.w      d2
[00011ef6] 8c42                      or.w       d2,d6
[00011ef8] 4642                      not.w      d2
[00011efa] cd59                      and.w      d6,(a1)+
[00011efc] 3801                      move.w     d1,d4
[00011efe] 6b12                      bmi.s      $00011F12
[00011f00] 2c07                      move.l     d7,d6
[00011f02] 3c18                      move.w     (a0)+,d6
[00011f04] 4846                      swap       d6
[00011f06] 2e06                      move.l     d6,d7
[00011f08] e1be                      rol.l      d0,d6
[00011f0a] 4651                      not.w      (a1)
[00011f0c] cd59                      and.w      d6,(a1)+
[00011f0e] 51cc fff0                 dbf        d4,$00011F00
[00011f12] 4ed5                      jmp        (a5)
[00011f14] 3e10                      move.w     (a0),d7
[00011f16] 4847                      swap       d7
[00011f18] e1bf                      rol.l      d0,d7
[00011f1a] b751                      eor.w      d3,(a1)
[00011f1c] 4643                      not.w      d3
[00011f1e] 8e43                      or.w       d3,d7
[00011f20] 4643                      not.w      d3
[00011f22] cf51                      and.w      d7,(a1)
[00011f24] d0ca                      adda.w     a2,a0
[00011f26] d2cb                      adda.w     a3,a1
[00011f28] 51cd ffba                 dbf        d5,$00011EE4
[00011f2c] 4e75                      rts
[00011f2e] 3801                      move.w     d1,d4
[00011f30] 6b00 0084                 bmi        $00011FB6
[00011f34] e24c                      lsr.w      #1,d4
[00011f36] 6522                      bcs.s      $00011F5A
[00011f38] 49fa 0040                 lea.l      $00011F7A(pc),a4
[00011f3c] 6606                      bne.s      $00011F44
[00011f3e] 4bfa 0062                 lea.l      $00011FA2(pc),a5
[00011f42] 6028                      bra.s      $00011F6C
[00011f44] 5344                      subq.w     #1,d4
[00011f46] 3004                      move.w     d4,d0
[00011f48] e84c                      lsr.w      #4,d4
[00011f4a] 3204                      move.w     d4,d1
[00011f4c] 4640                      not.w      d0
[00011f4e] 0240 000f                 andi.w     #$000F,d0
[00011f52] d040                      add.w      d0,d0
[00011f54] 4bfb 0028                 lea.l      $00011F7E(pc,d0.w),a5
[00011f58] 6012                      bra.s      $00011F6C
[00011f5a] 3004                      move.w     d4,d0
[00011f5c] e84c                      lsr.w      #4,d4
[00011f5e] 3204                      move.w     d4,d1
[00011f60] 4640                      not.w      d0
[00011f62] 0240 000f                 andi.w     #$000F,d0
[00011f66] d040                      add.w      d0,d0
[00011f68] 49fb 0014                 lea.l      $00011F7E(pc,d0.w),a4
[00011f6c] 3c18                      move.w     (a0)+,d6
[00011f6e] 4646                      not.w      d6
[00011f70] cc42                      and.w      d2,d6
[00011f72] 8551                      or.w       d2,(a1)
[00011f74] bd59                      eor.w      d6,(a1)+
[00011f76] 3801                      move.w     d1,d4
[00011f78] 4ed4                      jmp        (a4)
[00011f7a] 32d8                      move.w     (a0)+,(a1)+
[00011f7c] 4ed5                      jmp        (a5)
[00011f7e] 22d8                      move.l     (a0)+,(a1)+
[00011f80] 22d8                      move.l     (a0)+,(a1)+
[00011f82] 22d8                      move.l     (a0)+,(a1)+
[00011f84] 22d8                      move.l     (a0)+,(a1)+
[00011f86] 22d8                      move.l     (a0)+,(a1)+
[00011f88] 22d8                      move.l     (a0)+,(a1)+
[00011f8a] 22d8                      move.l     (a0)+,(a1)+
[00011f8c] 22d8                      move.l     (a0)+,(a1)+
[00011f8e] 22d8                      move.l     (a0)+,(a1)+
[00011f90] 22d8                      move.l     (a0)+,(a1)+
[00011f92] 22d8                      move.l     (a0)+,(a1)+
[00011f94] 22d8                      move.l     (a0)+,(a1)+
[00011f96] 22d8                      move.l     (a0)+,(a1)+
[00011f98] 22d8                      move.l     (a0)+,(a1)+
[00011f9a] 22d8                      move.l     (a0)+,(a1)+
[00011f9c] 22d8                      move.l     (a0)+,(a1)+
[00011f9e] 51cc ffde                 dbf        d4,$00011F7E
[00011fa2] 3c10                      move.w     (a0),d6
[00011fa4] 4646                      not.w      d6
[00011fa6] cc43                      and.w      d3,d6
[00011fa8] 8751                      or.w       d3,(a1)
[00011faa] bd51                      eor.w      d6,(a1)
[00011fac] d0ca                      adda.w     a2,a0
[00011fae] d2cb                      adda.w     a3,a1
[00011fb0] 51cd ffba                 dbf        d5,$00011F6C
[00011fb4] 4e75                      rts
[00011fb6] 544a                      addq.w     #2,a2
[00011fb8] 544b                      addq.w     #2,a3
[00011fba] 4a43                      tst.w      d3
[00011fbc] 671a                      beq.s      $00011FD8
[00011fbe] 4842                      swap       d2
[00011fc0] 3403                      move.w     d3,d2
[00011fc2] 2602                      move.l     d2,d3
[00011fc4] 4683                      not.l      d3
[00011fc6] 2c10                      move.l     (a0),d6
[00011fc8] cc82                      and.l      d2,d6
[00011fca] c791                      and.l      d3,(a1)
[00011fcc] 8d91                      or.l       d6,(a1)
[00011fce] d0ca                      adda.w     a2,a0
[00011fd0] d2cb                      adda.w     a3,a1
[00011fd2] 51cd fff2                 dbf        d5,$00011FC6
[00011fd6] 4e75                      rts
[00011fd8] 3602                      move.w     d2,d3
[00011fda] 4643                      not.w      d3
[00011fdc] 3c10                      move.w     (a0),d6
[00011fde] cc42                      and.w      d2,d6
[00011fe0] c751                      and.w      d3,(a1)
[00011fe2] 8d51                      or.w       d6,(a1)
[00011fe4] d0ca                      adda.w     a2,a0
[00011fe6] d2cb                      adda.w     a3,a1
[00011fe8] 51cd fff2                 dbf        d5,$00011FDC
[00011fec] 4e75                      rts
[00011fee] 3c18                      move.w     (a0)+,d6
[00011ff0] 4ed4                      jmp        (a4)
[00011ff2] 4846                      swap       d6
[00011ff4] 3c18                      move.w     (a0)+,d6
[00011ff6] 3e06                      move.w     d6,d7
[00011ff8] 4847                      swap       d7
[00011ffa] e0be                      ror.l      d0,d6
[00011ffc] 4646                      not.w      d6
[00011ffe] cc42                      and.w      d2,d6
[00012000] 8551                      or.w       d2,(a1)
[00012002] bd59                      eor.w      d6,(a1)+
[00012004] 4845                      swap       d5
[00012006] 3a01                      move.w     d1,d5
[00012008] 6b2a                      bmi.s      $00012034
[0001200a] e24d                      lsr.w      #1,d5
[0001200c] 650e                      bcs.s      $0001201C
[0001200e] 3e18                      move.w     (a0)+,d7
[00012010] 2c07                      move.l     d7,d6
[00012012] 4847                      swap       d7
[00012014] e0be                      ror.l      d0,d6
[00012016] 32c6                      move.w     d6,(a1)+
[00012018] 5345                      subq.w     #1,d5
[0001201a] 6b18                      bmi.s      $00012034
[0001201c] 2c07                      move.l     d7,d6
[0001201e] 2e18                      move.l     (a0)+,d7
[00012020] 2807                      move.l     d7,d4
[00012022] 4847                      swap       d7
[00012024] 3c07                      move.w     d7,d6
[00012026] e0be                      ror.l      d0,d6
[00012028] e0bc                      ror.l      d0,d4
[0001202a] 4846                      swap       d6
[0001202c] 3c04                      move.w     d4,d6
[0001202e] 22c6                      move.l     d6,(a1)+
[00012030] 51cd ffea                 dbf        d5,$0001201C
[00012034] 4845                      swap       d5
[00012036] 4ed5                      jmp        (a5)
[00012038] 3e10                      move.w     (a0),d7
[0001203a] e0bf                      ror.l      d0,d7
[0001203c] 4647                      not.w      d7
[0001203e] ce43                      and.w      d3,d7
[00012040] 8751                      or.w       d3,(a1)
[00012042] bf51                      eor.w      d7,(a1)
[00012044] d0ca                      adda.w     a2,a0
[00012046] d2cb                      adda.w     a3,a1
[00012048] 51cd ffa4                 dbf        d5,$00011FEE
[0001204c] 4e75                      rts
[0001204e] 3c18                      move.w     (a0)+,d6
[00012050] 4ed4                      jmp        (a4)
[00012052] 4846                      swap       d6
[00012054] 3c18                      move.w     (a0)+,d6
[00012056] 4846                      swap       d6
[00012058] 2e06                      move.l     d6,d7
[0001205a] e1be                      rol.l      d0,d6
[0001205c] 4646                      not.w      d6
[0001205e] cc42                      and.w      d2,d6
[00012060] 8551                      or.w       d2,(a1)
[00012062] bd59                      eor.w      d6,(a1)+
[00012064] 4845                      swap       d5
[00012066] 3a01                      move.w     d1,d5
[00012068] 6b28                      bmi.s      $00012092
[0001206a] e24d                      lsr.w      #1,d5
[0001206c] 650e                      bcs.s      $0001207C
[0001206e] 3e18                      move.w     (a0)+,d7
[00012070] 4847                      swap       d7
[00012072] 2c07                      move.l     d7,d6
[00012074] e1be                      rol.l      d0,d6
[00012076] 32c6                      move.w     d6,(a1)+
[00012078] 5345                      subq.w     #1,d5
[0001207a] 6b16                      bmi.s      $00012092
[0001207c] 2c07                      move.l     d7,d6
[0001207e] 2e18                      move.l     (a0)+,d7
[00012080] 4847                      swap       d7
[00012082] 3c07                      move.w     d7,d6
[00012084] 2807                      move.l     d7,d4
[00012086] e1be                      rol.l      d0,d6
[00012088] e1bc                      rol.l      d0,d4
[0001208a] 3c04                      move.w     d4,d6
[0001208c] 22c6                      move.l     d6,(a1)+
[0001208e] 51cd ffec                 dbf        d5,$0001207C
[00012092] 4845                      swap       d5
[00012094] 4ed5                      jmp        (a5)
[00012096] 3e10                      move.w     (a0),d7
[00012098] 4847                      swap       d7
[0001209a] e1bf                      rol.l      d0,d7
[0001209c] 4647                      not.w      d7
[0001209e] ce43                      and.w      d3,d7
[000120a0] 8751                      or.w       d3,(a1)
[000120a2] bf51                      eor.w      d7,(a1)
[000120a4] d0ca                      adda.w     a2,a0
[000120a6] d2cb                      adda.w     a3,a1
[000120a8] 51cd ffa4                 dbf        d5,$0001204E
[000120ac] 4e75                      rts
[000120ae] 3c18                      move.w     (a0)+,d6
[000120b0] cc42                      and.w      d2,d6
[000120b2] 4646                      not.w      d6
[000120b4] cd59                      and.w      d6,(a1)+
[000120b6] 3801                      move.w     d1,d4
[000120b8] 6b0a                      bmi.s      $000120C4
[000120ba] 3c18                      move.w     (a0)+,d6
[000120bc] 4646                      not.w      d6
[000120be] cd59                      and.w      d6,(a1)+
[000120c0] 51cc fff8                 dbf        d4,$000120BA
[000120c4] 4ed5                      jmp        (a5)
[000120c6] 3c10                      move.w     (a0),d6
[000120c8] cc43                      and.w      d3,d6
[000120ca] 4646                      not.w      d6
[000120cc] cd51                      and.w      d6,(a1)
[000120ce] d0ca                      adda.w     a2,a0
[000120d0] d2cb                      adda.w     a3,a1
[000120d2] 51cd ffda                 dbf        d5,$000120AE
[000120d6] 4e75                      rts
[000120d8] 3c18                      move.w     (a0)+,d6
[000120da] 4ed4                      jmp        (a4)
[000120dc] 4846                      swap       d6
[000120de] 3c18                      move.w     (a0)+,d6
[000120e0] 3e06                      move.w     d6,d7
[000120e2] e0be                      ror.l      d0,d6
[000120e4] cc42                      and.w      d2,d6
[000120e6] 4646                      not.w      d6
[000120e8] cd59                      and.w      d6,(a1)+
[000120ea] 3801                      move.w     d1,d4
[000120ec] 6b12                      bmi.s      $00012100
[000120ee] 3c07                      move.w     d7,d6
[000120f0] 4846                      swap       d6
[000120f2] 3c18                      move.w     (a0)+,d6
[000120f4] 3e06                      move.w     d6,d7
[000120f6] e0be                      ror.l      d0,d6
[000120f8] 4646                      not.w      d6
[000120fa] cd59                      and.w      d6,(a1)+
[000120fc] 51cc fff0                 dbf        d4,$000120EE
[00012100] 4847                      swap       d7
[00012102] 4ed5                      jmp        (a5)
[00012104] 3e10                      move.w     (a0),d7
[00012106] e0bf                      ror.l      d0,d7
[00012108] ce43                      and.w      d3,d7
[0001210a] 4647                      not.w      d7
[0001210c] cf51                      and.w      d7,(a1)
[0001210e] d0ca                      adda.w     a2,a0
[00012110] d2cb                      adda.w     a3,a1
[00012112] 51cd ffc4                 dbf        d5,$000120D8
[00012116] 4e75                      rts
[00012118] 3c18                      move.w     (a0)+,d6
[0001211a] 4ed4                      jmp        (a4)
[0001211c] 4846                      swap       d6
[0001211e] 3c18                      move.w     (a0)+,d6
[00012120] 4846                      swap       d6
[00012122] 2e06                      move.l     d6,d7
[00012124] e1be                      rol.l      d0,d6
[00012126] cc42                      and.w      d2,d6
[00012128] 4646                      not.w      d6
[0001212a] cd59                      and.w      d6,(a1)+
[0001212c] 3801                      move.w     d1,d4
[0001212e] 6b12                      bmi.s      $00012142
[00012130] 2c07                      move.l     d7,d6
[00012132] 3c18                      move.w     (a0)+,d6
[00012134] 4846                      swap       d6
[00012136] 2e06                      move.l     d6,d7
[00012138] e1be                      rol.l      d0,d6
[0001213a] 4646                      not.w      d6
[0001213c] cd59                      and.w      d6,(a1)+
[0001213e] 51cc fff0                 dbf        d4,$00012130
[00012142] 4ed5                      jmp        (a5)
[00012144] 3e10                      move.w     (a0),d7
[00012146] 4847                      swap       d7
[00012148] e1bf                      rol.l      d0,d7
[0001214a] ce43                      and.w      d3,d7
[0001214c] 4647                      not.w      d7
[0001214e] cf51                      and.w      d7,(a1)
[00012150] d0ca                      adda.w     a2,a0
[00012152] d2cb                      adda.w     a3,a1
[00012154] 51cd ffc2                 dbf        d5,$00012118
[00012158] 4e75                      rts
[0001215a] 4e75                      rts
[0001215c] 3c18                      move.w     (a0)+,d6
[0001215e] cc42                      and.w      d2,d6
[00012160] bd59                      eor.w      d6,(a1)+
[00012162] 3801                      move.w     d1,d4
[00012164] 6b08                      bmi.s      $0001216E
[00012166] 3c18                      move.w     (a0)+,d6
[00012168] bd59                      eor.w      d6,(a1)+
[0001216a] 51cc fffa                 dbf        d4,$00012166
[0001216e] 4ed5                      jmp        (a5)
[00012170] 3c10                      move.w     (a0),d6
[00012172] cc43                      and.w      d3,d6
[00012174] bd51                      eor.w      d6,(a1)
[00012176] d0ca                      adda.w     a2,a0
[00012178] d2cb                      adda.w     a3,a1
[0001217a] 51cd ffe0                 dbf        d5,$0001215C
[0001217e] 4e75                      rts
[00012180] 3c18                      move.w     (a0)+,d6
[00012182] 4ed4                      jmp        (a4)
[00012184] 4846                      swap       d6
[00012186] 3c18                      move.w     (a0)+,d6
[00012188] 3e06                      move.w     d6,d7
[0001218a] e0be                      ror.l      d0,d6
[0001218c] cc42                      and.w      d2,d6
[0001218e] bd59                      eor.w      d6,(a1)+
[00012190] 3801                      move.w     d1,d4
[00012192] 6b10                      bmi.s      $000121A4
[00012194] 3c07                      move.w     d7,d6
[00012196] 4846                      swap       d6
[00012198] 3c18                      move.w     (a0)+,d6
[0001219a] 3e06                      move.w     d6,d7
[0001219c] e0be                      ror.l      d0,d6
[0001219e] bd59                      eor.w      d6,(a1)+
[000121a0] 51cc fff2                 dbf        d4,$00012194
[000121a4] 4847                      swap       d7
[000121a6] 4ed5                      jmp        (a5)
[000121a8] 3e10                      move.w     (a0),d7
[000121aa] e0bf                      ror.l      d0,d7
[000121ac] ce43                      and.w      d3,d7
[000121ae] bf51                      eor.w      d7,(a1)
[000121b0] d0ca                      adda.w     a2,a0
[000121b2] d2cb                      adda.w     a3,a1
[000121b4] 51cd ffca                 dbf        d5,$00012180
[000121b8] 4e75                      rts
[000121ba] 3c18                      move.w     (a0)+,d6
[000121bc] 4ed4                      jmp        (a4)
[000121be] 4846                      swap       d6
[000121c0] 3c18                      move.w     (a0)+,d6
[000121c2] 4846                      swap       d6
[000121c4] 2e06                      move.l     d6,d7
[000121c6] e1be                      rol.l      d0,d6
[000121c8] cc42                      and.w      d2,d6
[000121ca] bd59                      eor.w      d6,(a1)+
[000121cc] 3801                      move.w     d1,d4
[000121ce] 6b10                      bmi.s      $000121E0
[000121d0] 2c07                      move.l     d7,d6
[000121d2] 3c18                      move.w     (a0)+,d6
[000121d4] 4846                      swap       d6
[000121d6] 2e06                      move.l     d6,d7
[000121d8] e1be                      rol.l      d0,d6
[000121da] bd59                      eor.w      d6,(a1)+
[000121dc] 51cc fff2                 dbf        d4,$000121D0
[000121e0] 4ed5                      jmp        (a5)
[000121e2] 3e10                      move.w     (a0),d7
[000121e4] 4847                      swap       d7
[000121e6] e1bf                      rol.l      d0,d7
[000121e8] ce43                      and.w      d3,d7
[000121ea] bf51                      eor.w      d7,(a1)
[000121ec] d0ca                      adda.w     a2,a0
[000121ee] d2cb                      adda.w     a3,a1
[000121f0] 51cd ffc8                 dbf        d5,$000121BA
[000121f4] 4e75                      rts
[000121f6] 3c18                      move.w     (a0)+,d6
[000121f8] cc42                      and.w      d2,d6
[000121fa] 8d59                      or.w       d6,(a1)+
[000121fc] 3801                      move.w     d1,d4
[000121fe] 6b08                      bmi.s      $00012208
[00012200] 3c18                      move.w     (a0)+,d6
[00012202] 8d59                      or.w       d6,(a1)+
[00012204] 51cc fffa                 dbf        d4,$00012200
[00012208] 4ed5                      jmp        (a5)
[0001220a] 3c10                      move.w     (a0),d6
[0001220c] cc43                      and.w      d3,d6
[0001220e] 8d51                      or.w       d6,(a1)
[00012210] d0ca                      adda.w     a2,a0
[00012212] d2cb                      adda.w     a3,a1
[00012214] 51cd ffe0                 dbf        d5,$000121F6
[00012218] 4e75                      rts
[0001221a] 3c18                      move.w     (a0)+,d6
[0001221c] 4ed4                      jmp        (a4)
[0001221e] 4846                      swap       d6
[00012220] 3c18                      move.w     (a0)+,d6
[00012222] 3e06                      move.w     d6,d7
[00012224] 4847                      swap       d7
[00012226] e0be                      ror.l      d0,d6
[00012228] cc42                      and.w      d2,d6
[0001222a] 8d59                      or.w       d6,(a1)+
[0001222c] 4845                      swap       d5
[0001222e] 3a01                      move.w     d1,d5
[00012230] 6b2a                      bmi.s      $0001225C
[00012232] e24d                      lsr.w      #1,d5
[00012234] 650e                      bcs.s      $00012244
[00012236] 3e18                      move.w     (a0)+,d7
[00012238] 2c07                      move.l     d7,d6
[0001223a] 4847                      swap       d7
[0001223c] e0be                      ror.l      d0,d6
[0001223e] 8d59                      or.w       d6,(a1)+
[00012240] 5345                      subq.w     #1,d5
[00012242] 6b18                      bmi.s      $0001225C
[00012244] 2c07                      move.l     d7,d6
[00012246] 2e18                      move.l     (a0)+,d7
[00012248] 2807                      move.l     d7,d4
[0001224a] 4847                      swap       d7
[0001224c] 3c07                      move.w     d7,d6
[0001224e] e0be                      ror.l      d0,d6
[00012250] e0bc                      ror.l      d0,d4
[00012252] 4846                      swap       d6
[00012254] 3c04                      move.w     d4,d6
[00012256] 8d99                      or.l       d6,(a1)+
[00012258] 51cd ffea                 dbf        d5,$00012244
[0001225c] 4845                      swap       d5
[0001225e] 4ed5                      jmp        (a5)
[00012260] 3e10                      move.w     (a0),d7
[00012262] e0bf                      ror.l      d0,d7
[00012264] ce43                      and.w      d3,d7
[00012266] 8f51                      or.w       d7,(a1)
[00012268] d0ca                      adda.w     a2,a0
[0001226a] d2cb                      adda.w     a3,a1
[0001226c] 51cd ffac                 dbf        d5,$0001221A
[00012270] 4e75                      rts
[00012272] 3c18                      move.w     (a0)+,d6
[00012274] 4ed4                      jmp        (a4)
[00012276] 4846                      swap       d6
[00012278] 3c18                      move.w     (a0)+,d6
[0001227a] 4846                      swap       d6
[0001227c] 2e06                      move.l     d6,d7
[0001227e] e1be                      rol.l      d0,d6
[00012280] cc42                      and.w      d2,d6
[00012282] 8d59                      or.w       d6,(a1)+
[00012284] 4845                      swap       d5
[00012286] 3a01                      move.w     d1,d5
[00012288] 6b28                      bmi.s      $000122B2
[0001228a] e24d                      lsr.w      #1,d5
[0001228c] 650e                      bcs.s      $0001229C
[0001228e] 3e18                      move.w     (a0)+,d7
[00012290] 4847                      swap       d7
[00012292] 2c07                      move.l     d7,d6
[00012294] e1be                      rol.l      d0,d6
[00012296] 8d59                      or.w       d6,(a1)+
[00012298] 5345                      subq.w     #1,d5
[0001229a] 6b16                      bmi.s      $000122B2
[0001229c] 2c07                      move.l     d7,d6
[0001229e] 2e18                      move.l     (a0)+,d7
[000122a0] 4847                      swap       d7
[000122a2] 3c07                      move.w     d7,d6
[000122a4] 2807                      move.l     d7,d4
[000122a6] e1be                      rol.l      d0,d6
[000122a8] e1bc                      rol.l      d0,d4
[000122aa] 3c04                      move.w     d4,d6
[000122ac] 8d99                      or.l       d6,(a1)+
[000122ae] 51cd ffec                 dbf        d5,$0001229C
[000122b2] 4845                      swap       d5
[000122b4] 4ed5                      jmp        (a5)
[000122b6] 3e10                      move.w     (a0),d7
[000122b8] 4847                      swap       d7
[000122ba] e1bf                      rol.l      d0,d7
[000122bc] ce43                      and.w      d3,d7
[000122be] 8f51                      or.w       d7,(a1)
[000122c0] d0ca                      adda.w     a2,a0
[000122c2] d2cb                      adda.w     a3,a1
[000122c4] 51cd ffac                 dbf        d5,$00012272
[000122c8] 4e75                      rts
[000122ca] 3c18                      move.w     (a0)+,d6
[000122cc] cc42                      and.w      d2,d6
[000122ce] 8d51                      or.w       d6,(a1)
[000122d0] b559                      eor.w      d2,(a1)+
[000122d2] 3801                      move.w     d1,d4
[000122d4] 6b0a                      bmi.s      $000122E0
[000122d6] 3c18                      move.w     (a0)+,d6
[000122d8] 8d51                      or.w       d6,(a1)
[000122da] 4659                      not.w      (a1)+
[000122dc] 51cc fff8                 dbf        d4,$000122D6
[000122e0] 4ed5                      jmp        (a5)
[000122e2] 3c10                      move.w     (a0),d6
[000122e4] cc43                      and.w      d3,d6
[000122e6] 8d51                      or.w       d6,(a1)
[000122e8] b751                      eor.w      d3,(a1)
[000122ea] d0ca                      adda.w     a2,a0
[000122ec] d2cb                      adda.w     a3,a1
[000122ee] 51cd ffda                 dbf        d5,$000122CA
[000122f2] 4e75                      rts
[000122f4] 3c18                      move.w     (a0)+,d6
[000122f6] 4ed4                      jmp        (a4)
[000122f8] 4846                      swap       d6
[000122fa] 3c18                      move.w     (a0)+,d6
[000122fc] 3e06                      move.w     d6,d7
[000122fe] e0be                      ror.l      d0,d6
[00012300] cc42                      and.w      d2,d6
[00012302] 8d51                      or.w       d6,(a1)
[00012304] b559                      eor.w      d2,(a1)+
[00012306] 3801                      move.w     d1,d4
[00012308] 6b10                      bmi.s      $0001231A
[0001230a] 3c07                      move.w     d7,d6
[0001230c] 4846                      swap       d6
[0001230e] 3c18                      move.w     (a0)+,d6
[00012310] 3e06                      move.w     d6,d7
[00012312] e0be                      ror.l      d0,d6
[00012314] 8d59                      or.w       d6,(a1)+
[00012316] 51cc fff2                 dbf        d4,$0001230A
[0001231a] 4847                      swap       d7
[0001231c] 4ed5                      jmp        (a5)
[0001231e] 3e10                      move.w     (a0),d7
[00012320] e0bf                      ror.l      d0,d7
[00012322] ce43                      and.w      d3,d7
[00012324] 8f51                      or.w       d7,(a1)
[00012326] b751                      eor.w      d3,(a1)
[00012328] d0ca                      adda.w     a2,a0
[0001232a] d2cb                      adda.w     a3,a1
[0001232c] 51cd ffc6                 dbf        d5,$000122F4
[00012330] 4e75                      rts
[00012332] 3c18                      move.w     (a0)+,d6
[00012334] 4ed4                      jmp        (a4)
[00012336] 4846                      swap       d6
[00012338] 3c18                      move.w     (a0)+,d6
[0001233a] 4846                      swap       d6
[0001233c] 2e06                      move.l     d6,d7
[0001233e] e1be                      rol.l      d0,d6
[00012340] cc42                      and.w      d2,d6
[00012342] 8d51                      or.w       d6,(a1)
[00012344] b559                      eor.w      d2,(a1)+
[00012346] 3801                      move.w     d1,d4
[00012348] 6b12                      bmi.s      $0001235C
[0001234a] 2c07                      move.l     d7,d6
[0001234c] 3c18                      move.w     (a0)+,d6
[0001234e] 4846                      swap       d6
[00012350] 2e06                      move.l     d6,d7
[00012352] e1be                      rol.l      d0,d6
[00012354] 8d51                      or.w       d6,(a1)
[00012356] 4659                      not.w      (a1)+
[00012358] 51cc fff0                 dbf        d4,$0001234A
[0001235c] 4ed5                      jmp        (a5)
[0001235e] 3e10                      move.w     (a0),d7
[00012360] 4847                      swap       d7
[00012362] e1bf                      rol.l      d0,d7
[00012364] ce43                      and.w      d3,d7
[00012366] 8f51                      or.w       d7,(a1)
[00012368] b751                      eor.w      d3,(a1)
[0001236a] d0ca                      adda.w     a2,a0
[0001236c] d2cb                      adda.w     a3,a1
[0001236e] 51cd ffc2                 dbf        d5,$00012332
[00012372] 4e75                      rts
[00012374] 3c18                      move.w     (a0)+,d6
[00012376] 4646                      not.w      d6
[00012378] cc42                      and.w      d2,d6
[0001237a] bd59                      eor.w      d6,(a1)+
[0001237c] 3801                      move.w     d1,d4
[0001237e] 6b0a                      bmi.s      $0001238A
[00012380] 3c18                      move.w     (a0)+,d6
[00012382] 4646                      not.w      d6
[00012384] bd59                      eor.w      d6,(a1)+
[00012386] 51cc fff8                 dbf        d4,$00012380
[0001238a] 4ed5                      jmp        (a5)
[0001238c] 3c10                      move.w     (a0),d6
[0001238e] 4646                      not.w      d6
[00012390] cc43                      and.w      d3,d6
[00012392] bd51                      eor.w      d6,(a1)
[00012394] d0ca                      adda.w     a2,a0
[00012396] d2cb                      adda.w     a3,a1
[00012398] 51cd ffda                 dbf        d5,$00012374
[0001239c] 4e75                      rts
[0001239e] 3c18                      move.w     (a0)+,d6
[000123a0] 4ed4                      jmp        (a4)
[000123a2] 4846                      swap       d6
[000123a4] 3c18                      move.w     (a0)+,d6
[000123a6] 3e06                      move.w     d6,d7
[000123a8] e0be                      ror.l      d0,d6
[000123aa] 4646                      not.w      d6
[000123ac] cc42                      and.w      d2,d6
[000123ae] bd59                      eor.w      d6,(a1)+
[000123b0] 3801                      move.w     d1,d4
[000123b2] 6b12                      bmi.s      $000123C6
[000123b4] 3c07                      move.w     d7,d6
[000123b6] 4846                      swap       d6
[000123b8] 3c18                      move.w     (a0)+,d6
[000123ba] 3e06                      move.w     d6,d7
[000123bc] e0be                      ror.l      d0,d6
[000123be] 4646                      not.w      d6
[000123c0] bd59                      eor.w      d6,(a1)+
[000123c2] 51cc fff0                 dbf        d4,$000123B4
[000123c6] 4847                      swap       d7
[000123c8] 4ed5                      jmp        (a5)
[000123ca] 3e10                      move.w     (a0),d7
[000123cc] e0bf                      ror.l      d0,d7
[000123ce] 4647                      not.w      d7
[000123d0] ce43                      and.w      d3,d7
[000123d2] bf51                      eor.w      d7,(a1)
[000123d4] d0ca                      adda.w     a2,a0
[000123d6] d2cb                      adda.w     a3,a1
[000123d8] 51cd ffc4                 dbf        d5,$0001239E
[000123dc] 4e75                      rts
[000123de] 3c18                      move.w     (a0)+,d6
[000123e0] 4ed4                      jmp        (a4)
[000123e2] 4846                      swap       d6
[000123e4] 3c18                      move.w     (a0)+,d6
[000123e6] 4846                      swap       d6
[000123e8] 2e06                      move.l     d6,d7
[000123ea] e1be                      rol.l      d0,d6
[000123ec] 4646                      not.w      d6
[000123ee] cc42                      and.w      d2,d6
[000123f0] bd59                      eor.w      d6,(a1)+
[000123f2] 3801                      move.w     d1,d4
[000123f4] 6b12                      bmi.s      $00012408
[000123f6] 2c07                      move.l     d7,d6
[000123f8] 3c18                      move.w     (a0)+,d6
[000123fa] 4846                      swap       d6
[000123fc] 2e06                      move.l     d6,d7
[000123fe] e1be                      rol.l      d0,d6
[00012400] 4646                      not.w      d6
[00012402] bd59                      eor.w      d6,(a1)+
[00012404] 51cc fff0                 dbf        d4,$000123F6
[00012408] 4ed5                      jmp        (a5)
[0001240a] 3e10                      move.w     (a0),d7
[0001240c] 4847                      swap       d7
[0001240e] e1bf                      rol.l      d0,d7
[00012410] 4647                      not.w      d7
[00012412] ce43                      and.w      d3,d7
[00012414] bf51                      eor.w      d7,(a1)
[00012416] d0ca                      adda.w     a2,a0
[00012418] d2cb                      adda.w     a3,a1
[0001241a] 51cd ffc2                 dbf        d5,$000123DE
[0001241e] 4e75                      rts
[00012420] 4bfa 001c                 lea.l      $0001243E(pc),a5
[00012424] 4a43                      tst.w      d3
[00012426] 6704                      beq.s      $0001242C
[00012428] 4bfa 0012                 lea.l      $0001243C(pc),a5
[0001242c] b559                      eor.w      d2,(a1)+
[0001242e] 3801                      move.w     d1,d4
[00012430] 6b06                      bmi.s      $00012438
[00012432] 4659                      not.w      (a1)+
[00012434] 51cc fffc                 dbf        d4,$00012432
[00012438] 4ed5                      jmp        (a5)
[0001243a] 4e71                      nop
[0001243c] b751                      eor.w      d3,(a1)
[0001243e] d0ca                      adda.w     a2,a0
[00012440] d2cb                      adda.w     a3,a1
[00012442] 51cd ffe8                 dbf        d5,$0001242C
[00012446] 4e75                      rts
[00012448] 3c18                      move.w     (a0)+,d6
[0001244a] cc42                      and.w      d2,d6
[0001244c] b551                      eor.w      d2,(a1)
[0001244e] 8d59                      or.w       d6,(a1)+
[00012450] 3801                      move.w     d1,d4
[00012452] 6b0a                      bmi.s      $0001245E
[00012454] 3c18                      move.w     (a0)+,d6
[00012456] 4651                      not.w      (a1)
[00012458] 8d59                      or.w       d6,(a1)+
[0001245a] 51cc fff8                 dbf        d4,$00012454
[0001245e] 4ed5                      jmp        (a5)
[00012460] 3c10                      move.w     (a0),d6
[00012462] cc43                      and.w      d3,d6
[00012464] b751                      eor.w      d3,(a1)
[00012466] 8d51                      or.w       d6,(a1)
[00012468] d0ca                      adda.w     a2,a0
[0001246a] d2cb                      adda.w     a3,a1
[0001246c] 51cd ffda                 dbf        d5,$00012448
[00012470] 4e75                      rts
[00012472] 3c18                      move.w     (a0)+,d6
[00012474] 4ed4                      jmp        (a4)
[00012476] 4846                      swap       d6
[00012478] 3c18                      move.w     (a0)+,d6
[0001247a] 3e06                      move.w     d6,d7
[0001247c] e0be                      ror.l      d0,d6
[0001247e] cc42                      and.w      d2,d6
[00012480] b551                      eor.w      d2,(a1)
[00012482] 8d59                      or.w       d6,(a1)+
[00012484] 3801                      move.w     d1,d4
[00012486] 6b12                      bmi.s      $0001249A
[00012488] 3c07                      move.w     d7,d6
[0001248a] 4846                      swap       d6
[0001248c] 3c18                      move.w     (a0)+,d6
[0001248e] 3e06                      move.w     d6,d7
[00012490] e0be                      ror.l      d0,d6
[00012492] 4651                      not.w      (a1)
[00012494] 8d59                      or.w       d6,(a1)+
[00012496] 51cc fff0                 dbf        d4,$00012488
[0001249a] 4847                      swap       d7
[0001249c] 4ed5                      jmp        (a5)
[0001249e] 3e10                      move.w     (a0),d7
[000124a0] e0bf                      ror.l      d0,d7
[000124a2] ce43                      and.w      d3,d7
[000124a4] b751                      eor.w      d3,(a1)
[000124a6] 8f51                      or.w       d7,(a1)
[000124a8] d0ca                      adda.w     a2,a0
[000124aa] d2cb                      adda.w     a3,a1
[000124ac] 51cd ffc4                 dbf        d5,$00012472
[000124b0] 4e75                      rts
[000124b2] 3c18                      move.w     (a0)+,d6
[000124b4] 4ed4                      jmp        (a4)
[000124b6] 4846                      swap       d6
[000124b8] 3c18                      move.w     (a0)+,d6
[000124ba] 4846                      swap       d6
[000124bc] 2e06                      move.l     d6,d7
[000124be] e1be                      rol.l      d0,d6
[000124c0] cc42                      and.w      d2,d6
[000124c2] b551                      eor.w      d2,(a1)
[000124c4] 8d59                      or.w       d6,(a1)+
[000124c6] 3801                      move.w     d1,d4
[000124c8] 6b12                      bmi.s      $000124DC
[000124ca] 2c07                      move.l     d7,d6
[000124cc] 3c18                      move.w     (a0)+,d6
[000124ce] 4846                      swap       d6
[000124d0] 2e06                      move.l     d6,d7
[000124d2] e1be                      rol.l      d0,d6
[000124d4] 4651                      not.w      (a1)
[000124d6] 8d59                      or.w       d6,(a1)+
[000124d8] 51cc fff0                 dbf        d4,$000124CA
[000124dc] 4ed5                      jmp        (a5)
[000124de] 3e10                      move.w     (a0),d7
[000124e0] 4847                      swap       d7
[000124e2] e1bf                      rol.l      d0,d7
[000124e4] ce43                      and.w      d3,d7
[000124e6] b751                      eor.w      d3,(a1)
[000124e8] 8f51                      or.w       d7,(a1)
[000124ea] d0ca                      adda.w     a2,a0
[000124ec] d2cb                      adda.w     a3,a1
[000124ee] 51cd ffc2                 dbf        d5,$000124B2
[000124f2] 4e75                      rts
[000124f4] 3c18                      move.w     (a0)+,d6
[000124f6] 4646                      not.w      d6
[000124f8] cc42                      and.w      d2,d6
[000124fa] 4642                      not.w      d2
[000124fc] c551                      and.w      d2,(a1)
[000124fe] 4642                      not.w      d2
[00012500] 8d59                      or.w       d6,(a1)+
[00012502] 3801                      move.w     d1,d4
[00012504] 6b0a                      bmi.s      $00012510
[00012506] 3c18                      move.w     (a0)+,d6
[00012508] 4646                      not.w      d6
[0001250a] 32c6                      move.w     d6,(a1)+
[0001250c] 51cc fff8                 dbf        d4,$00012506
[00012510] 4ed5                      jmp        (a5)
[00012512] 3c10                      move.w     (a0),d6
[00012514] 4646                      not.w      d6
[00012516] cc43                      and.w      d3,d6
[00012518] 4643                      not.w      d3
[0001251a] c751                      and.w      d3,(a1)
[0001251c] 4643                      not.w      d3
[0001251e] 8d51                      or.w       d6,(a1)
[00012520] d0ca                      adda.w     a2,a0
[00012522] d2cb                      adda.w     a3,a1
[00012524] 51cd ffce                 dbf        d5,$000124F4
[00012528] 4e75                      rts
[0001252a] 3c18                      move.w     (a0)+,d6
[0001252c] 4ed4                      jmp        (a4)
[0001252e] 4846                      swap       d6
[00012530] 3c18                      move.w     (a0)+,d6
[00012532] 3e06                      move.w     d6,d7
[00012534] e0be                      ror.l      d0,d6
[00012536] 4646                      not.w      d6
[00012538] cc42                      and.w      d2,d6
[0001253a] 4642                      not.w      d2
[0001253c] c551                      and.w      d2,(a1)
[0001253e] 4642                      not.w      d2
[00012540] 8d59                      or.w       d6,(a1)+
[00012542] 3801                      move.w     d1,d4
[00012544] 6b12                      bmi.s      $00012558
[00012546] 3c07                      move.w     d7,d6
[00012548] 4846                      swap       d6
[0001254a] 3c18                      move.w     (a0)+,d6
[0001254c] 3e06                      move.w     d6,d7
[0001254e] e0be                      ror.l      d0,d6
[00012550] 4646                      not.w      d6
[00012552] 32c6                      move.w     d6,(a1)+
[00012554] 51cc fff0                 dbf        d4,$00012546
[00012558] 4847                      swap       d7
[0001255a] 4ed5                      jmp        (a5)
[0001255c] 3e10                      move.w     (a0),d7
[0001255e] e0bf                      ror.l      d0,d7
[00012560] 4647                      not.w      d7
[00012562] ce43                      and.w      d3,d7
[00012564] 4643                      not.w      d3
[00012566] c751                      and.w      d3,(a1)
[00012568] 4643                      not.w      d3
[0001256a] 8f51                      or.w       d7,(a1)
[0001256c] d0ca                      adda.w     a2,a0
[0001256e] d2cb                      adda.w     a3,a1
[00012570] 51cd ffb8                 dbf        d5,$0001252A
[00012574] 4e75                      rts
[00012576] 3c18                      move.w     (a0)+,d6
[00012578] 4ed4                      jmp        (a4)
[0001257a] 4846                      swap       d6
[0001257c] 3c18                      move.w     (a0)+,d6
[0001257e] 4846                      swap       d6
[00012580] 2e06                      move.l     d6,d7
[00012582] e1be                      rol.l      d0,d6
[00012584] 4646                      not.w      d6
[00012586] cc42                      and.w      d2,d6
[00012588] 4642                      not.w      d2
[0001258a] c551                      and.w      d2,(a1)
[0001258c] 4642                      not.w      d2
[0001258e] 8d59                      or.w       d6,(a1)+
[00012590] 3801                      move.w     d1,d4
[00012592] 6b12                      bmi.s      $000125A6
[00012594] 2c07                      move.l     d7,d6
[00012596] 3c18                      move.w     (a0)+,d6
[00012598] 4846                      swap       d6
[0001259a] 2e06                      move.l     d6,d7
[0001259c] e1be                      rol.l      d0,d6
[0001259e] 4646                      not.w      d6
[000125a0] 32c6                      move.w     d6,(a1)+
[000125a2] 51cc fff0                 dbf        d4,$00012594
[000125a6] 4ed5                      jmp        (a5)
[000125a8] 3e10                      move.w     (a0),d7
[000125aa] 4847                      swap       d7
[000125ac] e1bf                      rol.l      d0,d7
[000125ae] 4647                      not.w      d7
[000125b0] ce43                      and.w      d3,d7
[000125b2] 4643                      not.w      d3
[000125b4] c751                      and.w      d3,(a1)
[000125b6] 4643                      not.w      d3
[000125b8] 8f51                      or.w       d7,(a1)
[000125ba] d0ca                      adda.w     a2,a0
[000125bc] d2cb                      adda.w     a3,a1
[000125be] 51cd ffb6                 dbf        d5,$00012576
[000125c2] 4e75                      rts
[000125c4] 3c18                      move.w     (a0)+,d6
[000125c6] 4646                      not.w      d6
[000125c8] cc42                      and.w      d2,d6
[000125ca] 8d59                      or.w       d6,(a1)+
[000125cc] 3801                      move.w     d1,d4
[000125ce] 6b0a                      bmi.s      $000125DA
[000125d0] 3c18                      move.w     (a0)+,d6
[000125d2] 4646                      not.w      d6
[000125d4] 8d59                      or.w       d6,(a1)+
[000125d6] 51cc fff8                 dbf        d4,$000125D0
[000125da] 4ed5                      jmp        (a5)
[000125dc] 3c10                      move.w     (a0),d6
[000125de] 4646                      not.w      d6
[000125e0] cc43                      and.w      d3,d6
[000125e2] 8d51                      or.w       d6,(a1)
[000125e4] d0ca                      adda.w     a2,a0
[000125e6] d2cb                      adda.w     a3,a1
[000125e8] 51cd ffda                 dbf        d5,$000125C4
[000125ec] 4e75                      rts
[000125ee] 3c18                      move.w     (a0)+,d6
[000125f0] 4ed4                      jmp        (a4)
[000125f2] 4846                      swap       d6
[000125f4] 3c18                      move.w     (a0)+,d6
[000125f6] 3e06                      move.w     d6,d7
[000125f8] e0be                      ror.l      d0,d6
[000125fa] 4646                      not.w      d6
[000125fc] cc42                      and.w      d2,d6
[000125fe] 8d59                      or.w       d6,(a1)+
[00012600] 3801                      move.w     d1,d4
[00012602] 6b12                      bmi.s      $00012616
[00012604] 3c07                      move.w     d7,d6
[00012606] 4846                      swap       d6
[00012608] 3c18                      move.w     (a0)+,d6
[0001260a] 3e06                      move.w     d6,d7
[0001260c] e0be                      ror.l      d0,d6
[0001260e] 4646                      not.w      d6
[00012610] 8d59                      or.w       d6,(a1)+
[00012612] 51cc fff0                 dbf        d4,$00012604
[00012616] 4847                      swap       d7
[00012618] 4ed5                      jmp        (a5)
[0001261a] 3e10                      move.w     (a0),d7
[0001261c] e0bf                      ror.l      d0,d7
[0001261e] 4647                      not.w      d7
[00012620] ce43                      and.w      d3,d7
[00012622] 8f51                      or.w       d7,(a1)
[00012624] d0ca                      adda.w     a2,a0
[00012626] d2cb                      adda.w     a3,a1
[00012628] 51cd ffc4                 dbf        d5,$000125EE
[0001262c] 4e75                      rts
[0001262e] 3c18                      move.w     (a0)+,d6
[00012630] 4ed4                      jmp        (a4)
[00012632] 4846                      swap       d6
[00012634] 3c18                      move.w     (a0)+,d6
[00012636] 4846                      swap       d6
[00012638] 2e06                      move.l     d6,d7
[0001263a] e1be                      rol.l      d0,d6
[0001263c] 4646                      not.w      d6
[0001263e] cc42                      and.w      d2,d6
[00012640] 8d59                      or.w       d6,(a1)+
[00012642] 3801                      move.w     d1,d4
[00012644] 6b12                      bmi.s      $00012658
[00012646] 2c07                      move.l     d7,d6
[00012648] 3c18                      move.w     (a0)+,d6
[0001264a] 4846                      swap       d6
[0001264c] 2e06                      move.l     d6,d7
[0001264e] e1be                      rol.l      d0,d6
[00012650] 4646                      not.w      d6
[00012652] 8d59                      or.w       d6,(a1)+
[00012654] 51cc fff0                 dbf        d4,$00012646
[00012658] 4ed5                      jmp        (a5)
[0001265a] 3e10                      move.w     (a0),d7
[0001265c] 4847                      swap       d7
[0001265e] e1bf                      rol.l      d0,d7
[00012660] 4647                      not.w      d7
[00012662] ce43                      and.w      d3,d7
[00012664] 8f51                      or.w       d7,(a1)
[00012666] d0ca                      adda.w     a2,a0
[00012668] d2cb                      adda.w     a3,a1
[0001266a] 51cd ffc2                 dbf        d5,$0001262E
[0001266e] 4e75                      rts
[00012670] 3c18                      move.w     (a0)+,d6
[00012672] 8c42                      or.w       d2,d6
[00012674] cd51                      and.w      d6,(a1)
[00012676] 8559                      or.w       d2,(a1)+
[00012678] 3801                      move.w     d1,d4
[0001267a] 6b0a                      bmi.s      $00012686
[0001267c] 3c18                      move.w     (a0)+,d6
[0001267e] cd51                      and.w      d6,(a1)
[00012680] 4659                      not.w      (a1)+
[00012682] 51cc fff8                 dbf        d4,$0001267C
[00012686] 4ed5                      jmp        (a5)
[00012688] 3c10                      move.w     (a0),d6
[0001268a] 8c43                      or.w       d3,d6
[0001268c] cd51                      and.w      d6,(a1)
[0001268e] b751                      eor.w      d3,(a1)
[00012690] d0ca                      adda.w     a2,a0
[00012692] d2cb                      adda.w     a3,a1
[00012694] 51cd ffda                 dbf        d5,$00012670
[00012698] 4e75                      rts
[0001269a] 3c18                      move.w     (a0)+,d6
[0001269c] 4ed4                      jmp        (a4)
[0001269e] 4846                      swap       d6
[000126a0] 3c18                      move.w     (a0)+,d6
[000126a2] 3e06                      move.w     d6,d7
[000126a4] e0be                      ror.l      d0,d6
[000126a6] 8c42                      or.w       d2,d6
[000126a8] cd51                      and.w      d6,(a1)
[000126aa] 8559                      or.w       d2,(a1)+
[000126ac] 3801                      move.w     d1,d4
[000126ae] 6b12                      bmi.s      $000126C2
[000126b0] 3c07                      move.w     d7,d6
[000126b2] 4846                      swap       d6
[000126b4] 3c18                      move.w     (a0)+,d6
[000126b6] 3e06                      move.w     d6,d7
[000126b8] e0be                      ror.l      d0,d6
[000126ba] cd51                      and.w      d6,(a1)
[000126bc] 4659                      not.w      (a1)+
[000126be] 51cc fff0                 dbf        d4,$000126B0
[000126c2] 4847                      swap       d7
[000126c4] 4ed5                      jmp        (a5)
[000126c6] 3e10                      move.w     (a0),d7
[000126c8] e0bf                      ror.l      d0,d7
[000126ca] 8e43                      or.w       d3,d7
[000126cc] cf51                      and.w      d7,(a1)
[000126ce] b751                      eor.w      d3,(a1)
[000126d0] d0ca                      adda.w     a2,a0
[000126d2] d2cb                      adda.w     a3,a1
[000126d4] 51cd ffc4                 dbf        d5,$0001269A
[000126d8] 4e75                      rts
[000126da] 3c18                      move.w     (a0)+,d6
[000126dc] 4ed4                      jmp        (a4)
[000126de] 4846                      swap       d6
[000126e0] 3c18                      move.w     (a0)+,d6
[000126e2] 4846                      swap       d6
[000126e4] 2e06                      move.l     d6,d7
[000126e6] e1be                      rol.l      d0,d6
[000126e8] 8c42                      or.w       d2,d6
[000126ea] cd51                      and.w      d6,(a1)
[000126ec] 8559                      or.w       d2,(a1)+
[000126ee] 3801                      move.w     d1,d4
[000126f0] 6b12                      bmi.s      $00012704
[000126f2] 2c07                      move.l     d7,d6
[000126f4] 3c18                      move.w     (a0)+,d6
[000126f6] 4846                      swap       d6
[000126f8] 2e06                      move.l     d6,d7
[000126fa] e1be                      rol.l      d0,d6
[000126fc] cd51                      and.w      d6,(a1)
[000126fe] 4659                      not.w      (a1)+
[00012700] 51cc fff0                 dbf        d4,$000126F2
[00012704] 4ed5                      jmp        (a5)
[00012706] 3e10                      move.w     (a0),d7
[00012708] 4847                      swap       d7
[0001270a] e1bf                      rol.l      d0,d7
[0001270c] 8e43                      or.w       d3,d7
[0001270e] cf51                      and.w      d7,(a1)
[00012710] b751                      eor.w      d3,(a1)
[00012712] d0ca                      adda.w     a2,a0
[00012714] d2cb                      adda.w     a3,a1
[00012716] 51cd ffc2                 dbf        d5,$000126DA
[0001271a] 4e75                      rts
[0001271c] 7eff                      moveq.l    #-1,d7
[0001271e] 4bfa 0018                 lea.l      $00012738(pc),a5
[00012722] 4a43                      tst.w      d3
[00012724] 6604                      bne.s      $0001272A
[00012726] 4bfa 0012                 lea.l      $0001273A(pc),a5
[0001272a] 8559                      or.w       d2,(a1)+
[0001272c] 3801                      move.w     d1,d4
[0001272e] 6b06                      bmi.s      $00012736
[00012730] 32c7                      move.w     d7,(a1)+
[00012732] 51cc fffc                 dbf        d4,$00012730
[00012736] 4ed5                      jmp        (a5)
[00012738] 8751                      or.w       d3,(a1)
[0001273a] d2cb                      adda.w     a3,a1
[0001273c] 51cd ffec                 dbf        d5,$0001272A
[00012740] 4e75                      rts
[00012742] 204c                      movea.l    a4,a0
[00012744] 224d                      movea.l    a5,a1
[00012746] 3a47                      movea.w    d7,a5
[00012748] 3c0a                      move.w     a2,d6
[0001274a] d245                      add.w      d5,d1
[0001274c] ccc1                      mulu.w     d1,d6
[0001274e] d1c6                      adda.l     d6,a0
[00012750] 3c00                      move.w     d0,d6
[00012752] dc44                      add.w      d4,d6
[00012754] e84e                      lsr.w      #4,d6
[00012756] dc46                      add.w      d6,d6
[00012758] d0c6                      adda.w     d6,a0
[0001275a] 3c0b                      move.w     a3,d6
[0001275c] d645                      add.w      d5,d3
[0001275e] ccc3                      mulu.w     d3,d6
[00012760] d3c6                      adda.l     d6,a1
[00012762] 3c02                      move.w     d2,d6
[00012764] dc44                      add.w      d4,d6
[00012766] e84e                      lsr.w      #4,d6
[00012768] dc46                      add.w      d6,d6
[0001276a] d2c6                      adda.w     d6,a1
[0001276c] 7c0f                      moveq.l    #15,d6
[0001276e] 3e00                      move.w     d0,d7
[00012770] ce46                      and.w      d6,d7
[00012772] de44                      add.w      d4,d7
[00012774] e84f                      lsr.w      #4,d7
[00012776] 3602                      move.w     d2,d3
[00012778] d644                      add.w      d4,d3
[0001277a] d044                      add.w      d4,d0
[0001277c] c046                      and.w      d6,d0
[0001277e] c646                      and.w      d6,d3
[00012780] 9043                      sub.w      d3,d0
[00012782] 3202                      move.w     d2,d1
[00012784] c246                      and.w      d6,d1
[00012786] d244                      add.w      d4,d1
[00012788] e849                      lsr.w      #4,d1
[0001278a] 9e41                      sub.w      d1,d7
[0001278c] d842                      add.w      d2,d4
[0001278e] 4644                      not.w      d4
[00012790] c846                      and.w      d6,d4
[00012792] 76ff                      moveq.l    #-1,d3
[00012794] e96b                      lsl.w      d4,d3
[00012796] cc42                      and.w      d2,d6
[00012798] 74ff                      moveq.l    #-1,d2
[0001279a] ec6a                      lsr.w      d6,d2
[0001279c] 3801                      move.w     d1,d4
[0001279e] d844                      add.w      d4,d4
[000127a0] 94c4                      suba.w     d4,a2
[000127a2] 96c4                      suba.w     d4,a3
[000127a4] 3807                      move.w     d7,d4
[000127a6] 7c04                      moveq.l    #4,d6
[000127a8] 7e00                      moveq.l    #0,d7
[000127aa] 49fa 007c                 lea.l      $00012828(pc),a4
[000127ae] 4a40                      tst.w      d0
[000127b0] 6750                      beq.s      $00012802
[000127b2] 6d20                      blt.s      $000127D4
[000127b4] 49fa 00f2                 lea.l      $000128A8(pc),a4
[000127b8] 7c08                      moveq.l    #8,d6
[000127ba] 4a44                      tst.w      d4
[000127bc] 6a04                      bpl.s      $000127C2
[000127be] 7e02                      moveq.l    #2,d7
[000127c0] 544a                      addq.w     #2,a2
[000127c2] 0c40 0008                 cmpi.w     #$0008,d0
[000127c6] 6f3a                      ble.s      $00012802
[000127c8] 49fa 015e                 lea.l      $00012928(pc),a4
[000127cc] 5340                      subq.w     #1,d0
[000127ce] 0a40 000f                 eori.w     #$000F,d0
[000127d2] 602e                      bra.s      $00012802
[000127d4] 49fa 0152                 lea.l      $00012928(pc),a4
[000127d8] 4440                      neg.w      d0
[000127da] 4a41                      tst.w      d1
[000127dc] 6608                      bne.s      $000127E6
[000127de] 4a44                      tst.w      d4
[000127e0] 6604                      bne.s      $000127E6
[000127e2] 7c0a                      moveq.l    #10,d6
[000127e4] 601c                      bra.s      $00012802
[000127e6] 7c04                      moveq.l    #4,d6
[000127e8] 554a                      subq.w     #2,a2
[000127ea] 4a44                      tst.w      d4
[000127ec] 6e04                      bgt.s      $000127F2
[000127ee] 7e02                      moveq.l    #2,d7
[000127f0] 544a                      addq.w     #2,a2
[000127f2] 0c40 0008                 cmpi.w     #$0008,d0
[000127f6] 6f0a                      ble.s      $00012802
[000127f8] 49fa 00ae                 lea.l      $000128A8(pc),a4
[000127fc] 5340                      subq.w     #1,d0
[000127fe] 0a40 000f                 eori.w     #$000F,d0
[00012802] dbcc                      adda.l     a4,a5
[00012804] 381d                      move.w     (a5)+,d4
[00012806] dc44                      add.w      d4,d6
[00012808] de5d                      add.w      (a5)+,d7
[0001280a] 4a41                      tst.w      d1
[0001280c] 6608                      bne.s      $00012816
[0001280e] c642                      and.w      d2,d3
[00012810] 7400                      moveq.l    #0,d2
[00012812] 7200                      moveq.l    #0,d1
[00012814] 3e15                      move.w     (a5),d7
[00012816] 5541                      subq.w     #2,d1
[00012818] 49fa 000e                 lea.l      $00012828(pc),a4
[0001281c] 4bfa 000a                 lea.l      $00012828(pc),a5
[00012820] d8c6                      adda.w     d6,a4
[00012822] dac7                      adda.w     d7,a5
[00012824] 4efb 4002                 jmp        $00012828(pc,d4.w)
[00012828] 0180                      bclr       d0,d0
[0001282a] 01a2                      bclr       d0,-(a2)
[0001282c] 01a4                      bclr       d0,-(a4)
[0001282e] 0000 01b0                 ori.b      #$B0,d0
[00012832] 01c8 01d2                 movep.l    d0,466(a0)
[00012836] 0000 0262                 ori.b      #$62,d0
[0001283a] 027e 028a                 andi.w     #$028A,???
[0001283e] 0000 0326                 ori.b      #$26,d0
[00012842] 0000                      dc.w       $0000
[00012844] 0000                      dc.w       $0000
[00012846] 0000 046c                 ori.b      #$6C,d0
[0001284a] 0484 048c 0000            subi.l     #$048C0000,d4
[00012850] 0518                      btst       d2,(a0)+
[00012852] 0518                      btst       d2,(a0)+
[00012854] 0518                      btst       d2,(a0)+
[00012856] 0000 051a                 ori.b      #$1A,d0
[0001285a] 052e 0534                 btst       d2,1332(a6)
[0001285e] 0000 05b4                 ori.b      #$B4,d0
[00012862] 05c8 05ce                 movep.l    d2,1486(a0)
[00012866] 0000 064e                 ori.b      #$4E,d0
[0001286a] 0666 066e                 addi.w     #$066E,-(a6)
[0001286e] 0000 06fa                 ori.b      #$FA,d0
[00012872] 0712                      btst       d3,(a2)
[00012874] 071a                      btst       d3,(a2)+
[00012876] 0000 07a6                 ori.b      #$A6,d0
[0001287a] 07c2                      bset       d3,d2
[0001287c] 07c4                      bset       d3,d4
[0001287e] 0000 07ce                 ori.b      #$CE,d0
[00012882] 07e6                      bset       d3,-(a6)
[00012884] 07ee 0000                 bset       d3,0(a6)
[00012888] 087a 0898 08a6            bchg       #2200,$00013132(pc) ; apollo only
[0001288e] 0000 094a                 ori.b      #$4A,d0
[00012892] 0962                      bchg       d4,-(a2)
[00012894] 096a 0000                 bchg       d4,0(a2)
[00012898] 09f6 0a0e                 bset       d4,14(a6,d0.l*2) ; 68020+ only
[0001289c] 0a16 0000                 eori.b     #$00,(a6)
[000128a0] 0aa2 0abe 0ac0            eori.l     #$0ABE0AC0,-(a2)
[000128a6] 0000 0180                 ori.b      #$80,d0
[000128aa] 01a2                      bclr       d0,-(a2)
[000128ac] 01a4                      bclr       d0,-(a4)
[000128ae] 0000 0220                 ori.b      #$20,d0
[000128b2] 024c 0258                 andi.w     #$0258,a4 ; apollo only
[000128b6] 0000 02de                 ori.b      #$DE,d0
[000128ba] 030e 031c                 movep.w    796(a6),d1
[000128be] 0000 042a                 ori.b      #$2A,d0
[000128c2] 0456 0462                 subi.w     #$0462,(a6)
[000128c6] 0000 04d8                 ori.b      #$D8,d0
[000128ca] 0504                      btst       d2,d4
[000128cc] 050e 0000                 movep.w    0(a6),d2
[000128d0] 0518                      btst       d2,(a0)+
[000128d2] 0518                      btst       d2,(a0)+
[000128d4] 0518                      btst       d2,(a0)+
[000128d6] 0000 057a                 ori.b      #$7A,d0
[000128da] 05a2                      bclr       d2,-(a2)
[000128dc] 05aa 0000                 bclr       d2,0(a2)
[000128e0] 0614 063c                 addi.b     #$3C,(a4)
[000128e4] 0644 0000                 addi.w     #$0000,d4
[000128e8] 06ba 06e6 06f0 0000       addi.l     #$06E606F0,$000128EA(pc) ; apollo only
[000128f0] 0766                      bchg       d3,-(a6)
[000128f2] 0792                      bclr       d3,(a2)
[000128f4] 079c                      bclr       d3,(a4)+
[000128f6] 0000 07a6                 ori.b      #$A6,d0
[000128fa] 07c2                      bset       d3,d2
[000128fc] 07c4                      bset       d3,d4
[000128fe] 0000 083a                 ori.b      #$3A,d0
[00012902] 0866 0870                 bchg       #2160,-(a6)
[00012906] 0000 08fe                 ori.b      #$FE,d0
[0001290a] 0930 0940                 btst       d4,(a0) ; 68020+ only; reserved BD=0
[0001290e] 0000 09b6                 ori.b      #$B6,d0
[00012912] 09e2                      bset       d4,-(a2)
[00012914] 09ec 0000                 bset       d4,0(a4)
[00012918] 0a62 0a8e                 eori.w     #$0A8E,-(a2)
[0001291c] 0a98 0000 0aa2            eori.l     #$00000AA2,(a0)+
[00012922] 0abe 0ac0 0000            eori.l     #$0AC00000,???
[00012928] 0180                      bclr       d0,d0
[0001292a] 01a2                      bclr       d0,-(a2)
[0001292c] 01a4                      bclr       d0,-(a4)
[0001292e] 0000 01dc                 ori.b      #$DC,d0
[00012932] 0208 0216                 andi.b     #$16,a0 ; apollo only
[00012936] 0000 0294                 ori.b      #$94,d0
[0001293a] 02c4                      byterev.l  d4 ; ColdFire isa_c only
[0001293c] 02d4 0000                 cmp2.w     (a4),d0 ; 68020+ only
[00012940] 03e6                      bset       d1,-(a6)
[00012942] 0412 0420                 subi.b     #$20,(a2)
[00012946] 0000 0496                 ori.b      #$96,d0
[0001294a] 04c2                      ff1.l      d2 ; ColdFire isa_c only
[0001294c] 04ce                      dc.w       $04CE ; illegal
[0001294e] 0000 0518                 ori.b      #$18,d0
[00012952] 0518                      btst       d2,(a0)+
[00012954] 0518                      btst       d2,(a0)+
[00012956] 0000 053e                 ori.b      #$3E,d0
[0001295a] 0566                      bchg       d2,-(a6)
[0001295c] 0570 0000                 bchg       d2,0(a0,d0.w)
[00012960] 05d8                      bset       d2,(a0)+
[00012962] 0600 060a                 addi.b     #$0A,d0
[00012966] 0000 0678                 ori.b      #$78,d0
[0001296a] 06a4 06b0 0000            addi.l     #$06B00000,-(a4)
[00012970] 0724                      btst       d3,-(a4)
[00012972] 0750                      bchg       d3,(a0)
[00012974] 075c                      bchg       d3,(a4)+
[00012976] 0000 07a6                 ori.b      #$A6,d0
[0001297a] 07c2                      bset       d3,d2
[0001297c] 07c4                      bset       d3,d4
[0001297e] 0000 07f8                 ori.b      #$F8,d0
[00012982] 0824 0830                 btst       #2096,-(a4)
[00012986] 0000 08b0                 ori.b      #$B0,d0
[0001298a] 08e2 08f4                 bset       #2292,-(a2)
[0001298e] 0000 0974                 ori.b      #$74,d0
[00012992] 09a0                      bclr       d4,-(a0)
[00012994] 09ac 0000                 bclr       d4,0(a4)
[00012998] 0a20 0a4c                 eori.b     #$4C,-(a0)
[0001299c] 0a58 0000                 eori.w     #$0000,(a0)+
[000129a0] 0aa2 0abe 0ac0            eori.l     #$0ABE0AC0,-(a2)
[000129a6] 0000 4642                 ori.b      #$42,d0
[000129aa] 4643                      not.w      d3
[000129ac] 7e00                      moveq.l    #0,d7
[000129ae] 4bfa 001c                 lea.l      $000129CC(pc),a5
[000129b2] b47c ffff                 cmp.w      #$FFFF,d2
[000129b6] 6704                      beq.s      $000129BC
[000129b8] 4bfa 0010                 lea.l      $000129CA(pc),a5
[000129bc] c751                      and.w      d3,(a1)
[000129be] 3801                      move.w     d1,d4
[000129c0] 6b06                      bmi.s      $000129C8
[000129c2] 3307                      move.w     d7,-(a1)
[000129c4] 51cc fffc                 dbf        d4,$000129C2
[000129c8] 4ed5                      jmp        (a5)
[000129ca] c561                      and.w      d2,-(a1)
[000129cc] 92cb                      suba.w     a3,a1
[000129ce] 51cd ffec                 dbf        d5,$000129BC
[000129d2] 4642                      not.w      d2
[000129d4] 4643                      not.w      d3
[000129d6] 4e75                      rts
[000129d8] 3c10                      move.w     (a0),d6
[000129da] 4643                      not.w      d3
[000129dc] 8c43                      or.w       d3,d6
[000129de] 4643                      not.w      d3
[000129e0] cd51                      and.w      d6,(a1)
[000129e2] 3801                      move.w     d1,d4
[000129e4] 6b08                      bmi.s      $000129EE
[000129e6] 3c20                      move.w     -(a0),d6
[000129e8] cd61                      and.w      d6,-(a1)
[000129ea] 51cc fffa                 dbf        d4,$000129E6
[000129ee] 4ed5                      jmp        (a5)
[000129f0] 3c20                      move.w     -(a0),d6
[000129f2] 4642                      not.w      d2
[000129f4] 8c42                      or.w       d2,d6
[000129f6] 4642                      not.w      d2
[000129f8] cd61                      and.w      d6,-(a1)
[000129fa] 90ca                      suba.w     a2,a0
[000129fc] 92cb                      suba.w     a3,a1
[000129fe] 51cd ffd8                 dbf        d5,$000129D8
[00012a02] 4e75                      rts
[00012a04] 3c10                      move.w     (a0),d6
[00012a06] 4ed4                      jmp        (a4)
[00012a08] 4846                      swap       d6
[00012a0a] 3c20                      move.w     -(a0),d6
[00012a0c] 4846                      swap       d6
[00012a0e] 2e06                      move.l     d6,d7
[00012a10] e0be                      ror.l      d0,d6
[00012a12] 4643                      not.w      d3
[00012a14] 8c43                      or.w       d3,d6
[00012a16] cd51                      and.w      d6,(a1)
[00012a18] 4643                      not.w      d3
[00012a1a] 3801                      move.w     d1,d4
[00012a1c] 6b10                      bmi.s      $00012A2E
[00012a1e] 2c07                      move.l     d7,d6
[00012a20] 3c20                      move.w     -(a0),d6
[00012a22] 4846                      swap       d6
[00012a24] 2e06                      move.l     d6,d7
[00012a26] e0be                      ror.l      d0,d6
[00012a28] cd61                      and.w      d6,-(a1)
[00012a2a] 51cc fff2                 dbf        d4,$00012A1E
[00012a2e] 4ed5                      jmp        (a5)
[00012a30] 3e20                      move.w     -(a0),d7
[00012a32] 4847                      swap       d7
[00012a34] e0bf                      ror.l      d0,d7
[00012a36] 4642                      not.w      d2
[00012a38] 8e42                      or.w       d2,d7
[00012a3a] 4642                      not.w      d2
[00012a3c] cf61                      and.w      d7,-(a1)
[00012a3e] 90ca                      suba.w     a2,a0
[00012a40] 92cb                      suba.w     a3,a1
[00012a42] 51cd ffc0                 dbf        d5,$00012A04
[00012a46] 4e75                      rts
[00012a48] 3c10                      move.w     (a0),d6
[00012a4a] 4ed4                      jmp        (a4)
[00012a4c] 4846                      swap       d6
[00012a4e] 3c20                      move.w     -(a0),d6
[00012a50] 3e06                      move.w     d6,d7
[00012a52] e1be                      rol.l      d0,d6
[00012a54] 4643                      not.w      d3
[00012a56] 8c43                      or.w       d3,d6
[00012a58] 4643                      not.w      d3
[00012a5a] cd51                      and.w      d6,(a1)
[00012a5c] 3801                      move.w     d1,d4
[00012a5e] 6b10                      bmi.s      $00012A70
[00012a60] 3c07                      move.w     d7,d6
[00012a62] 4846                      swap       d6
[00012a64] 3c20                      move.w     -(a0),d6
[00012a66] 3e06                      move.w     d6,d7
[00012a68] e1be                      rol.l      d0,d6
[00012a6a] cd61                      and.w      d6,-(a1)
[00012a6c] 51cc fff2                 dbf        d4,$00012A60
[00012a70] 4847                      swap       d7
[00012a72] 4ed5                      jmp        (a5)
[00012a74] 3e20                      move.w     -(a0),d7
[00012a76] e1bf                      rol.l      d0,d7
[00012a78] 4642                      not.w      d2
[00012a7a] 8e42                      or.w       d2,d7
[00012a7c] 4642                      not.w      d2
[00012a7e] cf61                      and.w      d7,-(a1)
[00012a80] 90ca                      suba.w     a2,a0
[00012a82] 92cb                      suba.w     a3,a1
[00012a84] 51cd ffc2                 dbf        d5,$00012A48
[00012a88] 4e75                      rts
[00012a8a] 3c10                      move.w     (a0),d6
[00012a8c] b751                      eor.w      d3,(a1)
[00012a8e] 4643                      not.w      d3
[00012a90] 8c43                      or.w       d3,d6
[00012a92] 4643                      not.w      d3
[00012a94] cd51                      and.w      d6,(a1)
[00012a96] 3801                      move.w     d1,d4
[00012a98] 6b0a                      bmi.s      $00012AA4
[00012a9a] 3c20                      move.w     -(a0),d6
[00012a9c] 4661                      not.w      -(a1)
[00012a9e] cd51                      and.w      d6,(a1)
[00012aa0] 51cc fff8                 dbf        d4,$00012A9A
[00012aa4] 4ed5                      jmp        (a5)
[00012aa6] 3c20                      move.w     -(a0),d6
[00012aa8] b561                      eor.w      d2,-(a1)
[00012aaa] 4642                      not.w      d2
[00012aac] 8c42                      or.w       d2,d6
[00012aae] 4642                      not.w      d2
[00012ab0] cd51                      and.w      d6,(a1)
[00012ab2] 90ca                      suba.w     a2,a0
[00012ab4] 92cb                      suba.w     a3,a1
[00012ab6] 51cd ffd2                 dbf        d5,$00012A8A
[00012aba] 4e75                      rts
[00012abc] 3c10                      move.w     (a0),d6
[00012abe] 4ed4                      jmp        (a4)
[00012ac0] 4846                      swap       d6
[00012ac2] 3c20                      move.w     -(a0),d6
[00012ac4] 4846                      swap       d6
[00012ac6] 2e06                      move.l     d6,d7
[00012ac8] e0be                      ror.l      d0,d6
[00012aca] b751                      eor.w      d3,(a1)
[00012acc] 4643                      not.w      d3
[00012ace] 8c43                      or.w       d3,d6
[00012ad0] 4643                      not.w      d3
[00012ad2] cd51                      and.w      d6,(a1)
[00012ad4] 3801                      move.w     d1,d4
[00012ad6] 6b12                      bmi.s      $00012AEA
[00012ad8] 2c07                      move.l     d7,d6
[00012ada] 3c20                      move.w     -(a0),d6
[00012adc] 4846                      swap       d6
[00012ade] 2e06                      move.l     d6,d7
[00012ae0] e0be                      ror.l      d0,d6
[00012ae2] 4661                      not.w      -(a1)
[00012ae4] cd51                      and.w      d6,(a1)
[00012ae6] 51cc fff0                 dbf        d4,$00012AD8
[00012aea] 4ed5                      jmp        (a5)
[00012aec] 3e20                      move.w     -(a0),d7
[00012aee] 4847                      swap       d7
[00012af0] e0bf                      ror.l      d0,d7
[00012af2] b561                      eor.w      d2,-(a1)
[00012af4] 4642                      not.w      d2
[00012af6] 8e42                      or.w       d2,d7
[00012af8] 4642                      not.w      d2
[00012afa] cf51                      and.w      d7,(a1)
[00012afc] 90ca                      suba.w     a2,a0
[00012afe] 92cb                      suba.w     a3,a1
[00012b00] 51cd ffba                 dbf        d5,$00012ABC
[00012b04] 4e75                      rts
[00012b06] 3c10                      move.w     (a0),d6
[00012b08] 4ed4                      jmp        (a4)
[00012b0a] 4846                      swap       d6
[00012b0c] 3c20                      move.w     -(a0),d6
[00012b0e] 3e06                      move.w     d6,d7
[00012b10] e1be                      rol.l      d0,d6
[00012b12] b751                      eor.w      d3,(a1)
[00012b14] 4643                      not.w      d3
[00012b16] 8c43                      or.w       d3,d6
[00012b18] 4643                      not.w      d3
[00012b1a] cd51                      and.w      d6,(a1)
[00012b1c] 3801                      move.w     d1,d4
[00012b1e] 6b12                      bmi.s      $00012B32
[00012b20] 3c07                      move.w     d7,d6
[00012b22] 4846                      swap       d6
[00012b24] 3c20                      move.w     -(a0),d6
[00012b26] 3e06                      move.w     d6,d7
[00012b28] e1be                      rol.l      d0,d6
[00012b2a] 4661                      not.w      -(a1)
[00012b2c] cd51                      and.w      d6,(a1)
[00012b2e] 51cc fff0                 dbf        d4,$00012B20
[00012b32] 4847                      swap       d7
[00012b34] 4ed5                      jmp        (a5)
[00012b36] 3e20                      move.w     -(a0),d7
[00012b38] e1bf                      rol.l      d0,d7
[00012b3a] b561                      eor.w      d2,-(a1)
[00012b3c] 4642                      not.w      d2
[00012b3e] 8e42                      or.w       d2,d7
[00012b40] 4642                      not.w      d2
[00012b42] cf51                      and.w      d7,(a1)
[00012b44] 90ca                      suba.w     a2,a0
[00012b46] 92cb                      suba.w     a3,a1
[00012b48] 51cd ffbc                 dbf        d5,$00012B06
[00012b4c] 4e75                      rts
[00012b4e] 3801                      move.w     d1,d4
[00012b50] 6b00 0084                 bmi        $00012BD6
[00012b54] e24c                      lsr.w      #1,d4
[00012b56] 6522                      bcs.s      $00012B7A
[00012b58] 49fa 0040                 lea.l      $00012B9A(pc),a4
[00012b5c] 6606                      bne.s      $00012B64
[00012b5e] 4bfa 0062                 lea.l      $00012BC2(pc),a5
[00012b62] 6028                      bra.s      $00012B8C
[00012b64] 5344                      subq.w     #1,d4
[00012b66] 3004                      move.w     d4,d0
[00012b68] e84c                      lsr.w      #4,d4
[00012b6a] 3204                      move.w     d4,d1
[00012b6c] 4640                      not.w      d0
[00012b6e] 0240 000f                 andi.w     #$000F,d0
[00012b72] d040                      add.w      d0,d0
[00012b74] 4bfb 0028                 lea.l      $00012B9E(pc,d0.w),a5
[00012b78] 6012                      bra.s      $00012B8C
[00012b7a] 3004                      move.w     d4,d0
[00012b7c] e84c                      lsr.w      #4,d4
[00012b7e] 3204                      move.w     d4,d1
[00012b80] 4640                      not.w      d0
[00012b82] 0240 000f                 andi.w     #$000F,d0
[00012b86] d040                      add.w      d0,d0
[00012b88] 49fb 0014                 lea.l      $00012B9E(pc,d0.w),a4
[00012b8c] 3c10                      move.w     (a0),d6
[00012b8e] 4646                      not.w      d6
[00012b90] cc43                      and.w      d3,d6
[00012b92] 8751                      or.w       d3,(a1)
[00012b94] bd51                      eor.w      d6,(a1)
[00012b96] 3801                      move.w     d1,d4
[00012b98] 4ed4                      jmp        (a4)
[00012b9a] 3320                      move.w     -(a0),-(a1)
[00012b9c] 4ed5                      jmp        (a5)
[00012b9e] 2320                      move.l     -(a0),-(a1)
[00012ba0] 2320                      move.l     -(a0),-(a1)
[00012ba2] 2320                      move.l     -(a0),-(a1)
[00012ba4] 2320                      move.l     -(a0),-(a1)
[00012ba6] 2320                      move.l     -(a0),-(a1)
[00012ba8] 2320                      move.l     -(a0),-(a1)
[00012baa] 2320                      move.l     -(a0),-(a1)
[00012bac] 2320                      move.l     -(a0),-(a1)
[00012bae] 2320                      move.l     -(a0),-(a1)
[00012bb0] 2320                      move.l     -(a0),-(a1)
[00012bb2] 2320                      move.l     -(a0),-(a1)
[00012bb4] 2320                      move.l     -(a0),-(a1)
[00012bb6] 2320                      move.l     -(a0),-(a1)
[00012bb8] 2320                      move.l     -(a0),-(a1)
[00012bba] 2320                      move.l     -(a0),-(a1)
[00012bbc] 2320                      move.l     -(a0),-(a1)
[00012bbe] 51cc ffde                 dbf        d4,$00012B9E
[00012bc2] 3c20                      move.w     -(a0),d6
[00012bc4] 4646                      not.w      d6
[00012bc6] cc42                      and.w      d2,d6
[00012bc8] 8561                      or.w       d2,-(a1)
[00012bca] bd51                      eor.w      d6,(a1)
[00012bcc] 90ca                      suba.w     a2,a0
[00012bce] 92cb                      suba.w     a3,a1
[00012bd0] 51cd ffba                 dbf        d5,$00012B8C
[00012bd4] 4e75                      rts
[00012bd6] 4a42                      tst.w      d2
[00012bd8] 6720                      beq.s      $00012BFA
[00012bda] 5588                      subq.l     #2,a0
[00012bdc] 5589                      subq.l     #2,a1
[00012bde] 4842                      swap       d2
[00012be0] 3403                      move.w     d3,d2
[00012be2] 2602                      move.l     d2,d3
[00012be4] 4683                      not.l      d3
[00012be6] 544a                      addq.w     #2,a2
[00012be8] 544b                      addq.w     #2,a3
[00012bea] 3c0a                      move.w     a2,d6
[00012bec] 4446                      neg.w      d6
[00012bee] 3446                      movea.w    d6,a2
[00012bf0] 3c0b                      move.w     a3,d6
[00012bf2] 4446                      neg.w      d6
[00012bf4] 3646                      movea.w    d6,a3
[00012bf6] 6000 f3ce                 bra        $00011FC6
[00012bfa] 3403                      move.w     d3,d2
[00012bfc] 4643                      not.w      d3
[00012bfe] 3c0a                      move.w     a2,d6
[00012c00] 4446                      neg.w      d6
[00012c02] 3446                      movea.w    d6,a2
[00012c04] 3c0b                      move.w     a3,d6
[00012c06] 4446                      neg.w      d6
[00012c08] 3646                      movea.w    d6,a3
[00012c0a] 6000 f3d0                 bra        $00011FDC
[00012c0e] 3c10                      move.w     (a0),d6
[00012c10] 4ed4                      jmp        (a4)
[00012c12] 4846                      swap       d6
[00012c14] 3c20                      move.w     -(a0),d6
[00012c16] 4846                      swap       d6
[00012c18] 2e06                      move.l     d6,d7
[00012c1a] e0be                      ror.l      d0,d6
[00012c1c] 4646                      not.w      d6
[00012c1e] cc43                      and.w      d3,d6
[00012c20] 8751                      or.w       d3,(a1)
[00012c22] bd51                      eor.w      d6,(a1)
[00012c24] 3801                      move.w     d1,d4
[00012c26] 6b10                      bmi.s      $00012C38
[00012c28] 2c07                      move.l     d7,d6
[00012c2a] 3c20                      move.w     -(a0),d6
[00012c2c] 4846                      swap       d6
[00012c2e] 2e06                      move.l     d6,d7
[00012c30] e0be                      ror.l      d0,d6
[00012c32] 3306                      move.w     d6,-(a1)
[00012c34] 51cc fff2                 dbf        d4,$00012C28
[00012c38] 4ed5                      jmp        (a5)
[00012c3a] 3e20                      move.w     -(a0),d7
[00012c3c] 4847                      swap       d7
[00012c3e] e0bf                      ror.l      d0,d7
[00012c40] 4647                      not.w      d7
[00012c42] ce42                      and.w      d2,d7
[00012c44] 8561                      or.w       d2,-(a1)
[00012c46] bf51                      eor.w      d7,(a1)
[00012c48] 90ca                      suba.w     a2,a0
[00012c4a] 92cb                      suba.w     a3,a1
[00012c4c] 51cd ffc0                 dbf        d5,$00012C0E
[00012c50] 4e75                      rts
[00012c52] 3c10                      move.w     (a0),d6
[00012c54] 4ed4                      jmp        (a4)
[00012c56] 4846                      swap       d6
[00012c58] 3c20                      move.w     -(a0),d6
[00012c5a] 3e06                      move.w     d6,d7
[00012c5c] e1be                      rol.l      d0,d6
[00012c5e] 4646                      not.w      d6
[00012c60] cc43                      and.w      d3,d6
[00012c62] 8751                      or.w       d3,(a1)
[00012c64] bd51                      eor.w      d6,(a1)
[00012c66] 3801                      move.w     d1,d4
[00012c68] 6b10                      bmi.s      $00012C7A
[00012c6a] 3c07                      move.w     d7,d6
[00012c6c] 4846                      swap       d6
[00012c6e] 3c20                      move.w     -(a0),d6
[00012c70] 3e06                      move.w     d6,d7
[00012c72] e1be                      rol.l      d0,d6
[00012c74] 3306                      move.w     d6,-(a1)
[00012c76] 51cc fff2                 dbf        d4,$00012C6A
[00012c7a] 4847                      swap       d7
[00012c7c] 4ed5                      jmp        (a5)
[00012c7e] 3e20                      move.w     -(a0),d7
[00012c80] e1bf                      rol.l      d0,d7
[00012c82] 4647                      not.w      d7
[00012c84] ce42                      and.w      d2,d7
[00012c86] 8561                      or.w       d2,-(a1)
[00012c88] bf51                      eor.w      d7,(a1)
[00012c8a] 90ca                      suba.w     a2,a0
[00012c8c] 92cb                      suba.w     a3,a1
[00012c8e] 51cd ffc2                 dbf        d5,$00012C52
[00012c92] 4e75                      rts
[00012c94] 3c10                      move.w     (a0),d6
[00012c96] cc43                      and.w      d3,d6
[00012c98] 4646                      not.w      d6
[00012c9a] cd51                      and.w      d6,(a1)
[00012c9c] 3801                      move.w     d1,d4
[00012c9e] 6b0a                      bmi.s      $00012CAA
[00012ca0] 3c20                      move.w     -(a0),d6
[00012ca2] 4646                      not.w      d6
[00012ca4] cd61                      and.w      d6,-(a1)
[00012ca6] 51cc fff8                 dbf        d4,$00012CA0
[00012caa] 4ed5                      jmp        (a5)
[00012cac] 3c20                      move.w     -(a0),d6
[00012cae] cc42                      and.w      d2,d6
[00012cb0] 4646                      not.w      d6
[00012cb2] cd61                      and.w      d6,-(a1)
[00012cb4] 90ca                      suba.w     a2,a0
[00012cb6] 92cb                      suba.w     a3,a1
[00012cb8] 51cd ffda                 dbf        d5,$00012C94
[00012cbc] 4e75                      rts
[00012cbe] 3c10                      move.w     (a0),d6
[00012cc0] 4ed4                      jmp        (a4)
[00012cc2] 4846                      swap       d6
[00012cc4] 3c20                      move.w     -(a0),d6
[00012cc6] 4846                      swap       d6
[00012cc8] 2e06                      move.l     d6,d7
[00012cca] e0be                      ror.l      d0,d6
[00012ccc] cc43                      and.w      d3,d6
[00012cce] 4646                      not.w      d6
[00012cd0] cd51                      and.w      d6,(a1)
[00012cd2] 3801                      move.w     d1,d4
[00012cd4] 6b12                      bmi.s      $00012CE8
[00012cd6] 2c07                      move.l     d7,d6
[00012cd8] 3c20                      move.w     -(a0),d6
[00012cda] 4846                      swap       d6
[00012cdc] 2e06                      move.l     d6,d7
[00012cde] e0be                      ror.l      d0,d6
[00012ce0] 4646                      not.w      d6
[00012ce2] cd61                      and.w      d6,-(a1)
[00012ce4] 51cc fff0                 dbf        d4,$00012CD6
[00012ce8] 4ed5                      jmp        (a5)
[00012cea] 3e20                      move.w     -(a0),d7
[00012cec] 4847                      swap       d7
[00012cee] e0bf                      ror.l      d0,d7
[00012cf0] ce42                      and.w      d2,d7
[00012cf2] 4647                      not.w      d7
[00012cf4] cf61                      and.w      d7,-(a1)
[00012cf6] 90ca                      suba.w     a2,a0
[00012cf8] 92cb                      suba.w     a3,a1
[00012cfa] 51cd ffc2                 dbf        d5,$00012CBE
[00012cfe] 4e75                      rts
[00012d00] 3c10                      move.w     (a0),d6
[00012d02] 4ed4                      jmp        (a4)
[00012d04] 4846                      swap       d6
[00012d06] 3c20                      move.w     -(a0),d6
[00012d08] 3e06                      move.w     d6,d7
[00012d0a] e1be                      rol.l      d0,d6
[00012d0c] cc43                      and.w      d3,d6
[00012d0e] 4646                      not.w      d6
[00012d10] cd51                      and.w      d6,(a1)
[00012d12] 3801                      move.w     d1,d4
[00012d14] 6b12                      bmi.s      $00012D28
[00012d16] 3c07                      move.w     d7,d6
[00012d18] 4846                      swap       d6
[00012d1a] 3c20                      move.w     -(a0),d6
[00012d1c] 3e06                      move.w     d6,d7
[00012d1e] e1be                      rol.l      d0,d6
[00012d20] 4646                      not.w      d6
[00012d22] cd61                      and.w      d6,-(a1)
[00012d24] 51cc fff0                 dbf        d4,$00012D16
[00012d28] 4847                      swap       d7
[00012d2a] 4ed5                      jmp        (a5)
[00012d2c] 3e20                      move.w     -(a0),d7
[00012d2e] e1bf                      rol.l      d0,d7
[00012d30] ce42                      and.w      d2,d7
[00012d32] 4647                      not.w      d7
[00012d34] cf61                      and.w      d7,-(a1)
[00012d36] 90ca                      suba.w     a2,a0
[00012d38] 92cb                      suba.w     a3,a1
[00012d3a] 51cd ffc4                 dbf        d5,$00012D00
[00012d3e] 4e75                      rts
[00012d40] 4e75                      rts
[00012d42] 3c10                      move.w     (a0),d6
[00012d44] cc43                      and.w      d3,d6
[00012d46] bd51                      eor.w      d6,(a1)
[00012d48] 3801                      move.w     d1,d4
[00012d4a] 6b08                      bmi.s      $00012D54
[00012d4c] 3c20                      move.w     -(a0),d6
[00012d4e] bd61                      eor.w      d6,-(a1)
[00012d50] 51cc fffa                 dbf        d4,$00012D4C
[00012d54] 4ed5                      jmp        (a5)
[00012d56] 3c20                      move.w     -(a0),d6
[00012d58] cc42                      and.w      d2,d6
[00012d5a] bd61                      eor.w      d6,-(a1)
[00012d5c] 90ca                      suba.w     a2,a0
[00012d5e] 92cb                      suba.w     a3,a1
[00012d60] 51cd ffe0                 dbf        d5,$00012D42
[00012d64] 4e75                      rts
[00012d66] 3c10                      move.w     (a0),d6
[00012d68] 4ed4                      jmp        (a4)
[00012d6a] 4846                      swap       d6
[00012d6c] 3c20                      move.w     -(a0),d6
[00012d6e] 4846                      swap       d6
[00012d70] 2e06                      move.l     d6,d7
[00012d72] e0be                      ror.l      d0,d6
[00012d74] cc43                      and.w      d3,d6
[00012d76] bd51                      eor.w      d6,(a1)
[00012d78] 3801                      move.w     d1,d4
[00012d7a] 6b10                      bmi.s      $00012D8C
[00012d7c] 2c07                      move.l     d7,d6
[00012d7e] 3c20                      move.w     -(a0),d6
[00012d80] 4846                      swap       d6
[00012d82] 2e06                      move.l     d6,d7
[00012d84] e0be                      ror.l      d0,d6
[00012d86] bd61                      eor.w      d6,-(a1)
[00012d88] 51cc fff2                 dbf        d4,$00012D7C
[00012d8c] 4ed5                      jmp        (a5)
[00012d8e] 3e20                      move.w     -(a0),d7
[00012d90] 4847                      swap       d7
[00012d92] e0bf                      ror.l      d0,d7
[00012d94] ce42                      and.w      d2,d7
[00012d96] bf61                      eor.w      d7,-(a1)
[00012d98] 90ca                      suba.w     a2,a0
[00012d9a] 92cb                      suba.w     a3,a1
[00012d9c] 51cd ffc8                 dbf        d5,$00012D66
[00012da0] 4e75                      rts
[00012da2] 3c10                      move.w     (a0),d6
[00012da4] 4ed4                      jmp        (a4)
[00012da6] 4846                      swap       d6
[00012da8] 3c20                      move.w     -(a0),d6
[00012daa] 3e06                      move.w     d6,d7
[00012dac] e1be                      rol.l      d0,d6
[00012dae] cc43                      and.w      d3,d6
[00012db0] bd51                      eor.w      d6,(a1)
[00012db2] 3801                      move.w     d1,d4
[00012db4] 6b10                      bmi.s      $00012DC6
[00012db6] 3c07                      move.w     d7,d6
[00012db8] 4846                      swap       d6
[00012dba] 3c20                      move.w     -(a0),d6
[00012dbc] 3e06                      move.w     d6,d7
[00012dbe] e1be                      rol.l      d0,d6
[00012dc0] bd61                      eor.w      d6,-(a1)
[00012dc2] 51cc fff2                 dbf        d4,$00012DB6
[00012dc6] 4847                      swap       d7
[00012dc8] 4ed5                      jmp        (a5)
[00012dca] 3e20                      move.w     -(a0),d7
[00012dcc] e1bf                      rol.l      d0,d7
[00012dce] ce42                      and.w      d2,d7
[00012dd0] bf61                      eor.w      d7,-(a1)
[00012dd2] 90ca                      suba.w     a2,a0
[00012dd4] 92cb                      suba.w     a3,a1
[00012dd6] 51cd ffca                 dbf        d5,$00012DA2
[00012dda] 4e75                      rts
[00012ddc] 3c10                      move.w     (a0),d6
[00012dde] cc43                      and.w      d3,d6
[00012de0] 8d51                      or.w       d6,(a1)
[00012de2] 3801                      move.w     d1,d4
[00012de4] 6b08                      bmi.s      $00012DEE
[00012de6] 3c20                      move.w     -(a0),d6
[00012de8] 8d61                      or.w       d6,-(a1)
[00012dea] 51cc fffa                 dbf        d4,$00012DE6
[00012dee] 4ed5                      jmp        (a5)
[00012df0] 3c20                      move.w     -(a0),d6
[00012df2] cc42                      and.w      d2,d6
[00012df4] 8d61                      or.w       d6,-(a1)
[00012df6] 90ca                      suba.w     a2,a0
[00012df8] 92cb                      suba.w     a3,a1
[00012dfa] 51cd ffe0                 dbf        d5,$00012DDC
[00012dfe] 4e75                      rts
[00012e00] 3c10                      move.w     (a0),d6
[00012e02] 4ed4                      jmp        (a4)
[00012e04] 4846                      swap       d6
[00012e06] 3c20                      move.w     -(a0),d6
[00012e08] 4846                      swap       d6
[00012e0a] 2e06                      move.l     d6,d7
[00012e0c] e0be                      ror.l      d0,d6
[00012e0e] cc43                      and.w      d3,d6
[00012e10] 8d51                      or.w       d6,(a1)
[00012e12] 3801                      move.w     d1,d4
[00012e14] 6b10                      bmi.s      $00012E26
[00012e16] 2c07                      move.l     d7,d6
[00012e18] 3c20                      move.w     -(a0),d6
[00012e1a] 4846                      swap       d6
[00012e1c] 2e06                      move.l     d6,d7
[00012e1e] e0be                      ror.l      d0,d6
[00012e20] 8d61                      or.w       d6,-(a1)
[00012e22] 51cc fff2                 dbf        d4,$00012E16
[00012e26] 4ed5                      jmp        (a5)
[00012e28] 3e20                      move.w     -(a0),d7
[00012e2a] 4847                      swap       d7
[00012e2c] e0bf                      ror.l      d0,d7
[00012e2e] ce42                      and.w      d2,d7
[00012e30] 8f61                      or.w       d7,-(a1)
[00012e32] 90ca                      suba.w     a2,a0
[00012e34] 92cb                      suba.w     a3,a1
[00012e36] 51cd ffc8                 dbf        d5,$00012E00
[00012e3a] 4e75                      rts
[00012e3c] 3c10                      move.w     (a0),d6
[00012e3e] 4ed4                      jmp        (a4)
[00012e40] 4846                      swap       d6
[00012e42] 3c20                      move.w     -(a0),d6
[00012e44] 3e06                      move.w     d6,d7
[00012e46] e1be                      rol.l      d0,d6
[00012e48] cc43                      and.w      d3,d6
[00012e4a] 8d51                      or.w       d6,(a1)
[00012e4c] 3801                      move.w     d1,d4
[00012e4e] 6b10                      bmi.s      $00012E60
[00012e50] 3c07                      move.w     d7,d6
[00012e52] 4846                      swap       d6
[00012e54] 3c20                      move.w     -(a0),d6
[00012e56] 3e06                      move.w     d6,d7
[00012e58] e1be                      rol.l      d0,d6
[00012e5a] 8d61                      or.w       d6,-(a1)
[00012e5c] 51cc fff2                 dbf        d4,$00012E50
[00012e60] 4847                      swap       d7
[00012e62] 4ed5                      jmp        (a5)
[00012e64] 3e20                      move.w     -(a0),d7
[00012e66] e1bf                      rol.l      d0,d7
[00012e68] ce42                      and.w      d2,d7
[00012e6a] 8f61                      or.w       d7,-(a1)
[00012e6c] 90ca                      suba.w     a2,a0
[00012e6e] 92cb                      suba.w     a3,a1
[00012e70] 51cd ffca                 dbf        d5,$00012E3C
[00012e74] 4e75                      rts
[00012e76] 3c10                      move.w     (a0),d6
[00012e78] cc43                      and.w      d3,d6
[00012e7a] 8d51                      or.w       d6,(a1)
[00012e7c] b751                      eor.w      d3,(a1)
[00012e7e] 3801                      move.w     d1,d4
[00012e80] 6b0a                      bmi.s      $00012E8C
[00012e82] 3c20                      move.w     -(a0),d6
[00012e84] 8d61                      or.w       d6,-(a1)
[00012e86] 4651                      not.w      (a1)
[00012e88] 51cc fff8                 dbf        d4,$00012E82
[00012e8c] 4ed5                      jmp        (a5)
[00012e8e] 3c20                      move.w     -(a0),d6
[00012e90] cc42                      and.w      d2,d6
[00012e92] 8d61                      or.w       d6,-(a1)
[00012e94] b551                      eor.w      d2,(a1)
[00012e96] 90ca                      suba.w     a2,a0
[00012e98] 92cb                      suba.w     a3,a1
[00012e9a] 51cd ffda                 dbf        d5,$00012E76
[00012e9e] 4e75                      rts
[00012ea0] 3c10                      move.w     (a0),d6
[00012ea2] 4ed4                      jmp        (a4)
[00012ea4] 4846                      swap       d6
[00012ea6] 3c20                      move.w     -(a0),d6
[00012ea8] 4846                      swap       d6
[00012eaa] 2e06                      move.l     d6,d7
[00012eac] e0be                      ror.l      d0,d6
[00012eae] cc43                      and.w      d3,d6
[00012eb0] 8d51                      or.w       d6,(a1)
[00012eb2] b751                      eor.w      d3,(a1)
[00012eb4] 3801                      move.w     d1,d4
[00012eb6] 6b12                      bmi.s      $00012ECA
[00012eb8] 2c07                      move.l     d7,d6
[00012eba] 3c20                      move.w     -(a0),d6
[00012ebc] 4846                      swap       d6
[00012ebe] 2e06                      move.l     d6,d7
[00012ec0] e0be                      ror.l      d0,d6
[00012ec2] 8d61                      or.w       d6,-(a1)
[00012ec4] 4651                      not.w      (a1)
[00012ec6] 51cc fff0                 dbf        d4,$00012EB8
[00012eca] 4ed5                      jmp        (a5)
[00012ecc] 3e20                      move.w     -(a0),d7
[00012ece] 4847                      swap       d7
[00012ed0] e0bf                      ror.l      d0,d7
[00012ed2] ce42                      and.w      d2,d7
[00012ed4] 8f61                      or.w       d7,-(a1)
[00012ed6] b551                      eor.w      d2,(a1)
[00012ed8] 90ca                      suba.w     a2,a0
[00012eda] 92cb                      suba.w     a3,a1
[00012edc] 51cd ffc2                 dbf        d5,$00012EA0
[00012ee0] 4e75                      rts
[00012ee2] 3c10                      move.w     (a0),d6
[00012ee4] 4ed4                      jmp        (a4)
[00012ee6] 4846                      swap       d6
[00012ee8] 3c20                      move.w     -(a0),d6
[00012eea] 3e06                      move.w     d6,d7
[00012eec] e1be                      rol.l      d0,d6
[00012eee] cc43                      and.w      d3,d6
[00012ef0] 8d51                      or.w       d6,(a1)
[00012ef2] b751                      eor.w      d3,(a1)
[00012ef4] 3801                      move.w     d1,d4
[00012ef6] 6b12                      bmi.s      $00012F0A
[00012ef8] 3c07                      move.w     d7,d6
[00012efa] 4846                      swap       d6
[00012efc] 3c20                      move.w     -(a0),d6
[00012efe] 3e06                      move.w     d6,d7
[00012f00] e1be                      rol.l      d0,d6
[00012f02] 8d61                      or.w       d6,-(a1)
[00012f04] 4651                      not.w      (a1)
[00012f06] 51cc fff0                 dbf        d4,$00012EF8
[00012f0a] 4847                      swap       d7
[00012f0c] 4ed5                      jmp        (a5)
[00012f0e] 3e20                      move.w     -(a0),d7
[00012f10] e1bf                      rol.l      d0,d7
[00012f12] ce42                      and.w      d2,d7
[00012f14] 8f61                      or.w       d7,-(a1)
[00012f16] b551                      eor.w      d2,(a1)
[00012f18] 90ca                      suba.w     a2,a0
[00012f1a] 92cb                      suba.w     a3,a1
[00012f1c] 51cd ffc4                 dbf        d5,$00012EE2
[00012f20] 4e75                      rts
[00012f22] 3c10                      move.w     (a0),d6
[00012f24] 4646                      not.w      d6
[00012f26] cc43                      and.w      d3,d6
[00012f28] bd51                      eor.w      d6,(a1)
[00012f2a] 3801                      move.w     d1,d4
[00012f2c] 6b0a                      bmi.s      $00012F38
[00012f2e] 3c20                      move.w     -(a0),d6
[00012f30] 4646                      not.w      d6
[00012f32] bd61                      eor.w      d6,-(a1)
[00012f34] 51cc fff8                 dbf        d4,$00012F2E
[00012f38] 4ed5                      jmp        (a5)
[00012f3a] 3c20                      move.w     -(a0),d6
[00012f3c] 4646                      not.w      d6
[00012f3e] cc42                      and.w      d2,d6
[00012f40] bd61                      eor.w      d6,-(a1)
[00012f42] 90ca                      suba.w     a2,a0
[00012f44] 92cb                      suba.w     a3,a1
[00012f46] 51cd ffda                 dbf        d5,$00012F22
[00012f4a] 4e75                      rts
[00012f4c] 3c10                      move.w     (a0),d6
[00012f4e] 4ed4                      jmp        (a4)
[00012f50] 4846                      swap       d6
[00012f52] 3c20                      move.w     -(a0),d6
[00012f54] 4846                      swap       d6
[00012f56] 2e06                      move.l     d6,d7
[00012f58] e0be                      ror.l      d0,d6
[00012f5a] 4646                      not.w      d6
[00012f5c] cc43                      and.w      d3,d6
[00012f5e] bd51                      eor.w      d6,(a1)
[00012f60] 3801                      move.w     d1,d4
[00012f62] 6b12                      bmi.s      $00012F76
[00012f64] 2c07                      move.l     d7,d6
[00012f66] 3c20                      move.w     -(a0),d6
[00012f68] 4846                      swap       d6
[00012f6a] 2e06                      move.l     d6,d7
[00012f6c] e0be                      ror.l      d0,d6
[00012f6e] 4646                      not.w      d6
[00012f70] bd61                      eor.w      d6,-(a1)
[00012f72] 51cc fff0                 dbf        d4,$00012F64
[00012f76] 4ed5                      jmp        (a5)
[00012f78] 3e20                      move.w     -(a0),d7
[00012f7a] 4847                      swap       d7
[00012f7c] e0bf                      ror.l      d0,d7
[00012f7e] 4647                      not.w      d7
[00012f80] ce42                      and.w      d2,d7
[00012f82] bf61                      eor.w      d7,-(a1)
[00012f84] 90ca                      suba.w     a2,a0
[00012f86] 92cb                      suba.w     a3,a1
[00012f88] 51cd ffc2                 dbf        d5,$00012F4C
[00012f8c] 4e75                      rts
[00012f8e] 3c10                      move.w     (a0),d6
[00012f90] 4ed4                      jmp        (a4)
[00012f92] 4846                      swap       d6
[00012f94] 3c20                      move.w     -(a0),d6
[00012f96] 3e06                      move.w     d6,d7
[00012f98] e1be                      rol.l      d0,d6
[00012f9a] 4646                      not.w      d6
[00012f9c] cc43                      and.w      d3,d6
[00012f9e] bd51                      eor.w      d6,(a1)
[00012fa0] 3801                      move.w     d1,d4
[00012fa2] 6b12                      bmi.s      $00012FB6
[00012fa4] 3c07                      move.w     d7,d6
[00012fa6] 4846                      swap       d6
[00012fa8] 3c20                      move.w     -(a0),d6
[00012faa] 3e06                      move.w     d6,d7
[00012fac] e1be                      rol.l      d0,d6
[00012fae] 4646                      not.w      d6
[00012fb0] bd61                      eor.w      d6,-(a1)
[00012fb2] 51cc fff0                 dbf        d4,$00012FA4
[00012fb6] 4847                      swap       d7
[00012fb8] 4ed5                      jmp        (a5)
[00012fba] 3e20                      move.w     -(a0),d7
[00012fbc] e1bf                      rol.l      d0,d7
[00012fbe] 4647                      not.w      d7
[00012fc0] ce42                      and.w      d2,d7
[00012fc2] bf61                      eor.w      d7,-(a1)
[00012fc4] 90ca                      suba.w     a2,a0
[00012fc6] 92cb                      suba.w     a3,a1
[00012fc8] 51cd ffc4                 dbf        d5,$00012F8E
[00012fcc] 4e75                      rts
[00012fce] 4bfa 001c                 lea.l      $00012FEC(pc),a5
[00012fd2] 4a42                      tst.w      d2
[00012fd4] 6704                      beq.s      $00012FDA
[00012fd6] 4bfa 0012                 lea.l      $00012FEA(pc),a5
[00012fda] b751                      eor.w      d3,(a1)
[00012fdc] 3801                      move.w     d1,d4
[00012fde] 6b06                      bmi.s      $00012FE6
[00012fe0] 4661                      not.w      -(a1)
[00012fe2] 51cc fffc                 dbf        d4,$00012FE0
[00012fe6] 4ed5                      jmp        (a5)
[00012fe8] 4e71                      nop
[00012fea] b561                      eor.w      d2,-(a1)
[00012fec] 90ca                      suba.w     a2,a0
[00012fee] 92cb                      suba.w     a3,a1
[00012ff0] 51cd ffe8                 dbf        d5,$00012FDA
[00012ff4] 4e75                      rts
[00012ff6] 3c10                      move.w     (a0),d6
[00012ff8] cc43                      and.w      d3,d6
[00012ffa] b751                      eor.w      d3,(a1)
[00012ffc] 8d51                      or.w       d6,(a1)
[00012ffe] 3801                      move.w     d1,d4
[00013000] 6b0a                      bmi.s      $0001300C
[00013002] 3c20                      move.w     -(a0),d6
[00013004] 4661                      not.w      -(a1)
[00013006] 8d51                      or.w       d6,(a1)
[00013008] 51cc fff8                 dbf        d4,$00013002
[0001300c] 4ed5                      jmp        (a5)
[0001300e] 3c20                      move.w     -(a0),d6
[00013010] cc42                      and.w      d2,d6
[00013012] b561                      eor.w      d2,-(a1)
[00013014] 8d51                      or.w       d6,(a1)
[00013016] 90ca                      suba.w     a2,a0
[00013018] 92cb                      suba.w     a3,a1
[0001301a] 51cd ffda                 dbf        d5,$00012FF6
[0001301e] 4e75                      rts
[00013020] 3c10                      move.w     (a0),d6
[00013022] 4ed4                      jmp        (a4)
[00013024] 4846                      swap       d6
[00013026] 3c20                      move.w     -(a0),d6
[00013028] 4846                      swap       d6
[0001302a] 2e06                      move.l     d6,d7
[0001302c] e0be                      ror.l      d0,d6
[0001302e] cc43                      and.w      d3,d6
[00013030] b751                      eor.w      d3,(a1)
[00013032] 8d51                      or.w       d6,(a1)
[00013034] 3801                      move.w     d1,d4
[00013036] 6b12                      bmi.s      $0001304A
[00013038] 2c07                      move.l     d7,d6
[0001303a] 3c20                      move.w     -(a0),d6
[0001303c] 4846                      swap       d6
[0001303e] 2e06                      move.l     d6,d7
[00013040] e0be                      ror.l      d0,d6
[00013042] 4661                      not.w      -(a1)
[00013044] 8d51                      or.w       d6,(a1)
[00013046] 51cc fff0                 dbf        d4,$00013038
[0001304a] 4ed5                      jmp        (a5)
[0001304c] 3e20                      move.w     -(a0),d7
[0001304e] 4847                      swap       d7
[00013050] e0bf                      ror.l      d0,d7
[00013052] ce42                      and.w      d2,d7
[00013054] b561                      eor.w      d2,-(a1)
[00013056] 8f51                      or.w       d7,(a1)
[00013058] 90ca                      suba.w     a2,a0
[0001305a] 92cb                      suba.w     a3,a1
[0001305c] 51cd ffc2                 dbf        d5,$00013020
[00013060] 4e75                      rts
[00013062] 3c10                      move.w     (a0),d6
[00013064] 4ed4                      jmp        (a4)
[00013066] 4846                      swap       d6
[00013068] 3c20                      move.w     -(a0),d6
[0001306a] 3e06                      move.w     d6,d7
[0001306c] e1be                      rol.l      d0,d6
[0001306e] cc43                      and.w      d3,d6
[00013070] b751                      eor.w      d3,(a1)
[00013072] 8d51                      or.w       d6,(a1)
[00013074] 3801                      move.w     d1,d4
[00013076] 6b12                      bmi.s      $0001308A
[00013078] 3c07                      move.w     d7,d6
[0001307a] 4846                      swap       d6
[0001307c] 3c20                      move.w     -(a0),d6
[0001307e] 3e06                      move.w     d6,d7
[00013080] e1be                      rol.l      d0,d6
[00013082] 4661                      not.w      -(a1)
[00013084] 8d51                      or.w       d6,(a1)
[00013086] 51cc fff0                 dbf        d4,$00013078
[0001308a] 4847                      swap       d7
[0001308c] 4ed5                      jmp        (a5)
[0001308e] 3e20                      move.w     -(a0),d7
[00013090] e1bf                      rol.l      d0,d7
[00013092] ce42                      and.w      d2,d7
[00013094] b561                      eor.w      d2,-(a1)
[00013096] 8f51                      or.w       d7,(a1)
[00013098] 90ca                      suba.w     a2,a0
[0001309a] 92cb                      suba.w     a3,a1
[0001309c] 51cd ffc4                 dbf        d5,$00013062
[000130a0] 4e75                      rts
[000130a2] 3c10                      move.w     (a0),d6
[000130a4] 4646                      not.w      d6
[000130a6] cc43                      and.w      d3,d6
[000130a8] 4643                      not.w      d3
[000130aa] c751                      and.w      d3,(a1)
[000130ac] 4643                      not.w      d3
[000130ae] 8d51                      or.w       d6,(a1)
[000130b0] 3801                      move.w     d1,d4
[000130b2] 6b0a                      bmi.s      $000130BE
[000130b4] 3c20                      move.w     -(a0),d6
[000130b6] 4646                      not.w      d6
[000130b8] 3306                      move.w     d6,-(a1)
[000130ba] 51cc fff8                 dbf        d4,$000130B4
[000130be] 4ed5                      jmp        (a5)
[000130c0] 3c20                      move.w     -(a0),d6
[000130c2] 4646                      not.w      d6
[000130c4] cc42                      and.w      d2,d6
[000130c6] 4642                      not.w      d2
[000130c8] c561                      and.w      d2,-(a1)
[000130ca] 4642                      not.w      d2
[000130cc] 8d51                      or.w       d6,(a1)
[000130ce] 90ca                      suba.w     a2,a0
[000130d0] 92cb                      suba.w     a3,a1
[000130d2] 51cd ffce                 dbf        d5,$000130A2
[000130d6] 4e75                      rts
[000130d8] 3c10                      move.w     (a0),d6
[000130da] 4ed4                      jmp        (a4)
[000130dc] 4846                      swap       d6
[000130de] 3c20                      move.w     -(a0),d6
[000130e0] 4846                      swap       d6
[000130e2] 2e06                      move.l     d6,d7
[000130e4] e0be                      ror.l      d0,d6
[000130e6] 4646                      not.w      d6
[000130e8] cc43                      and.w      d3,d6
[000130ea] 4643                      not.w      d3
[000130ec] c751                      and.w      d3,(a1)
[000130ee] 4643                      not.w      d3
[000130f0] 8d51                      or.w       d6,(a1)
[000130f2] 3801                      move.w     d1,d4
[000130f4] 6b12                      bmi.s      $00013108
[000130f6] 2c07                      move.l     d7,d6
[000130f8] 3c20                      move.w     -(a0),d6
[000130fa] 4846                      swap       d6
[000130fc] 2e06                      move.l     d6,d7
[000130fe] e0be                      ror.l      d0,d6
[00013100] 4646                      not.w      d6
[00013102] 3306                      move.w     d6,-(a1)
[00013104] 51cc fff0                 dbf        d4,$000130F6
[00013108] 4ed5                      jmp        (a5)
[0001310a] 3e20                      move.w     -(a0),d7
[0001310c] 4847                      swap       d7
[0001310e] e0bf                      ror.l      d0,d7
[00013110] 4647                      not.w      d7
[00013112] ce42                      and.w      d2,d7
[00013114] 4642                      not.w      d2
[00013116] c561                      and.w      d2,-(a1)
[00013118] 4642                      not.w      d2
[0001311a] 8f51                      or.w       d7,(a1)
[0001311c] 90ca                      suba.w     a2,a0
[0001311e] 92cb                      suba.w     a3,a1
[00013120] 51cd ffb6                 dbf        d5,$000130D8
[00013124] 4e75                      rts
[00013126] 3c10                      move.w     (a0),d6
[00013128] 4ed4                      jmp        (a4)
[0001312a] 4846                      swap       d6
[0001312c] 3c20                      move.w     -(a0),d6
[0001312e] 3e06                      move.w     d6,d7
[00013130] e1be                      rol.l      d0,d6
[00013132] 4646                      not.w      d6
[00013134] cc43                      and.w      d3,d6
[00013136] 4643                      not.w      d3
[00013138] c751                      and.w      d3,(a1)
[0001313a] 4643                      not.w      d3
[0001313c] 8d51                      or.w       d6,(a1)
[0001313e] 3801                      move.w     d1,d4
[00013140] 6b12                      bmi.s      $00013154
[00013142] 3c07                      move.w     d7,d6
[00013144] 4846                      swap       d6
[00013146] 3c20                      move.w     -(a0),d6
[00013148] 3e06                      move.w     d6,d7
[0001314a] e1be                      rol.l      d0,d6
[0001314c] 4646                      not.w      d6
[0001314e] 3306                      move.w     d6,-(a1)
[00013150] 51cc fff0                 dbf        d4,$00013142
[00013154] 4847                      swap       d7
[00013156] 4ed5                      jmp        (a5)
[00013158] 3e20                      move.w     -(a0),d7
[0001315a] e1bf                      rol.l      d0,d7
[0001315c] 4647                      not.w      d7
[0001315e] ce42                      and.w      d2,d7
[00013160] 4642                      not.w      d2
[00013162] c561                      and.w      d2,-(a1)
[00013164] 4642                      not.w      d2
[00013166] 8f51                      or.w       d7,(a1)
[00013168] 90ca                      suba.w     a2,a0
[0001316a] 92cb                      suba.w     a3,a1
[0001316c] 51cd ffb8                 dbf        d5,$00013126
[00013170] 4e75                      rts
[00013172] 3c10                      move.w     (a0),d6
[00013174] 4646                      not.w      d6
[00013176] cc43                      and.w      d3,d6
[00013178] 8d51                      or.w       d6,(a1)
[0001317a] 3801                      move.w     d1,d4
[0001317c] 6b0a                      bmi.s      $00013188
[0001317e] 3c20                      move.w     -(a0),d6
[00013180] 4646                      not.w      d6
[00013182] 8d61                      or.w       d6,-(a1)
[00013184] 51cc fff8                 dbf        d4,$0001317E
[00013188] 4ed5                      jmp        (a5)
[0001318a] 3c20                      move.w     -(a0),d6
[0001318c] 4646                      not.w      d6
[0001318e] cc42                      and.w      d2,d6
[00013190] 8d61                      or.w       d6,-(a1)
[00013192] 90ca                      suba.w     a2,a0
[00013194] 92cb                      suba.w     a3,a1
[00013196] 51cd ffda                 dbf        d5,$00013172
[0001319a] 4e75                      rts
[0001319c] 3c10                      move.w     (a0),d6
[0001319e] 4ed4                      jmp        (a4)
[000131a0] 4846                      swap       d6
[000131a2] 3c20                      move.w     -(a0),d6
[000131a4] 4846                      swap       d6
[000131a6] 2e06                      move.l     d6,d7
[000131a8] e0be                      ror.l      d0,d6
[000131aa] 4646                      not.w      d6
[000131ac] cc43                      and.w      d3,d6
[000131ae] 8d51                      or.w       d6,(a1)
[000131b0] 3801                      move.w     d1,d4
[000131b2] 6b12                      bmi.s      $000131C6
[000131b4] 2c07                      move.l     d7,d6
[000131b6] 3c20                      move.w     -(a0),d6
[000131b8] 4846                      swap       d6
[000131ba] 2e06                      move.l     d6,d7
[000131bc] e0be                      ror.l      d0,d6
[000131be] 4646                      not.w      d6
[000131c0] 8d61                      or.w       d6,-(a1)
[000131c2] 51cc fff0                 dbf        d4,$000131B4
[000131c6] 4ed5                      jmp        (a5)
[000131c8] 3e20                      move.w     -(a0),d7
[000131ca] 4847                      swap       d7
[000131cc] e0bf                      ror.l      d0,d7
[000131ce] 4647                      not.w      d7
[000131d0] ce42                      and.w      d2,d7
[000131d2] 8f61                      or.w       d7,-(a1)
[000131d4] 90ca                      suba.w     a2,a0
[000131d6] 92cb                      suba.w     a3,a1
[000131d8] 51cd ffc2                 dbf        d5,$0001319C
[000131dc] 4e75                      rts
[000131de] 3c10                      move.w     (a0),d6
[000131e0] 4ed4                      jmp        (a4)
[000131e2] 4846                      swap       d6
[000131e4] 3c20                      move.w     -(a0),d6
[000131e6] 3e06                      move.w     d6,d7
[000131e8] e1be                      rol.l      d0,d6
[000131ea] 4646                      not.w      d6
[000131ec] cc43                      and.w      d3,d6
[000131ee] 8d51                      or.w       d6,(a1)
[000131f0] 3801                      move.w     d1,d4
[000131f2] 6b12                      bmi.s      $00013206
[000131f4] 3c07                      move.w     d7,d6
[000131f6] 4846                      swap       d6
[000131f8] 3c20                      move.w     -(a0),d6
[000131fa] 3e06                      move.w     d6,d7
[000131fc] e1be                      rol.l      d0,d6
[000131fe] 4646                      not.w      d6
[00013200] 8d61                      or.w       d6,-(a1)
[00013202] 51cc fff0                 dbf        d4,$000131F4
[00013206] 4847                      swap       d7
[00013208] 4ed5                      jmp        (a5)
[0001320a] 3e20                      move.w     -(a0),d7
[0001320c] e1bf                      rol.l      d0,d7
[0001320e] 4647                      not.w      d7
[00013210] ce42                      and.w      d2,d7
[00013212] 8f61                      or.w       d7,-(a1)
[00013214] 90ca                      suba.w     a2,a0
[00013216] 92cb                      suba.w     a3,a1
[00013218] 51cd ffc4                 dbf        d5,$000131DE
[0001321c] 4e75                      rts
[0001321e] 3c10                      move.w     (a0),d6
[00013220] 8c43                      or.w       d3,d6
[00013222] cd51                      and.w      d6,(a1)
[00013224] b751                      eor.w      d3,(a1)
[00013226] 3801                      move.w     d1,d4
[00013228] 6b0a                      bmi.s      $00013234
[0001322a] 3c20                      move.w     -(a0),d6
[0001322c] cd61                      and.w      d6,-(a1)
[0001322e] 4651                      not.w      (a1)
[00013230] 51cc fff8                 dbf        d4,$0001322A
[00013234] 4ed5                      jmp        (a5)
[00013236] 3c20                      move.w     -(a0),d6
[00013238] 8c42                      or.w       d2,d6
[0001323a] cd61                      and.w      d6,-(a1)
[0001323c] 8551                      or.w       d2,(a1)
[0001323e] 90ca                      suba.w     a2,a0
[00013240] 92cb                      suba.w     a3,a1
[00013242] 51cd ffda                 dbf        d5,$0001321E
[00013246] 4e75                      rts
[00013248] 3c10                      move.w     (a0),d6
[0001324a] 4ed4                      jmp        (a4)
[0001324c] 4846                      swap       d6
[0001324e] 3c20                      move.w     -(a0),d6
[00013250] 4846                      swap       d6
[00013252] 2e06                      move.l     d6,d7
[00013254] e0be                      ror.l      d0,d6
[00013256] 8c43                      or.w       d3,d6
[00013258] cd51                      and.w      d6,(a1)
[0001325a] b751                      eor.w      d3,(a1)
[0001325c] 3801                      move.w     d1,d4
[0001325e] 6b12                      bmi.s      $00013272
[00013260] 2c07                      move.l     d7,d6
[00013262] 3c20                      move.w     -(a0),d6
[00013264] 4846                      swap       d6
[00013266] 2e06                      move.l     d6,d7
[00013268] e0be                      ror.l      d0,d6
[0001326a] cd61                      and.w      d6,-(a1)
[0001326c] 4651                      not.w      (a1)
[0001326e] 51cc fff0                 dbf        d4,$00013260
[00013272] 4ed5                      jmp        (a5)
[00013274] 3e20                      move.w     -(a0),d7
[00013276] 4847                      swap       d7
[00013278] e0bf                      ror.l      d0,d7
[0001327a] 8e42                      or.w       d2,d7
[0001327c] cf61                      and.w      d7,-(a1)
[0001327e] 8551                      or.w       d2,(a1)
[00013280] 90ca                      suba.w     a2,a0
[00013282] 92cb                      suba.w     a3,a1
[00013284] 51cd ffc2                 dbf        d5,$00013248
[00013288] 4e75                      rts
[0001328a] 3c10                      move.w     (a0),d6
[0001328c] 4ed4                      jmp        (a4)
[0001328e] 4846                      swap       d6
[00013290] 3c20                      move.w     -(a0),d6
[00013292] 3e06                      move.w     d6,d7
[00013294] e1be                      rol.l      d0,d6
[00013296] 8c43                      or.w       d3,d6
[00013298] cd51                      and.w      d6,(a1)
[0001329a] b751                      eor.w      d3,(a1)
[0001329c] 3801                      move.w     d1,d4
[0001329e] 6b12                      bmi.s      $000132B2
[000132a0] 3c07                      move.w     d7,d6
[000132a2] 4846                      swap       d6
[000132a4] 3c20                      move.w     -(a0),d6
[000132a6] 3e06                      move.w     d6,d7
[000132a8] e1be                      rol.l      d0,d6
[000132aa] cd61                      and.w      d6,-(a1)
[000132ac] 4651                      not.w      (a1)
[000132ae] 51cc fff0                 dbf        d4,$000132A0
[000132b2] 4847                      swap       d7
[000132b4] 4ed5                      jmp        (a5)
[000132b6] 3e20                      move.w     -(a0),d7
[000132b8] e1bf                      rol.l      d0,d7
[000132ba] 8e42                      or.w       d2,d7
[000132bc] cf61                      and.w      d7,-(a1)
[000132be] 8551                      or.w       d2,(a1)
[000132c0] 90ca                      suba.w     a2,a0
[000132c2] 92cb                      suba.w     a3,a1
[000132c4] 51cd ffc4                 dbf        d5,$0001328A
[000132c8] 4e75                      rts
[000132ca] 7eff                      moveq.l    #-1,d7
[000132cc] 4bfa 0018                 lea.l      $000132E6(pc),a5
[000132d0] 4a42                      tst.w      d2
[000132d2] 6604                      bne.s      $000132D8
[000132d4] 4bfa 0012                 lea.l      $000132E8(pc),a5
[000132d8] 8751                      or.w       d3,(a1)
[000132da] 3801                      move.w     d1,d4
[000132dc] 6b06                      bmi.s      $000132E4
[000132de] 3307                      move.w     d7,-(a1)
[000132e0] 51cc fffc                 dbf        d4,$000132DE
[000132e4] 4ed5                      jmp        (a5)
[000132e6] 8561                      or.w       d2,-(a1)
[000132e8] 92cb                      suba.w     a3,a1
[000132ea] 51cd ffec                 dbf        d5,$000132D8
[000132ee] 4e75                      rts
[000132f0] 4fef 0098                 lea.l      152(a7),a7
[000132f4] 4e75                      rts
[000132f6] 41fa 0120                 lea.l      $00013418(pc),a0
[000132fa] 43fa 0142                 lea.l      $0001343E(pc),a1
[000132fe] 45fa 0152                 lea.l      $00013452(pc),a2
[00013302] 47fa 02ea                 lea.l      $000135EE(pc),a3
[00013306] 2f09                      move.l     a1,-(a7)
[00013308] 4fef ff6c                 lea.l      -148(a7),a7
[0001330c] 2248                      movea.l    a0,a1
[0001330e] 41ef 009c                 lea.l      156(a7),a0
[00013312] 4e91                      jsr        (a1)
[00013314] 2e88                      move.l     a0,(a7)
[00013316] 2f48 0048                 move.l     a0,72(a7)
[0001331a] 67d4                      beq.s      $000132F0
[0001331c] 224a                      movea.l    a2,a1
[0001331e] 41ef 009c                 lea.l      156(a7),a0
[00013322] 45ef 0054                 lea.l      84(a7),a2
[00013326] 4e91                      jsr        (a1)
[00013328] 2848                      movea.l    a0,a4
[0001332a] 2f49 004c                 move.l     a1,76(a7)
[0001332e] 2f4a 0050                 move.l     a2,80(a7)
[00013332] 41ef 009c                 lea.l      156(a7),a0
[00013336] 45ef 0008                 lea.l      8(a7),a2
[0001333a] 4e93                      jsr        (a3)
[0001333c] 2a48                      movea.l    a0,a5
[0001333e] 2f49 0004                 move.l     a1,4(a7)
[00013342] 926f 009e                 sub.w      158(a7),d1
[00013346] 966f 00a2                 sub.w      162(a7),d3
[0001334a] 3807                      move.w     d7,d4
[0001334c] 3c2f 00aa                 move.w     170(a7),d6
[00013350] 3e2f 00a6                 move.w     166(a7),d7
[00013354] bc7c 7fff                 cmp.w      #$7FFF,d6
[00013358] 6406                      bcc.s      $00013360
[0001335a] be7c 7fff                 cmp.w      #$7FFF,d7
[0001335e] 6504                      bcs.s      $00013364
[00013360] e24e                      lsr.w      #1,d6
[00013362] e24f                      lsr.w      #1,d7
[00013364] 5246                      addq.w     #1,d6
[00013366] 5247                      addq.w     #1,d7
[00013368] bc47                      cmp.w      d7,d6
[0001336a] 6f52                      ble.s      $000133BE
[0001336c] 3a06                      move.w     d6,d5
[0001336e] 4445                      neg.w      d5
[00013370] 48c5                      ext.l      d5
[00013372] 4a41                      tst.w      d1
[00013374] 6704                      beq.s      $0001337A
[00013376] c2c6                      mulu.w     d6,d1
[00013378] 9a81                      sub.l      d1,d5
[0001337a] 4a43                      tst.w      d3
[0001337c] 6704                      beq.s      $00013382
[0001337e] c6c7                      mulu.w     d7,d3
[00013380] da83                      add.l      d3,d5
[00013382] 45ef 0054                 lea.l      84(a7),a2
[00013386] 204c                      movea.l    a4,a0
[00013388] 226f 0048                 movea.l    72(a7),a1
[0001338c] 266f 004c                 movea.l    76(a7),a3
[00013390] 4e93                      jsr        (a3)
[00013392] 244f                      movea.l    a7,a2
[00013394] 205a                      movea.l    (a2)+,a0
[00013396] 224d                      movea.l    a5,a1
[00013398] 265a                      movea.l    (a2)+,a3
[0001339a] 4e93                      jsr        (a3)
[0001339c] daee 01da                 adda.w     474(a6),a5
[000133a0] da47                      add.w      d7,d5
[000133a2] 6a06                      bpl.s      $000133AA
[000133a4] 51cc ffec                 dbf        d4,$00013392
[000133a8] 600a                      bra.s      $000133B4
[000133aa] 9a46                      sub.w      d6,d5
[000133ac] d8ee 01c6                 adda.w     454(a6),a4
[000133b0] 51cc ffd0                 dbf        d4,$00013382
[000133b4] 2057                      movea.l    (a7),a0
[000133b6] 4fef 0094                 lea.l      148(a7),a7
[000133ba] 225f                      movea.l    (a7)+,a1
[000133bc] 4ed1                      jmp        (a1)
[000133be] 3805                      move.w     d5,d4
[000133c0] 3a07                      move.w     d7,d5
[000133c2] 4445                      neg.w      d5
[000133c4] 48c5                      ext.l      d5
[000133c6] 4a41                      tst.w      d1
[000133c8] 6704                      beq.s      $000133CE
[000133ca] c2c6                      mulu.w     d6,d1
[000133cc] da81                      add.l      d1,d5
[000133ce] 4a43                      tst.w      d3
[000133d0] 6704                      beq.s      $000133D6
[000133d2] c6c7                      mulu.w     d7,d3
[000133d4] 9a83                      sub.l      d3,d5
[000133d6] 266f 004c                 movea.l    76(a7),a3
[000133da] 6004                      bra.s      $000133E0
[000133dc] 266f 0050                 movea.l    80(a7),a3
[000133e0] 45ef 0054                 lea.l      84(a7),a2
[000133e4] 204c                      movea.l    a4,a0
[000133e6] 226f 0048                 movea.l    72(a7),a1
[000133ea] 4e93                      jsr        (a3)
[000133ec] d8ee 01c6                 adda.w     454(a6),a4
[000133f0] da46                      add.w      d6,d5
[000133f2] 6a06                      bpl.s      $000133FA
[000133f4] 51cc ffe6                 dbf        d4,$000133DC
[000133f8] 7800                      moveq.l    #0,d4
[000133fa] 244f                      movea.l    a7,a2
[000133fc] 205a                      movea.l    (a2)+,a0
[000133fe] 224d                      movea.l    a5,a1
[00013400] 265a                      movea.l    (a2)+,a3
[00013402] 4e93                      jsr        (a3)
[00013404] 9a47                      sub.w      d7,d5
[00013406] daee 01da                 adda.w     474(a6),a5
[0001340a] 51cc ffca                 dbf        d4,$000133D6
[0001340e] 2057                      movea.l    (a7),a0
[00013410] 4fef 0094                 lea.l      148(a7),a7
[00013414] 225f                      movea.l    (a7)+,a1
[00013416] 4ed1                      jmp        (a1)
[00013418] 2f00                      move.l     d0,-(a7)
[0001341a] 700f                      moveq.l    #15,d0
[0001341c] c042                      and.w      d2,d0
[0001341e] d046                      add.w      d6,d0
[00013420] d080                      add.l      d0,d0
[00013422] d080                      add.l      d0,d0
[00013424] 4a6e 01c8                 tst.w      456(a6)
[00013428] 6606                      bne.s      $00013430
[0001342a] ec88                      lsr.l      #6,d0
[0001342c] 5280                      addq.l     #1,d0
[0001342e] d080                      add.l      d0,d0
[00013430] 207a 04f0                 movea.l    $00013922(pc),a0
[00013434] 2068 008c                 movea.l    140(a0),a0
[00013438] 4e90                      jsr        (a0)
[0001343a] 201f                      move.l     (a7)+,d0
[0001343c] 4e75                      rts
[0001343e] 48e7 80c0                 movem.l    d0/a0-a1,-(a7)
[00013442] 227a 04de                 movea.l    $00013922(pc),a1
[00013446] 2269 0090                 movea.l    144(a1),a1
[0001344a] 4e91                      jsr        (a1)
[0001344c] 4cdf 0301                 movem.l    (a7)+,d0/a0-a1
[00013450] 4e75                      rts
[00013452] 48e7 ff00                 movem.l    d0-d7,-(a7)
[00013456] 226e 01c2                 movea.l    450(a6),a1
[0001345a] c3ee 01c6                 muls.w     454(a6),d1
[0001345e] d3c1                      adda.l     d1,a1
[00013460] 48c0                      ext.l      d0
[00013462] 2200                      move.l     d0,d1
[00013464] 4a6e 01c8                 tst.w      456(a6)
[00013468] 6706                      beq.s      $00013470
[0001346a] d281                      add.l      d1,d1
[0001346c] d280                      add.l      d0,d1
[0001346e] 6004                      bra.s      $00013474
[00013470] e481                      asr.l      #2,d1
[00013472] d281                      add.l      d1,d1
[00013474] d3c1                      adda.l     d1,a1
[00013476] 3e02                      move.w     d2,d7
[00013478] 3404                      move.w     d4,d2
[0001347a] 3606                      move.w     d6,d3
[0001347c] 3c00                      move.w     d0,d6
[0001347e] 780f                      moveq.l    #15,d4
[00013480] c846                      and.w      d6,d4
[00013482] 9c50                      sub.w      (a0),d6
[00013484] 9e68 0004                 sub.w      4(a0),d7
[00013488] 3028 0008                 move.w     8(a0),d0
[0001348c] 3228 000c                 move.w     12(a0),d1
[00013490] b07c 7fff                 cmp.w      #$7FFF,d0
[00013494] 6406                      bcc.s      $0001349C
[00013496] b27c 7fff                 cmp.w      #$7FFF,d1
[0001349a] 6504                      bcs.s      $000134A0
[0001349c] e248                      lsr.w      #1,d0
[0001349e] e249                      lsr.w      #1,d1
[000134a0] 5240                      addq.w     #1,d0
[000134a2] 5241                      addq.w     #1,d1
[000134a4] b240                      cmp.w      d0,d1
[000134a6] 6f18                      ble.s      $000134C0
[000134a8] 3401                      move.w     d1,d2
[000134aa] 4442                      neg.w      d2
[000134ac] 48c2                      ext.l      d2
[000134ae] 4a46                      tst.w      d6
[000134b0] 6704                      beq.s      $000134B6
[000134b2] ccc1                      mulu.w     d1,d6
[000134b4] 9486                      sub.l      d6,d2
[000134b6] 4a47                      tst.w      d7
[000134b8] 671c                      beq.s      $000134D6
[000134ba] cec0                      mulu.w     d0,d7
[000134bc] d487                      add.l      d7,d2
[000134be] 6016                      bra.s      $000134D6
[000134c0] 3600                      move.w     d0,d3
[000134c2] 4443                      neg.w      d3
[000134c4] 48c3                      ext.l      d3
[000134c6] 4a46                      tst.w      d6
[000134c8] 6704                      beq.s      $000134CE
[000134ca] ccc1                      mulu.w     d1,d6
[000134cc] d686                      add.l      d6,d3
[000134ce] 4a47                      tst.w      d7
[000134d0] 6704                      beq.s      $000134D6
[000134d2] cec0                      mulu.w     d0,d7
[000134d4] 9687                      sub.l      d7,d3
[000134d6] 3c01                      move.w     d1,d6
[000134d8] 3e00                      move.w     d0,d7
[000134da] 4892 00dc                 movem.w    d2-d4/d6-d7,(a2)
[000134de] 2049                      movea.l    a1,a0
[000134e0] 4a6e 01c8                 tst.w      456(a6)
[000134e4] 660e                      bne.s      $000134F4
[000134e6] 43fa 001a                 lea.l      $00013502(pc),a1
[000134ea] 45fa 0016                 lea.l      $00013502(pc),a2
[000134ee] 4cdf 00ff                 movem.l    (a7)+,d0-d7
[000134f2] 4e75                      rts
[000134f4] 43fa 0098                 lea.l      $0001358E(pc),a1
[000134f8] 45fa 0094                 lea.l      $0001358E(pc),a2
[000134fc] 4cdf 00ff                 movem.l    (a7)+,d0-d7
[00013500] 4e75                      rts
[00013502] 48a7 0b00                 movem.w    d4/d6-d7,-(a7)
[00013506] 4c92 0c1c                 movem.w    (a2),d2-d4/a2-a3
[0001350a] b4cb                      cmpa.w     a3,a2
[0001350c] 6f44                      ble.s      $00013552
[0001350e] 3c3c 8000                 move.w     #$8000,d6
[00013512] 7e00                      moveq.l    #0,d7
[00013514] 6014                      bra.s      $0001352A
[00013516] 944a                      sub.w      a2,d2
[00013518] e25e                      ror.w      #1,d6
[0001351a] 55cb 000a                 dbcs       d3,$00013526
[0001351e] 32c7                      move.w     d7,(a1)+
[00013520] 7e00                      moveq.l    #0,d7
[00013522] 5343                      subq.w     #1,d3
[00013524] 6b26                      bmi.s      $0001354C
[00013526] 51c8 000c                 dbf        d0,$00013534
[0001352a] 700f                      moveq.l    #15,d0
[0001352c] 2210                      move.l     (a0),d1
[0001352e] 5488                      addq.l     #2,a0
[00013530] e9a9                      lsl.l      d4,d1
[00013532] 4841                      swap       d1
[00013534] 0101                      btst       d0,d1
[00013536] 6702                      beq.s      $0001353A
[00013538] 8e46                      or.w       d6,d7
[0001353a] d44b                      add.w      a3,d2
[0001353c] 6ad8                      bpl.s      $00013516
[0001353e] e25e                      ror.w      #1,d6
[00013540] 55cb fff2                 dbcs       d3,$00013534
[00013544] 32c7                      move.w     d7,(a1)+
[00013546] 7e00                      moveq.l    #0,d7
[00013548] 5343                      subq.w     #1,d3
[0001354a] 6ae8                      bpl.s      $00013534
[0001354c] 4c9f 00d0                 movem.w    (a7)+,d4/d6-d7
[00013550] 4e75                      rts
[00013552] 3c3c 8000                 move.w     #$8000,d6
[00013556] 7e00                      moveq.l    #0,d7
[00013558] 6014                      bra.s      $0001356E
[0001355a] 964b                      sub.w      a3,d3
[0001355c] e25e                      ror.w      #1,d6
[0001355e] 55ca 000a                 dbcs       d2,$0001356A
[00013562] 32c7                      move.w     d7,(a1)+
[00013564] 7e00                      moveq.l    #0,d7
[00013566] 5342                      subq.w     #1,d2
[00013568] 6b1e                      bmi.s      $00013588
[0001356a] 51c8 000c                 dbf        d0,$00013578
[0001356e] 700f                      moveq.l    #15,d0
[00013570] 2210                      move.l     (a0),d1
[00013572] 5488                      addq.l     #2,a0
[00013574] e9a9                      lsl.l      d4,d1
[00013576] 4841                      swap       d1
[00013578] 0101                      btst       d0,d1
[0001357a] 6702                      beq.s      $0001357E
[0001357c] 8e46                      or.w       d6,d7
[0001357e] d64a                      add.w      a2,d3
[00013580] 6ad8                      bpl.s      $0001355A
[00013582] 51ca ffe6                 dbf        d2,$0001356A
[00013586] 32c7                      move.w     d7,(a1)+
[00013588] 4c9f 00d0                 movem.w    (a7)+,d4/d6-d7
[0001358c] 4e75                      rts
[0001358e] 48a7 0c00                 movem.w    d4-d5,-(a7)
[00013592] 4c92 000c                 movem.w    (a2),d2-d3
[00013596] 4caa 0c00 0006            movem.w    6(a2),a2-a3
[0001359c] b4cb                      cmpa.w     a3,a2
[0001359e] 6f26                      ble.s      $000135C6
[000135a0] 1218                      move.b     (a0)+,d1
[000135a2] 1818                      move.b     (a0)+,d4
[000135a4] 1a18                      move.b     (a0)+,d5
[000135a6] 12c1                      move.b     d1,(a1)+
[000135a8] 12c4                      move.b     d4,(a1)+
[000135aa] 12c5                      move.b     d5,(a1)+
[000135ac] d44b                      add.w      a3,d2
[000135ae] 6a0a                      bpl.s      $000135BA
[000135b0] 51cb fff4                 dbf        d3,$000135A6
[000135b4] 4c9f 0030                 movem.w    (a7)+,d4-d5
[000135b8] 4e75                      rts
[000135ba] 944a                      sub.w      a2,d2
[000135bc] 51cb ffe2                 dbf        d3,$000135A0
[000135c0] 4c9f 0030                 movem.w    (a7)+,d4-d5
[000135c4] 4e75                      rts
[000135c6] 1218                      move.b     (a0)+,d1
[000135c8] 1818                      move.b     (a0)+,d4
[000135ca] 1a18                      move.b     (a0)+,d5
[000135cc] d64a                      add.w      a2,d3
[000135ce] 6a0c                      bpl.s      $000135DC
[000135d0] 51ca fff4                 dbf        d2,$000135C6
[000135d4] 22c1                      move.l     d1,(a1)+
[000135d6] 4c9f 0030                 movem.w    (a7)+,d4-d5
[000135da] 4e75                      rts
[000135dc] 12c1                      move.b     d1,(a1)+
[000135de] 12c4                      move.b     d4,(a1)+
[000135e0] 12c5                      move.b     d5,(a1)+
[000135e2] 964b                      sub.w      a3,d3
[000135e4] 51ca ffe0                 dbf        d2,$000135C6
[000135e8] 4c9f 0030                 movem.w    (a7)+,d4-d5
[000135ec] 4e75                      rts
[000135ee] 48e7 f000                 movem.l    d0-d3,-(a7)
[000135f2] 206e 01d6                 movea.l    470(a6),a0
[000135f6] c7ee 01da                 muls.w     474(a6),d3
[000135fa] d1c3                      adda.l     d3,a0
[000135fc] 48c2                      ext.l      d2
[000135fe] d1c2                      adda.l     d2,a0
[00013600] d482                      add.l      d2,d2
[00013602] d1c2                      adda.l     d2,a0
[00013604] 4a6e 01c8                 tst.w      456(a6)
[00013608] 6632                      bne.s      $0001363C
[0001360a] 700f                      moveq.l    #15,d0
[0001360c] c046                      and.w      d6,d0
[0001360e] 4840                      swap       d0
[00013610] 3006                      move.w     d6,d0
[00013612] e848                      lsr.w      #4,d0
[00013614] 24c0                      move.l     d0,(a2)+
[00013616] 24ee 00f2                 move.l     242(a6),(a2)+
[0001361a] 24ee 00f6                 move.l     246(a6),(a2)+
[0001361e] 7003                      moveq.l    #3,d0
[00013620] c06e 01ee                 and.w      494(a6),d0
[00013624] d040                      add.w      d0,d0
[00013626] 303b 000c                 move.w     $00013634(pc,d0.w),d0
[0001362a] 43fb 0008                 lea.l      $00013634(pc,d0.w),a1
[0001362e] 4cdf 000f                 movem.l    (a7)+,d0-d3
[00013632] 4e75                      rts
[00013634] 0040 00ae                 ori.w      #$00AE,d0
[00013638] 0106                      btst       d0,d6
[0001363a] 0136 34c6                 btst       d0,-58(a6,d3.w*4) ; 68020+ only
[0001363e] 700f                      moveq.l    #15,d0
[00013640] c06e 01ee                 and.w      494(a6),d0
[00013644] d040                      add.w      d0,d0
[00013646] 303b 000c                 move.w     $00013654(pc,d0.w),d0
[0001364a] 43fb 0008                 lea.l      $00013654(pc,d0.w),a1
[0001364e] 4cdf 000f                 movem.l    (a7)+,d0-d3
[00013652] 4e75                      rts
[00013654] 016e 017e                 bchg       d0,382(a6)
[00013658] 0192                      bclr       d0,(a2)
[0001365a] 01ac 01ba                 bclr       d0,442(a4)
[0001365e] 01d4                      bset       d0,(a4)
[00013660] 01d6                      bset       d0,(a6)
[00013662] 01ea 01fe                 bset       d0,510(a2)
[00013666] 0218 0232                 andi.b     #$32,(a0)+
[0001366a] 0240 025a                 andi.w     #$025A,d0
[0001366e] 0274 028e 02a8            andi.w     #$028E,-88(a4,d0.w*2) ; 68020+ only
[00013674] 48e7 0f00                 movem.l    d4-d7,-(a7)
[00013678] 201a                      move.l     (a2)+,d0
[0001367a] 528a                      addq.l     #1,a2
[0001367c] 141a                      move.b     (a2)+,d2
[0001367e] 161a                      move.b     (a2)+,d3
[00013680] 181a                      move.b     (a2)+,d4
[00013682] 528a                      addq.l     #1,a2
[00013684] 1a1a                      move.b     (a2)+,d5
[00013686] 1c1a                      move.b     (a2)+,d6
[00013688] 1e1a                      move.b     (a2)+,d7
[0001368a] 5340                      subq.w     #1,d0
[0001368c] 6b2c                      bmi.s      $000136BA
[0001368e] 3218                      move.w     (a0)+,d1
[00013690] 2640                      movea.l    d0,a3
[00013692] 700f                      moveq.l    #15,d0
[00013694] d241                      add.w      d1,d1
[00013696] 6412                      bcc.s      $000136AA
[00013698] 12c2                      move.b     d2,(a1)+
[0001369a] 12c3                      move.b     d3,(a1)+
[0001369c] 12c4                      move.b     d4,(a1)+
[0001369e] 51c8 fff4                 dbf        d0,$00013694
[000136a2] 200b                      move.l     a3,d0
[000136a4] 51c8 ffe8                 dbf        d0,$0001368E
[000136a8] 6010                      bra.s      $000136BA
[000136aa] 12c5                      move.b     d5,(a1)+
[000136ac] 12c6                      move.b     d6,(a1)+
[000136ae] 12c7                      move.b     d7,(a1)+
[000136b0] 51c8 ffe2                 dbf        d0,$00013694
[000136b4] 200b                      move.l     a3,d0
[000136b6] 51c8 ffd6                 dbf        d0,$0001368E
[000136ba] 4840                      swap       d0
[000136bc] 3218                      move.w     (a0)+,d1
[000136be] d241                      add.w      d1,d1
[000136c0] 6410                      bcc.s      $000136D2
[000136c2] 12c2                      move.b     d2,(a1)+
[000136c4] 12c3                      move.b     d3,(a1)+
[000136c6] 12c4                      move.b     d4,(a1)+
[000136c8] 51c8 fff4                 dbf        d0,$000136BE
[000136cc] 4cdf 00f0                 movem.l    (a7)+,d4-d7
[000136d0] 4e75                      rts
[000136d2] 12c5                      move.b     d5,(a1)+
[000136d4] 12c6                      move.b     d6,(a1)+
[000136d6] 12c7                      move.b     d7,(a1)+
[000136d8] 51c8 ffe4                 dbf        d0,$000136BE
[000136dc] 4cdf 00f0                 movem.l    (a7)+,d4-d7
[000136e0] 4e75                      rts
[000136e2] 2644                      movea.l    d4,a3
[000136e4] 201a                      move.l     (a2)+,d0
[000136e6] 528a                      addq.l     #1,a2
[000136e8] 141a                      move.b     (a2)+,d2
[000136ea] 161a                      move.b     (a2)+,d3
[000136ec] 181a                      move.b     (a2)+,d4
[000136ee] 5340                      subq.w     #1,d0
[000136f0] 6b28                      bmi.s      $0001371A
[000136f2] 3218                      move.w     (a0)+,d1
[000136f4] 2440                      movea.l    d0,a2
[000136f6] 700f                      moveq.l    #15,d0
[000136f8] d241                      add.w      d1,d1
[000136fa] 6412                      bcc.s      $0001370E
[000136fc] 12c2                      move.b     d2,(a1)+
[000136fe] 12c3                      move.b     d3,(a1)+
[00013700] 12c4                      move.b     d4,(a1)+
[00013702] 51c8 fff4                 dbf        d0,$000136F8
[00013706] 200a                      move.l     a2,d0
[00013708] 51c8 ffe8                 dbf        d0,$000136F2
[0001370c] 600c                      bra.s      $0001371A
[0001370e] 5689                      addq.l     #3,a1
[00013710] 51c8 ffe6                 dbf        d0,$000136F8
[00013714] 200a                      move.l     a2,d0
[00013716] 51c8 ffda                 dbf        d0,$000136F2
[0001371a] 4840                      swap       d0
[0001371c] 3218                      move.w     (a0)+,d1
[0001371e] d241                      add.w      d1,d1
[00013720] 640e                      bcc.s      $00013730
[00013722] 12c2                      move.b     d2,(a1)+
[00013724] 12c3                      move.b     d3,(a1)+
[00013726] 12c4                      move.b     d4,(a1)+
[00013728] 51c8 fff4                 dbf        d0,$0001371E
[0001372c] 280b                      move.l     a3,d4
[0001372e] 4e75                      rts
[00013730] 5689                      addq.l     #3,a1
[00013732] 51c8 ffea                 dbf        d0,$0001371E
[00013736] 280b                      move.l     a3,d4
[00013738] 4e75                      rts
[0001373a] 201a                      move.l     (a2)+,d0
[0001373c] 5340                      subq.w     #1,d0
[0001373e] 6b16                      bmi.s      $00013756
[00013740] 3218                      move.w     (a0)+,d1
[00013742] 760f                      moveq.l    #15,d3
[00013744] d241                      add.w      d1,d1
[00013746] 55c2                      scs        d2
[00013748] b519                      eor.b      d2,(a1)+
[0001374a] b519                      eor.b      d2,(a1)+
[0001374c] b519                      eor.b      d2,(a1)+
[0001374e] 51cb fff4                 dbf        d3,$00013744
[00013752] 51c8 ffec                 dbf        d0,$00013740
[00013756] 4840                      swap       d0
[00013758] 3218                      move.w     (a0)+,d1
[0001375a] d241                      add.w      d1,d1
[0001375c] 55c2                      scs        d2
[0001375e] b519                      eor.b      d2,(a1)+
[00013760] b519                      eor.b      d2,(a1)+
[00013762] b519                      eor.b      d2,(a1)+
[00013764] 51c8 fff4                 dbf        d0,$0001375A
[00013768] 4e75                      rts
[0001376a] 2644                      movea.l    d4,a3
[0001376c] 201a                      move.l     (a2)+,d0
[0001376e] 5a8a                      addq.l     #5,a2
[00013770] 141a                      move.b     (a2)+,d2
[00013772] 161a                      move.b     (a2)+,d3
[00013774] 181a                      move.b     (a2)+,d4
[00013776] 5340                      subq.w     #1,d0
[00013778] 6b28                      bmi.s      $000137A2
[0001377a] 3218                      move.w     (a0)+,d1
[0001377c] 2440                      movea.l    d0,a2
[0001377e] 700f                      moveq.l    #15,d0
[00013780] d241                      add.w      d1,d1
[00013782] 6512                      bcs.s      $00013796
[00013784] 12c2                      move.b     d2,(a1)+
[00013786] 12c3                      move.b     d3,(a1)+
[00013788] 12c4                      move.b     d4,(a1)+
[0001378a] 51c8 fff4                 dbf        d0,$00013780
[0001378e] 200a                      move.l     a2,d0
[00013790] 51c8 ffe8                 dbf        d0,$0001377A
[00013794] 600c                      bra.s      $000137A2
[00013796] 5689                      addq.l     #3,a1
[00013798] 51c8 ffe6                 dbf        d0,$00013780
[0001379c] 200a                      move.l     a2,d0
[0001379e] 51c8 ffda                 dbf        d0,$0001377A
[000137a2] 4840                      swap       d0
[000137a4] 3218                      move.w     (a0)+,d1
[000137a6] d241                      add.w      d1,d1
[000137a8] 650e                      bcs.s      $000137B8
[000137aa] 12c2                      move.b     d2,(a1)+
[000137ac] 12c3                      move.b     d3,(a1)+
[000137ae] 12c4                      move.b     d4,(a1)+
[000137b0] 51c8 fff4                 dbf        d0,$000137A6
[000137b4] 280b                      move.l     a3,d4
[000137b6] 4e75                      rts
[000137b8] 5689                      addq.l     #3,a1
[000137ba] 51c8 ffea                 dbf        d0,$000137A6
[000137be] 280b                      move.l     a3,d4
[000137c0] 4e75                      rts
[000137c2] 3012                      move.w     (a2),d0
[000137c4] 7200                      moveq.l    #0,d1
[000137c6] 12c1                      move.b     d1,(a1)+
[000137c8] 12c1                      move.b     d1,(a1)+
[000137ca] 12c1                      move.b     d1,(a1)+
[000137cc] 51c8 fff8                 dbf        d0,$000137C6
[000137d0] 4e75                      rts
[000137d2] 3012                      move.w     (a2),d0
[000137d4] 1218                      move.b     (a0)+,d1
[000137d6] c319                      and.b      d1,(a1)+
[000137d8] 1218                      move.b     (a0)+,d1
[000137da] c319                      and.b      d1,(a1)+
[000137dc] 1218                      move.b     (a0)+,d1
[000137de] c319                      and.b      d1,(a1)+
[000137e0] 51c8 fff2                 dbf        d0,$000137D4
[000137e4] 4e75                      rts
[000137e6] 3012                      move.w     (a2),d0
[000137e8] 1218                      move.b     (a0)+,d1
[000137ea] 4611                      not.b      (a1)
[000137ec] c319                      and.b      d1,(a1)+
[000137ee] 1218                      move.b     (a0)+,d1
[000137f0] 4611                      not.b      (a1)
[000137f2] c319                      and.b      d1,(a1)+
[000137f4] 1218                      move.b     (a0)+,d1
[000137f6] 4611                      not.b      (a1)
[000137f8] c319                      and.b      d1,(a1)+
[000137fa] 51c8 ffec                 dbf        d0,$000137E8
[000137fe] 4e75                      rts
[00013800] 301a                      move.w     (a2)+,d0
[00013802] 12d8                      move.b     (a0)+,(a1)+
[00013804] 12d8                      move.b     (a0)+,(a1)+
[00013806] 12d8                      move.b     (a0)+,(a1)+
[00013808] 51c8 fff8                 dbf        d0,$00013802
[0001380c] 4e75                      rts
[0001380e] 3012                      move.w     (a2),d0
[00013810] 1218                      move.b     (a0)+,d1
[00013812] 4601                      not.b      d1
[00013814] c319                      and.b      d1,(a1)+
[00013816] 1218                      move.b     (a0)+,d1
[00013818] 4601                      not.b      d1
[0001381a] c319                      and.b      d1,(a1)+
[0001381c] 1218                      move.b     (a0)+,d1
[0001381e] 4601                      not.b      d1
[00013820] c319                      and.b      d1,(a1)+
[00013822] 51c8 ffec                 dbf        d0,$00013810
[00013826] 4e75                      rts
[00013828] 4e75                      rts
[0001382a] 3012                      move.w     (a2),d0
[0001382c] 1218                      move.b     (a0)+,d1
[0001382e] b319                      eor.b      d1,(a1)+
[00013830] 1218                      move.b     (a0)+,d1
[00013832] b319                      eor.b      d1,(a1)+
[00013834] 1218                      move.b     (a0)+,d1
[00013836] b319                      eor.b      d1,(a1)+
[00013838] 51c8 fff2                 dbf        d0,$0001382C
[0001383c] 4e75                      rts
[0001383e] 3012                      move.w     (a2),d0
[00013840] 1218                      move.b     (a0)+,d1
[00013842] 8319                      or.b       d1,(a1)+
[00013844] 1218                      move.b     (a0)+,d1
[00013846] 8319                      or.b       d1,(a1)+
[00013848] 1218                      move.b     (a0)+,d1
[0001384a] 8319                      or.b       d1,(a1)+
[0001384c] 51c8 fff2                 dbf        d0,$00013840
[00013850] 4e75                      rts
[00013852] 3012                      move.w     (a2),d0
[00013854] 1218                      move.b     (a0)+,d1
[00013856] 8311                      or.b       d1,(a1)
[00013858] 4619                      not.b      (a1)+
[0001385a] 1218                      move.b     (a0)+,d1
[0001385c] 8311                      or.b       d1,(a1)
[0001385e] 4619                      not.b      (a1)+
[00013860] 1218                      move.b     (a0)+,d1
[00013862] 8311                      or.b       d1,(a1)
[00013864] 4619                      not.b      (a1)+
[00013866] 51c8 ffec                 dbf        d0,$00013854
[0001386a] 4e75                      rts
[0001386c] 3012                      move.w     (a2),d0
[0001386e] 1218                      move.b     (a0)+,d1
[00013870] b311                      eor.b      d1,(a1)
[00013872] 4619                      not.b      (a1)+
[00013874] 1218                      move.b     (a0)+,d1
[00013876] b311                      eor.b      d1,(a1)
[00013878] 4619                      not.b      (a1)+
[0001387a] 1218                      move.b     (a0)+,d1
[0001387c] b311                      eor.b      d1,(a1)
[0001387e] 4619                      not.b      (a1)+
[00013880] 51c8 ffec                 dbf        d0,$0001386E
[00013884] 4e75                      rts
[00013886] 3012                      move.w     (a2),d0
[00013888] 4619                      not.b      (a1)+
[0001388a] 4619                      not.b      (a1)+
[0001388c] 4619                      not.b      (a1)+
[0001388e] 51c8 fff8                 dbf        d0,$00013888
[00013892] 4e75                      rts
[00013894] 3012                      move.w     (a2),d0
[00013896] 1218                      move.b     (a0)+,d1
[00013898] 4611                      not.b      (a1)
[0001389a] 8319                      or.b       d1,(a1)+
[0001389c] 1218                      move.b     (a0)+,d1
[0001389e] 4611                      not.b      (a1)
[000138a0] 8319                      or.b       d1,(a1)+
[000138a2] 1218                      move.b     (a0)+,d1
[000138a4] 4611                      not.b      (a1)
[000138a6] 8319                      or.b       d1,(a1)+
[000138a8] 51c8 ffec                 dbf        d0,$00013896
[000138ac] 4e75                      rts
[000138ae] 3012                      move.w     (a2),d0
[000138b0] 1218                      move.b     (a0)+,d1
[000138b2] 4601                      not.b      d1
[000138b4] 12c1                      move.b     d1,(a1)+
[000138b6] 1218                      move.b     (a0)+,d1
[000138b8] 4601                      not.b      d1
[000138ba] 12c1                      move.b     d1,(a1)+
[000138bc] 1218                      move.b     (a0)+,d1
[000138be] 4601                      not.b      d1
[000138c0] 12c1                      move.b     d1,(a1)+
[000138c2] 51c8 ffec                 dbf        d0,$000138B0
[000138c6] 4e75                      rts
[000138c8] 3012                      move.w     (a2),d0
[000138ca] 1218                      move.b     (a0)+,d1
[000138cc] 4601                      not.b      d1
[000138ce] 8319                      or.b       d1,(a1)+
[000138d0] 1218                      move.b     (a0)+,d1
[000138d2] 4601                      not.b      d1
[000138d4] 8319                      or.b       d1,(a1)+
[000138d6] 1218                      move.b     (a0)+,d1
[000138d8] 4601                      not.b      d1
[000138da] 8319                      or.b       d1,(a1)+
[000138dc] 51c8 ffec                 dbf        d0,$000138CA
[000138e0] 4e75                      rts
[000138e2] 3012                      move.w     (a2),d0
[000138e4] 1218                      move.b     (a0)+,d1
[000138e6] c311                      and.b      d1,(a1)
[000138e8] 4619                      not.b      (a1)+
[000138ea] 1218                      move.b     (a0)+,d1
[000138ec] c311                      and.b      d1,(a1)
[000138ee] 4619                      not.b      (a1)+
[000138f0] 1218                      move.b     (a0)+,d1
[000138f2] c311                      and.b      d1,(a1)
[000138f4] 4619                      not.b      (a1)+
[000138f6] 51c8 ffec                 dbf        d0,$000138E4
[000138fa] 4e75                      rts
[000138fc] 3012                      move.w     (a2),d0
[000138fe] 72ff                      moveq.l    #-1,d1
[00013900] 12c1                      move.b     d1,(a1)+
[00013902] 12c1                      move.b     d1,(a1)+
[00013904] 12c1                      move.b     d1,(a1)+
[00013906] 51c8 fff8                 dbf        d0,$00013900
[0001390a] 4e75                      rts
[0001390c] 4e75                      rts

	.data
[0001390e]                           dc.w $03b0
[00013910]                           dc.w $04b2
[00013912]                           dc.b $00
[00013913]                           dc.b $30
[00013914]                           dc.b $00
[00013915]                           dc.b $20
[00013916]                           dc.b $00
[00013917]                           dc.b $42
[00013918]                           dc.b $00
[00013919]                           dc.b $8e
[0001391a]                           dc.w $01b2
[0001391c]                           dc.w $022a
[0001391e]                           dc.w $0420
[00013920]                           dc.b $00
[00013921]                           dc.b $00
