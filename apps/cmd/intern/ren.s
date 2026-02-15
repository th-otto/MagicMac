DEST      SET  -128

ren_com:
 link     a6,#DEST
 movem.l  a4/a5,-(sp)
 cmpi.w   #3,ARGC(a6)         * Genau zwei Argumente ?
 bne.b    ren_1
 movea.l  ARGV(a6),a0
 tst.l    (a0)+
 move.l   (a0)+,a4            * Pfadname (Quelle)
 move.l   (a0),a5             * Dateiname (Ziel)
 move.l   a4,a0
 bsr      enth_jok            * Quelle darf keinen Joker enthalten
 bne.b    ren_1
 move.l   a5,a0
 bsr      enth_jok            * Ziel darf keinen Joker enthalten
 bne.b    ren_1
 moveq    #':',d0
 move.l   a5,a0
 bsr      chrsrch
 bne.b    ren_1
 moveq    #'\',d0
 move.l   a5,a0
 bsr      chrsrch             * Ziel darf keine Pfadangabe enthalten
 bne.b    ren_1
 move.l   a4,a1
 lea      DEST(a6),a2
 move.l   a2,a0
 bsr      strcpy
 move.l   a2,a0
ren_2:
 tst.b    (a2)+
 bne.b    ren_2
ren_3:
 subq.l   #1,a2
 cmpa.l   a2,a0
 bhi.b    ren_5                  * nichts gefunden
 cmpi.b   #':',(a2)
 beq.b    ren_5                  * bis hier geht der Pfad
 cmpi.b   #'\',(a2)
 bne.b    ren_3
ren_5:
 clr.b    1(a2)
 move.l   a5,a1
* move.l   a0,a0
 bsr      strcat
 pea      DEST(a6)
 move.l   a4,-(sp)
 bsr      fileren
 addq.l   #8,sp
 tst.w    d0
 bne.b    ren_50
 bra.b    ren_end
ren_1:
 lea      ren_syntaxs(pc),a0
 bsr      get_country_str
 bsr      strcon
ren_50:
 bsr      inc_errlv
ren_end:
 movem.l  (sp)+,a4/a5
 unlk     a6
 rts
