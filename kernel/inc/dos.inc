*
* Definitionen aus GEMDOS
* Wird verwendet von:
*    AES
*    BIOS
*    STD
*    READ_INF
*

MACRO     gemdos    fnummer
          IF fnummer = 0
          clr.w     -(sp)
          ELSE
          move.w    #fnummer,-(sp)
          ENDIF
          trap      #1
          ENDM

* GEMDOS:

Pterm0    EQU 0
Cconin    EQU 1
Cconout   EQU 2
Cauxin    EQU 3
Cauxout   EQU 4
Cprnout   EQU 5
Crawio    EQU 6
Crawcin   EQU 7
Cnecin    EQU 8
Cconws    EQU 9
Cconrs    EQU $a
Cconis    EQU $b
Dsetdrv   EQU $e
Cconos    EQU $10
Cprnos    EQU $11
Cauxis    EQU $12
Cauxos    EQU $13
Slbopen   EQU $16
Slbclose  EQU $17
Dgetdrv   EQU $19
Fsetdta   EQU $1a
Super     EQU $20
Tgetdate  EQU $2a
Tsetdate  EQU $2b
Tgettime  EQU $2c
Tsettime  EQU $2d
Fgetdta   EQU $2f
Sversion  EQU $30
Ptermres  EQU $31
Sconfig   EQU $33             * KAOS
Dfree     EQU $36
Dcreate   EQU $39
Ddelete   EQU $3a
Dsetpath  EQU $3b
Fcreate   EQU $3c
Fopen     EQU $3d
Fclose    EQU $3e
Fread     EQU $3f
Fwrite    EQU $40
Fdelete   EQU $41
Fseek     EQU $42
Fattrib   EQU $43
Fdup      EQU $45
Fforce    EQU $46
Dgetpath  EQU $47
Malloc    EQU $48
Mfree     EQU $49
Mshrink   EQU $4a
Pexec     EQU $4b
Pterm     EQU $4c
Fsfirst   EQU $4e
Fsnext    EQU $4f
Frename   EQU $56
Fdatime   EQU $57
Psetlimit EQU  $11f
Fxattr    EQU  $12c
Dcntl     EQU  $130

LIM_MAXCPU     EQU  1
LIM_MEMTOT     EQU  2
LIM_MEMHEAP    EQU  3

* GEMDOS- Handles

STDIN     EQU  0
STDOUT    EQU  1
STDAUX    EQU  2
STDPRN    EQU  3
STDERR    EQU  4
STDXTRA   EQU  5
HDL_CON   EQU -1
HDL_AUX   EQU -2
HDL_PRN   EQU -3
HDL_NUL   EQU -4

/* Open- Modus von Dateien (MiNT) */

O_RDONLY       EQU  0
O_WRONLY       EQU  1
O_RDWR         EQU  2
O_APPEND       EQU  8         /* Schreiben geht immer ans Dateiende   */
O_COMPAT       EQU  0         /* compatibility mode */
O_DENYRW       EQU  $10       /* deny both read and write access */
O_DENYW        EQU  $20       /* deny write access to others */
O_DENYR        EQU  $30       /* deny read access to others */
O_DENYNONE     EQU  $40       /* don't deny any access to others */

O_NOINHERIT    EQU  $80       /* children can't access via this file descriptor */
O_NDELAY       EQU  $100      /* don't block for i/o on this file */
O_CREAT        EQU  $200      /* create file if it doesn't exist */
O_TRUNC        EQU  $400      /* truncate file to 0 bytes if it does exist */
O_EXCL         EQU  $800      /* fail open if file exists */
O_TTY          EQU  $2000     /* file is a terminal */
O_HEAD         EQU  $4000     /* file is a pseudo-terminal "master" */
O_LOCK         EQU  $8000     /* file has been locked */

/* Fcntl-Codes */

FSTAT          EQU  $4600

/* Dcntl-Codes */

MX_DEV_INSTALL2     EQU  $6d21     /* DFS_U ab 11.7.99 */

     OFFSET

dta_sname:     DS.B      12   /* 0x00: Suchname     (von Fsfirst)          */
dta_dpos:      DS.L      1    /* 0x0c: Suchpos. oder 0L bei nicht ROOT     */
dta_clpos:     DS.W      1    /* 0x10: Clusterposition, wenn nicht Root    */
dta_ccl:       DS.W      1    /* 0x12: Clusternummer, wenn nicht Root      */
dta_drive:     DS.B      1    /* 0x14: Laufwerk (0..31)                    */
dta_attr:      DS.B      1    /* 0x15: gefundenes Attribut                 */
dta_time:      DS.W      1    /* 0x16: gefundene Zeit                      */
dta_date:      DS.W      1    /* 0x18: gefundenes Datum                    */
dta_len:       DS.L      1    /* 0x1a: gefundene Länge                     */
dta_name:      DS.B      14   /* 0x1e: gefundener Dateiname                */
dta_sizeof:

     OFFSET

xattr_mode:    DS.W      1
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

     TEXT
