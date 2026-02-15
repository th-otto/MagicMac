* int isdevice(a0 = char dateiname[])
*  Stellt fest, ob ein Dateiname ein Device 'CON:', 'AUX:', 'PRN:' ist.

isdevice:
 movem.l  d7/a4,-(sp)
 subq.l   #4,sp
 tst.b    3(a0)
 beq.b    isdv_4                   ; String ist <= 3 Zeichen
 cmpi.b   #':',3(a0)               ; 4. Zeichen ':' ?
 bne      isdv_nix                 ; nein, kein GerÑt
 tst.b    4(a0)
 bne.b    isdv_nix                 ; zwar ':', aber danach noch was
isdv_4:
 move.l   sp,a1
 moveq    #2,d1                    ; 3 Zeichen kopieren
isdv_2:
 move.b   (a0)+,d0
 andi.b   #$5f,d0                  ; toupper
 move.b   d0,(a1)+
 dbra     d1,isdv_2
 lea      device_s(pc),a4          ; a4 = GerÑtenamen
 moveq    #3,d7                    ; 4 GerÑtenamen
isdv_1:
 move.l   sp,a0
 move.l   a4,a1
 moveq    #3,d0
 bsr      strncmp
 beq.b    isdv_5                   ; gefunden!
 addq.l   #3,a4
 dbra     d7,isdv_1
isdv_nix:
 moveq    #0,d0                    ; nicht gefunden
isdv_ende:
 addq.l   #4,sp
 movem.l  (sp)+,d7/a4
 rts
isdv_5:
 moveq    #1,d0
 bra.b    isdv_ende


* int fileren(alt_name,neu_name)
*  verschiebt eine Datei
*  RÅckgabewert 0, wenn alles in Ordnung
*
* Wird auch von REN benutzt!
*

ALT_NAME  SET  8
NEU_NAME  SET  $c

fileren:
 link     a6,#-4
 move.l   NEU_NAME(a6),(sp)
 move.l   ALT_NAME(a6),-(sp)
 clr.w    -(sp)
 gemdos   Frename
 addq.l   #8,sp
 move.l   d0,(sp)
 lea      rens(pc),a0              * "MV "
 bsr      get_country_str
 bsr      strcon
 move.l   ALT_NAME(a6),a0          * "altername"
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 move.l   (sp),d0
 bne.b    renf_1
 move.l   NEU_NAME(a6),a0          * "neuername"
 bsr      strcon
 bra.b    renf_end
renf_1:
 lea      err_rens(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.w   2(sp),d0                 * Low- Word des Fehlercodes
 bsr      print_err
renf_end:
 bsr      crlf_con
 move.l   (sp),d0
 unlk     a6
 rts


* int filecopy(quell_dateiname,ziel_dateiname)
*  kopiert eine Datei
*  RÅckgabewert 0, wenn alles in Ordnung
*

DTA_ZIEL       SET  -44
DTA_QUELL      SET  DTA_ZIEL-44
DATE_TIME      SET  DTA_QUELL-4

filecopy:
 link     a6,#DATE_TIME
 movem.l  d0/d3/d4/d6/d7/a3/a4/a5,-(sp)
 movem.l  8(a6),a3/a4         * 8(a6) -> a3 / $c(a6) -> a4
 bsr      memavail
 move.l   d0,d4               * Åberhaupt Speicher frei ?
 beq      fc_80
 cmp.l    #10240,d4           * mehr als 10k frei ?
 bcs.b    fc_30                 * nein => ganzen Speicher holen
 lsr.l    #1,d4               * sonst den halben Speicher holen
 andi.w   #$fffe,d4           * auf gerade Adressen zwingen
fc_30:
 move.l   d4,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq      fc_80
 move.l   d0,a5               * a5 ist Pufferadresse

 lea      DTA_ZIEL(a6),a1
 moveq    #0,d0
 move.l   a4,a0
 bsr      sfirst              * Datei- Informationen fÅr Ziel
 bne.b    fc_2

 lea      DTA_QUELL(a6),a1
 moveq    #0,d0
 move.l   a3,a0
 bsr      sfirst              * Datei- Informationen fÅr Quelle
 bne.b    fc_2

* Es wird nachgesehen, ob die beiden Dateien identisch sind. Dies ist der
* Fall, wenn DD (Bytes $11..$14) und Directory- Position (Bytes $d..$10)
* identisch sind

 lea      DTA_ZIEL+$d(a6),a0  * DTA- Puffer nur ab Byte 21 vergl.
 lea      DTA_QUELL+$d(a6),a1
 moveq    #8-1,d0             * vergl. DD/diroffs
fc_1:
 cmp.b    (a0)+,(a1)+
 dbne     d0,fc_1
 bne.b    fc_2
 lea      isidents(pc),a0
 bsr      get_country_str
 bra      fc_70

* AUSGABE DES KOMMENTARS "COPY quelle ziel"

fc_2:
 lea      copys(pc),a0             * "COPY "
 bsr      get_country_str
 bsr      strcon
 move.l   a3,a0
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 move.l   a4,a0
 bsr      strcon
 bsr      crlf_con
 gemdos   Cconis                   ; ^C abfragen
 addq.w   #2,sp

* ôFFNEN VON QUELL- UND ZIELDATEI

 clr.w    d0
 move.l   a3,a0
 bsr      open                * Quelldatei zum Lesen îffnen
 move.l   d0,d6               * LANGWORT testen !!! ('CON' ergibt 65535)
 bge.b    fc_4
 move.l   a3,(sp)             * Name der Fehlerhaften Datei
fc_3:
 bsr      print_err
 lea      auf_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.l   (sp),a0
 bra      fc_70
fc_4:
 tst.w    d6                  * GerÑt ?
 bge.b    fc_6
 move.l   #1024,d4            * Immer maximal nur 1024 Bytes lesen
fc_6:
 clr.w    d0                  * Zieldatei hat immer Attribut 0
 move.l   a4,a0
 bsr      create              * Zieldatei zum Schreiben îffnen
 move.l   d0,d7               * LANGWORT testen !!! ('CON' ergibt 65535)
 bge.b    fc_5
 move.w   d6,d0               * Fehler aufgetreten:
 bsr      close               * Quelldatei wieder schlieûen
 move.l   a4,(sp)             * Name der fehlerhaften Datei
 move.w   d7,d0
 bra.b    fc_3

* KOPIER- SCHLEIFE

fc_5:
 move.l   a5,a0               * pbuffer
 move.l   d4,d1               * count
 move.w   d6,d0               * handle
 bsr      read
 move.l   d0,d3               * Anzahl gelesener Bytes
 bge.b    fc_10
 move.l   a3,(sp)             * Fehler auf Quelldatei
fc_11:
 move.w   d6,d0
 bsr      close
 move.w   d7,d0
 bsr      close
 move.l   a4,-(sp)
 gemdos   Fdelete             * Zieldatei wieder lîschen
 addq.l   #6,sp
 move.l   d3,d0               * Fehlercode in d0
 blt.b    fc_3
 move.l   (sp),a0
 bra      fc_70
fc_10:
 tst.w    d6                  * Disk- Datei oder Device ?
 bge.b    fc_8

* SONDERBEHANDLUNG FöR GERéTE

 cmpi.w   #-3,d6              * NUL: oder PRN: ?
 ble.b    fc_7                  * Beenden
 cmpi.l   #1,d3
 bne.b    fc_9
 cmpi.b   #$1a,(a5)           * Zeile nur mit EOF gelesen
 beq.b    fc_7
fc_9:
 move.b   #CR,0(a5,d3.l)
 move.b   #LF,1(a5,d3.l)
 addq.l   #2,d3               * Zeichenfolge CR/LF ergÑnzen
 lea      -1(a5,d3.l),a0
 moveq    #1,d1
 move.w   d6,d0
 bsr      write               * LF echoen
fc_8:
 move.l   a5,a0               * pbuffer
 move.l   d3,d1               * count
 move.w   d7,d0               * handle
 bsr      write
 move.l   a4,(sp)
 tst.l    d0
 blt.b    fc_11                 * Fehler auf Zieldatei
 cmpi.w   #-4,d7              * Zieldatei NUL: ?
 beq.b    fc_31
 addq.l   #4,sp
 lea      zielvolls(pc),a0
 bsr      get_country_str
 pea      (a0)
 cmp.l    d3,d0
 bcs.b    fc_11                 * weniger geschrieben als vorhin gelesen
fc_31:
 tst.w    d6
 bmi      fc_5                  * Quelle = Device : Weitermachen
 cmp.l    d3,d4
 beq      fc_5                  * Noch nicht EOF:   Weitermachen

* Jetzt ist der Kopiervorgang korrekt beendet. Zeit/Datum der Zieldatei
* mÅssen von der Quelldatei Åbernommen werden, falls vorhanden.

fc_7:
 tst      d6
 bmi.b    fc_12
 tst      d7
 bmi.b    fc_12
 clr.w    (sp)                * Datum der Quelldatei holen
 move.w   d6,-(sp)
 pea      DATE_TIME(a6)
 gemdos   Fdatime
 addq.l   #8,sp

* ACHTUNG: Gemdos- Fehler erfordert Schlieûen und Wieder-ôffnen !!!
* Wenn t_flag = TRUE (TOUCH), wird die Uhrzeit nicht kopiert

 move     d+t_flag(pc),d0
 bne.b    fc_12

 IFF      KAOS
 move.w   d7,d0
 bsr      close               * Zieldatei schlieûen
 clr.w    d0
 move.l   a4,a0
 bsr      open                * Zieldatei wieder îffnen
 move.l   d0,d7
 bmi.b    fc_12
 ENDC

 move.w   #1,(sp)             * Datum der Zieldatei setzen
 move.w   d7,-(sp)
 pea      DATE_TIME(a6)
 gemdos   Fdatime
 addq.l   #8,sp
fc_12:
 move.w   d6,d0
 bsr      close
 move.w   d7,d0
 bsr      close
 clr.w    d0                  * kein Fehler
 bra.b    fc_90
fc_70:
 bsr      strcon              * Fehlermeldung ausgeben und Ende
fc_80:
 bsr      inc_errlv
 moveq    #1,d0
fc_90:
 bsr      free_tpa
 tst.l    (sp)+
 movem.l  (sp)+,d3/d4/d6/d7/a3/a4/a5
 unlk     a6
 rts


DTA        SET  -44            * char DTA[44]
ZIELPFAD   SET  DTA-150        * char ZIELPFAD[150]
STRING1    SET  ZIELPFAD-150   * char STRING1[150]
STRING2    SET  STRING1-150    * char STRING2[150]
ZIELDATEI  SET  STRING2-170    * char ZIELDATEI[170]
QUELLDATEI SET  ZIELDATEI-170  * char QUELLDATEI[170]

mv_com:
 moveq    #0,d0
 bra.b    copy_ren
copy_com:
 lea      d+t_flag(pc),a1
 clr      (a1)                * per Default Datum mitkopieren
 cmpi.w   #2,SP_ARGC(sp)      * keine Parameter
 blt.b    cp_1
 move.l   SP_ARGV(sp),a0
 move.l   4(a0),a0            * erster Parameter
 cmpi.b   #'-',(a0)+          * Switch ?
 bne.b    cp_1
 move.b   (a0)+,d0
 bsr      d0_upper
 cmpi.b   #'T',d0
 bne.b    cp_1
 tst.b    (a0)                * "-T" durch EOS abgeschlossen ?
 bne.b    cp_1
 st       (a1)                * t_flag setzen
 addq.l   #4,SP_ARGV(sp)
 subq.w   #1,SP_ARGC(sp)      * ersten Parameter Åberspringen
cp_1:
 moveq    #1,d0
copy_ren:
 link     a6,#QUELLDATEI
 movem.l  d3/d4/d5/d6/d7/a5/a4/a3,-(sp)
 lea      ZIELDATEI(a6),a5
 move     d0,d7               * Flag = 1 (COPY), 0 (REN)
 move.l   ARGV(a6),a0
 move.l   4(a0),a3            * erster  Parameter (Quelle)
 move.l   8(a0),a4            * zweiter Parameter (Ziel)
 move.l   a3,a0
 bsr      isdevice            * Quelle = 'CON:', 'AUX:' oder 'PRN:' ?
 move.w   d0,d3
 bsr      crlf_con
 clr.w    d6
 lea      syntaxcopys(pc),a0
 tst      d7
 bne.b    cr_30
 lea      syntaxrens(pc),a0
cr_30:
 cmpi.w   #2,ARGC(a6)
 blt.b    cr_4                  * keine Parameter => error
 bne.b    cr_3                  * 2 oder mehr => cr_3
 movea.l  a3,a1               * nur ein Parameter
cr_2:
 tst.b    (a1)+
 bne.b    cr_2
 move.l   a1,a4               * zweiten Parameter setzen
 gemdos   Dgetdrv
 addq.l   #2,sp
* move.w   d0,d0
 move.l   a4,a0
 bsr      drive_to_defpath    * als zweiter Parameter aktueller Pfad
cr_3:
 lea      ZIELPFAD(a6),a1
 move.l   a4,a0               * prÅfe, ob Ziel ein Pfadname ist
 bsr      checkpath
 move.w   d0,d4

 IFF      KAOS
 move.l   a3,a0
 bsr      str_to_drive        * Diskwechsel erkennen
 ENDC

 lea      STRING1(a6),a2
 lea      STRING2(a6),a1
 move.l   a3,a0
 bsr      split_path          * fÅr Quelle
 tst.w    d3
 beq.b    cr_20

 move.b   #':',STRING2+3(a6)
 clr.b    STRING2+4(a6)
 move.b   #':',STRING1+3(a6)
 clr.b    STRING1+4(a6)

* IFF      KAOS
* clr.b    STRING2+4(a6)       * im Falle 'CON:' usw. ausgleichen
* clr.b    STRING1+4(a6)
* ENDC
* IF       KAOS
* clr.b    STRING2+3(a6)       * im Falle 'CON' usw. ausgleichen
* clr.b    STRING1+3(a6)
* ENDC

 clr.b    DTA+30(a6)
cr_20:
 tst.w    d0
 bne.b    cr_5
 move.l   a3,a0               * <Quelle> nicht gefunden
 bsr      strcon
 lea      not_founds(pc),a0
cr_4:
 bsr      get_country_str
 bsr      strcon              * Fehlermeldung ausgeben und Ende
 bsr      inc_errlv
 bra      cr_end
cr_5:
 lea      STRING2(a6),a0
 bsr      enth_jok
 move.w   d0,d5
 move.l   a4,a0               * zweiten Parameter (Ziel) prÅfen
 bsr      enth_jok
 lea      unerlcopy_s(pc),a0
 tst.w    d7
 bne.b    cr_31
 lea      unerlren_s(pc),a0
cr_31:
 tst.w    d0
 bne.b    cr_4                  * Ziel enthÑlt Joker '*' oder '?'

 IFF      KAOS
 move.l   a4,a0               * Ziel ist GerÑt ?
 bsr      isdevice
 tst.w    d0
 beq.b    cr_32
 tst.w    d7
 beq.b    cr_4                  * bei REN GerÑt als Ziel ungÅltig
 ENDC

cr_32:
 tst.w    d5
 beq.b    cr_6
 tst.w    d4
 beq.b    cr_4
cr_6:
 tst.w    d3
 bne.b    cr_7                            * Quelle ist Standard- Device

 lea      DTA(a6),a1
 moveq    #6,d0                         * Dateityp = alle auûer Subdir
 lea      STRING2(a6),a0
 bsr      sfirst
 beq.b    cr_7

 lea      keine_dateiens(pc),a0       * "Keine Dateien"
 bsr      get_country_str
 addq.l   #3,a0
 bsr      strcon
 lea      crlfs(pc),a0
 bra.b    cr_4
cr_7:
 lea      STRING1(a6),a1                * Pfad der Quelldatei
 lea      QUELLDATEI(a6),a0
 bsr      strcpy
 lea      DTA+30(a6),a1
 lea      QUELLDATEI(a6),a0
 bsr      strcat
 lea      QUELLDATEI(a6),a0
 bsr      str_upper
 tst.w    d5
 bne.b    cr_8
 tst.w    d4
 beq.b    cr_9
cr_8:
 lea      ZIELPFAD(a6),a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcpy
 lea      DTA+30(a6),a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcat
 bra.b    cr_10
cr_9:
 move.l   a4,a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcpy
cr_10:
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      str_upper
 move.l   a5,-(sp)            * ZIELDATEI(a6)
 pea      QUELLDATEI(a6)
 lea      filecopy(pc),a0
 tst.w    d7
 bne.b    cr_22
 lea      fileren(pc),a0
cr_22:
 jsr      (a0)
 addq.l   #8,sp
 tst.w    d0
 bne.b    cr_11
 addq.w   #1,d6
 tst.w    d3
 bne.b    cr_11                    * Quelle war Standard- Device

 lea      DTA(a6),a0
 bsr      snext
 beq      cr_7

cr_11:
 tst.w    d7
 beq.b    cr_end
 lea      STRING1(a6),a4
 bsr      crlf_con
 move.l   a4,a0
 ext.l    d6
 move.l   d6,d0
 bsr      long_to_str		; gibt d0 und a0 zurÅck
 bsr      strcon			; nimmt a0
 lea      ndateiens(pc),a0
 bsr      get_country_str
 bsr      strcon
cr_end:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts
