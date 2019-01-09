; ph_branch = 0x601a
; ph_tlen = 0x000022de
; ph_dlen = 0x00000014
; ph_blen = 0x00001dc2
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000010
; relocation bytes = 0x00000076

[00010000] 604e                      bra.s     $00010050
[00010002] 4f46                      lea.l     d6,b7 ; apollo only
[00010004] 4653                      not.w     (a3)
[00010006] 4352                      lea.l     (a2),b1 ; apollo only
[00010008] 4e00 0410                 cmpiw.l   #$0410,d0 ; apollo only
[0001000c] 0050 0000                 ori.w     #$0000,(a0)
[00010010] 0001 0052                 ori.b     #$52,d1
[00010014] 0001 007e                 ori.b     #$7E,d1
[00010018] 0001 0632                 ori.b     #$32,d1
[0001001c] 0001 06fa                 ori.b     #$FA,d1
[00010020] 0001 0080                 ori.b     #$80,d1
[00010024] 0001 00c0                 ori.b     #$C0,d1
[00010028] 0001 010e                 ori.b     #$0E,d1
[0001002c] 0001 0164                 ori.b     #$64,d1
[00010030] 0000 0000                 ori.b     #$00,d0
[00010034] 0000 0000                 ori.b     #$00,d0
[00010038] 0000 0000                 ori.b     #$00,d0
[0001003c] 0000 0000                 ori.b     #$00,d0
[00010040] 0001 0000                 ori.b     #$00,d1
[00010044] 0010 0002                 ori.b     #$02,(a0)
[00010048] 0081 0000 0000            ori.l     #$00000000,d1
[0001004e] 0000 4e75                 ori.b     #$75,d0
[00010052] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010056] 23c8 0001 22f2            move.l    a0,$000122F2
[0001005c] 6100 0532                 bsr       $00010590
[00010060] 6100 0124                 bsr       $00010186
[00010064] 6100 0100                 bsr       $00010166
[00010068] 7005                      moveq.l   #5,d0
[0001006a] 7206                      moveq.l   #6,d1
[0001006c] 7405                      moveq.l   #5,d2
[0001006e] 6100 0546                 bsr       $000105B6
[00010072] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00010076] 203c 0000 0658            move.l    #$00000658,d0
[0001007c] 4e75                      rts
[0001007e] 4e75                      rts
[00010080] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[00010084] 20ee 0010                 move.l    16(a6),(a0)+
[00010088] 4258                      clr.w     (a0)+
[0001008a] 20ee 000c                 move.l    12(a6),(a0)+
[0001008e] 7027                      moveq.l   #39,d0
[00010090] 247a 2260                 movea.l   $000122F2(pc),a2
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
[000100c6] 247a 222a                 movea.l   $000122F2(pc),a2
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
[00010112] 43fa 009c                 lea.l     $000101B0(pc),a1
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
[00010134] 30ee 01a2                 move.w    418(a6),(a0)+
[00010138] 30e9 0002                 move.w    2(a1),(a0)+
[0001013c] 706f                      moveq.l   #111,d0
[0001013e] 43fa 0170                 lea.l     $000102B0(pc),a1
[00010142] 082e 0007 01a3            btst      #7,419(a6)
[00010148] 6704                      beq.s     $0001014E
[0001014a] 43fa 0084                 lea.l     $000101D0(pc),a1
[0001014e] 30d9                      move.w    (a1)+,(a0)+
[00010150] 51c8 fffc                 dbf       d0,$0001014E
[00010154] 303c 008f                 move.w    #$008F,d0
[00010158] 4258                      clr.w     (a0)+
[0001015a] 51c8 fffc                 dbf       d0,$00010158
[0001015e] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010162] 4e75                      rts
[00010164] 4e75                      rts
[00010166] 48e7 80e0                 movem.l   d0/a0-a2,-(a7)
[0001016a] 247a 2186                 movea.l   $000122F2(pc),a2
[0001016e] 246a 0028                 movea.l   40(a2),a2
[00010172] 2052                      movea.l   (a2),a0
[00010174] 43fa 2180                 lea.l     $000122F6(pc),a1
[00010178] 703f                      moveq.l   #63,d0
[0001017a] 22d8                      move.l    (a0)+,(a1)+
[0001017c] 51c8 fffc                 dbf       d0,$0001017A
[00010180] 4cdf 0701                 movem.l   (a7)+,d0/a0-a2
[00010184] 4e75                      rts
[00010186] 48e7 e0c0                 movem.l   d0-d2/a0-a1,-(a7)
[0001018a] 41fa 226a                 lea.l     $000123F6(pc),a0
[0001018e] 7000                      moveq.l   #0,d0
[00010190] 3200                      move.w    d0,d1
[00010192] 7407                      moveq.l   #7,d2
[00010194] 4258                      clr.w     (a0)+
[00010196] d201                      add.b     d1,d1
[00010198] 6504                      bcs.s     $0001019E
[0001019a] 4668 fffe                 not.w     -2(a0)
[0001019e] 51ca fff4                 dbf       d2,$00010194
[000101a2] 5240                      addq.w    #1,d0
[000101a4] b07c 0100                 cmp.w     #$0100,d0
[000101a8] 6de6                      blt.s     $00010190
[000101aa] 4cdf 0307                 movem.l   (a7)+,d0-d2/a0-a1
[000101ae] 4e75                      rts
[000101b0] 0002 0002                 ori.b     #$02,d2
[000101b4] 0010 0001                 ori.b     #$01,(a0)
[000101b8] 0000 0000                 ori.b     #$00,d0
[000101bc] 0000 0000                 ori.b     #$00,d0
[000101c0] 0005 0006                 ori.b     #$06,d5
[000101c4] 0005 0000                 ori.b     #$00,d5
[000101c8] 0000 0000                 ori.b     #$00,d0
[000101cc] 0001 0000                 ori.b     #$00,d1
[000101d0] 0003 0004                 ori.b     #$04,d3
[000101d4] 0005 0006                 ori.b     #$06,d5
[000101d8] 0007 ffff                 ori.b     #$FF,d7
[000101dc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101e4] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000101ec] ffff ffff 000d 000e       vperm     #$000D000E,e23,e23,e23
[000101f4] 000f 0000                 ori.b     #$00,a7 ; apollo only
[000101f8] 0001 0002                 ori.b     #$02,d1
[000101fc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010204] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001020c] ffff ffff 0008 0009       vperm     #$00080009,e23,e23,e23
[00010214] 000a 000b                 ori.b     #$0B,a2 ; apollo only
[00010218] 000c ffff                 ori.b     #$FF,a4 ; apollo only
[0001021c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010224] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001022c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010234] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001023c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010244] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001024c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010254] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001025c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010264] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001026c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010274] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001027c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010284] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001028c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010294] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001029c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102a4] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ac] ffff ffff 000b 000c       vperm     #$000B000C,e23,e23,e23
[000102b4] 000d 000e                 ori.b     #$0E,a5 ; apollo only
[000102b8] 000f ffff                 ori.b     #$FF,a7 ; apollo only
[000102bc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102c4] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102cc] ffff ffff 0005 0006       vperm     #$00050006,e23,e23,e23
[000102d4] 0007 0008                 ori.b     #$08,d7
[000102d8] 0009 000a                 ori.b     #$0A,a1 ; apollo only
[000102dc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102e4] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[000102ec] ffff ffff 0000 0001       vperm     #$00000001,e23,e23,e23
[000102f4] 0002 0003                 ori.b     #$03,d2
[000102f8] 0004 ffff                 ori.b     #$FF,d4
[000102fc] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010304] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001030c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010314] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001031c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010324] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001032c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010334] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001033c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010344] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001034c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010354] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001035c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010364] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001036c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010374] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001037c] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[00010384] ffff ffff ffff ffff       vperm     #$FFFFFFFF,e23,e23,e23
[0001038c] ffff ffff ffff f000       vperm     #$FFFFF000,e23,e23,e23
[00010394] 0720                      btst      d3,-(a0)
[00010396] ffe0 001e                 unpack1632.q-(b0),e8 ; apollo only
[0001039a] e193                      roxl.l    #8,d3
[0001039c] 1e57                      movea.l   (a7),b7 ; apollo only
[0001039e] dedb                      adda.w    (a3)+,a7
[000103a0] 8410                      or.b      (a0),d2
[000103a2] 8000                      or.b      d0,d0
[000103a4] 0400 b507                 subi.b    #$07,d0
[000103a8] 0010 8010                 ori.b     #$10,(a0)
[000103ac] 0410 18c3                 subi.b    #$C3,(a0)
[000103b0] 0006 000c                 ori.b     #$0C,d6
[000103b4] 0013 0019                 ori.b     #$19,(a3)
[000103b8] 001f 0180                 ori.b     #$80,(a7)+
[000103bc] 0186                      bclr      d0,d6
[000103be] 018c 0193                 movep.w   d0,403(a4)
[000103c2] 0199                      bclr      d0,(a1)+
[000103c4] 019f                      bclr      d0,(a7)+
[000103c6] 0320                      btst      d1,-(a0)
[000103c8] 0326                      btst      d1,-(a6)
[000103ca] 032c 0333                 btst      d1,819(a4)
[000103ce] 0339 033f 04c0            btst      d1,$033F04C0
[000103d4] 04c6                      ff1.l     d6 ; ColdFire isa_c only
[000103d6] 04cc                      dc.w      $04CC ; illegal
[000103d8] 04d3 04d9                 cmp2.l    (a3),d0 ; 68020+ only
[000103dc] 04df                      dc.w      $04DF ; illegal
[000103de] 0660 0666                 addi.w    #$0666,-(a0)
[000103e2] 066c 0673 0679            addi.w    #$0673,1657(a4)
[000103e8] 067f 07e0                 addi.w    #$07E0,???
[000103ec] 07e6                      bset      d3,-(a6)
[000103ee] 07ec 07f3                 bset      d3,2035(a4)
[000103f2] 07f9 07ff 3000            bset      d3,$07FF3000
[000103f8] 3006                      move.w    d6,d0
[000103fa] 300c                      move.w    a4,d0
[000103fc] 3013                      move.w    (a3),d0
[000103fe] 3019                      move.w    (a1)+,d0
[00010400] 301f                      move.w    (a7)+,d0
[00010402] 3180 3186 318c            move.w    d0,([],d3.w,$318C) ; 68020+ only; reserved BD=0
[00010408] 0018 3199                 ori.b     #$99,(a0)+
[0001040c] 319f 3320 3326            move.w    (a7)+,($3326,a0,d3.w*2) ; 68020+ only
[00010412] 332c 3333                 move.w    13107(a4),-(a1)
[00010416] 3339 333f 34c0            move.w    $333F34C0,-(a1)
[0001041c] 34c6                      move.w    d6,(a2)+
[0001041e] 34cc                      move.w    a4,(a2)+
[00010420] 34d3                      move.w    (a3),(a2)+
[00010422] 34d9                      move.w    (a1)+,(a2)+
[00010424] 34df                      move.w    (a7)+,(a2)+
[00010426] 3660                      movea.w   -(a0),a3
[00010428] 3666                      movea.w   -(a6),a3
[0001042a] 366c 3673                 movea.w   13939(a4),a3
[0001042e] 3679 367f 37e0            movea.w   $367F37E0,a3
[00010434] 37e6 37ec 37f3            move.w    -(a6),([$37F3,zpc],zd3.w*8) ; 68020+ only; reserved OD=0
[0001043a] 37f9 37ff 6000 6006       move.w    $37FF6000,$00010442(pc,d6.w) ; apollo only
[00010442] 600c                      bra.s     $00010450
[00010444] 6013                      bra.s     $00010459
[00010446] 6019                      bra.s     $00010461
[00010448] 601f                      bra.s     $00010469
[0001044a] 6180                      bsr.s     $000103CC
[0001044c] 6186                      bsr.s     $000103D4
[0001044e] 618c                      bsr.s     $000103DC
[00010450] 6193                      bsr.s     $000103E5
[00010452] 6199                      bsr.s     $000103ED
[00010454] 619f                      bsr.s     $000103F5
[00010456] 6320                      bls.s     $00010478
[00010458] 6326                      bls.s     $00010480
[0001045a] 632c                      bls.s     $00010488
[0001045c] 6333                      bls.s     $00010491
[0001045e] 6339                      bls.s     $00010499
[00010460] 633f                      bls.s     $000104A1
[00010462] 64c0                      bcc.s     $00010424
[00010464] 64c6                      bcc.s     $0001042C
[00010466] 64cc                      bcc.s     $00010434
[00010468] 64d3                      bcc.s     $0001043D
[0001046a] 64d9                      bcc.s     $00010445
[0001046c] 64df                      bcc.s     $0001044D
[0001046e] 6660                      bne.s     $000104D0
[00010470] 6666                      bne.s     $000104D8
[00010472] 666c                      bne.s     $000104E0
[00010474] 6673                      bne.s     $000104E9
[00010476] 6679                      bne.s     $000104F1
[00010478] 667f                      bne.s     $000104F9
[0001047a] 67e0                      beq.s     $0001045C
[0001047c] 67e6                      beq.s     $00010464
[0001047e] 67ec                      beq.s     $0001046C
[00010480] 67f3                      beq.s     $00010475
[00010482] 67f9                      beq.s     $0001047D
[00010484] 67ff 9800 9806            beq.l     $98019C8C ; 68020+ only
[0001048a] 980c                      sub.b     a4,d4
[0001048c] 9813                      sub.b     (a3),d4
[0001048e] 9819                      sub.b     (a1)+,d4
[00010490] 981f                      sub.b     (a7)+,d4
[00010492] 9980                      subx.l    d0,d4
[00010494] 9986                      subx.l    d6,d4
[00010496] 998c                      subx.l    -(a4),-(a4)
[00010498] 9993                      sub.l     d4,(a3)
[0001049a] 9999                      sub.l     d4,(a1)+
[0001049c] 999f                      sub.l     d4,(a7)+
[0001049e] 9b20                      sub.b     d5,-(a0)
[000104a0] 9b26                      sub.b     d5,-(a6)
[000104a2] 9b2c 9b33                 sub.b     d5,-25805(a4)
[000104a6] 9b39 9b3f 9cc0            sub.b     d5,$9B3F9CC0
[000104ac] 9cc6                      suba.w    d6,a6
[000104ae] 9ccc                      suba.w    a4,a6
[000104b0] 9cd3                      suba.w    (a3),a6
[000104b2] 9cd9                      suba.w    (a1)+,a6
[000104b4] 9cdf                      suba.w    (a7)+,a6
[000104b6] 9e60                      sub.w     -(a0),d7
[000104b8] 9e66                      sub.w     -(a6),d7
[000104ba] 9e6c 9e73                 sub.w     -24973(a4),d7
[000104be] 9e79 9e7f 9fe0            sub.w     $9E7F9FE0,d7
[000104c4] 9fe6                      suba.l    -(a6),a7
[000104c6] 9fec 9ff3                 suba.l    -24589(a4),a7
[000104ca] 9ff9 9fff c800            suba.l    $9FFFC800,a7
[000104d0] c806                      and.b     d6,d4
[000104d2] c80c                      and.b     a4,d4 ; apollo only
[000104d4] c813                      and.b     (a3),d4
[000104d6] c819                      and.b     (a1)+,d4
[000104d8] c81f                      and.b     (a7)+,d4
[000104da] c980                      cmp.l     b0,d4 ; apollo only
[000104dc] c986                      cmp.l     b6,d4 ; apollo only
[000104de] c98c                      exg       d4,a4
[000104e0] c993                      and.l     d4,(a3)
[000104e2] c999                      and.l     d4,(a1)+
[000104e4] c99f                      and.l     d4,(a7)+
[000104e6] cb20                      and.b     d5,-(a0)
[000104e8] cb26                      and.b     d5,-(a6)
[000104ea] cb2c cb33                 and.b     d5,-13517(a4)
[000104ee] cb39 cb3f ccc0            and.b     d5,$CB3FCCC0
[000104f4] ccc6                      mulu.w    d6,d6
[000104f6] cccc                      mulu.w    a4,d6
[000104f8] ccd3                      mulu.w    (a3),d6
[000104fa] ccd9                      mulu.w    (a1)+,d6
[000104fc] ccdf                      mulu.w    (a7)+,d6
[000104fe] ce60                      and.w     -(a0),d7
[00010500] ce66                      and.w     -(a6),d7
[00010502] ce6c ce73                 and.w     -12685(a4),d7
[00010506] ce79 ce7f cfe0            and.w     $CE7FCFE0,d7
[0001050c] cfe6                      muls.w    -(a6),d7
[0001050e] cfec cff3                 muls.w    -12301(a4),d7
[00010512] cff9 cfff f800            muls.w    $CFFFF800,d7
[00010518] f806 f80c f813            lpGEN     #$F813,d6
[0001051e] f819 f81f f980            lpGEN     #$F980,(a1)+
[00010524] f986                      dc.w      $F986 ; illegal
[00010526] f98c                      dc.w      $F98C ; illegal
[00010528] f993                      dc.w      $F993 ; illegal
[0001052a] f999                      dc.w      $F999 ; illegal
[0001052c] f99f                      dc.w      $F99F ; illegal
[0001052e] fb20                      wddata.b  -(a0)
[00010530] fb26                      wddata.b  -(a6)
[00010532] fb2c fb33                 wddata.b  -1229(a4)
[00010536] fb39 fb3f fcc0            wddata.b  $FB3FFCC0
[0001053c] fcc6 fccc fcd3            cp6B??.l  $FCCE0211
[00010542] fcd9 fcdf fe60            cp6B??.l  $FCE103A4
[00010548] fe66 fe6c                 nfS??     -(a6)
[0001054c] fe73 fe79 fe7f            nfS??     127(a3,a7.l*8) ; 68020+ only
[00010552] ffe0                      dc.w      $FFE0 ; illegal
[00010554] ffe6                      dc.w      $FFE6 ; illegal
[00010556] ffec                      dc.w      $FFEC ; illegal
[00010558] fff3                      dc.w      $FFF3 ; illegal
[0001055a] fff9                      dc.w      $FFF9 ; illegal
[0001055c] f000                      dc.w      $F000 ; illegal
[0001055e] e000                      asr.b     #8,d0
[00010560] c000                      and.b     d0,d0
[00010562] b000                      cmp.b     d0,d0
[00010564] 8000                      or.b      d0,d0
[00010566] 4800                      nbcd      d0
[00010568] 1800                      move.b    d0,d4
[0001056a] 0780                      bclr      d3,d0
[0001056c] 0720                      btst      d3,-(a0)
[0001056e] 0600 0580                 addi.b    #$80,d0
[00010572] 0400 0260                 subi.b    #$60,d0
[00010576] 00c0                      bitrev.l  d0 ; ColdFire isa_c only
[00010578] 0003 0009                 ori.b     #$09,d3
[0001057c] 0010 0016                 ori.b     #$16,(a0)
[00010580] 3193 001c                 move.w    (a3),28(a0,d0.w)
[00010584] f79e                      dc.w      $F79E ; illegal
[00010586] e73c                      rol.b     d3,d4
[00010588] c618                      and.b     (a0)+,d3
[0001058a] b596                      eor.l     d2,(a6)
[0001058c] 4a69 0000                 tst.w     0(a1)
[00010590] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00010594] a000                      ALINE     #$0000
[00010596] 907c 2070                 sub.w     #$2070,d0
[0001059a] 6714                      beq.s     $000105B0
[0001059c] 41fa fa62                 lea.l     $00010000(pc),a0
[000105a0] 43f9 0001 22de            lea.l     $000122DE,a1
[000105a6] 3219                      move.w    (a1)+,d1
[000105a8] 6706                      beq.s     $000105B0
[000105aa] d0c1                      adda.w    d1,a0
[000105ac] d150                      add.w     d0,(a0)
[000105ae] 60f6                      bra.s     $000105A6
[000105b0] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[000105b4] 4e75                      rts
[000105b6] 48e7 fec0                 movem.l   d0-d6/a0-a1,-(a7)
[000105ba] 7601                      moveq.l   #1,d3
[000105bc] e16b                      lsl.w     d0,d3
[000105be] 5343                      subq.w    #1,d3
[000105c0] 3003                      move.w    d3,d0
[000105c2] 7601                      moveq.l   #1,d3
[000105c4] e36b                      lsl.w     d1,d3
[000105c6] 5343                      subq.w    #1,d3
[000105c8] 3203                      move.w    d3,d1
[000105ca] 7601                      moveq.l   #1,d3
[000105cc] e56b                      lsl.w     d2,d3
[000105ce] 5343                      subq.w    #1,d3
[000105d0] 3403                      move.w    d3,d2
[000105d2] 48a7 e000                 movem.w   d0-d2,-(a7)
[000105d6] 41fa 2e1e                 lea.l     $000133F6(pc),a0
[000105da] 7a02                      moveq.l   #2,d5
[000105dc] 7600                      moveq.l   #0,d3
[000105de] 3803                      move.w    d3,d4
[000105e0] c8c0                      mulu.w    d0,d4
[000105e2] d8bc 0000 01f4            add.l     #$000001F4,d4
[000105e8] 88fc 03e8                 divu.w    #$03E8,d4
[000105ec] 10c4                      move.b    d4,(a0)+
[000105ee] 5243                      addq.w    #1,d3
[000105f0] b67c 03e8                 cmp.w     #$03E8,d3
[000105f4] 6fe8                      ble.s     $000105DE
[000105f6] 3001                      move.w    d1,d0
[000105f8] 3202                      move.w    d2,d1
[000105fa] 5288                      addq.l    #1,a0
[000105fc] 51cd ffde                 dbf       d5,$000105DC
[00010600] 4c9f 0007                 movem.w   (a7)+,d0-d2
[00010604] 43fa 39ae                 lea.l     $00013FB4(pc),a1
[00010608] 7c02                      moveq.l   #2,d6
[0001060a] 7600                      moveq.l   #0,d3
[0001060c] 3a00                      move.w    d0,d5
[0001060e] e24d                      lsr.w     #1,d5
[00010610] 48c5                      ext.l     d5
[00010612] 3803                      move.w    d3,d4
[00010614] c8fc 03e8                 mulu.w    #$03E8,d4
[00010618] d885                      add.l     d5,d4
[0001061a] 88c0                      divu.w    d0,d4
[0001061c] 32c4                      move.w    d4,(a1)+
[0001061e] 5243                      addq.w    #1,d3
[00010620] b640                      cmp.w     d0,d3
[00010622] 6fee                      ble.s     $00010612
[00010624] 3001                      move.w    d1,d0
[00010626] 3202                      move.w    d2,d1
[00010628] 51ce ffe0                 dbf       d6,$0001060A
[0001062c] 4cdf 037f                 movem.l   (a7)+,d0-d6/a0-a1
[00010630] 4e75                      rts
[00010632] 48e7 c0e0                 movem.l   d0-d1/a0-a2,-(a7)
[00010636] 3d7c 000f 01b4            move.w    #$000F,436(a6)
[0001063c] 3d7c 00ff 0014            move.w    #$00FF,20(a6)
[00010642] 2d7c 0001 11de 01f4       move.l    #$000111DE,500(a6)
[0001064a] 2d7c 0001 0b48 01f8       move.l    #$00010B48,504(a6)
[00010652] 2d7c 0001 0bda 01fc       move.l    #$00010BDA,508(a6)
[0001065a] 2d7c 0001 0df6 0200       move.l    #$00010DF6,512(a6)
[00010662] 2d7c 0001 1034 0204       move.l    #$00011034,516(a6)
[0001066a] 2d7c 0001 1936 0208       move.l    #$00011936,520(a6)
[00010672] 2d7c 0001 1b72 020c       move.l    #$00011B72,524(a6)
[0001067a] 2d7c 0001 0afe 0210       move.l    #$00010AFE,528(a6)
[00010682] 2d7c 0001 227a 0214       move.l    #$0001227A,532(a6)
[0001068a] 2d7c 0001 0ab6 021c       move.l    #$00010AB6,540(a6)
[00010692] 2d7c 0001 0ada 0218       move.l    #$00010ADA,536(a6)
[0001069a] 2d7c 0001 07e4 0220       move.l    #$000107E4,544(a6)
[000106a2] 2d7c 0001 076e 0224       move.l    #$0001076E,548(a6)
[000106aa] 2d7c 0001 06fc 0228       move.l    #$000106FC,552(a6)
[000106b2] 2d7c 0001 072e 022c       move.l    #$0001072E,556(a6)
[000106ba] 2d7c 0001 07d2 0230       move.l    #$000107D2,560(a6)
[000106c2] 2d7c 0001 07e0 0234       move.l    #$000107E0,564(a6)
[000106ca] 41fa fcc4                 lea.l     $00010390(pc),a0
[000106ce] 43ee 0458                 lea.l     1112(a6),a1
[000106d2] 45fa 1c22                 lea.l     $000122F6(pc),a2
[000106d6] 323c 00ff                 move.w    #$00FF,d1
[000106da] 7000                      moveq.l   #0,d0
[000106dc] 101a                      move.b    (a2)+,d0
[000106de] d040                      add.w     d0,d0
[000106e0] 3030 0000                 move.w    0(a0,d0.w),d0
[000106e4] 082e 0007 01a3            btst      #7,419(a6)
[000106ea] 6702                      beq.s     $000106EE
[000106ec] e158                      rol.w     #8,d0
[000106ee] 32c0                      move.w    d0,(a1)+
[000106f0] 51c9 ffe8                 dbf       d1,$000106DA
[000106f4] 4cdf 0703                 movem.l   (a7)+,d0-d1/a0-a2
[000106f8] 4e75                      rts
[000106fa] 4e75                      rts
[000106fc] 43ee 0458                 lea.l     1112(a6),a1
[00010700] d643                      add.w     d3,d3
[00010702] d2c3                      adda.w    d3,a1
[00010704] 41fa 2cf0                 lea.l     $000133F6(pc),a0
[00010708] 1030 0000                 move.b    0(a0,d0.w),d0
[0001070c] ed48                      lsl.w     #6,d0
[0001070e] 41e8 03ea                 lea.l     1002(a0),a0
[00010712] 8030 1000                 or.b      0(a0,d1.w),d0
[00010716] eb48                      lsl.w     #5,d0
[00010718] 41e8 03ea                 lea.l     1002(a0),a0
[0001071c] 8030 2000                 or.b      0(a0,d2.w),d0
[00010720] 082e 0007 01a3            btst      #7,419(a6)
[00010726] 6702                      beq.s     $0001072A
[00010728] e158                      rol.w     #8,d0
[0001072a] 3280                      move.w    d0,(a1)
[0001072c] 4e75                      rts
[0001072e] 43ee 0458                 lea.l     1112(a6),a1
[00010732] d040                      add.w     d0,d0
[00010734] 3431 0000                 move.w    0(a1,d0.w),d2
[00010738] 082e 0007 01a3            btst      #7,419(a6)
[0001073e] 6702                      beq.s     $00010742
[00010740] e15a                      rol.w     #8,d2
[00010742] 43fa 3870                 lea.l     $00013FB4(pc),a1
[00010746] ed5a                      rol.w     #6,d2
[00010748] 703e                      moveq.l   #62,d0
[0001074a] c042                      and.w     d2,d0
[0001074c] 3031 0000                 move.w    0(a1,d0.w),d0
[00010750] 43e9 0040                 lea.l     64(a1),a1
[00010754] ed5a                      rol.w     #6,d2
[00010756] 727e                      moveq.l   #126,d1
[00010758] c242                      and.w     d2,d1
[0001075a] 3231 1000                 move.w    0(a1,d1.w),d1
[0001075e] 43e9 0080                 lea.l     128(a1),a1
[00010762] eb5a                      rol.w     #5,d2
[00010764] c47c 003e                 and.w     #$003E,d2
[00010768] 3431 2000                 move.w    0(a1,d2.w),d2
[0001076c] 4e75                      rts
[0001076e] b07c 0010                 cmp.w     #$0010,d0
[00010772] 6614                      bne.s     $00010788
[00010774] 22d8                      move.l    (a0)+,(a1)+
[00010776] 22d8                      move.l    (a0)+,(a1)+
[00010778] 22d8                      move.l    (a0)+,(a1)+
[0001077a] 22d8                      move.l    (a0)+,(a1)+
[0001077c] 22d8                      move.l    (a0)+,(a1)+
[0001077e] 22d8                      move.l    (a0)+,(a1)+
[00010780] 22d8                      move.l    (a0)+,(a1)+
[00010782] 22d8                      move.l    (a0)+,(a1)+
[00010784] 7000                      moveq.l   #0,d0
[00010786] 4e75                      rts
[00010788] 48e7 6000                 movem.l   d1-d2,-(a7)
[0001078c] 343c 00ff                 move.w    #$00FF,d2
[00010790] 082e 0007 01a3            btst      #7,419(a6)
[00010796] 661c                      bne.s     $000107B4
[00010798] 2018                      move.l    (a0)+,d0
[0001079a] 2200                      move.l    d0,d1
[0001079c] e689                      lsr.l     #3,d1
[0001079e] 3200                      move.w    d0,d1
[000107a0] e489                      lsr.l     #2,d1
[000107a2] 1200                      move.b    d0,d1
[000107a4] e689                      lsr.l     #3,d1
[000107a6] 32c1                      move.w    d1,(a1)+
[000107a8] 51ca ffee                 dbf       d2,$00010798
[000107ac] 4cdf 0006                 movem.l   (a7)+,d1-d2
[000107b0] 700f                      moveq.l   #15,d0
[000107b2] 4e75                      rts
[000107b4] 2018                      move.l    (a0)+,d0
[000107b6] 2200                      move.l    d0,d1
[000107b8] e689                      lsr.l     #3,d1
[000107ba] 3200                      move.w    d0,d1
[000107bc] e489                      lsr.l     #2,d1
[000107be] 1200                      move.b    d0,d1
[000107c0] e689                      lsr.l     #3,d1
[000107c2] e159                      rol.w     #8,d1
[000107c4] 32c1                      move.w    d1,(a1)+
[000107c6] 51ca ffec                 dbf       d2,$000107B4
[000107ca] 4cdf 0006                 movem.l   (a7)+,d1-d2
[000107ce] 700f                      moveq.l   #15,d0
[000107d0] 4e75                      rts
[000107d2] 41ee 0458                 lea.l     1112(a6),a0
[000107d6] d040                      add.w     d0,d0
[000107d8] d0c0                      adda.w    d0,a0
[000107da] 7000                      moveq.l   #0,d0
[000107dc] 3010                      move.w    (a0),d0
[000107de] 4e75                      rts
[000107e0] 70ff                      moveq.l   #-1,d0
[000107e2] 4e75                      rts
[000107e4] 2f0e                      move.l    a6,-(a7)
[000107e6] 7000                      moveq.l   #0,d0
[000107e8] 3028 000c                 move.w    12(a0),d0
[000107ec] 3228 0006                 move.w    6(a0),d1
[000107f0] c2e8 0008                 mulu.w    8(a0),d1
[000107f4] 7400                      moveq.l   #0,d2
[000107f6] 4a68 000a                 tst.w     10(a0)
[000107fa] 6602                      bne.s     $000107FE
[000107fc] 7401                      moveq.l   #1,d2
[000107fe] 3342 000a                 move.w    d2,10(a1)
[00010802] 2050                      movea.l   (a0),a0
[00010804] 2251                      movea.l   (a1),a1
[00010806] 5381                      subq.l    #1,d1
[00010808] 6b4e                      bmi.s     $00010858
[0001080a] 5340                      subq.w    #1,d0
[0001080c] 6700 0292                 beq       $00010AA0
[00010810] 907c 000f                 sub.w     #$000F,d0
[00010814] 6642                      bne.s     $00010858
[00010816] d442                      add.w     d2,d2
[00010818] d442                      add.w     d2,d2
[0001081a] 247b 2040                 movea.l   $0001085C(pc,d2.w),a2
[0001081e] b3c8                      cmpa.l    a0,a1
[00010820] 6630                      bne.s     $00010852
[00010822] 2601                      move.l    d1,d3
[00010824] 5283                      addq.l    #1,d3
[00010826] eb8b                      lsl.l     #5,d3
[00010828] b6ae 0024                 cmp.l     36(a6),d3
[0001082c] 6e1e                      bgt.s     $0001084C
[0001082e] 2f03                      move.l    d3,-(a7)
[00010830] 2f08                      move.l    a0,-(a7)
[00010832] 226e 0020                 movea.l   32(a6),a1
[00010836] 2f09                      move.l    a1,-(a7)
[00010838] 2001                      move.l    d1,d0
[0001083a] 5280                      addq.l    #1,d0
[0001083c] 4e92                      jsr       (a2)
[0001083e] 205f                      movea.l   (a7)+,a0
[00010840] 225f                      movea.l   (a7)+,a1
[00010842] 221f                      move.l    (a7)+,d1
[00010844] e289                      lsr.l     #1,d1
[00010846] 5381                      subq.l    #1,d1
[00010848] 6000 025a                 bra       $00010AA4
[0001084c] 247b 2016                 movea.l   $00010864(pc,d2.w),a2
[00010850] 6004                      bra.s     $00010856
[00010852] 2001                      move.l    d1,d0
[00010854] 5280                      addq.l    #1,d0
[00010856] 4e92                      jsr       (a2)
[00010858] 2c5f                      movea.l   (a7)+,a6
[0001085a] 4e75                      rts
[0001085c] 0001 0a22                 ori.b     #$22,d1
[00010860] 0001 09a8                 ori.b     #$A8,d1
[00010864] 0001 086c                 ori.b     #$6C,d1
[00010868] 0001 093e                 ori.b     #$3E,d1
[0001086c] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010870] 2001                      move.l    d1,d0
[00010872] 780f                      moveq.l   #15,d4
[00010874] 6100 0102                 bsr       $00010978
[00010878] 4cdf 0302                 movem.l   (a7)+,d1/a0-a1
[0001087c] 2c41                      movea.l   d1,a6
[0001087e] 2f08                      move.l    a0,-(a7)
[00010880] 2f28 001c                 move.l    28(a0),-(a7)
[00010884] 2f28 0018                 move.l    24(a0),-(a7)
[00010888] 2f28 0014                 move.l    20(a0),-(a7)
[0001088c] 2f28 0010                 move.l    16(a0),-(a7)
[00010890] 2f09                      move.l    a1,-(a7)
[00010892] 5289                      addq.l    #1,a1
[00010894] 6118                      bsr.s     $000108AE
[00010896] 225f                      movea.l   (a7)+,a1
[00010898] 204f                      movea.l   a7,a0
[0001089a] 6112                      bsr.s     $000108AE
[0001089c] 4fef 0010                 lea.l     16(a7),a7
[000108a0] 205f                      movea.l   (a7)+,a0
[000108a2] 41e8 0020                 lea.l     32(a0),a0
[000108a6] 220e                      move.l    a6,d1
[000108a8] 5381                      subq.l    #1,d1
[000108aa] 6ad0                      bpl.s     $0001087C
[000108ac] 4e75                      rts
[000108ae] 700f                      moveq.l   #15,d0
[000108b0] 4840                      swap      d0
[000108b2] 3e18                      move.w    (a0)+,d7
[000108b4] 3c18                      move.w    (a0)+,d6
[000108b6] 3a18                      move.w    (a0)+,d5
[000108b8] 3818                      move.w    (a0)+,d4
[000108ba] 3618                      move.w    (a0)+,d3
[000108bc] 3418                      move.w    (a0)+,d2
[000108be] 3218                      move.w    (a0)+,d1
[000108c0] 3018                      move.w    (a0)+,d0
[000108c2] 4840                      swap      d0
[000108c4] 4847                      swap      d7
[000108c6] 4840                      swap      d0
[000108c8] d040                      add.w     d0,d0
[000108ca] df07                      addx.b    d7,d7
[000108cc] d241                      add.w     d1,d1
[000108ce] df07                      addx.b    d7,d7
[000108d0] d442                      add.w     d2,d2
[000108d2] df07                      addx.b    d7,d7
[000108d4] d643                      add.w     d3,d3
[000108d6] df07                      addx.b    d7,d7
[000108d8] d844                      add.w     d4,d4
[000108da] df07                      addx.b    d7,d7
[000108dc] da45                      add.w     d5,d5
[000108de] df07                      addx.b    d7,d7
[000108e0] dc46                      add.w     d6,d6
[000108e2] df07                      addx.b    d7,d7
[000108e4] 4847                      swap      d7
[000108e6] de47                      add.w     d7,d7
[000108e8] 4847                      swap      d7
[000108ea] df07                      addx.b    d7,d7
[000108ec] 12c7                      move.b    d7,(a1)+
[000108ee] 5289                      addq.l    #1,a1
[000108f0] 4840                      swap      d0
[000108f2] 51c8 ffd2                 dbf       d0,$000108C6
[000108f6] 4e75                      rts
[000108f8] 700f                      moveq.l   #15,d0
[000108fa] 4840                      swap      d0
[000108fc] 4847                      swap      d7
[000108fe] 1e18                      move.b    (a0)+,d7
[00010900] 5288                      addq.l    #1,a0
[00010902] de07                      add.b     d7,d7
[00010904] d140                      addx.w    d0,d0
[00010906] de07                      add.b     d7,d7
[00010908] d341                      addx.w    d1,d1
[0001090a] de07                      add.b     d7,d7
[0001090c] d542                      addx.w    d2,d2
[0001090e] de07                      add.b     d7,d7
[00010910] d743                      addx.w    d3,d3
[00010912] de07                      add.b     d7,d7
[00010914] d944                      addx.w    d4,d4
[00010916] de07                      add.b     d7,d7
[00010918] db45                      addx.w    d5,d5
[0001091a] de07                      add.b     d7,d7
[0001091c] dd46                      addx.w    d6,d6
[0001091e] de07                      add.b     d7,d7
[00010920] 4847                      swap      d7
[00010922] df47                      addx.w    d7,d7
[00010924] 4840                      swap      d0
[00010926] 51c8 ffd2                 dbf       d0,$000108FA
[0001092a] 4840                      swap      d0
[0001092c] 32c7                      move.w    d7,(a1)+
[0001092e] 32c6                      move.w    d6,(a1)+
[00010930] 32c5                      move.w    d5,(a1)+
[00010932] 32c4                      move.w    d4,(a1)+
[00010934] 32c3                      move.w    d3,(a1)+
[00010936] 32c2                      move.w    d2,(a1)+
[00010938] 32c1                      move.w    d1,(a1)+
[0001093a] 32c0                      move.w    d0,(a1)+
[0001093c] 4e75                      rts
[0001093e] 48e7 40c0                 movem.l   d1/a0-a1,-(a7)
[00010942] 2c41                      movea.l   d1,a6
[00010944] 2f08                      move.l    a0,-(a7)
[00010946] 45e8 0020                 lea.l     32(a0),a2
[0001094a] 2f22                      move.l    -(a2),-(a7)
[0001094c] 2f22                      move.l    -(a2),-(a7)
[0001094e] 2f22                      move.l    -(a2),-(a7)
[00010950] 2f22                      move.l    -(a2),-(a7)
[00010952] 2f22                      move.l    -(a2),-(a7)
[00010954] 2f22                      move.l    -(a2),-(a7)
[00010956] 2f22                      move.l    -(a2),-(a7)
[00010958] 2f22                      move.l    -(a2),-(a7)
[0001095a] 5288                      addq.l    #1,a0
[0001095c] 619a                      bsr.s     $000108F8
[0001095e] 204f                      movea.l   a7,a0
[00010960] 6196                      bsr.s     $000108F8
[00010962] 4fef 0020                 lea.l     32(a7),a7
[00010966] 205f                      movea.l   (a7)+,a0
[00010968] 41e8 0020                 lea.l     32(a0),a0
[0001096c] 220e                      move.l    a6,d1
[0001096e] 5381                      subq.l    #1,d1
[00010970] 6ad0                      bpl.s     $00010942
[00010972] 4cdf 0310                 movem.l   (a7)+,d4/a0-a1
[00010976] 700f                      moveq.l   #15,d0
[00010978] 5384                      subq.l    #1,d4
[0001097a] 6b2a                      bmi.s     $000109A6
[0001097c] 7400                      moveq.l   #0,d2
[0001097e] 2204                      move.l    d4,d1
[00010980] d1c0                      adda.l    d0,a0
[00010982] 41f0 0802                 lea.l     2(a0,d0.l),a0
[00010986] 3a10                      move.w    (a0),d5
[00010988] 2248                      movea.l   a0,a1
[0001098a] 2448                      movea.l   a0,a2
[0001098c] d480                      add.l     d0,d2
[0001098e] 2602                      move.l    d2,d3
[00010990] 6004                      bra.s     $00010996
[00010992] 2449                      movea.l   a1,a2
[00010994] 34a1                      move.w    -(a1),(a2)
[00010996] 5383                      subq.l    #1,d3
[00010998] 6af8                      bpl.s     $00010992
[0001099a] 3285                      move.w    d5,(a1)
[0001099c] 5381                      subq.l    #1,d1
[0001099e] 6ae0                      bpl.s     $00010980
[000109a0] 204a                      movea.l   a2,a0
[000109a2] 5380                      subq.l    #1,d0
[000109a4] 6ad6                      bpl.s     $0001097C
[000109a6] 4e75                      rts
[000109a8] d080                      add.l     d0,d0
[000109aa] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[000109ae] 5288                      addq.l    #1,a0
[000109b0] 610a                      bsr.s     $000109BC
[000109b2] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[000109b6] 2400                      move.l    d0,d2
[000109b8] e78a                      lsl.l     #3,d2
[000109ba] d3c2                      adda.l    d2,a1
[000109bc] 45f1 0800                 lea.l     0(a1,d0.l),a2
[000109c0] 47f2 0800                 lea.l     0(a2,d0.l),a3
[000109c4] 49f3 0800                 lea.l     0(a3,d0.l),a4
[000109c8] e588                      lsl.l     #2,d0
[000109ca] 2a40                      movea.l   d0,a5
[000109cc] 2c41                      movea.l   d1,a6
[000109ce] 700f                      moveq.l   #15,d0
[000109d0] 4840                      swap      d0
[000109d2] 4847                      swap      d7
[000109d4] 1e18                      move.b    (a0)+,d7
[000109d6] 5288                      addq.l    #1,a0
[000109d8] de07                      add.b     d7,d7
[000109da] d140                      addx.w    d0,d0
[000109dc] de07                      add.b     d7,d7
[000109de] d341                      addx.w    d1,d1
[000109e0] de07                      add.b     d7,d7
[000109e2] d542                      addx.w    d2,d2
[000109e4] de07                      add.b     d7,d7
[000109e6] d743                      addx.w    d3,d3
[000109e8] de07                      add.b     d7,d7
[000109ea] d944                      addx.w    d4,d4
[000109ec] de07                      add.b     d7,d7
[000109ee] db45                      addx.w    d5,d5
[000109f0] de07                      add.b     d7,d7
[000109f2] dd46                      addx.w    d6,d6
[000109f4] de07                      add.b     d7,d7
[000109f6] 4847                      swap      d7
[000109f8] df47                      addx.w    d7,d7
[000109fa] 4840                      swap      d0
[000109fc] 51c8 ffd2                 dbf       d0,$000109D0
[00010a00] 4840                      swap      d0
[00010a02] 32c7                      move.w    d7,(a1)+
[00010a04] 34c6                      move.w    d6,(a2)+
[00010a06] 36c5                      move.w    d5,(a3)+
[00010a08] 38c4                      move.w    d4,(a4)+
[00010a0a] 3383 d8fe                 move.w    d3,-2(a1,a5.l)
[00010a0e] 3582 d8fe                 move.w    d2,-2(a2,a5.l)
[00010a12] 3781 d8fe                 move.w    d1,-2(a3,a5.l)
[00010a16] 3980 d8fe                 move.w    d0,-2(a4,a5.l)
[00010a1a] 220e                      move.l    a6,d1
[00010a1c] 5381                      subq.l    #1,d1
[00010a1e] 6aac                      bpl.s     $000109CC
[00010a20] 4e75                      rts
[00010a22] d080                      add.l     d0,d0
[00010a24] 48e7 c0c0                 movem.l   d0-d1/a0-a1,-(a7)
[00010a28] 5289                      addq.l    #1,a1
[00010a2a] 610a                      bsr.s     $00010A36
[00010a2c] 4cdf 0303                 movem.l   (a7)+,d0-d1/a0-a1
[00010a30] 2400                      move.l    d0,d2
[00010a32] e78a                      lsl.l     #3,d2
[00010a34] d1c2                      adda.l    d2,a0
[00010a36] 45f0 0800                 lea.l     0(a0,d0.l),a2
[00010a3a] 47f2 0800                 lea.l     0(a2,d0.l),a3
[00010a3e] 49f3 0800                 lea.l     0(a3,d0.l),a4
[00010a42] e588                      lsl.l     #2,d0
[00010a44] 2a40                      movea.l   d0,a5
[00010a46] 2c41                      movea.l   d1,a6
[00010a48] 700f                      moveq.l   #15,d0
[00010a4a] 4840                      swap      d0
[00010a4c] 3e18                      move.w    (a0)+,d7
[00010a4e] 3c1a                      move.w    (a2)+,d6
[00010a50] 3a1b                      move.w    (a3)+,d5
[00010a52] 381c                      move.w    (a4)+,d4
[00010a54] 3630 d8fe                 move.w    -2(a0,a5.l),d3
[00010a58] 3432 d8fe                 move.w    -2(a2,a5.l),d2
[00010a5c] 3233 d8fe                 move.w    -2(a3,a5.l),d1
[00010a60] 3034 d8fe                 move.w    -2(a4,a5.l),d0
[00010a64] 4840                      swap      d0
[00010a66] 4847                      swap      d7
[00010a68] 4840                      swap      d0
[00010a6a] d040                      add.w     d0,d0
[00010a6c] df07                      addx.b    d7,d7
[00010a6e] d241                      add.w     d1,d1
[00010a70] df07                      addx.b    d7,d7
[00010a72] d442                      add.w     d2,d2
[00010a74] df07                      addx.b    d7,d7
[00010a76] d643                      add.w     d3,d3
[00010a78] df07                      addx.b    d7,d7
[00010a7a] d844                      add.w     d4,d4
[00010a7c] df07                      addx.b    d7,d7
[00010a7e] da45                      add.w     d5,d5
[00010a80] df07                      addx.b    d7,d7
[00010a82] dc46                      add.w     d6,d6
[00010a84] df07                      addx.b    d7,d7
[00010a86] 4847                      swap      d7
[00010a88] de47                      add.w     d7,d7
[00010a8a] 4847                      swap      d7
[00010a8c] df07                      addx.b    d7,d7
[00010a8e] 12c7                      move.b    d7,(a1)+
[00010a90] 5289                      addq.l    #1,a1
[00010a92] 4840                      swap      d0
[00010a94] 51c8 ffd2                 dbf       d0,$00010A68
[00010a98] 220e                      move.l    a6,d1
[00010a9a] 5381                      subq.l    #1,d1
[00010a9c] 6aa8                      bpl.s     $00010A46
[00010a9e] 4e75                      rts
[00010aa0] b3c8                      cmpa.l    a0,a1
[00010aa2] 670e                      beq.s     $00010AB2
[00010aa4] e289                      lsr.l     #1,d1
[00010aa6] 6504                      bcs.s     $00010AAC
[00010aa8] 32d8                      move.w    (a0)+,(a1)+
[00010aaa] 6002                      bra.s     $00010AAE
[00010aac] 22d8                      move.l    (a0)+,(a1)+
[00010aae] 5381                      subq.l    #1,d1
[00010ab0] 6afa                      bpl.s     $00010AAC
[00010ab2] 2c5f                      movea.l   (a7)+,a6
[00010ab4] 4e75                      rts
[00010ab6] 4a6e 01b2                 tst.w     434(a6)
[00010aba] 670a                      beq.s     $00010AC6
[00010abc] 206e 01ae                 movea.l   430(a6),a0
[00010ac0] c3ee 01b2                 muls.w    434(a6),d1
[00010ac4] 6008                      bra.s     $00010ACE
[00010ac6] 2078 044e                 movea.l   ($0000044E).w,a0
[00010aca] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010ace] d1c1                      adda.l    d1,a0
[00010ad0] d040                      add.w     d0,d0
[00010ad2] d0c0                      adda.w    d0,a0
[00010ad4] 7000                      moveq.l   #0,d0
[00010ad6] 3010                      move.w    (a0),d0
[00010ad8] 4e75                      rts
[00010ada] 4a6e 01b2                 tst.w     434(a6)
[00010ade] 670a                      beq.s     $00010AEA
[00010ae0] 206e 01ae                 movea.l   430(a6),a0
[00010ae4] c3ee 01b2                 muls.w    434(a6),d1
[00010ae8] 6008                      bra.s     $00010AF2
[00010aea] 2078 044e                 movea.l   ($0000044E).w,a0
[00010aee] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010af2] d1c1                      adda.l    d1,a0
[00010af4] d040                      add.w     d0,d0
[00010af6] d0c0                      adda.w    d0,a0
[00010af8] 3082                      move.w    d2,(a0)
[00010afa] 4e75                      rts
[00010afc] 4e75                      rts
[00010afe] 2278 044e                 movea.l   ($0000044E).w,a1
[00010b02] 3678 206e                 movea.w   ($0000206E).w,a3
[00010b06] 4a6e 01b2                 tst.w     434(a6)
[00010b0a] 6708                      beq.s     $00010B14
[00010b0c] 226e 01ae                 movea.l   430(a6),a1
[00010b10] 366e 01b2                 movea.w   434(a6),a3
[00010b14] 426e 01ec                 clr.w     492(a6)
[00010b18] 3d6e 0064 01ea            move.w    100(a6),490(a6)
[00010b1e] 3d6e 003c 01ee            move.w    60(a6),494(a6)
[00010b24] 3d7c 0000 01c8            move.w    #$0000,456(a6)
[00010b2a] 3d6e 01b4 01dc            move.w    436(a6),476(a6)
[00010b30] 0c6e 0003 01ee            cmpi.w    #$0003,494(a6)
[00010b36] 6600 0e14                 bne       $0001194C
[00010b3a] 426e 01ea                 clr.w     490(a6)
[00010b3e] 3d6e 0064 01ec            move.w    100(a6),492(a6)
[00010b44] 6000 0e06                 bra       $0001194C
[00010b48] 4a6e 00ca                 tst.w     202(a6)
[00010b4c] 675a                      beq.s     $00010BA8
[00010b4e] 2f08                      move.l    a0,-(a7)
[00010b50] 206e 00c6                 movea.l   198(a6),a0
[00010b54] 780f                      moveq.l   #15,d4
[00010b56] c841                      and.w     d1,d4
[00010b58] eb4c                      lsl.w     #5,d4
[00010b5a] d0c4                      adda.w    d4,a0
[00010b5c] 3838 206e                 move.w    ($0000206E).w,d4
[00010b60] 2278 044e                 movea.l   ($0000044E).w,a1
[00010b64] 4a6e 01b2                 tst.w     434(a6)
[00010b68] 6708                      beq.s     $00010B72
[00010b6a] 382e 01b2                 move.w    434(a6),d4
[00010b6e] 226e 01ae                 movea.l   430(a6),a1
[00010b72] 9440                      sub.w     d0,d2
[00010b74] d040                      add.w     d0,d0
[00010b76] c2c4                      mulu.w    d4,d1
[00010b78] 48c0                      ext.l     d0
[00010b7a] d280                      add.l     d0,d1
[00010b7c] 7e20                      moveq.l   #32,d7
[00010b7e] 7c0f                      moveq.l   #15,d6
[00010b80] b446                      cmp.w     d6,d2
[00010b82] 6c02                      bge.s     $00010B86
[00010b84] 3c02                      move.w    d2,d6
[00010b86] 701f                      moveq.l   #31,d0
[00010b88] c041                      and.w     d1,d0
[00010b8a] 3a30 0000                 move.w    0(a0,d0.w),d5
[00010b8e] 3802                      move.w    d2,d4
[00010b90] e84c                      lsr.w     #4,d4
[00010b92] 2241                      movea.l   d1,a1
[00010b94] 3285                      move.w    d5,(a1)
[00010b96] d2c7                      adda.w    d7,a1
[00010b98] 51cc fffa                 dbf       d4,$00010B94
[00010b9c] 5481                      addq.l    #2,d1
[00010b9e] 5342                      subq.w    #1,d2
[00010ba0] 51ce ffe4                 dbf       d6,$00010B86
[00010ba4] 205f                      movea.l   (a7)+,a0
[00010ba6] 4e75                      rts
[00010ba8] 226e 00c6                 movea.l   198(a6),a1
[00010bac] 780f                      moveq.l   #15,d4
[00010bae] c841                      and.w     d1,d4
[00010bb0] d844                      add.w     d4,d4
[00010bb2] 3c31 4000                 move.w    0(a1,d4.w),d6
[00010bb6] 43ee 0458                 lea.l     1112(a6),a1
[00010bba] 3a2e 00be                 move.w    190(a6),d5
[00010bbe] da45                      add.w     d5,d5
[00010bc0] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010bc4] 3805                      move.w    d5,d4
[00010bc6] 4844                      swap      d4
[00010bc8] 3805                      move.w    d5,d4
[00010bca] 4a6e 01b2                 tst.w     434(a6)
[00010bce] 672e                      beq.s     $00010BFE
[00010bd0] 226e 01ae                 movea.l   430(a6),a1
[00010bd4] c3ee 01b2                 muls.w    434(a6),d1
[00010bd8] 602c                      bra.s     $00010C06
[00010bda] 43ee 0458                 lea.l     1112(a6),a1
[00010bde] 3a2e 0046                 move.w    70(a6),d5
[00010be2] da45                      add.w     d5,d5
[00010be4] 3a31 5000                 move.w    0(a1,d5.w),d5
[00010be8] 3805                      move.w    d5,d4
[00010bea] 4844                      swap      d4
[00010bec] 3805                      move.w    d5,d4
[00010bee] 4a6e 01b2                 tst.w     434(a6)
[00010bf2] 670a                      beq.s     $00010BFE
[00010bf4] 226e 01ae                 movea.l   430(a6),a1
[00010bf8] c3ee 01b2                 muls.w    434(a6),d1
[00010bfc] 6008                      bra.s     $00010C06
[00010bfe] 2278 044e                 movea.l   ($0000044E).w,a1
[00010c02] c3f8 206e                 muls.w    ($0000206E).w,d1
[00010c06] 48c0                      ext.l     d0
[00010c08] d280                      add.l     d0,d1
[00010c0a] d280                      add.l     d0,d1
[00010c0c] d3c1                      adda.l    d1,a1
[00010c0e] de47                      add.w     d7,d7
[00010c10] 3e3b 7008                 move.w    $00010C1A(pc,d7.w),d7
[00010c14] 4efb 7004                 jmp       $00010C1A(pc,d7.w)
[00010c18] 4e75                      rts
[00010c1a] 0008 009a                 ori.b     #$9A,a0 ; apollo only
[00010c1e] 0144                      bchg      d0,d4
[00010c20] 0098 bc7c ffff            ori.l     #$BC7CFFFF,(a0)+
[00010c26] 6700 01c4                 beq       $00010DEC
[00010c2a] 2f0b                      move.l    a3,-(a7)
[00010c2c] 3f05                      move.w    d5,-(a7)
[00010c2e] 9440                      sub.w     d0,d2
[00010c30] c07c 000f                 and.w     #$000F,d0
[00010c34] e17e                      rol.w     d0,d6
[00010c36] 7220                      moveq.l   #32,d1
[00010c38] 700f                      moveq.l   #15,d0
[00010c3a] b440                      cmp.w     d0,d2
[00010c3c] 6c02                      bge.s     $00010C40
[00010c3e] 3002                      move.w    d2,d0
[00010c40] dc46                      add.w     d6,d6
[00010c42] 54c5                      scc       d5
[00010c44] 4885                      ext.w     d5
[00010c46] 8a57                      or.w      (a7),d5
[00010c48] 3802                      move.w    d2,d4
[00010c4a] e84c                      lsr.w     #4,d4
[00010c4c] 3e04                      move.w    d4,d7
[00010c4e] e84c                      lsr.w     #4,d4
[00010c50] 4647                      not.w     d7
[00010c52] 0247 000f                 andi.w    #$000F,d7
[00010c56] de47                      add.w     d7,d7
[00010c58] de47                      add.w     d7,d7
[00010c5a] 2649                      movea.l   a1,a3
[00010c5c] 4efb 7002                 jmp       $00010C60(pc,d7.w)
[00010c60] 3685                      move.w    d5,(a3)
[00010c62] d6c1                      adda.w    d1,a3
[00010c64] 3685                      move.w    d5,(a3)
[00010c66] d6c1                      adda.w    d1,a3
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
[00010ca0] 51cc ffbe                 dbf       d4,$00010C60
[00010ca4] 5489                      addq.l    #2,a1
[00010ca6] 5342                      subq.w    #1,d2
[00010ca8] 51c8 ff96                 dbf       d0,$00010C40
[00010cac] 3a1f                      move.w    (a7)+,d5
[00010cae] 265f                      movea.l   (a7)+,a3
[00010cb0] 4e75                      rts
[00010cb2] 4646                      not.w     d6
[00010cb4] bc7c ffff                 cmp.w     #$FFFF,d6
[00010cb8] 6700 0132                 beq       $00010DEC
[00010cbc] 2f0b                      move.l    a3,-(a7)
[00010cbe] 9440                      sub.w     d0,d2
[00010cc0] c07c 000f                 and.w     #$000F,d0
[00010cc4] e17e                      rol.w     d0,d6
[00010cc6] 7220                      moveq.l   #32,d1
[00010cc8] 700f                      moveq.l   #15,d0
[00010cca] b440                      cmp.w     d0,d2
[00010ccc] 6c02                      bge.s     $00010CD0
[00010cce] 3002                      move.w    d2,d0
[00010cd0] dc46                      add.w     d6,d6
[00010cd2] 645c                      bcc.s     $00010D30
[00010cd4] 3802                      move.w    d2,d4
[00010cd6] e84c                      lsr.w     #4,d4
[00010cd8] 3e04                      move.w    d4,d7
[00010cda] e84c                      lsr.w     #4,d4
[00010cdc] 4647                      not.w     d7
[00010cde] 0247 000f                 andi.w    #$000F,d7
[00010ce2] de47                      add.w     d7,d7
[00010ce4] de47                      add.w     d7,d7
[00010ce6] 2649                      movea.l   a1,a3
[00010ce8] 4efb 7002                 jmp       $00010CEC(pc,d7.w)
[00010cec] 3685                      move.w    d5,(a3)
[00010cee] d6c1                      adda.w    d1,a3
[00010cf0] 3685                      move.w    d5,(a3)
[00010cf2] d6c1                      adda.w    d1,a3
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
[00010d2c] 51cc ffbe                 dbf       d4,$00010CEC
[00010d30] 5489                      addq.l    #2,a1
[00010d32] 5342                      subq.w    #1,d2
[00010d34] 51c8 ff9a                 dbf       d0,$00010CD0
[00010d38] 265f                      movea.l   (a7)+,a3
[00010d3a] 4e75                      rts
[00010d3c] 5489                      addq.l    #2,a1
[00010d3e] 51ca 0004                 dbf       d2,$00010D44
[00010d42] 4e75                      rts
[00010d44] e24a                      lsr.w     #1,d2
[00010d46] 78ff                      moveq.l   #-1,d4
[00010d48] 4644                      not.w     d4
[00010d4a] 2009                      move.l    a1,d0
[00010d4c] 0800 0001                 btst      #1,d0
[00010d50] 6704                      beq.s     $00010D56
[00010d52] 5589                      subq.l    #2,a1
[00010d54] 4684                      not.l     d4
[00010d56] b999                      eor.l     d4,(a1)+
[00010d58] 51ca fffc                 dbf       d2,$00010D56
[00010d5c] 4e75                      rts
[00010d5e] 9440                      sub.w     d0,d2
[00010d60] c07c 000f                 and.w     #$000F,d0
[00010d64] e17e                      rol.w     d0,d6
[00010d66] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010d6a] 67d8                      beq.s     $00010D44
[00010d6c] bc7c 5555                 cmp.w     #$5555,d6
[00010d70] 67ca                      beq.s     $00010D3C
[00010d72] 2f0b                      move.l    a3,-(a7)
[00010d74] 7aff                      moveq.l   #-1,d5
[00010d76] 7220                      moveq.l   #32,d1
[00010d78] 700f                      moveq.l   #15,d0
[00010d7a] b440                      cmp.w     d0,d2
[00010d7c] 6c02                      bge.s     $00010D80
[00010d7e] 3002                      move.w    d2,d0
[00010d80] dc46                      add.w     d6,d6
[00010d82] 645c                      bcc.s     $00010DE0
[00010d84] 3802                      move.w    d2,d4
[00010d86] e84c                      lsr.w     #4,d4
[00010d88] 3e04                      move.w    d4,d7
[00010d8a] e84c                      lsr.w     #4,d4
[00010d8c] 4647                      not.w     d7
[00010d8e] 0247 000f                 andi.w    #$000F,d7
[00010d92] de47                      add.w     d7,d7
[00010d94] de47                      add.w     d7,d7
[00010d96] 2649                      movea.l   a1,a3
[00010d98] 4efb 7002                 jmp       $00010D9C(pc,d7.w)
[00010d9c] 4653                      not.w     (a3)
[00010d9e] d6c1                      adda.w    d1,a3
[00010da0] 4653                      not.w     (a3)
[00010da2] d6c1                      adda.w    d1,a3
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
[00010ddc] 51cc ffbe                 dbf       d4,$00010D9C
[00010de0] 5489                      addq.l    #2,a1
[00010de2] 5342                      subq.w    #1,d2
[00010de4] 51c8 ff9a                 dbf       d0,$00010D80
[00010de8] 265f                      movea.l   (a7)+,a3
[00010dea] 4e75                      rts
[00010dec] 9440                      sub.w     d0,d2
[00010dee] 32c4                      move.w    d4,(a1)+
[00010df0] 51ca fffc                 dbf       d2,$00010DEE
[00010df4] 4e75                      rts
[00010df6] 9641                      sub.w     d1,d3
[00010df8] 43ee 0458                 lea.l     1112(a6),a1
[00010dfc] 382e 0046                 move.w    70(a6),d4
[00010e00] d844                      add.w     d4,d4
[00010e02] 3831 4000                 move.w    0(a1,d4.w),d4
[00010e06] 2278 044e                 movea.l   ($0000044E).w,a1
[00010e0a] 3a38 206e                 move.w    ($0000206E).w,d5
[00010e0e] 4a6e 01b2                 tst.w     434(a6)
[00010e12] 6708                      beq.s     $00010E1C
[00010e14] 226e 01ae                 movea.l   430(a6),a1
[00010e18] 3a2e 01b2                 move.w    434(a6),d5
[00010e1c] c3c5                      muls.w    d5,d1
[00010e1e] d3c1                      adda.l    d1,a1
[00010e20] d040                      add.w     d0,d0
[00010e22] d2c0                      adda.w    d0,a1
[00010e24] de47                      add.w     d7,d7
[00010e26] 3e3b 7006                 move.w    $00010E2E(pc,d7.w),d7
[00010e2a] 4efb 7002                 jmp       $00010E2E(pc,d7.w)
J1:
[00010e2e] 0126                      dc.w $0126   ; $00010f54-$00010e2e
[00010e30] 000a                      dc.w $000a   ; $00010e38-$00010e2e
[00010e32] 009c                      dc.w $009c   ; $00010eca-$00010e2e
[00010e34] 0008                      dc.w $0008   ; $00010e36-$00010e2e
[00010e36] 4646                      not.w     d6
[00010e38] 3f05                      move.w    d5,-(a7)
[00010e3a] 48c5                      ext.l     d5
[00010e3c] e98d                      lsl.l     #4,d5
[00010e3e] 700f                      moveq.l   #15,d0
[00010e40] b640                      cmp.w     d0,d3
[00010e42] 6c02                      bge.s     $00010E46
[00010e44] 3003                      move.w    d3,d0
[00010e46] 2409                      move.l    a1,d2
[00010e48] dc46                      add.w     d6,d6
[00010e4a] 645a                      bcc.s     $00010EA6
[00010e4c] 3203                      move.w    d3,d1
[00010e4e] e849                      lsr.w     #4,d1
[00010e50] 3e01                      move.w    d1,d7
[00010e52] e849                      lsr.w     #4,d1
[00010e54] 4647                      not.w     d7
[00010e56] 0247 000f                 andi.w    #$000F,d7
[00010e5a] de47                      add.w     d7,d7
[00010e5c] de47                      add.w     d7,d7
[00010e5e] 4efb 7002                 jmp       $00010E62(pc,d7.w)
[00010e62] 3284                      move.w    d4,(a1)
[00010e64] d3c5                      adda.l    d5,a1
[00010e66] 3284                      move.w    d4,(a1)
[00010e68] d3c5                      adda.l    d5,a1
[00010e6a] 3284                      move.w    d4,(a1)
[00010e6c] d3c5                      adda.l    d5,a1
[00010e6e] 3284                      move.w    d4,(a1)
[00010e70] d3c5                      adda.l    d5,a1
[00010e72] 3284                      move.w    d4,(a1)
[00010e74] d3c5                      adda.l    d5,a1
[00010e76] 3284                      move.w    d4,(a1)
[00010e78] d3c5                      adda.l    d5,a1
[00010e7a] 3284                      move.w    d4,(a1)
[00010e7c] d3c5                      adda.l    d5,a1
[00010e7e] 3284                      move.w    d4,(a1)
[00010e80] d3c5                      adda.l    d5,a1
[00010e82] 3284                      move.w    d4,(a1)
[00010e84] d3c5                      adda.l    d5,a1
[00010e86] 3284                      move.w    d4,(a1)
[00010e88] d3c5                      adda.l    d5,a1
[00010e8a] 3284                      move.w    d4,(a1)
[00010e8c] d3c5                      adda.l    d5,a1
[00010e8e] 3284                      move.w    d4,(a1)
[00010e90] d3c5                      adda.l    d5,a1
[00010e92] 3284                      move.w    d4,(a1)
[00010e94] d3c5                      adda.l    d5,a1
[00010e96] 3284                      move.w    d4,(a1)
[00010e98] d3c5                      adda.l    d5,a1
[00010e9a] 3284                      move.w    d4,(a1)
[00010e9c] d3c5                      adda.l    d5,a1
[00010e9e] 3284                      move.w    d4,(a1)
[00010ea0] d3c5                      adda.l    d5,a1
[00010ea2] 51c9 ffbe                 dbf       d1,$00010E62
[00010ea6] 2242                      movea.l   d2,a1
[00010ea8] d2d7                      adda.w    (a7),a1
[00010eaa] 5343                      subq.w    #1,d3
[00010eac] 51c8 ff98                 dbf       d0,$00010E46
[00010eb0] 548f                      addq.l    #2,a7
[00010eb2] 4e75                      rts
[00010eb4] d2c5                      adda.w    d5,a1
[00010eb6] 51cb 0004                 dbf       d3,$00010EBC
[00010eba] 4e75                      rts
[00010ebc] da45                      add.w     d5,d5
[00010ebe] e24b                      lsr.w     #1,d3
[00010ec0] b951                      eor.w     d4,(a1)
[00010ec2] d2c5                      adda.w    d5,a1
[00010ec4] 51cb fffa                 dbf       d3,$00010EC0
[00010ec8] 4e75                      rts
[00010eca] 78ff                      moveq.l   #-1,d4
[00010ecc] bc7c aaaa                 cmp.w     #$AAAA,d6
[00010ed0] 67ea                      beq.s     $00010EBC
[00010ed2] bc7c 5555                 cmp.w     #$5555,d6
[00010ed6] 67dc                      beq.s     $00010EB4
[00010ed8] 3f05                      move.w    d5,-(a7)
[00010eda] 48c5                      ext.l     d5
[00010edc] e98d                      lsl.l     #4,d5
[00010ede] 700f                      moveq.l   #15,d0
[00010ee0] b640                      cmp.w     d0,d3
[00010ee2] 6c02                      bge.s     $00010EE6
[00010ee4] 3003                      move.w    d3,d0
[00010ee6] 2409                      move.l    a1,d2
[00010ee8] dc46                      add.w     d6,d6
[00010eea] 645a                      bcc.s     $00010F46
[00010eec] 3203                      move.w    d3,d1
[00010eee] e849                      lsr.w     #4,d1
[00010ef0] 3e01                      move.w    d1,d7
[00010ef2] e849                      lsr.w     #4,d1
[00010ef4] 4647                      not.w     d7
[00010ef6] 0247 000f                 andi.w    #$000F,d7
[00010efa] de47                      add.w     d7,d7
[00010efc] de47                      add.w     d7,d7
[00010efe] 4efb 7002                 jmp       $00010F02(pc,d7.w)
[00010f02] b951                      eor.w     d4,(a1)
[00010f04] d3c5                      adda.l    d5,a1
[00010f06] b951                      eor.w     d4,(a1)
[00010f08] d3c5                      adda.l    d5,a1
[00010f0a] b951                      eor.w     d4,(a1)
[00010f0c] d3c5                      adda.l    d5,a1
[00010f0e] b951                      eor.w     d4,(a1)
[00010f10] d3c5                      adda.l    d5,a1
[00010f12] b951                      eor.w     d4,(a1)
[00010f14] d3c5                      adda.l    d5,a1
[00010f16] b951                      eor.w     d4,(a1)
[00010f18] d3c5                      adda.l    d5,a1
[00010f1a] b951                      eor.w     d4,(a1)
[00010f1c] d3c5                      adda.l    d5,a1
[00010f1e] b951                      eor.w     d4,(a1)
[00010f20] d3c5                      adda.l    d5,a1
[00010f22] b951                      eor.w     d4,(a1)
[00010f24] d3c5                      adda.l    d5,a1
[00010f26] b951                      eor.w     d4,(a1)
[00010f28] d3c5                      adda.l    d5,a1
[00010f2a] b951                      eor.w     d4,(a1)
[00010f2c] d3c5                      adda.l    d5,a1
[00010f2e] b951                      eor.w     d4,(a1)
[00010f30] d3c5                      adda.l    d5,a1
[00010f32] b951                      eor.w     d4,(a1)
[00010f34] d3c5                      adda.l    d5,a1
[00010f36] b951                      eor.w     d4,(a1)
[00010f38] d3c5                      adda.l    d5,a1
[00010f3a] b951                      eor.w     d4,(a1)
[00010f3c] d3c5                      adda.l    d5,a1
[00010f3e] b951                      eor.w     d4,(a1)
[00010f40] d3c5                      adda.l    d5,a1
[00010f42] 51c9 ffbe                 dbf       d1,$00010F02
[00010f46] 2242                      movea.l   d2,a1
[00010f48] d2d7                      adda.w    (a7),a1
[00010f4a] 5343                      subq.w    #1,d3
[00010f4c] 51c8 ff98                 dbf       d0,$00010EE6
[00010f50] 548f                      addq.l    #2,a7
[00010f52] 4e75                      rts
[00010f54] bc7c ffff                 cmp.w     #$FFFF,d6
[00010f58] 6700 0082                 beq       $00010FDC
[00010f5c] 3f05                      move.w    d5,-(a7)
[00010f5e] 48c5                      ext.l     d5
[00010f60] e98d                      lsl.l     #4,d5
[00010f62] 700f                      moveq.l   #15,d0
[00010f64] b640                      cmp.w     d0,d3
[00010f66] 6c02                      bge.s     $00010F6A
[00010f68] 3003                      move.w    d3,d0
[00010f6a] 2f09                      move.l    a1,-(a7)
[00010f6c] dc46                      add.w     d6,d6
[00010f6e] 54c2                      scc       d2
[00010f70] 4882                      ext.w     d2
[00010f72] 8444                      or.w      d4,d2
[00010f74] 3203                      move.w    d3,d1
[00010f76] e849                      lsr.w     #4,d1
[00010f78] 3e01                      move.w    d1,d7
[00010f7a] e849                      lsr.w     #4,d1
[00010f7c] 4647                      not.w     d7
[00010f7e] 0247 000f                 andi.w    #$000F,d7
[00010f82] de47                      add.w     d7,d7
[00010f84] de47                      add.w     d7,d7
[00010f86] 4efb 7002                 jmp       $00010F8A(pc,d7.w)
[00010f8a] 3282                      move.w    d2,(a1)
[00010f8c] d3c5                      adda.l    d5,a1
[00010f8e] 3282                      move.w    d2,(a1)
[00010f90] d3c5                      adda.l    d5,a1
[00010f92] 3282                      move.w    d2,(a1)
[00010f94] d3c5                      adda.l    d5,a1
[00010f96] 3282                      move.w    d2,(a1)
[00010f98] d3c5                      adda.l    d5,a1
[00010f9a] 3282                      move.w    d2,(a1)
[00010f9c] d3c5                      adda.l    d5,a1
[00010f9e] 3282                      move.w    d2,(a1)
[00010fa0] d3c5                      adda.l    d5,a1
[00010fa2] 3282                      move.w    d2,(a1)
[00010fa4] d3c5                      adda.l    d5,a1
[00010fa6] 3282                      move.w    d2,(a1)
[00010fa8] d3c5                      adda.l    d5,a1
[00010faa] 3282                      move.w    d2,(a1)
[00010fac] d3c5                      adda.l    d5,a1
[00010fae] 3282                      move.w    d2,(a1)
[00010fb0] d3c5                      adda.l    d5,a1
[00010fb2] 3282                      move.w    d2,(a1)
[00010fb4] d3c5                      adda.l    d5,a1
[00010fb6] 3282                      move.w    d2,(a1)
[00010fb8] d3c5                      adda.l    d5,a1
[00010fba] 3282                      move.w    d2,(a1)
[00010fbc] d3c5                      adda.l    d5,a1
[00010fbe] 3282                      move.w    d2,(a1)
[00010fc0] d3c5                      adda.l    d5,a1
[00010fc2] 3282                      move.w    d2,(a1)
[00010fc4] d3c5                      adda.l    d5,a1
[00010fc6] 3282                      move.w    d2,(a1)
[00010fc8] d3c5                      adda.l    d5,a1
[00010fca] 51c9 ffbe                 dbf       d1,$00010F8A
[00010fce] 225f                      movea.l   (a7)+,a1
[00010fd0] d2d7                      adda.w    (a7),a1
[00010fd2] 5343                      subq.w    #1,d3
[00010fd4] 51c8 ff94                 dbf       d0,$00010F6A
[00010fd8] 548f                      addq.l    #2,a7
[00010fda] 4e75                      rts
[00010fdc] 3403                      move.w    d3,d2
[00010fde] 4642                      not.w     d2
[00010fe0] c47c 000f                 and.w     #$000F,d2
[00010fe4] d442                      add.w     d2,d2
[00010fe6] d442                      add.w     d2,d2
[00010fe8] e84b                      lsr.w     #4,d3
[00010fea] 4efb 2002                 jmp       $00010FEE(pc,d2.w)
[00010fee] 3284                      move.w    d4,(a1)
[00010ff0] d2c5                      adda.w    d5,a1
[00010ff2] 3284                      move.w    d4,(a1)
[00010ff4] d2c5                      adda.w    d5,a1
[00010ff6] 3284                      move.w    d4,(a1)
[00010ff8] d2c5                      adda.w    d5,a1
[00010ffa] 3284                      move.w    d4,(a1)
[00010ffc] d2c5                      adda.w    d5,a1
[00010ffe] 3284                      move.w    d4,(a1)
[00011000] d2c5                      adda.w    d5,a1
[00011002] 3284                      move.w    d4,(a1)
[00011004] d2c5                      adda.w    d5,a1
[00011006] 3284                      move.w    d4,(a1)
[00011008] d2c5                      adda.w    d5,a1
[0001100a] 3284                      move.w    d4,(a1)
[0001100c] d2c5                      adda.w    d5,a1
[0001100e] 3284                      move.w    d4,(a1)
[00011010] d2c5                      adda.w    d5,a1
[00011012] 3284                      move.w    d4,(a1)
[00011014] d2c5                      adda.w    d5,a1
[00011016] 3284                      move.w    d4,(a1)
[00011018] d2c5                      adda.w    d5,a1
[0001101a] 3284                      move.w    d4,(a1)
[0001101c] d2c5                      adda.w    d5,a1
[0001101e] 3284                      move.w    d4,(a1)
[00011020] d2c5                      adda.w    d5,a1
[00011022] 3284                      move.w    d4,(a1)
[00011024] d2c5                      adda.w    d5,a1
[00011026] 3284                      move.w    d4,(a1)
[00011028] d2c5                      adda.w    d5,a1
[0001102a] 3284                      move.w    d4,(a1)
[0001102c] d2c5                      adda.w    d5,a1
[0001102e] 51cb ffbe                 dbf       d3,$00010FEE
[00011032] 4e75                      rts
[00011034] 2278 044e                 movea.l   ($0000044E).w,a1
[00011038] 3a38 206e                 move.w    ($0000206E).w,d5
[0001103c] 4a6e 01b2                 tst.w     434(a6)
[00011040] 6708                      beq.s     $0001104A
[00011042] 226e 01ae                 movea.l   430(a6),a1
[00011046] 3a2e 01b2                 move.w    434(a6),d5
[0001104a] 3805                      move.w    d5,d4
[0001104c] c9c1                      muls.w    d1,d4
[0001104e] d3c4                      adda.l    d4,a1
[00011050] d2c0                      adda.w    d0,a1
[00011052] d2c0                      adda.w    d0,a1
[00011054] 780f                      moveq.l   #15,d4
[00011056] c840                      and.w     d0,d4
[00011058] e97e                      rol.w     d4,d6
[0001105a] 9440                      sub.w     d0,d2
[0001105c] 6b3a                      bmi.s     $00011098
[0001105e] 9641                      sub.w     d1,d3
[00011060] 6a04                      bpl.s     $00011066
[00011062] 4443                      neg.w     d3
[00011064] 4445                      neg.w     d5
[00011066] 2f08                      move.l    a0,-(a7)
[00011068] 41ee 0458                 lea.l     1112(a6),a0
[0001106c] 382e 0046                 move.w    70(a6),d4
[00011070] d844                      add.w     d4,d4
[00011072] 3830 4000                 move.w    0(a0,d4.w),d4
[00011076] 205f                      movea.l   (a7)+,a0
[00011078] b443                      cmp.w     d3,d2
[0001107a] 6d26                      blt.s     $000110A2
[0001107c] 3002                      move.w    d2,d0
[0001107e] d06e 004e                 add.w     78(a6),d0
[00011082] 6b14                      bmi.s     $00011098
[00011084] 3203                      move.w    d3,d1
[00011086] d241                      add.w     d1,d1
[00011088] 4442                      neg.w     d2
[0001108a] 3602                      move.w    d2,d3
[0001108c] d442                      add.w     d2,d2
[0001108e] de47                      add.w     d7,d7
[00011090] 3e3b 7008                 move.w    $0001109A(pc,d7.w),d7
[00011094] 4efb 7004                 jmp       $0001109A(pc,d7.w)
[00011098] 4e75                      rts
[0001109a] 002a 0070 0096            ori.b     #$70,150(a2)
[000110a0] 006e 3003 d06e            ori.w     #$3003,-12178(a6)
[000110a6] 004e 6bee                 ori.w     #$6BEE,a6 ; apollo only
[000110aa] 4443                      neg.w     d3
[000110ac] 3203                      move.w    d3,d1
[000110ae] d241                      add.w     d1,d1
[000110b0] d442                      add.w     d2,d2
[000110b2] de47                      add.w     d7,d7
[000110b4] 3e3b 7006                 move.w    $000110BC(pc,d7.w),d7
[000110b8] 4efb 7002                 jmp       $000110BC(pc,d7.w)
J2:
[000110bc] 009c                      dc.w $009c   ; $00011158-$000110bc
[000110be] 00e8                      dc.w $00e8   ; $000111a4-$000110bc
[000110c0] 0104                      dc.w $0104   ; $000111c0-$000110bc
[000110c2] 00e6                      dc.w $00e6   ; $000111a2-$000110bc
[000110c4] bc7c                      dc.w $bc7c   ; $0000cd38-$000110bc
[000110c6] ffff                      dc.w $ffff   ; $000110bb-$000110bc
[000110c8] 6728                      dc.w $6728   ; $000177e4-$000110bc
[000110ca] 7eff                      dc.w $7eff   ; $00018fbb-$000110bc
[000110cc] e35e                      dc.w $e35e   ; $0000f41a-$000110bc
[000110ce] 640c                      dc.w $640c   ; $000174c8-$000110bc
[000110d0] 32c4                      dc.w $32c4   ; $00014380-$000110bc
[000110d2] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[000110d4] 6a12                      dc.w $6a12   ; $00017ace-$000110bc
[000110d6] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[000110d8] fff4                      dc.w $fff4   ; $000110b0-$000110bc
[000110da] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[000110dc] 32c7                      dc.w $32c7   ; $00014383-$000110bc
[000110de] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[000110e0] 6a06                      dc.w $6a06   ; $00017ac2-$000110bc
[000110e2] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[000110e4] ffe8                      dc.w $ffe8   ; $000110a4-$000110bc
[000110e6] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[000110e8] d2c5                      dc.w $d2c5   ; $0000e381-$000110bc
[000110ea] d642                      dc.w $d642   ; $0000e6fe-$000110bc
[000110ec] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[000110ee] ffde                      dc.w $ffde   ; $0001109a-$000110bc
[000110f0] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[000110f2] 32c4                      dc.w $32c4   ; $00014380-$000110bc
[000110f4] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[000110f6] 6a06                      dc.w $6a06   ; $00017ac2-$000110bc
[000110f8] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[000110fa] fff8                      dc.w $fff8   ; $000110b4-$000110bc
[000110fc] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[000110fe] d2c5                      dc.w $d2c5   ; $0000e381-$000110bc
[00011100] d642                      dc.w $d642   ; $0000e6fe-$000110bc
[00011102] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[00011104] ffee                      dc.w $ffee   ; $000110aa-$000110bc
[00011106] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[00011108] 4646                      dc.w $4646   ; $00015702-$000110bc
[0001110a] e35e                      dc.w $e35e   ; $0000f41a-$000110bc
[0001110c] 640c                      dc.w $640c   ; $000174c8-$000110bc
[0001110e] 32c4                      dc.w $32c4   ; $00014380-$000110bc
[00011110] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[00011112] 6a12                      dc.w $6a12   ; $00017ace-$000110bc
[00011114] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[00011116] fff4                      dc.w $fff4   ; $000110b0-$000110bc
[00011118] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[0001111a] 5489                      dc.w $5489   ; $00016545-$000110bc
[0001111c] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[0001111e] 6a06                      dc.w $6a06   ; $00017ac2-$000110bc
[00011120] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[00011122] ffe8                      dc.w $ffe8   ; $000110a4-$000110bc
[00011124] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[00011126] d2c5                      dc.w $d2c5   ; $0000e381-$000110bc
[00011128] d642                      dc.w $d642   ; $0000e6fe-$000110bc
[0001112a] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[0001112c] ffde                      dc.w $ffde   ; $0001109a-$000110bc
[0001112e] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[00011130] 78ff                      dc.w $78ff   ; $000189bb-$000110bc
[00011132] e35e                      dc.w $e35e   ; $0000f41a-$000110bc
[00011134] 640c                      dc.w $640c   ; $000174c8-$000110bc
[00011136] b959                      dc.w $b959   ; $0000ca15-$000110bc
[00011138] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[0001113a] 6a12                      dc.w $6a12   ; $00017ace-$000110bc
[0001113c] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[0001113e] fff4                      dc.w $fff4   ; $000110b0-$000110bc
[00011140] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[00011142] 5489                      dc.w $5489   ; $00016545-$000110bc
[00011144] d641                      dc.w $d641   ; $0000e6fd-$000110bc
[00011146] 6a06                      dc.w $6a06   ; $00017ac2-$000110bc
[00011148] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[0001114a] ffe8                      dc.w $ffe8   ; $000110a4-$000110bc
[0001114c] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[0001114e] d2c5                      dc.w $d2c5   ; $0000e381-$000110bc
[00011150] d642                      dc.w $d642   ; $0000e6fe-$000110bc
[00011152] 51c8                      dc.w $51c8   ; $00016284-$000110bc
[00011154] ffde                      dc.w $ffde   ; $0001109a-$000110bc
[00011156] 4e75                      dc.w $4e75   ; $00015f31-$000110bc
[00011158] bc7c ffff                 cmp.w     #$FFFF,d6
[0001115c] 672c                      beq.s     $0001118A
[0001115e] 7eff                      moveq.l   #-1,d7
[00011160] e35e                      rol.w     #1,d6
[00011162] 640e                      bcc.s     $00011172
[00011164] 3284                      move.w    d4,(a1)
[00011166] d2c5                      adda.w    d5,a1
[00011168] d642                      add.w     d2,d3
[0001116a] 6a14                      bpl.s     $00011180
[0001116c] 51c8 fff2                 dbf       d0,$00011160
[00011170] 4e75                      rts
[00011172] 3287                      move.w    d7,(a1)
[00011174] d2c5                      adda.w    d5,a1
[00011176] d642                      add.w     d2,d3
[00011178] 6a06                      bpl.s     $00011180
[0001117a] 51c8 ffe4                 dbf       d0,$00011160
[0001117e] 4e75                      rts
[00011180] d641                      add.w     d1,d3
[00011182] 5489                      addq.l    #2,a1
[00011184] 51c8 ffda                 dbf       d0,$00011160
[00011188] 4e75                      rts
[0001118a] 3284                      move.w    d4,(a1)
[0001118c] d2c5                      adda.w    d5,a1
[0001118e] d642                      add.w     d2,d3
[00011190] 6a06                      bpl.s     $00011198
[00011192] 51c8 fff6                 dbf       d0,$0001118A
[00011196] 4e75                      rts
[00011198] d641                      add.w     d1,d3
[0001119a] 5489                      addq.l    #2,a1
[0001119c] 51c8 ffec                 dbf       d0,$0001118A
[000111a0] 4e75                      rts
[000111a2] 4646                      not.w     d6
[000111a4] e35e                      rol.w     #1,d6
[000111a6] 6402                      bcc.s     $000111AA
[000111a8] 3284                      move.w    d4,(a1)
[000111aa] d2c5                      adda.w    d5,a1
[000111ac] d642                      add.w     d2,d3
[000111ae] 6a06                      bpl.s     $000111B6
[000111b0] 51c8 fff2                 dbf       d0,$000111A4
[000111b4] 4e75                      rts
[000111b6] d641                      add.w     d1,d3
[000111b8] 5489                      addq.l    #2,a1
[000111ba] 51c8 ffe8                 dbf       d0,$000111A4
[000111be] 4e75                      rts
[000111c0] 78ff                      moveq.l   #-1,d4
[000111c2] e35e                      rol.w     #1,d6
[000111c4] 6402                      bcc.s     $000111C8
[000111c6] b951                      eor.w     d4,(a1)
[000111c8] d2c5                      adda.w    d5,a1
[000111ca] d642                      add.w     d2,d3
[000111cc] 6a06                      bpl.s     $000111D4
[000111ce] 51c8 fff2                 dbf       d0,$000111C2
[000111d2] 4e75                      rts
[000111d4] d641                      add.w     d1,d3
[000111d6] 5489                      addq.l    #2,a1
[000111d8] 51c8 ffe8                 dbf       d0,$000111C2
[000111dc] 4e75                      rts
[000111de] 41ee 0458                 lea.l     1112(a6),a0
[000111e2] 3a2e 00be                 move.w    190(a6),d5
[000111e6] da45                      add.w     d5,d5
[000111e8] 3a30 5000                 move.w    0(a0,d5.w),d5
[000111ec] 2278 044e                 movea.l   ($0000044E).w,a1
[000111f0] 3838 206e                 move.w    ($0000206E).w,d4
[000111f4] 4a6e 01b2                 tst.w     434(a6)
[000111f8] 6708                      beq.s     $00011202
[000111fa] 226e 01ae                 movea.l   430(a6),a1
[000111fe] 382e 01b2                 move.w    434(a6),d4
[00011202] 3e2e 003c                 move.w    60(a6),d7
[00011206] 286e 00c6                 movea.l   198(a6),a4
[0001120a] 206e 0020                 movea.l   32(a6),a0
[0001120e] 9641                      sub.w     d1,d3
[00011210] 3c04                      move.w    d4,d6
[00011212] 3f06                      move.w    d6,-(a7)
[00011214] c9c1                      muls.w    d1,d4
[00011216] d3c4                      adda.l    d4,a1
[00011218] d2c0                      adda.w    d0,a1
[0001121a] d2c0                      adda.w    d0,a1
[0001121c] 4a47                      tst.w     d7
[0001121e] 6600 02e6                 bne       $00011506
[00011222] 3e05                      move.w    d5,d7
[00011224] 4847                      swap      d7
[00011226] 3e05                      move.w    d5,d7
[00011228] 7af0                      moveq.l   #-16,d5
[0001122a] ca42                      and.w     d2,d5
[0001122c] 9a40                      sub.w     d0,d5
[0001122e] da45                      add.w     d5,d5
[00011230] 48c6                      ext.l     d6
[00011232] e98e                      lsl.l     #4,d6
[00011234] 48c5                      ext.l     d5
[00011236] 9c85                      sub.l     d5,d6
[00011238] 2646                      movea.l   d6,a3
[0001123a] 2a48                      movea.l   a0,a5
[0001123c] 7c0f                      moveq.l   #15,d6
[0001123e] 4a6e 00ca                 tst.w     202(a6)
[00011242] 6740                      beq.s     $00011284
[00011244] c246                      and.w     d6,d1
[00011246] 6724                      beq.s     $0001126C
[00011248] 2f0c                      move.l    a4,-(a7)
[0001124a] 3a01                      move.w    d1,d5
[0001124c] bd45                      eor.w     d6,d5
[0001124e] 3c01                      move.w    d1,d6
[00011250] 5346                      subq.w    #1,d6
[00011252] eb49                      lsl.w     #5,d1
[00011254] d8c1                      adda.w    d1,a4
[00011256] 2adc                      move.l    (a4)+,(a5)+
[00011258] 2adc                      move.l    (a4)+,(a5)+
[0001125a] 2adc                      move.l    (a4)+,(a5)+
[0001125c] 2adc                      move.l    (a4)+,(a5)+
[0001125e] 2adc                      move.l    (a4)+,(a5)+
[00011260] 2adc                      move.l    (a4)+,(a5)+
[00011262] 2adc                      move.l    (a4)+,(a5)+
[00011264] 2adc                      move.l    (a4)+,(a5)+
[00011266] 51cd ffee                 dbf       d5,$00011256
[0001126a] 285f                      movea.l   (a7)+,a4
[0001126c] 2adc                      move.l    (a4)+,(a5)+
[0001126e] 2adc                      move.l    (a4)+,(a5)+
[00011270] 2adc                      move.l    (a4)+,(a5)+
[00011272] 2adc                      move.l    (a4)+,(a5)+
[00011274] 2adc                      move.l    (a4)+,(a5)+
[00011276] 2adc                      move.l    (a4)+,(a5)+
[00011278] 2adc                      move.l    (a4)+,(a5)+
[0001127a] 2adc                      move.l    (a4)+,(a5)+
[0001127c] 51ce ffee                 dbf       d6,$0001126C
[00011280] 6000 00aa                 bra       $0001132C
[00011284] 4dfa 1170                 lea.l     $000123F6(pc),a6
[00011288] c246                      and.w     d6,d1
[0001128a] 6758                      beq.s     $000112E4
[0001128c] 2f0c                      move.l    a4,-(a7)
[0001128e] 3a01                      move.w    d1,d5
[00011290] bd45                      eor.w     d6,d5
[00011292] 3c01                      move.w    d1,d6
[00011294] 5346                      subq.w    #1,d6
[00011296] d241                      add.w     d1,d1
[00011298] d8c1                      adda.w    d1,a4
[0001129a] 7200                      moveq.l   #0,d1
[0001129c] 121c                      move.b    (a4)+,d1
[0001129e] e949                      lsl.w     #4,d1
[000112a0] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000112a4] 221a                      move.l    (a2)+,d1
[000112a6] 8287                      or.l      d7,d1
[000112a8] 2ac1                      move.l    d1,(a5)+
[000112aa] 221a                      move.l    (a2)+,d1
[000112ac] 8287                      or.l      d7,d1
[000112ae] 2ac1                      move.l    d1,(a5)+
[000112b0] 221a                      move.l    (a2)+,d1
[000112b2] 8287                      or.l      d7,d1
[000112b4] 2ac1                      move.l    d1,(a5)+
[000112b6] 221a                      move.l    (a2)+,d1
[000112b8] 8287                      or.l      d7,d1
[000112ba] 2ac1                      move.l    d1,(a5)+
[000112bc] 7200                      moveq.l   #0,d1
[000112be] 121c                      move.b    (a4)+,d1
[000112c0] e949                      lsl.w     #4,d1
[000112c2] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000112c6] 221a                      move.l    (a2)+,d1
[000112c8] 8287                      or.l      d7,d1
[000112ca] 2ac1                      move.l    d1,(a5)+
[000112cc] 221a                      move.l    (a2)+,d1
[000112ce] 8287                      or.l      d7,d1
[000112d0] 2ac1                      move.l    d1,(a5)+
[000112d2] 221a                      move.l    (a2)+,d1
[000112d4] 8287                      or.l      d7,d1
[000112d6] 2ac1                      move.l    d1,(a5)+
[000112d8] 221a                      move.l    (a2)+,d1
[000112da] 8287                      or.l      d7,d1
[000112dc] 2ac1                      move.l    d1,(a5)+
[000112de] 51cd ffba                 dbf       d5,$0001129A
[000112e2] 285f                      movea.l   (a7)+,a4
[000112e4] 7200                      moveq.l   #0,d1
[000112e6] 121c                      move.b    (a4)+,d1
[000112e8] e949                      lsl.w     #4,d1
[000112ea] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000112ee] 221a                      move.l    (a2)+,d1
[000112f0] 8287                      or.l      d7,d1
[000112f2] 2ac1                      move.l    d1,(a5)+
[000112f4] 221a                      move.l    (a2)+,d1
[000112f6] 8287                      or.l      d7,d1
[000112f8] 2ac1                      move.l    d1,(a5)+
[000112fa] 221a                      move.l    (a2)+,d1
[000112fc] 8287                      or.l      d7,d1
[000112fe] 2ac1                      move.l    d1,(a5)+
[00011300] 221a                      move.l    (a2)+,d1
[00011302] 8287                      or.l      d7,d1
[00011304] 2ac1                      move.l    d1,(a5)+
[00011306] 7200                      moveq.l   #0,d1
[00011308] 121c                      move.b    (a4)+,d1
[0001130a] e949                      lsl.w     #4,d1
[0001130c] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011310] 221a                      move.l    (a2)+,d1
[00011312] 8287                      or.l      d7,d1
[00011314] 2ac1                      move.l    d1,(a5)+
[00011316] 221a                      move.l    (a2)+,d1
[00011318] 8287                      or.l      d7,d1
[0001131a] 2ac1                      move.l    d1,(a5)+
[0001131c] 221a                      move.l    (a2)+,d1
[0001131e] 8287                      or.l      d7,d1
[00011320] 2ac1                      move.l    d1,(a5)+
[00011322] 221a                      move.l    (a2)+,d1
[00011324] 8287                      or.l      d7,d1
[00011326] 2ac1                      move.l    d1,(a5)+
[00011328] 51ce ffba                 dbf       d6,$000112E4
[0001132c] 3c02                      move.w    d2,d6
[0001132e] e84a                      lsr.w     #4,d2
[00011330] 3800                      move.w    d0,d4
[00011332] e84c                      lsr.w     #4,d4
[00011334] 9444                      sub.w     d4,d2
[00011336] 5342                      subq.w    #1,d2
[00011338] 6b00 017a                 bmi       $000114B4
[0001133c] cc7c 000f                 and.w     #$000F,d6
[00011340] dc46                      add.w     d6,d6
[00011342] 3846                      movea.w   d6,a4
[00011344] 544c                      addq.w    #2,a4
[00011346] c07c 000f                 and.w     #$000F,d0
[0001134a] d040                      add.w     d0,d0
[0001134c] d040                      add.w     d0,d0
[0001134e] dc46                      add.w     d6,d6
[00011350] 247b 000a                 movea.l   $0001135C(pc,d0.w),a2
[00011354] 2c7b 6046                 movea.l   $0001139C(pc,d6.w),a6
[00011358] 6000 0082                 bra       $000113DC
[0001135c] 0001 142a                 ori.b     #$2A,d1
[00011360] 0001 140a                 ori.b     #$0A,d1
[00011364] 0001 142c                 ori.b     #$2C,d1
[00011368] 0001 140e                 ori.b     #$0E,d1
[0001136c] 0001 142e                 ori.b     #$2E,d1
[00011370] 0001 1412                 ori.b     #$12,d1
[00011374] 0001 1430                 ori.b     #$30,d1
[00011378] 0001 1416                 ori.b     #$16,d1
[0001137c] 0001 1432                 ori.b     #$32,d1
[00011380] 0001 141a                 ori.b     #$1A,d1
[00011384] 0001 1434                 ori.b     #$34,d1
[00011388] 0001 141e                 ori.b     #$1E,d1
[0001138c] 0001 1436                 ori.b     #$36,d1
[00011390] 0001 1422                 ori.b     #$22,d1
[00011394] 0001 1438                 ori.b     #$38,d1
[00011398] 0001 1426                 ori.b     #$26,d1
[0001139c] 0001 147a                 ori.b     #$7A,d1
[000113a0] 0001 1490                 ori.b     #$90,d1
[000113a4] 0001 1472                 ori.b     #$72,d1
[000113a8] 0001 148e                 ori.b     #$8E,d1
[000113ac] 0001 146a                 ori.b     #$6A,d1
[000113b0] 0001 148c                 ori.b     #$8C,d1
[000113b4] 0001 1462                 ori.b     #$62,d1
[000113b8] 0001 148a                 ori.b     #$8A,d1
[000113bc] 0001 145a                 ori.b     #$5A,d1
[000113c0] 0001 1488                 ori.b     #$88,d1
[000113c4] 0001 1452                 ori.b     #$52,d1
[000113c8] 0001 1486                 ori.b     #$86,d1
[000113cc] 0001 144a                 ori.b     #$4A,d1
[000113d0] 0001 1484                 ori.b     #$84,d1
[000113d4] 0001 1442                 ori.b     #$42,d1
[000113d8] 0001 1482                 ori.b     #$82,d1
[000113dc] 700f                      moveq.l   #15,d0
[000113de] b640                      cmp.w     d0,d3
[000113e0] 6c02                      bge.s     $000113E4
[000113e2] 3003                      move.w    d3,d0
[000113e4] 4843                      swap      d3
[000113e6] 3600                      move.w    d0,d3
[000113e8] 4843                      swap      d3
[000113ea] 2f03                      move.l    d3,-(a7)
[000113ec] e84b                      lsr.w     #4,d3
[000113ee] 2f08                      move.l    a0,-(a7)
[000113f0] 3f0c                      move.w    a4,-(a7)
[000113f2] 2018                      move.l    (a0)+,d0
[000113f4] 2218                      move.l    (a0)+,d1
[000113f6] 2818                      move.l    (a0)+,d4
[000113f8] 2a18                      move.l    (a0)+,d5
[000113fa] 2c18                      move.l    (a0)+,d6
[000113fc] 2e18                      move.l    (a0)+,d7
[000113fe] 2858                      movea.l   (a0)+,a4
[00011400] 2a58                      movea.l   (a0)+,a5
[00011402] 305f                      movea.w   (a7)+,a0
[00011404] 2f09                      move.l    a1,-(a7)
[00011406] 3f02                      move.w    d2,-(a7)
[00011408] 4ed2                      jmp       (a2)
[0001140a] 32c0                      move.w    d0,(a1)+
[0001140c] 601e                      bra.s     $0001142C
[0001140e] 32c1                      move.w    d1,(a1)+
[00011410] 601c                      bra.s     $0001142E
[00011412] 32c4                      move.w    d4,(a1)+
[00011414] 601a                      bra.s     $00011430
[00011416] 32c5                      move.w    d5,(a1)+
[00011418] 6018                      bra.s     $00011432
[0001141a] 32c6                      move.w    d6,(a1)+
[0001141c] 6016                      bra.s     $00011434
[0001141e] 32c7                      move.w    d7,(a1)+
[00011420] 6014                      bra.s     $00011436
[00011422] 32cc                      move.w    a4,(a1)+
[00011424] 6012                      bra.s     $00011438
[00011426] 32cd                      move.w    a5,(a1)+
[00011428] 6010                      bra.s     $0001143A
[0001142a] 22c0                      move.l    d0,(a1)+
[0001142c] 22c1                      move.l    d1,(a1)+
[0001142e] 22c4                      move.l    d4,(a1)+
[00011430] 22c5                      move.l    d5,(a1)+
[00011432] 22c6                      move.l    d6,(a1)+
[00011434] 22c7                      move.l    d7,(a1)+
[00011436] 22cc                      move.l    a4,(a1)+
[00011438] 22cd                      move.l    a5,(a1)+
[0001143a] 51ca ffee                 dbf       d2,$0001142A
[0001143e] d2c8                      adda.w    a0,a1
[00011440] 4ed6                      jmp       (a6)
[00011442] 240d                      move.l    a5,d2
[00011444] 4842                      swap      d2
[00011446] 3302                      move.w    d2,-(a1)
[00011448] 603a                      bra.s     $00011484
[0001144a] 240c                      move.l    a4,d2
[0001144c] 4842                      swap      d2
[0001144e] 3302                      move.w    d2,-(a1)
[00011450] 6034                      bra.s     $00011486
[00011452] 2407                      move.l    d7,d2
[00011454] 4842                      swap      d2
[00011456] 3302                      move.w    d2,-(a1)
[00011458] 602e                      bra.s     $00011488
[0001145a] 2406                      move.l    d6,d2
[0001145c] 4842                      swap      d2
[0001145e] 3302                      move.w    d2,-(a1)
[00011460] 6028                      bra.s     $0001148A
[00011462] 2405                      move.l    d5,d2
[00011464] 4842                      swap      d2
[00011466] 3302                      move.w    d2,-(a1)
[00011468] 6022                      bra.s     $0001148C
[0001146a] 2404                      move.l    d4,d2
[0001146c] 4842                      swap      d2
[0001146e] 3302                      move.w    d2,-(a1)
[00011470] 601c                      bra.s     $0001148E
[00011472] 2401                      move.l    d1,d2
[00011474] 4842                      swap      d2
[00011476] 3302                      move.w    d2,-(a1)
[00011478] 6016                      bra.s     $00011490
[0001147a] 2400                      move.l    d0,d2
[0001147c] 4842                      swap      d2
[0001147e] 3302                      move.w    d2,-(a1)
[00011480] 6010                      bra.s     $00011492
[00011482] 230d                      move.l    a5,-(a1)
[00011484] 230c                      move.l    a4,-(a1)
[00011486] 2307                      move.l    d7,-(a1)
[00011488] 2306                      move.l    d6,-(a1)
[0001148a] 2305                      move.l    d5,-(a1)
[0001148c] 2304                      move.l    d4,-(a1)
[0001148e] 2301                      move.l    d1,-(a1)
[00011490] 2300                      move.l    d0,-(a1)
[00011492] 341f                      move.w    (a7)+,d2
[00011494] d3cb                      adda.l    a3,a1
[00011496] 51cb ff6e                 dbf       d3,$00011406
[0001149a] 225f                      movea.l   (a7)+,a1
[0001149c] 3848                      movea.w   a0,a4
[0001149e] 205f                      movea.l   (a7)+,a0
[000114a0] 41e8 0020                 lea.l     32(a0),a0
[000114a4] 261f                      move.l    (a7)+,d3
[000114a6] 5343                      subq.w    #1,d3
[000114a8] 4843                      swap      d3
[000114aa] d2d7                      adda.w    (a7),a1
[000114ac] 51cb ff3a                 dbf       d3,$000113E8
[000114b0] 548f                      addq.l    #2,a7
[000114b2] 4e75                      rts
[000114b4] 365f                      movea.w   (a7)+,a3
[000114b6] 720f                      moveq.l   #15,d1
[000114b8] 9c40                      sub.w     d0,d6
[000114ba] 96c6                      suba.w    d6,a3
[000114bc] 96c6                      suba.w    d6,a3
[000114be] b346                      eor.w     d1,d6
[000114c0] dc46                      add.w     d6,d6
[000114c2] 45fb 601a                 lea.l     $000114DE(pc,d6.w),a2
[000114c6] c041                      and.w     d1,d0
[000114c8] d040                      add.w     d0,d0
[000114ca] d0c0                      adda.w    d0,a0
[000114cc] 2848                      movea.l   a0,a4
[000114ce] 41e8 0020                 lea.l     32(a0),a0
[000114d2] 51c9 0008                 dbf       d1,$000114DC
[000114d6] 720f                      moveq.l   #15,d1
[000114d8] 41e8 fe00                 lea.l     -512(a0),a0
[000114dc] 4ed2                      jmp       (a2)
[000114de] 32dc                      move.w    (a4)+,(a1)+
[000114e0] 32dc                      move.w    (a4)+,(a1)+
[000114e2] 32dc                      move.w    (a4)+,(a1)+
[000114e4] 32dc                      move.w    (a4)+,(a1)+
[000114e6] 32dc                      move.w    (a4)+,(a1)+
[000114e8] 32dc                      move.w    (a4)+,(a1)+
[000114ea] 32dc                      move.w    (a4)+,(a1)+
[000114ec] 32dc                      move.w    (a4)+,(a1)+
[000114ee] 32dc                      move.w    (a4)+,(a1)+
[000114f0] 32dc                      move.w    (a4)+,(a1)+
[000114f2] 32dc                      move.w    (a4)+,(a1)+
[000114f4] 32dc                      move.w    (a4)+,(a1)+
[000114f6] 32dc                      move.w    (a4)+,(a1)+
[000114f8] 32dc                      move.w    (a4)+,(a1)+
[000114fa] 32dc                      move.w    (a4)+,(a1)+
[000114fc] 329c                      move.w    (a4)+,(a1)
[000114fe] d2cb                      adda.w    a3,a1
[00011500] 51cb ffca                 dbf       d3,$000114CC
[00011504] 4e75                      rts
[00011506] 5547                      subq.w    #2,d7
[00011508] 6d00 034a                 blt       $00011854
[0001150c] 6600 030a                 bne       $00011818
[00011510] 3e2e 00c0                 move.w    192(a6),d7
[00011514] 6700 022c                 beq       $00011742
[00011518] 5347                      subq.w    #1,d7
[0001151a] 6700 029e                 beq       $000117BA
[0001151e] 5347                      subq.w    #1,d7
[00011520] 660a                      bne.s     $0001152C
[00011522] 0c6e 0008 00c2            cmpi.w    #$0008,194(a6)
[00011528] 6700 0290                 beq       $000117BA
[0001152c] 7af0                      moveq.l   #-16,d5
[0001152e] ca42                      and.w     d2,d5
[00011530] 9a40                      sub.w     d0,d5
[00011532] da45                      add.w     d5,d5
[00011534] 48c6                      ext.l     d6
[00011536] e94e                      lsl.w     #4,d6
[00011538] 48c5                      ext.l     d5
[0001153a] 9c85                      sub.l     d5,d6
[0001153c] 2646                      movea.l   d6,a3
[0001153e] 4dfa 0eb6                 lea.l     $000123F6(pc),a6
[00011542] 2a48                      movea.l   a0,a5
[00011544] 7c0f                      moveq.l   #15,d6
[00011546] c246                      and.w     d6,d1
[00011548] 673c                      beq.s     $00011586
[0001154a] 2f0c                      move.l    a4,-(a7)
[0001154c] 3a01                      move.w    d1,d5
[0001154e] bd45                      eor.w     d6,d5
[00011550] 3c01                      move.w    d1,d6
[00011552] 5346                      subq.w    #1,d6
[00011554] d241                      add.w     d1,d1
[00011556] d8c1                      adda.w    d1,a4
[00011558] 7200                      moveq.l   #0,d1
[0001155a] 121c                      move.b    (a4)+,d1
[0001155c] 4601                      not.b     d1
[0001155e] e949                      lsl.w     #4,d1
[00011560] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011564] 2ada                      move.l    (a2)+,(a5)+
[00011566] 2ada                      move.l    (a2)+,(a5)+
[00011568] 2ada                      move.l    (a2)+,(a5)+
[0001156a] 2ada                      move.l    (a2)+,(a5)+
[0001156c] 7200                      moveq.l   #0,d1
[0001156e] 121c                      move.b    (a4)+,d1
[00011570] 4601                      not.b     d1
[00011572] e949                      lsl.w     #4,d1
[00011574] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011578] 2ada                      move.l    (a2)+,(a5)+
[0001157a] 2ada                      move.l    (a2)+,(a5)+
[0001157c] 2ada                      move.l    (a2)+,(a5)+
[0001157e] 2ada                      move.l    (a2)+,(a5)+
[00011580] 51cd ffd6                 dbf       d5,$00011558
[00011584] 285f                      movea.l   (a7)+,a4
[00011586] 7200                      moveq.l   #0,d1
[00011588] 121c                      move.b    (a4)+,d1
[0001158a] 4601                      not.b     d1
[0001158c] e949                      lsl.w     #4,d1
[0001158e] 45f6 1000                 lea.l     0(a6,d1.w),a2
[00011592] 2ada                      move.l    (a2)+,(a5)+
[00011594] 2ada                      move.l    (a2)+,(a5)+
[00011596] 2ada                      move.l    (a2)+,(a5)+
[00011598] 2ada                      move.l    (a2)+,(a5)+
[0001159a] 7200                      moveq.l   #0,d1
[0001159c] 121c                      move.b    (a4)+,d1
[0001159e] 4601                      not.b     d1
[000115a0] e949                      lsl.w     #4,d1
[000115a2] 45f6 1000                 lea.l     0(a6,d1.w),a2
[000115a6] 2ada                      move.l    (a2)+,(a5)+
[000115a8] 2ada                      move.l    (a2)+,(a5)+
[000115aa] 2ada                      move.l    (a2)+,(a5)+
[000115ac] 2ada                      move.l    (a2)+,(a5)+
[000115ae] 51ce ffd6                 dbf       d6,$00011586
[000115b2] 3c02                      move.w    d2,d6
[000115b4] e84a                      lsr.w     #4,d2
[000115b6] 3800                      move.w    d0,d4
[000115b8] e84c                      lsr.w     #4,d4
[000115ba] 9444                      sub.w     d4,d2
[000115bc] 5342                      subq.w    #1,d2
[000115be] 6b00 0186                 bmi       $00011746
[000115c2] cc7c 000f                 and.w     #$000F,d6
[000115c6] dc46                      add.w     d6,d6
[000115c8] 3846                      movea.w   d6,a4
[000115ca] 544c                      addq.w    #2,a4
[000115cc] c07c 000f                 and.w     #$000F,d0
[000115d0] d040                      add.w     d0,d0
[000115d2] d040                      add.w     d0,d0
[000115d4] dc46                      add.w     d6,d6
[000115d6] 247b 000a                 movea.l   $000115E2(pc,d0.w),a2
[000115da] 2c7b 6046                 movea.l   $00011622(pc,d6.w),a6
[000115de] 6000 0082                 bra       $00011662
[000115e2] 0001 16b6                 ori.b     #$B6,d1
[000115e6] 0001 1694                 ori.b     #$94,d1
[000115ea] 0001 16b8                 ori.b     #$B8,d1
[000115ee] 0001 1698                 ori.b     #$98,d1
[000115f2] 0001 16ba                 ori.b     #$BA,d1
[000115f6] 0001 169c                 ori.b     #$9C,d1
[000115fa] 0001 16bc                 ori.b     #$BC,d1
[000115fe] 0001 16a0                 ori.b     #$A0,d1
[00011602] 0001 16be                 ori.b     #$BE,d1
[00011606] 0001 16a4                 ori.b     #$A4,d1
[0001160a] 0001 16c0                 ori.b     #$C0,d1
[0001160e] 0001 16a8                 ori.b     #$A8,d1
[00011612] 0001 16c2                 ori.b     #$C2,d1
[00011616] 0001 16ac                 ori.b     #$AC,d1
[0001161a] 0001 16c4                 ori.b     #$C4,d1
[0001161e] 0001 16b0                 ori.b     #$B0,d1
[00011622] 0001 1708                 ori.b     #$08,d1
[00011626] 0001 1720                 ori.b     #$20,d1
[0001162a] 0001 1700                 ori.b     #$00,d1
[0001162e] 0001 171e                 ori.b     #$1E,d1
[00011632] 0001 16f8                 ori.b     #$F8,d1
[00011636] 0001 171c                 ori.b     #$1C,d1
[0001163a] 0001 16f0                 ori.b     #$F0,d1
[0001163e] 0001 171a                 ori.b     #$1A,d1
[00011642] 0001 16e8                 ori.b     #$E8,d1
[00011646] 0001 1718                 ori.b     #$18,d1
[0001164a] 0001 16e0                 ori.b     #$E0,d1
[0001164e] 0001 1716                 ori.b     #$16,d1
[00011652] 0001 16d8                 ori.b     #$D8,d1
[00011656] 0001 1714                 ori.b     #$14,d1
[0001165a] 0001 16d0                 ori.b     #$D0,d1
[0001165e] 0001 1710                 ori.b     #$10,d1
[00011662] 700f                      moveq.l   #15,d0
[00011664] b640                      cmp.w     d0,d3
[00011666] 6c02                      bge.s     $0001166A
[00011668] 3003                      move.w    d3,d0
[0001166a] 4843                      swap      d3
[0001166c] 3600                      move.w    d0,d3
[0001166e] 4843                      swap      d3
[00011670] 2f03                      move.l    d3,-(a7)
[00011672] e84b                      lsr.w     #4,d3
[00011674] 2f08                      move.l    a0,-(a7)
[00011676] 3f0c                      move.w    a4,-(a7)
[00011678] 2018                      move.l    (a0)+,d0
[0001167a] 2218                      move.l    (a0)+,d1
[0001167c] 2818                      move.l    (a0)+,d4
[0001167e] 2a18                      move.l    (a0)+,d5
[00011680] 2c18                      move.l    (a0)+,d6
[00011682] 2e18                      move.l    (a0)+,d7
[00011684] 2858                      movea.l   (a0)+,a4
[00011686] 2a58                      movea.l   (a0)+,a5
[00011688] 305f                      movea.w   (a7)+,a0
[0001168a] 2f09                      move.l    a1,-(a7)
[0001168c] 3f02                      move.w    d2,-(a7)
[0001168e] c78c                      exg       d3,a4
[00011690] c58d                      exg       d2,a5
[00011692] 4ed2                      jmp       (a2)
[00011694] b159                      eor.w     d0,(a1)+
[00011696] 6020                      bra.s     $000116B8
[00011698] b359                      eor.w     d1,(a1)+
[0001169a] 601e                      bra.s     $000116BA
[0001169c] b959                      eor.w     d4,(a1)+
[0001169e] 601c                      bra.s     $000116BC
[000116a0] bb59                      eor.w     d5,(a1)+
[000116a2] 601a                      bra.s     $000116BE
[000116a4] bd59                      eor.w     d6,(a1)+
[000116a6] 6018                      bra.s     $000116C0
[000116a8] bf59                      eor.w     d7,(a1)+
[000116aa] 6016                      bra.s     $000116C2
[000116ac] b759                      eor.w     d3,(a1)+
[000116ae] 6014                      bra.s     $000116C4
[000116b0] 32c2                      move.w    d2,(a1)+
[000116b2] 6012                      bra.s     $000116C6
[000116b4] c58d                      exg       d2,a5
[000116b6] b199                      eor.l     d0,(a1)+
[000116b8] b399                      eor.l     d1,(a1)+
[000116ba] b999                      eor.l     d4,(a1)+
[000116bc] bb99                      eor.l     d5,(a1)+
[000116be] bd99                      eor.l     d6,(a1)+
[000116c0] bf99                      eor.l     d7,(a1)+
[000116c2] b799                      eor.l     d3,(a1)+
[000116c4] b599                      eor.l     d2,(a1)+
[000116c6] c58d                      exg       d2,a5
[000116c8] 51ca ffea                 dbf       d2,$000116B4
[000116cc] d2c8                      adda.w    a0,a1
[000116ce] 4ed6                      jmp       (a6)
[000116d0] 240d                      move.l    a5,d2
[000116d2] 4842                      swap      d2
[000116d4] b561                      eor.w     d2,-(a1)
[000116d6] 603c                      bra.s     $00011714
[000116d8] 2403                      move.l    d3,d2
[000116da] 4842                      swap      d2
[000116dc] b561                      eor.w     d2,-(a1)
[000116de] 6036                      bra.s     $00011716
[000116e0] 2407                      move.l    d7,d2
[000116e2] 4842                      swap      d2
[000116e4] b561                      eor.w     d2,-(a1)
[000116e6] 6030                      bra.s     $00011718
[000116e8] 2406                      move.l    d6,d2
[000116ea] 4842                      swap      d2
[000116ec] b561                      eor.w     d2,-(a1)
[000116ee] 602a                      bra.s     $0001171A
[000116f0] 2405                      move.l    d5,d2
[000116f2] 4842                      swap      d2
[000116f4] b561                      eor.w     d2,-(a1)
[000116f6] 6024                      bra.s     $0001171C
[000116f8] 2404                      move.l    d4,d2
[000116fa] 4842                      swap      d2
[000116fc] b561                      eor.w     d2,-(a1)
[000116fe] 601e                      bra.s     $0001171E
[00011700] 2401                      move.l    d1,d2
[00011702] 4842                      swap      d2
[00011704] b561                      eor.w     d2,-(a1)
[00011706] 6018                      bra.s     $00011720
[00011708] 2400                      move.l    d0,d2
[0001170a] 4842                      swap      d2
[0001170c] b561                      eor.w     d2,-(a1)
[0001170e] 6012                      bra.s     $00011722
[00011710] 240d                      move.l    a5,d2
[00011712] b5a1                      eor.l     d2,-(a1)
[00011714] b7a1                      eor.l     d3,-(a1)
[00011716] bfa1                      eor.l     d7,-(a1)
[00011718] bda1                      eor.l     d6,-(a1)
[0001171a] bba1                      eor.l     d5,-(a1)
[0001171c] b9a1                      eor.l     d4,-(a1)
[0001171e] b3a1                      eor.l     d1,-(a1)
[00011720] b1a1                      eor.l     d0,-(a1)
[00011722] c78c                      exg       d3,a4
[00011724] 341f                      move.w    (a7)+,d2
[00011726] d3cb                      adda.l    a3,a1
[00011728] 51cb ff62                 dbf       d3,$0001168C
[0001172c] 225f                      movea.l   (a7)+,a1
[0001172e] 3848                      movea.w   a0,a4
[00011730] 205f                      movea.l   (a7)+,a0
[00011732] 41e8 0020                 lea.l     32(a0),a0
[00011736] 261f                      move.l    (a7)+,d3
[00011738] 5343                      subq.w    #1,d3
[0001173a] 4843                      swap      d3
[0001173c] d2d7                      adda.w    (a7),a1
[0001173e] 51cb ff2e                 dbf       d3,$0001166E
[00011742] 548f                      addq.l    #2,a7
[00011744] 4e75                      rts
[00011746] 365f                      movea.w   (a7)+,a3
[00011748] 720f                      moveq.l   #15,d1
[0001174a] 9c40                      sub.w     d0,d6
[0001174c] 96c6                      suba.w    d6,a3
[0001174e] 96c6                      suba.w    d6,a3
[00011750] b346                      eor.w     d1,d6
[00011752] dc46                      add.w     d6,d6
[00011754] dc46                      add.w     d6,d6
[00011756] 45fb 601a                 lea.l     $00011772(pc,d6.w),a2
[0001175a] c041                      and.w     d1,d0
[0001175c] d040                      add.w     d0,d0
[0001175e] d0c0                      adda.w    d0,a0
[00011760] 2848                      movea.l   a0,a4
[00011762] 41e8 0020                 lea.l     32(a0),a0
[00011766] 51c9 0008                 dbf       d1,$00011770
[0001176a] 720f                      moveq.l   #15,d1
[0001176c] 41e8 fe00                 lea.l     -512(a0),a0
[00011770] 4ed2                      jmp       (a2)
[00011772] 301c                      move.w    (a4)+,d0
[00011774] b159                      eor.w     d0,(a1)+
[00011776] 301c                      move.w    (a4)+,d0
[00011778] b159                      eor.w     d0,(a1)+
[0001177a] 301c                      move.w    (a4)+,d0
[0001177c] b159                      eor.w     d0,(a1)+
[0001177e] 301c                      move.w    (a4)+,d0
[00011780] b159                      eor.w     d0,(a1)+
[00011782] 301c                      move.w    (a4)+,d0
[00011784] b159                      eor.w     d0,(a1)+
[00011786] 301c                      move.w    (a4)+,d0
[00011788] b159                      eor.w     d0,(a1)+
[0001178a] 301c                      move.w    (a4)+,d0
[0001178c] b159                      eor.w     d0,(a1)+
[0001178e] 301c                      move.w    (a4)+,d0
[00011790] b159                      eor.w     d0,(a1)+
[00011792] 301c                      move.w    (a4)+,d0
[00011794] b159                      eor.w     d0,(a1)+
[00011796] 301c                      move.w    (a4)+,d0
[00011798] b159                      eor.w     d0,(a1)+
[0001179a] 301c                      move.w    (a4)+,d0
[0001179c] b159                      eor.w     d0,(a1)+
[0001179e] 301c                      move.w    (a4)+,d0
[000117a0] b159                      eor.w     d0,(a1)+
[000117a2] 301c                      move.w    (a4)+,d0
[000117a4] b159                      eor.w     d0,(a1)+
[000117a6] 301c                      move.w    (a4)+,d0
[000117a8] b159                      eor.w     d0,(a1)+
[000117aa] 301c                      move.w    (a4)+,d0
[000117ac] b159                      eor.w     d0,(a1)+
[000117ae] 301c                      move.w    (a4)+,d0
[000117b0] b151                      eor.w     d0,(a1)
[000117b2] d2cb                      adda.w    a3,a1
[000117b4] 51cb ffaa                 dbf       d3,$00011760
[000117b8] 4e75                      rts
[000117ba] 9440                      sub.w     d0,d2
[000117bc] 9c42                      sub.w     d2,d6
[000117be] 9c42                      sub.w     d2,d6
[000117c0] 5546                      subq.w    #2,d6
[000117c2] 0802 0000                 btst      #0,d2
[000117c6] 661c                      bne.s     $000117E4
[000117c8] 41fa 002c                 lea.l     $000117F6(pc),a0
[000117cc] 45fa 0040                 lea.l     $0001180E(pc),a2
[000117d0] 5342                      subq.w    #1,d2
[000117d2] 6b1e                      bmi.s     $000117F2
[000117d4] 700e                      moveq.l   #14,d0
[000117d6] c042                      and.w     d2,d0
[000117d8] e84a                      lsr.w     #4,d2
[000117da] 0a40 000e                 eori.w    #$000E,d0
[000117de] 45fb 001a                 lea.l     $000117FA(pc,d0.w),a2
[000117e2] 600e                      bra.s     $000117F2
[000117e4] 700e                      moveq.l   #14,d0
[000117e6] c042                      and.w     d2,d0
[000117e8] e84a                      lsr.w     #4,d2
[000117ea] 0a40 000e                 eori.w    #$000E,d0
[000117ee] 41fb 000a                 lea.l     $000117FA(pc,d0.w),a0
[000117f2] 3002                      move.w    d2,d0
[000117f4] 4ed0                      jmp       (a0)
[000117f6] 4659                      not.w     (a1)+
[000117f8] 4ed2                      jmp       (a2)
[000117fa] 4699                      not.l     (a1)+
[000117fc] 4699                      not.l     (a1)+
[000117fe] 4699                      not.l     (a1)+
[00011800] 4699                      not.l     (a1)+
[00011802] 4699                      not.l     (a1)+
[00011804] 4699                      not.l     (a1)+
[00011806] 4699                      not.l     (a1)+
[00011808] 4699                      not.l     (a1)+
[0001180a] 51c8 ffee                 dbf       d0,$000117FA
[0001180e] d2c6                      adda.w    d6,a1
[00011810] 51cb ffe0                 dbf       d3,$000117F2
[00011814] 548f                      addq.l    #2,a7
[00011816] 4e75                      rts
[00011818] 9440                      sub.w     d0,d2
[0001181a] 48c6                      ext.l     d6
[0001181c] e98e                      lsl.l     #4,d6
[0001181e] 2646                      movea.l   d6,a3
[00011820] 2a48                      movea.l   a0,a5
[00011822] 780f                      moveq.l   #15,d4
[00011824] 7c0f                      moveq.l   #15,d6
[00011826] c044                      and.w     d4,d0
[00011828] c244                      and.w     d4,d1
[0001182a] 671a                      beq.s     $00011846
[0001182c] 3e01                      move.w    d1,d7
[0001182e] bd47                      eor.w     d6,d7
[00011830] 3c01                      move.w    d1,d6
[00011832] 5346                      subq.w    #1,d6
[00011834] d241                      add.w     d1,d1
[00011836] 45f4 1000                 lea.l     0(a4,d1.w),a2
[0001183a] 321a                      move.w    (a2)+,d1
[0001183c] 4641                      not.w     d1
[0001183e] e179                      rol.w     d0,d1
[00011840] 3ac1                      move.w    d1,(a5)+
[00011842] 51cf fff6                 dbf       d7,$0001183A
[00011846] 321c                      move.w    (a4)+,d1
[00011848] 4641                      not.w     d1
[0001184a] e179                      rol.w     d0,d1
[0001184c] 3ac1                      move.w    d1,(a5)+
[0001184e] 51ce fff6                 dbf       d6,$00011846
[00011852] 6036                      bra.s     $0001188A
[00011854] 9440                      sub.w     d0,d2
[00011856] 48c6                      ext.l     d6
[00011858] e98e                      lsl.l     #4,d6
[0001185a] 2646                      movea.l   d6,a3
[0001185c] 2a48                      movea.l   a0,a5
[0001185e] 780f                      moveq.l   #15,d4
[00011860] 7c0f                      moveq.l   #15,d6
[00011862] c044                      and.w     d4,d0
[00011864] c244                      and.w     d4,d1
[00011866] 6718                      beq.s     $00011880
[00011868] 3e01                      move.w    d1,d7
[0001186a] bd47                      eor.w     d6,d7
[0001186c] 3c01                      move.w    d1,d6
[0001186e] 5346                      subq.w    #1,d6
[00011870] d241                      add.w     d1,d1
[00011872] 45f4 1000                 lea.l     0(a4,d1.w),a2
[00011876] 321a                      move.w    (a2)+,d1
[00011878] e179                      rol.w     d0,d1
[0001187a] 3ac1                      move.w    d1,(a5)+
[0001187c] 51cf fff8                 dbf       d7,$00011876
[00011880] 321c                      move.w    (a4)+,d1
[00011882] e179                      rol.w     d0,d1
[00011884] 3ac1                      move.w    d1,(a5)+
[00011886] 51ce fff8                 dbf       d6,$00011880
[0001188a] 3e05                      move.w    d5,d7
[0001188c] b644                      cmp.w     d4,d3
[0001188e] 6c02                      bge.s     $00011892
[00011890] 3803                      move.w    d3,d4
[00011892] 4843                      swap      d3
[00011894] 3604                      move.w    d4,d3
[00011896] 347c 0020                 movea.w   #$0020,a2
[0001189a] 7c0f                      moveq.l   #15,d6
[0001189c] b446                      cmp.w     d6,d2
[0001189e] 6c02                      bge.s     $000118A2
[000118a0] 3c02                      move.w    d2,d6
[000118a2] 3846                      movea.w   d6,a4
[000118a4] 9446                      sub.w     d6,d2
[000118a6] 5246                      addq.w    #1,d6
[000118a8] dc46                      add.w     d6,d6
[000118aa] 96c6                      suba.w    d6,a3
[000118ac] 4843                      swap      d3
[000118ae] 3203                      move.w    d3,d1
[000118b0] e849                      lsr.w     #4,d1
[000118b2] 2a49                      movea.l   a1,a5
[000118b4] 3c0c                      move.w    a4,d6
[000118b6] 3010                      move.w    (a0),d0
[000118b8] d040                      add.w     d0,d0
[000118ba] 645e                      bcc.s     $0001191A
[000118bc] 3802                      move.w    d2,d4
[000118be] d846                      add.w     d6,d4
[000118c0] e84c                      lsr.w     #4,d4
[000118c2] 3a04                      move.w    d4,d5
[000118c4] e84c                      lsr.w     #4,d4
[000118c6] 4645                      not.w     d5
[000118c8] 0245 000f                 andi.w    #$000F,d5
[000118cc] da45                      add.w     d5,d5
[000118ce] da45                      add.w     d5,d5
[000118d0] 2c4d                      movea.l   a5,a6
[000118d2] 4efb 5002                 jmp       $000118D6(pc,d5.w)
[000118d6] 3c87                      move.w    d7,(a6)
[000118d8] dcca                      adda.w    a2,a6
[000118da] 3c87                      move.w    d7,(a6)
[000118dc] dcca                      adda.w    a2,a6
[000118de] 3c87                      move.w    d7,(a6)
[000118e0] dcca                      adda.w    a2,a6
[000118e2] 3c87                      move.w    d7,(a6)
[000118e4] dcca                      adda.w    a2,a6
[000118e6] 3c87                      move.w    d7,(a6)
[000118e8] dcca                      adda.w    a2,a6
[000118ea] 3c87                      move.w    d7,(a6)
[000118ec] dcca                      adda.w    a2,a6
[000118ee] 3c87                      move.w    d7,(a6)
[000118f0] dcca                      adda.w    a2,a6
[000118f2] 3c87                      move.w    d7,(a6)
[000118f4] dcca                      adda.w    a2,a6
[000118f6] 3c87                      move.w    d7,(a6)
[000118f8] dcca                      adda.w    a2,a6
[000118fa] 3c87                      move.w    d7,(a6)
[000118fc] dcca                      adda.w    a2,a6
[000118fe] 3c87                      move.w    d7,(a6)
[00011900] dcca                      adda.w    a2,a6
[00011902] 3c87                      move.w    d7,(a6)
[00011904] dcca                      adda.w    a2,a6
[00011906] 3c87                      move.w    d7,(a6)
[00011908] dcca                      adda.w    a2,a6
[0001190a] 3c87                      move.w    d7,(a6)
[0001190c] dcca                      adda.w    a2,a6
[0001190e] 3c87                      move.w    d7,(a6)
[00011910] dcca                      adda.w    a2,a6
[00011912] 3c87                      move.w    d7,(a6)
[00011914] dcca                      adda.w    a2,a6
[00011916] 51cc ffbe                 dbf       d4,$000118D6
[0001191a] 548d                      addq.l    #2,a5
[0001191c] 51ce ff9a                 dbf       d6,$000118B8
[00011920] dbcb                      adda.l    a3,a5
[00011922] 51c9 ff90                 dbf       d1,$000118B4
[00011926] 5488                      addq.l    #2,a0
[00011928] d2d7                      adda.w    (a7),a1
[0001192a] 5343                      subq.w    #1,d3
[0001192c] 4843                      swap      d3
[0001192e] 51cb ff7c                 dbf       d3,$000118AC
[00011932] 548f                      addq.l    #2,a7
[00011934] 4e75                      rts
[00011936] 206e 01c2                 movea.l   450(a6),a0
[0001193a] 226e 01d6                 movea.l   470(a6),a1
[0001193e] 346e 01c6                 movea.w   454(a6),a2
[00011942] 366e 01da                 movea.w   474(a6),a3
[00011946] 026e 0003 01ee            andi.w    #$0003,494(a6)
[0001194c] 3c0a                      move.w    a2,d6
[0001194e] 3e0b                      move.w    a3,d7
[00011950] c3c6                      muls.w    d6,d1
[00011952] d1c1                      adda.l    d1,a0
[00011954] 3200                      move.w    d0,d1
[00011956] e849                      lsr.w     #4,d1
[00011958] d241                      add.w     d1,d1
[0001195a] d0c1                      adda.w    d1,a0
[0001195c] c7c7                      muls.w    d7,d3
[0001195e] d3c3                      adda.l    d3,a1
[00011960] d442                      add.w     d2,d2
[00011962] d2c2                      adda.w    d2,a1
[00011964] 720f                      moveq.l   #15,d1
[00011966] c041                      and.w     d1,d0
[00011968] b141                      eor.w     d0,d1
[0001196a] b841                      cmp.w     d1,d4
[0001196c] 6c02                      bge.s     $00011970
[0001196e] 3204                      move.w    d4,d1
[00011970] 4840                      swap      d0
[00011972] 3001                      move.w    d1,d0
[00011974] 4840                      swap      d0
[00011976] 3400                      move.w    d0,d2
[00011978] d444                      add.w     d4,d2
[0001197a] e84a                      lsr.w     #4,d2
[0001197c] d442                      add.w     d2,d2
[0001197e] 5442                      addq.w    #2,d2
[00011980] 94c2                      suba.w    d2,a2
[00011982] 3404                      move.w    d4,d2
[00011984] d442                      add.w     d2,d2
[00011986] 5442                      addq.w    #2,d2
[00011988] 96c2                      suba.w    d2,a3
[0001198a] 49ee 0458                 lea.l     1112(a6),a4
[0001198e] 2a4c                      movea.l   a4,a5
[00011990] 3c2e 01ea                 move.w    490(a6),d6
[00011994] dc46                      add.w     d6,d6
[00011996] d8c6                      adda.w    d6,a4
[00011998] 2c14                      move.l    (a4),d6
[0001199a] 3c14                      move.w    (a4),d6
[0001199c] 3e2e 01ec                 move.w    492(a6),d7
[000119a0] de47                      add.w     d7,d7
[000119a2] dac7                      adda.w    d7,a5
[000119a4] 2e15                      move.l    (a5),d7
[000119a6] 3e15                      move.w    (a5),d7
[000119a8] 342e 01ee                 move.w    494(a6),d2
[000119ac] d442                      add.w     d2,d2
[000119ae] 343b 2006                 move.w    $000119B6(pc,d2.w),d2
[000119b2] 4efb 2002                 jmp       $000119B6(pc,d2.w)
J3:
[000119b6] 0008                      dc.w $0008   ; $000119be-$000119b6
[000119b8] 007c                      dc.w $007c   ; $00011a32-$000119b6
[000119ba] 00e6                      dc.w $00e6   ; $00011a9c-$000119b6
[000119bc] 0150                      dc.w $0150   ; $00011b06-$000119b6
[000119be] 2406                      move.l    d6,d2
[000119c0] 3407                      move.w    d7,d2
[000119c2] 2842                      movea.l   d2,a4
[000119c4] 2607                      move.l    d7,d3
[000119c6] 3606                      move.w    d6,d3
[000119c8] 2a43                      movea.l   d3,a5
[000119ca] 3604                      move.w    d4,d3
[000119cc] 3418                      move.w    (a0)+,d2
[000119ce] e17a                      rol.w     d0,d2
[000119d0] 2200                      move.l    d0,d1
[000119d2] 4841                      swap      d1
[000119d4] 6002                      bra.s     $000119D8
[000119d6] 3418                      move.w    (a0)+,d2
[000119d8] 9641                      sub.w     d1,d3
[000119da] 5343                      subq.w    #1,d3
[000119dc] 5441                      addq.w    #2,d1
[000119de] 600a                      bra.s     $000119EA
[000119e0] d442                      add.w     d2,d2
[000119e2] 6418                      bcc.s     $000119FC
[000119e4] d442                      add.w     d2,d2
[000119e6] 640a                      bcc.s     $000119F2
[000119e8] 22c6                      move.l    d6,(a1)+
[000119ea] 5541                      subq.w    #2,d1
[000119ec] 6ef2                      bgt.s     $000119E0
[000119ee] 6724                      beq.s     $00011A14
[000119f0] 602c                      bra.s     $00011A1E
[000119f2] 22cc                      move.l    a4,(a1)+
[000119f4] 5541                      subq.w    #2,d1
[000119f6] 6ee8                      bgt.s     $000119E0
[000119f8] 671a                      beq.s     $00011A14
[000119fa] 6022                      bra.s     $00011A1E
[000119fc] d442                      add.w     d2,d2
[000119fe] 650a                      bcs.s     $00011A0A
[00011a00] 22c7                      move.l    d7,(a1)+
[00011a02] 5541                      subq.w    #2,d1
[00011a04] 6eda                      bgt.s     $000119E0
[00011a06] 670c                      beq.s     $00011A14
[00011a08] 6014                      bra.s     $00011A1E
[00011a0a] 22cd                      move.l    a5,(a1)+
[00011a0c] 5541                      subq.w    #2,d1
[00011a0e] 6ed0                      bgt.s     $000119E0
[00011a10] 6702                      beq.s     $00011A14
[00011a12] 600a                      bra.s     $00011A1E
[00011a14] d442                      add.w     d2,d2
[00011a16] 6404                      bcc.s     $00011A1C
[00011a18] 32c6                      move.w    d6,(a1)+
[00011a1a] 6002                      bra.s     $00011A1E
[00011a1c] 32c7                      move.w    d7,(a1)+
[00011a1e] 720f                      moveq.l   #15,d1
[00011a20] b641                      cmp.w     d1,d3
[00011a22] 6cb2                      bge.s     $000119D6
[00011a24] 3203                      move.w    d3,d1
[00011a26] 6aae                      bpl.s     $000119D6
[00011a28] d0ca                      adda.w    a2,a0
[00011a2a] d2cb                      adda.w    a3,a1
[00011a2c] 51cd ff9c                 dbf       d5,$000119CA
[00011a30] 4e75                      rts
[00011a32] 3604                      move.w    d4,d3
[00011a34] 3418                      move.w    (a0)+,d2
[00011a36] e17a                      rol.w     d0,d2
[00011a38] 2200                      move.l    d0,d1
[00011a3a] 4841                      swap      d1
[00011a3c] 6002                      bra.s     $00011A40
[00011a3e] 3418                      move.w    (a0)+,d2
[00011a40] 9641                      sub.w     d1,d3
[00011a42] 5343                      subq.w    #1,d3
[00011a44] 5441                      addq.w    #2,d1
[00011a46] 6024                      bra.s     $00011A6C
[00011a48] d442                      add.w     d2,d2
[00011a4a] 651a                      bcs.s     $00011A66
[00011a4c] d442                      add.w     d2,d2
[00011a4e] 650a                      bcs.s     $00011A5A
[00011a50] 5889                      addq.l    #4,a1
[00011a52] 5541                      subq.w    #2,d1
[00011a54] 6ef2                      bgt.s     $00011A48
[00011a56] 6728                      beq.s     $00011A80
[00011a58] 602e                      bra.s     $00011A88
[00011a5a] 5489                      addq.l    #2,a1
[00011a5c] 32c6                      move.w    d6,(a1)+
[00011a5e] 5541                      subq.w    #2,d1
[00011a60] 6ee6                      bgt.s     $00011A48
[00011a62] 671c                      beq.s     $00011A80
[00011a64] 6022                      bra.s     $00011A88
[00011a66] d442                      add.w     d2,d2
[00011a68] 640a                      bcc.s     $00011A74
[00011a6a] 22c6                      move.l    d6,(a1)+
[00011a6c] 5541                      subq.w    #2,d1
[00011a6e] 6ed8                      bgt.s     $00011A48
[00011a70] 670e                      beq.s     $00011A80
[00011a72] 6014                      bra.s     $00011A88
[00011a74] 32c6                      move.w    d6,(a1)+
[00011a76] 5489                      addq.l    #2,a1
[00011a78] 5541                      subq.w    #2,d1
[00011a7a] 6ecc                      bgt.s     $00011A48
[00011a7c] 6702                      beq.s     $00011A80
[00011a7e] 6008                      bra.s     $00011A88
[00011a80] d442                      add.w     d2,d2
[00011a82] 6402                      bcc.s     $00011A86
[00011a84] 3286                      move.w    d6,(a1)
[00011a86] 5489                      addq.l    #2,a1
[00011a88] 720f                      moveq.l   #15,d1
[00011a8a] b641                      cmp.w     d1,d3
[00011a8c] 6cb0                      bge.s     $00011A3E
[00011a8e] 3203                      move.w    d3,d1
[00011a90] 6aac                      bpl.s     $00011A3E
[00011a92] d0ca                      adda.w    a2,a0
[00011a94] d2cb                      adda.w    a3,a1
[00011a96] 51cd ff9a                 dbf       d5,$00011A32
[00011a9a] 4e75                      rts
[00011a9c] 3604                      move.w    d4,d3
[00011a9e] 3418                      move.w    (a0)+,d2
[00011aa0] e17a                      rol.w     d0,d2
[00011aa2] 2200                      move.l    d0,d1
[00011aa4] 4841                      swap      d1
[00011aa6] 6002                      bra.s     $00011AAA
[00011aa8] 3418                      move.w    (a0)+,d2
[00011aaa] 9641                      sub.w     d1,d3
[00011aac] 5343                      subq.w    #1,d3
[00011aae] 5441                      addq.w    #2,d1
[00011ab0] 6024                      bra.s     $00011AD6
[00011ab2] d442                      add.w     d2,d2
[00011ab4] 651a                      bcs.s     $00011AD0
[00011ab6] d442                      add.w     d2,d2
[00011ab8] 650a                      bcs.s     $00011AC4
[00011aba] 5889                      addq.l    #4,a1
[00011abc] 5541                      subq.w    #2,d1
[00011abe] 6ef2                      bgt.s     $00011AB2
[00011ac0] 6728                      beq.s     $00011AEA
[00011ac2] 602e                      bra.s     $00011AF2
[00011ac4] 5489                      addq.l    #2,a1
[00011ac6] 4659                      not.w     (a1)+
[00011ac8] 5541                      subq.w    #2,d1
[00011aca] 6ee6                      bgt.s     $00011AB2
[00011acc] 671c                      beq.s     $00011AEA
[00011ace] 6022                      bra.s     $00011AF2
[00011ad0] d442                      add.w     d2,d2
[00011ad2] 640a                      bcc.s     $00011ADE
[00011ad4] 4699                      not.l     (a1)+
[00011ad6] 5541                      subq.w    #2,d1
[00011ad8] 6ed8                      bgt.s     $00011AB2
[00011ada] 670e                      beq.s     $00011AEA
[00011adc] 6014                      bra.s     $00011AF2
[00011ade] 4659                      not.w     (a1)+
[00011ae0] 5489                      addq.l    #2,a1
[00011ae2] 5541                      subq.w    #2,d1
[00011ae4] 6ecc                      bgt.s     $00011AB2
[00011ae6] 6702                      beq.s     $00011AEA
[00011ae8] 6008                      bra.s     $00011AF2
[00011aea] d442                      add.w     d2,d2
[00011aec] 6402                      bcc.s     $00011AF0
[00011aee] 4651                      not.w     (a1)
[00011af0] 5489                      addq.l    #2,a1
[00011af2] 720f                      moveq.l   #15,d1
[00011af4] b641                      cmp.w     d1,d3
[00011af6] 6cb0                      bge.s     $00011AA8
[00011af8] 3203                      move.w    d3,d1
[00011afa] 6aac                      bpl.s     $00011AA8
[00011afc] d0ca                      adda.w    a2,a0
[00011afe] d2cb                      adda.w    a3,a1
[00011b00] 51cd ff9a                 dbf       d5,$00011A9C
[00011b04] 4e75                      rts
[00011b06] 3604                      move.w    d4,d3
[00011b08] 3418                      move.w    (a0)+,d2
[00011b0a] e17a                      rol.w     d0,d2
[00011b0c] 2200                      move.l    d0,d1
[00011b0e] 4841                      swap      d1
[00011b10] 6002                      bra.s     $00011B14
[00011b12] 3418                      move.w    (a0)+,d2
[00011b14] 9641                      sub.w     d1,d3
[00011b16] 5343                      subq.w    #1,d3
[00011b18] 5441                      addq.w    #2,d1
[00011b1a] 600a                      bra.s     $00011B26
[00011b1c] d442                      add.w     d2,d2
[00011b1e] 651a                      bcs.s     $00011B3A
[00011b20] d442                      add.w     d2,d2
[00011b22] 650a                      bcs.s     $00011B2E
[00011b24] 22c7                      move.l    d7,(a1)+
[00011b26] 5541                      subq.w    #2,d1
[00011b28] 6ef2                      bgt.s     $00011B1C
[00011b2a] 6728                      beq.s     $00011B54
[00011b2c] 602e                      bra.s     $00011B5C
[00011b2e] 32c7                      move.w    d7,(a1)+
[00011b30] 5489                      addq.l    #2,a1
[00011b32] 5541                      subq.w    #2,d1
[00011b34] 6ee6                      bgt.s     $00011B1C
[00011b36] 671c                      beq.s     $00011B54
[00011b38] 6022                      bra.s     $00011B5C
[00011b3a] d442                      add.w     d2,d2
[00011b3c] 640a                      bcc.s     $00011B48
[00011b3e] 5889                      addq.l    #4,a1
[00011b40] 5541                      subq.w    #2,d1
[00011b42] 6ed8                      bgt.s     $00011B1C
[00011b44] 670e                      beq.s     $00011B54
[00011b46] 6014                      bra.s     $00011B5C
[00011b48] 5489                      addq.l    #2,a1
[00011b4a] 32c7                      move.w    d7,(a1)+
[00011b4c] 5541                      subq.w    #2,d1
[00011b4e] 6ecc                      bgt.s     $00011B1C
[00011b50] 6702                      beq.s     $00011B54
[00011b52] 6008                      bra.s     $00011B5C
[00011b54] d442                      add.w     d2,d2
[00011b56] 6502                      bcs.s     $00011B5A
[00011b58] 3287                      move.w    d7,(a1)
[00011b5a] 5489                      addq.l    #2,a1
[00011b5c] 720f                      moveq.l   #15,d1
[00011b5e] b641                      cmp.w     d1,d3
[00011b60] 6cb0                      bge.s     $00011B12
[00011b62] 3203                      move.w    d3,d1
[00011b64] 6aac                      bpl.s     $00011B12
[00011b66] d0ca                      adda.w    a2,a0
[00011b68] d2cb                      adda.w    a3,a1
[00011b6a] 51cd ff9a                 dbf       d5,$00011B06
[00011b6e] 4e75                      rts
[00011b70] 4e75                      rts
[00011b72] bc44                      cmp.w     d4,d6
[00011b74] be45                      cmp.w     d5,d7
[00011b76] 08ae 0004 01ef            bclr      #4,495(a6)
[00011b7c] 6600 fdb8                 bne       $00011936
[00011b80] 7e0f                      moveq.l   #15,d7
[00011b82] ce6e 01ee                 and.w     494(a6),d7
[00011b86] 206e 01c2                 movea.l   450(a6),a0
[00011b8a] 206e 01c2                 movea.l   450(a6),a0
[00011b8e] 226e 01d6                 movea.l   470(a6),a1
[00011b92] 346e 01c6                 movea.w   454(a6),a2
[00011b96] 366e 01da                 movea.w   474(a6),a3
[00011b9a] 3c2e 01c8                 move.w    456(a6),d6
[00011b9e] bc6e 01dc                 cmp.w     476(a6),d6
[00011ba2] 66cc                      bne.s     $00011B70
[00011ba4] 0446 000f                 subi.w    #$000F,d6
[00011ba8] 66c6                      bne.s     $00011B70
[00011baa] 48c0                      ext.l     d0
[00011bac] 48c2                      ext.l     d2
[00011bae] 3c0a                      move.w    a2,d6
[00011bb0] c2c6                      mulu.w    d6,d1
[00011bb2] d280                      add.l     d0,d1
[00011bb4] d280                      add.l     d0,d1
[00011bb6] d1c1                      adda.l    d1,a0
[00011bb8] 3c0b                      move.w    a3,d6
[00011bba] c6c6                      mulu.w    d6,d3
[00011bbc] d682                      add.l     d2,d3
[00011bbe] d682                      add.l     d2,d3
[00011bc0] d3c3                      adda.l    d3,a1
[00011bc2] b1c9                      cmpa.l    a1,a0
[00011bc4] 6200 0350                 bhi       $00011F16
[00011bc8] 3c3c 8401                 move.w    #$8401,d6
[00011bcc] 0f06                      btst      d7,d6
[00011bce] 6600 0346                 bne       $00011F16
[00011bd2] 3c0a                      move.w    a2,d6
[00011bd4] ccc5                      mulu.w    d5,d6
[00011bd6] 2848                      movea.l   a0,a4
[00011bd8] d9c6                      adda.l    d6,a4
[00011bda] d8c4                      adda.w    d4,a4
[00011bdc] d8c4                      adda.w    d4,a4
[00011bde] b9c9                      cmpa.l    a1,a4
[00011be0] 6500 0334                 bcs       $00011F16
[00011be4] 548c                      addq.l    #2,a4
[00011be6] d28c                      add.l     a4,d1
[00011be8] 9288                      sub.l     a0,d1
[00011bea] 2a49                      movea.l   a1,a5
[00011bec] 3c0b                      move.w    a3,d6
[00011bee] ccc5                      mulu.w    d5,d6
[00011bf0] dbc6                      adda.l    d6,a5
[00011bf2] dac4                      adda.w    d4,a5
[00011bf4] dac4                      adda.w    d4,a5
[00011bf6] 548d                      addq.l    #2,a5
[00011bf8] d68d                      add.l     a5,d3
[00011bfa] 9689                      sub.l     a1,d3
[00011bfc] c14c                      exg       a0,a4
[00011bfe] c34d                      exg       a1,a5
[00011c00] 3c04                      move.w    d4,d6
[00011c02] 5246                      addq.w    #1,d6
[00011c04] dc46                      add.w     d6,d6
[00011c06] 94c6                      suba.w    d6,a2
[00011c08] 96c6                      suba.w    d6,a3
[00011c0a] 7002                      moveq.l   #2,d0
[00011c0c] 0804 0000                 btst      #0,d4
[00011c10] 6604                      bne.s     $00011C16
[00011c12] 7000                      moveq.l   #0,d0
[00011c14] 5344                      subq.w    #1,d4
[00011c16] 7206                      moveq.l   #6,d1
[00011c18] c244                      and.w     d4,d1
[00011c1a] 0a41 0006                 eori.w    #$0006,d1
[00011c1e] e644                      asr.w     #3,d4
[00011c20] 4a44                      tst.w     d4
[00011c22] 6a04                      bpl.s     $00011C28
[00011c24] 7800                      moveq.l   #0,d4
[00011c26] 7208                      moveq.l   #8,d1
[00011c28] de47                      add.w     d7,d7
[00011c2a] de47                      add.w     d7,d7
[00011c2c] 49fb 7022                 lea.l     $00011C50(pc,d7.w),a4
[00011c30] 3e1c                      move.w    (a4)+,d7
[00011c32] 6716                      beq.s     $00011C4A
[00011c34] 5347                      subq.w    #1,d7
[00011c36] 670e                      beq.s     $00011C46
[00011c38] 3e00                      move.w    d0,d7
[00011c3a] d040                      add.w     d0,d0
[00011c3c] d047                      add.w     d7,d0
[00011c3e] 3e01                      move.w    d1,d7
[00011c40] d241                      add.w     d1,d1
[00011c42] d247                      add.w     d7,d1
[00011c44] 6004                      bra.s     $00011C4A
[00011c46] d040                      add.w     d0,d0
[00011c48] d241                      add.w     d1,d1
[00011c4a] 3e1c                      move.w    (a4)+,d7
[00011c4c] 4efb 7002                 jmp       $00011C50(pc,d7.w)
[00011c50] 0000 035a                 ori.b     #$5A,d0
[00011c54] 0001 0040                 ori.b     #$40,d1
[00011c58] 0002 0070                 ori.b     #$70,d2
[00011c5c] 0000 00aa                 ori.b     #$AA,d0
[00011c60] 0002 00d0                 ori.b     #$D0,d2
[00011c64] 0000 0108                 ori.b     #$08,d0
[00011c68] 0001 010a                 ori.b     #$0A,d1
[00011c6c] 0001 013a                 ori.b     #$3A,d1
[00011c70] 0002 016a                 ori.b     #$6A,d2
[00011c74] 0002 01a4                 ori.b     #$A4,d2
[00011c78] 0000 051e                 ori.b     #$1E,d0
[00011c7c] 0002 01de                 ori.b     #$DE,d2
[00011c80] 0002 0218                 ori.b     #$18,d2
[00011c84] 0002 0252                 ori.b     #$52,d2
[00011c88] 0002 028c                 ori.b     #$8C,d2
[00011c8c] 0000 0356                 ori.b     #$56,d0
[00011c90] 49fb 2008                 lea.l     $00011C9A(pc,d2.w),a4
[00011c94] 4bfb 100c                 lea.l     $00011CA2(pc,d1.w),a5
[00011c98] 4ed4                      jmp       (a4)
[00011c9a] 3020                      move.w    -(a0),d0
[00011c9c] c161                      and.w     d0,-(a1)
[00011c9e] 3c04                      move.w    d4,d6
[00011ca0] 4ed5                      jmp       (a5)
[00011ca2] 2020                      move.l    -(a0),d0
[00011ca4] c1a1                      and.l     d0,-(a1)
[00011ca6] 2020                      move.l    -(a0),d0
[00011ca8] c1a1                      and.l     d0,-(a1)
[00011caa] 2020                      move.l    -(a0),d0
[00011cac] c1a1                      and.l     d0,-(a1)
[00011cae] 2020                      move.l    -(a0),d0
[00011cb0] c1a1                      and.l     d0,-(a1)
[00011cb2] 51ce ffee                 dbf       d6,$00011CA2
[00011cb6] 90ca                      suba.w    a2,a0
[00011cb8] 92cb                      suba.w    a3,a1
[00011cba] 51cd ffdc                 dbf       d5,$00011C98
[00011cbe] 4e75                      rts
[00011cc0] 49fb 0008                 lea.l     $00011CCA(pc,d0.w),a4
[00011cc4] 4bfb 100e                 lea.l     $00011CD4(pc,d1.w),a5
[00011cc8] 4ed4                      jmp       (a4)
[00011cca] 3020                      move.w    -(a0),d0
[00011ccc] 4651                      not.w     (a1)
[00011cce] c161                      and.w     d0,-(a1)
[00011cd0] 3c04                      move.w    d4,d6
[00011cd2] 4ed5                      jmp       (a5)
[00011cd4] 2020                      move.l    -(a0),d0
[00011cd6] 4691                      not.l     (a1)
[00011cd8] c1a1                      and.l     d0,-(a1)
[00011cda] 2020                      move.l    -(a0),d0
[00011cdc] 4691                      not.l     (a1)
[00011cde] c1a1                      and.l     d0,-(a1)
[00011ce0] 2020                      move.l    -(a0),d0
[00011ce2] 4691                      not.l     (a1)
[00011ce4] c1a1                      and.l     d0,-(a1)
[00011ce6] 2020                      move.l    -(a0),d0
[00011ce8] 4691                      not.l     (a1)
[00011cea] c1a1                      and.l     d0,-(a1)
[00011cec] 51ce ffe6                 dbf       d6,$00011CD4
[00011cf0] 90ca                      suba.w    a2,a0
[00011cf2] 92cb                      suba.w    a3,a1
[00011cf4] 51cd ffd2                 dbf       d5,$00011CC8
[00011cf8] 4e75                      rts
[00011cfa] 49fb 0008                 lea.l     $00011D04(pc,d0.w),a4
[00011cfe] 4bfb 100a                 lea.l     $00011D0A(pc,d1.w),a5
[00011d02] 4ed4                      jmp       (a4)
[00011d04] 3320                      move.w    -(a0),-(a1)
[00011d06] 3c04                      move.w    d4,d6
[00011d08] 4ed5                      jmp       (a5)
[00011d0a] 2320                      move.l    -(a0),-(a1)
[00011d0c] 2320                      move.l    -(a0),-(a1)
[00011d0e] 2320                      move.l    -(a0),-(a1)
[00011d10] 2320                      move.l    -(a0),-(a1)
[00011d12] 51ce fff6                 dbf       d6,$00011D0A
[00011d16] 90ca                      suba.w    a2,a0
[00011d18] 92cb                      suba.w    a3,a1
[00011d1a] 51cd ffe6                 dbf       d5,$00011D02
[00011d1e] 4e75                      rts
[00011d20] 49fb 0008                 lea.l     $00011D2A(pc,d0.w),a4
[00011d24] 4bfb 100e                 lea.l     $00011D34(pc,d1.w),a5
[00011d28] 4ed4                      jmp       (a4)
[00011d2a] 3020                      move.w    -(a0),d0
[00011d2c] 4640                      not.w     d0
[00011d2e] c161                      and.w     d0,-(a1)
[00011d30] 3c04                      move.w    d4,d6
[00011d32] 4ed5                      jmp       (a5)
[00011d34] 2020                      move.l    -(a0),d0
[00011d36] 4680                      not.l     d0
[00011d38] c1a1                      and.l     d0,-(a1)
[00011d3a] 2020                      move.l    -(a0),d0
[00011d3c] 4680                      not.l     d0
[00011d3e] c1a1                      and.l     d0,-(a1)
[00011d40] 2020                      move.l    -(a0),d0
[00011d42] 4680                      not.l     d0
[00011d44] c1a1                      and.l     d0,-(a1)
[00011d46] 2020                      move.l    -(a0),d0
[00011d48] 4680                      not.l     d0
[00011d4a] c1a1                      and.l     d0,-(a1)
[00011d4c] 51ce ffe6                 dbf       d6,$00011D34
[00011d50] 90ca                      suba.w    a2,a0
[00011d52] 92cb                      suba.w    a3,a1
[00011d54] 51cd ffd2                 dbf       d5,$00011D28
[00011d58] 4e75                      rts
[00011d5a] 49fb 0008                 lea.l     $00011D64(pc,d0.w),a4
[00011d5e] 4bfb 100c                 lea.l     $00011D6C(pc,d1.w),a5
[00011d62] 4ed4                      jmp       (a4)
[00011d64] 3020                      move.w    -(a0),d0
[00011d66] b161                      eor.w     d0,-(a1)
[00011d68] 3c04                      move.w    d4,d6
[00011d6a] 4ed5                      jmp       (a5)
[00011d6c] 2020                      move.l    -(a0),d0
[00011d6e] b1a1                      eor.l     d0,-(a1)
[00011d70] 2020                      move.l    -(a0),d0
[00011d72] b1a1                      eor.l     d0,-(a1)
[00011d74] 2020                      move.l    -(a0),d0
[00011d76] b1a1                      eor.l     d0,-(a1)
[00011d78] 2020                      move.l    -(a0),d0
[00011d7a] b1a1                      eor.l     d0,-(a1)
[00011d7c] 51ce ffee                 dbf       d6,$00011D6C
[00011d80] 90ca                      suba.w    a2,a0
[00011d82] 92cb                      suba.w    a3,a1
[00011d84] 51cd ffdc                 dbf       d5,$00011D62
[00011d88] 4e75                      rts
[00011d8a] 49fb 0008                 lea.l     $00011D94(pc,d0.w),a4
[00011d8e] 4bfb 100c                 lea.l     $00011D9C(pc,d1.w),a5
[00011d92] 4ed4                      jmp       (a4)
[00011d94] 3020                      move.w    -(a0),d0
[00011d96] 8161                      or.w      d0,-(a1)
[00011d98] 3c04                      move.w    d4,d6
[00011d9a] 4ed5                      jmp       (a5)
[00011d9c] 2020                      move.l    -(a0),d0
[00011d9e] 81a1                      or.l      d0,-(a1)
[00011da0] 2020                      move.l    -(a0),d0
[00011da2] 81a1                      or.l      d0,-(a1)
[00011da4] 2020                      move.l    -(a0),d0
[00011da6] 81a1                      or.l      d0,-(a1)
[00011da8] 2020                      move.l    -(a0),d0
[00011daa] 81a1                      or.l      d0,-(a1)
[00011dac] 51ce ffee                 dbf       d6,$00011D9C
[00011db0] 90ca                      suba.w    a2,a0
[00011db2] 92cb                      suba.w    a3,a1
[00011db4] 51cd ffdc                 dbf       d5,$00011D92
[00011db8] 4e75                      rts
[00011dba] 49fb 0008                 lea.l     $00011DC4(pc,d0.w),a4
[00011dbe] 4bfb 100e                 lea.l     $00011DCE(pc,d1.w),a5
[00011dc2] 4ed4                      jmp       (a4)
[00011dc4] 3020                      move.w    -(a0),d0
[00011dc6] 8151                      or.w      d0,(a1)
[00011dc8] 4661                      not.w     -(a1)
[00011dca] 3c04                      move.w    d4,d6
[00011dcc] 4ed5                      jmp       (a5)
[00011dce] 2020                      move.l    -(a0),d0
[00011dd0] 8191                      or.l      d0,(a1)
[00011dd2] 46a1                      not.l     -(a1)
[00011dd4] 2020                      move.l    -(a0),d0
[00011dd6] 8191                      or.l      d0,(a1)
[00011dd8] 46a1                      not.l     -(a1)
[00011dda] 2020                      move.l    -(a0),d0
[00011ddc] 8191                      or.l      d0,(a1)
[00011dde] 46a1                      not.l     -(a1)
[00011de0] 2020                      move.l    -(a0),d0
[00011de2] 8191                      or.l      d0,(a1)
[00011de4] 46a1                      not.l     -(a1)
[00011de6] 51ce ffe6                 dbf       d6,$00011DCE
[00011dea] 90ca                      suba.w    a2,a0
[00011dec] 92cb                      suba.w    a3,a1
[00011dee] 51cd ffd2                 dbf       d5,$00011DC2
[00011df2] 4e75                      rts
[00011df4] 49fb 0008                 lea.l     $00011DFE(pc,d0.w),a4
[00011df8] 4bfb 100e                 lea.l     $00011E08(pc,d1.w),a5
[00011dfc] 4ed4                      jmp       (a4)
[00011dfe] 3020                      move.w    -(a0),d0
[00011e00] b151                      eor.w     d0,(a1)
[00011e02] 4661                      not.w     -(a1)
[00011e04] 3c04                      move.w    d4,d6
[00011e06] 4ed5                      jmp       (a5)
[00011e08] 2020                      move.l    -(a0),d0
[00011e0a] b191                      eor.l     d0,(a1)
[00011e0c] 46a1                      not.l     -(a1)
[00011e0e] 2020                      move.l    -(a0),d0
[00011e10] b191                      eor.l     d0,(a1)
[00011e12] 46a1                      not.l     -(a1)
[00011e14] 2020                      move.l    -(a0),d0
[00011e16] b191                      eor.l     d0,(a1)
[00011e18] 46a1                      not.l     -(a1)
[00011e1a] 2020                      move.l    -(a0),d0
[00011e1c] b191                      eor.l     d0,(a1)
[00011e1e] 46a1                      not.l     -(a1)
[00011e20] 51ce ffe6                 dbf       d6,$00011E08
[00011e24] 90ca                      suba.w    a2,a0
[00011e26] 92cb                      suba.w    a3,a1
[00011e28] 51cd ffd2                 dbf       d5,$00011DFC
[00011e2c] 4e75                      rts
[00011e2e] 49fb 0008                 lea.l     $00011E38(pc,d0.w),a4
[00011e32] 4bfb 100e                 lea.l     $00011E42(pc,d1.w),a5
[00011e36] 4ed4                      jmp       (a4)
[00011e38] 4651                      not.w     (a1)
[00011e3a] 3020                      move.w    -(a0),d0
[00011e3c] 8161                      or.w      d0,-(a1)
[00011e3e] 3c04                      move.w    d4,d6
[00011e40] 4ed5                      jmp       (a5)
[00011e42] 4691                      not.l     (a1)
[00011e44] 2020                      move.l    -(a0),d0
[00011e46] 81a1                      or.l      d0,-(a1)
[00011e48] 4691                      not.l     (a1)
[00011e4a] 2020                      move.l    -(a0),d0
[00011e4c] 81a1                      or.l      d0,-(a1)
[00011e4e] 4691                      not.l     (a1)
[00011e50] 2020                      move.l    -(a0),d0
[00011e52] 81a1                      or.l      d0,-(a1)
[00011e54] 4691                      not.l     (a1)
[00011e56] 2020                      move.l    -(a0),d0
[00011e58] 81a1                      or.l      d0,-(a1)
[00011e5a] 51ce ffe6                 dbf       d6,$00011E42
[00011e5e] 90ca                      suba.w    a2,a0
[00011e60] 92cb                      suba.w    a3,a1
[00011e62] 51cd ffd2                 dbf       d5,$00011E36
[00011e66] 4e75                      rts
[00011e68] 49fb 0008                 lea.l     $00011E72(pc,d0.w),a4
[00011e6c] 4bfb 100e                 lea.l     $00011E7C(pc,d1.w),a5
[00011e70] 4ed4                      jmp       (a4)
[00011e72] 3020                      move.w    -(a0),d0
[00011e74] 4640                      not.w     d0
[00011e76] 3300                      move.w    d0,-(a1)
[00011e78] 3c04                      move.w    d4,d6
[00011e7a] 4ed5                      jmp       (a5)
[00011e7c] 2020                      move.l    -(a0),d0
[00011e7e] 4680                      not.l     d0
[00011e80] 2300                      move.l    d0,-(a1)
[00011e82] 2020                      move.l    -(a0),d0
[00011e84] 4680                      not.l     d0
[00011e86] 2300                      move.l    d0,-(a1)
[00011e88] 2020                      move.l    -(a0),d0
[00011e8a] 4680                      not.l     d0
[00011e8c] 2300                      move.l    d0,-(a1)
[00011e8e] 2020                      move.l    -(a0),d0
[00011e90] 4680                      not.l     d0
[00011e92] 2300                      move.l    d0,-(a1)
[00011e94] 51ce ffe6                 dbf       d6,$00011E7C
[00011e98] 90ca                      suba.w    a2,a0
[00011e9a] 92cb                      suba.w    a3,a1
[00011e9c] 51cd ffd2                 dbf       d5,$00011E70
[00011ea0] 4e75                      rts
[00011ea2] 49fb 0008                 lea.l     $00011EAC(pc,d0.w),a4
[00011ea6] 4bfb 100e                 lea.l     $00011EB6(pc,d1.w),a5
[00011eaa] 4ed4                      jmp       (a4)
[00011eac] 3020                      move.w    -(a0),d0
[00011eae] 4640                      not.w     d0
[00011eb0] 8161                      or.w      d0,-(a1)
[00011eb2] 3c04                      move.w    d4,d6
[00011eb4] 4ed5                      jmp       (a5)
[00011eb6] 2020                      move.l    -(a0),d0
[00011eb8] 4680                      not.l     d0
[00011eba] 81a1                      or.l      d0,-(a1)
[00011ebc] 2020                      move.l    -(a0),d0
[00011ebe] 4680                      not.l     d0
[00011ec0] 81a1                      or.l      d0,-(a1)
[00011ec2] 2020                      move.l    -(a0),d0
[00011ec4] 4680                      not.l     d0
[00011ec6] 81a1                      or.l      d0,-(a1)
[00011ec8] 2020                      move.l    -(a0),d0
[00011eca] 4680                      not.l     d0
[00011ecc] 81a1                      or.l      d0,-(a1)
[00011ece] 51ce ffe6                 dbf       d6,$00011EB6
[00011ed2] 90ca                      suba.w    a2,a0
[00011ed4] 92cb                      suba.w    a3,a1
[00011ed6] 51cd ffd2                 dbf       d5,$00011EAA
[00011eda] 4e75                      rts
[00011edc] 49fb 0008                 lea.l     $00011EE6(pc,d0.w),a4
[00011ee0] 4bfb 100e                 lea.l     $00011EF0(pc,d1.w),a5
[00011ee4] 4ed4                      jmp       (a4)
[00011ee6] 3020                      move.w    -(a0),d0
[00011ee8] c151                      and.w     d0,(a1)
[00011eea] 4661                      not.w     -(a1)
[00011eec] 3c04                      move.w    d4,d6
[00011eee] 4ed5                      jmp       (a5)
[00011ef0] 2020                      move.l    -(a0),d0
[00011ef2] c191                      and.l     d0,(a1)
[00011ef4] 46a1                      not.l     -(a1)
[00011ef6] 2020                      move.l    -(a0),d0
[00011ef8] c191                      and.l     d0,(a1)
[00011efa] 46a1                      not.l     -(a1)
[00011efc] 2020                      move.l    -(a0),d0
[00011efe] c191                      and.l     d0,(a1)
[00011f00] 46a1                      not.l     -(a1)
[00011f02] 2020                      move.l    -(a0),d0
[00011f04] c191                      and.l     d0,(a1)
[00011f06] 46a1                      not.l     -(a1)
[00011f08] 51ce ffe6                 dbf       d6,$00011EF0
[00011f0c] 90ca                      suba.w    a2,a0
[00011f0e] 92cb                      suba.w    a3,a1
[00011f10] 51cd ffd2                 dbf       d5,$00011EE4
[00011f14] 4e75                      rts
[00011f16] 3c04                      move.w    d4,d6
[00011f18] 5246                      addq.w    #1,d6
[00011f1a] dc46                      add.w     d6,d6
[00011f1c] 94c6                      suba.w    d6,a2
[00011f1e] 96c6                      suba.w    d6,a3
[00011f20] 7002                      moveq.l   #2,d0
[00011f22] 0804 0000                 btst      #0,d4
[00011f26] 6604                      bne.s     $00011F2C
[00011f28] 7000                      moveq.l   #0,d0
[00011f2a] 5344                      subq.w    #1,d4
[00011f2c] 7206                      moveq.l   #6,d1
[00011f2e] c244                      and.w     d4,d1
[00011f30] 0a41 0006                 eori.w    #$0006,d1
[00011f34] e644                      asr.w     #3,d4
[00011f36] 4a44                      tst.w     d4
[00011f38] 6a04                      bpl.s     $00011F3E
[00011f3a] 7800                      moveq.l   #0,d4
[00011f3c] 7208                      moveq.l   #8,d1
[00011f3e] de47                      add.w     d7,d7
[00011f40] de47                      add.w     d7,d7
[00011f42] 49fb 7022                 lea.l     $00011F66(pc,d7.w),a4
[00011f46] 3e1c                      move.w    (a4)+,d7
[00011f48] 6716                      beq.s     $00011F60
[00011f4a] 5347                      subq.w    #1,d7
[00011f4c] 670e                      beq.s     $00011F5C
[00011f4e] 3e00                      move.w    d0,d7
[00011f50] d040                      add.w     d0,d0
[00011f52] d047                      add.w     d7,d0
[00011f54] 3e01                      move.w    d1,d7
[00011f56] d241                      add.w     d1,d1
[00011f58] d247                      add.w     d7,d1
[00011f5a] 6004                      bra.s     $00011F60
[00011f5c] d040                      add.w     d0,d0
[00011f5e] d241                      add.w     d1,d1
[00011f60] 3e1c                      move.w    (a4)+,d7
[00011f62] 4efb 7002                 jmp       $00011F66(pc,d7.w)
[00011f66] 0000 0044                 ori.b     #$44,d0
[00011f6a] 0001 006a                 ori.b     #$6A,d1
[00011f6e] 0002 009a                 ori.b     #$9A,d2
[00011f72] 0000 00d4                 ori.b     #$D4,d0
[00011f76] 0002 00fa                 ori.b     #$FA,d2
[00011f7a] 0000 fdf2                 ori.b     #$F2,d0
[00011f7e] 0001 0134                 ori.b     #$34,d1
[00011f82] 0001 0164                 ori.b     #$64,d1
[00011f86] 0002 0194                 ori.b     #$94,d2
[00011f8a] 0002 01ce                 ori.b     #$CE,d2
[00011f8e] 0000 0208                 ori.b     #$08,d0
[00011f92] 0002 022c                 ori.b     #$2C,d2
[00011f96] 0002 0266                 ori.b     #$66,d2
[00011f9a] 0002 02a0                 ori.b     #$A0,d2
[00011f9e] 0002 02da                 ori.b     #$DA,d2
[00011fa2] 0000 0040                 ori.b     #$40,d0
[00011fa6] 7eff                      moveq.l   #-1,d7
[00011fa8] 6002                      bra.s     $00011FAC
[00011faa] 7e00                      moveq.l   #0,d7
[00011fac] 49fb 0008                 lea.l     $00011FB6(pc,d0.w),a4
[00011fb0] 4bfb 100a                 lea.l     $00011FBC(pc,d1.w),a5
[00011fb4] 4ed4                      jmp       (a4)
[00011fb6] 32c7                      move.w    d7,(a1)+
[00011fb8] 3c04                      move.w    d4,d6
[00011fba] 4ed5                      jmp       (a5)
[00011fbc] 22c7                      move.l    d7,(a1)+
[00011fbe] 22c7                      move.l    d7,(a1)+
[00011fc0] 22c7                      move.l    d7,(a1)+
[00011fc2] 22c7                      move.l    d7,(a1)+
[00011fc4] 51ce fff6                 dbf       d6,$00011FBC
[00011fc8] d2cb                      adda.w    a3,a1
[00011fca] 51cd ffe8                 dbf       d5,$00011FB4
[00011fce] 4e75                      rts
[00011fd0] 49fb 0008                 lea.l     $00011FDA(pc,d0.w),a4
[00011fd4] 4bfb 100c                 lea.l     $00011FE2(pc,d1.w),a5
[00011fd8] 4ed4                      jmp       (a4)
[00011fda] 3018                      move.w    (a0)+,d0
[00011fdc] c159                      and.w     d0,(a1)+
[00011fde] 3c04                      move.w    d4,d6
[00011fe0] 4ed5                      jmp       (a5)
[00011fe2] 2018                      move.l    (a0)+,d0
[00011fe4] c199                      and.l     d0,(a1)+
[00011fe6] 2018                      move.l    (a0)+,d0
[00011fe8] c199                      and.l     d0,(a1)+
[00011fea] 2018                      move.l    (a0)+,d0
[00011fec] c199                      and.l     d0,(a1)+
[00011fee] 2018                      move.l    (a0)+,d0
[00011ff0] c199                      and.l     d0,(a1)+
[00011ff2] 51ce ffee                 dbf       d6,$00011FE2
[00011ff6] d0ca                      adda.w    a2,a0
[00011ff8] d2cb                      adda.w    a3,a1
[00011ffa] 51cd ffdc                 dbf       d5,$00011FD8
[00011ffe] 4e75                      rts
[00012000] 49fb 0008                 lea.l     $0001200A(pc,d0.w),a4
[00012004] 4bfb 100e                 lea.l     $00012014(pc,d1.w),a5
[00012008] 4ed4                      jmp       (a4)
[0001200a] 3018                      move.w    (a0)+,d0
[0001200c] 4651                      not.w     (a1)
[0001200e] c159                      and.w     d0,(a1)+
[00012010] 3c04                      move.w    d4,d6
[00012012] 4ed5                      jmp       (a5)
[00012014] 2018                      move.l    (a0)+,d0
[00012016] 4691                      not.l     (a1)
[00012018] c199                      and.l     d0,(a1)+
[0001201a] 2018                      move.l    (a0)+,d0
[0001201c] 4691                      not.l     (a1)
[0001201e] c199                      and.l     d0,(a1)+
[00012020] 2018                      move.l    (a0)+,d0
[00012022] 4691                      not.l     (a1)
[00012024] c199                      and.l     d0,(a1)+
[00012026] 2018                      move.l    (a0)+,d0
[00012028] 4691                      not.l     (a1)
[0001202a] c199                      and.l     d0,(a1)+
[0001202c] 51ce ffe6                 dbf       d6,$00012014
[00012030] d0ca                      adda.w    a2,a0
[00012032] d2cb                      adda.w    a3,a1
[00012034] 51cd ffd2                 dbf       d5,$00012008
[00012038] 4e75                      rts
[0001203a] 49fb 0008                 lea.l     $00012044(pc,d0.w),a4
[0001203e] 4bfb 100a                 lea.l     $0001204A(pc,d1.w),a5
[00012042] 4ed4                      jmp       (a4)
[00012044] 32d8                      move.w    (a0)+,(a1)+
[00012046] 3c04                      move.w    d4,d6
[00012048] 4ed5                      jmp       (a5)
[0001204a] 22d8                      move.l    (a0)+,(a1)+
[0001204c] 22d8                      move.l    (a0)+,(a1)+
[0001204e] 22d8                      move.l    (a0)+,(a1)+
[00012050] 22d8                      move.l    (a0)+,(a1)+
[00012052] 51ce fff6                 dbf       d6,$0001204A
[00012056] d0ca                      adda.w    a2,a0
[00012058] d2cb                      adda.w    a3,a1
[0001205a] 51cd ffe6                 dbf       d5,$00012042
[0001205e] 4e75                      rts
[00012060] 49fb 0008                 lea.l     $0001206A(pc,d0.w),a4
[00012064] 4bfb 100e                 lea.l     $00012074(pc,d1.w),a5
[00012068] 4ed4                      jmp       (a4)
[0001206a] 3018                      move.w    (a0)+,d0
[0001206c] 4640                      not.w     d0
[0001206e] c159                      and.w     d0,(a1)+
[00012070] 3c04                      move.w    d4,d6
[00012072] 4ed5                      jmp       (a5)
[00012074] 2018                      move.l    (a0)+,d0
[00012076] 4680                      not.l     d0
[00012078] c199                      and.l     d0,(a1)+
[0001207a] 2018                      move.l    (a0)+,d0
[0001207c] 4680                      not.l     d0
[0001207e] c199                      and.l     d0,(a1)+
[00012080] 2018                      move.l    (a0)+,d0
[00012082] 4680                      not.l     d0
[00012084] c199                      and.l     d0,(a1)+
[00012086] 2018                      move.l    (a0)+,d0
[00012088] 4680                      not.l     d0
[0001208a] c199                      and.l     d0,(a1)+
[0001208c] 51ce ffe6                 dbf       d6,$00012074
[00012090] d0ca                      adda.w    a2,a0
[00012092] d2cb                      adda.w    a3,a1
[00012094] 51cd ffd2                 dbf       d5,$00012068
[00012098] 4e75                      rts
[0001209a] 49fb 0008                 lea.l     $000120A4(pc,d0.w),a4
[0001209e] 4bfb 100c                 lea.l     $000120AC(pc,d1.w),a5
[000120a2] 4ed4                      jmp       (a4)
[000120a4] 3018                      move.w    (a0)+,d0
[000120a6] b159                      eor.w     d0,(a1)+
[000120a8] 3c04                      move.w    d4,d6
[000120aa] 4ed5                      jmp       (a5)
[000120ac] 2018                      move.l    (a0)+,d0
[000120ae] b199                      eor.l     d0,(a1)+
[000120b0] 2018                      move.l    (a0)+,d0
[000120b2] b199                      eor.l     d0,(a1)+
[000120b4] 2018                      move.l    (a0)+,d0
[000120b6] b199                      eor.l     d0,(a1)+
[000120b8] 2018                      move.l    (a0)+,d0
[000120ba] b199                      eor.l     d0,(a1)+
[000120bc] 51ce ffee                 dbf       d6,$000120AC
[000120c0] d0ca                      adda.w    a2,a0
[000120c2] d2cb                      adda.w    a3,a1
[000120c4] 51cd ffdc                 dbf       d5,$000120A2
[000120c8] 4e75                      rts
[000120ca] 49fb 0008                 lea.l     $000120D4(pc,d0.w),a4
[000120ce] 4bfb 100c                 lea.l     $000120DC(pc,d1.w),a5
[000120d2] 4ed4                      jmp       (a4)
[000120d4] 3018                      move.w    (a0)+,d0
[000120d6] 8159                      or.w      d0,(a1)+
[000120d8] 3c04                      move.w    d4,d6
[000120da] 4ed5                      jmp       (a5)
[000120dc] 2018                      move.l    (a0)+,d0
[000120de] 8199                      or.l      d0,(a1)+
[000120e0] 2018                      move.l    (a0)+,d0
[000120e2] 8199                      or.l      d0,(a1)+
[000120e4] 2018                      move.l    (a0)+,d0
[000120e6] 8199                      or.l      d0,(a1)+
[000120e8] 2018                      move.l    (a0)+,d0
[000120ea] 8199                      or.l      d0,(a1)+
[000120ec] 51ce ffee                 dbf       d6,$000120DC
[000120f0] d0ca                      adda.w    a2,a0
[000120f2] d2cb                      adda.w    a3,a1
[000120f4] 51cd ffdc                 dbf       d5,$000120D2
[000120f8] 4e75                      rts
[000120fa] 49fb 0008                 lea.l     $00012104(pc,d0.w),a4
[000120fe] 4bfb 100e                 lea.l     $0001210E(pc,d1.w),a5
[00012102] 4ed4                      jmp       (a4)
[00012104] 3018                      move.w    (a0)+,d0
[00012106] 8151                      or.w      d0,(a1)
[00012108] 4659                      not.w     (a1)+
[0001210a] 3c04                      move.w    d4,d6
[0001210c] 4ed5                      jmp       (a5)
[0001210e] 2018                      move.l    (a0)+,d0
[00012110] 8191                      or.l      d0,(a1)
[00012112] 4699                      not.l     (a1)+
[00012114] 2018                      move.l    (a0)+,d0
[00012116] 8191                      or.l      d0,(a1)
[00012118] 4699                      not.l     (a1)+
[0001211a] 2018                      move.l    (a0)+,d0
[0001211c] 8191                      or.l      d0,(a1)
[0001211e] 4699                      not.l     (a1)+
[00012120] 2018                      move.l    (a0)+,d0
[00012122] 8191                      or.l      d0,(a1)
[00012124] 4699                      not.l     (a1)+
[00012126] 51ce ffe6                 dbf       d6,$0001210E
[0001212a] d0ca                      adda.w    a2,a0
[0001212c] d2cb                      adda.w    a3,a1
[0001212e] 51cd ffd2                 dbf       d5,$00012102
[00012132] 4e75                      rts
[00012134] 49fb 0008                 lea.l     $0001213E(pc,d0.w),a4
[00012138] 4bfb 100e                 lea.l     $00012148(pc,d1.w),a5
[0001213c] 4ed4                      jmp       (a4)
[0001213e] 3018                      move.w    (a0)+,d0
[00012140] b151                      eor.w     d0,(a1)
[00012142] 4659                      not.w     (a1)+
[00012144] 3c04                      move.w    d4,d6
[00012146] 4ed5                      jmp       (a5)
[00012148] 2018                      move.l    (a0)+,d0
[0001214a] b191                      eor.l     d0,(a1)
[0001214c] 4699                      not.l     (a1)+
[0001214e] 2018                      move.l    (a0)+,d0
[00012150] b191                      eor.l     d0,(a1)
[00012152] 4699                      not.l     (a1)+
[00012154] 2018                      move.l    (a0)+,d0
[00012156] b191                      eor.l     d0,(a1)
[00012158] 4699                      not.l     (a1)+
[0001215a] 2018                      move.l    (a0)+,d0
[0001215c] b191                      eor.l     d0,(a1)
[0001215e] 4699                      not.l     (a1)+
[00012160] 51ce ffe6                 dbf       d6,$00012148
[00012164] d0ca                      adda.w    a2,a0
[00012166] d2cb                      adda.w    a3,a1
[00012168] 51cd ffd2                 dbf       d5,$0001213C
[0001216c] 4e75                      rts
[0001216e] 49fb 0008                 lea.l     $00012178(pc,d0.w),a4
[00012172] 4bfb 100a                 lea.l     $0001217E(pc,d1.w),a5
[00012176] 4ed4                      jmp       (a4)
[00012178] 4659                      not.w     (a1)+
[0001217a] 3c04                      move.w    d4,d6
[0001217c] 4ed5                      jmp       (a5)
[0001217e] 4699                      not.l     (a1)+
[00012180] 4699                      not.l     (a1)+
[00012182] 4699                      not.l     (a1)+
[00012184] 4699                      not.l     (a1)+
[00012186] 51ce fff6                 dbf       d6,$0001217E
[0001218a] d2cb                      adda.w    a3,a1
[0001218c] 51cd ffe8                 dbf       d5,$00012176
[00012190] 4e75                      rts
[00012192] 49fb 0008                 lea.l     $0001219C(pc,d0.w),a4
[00012196] 4bfb 100e                 lea.l     $000121A6(pc,d1.w),a5
[0001219a] 4ed4                      jmp       (a4)
[0001219c] 4651                      not.w     (a1)
[0001219e] 3018                      move.w    (a0)+,d0
[000121a0] 8159                      or.w      d0,(a1)+
[000121a2] 3c04                      move.w    d4,d6
[000121a4] 4ed5                      jmp       (a5)
[000121a6] 4691                      not.l     (a1)
[000121a8] 2018                      move.l    (a0)+,d0
[000121aa] 8199                      or.l      d0,(a1)+
[000121ac] 4691                      not.l     (a1)
[000121ae] 2018                      move.l    (a0)+,d0
[000121b0] 8199                      or.l      d0,(a1)+
[000121b2] 4691                      not.l     (a1)
[000121b4] 2018                      move.l    (a0)+,d0
[000121b6] 8199                      or.l      d0,(a1)+
[000121b8] 4691                      not.l     (a1)
[000121ba] 2018                      move.l    (a0)+,d0
[000121bc] 8199                      or.l      d0,(a1)+
[000121be] 51ce ffe6                 dbf       d6,$000121A6
[000121c2] d0ca                      adda.w    a2,a0
[000121c4] d2cb                      adda.w    a3,a1
[000121c6] 51cd ffd2                 dbf       d5,$0001219A
[000121ca] 4e75                      rts
[000121cc] 49fb 0008                 lea.l     $000121D6(pc,d0.w),a4
[000121d0] 4bfb 100e                 lea.l     $000121E0(pc,d1.w),a5
[000121d4] 4ed4                      jmp       (a4)
[000121d6] 3018                      move.w    (a0)+,d0
[000121d8] 4640                      not.w     d0
[000121da] 32c0                      move.w    d0,(a1)+
[000121dc] 3c04                      move.w    d4,d6
[000121de] 4ed5                      jmp       (a5)
[000121e0] 2018                      move.l    (a0)+,d0
[000121e2] 4680                      not.l     d0
[000121e4] 22c0                      move.l    d0,(a1)+
[000121e6] 2018                      move.l    (a0)+,d0
[000121e8] 4680                      not.l     d0
[000121ea] 22c0                      move.l    d0,(a1)+
[000121ec] 2018                      move.l    (a0)+,d0
[000121ee] 4680                      not.l     d0
[000121f0] 22c0                      move.l    d0,(a1)+
[000121f2] 2018                      move.l    (a0)+,d0
[000121f4] 4680                      not.l     d0
[000121f6] 22c0                      move.l    d0,(a1)+
[000121f8] 51ce ffe6                 dbf       d6,$000121E0
[000121fc] d0ca                      adda.w    a2,a0
[000121fe] d2cb                      adda.w    a3,a1
[00012200] 51cd ffd2                 dbf       d5,$000121D4
[00012204] 4e75                      rts
[00012206] 49fb 0008                 lea.l     $00012210(pc,d0.w),a4
[0001220a] 4bfb 100e                 lea.l     $0001221A(pc,d1.w),a5
[0001220e] 4ed4                      jmp       (a4)
[00012210] 3018                      move.w    (a0)+,d0
[00012212] 4640                      not.w     d0
[00012214] 8159                      or.w      d0,(a1)+
[00012216] 3c04                      move.w    d4,d6
[00012218] 4ed5                      jmp       (a5)
[0001221a] 2018                      move.l    (a0)+,d0
[0001221c] 4680                      not.l     d0
[0001221e] 8199                      or.l      d0,(a1)+
[00012220] 2018                      move.l    (a0)+,d0
[00012222] 4680                      not.l     d0
[00012224] 8199                      or.l      d0,(a1)+
[00012226] 2018                      move.l    (a0)+,d0
[00012228] 4680                      not.l     d0
[0001222a] 8199                      or.l      d0,(a1)+
[0001222c] 2018                      move.l    (a0)+,d0
[0001222e] 4680                      not.l     d0
[00012230] 8199                      or.l      d0,(a1)+
[00012232] 51ce ffe6                 dbf       d6,$0001221A
[00012236] d0ca                      adda.w    a2,a0
[00012238] d2cb                      adda.w    a3,a1
[0001223a] 51cd ffd2                 dbf       d5,$0001220E
[0001223e] 4e75                      rts
[00012240] 49fb 0008                 lea.l     $0001224A(pc,d0.w),a4
[00012244] 4bfb 100e                 lea.l     $00012254(pc,d1.w),a5
[00012248] 4ed4                      jmp       (a4)
[0001224a] 3018                      move.w    (a0)+,d0
[0001224c] c151                      and.w     d0,(a1)
[0001224e] 4659                      not.w     (a1)+
[00012250] 3c04                      move.w    d4,d6
[00012252] 4ed5                      jmp       (a5)
[00012254] 2018                      move.l    (a0)+,d0
[00012256] c191                      and.l     d0,(a1)
[00012258] 4699                      not.l     (a1)+
[0001225a] 2018                      move.l    (a0)+,d0
[0001225c] c191                      and.l     d0,(a1)
[0001225e] 4699                      not.l     (a1)+
[00012260] 2018                      move.l    (a0)+,d0
[00012262] c191                      and.l     d0,(a1)
[00012264] 4699                      not.l     (a1)+
[00012266] 2018                      move.l    (a0)+,d0
[00012268] c191                      and.l     d0,(a1)
[0001226a] 4699                      not.l     (a1)+
[0001226c] 51ce ffe6                 dbf       d6,$00012254
[00012270] d0ca                      adda.w    a2,a0
[00012272] d2cb                      adda.w    a3,a1
[00012274] 51cd ffd2                 dbf       d5,$00012248
[00012278] 4e75                      rts
[0001227a] 3600                      move.w    d0,d3
[0001227c] 4843                      swap      d3
[0001227e] 3600                      move.w    d0,d3
[00012280] 4a6e 01b2                 tst.w     434(a6)
[00012284] 670a                      beq.s     $00012290
[00012286] 266e 01ae                 movea.l   430(a6),a3
[0001228a] c3ee 01b2                 muls.w    434(a6),d1
[0001228e] 6008                      bra.s     $00012298
[00012290] 2678 044e                 movea.l   ($0000044E).w,a3
[00012294] c3f8 206e                 muls.w    ($0000206E).w,d1
[00012298] d7c1                      adda.l    d1,a3
[0001229a] d6c0                      adda.w    d0,a3
[0001229c] d6c0                      adda.w    d0,a3
[0001229e] 284b                      movea.l   a3,a4
[000122a0] 3813                      move.w    (a3),d4
[000122a2] b642                      cmp.w     d2,d3
[000122a4] 6e0e                      bgt.s     $000122B4
[000122a6] 548b                      addq.l    #2,a3
[000122a8] b85b                      cmp.w     (a3)+,d4
[000122aa] 6608                      bne.s     $000122B4
[000122ac] 5243                      addq.w    #1,d3
[000122ae] b642                      cmp.w     d2,d3
[000122b0] 6df6                      blt.s     $000122A8
[000122b2] 3602                      move.w    d2,d3
[000122b4] 3283                      move.w    d3,(a1)
[000122b6] 4842                      swap      d2
[000122b8] 4843                      swap      d3
[000122ba] 264c                      movea.l   a4,a3
[000122bc] b642                      cmp.w     d2,d3
[000122be] 6f0e                      ble.s     $000122CE
[000122c0] 3003                      move.w    d3,d0
[000122c2] b863                      cmp.w     -(a3),d4
[000122c4] 6608                      bne.s     $000122CE
[000122c6] 5343                      subq.w    #1,d3
[000122c8] b642                      cmp.w     d2,d3
[000122ca] 6ef6                      bgt.s     $000122C2
[000122cc] 3602                      move.w    d2,d3
[000122ce] 3083                      move.w    d3,(a0)
[000122d0] 3015                      move.w    (a5),d0
[000122d2] b86d 0004                 cmp.w     4(a5),d4
[000122d6] 6704                      beq.s     $000122DC
[000122d8] 0a40 0001                 eori.w    #$0001,d0
[000122dc] 4e75                      rts

data:
[000122de]                           dc.w $0acc
[000122e0]                           dc.w $0024
[000122e2]                           dc.w $0014
[000122e4]                           dc.w $005a
[000122e6]                           dc.w $00a6
[000122e8]                           dc.w $0208
[000122ea]                           dc.w $022e
[000122ec]                           dc.w $01b8
[000122ee]                           dc.w $108a
[000122f0]                           dc.w $0000
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
; $0000054e
; $000005a2
; $00000644
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
; $000007c2
; $0000085c
; $00000860
; $00000864
; $00000868
; $00000966
; $00000a64
; $00000b62
; $00000c60
; $00000d5e
; $00000e5c
; $00000f5a
; $00001058
; $00001156
; $00001254
; $00001352
; $0000135c
; $00001360
; $00001364
; $00001368
; $0000136c
; $00001370
; $00001374
; $00001378
; $0000137c
; $00001380
; $00001384
; $00001388
; $0000138c
; $00001390
; $00001394
; $00001398
; $0000139c
; $000013a0
; $000013a4
; $000013a8
; $000013ac
; $000013b0
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
; $000014d6
; $000015d4
; $000015e2
; $000015e6
; $000015ea
; $000015ee
; $000015f2
; $000015f6
; $000015fa
; $000015fe
; $00001602
; $00001606
; $0000160a
; $0000160e
; $00001612
; $00001616
; $0000161a
; $0000161e
; $00001622
; $00001626
; $0000162a
; $0000162e
; $00001632
; $00001636
; $0000163a
; $0000163e
; $00001642
; $00001646
; $0000164a
; $0000164e
; $00001652
; $00001656
; $0000165a
; $0000165e
