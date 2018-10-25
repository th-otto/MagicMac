     OFFSET

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
MacSys_VgetRGB:     DS.L 1         ; Farbe erfragen (a0 zeigt auf den Stack bei VgetRGB())
MacSys_error:       DS.L 1         ; Fehlermeldung in d0.l an das Mac-System zurueckgeben
               ; Fehlermeldungen bei MacSys_error:
               ; -1: nicht unterstuetzte Grafikaufloesung => kein VDI-Treiber
MacSys_init:        DS.L 1         ; Wird beim Warmstart des Atari aufgerufen
MacSys_drv2devcode: DS.L 1         ; umrechnen Laufwerk->Devicenummer
MacSys_rawdrvr:     DS.L 1         ; Raw-Driver (Eject) fuer Mac
MacSys_floprd:      DS.L 1
MacSys_flopwr:      DS.L 1
MacSys_flopfmt:     DS.L 1
MacSys_flopver:     DS.L 1
MacSys_superstlen:  DS.L 1         ; Groesse des Supervisorstack pro APP
MacSys_dos_macfn:   DS.L 1         ; DOS-Funktionen 0x60..0xfe
MacSys_settime:     DS.L 1         ; xbios Settime
MacSys_prn_wrts:    DS.L 1         ; String auf Drucker
MacSys_version:     DS.L 1         ; Versionsnummer der Struktur
MacSys_in_interrupt: DS.L 1        ; Interruptzaehler fuer Mac-Seite
MacSys_drv_fsspec:  DS.L 1         ; Liste der FSSpec fuer Mac-Laufwerke
MacSys_cnverr:      DS.L 1         ; LONG cnverr( WORD mac_errcode )
MacSys_res1:        DS.L 1         ; reserviert
MacSys_res2:        DS.L 1         ; reserviert
MacSys_res3:        DS.L 1         ; reserviert

     TEXT

* Die beiden folgenden Macros widme ich den Hirnis, die den
* PASM entwickelt haben und mit den 68020-Adressierungsarten
* nur Unsinn erzeugen.
* Fuer "memory indirect postindexed"
* und "memory indirect"
*
* Syntax:      jsr_mip base,offs   =>   jsr  ([base.l],offs.w)
*              jsr_mi  base        =>   jsr  ([base.l])
*              mva0_mip base,offs  =>   movea.l ([base.l],offs.w),a0
*

MACRO     mva0_mip base,offs
          DC.W %0010000001110000   ; movea.l (mod=110,reg=000),a0
                                   ;  memory indir. postindexed
                                   ;  mit base register a0
          DC.W %0000000111110010   ; Indexregister: d0.w*1
                                   ; Base register suppressed
                                   ; Index register suppressed
                                   ; Base disp size LONG
                                   ; memory indirect with WORD outer
                                   ;  displacement
          DC.L base                ; base displacement
          DC.W offs                ; offset
          ENDM

MACRO     jsr_mip base,offs
          DC.W %0100111010110000   ; jsr (mod=110,reg=000)
                                   ;  memory indir. postindexed
                                   ;  mit base register a0
          DC.W %0000000111110010   ; Indexregister: d0.w*1
                                   ; Base register suppressed
                                   ; Index register suppressed
                                   ; Base disp size LONG
                                   ; memory indirect with WORD outer
                                   ;  displacement
          DC.L base                ; base displacement
          DC.W offs                ; offset
          ENDM

MACRO     jsr_mi base
          DC.W %0100111010110000   ; jsr (mod=110,reg=000)
                                   ;  memory indir. postindexed
                                   ;  mit base register a0
          DC.W %0000000111110001   ; Indexregister: d0.w*1
                                   ; Base register suppressed
                                   ; Index register suppressed
                                   ; Base disp size LONG
                                   ; memory indirect with NULL outer
                                   ;  displacement
          DC.L base                ; base displacement
          ENDM

MACRO     MAC
          DC.W $4eb0
          DC.W $01e1
          DC.W $00f0
          ENDM

MACRO     ATARI
          DC.W $4eb0
          DC.W $01e1
          DC.W $00f4
          ENDM
