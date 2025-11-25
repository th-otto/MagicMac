**********************************************************************
*
* Dieses Modul enthaelt die Dateitreiber fuer DOS- Dateien
* (fuer 32Bit Sektornummern und FAT32)
* Das Wurzelverzeichnis muss sich bei FAT16 aber noch in den ersten
* 65535 Sektoren befinden (ist immer so wg. b_datrec < 65536).
*
* Es gibt dabei zwei DOS- Dateitypen:
*
* - normale Dateien und Unterverzeichnisse
* - Das Wurzelverzeichnis (nur fuer FAT12 und FAT16)
*


DEBUG     EQU  8
NOWRITE   EQU  0

     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "structs.inc"
     INCLUDE "debug.inc"
     INCLUDE "magicdos.inc"

     SUPER


SECBUFSIZE     EQU  512       ; zunaechst 2048 Bytes reservieren
SECBUFN1       EQU  2         ; 2 Sektoren fuer FAT puffern
SECBUFN2       EQU  2         ; 2 Sektoren fuer Daten puffern



     XDEF dfs_fat_drv
     XDEF dosf_drv
     XDEF secb_ext
     XDEF ncopy_from


     XREF config_status       ; von BIOS
     XREF Bmalloc             ; vom BIOS

     XREF diskchange
     XREF _dir_srch
     XREF reopen_FD
     XREF close_DD
     XREF int_malloc,int_pmalloc
     XREF filename_match
     XREF init_DTA
     XREF DMD_rdevinit

* von MAGIDOS

     XREF getxhdi

     XREF str_to_con
     XREF resv_intmem,resvb_intmem,int_mblocks

* from AES

     XREF act_appl

* von MATH

     XREF _ulmul

     IF   DEBUG
     XREF hexl
     XREF crlf
     ENDIF


     OFFSET
* FAT Bootsektor
* Quelle: Hardware White Paper Version 1.02, 5.5.1999, Microsoft
bs_jump:       DS.B      3    /* x86 langer oder kurzer Sprung auf Bootcode */
                              /* 0xeb,0x??,0x90 oder 0xe9,0x??,0x?? */
bs_system_id:  DS.B      8    /* Systemname, sollte "MSWIN4.1" sein */
bs_sec_size:   DS.B      2    /* Bytes pro Sektor. */
                              /* M$ erlaubt hier 512,1024,2048 oder 4096, empfiehlt aber 512 */
bs_clu_size:   DS.B      1    /* Sektoren pro Cluster. M$ erlaubt jede */
                              /* 2er-Potenz von 1 bis 128 und empfiehlt dringend Bytes/Cluster <= 32kB */
bs_sec_resvd:  DS.W      1    /* Anzahl reservierter Sektoren ab Partitionsanfang, */
                              /* darf nicht Null sein (Bootsektor!). Bei FAT12 und FAT16 */
                              /* sollte der Wert 1 sein, fuer FAT32 32 */
bs_nfats:      DS.B      1    /* Anzahl FATs. M$ empfiehlt 2 */
bs_dir_entr:   DS.B      2    /* Anzahl Eintraege (a 32 Bytes) fuer root, 0 bei FAT32 */
bs_nsectors:   DS.B      2    /* Anzahl Sektoren (reserviert+FAT+root+Data) bzw. 0, wenn > 65535 */
bs_media:      DS.B      1    /* "media code": 0xf8 fuer Harddisk, 0xf0 fuer Wechselmedium */
                              /* der Wert muss im Lowbyte von FAT[0] stehen */
bs_fatlen:     DS.W      1    /* Sektoren fuer eine FAT. 0 fuer FAT32 (daran wird FAT32 erkannt) */
bs_secs_track: DS.W      1    /* Sektoren pro Spur (nur historisch oder Floppy) */
bs_heads:      DS.W      1    /* Anzahl Koepfe (historisch oder Floppy) */
bs_hidden:     DS.L      1    /* Anzahl versteckter Sektoren VOR der Partition (normalerweise 0) */
bs_total_sect: DS.L      1    /* Anzahl Sektoren (reserviert+FAT+root+Data), wenn bs_nsectors == 0 oder bei FAT32 */

; Ab hier unterscheiden sich FAT12/16 und FAT32
; Hier die Felder fuer FAT32:

bs_fatlen32:   DS.L      1    /* Anzahl Sektoren fuer eine FAT, wenn bs_fatlen == 0 */
bs_flags:      DS.W      1    /* Bit 0..3: aktive FAT, wenn Bit 7 == 1 */
                              /* Bit 4..6: reserviert */
                              /* Bit 7: 0 fuer "FAT-Spiegelung", 1 fuer "nur eine aktive FAT" */
                              /* Bit 8..15: reserviert */
bs_version:    DS.B      2    /* Hi: major filesystem version, Lo: minor */
                              /* zur Zeit 0.0. Ein Treiber sollte neuere Versionen verweigern */
bs_rootclust:  DS.L      1    /* Erster Cluster des Wurzelverzeichnisses, sollte */
                              /* normalerweise 2 sein */
bs_info_sect:  DS.W      1    /* Sektornummer des Info-Sektors (im reservierten Bereich) */
                              /* normalerweise 1 (direkt hinter dem Bootsektor) */
bs_bckup_boot: DS.W      1    /* Sektornummer des Backup-Bootsektors (im reservierten Bereich) */
                              /* sollte 0 sein (unbenutzt) oder 6 */
                              /* Hinter dem Backup-Bootsektor liegt das Backup-FSInfo */
bs_RESERVED2:  DS.B      12   /* reserviert, sollte 0 sein */
bs_DrvNum:     DS.B      1    /* "drive number". 0x00 == floppy, 0x80 == HD */
bs_Reserved1:  DS.B      1    /* fuer Windows NT reserviert, sollte 0 sein */
bs_BootSig:    DS.B      1    /* 0x29 legt fest, dass die folgenden drei Felder gueltig sind */
bs_VolID:      DS.B      4    /* Seriennummer, die mit bs_VolLab zusammen zur Medienwechselerkennung verwendet wird */
                              /* ist i.a. Datum+Uhrzeit der Formatierung kombiniert */
bs_VolLab:     DS.B      11   /* muss mit dem Disknamen im Wurzelverzeichnis identisch sein. */
                              /* Ist "NO NAME    ", wenn das Medium unbenannt ist
bs_FilSysType: DS.B      8    /* "FAT32   ". Darf aber nicht zur Bestimmung des Typs verwendet werden */

; Noch wichtig: sector[510] == 0x55, sector[511] == 0xaa
; M$ bestimmt den FAT-Typ aus der Anzahl der Cluster:
; nClusters < 4085 => FAT12
; 4085 <= nClusters < 65525 => FAT16
; 65525 <= nClusters => FAT32

; EOC (end of cluster chain) Clusternummern:
; FAT12: clnum >= 0x0ff8
; FAT16: clnum >= 0xfff8
; FAT32: clnum >= 0x0ffffff8 (eigentlich FAT28)
; beim Setzen von EOC sollte jeweils die Endziffer 0xf verwendet werden

; BAD CLUSTER:
; FAT12: 0x0ff7
; FAT16: 0xfff7
; FAT32: 0x0ffffff7

; FAT[0] enthaelt im LowByte das BPB_Media Byte, alle anderen Bits sind 1
; FAT[1] wird als EOC gesetzt, wobei bei FAT16 und FAT32 die oberen
; 2 Bits als "dirty volume" verwendet werden duerfen, alle anderen Bits sind 1:

FAT16_ClnShutBitMask     EQU  $8000          ; 1 = clean, 0 = dirty
FAT16_HrdErrBitMask      EQU  $4000          ; 1 = OK, 0 = I/O Fehler
FAT32_ClnShutBitMask     EQU  $80000000
FAT32_HrdErrBitMask      EQU  $40000000



FAT32_FSINFOLEADSIG EQU $52526141  ; 68k-Format
FAT32_FSINFOSTRSIG  EQU $72724161  ; 68k-Format
FAT32_FSINFOTRLSIG  EQU $000055aa  ; 68k-Format

     OFFSET
* FAT32 Info-Sektor (FSInfo-Struktur), drei 512-Byte-Sektoren

FSI_LeadSig:        DS.L      1    /* 0x41615252, wenn gueltig */
FSI_Reserved1:      DS.B      480  /* unbenutzt und 0 */
FSI_StrucSig:       DS.L      1    /* 0x61417272, wenn folgende gueltig */
FSI_Free_Count:     DS.L      1    /* Anzahl freier Cluster oder -1, wenn unbekannt */
FSI_Nxt_Free:       DS.L      1    /* Ab hier freie Cluster suchen oder -1, wenn unbekannt */
FSI_Reserved2:      DS.B      12   /* unbenutzt und 0 */
FSI_TrailSig:       DS.L      1    /* 0xaa550000, wenn gueltig, fuer alle 3 Info-Sektoren */

; falsche alte Info:
;FAT32_FSINFOSIG    EQU $72724161  ; 'aArr'
;is_reserved1:      DS.L      1    /* Nothing as far as I can tell */
;is_signature:      DS.L      1    /* 0x61417272L (Intel-Format!) */
;is_free_clusters:  DS.L      1    /* Free cluster count.  -1 if unknown */
;is_next_cluster:   DS.L      1    /* Most recently allocated cluster. Unused under Linux. */
;is_reserved2:      DS.L      4

/* avoid root dir fragmentation */
FAT32_ROFF equ 32

     OFFSET
* BCB
b_link:        DS.L      1    /* 0x00: Zeiger auf naechsten BCB            */
b_bufdrv:      DS.W      1    /* 0x04: Laufwerknummer, -1 fuer ungueltig   */
b_buftyp:      DS.W      1    /* 0x06: FAT=0, DIR=1, DATA=2                */
b_bufrec:      DS.W      1    /* 0x08: Sektornummer (GEMDOS- Code)         */
b_dirty:       DS.W      1    /* 0x0a: Pufferinhalt geaendert              */
b_dmd:         DS.L      1    /* 0x0c: Zeiger auf DMD von b_bufdrv         */
b_bufr:        DS.L      1    /* 0x10: Zeiger auf Sektorpuffer             */

     OFFSET

xb_next:       DS.L      1    /* 0x00: Zeiger auf naechsten XBCB           */
xb_prev:       DS.L      1    /* 0x04: Zeiger auf vorherigen XBCB          */
xb_first:      DS.L      1    /* 0x08: Zeiger auf den Anfang der Liste     */
xb_drv:        DS.W      1    /* 0x0c: Laufwerknummer, -1 fuer ungueltig   */
xb_dirty:      DS.W      1    /* 0x0e: Pufferinhalt geaendert              */
xb_secno:      DS.L      1    /* 0x10: Sektornummer (BIOS- Code)           */
xb_secno2:     DS.L      1    /* 0x14: Kopie (z.B. FAT #1) oder 0          */
xb_dmd:        DS.L      1    /* 0x18: Zeiger auf DMD von b_bufdrv         */
xb_data:       DS.L      1    /* 0x1c: Zeiger auf Sektorpuffer             */
xb_sem:        DS.B bl_sizeof /* 0x20: Veraenderungs- Semaphore            */
xb_sizeof:

*
* BiosParameterBlock
*

     OFFSET

b_recsiz:      DS.W      1    /* 0x00: Bytes/Sektor                        */
b_clsiz:       DS.W      1    /* 0x02: Sektoren/Cluster                    */
b_clsizb:      DS.W      1    /* 0x04: Bytes pro Cluster                   */
b_rdlen:       DS.W      1    /* 0x06: Sektoren fuer Root                  */
b_fsiz:        DS.W      1    /* 0x08: Sektoren pro FAT                    */
b_fatrec:      DS.W      1    /* 0x0a: Sektornr. der 2. FAT                */
b_datrec:      DS.W      1    /* 0x0c: Sektornr. des 1. Datenclusters      */
b_numcl:       DS.W      1    /* 0x0e: Anzahl Datencluster                 */
b_flags:       DS.W      8    /* 0x10: Bit 0/Flag 0 = FAT- Typ             */

*
* XtendedBiosParameterBlock
*

     OFFSET

bx_recsiz:     DS.W      1    /* Bytes/Sektor                         */
bx_clsiz:      DS.W      1    /* Sektoren/Cluster                     */
bx_clsizb:     DS.W      1    /* Bytes pro Cluster                    */
bx_rdlen:      DS.W      1    /* FAT12/16: Sektoren fuer Root         */
bx_rdclust:    DS.L      1    /* FAT32: Startcluster fuer Root        */
bx_fsiz:       DS.L      1    /* Sektoren pro FAT                     */
bx_fat1rec:    DS.L      1    /* Sektornr. der 1. FAT                 */
bx_fatrec:     DS.L      1    /* Sektornr. der aktiven (i.a.) 2. FAT  */
bx_datrec:     DS.L      1    /* Sektornr. des 1. Datenclusters       */
bx_numcl:      DS.L      1    /* Anzahl Datencluster                  */
bx_ftype:      DS.B      1    /* 0 = FAT12 1 = FAT16 -1 = FAT32       */
bx_nfats:      DS.B      1    /* Anzahl der FATs, liegen vor aktiver  */
bx_infosec:    DS.L      1    /* Info-Sektor, wenn F32 */
bx_sizeof:

     OFFSET

pun_puns:      DS.W      1    /* 0x00: Anzahl physikalischer Einheiten     */
pun_pun:       DS.B      16   /* 0x02: Zuordnung log->phys.                */
pun_pstart:    DS.L      16   /* 0x12: Physikalischer Partitionsanfang     */
pun_cookie:    DS.L      1    /* 0x52: z.B. 'AHDI'                         */
pun_cookiep:   DS.L      1    /* 0x56: Zeiger auf den Cookie               */
pun_version:   DS.W      1    /* 0x5a: Versionsnummer                      */
pun_msectsize: DS.W      1    /* 0x5e: Groesse der installierten Puffer    */

     TEXT

_bufl          EQU  $4b2
_drvbits       EQU  $4c2
pun_ptr        EQU  $516


dosf_drv:
 DC.L     dosf_open
 DC.L     dosf_close          ; immer Puffer zurueckschreiben
 DC.L     dosf_read
 DC.L     dosf_write
 DC.L     dosf_stat
 DC.L     dosf_seek
 DC.L     0                   ; normales Fdatime()
 DC.L     dosf_ioctl
 DC.L     dosf_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc

dosroot_drv:
 DC.L     dosroot_open
 DC.L     dosf_close          ; immer Puffer zurueckschreiben
 DC.L     dosroot_read
 DC.L     dosroot_write
 DC.L     0                   ; kein stat
 DC.L     dosroot_seek
 DC.L     0                   ; normales Fdatime()
 DC.L     0                   ; kein ioctl
 DC.L     0                   ; kein delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc


dfs_fat_drv:
 DC.B     'DFS_FAT '          ; 8 Bytes fuer den Namen
 DC.L     0                   ; naechster Treiber
 DC.L     dosfs_init          ; Initialisierung
 DC.L     dfs_fat_sync        ; Synchronisation
 DC.L     drv_open            ; neues Laufwerk
 DC.L     drv_close           ; Laufwerk freigeben
 DC.L     dosfs_dfree         ; Fuer Dfree()
 DC.L     dosf_sfirst
 DC.L     dosf_snext
 DC.L     dfs_fat_ext_fd      ; erweitere Verzeichnis
 DC.L     dfs_fat_fcreate     ; erstelle Datei
 DC.L     dfs_fat_fxattr      ; XATTR
 DC.L     dfs_fat_dir2index   ; Dreaddir
 DC.L     dfs_fat_readlink    ; Freadlink
 DC.L     dfs_fat_dir2FD
 DC.L     dfs_fat_fdelete
 DC.L     dfs_fat_pathconf


**********************************************************************
*
* void dosfs_init( void )
*
* initialisiert die Sektorpuffer
* Die Speicherverwaltung ist noch nicht initialisiert, deshalb darf
* Bmalloc verwendet werden.
*

;init: DC.B    'FAT32-DFS installiert.',$d,$a,0
;    EVEN

dosfs_init:
;     DEB  'Initialize DFS_FAT'
 movem.l  a6/d7/d6,-(sp)

; lea          init(pc),a0
; jsr          str_to_con

 clr.l    _bufl
 clr.l    _bufl+4                       ; TOS- Listen werden nicht verwendet
 move.l   #SECBUFSIZE,bufl_size.w       ; Groesse der installierten Puffer
 lea      bufl.w,a6
 moveq    #SECBUFN1-1,d7
di_nxtl:
 clr.l    (a6)
di_nxtb:
 moveq    #xb_sizeof,d0                 ; Laenge eines XBCB
 add.l    bufl_size.w,d0                ; Laenge eines Sektors
 jsr      Bmalloc                       ; Speicher vom BIOS holen

 move.l   a6,a2                         ; Liste
 lea      xb_sizeof(a0),a1              ; Sektorpuffer
;move.l   a0,a0                         ; XBCB
 bsr      install_secbuf                ; initialisieren & in Liste eintragen
 dbra     d7,di_nxtb

 addq.l   #4,a6                         ; naechste Liste
 moveq    #SECBUFN2-1,d7
 cmpa.l   #(bufl+4),a6
 bls.b    di_nxtl
 movem.l  (sp)+,a6/d7/d6
 rts


**********************************************************************
*
* void ncopy_to(d0 = int n, a0 = char *dest, a1 = char *source)
* kopiert n Bytes
*

ncopy_to:
 exg      a0,a1

**********************************************************************
*
* void ncopy_from(d0 = int n, a0 = char *source, a1 = char *dest)
* kopiert n Bytes
*
* aendert nicht a2
*

ncopy_from:
 btst     #0,d0
 bne.b    ncf_odd
 move.w   a0,d1
 move.w   a1,d2
 or.w     d2,d1
 btst     #0,d1
 bne.b    ncf_odd
 move.w   d0,d1
 asr.w    #2,d1
 bra.b    ncf_long_next
ncf_long_loop:
 move.l   (a0)+,(a1)+
ncf_long_next:
 dbf      d1,ncf_long_loop
 and.w    #3,d0
 beq.b    ncf_end
 move.w   (a0)+,(a1)+
ncf_end:
 rts
ncf_oddloop:
 move.b   (a0)+,(a1)+
ncf_odd:
 dbf      d0,ncf_oddloop
 rts


**********************************************************************
*
* void dfs_fat_sync( a0 = DMD *d )
*
* Schreibt alle Puffer zurueck, die dem Laufwerk <d_drive(a0)> gehoeren
*

dfs_fat_sync:
 movem.l  d7/a3/a4,-(sp)
 jsr      appl_begcritic           ; aendert nur d2/a2

 move.w   d_drive(a0),d7
 lea      (bufl+4).w,a3
sync_nxtlst:

* a4 = BCB

 move.l   (a3),a4
 bra.b    sync_nxt

* b_dirty == TRUE ?

sync_nxtbcb:
 cmp.w    xb_drv(a4),d7
 bne.b    sync_nowr
 tst.w    xb_dirty(a4)
 beq.b    sync_nowr

* Nur zurueckschreiben, wenn geaendert

 move.l   a4,a0
 bsr      write_sector
 bmi      sync_err
sync_nowr:
 move.l   xb_next(a4),a4
sync_nxt:
 move.l   a4,d0
 bne.b    sync_nxtbcb
 subq.l   #4,a3
 cmpa.l   #bufl,a3
 bcc.b    sync_nxtlst

 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,d7/a3/a4
 rts
sync_err:
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,d7/a3/a4
 bra      fatfs_diskerr


*********************************************************************
*
* BPB *check_xbpb( a0 = XBPB *b )
*
* Ueberpruefung der FAT-Laenge.
* Aendert nicht a0,a2
*

check_xbpb:
 cmpi.b   #2,bx_nfats(a0)          ; nur Zeit nur max. 2 FATs erlaubt
 bhi.b    cbpb_err
 move.l   bx_fsiz(a0),d0
 moveq    #0,d1
 move.w   bx_recsiz(a0),d1
 jsr      _ulmul                   ; Berechne Laenge der FAT in Bytes
cbpb_loop:
 move.l   bx_numcl(a0),d1
 beq.b    cbpb_err                 ; keine Cluster ?
 addq.l   #1,d1                    ; letzte Clusternummer
 move.l   d1,d2
 tst.b    bx_ftype(a0)             ; 16-Bit FAT ?
 bne.b    cbpb_f16                 ; ja
 lsr.l    #1,d1                    ; * 0,5
cbpb_f16:
 add.l    d1,d2                    ; Byte-Offset in FAT
 cmp.l    d0,d2                    ; < FAT-Laenge
 bcs.b    cbpb_ok                  ; ja, in Ordnung
 subq.l   #2,bx_numcl(a0)
 bcc.b    cbpb_loop
cbpb_err:
 moveq    #EDRIVE,d0               ; Fehler, FAT zu kurz
 rts
cbpb_ok:
 moveq    #0,d0                    ; OK
 rts


*********************************************************************
*
* EQ/MI d0/a0/a1 = char *rd_fsinfo( a0 = DMD *d )
*
* Liest den FSINFO-Sektor ein (falls vorhanden)
* Rueckgabe:    NULL      nicht vorhanden oder ungueltig
*              < 0       Fehler
*              > 0       Zeiger auf Sektor, a0 = XBCB *
*

rd_fsinfo:
 move.l   d_infosec(a0),d0         ; secnr
 beq.b    rdfsi_ende               ; kein FSINFO-Sektor
 move.l   a0,a1
; Sektor einlesen, noch nicht zum Aendern markieren
 clr.w    -(sp)                    ; will nur lesen
 lea      (bufl+4).w,a0            ; Tabelle fuer Datensektoren
 moveq    #0,d2                    ; kein Spiegelsektor
 move.l   d0,d1                    ; secnr
 move.w   d_drive(a1),d0
 bsr      read_sector
 addq.l   #2,sp
 bmi.b    rdfsi_ende               ; Lesefehler
; testen, ob die Daten schon ungueltig sind
 move.l   d0,a1                    ; a1 = Sektorpuffer
 cmpi.l   #FAT32_FSINFOLEADSIG,FSI_LeadSig(a1)
 bne.b    rdfsi_inval
 cmpi.l   #FAT32_FSINFOSTRSIG,FSI_StrucSig(a1)
 bne.b    rdfsi_inval
 cmpi.l   #FAT32_FSINFOTRLSIG,FSI_TrailSig(a1)
 bne.b    rdfsi_inval
;move.l   a0,a0                    ; XBCB *
 move.l   a1,d0                    ; gueltig
 rts
rdfsi_inval:
 moveq    #0,d0                    ; ungueltig
rdfsi_ende:
 rts


*********************************************************************
*
* LONG set_disk_dirty( a0 = DMD *d )
*
* Macht vor einem Schreibzugriff auf die FAT die Daten im Info-
* Sektor (F32) ungueltig.
*

set_disk_dirty:
 tst.b    d_dirty(a0)              ; schon "dirty" ?
 bne.b    sdd_ok                   ; ja, Ende
 move.l   a5,-(sp)
 move.l   a0,a5
; Sektor einlesen, noch nicht zum Aendern markieren
;move.l   a0,a0                    ; DMD
 bsr      rd_fsinfo
 beq.b    sdd_ok2                  ; ungueltig
 bmi.b    sdd_ende                 ; Fehler
 moveq    #-1,d0
 cmp.l    FSI_Free_Count(a1),d0
 bne.b    sdd_set
 cmp.l    FSI_Nxt_Free(a1),d0
 beq.b    sdd_ok2
; Sektor aendern (nicht verzoegert)
sdd_set:
 move.l   d0,FSI_Free_Count(a1)
 move.l   d0,FSI_Nxt_Free(a1)
 move.w   #1,xb_dirty(a0)          ; Puffer als geaendert markieren
;move.l   a0,a0                    ; XBCB
 bsr      write_sector
 bmi.b    sdd_ende
sdd_ok2:
 st.b     d_dirty(a5)              ; erledigt
 moveq    #E_OK,d0                 ; kein Fehler
sdd_ende:
 move.l   (sp)+,a5
 rts
sdd_ok:
 moveq    #0,d0
 rts


*********************************************************************
*
* LONG set_disk_clean( a0 = DMD *d )
*
* Macht vor einem "unmount" die Daten im Info-Sektor (F32) gueltig.
*

set_disk_clean:
 tst.b    d_dirty(a0)              ; schon "dirty" ?
 beq.b    sdc_ok                   ; nein, Ende
 move.l   a5,-(sp)
 move.l   a0,a5
; Sektor einlesen, noch nicht zum Aendern markieren
;move.l   a0,a0                    ; DMD
 bsr      rd_fsinfo
 beq.b    sdc_ok2                  ; ungueltig
 bmi.b    sdc_ende                 ; Fehler

 move.l   d_nfree_cl(a5),d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 move.l   d0,FSI_Free_Count(a1)
 moveq    #FAT32_ROFF,d1           ; minimale Cluster-Nummer ist 32
 move.l   d_1stfree_cl(a5),d0      ; erster freier Cluster
 cmp.l    d1,d0                    ; d0 >= 32?
 bcc.b    sdc_putnf                ; ja, Cluster-Nummer ist gueltig
 move.l   d1,d0                    ; nein, nimm 32 als Minimum
sdc_putnf:
 move.l   d_numcl(a5),d1           ; Anzahl Cluster
 cmp.l    d1,d0                    ; d0 >= Anzahl Cluster
 bcs.s    sdc_putnf2               ; nein, ist gueltig
 moveq    #FAT32_ROFF,d0           ; Nummer ist ungueltig, nimm 32

sdc_putnf2:
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0                    ; -> little-endian
 move.l   d0,FSI_Nxt_Free(a1)      ; im Sektor speichern
; Sektor aendern (nicht verzoegert)
 move.w   #1,xb_dirty(a0)          ; Puffer als geaendert markieren
;move.l   a0,a0                    ; XBCB
 bsr      write_sector
 bmi.b    sdc_ende
sdc_ok2:
 sf.b     d_dirty(a5)              ; erledigt
 moveq    #E_OK,d0                 ; kein Fehler
sdc_ende:
 move.l   (sp)+,a5
 rts
sdc_ok:
 moveq    #0,d0
 rts


*********************************************************************
*
* LONG getxbpb( d0 = WORD bios_drv, a0 = XBPB *xbpb )
*
* Versucht, ein FAT-Laufwerk zu erkennen. Dazu wird erst Getbpb()
* aufgerufen (Test auf FAT12 und FAT16). Falls das nicht geht, wird
* der Bootsektor gelesen und auf FAT32 getestet.
*

getxbpb:
 movem.l  d6/d7/a5/a6,-(sp)
 subq.l   #8,sp
 move.l   a0,a6                    ; a6 = XBPB *
 move.w   d0,d7                    ; d7 = drv

 move.w   d7,-(sp)
 move.w   #7,-(sp)
 trap     #$d                      ; BIOS Getbpb()
 addq.w   #4,sp
 tst.l    d0
 bne      gxb_bpb                  ; BIOS kennt es => FAT12 oder FAT16

* XHDI ermitteln. Version muss >= 1.10 sein.

 move.l   #512,d6                  ; Default-Sektorgroesse 512 Bytes

 jsr      getxhdi                  ; Prueft schon Version >= $110
 beq.b    gxb_no_xhdi
 move.l   d0,a5                    ; a5 = XHDI *

* Partition-ID pruefen

 lea      (sp),a0
 pea      (a0)                     ; partID
 clr.l    -(sp)                    ; nblocks
 clr.l    -(sp)                    ; bpb
 clr.l    -(sp)                    ; startsector
 pea      6(a0)                    ; minor
 pea      4(a0)                    ; major
 move.w   d7,-(sp)                 ; bios_dev
 move.w   #12,-(sp)                ; XHInqDev2
 jsr      (a5)
 adda.w   #28,sp
 tst.l    d0
 bne      gxb_edrive

 cmpi.l   #$46333200,(sp)          ; Atari-Partition F32
 beq.b    gxb_part_ok
 cmpi.l   #$00440b00,(sp)          ; DOS-Partition
 bne      gxb_edrive
gxb_part_ok:

* Sektorgroesse ermitteln

 lea      (sp),a0
 clr.w    -(sp)                    ; string len
 clr.l    -(sp)                    ; product name
 clr.l    -(sp)                    ; device flags
 pea      (a0)                     ; blocksize
 move.l   4(a0),-(sp)              ; major/minor
 move.w   #11,-(sp)                ; XHInqTarget2
 jsr      (a5)
 adda.w   #20,sp
 tst.l    d0
 bne      gxb_edrive
 move.l   (sp),d6                  ; d6 = Sektorgroesse

* Bootsektor einlesen

gxb_no_xhdi:
 suba.l   d6,sp

 move.l   sp,a0

 clr.l    -(sp)                    ; lrecno
 move.w   d7,-(sp)                 ; dev
 move.w   #-1,-(sp)                ; recno
 move.w   #1,-(sp)                 ; cnt
 move.l   a0,-(sp)                 ; buf
 clr.w    -(sp)                    ; rwflag
 move.w   #4,-(sp)
 trap     #$d                      ; BIOS Rwabs()
 adda.w   #18,sp
 tst.l    d0
 bne      gxb_ende2

* Bootsektor umwandeln

 move.l   a6,a0
 move.b   bs_sec_size+1(sp),d1
 lsl.w    #8,d1
 move.b   bs_sec_size(sp),d1
 move.w   d1,(a0)+                 ; bx_recsiz (Bytes pro Sektor)
 ble      gxb_edrive2

 moveq    #0,d0
 move.b   bs_clu_size(sp),d0       ; d0 = Sektoren pro Cluster
 ble      gxb_edrive2
 move.w   d0,(a0)+                 ; bx_clsiz (Sektoren pro Cluster)
 mulu     d1,d0
 move.w   d0,(a0)+                 ; bx_clsizb (Bytes pro Cluster)

 tst.b    bs_dir_entr(sp)          ; FAT32!
 bne      gxb_edrive2
 tst.b    bs_dir_entr+1(sp)        ; FAT32!
 bne      gxb_edrive2
 move.w   bs_version(sp),d0        ; FAT32-Version
 bne      gxb_edrive2              ; Version zu neu!
 clr.w    (a0)+                    ; bx_rdlen = 0

 move.l   bs_rootclust(sp),d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 move.l   d0,(a0)+                 ; bx_rdclust
 subq.l   #2,d0
 bcs      gxb_edrive2

 moveq    #0,d0
 move.w   bs_fatlen(sp),d0
 bne.b    gxb_fatw
 move.l   bs_fatlen32(sp),d0
 ror.w    #8,d0
 swap     d0
gxb_fatw:
 ror.w    #8,d0
 move.l   d0,(a0)+                 ; bx_fsiz (Sektoren pro FAT)

 moveq    #0,d1
 move.w   bs_sec_resvd(sp),d1      ; alle Sekt. vor der 1. FAT sind reserviert
 ror.w    #8,d1
 move.l   d1,(a0)+                 ; bx_fat1rec (Beginn der 1. FAT)
 move.l   d1,a2                    ; a2 := Beginn der 1. FAT

 moveq    #0,d1
 move.b   bs_nfats(sp),d1          ; Anzahl FATs
 move.w   d1,d2
 subq.w   #1,d2                    ; Nummer der akt. FAT: letzte
 bcs.b    gxb_edrive2
 bra.b    gxb_enfdloop
gxb_fdloop:
 add.l    d0,a2
gxb_enfdloop:
 dbra     d2,gxb_fdloop
 move.l   a2,(a0)+                 ; bx_fatrec (akt. FAT)

 add.l    d0,a2                    ; + bx_fsiz   (Laenge der 2. FAT)
 move.l   a2,(a0)+                 ; bx_datrec (Anfang des Datenbereichs)

 move.w   bx_clsiz(a6),d0
 bsr      ilog2                    ; Sektoren/Cluster
;moveq    #1,d1
;lsl.w    d0,d1
;cmp.w    bx_clsiz(a6),d1
;bne.b    gxb_edrive2              ; Sektoren/Cluster ist keine 2er-Potenz

 moveq    #0,d1
 move.b   bs_nsectors+1(sp),d1
 lsl.w    #8,d1
 move.b   bs_nsectors(sp),d1
 tst.l    d1
 bne.b    gxb_nsecw
 move.l   bs_total_sect(sp),d1     ; Anzahl Sektoren gesamt
 ror.w    #8,d1
 swap     d1
 ror.w    #8,d1
gxb_nsecw:
 sub.l    bx_datrec(a6),d1         ; - bx_datrec
 lsr.l    d0,d1                    ; / bx_clsiz
 move.l   d1,(a0)+                 ; = bx_numcl

 st.b     (a0)+                    ; bx_ftype = -1 (FAT32)

 move.b   bs_nfats(sp),(a0)        ; bx_nfats (Anzahl FATs)

; Sonderbehandlung fuer abgeschaltete FAT-Spiegelung

 move.b   bs_flags(sp),d0          ; Low-Word (intel!)
 btst.b   #7,d0
 beq.b    gxb_fatmirror_normal
 andi.l   #$0000000f,d0            ; d0 = aktive FAT
 cmp.b    (a0),d0
 bcc.b    gxb_edrive2              ; aktive FAT >= Anzahl FATs (?!?)
 move.b   #1,(a0)                  ; nur eine aktive FAT!
 move.l   bx_fsiz(a6),d1           ; Sektoren pro FAT
 jsr      _ulmul                   ; aendert nicht a0
 add.l    bx_fat1rec(a6),d0
 move.l   d0,bx_fatrec(a6)         ; aktive FAT
 
gxb_fatmirror_normal:
 addq.l   #1,a0
 moveq    #0,d0
 move.w   bs_info_sect(sp),d0      ; Nummer des Info-Sektors
 ror.w    #8,d0                    ; intel->motorola
 move.l   d0,(a0)                  ; bx_infosec
 moveq    #E_OK,d0
 bra.b    gxb_ende2
gxb_edrive2:
 moveq    #EDRIVE,d0
gxb_ende2:
 adda.l   d6,sp
 tst.l    d0
 bne.b    gxb_edrive
 bra.b    gxb_check

* BPB => XBPB
gxb_bpb:
 move.l   d0,a0
 move.l   a6,a1
 move.l   (a0)+,(a1)+              ; b_recsiz,b_clsiz
 move.l   (a0)+,(a1)+              ; b_clsizb,b_rdlen
 clr.l    (a1)+                    ; bx_rdclust := 0L
 clr.w    (a1)+                    ; bx_fsiz.hi := 0
 move.w   (a0)+,(a1)+              ; bx_fsiz.lo := b_fsiz
 clr.l    (a1)+                    ; bx_fat1rec := 0 (ungueltig!)
 clr.w    (a1)+                    ; bx_fatrec.hi := 0
 move.w   (a0)+,(a1)+              ; bx_fatrec.lo := b_fatrec
 clr.w    (a1)+                    ; bx_datrec.hi := 0
 move.w   (a0)+,(a1)+              ; bx_datrec.lo := b_datrec
 clr.w    (a1)+                    ; bx_numcl.hi := 0
 move.w   (a0)+,(a1)+              ; bx_numcl.lo := b_numcl
 move.w   (a0),d0                  ; b_flags
 andi.b   #1,d0
 move.b   d0,(a1)+                 ; FAT-Typ (12/16/32 Bit)
 move.w   (a0),d0
 btst.b   #1,d0
 seq      d0
 andi.b   #1,d0
 addq.b   #1,d0
 move.b   d0,(a1)+                 ; Anzahl FATs (1 oder 2)
 clr.l    (a1)                     ; bx_infosec

* Teste XBPB auf Konsistenz

gxb_check:
 move.l   a6,a0
 bsr      check_xbpb
 bra.b    gxb_ende
gxb_edrive:
 moveq    #EDRIVE,d0
gxb_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a6/a5/d7/d6
 rts


*********************************************************************
*
* long drv_open( a0 = DMD *dmd )
*
* Ist d_dfs(a0) schon initialisiert, wird ein Diskwechsel
* ueberprueft.
* Wenn nicht, wird ueberprueft, ob auf Laufwerk d_drive(a0)
* ein DOS- Dateisystem vorliegt.
*

drv_open:
 tst.l    d_dfs(a0)                ; Laufwerk schon bekannt ?
 bne      dosf_chkdrv              ; ja, nur Diskwechsel testen

;     DEB  'Try to open DFS_FAT on drive'

 move.l   a5,-(sp)
 suba.w   #bx_sizeof,sp
 move.l   a0,a5                    ; a5 := DMD *

 lea      (sp),a0                  ; XBPB *
 move.w   d_drive(a5),d0           ; bios_drv
 bsr      getxbpb
 bmi      do_ende                  ; Fehler

;     DEB  'Drive contains DOS-FAT filesystem => open'

* Dateisystem eintragen
 move.l   #dfs_fat_drv,d_dfs(a5)        ; Dateisystem eintragen
 move.w   d_drive(a5),d_biosdev(a5)     ; BIOS-Device
* Hier XHDI-Geraetenummern ermitteln
 move.l   a5,a0
 jsr      DMD_rdevinit                  ; d_driver/d_devcode eintragen
* Speicher fuer Root- DD_FD holen
 bsr      int_malloc
 move.l   d0,d_root(a5)                 ; Root in den DMD eintragen
* den DMD initialisieren

 move.l   bx_fsiz(sp),d_fsiz(a5)        ; FAT- Groesse in Sektoren
 move.l   bx_fatrec(sp),d_fatrec(a5)    ; Sektornummer der aktiven FAT
 move.w   bx_clsiz(sp),d_clsiz(a5)      ; Sektoren pro Cluster
 move.w   bx_clsizb(sp),d_clsizb(a5)    ; Bytes pro Cluster
 move.w   bx_recsiz(sp),d_recsiz(a5)    ; Bytes pro Sektor
 move.l   bx_infosec(sp),d_infosec(a5)  ; Info-Sektor (F32)
 sf.b     d_dirty(a5)                   ; Medium unveraendert

 move.l   bx_numcl(sp),d0
 btst.b   #5,config_status+3.w
 bne.b    no_2cl
 addq.l   #2,d0                         ; Korrektur
no_2cl:
 move.l   d0,d_numcl(a5)                ; Anzahl der Datencluster

 move.b   bx_ftype(sp),d_flag(a5)       ; FAT-Typ (12/16/32 Bit)
 move.b   bx_nfats(sp),d_flag+1(a5)     ; Anzahl FATs
 move.w   bx_clsiz(sp),d0
 bsr      ilog2
 move.w   d0,d_lclsiz(a5)          ; 2er- Logarithmus von clsiz
 lea      f_masks(pc),a0
 add.w    d0,d0
 move.w   0(a0,d0.w),d_mclsiz(a5)  ; Bitmaske fuer clsiz
 move.w   bx_recsiz(sp),d0
 bsr      ilog2
 move.w   d0,d_lrecsiz(a5)         ; 2er- Logarithmus von recsiz
 add.w    d0,d0
 move.w   0(a0,d0.w),d_mrecsiz(a5) ; Bitmaske fuer recsiz
 move.w   bx_clsizb(sp),d0
 bsr      ilog2
 move.w   d0,d_lclsizb(a5)         ; 2er- Logarithmus von clsizb

* Initialisierung des DD_FD der Root

 move.l   d_root(a5),a0
 move.l   a5,fd_dmd(a0)            ; DMD
 clr.b    fd_name(a0)              ; Nullname
 move.b   #$10,fd_attr(a0)         ; Attribut: Subdir

 move.l   bx_rdclust(sp),fd_Lstcl(a0)   ; Startcluster: 0 bzw. gueltig (FAT32)
 beq.b    dro_fixedroot
 move.l   #$7fffffff,fd_len(a0)    ; geoeffnetes Subdir
 move.l   #dosf_drv,fd_ddev(a0)
 bra.b    dro_bothroot

dro_fixedroot:
 move.w   bx_rdlen(sp),d0
 mulu     bx_recsiz(sp),d0
 move.l   d0,fd_len(a0)            ; Dateilaenge der Root in Bytes
 move.l   #dosroot_drv,fd_ddev(a0) ; DOSroot- Datei

* Offset fuer DATA in DMD

dro_bothroot:
 move.l   bx_datrec(sp),d0         ; Sektornummer des 1. Datenclusters
 moveq    #0,d1                    ; unsigned
 move.w   bx_clsiz(sp),d1
 add.l    d1,d1                    ; * 2 (1. gueltiger Cluster ist 2)
 sub.l    d1,d0                    ; vom 1. Datencluster abziehen
 move.l   d0,d_Ldoff(a5)           ; Sektornummeroffset fuer Daten

* FSINFO-Sektor einlesen und Daten ermitteln

 moveq    #-1,d0
 move.l   d0,d_1stfree_cl(a5)      ; Cache fuer freien Cl. (FAT16/FAT32)
 move.l   d0,d_nfree_cl(a5)        ; Anzahl freier Cluster unbekannt

 move.l   a5,a0
 bsr      rd_fsinfo                ; Lesen
 ble.b    do_ok                    ; Fehler oder ungueltig

 ; Anzahl freier Cluster aus Sektor lesen und in big-endian wandeln: d0
 move.l   FSI_Free_Count(a1),d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0                    ; -> big-endian

 ; naechsten freien Cluster aus Sektor lesen und in big-endian wandeln: d2
 move.l   FSI_Nxt_Free(a1),d2
 ror.w    #8,d2
 swap     d2
 ror.w    #8,d2                    ; -> big-endian

 ; gueltigen Bereich pruefen, ggf. ignorieren
 move.l   d_numcl(a5),d1           ; Anzahl aller Cluster
 cmp.l    d1,d0                    ; number free clusters >= numcl?
 bcc.s    do_ok                    ; yes, ignore
 cmp.l    d1,d2                    ; next free cluster >= numcl?
 bcc.s    do_ok                    ; yes, ignore
 moveq.l  #FAT32_ROFF,d1
 cmp.l    d1,d2                    ; next free cluster < 32?
 bcs.s    do_ok                    ; yes, ignore
 
 move.l   d0,d_nfree_cl(a5)
 move.l   d2,d_1stfree_cl(a5)

do_ok:
 moveq    #E_OK,d0
do_ende:
 adda.w   #bx_sizeof,sp
 move.l   (sp)+,a5
 rts

dosf_chkdrv:
;     DEB  'Test medium change on DFS_FAT drive'
 move.l   a0,-(sp)
 move.w   d_drive(a0),-(sp)
 move.w   #9,-(sp)
 trap     #$d                      ; bios Mediach
 addq.l   #4,sp
 move.l   (sp)+,a0
 move.l   d0,d1
 beq.b    dosf_ch_ok               ; Disk nicht gewechselt!
 subq.l   #1,d1
 beq.b    fatfs_checkit            ; Disk vielleicht gewechselt
 subq.l   #1,d1
 bne.b    dosfch_diskerr           ; anderer Rueckgabewert (?)
 moveq    #E_CHNG,d0               ; 2 => E_CHNG
dosfch_diskerr:
 move.w   d_drive(a0),d1
 bra      fatfs_diskerr
fatfs_checkit:
 move.l   a0,-(sp)
 move.w   d_drive(a0),d1           ; drv
 moveq    #1,d0                    ; Ausfuehrungsmodus
 bsr      secb_inv                 ; Sektorpuffer ungueltig machen
 moveq    #2,d0                    ; Bestimme Nachfolger von Cluster #2
 move.l   (sp),a0                  ; DMD
 bsr      FAT_read                 ; physikalischen Lesezugriff erzwingen
 move.l   (sp)+,a0
 bmi.b    dosfch_diskerr
 moveq    #0,d0
dosf_ch_ok:
 rts


**********************************************************************
*
* long drv_close( a0 = DMD *dmd, d0 = int mode )
*
* mode == 0:   Frage, ob schliessen erlaubt, ggf. schliessen
*         1:   Schliessen erzwingen, muss E_OK liefern
*

drv_close:
 tst.w    d0
 bne.b    drvcl_force
 move.l   a0,-(sp)
 bsr      secb_inv
 move.l   (sp)+,a0
 tst.l    d0
 bmi.b    drvcl_ende
 bsr      set_disk_clean           ; INFO-Sektor aktualisieren
 moveq    #E_OK,d0                 ; kein Fehler
drvcl_ende:
 rts

drvcl_force:
 move.w   d_drive(a0),d1
;move.w   d0,d0               ; Modus
 bra      secb_inv            ; Anfragen bzw. ungueltig machen


**********************************************************************
*
* long dosf_sfirst( a0 = FD   *dd, a1 = DIR *d)
*                   d0 = long pos, d1 = DTA *dta)
*
* Rueckgabe:    d0 = E_OK
*             oder
*              d0 = ELINK
*              a0 = char *link
*
* <pos> ist die Position, schon um 32 Bytes weiter
*

dosf_sfirst:
 move.l   fd_dmd(a0),a2
 tst.b    d_flag(a2)
 bge.b    dosff_f12_f16

* FAT 32

 move.l   d1,a2
 move.l   fd_Lccl(a0),d0
 bra.b    dosff_fat_all

* FAT 12 oder FAT16

dosff_f12_f16:
 move.l   fd_multi1(a0),a2
 tst.l    fd_parent(a2)                 ; Root ?
 move.l   d1,a2                         ; a2 = DTA
* Im Fall "root" einfach dta_dpos eintragen
 beq.b    dosff_root                    ; ja
* sonst dta_dpos = 0
 moveq    #0,d0
 move.w   fd_Lccl+2(a0),dta_ccl(a2)
dosff_fat_all:
 move.w   fd_clpos(a0),dta_clpos(a2)
dosff_root:
 move.l   d0,dta_dpos(a2)
 btst     #FAB_SYMLINK,dir_attr(a1)
 bne      dfs_get_symlink               ; symbolischer Link
 moveq    #0,d0                         ; kein Fehler
 rts


**********************************************************************
*
* d0 = DIR *dosf_snext( a0 = DTA *dta, a1 = DMD *d )
*
* Rueckgabe:    d0 = E_OK
*             oder
*              d0 = ELINK
*              a0 = char *link
*

dosf_snext:
 movem.l  d7/d6/a3/a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = DTA *
 move.l   a1,a4                    ; a4 = DMD *

 jsr      appl_begcritic           ; aendert nur a2/d2

 tst.b    d_flag(a4)
 bmi.b    fsn_fat32
 move.l   dta_dpos(a5),d1          ; Bytepos. innerhalb des Verzeichnisses
 beq.b    fsn_subdir


* 1. Fall : FAT12 oder FAT16
*           dta_dpos ist gueltig
*           dta_ccl und dta_clpos sind ungueltig
*           Wir suchen in der Root

 moveq    #OM_RPERM,d0
 move.l   d_root(a4),a0            ; DD
 bsr      reopen_FD
 bmi      fsn_err
 move.l   d0,a3                    ; a3 = FD
 move.l   dta_dpos(a5),d1          ; Position
 move.l   a5,a1                    ; Suchname (internes Format)
 move.l   a3,a0                    ; FD
 jsr      _dir_srch
 move.l   d0,d7                    ; DIR * oder Fehlercode
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq      fsn_err                  ; ja, sofort abbrechen!!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq      fsn_err                  ; ja, sofort abbrechen!!!
 move.l   d1,dta_dpos(a5)          ; Position neu festlegen
 move.l   a3,a0
 bsr      close_DD
 move.l   d7,d0
 bmi      fsn_notfound             ; return(ENMFIL)
 move.l   d0,a3                    ; DIR *
 bra      fsn_found2


* 2. Fall: FAT32
*          dta_dpos enthaelt die Clusternummer (LONG)
*          dta_ccl ist ungueltig
*          dta_clpos ist gueltig
*          Unterverzeichnis oder Root einer FAT32-Partition
* Die Disk auf FAT- Ebene durchsuchen (ohne Hilfe von FDs o.ae.)

fsn_fat32:
 move.l   dta_dpos(a5),d6          ; aktueller Cluster
 bra.b    fsn_fat

* 3. Fall: dta_dpos ist ungueltig
*          dta_ccl und dta_clpos sind gueltig
*          Unterverzeichnis
* Die Disk auf FAT- Ebene durchsuchen (ohne Hilfe von FDs o.ae.)

fsn_subdir:
 moveq    #0,d6
 move.w   dta_ccl(a5),d6           ; aktueller Cluster (UWORD => LONG)
fsn_fat:
 move.w   dta_clpos(a5),d7         ; Byteposition innerhalb des Clusters
* Ggf. einen Cluster weitergehen und Offsets neu bestimmen
fsn_secloop:
 cmp.w    d_clsizb(a4),d7          ; Bytes pro Cluster
 bne.b    fsn_read_sector          ; bin nicht am Clusterende

* einen Cluster weitergehen (FAT-Zugriff)

 clr.w    d7                       ; gehe 1 Cluster weiter, Offset 0
 move.l   a4,a0                    ; DMD
 move.l   d6,d0                    ; Folgecluster des aktuellen bestimmen
 bsr      FAT_read
 bmi      fsn_err                  ; Lesefehler
 move.l   d0,d6                    ; das ist der Folgecluster
 cmpi.l   #-1,d6
 beq      fsn_notfound             ; dieser ist aber ungueltig (EOF)

* einen Sektor einlesen

fsn_read_sector:
 clr.w    -(sp)                    ; lesen
 lea      (bufl+4).w,a0            ; buflist
 move.l   d6,d1                    ; Clusternummer
 move.w   d_lclsiz(a4),d0
 lsl.l    d0,d1                    ; umrechnen in Sektornummer
 moveq    #0,d2                    ; unsigned long
 move.w   d7,d2
 move.w   d_lrecsiz(a4),d0
 lsr.l    d0,d2                    ; ganze Sektoren vom Ueberhang ermitteln
 add.l    d2,d1
 add.l    d_Ldoff(a4),d1           ; Offset fuer Datensektoren
 moveq    #0,d2                    ; kein zweiter Sektor
 move.w   d_drive(a4),d0           ; drv
 bsr      read_sector
 addq.l   #2,sp
 bmi      fsn_err                  ; Lesefehler

 move.l   d0,a3
 move.w   d7,d0                    ; Offset zum Clusteranfang
 and.w    d_mrecsiz(a4),d0         ; Offset zum Sektoranfang
 add.w    d0,a3                    ; a3 = Sektor + Sektoroffset = DIR *
fsn_dirloop:
 tst.b    (a3)                     ; Nullbyte (Ende des Verzeichnisses) ?
 beq.b    fsn_notfound             ; ja, nicht gefunden
 move.l   a3,a1
 lea      (a5),a0
 jsr      filename_match           ; passt unsere Datei ?
 add.w    #$20,d7                  ; Offset schonmal weitersetzen
 tst.w    d0
 bne.b    fsn_found                ; Datei passt
 lea      32(a3),a3
 move.w   d7,d0                    ; Offset zum Clusteranfang
 and.w    d_mrecsiz(a4),d0         ; Offset zum Sektoranfang
 bne.b    fsn_dirloop              ; bin noch im Sektor
 bra      fsn_secloop


fsn_notfound:
 moveq    #ENMFIL,d0
fsn_err:
 clr.b    (a5)                     ; Suchname ungueltig
 clr.b    dta_name(a5)             ; gefundener Name leer
 bra.b    fsn_ende

fsn_found:
; Datei gefunden
 move.w   d7,dta_clpos(a5)
 tst.b    d_flag(a4)
 bge.b    fsn_fat12_16_setpos
 move.l   d6,dta_dpos(a5)          ; Cluster (ULONG)
 bra.b    fsn_found2
fsn_fat12_16_setpos:
 move.w   d6,dta_ccl(a5)           ; Cluster (UWORD)
fsn_found2:
 move.l   a5,a1                    ; DTA *
 move.l   a3,a0                    ; DIR *
 jsr      init_DTA

 btst     #FAB_SYMLINK,dir_attr(a3)
 beq.b    fsn_ok
 move.l   a4,a2                    ; DMD
 move.l   a3,a1                    ; DIR *
 bsr      _dfs_get_symlink         ; symbolischer Link
 bra.b    fsn_ende
fsn_ok:
 moveq    #0,d0

fsn_ende:
 jsr      appl_endcritic           ; aendert nur a2/d2

 movem.l  (sp)+,d6/d7/a3/a4/a5
 rts


**********************************************************************
*
* long dfs_fat_ext_fd( a0 = DD_FD *f )
*
* erweitert das Verzeichnis und fuellt den neuen Platz mit 0en.
* a0 ist garantiert ein Prototyp-FD, im "exclusive"-Modus.
*

dfs_fat_ext_fd:
 jsr      appl_begcritic           ; aendert nur d2/a2

 move.l   fd_dmd(a0),a1
 tst.b    d_flag(a1)
 bmi.b    dext_f32
 tst.l    fd_parent(a0)            ; FAT12/16: Wurzelverzeichnis ?
 beq      dext_eaccdn              ; ja, return(EACCDN)

* rette die Dateiposition!

dext_f32:
 move.l   fd_Lccl(a0),-(sp)        ; Clusternummer
 move.l   fd_Lcsec(a0),-(sp)       ; Sektornummer
 move.w   fd_clpos(a0),-(sp)       ; Byte-Offset

* erweitere die Datei

 moveq    #1,d0                    ; schreiben
 move.l   a0,-(sp)
 bsr      f_extend
 move.l   (sp)+,a0

* Dateiposition restaurieren!

 move.l   fd_Lcsec(a0),d1          ; zu loeschender Sektor
 move.w   (sp)+,fd_clpos(a0)
 move.l   (sp)+,fd_Lcsec(a0)
 move.l   (sp)+,fd_Lccl(a0)

 tst.l    d0
 bmi      dext_ende                ; Schreibfehler
 ext.l    d0
 bne      dext_eaccdn

 movem.l  d6/d7/a3/a4,-(sp)
 movea.l  a0,a4                    ; a4 = zugehoeriger FD
 move.l   d1,d7                    ; d7 = zu loeschender Sektor
 movea.l  fd_dmd(a4),a3            ; a3 = zugehoeriger DMD

* Fuer 1..(Sektoren/Cluster)-1

 moveq    #1,d6
 bra.b    dext_secloop_next

dext_secloop:
 move.w   #1,-(sp)                 ; will schreiben
 lea      (bufl+4).w,a0
 moveq    #0,d2
 move.l   d6,d1
 add.l    d7,d1                    ; secnr
 add.l    d_Ldoff(a3),d1
 move.w   d_drive(a3),d0
 bsr      read_sector
 addq.l   #2,sp
 bmi      cldc_ende

 move.l   d0,a0                    ; Zeiger auf Sektorpuffer

* Fuer jedes Byte/Sektor

 move.w   d_recsiz(a3),d1
 lsr.w    #2,d1                    ; in Langworte umrechnen
 bra.b    dext_clrloop_next
dext_clrloop:
 clr.l    (a0)+
dext_clrloop_next:
 dbra     d1,dext_clrloop
 addq.w   #1,d6
dext_secloop_next:
 cmp.w    d_clsiz(a3),d6
 bcs.b    dext_secloop

* Fuer 0

 move.w   #1,-(sp)                 ; will schreiben
 lea      (bufl+4).w,a0
 moveq    #0,d2
 move.l   d7,d1                    ; secnr
 add.l    d_Ldoff(a3),d1
 move.w   d_drive(a3),d0
 bsr      read_sector
 addq.l   #2,sp
 bmi      cldc_ende
 move.l   d0,a0                    ; Zeiger auf Sektorpuffer

 move.w   d_recsiz(a3),d1
 lsr.w    #2,d1                    ; in Langworte umrechnen
 bra.b    dext_clrloop2_next
dext_clrloop2:
 clr.l    (a0)+
dext_clrloop2_next:
 dbra     d1,dext_clrloop2
 moveq    #0,d0                    ; kein Fehler
cldc_ende:
 movem.l  (sp)+,a4/a3/d6/d7
dext_ende:
 jmp      appl_endcritic           ; aendert nur d2/a2
dext_eaccdn:
 moveq    #EACCDN,d0
 bra.b    dext_ende


**********************************************************************
*
* long dfs_fat_fcreate( a0 = DD *d, a1 = DIR *dir,
*                       d0 = int cmd, d1 = long arg )
*
* Rueckgabe: d0.l = Fehlercode
*
* Erstellt eine Datei (oder Verzeichnis) per Dcntl oder Fcreate.
* Ist cmd == 0, wurde nur Fcreate gemacht.
* Es ist <dir> zu aendern und entsprechende Massnahmen zu ergreifen,
* ggf. ein Fehlercode zurueckzugeben.
*

dfs_fat_fcreate:
 tst.w    d0
 beq.b    _fcre_ret0
 cmpi.w   #MX_INT_CREATESYMLNK,d0
 beq      _fcre_symlink
 moveq    #EINVFN,d0          ; unbekanntes Dcntl
 rts
_fcre_ret0:
 moveq    #0,d0
 rts
_fcre_symlink:
 movem.l  a3/a6,-(sp)
 move.l   d1,a3               ; a3 = char *link
 move.l   a1,a6               ; a6 = DIR *dir
 suba.w   #fd_sizeof,sp       ; FD allozieren

 jsr      appl_begcritic      ; aendert nur d2/a2

 move.l   fd_dmd(a0),fd_dmd(sp)
 move.l   sp,fd_multi1(sp)
 clr.l    fd_Lccl(sp)
 clr.l    fd_Lstcl(sp)        ; Datei ist zunaechst leer
 moveq    #1,d0               ; writeflag
 move.l   sp,a0               ; FD *
 bsr      f_extend            ; einen Cluster fuer Datei allozieren
 bmi.b    _fcre_ende          ; Fehler !

 move.b   #$40,dir_attr(a6)   ; FA_SYMLINK (MagiC-Erfindung)

 move.l   fd_Lstcl(sp),d1
 move.w   d1,d2               ; allozierter Startcluster (Loword)
 ror.w    #8,d2               ; ->intel
 move.w   d2,dir_stcl(a6)
 move.l   d1,d2
 swap     d2
 ror.w    #8,d2
 move.w   d2,dir_stcl_f32(a6)      ; FAT32: obere 12 Bit des Startclusters

 move.l   fd_dmd(sp),a2
 move.w   #1,-(sp)                 ; schreiben
 lea      (bufl+4).w,a0            ; buflist
 move.w   d_lclsiz(a2),d0
 lsl.l    d0,d1                    ; Clusternummer umrechnen in Sektornummer
 add.l    d_Ldoff(a2),d1           ; Offset fuer Datensektoren
 moveq    #0,d2                    ; kein zweiter Sektor
 move.w   d_drive(a2),d0           ; drv
 bsr      read_sector
 addq.l   #2,sp
 bmi.b    _fcre_ende
 move.l   d0,a1                    ; a1 = Zeiger auf Sektorpuffer

 move.l   a3,a0
 bsr      strlen
 addq.l   #2,d0
 bclr     #0,d0                    ; d0 Laenge (gerade) ohne Laengenfeld

; Pruefung auf Ueberlauf (Pfad laenger als Sektorlaenge)

 move.l   fd_dmd(sp),a2
 moveq    #0,d1                    ; unsigned long
 move.w   d_recsiz(a2),d1          ; Sektorgroesse in Bytes
 subq.l   #4,d1                    ; Sicherheitsabstand + Laengenwort
 cmp.l    d1,d0
 bhi.b    _fcre_erange

 move.w   d0,(a1)+
 addq.l   #2,d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 move.l   d0,dir_flen(a6)          ; Dateilaenge ins DIR eintragen
_fcre_loop:
 move.b   (a3)+,(a1)+
 bne.b    _fcre_loop
 moveq    #0,d0                    ; kein Fehler
_fcre_ende:

 jsr      appl_endcritic      ; aendert nur d2/a2
 adda.w   #fd_sizeof,sp
 movem.l  (sp)+,a3/a6
 rts
_fcre_erange:
 moveq    #ERANGE,d0
 bra.b    _fcre_ende


**********************************************************************
*
* long strlen( a0 = char *string )
*

strlen:
 move.l   a0,d0
str1:
 tst.b    (a0)+
 bne.b    str1
 suba.l   d0,a0
 move.l   a0,d0
 subq.l   #1,d0
 rts


**********************************************************************
*
* long dfs_fat_fxattr( a0 = DD *d, a1 = DIR *dir,
*                      d0 = int mode, d1 = XATTR *xattr )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurueck)
*         1:   Folge nicht  (d.h. erstelle XATTR fuer den Link)
*
* a1 == NULL: Es ist ein FD (a0)
*

dfs_fat_fxattr:
 move.l   d1,a2                    ; a2 = XATTR *
 move.l   a1,d2                    ; DIR *
 beq.b    fxa_nodir                ; nein, FD in a0 uebergeben
 move.w   d0,d2
 bsr      dfs_fat_dir2index
 move.l   d0,xattr_index(a2)
 btst     #FAB_SYMLINK,dir_attr(a1)
 beq.b    fxa_nodir
; Symlink
 andi.b   #%00001111,xattr_mode(a2)
 moveq    #14,d0              ; symbolic link
 lsl.b    #4,d0
 or.b     d0,xattr_mode(a2)
 tst.w    d2
 beq      dfs_get_symlink
fxa_nodir:
 move.l   fd_dmd(a0),a0
 move.w   d_clsizb(a0),xattr_blksize+2(a2)
 move.l   xattr_size(a2),d1        ; xattr.size
 beq.b    fxa_ok
 cmpi.l   #$7fffffff,d1            ; geoeffnetes Subdir ?
 bne.b    fxa_no_ovl
 moveq    #0,d1
 move.l   d1,xattr_size(a2)        ; geoeffnete Subdir => Laenge 0
 bra.b    fxa_ok
fxa_no_ovl:
 divu     xattr_blksize+2(a2),d1   ;   /xattr.blksize
 move.w   d1,d2
 swap     d1
 tst.w    d1                       ; bei Rest aufrunden
 beq.b    fxa_setb
 addq.w   #1,d2
fxa_setb:
 move.w   d2,xattr_nblocks+2(a2)   ; => xattr.nblocks
fxa_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* long dfs_fat_dir2index( a0 = FD *d, a1 = DIR *dir )
*
* Rechnet einen DIR- Eintrag in einen Index um. Der Index dient
* lediglich zur eindeutigen Kennzeichnung einer Datei.
*
* Aendert KEIN Register ausser d0.
*

dfs_fat_dir2index:
 btst     #FAB_SUBDIR,dir_attr(a1)
 bne.b    fd2i_subdir
 moveq    #-32,d0
 add.l    fd_fpos(a0),d0           ; Position im Verzeichnis
 lsr.l    #5,d0                    ; 32 Byte pro DIR-Eintrag
 swap     d0
 move.w   fd_Lstcl+2(a0),d0        ; Startcluster des DIR ins Hiword
 bne.b    fd2i_noroot
 addq.w   #1,d0                    ; Root -> index 1
fd2i_noroot:
 swap     d0
 rts
fd2i_subdir:
 moveq    #0,d0
 move.w   dir_stcl(a1),d0
 ror.w    #8,d0
 rts


**********************************************************************
*
* a0 = char * dfs_fat_readlink( a0 = DD *d, a1 = DIR *dir )
*
* Liest symbolischen Link
*

dfs_fat_readlink:
 btst     #FAB_SYMLINK,dir_attr(a1)
 bne      dfs_get_symlink               ; symbolischer Link
frl_err:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* ULONG dfs_fat_dir2stcl( a2 = DMD *dmd, a1 = DIR *dir )
*
* Holt aus einem Verzeichniseintrag den Startcluster.
* aendert nur d0.
*

dfs_fat_dir2stcl:
 tst.b    d_flag(a2)
 bge.b    d2stcl_f12_16
 move.w   dir_stcl_f32(a1),d0           ; obere 12 Bit des Startclusters
 ror.w    #8,d0                         ; intel => motorola
 swap     d0
 bra.b    d2stcl_fall
d2stcl_f12_16:
 moveq    #0,d0                         ; UWORD => ULONG
d2stcl_fall:
 move.w   dir_stcl(a1),d0
 ror.w    #8,d0
 rts


**********************************************************************
*
* long dfs_fat_dir2FD( a0 = FD *f, a1 = DIR *dir )
*
* initialisiert einen Prototyp-FD, und zwar
*
*  fd_len
*  fd_Lstcl
*  fd_attr
*  fd_ddev
*
* und ggf.
*  fd_name, fd_xftype, fd_xdata usw.
*
* und aendert ggf. Daten
*
* Rueckgabe:    0    OK
*             ELINK, a0 ist Zeiger auf symbolischen Link
*             <0    Fehlercode
*

dfs_fat_dir2FD:
 btst     #FAB_SYMLINK,dir_attr(a1)
 bne.b    dfs_get_symlink               ; symbolischer Link
 move.l   #dosf_drv,fd_ddev(a0)
 move.l   fd_dmd(a0),a2

;move.l   a2,a2
;move.l   a1,a1
 bsr      dfs_fat_dir2stcl              ; aendert nur d0
 move.l   d0,fd_Lstcl(a0)

 moveq    #0,d0                         ; kein Fehler
 btst     #FAB_SUBDIR,dir_attr(a1)      ; Subdir ?
 bne.b    d2f_dir
* kein SubDir
 move.l   dir_flen(a1),d0               ; Laenge (intel)
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0                         ; -> Motorola
 move.l   d0,fd_len(a0)                 ; FD- Laenge eintragen
 move.b   dir_attr(a1),fd_attr(a0)
 rts
* SubDir
d2f_dir:
 move.l   #$7fffffff,fd_len(a0)
 lea      fd_name(a0),a0
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)                     ; Name (11 Zeichen) und Attribut
 rts


**********************************************************************
*
* long dfs_fat_pathconf( a0 = DD *d, d0 = int which )
*
*         0:   internal limit on the number of open files
*         4:   number of bytes that can be written atomically
*

FA_ALL    SET  FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_VOLUME+FA_SUBDIR+FA_ARCHIVE

dfs_fat_pathconf:
;cmpi.w   #DP_IOPEN,d0
 tst.w    d0
 beq.b    dpp_0
 cmpi.w   #DP_MODEATTR,d0
 beq.b    dpp_7
 subq.w   #DP_ATOMIC,d0
 beq.b    dpp_4
 moveq    #EACCDN,d0
 rts
dpp_7:
 move.l   #FA_ALL+DP_FT_DIR+DP_FT_REG+DP_FT_LNK,d0
 rts
dpp_4:
 move.l   #512,d0
 rts
dpp_0:
 moveq    #40,d0
 rts


**********************************************************************
*
* long  dfs_get_symlink( a0 = FD *f, a1 = DIR *dir )
* long _dfs_get_symlink( a2 = DMD *drv, a1 = DIR *dir )
*
* => d0 = ELINK
*    a0 = char *link
*   oder
*    d0 = ernster Fehlercode
*

inv_link_s:
 DC.W     12
 DC.B     'U:\DEV\NULL',0

dfs_get_symlink:
 move.l   fd_dmd(a0),a2
_dfs_get_symlink:

 move.l   a2,d0
 jsr      appl_begcritic           ; aendert nur d2/a2
 move.l   d0,a2

;move.l   a2,a2
;move.l   a1,a1
 bsr      dfs_fat_dir2stcl         ; aendert nur d0

 cmpi.l   #2,d0                    ; Startcluster >= 2 ?
 bcc.b    dgs_val                  ; ja, lesen!
 lea      inv_link_s(pc),a0        ; ungueltiger Symlink
 bra.b    dgs_ende2

dgs_val:
 clr.w    -(sp)                    ; lesen
 lea      (bufl+4).w,a0            ; buflist
 move.l   d0,d1                    ; Clusternummer (ULONG)
 move.w   d_lclsiz(a2),d0
 lsl.l    d0,d1                    ; umrechnen in Sektornummer
 add.l    d_Ldoff(a2),d1           ; Offset fuer Datensektoren
 moveq    #0,d2                    ; kein zweiter Sektor
 move.w   d_drive(a2),d0           ; drv
 bsr      read_sector
 addq.l   #2,sp
 bmi.b    dgs_ende
 move.l   d0,a0
dgs_ende2:
 move.l   #ELINK,d0
dgs_ende:

 jmp      appl_endcritic           ; aendert nur d2/a2


**********************************************************************
*
* void install_secbuf( a0 = BCBX *b, a1 = void *buf, a2 = BCBX *liste )
*
* initialisiert einen Sektorpuffer und haengt ihn in die Liste
* Die Liste ist doppelt verkettet.
*

install_secbuf:
 move.w   #-1,xb_drv(a0)
 move.l   a1,xb_data(a0)
 clr.l    xb_prev(a0)              ; bin erster Block
 move.l   a2,xb_first(a0)
 move.l   (a2),d0
 move.l   d0,xb_next(a0)
 move.l   a0,(a2)
 tst.l    d0
 beq.b    ins_weiter               ; gibt keinen naechsten Puffer
 move.l   d0,a1
 move.l   a0,xb_prev(a1)           ; bin Vorgaenger meines Nachfolgers
ins_weiter:
 move.l   #'_SEC',d1
 lea      xb_sem(a0),a0
 moveq    #SEM_CREATE,d0
 jmp      evnt_sem


**********************************************************************
*
* long fatfs_diskerr(d0 = long errcode, d1 = int drv)
*
* Das BIOS meldete einen Diskfehler, oder Mediach() lieferte eine "1"
* fuer "Disk vielleicht gewechselt".
* Diskpuffer ungueltig machen.
*
* errcode = E_CHNG:      Rueckgabe E_CHNG, wenn Getbpb erfolgreich
*                        sonst    ERROR
*
* errcode sonst:         errcode zurueckgeben
*

fatfs_diskerr:
 move.l   d0,-(sp)                 ; errcode
 move.w   d1,-(sp)                 ; drv

* Alle Diskpuffer fuer unsere Disk fuer ungueltig erklaeren
* (d.h. nur die, die z.Zt. nicht gesperrt sind)

;move.w   d1,d1                    ; drv
 moveq    #1,d0                    ; Ausfuehrungsmodus
 bsr.b    secb_inv
 move.w   (sp)+,d1
 move.l   (sp)+,d0
 cmpi.l   #E_CHNG,d0
 bne.b    fatfd_ende
 move.w   d1,d0                    ; Disk
 jmp      diskchange               ; Disk ggf. wechseln
fatfd_ende:
 rts


**********************************************************************
*
* long secb_inv( d0 = int mode, d1 = int drive )
*
* mode == 0:   Anfragemodus. Falls ein Puffer unseres Laufwerks
*              gesperrt oder "dirty" ist, => EACCDN
*
* mode == 1:   Ausfuehrungsmodus. Alle nicht gesperrten Diskpuffer
*              fuer unsere Disk fuer ungueltig erklaeren
*

secb_inv:
 lea      bufl.w,a0
sinv_newlist:
 move.l   (a0),d2
 bra.b    sinv_nxtbuf
sinv_loop:
 move.l   d2,a1
 cmp.w    xb_drv(a1),d1            ; unser Laufwerk ?
 bne.b    sinv_nxt                 ; nein

 tst.w    d0                       ; Anfragemodus ?
 bne.b    sinv_exec                ; nein

;Anfragemodus
 tst.l    xb_sem+bl_app(a1)        ; Sektor in Arbeit ?
 bne.b    sinv_eaccdn              ; ja, Fehler
 tst.w    xb_dirty(a1)             ; Sektor geaendert ?
 beq.b    sinv_nxt                 ; nein, OK, naechster Sektor
sinv_eaccdn:
 moveq    #EACCDN,d0
 rts

; Ausfuehrungsmodus
sinv_exec:
 tst.l    xb_sem+bl_app(a1)        ; Sektor in Arbeit ?
 bne.b    sinv_nxt                 ; ja, nicht ungueltig machen
 move.w   #-1,xb_drv(a1)

sinv_nxt:
 move.l   xb_next(a1),d2
sinv_nxtbuf:
 bne      sinv_loop
 addq.l   #4,a0
 cmpa.l   #(bufl+4),a0
 bls      sinv_newlist
 moveq    #0,d0                    ; kein Fehler
 rts


**********************************************************************
*
* void secb_wait_unused( void )
*

secb_wait_unused:
 move.l   a5,-(sp)
 jsr      appl_begcritic           ; aendert nur d2/a2
suu_again:
 lea      bufl.w,a5                  ; list
suu_newlist:
 move.l   (a5),d2
 bra.b    suu_nxtbuf
suu_loop:
 move.l   d2,a1
 tst.l    xb_sem+bl_app(a1)        ; Semaphore belegt ?
 bne.b    suu_wr                   ; ja, muss zurueckschreiben
 tst.w    xb_drv(a1)
 bmi.b    suu_nxt                  ; Puffer unbenutzt
 tst.w    xb_dirty(a1)
 beq.b    suu_ok                   ; unveraendert, nur ungueltig machen
suu_wr:
 move.l   a1,a0
 bsr      write_sector
 bra      suu_again                ; muss nochmal anfangen (Taskwechsel!)

suu_ok:
 move.w   #-1,xb_drv(a1)
suu_nxt:
 move.l   xb_next(a1),d2
suu_nxtbuf:
 bne      suu_loop

 addq.l   #4,a5
 cmpa.l   #(bufl+4),a5
 bls      suu_newlist
 jsr      appl_endcritic           ; aendert nur d2/a2
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void secb_ext( void )
*
* Testet, ob die Pufferliste _bufl erweitert wurde und haengt ggf.
* neue Puffer in die Liste bufl.
*

secb_ext:
 lea      _bufl,a0
 tst.l    (a0)
 beq.b    se_nxt
 lea      bufl.w,a1
 bsr      _secb_ext
se_nxt:
 lea      (_bufl+4).w,a0
 tst.l    (a0)
 beq.b    se_ende
 lea      (bufl+4).w,a1
 bsr      _secb_ext
 move.l   d0,bufl_size.w
se_ende:
* Anzahl vorhandener Bloecke bestimmen
 bsr      int_mblocks
 move.l   d0,a0
* Anzahl angemeldeter Laufwerke bestimmen
 moveq    #0,d0
 move.l   _drvbits,d1
se_bloop:
 tst.l    d1
 beq.b    se_bend
 addq.l   #1,d0
 move.l   d1,d2
 subq.l   #1,d2
 and.l    d2,d1
 bra.b    se_bloop
se_bend:
 mulu     #8,d0               ; mind. 8 Bloecke pro Laufwerk
 move.l   a0,d1
 sub.l    d1,d0
 ble.b    se_ende2            ; sind genuegend Bloecke da!
;move.w   d0,d0
 bsr      resvb_intmem        ; soviele Bloecke allozieren
se_ende2:
 rts


_secb_ext:
 movem.l  a6/a5/a4/d7,-(sp)
 move.l   a0,a5                    ; _bufl+i
 move.l   a1,a6                    ; bufl+i
 move.l   bufl_size.w,d7
 move.l   pun_ptr,d0
 ble.b    sec_ende                 ; ungueltiger Zeiger ?
 move.l   d0,a2
 moveq    #0,d0
 move.w   pun_msectsize(a2),d0     ; Sektorgroesse
 cmp.l    bufl_size.w,d0           ; sind die installierten kleiner ?
 bls.b    se_ok                    ; nein, kann meine behalten
 move.l   d0,d7                    ; neue Groesse

* bestehende Puffer muessen deinstalliert werden

 bsr      secb_wait_unused         ; warten, bis kein Puffer gesperrt ist
* Die alten Puffer werden als interne Speicherbloecke recykelt
 move.l   (a6),d2
 bra.b    se_nxtbuf
se_loop:
 move.l   d2,a4
 move.l   bufl_size.w,d0
 move.l   xb_data(a4),a0
 bsr      resv_intmem
 move.l   xb_next(a4),d2
se_nxtbuf:
 bne      se_loop
 clr.l    (a6)                     ; keine Puffer mehr
se_ok:

* neue Puffer muessen installiert werden
 move.l   (a5),d2
 bra.b    se_nxtbuf2
se_loop2:
 move.l   d2,a4

 bsr      int_mblocks              ; Anzahl freier IMBs ermitteln
 cmpi.l   #20,d0                   ; mindestens 20 frei ?
 bcc.b    se_enough                ; ja, ok
 move.l   b_bufr(a4),a0            ; Pufferadresse
 move.l   d7,d0                    ; Pufferlaenge
 bsr      resv_intmem              ; gesamten Puffer als interner Speicher
 bra.b    se_nxtnb

se_enough:
 bsr      int_pmalloc              ; permanent allozieren

 move.l   a6,a2                    ; Liste
 move.l   b_bufr(a4),a1
;move.l   a0,a0                    ; XBCB
 bsr      install_secbuf

se_nxtnb:
 move.l   b_link(a4),d2
se_nxtbuf2:
 bne      se_loop2
 clr.l    (a5)                     ; keine neuen Puffer mehr
sec_ende:
 move.l   d7,d0
 movem.l  (sp)+,a4/a5/a6/d7
 rts


**********************************************************************
*
* long dosroot_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*

dosroot_open:
 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 rts


**********************************************************************
*
* long dosroot_seek( a0 = FD *file, d0 = long offs, d1 = int smode)
*
* Wurzelverzeichnis. Wird vom Kernel immer nur mit d1=0 aufgerufen,
* also mit absoluter Position.
* Die Felder ccl/Lcsec/clpos sind bei der Root ohne Bedeutung.
*

dosroot_seek:
 move.l   fd_multi1(a0),a2
 cmp.l    fd_len(a2),d0
 bhi      rfsk_range
 move.l   d0,fd_fpos(a0)
 rts
rfsk_range:
 moveq    #ERANGE,d0
 rts


**********************************************************************
*
* long dosroot_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

dosroot_write:
     IFNE NOWRITE
 moveq    #EWRPRO,d0
 rts
     ENDIF
 moveq    #1,d1
 lea      ncopy_to(pc),a2
 bra.b    dosroot_rw


**********************************************************************
*
* long dosroot_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Ein Zugriff wird nie ueber eine Sektorgrenze hinaus stattfinden.
*

dosroot_read:
 moveq    #0,d1
 lea      ncopy_from(pc),a2
dosroot_rw:
 movem.l  d7/d6/a6/a5,-(sp)

 move.w   d1,-(sp)                 ; Lese/Schreibflag
 move.l   a1,a6                    ; a6 = Pufferadresse
 move.l   a2,a5                    ; Kopier-Routine
 move.l   d0,d7                    ; d7 = cnt

 jsr      appl_begcritic           ; aendert nur a2/d2

 move.l   fd_dmd(a0),a2
 move.l   fd_fpos(a0),d1           ; Lese-/Schreibposition
 add.l    d1,d0                    ; d0 = cnt+pos
 move.l   fd_multi1(a0),a1         ; Prototyp-FD
 cmp.l    fd_len(a1),d0
 bhi      dor_eaccdn               ; ueber Dateiende hinaus!
 move.l   d0,fd_fpos(a0)           ; neue Position schon merken
 move.w   d1,d6
 and.w    d_mrecsiz(a2),d6         ; d6 = Byte-Offset im Sektor
 move.w   d_lrecsiz(a2),d0
 lsr.l    d0,d1                    ; Sektor-Offset berechnen
 add.l    d_fatrec(a2),d1          ;  + Beginn 2. FAT
 add.l    d_fsiz(a2),d1            ;  + Laenge der FAT => Beginn root
* Sektor holen
 lea      (bufl+4).w,a0            ; 2. Pufferliste (DIR/DATA)
 moveq    #0,d2                    ; kein gespiegelter Sektor
;move.l   d1,d1                    ; Sektor
 move.w   d_drive(a2),d0           ; drv

 bsr      read_sector
 bmi      dor_err                  ; Lesefehler
 move.l   a6,d1
 beq      dor_adr                  ; nur Adresse zurueckgeben

 move.l   d0,a0                    ; Adresse des Sektors
 add.w    d6,a0                    ; + Offset
 move.l   a6,a1
 move.w   d7,d0
 jsr      (a5)
 move.l   d7,d0
 bra      dor_err

dor_adr:
 ext.l    d6
 add.l    d6,d0                    ; Sektor+Offset
dor_err:
 jsr      appl_endcritic           ; aendert nur a2/d2

 addq.l   #2,sp
 movem.l  (sp)+,d7/d6/a6/a5
 rts
dor_eaccdn:
 moveq    #0,d0
 tst.w    (sp)
 beq.b    dor_err
 moveq    #EACCDN,d0
 bra.b    dor_adr                  ; Schreibzugriff verweigern



**********************************************************************
*
* long dosf_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*

dosf_read:
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d1
 sub.l    fd_fpos(a0),d1
 cmp.l    d1,d0
 ble.b    dr_weiter
 move.l   d1,d0                    ; nicht ueber Dateiende lesen!
dr_weiter:
 tst.l    d0
 ble.b    dr_ende
 pea      ncopy_from(pc)
;move.l   a1,a1                    ; Daten
;move.l   d0,d0                    ; Laenge
;move.l   a0,a0                    ; FD
 moveq    #0,d1                    ; lesen
 bsr      f_frw
 addq.w   #4,sp
dr_ende:
;     DEB  '_fread ENDE'
 rts


**********************************************************************
*
* long dosf_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

dosf_write:
     IFNE NOWRITE
 moveq    #EWRPRO,d0
 rts
     ENDIF
 pea      ncopy_to(pc)
;move.l   a1,a1
;move.l   d0,d0
;move.l   a0,a0
 moveq    #1,d1                    ; schreiben
 bsr      f_frw
 addq.w   #4,sp
;     DEB  '_fwrite ENDE'
 rts



**********************************************************************
*
* long dosf_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*

dosf_open:
 clr.l    fd_Lccl(a0)
 clr.l    fd_Lcsec(a0)
 clr.w    fd_clpos(a0)
 move.l   fd_multi1(a0),a1         ; Dateilaenge nur im Prototyp-FD
 tst.l    fd_len(a1)               ; Datei schon leer ?
 beq.b    dosfo_ok                 ; ja, nix tun
 btst     #(BO_TRUNC-8),fd_mode(a0)
 bne      Fshrink                  ; Datei zusammenkappen
dosfo_ok:
 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 rts


**********************************************************************
*
* long dosf_ioctl(a0 = FD *f,  d0 = int cmd, a1 = long arg)
*

dosf_ioctl:
 cmpi.w   #FIONREAD,d0
 beq.b    dosf_fionread
 cmpi.w   #FIONWRITE,d0
 beq.b    dosf_fionwrite
 cmpi.w   #FTRUNCATE,d0
 bne.b    ioc_einv
 tst.l    fd_parent(a0)
 beq.b    ioc_einv                 ; nicht fuer Root
 move.l   a0,-(sp)
 moveq    #0,d1                    ; absolute Position
 move.l   (a1),d0                  ; offset (indirekt!)
;move.l   a0,a0                    ; FD
 bsr      dosf_seek
 move.l   (sp)+,a0
 tst.l    d0
 bge      Fshrink
 rts
ioc_einv:
 moveq    #EINVFN,d0
 rts


*
* long dosf_fionread(a0 = FD *f, a1 = long *val)
*

dosf_fionread:
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d0
 sub.l    fd_fpos(a0),d0
 bra.b    dosf_fput


*
* long dosf_fionwrite(a0 = FD *f, a1 = long *val)
*

dosf_fionwrite:
 moveq    #0,d0
 tst.l    fd_Lccl(a0)
 bmi.b    dosf_fput                     ; Disk voll
 moveq    #1,d0
dosf_fput:
 move.l   d0,(a1)
 moveq    #0,d0
 rts


**********************************************************************
*
* long dfs_fat_fdelete( a0 = DD *d, a1 = DIR *dir, d0 = long dirpos )
*
* Rueckgabe: Fehlercode.
* symbolische Links werden nicht verfolgt, d.h. der Link als
* solcher wird geloescht.
*

dfs_fat_fdelete:

*********************************************************************
*
* long dosf_delete( a0 = DD *dir, a1 = DIR *dir, d0 = long dirpos )
*

dosf_delete:
 movem.l  d7/d6/a5,-(sp)
 jsr      appl_begcritic           ; aendert nur d2/a2
 move.l   fd_dmd(a0),a5

 move.l   a5,a2                    ; DMD
;move.l   a1,a1                    ; DIR
 bsr      dfs_fat_dir2stcl
 move.l   d0,d7                    ; d7 = Startcluster (ULONG)
 beq.b    _fdel_ende               ; ungueltig (Datei leer)

 move.l   a5,a0
 bsr      set_disk_dirty           ; Info-Sektor- Daten ungueltig machen
 bmi      _fdel_ende

 bra.b    _fdel_clear
* Alle Cluster der Datei werden als geloescht (0) markiert
_fdel_nxtcl:
 move.l   a5,a0                    ; DMD
 move.l   d6,d0                    ; cluster
 bsr      FAT_read
 bmi      _fdel_ende
 moveq    #-1,d1
 move.l   d1,d_1stfree_cl(a5)      ; Cache fuer freien Cluster loeschen!!
 move.l   d0,d7
 move.l   a5,a0
 moveq    #0,d1
 move.l   d6,d0
 bsr      FAT_write
 bmi      _fdel_ende               ; Schreibfehler
 addq.l   #1,d_nfree_cl(a5)        ; Anzahl freier Cluster erhoeht!
 bne.b    _fdel_clear              ; war nicht -1
 subq.l   #1,d_nfree_cl(a5)        ; war -1, bleibt -1
_fdel_clear:
 move.l   d7,d6
 beq.b    _fdel_endcl
 tst.b    d_flag(a5)
 bge.b    _fdel_f12_16
 cmpi.l   #$ffffff0,d7
 bcs.b    _fdel_nxtcl
 bra.b    _fdel_ende
_fdel_f12_16:
 cmpi.w   #$fff0,d7
 bcs.b    _fdel_nxtcl
_fdel_endcl:
_fdel_ende:
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,d6/d7/a5
 rts


**********************************************************************
*
* long dosf_seek( a0 = FD *file, d0 = long offs, d1 = int smode)
*
* Normale Datei, ich muss mich um die Umrechnung von smode selbst
* kuemmern
*

dosf_seek:
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d2
 tst.w    d1                       ; mode
 beq.b    fsk_beg                  ; 0: vom Anfang an
 subq.w   #1,d1
 bne.b    fsk_end
 add.l    fd_fpos(a0),d0           ; 1: von aktueller Position
 bra.b    fsk_beg
fsk_end:
 subq.w   #1,d1
 bne      dfsk_einvfn              ; nicht 0/1/2
 add.l    d2,d0                    ; 2: vom Ende
fsk_beg:
 movem.l  d4/d5/d6/d7/a4/a5,-(sp)

 move.l   d2,a1
 jsr      appl_begcritic           ; aendert nur d2/a2
 move.l   a1,d2

 movea.l  a0,a5                    ; FD
 move.l   d0,d7                    ; pos
 bmi      dfsk_erange

* Wenn Position > Dateilaenge: Fehler

 cmp.l    d2,d7
 bgt      dfsk_erange
 movea.l  fd_dmd(a5),a4
 tst.l    d7
 bne.b    dfsk_not0

* Wenn Position == 0 : FD.cloffs = 0, d5 = 0

 moveq    #0,d5                         ; erster Cluster
 clr.w    fd_clpos(a5)                  ; und Offset 0
 bra      dfsk_ende_ok

* Wenn FD.cloffs == 0 oder FD.cloffs == Clustergroesse: d2 = 1
* sonst                                               d2 = 0

dfsk_not0:
 moveq    #1,d2
 tst.w    fd_clpos(a5)
 beq.b    dfsk_clbegcheck_weiter
 move.w   fd_clpos(a5),d0
 cmp.w    d_clsizb(a4),d0               ; Clustergroesse in Bytes
 beq.b    dfsk_clbegcheck_weiter
 moveq    #0,d2                         ; bin nicht an Clusteranfang/Ende
dfsk_clbegcheck_weiter:
 move.l   d7,d0
 lea      f_masks(pc),a0
 movea.w  d_lclsizb(a4),a1
 adda.w   a1,a1
 move.w   0(a0,a1.w),d1
 ext.l    d1
 and.l    d1,d0
 move.w   d0,fd_clpos(a5)               ; "Divisionsrest" ist Offset
 move.l   d7,d0                         ; neue Position in Bytes
 move.w   d_lclsizb(a4),d1
 lsr.l    d1,d0                         ; umrechnen in Cluster
 move.l   d0,d6                         ; d6 := neuer rel. Cluster
 tst.l    fd_Lccl(a5)
 beq.b    dfsk_fromstart                ; Beginne bei Startcluster
 cmp.l    fd_fpos(a5),d7
 blt.b    dfsk_fromstart                ; rueckwaerts => ab Startcluster
 move.l   fd_fpos(a5),d0                ; rel. Position in Bytes
 move.w   d_lclsizb(a4),d1              ; 2er Log. fuer Clustergroesse in Bytes
 lsr.l    d1,d0                         ; => rel. Position in Clustern
 sub.l    d0,d6
 add.l    d2,d6                         ; d6 := Clusterdiff alt/neu
 move.l   fd_Lccl(a5),d5
 bra.b    dfsk_fromboth
dfsk_fromstart:
 move.l   fd_multi1(a5),a1
 move.l   fd_Lstcl(a1),d5          ; Startcluster
dfsk_fromboth:

 moveq    #1,d4
 bra.b    dfsk_clusterloop_next
dfsk_clusterloop:
 move.l   a4,a0
 move.l   d5,d0
 bsr      FAT_read
 bmi      dfsk_ende                ; Lesefehler
 cmpi.l   #-1,d0
 beq      dfsk_erange              ; Ende der Verkettungsliste
 move.l   d0,d5
 addq.l   #1,d4
dfsk_clusterloop_next:
 cmp.l    d6,d4
 blt.b    dfsk_clusterloop

 tst.w    fd_clpos(a5)
 beq.b    dfsk_ende_ok
 tst.l    d6
 beq.b    dfsk_ende_ok
 move.l   a4,a0
 move.l   d5,d0
 bsr      FAT_read
 bmi      dfsk_ende                ; Lesefehler
 cmpi.l   #-1,d0
 beq      dfsk_erange              ; Ende der Verkettungsliste
 move.l   d0,d5

* Felder besetzen und Ende

dfsk_ende_ok:
 move.l   d5,fd_Lccl(a5)           ; rel. Clusternummer
 move.w   d_lclsiz(a4),d0
 lsl.l    d0,d5                    ;  * Clustergroesse in Sektoren
 move.l   d5,fd_Lcsec(a5)          ;  = Sektornummer
 move.l   d7,fd_fpos(a5)
 move.l   d7,d0
dfsk_ende:
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4
;     DEB  '_fseek ENDE'
 rts
dfsk_einvfn:
 moveq    #EINVFN,d1
 rts
dfsk_erange:
 moveq    #ERANGE,d0
 bra      dfsk_ende


**********************************************************************
*
* long dosf_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                            d1 = long apcode );
*

dosf_stat:
 tst.w    d0
 bne.b    dosf_w
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d1
 cmp.l    fd_fpos(a0),d1
 bls.b    dosf_not                      ; EOF
 bra      dosf_yes

dosf_w:
 tst.l    fd_Lccl(a0)
 bmi.b    dosf_not                      ; Disk voll

dosf_yes:
 moveq    #1,d0
dosf_ende:
 move.l   a1,d1
 beq.b    dosf_ende2
 move.l   d0,(a1)
dosf_ende2:
 rts
dosf_not:
 moveq    #0,d0
 bra      dosf_ende


**********************************************************************
*
* long dosf_close(a0 = FD *f)
*

dosf_close:
 move.l   bufl_wback.l,d0       ; writeback aktiviert ?
 bne      _fcl_nix            ; nein, return(E_OK)
 movem.l  a3/a4,-(sp)
 jsr      appl_begcritic      ; aendert nur d2/a2

* Beide Pufferlisten werden vollstaendig zurueckgeschrieben
* (auf allen Laufwerken !!)

 lea      (bufl+4).w,a3
_fclo_nxtlst:

* a4 = BCB

 move.l   (a3),a4
 bra.b    _fclo_l1

* b_dirty == TRUE ?

_fclo_nxtbcb:
 tst.w    xb_dirty(a4)
 beq.b    _fclo_l2

* Nur zurueckschreiben, wenn geaendert

 move.l   a4,a0
 bsr      write_sector
 bmi      _fcl_ende
_fclo_l2:
 move.l   xb_next(a4),a4
_fclo_l1:
 move.l   a4,d0
 bne.b    _fclo_nxtbcb
 subq.l   #4,a3
 cmpa.l   #bufl,a3
 bcc.b    _fclo_nxtlst

 moveq    #0,d0                    ; keine Aktionen, kein Fehler
_fcl_ende:
 jsr      appl_endcritic      ; aendert nur d2/a2
 movem.l  (sp)+,a3/a4
 rts
_fcl_nix:
 moveq    #0,d0
 rts


**********************************************************************
*
* void adjust_fp(a0 = FD *file, d0 = long count, d1 = char flag)
*  Wird nur von f_frw() aufgerufen
*  Justiert den Dateizeiger von <FD>, wenn <count> Bytes
*  gelesen wurden.
*  Wenn <flag> = TRUE, wird nicht nur der Dateizeiger, sondern
*  auch die Pos. rel. zum Clusteranfang justiert.
*  Wird ueber das Dateiende hinaus geschrieben (Lesen blockt _fread() ab),
*  wird die Dateilaenge erhoeht und das "dirty"- Flag des FD gesetzt.
*

adjust_fp:
 add.l    d0,fd_fpos(a0)           ; Dateizeiger weitersetzen
 tst.b    d1                       ; clpos aendern ?
 beq.b    adjfp_nocl               ; nein
 add.w    d0,fd_clpos(a0)
adjfp_nocl:
 move.l   fd_fpos(a0),d0
 move.l   fd_multi1(a0),a1         ; fd_len aus dem Prototyp-FD !
 cmp.l    fd_len(a1),d0
 bls.b    adjfp_ende
* Ueber Dateiende hinausgeschossen: Dateilaenge entsprechend erhoehen
* und "dirty"- Flag des FD setzen
 move.l   d0,fd_len(a1)
 bset     #0,fd_dirch(a1)
adjfp_ende:
 rts


**********************************************************************
*
* MI/PL long f_frw(d1 = int writeflag, a0 = FD *file, d0 = long count,
*            a1 = char *buffer, void (*fn)())
*
*  Normalerweise wird (*fn) zum Kopieren der Daten aus dem Puffer
*  aufgerufen.
*
*  Ist <buffer> == NULL, bekommt man einen Zeiger auf die
*  gelesenen Bytes.
*
*  f_frw() wird nur bei DOS- Dateien aufgerufen, andere Dateitypen
*  wurden bereits abgefangen.
*  f_frw() wird nicht fuer den FD der Root aufgerufen, d.h. alle
*  Clusterangaben sind gueltig und nicht Pseudo.
*
*  Achtung: Es muss sichergestellt werden, dass die Daten nach
*           Beendigung des Vorgangs noch zur Verfuegung stehen,
*           d.h. beim Freigeben der Semaphore darf keine andere
*           Applikation Rechenzeit bekommen!
*
*    d1:    int writeflag
*    a0:    FD
*    d0:    long count
*    a1:    buffer
* 8(a6):    (*fn)()
*

ncopy           =       $08

startpos        =       -$04
sysbuf          =       -$08
ssave           =       -$0C
ccount          =       -$10
state           =       -$12

f_frw:
 link     a6,#state
 movem.l  d3-d7/a3-a5,-(sp)        ; C-Register retten
 subq.w   #4,sp                    ; Parameter-Platz

 jsr      appl_begcritic           ; aendert nur a2/d2

 move.l   d0,d7                    ; Anzahl Bytes
 beq      frw_ende                 ; 0 Bytes, fertig
 movea.l  a0,a4                    ; FD
 movea.l  fd_dmd(a4),a5

 movea.l  a1,a3                    ; Datenpuffer
 move.w   d1,d6                    ; Flag: Schreiben/Lesen
 move.l   fd_fpos(a4),startpos(a6) ; Position merken

 moveq    #0,d5                    ; long
 move.w   fd_clpos(a4),d5          ; Byte-Offset im Cluster
 move.w   d5,d4
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d5                    ; Sektor-Offset im Cluster
 add.l    fd_Lcsec(a4),d5          ; + akt. Sektornummer
 and.w    d_mrecsiz(a5),d4         ; Byte-Offset im Sektor
 beq      frw_off0                 ; noch nichts drin

*
* Restbytes im Sektor
*

 moveq    #0,d3                    ; unsigned
 move.w   d_recsiz(a5),d3
 sub.w    d4,d3                    ; Byte-Rest im Sektor
 cmp.l    d7,d3                    ; mehr als noetig ?
 bls      frw_min1                 ; nein
 move.l   d7,d3                    ; Minimum bestimmen

frw_min1:

 move.w   d6,(sp)                  ; wflag
 lea      (bufl+4).w,a0            ; Pufferliste
 moveq    #0,d2                    ; kein gespiegelter Sektor
 move.l   d5,d1
 add.l    d_Ldoff(a5),d1           ; DOS-Sektornummer + Offset
 move.w   d_drive(a5),d0
 bsr      read_sector
 bmi      frw_ende                 ; Lesefehler

 move.l   d0,sysbuf(a6)            ; -> Sektor

 st       d1                       ; Update-Flag
 move.l   d3,d0                    ; bearbeitete Menge
 move.l   a4,a0
 bsr      adjust_fp                ; Dateiposition erhoehen

 moveq    #0,d0                    ; unsigned
 move.w   d4,d0                    ; Byte-Offset im Sektor
 add.l    sysbuf(a6),d0            ; Position im Puffer
 move.l   a3,d1                    ; Puffer angegeben ?
 beq      frw_ende                 ; nein, Zeiger zurueckgeben

 move.l   a3,a1                    ; -> Puffer
 move.l   d0,a0                    ; Quelle
 move.w   d3,d0                    ; Anzahl Bytes
 movea.l  ncopy(a6),a2             ; -> Kopier-Routine
 jsr      (a2)                     ; Bytes kopieren

 sub.l    d3,d7                    ; Anzahl korrigieren
 beq      frw_finish               ; alles bearbeitet
 adda.l   d3,a3                    ; Puffer weiterzaehlen
 addq.l   #1,d5                    ; Sektor erhoehen

*
* ENDE: Restbytes im Sektor
*

frw_off0:
 move.l   d7,d4                    ; Anzahl Bytes
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d4                    ; Anzahl ganzer Sektoren
 beq      frw_off3                 ; nur noch Rest vorhanden

*
* ganze Sektoren
*

 move.w   d5,d0                    ; Sektornummer (nur Loword)
 and.w    d_mclsiz(a5),d0          ; Cluster voll/leer ?
 beq      frw_off1                 ; ja, neuen beginnen

*
* Sektorrest im Cluster
*

 moveq    #0,d3                    ; unsigned
 move.w   d_clsiz(a5),d3           ; Sektoren/Cluster
 sub.w    d0,d3                    ; Restsektoren im Cluster
 cmp.l    d4,d3                    ; mehr als noetig ?
 bls      frw_min2                 ; nein
 move.l   d4,d3                    ; Minimum nehmen

frw_min2:

 move.w   d6,(sp)                  ; rwflag
 lea      (bufl+4).w,a1            ; XBCB *
 move.l   a3,a0                    ; -> Puffer
 move.l   d3,d2                    ; Anzahl
 move.l   d5,d1
 add.l    d_Ldoff(a5),d1           ; DOS-Sektornummer + Offset
 move.w   d_drive(a5),d0           ; drv
 bsr      mrw_sectors
 bmi      frw_ende

 move.l   d3,d1                    ; Sektor-Anzahl
 move.w   d_lrecsiz(a5),d0
 lsl.l    d0,d1                    ; Byte-Anzahl berechnen
 adda.l   d1,a3                    ; Puffer erhoehen
 sub.l    d1,d7                    ; Anzahl korrigieren
 sub.l    d3,d4                    ; verbleibende Sektoren

 move.l   d1,d0                    ; Anzahl Bytes
 st       d1                       ; Update-Flag
 move.l   a4,a0
 bsr      adjust_fp                ; Dateiposition erhoehen

*
* ENDE: Restsektoren im Cluster
*

frw_off1:
 move.l   d4,d3                    ; verbleibende Sektoren
 move.w   d_lclsiz(a5),d0
 lsr.l    d0,d3                    ; ganze Cluster
 beq      frw_off2                 ; keine mehr

*
* ganze Cluster
*

 move.l   d3,ccount(a6)            ; Cluster-Zaehler
 lsl.l    d0,d3                    ; Anzahl Sektoren darin
 sub.l    d3,d4                    ; verbleibende Sektoren
 move.l   d4,ssave(a6)             ; restliche Sektoren merken

 moveq    #0,d5                    ; Anzahl Bytes
 moveq    #0,d4                    ; Sektor-Zaehler
 moveq    #0,d3                    ; Sektor-Nummer

frw_newclu0:
 move.w   d6,d0                    ; wflag
 move.l   a4,a0
 bsr      f_extend                 ; neuen Cluster beschaffen
 bmi      frw_ende                 ; Schreibfehler

 move.w   d0,state(a6)             ; Status merken
 bne.b    frw_not_cont             ; hat nicht geklappt (Disk voll)

 move.l   d4,d0                    ; Anzahl Sektoren
 add.l    d3,d0                    ; hoechste Sektornummer
 cmp.l    fd_Lcsec(a4),d0          ; zusammenhaengend ?
 bne.b    frw_not_cont             ; nein

frw_cont:
 moveq    #0,d0                    ; unsigned
 move.w   d_clsiz(a5),d0
 add.l    d0,d4                    ; Zaehler erhoehen
 move.w   d_clsizb(a5),d0          ; Bytes/Cluster
 add.l    d0,d5                    ; Anzahl Bytes erhoehen
 subq.l   #1,ccount(a6)            ; noch weiter ?
 bne      frw_newclu0              ; ja

frw_not_cont:
 tst.l    d4                       ; Sektoren vorhanden ?
 beq      frw_no_sects             ; nein

 move.w   d6,(sp)                  ; rwflag
 lea      (bufl+4).w,a1            ; XBCB *
 move.l   a3,a0                    ; -> Puffer
 move.l   d4,d2                    ; Anzahl
 move.l   d3,d1
 add.l    d_Ldoff(a5),d1           ; DOS-Sektornummer + Offset
 move.w   d_drive(a5),d0           ; drv
 bsr      mrw_sectors
 bmi      frw_ende

 sf       d1                       ; Update-Flag
 move.l   d5,d0                    ; Zuwachs
 move.l   a4,a0
 bsr      adjust_fp                ; Datei-Position erhoehen

 adda.l   d5,a3                    ; Pufferzeiger erhoehen
 sub.l    d5,d7                    ; Anzahl korrigieren

frw_no_sects:
 tst.w    state(a6)                ; Abbruch ?
 bne      frw_finish               ; ja

 move.l   fd_Lcsec(a4),d3          ; Sektornummer uebernehmen
 moveq    #0,d4                    ; zuruecksetzen
 moveq    #0,d5                    ; zuruecksetzen
 tst.l    ccount(a6)               ; noch weiter ?
 bne      frw_cont                 ; ja

 move.l   ssave(a6),d4             ; Sektorzaehler zurueck

*
* ENDE: ganze Cluster
*

frw_off2:
 tst.l    d4                       ; weitere Sektoren ?
 beq      frw_off3                 ; nein

*
* Restsektoren
*

 move.w   d6,d0                    ; wflag
 move.l   a4,a0
 bsr      f_extend                 ; neuen Cluster besorgen
 bmi      frw_ende                 ; Schreibfehler
 tst.w    d0                       ; erfolgreich ?
 bne      frw_finish               ; nein

 move.w   d6,(sp)                  ; rwflag
 lea      (bufl+4).w,a1            ; XBCB *
 move.l   a3,a0                    ; -> Puffer
 move.l   d4,d2                    ; Anzahl
 move.l   fd_Lcsec(a4),d1
 add.l    d_Ldoff(a5),d1           ; DOS-Sektornummer + Offset
 move.w   d_drive(a5),d0           ; drv
 bsr      mrw_sectors
 bmi      frw_ende

 move.w   d_lrecsiz(a5),d0
 move.l   d4,d1                    ; Anzahl Sektoren
 lsl.l    d0,d1                    ; Bytes darin
 adda.l   d1,a3                    ; Pufferzeiger erhoehen
 sub.l    d1,d7                    ; Anzahl korrigieren

 move.l   d1,d0                    ; Anzahl Bytes
 st       d1                       ; Update-Flag
 move.l   a4,a0
 bsr      adjust_fp                ; Datei-Position erhoehen

*
* Ende: Restsektoren
*

frw_off3:
 tst.l    d7                       ; noch etwas uebrig ?
 beq      frw_finish               ; nein

*
* Restbytes
*

 moveq    #0,d4                    ; unsigned long
 move.w   fd_clpos(a4),d4          ; Bytes im Cluster
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d4                    ; Sektor-Offset
 beq      frw_newclu1              ; Cluster ist leer
 cmp.w    d_clsiz(a5),d4           ; Cluster voll ?
 bne      frw_off4                 ; nein, noch Platz

frw_newclu1:
 move.w   d6,d0                    ; wflag
 move.l   a4,a0
 bsr      f_extend                 ; Folgecluster beschaffen
 bmi      frw_ende
 tst.w    d0                       ; erfolgreich ?
 bne      frw_finish               ; nein
 moveq    #0,d4                    ; Sektor-Offset 0

frw_off4:
 add.l    fd_Lcsec(a4),d4          ; Record berechnen

 move.w   d6,(sp)                  ; wflag
 lea      (bufl+4).w,a0            ; Pufferliste
 moveq    #0,d2                    ; kein gespiegelter Sektor
 move.l   d4,d1
 add.l    d_Ldoff(a5),d1           ; DOS-Sektornummer + Offset
 move.w   d_drive(a5),d0
 bsr      read_sector
 bmi      frw_ende                 ; Lesefehler

 move.l   d0,sysbuf(a6)            ; -> Puffer

 st       d1                       ; Update-Flag
 move.l   d7,d0                    ; Anzahl Bytes
 move.l   a4,a0
 bsr      adjust_fp                ; Dateiposition erhoehen

 move.l   sysbuf(a6),d0            ; Puffer zurueck
 move.l   a3,d1                    ; Puffer angegeben ?
 beq      frw_ende                 ; nein

 move.l   a3,a1                    ; Puffer
 move.l   d0,a0                    ; Quelle
 move.w   d7,d0                    ; Anzahl Bytes
 movea.l  ncopy(a6),a2             ; Kopierroutine
 jsr      (a2)                     ; Bytes kopieren

frw_finish:
 move.l   fd_fpos(a4),d0           ; neue Dateiposition
 sub.l    startpos(a6),d0          ; - Startposition

frw_ende:
 jsr      appl_endcritic           ; aendert nur a2/d2

 addq.w   #4,sp                    ; Parameter-Platz
 tst.l    d0                       ; MI, wenn Fehler
 movem.l  (sp)+,d3-d7/a3-a5
 unlk     a6
 rts


**********************************************************************
*
* long Fshrink(a0 = FD *file)
*
*  Wird von dosf_write() aufgerufen
*  Kappt Datei auf aktuelle Position zusammen.
*
* aus KAOS 1.2, aber laut TOS 1.4 werden defekte Cluster nicht
* freigegeben
*

Fshrink:
 movem.l  a4/a5/d7/d6,-(sp)
 jsr      appl_begcritic           ; aendert nur d2/a2

 moveq    #0,d0                    ; E_OK
 move.l   a0,a5                    ; FD
 move.l   fd_dmd(a5),a4            ; DMD
 move.l   fd_fpos(a5),d1
 move.l   fd_multi1(a5),a1
 cmp.l    fd_len(a1),d1
 bcc      fsh_ende                 ; Laenge ist bereits == akt. Pos.
 cmpa.l   a5,a1
 bne      fsh_eaccdn               ; Datei nochmal geoeffnet !
 btst     #BOM_WPERM,fd_mode+1(a5)
 beq      fsh_eaccdn               ; keine Schreiberlaubnis

 move.l   a4,a0
 bsr      set_disk_dirty           ; Info-Sektor- Daten ungueltig machen
 bmi      fsh_ende

 move.l   fd_Lccl(a5),d7           ; aktueller Cluster
 bne.b    fsh_not_st

* aktueller Cluster = 0 => Am Dateianfang, alles loeschen

 move.l   fd_Lstcl(a5),d7          ; Anfangscluster
 bra.b    fsh_clear

* Wir sind nicht am Dateianfang. Wir bestimmen den Nachfolger
* des aktuellen Clusters und markieren dann das Dateiende

fsh_not_st:
 moveq    #-1,d0
 cmp.l    d0,d7                    ; EOF?
 beq      fsh_ende                 ; ja
 move.l   d7,d6                    ; aktuellen Cluster merken
 move.l   a4,a0                    ; DMD
 move.l   d6,d0                    ; cluster
 bsr      FAT_read
 bmi      fsh_ende                 ; Lesefehler
 move.l   d0,d7                    ; Nachfolger ist erster zu loeschender
 move.l   a4,a0
 moveq    #-1,d1
 move.l   d6,d0                    ; aktueller ist Dateiende
 bsr      FAT_write
 bmi      fsh_ende
 bra.b    fsh_clear

* Alle Cluster der Datei werden als geloescht (0) markiert

fsh_nxtcl:
 move.l   a4,a0                    ; DMD
 move.l   d6,d0                    ; cluster
 bsr      FAT_read
 bmi      fsh_ende
 move.l   d0,d7
 move.l   a4,a0
 moveq    #0,d1
 move.l   d6,d0
 bsr      FAT_write
 bmi      fsh_ende
fsh_clear:
 moveq    #-1,d1
 move.l   d1,d_1stfree_cl(a4)      ; Cache fuer freien Cluster loeschen!
 addq.l   #1,d_nfree_cl(a4)        ; Anzahl freier Cluster erhoeht!
 bne.b    fsh_wasvalid             ; war nicht -1
 subq.l   #1,d_nfree_cl(a4)        ; war -1, bleibt -1
fsh_wasvalid:
 move.l   d7,d6
 beq.b    fsh_end1

 tst.b    d_flag(a4)
 bge.b    fsh_f12_16
 cmpi.l   #$ffffff0,d7
 bcs.b    fsh_nxtcl
 bra.b    fsh_end1
fsh_f12_16:
 cmpi.w   #$fff0,d7
 bcs.b    fsh_nxtcl

fsh_end1:
 move.l   fd_fpos(a5),fd_len(a5)   ; Dateilaenge = Dateiposition
 bne.b    fsh_no0
 clr.l    fd_Lstcl(a5)
fsh_no0:
 bset     #0,fd_dirch(a5)          ; Dirty- Flag setzen fuer FD geaendert
 move.w   dos_time.l,d1
 ror.w    #8,d1
 move.w   d1,fd_time(a5)
 move.w   dos_date.l,d1
 ror.w    #8,d1
 move.w   d1,fd_date(a5)
/*
 addq.w   #1,fd_refcnt(a5)         ; wird von dosxfs_fclose dekrementiert
 move.l   fd_dev(a5),a2
 move.l   dev_close(a2),a2
 move.l   a5,a0
 jsr      (a2)                     ; FD- Eintrag aktualisieren
*/
fsh_ende:
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,d7/d6/a5/a4
 rts
fsh_eaccdn:
 moveq    #EACCDN,d0
 bra.b    fsh_ende


**********************************************************************
*
* MI/PL long f_extend(a0 = FD *file, d0 = int writeflag)
*
*  Setzt den Dateipointer (falls moeglich) auf den naechsten Cluster der
*  Datei. Erweitert <file>, falls noetig und moeglich.
*  Rueckgabe: -1 Fehler            EQ oder PL
*            <0 BIOS- Fehler       MI
*             0 ok                 EQ oder PL
*
* Die Sperrung mit appl_beg/endcritic muss VOR Aufruf dieser
* Funktion erfolgen!
*

f_extend:
 movem.l  d3/d5/d6/d7/a4/a5/a6,-(sp)
 move.w   d0,-(sp)                 ; flag merken
 movea.l  a0,a5                    ; a5 := FD
 movea.l  fd_multi1(a5),a6         ; a6 := Prototyp-FD
 movea.l  fd_dmd(a6),a4            ; a4 := DMD
 move.l   fd_Lccl(a5),d6           ; d6 := aktueller Cluster
 beq.b    fex_stcl                 ; Datei leer, Startcluster nach d5

* Bestimme Folgecluster des aktuellen Clusters

* 1. Fall: Aktueller Cluster ist != 0: Bestimme Folgecluster in d5

 move.l   a4,a0
 move.l   d6,d0
 bsr      FAT_read
 bmi      fex_ende                 ; Lesefehler
 move.l   d0,d5
 bra.b    fex_both

* 2. Fall: Aktueller Cluster ist 0, die Datei ist nicht leer
*          gib Startcluster der Datei nach d5

fex_stcl:
 move.l   fd_Lstcl(a6),d5
 bne.b    fex_both

* 3. Fall: Aktueller Cluster ist 0, die Datei ist leer (Startcluster = 0)
*          schreibe -1 nach d5 (EOF)

 moveq    #-1,d5
fex_both:
 tst.w    (sp)                     ; flag ?
 beq      fex_seeknxt              ; will nur lesen, Dateizeiger korrigieren
 cmpi.l   #-1,d5                   ; am Dateiende ?
 bne      fex_seeknxt              ; nein, nur Dateizeiger korrigieren

* 1. Fall: Aktueller Cluster ist bereits Dateiende. Da wir schreiben sollen,
*          muss die Datei erweitert werden

 move.l   a4,a0
 bsr      set_disk_dirty           ; Info-Sektor- Daten ungueltig machen
 bmi      fex_ende

 tst.b    d_flag(a4)               ; FAT- Typ
 beq.b    fex_fat12                ; 12 Bit, ab d6 suchen   (langsame Methode)

* FAT- Typ 16-Bit oder 32-Bit
* Es muss irgendein freier Cluster gesucht werden. Wenn d6=0 ist, ist
* die Datei leer, und es wird ab Cluster 2 gesucht. Sonst ab d6

 move.l   d6,d0                    ; dies ist der letzte Cluster
 bne.b    fex_was_not_1st          ; Datei ist nicht leer
; Datei leer, benutze den Cache
 move.l   d_1stfree_cl(a4),d0
fex_was_not_1st:
 addq.l   #1,d0                    ; ab einem weiter suchen
 move.l   a4,a0
 bsr      _newcl16_32
 bmi      fex_ende
 move.l   d0,d_1stfree_cl(a4)      ; im Cache merken!!!
 move.l   d0,d5
 bne      fex_found                ; freier gefunden
 bra      fex_eof                  ; kein freier Cluster gefunden

* FAT- Typ 12-Bit
* Suche ab aktuellem Cluster einen freien. Wenn am Ende angelangt, suche
* vorne (ab Cluster 2) weiter
fex_fat12:

* Reservierung freier Cluster einer 12-Bit-FAT
* muss ueber Semaphore laufen

 lea      fat12_sem.l,a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      fex_ende                 ; -1: Reentranz/1: TimeOut (unmoeglich)

 move.l   d_numcl(a4),d3           ; d3 := groesste Clusternummer + 1
 move.l   d3,d7
 subq.l   #2,d7                    ; d7 enthaelt die Anzahl der Cluster
 move.l   d6,d5                    ; d5 ist die Clusternummer
 cmpi.l   #2,d5
 bcc.b    fex_ok
 moveq    #2,d5                    ; mindestens bei 2 anfangen
 bra.b    fex_ok
fex_srchloop:
 move.l   a4,a0
 move.l   d5,d0
 bsr      FAT_read
 bmi      fex_ende12               ; Lesefehler
 tst.l    d0                       ; Cluster frei ?
 beq.b    fex_found12              ; ja !
 addq.l   #1,d5
 cmp.l    d3,d5
 bcs.b    fex_ok
 moveq    #2,d5                    ; wieder vorn anfangen
fex_ok:
 dbra     d7,fex_srchloop

* Keinen freien gefunden, Semaphore freigeben
 moveq    #-1,d0

* Fehler, Semaphore freigeben
fex_ende12:
 move.l   d0,-(sp)
 lea      fat12_sem.l,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehercode von evnt_sem ignorieren
 move.l   (sp)+,d0
 bra      fex_ende                 ; Lesefehler

* freien gefunden, reservieren und Semaphore freigeben
fex_found12:
 move.l   a4,a0
 moveq    #-1,d1
 move.l   d5,d0
 bsr      FAT_write
 bmi      fex_ende12               ; Lesefehler

 lea      fat12_sem.l,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren

fex_found:
 move.l   d_nfree_cl(a4),d0
 addq.l   #1,d0
 beq.b    fex_nfree_invalid        ; Anzahl freier Cluster ist -1
 subq.l   #1,d_nfree_cl(a4)        ; merken, dass ein Cluster weniger frei ist
fex_nfree_invalid:
 tst.l    d6
 beq.b    fex_firstcl
* aktueller Cluster war != 0 => Folgecluster eintragen
 move.l   a4,a0
 move.l   d5,d1
 move.l   d6,d0
 bsr      FAT_write
 bmi      fex_ende                 ; Lesefehler
 bra.b    fex_seeknxt
* aktueller Cluster war == 0 => Startcluster in den FD eintragen
fex_firstcl:
 move.l   d5,fd_Lstcl(a6)
 bset     #0,fd_dirch(a6)

* 2. Fall: lesen, oder Schreiben geht nicht ueber Dateiende hinaus
*                 oder Datei gerade eben erweitert

fex_seeknxt:
 cmpi.l   #-1,d5
 beq.b    fex_ende
* Einfach alle Dateipositionsfelder auf naechsten Cluster (Anfang)
 move.l   d5,fd_Lccl(a5)           ; Clusternummer
 move.w   d_lclsiz(a4),d0
 move.l   d5,d1                    ; unsigned
 lsl.l    d0,d1                    ; -> Sektornummer
 move.l   d1,fd_Lcsec(a5)
 moveq    #0,d0
 move.w   d0,fd_clpos(a5)
fex_ende:
 addq.l   #2,sp
 movem.l  (sp)+,a6/a5/a4/d7/d6/d5/d3
 rts
fex_eof:
 move.l   #$ffff,d0
 bra.b    fex_ende


**********************************************************************
*
* int ilog2(d0 = unsigned int i)
*
* Gibt log2(i) zurueck (i ist 2er- Potenz)
*
* aendert nur d0 und d1
*

ilog2:
 move.w   d0,d1
 moveq    #0,d0
 tst.w    d1
 bra.b    il2_loop_next
il2_loop:
 addq.w   #1,d0
 lsr.w    d1
il2_loop_next:
 bne.b    il2_loop
 subq.w   #1,d0
 rts


f_masks:
 DC.W     0,1,3,7,$f,$1f,$3f,$7f,$ff,$1ff,$3ff,$7ff,$fff,$1fff,$3fff,$7fff


***********************************************
*
* long dosfs_dfree( a0 = DD *d, a1 = long df[4] )
*
* a0 ist ein DD_FD, nicht geoeffnet
*

dosfs_dfree:
 movem.l  d4/d5/d7/a4/a5,-(sp)
 jsr      appl_begcritic           ; aendert nur d2/a2

 move.l   fd_dmd(a0),a4            ; a4 = DMD
 move.l   a1,a5                    ; a5 = long df[4]

 move.l   d_nfree_cl(a4),d5        ; Anzahl freier Cluster schon bestimmt?
 bge.b    dfr_setdi                ; ja, einfach zurueckgeben

 moveq    #0,d5
 move.l   d_numcl(a4),d4           ; d4 = Nr. des hoechsten Clusters + 1
 tst.b    d_flag(a4)
 beq.b    dfr_FAT12

* IF:    FAT- Typ 16-Bit oder 32-Bit

 move.l   d4,d0                    ; maxcl
 move.l   a4,a0                    ; DMD
 bsr      _dfree16_32
 bmi      dfr_ende
 move.l   d0,d5
 bra.b    dfr_endif

* ELSE:  FAT- Typ 12-Bit

dfr_FAT12:
 moveq    #2,d7                    ; erste Clusternummer
 bra.b    dfr_nextloop
dfr_loop:
 move.l   a4,a0
 move.l   d7,d0
 bsr      FAT_read
 bmi      dfr_ende                 ; Lesefehler
 tst.l    d0
 bne.b    dfr_used
 addq.l   #1,d5                    ; freien Cluster gefunden
dfr_used:
 addq.l   #1,d7
dfr_nextloop:
 cmp.l    d4,d7
 bcs.b    dfr_loop

* ENDIF

dfr_endif:
 move.l   d5,d_nfree_cl(a4)        ; Cache fuer Anzahl freier Cluster

dfr_setdi:
 move.l   d5,(a5)+                 ; Anzahl freier Cluster
 move.l   d_numcl(a4),d0
 btst.b   #5,config_status+3.w
 bne.b    no_minus2
 subq.l   #2,d0                    ; Korrekturpatch
no_minus2:
 move.l   d0,(a5)+                 ; Anzahl Cluster ueberhaupt
 moveq    #0,d0
 move.w   d_recsiz(a4),d0          ; Bytes pro Sektor
 move.l   d0,(a5)+
 move.w   d_clsiz(a4),d0           ; Sektoren pro Cluster
 move.l   d0,(a5)+
 moveq    #0,d0
dfr_ende:
 jsr      appl_endcritic           ; aendert nur d2/a2
 movem.l  (sp)+,d4/d5/d7/a4/a5
 rts


**********************************************************************
*
* MI/PL long/int _dfree16_32(a0 = DMD *drive, d0 = ULONG maxcl)
*
* NUR BEI 16-Bit FAT oder 32-Bit FAT!
*
* Gib Anzahl freier Cluster bis maxcl zurueck
*
* appl_beg/endcritic ist schon aufgerufen
*

_dfree16_32:
 movem.l  d4-d7/a5,-(sp)
 move.l   d0,d7                    ; Anzahl Cluster
 movea.l  a0,a5                    ; -> DMD
 moveq    #0,d4                    ; Zaehler auf 0
 subq.l   #2,d7
 bcs.b    _df16_fin                ; keine (!)
 move.w   d_recsiz(a5),d5          ; Bytes/Sektor
 moveq    #0,d6                    ; Sektor-Offset 0

 moveq    #0,d1                    ; Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; FAT einlesen
 bmi      _df16_ende
 movea.l  d0,a0                    ; -> FAT
 movea.l  d0,a1
 adda.w   d5,a1                    ; FAT-Ende
 tst.b    d_flag(a5)               ; 16-Bit FAT
 bgt.b    _df16_bloop

* 32-Bit FAT

 addq.w   #8,a0                    ; Eintrag 2
_df32_loop:
 tst.l    (a0)+                    ; Eintrag frei ?
 bne.b    _df32_found1             ; nein
 addq.l   #1,d4                    ; Zaehler erhoehen
_df32_found1:
 subq.l   #1,d7                    ; Cluster-Anzahl
 beq.b    _df16_fin                ; Ende erreicht
 cmpa.l   a1,a0                    ; Sektor-Ende ?
 bcs.b    _df32_loop               ; nein
 bra.b    _df16_nxtsec

* 16-Bit FAT

_df16_bloop:
 addq.w   #4,a0                    ; Eintrag 2
_df16_loop:
 tst.w    (a0)+                    ; Eintrag frei ?
 bne.b    _df16_found1             ; nein
 addq.l   #1,d4                    ; Zaehler erhoehen
_df16_found1:
 subq.l   #1,d7                    ; Cluster-Anzahl
 beq.b    _df16_fin                ; Ende erreicht
 cmpa.l   a1,a0                    ; Sektor-Ende ?
 bcs.b    _df16_loop               ; nein

_df16_nxtsec:
 addq.l   #1,d6                    ; naechster Sektor
 moveq    #0,d1                    ; Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; Fat einlesen
 bmi.b    _df16_ende
 movea.l  d0,a0                    ; -> FAT
 movea.l  d0,a1                    ; Ende
 adda.w   d5,a1                    ; des Sektors

 tst.b    d_flag(a5)               ; 32-Bit FAT ?
 bmi.b    _df32_loop
 bra.b    _df16_loop

_df16_fin:
 move.l   d4,d0                    ; Ergebnis
_df16_ende:
 movem.l  (sp)+,d4-d7/a5
 rts


**********************************************************************
*
* MI/EQ long/int _newcl16_32( a0 = DMD *drive, d0 = ULONG firstcl )
*
* Schnelle Routine zur Reservierung eines neuen Clusters.
* NUR BEI 16-Bit oder 32-Bit FAT!
*
* Gib Nummer des ersten freien Clusters zurueck, suche ab <firstcl>.
* Reserviere ihn, indem -1 in die FAT geschrieben wird.
* D.h. es wird ein neuer Cluster angefordert, der zunaechst als
* Dateiende markiert wird.
*
* appl_beg/endcritic ist schon aufgerufen
*

_newcl16_32:
 movem.l  d3-d7/a5,-(sp)
 movea.l  a0,a5                    ; -> DMD
 move.l   d_numcl(a5),d7           ; d7 := groesste Clusternummer + 1
 cmp.l    d7,d0                    ; Clusternummer zu hoch ?
 bcs.b    _nc16_noov               ; nein
 moveq    #0,d0                    ; wieder vorn anfangen
_nc16_noov:
 subq.l   #2,d7                    ; d7 := groesste Clusternummer - 1
 bcs      _nc16_nofree             ; keine Cluster (!)
 move.w   d_recsiz(a5),d5          ; Bytes/Sektor

 cmpi.l   #2,d0
 bcs.b    _nc16_beg                ; mindestens bei 2 anfangen

 move.l   d0,d4
 move.l   d0,d6                    ; Cluster-Nummer
 add.l    d6,d6                    ; Byte-Offset in FAT (16-Bit FAT)
 tst.b    d_flag(a5)
 bgt.b    _nc16_fat16
 add.l    d6,d6                    ; Byte-Offset in FAT (32-Bit FAT)
_nc16_fat16:
 move.l   d6,d3
 and.w    d_mrecsiz(a5),d3         ; d3 := Byte-Offset im Sektor
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d6                    ; Sektor-Offset in der FAT
 bra.b    _nc16_read

* fange bei Clusternummer 2 an

_nc16_beg:
 moveq    #0,d6                    ; 1. FAT-Sektor
 moveq    #2,d4                    ; 1. Datencluster ist Cluster 2
 moveq    #4,d3                    ; Byte-Offset 4 (16-Bit FAT)
 tst.b    d_flag(a5)
 bgt.b    _nc16_2fat16
 moveq    #8,d3                    ; Byte-Offset 8 (32-Bit FAT)
_nc16_2fat16:

* Beginne die Suche

_nc16_read:
 moveq    #0,d1                    ; Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; FAT einlesen (a0 = XBCB *)
 bmi      _nc16_ende
 movea.l  d0,a2                    ; -> FAT
 movea.l  d0,a1
 adda.w   d5,a1                    ; FAT-Sektor-Ende
 add.w    d3,a2                    ; Byte-Offset innerhalb des Sektors
_nc16_loop:
 tst.b    d_flag(a5)
 bgt.b    _nc16_3fat16
 tst.l    (a2)+                    ; Eintrag belegt (32-Bit FAT)?
 bra.b    _nc16_3endif
_nc16_3fat16:
 tst.w    (a2)+                    ; Eintrag belegt (16-Bit FAT)?
_nc16_3endif:
 beq.b    _nc16_fin                ; nein, gefunden
 subq.l   #1,d7                    ; Cluster-Anzahl
 beq.b    _nc16_nofree             ; Ende erreicht
 addq.l   #1,d4                    ; naechster Eintrag
 cmp.l    d_numcl(a5),d4           ; Ueberlauf ?
 bcc.b    _nc16_beg                ; ja, wieder vorn anfangen
 cmpa.l   a1,a2                    ; Sektor-Ende ?
 bcs.b    _nc16_loop               ; nein

 addq.l   #1,d6                    ; naechster Sektor
 moveq    #0,d1                    ; Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; Fat einlesen (a0 = XBCB *)
 bmi.b    _nc16_ende
 movea.l  d0,a2                    ; -> FAT
 movea.l  d0,a1                    ; Ende
 adda.w   d5,a1                    ; des Sektors
 bra.b    _nc16_loop

* keinen freien Cluster gefunden: return(0), Flags == EQ

_nc16_nofree:
 moveq    #0,d0                    ; nichts frei
 bra.b    _nc16_ende

* freien Cluster gefunden. Auf -1 setzen!
* return(cl), Flags == PL/NE

_nc16_fin:
 moveq    #-1,d0
 tst.b    d_flag(a5)
 bgt.b    _nc16_4fat16
 move.l   d0,-(a2)                 ; Eintrag auf -1 setzen (32-Bit FAT)
 bra.b    _nc16_4endif
_nc16_4fat16:
 move.w   d0,-(a2)                 ; Eintrag auf -1 setzen
_nc16_4endif:
 st       xb_dirty(a0)             ; und dirty-Flag fuer Puffer setzen
 move.l   d4,d0                    ; Ergebnis
 moveq    #0,d1                    ; N-Flag loeschen
_nc16_ende:
 movem.l  (sp)+,d3-d7/a5
 rts


**********************************************************************
**********************************************************************
*
* FAT- Zugriff
*
**********************************************************************
**********************************************************************
*
* PL/MI char *FAT_rw(d6 = long secnr, a5 = DMD *drv, d1 = int to_write)
*
*   d6  : int secnr
*   a5  : DMD *drive
*   d1  : int to_write           : Schreibzugriff geplant
*
* -> d0 = Fehlercode oder Zeiger auf gelesenen Sektorpuffer
* wenn d0 > 0:
* -> a0 = Zeiger auf den XBCB
*
* Liest den angegebenen FAT- Sektor. Die Angabe <secnr> ist relativ
* zum Anfang der FAT
* Gibt Zeiger auf den Sektorpuffer oder Fehlercode zurueck.
*

FAT_rw:
 move.w   d1,-(sp)
 move.l   d6,d1
 add.l    d_fatrec(a5),d1          ; relativer Sektor => BIOS- Code (2. FAT)
 move.l   d1,d2                    ; secno2  (1. FAT)
 sub.l    d_fsiz(a5),d2            ; 1. FAT
 cmpi.b   #2,d_flag+1(a5)          ; Anzahl FATs
 beq.b    ftrw_2f                  ; nein, 2 FATs
 moveq    #0,d2                    ; ja, nur 1 FAT
ftrw_2f:
 move.w   d_drive(a5),d0           ; drv
 lea      bufl.w,a0                ; 1. Pufferliste
 bsr      read_sector
 addq.l   #2,sp
 rts


**********************************************************************
*
* LONG FAT_write(d0 = ULONG cluster, d1 = ULONG nextcl, a0 = DMD *drive)
*  Schreibt die Nummer <nextcl> des Folgeclusters von <cluster>
*  in die FAT
*

FAT_write:
     IFNE NOWRITE
 moveq    #EWRPRO,d0
 rts
     ENDIF

; DEBL     d0,'FAT_write: cl = '
; DEBL     d1,'FAT_write: nx = '
; DEB      ' '

 movem.l  d4-d7/a5,-(sp)
 move.l   d0,d7                    ; Cluster-Nummer
 move.l   d1,d4                    ; nextcl (Folgecluster)
 movea.l  a0,a5                    ; -> DMD

 move.l   d7,d1
 tst.b    d_flag(a5)               ; 16-Bit FAT ?
 bgt.b    ftw_fat_16               ; ja
 beq.b    ftw_fat_12
 add.l    d1,d1
 add.l    d1,d1                    ; * 4 fuer 32-Bit FAT
 bra.b    ftw_fat_all
ftw_fat_12:
 lsr.l    #1,d1                    ; * 0,5
ftw_fat_16:
 add.l    d7,d1
ftw_fat_all:
 move.l   d1,d5                    ; Byte-Offset in FAT
 and.w    d_mrecsiz(a5),d5         ; Byteoffset im Sektor
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d1                    ; Sektor-Offset in FAT
 move.l   d1,d6                    ; merken
 moveq    #1,d1                    ; schreiben
;move.l   a5,a5
;move.l   d6,d6                    ; Record
 bsr      FAT_rw                   ; FAT einlesen
 bmi      ftw_ende                 ; Lesefehler
 movea.l  d0,a0                    ; -> FAT
 adda.w   d5,a0                    ; + Byte-Offset
 tst.b    d_flag(a5)               ; 12-Bit FAT ?
 beq.b    ftw_wfat_12              ; ja
 bgt.b    ftw_wfat_16
 andi.l   #$0fffffff,d4            ; auf 28 Bit reduzieren (!!!)
 ror.w    #8,d4                    ; neuer Eintrag 68000 -> Intel
 swap     d4
 ror.w    #8,d4
 move.l   d4,(a0)                  ; 32-Bit FAT
 bra      ftw_ok
ftw_wfat_16:
 ror.w    #8,d4                    ; neuer Eintrag 68000 -> Intel
 move.w   d4,(a0)                  ; einfach eintragen
 bra      ftw_ok                   ; und fertig
ftw_wfat_12:
 and.w    #$0fff,d4                ; 12 Bit ausblenden
 ror.w    #8,d4                    ; neuer Eintrag 68000 -> Intel
 btst     #0,d7                    ; gerade Nummer ?
 bne      ftw_odd1                 ; nein
 move.w   d4,d0
 lsr.w    #8,d0                    ; High-Byte
 move.b   d0,(a0)+                 ; direkt eintragen
 bra      ftw_second
ftw_odd1:
 rol.w    #4,d4                    ; zurechtschieben
 move.w   d4,d0
 lsr.w    #8,d0                    ; High-Byte
 andi.b   #$0f,(a0)                ; 4 Bit uebernehmen
 or.b     d0,(a0)+                 ; 4 Bit einblenden
ftw_second:
 cmp.w    d_mrecsiz(a5),d5         ; letzes Byte im Sektor ?
 bcs      ftw_in_buffer            ; nein
 addq.l   #1,d6                    ; naechster Sektor
 moveq    #1,d1                    ; schreiben
;move.l   a5,a5
;move.l   d6,d6                    ; Record
 bsr      FAT_rw                   ; FAT einlesen
 bmi      ftw_ende
 movea.l  d0,a0                    ; -> FAT
ftw_in_buffer:
 btst     #0,d7                    ; gerade Nummer ?
 bne      ftw_odd2                 ; nein
 move.b   (a0),d0                  ; Byte uebernehmen
 and.b    #$f0,d0                  ; 4 Bit
 or.b     d0,d4                    ; einblenden
ftw_odd2:
 move.b   d4,(a0)                  ; Wert eintragen
ftw_ok:
 moveq    #0,d0                    ; kein Fehler
ftw_ende:
 movem.l  (sp)+,d4-d7/a5
 rts


*********************************************************************
*
* PL/MI LONG FAT_read(d0 = ULONG cluster, a0 = DMD *drive)
*
* Gibt die Nummer des Folgeclusters zurueck (also den entsprechenden
* FAT- Eintrag). EOF-Eintraege werden, unabhaengig vom FAT-Typ, immer
* als -1 zurueckgegeben.
*
* Rueckgabe MI, wenn Fehler.
*

FAT_read:
;     DEBL d0,'FAT_read '
 movem.l  d5-d7/a5,-(sp)
 movea.l  a0,a5                    ; -> DMD
 move.l   d0,d7                    ; Cluster-Nummer
 move.l   d7,d1                    ; Cluster
 tst.b    d_flag(a5)
 bgt.b    ftr_fat_16               ; 16-Bit FAT
 beq.b    ftr_fat_12
 add.l    d1,d1
 add.l    d1,d1                    ; * 4
 bra.b    ftr_fat_all
ftr_fat_12:
 lsr.l    #1,d1                    ; * 0,5
ftr_fat_16:
 add.l    d7,d1                    ; Byte-Offset in FAT
ftr_fat_all:
 move.l   d1,d5
 and.w    d_mrecsiz(a5),d5         ; d5.w: Byte-Offset im Sektor
 move.w   d_lrecsiz(a5),d0
 lsr.l    d0,d1                    ; d1.l: Sektor-Offset berechnen
 move.l   d1,d6                    ; Sektor-Offset in der FAT
 moveq    #0,d1                    ; Modus: Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; FAT einlesen
 bmi      ftr_ende                 ; return(MI)
 movea.l  d0,a0                    ; -> FAT
 adda.w   d5,a0                    ; Byte-Offset
 tst.b    d_flag(a5)               ; 12-Bit FAT ?
 beq.b    ftr_rfat_12              ; ja
 bgt.b    ftr_rfat_16
 move.l   (a0),d0                  ; Folgecluster holen (FAT32)
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0                    ; Intel -> 68000
 andi.l   #$0fffffff,d0            ; oberste 4 Bit loeschen(?!?)
 cmpi.l   #$0ffffff8,d0
 bcs.b    ftr_ok
 bra.b    ftr_eof
ftr_rfat_16:
 moveq    #0,d0                    ; unsigned long
 move.w   (a0),d0                  ; Folgecluster holen (FAT16)
 ror.w    #8,d0                    ; Intel -> 68000
 cmpi.w   #$fff8,d0
 bcs.b    ftr_ok
 bra.b    ftr_eof
ftr_rfat_12:
 move.b   (a0)+,d0                 ; 1. FAT-Byte
 cmp.w    d_mrecsiz(a5),d5         ; letztes Byte im Sektor ?
 bcs.b    ftr_in_buffer            ; nein
 move.w   d0,d5                    ; Wert retten
 addq.l   #1,d6                    ; naechster Record
 moveq    #0,d1                    ; Modus: Lesen
;move.l   a5,a5                    ; -> DMD
;move.l   d6,d6                    ; Sektor-Offset
 bsr      FAT_rw                   ; FAT einlesen
 bmi.b    ftr_ende                 ; return(MI)
 movea.l  d0,a0                    ; -> FAT
 move.w   d5,d0                    ; Wert zurueck
ftr_in_buffer:
 lsl.w    #8,d0                    ; in High-Byte
 move.b   (a0),d0                  ; 2. FAT-Byte
 ror.w    #8,d0                    ; Intel -> 68000
 btst     #0,d7                    ; ungerade ?
 beq.b    ftr_even                 ; nein
 lsr.w    #4,d0                    ; zurechtschieben
ftr_even:
 andi.l   #$00000fff,d0            ; 12 Bit ausblenden
 cmp.w    #$0ff0,d0                ; Ende-Markierung ?
 bcs.b    ftr_ok                   ; nein
ftr_eof:
 moveq    #-1,d0                   ; EOF melden
ftr_ok:
 moveq    #0,d1                    ; N-Flag loeschen
ftr_ende:
 movem.l  (sp)+,d5-d7/a5
;     DEBL d0,'FAT_read =>'
 rts


**********************************************************************
**********************************************************************
*
* Dateiverwaltung, unterste Ebene
*
**********************************************************************

**********************************************************************
*
* EQ/MI long write_sector(a0 = XBCB *buf)
*
*  schreibt einen Sektor der Pufferliste zurueck, falls dieser gueltig
*  ist und sich geaendert hat.
*  Im Gegensatz zu TOS wird nur dieser Sektor zurueckgeschrieben
*  und nicht etwa alle anderen bei dieser Gelegenheit auch. Das
*  Zurueckschreiben aller Sektoren erfolgt sowieso bei dem Schliessen
*  einer Datei.
*
*  Ggf. Semaphorenbehandlung noch beschleunigen!
*  Ggf. Frage, ob Puffer gueltig, entfernen
*  Ggf. noch Unterstuetzung von 32 Bit Sektornummern ergaenzen
*

write_sector:
      DEB  'write_sector'
 tst.w    xb_dirty(a0)             ; Pufferinhalt geaendert ?
 beq      ws_ok                    ; nein
 tst.w    xb_drv(a0)               ; Puffer gueltig
 bmi      ws_ok                    ; nein
 move.l   a6,-(sp)
*
* Semaphore setzen und damit den Sektor schuetzen
*
 move.l   a0,a6
 lea      xb_sem+bl_app(a6),a0
 tst.l    (a0)                     ; Sektor belegt ?
 beq.b    ws_weiter                ; nein, Sektor belegen
*
* Der Sektor ist gerade belegt, wird also beschrieben oder
* gelesen
*
 subq.l   #bl_app,a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      ws_err                   ; -1: Reentranz/1: TimeOut (unmoeglich)
*
* Jetzt haben wir den Sektor, aber sein Inhalt kann sich schon
* wieder geaendert haben.
*
 tst.w    xb_dirty(a6)             ; Pufferinhalt geaendert ?
 beq      ws_ok2                   ; nein
 tst.w    xb_drv(a6)               ; Puffer gueltig
 bmi      ws_ok2                   ; nein
*
* Es hat zwar ein Taskwechsel stattgefunden, aber der Puffer ist immer
* noch gueltig und geaendert.
*
 bra      ws_wr
*
* Der Puffer war nicht belegt, wir koennen ihn einfach belegen
* und dann schreiben, beim Belegen kann kein Taskwechsel
* stattfinden.
*
ws_weiter:
 move.l   act_appl.l,(a0)            ; Semaphore belegen
 move.l   act_pd.l,bl_pd-bl_app(a0)  ; !neu!
*
* Puffer zurueckschreiben
*
ws_wr:
 move.l   xb_secno(a6),d0
 move.l   d0,-(sp)                 ; Sektornummer (long)
 move.w   xb_drv(a6),-(sp)         ; Laufwerknummer
 tst.w    xb_secno(a6)             ; Sektornummer > 65535 ?
 beq.b    ws_wr_short
 move.w   #-1,-(sp)
 bra.b    ws_wr_long
ws_wr_short:
 move.w   d0,-(sp)                 ; Sektornummer (short)
ws_wr_long:
 move.w   #1,-(sp)                 ; 1 Sektor
 move.l   xb_data(a6),-(sp)        ; Datenpuffer
 move.l   #$40001,-(sp)            ; bios Rwabs(1,...)
 trap     #$d
 tst.l    d0
 bne.b    ws_berr                  ; Schreibfehler

* Die Sektornummer der Kopie ist immer < 65535 (FATs liegen vorn)

 move.l   xb_secno2(a6),d1
 beq.b    ws_berr                  ; Sektornummer ist 0
 move.w   d1,10(sp)                ; Sektorkopie (z.B. FAT #1)
 trap     #$d
ws_berr:
 adda.w   #18,sp
 tst.l    d0                       ; Schreibfehler ?
 beq.b    ws_ok1                   ; nein

* Schreibfehler

 move.l   d0,-(sp)                 ; Fehlercode merken
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehercode von evnt_sem ignorieren
 move.l   (sp)+,d0                 ; Fehlercode zurueck

 move.w   xb_drv(a6),d1            ; Fehler-Laufwerk
 move.w   #-1,xb_drv(a6)           ; Puffer ungueltig
 bsr      fatfs_diskerr
 tst.l    d0
 bra.b    ws_ende

*
* dirty- Flag loeschen
*
ws_ok1:
 clr.w    xb_dirty(a6)
ws_ok2:
 tst.l    xb_sem+bl_waiting(a6)    ; Semaphore anderweitig angefordert ?
 bne.b    ws_ok3                   ; ja !
 clr.l    xb_sem+bl_app(a6)        ; einfach nur freigeben
 bra.b    ws_ende
ws_ok3:
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehercode von evnt_sem zurueckgeben
ws_ende:
 move.l   (sp)+,a6
 rts
ws_err:
 moveq    #ERROR,d0
 bra.b    ws_ende
ws_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* EQ/MI char *read_sector(d0 = int drv,
*                         d1 = long secnr, d2 = long secno2
*                         a0 = XBCB *buflist, int to_write)
*
* -> d0 = Fehlercode oder Zeiger auf gelesenen Sektorpuffer
* wenn d0 > 0:
* -> a0 = Zeiger auf den XBCB
*
* Liest einen Sektor <secnr> von Laufwerk <drv> und gibt einen
* Zeiger auf den gelesenen Sektor zurueck.
* in <secno2> wird eine Kopie des Sektors angegeben, etwa fuer eine
* zweite FAT.
*
* Der Zeiger auf den XBCB wird zurueckgegeben, damit ein Programm fuer
* den FAT-Zugriff (Reservierung eines freien Clusters) ohne
* Kontextwechsel einen Cluster reservieren kann.
*
* D.h.
*   - lese Sektor
*   - suche nach 0-Eintrag
*   - setze ihn auf -1 (Dateiende)
* wird nicht unterbrochen.
*
* Ggf. Semaphorenbehandlung vereinfachen.
*

read_sector:
      DEBL  d1,'read sector '
      DEBL  d0,'        drv '
 movem.l  a5/a6/d5/d6/d7,-(sp)
 move.l   d2,d5                    ; d5 = secno2
 move.l   d1,d6                    ; d6 = secno
 move.w   d0,d7                    ; d7 = drv
 move.l   a0,a5                    ; buflist
rs_again:
 suba.l   a1,a1                    ; keinen freien Sektor gefunden
 move.l   (a5),d2
 bra.b    rs_nxtbuf
rs_loop:
 move.l   d2,a6
 move.w   xb_drv(a6),d0
 bmi.b    rs_isfree
 cmp.w    d0,d7
 bne.b    rs_nxt                   ; anderes Laufwerk
 cmp.l    xb_secno(a6),d6
 bne.b    rs_nxt                   ; anderer Sektor
*
* Wir haben einen passenden Sektor gefunden.
* Wir muessen noch sicherstellen, dass der Sektor nicht
* gesperrt ist und ggf. darauf warten.
* Dazu einfach sperren und wieder freigeben.
* Achtung: TOS macht hier ein Mediach(), das ich mir aber sparen will
*
rs_found:
 tst.l    xb_sem+bl_app(a6)        ; Semaphore belegt ?
 beq      rs_return                ; nein, alles OK
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 lea      xb_sem(a6),a0
 jsr      evnt_sem
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren
* Der Sektorinhalt kann sich geaendert haben
 cmp.w    xb_drv(a6),d7
 bne      rs_again                 ; nochmal ganz von vorn
 cmp.l    xb_secno(a6),d6
 bne      rs_again                 ; nochmal ganz von vorn
 bra      rs_return

rs_isfree:
 move.l   a6,a1                    ; a1 ist freier XBCB
rs_nxt:
 move.l   xb_next(a6),d2
rs_nxtbuf:
 bne      rs_loop
*
* keinen passenden Sektor gefunden.
*
 move.l   a1,d2                    ; freien Sektor gefunden ?
 bne.b    rs_read                  ; ja, belegen und benutzen
*
* weder passenden noch freien Sektor gefunden
* schreibe den letzten der Liste zurueck
*
 tst.w    xb_dirty(a6)             ; Pufferinhalt geaendert ?
 bne.b    rs_get                   ; ja, schreiben
 tst.l    xb_sem+bl_app(a6)        ; Sektor belegt ?
 beq      rs_ok                    ; nein
* nichts zu schreiben, aber Sektor ist belegt, auf Freigabe warten
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 lea      xb_sem(a6),a0
 jsr      evnt_sem

* der Puffer gehoert jetzt uns, kann aber inzwischen "dirty" sein.

 tst.w    xb_dirty(a6)             ; Pufferinhalt geaendert ?
 bne.b    rs_free_get              ; ja, freigeben, schreiben, again

* Der Puffer gehoert uns, ist nicht "dirty".
* Es kann aber sein, dass inzwischen
* unser Sektor woanders geladen wurde. Also nochmal die
* Pufferliste durchsuchen

 move.l   (a5),d2
 bra.b    rs2_nxtbuf
rs2_loop:
 move.l   d2,a1
 cmp.w    xb_drv(a1),d7
 bne.b    rs2_nxt                  ; anderes Laufwerk
 cmp.l    xb_secno(a1),d6
 bne.b    rs2_nxt                  ; anderer Sektor
*
* Der Puffer a6 ist noch von uns gesperrt.
* Inzwischen wurde unser Sektor aber im Puffer a1
* angefordert.
* Erstmal Puffer a6 wieder freigeben, dabei kann kein
* Taskwechsel stattfinden, und wir arbeiten jetzt mit
* Puffer a1, der unseren Sektor enthaelt
 lea      xb_sem(a6),a0
 move.l   a1,a6
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren
 bra      rs_found                 ; passenden Sektor gefunden
rs2_nxt:
 move.l   xb_next(a1),d2
rs2_nxtbuf:
 bne      rs2_loop
*
* Der Puffer a6 ist noch von uns gesperrt und nicht "dirty".
* Inzwischen wurde unser Sektor nicht woanders angefordert.
* Wir behalten den Puffer und lesen die Daten einfach ein.
*

 bra      rs_read2

*
* Wir schreiben einen Puffer, der gueltig und "dirty" ist,
* zurueck, um beim naechsten Durchlauf durch die Pufferliste
* bessere Karten zu haben.
*

rs_free_get:
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren
rs_get:
 move.l   a6,a0
 bsr      write_sector
 bmi      rs_ende

*
* Dabei kann ein Taskwechsel stattgefunden haben, deshalb
* fangen wir nochmal von vorn an.
*

 bra      rs_again

*
* Sektorpuffer <a1> ist frei bzw. nicht "dirty"
* In jedem Fall unbelegt, und es hat kein Taskwechsel stattgefunden.
* Sektorpuffer belegen und einlesen.
*

rs_read:
 move.l   a1,a6

* Der letzte Puffer der Liste ist nicht in Benutzung und ausserdem
* nicht veraendert (kein "dirty"). Wir koennen ihn ohne Taskwechsel
* belegen.

rs_ok:
 move.l   act_appl.l,xb_sem+bl_app(a6)    ; Sektor belegen
 move.l   act_pd.l,xb_sem+bl_pd(a6)       ; !neu!

rs_read2:
 move.w   d7,xb_drv(a6)
 move.l   d6,xb_secno(a6)
 move.l   d5,xb_secno2(a6)
 move.l   d6,-(sp)                 ; Sektornummer (long)
 move.w   d7,-(sp)                 ; Laufwerknummer
 tst.w    xb_secno(a6)             ; secno > 65535 ?
 beq.b    rs_read_short
 move.w   #-1,-(sp)
 bra.b    rs_read_long
rs_read_short:
 move.w   d6,-(sp)                 ; Sektornummer (short)
rs_read_long:
 move.w   #1,-(sp)                 ; 1 Sektor
 move.l   xb_data(a6),-(sp)        ; Datenpuffer
 move.l   #$40000,-(sp)            ; bios Rwabs(0,...)
 trap     #$d
 adda.w   #18,sp
 tst.l    d0                       ; Lesefehler ?
 bge.b    rs_rok                   ; nein

* Ein Lesefehler ist aufgetreten

 move.l   d0,-(sp)
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren
 move.l   (sp)+,d0
 move.w   xb_drv(a6),d1
 move.w   #-1,xb_drv(a6)           ; ja, Puffer ungueltig
 bsr      fatfs_diskerr
 tst.l    d0
 bra      rs_ende
*
* Der Puffer ist soeben erfolgreich eingelesen worden
* dirty- Flag setzen, wenn ich zu schreiben beabsichtige
*
rs_rok:
 move.w   24(sp),xb_dirty(a6)
 tst.l    xb_sem+bl_waiting(a6)    ; Semaphore anderweitig angefordert ?
 bne.b    rs_ok3                   ; ja !
 clr.l    xb_sem+bl_app(a6)        ; einfach nur freigeben
 bra.b    rs_return
rs_ok3:
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem                 ; Fehlercode von evnt_sem ignorieren
rs_return:
*
* Der gefundene Sektor wird nach vorn in die Liste gehaengt und
* zurueckgegeben. TOS spart sich diese Muehe.
*
 move.l   xb_prev(a6),d0           ; hat Vorgaenger ?
 beq.b    rs_weiter                ; nein, bin schon vorn
 move.l   d0,a0                    ; a0 ist Vorgaenger
 move.l   xb_next(a6),d0           ; hat Nachfolger ?
 move.l   d0,xb_next(a0)           ; aus Vorwaertsverkettung klinken
 beq.b    rs_weiter2               ; nein, ich war ganz hinten
 move.l   d0,a0
 move.l   xb_prev(a6),xb_prev(a0)  ; aus Rueckwaertsverkettung klinken
rs_weiter2:
 move.l   xb_first(a6),a0          ; die Liste
 move.l   (a0),a1                  ; a1 = bisheriges erstes Element
 move.l   a6,(a0)                  ; ich bin neues erstes Element
 move.l   a1,xb_next(a6)           ;  bisher. wird mein Nachfolger
 move.l   a6,xb_prev(a1)           ; und ich bin dessen Vorgaenger
 clr.l    xb_prev(a6)              ; mein Vorgaenger existiert nicht.
rs_weiter:
 move.w   24(sp),d0                ; to_write
 or.w     d0,xb_dirty(a6)          ; ggf. hier schon dirty setzen
 move.l   xb_data(a6),d0
rs_ende:
 move.l   a6,a0                    ; Rueckgabe des Puffers!!
 movem.l  (sp)+,a5/a6/d5/d6/d7
 rts


**********************************************************************
*
* long mrw_sectors(d0 = int drv, d1 = long secno, d2 = long anzahl,
*                 a0 = char *puffer, a1 = XBCB *list, int rwflag )
*
* Liest/Schreibt eine Anzahl DATEN- Sektoren in einem Rutsch
* <anzahl> muss WORD sein (wegen Rwabs)
*

mrw_sectors:

     DEBL d1,'mrw_sectors '
     DEBL d0,'        drv '
     DEBL d2,'     anzahl '

 movem.l  a4/a5/a6/d7/d6/d5,-(sp)
 move.l   a0,a4                    ; Puffer
 move.l   a1,a5                    ; list
 move.w   d0,d7                    ; drv
 move.l   d1,d6                    ; secno
 move.l   d2,d5                    ; anzahl
 add.l    d6,d5                    ; secno+anzahl
mrw_again:
 move.l   (a5),d2
 bra.b    mrw_nxtbuf
mrw_loop:
 move.l   d2,a6
 cmp.w    xb_drv(a6),d7
 bne.b    mrw_nxt                  ; anderes Laufwerk
 move.l   xb_secno(a6),d0
 cmp.l    d6,d0
 bcs.b    mrw_nxt                  ; liegt drunter
 cmp.l    d5,d0
 bcc.b    mrw_nxt                  ; liegt drueber
*
* Wir haben einen Sektor in unserem Bereich gefunden.
* Der Sektor wird zurueckgeschrieben und ist damit nicht mehr "dirty"
* beim naechsten Durchgang wird er dann ungueltig gemacht, weil er nicht
* mehr dirty ist, es sei denn, er ist noch blockiert, dann geht es wieder
* write_sector.
*
 tst.w    xb_dirty(a6)
 bne.b    mrw_wr                   ; veraendert, muss zurueckschreiben
 tst.l    xb_sem+bl_app(a6)        ; Semaphore belegt ?
 beq.b    mrw_ok                   ; nein, einfach nur ungueltig machen
* Der Sektor ist belegt, aber nicht veraendert, wir warten auf
* die Freigabe, d.h. belegen und geben gleich wieder frei
 lea      xb_sem(a6),a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 lea      xb_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 bra      mrw_again
mrw_wr:
 move.l   a6,a0
 bsr      write_sector
 bra      mrw_again                ; muss nochmal anfangen (Taskwechsel!)

mrw_ok:
 move.w   #-1,xb_drv(a6)
mrw_nxt:
 move.l   xb_next(a6),d2
mrw_nxtbuf:
 bne      mrw_loop

 move.l   d6,-(sp)                 ; secno (long)
 move.w   d7,-(sp)
 tst.w    2(sp)                    ; secno > 65535 ?
 beq.b    mrw_short
 move.w   #-1,-(sp)
 bra.b    mrw_long
mrw_short:
 move.w   d6,-(sp)                 ; secno (short)
mrw_long:
 sub.l    d6,d5
 move.w   d5,-(sp)                 ; Anzahl der Sektoren (immer short!!!)
 move.l   a4,-(sp)                 ; Puffer
 move.w   42(sp),-(sp)             ; rw- Flag
 move.w   #4,-(sp)                 ; bios Rwabs
 trap     #$d
 adda.w   #18,sp
 tst.l    d0
 beq.b    mrw_noerr
 move.w   d7,d1
 bsr      fatfs_diskerr
 tst.l    d0
mrw_noerr:
 movem.l  (sp)+,a4/a5/a6/d7/d6/d5
 rts
