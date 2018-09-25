     OFFSET

; vom Kernel verwendete Funktionen
dev_close:     DS.L      1
dev_read:      DS.L      1
dev_write:     DS.L      1
dev_stat:      DS.L      1
dev_seek:      DS.L      1
dev_datime:    DS.L      1
dev_ioctl:     DS.L      1
dev_getc:      DS.L      1
dev_getline:   DS.L      1
dev_putc:      DS.L      1

     OFFSET

; vom XFS verwendete Funktionen
ddev_open:     DS.L      1
ddev_close:    DS.L      1
ddev_read:     DS.L      1
ddev_write:    DS.L      1
ddev_stat:     DS.L      1
ddev_seek:     DS.L      1
ddev_datime:   DS.L      1
ddev_ioctl:    DS.L      1
ddev_delete:   DS.L      1
ddev_getc:     DS.L      1
ddev_getline:  DS.L      1
ddev_putc:     DS.L      1

     OFFSET

dd_dmd:        DS.L      1    /* 0x00: Zeiger auf DMD                      */
dd_refcnt:     DS.W      1    /* 0x04: Ref.zähler für Standardpfade        */

     OFFSET

; für alle XFS, vom Kernel verwendet
fd_dmd:        DS.L      1    /* 0x00: Zeiger auf DMD                      */
fd_refcnt:     DS.W      1    /* 0x04: Ref.zähler fürs Schließen oder -1   */
fd_mode:       DS.W      1    /* 0x06: Open- Modus (0,1,2) und flags       */
fd_dev:        DS.L      1    /* 0x08: Zeiger auf MAGX_DEVDRVR             */
; für alle DFS
; fd_name/attr/next/children
; fd_dirch/time/date/stcl/len sind bei Clones ungültig
; fd_parent/dirpos/dmd sind identisch mit dem Prototyp-FD
fd_ddev:       DS.L      1    /* 0x0c: Zeiger auf MAGX_DOSDEVDRVR          */
fd_name:       DS.B      11   /* 0x10: DD_FD: Name im internen Format      */
                              /*       nur gültig, wenn Ursprungs-DD       */
fd_attr:       DS.B      1    /* 0x1b: Attribut                            */
fd_owner:      DS.L      1    /* 0x1c: DD_FD: Eigner eines FD oder NULL    */
fd_parent:     DS.L      1    /* 0x20: Zeiger auf den Parent-DD_FD         */
fd_children:   DS.L      1    /* 0x24: DD_FD: Liste aller Kinder           */
fd_next:       DS.L      1    /* 0x28: Zeiger auf FDs im selben Verzeichn. */
fd_multi:      DS.L      1    /* 0x2c: Zeiger auf FD derselben Datei       */
fd_multi1:     DS.L      1    /* 0x30: Zeiger auf erstes Listenelement     */
                              /*       fd_next/children ist ungültig, wenn */
                              /*       die Datei nicht erste der Liste ist */
fd_fpos:       DS.L      1    /* 0x34: Position des Dateizeigers           */
fd_dirch:      DS.B      1    /* 0x38: Bit0: "dirty"                       */
                              /*       Bit1: tosflag für Dreaddir          */
fd_unused:     DS.B      1    /* 0x39: */
fd_time:       DS.W      1    /* 0x3a: Zeit  (8086)                        */
fd_date:       DS.W      1    /* 0x3c: Datum (8086)                        */
fd_unused3:    DS.W      1    /* (alt: Start- Cluster)                     */
fd_len:        DS.L      1    /* 0x40: Dateilänge in Bytes                 */
fd_dirpos:     DS.L      1    /* 0x44: Pos. des zug. Eintrags im Directory */
fd_xdata:                     /* 2 Langworte zur freien Verfügung */
fd_Lccl:       DS.L      1    /* 0x48:  Clusternummer } oder Pointer       */
fd_usr1:
fd_clpos:      DS.W      1    /* 0x4c:  Offset zum Clusteranfang oder dev  */
fd_xftype:     DS.W      1    /* 0x4e:  (wie dir_xftype)                   */
fd_longname:   DS.L      1    /* 0x52: Zeiger auf IMB mit langem Namen     */
fd_usr3:
fd_Lcsec:      DS.L      1    /* 0x56: Sektornummer (LONG !!!)             */
fd_Lstcl:      DS.L      1    /* Startcluster (LONG)                       */
fd_sizeof:

     OFFSET

dhd_dmd:       DS.L      1    /* 0x00: Zeiger auf DMD                      */

     OFFSET

dta_sname:     DS.B      12   /* 0x00: Suchname     (von Fsfirst)          */
dta_dpos:      DS.L      1    /* 0x0c: Suchpos. oder 0L bei nicht ROOT     */
                              /*        bei FAT32: Clusternummer           */
dta_clpos:     DS.W      1    /* 0x10: Clusterposition, wenn nicht Root    */
dta_ccl:       DS.W      1    /* 0x12: Clusternummer, wenn nicht Root      */
                              /*        bei FAT32: unbenutzt               */
dta_drive:     DS.B      1    /* 0x14: Laufwerk (0..31)                    */

dta_attr:      DS.B      1    /* 0x15: gefundenes Attribut                 */
dta_time:      DS.W      1    /* 0x16: gefundene Zeit                      */
dta_date:      DS.W      1    /* 0x18: gefundenes Datum                    */
dta_len:       DS.L      1    /* 0x1a: gefundene Länge                     */
dta_name:      DS.B      14   /* 0x1e: gefundener Dateiname                */
dta_sizeof:

     OFFSET

; die ersten drei Einträge existieren für jedes Dateisystem
d_xfs:         DS.L      1    /* 0x00: Der Dateisystemtreiber              */
d_drive:       DS.W      1    /* 0x04: Laufwerknummer 0..31                */
d_root:        DS.L      1    /* 0x06: Zeiger auf FD der Root              */
d_biosdev:     DS.W      1    /* 0x0a: BIOS-Laufwerk oder -1               */
d_driver:      DS.L      1    /* 0x0c: def. zus. mit devcode das Medium    */
d_devcode:     DS.L      1    /* 0x10: XHDI-Code, SCSI Target & Laufwerk   */
; dieser Eintrag existiert nur für DOS- Dateisysteme
d_dfs:         DS.L      1    /* 0x14: DOS-spezifischer Dateisystemtreiber */
d_flags:       DS.W      1    /* 0x18: Bit0:lange Namen zulassen           */
; die restlichen Einträge existieren nur fürs FAT- Dateisystem
d_Ldoff:       DS.L      1    /* 0x1a: Sekt.nr.offset für Datensektoren    */
d_fatrec:      DS.L      1    /* erste Sektornr. der 2. FAT */
d_fsiz:        DS.L      1    /* FAT- Größe in Sektoren */
d_clsiz:       DS.W      1    /* Cluster- Größe in Sektoren */
d_clsizb:      DS.W      1    /* Cluster- Größe in Bytes */
d_recsiz:      DS.W      1    /* Sektor- Größe in Bytes */
d_numcl:       DS.L      1    /* Anzahl der Datencluster */
d_lclsiz:      DS.W      1    /* 2er- Logarithmus von clsiz */
d_mclsiz:      DS.W      1    /* Bit- Maske für clsiz */
d_lrecsiz:     DS.W      1    /* 2er- Logarithmus von recsiz */
d_mrecsiz:     DS.W      1    /* Bit- Maske für recsiz */
d_lclsizb:     DS.W      1    /* 2er- Logarithmus von clsizb */
d_flag:        DS.B      2    /* [0] : 0: FAT12 1: FAT16 -1:FAT32 */
                              /* [1] : Anzahl FATs */
d_1stfree_cl:  DS.L      1    /* Cache für ersten freien Cluster */
d_nfree_cl:    DS.L      1    /* Anzahl freier Cluster bzw. -1 (unbek.)    */
d_infosec:     DS.L      1    /* Nr. des Info-Sektors (FAT32) */
d_dirty:       DS.B      1    /* Medium geändert */
dmd_sizeof:

     OFFSET

dir_name:      DS.B     11    /* 0x00: Dateiname                           */
dir_attr:      DS.B      1    /* 0x0b: Attribut                            */
dir_xftype:    DS.W      1    /* 0x0c: Pseudodatei- Typ                    */
dir_xdata:     DS.L      1    /* 0x0e: Datenblock (für U:\)                */
dir_xdata2:    DS.B      2    /* 0x12: Datenblock (für U:\)                */
dir_xdata3:                   /* 0x14: Datenblock (für U:\)                */
dir_stcl_f32:  DS.W      1    /* 0x14: obere 12 Bits des Startclusters     */
dir_time:      DS.W      1    /* 0x16: Zeit  der letzten Änderung          */
dir_date:      DS.W      1    /* 0x18: Datum der letzten Änderung          */
dir_stcl:      DS.W      1    /* 0x1a: erster Cluster                      */
dir_flen:      DS.L      1    /* 0x1c: Dateilänge                          */
dir_sizeof:                   /* Länge der Struktur                        */

; dir_xftype = FT_MEMBLK:
;    dir_xdata zeigt auf Speicherblock für Verzeichnis
; dir_xftype = FT_SHM:
;    dir_xdata zeigt auf Speicherblock
; dir_xftype = FT_UNIPIPE oder FT_BIPIPE:
;    dir_xdata zeigt auf Speicherblock
; dir_xftype = FT_DEVICE:
;    dir_xdata zeigt auf Gerätetreiber
; dir_xftype = FT_PROCESS:
;    dir_xdata zeigt auf PD
; dir_xftype = FT_SYMLINK:
;    dir_xdata2 = 0 => dir_xdata zeigt auf Pfad
;    sonst => dir_xdata2-2 ist der Pfad selbst, also X:\
; dir_xftype = FT_DEVICE2:
;    dir_xdata zeigt auf Struktur, die auch auf Gerätetreiber zeigt

     OFFSET

xattr_mode:    DS.W      1    /* %ttttsssrwxrwxrwx                         */
                              /* Bit 12,13,14,15: Dateityp                 */
                              /*         2: BIOS special file              */
                              /*         4: Directory file                 */
                              /*         8: regular file                   */
                              /*        10: fifo                           */
                              /*        12: memory region or process       */
                              /*        14: symbolic link                  */
                              /* Bit 9,10,11: special bits                 */
                              /*         1: sticky bit (?)                 */
                              /*         2: setgid (?)                     */
                              /*         4: setuid (?)                     */
                              /* Bit 0..8: access modes                    */
                              /*         rwx für user/group/world          */
xattr_index:   DS.L      1
xattr_dev:     DS.W      1
xattr_res1:    DS.W      1
xattr_nlink:   DS.W      1
xattr_uid:     DS.W      1
xattr_gid:     DS.W      1
xattr_size:    DS.L      1
xattr_blksize: DS.L      1
xattr_nblocks: DS.L      1
xattr_mtime:   DS.W      1
xattr_mdate:   DS.W      1
xattr_atime:   DS.W      1
xattr_adate:   DS.W      1
xattr_ctime:   DS.W      1
xattr_cdate:   DS.W      1
xattr_attr:    DS.W      1
xattr_res2:    DS.W      1
xattr_res3:    DS.L      2
xattr_sizeof:

     OFFSET

timb_actime:   DS.W      1         /* für Dcntl(FUTIME, void *arg) */
timb_acdate:   DS.W      1
timb_modtime:  DS.W      1
timb_moddate:  DS.W      1

     OFFSET

l_type:        DS.W      1         /* type of lock */
l_whence:      DS.W      1         /* SEEK_SET, SEEK_CUR, SEEK_END */
l_start:       DS.L      1         /* start of locked region */
l_len:         DS.L      1         /* length of locked region */
l_pid:         DS.W      1         /* pid of locking process (F_GETLK only) */
l_sizeof:

     OFFSET

dfs_name:      DS.B      8    /* Untername des DOS-Dateisystems            */
dfs_next:      DS.L      1    /* Nächster Treiber                          */
dfs_init:      DS.L      1    /* Initialisierung                           */
dfs_sync:      DS.L      1    /* Synchronisiert Dateisystem                */
                              /* a0 = DMD *d                               */
                              /* -> long errcode                           */
dfs_drv_open:  DS.L      1    /* neues Laufwerk                            */
dfs_drv_close: DS.L      1    /* Laufwerk freigeben                        */
dfs_dfree:     DS.L      1    /* Für Dfree()                               */
dfs_sfirst:    DS.L      1
dfs_snext:     DS.L      1
dfs_ext_fd:    DS.L      1    /* erweitere ein Verzeichnis                 */
dfs_fcreate:   DS.L      1    /* erstelle Datei oder Verzeichnis           */
dfs_fxattr:    DS.L      1    /* für Fxattr                                */
dfs_dir2index: DS.L      1    /* für Dreaddir                              */
dfs_readlink:  DS.L      1    /* für Freadlink                             */
dfs_dir2FD:    DS.L      1    /* Für Fopen                                 */
dfs_fdelete:   DS.L      1    /* Für Fdelete und Ddelete                   */
dfs_pathconf:  DS.L      1    /* FÜr Dpathconf                             */

     OFFSET

xfs_name:      DS.B      8    /* Name des Dateisystems                     */
xfs_next:      DS.L      1    /* nächster Treiber                          */
xfs_flags:     DS.L      1    /* Flags laut MiNT                           */
xfs_init:      DS.L      1    /* Initialisierung                           */
xfs_sync:      DS.L      1    /* Synchronisiert Dateisystem                */
                              /* a0 = DMD *d                               */
                              /* -> long errcode                           */
xfs_pterm:     DS.L      1    /* Teilt ein Programmende mit                */
                              /* a0 = PD *                                 */
                              /* -> void                                   */
xfs_garbcoll:  DS.L      1    /* garbage collection oder NULL              */
                              /* a0 = DMD *d                               */
                              /* -> d0 = 1L oder 0L                        */
xfs_freeDD:    DS.L      1    /* DD freigeben                              */
                              /* a0 = DD *                                 */
                              /* -> void                                   */
xfs_drv_open:  DS.L      1    /* initialisiert bzw. testet DMD (Mediach)   */
                              /* a0 = DMD *                                */
                              /* -> d0 = long errcode                      */
xfs_drv_close: DS.L      1    /* erzwingt einen Diskwechsel                */
                              /* a0 = DMD *                                */
                              /* d0 = int mode                             */
                              /* -> d0 = long errcode                      */
xfs_path2DD:   DS.L      1    /* gibt einen DD zum Pfadnamen zurück        */
                              /* mode = 0: name ist Datei                  */
                              /*      = 1: name ist selbst Verzeichnis     */
                              /* d0 = int mode                             */
                              /* a0 = DD *reldir    akt. Verzeichnis       */
                              /* a1 = char *pathname                       */
                              /* -> d0 = DD *                              */
                              /*    d1 = char *restpath                    */
                              /* oder                                      */
                              /* -> d0 = ELINK                             */
                              /*    d1 = Restpfad ohne beginnenden '\'     */
                              /*    a0 = FD des Pfades, in dem der         */
                              /*         symbolische Link liegt.           */
                              /*    a1 = NULL  Der Pfad stellt den Parent  */
                              /*               des Wurzelverzeichnisses    */
                              /*               dar                         */
                              /*    a1 = Pfad des symbolischen Links       */
xfs_sfirst:    DS.L      1    /* Sucht die erste passende Datei            */
                              /* a0 = DD *                                 */
                              /* a1 = char *name   (ohne Pfad)             */
                              /* d0 = DTA *                                */
                              /* d1 = int  attrib                          */
                              /* -> d0 = long errcode                      */
xfs_snext:     DS.L      1    /* Sucht die nächste passende Datei          */
                              /* a0 = DTA *                                */
                              /* a1 = DMD *                                */
                              /* -> d0 = long errcode                      */
xfs_fopen:     DS.L      1    /* öffnet oder/und erstellt eine Datei       */
                              /* Öffnet aber nicht den Dateitreiber        */
                              /* a0 = DD *                                 */
                              /* a1 = char *name   (ohne Pfad)             */
                              /* d0 = int omode    (fürs Öffnen)           */
                              /* d1 = int attrib   (fürs Erstellen)        */
                              /* -> d0 = FD *                              */
                              /*         oder Fehlercode                   */
xfs_fdelete:   DS.L      1    /* löscht eine Datei                         */
                              /* a0 = DD *                                 */
                              /* a1 = char *name   (ohne Pfad)             */
                              /* -> d0 = long errcode                      */
xfs_link:      DS.L      1    /* für Frename und Flink                     */
                              /* a0 = DD *olddir                           */
                              /* a1 = DD *newdir                           */
                              /* d0 = char *oldname                        */
                              /* d1 = char *newname                        */
                              /* d2 = int flag_link                        */
                              /* -> d0 = long errcode                      */
xfs_xattr:     DS.L      1    /* für Fxattr                                */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = XATTR *                              */
                              /* d1 = int mode                             */
                              /* -> d0 = long errcode                      */
xfs_attrib:    DS.L      1    /* für Fattrib                               */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = int rwflag                           */
                              /* d1 = int attrib                           */
                              /* -> d0 = char attr                         */
                              /*         oder long errcode                 */
xfs_chown:     DS.L      1    /* für Fchown                                */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = uid                                  */
                              /* d1 = gid                                  */
                              /* -> d0 = long errcode                      */
xfs_chmod:     DS.L      1    /* für Fchmod                                */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = int mode                             */
                              /* -> d0 = long errcode                      */
xfs_dcreate:   DS.L      1    /* erstellt ein Verzeichnis                  */
                              /* a0 = DD *                                 */
                              /* a1 = char *name   (ohne Pfad)             */
                              /* d0 = int mode                             */
                              /* -> d0 = long errcode                      */
xfs_ddelete:   DS.L      1    /* löscht ein Verzeichnis                    */
                              /* a0 = DD *                                 */
                              /* -> d0 = long errcode                      */
xfs_DD2name:   DS.L      1    /* gibt den absoluten Pfadnamen zurück       */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = int size                             */
                              /* -> d0 = long errcode                      */
xfs_dopendir:   DS.L      1   /* Öffnet ein Verzeichnis                    */
                              /* a0 = DD *                                 */
                              /* d0 = int tosflag                          */
                              /* -> d0 = long dirhandle                    */
                              /*         oder Fehlercode                   */
xfs_dreaddir:   DS.L      1   /* Liest den nächsten Verzeichniseintrag     */
                              /* a0 = DD *dirhandle                        */
                              /* d0 = int  size                            */
                              /* a1 = char *buf                            */
                              /* d1 = XATTR *xattr oder NULL               */
                              /* d2 = long  *xr   (wenn xattr != NULL)     */
                              /* -> d0 = long errcode                      */
xfs_drewinddir: DS.L      1   /* Setzt das dirhandle auf den 1. Eintrag    */
                              /* a0 = DD * dirhandle                       */
                              /* -> d0 = long errcode                      */
xfs_dclosedir:  DS.L      1   /* Schließt das dirhandle                    */
                              /* a0 = DD *dirhandle                        */
                              /* -> d0 = long errcode                      */
xfs_dpathconf: DS.L      1    /* Ermittle verschiedene Limits              */
                              /* a0 = DD *                                 */
                              /* d0 = int which                            */
                              /* -> d0 = long value                        */
xfs_dfree:     DS.L      1    /* Ermittle Anzahl freier Blöcke usw.        */
                              /* a0 = DD *                                 */
                              /* a1 = long[4]                              */
                              /* -> d0 = long errcode                      */
xfs_wlabel:    DS.L      1    /* Schreibe Disknamen                        */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* -> d0 = long errcode                      */
xfs_rlabel:    DS.L      1    /* Lies Disknamen                            */
                              /* a0 = DD *                                 */
                              /* a1 = char *buf                            */
                              /* d0 = int len                              */
                              /* -> d0 = long errcode                      */
xfs_symlink:   DS.L      1    /* erstelle symbolischen Link                */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = char *to                             */
                              /* -> d0 = long errcode                      */
xfs_readlink:  DS.L      1    /* Lies symbolischen Link                    */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = char *buf                            */
                              /* d1 = int  size                            */
                              /* -> d0 = long errcode                      */
xfs_dcntl:     DS.L      1    /* für Dcntl                                 */
                              /* a0 = DD *                                 */
                              /* a1 = char *name                           */
                              /* d0 = int cmd                              */
                              /* d1 = long arg                             */
                              /* -> d0 = long errcode                      */


     TEXT

/* Modus- Feld des XFS- Treibers. Z.Zt. ohne Bedeutung */
FS_KNOPARSE         EQU  1    /* Kernel zerlegt keine Pfadnamen            */
FS_CASESENSITIVE    EQU  2    /* Dateinamen sind case sensitive            */
FS_NOXBIT           EQU  4    /* Jede lesbare Datei ist ausführbar         */
FS_LONGPATH         EQU  5    /* getname verarbeitet Parameter size        */

/* Standardhandles */

STDIN               EQU  0
STDOUT              EQU  1
STDAUX              EQU  2
STDPRN              EQU  3
STDHDL4             EQU  4
STDHDL5             EQU  5

/* Schreib-/Lesemodi für Fgetchar und Fputchar */

CMODE_RAW           EQU  0
CMODE_COOKED        EQU  1
BCMODE_COOKED       EQU  0
CMODE_ECHO          EQU  2
BCMODE_ECHO         EQU  1

/* Open- Modus von Dateien (Mag!X- intern) */
/* NOINHERIT wird seit MagiC 6.20 unterstützt */
/* HiByte wie unter MiNT verwendet */

OM_RPERM       EQU  1         /* Datei ist zum Lesen geöffnet              */
BOM_RPERM      EQU  0
OM_WPERM       EQU  2         /* Datei ist zum Schreiben geöffnet          */
BOM_WPERM      EQU  1
OM_EXEC        EQU  4         /* Datei ist zum Ausführen geöffnet          */
BOM_EXEC       EQU  2
OM_APPEND      EQU  8         /* Schreibzugriffe ans Ende (Kernel!)        */
BOM_APPEND     EQU  3
OM_RDENY       EQU  16        /* andere dürfen nicht gleichz. lesen        */
BOM_RDENY      EQU  4
OM_WDENY       EQU  32        /* andere dürfen nicht gleichz. schreiben    */
BOM_WDENY      EQU  5
OM_NOCHECK     EQU  64        /* KEINE Überprüfung durch den Kernel        */
BOM_NOCHECK    EQU  6
OM_NOINHERIT   EQU  128       /* weder bei Pexec noch bei Pfork vererben */
BOM_NOINHERIT  EQU  7


/* Open- Modus von Dateien (MiNT) */
O_RWMODE       EQU  3         /* Maske für r/w- Modi */
O_RDONLY       EQU  0
O_WRONLY       EQU  1
O_RDWR         EQU  2
O_EXEC         EQU  3

O_APPEND       EQU  8         /* Schreiben geht immer ans Dateiende   */
BO_APPEND      EQU  3

O_SHMODE       EQU  $70       /* isolates file sharing mode */
O_COMPAT       EQU  0         /* compatibility mode */
O_DENYRW       EQU  $10       /* deny both read and write access */
O_DENYW        EQU  $20       /* deny write access to others */
O_DENYR        EQU  $30       /* deny read access to others */
O_DENYNONE     EQU  $40       /* don't deny any access to others */

O_NOINHERIT    EQU  $80       /* children can't access via this file descriptor */
O_NDELAY       EQU  $100      /* don't block for i/o on this file */
O_CREAT        EQU  $200      /* create file if it doesn't exist */
BO_CREAT       EQU  9
O_TRUNC        EQU  $400      /* truncate file to 0 bytes if it does exist */
BO_TRUNC       EQU  10
O_EXCL         EQU  $800      /* fail open if file exists */
BO_EXCL        EQU  11
O_TTY          EQU  $2000     /* file is a terminal */
O_HEAD         EQU  $4000     /* file is a pseudo-terminal "master" */
BO_HEAD        EQU  14
O_LOCK         EQU  $8000     /* file has been locked */

; neue Dcntl-Modi für MagiC 6 (Kernel)

MX_KER_GETINFO      EQU  $6d00     /* Kernel: gib Zeiger auf Kernel zurück */
MX_KER_DOSLIMITS    EQU  $6d01     /* Kernel: gib indir. Zeiger auf DOSLIMITS */
MX_KER_INSTXFS      EQU  $6d02     /* Kernel: installiere ein XFS */
MX_KER_DRVSTAT      EQU  $6d04     /* Kernel: Drive-Status */
MX_KER_XFSNAME      EQU  $6d05     /* Kernel: XFS-Name */
MX_DEV_INSTALL      EQU  $6d20     /* DFS_U */
MX_DEV_INSTALL2     EQU  $6d21     /* DFS_U ab 11.7.99 */
MX_DFS_GETINFO      EQU  $6d40     /* XFS_DOS: gib Zeiger auf DFS-Kernel */
MX_DFS_INSTDFS      EQU  $6d41     /* XFS_DOS: installiere ein DFS */
MX_INT_CREATEPROC   EQU  $6d60     /* DFS_U */
MX_INT_CREATESYMLNK EQU  $6d61     /* DFS_U */

; alte Dcntl-Modi für MagiC (Kernel)

KER_GETINFO    EQU  $0100     /* Kernel: gib Zeiger auf Kernel zurück */
KER_DOSLIMITS  EQU  $0101     /* Kernel: gib indir. Zeiger auf DOSLIMITS */
KER_DRVSTAT    EQU  $0104     /* Kernel: Drive-Status (ab 9.9.95) */
KER_XFSNAME    EQU  $0105     /* Kernel: XFS-Name (ab 15.6.96) */
KER_INSTXFS    EQU  $0200     /* Kernel: installiere ein XFS */
DFS_GETINFO    EQU  $1100     /* XFS_DOS: gib Zeiger auf DFS-Kernel */
DFS_INSTDFS    EQU  $1200     /* XFS_DOS: installiere ein DFS */
;PROC_CREATE    EQU  $cc00     /* DFS_U */
DEV_M_INSTALL  EQU  $cd00     /* DFS_U */

; allgemeine Dcntl- Modi

CDROMEJECT     EQU  $4309     /* Kernel: Medium auswerfen */
VFAT_CNFDFLN   EQU  $5600     /* VFAT-XFS: Dflt.-Bitv. f. lange Dateinamen */
VFAT_CNFLN     EQU  $5601     /* VFAT-XFS: Lange Dateinamen f. LW an/aus */
FUTIME         EQU  $4603     /* XFS_DOS */

; Pseudo- Dcntl (intern)

FILE_CREATE    EQU  $ce00     /* XFS_DOS */
;SYMLINK_CREATE EQU  $cf00     /* DFS_U und DFS_FAT */

; unterstützte Fcntl- Modi
F_DUPFD        EQU  0
F_GETFD        EQU  1
F_SETFD        EQU  2
 FD_CLOEXEC    EQU  1
FSTAT          EQU  $4600
FIONREAD       EQU  $4601
FIONWRITE      EQU  $4602
FTRUNCATE      EQU  $4604
F_SETLK        EQU  6

LASTDRIVE      EQU  'Z'-'A'        ; höchste Laufwerknummer

BIOS_CON       EQU  2
Bconstat       EQU  1
Bcostat        EQU  8
Bconin         EQU  2
Bconout        EQU  3

/* The requests for Dpathconf() */

DP_IOPEN       EQU  0    /* internal limit on # of open files */
DP_MAXLINKS    EQU  1    /* max number of hard links to a file */
DP_PATHMAX     EQU  2    /* max path name length */
DP_NAMEMAX     EQU  3    /* max length of an individual file name */
DP_ATOMIC      EQU  4    /* # of bytes that can be written atomically */
DP_TRUNC       EQU  5    /* file name truncation behavior */
 DP_NOTRUNC    EQU  0    /* long filenames give an error */
 DP_AUTOTRUNC  EQU  1    /* long filenames truncated */
 DP_DOSTRUNC   EQU  2    /* DOS truncation rules in effect */
DP_CASE        EQU  6
 DP_CASESENS   EQU  0    /* case sensitive */
 DP_CASECONV   EQU  1    /* case always converted */
 DP_CASEINSENS EQU  2    /* case insensitive, preserved */
DP_MODEATTR    EQU  7
 DP_ATTRBITS   EQU  $000000ff
 DP_MODEBITS   EQU  $000fff00
 DP_FILETYPS   EQU  $fff00000
  DP_FT_DIR    EQU  $00100000
  DP_FT_CHR    EQU  $00200000
  DP_FT_BLK    EQU  $00400000
  DP_FT_REG    EQU  $00800000
  DP_FT_LNK    EQU  $01000000
  DP_FT_SOCK   EQU  $02000000
  DP_FT_FIFO   EQU  $04000000
  DP_FT_MEM    EQU  $08000000
DP_XATTRFIELDS EQU  8
 DP_INDEX      EQU  $0001
 DP_DEV        EQU  $0002
 DP_RDEV       EQU  $0004
 DP_NLINK      EQU  $0008
 DP_UID        EQU  $0010
 DP_GID        EQU  $0020
 DP_BLKSIZE    EQU  $0040
 DP_SIZE       EQU  $0080
 DP_NBLOCKS    EQU  $0100
 DP_ATIME      EQU  $0200
 DP_CTIME      EQU  $0400
 DP_MTIME      EQU  $0800

/* Für Psemaphore */

PSEM_CRGET     EQU  0    /* create and get */
PSEM_DESTROY   EQU  1
PSEM_GET       EQU  2
PSEM_RELEASE   EQU  3

/* Für Fseek, Flock */

SEEK_SET       EQU  0
SEEK_CUR       EQU  1
SEEK_END       EQU  2

/* attributes for Fcreate/Fsfirst/Fsnext: */

FAB_READONLY   EQU  0
FAB_HIDDEN     EQU  1
FAB_SYSTEM     EQU  2
FAB_VOLUME     EQU  3
FAB_SUBDIR     EQU  4
FAB_ARCHIVE    EQU  5
FAB_SYMLINK    EQU  6              ; MagiC 3

FA_READONLY    EQU  1
FA_HIDDEN      EQU  2
FA_SYSTEM      EQU  4
FA_VOLUME      EQU  8
FA_SUBDIR      EQU  16
FA_ARCHIVE     EQU  32

/* Für Flock, Lock-Typen */

F_RDLCK        EQU  0
F_WRLCK        EQU  1
F_UNLCK        EQU  3

/* Pexec-Modi */

EXE_LDEX       EQU  0              ; laden und ausführen
EXE_LD         EQU  3              ; laden
EXE_EX         EQU  4              ; ausführen, PD und Env unverändert
EXE_BASE       EQU  5              ; Basepage erstellen
EXE_EXFR       EQU  6              ; ausführen, PD und Env an neuen Prozeß
EXE_XBASE      EQU  7              ; wie 5, aber prgflags statt name
MEXE_LDEX      EQU  100            ; MiNT
XEXE_INIT      EQU  101            ; MagiC intern
XEXE_TERM      EQU  102            ; MagiC intern
MEXE_EX        EQU  104            ; MiNT
MEXE_EXFR      EQU  106            ; MiNT
XEXE_XBASE     EQU  107            ; MagiC intern
XEXE_EXACC     EQU  108            ; MagiC intern
MEXE_LDEXOV    EQU  200            ; MiNT, ab MagiC vom 1.11.98
XXEXE_INIT     EQU  301            ; MagiC intern
XXEXE_INITM    EQU  401            ; MagiC intern
XXEXE_EX       EQU  300            ; MagiC intern
