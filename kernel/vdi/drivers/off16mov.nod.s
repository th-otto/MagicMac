; ph_branch = 0x601a
; ph_tlen = 0x00002332
; ph_dlen = 0x00000014
; ph_blen = 0x00002006
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000025

[00010000] 604e                      bra.s      $00010050
[00010002] 4f46                      lea.l      d6,b7 ; apollo only
[00010004] 4653                      not.w      (a3)
[00010006] 4352                      lea.l      (a2),b1 ; apollo only
[00010008] 4e00 0500                 cmpiw.l    #$0500,d0 ; apollo only
[0001000c] 0050 0000                 ori.w      #$0000,(a0)
[00010010] 0001 0052                 ori.b      #$52,d1
[00010014] 0001 0086                 ori.b      #$86,d1
[00010018] 0001 0414                 ori.b      #$14,d1
[0001001c] 0001 04a2                 ori.b      #$A2,d1
[00010020] 0001 0088                 ori.b      #$88,d1
[00010024] 0001 00c8                 ori.b      #$C8,d1
[00010028] 0001 0116                 ori.b      #$16,d1
[0001002c] 0001 0370                 ori.b      #$70,d1
[00010030] 0000                      dc.w       $0000
[00010032] 0000                      dc.w       $0000
[00010034] 0000                      dc.w       $0000
[00010036] 0000                      dc.w       $0000
[00010038] 0000                      dc.w       $0000
[0001003a] 0000                      dc.w       $0000
[0001003c] 0000                      dc.w       $0000
[0001003e] 0000 0100                 ori.b      #$00,d0
[00010042] 0000 0020                 ori.b      #$20,d0
[00010046] 0002 0081                 ori.b      #$81,d2
[0001004a] 0000                      dc.w       $0000
[0001004c] 0000                      dc.w       $0000
[0001004e] 0000 4e75                 ori.b      #$75,d0
[00010052] 48e7 e0e0                 movem.l    d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 2348            move.l     a0,$00012348
[0001005c] 6100 02ee                 bsr        $0001034C
[00010060] 207a 22e6                 movea.l    $00012348(pc),a0
[00010064] 3028 005e                 move.w     94(a0),d0
[00010068] b07c 0028                 cmp.w      #$0028,d0
[0001006c] 57c0                      seq        d0
[0001006e] 4880                      ext.w      d0
[00010070] 33c0 0001 2346            move.w     d0,$00012346
[00010076] 6100 02fa                 bsr        $00010372
[0001007a] 4cdf 0707                 movem.l    (a7)+,d0-d2/a0-a2
[0001007e] 203c 0000 0b20            move.l     #$00000B20,d0
[00010084] 4e75                      rts
[00010086] 4e75                      rts
[00010088] 48e7 80e0                 movem.l    d0/a0-a2,-(a7)
[0001008c] 20ee 0010                 move.l     16(a6),(a0)+
[00010090] 4258                      clr.w      (a0)+
[00010092] 20ee 000c                 move.l     12(a6),(a0)+
[00010096] 7027                      moveq.l    #39,d0
[00010098] 247a 22ae                 movea.l    $00012348(pc),a2
[0001009c] 246a 002c                 movea.l    44(a2),a2
[000100a0] 45ea 000a                 lea.l      10(a2),a2
[000100a4] 30da                      move.w     (a2)+,(a0)+
[000100a6] 51c8 fffc                 dbf        d0,$000100A4
[000100aa] 317c 0100 ffc0            move.w     #$0100,-64(a0)
[000100b0] 317c 0001 ffec            move.w     #$0001,-20(a0)
[000100b6] 4268 fff4                 clr.w      -12(a0)
[000100ba] 700b                      moveq.l    #11,d0
[000100bc] 32da                      move.w     (a2)+,(a1)+
[000100be] 51c8 fffc                 dbf        d0,$000100BC
[000100c2] 4cdf 0701                 movem.l    (a7)+,d0/a0-a2
[000100c6] 4e75                      rts
[000100c8] 48e7 80e0                 movem.l    d0/a0-a2,-(a7)
[000100cc] 702c                      moveq.l    #44,d0
[000100ce] 247a 2278                 movea.l    $00012348(pc),a2
[000100d2] 246a 0030                 movea.l    48(a2),a2
[000100d6] 30da                      move.w     (a2)+,(a0)+
[000100d8] 51c8 fffc                 dbf        d0,$000100D6
[000100dc] 4268 ffa6                 clr.w      -90(a0)
[000100e0] 4268 ffa8                 clr.w      -88(a0)
[000100e4] 317c 0020 ffae            move.w     #$0020,-82(a0)
[000100ea] 317c 0001 ffb0            move.w     #$0001,-80(a0)
[000100f0] 317c 0898 ffb2            move.w     #$0898,-78(a0)
[000100f6] 317c 0001 ffcc            move.w     #$0001,-52(a0)
[000100fc] 700b                      moveq.l    #11,d0
[000100fe] 32da                      move.w     (a2)+,(a1)+
[00010100] 51c8 fffc                 dbf        d0,$000100FE
[00010104] 45ee 0034                 lea.l      52(a6),a2
[00010108] 235a ffe8                 move.l     (a2)+,-24(a1)
[0001010c] 235a ffec                 move.l     (a2)+,-20(a1)
[00010110] 4cdf 0701                 movem.l    (a7)+,d0/a0-a2
[00010114] 4e75                      rts
[00010116] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[0001011a] 43fa 0050                 lea.l      $0001016C(pc),a1
[0001011e] 30d9                      move.w     (a1)+,(a0)+
[00010120] 30d9                      move.w     (a1)+,(a0)+
[00010122] 30d9                      move.w     (a1)+,(a0)+
[00010124] 20d9                      move.l     (a1)+,(a0)+
[00010126] 30ee 01b2                 move.w     434(a6),(a0)+
[0001012a] 20ee 01ae                 move.l     430(a6),(a0)+
[0001012e] 5c89                      addq.l     #6,a1
[00010130] 30d9                      move.w     (a1)+,(a0)+
[00010132] 30d9                      move.w     (a1)+,(a0)+
[00010134] 30d9                      move.w     (a1)+,(a0)+
[00010136] 30d9                      move.w     (a1)+,(a0)+
[00010138] 30d9                      move.w     (a1)+,(a0)+
[0001013a] 30d9                      move.w     (a1)+,(a0)+
[0001013c] 30ee 01a2                 move.w     418(a6),(a0)+
[00010140] 30e9 0002                 move.w     2(a1),(a0)+
[00010144] 706f                      moveq.l    #111,d0
[00010146] 43fa 0044                 lea.l      $0001018C(pc),a1
[0001014a] 082e 0007 01a3            btst       #7,419(a6)
[00010150] 6704                      beq.s      $00010156
[00010152] 43fa 0118                 lea.l      $0001026C(pc),a1
[00010156] 30d9                      move.w     (a1)+,(a0)+
[00010158] 51c8 fffc                 dbf        d0,$00010156
[0001015c] 303c 008f                 move.w     #$008F,d0
[00010160] 4258                      clr.w      (a0)+
[00010162] 51c8 fffc                 dbf        d0,$00010160
[00010166] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[0001016a] 4e75                      rts
[0001016c] 0002 0002                 ori.b      #$02,d2
[00010170] 0020 0100                 ori.b      #$00,-(a0)
[00010174] 0000                      dc.w       $0000
[00010176] 0000                      dc.w       $0000
[00010178] 0000                      dc.w       $0000
[0001017a] 0000 0008                 ori.b      #$08,d0
[0001017e] 0008 0008                 ori.b      #$08,a0 ; apollo only
[00010182] 0008 0000                 ori.b      #$00,a0 ; apollo only
[00010186] 0000 0001                 ori.b      #$01,d0
[0001018a] 0000 0010                 ori.b      #$10,d0
[0001018e] 0011 0012                 ori.b      #$12,(a1)
[00010192] 0013 0014                 ori.b      #$14,(a3)
[00010196] 0015 0016                 ori.b      #$16,(a5)
[0001019a] 0017 ffff                 ori.b      #$FF,(a7)
[0001019e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101a6] ffff ffff ffff 0008       vperm      #$FFFF0008,e23,e23,e23
[000101ae] 0009 000a                 ori.b      #$0A,a1 ; apollo only
[000101b2] 000b 000c                 ori.b      #$0C,a3 ; apollo only
[000101b6] 000d 000e                 ori.b      #$0E,a5 ; apollo only
[000101ba] 000f ffff                 ori.b      #$FF,a7 ; apollo only
[000101be] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101c6] ffff ffff ffff 0000       vperm      #$FFFF0000,e23,e23,e23
[000101ce] 0001 0002                 ori.b      #$02,d1
[000101d2] 0003 0004                 ori.b      #$04,d3
[000101d6] 0005 0006                 ori.b      #$06,d5
[000101da] 0007 ffff                 ori.b      #$FF,d7
[000101de] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000101e6] ffff ffff ffff 0018       vperm      #$FFFF0018,e23,e23,e23
[000101ee] 0019 001a                 ori.b      #$1A,(a1)+
[000101f2] 001b 001c                 ori.b      #$1C,(a3)+
[000101f6] 001d 001e                 ori.b      #$1E,(a5)+
[000101fa] 001f ffff                 ori.b      #$FF,(a7)+
[000101fe] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010206] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001020e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010216] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001021e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010226] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001022e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010236] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001023e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010246] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001024e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010256] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001025e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010266] ffff ffff ffff 0008       vperm      #$FFFF0008,e23,e23,e23
[0001026e] 0009 000a                 ori.b      #$0A,a1 ; apollo only
[00010272] 000b 000c                 ori.b      #$0C,a3 ; apollo only
[00010276] 000d 000e                 ori.b      #$0E,a5 ; apollo only
[0001027a] 000f ffff                 ori.b      #$FF,a7 ; apollo only
[0001027e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010286] ffff ffff ffff 0010       vperm      #$FFFF0010,e23,e23,e23
[0001028e] 0011 0012                 ori.b      #$12,(a1)
[00010292] 0013 0014                 ori.b      #$14,(a3)
[00010296] 0015 0016                 ori.b      #$16,(a5)
[0001029a] 0017 ffff                 ori.b      #$FF,(a7)
[0001029e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102a6] ffff ffff ffff 0018       vperm      #$FFFF0018,e23,e23,e23
[000102ae] 0019 001a                 ori.b      #$1A,(a1)+
[000102b2] 001b 001c                 ori.b      #$1C,(a3)+
[000102b6] 001d 001e                 ori.b      #$1E,(a5)+
[000102ba] 001f ffff                 ori.b      #$FF,(a7)+
[000102be] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102c6] ffff ffff ffff 0000       vperm      #$FFFF0000,e23,e23,e23
[000102ce] 0001 0002                 ori.b      #$02,d1
[000102d2] 0003 0004                 ori.b      #$04,d3
[000102d6] 0005 0006                 ori.b      #$06,d5
[000102da] 0007 ffff                 ori.b      #$FF,d7
[000102de] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102e6] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102ee] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102f6] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[000102fe] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010306] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001030e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010316] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001031e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010326] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001032e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010336] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[0001033e] ffff ffff ffff ffff       vperm      #$FFFFFFFF,e23,e23,e23
[00010346] ffff ffff ffff 48e7       vperm      #$FFFF48E7,e23,e23,e23
[0001034e] e0e0                      asr.w      -(a0)
[00010350] a000                      ALINE      #$0000
[00010352] 907c 2070                 sub.w      #$2070,d0
[00010356] 6712                      beq.s      $0001036A
[00010358] 41fa fca6                 lea.l      $00010000(pc),a0
[0001035c] 43fa 1fd4                 lea.l      $00012332(pc),a1
[00010360] 3219                      move.w     (a1)+,d1
[00010362] 6706                      beq.s      $0001036A
[00010364] d0c1                      adda.w     d1,a0
[00010366] d150                      add.w      d0,(a0)
[00010368] 60f6                      bra.s      $00010360
[0001036a] 4cdf 0707                 movem.l    (a7)+,d0-d2/a0-a2
[0001036e] 4e75                      rts
[00010370] 4e75                      rts
[00010372] 48e7 e0c0                 movem.l    d0-d2/a0-a1,-(a7)
[00010376] 41fa 1fd4                 lea.l      $0001234C(pc),a0
[0001037a] 7000                      moveq.l    #0,d0
[0001037c] 3200                      move.w     d0,d1
[0001037e] 7407                      moveq.l    #7,d2
[00010380] 4298                      clr.l      (a0)+
[00010382] d201                      add.b      d1,d1
[00010384] 6504                      bcs.s      $0001038A
[00010386] 46a8 fffc                 not.l      -4(a0)
[0001038a] 51ca fff4                 dbf        d2,$00010380
[0001038e] 5240                      addq.w     #1,d0
[00010390] b07c 0100                 cmp.w      #$0100,d0
[00010394] 6de6                      blt.s      $0001037C
[00010396] 4cdf 0307                 movem.l    (a7)+,d0-d2/a0-a1
[0001039a] 4e75                      rts
[0001039c] 3600                      move.w     d0,d3
[0001039e] 4843                      swap       d3
[000103a0] 3600                      move.w     d0,d3
[000103a2] 4a6e 01b2                 tst.w      434(a6)
[000103a6] 6712                      beq.s      $000103BA
[000103a8] 906e 01b6                 sub.w      438(a6),d0
[000103ac] 926e 01b8                 sub.w      440(a6),d1
[000103b0] 266e 01ae                 movea.l    430(a6),a3
[000103b4] c2ee 01b2                 mulu.w     434(a6),d1
[000103b8] 6008                      bra.s      $000103C2
[000103ba] 2678 044e                 movea.l    ($0000044E).w,a3
[000103be] c2f8 206e                 mulu.w     ($0000206E).w,d1
[000103c2] d7c1                      adda.l     d1,a3
[000103c4] 48c0                      ext.l      d0
[000103c6] e580                      asl.l      #2,d0
[000103c8] d7c0                      adda.l     d0,a3
[000103ca] e480                      asr.l      #2,d0
[000103cc] 284b                      movea.l    a3,a4
[000103ce] 2813                      move.l     (a3),d4
[000103d0] b642                      cmp.w      d2,d3
[000103d2] 6e0e                      bgt.s      $000103E2
[000103d4] 588b                      addq.l     #4,a3
[000103d6] b89b                      cmp.l      (a3)+,d4
[000103d8] 6608                      bne.s      $000103E2
[000103da] 5243                      addq.w     #1,d3
[000103dc] b642                      cmp.w      d2,d3
[000103de] 6df6                      blt.s      $000103D6
[000103e0] 3602                      move.w     d2,d3
[000103e2] 3283                      move.w     d3,(a1)
[000103e4] 4842                      swap       d2
[000103e6] 4843                      swap       d3
[000103e8] 264c                      movea.l    a4,a3
[000103ea] b642                      cmp.w      d2,d3
[000103ec] 6f0e                      ble.s      $000103FC
[000103ee] 3003                      move.w     d3,d0
[000103f0] b8a3                      cmp.l      -(a3),d4
[000103f2] 6608                      bne.s      $000103FC
[000103f4] 5343                      subq.w     #1,d3
[000103f6] b642                      cmp.w      d2,d3
[000103f8] 6ef6                      bgt.s      $000103F0
[000103fa] 3602                      move.w     d2,d3
[000103fc] 3083                      move.w     d3,(a0)
[000103fe] 3015                      move.w     (a5),d0
[00010400] b8ad 0002                 cmp.l      2(a5),d4
[00010404] 6704                      beq.s      $0001040A
[00010406] 0a40 0001                 eori.w     #$0001,d0
[0001040a] 322e 01b6                 move.w     438(a6),d1
[0001040e] d350                      add.w      d1,(a0)
[00010410] d351                      add.w      d1,(a1)
[00010412] 4e75                      rts
[00010414] 48e7 c0e0                 movem.l    d0-d1/a0-a2,-(a7)
[00010418] 3d7c 001f 01b4            move.w     #$001F,436(a6)
[0001041e] 3d7c 00ff 0014            move.w     #$00FF,20(a6)
[00010424] 2d7c 0001 0eb4 01f4       move.l     #$00010EB4,500(a6)
[0001042c] 2d7c 0001 090e 01f8       move.l     #$0001090E,504(a6)
[00010434] 2d7c 0001 0996 01fc       move.l     #$00010996,508(a6)
[0001043c] 2d7c 0001 0aa4 0200       move.l     #$00010AA4,512(a6)
[00010444] 2d7c 0001 0cec 0204       move.l     #$00010CEC,516(a6)
[0001044c] 2d7c 0001 161e 0208       move.l     #$0001161E,520(a6)
[00010454] 2d7c 0001 177c 020c       move.l     #$0001177C,524(a6)
[0001045c] 2d7c 0001 15d2 0210       move.l     #$000115D2,528(a6)
[00010464] 2d7c 0001 039c 0214       move.l     #$0001039C,532(a6)
[0001046c] 2d7c 0001 08ae 021c       move.l     #$000108AE,540(a6)
[00010474] 2d7c 0001 08de 0218       move.l     #$000108DE,536(a6)
[0001047c] 2d7c 0001 0526 0220       move.l     #$00010526,544(a6)
[00010484] 2d7c 0001 04a4 0224       move.l     #$000104A4,548(a6)
[0001048c] 2d7c 0001 04ee 0230       move.l     #$000104EE,560(a6)
[00010494] 2d7c 0001 0522 0234       move.l     #$00010522,564(a6)
[0001049c] 4cdf 0703                 movem.l    (a7)+,d0-d1/a0-a2
[000104a0] 4e75                      rts
[000104a2] 4e75                      rts
[000104a4] b07c 0010                 cmp.w      #$0010,d0
[000104a8] 6614                      bne.s      $000104BE
[000104aa] 22d8                      move.l     (a0)+,(a1)+
[000104ac] 22d8                      move.l     (a0)+,(a1)+
[000104ae] 22d8                      move.l     (a0)+,(a1)+
[000104b0] 22d8                      move.l     (a0)+,(a1)+
[000104b2] 22d8                      move.l     (a0)+,(a1)+
[000104b4] 22d8                      move.l     (a0)+,(a1)+
[000104b6] 22d8                      move.l     (a0)+,(a1)+
[000104b8] 22d8                      move.l     (a0)+,(a1)+
[000104ba] 7000                      moveq.l    #0,d0
[000104bc] 4e75                      rts
[000104be] 303c 00ff                 move.w     #$00FF,d0
[000104c2] 082e 0007 01a3            btst       #7,419(a6)
[000104c8] 660a                      bne.s      $000104D4
[000104ca] 22d8                      move.l     (a0)+,(a1)+
[000104cc] 51c8 fffc                 dbf        d0,$000104CA
[000104d0] 701f                      moveq.l    #31,d0
[000104d2] 4e75                      rts
[000104d4] 2f01                      move.l     d1,-(a7)
[000104d6] 3218                      move.w     (a0)+,d1
[000104d8] e159                      rol.w      #8,d1
[000104da] 4841                      swap       d1
[000104dc] 3218                      move.w     (a0)+,d1
[000104de] e159                      rol.w      #8,d1
[000104e0] 4841                      swap       d1
[000104e2] 22c1                      move.l     d1,(a1)+
[000104e4] 51c8 fff0                 dbf        d0,$000104D6
[000104e8] 221f                      move.l     (a7)+,d1
[000104ea] 701f                      moveq.l    #31,d0
[000104ec] 4e75                      rts
[000104ee] 207a 1e58                 movea.l    $00012348(pc),a0
[000104f2] 2068 0028                 movea.l    40(a0),a0
[000104f6] 2050                      movea.l    (a0),a0
[000104f8] 1030 0000                 move.b     0(a0,d0.w),d0
[000104fc] 206e 0278                 movea.l    632(a6),a0
[00010500] e748                      lsl.w      #3,d0
[00010502] 41f0 0830                 lea.l      48(a0,d0.l),a0
[00010506] 3018                      move.w     (a0)+,d0
[00010508] 1010                      move.b     (a0),d0
[0001050a] 5488                      addq.l     #2,a0
[0001050c] 4840                      swap       d0
[0001050e] 3018                      move.w     (a0)+,d0
[00010510] 1010                      move.b     (a0),d0
[00010512] 082e 0007 01a3            btst       #7,419(a6)
[00010518] 6706                      beq.s      $00010520
[0001051a] e158                      rol.w      #8,d0
[0001051c] 4840                      swap       d0
[0001051e] e158                      rol.w      #8,d0
[00010520] 4e75                      rts
[00010522] 70ff                      moveq.l    #-1,d0
[00010524] 4e75                      rts
[00010526] 2f0e                      move.l     a6,-(a7)
[00010528] 7000                      moveq.l    #0,d0
[0001052a] 3028 000c                 move.w     12(a0),d0
[0001052e] 3228 0006                 move.w     6(a0),d1
[00010532] c2e8 0008                 mulu.w     8(a0),d1
[00010536] 7400                      moveq.l    #0,d2
[00010538] 4a68 000a                 tst.w      10(a0)
[0001053c] 6602                      bne.s      $00010540
[0001053e] 7401                      moveq.l    #1,d2
[00010540] 3342 000a                 move.w     d2,10(a1)
[00010544] 2050                      movea.l    (a0),a0
[00010546] 2251                      movea.l    (a1),a1
[00010548] 5381                      subq.l     #1,d1
[0001054a] 6b76                      bmi.s      $000105C2
[0001054c] 5340                      subq.w     #1,d0
[0001054e] 6700 0348                 beq        $00010898
[00010552] 907c 001f                 sub.w      #$001F,d0
[00010556] 666a                      bne.s      $000105C2
[00010558] d442                      add.w      d2,d2
[0001055a] d442                      add.w      d2,d2
[0001055c] 247b 2068                 movea.l    $000105C6(pc,d2.w),a2
[00010560] b3c8                      cmpa.l     a0,a1
[00010562] 6658                      bne.s      $000105BC
[00010564] 2601                      move.l     d1,d3
[00010566] 5283                      addq.l     #1,d3
[00010568] ed8b                      lsl.l      #6,d3
[0001056a] b6bc 0000 4000            cmp.l      #$00004000,d3
[00010570] 6e44                      bgt.s      $000105B6
[00010572] 2003                      move.l     d3,d0
[00010574] 207a 1dd2                 movea.l    $00012348(pc),a0
[00010578] 2068 008c                 movea.l    140(a0),a0
[0001057c] 4e90                      jsr        (a0)
[0001057e] 2008                      move.l     a0,d0
[00010580] 6734                      beq.s      $000105B6
[00010582] c149                      exg        a0,a1
[00010584] 2f09                      move.l     a1,-(a7)
[00010586] 2f03                      move.l     d3,-(a7)
[00010588] 2f08                      move.l     a0,-(a7)
[0001058a] 2001                      move.l     d1,d0
[0001058c] 5280                      addq.l     #1,d0
[0001058e] 4e92                      jsr        (a2)
[00010590] 225f                      movea.l    (a7)+,a1
[00010592] 221f                      move.l     (a7)+,d1
[00010594] 205f                      movea.l    (a7)+,a0
[00010596] e289                      lsr.l      #1,d1
[00010598] 5381                      subq.l     #1,d1
[0001059a] 2c5f                      movea.l    (a7)+,a6
[0001059c] 2f08                      move.l     a0,-(a7)
[0001059e] 487a 0008                 pea.l      $000105A8(pc)
[000105a2] 2f0e                      move.l     a6,-(a7)
[000105a4] 6000 02f6                 bra        $0001089C
[000105a8] 205f                      movea.l    (a7)+,a0
[000105aa] 227a 1d9c                 movea.l    $00012348(pc),a1
[000105ae] 2269 0090                 movea.l    144(a1),a1
[000105b2] 4e91                      jsr        (a1)
[000105b4] 4e75                      rts
[000105b6] 247b 2016                 movea.l    $000105CE(pc,d2.w),a2
[000105ba] 6004                      bra.s      $000105C0
[000105bc] 2001                      move.l     d1,d0
[000105be] 5280                      addq.l     #1,d0
[000105c0] 4e92                      jsr        (a2)
[000105c2] 2c5f                      movea.l    (a7)+,a6
[000105c4] 4e75                      rts
[000105c6] 0001 07f6                 ori.b      #$F6,d1
[000105ca] 0001 0758                 ori.b      #$58,d1
[000105ce] 0001 05d6                 ori.b      #$D6,d1
[000105d2] 0001 06d4                 ori.b      #$D4,d1
[000105d6] 48e7 40c0                 movem.l    d1/a0-a1,-(a7)
[000105da] 2001                      move.l     d1,d0
[000105dc] 781f                      moveq.l    #31,d4
[000105de] 6100 0148                 bsr        $00010728
[000105e2] 4cdf 0302                 movem.l    (a7)+,d1/a0-a1
[000105e6] 2c41                      movea.l    d1,a6
[000105e8] 2f08                      move.l     a0,-(a7)
[000105ea] 41e8 0040                 lea.l      64(a0),a0
[000105ee] 2f20                      move.l     -(a0),-(a7)
[000105f0] 2f20                      move.l     -(a0),-(a7)
[000105f2] 2f20                      move.l     -(a0),-(a7)
[000105f4] 2f20                      move.l     -(a0),-(a7)
[000105f6] 2f20                      move.l     -(a0),-(a7)
[000105f8] 2f20                      move.l     -(a0),-(a7)
[000105fa] 2f20                      move.l     -(a0),-(a7)
[000105fc] 2f20                      move.l     -(a0),-(a7)
[000105fe] 2f20                      move.l     -(a0),-(a7)
[00010600] 2f20                      move.l     -(a0),-(a7)
[00010602] 2f20                      move.l     -(a0),-(a7)
[00010604] 2f20                      move.l     -(a0),-(a7)
[00010606] 41e8 fff0                 lea.l      -16(a0),a0
[0001060a] 2f09                      move.l     a1,-(a7)
[0001060c] 6136                      bsr.s      $00010644
[0001060e] 225f                      movea.l    (a7)+,a1
[00010610] 5289                      addq.l     #1,a1
[00010612] 204f                      movea.l    a7,a0
[00010614] 2f09                      move.l     a1,-(a7)
[00010616] 612c                      bsr.s      $00010644
[00010618] 225f                      movea.l    (a7)+,a1
[0001061a] 4fef 0010                 lea.l      16(a7),a7
[0001061e] 5289                      addq.l     #1,a1
[00010620] 204f                      movea.l    a7,a0
[00010622] 2f09                      move.l     a1,-(a7)
[00010624] 611e                      bsr.s      $00010644
[00010626] 225f                      movea.l    (a7)+,a1
[00010628] 4fef 0010                 lea.l      16(a7),a7
[0001062c] 5289                      addq.l     #1,a1
[0001062e] 204f                      movea.l    a7,a0
[00010630] 6112                      bsr.s      $00010644
[00010632] 4fef 0010                 lea.l      16(a7),a7
[00010636] 205f                      movea.l    (a7)+,a0
[00010638] 41e8 0040                 lea.l      64(a0),a0
[0001063c] 220e                      move.l     a6,d1
[0001063e] 5381                      subq.l     #1,d1
[00010640] 6aa4                      bpl.s      $000105E6
[00010642] 4e75                      rts
[00010644] 700f                      moveq.l    #15,d0
[00010646] 4840                      swap       d0
[00010648] 3e18                      move.w     (a0)+,d7
[0001064a] 3c18                      move.w     (a0)+,d6
[0001064c] 3a18                      move.w     (a0)+,d5
[0001064e] 3818                      move.w     (a0)+,d4
[00010650] 3618                      move.w     (a0)+,d3
[00010652] 3418                      move.w     (a0)+,d2
[00010654] 3218                      move.w     (a0)+,d1
[00010656] 3018                      move.w     (a0)+,d0
[00010658] 4840                      swap       d0
[0001065a] 4847                      swap       d7
[0001065c] 4840                      swap       d0
[0001065e] d040                      add.w      d0,d0
[00010660] df07                      addx.b     d7,d7
[00010662] d241                      add.w      d1,d1
[00010664] df07                      addx.b     d7,d7
[00010666] d442                      add.w      d2,d2
[00010668] df07                      addx.b     d7,d7
[0001066a] d643                      add.w      d3,d3
[0001066c] df07                      addx.b     d7,d7
[0001066e] d844                      add.w      d4,d4
[00010670] df07                      addx.b     d7,d7
[00010672] da45                      add.w      d5,d5
[00010674] df07                      addx.b     d7,d7
[00010676] dc46                      add.w      d6,d6
[00010678] df07                      addx.b     d7,d7
[0001067a] 4847                      swap       d7
[0001067c] de47                      add.w      d7,d7
[0001067e] 4847                      swap       d7
[00010680] df07                      addx.b     d7,d7
[00010682] 1287                      move.b     d7,(a1)
[00010684] 5889                      addq.l     #4,a1
[00010686] 4840                      swap       d0
[00010688] 51c8 ffd2                 dbf        d0,$0001065C
[0001068c] 4e75                      rts
[0001068e] 700f                      moveq.l    #15,d0
[00010690] 4840                      swap       d0
[00010692] 4847                      swap       d7
[00010694] 1e10                      move.b     (a0),d7
[00010696] 5888                      addq.l     #4,a0
[00010698] de07                      add.b      d7,d7
[0001069a] d140                      addx.w     d0,d0
[0001069c] de07                      add.b      d7,d7
[0001069e] d341                      addx.w     d1,d1
[000106a0] de07                      add.b      d7,d7
[000106a2] d542                      addx.w     d2,d2
[000106a4] de07                      add.b      d7,d7
[000106a6] d743                      addx.w     d3,d3
[000106a8] de07                      add.b      d7,d7
[000106aa] d944                      addx.w     d4,d4
[000106ac] de07                      add.b      d7,d7
[000106ae] db45                      addx.w     d5,d5
[000106b0] de07                      add.b      d7,d7
[000106b2] dd46                      addx.w     d6,d6
[000106b4] de07                      add.b      d7,d7
[000106b6] 4847                      swap       d7
[000106b8] df47                      addx.w     d7,d7
[000106ba] 4840                      swap       d0
[000106bc] 51c8 ffd2                 dbf        d0,$00010690
[000106c0] 4840                      swap       d0
[000106c2] 32c7                      move.w     d7,(a1)+
[000106c4] 32c6                      move.w     d6,(a1)+
[000106c6] 32c5                      move.w     d5,(a1)+
[000106c8] 32c4                      move.w     d4,(a1)+
[000106ca] 32c3                      move.w     d3,(a1)+
[000106cc] 32c2                      move.w     d2,(a1)+
[000106ce] 32c1                      move.w     d1,(a1)+
[000106d0] 32c0                      move.w     d0,(a1)+
[000106d2] 4e75                      rts
[000106d4] 48e7 40c0                 movem.l    d1/a0-a1,-(a7)
[000106d8] 2c41                      movea.l    d1,a6
[000106da] 41e8 0040                 lea.l      64(a0),a0
[000106de] 2f08                      move.l     a0,-(a7)
[000106e0] 2f20                      move.l     -(a0),-(a7)
[000106e2] 2f20                      move.l     -(a0),-(a7)
[000106e4] 2f20                      move.l     -(a0),-(a7)
[000106e6] 2f20                      move.l     -(a0),-(a7)
[000106e8] 2f20                      move.l     -(a0),-(a7)
[000106ea] 2f20                      move.l     -(a0),-(a7)
[000106ec] 2f20                      move.l     -(a0),-(a7)
[000106ee] 2f20                      move.l     -(a0),-(a7)
[000106f0] 2f20                      move.l     -(a0),-(a7)
[000106f2] 2f20                      move.l     -(a0),-(a7)
[000106f4] 2f20                      move.l     -(a0),-(a7)
[000106f6] 2f20                      move.l     -(a0),-(a7)
[000106f8] 2f20                      move.l     -(a0),-(a7)
[000106fa] 2f20                      move.l     -(a0),-(a7)
[000106fc] 2f20                      move.l     -(a0),-(a7)
[000106fe] 2f20                      move.l     -(a0),-(a7)
[00010700] 618c                      bsr.s      $0001068E
[00010702] 204f                      movea.l    a7,a0
[00010704] 5288                      addq.l     #1,a0
[00010706] 6186                      bsr.s      $0001068E
[00010708] 204f                      movea.l    a7,a0
[0001070a] 5488                      addq.l     #2,a0
[0001070c] 6180                      bsr.s      $0001068E
[0001070e] 204f                      movea.l    a7,a0
[00010710] 5688                      addq.l     #3,a0
[00010712] 6100 ff7a                 bsr        $0001068E
[00010716] 4fef 0040                 lea.l      64(a7),a7
[0001071a] 205f                      movea.l    (a7)+,a0
[0001071c] 220e                      move.l     a6,d1
[0001071e] 5381                      subq.l     #1,d1
[00010720] 6ab6                      bpl.s      $000106D8
[00010722] 4cdf 0310                 movem.l    (a7)+,d4/a0-a1
[00010726] 701f                      moveq.l    #31,d0
[00010728] 5384                      subq.l     #1,d4
[0001072a] 6b2a                      bmi.s      $00010756
[0001072c] 7400                      moveq.l    #0,d2
[0001072e] 2204                      move.l     d4,d1
[00010730] d1c0                      adda.l     d0,a0
[00010732] 41f0 0802                 lea.l      2(a0,d0.l),a0
[00010736] 3a10                      move.w     (a0),d5
[00010738] 2248                      movea.l    a0,a1
[0001073a] 2448                      movea.l    a0,a2
[0001073c] d480                      add.l      d0,d2
[0001073e] 2602                      move.l     d2,d3
[00010740] 6004                      bra.s      $00010746
[00010742] 2449                      movea.l    a1,a2
[00010744] 34a1                      move.w     -(a1),(a2)
[00010746] 5383                      subq.l     #1,d3
[00010748] 6af8                      bpl.s      $00010742
[0001074a] 3285                      move.w     d5,(a1)
[0001074c] 5381                      subq.l     #1,d1
[0001074e] 6ae0                      bpl.s      $00010730
[00010750] 204a                      movea.l    a2,a0
[00010752] 5380                      subq.l     #1,d0
[00010754] 6ad6                      bpl.s      $0001072C
[00010756] 4e75                      rts
[00010758] d080                      add.l      d0,d0
[0001075a] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[0001075e] 6130                      bsr.s      $00010790
[00010760] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010764] 5288                      addq.l     #1,a0
[00010766] 2400                      move.l     d0,d2
[00010768] e78a                      lsl.l      #3,d2
[0001076a] d3c2                      adda.l     d2,a1
[0001076c] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010770] 611e                      bsr.s      $00010790
[00010772] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010776] 5288                      addq.l     #1,a0
[00010778] 2400                      move.l     d0,d2
[0001077a] e78a                      lsl.l      #3,d2
[0001077c] d3c2                      adda.l     d2,a1
[0001077e] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010782] 610c                      bsr.s      $00010790
[00010784] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010788] 5288                      addq.l     #1,a0
[0001078a] 2400                      move.l     d0,d2
[0001078c] e78a                      lsl.l      #3,d2
[0001078e] d3c2                      adda.l     d2,a1
[00010790] 45f1 0800                 lea.l      0(a1,d0.l),a2
[00010794] 47f2 0800                 lea.l      0(a2,d0.l),a3
[00010798] 49f3 0800                 lea.l      0(a3,d0.l),a4
[0001079c] e588                      lsl.l      #2,d0
[0001079e] 2a40                      movea.l    d0,a5
[000107a0] 2c41                      movea.l    d1,a6
[000107a2] 700f                      moveq.l    #15,d0
[000107a4] 4840                      swap       d0
[000107a6] 4847                      swap       d7
[000107a8] 1e10                      move.b     (a0),d7
[000107aa] 5888                      addq.l     #4,a0
[000107ac] de07                      add.b      d7,d7
[000107ae] d140                      addx.w     d0,d0
[000107b0] de07                      add.b      d7,d7
[000107b2] d341                      addx.w     d1,d1
[000107b4] de07                      add.b      d7,d7
[000107b6] d542                      addx.w     d2,d2
[000107b8] de07                      add.b      d7,d7
[000107ba] d743                      addx.w     d3,d3
[000107bc] de07                      add.b      d7,d7
[000107be] d944                      addx.w     d4,d4
[000107c0] de07                      add.b      d7,d7
[000107c2] db45                      addx.w     d5,d5
[000107c4] de07                      add.b      d7,d7
[000107c6] dd46                      addx.w     d6,d6
[000107c8] de07                      add.b      d7,d7
[000107ca] 4847                      swap       d7
[000107cc] df47                      addx.w     d7,d7
[000107ce] 4840                      swap       d0
[000107d0] 51c8 ffd2                 dbf        d0,$000107A4
[000107d4] 4840                      swap       d0
[000107d6] 32c7                      move.w     d7,(a1)+
[000107d8] 34c6                      move.w     d6,(a2)+
[000107da] 36c5                      move.w     d5,(a3)+
[000107dc] 38c4                      move.w     d4,(a4)+
[000107de] 3383 d8fe                 move.w     d3,-2(a1,a5.l)
[000107e2] 3582 d8fe                 move.w     d2,-2(a2,a5.l)
[000107e6] 3781 d8fe                 move.w     d1,-2(a3,a5.l)
[000107ea] 3980 d8fe                 move.w     d0,-2(a4,a5.l)
[000107ee] 220e                      move.l     a6,d1
[000107f0] 5381                      subq.l     #1,d1
[000107f2] 6aac                      bpl.s      $000107A0
[000107f4] 4e75                      rts
[000107f6] d080                      add.l      d0,d0
[000107f8] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[000107fc] 6130                      bsr.s      $0001082E
[000107fe] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010802] 2400                      move.l     d0,d2
[00010804] e78a                      lsl.l      #3,d2
[00010806] d1c2                      adda.l     d2,a0
[00010808] 5289                      addq.l     #1,a1
[0001080a] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[0001080e] 611e                      bsr.s      $0001082E
[00010810] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010814] 2400                      move.l     d0,d2
[00010816] e78a                      lsl.l      #3,d2
[00010818] d1c2                      adda.l     d2,a0
[0001081a] 5289                      addq.l     #1,a1
[0001081c] 48e7 c0c0                 movem.l    d0-d1/a0-a1,-(a7)
[00010820] 610c                      bsr.s      $0001082E
[00010822] 4cdf 0303                 movem.l    (a7)+,d0-d1/a0-a1
[00010826] 2400                      move.l     d0,d2
[00010828] e78a                      lsl.l      #3,d2
[0001082a] d1c2                      adda.l     d2,a0
[0001082c] 5289                      addq.l     #1,a1
[0001082e] 45f0 0800                 lea.l      0(a0,d0.l),a2
[00010832] 47f2 0800                 lea.l      0(a2,d0.l),a3
[00010836] 49f3 0800                 lea.l      0(a3,d0.l),a4
[0001083a] e588                      lsl.l      #2,d0
[0001083c] 2a40                      movea.l    d0,a5
[0001083e] 2c41                      movea.l    d1,a6
[00010840] 700f                      moveq.l    #15,d0
[00010842] 4840                      swap       d0
[00010844] 3e18                      move.w     (a0)+,d7
[00010846] 3c1a                      move.w     (a2)+,d6
[00010848] 3a1b                      move.w     (a3)+,d5
[0001084a] 381c                      move.w     (a4)+,d4
[0001084c] 3630 d8fe                 move.w     -2(a0,a5.l),d3
[00010850] 3432 d8fe                 move.w     -2(a2,a5.l),d2
[00010854] 3233 d8fe                 move.w     -2(a3,a5.l),d1
[00010858] 3034 d8fe                 move.w     -2(a4,a5.l),d0
[0001085c] 4840                      swap       d0
[0001085e] 4847                      swap       d7
[00010860] 4840                      swap       d0
[00010862] d040                      add.w      d0,d0
[00010864] df07                      addx.b     d7,d7
[00010866] d241                      add.w      d1,d1
[00010868] df07                      addx.b     d7,d7
[0001086a] d442                      add.w      d2,d2
[0001086c] df07                      addx.b     d7,d7
[0001086e] d643                      add.w      d3,d3
[00010870] df07                      addx.b     d7,d7
[00010872] d844                      add.w      d4,d4
[00010874] df07                      addx.b     d7,d7
[00010876] da45                      add.w      d5,d5
[00010878] df07                      addx.b     d7,d7
[0001087a] dc46                      add.w      d6,d6
[0001087c] df07                      addx.b     d7,d7
[0001087e] 4847                      swap       d7
[00010880] de47                      add.w      d7,d7
[00010882] 4847                      swap       d7
[00010884] df07                      addx.b     d7,d7
[00010886] 1287                      move.b     d7,(a1)
[00010888] 5889                      addq.l     #4,a1
[0001088a] 4840                      swap       d0
[0001088c] 51c8 ffd2                 dbf        d0,$00010860
[00010890] 220e                      move.l     a6,d1
[00010892] 5381                      subq.l     #1,d1
[00010894] 6aa8                      bpl.s      $0001083E
[00010896] 4e75                      rts
[00010898] b3c8                      cmpa.l     a0,a1
[0001089a] 670e                      beq.s      $000108AA
[0001089c] e289                      lsr.l      #1,d1
[0001089e] 6504                      bcs.s      $000108A4
[000108a0] 32d8                      move.w     (a0)+,(a1)+
[000108a2] 6002                      bra.s      $000108A6
[000108a4] 22d8                      move.l     (a0)+,(a1)+
[000108a6] 5381                      subq.l     #1,d1
[000108a8] 6afa                      bpl.s      $000108A4
[000108aa] 2c5f                      movea.l    (a7)+,a6
[000108ac] 4e75                      rts
[000108ae] 4a6e 01b2                 tst.w      434(a6)
[000108b2] 6712                      beq.s      $000108C6
[000108b4] 906e 01b6                 sub.w      438(a6),d0
[000108b8] 926e 01b8                 sub.w      440(a6),d1
[000108bc] 206e 01ae                 movea.l    430(a6),a0
[000108c0] c2ee 01b2                 mulu.w     434(a6),d1
[000108c4] 6008                      bra.s      $000108CE
[000108c6] 2078 044e                 movea.l    ($0000044E).w,a0
[000108ca] c2f8 206e                 mulu.w     ($0000206E).w,d1
[000108ce] d1c1                      adda.l     d1,a0
[000108d0] 7200                      moveq.l    #0,d1
[000108d2] 3200                      move.w     d0,d1
[000108d4] d281                      add.l      d1,d1
[000108d6] d281                      add.l      d1,d1
[000108d8] d1c1                      adda.l     d1,a0
[000108da] 2010                      move.l     (a0),d0
[000108dc] 4e75                      rts
[000108de] 4a6e 01b2                 tst.w      434(a6)
[000108e2] 6712                      beq.s      $000108F6
[000108e4] 906e 01b6                 sub.w      438(a6),d0
[000108e8] 926e 01b8                 sub.w      440(a6),d1
[000108ec] 206e 01ae                 movea.l    430(a6),a0
[000108f0] c2ee 01b2                 mulu.w     434(a6),d1
[000108f4] 6008                      bra.s      $000108FE
[000108f6] 2078 044e                 movea.l    ($0000044E).w,a0
[000108fa] c2f8 206e                 mulu.w     ($0000206E).w,d1
[000108fe] d1c1                      adda.l     d1,a0
[00010900] 7200                      moveq.l    #0,d1
[00010902] 3200                      move.w     d0,d1
[00010904] d281                      add.l      d1,d1
[00010906] d281                      add.l      d1,d1
[00010908] d1c1                      adda.l     d1,a0
[0001090a] 2082                      move.l     d2,(a0)
[0001090c] 4e75                      rts
[0001090e] 4a6e 00ca                 tst.w      202(a6)
[00010912] 676a                      beq.s      $0001097E
[00010914] 2f08                      move.l     a0,-(a7)
[00010916] 206e 00c6                 movea.l    198(a6),a0
[0001091a] 780f                      moveq.l    #15,d4
[0001091c] c841                      and.w      d1,d4
[0001091e] ed4c                      lsl.w      #6,d4
[00010920] d0c4                      adda.w     d4,a0
[00010922] 7800                      moveq.l    #0,d4
[00010924] 382e 01b2                 move.w     434(a6),d4
[00010928] 6710                      beq.s      $0001093A
[0001092a] 43ee 01b6                 lea.l      438(a6),a1
[0001092e] 9051                      sub.w      (a1),d0
[00010930] 9459                      sub.w      (a1)+,d2
[00010932] 9251                      sub.w      (a1),d1
[00010934] 226e 01ae                 movea.l    430(a6),a1
[00010938] 6008                      bra.s      $00010942
[0001093a] 3838 206e                 move.w     ($0000206E).w,d4
[0001093e] 2278 044e                 movea.l    ($0000044E).w,a1
[00010942] 9480                      sub.l      d0,d2
[00010944] d080                      add.l      d0,d0
[00010946] d080                      add.l      d0,d0
[00010948] c2c4                      mulu.w     d4,d1
[0001094a] d280                      add.l      d0,d1
[0001094c] 2f09                      move.l     a1,-(a7)
[0001094e] 7e40                      moveq.l    #64,d7
[00010950] 7c0f                      moveq.l    #15,d6
[00010952] b446                      cmp.w      d6,d2
[00010954] 6c02                      bge.s      $00010958
[00010956] 3c02                      move.w     d2,d6
[00010958] 703f                      moveq.l    #63,d0
[0001095a] c041                      and.w      d1,d0
[0001095c] 2a30 0000                 move.l     0(a0,d0.w),d5
[00010960] 3802                      move.w     d2,d4
[00010962] e84c                      lsr.w      #4,d4
[00010964] 2257                      movea.l    (a7),a1
[00010966] d3c1                      adda.l     d1,a1
[00010968] 2285                      move.l     d5,(a1)
[0001096a] d2c7                      adda.w     d7,a1
[0001096c] 51cc fffa                 dbf        d4,$00010968
[00010970] 5881                      addq.l     #4,d1
[00010972] 5342                      subq.w     #1,d2
[00010974] 51ce ffe2                 dbf        d6,$00010958
[00010978] 588f                      addq.l     #4,a7
[0001097a] 205f                      movea.l    (a7)+,a0
[0001097c] 4e75                      rts
[0001097e] 226e 00c6                 movea.l    198(a6),a1
[00010982] 780f                      moveq.l    #15,d4
[00010984] c841                      and.w      d1,d4
[00010986] d844                      add.w      d4,d4
[00010988] 3e31 4000                 move.w     0(a1,d4.w),d7
[0001098c] 780f                      moveq.l    #15,d4
[0001098e] c840                      and.w      d0,d4
[00010990] e97f                      rol.w      d4,d7
[00010992] 6002                      bra.s      $00010996
[00010994] 4e71                      nop
[00010996] 4a6e 01b2                 tst.w      434(a6)
[0001099a] 6714                      beq.s      $000109B0
[0001099c] 43ee 01b6                 lea.l      438(a6),a1
[000109a0] 9051                      sub.w      (a1),d0
[000109a2] 9459                      sub.w      (a1)+,d2
[000109a4] 9251                      sub.w      (a1),d1
[000109a6] 226e 01ae                 movea.l    430(a6),a1
[000109aa] c2ee 01b2                 mulu.w     434(a6),d1
[000109ae] 6008                      bra.s      $000109B8
[000109b0] 2278 044e                 movea.l    ($0000044E).w,a1
[000109b4] c2f8 206e                 mulu.w     ($0000206E).w,d1
[000109b8] 2800                      move.l     d0,d4
[000109ba] d884                      add.l      d4,d4
[000109bc] d884                      add.l      d4,d4
[000109be] d3c1                      adda.l     d1,a1
[000109c0] d3c4                      adda.l     d4,a1
[000109c2] 9440                      sub.w      d0,d2
[000109c4] 3c2e 003c                 move.w     60(a6),d6
[000109c8] dc46                      add.w      d6,d6
[000109ca] 3c3b 6006                 move.w     $000109D2(pc,d6.w),d6
[000109ce] 4efb 6002                 jmp        $000109D2(pc,d6.w)
J1:
[000109d2] 0008                      dc.w $0008   ; $000109da-J1
[000109d4] 0054                      dc.w $0054   ; $00010a26-J1
[000109d6] 009c                      dc.w $009c   ; $00010a6e-J1
[000109d8] 004c                      dc.w $004c   ; $00010a1e-J1
[000109da] be7c ffff                 cmp.w      #$FFFF,d7
[000109de] 6732                      beq.s      $00010A12
[000109e0] 2f0b                      move.l     a3,-(a7)
[000109e2] 7240                      moveq.l    #64,d1
[000109e4] 700f                      moveq.l    #15,d0
[000109e6] b440                      cmp.w      d0,d2
[000109e8] 6c02                      bge.s      $000109EC
[000109ea] 3002                      move.w     d2,d0
[000109ec] 2a2e 00f2                 move.l     242(a6),d5
[000109f0] de47                      add.w      d7,d7
[000109f2] 6504                      bcs.s      $000109F8
[000109f4] 2a2e 00f6                 move.l     246(a6),d5
[000109f8] 3802                      move.w     d2,d4
[000109fa] e84c                      lsr.w      #4,d4
[000109fc] 2649                      movea.l    a1,a3
[000109fe] 2685                      move.l     d5,(a3)
[00010a00] d6c1                      adda.w     d1,a3
[00010a02] 51cc fffa                 dbf        d4,$000109FE
[00010a06] 5889                      addq.l     #4,a1
[00010a08] 5342                      subq.w     #1,d2
[00010a0a] 51c8 ffe0                 dbf        d0,$000109EC
[00010a0e] 265f                      movea.l    (a7)+,a3
[00010a10] 4e75                      rts
[00010a12] 2a2e 00f2                 move.l     242(a6),d5
[00010a16] 22c5                      move.l     d5,(a1)+
[00010a18] 51ca fffc                 dbf        d2,$00010A16
[00010a1c] 4e75                      rts
[00010a1e] 4647                      not.w      d7
[00010a20] 2a2e 00f6                 move.l     246(a6),d5
[00010a24] 6004                      bra.s      $00010A2A
[00010a26] 2a2e 00f2                 move.l     242(a6),d5
[00010a2a] be7c ffff                 cmp.w      #$FFFF,d7
[00010a2e] 67e6                      beq.s      $00010A16
[00010a30] 2f0b                      move.l     a3,-(a7)
[00010a32] 7240                      moveq.l    #64,d1
[00010a34] 700f                      moveq.l    #15,d0
[00010a36] b440                      cmp.w      d0,d2
[00010a38] 6c02                      bge.s      $00010A3C
[00010a3a] 3002                      move.w     d2,d0
[00010a3c] de47                      add.w      d7,d7
[00010a3e] 640e                      bcc.s      $00010A4E
[00010a40] 3802                      move.w     d2,d4
[00010a42] e84c                      lsr.w      #4,d4
[00010a44] 2649                      movea.l    a1,a3
[00010a46] 2685                      move.l     d5,(a3)
[00010a48] d6c1                      adda.w     d1,a3
[00010a4a] 51cc fffa                 dbf        d4,$00010A46
[00010a4e] 5889                      addq.l     #4,a1
[00010a50] 5342                      subq.w     #1,d2
[00010a52] 51c8 ffe8                 dbf        d0,$00010A3C
[00010a56] 265f                      movea.l    (a7)+,a3
[00010a58] 4e75                      rts
[00010a5a] 5889                      addq.l     #4,a1
[00010a5c] 51ca 0004                 dbf        d2,$00010A62
[00010a60] 4e75                      rts
[00010a62] e24a                      lsr.w      #1,d2
[00010a64] 4699                      not.l      (a1)+
[00010a66] 5889                      addq.l     #4,a1
[00010a68] 51ca fffa                 dbf        d2,$00010A64
[00010a6c] 4e75                      rts
[00010a6e] be7c aaaa                 cmp.w      #$AAAA,d7
[00010a72] 67ee                      beq.s      $00010A62
[00010a74] be7c 5555                 cmp.w      #$5555,d7
[00010a78] 67e0                      beq.s      $00010A5A
[00010a7a] 2f0b                      move.l     a3,-(a7)
[00010a7c] 7240                      moveq.l    #64,d1
[00010a7e] 700f                      moveq.l    #15,d0
[00010a80] b440                      cmp.w      d0,d2
[00010a82] 6c02                      bge.s      $00010A86
[00010a84] 3002                      move.w     d2,d0
[00010a86] de47                      add.w      d7,d7
[00010a88] 640e                      bcc.s      $00010A98
[00010a8a] 3802                      move.w     d2,d4
[00010a8c] e84c                      lsr.w      #4,d4
[00010a8e] 2649                      movea.l    a1,a3
[00010a90] 4693                      not.l      (a3)
[00010a92] d6c1                      adda.w     d1,a3
[00010a94] 51cc fffa                 dbf        d4,$00010A90
[00010a98] 5889                      addq.l     #4,a1
[00010a9a] 5342                      subq.w     #1,d2
[00010a9c] 51c8 ffe8                 dbf        d0,$00010A86
[00010aa0] 265f                      movea.l    (a7)+,a3
[00010aa2] 4e75                      rts
[00010aa4] 7a00                      moveq.l    #0,d5
[00010aa6] 3a2e 01b2                 move.w     434(a6),d5
[00010aaa] 670e                      beq.s      $00010ABA
[00010aac] 226e 01ae                 movea.l    430(a6),a1
[00010ab0] 906e 01b6                 sub.w      438(a6),d0
[00010ab4] 926e 01b8                 sub.w      440(a6),d1
[00010ab8] 6008                      bra.s      $00010AC2
[00010aba] 2278 044e                 movea.l    ($0000044E).w,a1
[00010abe] 3a38 206e                 move.w     ($0000206E).w,d5
[00010ac2] c2c5                      mulu.w     d5,d1
[00010ac4] d3c1                      adda.l     d1,a1
[00010ac6] d080                      add.l      d0,d0
[00010ac8] d080                      add.l      d0,d0
[00010aca] d3c0                      adda.l     d0,a1
[00010acc] 3c2e 003c                 move.w     60(a6),d6
[00010ad0] dc46                      add.w      d6,d6
[00010ad2] 3c3b 6006                 move.w     $00010ADA(pc,d6.w),d6
[00010ad6] 4efb 6002                 jmp        $00010ADA(pc,d6.w)
J2:
[00010ada] 0008                      dc.w $0008   ; $00010ae2-J2
[00010adc] 00f6                      dc.w $00f6   ; $00010bd0-J2
[00010ade] 018a                      dc.w $018a   ; $00010c64-J2
[00010ae0] 00ee                      dc.w $00ee   ; $00010bc8-J2
[00010ae2] be7c ffff                 cmp.w      #$FFFF,d7
[00010ae6] 6700 0084                 beq        $00010B6C
[00010aea] 2f05                      move.l     d5,-(a7)
[00010aec] e98d                      lsl.l      #4,d5
[00010aee] 700f                      moveq.l    #15,d0
[00010af0] b440                      cmp.w      d0,d2
[00010af2] 6c02                      bge.s      $00010AF6
[00010af4] 3002                      move.w     d2,d0
[00010af6] 2f09                      move.l     a1,-(a7)
[00010af8] 262e 00f2                 move.l     242(a6),d3
[00010afc] de47                      add.w      d7,d7
[00010afe] 6504                      bcs.s      $00010B04
[00010b00] 262e 00f6                 move.l     246(a6),d3
[00010b04] 3202                      move.w     d2,d1
[00010b06] e849                      lsr.w      #4,d1
[00010b08] 3c01                      move.w     d1,d6
[00010b0a] e849                      lsr.w      #4,d1
[00010b0c] 4646                      not.w      d6
[00010b0e] 0246 000f                 andi.w     #$000F,d6
[00010b12] dc46                      add.w      d6,d6
[00010b14] dc46                      add.w      d6,d6
[00010b16] 4efb 6002                 jmp        $00010B1A(pc,d6.w)
[00010b1a] 2283                      move.l     d3,(a1)
[00010b1c] d3c5                      adda.l     d5,a1
[00010b1e] 2283                      move.l     d3,(a1)
[00010b20] d3c5                      adda.l     d5,a1
[00010b22] 2283                      move.l     d3,(a1)
[00010b24] d3c5                      adda.l     d5,a1
[00010b26] 2283                      move.l     d3,(a1)
[00010b28] d3c5                      adda.l     d5,a1
[00010b2a] 2283                      move.l     d3,(a1)
[00010b2c] d3c5                      adda.l     d5,a1
[00010b2e] 2283                      move.l     d3,(a1)
[00010b30] d3c5                      adda.l     d5,a1
[00010b32] 2283                      move.l     d3,(a1)
[00010b34] d3c5                      adda.l     d5,a1
[00010b36] 2283                      move.l     d3,(a1)
[00010b38] d3c5                      adda.l     d5,a1
[00010b3a] 2283                      move.l     d3,(a1)
[00010b3c] d3c5                      adda.l     d5,a1
[00010b3e] 2283                      move.l     d3,(a1)
[00010b40] d3c5                      adda.l     d5,a1
[00010b42] 2283                      move.l     d3,(a1)
[00010b44] d3c5                      adda.l     d5,a1
[00010b46] 2283                      move.l     d3,(a1)
[00010b48] d3c5                      adda.l     d5,a1
[00010b4a] 2283                      move.l     d3,(a1)
[00010b4c] d3c5                      adda.l     d5,a1
[00010b4e] 2283                      move.l     d3,(a1)
[00010b50] d3c5                      adda.l     d5,a1
[00010b52] 2283                      move.l     d3,(a1)
[00010b54] d3c5                      adda.l     d5,a1
[00010b56] 2283                      move.l     d3,(a1)
[00010b58] d3c5                      adda.l     d5,a1
[00010b5a] 51c9 ffbe                 dbf        d1,$00010B1A
[00010b5e] 225f                      movea.l    (a7)+,a1
[00010b60] d3d7                      adda.l     (a7),a1
[00010b62] 5342                      subq.w     #1,d2
[00010b64] 51c8 ff90                 dbf        d0,$00010AF6
[00010b68] 588f                      addq.l     #4,a7
[00010b6a] 4e75                      rts
[00010b6c] 282e 00f2                 move.l     242(a6),d4
[00010b70] 3602                      move.w     d2,d3
[00010b72] 4643                      not.w      d3
[00010b74] c67c 000f                 and.w      #$000F,d3
[00010b78] d643                      add.w      d3,d3
[00010b7a] d643                      add.w      d3,d3
[00010b7c] e84a                      lsr.w      #4,d2
[00010b7e] 4efb 3002                 jmp        $00010B82(pc,d3.w)
[00010b82] 2284                      move.l     d4,(a1)
[00010b84] d3c5                      adda.l     d5,a1
[00010b86] 2284                      move.l     d4,(a1)
[00010b88] d3c5                      adda.l     d5,a1
[00010b8a] 2284                      move.l     d4,(a1)
[00010b8c] d3c5                      adda.l     d5,a1
[00010b8e] 2284                      move.l     d4,(a1)
[00010b90] d3c5                      adda.l     d5,a1
[00010b92] 2284                      move.l     d4,(a1)
[00010b94] d3c5                      adda.l     d5,a1
[00010b96] 2284                      move.l     d4,(a1)
[00010b98] d3c5                      adda.l     d5,a1
[00010b9a] 2284                      move.l     d4,(a1)
[00010b9c] d3c5                      adda.l     d5,a1
[00010b9e] 2284                      move.l     d4,(a1)
[00010ba0] d3c5                      adda.l     d5,a1
[00010ba2] 2284                      move.l     d4,(a1)
[00010ba4] d3c5                      adda.l     d5,a1
[00010ba6] 2284                      move.l     d4,(a1)
[00010ba8] d3c5                      adda.l     d5,a1
[00010baa] 2284                      move.l     d4,(a1)
[00010bac] d3c5                      adda.l     d5,a1
[00010bae] 2284                      move.l     d4,(a1)
[00010bb0] d3c5                      adda.l     d5,a1
[00010bb2] 2284                      move.l     d4,(a1)
[00010bb4] d3c5                      adda.l     d5,a1
[00010bb6] 2284                      move.l     d4,(a1)
[00010bb8] d3c5                      adda.l     d5,a1
[00010bba] 2284                      move.l     d4,(a1)
[00010bbc] d3c5                      adda.l     d5,a1
[00010bbe] 2284                      move.l     d4,(a1)
[00010bc0] d3c5                      adda.l     d5,a1
[00010bc2] 51ca ffbe                 dbf        d2,$00010B82
[00010bc6] 4e75                      rts
[00010bc8] 4647                      not.w      d7
[00010bca] 282e 00f6                 move.l     246(a6),d4
[00010bce] 6004                      bra.s      $00010BD4
[00010bd0] 282e 00f2                 move.l     242(a6),d4
[00010bd4] 2f05                      move.l     d5,-(a7)
[00010bd6] e98d                      lsl.l      #4,d5
[00010bd8] 700f                      moveq.l    #15,d0
[00010bda] b440                      cmp.w      d0,d2
[00010bdc] 6c02                      bge.s      $00010BE0
[00010bde] 3002                      move.w     d2,d0
[00010be0] 2609                      move.l     a1,d3
[00010be2] de47                      add.w      d7,d7
[00010be4] 645a                      bcc.s      $00010C40
[00010be6] 3202                      move.w     d2,d1
[00010be8] e849                      lsr.w      #4,d1
[00010bea] 3c01                      move.w     d1,d6
[00010bec] e849                      lsr.w      #4,d1
[00010bee] 4646                      not.w      d6
[00010bf0] 0246 000f                 andi.w     #$000F,d6
[00010bf4] dc46                      add.w      d6,d6
[00010bf6] dc46                      add.w      d6,d6
[00010bf8] 4efb 6002                 jmp        $00010BFC(pc,d6.w)
[00010bfc] 2284                      move.l     d4,(a1)
[00010bfe] d3c5                      adda.l     d5,a1
[00010c00] 2284                      move.l     d4,(a1)
[00010c02] d3c5                      adda.l     d5,a1
[00010c04] 2284                      move.l     d4,(a1)
[00010c06] d3c5                      adda.l     d5,a1
[00010c08] 2284                      move.l     d4,(a1)
[00010c0a] d3c5                      adda.l     d5,a1
[00010c0c] 2284                      move.l     d4,(a1)
[00010c0e] d3c5                      adda.l     d5,a1
[00010c10] 2284                      move.l     d4,(a1)
[00010c12] d3c5                      adda.l     d5,a1
[00010c14] 2284                      move.l     d4,(a1)
[00010c16] d3c5                      adda.l     d5,a1
[00010c18] 2284                      move.l     d4,(a1)
[00010c1a] d3c5                      adda.l     d5,a1
[00010c1c] 2284                      move.l     d4,(a1)
[00010c1e] d3c5                      adda.l     d5,a1
[00010c20] 2284                      move.l     d4,(a1)
[00010c22] d3c5                      adda.l     d5,a1
[00010c24] 2284                      move.l     d4,(a1)
[00010c26] d3c5                      adda.l     d5,a1
[00010c28] 2284                      move.l     d4,(a1)
[00010c2a] d3c5                      adda.l     d5,a1
[00010c2c] 2284                      move.l     d4,(a1)
[00010c2e] d3c5                      adda.l     d5,a1
[00010c30] 2284                      move.l     d4,(a1)
[00010c32] d3c5                      adda.l     d5,a1
[00010c34] 2284                      move.l     d4,(a1)
[00010c36] d3c5                      adda.l     d5,a1
[00010c38] 2284                      move.l     d4,(a1)
[00010c3a] d3c5                      adda.l     d5,a1
[00010c3c] 51c9 ffbe                 dbf        d1,$00010BFC
[00010c40] 2243                      movea.l    d3,a1
[00010c42] d3d7                      adda.l     (a7),a1
[00010c44] 5342                      subq.w     #1,d2
[00010c46] 51c8 ff98                 dbf        d0,$00010BE0
[00010c4a] 588f                      addq.l     #4,a7
[00010c4c] 4e75                      rts
[00010c4e] d3c5                      adda.l     d5,a1
[00010c50] 51ca 0004                 dbf        d2,$00010C56
[00010c54] 4e75                      rts
[00010c56] da85                      add.l      d5,d5
[00010c58] e24a                      lsr.w      #1,d2
[00010c5a] b991                      eor.l      d4,(a1)
[00010c5c] d3c5                      adda.l     d5,a1
[00010c5e] 51ca fffa                 dbf        d2,$00010C5A
[00010c62] 4e75                      rts
[00010c64] 78ff                      moveq.l    #-1,d4
[00010c66] be7c aaaa                 cmp.w      #$AAAA,d7
[00010c6a] 67ea                      beq.s      $00010C56
[00010c6c] be7c 5555                 cmp.w      #$5555,d7
[00010c70] 67dc                      beq.s      $00010C4E
[00010c72] 2f05                      move.l     d5,-(a7)
[00010c74] e98d                      lsl.l      #4,d5
[00010c76] 700f                      moveq.l    #15,d0
[00010c78] b440                      cmp.w      d0,d2
[00010c7a] 6c02                      bge.s      $00010C7E
[00010c7c] 3002                      move.w     d2,d0
[00010c7e] 2609                      move.l     a1,d3
[00010c80] de47                      add.w      d7,d7
[00010c82] 645a                      bcc.s      $00010CDE
[00010c84] 3202                      move.w     d2,d1
[00010c86] e849                      lsr.w      #4,d1
[00010c88] 3c01                      move.w     d1,d6
[00010c8a] e849                      lsr.w      #4,d1
[00010c8c] 4646                      not.w      d6
[00010c8e] 0246 000f                 andi.w     #$000F,d6
[00010c92] dc46                      add.w      d6,d6
[00010c94] dc46                      add.w      d6,d6
[00010c96] 4efb 6002                 jmp        $00010C9A(pc,d6.w)
[00010c9a] b991                      eor.l      d4,(a1)
[00010c9c] d3c5                      adda.l     d5,a1
[00010c9e] b991                      eor.l      d4,(a1)
[00010ca0] d3c5                      adda.l     d5,a1
[00010ca2] b991                      eor.l      d4,(a1)
[00010ca4] d3c5                      adda.l     d5,a1
[00010ca6] b991                      eor.l      d4,(a1)
[00010ca8] d3c5                      adda.l     d5,a1
[00010caa] b991                      eor.l      d4,(a1)
[00010cac] d3c5                      adda.l     d5,a1
[00010cae] b991                      eor.l      d4,(a1)
[00010cb0] d3c5                      adda.l     d5,a1
[00010cb2] b991                      eor.l      d4,(a1)
[00010cb4] d3c5                      adda.l     d5,a1
[00010cb6] b991                      eor.l      d4,(a1)
[00010cb8] d3c5                      adda.l     d5,a1
[00010cba] b991                      eor.l      d4,(a1)
[00010cbc] d3c5                      adda.l     d5,a1
[00010cbe] b991                      eor.l      d4,(a1)
[00010cc0] d3c5                      adda.l     d5,a1
[00010cc2] b991                      eor.l      d4,(a1)
[00010cc4] d3c5                      adda.l     d5,a1
[00010cc6] b991                      eor.l      d4,(a1)
[00010cc8] d3c5                      adda.l     d5,a1
[00010cca] b991                      eor.l      d4,(a1)
[00010ccc] d3c5                      adda.l     d5,a1
[00010cce] b991                      eor.l      d4,(a1)
[00010cd0] d3c5                      adda.l     d5,a1
[00010cd2] b991                      eor.l      d4,(a1)
[00010cd4] d3c5                      adda.l     d5,a1
[00010cd6] b991                      eor.l      d4,(a1)
[00010cd8] d3c5                      adda.l     d5,a1
[00010cda] 51c9 ffbe                 dbf        d1,$00010C9A
[00010cde] 2243                      movea.l    d3,a1
[00010ce0] d3d7                      adda.l     (a7),a1
[00010ce2] 5342                      subq.w     #1,d2
[00010ce4] 51c8 ff98                 dbf        d0,$00010C7E
[00010ce8] 588f                      addq.l     #4,a7
[00010cea] 4e75                      rts
[00010cec] 2f06                      move.l     d6,-(a7)
[00010cee] 7c00                      moveq.l    #0,d6
[00010cf0] 3c2e 01b2                 move.w     434(a6),d6
[00010cf4] 670e                      beq.s      $00010D04
[00010cf6] 226e 01ae                 movea.l    430(a6),a1
[00010cfa] 906e 01b6                 sub.w      438(a6),d0
[00010cfe] 926e 01b8                 sub.w      440(a6),d1
[00010d02] 6008                      bra.s      $00010D0C
[00010d04] 2278 044e                 movea.l    ($0000044E).w,a1
[00010d08] 3c38 206e                 move.w     ($0000206E).w,d6
[00010d0c] c2c6                      mulu.w     d6,d1
[00010d0e] d3c1                      adda.l     d1,a1
[00010d10] d080                      add.l      d0,d0
[00010d12] d080                      add.l      d0,d0
[00010d14] d3c0                      adda.l     d0,a1
[00010d16] 4a9f                      tst.l      (a7)+
[00010d18] 6a02                      bpl.s      $00010D1C
[00010d1a] 4486                      neg.l      d6
[00010d1c] 202e 00f2                 move.l     242(a6),d0
[00010d20] 322e 003c                 move.w     60(a6),d1
[00010d24] ba44                      cmp.w      d4,d5
[00010d26] 6302                      bls.s      $00010D2A
[00010d28] 5841                      addq.w     #4,d1
[00010d2a] d241                      add.w      d1,d1
[00010d2c] 323b 1006                 move.w     $00010D34(pc,d1.w),d1
[00010d30] 4efb 1002                 jmp        $00010D34(pc,d1.w)
J3:
[00010d34] 0010                      dc.w $0010   ; $00010d44-J3
[00010d36] 005c                      dc.w $005c   ; $00010d90-J3
[00010d38] 0082                      dc.w $0082   ; $00010db6-J3
[00010d3a] 0056                      dc.w $0056   ; $00010d8a-J3
[00010d3c] 00aa                      dc.w $00aa   ; $00010dde-J3
[00010d3e] 00fc                      dc.w $00fc   ; $00010e30-J3
[00010d40] 0118                      dc.w $0118   ; $00010e4c-J3
[00010d42] 00f6                      dc.w $00f6   ; $00010e2a-J3
[00010d44] be7c ffff                 cmp.w      #$FFFF,d7
[00010d48] 672a                      beq.s      $00010D74
[00010d4a] 222e 00f6                 move.l     246(a6),d1
[00010d4e] e35f                      rol.w      #1,d7
[00010d50] 640c                      bcc.s      $00010D5E
[00010d52] 22c0                      move.l     d0,(a1)+
[00010d54] d645                      add.w      d5,d3
[00010d56] 6a12                      bpl.s      $00010D6A
[00010d58] 51ca fff4                 dbf        d2,$00010D4E
[00010d5c] 4e75                      rts
[00010d5e] 22c1                      move.l     d1,(a1)+
[00010d60] d645                      add.w      d5,d3
[00010d62] 6a06                      bpl.s      $00010D6A
[00010d64] 51ca ffe8                 dbf        d2,$00010D4E
[00010d68] 4e75                      rts
[00010d6a] d3c6                      adda.l     d6,a1
[00010d6c] 9644                      sub.w      d4,d3
[00010d6e] 51ca ffde                 dbf        d2,$00010D4E
[00010d72] 4e75                      rts
[00010d74] 22c0                      move.l     d0,(a1)+
[00010d76] d645                      add.w      d5,d3
[00010d78] 6a06                      bpl.s      $00010D80
[00010d7a] 51ca fff8                 dbf        d2,$00010D74
[00010d7e] 4e75                      rts
[00010d80] d3c6                      adda.l     d6,a1
[00010d82] 9644                      sub.w      d4,d3
[00010d84] 51ca ffee                 dbf        d2,$00010D74
[00010d88] 4e75                      rts
[00010d8a] 4647                      not.w      d7
[00010d8c] 202e 00f6                 move.l     246(a6),d0
[00010d90] e35f                      rol.w      #1,d7
[00010d92] 640c                      bcc.s      $00010DA0
[00010d94] 22c0                      move.l     d0,(a1)+
[00010d96] d645                      add.w      d5,d3
[00010d98] 6a12                      bpl.s      $00010DAC
[00010d9a] 51ca fff4                 dbf        d2,$00010D90
[00010d9e] 4e75                      rts
[00010da0] 5889                      addq.l     #4,a1
[00010da2] d645                      add.w      d5,d3
[00010da4] 6a06                      bpl.s      $00010DAC
[00010da6] 51ca ffe8                 dbf        d2,$00010D90
[00010daa] 4e75                      rts
[00010dac] d3c6                      adda.l     d6,a1
[00010dae] 9644                      sub.w      d4,d3
[00010db0] 51ca ffde                 dbf        d2,$00010D90
[00010db4] 4e75                      rts
[00010db6] 70ff                      moveq.l    #-1,d0
[00010db8] e35f                      rol.w      #1,d7
[00010dba] 640c                      bcc.s      $00010DC8
[00010dbc] b199                      eor.l      d0,(a1)+
[00010dbe] d645                      add.w      d5,d3
[00010dc0] 6a12                      bpl.s      $00010DD4
[00010dc2] 51ca fff4                 dbf        d2,$00010DB8
[00010dc6] 4e75                      rts
[00010dc8] 5889                      addq.l     #4,a1
[00010dca] d645                      add.w      d5,d3
[00010dcc] 6a06                      bpl.s      $00010DD4
[00010dce] 51ca ffe8                 dbf        d2,$00010DB8
[00010dd2] 4e75                      rts
[00010dd4] d3c6                      adda.l     d6,a1
[00010dd6] 9644                      sub.w      d4,d3
[00010dd8] 51ca ffde                 dbf        d2,$00010DB8
[00010ddc] 4e75                      rts
[00010dde] be7c ffff                 cmp.w      #$FFFF,d7
[00010de2] 672e                      beq.s      $00010E12
[00010de4] 222e 00f6                 move.l     246(a6),d1
[00010de8] e35f                      rol.w      #1,d7
[00010dea] 640e                      bcc.s      $00010DFA
[00010dec] 2280                      move.l     d0,(a1)
[00010dee] d3c6                      adda.l     d6,a1
[00010df0] d644                      add.w      d4,d3
[00010df2] 6a14                      bpl.s      $00010E08
[00010df4] 51ca fff2                 dbf        d2,$00010DE8
[00010df8] 4e75                      rts
[00010dfa] 2281                      move.l     d1,(a1)
[00010dfc] d3c6                      adda.l     d6,a1
[00010dfe] d644                      add.w      d4,d3
[00010e00] 6a06                      bpl.s      $00010E08
[00010e02] 51ca ffe4                 dbf        d2,$00010DE8
[00010e06] 4e75                      rts
[00010e08] 5889                      addq.l     #4,a1
[00010e0a] 9645                      sub.w      d5,d3
[00010e0c] 51ca ffda                 dbf        d2,$00010DE8
[00010e10] 4e75                      rts
[00010e12] 2280                      move.l     d0,(a1)
[00010e14] d3c6                      adda.l     d6,a1
[00010e16] d644                      add.w      d4,d3
[00010e18] 6a06                      bpl.s      $00010E20
[00010e1a] 51ca fff6                 dbf        d2,$00010E12
[00010e1e] 4e75                      rts
[00010e20] 5889                      addq.l     #4,a1
[00010e22] 9645                      sub.w      d5,d3
[00010e24] 51ca ffec                 dbf        d2,$00010E12
[00010e28] 4e75                      rts
[00010e2a] 4647                      not.w      d7
[00010e2c] 202e 00f6                 move.l     246(a6),d0
[00010e30] e35f                      rol.w      #1,d7
[00010e32] 6402                      bcc.s      $00010E36
[00010e34] 2280                      move.l     d0,(a1)
[00010e36] d3c6                      adda.l     d6,a1
[00010e38] d644                      add.w      d4,d3
[00010e3a] 6a06                      bpl.s      $00010E42
[00010e3c] 51ca fff2                 dbf        d2,$00010E30
[00010e40] 4e75                      rts
[00010e42] 5889                      addq.l     #4,a1
[00010e44] 9645                      sub.w      d5,d3
[00010e46] 51ca ffe8                 dbf        d2,$00010E30
[00010e4a] 4e75                      rts
[00010e4c] 70ff                      moveq.l    #-1,d0
[00010e4e] e35f                      rol.w      #1,d7
[00010e50] 6402                      bcc.s      $00010E54
[00010e52] b191                      eor.l      d0,(a1)
[00010e54] d3c6                      adda.l     d6,a1
[00010e56] d644                      add.w      d4,d3
[00010e58] 6a06                      bpl.s      $00010E60
[00010e5a] 51ca fff2                 dbf        d2,$00010E4E
[00010e5e] 4e75                      rts
[00010e60] 5889                      addq.l     #4,a1
[00010e62] 9645                      sub.w      d5,d3
[00010e64] 51ca ffe8                 dbf        d2,$00010E4E
[00010e68] 4e75                      rts
[00010e6a] 9641                      sub.w      d1,d3
[00010e6c] c2c4                      mulu.w     d4,d1
[00010e6e] 2c00                      move.l     d0,d6
[00010e70] dc86                      add.l      d6,d6
[00010e72] dc86                      add.l      d6,d6
[00010e74] d286                      add.l      d6,d1
[00010e76] d3c1                      adda.l     d1,a1
[00010e78] 9480                      sub.l      d0,d2
[00010e7a] 2002                      move.l     d2,d0
[00010e7c] 5280                      addq.l     #1,d0
[00010e7e] d080                      add.l      d0,d0
[00010e80] d080                      add.l      d0,d0
[00010e82] 9880                      sub.l      d0,d4
[00010e84] 7007                      moveq.l    #7,d0
[00010e86] c082                      and.l      d2,d0
[00010e88] 0a40 0007                 eori.w     #$0007,d0
[00010e8c] d080                      add.l      d0,d0
[00010e8e] e68a                      lsr.l      #3,d2
[00010e90] 41fb 0806                 lea.l      $00010E98(pc,d0.l),a0
[00010e94] 2002                      move.l     d2,d0
[00010e96] 4ed0                      jmp        (a0)
[00010e98] 22c5                      move.l     d5,(a1)+
[00010e9a] 22c5                      move.l     d5,(a1)+
[00010e9c] 22c5                      move.l     d5,(a1)+
[00010e9e] 22c5                      move.l     d5,(a1)+
[00010ea0] 22c5                      move.l     d5,(a1)+
[00010ea2] 22c5                      move.l     d5,(a1)+
[00010ea4] 22c5                      move.l     d5,(a1)+
[00010ea6] 22c5                      move.l     d5,(a1)+
[00010ea8] 51c8 ffee                 dbf        d0,$00010E98
[00010eac] d3c4                      adda.l     d4,a1
[00010eae] 51cb ffe4                 dbf        d3,$00010E94
[00010eb2] 4e75                      rts
[00010eb4] 48c0                      ext.l      d0
[00010eb6] 48c1                      ext.l      d1
[00010eb8] 48c2                      ext.l      d2
[00010eba] 48c3                      ext.l      d3
[00010ebc] 2a2e 00f2                 move.l     242(a6),d5
[00010ec0] 7800                      moveq.l    #0,d4
[00010ec2] 382e 01b2                 move.w     434(a6),d4
[00010ec6] 6712                      beq.s      $00010EDA
[00010ec8] 43ee 01b6                 lea.l      438(a6),a1
[00010ecc] 9051                      sub.w      (a1),d0
[00010ece] 9459                      sub.w      (a1)+,d2
[00010ed0] 9251                      sub.w      (a1),d1
[00010ed2] 9651                      sub.w      (a1),d3
[00010ed4] 226e 01ae                 movea.l    430(a6),a1
[00010ed8] 6008                      bra.s      $00010EE2
[00010eda] 2278 044e                 movea.l    ($0000044E).w,a1
[00010ede] 3838 206e                 move.w     ($0000206E).w,d4
[00010ee2] 3e2e 003c                 move.w     60(a6),d7
[00010ee6] 662c                      bne.s      $00010F14
[00010ee8] 2c2e 0030                 move.l     48(a6),d6
[00010eec] bcae 00f6                 cmp.l      246(a6),d6
[00010ef0] 6622                      bne.s      $00010F14
[00010ef2] ba86                      cmp.l      d6,d5
[00010ef4] 6700 ff74                 beq        $00010E6A
[00010ef8] 0c6e 0001 00c0            cmpi.w     #$0001,192(a6)
[00010efe] 6700 ff6a                 beq        $00010E6A
[00010f02] 0c6e 0002 00c0            cmpi.w     #$0002,192(a6)
[00010f08] 660a                      bne.s      $00010F14
[00010f0a] 0c6e 0008 00c2            cmpi.w     #$0008,194(a6)
[00010f10] 6700 ff58                 beq        $00010E6A
[00010f14] 286e 00c6                 movea.l    198(a6),a4
[00010f18] 206e 00e2                 movea.l    226(a6),a0
[00010f1c] 9641                      sub.w      d1,d3
[00010f1e] 2c04                      move.l     d4,d6
[00010f20] c8c1                      mulu.w     d1,d4
[00010f22] d3c4                      adda.l     d4,a1
[00010f24] 2800                      move.l     d0,d4
[00010f26] d884                      add.l      d4,d4
[00010f28] d884                      add.l      d4,d4
[00010f2a] d3c4                      adda.l     d4,a1
[00010f2c] 4a47                      tst.w      d7
[00010f2e] 6600 03b8                 bne        $000112E8
[00010f32] 4fef ffe2                 lea.l      -30(a7),a7
[00010f36] 2f46 0016                 move.l     d6,22(a7)
[00010f3a] 78f0                      moveq.l    #-16,d4
[00010f3c] c882                      and.l      d2,d4
[00010f3e] 9880                      sub.l      d0,d4
[00010f40] d884                      add.l      d4,d4
[00010f42] d884                      add.l      d4,d4
[00010f44] e98e                      lsl.l      #4,d6
[00010f46] 9c84                      sub.l      d4,d6
[00010f48] 2f46 000e                 move.l     d6,14(a7)
[00010f4c] 2a48                      movea.l    a0,a5
[00010f4e] 7c1f                      moveq.l    #31,d6
[00010f50] d26e 01b8                 add.w      440(a6),d1
[00010f54] d281                      add.l      d1,d1
[00010f56] 4a6e 00ca                 tst.w      202(a6)
[00010f5a] 673e                      beq.s      $00010F9A
[00010f5c] c286                      and.l      d6,d1
[00010f5e] 6722                      beq.s      $00010F82
[00010f60] 264c                      movea.l    a4,a3
[00010f62] 2a01                      move.l     d1,d5
[00010f64] bd85                      eor.l      d6,d5
[00010f66] 2c01                      move.l     d1,d6
[00010f68] 5386                      subq.l     #1,d6
[00010f6a] eb89                      lsl.l      #5,d1
[00010f6c] d7c1                      adda.l     d1,a3
[00010f6e] 2adb                      move.l     (a3)+,(a5)+
[00010f70] 2adb                      move.l     (a3)+,(a5)+
[00010f72] 2adb                      move.l     (a3)+,(a5)+
[00010f74] 2adb                      move.l     (a3)+,(a5)+
[00010f76] 2adb                      move.l     (a3)+,(a5)+
[00010f78] 2adb                      move.l     (a3)+,(a5)+
[00010f7a] 2adb                      move.l     (a3)+,(a5)+
[00010f7c] 2adb                      move.l     (a3)+,(a5)+
[00010f7e] 51cd ffee                 dbf        d5,$00010F6E
[00010f82] 2adc                      move.l     (a4)+,(a5)+
[00010f84] 2adc                      move.l     (a4)+,(a5)+
[00010f86] 2adc                      move.l     (a4)+,(a5)+
[00010f88] 2adc                      move.l     (a4)+,(a5)+
[00010f8a] 2adc                      move.l     (a4)+,(a5)+
[00010f8c] 2adc                      move.l     (a4)+,(a5)+
[00010f8e] 2adc                      move.l     (a4)+,(a5)+
[00010f90] 2adc                      move.l     (a4)+,(a5)+
[00010f92] 51ce ffee                 dbf        d6,$00010F82
[00010f96] 6000 01c0                 bra        $00011158
[00010f9a] 2e2e 0030                 move.l     48(a6),d7
[00010f9e] beae 00f6                 cmp.l      246(a6),d7
[00010fa2] 6700 0124                 beq        $000110C8
[00010fa6] 48e7 9000                 movem.l    d0/d3,-(a7)
[00010faa] 262e 00f6                 move.l     246(a6),d3
[00010fae] 4dfa 139c                 lea.l      $0001234C(pc),a6
[00010fb2] c286                      and.l      d6,d1
[00010fb4] 6700 008c                 beq        $00011042
[00010fb8] 264c                      movea.l    a4,a3
[00010fba] d7c1                      adda.l     d1,a3
[00010fbc] 2c01                      move.l     d1,d6
[00010fbe] 0a41 001f                 eori.w     #$001F,d1
[00010fc2] 5386                      subq.l     #1,d6
[00010fc4] 7e00                      moveq.l    #0,d7
[00010fc6] 1e1b                      move.b     (a3)+,d7
[00010fc8] eb4f                      lsl.w      #5,d7
[00010fca] 45f6 7000                 lea.l      0(a6,d7.w),a2
[00010fce] 2e1a                      move.l     (a2)+,d7
[00010fd0] 2007                      move.l     d7,d0
[00010fd2] 8e85                      or.l       d5,d7
[00010fd4] 4680                      not.l      d0
[00010fd6] 8083                      or.l       d3,d0
[00010fd8] ce80                      and.l      d0,d7
[00010fda] 2ac7                      move.l     d7,(a5)+
[00010fdc] 2e1a                      move.l     (a2)+,d7
[00010fde] 2007                      move.l     d7,d0
[00010fe0] 8e85                      or.l       d5,d7
[00010fe2] 4680                      not.l      d0
[00010fe4] 8083                      or.l       d3,d0
[00010fe6] ce80                      and.l      d0,d7
[00010fe8] 2ac7                      move.l     d7,(a5)+
[00010fea] 2e1a                      move.l     (a2)+,d7
[00010fec] 2007                      move.l     d7,d0
[00010fee] 8e85                      or.l       d5,d7
[00010ff0] 4680                      not.l      d0
[00010ff2] 8083                      or.l       d3,d0
[00010ff4] ce80                      and.l      d0,d7
[00010ff6] 2ac7                      move.l     d7,(a5)+
[00010ff8] 2e1a                      move.l     (a2)+,d7
[00010ffa] 2007                      move.l     d7,d0
[00010ffc] 8e85                      or.l       d5,d7
[00010ffe] 4680                      not.l      d0
[00011000] 8083                      or.l       d3,d0
[00011002] ce80                      and.l      d0,d7
[00011004] 2ac7                      move.l     d7,(a5)+
[00011006] 2e1a                      move.l     (a2)+,d7
[00011008] 2007                      move.l     d7,d0
[0001100a] 8e85                      or.l       d5,d7
[0001100c] 4680                      not.l      d0
[0001100e] 8083                      or.l       d3,d0
[00011010] ce80                      and.l      d0,d7
[00011012] 2ac7                      move.l     d7,(a5)+
[00011014] 2e1a                      move.l     (a2)+,d7
[00011016] 2007                      move.l     d7,d0
[00011018] 8e85                      or.l       d5,d7
[0001101a] 4680                      not.l      d0
[0001101c] 8083                      or.l       d3,d0
[0001101e] ce80                      and.l      d0,d7
[00011020] 2ac7                      move.l     d7,(a5)+
[00011022] 2e1a                      move.l     (a2)+,d7
[00011024] 2007                      move.l     d7,d0
[00011026] 8e85                      or.l       d5,d7
[00011028] 4680                      not.l      d0
[0001102a] 8083                      or.l       d3,d0
[0001102c] ce80                      and.l      d0,d7
[0001102e] 2ac7                      move.l     d7,(a5)+
[00011030] 2e1a                      move.l     (a2)+,d7
[00011032] 2007                      move.l     d7,d0
[00011034] 8e85                      or.l       d5,d7
[00011036] 4680                      not.l      d0
[00011038] 8083                      or.l       d3,d0
[0001103a] ce80                      and.l      d0,d7
[0001103c] 2ac7                      move.l     d7,(a5)+
[0001103e] 51c9 ff84                 dbf        d1,$00010FC4
[00011042] 7e00                      moveq.l    #0,d7
[00011044] 1e1c                      move.b     (a4)+,d7
[00011046] eb4f                      lsl.w      #5,d7
[00011048] 45f6 7000                 lea.l      0(a6,d7.w),a2
[0001104c] 2e1a                      move.l     (a2)+,d7
[0001104e] 2007                      move.l     d7,d0
[00011050] 8e85                      or.l       d5,d7
[00011052] 4680                      not.l      d0
[00011054] 8083                      or.l       d3,d0
[00011056] ce80                      and.l      d0,d7
[00011058] 2ac7                      move.l     d7,(a5)+
[0001105a] 2e1a                      move.l     (a2)+,d7
[0001105c] 2007                      move.l     d7,d0
[0001105e] 8e85                      or.l       d5,d7
[00011060] 4680                      not.l      d0
[00011062] 8083                      or.l       d3,d0
[00011064] ce80                      and.l      d0,d7
[00011066] 2ac7                      move.l     d7,(a5)+
[00011068] 2e1a                      move.l     (a2)+,d7
[0001106a] 2007                      move.l     d7,d0
[0001106c] 8e85                      or.l       d5,d7
[0001106e] 4680                      not.l      d0
[00011070] 8083                      or.l       d3,d0
[00011072] ce80                      and.l      d0,d7
[00011074] 2ac7                      move.l     d7,(a5)+
[00011076] 2e1a                      move.l     (a2)+,d7
[00011078] 2007                      move.l     d7,d0
[0001107a] 8e85                      or.l       d5,d7
[0001107c] 4680                      not.l      d0
[0001107e] 8083                      or.l       d3,d0
[00011080] ce80                      and.l      d0,d7
[00011082] 2ac7                      move.l     d7,(a5)+
[00011084] 2e1a                      move.l     (a2)+,d7
[00011086] 2007                      move.l     d7,d0
[00011088] 8e85                      or.l       d5,d7
[0001108a] 4680                      not.l      d0
[0001108c] 8083                      or.l       d3,d0
[0001108e] ce80                      and.l      d0,d7
[00011090] 2ac7                      move.l     d7,(a5)+
[00011092] 2e1a                      move.l     (a2)+,d7
[00011094] 2007                      move.l     d7,d0
[00011096] 8e85                      or.l       d5,d7
[00011098] 4680                      not.l      d0
[0001109a] 8083                      or.l       d3,d0
[0001109c] ce80                      and.l      d0,d7
[0001109e] 2ac7                      move.l     d7,(a5)+
[000110a0] 2e1a                      move.l     (a2)+,d7
[000110a2] 2007                      move.l     d7,d0
[000110a4] 8e85                      or.l       d5,d7
[000110a6] 4680                      not.l      d0
[000110a8] 8083                      or.l       d3,d0
[000110aa] ce80                      and.l      d0,d7
[000110ac] 2ac7                      move.l     d7,(a5)+
[000110ae] 2e1a                      move.l     (a2)+,d7
[000110b0] 2007                      move.l     d7,d0
[000110b2] 8e85                      or.l       d5,d7
[000110b4] 4680                      not.l      d0
[000110b6] 8083                      or.l       d3,d0
[000110b8] ce80                      and.l      d0,d7
[000110ba] 2ac7                      move.l     d7,(a5)+
[000110bc] 51ce ff84                 dbf        d6,$00011042
[000110c0] 4cdf 0009                 movem.l    (a7)+,d0/d3
[000110c4] 6000 0092                 bra        $00011158
[000110c8] 4dfa 1282                 lea.l      $0001234C(pc),a6
[000110cc] c286                      and.l      d6,d1
[000110ce] 674a                      beq.s      $0001111A
[000110d0] 264c                      movea.l    a4,a3
[000110d2] d7c1                      adda.l     d1,a3
[000110d4] 2c01                      move.l     d1,d6
[000110d6] 0a41 001f                 eori.w     #$001F,d1
[000110da] 5386                      subq.l     #1,d6
[000110dc] 7e00                      moveq.l    #0,d7
[000110de] 1e1b                      move.b     (a3)+,d7
[000110e0] eb4f                      lsl.w      #5,d7
[000110e2] 45f6 7000                 lea.l      0(a6,d7.w),a2
[000110e6] 2e1a                      move.l     (a2)+,d7
[000110e8] 8e85                      or.l       d5,d7
[000110ea] 2ac7                      move.l     d7,(a5)+
[000110ec] 2e1a                      move.l     (a2)+,d7
[000110ee] 8e85                      or.l       d5,d7
[000110f0] 2ac7                      move.l     d7,(a5)+
[000110f2] 2e1a                      move.l     (a2)+,d7
[000110f4] 8e85                      or.l       d5,d7
[000110f6] 2ac7                      move.l     d7,(a5)+
[000110f8] 2e1a                      move.l     (a2)+,d7
[000110fa] 8e85                      or.l       d5,d7
[000110fc] 2ac7                      move.l     d7,(a5)+
[000110fe] 2e1a                      move.l     (a2)+,d7
[00011100] 8e85                      or.l       d5,d7
[00011102] 2ac7                      move.l     d7,(a5)+
[00011104] 2e1a                      move.l     (a2)+,d7
[00011106] 8e85                      or.l       d5,d7
[00011108] 2ac7                      move.l     d7,(a5)+
[0001110a] 2e1a                      move.l     (a2)+,d7
[0001110c] 8e85                      or.l       d5,d7
[0001110e] 2ac7                      move.l     d7,(a5)+
[00011110] 2e1a                      move.l     (a2)+,d7
[00011112] 8e85                      or.l       d5,d7
[00011114] 2ac7                      move.l     d7,(a5)+
[00011116] 51c9 ffc4                 dbf        d1,$000110DC
[0001111a] 7e00                      moveq.l    #0,d7
[0001111c] 1e1c                      move.b     (a4)+,d7
[0001111e] eb4f                      lsl.w      #5,d7
[00011120] 45f6 7000                 lea.l      0(a6,d7.w),a2
[00011124] 2e1a                      move.l     (a2)+,d7
[00011126] 8e85                      or.l       d5,d7
[00011128] 2ac7                      move.l     d7,(a5)+
[0001112a] 2e1a                      move.l     (a2)+,d7
[0001112c] 8e85                      or.l       d5,d7
[0001112e] 2ac7                      move.l     d7,(a5)+
[00011130] 2e1a                      move.l     (a2)+,d7
[00011132] 8e85                      or.l       d5,d7
[00011134] 2ac7                      move.l     d7,(a5)+
[00011136] 2e1a                      move.l     (a2)+,d7
[00011138] 8e85                      or.l       d5,d7
[0001113a] 2ac7                      move.l     d7,(a5)+
[0001113c] 2e1a                      move.l     (a2)+,d7
[0001113e] 8e85                      or.l       d5,d7
[00011140] 2ac7                      move.l     d7,(a5)+
[00011142] 2e1a                      move.l     (a2)+,d7
[00011144] 8e85                      or.l       d5,d7
[00011146] 2ac7                      move.l     d7,(a5)+
[00011148] 2e1a                      move.l     (a2)+,d7
[0001114a] 8e85                      or.l       d5,d7
[0001114c] 2ac7                      move.l     d7,(a5)+
[0001114e] 2e1a                      move.l     (a2)+,d7
[00011150] 8e85                      or.l       d5,d7
[00011152] 2ac7                      move.l     d7,(a5)+
[00011154] 51ce ffc4                 dbf        d6,$0001111A
[00011158] 2c02                      move.l     d2,d6
[0001115a] e88a                      lsr.l      #4,d2
[0001115c] 2800                      move.l     d0,d4
[0001115e] e88c                      lsr.l      #4,d4
[00011160] 9484                      sub.l      d4,d2
[00011162] 6700 0126                 beq        $0001128A
[00011166] 5582                      subq.l     #2,d2
[00011168] 3e82                      move.w     d2,(a7)
[0001116a] 7a1e                      moveq.l    #30,d5
[0001116c] d040                      add.w      d0,d0
[0001116e] c045                      and.w      d5,d0
[00011170] 3f40 0004                 move.w     d0,4(a7)
[00011174] 7e00                      moveq.l    #0,d7
[00011176] 907c 0018                 sub.w      #$0018,d0
[0001117a] 6b04                      bmi.s      $00011180
[0001117c] 3e00                      move.w     d0,d7
[0001117e] de47                      add.w      d7,d7
[00011180] 3f47 0006                 move.w     d7,6(a7)
[00011184] dc46                      add.w      d6,d6
[00011186] cc45                      and.w      d5,d6
[00011188] 3e06                      move.w     d6,d7
[0001118a] de47                      add.w      d7,d7
[0001118c] 5847                      addq.w     #4,d7
[0001118e] 3f47 000c                 move.w     d7,12(a7)
[00011192] bb46                      eor.w      d5,d6
[00011194] 3f46 0008                 move.w     d6,8(a7)
[00011198] 7e10                      moveq.l    #16,d7
[0001119a] 5146                      subq.w     #8,d6
[0001119c] 6a04                      bpl.s      $000111A2
[0001119e] dc46                      add.w      d6,d6
[000111a0] de46                      add.w      d6,d7
[000111a2] 3f47 000a                 move.w     d7,10(a7)
[000111a6] 700f                      moveq.l    #15,d0
[000111a8] b640                      cmp.w      d0,d3
[000111aa] 6c02                      bge.s      $000111AE
[000111ac] 3003                      move.w     d3,d0
[000111ae] 3f40 001a                 move.w     d0,26(a7)
[000111b2] 3f43 0002                 move.w     d3,2(a7)
[000111b6] 2f49 0012                 move.l     a1,18(a7)
[000111ba] 302f 0002                 move.w     2(a7),d0
[000111be] e848                      lsr.w      #4,d0
[000111c0] 2218                      move.l     (a0)+,d1
[000111c2] 2418                      move.l     (a0)+,d2
[000111c4] 2618                      move.l     (a0)+,d3
[000111c6] 2818                      move.l     (a0)+,d4
[000111c8] 2a18                      move.l     (a0)+,d5
[000111ca] 2c18                      move.l     (a0)+,d6
[000111cc] 2e18                      move.l     (a0)+,d7
[000111ce] 2458                      movea.l    (a0)+,a2
[000111d0] 2658                      movea.l    (a0)+,a3
[000111d2] 2858                      movea.l    (a0)+,a4
[000111d4] 2a58                      movea.l    (a0)+,a5
[000111d6] 2c58                      movea.l    (a0)+,a6
[000111d8] 4840                      swap       d0
[000111da] d0ef 0006                 adda.w     6(a7),a0
[000111de] 302f 0004                 move.w     4(a7),d0
[000111e2] 4efb 0002                 jmp        $000111E6(pc,d0.w)
[000111e6] 22c1                      move.l     d1,(a1)+
[000111e8] 22c2                      move.l     d2,(a1)+
[000111ea] 22c3                      move.l     d3,(a1)+
[000111ec] 22c4                      move.l     d4,(a1)+
[000111ee] 22c5                      move.l     d5,(a1)+
[000111f0] 22c6                      move.l     d6,(a1)+
[000111f2] 22c7                      move.l     d7,(a1)+
[000111f4] 22ca                      move.l     a2,(a1)+
[000111f6] 22cb                      move.l     a3,(a1)+
[000111f8] 22cc                      move.l     a4,(a1)+
[000111fa] 22cd                      move.l     a5,(a1)+
[000111fc] 22ce                      move.l     a6,(a1)+
[000111fe] 22d8                      move.l     (a0)+,(a1)+
[00011200] 22d8                      move.l     (a0)+,(a1)+
[00011202] 22d8                      move.l     (a0)+,(a1)+
[00011204] 22d8                      move.l     (a0)+,(a1)+
[00011206] 3017                      move.w     (a7),d0
[00011208] 6b28                      bmi.s      $00011232
[0001120a] 41e8 fff0                 lea.l      -16(a0),a0
[0001120e] 22c1                      move.l     d1,(a1)+
[00011210] 22c2                      move.l     d2,(a1)+
[00011212] 22c3                      move.l     d3,(a1)+
[00011214] 22c4                      move.l     d4,(a1)+
[00011216] 22c5                      move.l     d5,(a1)+
[00011218] 22c6                      move.l     d6,(a1)+
[0001121a] 22c7                      move.l     d7,(a1)+
[0001121c] 22ca                      move.l     a2,(a1)+
[0001121e] 22cb                      move.l     a3,(a1)+
[00011220] 22cc                      move.l     a4,(a1)+
[00011222] 22cd                      move.l     a5,(a1)+
[00011224] 22ce                      move.l     a6,(a1)+
[00011226] 22d8                      move.l     (a0)+,(a1)+
[00011228] 22d8                      move.l     (a0)+,(a1)+
[0001122a] 22d8                      move.l     (a0)+,(a1)+
[0001122c] 22d8                      move.l     (a0)+,(a1)+
[0001122e] 51c8 ffda                 dbf        d0,$0001120A
[00011232] 90ef 000a                 suba.w     10(a7),a0
[00011236] d2ef 000c                 adda.w     12(a7),a1
[0001123a] 302f 0008                 move.w     8(a7),d0
[0001123e] 4efb 0002                 jmp        $00011242(pc,d0.w)
[00011242] 2320                      move.l     -(a0),-(a1)
[00011244] 2320                      move.l     -(a0),-(a1)
[00011246] 2320                      move.l     -(a0),-(a1)
[00011248] 2320                      move.l     -(a0),-(a1)
[0001124a] 230e                      move.l     a6,-(a1)
[0001124c] 230d                      move.l     a5,-(a1)
[0001124e] 230c                      move.l     a4,-(a1)
[00011250] 230b                      move.l     a3,-(a1)
[00011252] 230a                      move.l     a2,-(a1)
[00011254] 2307                      move.l     d7,-(a1)
[00011256] 2306                      move.l     d6,-(a1)
[00011258] 2305                      move.l     d5,-(a1)
[0001125a] 2304                      move.l     d4,-(a1)
[0001125c] 2303                      move.l     d3,-(a1)
[0001125e] 2302                      move.l     d2,-(a1)
[00011260] 2301                      move.l     d1,-(a1)
[00011262] d3ef 000e                 adda.l     14(a7),a1
[00011266] 4840                      swap       d0
[00011268] 51c8 ff6e                 dbf        d0,$000111D8
[0001126c] 41e8 0010                 lea.l      16(a0),a0
[00011270] 226f 0012                 movea.l    18(a7),a1
[00011274] d3ef 0016                 adda.l     22(a7),a1
[00011278] 536f 0002                 subq.w     #1,2(a7)
[0001127c] 536f 001a                 subq.w     #1,26(a7)
[00011280] 6a00 ff34                 bpl        $000111B6
[00011284] 4fef 001e                 lea.l      30(a7),a7
[00011288] 4e75                      rts
[0001128a] 266f 0016                 movea.l    22(a7),a3
[0001128e] 4fef 001e                 lea.l      30(a7),a7
[00011292] 720f                      moveq.l    #15,d1
[00011294] 9c80                      sub.l      d0,d6
[00011296] 2e06                      move.l     d6,d7
[00011298] de87                      add.l      d7,d7
[0001129a] de87                      add.l      d7,d7
[0001129c] 97c7                      suba.l     d7,a3
[0001129e] b386                      eor.l      d1,d6
[000112a0] dc86                      add.l      d6,d6
[000112a2] 45fb 601c                 lea.l      $000112C0(pc,d6.w),a2
[000112a6] c041                      and.w      d1,d0
[000112a8] d040                      add.w      d0,d0
[000112aa] d040                      add.w      d0,d0
[000112ac] d0c0                      adda.w     d0,a0
[000112ae] 2848                      movea.l    a0,a4
[000112b0] 41e8 0040                 lea.l      64(a0),a0
[000112b4] 51c9 0008                 dbf        d1,$000112BE
[000112b8] 720f                      moveq.l    #15,d1
[000112ba] 41e8 fc00                 lea.l      -1024(a0),a0
[000112be] 4ed2                      jmp        (a2)
[000112c0] 22dc                      move.l     (a4)+,(a1)+
[000112c2] 22dc                      move.l     (a4)+,(a1)+
[000112c4] 22dc                      move.l     (a4)+,(a1)+
[000112c6] 22dc                      move.l     (a4)+,(a1)+
[000112c8] 22dc                      move.l     (a4)+,(a1)+
[000112ca] 22dc                      move.l     (a4)+,(a1)+
[000112cc] 22dc                      move.l     (a4)+,(a1)+
[000112ce] 22dc                      move.l     (a4)+,(a1)+
[000112d0] 22dc                      move.l     (a4)+,(a1)+
[000112d2] 22dc                      move.l     (a4)+,(a1)+
[000112d4] 22dc                      move.l     (a4)+,(a1)+
[000112d6] 22dc                      move.l     (a4)+,(a1)+
[000112d8] 22dc                      move.l     (a4)+,(a1)+
[000112da] 22dc                      move.l     (a4)+,(a1)+
[000112dc] 22dc                      move.l     (a4)+,(a1)+
[000112de] 229c                      move.l     (a4)+,(a1)
[000112e0] d3cb                      adda.l     a3,a1
[000112e2] 51cb ffca                 dbf        d3,$000112AE
[000112e6] 4e75                      rts
[000112e8] 5547                      subq.w     #2,d7
[000112ea] 6d00 01fa                 blt        $000114E6
[000112ee] 6600 01b2                 bne        $000114A2
[000112f2] 3e2e 00c0                 move.w     192(a6),d7
[000112f6] 6700 015c                 beq        $00011454
[000112fa] 5347                      subq.w     #1,d7
[000112fc] 6700 0158                 beq        $00011456
[00011300] 5347                      subq.w     #1,d7
[00011302] 660a                      bne.s      $0001130E
[00011304] 0c6e 0008 00c2            cmpi.w     #$0008,194(a6)
[0001130a] 6700 014a                 beq        $00011456
[0001130e] 2f06                      move.l     d6,-(a7)
[00011310] 4dfa 103a                 lea.l      $0001234C(pc),a6
[00011314] 2a48                      movea.l    a0,a5
[00011316] 7c1f                      moveq.l    #31,d6
[00011318] d26e 01b8                 add.w      440(a6),d1
[0001131c] d241                      add.w      d1,d1
[0001131e] c246                      and.w      d6,d1
[00011320] 672c                      beq.s      $0001134E
[00011322] 264c                      movea.l    a4,a3
[00011324] d6c1                      adda.w     d1,a3
[00011326] 3c01                      move.w     d1,d6
[00011328] 0a41 001f                 eori.w     #$001F,d1
[0001132c] 5346                      subq.w     #1,d6
[0001132e] 7e00                      moveq.l    #0,d7
[00011330] 1e1b                      move.b     (a3)+,d7
[00011332] 4607                      not.b      d7
[00011334] eb4f                      lsl.w      #5,d7
[00011336] 45f6 7000                 lea.l      0(a6,d7.w),a2
[0001133a] 2ada                      move.l     (a2)+,(a5)+
[0001133c] 2ada                      move.l     (a2)+,(a5)+
[0001133e] 2ada                      move.l     (a2)+,(a5)+
[00011340] 2ada                      move.l     (a2)+,(a5)+
[00011342] 2ada                      move.l     (a2)+,(a5)+
[00011344] 2ada                      move.l     (a2)+,(a5)+
[00011346] 2ada                      move.l     (a2)+,(a5)+
[00011348] 2ada                      move.l     (a2)+,(a5)+
[0001134a] 51c9 ffe2                 dbf        d1,$0001132E
[0001134e] 7e00                      moveq.l    #0,d7
[00011350] 1e1c                      move.b     (a4)+,d7
[00011352] 4607                      not.b      d7
[00011354] eb4f                      lsl.w      #5,d7
[00011356] 45f6 7000                 lea.l      0(a6,d7.w),a2
[0001135a] 2ada                      move.l     (a2)+,(a5)+
[0001135c] 2ada                      move.l     (a2)+,(a5)+
[0001135e] 2ada                      move.l     (a2)+,(a5)+
[00011360] 2ada                      move.l     (a2)+,(a5)+
[00011362] 2ada                      move.l     (a2)+,(a5)+
[00011364] 2ada                      move.l     (a2)+,(a5)+
[00011366] 2ada                      move.l     (a2)+,(a5)+
[00011368] 2ada                      move.l     (a2)+,(a5)+
[0001136a] 51ce ffe2                 dbf        d6,$0001134E
[0001136e] 265f                      movea.l    (a7)+,a3
[00011370] 2c02                      move.l     d2,d6
[00011372] e88a                      lsr.l      #4,d2
[00011374] 2800                      move.l     d0,d4
[00011376] e88c                      lsr.l      #4,d4
[00011378] 9484                      sub.l      d4,d2
[0001137a] 720f                      moveq.l    #15,d1
[0001137c] 2e06                      move.l     d6,d7
[0001137e] 9e80                      sub.l      d0,d7
[00011380] de87                      add.l      d7,d7
[00011382] de87                      add.l      d7,d7
[00011384] 5887                      addq.l     #4,d7
[00011386] 97c7                      suba.l     d7,a3
[00011388] c041                      and.w      d1,d0
[0001138a] d040                      add.w      d0,d0
[0001138c] d040                      add.w      d0,d0
[0001138e] d0c0                      adda.w     d0,a0
[00011390] 5342                      subq.w     #1,d2
[00011392] 6a0c                      bpl.s      $000113A0
[00011394] 5947                      subq.w     #4,d7
[00011396] 0a47 003c                 eori.w     #$003C,d7
[0001139a] 45fb 7072                 lea.l      $0001140E(pc,d7.w),a2
[0001139e] 6010                      bra.s      $000113B0
[000113a0] 45fb 0022                 lea.l      $000113C4(pc,d0.w),a2
[000113a4] cc41                      and.w      d1,d6
[000113a6] b346                      eor.w      d1,d6
[000113a8] dc46                      add.w      d6,d6
[000113aa] dc46                      add.w      d6,d6
[000113ac] 4bfb 6060                 lea.l      $0001140E(pc,d6.w),a5
[000113b0] 2848                      movea.l    a0,a4
[000113b2] 41e8 0040                 lea.l      64(a0),a0
[000113b6] 51c9 0008                 dbf        d1,$000113C0
[000113ba] 720f                      moveq.l    #15,d1
[000113bc] 41e8 fc00                 lea.l      -1024(a0),a0
[000113c0] 3802                      move.w     d2,d4
[000113c2] 4ed2                      jmp        (a2)
[000113c4] 201c                      move.l     (a4)+,d0
[000113c6] b199                      eor.l      d0,(a1)+
[000113c8] 201c                      move.l     (a4)+,d0
[000113ca] b199                      eor.l      d0,(a1)+
[000113cc] 201c                      move.l     (a4)+,d0
[000113ce] b199                      eor.l      d0,(a1)+
[000113d0] 201c                      move.l     (a4)+,d0
[000113d2] b199                      eor.l      d0,(a1)+
[000113d4] 201c                      move.l     (a4)+,d0
[000113d6] b199                      eor.l      d0,(a1)+
[000113d8] 201c                      move.l     (a4)+,d0
[000113da] b199                      eor.l      d0,(a1)+
[000113dc] 201c                      move.l     (a4)+,d0
[000113de] b199                      eor.l      d0,(a1)+
[000113e0] 201c                      move.l     (a4)+,d0
[000113e2] b199                      eor.l      d0,(a1)+
[000113e4] 201c                      move.l     (a4)+,d0
[000113e6] b199                      eor.l      d0,(a1)+
[000113e8] 201c                      move.l     (a4)+,d0
[000113ea] b199                      eor.l      d0,(a1)+
[000113ec] 201c                      move.l     (a4)+,d0
[000113ee] b199                      eor.l      d0,(a1)+
[000113f0] 201c                      move.l     (a4)+,d0
[000113f2] b199                      eor.l      d0,(a1)+
[000113f4] 201c                      move.l     (a4)+,d0
[000113f6] b199                      eor.l      d0,(a1)+
[000113f8] 201c                      move.l     (a4)+,d0
[000113fa] b199                      eor.l      d0,(a1)+
[000113fc] 201c                      move.l     (a4)+,d0
[000113fe] b199                      eor.l      d0,(a1)+
[00011400] 201c                      move.l     (a4)+,d0
[00011402] b199                      eor.l      d0,(a1)+
[00011404] 49ec ffc0                 lea.l      -64(a4),a4
[00011408] 51cc ffba                 dbf        d4,$000113C4
[0001140c] 4ed5                      jmp        (a5)
[0001140e] 201c                      move.l     (a4)+,d0
[00011410] b199                      eor.l      d0,(a1)+
[00011412] 201c                      move.l     (a4)+,d0
[00011414] b199                      eor.l      d0,(a1)+
[00011416] 201c                      move.l     (a4)+,d0
[00011418] b199                      eor.l      d0,(a1)+
[0001141a] 201c                      move.l     (a4)+,d0
[0001141c] b199                      eor.l      d0,(a1)+
[0001141e] 201c                      move.l     (a4)+,d0
[00011420] b199                      eor.l      d0,(a1)+
[00011422] 201c                      move.l     (a4)+,d0
[00011424] b199                      eor.l      d0,(a1)+
[00011426] 201c                      move.l     (a4)+,d0
[00011428] b199                      eor.l      d0,(a1)+
[0001142a] 201c                      move.l     (a4)+,d0
[0001142c] b199                      eor.l      d0,(a1)+
[0001142e] 201c                      move.l     (a4)+,d0
[00011430] b199                      eor.l      d0,(a1)+
[00011432] 201c                      move.l     (a4)+,d0
[00011434] b199                      eor.l      d0,(a1)+
[00011436] 201c                      move.l     (a4)+,d0
[00011438] b199                      eor.l      d0,(a1)+
[0001143a] 201c                      move.l     (a4)+,d0
[0001143c] b199                      eor.l      d0,(a1)+
[0001143e] 201c                      move.l     (a4)+,d0
[00011440] b199                      eor.l      d0,(a1)+
[00011442] 201c                      move.l     (a4)+,d0
[00011444] b199                      eor.l      d0,(a1)+
[00011446] 201c                      move.l     (a4)+,d0
[00011448] b199                      eor.l      d0,(a1)+
[0001144a] 201c                      move.l     (a4)+,d0
[0001144c] b199                      eor.l      d0,(a1)+
[0001144e] d3cb                      adda.l     a3,a1
[00011450] 51cb ff5e                 dbf        d3,$000113B0
[00011454] 4e75                      rts
[00011456] 9480                      sub.l      d0,d2
[00011458] 2202                      move.l     d2,d1
[0001145a] 5281                      addq.l     #1,d1
[0001145c] d281                      add.l      d1,d1
[0001145e] d281                      add.l      d1,d1
[00011460] 9c81                      sub.l      d1,d6
[00011462] 700f                      moveq.l    #15,d0
[00011464] c042                      and.w      d2,d0
[00011466] e84a                      lsr.w      #4,d2
[00011468] 0a40 000f                 eori.w     #$000F,d0
[0001146c] d040                      add.w      d0,d0
[0001146e] 41fb 0006                 lea.l      $00011476(pc,d0.w),a0
[00011472] 3002                      move.w     d2,d0
[00011474] 4ed0                      jmp        (a0)
[00011476] 4699                      not.l      (a1)+
[00011478] 4699                      not.l      (a1)+
[0001147a] 4699                      not.l      (a1)+
[0001147c] 4699                      not.l      (a1)+
[0001147e] 4699                      not.l      (a1)+
[00011480] 4699                      not.l      (a1)+
[00011482] 4699                      not.l      (a1)+
[00011484] 4699                      not.l      (a1)+
[00011486] 4699                      not.l      (a1)+
[00011488] 4699                      not.l      (a1)+
[0001148a] 4699                      not.l      (a1)+
[0001148c] 4699                      not.l      (a1)+
[0001148e] 4699                      not.l      (a1)+
[00011490] 4699                      not.l      (a1)+
[00011492] 4699                      not.l      (a1)+
[00011494] 4699                      not.l      (a1)+
[00011496] 51c8 ffde                 dbf        d0,$00011476
[0001149a] d3c6                      adda.l     d6,a1
[0001149c] 51cb ffd4                 dbf        d3,$00011472
[000114a0] 4e75                      rts
[000114a2] 2a2e 00f6                 move.l     246(a6),d5
[000114a6] 9440                      sub.w      d0,d2
[000114a8] 2f06                      move.l     d6,-(a7)
[000114aa] e98e                      lsl.l      #4,d6
[000114ac] 2646                      movea.l    d6,a3
[000114ae] 2a48                      movea.l    a0,a5
[000114b0] 780f                      moveq.l    #15,d4
[000114b2] 7c0f                      moveq.l    #15,d6
[000114b4] c044                      and.w      d4,d0
[000114b6] d26e 01b8                 add.w      440(a6),d1
[000114ba] c244                      and.w      d4,d1
[000114bc] 671a                      beq.s      $000114D8
[000114be] 3e01                      move.w     d1,d7
[000114c0] bd47                      eor.w      d6,d7
[000114c2] 3c01                      move.w     d1,d6
[000114c4] 5346                      subq.w     #1,d6
[000114c6] d241                      add.w      d1,d1
[000114c8] 45f4 1000                 lea.l      0(a4,d1.w),a2
[000114cc] 321a                      move.w     (a2)+,d1
[000114ce] 4641                      not.w      d1
[000114d0] e179                      rol.w      d0,d1
[000114d2] 3ac1                      move.w     d1,(a5)+
[000114d4] 51cf fff6                 dbf        d7,$000114CC
[000114d8] 321c                      move.w     (a4)+,d1
[000114da] 4641                      not.w      d1
[000114dc] e179                      rol.w      d0,d1
[000114de] 3ac1                      move.w     d1,(a5)+
[000114e0] 51ce fff6                 dbf        d6,$000114D8
[000114e4] 603e                      bra.s      $00011524
[000114e6] 2a2e 00f2                 move.l     242(a6),d5
[000114ea] 9440                      sub.w      d0,d2
[000114ec] 2f06                      move.l     d6,-(a7)
[000114ee] e98e                      lsl.l      #4,d6
[000114f0] 2646                      movea.l    d6,a3
[000114f2] 2a48                      movea.l    a0,a5
[000114f4] 780f                      moveq.l    #15,d4
[000114f6] 7c0f                      moveq.l    #15,d6
[000114f8] c044                      and.w      d4,d0
[000114fa] d26e 01b8                 add.w      440(a6),d1
[000114fe] c244                      and.w      d4,d1
[00011500] 6718                      beq.s      $0001151A
[00011502] 3e01                      move.w     d1,d7
[00011504] bd47                      eor.w      d6,d7
[00011506] 3c01                      move.w     d1,d6
[00011508] 5346                      subq.w     #1,d6
[0001150a] d241                      add.w      d1,d1
[0001150c] 45f4 1000                 lea.l      0(a4,d1.w),a2
[00011510] 321a                      move.w     (a2)+,d1
[00011512] e179                      rol.w      d0,d1
[00011514] 3ac1                      move.w     d1,(a5)+
[00011516] 51cf fff8                 dbf        d7,$00011510
[0001151a] 321c                      move.w     (a4)+,d1
[0001151c] e179                      rol.w      d0,d1
[0001151e] 3ac1                      move.w     d1,(a5)+
[00011520] 51ce fff8                 dbf        d6,$0001151A
[00011524] 2e05                      move.l     d5,d7
[00011526] b644                      cmp.w      d4,d3
[00011528] 6c02                      bge.s      $0001152C
[0001152a] 3803                      move.w     d3,d4
[0001152c] 4843                      swap       d3
[0001152e] 3604                      move.w     d4,d3
[00011530] 347c 0040                 movea.w    #$0040,a2
[00011534] 7c0f                      moveq.l    #15,d6
[00011536] b486                      cmp.l      d6,d2
[00011538] 6c02                      bge.s      $0001153C
[0001153a] 2c02                      move.l     d2,d6
[0001153c] 2846                      movea.l    d6,a4
[0001153e] 9486                      sub.l      d6,d2
[00011540] 5286                      addq.l     #1,d6
[00011542] dc86                      add.l      d6,d6
[00011544] dc86                      add.l      d6,d6
[00011546] 97c6                      suba.l     d6,a3
[00011548] 4843                      swap       d3
[0001154a] 3203                      move.w     d3,d1
[0001154c] e849                      lsr.w      #4,d1
[0001154e] 2a49                      movea.l    a1,a5
[00011550] 2c0c                      move.l     a4,d6
[00011552] 3010                      move.w     (a0),d0
[00011554] d040                      add.w      d0,d0
[00011556] 645e                      bcc.s      $000115B6
[00011558] 3802                      move.w     d2,d4
[0001155a] d846                      add.w      d6,d4
[0001155c] e84c                      lsr.w      #4,d4
[0001155e] 3a04                      move.w     d4,d5
[00011560] e84c                      lsr.w      #4,d4
[00011562] 4645                      not.w      d5
[00011564] 0245 000f                 andi.w     #$000F,d5
[00011568] da45                      add.w      d5,d5
[0001156a] da45                      add.w      d5,d5
[0001156c] 2c4d                      movea.l    a5,a6
[0001156e] 4efb 5002                 jmp        $00011572(pc,d5.w)
[00011572] 2c87                      move.l     d7,(a6)
[00011574] dcca                      adda.w     a2,a6
[00011576] 2c87                      move.l     d7,(a6)
[00011578] dcca                      adda.w     a2,a6
[0001157a] 2c87                      move.l     d7,(a6)
[0001157c] dcca                      adda.w     a2,a6
[0001157e] 2c87                      move.l     d7,(a6)
[00011580] dcca                      adda.w     a2,a6
[00011582] 2c87                      move.l     d7,(a6)
[00011584] dcca                      adda.w     a2,a6
[00011586] 2c87                      move.l     d7,(a6)
[00011588] dcca                      adda.w     a2,a6
[0001158a] 2c87                      move.l     d7,(a6)
[0001158c] dcca                      adda.w     a2,a6
[0001158e] 2c87                      move.l     d7,(a6)
[00011590] dcca                      adda.w     a2,a6
[00011592] 2c87                      move.l     d7,(a6)
[00011594] dcca                      adda.w     a2,a6
[00011596] 2c87                      move.l     d7,(a6)
[00011598] dcca                      adda.w     a2,a6
[0001159a] 2c87                      move.l     d7,(a6)
[0001159c] dcca                      adda.w     a2,a6
[0001159e] 2c87                      move.l     d7,(a6)
[000115a0] dcca                      adda.w     a2,a6
[000115a2] 2c87                      move.l     d7,(a6)
[000115a4] dcca                      adda.w     a2,a6
[000115a6] 2c87                      move.l     d7,(a6)
[000115a8] dcca                      adda.w     a2,a6
[000115aa] 2c87                      move.l     d7,(a6)
[000115ac] dcca                      adda.w     a2,a6
[000115ae] 2c87                      move.l     d7,(a6)
[000115b0] dcca                      adda.w     a2,a6
[000115b2] 51cc ffbe                 dbf        d4,$00011572
[000115b6] 588d                      addq.l     #4,a5
[000115b8] 51ce ff9a                 dbf        d6,$00011554
[000115bc] dbcb                      adda.l     a3,a5
[000115be] 51c9 ff90                 dbf        d1,$00011550
[000115c2] 5488                      addq.l     #2,a0
[000115c4] d3d7                      adda.l     (a7),a1
[000115c6] 5343                      subq.w     #1,d3
[000115c8] 4843                      swap       d3
[000115ca] 51cb ff7c                 dbf        d3,$00011548
[000115ce] 588f                      addq.l     #4,a7
[000115d0] 4e75                      rts
[000115d2] 7c00                      moveq.l    #0,d6
[000115d4] 3c0a                      move.w     a2,d6
[000115d6] 2446                      movea.l    d6,a2
[000115d8] 4a6e 01b2                 tst.w      434(a6)
[000115dc] 6724                      beq.s      $00011602
[000115de] 226e 01ae                 movea.l    430(a6),a1
[000115e2] 3c2e 01b2                 move.w     434(a6),d6
[000115e6] 2646                      movea.l    d6,a3
[000115e8] 946e 01b6                 sub.w      438(a6),d2
[000115ec] 966e 01b8                 sub.w      440(a6),d3
[000115f0] 3d6e 003c 01ee            move.w     60(a6),494(a6)
[000115f6] 426e 01c8                 clr.w      456(a6)
[000115fa] 3d6e 01b4 01dc            move.w     436(a6),476(a6)
[00011600] 6032                      bra.s      $00011634
[00011602] 2278 044e                 movea.l    ($0000044E).w,a1
[00011606] 3c38 206e                 move.w     ($0000206E).w,d6
[0001160a] 2646                      movea.l    d6,a3
[0001160c] 3d6e 003c 01ee            move.w     60(a6),494(a6)
[00011612] 426e 01c8                 clr.w      456(a6)
[00011616] 3d6e 01b4 01dc            move.w     436(a6),476(a6)
[0001161c] 6016                      bra.s      $00011634
[0001161e] 7c00                      moveq.l    #0,d6
[00011620] 206e 01c2                 movea.l    450(a6),a0
[00011624] 226e 01d6                 movea.l    470(a6),a1
[00011628] 3c2e 01c6                 move.w     454(a6),d6
[0001162c] 2446                      movea.l    d6,a2
[0001162e] 3c2e 01da                 move.w     474(a6),d6
[00011632] 2646                      movea.l    d6,a3
[00011634] 48c0                      ext.l      d0
[00011636] 48c1                      ext.l      d1
[00011638] 48c2                      ext.l      d2
[0001163a] 48c3                      ext.l      d3
[0001163c] 48c4                      ext.l      d4
[0001163e] 48c5                      ext.l      d5
[00011640] 2c0a                      move.l     a2,d6
[00011642] 2e0b                      move.l     a3,d7
[00011644] c2c6                      mulu.w     d6,d1
[00011646] d1c1                      adda.l     d1,a0
[00011648] 2200                      move.l     d0,d1
[0001164a] e889                      lsr.l      #4,d1
[0001164c] d281                      add.l      d1,d1
[0001164e] d1c1                      adda.l     d1,a0
[00011650] c6c7                      mulu.w     d7,d3
[00011652] d3c3                      adda.l     d3,a1
[00011654] d482                      add.l      d2,d2
[00011656] d482                      add.l      d2,d2
[00011658] d3c2                      adda.l     d2,a1
[0001165a] 720f                      moveq.l    #15,d1
[0001165c] c081                      and.l      d1,d0
[0001165e] b181                      eor.l      d0,d1
[00011660] b881                      cmp.l      d1,d4
[00011662] 6c02                      bge.s      $00011666
[00011664] 2204                      move.l     d4,d1
[00011666] 2400                      move.l     d0,d2
[00011668] 4840                      swap       d0
[0001166a] 3001                      move.w     d1,d0
[0001166c] 4840                      swap       d0
[0001166e] d484                      add.l      d4,d2
[00011670] e88a                      lsr.l      #4,d2
[00011672] d482                      add.l      d2,d2
[00011674] 5482                      addq.l     #2,d2
[00011676] 95c2                      suba.l     d2,a2
[00011678] 2404                      move.l     d4,d2
[0001167a] d482                      add.l      d2,d2
[0001167c] d482                      add.l      d2,d2
[0001167e] 5882                      addq.l     #4,d2
[00011680] 97c2                      suba.l     d2,a3
[00011682] 9881                      sub.l      d1,d4
[00011684] 2c2e 00f2                 move.l     242(a6),d6
[00011688] 2e2e 00f6                 move.l     246(a6),d7
[0001168c] 7403                      moveq.l    #3,d2
[0001168e] c46e 01ee                 and.w      494(a6),d2
[00011692] d442                      add.w      d2,d2
[00011694] 343b 2006                 move.w     $0001169C(pc,d2.w),d2
[00011698] 4efb 2002                 jmp        $0001169C(pc,d2.w)
J4:
[0001169c] 0008                      dc.w $0008   ; $000116a4-J4
[0001169e] 003e                      dc.w $003e   ; $000116da-J4
[000116a0] 0074                      dc.w $0074   ; $00011710-J4
[000116a2] 00aa                      dc.w $00aa   ; $00011746-J4
[000116a4] 3604                      move.w     d4,d3
[000116a6] 3418                      move.w     (a0)+,d2
[000116a8] e17a                      rol.w      d0,d2
[000116aa] 2200                      move.l     d0,d1
[000116ac] 4841                      swap       d1
[000116ae] 6002                      bra.s      $000116B2
[000116b0] 3418                      move.w     (a0)+,d2
[000116b2] d442                      add.w      d2,d2
[000116b4] 6408                      bcc.s      $000116BE
[000116b6] 22c6                      move.l     d6,(a1)+
[000116b8] 51c9 fff8                 dbf        d1,$000116B2
[000116bc] 6006                      bra.s      $000116C4
[000116be] 22c7                      move.l     d7,(a1)+
[000116c0] 51c9 fff0                 dbf        d1,$000116B2
[000116c4] 720f                      moveq.l    #15,d1
[000116c6] 5343                      subq.w     #1,d3
[000116c8] 9641                      sub.w      d1,d3
[000116ca] 6ae4                      bpl.s      $000116B0
[000116cc] d243                      add.w      d3,d1
[000116ce] 6ae0                      bpl.s      $000116B0
[000116d0] d1ca                      adda.l     a2,a0
[000116d2] d3cb                      adda.l     a3,a1
[000116d4] 51cd ffce                 dbf        d5,$000116A4
[000116d8] 4e75                      rts
[000116da] 3604                      move.w     d4,d3
[000116dc] 3418                      move.w     (a0)+,d2
[000116de] e17a                      rol.w      d0,d2
[000116e0] 2200                      move.l     d0,d1
[000116e2] 4841                      swap       d1
[000116e4] 6002                      bra.s      $000116E8
[000116e6] 3418                      move.w     (a0)+,d2
[000116e8] d442                      add.w      d2,d2
[000116ea] 6408                      bcc.s      $000116F4
[000116ec] 22c6                      move.l     d6,(a1)+
[000116ee] 51c9 fff8                 dbf        d1,$000116E8
[000116f2] 6006                      bra.s      $000116FA
[000116f4] 5889                      addq.l     #4,a1
[000116f6] 51c9 fff0                 dbf        d1,$000116E8
[000116fa] 720f                      moveq.l    #15,d1
[000116fc] 5343                      subq.w     #1,d3
[000116fe] 9641                      sub.w      d1,d3
[00011700] 6ae4                      bpl.s      $000116E6
[00011702] d243                      add.w      d3,d1
[00011704] 6ae0                      bpl.s      $000116E6
[00011706] d1ca                      adda.l     a2,a0
[00011708] d3cb                      adda.l     a3,a1
[0001170a] 51cd ffce                 dbf        d5,$000116DA
[0001170e] 4e75                      rts
[00011710] 3604                      move.w     d4,d3
[00011712] 3418                      move.w     (a0)+,d2
[00011714] e17a                      rol.w      d0,d2
[00011716] 2200                      move.l     d0,d1
[00011718] 4841                      swap       d1
[0001171a] 6002                      bra.s      $0001171E
[0001171c] 3418                      move.w     (a0)+,d2
[0001171e] d442                      add.w      d2,d2
[00011720] 6408                      bcc.s      $0001172A
[00011722] 4699                      not.l      (a1)+
[00011724] 51c9 fff8                 dbf        d1,$0001171E
[00011728] 6006                      bra.s      $00011730
[0001172a] 5889                      addq.l     #4,a1
[0001172c] 51c9 fff0                 dbf        d1,$0001171E
[00011730] 720f                      moveq.l    #15,d1
[00011732] 5343                      subq.w     #1,d3
[00011734] 9641                      sub.w      d1,d3
[00011736] 6ae4                      bpl.s      $0001171C
[00011738] d243                      add.w      d3,d1
[0001173a] 6ae0                      bpl.s      $0001171C
[0001173c] d1ca                      adda.l     a2,a0
[0001173e] d3cb                      adda.l     a3,a1
[00011740] 51cd ffce                 dbf        d5,$00011710
[00011744] 4e75                      rts
[00011746] 3604                      move.w     d4,d3
[00011748] 3418                      move.w     (a0)+,d2
[0001174a] e17a                      rol.w      d0,d2
[0001174c] 2200                      move.l     d0,d1
[0001174e] 4841                      swap       d1
[00011750] 6002                      bra.s      $00011754
[00011752] 3418                      move.w     (a0)+,d2
[00011754] d442                      add.w      d2,d2
[00011756] 6508                      bcs.s      $00011760
[00011758] 22c7                      move.l     d7,(a1)+
[0001175a] 51c9 fff8                 dbf        d1,$00011754
[0001175e] 6006                      bra.s      $00011766
[00011760] 5889                      addq.l     #4,a1
[00011762] 51c9 fff0                 dbf        d1,$00011754
[00011766] 720f                      moveq.l    #15,d1
[00011768] 5343                      subq.w     #1,d3
[0001176a] 9641                      sub.w      d1,d3
[0001176c] 6ae4                      bpl.s      $00011752
[0001176e] d243                      add.w      d3,d1
[00011770] 6ae0                      bpl.s      $00011752
[00011772] d1ca                      adda.l     a2,a0
[00011774] d3cb                      adda.l     a3,a1
[00011776] 51cd ffce                 dbf        d5,$00011746
[0001177a] 4e75                      rts
[0001177c] 48c0                      ext.l      d0
[0001177e] 48c1                      ext.l      d1
[00011780] 48c2                      ext.l      d2
[00011782] 48c3                      ext.l      d3
[00011784] 48c4                      ext.l      d4
[00011786] 48c5                      ext.l      d5
[00011788] 48c6                      ext.l      d6
[0001178a] 48c7                      ext.l      d7
[0001178c] bc84                      cmp.l      d4,d6
[0001178e] 6600 0692                 bne        $00011E22
[00011792] be85                      cmp.l      d5,d7
[00011794] 6600 068c                 bne        $00011E22
[00011798] 08ae 0004 01ef            bclr       #4,495(a6)
[0001179e] 6600 fe7e                 bne        $0001161E
[000117a2] 7e0f                      moveq.l    #15,d7
[000117a4] ce6e 01ee                 and.w      494(a6),d7
[000117a8] 206e 01c2                 movea.l    450(a6),a0
[000117ac] 226e 01d6                 movea.l    470(a6),a1
[000117b0] 7c00                      moveq.l    #0,d6
[000117b2] 3c2e 01c6                 move.w     454(a6),d6
[000117b6] 2446                      movea.l    d6,a2
[000117b8] 3c2e 01da                 move.w     474(a6),d6
[000117bc] 2646                      movea.l    d6,a3
[000117be] 3c2e 01c8                 move.w     456(a6),d6
[000117c2] bc6e 01dc                 cmp.w      476(a6),d6
[000117c6] 6600 00a4                 bne        $0001186C
[000117ca] 2c0a                      move.l     a2,d6
[000117cc] c2c6                      mulu.w     d6,d1
[000117ce] d080                      add.l      d0,d0
[000117d0] d080                      add.l      d0,d0
[000117d2] d280                      add.l      d0,d1
[000117d4] e480                      asr.l      #2,d0
[000117d6] d1c1                      adda.l     d1,a0
[000117d8] 2c0b                      move.l     a3,d6
[000117da] c6c6                      mulu.w     d6,d3
[000117dc] d482                      add.l      d2,d2
[000117de] d482                      add.l      d2,d2
[000117e0] d682                      add.l      d2,d3
[000117e2] e482                      asr.l      #2,d2
[000117e4] d3c3                      adda.l     d3,a1
[000117e6] b1c9                      cmpa.l     a1,a0
[000117e8] 6200 02c4                 bhi        $00011AAE
[000117ec] 3c3c 8401                 move.w     #$8401,d6
[000117f0] 0f06                      btst       d7,d6
[000117f2] 6600 02ba                 bne        $00011AAE
[000117f6] 2c0a                      move.l     a2,d6
[000117f8] ccc5                      mulu.w     d5,d6
[000117fa] 2848                      movea.l    a0,a4
[000117fc] d9c6                      adda.l     d6,a4
[000117fe] d884                      add.l      d4,d4
[00011800] d884                      add.l      d4,d4
[00011802] d9c4                      adda.l     d4,a4
[00011804] e48c                      lsr.l      #2,d4
[00011806] b9c9                      cmpa.l     a1,a4
[00011808] 6500 02a4                 bcs        $00011AAE
[0001180c] 588c                      addq.l     #4,a4
[0001180e] d28c                      add.l      a4,d1
[00011810] 9288                      sub.l      a0,d1
[00011812] 2a49                      movea.l    a1,a5
[00011814] 2c0b                      move.l     a3,d6
[00011816] ccc5                      mulu.w     d5,d6
[00011818] dbc6                      adda.l     d6,a5
[0001181a] d884                      add.l      d4,d4
[0001181c] d884                      add.l      d4,d4
[0001181e] dbc4                      adda.l     d4,a5
[00011820] e48c                      lsr.l      #2,d4
[00011822] 588d                      addq.l     #4,a5
[00011824] d68d                      add.l      a5,d3
[00011826] 9689                      sub.l      a1,d3
[00011828] c14c                      exg        a0,a4
[0001182a] c34d                      exg        a1,a5
[0001182c] 2c04                      move.l     d4,d6
[0001182e] 5286                      addq.l     #1,d6
[00011830] dc86                      add.l      d6,d6
[00011832] dc86                      add.l      d6,d6
[00011834] 95c6                      suba.l     d6,a2
[00011836] 97c6                      suba.l     d6,a3
[00011838] 7203                      moveq.l    #3,d1
[0001183a] c284                      and.l      d4,d1
[0001183c] 0a41 0003                 eori.w     #$0003,d1
[00011840] d281                      add.l      d1,d1
[00011842] e484                      asr.l      #2,d4
[00011844] 4a44                      tst.w      d4
[00011846] 6a04                      bpl.s      $0001184C
[00011848] 7800                      moveq.l    #0,d4
[0001184a] 7208                      moveq.l    #8,d1
[0001184c] de47                      add.w      d7,d7
[0001184e] de47                      add.w      d7,d7
[00011850] 49fb 701c                 lea.l      $0001186E(pc,d7.w),a4
[00011854] 3e1c                      move.w     (a4)+,d7
[00011856] 670e                      beq.s      $00011866
[00011858] 5347                      subq.w     #1,d7
[0001185a] 6708                      beq.s      $00011864
[0001185c] 3e01                      move.w     d1,d7
[0001185e] d241                      add.w      d1,d1
[00011860] d247                      add.w      d7,d1
[00011862] 6002                      bra.s      $00011866
[00011864] d241                      add.w      d1,d1
[00011866] 3e1c                      move.w     (a4)+,d7
[00011868] 4efb 7004                 jmp        $0001186E(pc,d7.w)
[0001186c] 4e75                      rts
[0001186e] 0000 0374                 ori.b      #$74,d0
[00011872] 0001 0040                 ori.b      #$40,d1
[00011876] 0002 0066                 ori.b      #$66,d2
[0001187a] 0000 0094                 ori.b      #$94,d0
[0001187e] 0002 00b2                 ori.b      #$B2,d2
[00011882] 0000 00de                 ori.b      #$DE,d0
[00011886] 0001 00e0                 ori.b      #$E0,d1
[0001188a] 0001 0106                 ori.b      #$06,d1
[0001188e] 0002 012c                 ori.b      #$2C,d2
[00011892] 0002 015a                 ori.b      #$5A,d2
[00011896] 0000 04da                 ori.b      #$DA,d0
[0001189a] 0002 0188                 ori.b      #$88,d2
[0001189e] 0002 01b6                 ori.b      #$B6,d2
[000118a2] 0002 01e4                 ori.b      #$E4,d2
[000118a6] 0002 0212                 ori.b      #$12,d2
[000118aa] 0000 0370                 ori.b      #$70,d0
[000118ae] 4bfb 1006                 lea.l      $000118B6(pc,d1.w),a5
[000118b2] 3c04                      move.w     d4,d6
[000118b4] 4ed5                      jmp        (a5)
[000118b6] 2020                      move.l     -(a0),d0
[000118b8] c1a1                      and.l      d0,-(a1)
[000118ba] 2020                      move.l     -(a0),d0
[000118bc] c1a1                      and.l      d0,-(a1)
[000118be] 2020                      move.l     -(a0),d0
[000118c0] c1a1                      and.l      d0,-(a1)
[000118c2] 2020                      move.l     -(a0),d0
[000118c4] c1a1                      and.l      d0,-(a1)
[000118c6] 51ce ffee                 dbf        d6,$000118B6
[000118ca] 91ca                      suba.l     a2,a0
[000118cc] 93cb                      suba.l     a3,a1
[000118ce] 51cd ffe2                 dbf        d5,$000118B2
[000118d2] 4e75                      rts
[000118d4] 4bfb 1006                 lea.l      $000118DC(pc,d1.w),a5
[000118d8] 3c04                      move.w     d4,d6
[000118da] 4ed5                      jmp        (a5)
[000118dc] 2020                      move.l     -(a0),d0
[000118de] 4691                      not.l      (a1)
[000118e0] c1a1                      and.l      d0,-(a1)
[000118e2] 2020                      move.l     -(a0),d0
[000118e4] 4691                      not.l      (a1)
[000118e6] c1a1                      and.l      d0,-(a1)
[000118e8] 2020                      move.l     -(a0),d0
[000118ea] 4691                      not.l      (a1)
[000118ec] c1a1                      and.l      d0,-(a1)
[000118ee] 2020                      move.l     -(a0),d0
[000118f0] 4691                      not.l      (a1)
[000118f2] c1a1                      and.l      d0,-(a1)
[000118f4] 51ce ffe6                 dbf        d6,$000118DC
[000118f8] 91ca                      suba.l     a2,a0
[000118fa] 93cb                      suba.l     a3,a1
[000118fc] 51cd ffda                 dbf        d5,$000118D8
[00011900] 4e75                      rts
[00011902] 4bfb 1006                 lea.l      $0001190A(pc,d1.w),a5
[00011906] 3c04                      move.w     d4,d6
[00011908] 4ed5                      jmp        (a5)
[0001190a] 2320                      move.l     -(a0),-(a1)
[0001190c] 2320                      move.l     -(a0),-(a1)
[0001190e] 2320                      move.l     -(a0),-(a1)
[00011910] 2320                      move.l     -(a0),-(a1)
[00011912] 51ce fff6                 dbf        d6,$0001190A
[00011916] 91ca                      suba.l     a2,a0
[00011918] 93cb                      suba.l     a3,a1
[0001191a] 51cd ffea                 dbf        d5,$00011906
[0001191e] 4e75                      rts
[00011920] 4bfb 1006                 lea.l      $00011928(pc,d1.w),a5
[00011924] 3c04                      move.w     d4,d6
[00011926] 4ed5                      jmp        (a5)
[00011928] 2020                      move.l     -(a0),d0
[0001192a] 4680                      not.l      d0
[0001192c] c1a1                      and.l      d0,-(a1)
[0001192e] 2020                      move.l     -(a0),d0
[00011930] 4680                      not.l      d0
[00011932] c1a1                      and.l      d0,-(a1)
[00011934] 2020                      move.l     -(a0),d0
[00011936] 4680                      not.l      d0
[00011938] c1a1                      and.l      d0,-(a1)
[0001193a] 2020                      move.l     -(a0),d0
[0001193c] 4680                      not.l      d0
[0001193e] c1a1                      and.l      d0,-(a1)
[00011940] 51ce ffe6                 dbf        d6,$00011928
[00011944] 91ca                      suba.l     a2,a0
[00011946] 93cb                      suba.l     a3,a1
[00011948] 51cd ffda                 dbf        d5,$00011924
[0001194c] 4e75                      rts
[0001194e] 4bfb 1006                 lea.l      $00011956(pc,d1.w),a5
[00011952] 3c04                      move.w     d4,d6
[00011954] 4ed5                      jmp        (a5)
[00011956] 2020                      move.l     -(a0),d0
[00011958] b1a1                      eor.l      d0,-(a1)
[0001195a] 2020                      move.l     -(a0),d0
[0001195c] b1a1                      eor.l      d0,-(a1)
[0001195e] 2020                      move.l     -(a0),d0
[00011960] b1a1                      eor.l      d0,-(a1)
[00011962] 2020                      move.l     -(a0),d0
[00011964] b1a1                      eor.l      d0,-(a1)
[00011966] 51ce ffee                 dbf        d6,$00011956
[0001196a] 91ca                      suba.l     a2,a0
[0001196c] 93cb                      suba.l     a3,a1
[0001196e] 51cd ffe2                 dbf        d5,$00011952
[00011972] 4e75                      rts
[00011974] 4bfb 1006                 lea.l      $0001197C(pc,d1.w),a5
[00011978] 3c04                      move.w     d4,d6
[0001197a] 4ed5                      jmp        (a5)
[0001197c] 2020                      move.l     -(a0),d0
[0001197e] 81a1                      or.l       d0,-(a1)
[00011980] 2020                      move.l     -(a0),d0
[00011982] 81a1                      or.l       d0,-(a1)
[00011984] 2020                      move.l     -(a0),d0
[00011986] 81a1                      or.l       d0,-(a1)
[00011988] 2020                      move.l     -(a0),d0
[0001198a] 81a1                      or.l       d0,-(a1)
[0001198c] 51ce ffee                 dbf        d6,$0001197C
[00011990] 91ca                      suba.l     a2,a0
[00011992] 93cb                      suba.l     a3,a1
[00011994] 51cd ffe2                 dbf        d5,$00011978
[00011998] 4e75                      rts
[0001199a] 4bfb 1006                 lea.l      $000119A2(pc,d1.w),a5
[0001199e] 3c04                      move.w     d4,d6
[000119a0] 4ed5                      jmp        (a5)
[000119a2] 2020                      move.l     -(a0),d0
[000119a4] 8191                      or.l       d0,(a1)
[000119a6] 46a1                      not.l      -(a1)
[000119a8] 2020                      move.l     -(a0),d0
[000119aa] 8191                      or.l       d0,(a1)
[000119ac] 46a1                      not.l      -(a1)
[000119ae] 2020                      move.l     -(a0),d0
[000119b0] 8191                      or.l       d0,(a1)
[000119b2] 46a1                      not.l      -(a1)
[000119b4] 2020                      move.l     -(a0),d0
[000119b6] 8191                      or.l       d0,(a1)
[000119b8] 46a1                      not.l      -(a1)
[000119ba] 51ce ffe6                 dbf        d6,$000119A2
[000119be] 91ca                      suba.l     a2,a0
[000119c0] 93cb                      suba.l     a3,a1
[000119c2] 51cd ffda                 dbf        d5,$0001199E
[000119c6] 4e75                      rts
[000119c8] 4bfb 1006                 lea.l      $000119D0(pc,d1.w),a5
[000119cc] 3c04                      move.w     d4,d6
[000119ce] 4ed5                      jmp        (a5)
[000119d0] 2020                      move.l     -(a0),d0
[000119d2] b191                      eor.l      d0,(a1)
[000119d4] 46a1                      not.l      -(a1)
[000119d6] 2020                      move.l     -(a0),d0
[000119d8] b191                      eor.l      d0,(a1)
[000119da] 46a1                      not.l      -(a1)
[000119dc] 2020                      move.l     -(a0),d0
[000119de] b191                      eor.l      d0,(a1)
[000119e0] 46a1                      not.l      -(a1)
[000119e2] 2020                      move.l     -(a0),d0
[000119e4] b191                      eor.l      d0,(a1)
[000119e6] 46a1                      not.l      -(a1)
[000119e8] 51ce ffe6                 dbf        d6,$000119D0
[000119ec] 91ca                      suba.l     a2,a0
[000119ee] 93cb                      suba.l     a3,a1
[000119f0] 51cd ffda                 dbf        d5,$000119CC
[000119f4] 4e75                      rts
[000119f6] 4bfb 1006                 lea.l      $000119FE(pc,d1.w),a5
[000119fa] 3c04                      move.w     d4,d6
[000119fc] 4ed5                      jmp        (a5)
[000119fe] 4691                      not.l      (a1)
[00011a00] 2020                      move.l     -(a0),d0
[00011a02] 81a1                      or.l       d0,-(a1)
[00011a04] 4691                      not.l      (a1)
[00011a06] 2020                      move.l     -(a0),d0
[00011a08] 81a1                      or.l       d0,-(a1)
[00011a0a] 4691                      not.l      (a1)
[00011a0c] 2020                      move.l     -(a0),d0
[00011a0e] 81a1                      or.l       d0,-(a1)
[00011a10] 4691                      not.l      (a1)
[00011a12] 2020                      move.l     -(a0),d0
[00011a14] 81a1                      or.l       d0,-(a1)
[00011a16] 51ce ffe6                 dbf        d6,$000119FE
[00011a1a] 91ca                      suba.l     a2,a0
[00011a1c] 93cb                      suba.l     a3,a1
[00011a1e] 51cd ffda                 dbf        d5,$000119FA
[00011a22] 4e75                      rts
[00011a24] 4bfb 1006                 lea.l      $00011A2C(pc,d1.w),a5
[00011a28] 3c04                      move.w     d4,d6
[00011a2a] 4ed5                      jmp        (a5)
[00011a2c] 2020                      move.l     -(a0),d0
[00011a2e] 4680                      not.l      d0
[00011a30] 2300                      move.l     d0,-(a1)
[00011a32] 2020                      move.l     -(a0),d0
[00011a34] 4680                      not.l      d0
[00011a36] 2300                      move.l     d0,-(a1)
[00011a38] 2020                      move.l     -(a0),d0
[00011a3a] 4680                      not.l      d0
[00011a3c] 2300                      move.l     d0,-(a1)
[00011a3e] 2020                      move.l     -(a0),d0
[00011a40] 4680                      not.l      d0
[00011a42] 2300                      move.l     d0,-(a1)
[00011a44] 51ce ffe6                 dbf        d6,$00011A2C
[00011a48] 91ca                      suba.l     a2,a0
[00011a4a] 93cb                      suba.l     a3,a1
[00011a4c] 51cd ffda                 dbf        d5,$00011A28
[00011a50] 4e75                      rts
[00011a52] 4bfb 1006                 lea.l      $00011A5A(pc,d1.w),a5
[00011a56] 3c04                      move.w     d4,d6
[00011a58] 4ed5                      jmp        (a5)
[00011a5a] 2020                      move.l     -(a0),d0
[00011a5c] 4680                      not.l      d0
[00011a5e] 81a1                      or.l       d0,-(a1)
[00011a60] 2020                      move.l     -(a0),d0
[00011a62] 4680                      not.l      d0
[00011a64] 81a1                      or.l       d0,-(a1)
[00011a66] 2020                      move.l     -(a0),d0
[00011a68] 4680                      not.l      d0
[00011a6a] 81a1                      or.l       d0,-(a1)
[00011a6c] 2020                      move.l     -(a0),d0
[00011a6e] 4680                      not.l      d0
[00011a70] 81a1                      or.l       d0,-(a1)
[00011a72] 51ce ffe6                 dbf        d6,$00011A5A
[00011a76] 91ca                      suba.l     a2,a0
[00011a78] 93cb                      suba.l     a3,a1
[00011a7a] 51cd ffda                 dbf        d5,$00011A56
[00011a7e] 4e75                      rts
[00011a80] 4bfb 1006                 lea.l      $00011A88(pc,d1.w),a5
[00011a84] 3c04                      move.w     d4,d6
[00011a86] 4ed5                      jmp        (a5)
[00011a88] 2020                      move.l     -(a0),d0
[00011a8a] c191                      and.l      d0,(a1)
[00011a8c] 46a1                      not.l      -(a1)
[00011a8e] 2020                      move.l     -(a0),d0
[00011a90] c191                      and.l      d0,(a1)
[00011a92] 46a1                      not.l      -(a1)
[00011a94] 2020                      move.l     -(a0),d0
[00011a96] c191                      and.l      d0,(a1)
[00011a98] 46a1                      not.l      -(a1)
[00011a9a] 2020                      move.l     -(a0),d0
[00011a9c] c191                      and.l      d0,(a1)
[00011a9e] 46a1                      not.l      -(a1)
[00011aa0] 51ce ffe6                 dbf        d6,$00011A88
[00011aa4] 91ca                      suba.l     a2,a0
[00011aa6] 93cb                      suba.l     a3,a1
[00011aa8] 51cd ffda                 dbf        d5,$00011A84
[00011aac] 4e75                      rts
[00011aae] be7c 0003                 cmp.w      #$0003,d7
[00011ab2] 6600 00aa                 bne        $00011B5E
[00011ab6] 323a 088e                 move.w     $00012346(pc),d1
[00011aba] 6700 00a2                 beq        $00011B5E
[00011abe] b87c 000f                 cmp.w      #$000F,d4
[00011ac2] 6f00 009a                 ble        $00011B5E
[00011ac6] 7c0f                      moveq.l    #15,d6
[00011ac8] 2208                      move.l     a0,d1
[00011aca] 2609                      move.l     a1,d3
[00011acc] c286                      and.l      d6,d1
[00011ace] c686                      and.l      d6,d3
[00011ad0] b681                      cmp.l      d1,d3
[00011ad2] 6600 008a                 bne        $00011B5E
[00011ad6] 2e04                      move.l     d4,d7
[00011ad8] 5287                      addq.l     #1,d7
[00011ada] de87                      add.l      d7,d7
[00011adc] de87                      add.l      d7,d7
[00011ade] 95c7                      suba.l     d7,a2
[00011ae0] 97c7                      suba.l     d7,a3
[00011ae2] 7c03                      moveq.l    #3,d6
[00011ae4] e489                      lsr.l      #2,d1
[00011ae6] 2001                      move.l     d1,d0
[00011ae8] 6604                      bne.s      $00011AEE
[00011aea] 70ff                      moveq.l    #-1,d0
[00011aec] 6008                      bra.s      $00011AF6
[00011aee] 4680                      not.l      d0
[00011af0] c086                      and.l      d6,d0
[00011af2] 9880                      sub.l      d0,d4
[00011af4] 5384                      subq.l     #1,d4
[00011af6] 2404                      move.l     d4,d2
[00011af8] e48c                      lsr.l      #2,d4
[00011afa] 5384                      subq.l     #1,d4
[00011afc] c486                      and.l      d6,d2
[00011afe] b486                      cmp.l      d6,d2
[00011b00] 6634                      bne.s      $00011B36
[00011b02] 74ff                      moveq.l    #-1,d2
[00011b04] 5284                      addq.l     #1,d4
[00011b06] b480                      cmp.l      d0,d2
[00011b08] 662c                      bne.s      $00011B36
[00011b0a] 5285                      addq.l     #1,d5
[00011b0c] 600e                      bra.s      $00011B1C
[00011b0e] 0000 f620                 ori.b      #$20,d0
[00011b12] 9000                      sub.b      d0,d0
[00011b14] 51ce fffa                 dbf        d6,$00011B10
[00011b18] d1ca                      adda.l     a2,a0
[00011b1a] d3cb                      adda.l     a3,a1
[00011b1c] 3c04                      move.w     d4,d6
[00011b1e] 51cd fff0                 dbf        d5,$00011B10
[00011b22] 4e75                      rts
[00011b24] 0000                      dc.w       $0000
[00011b26] 0000                      dc.w       $0000
[00011b28] 0000                      dc.w       $0000
[00011b2a] 0000                      dc.w       $0000
[00011b2c] 0000                      dc.w       $0000
[00011b2e] 0000 4e71                 ori.b      #$71,d0
[00011b32] 4e71                      nop
[00011b34] 4e71                      nop
[00011b36] 3c00                      move.w     d0,d6
[00011b38] 6b06                      bmi.s      $00011B40
[00011b3a] 22d8                      move.l     (a0)+,(a1)+
[00011b3c] 51ce fffc                 dbf        d6,$00011B3A
[00011b40] 3c04                      move.w     d4,d6
[00011b42] f620 9000                 move16     (a0)+,(a1)+
[00011b46] 51ce fffa                 dbf        d6,$00011B42
[00011b4a] 3c02                      move.w     d2,d6
[00011b4c] 6b06                      bmi.s      $00011B54
[00011b4e] 22d8                      move.l     (a0)+,(a1)+
[00011b50] 51ce fffc                 dbf        d6,$00011B4E
[00011b54] d1ca                      adda.l     a2,a0
[00011b56] d3cb                      adda.l     a3,a1
[00011b58] 51cd ffdc                 dbf        d5,$00011B36
[00011b5c] 4e75                      rts
[00011b5e] 2c04                      move.l     d4,d6
[00011b60] 5286                      addq.l     #1,d6
[00011b62] dc86                      add.l      d6,d6
[00011b64] dc86                      add.l      d6,d6
[00011b66] 95c6                      suba.l     d6,a2
[00011b68] 97c6                      suba.l     d6,a3
[00011b6a] 7203                      moveq.l    #3,d1
[00011b6c] c284                      and.l      d4,d1
[00011b6e] 0a41 0003                 eori.w     #$0003,d1
[00011b72] d281                      add.l      d1,d1
[00011b74] e484                      asr.l      #2,d4
[00011b76] 4a84                      tst.l      d4
[00011b78] 6a04                      bpl.s      $00011B7E
[00011b7a] 7800                      moveq.l    #0,d4
[00011b7c] 7208                      moveq.l    #8,d1
[00011b7e] de47                      add.w      d7,d7
[00011b80] de47                      add.w      d7,d7
[00011b82] 49fb 701a                 lea.l      $00011B9E(pc,d7.w),a4
[00011b86] 3e1c                      move.w     (a4)+,d7
[00011b88] 670e                      beq.s      $00011B98
[00011b8a] 5347                      subq.w     #1,d7
[00011b8c] 6708                      beq.s      $00011B96
[00011b8e] 3e01                      move.w     d1,d7
[00011b90] d241                      add.w      d1,d1
[00011b92] d247                      add.w      d7,d1
[00011b94] 6002                      bra.s      $00011B98
[00011b96] d241                      add.w      d1,d1
[00011b98] 3e1c                      move.w     (a4)+,d7
[00011b9a] 4efb 7002                 jmp        $00011B9E(pc,d7.w)
[00011b9e] 0000 0044                 ori.b      #$44,d0
[00011ba2] 0001 0062                 ori.b      #$62,d1
[00011ba6] 0002 0088                 ori.b      #$88,d2
[00011baa] 0000 00b6                 ori.b      #$B6,d0
[00011bae] 0002 00d4                 ori.b      #$D4,d2
[00011bb2] 0000 fdae                 ori.b      #$AE,d0
[00011bb6] 0001 0102                 ori.b      #$02,d1
[00011bba] 0001 0128                 ori.b      #$28,d1
[00011bbe] 0002 014e                 ori.b      #$4E,d2
[00011bc2] 0002 017c                 ori.b      #$7C,d2
[00011bc6] 0000 01aa                 ori.b      #$AA,d0
[00011bca] 0002 01c6                 ori.b      #$C6,d2
[00011bce] 0002 01f4                 ori.b      #$F4,d2
[00011bd2] 0002 0222                 ori.b      #$22,d2
[00011bd6] 0002 0250                 ori.b      #$50,d2
[00011bda] 0000 0040                 ori.b      #$40,d0
[00011bde] 7e00                      moveq.l    #0,d7
[00011be0] 6002                      bra.s      $00011BE4
[00011be2] 7eff                      moveq.l    #-1,d7
[00011be4] 4bfb 1006                 lea.l      $00011BEC(pc,d1.w),a5
[00011be8] 3c04                      move.w     d4,d6
[00011bea] 4ed5                      jmp        (a5)
[00011bec] 22c7                      move.l     d7,(a1)+
[00011bee] 22c7                      move.l     d7,(a1)+
[00011bf0] 22c7                      move.l     d7,(a1)+
[00011bf2] 22c7                      move.l     d7,(a1)+
[00011bf4] 51ce fff6                 dbf        d6,$00011BEC
[00011bf8] d3cb                      adda.l     a3,a1
[00011bfa] 51cd ffec                 dbf        d5,$00011BE8
[00011bfe] 4e75                      rts
[00011c00] 4bfb 1006                 lea.l      $00011C08(pc,d1.w),a5
[00011c04] 3c04                      move.w     d4,d6
[00011c06] 4ed5                      jmp        (a5)
[00011c08] 2018                      move.l     (a0)+,d0
[00011c0a] c199                      and.l      d0,(a1)+
[00011c0c] 2018                      move.l     (a0)+,d0
[00011c0e] c199                      and.l      d0,(a1)+
[00011c10] 2018                      move.l     (a0)+,d0
[00011c12] c199                      and.l      d0,(a1)+
[00011c14] 2018                      move.l     (a0)+,d0
[00011c16] c199                      and.l      d0,(a1)+
[00011c18] 51ce ffee                 dbf        d6,$00011C08
[00011c1c] d1ca                      adda.l     a2,a0
[00011c1e] d3cb                      adda.l     a3,a1
[00011c20] 51cd ffe2                 dbf        d5,$00011C04
[00011c24] 4e75                      rts
[00011c26] 4bfb 1006                 lea.l      $00011C2E(pc,d1.w),a5
[00011c2a] 3c04                      move.w     d4,d6
[00011c2c] 4ed5                      jmp        (a5)
[00011c2e] 2018                      move.l     (a0)+,d0
[00011c30] 4691                      not.l      (a1)
[00011c32] c199                      and.l      d0,(a1)+
[00011c34] 2018                      move.l     (a0)+,d0
[00011c36] 4691                      not.l      (a1)
[00011c38] c199                      and.l      d0,(a1)+
[00011c3a] 2018                      move.l     (a0)+,d0
[00011c3c] 4691                      not.l      (a1)
[00011c3e] c199                      and.l      d0,(a1)+
[00011c40] 2018                      move.l     (a0)+,d0
[00011c42] 4691                      not.l      (a1)
[00011c44] c199                      and.l      d0,(a1)+
[00011c46] 51ce ffe6                 dbf        d6,$00011C2E
[00011c4a] d1ca                      adda.l     a2,a0
[00011c4c] d3cb                      adda.l     a3,a1
[00011c4e] 51cd ffda                 dbf        d5,$00011C2A
[00011c52] 4e75                      rts
[00011c54] 4bfb 1006                 lea.l      $00011C5C(pc,d1.w),a5
[00011c58] 3c04                      move.w     d4,d6
[00011c5a] 4ed5                      jmp        (a5)
[00011c5c] 22d8                      move.l     (a0)+,(a1)+
[00011c5e] 22d8                      move.l     (a0)+,(a1)+
[00011c60] 22d8                      move.l     (a0)+,(a1)+
[00011c62] 22d8                      move.l     (a0)+,(a1)+
[00011c64] 51ce fff6                 dbf        d6,$00011C5C
[00011c68] d1ca                      adda.l     a2,a0
[00011c6a] d3cb                      adda.l     a3,a1
[00011c6c] 51cd ffea                 dbf        d5,$00011C58
[00011c70] 4e75                      rts
[00011c72] 4bfb 1006                 lea.l      $00011C7A(pc,d1.w),a5
[00011c76] 3c04                      move.w     d4,d6
[00011c78] 4ed5                      jmp        (a5)
[00011c7a] 2018                      move.l     (a0)+,d0
[00011c7c] 4680                      not.l      d0
[00011c7e] c199                      and.l      d0,(a1)+
[00011c80] 2018                      move.l     (a0)+,d0
[00011c82] 4680                      not.l      d0
[00011c84] c199                      and.l      d0,(a1)+
[00011c86] 2018                      move.l     (a0)+,d0
[00011c88] 4680                      not.l      d0
[00011c8a] c199                      and.l      d0,(a1)+
[00011c8c] 2018                      move.l     (a0)+,d0
[00011c8e] 4680                      not.l      d0
[00011c90] c199                      and.l      d0,(a1)+
[00011c92] 51ce ffe6                 dbf        d6,$00011C7A
[00011c96] d1ca                      adda.l     a2,a0
[00011c98] d3cb                      adda.l     a3,a1
[00011c9a] 51cd ffda                 dbf        d5,$00011C76
[00011c9e] 4e75                      rts
[00011ca0] 4bfb 1006                 lea.l      $00011CA8(pc,d1.w),a5
[00011ca4] 3c04                      move.w     d4,d6
[00011ca6] 4ed5                      jmp        (a5)
[00011ca8] 2018                      move.l     (a0)+,d0
[00011caa] b199                      eor.l      d0,(a1)+
[00011cac] 2018                      move.l     (a0)+,d0
[00011cae] b199                      eor.l      d0,(a1)+
[00011cb0] 2018                      move.l     (a0)+,d0
[00011cb2] b199                      eor.l      d0,(a1)+
[00011cb4] 2018                      move.l     (a0)+,d0
[00011cb6] b199                      eor.l      d0,(a1)+
[00011cb8] 51ce ffee                 dbf        d6,$00011CA8
[00011cbc] d1ca                      adda.l     a2,a0
[00011cbe] d3cb                      adda.l     a3,a1
[00011cc0] 51cd ffe2                 dbf        d5,$00011CA4
[00011cc4] 4e75                      rts
[00011cc6] 4bfb 1006                 lea.l      $00011CCE(pc,d1.w),a5
[00011cca] 3c04                      move.w     d4,d6
[00011ccc] 4ed5                      jmp        (a5)
[00011cce] 2018                      move.l     (a0)+,d0
[00011cd0] 8199                      or.l       d0,(a1)+
[00011cd2] 2018                      move.l     (a0)+,d0
[00011cd4] 8199                      or.l       d0,(a1)+
[00011cd6] 2018                      move.l     (a0)+,d0
[00011cd8] 8199                      or.l       d0,(a1)+
[00011cda] 2018                      move.l     (a0)+,d0
[00011cdc] 8199                      or.l       d0,(a1)+
[00011cde] 51ce ffee                 dbf        d6,$00011CCE
[00011ce2] d1ca                      adda.l     a2,a0
[00011ce4] d3cb                      adda.l     a3,a1
[00011ce6] 51cd ffe2                 dbf        d5,$00011CCA
[00011cea] 4e75                      rts
[00011cec] 4bfb 1006                 lea.l      $00011CF4(pc,d1.w),a5
[00011cf0] 3c04                      move.w     d4,d6
[00011cf2] 4ed5                      jmp        (a5)
[00011cf4] 2018                      move.l     (a0)+,d0
[00011cf6] 8191                      or.l       d0,(a1)
[00011cf8] 4699                      not.l      (a1)+
[00011cfa] 2018                      move.l     (a0)+,d0
[00011cfc] 8191                      or.l       d0,(a1)
[00011cfe] 4699                      not.l      (a1)+
[00011d00] 2018                      move.l     (a0)+,d0
[00011d02] 8191                      or.l       d0,(a1)
[00011d04] 4699                      not.l      (a1)+
[00011d06] 2018                      move.l     (a0)+,d0
[00011d08] 8191                      or.l       d0,(a1)
[00011d0a] 4699                      not.l      (a1)+
[00011d0c] 51ce ffe6                 dbf        d6,$00011CF4
[00011d10] d1ca                      adda.l     a2,a0
[00011d12] d3cb                      adda.l     a3,a1
[00011d14] 51cd ffda                 dbf        d5,$00011CF0
[00011d18] 4e75                      rts
[00011d1a] 4bfb 1006                 lea.l      $00011D22(pc,d1.w),a5
[00011d1e] 3c04                      move.w     d4,d6
[00011d20] 4ed5                      jmp        (a5)
[00011d22] 2018                      move.l     (a0)+,d0
[00011d24] b191                      eor.l      d0,(a1)
[00011d26] 4699                      not.l      (a1)+
[00011d28] 2018                      move.l     (a0)+,d0
[00011d2a] b191                      eor.l      d0,(a1)
[00011d2c] 4699                      not.l      (a1)+
[00011d2e] 2018                      move.l     (a0)+,d0
[00011d30] b191                      eor.l      d0,(a1)
[00011d32] 4699                      not.l      (a1)+
[00011d34] 2018                      move.l     (a0)+,d0
[00011d36] b191                      eor.l      d0,(a1)
[00011d38] 4699                      not.l      (a1)+
[00011d3a] 51ce ffe6                 dbf        d6,$00011D22
[00011d3e] d1ca                      adda.l     a2,a0
[00011d40] d3cb                      adda.l     a3,a1
[00011d42] 51cd ffda                 dbf        d5,$00011D1E
[00011d46] 4e75                      rts
[00011d48] 4bfb 1006                 lea.l      $00011D50(pc,d1.w),a5
[00011d4c] 3c04                      move.w     d4,d6
[00011d4e] 4ed5                      jmp        (a5)
[00011d50] 4699                      not.l      (a1)+
[00011d52] 4699                      not.l      (a1)+
[00011d54] 4699                      not.l      (a1)+
[00011d56] 4699                      not.l      (a1)+
[00011d58] 51ce fff6                 dbf        d6,$00011D50
[00011d5c] d3cb                      adda.l     a3,a1
[00011d5e] 51cd ffec                 dbf        d5,$00011D4C
[00011d62] 4e75                      rts
[00011d64] 4bfb 1006                 lea.l      $00011D6C(pc,d1.w),a5
[00011d68] 3c04                      move.w     d4,d6
[00011d6a] 4ed5                      jmp        (a5)
[00011d6c] 4691                      not.l      (a1)
[00011d6e] 2018                      move.l     (a0)+,d0
[00011d70] 8199                      or.l       d0,(a1)+
[00011d72] 4691                      not.l      (a1)
[00011d74] 2018                      move.l     (a0)+,d0
[00011d76] 8199                      or.l       d0,(a1)+
[00011d78] 4691                      not.l      (a1)
[00011d7a] 2018                      move.l     (a0)+,d0
[00011d7c] 8199                      or.l       d0,(a1)+
[00011d7e] 4691                      not.l      (a1)
[00011d80] 2018                      move.l     (a0)+,d0
[00011d82] 8199                      or.l       d0,(a1)+
[00011d84] 51ce ffe6                 dbf        d6,$00011D6C
[00011d88] d1ca                      adda.l     a2,a0
[00011d8a] d3cb                      adda.l     a3,a1
[00011d8c] 51cd ffda                 dbf        d5,$00011D68
[00011d90] 4e75                      rts
[00011d92] 4bfb 1006                 lea.l      $00011D9A(pc,d1.w),a5
[00011d96] 3c04                      move.w     d4,d6
[00011d98] 4ed5                      jmp        (a5)
[00011d9a] 2018                      move.l     (a0)+,d0
[00011d9c] 4680                      not.l      d0
[00011d9e] 22c0                      move.l     d0,(a1)+
[00011da0] 2018                      move.l     (a0)+,d0
[00011da2] 4680                      not.l      d0
[00011da4] 22c0                      move.l     d0,(a1)+
[00011da6] 2018                      move.l     (a0)+,d0
[00011da8] 4680                      not.l      d0
[00011daa] 22c0                      move.l     d0,(a1)+
[00011dac] 2018                      move.l     (a0)+,d0
[00011dae] 4680                      not.l      d0
[00011db0] 22c0                      move.l     d0,(a1)+
[00011db2] 51ce ffe6                 dbf        d6,$00011D9A
[00011db6] d1ca                      adda.l     a2,a0
[00011db8] d3cb                      adda.l     a3,a1
[00011dba] 51cd ffda                 dbf        d5,$00011D96
[00011dbe] 4e75                      rts
[00011dc0] 4bfb 1006                 lea.l      $00011DC8(pc,d1.w),a5
[00011dc4] 3c04                      move.w     d4,d6
[00011dc6] 4ed5                      jmp        (a5)
[00011dc8] 2018                      move.l     (a0)+,d0
[00011dca] 4680                      not.l      d0
[00011dcc] 8199                      or.l       d0,(a1)+
[00011dce] 2018                      move.l     (a0)+,d0
[00011dd0] 4680                      not.l      d0
[00011dd2] 8199                      or.l       d0,(a1)+
[00011dd4] 2018                      move.l     (a0)+,d0
[00011dd6] 4680                      not.l      d0
[00011dd8] 8199                      or.l       d0,(a1)+
[00011dda] 2018                      move.l     (a0)+,d0
[00011ddc] 4680                      not.l      d0
[00011dde] 8199                      or.l       d0,(a1)+
[00011de0] 51ce ffe6                 dbf        d6,$00011DC8
[00011de4] d1ca                      adda.l     a2,a0
[00011de6] d3cb                      adda.l     a3,a1
[00011de8] 51cd ffda                 dbf        d5,$00011DC4
[00011dec] 4e75                      rts
[00011dee] 4bfb 1006                 lea.l      $00011DF6(pc,d1.w),a5
[00011df2] 3c04                      move.w     d4,d6
[00011df4] 4ed5                      jmp        (a5)
[00011df6] 2018                      move.l     (a0)+,d0
[00011df8] c191                      and.l      d0,(a1)
[00011dfa] 4699                      not.l      (a1)+
[00011dfc] 2018                      move.l     (a0)+,d0
[00011dfe] c191                      and.l      d0,(a1)
[00011e00] 4699                      not.l      (a1)+
[00011e02] 2018                      move.l     (a0)+,d0
[00011e04] c191                      and.l      d0,(a1)
[00011e06] 4699                      not.l      (a1)+
[00011e08] 2018                      move.l     (a0)+,d0
[00011e0a] c191                      and.l      d0,(a1)
[00011e0c] 4699                      not.l      (a1)+
[00011e0e] 51ce ffe6                 dbf        d6,$00011DF6
[00011e12] d1ca                      adda.l     a2,a0
[00011e14] d3cb                      adda.l     a3,a1
[00011e16] 51cd ffda                 dbf        d5,$00011DF2
[00011e1a] 4e75                      rts
[00011e1c] 4fef 0098                 lea.l      152(a7),a7
[00011e20] 4e75                      rts
[00011e22] 41fa 0140                 lea.l      $00011F64(pc),a0
[00011e26] 43fa 0162                 lea.l      $00011F8A(pc),a1
[00011e2a] 45fa 0172                 lea.l      $00011F9E(pc),a2
[00011e2e] 47fa 02e4                 lea.l      $00012114(pc),a3
[00011e32] 2f09                      move.l     a1,-(a7)
[00011e34] 4fef ff6c                 lea.l      -148(a7),a7
[00011e38] 2248                      movea.l    a0,a1
[00011e3a] 41ef 009c                 lea.l      156(a7),a0
[00011e3e] 4e91                      jsr        (a1)
[00011e40] 2e88                      move.l     a0,(a7)
[00011e42] 2f48 0048                 move.l     a0,72(a7)
[00011e46] 67d4                      beq.s      $00011E1C
[00011e48] 224a                      movea.l    a2,a1
[00011e4a] 41ef 009c                 lea.l      156(a7),a0
[00011e4e] 45ef 0054                 lea.l      84(a7),a2
[00011e52] 4e91                      jsr        (a1)
[00011e54] 2848                      movea.l    a0,a4
[00011e56] 2f49 004c                 move.l     a1,76(a7)
[00011e5a] 2f4a 0050                 move.l     a2,80(a7)
[00011e5e] 41ef 009c                 lea.l      156(a7),a0
[00011e62] 45ef 0008                 lea.l      8(a7),a2
[00011e66] 4e93                      jsr        (a3)
[00011e68] 2a48                      movea.l    a0,a5
[00011e6a] 2f49 0004                 move.l     a1,4(a7)
[00011e6e] 926f 009e                 sub.w      158(a7),d1
[00011e72] 966f 00a2                 sub.w      162(a7),d3
[00011e76] 3807                      move.w     d7,d4
[00011e78] 3c2f 00aa                 move.w     170(a7),d6
[00011e7c] 3e2f 00a6                 move.w     166(a7),d7
[00011e80] bc7c 7fff                 cmp.w      #$7FFF,d6
[00011e84] 6406                      bcc.s      $00011E8C
[00011e86] be7c 7fff                 cmp.w      #$7FFF,d7
[00011e8a] 6504                      bcs.s      $00011E90
[00011e8c] e24e                      lsr.w      #1,d6
[00011e8e] e24f                      lsr.w      #1,d7
[00011e90] 5246                      addq.w     #1,d6
[00011e92] 5247                      addq.w     #1,d7
[00011e94] bc47                      cmp.w      d7,d6
[00011e96] 6f62                      ble.s      $00011EFA
[00011e98] 3a06                      move.w     d6,d5
[00011e9a] 4445                      neg.w      d5
[00011e9c] 48c5                      ext.l      d5
[00011e9e] 4a41                      tst.w      d1
[00011ea0] 6704                      beq.s      $00011EA6
[00011ea2] c2c6                      mulu.w     d6,d1
[00011ea4] 9a81                      sub.l      d1,d5
[00011ea6] 4a43                      tst.w      d3
[00011ea8] 6704                      beq.s      $00011EAE
[00011eaa] c6c7                      mulu.w     d7,d3
[00011eac] da83                      add.l      d3,d5
[00011eae] 45ef 0054                 lea.l      84(a7),a2
[00011eb2] 204c                      movea.l    a4,a0
[00011eb4] 226f 0048                 movea.l    72(a7),a1
[00011eb8] 266f 004c                 movea.l    76(a7),a3
[00011ebc] 4e93                      jsr        (a3)
[00011ebe] 244f                      movea.l    a7,a2
[00011ec0] 205a                      movea.l    (a2)+,a0
[00011ec2] 224d                      movea.l    a5,a1
[00011ec4] 265a                      movea.l    (a2)+,a3
[00011ec6] 4e93                      jsr        (a3)
[00011ec8] 2f00                      move.l     d0,-(a7)
[00011eca] 7000                      moveq.l    #0,d0
[00011ecc] 302e 01da                 move.w     474(a6),d0
[00011ed0] dbc0                      adda.l     d0,a5
[00011ed2] 201f                      move.l     (a7)+,d0
[00011ed4] da47                      add.w      d7,d5
[00011ed6] 6a06                      bpl.s      $00011EDE
[00011ed8] 51cc ffe4                 dbf        d4,$00011EBE
[00011edc] 6012                      bra.s      $00011EF0
[00011ede] 9a46                      sub.w      d6,d5
[00011ee0] 2f00                      move.l     d0,-(a7)
[00011ee2] 7000                      moveq.l    #0,d0
[00011ee4] 302e 01c6                 move.w     454(a6),d0
[00011ee8] d9c0                      adda.l     d0,a4
[00011eea] 201f                      move.l     (a7)+,d0
[00011eec] 51cc ffc0                 dbf        d4,$00011EAE
[00011ef0] 2057                      movea.l    (a7),a0
[00011ef2] 4fef 0094                 lea.l      148(a7),a7
[00011ef6] 225f                      movea.l    (a7)+,a1
[00011ef8] 4ed1                      jmp        (a1)
[00011efa] 3805                      move.w     d5,d4
[00011efc] 3a07                      move.w     d7,d5
[00011efe] 4445                      neg.w      d5
[00011f00] 48c5                      ext.l      d5
[00011f02] 4a41                      tst.w      d1
[00011f04] 6704                      beq.s      $00011F0A
[00011f06] c2c6                      mulu.w     d6,d1
[00011f08] da81                      add.l      d1,d5
[00011f0a] 4a43                      tst.w      d3
[00011f0c] 6704                      beq.s      $00011F12
[00011f0e] c6c7                      mulu.w     d7,d3
[00011f10] 9a83                      sub.l      d3,d5
[00011f12] 266f 004c                 movea.l    76(a7),a3
[00011f16] 6004                      bra.s      $00011F1C
[00011f18] 266f 0050                 movea.l    80(a7),a3
[00011f1c] 45ef 0054                 lea.l      84(a7),a2
[00011f20] 204c                      movea.l    a4,a0
[00011f22] 226f 0048                 movea.l    72(a7),a1
[00011f26] 4e93                      jsr        (a3)
[00011f28] 2f00                      move.l     d0,-(a7)
[00011f2a] 7000                      moveq.l    #0,d0
[00011f2c] 302e 01c6                 move.w     454(a6),d0
[00011f30] d9c0                      adda.l     d0,a4
[00011f32] 201f                      move.l     (a7)+,d0
[00011f34] da46                      add.w      d6,d5
[00011f36] 6a06                      bpl.s      $00011F3E
[00011f38] 51cc ffde                 dbf        d4,$00011F18
[00011f3c] 7800                      moveq.l    #0,d4
[00011f3e] 244f                      movea.l    a7,a2
[00011f40] 205a                      movea.l    (a2)+,a0
[00011f42] 224d                      movea.l    a5,a1
[00011f44] 265a                      movea.l    (a2)+,a3
[00011f46] 4e93                      jsr        (a3)
[00011f48] 9a47                      sub.w      d7,d5
[00011f4a] 2f00                      move.l     d0,-(a7)
[00011f4c] 7000                      moveq.l    #0,d0
[00011f4e] 302e 01da                 move.w     474(a6),d0
[00011f52] dbc0                      adda.l     d0,a5
[00011f54] 201f                      move.l     (a7)+,d0
[00011f56] 51cc ffba                 dbf        d4,$00011F12
[00011f5a] 2057                      movea.l    (a7),a0
[00011f5c] 4fef 0094                 lea.l      148(a7),a7
[00011f60] 225f                      movea.l    (a7)+,a1
[00011f62] 4ed1                      jmp        (a1)
[00011f64] 2f00                      move.l     d0,-(a7)
[00011f66] 700f                      moveq.l    #15,d0
[00011f68] c042                      and.w      d2,d0
[00011f6a] d046                      add.w      d6,d0
[00011f6c] d080                      add.l      d0,d0
[00011f6e] d080                      add.l      d0,d0
[00011f70] 4a6e 01c8                 tst.w      456(a6)
[00011f74] 6606                      bne.s      $00011F7C
[00011f76] ec88                      lsr.l      #6,d0
[00011f78] 5280                      addq.l     #1,d0
[00011f7a] d080                      add.l      d0,d0
[00011f7c] 207a 03ca                 movea.l    $00012348(pc),a0
[00011f80] 2068 008c                 movea.l    140(a0),a0
[00011f84] 4e90                      jsr        (a0)
[00011f86] 201f                      move.l     (a7)+,d0
[00011f88] 4e75                      rts
[00011f8a] 48e7 80c0                 movem.l    d0/a0-a1,-(a7)
[00011f8e] 227a 03b8                 movea.l    $00012348(pc),a1
[00011f92] 2269 0090                 movea.l    144(a1),a1
[00011f96] 4e91                      jsr        (a1)
[00011f98] 4cdf 0301                 movem.l    (a7)+,d0/a0-a1
[00011f9c] 4e75                      rts
[00011f9e] 48e7 ff00                 movem.l    d0-d7,-(a7)
[00011fa2] 226e 01c2                 movea.l    450(a6),a1
[00011fa6] c2ee 01c6                 mulu.w     454(a6),d1
[00011faa] d3c1                      adda.l     d1,a1
[00011fac] 3200                      move.w     d0,d1
[00011fae] 48c1                      ext.l      d1
[00011fb0] d281                      add.l      d1,d1
[00011fb2] d281                      add.l      d1,d1
[00011fb4] 4a6e 01c8                 tst.w      456(a6)
[00011fb8] 6604                      bne.s      $00011FBE
[00011fba] ec81                      asr.l      #6,d1
[00011fbc] d281                      add.l      d1,d1
[00011fbe] d3c1                      adda.l     d1,a1
[00011fc0] 3e02                      move.w     d2,d7
[00011fc2] 3404                      move.w     d4,d2
[00011fc4] 3606                      move.w     d6,d3
[00011fc6] 3c00                      move.w     d0,d6
[00011fc8] 780f                      moveq.l    #15,d4
[00011fca] c846                      and.w      d6,d4
[00011fcc] 9c50                      sub.w      (a0),d6
[00011fce] 9e68 0004                 sub.w      4(a0),d7
[00011fd2] 3028 0008                 move.w     8(a0),d0
[00011fd6] 3228 000c                 move.w     12(a0),d1
[00011fda] b07c 7fff                 cmp.w      #$7FFF,d0
[00011fde] 6406                      bcc.s      $00011FE6
[00011fe0] b27c 7fff                 cmp.w      #$7FFF,d1
[00011fe4] 6504                      bcs.s      $00011FEA
[00011fe6] e248                      lsr.w      #1,d0
[00011fe8] e249                      lsr.w      #1,d1
[00011fea] 5240                      addq.w     #1,d0
[00011fec] 5241                      addq.w     #1,d1
[00011fee] b240                      cmp.w      d0,d1
[00011ff0] 6f18                      ble.s      $0001200A
[00011ff2] 3401                      move.w     d1,d2
[00011ff4] 4442                      neg.w      d2
[00011ff6] 48c2                      ext.l      d2
[00011ff8] 4a46                      tst.w      d6
[00011ffa] 6704                      beq.s      $00012000
[00011ffc] ccc1                      mulu.w     d1,d6
[00011ffe] 9486                      sub.l      d6,d2
[00012000] 4a47                      tst.w      d7
[00012002] 671c                      beq.s      $00012020
[00012004] cec0                      mulu.w     d0,d7
[00012006] d487                      add.l      d7,d2
[00012008] 6016                      bra.s      $00012020
[0001200a] 3600                      move.w     d0,d3
[0001200c] 4443                      neg.w      d3
[0001200e] 48c3                      ext.l      d3
[00012010] 4a46                      tst.w      d6
[00012012] 6704                      beq.s      $00012018
[00012014] ccc1                      mulu.w     d1,d6
[00012016] d686                      add.l      d6,d3
[00012018] 4a47                      tst.w      d7
[0001201a] 6704                      beq.s      $00012020
[0001201c] cec0                      mulu.w     d0,d7
[0001201e] 9687                      sub.l      d7,d3
[00012020] 3c01                      move.w     d1,d6
[00012022] 3e00                      move.w     d0,d7
[00012024] 4892 00dc                 movem.w    d2-d4/d6-d7,(a2)
[00012028] 2049                      movea.l    a1,a0
[0001202a] 4a6e 01c8                 tst.w      456(a6)
[0001202e] 660e                      bne.s      $0001203E
[00012030] 43fa 001a                 lea.l      $0001204C(pc),a1
[00012034] 45fa 0016                 lea.l      $0001204C(pc),a2
[00012038] 4cdf 00ff                 movem.l    (a7)+,d0-d7
[0001203c] 4e75                      rts
[0001203e] 43fa 0098                 lea.l      $000120D8(pc),a1
[00012042] 45fa 0094                 lea.l      $000120D8(pc),a2
[00012046] 4cdf 00ff                 movem.l    (a7)+,d0-d7
[0001204a] 4e75                      rts
[0001204c] 48a7 0b00                 movem.w    d4/d6-d7,-(a7)
[00012050] 4c92 0c1c                 movem.w    (a2),d2-d4/a2-a3
[00012054] b4cb                      cmpa.w     a3,a2
[00012056] 6f44                      ble.s      $0001209C
[00012058] 3c3c 8000                 move.w     #$8000,d6
[0001205c] 7e00                      moveq.l    #0,d7
[0001205e] 6014                      bra.s      $00012074
[00012060] 944a                      sub.w      a2,d2
[00012062] e25e                      ror.w      #1,d6
[00012064] 55cb 000a                 dbcs       d3,$00012070
[00012068] 32c7                      move.w     d7,(a1)+
[0001206a] 7e00                      moveq.l    #0,d7
[0001206c] 5343                      subq.w     #1,d3
[0001206e] 6b26                      bmi.s      $00012096
[00012070] 51c8 000c                 dbf        d0,$0001207E
[00012074] 700f                      moveq.l    #15,d0
[00012076] 2210                      move.l     (a0),d1
[00012078] 5488                      addq.l     #2,a0
[0001207a] e9a9                      lsl.l      d4,d1
[0001207c] 4841                      swap       d1
[0001207e] 0101                      btst       d0,d1
[00012080] 6702                      beq.s      $00012084
[00012082] 8e46                      or.w       d6,d7
[00012084] d44b                      add.w      a3,d2
[00012086] 6ad8                      bpl.s      $00012060
[00012088] e25e                      ror.w      #1,d6
[0001208a] 55cb fff2                 dbcs       d3,$0001207E
[0001208e] 32c7                      move.w     d7,(a1)+
[00012090] 7e00                      moveq.l    #0,d7
[00012092] 5343                      subq.w     #1,d3
[00012094] 6ae8                      bpl.s      $0001207E
[00012096] 4c9f 00d0                 movem.w    (a7)+,d4/d6-d7
[0001209a] 4e75                      rts
[0001209c] 3c3c 8000                 move.w     #$8000,d6
[000120a0] 7e00                      moveq.l    #0,d7
[000120a2] 6014                      bra.s      $000120B8
[000120a4] 964b                      sub.w      a3,d3
[000120a6] e25e                      ror.w      #1,d6
[000120a8] 55ca 000a                 dbcs       d2,$000120B4
[000120ac] 32c7                      move.w     d7,(a1)+
[000120ae] 7e00                      moveq.l    #0,d7
[000120b0] 5342                      subq.w     #1,d2
[000120b2] 6b1e                      bmi.s      $000120D2
[000120b4] 51c8 000c                 dbf        d0,$000120C2
[000120b8] 700f                      moveq.l    #15,d0
[000120ba] 2210                      move.l     (a0),d1
[000120bc] 5488                      addq.l     #2,a0
[000120be] e9a9                      lsl.l      d4,d1
[000120c0] 4841                      swap       d1
[000120c2] 0101                      btst       d0,d1
[000120c4] 6702                      beq.s      $000120C8
[000120c6] 8e46                      or.w       d6,d7
[000120c8] d64a                      add.w      a2,d3
[000120ca] 6ad8                      bpl.s      $000120A4
[000120cc] 51ca ffe6                 dbf        d2,$000120B4
[000120d0] 32c7                      move.w     d7,(a1)+
[000120d2] 4c9f 00d0                 movem.w    (a7)+,d4/d6-d7
[000120d6] 4e75                      rts
[000120d8] 4c92 000c                 movem.w    (a2),d2-d3
[000120dc] 4caa 0c00 0006            movem.w    6(a2),a2-a3
[000120e2] b4cb                      cmpa.w     a3,a2
[000120e4] 6f16                      ble.s      $000120FC
[000120e6] 2218                      move.l     (a0)+,d1
[000120e8] 22c1                      move.l     d1,(a1)+
[000120ea] d44b                      add.w      a3,d2
[000120ec] 6a06                      bpl.s      $000120F4
[000120ee] 51cb fff8                 dbf        d3,$000120E8
[000120f2] 4e75                      rts
[000120f4] 944a                      sub.w      a2,d2
[000120f6] 51cb ffee                 dbf        d3,$000120E6
[000120fa] 4e75                      rts
[000120fc] 2218                      move.l     (a0)+,d1
[000120fe] d64a                      add.w      a2,d3
[00012100] 6a08                      bpl.s      $0001210A
[00012102] 51ca fff8                 dbf        d2,$000120FC
[00012106] 22c1                      move.l     d1,(a1)+
[00012108] 4e75                      rts
[0001210a] 22c1                      move.l     d1,(a1)+
[0001210c] 964b                      sub.w      a3,d3
[0001210e] 51ca ffec                 dbf        d2,$000120FC
[00012112] 4e75                      rts
[00012114] 48e7 f000                 movem.l    d0-d3,-(a7)
[00012118] 206e 01d6                 movea.l    470(a6),a0
[0001211c] c7ee 01da                 muls.w     474(a6),d3
[00012120] d1c3                      adda.l     d3,a0
[00012122] 48c2                      ext.l      d2
[00012124] d482                      add.l      d2,d2
[00012126] d482                      add.l      d2,d2
[00012128] d1c2                      adda.l     d2,a0
[0001212a] 4a6e 01c8                 tst.w      456(a6)
[0001212e] 6632                      bne.s      $00012162
[00012130] 700f                      moveq.l    #15,d0
[00012132] c046                      and.w      d6,d0
[00012134] 4840                      swap       d0
[00012136] 3006                      move.w     d6,d0
[00012138] e848                      lsr.w      #4,d0
[0001213a] 24c0                      move.l     d0,(a2)+
[0001213c] 24ee 00f2                 move.l     242(a6),(a2)+
[00012140] 24ee 00f6                 move.l     246(a6),(a2)+
[00012144] 7003                      moveq.l    #3,d0
[00012146] c06e 01ee                 and.w      494(a6),d0
[0001214a] d040                      add.w      d0,d0
[0001214c] 303b 000c                 move.w     $0001215A(pc,d0.w),d0
[00012150] 43fb 0008                 lea.l      $0001215A(pc,d0.w),a1
[00012154] 4cdf 000f                 movem.l    (a7)+,d0-d3
[00012158] 4e75                      rts
[0001215a] 0040 0086                 ori.w      #$0086,d0
[0001215e] 00b4 00e4 34c6 700f       ori.l      #$00E434C6,15(a4,d7.w)
[00012166] c06e 01ee                 and.w      494(a6),d0
[0001216a] d040                      add.w      d0,d0
[0001216c] 303b 000c                 move.w     $0001217A(pc,d0.w),d0
[00012170] 43fb 0008                 lea.l      $0001217A(pc,d0.w),a1
[00012174] 4cdf 000f                 movem.l    (a7)+,d0-d3
[00012178] 4e75                      rts
[0001217a] 00f4 0100 010c            cmp2.b     ([a4],d0.w),d0 ; 68020+ only; reserved BD=0; reserved OD=0
[00012180] 011a                      btst       d0,(a2)+
[00012182] 0124                      btst       d0,-(a4)
[00012184] 0132 0134 0140 014c       btst       d0,([$0140014C,a2],d0.w) ; 68020+ only; reserved OD=0
[0001218c] 015a                      bchg       d0,(a2)+
[0001218e] 0168 0172                 bchg       d0,370(a0)
[00012192] 0180                      bclr       d0,d0
[00012194] 018e 019c                 movep.w    d0,412(a6)
[00012198] 01aa 2644                 bclr       d0,9796(a2)
[0001219c] 201a                      move.l     (a2)+,d0
[0001219e] 241a                      move.l     (a2)+,d2
[000121a0] 261a                      move.l     (a2)+,d3
[000121a2] 5340                      subq.w     #1,d0
[000121a4] 6b1e                      bmi.s      $000121C4
[000121a6] 3218                      move.w     (a0)+,d1
[000121a8] 780f                      moveq.l    #15,d4
[000121aa] d241                      add.w      d1,d1
[000121ac] 640c                      bcc.s      $000121BA
[000121ae] 22c2                      move.l     d2,(a1)+
[000121b0] 51cc fff8                 dbf        d4,$000121AA
[000121b4] 51c8 fff0                 dbf        d0,$000121A6
[000121b8] 600a                      bra.s      $000121C4
[000121ba] 22c3                      move.l     d3,(a1)+
[000121bc] 51cc ffec                 dbf        d4,$000121AA
[000121c0] 51c8 ffe4                 dbf        d0,$000121A6
[000121c4] 4840                      swap       d0
[000121c6] 3218                      move.w     (a0)+,d1
[000121c8] d241                      add.w      d1,d1
[000121ca] 640a                      bcc.s      $000121D6
[000121cc] 22c2                      move.l     d2,(a1)+
[000121ce] 51c8 fff8                 dbf        d0,$000121C8
[000121d2] 280b                      move.l     a3,d4
[000121d4] 4e75                      rts
[000121d6] 22c3                      move.l     d3,(a1)+
[000121d8] 51c8 ffee                 dbf        d0,$000121C8
[000121dc] 280b                      move.l     a3,d4
[000121de] 4e75                      rts
[000121e0] 201a                      move.l     (a2)+,d0
[000121e2] 241a                      move.l     (a2)+,d2
[000121e4] 5340                      subq.w     #1,d0
[000121e6] 6b14                      bmi.s      $000121FC
[000121e8] 3218                      move.w     (a0)+,d1
[000121ea] 760f                      moveq.l    #15,d3
[000121ec] d241                      add.w      d1,d1
[000121ee] 6402                      bcc.s      $000121F2
[000121f0] 2282                      move.l     d2,(a1)
[000121f2] 5889                      addq.l     #4,a1
[000121f4] 51cb fff6                 dbf        d3,$000121EC
[000121f8] 51c8 ffee                 dbf        d0,$000121E8
[000121fc] 4840                      swap       d0
[000121fe] 3218                      move.w     (a0)+,d1
[00012200] d241                      add.w      d1,d1
[00012202] 6402                      bcc.s      $00012206
[00012204] 2282                      move.l     d2,(a1)
[00012206] 5889                      addq.l     #4,a1
[00012208] 51c8 fff6                 dbf        d0,$00012200
[0001220c] 4e75                      rts
[0001220e] 201a                      move.l     (a2)+,d0
[00012210] 5340                      subq.w     #1,d0
[00012212] 6b16                      bmi.s      $0001222A
[00012214] 3218                      move.w     (a0)+,d1
[00012216] 760f                      moveq.l    #15,d3
[00012218] d241                      add.w      d1,d1
[0001221a] 55c2                      scs        d2
[0001221c] 4882                      ext.w      d2
[0001221e] 48c2                      ext.l      d2
[00012220] b599                      eor.l      d2,(a1)+
[00012222] 51cb fff4                 dbf        d3,$00012218
[00012226] 51c8 ffec                 dbf        d0,$00012214
[0001222a] 4840                      swap       d0
[0001222c] 3218                      move.w     (a0)+,d1
[0001222e] d241                      add.w      d1,d1
[00012230] 55c2                      scs        d2
[00012232] 4882                      ext.w      d2
[00012234] 48c2                      ext.l      d2
[00012236] b599                      eor.l      d2,(a1)+
[00012238] 51c8 fff4                 dbf        d0,$0001222E
[0001223c] 4e75                      rts
[0001223e] 201a                      move.l     (a2)+,d0
[00012240] 242a 0004                 move.l     4(a2),d2
[00012244] 5340                      subq.w     #1,d0
[00012246] 6b14                      bmi.s      $0001225C
[00012248] 3218                      move.w     (a0)+,d1
[0001224a] 760f                      moveq.l    #15,d3
[0001224c] d241                      add.w      d1,d1
[0001224e] 6502                      bcs.s      $00012252
[00012250] 22c2                      move.l     d2,(a1)+
[00012252] 5889                      addq.l     #4,a1
[00012254] 51cb fff6                 dbf        d3,$0001224C
[00012258] 51c8 ffee                 dbf        d0,$00012248
[0001225c] 4840                      swap       d0
[0001225e] 3218                      move.w     (a0)+,d1
[00012260] d241                      add.w      d1,d1
[00012262] 6502                      bcs.s      $00012266
[00012264] 2282                      move.l     d2,(a1)
[00012266] 5889                      addq.l     #4,a1
[00012268] 51c8 fff6                 dbf        d0,$00012260
[0001226c] 4e75                      rts
[0001226e] 3012                      move.w     (a2),d0
[00012270] 7200                      moveq.l    #0,d1
[00012272] 22c1                      move.l     d1,(a1)+
[00012274] 51c8 fffc                 dbf        d0,$00012272
[00012278] 4e75                      rts
[0001227a] 3012                      move.w     (a2),d0
[0001227c] 2218                      move.l     (a0)+,d1
[0001227e] c399                      and.l      d1,(a1)+
[00012280] 51c8 fffa                 dbf        d0,$0001227C
[00012284] 4e75                      rts
[00012286] 3012                      move.w     (a2),d0
[00012288] 2218                      move.l     (a0)+,d1
[0001228a] 4691                      not.l      (a1)
[0001228c] c399                      and.l      d1,(a1)+
[0001228e] 51c8 fff8                 dbf        d0,$00012288
[00012292] 4e75                      rts
[00012294] 301a                      move.w     (a2)+,d0
[00012296] 22d8                      move.l     (a0)+,(a1)+
[00012298] 51c8 fffc                 dbf        d0,$00012296
[0001229c] 4e75                      rts
[0001229e] 3012                      move.w     (a2),d0
[000122a0] 2218                      move.l     (a0)+,d1
[000122a2] 4681                      not.l      d1
[000122a4] c399                      and.l      d1,(a1)+
[000122a6] 51c8 fff8                 dbf        d0,$000122A0
[000122aa] 4e75                      rts
[000122ac] 4e75                      rts
[000122ae] 3012                      move.w     (a2),d0
[000122b0] 2218                      move.l     (a0)+,d1
[000122b2] b399                      eor.l      d1,(a1)+
[000122b4] 51c8 fffa                 dbf        d0,$000122B0
[000122b8] 4e75                      rts
[000122ba] 3012                      move.w     (a2),d0
[000122bc] 2218                      move.l     (a0)+,d1
[000122be] 8399                      or.l       d1,(a1)+
[000122c0] 51c8 fffa                 dbf        d0,$000122BC
[000122c4] 4e75                      rts
[000122c6] 3012                      move.w     (a2),d0
[000122c8] 2218                      move.l     (a0)+,d1
[000122ca] 8391                      or.l       d1,(a1)
[000122cc] 4699                      not.l      (a1)+
[000122ce] 51c8 fff8                 dbf        d0,$000122C8
[000122d2] 4e75                      rts
[000122d4] 3012                      move.w     (a2),d0
[000122d6] 2218                      move.l     (a0)+,d1
[000122d8] b391                      eor.l      d1,(a1)
[000122da] 4699                      not.l      (a1)+
[000122dc] 51c8 fff8                 dbf        d0,$000122D6
[000122e0] 4e75                      rts
[000122e2] 3012                      move.w     (a2),d0
[000122e4] 4699                      not.l      (a1)+
[000122e6] 51c8 fffc                 dbf        d0,$000122E4
[000122ea] 4e75                      rts
[000122ec] 3012                      move.w     (a2),d0
[000122ee] 2218                      move.l     (a0)+,d1
[000122f0] 4691                      not.l      (a1)
[000122f2] 8399                      or.l       d1,(a1)+
[000122f4] 51c8 fff8                 dbf        d0,$000122EE
[000122f8] 4e75                      rts
[000122fa] 3012                      move.w     (a2),d0
[000122fc] 2218                      move.l     (a0)+,d1
[000122fe] 4681                      not.l      d1
[00012300] 22c1                      move.l     d1,(a1)+
[00012302] 51c8 fff8                 dbf        d0,$000122FC
[00012306] 4e75                      rts
[00012308] 3012                      move.w     (a2),d0
[0001230a] 2218                      move.l     (a0)+,d1
[0001230c] 4681                      not.l      d1
[0001230e] 8399                      or.l       d1,(a1)+
[00012310] 51c8 fff8                 dbf        d0,$0001230A
[00012314] 4e75                      rts
[00012316] 3012                      move.w     (a2),d0
[00012318] 2218                      move.l     (a0)+,d1
[0001231a] c391                      and.l      d1,(a1)
[0001231c] 4699                      not.l      (a1)+
[0001231e] 51c8 fff8                 dbf        d0,$00012318
[00012322] 4e75                      rts
[00012324] 3012                      move.w     (a2),d0
[00012326] 72ff                      moveq.l    #-1,d1
[00012328] 22c1                      move.l     d1,(a1)+
[0001232a] 51c8 fffc                 dbf        d0,$00012328
[0001232e] 4e75                      rts
[00012330] 4e75                      rts

	.data
[00012332]                           dc.w $03c0
[00012334]                           dc.w $050c
[00012336]                           dc.b $00
[00012337]                           dc.b $30
[00012338]                           dc.b $00
[00012339]                           dc.b $40
[0001233a]                           dc.b $00
[0001233b]                           dc.b $7a
[0001233c]                           dc.w $010a
[0001233e]                           dc.w $024a
[00012340]                           dc.w $01d6
[00012342]                           dc.w $0728
[00012344]                           dc.b $00
[00012345]                           dc.b $00
