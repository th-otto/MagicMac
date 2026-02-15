rd_com:
 moveq    #Ddelete,d0
 bra.b    rmd_com
md_com:
 moveq    #Dcreate,d0
rmd_com:
 lea      rmd_syntaxs(pc),a0
 cmpi.w   #2,SP_ARGC(sp)      * Genau ein Argument ?
 bne.b    rmd_1
 movea.l  SP_ARGV(sp),a0
 move.l   4(a0),-(sp)
 move.w   d0,-(sp)            * Dcreate oder Ddelete
 trap     #1
 addq.l   #6,sp
 tst.w    d0
 beq.b    rmd_end
 bsr      crprint_err
 bra.b    rmd_50
rmd_1:
 bsr      get_country_str
 bsr      strcon
rmd_50:
 bsr      inc_errlv
rmd_end:
 rts
