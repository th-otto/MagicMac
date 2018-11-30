; Hardwarenahe Funktionen des SERIAL- Treibers fÅr MMX

	SUPER

	XREF kernel
	XREF pSysX

	XDEF _ser_dev_open
	XDEF _ser_dev_close
	XDEF ser_dev_read
	XDEF ser_dev_write
	XDEF ser_dev_stat
	XDEF ser_dev_ioctl

	INCLUDE "..\kernel\inc\mgx_xfs.inc"

	TEXT


E_OK           EQU    0       ;   0     kein Fehler
ERROR          EQU   -1       ;  -1     allgemeiner Fehler
EDRVNR         EQU   -2       ;  -2     Laufwerk nicht bereit
EUNCMD         EQU   -3       ;  -3     unbekanntes Kommando
E_CRC          EQU   -4       ;  -4     PrÅfsummenfehler
EBADRQ         EQU   -5       ;  -5     Kommando nicht mîglich
E_SEEK         EQU   -6       ;  -6     Spur nicht gefunden
EMEDIA         EQU   -7       ;  -7     unbekanntes Medium
ESECNF         EQU   -8       ;  -8     Sektor nicht gefunden
EPAPER         EQU   -9       ;  -9     kein Papier mehr
EWRITF         EQU  -10       ; -$A     Schreibfehler
EREADF         EQU  -11       ; -$B     Lesefehler
EWRPRO         EQU  -13       ; -$D     Schreibschutz
E_CHNG         EQU  -14       ; -$E     unerlaubter Diskwechsel
EUNDEV         EQU  -15       ; -$F     unbekanntes GerÑt
EBADSF         EQU  -16       ; -$10    Verify- Fehler
EOTHER         EQU  -17       ; -$11    Disk wechseln (A<->B)

EINVFN         EQU  -32       ; -$20    ungÅltige Funktionsnummer
EFILNF         EQU  -33       ; -$21    Datei nicht gefunden
EPTHNF         EQU  -34       ; -$22    Pfad nicht gefunden
ENHNDL         EQU  -35       ; -$23    keine Handles mehr
EACCDN         EQU  -36       ; -$24    Zugriff nicht mîglich
EIHNDL         EQU  -37       ; -$25    ungÅltiges Handle
ENSMEM         EQU  -39       ; -$27    zuwenig Speicher
EIMBA          EQU  -40       ; -$28    ungÅltiger Speicherblock
EDRIVE         EQU  -46       ; -$2E    ungÅltiges Laufwerk
ENSAME         EQU  -48       ; -$30    nicht dasselbe Laufwerk
ENMFIL         EQU  -49       ; -$31    keine weiteren Dateien
ELOCKED        EQU  -58       ;          MiNT: GerÑt blockiert
ENSLOCK        EQU  -59       ;          MiNT: Unlock- Fehler
ERANGE         EQU  -64       ; -$40    ung. Dateizeiger- Bereich
EINTRN         EQU  -65       ; -$41    interner Fehler
EPLFMT         EQU  -66       ; -$42    UngÅltiges Programmformat
EGSBF          EQU  -67       ; -$43    Speicherblock vergrîûert
EBREAK         EQU  -68       ; -$44    KAOS: mit CTRL-C abgebrochen
EXCPT          EQU  -69       ; -$45    KAOS: 68000- Exception


PTRLEN	EQU	4		; Zeiger auf Elementfunktion braucht 4 Zeiger

	OFFSET

;Atari -> Mac
MacSysX_magic:		DS.L 1		; ist 'MagC'
MacSysX_len:		DS.L	1		; LÑnge der Struktur
MacSysX_syshdr:	DS.L 1		; Adresse des Atari-Syshdr
MacSysX_keytabs:	DS.L 1		; 5*128 Bytes fÅr Tastaturtabellen
MacSysX_mem_root:	DS.L 1		; Speicherlisten
MacSysX_act_pd:	DS.L 1		; Zeiger auf aktuellen Prozeû
MacSysX_act_appl:	DS.L 1		; Zeiger auf aktuelle Task
MacSysX_verAtari:	DS.L 1		; Versionsnummer MagicMacX.OS
;Mac -> Atari
MacSysX_verMac:	DS.L	1		; Versionsnummer der Struktur
MacSysX_cpu:		DS.W 1		; CPU (30=68030, 40=68040)
MacSysX_fpu:		DS.W 1		; FPU (0=nix,4=68881,6=68882,8=68040)
MacSysX_init:		DS.L PTRLEN	; Wird beim Warmstart des Atari aufgerufen
MacSysX_biosinit:	DS.L PTRLEN	; nach Initialisierung aufrufen
MacSysX_VdiInit:	DS.L PTRLEN	; nach Initialisierung des VDI aufrufen
MacSysX_pixmap:	DS.L 1		; Daten fÅrs VDI
MacSysX_pMMXCookie:	DS.L	1		; 68k-Zeiger auf MgMx-Cookie
MacSysX_Xcmd:		DS.L PTRLEN	; XCMD-Kommandos
MacSysX_PPCAddr:	DS.L 1		; tats. PPC-Adresse von 68k-Adresse 0
MacSysX_VideoAddr:	DS.L	1		; tats. PPC-Adresse des Bildschirmspeichers
MacSysX_Exec68k:	DS.L	PTRLEN	; hier kann der PPC-Callback 68k-Code ausfÅhren
MacSysX_gettime:	DS.L 1		; LONG GetTime(void) Datum und Uhrzeit ermitteln
MacSysX_settime:	DS.L	1		; void SetTime(LONG *time) Datum/Zeit setzen
MacSysX_Setpalette:	DS.L	1		; void Setpalette( int ptr[16] )
MacSysX_Setcolor:	DS.L	1		; int Setcolor( int nr, int val )
MacSysX_VsetRGB:	DS.L	1		; void VsetRGB( WORD index, WORD count, LONG *array )
MacSysX_VgetRGB:	DS.L	1		; void VgetRGB( WORD index, WORD count, LONG *array )
MacSysX_syshalt:	DS.L 1		; SysHalt( char *str ) "System halted"
MacSysX_syserr:	DS.L 1		; SysErr( long val ) "a1 = 0 => Bomben"
MacSysX_coldboot:	DS.L 1		; ColdBoot(void) Kaltstart ausfÅhren
MacSysX_exit:	  	DS.L 1		; Exit(void) beenden
MacSysX_debugout:	DS.L 1		; MacPuts( char *str ) fÅrs Debugging
MacSysX_error: 	DS.L 1		; d0 = -1: kein Grafiktreiber
MacSysX_prtos: 	DS.L 1		; Bcostat(void) fÅr PRT
MacSysX_prtin: 	DS.L 1		; Cconin(void) fÅr PRT
MacSysX_prtout:	DS.L 1		; Cconout( void *params ) fÅr PRT
MacSysX_prn_wrts:	DS.L	1		; LONG PrnWrts({char *buf, LONG count}) String auf Drucker
MacSysX_serconf:	DS.L 1		; Rsconf( void *params ) fÅr ser1
MacSysX_seris: 	DS.L 1		; Bconstat(void) fÅr ser1 (AUX)
MacSysX_seros: 	DS.L 1		; Bcostat(void) fÅr ser1
MacSysX_serin: 	DS.L 1		; Cconin(void) fÅr ser1
MacSysX_serout:	DS.L 1		; Cconout( void *params ) fÅr ser1
MacSysX_SerOpen:	DS.L 1		; Serielle Schnittstelle îffnen
MacSysX_SerClose: 	DS.L 1		; Serielle Schnittstelle schlieûen
MacSysX_SerRead: 	DS.L 1		; Mehrere Zeichen von seriell lesen
MacSysX_SerWrite:	DS.L 1		; Mehrere Zeichen auf seriell schreiben
MacSysX_SerStat:	DS.L 1		; Lese-/Schreibstatus fÅr serielle Schnittstelle
MacSysX_SerIoctl:	DS.L 1		; Ioctl-Aufrufe fÅr serielle Schnittstelle
MacSysX_GetKbOrMous: DS.L PTRLEN	; Liefert Tastatur/Maus
MacSysX_dos_macfn:	DS.L	1		; DosFn({int,void*} *) DOS-Funktionen 0x60..0xfe
MacSysX_xfs_version: DS.L 1		; Version des Mac-XFS
MacSysX_xfs_flags:	DS.L	1		; Flags fÅr das Mac-XFS
MacSysX_xfs:		DS.L PTRLEN	; zentrale Routine fÅr das XFS
MacSysX_xfs_dev:	DS.L PTRLEN	; zugehîriger Dateitreiber
MacSysX_drv2devcode: DS.L PTRLEN	; umrechnen Laufwerk->Devicenummer
MacSysX_rawdrvr:	DS.L PTRLEN	; LONG RawDrvr({int, long} *) Raw-Driver (Eject) fÅr Mac
MacSys_OldHdr:		DS.L	49		; KompatibilitÑt mit Behnes
MacSysX_sizeof:

	TEXT

; Prozedur aufrufen. a0 auf Zeiger, a1 ist Parameter.

MACRO	MACPPC
		DC.W $00c0
		ENDM

; Elementfunktion aufrufen. a0 auf 4 Zeiger, a1 ist Parameter

MACRO	MACPPCE
		DC.W $00c1
		ENDM


/******************************************************************
*
* îffnen:
* long _ser_dev_open( void );
*
******************************************************************/

_ser_dev_open:
 move.l	pSysX,a2
 lea		MacSysX_SerOpen(a2),a0
 MACPPC
 rts


/******************************************************************
*
* schlieûen:
* long _lpt_dev_close( void );
*
******************************************************************/

_ser_dev_close:
 move.l	pSysX,a2
 lea		MacSysX_SerClose(a2),a0
 MACPPC
 rts


/******************************************************************
*
* lesen:
* long ser_dev_read(a0 = MX_DOSFD *f, a1 = void *buf, d0 = long len);
*
******************************************************************/

ser_dev_read:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 lea		(sp),a1				; öbergabeparameter
 move.l	pSysX,a2
 lea		MacSysX_SerRead(a2),a0
 MACPPC
 addq.l	#8,sp
 rts


/******************************************************************
*
* schreiben:
* long lpt_dev_write(MX_DOSFD *f, void *buf, long len);
*
******************************************************************/

ser_dev_write:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 lea		(sp),a1				; öbergabeparameter
 move.l	pSysX,a2
 lea		MacSysX_SerWrite(a2),a0
 MACPPC
 addq.l	#8,sp
 rts


/******************************************************************
*
* Status:
* long lpt_dev_stat(a0 = MAGX_FD *f, d0 = int rwflag, a1 = void *unsel, d1 = long apcode)
*
******************************************************************/

ser_dev_stat:
 move.l	a1,-(sp)					; unsel merken
 move.w	d0,-(sp)					; rwmode
 lea		(sp),a1					; Parameter
 move.l	pSysX,a2
 lea		MacSysX_SerStat(a2),a0
 MACPPC
 addq.l	#2,sp
 moveq	#1,d1
 and.l	d1,d0					; auf 0 oder 1 normieren
 move.l	(sp)+,d1
 beq.b	bms_ok
 move.l	d1,a1
 move.l	d0,(a1)					; nicht interruptfÑhig
bms_ok:
 rts


/******************************************************************
*
* Ioctl:
* long ser_dev_ioctl(a0 = MX_DOSFD *f, d0 = int cmd, a1 = void *buf);
*
******************************************************************/

ser_dev_ioctl:
 move.l	a1,-(sp)
 move.w	d0,-(sp)
 lea		(sp),a1				; öbergabeparameter
 move.l	pSysX,a2
 lea		MacSysX_SerIoctl(a2),a0
 MACPPC
 addq.l	#6,sp
 rts
