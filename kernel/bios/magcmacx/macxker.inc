PTRLEN    EQU  4         ; Zeiger auf Elementfunktion braucht 4 Zeiger

     OFFSET

/*
 * some variables are actually host addresses. DO NOT USE THEM,
 * they might actually be 64bit addresses, and are not accessible
 * from Atari-Side anyway
 */
;Atari -> Mac
MacSysX_magic:      DS.L 1         ; ist 'MagC'
MacSysX_len:        DS.L 1         ; Laenge der Struktur
MacSysX_syshdr:     DS.L 1         ; Adresse des Atari-Syshdr
MacSysX_keytabs:    DS.L 1         ; 5*128 Bytes fuer Tastaturtabellen
MacSysX_mem_root:   DS.L 1         ; Speicherlisten
MacSysX_act_pd:     DS.L 1         ; Zeiger auf aktuellen Prozess
MacSysX_act_appl:   DS.L 1         ; Zeiger auf aktuelle Task
MacSysX_verAtari:   DS.L 1         ; Versionsnummer MagicMacX.OS
;Mac -> Atari
MacSysX_verMac:     DS.L 1         ; Versionsnummer der Struktur
MacSysX_cpu:        DS.W 1         ; CPU (30=68030, 40=68040)
MacSysX_fpu:        DS.W 1         ; FPU (0=nix,4=68881,6=68882,8=68040)
MacSysX_init:       DS.L PTRLEN    ; Wird beim Warmstart des Atari aufgerufen
MacSysX_biosinit:   DS.L PTRLEN    ; nach Initialisierung aufrufen
MacSysX_VdiInit:    DS.L PTRLEN    ; nach Initialisierung des VDI aufrufen
MacSysX_pixmap:     DS.L 1         ; Daten fuers VDI
MacSysX_pMMXCookie: DS.L 1         ; 68k-Zeiger auf MgMx-Cookie
MacSysX_Xcmd:       DS.L PTRLEN    ; XCMD-Kommandos
MacSysX_PPCAddr:    DS.L 1         ; tats. PPC-Adresse von 68k-Adresse 0 DO NOT USE
MacSysX_VideoAddr:  DS.L 1         ; tats. PPC-Adresse des Bildschirmspeichers DO NOT USE
MacSysX_Exec68k:    DS.L PTRLEN    ; hier kann der PPC-Callback 68k-Code ausfuehren
MacSysX_gettime:    DS.L 1         ; LONG GetTime(void) Datum und Uhrzeit ermitteln
MacSysX_settime:    DS.L 1         ; void SetTime(LONG *time) Datum/Zeit setzen
MacSysX_Setpalette: DS.L 1         ; void Setpalette( int ptr[16] )
MacSysX_Setcolor:   DS.L 1         ; int Setcolor( int nr, int val )
MacSysX_VsetRGB:    DS.L 1         ; void VsetRGB( WORD index, WORD count, LONG *array )
MacSysX_VgetRGB:    DS.L 1         ; void VgetRGB( WORD index, WORD count, LONG *array )
MacSysX_syshalt:    DS.L 1         ; SysHalt( char *str ) "System halted"
MacSysX_syserr:     DS.L 1         ; SysErr( long val ) "a1 = 0 => Bomben"
MacSysX_coldboot:   DS.L 1         ; ColdBoot(void) Kaltstart ausfuehren
MacSysX_exit:       DS.L 1         ; Exit(void) beenden
MacSysX_debugout:   DS.L 1         ; MacPuts( char *str ) fuers Debugging
MacSysX_error:      DS.L 1         ; d0 = -1: kein Grafiktreiber
MacSysX_prtos:      DS.L 1         ; Bcostat(void) fuer PRT
MacSysX_prtin:      DS.L 1         ; Cconin(void) fuer PRT
MacSysX_prtout:     DS.L 1         ; Cconout( void *params ) fuer PRT
MacSysX_prn_wrts:   DS.L 1         ; LONG PrnWrts({char *buf, LONG count}) String auf Drucker
MacSysX_serconf:    DS.L 1         ; Rsconf( void *params ) fuer ser1
MacSysX_seris:      DS.L 1         ; Bconstat(void) fuer ser1 (AUX)
MacSysX_seros:      DS.L 1         ; Bcostat(void) fuer ser1
MacSysX_serin:      DS.L 1         ; Cconin(void) fuer ser1
MacSysX_serout:     DS.L 1         ; Cconout( void *params ) fuer ser1
MacSysX_SerOpen:    DS.L 1         ; Serielle Schnittstelle oeffnen
MacSysX_SerClose:   DS.L 1         ; Serielle Schnittstelle schliessen
MacSysX_SerRead:    DS.L 1         ; Mehrere Zeichen von seriell lesen
MacSysX_SerWrite:   DS.L 1         ; Mehrere Zeichen auf seriell schreiben
MacSysX_SerStat:    DS.L 1         ; Lese-/Schreibstatus fuer serielle Schnittstelle
MacSysX_SerIoctl:   DS.L 1         ; Ioctl-Aufrufe fuer serielle Schnittstelle
MacSysX_GetKbOrMous: DS.L PTRLEN   ; Liefert Tastatur/Maus
MacSysX_dos_macfn:  DS.L 1         ; DosFn({int,void*} *) DOS-Funktionen 0x60..0xfe
MacSysX_xfs_version: DS.L 1        ; Version des Mac-XFS
MacSysX_xfs_flags:  DS.L 1         ; Flags fuer das Mac-XFS
MacSysX_xfs:        DS.L PTRLEN    ; zentrale Routine fuer das XFS
MacSysX_xfs_dev:    DS.L PTRLEN    ; zugehoeriger Dateitreiber
MacSysX_drv2devcode: DS.L PTRLEN   ; umrechnen Laufwerk->Devicenummer
MacSysX_rawdrvr:    DS.L PTRLEN    ; LONG RawDrvr({int, long} *) Raw-Driver (Eject) fuer Mac
MacSysX_Daemon:     DS.L PTRLEN    ; Aufruf fuer den mmx-Daemon
MacSysX_Yield:      DS.L 1         ; Aufruf fuer Rechenzeit abgeben
MacSys_OldHdr:      DS.L 49        ; Kompatibilitaet mit Behnes
MacSysX_sizeof:

     TEXT

; Prozedur aufrufen. a0 auf Zeiger, a1 ist Parameter.

MACRO     MACPPC
          DC.W $00c0
          ENDM

; Elementfunktion aufrufen. a0 auf 4 Zeiger, a1 ist Parameter

MACRO     MACPPCE
          DC.W $00c1
          ENDM
