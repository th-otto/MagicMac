goto_com:
 link     a6,#-130
 movem.l  a5/a4,-(sp)
 bsr      sav_errlv
 move.w   BATCH(a6),d0        * checken, ob im Batch- Modus
 beq.b    goto_end
 lea      -90(a6),a5
 cmpi.w   #2,ARGC(a6)
 blt.b    goto_50
 clr.w    -(sp)
 move.w   d0,-(sp)            * Handle der Batchdatei
 clr.l    -(sp)               * An den Anfang der Batchdatei gehen
 gemdos   Fseek
 adda.w   #$a,sp
 bra.b    goto_5
goto_1:
 move.l   a5,a0
 bsr      skip_sep
 move.l   d0,a4
 cmpi.b   #':',(a4)+
 bne.b    goto_5             * N„chste Zeile
 move.l   a4,a0
 bsr      search_sep
 clr.b    (a0)
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1
 move.l   a4,a0
 bsr      upper_strcmp   * Ist es das richtige Label ?
 beq.b    goto_end         * Gefunden !!
goto_5:
 move.l   a5,a0
 move.w   BATCH(a6),d0   * Batch- Handle
 bsr      read_str
 tst.w    d0
 beq.b    goto_1
goto_50:
 lea      lbl_not_found_s(pc),a0
 bsr      get_country_str
 bsr      strcon
goto_end:
 movem.l  (sp)+,a5/a4
 unlk     a6
 rts
