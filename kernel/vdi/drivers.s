; ph_branch = 0x601a
; ph_tlen = 0x000006b0
; ph_dlen = 0x00000024
; ph_blen = 0x00000000
; ph_slen = 0x00000230
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000000
; ph_absflag = 0x0000
; CP/M relocation bytes = 0x000006d4

init_NOD:
[00000000] 2f0a                      move.l    a2,-(a7)
[00000002] 4fef ff00                 lea.l     -256(a7),a7
[00000006] 4279 0000 0000            clr.w     OSC_coun
[0000000c] 42b9 0000 0000            clr.l     OSC_ptr
[00000012] 45f9 0000 0000            lea.l     gdos_pat,a2
[00000018] 224a                      movea.l   a2,a1
[0000001a] 41d7                      lea.l     (a7),a0
[0000001c] 4eb9 0000 0000            jsr       strgcpy
[00000022] 43f9 0000 0010            lea.l     $00000010,a1
[00000028] 41d7                      lea.l     (a7),a0
[0000002a] 4eb9 0000 0000            jsr       strgcat
[00000030] 41d7                      lea.l     (a7),a0
[00000032] 4eb9 0000 0078            jsr       init_off
[00000038] 224a                      movea.l   a2,a1
[0000003a] 41d7                      lea.l     (a7),a0
[0000003c] 4eb9 0000 0000            jsr       strgcpy
[00000042] 43f9 0000 0016            lea.l     $00000016,a1
[00000048] 41d7                      lea.l     (a7),a0
[0000004a] 4eb9 0000 0000            jsr       strgcat
[00000050] 41d7                      lea.l     (a7),a0
[00000052] 4eb9 0000 0078            jsr       init_off
[00000058] 4eb9 0000 0164            jsr       load_mon
[0000005e] 4a40                      tst.w     d0
[00000060] 6708                      beq.s     $0000006A
[00000062] 3039 0000 0000            move.w    OSC_coun,d0
[00000068] 6604                      bne.s     $0000006E
[0000006a] 4240                      clr.w     d0
[0000006c] 6002                      bra.s     $00000070
[0000006e] 7001                      moveq.l   #1,d0
[00000070] 4fef 0100                 lea.l     256(a7),a7
[00000074] 245f                      movea.l   (a7)+,a2
[00000076] 4e75                      rts
init_off:
[00000078] 48e7 003e                 movem.l   a2-a6,-(a7)
[0000007c] 4fef fe80                 lea.l     -384(a7),a7
[00000080] 2848                      movea.l   a0,a4
[00000082] 4eb9 0000 0000            jsr       Fgetdta
[00000088] 2e88                      move.l    a0,(a7)
[0000008a] 47ef 0004                 lea.l     4(a7),a3
[0000008e] 204b                      movea.l   a3,a0
[00000090] 4eb9 0000 0000            jsr       Fsetdta
[00000096] 4240                      clr.w     d0
[00000098] 204c                      movea.l   a4,a0
[0000009a] 4eb9 0000 0000            jsr       Fsfirst
[000000a0] 4a40                      tst.w     d0
[000000a2] 6600 00ac                 bne       $00000150
[000000a6] 4def 0030                 lea.l     48(a7),a6
[000000aa] 4bef 0080                 lea.l     128(a7),a5
[000000ae] 49f9 0000 0000            lea.l     gdos_pat,a4
[000000b4] 224c                      movea.l   a4,a1
[000000b6] 204d                      movea.l   a5,a0
[000000b8] 4eb9 0000 0000            jsr       strgcpy
[000000be] 43eb 001e                 lea.l     30(a3),a1
[000000c2] 204d                      movea.l   a5,a0
[000000c4] 4eb9 0000 0000            jsr       strgcat
[000000ca] 7250                      moveq.l   #80,d1
[000000cc] 701c                      moveq.l   #28,d0
[000000ce] 224e                      movea.l   a6,a1
[000000d0] 204d                      movea.l   a5,a0
[000000d2] 4eb9 0000 0000            jsr       read_fil
[000000d8] 43f9 0000 001c            lea.l     $0000001C,a1
[000000de] 41ee 0002                 lea.l     2(a6),a0
[000000e2] 4eb9 0000 0000            jsr       strgcmp
[000000e8] 4a40                      tst.w     d0
[000000ea] 6658                      bne.s     $00000144
[000000ec] 0c6e 0280 000a            cmpi.w    #$0280,10(a6)
[000000f2] 6f50                      ble.s     $00000144
[000000f4] 7036                      moveq.l   #54,d0
[000000f6] 4eb9 0000 0000            jsr       Malloc_s
[000000fc] 2448                      movea.l   a0,a2
[000000fe] 200a                      move.l    a2,d0
[00000100] 6742                      beq.s     $00000144
[00000102] 43eb 001e                 lea.l     30(a3),a1
[00000106] 41ea 001e                 lea.l     30(a2),a0
[0000010a] 4eb9 0000 0000            jsr       strgcpy
[00000110] 256b 001a 002e            move.l    26(a3),46(a2)
[00000116] 254c 0032                 move.l    a4,50(a2)
[0000011a] 41ee 0040                 lea.l     64(a6),a0
[0000011e] 43ea 000e                 lea.l     14(a2),a1
[00000122] 22d8                      move.l    (a0)+,(a1)+
[00000124] 22d8                      move.l    (a0)+,(a1)+
[00000126] 22d8                      move.l    (a0)+,(a1)+
[00000128] 22d8                      move.l    (a0)+,(a1)+
[0000012a] 426a 000c                 clr.w     12(a2)
[0000012e] 42aa 0004                 clr.l     4(a2)
[00000132] 24b9 0000 0000            move.l    OSC_ptr,(a2)
[00000138] 23ca 0000 0000            move.l    a2,OSC_ptr
[0000013e] 5279 0000 0000            addq.w    #1,OSC_coun
[00000144] 4eb9 0000 0000            jsr       Fsnext
[0000014a] 4a40                      tst.w     d0
[0000014c] 6700 ff58                 beq       $000000A6
[00000150] 2057                      movea.l   (a7),a0
[00000152] 4eb9 0000 0000            jsr       Fsetdta
[00000158] 7001                      moveq.l   #1,d0
[0000015a] 4fef 0180                 lea.l     384(a7),a7
[0000015e] 4cdf 7c00                 movem.l   (a7)+,a2-a6
[00000162] 4e75                      rts
load_mon:
[00000164] 2f0a                      move.l    a2,-(a7)
[00000166] 4fef fff0                 lea.l     -16(a7),a7
[0000016a] 41f9 0000 0000            lea.l     init_NOD,a0
[00000170] 43d7                      lea.l     (a7),a1
[00000172] 22d8                      move.l    (a0)+,(a1)+
[00000174] 22d8                      move.l    (a0)+,(a1)+
[00000176] 22d8                      move.l    (a0)+,(a1)+
[00000178] 22d8                      move.l    (a0)+,(a1)+
[0000017a] 41d7                      lea.l     (a7),a0
[0000017c] 4eb9 0000 01a0            jsr       load_NOD
[00000182] 2448                      movea.l   a0,a2
[00000184] 200a                      move.l    a2,d0
[00000186] 670e                      beq.s     $00000196
[00000188] 206a 0004                 movea.l   4(a2),a0
[0000018c] 4eb9 0000 0000            jsr       init_mon
[00000192] 7001                      moveq.l   #1,d0
[00000194] 6002                      bra.s     $00000198
[00000196] 4240                      clr.w     d0
[00000198] 4fef 0010                 lea.l     16(a7),a7
[0000019c] 245f                      movea.l   (a7)+,a2
[0000019e] 4e75                      rts
load_NOD:
[000001a0] 2f0a                      move.l    a2,-(a7)
[000001a2] 2f0b                      move.l    a3,-(a7)
[000001a4] 4fef ff00                 lea.l     -256(a7),a7
[000001a8] 2648                      movea.l   a0,a3
[000001aa] 2479 0000 0000            movea.l   OSC_ptr,a2
[000001b0] 6000 0080                 bra       $00000232
[000001b4] 202a 000e                 move.l    14(a2),d0
[000001b8] b093                      cmp.l     (a3),d0
[000001ba] 6600 0074                 bne.w     $00000230
[000001be] 322a 0012                 move.w    18(a2),d1
[000001c2] b26b 0004                 cmp.w     4(a3),d1
[000001c6] 6668                      bne.s     $00000230
[000001c8] 342a 0014                 move.w    20(a2),d2
[000001cc] b46b 0006                 cmp.w     6(a3),d2
[000001d0] 665e                      bne.s     $00000230
[000001d2] 302a 0016                 move.w    22(a2),d0
[000001d6] c06b 0008                 and.w     8(a3),d0
[000001da] b06b 0008                 cmp.w     8(a3),d0
[000001de] 6650                      bne.s     $00000230
[000001e0] 222a 0004                 move.l    4(a2),d1
[000001e4] 6624                      bne.s     $0000020A
[000001e6] 226a 0032                 movea.l   50(a2),a1
[000001ea] 41d7                      lea.l     (a7),a0
[000001ec] 4eb9 0000 0000            jsr       strgcpy
[000001f2] 43ea 001e                 lea.l     30(a2),a1
[000001f6] 41d7                      lea.l     (a7),a0
[000001f8] 4eb9 0000 0000            jsr       strgcat
[000001fe] 41d7                      lea.l     (a7),a0
[00000200] 4eb9 0000 0266            jsr       load_prg
[00000206] 2548 0004                 move.l    a0,4(a2)
[0000020a] 202a 0004                 move.l    4(a2),d0
[0000020e] 6720                      beq.s     $00000230
[00000210] 322a 000c                 move.w    12(a2),d1
[00000214] 6612                      bne.s     $00000228
[00000216] 41f9 0000 0000            lea.l     nvdi_str,a0
[0000021c] 2240                      movea.l   d0,a1
[0000021e] 2269 0010                 movea.l   16(a1),a1
[00000222] 4e91                      jsr       (a1)
[00000224] 2540 0008                 move.l    d0,8(a2)
[00000228] 526a 000c                 addq.w    #1,12(a2)
[0000022c] 204a                      movea.l   a2,a0
[0000022e] 600a                      bra.s     $0000023A
[00000230] 2452                      movea.l   (a2),a2
[00000232] 200a                      move.l    a2,d0
[00000234] 6600 ff7e                 bne       $000001B4
[00000238] 91c8                      suba.l    a0,a0
[0000023a] 4fef 0100                 lea.l     256(a7),a7
[0000023e] 265f                      movea.l   (a7)+,a3
[00000240] 245f                      movea.l   (a7)+,a2
[00000242] 4e75                      rts
unload_N:
[00000244] 2f0a                      move.l    a2,-(a7)
[00000246] 2448                      movea.l   a0,a2
[00000248] 536a 000c                 subq.w    #1,12(a2)
[0000024c] 302a 000c                 move.w    12(a2),d0
[00000250] 660e                      bne.s     $00000260
[00000252] 206a 0004                 movea.l   4(a2),a0
[00000256] 4eb9 0000 0000            jsr       Mfree_sy
[0000025c] 42aa 0004                 clr.l     4(a2)
[00000260] 7001                      moveq.l   #1,d0
[00000262] 245f                      movea.l   (a7)+,a2
[00000264] 4e75                      rts
load_prg:
[00000266] 48e7 1c3c                 movem.l   d3-d5/a2-a5,-(a7)
[0000026a] 4fef ffb8                 lea.l     -72(a7),a7
[0000026e] 2848                      movea.l   a0,a4
[00000270] 95ca                      suba.l    a2,a2
[00000272] 4eb9 0000 0000            jsr       Fgetdta
[00000278] 2648                      movea.l   a0,a3
[0000027a] 41d7                      lea.l     (a7),a0
[0000027c] 4eb9 0000 0000            jsr       Fsetdta
[00000282] 4240                      clr.w     d0
[00000284] 204c                      movea.l   a4,a0
[00000286] 4eb9 0000 0000            jsr       Fsfirst
[0000028c] 4a40                      tst.w     d0
[0000028e] 6600 00f6                 bne       $00000386
[00000292] 4240                      clr.w     d0
[00000294] 204c                      movea.l   a4,a0
[00000296] 4eb9 0000 0000            jsr       Fopen
[0000029c] 2600                      move.l    d0,d3
[0000029e] 4a80                      tst.l     d0
[000002a0] 6f00 00e4                 ble       $00000386
[000002a4] 49ef 002c                 lea.l     44(a7),a4
[000002a8] 204c                      movea.l   a4,a0
[000002aa] 721c                      moveq.l   #28,d1
[000002ac] 3003                      move.w    d3,d0
[000002ae] 4eb9 0000 0000            jsr       Fread
[000002b4] 721c                      moveq.l   #28,d1
[000002b6] b280                      cmp.l     d0,d1
[000002b8] 6600 00c4                 bne       $0000037E
[000002bc] 0c54 601a                 cmpi.w    #$601A,(a4)
[000002c0] 6600 00bc                 bne       $0000037E
[000002c4] 2a2f 001a                 move.l    26(a7),d5
[000002c8] daac 000a                 add.l     10(a4),d5
[000002cc] 9aac 000e                 sub.l     14(a4),d5
[000002d0] 2005                      move.l    d5,d0
[000002d2] 4eb9 0000 0000            jsr       Malloc_s
[000002d8] 2448                      movea.l   a0,a2
[000002da] 200a                      move.l    a2,d0
[000002dc] 6700 00a0                 beq       $0000037E
[000002e0] 2a2c 0002                 move.l    2(a4),d5
[000002e4] daac 0006                 add.l     6(a4),d5
[000002e8] 2805                      move.l    d5,d4
[000002ea] d8ac 000a                 add.l     10(a4),d4
[000002ee] 2205                      move.l    d5,d1
[000002f0] 3003                      move.w    d3,d0
[000002f2] 4eb9 0000 0000            jsr       Fread
[000002f8] ba80                      cmp.l     d0,d5
[000002fa] 6600 0078                 bne.w     $00000374
[000002fe] 7401                      moveq.l   #1,d2
[00000300] 3203                      move.w    d3,d1
[00000302] 202c 000e                 move.l    14(a4),d0
[00000306] 4eb9 0000 0000            jsr       Fseek
[0000030c] 41f2 5800                 lea.l     0(a2,d5.l),a0
[00000310] 202c 000a                 move.l    10(a4),d0
[00000314] 4eb9 0000 0000            jsr       clear_me
[0000031a] 4bf2 4800                 lea.l     0(a2,d4.l),a5
[0000031e] 7ae4                      moveq.l   #-28,d5
[00000320] daaf 001a                 add.l     26(a7),d5
[00000324] 9aac 0002                 sub.l     2(a4),d5
[00000328] 9aac 0006                 sub.l     6(a4),d5
[0000032c] 9aac 000e                 sub.l     14(a4),d5
[00000330] 204d                      movea.l   a5,a0
[00000332] 2205                      move.l    d5,d1
[00000334] 3003                      move.w    d3,d0
[00000336] 4eb9 0000 0000            jsr       Fread
[0000033c] ba80                      cmp.l     d0,d5
[0000033e] 6634                      bne.s     $00000374
[00000340] 2015                      move.l    (a5),d0
[00000342] 584d                      addq.w    #4,a5
[00000344] 4a80                      tst.l     d0
[00000346] 6720                      beq.s     $00000368
[00000348] 41f2 0800                 lea.l     0(a2,d0.l),a0
[0000034c] 6012                      bra.s     $00000360
[0000034e] b03c 0001                 cmp.b     #$01,d0
[00000352] 6606                      bne.s     $0000035A
[00000354] 41e8 00fe                 lea.l     254(a0),a0
[00000358] 600a                      bra.s     $00000364
[0000035a] 7200                      moveq.l   #0,d1
[0000035c] 1200                      move.b    d0,d1
[0000035e] d1c1                      adda.l    d1,a0
[00000360] 220a                      move.l    a2,d1
[00000362] d390                      add.l     d1,(a0)
[00000364] 101d                      move.b    (a5)+,d0
[00000366] 66e6                      bne.s     $0000034E
[00000368] 2004                      move.l    d4,d0
[0000036a] 204a                      movea.l   a2,a0
[0000036c] 4eb9 0000 0000            jsr       Mshrink_
[00000372] 600a                      bra.s     $0000037E
[00000374] 204a                      movea.l   a2,a0
[00000376] 4eb9 0000 0000            jsr       Mfree_sy
[0000037c] 95ca                      suba.l    a2,a2
[0000037e] 3003                      move.w    d3,d0
[00000380] 4eb9 0000 0000            jsr       Fclose
[00000386] 204b                      movea.l   a3,a0
[00000388] 4eb9 0000 0000            jsr       Fsetdta
[0000038e] 200a                      move.l    a2,d0
[00000390] 6706                      beq.s     $00000398
[00000392] 4eb9 0000 0000            jsr       clear_cp
[00000398] 204a                      movea.l   a2,a0
[0000039a] 4fef 0048                 lea.l     72(a7),a7
[0000039e] 4cdf 3c38                 movem.l   (a7)+,d3-d5/a2-a5
[000003a2] 4e75                      rts
create_b:
[000003a4] 48e7 003c                 movem.l   a2-a5,-(a7)
[000003a8] 4fef ffd4                 lea.l     -44(a7),a7
[000003ac] 2f49 0014                 move.l    a1,20(a7)
[000003b0] 2a6f 0040                 movea.l   64(a7),a5
[000003b4] 266f 0044                 movea.l   68(a7),a3
[000003b8] 95ca                      suba.l    a2,a2
[000003ba] 2eab 001e                 move.l    30(a3),(a7)
[000003be] 3f6b 0022 0004            move.w    34(a3),4(a7)
[000003c4] 3f6b 0024 0006            move.w    36(a3),6(a7)
[000003ca] 3f6b 0026 0008            move.w    38(a3),8(a7)
[000003d0] 426f 000a                 clr.w     10(a7)
[000003d4] 426f 000c                 clr.w     12(a7)
[000003d8] 426f 000e                 clr.w     14(a7)
[000003dc] 2017                      move.l    (a7),d0
[000003de] 662a                      bne.s     $0000040A
[000003e0] 322d 000c                 move.w    12(a5),d1
[000003e4] 670a                      beq.s     $000003F0
[000003e6] 2268 000c                 movea.l   12(a0),a1
[000003ea] b269 0044                 cmp.w     68(a1),d1
[000003ee] 6614                      bne.s     $00000404
[000003f0] 2268 000c                 movea.l   12(a0),a1
[000003f4] 43e9 0040                 lea.l     64(a1),a1
[000003f8] 49d7                      lea.l     (a7),a4
[000003fa] 28d9                      move.l    (a1)+,(a4)+
[000003fc] 28d9                      move.l    (a1)+,(a4)+
[000003fe] 28d9                      move.l    (a1)+,(a4)+
[00000400] 28d9                      move.l    (a1)+,(a4)+
[00000402] 6006                      bra.s     $0000040A
[00000404] 3f7c 0001 0004            move.w    #$0001,4(a7)
[0000040a] 0c6f 0001 0004            cmpi.w    #$0001,4(a7)
[00000410] 6612                      bne.s     $00000424
[00000412] 2ebc 0000 0002            move.l    #$00000002,(a7)
[00000418] 3f7c 0002 0006            move.w    #$0002,6(a7)
[0000041e] 3f7c 0001 0008            move.w    #$0001,8(a7)
[00000424] 41d7                      lea.l     (a7),a0
[00000426] 6100 fd78                 bsr       load_NOD
[0000042a] 2f48 0010                 move.l    a0,16(a7)
[0000042e] 2008                      move.l    a0,d0
[00000430] 6700 01be                 beq       $000005F0
[00000434] 2028 0008                 move.l    8(a0),d0
[00000438] 4eb9 0000 062a            jsr       create_w
[0000043e] 2448                      movea.l   a0,a2
[00000440] 200a                      move.l    a2,d0
[00000442] 6700 01ac                 beq       $000005F0
[00000446] 43d7                      lea.l     (a7),a1
[00000448] 49ea 019a                 lea.l     410(a2),a4
[0000044c] 28d9                      move.l    (a1)+,(a4)+
[0000044e] 28d9                      move.l    (a1)+,(a4)+
[00000450] 28d9                      move.l    (a1)+,(a4)+
[00000452] 28d9                      move.l    (a1)+,(a4)+
[00000454] 2f00                      move.l    d0,-(a7)
[00000456] 226f 0014                 movea.l   20(a7),a1
[0000045a] 91c8                      suba.l    a0,a0
[0000045c] 4eb9 0000 0000            jsr       wk_init
[00000462] 584f                      addq.w    #4,a7
[00000464] 302b 0016                 move.w    22(a3),d0
[00000468] 670c                      beq.s     $00000476
[0000046a] 3540 0010                 move.w    d0,16(a2)
[0000046e] 356b 0018 0012            move.w    24(a3),18(a2)
[00000474] 6010                      bra.s     $00000486
[00000476] 206f 0014                 movea.l   20(a7),a0
[0000047a] 3568 0010 0010            move.w    16(a0),16(a2)
[00000480] 3568 0012 0012            move.w    18(a0),18(a2)
[00000486] 302b 001a                 move.w    26(a3),d0
[0000048a] 670c                      beq.s     $00000498
[0000048c] 3540 000c                 move.w    d0,12(a2)
[00000490] 356b 001c 000e            move.w    28(a3),14(a2)
[00000496] 6010                      bra.s     $000004A8
[00000498] 206f 0014                 movea.l   20(a7),a0
[0000049c] 3568 000c 000c            move.w    12(a0),12(a2)
[000004a2] 3568 000e 000e            move.w    14(a0),14(a2)
[000004a8] 7010                      moveq.l   #16,d0
[000004aa] d06a 0010                 add.w     16(a2),d0
[000004ae] c07c fff0                 and.w     #$FFF0,d0
[000004b2] 5340                      subq.w    #1,d0
[000004b4] 3540 01ba                 move.w    d0,442(a2)
[000004b8] 356a 0012 01bc            move.w    18(a2),444(a2)
[000004be] 356a 0010 0038            move.w    16(a2),56(a2)
[000004c4] 356a 0012 003a            move.w    18(a2),58(a2)
[000004ca] 7001                      moveq.l   #1,d0
[000004cc] d06a 0010                 add.w     16(a2),d0
[000004d0] 48c0                      ext.l     d0
[000004d2] 7201                      moveq.l   #1,d1
[000004d4] d26a 01b4                 add.w     436(a2),d1
[000004d8] 48c1                      ext.l     d1
[000004da] 4eb9 0000 0000            jsr       _lmul
[000004e0] 7208                      moveq.l   #8,d1
[000004e2] 4eb9 0000 0000            jsr       _ldiv
[000004e8] 3540 01b2                 move.w    d0,434(a2)
[000004ec] 48c0                      ext.l     d0
[000004ee] 7201                      moveq.l   #1,d1
[000004f0] d26a 0012                 add.w     18(a2),d1
[000004f4] 48c1                      ext.l     d1
[000004f6] 4eb9 0000 0000            jsr       _lmul
[000004fc] 2540 01be                 move.l    d0,446(a2)
[00000500] 256f 0010 0194            move.l    16(a7),404(a2)
[00000506] 2015                      move.l    (a5),d0
[00000508] 6674                      bne.s     $0000057E
[0000050a] 7201                      moveq.l   #1,d1
[0000050c] d26a 0010                 add.w     16(a2),d1
[00000510] 3b41 0004                 move.w    d1,4(a5)
[00000514] 7001                      moveq.l   #1,d0
[00000516] d06a 0012                 add.w     18(a2),d0
[0000051a] 3b40 0006                 move.w    d0,6(a5)
[0000051e] 7201                      moveq.l   #1,d1
[00000520] d26a 01b4                 add.w     436(a2),d1
[00000524] 3b41 000c                 move.w    d1,12(a5)
[00000528] 426d 000a                 clr.w     10(a5)
[0000052c] 302a 01b2                 move.w    434(a2),d0
[00000530] 48c0                      ext.l     d0
[00000532] 7201                      moveq.l   #1,d1
[00000534] d26a 01b4                 add.w     436(a2),d1
[00000538] 81c1                      divs.w    d1,d0
[0000053a] 48c0                      ext.l     d0
[0000053c] 81fc 0002                 divs.w    #$0002,d0
[00000540] 3b40 0008                 move.w    d0,8(a5)
[00000544] 202a 01be                 move.l    446(a2),d0
[00000548] 4eb9 0000 0000            jsr       Malloc_s
[0000054e] 2a88                      move.l    a0,(a5)
[00000550] 2548 01ae                 move.l    a0,430(a2)
[00000554] 2015                      move.l    (a5),d0
[00000556] 6712                      beq.s     $0000056A
[00000558] 006a 8000 01a2            ori.w     #$8000,418(a2)
[0000055e] 204a                      movea.l   a2,a0
[00000560] 4eb9 0000 0000            jsr       clear_bi
[00000566] 6000 0088                 bra       $000005F0
[0000056a] 206f 0010                 movea.l   16(a7),a0
[0000056e] 6100 fcd4                 bsr       unload_N
[00000572] 204a                      movea.l   a2,a0
[00000574] 4eb9 0000 0680            jsr       delete_w
[0000057a] 91c8                      suba.l    a0,a0
[0000057c] 6074                      bra.s     $000005F2
[0000057e] 2555 01ae                 move.l    (a5),430(a2)
[00000582] 302d 0008                 move.w    8(a5),d0
[00000586] d040                      add.w     d0,d0
[00000588] c1ed 000c                 muls.w    12(a5),d0
[0000058c] 3540 01b2                 move.w    d0,434(a2)
[00000590] 322d 000a                 move.w    10(a5),d1
[00000594] 675a                      beq.s     $000005F0
[00000596] 204d                      movea.l   a5,a0
[00000598] 43ef 0018                 lea.l     24(a7),a1
[0000059c] 7404                      moveq.l   #4,d2
[0000059e] 22d8                      move.l    (a0)+,(a1)+
[000005a0] 51ca fffc                 dbf       d2,$0000059E
[000005a4] 426f 0022                 clr.w     34(a7)
[000005a8] 202a 01be                 move.l    446(a2),d0
[000005ac] 4eb9 0000 0000            jsr       Malloc_s
[000005b2] 2f48 0018                 move.l    a0,24(a7)
[000005b6] 2008                      move.l    a0,d0
[000005b8] 6722                      beq.s     $000005DC
[000005ba] 2f0a                      move.l    a2,-(a7)
[000005bc] 43ef 001c                 lea.l     28(a7),a1
[000005c0] 204d                      movea.l   a5,a0
[000005c2] 4eb9 0000 0000            jsr       transfor
[000005c8] 584f                      addq.w    #4,a7
[000005ca] 2255                      movea.l   (a5),a1
[000005cc] 206f 0018                 movea.l   24(a7),a0
[000005d0] 202a 01be                 move.l    446(a2),d0
[000005d4] 4eb9 0000 0000            jsr       copy_mem
[000005da] 6014                      bra.s     $000005F0
[000005dc] 2f55 0018                 move.l    (a5),24(a7)
[000005e0] 2f0a                      move.l    a2,-(a7)
[000005e2] 43ef 001c                 lea.l     28(a7),a1
[000005e6] 204d                      movea.l   a5,a0
[000005e8] 4eb9 0000 0000            jsr       transfor
[000005ee] 584f                      addq.w    #4,a7
[000005f0] 204a                      movea.l   a2,a0
[000005f2] 4fef 002c                 lea.l     44(a7),a7
[000005f6] 4cdf 3c00                 movem.l   (a7)+,a2-a5
[000005fa] 4e75                      rts
delete_b:
[000005fc] 2f0a                      move.l    a2,-(a7)
[000005fe] 2448                      movea.l   a0,a2
[00000600] 206a 0194                 movea.l   404(a2),a0
[00000604] 6100 fc3e                 bsr       unload_N
[00000608] 302a 01a2                 move.w    418(a2),d0
[0000060c] c07c 8000                 and.w     #$8000,d0
[00000610] 670a                      beq.s     $0000061C
[00000612] 206a 01ae                 movea.l   430(a2),a0
[00000616] 4eb9 0000 0000            jsr       Mfree_sy
[0000061c] 204a                      movea.l   a2,a0
[0000061e] 4eb9 0000 0680            jsr       delete_w
[00000624] 7001                      moveq.l   #1,d0
[00000626] 245f                      movea.l   (a7)+,a2
[00000628] 4e75                      rts
create_w:
[0000062a] 48e7 1830                 movem.l   d3-d4/a2-a3,-(a7)
[0000062e] 2800                      move.l    d0,d4
[00000630] 95ca                      suba.l    a2,a2
[00000632] 7602                      moveq.l   #2,d3
[00000634] 47f9 0000 0000            lea.l     wk_tab,a3
[0000063a] 6036                      bra.s     $00000672
[0000063c] 3003                      move.w    d3,d0
[0000063e] e548                      lsl.w     #2,d0
[00000640] 2073 00fc                 movea.l   -4(a3,d0.w),a0
[00000644] b1fc 0000 0000            cmpa.l    #closed,a0
[0000064a] 6624                      bne.s     $00000670
[0000064c] 2004                      move.l    d4,d0
[0000064e] 4eb9 0000 0000            jsr       Malloc_s
[00000654] 2448                      movea.l   a0,a2
[00000656] 200a                      move.l    a2,d0
[00000658] 671e                      beq.s     $00000678
[0000065a] 2004                      move.l    d4,d0
[0000065c] 4eb9 0000 0000            jsr       clear_me
[00000662] 3543 0008                 move.w    d3,8(a2)
[00000666] 3003                      move.w    d3,d0
[00000668] e548                      lsl.w     #2,d0
[0000066a] 278a 00fc                 move.l    a2,-4(a3,d0.w)
[0000066e] 6008                      bra.s     $00000678
[00000670] 5243                      addq.w    #1,d3
[00000672] b67c 0080                 cmp.w     #$0080,d3
[00000676] 6fc4                      ble.s     $0000063C
[00000678] 204a                      movea.l   a2,a0
[0000067a] 4cdf 0c18                 movem.l   (a7)+,d3-d4/a2-a3
[0000067e] 4e75                      rts
delete_w:
[00000680] 2f0a                      move.l    a2,-(a7)
[00000682] 2448                      movea.l   a0,a2
[00000684] 41f9 0000 0000            lea.l     wk_tab,a0
[0000068a] 302a 0008                 move.w    8(a2),d0
[0000068e] e548                      lsl.w     #2,d0
[00000690] b5f0 00fc                 cmpa.l    -4(a0,d0.w),a2
[00000694] 6614                      bne.s     $000006AA
[00000696] 21bc 0000 0000 00fc       move.l    #closed,-4(a0,d0.w)
[0000069e] 204a                      movea.l   a2,a0
[000006a0] 4eb9 0000 0000            jsr       Mfree_sy
[000006a6] 7001                      moveq.l   #1,d0
[000006a8] 6002                      bra.s     $000006AC
[000006aa] 4240                      clr.w     d0
[000006ac] 245f                      movea.l   (a7)+,a2
[000006ae] 4e75                      rts

data:
[000006b0]                           dc.w $0000
[000006b2]                           dc.w $0002
[000006b4]                           dc.w $0001
[000006b6]                           dc.w $0002
[000006b8]                           dc.w $0001
[000006ba]                           dc.w $0000
[000006bc]                           dc.w $0000
[000006be]                           dc.w $0000
[000006c0]                           dc.b '*.NOD',0
[000006c6]                           dc.b '*.OSD',0
[000006cc]                           dc.b 'OFFSCRN',0
;
         U OSC_coun
         U Mfree_sy
         U Fsetdta
         U Fgetdta
         U Fopen
         U clear_me
         U Fclose
         U closed
         U _lmul
         U clear_cp
         U wk_tab
         U Fseek
         U strgcpy
         U transfor
         U gdos_pat
         U clear_bi
         U read_fil
         U copy_mem
         U wk_init
         U strgcat
         U nvdi_str
         U init_mon
         U Fread
         U Fsfirst
         U Mshrink_
         U OSC_ptr
         U strgcmp
         U Fsnext
         U Malloc_s
         U _ldiv
00000000 T init_NOD
00000078 T init_off
00000164 T load_mon
000001a0 T load_NOD
00000244 T unload_N
00000266 T load_prg
000003a4 T create_b
000005fc T delete_b
0000062a T create_w
00000680 T delete_w
;
; CP/M Relocations:
; $00000024 data
; $00000034 text
; $00000044 data
; $00000054 text
; $0000005a text
; $000000da data
; $0000016c data
; $0000017e text
; $00000202 text
; $0000043a text
; $00000576 text
; $00000620 text
