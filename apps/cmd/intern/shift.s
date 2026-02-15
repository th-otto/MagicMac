shift_com:
 tst.w    SP_BATCH(sp)             * checken, ob im Batch- Modus
 beq.b    shf_end
 lea      syntax_shifts(pc),a0
 bsr      get_country_str
 movea.l  SP_PARGC(sp),a1
 tst.w    (a1)
 beq.b    shf_1
 subq.w   #1,(a1)
 movea.l  SP_PARGV(sp),a0
 addq.l   #4,(a0)
 bra.b    shf_end
shf_1:
 bsr      strcon
 bsr      inc_errlv
shf_end:
 rts
