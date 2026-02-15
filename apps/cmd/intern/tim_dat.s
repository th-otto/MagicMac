* int number_a5(a5 = char *string, d0 = int default)
*  Zeiger auf einen Stringzeiger in a5 als Ein- und Ausgabe
*  Rechnet den String in einen int- Wert um und gibt diesen zurÅck.
*  Ist der String = "", wird <default> zurÅckgegeben.
*  Der Stringzeiger a5 wird nach Einlesen auf den Beginn der nÑchsten
*  Zahl gestellt.

number_a5:
 tst.b    (a5)
 beq.b    numa5_5
 clr.w    d0
 bra.b    numa5_2
numa5_1:
 muls     #10,d0
 add.w    d1,d0
numa5_2:
 move.b   (a5)+,d1            * Zeichen aus String holen
 ext.w    d1
 subi.w   #'0',d1
 cmpi.w   #9,d1
 bls.b    numa5_1
 subq.l   #1,a5               * a1 auf erstes nichtnumerisches Zeichen
numa5_3:
 move.b   (a5)+,d1
 beq.b    numa5_6
 subi.b   #'0',d1
 cmpi.b   #9,d1
 bhi.b    numa5_3
numa5_6:
 subq.l   #1,a5
numa5_5:
 rts


STRING         SET  -140

time_com:
 lea      akt_time_is(pc),a0
 lea      time_to_str(pc),a1
 lea      give_times(pc),a2
 moveq    #Tgettime,d0
 moveq    #$3f,d2
 moveq    #0,d1
 bra.b    da_ti
date_com:
 lea      akt_date_is(pc),a0
 lea      date_to_str(pc),a1
 lea      give_dates(pc),a2
 moveq    #Tgetdate,d0
 moveq    #$f,d2
 moveq    #1,d1
da_ti:
 link     a6,#STRING
 movem.l  d4/d5/d6/d7/a5,-(sp)
 move.w   d0,d5
 move.w   d1,d4
 move.w   d2,d6
 movea.l  ARGV(a6),a5
 move.l   4(a5),a5
 subq.w   #2,ARGC(a6)              * mindestens ein Parameter
 bge.b    timec_1
*
* Falls kein Parameter eingegeben wurde, wird von STDIN gelesen
*
 lea      STRING(a6),a5
* move.l a0,a0
 bsr      get_country_str
 move.l   a2,-(sp)
 move.l   a1,-(sp)
 bsr      strstdout
 move.l   (sp)+,a1
 move.l   a5,a0
 jsr      (a1)                     * date/time_to_str
 move.l   a5,a0
 bsr      strstdout
 move.l   (sp)+,a0
 bsr      get_country_str
 bsr      strcon
 move.l   a5,a0
 clr.w    d0
 bsr      read_str
 tst.b    (a5)
 beq      dati_20
*
* Aktuelle Zeit/Datum in TMJ bzw. SMS zerlegen (d5,d6,d7)
*
timec_1:
 move.w   d5,-(sp)       * Tgettime/Tgetdate
 trap     #1
 addq.l   #2,sp
 move.w   d0,d5
 and.w    #$1f,d5        * d5 = aktueller Tag
 moveq    #1,d1
 sub.w    d4,d1
 asl.w    d1,d5          * Sekunden
 lsr.w    #5,d0
 and.w    d0,d6
 moveq    #6,d1
 sub.w    d4,d1
 sub.w    d4,d1
 lsr.w    d1,d0
 move.w   d0,d7          * d7 = aktuelles Jahr
 tst.w    d4
 beq.b    dati_2
 add.w    #1980,d7
 bra.b    dati_3
dati_2:
 exg      d7,d5
*
* String in Zahlen umwandeln. d5,d6,d7 als Default.
*
dati_3:
 move.w   d5,d0
 bsr      number_a5      * lies Tag ein
 move.w   d0,d5          * Tag nach d5
 move.w   d6,d0
 bsr      number_a5      * lies Monat ein
 move.w   d0,d6          * Monat nach d6
 move.w   d7,d0
 bsr      number_a5      * lies Jahr ein
 move.w   d0,d7          * Jahr nach d7
*
* d5,d6,d7 wieder packen und Uhrzeit/Datum setzen
*
 tst.w    d4
 beq.b    dati_4
 subi.w   #1980,d7
 bge.b    dati_5
 addi.w   #1900,d7
 bgt.b    dati_5
 addi.w   #100,d7
dati_5:
 moveq    #Tsetdate,d2
 moveq    #4,d1
 bra.b    dati_6
dati_4:
 exg      d5,d7
 asr.w    #1,d5          * Sekunden
 moveq    #Tsettime,d2
 moveq    #6,d1
dati_6:
 move.w   d7,d0
 lsl.w    d1,d0
 or.w     d6,d0
 lsl.w    #5,d0
 or.w     d5,d0
 move.w   d0,-(sp)
 move.w   d2,-(sp)
 trap     #1
 addq.l   #4,sp
 tst.l    d0
 bge.b    dati_20
 bsr      inc_errlv
 lea      falsches_forms(pc),a0
 bsr      get_country_str
 bsr      strcon
dati_20:
 movem.l  (sp)+,a5/d7/d6/d5/d4
 unlk     a6
 rts
