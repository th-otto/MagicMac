                                                         Misburg, den 13.08.93

README zu Mag!X V2.00 fÅr (Mega) ST(E) und TT
=============================================

Diese Datei enthÑlt wichtige Hinweise zur Installation und und zum Betrieb
von Mag!X. Ferner werden ggf. énderungen zum Handbuch hier untergebracht.
Ihnen sollten folgende HandbÅcher vorliegen:

     1. Mag!X
     2. Mag!X 2.00

Das erste Handbuch wird seit V1.0 ausgeliefert, seit V2.0 gibt es ein
Zusatzhandbuch, das die neuen Features von Mag!X beschreibt. Diese Datei
enthÑlt daher nur Informationen, die nicht mehr im Mag!X 2.00- ErgÑnzungs-
Handbuch untergebracht werden konnten.
Auûerdem sind hier alle Zusatzprogramme und -dateien aufgefÅhrt, auf die im
Handbuch nicht nÑher eingegangen wird.
Um den Betriebssystem- Zusatz Mag!X zu benutzen, genÅgt das Starten des
Programms INSTMAGX und die Vorgehensweise nach Handbuch.
Sollte das System sich von Ihrer Platte nicht starten lassen, so klemmen Sie
Ihre Platte ab und versuchen es von Diskette. Funktioniert Mag!X jetzt, liegt
das Problem an Ihrem Plattentreiber. Setzen Sie sich mit dem Hersteller Ihrer
Platte bzw. der zugehîrigen Software in Verbindung oder verwenden Sie einen
alternativen Plattentreiber.
Achtung:  Bestimmte (Ñltere) Versionen des Plattentreibers von der Scheiben-
          kleister- Diskette ("CBHD") haben die Eigenschaft, unter Mag!X
          einen Virus zu melden. Dies resultiert in einer fehlerhaften
          Abfrage und kann zunÑchst getrost ignoriert werden. Sie sollten
          sich aber eine neue Version besorgen, bei der der Fehler behoben
          ist.
Achtung:  Wenn Sie zusammen mit Mag!X ein GDOS verwenden mîchten, mÅssen Sie
          folgendes beachten:

          Der Mag!X-Booter MAGXBOOT.PRG muû im AUTO-Ordner unbedingt vor
          NVDI und auch vor einem anderen GDOS liegen. Wenn Sie kein AUTO-
          Ordner-Sortierprogramm haben, kopieren Sie den ganzen AUTO-Ordner
          etwa in einen neuen AUTO-Ordner AUTO2, lîschen den AUTO-Ordner und
          kopieren jetzt MAGXBOOT.PRG als erstes Programm in den neuen AUTO-
          Ordner zurÅck, danach die anderen Dateien.

          Wenn Sie nicht FSMGDOS oder NVDI in einer Version 2.02 oder grîûer
          verwenden, sollten Sie alle Fonts fÅr Bildschirmtreiber resident
          laden, um Konflikte mit dem Multitasking zu vermeiden.

          Wenn Sie die virtuelle Speicherverwaltung OUTSIDE verwenden,
          kînnen Sie statt MAGXBOOT auch MAGXBO32 verwenden. Dieses alterna-
          tive Bootprogramm ermîglicht, daû OUTSIDE den Speicherbereich von
          Mag!X schreibschÅtzen kann.


˘ Dateien auf dieser Diskette:

     \INSTMAGX.PRG            Installationsprogramm
     \INSTMAGX.RSC            zugehîrige Ressourcen
     \README.TXT              ?
     \MAGX\                   Das Multitaskingsystem
     \MAGX\ICNEDIT            Diese Dateien benîtigen Sie, um in MAGXDESK
                              bestimmten Programmen oder Dateien bestimmte
                              Icons zuzuweisen, neue Icons zu erstellen oder
                              bestehende zu Ñndern. Diese Dateien werden
                              NICHT von INSTMAGX automatisch auf Ihre
                              Festplatte kopiert.
                              NÑheres in den Kapiteln B10 und B11 des
                              Handbuchs
     \MAGX\ZUSATZ             Diese Dateien werden NICHT von INSTMAGX
                              automatisch auf Ihre Festplatte kopiert, da sie
                              nicht in jedem Fall benîtigt werden.
     ZUSATZ\GMNIMAGX          Ein Programm von Oliver Scheel, das es ermîg-
                              licht, unter Mag!X und Gemini Programme
                              parallel zu starten
     ZUSATZ\CPX               Ein Programm von Stefan Radermacher, das die
                              Funktion von MAGXCONF.ACC als CPX zusammen mit
                              dem XCONTROL.ACC von Atari bietet.
     ZUSATZ\AES_LUPE          Ein Programm von Laurenz PrÅûner, das
                              eigentlich als Accessory gedacht ist, aber
                              hervorragend die Multitasking-Eigenschaften
                              von Mag!X demonstriert.
                              Die Lupe ist weder Public Domain noch
                              Shareware, sondern lizensiert!!!
     ZUSATZ\CLOCK             Shareware- Uhrenprogramm von Stefan Hintz.
                              Ein bestechendes Programm, das eigentlich als
                              Accessory gedacht ist, aber unter Mag!X
                              problemlos im Hintergrund lÑuft.
                              Besonders dann, wenn es als nicht oberstes
                              Fenster verschoben wird, zeigt es schonungs- und
                              erbarmungslos den Unterschied zwischen TOS und
                              Mag!X.
                              Sollte einfach in den GEM-AUTO-Ordner kopiert
                              werden.
     ZUSATZ\MAGX.INF          Beispieldatei mit genauer ErklÑrung aller
                              Einstellmîglichkeiten, die z.T. im Handbuch
                              nicht erwÑhnt und nur fÅr Spezialisten geeignet
                              sind.
     ZUSATZ\ROMDRVR.PRG       Ein Treiberprogramm fÅr ROM-Module. Legen Sie
                              dieses Programm in den AUTO- Ordner, wird ein
                              neues Laufwerk R: eingerichtet, das die Dateien
                              des Moduls enthÑlt. Sie kînnen Ihr Modul dann
                              von MAGXDESK oder KCMD oder jedem anderen
                              Programm aus nutzen, das Laufwerke mit Namen R:
                              nicht verbietet.
     ZUSATZ\MAGXDEMO.PRG      Demoprogramm fÅr die erweiterten Dialogboxen in
                              Mag!X
     ZUSATZ\DEMO5.PRG         Demoprogramm fÅr die MultitaskingfÑhigkeiten
                              von Mag!X. LÑuft auch unter anderen eventuellen
                              Multitaskingsystemen und unter TOS (natÅrlich
                              allein) sowie auch als Accessory. Zeigt seine
                              besonderen FÑhigkeiten erst, wenn unter einem
                              nicht-Mag!X mehrfach gestartet.
     ZUSATZ\MAGX.H            Headerdatei fÅr das Programmieren in 'C' zur
                              Verwendung von MAGXLIB.LIB
     ZUSATZ\MAGXLIB.LIB       Bibliothek fÅr Turbo/Pure C mit allen neuen
                              Systemaufrufen von Mag!X
     \KCMD\                   ist ein Shareware- Kommandoprozessor, der als
                              Batchprozessor fÅr MAGXDESK verwendet werden
                              kann (im Dialog Optionen/Programme unter
                              "Command" eintragen).
                              Wenn Sie TOS-Programme per VT52.PRG im Fenster
                              laufen lassen mîchten, mÅssen Sie MCMD.TOS
                              verwenden, andernfalls gibt es Schwierigkeiten
                              mit dem Ein- und Abschalten des Mauszeigers.
                              Die Anleitung CMD.DOC liegt im WORDPLUS- Format
                              vor, da davon ausgegangen wird, daû jeder die
                              Mîglichkeit hat, solche Dateien selbst auszu-
                              drucken oder ausdrucken zu lassen.  Mit Hilfe
                              des Programms \KCMD\BIN\WORDTOAS.TTP kann man
                              die Dateien auch in reines ASCII- Format umwan-
                              deln (als Parameter den vollstÑndigen Pfad der
                              .DOC-Datei angeben). Hierbei gehen jedoch wich-
                              tige Hervorhebungen wie  Fett- oder Kursiv-
                              schrift verloren.

˘ Das Verzeichnis \MAGX\ enthÑlt das Programm VT52, mit Hilfe dessen TOS-
  Programme in Fenstern ausgefÅhrt werden. Auûerdem gewÑhrleistet VT52, daû
  diese Programme nicht beim Warten auf Tastatureingaben die restlichen
  Programme lahmlegen.
  Wer VT52 nicht verwenden mîchte, muû in MAGX.INF die Zeile lîschen oder
  auskommentieren, die mit #_TRM beginnt. Notfalls genÅgt es auch, das
  Programm VT52.PRG, das vom Installationsprogramm nach \UTILITY Ihrer
  Bootpartition kopiert wird, zu lîschen oder umzubenennen (das kostet einen
  kurzen Plattenzugriff bei jedem gestarteten TOS-Programm, da jedesmal
  vorher versucht wird, VT52 zu starten).
˘ Nur fÅr Programmierer:
  Seit geraumer Zeit (AES Version 4.0, also auch im MultiTOS 1.0) existiert
  die AES- Funktion appl_getinfo(), die seit MultiTOS 1.07 (AES V4.01) in
  neuen Unterfunktionen (ab Funktionsnummer 4) auch Informationen Åber
  vorhandene Funktionsaufrufe und Eigenschaften sowohl von Mag!X als auch
  von MultiTOS liefert.
  Mit Hilfe dieser in Mag!X 2.00 und MultiTOS vorhandenen Funktion lassen
  sich gezielt Eigenschaften beider Systeme auch zur Laufzeit erfragen.
  Gewissermaûen ist dies die Absegnung der neuen Mag!X- Funktionen seitens
  Atari. Ferner werden wir uns bemÅhen, zukÅnftige Erweiterungen beiderseitig
  abzustimmen, um UnvertrÑglichkeiten zwischen Mag!X und MultiTOS zu
  verhindern.

  Man Åbergibt eine Unterfunktionsnummer und erhÑlt 4 RÅckgabewerte.
  Es gibt folgende Unterfunktionen; sie sind auch unter Mag!X vorhanden:

  Funktion 0: Informationen Åber den normalen AES- Zeichensatz
  -> Wort 1    Fonthîhe
     Wort 2    Font-ID
     Wort 3    Font-Typ (0=system,1=FSM)
  Funktion 1: dito fÅr den kleinen Zeichensatz
  Funktion 2: Farben
  -> Wort 1    VDI-GerÑtenummer (device id)
     Wort 2    Farben fÅr OBJECTs
     Wort 3    Farbicons vorhanden (1) bzw. nicht (0)
     Wort 4    neues RSC-Format vorhanden (1) oder nicht (0)
  Funktion 3: Sprache
  -> Wort 1    z.B. Englisch (0) oder Deutsch (1)
  Funktion 4: allgemeine Information Nr. 1
  -> Wort 1    Multitasking prÑemptiv (1) oder nicht (0)
     Wort 2    appl_find konvertiert MiNT und AES-IDs (1) oder nicht (0)
     Wort 3    appl_search vorhanden (1) oder nicht (0)
     Wort 4    rsrc_rcfix vorhanden (1) oder nicht (0)
  Funktion 5: allgemeine Information Nr. 2
  -> Wort 1    objc_xfind vorhanden (1) oder nicht (0)
     Wort 2    reserviert, immer 0
     Wort 3    menu_click (GEM/3 + Mag!X) vorhanden (1) oder nicht (0)
     Wort 4    shel_r/wdef (GEM/3 + Mag!X) vorhanden (1) oder nicht (0)
  Funktion 6: allgemeine Information Nr. 3
  -> Wort 1    appl_read(-1) vorhanden (1) oder nicht (0)
     Wort 2    shel_get(-1) vorhanden (1) oder nicht (0)
     Wort 3    menu_bar(-1) vorhanden (1) oder nicht (0)
     Wort 4    menu_bar(MENU_INSTL) (Mag!X) vorhanden (1) oder nicht (0)
  Funktion 7: reserviert fÅr Mag!X und andere Erweiterungen, MultiTOS setzt
              alle RÅckgabewerte immer auf 0
  Funktion 8: Maus
  -> Wort 1    graf_mouse- Modi 258-260 vorhanden (1) oder nicht (0)
     Wort 2    Mausform vom AES fÅr jede App. verwaltet (1) oder nicht (0)
  Funktion 9: MenÅs
  -> Wort 1    MultiTOS-SubmenÅs vorhanden (1) oder nicht (0)
     Wort 2    MultiTOS-Popups vorhanden (1) oder nicht (0)
     Wort 3    MultiTOS-ScrollmenÅs vorhanden (1) oder nicht (0)
     Wort 4    erweiterte MN_SELECTED- Nachricht vorhanden (1) oder nicht (0)
  Funktion 10: shel_write
  -> Wort 1    vorhandene Modi
               Bit 0..7:  hîchster zulÑssiger Wert fÅr sh_wdoex & 0x00ff
               Bit 8..15: Bits von sh_wdoex & 0xff00, die wie in MultiTOS
                          behandelt werden
     Wort 2    1: shel_write(0) macht vorherige shel_write- Aufrufe ungÅltig
                  (d.h. das Desktop wird Nachfolgeprogramm) (TOS 1.4 &
                   Mag!X)
               0: startet Programm (MultiTOS)
     Wort 3    1: shel_write(1) startet Programm nach Beendigung des
                  laufenden (TOS 1.4 & Mag!X)
               0: startet Programm sofort (MultiTOS)
     Wort 4    ARGV via sh_wiscr unterstÅtzt (1) oder nicht (0)
  Funktion 11: Fenster
  -> Wort 1    gesetzte Bits signalisieren unterstÅtzte Funktionen:
               Bit 0: WF_TOP liefert zweitoberstes Fenster
                   1: wind_get(WF_NEWDESK)
                   2: wind_g/set(WF_COLOR)
                   3: wind_g/set(WF_DCOLOR)
                   4: wind_get(WF_OWNER)
                   5: wind_g/set(WF_BEVENT)
                   6: WF_BOTTOM
                   7: WF_ICONIFY
                   8: WF_UNICONIFY
                   9..15: reserviert, immer 0
     Wort 2    reserviert, 0
     Wort 3    vorhandene Fensterbuttons:
               Bit 0: Iconifier
                   1: Backdrop-Button (Mag!X)
                   2: Shift-Click fÅr Backdrop
                   3: "Hot" Closebox (GEM/3 & Mag!X)
                   4..15: reserviert, 0
     Wort 4    wind_update check_and_set vorhanden (1) oder nicht (0)
  Funktion 12: Nachrichten
  -> Wort 1    gesetzte Bits signalisieren unterstÅtzte Nachrichten:
               Bit 0: WM_NEWTOP
                   1: WM_UNTOPPED
                   2: WM_ONTOP
                   3: AP_TERM
                   4: MultiTOS- Auflîsungswechsel
                   5: CH_EXIT
                   6: WM_BOTTOM
                   7: WM_ICONIFY
                   8: WM_UNICONIFY
                   9: WM_ALLICONIFY
     Wort 2    reserviert, alle 0
     Wort 3    WM_ICONIFY liefert Koordinaten (1) oder nicht (0)
  Funktion 13: OBJECTs
  -> Wort 1    3D- Objekte Åber ob_flags vorhanden (1) oder nicht (0)
     Wort 2    objc_sysvar vorhanden (1) oder nicht (0)
     Wort 3    Speedo- und GDOS- Fonts im TEDINFO erlaubt (1) oder nicht (0)
     Wort 4    reserviert fÅr Mag!X, wird von MultiTOS auf 0 gesetzt
               Bit 0: G_SWBUTTON vorhanden
                   1: G_POPUP vorhanden
                   2: WHITEBAK steuert Unterstriche und Buttons
  Funktion 14: Formulare (Mag!X form_xdo und form_xdial)
  -> Wort 1    Mag!X- Flydials vorhanden (1) oder nicht (0)
     Wort 2    Mag!X- Tastaturtabellen vorhanden (1) oder nicht (0)
     Wort 3    letzte Cursorposition wird zurÅckgegeben (1) oder nicht (0)
     Wort 4    reserviert, 0
