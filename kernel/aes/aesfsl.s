*
* Alte Dateiauswahl
*

     INCLUDE "aesinc.s"
     TEXT

     XREF      get_clip_grect
     XREF      set_clip_grect
     XREF      rsrc_obfix

     XREF      update_1
     XREF      update_0

     XREF      ob_modes
     XREF      _objc_offset
     XREF      _objc_draw
     XREF      _objc_change

     XREF      _form_xdo
     XREF      _form_button
     XREF      __fm_xdial
     XREF      _form_center
     XREF      form_alert
     XREF      form_error

     XREF      graf_mouse
     XREF      graf_slidebox

     XREF      chg_3d
     XREF      Memavail,mmalloc,mfree,dgetdrv,fsetdta,extract_name
     XREF      vstrcpy,vstrcmp
     XREF      vmemcpy
     XREF      toupper
     XREF      _sprintf

     XDEF      fsel_exinput

; COUNTRY TODO
al_fserr:      DC.B '[1][Zuwenig Speicher f',$81,'r|Dateiauswahl!][ABBRUCH]',0
     EVEN

**********************************************************************
**********************************************************************
*
* Der Fileselector
*
* Objektnummern:
*
*              0         ; umgebende BOX
FS_TITLE  SET  1         ; Titelzeile, TEDINFO
*              2         ; "PFAD:"
FS_PATH   SET  3         ; Pfad, TEDINFO
FS_FILE   SET  4         ; Auswahl, TEDINFO
*              5         ; "Laufwerk:"
FS_CLOSE  SET  6         ; Closebox, BOXCHAR
FS_PATT   SET  7         ; Pfadmuster in Fenstertitel, TEDINFO
*              8         ; Laufwerkbuttons, BOX
FS_DRV1   SET  9         ; 9..24 Laufwerke, BOXCHARs
FS_DRV16  SET  24
FS_WFILS  SET  25        ; Fensterinhalt, BOX
FS_FILE1  SET  26        ; 26..34 Dateinamen im Fenster
*                        ;        TEDINFO, tmplt = "_ ________.___"
FS_DOWN   SET  35        ; Pfeil nach unten, BOXCHAR
FS_SCRL   SET  36        ; Scrollfeld
FS_SLID   SET  37        ; Scrollbalken
FS_UP     SET  38        ; Pfeil nach oben, BOXCHAR
FS_OK     SET  39        ; "OK"
FS_CANC   SET  40        ; "Abbruch"
*


**********************************************************************
*
* int fsel_exinput(char *path, char *name, int *button, char *title)
*
*    8(a6):    char *path
*   $c(a6):    char *name
*  $10(a6):    int  *button
*  $14(a6):    char *title
*
* -$28(a6):    DISKINFO
* -$18(a6):    void  *   (FLYINF *)
* -$14(a6):    DTA   *
* -$10(a6):    GRECT clip
*   -8(a6):    GRECT centr
*
* Speicherblock (a4):
*
* -120(a4):    maximale Anzahl Dateien
* -118(a4):    Dateiname
* -100(a4):    Muster
*

fsel_exinput:
 link     a6,#-$28
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5,-(sp)

 jsr      update_1

 movea.l  $10(a6),a0
 clr.w    (a0)                     ; per Default Rueckgabe 0

 move.l   #fsel_tree_end-fsel_tree,d6   ; benoetigter Speicher fuer Box

 jsr      Memavail
 move.l   #1024*16+120,d1          ; 1024 Dateien + Strings
 add.l    d6,d1                    ; + Dialogbox selbst
 cmp.l    d1,d0
 bcs.b    fsx_1024
 move.l   d1,d0                    ; maximal 16k holen!
fsx_1024:
 move.l   d0,d1                    ; Restspeichergroesse nach d1
 subi.l   #120,d1                  ; - 100 fuer Pfade usw.
 sub.l    d6,d1                    ; - Speicher fuer Box selbst
 asr.l    #4,d1                    ; / 16 = Anzahl ladbarer Dateien
                                   ; ist "int" wegen <= 1024
 cmpi.w   #9,d1
 bge.b    fsx_neg                  ; d1 kann hier negativ sein !
* weniger fuer 9 Dateien: Fehler
fsx_memerr:
 lea      al_fserr(pc),a0          ; "Zuwenig Speicher fuer den Dialog"
 moveq    #1,d0
 bsr      form_alert
 clr.w    d0
 bra      fsx_ende
* mehr oder genau 9 * 16 Bytes frei
fsx_neg:
 move.w   d1,d7                    ; fsel_maxfiles merken
;move.l   d0,d0
 jsr      mmalloc                   ; Speicher holen
 beq      fsx_memerr
 move.l   d0,a4                    ; Adresse nach a4
 add.l    d6,a4                    ; Platz fuer Objektbaum und TEDINFOs
 move.w   d7,(a4)                  ; fsel_maxfiles merken
 lea      120(a4),a4               ; a4 auf Datenbereich

 move.l   d0,a5                    ; Baumadresse

* Baum fuer Dialogbox erzeugen

 move.w   d6,d0
 lea      fsel_tree(pc),a1
 move.l   a5,a0
 jsr      vmemcpy

* 3D/2D
 move.w   #1,fs_tedinfo3-fsel_tree+te_thickness(a5)
 move.w   #$11a1,fs_tedinfo3-fsel_tree+te_color(a5)
 move.w   enable_3d,d0
 beq.b    fsx_2d
 clr.b    fs_tedinfo3-fsel_tree+te_color+1(a5)
 addq.w   #1,fs_tedinfo3-fsel_tree+te_thickness(a5)

fsx_2d:
 move.l   a5,a1
 lea      fsel3dtab(pc),a0
 jsr      chg_3d

 lea      -24(a5),a3
fsx_fix_loop:
 lea      24(a3),a3
 moveq    #0,d0                    ; ist Objekt selbst
 move.l   a3,a0
 jsr      rsrc_obfix
 move.w   ob_type(a3),d0
 lea      ob_modes(pc),a0
 cmpi.b   #-1,-20(a0,d0.w)         ; TEDINFO ?
 bne.b    fsx_nxtfix               ; nein
 move.l   a5,d0
 add.l    d0,ob_spec(a3)           ; ja, relozieren
fsx_nxtfix:
 btst     #5,ob_flags+1(a3)        ; LASTOB ?
 beq.b    fsx_fix_loop

* Dialogbox zentrieren
 lea      -8(a6),a1
 move.l   a5,a0
 jsr      _form_center

 lea      -$18(a6),a2              ; FlyDials
 lea      -8(a6),a1                ; Zeiger auf biggrect
;suba.l   a0,a0                    ; Zeiger auf littlegrect
 moveq    #0,d0                    ; FMD_START
 bsr      __fm_xdial

 move.l   FS_PATH*24+ob_spec(a5),a0     ; TEDINFO des Pfades
 move.l   8(a6),te_ptext(a0)            ; direkt setzen

 move.l   $14(a6),d0
 beq.b    fsx_default_title             ; kein Titel
 move.l   FS_TITLE*24+ob_spec(a5),a0    ; TEDINFO des Titels
 move.l   d0,te_ptext(a0)               ; direkt setzen

fsx_default_title:
 move.l   FS_PATT*24+ob_spec(a5),a0     ; TEDINFO des Musters ("Fenstertitel")
 lea      -100(a4),a1
 move.l   a1,te_ptext(a0)               ; direkt setzen

 move.l   FS_FILE*24+ob_spec(a5),a0     ; TEDINFO der Auswahl
 lea      -118(a4),a1
 move.l   a1,te_ptext(a0)               ; direkt setzen
;move.l   a1,a1
 move.l   $c(a6),a0                     ; char *name
 bsr      fname_to_ptext                ; ins interne Format uebertragen

* Laufwerkbuttons initialisieren

 move.w   _drvbits+2,d0                 ; Bit 15 = Drive A:
 lea      FS_DRV16*24+ob_state(a5),a0   ; Laufwerk P:
 moveq    #15,d1
fsx_initbut:
 btst     d1,d0                         ; Laufwerk existiert ?
 seq      d2                            ; wenn nicht, d2 = $ff
 andi.w   #8,d2                         ; wenn nicht, d2 = DISABLED
 move.w   d2,(a0)
 lea      -24(a0),a0
 dbra     d1,fsx_initbut

* zu rettende Daten und Einstellungen retten

 move.w   #$2f,-(sp)
 trap     #1                       ; Fgetdta
 addq.w   #2,sp
 move.l   d0,-$14(a6)              ; -$14(a6): aktueller DTA- Puffer

 lea      -$10(a6),a0
 jsr      get_clip_grect           ; -$10(a6): aktuelles Clipping

* Box ausgeben

 lea      -100(a4),a1
 move.l   8(a6),a0
 bsr      complete_path            ; Pfad in Muster und Pfad aufsplitten

 move.l   8(a6),a1
 lea      -100(a4),a0
 bsr      strcat_to                ; und fuer die Ausgabe wieder ketten
 clr.b    -100(a4)                 ; zunaechst kein Muster ausgeben

 lea      -8(a6),a0
 jsr      set_clip_grect           ; Clipping auf Box

;clr.w    FS_SLID*24+ob_y(a5)                ; Scrollbalken nach oben
;move.w   FS_SCRL*24+ob_height(a5),FS_SLID*24+ob_height(a5)
                                             ; Scrollbalkenhoehe maximal

;ori.b    #$80,FS_WFILS*24+ob_flags+1(a5)    ; Fensterinhalt HIDDEN
;ori.b    #$80,FS_PATH*24+ob_flags+1(a5)     ; Pfad HIDDEN

 moveq    #8,d1
 moveq    #0,d0
 move.l   a5,a0                              ; tree
 jsr      _objc_draw                          ; Fileselector ausgeben

 andi.b   #$7f,FS_WFILS*24+ob_flags+1(a5)    ; Fensterinhalt ~HIDDEN
 andi.b   #$7f,FS_PATH*24+ob_flags+1(a5)     ; Pfad ~HIDDEN

 moveq    #0,d1                              ; nur Objekt selbst
 moveq    #FS_WFILS,d0                       ; Fensterinhalt
 move.l   a5,a0                              ; tree
 jsr      _objc_draw                          ; Fensterrahmen ausgeben

 moveq    #-1,d4                   ; noch kein Dateifeld selektiert
 moveq    #FS_PATH,d3
 bra      fsx_c_path

*
*  die grosse Schleife
*

fsel_mainloop:

* switch(d0)

 cmp.w    #38,d0
 bhi      fsx_endsw
 move.w   d0,d1
 add.w    d1,d1
 move.w   fsel_jmptab(pc,d1.w),d1
 jmp      fsel_jmptab(pc,d1.w)

fsel_jmptab:
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_c_path-fsel_jmptab     ; Objekt 3 (Pfad)
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_c_close-fsel_jmptab    ; Objekt 6 (Schliessfeld)
 DC.W     fsx_c_path-fsel_jmptab
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab      ; Objekt 9 (Laufwerk A:)
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab
 DC.W     fsx_c_drv-fsel_jmptab      ; Objekt 24 (Laufwerk P:)
 DC.W     fsx_endsw-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab     ; Objekt 26 (Dateiname #1)
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab
 DC.W     fsx_c_file-fsel_jmptab     ; Objekt 34 (Dateiname #9)
 DC.W     fsx_c_scrolldown-fsel_jmptab    ; Objekt 35
 DC.W     fsx_c_scroll-fsel_jmptab        ; Objekt 36 (graues Scrollfeld)
 DC.W     fsx_c_slider-fsel_jmptab        ; Objekt 37 (Schieber)
 DC.W     fsx_c_scrollup-fsel_jmptab      ; Objekt 38

* case 38:

fsx_c_scroll:
 moveq    #FS_SLID,d0              ; Schieber
 move.l   a5,a0
 jsr      _objc_offset

 moveq    #-9,d0                   ; um 9 Positionen scrollen
 cmp.w    gr_mkmy,d1
 bge      fsx_scroll
 moveq    #9,d0
 bra      fsx_scroll

* case 39:

fsx_c_slider:
;moveq    #1,d0
;jsr      wind_mctrl

 moveq    #1,d2                    ; vertikal
 moveq    #FS_SLID,d1
 moveq    #FS_SCRL,d0
 move.l   a5,a0
 jsr      graf_slidebox

 move.w   d0,-(sp)                 ; Position merken

;moveq    #0,d0
;jsr      wind_mctrl

 move.w   d7,d0
 subi.w   #9,d0
 mulu     (sp)+,d0
 divs     #1000,d0

 sub.w    d6,d0
 bra.b    fsx_scroll

* case 37:

fsx_c_scrolldown:
 moveq    #1,d0                    ; um einen Eintrag scrollen
fsx_scroll:
 add.w    d6,d0                    ; Scrollposition + Scrollwert
 cmp.w    d5,d0                    ; maximale Scrollposition erreicht ?
 ble.b    fscx_l1                  ; nein, ok
 move.w   d5,d0
fscx_l1:
 tst.w    d0
 bge.b    fsx_sok2
 moveq    #0,d0
fsx_sok2:
 cmp.w    d0,d6
 beq      fsx_endsw                ; keine Aenderung
 move.w   d0,d6                    ; neuen Wert setzen

 move.w   d7,d1
 move.w   d6,d0
 move.l   a4,a1
 move.l   a5,a0
 bsr      fs_show_9_files
 bra      fsx_endsw

* case 39:

fsx_c_scrollup:
 moveq    #-1,d0
 bra.b    fsx_scroll

* case 6:

fsx_c_close:
 lea      -100(a4),a1
 move.l   8(a6),a0
 bsr      complete_path

 btst     #15,d3                   ; Doppelklick ?
 beq.b    fsx_no_toroot            ; nein
 move.l   8(a6),a0
 addq.l   #3,a0
 tst.b    (a0)
 beq      fsx_endsw                ; ist schon Root
 clr.b    (a0)                     ; zurueck zur Root
 bra.b    fsx_readall              ; und neu ausgeben

fsx_no_toroot:
 subq.l   #1,a0                    ; a0 auf abschliessenden '\\'

 move.l   8(a6),a1
 addq.l   #2,a1                    ; "X:" ueberlesen
fsx_cloop:
 cmpa.l   a1,a0
 bcs      fsx_ecloop
 cmpi.b   #92,-(a0)
 bne.b    fsx_cloop
 clr.b    1(a0)
fsx_ecloop:
 bra.b    fsx_readall

* case 3

fsx_c_path:
 lea      -100(a4),a1
 move.l   8(a6),a0
 bsr      complete_path

 btst     #15,d3
 beq.b    fsx_readall
 move.l   #$2a2e2a00,-100(a4)      ; "*.*",0

fsx_readall:
 move.l   a4,a2
 move.l   8(a6),a1
 move.l   a5,a0
 bsr      fsel_readfiles
 clr.w    d6                       ; Scrollpos 0
 clr.w    d5                       ; maxscroll zunaechst auf 0
 move.w   d0,d7                    ; Anzahl gelesener Dateien

 subi.w   #9,d0
 ble      fsx_endsw
 move.w   d0,d5
 bra      fsx_endsw

* case 9:
*  .
*  .
* case 24: (16 Laufwerkbuttons)

fsx_c_drv:
 move.w   d0,d1
 mulu     #24,d1
 btst     #3,ob_state+1(a5,d1.w)   ; DISABLED
 bne      fsx_endsw                ; ja, nichts tun
 subi.w   #FS_DRV1,d0              ; in Laufwerknummer umrechnen
 btst     #15,d3                   ; Doppelklick ?
 beq.b    fsx_noinfo

 move.w   d0,d3                    ; Laufwerk merken

 moveq    #-1,d2                   ; winhdl
 moveq    #1,d1                    ; ein Klick
 move.l   8(a6),a0                 ; path
 move.b   (a0),d0
 ext.w    d0                       ; Laufwerkbuchstabe
 addi.w   #FS_DRV1-'A',d0          ; in Objektnummer umrechnen
 move.l   a5,a0                    ; OBJECT *tree
 bsr      _form_button             ; altes Laufwerk wieder aktivieren

 lea      -$28(a6),a0              ; DISKINFO *
 move.w   d3,-(sp)
 addq.w   #1,(sp)
 move.l   a0,-(sp)
 move.w   #$36,-(sp)
 trap     #1                       ; gemdos Dfree
 addq.l   #8,sp
 tst.l    d0
 bne      fsx_endsw                ; Fehler

 lea      -$28(a6),a0
 move.w   $e(a0),d1                ; Sektoren/Cluster
 mulu     $a(a0),d1                ;  * Bytes/Sektor
 move.w   d1,d0
 mulu     2(a0),d0                 ;  * freie Cluster (unsigned int ?)
 mulu     6(a0),d1                 ;  * Gesamt- Cluster

 addi.b   #'A',d3
 lea      12(a0),a1

 move.l   a1,(a0)                  ; String mit Laufwerk
 move.l   d1,4(a0)
 move.l   d0,8(a0)
 move.b   d3,(a1)+
 clr.b    (a1)

 pea      (a0)                     ; (a0):Bytes 4(a0):String
 pea      diskinfo(pc)             ; Schablone
 pea      -100(a4)                 ; Ziel
 jsr      _sprintf
 lea      12(sp),sp

 lea      -100(a4),a0
 moveq    #1,d0
 bsr      form_alert
 bra      fsx_endsw

fsx_noinfo:
 move.l   8(a6),a0
 addi.b   #'A',d0
 cmp.b    (a0),d0
 beq      fsx_endsw                ; selbes Laufwerk
 move.b   d0,(a0)                  ; Laufwerkbuchstabe aendern

 lea      -100(a4),a1              ; Muster hierhin retten
;move.l   a0,a0
 bsr      complete_path

 movea.l  8(a6),a0                 ; Standardpfad angeben:
 addq.l   #2,a0                    ;  "X:" ueberspringen
 lea      -100(a4),a1
fsx_drvcloop:
 move.b   (a1)+,(a0)+              ; Muster dahinterkopieren
 bne.b    fsx_drvcloop
 bra      fsx_c_path               ; wie, wenn Pfad geaendert

* case 26:
*  .
*  .
* case 34: (10 Dateifelder)

fsx_c_file:
 move.w   d0,d1
 subi.w   #FS_FILE1,d1             ; in 0..8 umrechnen
 add.w    d6,d1                    ; + scrollpos
 lsl.w    #4,d1
 lea      0(a4,d1.w),a3            ; Eintrag in der Tabelle

 cmpi.b   #7,(a3)                  ; Subdir ?
 bne.b    fsx_file                 ; nein

 lea      -100(a4),a1
 move.l   8(a6),a0
 bsr      complete_path

 move.l   a0,a1
 lea      1(a3),a0                 ; '\7' ueberspringen
 bsr      ptext_to_fname           ; Verzeichnis anhaengen

 move.l   8(a6),a0
fsx_cdloop:
 tst.b    (a0)+
 bne.b    fsx_cdloop
 subq.l   #1,a0
 move.b   #92,(a0)+
 clr.b    (a0)                     ; "\\" anhaengen

 bra      fsx_readall

fsx_file:
 cmpi.b   #' ',(a3)+               ; Datei ?
 bne.b    fsx_endsw                ; nein, unbekannt
 tst.b    (a3)                     ; Dateiname ?
 beq.b    fsx_endsw                ; ungueltig!

 move.w   d0,-(sp)
 moveq    #1,d2
 moveq    #0,d1
 move.w   d4,d0
 bmi.b    fsx_nodesel
 move.l   a5,a0
 jsr      _objc_change              ; bisheriges Objekt deselektieren

fsx_nodesel:
 move.w   (sp)+,d4                 ; neues Objekt

 move.l   a3,a1
 lea      -118(a4),a0
fsx_cploop:
 move.b   (a1)+,(a0)+              ; String in die Auswahl kopieren
 bne.b    fsx_cploop

 moveq    #0,d1                    ; depth
 moveq    #FS_FILE,d0              ; startob
 move.l   a5,a0                    ; tree
 jsr      _objc_draw

 moveq    #1,d2
 moveq    #1,d1
 move.w   d4,d0
 move.l   a5,a0
 jsr      _objc_change              ; angeklickte Zeile selektieren

 move.w   d3,d0
 and.w    #$8000,d0
 beq.b    fsx_endsw                ; war kein Doppelklick

 moveq    #1,d2
 moveq    #1,d1
 moveq    #FS_OK,d0
 move.l   a5,a0
 jsr      _objc_change

 moveq    #FS_OK,d3                ; "OK"- Button
 bra      fsel_exit

*
*
*

fsx_endsw:
 move.l   -$18(a6),a2              ; FlyDials
 lea      fskeys(pc),a1
 move.l   a5,a0
 moveq    #FS_FILE,d0
 bsr      _form_xdo

 move.w   d0,d3
 and.w    #$7fff,d0
 subq.w   #FS_PATH,d1              ; war der Cursor in der oberen Zeile ?
 bne.b    fsx_no_curpath           ; nein
 cmpi.w   #FS_OK,d0                ; ist OK angewaehlt worden ?
 bne.b    fsx_no_curpath
* OK angewaehlt nach Pfadaenderung
 moveq    #1,d2                    ; der OK- Button wird deselektiert
 moveq    #0,d1
 moveq    #FS_OK,d0
 move.l   a5,a0
 jsr      _objc_change
 bra      fsx_c_path               ; ja, stattdessen Pfad neu anzeigen

fsx_no_curpath:
 cmpi.w   #FS_OK,d0                ; OK
 beq.b    fsel_exit
fscx_l2:
 cmpi.w   #FS_CANC,d0              ; Abbruch
 bne      fsel_mainloop


fsel_exit:
 move.l   $c(a6),a1
 lea      -118(a4),a0
 bsr      ptext_to_fname

 move.l   $10(a6),a0
 cmpi.w   #FS_OK,d3                ; OK ?
 seq      d0
 andi.w   #1,d0
 move.w   d0,(a0)                  ; Rueckgabe 1 oder 0

 lea      -$18(a6),a2              ; FlyDials
 lea      -8(a6),a1
;suba.l   a0,a0
 moveq    #3,d0
 bsr      __fm_xdial
 move.l   -$14(a6),a0
 jsr      fsetdta

 lea      -$10(a6),a0
 jsr      set_clip_grect

 move.l   a5,a0
 jsr      mfree

 moveq    #1,d0
fsx_ende:
 move.l   d0,-(sp)
 jsr      update_0
 move.l   (sp)+,d0
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts


**********************************************************************
*
* void strcat_to(a0 = char *src, a1 = char *dst)
*

strcat_to:
 tst.b    (a1)+
 bne.b    strcat_to
 subq.l   #1,a1
strc_loop:
 move.b   (a0)+,(a1)+
 bne.b    strc_loop
 rts


**********************************************************************
*
* a0 = char *complete_path(a0 = char *path, a1 = char *patt)
*
* komplettiert den Pfad und trennt das Muster bzw. den Dateinamen ab.
*

complete_path:
 movem.l  a3/a4/a5,-(sp)
 suba.w   #128,sp
 movea.l  a0,a5
 movea.l  a1,a4

 jsr      extract_name
 move.l   a0,a2
 move.l   a4,a1
cmp_cpyloop:
 move.b   (a2)+,d0
 jsr      toupper
 move.b   d0,(a1)+
 bne.b    cmp_cpyloop              ; Dateiname (Muster) nach <patt> kopieren
 clr.b    (a0)                     ; Ende des reinen Pfades

 tst.b    (a4)                     ; Dateiname existiert ?
 bne.b    cmp_pattern              ; ja, ok
 move.b   #'*',(a4)+
 move.b   #'.',(a4)+
 move.b   #'*',(a4)+
 clr.b    (a4)                     ; nein, "*.*" setzen

cmp_pattern:
 move.l   sp,a0
 move.l   a5,a1
cmp_loop1:
 move.b   (a1)+,d0
 jsr      toupper
 move.b   d0,(a0)+
 bne.b    cmp_loop1

 lea      (sp),a3
 tst.b    (a3)
 beq.b    cmp_drv
 cmpi.b   #':',1(a3)
 beq.b    cmp_nodrv
cmp_drv:
 jsr      dgetdrv                  ; ggf. aktuelles Laufwerk einsetzen
 bra.b    cmp_setdrv
cmp_nodrv:
 moveq    #0,d0
 move.b   (a3),d0
 jsr      toupper
 subi.w   #'A',d0
 addq.l   #2,a3
cmp_setdrv:
 move.b   d0,(a5)
 addi.b   #'A',(a5)+
 move.b   #':',(a5)+

 cmpi.b   #92,(a3)
 beq.b    cmp_root
 clr.b    (a5)                     ; ggf. aktuellen Pfad einfuegen
 addq.w   #1,d0
 move.w   d0,-(sp)
 move.l   a5,-(sp)
 move.w   #$47,-(sp)
 trap     #1                       ; gemdos Dgetpath
 addq.l   #8,sp
cmp_loop2:
 tst.b    (a5)+
 bne.b    cmp_loop2
 subq.l   #1,a5
 cmpi.b   #92,-1(a5)
 beq.b    cmp_root
 move.b   #92,(a5)+
cmp_root:
 move.b   (a3)+,(a5)+
 bne.b    cmp_root
 subq.l   #1,a5
 cmpi.b   #92,-1(a5)
 beq.b    cmp_slash
 move.b   #92,(a5)+
 clr.b    (a5)
cmp_slash:
 move.l   a5,a0                    ; Ende des Pfades
 adda.w   #128,sp
 movem.l  (sp)+,a3/a4/a5
 rts



**********************************************************************
*
* void ptext_to_fname(a0 = char *name, a1 = char *int_name)
*

ptext_to_fname:
 moveq    #7,d0
pttn_l1:
 move.b   (a0)+,d1
 beq.b    pttn_l4
 cmpi.b   #' ',d1
 beq.b    pttn_l2
 move.b   d1,(a1)+
pttn_l2:
 dbf      d0,pttn_l1
 tst.b    (a0)
 beq.b    pttn_l4
 move.b   #'.',(a1)+
pttn_l3:
 tst.b    (a0)
 beq.b    pttn_l4
 move.b   (a0)+,(a1)+
 bra.b    pttn_l3
pttn_l4:
 clr.b    (a1)
 rts


**********************************************************************
*
* void fname_to_ptext(a0 = char *name, a1 = char *int_name)
*

fname_to_ptext:
 moveq    #7,d0
fnpt_l1:
 tst.b    (a0)
 beq.b    fnpt_l2
 cmpi.b   #'.',(a0)
 beq.b    fnpt_l2
 move.b   (a0)+,(a1)+
 dbf      d0,fnpt_l1
 bra.b    fnpt_l3
fnpt_l2:
 tst.b    (a0)
 beq.b    nti_eos
fnpt_loop:
 move.b   #' ',(a1)+
 dbf      d0,fnpt_loop
fnpt_l3:
 tst.b    (a0)+
 beq.b    nti_eos
fnpt_lopp2:
 tst.b    (a0)
 beq.b    nti_eos
 move.b   (a0)+,(a1)+
 bra.b    fnpt_lopp2
nti_eos:
 clr.b    (a1)
 rts


**********************************************************************
*
* long fsel_readfiles(a0 = OBJECT *tree, a1 = char *path,
*                     a2 = void *mem )
*
* Rueckgabe: Anzahl gelesener Eintraege (0 bei Fehler)
* zeigt ab Mag!X 1.12 Fehler-Alerts an
*

fsel_readfiles:
 movem.l  d6/d7/a3/a4/a5/a6,-(sp)
 suba.w   #$2c,sp                  ; DTA

 move.l   a0,a5                    ; OBJECT *
 movea.l  a1,a6                    ; a6 = path
 movea.l  a2,a4                    ; mem

 moveq    #2,d0
 jsr      graf_mouse               ; Maus als Biene

* 9 Strings a 16 Bytes auf " " setzen

 moveq    #9-1,d1
 move.l   a4,a0
fsr_setspace:
 move.w   #$2000,(a0)              ; " "
 lea      16(a0),a0
 dbra     d1,fsr_setspace

fsr_again:
 move.l   a6,a1
fsr_eloop:
 tst.b    (a1)+
 bne.b    fsr_eloop
 subq.l   #1,a1
 move.l   a1,a3                    ; Ende des Pfads merken

 move.b   #'*',(a1)+
 move.b   #'.',(a1)+
 move.b   #'*',(a1)+
 clr.b    (a1)                     ; und "*.*" anhaengen

 lea      (sp),a0
 jsr      fsetdta                  ; DTA setzen

 moveq    #0,d7                    ; noch keine Datei

 move.w   #$10,-(sp)               ; normale Dateien und Subdirs (KAOS!!)
 move.l   a6,-(sp)
 move.w   #$4e,-(sp)
 trap     #1                       ; gemdos Fsfirst
 addq.l   #8,sp
; der folgende Code ist fuer Mag!X 1.12 geaendert
 cmp.w    #$ffde,d0                ; EPTHNF ?
 bne      fsr_nxtfile              ; nein, normale Fehlerbehandlung
* Sonderbehandlung fuer: Fsfirst->EPTHNF
 tst.b    3(a6)                    ; schon Root ?
 beq      fsr_nxtfile              ; ja, nix zu machen
 clr.b    3(a6)                    ; zur Root
 bra.b    fsr_again                ; und nochmal

fsr_readloop:
 lea      $1e(sp),a1               ; Name
 btst     #4,$15(sp)               ; Subdir ?
 beq.b    fsr_l1                   ; nein
* Subdir
 cmpi.b   #'.',(a1)+               ; beginnt mit '.' ?
 bne.b    fsr_sub                  ; nein, ok
 tst.b    (a1)                     ; "." ?
 beq.b    fsr_skip
 cmpi.b   #'.',(a1)                ; ".." ?
 beq.b    fsr_skip
fsr_sub:
 move.w   d7,d0
 lsl.w    #4,d0
 move.b   #7,0(a4,d0.w)            ; Zeichen fuer Subdir
 bra.b    fsr_l2
* kein Subdir
fsr_l1:
;move.l   a1,a1                    ; Dateiname aus der DTA
 lea      -100(a4),a0              ; Muster, etwa "*.PRG"
 bsr      fname_match              ; Dateien werden gematcht

 beq.b    fsr_skip                 ; passt nicht zum Muster
 move.w   d7,d0
 lsl.w    #4,d0
 move.b   #' ',0(a4,d0.w)          ; Dateien beginnen mit ' '
* endif
fsr_l2:
 move.w   d7,d0
 lsl.w    #4,d0
 lea      1(a4,d0.w),a1
 lea      $1e(sp),a0
 bsr      fname_to_ptext           ; Datei/Subdirname kopieren

 addq.w   #1,d7
fsr_skip:
 move.w   #$4f,-(sp)
 trap     #1                       ; gemdos Fsnext
 addq.l   #2,sp

* Naechste Datei. d0 enthaelt letzten Fehlercode

fsr_nxtfile:
 ext.l    d0                       ; Fehler beim letzen Fsfirst/next ?
 bmi.b    fsr_l3                   ; ja, Ende
 cmp.w    -120(a4),d7
 bcs      fsr_readloop
 moveq    #$ffffffdf,d0            ; ENMFIL simulieren

* Ende des Einlesens.
* d0.l ist in jedem Fall negativ
* Ein Fehlercode EFILNF oder ENMFIL ist kein Fehler!

fsr_l3:
 cmpi.w   #$ffdf,d0                ; EFILNF
 beq.b    fsr_okay
 cmpi.w   #$ffcf,d0                ; ENMFIL
 beq.b    fsr_okay
 bsr      form_error               ; Hier wird der Fehler angezeigt!
fsr_okay:
 move.w   d7,d0
 beq.b    fsr_draw                 ; keine Dateien
 move.l   a4,a0
 bsr      sort_files
fsr_draw:

* d7.l ist jetzt 0 oder enthaelt die Anzahl der Dateien

 lea      -100(a4),a1
 move.l   a3,a0
fsr_cat:
 move.b   (a1)+,(a0)+              ; unser Muster wieder dahinterhaengen
 bne.b    fsr_cat

 moveq    #FS_PATH,d0              ; Pfad neumalen
 move.l   a5,a0
 jsr      _objc_draw

 moveq    #FS_PATT,d0              ; Muster neumalen
 move.l   a5,a0
 jsr      _objc_draw

 move.w   FS_SCRL*24+ob_height(a5),d0   ; Hoehe des Scrollfelds
 cmpi.w   #9,d7
 bls.b    fsr_l4                   ; <= 9 Dateien
 muls     #9,d0
 ext.l    d0
 divu     d7,d0
fsr_l4:
 clr.w    FS_SLID*24+ob_y(a5)           ; Scrollbalken nach oben
 move.w   d0,FS_SLID*24+ob_height(a5)   ; Hoehe des Scrollbalkens

* Laufwerkbuttons bearbeiten

 moveq    #16-1,d6                 ; 16 Laufwerke
 lea      FS_DRV16*24(a5),a3       ; letztes Laufwerk
fsx_drvs:
 move.w   ob_state(a3),d1
 btst     #3,d1
 bne.b    fsx_nxtdrv               ; DISABLED
 move.b   (a6),d0                  ; erstes Zeichen des Pfades
 cmp.b    ob_spec(a3),d0           ; unser Laufwerk ?
 bne.b    fsx_other                ; nein
 bset     #0,d1                    ; ja, selektieren
 bne.b    fsx_nxtdrv               ; war schon selektiert
 bra.b    fsx_chgdrv
fsx_other:
 bclr     #0,d1                    ; deselektieren
 beq.b    fsx_nxtdrv               ; war schon deselektiert
fsx_chgdrv:
 moveq    #1,d2
;move.w   d1,d1
 move.w   d6,d0
 addi.w   #FS_DRV1,d0
 move.l   a5,a0
 jsr      _objc_change
fsx_nxtdrv:
 lea      -24(a3),a3
 dbra     d6,fsx_drvs

 move.w   d7,d1
 moveq    #0,d0
 move.l   a4,a1
 move.l   a5,a0
 bsr      fs_show_9_files

 moveq    #0,d0                    ; Pfeil
 jsr      graf_mouse               ; Maus wieder als Pfeil

 move.l   d7,d0                    ; Anzahl Dateien oder 0

 adda.w   #$2c,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6
 rts


**********************************************************************
*
* int fname_match( a0 = char *patt, a1 = char *fname )
*
* patt ist etwa "*.PRG,*.APP"
* Rueckgabe 1, wenn passt
*

fname_match:
 move.l   a3,-(sp)
 move.l   a0,a3                    ; patt merken
 move.l   a1,a2                    ; fname merken
fnm_nxt_patt:
 bsr      _fname_match
 bne.b    fnm_ende                 ; passt !
fnm_loop:
 tst.b    (a3)
 beq.b    fnm_ende
 cmpi.b   #',',(a3)+               ; suche Komma oder EOS
 bne.b    fnm_loop
 move.l   a3,a0                    ; a0 hinter Komma, naechstes Muster
 move.l   a2,a1
 bra.b    fnm_nxt_patt
fnm_ende:
 tst.w    d0
 move.l   (sp)+,a3
 rts

_fname_match:
 tst.b    (a0)                     ; Ende des Patterns
 beq.b    _fn_eopat
 cmpi.b   #',',(a0)                ; Ende des Patterns
 beq.b    _fn_eopat
 tst.b    (a1)
 beq.b    flnm_l5
 cmpi.b   #'?',(a0)
 bne.b    flnm_l2
 addq.l   #1,a0
 cmpi.b   #'.',(a1)
 beq.b    _fname_match
flnm_l1:
 addq.l   #1,a1
 bra.b    _fname_match
flnm_l2:
 cmpi.b   #'*',(a0)
 bne.b    flnm_l3
 cmpi.b   #'.',(a1)
 bne.b    flnm_l1
 addq.l   #1,a0
 bra.b    _fname_match
flnm_l3:
 move.b   (a0),d0
 cmp.b    (a1),d0
 bne.b    flnm_ret0
 addq.l   #1,a0
 bra.b    flnm_l1
flnm_l4:
 addq.l   #1,a0
flnm_l5:
 cmpi.b   #'*',(a0)
 beq.b    flnm_l4
 cmpi.b   #'?',(a0)
 beq.b    flnm_l4
 cmpi.b   #'.',(a0)
 beq.b    flnm_l4
 tst.b    (a0)
 beq.b    _fn_eopat
 cmpi.b   #',',(a0)
 bne.b    flnm_ret0
_fn_eopat:
 tst.b    (a1)
 bne.b    flnm_ret0
 moveq    #1,d0
 rts
flnm_ret0:
 moveq    #0,d0
 rts


**********************************************************************
*
* void sort_files( a0 = char s[n][16], d0 = int n )
*

sort_files:
 movem.l  d3/d4/d5/d6/d7/a4/a5,-(sp)
 movea.l  a0,a5
 move.w   d0,d3
 move.w   d0,d7
 bra      srtf_l7
srtf_l1:
 move.w   d7,d6
 bra      srtf_l6
srtf_l2:
 move.w   d6,d5
 bra.b    srtf_l4
srtf_l3:

 move.w   d5,d0
 add.w    d7,d0
 lsl.w    #4,d0
 lea      0(a5,d0.w),a4
 move.w   d5,d0
 lsl.w    #4,d0
 lea      0(a5,d0.w),a2

 move.l   a4,a1
 move.l   a2,a0
 jsr      strcmp

 tst.w    d0
 ble.b    srtf_l5

* strings a2/a4 tauschen

 moveq    #16-1,d1                 ; 16 Zeichen
sort_loop:
 move.b   (a2),d0
 move.b   (a4),(a2)+
 move.b   d0,(a4)+
 dbra     d1,sort_loop

srtf_l4:
 sub.w    d7,d5
 bge.b    srtf_l3
srtf_l5:
 addq.w   #1,d6
srtf_l6:
 cmp.w    d3,d6
 blt      srtf_l2
srtf_l7:
 lsr.w    #1,d7
 tst.w    d7
 bgt      srtf_l1
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* void fs_show_9_files(a0 = OBJECT *tree, a1 = void *mem, d0 = int n,
*                      d1 = int nfiles)
*
* ab Nummer <n> werden genau 9 Dateien angezeigt. n ist immer fsel_scrollpos
* Die 9 Dateinamen und der Scrollbalken werden neu gezeichnet, die
* Position des Scrollbalkens vorher korrigert.
*

fs_show_9_files:
 movem.l  d7/a3/a4/a5,-(sp)
 move.w   d0,d7                    ; d7 = n
 move.l   a0,a5                    ; tree
 move.l   a1,a4                    ; mem

 move.w   FS_SCRL*24+ob_height(a5),d0   ; Scrollfeldhoehe
 mulu     d7,d0                    ; * Nr. der ersten angezeigten Datei
 tst.w    d1                       ; Anzahl Dateien ueberhaupt
 beq.b    fssw_l1                  ; ist 0
 ext.l    d0
 divu     d1,d0
fssw_l1:
 move.w   d0,FS_SLID*24+ob_y(a5)   ; Scrollbalkenposition

 moveq    #8,d1
 moveq    #FS_SCRL,d0              ; Scrollfeld malen
 move.l   a5,a0
 jsr      _objc_draw

 lea      FS_FILE1*24(a5),a3       ; erstes Dateinamenfeld
 lsl.w    #4,d7
 add.w    d7,a4                    ; erster anzuzeigender Dateiname
 moveq    #9-1,d7                  ; Zaehler

* immer genau 9 Felder bearbeiten

fssw_l2:
 clr.w    ob_state(a3)             ; Status loeschen
 move.l   ob_spec(a3),a0           ; TEDINFO *
 move.l   a4,te_ptext(a0)

 lea      24(a3),a3
 lea      16(a4),a4
 dbra     d7,fssw_l2

 moveq    #8,d1                    ; volle Tiefe
 moveq    #FS_WFILS,d0             ; Fensterhinhalt + Dateinamen
 move.l   a5,a0                    ; Baum
 bsr      _objc_draw

 movem.l  (sp)+,a5/a4/a3/d7
 rts


fskeys:
 DC.L     0
 DC.L     0
 DC.L     fsctrlkeys
 DC.L     fsaltkeys
 DC.L     0

fsctrlkeys:
 DC.B     $48,1,0,FS_UP            ; CTRL-uparrow
 DC.B     $50,1,0,FS_DOWN          ; CTRL-dnarrow
 DC.W     0
fsaltkeys:
 DC.B     1,1,0,FS_PATT            ; ALT-Esc
 DC.B     14,1,0,FS_CLOSE          ; ALT-Bs
 DC.B     120,1,0,FS_FILE1         ; ALT-1
 DC.B     121,1,0,FS_FILE1+1       ; ALT-2
 DC.B     122,1,0,FS_FILE1+2       ; ALT-3
 DC.B     123,1,0,FS_FILE1+3       ; ALT-4
 DC.B     124,1,0,FS_FILE1+4       ; ALT-5
 DC.B     125,1,0,FS_FILE1+5       ; ALT-6
 DC.B     126,1,0,FS_FILE1+6       ; ALT-7
 DC.B     127,1,0,FS_FILE1+7       ; ALT-8
 DC.B     128,1,0,FS_FILE1+8       ; ALT-9
 DC.B     30,1,0,FS_DRV1           ; ALT-A
 DC.B     48,1,0,FS_DRV1+1         ; ALT-B
 DC.B     46,1,0,FS_DRV1+2         ; ALT-C
 DC.B     32,1,0,FS_DRV1+3         ; ALT-D
 DC.B     18,1,0,FS_DRV1+4         ; ALT-E
 DC.B     33,1,0,FS_DRV1+5         ; ALT-F
 DC.B     34,1,0,FS_DRV1+6         ; ALT-G
 DC.B     35,1,0,FS_DRV1+7         ; ALT-H
 DC.B     23,1,0,FS_DRV1+8         ; ALT-I
 DC.B     36,1,0,FS_DRV1+9         ; ALT-J
 DC.B     37,1,0,FS_DRV1+10        ; ALT-K
 DC.B     38,1,0,FS_DRV1+11        ; ALT-L
 DC.B     50,1,0,FS_DRV1+12        ; ALT-M
 DC.B     49,1,0,FS_DRV1+13        ; ALT-N
 DC.B     24,1,0,FS_DRV1+14        ; ALT-O
 DC.B     25,1,0,FS_DRV1+15        ; ALT-P
 DC.W     0

fsel3dtab:
 DC.B     6,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,35,37,38,-1
 EVEN

fsel_tree:
 DC.W     -1,1,40                  ;  0: umgebende Box
 DC.W     G_BOX,FL3DBAK,OUTLINED
 DC.L     $21100
 DC.W     0,0,40,19

 DC.W     2,-1,-1                  ;  1: Titelzeile
 DC.W     G_TEXT,FL3DBAK,0
 DC.L     fs_tedinfo0-fsel_tree
 DC.W     $0205,$0600,30,1

 DC.W     3,-1,-1                  ;  2: "PFAD:"
 DC.W     G_STRING,0,0
 DC.L     fs_pfad
 DC.W     1,$0601,5,1

 DC.W     4,-1,-1                  ;  3: Pfad
 DC.W     G_FTEXT,FL3DBAK+EDITABLE+HIDETREE,0
 DC.L     fs_tedinfo1-fsel_tree
 DC.W     $0101,$0103,37,1

 DC.W     5,-1,-1                  ;  4: Auswahl
 DC.W     G_FTEXT,FL3DBAK+EDITABLE,0
 DC.L     fs_tedinfo2-fsel_tree
 DC.W     $0103,$0604,21,1

 DC.W     6,-1,-1                  ;  5: "LAUFWERK:"
 DC.W     G_STRING,0,0
 DC.L     fs_laufwerk
 DC.W     $071a,5,9,1

 DC.W     7,-1,-1                  ;  6: Schliessfeld
 DC.W     G_BOXCHAR,FL3DACT+TOUCHEXIT,0
 DC.L     $5011100
 DC.W     3,6,0x0a01,$0301

 DC.W     8,-1,-1                  ;  7: Pfadmuster
 DC.W     G_BOXTEXT,FL3DBAK+TOUCHEXIT,0
 DC.L     fs_tedinfo3-fsel_tree
 DC.W     $0904,6,$0413,$0301

 DC.W     25,9,24                  ;  8: Vater fuer Laufwerkbuttons
 DC.W     G_IBOX,0,0
 DC.L     0
 DC.W     27,0x0106,10,8

 DC.W     10,-1,-1                 ;  9: Laufwerk A:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $41011100
 DC.W     0,0,4,$0101

 DC.W     11,-1,-1                 ; 10: Laufwerk B:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $42011100
 DC.W     5,0,4,$0101

 DC.W     12,-1,-1                 ; 11: Laufwerk C:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $43011100
 DC.W     0,1,4,$0101

 DC.W     13,-1,-1                 ; 12: Laufwerk D:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $44011100
 DC.W     5,1,4,$0101

 DC.W     14,-1,-1                 ; 13: Laufwerk E:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $45011100
 DC.W     0,2,4,$0101

 DC.W     15,-1,-1                 ; 14: Laufwerk F:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $46011100
 DC.W     5,2,4,$0101

 DC.W     16,-1,-1                 ; 15: Laufwerk G:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $47011100
 DC.W     0,3,4,$0101

 DC.W     17,-1,-1                 ; 16: Laufwerk H:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $48011100
 DC.W     5,3,4,$0101

 DC.W     18,-1,-1                 ; 17: Laufwerk I:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $49011100
 DC.W     0,4,4,$0101

 DC.W     19,-1,-1                 ; 18: Laufwerk J:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4a011100
 DC.W     5,4,4,$0101

 DC.W     20,-1,-1                 ; 19: Laufwerk K:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4b011100
 DC.W     0,5,4,$0101

 DC.W     21,-1,-1                 ; 20: Laufwerk L:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4c011100
 DC.W     5,5,4,$0101

 DC.W     22,-1,-1                 ; 21: Laufwerk M:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4d011100
 DC.W     0,6,4,$0101

 DC.W     23,-1,-1                 ; 22: Laufwerk N:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4e011100
 DC.W     5,6,4,$0101

 DC.W     24,-1,-1                 ; 23: Laufwerk O
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $4f011100
 DC.W     0,7,4,$0101

 DC.W     8,-1,-1                  ; 24: Laufwerk P:
 DC.W     G_BOXCHAR,FL3DIND+SELECTABLE+TOUCHEXIT+RBUTTON,0
 DC.L     $50011100
 DC.W     5,7,4,$0101

 DC.W     35,26,34                 ; 25: Fensterbereich
 DC.W     G_IBOX,HIDETREE,0
 DC.L     $011100
 DC.W     3,0x0207,19,11

 DC.W     27,-1,-1                 ; 26: Dateiname 1
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo4-fsel_tree
 DC.W     2,1,15,1

 DC.W     28,-1,-1                 ; 27: Dateiname 2
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo5-fsel_tree
 DC.W     2,2,15,1

 DC.W     29,-1,-1                 ; 28: Dateiname 3
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo6-fsel_tree
 DC.W     2,3,15,1

 DC.W     30,-1,-1                 ; 29: Dateiname 4
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo7-fsel_tree
 DC.W     2,4,15,1

 DC.W     31,-1,-1                 ; 30: Dateiname 5
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo8-fsel_tree
 DC.W     2,5,15,1

 DC.W     32,-1,-1                 ; 31: Dateiname 6
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo9-fsel_tree
 DC.W     2,6,15,1

 DC.W     33,-1,-1                 ; 32: Dateiname 7
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo10-fsel_tree
 DC.W     2,7,15,1

 DC.W     34,-1,-1                 ; 33: Dateiname 8
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo11-fsel_tree
 DC.W     2,8,15,1

 DC.W     25,-1,-1                 ; 34: Dateiname 9
 DC.W     G_FBOXTEXT,FL3DIND+TOUCHEXIT,0
 DC.L     fs_tedinfo12-fsel_tree
 DC.W     2,9,15,1

 DC.W     36,-1,-1                 ; 35: Pfeil nach unten
 DC.W     G_BOXCHAR,FL3DACT+TOUCHEXIT,0
 DC.L     $02011100
 DC.W     $ff16,0x0210,$0e01,2

 DC.W     38,37,37                 ; 36: graues Scrollfeld
 DC.W     G_BOX,TOUCHEXIT,0
 DC.L     $00011111
 DC.W     $ff16,$0109,$0e01,$0207

 DC.W     36,-1,-1                 ; 37: weisser Scrollbalken
 DC.W     G_BOX,FL3DACT+TOUCHEXIT,0
 DC.L     $00011100
 DC.W     0,0,$0e01,$0207          ; Balken ganz oben, volle Hoehe

 DC.W     39,-1,-1                 ; 38: Pfeil nach oben
 DC.W     G_BOXCHAR,FL3DACT+TOUCHEXIT,0
 DC.L     $01011100
 DC.W     $ff16,0x0207,$0e01,2

 DC.W     40,-1,-1                 ; 39: "OK"
 DC.W     G_BUTTON,FL3DACT+SELECTABLE+DEFAULT+EXIT,0
 DC.L     fs_ok
 DC.W     27,15,9,1

 DC.W     0,-1,-1                  ; 40: "Abbruch"
 DC.W     G_BUTTON,FL3DACT+SELECTABLE+EXIT+LASTOB,0
 DC.L     fs_abbruch
 DC.W     27,17,9,1


fs_tedinfo0:                       ; Fileselector- Titel
 DC.L     fs_dflttit               ; "Objektauswahl"
 DC.L     0
 DC.L     0
 DC.W     3,6,2,$1100,0,0,0,0

fs_tedinfo1:                       ; Fileselector- Pfad
 DC.L     0                        ; Text hier einklinken
 DC.L     fs_string5               ; 37 mal '_'
 DC.L     fs_string6               ; "x"
 DC.W     3,1,0,$1180,0,-2,38,38

fs_tedinfo2:                       ; Fileselector: ausgewaehlter Dateiname
 DC.L     0                        ; Text hier einklinken
 DC.L     fs_string9               ; "AUSWAHL: ________.___"
 DC.L     fs_string10              ; "F"
 DC.W     3,1,0,$1180,0,-2,12,22

fs_tedinfo3:                       ; Fileselector: Pfadmuster
 DC.L     0                        ; Text hier einklinken
 DC.L     0
 DC.L     0
 DC.W     3,1,2,$11a1,0,1,12,13

fs_tedinfo4:                       ; Fileselector: Dateiname 1
 DC.L     0                        ; Text hier einklinken
 DC.L     fs_string16              ; "_ ________.___"
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo5:                       ; Fileselector: Dateiname 2
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo6:                       ; Fileselector: Dateiname 3
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo7:                       ; Fileselector: Dateiname 4
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo8:                       ; Fileselector: Dateiname 5
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo9:                       ; Fileselector: Dateiname 6
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo10:                      ; Fileselector: Dateiname 7
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo11:                      ; Fileselector: Dateiname 8
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fs_tedinfo12:                      ; Fileselector: Dateiname 9
 DC.L     0
 DC.L     fs_string16
 DC.L     0
 DC.W     3,1,0,$1100,0,0,13,15

fsel_tree_end:

     IF   COUNTRY=COUNTRY_DE
fs_dflttit:    DC.B "OBJEKT-AUSWAHL",0
fs_ok:         DC.B "OK",0
fs_abbruch:    DC.B "ABBRUCH",0
fs_pfad:       DC.B "PFAD:",0
fs_laufwerk:   DC.B "LAUFWERK:",0
fs_string5:    DC.B "_____________________________________",0
fs_string6:    DC.B "x",0
fs_string9:    DC.B "AUSWAHL: ________.___",0
fs_string10:   DC.B "F",0
fs_string16:   DC.B "_ ________.___",0
diskinfo:      DC.B '[0][Informationen f',$81,'r Laufwerk %S:| |'
               DC.B '%L Bytes insgesamt|'
               DC.B '%L Bytes frei][  OK  ]',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
fs_dflttit:    DC.B "FILE SELECTOR",0
fs_ok:         DC.B "OK",0
fs_abbruch:    DC.B "CANCEL",0
fs_pfad:       DC.B "PATH:",0
fs_laufwerk:   DC.B "DRIVE:",0
fs_string5:    DC.B "_____________________________________",0
fs_string6:    DC.B "x",0
fs_string9:    DC.B "FILE   : ________.___",0
fs_string10:   DC.B "F",0
fs_string16:   DC.B "_ ________.___",0
diskinfo:      DC.B '[0][Information about drive %S:| |'
               DC.B '%L Bytes total|'
               DC.B '%L Bytes free][  OK  ]',0
     ENDIF
     IF  COUNTRY=COUNTRY_FR
fs_dflttit:    DC.B "CHOIX D'OBJET",0
fs_ok:         DC.B "OK",0
fs_abbruch:    DC.B "ABANDON",0
fs_pfad:       DC.B "CHEMIN:",0
fs_laufwerk:   DC.B "LECTEUR:",0
fs_string5:    DC.B "_____________________________________",0
fs_string6:    DC.B "x",0
fs_string9:    DC.B "CHOIX : ________.___",0
fs_string10:   DC.B "F",0
fs_string16:   DC.B "_ ________.___",0
diskinfo:      DC.B '[0][Informations pour le lecteur %S:| |'
               DC.B '%L Bytes en tout|'
               DC.B '%L Bytes libres][  OK  ]',0
     ENDIF

     EVEN

     END
