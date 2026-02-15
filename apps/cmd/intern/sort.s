sort_com:
 link     a6,#0
 movem.l  d4/d5/d7/a3/a4/a5,-(sp)
 lea      d+r_flag(pc),a2
 clr.w    (a2)
* clr.b    r_flag
* clr.b    c_flag
 clr.w    schluessel-r_flag(a2)
 bra.b    sort_8
sort_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5
 lea      syntax_sorts(pc),a0
 cmpi.b   #'-',(a5)+
 bne.b    sort_11
 cmpi.b   #'1',(a5)
 blt.b    sort_4
 cmpi.b   #'9',(a5)
 bgt.b    sort_4
 move.l   a5,a0
 bsr      str_toi
 subq.w   #1,d0
 blt.b    sort_4
 move.w   d0,schluessel-r_flag(a2)
sort_4:
 move.b   (a5),d0
 bsr      d0_upper
 cmpi.b   #'R',d0
 bne.b    sort_5
 st       (a2)           * r_flag
sort_5:
 cmpi.b   #'C',d0
 bne.b    sort_8
 st       c_flag-r_flag(a2)
sort_8:
 subq.w   #1,8(a6)
 bne.b    sort_1
 bsr      memavail
 move.l   d0,d5
 beq.b    sort_10
* move.l   d5,d0
 bsr      alloc_tpa                * Z=1, wenn Fehler
 beq.b    sort_50
 move.l   d0,a3
 cmpi.l   #1000,d5
 bcc.b    sort_12
sort_10:
 lea      sort_memerrs(pc),a0
sort_11:
 bsr      get_country_str
 bsr      strcon
sort_50:
 bsr      inc_errlv
 bra      sort_25
sort_12:
* Zeigerpuffer a4 bis d4, Stringpuffer a5 bis d5
 movea.l  a3,a4          * Anfang des Zeigerpuffers
 move.l   a3,a5
 move.l   d5,d4
 lsr.l    #3,d4
 sub.l    d4,d5          * d5 = L„nge des Stringpuffers a5[]
 add.l    a4,d4
 move.l   d4,a5          * a5 = Anfang des Stringpuffers
 subq.l   #4,d4          * d4 = Ende des Zeigerpuffers
 add.l    a5,d5
 subq.l   #4,d5          * d5 = Ende des Stringpuffers
 clr.l    d7             * Anzahl gelesener Strings
 move.l   a5,(a4)+       * Adresse des ersten Strings
 bra.b    sort_18
sort_13:
 move.l   a5,a0
 moveq    #1,d1
 moveq    #STDIN,d0      * lies ein Byte von stdin nach a5[]
 bsr      read
 bsr      fatal
 subq.l   #1,d0
 bne.b    sort_21            * Datei- Ende
 cmpi.b   #$1a,(a5)      * EOF ?
 beq.b    sort_21
 cmpi.b   #CR,(a5)       * CR einfach berlesen
 beq.b    sort_18
 cmpi.b   #LF,(a5)+
 bne.b    sort_18
 clr.b    -1(a5)         * LF bedeutet EOL => EOL speichern
 addq.l   #1,d7          * Anzahl gelesener Strings
 move.l   a5,(a4)+
sort_18:
 cmpa.l   d5,a5          * a4[] schon voll ?
 bcc.b    sort_10            * Zuwenig Speicher (Stringbereich)
 cmpa.l   d4,a4
 bcc.b    sort_10            * Zuwenig Speicher (Pointerfeld)
 bra.b    sort_13            * weiter einlesen
* Hier ist das Einlesen fertig, und wir kommen zum Sortieren:
sort_21:
 clr.b    (a5)
 move.l   a3,-(sp)                 * Adresse des Pointerfeldes
 move.l   d7,-(sp)                 * Anzahl gelesener Zeichenketten = L„nge desselben
 pea      cmps(pc)                 * Vergleichsfunktion
 bsr      shellsort
 adda.w   #12,sp
 tst.l    d7
 beq.b    sort_25                      * Anzahl ist Null
sort_22:
 move.l   (a3)+,a0
 bsr      strstdout                * String ausgeben
 bsr      crlf_stdout              * CR/LF hinterhersenden
 lea      sort_zielvolls(pc),a0
 bsr      get_country_str
 bsr      fatal
 subq.l   #1,d0
 bne      sort_11
 subq.l   #1,d7
 bne.b    sort_22
sort_25:
 bsr      free_tpa
sort_end:
 movem.l  (sp)+,a5/a4/a3/d7/d5/d4
 unlk     a6
 rts
