* int unlink(dateiname)
*  Lîscht eine Datei, deren Name als Parameter Åbergeben wurde
*  Ist query_flag != 0, wird vorher die Sicherheitsfrage gestellt
*  RÅckgabe 1, wenn Fehler aufgetreten

unlink:
 link     a6,#-4
 move.b   d+query_flag(pc),d0
 beq      unl_6
 lea      loesch_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      auswahl_s(pc),a0
 bsr      get_country_str
 bsr      strcon
unl_ask_again:
 gemdos   Cnecin
 addq.l   #2,sp
 bsr      d0_upper

 IFF      KAOS
 cmpi.b   #3,d0
 beq.b    unl_2
 ENDC

 cmpi.b   #'G',d0				* "Global"
 beq.b    unl_global
 cmpi.b   #'A',d0				* "Abort"?
 beq.b    unl_abort
 cmpi.b   #'Q',d0				* "Quit"?
 beq.b    unl_abort
 cmpi.b   #'J',d0				* "Ja"
 beq.b    unl_yes
 cmpi.b   #'Y',d0				* "Yes"
 beq.b    unl_yes
 cmpi.b   #'O',d0				* "Oui"
 beq.b    unl_yes
 cmpi.b   #'N',d0				* "Nein", "Non, "No"
 bne.b    unl_ask_again
 lea      nein_s(pc),a0            * Nein
 bsr      get_country_str
 bsr      strcon
 clr.w    d0
 bra.b    unl_ret_d0

 IFF      KAOS
unl_2:
 bra      break     * CTRL-C
 ENDC

unl_global:
 lea      d+query_flag(pc),a0
 clr.b    (a0)                     * Global: Flag fÅr Sicherheitsfrage lîschen
 lea      global_s(pc),a0
 bra.b    unl_1
unl_abort:
 lea      quit_s(pc),a0            * Quit
 bsr      get_country_str
 bsr      strcon
 moveq    #1,d0
 bra.b    unl_ret_d0
unl_yes:
 lea      ja_s(pc),a0              * Ja
unl_1:
 bsr      get_country_str
 bsr      strcon
unl_6:
 move.l   8(a6),(sp)
 gemdos   Fdelete
 addq.l   #2,sp
 tst.l    d0
 bge.b    unl_8                       * alles ok
 move.w   d0,-(sp)
 bsr      crlf_con
 move.w   (sp)+,d0
 bsr      print_err
 lea      auf_s(pc),a0             * Fehler
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 bsr      inc_errlv
 bra.b    unl_10
unl_8:
 move.b   d+query_flag(pc),d0
 bne.b    unl_10
 lea      dels(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
unl_10:
 clr.w    d0
unl_ret_d0:
 unlk     a6
 rts


STRING1   SET  -150                * char *STRING1[150]
STRING2   SET  STRING1-150         * char *STRING2[150]

del_com:
 link     a6,#STRING2
 movem.l  a5/d7,-(sp)
 moveq    #1,d7                    ; kein N- Flag
 subq.w   #1,ARGC(a6)
 bgt.b    del_1
 lea      syntax_dels(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
 bra.b    del_end
del_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5
 move.l   a5,a0
 cmpi.b   #'-',(a0)+
 bne.b    del_4
 move.b   (a0)+,d0
 bsr      d0_upper
 cmpi.b   #'N',d0
 bne.b    del_4
 move.b   (a0),d0
 bne.b    del_4
* "-N"
 moveq    #0,d7
 bra.b    del_3                       ; nÑchste Datei
del_4:
 lea      STRING1(a6),a2
 lea      STRING2(a6),a1
 move.l   a5,a0
 bsr      split_path
 tst.w    d0
 beq.b    del_2
 lea      STRING2(a6),a0
 bsr      enth_jok
del_2:
 lea      d+query_flag(pc),a0
 and.b    d7,d0
 move.b   d0,(a0)
 lea      unlink(pc),a1  * auszufÅhrende Routine
 moveq    #6,d0          * Dateityp = alle auûer Subdir
 move.l   a5,a0          * Dateiname(nsmuster)
 bsr      for_all
 bne.b    del_3
 bsr      crlf_con
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
del_3:
 subq.w   #1,ARGC(a6)
 bne.b    del_1
 bsr      crlf_con
del_end:
 movem.l  (sp)+,a5/d7
 unlk     a6
 rts
