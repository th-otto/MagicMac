
xfs2:
[000102c6] 4e56 0000                 link       a6,#0
[000102ca] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[000102ce] 33fc 0001 0001 2b58       move.w     #$0001,cont_parse
[000102d6] 4279 0001 2b5a            clr.w      vt52_err
[000102dc] 41ee 0008                 lea.l      8(a6),a0
[000102e0] 23c8 0001 2b5c            move.l     a0,args
[000102e6] 58b9 0001 2b5c            addq.l     #4,args
[000102ec] 2a6e 0008                 movea.l    8(a6),a5
[000102f0] 284d                      movea.l    a5,a4
[000102f2] 6002                      bra.s      $000102F6
[000102f4] 528c                      addq.l     #1,a4
[000102f6] 4a14                      tst.b      (a4)
[000102f8] 66fa                      bne.s      $000102F4
[000102fa] 2e8c                      move.l     a4,(a7)
[000102fc] 2f0d                      move.l     a5,-(a7)
[000102fe] 611e                      bsr.s      doprt
[00010300] 588f                      addq.l     #4,a7
[00010302] 4a79 0001 2b5a            tst.w      vt52_err
[00010308] 6704                      beq.s      $0001030E
[0001030a] 6100 162c                 bsr        printerr
[0001030e] 3039 0001 2b5a            move.w     vt52_err,d0
[00010314] 4a9f                      tst.l      (a7)+
[00010316] 4cdf 3000                 movem.l    (a7)+,a4-a5
[0001031a] 4e5e                      unlk       a6
[0001031c] 4e75                      rts
doprt:
[0001031e] 4e56 fff0                 link       a6,#-16
[00010322] 6000 009a                 bra        $000103BE
[00010326] 2e8e                      move.l     a6,(a7)
[00010328] 0697 ffff fff4            addi.l     #$FFFFFFF4,(a7)
[0001032e] 2f0e                      move.l     a6,-(a7)
[00010330] 5197                      subq.l     #8,(a7)
[00010332] 2f0e                      move.l     a6,-(a7)
[00010334] 5997                      subq.l     #4,(a7)
[00010336] 2f0e                      move.l     a6,-(a7)
[00010338] 0697 0000 000c            addi.l     #$0000000C,(a7)
[0001033e] 2f0e                      move.l     a6,-(a7)
[00010340] 5097                      addq.l     #8,(a7)
[00010342] 6100 01aa                 bsr        $000104EE
[00010346] dffc 0000 0010            adda.l     #$00000010,a7
[0001034c] 3d40 fff6                 move.w     d0,-10(a6)
[00010350] 4a6e fff6                 tst.w      -10(a6)
[00010354] 6c10                      bge.s      $00010366
[00010356] 4279 0001 2b58            clr.w      cont_parse
[0001035c] 33ee fff6 0001 2b5a       move.w     -10(a6),vt52_err
[00010364] 6058                      bra.s      $000103BE
[00010366] 202e fffc                 move.l     -4(a6),d0
[0001036a] b0ae fff8                 cmp.l      -8(a6),d0
[0001036e] 6c4e                      bge.s      $000103BE
[00010370] 4a6e fff6                 tst.w      -10(a6)
[00010374] 6f24                      ble.s      $0001039A
[00010376] 600c                      bra.s      $00010384
[00010378] 2eae fff8                 move.l     -8(a6),(a7)
[0001037c] 2f2e fffc                 move.l     -4(a6),-(a7)
[00010380] 619c                      bsr.s      doprt
[00010382] 588f                      addq.l     #4,a7
[00010384] 302e fff4                 move.w     -12(a6),d0
[00010388] 536e fff4                 subq.w     #1,-12(a6)
[0001038c] 4a40                      tst.w      d0
[0001038e] 6708                      beq.s      $00010398
[00010390] 4a79 0001 2b58            tst.w      cont_parse
[00010396] 66e0                      bne.s      $00010378
[00010398] 6024                      bra.s      $000103BE
[0001039a] 600e                      bra.s      $000103AA
[0001039c] 2eae fff8                 move.l     -8(a6),(a7)
[000103a0] 2f2e fffc                 move.l     -4(a6),-(a7)
[000103a4] 6100 032e                 bsr        $000106D4
[000103a8] 588f                      addq.l     #4,a7
[000103aa] 302e fff4                 move.w     -12(a6),d0
[000103ae] 536e fff4                 subq.w     #1,-12(a6)
[000103b2] 4a40                      tst.w      d0
[000103b4] 6708                      beq.s      $000103BE
[000103b6] 4a79 0001 2b58            tst.w      cont_parse
[000103bc] 66de                      bne.s      $0001039C
[000103be] 202e 0008                 move.l     8(a6),d0
[000103c2] b0ae 000c                 cmp.l      12(a6),d0
[000103c6] 6c0a                      bge.s      $000103D2
[000103c8] 4a79 0001 2b58            tst.w      cont_parse
[000103ce] 6600 ff56                 bne        $00010326
[000103d2] 4e5e                      unlk       a6
[000103d4] 4e75                      rts
vt52_scanf:
[000103d6] 4e56 0000                 link       a6,#0
[000103da] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[000103de] 33fc 0001 0001 2b58       move.w     #$0001,cont_parse
[000103e6] 4279 0001 2b5a            clr.w      vt52_err
[000103ec] 33fc ffff 0001 28d8       move.w     #$FFFF,$000128D8
[000103f4] 41ee 0008                 lea.l      8(a6),a0
[000103f8] 23c8 0001 2b5c            move.l     a0,args
[000103fe] 58b9 0001 2b5c            addq.l     #4,args
[00010404] 2a6e 0008                 movea.l    8(a6),a5
[00010408] 284d                      movea.l    a5,a4
[0001040a] 6002                      bra.s      $0001040E
[0001040c] 528c                      addq.l     #1,a4
[0001040e] 4a14                      tst.b      (a4)
[00010410] 66fa                      bne.s      $0001040C
[00010412] 2e8c                      move.l     a4,(a7)
[00010414] 2f0d                      move.l     a5,-(a7)
[00010416] 611e                      bsr.s      doprt2
[00010418] 588f                      addq.l     #4,a7
[0001041a] 4a79 0001 2b5a            tst.w      vt52_err
[00010420] 6704                      beq.s      $00010426
[00010422] 6100 1514                 bsr        printerr
[00010426] 3039 0001 2b5a            move.w     vt52_err,d0
[0001042c] 4a9f                      tst.l      (a7)+
[0001042e] 4cdf 3000                 movem.l    (a7)+,a4-a5
[00010432] 4e5e                      unlk       a6
[00010434] 4e75                      rts
doinp:
[00010436] 4e56 fff0                 link       a6,#-16
[0001043a] 6000 009a                 bra        $000104D6
[0001043e] 2e8e                      move.l     a6,(a7)
[00010440] 0697 ffff fff4            addi.l     #$FFFFFFF4,(a7)
[00010446] 2f0e                      move.l     a6,-(a7)
[00010448] 5197                      subq.l     #8,(a7)
[0001044a] 2f0e                      move.l     a6,-(a7)
[0001044c] 5997                      subq.l     #4,(a7)
[0001044e] 2f0e                      move.l     a6,-(a7)
[00010450] 0697 0000 000c            addi.l     #$0000000C,(a7)
[00010456] 2f0e                      move.l     a6,-(a7)
[00010458] 5097                      addq.l     #8,(a7)
[0001045a] 6100 0092                 bsr        parse_field
[0001045e] dffc 0000 0010            adda.l     #$00000010,a7
[00010464] 3d40 fff6                 move.w     d0,-10(a6)
[00010468] 4a6e fff6                 tst.w      -10(a6)
[0001046c] 6c10                      bge.s      $0001047E
[0001046e] 4279 0001 2b58            clr.w      cont_parse
[00010474] 33ee fff6 0001 2b5a       move.w     -10(a6),vt52_err
[0001047c] 6058                      bra.s      $000104D6
[0001047e] 202e fffc                 move.l     -4(a6),d0
[00010482] b0ae fff8                 cmp.l      -8(a6),d0
[00010486] 6c4e                      bge.s      $000104D6
[00010488] 4a6e fff6                 tst.w      -10(a6)
[0001048c] 6f24                      ble.s      $000104B2
[0001048e] 600c                      bra.s      $0001049C
[00010490] 2eae fff8                 move.l     -8(a6),(a7)
[00010494] 2f2e fffc                 move.l     -4(a6),-(a7)
[00010498] 619c                      bsr.s      doprt2
[0001049a] 588f                      addq.l     #4,a7
[0001049c] 302e fff4                 move.w     -12(a6),d0
[000104a0] 536e fff4                 subq.w     #1,-12(a6)
[000104a4] 4a40                      tst.w      d0
[000104a6] 6708                      beq.s      $000104B0
[000104a8] 4a79 0001 2b58            tst.w      cont_parse
[000104ae] 66e0                      bne.s      $00010490
[000104b0] 6024                      bra.s      $000104D6
[000104b2] 600e                      bra.s      $000104C2
[000104b4] 2eae fff8                 move.l     -8(a6),(a7)
[000104b8] 2f2e fffc                 move.l     -4(a6),-(a7)
[000104bc] 6100 0ffc                 bsr        inp_field
[000104c0] 588f                      addq.l     #4,a7
[000104c2] 302e fff4                 move.w     -12(a6),d0
[000104c6] 536e fff4                 subq.w     #1,-12(a6)
[000104ca] 4a40                      tst.w      d0
[000104cc] 6708                      beq.s      $000104D6
[000104ce] 4a79 0001 2b58            tst.w      cont_parse
[000104d4] 66de                      bne.s      $000104B4
[000104d6] 202e 0008                 move.l     8(a6),d0
[000104da] b0ae 000c                 cmp.l      12(a6),d0
[000104de] 6c0a                      bge.s      $000104EA
[000104e0] 4a79 0001 2b58            tst.w      cont_parse
[000104e6] 6600 ff56                 bne        $0001043E
[000104ea] 4e5e                      unlk       a6
[000104ec] 4e75                      rts
parse_field:
[000104ee] 4e56 fffa                 link       a6,#-6
[000104f2] 48e7 070c                 movem.l    d5-d7/a4-a5,-(a7)
[000104f6] 3d7c 0001 fffe            move.w     #$0001,-2(a6)
[000104fc] 206e 0008                 movea.l    8(a6),a0
[00010500] 2a50                      movea.l    (a0),a5
[00010502] 206e 000c                 movea.l    12(a6),a0
[00010506] 2850                      movea.l    (a0),a4
[00010508] 1e24                      move.b     -(a4),d7
[0001050a] 4887                      ext.w      d7
[0001050c] be7c 0020                 cmp.w      #$0020,d7
[00010510] 67f6                      beq.s      $00010508
[00010512] be7c 002c                 cmp.w      #$002C,d7
[00010516] 67f0                      beq.s      $00010508
[00010518] 528c                      addq.l     #1,a4
[0001051a] 206e 000c                 movea.l    12(a6),a0
[0001051e] 208c                      move.l     a4,(a0)
[00010520] 6002                      bra.s      $00010524
[00010522] 528d                      addq.l     #1,a5
[00010524] 1e15                      move.b     (a5),d7
[00010526] 4887                      ext.w      d7
[00010528] be7c 0020                 cmp.w      #$0020,d7
[0001052c] 67f4                      beq.s      $00010522
[0001052e] be7c 002c                 cmp.w      #$002C,d7
[00010532] 67ee                      beq.s      $00010522
[00010534] bbcc                      cmpa.l     a4,a5
[00010536] 6400 016e                 bcc        $000106A6
[0001053a] be7c 0030                 cmp.w      #$0030,d7
[0001053e] 6d58                      blt.s      $00010598
[00010540] be7c 0039                 cmp.w      #$0039,d7
[00010544] 6e52                      bgt.s      $00010598
[00010546] 426e fffe                 clr.w      -2(a6)
[0001054a] 6016                      bra.s      $00010562
[0001054c] 528d                      addq.l     #1,a5
[0001054e] 3007                      move.w     d7,d0
[00010550] 322e fffe                 move.w     -2(a6),d1
[00010554] c3fc 000a                 muls.w     #$000A,d1
[00010558] d041                      add.w      d1,d0
[0001055a] d07c ffd0                 add.w      #$FFD0,d0
[0001055e] 3d40 fffe                 move.w     d0,-2(a6)
[00010562] 1e15                      move.b     (a5),d7
[00010564] 4887                      ext.w      d7
[00010566] 3007                      move.w     d7,d0
[00010568] b07c 0030                 cmp.w      #$0030,d0
[0001056c] 6d06                      blt.s      $00010574
[0001056e] be7c 0039                 cmp.w      #$0039,d7
[00010572] 6fd8                      ble.s      $0001054C
[00010574] 6006                      bra.s      $0001057C
[00010576] 528d                      addq.l     #1,a5
[00010578] 1e15                      move.b     (a5),d7
[0001057a] 4887                      ext.w      d7
[0001057c] be7c 0020                 cmp.w      #$0020,d7
[00010580] 67f4                      beq.s      $00010576
[00010582] be7c 002c                 cmp.w      #$002C,d7
[00010586] 6606                      bne.s      $0001058E
[00010588] 70fb                      moveq.l    #-5,d0
[0001058a] 6000 013e                 bra        $000106CA
[0001058e] bbcc                      cmpa.l     a4,a5
[00010590] 6506                      bcs.s      $00010598
[00010592] 70fb                      moveq.l    #-5,d0
[00010594] 6000 0134                 bra        $000106CA
[00010598] 206e 0018                 movea.l    24(a6),a0
[0001059c] 30ae fffe                 move.w     -2(a6),(a0)
[000105a0] be7c 0028                 cmp.w      #$0028,d7
[000105a4] 6600 008e                 bne        $00010634
[000105a8] 528d                      addq.l     #1,a5
[000105aa] 7c01                      moveq.l    #1,d6
[000105ac] 3d7c 0001 fffc            move.w     #$0001,-4(a6)
[000105b2] 206e 0010                 movea.l    16(a6),a0
[000105b6] 208d                      move.l     a5,(a0)
[000105b8] 6044                      bra.s      $000105FE
[000105ba] 1e1d                      move.b     (a5)+,d7
[000105bc] 4887                      ext.w      d7
[000105be] 4a6e fffc                 tst.w      -4(a6)
[000105c2] 672a                      beq.s      $000105EE
[000105c4] be7c 0027                 cmp.w      #$0027,d7
[000105c8] 6706                      beq.s      $000105D0
[000105ca] be7c 0060                 cmp.w      #$0060,d7
[000105ce] 660a                      bne.s      $000105DA
[000105d0] 426e fffc                 clr.w      -4(a6)
[000105d4] 3d47 fffa                 move.w     d7,-6(a6)
[000105d8] 6012                      bra.s      $000105EC
[000105da] be7c 0028                 cmp.w      #$0028,d7
[000105de] 6604                      bne.s      $000105E4
[000105e0] 5246                      addq.w     #1,d6
[000105e2] 6008                      bra.s      $000105EC
[000105e4] be7c 0029                 cmp.w      #$0029,d7
[000105e8] 6602                      bne.s      $000105EC
[000105ea] 5346                      subq.w     #1,d6
[000105ec] 6010                      bra.s      $000105FE
[000105ee] be6e fffa                 cmp.w      -6(a6),d7
[000105f2] 6704                      beq.s      $000105F8
[000105f4] 4240                      clr.w      d0
[000105f6] 6002                      bra.s      $000105FA
[000105f8] 7001                      moveq.l    #1,d0
[000105fa] 3d40 fffc                 move.w     d0,-4(a6)
[000105fe] 4a46                      tst.w      d6
[00010600] 6704                      beq.s      $00010606
[00010602] bbcc                      cmpa.l     a4,a5
[00010604] 65b4                      bcs.s      $000105BA
[00010606] 4a6e fffc                 tst.w      -4(a6)
[0001060a] 6606                      bne.s      $00010612
[0001060c] 70fc                      moveq.l    #-4,d0
[0001060e] 6000 00ba                 bra        $000106CA
[00010612] 4a46                      tst.w      d6
[00010614] 6706                      beq.s      $0001061C
[00010616] 70fd                      moveq.l    #-3,d0
[00010618] 6000 00b0                 bra        $000106CA
[0001061c] 206e 0008                 movea.l    8(a6),a0
[00010620] 208d                      move.l     a5,(a0)
[00010622] 538d                      subq.l     #1,a5
[00010624] 206e 0014                 movea.l    20(a6),a0
[00010628] 208d                      move.l     a5,(a0)
[0001062a] 7001                      moveq.l    #1,d0
[0001062c] 6000 009c                 bra        $000106CA
[00010630] 6000 0074                 bra.w      $000106A6
[00010634] 206e 0010                 movea.l    16(a6),a0
[00010638] 208d                      move.l     a5,(a0)
[0001063a] be7c 0027                 cmp.w      #$0027,d7
[0001063e] 6706                      beq.s      $00010646
[00010640] be7c 0060                 cmp.w      #$0060,d7
[00010644] 6604                      bne.s      $0001064A
[00010646] 4240                      clr.w      d0
[00010648] 6002                      bra.s      $0001064C
[0001064a] 7001                      moveq.l    #1,d0
[0001064c] 3d40 fffc                 move.w     d0,-4(a6)
[00010650] 4a6e fffc                 tst.w      -4(a6)
[00010654] 6720                      beq.s      $00010676
[00010656] 6006                      bra.s      $0001065E
[00010658] 528d                      addq.l     #1,a5
[0001065a] 1e15                      move.b     (a5),d7
[0001065c] 4887                      ext.w      d7
[0001065e] be7c 002c                 cmp.w      #$002C,d7
[00010662] 6710                      beq.s      $00010674
[00010664] be7c 0027                 cmp.w      #$0027,d7
[00010668] 670a                      beq.s      $00010674
[0001066a] be7c 0060                 cmp.w      #$0060,d7
[0001066e] 6704                      beq.s      $00010674
[00010670] bbcc                      cmpa.l     a4,a5
[00010672] 65e4                      bcs.s      $00010658
[00010674] 6020                      bra.s      $00010696
[00010676] 3d47 fffa                 move.w     d7,-6(a6)
[0001067a] 528d                      addq.l     #1,a5
[0001067c] 4247                      clr.w      d7
[0001067e] bbcc                      cmpa.l     a4,a5
[00010680] 640a                      bcc.s      $0001068C
[00010682] 1e1d                      move.b     (a5)+,d7
[00010684] 4887                      ext.w      d7
[00010686] be6e fffa                 cmp.w      -6(a6),d7
[0001068a] 66f2                      bne.s      $0001067E
[0001068c] be6e fffa                 cmp.w      -6(a6),d7
[00010690] 6704                      beq.s      $00010696
[00010692] 70fc                      moveq.l    #-4,d0
[00010694] 6034                      bra.s      $000106CA
[00010696] 206e 0014                 movea.l    20(a6),a0
[0001069a] 208d                      move.l     a5,(a0)
[0001069c] 206e 0008                 movea.l    8(a6),a0
[000106a0] 208d                      move.l     a5,(a0)
[000106a2] 4240                      clr.w      d0
[000106a4] 6024                      bra.s      $000106CA
[000106a6] 206e 0008                 movea.l    8(a6),a0
[000106aa] 226e 000c                 movea.l    12(a6),a1
[000106ae] 2091                      move.l     (a1),(a0)
[000106b0] 206e 000c                 movea.l    12(a6),a0
[000106b4] 2010                      move.l     (a0),d0
[000106b6] 226e 0014                 movea.l    20(a6),a1
[000106ba] 2280                      move.l     d0,(a1)
[000106bc] 226e 0010                 movea.l    16(a6),a1
[000106c0] 2280                      move.l     d0,(a1)
[000106c2] 206e 0018                 movea.l    24(a6),a0
[000106c6] 4250                      clr.w      (a0)
[000106c8] 4240                      clr.w      d0
[000106ca] 4a9f                      tst.l      (a7)+
[000106cc] 4cdf 30c0                 movem.l    (a7)+,d6-d7/a4-a5
[000106d0] 4e5e                      unlk       a6
[000106d2] 4e75                      rts
prt_field:
[000106d4] 4e56 0000                 link       a6,#0
[000106d8] 48e7 0300                 movem.l    d6-d7,-(a7)
[000106dc] 202e 0008                 move.l     8(a6),d0
[000106e0] b0ae 000c                 cmp.l      12(a6),d0
[000106e4] 6506                      bcs.s      $000106EC
[000106e6] 70ff                      moveq.l    #-1,d0
[000106e8] 6000 00b2                 bra        $0001079C
[000106ec] 23ee 0008 0001 2b60       move.l     8(a6),strstart
[000106f4] 23ee 000c 0001 2b64       move.l     12(a6),strend
[000106fc] 206e 0008                 movea.l    8(a6),a0
[00010700] 1e10                      move.b     (a0),d7
[00010702] 1007                      move.b     d7,d0
[00010704] 4880                      ext.w      d0
[00010706] 6000 007e                 bra.w      $00010786
case '/'
[0001070a] 3ebc 000d                 move.w     #$000D,(a7)
[0001070e] 3f3c 0002                 move.w     #$0002,-(a7)
[00010712] 3f3c 0003                 move.w     #$0003,-(a7)
[00010716] 4eb9 0001 222c            jsr        bios
[0001071c] 588f                      addq.l     #4,a7
[0001071e] 3ebc 000a                 move.w     #$000A,(a7)
[00010722] 3f3c 0002                 move.w     #$0002,-(a7)
[00010726] 3f3c 0003                 move.w     #$0003,-(a7)
[0001072a] 4eb9 0001 222c            jsr        bios
[00010730] 588f                      addq.l     #4,a7
[00010732] 6000 0068                 bra.w      $0001079C
case '\''
case '`'
[00010736] 6100 012a                 bsr        rawprint
[0001073a] 6000 0060                 bra.w      $0001079C
case '?'
[0001073e] 33fc 0001 0001 28da       move.w     #$0001,$000128DA
[00010746] 6054                      bra.s      $0001079C
case '!'
[00010748] 4279 0001 28da            clr.w      $000128DA
[0001074e] 604c                      bra.s      $0001079C
case 's'
[00010750] 6100 014e                 bsr        prt_str
[00010754] 6046                      bra.s      $0001079C
case 'l'
[00010756] 6100 02ce                 bsr        $00010A26
[0001075a] 6040                      bra.s      $0001079C
case 'i'
[0001075c] 6100 022a                 bsr        $00010988
[00010760] 603a                      bra.s      $0001079C
case 'f':
[00010762] 6100 0360                 bsr        prt_fixed
[00010766] 6034                      bra.s      $0001079C
case 'e'
[00010768] 6100 03aa                 bsr        prt_float
[0001076c] 602e                      bra.s      $0001079C
case 'v'
[0001076e] 6100 03f4                 bsr        vt52_seq
[00010772] 6028                      bra.s      $0001079C
[00010774] 4279 0001 2b58            clr.w      cont_parse
[0001077a] 33fc ffff 0001 2b5a       move.w     #$FFFF,vt52_err
[00010782] 6018                      bra.s      $0001079C
[00010784] 6016                      bra.s      $0001079C
[00010786] 48c0                      ext.l      d0
[00010788] 207c 0001 28dc            movea.l    #$000128DC,a0
[0001078e] 720b                      moveq.l    #11,d1
[00010790] b098                      cmp.l      (a0)+,d0
[00010792] 57c9 fffc                 dbeq       d1,$00010790
[00010796] 2068 002c                 movea.l    44(a0),a0
[0001079a] 4ed0                      jmp        (a0)
[0001079c] 4a9f                      tst.l      (a7)+
[0001079e] 4cdf 0080                 movem.l    (a7)+,d7
[000107a2] 4e5e                      unlk       a6
[000107a4] 4e75                      rts
parse_prec:
[000107a6] 4e56 0000                 link       a6,#0
[000107aa] 48e7 0f0c                 movem.l    d4-d7/a4-a5,-(a7)
[000107ae] 2a79 0001 2b60            movea.l    strstart,a5
[000107b4] 528d                      addq.l     #1,a5
[000107b6] 2879 0001 2b64            movea.l    strend,a4
[000107bc] 538c                      subq.l     #1,a4
[000107be] 7cff                      moveq.l    #-1,d6
[000107c0] 3e06                      move.w     d6,d7
[000107c2] 6002                      bra.s      $000107C6
[000107c4] 528d                      addq.l     #1,a5
[000107c6] 0c15 0020                 cmpi.b     #$20,(a5)
[000107ca] 67f8                      beq.s      $000107C4
[000107cc] 6002                      bra.s      $000107D0
[000107ce] 538c                      subq.l     #1,a4
[000107d0] 0c14 0020                 cmpi.b     #$20,(a4)
[000107d4] 67f8                      beq.s      $000107CE
[000107d6] bbcc                      cmpa.l     a4,a5
[000107d8] 625e                      bhi.s      $00010838
[000107da] 4247                      clr.w      d7
[000107dc] 600e                      bra.s      $000107EC
[000107de] 3005                      move.w     d5,d0
[000107e0] 3207                      move.w     d7,d1
[000107e2] c3fc 000a                 muls.w     #$000A,d1
[000107e6] d041                      add.w      d1,d0
[000107e8] 3e00                      move.w     d0,d7
[000107ea] 528d                      addq.l     #1,a5
[000107ec] bbcc                      cmpa.l     a4,a5
[000107ee] 6210                      bhi.s      $00010800
[000107f0] 1a15                      move.b     (a5),d5
[000107f2] 4885                      ext.w      d5
[000107f4] da7c ffd0                 add.w      #$FFD0,d5
[000107f8] 6d06                      blt.s      $00010800
[000107fa] ba7c 000a                 cmp.w      #$000A,d5
[000107fe] 6dde                      blt.s      $000107DE
[00010800] bbcc                      cmpa.l     a4,a5
[00010802] 6234                      bhi.s      $00010838
[00010804] 0c1d 002e                 cmpi.b     #$2E,(a5)+
[00010808] 663e                      bne.s      $00010848
[0001080a] bbcc                      cmpa.l     a4,a5
[0001080c] 623a                      bhi.s      $00010848
[0001080e] 4246                      clr.w      d6
[00010810] 600e                      bra.s      $00010820
[00010812] 3005                      move.w     d5,d0
[00010814] 3206                      move.w     d6,d1
[00010816] c3fc 000a                 muls.w     #$000A,d1
[0001081a] d041                      add.w      d1,d0
[0001081c] 3c00                      move.w     d0,d6
[0001081e] 528d                      addq.l     #1,a5
[00010820] bbcc                      cmpa.l     a4,a5
[00010822] 6210                      bhi.s      $00010834
[00010824] 1a15                      move.b     (a5),d5
[00010826] 4885                      ext.w      d5
[00010828] da7c ffd0                 add.w      #$FFD0,d5
[0001082c] 6d06                      blt.s      $00010834
[0001082e] ba7c 000a                 cmp.w      #$000A,d5
[00010832] 6dde                      blt.s      $00010812
[00010834] bbcc                      cmpa.l     a4,a5
[00010836] 6310                      bls.s      $00010848
[00010838] 206e 0008                 movea.l    8(a6),a0
[0001083c] 3087                      move.w     d7,(a0)
[0001083e] 206e 000c                 movea.l    12(a6),a0
[00010842] 3086                      move.w     d6,(a0)
[00010844] 4240                      clr.w      d0
[00010846] 6010                      bra.s      $00010858
[00010848] 4279 0001 2b58            clr.w      cont_parse
[0001084e] 33fc fffe 0001 2b5a       move.w     #$FFFE,vt52_err
[00010856] 70ff                      moveq.l    #-1,d0
[00010858] 4a9f                      tst.l      (a7)+
[0001085a] 4cdf 30e0                 movem.l    (a7)+,d5-d7/a4-a5
[0001085e] 4e5e                      unlk       a6
[00010860] 4e75                      rts
rawprint:
[00010862] 4e56 0000                 link       a6,#0
[00010866] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[0001086a] 2a79 0001 2b60            movea.l    strstart,a5
[00010870] 528d                      addq.l     #1,a5
[00010872] 2879 0001 2b64            movea.l    strend,a4
[00010878] 538c                      subq.l     #1,a4
[0001087a] 6016                      bra.s      $00010892
[0001087c] 101d                      move.b     (a5)+,d0
[0001087e] 4880                      ext.w      d0
[00010880] 3e80                      move.w     d0,(a7)
[00010882] 3f3c 0005                 move.w     #$0005,-(a7)
[00010886] 3f3c 0003                 move.w     #$0003,-(a7)
[0001088a] 4eb9 0001 222c            jsr        bios
[00010890] 588f                      addq.l     #4,a7
[00010892] bbcc                      cmpa.l     a4,a5
[00010894] 65e6                      bcs.s      $0001087C
[00010896] 4a9f                      tst.l      (a7)+
[00010898] 4cdf 3000                 movem.l    (a7)+,a4-a5
[0001089c] 4e5e                      unlk       a6
[0001089e] 4e75                      rts
prt_str:
[000108a0] 4e56 fff8                 link       a6,#-8
[000108a4] 48e7 031c                 movem.l    d6-d7/a3-a5,-(a7)
[000108a8] 2d79 0001 2b5c fff8       move.l     args,-8(a6)
[000108b0] 58b9 0001 2b5c            addq.l     #4,args
[000108b6] 206e fff8                 movea.l    -8(a6),a0
[000108ba] 2a50                      movea.l    (a0),a5
[000108bc] 2879 0001 2b60            movea.l    strstart,a4
[000108c2] 528c                      addq.l     #1,a4
[000108c4] b9f9 0001 2b64            cmpa.l     strend,a4
[000108ca] 6412                      bcc.s      $000108DE
[000108cc] 0c14 0068                 cmpi.b     #$68,(a4)
[000108d0] 6706                      beq.s      $000108D8
[000108d2] 0c14 0062                 cmpi.b     #$62,(a4)
[000108d6] 6606                      bne.s      $000108DE
[000108d8] 52b9 0001 2b60            addq.l     #1,strstart
[000108de] 2e8e                      move.l     a6,(a7)
[000108e0] 5997                      subq.l     #4,(a7)
[000108e2] 2f0e                      move.l     a6,-(a7)
[000108e4] 5597                      subq.l     #2,(a7)
[000108e6] 6100 febe                 bsr        $000107A6
[000108ea] 588f                      addq.l     #4,a7
[000108ec] 4a79 0001 2b58            tst.w      cont_parse
[000108f2] 6700 008a                 beq        $0001097E
[000108f6] 4247                      clr.w      d7
[000108f8] 6002                      bra.s      $000108FC
[000108fa] 5247                      addq.w     #1,d7
[000108fc] 4a35 7000                 tst.b      0(a5,d7.w)
[00010900] 66f8                      bne.s      $000108FA
[00010902] 0c14 0068                 cmpi.b     #$68,(a4)
[00010906] 6610                      bne.s      $00010918
[00010908] 3eae fffe                 move.w     -2(a6),(a7)
[0001090c] 3f07                      move.w     d7,-(a7)
[0001090e] 2f0d                      move.l     a5,-(a7)
[00010910] 6100 0a2e                 bsr        prt_hex
[00010914] 5c8f                      addq.l     #6,a7
[00010916] 6066                      bra.s      $0001097E
[00010918] 0c14 0062                 cmpi.b     #$62,(a4)
[0001091c] 6610                      bne.s      $0001092E
[0001091e] 3eae fffe                 move.w     -2(a6),(a7)
[00010922] 3f07                      move.w     d7,-(a7)
[00010924] 2f0d                      move.l     a5,-(a7)
[00010926] 6100 0b28                 bsr        prt_bin
[0001092a] 5c8f                      addq.l     #6,a7
[0001092c] 6050                      bra.s      $0001097E
[0001092e] 6018                      bra.s      $00010948
[00010930] 536e fffe                 subq.w     #1,-2(a6)
[00010934] 3ebc 0020                 move.w     #$0020,(a7)
[00010938] 3f3c 0002                 move.w     #$0002,-(a7)
[0001093c] 3f3c 0003                 move.w     #$0003,-(a7)
[00010940] 4eb9 0001 222c            jsr        bios
[00010946] 588f                      addq.l     #4,a7
[00010948] be6e fffe                 cmp.w      -2(a6),d7
[0001094c] 6de2                      blt.s      $00010930
[0001094e] 4a6e fffe                 tst.w      -2(a6)
[00010952] 6d0a                      blt.s      $0001095E
[00010954] be6e fffe                 cmp.w      -2(a6),d7
[00010958] 6f04                      ble.s      $0001095E
[0001095a] 3e2e fffe                 move.w     -2(a6),d7
[0001095e] 6016                      bra.s      $00010976
[00010960] 101d                      move.b     (a5)+,d0
[00010962] 4880                      ext.w      d0
[00010964] 3e80                      move.w     d0,(a7)
[00010966] 3f3c 0002                 move.w     #$0002,-(a7)
[0001096a] 3f3c 0003                 move.w     #$0003,-(a7)
[0001096e] 4eb9 0001 222c            jsr        bios
[00010974] 588f                      addq.l     #4,a7
[00010976] 3007                      move.w     d7,d0
[00010978] 5347                      subq.w     #1,d7
[0001097a] 4a40                      tst.w      d0
[0001097c] 6ee2                      bgt.s      $00010960
[0001097e] 4a9f                      tst.l      (a7)+
[00010980] 4cdf 3880                 movem.l    (a7)+,d7/a3-a5
[00010984] 4e5e                      unlk       a6
[00010986] 4e75                      rts

prt_int:
[00010988] 4e56 fffc                 link       a6,#-4
[0001098c] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[00010990] 2a79 0001 2b5c            movea.l    args,a5
[00010996] 54b9 0001 2b5c            addq.l     #2,args
[0001099c] 2879 0001 2b60            movea.l    strstart,a4
[000109a2] 528c                      addq.l     #1,a4
[000109a4] b9f9 0001 2b64            cmpa.l     strend,a4
[000109aa] 6412                      bcc.s      $000109BE
[000109ac] 0c14 0068                 cmpi.b     #$68,(a4)
[000109b0] 6706                      beq.s      $000109B8
[000109b2] 0c14 0062                 cmpi.b     #$62,(a4)
[000109b6] 6606                      bne.s      $000109BE
[000109b8] 52b9 0001 2b60            addq.l     #1,strstart
[000109be] 2e8e                      move.l     a6,(a7)
[000109c0] 5997                      subq.l     #4,(a7)
[000109c2] 2f0e                      move.l     a6,-(a7)
[000109c4] 5597                      subq.l     #2,(a7)
[000109c6] 6100 fdde                 bsr        $000107A6
[000109ca] 588f                      addq.l     #4,a7
[000109cc] 4a79 0001 2b58            tst.w      cont_parse
[000109d2] 6748                      beq.s      $00010A1C
[000109d4] 0c14 0068                 cmpi.b     #$68,(a4)
[000109d8] 6612                      bne.s      $000109EC
[000109da] 3eae fffe                 move.w     -2(a6),(a7)
[000109de] 3f3c 0002                 move.w     #$0002,-(a7)
[000109e2] 2f0d                      move.l     a5,-(a7)
[000109e4] 6100 095a                 bsr        prt_hex
[000109e8] 5c8f                      addq.l     #6,a7
[000109ea] 6030                      bra.s      $00010A1C
[000109ec] 0c14 0062                 cmpi.b     #$62,(a4)
[000109f0] 6612                      bne.s      $00010A04
[000109f2] 3eae fffe                 move.w     -2(a6),(a7)
[000109f6] 3f3c 0002                 move.w     #$0002,-(a7)
[000109fa] 2f0d                      move.l     a5,-(a7)
[000109fc] 6100 0a52                 bsr        prt_bin
[00010a00] 5c8f                      addq.l     #6,a7
[00010a02] 6018                      bra.s      $00010A1C
[00010a04] 2ebc 0001 2ab6            move.l     #strbuf,(a7)
[00010a0a] 3f2e fffe                 move.w     -2(a6),-(a7)
[00010a0e] 3f15                      move.w     (a5),-(a7)
[00010a10] 4eb9 0001 1a14            jsr        fmt_int
[00010a16] 588f                      addq.l     #4,a7
[00010a18] 6100 08f4                 bsr        flush_strbuf
[00010a1c] 4a9f                      tst.l      (a7)+
[00010a1e] 4cdf 3000                 movem.l    (a7)+,a4-a5
[00010a22] 4e5e                      unlk       a6
[00010a24] 4e75                      rts

prt_long:
[00010a26] 4e56 fffc                 link       a6,#-4
[00010a2a] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[00010a2e] 2a79 0001 2b5c            movea.l    args,a5
[00010a34] 58b9 0001 2b5c            addq.l     #4,args
[00010a3a] 2879 0001 2b60            movea.l    strstart,a4
[00010a40] 528c                      addq.l     #1,a4
[00010a42] b9f9 0001 2b64            cmpa.l     strend,a4
[00010a48] 6412                      bcc.s      $00010A5C
[00010a4a] 0c14 0068                 cmpi.b     #$68,(a4)
[00010a4e] 6706                      beq.s      $00010A56
[00010a50] 0c14 0062                 cmpi.b     #$62,(a4)
[00010a54] 6606                      bne.s      $00010A5C
[00010a56] 52b9 0001 2b60            addq.l     #1,strstart
[00010a5c] 2e8e                      move.l     a6,(a7)
[00010a5e] 5997                      subq.l     #4,(a7)
[00010a60] 2f0e                      move.l     a6,-(a7)
[00010a62] 5597                      subq.l     #2,(a7)
[00010a64] 6100 fd40                 bsr        $000107A6
[00010a68] 588f                      addq.l     #4,a7
[00010a6a] 4a79 0001 2b58            tst.w      cont_parse
[00010a70] 6748                      beq.s      $00010ABA
[00010a72] 0c14 0068                 cmpi.b     #$68,(a4)
[00010a76] 6612                      bne.s      $00010A8A
[00010a78] 3eae fffe                 move.w     -2(a6),(a7)
[00010a7c] 3f3c 0004                 move.w     #$0004,-(a7)
[00010a80] 2f0d                      move.l     a5,-(a7)
[00010a82] 6100 08bc                 bsr        prt_hex
[00010a86] 5c8f                      addq.l     #6,a7
[00010a88] 6030                      bra.s      $00010ABA
[00010a8a] 0c14 0062                 cmpi.b     #$62,(a4)
[00010a8e] 6612                      bne.s      $00010AA2
[00010a90] 3eae fffe                 move.w     -2(a6),(a7)
[00010a94] 3f3c 0004                 move.w     #$0004,-(a7)
[00010a98] 2f0d                      move.l     a5,-(a7)
[00010a9a] 6100 09b4                 bsr        prt_bin
[00010a9e] 5c8f                      addq.l     #6,a7
[00010aa0] 6018                      bra.s      $00010ABA
[00010aa2] 2ebc 0001 2ab6            move.l     #strbuf,(a7)
[00010aa8] 3f2e fffe                 move.w     -2(a6),-(a7)
[00010aac] 2f15                      move.l     (a5),-(a7)
[00010aae] 4eb9 0001 1a2e            jsr        fmt_long
[00010ab4] 5c8f                      addq.l     #6,a7
[00010ab6] 6100 0856                 bsr        flush_strbuf
[00010aba] 4a9f                      tst.l      (a7)+
[00010abc] 4cdf 3000                 movem.l    (a7)+,a4-a5
[00010ac0] 4e5e                      unlk       a6
[00010ac2] 4e75                      rts

prt_fixed:
[00010ac4] 4e56 fffc                 link       a6,#-4
[00010ac8] 48e7 0104                 movem.l    d7/a5,-(a7)
[00010acc] 2a79 0001 2b5c            movea.l    args,a5
[00010ad2] 58b9 0001 2b5c            addq.l     #4,args
[00010ad8] 2e8e                      move.l     a6,(a7)
[00010ada] 5997                      subq.l     #4,(a7)
[00010adc] 2f0e                      move.l     a6,-(a7)
[00010ade] 5597                      subq.l     #2,(a7)
[00010ae0] 6100 fcc4                 bsr        $000107A6
[00010ae4] 588f                      addq.l     #4,a7
[00010ae6] 4a79 0001 2b58            tst.w      cont_parse
[00010aec] 671c                      beq.s      $00010B0A
[00010aee] 2ebc 0001 2ab6            move.l     #strbuf,(a7)
[00010af4] 3f2e fffc                 move.w     -4(a6),-(a7)
[00010af8] 3f2e fffe                 move.w     -2(a6),-(a7)
[00010afc] 2f15                      move.l     (a5),-(a7)
[00010afe] 4eb9 0001 1ac4            jsr        fmt_fixed
[00010b04] 508f                      addq.l     #8,a7
[00010b06] 6100 0806                 bsr        flush_strbuf
[00010b0a] 4a9f                      tst.l      (a7)+
[00010b0c] 4cdf 2000                 movem.l    (a7)+,a5
[00010b10] 4e5e                      unlk       a6
[00010b12] 4e75                      rts

prt_float:
[00010b14] 4e56 fffc                 link       a6,#-4
[00010b18] 48e7 0104                 movem.l    d7/a5,-(a7)
[00010b1c] 2a79 0001 2b5c            movea.l    args,a5
[00010b22] 58b9 0001 2b5c            addq.l     #4,args
[00010b28] 2e8e                      move.l     a6,(a7)
[00010b2a] 5997                      subq.l     #4,(a7)
[00010b2c] 2f0e                      move.l     a6,-(a7)
[00010b2e] 5597                      subq.l     #2,(a7)
[00010b30] 6100 fc74                 bsr        $000107A6
[00010b34] 588f                      addq.l     #4,a7
[00010b36] 4a79 0001 2b58            tst.w      cont_parse
[00010b3c] 671c                      beq.s      $00010B5A
[00010b3e] 2ebc 0001 2ab6            move.l     #strbuf,(a7)
[00010b44] 3f2e fffc                 move.w     -4(a6),-(a7)
[00010b48] 3f2e fffe                 move.w     -2(a6),-(a7)
[00010b4c] 2f15                      move.l     (a5),-(a7)
[00010b4e] 4eb9 0001 1c9a            jsr        fmt_float
[00010b54] 508f                      addq.l     #8,a7
[00010b56] 6100 07b6                 bsr        flush_strbuf
[00010b5a] 4a9f                      tst.l      (a7)+
[00010b5c] 4cdf 2000                 movem.l    (a7)+,a5
[00010b60] 4e5e                      unlk       a6
[00010b62] 4e75                      rts

vt52_seq:
[00010b64] 4e56 0000                 link       a6,#0
[00010b68] 48e7 0704                 movem.l    d5-d7/a5,-(a7)
[00010b6c] 52b9 0001 2b60            addq.l     #1,strstart
[00010b72] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010b78] 2f3c 0001 29b4            move.l     #$000129B4,-(a7)
[00010b7e] 6100 075a                 bsr        streq
[00010b82] 588f                      addq.l     #4,a7
[00010b84] 4a40                      tst.w      d0
[00010b86] 672c                      beq.s      $00010BB4
[00010b88] 3ebc 001b                 move.w     #$001B,(a7)
[00010b8c] 3f3c 0002                 move.w     #$0002,-(a7)
[00010b90] 3f3c 0003                 move.w     #$0003,-(a7)
[00010b94] 4eb9 0001 222c            jsr        bios
[00010b9a] 588f                      addq.l     #4,a7
[00010b9c] 3ebc 0041                 move.w     #$0041,(a7)
[00010ba0] 3f3c 0002                 move.w     #$0002,-(a7)
[00010ba4] 3f3c 0003                 move.w     #$0003,-(a7)
[00010ba8] 4eb9 0001 222c            jsr        bios
[00010bae] 588f                      addq.l     #4,a7
[00010bb0] 6000 071e                 bra        $000112D0
[00010bb4] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010bba] 2f3c 0001 29b9            move.l     #$000129B9,-(a7)
[00010bc0] 6100 0718                 bsr        streq
[00010bc4] 588f                      addq.l     #4,a7
[00010bc6] 4a40                      tst.w      d0
[00010bc8] 672c                      beq.s      $00010BF6
[00010bca] 3ebc 001b                 move.w     #$001B,(a7)
[00010bce] 3f3c 0002                 move.w     #$0002,-(a7)
[00010bd2] 3f3c 0003                 move.w     #$0003,-(a7)
[00010bd6] 4eb9 0001 222c            jsr        bios
[00010bdc] 588f                      addq.l     #4,a7
[00010bde] 3ebc 0042                 move.w     #$0042,(a7)
[00010be2] 3f3c 0002                 move.w     #$0002,-(a7)
[00010be6] 3f3c 0003                 move.w     #$0003,-(a7)
[00010bea] 4eb9 0001 222c            jsr        bios
[00010bf0] 588f                      addq.l     #4,a7
[00010bf2] 6000 06dc                 bra        $000112D0
[00010bf6] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010bfc] 2f3c 0001 29c0            move.l     #$000129C0,-(a7)
[00010c02] 6100 06d6                 bsr        streq
[00010c06] 588f                      addq.l     #4,a7
[00010c08] 4a40                      tst.w      d0
[00010c0a] 672c                      beq.s      $00010C38
[00010c0c] 3ebc 001b                 move.w     #$001B,(a7)
[00010c10] 3f3c 0002                 move.w     #$0002,-(a7)
[00010c14] 3f3c 0003                 move.w     #$0003,-(a7)
[00010c18] 4eb9 0001 222c            jsr        bios
[00010c1e] 588f                      addq.l     #4,a7
[00010c20] 3ebc 0043                 move.w     #$0043,(a7)
[00010c24] 3f3c 0002                 move.w     #$0002,-(a7)
[00010c28] 3f3c 0003                 move.w     #$0003,-(a7)
[00010c2c] 4eb9 0001 222c            jsr        bios
[00010c32] 588f                      addq.l     #4,a7
[00010c34] 6000 069a                 bra        $000112D0
[00010c38] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010c3e] 2f3c 0001 29c8            move.l     #$000129C8,-(a7)
[00010c44] 6100 0694                 bsr        streq
[00010c48] 588f                      addq.l     #4,a7
[00010c4a] 4a40                      tst.w      d0
[00010c4c] 672c                      beq.s      $00010C7A
[00010c4e] 3ebc 001b                 move.w     #$001B,(a7)
[00010c52] 3f3c 0002                 move.w     #$0002,-(a7)
[00010c56] 3f3c 0003                 move.w     #$0003,-(a7)
[00010c5a] 4eb9 0001 222c            jsr        bios
[00010c60] 588f                      addq.l     #4,a7
[00010c62] 3ebc 0044                 move.w     #$0044,(a7)
[00010c66] 3f3c 0002                 move.w     #$0002,-(a7)
[00010c6a] 3f3c 0003                 move.w     #$0003,-(a7)
[00010c6e] 4eb9 0001 222c            jsr        bios
[00010c74] 588f                      addq.l     #4,a7
[00010c76] 6000 0658                 bra        $000112D0
[00010c7a] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010c80] 2f3c 0001 29cf            move.l     #$000129CF,-(a7)
[00010c86] 6100 0652                 bsr        streq
[00010c8a] 588f                      addq.l     #4,a7
[00010c8c] 4a40                      tst.w      d0
[00010c8e] 672c                      beq.s      $00010CBC
[00010c90] 3ebc 001b                 move.w     #$001B,(a7)
[00010c94] 3f3c 0002                 move.w     #$0002,-(a7)
[00010c98] 3f3c 0003                 move.w     #$0003,-(a7)
[00010c9c] 4eb9 0001 222c            jsr        bios
[00010ca2] 588f                      addq.l     #4,a7
[00010ca4] 3ebc 0045                 move.w     #$0045,(a7)
[00010ca8] 3f3c 0002                 move.w     #$0002,-(a7)
[00010cac] 3f3c 0003                 move.w     #$0003,-(a7)
[00010cb0] 4eb9 0001 222c            jsr        bios
[00010cb6] 588f                      addq.l     #4,a7
[00010cb8] 6000 0616                 bra        $000112D0
[00010cbc] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010cc2] 2f3c 0001 29d6            move.l     #$000129D6,-(a7)
[00010cc8] 6100 0610                 bsr        streq
[00010ccc] 588f                      addq.l     #4,a7
[00010cce] 4a40                      tst.w      d0
[00010cd0] 672c                      beq.s      $00010CFE
[00010cd2] 3ebc 001b                 move.w     #$001B,(a7)
[00010cd6] 3f3c 0002                 move.w     #$0002,-(a7)
[00010cda] 3f3c 0003                 move.w     #$0003,-(a7)
[00010cde] 4eb9 0001 222c            jsr        bios
[00010ce4] 588f                      addq.l     #4,a7
[00010ce6] 3ebc 0048                 move.w     #$0048,(a7)
[00010cea] 3f3c 0002                 move.w     #$0002,-(a7)
[00010cee] 3f3c 0003                 move.w     #$0003,-(a7)
[00010cf2] 4eb9 0001 222c            jsr        bios
[00010cf8] 588f                      addq.l     #4,a7
[00010cfa] 6000 05d4                 bra        $000112D0
[00010cfe] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010d04] 2f3c 0001 29dd            move.l     #$000129DD,-(a7)
[00010d0a] 6100 05ce                 bsr        streq
[00010d0e] 588f                      addq.l     #4,a7
[00010d10] 4a40                      tst.w      d0
[00010d12] 672c                      beq.s      $00010D40
[00010d14] 3ebc 001b                 move.w     #$001B,(a7)
[00010d18] 3f3c 0002                 move.w     #$0002,-(a7)
[00010d1c] 3f3c 0003                 move.w     #$0003,-(a7)
[00010d20] 4eb9 0001 222c            jsr        bios
[00010d26] 588f                      addq.l     #4,a7
[00010d28] 3ebc 0049                 move.w     #$0049,(a7)
[00010d2c] 3f3c 0002                 move.w     #$0002,-(a7)
[00010d30] 3f3c 0003                 move.w     #$0003,-(a7)
[00010d34] 4eb9 0001 222c            jsr        bios
[00010d3a] 588f                      addq.l     #4,a7
[00010d3c] 6000 0592                 bra        $000112D0
[00010d40] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010d46] 2f3c 0001 29e4            move.l     #$000129E4,-(a7)
[00010d4c] 6100 058c                 bsr        streq
[00010d50] 588f                      addq.l     #4,a7
[00010d52] 4a40                      tst.w      d0
[00010d54] 672c                      beq.s      $00010D82
[00010d56] 3ebc 001b                 move.w     #$001B,(a7)
[00010d5a] 3f3c 0002                 move.w     #$0002,-(a7)
[00010d5e] 3f3c 0003                 move.w     #$0003,-(a7)
[00010d62] 4eb9 0001 222c            jsr        bios
[00010d68] 588f                      addq.l     #4,a7
[00010d6a] 3ebc 004a                 move.w     #$004A,(a7)
[00010d6e] 3f3c 0002                 move.w     #$0002,-(a7)
[00010d72] 3f3c 0003                 move.w     #$0003,-(a7)
[00010d76] 4eb9 0001 222c            jsr        bios
[00010d7c] 588f                      addq.l     #4,a7
[00010d7e] 6000 0550                 bra        $000112D0
[00010d82] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010d88] 2f3c 0001 29eb            move.l     #$000129EB,-(a7)
[00010d8e] 6100 054a                 bsr        streq
[00010d92] 588f                      addq.l     #4,a7
[00010d94] 4a40                      tst.w      d0
[00010d96] 672c                      beq.s      $00010DC4
[00010d98] 3ebc 001b                 move.w     #$001B,(a7)
[00010d9c] 3f3c 0002                 move.w     #$0002,-(a7)
[00010da0] 3f3c 0003                 move.w     #$0003,-(a7)
[00010da4] 4eb9 0001 222c            jsr        bios
[00010daa] 588f                      addq.l     #4,a7
[00010dac] 3ebc 004b                 move.w     #$004B,(a7)
[00010db0] 3f3c 0002                 move.w     #$0002,-(a7)
[00010db4] 3f3c 0003                 move.w     #$0003,-(a7)
[00010db8] 4eb9 0001 222c            jsr        bios
[00010dbe] 588f                      addq.l     #4,a7
[00010dc0] 6000 050e                 bra        $000112D0
[00010dc4] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010dca] 2f3c 0001 29f3            move.l     #$000129F3,-(a7)
[00010dd0] 6100 0508                 bsr        streq
[00010dd4] 588f                      addq.l     #4,a7
[00010dd6] 4a40                      tst.w      d0
[00010dd8] 672c                      beq.s      $00010E06
[00010dda] 3ebc 001b                 move.w     #$001B,(a7)
[00010dde] 3f3c 0002                 move.w     #$0002,-(a7)
[00010de2] 3f3c 0003                 move.w     #$0003,-(a7)
[00010de6] 4eb9 0001 222c            jsr        bios
[00010dec] 588f                      addq.l     #4,a7
[00010dee] 3ebc 004c                 move.w     #$004C,(a7)
[00010df2] 3f3c 0002                 move.w     #$0002,-(a7)
[00010df6] 3f3c 0003                 move.w     #$0003,-(a7)
[00010dfa] 4eb9 0001 222c            jsr        bios
[00010e00] 588f                      addq.l     #4,a7
[00010e02] 6000 04cc                 bra        $000112D0
[00010e06] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010e0c] 2f3c 0001 29fb            move.l     #$000129FB,-(a7)
[00010e12] 6100 04c6                 bsr        streq
[00010e16] 588f                      addq.l     #4,a7
[00010e18] 4a40                      tst.w      d0
[00010e1a] 672c                      beq.s      $00010E48
[00010e1c] 3ebc 001b                 move.w     #$001B,(a7)
[00010e20] 3f3c 0002                 move.w     #$0002,-(a7)
[00010e24] 3f3c 0003                 move.w     #$0003,-(a7)
[00010e28] 4eb9 0001 222c            jsr        bios
[00010e2e] 588f                      addq.l     #4,a7
[00010e30] 3ebc 004d                 move.w     #$004D,(a7)
[00010e34] 3f3c 0002                 move.w     #$0002,-(a7)
[00010e38] 3f3c 0003                 move.w     #$0003,-(a7)
[00010e3c] 4eb9 0001 222c            jsr        bios
[00010e42] 588f                      addq.l     #4,a7
[00010e44] 6000 048a                 bra        $000112D0
[00010e48] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010e4e] 2f3c 0001 2a03            move.l     #$00012A03,-(a7)
[00010e54] 6100 0484                 bsr        streq
[00010e58] 588f                      addq.l     #4,a7
[00010e5a] 4a40                      tst.w      d0
[00010e5c] 6774                      beq.s      $00010ED2
[00010e5e] 2a79 0001 2b5c            movea.l    args,a5
[00010e64] 54b9 0001 2b5c            addq.l     #2,args
[00010e6a] 3e15                      move.w     (a5),d7
[00010e6c] 2a79 0001 2b5c            movea.l    args,a5
[00010e72] 54b9 0001 2b5c            addq.l     #2,args
[00010e78] 3c15                      move.w     (a5),d6
[00010e7a] 3ebc 001b                 move.w     #$001B,(a7)
[00010e7e] 3f3c 0002                 move.w     #$0002,-(a7)
[00010e82] 3f3c 0003                 move.w     #$0003,-(a7)
[00010e86] 4eb9 0001 222c            jsr        bios
[00010e8c] 588f                      addq.l     #4,a7
[00010e8e] 3ebc 0059                 move.w     #$0059,(a7)
[00010e92] 3f3c 0002                 move.w     #$0002,-(a7)
[00010e96] 3f3c 0003                 move.w     #$0003,-(a7)
[00010e9a] 4eb9 0001 222c            jsr        bios
[00010ea0] 588f                      addq.l     #4,a7
[00010ea2] 3e86                      move.w     d6,(a7)
[00010ea4] 0657 0020                 addi.w     #$0020,(a7)
[00010ea8] 3f3c 0002                 move.w     #$0002,-(a7)
[00010eac] 3f3c 0003                 move.w     #$0003,-(a7)
[00010eb0] 4eb9 0001 222c            jsr        bios
[00010eb6] 588f                      addq.l     #4,a7
[00010eb8] 3e87                      move.w     d7,(a7)
[00010eba] 0657 0020                 addi.w     #$0020,(a7)
[00010ebe] 3f3c 0002                 move.w     #$0002,-(a7)
[00010ec2] 3f3c 0003                 move.w     #$0003,-(a7)
[00010ec6] 4eb9 0001 222c            jsr        bios
[00010ecc] 588f                      addq.l     #4,a7
[00010ece] 6000 0400                 bra        $000112D0
[00010ed2] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010ed8] 2f3c 0001 2a09            move.l     #$00012A09,-(a7)
[00010ede] 6100 03fa                 bsr        streq
[00010ee2] 588f                      addq.l     #4,a7
[00010ee4] 4a40                      tst.w      d0
[00010ee6] 677a                      beq.s      $00010F62
[00010ee8] 3ebc 001b                 move.w     #$001B,(a7)
[00010eec] 3f3c 0002                 move.w     #$0002,-(a7)
[00010ef0] 3f3c 0003                 move.w     #$0003,-(a7)
[00010ef4] 4eb9 0001 222c            jsr        bios
[00010efa] 588f                      addq.l     #4,a7
[00010efc] 3ebc 0062                 move.w     #$0062,(a7)
[00010f00] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f04] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f08] 4eb9 0001 222c            jsr        bios
[00010f0e] 588f                      addq.l     #4,a7
[00010f10] 3ebc 0001                 move.w     #$0001,(a7)
[00010f14] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f18] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f1c] 4eb9 0001 222c            jsr        bios
[00010f22] 588f                      addq.l     #4,a7
[00010f24] 3ebc 001b                 move.w     #$001B,(a7)
[00010f28] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f2c] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f30] 4eb9 0001 222c            jsr        bios
[00010f36] 588f                      addq.l     #4,a7
[00010f38] 3ebc 0063                 move.w     #$0063,(a7)
[00010f3c] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f40] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f44] 4eb9 0001 222c            jsr        bios
[00010f4a] 588f                      addq.l     #4,a7
[00010f4c] 4257                      clr.w      (a7)
[00010f4e] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f52] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f56] 4eb9 0001 222c            jsr        bios
[00010f5c] 588f                      addq.l     #4,a7
[00010f5e] 6000 0370                 bra        $000112D0
[00010f62] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010f68] 2f3c 0001 2a0f            move.l     #$00012A0F,-(a7)
[00010f6e] 6100 036a                 bsr        streq
[00010f72] 588f                      addq.l     #4,a7
[00010f74] 4a40                      tst.w      d0
[00010f76] 677a                      beq.s      $00010FF2
[00010f78] 3ebc 001b                 move.w     #$001B,(a7)
[00010f7c] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f80] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f84] 4eb9 0001 222c            jsr        bios
[00010f8a] 588f                      addq.l     #4,a7
[00010f8c] 3ebc 0062                 move.w     #$0062,(a7)
[00010f90] 3f3c 0002                 move.w     #$0002,-(a7)
[00010f94] 3f3c 0003                 move.w     #$0003,-(a7)
[00010f98] 4eb9 0001 222c            jsr        bios
[00010f9e] 588f                      addq.l     #4,a7
[00010fa0] 4257                      clr.w      (a7)
[00010fa2] 3f3c 0002                 move.w     #$0002,-(a7)
[00010fa6] 3f3c 0003                 move.w     #$0003,-(a7)
[00010faa] 4eb9 0001 222c            jsr        bios
[00010fb0] 588f                      addq.l     #4,a7
[00010fb2] 3ebc 001b                 move.w     #$001B,(a7)
[00010fb6] 3f3c 0002                 move.w     #$0002,-(a7)
[00010fba] 3f3c 0003                 move.w     #$0003,-(a7)
[00010fbe] 4eb9 0001 222c            jsr        bios
[00010fc4] 588f                      addq.l     #4,a7
[00010fc6] 3ebc 0063                 move.w     #$0063,(a7)
[00010fca] 3f3c 0002                 move.w     #$0002,-(a7)
[00010fce] 3f3c 0003                 move.w     #$0003,-(a7)
[00010fd2] 4eb9 0001 222c            jsr        bios
[00010fd8] 588f                      addq.l     #4,a7
[00010fda] 3ebc 0001                 move.w     #$0001,(a7)
[00010fde] 3f3c 0002                 move.w     #$0002,-(a7)
[00010fe2] 3f3c 0003                 move.w     #$0003,-(a7)
[00010fe6] 4eb9 0001 222c            jsr        bios
[00010fec] 588f                      addq.l     #4,a7
[00010fee] 6000 02e0                 bra        $000112D0
[00010ff2] 2eb9 0001 2b60            move.l     strstart,(a7)
[00010ff8] 2f3c 0001 2a15            move.l     #$00012A15,-(a7)
[00010ffe] 6100 02da                 bsr        streq
[00011002] 588f                      addq.l     #4,a7
[00011004] 4a40                      tst.w      d0
[00011006] 672c                      beq.s      $00011034
[00011008] 3ebc 001b                 move.w     #$001B,(a7)
[0001100c] 3f3c 0002                 move.w     #$0002,-(a7)
[00011010] 3f3c 0003                 move.w     #$0003,-(a7)
[00011014] 4eb9 0001 222c            jsr        bios
[0001101a] 588f                      addq.l     #4,a7
[0001101c] 3ebc 0064                 move.w     #$0064,(a7)
[00011020] 3f3c 0002                 move.w     #$0002,-(a7)
[00011024] 3f3c 0003                 move.w     #$0003,-(a7)
[00011028] 4eb9 0001 222c            jsr        bios
[0001102e] 588f                      addq.l     #4,a7
[00011030] 6000 029e                 bra        $000112D0
[00011034] 2eb9 0001 2b60            move.l     strstart,(a7)
[0001103a] 2f3c 0001 2a1a            move.l     #$00012A1A,-(a7)
[00011040] 6100 0298                 bsr        streq
[00011044] 588f                      addq.l     #4,a7
[00011046] 4a40                      tst.w      d0
[00011048] 672c                      beq.s      $00011076
[0001104a] 3ebc 001b                 move.w     #$001B,(a7)
[0001104e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011052] 3f3c 0003                 move.w     #$0003,-(a7)
[00011056] 4eb9 0001 222c            jsr        bios
[0001105c] 588f                      addq.l     #4,a7
[0001105e] 3ebc 0065                 move.w     #$0065,(a7)
[00011062] 3f3c 0002                 move.w     #$0002,-(a7)
[00011066] 3f3c 0003                 move.w     #$0003,-(a7)
[0001106a] 4eb9 0001 222c            jsr        bios
[00011070] 588f                      addq.l     #4,a7
[00011072] 6000 025c                 bra        $000112D0
[00011076] 2eb9 0001 2b60            move.l     strstart,(a7)
[0001107c] 2f3c 0001 2a1f            move.l     #$00012A1F,-(a7)
[00011082] 6100 0256                 bsr        streq
[00011086] 588f                      addq.l     #4,a7
[00011088] 4a40                      tst.w      d0
[0001108a] 672c                      beq.s      $000110B8
[0001108c] 3ebc 001b                 move.w     #$001B,(a7)
[00011090] 3f3c 0002                 move.w     #$0002,-(a7)
[00011094] 3f3c 0003                 move.w     #$0003,-(a7)
[00011098] 4eb9 0001 222c            jsr        bios
[0001109e] 588f                      addq.l     #4,a7
[000110a0] 3ebc 0066                 move.w     #$0066,(a7)
[000110a4] 3f3c 0002                 move.w     #$0002,-(a7)
[000110a8] 3f3c 0003                 move.w     #$0003,-(a7)
[000110ac] 4eb9 0001 222c            jsr        bios
[000110b2] 588f                      addq.l     #4,a7
[000110b4] 6000 021a                 bra        $000112D0
[000110b8] 2eb9 0001 2b60            move.l     strstart,(a7)
[000110be] 2f3c 0001 2a25            move.l     #$00012A25,-(a7)
[000110c4] 6100 0214                 bsr        streq
[000110c8] 588f                      addq.l     #4,a7
[000110ca] 4a40                      tst.w      d0
[000110cc] 672c                      beq.s      $000110FA
[000110ce] 3ebc 001b                 move.w     #$001B,(a7)
[000110d2] 3f3c 0002                 move.w     #$0002,-(a7)
[000110d6] 3f3c 0003                 move.w     #$0003,-(a7)
[000110da] 4eb9 0001 222c            jsr        bios
[000110e0] 588f                      addq.l     #4,a7
[000110e2] 3ebc 006a                 move.w     #$006A,(a7)
[000110e6] 3f3c 0002                 move.w     #$0002,-(a7)
[000110ea] 3f3c 0003                 move.w     #$0003,-(a7)
[000110ee] 4eb9 0001 222c            jsr        bios
[000110f4] 588f                      addq.l     #4,a7
[000110f6] 6000 01d8                 bra        $000112D0
[000110fa] 2eb9 0001 2b60            move.l     strstart,(a7)
[00011100] 2f3c 0001 2a2c            move.l     #$00012A2C,-(a7)
[00011106] 6100 01d2                 bsr        streq
[0001110a] 588f                      addq.l     #4,a7
[0001110c] 4a40                      tst.w      d0
[0001110e] 672c                      beq.s      $0001113C
[00011110] 3ebc 001b                 move.w     #$001B,(a7)
[00011114] 3f3c 0002                 move.w     #$0002,-(a7)
[00011118] 3f3c 0003                 move.w     #$0003,-(a7)
[0001111c] 4eb9 0001 222c            jsr        bios
[00011122] 588f                      addq.l     #4,a7
[00011124] 3ebc 006b                 move.w     #$006B,(a7)
[00011128] 3f3c 0002                 move.w     #$0002,-(a7)
[0001112c] 3f3c 0003                 move.w     #$0003,-(a7)
[00011130] 4eb9 0001 222c            jsr        bios
[00011136] 588f                      addq.l     #4,a7
[00011138] 6000 0196                 bra        $000112D0
[0001113c] 2eb9 0001 2b60            move.l     strstart,(a7)
[00011142] 2f3c 0001 2a33            move.l     #$00012A33,-(a7)
[00011148] 6100 0190                 bsr        streq
[0001114c] 588f                      addq.l     #4,a7
[0001114e] 4a40                      tst.w      d0
[00011150] 672c                      beq.s      $0001117E
[00011152] 3ebc 001b                 move.w     #$001B,(a7)
[00011156] 3f3c 0002                 move.w     #$0002,-(a7)
[0001115a] 3f3c 0003                 move.w     #$0003,-(a7)
[0001115e] 4eb9 0001 222c            jsr        bios
[00011164] 588f                      addq.l     #4,a7
[00011166] 3ebc 006c                 move.w     #$006C,(a7)
[0001116a] 3f3c 0002                 move.w     #$0002,-(a7)
[0001116e] 3f3c 0003                 move.w     #$0003,-(a7)
[00011172] 4eb9 0001 222c            jsr        bios
[00011178] 588f                      addq.l     #4,a7
[0001117a] 6000 0154                 bra        $000112D0
[0001117e] 2eb9 0001 2b60            move.l     strstart,(a7)
[00011184] 2f3c 0001 2a3a            move.l     #$00012A3A,-(a7)
[0001118a] 6100 014e                 bsr        streq
[0001118e] 588f                      addq.l     #4,a7
[00011190] 4a40                      tst.w      d0
[00011192] 672c                      beq.s      $000111C0
[00011194] 3ebc 001b                 move.w     #$001B,(a7)
[00011198] 3f3c 0002                 move.w     #$0002,-(a7)
[0001119c] 3f3c 0003                 move.w     #$0003,-(a7)
[000111a0] 4eb9 0001 222c            jsr        bios
[000111a6] 588f                      addq.l     #4,a7
[000111a8] 3ebc 006f                 move.w     #$006F,(a7)
[000111ac] 3f3c 0002                 move.w     #$0002,-(a7)
[000111b0] 3f3c 0003                 move.w     #$0003,-(a7)
[000111b4] 4eb9 0001 222c            jsr        bios
[000111ba] 588f                      addq.l     #4,a7
[000111bc] 6000 0112                 bra        $000112D0
[000111c0] 2eb9 0001 2b60            move.l     strstart,(a7)
[000111c6] 2f3c 0001 2a42            move.l     #$00012A42,-(a7)
[000111cc] 6100 010c                 bsr        streq
[000111d0] 588f                      addq.l     #4,a7
[000111d2] 4a40                      tst.w      d0
[000111d4] 672c                      beq.s      $00011202
[000111d6] 3ebc 001b                 move.w     #$001B,(a7)
[000111da] 3f3c 0002                 move.w     #$0002,-(a7)
[000111de] 3f3c 0003                 move.w     #$0003,-(a7)
[000111e2] 4eb9 0001 222c            jsr        bios
[000111e8] 588f                      addq.l     #4,a7
[000111ea] 3ebc 0070                 move.w     #$0070,(a7)
[000111ee] 3f3c 0002                 move.w     #$0002,-(a7)
[000111f2] 3f3c 0003                 move.w     #$0003,-(a7)
[000111f6] 4eb9 0001 222c            jsr        bios
[000111fc] 588f                      addq.l     #4,a7
[000111fe] 6000 00d0                 bra        $000112D0
[00011202] 2eb9 0001 2b60            move.l     strstart,(a7)
[00011208] 2f3c 0001 2a48            move.l     #$00012A48,-(a7)
[0001120e] 6100 00ca                 bsr        streq
[00011212] 588f                      addq.l     #4,a7
[00011214] 4a40                      tst.w      d0
[00011216] 672c                      beq.s      $00011244
[00011218] 3ebc 001b                 move.w     #$001B,(a7)
[0001121c] 3f3c 0002                 move.w     #$0002,-(a7)
[00011220] 3f3c 0003                 move.w     #$0003,-(a7)
[00011224] 4eb9 0001 222c            jsr        bios
[0001122a] 588f                      addq.l     #4,a7
[0001122c] 3ebc 0071                 move.w     #$0071,(a7)
[00011230] 3f3c 0002                 move.w     #$0002,-(a7)
[00011234] 3f3c 0003                 move.w     #$0003,-(a7)
[00011238] 4eb9 0001 222c            jsr        bios
[0001123e] 588f                      addq.l     #4,a7
[00011240] 6000 008e                 bra        $000112D0
[00011244] 2eb9 0001 2b60            move.l     strstart,(a7)
[0001124a] 2f3c 0001 2a4f            move.l     #$00012A4F,-(a7)
[00011250] 6100 0088                 bsr        streq
[00011254] 588f                      addq.l     #4,a7
[00011256] 4a40                      tst.w      d0
[00011258] 672a                      beq.s      $00011284
[0001125a] 3ebc 001b                 move.w     #$001B,(a7)
[0001125e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011262] 3f3c 0003                 move.w     #$0003,-(a7)
[00011266] 4eb9 0001 222c            jsr        bios
[0001126c] 588f                      addq.l     #4,a7
[0001126e] 3ebc 0076                 move.w     #$0076,(a7)
[00011272] 3f3c 0002                 move.w     #$0002,-(a7)
[00011276] 3f3c 0003                 move.w     #$0003,-(a7)
[0001127a] 4eb9 0001 222c            jsr        bios
[00011280] 588f                      addq.l     #4,a7
[00011282] 604c                      bra.s      $000112D0
[00011284] 2eb9 0001 2b60            move.l     strstart,(a7)
[0001128a] 2f3c 0001 2a56            move.l     #$00012A56,-(a7)
[00011290] 6148                      bsr.s      streq
[00011292] 588f                      addq.l     #4,a7
[00011294] 4a40                      tst.w      d0
[00011296] 672a                      beq.s      $000112C2
[00011298] 3ebc 001b                 move.w     #$001B,(a7)
[0001129c] 3f3c 0002                 move.w     #$0002,-(a7)
[000112a0] 3f3c 0003                 move.w     #$0003,-(a7)
[000112a4] 4eb9 0001 222c            jsr        bios
[000112aa] 588f                      addq.l     #4,a7
[000112ac] 3ebc 0077                 move.w     #$0077,(a7)
[000112b0] 3f3c 0002                 move.w     #$0002,-(a7)
[000112b4] 3f3c 0003                 move.w     #$0003,-(a7)
[000112b8] 4eb9 0001 222c            jsr        bios
[000112be] 588f                      addq.l     #4,a7
[000112c0] 600e                      bra.s      $000112D0
[000112c2] 4279 0001 2b58            clr.w      cont_parse
[000112c8] 33fc fffa 0001 2b5a       move.w     #$FFFA,vt52_err
[000112d0] 4a9f                      tst.l      (a7)+
[000112d2] 4cdf 20c0                 movem.l    (a7)+,d6-d7/a5
[000112d6] 4e5e                      unlk       a6
[000112d8] 4e75                      rts

streq:
[000112da] 4e56 0000                 link       a6,#0
[000112de] 48e7 030c                 movem.l    d6-d7/a4-a5,-(a7)
[000112e2] 2a6e 0008                 movea.l    8(a6),a5
[000112e6] 286e 000c                 movea.l    12(a6),a4
[000112ea] 7e01                      moveq.l    #1,d7
[000112ec] 600c                      bra.s      $000112FA
[000112ee] b90d                      cmpm.b     (a5)+,(a4)+
[000112f0] 6704                      beq.s      $000112F6
[000112f2] 4240                      clr.w      d0
[000112f4] 6002                      bra.s      $000112F8
[000112f6] 7001                      moveq.l    #1,d0
[000112f8] 3e00                      move.w     d0,d7
[000112fa] 4a47                      tst.w      d7
[000112fc] 6704                      beq.s      $00011302
[000112fe] 4a15                      tst.b      (a5)
[00011300] 66ec                      bne.s      $000112EE
[00011302] 3007                      move.w     d7,d0
[00011304] 4a9f                      tst.l      (a7)+
[00011306] 4cdf 3080                 movem.l    (a7)+,d7/a4-a5
[0001130a] 4e5e                      unlk       a6
[0001130c] 4e75                      rts
flush_strbuf:
[0001130e] 4e56 0000                 link       a6,#0
[00011312] 48e7 0304                 movem.l    d6-d7/a5,-(a7)
[00011316] 2a7c 0001 2ab6            movea.l    #strbuf,a5
[0001131c] 6012                      bra.s      $00011330
[0001131e] 3e87                      move.w     d7,(a7)
[00011320] 3f3c 0005                 move.w     #$0005,-(a7)
[00011324] 3f3c 0003                 move.w     #$0003,-(a7)
[00011328] 4eb9 0001 222c            jsr        bios
[0001132e] 588f                      addq.l     #4,a7
[00011330] 1e1d                      move.b     (a5)+,d7
[00011332] 4887                      ext.w      d7
[00011334] 66e8                      bne.s      $0001131E
[00011336] 4a9f                      tst.l      (a7)+
[00011338] 4cdf 2080                 movem.l    (a7)+,d7/a5
[0001133c] 4e5e                      unlk       a6
[0001133e] 4e75                      rts
prt_hex:
[00011340] 4e56 0000                 link       a6,#0
[00011344] 48e7 3f04                 movem.l    d2-d7/a5,-(a7)
[00011348] 4a6e 000c                 tst.w      12(a6)
[0001134c] 6f00 00f8                 ble        $00011446
[00011350] 2a6e 0008                 movea.l    8(a6),a5
[00011354] 3e2e 000c                 move.w     12(a6),d7
[00011358] e347                      asl.w      #1,d7
[0001135a] 4a6e 000e                 tst.w      14(a6)
[0001135e] 6e06                      bgt.s      $00011366
[00011360] 4243                      clr.w      d3
[00011362] 3803                      move.w     d3,d4
[00011364] 6008                      bra.s      $0001136E
[00011366] 3807                      move.w     d7,d4
[00011368] 986e 000e                 sub.w      14(a6),d4
[0001136c] 7601                      moveq.l    #1,d3
[0001136e] 6018                      bra.s      $00011388
[00011370] 536e 000e                 subq.w     #1,14(a6)
[00011374] 3ebc 0020                 move.w     #$0020,(a7)
[00011378] 3f3c 0002                 move.w     #$0002,-(a7)
[0001137c] 3f3c 0003                 move.w     #$0003,-(a7)
[00011380] 4eb9 0001 222c            jsr        bios
[00011386] 588f                      addq.l     #4,a7
[00011388] be6e 000e                 cmp.w      14(a6),d7
[0001138c] 6de2                      blt.s      $00011370
[0001138e] 6000 0084                 bra        $00011414
[00011392] 0807 0000                 btst       #0,d7
[00011396] 670e                      beq.s      $000113A6
[00011398] 1c1d                      move.b     (a5)+,d6
[0001139a] 4886                      ext.w      d6
[0001139c] 3a06                      move.w     d6,d5
[0001139e] e845                      asr.w      #4,d5
[000113a0] ca7c 000f                 and.w      #$000F,d5
[000113a4] 6006                      bra.s      $000113AC
[000113a6] 3a06                      move.w     d6,d5
[000113a8] ca7c 000f                 and.w      #$000F,d5
[000113ac] 4a45                      tst.w      d5
[000113ae] 6706                      beq.s      $000113B6
[000113b0] 4a44                      tst.w      d4
[000113b2] 6e00 006e                 bgt.w      $00011422
[000113b6] 3004                      move.w     d4,d0
[000113b8] 5344                      subq.w     #1,d4
[000113ba] 4a40                      tst.w      d0
[000113bc] 6e56                      bgt.s      $00011414
[000113be] 4a43                      tst.w      d3
[000113c0] 6704                      beq.s      $000113C6
[000113c2] 4a45                      tst.w      d5
[000113c4] 6704                      beq.s      $000113CA
[000113c6] 4240                      clr.w      d0
[000113c8] 6002                      bra.s      $000113CC
[000113ca] 7001                      moveq.l    #1,d0
[000113cc] 3600                      move.w     d0,d3
[000113ce] ba7c 0009                 cmp.w      #$0009,d5
[000113d2] 6f08                      ble.s      $000113DC
[000113d4] 3005                      move.w     d5,d0
[000113d6] d07c 0037                 add.w      #$0037,d0
[000113da] 6006                      bra.s      $000113E2
[000113dc] 3005                      move.w     d5,d0
[000113de] d07c 0030                 add.w      #$0030,d0
[000113e2] 3a00                      move.w     d0,d5
[000113e4] 4a43                      tst.w      d3
[000113e6] 671a                      beq.s      $00011402
[000113e8] 4a47                      tst.w      d7
[000113ea] 6716                      beq.s      $00011402
[000113ec] 3ebc 0020                 move.w     #$0020,(a7)
[000113f0] 3f3c 0002                 move.w     #$0002,-(a7)
[000113f4] 3f3c 0003                 move.w     #$0003,-(a7)
[000113f8] 4eb9 0001 222c            jsr        bios
[000113fe] 588f                      addq.l     #4,a7
[00011400] 6012                      bra.s      $00011414
[00011402] 3e85                      move.w     d5,(a7)
[00011404] 3f3c 0002                 move.w     #$0002,-(a7)
[00011408] 3f3c 0003                 move.w     #$0003,-(a7)
[0001140c] 4eb9 0001 222c            jsr        bios
[00011412] 588f                      addq.l     #4,a7
[00011414] 3007                      move.w     d7,d0
[00011416] 5347                      subq.w     #1,d7
[00011418] 4a40                      tst.w      d0
[0001141a] 6600 ff76                 bne        $00011392
[0001141e] 4240                      clr.w      d0
[00011420] 6024                      bra.s      $00011446
[00011422] 6014                      bra.s      $00011438
[00011424] 3ebc 002a                 move.w     #$002A,(a7)
[00011428] 3f3c 0002                 move.w     #$0002,-(a7)
[0001142c] 3f3c 0003                 move.w     #$0003,-(a7)
[00011430] 4eb9 0001 222c            jsr        bios
[00011436] 588f                      addq.l     #4,a7
[00011438] 302e 000e                 move.w     14(a6),d0
[0001143c] 536e 000e                 subq.w     #1,14(a6)
[00011440] 4a40                      tst.w      d0
[00011442] 6ee0                      bgt.s      $00011424
[00011444] 70ff                      moveq.l    #-1,d0
[00011446] 4a9f                      tst.l      (a7)+
[00011448] 4cdf 20f8                 movem.l    (a7)+,d3-d7/a5
[0001144c] 4e5e                      unlk       a6
[0001144e] 4e75                      rts
prt_bin:
[00011450] 4e56 0000                 link       a6,#0
[00011454] 48e7 0704                 movem.l    d5-d7/a5,-(a7)
[00011458] 4a6e 000c                 tst.w      12(a6)
[0001145c] 6f52                      ble.s      $000114B0
[0001145e] 2a6e 0008                 movea.l    8(a6),a5
[00011462] 6040                      bra.s      $000114A4
[00011464] 1e1d                      move.b     (a5)+,d7
[00011466] 4887                      ext.w      d7
[00011468] 3c3c 0080                 move.w     #$0080,d6
[0001146c] 6032                      bra.s      $000114A0
[0001146e] 3007                      move.w     d7,d0
[00011470] c046                      and.w      d6,d0
[00011472] 6716                      beq.s      $0001148A
[00011474] 3ebc 0049                 move.w     #$0049,(a7)
[00011478] 3f3c 0002                 move.w     #$0002,-(a7)
[0001147c] 3f3c 0003                 move.w     #$0003,-(a7)
[00011480] 4eb9 0001 222c            jsr        bios
[00011486] 588f                      addq.l     #4,a7
[00011488] 6014                      bra.s      $0001149E
[0001148a] 3ebc 0030                 move.w     #$0030,(a7)
[0001148e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011492] 3f3c 0003                 move.w     #$0003,-(a7)
[00011496] 4eb9 0001 222c            jsr        bios
[0001149c] 588f                      addq.l     #4,a7
[0001149e] e246                      asr.w      #1,d6
[000114a0] 4a46                      tst.w      d6
[000114a2] 66ca                      bne.s      $0001146E
[000114a4] 302e 000c                 move.w     12(a6),d0
[000114a8] 536e 000c                 subq.w     #1,12(a6)
[000114ac] 4a40                      tst.w      d0
[000114ae] 66b4                      bne.s      $00011464
[000114b0] 4a9f                      tst.l      (a7)+
[000114b2] 4cdf 20c0                 movem.l    (a7)+,d6-d7/a5
[000114b6] 4e5e                      unlk       a6
[000114b8] 4e75                      rts
inp_field:
[000114ba] 4e56 0000                 link       a6,#0
[000114be] 48e7 0300                 movem.l    d6-d7,-(a7)
[000114c2] 202e 0008                 move.l     8(a6),d0
[000114c6] b0ae 000c                 cmp.l      12(a6),d0
[000114ca] 6506                      bcs.s      $000114D2
[000114cc] 70ff                      moveq.l    #-1,d0
[000114ce] 6000 00a8                 bra        $00011578
[000114d2] 23ee 0008 0001 2b60       move.l     8(a6),strstart
[000114da] 23ee 000c 0001 2b64       move.l     12(a6),strend
[000114e2] 206e 0008                 movea.l    8(a6),a0
[000114e6] 1e10                      move.b     (a0),d7
[000114e8] 1007                      move.b     d7,d0
[000114ea] 4880                      ext.w      d0
[000114ec] 6000 0074                 bra.w      $00011562
case /
[000114f0] 3ebc 000d                 move.w     #$000D,(a7)
[000114f4] 3f3c 0002                 move.w     #$0002,-(a7)
[000114f8] 3f3c 0003                 move.w     #$0003,-(a7)
[000114fc] 4eb9 0001 222c            jsr        bios
[00011502] 588f                      addq.l     #4,a7
[00011504] 3ebc 000a                 move.w     #$000A,(a7)
[00011508] 3f3c 0002                 move.w     #$0002,-(a7)
[0001150c] 3f3c 0003                 move.w     #$0003,-(a7)
[00011510] 4eb9 0001 222c            jsr        bios
[00011516] 588f                      addq.l     #4,a7
[00011518] 6000 005e                 bra.w      $00011578
case '\''
case '`'
[0001151c] 6100 f344                 bsr        rawprint
[00011520] 6056                      bra.s      $00011578
case '?'
[00011522] 33fc 0001 0001 28da       move.w     #$0001,$000128DA
[0001152a] 604c                      bra.s      $00011578
case '!'
[0001152c] 4279 0001 28da            clr.w      $000128DA
[00011532] 6044                      bra.s      $00011578
case 's'
[00011534] 614c                      bsr.s      inp_str
[00011536] 6040                      bra.s      $00011578
case 'l'
[00011538] 6100 0116                 bsr        inp_long
[0001153c] 603a                      bra.s      $00011578
case 'i'
[0001153e] 6100 0090                 bsr        inp_int
[00011542] 6034                      bra.s      $00011578
case 'e'
case 'f'
[00011544] 6100 018a                 bsr        inp_float
[00011548] 602e                      bra.s      $00011578
case 'v'
[0001154a] 6100 f618                 bsr        vt52_seq
[0001154e] 6028                      bra.s      $00011578
[00011550] 4279 0001 2b58            clr.w      cont_parse
[00011556] 33fc ffff 0001 2b5a       move.w     #$FFFF,vt52_err
[0001155e] 6018                      bra.s      $00011578
[00011560] 6016                      bra.s      $00011578
[00011562] 48c0                      ext.l      d0
[00011564] 207c 0001 293c            movea.l    #$0001293C,a0
[0001156a] 720b                      moveq.l    #11,d1
[0001156c] b098                      cmp.l      (a0)+,d0
[0001156e] 57c9 fffc                 dbeq       d1,$0001156C
[00011572] 2068 002c                 movea.l    44(a0),a0
[00011576] 4ed0                      jmp        (a0)
[00011578] 4a9f                      tst.l      (a7)+
[0001157a] 4cdf 0080                 movem.l    (a7)+,d7
[0001157e] 4e5e                      unlk       a6
[00011580] 4e75                      rts

inp_str:
[00011582] 4e56 fffc                 link       a6,#-4
[00011586] 48e7 010c                 movem.l    d7/a4-a5,-(a7)
[0001158a] 2a79 0001 2b5c            movea.l    args,a5
[00011590] 58b9 0001 2b5c            addq.l     #4,args
[00011596] 2855                      movea.l    (a5),a4
[00011598] 2e8e                      move.l     a6,(a7)
[0001159a] 5997                      subq.l     #4,(a7)
[0001159c] 2f0e                      move.l     a6,-(a7)
[0001159e] 5597                      subq.l     #2,(a7)
[000115a0] 6100 f204                 bsr        $000107A6
[000115a4] 588f                      addq.l     #4,a7
[000115a6] 4a6e fffe                 tst.w      -2(a6)
[000115aa] 6c06                      bge.s      $000115B2
[000115ac] 3d7c 0001 fffe            move.w     #$0001,-2(a6)
[000115b2] 3eae fffe                 move.w     -2(a6),(a7)
[000115b6] 2f0c                      move.l     a4,-(a7)
[000115b8] 6100 028c                 bsr        $00011846
[000115bc] 588f                      addq.l     #4,a7
[000115be] 33fc ffff 0001 28d8       move.w     #$FFFF,$000128D8
[000115c6] 4a9f                      tst.l      (a7)+
[000115c8] 4cdf 3000                 movem.l    (a7)+,a4-a5
[000115cc] 4e5e                      unlk       a6
[000115ce] 4e75                      rts

inp_int:
[000115d0] 4e56 fffe                 link       a6,#-2
[000115d4] 48e7 0104                 movem.l    d7/a5,-(a7)
[000115d8] 2a79 0001 2b5c            movea.l    args,a5
[000115de] 58b9 0001 2b5c            addq.l     #4,args
[000115e4] 2e8e                      move.l     a6,(a7)
[000115e6] 5597                      subq.l     #2,(a7)
[000115e8] 6100 0164                 bsr        inp_item
[000115ec] 2e95                      move.l     (a5),(a7)
[000115ee] 203c 0001 2ab6            move.l     #strbuf,d0
[000115f4] 322e fffe                 move.w     -2(a6),d1
[000115f8] 48c1                      ext.l      d1
[000115fa] d081                      add.l      d1,d0
[000115fc] 2f00                      move.l     d0,-(a7)
[000115fe] 4eb9 0001 2012            jsr        $00012012
[00011604] 588f                      addq.l     #4,a7
[00011606] 4a40                      tst.w      d0
[00011608] 6c3c                      bge.s      $00011646
[0001160a] 3ebc 000d                 move.w     #$000D,(a7)
[0001160e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011612] 3f3c 0003                 move.w     #$0003,-(a7)
[00011616] 4eb9 0001 222c            jsr        bios
[0001161c] 588f                      addq.l     #4,a7
[0001161e] 3ebc 000a                 move.w     #$000A,(a7)
[00011622] 3f3c 0002                 move.w     #$0002,-(a7)
[00011626] 3f3c 0003                 move.w     #$0003,-(a7)
[0001162a] 4eb9 0001 222c            jsr        bios
[00011630] 588f                      addq.l     #4,a7
[00011632] 2ebc 0001 2a5e            move.l     #$00012A5E,(a7)
[00011638] 6100 03a0                 bsr        $000119DA
[0001163c] 33fc ffff 0001 28d8       move.w     #$FFFF,$000128D8
[00011644] 609e                      bra.s      $000115E4
[00011646] 4a9f                      tst.l      (a7)+
[00011648] 4cdf 2000                 movem.l    (a7)+,a5
[0001164c] 4e5e                      unlk       a6
[0001164e] 4e75                      rts
inp_long
[00011650] 4e56 fffe                 link       a6,#-2
[00011654] 48e7 0104                 movem.l    d7/a5,-(a7)
[00011658] 2a79 0001 2b5c            movea.l    args,a5
[0001165e] 58b9 0001 2b5c            addq.l     #4,args
[00011664] 2e8e                      move.l     a6,(a7)
[00011666] 5597                      subq.l     #2,(a7)
[00011668] 6100 00e4                 bsr        inp_item
[0001166c] 2e95                      move.l     (a5),(a7)
[0001166e] 203c 0001 2ab6            move.l     #strbuf,d0
[00011674] 322e fffe                 move.w     -2(a6),d1
[00011678] 48c1                      ext.l      d1
[0001167a] d081                      add.l      d1,d0
[0001167c] 2f00                      move.l     d0,-(a7)
[0001167e] 4eb9 0001 1e80            jsr        $00011E80
[00011684] 588f                      addq.l     #4,a7
[00011686] 4a40                      tst.w      d0
[00011688] 6c3c                      bge.s      $000116C6
[0001168a] 3ebc 000d                 move.w     #$000D,(a7)
[0001168e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011692] 3f3c 0003                 move.w     #$0003,-(a7)
[00011696] 4eb9 0001 222c            jsr        bios
[0001169c] 588f                      addq.l     #4,a7
[0001169e] 3ebc 000a                 move.w     #$000A,(a7)
[000116a2] 3f3c 0002                 move.w     #$0002,-(a7)
[000116a6] 3f3c 0003                 move.w     #$0003,-(a7)
[000116aa] 4eb9 0001 222c            jsr        bios
[000116b0] 588f                      addq.l     #4,a7
[000116b2] 2ebc 0001 2a79            move.l     #$00012A79,(a7)
[000116b8] 6100 0320                 bsr        $000119DA
[000116bc] 33fc ffff 0001 28d8       move.w     #$FFFF,$000128D8
[000116c4] 609e                      bra.s      $00011664
[000116c6] 4a9f                      tst.l      (a7)+
[000116c8] 4cdf 2000                 movem.l    (a7)+,a5
[000116cc] 4e5e                      unlk       a6
[000116ce] 4e75                      rts
inp_float:
[000116d0] 4e56 fffe                 link       a6,#-2
[000116d4] 48e7 0104                 movem.l    d7/a5,-(a7)
[000116d8] 2a79 0001 2b5c            movea.l    args,a5
[000116de] 58b9 0001 2b5c            addq.l     #4,args
[000116e4] 2e8e                      move.l     a6,(a7)
[000116e6] 5597                      subq.l     #2,(a7)
[000116e8] 6164                      bsr.s      inp_item
[000116ea] 2e95                      move.l     (a5),(a7)
[000116ec] 203c 0001 2ab6            move.l     #strbuf,d0
[000116f2] 322e fffe                 move.w     -2(a6),d1
[000116f6] 48c1                      ext.l      d1
[000116f8] d081                      add.l      d1,d0
[000116fa] 2f00                      move.l     d0,-(a7)
[000116fc] 4eb9 0001 2040            jsr        atofloat
[00011702] 588f                      addq.l     #4,a7
[00011704] 4a40                      tst.w      d0
[00011706] 6c3c                      bge.s      $00011744
[00011708] 3ebc 000d                 move.w     #$000D,(a7)
[0001170c] 3f3c 0002                 move.w     #$0002,-(a7)
[00011710] 3f3c 0003                 move.w     #$0003,-(a7)
[00011714] 4eb9 0001 222c            jsr        bios
[0001171a] 588f                      addq.l     #4,a7
[0001171c] 3ebc 000a                 move.w     #$000A,(a7)
[00011720] 3f3c 0002                 move.w     #$0002,-(a7)
[00011724] 3f3c 0003                 move.w     #$0003,-(a7)
[00011728] 4eb9 0001 222c            jsr        bios
[0001172e] 588f                      addq.l     #4,a7
[00011730] 2ebc 0001 2a91            move.l     #$00012A91,(a7)
[00011736] 6100 02a2                 bsr        $000119DA
[0001173a] 33fc ffff 0001 28d8       move.w     #$FFFF,$000128D8
[00011742] 60a0                      bra.s      $000116E4
[00011744] 4a9f                      tst.l      (a7)+
[00011746] 4cdf 2000                 movem.l    (a7)+,a5
[0001174a] 4e5e                      unlk       a6
[0001174c] 4e75                      rts
inp_item:
[0001174e] 4e56 0000                 link       a6,#0
[00011752] 48e7 0300                 movem.l    d6-d7,-(a7)
[00011756] 4a79 0001 28d8            tst.w      $000128D8
[0001175c] 6d48                      blt.s      $000117A6
[0001175e] 3079 0001 28d8            movea.w    $000128D8,a0
[00011764] 227c 0001 2ab6            movea.l    #strbuf,a1
[0001176a] 4a30 9800                 tst.b      0(a0,a1.l)
[0001176e] 6606                      bne.s      $00011776
[00011770] 4279 0001 28d8            clr.w      $000128D8
[00011776] 4a79 0001 28d8            tst.w      $000128D8
[0001177c] 6628                      bne.s      $000117A6
[0001177e] 3ebc 000d                 move.w     #$000D,(a7)
[00011782] 3f3c 0002                 move.w     #$0002,-(a7)
[00011786] 3f3c 0003                 move.w     #$0003,-(a7)
[0001178a] 4eb9 0001 222c            jsr        bios
[00011790] 588f                      addq.l     #4,a7
[00011792] 3ebc 000a                 move.w     #$000A,(a7)
[00011796] 3f3c 0002                 move.w     #$0002,-(a7)
[0001179a] 3f3c 0003                 move.w     #$0003,-(a7)
[0001179e] 4eb9 0001 222c            jsr        bios
[000117a4] 588f                      addq.l     #4,a7
[000117a6] 4a79 0001 28d8            tst.w      $000128D8
[000117ac] 6e16                      bgt.s      $000117C4
[000117ae] 3ebc 00a0                 move.w     #$00A0,(a7)
[000117b2] 2f3c 0001 2ab6            move.l     #strbuf,-(a7)
[000117b8] 6100 008c                 bsr        $00011846
[000117bc] 588f                      addq.l     #4,a7
[000117be] 4279 0001 28d8            clr.w      $000128D8
[000117c4] 6006                      bra.s      $000117CC
[000117c6] 5279 0001 28d8            addq.w     #1,$000128D8
[000117cc] 3079 0001 28d8            movea.w    $000128D8,a0
[000117d2] 227c 0001 2ab6            movea.l    #strbuf,a1
[000117d8] 1030 9800                 move.b     0(a0,a1.l),d0
[000117dc] 4880                      ext.w      d0
[000117de] 3e00                      move.w     d0,d7
[000117e0] be7c 0020                 cmp.w      #$0020,d7
[000117e4] 67e0                      beq.s      $000117C6
[000117e6] 4a47                      tst.w      d7
[000117e8] 6700 ff6c                 beq        $00011756
[000117ec] 206e 0008                 movea.l    8(a6),a0
[000117f0] 30b9 0001 28d8            move.w     $000128D8,(a0)
[000117f6] 6006                      bra.s      $000117FE
[000117f8] 5279 0001 28d8            addq.w     #1,$000128D8
[000117fe] 3079 0001 28d8            movea.w    $000128D8,a0
[00011804] 227c 0001 2ab6            movea.l    #strbuf,a1
[0001180a] 1030 9800                 move.b     0(a0,a1.l),d0
[0001180e] 4880                      ext.w      d0
[00011810] 3e00                      move.w     d0,d7
[00011812] 6706                      beq.s      $0001181A
[00011814] be7c 002c                 cmp.w      #$002C,d7
[00011818] 66de                      bne.s      $000117F8
[0001181a] 4a47                      tst.w      d7
[0001181c] 6718                      beq.s      $00011836
[0001181e] 207c 0001 2ab6            movea.l    #strbuf,a0
[00011824] 3279 0001 28d8            movea.w    $000128D8,a1
[0001182a] d1c9                      adda.l     a1,a0
[0001182c] 4210                      clr.b      (a0)
[0001182e] 5279 0001 28d8            addq.w     #1,$000128D8
[00011834] 6006                      bra.s      $0001183C
[00011836] 4279 0001 28d8            clr.w      $000128D8
[0001183c] 4a9f                      tst.l      (a7)+
[0001183e] 4cdf 0080                 movem.l    (a7)+,d7
[00011842] 4e5e                      unlk       a6
[00011844] 4e75                      rts
readstr:
[00011846] 4e56 0000                 link       a6,#0
[0001184a] 48e7 0704                 movem.l    d5-d7/a5,-(a7)
[0001184e] 2a6e 0008                 movea.l    8(a6),a5
[00011852] 4246                      clr.w      d6
[00011854] 4a79 0001 28da            tst.w      $000128DA
[0001185a] 6714                      beq.s      $00011870
[0001185c] 3ebc 003f                 move.w     #$003F,(a7)
[00011860] 3f3c 0002                 move.w     #$0002,-(a7)
[00011864] 3f3c 0003                 move.w     #$0003,-(a7)
[00011868] 4eb9 0001 222c            jsr        bios
[0001186e] 588f                      addq.l     #4,a7
[00011870] 6000 0098                 bra        $0001190A
[00011874] be7c 0008                 cmp.w      #$0008,d7
[00011878] 666c                      bne.s      $000118E6
[0001187a] 4a46                      tst.w      d6
[0001187c] 6f66                      ble.s      $000118E4
[0001187e] 5346                      subq.w     #1,d6
[00011880] 3ebc 001b                 move.w     #$001B,(a7)
[00011884] 3f3c 0002                 move.w     #$0002,-(a7)
[00011888] 3f3c 0003                 move.w     #$0003,-(a7)
[0001188c] 4eb9 0001 222c            jsr        bios
[00011892] 588f                      addq.l     #4,a7
[00011894] 3ebc 0044                 move.w     #$0044,(a7)
[00011898] 3f3c 0002                 move.w     #$0002,-(a7)
[0001189c] 3f3c 0003                 move.w     #$0003,-(a7)
[000118a0] 4eb9 0001 222c            jsr        bios
[000118a6] 588f                      addq.l     #4,a7
[000118a8] 3ebc 0020                 move.w     #$0020,(a7)
[000118ac] 3f3c 0002                 move.w     #$0002,-(a7)
[000118b0] 3f3c 0003                 move.w     #$0003,-(a7)
[000118b4] 4eb9 0001 222c            jsr        bios
[000118ba] 588f                      addq.l     #4,a7
[000118bc] 3ebc 001b                 move.w     #$001B,(a7)
[000118c0] 3f3c 0002                 move.w     #$0002,-(a7)
[000118c4] 3f3c 0003                 move.w     #$0003,-(a7)
[000118c8] 4eb9 0001 222c            jsr        bios
[000118ce] 588f                      addq.l     #4,a7
[000118d0] 3ebc 0044                 move.w     #$0044,(a7)
[000118d4] 3f3c 0002                 move.w     #$0002,-(a7)
[000118d8] 3f3c 0003                 move.w     #$0003,-(a7)
[000118dc] 4eb9 0001 222c            jsr        bios
[000118e2] 588f                      addq.l     #4,a7
[000118e4] 6024                      bra.s      $0001190A
[000118e6] bc6e 000c                 cmp.w      12(a6),d6
[000118ea] 6c1e                      bge.s      $0001190A
[000118ec] 3007                      move.w     d7,d0
[000118ee] 224d                      movea.l    a5,a1
[000118f0] 3446                      movea.w    d6,a2
[000118f2] d3ca                      adda.l     a2,a1
[000118f4] 1280                      move.b     d0,(a1)
[000118f6] 5246                      addq.w     #1,d6
[000118f8] 3e87                      move.w     d7,(a7)
[000118fa] 3f3c 0005                 move.w     #$0005,-(a7)
[000118fe] 3f3c 0003                 move.w     #$0003,-(a7)
[00011902] 4eb9 0001 222c            jsr        bios
[00011908] 588f                      addq.l     #4,a7
[0001190a] 3ebc 0002                 move.w     #$0002,(a7)
[0001190e] 3f3c 0002                 move.w     #$0002,-(a7)
[00011912] 4eb9 0001 222c            jsr        bios
[00011918] 548f                      addq.l     #2,a7
[0001191a] 3e00                      move.w     d0,d7
[0001191c] be7c 000d                 cmp.w      #$000D,d7
[00011920] 6600 ff52                 bne        $00011874
[00011924] 204d                      movea.l    a5,a0
[00011926] 3246                      movea.w    d6,a1
[00011928] d1c9                      adda.l     a1,a0
[0001192a] 4210                      clr.b      (a0)
[0001192c] 3006                      move.w     d6,d0
[0001192e] 4a9f                      tst.l      (a7)+
[00011930] 4cdf 20c0                 movem.l    (a7)+,d6-d7/a5
[00011934] 4e5e                      unlk       a6
[00011936] 4e75                      rts
printerr:
[00011938] 4e56 0000                 link       a6,#0
[0001193c] 48e7 0104                 movem.l    d7/a5,-(a7)
[00011940] 3039 0001 2b5a            move.w     vt52_err,d0
[00011946] 6034                      bra.s      $0001197C
[00011948] 2a7c 0001 2856            movea.l    #$00012856,a5
[0001194e] 6044                      bra.s      $00011994
[00011950] 2a7c 0001 2866            movea.l    #$00012866,a5
[00011956] 603c                      bra.s      $00011994
[00011958] 2a7c 0001 2880            movea.l    #$00012880,a5
[0001195e] 6034                      bra.s      $00011994
[00011960] 2a7c 0001 2892            movea.l    #$00012892,a5
[00011966] 602c                      bra.s      $00011994
[00011968] 2a7c 0001 28ac            movea.l    #$000128AC,a5
[0001196e] 6024                      bra.s      $00011994
[00011970] 2a7c 0001 28c0            movea.l    #$000128C0,a5
[00011976] 601c                      bra.s      $00011994
[00011978] 6056                      bra.s      $000119D0
[0001197a] 6018                      bra.s      $00011994
[0001197c] 907c fffa                 sub.w      #$FFFA,d0
[00011980] b07c 0005                 cmp.w      #$0005,d0
[00011984] 62f2                      bhi.s      $00011978
[00011986] e540                      asl.w      #2,d0
[00011988] 3040                      movea.w    d0,a0
[0001198a] d1fc 0001 299c            adda.l     #$0001299C,a0
[00011990] 2050                      movea.l    (a0),a0
[00011992] 4ed0                      jmp        (a0)
[00011994] 2ebc 0001 2aaa            move.l     #$00012AAA,(a7)
[0001199a] 613e                      bsr.s      $000119DA
[0001199c] 2e8d                      move.l     a5,(a7)
[0001199e] 613a                      bsr.s      $000119DA
[000119a0] 2ebc 0001 2aaf            move.l     #$00012AAF,(a7)
[000119a6] 6132                      bsr.s      $000119DA
[000119a8] 3ebc 000d                 move.w     #$000D,(a7)
[000119ac] 3f3c 0002                 move.w     #$0002,-(a7)
[000119b0] 3f3c 0003                 move.w     #$0003,-(a7)
[000119b4] 4eb9 0001 222c            jsr        bios
[000119ba] 588f                      addq.l     #4,a7
[000119bc] 3ebc 000a                 move.w     #$000A,(a7)
[000119c0] 3f3c 0002                 move.w     #$0002,-(a7)
[000119c4] 3f3c 0003                 move.w     #$0003,-(a7)
[000119c8] 4eb9 0001 222c            jsr        bios
[000119ce] 588f                      addq.l     #4,a7
[000119d0] 4a9f                      tst.l      (a7)+
[000119d2] 4cdf 2000                 movem.l    (a7)+,a5
[000119d6] 4e5e                      unlk       a6
[000119d8] 4e75                      rts
printstr:
[000119da] 4e56 fffc                 link       a6,#-4
[000119de] 601e                      bra.s      $000119FE
[000119e0] 206e 0008                 movea.l    8(a6),a0
[000119e4] 1010                      move.b     (a0),d0
[000119e6] 4880                      ext.w      d0
[000119e8] 3e80                      move.w     d0,(a7)
[000119ea] 3f3c 0002                 move.w     #$0002,-(a7)
[000119ee] 3f3c 0003                 move.w     #$0003,-(a7)
[000119f2] 4eb9 0001 222c            jsr        bios
[000119f8] 588f                      addq.l     #4,a7
[000119fa] 52ae 0008                 addq.l     #1,8(a6)
[000119fe] 206e 0008                 movea.l    8(a6),a0
[00011a02] 4a10                      tst.b      (a0)
[00011a04] 66da                      bne.s      $000119E0
[00011a06] 4e5e                      unlk       a6
[00011a08] 4e75                      rts

	dc.w 0x23f9
	dc.b 'cio2.o',0,0

fmt_int:
[00011a14] 4e56 fffc                 link       a6,#-4
[00011a18] 2eae 000c                 move.l     12(a6),(a7)
[00011a1c] 3f2e 000a                 move.w     10(a6),-(a7)
[00011a20] 306e 0008                 movea.w    8(a6),a0
[00011a24] 2f08                      move.l     a0,-(a7)
[00011a26] 6106                      bsr.s      fmt_long
[00011a28] 5c8f                      addq.l     #6,a7
[00011a2a] 4e5e                      unlk       a6
[00011a2c] 4e75                      rts

fmt_long:
[00011a2e] 4e56 0000                 link       a6,#0
[00011a32] 48e7 0f04                 movem.l    d4-d7/a5,-(a7)
[00011a36] 4246                      clr.w      d6
[00011a38] 2e2e 0008                 move.l     8(a6),d7
[00011a3c] 4a87                      tst.l      d7
[00011a3e] 6d04                      blt.s      $00011A44
[00011a40] 4240                      clr.w      d0
[00011a42] 6002                      bra.s      $00011A46
[00011a44] 7001                      moveq.l    #1,d0
[00011a46] 3a00                      move.w     d0,d5
[00011a48] 6706                      beq.s      $00011A50
[00011a4a] 2007                      move.l     d7,d0
[00011a4c] 4480                      neg.l      d0
[00011a4e] 2e00                      move.l     d0,d7
[00011a50] 2a7c 0001 2bb9            movea.l    #$00012BB9,a5
[00011a56] 2f3c 0000 000a            move.l     #$0000000A,-(a7)
[00011a5c] 2f07                      move.l     d7,-(a7)
[00011a5e] 4eb9 0001 282a            jsr        lrem
[00011a64] 508f                      addq.l     #8,a7
[00011a66] d0bc 0000 0030            add.l      #$00000030,d0
[00011a6c] 1b00                      move.b     d0,-(a5)
[00011a6e] 2f3c 0000 000a            move.l     #$0000000A,-(a7)
[00011a74] 2f07                      move.l     d7o,-(a7)
[00011a76] 4eb9 0001 2782            jsr        ldiv
[00011a7c] 508f                      addq.l     #8,a7
[00011a7e] 2e00                      move.l     d0,d7
[00011a80] 5246                      addq.w     #1,d6
[00011a82] 4a87                      tst.l      d7
[00011a84] 66d0                      bne.s      $00011A56
[00011a86] 4a45                      tst.w      d5
[00011a88] 6706                      beq.s      $00011A90
[00011a8a] 5246                      addq.w     #1,d6
[00011a8c] 1b3c 002d                 move.b     #$2D,-(a5)
[00011a90] 4a6e 000c                 tst.w      12(a6)
[00011a94] 6c04                      bge.s      $00011A9A
[00011a96] 3d46 000c                 move.w     d6,12(a6)
[00011a9a] 0c6e 0050 000c            cmpi.w     #$0050,12(a6)
[00011aa0] 6f06                      ble.s      $00011AA8
[00011aa2] 3d7c 0050 000c            move.w     #$0050,12(a6)
[00011aa8] 3eae 000c                 move.w     12(a6),(a7)
[00011aac] 3f06                      move.w     d6,-(a7)
[00011aae] 2f2e 000e                 move.l     14(a6),-(a7)
[00011ab2] 6100 036a                 bsr        $00011E1E
[00011ab6] 5c8f                      addq.l     #6,a7
[00011ab8] 3006                      move.w     d6,d0
[00011aba] 4a9f                      tst.l      (a7)+
[00011abc] 4cdf 20e0                 movem.l    (a7)+,d5-d7/a5
[00011ac0] 4e5e                      unlk       a6
[00011ac2] 4e75                      rts

fmt_fixed:
[00011ac4] 4e56 fff8                 link       a6,#-8
[00011ac8] 48e7 0f04                 movem.l    d4-d7/a5,-(a7)
[00011acc] 2a6e 0010                 movea.l    16(a6),a5
[00011ad0] 2f2e 0008                 move.l     8(a6),-(a7)
[00011ad4] 4240                      clr.w      d0
[00011ad6] 48c0                      ext.l      d0
[00011ad8] 2f00                      move.l     d0,-(a7)
[00011ada] 4eb9 0001 22d2            jsr        fpltof
[00011ae0] 588f                      addq.l     #4,a7
[00011ae2] 2f00                      move.l     d0,-(a7)
[00011ae4] 4eb9 0001 2280            jsr        fpcmp
[00011aea] 508f                      addq.l     #8,a7
[00011aec] 6e04                      bgt.s      $00011AF2
[00011aee] 4240                      clr.w      d0
[00011af0] 6002                      bra.s      $00011AF4
[00011af2] 7001                      moveq.l    #1,d0
[00011af4] 3d40 fffa                 move.w     d0,-6(a6)
[00011af8] 4a6e 000e                 tst.w      14(a6)
[00011afc] 6c06                      bge.s      $00011B04
[00011afe] 3d7c 0002 000e            move.w     #$0002,14(a6)
[00011b04] 4a6e fffa                 tst.w      -6(a6)
[00011b08] 6710                      beq.s      $00011B1A
[00011b0a] 2f2e 0008                 move.l     8(a6),-(a7)
[00011b0e] 4eb9 0001 2428            jsr        fpneg
[00011b14] 588f                      addq.l     #4,a7
[00011b16] 2d40 0008                 move.l     d0,8(a6)
[00011b1a] 700a                      moveq.l    #10,d0
[00011b1c] 48c0                      ext.l      d0
[00011b1e] 2f00                      move.l     d0,-(a7)
[00011b20] 4eb9 0001 22d2            jsr        fpltof
[00011b26] 588f                      addq.l     #4,a7
[00011b28] 2d40 fffc                 move.l     d0,-4(a6)
[00011b2c] 7e01                      moveq.l    #1,d7
[00011b2e] 6018                      bra.s      $00011B48
[00011b30] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[00011b36] 2f2e fffc                 move.l     -4(a6),-(a7)
[00011b3a] 4eb9 0001 23fe            jsr        fpmul
[00011b40] 508f                      addq.l     #8,a7
[00011b42] 2d40 fffc                 move.l     d0,-4(a6)
[00011b46] 5247                      addq.w     #1,d7
[00011b48] 2f2e 0008                 move.l     8(a6),-(a7)
[00011b4c] 2f2e fffc                 move.l     -4(a6),-(a7)
[00011b50] 4eb9 0001 2280            jsr        fpcmp
[00011b56] 508f                      addq.l     #8,a7
[00011b58] 6e06                      bgt.s      $00011B60
[00011b5a] be7c 0064                 cmp.w      #$0064,d7
[00011b5e] 6dd0                      blt.s      $00011B30
[00011b60] 3a07                      move.w     d7,d5
[00011b62] da6e 000e                 add.w      14(a6),d5
[00011b66] da6e fffa                 add.w      -6(a6),d5
[00011b6a] 5245                      addq.w     #1,d5
[00011b6c] 4a6e 000c                 tst.w      12(a6)
[00011b70] 6c04                      bge.s      $00011B76
[00011b72] 3d45 000c                 move.w     d5,12(a6)
[00011b76] 3c2e 000c                 move.w     12(a6),d6
[00011b7a] 9c45                      sub.w      d5,d6
[00011b7c] 4a46                      tst.w      d6
[00011b7e] 6d00 00fa                 blt        $00011C7A
[00011b82] 6004                      bra.s      $00011B88
[00011b84] 1afc 0020                 move.b     #$20,(a5)+
[00011b88] 3006                      move.w     d6,d0
[00011b8a] 5346                      subq.w     #1,d6
[00011b8c] 4a40                      tst.w      d0
[00011b8e] 66f4                      bne.s      $00011B84
[00011b90] 4a6e fffa                 tst.w      -6(a6)
[00011b94] 6704                      beq.s      $00011B9A
[00011b96] 1afc 002d                 move.b     #$2D,(a5)+
[00011b9a] 606e                      bra.s      $00011C0A
[00011b9c] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[00011ba2] 2f2e fffc                 move.l     -4(a6),-(a7)
[00011ba6] 4eb9 0001 22a8            jsr        fpdiv
[00011bac] 508f                      addq.l     #8,a7
[00011bae] 2d40 fffc                 move.l     d0,-4(a6)
[00011bb2] 2f2e fffc                 move.l     -4(a6),-(a7)
[00011bb6] 2f2e 0008                 move.l     8(a6),-(a7)
[00011bba] 4eb9 0001 22a8            jsr        fpdiv
[00011bc0] 508f                      addq.l     #8,a7
[00011bc2] 2f00                      move.l     d0,-(a7)
[00011bc4] 4eb9 0001 236c            jsr        lpftol
[00011bca] 588f                      addq.l     #4,a7
[00011bcc] 3d40 fff8                 move.w     d0,-8(a6)
[00011bd0] 302e fff8                 move.w     -8(a6),d0
[00011bd4] d07c 0030                 add.w      #$0030,d0
[00011bd8] 1ac0                      move.b     d0,(a5)+
[00011bda] 2f2e fffc                 move.l     -4(a6),-(a7)
[00011bde] 302e fff8                 move.w     -8(a6),d0
[00011be2] 48c0                      ext.l      d0
[00011be4] 2f00                      move.l     d0,-(a7)
[00011be6] 4eb9 0001 22d2            jsr        fpltof
[00011bec] 588f                      addq.l     #4,a7
[00011bee] 2f00                      move.l     d0,-(a7)
[00011bf0] 4eb9 0001 23fe            jsr        fpmul
[00011bf6] 508f                      addq.l     #8,a7
[00011bf8] 2f00                      move.l     d0,-(a7)
[00011bfa] 2f2e 0008                 move.l     8(a6),-(a7)
[00011bfe] 4eb9 0001 244e            jsr        fpsub
[00011c04] 508f                      addq.l     #8,a7
[00011c06] 2d40 0008                 move.l     d0,8(a6)
[00011c0a] 3007                      move.w     d7,d0
[00011c0c] 5347                      subq.w     #1,d7
[00011c0e] 4a40                      tst.w      d0
[00011c10] 668a                      bne.s      $00011B9C
[00011c12] 1afc 002e                 move.b     #$2E,(a5)+
[00011c16] 6050                      bra.s      $00011C68
[00011c18] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[00011c1e] 2f2e 0008                 move.l     8(a6),-(a7)
[00011c22] 4eb9 0001 23fe            jsr        fpmul
[00011c28] 508f                      addq.l     #8,a7
[00011c2a] 2d40 0008                 move.l     d0,8(a6)
[00011c2e] 2f00                      move.l     d0,-(a7)
[00011c30] 4eb9 0001 236c            jsr        lpftol
[00011c36] 588f                      addq.l     #4,a7
[00011c38] 3d40 fff8                 move.w     d0,-8(a6)
[00011c3c] 302e fff8                 move.w     -8(a6),d0
[00011c40] d07c 0030                 add.w      #$0030,d0
[00011c44] 1ac0                      move.b     d0,(a5)+
[00011c46] 302e fff8                 move.w     -8(a6),d0
[00011c4a] 48c0                      ext.l      d0
[00011c4c] 2f00                      move.l     d0,-(a7)
[00011c4e] 4eb9 0001 22d2            jsr        fpltof
[00011c54] 588f                      addq.l     #4,a7
[00011c56] 2f00                      move.l     d0,-(a7)
[00011c58] 2f2e 0008                 move.l     8(a6),-(a7)
[00011c5c] 4eb9 0001 244e            jsr        fpsub
[00011c62] 508f                      addq.l     #8,a7
[00011c64] 2d40 0008                 move.l     d0,8(a6)
[00011c68] 302e 000e                 move.w     14(a6),d0
[00011c6c] 536e 000e                 subq.w     #1,14(a6)
[00011c70] 4a40                      tst.w      d0
[00011c72] 66a4                      bne.s      $00011C18
[00011c74] 421d                      clr.b      (a5)+
[00011c76] 3005                      move.w     d5,d0
[00011c78] 6016                      bra.s      $00011C90
[00011c7a] 6004                      bra.s      $00011C80
[00011c7c] 1afc 002a                 move.b     #$2A,(a5)+
[00011c80] 302e 000c                 move.w     12(a6),d0
[00011c84] 536e 000c                 subq.w     #1,12(a6)
[00011c88] 4a40                      tst.w      d0
[00011c8a] 6ef0                      bgt.s      $00011C7C
[00011c8c] 421d                      clr.b      (a5)+
[00011c8e] 70ff                      moveq.l    #-1,d0
[00011c90] 4a9f                      tst.l      (a7)+
[00011c92] 4cdf 20e0                 movem.l    (a7)+,d5-d7/a5
[00011c96] 4e5e                      unlk       a6
[00011c98] 4e75                      rts

fmt_float:
[00011c9a] 4e56 fffa                 link       a6,#-6
[00011c9e] 48e7 0f04                 movem.l    d4-d7/a5,-(a7)
[00011ca2] 4246                      clr.w      d6
[00011ca4] 4a6e 000c                 tst.w      12(a6)
[00011ca8] 6c06                      bge.s      $00011CB0
[00011caa] 3d7c 0001 000c            move.w     #$0001,12(a6)
[00011cb0] 4a6e 000e                 tst.w      14(a6)
[00011cb4] 6c04                      bge.s      $00011CBA
[00011cb6] 426e 000e                 clr.w      14(a6)
[00011cba] 2d7c 8000 0041 fffa       move.l     #$80000041,-6(a6)
[00011cc2] 3a2e 000c                 move.w     12(a6),d5
[00011cc6] 6016                      bra.s      $00011CDE
[00011cc8] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[00011cce] 2f2e fffa                 move.l     -6(a6),-(a7)
[00011cd2] 4eb9 0001 23fe            jsr        fpmul
[00011cd8] 508f                      addq.l     #8,a7
[00011cda] 2d40 fffa                 move.l     d0,-6(a6)
[00011cde] 3005                      move.w     d5,d0
[00011ce0] 5345                      subq.w     #1,d5
[00011ce2] 4a40                      tst.w      d0
[00011ce4] 66e2                      bne.s      $00011CC8
[00011ce6] 2f2e 0008                 move.l     8(a6),-(a7)
[00011cea] 4240                      clr.w      d0
[00011cec] 48c0                      ext.l      d0
[00011cee] 2f00                      move.l     d0,-(a7)
[00011cf0] 4eb9 0001 22d2            jsr        fpltof
[00011cf6] 588f                      addq.l     #4,a7
[00011cf8] 2f00                      move.l     d0,-(a7)
[00011cfa] 4eb9 0001 2280            jsr        fpcmp
[00011d00] 508f                      addq.l     #8,a7
[00011d02] 6e04                      bgt.s      $00011D08
[00011d04] 4240                      clr.w      d0
[00011d06] 6002                      bra.s      $00011D0A
[00011d08] 7001                      moveq.l    #1,d0
[00011d0a] 3e00                      move.w     d0,d7
[00011d0c] 6710                      beq.s      $00011D1E
[00011d0e] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d12] 4eb9 0001 2428            jsr        fpneg
[00011d18] 588f                      addq.l     #4,a7
[00011d1a] 2d40 0008                 move.l     d0,8(a6)
[00011d1e] 2f3c 0000 0000            move.l     #$00000000,-(a7)
[00011d24] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d28] 4eb9 0001 2280            jsr        fpcmp
[00011d2e] 508f                      addq.l     #8,a7
[00011d30] 6758                      beq.s      $00011D8A
[00011d32] 6018                      bra.s      $00011D4C
[00011d34] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[00011d3a] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d3e] 4eb9 0001 23fe            jsr        fpmul
[00011d44] 508f                      addq.l     #8,a7
[00011d46] 2d40 0008                 move.l     d0,8(a6)
[00011d4a] 5346                      subq.w     #1,d6
[00011d4c] 2f2e fffa                 move.l     -6(a6),-(a7)
[00011d50] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d54] 4eb9 0001 2280            jsr        fpcmp
[00011d5a] 508f                      addq.l     #8,a7
[00011d5c] 6dd6                      blt.s      $00011D34
[00011d5e] 6018                      bra.s      $00011D78
[00011d60] 2f3c cccc cd3d            move.l     #$CCCCCD3D,-(a7)
[00011d66] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d6a] 4eb9 0001 23fe            jsr        fpmul
[00011d70] 508f                      addq.l     #8,a7
[00011d72] 2d40 0008                 move.l     d0,8(a6)
[00011d76] 5246                      addq.w     #1,d6
[00011d78] 2f2e fffa                 move.l     -6(a6),-(a7)
[00011d7c] 2f2e 0008                 move.l     8(a6),-(a7)
[00011d80] 4eb9 0001 2280            jsr        fpcmp
[00011d86] 508f                      addq.l     #8,a7
[00011d88] 6ed6                      bgt.s      $00011D60
[00011d8a] 302e 000c                 move.w     12(a6),d0
[00011d8e] d06e 000e                 add.w      14(a6),d0
[00011d92] 5440                      addq.w     #2,d0
[00011d94] 3d40 fffe                 move.w     d0,-2(a6)
[00011d98] 2eae 0010                 move.l     16(a6),(a7)
[00011d9c] 3f2e 000e                 move.w     14(a6),-(a7)
[00011da0] 3f2e fffe                 move.w     -2(a6),-(a7)
[00011da4] 2f2e 0008                 move.l     8(a6),-(a7)
[00011da8] 6100 fd1a                 bsr        fmt_fixed
[00011dac] 508f                      addq.l     #8,a7
[00011dae] 4a47                      tst.w      d7
[00011db0] 670a                      beq.s      $00011DBC
[00011db2] 206e 0010                 movea.l    16(a6),a0
[00011db6] 10bc 002d                 move.b     #$2D,(a0)
[00011dba] 600e                      bra.s      $00011DCA
[00011dbc] 4a6e 000c                 tst.w      12(a6)
[00011dc0] 6608                      bne.s      $00011DCA
[00011dc2] 206e 0010                 movea.l    16(a6),a0
[00011dc6] 10bc 0020                 move.b     #$20,(a0)
[00011dca] 2a6e 0010                 movea.l    16(a6),a5
[00011dce] 302e fffe                 move.w     -2(a6),d0
[00011dd2] 48c0                      ext.l      d0
[00011dd4] dbc0                      adda.l     d0,a5
[00011dd6] 1afc 0065                 move.b     #$65,(a5)+
[00011dda] 4a46                      tst.w      d6
[00011ddc] 6c0c                      bge.s      $00011DEA
[00011dde] 3006                      move.w     d6,d0
[00011de0] 4440                      neg.w      d0
[00011de2] 3c00                      move.w     d0,d6
[00011de4] 1afc 002d                 move.b     #$2D,(a5)+
[00011de8] 6004                      bra.s      $00011DEE
[00011dea] 1afc 002b                 move.b     #$2B,(a5)+
[00011dee] 3006                      move.w     d6,d0
[00011df0] 48c0                      ext.l      d0
[00011df2] 81fc 000a                 divs.w     #$000A,d0
[00011df6] d07c 0030                 add.w      #$0030,d0
[00011dfa] 1ac0                      move.b     d0,(a5)+
[00011dfc] 3006                      move.w     d6,d0
[00011dfe] 48c0                      ext.l      d0
[00011e00] 81fc 000a                 divs.w     #$000A,d0
[00011e04] 4840                      swap       d0
[00011e06] d07c 0030                 add.w      #$0030,d0
[00011e0a] 1ac0                      move.b     d0,(a5)+
[00011e0c] 421d                      clr.b      (a5)+
[00011e0e] 302e fffe                 move.w     -2(a6),d0
[00011e12] 5840                      addq.w     #4,d0
[00011e14] 4a9f                      tst.l      (a7)+
[00011e16] 4cdf 20e0                 movem.l    (a7)+,d5-d7/a5
[00011e1a] 4e5e                      unlk       a6
[00011e1c] 4e75                      rts
copytmp:
[00011e1e] 4e56 0000                 link       a6,#0
[00011e22] 48e7 070c                 movem.l    d5-d7/a4-a5,-(a7)
[00011e26] 3e2e 000c                 move.w     12(a6),d7
[00011e2a] 3c2e 000e                 move.w     14(a6),d6
[00011e2e] 9c47                      sub.w      d7,d6
[00011e30] 2a7c 0001 2bb9            movea.l    #$00012BB9,a5
[00011e36] 286e 0008                 movea.l    8(a6),a4
[00011e3a] 302e 000e                 move.w     14(a6),d0
[00011e3e] 48c0                      ext.l      d0
[00011e40] d9c0                      adda.l     d0,a4
[00011e42] 4214                      clr.b      (a4)
[00011e44] 4a46                      tst.w      d6
[00011e46] 6d1c                      blt.s      $00011E64
[00011e48] 6002                      bra.s      $00011E4C
[00011e4a] 1925                      move.b     -(a5),-(a4)
[00011e4c] 3007                      move.w     d7,d0
[00011e4e] 5347                      subq.w     #1,d7
[00011e50] 4a40                      tst.w      d0
[00011e52] 6ef6                      bgt.s      $00011E4A
[00011e54] 6004                      bra.s      $00011E5A
[00011e56] 193c 0020                 move.b     #$20,-(a4)
[00011e5a] 3006                      move.w     d6,d0
[00011e5c] 5346                      subq.w     #1,d6
[00011e5e] 4a40                      tst.w      d0
[00011e60] 6ef4                      bgt.s      $00011E56
[00011e62] 6012                      bra.s      $00011E76
[00011e64] 6004                      bra.s      $00011E6A
[00011e66] 193c 002a                 move.b     #$2A,-(a4)
[00011e6a] 302e 000e                 move.w     14(a6),d0
[00011e6e] 536e 000e                 subq.w     #1,14(a6)
[00011e72] 4a40                      tst.w      d0
[00011e74] 6ef0                      bgt.s      $00011E66
[00011e76] 4a9f                      tst.l      (a7)+
[00011e78] 4cdf 30c0                 movem.l    (a7)+,d6-d7/a4-a5
[00011e7c] 4e5e                      unlk       a6
[00011e7e] 4e75                      rts
atolong:
[00011e80] 4e56 fffa                 link       a6,#-6
[00011e84] 48e7 3f04                 movem.l    d2-d7/a5,-(a7)
[00011e88] 2a6e 0008                 movea.l    8(a6),a5
[00011e8c] 4287                      clr.l      d7
[00011e8e] 1c1d                      move.b     (a5)+,d6
[00011e90] 4886                      ext.w      d6
[00011e92] bc7c 0020                 cmp.w      #$0020,d6
[00011e96] 67f6                      beq.s      $00011E8E
[00011e98] bc7c 002d                 cmp.w      #$002D,d6
[00011e9c] 6704                      beq.s      $00011EA2
[00011e9e] 4240                      clr.w      d0
[00011ea0] 6002                      bra.s      $00011EA4
[00011ea2] 7001                      moveq.l    #1,d0
[00011ea4] 3a00                      move.w     d0,d5
[00011ea6] bc7c 0068                 cmp.w      #$0068,d6
[00011eaa] 6704                      beq.s      $00011EB0
[00011eac] 4240                      clr.w      d0
[00011eae] 6002                      bra.s      $00011EB2
[00011eb0] 7001                      moveq.l    #1,d0
[00011eb2] 3800                      move.w     d0,d4
[00011eb4] bc7c 0062                 cmp.w      #$0062,d6
[00011eb8] 6704                      beq.s      $00011EBE
[00011eba] 4240                      clr.w      d0
[00011ebc] 6002                      bra.s      $00011EC0
[00011ebe] 7001                      moveq.l    #1,d0
[00011ec0] 3600                      move.w     d0,d3
[00011ec2] 4a44                      tst.w      d4
[00011ec4] 660e                      bne.s      $00011ED4
[00011ec6] 4a43                      tst.w      d3
[00011ec8] 660a                      bne.s      $00011ED4
[00011eca] 4a45                      tst.w      d5
[00011ecc] 6606                      bne.s      $00011ED4
[00011ece] bc7c 002b                 cmp.w      #$002B,d6
[00011ed2] 660a                      bne.s      $00011EDE
[00011ed4] 1c1d                      move.b     (a5)+,d6
[00011ed6] 4886                      ext.w      d6
[00011ed8] bc7c 0020                 cmp.w      #$0020,d6
[00011edc] 67f6                      beq.s      $00011ED4
[00011ede] 4a46                      tst.w      d6
[00011ee0] 6606                      bne.s      $00011EE8
[00011ee2] 70ff                      moveq.l    #-1,d0
[00011ee4] 6000 0122                 bra        $00012008
[00011ee8] 4a43                      tst.w      d3
[00011eea] 6738                      beq.s      $00011F24
[00011eec] 6010                      bra.s      $00011EFE
[00011eee] e387                      asl.l      #1,d7
[00011ef0] 3006                      move.w     d6,d0
[00011ef2] d07c ffd0                 add.w      #$FFD0,d0
[00011ef6] 48c0                      ext.l      d0
[00011ef8] 8e80                      or.l       d0,d7
[00011efa] 1c1d                      move.b     (a5)+,d6
[00011efc] 4886                      ext.w      d6
[00011efe] bc7c 0030                 cmp.w      #$0030,d6
[00011f02] 67ea                      beq.s      $00011EEE
[00011f04] bc7c 0031                 cmp.w      #$0031,d6
[00011f08] 67e4                      beq.s      $00011EEE
[00011f0a] bc7c 002c                 cmp.w      #$002C,d6
[00011f0e] 6710                      beq.s      $00011F20
[00011f10] bc7c 0020                 cmp.w      #$0020,d6
[00011f14] 670a                      beq.s      $00011F20
[00011f16] 4a46                      tst.w      d6
[00011f18] 6706                      beq.s      $00011F20
[00011f1a] 70fe                      moveq.l    #-2,d0
[00011f1c] 6000 00ea                 bra        $00012008
[00011f20] 6000 00de                 bra        $00012000
[00011f24] 4a44                      tst.w      d4
[00011f26] 6700 008a                 beq        $00011FB2
[00011f2a] 6028                      bra.s      $00011F54
[00011f2c] 4a6e fffe                 tst.w      -2(a6)
[00011f30] 6706                      beq.s      $00011F38
[00011f32] 9c7c 0030                 sub.w      #$0030,d6
[00011f36] 6010                      bra.s      $00011F48
[00011f38] 4a6e fffc                 tst.w      -4(a6)
[00011f3c] 6706                      beq.s      $00011F44
[00011f3e] 9c7c 0037                 sub.w      #$0037,d6
[00011f42] 6004                      bra.s      $00011F48
[00011f44] 9c7c 0057                 sub.w      #$0057,d6
[00011f48] e987                      asl.l      #4,d7
[00011f4a] 3006                      move.w     d6,d0
[00011f4c] 48c0                      ext.l      d0
[00011f4e] de80                      add.l      d0,d7
[00011f50] 1c1d                      move.b     (a5)+,d6
[00011f52] 4886                      ext.w      d6
[00011f54] bc7c 0030                 cmp.w      #$0030,d6
[00011f58] 6d06                      blt.s      $00011F60
[00011f5a] bc7c 0039                 cmp.w      #$0039,d6
[00011f5e] 6f04                      ble.s      $00011F64
[00011f60] 4240                      clr.w      d0
[00011f62] 6002                      bra.s      $00011F66
[00011f64] 7001                      moveq.l    #1,d0
[00011f66] 3d40 fffe                 move.w     d0,-2(a6)
[00011f6a] 66c0                      bne.s      $00011F2C
[00011f6c] bc7c 0041                 cmp.w      #$0041,d6
[00011f70] 6d06                      blt.s      $00011F78
[00011f72] bc7c 0046                 cmp.w      #$0046,d6
[00011f76] 6f04                      ble.s      $00011F7C
[00011f78] 4240                      clr.w      d0
[00011f7a] 6002                      bra.s      $00011F7E
[00011f7c] 7001                      moveq.l    #1,d0
[00011f7e] 3d40 fffc                 move.w     d0,-4(a6)
[00011f82] 66a8                      bne.s      $00011F2C
[00011f84] bc7c 0061                 cmp.w      #$0061,d6
[00011f88] 6d06                      blt.s      $00011F90
[00011f8a] bc7c 0066                 cmp.w      #$0066,d6
[00011f8e] 6f04                      ble.s      $00011F94
[00011f90] 4240                      clr.w      d0
[00011f92] 6002                      bra.s      $00011F96
[00011f94] 7001                      moveq.l    #1,d0
[00011f96] 3d40 fffa                 move.w     d0,-6(a6)
[00011f9a] 6690                      bne.s      $00011F2C
[00011f9c] bc7c 002c                 cmp.w      #$002C,d6
[00011fa0] 670e                      beq.s      $00011FB0
[00011fa2] bc7c 0020                 cmp.w      #$0020,d6
[00011fa6] 6708                      beq.s      $00011FB0
[00011fa8] 4a46                      tst.w      d6
[00011faa] 6704                      beq.s      $00011FB0
[00011fac] 70fe                      moveq.l    #-2,d0
[00011fae] 6058                      bra.s      $00012008
[00011fb0] 604e                      bra.s      $00012000
[00011fb2] 6022                      bra.s      $00011FD6
[00011fb4] 2f3c 0000 000a            move.l     #$0000000A,-(a7)
[00011fba] 2f07                      move.l     d7,-(a7)
[00011fbc] 4eb9 0001 2724            jsr        lmul
[00011fc2] 508f                      addq.l     #8,a7
[00011fc4] 2e00                      move.l     d0,d7
[00011fc6] 3006                      move.w     d6,d0
[00011fc8] 48c0                      ext.l      d0
[00011fca] de80                      add.l      d0,d7
[00011fcc] debc ffff ffd0            add.l      #$FFFFFFD0,d7
[00011fd2] 1c1d                      move.b     (a5)+,d6
[00011fd4] 4886                      ext.w      d6
[00011fd6] bc7c 0030                 cmp.w      #$0030,d6
[00011fda] 6d06                      blt.s      $00011FE2
[00011fdc] bc7c 0039                 cmp.w      #$0039,d6
[00011fe0] 6fd2                      ble.s      $00011FB4
[00011fe2] bc7c 002c                 cmp.w      #$002C,d6
[00011fe6] 670e                      beq.s      $00011FF6
[00011fe8] bc7c 0020                 cmp.w      #$0020,d6
[00011fec] 6708                      beq.s      $00011FF6
[00011fee] 4a46                      tst.w      d6
[00011ff0] 6704                      beq.s      $00011FF6
[00011ff2] 70fe                      moveq.l    #-2,d0
[00011ff4] 6012                      bra.s      $00012008
[00011ff6] 4a45                      tst.w      d5
[00011ff8] 6706                      beq.s      $00012000
[00011ffa] 2007                      move.l     d7,d0
[00011ffc] 4480                      neg.l      d0
[00011ffe] 2e00                      move.l     d0,d7
[00012000] 206e 000c                 movea.l    12(a6),a0
[00012004] 2087                      move.l     d7,(a0)
[00012006] 7001                      moveq.l    #1,d0
[00012008] 4a9f                      tst.l      (a7)+
[0001200a] 4cdf 20f8                 movem.l    (a7)+,d3-d7/a5
[0001200e] 4e5e                      unlk       a6
[00012010] 4e75                      rts
atoint:
[00012012] 4e56 fffc                 link       a6,#-4
[00012016] 48e7 0300                 movem.l    d6-d7,-(a7)
[0001201a] 2e8e                      move.l     a6,(a7)
[0001201c] 5997                      subq.l     #4,(a7)
[0001201e] 2f2e 0008                 move.l     8(a6),-(a7)
[00012022] 6100 fe5c                 bsr        $00011E80
[00012026] 588f                      addq.l     #4,a7
[00012028] 3e00                      move.w     d0,d7
[0001202a] 202e fffc                 move.l     -4(a6),d0
[0001202e] 226e 000c                 movea.l    12(a6),a1
[00012032] 3280                      move.w     d0,(a1)
[00012034] 3007                      move.w     d7,d0
[00012036] 4a9f                      tst.l      (a7)+
[00012038] 4cdf 0080                 movem.l    (a7)+,d7
[0001203c] 4e5e                      unlk       a6
[0001203e] 4e75                      rts
atofloat:
[00012040] 4e56 fff4                 link       a6,#-12
[00012044] 48e7 0704                 movem.l    d5-d7/a5,-(a7)
[00012048] 2a6e 0008                 movea.l    8(a6),a5
[0001204c] 2d7c 0000 0000 fffc       move.l     #$00000000,-4(a6)
[00012054] 1e1d                      move.b     (a5)+,d7
[00012056] 4887                      ext.w      d7
[00012058] be7c 0020                 cmp.w      #$0020,d7
[0001205c] 67f6                      beq.s      $00012054
[0001205e] be7c 002d                 cmp.w      #$002D,d7
[00012062] 6704                      beq.s      $00012068
[00012064] 4240                      clr.w      d0
[00012066] 6002                      bra.s      $0001206A
[00012068] 7001                      moveq.l    #1,d0
[0001206a] 3d40 fffa                 move.w     d0,-6(a6)
[0001206e] 4a6e fffa                 tst.w      -6(a6)
[00012072] 6606                      bne.s      $0001207A
[00012074] be7c 002b                 cmp.w      #$002B,d7
[00012078] 660a                      bne.s      $00012084
[0001207a] 1e1d                      move.b     (a5)+,d7
[0001207c] 4887                      ext.w      d7
[0001207e] be7c 0020                 cmp.w      #$0020,d7
[00012082] 67f6                      beq.s      $0001207A
[00012084] 4a47                      tst.w      d7
[00012086] 6606                      bne.s      $0001208E
[00012088] 70ff                      moveq.l    #-1,d0
[0001208a] 6000 017c                 bra        $00012208
[0001208e] 6038                      bra.s      $000120C8
[00012090] 3007                      move.w     d7,d0
[00012092] d07c ffd0                 add.w      #$FFD0,d0
[00012096] 48c0                      ext.l      d0
[00012098] 2f00                      move.l     d0,-(a7)
[0001209a] 4eb9 0001 22d2            jsr        fpltof
[000120a0] 588f                      addq.l     #4,a7
[000120a2] 2f00                      move.l     d0,-(a7)
[000120a4] 2f2e fffc                 move.l     -4(a6),-(a7)
[000120a8] 2f3c a000 0044            move.l     #$A0000044,-(a7)
[000120ae] 4eb9 0001 23fe            jsr        fpmul
[000120b4] 508f                      addq.l     #8,a7
[000120b6] 2f00                      move.l     d0,-(a7)
[000120b8] 4eb9 0001 2256            jsr        fpadd
[000120be] 508f                      addq.l     #8,a7
[000120c0] 2d40 fffc                 move.l     d0,-4(a6)
[000120c4] 1e1d                      move.b     (a5)+,d7
[000120c6] 4887                      ext.w      d7
[000120c8] be7c 0030                 cmp.w      #$0030,d7
[000120cc] 6d06                      blt.s      $000120D4
[000120ce] be7c 0039                 cmp.w      #$0039,d7
[000120d2] 6fbc                      ble.s      $00012090
[000120d4] be7c 002e                 cmp.w      #$002E,d7
[000120d8] 6666                      bne.s      $00012140
[000120da] 2d7c 8000 0041 fff4       move.l     #$80000041,-12(a6)
[000120e2] 1e1d                      move.b     (a5)+,d7
[000120e4] 4887                      ext.w      d7
[000120e6] 604c                      bra.s      $00012134
[000120e8] 2f3c cccc cd3d            move.l     #$CCCCCD3D,-(a7)
[000120ee] 2f2e fff4                 move.l     -12(a6),-(a7)
[000120f2] 4eb9 0001 23fe            jsr        fpmul
[000120f8] 508f                      addq.l     #8,a7
[000120fa] 2d40 fff4                 move.l     d0,-12(a6)
[000120fe] 2f2e fffc                 move.l     -4(a6),-(a7)
[00012102] 2f2e fff4                 move.l     -12(a6),-(a7)
[00012106] 3007                      move.w     d7,d0
[00012108] d07c ffd0                 add.w      #$FFD0,d0
[0001210c] 48c0                      ext.l      d0
[0001210e] 2f00                      move.l     d0,-(a7)
[00012110] 4eb9 0001 22d2            jsr        fpltof
[00012116] 588f                      addq.l     #4,a7
[00012118] 2f00                      move.l     d0,-(a7)
[0001211a] 4eb9 0001 23fe            jsr        fpmul
[00012120] 508f                      addq.l     #8,a7
[00012122] 2f00                      move.l     d0,-(a7)
[00012124] 4eb9 0001 2256            jsr        fpadd
[0001212a] 508f                      addq.l     #8,a7
[0001212c] 2d40 fffc                 move.l     d0,-4(a6)
[00012130] 1e1d                      move.b     (a5)+,d7
[00012132] 4887                      ext.w      d7
[00012134] be7c 0030                 cmp.w      #$0030,d7
[00012138] 6d06                      blt.s      $00012140
[0001213a] be7c 0039                 cmp.w      #$0039,d7
[0001213e] 6fa8                      ble.s      $000120E8
[00012140] 4246                      clr.w      d6
[00012142] be7c 0065                 cmp.w      #$0065,d7
[00012146] 6708                      beq.s      $00012150
[00012148] be7c 0045                 cmp.w      #$0045,d7
[0001214c] 6600 0086                 bne        $000121D4
[00012150] 1e1d                      move.b     (a5)+,d7
[00012152] 4887                      ext.w      d7
[00012154] be7c 002d                 cmp.w      #$002D,d7
[00012158] 6704                      beq.s      $0001215E
[0001215a] 4240                      clr.w      d0
[0001215c] 6002                      bra.s      $00012160
[0001215e] 7001                      moveq.l    #1,d0
[00012160] 3d40 fff8                 move.w     d0,-8(a6)
[00012164] 4a6e fff8                 tst.w      -8(a6)
[00012168] 6606                      bne.s      $00012170
[0001216a] be7c 002b                 cmp.w      #$002B,d7
[0001216e] 6604                      bne.s      $00012174
[00012170] 1e1d                      move.b     (a5)+,d7
[00012172] 4887                      ext.w      d7
[00012174] 6014                      bra.s      $0001218A
[00012176] 3007                      move.w     d7,d0
[00012178] 3206                      move.w     d6,d1
[0001217a] c3fc 000a                 muls.w     #$000A,d1
[0001217e] d041                      add.w      d1,d0
[00012180] 3c00                      move.w     d0,d6
[00012182] dc7c ffd0                 add.w      #$FFD0,d6
[00012186] 1e1d                      move.b     (a5)+,d7
[00012188] 4887                      ext.w      d7
[0001218a] be7c 0030                 cmp.w      #$0030,d7
[0001218e] 6d06                      blt.s      $00012196
[00012190] be7c 0039                 cmp.w      #$0039,d7
[00012194] 6fe0                      ble.s      $00012176
[00012196] bc7c 0063                 cmp.w      #$0063,d6
[0001219a] 6f02                      ble.s      $0001219E
[0001219c] 7c63                      moveq.l    #99,d6
[0001219e] 4a6e fff8                 tst.w      -8(a6)
[000121a2] 6708                      beq.s      $000121AC
[000121a4] 203c cccc cd3d            move.l     #$CCCCCD3D,d0
[000121aa] 6006                      bra.s      $000121B2
[000121ac] 203c a000 0044            move.l     #$A0000044,d0
[000121b2] 2d40 fff4                 move.l     d0,-12(a6)
[000121b6] 6014                      bra.s      $000121CC
[000121b8] 2f2e fffc                 move.l     -4(a6),-(a7)
[000121bc] 2f2e fff4                 move.l     -12(a6),-(a7)
[000121c0] 4eb9 0001 23fe            jsr        fpmul
[000121c6] 508f                      addq.l     #8,a7
[000121c8] 2d40 fffc                 move.l     d0,-4(a6)
[000121cc] 3006                      move.w     d6,d0
[000121ce] 5346                      subq.w     #1,d6
[000121d0] 4a40                      tst.w      d0
[000121d2] 6ee4                      bgt.s      $000121B8
[000121d4] be7c 0020                 cmp.w      #$0020,d7
[000121d8] 670e                      beq.s      $000121E8
[000121da] be7c 002c                 cmp.w      #$002C,d7
[000121de] 6708                      beq.s      $000121E8
[000121e0] 4a47                      tst.w      d7
[000121e2] 6704                      beq.s      $000121E8
[000121e4] 70fe                      moveq.l    #-2,d0
[000121e6] 6020                      bra.s      $00012208
[000121e8] 4a6e fffa                 tst.w      -6(a6)
[000121ec] 6710                      beq.s      $000121FE
[000121ee] 2f2e fffc                 move.l     -4(a6),-(a7)
[000121f2] 4eb9 0001 2428            jsr        fpneg
[000121f8] 588f                      addq.l     #4,a7
[000121fa] 2d40 fffc                 move.l     d0,-4(a6)
[000121fe] 206e 000c                 movea.l    12(a6),a0
[00012202] 20ae fffc                 move.l     -4(a6),(a0)
[00012206] 7001                      moveq.l    #1,d0
[00012208] 4a9f                      tst.l      (a7)+
[0001220a] 4cdf 20c0                 movem.l    (a7)+,d6-d7/a5
[0001220e] 4e5e                      unlk       a6
[00012210] 4e75                      rts

	dc.w 0x23f9
	dc.b 'cio2con.'

xbios:	
[0001221c] 23df 0001 2bba            move.l     (a7)+,$00012BBA
[00012222] 4e4e                      trap       #14
[00012224] 2f39 0001 2bba            move.l     $00012BBA,-(a7)
[0001222a] 4e75                      rts

bios:
[0001222c] 23df 0001 2bba            move.l     (a7)+,$00012BBA
[00012232] 4e4d                      trap       #13
[00012234] 2f39 0001 2bba            move.l     $00012BBA,-(a7)
[0001223a] 4e75                      rts

gemdos:
[0001223c] 23df 0001 2bba            move.l     (a7)+,$00012BBA
[00012242] 4e41                      trap       #1
[00012244] 2f39 0001 2bba            move.l     $00012BBA,-(a7)
[0001224a] 4e75                      rts

	dc.w 0x23f9
	dc.b 'osbind.o'

fpadd:
[00012256] 4e56 fffc                 link       a6,#-4
[0001225a] 48e7 1f00                 movem.l    d3-d7,-(a7)
[0001225e] 2e2e 0008                 move.l     8(a6),d7
[00012262] 2c2e 000c                 move.l     12(a6),d6
[00012266] 4eb9 0001 24ca            jsr        ffpadd
[0001226c] 2007                      move.l     d7,d0
[0001226e] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[00012272] 4e5e                      unlk       a6
[00012274] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpadd.o',0

fpcmp:
[00012280] 4e56 fffc                 link       a6,#-4
[00012284] 48e7 1f00                 movem.l    d3-d7,-(a7)
[00012288] 2e2e 0008                 move.l     8(a6),d7
[0001228c] 2c2e 000c                 move.l     12(a6),d6
[00012290] 4eb9 0001 2478            jsr        $00012478
[00012296] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[0001229a] 4e5e                      unlk       a6
[0001229c] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpcmp.o',0

fpdiv:
[000122a8] 4e56 fffc                 link       a6,#-4
[000122ac] 48e7 1f00                 movem.l    d3-d7,-(a7)
[000122b0] 2e2e 0008                 move.l     8(a6),d7
[000122b4] 2c2e 000c                 move.l     12(a6),d6
[000122b8] 4eb9 0001 25ca            jsr        ffpdiv
[000122be] 2007                      move.l     d7,d0
[000122c0] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[000122c4] 4e5e                      unlk       a6
[000122c6] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpdiv.o',0

fpltof:
[000122d2] 4e56 0000                 link       a6,#0
[000122d6] 48e7 0700                 movem.l    d5-d7,-(a7)
[000122da] 4aae 0008                 tst.l      8(a6)
[000122de] 6c0e                      bge.s      $000122EE
[000122e0] 7c01                      moveq.l    #1,d6
[000122e2] 202e 0008                 move.l     8(a6),d0
[000122e6] 4480                      neg.l      d0
[000122e8] 2d40 0008                 move.l     d0,8(a6)
[000122ec] 6002                      bra.s      $000122F0
[000122ee] 4246                      clr.w      d6
[000122f0] 4aae 0008                 tst.l      8(a6)
[000122f4] 6604                      bne.s      $000122FA
[000122f6] 4280                      clr.l      d0
[000122f8] 605e                      bra.s      $00012358
[000122fa] 7e18                      moveq.l    #24,d7
[000122fc] 600c                      bra.s      $0001230A
[000122fe] 202e 0008                 move.l     8(a6),d0
[00012302] e280                      asr.l      #1,d0
[00012304] 2d40 0008                 move.l     d0,8(a6)
[00012308] 5287                      addq.l     #1,d7
[0001230a] 202e 0008                 move.l     8(a6),d0
[0001230e] c0bc 7f00 0000            and.l      #$7F000000,d0
[00012314] 66e8                      bne.s      $000122FE
[00012316] 600c                      bra.s      $00012324
[00012318] 202e 0008                 move.l     8(a6),d0
[0001231c] e380                      asl.l      #1,d0
[0001231e] 2d40 0008                 move.l     d0,8(a6)
[00012322] 5387                      subq.l     #1,d7
[00012324] 082e 0007 0009            btst       #7,9(a6)
[0001232a] 67ec                      beq.s      $00012318
[0001232c] 202e 0008                 move.l     8(a6),d0
[00012330] e180                      asl.l      #8,d0
[00012332] 2d40 0008                 move.l     d0,8(a6)
[00012336] debc 0000 0040            add.l      #$00000040,d7
[0001233c] 2007                      move.l     d7,d0
[0001233e] c0bc 0000 007f            and.l      #$0000007F,d0
[00012344] 81ae 0008                 or.l       d0,8(a6)
[00012348] 4a46                      tst.w      d6
[0001234a] 6708                      beq.s      $00012354
[0001234c] 00ae 0000 0080 0008       ori.l      #$00000080,8(a6)
[00012354] 202e 0008                 move.l     8(a6),d0
[00012358] 4a9f                      tst.l      (a7)+
[0001235a] 4cdf 00c0                 movem.l    (a7)+,d6-d7
[0001235e] 4e5e                      unlk       a6
[00012360] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ltof.o',0,0

fpftol:
[0001236c] 4e56 0000                 link       a6,#0
[00012370] 48e7 0f00                 movem.l    d4-d7,-(a7)
[00012374] 202e 0008                 move.l     8(a6),d0
[00012378] c0bc 0000 007f            and.l      #$0000007F,d0
[0001237e] d0bc ffff ffc0            add.l      #$FFFFFFC0,d0
[00012384] 3c00                      move.w     d0,d6
[00012386] 4aae 0008                 tst.l      8(a6)
[0001238a] 6704                      beq.s      $00012390
[0001238c] 4a46                      tst.w      d6
[0001238e] 6c04                      bge.s      $00012394
[00012390] 4280                      clr.l      d0
[00012392] 6056                      bra.s      $000123EA
[00012394] 202e 0008                 move.l     8(a6),d0
[00012398] c0bc 0000 0080            and.l      #$00000080,d0
[0001239e] 3a00                      move.w     d0,d5
[000123a0] bc7c 001f                 cmp.w      #$001F,d6
[000123a4] 6f14                      ble.s      $000123BA
[000123a6] 4a45                      tst.w      d5
[000123a8] 6708                      beq.s      $000123B2
[000123aa] 203c 8000 0000            move.l     #$80000000,d0
[000123b0] 6006                      bra.s      $000123B8
[000123b2] 203c 7fff ffff            move.l     #$7FFFFFFF,d0
[000123b8] 6030                      bra.s      $000123EA
[000123ba] 2e2e 0008                 move.l     8(a6),d7
[000123be] e087                      asr.l      #8,d7
[000123c0] cebc 00ff ffff            and.l      #$00FFFFFF,d7
[000123c6] 9c7c 0018                 sub.w      #$0018,d6
[000123ca] 6004                      bra.s      $000123D0
[000123cc] e287                      asr.l      #1,d7
[000123ce] 5246                      addq.w     #1,d6
[000123d0] 4a46                      tst.w      d6
[000123d2] 6df8                      blt.s      $000123CC
[000123d4] 6004                      bra.s      $000123DA
[000123d6] e387                      asl.l      #1,d7
[000123d8] 5346                      subq.w     #1,d6
[000123da] 4a46                      tst.w      d6
[000123dc] 6ef8                      bgt.s      $000123D6
[000123de] 4a45                      tst.w      d5
[000123e0] 6706                      beq.s      $000123E8
[000123e2] 2007                      move.l     d7,d0
[000123e4] 4480                      neg.l      d0
[000123e6] 2e00                      move.l     d0,d7
[000123e8] 2007                      move.l     d7,d0
[000123ea] 4a9f                      tst.l      (a7)+
[000123ec] 4cdf 00e0                 movem.l    (a7)+,d5-d7
[000123f0] 4e5e                      unlk       a6
[000123f2] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ftol.o',0,0

fpmul:
[000123fe] 4e56 fffc                 link       a6,#-4
[00012402] 48e7 1f00                 movem.l    d3-d7,-(a7)
[00012406] 2e2e 0008                 move.l     8(a6),d7
[0001240a] 2c2e 000c                 move.l     12(a6),d6
[0001240e] 4eb9 0001 2646            jsr        ffmul2
[00012414] 2007                      move.l     d7,d0
[00012416] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[0001241a] 4e5e                      unlk       a6
[0001241c] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpmul.o',0

fpneg:
[00012428] 4e56 fffc                 link       a6,#-4
[0001242c] 48e7 1f00                 movem.l    d3-d7,-(a7)
[00012430] 2e2e 0008                 move.l     8(a6),d7
[00012434] 4eb9 0001 24a4            jsr        ffpneg
[0001243a] 2007                      move.l     d7,d0
[0001243c] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[00012440] 4e5e                      unlk       a6
[00012442] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpneg.o',0

fpsub:
[0001244e] 4e56 fffc                 link       a6,#-4
[00012452] 48e7 1f00                 movem.l    d3-d7,-(a7)
[00012456] 2e2e 0008                 move.l     8(a6),d7
[0001245a] 2c2e 000c                 move.l     12(a6),d6
[0001245e] 4eb9 0001 24b8            jsr        ffpsub
[00012464] 2007                      move.l     d7,d0
[00012466] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[0001246a] 4e5e                      unlk       a6
[0001246c] 4e75                      rts

	dc.w 0x23f9
	dc.b 'fpsub.o',0

ffpcmp:
[00012478] 4a06                      tst.b      d6
[0001247a] 6a0c                      bpl.s      $00012488
[0001247c] 4a07                      tst.b      d7
[0001247e] 6a08                      bpl.s      $00012488
[00012480] bc07                      cmp.b      d7,d6
[00012482] 660a                      bne.s      $0001248E
[00012484] bc87                      cmp.l      d7,d6
[00012486] 4e75                      rts
[00012488] be06                      cmp.b      d6,d7
[0001248a] 6602                      bne.s      $0001248E
[0001248c] be86                      cmp.l      d6,d7
[0001248e] 4e75                      rts
[00012490] 4a07                      tst.b      d7
[00012492] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ffpcmp.o'

[0001249e] ce3c 007f                 and.b      #$7F,d7
[000124a2] 4e75                      rts

ffpneg:
[000124a4] 4a07                      tst.b      d7
[000124a6] 6704                      beq.s      $000124AC
[000124a8] 0a07 0080                 eori.b     #$80,d7
[000124ac] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ffpabs.o'

ffpsub:
[000124b8] 1806                      move.b     d6,d4
[000124ba] 6752                      beq.s      $0001250E
[000124bc] 0a04 0080                 eori.b     #$80,d4
[000124c0] 6b6a                      bmi.s      $0001252C
[000124c2] 1a07                      move.b     d7,d5
[000124c4] 6b6c                      bmi.s      $00012532
[000124c6] 660e                      bne.s      $000124D6
[000124c8] 603e                      bra.s      $00012508

ffpadd:
[000124ca] 1806                      move.b     d6,d4
[000124cc] 6b5e                      bmi.s      $0001252C
[000124ce] 673e                      beq.s      $0001250E
[000124d0] 1a07                      move.b     d7,d5
[000124d2] 6b5e                      bmi.s      $00012532
[000124d4] 6732                      beq.s      $00012508
[000124d6] 9a04                      sub.b      d4,d5
[000124d8] 6b38                      bmi.s      $00012512
[000124da] 1807                      move.b     d7,d4
[000124dc] ba3c 0018                 cmp.b      #$18,d5
[000124e0] 642c                      bcc.s      $0001250E
[000124e2] 2606                      move.l     d6,d3
[000124e4] 4203                      clr.b      d3
[000124e6] eaab                      lsr.l      d5,d3
[000124e8] 1e3c 0080                 move.b     #$80,d7
[000124ec] de83                      add.l      d3,d7
[000124ee] 6504                      bcs.s      $000124F4
[000124f0] 1e04                      move.b     d4,d7
[000124f2] 4e75                      rts
[000124f4] e297                      roxr.l     #1,d7
[000124f6] 5204                      addq.b     #1,d4
[000124f8] 6902                      bvs.s      $000124FC
[000124fa] 64f4                      bcc.s      $000124F0
[000124fc] 7eff                      moveq.l    #-1,d7
[000124fe] 5304                      subq.b     #1,d4
[00012500] 1e04                      move.b     d4,d7
[00012502] 003c 0002                 ori.b      #$02,ccr
[00012506] 4e75                      rts
[00012508] 2e06                      move.l     d6,d7
[0001250a] 1e04                      move.b     d4,d7
[0001250c] 4e75                      rts
[0001250e] 4a07                      tst.b      d7
[00012510] 4e75                      rts
[00012512] ba3c ffe8                 cmp.b      #$E8,d5
[00012516] 6ff0                      ble.s      $00012508
[00012518] 4405                      neg.b      d5
[0001251a] 2606                      move.l     d6,d3
[0001251c] 4207                      clr.b      d7
[0001251e] eaaf                      lsr.l      d5,d7
[00012520] 163c 0080                 move.b     #$80,d3
[00012524] de83                      add.l      d3,d7
[00012526] 65cc                      bcs.s      $000124F4
[00012528] 1e04                      move.b     d4,d7
[0001252a] 4e75                      rts
[0001252c] 1a07                      move.b     d7,d5
[0001252e] 6ba6                      bmi.s      $000124D6
[00012530] 67d6                      beq.s      $00012508
[00012532] 7680                      moveq.l    #-128,d3
[00012534] b705                      eor.b      d3,d5
[00012536] 9a04                      sub.b      d4,d5
[00012538] 6750                      beq.s      $0001258A
[0001253a] 6b3c                      bmi.s      $00012578
[0001253c] ba3c 0018                 cmp.b      #$18,d5
[00012540] 64cc                      bcc.s      $0001250E
[00012542] 1807                      move.b     d7,d4
[00012544] 1e03                      move.b     d3,d7
[00012546] 2606                      move.l     d6,d3
[00012548] 4203                      clr.b      d3
[0001254a] eaab                      lsr.l      d5,d3
[0001254c] 9e83                      sub.l      d3,d7
[0001254e] 6ba0                      bmi.s      $000124F0
[00012550] 1a04                      move.b     d4,d5
[00012552] 4207                      clr.b      d7
[00012554] 5304                      subq.b     #1,d4
[00012556] bebc 0000 7fff            cmp.l      #$00007FFF,d7
[0001255c] 6206                      bhi.s      $00012564
[0001255e] 4847                      swap       d7
[00012560] 983c 0010                 sub.b      #$10,d4
[00012564] de87                      add.l      d7,d7
[00012566] 5bcc fffc                 dbmi       d4,$00012564
[0001256a] b905                      eor.b      d4,d5
[0001256c] 6b06                      bmi.s      $00012574
[0001256e] 1e04                      move.b     d4,d7
[00012570] 6702                      beq.s      $00012574
[00012572] 4e75                      rts
[00012574] 7e00                      moveq.l    #0,d7
[00012576] 4e75                      rts
[00012578] ba3c ffe8                 cmp.b      #$E8,d5
[0001257c] 6f8a                      ble.s      $00012508
[0001257e] 4405                      neg.b      d5
[00012580] 2607                      move.l     d7,d3
[00012582] 2e06                      move.l     d6,d7
[00012584] 1e3c 0080                 move.b     #$80,d7
[00012588] 60be                      bra.s      $00012548
[0001258a] 1a07                      move.b     d7,d5
[0001258c] cb44                      exg        d5,d4
[0001258e] 1e06                      move.b     d6,d7
[00012590] 9e86                      sub.l      d6,d7
[00012592] 67e0                      beq.s      $00012574
[00012594] 6aba                      bpl.s      $00012550
[00012596] 4487                      neg.l      d7
[00012598] 1805                      move.b     d5,d4
[0001259a] 60b6                      bra.s      $00012552

	dc.w 0x23f9
	dc.b 'ffpadd.o'

[000125a6] 8efc 0000                 divu.w     #$0000,d7
[000125aa] 4a86                      tst.l      d6
[000125ac] 661c                      bne.s      ffpdiv
[000125ae] 8ebc ffff ff7f            or.l       #$FFFFFF7F,d7
[000125b4] 4a07                      tst.b      d7
[000125b6] 003c 0002                 ori.b      #$02,ccr
[000125ba] 4e75                      rts
[000125bc] 4846                      swap       d6
[000125be] 4847                      swap       d7
[000125c0] bd07                      eor.b      d6,d7
[000125c2] 60ea                      bra.s      $000125AE
[000125c4] 6bfa                      bmi.s      $000125C0
[000125c6] 7e00                      moveq.l    #0,d7
[000125c8] 4e75                      rts
ffpdiv:
[000125ca] 1a06                      move.b     d6,d5
[000125cc] 67d8                      beq.s      $000125A6
[000125ce] 2807                      move.l     d7,d4
[000125d0] 67e8                      beq.s      $000125BA
[000125d2] 7680                      moveq.l    #-128,d3
[000125d4] da45                      add.w      d5,d5
[000125d6] d844                      add.w      d4,d4
[000125d8] b705                      eor.b      d3,d5
[000125da] b704                      eor.b      d3,d4
[000125dc] 9805                      sub.b      d5,d4
[000125de] 69e4                      bvs.s      $000125C4
[000125e0] 4207                      clr.b      d7
[000125e2] 4847                      swap       d7
[000125e4] 4846                      swap       d6
[000125e6] be46                      cmp.w      d6,d7
[000125e8] 6b06                      bmi.s      $000125F0
[000125ea] 5404                      addq.b     #2,d4
[000125ec] 69ce                      bvs.s      $000125BC
[000125ee] e29f                      ror.l      #1,d7
[000125f0] 4847                      swap       d7
[000125f2] 1a03                      move.b     d3,d5
[000125f4] bb44                      eor.w      d5,d4
[000125f6] e24c                      lsr.w      #1,d4
[000125f8] 2607                      move.l     d7,d3
[000125fa] 86c6                      divu.w     d6,d3
[000125fc] 3a03                      move.w     d3,d5
[000125fe] c6c6                      mulu.w     d6,d3
[00012600] 9e83                      sub.l      d3,d7
[00012602] 4847                      swap       d7
[00012604] 4846                      swap       d6
[00012606] 3606                      move.w     d6,d3
[00012608] 4203                      clr.b      d3
[0001260a] c6c5                      mulu.w     d5,d3
[0001260c] 9e83                      sub.l      d3,d7
[0001260e] 6408                      bcc.s      $00012618
[00012610] 2606                      move.l     d6,d3
[00012612] 4203                      clr.b      d3
[00012614] de83                      add.l      d3,d7
[00012616] 5345                      subq.w     #1,d5
[00012618] 2606                      move.l     d6,d3
[0001261a] 4843                      swap       d3
[0001261c] 4247                      clr.w      d7
[0001261e] 8ec3                      divu.w     d3,d7
[00012620] 4845                      swap       d5
[00012622] 6b08                      bmi.s      $0001262C
[00012624] 3a07                      move.w     d7,d5
[00012626] da85                      add.l      d5,d5
[00012628] 5304                      subq.b     #1,d4
[0001262a] 3e05                      move.w     d5,d7
[0001262c] 3a07                      move.w     d7,d5
[0001262e] dabc 0000 0080            add.l      #$00000080,d5
[00012634] 2e05                      move.l     d5,d7
[00012636] 1e04                      move.b     d4,d7
[00012638] 678c                      beq.s      $000125C6
[0001263a] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ffpdiv.o'

ffmul2:
[00012646] 1a07                      move.b     d7,d5
[00012648] 6752                      beq.s      $0001269C
[0001264a] 1806                      move.b     d6,d4
[0001264c] 6768                      beq.s      $000126B6
[0001264e] da45                      add.w      d5,d5
[00012650] d844                      add.w      d4,d4
[00012652] 7680                      moveq.l    #-128,d3
[00012654] b704                      eor.b      d3,d4
[00012656] b705                      eor.b      d3,d5
[00012658] da04                      add.b      d4,d5
[0001265a] 695e                      bvs.s      $000126BA
[0001265c] 1803                      move.b     d3,d4
[0001265e] b945                      eor.w      d4,d5
[00012660] e25d                      ror.w      #1,d5
[00012662] 4845                      swap       d5
[00012664] 3a06                      move.w     d6,d5
[00012666] 4207                      clr.b      d7
[00012668] 4205                      clr.b      d5
[0001266a] 3805                      move.w     d5,d4
[0001266c] c8c7                      mulu.w     d7,d4
[0001266e] 4844                      swap       d4
[00012670] 2607                      move.l     d7,d3
[00012672] 4843                      swap       d3
[00012674] c6c5                      mulu.w     d5,d3
[00012676] d883                      add.l      d3,d4
[00012678] 4846                      swap       d6
[0001267a] 2606                      move.l     d6,d3
[0001267c] c6c7                      mulu.w     d7,d3
[0001267e] d883                      add.l      d3,d4
[00012680] 4244                      clr.w      d4
[00012682] d904                      addx.b     d4,d4
[00012684] 4844                      swap       d4
[00012686] 4847                      swap       d7
[00012688] cec6                      mulu.w     d6,d7
[0001268a] 4846                      swap       d6
[0001268c] 4845                      swap       d5
[0001268e] de84                      add.l      d4,d7
[00012690] 6a0c                      bpl.s      $0001269E
[00012692] debc 0000 0080            add.l      #$00000080,d7
[00012698] 1e05                      move.b     d5,d7
[0001269a] 671a                      beq.s      $000126B6
[0001269c] 4e75                      rts
[0001269e] 5305                      subq.b     #1,d5
[000126a0] 6914                      bvs.s      $000126B6
[000126a2] 6512                      bcs.s      $000126B6
[000126a4] 7840                      moveq.l    #64,d4
[000126a6] de84                      add.l      d4,d7
[000126a8] de87                      add.l      d7,d7
[000126aa] 6404                      bcc.s      $000126B0
[000126ac] e297                      roxr.l     #1,d7
[000126ae] 5205                      addq.b     #1,d5
[000126b0] 1e05                      move.b     d5,d7
[000126b2] 6702                      beq.s      $000126B6
[000126b4] 4e75                      rts
[000126b6] 7e00                      moveq.l    #0,d7
[000126b8] 4e75                      rts
[000126ba] 6afa                      bpl.s      $000126B6
[000126bc] bd07                      eor.b      d6,d7
[000126be] 8ebc ffff ff7f            or.l       #$FFFFFF7F,d7
[000126c4] 4a07                      tst.b      d7
[000126c6] 003c 0002                 ori.b      #$02,ccr
[000126ca] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ffpmul2.'

[000126d6] 6d63                      blt.s      $0001273B
[000126d8] 3638 3334                 move.w     ($00003334).w,d3
[000126dc] 3320                      move.w     -(a0),-(a1)
[000126de] 666c                      bne.s      $0001274C
[000126e0] 6f61                      ble.s      $00012743
[000126e2] 7469                      moveq.l    #105,d2
[000126e4] 6e67                      bgt.s      $0001274D
[000126e6] 2070 6f69 6e74            movea.l    ([$6E74,a0,zd6.l*8]),a0 ; 68020+ only
[000126ec] 2066                      movea.l    -(a6),a0
[000126ee] 6972                      bvs.s      $00012762
[000126f0] 6d77                      blt.s      $00012769
[000126f2] 6172                      bsr.s      $00012766
[000126f4] 6520                      bcs.s      $00012716
[000126f6] 2863                      movea.l    -(a3),a4
[000126f8] 2920                      move.l     -(a0),-(a4)
[000126fa] 636f                      bls.s      $0001276B
[000126fc] 7079                      moveq.l    #121,d0
[000126fe] 7269                      moveq.l    #105,d1
[00012700] 6768                      beq.s      $0001276A
[00012702] 7420                      moveq.l    #32,d2
[00012704] 3139 3831 2062            move.w     $38312062,-(a0)
[0001270a] 7920                      ???
[0001270c] 6d6f                      blt.s      $0001277D
[0001270e] 746f                      moveq.l    #111,d2
[00012710] 726f                      moveq.l    #111,d1
[00012712] 6c61                      bge.s      $00012775
[00012714] 2069 6e63                 movea.l    28259(a1),a0
[00012718] 2e00                      move.l     d0,d7

	dc.w 0x23f9
	dc.b 'ffpcpyrt'

lmul:
[00012724] 4e56 fffc                 link       a6,#-4
[00012728] 4242                      clr.w      d2
[0001272a] 4aae 0008                 tst.l      8(a6)
[0001272e] 6c06                      bge.s      $00012736
[00012730] 44ae 0008                 neg.l      8(a6)
[00012734] 5242                      addq.w     #1,d2
[00012736] 4aae 000c                 tst.l      12(a6)
[0001273a] 6c06                      bge.s      $00012742
[0001273c] 44ae 000c                 neg.l      12(a6)
[00012740] 5242                      addq.w     #1,d2
[00012742] 302e 000a                 move.w     10(a6),d0
[00012746] c0ee 000e                 mulu.w     14(a6),d0
[0001274a] 2d40 fffc                 move.l     d0,-4(a6)
[0001274e] 302e 0008                 move.w     8(a6),d0
[00012752] c0ee 000e                 mulu.w     14(a6),d0
[00012756] 322e 000c                 move.w     12(a6),d1
[0001275a] c2ee 000a                 mulu.w     10(a6),d1
[0001275e] d041                      add.w      d1,d0
[00012760] d06e fffc                 add.w      -4(a6),d0
[00012764] 3d40 fffc                 move.w     d0,-4(a6)
[00012768] 202e fffc                 move.l     -4(a6),d0
[0001276c] 0802 0000                 btst       #0,d2
[00012770] 6702                      beq.s      $00012774
[00012772] 4480                      neg.l      d0
[00012774] 4e5e                      unlk       a6
[00012776] 4e75                      rts

	dc.w 0x23f9
	dc.b 'lmul.o',0,0

ldiv:
[00012782] 4e56 fffe                 link       a6,#-2
[00012786] 48e7 3f00                 movem.l    d2-d7,-(a7)
[0001278a] 4243                      clr.w      d3
[0001278c] 4285                      clr.l      d5
[0001278e] 2e2e 0008                 move.l     8(a6),d7
[00012792] 2c2e 000c                 move.l     12(a6),d6
[00012796] 6618                      bne.s      $000127B0
[00012798] 23fc 8000 0000 0001 2bbe  move.l     #$80000000,$00012BBE
[000127a2] 203c 8000 0000            move.l     #$80000000,d0
[000127a8] 81fc 0000                 divs.w     #$0000,d0
[000127ac] 6000 0068                 bra.w      $00012816
[000127b0] 6c04                      bge.s      $000127B6
[000127b2] 4486                      neg.l      d6
[000127b4] 5243                      addq.w     #1,d3
[000127b6] 4a87                      tst.l      d7
[000127b8] 6c04                      bge.s      $000127BE
[000127ba] 4487                      neg.l      d7
[000127bc] 5243                      addq.w     #1,d3
[000127be] bc87                      cmp.l      d7,d6
[000127c0] 6e38                      bgt.s      $000127FA
[000127c2] 6606                      bne.s      $000127CA
[000127c4] 7a01                      moveq.l    #1,d5
[000127c6] 4287                      clr.l      d7
[000127c8] 6030                      bra.s      $000127FA
[000127ca] bebc 0001 0000            cmp.l      #$00010000,d7
[000127d0] 6c0a                      bge.s      $000127DC
[000127d2] 8ec6                      divu.w     d6,d7
[000127d4] 3a07                      move.w     d7,d5
[000127d6] 4847                      swap       d7
[000127d8] 48c7                      ext.l      d7
[000127da] 601e                      bra.s      $000127FA
[000127dc] 7801                      moveq.l    #1,d4
[000127de] be86                      cmp.l      d6,d7
[000127e0] 6506                      bcs.s      $000127E8
[000127e2] e386                      asl.l      #1,d6
[000127e4] e384                      asl.l      #1,d4
[000127e6] 60f6                      bra.s      $000127DE
[000127e8] 4a84                      tst.l      d4
[000127ea] 670e                      beq.s      $000127FA
[000127ec] be86                      cmp.l      d6,d7
[000127ee] 6504                      bcs.s      $000127F4
[000127f0] 8a84                      or.l       d4,d5
[000127f2] 9e86                      sub.l      d6,d7
[000127f4] e28c                      lsr.l      #1,d4
[000127f6] e28e                      lsr.l      #1,d6
[000127f8] 60ee                      bra.s      $000127E8
[000127fa] b67c 0001                 cmp.w      #$0001,d3
[000127fe] 660e                      bne.s      $0001280E
[00012800] 4487                      neg.l      d7
[00012802] 23c7 0001 2bbe            move.l     d7,$00012BBE
[00012808] 2005                      move.l     d5,d0
[0001280a] 4480                      neg.l      d0
[0001280c] 6008                      bra.s      $00012816
[0001280e] 23c7 0001 2bbe            move.l     d7,$00012BBE
[00012814] 2005                      move.l     d5,d0
[00012816] 4a9f                      tst.l      (a7)+
[00012818] 4cdf 00f8                 movem.l    (a7)+,d3-d7
[0001281c] 4e5e                      unlk       a6
[0001281e] 4e75                      rts

	dc.w 0x23f9
	dc.b 'ldiv.o',0,0

lrem:
[0001282a] 4e56 fffe                 link       a6,#-2
[0001282e] 2f2e 000c                 move.l     12(a6),-(a7)
[00012832] 2f2e 0008                 move.l     8(a6),-(a7)
[00012836] 4eb9 0001 2782            jsr        $00012782
[0001283c] bf8f                      cmpm.l     (a7)+,(a7)+
[0001283e] 2039 0001 2bbe            move.l     $00012BBE,d0
[00012844] 4e5e                      unlk       a6
[00012846] 4e75                      rts

	dc.w 0x23f9
	dc.b 'lrem.o',0,0

data:
[00012852]                           dc.w $0000
[00012854]                           dc.w $0000
[00012856]                           dc.b 'falsches Format',0
[00012866]                           dc.b 'falsches Formatextension',0
[0001287f]                           dc.b $00
[00012880]                           dc.b 'fehlende Klammer',0
[00012891]                           dc.b $00
[00012892]                           dc.b 'fehlender Stringdelimiter',0
[000128ac]                           dc.b 'falscher Rep.count',0
[000128bf]                           dc.b $00
[000128c0]                           dc.b 'falsche vt52-Anweisung',0
[000128d7]                           dc.b $00
[000128d8]                           dc.w $ffff
[000128da]                           dc.w $0000
[000128dc]                           dc.w $00000021
[000128e0]                           dc.w $00000027
[000128e4]                           dc.w $0000002f
[000128e8]                           dc.w $0000003f
[000128ec]                           dc.w $00000060
[000128f0]                           dc.w $00000065
[000128f4]                           dc.w $00000066
[000128f8]                           dc.w $00000069
[000128fc]                           dc.w $0000006c
[00012900]                           dc.w $00000073
[00012904]                           dc.w $00000076
[00012908]                           dc.w $00000000
[0001290c]                           dc.l $00010748 21
[00012910]                           dc.l $00010736 27
[00012914]                           dc.l $0001070a 2f
[00012918]                           dc.l $0001073e 3f
[0001291c]                           dc.l $00010736 60
[00012920]                           dc.l $00010768 65
[00012924]                           dc.l $00010762 66
[00012928]                           dc.l $0001075c 69
[0001292c]                           dc.l $00010756 6c
[00012930]                           dc.l $00010750 73
[00012934]                           dc.l $0001076e 76
[00012938]                           dc.l $00010774

[0001293c]                           dc.w $00000021
[00012940]                           dc.w $00000027
[00012944]                           dc.w $0000002f
[00012948]                           dc.w $0000003f
[0001294c]                           dc.w $00000060
[00012950]                           dc.w $00000065
[00012954]                           dc.w $00000066
[00012958]                           dc.w $00000069
[0001295c]                           dc.w $0000006c
[00012960]                           dc.w $00000073
[00012964]                           dc.w $00000076
[00012968]                           dc.w $00000000
[0001296c]                           dc.l $0001152c 21
[00012970]                           dc.l $0001151c 27
[00012974]                           dc.l $000114f0 2f
[00012978]                           dc.l $00011522 3f
[0001297c]                           dc.l $0001151c 60
[00012980]                           dc.l $00011544 65
[00012984]                           dc.l $00011544 66
[00012988]                           dc.l $0001153e 69
[0001298c]                           dc.l $00011538 6c
[00012990]                           dc.l $00011534 73
[00012994]                           dc.l $0001154a 76
[00012998]                           dc.l $00011550
switch table printerr
[0001299c]                           dc.l $00011970
[000129a0]                           dc.l $00011968
[000129a4]                           dc.l $00011960
[000129a8]                           dc.l $00011958
[000129ac]                           dc.l $00011950
[000129b0]                           dc.l $00011948
[000129b4]                           dc.b 'cuup',0
[000129b9]                           dc.b 'cudown',0
[000129c0]                           dc.b 'curight',0
[000129c8]                           dc.b 'culeft',0
[000129cf]                           dc.b 'clhome',0
[000129d6]                           dc.b 'cuhome',0
[000129dd]                           dc.b 'cuupin',0
[000129e4]                           dc.b 'cldown',0
[000129eb]                           dc.b 'clliner',0
[000129f3]                           dc.b 'insline',0
[000129fb]                           dc.b 'delline',0
[00012a03]                           dc.b 'cupos',0
[00012a09]                           dc.b 'white',0
[00012a0f]                           dc.b 'black',0
[00012a15]                           dc.b 'clup',0
[00012a1a]                           dc.b 'cuon',0
[00012a1f]                           dc.b 'cuoff',0
[00012a25]                           dc.b 'cusave',0
[00012a2c]                           dc.b 'curest',0
[00012a33]                           dc.b 'clline',0
[00012a3a]                           dc.b 'cllinel',0
[00012a42]                           dc.b 'revon',0
[00012a48]                           dc.b 'revoff',0
[00012a4f]                           dc.b 'autoon',0
[00012a56]                           dc.b 'autooff',0
[00012a5e]                           dc.b ' falsche Integer-Eingabe. ',0
[00012a79]                           dc.b ' falsche Long-Eingabe. ',0
[00012a91]                           dc.b ' falsche Float-Eingabe. ',0
[00012aaa]                           dc.b '*** ',0
[00012aaf]                           dc.b '. ***',0
[00012ab5]                           dc.b $00


/*
12852: kernel
128d8: inplen

12ab6: strbuf
12b58: cont_parse
12B5A: vt52_err
12b5c: args
12b60: strstart
12b64: strend
12bba: saveret
12bbe: ldivr
*/
