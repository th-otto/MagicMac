break_com:
 moveq    #1,d0
 bra.b    vb_com
verify_com:
 moveq    #0,d0
vb_com:
 movem.l  d6/d7,-(sp)
 move     d0,d7
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    vb_2
 tst      d7
 bne.b    vb_11
* 1. Fall: Verify- Flag holen
 clr.l    -(sp)
 gemdos   Super          * in Super- Mode
 addq.l   #6,sp
 move.l   d0,-(sp)
 move.w   _fverify,d6
 gemdos   Super          * in User Mode
 addq.l   #6,sp
 bra.b    vb_12
* 2. Fall: Break- Flag holen
vb_11:
 clr.w    -(sp)
 gemdos   Sconfig
 addq.l   #4,sp
 andi.w   #4,d0                    * Bit 2 isolieren
 move     d0,d6
vb_12:
 lea      status_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
 lea      ons(pc),a0               * "ON"
 tst.w    d6
 bne.b    vb_1
 lea      offs(pc),a0              * "OFF"
vb_1:
 bsr      strstdout
 bsr      crlf_stdout
 bra.b    vb_end
vb_2:
 movea.l  SP_ARGV+8(sp),a0
 move.l   4(a0),a0
 bsr      is_off_on
 move.w   d0,d6
 bge.b    vb_3
 bsr      inc_errlv
 lea      error_verifys(pc),a0
 bsr      get_country_str
 bsr      strcon
 bra.b    vb_end
vb_3:
 tst      d7
 bne.b    vb_21
* 1. Fall: Verify- Flag setzen
 clr.l    -(sp)
 gemdos   Super          * in Super- Mode
 addq.l   #6,sp
 move.l   d0,-(sp)
 move.w   d6,_fverify
 gemdos   Super          * in User- Mode
 addq.l   #6,sp
 bra.b    vb_end
* 2. Fall: Break Flag setzen
vb_21:
 clr.w    -(sp)                    * Bitvektor holen
 gemdos   Sconfig
 addq.l   #4,sp
 tst      d6
 beq.b    vb_22
 bset     #2,d0
 bra.b    vb_23
vb_22:
 bclr     #2,d0
vb_23:
 move.l   d0,-(sp)
 move.w   #1,-(sp)                 * Bitvektor setzen
 gemdos   Sconfig
 addq.l   #8,sp
vb_end:
 movem.l  (sp)+,d6/d7
 rts
