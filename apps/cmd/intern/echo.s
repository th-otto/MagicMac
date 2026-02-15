echo_com:
 movem.l  d7/a5,-(sp)
 sf       d7
echo_7:
 lea      is_echo(pc),a5
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    echo_2
 lea      echo_ists(pc),a0
 bsr      get_country_str
 bsr      strstdout
 lea      ons(pc),a0               * "ON"
 tst.b    (a5)
 bne.b    echo_1
 lea      offs(pc),a0              * "OFF"
echo_1:
 bsr      strstdout
 bra.b    echo_6
echo_2:
 movea.l  SP_ARGV+8(sp),a0
 move.l   4(a0),a1
 cmpi.b   #'-',(a1)+
 bne.b    echo_5
 move.b   (a1)+,d0
 bsr      d0_upper
 cmpi.b   #'N',d0
 bne.b    echo_5
 tst.b    (a1)
 bne.b    echo_5
* Erstes Argument: "-n" : CR/LF unterdrcken
 addq.l   #4,SP_ARGV+8(sp)
 subq.w   #1,SP_ARGC+8(sp)
 st       d7
 bra.b    echo_7
echo_5:
 move.l   4(a0),a0
 bsr      is_off_on
 tst.w    d0
 bmi.b    echo_4                       * negativ => String ausgeben
 sne      (a5)                     * ECHO- Status merken
 bra.b    echo_6
echo_3:
 addq.l   #4,SP_ARGV+8(sp)
 movea.l  SP_ARGV+8(sp),a0
 move.l   (a0),a0
 bsr      strstdout
 cmpi.w   #1,SP_ARGC+8(sp)
 beq.b    echo_4
 moveq    #' ',d0
 bsr      putchar
echo_4:
 subq.w   #1,SP_ARGC+8(sp)
 bne.b    echo_3
echo_6:
 tst.b    d7
 bne.b    echo_8
 bsr      crlf_stdout
echo_8:
 movem.l  (sp)+,a5/d7
 rts
