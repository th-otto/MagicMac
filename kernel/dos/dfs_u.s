**********************************************************************
*
* Dieses Modul enthaelt den Dateisystemtreiber fuer Laufwerk U:
*

     SUPER


DEBUG     EQU  8

     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "structs.inc"
     INCLUDE "debug.inc"
     INCLUDE "basepage.inc"
     INCLUDE "magicdos.inc"

DRIVE_U        EQU  'U'-'A'        ; fuer "MiNT"
UROOT_LEN      EQU  128            ; soviele Eintraege
_drvbits       EQU  $4c2
_nflops        EQU  $4a6

; Dateitypen:

FT_MEMBLK      EQU  1              ; Speicherblock (Verzeichnis)
FT_SHM         EQU  2              ; "shared memory"
FT_UNIPIPE     EQU  3              ; unidirektionale Pipe
FT_BIPIPE      EQU  4              ; bidirektionale Pipe
FT_DEVICE      EQU  5              ; Device
FT_PROCESS     EQU  6              ; Prozess
FT_SYMLINK     EQU  7              ; symbolischer Link
FT_DEVICE2     EQU  8              ; Device mit Extradaten

     XDEF dfs_u_drv
     XDEF get_u_lnk

     XREF Bmalloc             ; vom BIOS
     XREF Mxalloc,Mfree

     XREF dfs_fat_drv
     XREF fast_clrmem         ; schnelle Speicherloesch- Routine
     XREF str_to_con
     XREF conv_8_3
     XREF rcnv_8_3
     XREF filename_match
     XREF init_DTA
     XREF pd_used_mem         ; von MAGIDOS
     XREF total_mem           ; von MAGIDOS

     XREF upipe_drv,upipe_create
     XREF bipipe_drv,bipipe_create
     XREF memblk_drv
     XREF shm_drv,shm_create
     XREF proc_drv,proc_create
     XREF int_malloc

     XDEF      _anb_devdrv    ; 27.6.2002
     XREF      _bios_devdrv
     XREF      _midi_devdrv
     XREF      _con_devdrv
     XREF      _nul_devdrv

	TEXT

dfs_u_drv:
 DC.B     'DFS_U   '          ; 8 Bytes fuer den Namen
 DC.L     dfs_fat_drv         ; naechster Treiber
 DC.L     fsu_init            ; Initialisierung
 DC.L     fsu_sync            ; Synchronisation (dummy)
 DC.L     drv_open            ; neues Laufwerk
 DC.L     drv_close           ; Laufwerk freigeben
 DC.L     fsu_dfree           ; Fuer Dfree()
 DC.L     fsu_sfirst
 DC.L     fsu_snext
 DC.L     fsu_ext_fd          ; erweitere Verzeichnis
 DC.L     fsu_fcreate         ; erstelle Datei oder Dcntl
 DC.L     fsu_fxattr
 DC.L     fsu_dir2index
 DC.L     fsu_readlink
 DC.L     fsu_dir2FD
 DC.L     fsu_fdelete
 DC.L     fsu_pathconf

pseudo_dirs:
 DC.B     'DEV',0,0,0
 DC.L     udrv_devdir
 DC.B     'PIPE',0,0
 DC.L     udrv_pipedir
 DC.B     'PROC',0,0
 DC.L     udrv_procdir
 DC.B     'SHM',0,0,0
 DC.L     udrv_shmdir


**********************************************************************
*
* void fsu_init( void )
*

fsu_init:
     DEB  'DFS_U initialisieren'
 movem.l  d7/a5/a4,-(sp)

; Root allozieren

 move.l   #((dir_sizeof*UROOT_LEN)+2),d0  ; n Eintraege + EOF- Zeichen
 jsr      Bmalloc                       ; aendert nicht d0
 move.l   a0,(udrv_root).l
 move.l   a0,a5
 movem.l  a0/d0,-(sp)
;lea      (a0),a0
 lea      0(a0,d0.l),a1
 jsr      fast_clrmem                   ; Verzeichnis loeschen
 movem.l  (sp)+,d0/a0

; die 4 Pseudoverzeichnisse anlegen

 moveq    #3,d7                         ; vier Pseudoverzeichnisse
 lea      pseudo_dirs(pc),a4
dosi_loop2:
 move.b   #$10,dir_attr(a5)             ; Unterverzeichnis
 move.w   #-1,dir_stcl(a5)              ; Startcluster ungueltig
 move.l   a5,a1
 move.l   a4,a0
 jsr      conv_8_3
 addq.l   #6,a4

 move.l   #((dir_sizeof*32)+2).l,d0         ; 32 Eintraege + EOF- Zeichen
 jsr      Bmalloc                       ; aendert nicht d0

 movem.l  a0/d0,-(sp)
;lea      (a0),a0
 lea      0(a0,d0.l),a1
 jsr      fast_clrmem                   ; Verzeichnis loeschen
 movem.l  (sp)+,d0/a0

 move.l   (a4)+,a1
 move.l   a0,(a1)

 move.w   #FT_MEMBLK,dir_xftype(a5)     ; Pseudodatei: Speicherblock
 move.l   a0,dir_xdata(a5)              ; Zeiger auf Daten
 subq.l   #2,d0                         ; Nettolaenge
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0
 move.l   d0,dir_flen(a5)               ; Dateilaenge eintragen

 lea      dir_sizeof(a5),a5
 dbra     d7,dosi_loop2

;clr.b    (a5)                          ; EOF- Zeichen !!!

 bset     #DRIVE_U-16,_drvbits+1        ; Laufwerk U: anmelden
 clr.l    (udrv_drvs).l                 ; noch keine Laufwerke gelinkt
 movem.l  (sp)+,d7/a5/a4
 rts


**********************************************************************
*
* void fsu_sync( a0 = DMD *d )
*

fsu_sync:
 moveq    #0,d0
 rts


**********************************************************************
*
* char *get_u_lnk( d0 = int drv, a0 = char *dst )
*
* Sucht nach einem Link von Laufwerk <drv> in U:\. Der Name dieses
* Links wird nach <dst> kopiert (wenn er gefunden wird). Wenn er
* nicht gefunden wird, wird ein Laufwerkbuchstabe kopiert.
*
* Diese Funktion wird fuer Dgetcwd() benoetigt, wenn ein Symlink in
* U:\ umbenannt worden ist.
*

get_u_lnk:
 move.w   d0,-(sp)
 move.l   a0,-(sp)
 bsr.b    _get_link
 move.l   (sp)+,a1
 ble.b    gul_err             ; nicht gefunden
 addq.l   #2,sp
 bra      rcnv_8_3            ; gibt in d0 den Zeiger zurueck
gul_err:
 move.w   (sp)+,d0
 addi.b   #'A',d0
 cmp.b #'Z',d0
 ble.s gul_err2
 sub.b #('Z'+1-'1'),d0
gul_err2:
 move.b   d0,(a1)+            ; Laufwerkbuchstaben einsetzen
 clr.b    (a1)
 move.l   a1,d0
 rts
 

**********************************************************************
*
* DIR *_get_link( d0 = int drv )
*
* Sucht nach einem Link von Laufwerk <drv> in U:\
* Wenn <d0> = -1 ist, wird eine freie Stelle gesucht.
*

_get_link:
 move.l   (udrv_root).l,a0
 move.w   d0,d2                    ; d2.w = drv
 bmi.b    _gl_free                 ; suche freien Platz
 addi.b   #'A',d0
 cmp.b #'Z',d0
 ble.s _gl_drv
 sub.b #('Z'+1-'1'),d0
_gl_drv:
 lsl.w    #8,d0
 move.b   #':',d0
 swap     d0
 move.w   #$5c00,d0                ; d0.l = 'A:\\',0
_gl_free:
 moveq    #UROOT_LEN-1,d1
_gl_loop:
 tst.w    d2
 bge.b    _gl_fnd_drv
; freien Platz suchen
 tst.b    (a0)
 beq.b    _gl_ende                 ; freie Stelle gefunden
 cmpi.b   #$e5,(a0)
 beq.b    _gl_ende                 ; freie Stelle gefunden
 bra.b    _gl_nxt
_gl_fnd_drv:
 tst.b    (a0)
 beq.b    _gl_err                  ; Ende, nix gefunden
 cmpi.b   #$e5,(a0)
 beq.b    _gl_nxt
 cmp.l    dir_xdata2(a0),d0
 beq.b    _gl_ende                 ; es ist unser Pfad
_gl_nxt:
 lea      dir_sizeof(a0),a0
 dbra     d1,_gl_loop
_gl_err:
 suba.l   a0,a0                    ; nix gefunden
_gl_ende:
 move.l   a0,d0
 rts


**********************************************************************
*
* void del_link( d0 = int drv )
*
* entfernt einen Link von Laufwerk in U:\
*

del_link:
 bsr.b    _get_link
 ble.b    ddl_ende
 move.b   #$e5,(a0)                ; Link entfernen
 clr.l    dir_xdata(a0)
 clr.l    dir_xdata2(a0)
ddl_ende:
 rts


**********************************************************************
*
* void add_link( d0 = int drv )
*
* fuegt einen Link auf ein Laufwerk in U:\ ein.
* der Link existiert noch nicht (es wird nicht auf Existenz geprueft).
*

add_link:
 move.w   d0,-(sp)
 moveq    #-1,d0                   ; suche freien Platz
 bsr.b    _get_link
 ble.b    adl_err                  ; keinen gefunden

 move.w   (sp),d0
 addi.b   #'A',d0
 cmp.b #'Z',d0
 ble.s _al_drv
 sub.b #('Z'+1-'1'),d0
_al_drv:
 lsl.w    #8,d0
 move.b   #':',d0
 swap     d0
 move.w   #$5c00,d0                ; d0.l = 'A:\\',0

 move.l   a0,a1
 move.l   #'    ',d1
 move.l   d1,(a0)+
 move.l   d1,(a0)+
 move.l   d1,(a0)
 move.w   #FT_SYMLINK,dir_xftype(a1)    ; Pseudodatei: symbolischer Link
 lea      dir_xdata2-2(a1),a0           ; Platz fuer 2+4 Bytes !
 move.w   #4,(a0)+                      ; Laenge des Links: 4 Bytes
;move.l   a0,dir_xdata(a1)              ; Zeiger auf Link
 move.l   d0,(a0)                       ; Link ist "A:\\" usw.
 move.b   (a0),(a1)                     ; Dateiname
 move.b   #$40,dir_attr(a1)             ; Attributbit 6: symlink

adl_err:
 addq.l   #2,sp
 rts


**********************************************************************
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
 bne      fsu_chkdrv               ; ja, nur Diskwechsel
 cmpi.w   #DRIVE_U,d_drive(a0)     ; unser Treiber ?
 bne      do_edrive                ; nein
     DEB  'Auf dem Laufwerk Dateisystem DFS_U eintragen'
* Dateisystem eintragen
 move.l   #dfs_u_drv,d_dfs(a0)     ; Dateisystem eintragen
 move.w   #-1,d_biosdev(a0)        ; kein BIOS-Device
* Hier waeren bei BIOS-Devices XHDI-Geraetenummern zu ermitteln
 clr.l    d_devcode(a0)            ; devcode ungueltig
;move.l   <>,d_driver(a0)
;move.l   <>,d_devcode(a0)
* Speicher fuer Root- DD_FD holen
 move.l   a0,-(sp)
 bsr      int_malloc
 move.l   (sp)+,a0
 move.l   d0,d_root(a0)            ; Root- DD_FD in den DMD eintragen
* DD der Root initialisieren
 move.l   d0,a1
 move.l   a0,fd_dmd(a1)
 move.w   #dir_sizeof*(NUM_DRIVES+4),fd_len+2(a1)  ; Dateilaenge
 move.l   (udrv_root).l,fd_xdata(a1)                ; Zeiger auf Daten
 move.l   #memblk_drv,fd_ddev(a1)
 move.w   #FT_MEMBLK,fd_xftype(a1)
 move.b   #$10,fd_attr(a1)
fsu_chkdrv:
     DEB  'Auf dem Laufwerk Dateisystem DFS_U testen'
* Laufwerke als Unterverzeichnisse eintragen
 move.l   _drvbits,d2
 move.l   (udrv_drvs).l,d1
 eor.l    d2,d1
 beq.b    do_ok                    ; schon alle eingetragen
 moveq    #0,d0
startdd_loop_u:
 cmpi.w   #DRIVE_U,d0
 beq.b    startdd_loopn_u          ; Laufwerk U: ueberspringen
 cmpi.w   #1,d0                    ; Laufwerk B: ?
 bne.b    stdnob                   ; nein
 cmpi.w   #2,_nflops
 bcs.b    startdd_loopn_u          ; kein physikalisches Laufwerk B:
stdnob:
 btst.l   d0,d1
 beq.b    startdd_loopn_u          ; hat sich nicht geaendert
 move.l   _drvbits,d2
 btst.l   d0,d2
 movem.l  d0/d1/d2,-(sp)
 beq.b    _startdd_del
 bsr      add_link
 bra.b    do_both
_startdd_del:
 bsr      del_link
do_both:
 movem.l  (sp)+,d0/d1/d2
startdd_loopn_u:
 addq.w   #1,d0
 cmpi.w   #NUM_DRIVES,d0
 bcc.s    startdd_loop_u
 move.l   d2,(udrv_drvs).l             ; aktualisieren
do_ok:
 moveq    #0,d0
 rts
do_edrive:
 moveq    #EDRIVE,d0
 rts


**********************************************************************
*
* long drv_close( a0 = DMD *dmd )
*

drv_close:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long fsu_dfree( a0 = DD *d, a1 = long df[4] )
*

fsu_dfree:
 move.l   fd_xdata(a0),a2
 cmpa.l   (udrv_procdir).l,a2
 beq.b    dfr_proc
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)                     ; alles ausnullen
 moveq    #0,d0                    ; kein Fehler
 rts
* FUer U:\PROC
dfr_proc:
 move.l   a6,-(sp)
 move.l   a1,a6
 suba.l   a0,a0
 jsr      pd_used_mem
 lsr.l    #1,d0
 move.l   d0,(a6)+                 ; Anzahl freier "Cluster"
 jsr      total_mem
 lsr.l    #1,d0
 move.l   d0,(a6)+                 ; Gesamtzahl "Cluster"
 moveq    #1,d0
 move.l   d0,(a6)+                 ; 1 Byte pro "Sektor"
 moveq    #2,d0
 move.l   d0,(a6)                  ; 2 "Sektor"en pro "Cluster"
 move.l   (sp)+,a6
 moveq    #0,d0
 rts


*********************************************************************
*
* long fsu_sfirst( a0 = FD   *dd, a1 = DIR *d)
*                  d0 = long pos, d1 = DTA *dta)
*
* Rueckgabe:    d0 = E_OK
*             oder
*              d0 = ELINK
*              a0 = char *link
*

fsu_sfirst:
 move.l   d1,a2
 move.l   a1,dta_dpos(a2)               ; direkt Speicheradresse merken
 cmpi.w   #FT_SYMLINK,dir_xftype(a1)    ; symbolischer Link ?
 beq      fsu_get_symlink
 cmpi.w   #FT_PROCESS,dir_xftype(a1)
 bne.b    fsf_ok
 move.l   dir_xdata(a1),a0              ; proc: Laenge berechnen
 move.l   a2,-(sp)
 bsr      pd_used_mem                   ; Speicherbedarf
 move.l   (sp)+,a2
 move.l   d0,dta_len(a2)
fsf_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* d0 = DIR *fsu_snext( a0 = DTA *dta, a1 = DMD *d )
*
* Rueckgabe:    d0 = E_OK
*             oder
*              d0 = ELINK
*              a0 = char *link
*

fsu_snext:
 movem.l  a5/a3,-(sp)
 move.l   a0,a5
 move.l   dta_dpos(a5),a3          ; a3 ist Suchposition
fsn_ps_loop:
 lea      32(a3),a3                ; naechster Eintrag
 tst.b    (a3)
 beq.b    fsn_notfound             ; Ende des Verzeichnisses
 move.l   a3,a1
 lea      (a5),a0                  ; Suchdateiname im internen Format
 jsr      filename_match
 tst.w    d0
 beq.b    fsn_ps_loop
 move.l   a3,dta_dpos(a5)          ; naechste Position fuer naechstes Fsnext
 move.l   a5,a1                    ; DTA *
 move.l   a3,a0                    ; DIR *
 jsr      init_DTA
 cmpi.w   #FT_SYMLINK,dir_xftype(a3)    ; symbolischer Link ?
 bne.b    fsn_nl
 move.l   a3,a1
 bsr      fsu_get_symlink
 bra.b    fsn_ende
fsn_nl:
 cmpi.w   #FT_PROCESS,dir_xftype(a3)
 bne.b    fsn_ok
 move.l   dir_xdata(a3),a0              ; proc: Laenge berechnen
 bsr      pd_used_mem                   ; Speicherbedarf
 move.l   d0,dta_len(a5)
fsn_ok:
 moveq    #0,d0
fsn_ende:
 movem.l  (sp)+,a3/a5
 rts
fsn_notfound:
 moveq    #ENMFIL,d0
 clr.b    (a5)                     ; Suchname ungueltig
 clr.b    dta_name(a5)             ; gefundener Name leer
 bra.b    fsn_ende


**********************************************************************
*
* long fsu_ext_fd( a0 = FD *f )
*
* Verzeichnisse des Pseudolaufwerks lassen sich nicht verlaengern
*

fsu_ext_fd:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* d0 = MAGX_DEVDRV *DIR2ddev(a1 = DIR *dir)
*
* Gibt zu einer Datei den Geraetetreiber zurueck.
* aendert nur d0
*

ftype_tab:
 DC.L     memblk_drv               ; 1: FT_MEMBLK
 DC.L     shm_drv                  ; 2: FT_SHM
 DC.L     upipe_drv                ; 3: FT_UNIPIPE
 DC.L     bipipe_drv               ; 4: FT_BIPIPE
 DC.L     -1                       ; 5: FT_DEVICE
 DC.L     proc_drv                 ; 6: FT_PROCESS
 DC.L     0                        ; 7: FT_SYMLINK
 DC.L     -1                       ; 8: FT_DEVICE2

DIR2ddev:
 move.w   dir_xftype(a1),d0
 add.w    d0,d0
 add.w    d0,d0
 move.l   ftype_tab-4(pc,d0.w),d0
 bge.b    d2m_ok
 move.l   dir_xdata(a1),d0         ; Device
d2m_ok:
 rts


**********************************************************************
*
* long fsu_fcreate( a0 = FD *d, a1 = DIR *dir,
*                   d0 = int cmd, d1 = long arg )
*
* Rueckgabe: d0.l = Fehlercode
*
* Erstellt eine Datei (oder Verzeichnis) per Dcntl oder Fcreate.
* Ist cmd == 0, wurde nur Fcreate gemacht.
* a0 ist ein DD_FD und im exklusiven Modus geoeffnet
* Es ist <dir> zu aendern und entsprechende Massnahmen zu ergreifen,
* ggf. ein Fehlercode zurueckzugeben.
*

fsu_fcreate:
 cmpi.w   #MX_INT_CREATESYMLNK,d0
 beq      _fcre_symlink
 move.l   fd_xdata(a0),a2          ; Startadresse des Verzeichnisses
 move.w   #-1,dir_stcl(a1)         ; als Pseudodatei markieren
 cmpa.l   (udrv_shmdir).l,a2
 bne.b    _fcre_pweiter

* Sonderbehandlung fuer U:\SHM
 tst.w    d0                       ; cmd == 0 (einfach Datei erstellen) ?
 bne      _fcre_ewrpro             ; nein, return(EWRPRO)
 move.w   #FT_SHM,dir_xftype(a1)
 move.l   a1,a0
 jmp      shm_create               ; -> Fehlercode

_fcre_pweiter:
 cmpa.l   (udrv_devdir).l,a2
 bne.b    _fcre_pweiter2

* Sonderbehandlung fuer U:\DEV
 cmpi.w   #MX_DEV_INSTALL2,d0      ; attr = DEV_M_INSTALL ?
 beq.b    _fcre_devinstall2
 cmpi.w   #MX_DEV_INSTALL,d0       ; attr = DEV_M_INSTALL ?
 beq.b    _fcre_devinstall
 cmpi.w   #DEV_M_INSTALL,d0        ; attr = DEV_M_INSTALL ?
 bne      _fcre_ewrpro             ; nein, return(EWRPRO)
_fcre_devinstall:
 move.w   #FT_DEVICE,dir_xftype(a1)
_fcre__devinstall:
 clr.b    dir_attr(a1)
 move.l   d1,dir_xdata(a1)         ; Geraete- Info einsetzen
 moveq    #0,d0
 rts

* Neue Geraeteinstallation. Zusaetzliches Info-Langwort, das spaeter
* nach fd_usr3 kommt. Ist der Geraetetreiber NULL, wird ein BIOS-
* Geraet erstellt.

_fcre_devinstall2:
 move.l   d1,a0
 move.l   (a0)+,d1                 ; dir_xdata: Treiber
 bne.b    _fcre_devi_no0           ; Treiber angegeben, kein internes Geraet
 move.l   #_nul_devdrv,d1
 cmpi.l   #-1,(a0)
 beq.b    _fcre_devi_no0           ; -1: "NUL:"
 move.l   #_con_devdrv,d1
 cmpi.l   #2,(a0)
 beq.b    _fcre_devi_no0           ; 2: "CON:"
 move.l   #_anb_devdrv,d1          ; 27.6.2002
 cmpi.l   #100,(a0)
 beq.b    _fcre_devi_no0           ; 100: "AUXNB" nichtblockierend
 move.l   #_bios_devdrv,d1
 cmpi.l   #3,(a0)
 bne.b    _fcre_devi_no0
 move.l   #_midi_devdrv,d1         ; 3: "MIDI"
_fcre_devi_no0:
 move.l   (a0),dir_xdata2(a1)      ; dir_xdata2: z.B. BIOS-Geraet
 move.w   #FT_DEVICE2,dir_xftype(a1)
 bra.b    _fcre__devinstall


_fcre_pweiter2:
 cmpa.l   (udrv_procdir).l,a2
 bne.b    _fcre_pweiter3

* Sonderbehandlung fuer U:\PROC
 cmpi.w   #MX_INT_CREATEPROC,d0    ; cmd == PROC_CREATE ?
 bne      _fcre_ewrpro             ; nein, return(EWRPRO)
_fcre_crproc:
 move.w   #FT_PROCESS,dir_xftype(a1)
 move.l   a1,a0
 move.l   d1,a1
 jmp      proc_create

* Sonderbehandlung fuer U:\PIPE
_fcre_pweiter3:
 cmpa.l   (udrv_pipedir).l,a2
 bne.b    _fcre_ewrpro             ; Root ist schreibgeschuetzt !

 tst.w    d0                       ; cmd == 0 (einfach Datei erstellen) ?
 bne.b    _fcre_ewrpro             ; nein, return(EWRPRO)
 btst     #0,dir_attr(a1)
 bne.b    _fcre_upipe
 move.w   #FT_BIPIPE,dir_xftype(a1)
 move.l   a1,a0
 jmp      bipipe_create
_fcre_upipe:
 move.w   #FT_UNIPIPE,dir_xftype(a1)
 move.l   a1,a0
 jmp      upipe_create

_fcre_ewrpro:
 moveq    #EWRPRO,d0
 rts
_fcre_symlink:
 movem.l  d1/a1,-(sp)
 move.l   d1,a0               ; Pfad
 bsr      strlen
 addq.l   #4,d0
 bclr     #0,d0
 move.w   d0,-(sp)
 move.l   act_pd.l,a1
 move.w   #$4002,d1           ; dontfree, ST-RAM preferred
 jsr      Mxalloc
 move.w   (sp)+,d2
 movem.l  (sp)+,d1/a1
 tst.l    d0
 ble.b    _fcre_ensmem
 move.w   #FT_SYMLINK,dir_xftype(a1)
 move.b   #$40,dir_attr(a1)
 move.l   d0,dir_xdata(a1)
 move.l   d0,a0
 move.w   d2,(a0)+
 ror.w    #8,d2
 move.w   d2,dir_flen(a1)
 move.l   d1,a2
_fcre_loop:
 move.b   (a2)+,(a0)+
 bne.b    _fcre_loop
 moveq    #0,d0
 rts
_fcre_ensmem:
 moveq    #ENSMEM,d0
 rts


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
* long fsu_fdelete( a0 = DD *d, a1 = DIR *dir, d0 = long dirpos )
*
* Rueckgabe: Fehlercode.
* symbolische Links werden nicht verfolgt, d.h. der Link als
* solcher wird geloescht.
*

fsu_fdelete:
 bsr      DIR2ddev
 beq.b    del_symlink
 move.l   d0,a2
;move.l   a1,a1
 move.l   ddev_delete(a2),a2
 jmp      (a2)
del_symlink:
 tst.b    dir_xdata2(a1)                ; Link direkt im DIR ?
 bne.b    del_ulink                     ; ja
 move.l   dir_xdata(a1),a0              ; Zeiger auf Pfad
 jmp      Mfree
del_ulink:
 moveq    #0,d0
 rts


**********************************************************************
*
* long fsu_fxattr( a0 = DD *d, a1 = DIR *dir,
*                  d0 = int mode, d1 = XATTR *xattr)
*
* mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurueck)
*         1:   Folge nicht  (d.h. erstelle XATTR fuer den Link)
*
* a1 == NULL: Es ist ein FD (a0)
*

fsu_fxattr:
 move.l   a6,-(sp)
 move.l   d1,a6               ; a6 = XATTR *
 move.l   a1,d2               ; DIR- Eintrag uebergeben ?
 bne.b    fxa_dir             ; ja!
 move.l   fd_xdata(a0),d1     ; nein, xdata aus dem FD holen
 move.w   fd_xftype(a0),d2    ; und xftype aus dem FD holen
 bra.b    fxa_both
fxa_dir:
 move.l   dir_xdata(a1),d1    ; xdata aus dem DIR holen
 move.w   dir_xftype(a1),d2   ; xftype aus dem DIR holen
 cmpi.w   #FT_SYMLINK,d2      ; symlink ?
 bne.b    fxa_both            ; nein
 tst.w    d0                  ; Symlinks verfolgen ?
 bne.b    fxa_sym             ; nein
* symlink muss verfolgt werden
 move.l   d1,xattr_index(a6)            ; index eintragen
 andi.b   #%00001111,xattr_mode(a6)     ; Dateityp ausmaskieren...
 moveq    #14,d1                        ; ...symbolic link
 lsl.b    #4,d1
 or.b     d1,xattr_mode(a6)             ; ...stattdessen eintragen
 move.l   (sp)+,a6
 bra      fsu_get_symlink               ; Symlink ermitteln

fxa_sym:
 tst.b    dir_xdata2(a1)                ; Symlink direkt im DIR ?
 beq.b    fxa_both                      ; nein !
 moveq    #dir_xdata2-2,d1              ; Position des Symlink im DIR
 add.l    a1,d1
fxa_both:
 move.l   d1,xattr_index(a6)
 btst     #4,fd_attr(a0)      ; Datei ist Verzeichnis ?
 bne.b    fxa_fd_isdir        ; ja
 move.l   fd_parent(a0),a2    ; nein, nimm den Parent
 move.l   fd_xdata(a2),a2     ; index des Parent
 bra.b    fxa_dd
fxa_fd_isdir:
 move.l   fd_xdata(a0),a2     ; xdata des FD holen
 cmpi.w   #FT_MEMBLK,d2       ; ist die Datei ein Speicherblock ?
 bne.b    fxa_dd              ; nein, nimm ihr Verzeichnis
 move.l   d1,a2               ; ja, nimm ihren xftype
fxa_dd:
 move.w   #32,xattr_dev(a6)
 cmpa.l   (udrv_devdir).l,a2
 beq.b    fxa_dev             ;  dev: 32
 addq.w   #1,xattr_dev(a6)
 cmpa.l   (udrv_pipedir).l,a2
 beq.b    fxa_dev             ; pipe: 33
 addq.w   #1,xattr_dev(a6)
 cmpa.l   (udrv_procdir).l,a2
 beq.b    fxa_dev             ; proc: 34
 addq.w   #1,xattr_dev(a6)
 cmpa.l   (udrv_shmdir),a2
 beq.b    fxa_dev             ; shm: 35
 move.w   #'U'-'A',xattr_dev(a6)   ; root
fxa_dev:
 cmpi.w   #FT_SHM,d2
 beq.b    fxa_mem
 moveq    #2,d1               ; BIOS special file (Device)
 cmpi.w   #FT_DEVICE,d2
 beq.b    fxa_ok
 cmpi.w   #FT_DEVICE2,d2
 beq.b    fxa_ok
 moveq    #14,d1              ; symbolic link
 cmpi.w   #FT_SYMLINK,d2
 beq.b    fxa_ok
 moveq    #10,d1              ; fifo
 cmpi.w   #FT_UNIPIPE,d2
 beq.b    fxa_ok
 cmpi.w   #FT_BIPIPE,d2
 beq.b    fxa_ok

 cmpi.w   #FT_PROCESS,d2
 bne.b    fxa_normal

 move.l   xattr_index(a6),a0  ; proc: Laenge berechnen
 moveq    #0,d0
 move.w   p_procid(a0),d0
 move.l   d0,xattr_index(a6)
;move.l   a0,a0
 bsr      pd_used_mem         ; Speicherbedarf
 move.l   d0,xattr_size(a6)

fxa_mem:
 moveq    #12,d1              ; memory region or process
fxa_ok:
 andi.b   #%00001111,xattr_mode(a6)
 lsl.b    #4,d1
 or.b     d1,xattr_mode(a6)
fxa_normal:
 move.w   #1,xattr_blksize+2(a6)
 move.l   xattr_size(a6),xattr_nblocks(a6)
 moveq    #0,d0
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* long fsu_dir2index( a0 = FD *d, a1 = DIR *dir )
*
* Rechnet einen DIR- Eintrag in einen Index um
*

fsu_dir2index:
 move.l   dir_xdata(a1),d0
 cmpi.w   #FT_PROCESS,dir_xftype(a1)
 bne.b    fsu2_ok
 move.l   d0,a2
 moveq    #0,d0
 move.w   p_procid(a2),d0
fsu2_ok:
 rts


**********************************************************************
*
* a0 = char *fsu_readlink( a0 = DD *d, a1 = DIR *dir )
*
* Liest symbolischen Link
*

fsu_readlink:
 cmpi.w   #FT_SYMLINK,dir_xftype(a1)    ; symbolischer Link ?
 beq      fsu_get_symlink
frl_err:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long fsu_dir2FD( a0 = FD *fd, a1 = DIR *dir )
*
* initialisiert einen Prototyp-FD, und zwar
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
* Rueckgabe:    0    OK
*             ELINK, a0 ist Zeiger auf symbolischen Link
*             <0    Fehlercode
*
* hier wird kein stcl eingetragen, weil wir keinen brauchen
*

fsu_dir2FD:
 move.w   dir_xftype(a1),d0
 cmpi.w   #FT_SYMLINK,d0                ; symbolischer Link ?
 beq.b    fsu_get_symlink
 cmpi.w   #FT_UNIPIPE,d0
 beq.b    d2f_long
 cmpi.w   #FT_BIPIPE,d0
 beq.b    d2f_long
 cmpi.w   #FT_PROCESS,d0
 bne.b    d2f_normal
d2f_long:
 move.l   #$7fffffff,d1
 bra.b    d2f_both
d2f_normal:
 move.l   dir_flen(a1),d1               ; Laenge (intel)
 ror.w    #8,d1
 swap     d1
 ror.w    #8,d1                         ; -> Motorola
d2f_both:
 move.l   d1,fd_len(a0)                 ; FD- Laenge eintragen

 move.w   d0,fd_xftype(a0)
 move.l   dir_xdata(a1),fd_xdata(a0)    ; ja, Zeiger auf Daten!
 move.l   dir_xdata2(a1),fd_usr3(a0)    ; Benutzerdaten (LONG)
 bsr      DIR2ddev
 move.l   d0,fd_ddev(a0)
 moveq    #0,d0                         ; kein Fehler
 btst     #4,dir_attr(a1)               ; Subdir ?
 bne.b    d2f_dir
* kein SubDir
 move.b   dir_attr(a1),fd_attr(a0)
 rts
* SubDir
d2f_dir:
 lea      fd_name(a0),a0
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)                     ; Name (11 Zeichen) und Attribut
 rts


**********************************************************************
*
* long  fsu_get_symlink( a1 = DIR *dir )
*
* => d0 = ELINK
*    a0 = char *link
*   oder
*    d0 = ernster Fehlercode
*

fsu_get_symlink:
 tst.b    dir_xdata2(a1)                ; Link direkt im DIR ?
 beq.b    fsu2d_ulink                   ; nein
 lea      dir_xdata2-2(a1),a0           ; Zeiger auf Laenge
 bra.b    fsu2d_ende
fsu2d_ulink:
 move.l   dir_xdata(a1),a0              ; Zeiger auf Pfad
fsu2d_ende:
 move.l   #ELINK,d0
 rts


**********************************************************************
*
* long fsu_pathconf( a0 = DD *d, d0 = int which )
*
*         0:   internal limit on the number of open files
*         4:   number of bytes that can be written atomically
*

FA_ALL    SET  FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_VOLUME+FA_SUBDIR+FA_ARCHIVE

fsu_pathconf:
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
 move.l   #FA_ALL+DP_FT_DIR+DP_FT_LNK+DP_FT_CHR+DP_FT_FIFO+DP_FT_MEM,d0
 rts
dpp_4:
 moveq    #1,d0
 rts
dpp_0:
 moveq    #40,d0
 rts
