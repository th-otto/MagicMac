* int input(string,len)
* char *string;
* int  len;
*            Register a3 ist global in diesem Modul

* lokal  akt_len d6
*        zeiger  d7
*        x       d4
*        string  a5
*        maxlen  d5
*        Ftaste  a4
*            Register a3 ist global in diesem Modul

input:
 link     a6,#0
 movem.l  a5/a4/a3/d7/d6/d5/d4,-(sp)
 DC.W     A_INIT
 move.l   a0,a3               * a3 = Zeiger auf LineA
 move.l   8(a6),a5
 move.w   $c(a6),d5
 bsr      cursor              * Cursor einschalten
 lea      d+home_ypos(pc),a0
 move.w   v_cur_cx(a3),d4     * Cursorspalte
 move.w   v_cur_cy(a3),(a0)   * home_ypos,  Cursorzeile
 clr.w    d7
 clr.w    d6
 suba.l   a4,a4
inp_1:
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr      gotox               * gotox(x+zeiger)
 addq.l   #2,sp
 move.l   a4,d0
 beq.b    inp_15
 move.b   (a4),d0
 beq.b    inp_15
 addq.l   #1,a4
 cmpi.b   #LF,d0
 beq      inp_end
 cmpi.b   #CR,d0
 beq      inp_end
 bra      inp_20
inp_15:
 gemdos   Cnecin
 addq.l   #2,sp
 andi.l   #$00ffffff,d0       * evtl. Shiftstatus lîschen
 cmpi.l   #K_CTRL_C,d0        * CTRL-C bewirkt Warmstart
 bne.b    inp_80
 gemdos   Pterm0
inp_80:
 cmpi.l   #CR,d0              * CR Åberlesen, wenn Tastaturcode 0
 beq.b    inp_1
 cmpi.l   #LF,d0              * LF schlieût ab, wenn Tastaturcode 0
 beq      inp_end
 cmpi.l   #K_RETURN,d0
 beq      inp_90
 cmpi.l   #K_ENTER,d0
 beq      inp_end                * RETURN und ENTER beenden die Eingabe
 cmpi.l   #K_BS,d0
 bne.b    inp_2
 tst.w    d7
 beq.b    inp_1                  * Zeiger ist auf Feldanfang
 subq.w   #1,d7
inp_3:
 bsr      str_del             * Zeichen vor Cursorposition lîschen
 bsr      string_at
 moveq    #' ',d0
 bsr      putch
 bra      inp_1                  * weiter
inp_2:
 cmpi.l   #K_DEL,d0
 beq.b    inp_3                  * analog zu BACKSPACE
 cmpi.l   #K_TAB,d0
 bne.b    inp_4
 cmp.w    d6,d7               * zeiger am Feldende ?
 bcs.b    inp_5
 clr.w    d7                  * zeiger nach Feldanfang
 bra      inp_1
inp_5:
 move.w   d6,d7               * zeiger nach Feldende
 bra      inp_1
inp_4:
 cmpi.l   #K_LTARROW,d0
 bne.b    inp_6
 tst.w    d7
 beq      inp_1
 subq.w   #1,d7
 bra      inp_1
inp_6:
 cmpi.l   #K_RTARROW,d0
 bne.b    inp_7
 cmp.w    d6,d7
 bcc      inp_1
 addq.w   #1,d7
 bra      inp_1
inp_7:
 cmpi.l   #K_INSERT,d0
 bne.b    inp_8
 lea      ovwr_flag(pc),a0
 not.w    (a0)
 bra      inp_1
inp_8:
 cmpi.l   #K_CLR,d0
 bne.b    inp_9
 move.w   d6,-(sp)
 move.w   d4,-(sp)
 bsr      spacestr_at
 addq.l   #4,sp
 clr.w    d6
 clr.w    d7
 bra      inp_1
inp_9:
 cmpi.l   #K_UNDO,d0
 bne.b    inp_10
 lea      d+laststring(pc),a4
 bra      inp_1
inp_10:
 cmpi.l   #K_F1,d0
 blt      inp_20
 cmpi.l   #K_F10,d0
 bgt      inp_20
 swap     d0
 addi.b   #'0'-$3b+1,d0
 cmpi.b   #'9',d0
 ble.b    inp_11
 move.b   #'0',d0             * F10 als F0 darstellen
inp_11:
 lea      func_s(pc),a0
 move.b   d0,1(a0)
* move.l   a0,a0
 bsr      getenv
 tst.l    d0
 beq      inp_1                  * Funktionstaste nicht belegt
 move.l   d0,a4
 bra      inp_1
* Jetzt kommen die druckbaren Zeichen:
inp_20:
 clr.w    d2
 move.b   d0,d2                    * obere 8 Bit lîschen
 beq      inp_1
 cmp.w    d5,d7                    * Eingabefeld voll ?
 bge      inp_1
 move.w   ovwr_flag(pc),d0
 beq.b    inp_21
 bsr      str_del
inp_21:
 bsr      str_ins
 bsr      string_at
 addq.w   #1,d7
 bra      inp_1
inp_90:
 move.w   d6,d0
 subq.w   #1,d0
 bcs.b    inp_end                * Leerstring eingegeben
 move.l   a5,a1
 lea      d+laststring(pc),a0
 cmpi.w   #128,d0
 bls.b    inp_91
 move.w   #128,d0
inp_91:
 move.b   (a1)+,(a0)+
 dbra     d0,inp_91
 clr.b    (a0)
inp_end:
 clr.b    0(a5,d6.w)          * Erzeuge EOS am Ende
 move.l   a5,-(sp)
 bsr      str_adjust
 addq.l   #4,sp
 moveq    #CR,d0
 bsr      putch
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4
 unlk     a6
 rts



* void gotox(x)
* int x;


gotox:
 moveq    #$1b,d0
 bsr      putch
 moveq    #'Y',d0
 bsr      putch
 moveq    #32,d0
 add.w    d+home_ypos(pc),d0
 clr.l    d1
 move.w   4(sp),d1
 move.w   v_cel_mx(a3),d2
 addq.w   #1,d2
 divu     d2,d1
 add.w    d1,d0
 swap     d1
 move.w   d1,-(sp)
 bsr      putch
 moveq    #32,d0
 add.w    (sp)+,d0
 bsr      putch
 rts


**********************************************************************
*
* void str_at()
*
*  Schreibt den String <char a5[]>, der eine LÑnge von <int d6> hat,
*  ab Position <int d7> nach Bildschirm- Position <int d4>
*

string_at:
 movem.l  d3/a4,-(sp)
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr.b    gotox
 addq.l   #2,sp
 move.l   a5,a4
 adda.w   d7,a4                    ; a4 = ab hier ausgeben
 move.w   d6,d3
 sub.w    d7,d3                    ; d3 = Anzahl auszugebender Zeichen
 bra.b    strat_2
strat_1:
 move.w   v_cur_cy(a3),-(sp)
 clr.w    d0
 move.b   (a4)+,d0
 move.w   d0,-(sp)
 move.w   #5,-(sp)
 bios     Bconout
 addq.l   #6,sp
 move.w   (sp)+,d0

* Falls sich der Cursor nach der Ausgabe links befindet und er vorher
* auf der letzten Zeile stand, muû der Bildschirm gescrollt haben.
* Folglich wandert unsere Home- Position nach oben

 tst.w    v_cur_cx(a3)
 bne.b    strat_2
 cmp.w    v_cel_my(a3),d0
 bcs.b    strat_2
 lea      d+home_ypos(pc),a0
 subq.w   #1,(a0)
strat_2:
 dbra     d3,strat_1
 movem.l  (sp)+,d3/a4
 rts


* void spacestr_at(x,len)
* int x,len;

spacestr_at:
 link     a6,#0
 move.w   8(a6),-(sp)
 bsr      gotox
 addq.l   #2,sp
sstrat_1:
 subq.w   #1,$a(a6)
 bcs.b    sstrat_end
 moveq    #' ',d0
 bsr      putch
 bra.b    sstrat_1
sstrat_end:
 unlk     a6
 rts


**************************************************************
*
* fÅgt in einen String <char a5[]> der MaximallÑnge <int d5>
* an Position <int d7> das Zeichen <char d2> ein.
* akt_len (d6) wird entsprechend erhîht
*
**************************************************************

* void str_ins()

str_ins:
 move.l   a5,a1
 adda.w   d7,a1                    ; a0 = EinfÅgeposition
 move.l   a5,a0
 add.w    d6,a0                    ; a0 = String- Ende
 cmp.w    d5,d6
 beq.b    strins_90                ; akt_len == max_len
 bra.b    strins_1
strins_2:
 move.b   (a0),1(a0)
strins_1:
 subq.l   #1,a0
 cmpa.l   a1,a0
 bcc.b    strins_2
 addq.w   #1,d6
strins_90:
 move.b   d2,(a1)
 rts


**************************************************************
*
* nimmt aus einem <char a5[]> der LÑnge <int d6> an Position
* <int d7> ein Zeichen heraus.
* Die LÑnge wird entsprechend korrigiert
*
**************************************************************

* void str_del()

str_del:
 move.l   a5,a0
 adda.w   d7,a0                    ; a0 = string + pos
 move.w   d6,d0
 sub.w    d7,d0                    ; d1 = len - pos
 beq.b    sd100
 bra.b    sd3
sd2:
 move.b   1(a0),(a0)+
sd3:
 dbra     d0,sd2
 subq.w   #1,d6                    ; len = len - 1
sd100:
 rts


**************************************************************
*
* Entfernt aus einem <string> die rechtsbÅndigen Leerstellen.
* Wenn <string> nur aus Leerstellen besteht, bekommt <string>
* die LÑnge 0.
*
**************************************************************

* void str_adjust(string)
* char string[];

str_adjust:
 move.l   4(sp),a0
 move.l   a0,a1
stradj_1:
 tst.b    (a0)+
 bne.b    stradj_1
 subq.l   #1,a0
stradj_2:
 cmpa.l   a0,a1
 bcc.b    stradj_end
 cmpi.b   #' ',-(a0)
 beq.b    stradj_2
 addq.l   #1,a0
stradj_end:
 clr.b    (a0)
 rts
