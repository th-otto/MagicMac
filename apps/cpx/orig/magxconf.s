; CPX magic = 0x0064
; CPX flags = 0x0002
; CPX id = 0x4d414758
; CPX version = 0x0103
; CPX i_text = 'M','A','G','X','C','O','N','F',0,0,0,0,0,0
; CPX sm_icon = 0x3fff,0xffde
; CPX i_color = 0x1000
; CPX title_text = 'M','a','g','i','C','-','K','o','n','f','i','g','.',0,0,0,0,0
; CPX t_color = 0x1180
; CPX buffer = 

; ph_branch = 0x601a
; ph_tlen = 0x000005fe ; 1534
; ph_dlen = 0x000007ae ; 1966
; ph_blen = 0x000010b0 ; 4272
; ph_slen = 0x00000000
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000007
; ph_absflag = 0x0000
; first relocation = 0x00000002
; relocation bytes = 0x0000002b

[00010200] 4ef9 0001 0206            jmp       $00010206
[00010206] 48e7 3038                 movem.l   d2-d3/a2-a4,-(a7)
[0001020a] 594f                      subq.w    #4,a7
[0001020c] 49f9 0001 0fb4            lea.l     global_xcpb,a4
[00010212] 28af 001c                 move.l    28(a7),(a4)
[00010216] 4857                      pea.l     (a7)
[00010218] 2f3c 4d61 6758            move.l    #$4d616758,-(a7)
[0001021e] 2054                      movea.l   (a4),a0
[00010220] 2068 0050                 movea.l   80(a0),a0
[00010224] 4e90                      jsr       (a0)
[00010226] 504f                      addq.w    #8,a7
[00010228] 2017                      move.l    (a7),d0
[0001022a] 6618                      bne.s     $00010244
[0001022c] 2054                      movea.l   (a4),a0
[0001022e] 3228 0002                 move.w    2(a0),d1
[00010232] 6610                      bne.s     $00010244
[00010234] 93c9                      suba.l    a1,a1
[00010236] 41f9 0001 09fc            lea.l     $000109fc,a0
[0001023c] 7001                      moveq.l   #1,d0
[0001023e] 6100 0594                 bsr       mt_form_alert
[00010242] 6024                      bra.s     $00010268

[00010244] 2017                      move.l    (a7),d0
[00010246] 676a                      beq.s     $000102b2

[00010248] 2040                      movea.l   d0,a0
[0001024a] 2468 0008                 movea.l   8(a0),a2
[0001024e] 220a                      move.l    a2,d1
[00010250] 661c                      bne.s     $0001026e
[00010252] 2254                      movea.l   (a4),a1
[00010254] 3429 0002                 move.w    2(a1),d2
[00010258] 6614                      bne.s     $0001026e
[0001025a] 41f9 0001 0a29            lea.l     $00010a29,a0
[00010260] 7001                      moveq.l   #1,d0
[00010262] 93c9                      suba.l    a1,a1
[00010264] 6100 056e                 bsr       mt_form_alert
[00010268] 7000                      moveq.l   #0,d0
[0001026a] 6000 00d2                 bra       $0001033e

[0001026e] 200a                      move.l    a2,d0
[00010270] 6740                      beq.s     $000102b2
[00010272] 2054                      movea.l   (a4),a0
[00010274] 3228 0002                 move.w    2(a0),d1
[00010278] 673e                      beq.s     $000102b8
[0001027a] 42a7                      clr.l     -(a7)
[0001027c] 3f3c 414b                 move.w    #$414b,-(a7)
[00010280] 7433                      moveq.l   #51,d2
[00010282] 3f02                      move.w    d2,-(a7)
[00010284] 6100 0456                 bsr       gemdos
[00010288] 504f                      addq.w    #8,a7
[0001028a] 2940 fff8                 move.l    d0,-8(a4)
[0001028e] 02ac ffff f20f fff8       andi.l    #$fffff20f,-8(a4)
[00010296] 2039 0001 07fe            move.l    save_vars.config,d0
[0001029c] 81ac fff8                 or.l      d0,-8(a4)
[000102a0] 2f2c fff8                 move.l    -8(a4),-(a7)
[000102a4] 3f3c 454c                 move.w    #$454c,-(a7)
[000102a8] 7233                      moveq.l   #51,d1
[000102aa] 3f01                      move.w    d1,-(a7)
[000102ac] 6100 042e                 bsr       gemdos
[000102b0] 504f                      addq.w    #8,a7

[000102b2] 7001                      moveq.l   #1,d0
[000102b4] 6000 0088                 bra       $0001033e

[000102b8] 42a7                      clr.l     -(a7)
[000102ba] 3f3c 414b                 move.w    #$414b,-(a7)
[000102be] 7033                      moveq.l   #51,d0
[000102c0] 3f00                      move.w    d0,-(a7)
[000102c2] 6100 0418                 bsr       gemdos
[000102c6] 504f                      addq.w    #8,a7
[000102c8] 2940 fff8                 move.l    d0,-8(a4)

[000102cc] 47f9 0001 082a            lea.l     $0001082a,a3
[000102d2] 2054                      movea.l   (a4),a0
[000102d4] 3028 0006                 move.w    6(a0),d0
[000102d8] 665e                      bne.s     $00010338
[000102da] 4243                      clr.w     d3
[000102dc] 6010                      bra.s     $000102ee
[000102de] 3f03                      move.w    d3,-(a7)
[000102e0] 4853                      pea.l     (a3)
[000102e2] 2054                      movea.l   (a4),a0
[000102e4] 2068 0014                 movea.l   20(a0),a0
[000102e8] 4e90                      jsr       (a0)
[000102ea] 5c4f                      addq.w    #6,a7
[000102ec] 5243                      addq.w    #1,d3
[000102ee] b67c 000d                 cmp.w     #$000d,d3
[000102f2] 6dea                      blt.s     $000102de
[000102f4] 296b 0138 fffc            move.l    312(a3),-4(a4) ; maintree
[000102fa] 206c fffc                 movea.l   -4(a4),a0
[000102fe] 2868 0024                 movea.l   36(a0),a4
[00010302] 204c                      movea.l   a4,a0
[00010304] 6100 03ac                 bsr       strlen
[00010308] 41f4 08ff                 lea.l     -1(a4,d0.l),a0
[0001030c] 7208                      moveq.l   #8,d1
[0001030e] 202a 0010                 move.l    16(a2),d0
[00010312] 6100 0032                 bsr.w     format_number
[00010316] 2848                      movea.l   a0,a4
[00010318] 5d4c                      subq.w    #6,a4
[0001031a] 0c6a 0003 0032            cmpi.w    #$0003,50(a2)
[00010320] 6c08                      bge.s     $0001032a
[00010322] 70e0                      moveq.l   #-32,d0
[00010324] d02a 0033                 add.b     51(a2),d0
[00010328] 1880                      move.b    d0,(a4)
[0001032a] 204c                      movea.l   a4,a0
[0001032c] 7203                      moveq.l   #3,d1
[0001032e] 302a 0030                 move.w    48(a2),d0
[00010332] 48c0                      ext.l     d0
[00010334] 6100 0010                 bsr.w     format_number

[00010338] 41eb ffd8                 lea.l     -40(a3),a0
[0001033c] 2008                      move.l    a0,d0
[0001033e] 584f                      addq.w    #4,a7
[00010340] 4cdf 1c0c                 movem.l   (a7)+,d2-d3/a2-a4
[00010344] 4e75                      rts

format_number:
[00010346] 740f                      moveq.l   #15,d2
[00010348] c400                      and.b     d0,d2
[0001034a] d43c 0030                 add.b     #$30,d2
[0001034e] 1102                      move.b    d2,-(a0)
[00010350] e888                      lsr.l     #4,d0
[00010352] 0c28 002e ffff            cmpi.b    #$2e,-1(a0)
[00010358] 6602                      bne.s     $0001035c
[0001035a] 5348                      subq.w    #1,a0
[0001035c] 5341                      subq.w    #1,d1
[0001035e] 6ee6                      bgt.s     $00010346
[00010360] 4e75                      rts

get_config:
[00010362] 2f0a                      move.l    a2,-(a7)
[00010364] 2448                      movea.l   a0,a2
[00010366] 42a7                      clr.l     -(a7)
[00010368] 3f3c 414b                 move.w    #$414b,-(a7)
[0001036c] 7033                      moveq.l   #51,d0
[0001036e] 3f00                      move.w    d0,-(a7)
[00010370] 6100 036a                 bsr       gemdos
[00010374] 504f                      addq.w    #8,a7
[00010376] 41f9 0001 082a            lea.l     $0001082a,a0
[0001037c] 7210                      moveq.l   #16,d1
[0001037e] c280                      and.l     d0,d1
[00010380] 6708                      beq.s     $0001038a
[00010382] 0268 fffe 003a            andi.w    #$fffe,58(a0)
[00010388] 6006                      bra.s     $00010390
[0001038a] 0068 0001 003a            ori.w     #$0001,58(a0)
[00010390] 7220                      moveq.l   #32,d1
[00010392] c280                      and.l     d0,d1
[00010394] 6708                      beq.s     $0001039e
[00010396] 0068 0001 0052            ori.w     #$0001,82(a0)
[0001039c] 6006                      bra.s     $000103a4
[0001039e] 0268 fffe 0052            andi.w    #$fffe,82(a0)
[000103a4] 7240                      moveq.l   #64,d1
[000103a6] c280                      and.l     d0,d1
[000103a8] 6708                      beq.s     $000103b2
[000103aa] 0268 fffe 006a            andi.w    #$fffe,106(a0)
[000103b0] 6006                      bra.s     $000103b8
[000103b2] 0068 0001 006a            ori.w     #$0001,106(a0)
[000103b8] 223c 0000 0080            move.l    #$00000080,d1
[000103be] c280                      and.l     d0,d1
[000103c0] 6708                      beq.s     $000103ca
[000103c2] 0268 fffe 0082            andi.w    #$fffe,130(a0)
[000103c8] 6006                      bra.s     $000103d0
[000103ca] 0068 0001 0082            ori.w     #$0001,130(a0)
[000103d0] 2200                      move.l    d0,d1
[000103d2] c2bc 0000 0400            and.l     #$00000400,d1
[000103d8] 6708                      beq.s     $000103e2
[000103da] 0068 0001 00b2            ori.w     #$0001,178(a0)
[000103e0] 6006                      bra.s     $000103e8
[000103e2] 0268 fffe 00b2            andi.w    #$fffe,178(a0)
[000103e8] 2200                      move.l    d0,d1
[000103ea] c2bc 0000 0800            and.l     #$00000800,d1
[000103f0] 6708                      beq.s     $000103fa
[000103f2] 0068 0001 009a            ori.w     #$0001,154(a0)
[000103f8] 6006                      bra.s     $00010400
[000103fa] 0268 fffe 009a            andi.w    #$fffe,154(a0)
[00010400] 2480                      move.l    d0,(a2)
[00010402] 245f                      movea.l   (a7)+,a2
[00010404] 4e75                      rts

set_config:
[00010406] 2f0a                      move.l    a2,-(a7)
[00010408] 2448                      movea.l   a0,a2
[0001040a] 7000                      moveq.l   #0,d0
[0001040c] 41f9 0001 082a            lea.l     $0001082a,a0
[00010412] 7201                      moveq.l   #1,d1
[00010414] c268 003a                 and.w     58(a0),d1
[00010418] 6602                      bne.s     $0001041c
[0001041a] 7010                      moveq.l   #16,d0
[0001041c] 7201                      moveq.l   #1,d1
[0001041e] c268 0052                 and.w     82(a0),d1
[00010422] 6706                      beq.s     $0001042a
[00010424] 80bc 0000 0020            or.l      #$00000020,d0
[0001042a] 7201                      moveq.l   #1,d1
[0001042c] c268 006a                 and.w     106(a0),d1
[00010430] 6606                      bne.s     $00010438
[00010432] 80bc 0000 0040            or.l      #$00000040,d0
[00010438] 7201                      moveq.l   #1,d1
[0001043a] c268 0082                 and.w     130(a0),d1
[0001043e] 6606                      bne.s     $00010446
[00010440] 80bc 0000 0080            or.l      #$00000080,d0
[00010446] 7201                      moveq.l   #1,d1
[00010448] c268 00b2                 and.w     178(a0),d1
[0001044c] 6706                      beq.s     $00010454
[0001044e] 80bc 0000 0400            or.l      #$00000400,d0
[00010454] 7201                      moveq.l   #1,d1
[00010456] c268 009a                 and.w     154(a0),d1
[0001045a] 6706                      beq.s     $00010462
[0001045c] 80bc 0000 0800            or.l      #$00000800,d0
[00010462] 0292 ffff f20f            andi.l    #$fffff20f,(a2)
[00010468] 8192                      or.l      d0,(a2)
[0001046a] 2f12                      move.l    (a2),-(a7)
[0001046c] 3f3c 454c                 move.w    #$454c,-(a7)
[00010470] 7033                      moveq.l   #51,d0
[00010472] 3f00                      move.w    d0,-(a7)
[00010474] 6100 0266                 bsr       gemdos
[00010478] 504f                      addq.w    #8,a7
[0001047a] 245f                      movea.l   (a7)+,a2
[0001047c] 4e75                      rts

fix_tree:
[0001047e] 48e7 1e30                 movem.l   d3-d6/a2-a3,-(a7)
[00010482] 2648                      movea.l   a0,a3
[00010484] 3600                      move.w    d0,d3
[00010486] 2449                      movea.l   a1,a2
[00010488] 3801                      move.w    d1,d4
[0001048a] 42a7                      clr.l     -(a7)
[0001048c] 486a 0002                 pea.l     2(a2)
[00010490] 6100 0304                 bsr       mt_objc_offset
[00010494] 504f                      addq.w    #8,a7
[00010496] 3203                      move.w    d3,d1
[00010498] 48c1                      ext.l     d1
[0001049a] 2001                      move.l    d1,d0
[0001049c] d080                      add.l     d0,d0
[0001049e] d081                      add.l     d1,d0
[000104a0] e788                      lsl.l     #3,d0
[000104a2] 3573 0814 0004            move.w    20(a3,d0.l),4(a2)
[000104a8] 3573 0816 0006            move.w    22(a3,d0.l),6(a2)
[000104ae] 4a44                      tst.w     d4
[000104b0] 6700 0098                 beq       $0001054a

[000104b4] 3833 0808                 move.w    8(a3,d0.l),d4
[000104b8] 3033 0806                 move.w    6(a3,d0.l),d0
[000104bc] c07c 00ff                 and.w     #$00ff,d0
[000104c0] b07c 0014                 cmp.w     #$0014,d0
[000104c4] 670c                      beq.s     $000104d2
[000104c6] b07c 0019                 cmp.w     #$0019,d0
[000104ca] 6706                      beq.s     $000104d2
[000104cc] b07c 001b                 cmp.w     #$001b,d0
[000104d0] 6618                      bne.s     $000104ea
[000104d2] 3203                      move.w    d3,d1
[000104d4] 48c1                      ext.l     d1
[000104d6] 2001                      move.l    d1,d0
[000104d8] d080                      add.l     d0,d0
[000104da] d081                      add.l     d1,d0
[000104dc] e788                      lsl.l     #3,d0
[000104de] 3a33 080c                 move.w    12(a3,d0.l),d5
[000104e2] e14d                      lsl.w     #8,d5
[000104e4] e045                      asr.w     #8,d5
[000104e6] 3c05                      move.w    d5,d6
[000104e8] 6002                      bra.s     $000104ec

[000104ea] 4246                      clr.w     d6
[000104ec] 7040                      moveq.l   #64,d0
[000104ee] c044                      and.w     d4,d0
[000104f0] 6702                      beq.s     $000104f4
[000104f2] 7aff                      moveq.l   #-1,d5
[000104f4] 7004                      moveq.l   #4,d0
[000104f6] c044                      and.w     d4,d0
[000104f8] 6702                      beq.s     $000104fc
[000104fa] 7afe                      moveq.l   #-2,d5
[000104fc] 7010                      moveq.l   #16,d0
[000104fe] 3403                      move.w    d3,d2
[00010500] 48c2                      ext.l     d2
[00010502] 2202                      move.l    d2,d1
[00010504] d281                      add.l     d1,d1
[00010506] d282                      add.l     d2,d1
[00010508] e789                      lsl.l     #3,d1
[0001050a] c073 180a                 and.w     10(a3,d1.l),d0
[0001050e] 6702                      beq.s     $00010512
[00010510] 7afd                      moveq.l   #-3,d5
[00010512] 4a45                      tst.w     d5
[00010514] 6a10                      bpl.s     $00010526
[00010516] db52                      add.w     d5,(a2)
[00010518] db6a 0002                 add.w     d5,2(a2)
[0001051c] da45                      add.w     d5,d5
[0001051e] 9b6a 0004                 sub.w     d5,4(a2)
[00010522] 9b6a 0006                 sub.w     d5,6(a2)
[00010526] 7020                      moveq.l   #32,d0
[00010528] 3403                      move.w    d3,d2
[0001052a] 48c2                      ext.l     d2
[0001052c] 2202                      move.l    d2,d1
[0001052e] d281                      add.l     d1,d1
[00010530] d282                      add.l     d2,d1
[00010532] e789                      lsl.l     #3,d1
[00010534] c073 180a                 and.w     10(a3,d1.l),d0
[00010538] 6710                      beq.s     $0001054a
[0001053a] 4a46                      tst.w     d6
[0001053c] 6a02                      bpl.s     $00010540
[0001053e] 4446                      neg.w     d6
[00010540] dc46                      add.w     d6,d6
[00010542] dd6a 0004                 add.w     d6,4(a2)
[00010546] dd6a 0006                 add.w     d6,6(a2)

[0001054a] 4cdf 0c78                 movem.l   (a7)+,d3-d6/a2-a3
[0001054e] 4e75                      rts

draw_tree:
[00010550] 48e7 1038                 movem.l   d3/a2-a4,-(a7)
[00010554] 514f                      subq.w    #8,a7
[00010556] 2448                      movea.l   a0,a2
[00010558] 3600                      move.w    d0,d3
[0001055a] 7201                      moveq.l   #1,d1
[0001055c] 43d7                      lea.l     (a7),a1
[0001055e] 6100 ff1e                 bsr       $0001047e
[00010562] 47f9 0001 0fb4            lea.l     global_xcpb,a3
[00010568] 4857                      pea.l     (a7)
[0001056a] 2053                      movea.l   (a3),a0
[0001056c] 2068 0038                 movea.l   56(a0),a0 ; GetFirstRect
[00010570] 4e90                      jsr       (a0)
[00010572] 584f                      addq.w    #4,a7
[00010574] 2840                      movea.l   d0,a4
[00010576] 601a                      bra.s     $00010592
[00010578] 42a7                      clr.l     -(a7)
[0001057a] 224c                      movea.l   a4,a1
[0001057c] 7208                      moveq.l   #8,d1
[0001057e] 3003                      move.w    d3,d0
[00010580] 204a                      movea.l   a2,a0
[00010582] 6100 01d0                 bsr       mt_objc_draw_grect
[00010586] 584f                      addq.w    #4,a7
[00010588] 2053                      movea.l   (a3),a0
[0001058a] 2068 003c                 movea.l   60(a0),a0
[0001058e] 4e90                      jsr       (a0)
[00010590] 2840                      movea.l   d0,a4
[00010592] 200c                      move.l    a4,d0
[00010594] 66e2                      bne.s     $00010578
[00010596] 504f                      addq.w    #8,a7
[00010598] 4cdf 1c08                 movem.l   (a7)+,d3/a2-a4
[0001059c] 4e75                      rts

handle_msg:
[0001059e] 48e7 1030                 movem.l   d3/a2-a3,-(a7)
[000105a2] 594f                      subq.w    #4,a7
[000105a4] 2648                      movea.l   a0,a3
[000105a6] 4243                      clr.w     d3
[000105a8] b07c ffff                 cmp.w     #$ffff,d0
[000105ac] 6704                      beq.s     $000105b2
[000105ae] c07c 7fff                 and.w     #$7fff,d0
[000105b2] 45f9 0001 0fac            lea.l     $00010fac,a2
[000105b8] 3200                      move.w    d0,d1
[000105ba] 5241                      addq.w    #1,d1
[000105bc] 6770                      beq.s     $0001062e
[000105be] 927c 000b                 sub.w     #$000b,d1
[000105c2] 6720                      beq.s     $000105e4
[000105c4] 5341                      subq.w    #1,d1
[000105c6] 6708                      beq.s     $000105d0
[000105c8] 5341                      subq.w    #1,d1
[000105ca] 670e                      beq.s     $000105da
[000105cc] 6000 0078                 bra.w     $00010646
case 11:
[000105d0] 0279 fffe 0001 093c       andi.w    #$fffe,$0001093c
[000105d8] 6064                      bra.s     $0001063e
case 12:
[000105da] 0279 fffe 0001 0954       andi.w    #$fffe,$00010954
[000105e2] 6060                      bra.s     $00010644
case 10:
[000105e4] 4267                      clr.w     -(a7)
[000105e6] 206a 0008                 movea.l   8(a2),a0
[000105ea] 2068 0044                 movea.l   68(a0),a0
[000105ee] 4e90                      jsr       (a0)
[000105f0] 544f                      addq.w    #2,a7
[000105f2] 4a40                      tst.w     d0
[000105f4] 6724                      beq.s     $0001061a
[000105f6] 204a                      movea.l   a2,a0
[000105f8] 6100 fe0c                 bsr       set_config
[000105fc] 2012                      move.l    (a2),d0
[000105fe] c0bc 0000 0df0            and.l     #$00000df0,d0
[00010604] 2e80                      move.l    d0,(a7)
[00010606] 7204                      moveq.l   #4,d1
[00010608] 2f01                      move.l    d1,-(a7)
[0001060a] 486f 0004                 pea.l     4(a7)
[0001060e] 206a 0008                 movea.l   8(a2),a0
[00010612] 2068 0048                 movea.l   72(a0),a0
[00010616] 4e90                      jsr       (a0)
[00010618] 504f                      addq.w    #8,a7
[0001061a] 0279 fffe 0001 0924       andi.w    #$fffe,$00010924
[00010622] 700a                      moveq.l   #10,d0
[00010624] 206a 0004                 movea.l   4(a2),a0
[00010628] 6100 ff26                 bsr       draw_tree
[0001062c] 6018                      bra.s     $00010646
case -1:
[0001062e] 3013                      move.w    (a3),d0
[00010630] 907c 0016                 sub.w     #$0016,d0
[00010634] 6708                      beq.s     $0001063e
[00010636] 907c 0013                 sub.w     #$0013,d0
[0001063a] 6708                      beq.s     $00010644
[0001063c] 6008                      bra.s     $00010646
[0001063e] 204a                      movea.l   a2,a0
[00010640] 6100 fdc4                 bsr       set_config
[00010644] 7601                      moveq.l   #1,d3
}
[00010646] 3003                      move.w    d3,d0
[00010648] 584f                      addq.w    #4,a7
[0001064a] 4cdf 0c08                 movem.l   (a7)+,d3/a2-a3
[0001064e] 4e75                      rts

cpx_call:
[00010650] 48e7 3830                 movem.l   d2-d4/a2-a3,-(a7)
[00010654] 4fef fff0                 lea.l     -16(a7),a7
[00010658] 206f 0028                 movea.l   40(a7),a0
[0001065c] 4243                      clr.w     d3
[0001065e] 45f9 0001 082a            lea.l     $0001082a,a2
[00010664] 3550 0010                 move.w    (a0),16(a2)
[00010668] 3568 0002 0012            move.w    2(a0),18(a2)
[0001066e] 47f9 0001 0fb4            lea.l     global_xcpb,a3
[00010674] 41eb fff8                 lea.l     -8(a3),a0
[00010678] 6100 fce8                 bsr       get_config
[0001067c] 4240                      clr.w     d0
[0001067e] 206b fffc                 movea.l   -4(a3),a0
[00010682] 6100 fecc                 bsr       draw_tree
[00010686] 4857                      pea.l     (a7)
[00010688] 4267                      clr.w     -(a7)
[0001068a] 4852                      pea.l     (a2)
[0001068c] 2053                      movea.l   (a3),a0
[0001068e] 2068 0034                 movea.l   52(a0),a0
[00010692] 4e90                      jsr       (a0)
[00010694] 4fef 000a                 lea.l     10(a7),a7
[00010698] 3800                      move.w    d0,d4
[0001069a] 41d7                      lea.l     (a7),a0
[0001069c] 6100 ff00                 bsr       handle_msg
[000106a0] 3600                      move.w    d0,d3
[000106a2] 4a40                      tst.w     d0
[000106a4] 67e0                      beq.s     $00010686
[000106a6] 4240                      clr.w     d0
[000106a8] 4fef 0010                 lea.l     16(a7),a7
[000106ac] 4cdf 0c1c                 movem.l   (a7)+,d2-d4/a2-a3
[000106b0] 4e75                      rts

strlen:
[000106b2] 2248                      movea.l   a0,a1
[000106b4] 4a18                      tst.b     (a0)+
[000106b6] 671c                      beq.s     $000106d4
[000106b8] 4a18                      tst.b     (a0)+
[000106ba] 6718                      beq.s     $000106d4
[000106bc] 4a18                      tst.b     (a0)+
[000106be] 6714                      beq.s     $000106d4
[000106c0] 4a18                      tst.b     (a0)+
[000106c2] 6710                      beq.s     $000106d4
[000106c4] 4a18                      tst.b     (a0)+
[000106c6] 670c                      beq.s     $000106d4
[000106c8] 4a18                      tst.b     (a0)+
[000106ca] 6708                      beq.s     $000106d4
[000106cc] 4a18                      tst.b     (a0)+
[000106ce] 6704                      beq.s     $000106d4
[000106d0] 4a18                      tst.b     (a0)+
[000106d2] 66e0                      bne.s     $000106b4
[000106d4] 2008                      move.l    a0,d0
[000106d6] 9089                      sub.l     a1,d0
[000106d8] 5380                      subq.l    #1,d0
[000106da] 4e75                      rts

gemdos:
[000106dc] 23df 0001 0fb8            move.l    (a7)+,$00010fb8
[000106e2] 23ca 0001 0fbc            move.l    a2,$00010fbc
[000106e8] 4e41                      trap      #1
[000106ea] 2479 0001 0fbc            movea.l   $00010fbc,a2
[000106f0] 2279 0001 0fb8            movea.l   $00010fb8,a1
[000106f6] 4ed1                      jmp       (a1)

_aes_trap:
[000106f8] 2f0a                      move.l    a2,-(a7)
[000106fa] 4fef ffe8                 lea.l     -24(a7),a7
[000106fe] 244f                      movea.l   a7,a2
[00010700] 24c8                      move.l    a0,(a2)+
[00010702] 20d9                      move.l    (a1)+,(a0)+
[00010704] 20d9                      move.l    (a1)+,(a0)+
[00010706] 4258                      clr.w     (a0)+
[00010708] 24ef 0020                 move.l    32(a7),(a2)+
[0001070c] 6608                      bne.s     $00010716
[0001070e] 257c 0001 0fde fffc       move.l    #aes_global,-4(a2)
[00010716] 24c8                      move.l    a0,(a2)+
[00010718] 41e8 0020                 lea.l     32(a0),a0
[0001071c] 24c8                      move.l    a0,(a2)+
[0001071e] 41e8 0020                 lea.l     32(a0),a0
[00010722] 24c8                      move.l    a0,(a2)+
[00010724] 41e8 0040                 lea.l     64(a0),a0
[00010728] 24c8                      move.l    a0,(a2)+
[0001072a] 303c 00c8                 move.w    #$00c8,d0
[0001072e] 220f                      move.l    a7,d1
[00010730] 4e42                      trap      #2
[00010732] 4fef 0018                 lea.l     24(a7),a7
[00010736] 245f                      movea.l   (a7)+,a2
[00010738] 4e75                      rts

_crystal:
[0001073a] 2f0a                      move.l    a2,-(a7)
[0001073c] 303c 00c8                 move.w    #$00c8,d0
[00010740] 2208                      move.l    a0,d1
[00010742] 4e42                      trap      #2
[00010744] 245f                      movea.l   (a7)+,a2
[00010746] 4e75                      rts

_appl_yield:
[00010748] 2f0a                      move.l    a2,-(a7)
[0001074a] 303c 00c9                 move.w    #$00c9,d0
[0001074e] 4e42                      trap      #2
[00010750] 245f                      movea.l   (a7)+,a2
[00010752] 4e75                      rts

mt_objc_draw_grect:
[00010754] 2f0a                      move.l    a2,-(a7)
[00010756] 2f0b                      move.l    a3,-(a7)
[00010758] 4fef ff36                 lea.l     -202(a7),a7
[0001075c] 3f40 000a                 move.w    d0,10(a7)
[00010760] 3f41 000c                 move.w    d1,12(a7)
[00010764] 2449                      movea.l   a1,a2
[00010766] 47ef 000e                 lea.l     14(a7),a3
[0001076a] 26da                      move.l    (a2)+,(a3)+
[0001076c] 26da                      move.l    (a2)+,(a3)+
[0001076e] 2f48 004a                 move.l    a0,74(a7)
[00010772] 2f2f 00d6                 move.l    214(a7),-(a7)
[00010776] 43f9 0001 0b54            lea.l     $00010b54,a1
[0001077c] 41ef 0004                 lea.l     4(a7),a0
[00010780] 4eb9 0001 06f8            jsr       _aes_trap
[00010786] 584f                      addq.w    #4,a7
[00010788] 302f 002a                 move.w    42(a7),d0
[0001078c] 4fef 00ca                 lea.l     202(a7),a7
[00010790] 265f                      movea.l   (a7)+,a3
[00010792] 245f                      movea.l   (a7)+,a2
[00010794] 4e75                      rts

mt_objc_offset:
[00010796] 2f0b                      move.l    a3,-(a7)
[00010798] 4fef ff36                 lea.l     -202(a7),a7
[0001079c] 2649                      movea.l   a1,a3
[0001079e] 3f40 000a                 move.w    d0,10(a7)
[000107a2] 2f48 004a                 move.l    a0,74(a7)
[000107a6] 2f2f 00d6                 move.l    214(a7),-(a7)
[000107aa] 43f9 0001 0b64            lea.l     $00010b64,a1
[000107b0] 41ef 0004                 lea.l     4(a7),a0
[000107b4] 4eb9 0001 06f8            jsr       _aes_trap
[000107ba] 584f                      addq.w    #4,a7
[000107bc] 36af 002c                 move.w    44(a7),(a3)
[000107c0] 206f 00d2                 movea.l   210(a7),a0
[000107c4] 30af 002e                 move.w    46(a7),(a0)
[000107c8] 302f 002a                 move.w    42(a7),d0
[000107cc] 4fef 00ca                 lea.l     202(a7),a7
[000107d0] 265f                      movea.l   (a7)+,a3
[000107d2] 4e75                      rts

mt_form_alert:
[000107d4] 4fef ff36                 lea.l     -202(a7),a7
[000107d8] 3f40 000a                 move.w    d0,10(a7)
[000107dc] 2f48 004a                 move.l    a0,74(a7)
[000107e0] 2f09                      move.l    a1,-(a7)
[000107e2] 43f9 0001 0bb4            lea.l     $00010bb4,a1
[000107e8] 41ef 0004                 lea.l     4(a7),a0
[000107ec] 4eb9 0001 06f8            jsr       _aes_trap
[000107f2] 584f                      addq.w    #4,a7
[000107f4] 302f 002a                 move.w    42(a7),d0
[000107f8] 4fef 00ca                 lea.l     202(a7),a7
[000107fc] 4e75                      rts

data:
save_vars:
[000107fe]                           dc.l 0

[00010802]                           dc.w $00010650
[00010806]                           dc.w $00000000
[0001080a]                           dc.w $00000000
[0001080e]                           dc.w $00000000
[00010812]                           dc.w $00000000
[00010816]                           dc.w $00000000
[0001081a]                           dc.w $00000000
[0001081e]                           dc.w $00000000
[00010822]                           dc.w $00000000
[00010826]                           dc.w $00000000

rs_object:
[0001062a]                           dc.w -1, 1, 12, G_BOX, OF_FL3DBAK, OS_NONE, 0x00ff1000, 0, 0, 32, 11
[00010642]                           dc.w 8, 2, 7, G_BUTTON, OF_FL3DBAK, 0xfe40, 0x00010966, 1, 0x0400, 0x011e, 0x0408
[0001065a]                           dc.w 3, -1, -1, G_BUTTON, 0x0241, 0x8040, 0x00010983, 2, 0x0801, 11, 1
[00010672]                           dc.w 4, -1, -1, G_BUTTON, 0x0241, 0x8040, 0x0001098c, 2, 0x0802, 0x0015, 1
[0001068a]                           dc.w 5, -1, -1, G_BUTTON, 0x0241, 0x8640, 0x0001099f, 2, 0x0803, 0x000f, 1
[000106a2]                           dc.w 6, -1, -1, G_BUTTON, 0x0241, 0x8040, 0x000109ac, 2, 0x0804, 0x0018, 1
[000106ba]                           dc.w 7, -1, -1, G_BUTTON, 0x0241, 0x8740, 0x000109c2, 2, 0x0805, 0x0019, 1
[000106d2]                           dc.w 1, -1, -1, G_BUTTON, 0x0241, 0x8040, 0x000109d9, 2, 0x0806, 0x0012, 1

[000106ea]                           dc.w 9, -1, -1, G_IBOX, 0x0200, 0x0001, 0x00010100, 0, 0x0e08, 0x0020, 0x0200
[00010702]                           dc.w 10, -1, -1, G_IBOX, 0x0200, 0x0001, 0x00010100, 0x040a, 0x0f08, 0x0200, 0x0102
[0001071a]                           dc.w 11, -1, -1, G_BUTTON, 0x0605, 0x0040, 0x000109e9, 0x0201, 0x0709, 8, 0x0101
[00010732]                           dc.w 12, -1, -1, G_BUTTON, 0x0607, 0x0040, 0x000109f1, 12, 0x0709, 8, 0x0201
[0001074a]                           dc.w 0, -1, -1, G_BUTTON, 0x0625, 0x0040, 0x000109f4, 0x0616, 0x0709, 8, 0x0101

[00010762]                           dc.w $0001
[00010764]                           dc.w $062a
[00010966]                           dc.b ' MagiC 0.00  vom 00.00.0000 ',0
[00010983]                           dc.b 'Fastload',0
[0001098c]                           dc.b 'TOS-KompatibilitÑt',0
[0001099f]                           dc.b 'Smart Redraw',0

[000109ac]                           dc.b 'Grow- und Shrinkboxen',0
[000109c2]                           dc.b 'Floppy-Hintergrund-DMA',0
[000109d9]                           dc.b 'Pull-Down-MenÅs',0
[000109e9]                           dc.b 'Sichern',0
[000109f1]                           dc.b 'OK',0
[000109f4]                           dc.b 'Abbruch',0
[000109fc]                           dc.b '[1][MagiC ist nicht installiert!][ Abbruch ]',0
[00010a29]                           dc.b '[1][MagiC-AES ist nicht aktiv!][ Abbruch ]',0

00010Fac: config
00010FB0: maintree
00010FB4: global_xcpb
00010fde: aes_global
00010fb8: ret_pc
00010fbc: save_a2
