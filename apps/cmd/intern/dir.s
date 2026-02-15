* void wholepath(a0 = char string[])
*  Wandelt eine Pfad- + Dateiangabe in den vollstÑndigen Pfad
*  (mit Laufwerk, ab Root) um.

STRING    SET  -200

wholepath:
 link     a6,#STRING
 movem.l  a4/a5,-(sp)
 movea.l  a0,a5
 bsr      str_upper
 lea      STRING(a6),a4
 move.l   a5,a0
 bsr      str_to_drive        * Laufwerksbezeichnung aus Pfad holen
 move.l   a4,a0
* move.w   d0,d0
 bsr      drive_to_defpath    * FÅr dieses Laufwerk Default- Pfad holen
 bsr      fatal
 move.l   a4,a0
 bsr      strlen
 lea      0(a4,d0.l),a0       * a0 = Ende des Strings
 move.l   a5,a2
 cmpi.b   #'\',-1(a0)         * Endet Default- Path mit '\' ?
 beq.b    wpt_1
 move.b   #'\',(a0)+
 clr.b    (a0)
wpt_1:
 cmpi.b   #':',1(a5)
 bne.b    wpt_2
 addq.l   #2,a2
wpt_2:
 cmpi.b   #'\',(a2)
 beq.b    wpt_end
 move.l   a2,a1
 move.l   a4,a0
 bsr      strcat
 move.l   a4,a1
 move.l   a5,a0
 bsr      strcpy
wpt_end:
 movem.l  (sp)+,a4/a5
 unlk     a6
 rts


* int dir_entry(name,dta)
* char *name, *dta;
*  Speichert den wichtigen Teil des DTA- Puffers fÅrs spÑtere Sortieren ab.

MAXDIR    EQU  512            * Maximal 512 Directory- EintrÑge

dir_entry:
 moveq    #1,d0
 lea      d+dir_zeilen(pc),a0
 cmpi.w   #MAXDIR,(a0)
 bge.b    dire_end              * Zuviele EintrÑge
 addq.w   #1,(a0)             * Anzahl der EintrÑge mitzÑhlen
 move.l   d+zeiger_adr(pc),a0
 lea      d+puffer_adr(pc),a2
 move.l   (a2),a1
 move.l   a1,(a0)+            * Zeiger auf Inhalt sichern
 move.l   a0,zeiger_adr-puffer_adr(a2)
 moveq    #44-20-1,d0         * sizeof(struct dta)-20(unwichtige Daten)
 move.l   8(sp),a0
 adda.w   #20,a0
dire_1:
 move.b   (a0)+,(a1)+         * Inhalt sichern
 dbra     d0,dire_1
 move.l   a1,(a2)             * neues Pufferende setzen
 clr.w    d0
dire_end:
 rts


* void dir_entry_print(filler, eintrag)
* long filler;
* DTA  *eintrag;
*  Druckt einen Directory- Eintrag (DTA-Struktur)
*  Er wird mit CR/LF abgeschlossen, wenn das w-Flag NICHT gesetzt war

dir_entry_print:
 link     a6,#0
 movem.l  d6/d7/a5/a4,-(sp)
 lea      d+dir_zeilen(pc),a0
 addq.w   #1,(a0)
 move.w   (a0),d6
 ext.l    d6
 movea.l  $c(a6),a5                * a5 = DTA
 btst     #4,21(a5)                          * Subdirectory ?
 bne.b    dep_30
 move.l   26(a5),d0
 add.l    d0,normal_len-dir_zeilen(a0)       * LÑnge akkumulieren
 addq.w   #1,normal_no-dir_zeilen(a0)        * Anzahl Dateien
dep_30:
 lea      leers(pc),a4
 cmpi.b   #'.',30(a5)              * Name beginnt mit '.'
 beq.b    dep_1
 moveq    #'.',d0
 lea      30(a5),a0      * Dateiname
 bsr      chrsrch
 beq.b    dep_1
 move.l   d0,a4          * a4 zeigt auf die Extension, sonst ""
 clr.b    (a4)+          * Den Punkt im Dateinamen lîschen
dep_1:
* Dateiname ausgeben
 move.b   d+w_flag(pc),d1
 beq.b    dep_12
 moveq    #' ',d0
 btst     #4,21(a5)                * Subdirectory ?
 beq.b    dep_13
 moveq    #'#',d0
dep_13:
 bsr      putchar
dep_12:
 lea      30(a5),a0
 bsr      strstdout                * Dateiname
 lea      30(a5),a0
 bsr      strlen
 move.w   #9,d7
 sub.w    d0,d7
 bra.b    dep_20
dep_21:
 moveq    #' ',d0
 bsr      putchar
dep_20:
 dbra     d7,dep_21
* Extension ausgeben
 move.l   a4,a0
 bsr      strstdout                * Extension
 move.l   a4,a0
 bsr      strlen
 move.w   #3,d7
 sub.w    d0,d7
 bra.b    dep_23
dep_22:
 moveq    #' ',d0
 bsr      putchar
dep_23:
 dbra     d7,dep_22
* Jetzt wird unterschieden, ob kurze oder lange Darstellung
 move.b   d+w_flag(pc),d1
 beq.b    dep_4
 move.l   d6,d0
 ext.l    d0
 divs     #5,d0
 swap     d0
 lea      space3_s(pc),a0
 tst.w    d0
 bne.b    dep_2
 lea      crlfs(pc),a0
dep_2:
 move.w   #115,d0
 bra      dep_7
* Jetzt kommt die lange Darstellung
dep_4:
 btst     #4,21(a5)                * Subdirectory ?
 beq.b    dep_5
 lea      dir_zeichens(pc),a0      * Ja
 bsr      get_country_str
 bsr      strstdout
 bra.b    dep_25
dep_5:
 moveq    #8,d1
 move.l   26(a5),d0                * Grîûe
 bsr      rwrite_long
dep_25:
 move.w   24(a5),d7                * Datum
 move.w   d7,d0
 andi.w   #$1f,d0
* Tag ausgeben (4 Zeichen, ohne fÅhrende '0')
 moveq    #4,d1
 ext.l    d0
 bsr      rwrite_long
* Minuszeichen ausgeben
 moveq    #'-',d0
 bsr      putchar
 lsr.w    #5,d7
 move.w   d7,d0
 andi.w   #$f,d0
* Monat ausgeben (2 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #2,d1
 ext.l    d0
 bsr      write_long
 lsr.w    #4,d7
 addi.w   #1980,d7
* Minuszeichen ausgeben
 moveq    #'-',d0
 bsr      putchar
* Jahr ausgeben (4 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #4,d1
 ext.l    d7
 move.l   d7,d0
 bsr      write_long
 move.w   22(a5),d7      * Zeit
 lsr.w    #5,d7          * Sekunden vergessen
* Stunden ausgeben (4 Zeichen, ohne fÅhrende '0')
 moveq    #4,d1
 move.w   d7,d0
 lsr.w    #6,d0
 ext.l    d0
 bsr      rwrite_long
* Doppelpunkt ausgeben
 moveq    #':',d0
 bsr      putchar
* Minuten ausgeben (2 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #2,d1
 andi.w   #$3f,d7
 ext.l    d7
 move.l   d7,d0
 bsr      write_long
 move.b   d+s_flag(pc),d0
 beq.b    dep_14
 lea      space3_s+1(pc),a0
 bsr      strstdout
 clr.w    d0
 move.b   21(a5),d0
 bsr      print_attr
dep_14:
* mit crlf abschlieûen
 lea      crlfs(pc),a0
 move.w   #20,d0
dep_7:
 divu     d0,d6
 swap     d6
 bsr      strstdout
 move.b   d+p_flag(pc),d0
 beq.b    dep_11
 tst.w    d6
 bne.b    dep_11
 lea      taste_drueckens(pc),a0
 bsr      get_country_str
 bsr      strcon
 bra.b    dep_9
dep_8:
 gemdos   Cnecin
 addq.l   #2,sp
dep_9:
 gemdos   Cconis
 addq.l   #2,sp
 tst.w    d0
 bne.b    dep_8
 gemdos   Cnecin
 addq.l   #2,sp

 IFF      KAOS

 cmpi.b   #3,d0               * CTRL-C ?
 beq      break

 ENDC

 lea      dellines(pc),a0
 bsr      strcon
dep_11:
 clr.w    d0
 movem.l  (sp)+,a5/a4/d7/d6
 unlk     a6
 rts


* int cmp_dta(a0 = char *eintrag1, a1 = char *eintrag2)
*  Vergleicht zwei Directory- EintrÑge (ab Byte 21)
*  sort_mode : 'A' nach Art (type)
*              'G' nach Grîûe (size)
*              'D' nach Datum/Zeit
*              sonst: nach Namen

cmp_dta:
 move.b   sort_mode(pc),d2
 btst     #4,21-20(a0)   * Attribut = Subdir ?
 beq.b    cmpd_1             * nein
 btst     #4,21-20(a1)
 bne.b    cmpd_2             * Beides Verzeichnisse => sortiere nach Namen
* Jetzt ist e1 subdir, e2 nicht => e2 > e1
 moveq    #-1,d0
 bra      cmpd_end
cmpd_1:
 btst     #4,21-20(a1)
 beq.b    cmpd_3             * Beides normale Dateien
* Jetzt ist e1 normal, e2 Subdir => e2 < e1
 moveq    #1,d0
 bra      cmpd_end
cmpd_3:
 cmpi.b   #'G',d2			* "Grîûe"
 bne.b    cmpd_6
cmpd_size:
 move.l   26-20(a1),d1   * nach Grîûe sortieren
 sub.l    26-20(a0),d1
cmpd_12:
 tst.l    d1
 beq.b    cmpd_2             * Grîûe oder Datum+Zeit gleich => Namensvergleich
 moveq    #1,d0
 tst.l    d1
 bgt.b    cmpd_5             * erster Eintrag grîûer
 moveq    #-1,d0
cmpd_5:
 bra.b    cmpd_end
cmpd_6:
 cmpi.b   #'A',d2			* "Art"
 bne.b    cmpd_10
cmpd_type:
 movem.l  a0/a1,-(sp)
 adda.w   #30-20,a0      * Zeiger auf den Namen
 adda.w   #30-20,a1
cmpd_7:
 tst.b    (a0)
 beq.b    cmpd_8
 cmpi.b   #'.',(a0)+
 bne.b    cmpd_7
cmpd_8:
 tst.b    (a1)
 beq.b    cmpd_9
 cmpi.b   #'.',(a1)+
 bne.b    cmpd_8
cmpd_9:
* move.l   a1,a1
* move.l   a0,a0
 bsr      strcmp
 movem.l  (sp)+,a0/a1
 bne.b    cmpd_end
 bra.b    cmpd_2             * Typ gleich => Namensvergleich
cmpd_10:
 cmpi.b   #'D',d2			* "Datum" oder "Date"
 beq.b    cmpd_13
cmpd_2:
 lea      30-20(a1),a1   * Namen vergleichen
 lea      30-20(a0),a0
 bsr      strcmp
 bra.b    cmpd_end
cmpd_13:
 move.w   24-20(a1),d1   * Datum vergleichen
 sub.w    24-20(a0),d1
 ext.l    d1
 bne.b    cmpd_11            * Wie bei LÑnge
 move.w   22-20(a1),d1   * Datum gleich => Zeit vergleichen
 sub.w    22-20(a0),d1
 ext.l    d1
cmpd_11:
 bra.b    cmpd_12
cmpd_end:
 rts


STRING         SET  -(16+150+200)       * char STRING[200]
DUMMYSTRING    SET  -(16+150)           * char DUMMYSTRING[150]
DFREE_BUFFER   SET  -16                 * long DFREE_BUFFER[4]

dir_com:
 link     a6,#STRING
 movem.l  d7/a3/a4/a5,-(sp)
 lea      d+w_flag(pc),a3
 clr.w    (a3)
 clr.b    q_flag-w_flag(a3)
 clr.b    s_flag-w_flag(a3)
 clr.l    normal_len-w_flag(a3)
 clr.w    normal_no-w_flag(a3)
* clr.b    w_flag
* clr.b    p_flag
* clr.b    q_flag
 bsr      memavail
 move.l   #MAXDIR*28,d1       * 512 Eintr. * (24 Byt. LÑnge + 4 Byt. Zeiger)
 suba.l   a4,a4
 cmp.l    d1,d0
 bcs.b    dir_30
 move.l   d1,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq      dir_end
 move.l   d0,a4               * a4 ist Pufferadresse
dir_30:
 subq.w   #1,ARGC(a6)
 bgt.b    dir_1
 movea.l  ARGV(a6),a0
 lea      star_pt_star(pc),a1   * "*.*"
 move.l   a1,4(a0)
 move.w   #1,ARGC(a6)
dir_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5                  * a5[] ist Parameter
 cmpi.b   #'-',(a5)
 bne.b    dir_6
 addq.l   #1,a5
dir_13:
 move.b   (a5)+,d0
 bsr      d0_upper
 cmpi.b   #'W',d0                  * "WIDE" = breite Ausgabe
 bne.b    dir_2
 st       (a3)
 bra.b    dir_4
dir_2:
 cmpi.b   #'P',d0                  * "PAGE" = seitenweise Ausgabe
 bne.b    dir_10
 st       p_flag-w_flag(a3)
 bra.b    dir_4
dir_10:
 cmpi.b   #'S',d0                  * "SYSTEM" = alle Dateien + Attribute
 bne.b    dir_3
 st       s_flag-w_flag(a3)
 bra.b    dir_4
dir_3:
 cmpi.b   #'Q',d0                  * "QUICK" = ohne freier Speicher
 bne.b    dir_5
 st       q_flag-w_flag(a3)
 bra.b    dir_4
dir_5:
 lea      sort_mode(pc),a0
 move.b   d0,(a0)                  * Falls weder -W noch -P noch -Q, dann Sortiermodus
dir_4:
 tst.b    (a5)
 bne.b    dir_13
 cmpi.w   #1,ARGC(a6)
 bne      dir_11
 addq.w   #1,ARGC(a6)
 movea.l  ARGV(a6),a0
 lea      star_pt_star(pc),a1 * "*.*"
 move.l   a1,4(a0)
 bra      dir_11
*
* Verzeichnis ausgeben
*
dir_6:
 cmpi.w   #1,ARGC(a6)
 beq.b    dir_32
 st       q_flag-w_flag(a3)   * mehrere Verzeichnisse: q- Flag setzen
dir_32:
 move.l   a5,a0
 bsr      str_to_drive
 move.w   d0,d7               * d7 enthÑlt den Laufwerks- Code
 blt      dir_11                 * Fehler => nÑchstes Argument
 tst.b    q_flag-w_flag(a3)
 bne.b    dir_7
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree
 addq.l   #8,sp
 bsr      fatal
 move.w   d7,d0
 bsr      label_to_stdout
 bra.b    dir_14
dir_7:
 bsr      crlf_stdout
dir_14:
 lea      DUMMYSTRING(a6),a2
 lea      STRING(a6),a1
 move.l   a5,a0
 bsr      split_path
 lea      verzchn_vons(pc),a0      * "Verzeichnis von "
 bsr      get_country_str
 bsr      strstdout
 lea      STRING(a6),a0
 bsr      wholepath
 lea      STRING(a6),a0
 bsr      strstdout
 lea      sort_mode(pc),a0
 move.l   a4,d0                    * Speicher vorhanden ?
 bne.b    dir_31				* ja
 move.b   #'U',(a0)                * kein Speicher => nicht sortieren
dir_31:
 move.b   (a0),d0
 lea      nach_art_s(pc),a0		* "nach Art" oder "by type"
 cmpi.b   #'A',d0
 beq.b    dir_print_sort
 lea      nach_grs_s(pc),a0		* "nach Grîûe"
 cmpi.b   #'G',d0
 beq.b    dir_print_sort
 lea      nach_dat_s(pc),a0		* "nach Datum" oder "by date"
 cmpi.b   #'D',d0
 beq.b    dir_print_sort
 lea      nach_nix_s(pc),a0		* "unsorted" oder "unsortiert"
 cmpi.b   #'U',d0
 bne.b    dir_skip_sort_output
dir_print_sort:
 bsr      get_country_str
 bsr      strstdout
dir_skip_sort_output:
 bsr      crlf_stdout
 bsr      crlf_stdout
* Jetzt wird das gesamte Verzeichnis in den Puffer geschrieben
* oder gleich ausgedruckt, falls <sort_mode> = 'U'(nsortiert)
 move.l   a4,zeiger_adr-w_flag(a3)
 lea      4*MAXDIR(a4),a0
 move.l   a0,puffer_adr-w_flag(a3)
 clr.w    dir_zeilen-w_flag(a3)
 lea      dir_entry(pc),a1
 lea      sort_mode(pc),a0
 cmpi.b   #'U',(a0)				* "unsorted"
 bne.b    dir_27
 lea      dir_entry_print(pc),a1
dir_27:
 moveq    #$10,d0                  * normale Dateien + Subdir
 tst.b    s_flag-w_flag(a3)
 beq.b    dir_12
 addq.w   #6,d0                    * norm + Subdir + Hid + Syst
dir_12:
 move.l   a5,a0
 bsr      for_all
 lea      keine_dateiens(pc),a0
 beq.b    dir_8
 lea      sort_mode(pc),a0
 cmpi.b   #'U',(a0)				* "unsorted"
 beq.b    dir_28
*
* Das Verzeichnis wird jetzt sortiert, falls <sort_mode> <> 'U'
*
 move.l   a4,-(sp)				* Zeigertabelle
 lea      d+dir_zeilen(pc),a0
 move.w   (a0),d7
 clr.w    (a0)
 ext.l    d7
 move.l   d7,-(sp)				* Anzahl Elemente
 pea      cmp_dta(pc)        		* Vergleichs- Routine
 bsr      shellsort
 adda.w   #12,sp
* Das Verzeichnis wird ausgegeben
 subq.w   #1,d7
 move.l   a4,a5
dir_21:
 move.l   (a5)+,-(sp)
 subi.l   #20,(sp)            * Die Puffer werden nur ab Byte 20 gespeichert
 clr.l    -(sp)
 bsr      dir_entry_print
 addq.l   #8,sp
 dbra     d7,dir_21
*
* Korrektur fÅr w- Format
*
dir_28:
 move.b   d+w_flag(pc),d0
 beq.b    dir_29
 bsr      crlf_stdout
*
* Jetzt noch die Schluûzeilen
*
dir_29:
 cmpi.w   #1,ARGC(a6)              * war letztes Argument ?
 bne.b    dir_11                      * nein
 bsr      crlf_stdout
 moveq    #8,d1
 move.l   d+normal_len(pc),d0
 bsr      rwrite_long
 lea      n_dbytes(pc),a0
 bsr      get_country_str
 bsr      strstdout
 moveq    #11,d1
 move.w   d+normal_no(pc),d0
 ext.l    d0
 bsr      rwrite_long
 lea      n_dateiens(pc),a0
dir_8:
 bsr      get_country_str
 bsr      strstdout
 bsr      crlf_stdout
 tst.b    q_flag-w_flag(a3)
 bne.b    dir_11
 lea      DFREE_BUFFER(a6),a0
 bsr      print_free
dir_11:
 subq.w   #1,ARGC(a6)
 bne      dir_1
 bsr      free_tpa
dir_end:
 movem.l  (sp)+,a5/a4/a3/d7
 unlk     a6
 rts
