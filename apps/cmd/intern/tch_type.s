TIME      SET  -4
DATE      SET  -2

touch_file:
 link     a6,#-4
 move.l   d7,-(sp)
 clr.w    d0
 move.l   8(a6),a0
 bsr      open
 move.w   d0,d7                    * nur echte Dateien
 bge.b    tf_2
 lea      kann_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      nicht_offn_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
 moveq    #1,d0
 bra.b    tf_50
tf_2:
 move.l   8(a6),a0
 bsr      strcon
 bsr      crlf_con
 gemdos   Tgettime
 addq.l   #2,sp
 move.w   d0,TIME(a6)
 gemdos   Tgetdate
 addq.l   #2,sp
 move.w   d0,DATE(a6)
 move.w   #1,-(sp)
 move.w   d7,-(sp)
 pea      TIME(a6)
 gemdos   Fdatime
 adda.w   #$a,sp
 move.w   d7,d0
 bsr      close
tf_50:
 move.l   (sp)+,d7
 unlk     a6
 rts


type_file:
 link     a6,#0
 movem.l  d6/d7/a5/a4,-(sp)
 bsr      memavail
 move.l   #1024,d6            * maximal 1k reservieren
 tst.l    d0
 beq.b    tyf_3               * kein Speicher frei => Fehler provozieren
 cmp.l    d6,d0               * mehr als 1k frei ?
 bhi.b    tyf_3               * trotzdem nur 1k holen
 move.l   d0,d6               * Sonst gesamten Speicher holen
tyf_3:
 move.l   d6,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq.b    tyf_12
 move.l   d0,a4               * a4 = Pufferadresse
 lea      datei_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 bsr      crlf_con
 bsr      crlf_con
 clr.w    d0
 move.l   8(a6),a0
 bsr      open
 move.l   d0,d7
 bge.b    tyf_2
 lea      kann_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      nicht_offn_s(pc),a0
 bsr      get_country_str
 bsr      strcon
tyf_12:
 bsr      inc_errlv
 moveq    #1,d0
 bra.b    tyf_50
tyf_1:
 move.l   a4,a0
 move.l   d0,d1
 moveq    #STDOUT,d0
 bsr      write
tyf_2:
 move.l   a4,a0
 move.l   d6,d1
 move.w   d7,d0
 bsr      read
 tst.l    d0
 bgt.b    tyf_1
 move.w   d7,d0
 bsr      close
 clr.w    d0
tyf_50:
 bsr      free_tpa
 movem.l  (sp)+,a4/a5/d7/d6
 unlk     a6
 rts

touch_com:
 lea      touch_file(pc),a1
 bra.b    t_com
type_com:
 lea      type_file(pc),a1
t_com:
 movem.l  a5/a4,-(sp)
 move.l   a1,a4
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    toty_2
 lea      syntax_ts(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
 bra.b    toty_end
toty_1:
 addq.l   #4,SP_ARGV+8(sp)
 movea.l  SP_ARGV+8(sp),a0
 movea.l  (a0),a5
 move.l   a4,a1
 moveq    #6,d0
 move.l   a5,a0
 bsr      for_all
 bne.b    toty_2
 bsr      crlf_con
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      get_country_str
 bsr      strcon
toty_2:
 subq.w   #1,SP_ARGC+8(sp)
 bne.b    toty_1
toty_end:
 movem.l  (sp)+,a5/a4
 rts
