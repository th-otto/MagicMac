/*
**
** Dies ist der Atari-Teil des MAC-XFS fuer MagiX
** Entwickelt mit PASM.
**
** (C) Andreas Kromke 1994
**
**
** Uebergabestrukturen:
**   ataridos       enthaelt die MAC-Seite des Dateisystems (XFS)
**   macdev         enthaelt die MAC-Seite des Dateitreibers (MX_FD)
**
*/

     INCLUDE "errno.inc"
     INCLUDE "mgx_xfs.inc"
     INCLUDE "kernel.inc"
     INCLUDE "mac_ker.inc"

BACKGR_DMA     EQU  1
EVNT_IO        EQU  1

_hz_200        EQU $4ba

     XDEF mxfs_init

     XREF int_malloc,int_mfree,diskchange
     XREF drv2devcode,bios_rawdrvr
     XREF MSys
     XREF Mac_xfsx                      ; von MAC_BIOS
     XREF dmdx
     XREF pe_slice
     XREF appl_begcritic,appl_endcritic ; ändert d2/a2
     XREF Mappl_IOcomplete              ; von AESEVT



/*
*
* Dies ist die Uebergabestruktur zwischen
* dem Atari- Teil des XFS und dem MAC-Teil.
* Der MAC- Teil bekommt seine Parameter
* "sauber" ueber den Stack, waehrend der Atari-Teil
* ueber Register mit dem MagiX-Kernel kommuniziert.
*
*/

     OFFSET

macxfs_version:     DS.L 1
macxfs_flags:       DS.L 1
macxfs_sync:        DS.L 1
macxfs_pterm:       DS.L 1
macxfs_drv_open:    DS.L 1
macxfs_drv_close:   DS.L 1
macxfs_path2DD:     DS.L 1
macxfs_sfirst:      DS.L 1
macxfs_snext:       DS.L 1
macxfs_fopen:       DS.L 1
macxfs_fdelete:     DS.L 1
macxfs_link:        DS.L 1
macxfs_xattr:       DS.L 1
macxfs_attrib:      DS.L 1
macxfs_fchown:      DS.L 1
macxfs_fchmod:      DS.L 1
macxfs_dcreate:     DS.L 1
macxfs_ddelete:     DS.L 1
macxfs_DD2name:     DS.L 1
macxfs_dopendir:    DS.L 1
macxfs_dreaddir:    DS.L 1
macxfs_drewinddir:  DS.L 1
macxfs_dclosedir:   DS.L 1
macxfs_dpathconf:   DS.L 1
macxfs_dfree:       DS.L 1
macxfs_wlabel:      DS.L 1
macxfs_rlabel:      DS.L 1
macxfs_symlink:     DS.L 1
macxfs_readlink:    DS.L 1
macxfs_dcntl:       DS.L 1


     OFFSET

macdev_version:     DS.L 1
macdev_flags:       DS.L 1
macdev_close:       DS.L 1
macdev_read:        DS.L 1
macdev_write:       DS.L 1
macdev_stat:        DS.L 1
macdev_seek:        DS.L 1
macdev_datime:      DS.L 1
macdev_ioctl:       DS.L 1
macdev_getc:        DS.L 1
macdev_getline:     DS.L 1
macdev_putc:        DS.L 1
macdev_pread:       DS.L 1         ; erst ab 12.2.98
macdev_pwrite:      DS.L 1         ; erst ab 12.2.98

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
* Für jedes eventuelle Laufwerk (A..Z) wird ein Deskriptor
* angelegt, mit dem das Laufwerk gesperrt werden und der
* letzte Zugriff eingetragen werden kann.
*
*/
     OFFSET

xfds_dirty:         DS.B 1              ; "dirty"
xfds_resvd:         DS.B 1
xfds_lastacc:       DS.L 1              ; letzter Zugriff
xfds_sem:           DS.B bl_sizeof      ; Semaphore
;xfds_iopb:         DS.B io_sizeof      ; PB für xfs_sync
xfds_sizeof:

/*
*
* Dies sind die eigentlichen Treiber, die über eine
* Assemblerschnittstelle mit dem MagiX- Kernel und
* über eine C-Schnittstelle mit dem MAC-Teil
* kommunizieren.
*
*/

     OFFSET

dd___:              DS.B 6         ; MagiX-DD
dd_dirid:           DS.L 1         ; MacIntosh-DD

     OFFSET

fd___:              DS.B 12        ; MagiX-FD
fd_refnum:          DS.W 1         ; MacIntosh-FD

     TEXT

mxfs:
 DC.B     'MMAC_HFS'               ; Name
 DC.L     0                        ; nächstes XFS
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
* WORD mxfs_unique_vrefnum( d0 = WORD drv )
*
* Ermittelt aus der Atari-Laufwerknummer 0..25
* die kleinste Atari-Laufwerknummer auf
* demselben Mac-Volume.
*
* Ändert a2,d0,d2
*

mxfs_unique_vrefnum:
 move.l   MSys+MacSys_drv_fsspec,a2
 mulu     #fsspec_sizeof,d0
 move.w   fsspec_vrefnum(a2,d0.l),d2    ; unsere Volume-ID
 moveq    #0,d0
mxuvn_loop:
 cmp.w    fsspec_vrefnum(a2),d2
 beq.b    mxuvn_found
 addq.w   #1,d0
 lea      fsspec_sizeof(a2),a2
 cmpi.w   #NDRVS,d0
 bcs.b    mxuvn_loop
 illegal                                ; ???
mxuvn_found:
 rts


***********************************************
*
* void mdev_completion_routine(a0 = ParamBlockRec *pb,
*                             d0 = WORD errcode )
*
* Diese Routine wird vom MacOS im Interrupt
* aufgerufen, wenn ein Transfer beendet wurde.
* Die Routine darf a0-a1 und d0-d2 ändern.
*
* Die Routine trägt den Atari-Fehlercode statt
* der "unselect"-Routine ein. Der Fehlercode wird
* dann von evnt_IO zurückgegeben.
*
* Achtung: Die unteren 32k vom MacOS sind hier
* eingeblendet
*

     IF   EVNT_IO
mdev_completion_routine:
 moveq    #0,d1                         ; TOS: kein Fehler
 tst.w    d0                            ; Mac: Fehlercode
 beq.b    mdev_cr_seterr                ; kein Fehler (noErr)
 cmpi.w   #-39,d0                       ; EOF (fEof)
 beq.b    mdev_cr_seterr                ; EOF ist im TOS kein Fehler
 movem.l  a0/a2,-(sp)                   ; sicherheitshalber a2 sichern
 move.w   d0,-(sp)                      ; Mac-Fehlercode
 move.l   MSys+MacSys_cnverr,a2
 jsr      (a2)                          ; => TOS-Fehlercode
 addq.l   #2,sp
 move.l   d0,d1
 movem.l  (sp)+,a0/a2
mdev_cr_seterr:
 move.l   d1,ioMagiCUnsel(a0)           ; Fehlercode statt unselect
 move.l   MSys+MacSys_offs_32k,a1       ; Zeropage
 move.l   ioMagiCApp(a0),a0             ; APPL *
 jmp      Mappl_IOcomplete              ; Applikation => READY
mdev_unsel:
 rts
     ENDIF

***********************************************
*
* a2 = long *mxfs_get_xfds( a0 = FD *fd )
*
* a2 = long *mxfs_get2_xfds( a0 = DMD *dmd )
*
* Ermittelt den Zeiger auf den zugehörigen
* xfds-Tabelleneintrag.
*
* Ändert nur a2,d2
*

mxfs_get_xfds:
 move.l   fd_dmd(a0),a2
mxfs_get2_xfds:
 move.l   d0,-(sp)
 move.w   d_drive(a2),d0
 bsr.b    mxfs_unique_vrefnum
 mulu     #xfds_sizeof,d0
 move.l   Mac_xfsx,a2
 adda.w   d0,a2
 move.l   (sp)+,d0
 rts


***********************************************
*
* <> mxfs_diskchange( DMD *d )
*

mxfs_diskchange:
 ATARI
 move.l   (sp)+,a5
mxfs_diskchange2:
 cmpi.l   #E_CHNG,d0
 bne.b    mxdc_ok
 move.l   (sp)+,a0            ; DMD zurück
 move.w   d_drive(a0),d0
 jmp      diskchange
mxdc_ok:
 addq.l   #4,sp               ; DMD überlesen
 rts


***********************************************
*
* void mxfs_init( void )
*
* Initialisierung: initialisiert die Deskriptoren.
*

mxfs_init:
 movem.l  d7/a6,-(sp)

 move.l   #xfds_sizeof*NDRVS,-(sp)
 move.w   #$48,-(sp)               ; Malloc
 trap     #1
 addq.l   #6,sp
 move.l   d0,Mac_xfsx
 beq.b    mxi_err

; XFS-Deskriptoren initialisieren

 move.l   d0,a6
 moveq    #NDRVS-1,d7
mxi_loop:
 sf.b     xfds_dirty(a6)
 clr.l    xfds_lastacc(a6)         ; Zugriffszeit löschen
 move.l   #'_MXD',d1
 lea      xfds_sem(a6),a0
 moveq    #SEM_CREATE,d0
 jsr      evnt_sem                 ; Semaphore erstellen
 lea      xfds_sizeof(a6),a6
 dbra     d7,mxi_loop

 pea      mxfs(pc)
 clr.l    -(sp)
 move.w   #KER_INSTXFS,-(sp)
 move.w   #$130,-(sp)         ; Dcntl
 trap     #1
 lea      12(sp),sp
mxi_err:
 movem.l  (sp)+,d7/a6
 rts


**********************************************************************
*
* void mxfs_sync( a0 = DMD *d )
*

mxfs_sync:
     IFNE BACKGR_DMA

*
* Prüfen, ob wir nicht die alte Routine aufrufen müssen
*

 move.l   MSys+MacSys_xfs_dev,a2
 btst     #0,macxfs_flags+3(a2)
 beq      mdev_sync_old
 tst.w    pe_slice
 bmi      mdev_sync_old

*
* sicherstellen, daß jedes Volume nur einmal ge-sync-t wird.
*

 move.w   d_drive(a0),d0                ; Laufwerknummer
 bsr      mxfs_unique_vrefnum
 cmp.w    d_drive(a0),d0                ; kleinste Nummer dieses Volumes?
 bne      mxsy_ende                     ; Mac-Volume schon behandelt!

*
* XFDS bestimmen
*

 mulu     #xfds_sizeof,d0
 move.l   Mac_xfsx,a2
 adda.w   d0,a2                         ; zugehöriger XFDS

*
* Feststellen, ob wir "sync"en müssen
*

 tst.b    xfds_dirty(a2)                ; geändert?
 beq      mxsy_ende                     ; nein
 tst.l    xfds_lastacc(a2)              ; gerade aktiv ?
 beq      mxsy_ende                     ; ja, nix machen
 move.l   _hz_200,d0                    ; aktuelle Zeit
 sub.l    xfds_lastacc(a2),d0           ; - Zeit des letzten Zugriffs
 cmpi.l   #400,d0                       ; mind. 2s ?
 bcs      mxsy_ende                     ; nein

 move.l   a0,-(sp)                      ; DMD merken
 movem.l  d7/a5/a6,-(sp)
 suba.w   #io_sizeof,sp
 move.l   a2,a6                         ; a6 = XFDS
 move.w   d_drive(a0),d7                ; d7 = drive

*
* Semaphore setzen
*

 lea      xfds_sem(a6),a0
 moveq    #0,d1                         ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      mxfs_sync_ende                ; -1: Reentranz/1: TimeOut (unmöglich)

 clr.l    xfds_lastacc(a6)              ; "im Zugriff"

*
* Completion-Routine aufsetzen
*

     IF   EVNT_IO
; move.l  #mdev_completion_routine,xfds_iopb+ioCompletion(a6)
; move.l  #mdev_unsel,xfds_iopb+ioMagiCUnsel(a6)
; move.l  act_appl,xfds_iopb+ioMagiCApp(a6)
 move.l   #mdev_completion_routine,ioCompletion(sp)
 move.l   #mdev_unsel,ioMagiCUnsel(sp)  ; Unselect-Routine bzw. Retcode
 move.l   act_appl,ioMagiCApp(sp)       ; für wakeup
     ELSE
 clr.l    ioCompletion(sp)
     ENDIF

 move.l   MSys+MacSys_in_interrupt,a2
 addq.l   #1,(a2)                       ; Tip von Tempi

 move.l   MSys+MacSys_a5,a5
 lea      (sp),a2                       ; Zeiger auf ParamBlockRec

*
* ins MacOS
*

 MAC
 pea      (a2)                          ; &pb
;pea      xfds_iopb(a6)
 move.w   d7,-(sp)                      ; drive
 mva0_mip MSys+MacSys_xfs,macxfs_sync   ; memory indirect, post-indexed
 jsr      (a0)
 addq.l   #6,sp
 ATARI

*
* Auf Beendigung warten
*

 move.l   MSys+MacSys_in_interrupt,a2
 subq.l   #1,(a2)                       ; Tip von Tempi

 tst.l    d0
 bmi.b    mxfs_sync_endwait

     IF   EVNT_IO
 lea      ioMagiCUnsel(sp),a0           ; Adresse des unselect
;lea      xfds_iopb+ioMagiCUnsel(a6),a0
 moveq    #0,d0                         ; kein TimeOut
 jsr      evnt_IO
     ELSE
mxfs_sync_loop:
 jsr      appl_yield
 tst.w    ioResult(sp)
 bgt.b    mxfs_sync_loop
 moveq    #0,d0
 move.w   ioResult(sp),d0
 beq.b    mxfs_sync_endwait
 ori.l    #$ffff0000,d0                 ; Hiword = -1
     ENDIF

*
* "dirty" löschen und Semaphore freigeben
*

mxfs_sync_endwait:
 sf.b     xfds_dirty(a6)                ; nicht mehr "dirty"
 move.l   _hz_200,xfds_lastacc(a6)      ; Zeit des letzten Zugriffs!

 move.l   d0,d7                         ; Rückgabewert merken
 lea      xfds_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 move.l   d7,d0

*
* Ende, Fehlercode behandeln
*

mxfs_sync_ende:
 adda.w   #io_sizeof,sp
 movem.l  (sp)+,a5/a6/d7
 bra      mxfs_diskchange2
mxsy_ende:
 rts
     ENDIF
mdev_sync_old:
 move.l   a0,-(sp)                      ; DMD merken
 move.l   a5,-(sp)
 suba.w   #io_sizeof,sp
 clr.l    ioCompletion(sp)

 move.l   MSys+MacSys_a5,a5
 lea      (sp),a2                       ; Zeiger auf ParamBlockRec

 MAC
 pea      (a2)                          ; &pb
 move.w   d_drive(a0),-(sp)             ; drive
 mva0_mip MSys+MacSys_xfs,macxfs_sync   ; memory indirect, post-indexed
 jsr      (a0)
 addq.l   #6,sp
 ATARI

 adda.w   #io_sizeof,sp
 move.l   (sp)+,a5
 bra      mxfs_diskchange2


**********************************************************************
*
* void mxfs_pterm( a0 = DMD *d, a1 = PD *pd )
*
* Ein Programm wird gerade terminiert. Das XFS kann alle von diesem
* Programm belegten Ressourcen freigeben.
* Alle Ressourcen, von dem der Kernel weiß (d.h. geöffnete Dateien)
* sind bereits vom Kernel freigegeben worden.
*

mxfs_pterm:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)
 mva0_mip MSys+MacSys_xfs,macxfs_pterm
 jsr      (a0)
 addq.l   #4,sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mxfs_garbcoll( a0 = DMD *dir )
*
* Sucht nach einem unbenutzten FD
* Rückgabe TRUE, wenn mindestens einer gefunden wurde.
*

mxfs_garbcoll:
 moveq    #0,d0
 rts


**********************************************************************
*
* void mxfs_freeDD( a0 = DD *dir )
*
* Der Kernel hat den Referenzzähler des DD auf 0 dekrementiert.
* Die Struktur kann jetzt freigegeben werden.
*

mxfs_freeDD:
 jmp      int_mfree


**********************************************************************
*
* long mxfs_drv_open( a0 = DMD *dmd )
*
* Initialisiert den DMD.
* Diskwechsel auf der MAC-Seite sind z.Zt. noch nicht möglich,
* daher wird bereits hier ein E_OK geliefert.
*

mxfs_drv_open:
 move.l   a0,-(sp)

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d_xfs(a0),-(sp)          ; Flag "schon initialisiert", Diskwechsel ?
 pea      d_root(a0)
 move.w   d_drive(a0),-(sp)
 mva0_mip MSys+MacSys_xfs,macxfs_drv_open
 jsr      (a0)
 adda.w   #10,sp
 ATARI
 move.l   (sp)+,a5

 tst.l    d0
 bne.b    drvop_err                ; Fehler
 move.l   (sp),a0
 tst.l    d_xfs(a0)                ; DMD schon initialisiert ?
 bne      drvop_err                ; ja, nichts tun
 move.w   d_drive(a0),d0
 jsr      drv2devcode
 move.l   (sp),a0
 move.l   d0,d_devcode(a0)         ; raw-device eintragen (Eject!)
 move.l   #bios_rawdrvr,d_driver(a0)
 jsr      int_malloc               ; DD der root allozieren
 move.l   (sp),a0                  ; a0 = DMD *
 move.l   d0,a1                    ; a1 = DD *
 move.l   a0,dd_dmd(a1)
 move.w   #1,dd_refcnt(a1)
;clr.w    dd_refcnt(a1)
 move.l   d_root(a0),dd_dirid(a1)
 move.l   a1,d_root(a0)
 move.l   #mxfs,d_xfs(a0)
 move.w   #-1,d_biosdev(a0)
 moveq    #0,d0
drvop_err:
 bra      mxfs_diskchange2


**********************************************************************
*
* long mxfs_drv_close( a0 = DMD *dmd , d0 = int mode)
*
* mode == 0:   Frage, ob schließen erlaubt, ggf. schließen
*         1:   Schließen erzwingen, muß E_OK liefern
*

mxfs_drv_close:
 move.l   a0,-(sp)                 ; Zeiger auf DMD merken
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)
 move.w   d_drive(a0),-(sp)
 mva0_mip MSys+MacSys_xfs,macxfs_drv_close,a0
 jsr      (a0)
 addq.l   #4,sp
 ATARI
 move.l   (sp)+,a5
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
*            zurück, in dem die Datei liegt.
*            gib in a0 einen Zeiger auf den isolierten Dateinamen
*            zurück.
*         1: pathname ist selbst ein Verzeichnis, gib dessen DD
*            zurück, a0 ist danach undefiniert.
*
* Rückgabe:
*  d0 = DD des Pfades, Referenzzähler entsprechend erhöht
*  d1 = Rest- Dateiname ohne beginnenden '\'
* oder
*  d0 = ELINK
*  d1 = Restpfad ohne beginnenden '\'
*  a0 = DD des Pfades, in dem der symbolische Link liegt. Dies ist
*       wichtig bei relativen Pfadangaben im Link.
*  a1 = NULL
*            Der Pfad stellt den Parent des Wurzelverzeichnisses
*            dar, der Kernel kann, wenn das Laufwerk U: ist, auf
*            U:\ zurückgehen.
*  a1 = Pfad des symbolischen Links. Der Pfad enthält einen
*            symbolischen Link, womöglich auf ein
*            anderes Laufwerk. Der Kernel muß den Restpfad <a0>
*            relativ zum neuen DD <a0> umwandeln.
*            a1 zeigt auf ein Wort für die Zeichenkettenlänge
*            (gerade Zahl auf gerader Adresse, inkl. EOS),
*            danach folgt die Zeichenkette. Der Puffer kann
*            flüchtig sein, der Kernel kopiert den Pfad um.
*
*
* z.Zt. werden keine SymLinks unterstützt. Auch der Parent eines
* Wurzelverzeichnisses wird nicht korrekt behandelt.
* Es wäre sinnvoll, einen Überblick über alle angeforderten DDs zu haben, um
* einer bereits referenzierten dirID keinen neuen Deskriptor anfordern
* zu müssen, sondern einfach den Referenzzähler zu erhöhen.
*

mxfs_path2DD:
 move.l   dd_dmd(a0),a2
 move.l   a2,-(sp)                 ; DMD merken

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d_drive(a2),-(sp)        ; für alten Emulator: Rückgabe vorbesetzen
 suba.w   #12,sp                   ; Platz für:
                                   ;  Zeiger auf Rest-Dateiname
                                   ;  dirID des Pfads, in dem SymLink liegt
                                   ;  Zeiger auf den SymLink
                                   ;  Laufwerk
 pea      12(sp)                   ; &dir_drive
 pea      12(sp)                   ; &symlink
 pea      12(sp)                   ; &dirID des Symlinks
 pea      12(sp)                   ; &fname
 move.l   a1,-(sp)                 ; path
 move.l   dd_dirid(a0),-(sp)       ; reldir
 move.w   d_drive(a2),-(sp)        ; drv
 move.w   d0,-(sp)                 ; mode

 mva0_mip MSys+MacSys_xfs,macxfs_path2DD
 jsr      (a0)
 lea      28(sp),sp
 move.l   (sp)+,d1                 ; Rest-fname
 move.l   (sp)+,a0                 ; dirID des Symlinks
 move.l   (sp)+,a1                 ; Symlink
 move.w   (sp)+,d2                 ; dir_drive
 ATARI
 move.l   (sp)+,a5

* ggf. DMD wechseln:

 move.l   (sp),a2
 cmp.w    d_drive(a2),d2           ; haben wir das Laufwerk gewechselt?
 beq.b    p2d_samedrv              ; nein
 lea      dmdx,a2
 add.w    d2,d2
 add.w    d2,d2
 add.w    d2,a2
 move.l   (a2),(sp)                ; DMD wechseln
 bge.b    p2d_samedrv
 moveq    #EPTHNF,d0               ; neuer DMD ungültig???

p2d_samedrv:
 cmpi.l   #ELINK,d0                ; Symlink ?
 beq.b    p2d_link                 ; ja!
 tst.l    d0                       ; Rückgabewert...
 bmi.b    p2d_err                  ; ist Fehler
 move.l   d1,-(sp)                 ; Dateinamen merken
 move.l   d0,-(sp)                 ; DirID merken
 jsr      int_malloc               ; DD allozieren
 move.l   d0,a0                    ; a0 = DD *
 move.l   (sp)+,dd_dirid(a0)       ; DirID in den DD eintragen
 move.l   (sp)+,d1                 ; Dateinamen zurück
 move.l   (sp),dd_dmd(a0)          ; DMD in den DD eintragen
 addq.w   #1,dd_refcnt(a0)         ; Referenzzähler auf 1
;move.l   a0,d0
p2d_err:
 bra      mxfs_diskchange2
p2d_link:
 move.l   a1,d2                    ; Parent der root ?
 beq.b    p2d_ende                 ; ja!
 move.l   a1,-(sp)                 ; Symlink
 move.l   d1,-(sp)                 ; Dateinamen merken
 move.l   a0,-(sp)                 ; dirID des Symlinks
 jsr      int_malloc               ; DD allozieren
 move.l   d0,a2                    ; a2 = DD *
 move.l   (sp)+,dd_dirid(a2)       ; DirID in den DD eintragen
 move.l   (sp)+,d1                 ; Dateinamen zurück
 move.l   (sp)+,a1                 ; Symlink zurück
 move.l   (sp)+,dd_dmd(a2)         ; DMD in den DD eintragen
 addq.w   #1,dd_refcnt(a2)         ; Referenzzähler auf 1
 move.l   #ELINK,d0
 rts
p2d_ende:
 addq.l   #4,sp
 rts


**********************************************************************
*
* long mxfs_sfirst(a0 = DD *d, a1 = char *name, d0 = DTA *dta,
*                  d1 = int attrib)
*
* Rückgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

mxfs_sfirst:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; attr
 move.l   d0,-(sp)                 ; DTA
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_sfirst
 jsr      (a0)
 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_snext(a0 = DTA *dta, a1 = DMD *d)
*
* Rückgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

mxfs_snext:
 move.l   a1,-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a0,-(sp)                 ; DTA
 move.w   d_drive(a1),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_snext
 jsr      (a0)
 addq.l   #6,sp
 bra      mxfs_diskchange


**********************************************************************
*
* d0 = FD * mxfs_fopen(a0 = DD *d, a1 = char *name, d0 = int omode,
*                      d1 = int attrib )
*
* Öffnet und/oder erstellt Dateien, Öffnet den Dateitreiber.
* Der Open- Modus ist vom Kernel bereits in die interne
* MagiX- Spezifikation konvertiert worden.
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel übernommen.
*
* Rückgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*

mxfs_fopen:
 move.l   dd_dmd(a0),-(sp)         ; DMD retten
 move.w   d0,-(sp)                 ; omode retten

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; attrib
 move.w   d0,-(sp)                 ; omode
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.l   a1,-(sp)                 ; name
 mva0_mip MSys+MacSys_xfs,macxfs_fopen
 jsr      (a0)
 lea      14(sp),sp
 ATARI
 move.l   (sp)+,a5

 tst.l    d0                       ; Rückgabewert
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
 bra      mxfs_diskchange2


*********************************************************************
*
* long mxfs_fdelete(a0 = DD *d, a1 = char *name)
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel übernommen.
*
* Rückgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*
* Es dürfen keine SubDirs oder Labels gelöscht werden.
*

mxfs_fdelete:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_fdelete
 jsr      (a0)
 lea      10(sp),sp
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
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   dd_dmd(a1),a2
 move.w   d_drive(a2),-(sp)        ; neu-drv
 move.w   d2,-(sp)                 ; mode
 move.l   dd_dirid(a1),-(sp)       ; neudir
 move.l   dd_dirid(a0),-(sp)       ; altdir
 move.l   d1,-(sp)                 ; neuer Name
 move.l   d0,-(sp)                 ; alter Name
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; altdrv
 mva0_mip MSys+MacSys_xfs,macxfs_link
 jsr      (a0)
 lea      22(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_xattr( a0 = DD *dir, a1 = char *name, d0 = XATTR *xa,
*                  d1 = int mode )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurück)
*         1:   Folge nicht  (d.h. erstelle XATTR für den Link)
*

mxfs_xattr:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; xattr
 move.l   a1,-(sp)                 ; Name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_xattr
 jsr      (a0)
 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_attrib( a0 = DD *dir, a1 = char *name, d0 = int mode,
*                   d1 = int attrib )
*
* Rückgabe:    >= 0      Attribut
*              <  0      Fehler
*
* mode == 0:   Lies Attribut
*         1:   Schreibe Attribut
*

mxfs_attrib:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; attrib
 move.w   d0,-(sp)                 ; mode
 move.l   a1,-(sp)                 ; Name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_attrib
 jsr      (a0)
 lea      14(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_chown( a0 = DD *dir, a1 = char *name, d0 = int uid,
*                  d1 = int gid )
*
* Rückgabe:    == 0      OK
*              <  0      Fehler
*

mxfs_chown:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; gid
 move.w   d0,-(sp)                 ; uid
 move.l   a1,-(sp)                 ; Name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_fchown
 jsr      (a0)
 lea      14(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_chmod( a0 = DD *dir, a1 = char *name, d0 = int mode )
*
* Rückgabe:    == 0      OK
*              <  0      Fehler
*

mxfs_chmod:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; mode
 move.l   a1,-(sp)                 ; Name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_fchmod
 jsr      (a0)
 lea      12(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dcreate(a0 = DD *d, a1 = char *name, d0 = int mode )
*
* mode ist üblicherweise "directory file" mit RWXRwXRwX
*
*
* Hier wird "mode" ignoriert!
*

mxfs_dcreate:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; Name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_dcreate
 jsr      (a0)
 lea      10(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_ddelete( a0 = DD *d )
*
* Der DD darf nicht freigegeben werden (bleibt ge-lock-t!)
*

mxfs_ddelete:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
;move.l   a0,a0
 mva0_mip MSys+MacSys_xfs,macxfs_ddelete
 jsr      (a0)
 addq.l   #6,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long dxfs_DD2name(a0 = DD *d, a1 = char *buf, d0 = int buflen)
*
* Wandelt DD in einen Pfadnamen um
*

mxfs_DD2name:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; buflen
 move.l   a1,-(sp)                 ; buf
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_DD2name
 jsr      (a0)
 lea      12(sp),sp
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
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; tosflag
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 move.l   a1,-(sp)                 ; DHD
 mva0_mip MSys+MacSys_xfs,macxfs_dopendir
 jsr      (a0)
 lea      12(sp),sp
 ATARI
 move.l   (sp)+,a5
 tst.l    d0
 bge.b    dop_ok
; Fehler, DHD wieder freigeben
 move.l   (sp),a0                  ; DHD
 move.l   d0,(sp)
 jsr      int_mfree
dop_ok:
 move.l   (sp)+,d0                 ; DHD * bzw. Fehlercode
 bra      mxfs_diskchange2


**********************************************************************
*
* long mxfs_dreaddir( a0 = void *dh, d0 = int len, a1 = char *buf,
*                     d1 = XATTR *xattr, d2 = long *xr )
*
* FÜr Dreaddir (xattr = NULL) und Dxreaddir
*

mxfs_dreaddir:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d2,-(sp)                 ; xr
 move.l   d1,-(sp)                 ; xattr
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; len
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 mva0_mip MSys+MacSys_xfs,macxfs_dreaddir
 jsr      (a0)
 lea      20(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_drewinddir( a0 = FD *d )
*

mxfs_drewinddir:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 mva0_mip MSys+MacSys_xfs,macxfs_drewinddir
 jsr      (a0)
 addq.l   #6,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dclosedir( a0 = FD *d )
*

mxfs_dclosedir:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   dhd_dmd(a0),a1
 move.w   d_drive(a1),-(sp)        ; drv
 move.l   a0,-(sp)                 ; dh
 mva0_mip MSys+MacSys_xfs,macxfs_dclosedir
 jsr      (a0)
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
*              1 = nicht case-sensitiv, immer in Großschrift
*              2 = nicht case-sensitiv, aber unbeeinflußt
*
*      If  any  of these items are unlimited, then 0x7fffffffL is
*      returned.
*

mxfs_dpathconf:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; which
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_dpathconf
 jsr      (a0)
 addq.l   #8,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dfree( a0 = DD_FD *dir, a1 = long buf[4] )
*

mxfs_dfree:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; data
 move.l   a0,-(sp)                 ; DD *
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_dfree
 jsr      (a0)
 lea      10(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_wlabel( a0 = DD *d, a1 = char *name )
*

mxfs_wlabel:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)          ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_wlabel
 jsr      (a0)
 adda.w   #10,sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_rlabel( a0 = DD *d, a1 = char *name,
*                   d0 = char *buf, d1 = int len )
*

mxfs_rlabel:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; len
 move.l   d0,-(sp)                 ; buf
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)          ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_rlabel
 jsr      (a0)
 lea      12(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_symlink( a0 = DD *d, a1 = char *name, d0 = char *to )
*
* erstelle symbolischen Link
*

mxfs_symlink:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d0,-(sp)                 ; to
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_symlink
 jsr      (a0)
 lea      14(sp),sp
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
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; buflen
 move.l   d0,-(sp)                 ; buf
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_readlink
 jsr      (a0)
 lea      16(sp),sp
 bra      mxfs_diskchange


**********************************************************************
*
* long mxfs_dcntl( a0 = DD *d, a1 = char *name, d0 = int cmd,
*                  d1 = long arg )
*
* Führt Spezialfunktionen aus
*

mxfs_dcntl:
 move.l   dd_dmd(a0),-(sp)
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d1,-(sp)                 ; arg
 move.w   d0,-(sp)                 ; cmd
 move.l   a1,-(sp)                 ; name
 move.l   dd_dirid(a0),-(sp)       ; dir
 move.l   dd_dmd(a0),a0
 move.w   d_drive(a0),-(sp)        ; drv
 mva0_mip MSys+MacSys_xfs,macxfs_dcntl
 jsr      (a0)
 lea      16(sp),sp
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

     IFNE BACKGR_DMA

*
* Prüfen, ob wir nicht die alte Routine aufrufen müssen
*

 move.l   MSys+MacSys_xfs_dev,a2
 btst     #0,macxfs_flags+3(a2)
 beq      mdev_rd_old
 tst.w    pe_slice
 bmi      mdev_rd_old

*
* neue Routine
*

 movem.l  a3/a4/a5/a6,-(sp)
 suba.w   #io_sizeof,sp
 move.l   a1,ioBuffer(sp)
 move.l   d0,ioReqCount(sp)
 move.l   a0,a3                    ; a3 = FD

*
* XFDS bestimmen: a6
*

;move.l   a0,a0                    ; FD
 bsr      mxfs_get_xfds            ; ändert nicht a0/a1/d0
 move.l   a2,a6                    ; a6 = Zeiger auf letzte Zugriffszeit

*
* Semaphore setzen
*

 lea      xfds_sem(a6),a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      mdev_rd_ende             ; -1: Reentranz/1: TimeOut (unmöglich)

 clr.l    xfds_lastacc(a6)         ; gerade in Benutzung!

;jsr      appl_begcritic           ; darf nicht terminiert werden

*
* Completion-Routine aufsetzen
*

 move.l   MSys+MacSys_in_interrupt,a4
 addq.l   #1,(a4)                       ; Tip von Tempi

     IF   EVNT_IO
 move.l   #mdev_completion_routine,ioCompletion(sp)
 move.l   #mdev_unsel,ioMagiCUnsel(sp)  ; Unselect-Routine bzw. Retcode
 move.l   act_appl,ioMagiCApp(sp)       ; für wakeup
     ELSE
 clr.l    ioCompletion(sp)
     ENDIF

 move.l   MSys+MacSys_a5,a5
 lea      (sp),a2
 MAC
 pea      (a2)                     ; ioBuf
 move.l   a3,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_pread
 jsr      (a0)
 addq.l   #8,sp
 ATARI

 subq.l   #1,(a4)                       ; Tip von Tempi

 tst.l    d0
 bmi.b    mdev_rd_err

     IF   EVNT_IO
 lea      ioMagiCUnsel(sp),a0           ; Adresse des unselect
 moveq    #0,d0                         ; kein TimeOut
 jsr      evnt_IO
 tst.l    d0                            ; TOS-Fehlercode
 bmi.b    mdev_rd_err                   ; Fehler
     ELSE
mdev_rd_loop:
 jsr      appl_yield
 tst.w    ioResult(sp)
 bgt.b    mdev_rd_loop
 move.w   ioResult(sp),d0
 beq.b    mdev_rd_ok
 cmpi.w   #-39,d0                  ; fEof (Mac-Fehlercode)
 beq.b    mdev_rd_ok
 ori.l    #$ffff0000,d0            ; Hiword = -1
 bra.b    mdev_rd_err
     ENDIF

mdev_rd_ok:
 move.l   ioActCount(sp),d0        ; kein Fehler
mdev_rd_err:
 move.l   _hz_200,xfds_lastacc(a6) ; Zeit des letzten Zugriffs!

*
* Semaphore wieder freigeben
*

;jsr      appl_endcritic           ; darf wieder terminiert werden
 move.l   d0,a4                    ; Rückgabewert merken
 lea      xfds_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 move.l   a4,d0

mdev_rd_ende:
 adda.w   #io_sizeof,sp
 movem.l  (sp)+,a3/a4/a5/a6
 rts

mdev_rd_old:
     ENDIF

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; buffer
 move.l   d0,-(sp)                 ; count
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_read
 jsr      (a0)
 lea      12(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_write(a0 = FD *file, d0 = long count, a1 = char *buffer)
*

mdev_write:
     IFNE BACKGR_DMA

*
* Prüfen, ob wir nicht die alte Routine aufrufen müssen
*

 move.l   MSys+MacSys_xfs_dev,a2
 btst     #0,macxfs_flags+3(a2)
 beq      mdev_wr_old
 tst.w    pe_slice
 bmi      mdev_wr_old

*
* neue Routine
*

 movem.l  a3/a4/a5/a6,-(sp)
 suba.w   #io_sizeof,sp
 move.l   a0,a3                    ; a3 = FD
 move.l   a1,ioBuffer(sp)
 move.l   d0,ioReqCount(sp)

*
* XFDS bestimmen: a6
*

;move.l   a0,a0
 bsr      mxfs_get_xfds
 move.l   a2,a6                    ; a6 = Zeiger auf letzte Zugriffszeit

*
* Semaphore setzen
*

 lea      xfds_sem(a6),a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      mdev_wr_ende             ; -1: Reentranz/1: TimeOut (unmöglich)

 clr.l    xfds_lastacc(a6)         ; gerade in Benutzung!

;jsr      appl_begcritic           ; darf nicht terminiert werden

*
* Completion-Routine aufsetzen
*

 move.l   MSys+MacSys_in_interrupt,a4
 addq.l   #1,(a4)                       ; Tip von Tempi

     IF   EVNT_IO
 move.l   #mdev_completion_routine,ioCompletion(sp)
 move.l   #mdev_unsel,ioMagiCUnsel(sp)  ; Unselect-Routine bzw. Retcode
 move.l   act_appl,ioMagiCApp(sp)       ; für wakeup
     ELSE
 clr.l    ioCompletion(sp)
     ENDIF

*
* Ab ins MacOS
*

 move.l   MSys+MacSys_a5,a5
 lea      (sp),a2
 MAC
 pea      (a2)                     ; ioBuf
 move.l   a3,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_pwrite
 jsr      (a0)
 addq.l   #8,sp
 ATARI

 subq.l   #1,(a4)                       ; Tip von Tempi

*
* Fehlercode auswerten bzw. auf Beendigung warten
*

 tst.l    d0
 bmi.b    mdev_wr_err

     IF   EVNT_IO
 lea      ioMagiCUnsel(sp),a0
 moveq    #0,d0                         ; kein TimeOut
 jsr      evnt_IO
 tst.l    d0                            ; TOS-Fehlercode
 bmi.b    mdev_wr_err                   ; Fehler
     ELSE
mdev_wr_loop:
 jsr      appl_yield
 tst.w    ioResult(sp)
 bgt.b    mdev_wr_loop
 move.w   ioResult(sp),d0
 beq.b    mdev_wr_ok
 ori.l    #$ffff0000,d0                 ; Hiword = -1
 bra.b    mdev_wr_err
     ENDIF

*
* Fehlercode auswerten
*

mdev_wr_ok:
 move.l   ioActCount(sp),d0
mdev_wr_err:
 st.b     xfds_dirty(a6)           ; Daten geändert
 move.l   _hz_200,xfds_lastacc(a6) ; Zeit des letzten Zugriffs!

*
* Semaphore wieder freigeben
*

;jsr      appl_endcritic           ; darf wieder terminiert werden
 move.l   d0,a4                    ; Rückgabewert merken
 lea      xfds_sem(a6),a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 move.l   a4,d0

mdev_wr_ende:
 adda.w   #io_sizeof,sp
 movem.l  (sp)+,a3/a4/a5/a6
 rts

mdev_wr_old:
     ENDIF

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; buffer
 move.l   d0,-(sp)                 ; count
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_write
 jsr      (a0)
 lea      12(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_getc( a0 = FD *f, d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rückgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*

mdev_getc:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_getc
 jsr      (a0)
 addq.l   #6,sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_getline( a0 = FD *f, a1 = char *buf, d1 = long size,
*                      d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rückgabe: Anzahl gelesener Bytes oder Fehlercode
*

mdev_getline:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; mode
 move.l   d1,-(sp)                 ; size
 move.l   a1,-(sp)                 ; buf
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_getline
 jsr      (a0)
 lea      14(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_putc( a0 = FD *f, d0 = int mode, d1 = long value )
*
* mode & 0x0001:    cooked
*
* Rückgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

mdev_putc:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d1,-(sp)                 ; val
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_putc
 jsr      (a0)
 lea      10(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_stat(a0 = FD *f, a1 = long *unselect,
*                  d0 = int rwflag, d1 = long apcode)
*

mdev_stat:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   d1,-(sp)                 ; apcode
 move.w   d0,-(sp)                 ; rwflag
 move.l   a1,-(sp)                 ; unsel
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_stat
 jsr      (a0)
 lea      14(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

mdev_seek:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; where
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_seek
 jsr      (a0)
 lea      10(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long mdev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*

mdev_ioctl:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; cmd
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_ioctl
 jsr      (a0)
 lea      10(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long long mdev_datime(a0 = FD *file, a1 = int d[2], d0 = int set)
*

mdev_datime:
 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.w   d0,-(sp)                 ; set
 move.l   a1,-(sp)                 ; d
 move.l   a0,-(sp)                 ; FD
 mva0_mip MSys+MacSys_xfs_dev,macdev_datime
 jsr      (a0)
 lea      10(sp),sp
 ATARI
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long long mdev_close(a0 = FD *file)
*
* schreibt alles zurück, ruft den Dateitreiber auf und gibt ggf.
* den FD frei.
*

mdev_close:
 tst.w    fd_refcnt(a0)            ; FD freigeben ?
 beq.b    mdclo_free
 move.l   a0,-(sp)

 move.l   a5,-(sp)
 move.l   MSys+MacSys_a5,a5
 MAC
 move.l   a0,-(sp)                 ; FD
 mva0_mip  MSys+MacSys_xfs_dev,macdev_close
 jsr      (a0)
 addq.l   #4,sp
 ATARI
 move.l   (sp)+,a5

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
