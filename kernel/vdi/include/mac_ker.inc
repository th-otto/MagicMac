                    OFFSET 0

MacSys_magic:       DS.L 1         ; ist 'MagC'
MacSys_syshdr:      DS.L 1         ; Adresse des Atari-Syshdr
MacSys_keytabs:     DS.L 1         ; 5*128 Bytes fuer Tastaturtabellen
MacSys_ver:         DS.L 1         ; Version
MacSys_cpu:         DS.W 1         ; CPU (30=68030, 40=68040)
MacSys_fpu:         DS.W 1         ; FPU (0=nix,4=68881,6=68882,8=68040)
MacSys_boot_sp:     DS.L 1         ; sp fuers Booten
MacSys_biosinit:    DS.L 1         ; nach Initialisierung aufrufen
MacSys_pixmap:      DS.L 1         ; Daten fuers VDI
MacSys_offs_32k:    DS.L 1         ; Adressenoffset fuer erste 32k im MAC
MacSys_a5:          DS.L 1         ; globales Register a5 fuer Mac-Programm
MacSys_tasksw:      DS.L 1         ; != NULL, wenn Taskswitch erforderlich
MacSys_gettime:     DS.L 1         ; Datum und Uhrzeit ermitteln
MacSys_bombs:       DS.L 1         ; Atari-Routine, wird vom MAC aufgerufen
MacSys_syshalt:     DS.L 1         ; "System halted", String in a0
MacSys_coldboot:    DS.L 1
MacSys_debugout:    DS.L 1         ; fuers Debugging
MacSys_prtis:       DS.L 1         ;    Fuer Drucker (PRT)
MacSys_prtos:       DS.L 1         ;
MacSys_prtin:       DS.L 1         ;
MacSys_prtout:      DS.L 1         ;
MacSys_serconf:     DS.L 1         ;    Rsconf fuer ser1
MacSys_seris:       DS.L 1         ;    Fuer ser1 (AUX)
MacSys_seros:       DS.L 1         ;
MacSys_serin:       DS.L 1         ;
MacSys_serout:      DS.L 1         ;
MacSys_xfs:         DS.L 1         ; Routinen fuer das XFS
MacSys_xfs_dev:     DS.L 1         ;  Zugehoeriger Dateitreiber
MacSys_set_physbase: DS.L 1        ; Bildschirmadresse bei Setscreen umsetzen (a0 zeigt auf den Stack von Setscreen())
MacSys_VsetRGB:     DS.L 1         ; Farbe setzen (a0 zeigt auf den Stack bei VsetRGB())
MacSys_VgetRGB:     DS.L 1         ; Farbe ergragen (a0 zeigt auf den Stack bei VgetRGB())
MacSys_error:       DS.L 1         ; Fehlermeldung in d0.l an das Mac-System zurueckgeben

;Fehlermeldungen bei MacSys_error:
;-1: nicht unterstuetzte Grafikaufloesung => kein VDI-Treiber
