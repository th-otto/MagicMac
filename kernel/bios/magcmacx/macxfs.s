/*
**
** Dies ist der Atari-Teil des Mac-XFS fuer MagiX
** Entwickelt mit PASM.
**
** (C) Andreas Kromke 2000
**
*/

     INCLUDE "errno.inc"
     INCLUDE "mgx_xfs.inc"
     INCLUDE "kernel.inc"
     INCLUDE "macxker.inc"
     INCLUDE "..\dos\magicdos.inc"

     XDEF mxfs_init

     XREF int_malloc,int_mfree,diskchange
     XREF drv2devcode,bios_rawdrvr
     XREF MSysX
     XREF Mac_xfsx                      ; von MAGXBIOS
     XREF pe_slice
     XREF appl_begcritic,appl_endcritic ; aendert d2/a2
     XREF Mappl_IOcomplete              ; von AESEVT
     XREF vmemcpy                       ; von STD



/*
*
* Dies sind die Funktionsnummern fuer die
* XFS-Funktion auf der Mac-Seite.
*
*/

macxfs_sync         EQU  0
macxfs_pterm        EQU  1
macxfs_drv_open     EQU  2
macxfs_drv_close    EQU  3
macxfs_path2DD      EQU  4
macxfs_sfirst       EQU  5
macxfs_snext        EQU  6
macxfs_fopen        EQU  7
macxfs_fdelete      EQU  8
macxfs_link         EQU  9
macxfs_xattr        EQU  10
macxfs_attrib       EQU  11
macxfs_fchown       EQU  12
macxfs_fchmod       EQU  13
macxfs_dcreate      EQU  14
macxfs_ddelete      EQU  15
macxfs_DD2name      EQU  16
macxfs_dopendir     EQU  17
macxfs_dreaddir     EQU  18
macxfs_drewinddir   EQU  19
macxfs_dclosedir    EQU  20
macxfs_dpathconf    EQU  21
macxfs_dfree        EQU  22
macxfs_wlabel       EQU  23
macxfs_rlabel       EQU  24
macxfs_symlink      EQU  25
macxfs_readlink     EQU  26
macxfs_dcntl        EQU  27


/*
*
* Dies sind die Funktionsnummern fuer die
* Geraete-Funktion auf der Mac-Seite.
*
*/

macdev_close        EQU  0
macdev_read         EQU  1
macdev_write        EQU  2
macdev_stat         EQU  3
macdev_seek         EQU  4
macdev_datime       EQU  5
macdev_ioctl        EQU  6
macdev_getc         EQU  7
macdev_getline      EQU  8
macdev_putc         EQU  9

     OFFSET

fsspec_vrefnum:     DS.W 1         ; MacOS "volume reference number"
fsspec_parID:       DS.L 1         ; MacOS "parent dirID"
fsspec_name:        DS.B 64        ; Name (64 Bytes in Pascal-Format)
fsspec_sizeof:

     OFFSET

qLink:              DS.L 1
qType:              DS.W 1
ioTrap:             DS.W 1
ioCmdAddr:          DS.L 1
ioCompletion:       DS.L 1
ioResult:           DS.W 1
ioNamePtr:          DS.L 1
ioVRefNum:          DS.W 1
ioRefNum:           DS.W 1
ioVersNum:          DS.B 1
ioPermssn:          DS.B 1
ioMisc:             DS.L 1
ioBuffer:           DS.L 1
ioReqCount:         DS.L 1
ioActCount:         DS.L 1
ioPosMode:          DS.W 1
ioPosOffset:        DS.L 1
ioMagiCUnsel:       DS.L 1
ioMagiCApp:         DS.L 1
io_sizeof:


/*
*
* Dies sind die eigentlichen Treiber, die ueber eine
* Assemblerschnittstelle mit dem MagiX- Kernel und
* ueber eine C-Schnittstelle mit dem Mac-Teil
* kommunizieren.
*
*/

     OFFSET

dd___:              DS.B 6         ; MagiX-DD
dd_dirid:           DS.L 1         ; MacOS-DD: Verzeichnis-INode
dd_vrefnum:         DS.W 1         ; MacOS-DD: Volume-Nummer

     OFFSET

fd___:              DS.B 12        ; MagiX-FD
fd_refnum:          DS.W 1         ; MacIntosh-FD

     TEXT

mxfs:
 DC.B     'MMCX_HFS'               ; Name
 DC.L     0                        ; naechstes XFS
 DC.L     0                        ; Flags
 DC.L     mxfs_init
 DC.L     mxfs_sync
 DC.L     mxfs_pterm
 DC.L     mxfs_garbcoll
 DC.L     mxfs_freeDD
 DC.L     mxfs_drv_open
 DC.L     mxfs_drv_close
 DC.L     mxfs_path2DD
 DC.L     mxfs_sfirst
 DC.L     mxfs_snext
 DC.L     mxfs_fopen
 DC.L     mxfs_fdelete
 DC.L     mxfs_frename
 DC.L     mxfs_xattr
 DC.L     mxfs_attrib
 DC.L     mxfs_chown
 DC.L     mxfs_chmod
 DC.L     mxfs_dcreate
 DC.L     mxfs_ddelete
 DC.L     mxfs_DD2name
 DC.L     mxfs_dopendir
 DC.L     mxfs_dreaddir
 DC.L     mxfs_drewinddir
 DC.L     mxfs_dclosedir
 DC.L     mxfs_dpathconf
 DC.L     mxfs_dfree
 DC.L     mxfs_wlabel
 DC.L     mxfs_rlabel
 DC.L     mxfs_symlink
 DC.L     mxfs_readlink
 DC.L     mxfs_dcntl
mxfs_len:


mdev:
 DC.L     mdev_close
 DC.L     mdev_read
 DC.L     mdev_write
 DC.L     mdev_stat
 DC.L     mdev_seek
 DC.L     mdev_datime
 DC.L     mdev_ioctl
 DC.L     mdev_getc
 DC.L     mdev_getline
 DC.L     mdev_putc



***********************************************
*
* <> mxfs_diskchange( DMD *d )
*

mxfs_diskchange:
 cmpi.l   #E_CHNG,d0
 bne.b    mxdc_ok
 move.l   (sp)+,a0            ; DMD zurueck
 move.w   d_drive(a0),d0
 jmp      diskchange
mxdc_ok:
 addq.l   #4,sp               ; DMD ueberlesen
 rts


***********************************************
*
* void mxfs_init( void )
*

mxfs_init:
; Kopie ins RAM
 move.w   #3,-(sp)                 ; lieber FastRAM
 pea      mxfs_len-mxfs
 move.w   #$44,-(sp)
 trap     #1
 addq.l   #8,sp
 tst.l    d0
 beq      mxfs_init_err

 move.l   d0,-(sp)                 ; Adresse

 move.l   d0,a0                    ; dst
 lea      mxfs(pc),a1              ; src
 move.w   #mxfs_len-mxfs,d0
 jsr      vmemcpy

; Kopie anmelden
;pea      mxfs(pc)                 ; Adresse der Kopie liegt schon auf Stack
 clr.l    -(sp)
 move.w   #KER_INSTXFS,-(sp)
 move.w   #$130,-(sp)         ; Dcntl
 trap     #1
 lea      12(sp),sp
mxfs_init_err:
 rts


**********************************************************************
*
* void mxfs_sync( a0 = DMD *d )
*

mxfs_sync:
 move.l   a0,-(sp)                      ; DMD merken
 move.w   d_drive(a0),-(sp)             ; drive
 move.w   #macxfs_sync,-(sp)            ; Funktionsnummer

 lea      (sp),a1                       ; a1 = Parameter
 lea      MSysX+MacSysX_xfs,a0               ; a0 = &Funktionszeiger
 MACPPCE                                ; Mac aufrufen

 addq.l   #4,sp
 bra      mxfs_diskchange


**********************************************************************
*
* void mxfs_pterm( a0 = DMD *d, a1 = PD *pd )
*
* Ein Programm wird gerade terminiert. Das XFS kann alle von diesem
* Programm belegten Ressourcen freigeben.
* Alle Ressourcen, von dem der Kernel weiss (d.h. geoeffnete Dateien)
* sind bereits vom Kernel freigegeben worden.
*

mxfs_pterm:
 move.l   a1,-(sp)
 move.w   #macxfs_pterm,-(sp)

 lea      (sp),a1                       ; a1 = Parameter
 lea      MSysX+MacSysX_xfs,a0               ; a0 = &Funktionszeiger
 MACPPCE                                ; Mac aufrufen

 addq.l   #6,sp
 rts


**********************************************************************
*
* long mxfs_garbcoll( a0 = DMD *dir )
*
* Sucht nach einem unbenutzten FD
* Rueckgabe TRUE, wenn mindestens einer gefunden wurde.
*

mxfs_garbcoll:
 moveq    #0,d0
 rts


**********************************************************************
*
* void mxfs_freeDD( a0 = DD *dir )
*
* Der Kernel hat den Referenzzaehler des DD auf 0 dekrementiert.
* Die Struktur kann jetzt freigegeben werden.
*

mxfs_freeDD:
 jmp      int_mfree


**********************************************************************
*
* long mxfs_drv_open( a0 = DMD *dmd )
*
* Initialisiert den DMD.
* Diskwechsel auf der Mac-Seite sind z.Zt. noch nicht moeglich,
* daher wird bereits hier ein E_OK geliefert.
*

mxfs_drv_open:
 move.l   a0,-(sp)                 ; DMD merken

 subq.l   #6,sp                    ; Platz fuer DD
 move.l   d_xfs(a0),-(sp)          ; Flag "schon initialisiert", Diskwechsel ?
 pea      0+4(sp)                  ; &dd
 move.w   d_drive(a0),-(sp)
 move.w   #macxfs_drv_open,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 adda.w   #12,sp
 move.l   (sp)+,d1                 ; dirID
 move.w   (sp)+,d2                 ; vRefNum

 tst.l    d0
 bne.b    drvop_err                ; Fehler
 move.l   (sp),a0
 tst.l    d_xfs(a0)                ; DMD schon initialisiert ?
 bne      drvop_err                ; ja, nichts tun
 movem.l  d1/d2,-(sp)
 move.w   d_drive(a0),d0
 jsr      drv2devcode
 movem.l  (sp)+,d1/d2
 move.l   (sp),a0
 move.l   d0,d_devcode(a0)         ; raw-device eintragen (Eject!)
 move.l   #bios_rawdrvr,d_driver(a0)
 movem.l  d1/d2,-(sp)
 jsr      int_malloc               ; DD der root allozieren
 movem.l  (sp)+,d1/d2
 move.l   (sp),a0                  ; a0 = DMD *
 move.l   d0,a1                    ; a1 = DD *
 move.l   a0,dd_dmd(a1)
 move.w   #1,dd_refcnt(a1)
 move.l   d1,dd_dirid(a1)
 move.w   d2,dd_vrefnum(a1)
 move.l   a1,d_root(a0)
 move.l   #mxfs,d_xfs(a0)
 move.w   #-1,d_biosdev(a0)
 moveq    #0,d0
drvop_err:
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_drv_close( a0 = DMD *dmd , d0 = int mode)
*
* mode == 0:   Frage, ob schliessen erlaubt, ggf. schliessen
*         1:   Schliessen erzwingen, muss E_OK liefern
*

mxfs_drv_close:
 move.l   a0,-(sp)                 ; Zeiger auf DMD merken
 move.w   d0,-(sp)
 move.w   d_drive(a0),-(sp)
 move.w   #macxfs_drv_close,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 addq.l   #6,sp
 move.l   (sp)+,a1
 tst.l    d0                       ; Freigabe zugelassen?
 bne.b    drvcl_err                ; nein
; root freigeben
 move.l   d_root(a1),a0
 clr.l    d_root(a1)
 jsr      int_mfree                ; root freigeben
 moveq    #E_OK,d0
drvcl_err:
 rts


**********************************************************************
*
* DD * mxfs_path2DD( a0 = DD * reldir,
*                    a1 = char *pathname,
*                    d0 = int  mode )
*
* d1 ist der Pfad ohne Laufwerk
* -> d0 = DD *dir     oder Fehlercode
* -> d1 = char *fname
*
* Wandelt den Pfadnamen, der relativ zu <reldir> gegeben ist, in
* einen DD um.
*
* mode == 0: pathname zeigt auf eine beliebige Datei. Gib den DD
*            zurueck, in dem die Datei liegt.
*            gib in a0 einen Zeiger auf den isolierten Dateinamen
*            zurueck.
*         1: pathname ist selbst ein Verzeichnis, gib dessen DD
*            zurueck, a0 ist danach undefiniert.
*
* Rueckgabe:
*  d0 = DD des Pfades, Referenzzaehler entsprechend erhoeht
*  d1 = Rest- Dateiname ohne beginnenden '\\'
* oder
*  d0 = ELINK
*  d1 = Restpfad ohne beginnenden '\\'
*  a0 = DD des Pfades, in dem der symbolische Link liegt. Dies ist
*       wichtig bei relativen Pfadangaben im Link.
*  a1 = NULL
*            Der Pfad stellt den Parent des Wurzelverzeichnisses
*            dar, der Kernel kann, wenn das Laufwerk U: ist, auf
*            U:\ zurueckgehen.
*  a1 = Pfad des symbolischen Links. Der Pfad enthaelt einen
*            symbolischen Link, womoeglich auf ein
*            anderes Laufwerk. Der Kernel muss den Restpfad <a0>
*            relativ zum neuen DD <a0> umwandeln.
*            a1 zeigt auf ein Wort fuer die Zeichenkettenlaenge
*            (gerade Zahl auf gerader Adresse, inkl. EOS),
*            danach folgt die Zeichenkette. Der Puffer kann
*            fluechtig sein, der Kernel kopiert den Pfad um.
*
*
* z.Zt. werden keine SymLinks unterstuetzt. Auch der Parent eines
* Wurzelverzeichnisses wird nicht korrekt behandelt.
* Es waere sinnvoll, einen Ueberblick ueber alle angeforderten DDs zu haben, um
* einer bereits referenzierten dirID keinen neuen Deskriptor anfordern
* zu muessen, sondern einfach den Referenzzaehler zu erhoehen.
*

mxfs_path2DD:
 movem.l  d3/d4/d5,-(sp)
 move.l   dd_dmd(a0),a2
 move.l   a2,-(sp)                 ; DMD merken

 move.w   d_drive(a2),-(sp)        ; fuer alten Emulator: Rueckgabe vorbesetzen
 suba.w   #20,sp                   ; Platz fuer:
                                   ;  Zeiger auf Rest-Dateiname
                                   ;  dirID des Pfads, in dem SymLink liegt
                                   ;  dazugehoerige VRefNum
                                   ;  Zeiger auf den SymLink
                                   ;  MagiC-Laufwerk
 pea      20(sp)                   ; &dir_drive (20..21)
 pea      14+4(sp)                 ; &dirID und vRefNum (14..19)
 pea      10+8(sp)                 ; &symlink (10..13)
 pea      4+12(sp)                 ; &dirID+vRefNum des Symlinks (4..9)
 pea      0+16(sp)                 ; &fname (0..3)
 move.l   a1,-(sp)                 ; path
 pea      dd_dirid(a0)             ; Zeiger auf reldir + vRefnum
 move.w   d_drive(a2),-(sp)        ; MagiC-Laufwerknummer
 move.w   d0,-(sp)                 ; mode
 move.w   #macxfs_path2DD,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      34(sp),sp
 move.l   (sp)+,d1                 ; Rest-fname
 move.l   (sp)+,a0                 ; dirID des Symlinks
 move.w   (sp)+,d3                 ; vRefNum des Symlinks
 move.l   (sp)+,a1                 ; Symlink
 move.l   (sp)+,d4                 ; dirID
 move.w   (sp)+,d5                 ; zugeh. vRefNum
 move.w   (sp)+,d2                 ; dir_drive

* ggf. DMD wechseln:

 move.l   (sp),a2
 cmp.w    d_drive(a2),d2           ; haben wir das Laufwerk gewechselt?
 beq.b    p2d_samedrv              ; nein
 lea      dmdx.l,a2
 add.w    d2,d2
 add.w    d2,d2
 add.w    d2,a2
 move.l   (a2),(sp)                ; DMD wechseln
 bge.b    p2d_samedrv
 moveq    #EPTHNF,d0               ; neuer DMD ungueltig???

p2d_samedrv:
 cmpi.l   #ELINK,d0                ; Symlink ?
 beq.b    p2d_link                 ; ja!
 tst.l    d0                       ; Rueckgabewert...
 bmi.b    p2d_err                  ; ist Fehler
 move.l   d1,-(sp)                 ; Rest-Dateinamen merken
 jsr      int_malloc               ; DD allozieren
 move.l   d0,a0                    ; a0 = DD *
 move.l   d4,dd_dirid(a0)          ; DirID in den DD eintragen
 move.w   d5,dd_vrefnum(a0)        ; vRefNum in den DD eintragen
 move.l   (sp)+,d1                 ; Dateinamen zurueck
 move.l   (sp),dd_dmd(a0)          ; DMD in den DD eintragen
 addq.w   #1,dd_refcnt(a0)         ; Referenzzaehler auf 1
;move.l   a0,d0
p2d_err:
 move.l   (sp)+,a2
 movem.l  (sp)+,d3/d4/d5
 move.l   a2,-(sp)
 bra      mxfs_diskchange
p2d_link:
 move.l   a1,d2                    ; Parent der root ?
 beq.b    p2d_ende                 ; ja!
 move.l   a1,-(sp)                 ; Symlink
 move.l   d1,-(sp)                 ; Dateinamen merken
 move.l   a0,d4                    ; dirID des Symlinks nach d4
 jsr      int_malloc               ; DD allozieren
 move.l   d0,a2                    ; a2 = DD *
 move.l   d4,dd_dirid(a2)          ; DirID in den DD eintragen
 move.w   d3,dd_vrefnum(a2)        ; vRefNum in den DD eintragen
 move.l   (sp)+,d1                 ; Dateinamen zurueck
 move.l   (sp)+,a1                 ; Symlink zurueck
 move.l   (sp)+,dd_dmd(a2)         ; DMD in den DD eintragen
 addq.w   #1,dd_refcnt(a2)         ; Referenzzaehler auf 1
 move.l   #ELINK,d0
 movem.l  (sp)+,d3/d4/d5
 rts
p2d_ende:
 addq.l   #4,sp
 movem.l  (sp)+,d3/d4/d5
 rts


**********************************************************************
*
* long mxfs_sfirst(a0 = DD *d, a1 = char *name, d0 = DTA *dta,
*                  d1 = int attrib)
*
* Rueckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

mxfs_sfirst:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; attr
 move.l   d0,-(sp)                 ; DTA
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_sfirst,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      18(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_snext(a0 = DTA *dta, a1 = DMD *d)
*
* Rueckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

mxfs_snext:
 move.l   a1,-(sp)
 move.l   a0,-(sp)                 ; DTA
 move.w   d_drive(a1),-(sp)        ; drv
 move.w   #macxfs_snext,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 addq.l   #8,sp
 bra      mxfs_diskchange


**********************************************************************
*
* d0 = FD * mxfs_fopen(a0 = DD *d, a1 = char *name, d0 = int omode,
*                      d1 = int attrib )
*
* Oeffnet und/oder erstellt Dateien, Oeffnet den Dateitreiber.
* Der Open- Modus ist vom Kernel bereits in die interne
* MagiX- Spezifikation konvertiert worden.
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel uebernommen.
*
* Rueckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*

mxfs_fopen:
 move.l   dd_dmd(a0),-(sp)         ; DMD retten
 move.w   d0,-(sp)                 ; omode retten

 move.w   d1,-(sp)                 ; attrib
 move.w   d0,-(sp)                 ; omode
 pea      dd_dirid(a0)             ; dirID und vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.l   a1,-(sp)                 ; name
 move.w   #macxfs_fopen,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE
 lea      16(sp),sp

 tst.l    d0                       ; Rueckgabewert
 bmi.b    fop_err                  ; ist Fehlercode
 move.w   d0,-(sp)                 ; RefNum (d.h. Mac-Handle (16 Bit))
 jsr      int_malloc               ; FD allozieren
 move.l   d0,a0
 move.w   (sp)+,fd_refnum(a0)      ; RefNum eintragen
 addq.w   #1,fd_refcnt(a0)
 move.l   #mdev,fd_dev(a0)
 move.l   2(sp),fd_dmd(a0)
 move.w   (sp),fd_mode(a0)
;move.l   a0,d0
fop_err:
 addq.l   #2,sp
 bra      mxfs_diskchange


*********************************************************************
*
* long mxfs_fdelete(a0 = DD *d, a1 = char *name)
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel uebernommen.
*
* Rueckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*
* Es duerfen keine SubDirs oder Labels geloescht werden.
*

mxfs_fdelete:
 move.l   dd_dmd(a0),-(sp)
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_fdelete,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      12(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_frename(a0 = DD *altdir, a1 = DD *neudir,
*                   d0 = char *altname, d1 = char *neuname, d2 = int flag)
*
* d2 = 1: Flink
* d2 = 0: Frename
*

mxfs_frename:
 move.l   dd_dmd(a0),-(sp)
 move.l   dd_dmd(a1),a2
 move.w   d_drive(a2),-(sp)        ; neu-drv
 move.w   d2,-(sp)                 ; mode
 pea      dd_dirid(a1)             ; neudir & vRefNum
 pea      dd_dirid(a0)             ; altdir & vRefNum
 move.l   d1,-(sp)                 ; neuer Name
 move.l   d0,-(sp)                 ; alter Name
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; altdrv
 move.w   #macxfs_link,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      24(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_xattr( a0 = DD *dir, a1 = char *name, d0 = XATTR *xa,
*                  d1 = int mode )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurueck)
*         1:   Folge nicht  (d.h. erstelle XATTR fuer den Link)
*

mxfs_xattr:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; xattr
 move.l   a1,-(sp)                 ; Name
 pea      dd_dirid(a0)             ; &dirID und vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_xattr,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      18(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_attrib( a0 = DD *dir, a1 = char *name, d0 = int mode,
*                   d1 = int attrib )
*
* Rueckgabe:    >= 0      Attribut
*              <  0      Fehler
*
* mode == 0:   Lies Attribut
*         1:   Schreibe Attribut
*

mxfs_attrib:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; attrib
 move.w   d0,-(sp)                 ; mode
 move.l   a1,-(sp)                 ; Name
 pea      dd_dirid(a0)             ; &(dirID und vRefNum)
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_attrib,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_chown( a0 = DD *dir, a1 = char *name, d0 = int uid,
*                  d1 = int gid )
*
* Rueckgabe:    == 0      OK
*              <  0      Fehler
*

mxfs_chown:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; gid
 move.w   d0,-(sp)                 ; uid
 move.l   a1,-(sp)                 ; Name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_fchown,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_chmod( a0 = DD *dir, a1 = char *name, d0 = int mode )
*
* Rueckgabe:    == 0      OK
*              <  0      Fehler
*

mxfs_chmod:
 move.l   dd_dmd(a0),-(sp)
 move.w   d0,-(sp)                 ; mode
 move.l   a1,-(sp)                 ; Name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_fchmod,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      14(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dcreate(a0 = DD *d, a1 = char *name, d0 = int mode )
*
* mode ist ueblicherweise "directory file" mit RWXRwXRwX
*
*
* Hier wird "mode" ignoriert!
*

mxfs_dcreate:
 move.l   dd_dmd(a0),-(sp)
 move.l   a1,-(sp)                 ; Name
 pea      dd_dirid(a0)             ; dir&vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_dcreate,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      12(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_ddelete( a0 = DD *d )
*
* Der DD darf nicht freigegeben werden (bleibt ge-lock-t!)
*

mxfs_ddelete:
 move.l   dd_dmd(a0),-(sp)
 pea      dd_dirid(a0)             ; dir&vRefNum
 move.l   dd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
;move.l   a0,a0
 move.w   #macxfs_ddelete,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 addq.l   #8,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long dxfs_DD2name(a0 = DD *d, a1 = char *buf, d0 = int buflen)
*
* Wandelt DD in einen Pfadnamen um
*

mxfs_DD2name:
 move.l   dd_dmd(a0),-(sp)
 move.w   d0,-(sp)                 ; buflen
 move.l   a1,-(sp)                 ; buf
 pea      dd_dirid(a0)             ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_DD2name,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      14(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* FD *mxfs_dopendir( a0 = DD *d, d0 = int tosflag )
*

mxfs_dopendir:
 move.l   dd_dmd(a0),-(sp)
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 jsr      int_malloc
 move.l   d0,a1                    ; a1 = DHD *dhd
 move.w   (sp)+,d0                 ; d0 = int tosflag
 move.l   (sp)+,a0                 ; a0 = DD *d
 move.l   (sp),dhd_dmd(a1)

 move.l   a1,-(sp)                 ; DHD
 move.w   d0,-(sp)                 ; tosflag
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.l   a1,-(sp)                 ; DHD
 move.w   #macxfs_dopendir,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      14(sp),sp
 tst.l    d0
 bge.b    dop_ok
; Fehler, DHD wieder freigeben
 move.l   (sp),a0                  ; DHD
 move.l   d0,(sp)
 jsr      int_mfree
dop_ok:
 move.l   (sp)+,d0                 ; DHD * bzw. Fehlercode
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dreaddir( a0 = void *dh, d0 = int len, a1 = char *buf,
*                     d1 = XATTR *xattr, d2 = long *xr )
*
* FUer Dreaddir (xattr = NULL) und Dxreaddir
*

mxfs_dreaddir:
 move.l   dd_dmd(a0),-(sp)
 move.l   d2,-(sp)                 ; xr
 move.l   d1,-(sp)                 ; xattr
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; len
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 move.w   #macxfs_dreaddir,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      22(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_drewinddir( a0 = FD *d )
*

mxfs_drewinddir:
 move.l   dd_dmd(a0),-(sp)
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 move.w   #macxfs_drewinddir,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 addq.l   #8,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dclosedir( a0 = FD *d )
*

mxfs_dclosedir:
 move.l   dd_dmd(a0),-(sp)
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 move.w   #macxfs_dclosedir,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 addq.l   #2,sp
 move.l   (sp)+,a0
 move.l   d0,-(sp)
 jsr      int_mfree                ; FD freigeben
 move.l   (sp)+,d0
 addq.l   #2,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dpathconf( a0 = DD *d, d0 = int which )
*
* mode = -1:   max. legal value for n in Dpathconf(n)
*         0:   internal limit on the number of open files
*         1:   max. number of links to a file
*         2:   max. length of a full path name
*         3:   max. length of an individual file name
*         4:   number of bytes that can be written atomically
*         5:   information about file name truncation
*              0 = File names are never truncated; if the file name in
*                  any system call affecting  this  directory  exceeds
*                  the  maximum  length (returned by mode 3), then the
*                  error value ERANGE is  returned  from  that  system
*                  call.
*
*              1 = File names are automatically truncated to the maxi-
*                  mum length.
*
*              2 = File names are truncated according  to  DOS  rules,
*                  i.e. to a maximum 8 character base name and a maxi-
*                  mum 3 character extension.
*         6:   0 = case-sensitiv
*              1 = nicht case-sensitiv, immer in Grossschrift
*              2 = nicht case-sensitiv, aber unbeeinflusst
*
*      If  any  of these items are unlimited, then 0x7fffffffL is
*      returned.
*

mxfs_dpathconf:
 move.l   dd_dmd(a0),-(sp)
 move.w   d0,-(sp)                 ; which
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_dpathconf,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 adda.w   #10,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dfree( a0 = DD_FD *dir, a1 = long buf[4] )
*

mxfs_dfree:
 move.l   dd_dmd(a0),-(sp)
 move.l   a1,-(sp)                 ; data
 move.l   a0,-(sp)                 ; DD *
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_dfree,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      12(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_wlabel( a0 = DD *d, a1 = char *name )
*

mxfs_wlabel:
 move.l   dd_dmd(a0),-(sp)
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)          ; drv
 move.w   #macxfs_wlabel,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 adda.w   #12,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_rlabel( a0 = DD *d, a1 = char *name,
*                   d0 = char *buf, d1 = int len )
*

mxfs_rlabel:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; len
 move.l   d0,-(sp)                 ; buf
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)          ; drv
 move.w   #macxfs_rlabel,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      14(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_symlink( a0 = DD *d, a1 = char *name, d0 = char *to )
*
* erstelle symbolischen Link
*

mxfs_symlink:
 move.l   dd_dmd(a0),-(sp)
 move.l   d0,-(sp)                 ; to
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_symlink,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_readlink( a0 = DD *d, a1 = char *name, d0 = char *buf,
*                     d1 = int buflen )
*
* Lies symbolischen Link
*

mxfs_readlink:
 move.l   dd_dmd(a0),-(sp)
 move.w   d1,-(sp)                 ; buflen
 move.l   d0,-(sp)                 ; buf
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_readlink,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      18(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dcntl( a0 = DD *d, a1 = char *name, d0 = int cmd,
*                  d1 = long arg )
*
* Fuehrt Spezialfunktionen aus
*

mxfs_dcntl:
 move.l   dd_dmd(a0),-(sp)
 move.l   d1,-(sp)                 ; arg
 move.w   d0,-(sp)                 ; cmd
 move.l   a1,-(sp)                 ; name
 pea      dd_dirid(a0)             ; dir & vRefNum
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.w   #macxfs_dcntl,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs,a0
 MACPPCE

 lea      18(sp),sp
 bra      mxfs_diskchange



**********************************************************************
**********************************************************************
*
* Dateitreiber
*
**********************************************************************
**********************************************************************
*
* long mdev_read(a0 = FD *file, d0 = long count, a1 = char *buffer)
*

mdev_read:
 move.l   a1,-(sp)                 ; buffer
 move.l   d0,-(sp)                 ; count
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_read,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      14(sp),sp
 rts


**********************************************************************
*
* long mdev_write(a0 = FD *file, d0 = long count, a1 = char *buffer)
*

mdev_write:
 move.l   a1,-(sp)                 ; buffer
 move.l   d0,-(sp)                 ; count
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_write,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      14(sp),sp
 rts


**********************************************************************
*
* long mdev_getc( a0 = FD *f, d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rueckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*

mdev_getc:
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_getc,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 addq.l   #8,sp
 rts


**********************************************************************
*
* long mdev_getline( a0 = FD *f, a1 = char *buf, d1 = long size,
*                      d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rueckgabe: Anzahl gelesener Bytes oder Fehlercode
*

mdev_getline:
 move.w   d0,-(sp)                 ; mode
 move.l   d1,-(sp)                 ; size
 move.l   a1,-(sp)                 ; buf
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_getline,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      16(sp),sp
 rts


**********************************************************************
*
* long mdev_putc( a0 = FD *f, d0 = int mode, d1 = long value )
*
* mode & 0x0001:    cooked
*
* Rueckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

mdev_putc:
 move.l   d1,-(sp)                 ; val
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_putc,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      12(sp),sp
 rts


**********************************************************************
*
* long mdev_stat(a0 = FD *f, a1 = long *unselect,
*                  d0 = int rwflag, d1 = long apcode)
*

mdev_stat:
 move.l   d1,-(sp)                 ; apcode
 move.w   d0,-(sp)                 ; rwflag
 move.l   a1,-(sp)                 ; unsel
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_stat,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      16(sp),sp
 rts


**********************************************************************
*
* long mdev_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

mdev_seek:
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; where
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_seek,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      12(sp),sp
 rts


**********************************************************************
*
* long mdev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*

mdev_ioctl:
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; cmd
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_ioctl,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      12(sp),sp
 rts


**********************************************************************
*
* long long mdev_datime(a0 = FD *file, a1 = int d[2], d0 = int set)
*

mdev_datime:
 move.w   d0,-(sp)                 ; set
 move.l   a1,-(sp)                 ; d
 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_datime,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 lea      12(sp),sp
 rts


**********************************************************************
*
* long long mdev_close(a0 = FD *file)
*
* schreibt alles zurueck, ruft den Dateitreiber auf und gibt ggf.
* den FD frei.
*

mdev_close:
 tst.w    fd_refcnt(a0)            ; FD freigeben ?
 beq.b    mdclo_free
 move.l   a0,-(sp)

 move.l   a0,-(sp)                 ; FD
 move.w   #macdev_close,-(sp)

 lea      (sp),a1
 lea      MSysX+MacSysX_xfs_dev,a0
 MACPPCE

 addq.l   #6,sp

 move.l   (sp)+,a0
 tst.w    fd_refcnt(a0)            ; FD freigeben ?
 bne.b    mdclo_ende
mdclo_free:
 move.l   d0,-(sp)
 jsr      int_mfree
 move.l   (sp)+,d0
mdclo_ende:
 rts

     END
