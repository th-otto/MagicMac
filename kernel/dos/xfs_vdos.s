*
* Dieses Modul enthaelt das Dateisystem (XFS) fuer alle DOS- kompatiblen
* Dateisysteme (DFS).
* Die meisten Funktionen werden von diesem XFS durchgefuehrt, fuer
* Spezialfunktionen wird d_dfs des DMD verwendet
*


_hz_200        EQU $4ba

FINDDIR        EQU  0
FINDXDIR       EQU  1
FINDNDIR       EQU  2
FINDALL        EQU  3
FINDLABL       EQU  4


DEBUG     EQU  2

     INCLUDE "errno.inc"
     INCLUDE "structs.inc"
     INCLUDE "debug.inc"
     INCLUDE "kernel.inc"
     INCLUDE "basepage.inc"
	 INCLUDE "magicdos.inc"

     SUPER

     XDEF      dosxfs
     XDEF      _dir_srch
     XDEF      reopen_FD,close_DD  ; => DFS_FAT,VFAT
     XDEF      get_DD              ; => VFAT
     XDEF      _xattr              ; => VFAT
     XDEF      filename_match
     XDEF      conv_8_3            ; str => 8+3
     XDEF      rcnv_8_3            ; 8+3 => str
     XDEF      init_DTA

* von STD

     XREF      strlen
     XREF      stricmp
     XREF      fast_clrmem

* vom BIOS

     XREF      config_status
     XREF      halt_system

* vom AES

	 XREF act_appl
     XREF      appl_begcritic
     XREF      appl_endcritic

* vom DOS

     XREF      dfs_u_drv
     XREF      toupper
     XREF      str_to_con
     XREF      int_malloc,int_mfree
     XREF      _fread,_fwrite,__fseek
     XREF      proc_info
     XREF      dfs_longnames

* von VFAT

     XREF      vf_readdir
     XREF      vf_path2DD
     XREF      vf_dirsrch
     XREF      vf_ffree
     XREF      vf_crnam
     XREF      vf_rlabel

	TEXT

dosxfs:
 DC.B     'VDOS_XFS'               ; Name
 DC.L     0                        ; naechstes XFS
 DC.L     FS_KNOPARSE+FS_NOXBIT    ; Flags
 DC.L     dxfs_init
 DC.L     dxfs_sync
 DC.L     dxfs_pterm
 DC.L     dxfs_garbcoll
 DC.L     dxfs_freeDD
 DC.L     dxfs_drv_open
 DC.L     dxfs_drv_close
 DC.L     dxfs_path2DD
 DC.L     dxfs_sfirst
 DC.L     dxfs_snext
 DC.L     dxfs_fopen
 DC.L     dxfs_fdelete
 DC.L     dxfs_frename
 DC.L     dxfs_xattr
 DC.L     dxfs_attrib
 DC.L     dxfs_chown
 DC.L     dxfs_chmod
 DC.L     dxfs_dcreate
 DC.L     dxfs_ddelete
 DC.L     dxfs_DD2name
 DC.L     dxfs_dopendir
 DC.L     dxfs_dreaddir
 DC.L     dxfs_drewinddir
 DC.L     dxfs_dclosedir
 DC.L     dxfs_dpathconf
 DC.L     dxfs_dfree
 DC.L     dxfs_wlabel
 DC.L     dxfs_rlabel
 DC.L     dxfs_symlink
 DC.L     dxfs_readlink
 DC.L     dxfs_dcntl


dosdev_drv:
 DC.L     dosdev_close
 DC.L     dosdev_read
 DC.L     dosdev_write
 DC.L     dosdev_stat
 DC.L     dosdev_seek
 DC.L     dosdev_datime
 DC.L     dosdev_ioctl
 DC.L     dosdev_getc
 DC.L     dosdev_getline
 DC.L     dosdev_putc


***********************************************
*
* void dxfs_init( void )
*
* Initialisiert seinerseits alle DFSs
*

;    init:
;         DC.B $d,$a,'VFAT-XFS installiert.',$d,$a,0
;         EVEN

dxfs_init:
     DEB  'DFSs initialisieren'

;     lea      init(pc),a0
;     jsr      str_to_con

 move.l   #dfs_u_drv,(dfs_list).l
 clr.l    dfs_longnames.w               ; keine langen Dateinamen
 move.l   a5,-(sp)
 move.l   (dfs_list).l,a5
 bra.b    dosi_nfs
dosi_nloop:
 move.l   dfs_init(a5),a0
 jsr      (a0)
 move.l   dfs_next(a5),a5
dosi_nfs:
 move.l   a5,d0
 bne.b    dosi_nloop
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void dxfs_sync( a0 = DMD *d )
*

dxfs_sync:
 move.l   d_dfs(a0),a2
 move.l   dfs_sync(a2),a2
;move.l   a0,a0                    ; DMD *
 jmp      (a2)


**********************************************************************
*
* void dxfs_pterm( a0 = DMD *d, a1 = PD *pd )
*
* Ein Programm wird gerade terminiert. Das XFS kann alle von diesem
* Programm belegten Ressourcen freigeben.
* Alle Ressourcen, von dem der Kernel weiss (d.h. geoeffnete Dateien)
* sind bereits vom Kernel freigegeben worden.
*

dxfs_pterm:
 move.l   a4,-(sp)
 move.l   d_root(a0),d0
 beq.b    dpt_rts
 move.l   a1,a4
 bsr.b    _dxfs_pterm
dpt_rts:
 move.l   (sp)+,a4
 rts
_dxfs_pterm:
 move.l   a5,-(sp)
_dpt_nxt:
 move.l   d0,a5
 btst     #FAB_SUBDIR,fd_attr(a5)  ; Unterverzeichnis ?
 beq.b    dpt_nxt                  ; nein, Ende
* entsperre Kinder, falls vorhanden
 move.l   fd_children(a5),d0
 beq.b    dpt_nochildren
 bsr.b    _dxfs_pterm              ; Rekursion !
dpt_nochildren:
* Entsperre Prototyp-DD_FD
 cmp.l    fd_owner(a5),a4          ; gehoert dem terminierenden Prozess ?
 bne.b    dpt_other                ; nein
 move.l   a5,a0
 bsr      close_DD                 ; ja, freigeben
dpt_other:
 bra.b    dpt_nxtclone
* entsperre Clone-FDs
dpt_cloneloop:
 move.l   d0,a5
 cmp.l    fd_owner(a5),a4
 bne.b    dpt_nxtclone
 move.l   a5,a0
 bsr      close_DD
dpt_nxtclone:
 move.l   fd_multi(a5),d0          ; erster Clone
 bne.b    dpt_cloneloop
 move.l   fd_multi1(a5),a5         ; wieder zum ersten Clone
dpt_nxt:
 move.l   fd_next(a5),d0           ; Geschwister bearbeiten
 bne.b    _dpt_nxt
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long dxfs_drv_open( a0 = DMD *dmd )
*
* Gibt die Anforderung einfach an den DFS-
* Untertreiber weiter.
*

dxfs_drv_open:
     DEBON
 move.l   d_dfs(a0),d0
 bne      ddo_mediach              ; schon initialisiert
     DEB  $99,'ffne neues DOSXFS- Laufwerk'
 movem.l  a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = DMD *

; ermittle, ob lange Dateinamen erlaubt sind
 moveq    #1,d0
 move.w   d_drive(a5),d1
 lsl.l    d1,d0
 and.l    dfs_longnames.w,d0
 sne      d0
 andi.w   #1,d0
 move.w   d0,d_flags(a5)

 move.l   (dfs_list).l,a4
 bra.b    ddo_nfs
ddo_nloop:
 move.l   dfs_drv_open(a4),a1
 move.l   a5,a0                    ; DMD
 jsr      (a1)
 tst.l    d0
 beq.b    ddo_valid                ; alles OK, DMD gueltig
 move.l   dfs_next(a4),a4
ddo_nfs:
 move.l   a4,d0
 bne.b    ddo_nloop
 moveq    #EDRIVE,d0               ; kein DOS- FS
 bra.b    ddo_ende
ddo_valid:
 move.l   #dosxfs,d_xfs(a5)
 move.l   d_root(a5),a0
 move.l   #dosdev_drv,fd_dev(a0)   ; Geraetetreiber fuer FD der Root
 move.l   a0,fd_multi1(a0)         ; Root ist eigener Prototyp
ddo_ende:
 movem.l  (sp)+,a4/a5
 rts
ddo_mediach:
;     DEB  'Diskwechseltest eines DOSXFS- Laufwerks'
 move.l   d0,a1
 move.l   dfs_drv_open(a1),a1
 jmp      (a1)


**********************************************************************
*
* long dxfs_drv_close( a0 = DMD *dmd , d0 = int mode)
*
* mode == 0:   Frage, ob schliessen erlaubt, ggf. schliessen
*         1:   Schliessen erzwingen, muss E_OK liefern
*
* Leitet das Schliessen eines Laufwerks einfach
* an den Untertreiber weiter
*

dxfs_drv_close:
 movem.l  a5/d7,-(sp)
 move.l   a0,a5                    ; dmd
 move.w   d0,d7                    ; mode
 bne.b    drvclo_free              ; einfach nur freigeben

*
* 1. Fragemodus
*

; zunaechst die Strukturen des XFS pruefen
 move.l   d_root(a5),d0
 beq.b    drvclo_nr                ; ???
;move.w   d7,d7                    ; global
 move.l   d0,a0
 bsr.s    free_all_FDs
 bmi.b    drvclo_ende              ; Fehler
; dann nachsehen, ob das DFS das Laufwerk schliessen kann
drvclo_nr:
 move.l   d_dfs(a5),a2
 move.l   dfs_drv_close(a2),a2
 move.l   a5,a0                    ; DMD *
 moveq    #0,d0                    ; Fragemodus
 jsr      (a2)
 tst.l    d0                       ; war Fragemodus, Schliessen verweigert
 bmi.b    drvclo_ende              ; Das DFS meldet z.B. Plattenbetrieb
 moveq    #1,d7

*
* 2. Ausfuehren
*

drvclo_free:
; Alles OK, jetzt freigeben
 move.l   d_dfs(a5),a2
 move.l   dfs_drv_close(a2),a2
 move.l   a5,a0                    ; DMD *
 move.w   d7,d0                    ; freigeben
 jsr      (a2)
 move.l   d_root(a5),d0
 beq.b    drvclo_ende
;moveq    #1,d7                    ; freigeben
 move.l   d0,a0
 bsr.s    free_all_FDs
drvclo_ende:
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* EQ/MI long free_all_FDs(a0 = FD *dir, d7 = int mode)
*
* mode == 0:   Anfragemodus. Gibt EACCDN, falls noch Dateien offen
*              sind.
*
* mode == 1:   Ausfuehrungsmodus. Gibt alle Strukturen frei.
*              Greift keine Verkettungen an.
*

free_all_FDs:
 move.l   fd_children(a0),d0
 beq.b    frdd_nochild             ; erst alle Unterverzeichnisse freigeben
 move.l   a0,-(sp)
 move.l   d0,a0
 bsr.b    free_all_FDs
 move.l   (sp)+,a0
 bmi.b    frdd_ende                ; Fehler
frdd_nochild:
 move.l   fd_next(a0),-(sp)
;move.l   a0,a0
 bsr.s    free_FDs                 ; FDs selbst freigeben
 move.l   (sp)+,a0
 bmi.b    frdd_ende                ; Fehler
 move.l   a0,d0
 bne.b    free_all_FDs             ; folgende Dateien freigeben
frdd_ende:
 rts


*********************************************************************
*
* EQ/NE long free_FDs( a0 = FD *file, d7 = int mode )
*
* <file> ist der Prototyp- FD einer Datei.
*
* mode == 0: Anfragemodus
* mode == 1: Ausfuehrungsmodus. FD und alle Kopien derselben Datei
*            ("Clones") werden freigeben. Veraendert keine Verkettungen.
*

free_FDs:
 tst.w    d7                       ; Anfragemodus ?
 bne.b    ffd_free                 ; nein, ausfuehren
 tst.l    fd_owner(a0)             ; FD belegt ?
 bne.b    ffd_eaccdn
 move.l   fd_multi(a0),a0
 bra.b    ffd_nxt
ffd_free:
 move.l   fd_longname(a0),d0
 beq.b    ffd_no_lname
 move.l   a0,-(sp)
 move.l   d0,a0
 jsr      int_mfree                ; langen Pfadnamen freigeben
 move.l   (sp)+,a0
ffd_no_lname:
 move.l   fd_multi(a0),-(sp)
 jsr      int_mfree                ; FD selbst freigeben
 move.l   (sp)+,a0
ffd_nxt:
 move.l   a0,d0
 bne.b    free_FDs
 rts
ffd_eaccdn:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long dxfs_dfree( a0 = DD_FD *dir, a1 = long buf[4] )
*

dxfs_dfree:
 move.l   fd_dmd(a0),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_dfree(a2),a2
;move.l   a1,a1
;move.l   a0,a0
 jmp      (a2)


**********************************************************************
*
* long dxfs_path2DD( a0 = DD_FD * reldir,
*                    a1 = char *pathname,
*                    d0 = int  mode )
*
* a1 ist der Pfad ohne Laufwerk
* -> d0 = DD_FD *dir     oder Fehlercode
* -> d1 = char *fname
*
* Wandelt den Pfadnamen, der relativ zu <reldir> gegeben ist, in
* einen DD_FD um. <pathname> ist immer ohne Laufwerk angegeben, aber
* ggf. mit fuehrendem '\\'. Beginnt <pathname> mit '\\', muss das XFS ab
* der Root suchen.
*
* Der DD_FD ist immer der Prototyp- FD eines Verzeichnisses.
*
* mode == 0: pathname zeigt auf eine beliebige Datei. Gib den DD_FD
*            zurueck, in dem die Datei liegt.
*            gib in a0 einen Zeiger auf den isolierten Dateinamen
*            zurueck.
*         1: pathname ist selbst ein Verzeichnis, gib dessen DD_FD
*            zurueck, a0 ist danach undefiniert.
*
* Rueckgabe:
*  d0 = FD des Pfades, der Referenzzaehler ist entsprechend erhoeht
*  d1 = Rest- Dateiname ohne beginnenden '\\'
* oder
*  d0 = ELINK
*  d1 = Restpfad ohne beginnenden '\\'
*  a0 = FD des Pfades, in dem der symbolische Link liegt. Dies ist
*       wichtig bei relativen Pfadangaben im Link. Der Referenzzaehler des
*       FD ist entsprechend erhoeht
*  a1 = NULL
*            Der Pfad stellt den Parent des Wurzelverzeichnisses
*            dar, der Kernel kann, wenn das Laufwerk U: ist, auf
*            U:\ zurueckgehen.
*  a1 = Pfad des symbolischen Links. Der Pfad enthaelt einen
*            symbolischen Link, womoeglich auf ein
*            anderes Laufwerk. Der Kernel muss den Restpfad <a0>
*            relativ zum neuen DD_FD <a0> umwandeln.
*            a1 zeigt auf ein Wort fuer die Zeichenkettenlaenge
*            (gerade Zahl auf gerader Adresse, inkl. EOS),
*            danach folgt die Zeichenkette. Der Puffer kann
*            fluechtig sein, der Kernel kopiert den Pfad um.
*

dxfs_path2DD:
     DEBT a1,'DOSXFS sucht einen Pfad: '
 movem.l  a4/a5/a3/d7/d6,-(sp)
 move.w   d0,d6                    ; d6 = mode
 move.l   a1,a3                    ; a3 = Pfad
 cmpi.b   #$5c,(a3)                ; ab Root
 bne.b    dp2d_relpath             ; nein -> relativer Pfad
 addq.l   #1,a3                    ; backslash ueberspringen
 move.l   fd_dmd(a0),a0
 movea.l  d_root(a0),a0            ; absoluter Pfad: Root- FD
dp2d_relpath:
 move.l   a0,a4                    ; Anfangspfad

 tst.l    fd_owner(a4)             ; geoeffnet ?
 beq.b    pthdd_loop               ; nein, alles OK
 btst     #BOM_RDENY,fd_mode+1(a4) ; gesperrt ?
 bne      pthdd_eaccdn             ; ja, Fehler

* Schleife:

pthdd_loop:

 clr.w    d7                       ; Laenge des Pfadelements nach d7
 movea.l  a3,a0
 bra.b    pthdd_bsl
pthdd_bslloop:
 cmpi.b   #$5c,(a0)
 beq.b    pthdd_bslfound
 addq.l   #1,a0
 addq.w   #1,d7
pthdd_bsl:
 tst.b    (a0)
 bne.b    pthdd_bslloop
* kein backslash gefunden, a3 zeigt auf letztes Pfadelement
* Sonderbehandlung, falls letztes Element == "." oder ".."
 tst.w    d6                       ; Pfad ist DD ?
 bne.b    pthdd_bslfound           ; ja, Pfadelement behandeln
 cmpi.b   #'.',(a3)                ; "." oder ".." ?
 bne      pthdd_ok                 ; nein, Dateiname (letztes Element) zurueck
 tst.b    1(a3)
 beq.b    pthdd_bslfound           ; "."
 cmpi.b   #'.',1(a3)               ; ".." ?
 bne      pthdd_ok                 ; nein, Dateiname zurueckgeben
* backslash gefunden, oder <flag> == TRUE
pthdd_bslfound:
 tst.w    d7
 beq      pthdd_nxtpth             ; \\ wie \.\ behandeln !!!
 move.b   (a0),d0                  ; '\\' oder '\0'
 move.l   a3,a0
 bsr      chk_specdir
 addq.w   #1,d0
 beq      pthdd_nxtpth             ; '.'
 bgt.b    pthdd_nospec             ; weder "." noch ".."
 neg.w    d0
 subq.w   #1,d0
pthdd_ploop:
 movea.l  fd_parent(a4),a4         ; ".n." => n Schritte zurueck
 move.l   a4,d1
 bgt.b    pthdd_parnor

* war schon Wurzelverzeichnis

 suba.l   a1,a1                    ; a1 = NULL
 lea      0(a3,d7.w),a0            ; a0 = Restpfad
 move.l   a0,d1
 move.l   #ELINK,d0
 bra      pthdd_ende

pthdd_parnor:
 dbra     d0,pthdd_ploop
 bra      pthdd_nxtpth


pthdd_nospec:

* Wir muessen immer die langen Dateinamen beruecksichtigen, weil
* der DD_FD in fd_longname den langen Pfadnamen enthalten muss!

     DEBT a3,' vf_path2DD mit Pfad '

 clr.l    -(sp)
 pea      (sp)                     ; ggf. Zeiger auf Symlink
 move.w   d7,d0                    ; Laenge des Pfadelements
 move.l   a3,a1                    ; char *path
 move.l   a4,a0                    ; DD_FD *fd
 jsr      vf_path2DD
 addq.l   #4,sp
 move.l   (sp)+,a0                 ; ggf. Symlink

     DEBL d0,' vf_path2DD => '

 tst.l    d0
 bgt.b    pthdd_okdd               ; kein Fehler
 cmpi.l   #ELINK,d0
 bne.b    pthdd_ende               ; Fehler, gib Fehlercode != ELINK
 move.l   a0,a1                    ; ggf. Wert des Links
 lea      0(a3,d7.w),a0            ; ggf. Restpfad beim Link
 cmpi.b   #$5c,(a0)+               ; gehe auf naechstes Pfadelement
 beq.b    pthdd_oksl
 subq.l   #1,a0
pthdd_oksl:
 move.l   a0,d1                    ; Restpfad
 move.l   a4,a0                    ; DD, in dem der Link liegt
;move.l   #ELINK,d0
 bra.b    pthdd_ref                ; ELINK und referenzierten DD

pthdd_okdd:
 move.l   d0,a5                    ; -> DD

pthdd_sdir:
 move.l   a5,a4                    ; neues Verzeichnis

pthdd_nxtpth:
 add.w    d7,a3                    ; Restpfad weiterschalten
 tst.b    (a3)+                    ; Ende des Pfads ? (backslash ueberspringen)
 bne      pthdd_loop               ; ja, weiter
 subq.l   #1,a3
pthdd_ok:
 move.l   a3,d1                    ; Restpfad ist Dateiname
 move.l   a4,d0
pthdd_ref:
 addq.w   #1,fd_refcnt(a4)         ; DD wird vom Kernel referenziert!
pthdd_ende:
 movem.l  (sp)+,a4/a5/a3/d7/d6
     DEBL d0,'DOSXFS fand Pfad => '
     DEBT d1,'mit Restpfad (Dateiname) '
 rts
pthdd_eaccdn:
 moveq    #EACCDN,d0               ; gesperrt, return(EACCDN)
 bra      pthdd_ende


**********************************************************************
*
* long dxfs_DD2name(a0 = DD_FD *d, a1 = char *buf, d0 = int buflen)
*
* <d> ist ein Prototyp-FD, der ein Verzeichnis darstellt, ein DD_FD.
* Wandelt DD in einen Pfadnamen um
* BUG: buflen wird nicht beruecksichtigt
*

dxfs_DD2name:
* erst Domain ermitteln (wg. langer Namen)
 move.l   act_pd.l,a2
 move.b   p_flags(a2),d2
 andi.w   #1,d2                    ; Bit 0: Domain MiNT (1) oder TOS (0)
* Rekursionsbeginn: erst Parent in den Puffer
_dd2name:
 move.l   fd_parent(a0),d1
 beq.b    _dgp_top
 move.l   a0,-(sp)
;move.l   a1,a1                    ; Puffer
 move.l   d1,a0                    ; DD
;move.w   d0,d0
 bsr.b    _dd2name
 move.b   #$5c,(a1)+               ; mit backslash abschliessen
;move.l   a1,a1                    ; neuer Puffer
 move.l   (sp)+,a0                 ; den DD selbst
* dann das Verzeichnis selbst
_dgp_top:
 move.w   d2,-(sp)                 ; d2 retten, TOS-Domain?
 beq.b    _dgp_tos                 ; ja, Kurznamen nehmen
 move.l   fd_longname(a0),d2       ; langer Name?
 beq.b    _dgp_tos                 ; nein
 move.l   fd_dmd(a0),a2            ; DMD
 tst.w    d_flags(a2)              ; lange Namen aktiviert?
 beq.b    _dgp_tos                 ; nein
* langen Namen kopieren
 move.l   d2,a2
_dgp_loop:
 move.b   (a2)+,(a1)+
 bne.b    _dgp_loop
 subq.l   #1,a1
 bra.b    _dgp_rts
* kurzen Namen kopieren
_dgp_tos:
;move.l   a1,a1
 lea      fd_name(a0),a0
 bsr      rcnv_8_3
 movea.l  d0,a1
_dgp_rts:
 move.w   (sp)+,d2
 moveq    #0,d0                    ; kein Fehler
 rts


**********************************************************************
*
* long dxfs_sfirst(a0 = DD_FD *d, a1 = char *name, d0 = DTA *dta,
*                  d1 = int attrib)
*
* Rueckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

dxfs_sfirst:
 movem.l  a4/a5/a6,-(sp)
 move.l   a0,a4                    ; a4 = DD
 move.l   d0,a5                    ; a5 = DTA *
 move.l   a1,a6                    ; a6 = Suchmuster

* Wir wandeln hier den zu suchenden Dateinamen schon ins interne Format um

 move.l   a1,a0                    ; Suchmuster
 move.l   a5,a1                    ; gleich in die DTA
 move.b   d1,11(a5)                ; Suchattribut
 bsr      conv_8_3

* DD oeffnen

 moveq    #OM_RPERM,d0
 move.l   a4,a0
 bsr      reopen_FD
 bmi      fsf_ende
 move.l   d0,a4                    ; a4 = FD *

 moveq    #0,d1                    ; Ab Dateianfang
 lea      (a5),a1                  ; Dateiname im internen Format
 move.l   a4,a0
 bsr      _dir_srch
 bmi      fsf_close                ; Fehlermeldung weitergeben
 move.l   d0,a6                    ; a6 = DIR *
 move.l   d1,-(sp)                 ; pos merken

* User- Bereich (Bytes $15...) fuellen

 move.l   a5,a1               ; DTA *
 move.l   a6,a0               ; DIR *
 bsr      init_DTA

* DFS aufrufen

 move.l   fd_dmd(a4),a2
 move.b   d_drive+1(a2),dta_drive(a5)
 move.l   d_dfs(a2),a2
 move.l   dfs_sfirst(a2),a2
 move.l   a5,d1                    ; d1 = DTA *
 move.l   (sp)+,d0                 ; d0 = naechste pos
 move.l   a6,a1                    ; a1 = DIR *
 move.l   a4,a0                    ; a0 = DD_FD *
 jsr      (a2)                     ; => errcode
fsf_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fsf_err                  ; ja, sofort abbrechen !
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fsf_err                  ; ja, sofort abbrechen !
 move.l   a0,a6                    ; a6 = Link
 move.l   a4,a0
 move.l   d0,a4                    ; a4 = errcode
 bsr      close_DD
 move.l   a6,a0
 move.l   a4,d0
 bge.b    fsf_ende                 ; kein Fehler
 cmpi.l   #ELINK,d0
 beq.b    fsf_ende
fsf_err:
 clr.b    (a5)                     ; Fehler! DTA ungueltig machen
fsf_ende:
 movem.l  (sp)+,a6/a5/a4
 rts


**********************************************************************
*
* long dxfs_snext(a0 = DTA *dta, a1 = DMD *d)
*
* Rueckgabe:    d0 = errcode
*             oder
*              d0 = ELINK
*              a0 = char *link
*

dxfs_snext:
                                   ; war schon einmal ein
 tst.b    (a0)                     ;  Fsfirst() oder Fsnext() erfolglos ?
 beq      fsn_enmfil               ; ja => return(ENMFIL)
 move.l   d_dfs(a1),a2
 move.l   dfs_snext(a2),a2
;move.l   a1,a1                    ; a1 = DMD *
;move.l   a0,a0                    ; a0 = DTA *
 jmp      (a2)                     ; macht bereits init_DTA, loescht ggf. DTA
fsn_enmfil:
 moveq    #ENMFIL,d0
 rts


**********************************************************************
*
* d0 = long _dxfs_fopen(a0 = DD_FD *d, a1 = char *name, d0 = int omode,
*                       d1 = int attrib, d2 = int dmode.cmd, a2 = long arg)
*
* d2.hi   cmd
* d2.lo   open- Modus fuer den DD_FD (-1 = isopen)
*
**********************************************************************
*
* d0 = FD * dxfs_fopen(a0 = DD_FD *d, a1 = char *name, d0 = int omode,
*                      d1 = int attrib )
*
* Oeffnet und/oder erstellt Dateien, Oeffnet den Dateitreiber.
* Der Open- Modus ist vom Kernel bereits in die interne
* MagiX- Spezifikation konvertiert worden.
*
* Der Open- Modus O_TRUNC kann hier ignoriert werden, weil er vom
* Dateitreiber (MDEV) ausgewertet wird.
* Es ist hier angenommen, dass folgende Modi andere implizieren
* sollten:
*
* O_TRUNC      => OM_WPERM
* O_CREAT      => OM_WPERM
* O_EXCL       => O_CREAT     => O_WPERM
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel uebernommen.
*
* Rueckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*
* Diese Funktion bearbeitet auch Dcntl PROC_CREATE und
* DEV_M_INSTALL, aber nur innerhalb dieses Moduls.
*

dxfs_fopen:
;moveq    #0,d2                    ; Hiword loeschen, kein Dcntl
 moveq    #OM_RPERM,d2             ; nur Lesezugriff auf den DD
 btst     #BO_CREAT,d0
 bne.b    fop_dd_wr
 btst     #BO_TRUNC,d0
 beq.b    _dxfs_fopen
; Schreibzugriff auf den DD beabsichtigt
fop_dd_wr:
 ori.w    #OM_WPERM+OM_WDENY,d2    ; Schreibzugriffe anderer verbieten
_dxfs_fopen:
     DEBT a1,'_dxfs_fopen '
     DEBL d0,'        omode '
     DEBL d1,'        attr  '
     DEBL d2,'        cmd   '
 movem.l  d3/d4/d5/d6/d7/a3/a4/a6,-(sp)
 suba.w   #40,sp                   ; (sp):   DIR
                                   ; 32(sp): char *
                                   ; 36(sp): LONG
 clr.l    32(sp)                   ; kein langer Name
 move.l   a0,a4                    ; a4 = DD_FD *
 move.l   a1,a3                    ; a3 = char *name
 move.w   d0,d7                    ; d7 = int omode
 move.w   d1,d6                    ; d6 = int attrib
 move.l   d2,d3                    ; d3 = cmd.hi (bei Dcntl) oder 0
 swap     d3                       ; nur das Hiword
 move.l   a2,d4                    ; d4 = arg (bei Dcntl)

* Verzeichnis oeffnen

 move.w   d2,d0
 bmi.b    fop_isopen               ; DD ist schon geoeffnet!
;move.l   a4,a0
 bsr      reopen_FD
 bmi      fop_ende                 ; Verzeichnis ist blockiert
 move.l   d0,a4                    ; a4 ist unser FD

* Der Verzeichniseintrag wird ermittelt: a6
* ggf. wird das Verzeichnis geoeffnet gelassen

fop_isopen:
 moveq    #FINDALL,d0
 move.l   a3,a1                    ; Name
 move.l   a4,a0                    ; DD_FD
 bsr      dir_srch
 bmi      fop_notexist             ; a6 = DIR *
 move.l   d1,d5                    ; d5 = dirpos
 movea.l  d0,a6

* ###
* Datei existiert. Zugriffskontrolle durch den Kernel
* ###

* Wenn das Flag O_EXCL gesetzt ist, wird das Oeffnen
* verboten (d.h. es werden im Zusammenhang mit O_CREAT nur neue Dateien
* erzeugt, keine existierenden geloescht).

 moveq    #BO_EXCL,d0
 btst     d0,d7
 bne      fop_eaccdn

* Wenn Attribut SubDir, Oeffnen nicht erlaubt!
* Wenn Attribut ReadOnly, nur mit O_RDONLY zu oeffnen erlaubt

 btst     #FAB_SUBDIR,dir_attr(a6) ; Subdir
 bne      fop_eaccdn
 btst     #FAB_READONLY,dir_attr(a6)
 beq      fop_open                 ; weder SubDir noch Rdonly => open
fop_rdonly:
 btst     #BOM_WPERM,d7            ; will ich schreiben ?
 bne      fop_eaccdn               ; ja => Fehler
 btst     #FAB_SUBDIR,dir_attr(a6) ; Subdir ?
 beq      fop_open                 ; nein, OK
 btst     #BOM_EXEC,d7             ; Subdir und will ausfuehren ?
 bne      fop_eaccdn               ; Fehler !
 bra      fop_open

* ###
* Datei existiert nicht.
* ###

fop_notexist:
 cmpi.l   #EFILNF,d0
 bne      fop_close                ; boeser Fehler

* Wenn das Flag O_CREAT gesetzt ist, wird die Datei erstellt

 moveq    #BO_CREAT,d0
 btst     d0,d7
 beq      fop_efilnf
 clr.b    (sp)                     ; Leername
/*
 move.l   d4,a6                    ; zu erstellendes DIR
 cmpi.w   #FILE_CREATE,d3
 beq.b    fop_no_conv              ; nix konvertieren, DIR unveraendert
*/
 move.l   sp,a6                    ; DIR auf dem Stack
 move.l   a6,a1
 move.l   a3,a0
 bsr      conv_8_3                 ; Dateinamen ins interne Format
 move.b   d6,dir_attr(a6)          ; Attribut einsetzen

* Name auf "." oder "..", auf Nullname und Joker und ':' im Dateinamen

 move.l   a3,a0
 bsr      tst_name
 bne      fop_ebadrq

* geloeschten oder leeren Directory- Eintrag suchen
* dabei ggf. den 8+3-Namen modifizieren

fop_no_conv:
 pea      36(sp)                   ; Pos. des ersten DIR-Eintrags
 pea      32+4(sp)                 ; NULL oder Zeiger auf langen Namen
 move.l   a6,-(sp)                 ; 8+3-Name, ggf. modifizieren!
 move.l   a3,a1                    ; neuer Name
 move.l   a4,a0                    ; DD_FD *
 moveq    #-1,d1                   ;
 moveq    #-1,d0                   ; keine special position
 bsr      vf_ffree
 adda.w   #12,sp
 move.l   d0,d5                    ; d5 = dirpos fuer Haupteintrag
 bmi      fop_close                ; Fehler

* Ein leerer Eintrag wurde gefunden: bei Pos. d5

 cmpi.w   #FILE_CREATE,d3
 beq.b    fop_wr                   ; gleich schreiben

* Restliche Eintraege zunaechst mit 0en initialisieren

 lea      dir_xftype(sp),a0
 clr.w    (a0)+                    ; dir_xftype
 clr.l    (a0)+                    ; dir_xdata
 clr.l    (a0)+                    ; dir_dummy, dir_stcl_f32

* Zeit und Datum einsetzen

 move.w   dos_time.l,d0
 ror.w    #8,d0
 move.w   d0,(a0)+                 ; dir_time
 move.w   dos_date.l,d0
 ror.w    #8,d0
 move.w   d0,(a0)+                 ; dir_date

* Anfangscluster und Laenge auf 0

 clr.w    (a0)+                    ; dir_stcl
 clr.l    (a0)                     ; dir_flen

* Aufruf des DFS-Treibers fuer besondere Funktionen

 move.l   sp,a1                    ; DIR *
 move.l   a4,a0                    ; FD * des Verzeichnisses
 move.l   d4,d1                    ; arg
 move.w   d3,d0                    ; cmd bzw. 0
 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_fcreate(a2),a2
 jsr      (a2)
 tst.l    d0
 bmi      fop_close                ; Fehler beim Erstellen
 move.l   sp,a6

* Dateizeiger des Verzeichnisses auf unseren Eintrag

fop_wr:
 move.l   36(sp),d0                ; erster DIR-Eintrag
 move.l   a4,a0
 bsr      __fseek
 bmi      fop_close

* Unseren Eintrag wegschreiben

 move.l   32(sp),-(sp)             ; char *longname
 move.l   a6,a1                    ; Daten
 move.l   a4,a0                    ; FD
 jsr      vf_crnam                 ; langen Namen und Alias schreiben
 addq.l   #4,sp
 tst.l    d0
 bmi      fop_close                ; Schreibfehler


* ###
*
* Datei oeffnen
*
* a6      = DIR   *direntry
* d5      = long  dirpos
* a4      = DD_FD *dd
* d7      = int   omode
*
* ###

fop_open:
 moveq    #0,d0
 tst.w    d3
 bne      fop_close                ; Dcntl oeffnet keine Datei, E_OK

* Testen, ob die Datei schon geoeffnet ist

 move.l   d5,d0
 move.l   a4,a0
 bsr      file_is_open
 beq.b    fop_open_proto           ; Datei war noch nicht geoeffnet

*
* Datei war schon geoeffnet. Wir legen einen Clone an.
*

 move.l   d0,a0                    ; FD
 move.w   d7,d0                    ; omode
 bsr      reopen_FD
 bmi      fop_close                ; Fehler bei Zugriffsrechten
 move.l   d0,a3
 bra.b    fop_ok

*
* Datei war noch nicht geoeffnet. Prototyp- FD erstellen
*

fop_open_proto:
 move.l   32(sp),d0                ; ggf. langer Name fuer SubDir
;move.l   d5,d5                    ; dirpos
;move.l   a6,a6                    ; DIR
;move.l   a4,a4                    ; DD_FD
 bsr      DIR2protoFD
 bmi      fop_close                ; Fehler beim Erstellen des FD (ELINK ?)
 move.l   d0,a3

* FD initialisieren

 move.l   act_pd.l,fd_owner(a3)
 move.w   d7,fd_mode(a3)

*
* Dateitreiber oeffnen
*

 move.l   fd_ddev(a3),a2
 move.l   ddev_open(a2),a2
 move.l   a3,a0                    ; FD *
 jsr      (a2)
 tst.l    d0
 beq.b    fop_ok

* Fehler beim Oeffnen des Dateitreibers, FD einfach wieder
* freigeben

 move.l   a3,a0
 move.l   d0,a3                    ; Fehlercode merken
 bsr      free_FD
 move.l   a3,d0
 bra.b    fop_close

fop_ok:
 move.w   #1,fd_refcnt(a3)         ; FD einmal referenziert
 move.l   a3,d0                    ; FD *

fop_close:
 swap     d3
 tst.w    d3                       ; FD war schon geoeffnet ?
 bmi.b    fop_ende                 ; ja, nicht schliessen
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fop_ende                 ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fop_ende                 ; ja, sofort abbrechen!!
 move.l   a0,a6                    ; ggf. Link retten
 move.l   d0,d7
; Fehlercode von close_DD durchreichen, wenn E_CHNG oder EDRIVE
 move.l   a4,a0
 bsr      close_DD                 ; nein, FD schliessen
 move.l   a6,a0
 tst.l    d0
 beq.b    fop_cldd_ok              ; kein Fehler bei close_DD
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fop_ende                 ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fop_ende                 ; ja, sofort abbrechen!!
 tst.l    d7                       ; war vorher Fehler ?
 bmi.b    fop_cldd_ok              ; ja, den weitergeben
 beq.b    fop_ende                 ; nein, neuen Fehler weitergeben
; d7 >= 0, d.h. FD geoeffnet
; d0 < 0, d.h. Fehler bei close_DD
; => FD wieder freigeben
 move.l   d0,a3                    ; Fehlercode merken
 move.l   d7,a0
 bsr      free_FD                  ; FD wieder freigeben
 move.l   a3,d7                    ; Fehlercode zurueck
fop_cldd_ok:
 move.l   d7,d0
fop_ende:
 adda.w   #40,sp
 movem.l  (sp)+,a6/a4/a3/d3/d4/d5/d6/d7
 rts
fop_ebadrq:
 moveq    #EBADRQ,d0
 bra.b    fop_close
fop_eaccdn:
 moveq    #EACCDN,d0
 bra.b    fop_close
fop_efilnf:
 moveq    #EFILNF,d0
 bra.b    fop_close


*********************************************************************
*
* long _dxfs_fdelete(a0 = DD *d, a1 = char *name, d0 = int srchattr)
*
* Wird mit Suchattribut 8 fuer das Loeschen eines Labels aufgerufen
*
*********************************************************************
*
* long dxfs_fdelete(a0 = DD *d, a1 = char *name)
*
* Eine Wiederholung im Fall E_CHNG wird vom Kernel uebernommen.
*
* Rueckgabe:
* d0 = ELINK: Datei ist symbolischer Link
*             a0 ist der Dateiname des symbolischen Links
*
* Es koennen keine SubDirs oder Labels geloescht werden, da sie
* per dir_srch nicht gefunden werden
*

dxfs_fdelete:
 moveq    #FINDNDIR,d0        ; keine SubDirs oder Labels !!
_dxfs_fdelete:
 move.l   a4,-(sp)
 movem.l  d0/a1,-(sp)
 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
;move.l   a0,a0
 bsr      reopen_FD
 bmi      fdel_ende3
 move.l   d0,a4                    ; a4 = FD
 movem.l  (sp)+,d0/a1

* Der Verzeichniseintrag wird ermittelt: a6

;move.w   d0,d0                    ; alle Dateien suchen
;move.l   a1,a1                    ; Name
;move.l   a4,a0                    ; DD
 bsr      dir_srch
 bmi      fdel_close
 movea.l  d0,a1                    ; a1 = DIR *
 move.l   d1,d0                    ; d0 = dirpos
 tst.l    d2                       ; Pos. des langen Namens
 bmi.b    fdel_nolong              ; kein langer Name, d1=d0
 move.l   d2,d1                    ; langer Name, d1=d2
fdel_nolong:

* ###
* Datei existiert. Loeschen.
* ###

;move.l   d0,d0                    ; long dirpos
;move.l   a1,a1                    ; DIR *
 move.l   a4,a0                    ; DD *
 bsr      _fdelete

fdel_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fdel_ende                ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fdel_ende                ; ja, sofort abbrechen!!
 move.l   a4,a0
 move.l   d0,a4
 bsr      close_DD
 move.l   a4,d0
fdel_ende:
 move.l   (sp)+,a4
 rts
fdel_ende3:
 addq.l   #8,sp
 bra.b    fdel_ende


**********************************************************************
*
* long dxfs_frename(a0 = DD *altdir, a1 = DD *neudir,
*                   d0 = char *altname, d1 = char *neuname, d2 = int flag)
*
* d2 = 1: Flink
* d2 = 0: Frename
*
* (sp)    neuer DIR-Eintrag, 32 Bytes
* 32(sp)  Zeiger auf langen neuen Namen oder NULL
* 36(sp)  Pos. des ersten DIR-Eintrags fuer neuen Namen (freier Platz)
* 40(sp)  Pos. des ersten DIR-Eintrags der alten Datei (bzw. -1L)
*

dxfs_frename:
 tst.w    d2
 beq.b    fren_fren
 moveq    #EINVFN,d0               ; keine Hardlinks !
 rts
fren_fren:
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
 suba.w   #44,sp
 move.l   a0,a4                    ; a4 = DD *olddir
 move.l   a1,a5                    ; a5 = DD *newdir
 move.l   d0,d4                    ; d4 = char *oldname
 move.l   d1,a3                    ; a3 = char *newname

* Pruefen, ob beide Pfade auf demselben Laufwerk liegen. Wenn nicht, ENSAME.

 move.l   fd_dmd(a4),d0            ; DMD von <olddir>
 cmp.l    fd_dmd(a5),d0            ; DMD von <newdir>
 bne      fren_ensame              ; die DMDs sind nicht dieselben

* Beide DDs oeffnen

 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
;move.l   a4,a0
 bsr      reopen_FD
 bmi      fren_ende2
 cmpa.l   a4,a5
 beq.b    fren_same
 move.l   d0,a4
 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
 move.l   a5,a0
 bsr      reopen_FD
 bgt.b    fren_nosame
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 move.l   a4,a0
 bsr      close_DD
 bra      fren_ende2

fren_same:
 move.l   d0,a4
fren_nosame:
 move.l   d0,a5

* Pruefen, ob neuer Name Nullname ist oder ':?*' enthaelt oder "." oder ".."

 move.l   a3,a0
 bsr      tst_name
 bne      fren_eaccdn

* Wir muessen ERST die alte Datei ermitteln, um im Fall
* "selbes Verzeichnis" feststellen zu koennen, ob der Kurzname,
* d.h. der Haupteintrag, derselbe ist.

* <alt> ermitteln

 moveq    #FINDALL,d0              ; keine Volumes suchen
 move.l   d4,a1                    ; alter Name
 move.l   a4,a0                    ; DD *
 bsr      dir_srch
 bmi      fren_ende
 move.l   d1,d3                    ; d3 = dirpos von alt
 move.l   d2,40(sp)                ; 40(sp) = langer Name von <alt>
 move.l   d0,a6

*
* <alt> existiert, DIR * ist a6, dirpos ist d3
*

* Test auf schreibgeschuetzte Datei

 move.b   dir_attr(a6),d7
 btst     #FAB_READONLY,d7
 beq.b    fren_no_ro               ; nicht schreibgeschuetzt
 move.l   act_pd.l,a0
 btst     #0,p_flags(a0)           ; MiNT-Domain?
 beq      fren_eaccdn              ; nein, Zugriff verweigern
fren_no_ro:

* Wir testen hier, ob die zu verschiebende Datei ein Verzeichnis ist.
* Wenn ja, testen wir, ob sie ein "parent" des Zielverzeichnisses ist.
*  Wenn ja, ist der Verschiebevorgang ungueltig.

 btst     #FAB_SUBDIR,d7
 beq.b    fren_noinvalren
 move.l   fd_multi1(a5),a0
fren_testparloop:
 move.l   fd_parent(a0),d0         ; parent von <newdir>
 beq.b    fren_noinvalren          ; ist schon root
 cmpa.l   d0,a4                    ; selber parent wie die zu verschiebende ?
 bne.b    fren_tpa                 ; nein, weiter
 cmp.l    fd_dirpos(a0),d3         ; selbe Dateiposition ?
 beq      fren_eaccdn              ; Ja, Fehler
fren_tpa:
 move.l   d0,a0
 bra.b    fren_testparloop
fren_noinvalren:

* Wir erzeugen hier schon den neuen Haupteintrag im Speicher, da
* uns der Dateipuffer fuer die alte Datei gleich floeten geht.

* Neuen Namen ins interne Format wandeln, nach (sp)

 lea      (sp),a1
 move.l   a3,a0                    ; neuer Name
 bsr      conv_8_3
 lea      dir_attr(sp),a0
 lea      dir_attr(a6),a1
 move.b   (a1)+,(a0)+              ; Ausser Namen andere Daten uebernehmen
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)

* Pruefen, ob <neu> schon existiert.
* Wenn ja, und es ist nicht dieselbe Datei, EACCDN zurueckgeben.

 moveq    #0,d0                    ; Dateizeiger an den Anfang
 move.l   a5,a0                    ; DD *newdir
 bsr      __fseek                  ; noetig, da bei (newdir==olddir) verstellt!
 bmi      fren_ende
 moveq    #FINDALL,d0              ; keine Volumes suchen
 move.l   a3,a1                    ; neuer Name
 move.l   a5,a0                    ; DD *newdir
 bsr      dir_srch
 cmpi.l   #EFILNF,d0
 beq.b    fren_ok                  ; Datei nicht gefunden, alles OK
 tst.l    d0
 bmi      fren_ende                ; anderer Fehlercode
; Datei <alt> existiert schon
 cmpa.l   a4,a5                    ; selbes Verzeichnis ?
 bne      fren_eaccdn              ; nein, Datei existiert schon
 cmp.l    d1,d3                    ; dirpos (Haupteintrag) gleich ?
 bne      fren_eaccdn              ; nein, Datei existiert schon

*
* Entweder existiert die neue Datei noch nicht, oder sie
* ist identisch mit der alten, d.h. es hat sich nur der
* lange Name geaendert.
*

* Suche freien Platz im neuen Verzeichnis, der den neuen Namen
* aufnehmen kann.

fren_ok:
 pea      36(sp)                   ; Pos. des ersten DIR-Eintrags
 pea      32+4(sp)                 ; NULL oder Zeiger auf langen Namen
 pea      8(sp)                    ; 8+3-Name, ggf. modifizieren!
 move.l   a3,a1                    ; neuer Name
 move.l   a5,a0                    ; DD_FD *
 moveq    #-1,d0                   ; special position invalid
 cmpa.l   a4,a5                    ; <newdir> == <olddir> ?
 bne.b    fren_nospecpos           ; nein, keine special position
 move.l   40+12(sp),d1             ; specialpos: alter Anf.eintrag
 move.l   d3,d0                    ; specialpos: alter Haupteintrag
fren_nospecpos:
 bsr      vf_ffree
 adda.w   #12,sp
 move.l   d0,d5                    ; d5 = dirpos fuer Haupteintrag
 bmi      fren_ende                ; Fehler

* Dateizeiger des Verzeichnisses auf unseren Eintrag

 move.l   36(sp),d0                ; erster DIR-Eintrag
 move.l   a5,a0
 bsr      __fseek
 bmi      fren_ende

* Unseren Eintrag wegschreiben

 move.l   32(sp),-(sp)             ; char *longname
 lea      4(sp),a1                 ; Daten
 move.l   a5,a0                    ; FD
 jsr      vf_crnam                 ; langen Namen und Alias schreiben
 addq.l   #4,sp
 tst.l    d0
 bmi      fren_ende                ; Fehler beim Schreiben

* ggf. bei geoeffneten Dateien FD aktualisieren

 move.l   d3,d0
 move.l   a4,a0                    ; olddir
 bsr      file_is_open             ; Datei geoeffnet ?
 beq      fren_weiter              ; nein
; aus der Liste der Geschwister ausklinken
 movea.l  fd_parent(a0),a1
 lea      fd_children(a1),a1
 moveq    #fd_next,d0
 bsr      unlist                   ; in der Liste der Geschwister
 move.l   fd_next(a0),(a1)         ;  aus Liste ausklinken
; in neues Verzeichnis einklinken
 move.l   fd_multi1(a5),a1
 move.l   fd_children(a1),fd_next(a0)
 move.l   a0,fd_children(a1)
; neue Verzeichnisposition eintragen
 move.l   d5,fd_dirpos(a0)
; neuen Parent eintragen
 move.l   a5,fd_parent(a0)
; Namen nur bei Subdir behandeln
 btst.b   #FAB_SUBDIR,fd_attr(a0)
 beq.b    fren_weiter
; Namen kopieren
 move.l   (sp),fd_name(a0)
 move.l   4(sp),fd_name+4(a0)
 move.l   8(sp),fd_name+8(a0)
; langen Namen kopieren
 tst.l    32(sp)                   ; langer Name ?
 beq.b    fren_is_short            ; nein, neuer Name ist kurz
 tst.l    fd_longname(a0)          ; alter Name auch lang ?
 bne.b    fren_cpyln               ; ja, Namen kopieren
 addq.w   #1,fd_refcnt(a0)
 move.l   a0,-(sp)
 jsr      int_malloc               ; langen Namen allozieren
 move.l   (sp)+,a0
 subq.w   #1,fd_refcnt(a0)
 move.l   d0,fd_longname(a0)
fren_cpyln:
 move.l   32(sp),a1
 move.l   fd_longname(a0),a2
fren_cploop:
 move.b   (a1)+,(a2)+
 bne.b    fren_cploop
 bra.b    fren_weiter
fren_is_short:
 move.l   fd_longname(a0),d0       ; alter Name lang ?
 beq.b    fren_weiter              ; nein
 clr.l    fd_longname(a0)
 move.l   d0,a0
 jsr      int_mfree                ; langen Namen freigeben

* Bei Verzeichnissen ggf. den Eintrag ".." korrigieren

fren_weiter:
 btst     #FAB_SUBDIR,d7
 beq      fren_del                 ; kein Subdir
 cmpa.l   a4,a5                    ; verschoben ?
 beq      fren_del                 ; nein, nur umbenannt
; DD ermitteln
 clr.l    -(sp)
 pea      (sp)                     ; Platz fuer Symlink (dummy)
 move.l   32+8(sp),-(sp)           ; char *longname
 move.l   d5,d0                    ; dirpos (Haupteintrag)
 lea      12(sp),a1                ; DIR *main_entry
 move.l   a5,a0                    ; DD *dir
 bsr      get_DD
 lea      12(sp),sp
 tst.l    d0
 bmi.b    fren_errpp               ; "halb" schiefgegangen (kritisch!)
; DD oeffnen (FD ermitteln)
 move.l   d0,a0                    ; DD *
 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
 bsr      reopen_FD
fren_errpp:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 tst.l    d0
 bmi      fren_del                 ; "halb" schiefgegangen (kritisch!)
 move.l   d0,a6                    ; FD
; Position des ".."-Eintrags anfahren
 moveq    #32,d0                   ; zweiter DIR-Eintrag ("..")
 move.l   a6,a0
 bsr      __fseek
 bge.b    fren_weiter2
fren_erppp:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq      fren_ende2               ; ja, sofort abbrechen!!
 bra.b    fren_closea6
fren_weiter2:
; Bis "dir_time" lesen (ueberpruefen, ob der Eintrag ".." ist)
 suba.l   a1,a1                    ; Pufferadresse zurueckgeben
 moveq    #dir_stcl_f32,d0         ; Nur bis dir_stcl_f32
 move.l   a6,a0
 bsr      _fread
 bmi.b    fren_erppp               ; Lesefehler
 beq.b    fren_closea6             ; EOF
 move.l   d0,a1
 cmpi.l   #'..  ',(a1)+
 bne.b    fren_closea6
 cmpi.l   #'    ',(a1)+
 bne.b    fren_closea6
 cmpi.l   #$20202010,(a1)
 bne.b    fren_closea6
; Der Name ist "..". Schreibe "stcl_f32/time/date/stcl"
 move.w   fd_Lstcl+2(a5),d0        ; stcl (Loword)
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; stcl.lo (intel)
 move.w   fd_date(a5),d0
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; date (intel)
 move.w   fd_time(a5),d0
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; time (intel)
 move.w   fd_Lstcl(a5),d0          ; stcl (Hiword)
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; stcl.hi (intel)
 lea      (sp),a1                  ; Daten
 moveq    #8,d0                    ; Anzahl Bytes
 move.l   a6,a0                    ; FD
 bsr      _fwrite
 addq.l   #8,sp
 bmi.b    fren_erppp
; FD schliessen
fren_closea6:
 move.l   a6,a0
 bsr      close_DD
 tst.l    d0
 bmi      fren_errpp               ; "halb" schiefgegangen (kritisch!)


* Datei im alten Verzeichnis loeschen
* ggf. Ueberlappung mit neuem Namen beruecksichtigen

fren_del:
 move.l   40(sp),d1                ; erste Position des alten Namens
 bge.b    fren_dl                  ; langer Name
 move.l   d3,d1                    ; kein langer Name
fren_dl:
 cmpa.l   a4,a5                    ; im selben Verzeichnis ?
 bne.b    fren_deldel              ; nein
 cmp.l    d5,d1                    ; alter 1.Eintrag > neuer letzter ?
 bhi.b    fren_deldel              ; ja, keine Ueberlappung
 move.l   36(sp),d0
 cmp.l    d0,d3                    ; alter letzter < neuer erster ?
 bcs.b    fren_deldel              ; ja, keine Ueberlappung
; wir haben eine Ueberlappung
 cmp.l    d0,d1                    ; alter Anfang < neuer Anfang ?
 bcs.b    fren_del1                ; tritt normalerweise nicht auf
; neuer Anfang <= alter Anfang. Erst ab neuem Ende+1 loeschen.
 moveq    #32,d1
 add.l    d5,d1                    ; Loeschpos: (Ende neu)+1
 bra.b    fren_del2                ; bis (Ende alt)
fren_del1:
 moveq    #-32,d3
 add.l    d0,d3                    ; Endpos: (Anfang neu)-1
fren_del2:
 moveq    #E_OK,d0
 cmp.l    d1,d3                    ; Endpos < Anfangspos ?
 bcs.b    fren_ende                ; ja, nix loeschen
; Ueberlappung beseitigt
fren_deldel:
 move.l   d3,d0
;move.l   d1,d1
 move.l   a4,a0
 bsr      __fdelete

* Directories aktualisieren und schliessen

fren_ende:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fren_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fren_ende2               ; ja, sofort abbrechen!!
 move.l   d0,d7                    ; Rueckgabewert retten
 cmpa.l   a4,a5
 beq.b    fren_noa4
 move.l   a4,a0
 bsr      close_DD
 cmpi.l   #E_CHNG,d0               ; Diskwechsel bei close_DD ?
 beq.b    fren_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel bei close_DD ?
 beq.b    fren_ende2               ; ja, sofort abbrechen!!
fren_noa4:
 move.l   a5,a0
 bsr      close_DD
 move.l   d7,d0

fren_ende2:
 adda.w   #44,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3
 rts
fren_eaccdn:
 moveq    #EACCDN,d0
 bra.b    fren_ende
fren_ensame:
 moveq    #ENSAME,d0
 bra.b    fren_ende2               ; a4/a5 nicht geoeffnet !


**********************************************************************
*
* long dxfs_xattr( a0 = DD *dir, a1 = char *name, d0 = XATTR *xa,
*                  d1 = int mode )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurueck)
*         1:   Folge nicht  (d.h. erstelle XATTR fuer den Link)
*

dxfs_xattr:
 movem.l  d7/a3/a4/a5,-(sp)
 move.l   a1,a3                    ; a3 = name
 move.l   d0,a5                    ; a5 = XATTR *
 move.w   d1,d7                    ; d7 = int mode

* DD oeffnen
 moveq    #OM_RPERM,d0
;move.l   a0,a0
 bsr      reopen_FD
 bmi      fxa_ende
 move.l   d0,a4                    ; a4 = FD

 suba.l   a1,a1
 tst.b    (a3)                     ; ist ein Verzeichnis ?
 beq.b    fxa_isdir                ; ja !
 moveq    #FINDALL,d0              ; alle ausser Volume
 move.l   a3,a1                    ; Name
 move.l   a4,a0                    ; DD *
 bsr      dir_srch
 bmi      fxa_close                ; Datei existiert nicht
 move.l   d0,a1

fxa_isdir:
 move.l   a4,a0                    ; DD *
;move.l   a1,a1                    ; DIR *
 move.w   d7,d1                    ; mode
 move.l   a5,d0                    ; XATTR *
 bsr.s    _xattr

fxa_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fxa_ende                 ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fxa_ende                 ; ja, sofort abbrechen!!
 move.l   d0,d7                    ; long errcode
 move.l   a0,a5                    ; char *link
 move.l   a4,a0
 bsr      close_DD
 move.l   a5,a0
 move.l   d7,d0
fxa_ende:
 movem.l  (sp)+,a3/a4/a5/d7
 rts


**********************************************************************
*
* long _xattr( a0 = DD *dir, a1 = DIR *dir, d0 = XATTR *xa,
*              d1 = int mode )
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurueck)
*         1:   Folge nicht  (d.h. erstelle XATTR fuer den Link)
*
* <dir> == NULL:    XATTR fuer das Verzeichnis oder Datei <a0>
*                   (a0 ist ein FD)
*

_xattr:
 movem.l  d7/a6/a5/a4/a2,-(sp)
 move.l   d0,a5                    ; a5 = XATTR *
 move.l   a0,a4                    ; a4 = FD *
 move.l   a1,a6                    ; a6 = DIR *
 move.w   d1,d7

 move.l   a5,a0
 lea      xattr_sizeof(a0),a1
 jsr      fast_clrmem              ; XATTR zunaechst loeschen

 move.l   a6,d0                    ; ist ein FD ?
 beq      _xa_is_fd                ; ja!

; Trage Werte des DIR ein, soweit es fuer alle Dateien gleich ist

 move.l   dir_flen(a6),d1
 ror.w    #8,d1
 swap     d1
 ror.w    #8,d1                    ; intel->motorola
 move.l   d1,xattr_size(a5)
 move.b   dir_attr(a6),d2
 move.w   dir_stcl_f32(a6),d0
 ror.w    #8,d0
 swap     d0
 move.w   dir_stcl(a6),d0
 ror.w    #8,d0
 move.l   d0,xattr_index(a5)
 move.l   dir_time(a6),d0          ; Datum und Uhrzeit

_xa_both:
 moveq    #4,d1                    ; directory file
 btst     #FAB_SUBDIR,d2
 bne.b    _xa_setmode              ; Verzeichnis
 moveq    #8,d1                    ; regular file
_xa_setmode:
 lsl.w    #8,d1
 lsl.w    #4,d1
 ori.w    #%111111111,d1           ; RWXRWXRWX
 andi.w   #FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_VOLUME+FA_SUBDIR+FA_ARCHIVE,d2
 move.w   d2,xattr_attr(a5)        ; xattr_attr
 btst     #FAB_READONLY,d2         ; Schreiben erlaubt ?
 beq.b    _xa_set1
 andi.w   #%1111111101101101,d1    ; RwXRwXRwX
_xa_set1:
 move.w   d1,(a5)                  ; mode
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 swap     d0
 lea      xattr_mtime(a5),a2
 move.l   d0,(a2)+                 ; mtime/date
 move.l   d0,(a2)+                 ; atime/date
 move.l   d0,(a2)                  ; ctime/date

 move.l   fd_dmd(a4),a2
 move.w   d_drive(a2),xattr_dev(a5)
 moveq    #1,d1
 move.l   d1,xattr_res1(a5)   ; xattr_res1  = 0
                              ; xattr_nlink = 1
 clr.l    xattr_uid(a5)       ; xattr.uid
                              ; xattr.gid

 move.l   a5,d1               ; XATTR *
 move.w   d7,d0               ; int mode
 move.l   a6,a1               ; DIR *  oder NULL
 move.l   a4,a0               ; DD *
;move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_fxattr(a2),a2
 jsr      (a2)                ; d0 = errcode / a0 = link
_xa_ende:
 movem.l  (sp)+,a2/a4/a5/a6/d7
 rts
_xa_is_fd:
 move.l   fd_multi1(a4),a0
 move.l   fd_Lstcl(a0),xattr_index(a5)
 move.l   fd_len(a0),xattr_size(a5)
 move.b   fd_attr(a0),d2
 move.l   fd_time(a0),d0
 bra      _xa_both


**********************************************************************
*
* long futime( a0 = DD *dir, a1 = char *name, d0 = long data )
*

futime:
 movem.l  d3/d4/d5/d7/a4/a3,-(sp)
 move.l   d0,-(sp)
 moveq    #FINDALL,d4              ; alle Dateien
 moveq    #dir_time,d5             ; Offset fuer Daten
 moveq    #4,d3                    ; 4 Bytes
 moveq    #1,d7                    ; schreiben
 bra.b    __set_dir_attr


**********************************************************************
*
* long dxfs_attrib( a0 = DD *dir, a1 = char *name, d0 = int mode,
*                   d1 = int attrib )
*
* Rueckgabe:    >= 0      Attribut
*              <  0      Fehler
*              ELINK => a0 ist Zeiger auf Link
*
* mode == 0:   Lies Attribut
*         1:   Schreibe Attribut
*

dxfs_attrib:
 movem.l  d3/d4/d5/d7/a4/a3,-(sp)
 subq.w   #2,sp                    ; (dummy, auf 4 Bytes auffuellen)
 move.b   d1,-(sp)                 ; int attrib
 moveq    #FINDALL,d4
 moveq    #dir_attr,d5             ; Offset fuer Daten
 moveq    #1,d3                    ; 1 Byte
 move.w   d0,d7                    ; d7 = int mode
 beq.b    __set_dir_attr           ; will lesen
* Schreiben gewuenscht
 move.b   (sp),d1
* Nur Bits fuer "ReadOnly", "Hidden", "System" und "Archive" zulassen !!
 and.b    #$d8,d1
 bne      fatt_eaccdn


__set_dir_attr:
 move.l   a1,a3                    ; a3 = Name

* DD oeffnen

 move.w   #OM_RPERM,d0
;move.l   a0,a0
 bsr      reopen_FD
 bmi      fatt_ende
 move.l   d0,a4                    ; a4 = FD

 move.w   d4,d0                    ; zu suchende Attribute
 move.l   a3,a1                    ; Name
 move.l   a4,a0                    ; DD *
 bsr      dir_srch
 bmi      fatt_close               ; Datei existiert nicht
 add.l    d1,d5                    ; d5 = dirpos+dir_attr
* Im Fall FUTIME weiter
 cmpi.w   #4,d3
 beq.b    fatt_futime
* Attribut holen
 move.l   d0,a1
 moveq    #0,d0
 move.b   dir_attr(a1),d0
* Symlink ?
 btst     #FAB_SYMLINK,d0          ; Symlink ?
 bne      fatt_symlink             ; ja, Sonderbehandlung
 tst.w    d7                       ; wollte ich nur lesen ?
 beq      fatt_close               ; ja, Attribut zurueckgeben
 btst     #FAB_SUBDIR,d0           ; Subdir ?
 beq.b    fatt_futime              ; nein, weiter
fatt_unknown:
 moveq    #EACCDN,d0
 bra.b    fatt_close               ; Subdir darf man nicht aendern
* Position des Attributs anfahren
fatt_futime:
 move.l   d5,d0
 move.l   a4,a0
 bsr      __fseek
 bmi      fatt_close
* Attribut schreiben
 lea      (sp),a1                  ; Daten
 move.l   d3,d0                    ; Anzahl Bytes
 move.l   a4,a0                    ; FD
 bsr      _fwrite
 bmi.b    fatt_close
 moveq    #0,d0
* Im Fall FUTIME weiter
 cmpi.w   #4,d3
 beq.b    fatt_close
 move.b   (sp),d0
fatt_close:
* Directory updaten
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    fatt_ende                ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    fatt_ende                ; ja, sofort abbrechen!!
 move.l   d0,d7                    ; Fehlercode merken
 move.l   a0,d5                    ; ggf. Link merken
 move.l   a4,a0
 bsr      close_DD
 tst.l    d0
 bmi.b    fatt_ende
 move.l   d5,a0
 move.l   d7,d0
fatt_ende:
 addq.l   #4,sp
 movem.l  (sp)+,a3/a4/d7/d5/d4/d3
 rts
fatt_eaccdn:
 moveq    #EACCDN,d0
 bra.b    fatt_ende
fatt_symlink:
;move.l   a1,a1                    ; DIR *
 move.l   a4,a0                    ; DD *
 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_readlink(a2),a2
 jsr      (a2)                     ; ELINK oder Lesefehler o.ae.
 bra.b    fatt_close


**********************************************************************
*
* long dxfs_chown( a0 = DD *dir, a1 = char *name, d0 = int uid,
*                  d1 = int gid )
*
* Rueckgabe:    == 0      OK
*              <  0      Fehler
*

dxfs_chown:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long dxfs_chmod( a0 = DD *dir, a1 = char *name, d0 = int mode )
*
* Rueckgabe:    == 0      OK
*              <  0      Fehler
*

dxfs_chmod:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long dxfs_dcreate(a0 = DD *d, a1 = char *name )
*
* 2.12.95:     Aktion wird durch appl_beg/end/critic geschuetzt,
*              damit keine ungueltigen Unterverzeichnisse entstehen.
*

 EVEN
dirproto:
 DC.B     '.          ',$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DC.B     '..         ',$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 EVEN

dxfs_dcreate:
 movem.l  d6/a4/a5,-(sp)
 suba.w   #64,sp
 jsr      appl_begcritic           ; aendert nur d2/a2

* Das Verzeichnis, in dem die neue Datei liegen soll, oeffnen

 move.l   a1,-(sp)
;move.l   a0,a0
 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
 bsr      reopen_FD
 move.l   (sp)+,a1
 bmi      dcre_ende                ; Verzeichnis ist in Benutzung
 move.l   d0,a4

* Das Verzeichnis wird ueber "Fcreate" mit Attribut "Subdir" erzeugt.

 moveq    #0,d2
 subq.w   #1,d2                    ; Hi: kein Dcntl/Lo: DIR ist offen
 moveq    #$10,d1                  ; Attribut "SubDir"
                                   ; erzeuge nicht existierende Datei
 move.w   #O_CREAT+O_EXCL+OM_WPERM+OM_RDENY+OM_WDENY,d0
;move.l   a1,a1                    ; char *name
;move.l   a0,a0                    ; DD *
 bsr      _dxfs_fopen
 tst.l    d0
 bmi      dcre_ok
 move.l   d0,a5                    ; a5 = FD des neuen Verzeichnisses

* Fuer das Verzeichnis wird eine Zuordnungseinheit reserviert und mit
* Nullen initialisiert

 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_ext_fd(a2),a2
 move.l   a5,a0                    ; FD *
 jsr      (a2)
 tst.l    d0
 bmi      dcre_del                 ; Fehler, Datei wieder loeschen

* Die Eintraege "." und ".." werden erzeugt

* Eintrag "." erstellen

 move.l   sp,a1                    ; nach
 lea      dirproto(pc),a0          ; von
 moveq    #16-1,d0                 ; 2*sizeof(DIR)
ncf_loop:
 move.l   (a0)+,(a1)+
 dbra     d0,ncf_loop
* Zeit und Datum: aktuelle nehmen
 move.w   dos_time.l,d0
 ror.w    #8,d0
 move.w   d0,dir_time(sp)
 move.w   dos_date.l,d0
 ror.w    #8,d0
 move.w   d0,dir_date(sp)
* Startcluster aus FD holen (ist normalerweise 0, da Datei leer)
 move.l   fd_Lstcl(a5),d0
 ror.w    #8,d0
 move.w   d0,dir_stcl(sp)               ; stcl.lo
 swap     d0
 ror.w    #8,d0
 move.w   d0,dir_stcl_f32(sp)           ; stcl.hi
* Laenge = 0
;clr.l    dir_flen(sp)

* Eintrag ".." erstellen

* Zeit: aus FD des Parent holen
 movea.l  fd_parent(a5),a0
 move.w   fd_time(a0),dir_time+dir_sizeof(sp)
* Datum: aus FD des Parent holen
 move.w   fd_date(a0),dir_date+dir_sizeof(sp)
* Startcluster: aus FD des Parent holen, 0 bei Root
 move.l   fd_Lstcl(a0),d0
 bge.b    dcre_weiter1
 moveq    #0,d0
dcre_weiter1:
 ror.w    #8,d0
 move.w   d0,dir_stcl+dir_sizeof(sp)         ; stcl.lo
 swap     d0
 ror.w    #8,d0
 move.w   d0,dir_stcl_f32+dir_sizeof(sp)     ; stcl.hi
* Wer weiss, ob ext_fd den FD verschoben hat!
 moveq    #0,d0                    ; An den Dateianfang
 move.l   a5,a0
 bsr      __fseek
 bmi      dcre_del
* wegschreiben
 lea      (sp),a1                  ; Daten
 moveq    #64,d0                   ; Laenge
 move.l   a5,a0                    ; FD
 bsr      _fwrite
 bmi.b    dcre_del

* Es ist alles in Butter, FD schliessen
* vorher muss das OM_WDENY des Parent aufgehoben werden,
* weil dosdev_close den Parent nochmal oeffnet !

 andi.w   #!OM_WDENY,fd_mode(a4)

 move.l   a5,a0
 addq.w   #1,fd_refcnt(a5)         ; FD nicht freigeben, ist neuer DD_FD !
 bsr      dosdev_close
 clr.l    fd_owner(a5)
 subq.w   #1,fd_refcnt(a5)
 bra      dcre_ok

* Es ist irgendein Fehler aufgetreten,
* Datei erst schliessen (FD freigeben) und dann loeschen


dcre_del:
 move.l   d0,d6                    ; Fehlercode merken
 move.l   fd_longname(a5),d0
 beq.b    dcre_nlong
 move.l   d0,a0
 jsr      strlen
dcre_nlong:
 move.l   d0,-(sp)                 ; Laenge des langen Namens

 move.l   fd_dirpos(a5),d5         ; dirpos merken
 move.l   a5,a0
 bsr      free_FD

* Datei wieder loeschen

 move.l   (sp)+,d1                 ; Laenge des langen Namens
 move.l   a4,a0                    ; DD des Pfades
 move.l   d5,d0                    ; dirpos
 bsr      _ddelete
 move.l   d6,d0

dcre_ok:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    dcre_ende                ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    dcre_ende                ; ja, sofort abbrechen!!
 move.l   d0,d6
 move.l   a4,a0
 bsr      close_DD
 move.l   d6,d0
dcre_ende:
 jsr      appl_endcritic           ; aendert nur d2/a2
 adda.w   #64,sp
 movem.l  (sp)+,a4/a5/d6
 rts


**********************************************************************
*
* long dxfs_ddelete( a0 = DD_FD *d )
*
* 2.12.95:
*    Aenderung am XFS-Konzept:
*    Beim Aufruf ist der <refcnt> garantiert 1, das wird vom Kernel
*    getestet. Der DD wird nicht freigegeben.
*

dxfs_ddelete:
 movem.l  d5/a4/a5,-(sp)
 move.l   a0,a4                    ; a4 = DD *
 tst.l    fd_children(a4)          ; geoeffnete Dateien oder Subdirs ?
 bne      ddel_eaccdn
 move.l   fd_parent(a4),d0         ; Parent existiert ?
 beq      ddel_eaccdn              ; nein, bin Root !

*
* unseren DD sperren, indem wir ihn exklusiv oeffnen.
* Damit sollte garantiert sein, dass <fd_multi> == NULL ist und
* auch so bleibt.
*

 moveq    #OM_RPERM+OM_RDENY+OM_WDENY,d0      ; nur lesen, aber exkl. oeffnen
;move.l   a4,a0
 bsr      reopen_FD
 bmi.b    ddel_ende2               ; DD wird benutzt (?!?)
;move.l   d0,a4                    ; ueberfluessig, weil exklusiv geoeffnet

*
* Parent zum Schreiben oeffnen
*

 suba.l   a5,a5                    ; FD ist noch ungueltig
 move.l   fd_parent(a4),a0
 moveq    #OM_RPERM+OM_WPERM+OM_WDENY,d0
 bsr      reopen_FD
 bmi      ddel_ende                ; Zugriff verweigert !
 move.l   d0,a5                    ; a5 = FD des Parent

*
* Verzeichnis testen, ob es leer ist.
*

;move.l   a4,a4
 bsr      dtest
 bmi.b    ddel_ende                ; Verzeichnis nicht leer

*
* Eintrag loeschen, der auf unser Verzeichnis zeigt
* Die Datei bleibt dabei geoeffnet
*

 move.l   fd_longname(a4),d1
 beq.b    ddel_nolong
 move.l   d1,a0
 jsr      strlen
 move.l   d0,d1
ddel_nolong:
 move.l   a5,a0                    ; DD_FD, in dem wir liegen
 move.l   fd_dirpos(a4),d0
 bsr      _ddelete
 tst.l    d0
 bmi.b    ddel_ende                ; Fehler

*
* erst jetzt ist alles gut gegangen.
* Der DD bleibt im Speicher!
*

 moveq    #E_OK,d5
 clr.l    fd_dev(a4)               ; DD als "zombie" markieren.
 bra.b    ddel_ende4

*
* Fehlerbehandlung und Ende
*

ddel_ende:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    ddel_ende2               ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    ddel_ende2               ; ja, sofort abbrechen!!

 move.l   d0,d5                    ; Fehlercode retten
 move.l   a4,a0
 bsr      close_DD                 ; zu loeschenden DD schliessen
 move.l   a5,d1                    ; parent geoeffnet ?
 beq.b    ddel_ende3               ; nein
ddel_ende4:
 move.l   a5,a0
 bsr      close_DD                 ; parent schliessen
ddel_ende3:
 move.l   d5,d0

ddel_ende2:
 movem.l  (sp)+,a5/a4/d5
 rts
ddel_eaccdn:
 moveq    #EACCDN,d0
 bra.b    ddel_ende2


**********************************************************************
*
* FD *dxfs_dopendir( a0 = DD *d, d0 = int tosflag )
*

dxfs_dopendir:
 move.w   d0,-(sp)
 moveq    #OM_RPERM,d0             ; shared mode
;move.l   a0,a0
 bsr      reopen_FD
 bmi.b    dop_ende
 move.l   d0,a0
 bclr     #1,fd_dirch(a0)          ; tosflag merken in Bit #1 von dirch
 tst.w    (sp)
 beq.b    dop_ende
 bset     #1,fd_dirch(a0)          ; tosflag merken in Bit #1 von dirch
dop_ende:
 addq.l   #2,sp
 rts


**********************************************************************
*
* long dxfs_dreaddir( a0 = FD *d, d0 = int len, a1 = char *buf,
*                     d1 = XATTR *xattr, d2 = long *xr )
*
* FUer Dreaddir (xattr = NULL) und Dxreaddir
*

dxfs_dreaddir:
 move.l   fd_dmd(a0),a2
 tst.w    d_flags(a2)
 beq.b    readdir_short
 jmp      vf_readdir
; Funktion fuer kurze Namen
readdir_short:
 movem.l  a3/a4/a5/a6,-(sp)
 move.l   a0,a4
 move.l   a1,a5
 move.l   d2,a3                    ; a3 = long *xr
 move.l   d1,a6                    ; a6 = XATTR *xattr
* Pruefen, ob Puffer lang genug ist
 cmpi.w   #8+3+1+1+4,d0
 bcc.b    drd_ok                   ; genug fuer 8+3 Zeichen +'.'+EOS+index
 btst     #1,fd_dirch(a4)
 beq.b    drd_erange
 sub.w    #8+3+1+1,d0
 bcs.b    drd_erange
* Directoryeintrag lesen
drd_ok:
 suba.l   a1,a1                    ; Pufferadresse zurueckgeben
 moveq    #32,d0                   ; 32 Bytes
 move.l   a4,a0
 bsr      _fread
 bmi      drd_ende                 ; Lesefehler
 beq      drd_enmfil               ; EOF
 move.l   d0,a1
 tst.b    (a1)
 beq      drd_enmfil               ; Ende des Verzeichnisses
 cmpi.b   #$e5,(a1)
 beq.b    drd_ok                   ; geloeschte Datei gilt nicht
 btst     #FAB_VOLUME,dir_attr(a1)
 bne.b    drd_ok                   ; Volume gilt nicht

 move.l   d0,-(sp)
 btst     #1,fd_dirch(a4)
 bne.b    drd_tosmode

;move.l   d0,a1                    ; DIR *
 move.l   a4,a0                    ; FD *
 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_dir2index(a2),a2
 jsr      (a2)                     ; -> index
 move.l   d0,-(sp)
 move.l   sp,a0
 move.b   (a0)+,(a5)+
 move.b   (a0)+,(a5)+
 move.b   (a0)+,(a5)+
 move.b   (a0)+,(a5)+              ; wegen ungerader Adresse (Unsinn!!)
 addq.l   #4,sp
drd_tosmode:
 move.l   a5,a1
 move.l   (sp),a0                  ; DIR *
 bsr      rcnv_8_3
 move.l   (sp)+,a1                 ; DIR *
 move.l   a6,d0                    ; D[x]readdir ??
 beq.b    drd_ende                 ; nein, return(E_OK)

;move.l   a1,a1                    ; DIR *
 move.l   a4,a0                    ; FD *
;move.l   d0,d0                    ; XATTR *
 moveq    #1,d1                    ; folge nicht Symlinks
 bsr      _xattr


 move.l   d0,(a3)                  ; errcode
 moveq    #0,d0                    ; kein Fehler bei readdir
drd_ende:
 movem.l  (sp)+,a3/a4/a5/a6
 rts
drd_erange:
 moveq    #ERANGE,d0
 bra.b    drd_ende
drd_enmfil:
 moveq    #ENMFIL,d0
 bra.b    drd_ende


**********************************************************************
*
* long dxfs_drewinddir( a0 = FD *d )
*

dxfs_drewinddir:
 moveq    #0,d0
;move.l   a0,a0
 bra      __fseek


**********************************************************************
*
* long dxfs_dclosedir( a0 = FD *d )
*

dxfs_dclosedir:
;move.l   a0,a0
 bra      close_DD


**********************************************************************
*
* long dxfs_dpathconf( a0 = DD *d, d0 = int which )
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
*         7:   Information ueber unterstuetzte Attribute und Modi
*         8:   information ueber gueltige Felder in XATTR
*
*      If  any  of these items are unlimited, then 0x7fffffffL is
*      returned.
*

dpp_tab:
 DC.W     8              ;    Parameter 0..8
 DC.W     40             ; 0: (40 offene Dateien                 DFS)
 DC.W     1              ; 1: 1 Hardlink pro Datei
 DC.W     128            ; 2: 128 Bytes maximale Pfadlaenge
 DC.W     12             ; 3: 12 Bytes maximale Dateinamenlaenge
 DC.W     1              ; 4: (interne Blockgroesse                DFS)
 DC.W     DP_DOSTRUNC    ; 5: Dateinamen 8+3
 DC.W     DP_CASECONV    ; 6: immer nach Grossschrift
 DC.W     0              ; 7: (Dateimodi/-typen                  DFS)
 DC.W     DP_INDEX+DP_DEV+DP_NLINK+DP_BLKSIZE+DP_SIZE+DP_NBLOCKS+DP_MTIME


dxfs_dpathconf:
;cmpi.w   #DP_IOPEN,d0
 tst.w    d0
 beq.b    dpp_dfs
 cmpi.w   #DP_ATOMIC,d0
 beq.b    dpp_dfs
 cmpi.w   #DP_MODEATTR,d0
 beq.b    dpp_dfs
 move.l   fd_dmd(a0),a1
 tst.w    d_flags(a1)              ; lange Namen ?
 beq.b    dpp_norm                 ; nein!
 cmpi.w   #DP_NAMEMAX,d0
 beq.b    dpp_3
 cmpi.w   #DP_TRUNC,d0
 beq.b    dpp_5
 cmpi.w   #DP_CASE,d0
 beq.b    dpp_6
dpp_norm:
 move.w   d0,d1
 addq.w   #1,d1
 cmpi.w   #9,d1
 bhi.b    dpp_eaccdn
 add.w    d1,d1
 moveq    #0,d0
 move.w   dpp_tab(pc,d1.w),d0
 rts
dpp_eaccdn:
 moveq    #EACCDN,d0
 rts
dpp_3:
 moveq    #64,d0                   ; Dateinamenlaenge
 rts
dpp_5:
 moveq    #DP_NOTRUNC,d0           ; Dateinamen nicht absaegen
 rts
dpp_6:
 moveq    #DP_CASEINSENS,d0        ; nicht case-sensitiv
 rts

dpp_dfs:
 move.l   fd_dmd(a0),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_pathconf(a2),a2
;move.l   a5,a0                    ; FD *
 jmp      (a2)


**********************************************************************
*
* long dxfs_wlabel( a0 = DD *d, a1 = char *name )
*

all_files:
 DC.B     '*.*',0
 EVEN

dxfs_wlabel:
 move.l   fd_dmd(a0),a0
 move.l   d_root(a0),a0            ; zugehoeriges Wurzelverzeichnis
 movem.l  a0/a1,-(sp)
 moveq    #FINDLABL,d0             ; Nur Dateien mit Attribut 8 loeschen
 lea      all_files(pc),a1         ; Name
;move.l   a0,a0
 bsr      _dxfs_fdelete            ; Vorhandene Volumes loeschen
 movem.l  (sp)+,a0/a1
 tst.l    d0
 beq.b    dwl_ok
 cmpi.l   #EFILNF,d0
 bne.b    dwl_ende
dwl_ok:
 tst.b    (a1)                     ; Name leer ?
 beq.b    dwl_ret0
 cmpi.b   #$e5,(a1)                ; geloeschten Eintrag erzeugen ?
 beq.b    dwl_ret0
 moveq    #FA_VOLUME,d1            ; Volume
 move.w   #O_CREAT+O_EXCL,d0       ; Datei erstellen, nichts loeschen
;move.l   a1,a1                    ; Name
;move.l   a0,a0
 bsr      dxfs_fopen               ; Neues Volume erstellen
 tst.l    d0
 bmi.b    dwl_ende
 move.l   d0,a0
 bra      dosdev_close
dwl_ret0:
 moveq    #0,d0
dwl_ende:
 rts


**********************************************************************
*
* long dxfs_rlabel( a0 = DD *d, a1 = char *name,
*                   d0 = char *buf, d1 = int len )
*
* a1 = NULL, wenn von Dreadlabel() aufgerufen.
* sonst zeigt a1 ueblicherweise auf "*.*"
*

dxfs_rlabel:
 movem.l  a5/a4/d7,-(sp)
 move.l   d0,a5
 move.w   d1,d7
 move.l   fd_dmd(a0),a0
 move.l   d_root(a0),a0            ; zugehoeriges Wurzelverzeichnis
 moveq    #OM_RPERM,d0
 bsr      reopen_FD
 bmi.b    drl_ende
 move.l   d0,a4

 move.l   fd_dmd(a4),a0
 tst.w    d_flags(a0)              ; lange Dateinamen ?
 beq      drl_short                ; nein, alte Funktion

* Fuer lange Namen

 move.w   d7,d0                    ; buflen
 move.l   a5,a1                    ; buf
 move.l   a4,a0                    ; DD
 jsr      vf_rlabel
 bra.b    drl_close

* Fuer kurze Namen

drl_short:
 moveq    #ERANGE,d0
 cmpi.w   #8+3+1+1,d7
 bcs.b    drl_close
 moveq    #FINDLABL,d0             ; nur Labels suchen
 lea      all_files(pc),a1         ; Name
 move.l   a4,a0                    ; DD
 bsr      dir_srch                 ; Datei suchen
 bmi.b    drl_close
 move.l   a5,a1
 move.l   d0,a0
 bsr      rcnv_8_3            ; vom internen Format wandeln
 moveq    #0,d0
drl_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    drl_ende                 ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    drl_ende                 ; ja, sofort abbrechen!!
 move.l   d0,a5
 move.l   a4,a0
 bsr      close_DD
 move.l   a5,d0
drl_ende:
 movem.l  (sp)+,a4/a5/d7
 rts


**********************************************************************
*
* long dxfs_readlink( a0 = DD *d, a1 = char *name, d0 = char *buf,
*                       d1 = int buflen )
*
* Lies symbolischen Link
*

dxfs_readlink:
 movem.l  a3/a4/a5/d7,-(sp)
 move.l   d0,a5                    ; a5 = char *buf
 move.w   d1,d7                    ; d7 = int buflen
 move.l   a1,a3                    ; a3 = char *name

* DD oeffnen

 moveq    #OM_RPERM,d0
;move.l   a0,a0
 bsr      reopen_FD
 bmi.b    rlnk_ende
 move.l   d0,a4                    ; a4 = FD

 moveq    #FINDALL,d0    ; alle ausser Volumes
 move.l   a3,a1                    ; Name
 move.l   a4,a0                    ; DD
 bsr      dir_srch
 bmi      rlnk_close

 move.l   d0,a1                    ; DIR *
 move.l   a4,a0                    ; DD *
 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_readlink(a2),a2
 jsr      (a2)
 cmpi.l   #ELINK,d0
 bne.b    rlnk_close
 cmp.w    (a0)+,d7
 bcs.b    rlnk_erange
rlnk_loop:
 move.b   (a0)+,(a5)+
 bne.b    rlnk_loop
 moveq    #0,d0
 bra.b    rlnk_close
rlnk_erange:
 moveq    #ERANGE,d0
rlnk_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    rlnk_ende                ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    rlnk_ende                ; ja, sofort abbrechen!!
 move.l   d0,d7
 move.l   a4,a0
 bsr      close_DD
 move.l   d7,d0
rlnk_ende:
 movem.l  (sp)+,a3/a4/a5/d7
 rts


**********************************************************************
*
* long dxfs_symlink( a0 = DD *d, a1 = char *name, d0 = char *to )
*
* erstelle symbolischen Link
*

dxfs_symlink:
 move.l   d0,a2
 move.w   #O_CREAT+O_EXCL,d0       ; omode
;move.l   a1,a1                    ; Name
;move.l   a0,a0                    ; DD *
 move.w   #MX_INT_CREATESYMLNK,d2
 swap     d2
 move.w   #OM_RPERM+OM_WPERM+OM_WDENY,d2       ; DD zum Schreiben oeffnen
 bra      _dxfs_fopen


**********************************************************************
*
* long dxfs_dcntl( a0 = DD *d, a1 = char *name, d0 = int cmd,
*                  d1 = long arg )
*
* Fuehrt Spezialfunktionen aus
*

dxfs_dcntl:
 cmpi.w   #VFAT_CNFDFLN,d0
 beq.b    dc_cnfdfln
 cmpi.w   #VFAT_CNFLN,d0
 beq.b    dc_cnfln
 move.l   d1,a2                    ; arg
 move.w   d0,d2                    ; cmd
 cmpi.w   #FUTIME,d2
 beq      dc_futime
 moveq    #0,d1                    ; attrib
 cmpi.w   #MX_DFS_GETINFO,d2       ; MagiC 6
 beq.b    dc_info
 cmpi.w   #DFS_GETINFO,d2
 beq.b    dc_info
 cmpi.w   #MX_DFS_INSTDFS,d2       ; MagiC 6
 beq.b    dc_inst
 cmpi.w   #DFS_INSTDFS,d2
 beq.b    dc_inst
 cmpi.w   #MX_DEV_INSTALL2,d0      ; MagiC 6.20
 beq.b    dc_open
 cmpi.w   #MX_DEV_INSTALL,d0       ; MagiC 6
 beq.b    dc_open
 cmpi.w   #DEV_M_INSTALL,d0
 beq.b    dc_open
 cmpi.w   #MX_INT_CREATEPROC,d0    ; MagiC 6 (intern)
 beq.b    dc_open
 moveq    #EINVFN,d0
 rts
dc_cnfdfln:
 move.l   dfs_longnames.w,d0       ; alter Wert zurueck
 tst.l    d1
 bmi.b    dcntl_ende               ; negativ, nur Wert holen
 move.l   d1,dfs_longnames.w
dcntl_ende:
 rts
dc_cnfln:
 move.l   fd_dmd(a0),a1
 lea      d_flags(a1),a1
 moveq    #0,d0
 move.w   (a1),d0                  ; alten Wert zurueck
 tst.l    d1
 bmi.b    dcntl_ende
 move.w   d1,(a1)                  ; neuen Wert setzen

 move.l   d0,-(sp)
 move.l   fd_dmd(a0),-(sp)
cnfln_garbc_loop:
 move.l   (sp),a0                  ; DMD
 bsr      dxfs_garbcoll
 tst.l    d0                       ; einen freigegeben ?
 bne.b    cnfln_garbc_loop         ; ja, nochmal versuchen
 addq.l   #4,sp
 move.l   (sp)+,d0
 rts

dc_open:
 move.w   #O_CREAT+O_EXCL,d0       ; omode
;move.l   a1,a1                    ; Name
;move.l   a0,a0                    ; DD *
 swap     d2
 move.w   #OM_RPERM+OM_WPERM+OM_WDENY,d2       ; DD zum Schreiben oeffnen
 bra      _dxfs_fopen
dc_inst:
 move.l   (dfs_list).l,dfs_next(a2)    ; DFS einbinden
 move.l   a2,(dfs_list).l
dc_info:
 move.l   #dosxfs_kernel,d0
 rts
dc_futime:
 move.l   timb_modtime(a2),d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 swap     d0                       ; motorola->intel
 bra      futime


dosxfs_kernel:
 DC.W     1                        ; Version
 DC.L     _dir_srch
 DC.L     reopen_FD
 DC.L     close_DD
 DC.L     filename_match
 DC.L     conv_8_3
 DC.L     init_DTA
 DC.L     rcnv_8_3


**********************************************************************
*
* long dtest( a4 = DD_FD *d )
*
* Der DD ist dabei bereits exklusiv (Schreibmodus) geoeffnet.
* Wird nur von xfs_ddelete aufgerufen
*

dtest:
 moveq    #64,d0                   ; Eintraege '.' und '..' ueberspringen
 move.l   a4,a0                    ; FD
 bsr      __fseek
 bmi.b    dtest_ende
dtest_nxtdir:
 suba.l   a1,a1                    ; Pufferadresse zurueckgeben
 moveq    #32,d0                   ; 32 Bytes
 move.l   a4,a0                    ; FD
 bsr      _fread
 bmi      dtest_ende               ; Lesefehler
 beq.b    dtest_enddir             ; Ende der Verzeichnisdatei
 move.l   d0,a0
 tst.b    (a0)
 beq.b    dtest_enddir             ; Ende des Verzeichnisses
 cmpi.b   #$e5,(a0)
 beq.b    dtest_nxtdir             ; geloeschte Datei => weitersuchen
 cmpi.b   #$0f,dir_attr(a0)
 beq.b    dtest_nxtdir             ; langer Name => weitersuchen
* Wir haben einen nicht geloeschte Haupteintrag gefunden => EACCDN
 moveq    #EACCDN,d0               ; EACCDN, Verzeichnis nicht leer
 rts
dtest_enddir:
 moveq    #0,d0
dtest_ende:
 rts


**********************************************************************
*
* long _ddelete( a0 = FD *d, d0 = long dirmainpos,
*                   d1 = long len_of_longname)
*
* a0 ist das Verzeichnis, in dem meine Datei liegt,
* a0 ist bereits exklusiv geoeffnet.
* d1 enthaelt die Laenge des langen Dateinamens oder == 0
*

_ddelete:
 movem.l  a4/d5/d7,-(sp)
 move.l   a0,a4                    ; a4 = FD *
 move.l   d0,d5                    ; d5 = long dirpos
* Die Position des langen Namens ermitteln wir aus der Laenge des
* Namens
 move.l   d5,d7                    ; Default: Wie Kurzname
 tst.l    d1
 beq.b    _ddel_nolong
 addq.l   #8,d1
 addq.l   #4,d1                    ; 12 addieren
 divu     #13,d1                   ; durch 13 teilen, aufrunden
 ext.l    d1
 lsl.l    #5,d1                    ; * sizeof(DIR)
 sub.l    d1,d7                    ; Pos. des langen Namens
_ddel_nolong:
* FUers Loeschen erst unsere Directoryposition anfahren
* und die Daten holen.
;move.l   d5,d0
;move.l   a4,a0
 bsr      __fseek
 bmi      _ddel_ende
 suba.l   a1,a1                    ; Pufferadresse zurueckgeben
 moveq    #32,d0                   ; 32 Bytes
 move.l   a4,a0
 bsr      _fread
 bmi      ddel_ende                ; Lesefehler
 move.l   d0,a1                    ; a1 = DIR *

 move.l   d7,d1                    ; Pos. des langen Namens
 move.l   d5,d0                    ; pos
;move.l   a1,a1                    ; DIR *
 move.l   a4,a0                    ; FD *
 bsr.s    _fdelete
_ddel_ende:
 movem.l  (sp)+,a4/d5/d7
 rts


**********************************************************************
*
* d0/a0 = FD *file_is_open(a0 = DD *dir, d0 = long position )
*
* Testet, ob eine Datei geoeffnet ist, und gibt ggf. einen Zeiger
* auf seinen Prototyp-FD zurueck.
*

file_is_open:
 move.l   fd_multi1(a0),a0
 move.l   fd_children(a0),a0            ; Liste geoeffneter Dateien
                                        ;  desselben DDs
 bra.b    fio_st
fio_loop:
 cmp.l    fd_dirpos(a0),d0
 beq.b    fio_ende
 move.l   fd_next(a0),a0
fio_st:
 move.l   a0,d1
 bne.b    fio_loop
 moveq    #0,d0                         ; nicht gefunden
 rts
fio_ende:
 move.l   a0,d0
 rts


**********************************************************************
*
* long __fdelete(a0 = FD *dir,
*               d0 = long main_position,
*               d1 = long first_position)
*
* loescht die DIR-Eintraege
*

__fdelete:
 movem.l  a4/d7/d5,-(sp)
 move.w   #$e500,-(sp)             ; Daten
 move.l   a0,a4
 move.l   d0,d5
 move.l   d1,d7
__fdel_loop:
 move.l   d7,d0                    ; pos
 move.l   a4,a0                    ; dd_fd
 bsr      __fseek
 bmi      __fdel_ende
 lea      (sp),a1                  ; Daten
 moveq    #1,d0                    ; 1 Byte

 move.l   a4,a0                    ; FD
 bsr      _fwrite
 bmi.b    __fdel_ende
 moveq    #32,d0
 add.l    d0,d7
 cmp.l    d5,d7                    ; Haupt-DIR-Eintrag erreicht ?
 bls.b    __fdel_loop
 moveq    #0,d0
__fdel_ende:
 addq.l   #2,sp
 movem.l  (sp)+,d7/d5/a4
 rts


**********************************************************************
*
* long _fdelete(a0 = FD *dir, a1 = char *dir_entry,
*               d0 = long main_position,
*               d1 = long first_position)
*
* a0 ist bereits zum Schreiben geoeffnet.
* Der erste DIR-Eintrag liegt bei <first_position>,
* der Haupteintrag bei <main_position>.
*
* Diese Funktion wird von xfs_fdelete() und xfs_ddelete()
* verwendet.
* Bei xfs_ddelete() brauchen wir keinen Test, ob die Datei
* geoeffnet ist, da dieser Test schon durchgefuehrt wurde und die
* Datei als "Lock" geoeffnet bleiben muss.
*

_fdelete:
 movem.l  d5/d7/a4/a6,-(sp)

 move.l   a0,a4                    ; a4 = DD *
 move.l   a1,a6                    ; a6 = DIR *
 move.l   d0,d5                    ; d5 = dirpos
 move.l   d1,d7                    ; d7 = first_pos

* Falls Attribut ReadOnly : return(EACCDN)

 btst     #FAB_READONLY,dir_attr(a6)    ; ReadOnly ?
 bne      _fdel_eaccdn             ; ja, Fehler
 btst     #FAB_SUBDIR,dir_attr(a6) ; Subdir ?
 bne.b    _fdel_del                ; ja, kein Test!

* Teste, ob unsere zu loeschende Datei womoeglich geoeffnet ist.

_fdel_again:
 move.l   a4,a0
 move.l   d5,d0
 bsr.s    file_is_open
 beq.b    _fdel_del                ; Datei ist nicht geoeffnet, OK
 btst     #5,(config_status+3).w
 beq.b    _fdel_eaccdn             ; Datei geoeffnet => return(EACCDN)

* Im Kompatibilitaetsmodus werden die Dateien geschlossen
* GEFAHR !!

 move.l   d0,a0
 tst.w    fd_refcnt(a0)
 bmi.b    _fdel_eaccdn             ; Diese kann man nicht schliessen
 bsr      dosdev_close             ; Kompatib.: Dateien werden "geschlossen"
 tst.l    d0
 bmi      _fdel_ende
 bra.b    _fdel_again

*
* DFS- Aufruf
*

_fdel_del:
 move.l   d5,d0                    ; d0 = long dirpos
 move.l   a6,a1                    ; DIR *
 move.l   a4,a0                    ; DD *
 move.l   fd_dmd(a4),a2
 move.l   d_dfs(a2),a2
 move.l   dfs_fdelete(a2),a2
 jsr      (a2)                     ; => a0 = MDEV *
 tst.l    d0
 bmi.b    _fdel_ende               ; ggf. auch ELINK (a0 = char *name)
 subq.l   #1,d0                    ; ignorieren ?
 beq.b    _fdel_ende               ; ja, nichts loeschen

* Verzeichniseintraege loeschen

 move.l   d5,d0

 move.l   d7,d1
 move.l   a4,a0
 bsr      __fdelete
_fdel_ende:
 movem.l  (sp)+,a6/a4/d5/d7
 rts
_fdel_eaccdn:
 moveq    #EACCDN,d0
 bra.b    _fdel_ende


**********************************************************************
*
* void free_FD(a0 = FD *file)
*
* gibt einen FD frei. Es wird die Liste der Kinder seines Parent
* durchsucht (d.h. die Geschwister).
*

free_FD:
 cmpa.l   fd_multi1(a0),a0              ; bin ich ein Prototyp ?
 beq.b    dfcl_amproto                  ; ja !
 move.l   fd_multi1(a0),a1
 moveq    #fd_multi,d0
 add.w    d0,a1
 bsr      unlist
 move.l   0(a0,d0.w),(a1)               ; mich ausklinken
 move.l   fd_multi1(a0),a1              ; Prototyp
 btst     #FAB_SUBDIR,fd_attr(a1)       ; Verzeichnis ?
 bne      dfcl_ende                     ; ja, nicht freigeben
 tst.l    fd_owner(a1)                  ; Prototyp belegt ?
 bne      dfcl_ende                     ; ja, nur mich freigeben
 tst.w    fd_refcnt(a1)                 ; kann eigentlich nicht sein!
 bne      dfcl_ende                     ; nicht freigeben

 move.l   a1,-(sp)
;move.l   a0,a0
 jsr      int_mfree                     ; erst mich freigeben
 move.l   (sp)+,a0
;bra      dfcl_amproto                  ; dann den Prototyp freigeben

* aus der Liste der Geschwister ausklinken, wenn keine Clones
* da sind

dfcl_amproto:
 tst.l    fd_multi(a0)                  ; noch andere Clones da ?
 bne      dfcl_nix                      ; ja, nichts freigeben
 movea.l  fd_parent(a0),a1
 lea      fd_children(a1),a1
 moveq    #fd_next,d0
 bsr.s    unlist                        ; in der Liste der Geschwister
 move.l   fd_next(a0),(a1)              ;  aus Liste ausklinken
 move.l   fd_longname(a0),d0
 beq.b    dfcl_ende
 move.l   a0,-(sp)
 move.l   d0,a0
 jsr      int_mfree                     ; langen Ordnernamen freigeben
 move.l   (sp)+,a0
dfcl_ende:
 jmp      int_mfree
dfcl_nix:
 clr.l    fd_owner(a0)
 rts


**********************************************************************
*
* void free_clone_FD(a0 = FD *file)
*
* gibt einen Clone-FD frei. Der Prototyp wird nicht angetastet, weil
* er ein Verzeichnis ist.
*

free_clone_FD:
 move.l   fd_multi1(a0),a1
 moveq    #fd_multi,d0

 add.w    d0,a1

 bsr.b    unlist
 move.l   0(a0,d0.w),(a1)               ; mich ausklinken
 jmp      int_mfree


**********************************************************************
*
* void unlist(a0 = void *obj, a1 = void *liste, d0 = int offs)
*
* Entfernt das Element <a0> aus der Liste <a1>.
* a1 zeigt auf den Vorgaenger + d0, a0 ist unveraendert
*

fatal_errs:
 DC.B     '*** FATALER FEHLER IM DOS-XFS:',0
 EVEN

unlist_loop:
 cmpa.l   d1,a0
 beq.b    unlist_found
 move.l   d1,a2
 lea      0(a2,d0.w),a1
unlist:
 move.l   (a1),d1
 bne.b    unlist_loop
; nicht gefunden
 lea      fatal_errs(pc),a0
 jmp      halt_system
unlist_found:
 rts


**********************************************************************
*
* long fflush(a0 = FD *file)
*
* Aktualisierung des zur Datei <file> gehoerigen Directory- Eintrags.
* Wird nur fuer Datendateien verwendet, da bei der Modifikation eines
* Verzeichnisses keine Angaben im parent modifiziert werden.
*

fflush:
 moveq    #0,d0
 move.l   fd_multi1(a0),a0         ; Prototyp- FD verwenden
 btst     #0,fd_dirch(a0)          ; FD.dirty ?
 beq      ffl_rts                  ; nein, nichts veraendert, alles OK
 move.l   fd_parent(a0),d0         ; hiermit schreiben wir rum
 beq      ffl_rts                  ; wir sind selbst die Root ?!?
 movem.l  d7/a4/a5,-(sp)
 movea.l  a0,a5                    ; a5 = FD *
 move.l   d0,a4                    ; a4 = DD_FD *
 move.l   _hz_200,d7
 add.l    #1000,d7                 ; 5s Timeout
ffl_loop:
 move.l   a4,a0
;moveq    #OM_WPERM,d0             ; schreiben, shared mode
 moveq    #OM_RPERM,d0             ; lesen (trotz schreiben!), shared mode
 bsr      reopen_FD
 bge.b    ffl_opened               ; Zugriff erlaubt
 cmpi.l   #EACCDN,d0
 bne      ffl_ende                 ; schwerer Fehler
* Der Zugriff ist momentan blockiert
 tst.l    act_appl.l               ; AES aktiv ?
 ble      ffl_ende                 ; nein, Fehler
 cmp.l    _hz_200,d7               ; Timeout ?
 bcs      ffl_ende
 jsr      appl_yield
 bra      ffl_loop
ffl_opened:
 move.l   d0,a4

* Wenn fd_dirch.Bit_0 gesetzt ist, werden die Daten
* filt.stcl_f32 file.time, file.date, file.clust, file.len
* fuer das Zurueckschreiben
* erst ins INTEL- Format gebracht und dazu erst einmal kopiert

* Directoryposition anfahren
 moveq    #dir_stcl_f32,d0
 add.l    fd_dirpos(a5),d0
 move.l   a4,a0
 bsr      __fseek
 bmi      ffl_close                ; Fehler
* zurueckzuschreibende Daten auf Stack
 clr.l    -(sp)                    ; flen
 move.l   fd_len(a5),d0
 cmpi.l   #$7fffffff,d0            ; Laenge ungueltig (dir) ?
 beq.b    ffl_0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 move.l   d0,(sp)                  ; Laenge als intel speichern
ffl_0:
 move.l   fd_Lstcl(a5),d0
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; stcl.lo als intel
;move.w   fd_date(a5),-(sp
 move.l   fd_time(a5),-(sp)        ; Zeit UND Datum
 swap     d0
 ror.w    #8,d0
 move.w   d0,-(sp)                 ; stcl.hi als intel
* Daten sichern
 lea      (sp),a1                  ; Daten
 moveq    #12,d0                   ; 12 Bytes
 move.l   a4,a0                    ; FD
 bsr      _fwrite
 adda.w   #12,sp
 bmi.b    ffl_close                ; Schreibfehler
* ggf. Attributbyte anpassen
 btst     #FAB_SUBDIR,fd_attr(a5)  ; Verzeichnis ?
 bne.b    ffl_ok                   ; ja, OK
 btst     #FAB_VOLUME,fd_attr(a5)  ; Volume ?
 bne.b    ffl_ok                   ; ja, OK
 bset     #FAB_ARCHIVE,fd_attr(a5) ; Archivbit schon gesetzt ?
 bne.b    ffl_ok                   ; ja, OK
* Normale Datei, Archivbit muss gesetzt werden
 moveq    #dir_attr,d0
 add.l    fd_dirpos(a5),d0
 move.l   a4,a0
 bsr      __fseek
 bmi      ffl_close
 lea      fd_attr(a5),a1           ; Daten
 moveq    #1,d0                    ; 1 Bytes
 move.l   a4,a0                    ; FD
 bsr      _fwrite
 bmi.b    ffl_close                ; Schreibfehler
* dirty- Flag des FD loeschen
ffl_ok:
 bclr     #0,fd_dirch(a5)
 moveq    #0,d0                    ; kein Fehler
ffl_close:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    ffl_ende                 ; ja, sofort abbrechen!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    ffl_ende                 ; ja, sofort abbrechen!!
 move.l   d0,a5
 move.l   a4,a0
 bsr      close_DD
 move.l   a5,d0
ffl_ende:
 movem.l  (sp)+,a5/a4/d7
ffl_rts:
 rts


**********************************************************************
*
* int chk_specdir(a0 = char *dateiname, d0 = char c)
*
* Durchsuche <dateiname> bis zum ersten Zeichen, das == c ist
* Rueckgabe: ""       =>   1
*           ".c"     =>   -1
*           "..c"    =>   -2
*           "...c"   =>   -3
*            usw.
*           sonst    =>   0
*

chk_specdir:
 move.b   d0,d1
 moveq    #1,d0
 tst.b    (a0)                     ; Nullstring => return(1)
 beq.b    chks_ende
 moveq    #0,d0
chks_loop:
 cmpi.b   #'.',(a0)+               ; erstes Zeichen != '.' => return(0)
 bne.b    chks_0
* erstes Zeichen ist '.'
 subq.l   #1,d0
 cmp.b    (a0),d1
 bne.b    chks_loop
chks_ende:
 rts
chks_0:
 moveq    #0,d0
 rts


**********************************************************************
*
* EQ/MI long tst_name(a0 = char *name)
*
* Testet den Dateinamen <name> , ob er fuer
* Fcreate() oder Frename() zulaessig ist, also kein Nullname ist, kein
* spezielles Verzeichnis (. oder ..) ist und
* die Zeichen '*','?' und ':' nicht enthaelt.
* Ausserdem darf der Name nicht mit ' ' beginnen.
*
* Achtung: Wegen der langen Namen wird hier auf eine maximale
* Laenge von 64 Zeichen getestet
*

tst_name:
 tst.b    (a0)
 beq.b    tstn_ende                ; Nullname
 cmpi.b   #' ',(a0)
 beq.b    tstn_ende                ; beginnt mit Leerstelle
 cmpi.b   #'.',(a0)
 bne.b    tstn_begloop
 tst.b    1(a0)
 beq.b    tstn_ende                ; Eintrag "."
 cmpi.b   #'.',1(a0)
 beq.b    tstn_ende                ; Eintrag beginnt mit ".."
tstn_begloop:
 moveq    #64,d1                   ; dbra- Zaehler
tstn_loop:
 cmpi.b   #'?',(a0)
 beq.b    tstn_ende                ; Fehler
 cmpi.b   #'*',(a0)
 beq.b    tstn_ende                ; Fehler
 cmpi.b   #':',(a0)
 beq.b    tstn_ende                ; Fehler
 tst.b    (a0)+
 beq.b    tstn_ok
 dbra     d1,tstn_loop
tstn_ende:
 moveq    #EBADRQ,d0               ; zu lang oder ungueltige Zeichen
 rts
tstn_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* void dxfs_freeDD( a0 = DD *d )
*
* Der Referenzzaehler eines DD ist vom Kernel auf 0 dekrementiert
* worden. Ein XFS, das keine garbage collection macht, kann hier
* Strukturen freigeben.
*

dxfs_freeDD:
 tst.l    fd_dev(a0)               ; ungueltig ? (von geloeschtem DIR)
 beq      free_FD                  ; ja, freigeben
 rts


**********************************************************************
*
* long dxfs_garbcoll( a0 = DMD *dir )
*
* Sucht nach einem unbenutzten FD
* Rueckgabe TRUE, wenn mindestens einer gefunden wurde.
*

dxfs_garbcoll:
 move.l   d_root(a0),d0
 move.l   d0,a0
 bne.b    _collect_DD
 rts


**********************************************************************
*
* DD *_collect_DD(a0 = DD *root)
*  (wird nur von dfs_garbcoll aufgerufen)
*
* Gibt einen nicht benoetigten DD zurueck. Es wird erst das Verzeichnis
* selbst, dann alle Unterverzeichnisse durchsucht. Die Root wird nie
* freigegeben.
*

_collect_DD:
 move.l   a5,-(sp)
 movea.l  a0,a5                    ; a5 ist der DD

* pruefen, ob der DD selbst freigegeben werden kann

_cdd_loop:
 tst.l    fd_children(a5)          ; hat Unterverzeichnisse ?
 bne.b    _cdd_children            ; ja, nicht freigeben
 btst     #FAB_SUBDIR,fd_attr(a5)
 beq      _cdd_sisters             ; ist kein DD_FD
 tst.l    fd_parent(a5)            ; Ist Root (kein Parent) ?
 beq.b    _cdd_sisters             ; nicht freigeben
 tst.w    fd_refcnt(a5)            ; ist geschuetzter Standardpfad ?
 bne      _cdd_sisters             ; ja, nicht freigeben
 tst.l    fd_owner(a5)             ; DD_FD belegt ?
 bne      _cdd_sisters
 tst.l    fd_multi(a5)
 bne      _cdd_sisters             ; Prototyp- DD_FD nicht freigeben
 move.l   a5,a0
 bsr      free_FD                  ; ausklinken
 bra      _cdd_a5                  ; und zurueckgeben

* Alle Unterverzeichnisse durchsuchen

_cdd_children:
 move.l   fd_children(a5),d0
 beq.b    _cdd_sisters
 move.l   d0,a0
 bsr.b    _collect_DD
 tst.l    d0
 bne.b    _cdd_ende                ; DD gefunden

* Naechstes Verzeichnis auf gleicher Ebene durchsuchen

_cdd_sisters:
 movea.l  fd_next(a5),a5
 move.l   a5,d0
 bne.b    _cdd_loop

* Nichts gefunden, NULL zurueckgeben

 moveq    #0,d0
_cdd_ende:
 move.l   (sp)+,a5
 rts
_cdd_a5:
 move.l   a5,d0
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* DD *get_DD(a0 = DD *dir, a1 = DIR *subdir, d0 = long dirpos,
*              char *longname, void **link)
*
* Sucht das Verzeichnis mit dem Eintrag <subdir> im Ordner <dir>.
* Gibt einen Zeiger auf den DD des <subdir> zurueck. Notfalls muss
* dieser DD eben erzeugt werden.
* Wegen der Plattenzugriffe in dirDD_srch kann es sein, dass ein
* anderer Prozess unseren DD gleichzeitig schon erzeugt hat.
* Deshalb prueft get_DD noch einmal die Liste der Unterverzeichnisse,
* ob unser jetzt gefundener Eintrag schon enthalten ist.
*
* Der DD <dir> ist zu diesem Zeitpunkt geschuetzt, weil von
* dirDD_srch aufgerufen und hier geoeffnet.
*
* Rueckgabe:
*    d0 = DD *dd    Der gesuchte DD
*    d0 = ELINK
*     (*link) = int len, char *p  Datei ist symbolischer Link
*

get_DD:
     DEBT  a1,'get_DD '
 movem.l  d5/a2/a4/a6,-(sp)
 movea.l  fd_multi1(a0),a4         ; a4 := DD_FD  (Prototyp)
 movea.l  a1,a6                    ; a6 := DIR
 move.l   d0,d5                    ; d5 = dirpos
 movea.l  fd_children(a4),a0
 bra.b    gDD_nxtchild             ; Durchlaufe alle Kinder des DD
gDD_childloop:
 cmp.l    fd_dirpos(a0),d5         ; sind wir es ?
 beq.b    gDD_ende                 ; DD gefunden => gib a3 zurueck
 movea.l  fd_next(a0),a0           ; naechstes Geschwist
gDD_nxtchild:
 move.l   a0,d0
 bne.b    gDD_childloop

* Wir haben unser Verzeichnis nicht unter den Kindern von <dir> gefunden
* erstelle einen Prototyp-FD, oeffne aber nicht den Dateitreiber

 move.l   20(sp),d0                ; langer Name
;move.l   a6,a6                    ; DIR *
;move.l   d5,d5                    ; dirpos
;move.l   a4,a4                    ; DD *
 bsr.s    DIR2protoFD

 move.l   24(sp),a1                ; void **link
 move.l   a0,(a1)                  ; ggf. Link eintragen
gDD_ende:
 movem.l  (sp)+,a6/a4/a2/d5
     DEBL  d0,'get_DD => '
 rts


**********************************************************************
*
* EQ/MI d0 = FD * DIR2protoFD(a4 = DD_FD *d, a6 = DIR *dir,
*                             d5 = long dirpos,
*                             d0 = char *longname )
*
* erstellt einen Prototyp-FD aus den Verzeichnisdaten und oeffnet den
* Dateitreiber.
* Bei einem Unterverzeichnis und langem Dateinamen wird dieser
* ebenfalls angelegt.
*
* a4/a5/a6/d5/d7 sind global und duerfen nicht veraendert werden.
*
* Wird verwendet von fopen und get_DD
*

DIR2protoFD:
 move.l   a3,-(sp)
 move.l   d0,-(sp)            ; langer Name
 bsr      int_malloc
 movea.l  d0,a3

* Ein Teil des FD wird schon jetzt angelegt und kann vom DFS manipuliert
* werden.
* Achtung: fd_len und fd_Lstcl muessen vom DFS initialisiert werden

;move.w   dir_stcl(a6),d0          ; -> DFS
;ror.w    #8,d0
;move.w   d0,fd_stcl(a3)
 move.l   dir_time(a6),fd_time(a3)
;move.w   dir_date(a6),fd_date(a3)
 move.l   d5,fd_dirpos(a3)              ; dirpos
;clr.l    fd_fpos(a3)
 move.l   fd_multi1(a4),a0              ; a0 = DD_FD
 move.l   a0,fd_parent(a3)
 move.l   fd_dmd(a0),a2                 ; a2 = DMD
 move.l   a2,fd_dmd(a3)
;clr.l    fd_owner(a3)
;clr.l    fd_refcnt(a3)

*
* Hier kann das DFS noch einmal einschreiten.
* Das DFS initialisiert:
*
*  fd_len
*  fd_stcl
*  fd_attr
*  fd_ddev
*
* und ggf.
*  fd_name, fd_xftype, fd_xdata usw.
*
* und aendert ggf. Daten
*

 move.l   d_dfs(a2),a2
 move.l   dfs_dir2FD(a2),a2
 move.l   a6,a1                    ; DIR *
 move.l   a3,a0                    ; Prototyp- FD *
 jsr      (a2)                     ; -> (E_OK) oder (d0=ELINK/a0=char *link)
 tst.l    d0
 bmi.b    D2F_err

* Den neuen FD vorne in die Liste der Kinder von <dir> einhaengen

 move.l   #dosdev_drv,fd_dev(a3)
 move.l   fd_multi1(a4),a0
 move.l   fd_children(a0),fd_next(a3)
 move.l   a3,fd_children(a0)
 move.l   a3,fd_multi1(a3)              ; neuer FD ist ein Prototyp

;lea      fd_name(a3),a1                ; -> DFS
;move.l   (a6)+,(a1)+
;move.l   (a6)+,(a1)+
;move.l   (a6),(a1)                     ; Name (11 Zeichen) und Attribut

* jetzt den langen Ordnernamen einfuegen, wenn noetig

 btst.b   #FAB_SUBDIR,fd_attr(a3)       ; Subdir ?
 beq.b    D2F_nosub                     ; nein!

 move.l   (sp),d0                       ; langer Name ?
 beq.b    D2F_nosub                     ; kein langer Name
 addq.w   #1,fd_refcnt(a3)              ; Block schuetzen
 jsr      int_malloc
 subq.w   #1,fd_refcnt(a3)
 move.l   d0,fd_longname(a3)
 move.l   (sp),a1
 move.l   d0,a0
gDD_cpy:
 move.b   (a1)+,(a0)+              ; langen Namen kopieren
 bne.b    gDD_cpy

D2F_nosub:
 move.l   a3,d0

D2F_ende:
 addq.l   #4,sp
 move.l   (sp)+,a3
 rts

* Fehler oder Link, FD wieder freigeben
D2F_err:
 move.l   a0,-(sp)                 ; ggf. Link merken
 move.l   a3,a0                    ; neuen DD freigeben
 move.l   d0,a3                    ; Fehlercode merken
 bsr      int_mfree
 move.l   (sp)+,a0                 ; ggf. Link
 move.l   a3,d0
 bra.b    D2F_ende


**********************************************************************
*
* MI/GT DIR *long dir_srch(a0 = DD_FD *dir, a1 = char *restpath,
*                          d0 = char attrib)
* -> d0 = DIR *
* -> d1 = long pos1           zeigt auf Haupt-DIR-Eintrag
*    d2 = long pos2           Anfang des langen Namens, ggf. -1
*
*  Sucht im Directory <dir> von vorn nach der naechsten in <restpath>
*   spezifizierten Datei (auch Muster) mit dem Attributsmuster
*   <attrib>.
*  Wird verwendet fuer
*
*    Fopen
*    Fdelete
*    Fxattr
*    Fattrib
*

dir_srch:

     DEBL  a0,'dir_srch PATH = '
     DEBT  a1,'         Name = '
     DEBL  d0,'         Attr = '

 move.l   fd_dmd(a0),a2
 tst.w    d_flags(a2)              ; lange Dateinamen ?
 beq      dirs_short               ; nein, alte Funktion
 suba.w   #8,sp                    ; Platz fuer spos/lpos
 pea      4(sp)                    ; &lpos
 pea      4(sp)                    ; &apos
;move.w   d0,d0                    ; attrib
;move.l   a1,a1                    ; Dateiname
;move.l   a0,a0                    ; DD_FD
 jsr      vf_dirsrch
 addq.l   #8,sp
 move.l   (sp)+,d1                 ; pos1
 move.l   (sp)+,d2                 ; pos2

     DEBL  d0,'dir_srch => '
     DEBL  d1,'      d1 => '
     DEBL  d2,'      d2 => '

 tst.l    d0
 rts
dirs_short:
 cmpi.b   #FINDALL,d0
 beq.b    drss_4
 cmpi.b   #FINDNDIR,d0
 beq.b    drss_2
 moveq    #FA_VOLUME,d0            ; nur Labels suchen
 bra.b    drss_all
drss_2:

 moveq    #FA_HIDDEN+FA_SYSTEM,d0       ; keine SubDirs oder Labels !!
 bra.b    drss_all
drss_4:
 moveq    #FA_HIDDEN+FA_SYSTEM+FA_SUBDIR,d0
drss_all:
 suba.w   #12,sp
 move.l   a0,-(sp)
* nach (sp) kommt der zu suchende Dateiname im internen Format,
* dahinter das Attributsmuster
 move.b   d0,11+4(sp)
 move.l   a1,a0                    ; Suchmuster
 lea      4(sp),a1
 bsr      conv_8_3
 move.l   (sp)+,a0
 lea      (sp),a1
 moveq    #0,d1                    ; ab Anfang
 bsr.s    _dir_srch
 adda.w   #12,sp
 subi.l   #32,d1                   ; dirpos korrigieren
 moveq    #-1,d2                   ; kein langer Name
 tst.l    d0

     DEBL  d0,'dir_srch => '
     DEBL  d1,'      d1 => '
     DEBL  d2,'      d2 => '

 rts


**********************************************************************
*
* MI/GT long _dir_srch(a0 = DD *dir, a1 = char int_fname[12],
*                      d1 = long pos)
*
* Wie dir_srch, aber verlangt in a1 einen Zeiger auf den Dateinamen
* samt Suchmuster im internen Format (12 Bytes), und zwar auf gerader
* Adresse. Ausserdem wird ab <pos> gesucht.
* Verwendet fuer Fsfirst und Fsnext, sucht nur 8+3.
*

_dir_srch:

     DEBT  a1,'_dir_srch '

 movem.l  a3/a4,-(sp)
 suba.w   #12,sp
 movea.l  a0,a4                    ; a4 = FD

* nach (sp) kommt der zu suchende Dateiname im internen Format,
* dahinter das Attributmuster

 move.l   sp,a0

 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)

* Dateizeiger des Verzeichnisses auf den Anfang der Suche
* also auf <pos> oder 0L, wenn <pos> == -1L

 move.l   d1,d0
 move.l   a4,a0                    ; FD
 bsr      __fseek
 bmi      dsrch_ende

* Das gesamte Verzeichnis wird durchsucht

 bra.b    dsrch_nxt
dsrch_loop:
 move.l   a3,a1
 lea      (sp),a0
 bsr      filename_match           ; Ist es der gesuchte Eintrag ?
 beq.b    dsrch_nxt                ; nein
dsrch_found:
 move.l   fd_fpos(a4),d1
 move.l   a3,d0
 bra.b    dsrch_ende               ; gefunden!
* naechsten Verzeichniseintrag (struct DIR) lesen
dsrch_nxt:
 suba.l   a1,a1                    ; Pufferadresse zurueckgeben
 moveq    #32,d0                   ; 32 Bytes
 move.l   a4,a0                    ; FD
 bsr      _fread
 bmi      dsrch_ende               ; Lesefehler
 beq.b    dsrch_efilnf
 movea.l  d0,a3                    ; Zeiger auf DIR
 tst.b    (a3)                     ; Ende des Verzeichnisses ?
 bne.b    dsrch_loop               ; nein, weiter
* Dateiende (oder nie benutzter Eintrag gefunden)
 cmpi.b   #$e5,(sp)                ; suche nach geloeschter Datei ?
 beq.b    dsrch_found              ; ja, geloeschte Datei gefunden
dsrch_efilnf:
 moveq    #EFILNF,d0
dsrch_ende:
     DEBL  d0,'_dir_srch => '
 adda.w   #12,sp
 movem.l  (sp)+,a4/a3
 rts


**********************************************************************
*
* char *rcnv_8_3(a0 = char *intname, a1 = char *name)
*
* Wandelt einen internen Dateinamen (8+3-Format) in eine Zeichenkette
* um und gibt in d0 einen Zeiger hinter den String zurueck
*

rcnv_8_3:
 tst.b    (a0)                     ; Name ist 0 ?
 beq      ddtos_ende               ; DD ist Root, schreibe Nullstring

* kopiere den Ordnernamen (max. 8 Zeichen)

 move.l   a0,a2                    ; a2 = Quellstring
 moveq    #0,d1
 bra.b    i2n_n1
i2n_loop1:
 move.b   (a2)+,(a1)+
 addq.w   #1,d1
i2n_n1:
 cmp.w    #8,d1
 bge.b    i2n_spec
 tst.b    (a2)
 beq.b    i2n_spec
 cmpi.b   #' ',(a2)
 bne.b    i2n_loop1
i2n_spec:
 cmpi.b   #'.',(a0)                ; beginnt Ordnername mit '.' ?
 beq.b    ddtos_ende               ;  ja, fertig
 lea      8(a0),a2
 cmpi.b   #' ',(a2)                ; hat der Ordner keine Extension
 beq.b    ddtos_ende               ;  nein, fertig
 move.b   #'.',(a1)+               ; sonst schreibe '.'

* kopiere die Extension (max. 3 Bytes)

 clr.w    d1
 bra.b    i2n_n2
i2n_loop2:
 move.b   (a2)+,(a1)+
 addq.w   #1,d1
i2n_n2:
 cmp.w    #3,d1
 bge.b    ddtos_ende
 tst.b    (a2)
 beq.b    ddtos_ende
 cmpi.b   #' ',(a2)
 bne.b    i2n_loop2

* Schliesse String mit EOS ab und gib Zeiger auf dieses EOS zurueck

ddtos_ende:
 clr.b    (a1)
 move.l   a1,d0
 rts


**********************************************************************
*
* void init_DTA(a0 = DIR *file, a1 = DTA *buf)
*
* Fuellt den User- Bereich der DTA
*
* nichts korrigiert, nur optimiert
*

init_DTA:
 move.b   dir_attr(a0),dta_attr(a1)
 move.l   dir_time(a0),d0          ; Datum und Uhrzeit
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 swap     d0
 move.l   d0,dta_time(a1)

 moveq    #0,d0                         ; dir: Laenge 0
 btst     #FAB_SUBDIR,dir_attr(a0)
 bne.b    indt_isdir
 move.l   dir_flen(a0),d0
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0

indt_isdir:
 move.l   d0,dta_len(a1)

 lea      dta_name(a1),a1
;move.l   a0,a0
 bra      rcnv_8_3


**********************************************************************
*
* PL/MI d0 = FD *reopen_FD(a0 = DD_FD *verz, d0 = int omode)
*
*  Beschafft einen (Clone-)FD fuer eine Datei, die bereits ueber den
*  Prototyp-FD <a0> geoeffnet ist.
*  Dies kommt vor, wenn eine Datei mehrmals geoeffnet wird und wenn
*  ein Verzeichnis geoeffnet wird, da Verzeichnis- Prototyp- FDs nicht
*  freigegeben werden.
*  Die Kompatibilitaet des <omode> zu der bereits geoeffneten Datei
*  wird ueberprueft.
*

reopen_FD:
 move.l   a2,-(sp)                      ; PUREC
; Vertraeglichkeit der Open- Modi testen
 tst.l    fd_owner(a0)                  ; Prototyp belegt ?
 bne.b    _opf_tst                      ; ja, teste ihn
 move.l   fd_multi(a0),d1               ; Prototyp frei, andere belegt ?
 beq      opd_a0                        ; nein, einfach verwenden
_opf_loop:
 move.l   d1,a0
_opf_tst:
 move.w   fd_mode(a0),d1
 btst     #BOM_NOCHECK,d1               ; kein Check durch den Kernel ?
 bne.b    _opf_nxt                      ; ja, ddev_open prueft
 ror.b    #4,d1
 and.b    d0,d1
 andi.b   #OM_RPERM+OM_WPERM,d1         ; Lese-/Schreibberechtigung
 bne      opd_eaccdn                    ; Konflikt: return(EACCDN)
_opf_nxt:
 move.l   fd_multi(a0),d1
 bne.b    _opf_loop

 move.l   fd_multi1(a0),a0              ; zurueck zum Prototyp
 tst.l    fd_owner(a0)                  ; Prototyp benutzt ?
 beq.b    opd_a0                        ; nein, einfach nehmen
* Es gibt keinen Konflikt zu bereits geoeffneten Deskriptoren
* Protoyp belegt, neuen FD anlegen
 move.w   d0,-(sp)
 move.l   a0,-(sp)
 bsr      int_malloc                    ; FD allozieren (setzt alles auf 0)
 move.l   d0,a0
 move.l   (sp)+,a1
 move.w   (sp)+,d0
* fd_name/fd_parent/fd_children/fd_next ist ungueltig bei einem Clone
 move.l   a1,fd_multi1(a0)              ; Prototyp-FD einsetzen
 move.l   fd_multi(a1),fd_multi(a0)
 move.l   a0,fd_multi(a1)               ; rein in die multi- Verkettung
 move.l   fd_dev(a1),fd_dev(a0)
 move.l   fd_ddev(a1),fd_ddev(a0)
 move.l   fd_xdata(a1),fd_xdata(a0)
 move.w   fd_xftype(a1),fd_xftype(a0)
 move.l   fd_dmd(a1),fd_dmd(a0)

/*
 move.w   fd_stcl(a1),fd_stcl(a0)       ; unnoetig
 move.l   fd_len(a1),fd_len(a0)         ; unnoetig
 move.l   fd_dirpos(a1),fd_dirpos(a0)   ; unnoetig
 move.w   fd_date(a1),fd_date(a0)       ; unnoetig
 move.w   fd_time(a1),fd_time(a0)       ; unnoetig
 move.b   fd_attr(a1),fd_attr(a0)       ; unnoetig
*/

opd_a0:
 move.w   d0,fd_mode(a0)
 move.l   act_pd.l,fd_owner(a0)
 clr.l    fd_fpos(a0)
 move.l   a0,-(sp)
 move.l   fd_ddev(a0),a2
 move.l   ddev_open(a2),a2
 jsr      (a2)
 move.l   (sp)+,a0
 tst.l    d0
 bmi.b    opd_err
 move.l   a0,d0
 move.l   (sp)+,a2
 rts
* Fehler beim Oeffnen: FD einfach freigeben
opd_err:
 move.l   d0,-(sp)
 bsr      free_FD
 move.l   (sp)+,d0
 move.l   (sp)+,a2
 rts
opd_eaccdn:
 moveq    #EACCDN,d0
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* long close_DD(a0 = FD *file)
*
* Es ist sichergestellt, dass nach dem Aufruf der FD noch zur
* Verfuegung steht, da erst nach dem Plattenzugriff der FD freigegeben
* wird.
*
* Aufruf des Geraetetreibers zum Schliessen.
* Die Funktion wird anstelle von dosdev_close im Fall von
* Unterverzeichnissen aufgerufen, weil hier ihr Verzeichniseintrag
* nicht modifiziert wird und Prototyp- FDs nicht freigegeben werden.
* Im wesentlichen werden hier nur Caches zurueckgeschrieben.
*


close_DD:
; zurueckschreiben
 move.l   a2,-(sp)                      ; wg. Pure C
 moveq    #0,d0                         ; kein Fehler
 move.l   fd_multi1(a0),a1              ; Prototyp verwenden!
 bclr     #0,fd_dirch(a1)               ; war Schreibzugriff ?
 beq.b    fdd_nowr                      ; nein !
 move.l   fd_ddev(a0),a2
 move.l   ddev_close(a2),a2
;move.l   a0,a0
 move.l   a0,-(sp)
 jsr      (a2)
 move.l   (sp)+,a0
 tst.l    d0                            ; Fehler ?
 beq.b    fdd_nowr                      ; nein
 cmpi.l   #E_CHNG,d0                    ; Diskwechsel ?
 beq.b    closdd_rts                    ; ja, sofort abbrechen !
 cmpi.l   #EDRIVE,d0                    ; Diskwechsel ?
 beq.b    closdd_rts                    ; ja, sofort abbrechen !
fdd_nowr:
 cmpa.l   fd_multi1(a0),a0              ; bin ich der Prototyp-FD ?
 bne      fdd_clone                     ; nein, Clones einfach freigeben
 clr.l    fd_owner(a0)                  ; Prototyp-FD als unbenutzt markieren
closdd_rts:
 move.l   (sp)+,a2
 rts
fdd_clone:
 move.l   d0,-(sp)
 bsr      free_clone_FD
 move.l   (sp)+,d0
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* EQ/NE namecmp(a0 = char *string1, a1 = char *string2)
*  vergleicht zwei Dateinamen im internen Format (11 Zeichen)
*  auf Uebereinstimmung (ohne Unterscheidung gr/kl)
*  Rueckgabe : 1      Namen gleich
*             0      Namen unterschiedlich
*
*  identisch mit DOS 0.19
*
* nichts korrigiert, nur optimiert
*

namecmp:
 movea.l  a0,a2
;movea.l  a1,a1
 moveq    #11-1,d2                 ; Zaehler fuer dbra
nmc_loop:
 move.b   (a2)+,d0
 jsr      toupper
 move.b   d0,d1
 move.b   (a1)+,d0
 jsr      toupper
 cmp.b    d1,d0
 bne.b    nmc_isne
 dbra     d2,nmc_loop
 moveq    #1,d0
 rts
nmc_isne:
 moveq    #0,d0
 rts


**********************************************************************
*
* EQ/NE filename_match(a0 = char *muster, a1 = char *fname)
*
* Vergleicht ein 12- stelliges Dateimuster mit einem Dateinamen.
* Die Stelle 11 ist das Datei- Attribut(-muster).
* Rueckgabe : 1 = MATCH, sonst 0
*
* Im wesentlichen mit DOS 0.19 identisch, aber toupper nicht verwendet
*
* Korrektur: toupper verwendet, damit Dateien mit Umlautnamen
*            gefunden werden koennen
* Vergleich der Attribute korrigiert, optimiert
*
* Regeln zum Vergleich der Attribute:
*    1) ReadOnly und Archive werden bei dem Vergleich NIEMALS
*       beruecksichtigt.
*    2) Ist das Suchattribut 8, werden genau alle Dateien mit gesetztem
*       Volume- Bit gefunden (auch versteckte usw.).
*    3) Ist das Suchattribut nicht 8, werden normale Dateien IMMER
*       gefunden.
*    4) Ist das Suchattribut nicht 8, werden Ordner nur bei gesetztem
*       Bit 4 gefunden.
*    5) Ist das Suchattribut nicht 8, werden Volumes nur bei gesetztem
*       Bit 3 gefunden.
*    6) Ist das Suchattribut nicht 8, werden versteckte oder System-
*       dateien (auch Ordner oder Volumes) NUR gefunden, wenn das
*       entsprechende Bit im Suchattribut gesetzt ist.
*
* Beispiele (die Bits ReadOnly und Archive sind ohne Belang):
*    8    alle Dateien mit gesetztem Bit 3 (Volumes)
*    0    nur normale Dateien
*    2    normale und versteckte Dateien

*    6    normale, versteckte und System- Dateien
*  $10    normale Dateien, normale Ordner
*  $12    normale und versteckte Dateien und Ordner
*  $16    normale und versteckte und System- Dateien und -Ordner
*   $a    normale und versteckte Dateien und Volumes
*   $e    normale, versteckte und System- Dateien und -Volumes
*  $1e    alles
*


filename_match:
 move.l   a0,a2                    ; a2 = muster
;move.l   a1,a1                    ; a1 = fname
 cmpi.b   #$e5,(a1)
 bne.b    fnmtch_l1
* <fname> ist eine geloeschte Datei
 cmpi.b   #'?',(a2)
 beq      fmat_ne                  ; passt nicht
 cmpi.b   #$e5,(a2)
 beq      fmat_eq                  ; geloeschte Datei gesucht !
* vergleiche 11 Zeichen
fnmtch_l1:
 moveq    #11-1,d2                 ; dbra- Zaehler
fnmtch_loop:
 move.b   (a2)+,d0
 cmpi.b   #'?',d0
 beq.b    fnmtch_l2                ; '?' passt immer
 jsr      toupper
 move.b   d0,d1
 move.b   (a1),d0
 jsr      toupper
 cmp.b    d1,d0
 bne.b    fmat_ne                  ; passt nicht
fnmtch_l2:
 addq.l   #1,a1
 dbra     d2,fnmtch_loop
* Attribut vergleichen
 move.b   (a2),d0                  ; gesucht
 move.b   (a1),d1                  ; gefunden
 cmpi.b   #$0f,d1                  ; langer Dateiname ?
 beq.b    fmat_ne                  ; immer ueberlesen !
 cmpi.b   #FA_VOLUME,d0
 beq.b    fmat_and                 ; nur Volumes suchen
 andi.b   #$1e,d1                  ; SymLink, ReadOnly und Archive ausbl.
 beq.b    fmat_eq                  ; normale Dateien werden immer gefunden
 btst     #FAB_SUBDIR,d1
 beq.b    fmat_nodir
* Ordner gefunden
 btst     #FAB_SUBDIR,d0
 beq.b    fmat_ne                  ; Ordner nur finden, falls $10 gesetzt
fmat_nodir:
 btst     #FAB_VOLUME,d1
 beq.b    fmat_novol
* Volume gefunden
 btst     #FAB_VOLUME,d0
 beq.b    fmat_ne                  ; Volumes nur finden, falls 8 gesetzt
fmat_novol:
 move.b   d1,d2
 andi.b   #FA_HIDDEN+FA_SYSTEM,d2
 beq.b    fmat_and                 ; nicht versteckt
* versteckte oder Systemdatei gefunden
 move.b   d2,d1
 andi.b   #FA_HIDDEN+FA_SYSTEM,d0  ; nur finden, falls Hidden od. System ges.
fmat_and:
 and.b    d1,d0
 beq.b    fmat_ne
fmat_eq:
 moveq    #1,d0
 rts
fmat_ne:
 moveq    #0,d0
 rts


**********************************************************************
*
* void conv_8_3(a0 = char *pathname, a1 = char *name)
*  Das in <pathname> stehende, erste Pfadelement (vor backslash oder EOS)
*  wird ins interne Format gewandelt und nach <name> kopiert
*
* Woertlich mit DOS 0.19 identisch
*
* nur leicht optimiert, nichts korrigiert
*

conv_8_3:
 movea.l  a0,a2
;movea.l  a1,a1
 moveq    #0,d1
 bra.b    c83_nxtloop8
c83_loop8:
 jsr      toupper
 move.b   d0,(a1)+
 addq.w   #1,d1
c83_nxtloop8:
 cmp.w    #8,d1
 bge.b    c83_point
 move.b   (a2)+,d0
 beq.b    c83_endloop8
 cmpi.b   #'*',d0
 beq.b    c83_endloop8
 cmpi.b   #$5c,d0
 beq.b    c83_endloop8
 cmpi.b   #'.',d0
 beq.b    c83_point
 cmpi.b   #' ',d0
 bne.b    c83_loop8

* NEU: Leerstellen durch '_' ersetzen

 moveq    #'_',d0
 bra.b    c83_loop8

* 24.7.96: Letzten Punkt, nicht ersten suchen.
* damit "laber.tar.gz" => "LABER.GZ"

c83_point:
 move.l   a2,a0
c83_point_loop:
 move.b   (a0)+,d0
 beq.b    c83_endloop8
 cmpi.b   #$5c,d0
 beq.b    c83_endloop8
 cmpi.b   #'.',d0
 bne.b    c83_point_loop
;einen weiteren Punkt gefunden!
 move.l   a0,a2                    ; hier weitermachen
 bra.b    c83_point_loop

c83_endloop8:
 subq.l   #1,a2
 cmp.w    #8,d1
 bne.b    c83_fill8
 bra.b    c83_l1
c83_l2:
 addq.l   #1,a2
c83_l1:
 move.b   (a2),d0
 beq.b    c83_fill8
 cmpi.b   #'.',d0
 beq.b    c83_fill8
 cmpi.b   #$5c,d0
 bne.b    c83_l2

*
* Dateiname auf 8 Zeichen auffuellen (' ' oder '?')
*

c83_fill8:
 moveq    #' ',d0
 cmpi.b   #'*',(a2)
 bne.b    c83_l3
 moveq    #'?',d0
c83_l3:
 cmpi.b   #'*',(a2)
 bne.b    c83_l4
 addq.l   #1,a2
c83_l4:
 cmpi.b   #'.',(a2)
 bne.b    c83_l5
 addq.l   #1,a2
c83_l5:
 bra.b    c83_fill8_next
c83_fill8_loop:
 move.b   d0,(a1)+
 addq.w   #1,d1
c83_fill8_next:
 cmpi.w   #8,d1
 blt.b    c83_fill8_loop

*
* Extension kopieren
*

 moveq    #0,d1
 bra.b    c83_ext3_next
c83_ext3_loop:
 move.b   (a2)+,d0
 jsr      toupper
 move.b   d0,(a1)+
 addq.w   #1,d1
c83_ext3_next:
 cmp.w    #3,d1
 bge.b    c83_fill3
 move.b   (a2),d0
 beq.b    c83_fill3
 cmpi.b   #'*',d0
 beq.b    c83_fill3
 cmpi.b   #$5c,d0
 beq.b    c83_fill3
 cmpi.b   #'.',d0
 beq.b    c83_fill3
 cmpi.b   #' ',d0
 bne.b    c83_ext3_loop

*
* Extension auf 3 Zeichen auffuellen (' ' oder '?')
*

c83_fill3:
 moveq    #' ',d0
 cmpi.b   #'*',(a2)
 bne.b    c83_fill3_next
 moveq    #'?',d0
 bra.b    c83_fill3_next
c83_fill3_loop:
 move.b   d0,(a1)+
 addq.w   #1,d1
c83_fill3_next:
 cmp.w    #3,d1
 blt.b    c83_fill3_loop
 rts



**********************************************************************
**********************************************************************
*
* Dateitreiber
*
**********************************************************************
**********************************************************************
*
* long dosdev_read(a0 = FD *file, d0 = long count, a1 = char *buffer)
*
* Leitet nur an den MDEV- Treiber weiter
*

dosdev_read:
 move.l   fd_ddev(a0),a2
 move.l   ddev_read(a2),a2
 jmp      (a2)


**********************************************************************
*
* long dosdev_write(a0 = FD *file, d0 = long count, a1 = char *buffer)
*
* Merkt sich Daten des letzten Schreibzugriffs im Prototyp-FD.
* Leitet dann an den MDEV- Treiber weiter
*

dosdev_write:
 move.l   fd_multi1(a0),a2
 bset     #0,fd_dirch(a2)          ; "dirty"- Flag setzen
 move.w   dos_time.l,d1
 ror.w    #8,d1
 move.w   d1,fd_time(a2)
 move.w   dos_date.l,d1
 ror.w    #8,d1
 move.w   d1,fd_date(a2)
dvw_dir:
 move.l   fd_ddev(a0),a2
 move.l   ddev_write(a2),a2
 jmp      (a2)


**********************************************************************
*
* long dosdev_getc( a0 = FD *f, d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rueckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*

dosdev_getc:
 move.l   fd_ddev(a0),a2
 move.l   ddev_getc(a2),d2
 beq.b    ddv_getc                 ; ist kein Geraet
 move.l   d2,a2
 jmp      (a2)
ddv_getc:
 clr.b    -(sp)
 move.l   sp,a1
 moveq    #1,d0
 bsr      _fread
 bmi.b    ddv_err                  ; Fehler => Fehlercode
 beq.b    ddv_eof                  ; nix => EOF
 moveq    #0,d0
 move.b   (sp),d0                  ; sonst: Zeichen
ddv_err:
 addq.l   #2,sp
 rts
ddv_eof:
 move.w   #$ff1a,d0
 bra.b    ddv_err


**********************************************************************
*
* long dosdev_getline( a0 = FD *f, a1 = char *buf, d1 = long size,
*                      d0 = int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rueckgabe: Anzahl gelesener Bytes oder Fehlercode
*

dosdev_getline:
 move.l   fd_ddev(a0),a2
 move.l   ddev_getline(a2),d2
 beq.b    ddv_getl                 ; ist kein Geraet
 move.l   d2,a2
 jmp      (a2)
ddv_getl:
 movem.l  a5/a4/d6/d7,-(sp)
 move.l   d1,d6                    ; d6 = Anzahl zu lesender Zeichen
 move.l   a0,a5                    ; a5 = FD
 move.l   a1,a4                    ; a4 = buf
 moveq    #0,d7                    ; d7 = Anzahl gelesener Zeichen
 bra.b    ddvgetl_nxt
ddvgetl_loop:
 move.l   a4,a1
 moveq    #1,d0
 move.l   a5,a0
 bsr      _fread
 bmi.b    ddvgetl_ende             ; Fehler => return(errcode)
 beq.b    ddvgetl_eos              ; EOF => Anzahl zurueckgeben
 cmpi.b   #$d,(a4)
 beq.b    ddvgetl_nxt              ; CR ueberlesen
 cmpi.b   #$a,(a4)+
 beq.b    ddvgetl_eos              ; LF schliesst ab
 addq.l   #1,d7                    ; erfolgreich eingelesen
ddvgetl_nxt:
 cmp.l    d6,d7
 bcs.b    ddvgetl_loop
ddvgetl_eos:
 move.l   d7,d0
ddvgetl_ende:
 movem.l  (sp)+,a5/a4/d7/d6
 rts


**********************************************************************
*
* long dosdev_putc( a0 = FD *f, d0 = int mode, d1 = long value )
*
* mode & 0x0001:    cooked
*
* Rueckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

dosdev_putc:
 move.l   fd_ddev(a0),a2
 move.l   ddev_putc(a2),d2
 beq.b    ddv_putc                 ; ist kein Geraet
 move.l   d2,a2
 jmp      (a2)
ddv_putc:
 move.b   d1,-(sp)
 move.l   sp,a1
 moveq    #1,d0
 bsr      _fwrite                  ; => errcode, 1L oder 0L
 addq.l   #2,sp
 rts


**********************************************************************
*
* long dosdev_stat(a0 = FD *f, a1 = long *unselect,
*                  d0 = int rwflag, d1 = long apcode)
*
* Leitet nur an den MDEV- Treiber weiter
*

dosdev_stat:
 move.l   fd_ddev(a0),a2
 move.l   ddev_stat(a2),a2
 jmp      (a2)


**********************************************************************
*
* long dosdev_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*
* Leitet nur an den MDEV- Treiber weiter
*

dosdev_seek:
 move.l   fd_ddev(a0),a2
 move.l   ddev_seek(a2),a2
 jmp      (a2)


**********************************************************************
*
* long dosdev_f_fstat(a0 = FD *f, a1 = XATTR *xattr)
*
* erledigt Fcntl(FSTAT, XATTR *xattr)
*

dosdev_f_fstat:
;move.l   a0,a0                    ; FD *
 move.l   a1,d0                    ; XATTR *
 suba.l   a1,a1                    ; kein DIR *
 moveq    #0,d1                    ; mode (egal)
 bra      _xattr


**********************************************************************
*
* long dosdev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*
* Erledigt FSTAT und FUTIME, leitet sonst
* an den MDEV- Treiber weiter
*

dosdev_ioctl:
 cmpi.w   #FSTAT,d0
 beq.b    dosdev_f_fstat
 cmpi.w   #FUTIME,d0
 beq.b    dosdev_f_futime
 move.l   fd_ddev(a0),a2
 move.l   ddev_ioctl(a2),a2
 jmp      (a2)
dosdev_f_futime:
 addq.l   #timb_modtime,a1         ; nur Modifikationszeit
 moveq    #1,d0                    ; setzen
;bra.b    dosdev_datime


**********************************************************************
*
* long long dosdev_datime(a0 = FD *file, a1 = int d[2], d0 = int set)
*

dosdev_datime:
 move.l   fd_multi1(a0),a0         ; Zugriffe immer auf Prototyp-FD !
 move.l   fd_ddev(a0),a2
 tst.l    ddev_datime(a2)          ; Sonderbehandlung ?
 bne      fdatime_dev              ; ja, Vektor aufrufen
 tst.w    d0
 bne.b    fdt_wr
* lesen (setflag = 0)
 move.w   fd_time(a0),d0
 ror.w    #8,d0

 move.w   d0,(a1)+
 move.w   fd_date(a0),d0
 ror.w    #8,d0
 move.w   d0,(a1)
 moveq    #0,d0                    ; kein Fehler
 rts
* schreiben (setflag = 1)
fdt_wr:
 move.w   (a1)+,d0
 ror.w    #8,d0
 move.w   d0,fd_time(a0)
 move.w   (a1),d0
 ror.w    #8,d0
 move.w   d0,fd_date(a0)
 bset     #0,fd_dirch(a0)          ; Verzeichniseintrag geaendert
 moveq    #0,d0
 rts

fdatime_dev:
 move.l   ddev_datime(a2),a2
 jmp      (a2)


**********************************************************************
*
* long long dosdev_close(a0 = FD *file)
*
* schreibt alles zurueck, ruft den Dateitreiber auf und gibt ggf.
* den FD frei.
*

dosdev_close:
 movem.l  d7/a5,-(sp)
 move.l   a0,a5
 moveq    #0,d7
 tst.w    fd_refcnt(a5)
 beq.b    fclo_free

* Zunaechst das Update des Verzeichnisses, in dem die Datei liegt

;move.l   a5,a0
 bsr      fflush
 move.l   d0,d7                    ; Fehlercode merken

* Dann den Dateitreiber schreiben lassen. Dabei werden ggf.
* auch Sektorpuffer zurueckgeschrieben.

 move.l   fd_ddev(a5),a2
 move.l   ddev_close(a2),a2
 move.l   a5,a0
 jsr      (a2)

 tst.l    d0
 bmi.b    dfc_iserr                ; Fehlercode von ddev ist staerker
 move.l   d7,d0
dfc_iserr:
 move.l   d0,d7

 tst.w    fd_refcnt(a5)
 bmi.b    fclo_ende                ; FD darf nicht freigegeben werden
 subq.w   #1,fd_refcnt(a5)
 bne.b    fclo_ende                ; FD noch in Benutzung

* ggf. den FD freigeben

fclo_free:
 move.l   a5,a0
 bsr      free_FD

fclo_ende:
 move.l   d7,d0
 movem.l  (sp)+,a5/d7
 rts
