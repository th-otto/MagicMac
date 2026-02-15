if_com:
 link     a6,#-$80
 movem.l  d6/d7/a4/a5,-(sp)
 bsr      sav_errlv
 tst.w    BATCH(a6)           * checken, ob im Batch-Modus
 beq      i100
 move.l   ARGV(a6),a5
 clr.w    d7
 addq.l   #4,a5               * nÑchster Parameter
 subq.w   #1,ARGC(a6)
 bne.b    i1
i11:
 lea      syntax_ifs(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
 bra      i100
i1:
 lea      not_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i2
 moveq    #1,d7
 subq.w   #1,ARGC(a6)
 addq.l   #4,a5
i2:
 tst.w    ARGC(a6)
 beq.b    i11
 lea      errorlevel_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i5
 cmpi.w   #3,ARGC(a6)
 blt.b    i5
 move.l   4(a5),a0
 bsr      str_toi
 clr.w    d6
 cmp.w    errorlevel(pc),d0
 bhi.b    i3
 moveq    #1,d6
i3:
 addq.l   #4,a5
 subq.w   #1,ARGC(a6)
exe_restzeile:
 eor.w    d7,d6          * d6 umdrehen, falls d7 = 1, sonst lassen
 beq.b    i4            * Damit ist d7 die Operation NOT auf 0 und 1
 move.l   a5,a1
 move.w   ARGC(a6),d0
 lea      -$80(a6),a0
 bsr      cat_strings
 move.l   PARGV(a6),-(sp)
 move.l   PARGC(a6),-(sp)
 pea      -$80(a6)
 move.w   BATCH(a6),-(sp)
 bsr      cmdline_exec        * Rest der Kommandozeile ausfÅhren
 adda.w   #14,sp
i4:
 bra.b    i100
i5:
 lea      exist_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i7
 cmpi.w   #3,ARGC(a6)
 blt.b    i7
 clr.w    d0
 move.l   4(a5),a0
 bsr      open
 clr.w    d6
 tst.l    d0
 blt.b    i6
* move.w   d0,,d0
 bsr      close
 moveq    #1,d6
i6:
 bra.b    i3             * Weiter wie bei "errorlevel"
i7:
 cmpi.w   #4,ARGC(a6)
 blt.b    i100           * Fehlermeldung unterdrÅcken
 lea      equal_s(pc),a1
 move.l   4(a5),a0
 bsr      upper_strcmp
 bne.b    i100           * Fehlermeldung unterdrÅcken
 subq.w   #1,ARGC(a6)    * Ausdruck "string1 == string2"
 moveq    #0,d6
 move.l   8(a5),a1
 move.l   (a5)+,a0
 bsr      upper_strcmp
 bne.b    i8
 moveq    #1,d6
i8:
 bra      i3
i100:
 movem.l  (sp)+,a4/a5/d7/d6
 unlk     a6
 rts
