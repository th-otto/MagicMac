**********************************************************************
*
* Emulation des 68000- Befehls "move sr,ea" auf dem 680x0
*
**********************************************************************

my_priv_exception:
          movem.l a0/a1/d0,-(sp)
          movea.l 14(sp),a0
          move.w  (a0),d0
          subi.w  #$40c0,d0
          bcs.b   nosrea
          cmpi.w  #$3a,d0
          bcc.b   nosrea
          andi.w  #$38,d0
          lsr.w   #2,d0
          move.w  srea3(pc,d0.w),d0
          jmp     srea3(pc,d0.w)
nosrea:   movem.l (sp)+,a0/a1/d0
          rte

srea3:    DC.W    eaddd-srea3
          DC.W    nosrea-srea3
          DC.W    eaan-srea3
          DC.W    eaanp-srea3
          DC.W    ea_an-srea3
          DC.W    ead16-srea3
          DC.W    ead08-srea3
          DC.W    eaadr-srea3

eaddd:    moveq   #7,d0
          and.w   (a0),d0
          lsl.w   #2,d0
          lea     eaddd1(pc,d0.w),a0
          move.l  (sp)+,d0
          movea.w 8(sp),a1
          jmp     (a0)
eaddd1:   move.w  a1,d0
          bra.b   eaddd2
          move.w  a1,d1
          bra.b   eaddd2
          move.w  a1,d2
          bra.b   eaddd2
          move.w  a1,d3
          bra.b   eaddd2
          move.w  a1,d4
          bra.b   eaddd2
          move.w  a1,d5
          bra.b   eaddd2
          move.w  a1,d6
          bra.b   eaddd2
          move.w  a1,d7
eaddd2:   movea.l (sp)+,a0
          movea.l (sp)+,a1
          addq.l  #2,2(sp)
          rte
eaadr:    cmpi.w  #$40f8,(a0)+
          bne.b   eaadr1
          movea.w (a0),a0
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
eaadr1:   movea.l (a0),a0
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #6,2(sp)
          rte
eaan:     bsr.b   srea2
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #2,2(sp)
          rte
ea_an:    bsr.b   srea2
          move.w  12(sp),-(a0)
          bra.b   retan
eaanp:    bsr.b   srea2
          move.w  12(sp),(a0)+
retan:    pea     retan1(pc,d0.w)
          move.l  a0,d0
          movem.l 8(sp),a0/a1
          rts
retan1:   movea.l d0,a0
          bra.b   retan2
          movea.l d0,a1
          bra.b   retan2
          movea.l d0,a2
          bra.b   retan2
          movea.l d0,a3
          bra.b   retan2
          movea.l d0,a4
          bra.b   retan2
          movea.l d0,a5
          bra.b   retan2
          movea.l d0,a6
          bra.b   retan2
          movea.l d0,a0
          move    a0,usp
          movea.l 4(sp),a0
retan2:   move.l  (sp)+,d0
          addq.l  #8,sp
          addq.l  #2,2(sp)
          rte
srea2:    moveq   #7,d0
          and.w   (a0),d0
          lsl.w   #2,d0
          movea.l 8(sp),a0
          jmp     srea1(pc,d0.w)
srea1:    rts

          DC.W    $ffff

          movea.l a1,a0
          rts
          movea.l a2,a0
          rts

          movea.l a3,a0
          rts
          movea.l a4,a0
          rts
          movea.l a5,a0
          rts
          movea.l a6,a0
          rts
          move    usp,a0
          rts
ead16:    bsr.b  srea2
          movea.l 14(sp),a1
          move.l  (a1),d0
          move.w  12(sp),(a0,d0.w)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
ead08:    bsr.b  srea2
          movea.l 14(sp),a1
          addq.l  #2,a1
          move.w  (a1),d0
          ext.w   d0
          pea     0(a0,d0.w)
          move.b  (a1),d0
          move.w  d0,-(sp)
          andi.w  #$f0,d0
          lsr.w   #2,d0
          bclr    #5,d0
          bne.b   ead08a1
          lea     ead08d1(pc,d0.w),a0
          move.l  6(sp),d0
          jmp     (a0)
ead08a1:  movem.l 10(sp),a0/a1
          jsr     srea1(pc,d0.w)
ead081:   moveq   #8,d0
          and.w   (sp)+,d0
          movea.l (sp)+,a1
          bne.b   ead082
          movea.w a0,a0
ead082:   move.w  12(sp),(a1,a0.L)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
ead08d1:  movea.l d0,a0
          bra.b   ead081
          movea.l d1,a0
          bra.b   ead081
          movea.l d2,a0
          bra.b   ead081
          movea.l d3,a0
          bra.b   ead081
          movea.l d4,a0
          bra.b   ead081
          movea.l d5,a0
          bra.b   ead081
          movea.l d6,a0
          bra.b   ead081
          movea.l d7,a0
          bra.b   ead081
