pause_com:
 move.l   a5,-(sp)
 move.l   SP_ARGV+4(sp),a5
 addq.l   #4,a5          * a5 auf ersten Parameter (argv[1])
 lea      taste_drueckens(pc),a0
 bsr      get_country_str
 subq.w   #1,SP_ARGC+4(sp)
 bne.b    pause_1
 move.l   a0,(a5)
pause_1:
 move.l   (a5)+,a0
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 subq.w   #1,SP_ARGC+4(sp)
 bgt.b    pause_1
 bra.b    pause_4
pause_3:
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
pause_4:
 move.w   #2,-(sp)
 bios     Bconstat
 addq.l   #4,sp
 tst.w    d0
 bne.b    pause_3
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
 cmpi.b   #3,d0          * CTRL-C
 beq      break
 lea      errorlevel(pc),a0
 move.w   d0,(a0)        * Taste merken fÅr Abfrage
 moveq    #CR,d0
 bsr      putch
 move.l   (sp)+,a5
 rts
