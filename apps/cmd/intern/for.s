for_com:
 link     a6,#-$80
 movem.l  a5/a4/a3/d6/d7,-(sp)
 lea      for_flag(pc),a3
 bsr      sav_errlv
 move.w   BATCH(a6),d6        * checken, ob im Batch- Modus
 beq      for_end
 clr.w    d7
 lea      -$80(a6),a4
 move.l   ARGV(a6),a5
for_11:
 addq.l   #4,a5
 subq.w   #1,ARGC(a6)         * Auf ersten Parameter
 beq      for_50
 lea      not_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    for_10
 moveq    #1,d7
 bra.b    for_11
for_10:
* Handle und Position der FOR- Anweisung feststellen
 move.w   #1,-(sp)
 move.w   d6,-(sp)
 clr.l    -(sp)
 gemdos   Fseek               * Ftell(d7)
 adda.w   #10,sp
 tst.w    (a3)                * for_flag
 beq.b    for_1                  * erstes Erreichen einer FOR- Schleife
 cmp.w    for_hdl(pc),d6
 bne      for_50
 cmp.l    for_pos(pc),d0
 bne      for_50
for_1:
 move.w   d6,for_hdl-for_flag(a3)
 move.l   d0,for_pos-for_flag(a3)
* Erstes Argument (die Laufvariable) holen
 move.l   (a5)+,a1            * Variable
 subq.w   #1,ARGC(a6)
 beq      for_50
 move.l   a4,a0
 bsr      strcpy              * Name der Variablen speichern
 lea      gleich_s(pc),a1        * "="
 move.l   a4,a0
 bsr      strcat
* Laufvariable neu setzen oder FOR- Schleife abbrechen
 addq.l   #4,a5               * Argument "(" Åberspringen
 subq.w   #1,ARGC(a6)
 ble.b    for_50
 move.w   (a3),d0             * for_flag, nÑchster Zustand der Laufvariablen
 move.w   ARGC(a6),d1
 sub.w    d0,d1
 ble.b    for_50                 * Ende der Argumentreihe (')' fehlt)
 move.w   d1,ARGC(a6)
 lsl.w    #2,d0               * mal 4 fÅr Index
 adda.w   d0,a5               * a5 zeigt auf neuen Wert
 move.l   (a5),a0
 cmpi.b   #')',(a0)
 bne.b    for_2
 tst.b    1(a0)
 bne.b    for_2
* ')' erreicht, nÑchster Befehl wird nicht ausgefÅhrt (wenn nicht NOT)
 clr.w    (a3)                * for_flag
 clr.w    d6
 bra.b    for_3
* Variablen- Zuweisung
for_2:
 moveq    #1,d6
 move.l   a0,a1
 move.l   a4,a0
 bsr      strcat
 addq.w   #1,(a3)             * for_flag
 move.l   a4,a0
 bsr      env_set             * Variable setzen
* Suche Ende der Zuweisungskette (Argument ')' )
for_3:
 move.l   (a5)+,a0
 subq.w   #1,ARGC(a6)
 bls.b    for_50                 * Zuwenig Argumente ( ')' fehlt)
 cmpi.b   #')',(a0)
 bne.b    for_3
 tst.b    1(a0)
 bne.b    for_3
 subq.l   #4,a5
 addq.w   #1,ARGC(a6)
 bra      exe_restzeile       * Wie bei IF
for_50:
 lea      for_error_s(pc),a0
 bsr      get_country_str
 bsr      strcon
for_end:
 movem.l  (sp)+,a5/a4/d6/d7
 unlk     a6
 rts
