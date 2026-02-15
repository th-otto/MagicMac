STRING    SET  -200

find_com:
 link     a6,#STRING
 movem.l  d6/d7/a5/a4,-(sp)
 cmpi.w   #2,ARGC(a6)
 bge.b    find_1
 bsr      inc_errlv
 lea      syntax_finds(pc),a0
 bsr      get_country_str
 bsr      strcon
 bra.b    find_end
find_1:
 lea      STRING(a6),a5
 movea.l  a5,a4
 move.w   #200,d7
find_2:
 clr.b    1(a5)
 move.l   a5,a0
 moveq    #1,d1
 moveq    #STDIN,d0           * 1 Byte von stdin lesen
 bsr      read
 bsr      fatal
 moveq    #1,d6               * Setze EOF = TRUE
 subq.l   #1,d0
 bne.b    find_4                  * EOF
 cmpi.b   #$1a,(a5)
 beq.b    find_4                  * EOF
 clr.w    d6                  * Setze EOF = FALSE
 cmpi.b   #CR,(a5)
 beq.b    find_3
 cmpi.b   #LF,(a5)
 beq.b    find_4
 addq.l   #1,a5
 subq.w   #1,d7
find_3:
 tst.w    d7
 bne.b    find_2
find_4:
 clr.b    (a5)
 move.l   a4,a1
 movea.l  ARGV(a6),a0
 move.l   4(a0),a0
 bsr      content
 tst.w    d0
 beq.b    find_5
 move.l   a4,a0
 bsr      strstdout
 bsr      crlf_stdout
find_5:
 tst.w    d6
 beq.b    find_1        * noch nicht EOF
find_end:
 movem.l  (sp)+,a5/a4/d7/d6
 unlk     a6
 rts
