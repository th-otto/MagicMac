*********************************
*
* MAGIDOS fuer MAGIX
*
*********************************


 DEBUG         EQU  0

 DEBUG_FN      EQU  0
 MONITOR       EQU  0
     IFNE MONITOR
 XREF          mon
     ENDIF


DRIVE_U        EQU  'U'-'A'        ; fuer "MiNT"
N_PROCS        EQU  256            ; Anzahl Prozesse
N_HDLX         EQU  75             ; Anzahl globaler Handles
FDSIZE         EQU  94
DOSMEMSIZ      EQU  150            ; 150 IMBs fuer DOS reservieren
                                   ; MagiC < 6: 70 IMBs
NPDL           EQU  64             ; soviele Prozesse verwenden die SharedLib

     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "structs.inc"
     INCLUDE "debug.inc"
     INCLUDE "basepage.inc"
     INCLUDE "lowmem.inc"

     XDEF  dos_init
     XDEF  mem_root           ; an XAES,MALLOC
     XDEF  __e_dos
     XDEF  swap_paths         ; an XAES
     XDEF  env_clr_int
     XDEF  srch_process       ; an XAES
     XDEF  match_pid          ; an XAES (fuer Pwaitpid())
     XDEF  proc_info          ; => DOS_XFS
     XDEF  dmdx               ; => MAC_XFS
     XDEF  funselect          ; an XAES
     XDEF  env_end            ; an XAES
     XDEF  int_malloc
     XDEF  int_pmalloc
     XDEF  int_mfree
     XDEF dos_time

     XDEF  resv_intmem
     XDEF  resvb_intmem
     XDEF  int_mblocks
     XDEF  _fread,_fwrite,__fseek
     XDEF  Mfree
     XDEF  str_to_con
     XDEF  diskchange

     XDEF  bufl,bufl_size

     XDEF  DMD_rdevinit
     XDEF  getxhdi
     XDEF  Pterm,PDkill
     XDEF  get_act_appl
     XDEF  undo_buf

     XDEF getkey,dump         ; an MALLOC

     XDEF asgndevh            ; an READ_INF
     XDEF iniddev1
     XDEF iniddev2
     XDEF deleddev

* aus MALLOC

     XREF mc_init
     XREF Mxalloc
     XREF Memxavail
     XREF Mxfree
     XREF Mxshrink
     XREF Srealloc
     XREF Maddalt
     XREF Pfree
     XREF Mchgown
     XREF Mgetlen
     XREF Mzombie,Mfzombie
     XREF pd_used_mem
     XREF mshare
     XREF mfork
     XREF Pmemsave,Pmemrestore     ; fuer Pfork()
     IF   DEBUG
     XREF hexl,putstr,crlf
     ENDIF

* Importe aus dem BIOS

     XREF  _start              ; Beginn des ROMs
     XREF  config_status
     XREF  fast_clrmem         ; schnelle Speicherloesch- Routine
     XREF  getcookie           ; Cookie suchen
     XREF  bios2devcode        ; BIOS-Device => devcode (32 Bit)
     XREF  bios_rawdrvr        ; raw-Driver aus dem BIOS
     XREF  vmemcpy             ; a0=dst,a1=src,d0=int len
     XREF  chk_rtclock         ; Prueft, ob MegaST- Uhr da ist
     XREF  read_rtclock        ; MegaST- Uhr auslesen
     XREF  machine_type
     XREF  halt_system
     XREF  Bmalloc
     XREF  Bmaddalt            ; FRB anlegen
     XREF  pe_slice,pe_timer
     XREF  dos_macfn           ; DOS-Funktionen des Macintosh
     XREF  sust_len

* Importe aus dem AES

	 XREF act_appl
     XREF  keyb_app
     XREF  appl_break
     XREF  appl_yield
     XREF  appl_suspend
     XREF  appl_begcritic
     XREF  appl_endcritic
     XREF  appl_alrm
     XREF  evnt_mIO
     XREF  evnt_emIO
     XREF  evnt_IO
     XREF  evnt_sem
     XREF  evnt_pid,hap_pid             ; fuer Pwaitpid()
     XREF  evnt_fork,hap_fork           ; fuer P(v)fork()
     XREF  appl_IOcomplete
     XREF  psig_freeze
     XREF  toupper
     XREF  _sprintf
     XREF sigreturn,do_signals,pkill_threads,wait_signals
     XREF exec_10x

* Importe aus dem VDI

     XREF  vdi_entry

* Importe aus XFS_DOS

     XREF  dosxfs

* Importe aus DFS_FAT

     XREF  secb_ext

* Importe aus DFS_U

     XREF get_u_lnk

* Importe aus DEV_BIOS

     XREF  Bputch,get_termdata
     XREF  dos_break

* Importe aus STD

     XREF stricmp
     XREF fn_name
     XREF ffind
     XREF crlf

	INCLUDE "country.inc"




/*
*
* Header fuer "shared library".
* Liegt direkt hinter dem Programmheader.
*
*/

     OFFSET

slb_magic:     DS.L      1    /* 0x70004afcL (moveq #0,d0;illegal)    */
slb_name:      DS.L      1    /* Zeiger auf Namen der Bibliothek      */
slb_version:   DS.L      1    /* Versionsnummer                       */
slb_flags:     DS.L      1    /* Flags, z.Zt. 0L                      */
slb_init:      DS.L      1    /* wird nach dem Laden aufgerufen       */
slb_exit:      DS.L      1    /* wird vor dem Entfernen aufgerufen    */
slb_open:      DS.L      1    /* wird beim Oeffnen aufgerufen          */
slb_close:     DS.L      1    /* wird beim Schliessen aufgerufen       */
slb_names:     DS.L      1    /* Zeiger auf Prozedurnamen (optional)  */
slb_unused:    DS.L      8    /* (z.Zt. unbenutzt, immer NULL)        */
slb_fnn:       DS.L      1    /* Anzahl der Funktionen                */
slb_fx:
slb_sizeof:
;              DS.L      fnn  /* ...Funktionszeiger...                */

/*
*
* Struktur fuer eine geladene "shared library".
*
*/

     OFFSET

lslb_next:     DS.L      1    /* Verkettungszeiger                    */
lslb_slb:      DS.L      1    /* Zeiger auf den Header                */
lslb_refcnt:   DS.W      1    /* Referenzierungszaehler                */
lslb_pdtab:    DS.L      NPDL /* Prozesse, die die Lib verwenden      */
lslb_sizeof:

/*
*
* Header fuer Programmdatei
*
*/
     OFFSET

ph_branch:     DS.W      1    /* 0x00: muss 0x601a sein!! */
ph_tlen:       DS.L      1    /* 0x02: Laenge  des TEXT - Segments */
ph_dlen:       DS.L      1    /* 0x06: Laenge  des DATA - Segments */
ph_blen:       DS.L      1    /* 0x0a: Laenge  des BSS  - Segments */
ph_slen:       DS.L      1    /* 0x0e: Laenge  der Symboltabelle   */
ph_res1:       DS.L      1    /* 0x12: */
ph_flags:      DS.L      1    /* 0x16:  Bit 0: Heap nicht loeschen */
                              /*        Bit 1: Laden ins FastRAM  */
                              /*        Bit 2: Malloc aus FastRAM */
                              /*        Bit 3: nur t+d+b+s (MagiC 5.20) */
                              /*        Bit 4,5,6,7: Speicherschutz (MiNT) */
                              /*        Bit 8: unbenutzt          */
                              /*        Bit 9: unbenutzt          */
                              /*        Bit 10: unbenutzt         */
                              /*        Bit 11: SharedText (MiNT) */
                              /*        Bit 12: unbenutzt         */
                              /*        Bit 13: unbenutzt         */
                              /*        Bit 14: unbenutzt         */
                              /*        Bit 15: unbenutzt         */
                              /*        Bits 31..28: TPA-Size     */
                              /*         (mal 128k + 128k: Mindestgr. Heap */
ph_reloflag:   DS.W      1    /* 0x1a: != 0: nicht relozieren */
ph_sizeof:






     OFFSET

imb_link:      DS.L      1    /* 0x00: Zeiger auf naechsten Block           */
imb_used:      DS.B      1    /* 0x04: 0=unbenutzt  -1=DD/FD/DMD 1=MDs     */
imb_switch:    DS.B      1    /* 0x05: unbenutzt                           */
imb_data:      DS.B FDSIZE    /* 0x06: Datenbereich                        */
imb_sizeof:

     IF    (fd_sizeof>FDSIZE)
     FAIL
     ENDIF
     IF    (dmd_sizeof>FDSIZE)
     FAIL
     ENDIF

     INCLUDE "magicdos.inc"

     SUPER
     MC68020




     TEXT

* ORG      $fc4388


**********************************************************************
**********************************************************************
*
* Initialisierung von GEMDOS
*
**********************************************************************
**********************************************************************
*
* dos_init( void )
*

dos_init:

     DEBON
     DEB  'Initialisierung des DOS'

* Prozesstabelle initialisieren und loeschen

 clr.w    nxt_procid
 move.l   #N_PROCS*4,d0            ; N_PROC Eintraege
 jsr      Bmalloc
 move.l   a0,procx
;move.l   a0,a0
 lea      N_PROCS*4(a0),a1
 jsr      fast_clrmem

* Geraete-Handle-Tabelle loeschen

 lea      dev_fds,a0
 lea      16(a0),a1
 jsr      fast_clrmem

* Verwaltung des internen Speichers initialisieren

 move.l   #deflt_doslimits,p_doslimits  ; initiale DOSLIMITS-Struktur
 clr.l    imbx
 move.l   #(DOSMEMSIZ*imb_sizeof),d0
 jsr      Bmalloc
;move.l   d0,d0                    ; Pufferlaenge (80*70)
;lea      a0,a0                    ; Platz fuer IMBs
 bsr      resv_intmem

* Dateisysteme (XFSs) initialisieren

     DEB  'XFSs initialisieren'

 move.l   #dosxfs,xfs_list

 move.l   a5,-(sp)
 move.l   xfs_list,a5
 bra.b    dosi_nfs
dosi_nloop:
 move.l   xfs_init(a5),a0
 jsr      (a0)
 move.l   xfs_next(a5),a5
dosi_nfs:
 move.l   a5,d0
 bne.b    dosi_nloop
 move.l   (sp)+,a5

     DEB  'Semaphoren erstellen'

 move.l   #'_DCH',d1
 lea      dskchg_sem,a0
 moveq    #SEM_CREATE,d0
 jsr      evnt_sem
 move.l   #'_EXE',d1
 lea      pexec_sem,a0
 moveq    #SEM_CREATE,d0
 jsr      evnt_sem
 move.l   #'_F12',d1               ; fuer 12-Bit-FAT
 lea      fat12_sem,a0
 moveq    #SEM_CREATE,d0
 jsr      evnt_sem

* Rest initialisieren

     DEB  'Rest des DOS initialieren'

 clr.l    lslb_list                ; keine SharedLib geladen
 bsr      os_init                  ; Prozess setzen

 move.w   _bootdev,d0
 move.l   #dosvars,(config_status+4).w
 bsr      Dsetdrv

     IFNE MONITOR
 bsr      load_monitor
     ENDIF

 pea      -1
 clr.l    -(sp)                    ; BIOS-Geraet
 lea      (sp),a1
 lea      nul_name_s(pc),a0
 move.w   #MX_DEV_INSTALL2,d0
 bsr      Dcntl
 addq.l   #8,sp

; fuer den Hddriver muessen alle Geraete und Handles definiert werden

 bsr.s      iniddev1
 bsr      iniddev2
 rts


*********************************************************************
*
* d0 = LONG deleddev( void )
*
* Loescht alle Geraete und Handles wieder, nachdem Hddriver gelaufen
* ist, damit die magx.inf ausgewertet werden kann.
*

deleddev:
     DEB  'Devices wieder l',$94,'schen'
 movem.l  a5/a6/d7,-(sp)

; erst die Standard-Handles des Boot-Prozesses loeschen

 lea      ur_pd,a0
 move.l   p_procdata(a0),a0
 lea      pr_hndm4(a0),a5               ; Beginne bei Handle -4
 lea      dev_fds,a6
 moveq    #-MIN_FHANDLE-1,d7
ddv_loop:
 move.l   (a6),a0
 clr.l    (a6)+                         ; gleich loeschen
 move.w   #1,fd_refcnt(a0)              ; damit freigeben wird
 move.l   fd_dev(a0),a2
 move.l   dev_close(a2),a2
 jsr      (a2)                          ; freigeben
 clr.l    (a5)+                         ; im Prozess Handle ungueltig
 addq.l   #2,a5                         ; fh_flag ueberspringen
 dbra     d7,ddv_loop
 clr.l    (a5)+                         ; Handle 0
 addq.l   #2,a5
 clr.l    (a5)+                         ; Handle 1
 addq.l   #2,a5
 clr.l    (a5)+                         ; Handle 2
 addq.l   #2,a5
 clr.l    (a5)+                         ; Handle 3
 addq.l   #2,a5
 clr.l    (a5)+                         ; Handle 4
 addq.l   #2,a5
 clr.l    (a5)                          ; Handle 5

; Dann die Geraetedateien loeschen
 pea      con_name_s(pc)
 lea      (sp),a0
 bsr      D_Fdelete
 addq.l   #4,sp

 pea      aux_name_s(pc)
 lea      (sp),a0
 bsr      D_Fdelete
 addq.l   #4,sp

 pea      prn_name_s(pc)
 lea      (sp),a0
 bsr      D_Fdelete
 addq.l   #4,sp

 movem.l  (sp)+,a5/a6/d7
 rts


*********************************************************************
*
* d0 = LONG iniddev1( void )
*
* Initialisiert die Geraete, die noch nicht in der magx.inf
* definiert wurden.
*

iniddev1:
     DEB  'Devices initialisieren'
 pea      100                      ; Spezial-AUX (nichtblockierend) 27.6.2002
 clr.l    -(sp)                    ; BIOS-Geraet
 lea      (sp),a1
 lea      auxnb_name_s(pc),a0
 move.w   #MX_DEV_INSTALL2,d0
 bsr      Dcntl
 addq.l   #8,sp

 pea      2                        ; CON
 clr.l    -(sp)                    ; BIOS-Geraet
 lea      (sp),a1
 lea      con_name_s(pc),a0
 move.w   #MX_DEV_INSTALL2,d0
 bsr      Dcntl
 addq.l   #8,sp

 pea      1                        ; AUX
 clr.l    -(sp)                    ; BIOS-Geraet
 lea      (sp),a1
 lea      aux_name_s(pc),a0
 move.w   #MX_DEV_INSTALL2,d0
 bsr      Dcntl
 addq.l   #8,sp

 pea      0                        ; PRN
 clr.l    -(sp)                    ; BIOS-Geraet
 lea      (sp),a1
 lea      prn_name_s(pc),a0
 move.w   #MX_DEV_INSTALL2,d0
 bsr      Dcntl
 addq.l   #8,sp
 rts


*********************************************************************
*
* d0 = LONG iniddev2( void )
*
* Initialisiert die Geraete-Handles, die noch nicht in der magx.inf
* definiert wurden.
*

iniddev2:
     DEB  'Ger',$84,'tehandles -1..-4 erzeugen'
 movem.l  d7/a5/a4,-(sp)
 moveq    #3,d7
 lea      dev_fds,a5
 lea      u_devices+16(pc),a4           ; beginne mit NUL:
dosi_dmloop:
 move.l   -(a4),a0
 move.l   (a5),d0                       ; schon geoeffnet?
 bne.b    dosi_savedm                   ; ja!
 bsr.s      open_device
 bgt.b    dosi_savedm                   ; FD ist in Ordnung
 moveq    #0,d0                         ; FD ist ungueltig
dosi_savedm:
 move.l   d0,(a5)+                      ; FD merken
 dbra     d7,dosi_dmloop

 move.l   act_pd,a0
 bsr      init_stdfiles                 ; STDXXX fuer Ur-Prozess initialisieren

 movem.l  (sp)+,d7/a5/a4

;    DEBON
     DEB  'Initialisierung abgeschlossen'

 rts


*********************************************************************
*
* d0 = LONG asgndevh(d0 = WORD hdl, a0 = char *fname)
*
* Oeffnet ein negatives Geraetehandle
*

asgndevh:
 add.w    d0,d0
 add.w    d0,d0
 lea      dev_fds+16,a1
 pea      0(a1,d0.w)
;move.l   a0,a0
 bsr.s      open_device
 move.l   (sp)+,a0
 bmi.b    asdh_ende                ; Fehler
 move.l   d0,(a0)                  ; abspeichern
asdh_ende:
 rts


*********************************************************************
*
* MI/PL d0 = FD *open_device(a0 = char *fname)
*
* Oeffnet ein negatives Geraetehandle
*

open_device:
 moveq    #O_RDWR,d0               ; Lesen und Schreiben
;move.l   a0,a0
 bsr      Fopen                    ; Geraet oeffnen
 tst.l    d0
 bmi.b    opnd_ende                ; Fehler beim Oeffnen
 bsr      hdl_to_FD
 bmi.b    opnd_ende
 move.l   d0,a1
 move.w   #-1,fd_refcnt(a1)        ; als unbegrenzt geoeffnet markieren
 ori.w    #OM_NOCHECK,fd_mode(a1)  ; sharing
 clr.l    (a0)                     ; Handle wieder freigeben
 move.l   a1,d0
opnd_ende:
 rts


     IFNE MONITOR
__lm1:    DC.B $d,$a
          DC.B 'MONITOR: erstelle Basepage',$d,$a,0
__lm2:    DC.B 'MONITOR: Lade...',$d,$a,0
__lm3:    DC.B 'MONITOR: starte',$d,$a,0
__lm4:    DC.B 'MONITOR: Fehler beim Laden',$d,$a,0
__lm5:    DC.B 'MONITOR: Laden beendet, Taste',$d,$a,$a,0
     EVEN
load_monitor:
 movem.l  a3-a6/d3-d7,-(sp)

 lea      __lm1(pc),a0
 bsr      str_to_con

 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 move.w   #5,-(sp)            ; Erstelle Basepage
 move.l   sp,a0
 bsr      D_Pexec
 adda.w   #14,sp
 move.l   d0,a6

 lea      __lm2(pc),a0
 bsr      str_to_con

 move.l   a6,-(sp)
 lea      mon,a0
 cmpi.w   #$601a,(a0)
 bne      dos_fatal_err
 moveq    #-1,d0         ; MON lesen
 bsr      pload
 addq.l   #4,sp

 tst.l    d0
 bne.b    _mon_err

 lea      __lm3(pc),a0
 bsr      str_to_con

 clr.l    -(sp)
 move.l   a6,-(sp)
 clr.l    -(sp)
 move.w   #4,-(sp)
 move.l   sp,a0
 bsr      D_Pexec
 adda.w   #14,sp
 bra      _mon_ok
_mon_err:

 lea      __lm4(pc),a0
 bsr      str_to_con

 move.l   a6,a0
 bsr      Mfree
_mon_ok:

 lea      __lm5(pc),a0
 bsr      str_to_con
 bsr      getkey

 movem.l  (sp)+,a3-a6/d3-d7
 rts
     ENDIF


**********************************************************************
*
* os_init()
*  wird von dos_init aufgerufen.
*  Initialisiert das GEMDOS (exception- Vektoren) nach einem Reset.
*
* neu: auch etv_critic
*

os_init:
 clr.l    xaes_appls
 move.l   _start+$14,a0            ; os_magic
 move.l   -4(a0),config_status.w   ; Default- Konfigurationsbits
 lea      dos_trap1(pc),a0
 move.l   a0,$84
 move.l   $88,otrap2
 lea      dos_trap2(pc),a0
 move.l   a0,$88
 move     sr,-(sp)
 ori      #$700,sr
 pea      dos_etv_timer(pc)
 move.w   #$100,-(sp)
 move.w   #5,-(sp)
 trap     #$d                 ; bios Setexc
 addq.l   #8,sp
 move.l   d0,otimer
 clr.l    criticret           ; MagiC 6.01: Semaphore fuer Handler
 pea      etv_critic_vec(pc)
 move.w   #$101,-(sp)
 move.w   #5,-(sp)
 trap     #$d                 ; bios Setexc
 addq.l   #8,sp
 move     (sp)+,sr
* Ur- PD einrichten (256 Bytes!!) und mit 0 initialisieren
 lea      ur_pd,a1
 move.l   a1,act_pd
 movea.l  a1,a0
 moveq    #$40-1,d0
osinit_loop:
 clr.l    (a0)+
 dbra     d0,osinit_loop
 move.l   #$ffffffff,p_mem(a1)
* PROCDATA
 move.l   a1,-(sp)
 move.l   #pr_sizeof,d0
 jsr      Bmalloc
 move.l   (sp),a1
 move.l   a0,p_procdata(a1)
;move.l   a0,a0
 lea      pr_sizeof(a0),a1
 jsr      fast_clrmem              ; Block loeschen
 move.l   (sp)+,a1
* Default- Handles fuer Standarddateien in den PD kopieren
* (sind ab MagiC 6.20 nur dummies)
 lea      def_hdlx(pc),a0
 lea      p_devx(a1),a1
 move.l   (a0)+,(a1)+
 move.w   (a0),(a1)
* Speicherverwaltung
 bra      mc_init

*
* void dump( d0 = int drv )
*

dump:
 movem.l  d0-d2/a0-a2,-(sp)
 bsr      Dsetdrv
 lea      dumps(pc),a0
 moveq    #0,d0
 bsr      Fcreate
 tst.w    d0
 ble.b    nixx
 move.w   d0,-(sp)

 pea      ur_pd
 pea      mem_root.w
 moveq    #8,d1                    ; erst mem_root, dann ur_pd
 lea      (sp),a0
 bsr      Fwrite
 addq.l   #8,sp

 move.w   (sp),d0
 move.l   phystop,d1
 subq.l   #8,d1
 lea      8,a0
 bsr      Fwrite

 move.w   (sp)+,d0
 bsr      Fclose
nixx:
 movem.l  (sp)+,d0-d2/a0-a2
 rts
dumps:    DC.B '\_sys_.$$$',0
     EVEN


**********************************************************************
**********************************************************************
*
* Speicherverwaltung
*

**********************************************************************
*
* void *Malloc(long size)
*

D_Malloc:
 move.l   act_pd,a1
 move.l   p_mflags(a1),d1
 move.l   (a0),d0
 beq.b    mal_leer                 ; wollte 0 Bytes holen


**********************************************************************
*
* void *Malloc(d0 = long size, d1 = long prgflags )
*

Malloc:
 btst     #2,d1
 sne      d1                       ; Malloc darf TT-RAM holen
 andi.w   #3,d1                    ; Modus 0 bzw. 3
 bra.b    _xalloc
mal_leer:
 moveq    #1,d0
 rts


**********************************************************************
*
* void *D_Mxalloc(long size, int mode)
*
* mode == 0: nur ST-RAM
*         1: nur FastRAM
*         2: lieber ST-RAM
*         3: lieber FastRAM
*
* Bit 13: nolimit
* Bit 14: dontfree
*

D_Mxalloc:
 move.l   (a0)+,d0       ; Menge
 beq.b    mal_leer       ; wollte 0 Bytes holen
 move.w   (a0),d1        ; mode
_xalloc:
 move.l   act_pd,a1
;    IF   (DEBUG&DEBLEVEL)
;    DEBL d0,'Mxalloc '
; jsr          Mxalloc
;    DEBL d0,'Mxalloc -> '
; rts
;    ELSE
 jmp      Mxalloc
;    ENDIF


**********************************************************************
*
* Kernelfunktionen fuer das XFS
*

ker_mxalloc:
 move.l   a0,a1          ; PD ist angegeben
;move.w   d1,d1
;move.l   d0,d0
 jmp      Mxalloc
ker_mshrink:
 suba.l   a1,a1          ; kein p_mem modifizieren
;move.l   a0,a0
;move.l   d0,d0
 jmp      Mxshrink
ker_mfree:
 suba.l   a1,a1          ; kein p_mem modifizieren
;move.l   a0,a0
 jmp      Mxfree


**********************************************************************
*
* long Mshrink(a0 = char *memblock, d0 = long size)
*
* Im wesentlichen aus KAOS 1.2, also gegenueber TOS 1.4 noch folgendes:
*  - Es kann ein Block vergroessert werden (wie in MS-DOS) !!
*  - Wird -1L als Groesse uebergeben, wird die groesstmoegliche Groesse
*    des Speicherblocks zurueckgegeben.
*  - Bei neuer Groesse 0L, bringt TOS 1.4 den Block sowohl in die freelist
*    als auch in die alloc-list, was toedlich ist und daher nicht
*    uebernommen wurde.
* Neu gegenueber KAOS 1.2:
*  - Bei neuer Groesse 0L einfach Block freigeben
*

D_Mshrink:
 addq.l   #6,a0
 move.l   (a0),d0
 move.l   -(a0),a0
Mshrink:
 move.l   act_pd,a1
 jmp      Mxshrink


**********************************************************************
*
* long Srealloc( long size)
*
* size == -1L: maximal moegliche Groesse ermitteln
* sonst:       alten Block freigeben, neuen allozieren
*
* => NULL      Fehler
*    sonst     Adresse des Puffers
*

D_Srealloc:
 move.l   (a0),d0
 jmp      Srealloc


**********************************************************************
*
* PUREC LONG Mfree( void *memblk )
*
* long Mfree(a0 = char *memblock)
*
* Mfree(1L) => E_OK
* Seit Mag!X 3.00 wird die Adresse ueberprueft, ob sie in einem der
* Speicherbloecke liegt.
*

D_Mfree:
 move.l   (a0),a0
Mfree:
 move.l   act_pd,a1
 jmp      Mxfree



**********************************************************************
**********************************************************************
*
* Zeichenorientierte Funktionen
*

**********************************************************************
*
* long D_Cconout(a0 => int c)
* long D_Cauxout(a0 => int c)
* long D_Cprnout(a0 => int c)
*
* Diese Funktionen gingen bisher ueber Fwrite, gehen aber ab
* Mag!X 3.00 wegen MiNT- Konvention ueber Fputchar().
* Dabei ist nach MiNT- Konvention nur Cconout() "cooked".
* Das "int" wird auf "unsigned long" erweitert.
*

D_Cconout:
 moveq    #CMODE_COOKED,d1
 moveq    #STDOUT,d0
 bra.b    _cconout
D_Cauxout:
 moveq    #STDAUX,d0
 bra.b    _cconout_raw
D_Cprnout:
 moveq    #STDPRN,d0
_cconout_raw:
 moveq    #CMODE_RAW,d1
_cconout:
 move.w   d1,-(sp)                 ; mode
 move.w   (a0),-(sp)
 clr.w    -(sp)                    ; int => unsigned long
 move.w   d0,-(sp)                 ; Handle
 move.l   sp,a0
 bsr      D_Fputchar
 addq.l   #8,sp
 rts


**********************************************************************
*
* long Cconis()
* long Cauxis()
* long Cconos()
* long Cauxos()
* long Cprnos()
*
* RUeckgabe: 0       nicht lese-/schreibbereit oder Fehler
*              -1   lesebereit
*
* Diese Funktionen gehen ueber Fin/outstat und sind daher "raw".
* wegen TOS- Kompatibilitaet raw- Status
*

D_Cconis:
 moveq    #STDIN,d0
 bra.b    _cis
D_Cauxis:
 moveq    #STDAUX,d0
_cis:
 moveq    #0,d1                    ; read
 bra      __cis
D_Cconos:
 moveq    #STDOUT,d0
 bra.b    _cos
D_Cauxos:
 moveq    #STDAUX,d0
 bra.b    _cos
D_Cprnos:
 moveq    #STDPRN,d0
_cos:
 moveq    #1,d1                    ; write
__cis:
 suba.l   a1,a1
 suba.l   a0,a0                    ; polling
 bsr      Fstat
 tst.l    d0
 sgt      d0                       ; <=0 -> 0 / 1-> -1
 ext.w    d0
 ext.l    d0
 rts


**********************************************************************
*
* Cconws( char *s )
*
* Gibt in Analogie zu Fwrite die Laenge des Strings zurueck.
* Dies entspricht dem Verhalten in MiNT.
*
* Die Funktion wird direkt auf Fwrite zurueckgefuehrt und ist daher
* "cooked" (falls der Dateitreiber dies kann)
*
* TOS 1.4 liefert 0L (ok) oder ERROR (eof), dies wird ab
* Mag!X 3.00 nicht mehr unterstuetzt.
*

D_Cconws:
 move.l   (a0),-(sp)
 move.l   (sp),a0
 bsr      strlen
 move.l   (sp)+,a0
 move.l   d0,d1                    ; count
 moveq    #STDOUT,d0
 bra      Fwrite

/*
D_Cconws:
 move.l   (a0),-(sp)
 move.l   (sp),a0
 bsr      strlen
 move.l   (sp)+,a0
 move.l   d0,d1                    ; count
 moveq    #1,d0                    ; Handle
 move.l   d1,-(sp)                 ; d1 merken
 bsr      Fwrite
 move.l   (sp)+,d1                 ; d1 holen

 btst     #5,(config_status+3).w   ; Kompatibilitaet ?
 beq      cconws_end1              ; KAOS: Rueckgabewert weiterreichen
* TOS 1.4 liefert 0L (ok) oder ERROR (eof)
 tst.l    d0
 bmi      cconws_end1              ; Fehler immer weiterreichen
 cmp.l    d0,d1
 bcc.b    cconws_ret0
 moveq    #ERROR,d0
cconws_end1:
 rts
cconws_ret0:
 moveq    #0,d0
 rts
*/


**********************************************************************
*
* long Crawio(int c)
*
*  1. Fall: <c> == 0x00ff
*     Wenn kein Zeichen anliegt: return(0L)
*     sonst lies ein Zeichen im "raw"- Modus von STDIN
*  2. Fall: sonst
*     Schreibe <c> im "raw"- Modus nach STDOUT
*

D_Crawio:
 moveq    #STDOUT,d0
 cmpi.w   #$00ff,(a0)
 bne      _cconout_raw        ; d0 = Handle, (a0).w = char
 bsr.s      D_Cconis
 tst.l    d0
 bne.b    D_Crawcin
 rts


**********************************************************************
*
* long Cconin ( void )        STDIN     COOKED    ECHO
* long Cnecin ( void )        STDIN     COOKED
* long Crawcin( void )        STDIN     RAW
* long Cauxin ( void )        STAUX     RAW
*
* Liest Zeichen ein.
*

D_Cconin:
 moveq    #CMODE_COOKED+CMODE_ECHO,d1
 moveq    #STDIN,d0
 bra.b    _cin_char
D_Cnecin:
 moveq    #CMODE_COOKED,d1
 moveq    #STDIN,d0
 bra.b    _cin_char
D_Cauxin:
 moveq    #CMODE_RAW,d1
 moveq    #STDAUX,d0
 bra.b    _cin_char
D_Crawcin:
 moveq    #CMODE_RAW,d1
 moveq    #STDIN,d0
_cin_char:
 move.w   d1,-(sp)            ; Modus
 move.w   d0,-(sp)            ; Handle
 move.l   sp,a0
 bsr      D_Fgetchar
 addq.l   #4,sp
 rts



**********************************************************************
*
* long Cconrs(char *buf)
*
* Eingabe:     buf[0]    Anzahl zu lesender Zeichen
* Ausgabe:     buf[1]    tatsaechlich gelesene Zeichen
*
* Rueckgabe:    E_OK oder Fehlercode
*

D_Cconrs:
 move.l   (a0),a0
 clr.b    1(a0)               ; noch kein Zeichen gelesen
 move.l   a0,-(sp)
 moveq    #STDIN,d0
 bsr      hdl_to_FD
 move.l   (sp)+,a1
 bmi.b    crs_ende
 move.l   d0,a0
 moveq    #0,d1
 move.b   (a1)+,d1                      ; Anzahl zu lesender Zeichen
 moveq    #CMODE_COOKED+CMODE_ECHO,d0   ; Modus
 move.l   a1,-(sp)                      ; buf+1 merken
 addq.l   #1,a1                         ; buf
 move.l   fd_dev(a0),a2
 move.l   dev_getline(a2),a2
 jsr      (a2)                          ; => Anzahl Zeichen oder errcode
 move.l   (sp)+,a1
 tst.l    d0
 bmi.b    crs_ende
 move.b   d0,(a1)                       ; buf[1] = Anzahl Zeichen
 moveq    #0,d0                         ; kein Fehler
crs_ende:
 rts



**********************************************************************
**********************************************************************
*
* Verwaltung der Laufwerke
*
**********************************************************************
**********************************************************************
*
* DMD *drv_to_dmd( d0 = int drive )
*
* aendert nur a0
*

drv_to_dmd:
 move.w   d0,a0
 add.w    a0,a0
 add.w    a0,a0
 move.l   dmdx(a0),a0
 rts


**********************************************************************
*
* EQ/NE long getxhdi( void )
*
* Liefert den Funktionszeiger
*

getxhdi:
 move.l   #'XHDI',d0
 jsr      getcookie
 beq.b    gxh_err             ; Cookie nicht gefunden
 move.l   d1,a0               ; Wert des Cookies
 cmpi.l   #$27011992,-4(a0)   ; magischer Wert
 bne.b    gxh_err             ; ungueltig
; a1 ist jetzt der XHDI-Funktionszeiger
 move.l   a0,-(sp)
 clr.w    -(sp)
 jsr      (a0)                ; XHGetVersion
 addq.l   #2,sp
 move.l   (sp)+,a0
 tst.l    d0
 bmi.b    gxh_err             ; Funktionsaufruf ungueltig
 cmpi.w   #$0110,d0
 bcs.b    gxh_err             ; Versionsnummer zu klein
 move.l   a0,d0
 rts
gxh_err:
 moveq    #0,d0
 rts


**********************************************************************
*
* long xhdi_rawdrvr( d0 = int opcode, d1 = long devcode, ... )
*
* Fuehrt geraetespezifische Aktionen aus.
*
* d0 = 0: Medium auswerfen.
*

xhdi_rawdrvr:
 movem.l  d0/d1,-(sp)
 bsr.s    getxhdi
 beq.b    rxh_err             ; Cookie nicht gefunden
 move.l   d0,a1               ; a1 = Funktionszeiger
 movem.l  (sp)+,d0/d1
 tst.w    d0
 bne.b    rxh_err2            ; falsche Funktionsnummer
 clr.w    -(sp)               ; kein Schluessel
 move.w   #1,-(sp)            ; auswerfen
 move.l   d1,-(sp)            ; major/minor
 move.w   #5,-(sp)
 jsr      (a1)                ; XHEject
 tst.l    d0                  ; erfolgreich ?
 bge.b    rxh_ok              ; ja, Ende
 subq.w   #1,(sp)             ; XHStop
 jsr      (a1)
rxh_ok:
 adda.w   #10,sp
 rts
rxh_err:
 addq.l   #8,sp
rxh_err2:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* void DMD_rdevinit( a0 = DMD *dmd )
*
* Initialisiert die Felder <d_driver> und <d_devcode> des DMD und
* benutzt dazu das Feld <d_biosdev>
*
* Diese Funktion wird nicht vom Kernel, sondern vom XFS ausgefuehrt.
* Es wird zunaechst versucht, XHDI zu verwenden. Geht das schief, wird
* das BIOS aufgerufen (Mac !)
*

DMD_rdevinit:
;     DEB  'DMD_xhdi'
 movem.l  a5/a6,-(sp)
 move.l   a0,a5               ; DMD merken
 clr.l    d_driver(a5)        ; kein Treiber
 bsr.s    getxhdi
 beq.b    dxh_err             ; Cookie nicht gefunden
 move.l   d0,a6               ; Wert des Cookies
 clr.l    -(sp)               ; kein BPB
 clr.l    -(sp)               ; kein Startsektor
 pea      d_devcode+2(a5)     ; &minor
 pea      d_devcode(a5)       ; &major
 move.w   d_biosdev(a5),-(sp)
 move.w   #7,-(sp)
 jsr      (a6)                ; XHInqDev
 adda.w   #20,sp
 tst.l    d0
 beq.b    dxh_xhdi
 cmpi.l   #EDRVNR,d0
 bne.b    dxh_err
dxh_xhdi:
 move.l   #xhdi_rawdrvr,d_driver(a5)
 bra.b    dxh_ende
dxh_err:
 move.w   d_biosdev(a5),d0
 jsr      bios2devcode        ; => BIOS (Mac!)
 move.l   d0,d_devcode(a5)
 beq.b    dxh_ende            ; ungueltig
 move.l   #bios_rawdrvr,d_driver(a5)
dxh_ende:
 movem.l  (sp)+,a5/a6
;     DEBL d0,'DMD_xhdi => '
 rts


**********************************************************************
*
* DMD * DMD_create(d0 = int drive)
*  erstellt fuer <drive> einen DMD, falls dieser noch nicht
*  existiert.
*

DMD_create:
;     DEB  'DMD_create'
 movem.l  d7/a4/a5,-(sp)
 move.w   d0,d7
 bsr      drv_to_dmd
 move.l   a0,d0
 beq.b    dc_create
* DMD existiert bereits
 move.l   a0,a5
 move.l   d_xfs(a5),a1
 move.l   xfs_drv_open(a1),a1
 jsr      (a1)
 tst.l    d0
 bmi      dc_ende
 bra      dc_valid
dc_create:
* Speicher fuer DMD holen
 bsr      int_malloc
 movea.l  d0,a5                    ; a5 = DMD

 move.w   d7,d_drive(a5)           ; Laufwerknummer in den DMD
;clr.l    d_dfs(a5)
;clr.l    d_xfs(a5)
* DMD initialisieren
 move.l   xfs_list,a4
 bra.b    dc_nfs
dc_nloop:
 move.l   xfs_drv_open(a4),a1
 move.l   a5,a0                    ; DMD
 jsr      (a1)
 tst.l    d0
 beq      dc_valid                 ; alles OK, DMD gueltig
 move.l   xfs_next(a4),a4
dc_nfs:
 move.l   a4,d0
 bne.b    dc_nloop
* DMD kann nicht initialisiert werden
 move.l   a5,a0
 bsr      int_mfree
 moveq    #EDRIVE,d0
 bra.b    dc_ende
* neuer DMD initialisiert
dc_valid:
 lea      dmdx,a0
 add.w    d7,d7
 add.w    d7,d7
 move.l   a5,(a0,d7.w)             ; in dmdx[drv] eintragen
 move.l   a5,d0                    ; => return(DMD)
dc_ende:
 movem.l  (sp)+,a4/a5/d7
;     DEBL  d0,'DMD_create => '
 rts


**********************************************************************
**********************************************************************
*
* Dateiverwaltung, obere Ebene
*
**********************************************************************
**********************************************************************
*
* DMD *d_chkdrv(d0 = unsigned int drive, d1 = int mode)
*
*  Prueft, ob <drive> vorhanden.
*
*    mode == 0: meldet es ggf. an
*    mode == 1: gibt nur DMD bzw. NULL bzw. Fehlercode
*
*  Rueckgabe: negativ bei Fehler, sonst DMD
*

d_chkdrv:
 cmpi.w   #LASTDRIVE,d0
 bhi      chkdrv_edrive            ; Nicht im Bereich 0..LASTDRIVE

* Auf LOCK testen

 move.w   d0,a0
 add.w    a0,a0
 add.w    a0,a0
 tst.l    dlockx(a0)
 bne      chkdrv_elocked
 tst.w    d1                       ; automount ?
 beq.b    chkdrv_mount
;move.w   d0,d0
 bsr      drv_to_dmd               ; gemounteten DMD oder NULL
 move.l   a0,d0
 rts

* Existiert <drive> schon ?

chkdrv_mount:
;move.w   d0,d0
 bra      DMD_create
chkdrv_edrive:
 moveq    #EDRIVE,d0
 rts
chkdrv_elocked:
 moveq    #ELOCKED,d0
 rts



**********************************************************************
*
* long Dfree(DISKINFO *d, int drivecode)
*

D_Dfree:
 movem.l  d7/a6,-(sp)
 move.l   a0,a6
dfr_again:
 move.w   4(a6),d0                 ; d0 = drivecode

* Laufwerkcode bestimmen

 moveq    #0,d7                    ; Pfadhandle ungueltig (root)
 subq.w   #1,d0
 bcc.b    dfr_weiter

* Laufwerk ist 0, also aktuelles Laufwerk und aktueller Pfad

 movea.l  act_pd,a0
 clr.w    d0
 move.b   p_defdrv(a0),d0          ; aktuelles Laufwerk
 move.b   p_drvx(a0,d0.w),d7       ; zugehoeriger Pfad

* Pruefen, ob Laufwerk existiert

dfr_weiter:
 moveq    #0,d1                    ; automount
;move.w   d0,d0
 bsr.s    d_chkdrv
 tst.l    d0
 blt.b    dfr_ende                 ; Fehlercode woertlich weiterreichen
 tst.b    d7                       ; Pfadhandle ?
 ble.b    dfr_root                 ; root (0) oder ungueltig (-1)
* aktueller Pfad
 add.w    d7,d7
 add.w    d7,d7
 lea      pathx,a0
 move.l   0(a0,d7.w),a0            ; a0 = aktueller Pfad
 move.l   dd_dmd(a0),a2
 bra.b    dfr_go
* root
dfr_root:
 move.l   d0,a2                    ; DMD
 move.l   d_root(a2),a0            ; DD *root
* beides
dfr_go:
 move.l   d_xfs(a2),a2
 move.l   xfs_dfree(a2),a2
 move.l   (a6),a1                  ; long df[4]
 jsr      (a2)
 cmpi.l   #E_CHNG,d0
 beq      dfr_again

dfr_ende:
 movem.l  (sp)+,d7/a6
 rts


**********************************************************************
*
* DD *path_to_DD(a0 = char *pathname, a1 = char **fname,
*                d0 = int flag)
*
* DD *_path_to_DD(a0 = char *pathname, a1 = char **fname,
*                 a2 = DD *relpath, d0 = int flag, d2 = int rekurs_cnt )
*
*  Eingabeparameter:
*   path       : kompletter Pfadname
*   flag  == 0 : gib DD des Verzeichnisses zurueck, in dem die spezi-
*                fizierte Datei liegt
*         == 1 : die spezifizierte Datei ist ein Verzeichnis, gib
*                deren DD zurueck.
*  Ausgabeparameter:
*   *fname     : zeigt auf den isolierten Dateinamen
*  Rueckgabe    : d0 = DD oder Fehlercode < 0
*                d1 = TRUE, wenn Pfad fuer Laufwerk U: ist
*
* Bricht bei mehr als 4 Rekursionen mit ELOOP ab.
* Der zurueckgegebene DD ist vom XFS ge-lock-t worden, d.h. der
* Referenzzaehler ist erhoeht worden. Der DD muss wieder freigegeben
* werden, wenn er nicht mehr verwendet wird.
*
* 2.12.95:     Der Anfangs-DD wird aus Sicherheitsgruenden
*              vor dem ersten Zugriff ge-lock-t, da Standardpfade
*              nicht mehr geschuetzt werden.
*

path_to_DD:

;    DEBT a0,'path_to_DD '

 moveq    #5,d2
 suba.l   a2,a2
_path_to_DD:
 movem.l  d4/d5/d6/d7/a3/a4/a6,-(sp)
 subq.w   #1,d2
 bcs      pthdd_eloop              ; maximale Rekursionstiefe ueberschritten
 move.w   d2,d5

 move.l   a0,a3                    ; a3 = pathname
 move.l   a1,a6                    ; a6 = fname
 move.l   a2,a4                    ; a4 = DD *relpath
 move.w   d0,d7                    ; d7 = flag

* erstmal auf Geraetenamen pruefen

 cmpi.b   #':',3(a3)
 bne.b    pthdd_nodev
 lea      (a3),a1
 move.b   (a1)+,d0
 jsr      toupper
 lsl.l    #8,d0
 move.b   (a1)+,d0
 jsr      toupper
 lsl.l    #8,d0
 move.b   (a1)+,d0
 jsr      toupper
 lsl.l    #8,d0
 move.b   (a1)+,d0                 ; ist jetzt umgewandelt in long
 tst.b    (a1)
 bne.b    pthdd_nodev              ; Fehlanzeige
 exg      a0,a3
 lea      con_name_s(pc),a3
 cmpi.l   #'CON:',d0
 beq.b    pthdd_nodev
 lea      aux_name_s(pc),a3
 cmpi.l   #'AUX:',d0
 beq.b    pthdd_nodev
 lea      prn_name_s(pc),a3
 cmpi.l   #'PRN:',d0
 beq.b    pthdd_nodev
 lea      nul_name_s(pc),a3
 cmpi.l   #'NUL:',d0
 beq.b    pthdd_nodev
 exg      a0,a3

* d6 := Laufwerk, a1 := Pfad

pthdd_nodev:
 clr.w    d6                       ; Hibyte loeschen
 move.b   (a3),d0
 beq.b    startdd_actdrv           ; Nullstring -> aktuelles Laufwerk
 cmpi.b   #':',1(a3)
 bne.b    startdd_actdrv           ; keine Laufwerkangabe->aktuelles Laufwerk
 jsr      toupper
 move.b   d0,d6
 subi.b   #'A',d6
 addq.l   #2,a3                    ; Laufwerkangabe ueberspringen
 bra.b    startdd_bothdrv
startdd_actdrv:
 move.l   a4,d0                    ; relativer Pfad ?
 beq.b    startdd_pddrv            ; nein, aus PD holen

; relativer Pfad uebergeben ( wo der Symlink liegt ).
; Der Pfad enthaelt kein Laufwerk.
; Falls der Pfad mit \ beginnt,
; auf die Root des Laufwerks gehen, wo der Symlink liegt.

 move.l   dd_dmd(a4),a0
 move.w   d_drive(a0),d6
 cmpi.b   #$5c,(a3)
 bne.b    pthdd_begloop
 addq.l   #1,a3
 move.l   d_root(a0),a4
 bra.b    pthdd_begloop

; entweder: kein relativer Pfad uebergeben ( wo der Symlink liegt ), aktuelles
;              Laufwerk ermitteln.
; oder:        relativer Pfad uebergeben, aber der Pfad enthaelt ein Laufwerk.
;              dann wird dieser relative Pfad ignoriert und das Laufwerk
;              ermittelt.
;
; Falls der Pfad mit \ beginnt,
; auf die Root des Laufwerks gehen.

startdd_pddrv:
 movea.l  act_pd,a0
 move.b   p_defdrv(a0),d6
startdd_bothdrv:
 moveq    #0,d1                    ; automount
 move.w   d6,d0
 bsr      d_chkdrv                 ; nachsehen, ob Laufwerk da ist
 tst.l    d0
 bmi      pthdd_err                ; Fehler
 movea.l  d0,a0                    ; a0 = DMD *
 move.l   d_root(a0),a4            ; Root ist Defaultpfad
 cmpi.b   #$5c,(a3)+
 beq.b    pthdd_begloop            ; absoluter Pfad, beginne bei root
 subq.l   #1,a3                    ; beginne bei aktuellem Pfad

 movea.l  act_pd,a2
 clr.w    d0
 move.b   p_drvx(a2,d6.w),d0
 beq.b    pthdd_begloop            ; kein anderer Defaultpfad
 bmi      pthdd_epthnf             ; Standardpfad ungueltig
 add.w    d0,d0
 add.w    d0,d0
 lea      pathx,a2
 move.l   0(a2,d0.w),a4            ; a4 = aktueller Pfad
pthdd_begloop:
 addq.w   #1,dd_refcnt(a4)
 st       d4                       ; DD ist ge-lock-t !!

* a4 ist jetzt der aktuelle Pfad, ab dem wir suchen
* d6 ist das Laufwerk

pthdd_loop:
 move.w   d7,d0                    ; d0 = int flag
 move.l   a3,a1                    ; a1 = char *pathname
 move.l   a4,a0                    ; a0 = DD *reldir
 move.l   dd_dmd(a4),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_path2DD(a2),a2
 jsr      (a2)
 tst.b    d4                       ; war a4 ge-lock-t ?
 beq.b    pthdd_nounlock           ; nein
 move.l   a0,-(sp)
 move.l   a4,a0
 bsr      unlock_dd                ; a4 freigeben
 move.l   (sp)+,a0
pthdd_nounlock:
 tst.l    d0
 bge      pthdd_ok
 cmpi.l   #ELINK,d0
 bne      pthdd_err                ; Fehler

* Rueckgabe d0 = ELINK: Link muss vom Kernel behandelt werden

 move.l   a1,d0
 bne.b    pthdd_link               ; symbolischer Link!

* Parent eines Wurzelverzeichnisses angewaehlt

 cmpi.w   #DRIVE_U,d6
 bne      pthdd_epthnf             ; nicht Laufwerk U:
 move.l   dmdx+(4*DRIVE_U),d0      ; DMD von Laufwerk U:
 beq      pthdd_epthnf
 move.l   d1,a3                    ; Restpfad
 move.l   d0,a4
 move.l   d_root(a4),a4            ; Auf u:\ gehen
 sf       d4                       ; root braucht nicht ge-lock-t zu werden
 bra      pthdd_loop

* a1 der Pfadname eines Links
* a0 ist der Pfad, in dem der Link liegt. Dieser Pfad ist ge-lock-t
* Da die Adresse "fl",$81,"chtig" ist, muss der Pfad auf den Stack
* umkopiert werden. Der Zeiger auf den Link muss auf gerader Adresse
* liegen und enthaelt zunaechst 1 Wort fuer die Laenge inkl. EOS, diese
* Laenge muss auch gerade sein.

pthdd_link:
 move.l   d1,-(sp)                 ; Restpfad (char *) merken
 move.l   a0,a4                    ; aktuellen Pfad (DD *) merken
 move.l   sp,a3                    ; alten Stack merken
 move.w   (a1)+,d0                 ; Laenge des Links inkl. EOS und gerade
 suba.w   d0,sp
 lsr.w    #1,d0
 move.l   sp,a0
 bra.b    pthdd_linkcpy
pthdd_lcloop:
 move.w   (a1)+,(a0)+              ; Link auf den Stack kopieren
pthdd_linkcpy:
 dbra     d0,pthdd_lcloop
 move.l   sp,a0                    ; Link- Verzeichnis
 clr.l    -(sp)
 moveq    #1,d0                    ; Pfad ist Directory
 move.l   a4,a2                    ; a2 = DD *reldir
 move.l   sp,a1                    ; a1 = dummy
 move.w   d5,d2                    ; Rekursionszaehler
 bsr      _path_to_DD              ; Rekursion
 move.l   a3,sp                    ; Stack restaurieren
 move.l   (sp)+,a3                 ; Restpfad

 move.l   a4,a0                    ; Pfad, in dem der Link gesucht wurde...
 bsr      unlock_dd                ;  ...wird freigegeben

 tst.l    d0
 bmi.b    pthdd_epthnf             ; Fehler ist immer EPTHNF
 st       d4                       ; Pfad ist ge-lock-t
 move.l   d0,a4                    ; Anfangspfad (DD *)
 bra      pthdd_loop

pthdd_ok:
 move.l   d1,(a6)                  ; Restpfad ist Dateiname
pthdd_no_dd:
 tst.l    d0
 beq.b    pthdd_epthnf             ; NULL     nach EPTHNF konvertieren
pthdd_err:
 moveq    #EFILNF,d1               ; EFILNF nach EPTHNF konvertieren
 cmp.l    d0,d1
 bne.b    pthdd_end
pthdd_epthnf:
 moveq    #EPTHNF,d0
pthdd_end:
 move.w   d6,d1                    ; RUeckgabe in d1: war Laufwerk U:
 movem.l  (sp)+,a6/a4/a3/d7/d6/d5/d4

;    DEBL d0,'path_to_DD => '

 rts
pthdd_eloop:
 moveq    #ELOOP,d0                ; mehr als 4 Rekursionen!
 bra.b    pthdd_end


**********************************************************************
*
* Dsetpath(char *pathname)
*  Setzt <pathname> als aktuellen Pfad fuer das in <pathname>
*  enthaltene Laufwerk.
*

D_Dsetpath:
 movem.l  d6/d7/a3/a4/a5/a6,-(sp)
;    DEBT (a0),'Dsetpath '
 move.l   (a0),-(sp)
dsp_again:
 movea.l  act_pd,a4

* a5 := DD des Verzeichnisses

 moveq    #1,d0                         ; Pfad ist selbst ein Verzeichnis
 move.l   (sp),a0
 clr.l    -(sp)
 lea      (sp),a1
 bsr      path_to_DD
 addq.l   #4,sp
 tst.l    d0
 bmi      dsp_ende                      ; Fehler
 movea.l  d0,a5                         ; a5 := DD
 move.w   d1,d7                         ; angegebenes Laufwerk
 move.w   d7,d6                         ; Laufwerk, dessen Pfad gesetzt wird
 move.l   dd_dmd(a5),a0
 cmpi.w   #DRIVE_U,d6
 beq.b    dsp_u                         ; bei U: bleibe ich auf U:
 move.w   d_drive(a0),d6                ; sonst kann anderes Laufwerk sein!

* Feststellen, ob einfach die Root des zugehoerigen Laufwerks
* angewaehlt wurde

dsp_u:
 cmp.w    d_drive(a0),d7                ; cross drive link ?
 bne.b    dsp_noroot                    ; nein
 cmpa.l   d_root(a0),a5                 ; Wurzelverzeichnis ?
 bne.b    dsp_noroot                    ; nein
 move.l   a5,a0
 bsr      unlock_dd                     ; DD der root wieder freigeben
 suba.l   a5,a5                         ; stattdessen Defaultpfad

* a5 := DD des Pfades (oder NULL, wenn default)
* a2 := Referenzzaehler- Tabelle
* a3 := Zeiger auf Ref. zaehler des alten Pfad- Handles oder NULL

dsp_noroot:
 lea      pathcntx,a2
 suba.l   a3,a3
 move.b   p_drvx(a4,d6.w),d0            ; altes Pfadhandle
 ble.b    dsp_srchhdl                   ; ist ungueltig bzw. root
 ext.w    d0
 lea      0(a2,d0.w),a3
 add.w    d0,d0
 add.w    d0,d0
 lea      pathx,a6
 add.w    d0,a6                         ; alter Pfad

* Pruefen, ob unser DD schon Defaultpfad eines anderen
* Prozesses ist

dsp_srchhdl:
 move.l   a5,d1                    ; Defaultpfad (root) ?
 bne.b    dsp_srchnew

* Der neue DD ist die Root, also der Defaultpfad, der nun nicht mehr
* im PD vermerkt zu sein braucht!

;moveq    #0,d1                    ; neues Pfadhandle ist 0
 move.l   a3,d0
 beq.b    dsp_ok
 subq.b   #1,(a3)
 move.l   (a6),a0
 bsr      unlock_dd                ; alter Pfad, kein Register veraendert
 bra.b    dsp_ok

dsp_srchnew:
 move.l   a5,a0
 bsr      isdefault
 bmi      dsp_store                ; ja, einfach benutzen

* Freies Pfad- Handle suchen

 suba.l   a0,a0
 bsr      isdefault
 bmi      dsp_store

* Kein freies Handle gefunden, return(ENSMEM)

 moveq    #ENSMEM,d0
 bra.b    dsp_ende

* a6: Zeiger auf alten pathx- Eintrag
* a3: Zeiger auf alten pathcntx- Eintrag
* a1: Zeiger auf pathcntx- Eintrag
* a0: Zeiger auf pathx-    Eintrag
* d1: Pfadhandle
* Der DD wird in die Tabelle fuer die DDs der Pfad- Handles eingetragen
* Das Pfadhandle wird in den PD eingetragen

dsp_store:
 move.l   a3,d0
 beq.b    dsp_noold
 subq.b   #1,(a3)
 move.l   a0,a2                    ; a0 retten
 move.l   (a6),a0
 bsr      unlock_dd                ; alten Pfad freigeben
 move.l   a2,a0                    ; a0 zurueck
dsp_noold:
 addq.b   #1,(a1)
 move.l   a5,(a0)
;addq.w   #1,dd_refcnt(a5)         ; neuer Pfad (schon im XFS erledigt!)
 cmp.w    d6,d7                    ; fuer anderes Laufwerk geaendert ?
 beq.b    dsp_ok                   ; nein
 cmp.b    p_defdrv(a4),d7          ; Pfad fuer Defaultlaufwerk angegeben ?
 bne.b    dsp_ok                   ; nein !
 move.b   d6,p_defdrv(a4)          ; ja, Defaultlaufwerk aendern!
dsp_ok:
 move.b   d1,p_drvx(a4,d6.w)
 moveq    #0,d0
dsp_ende:
 cmpi.l   #E_CHNG,d0
 beq      dsp_again
 addq.l   #4,sp
 movem.l  (sp)+,d6/d7/a3/a4/a5/a6
;    DEBL d0,'Dsetpath => '
 rts


**********************************************************************
*
* void Dgetcwd(char pathbuf[], int drivecode, int buflen)
*

D_Dgetcwd:
 move.w   6(a0),d1
 bra.b    _dgp


**********************************************************************
*
* void Dgetpath(char pathbuf[], int drivecode)
*

D_Dgetpath:
 move.w   #128,d1                  ; Pufferlaenge
_dgp:
 move.w   4(a0),d0
 move.l   (a0),a0


**********************************************************************
*
* LONG Dgetcwd(a0 = char *pathbuf, d0 = int drivecode, d1 = int buflen)
*
* 2.12.95:     EPTHNF, wenn Standardlaufwerk ungueltig
*

Dgetcwd:
 movem.l  a5/d6/d7,-(sp)
 move.l   a0,a5                    ; a5 := pathbuf
 move.w   d0,d6                    ; d6 := drivecode
 move.w   d1,d7                    ; d7 := len
dgp_again:
;    DEBL  d0,'Dgetcwd '
 move.w   d6,d0
 subq.w   #1,d0                    ; drivecode
 bcc.b    dgp_drv                  ; angegebenes Laufwerk verwenden
 movea.l  act_pd,a0
 clr.w    d0
 move.b   p_defdrv(a0),d0          ; aktuelles Laufwerk verwenden
dgp_drv:
 moveq    #0,d1                    ; automount
;move.w   d0,d0
 bsr      d_chkdrv                 ; Laufwerk ueberpruefen
 clr.b    (a5)                     ; per Default loeschen
 tst.l    d0
 bmi.b    dgp_ende                 ; Fehlercode woertlich weiterreichen
* bisher alles gut gegangen
 move.l   d0,a2                    ; a2 = DMD
 move.l   d_root(a2),a0            ; Default-DD: root
 movea.l  act_pd,a1
 adda.w   d_drive(a2),a1
 moveq    #0,d1
 move.b   p_drvx(a1),d1            ; Pfadhandle holen
 beq.b    dgp_root
 bmi.b    dgp_epthnf               ; Standardpfad ungueltig!
 add.w    d1,d1
 add.w    d1,d1
 lea      pathx,a1
 move.l   0(a1,d1.w),a0            ; DD holen
dgp_root:
 cmpi.w   #DRIVE_U,d_drive(a2)     ; Pseudolaufwerk ?
 bne.b    dgp_ok                   ; nein
 move.l   dd_dmd(a0),a1
 cmpi.w   #DRIVE_U,d_drive(a1)     ; Pfad auch Pseudolaufwerk ?
 beq.b    dgp_ok                   ; ja

; "U:\<laufwerk>" + "<pfad>"

 move.l   a0,-(sp)                 ; DD merken
 move.l   a5,a0                    ; Ziel (Puffer)
 move.b   #$5c,(a0)+               ; wichtig!
 move.w   d_drive(a1),d0
 jsr      get_u_lnk

 move.l   a5,d1
 move.l   d0,a5
 sub.l    d1,d0                    ; Laenge des Pfad-Anfangs
 sub.w    d0,d7
 move.l   (sp)+,a0                 ; DD zurueck
/*
 moveq    #'A',d1
 add.w    d_drive(a1),d1
 move.b   #$5c,(a5)+
 move.b   d1,(a5)+
 clr.b    (a5)
*/
dgp_ok:
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_DD2name(a2),a2
;move.l   a0,a0                    ; a0 = DD *
 move.l   a5,a1                    ; a1 = char *buf
 move.w   d7,d0                    ; Pufferlaenge
 jsr      (a2)
dgp_ende:
 cmpi.l   #E_CHNG,d0
 beq      dgp_again
 movem.l  (sp)+,a5/d7/d6
 rts
dgp_epthnf:
 moveq    #EPTHNF,d0
 bra.b    dgp_ende


**********************************************************************
*
* LONG pathcmpl(a0 = char *outpath, a1 = char *inpath, d0 = int buflen)
*
* macht aus einem relativen einen absoluten Pfad.
*

pathcmpl:
 movem.l  a6/a5/d7,-(sp)
 move.l   a0,a6               ; a6 = outpath
 move.l   a1,a5               ; a5 = inpath
 move.w   d0,d7
 subq.w   #2,d7               ; Laufwerk und Doppelpunkt
 bcs.b    pcpl_erange
 moveq    #':',d1
 tst.b    (a5)
 beq.b    pcpl_drv
 cmp.b    1(a5),d1
 bne.b    pcpl_drv
 move.b   (a5)+,d0
 jsr      toupper
 move.b   d0,(a6)+
 move.b   (a5)+,(a6)+
 bra.b    pcpl_nxt
pcpl_drv:
 move.l   act_pd,a0
 moveq    #'A',d0
 add.b    p_defdrv(a0),d0
 move.b   d0,(a6)+
 move.b   d1,(a6)+
pcpl_nxt:
 cmpi.b   #$5c,(a5)
 beq.b    pcpl_defpath
 move.w   d7,d1               ; buflen
 subi.w   #'A'-1,d0           ; drivecode (1 = A, ...)
 move.l   a6,a0               ; pathbuf
 clr.b    (a0)                ; zur Sicherheit
 bsr      Dgetcwd
 tst.l    d0
 bmi.b    pcpl_ende           ; Fehler
pcpl_loop1:
 tst.b    (a6)
 beq.b    pcpl_next2
 addq.l   #1,a6
 subq.w   #1,d7
 ble.b    pcpl_erange         ; kann eigentlich nicht sein
 bra.b    pcpl_loop1
pcpl_next2:
 cmpi.b   #$5c,-1(a6)
 beq.b    pcpl_defpath
 move.b   #$5c,(a6)+
 clr.b    (a6)
pcpl_defpath:
 move.l   a5,a0
 bsr      strlen
 addq.l   #1,d0               ; EOS
 sub.w    d0,d7
 bcs.b    pcpl_erange
pcpl_loop2:
 move.b   (a5)+,(a6)+
 bne.b    pcpl_loop2
 moveq    #E_OK,d0
 bra.b    pcpl_ende
pcpl_erange:
 moveq    #ERANGE,d0
pcpl_ende:
 movem.l  (sp)+,a6/a5/d7
 rts


**********************************************************************
*
* long isdefault(a0 = DD *dd)
*
* Prueft, ob <dd> ein Standardpfad fuer irgendein Laufwerk ist.
* Bei <dd> == NULL wird ein freies Pfadhandle gesucht.
* Rueckgabe EACCDN, wenn ja
*   (a0 = pathx- Eintrag, a1 = Pfadhandle- Eintrag, d1 = Pfadhandle)
* sonst 0L
* Das Z und N- Flag ist dann entsprechend gesetzt.
*

isdefault:
 move.l   a0,d0                    ; dd
 lea      pathx+4,a0
 lea      pathcntx+1,a1
 moveq    #1,d1
isdef_loop:
 tst.b    (a1)
 bne.b    isdef_tst                ; Standardpfad benutzt
 tst.l    d0                       ; sollte unbenutztes Handle suchen ?
 beq.b    isdef_is                 ; unbenutztes Handle gefunden
 bra.b    isdef_nxtpath
isdef_tst:
 cmp.l    (a0),d0
 beq.b    isdef_is                 ; return(EACCDN)
isdef_nxtpath:
 addq.l   #1,a1
 addq.l   #4,a0
 addq.w   #1,d1
 cmpi.w   #N_STDPATHS,d1
 bcs.b    isdef_loop
 moveq    #0,d0
 rts
isdef_is:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long Fsnext()
*

Fsnext:
     DEB  'Fsnext'
 movea.l  act_pd,a0
 movea.l  p_dta(a0),a0             ; a0 = DTA
 moveq    #0,d0
 move.b   dta_drive(a0),d0
 cmpi.w   #LASTDRIVE,d0
 bhi.b    fsn_enmfil               ; von Drdlabel
 move.l   a0,-(sp)
 bsr      drv_to_dmd
 move.l   d_xfs(a0),a2
 move.l   xfs_snext(a2),a2
 move.l   a0,a1                    ; a1 = DMD *
 move.l   (sp),a0                  ; a0 = DTA *
 jsr      (a2)
 move.l   (sp)+,a1
 cmpi.l   #ELINK,d0
 beq.b    sfirst_symlink
fsn_ok:
 rts
fsn_enmfil:
 moveq    #ENMFIL,d0
 rts


**********************************************************************
*
* long sfirst_symlink(a0 = char *link, a1 = DTA *dta)
*

sfirst_symlink:
 movem.l  a6/a5,-(sp)
 move.l   sp,a6                    ; sp merken
 move.l   a1,a5                    ; a5 = DTA
 move.w   (a0)+,d0                 ; Laenge des Links inkl. EOS und gerade
 suba.w   d0,sp
 lsr.w    #1,d0
 move.l   sp,a2
 bra.b    sfs_linkcpy
sfs_lcloop:
 move.w   (a0)+,(a2)+              ; Link auf den Stack kopieren
sfs_linkcpy:
 dbra     d0,sfs_lcloop
 move.l   sp,a0                    ; Link
 suba.w   #xattr_sizeof,sp
 move.l   sp,-(sp)                 ; XATTR *
 move.l   a0,-(sp)                 ; char *path
 clr.w    -(sp)                    ; int mode
 move.l   sp,a0
 bsr      D_Fxattr
 adda.w   #10,sp
 tst.l    d0                       ; Fehler ?
 bmi.b    sfs_ok                   ; ja, Link nicht verfolgen
 move.b   xattr_attr+1(sp),dta_attr(a5)
 move.l   xattr_mtime(sp),dta_time(a5)
;move.w   xattr_mdate(sp),dta_date(a5)
 move.l   xattr_size(sp),dta_len(a5)
sfs_ok:
 moveq    #0,d0
sfs_ende:
 move.l   a6,sp
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* long Fpipe( int handles[2] )
*
* Erstellt eine unidirektionale Pipe und oeffnet sie zweimal, und zwar
* zum Lesen in handles[0] und zum Schreiben in handles[1].
* Als Name wird "sys$pipe.xxx" verwendet.
*

D_Fpipe:
 move.l   a5,-(sp)
 move.l   (a0),a5
 clr.w    -(sp)                         ; EOS
 move.l   #'.000',-(sp)                 ; "000\0"
 move.l   #'pipe',-(sp)
 move.l   #'sys$',-(sp)
 move.l   #$6970655c,-(sp)
 move.l   #$753a5c70,-(sp)
fpip_loop:
 moveq    #1,d1                         ; Attribut: Bit 0 = unipipe
 move.w   #O_CREAT+O_WRONLY+O_DENYW+O_EXCL,d0     ; nur neue Dateien erstellen
 move.l   sp,a0
 bsr      _Fopen
 tst.l    d0
 bge.b    fpip_ok
 cmpi.l   #EACCDN,d0
 bne.b    fpip_ende                     ; schwerer Fehler!
 lea      19(sp),a1
 addq.b   #1,(a1)                       ; Einerstellen des Namens
 cmpi.b   #'9',(a1)
 bls.b    fpip_loop
 move.b   #'0',(a1)
 addq.b   #1,-(a1)                      ; 10erstellen des Namens
 cmpi.b   #'9',(a1)
 bls.b    fpip_loop
 move.b   #'0',(a1)
 addq.b   #1,-(a1)                      ; 100erstellen des Namens
 cmpi.b   #'9',(a1)
 bls.b    fpip_loop
 bra.b    fpip_ende
fpip_ok:
 move.w   d0,2(a5)
 move.w   #O_RDONLY+O_DENYR,d0
 move.l   sp,a0
 bsr      _Fopen
 tst.l    d0
 bge.b    fpip_ok2
 move.l   d0,-(sp)                      ; Fehlercode merken
 move.w   2(a5),d0
 bsr      Fclose                        ; erstes Handle wieder schliessen
 move.l   (sp)+,d0
 bra.b    fpip_ende
fpip_ok2:
 move.w   d0,(a5)
 moveq    #0,d0
fpip_ende:
 adda.w   #22,sp
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long Fcreate(a0 = char *pathname, d0 = unsigned char attr)
*

D_Fcreate:
 move.w   4(a0),d0
 move.l   (a0),a0
Fcreate:
 btst     #3,d0                    ; will Volume erstellen
 bne.b    fcre_wrlabel
 btst     #4,d0                    ; will Subdir erstellen
 bne.b    fcre_ebadrq
 andi.w   #FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE,d0
 move.w   d0,d1
 move.w   #O_CREAT+O_RDWR+O_TRUNC,d0
 bra      _Fopen
fcre_wrlabel:
 bsr      Dwrlabel
 tst.l    d0
 bmi.b    fcre_ok
 move.l   #$0000fffc,d0            ; Handle fuer NUL: zurueckgeben
fcre_ok:
 rts
fcre_ebadrq:
 moveq    #EBADRQ,d0
 rts


**********************************************************************
*
* int mintmode2omode(d0 = int omode)
*
* Rechnet einen MiNT- Openmodus in die interne Mag!X- Konvention um.
* Eine Vertraeglichkeit zwischen Modus d0 und Modus d1 wird
* folgendermassen getestet:
*
*    ror.b #4,d0
*    and.b d0,d1
*    bne   eaccdn
*

rwmodes_tab:
 DC.B     OM_RPERM            ; RDONLY: Erlaubnis, zu lesen
 DC.B     OM_WPERM            ; WRONLY: Erlaubnis, zu schreiben
 DC.B     OM_RPERM+OM_WPERM   ; RDWR  : Lesen und schreiben
 DC.B     OM_RPERM+OM_EXEC    ; EXEC  : Lesen und ausfuehren (->XFS)
shmodes_tab:
 DC.B     OM_WDENY            ; COMPAT
 DC.B     OM_RDENY+OM_WDENY   ; DENYRW
 DC.B     OM_WDENY            ; DENYW
 DC.B     OM_RDENY            ; DENYR
 DC.B     0                   ; DENYNONE
 DC.B     0                   ; Fehler ?
 DC.B     0                   ; Fehler ?
 DC.B     0                   ; Fehler ?

mintmode2omode:
 move.w   d0,d2
 bne.b    m2o_ok
 moveq    #OM_RPERM,d0             ; Sonderfall RDONLY+COMPAT: alles erlauben
 rts
m2o_ok:
 andi.b   #O_APPEND+O_NOINHERIT,d0      ; Hibyte, O_APPEND und O_NOINHERIT
                                        ; uebernehmen
 move.w   d2,d1
 andi.w   #O_RWMODE,d1
 or.b     rwmodes_tab(pc,d1.w),d0
 andi.w   #O_SHMODE,d2
 lsr.w    #4,d2
 or.b     shmodes_tab(pc,d2.w),d0
 rts

**********************************************************************
*
* long Fopen(a0 = char *pathname, d0 = int omode)
*
* Datei suchen, Oeffnen, ggf. symbolischen Link verfolgen.
*
**********************************************************************
*
* long _Fopen(a0 = char *pathname, d0 = int omode, d1 = int attrib)
*

D_Fopen:
 move.w   4(a0),d0
 move.l   (a0),a0
Fopen:
     DEBT a0,'Fopen '
 moveq    #0,d1
_Fopen:
 movem.l  d3/d5/d6/d7/a3/a4/a6,-(sp)
 suba.w   #256,sp
 move.l   a0,a3                    ; a3 = pathname
 move.w   d1,d6                    ; d6 = attrib
;move.w   d0,d0                    ; MiNT- omode
 bsr.s      mintmode2omode
 move.w   d0,d7                    ; d7 = omode

 bsr      new_hdl
 bmi      fop_ende                 ; kein Handle frei

 move.w   d0,d5                    ; d5 = Handle
 move.l   a0,a6                    ; a6 = act_pd->procdata.handle+Handle

* Wegen MT-fest: Handle hier bereits reservieren

 move.l   dev_fds,(a6)             ; Handle (NUL:) einsetzen

fop_tagain:
 suba.l   a4,a4                    ; kein aktuelles Verzeichnis
 moveq    #7,d3                    ; Zaehler fuer Links

fop_again:

* Der DD des Pfades wird ermittelt

 subq.l   #4,sp
 moveq    #0,d0
 lea      (sp),a1
 move.l   a3,a0
 moveq    #5,d2                    ; Zaehler fuer Rekursion
 move.l   a4,a2                    ; reldir
 bsr      _path_to_DD
 move.l   (sp)+,a1

 move.l   a4,d2                    ; war reldir ?
 beq.b    fop_nounlock
 move.l   a0,-(sp)
 move.l   a4,a0
 bsr      unlock_dd                ; Pfad, in dem DD gesucht wurde, freigeben
 move.l   (sp)+,a0
fop_nounlock:

 tst.l    d0
 bmi      fop_err
 move.l   d0,a0
 move.l   a0,a4

* Die Datei wird ueber den Dateisystemtreiber geoeffnet

 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_fopen(a2),a2
 move.w   d7,d0                    ; d0 = omode
;move.l   a1,a1                    ; a1 = name
;move.l   a0,a0                    ; a0 = DD
 move.w   d6,d1                    ; d1 = attrib nur bei (omode & O_CREAT)
 jsr      (a2)

 tst.l    d0                       ; FD gueltig ?
 bge      fop_ok                   ; ja !
 cmpi.l   #ELINK,d0                ; symbolischer Link ?
 bne.b    fop_ferr                 ; nein, Fehler

; symbolischer Link

 move.w   (a0)+,d0
 beq.b    fop_eloop                ; Link ungueltig
 cmpi.w   #256,d0
 bhi.b    fop_eloop                ; Link zu lang
 move.l   sp,a1
 lsr.w    #1,d0
 bra.b    fop_endl
fop_lo:
 move.w   (a0)+,(a1)+
fop_endl:
 dbra     d0,fop_lo
 move.l   sp,a3
 dbra     d3,fop_again             ; Anzahl Links mitzaehlen!

fop_eloop:
 moveq    #ELOOP,d0
 bra.b    fop_err

* Rueckgabe ist ein gueltiger FD, Datei ist geoeffnet, d.h. der
* Dateitreiber ist schon geoeffnet

fop_ok:
 move.l   a4,a0
 bsr      unlock_dd                ; Pfad freigeben

 move.l   d0,(a6)                  ; FD in die Handle-Tabelle eintragen
 moveq    #0,d0
 move.w   d5,d0                    ; Handle auf unsigned long

fop_ende:
 adda.w   #256,sp
 movem.l  (sp)+,a6/a4/a3/d7/d6/d5/d3
     DEBL d0,'Fopen => '
 rts
fop_ferr:
 move.l   a4,a0
 bsr      cond_unlock_dd           ; Pfad freigeben
fop_err:
 cmpi.l   #E_CHNG,d0
 beq      fop_tagain
 clr.l    (a6)                     ; Handle wieder freigeben
 bra.b    fop_ende


**********************************************************************
*
* long Fxattr( int mode, char *path, XATTR *xattr )
*
* flag == 0:   Folge symbolischen Links
*         1:   Folge nicht
*

D_Fxattr:
 moveq    #xfs_xattr,d2
 move.w   (a0)+,d1                 ; d1 = mode
 move.l   4(a0),d0                 ; d0 = XATTR *
 bra      _df3


**********************************************************************
*
* long Fsymlink( char *oldname, char *newname )
*

D_Fsymlink:
 move.w   #xfs_symlink,d2
 move.l   (a0)+,d0                 ; Wert des Links
 bra      _df3


**********************************************************************
*
* long Freadlink( int bufsiz, char *buf, char *name )
*

D_Freadlink:
 move.w   #xfs_readlink,d2
 move.w   (a0)+,d1                 ; par2 = buflen
 move.l   (a0)+,d0                 ; par1 = buf
 bra      _df3


**********************************************************************
*
* long Dcntl( d0 = int mode, a0 = char *name, a1 = void *info )
*
* mode =  DEV_INSTALL    0xde02    (Mag!X nimmt DEV_M_INSTALL)
*         DEV_NEWBIOS    0xde01    (nicht unterstuetzt)
*         DEV_NEWTTY     0xde00    (nicht unterstuetzt)
*         PROC_CREATE    0xcc00    (Mag!X 2.10)
*         DEV_M_INSTALL  0xcd00    (Mag!X 2.10)
*
*         KER_GETINFO    0x0100    (Kernel- Info)
*         KER_DOSLIMITS  0x0101    (DOSLIMITS erfragen)
*                                  ab 11.6.95
*         KER_DRVSTAT    0x0104    ab 9.9.95
*         KER_XFSNAME    0x0105    ab 15.6.96
*         KER_INSTXFS    0x0200    (installiere ein XFS)
*
*         CDROMEJECT     0x4309    Medium auswerfen
*
*    ab 2.12. abgeschafft:
*         KER_INTMAVAIL  0x0102    (internen Speicher ermitteln)
*         KER_INTGARBC   0x0103    garbage collection
*         KER_SETWBACK   0x0300    konfiguriere writeback
*

D_Dcntl:
 move.w   (a0)+,d0
 move.l   4(a0),a1
 move.l   (a0),a0
Dcntl:

;    DEBT a0,'Dcntl '

 cmpi.w   #MX_KER_GETINFO,d0       ; MagiC 6
 beq.b    dcntl_kerinfo
 cmpi.w   #MX_KER_DOSLIMITS,d0     ; MagiC 6
 beq      dcntl_doslimits
 cmpi.w   #MX_KER_DRVSTAT,d0       ; MagiC 6
 beq      dcntl_drvstat
 cmpi.w   #MX_KER_XFSNAME,d0       ; MagiC 6
 beq      dcntl_xfsname
 cmpi.w   #MX_KER_INSTXFS,d0       ; MagiC 6
 beq.b    dcntl_instxfs

 cmpi.w   #KER_GETINFO,d0
 beq.b    dcntl_kerinfo
 cmpi.w   #KER_INSTXFS,d0
 beq.b    dcntl_instxfs
 cmpi.w   #KER_DOSLIMITS,d0
 beq.b    dcntl_doslimits
 cmpi.w   #KER_DRVSTAT,d0
 beq.b    dcntl_drvstat
 cmpi.w   #CDROMEJECT,d0
 beq      dcntl_eject
 cmpi.w   #KER_XFSNAME,d0
 beq.b    dcntl_xfsname
 move.w   #xfs_dcntl,d2
 move.l   a1,d1                    ; par2 = info
;move.w   d0,d0                    ; par1 = mode
;move.l   a0,a0                    ; char *path
 bra      Fxfunct
dcntl_kerinfo:
 move.l   #kernel,d0

;    DEBL d0,'Dcntl => '

 rts
dcntl_doslimits:
 move.l   #p_doslimits,d0
 rts
dcntl_instxfs:
 move.l   xfs_list,xfs_next(a1)    ; XFS einbinden
 move.l   a1,xfs_list
 bra.b    dcntl_kerinfo

*
* Unterfunktion: Status eines Laufwerks (0..25)
*

dcntl_drvstat:
 moveq    #EINVFN,d0
 move.w   (a1)+,d0                 ; Unterfunktion 0 ?
 bne.b    dcnds_ende               ; nein, unbekannt
 move.w   (a1),d0                  ; Laufwerknummer (0..25)
 moveq    #1,d1                    ; kein automount
 bsr      d_chkdrv                 ; DMD ermitteln bzw. NULL bzw. Fehler
dcnds_ende:
 rts

*
* Unterfunktion: Fuer einen Pfad den Namen des XFS ermitteln
*

dcntl_xfsname:
 move.l   a1,-(sp)                 ; a1 retten
 moveq    #1,d0                    ; DD holen
 clr.l    -(sp)
 lea      (sp),a1                  ; &fname (dummy)
;move.l   a0,a0                    ; Pfad
 bsr      path_to_DD
 addq.l   #4,sp
 move.l   (sp)+,a1                 ; a1 zurueck
 tst.l    d0
 ble.b    xfsnam_ende              ; Fehler
 move.l   d0,a0
 move.l   dd_dmd(a0),a2
 move.l   a2,d0                    ; DMD merken
 move.l   d_xfs(a2),a2
 move.l   (a2)+,(a1)+              ; Name (8 Zeichen) kopieren
 move.l   (a2),(a1)+
 clr.b    (a1)
;move.l   a0,a0
 bsr      unlock_dd                ; DD freigeben, aendert nicht d0
xfsnam_ende:
 rts

*
* Unterfunktion: Medium auswerfen
*

dcntl_eject:
 moveq    #1,d0                    ; DD holen
 clr.l    -(sp)
 lea      (sp),a1                  ; &fname (dummy)
;move.l   a0,a0                    ; Pfad
 bsr      path_to_DD
 addq.l   #4,sp
 tst.l    d0
 ble.b    eject_ende               ; Fehler
 move.l   d0,a0
 move.l   dd_dmd(a0),-(sp)         ; DMD merken
 bsr      unlock_dd                ; DD freigeben
 move.l   (sp),a0                  ; a0 ist jetzt der DMD
 bsr      Sunmount                 ; alle zugehoerigen Dateisysteme unmount
 tst.l    d0
 bne.b    eject_err                ; Fehler beim unmount
 move.l   (sp),a0
 move.l   d_driver(a0),d0          ; Treiber ?
 beq.b    eject_err                ; keiner da, nix tun
 move.l   d0,a1
 move.l   d_devcode(a0),d1         ; devcode
 moveq    #0,d0                    ; Subfn: 0 (eject)
 jsr      (a1)
eject_err:
 addq.l   #4,sp
eject_ende:
 rts


deflt_doslimits:
 DC.W     0         ; Versionsnummer der Struktur
 DC.W     26        ; maximale Zahl der DOS- Laufwerke
 DC.L     32768     ; maximale Sektorgroesse auf BIOS- Ebene
 DC.W     1         ; minimale Anzahl von FATs
 DC.W     2         ; maximale Anzahl von FATs
 DC.L     1         ; Sektoren/Cluster minimal
 DC.L     32768     ; Sektoren/Cluster maximal
 DC.L     65518     ; maximale Clusterzahl ($0002..$ffef)
 DC.L     4193216   ; maximale Zahl von Sektoren

kernel:
 DC.W     $0004                    ; Versionsnummer
 DC.L     fast_clrmem
 DC.L     toupper
 DC.L     _sprintf
 DC.L     act_pd
 DC.L     act_appl
 DC.L     keyb_app
 DC.L     pe_slice
 DC.L     pe_timer
 DC.L     appl_yield
 DC.L     appl_suspend
 DC.L     appl_begcritic
 DC.L     appl_endcritic
 DC.L     evnt_IO
 DC.L     evnt_mIO
 DC.L     evnt_emIO
 DC.L     appl_IOcomplete
 DC.L     evnt_sem
 DC.L     Pfree
 DC.W     FDSIZE              ; Laenge eines internen Speicherblocks
 DC.L     int_malloc
 DC.L     int_mfree
 DC.L     resv_intmem
 DC.L     diskchange
 DC.L     DMD_rdevinit        ; ab 3.6.95
 DC.L     proc_info           ; ab 14.11.95
 DC.L     ker_mxalloc         ; ab 15.6.96
 DC.L     ker_mfree           ; ab 15.6.96
 DC.L     ker_mshrink         ; ab 15.6.96


**********************************************************************
*
* long D_Fsfirst(char *path, int sattr)
* long Fsfirst( a0 = char *path, a1 = DTA *dta, d0 = int attrib)
*

D_Fsfirst:
 movea.l  act_pd,a1
 move.l   p_dta(a1),a1             ; a1 = DTA *
 move.w   4(a0),d0                 ; d0 = sattr
 move.l   (a0),a0                  ; a0 = path
 cmpi.b   #8,d0                    ; will Volume lesen
 beq.b    fsf_rdlabel
Fsfirst:
 moveq    #xfs_sfirst,d2
 move.w   d0,d1                    ; par2
 move.l   a1,d0                    ; par1
 bra      Fxfunct

fsf_rdlabel:
; Label per sfirst lesen. Datum/Uhrzeit ist leider nicht lesbar.
 lea      dta_drive(a1),a1
 move.b   #-1,(a1)+                ; dta_drive
 move.b   #8,(a1)+                 ; dta_attr
 clr.l    (a1)+                    ; dta_time,dta_date (schade...)
 clr.l    (a1)+                    ; dta_len
 clr.b    (a1)                     ; Namen auf "" initialisieren
 moveq    #32,d1                   ; par2 (Pufferlaenge)
 sub.w    d1,sp                    ; Puffer 32 Zeichen
 move.l   sp,d0                    ; par1 (Puffer)
 move.l   a1,-(sp)                 ; DTA-Namenspuffer merken
;move.l   a0,a0                    ; Pfad
 moveq    #xfs_rlabel,d2
 bsr.b    Fxfunct
 move.l   (sp)+,a1                 ; Puffer zurueck
 tst.l    d0
 bne.b    fsfrdl_ende              ; Fehler
 move.l   sp,a0
 moveq    #9-1,d1                  ; 8 Zeichen und '.'
fsrdl_loop:
 move.b   (a0)+,(a1)+
 beq.b    fsfrdl_ende
 cmpi.b   #'.',-1(a1)
 beq.b    fsrdl_p
 dbra     d1,fsrdl_loop
 subq.l   #1,a1
 bra.b    fsfrdl_ende2
fsrdl_p:
 moveq    #3-1,d1
fsrdl_loop2:
 cmpi.b   #'.',(a0)
 beq.b    fsfrdl_ende2
 move.b   (a0)+,(a1)+
 dbeq     d1,fsrdl_loop2
fsfrdl_ende2:
 clr.b    (a1)                     ; ... und mit EOS abschliessen
fsfrdl_ende:
 adda.w   #32,sp
 rts


**********************************************************************
*
* long Dwrlabel(a0 = char *path)
*

Dwrlabel:
 moveq    #xfs_wlabel,d2
 bra.b    Fxfunct


**********************************************************************
*
* long Fdelete(char pathname[])
*

D_Fdelete:
 moveq    #xfs_fdelete,d2
 bra      _df3


**********************************************************************
*
* long Dcreate(char path[])
*

D_Dcreate:
 moveq    #xfs_dcreate,d2
 bra.b    _df3


**********************************************************************
*
* long Fchown(char pathname[], int uid, int gid)
*

D_Fchown:
 moveq    #xfs_chown,d2
 bra.b    _df


**********************************************************************
*
* long Fchmod(char pathname[], int mode)
*

D_Fchmod:
 moveq    #xfs_chmod,d2
 bra.b    _df2


**********************************************************************
*
* long Fattrib(char pathname[], int wrt, char attrib)
*

D_Fattrib:
 moveq    #xfs_attrib,d2
_df:
 move.w   6(a0),d1
_df2:
 move.w   4(a0),d0
_df3:
 move.l   (a0),a0


**********************************************************************
*
* long Fxfunct( a0 = char pathname[],
*               d0 = long par1, d1 = long par2, d2 = int function )
*
* Fuehrt eine Funktion des Dateisystemtreibers aus. Verwendet fuer:
*
* Fsfirst
* Dcntl
* Freadlink
* Fsymlink
* Fxattr
* Fdelete
* Fattrib
* Fchown
* Fchmod
* Dcreate
* Drdlabel
* Dwrlabel
*

Fxfunct:
 movem.l  d3/d5/d6/d7/a3/a4,-(sp)
 suba.w   #256,sp
 move.l   d0,d7                    ; d7 = par1
 move.l   d1,d6                    ; d6 = par2
 move.w   d2,d3                    ; d3 = Funktion
 move.l   a0,a3                    ; a3 = pathname

fxf_tagain:
 moveq    #7,d5                    ; Zaehler fuer Links
 suba.l   a4,a4                    ; relatives ist Defaultverzeichnis

* Der DD des Pfades wird ermittelt

fxf_again:
 subq.l   #4,sp
 moveq    #0,d0
 lea      (sp),a1
 move.l   a3,a0
 moveq    #5,d2                    ; Zaehler fuer Rekursion
 move.l   a4,a2
 bsr      _path_to_DD
 move.l   (sp)+,a1

 move.l   a4,d2                    ; war reldir ?
 beq.b    fxf_nounlock
 move.l   a0,-(sp)
 move.l   a4,a0
 bsr      unlock_dd                ; Pfad, in dem DD gesucht wurde, freigeben
 move.l   (sp)+,a0
fxf_nounlock:

 tst.l    d0
 bmi      fxf_ende2
 move.l   d0,a4

* Der Dateisystemtreiber wird mit Pfad und Restname aufgerufen

 move.l   a4,a0
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   (a2,d3.w),a2             ; Funktion auswaehlen
 move.l   d6,d1                    ; Parameter #2
 move.l   d7,d0                    ; Parameter #1
;move.l   a1,a1                    ; a1 = name
;move.l   a0,a0                    ; a0 = DD
 jsr      (a2)
 cmpi.l   #ELINK,d0
 bne.b    fxf_ende
; symbolischer Link
 cmpi.w   #xfs_sfirst,d3
 bne.b    fxf_nosf
; Sonderbehandlung fuer Fsfirst
 move.l   d7,a1                    ; a1 = DTA *d
;move.l   a0,a0                    ; a0 = char *link
 bsr      sfirst_symlink
 bra      fxf_ende
fxf_nosf:
 move.w   (a0)+,d0
 cmpi.w   #256,d0
 bhi.b    fxf_eloop                ; Link zu lang
 move.l   sp,a1
 lsr.w    #1,d0
 bra.b    fxf_endl
fxf_lo:
 move.w   (a0)+,(a1)+
fxf_endl:
 dbra     d0,fxf_lo
 move.l   sp,a3
 dbra     d5,fxf_again             ; Anzahl Links mitzaehlen!

fxf_eloop:
 moveq    #ELOOP,d0
fxf_ende:
 move.l   a4,a0
 bsr      cond_unlock_dd           ; Pfad, in dem DD gesucht wurde, freigeben

fxf_ende2:
 cmpi.l   #E_CHNG,d0
 beq      fxf_tagain
 adda.w   #256,sp
 movem.l  (sp)+,d3/d5/d6/d7/a3/a4
 rts


**********************************************************************
*
* long Dreadlabel( char *dir, char *buf, int len )
*

D_Dreadlabel:
 move.w   8(a0),a2
 move.l   4(a0),d0
 moveq    #xfs_rlabel,d2
 suba.l   a1,a1                    ; a1 = NULL dem XFS uebergeben
 moveq    #0,d1                    ; aktuelle Verzeichnisse ignorieren
 bra      _dx


**********************************************************************
*
* long Dwritelabel( char *dir, char *name )
*

D_Dwritelabel:
 move.l   4(a0),a1
 moveq    #xfs_wlabel,d2
 moveq    #0,d1                    ; aktuelle Verzeichnisse ignorieren
 bra      _dx


**********************************************************************
*
* Dclosedir( long dirhandle )
*

D_Dclosedir:
 moveq    #xfs_dclosedir,d2
 bra.b    _dd


**********************************************************************
*
* Drewinddir( long dirhandle )
*

D_Drewinddir:
 moveq    #xfs_drewinddir,d2
 bra.b    _dd


**********************************************************************
*
* Dreaddir(int len, long dirhandle, char *buf)
*

D_Dreaddir:
 moveq    #0,d1               ; d1 = NULL (Dreaddir, nicht D_x_readdir)
 move.l   6(a0),a1            ; a1 = char *buf
 move.w   (a0)+,d0            ; d0 = int len
 moveq    #xfs_dreaddir,d2
_dd:
 move.l   (a0),a0
 move.l   dhd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   0(a2,d2.w),a2
 jmp      (a2)


**********************************************************************
*
* Dxreaddir(int len, long dirhandle, char *buf, XATTR *xattr, long *xr)
*
* Beim Fxattr werden Symlinks nicht verfolgt.
* <xr> enthaelt nach dem Aufruf den Fehlercode von Fxattr.
*

D_Dxreaddir:
 move.l   a0,a2
 move.w   (a2)+,d0            ; d0 = int len
 move.l   (a2)+,a0            ; a0 = FD *dirhandle
 move.l   (a2)+,a1            ; a1 = char *buf
 move.l   (a2)+,d1            ; d1 = XATTR *xattr
 move.l   (a2),d2             ; d2 = long *xr
 move.l   dhd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_dreaddir(a2),a2
 jmp      (a2)


**********************************************************************
*
* Dpathconf(char *path, int which)
*

D_Dpathconf:
 move.l   a0,-(sp)                 ; Zeiger auf Argumente retten
 moveq    #xfs_dpathconf,d2
 bsr      _dx2                     ; 1. Versuch: <path> ist Directory
 move.l   (sp)+,a0
 moveq    #xfs_dpathconf,d2
 cmpi.l   #EPTHNF,d0               ; 1. Versuch gescheitert ?
 beq      _df2                     ; ja, Versuch mit Datei!
dptc_ende:
 rts


**********************************************************************
*
* Ddelete(char *path)
*
* 2.12.95:
*    Hier wird jetzt etwas mehr Aufwand getrieben.
*    Zunaechst muss ein abschliessender backslash entfernt werden.
*    Dann wird mit Fxattr ermittelt, ob es nicht ein
*    Symlink ist, und dieser wird ggf. per Fdelete()
*    entfernt.
*    Ansonsten wird der DD des Pfades bestimmt und ggf.
*    die Standardpfade aller zugehoerigen Prozesse als ungueltig
*    gesetzt.
*

D_Ddelete:
 move.l   (a0),a0
 movem.l  a6/a5/a4/a3/d7/d6,-(sp)
 suba.w   #xattr_sizeof,sp
 move.l   a0,a3
; trailing backslash entfernen
 suba.l   a6,a6                    ; kein trailing backslash
 tst.b    (a3)                     ; leerer Pfad ?
 beq.b    ddl_endloop              ; ja, kein backslash
 move.l   a3,a1
ddl_loop:
 tst.b    (a1)+
 bne.b    ddl_loop
 subq.l   #2,a1
 cmpi.b   #$5c,(a1)                ; letztes Zeichen ist backslash ?
 bne.b    ddl_endloop              ; nein
 clr.b    (a1)                     ; backslash entfernen
 move.l   a1,a6                    ; und merken, dass backslash entfernt wurde
ddl_endloop:
; DD des parent ermitteln
ddl_again:
 subq.l   #4,sp
 moveq    #0,d0                    ; DD des parent
 lea      (sp),a1
 move.l   a3,a0
 moveq    #5,d2                    ; Zaehler fuer Rekursion
 suba.l   a2,a2                    ; Default-Reldir
 bsr      _path_to_DD
 move.l   (sp)+,a5                 ; Restpfad
 tst.l    d0                       ; Fehler ?
 bmi      ddl_ende                 ; ja, Ende
; DD in a4 merken
 move.l   d0,a4
; Fxattr machen, um den Dateityp zu ermitteln
 move.l   a4,a0
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_xattr(a2),a2
 moveq    #1,d1                    ; Symlink NICHT folgen
 move.l   sp,d0                    ; XATTR *
 move.l   a5,a1                    ; a1 = name
;move.l   a0,a0                    ; a0 = DD
 jsr      (a2)
 tst.l    d0
 bmi      ddl_ende1                ; Das Objekt existiert nicht
; Fxattr erfolgreich. Ist es ein Symlink ?
 moveq    #EACCDN,d0               ; Fehlercode, falls weder dir noch Symlink
 move.b   xattr_mode(sp),d1
 lsr.b    #4,d1
 cmpi.b   #4,d1                    ; Directory ?
 beq.b    ddl_is_dir
 cmpi.b   #14,d1                   ; Symlink ?
 bne      ddl_ende1                ; nein, return(EACCDN)

;
; Es ist ein Symlink. Fdelete machen, um den Symlink zu loeschen
;

 move.l   a4,a0
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_fdelete(a2),a2
 move.l   a5,a1                    ; a1 = name
;move.l   a0,a0                    ; a0 = DD
 jsr      (a2)
 bra.b    ddl_ende1

;
; Es ist ein Verzeichnis
;

ddl_is_dir:
 moveq    #1,d0                    ; d0 = int flag (DD ermitteln)
 move.l   a5,a1                    ; a1 = char *pathname
 move.l   a4,a0                    ; a0 = DD *reldir
 move.l   dd_dmd(a4),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_path2DD(a2),a2
 jsr      (a2)
 tst.l    d0
 bmi.b    ddl_ende1                ; Fehler!
 move.l   a4,a0
 bsr      cond_unlock_dd           ; Pfad, in dem DD gesucht wurde, freigeben
 move.l   d0,a4                    ; der zu loeschende DD
; auf Default-Verzeichnis pruefen
 suba.l   a5,a5                    ; kein Standardpfad
 moveq    #1,d6                    ; erlaubter Referenzzaehler fuer DD
 move.l   a4,a0
 bsr      isdefault
 beq.b    ddl_no_std               ; ist kein Standardpfad
 move.l   a0,a5                    ; Zeiger auf Zeiger auf DD merken
 move.l   a1,d7                    ; Zeiger auf Referenzzaehler
; testen, ob Pfad noch anders als als Standardpfad verwendet wird.
 add.b    (a1),d6                  ; Referenzzaehler fuer Standardpfad
ddl_no_std:
 moveq    #EACCDN,d0
 cmp.w    dd_refcnt(a4),d6
 bcs.b    ddl_ende1                ; DD zusaetzlich noch referenziert
; Verzeichnis loeschen
 move.l   a4,a0
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_ddelete(a2),a2
;move.l   a0,a0                    ; a0 = DD
 jsr      (a2)
 tst.l    d0
 bmi.b    ddl_ende1                ; Fehler beim Loeschen
; Das Verzeichnis ist geloescht
 move.l   a5,d1                    ; war Standardpfad ?
 beq.b    ddl_ende1                ; nein
; Standardpfade ungueltig machen
 cmpa.l   (a5),a4                  ; ist noch Standardpfad ?
 bne.b    ddl_ende1                ; nein (?!?)
 move.l   d7,a1
 moveq    #0,d1
 move.b   (a1),d1                  ; Referenzzaehler
 beq.b    ddl_ende1                ; ist schon auf 0 (?)
 clr.l    (a5)                     ; Standardpfad als ungueltig markieren
 sub.w    d1,dd_refcnt(a4)         ; runtersetzen
 bgt.b    ddl_ok1
 move.w   #1,dd_refcnt(a4)         ; kann eigentlich nicht sein!
ddl_ok1:
 suba.l   a0,a0
 bsr      free_pathx
 moveq    #E_OK,d0

;
; Ende, DD schliessen.
;

ddl_ende1:
 move.l   a4,a0
 bsr      cond_unlock_dd           ; Pfad, in dem DD gesucht wurde, freigeben
ddl_ende:
 cmpi.l   #E_CHNG,d0
 beq      ddl_again
 move.l   a6,d1                    ; war trailing backslash ?
 beq.b    ddl_ende2                ; nein
 move.b   #$5c,(a6)                ; backslash wieder einsetzen
ddl_ende2:
 adda.w   #xattr_sizeof,sp
 movem.l  (sp)+,d6/d7/a3/a4/a5/a6
 rts


**********************************************************************
*
* Dopendir(char *path, int tosflag)
*

D_Dopendir:
 moveq    #xfs_dopendir,d2
_dx2:
 moveq    #0,d1                    ; aktuelle Verzeichnisse ignorieren
 move.w   4(a0),d0
_dx:
 move.l   (a0),a0                  ; a0 = subdir


**********************************************************************
*
* Dxfunc( a0 = char *path, d0 = long arg, d1 = int flag,
*         a1 = long arg2, a2 = long arg3,
*         d2 = int fn_offs)
*
* fuer Ddelete/Dpathconf/Dopendir/Dreadlabel/Dwritelabel
*
* Die aufgerufenen XFS-Routinen bekommen:
*    in a0          DD *
*    in a1          arg2
*    in d0          arg
*    in d1          arg3
*

Dxfunc:
 movem.l  d3/d4/d5/d6/d7/a3/a4,-(sp)
 move.l   a0,a3                    ; a3 = pathname
 move.l   d0,d7                    ; d7 = arg
 move.w   d1,d6                    ; d6 = flag
 move.w   d2,d3                    ; d3 = fn_offs
 move.l   a1,d4                    ; d4 = arg2
 move.l   a2,d5                    ; d5 = arg3

* Gleich den DD des zu bearbeitenden Verzeichnisses holen: a4
dxfu_again:
 moveq    #1,d0
 clr.l    -(sp)
 lea      (sp),a1
 move.l   a3,a0
 bsr      path_to_DD
 addq.l   #4,sp

 tst.l    d0
 ble      dxfu_ende                ; Datei nicht gefunden
 movea.l  d0,a4

* Nachsehen, ob ein Prozess das Verzeichnis als aktuelles Verzeichnis
* hat. Wenn ja, EACCDN zurueckgeben.

 tst.w    d6
 beq.b    dxfu_no_chk              ; kein Test, ist Open, nicht Delete
 btst.b   #5,(config_status+3).w
 bne.b    dxfu_no_chk              ; gefaehrlich !!!

 move.l   a4,a0
 bsr      isdefault
 bpl.b    dxfu_no_chk              ; OK
 move.l   a4,a0
 bsr      unlock_dd                ; aendert nicht d0
 bra.b    dxfu_ende                ; return(EACCDN)

* Das Verzeichnis wird ueber den Dateisystemtreiber bearbeitet
* Der DD braucht bei Ddelete nicht mehr freigegeben zu werden, das muss
* das XFS machen

dxfu_no_chk:
 move.l   d4,a1                    ; a1 = arg2
 move.l   d5,d1                    ; d1 = arg3
 move.l   dd_dmd(a4),a2
 move.l   d_xfs(a2),a2
 move.l   0(a2,d3.w),a2
 move.l   d7,d0                    ; arg
 move.l   a4,a0                    ; a0 = DD
 jsr      (a2)

 tst.w    d6                       ; Ddelete ?
 bne.b    dxfu_ende                ; ja, kein unlock
 move.l   a4,a0
 bsr      cond_unlock_dd           ; aendert nicht d0

dxfu_ende:
 cmpi.l   #E_CHNG,d0
 beq      dxfu_again
 movem.l  (sp)+,a4/a3/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* long Flink( char *fromdir, char *todir )
*
* erstelle "hard link".
* eigentlich aehnlich wie Frename, nur dass der alte Verzeichnis-
* eintrag nicht geloescht wird. Ausserdem darf <fromdir> ein symbolischer
* Link sein, wobei dann die tatsaechliche Datei, nicht etwa der Link
* dupliziert wird. Oder ?
*

D_Flink:
 moveq    #1,d0
 bra.b    fren_flink


**********************************************************************
*
* Frename(int 0, char *alt, char *neu)
*

D_Frename:
 addq.l   #2,a0
 moveq    #0,d0
fren_flink:
 movem.l  a6/a3/a4/d7/d4,-(sp)
 lea      (a0),a6
 move.w   d0,d7

* Der DD des Pfades von <alt> wird ermittelt: a4
* Der isolierte Dateiname: d4

fren_again:
 subq.l   #4,sp
 moveq    #0,d0
 lea      (sp),a1
 move.l   (a6),a0
 bsr      path_to_DD
 move.l   (sp)+,d4

 tst.l    d0
 bmi      fren_ende
 move.l   d0,a4

* Der DD des Pfades von <neu> wird ermittelt: a3
* Der isolierte Dateiname: d1

 subq.l   #4,sp
 moveq    #0,d0
 lea      (sp),a1
 move.l   4(a6),a0
 bsr      path_to_DD
 move.l   (sp)+,d1

 tst.l    d0
 bmi      fren_fende               ; a4 freigeben und Ende
 move.l   d0,a3

* Die Datei wird ueber den Dateisystemtreiber umbenannt
* Links werden nicht verfolgt, sondern es wird vom XFS- Treiber
* der Link umbenannt

 move.l   dd_dmd(a4),a2
 move.l   d_xfs(a2),a2
 move.l   dd_dmd(a3),a0
 cmpa.l   d_xfs(a0),a2             ; Dasselbe Dateisystem ?
 bne      fren_ensame              ; nein => a1/a4 freigeben und ENSAME
 move.l   xfs_link(a2),a2
 move.w   d7,d2                    ; d2 = flag (1=link 0=ren)
;move.l   d1,d1                    ; d1 = char *newname
 move.l   d4,d0                    ; d0 = char *oldname
 move.l   a3,a1                    ; a1 = DD * newdir
 move.l   a4,a0                    ; a0 = DD * olddir
 jsr      (a2)
fren_ffende:
 move.l   a3,a0
 bsr      unlock_dd                ; Ziel-DD freigeben
fren_fende:
 move.l   a4,a0
 bsr      unlock_dd                ; Quell-DD freigeben
fren_ende:
 cmpi.l   #E_CHNG,d0
 beq      fren_again
 movem.l  (sp)+,a6/a4/a3/d4/d7
 rts
fren_ensame:
 moveq    #ENSAME,d0
 bra.b    fren_ffende


**********************************************************************
*
* long Fseek(long offs, int hdl, int smode)
*

D_Fseek:
 move.l   a6,-(sp)
 move.l   a0,a6
 move.w   4(a6),d0                 ; hdl
 bsr.s    hdl_to_FD                ; hdl->FD
 ble      fsk_eihndl
 move.l   d0,a0
 move.l   (a6),d0                  ; offs
 move.w   6(a6),d1                 ; mode
 move.l   (sp)+,a6
;bra      _fseek


**********************************************************************
*
* MI/PL long _fseek( a0 = FD *file, d0 = long offs, d1 = int smode)
*

_fseek:
 move.l   fd_dev(a0),a2
 move.l   dev_seek(a2),a2
;move.w   d1,d1
;move.l   d0,d0
;move.l   a0,a0
 jmp      (a2)

fsk_eihndl:
 move.l   (sp)+,a6
 moveq    #EIHNDL,d0
 rts

__fseek:

;     DEB  '  __fseek'

 moveq    #0,d1                    ; ab Anfang
 bsr.b    _fseek
 tst.l    d0

;     DEBL  d0,'  __fseek => '

 rts


**********************************************************************
*
* LE/GT FD *hdl_to_FD(d0 = int handle)
*  Gibt zu einem Dateihandle den zugehoerigen FD zurueck.
*  Rueckgabe EIHNDL, wenn Fehler; dh. Datei nicht geoeffnet
*
*  a0 enthaelt die Adresse des Eintrags in PROCDATA.
*

hdl_to_FD:
 cmpi.w   #MIN_FHANDLE,d0
 blt.b    hdlx_err                 ; Handle kleiner als -4
 cmpi.w   #MAX_OPEN,d0
 bge.b    hdlx_err                 ; Handle groesser als 32
 move.l   act_pd,a0
 move.l   p_procdata(a0),a0
 lea      pr_handle(a0),a0
 muls     #fh_sizeof,d0
 add.l    d0,a0
 move.l   (a0),d0                  ; d0 = FD *
 beq.b    hdlx_err                 ; ungueltig
 rts
hdlx_err:
 moveq    #EIHNDL,d0
 rts


**********************************************************************
*
* long Fdup(int stdhdl)
*
* Legt eine Kopie des Standardhandles <stdhdl> an und erzeugt ein
* neues Handle.
* gibt (TOS- kompatibel) immer ein Handle > 5 zurueck, nicht mehr,
* wie in Mag!X 2.0, ein Geraetehandle < 0.
*
* ab 2.7.95:   Fdup von neg. Handle moeglich
*
* ab 18.4.99: MiNT-kompatibel, Fdup ist fuer jedes Handle moeglich.
*

D_Fdup:
 move.l   a6,-(sp)
 move.w   (a0),d0                  ; Handle
 bsr.b    hdl_to_FD
 bmi.b    fdup_ende
 move.l   d0,a6                    ; a6 = FD
 bsr      new_hdl
 bmi.b    fdup_ende                ; kein Handle mehr frei
 move.l   a6,(a0)                  ; neues Handle belegen
 cmpi.w   #-1,fd_refcnt(a6)
 beq.b    fdup_ende
 addq.w   #1,fd_refcnt(a6)
;move.l   d0,d0                    ; Handle zurueckgeben
fdup_ende:
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* long Fforce(int stdhdl, int nstdhdl)
*
*  8(a6) : stdhdl
* $a(a6) : nstdhdl
*  a5    : Zeiger auf Hdl- Eintrag von nstdhdl
*  a4    : Zeiger auf PD- Eintrag von stdhdl
*  d7    : FD oder Geraet des nstdhdl
*  d2    : Rueckgabewert 0L oder Fehlercode
*
* Unterschiede zur Original- Routine:
*  - Im Falle, dass die std- Datei schon auf eine andere "echte"
*    Datei gelenkt ist, wird std erst geschlossen, damit der
*    Referenzzaehler fuer diese Datei wieder stimmt.
*  - Es werden mehr Kontrollen durchgefuehrt (Handle > 80 usw.)
*
* ab 1.7.95:   Fforce auf neg. Handle (ausser -4) moeglich, wirkt
*              systemglobal
*
* 18.4.99: MiNT-kompatibel, jedes Handle kann umgelenkt werden.
*

D_Fforce:
 movem.l  a6/a4/a3,-(sp)
 move.l   a0,a6
* ermittle neues Handle
 move.w   2(a6),d0
 bsr.s    hdl_to_FD
 bmi      ffor_ende
 move.l   d0,a3                    ; FD merken
* ermittle altes Handle
 move.w   (a6),d0
 bsr.s    hdl_to_FD
 bmi.b    ffor_ende                ; ungueltig
 move.l   a0,a4                    ; Zeiger auf (FD *) merken
* schliesse altes Handle
 move.l   d0,a0
 move.l   fd_dev(a0),a2
 move.l   dev_close(a2),a2
;move.l   a0,a0
 jsr      (a2)                     ; flush/ggf. freigeben
* Handle umlenken
 move.l   a3,(a4)
* Referenzzaehler ggf. erhoehen
 cmpi.w   #-1,fd_refcnt(a3)        ; nur zur Sicherheit
 beq.b    ffor_dev
 addq.w   #1,fd_refcnt(a3)
ffor_dev:
 moveq    #0,d0
ffor_ende:
 movem.l  (sp)+,a6/a4/a3
 rts


**********************************************************************
*
* long Fclose(d0 = int hdl)
*
* Fclose ruft praktisch direkt den Dateitreiber auf, der das
* Herunterzaehlen des Referenzzaehlers besorgt und den FD schliesslich
* auch freigibt
*

D_Fclose:
 move.w   (a0),d0
;    DEBL  d0,'Fclose (hdl=)'
Fclose:
 movem.l  a5/d6,-(sp)

* Handle- Eintrag, FD ermitteln

 move.w   d0,d6
 bmi.b    fclo_eihndl              ; Geraetedateien (<0) nicht schliessen.
;move.w   d0,d0
 bsr      hdl_to_FD                ; => a0 = &FD
 bmi.b    fclo_ende                ; Fehler
 move.l   d0,a5                    ; a5 = FD *
 cmpi.w   #MIN_OPEN,d6             ; Standard-Datei?
 bge.b    fclo_nstd                ; nein
 move.l   act_pd,a1
 btst     #0,p_flags(a1)           ; MiNT-Domain?
 bne.b    fclo_nstd                ; ja, alle Handles gleich behandeln

* stdxx- Dateien (0..5) werden geschlossen, indem die urspruengliche
* Definition wieder eingesetzt wird.
* 2.6.99: Nur fuer die TOS-Domain!

 lea      def_hdlx(pc),a2
 move.b   0(a2,d6.w),d0
 ext.w    d0                       ; 0xff => -1
;move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 lea      pr_handle(a1),a1
 muls     #fh_sizeof,d0
 move.l   0(a1,d0.l),a1
 cmpi.w   #-1,fd_refcnt(a1)
 beq.b    fclo_dev
 addq.w   #1,fd_refcnt(a1)         ; Referenzzaehler erhoehen
fclo_dev:
 move.l   a1,(a0)                  ; Geraete- FD eintragen
 bra.b    fclo_both

* "Normale" Dateien einfach schliessen

fclo_nstd:
 clr.l    (a0)                     ; Handle freigeben

fclo_both:
 move.l   fd_dev(a5),a2
 move.l   dev_close(a2),a2
 move.l   a5,a0
 jsr      (a2)                     ; dekrem. refcnt, flush/ggf. freigeben

fclo_ende:
 movem.l  (sp)+,d6/a5
;    DEBL  d0,'Fclose => '
 rts
fclo_eihndl:
 moveq    #EIHNDL,d0
 bra.b    fclo_ende


**********************************************************************
*
* long Fread(d0 = int hdl, d1 = long count, a0 = char *buf)
*
* Unterschied zu DOS 0.19: Faengt das Lesen von 0 Bytes ab
*

D_Fread:
 move.w   (a0)+,d0
 move.l   (a0)+,d1
 move.l   (a0),a0
Fread:
;    DEBL  d0,'Fread  hdl = '
;    DEBL  d1,'       cnt = '
;    DEBL  a0,'       buf = '
 move.l   a0,-(sp)
 move.l   d1,-(sp)
 bsr      hdl_to_FD
 bmi.b    fread_eihndl
 movea.l  d0,a0                    ; a0 = FD
 move.l   (sp)+,d0                 ; d0 = count
 move.l   (sp)+,a1                 ; a1 = Daten
 beq.b    fread_ende               ; 0 Bytes lesen, return(0L)
 btst     #5,(config_status+3).w
 bne      _fread                   ; a0=FD/d0=count/a1=Daten
 btst     #BOM_RPERM,fd_mode+1(a0) ; Leseerlaubnis auf Datei ?
 bne      _fread                   ; ja
fread_eaccdn:
 moveq    #EACCDN,d0
fread_ende:
 rts
fread_eihndl:
 addq.l   #8,sp
 rts


**********************************************************************
*
* long Fwrite(d0 = int hdl, d1 = long count, a0 = char *buf)
*
* Unterschied zu DOS 0.19: Faengt das Schreiben von 0 Bytes ab
*                          Setzt sonst das dirty- Flag
*

D_Fwrite:
 move.w   (a0)+,d0
;     DEBL  d0,'Fwrite (hdl=)'
 move.l   (a0)+,d1
 bne.b    fwr_ok
 move.l   (a0),a0
 cmpa.w   #-1,a0
 bne.b    Fwrite
* count == 0/buf == -1 => Truncate
 move.w   d0,-(sp)
 move.w   #SEEK_CUR,-(sp)
 move.w   d0,-(sp)
 clr.l    -(sp)
 move.l   sp,a0
 bsr      D_Fseek             ; aktuelle Position ermitteln
 addq.l   #8,sp
 move.w   (sp)+,d1
 tst.l    d0
 bmi.b    fwr_err             ; Fehler bei Fseek
 move.l   d0,-(sp)            ; pos
 move.w   #FTRUNCATE,-(sp)
 pea      2(sp)               ; &pos
 move.w   d1,-(sp)            ; hdl
 move.l   sp,a0
 bsr      D_Fcntl
 lea      12(sp),sp
fwr_err:
 rts

fwr_ok:

 move.l   (a0),a0
Fwrite:
 move.l   a0,-(sp)                 ; buf merken
 move.l   d1,-(sp)                 ; count merken
;move.w   d0,d0
 bsr      hdl_to_FD
 bmi.b    fwrite_eihndl
 movea.l  d0,a0                    ; a0 = FD *
 move.l   (sp)+,d0                 ; d0 = count
 beq.b    fwrite_ende              ; 0 Bytes schreiben
 btst     #5,(config_status+3).w
 bne.b    fwrite_notst
 btst     #BOM_WPERM,fd_mode+1(a0) ; Schreib- Erlaubnis ?
 beq.b    fwrite_eaccdn            ; nur Lesen erlaubt!
fwrite_notst:
 btst     #BO_APPEND,fd_mode+1(a0)
 beq.b    fwrite_go
* Append fuehrt der Kernel durch!
 movem.l  d0/a0,-(sp)
 move.l   fd_dev(a0),a2
 move.l   dev_seek(a2),a2
;move.l   a0,a0
 moveq    #0,d0                    ; 0 Bytes
 moveq    #2,d1                    ; ab Dateiende
 jsr      (a2)
 tst.l    d0
 bge.b    fwrite_go2
 addq.l   #8,sp
 bra.b    fwrite_ende              ; Fehler bei seek
fwrite_go2:
 movem.l  (sp)+,d0/a0
fwrite_go:
 move.l   (sp)+,a1                 ; Daten
;move.l   d0,d0                    ; Anzahl Bytes
;move.l   a0,a0                    ; FD
 bra      _fwrite
fwrite_eihndl:
 addq.l   #8,sp
 rts
fwrite_eaccdn:
 moveq    #EACCDN,d0
fwrite_ende:
 addq.l   #4,sp
 rts



**********************************************************************
*
* MI/PL long _fread(a0 = FD *file, d0 = long count, a1 = char *buffer)
*  Ist <buffer> == NULL, bekommt man einen Zeiger auf die
*  gelesenen Bytes.
*

_fread:

;     DEB  '  _fread'

 move.l   fd_dev(a0),a2
 move.l   dev_read(a2),a2
 jsr      (a2)
 tst.l    d0

;     DEBL  d0,'  _fread => '

 rts


**********************************************************************
*
* Mi/PL _fwrite(a0 = FD *file, d0 = long count, a1 = char *data)
*

_fwrite:

;     DEB  '  _fwrite'

 move.l   fd_dev(a0),a2
 move.l   dev_write(a2),a2
 jsr      (a2)
 tst.l    d0

;     DEBL  d0,'  _fwrite => '

 rts


**********************************************************************
*
* long D_Fgetchar( int handle, int mode )
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rueckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*              0x0000FF1A bei EOF
*

D_Fgetchar:
 move.w   #dev_getc,-(sp)
 clr.l    -(sp)
 move.w   2(a0),-(sp)
 bra.b    _fpc


**********************************************************************
*
* long D_Fputchar( int handle, long value, int mode )
*
* mode & 0x0001:    cooked
*
* Rueckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*

D_Fputchar:
 move.w   #dev_putc,-(sp)
 move.l   2(a0),-(sp)
 move.w   6(a0),-(sp)
_fpc:
 move.w   (a0),d0
 bsr      hdl_to_FD
 bmi.b    fpc_err
 move.l   d0,a0               ; FD
 move.w   (sp)+,d0            ; mode
 move.l   (sp)+,d1            ; val
 move.l   fd_dev(a0),a2
 add.w    (sp)+,a2
 move.l   (a2),a2
 jmp      (a2)
fpc_err:
 addq.l   #8,sp
 rts


**********************************************************************
*
* long D_Finstat( int handle )
*
* Gibt die Anzahl der Bytes zurueck, die noch zu lesen sind, d.h. die
* bei Geraeten noch im Puffer liegen.
* Wenn die Anzahl der Bytes nicht abgeschaetzt werden kann, wird eine
* 1 geliefert.
*

D_Finstat:
 moveq    #0,d1               ; Lesemodus
 bra.b    _dfstat


**********************************************************************
*
* long D_Foutstat( int handle )
*
* Gibt die Anzahl der Bytes zurueck, die noch zu schreiben sind, d.h.
* die bei Geraeten noch in den Puffer passen.
* Wenn die Anzahl der Bytes nicht abgeschaetzt werden kann, wird eine
* 1 geliefert.
*

D_Foutstat:
 moveq    #1,d1                    ; Schreibmodus
_dfstat:
 move.w   d1,-(sp)                 ; Modus merken
 move.w   (a0),d0                  ; Handle
 bsr      hdl_to_FD
 bmi.b    _dfst_err                ; ungueltig
 movea.l  d0,a0
 move.w   (sp),d0
 btst     d0,fd_mode+1(a0)         ; jeweilige Erlaubnis ?
 beq.b    _dfst_eaccdn             ; nein!
 move.l   a0,-(sp)                 ; FD merken
 subq.l   #4,sp                    ; Platz fuer 1 long
 move.l   fd_dev(a0),a2
 move.l   sp,a1                    ; a1 = arg      (Typ: void *)
 move.w   #FIONREAD,d0             ; d0 = cmd
 add.w    8(sp),d0                 ; ggf. FIONWRITE
 move.l   dev_ioctl(a2),a2
 jsr      (a2)                     ; Fcntl(FIONREAD usw.)
 tst.l    d0
 bge.b    _dfst_ok                 ; hat funktioniert!
 addq.l   #4,sp                    ; nein, Rueckgabewert ungueltig
 cmpi.l   #EINVFN,d0               ; nicht implementiert ?
 bne.b    _dfst_err2               ; nein, boeser Fehler

; nicht implementiert, nimm Fstat

 move.l   (sp)+,a0                 ; FD
 move.w   (sp)+,d0                 ; rwmode
 moveq    #0,d1                    ; d1 = ap_code (polling!)
 suba.l   a1,a1                    ; a1 = void *unselect
 move.l   fd_dev(a0),a2
 move.l   dev_stat(a2),a2
 jmp      (a2)

_dfst_ok:
 move.l   (sp)+,d0                 ; Rueckgabewert: Anzahl Bytes
_dfst_err2:
 addq.l   #4,sp                    ; FD abbauen
_dfst_err:
 addq.l   #2,sp                    ; Flag abbauen
 rts
_dfst_eaccdn:
 moveq    #EACCDN,d0
 bra.b    _dfst_err


**********************************************************************
*
* long Fstat( d0 = int handle, d1 = int rwflag,
*                a0 = void *unselect, a1 = long ap_code )
*
* Stellt den Ein-/Ausgabestatus einer Datei (bzw. eines Devices) fest.
*
* Grundsaetzlich: Wenn a0 != NULL ist, wird der Rueckgabewert auch nach
* (a0) geschrieben.
*
* 1. Variante: Polling
*    Eingabe:  a1 = NULL
*    Rueckgabe: 0         nicht bereit zum Lesen
*              1         bereit zum Lesen
*              < 0       Fehlercode
*              Rueckgabe nach *unselect, falls Zeiger ungleich NULL
*
* 2. Variante: Waiting
*    Eingabe:  a0 ist ein Zeiger, a1 kennzeichnet die Applikation
*    Rueckgabe: 1         bereit zum Lesen, App braucht nicht zu warten
*                        *unselect wird nicht veraendert
*              0         Dateihandler ist nicht interruptfaehig und muss
*                        ge-pollt werden.
*                        *unselect wird nicht veraendert
*              2         Datei ist z.Zt. nicht lesebereit. Die aktuelle
*                        Applikation (a1) wird als "Klient" fuer den Interrupt-
*                        Handler eingetragen, das muss der Geraetetreiber
*                        erledigen (d.h. a0 und a1 merken und den Interrupt
*                        aktivieren.
*
*                        * unselect wird mit der Adresse einer Routine
*                        beschrieben, die das Warten auf ein Ereignis
*                        wieder deaktiviert.
*                        Prototyp des Interrupt- Deaktivierers:
*                             void unselect( a0 = void *code,
*                                            a1 = long ap_code );
*                        unselect wird aufgerufen mit demselben Parameter
*                        wie Fstat in a0. Es darf auf keinen Fall nach
*                        Aufruf von unselect noch auf (a0) zugegriffen
*                        werden! unselect ersetzt den Wert in (a0), der noch
*                        der Zeiger auf unselect sein kann (wenn der
*                        Interrupt nicht dazwischengekommen ist) durch 0
*                        oder 1 oder < 0.
*
*                        Wenn der Interrupt eintrifft, wird anstelle der
*                        unselect- Routine eine 1L (OK) oder <0 (Fehler)
*                        eingetragen.
*                        Die Interrupt- Routine muss die Kernelfunktion
*                        appl_IOcomplete aufrufen, Parameter ist ap_code
*                        der aufzuweckenden Applikation.
*                        Prototyp des Interrupt- Melders:
*                             void appl_IOcomplete( a0 = long ap_code );
*
*

Fstat:
 move.l   a0,-(sp)                 ; void *unselect
 move.l   a1,-(sp)                 ; void *ap_code
 move.w   d1,-(sp)                 ; int  rwflag
 bsr      hdl_to_FD
 move.w   (sp)+,d1
 move.l   (sp)+,a2                 ; long ap_code
 tst.l    d0
 bmi      Frws_err                 ; Fehler
 move.l   (sp)+,a1
 move.l   d0,a0


**********************************************************************
*
* long fstat( a0 = FD *fd, d1 = int rwflag,
*                a1 = void *unselect, a2 = long ap_code )
*
* Rueckgabe: wie Fstat
*

fstat:
 move.l   a1,-(sp)                      ; unselect merken
 btst     d1,fd_mode+1(a0)              ; jeweilige Erlaubnis ?
 beq      fstat_eaccdn                  ; keine Lese-Erlaubnis
 move.w   d1,d0                         ; d0 = rwflag
 move.l   a2,d1                         ; d1 = ap_code
 move.l   (sp)+,a1                      ; a1 = void *unselect
 move.l   fd_dev(a0),a2
 move.l   dev_stat(a2),a2
 jmp      (a2)

fstat_eaccdn:
 moveq    #EACCDN,d0                    ; falscher Open- Modus
 bra.b    Frws_ende
Frws_err:
 moveq    #EIHNDL,d0                    ; ungueltiges Handle
Frws_ende:
 move.l   (sp)+,d1                      ; void *unselect
 beq.b    Frws_e2
 move.l   d1,a0
 move.l   d0,(a0)
Frws_e2:
 rts


**********************************************************************
*
* long Fselect( int timeout, long *instat, long *outstat, long dummy )
*
* setzt Bits, wenn Status ok
* timeout gibt Millisekunden an, wenn 0, wird immer gewartet.
* Rueckgabe: Anzahl der gesetzten Bits von instat und outstat
*
* d7      int  timeout
* a6      long *instat
* d6      long instat
* a5      long *outstat
* d5      long outstat
* d4      long recode
*

D_Fselect:
 movem.l  a6/a5/a4/a3/d7/d6/d5/d4/d3,-(sp)
 suba.w   #8*64,sp                      ; 64 double-longs

 moveq    #-1,d7
 move.w   (a0)+,d7                      ; int timeout

 move.l   (a0)+,a6                      ; &instat
 move.l   (a0),a5                       ; &outstat

 bsr      get_act_appl
 move.l   d0,a3                         ; a3 = act_appl

 move.l   a6,d6
 beq.b    dfs_no_in
 move.l   (a6),d6                       ; instat
 clr.l    (a6)                          ; zunaechst alle Bits loeschen

dfs_no_in:
 move.l   a5,d5
 beq.b    dfs_no_out
 move.l   (a5),d5                       ; outstat
 clr.l    (a5)                          ; zunaechst alle Bits loeschen
dfs_no_out:

 moveq    #0,d4
dfs_again:
 lea      8*64(sp),a4

*
* Dateien zum Lesen
*

 moveq    #63,d3
dfs_loop:
 subq.l   #4,a4                         ; Datenlangwort ueberspringen
 clr.l    -(a4)                         ; per Default nicht eingetroffen
 move.w   d3,d0
 andi.w   #31,d0                        ; d0 = Handle (0..31)
 cmpi.w   #31,d3
 bls.b    dfs_wstate
* Dateien zum Lesen
 moveq    #0,d1                         ; d1 = rstate
 btst     d0,d6
 bra.b    dfs_bstate
* Dateien zum Schreiben
dfs_wstate:
 moveq    #1,d1                         ; d1 = wstate
 btst     d0,d5
dfs_bstate:
 beq.b    dfs_nloop
 move.l   a3,a1                         ; APPL * (wait) bzw. NULL (polling)
 move.l   a4,a0
;move.w   d1,d1
;move.w   d0,d0
 bsr      Fstat
 tst.l    d0
* negativ: Fehler
 bmi      dfs_etidy                     ; EIHNDL, ggf. unselect
 beq.b    dfs_poll                      ; muss Polling machen
 subq.l   #1,d0                         ; waiting ?
 bne.b    dfs_nloop                     ; ja, weiter
 addq.l   #1,d4                         ; Datei ist jetzt schon "ready"
 bra.b    dfs_nloop
dfs_poll:
* Null: bin nicht interruptfaehig
 move.l   a3,d0                         ; schon im polling mode ?
 beq.b    dfs_nloop                     ; ja!
 bsr      dfs_tidy                      ; alle unselects durchfuehren
 suba.l   a3,a3                         ; APPL * loeschen
dfs_nloop:
 dbra     d3,dfs_loop

 tst.w    d4                            ; irgendwelche Bits gesetzt ?
 bne.b    dfs_ende                      ; ja!

 move.l   a3,d0                         ; alle Dateien interruptfaehig ?
 bne.b    dfs_wait

 jsr      appl_yield

 tst.l    d7                            ; schon in Ticks umgerechnet
 beq      dfs_again                     ; ja, unbegrenzt warten
 bgt.b    dfs_wait200hz                 ; ja, mit 200hz- Timer vergl.
* ms in 200Hz umrechnen
 andi.l   #$ffff,d7
 beq      dfs_again                     ; unbegrenzt warten
 divu     #5,d7                         ; ms => Ticks
 ext.l    d7
 add.l    _hz_200,d7                    ; Abbruchzeit ausrechnen
dfs_wait200hz:
 cmp.l    _hz_200,d7
 bgt      dfs_again                     ; noch kein Timeout
 bra.b    dfs_ende

*
* Lege Applikation schlafen
*

dfs_wait:
 moveq    #0,d1
 move.w   d7,d1
 divu     #20,d1                        ; ms -> 50Hz
 moveq    #0,d0
 move.w   d1,d0                         ; Hiword loeschen
 swap     d1
 tst.w    d1                            ; Rest bei Division ?
 beq.b    dfs_ww
 addq.w   #1,d0
dfs_ww:
 moveq    #64,d1                        ; 64 Ereignisse
 move.l   sp,a0                         ; Dateien
 jsr      evnt_mIO                      ; event-multi-input-output

dfs_ende:

*
* Zaehle eingetroffene Ereignisse und setze Bits
*

 lea      (sp),a0
 moveq    #64,d0
 move.l   a3,a1
 bsr.b    funselect                     ; unselect durchfuehren
 move.l   d0,d4

 lea      8*64(sp),a4
 moveq    #63,d3
dfs_endloop:
 subq.l   #4,a4                         ; Datenlangwort ueberspringen
 move.l   -(a4),d0
 ble.b    dfs_enext
 moveq    #0,d0
 bset.l   d3,d0
 move.l   a6,a0
 cmpi.w   #31,d3
 bhi.b    dfs_eo
 move.l   a5,a0
dfs_eo:
 or.l     d0,(a0)                       ; eingetroffen
dfs_enext:
 dbra     d3,dfs_endloop

dfs_retd4:
 move.l   d4,d0
dfs_err:
 adda.w   #8*64,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3
 rts

dfs_etidy:
 move.l   d0,d4                         ; Fehlercode merken
 bsr.b    dfs_tidy
 bra      dfs_retd4

dfs_tidy:
 move.l   a4,a0
 lea      8*64+4(sp),a1
 suba.l   a4,a1
 move.l   a1,d0
 lsr.l    #3,d0                         ; teilen durch 8
 move.l   a3,a1                         ; APPL *


**********************************************************************
*
* long funselect(a0 = long tab[num], a1 = APPL *ap, d0 = int num)
*
* macht unselect fuer die bisher erwarteten Ereignisse. Anschliessend
* stehen nur noch 0 oder 1 oder Fehlercodes in der Tabelle.
* Gibt die Anzahl der eingetroffenen Ereignisse zurueck.
*

funselect:
 movem.l  a5/a6/d6/d7,-(sp)
 move.l   a0,a6                         ; a6 = long *tab
 move.l   a1,a5                         ; a5 = APPL *
 move.w   d0,d6                         ; d6 = int num
 moveq    #0,d7                         ; Zaehler fuer eingetroffene
 bra      funs_nxt
funs_loop:
 move.l   (a6),d1
 ble.b    funs_anxt                     ; Fehler oder "nicht eingetroffen"
 move.l   d1,a2
 subq.l   #1,d1
 beq.b    funs_tadd                     ; schon eingetroffen
 move.l   a5,a1                         ; APPL *
 lea      (a6),a0                       ; long *code
 jsr      (a2)                          ; unselect
 tst.l    (a6)                          ; jetzt eingetroffen ?
 ble.b    funs_anxt                     ; nein
funs_tadd:
 addq.l   #1,d7
funs_anxt:
 addq.l   #8,a6
funs_nxt:

 dbra     d6,funs_loop
 move.l   a5,d0
 beq.b    funs_ende
 move.l   a5,a0
 jsr      evnt_emIO                     ; ggf. ausstehende Events loeschen
funs_ende:
 move.l   d7,d0
 movem.l  (sp)+,a5/a6/d6/d7
 rts


**********************************************************************
*
* long Fdatime(int buffer[2], int handle, int setflag)
*
* gegenueber DOS 0.19 voellig neu, alle Fehler beseitigt,
*                    beruecksichtigt sogar mehrfach geoeffnete Dateien
*
* stark optimiert. Abfrage auf identische Dateien korrigiert.
* Bisher wurde im selben Verzeichnis geoeffnete Dateien auch im Datum
* geaendert, wenn sie wie <handle> leer waren.
*

D_Fdatime:
 move.l   a5,-(sp)
 move.l   a0,a5
 move.w   4(a5),d0
 bsr      hdl_to_FD
 bmi.b    fdat_err                 ; ungueltig oder Device
 movea.l  d0,a0
 move.l   fd_dev(a0),a2
 move.l   dev_datime(a2),a2
 movea.l  (a5),a1                  ; a1 = puffer
 move.w   6(a5),d0                 ; d0 = setflag
 move.l   (sp)+,a5
 jmp      (a2)
fdat_err:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long Flock(int handle, int mode, long start, long len)
*
* Ist eigentlich keine MiNT- Funktion, wird aber von MiNT
* unterstuetzt
*

D_Flock:
 moveq    #F_UNLCK,d1
 move.w   2(a0),d0
 beq.b    flk_ok
 moveq    #F_WRLCK,d1
 subq.w   #1,d0
 beq.b    flk_ok
 moveq    #EINVFN,d0
 rts
flk_ok:
 clr.w    -(sp)               ; l_pid
 move.l   8(a0),-(sp)         ; l_len
 move.l   4(a0),-(sp)         ; l_start
 clr.w    -(sp)               ; l_whence = SEEK_SET
 move.w   d1,-(sp)            ; l_type
 move.w   #F_SETLK,-(sp)
 pea      2(sp)
 move.w   (a0),-(sp)
 bsr.b    D_Fcntl
 adda.w   #22,sp
 rts


**********************************************************************
*
* long Fcntl( int hdl, long arg, int cmd )
*
* Kernel sollte erledigen:
*    F_DUPFD   EQU  0
*    F_GETFD   EQU  1
*    F_SETFD   EQU  2
*    F_GETFL   EQU  3
*    F_SETFL   EQU  4
*    F_GETLK   EQU  5
*    F_SETLK   EQU  6
*    F_SETLKW  EQU  7
*
* sollten alle Treiber unterstuetzen:
*    FSTAT     EQU  $4600
*    FIONREAD  EQU  $4601
*    FIONWRITE EQU  $4602
*

D_Fcntl:
 move.l   a5,-(sp)
 move.l   a0,a5
 move.w   (a5)+,d0                 ; Handle
 bsr      hdl_to_FD
 bmi.b    fct_err                  ; ungueltig oder Device
 movea.l  d0,a1                    ; a1 = FD
 move.w   4(a5),d0                 ; d0 = cmd
 beq.b    fct_0
 cmpi.w   #F_GETFD,d0
 beq.b    fct_1
 cmpi.w   #F_SETFD,d0
 bne.b    fct_else
* F_SETFD (2)
 move.w   2(a5),fh_flag(a0)             ; Vererbungs-Flag setzen
 moveq    #E_OK,d0
 bra.b    fct_err
* F_GETFD (1)
fct_1:
 moveq    #0,d0
 move.w   fh_flag(a0),d0           ; Vererbung-Flag holen
 bra.b    fct_err
* F_DUPFD (0)
fct_0:
 moveq    #0,d0                    ; Hiword loeschen
 move.w   2(a5),d0                 ; minimales Handle
 cmpi.w   #MIN_FHANDLE,d0
 blt.b    fct_eihndl               ; zu klein
 cmpi.w   #MAX_OPEN-1,d0
 blt.b    fct0_ok                  ; ok (kleiner als 31)
fct_eihndl:
 moveq    #EIHNDL,d0               ; Handle < 0 oder >= MAX_OPEN
 bra.b    fct_err
fct0_ok:
 move.l   a1,-(sp)
 bsr.s    _new_hdl
 move.l   (sp)+,a1
 bmi.b    fct_err                  ; kein Handle mehr frei
 move.l   a1,(a0)                  ; neues Handle belegen
 cmpi.w   #-1,fd_refcnt(a1)
 beq.b    fct0_0
 addq.w   #1,fd_refcnt(a1)
;move.l   d0,d0                    ; Handle zurueckgeben
fct0_0:
 bra.b    fct_err
* alle anderen
fct_else:
;move.w   d0,d0                    ; d0 = WORD cmd
 move.l   a1,a0
 move.l   (a5),a1                  ; a1 = arg    (Typ: void *)
 move.l   (sp)+,a5
 move.l   fd_dev(a0),a2
 move.l   dev_ioctl(a2),a2
 jmp      (a2)
fct_err:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void unlock_dd( a0 = DD *dir, d0 = long errcode )
*
* fuehrt <unlock_dd> nur aus, wenn kein Diskwechsel war.
*

cond_unlock_dd:
 cmpi.l   #E_CHNG,d0               ; Diskwechsel ?
 beq.b    unldd_ok                 ; kein unlock!!
 cmpi.l   #EDRIVE,d0               ; Diskwechsel ?
 beq.b    unldd_ok                 ; kein unlock!!
;bra      unlock_dd


**********************************************************************
*
* void unlock_dd( a0 = DD *dir )
*
* Der Referenzzaehler eines DD wird dekrementiert. Wenn er 0 ist, wird
* das XFS aufgerufen, um den DD freizugeben.
* veraendert nicht d0/d1/d2/a0/a1/a2
*

unlock_dd:
 subq.w   #1,dd_refcnt(a0)         ; alter Pfad
 bne.b    unldd_ok                 ; noch nicht freigeben
 movem.l  d0-d2/a0-a2,-(sp)
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_freeDD(a2),a2
 jsr      (a2)                     ; DD freigeben
 movem.l  (sp)+,d0-d2/a0-a2
unldd_ok:
 rts


**********************************************************************
*
* d0/a0 new_hdl( void )
*
* gibt in d0 ein neues Handle fuer act_pd oder ENHNDL zurueck
* gibt in a0 einen Zeiger auf pr_handle+d0 zurueck
*
* die Bits Z und N des ccr sind entsprechend gesetzt
*

new_hdl:
 moveq    #MIN_OPEN,d0                  ; erstes non-standard Handle
_new_hdl:
 move.l   act_pd,a0
 move.l   p_procdata(a0),a0
 move.w   d0,d1
 muls     #fh_sizeof,d1
 add.l    d1,a0
 lea      pr_handle(a0),a0
newh_loop:
 tst.l    (a0)
 beq.b    newh_ende
 addq.l   #fh_sizeof,a0
 addq.w   #1,d0
 cmpi.w   #MAX_OPEN,d0
 blt.b    newh_loop
 moveq    #ENHNDL,d0
newh_ende:
 cmpi.w   #MIN_OPEN,d0
 blt.b    newh_0
 move.w   #FD_CLOEXEC,fh_flag(a0)       ; nicht vererben
newh_0:
 tst.l    d0
 rts


**********************************************************************
*
* long Fgetdta()
*

Fgetdta:
 movea.l  act_pd,a0
 move.l   p_dta(a0),d0
 rts


**********************************************************************
*
* long Fsetdta()
*
* Mag!X 2.00: liefert immer 0 fuer "kein Fehler"
*

D_Fsetdta:
 movea.l  act_pd,a1
 move.l   (a0),p_dta(a1)
 moveq    #0,d0
 rts


**********************************************************************
*
* long Dsetdrv( d0 = char drv )
*

D_Dsetdrv:
 move.w   (a0),d0
Dsetdrv:
 movea.l  act_pd,a0
 move.b   d0,p_defdrv(a0)
 move.w   #$a,-(sp)
 trap     #$d
 addq.w   #2,sp
 rts


**********************************************************************
*
* long kill_locks( a0 =  PD *pd )
*
* entfernt alle Locks, die dem Prozess gehoeren
*

kill_locks:
 movem.l  a5/d7,-(sp)
 moveq    #0,d7
 lea      dlockx,a5
kllo_loop:
 cmpa.l   (a5),a0
 bne.b    kllo_nxtloop
 clr.l    (a5)                     ; Lock freigeben
kllo_nxtloop:
 addq.l   #4,a5
 addq.w   #1,d7
 cmpi.w   #LASTDRIVE,d7
 bls.b    kllo_loop
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* long Dlock( int mode, int drv )
*

D_Dlock:
 moveq    #EDRIVE,d0
 move.w   (a0)+,d2                 ; int mode
 move.w   (a0),a0                  ; int drv
 move.w   a0,d1
 cmp.w    #LASTDRIVE,a0
 bhi      dlk_ende                 ; Laufwerknummer nicht 0..LASTDRIVE
 cmp.w    #DRIVE_U,a0
 beq      dlk_ende                 ; Laufwerk U: nicht gueltig!
 add.w    a0,a0
 add.w    a0,a0
 lea      dlockx(a0),a0
 btst     #0,d2
 beq.b    dlk_unlock
; LOCK
 move.l   (a0),d0                  ; sperrender Prozess
 beq.b    dlk_weiter               ; nicht gesperrt
 cmp.l    act_pd,d0

* 1. Fall: Wir haben selbst schon gesperrt: E_OK

 beq      dlk_ok                   ; wir haben selbst gesperrt: E_OK

* 2. Fall: Anderer Prozess hat gesperrt

* 2.1      Bit 1 von mode geloescht: ELOCKED

 moveq    #ELOCKED,d0
 btst     #1,d2
 beq      dlk_ende

* 2.2      Bit 1 von mode gesetzt: sperrende process_id

 move.l   (a0),a0
 moveq    #0,d0
 move.w   p_procid(a0),d0
 bgt.b    dlk_ende                 ; proc_id gueltig
 move.w   #N_PROCS+1,d0            ; ungueltige id
 rts

* 3. Fall: nicht gesperrt. Teste Dateien und sperre, wenn moeglich

dlk_weiter:
 move.w   d1,d0
 bra      _dlock

* UNLOCK

dlk_unlock:
 moveq    #ENSLOCK,d0
 move.l   (a0),a1

* 4. Unlock: Geraet nicht oder nicht von mir ge-lock-t: ENSLOCK

 cmpa.l   act_pd,a1
 bne      dlk_ende

* 4. Unlock: Geraet von mir ge-lock-t: Diskwechsel schon passiert, E_OK

 clr.l    (a0)

dlk_ok:
 moveq    #0,d0
dlk_ende:
 rts


**********************************************************************
*
* long Dgetdrv()
*

Dgetdrv:
 moveq    #0,d0
 movea.l  act_pd,a0
 move.b   p_defdrv(a0),d0
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
* int strncmp(a0 = char *s1, a1 = char *s2, d0 = int n)
* Kommt mit gesetztem/geloeschtem Z-Flag zurueck
*

strncmp:
 move.w  d0,d1
 subq.w  #1,d1
 bcs.b   snc_4            * n = 0
 bra.b   snc_2
snc_loop:
 tst.b   -1(a0)
 beq.b   snc_4
snc_2:
 cmp.b   (a1)+,(a0)+
 beq.b   snc_3
 move.b  -1(a0),d0
 sub.b   -1(a1),d0
 ext.w   d0
 bra.b   snc_5
snc_3:
 dbra    d1,snc_loop
snc_4:
 moveq    #0,d0
snc_5:
 rts



**********************************************************************
**********************************************************************
*
* Prozessverwaltung
*
**********************************************************************


**********************************************************************
*
* d0 = proc_info( d0 = int code, a0 = PD *pd )
*
* Kernel-Funktion (zum Aufruf durch ein XFS).
* Ermittelt Daten fuer den aktuellen Prozess:
*
*    d0 = 0:   hoechste verfuegbare Unterfunktionsnummer
*         1:   Domain
*         2:   Process-ID
*

proc_info:
 tst.w    d0
 beq.b    proci_maxval
 subq.w   #1,d0
 beq.b    proci_1
 subq.w   #1,d0
 beq.b    proci_2
 moveq    #ERANGE,d0
 rts
* Unterfunktion 1: Pdomain ermitteln
proci_1:
 moveq    #0,d0
 move.b   p_flags(a0),d0
 andi.b   #1,d0
 rts
* Unterfunktion 2: Process-ID ermitteln
proci_2:
 moveq    #0,d0
 move.w   p_procid(a0),d0
 rts
proci_maxval:
 moveq    #2,d0
 rts


**********************************************************************
*
* d0/d1 = pgetmemlim( a0 = PD *pd )
*
* d0 = So ist die aktuelle Einstellung des Limits
* d1 = Wievel braucht der Prozess momentan ?

*
* aendert nicht a0
*

pgetmemlim:
 move.l   a0,-(sp)
 bsr      pd_used_mem              ; gesamter momentaner Speicher
 move.l   (sp)+,a0
 move.l   p_tlen(a0),d1
 add.l    p_dlen(a0),d1
 add.l    p_blen(a0),d1
 add.l    #256,d1                  ; BP+TEXT+DATA+BSS
 sub.l    d1,d0                    ; soviel habe ich schon geholt
 move.l   d0,d1
 move.l   p_mem(a0),d0             ; soviel darf ich noch holen
 addq.l   #1,d0                    ; unlimitiert ?
 beq.b    psl3_unl                 ; ja!
 subq.l   #1,d0
 add.l    d1,d0                    ; + soviel habe ich geholt
psl3_unl:
 rts


**********************************************************************
*
* long Psetlimit( WORD limit, LONG val )
*
* Setzt/ermittelt fuer den aktuellen Prozess eine Limitierung der
* Prozessorzeit oder des Speichers.
*
* val   = 0: unbegrenzt
*        -1: nur aktuellen Wert zurueckgeben
*     sonst: neuen Wert setzen
*
* limit = 1: get/set maximum CPU time for process (in milliseconds)
*         2: get/set total maximum memory allowed for process
*         3: get/set limit on Malloced memory for process
*
* RUeckgabewert: alter Wert bzw. EINVFN, wenn nicht unterstuetzt
*
* Modus 3 implementiert: 17.9.95
*

D_Psetlimit:
 move.w   (a0)+,d0                 ; limit
 subq.w   #3,d0
 bne.b    pslim_einvfn             ; in MagiC nur Modus 3 erlaubt
* Modus 3
 move.l   d7,-(sp)
 move.l   (a0),d7                  ; val
 move.l   act_pd,a0
 bsr.b    pgetmemlim
 addq.l   #1,d7                    ; nur Wert holen ?
 beq.b    psl3_ret                 ; ja, akt. Wert zurueckgeben
 moveq    #-1,d2
 subq.l   #1,d7                    ; 0 (unbegrenzt) ?
 beq.b    psl3_sunl                ; ja, als unbegrenzt setzen
 moveq    #0,d2
 sub.l    d1,d7                    ; abziehen, was ich schon geholt habe
 bcs.b    psl3_sunl                ; zuviel, Rest ist Null
 move.l   d7,d2
psl3_sunl:
 move.l   d2,p_mem(a0)
psl3_ret:
 move.l   (sp)+,d7
 rts
pslim_einvfn:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long Psemaphore( int mode, long id, long timeout )
*
* <timeout> wird in ms angegeben.
* <timeout> == -1L wartet fuer immer.
* <timeout> == 0L kommt sofort zurueck.
*

D_Psemaphore:
 move.w   (a0)+,d0
 move.l   (a0)+,d1
 cmpi.w   #PSEM_CRGET,d0
 beq.b    psem_crget
 cmpi.w   #PSEM_DESTROY,d0
 beq.b    psem_destroy
 cmpi.w   #PSEM_GET,d0
 beq      psem_get
 cmpi.w   #PSEM_RELEASE,d0
 beq      psem_rel
 moveq    #EINVFN,d0
 rts
psem_erange:
 moveq    #ERANGE,d0
 rts

* case PSEM_CRGET

psem_crget:
 move.l   d1,-(sp)
 moveq    #SEM_GET,d0
 jsr      evnt_sem
 move.l   (sp)+,d1
 tst.l    d0                       ; existiert Semaphore schon ?
 bgt      psem_eaccdn              ; ja, return(EACCDN)
 move.l   d1,-(sp)
 bsr      int_malloc               ; Block fuer Semaphore anfordern
 move.l   d0,a0
 move.l   #'sema',(a0)+
 move.l   #'phor',(a0)+            ; Magic reinschreiben!
 move.l   (sp)+,d1
 moveq    #SEM_CREATE,d0
 move.l   a0,-(sp)
 jsr      evnt_sem                 ; Semaphore erstellen
 move.l   (sp)+,a0
 moveq    #-1,d1
 moveq    #SEM_SET,d0
 jmp      evnt_sem                 ; Semaphore belegen

* case PSEM_DESTROY

psem_destroy:
 moveq    #SEM_GET,d0
 jsr      evnt_sem                 ; Semaphore ermitteln
 tst.l    d0
 bmi.b    psem_erange              ; existiert nicht!
 move.l   act_pd,a1
 cmpa.l   bl_pd(a0),a1             ; bin ich Eigner ?
 bne.b    psem_eaccdn              ; nein, return(EACCDN)
 cmpi.l   #'phor',-(a0)
 bne.b    psem_eaccdn
 cmpi.l   #'sema',-(a0)
 bne.b    psem_eaccdn              ; ungueltiges MAGIC
 move.l   a0,-(sp)
 addq.l   #8,a0
 moveq    #SEM_DEL,d0
 jsr      evnt_sem                 ; Semaphore freigeben
 move.l   (sp)+,a0
 tst.l    d0
 bmi      psem_eaccdn              ; Fehler ?
 clr.l    (a0)
 clr.l    4(a0)                    ; magic loeschen
 bsr      int_mfree                ; und Block freigeben
 moveq    #0,d0
 rts


* case PSEM_GET

psem_get:
 move.l   (a0),-(sp)
 moveq    #SEM_GET,d0
 jsr      evnt_sem
 move.l   (sp)+,d1                 ; timeout
 tst.l    d0
 bmi      psem_erange              ; nicht gefunden
; umrechnen ms => 50Hz
 addq.l   #1,d1                    ; -1 uebergeben, ewig warten ?
 beq.b    psem_sw                  ; ja
 subq.l   #1,d1                    ; 0L uebergeben, d.h. nicht warten ?
 beq.b    psem_cset                ; ja
 moveq    #0,d2
 move.w   d1,d2
 divu     #20,d2                   ; ms -> 50Hz
 moveq    #0,d1
 move.w   d2,d1                    ; Hiword loeschen
 swap     d2
 tst.w    d2                       ; Rest bei Division ?
 beq.b    psem_sw                  ; nein
 addq.l   #1,d1                    ; aufrunden !
psem_sw:
 moveq    #SEM_SET,d0
psem__sw:

 jsr      evnt_sem
 tst.l    d0
 beq.b    psem_rts                 ; OK
 bgt.b    psem_eaccdn              ; Timeout (1) => EACCDN
 cmpi.w   #-2,d0
 beq      psem_erange              ; zerstoert (-2) => ERANGE
 rts
psem_eaccdn:
 moveq    #EACCDN,d0               ; 1L -> EACCDN Timout
psem_rts:
 rts

psem_cset:
 moveq    #SEM_CSET,d0             ; sofort zurueck, falls schon gesetzt!
 bra.b    psem__sw

psem_rel:
 moveq    #SEM_GET,d0
 jsr      evnt_sem
 tst.l    d0
 bmi      psem_erange              ; nicht gefunden
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 tst.l    d0
 bne.b    psem_eaccdn
 rts


**********************************************************************
*
* int/ PD * /APPL * srch_process( a0 = PD *pd, d0 = int pid )
*
* Gibt zu einer Basepage bzw. zu einer ProcessID die zugehoerige APPL
* in a0 und den zugehoerigen PD in a1 zurueck (falls vorhanden).
* d0 == -1     suche nach <pd>
* a0 == NULL   suche nach <pid>
*
* RUeckgabe:
* d0      ap_id, falls gefunden, sonst -1
* d1      Kindprozess (PD) oder NULL
* a0      APPL *
* a1      PD   *
*
* Beruecksichtigt auch Threads und Signalhandler
*

srch_process:
 movem.l  d5/d6/d7/a6,-(sp)
 move.w   d0,d6                    ; pid
 beq      pdad_err                 ; pid 0 ist ungueltig
 move.l   a0,a6
 move.l   xaes_appls,d0            ; XAES ?
 beq.b    pdad_err                 ; nein
 move.l   d0,a2
 cmpi.l   #'XAES',(a2)+            ; magische Kennung ?
 bne.b    pdad_err                 ; nein
 move.l   (a2)+,d0                 ; act_appl
 move.w   (a2)+,d5                 ; Offset fuer ap_pd
 addq.l   #2,a2                    ; Anzahl der APPLs unwichtig
 move.w   (a2)+,d7                 ; Tabellenlaenge
 moveq    #0,d0

pdad_applloop:
 move.l   (a2)+,d2
 beq.b    pdad_nxtappl             ; Slot unbelegt
 bclr     #31,d2                   ; eingefrorene APP auch behandeln!
 move.l   d2,a0                    ; APPL *
 move.l   0(a0,d5.w),a1            ; geretteter PD (=0?) der schlafenden APPL
 moveq    #0,d1                    ; kein Kindprozess
 bra.b    pdad_nxtpd

pdad_pdloop:
 cmpa.l   a1,a6
 beq.b    pdad_ende                ; gefunden, gib d0/a0/a1 zurueck
 cmp.w    p_procid(a1),d6
 beq.b    pdad_ende
 move.l   a1,d1                    ; d1 = Kindprozess

 cmpi.l   #'_PRG',p_res3(a1)       ; paralleler Prozess ?
 beq.b    pdad_nxtappl             ; ja, parent ist ungueltig

 move.l   p_parent(a1),a1
pdad_nxtpd:
 move.l   a1,d2
 bne.b    pdad_pdloop

pdad_nxtappl:
 addq.w   #1,d0
 cmp.w    d7,d0
 bcs      pdad_applloop
pdad_err:
 moveq    #-1,d0
pdad_ende:
 tst.w    d0
 movem.l  (sp)+,d5/d6/d7/a6
 rts


*********************************************************************
*
* int match_pid( d0 = int srch_pid, a0 = PD *srch_pd, a1 = PD *child )
*
* aendert nur d0/d1
* Testet, ob <child> durch <srch_pid> spezifiziert wurde.
* Rueckgabe 1, wenn ja, sonst 0
*

match_pid:
 tst.w    d0
 bmi.b    mpid_p3
 beq.b    mpid_p2
; pid > 0: pid direkt abfragen
 cmp.w    p_procid(a1),d0
 bra.b    mpid_ask
; pid == 0: gleiche pgrp gesucht
mpid_p2:
 move.w   p_procgroup(a0),d1       ; unsere Prozessgruppe
 cmp.w    p_procgroup(a1),d1
mpid_ask:
 beq.b    mpid_found
 moveq    #0,d0
 rts
mpid_p3:
 cmpi.w   #-1,d0                   ; jedes Kind gesucht ?
; pid == -1: Jedes Kind
 beq.b    mpid_found               ; ja, gefunden
; pid < -1: Prozessgruppe
 move.w   p_procgroup(a1),d1
 neg.w    d1
 cmp.w    d1,d0
 bra.b    mpid_ask
mpid_found:
 moveq    #1,d0
 rts


*********************************************************************
*
* long Pwaitpid( WORD pid, WORD flag, LONG *rusage )
*
* Wartet auf Beendigung oder Anhalten eines oder mehrerer Kinder.
*
* pid == -1:   Jedes Kind
* pid == 0:    Jedes Kind mit gleicher Prozessgruppe wie Aufrufer 
* pid > 0:     Ein spezielles Kind <pid>
* pid < -1:    Jedes Kind mit Prozessgruppe <-pid>
*
* flag & 1:    Warten (0) oder nicht warten (1)
* flag & 2:
*
* rusage:      Liefert unter MagiC nur Nullen
*
* Rueckgabe:    (pid<<16)|exitcode
*              EFILNF: keine Kinder da.
*

D_Pwaitpid:
 movem.l  a5/a4/d5/d6/d7,-(sp)
 move.w   (a0)+,d7                 ; d7 = pid
 move.l   a0,a4

; suche Kindprozess

 move.l   procx,a5
 move.l   act_pd,a0
 move.w   #N_PROCS-1,d5
 moveq    #0,d6                    ; noch kein passendes Kind gefunden
wpid_loop1:
 move.l   (a5)+,d1
 beq.b    wpid_nxtloop             ; Slot unbelegt
 move.l   d1,a1                    ; a1 = existierender Prozess
 cmpa.l   p_parent(a1),a0          ; ein Kind von uns ?
 bne.b    wpid_nxtloop             ; nein, weiter

; Kindprozess (a1) gefunden

;move.l   a1,a1                    ; child
;move.l   a0,a0                    ; PD *
 move.w   d7,d0                    ; Suchkriterium
 bsr.s    match_pid
 tst.w    d0
 beq.b    wpid_nxtloop

; Kindprozess passt

 moveq    #1,d6                    ; merken, dass passender existiert
 cmpi.w   #PROCSTATE_ZOMBIE,p_status(a1)     ; Kind terminiert ?
 beq.b    wpid_exit                          ; ja, a5 enthaelt das gesuchte

; naechster Tabelleneintrag

wpid_nxtloop:
 dbra     d5,wpid_loop1

; Schleifenende. Sollen wir warten ?

 moveq    #EFILNF,d0
 tst.w    d6                       ; gibt es ueberhaupt passende Kinder ?
 beq.b    wpid_ende                ; nein, es lohnt nicht zu warten
 moveq    #0,d0
 btst     #0,1(a4)                 ; warten ?
 bne.b    wpid_ende                ; nein, return(0L)

; Es gibt Kinder. Wir warten auf Terminierung.

 move.w   d7,d0
 jsr      evnt_pid                 ; warte auf Terminierung
 move.l   a0,a1

; Erfolg: a1 ist das gesuchte Kind
; Gib Daten zurueck und gib den PD frei

wpid_exit:
 move.l   2(a4),d0                 ; rusage ?
 beq.b    wpid_no_rusage
 move.l   d0,a0
 clr.l    (a0)+
 clr.l    (a0)                     ; rusage[0,1] = 0 (unbenutzt)
wpid_no_rusage:
 move.w   p_dta(a1),-(sp)          ; Exitcode ins Loword
 move.w   p_procid(a1),-(sp)       ; ProcId ins Hiword
 move.l   a1,-(sp)
 move.l   a1,a0                    ; PD holen
 bsr      delete_procname
 move.l   (sp)+,a0
 lea      ur_pd,a1                 ; neuer Eigner
;move.l   a0,a0
 bsr      Mfzombie                 ; PD freigeben
 move.l   (sp)+,d0

wpid_ende:
 movem.l  (sp)+,a5/a4/d7/d6/d5
 rts


*********************************************************************
*
* long D_Pwait3( WORD flag, LONG *rusage )
*
* => Pwaitpid(-1, flag, rusage)
*

D_Pwait3:
 move.l   2(a0),-(sp)
 move.w   (a0),-(sp)
 move.w   #-1,-(sp)
 move.l   sp,a0
 bsr      D_Pwaitpid
 addq.l   #8,sp
 rts


*********************************************************************
*
* long D_Pwait( void )
*
* => Pwaitpid(-1, 2, NULL)
*

D_Pwait:
 clr.l    -(sp)
 move.w   #2,-(sp)
 move.w   #-1,-(sp)
 move.l   sp,a0
 bsr      D_Pwaitpid
 addq.l   #8,sp
 rts


*********************************************************************
*
* long Psignal( int sig, long handler )
*
* handler = SIG_DFL (0L):     Default-Aktion wieder aktivieren
*           SIG_IGN (1L):     Signal komplett ignorieren
*           sonst:            Signalhandler aktivieren
*
* Wird zurueckgefuehrt auf Psigaction(sig, {handler,0L,0},...)
*
* zusaetzlich noch SIGFREEZE.
*

D_Psignal:
 move.w   (a0)+,d1
 move.l   (a0),d0
 cmpi.w   #SIGFREEZE,d1
 beq.b    psig_fr                  ; MagiC special
 clr.w    -(sp)                    ; Flags = 0
 clr.l    -(sp)                    ; sigmask = 0
 move.l   d0,-(sp)                 ; neuer Handler
 suba.w   #10,sp
 pea      (sp)                     ; Platz fuer alte Daten
 pea      10+4(sp)                 ; neue Daten
 move.w   d1,-(sp)                 ; sig
 move.l   sp,a0
 bsr.b    D_Psigaction
 tst.l    d0
 bmi.b    psig_ende
 move.l   10(sp),d0                ; alter Handler
psig_ende:
 adda.w   #30,sp
 rts
psig_fr:
 jmp      psig_freeze              ; => AES


*********************************************************************
*
* long Psigaction( WORD sig, struct sigaction *act,
*                   struct sigaction *oact )
*
*    struct sigaction {
*         LONG sa_handler;
*         LONG sa_mask;
*         WORD sa_flags;
*         };
*
* Installiert einen Signal-Handler
*

D_Psigaction:
 move.w   (a0)+,d0                 ; sig
 beq.b    psigac_err               ; 0: Fehler
 cmpi.w   #31,d0
 bhi.b    psigac_err               ; >31: Fehler
 cmpi.w   #SIGKILL,d0
 beq.b    psigac_tst
 cmpi.w   #SIGSTOP,d0
 bne.b    psigac_notst
psigac_tst:
 tst.l    (a0)
 bne.b    psigac_eaccdn            ; SIGKILL und SIGSTOP nicht aenderbar
psigac_notst:
 move.l   a6,-(sp)
 move.l   act_pd,a6
 move.l   p_procdata(a6),a6
 move.w   d0,d1
 mulu     #sa_sizeof,d1
 lea      pr_sigdata(a6,d1.w),a1
 move.l   4(a0),d1                 ; oact
 beq.b    psigac_noold

* alte Daten zurueckgeben

 move.l   d1,a2
 move.l   (a1)+,(a2)+              ; alter Handler
 move.l   (a1)+,(a2)+              ; alte Maske
 move.w   (a1),d1
 andi.w   #1,d1
 move.w   d1,(a2)                  ; alte Flags (nur Bit 0)
 subq.l   #8,a1                    ; a1 restaurieren
psigac_noold:

 move.l   (a0)+,d1                 ; act
 beq.b    psigac_ende              ; keine neue Aktion

* neue Daten setzen

 move.l   d1,a2
 move.l   (a2)+,d1
 move.l   d1,(a1)+                 ; neuer Handler
 subq.l   #1,d1                    ; SIG_IGN
 bne.b    psigac_noi
; ggf. "pending signal" loeschen
 move.l   pr_sigpending(a6),d1
 bclr     d0,d1
 move.l   d1,pr_sigpending(a6)
psigac_noi:
 move.l   (a2)+,(a1)+              ; neue Maske
 move.w   (a2),d1                  ; neue Flags
 bclr     #0,1(a1)
 or.w     d1,(a1)                  ; nur Bit 0 aendern
; zugeh. "signal mask bit" loeschen, d.h. Signal "enablen"
 move.l   pr_sigmask(a6),d1
 bclr     d0,d1
 move.l   d1,pr_sigmask(a6)
psigac_ende:
 moveq    #0,d0
 move.l   (sp)+,a6
 rts
psigac_eaccdn:
 moveq    #EACCDN,d0
 rts
psigac_err:
 moveq    #ERANGE,d0
 rts


*********************************************************************
*
* long Psigblock( long mask )
* long Psigsetmask( long mask )
*
* OR-t bzw. ersetzt die Signalmaske
*

D_Psigblock:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 lea      pr_sigmask(a1),a1
 move.l   (a1),d0                  ; alter Wert
 move.l   (a0),d1                  ; neuer Wert
 andi.l   #!UNMASKABLE,d1
 or.l     d1,(a1)                  ; neuen Wert setzen
 rts
D_Psigsetmask:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 lea      pr_sigmask(a1),a1
 move.l   (a1),d0                  ; alter Wert
 move.l   (a0),d1                  ; neuer Wert
 andi.l   #!UNMASKABLE,d1
 move.l   d1,(a1)                  ; neuen Wert setzen
 move.l   d0,-(sp)
 move.l   act_pd,a0                ; PD *
 jsr      do_signals               ; Signale bearbeiten (=> AES)
 move.l   (sp)+,d0
 rts


*********************************************************************
*
* long Psigreturn( void )
*
* Beendet die Signalbehandlung.
* Wenn die aktuelle Applikation kein Signalhandler ist, wird
* EACCDN geliefert.
*

D_Psigreturn:
 jmp      sigreturn                ; Thread umschalten (=> AES)


*********************************************************************
*
* long Psigpending( void )
*
* Gibt die noch nicht ausgelieferten Signale
* Bearbeitet vorher die Signale
*

D_Psigpending:
 move.l   act_pd,a0
 jsr      do_signals               ; Signale bearbeiten (=> AES)
 move.l   act_pd,a0
 move.l   p_procdata(a0),a0
 move.l   pr_sigpending(a0),d0
 rts


*********************************************************************
*
* long Pause( void )
*
* wie Psigpause, aber veraendert nicht die Signalmaske.
* MiNT testet hier _NICHT_, ob schon ein Signal anliegt.
*

D_Pause:
 moveq    #0,d0                         ; keine neue Maske
 bra.b    sigpause


*********************************************************************
*
* long Psigpause( long mask )
*
* Gibt die noch nicht ausgelieferten Signale
* Bearbeitet vorher die Signale
*

D_Psigpause:
 move.l   (a0),d0                       ; neue Maske
 moveq    #1,d1                         ; alte Maske retten
;bra.b    sigpause


*********************************************************************
*
* long sigpause( d0 = long mask, d1 = int setmask )
*
* Wenn <setmask> == TRUE, wird die Maske veraendert.
* fuer Pause() und Psigpause()
*

sigpause:
 movem.l  a6/d7,-(sp)
 move.w   d1,d7
 move.l   act_pd,a0
 move.l   p_procdata(a0),a6
 move.l   pr_sigmask(a6),d2             ; alte Signalmaske
 tst.w    d7                            ; umsetzen ?
 beq.b    sigp_nomask                   ; nein!
 move.l   d2,-(sp)                      ; alte Signalmaske retten
 andi.l   #!UNMASKABLE,d0               ; neue Maske korrigieren
 move.l   d0,pr_sigmask(a6)             ; neue Maske setzen
 move.l   d0,d2
sigp_nomask:
 not.l    d2
 and.l    pr_sigpending(a6),d2          ; liegen Signale an ?
 beq.b    sigp_wait                     ; nein

; es liegen gerade welche an: bearbeiten

 move.l   act_pd,a0
 jsr      do_signals               ; Signale bearbeiten (=> AES)
 bra.b    sigp_ende

; wir muessen auf Signale warten

sigp_wait:
 jsr      wait_signals             ; => AES

; Ende. Signalmaske restaurieren und nochmal checken

sigp_ende:
 tst.w    d7                       ; alte Maske gerettet ?
 beq.b    sigp_nix2                ; nein
 move.l   (sp)+,pr_sigmask(a6)     ; Maske zurueck
 move.l   act_pd,a0
 jsr      do_signals               ; Signale bearbeiten (=> AES)
sigp_nix2:
 moveq    #0,d0
 movem.l  (sp)+,a6/d7
 rts


*********************************************************************
*
* long _pkill( a0 = PD *pd, d0 = WORD sig )
*
* Schickt Signal <sig> an Prozess
*

_pkill:
 tst.w    d0                       ; Signalnummer
 beq.b    _pkill_ende              ; SIGNULL nicht ausliefern
 cmpi.w   #30,d0
 bhi.b    _pkill_erange            ; Signalnummer ungueltig
 move.l   p_procdata(a0),a2
; Signal ausliefern
 move.l   pr_sigpending(a2),d1
 bset.l   d0,d1
 move.l   d1,pr_sigpending(a2)
; Testen, ob der Prozess aktiv ist
;move.l   a0,a0                    ; PD *
 jsr      do_signals               ; Signale bearbeiten
_pkill_ende:
 moveq    #0,d0
 rts
_pkill_erange:
 moveq    #ERANGE,d0
 rts


*********************************************************************
*
* long Pkill( WORD pid, WORD sig )
*
* Schickt Signal <sig> an:
*
*  pid > 0     Prozess mit der angegebenen pid
*  pid = 0     alle Prozesse der Prozessgruppe des Aufrufers (inkl.)
*  pid < 0     an alle Prozesse mit der Gruppennummer (-pid).
*
* pid <= 0 beruecksichtigt seit MagiC 6.01 vom 10.10.98
*

D_Pkill:
 move.w   (a0)+,d0                 ; pid
 move.w   (a0),d1                  ; sig
Pkill:
 movem.l  a6/d7/d6/d5/d4/d3,-(sp)
 move.w   d1,d7                    ; d7 = sig
 move.l   act_pd,a0
 move.w   d0,d6                    ; d6 = pid
 bne.b    pkill_no0
 move.w   p_procgroup(a0),d6
 neg.w    d6                       ; pid = 0: aktuelle Prozessgruppe
pkill_no0:

; suche Prozess

 move.l   procx,a6
 move.w   #N_PROCS-1,d5
 sf       d4                       ; noch keinen gefunden
 sf       d3                       ; kein Selbst-Kill
pkill_loop1:
 move.l   (a6)+,d0
 beq.b    pkill_nxtloop            ; Slot unbelegt
 move.l   d0,a0                    ; a0 = existierender Prozess
 cmpi.w   #PROCSTATE_ZOMBIE,p_status(a0)
 beq.b    pkill_nxtloop            ; Zombie-Prozesse ignorieren

 move.w   d6,d0
 bmi.b    pkill_grp
 cmp.w    p_procid(a0),d0
 bne.b    pkill_nxtloop
 bra.b    pkill_kill

pkill_grp:
 neg.w    d0
 cmp.w    p_procgroup(a0),d0
 bne.b    pkill_nxtloop

; Prozess mit der PID bzw. der Prozessgruppen-Nummer gefunden
pkill_kill:
 st       d4                       ; merken, dass einer gefunden
 cmpa.l   act_pd,a0                ; selbst killen?
 bne.b    pkill_kill2              ; nein
 st       d3                       ; merken, dass selbst gekillt
 bra.b    pkill_nxtloop            ; spaeter nachholen
pkill_kill2:
 move.w   d7,d0                    ; sig
;move.l   a0,a0                    ; PD
 bsr.s    _pkill

; naechster Tabelleneintrag

pkill_nxtloop:
 dbra     d5,pkill_loop1

; Schleifenende.

 moveq    #EFILNF,d0
 tst.b    d4
 beq.b    pkill_ende               ; nicht gefunden
 moveq    #ERANGE,d0
 cmpi.w   #30,d7
 bhi.b    pkill_ende               ; Signalnummer ungueltig
 moveq    #0,d0
 tst.b    d3
 beq.b    pkill_ende
 move.w   d7,d0                    ; Signal
 move.l   act_pd,a0
 bsr      _pkill                   ; an sich selbst ausliefern
pkill_ende:
 movem.l  (sp)+,a6/d7/d6/d5/d4/d3
 rts


*********************************************************************
*
* long Pgetpid( void )
* long Pgetppid( void )
*
* Gibt die Prozssnummer des aktuellen Prozesses bzw. des parent
* zurueck.
* Im Gegensatz zu MiNT kann eine -1 auftreten, dann existiert kein
* parent.
*

D_Pgetpid:
 move.l   act_pd,a0
 bra.b    _getpid
D_Pgetppid:
 move.l   act_pd,a1
 move.l   p_parent(a1),a0
 move.l   a0,d0
 bne.b    _getpid
 moveq    #-1,d0
 rts
_getpid:
 moveq    #0,d0
 move.w   p_procid(a0),d0
 rts


*********************************************************************
*
* LONG Pgetpgrp( void )
*
* Gibt die Prozssgruppennummer des aktuellen Prozesses zurueck.
*
* ab MagiC 6.01 vom 9.10.98
*

D_Pgetpgrp:
 move.l   act_pd,a0
 moveq    #0,d0
 move.w   p_procgroup(a0),d0
 rts


*********************************************************************
*
* LONG Psetpgrp( WORD pid, WORD newgroup )
*
* Aendert die Prozessgruppennummer von Prozess <pid> (bzw. des aktuellen
* Prozesses, wenn <pid> = 0) bzw. gibt sie zurueck (wenn <newgroup> < 0).
* Wenn <newgroup> < 0 ist, wird die Prozess-ID als Prozessgruppennummer
* verwendet.
*
* ab MagiC 6.01 vom 9.10.98
*

D_Psetpgrp:
 move.w   (a0)+,d0                 ; pid
 bne.b    pspg_noact
 move.l   act_pd,a1                ; pid = 0: aktueller Prozess
 bra.b    pspg_weiter
pspg_noact:
 move.l   a0,-(sp)
;move.w   d0,d0
 suba.l   a0,a0
 bsr      srch_process             ; Prozess aus PID ermitteln => a1
 move.l   (sp)+,a0
 bmi.b    pspg_err
pspg_weiter:
 moveq    #0,d0                    ; auf unsigned long
 move.w   (a0)+,d0                 ; newgrp
 bmi.b    pspg_get                 ; < 0: nur ermitteln
 bne.b    pspg_set                 ; > 0: setzen
 move.w   p_procid(a1),d0          ; = 0: procid nehmen
pspg_set:
 move.w   d0,p_procgroup(a1)       ; Gruppe setzen
 rts
pspg_get:
 move.w   p_procgroup(a1),d0       ; newgrp < 0: Prozessgruppe ermitteln
 rts
pspg_err:
 moveq    #EFILNF,d0               ; PID ungueltig
 rts


*********************************************************************
*
* long Pgetuid( void )
*
* Gibt die "real user ID" des Prozesses zurueck.
*
* Seit 30.12.99
*

D_Pgetuid:
 moveq    #pr_ruid,d1
_getid:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 moveq    #0,d0
 move.w   0(a1,d1.w),d0
 rts


*********************************************************************
*
* long Pgetgid( void )
*
* Gibt die "real group ID" des Prozesses zurueck.
*
* Seit 30.12.99
*

D_Pgetgid:
 moveq    #pr_rgid,d1
 bra.b    _getid


*********************************************************************
*
* long Pgeteuid( void )
*
* Gibt die "effective user ID" des Prozesses zurueck.
*
* Seit 30.12.99
*

D_Pgeteuid:
 moveq    #pr_euid,d1
 bra.b    _getid


*********************************************************************
*
* long Pgetegid( void )
*
* Gibt die "effective group ID" des Prozesses zurueck.
*
* Seit 30.12.99
*

D_Pgetegid:
 moveq    #pr_egid,d1
 bra.b    _getid


*********************************************************************
*
* long Pgetauid( void )
*
* Gibt die "audit user ID" des Prozesses zurueck.
*
* Seit 30.12.99
*

D_Pgetauid:
 moveq    #pr_auid,d1
 bra.b    _getid


*********************************************************************
*
* LONG Psetuid( WORD uid )
*
* Setzt die "real user ID" des Prozesses.
*
* Seit 30.12.99
*

D_Psetuid:
 moveq    #pr_ruid,d1
_setid:
 moveq    #0,d0
 move.w   (a0),d0                  ; d0 = uid
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 move.w   pr_euid-pr_ruid(a1,d1.w),d0
 beq.b    setid_root               ; bin root, darf alles
 cmp.w    pr_ruid-pr_ruid(a1,d1.w),d0
 beq.b    setid_seteuid            ; gehoere demselben User
 cmp.w    pr_suid-pr_ruid(a1,d1.w),d0
 beq.b    setid_seteuid            ; gehoerte demselben User (?)
 moveq    #EACCDN,d0
 rts
setid_root:
 move.w   d0,pr_ruid-pr_ruid(a1,d1.w)
 move.w   d0,pr_suid-pr_ruid(a1,d1.w)
setid_seteuid:
 move.w   d0,pr_euid-pr_ruid(a1,d1.w)
 rts


*********************************************************************
*
* LONG Psetgid( WORD gid )
*
* Setzt die "real group ID" des Prozesses.
*
* Seit 30.12.99
*

D_Psetgid:
 moveq    #pr_rgid,d1
 bra.b    _setid


*********************************************************************
*
* LONG Psetreuid( WORD ruid, WORD euid )
*
* Setzt die "effective user ID" des Prozesses und laesst die
* "real user ID" unveraendert (?).
*
* Seit 30.12.99
*

Psetreuid:
 moveq    #pr_ruid,d1
_setreid:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 move.w   pr_ruid-pr_ruid(a1,d1.w),d2   ; old_ruid
 move.w   (a0),d0                       ; ruid
 cmpi.w   #-1,d0
 beq.b    _setreid_noruid
 cmp.w    d2,d0
 beq.b    _setreid_noruid     ; unveraendert

 ; ruid != -1

 cmp.w    pr_euid-pr_ruid(a1,d1.w),d0
 beq.b    _setreid_setr
 tst.w    pr_euid-pr_ruid(a1,d1.w)
 bne.b    _setreid_err        ; bin nicht root
_setreid_setr:
 move.w   d0,pr_ruid-pr_ruid(a1,d1.w)

_setreid_noruid:
 move.w   2(a0),d0
 cmpi.w   #-1,d0
 beq.b    _setreid_noeuid
 cmp.w    pr_euid-pr_ruid(a1,d1.w),d0
 beq.b    _setreid_noeuid     ; unveraendert
 cmp.w    d2,d0
 beq.b    _setreid_sete
 cmp.w    pr_suid-pr_ruid(a1,d1.w),d0
 beq.b    _setreid_sete
 tst.w    pr_euid-pr_ruid(a1,d1.w)
 bne.b    _setreid_err2       ; bin nicht root
_setreid_sete:
 move.w   d0,pr_euid-pr_ruid(a1,d1.w)

 ; euid != -1

_setreid_noeuid:
 cmpi.w   #-1,(a0)
 bne.b    _setreid_sets
 cmpi.w   #-1,d0
 beq.b    _setreid_ende
 cmp.w    d2,d0
 beq.b    _setreid_ende
_setreid_sets:
 move.w   d0,pr_suid-pr_ruid(a1,d1.w)   ; suid = euid
_setreid_ende:
 moveq    #0,d0
 rts
_setreid_err2:
 move.w   d2,pr_ruid-pr_ruid(a1,d1.w)   ; ruid restaurieren
_setreid_err:
 moveq    #EACCDN,d0
 rts


*********************************************************************
*
* LONG Psetregid( WORD rgid, WORD egid )
*
* Setzt die "effective group ID" des Prozesses und laesst die
* "real group ID" unveraendert (?).
*
* Seit 30.12.99
*

Psetregid:
 moveq    #pr_rgid,d1
 bra.b    _setreid


*********************************************************************
*
* LONG Pseteuid( WORD uid )
*
* Setzt die "effective user ID" des Prozesses.
*
* Seit 30.12.99
*

D_Pseteuid:
 lea      Psetreuid(pc),a1
_seteid:
 move.w   (a0),-(sp)
 move.w   #-1,-(sp)
 move.l   sp,a0
 jsr      (a1)
 tst.l    d0
 bne.b    seteuid_ende        ; EACCDN
 move.w   2(sp),d0            ; uid zurueckgeben
seteuid_ende:
 addq.l   #4,sp
 rts


*********************************************************************
*
* LONG Psetegid( WORD gid )
*
* Setzt die "effective group ID" des Prozesses.
*
* Seit 30.12.99
*

D_Psetegid:
 lea      Psetregid(pc),a1
 bra.b    _seteid


*********************************************************************
*
* LONG Psetauid( WORD uid )
*
* Setzt die "audit user ID" des Prozesses.
*
* Seit 30.12.99
*

D_Psetauid:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 move.w   pr_auid(a1),d0
 bne.b    setauid_err              ; ist schon gesetzt
 moveq    #0,d0
 move.w   (a0),d0
 move.w   d0,pr_auid(a1)           ; umsetzen und zurueckgeben
 rts
setauid_err:
 moveq    #EACCDN,d0
 rts


*********************************************************************
*
* LONG Prenice( WORD pid, WORD delta )
*
* Seit 2.1.2000
*

D_Prenice:
 move.w   (a0)+,d0                 ; pid
 move.l   a0,-(sp)
 suba.l   a0,a0
 bsr      srch_process             ; Prozess aus PID ermitteln => a1
 move.l   (sp)+,a0
 bmi.b    prnic_err
 move.l   p_procdata(a1),a1
 moveq    #0,d0
 move.w   pr_pri(a1),d0            ; alte Prioritaet
 add.w    (a0),d0                  ; delta addieren
 cmpi.w   #20,d0                   ; Resultat auf -20..20 begrenzen
 bgt.b    prnic_20
 cmpi.w   #-20,d0
 bge.b    prnic_ok
 move.w   #-20,d0
 bra.b    prnic_ok
prnic_20:
 moveq    #20,d0
prnic_ok:
 move.w   d0,pr_pri(a1)            ; Prioritaet umsetzen
 rts
prnic_err:
 moveq    #EFILNF,d0               ; PID ungueltig
 rts


*********************************************************************
*
* LONG Pnice( WORD delta )
*
* Seit 2.1.2000
*

D_Pnice:
 move.w   (a0),-(sp)               ; delta
 move.l   act_pd,a1
 move.w   p_procid(a1),-(sp)
 move.l   sp,a0
 bsr.s    D_Prenice
 addq.l   #4,sp
 rts


*********************************************************************
*
* long Pdomain( WORD dom )
*
* Setzt die Domain des aufrufenden Prozesses auf
*
*    dom = 0   TOS
*    dom = 1   MiNT
*
*    weitere Werte sind reserviert.
*

D_Pdomain:
 move.l   act_pd,a1
 moveq    #0,d0
 lea      p_flags(a1),a1
 move.b   (a1),d0
 andi.b   #1,d0               ; alten Wert holen, auf LONG erweit.
 move.w   (a0),d1             ; neuer Wert
 bmi.b    pdom_ende           ; ... ist negativ, nur alten liefern
 cmpi.w   #1,d1
 bhi.b    pdom_erange         ; ... ist ungueltig, nicht 0 oder 1
 andi.b   #$fe,(a1)
 or.b     d1,(a1)             ; nur Bit 0 modifizieren
pdom_ende:
 rts
pdom_erange:
 moveq    #ERANGE,d0
 rts


*********************************************************************
*
* long Pumask( WORD mask )
*
* Setzt die Dateimodi-Maske fuer zu erstellende Dateien.
* Gibt den alten Wert zurueck.
*

D_Pumask:
 move.l   act_pd,a1
 moveq    #0,d0
 move.w   p_umask(a1),d0      ; alten Wert zurueckgeben
 move.w   (a0),d1             ; neuer Wert
 andi.w   #$fff,d1            ; Dateimodi isolieren "sssrwxrwxrwx"
 move.w   d1,p_umask(a1)      ; neuen Wert setzen
 rts


*********************************************************************
*
* long Pusrval( LONG val )
*
* Setzt bzw. gibt zurueck (wenn val == -1) einen benutzerdefinierten
* Wert.
* Gibt den alten Wert zurueck.
*

D_Pusrval:
 move.l   act_pd,a1
 move.l   p_procdata(a1),a1
 move.l   pr_usrval(a1),d0
 move.l   (a0),d1
 addq.l   #1,d1
 beq.b    pusrval_ende
 subq.l   #1,d1
 move.l   d1,pr_usrval(a1)
pusrval_ende:
 rts


*********************************************************************
*
* void fnam2pnam( a0 = char *fnam, a1 = char *pnam )
*
* Macht aus einem Datei- einen Prozessnamen
* aendert nicht a2
*

fnam2pnam:
 moveq    #8-1,d1                  ; max. 8 Zeichen
f2p_loop:
 move.b   (a0)+,d0
 beq.b    f2p_endloop
 cmpi.b   #'.',d0
 beq.b    f2p_endloop
 cmpi.b   #' ',d0
 beq.b    f2p_loop
 move.b   d0,(a1)+
 dbra     d1,f2p_loop
f2p_endloop:
 clr.b    (a1)
 rts


*********************************************************************
*
* void create_procname( a0 = PD * pd )
*
* vergibt eine Prozessnummer und initialisiert, wenn nicht schon
*  getan, pd->procdata->pr_procname.
* erstellt in u:\proc\ einen Dateinamen.
*

create_procname:
 movem.l  a5/a6,-(sp)
 move.l   a0,a6                    ; a6 = pd
 suba.w   #40,sp

; suche freien Prozess-Slot

 move.l   procx,a1
 move.w   #N_PROCS-1,d0
cpn_loop1:
 tst.l    (a1)+
 dbeq     d0,cpn_loop1
 bne      dos_fatal_err            ; kein freier Slot (?!?)

; suche unbelegte ProcId, falls noch keine eingetragen

 tst.w    p_procid(a6)             ; schon eine eingetragen?
 bgt.b    cpn_isprocid

 move.w   nxt_procid,d1            ; versuche es mal damit
cpn_again:
 move.l   procx,a0
 move.w   #N_PROCS-1,d0
 addq.w   #1,d1
 cmpi.w   #1000,d1
 bcs.b    cpn_loop3
 moveq    #1,d1                    ; wrapping !
cpn_loop3:
 move.l   (a0)+,d2
 beq.b    cpn_nxtloop3             ; Slot unbelegt
 move.l   d2,a2                    ; PD
 cmp.w    p_procid(a2),d1          ; unsere ID ?
 beq.b    cpn_again                ; ja, Kollision!
cpn_nxtloop3:
 dbra     d0,cpn_loop3

 move.w   d1,p_procid(a6)          ; ID eintragen
 move.w   d1,nxt_procid            ; und dort das naechste Mal weitersuchen

cpn_isprocid:
 move.l   a6,-(a1)                 ; Slot als belegt markieren
; ermittle Prozessnamen
 move.l   p_procdata(a6),a5        ; a5 = PROCDATA
 btst     #0,pr_flags+1(a5)        ; kein Eintrag in u:\proc ?
 bne.b    cpn_ende                 ; nein, Ende

 lea      pr_procname(a5),a5       ; a5 = pr_procname
 tst.b    (a5)                     ; schon ein Name angegeben ?
 bne.b    cpn_crname               ; ja

* Name von der geladenen Programmdatei holen

 move.l   p_procdata(a6),a0
 lea      pr_fname(a0),a0
 tst.b    (a0)
 beq.b    cpn_no_fname
 jsr      fn_name                  ; Pfad abtrennen
 bra.b    cpn_okname
cpn_no_fname:
 lea      noname_s(pc),a0
cpn_okname:
 move.l   a5,a1
;move.l   a0,a0
 bsr      fnam2pnam

* In a5 steht jetzt der Name

cpn_crname:
 moveq    #0,d1
 move.w   p_procid(a6),d1
 lea      (sp),a0
; Pseudo- Dateinamen zusammensetzen
 move.l   #$553a5c50,(a0)+
 move.l   #$524f435c,(a0)+
cpn_loop2:
 move.b   (a5)+,(a0)+
 bne.b    cpn_loop2
 subq.l   #1,a0
 move.b   #'.',(a0)+
 divu     #100,d1
 add.b    #'0',d1
 move.b   d1,(a0)+
 clr.w    d1
 swap     d1
 divu     #10,d1
 add.b    #'0',d1
 move.b   d1,(a0)+
 swap     d1
 add.b    #'0',d1
 move.b   d1,(a0)+
 clr.b    (a0)

 move.l   a6,a1                    ; PD
 lea      (sp),a0                  ; name
;move.w   #PROC_CREATE,d0
 move.w   #MX_INT_CREATEPROC,d0
 bsr      Dcntl

cpn_ende:
 adda.w   #40,sp
 movem.l  (sp)+,a5/a6
 rts


*********************************************************************
*
* void delete_procname( a0 = PD * pd )
*
* loescht einen Prozess aus der Tabelle procx[] und entfernt aus
* in u:\proc\ den zugehoerigen Dateinamen.
*

delete_procname:
 suba.w   #40,sp
; suche meinen Prozess-Slot
 move.l   procx,a1
 move.w   #N_PROCS-1,d0
dpn_loop1:
 cmpa.l   (a1)+,a0
 dbeq     d0,dpn_loop1
 bne.b    dpn_noslot               ; nicht eingetragen (?!?)
 clr.l    -(a1)
; Prozessnamen loeschen
dpn_noslot:
 moveq    #0,d1
 move.w   p_procid(a0),d1
 beq.b    dpn_ende
 clr.w    p_procid(a0)             ; wichtig, damit Fdelete nicht PDkillt
 lea      (sp),a2
 move.l   #$553a5c50,(a2)+
 move.l   #$524f435c,(a2)+
 move.w   #$2a2e,(a2)+             ; erstelle Dateinamen *.nnn
 divu     #100,d1
 add.b    #'0',d1
 move.b   d1,(a2)+
 clr.w    d1
 swap     d1
 divu     #10,d1
 add.b    #'0',d1
 move.b   d1,(a2)+
 swap     d1
 add.b    #'0',d1
 move.b   d1,(a2)+
 clr.b    (a2)
 lea      (sp),a0
 move.l   a0,-(sp)
 move.l   sp,a0
 bsr      D_Fdelete
 addq.l   #4,sp
dpn_ende:
 adda.w   #40,sp
 rts


**********************************************************************
*
* long Ptermres(long size, int exitcode)
*
* nur optimiert
*

D_Ptermres:
 move.w   4(a0),-(sp)              ; exitcode

 move.l   (a0),d0                  ; size
 move.l   act_pd,a0
 bsr      Mshrink

 jsr      secb_ext                 ; erweitere Pufferliste ?

 move.w   (sp)+,d0                 ; exitcode
 moveq    #0,d1                    ; Speicher nicht freigeben
 bra.b    Pterm


**********************************************************************
*
* Pterm0()
*

Pterm0:
 moveq    #1,d1                    ; Speicher freigeben
 moveq    #0,d0                    ; Rueckgabewert 0
 bra.b    Pterm


**********************************************************************
*
* long Pterm(d0 = int exitcode, d1 = int freemem)
*
* Speicher freigeben, wenn <freemem> = 1
*

D_Pterm:
 move.w   (a0),d0
 moveq    #1,d1
Pterm:

     DEB  'Pterm'

 move.l   act_pd,a1
 move.l   p_app(a1),d2             ; Parent-Thread
 beq.b    pterm_pterm              ; ist ungueltig, terminieren!
 cmp.l    act_appl.l,d2              ; habe ich ueberhaupt Pexec-t ?
 beq.b    pterm_pterm              ; Ja!

* Ich bin ein Thread, der den aktuellen Prozess nicht gestartet hat.
* Daher darf ich ihn auch nicht beenden.
* Daher beende ich mich. RUeckgabewert ist immer EBREAK.

 jmp      appl_break

pterm_pterm:
 move.w   d1,-(sp)                 ; Speicher freigeben ?
 move.w   d0,-(sp)
 clr.l    -(sp)                    ; Dummy- RUecksprungadresse

 link     a6,#0                    ; fuer T. Tempelmann ("TT" ?), der sich
                                   ;    offenbar selbst fuer den King of Atari
                                   ;    haelt, dazu ausersehen, Standards zu
                                   ;    deklarieren.
 moveq    #-1,d0
 move.l   d0,-(sp)
 move.l   #$50102,-(sp)            ; bios Setexc
 trap     #$d
 addq.w   #8,sp
 move.l   d0,a0
 jsr      (a0)                     ; springe ueber etv_term
 bsr      restore_time

* das VDI aufraeumen!

 move.l   (config_status+12).w,d0
 beq.b    ptm_no_v_tidy
 move.l   d0,a2
 lea      Mfree(pc),a1             ; a1 = Mfree()
 movea.l  act_pd,a0                ; a0 = PD *
 moveq    #0,d0                    ; d0 = Funktionsnummer 0
 jsr      (a2)

ptm_no_v_tidy:
 move.l   act_pd,a0
 cmpi.l   #'_PRG',p_res3(a0)
 bne.b    ptm_no_prg

* paralleler Prozess terminiert.

 move.l   p_res3+4(a0),p_context(a0)    ; ssp fuer Ruecksprung setzen
 move.w   8(a6),p_dta(a0)               ; Rueckgabewert in Basepage merken!
 bra.b    ptm_sigrestart                ; Prozess noch nicht killen!

ptm_no_prg:
 move.l   p_parent(a0),d0               ; parent gueltig?
 bne.b    ptm_noacc                     ; ja, kein ACC

* Parent ungueltig, d.h. ACC terminiert

 cmpi.l   #'_ACC',p_res3(a0)
 bne      dos_fatal_err
 move.l   p_res3+4(a0),p_context(a0)    ; ssp fuer Ruecksprung setzen
 bra.b    ptm_restart                   ; Prozess noch nicht killen!

ptm_noacc:
 move.l   d0,act_pd
 move.l   act_appl.l,d0
 beq.b    ptm_noap
 move.l   d0,a1
 move.l   act_pd,ap_pd(a1)         ; in Applikationsstruktur eintragen
ptm_noap:
 move.w   8(a6),p_dta(a0)          ; Rueckgabewert in Basepage merken!
 move.w   10(a6),d0                ; Speicher freigeben
;move.l   a0,a0
 bsr.s    PDkill

ptm_sigrestart:
 move.l   act_pd,a0
 jsr      do_signals               ; evtl. warten Signale auf uns

ptm_restart:
 moveq    #0,d0
 move.w   8(a6),d0                 ; unsigned int

     DEB  'END Pterm'

 bra      start_proc


**********************************************************************
*
* void adjust_parents( a0 = PD *old_process, a1 = PD *new_process )
*
* Ein Prozess <old_process> wird durch einen neuen Prozess
* <new_process> ersetzt (OVERLAY) bzw. entfernt (new_process == NULL).
* Von allen Prozessen wird der Parent-Zeiger (p_parent) entsprechend
* korrigiert. Ggf. werden Zombie-Kinder entfernt (wenn new_process
* == NULL).
*

adjust_parents:
 movem.l  d7/a3/a4/a5/a6,-(sp)
 move.l   a0,a5                    ; a5 := old_process
 move.l   a1,a6                    ; a6 := new_process

 move.l   procx,a4
 move.w   #N_PROCS-1,d7
adjp_loop1:
 move.l   (a4)+,d0                 ; (PD *) holen
 beq.b    adjp_nxt1                ; Slot unbelegt
 move.l   d0,a3
 cmpa.l   p_parent(a3),a5          ; sind wir parent ?
 bne.b    adjp_nxt1                ; nein
 move.l   a6,p_parent(a3)          ; parent aendern (Kind wird ggf. Waise)
 bne.b    adjp_nxt1                ; neuer parent gueltig
 cmpi.w   #PROCSTATE_ZOMBIE,p_status(a3)
 bne.b    adjp_nxt1
 move.l   a3,a0
 bsr      delete_procname          ; Prozessnamen entfernen
 lea      ur_pd,a1                 ; neuer Eigner
 move.l   a3,a0
 bsr      Mfzombie                 ; PD freigeben
adjp_nxt1:
 dbra     d7,adjp_loop1
 movem.l  (sp)+,a5/a6/a4/a3/d7
 rts


**********************************************************************
*
* void PDkill(a0 = PD *process, d0 = int freemem)
*
* entfernt einen Prozess (FCBs, MDs, Pfadhandles).
* Entfernt alle zugehoerigen Threads ausser der aktuellen Applikation.
* Laesst den Speicher unangetastet, falls <freemem> = 0
*
* MagiC 5.04:  Loescht den Prozessnamen in u:\proc noch nicht und
*              behaelt die Basepage in procx[], falls der Prozess
*              mit MiNT-Funktionen (Pexec(100/104/106)) erzeugt
*              worden ist.
*

PDkill:

;    DEB  'PDkill'

 movem.l  d6/a4/a5,-(sp)
 move.w   d0,-(sp)                 ; Flag merken
 move.l   a0,a5                    ; a5 = PD *
* Shared Libraries freigeben
 move.l   a5,a0
 bsr      slb_close_all
* SIGCHLD verschicken
 move.l   p_parent(a5),d0          ; unser Parent
 beq.b    pdk_no_sigchld           ; ... ist schon ungueltig
 move.l   d0,a1
 move.w   p_procid(a1),d0          ; pid
 moveq    #SIGCHLD,d1
 bsr      Pkill
pdk_no_sigchld:
 move.l   a5,a0
 jsr      hap_fork                 ; ggf. wartenden Parent aufwecken
* <p_parent> aller Kinder auf NULL setzen
* Zombie-Kinder entfernen
 suba.l   a1,a1                    ; new_pd
 move.l   a5,a0                    ; old_pd
 bsr.s    adjust_parents
* Threads entfernen
 move.l   act_appl.l,d0
 beq.b    pk_no_aes
 move.l   a5,a0
 jsr      pkill_threads            ; alle Threads ausser aktueller APP killen
pk_no_aes:
* Sprung ueber config_status+24
 move.l   (config_status+24).w,d0
 beq.b    pk_no_tidy
 move.l   d0,a2
 move.l   a5,a0                    ; PD *
 jsr      (a2)
pk_no_tidy:
* ggf. Writeback abschalten
 cmpa.l   bufl_wback,a5
 bne.b    pk_nowb
 clr.l    bufl_wback
 bsr      Ssync                    ; alle Dateisysteme synchronisieren
pk_nowb:
* ggf. in Zombie wandeln
 cmpi.w   #PROCSTATE_MINT,p_status(a5)
 bne.b    pk_kill                  ; alles OK, killen
 move.l   a5,a0
 jsr      hap_pid                  ; => AES (parent aufwecken)
 tst.w    d0
 beq.b    pk_kill                  ; kein Problem, kann mich beenden
 lea      ur_pd,a1
 move.l   a5,a0
 bsr      Mzombie                  ; In ZOMBIE wandeln
 move.w   #PROCSTATE_ZOMBIE,p_status(a5)
 bra.b    pk_nokillpd
pk_kill:
* Prozessnamen entfernen und aus procx[] entfernen
 move.l   a5,a0
 bsr      delete_procname
pk_nokillpd:
* LOCKs entfernen
 move.l   a5,a0
 bsr      kill_locks
 
* Alle Dateien schliessen

 moveq    #MAX_OPEN-MIN_FHANDLE-1,d6    ; dbra- Zaehler
 move.l   p_procdata(a5),a0
 lea      fh_sizeof*MIN_FHANDLE+pr_handle(a0),a4
pk_fclose_loop:
 move.l   (a4),d0                       ; FD holen
 beq.b    pk_fclose_nxtloop             ; ist leer
 clr.l    (a4)                          ; nur sicherheitshalber!
 move.l   d0,a0
 move.l   fd_dev(a0),a2
 move.l   dev_close(a2),a2
;move.l   a0,a0
 jsr      (a2)                          ; flush/ggf. freigeben
pk_fclose_nxtloop:
 addq.l   #fh_sizeof,a4
 dbra     d6,pk_fclose_loop

* Alle Pfadhandles loeschen

 moveq    #LASTDRIVE,d6            ; dbra- Zaehler
 lea      pathcntx,a4
pkx_stdpthloop:
 move.b   p_drvx(a5,d6.w),d0
 ext.w    d0
 ble.b    pkx_nxtstdpth            ; root oder ungueltig
 tst.b    0(a4,d0.w)               ; eigentlich nicht noetig
 beq.b    pkx_nxtstdpth
 subq.b   #1,0(a4,d0.w)
 move.w   d0,a0
 add.w    a0,a0
 add.w    a0,a0
 move.l   pathx(a0),a0
 subq.w   #1,dd_refcnt(a0)         ; Referenzzaehler im DD ebenfalls dekrem.
 bne.b    pkx_nxtstdpth            ; noch nicht auf 0

;move.l   a0,a0                    ; Zeiger auf DD uebergeben
 move.l   dd_dmd(a0),a2
 move.l   d_xfs(a2),a2
 move.l   xfs_freeDD(a2),a2
 jsr      (a2)                     ; DD freigeben

pkx_nxtstdpth:
 dbra     d6,pkx_stdpthloop

* Alle XFSs benachrichtigen

 lea      dmdx,a4
pkx_loop:
 move.l   (a4)+,d0
 beq.b    pkx_next                 ; Laufwerk nicht bekannt
 move.l   d0,a0
 move.l   d_xfs(a0),a2
 move.l   xfs_pterm(a2),a2
 move.l   a5,a1
 jsr      (a2)
pkx_next:
 cmpa.l   #dmdx+4*LASTDRIVE,a4
 bls.b    pkx_loop

* Alle zum Prozess gehoerigen Semaphoren freigeben

 move.l   a5,a0
 moveq    #SEM_FPD,d0
 jsr      evnt_sem


 move.w   (sp)+,d0
 bne.b    pk_pfree                 ; Bloecke freigeben

/*
* Speicherbloecke nicht freigeben, aber ggf. p_procdata loeschen

 move.l   p_procdata(a5),d0
 beq.b    pk_ende                  ; ist schon leer
 move.l   d0,a0
 move.l   pr_memlist(a0),d0        ; shared memory?
 bne.b    pk_ende                  ; ja, darf PROCDATA nicht freigeben
 clr.l    p_procdata(a5)           ; muss Zeiger fuer spaeteres Pfree loeschen,
                                   ; da Ptermres() PROCDATA freigibt
*/
 bra.b    pk_ende

* Alle Speicherbloecke freigeben

pk_pfree:
 move.l   a5,a0
 bsr      Pfree

pk_ende:
 movem.l  (sp)+,a5/a4/d6

;    DEB  'END PDkill'

 rts


**********************************************************************
*
* void swap_paths( void )
*
* Pfadhandles zwischen aktuellem Prozess und seinem parent vertauschen.
* Benoetigt vom AES fuer den Single mode.
*

swap_paths:
 move.l   act_pd,a1
 move.l   p_parent(a1),a0
 move.b   p_defdrv(a1),p_defdrv(a0)     ; Standardlaufwerk kopieren
 lea      p_drvx(a1),a1                 ; Standardhandles
 lea      p_drvx(a0),a0
 moveq    #3,d1                         ; 4 * 4 Pfade
swpth_loop:
 move.l   (a1),d0
 move.l   (a0),(a1)+
 move.l   d0,(a0)+
 dbra     d1,swpth_loop
 rts


**********************************************************************
*
* void init_stdfiles(a0 = PD *basepage)
*
* Setzt die Standarddateien fuer den Ur-Prozess.
*

init_stdfiles:
 move.l   p_procdata(a0),a0
 lea      pr_hndm4(a0),a0               ; Beginne bei Handle -4
 lea      dev_fds,a1
 moveq    #-MIN_FHANDLE-1,d0
istdf_loop:
 move.l   (a1)+,(a0)+                   ; FD
 clr.w    (a0)+                         ; fh_flag = 0 (vererben)
 dbra     d0,istdf_loop
 move.l   dev_fds+12,a2                 ; Handle 0: -1
 bsr.b    _isdf
 move.l   dev_fds+12,a2                 ; Handle 1: -1
 bsr.b    _isdf
 move.l   dev_fds+8,a2                  ; Handle 2: -2
 bsr.b    _isdf
 move.l   dev_fds+4,a2                  ; Handle 3: -3
 bsr.b    _isdf
 move.l   dev_fds+12,a2                 ; Handle 4: -1
 bsr.b    _isdf
 move.l   dev_fds+12,a2                 ; Handle 5: -1
_isdf:
 cmpi.w   #-1,fd_refcnt(a2)
 beq.b    istdf_noinc
 addq.w   #1,fd_refcnt(a2)
istdf_noinc:
 move.l   a2,(a0)+
 clr.w    (a0)+                         ; fh_flag = 0 (vererben)
 rts


**********************************************************************
*
* void init_pd(a0 = PD *basepage, a1 = PD *parent)
*
* Pfad- und Standard- Datei- Handles vom aktuellen Prozess kopieren.
* Signale vererben (PROCDATA).
* Prozessnamen in u:\proc erstellen.
*
* 2.12.95:     Ungueltige Standardpfade werden nicht mit kopiert.
*              Der Prozess landet automatisch in der root.
* 22.9.96:     Umask vererben.
* 6.10.96:     procgroup vererben
*

init_pd:
 movem.l  a5/a4/d7/d6,-(sp)
 move.w   p_umask(a1),p_umask(a0)            ; Umask vererben
 move.w   p_procgroup(a1),p_procgroup(a0)    ; Prozessgruppe vererben
 move.l   a1,a5                    ; von
 move.l   a0,a4                    ; nach

* Dateihandles kopieren

 moveq    #MAX_OPEN-MIN_FHANDLE-1,d7    ; dbra- Zaehler
 move.l   p_procdata(a5),a1
 lea      fh_sizeof*MIN_FHANDLE+pr_handle(a1),a1
 move.l   p_procdata(a4),a0
 btst     #1,pr_flags+1(a0)             ; Pfork() ?
 sne      d6
 lea      fh_sizeof*MIN_FHANDLE+pr_handle(a0),a0
seth_hdlloop:
 move.l   (a1),d0                  ; FD holen
 beq.b    seth_hdlnxt              ; Handle unbenutzt
 move.l   d0,a2
 btst.b   #BOM_NOINHERIT,fd_mode+1(a2)
 bne.b    seth_hdlnxt              ; nicht vererben
 tst.b    d6                       ; Pfork()?
 bne.b    seth_fork                ; ja, immer vererben
 btst     #0,fh_flag+1(a1)         ; FD_CLOEXEC?
 bne.b    seth_hdlnxt              ; ja, nicht vererben
seth_fork:
; vererben
 cmpi.w   #-1,fd_refcnt(a2)
 beq.b    seth_hdlnofcb
 addq.w   #1,fd_refcnt(a2)
seth_hdlnofcb:
 move.l   a2,(a0)                  ; Handle kopieren
 move.w   fh_flag(a1),fh_flag(a0)  ; Flag kopieren
seth_hdlnxt:
 addq.l   #fh_sizeof,a0
 addq.l   #fh_sizeof,a1
 dbra     d7,seth_hdlloop

* Standard- Pfad- Handles kopieren

 moveq    #LASTDRIVE,d7            ; dbra- Zaehler
 lea      pathcntx,a0
 lea      pathx,a1
 moveq    #0,d0                    ; Hibyte loeschen
seth_pthloop:
 move.b   p_drvx(a5,d7.w),d0
 bge.b    seth_valid
 moveq    #0,d0                    ; ungueltig => root
seth_valid:
 move.b   d0,p_drvx(a4,d7.w)       ; Pfadhandle setzen
 beq.b    seth_pthnxt              ; Handle root
 ext.w    d0
 addq.b   #1,0(a0,d0.w)            ; Referenzzaehler erhoehen
 add.w    d0,d0
 add.w    d0,d0
 move.l   0(a1,d0.w),a2
 addq.w   #1,dd_refcnt(a2)         ; Referenzzaehler im DD erhoehen
seth_pthnxt:
 dbra     d7,seth_pthloop
* Standard- Laufwerk kopieren
 move.b   p_defdrv(a5),p_defdrv(a4)

* PROCDATA von anderem Prozess vererben
* sigmask und sigpending sind 0, alle Signale mit SIG_IGN bleiben so,
* alle anderen werden SIG_DFL
* MiNT vererbt sigextra und sigflags bei den ignorierten Signalen,
* das ergibt jedoch keinen Sinn und wird nicht so uebernommen
*

 move.l   p_procdata(a5),a1        ; parent
 move.l   p_procdata(a4),a0        ; child

 move.l   #'Proc',pr_magic(a0)
 move.l   pr_usrval(a1),pr_usrval(a0)        ; User-Wert vererben
 move.l   pr_ruid(a1),pr_ruid(a0)            ; ruid und rgid
 move.l   pr_euid(a1),pr_euid(a0)            ; euid und egid
 move.l   pr_suid(a1),pr_suid(a0)            ; suid und sgid
 move.w   pr_auid(a1),pr_auid(a0)
 move.w   pr_pri(a1),pr_pri(a0)

 lea      pr_sigdata(a0),a0
 lea      pr_sigdata(a1),a1
 moveq    #32-1,d1                 ; Zaehler
pxc_siginh_loop:
 move.l   (a1),d0                  ; handler
 subq.l   #SIG_IGN,d0
 bne.b    pxc_sig_set0             ; default bleibt default, action=>default
; zu ignorierende Signale vererben
 addq.l   #1,(a0)                  ; sa_handler = SIG_IGN
pxc_sig_set0:
 lea      sa_sizeof(a0),a0
 lea      sa_sizeof(a1),a1
 dbra     d1,pxc_siginh_loop       ; naechstes Signal

* Prozessnamen erstellen

 move.l   a4,a0
 bsr      create_procname

 movem.l  (sp)+,a5/a4/d7/d6
 rts


**********************************************************************
*
* a0 = XDEF char *env_end( a0 = char *env )
*
* a0 hinter das letzte Nullbyte des Environments
* d0 = Laenge des Env
* aendert nicht d1/d2
*

env_end:
 move.l   a0,a1
eev_loop:
 tst.b    (a0)+
 bne.b    eev_loop                  ; Variable ueberlesen
 tst.b    (a0)
 bne.b    eev_loop
 addq.l   #1,a0
 move.l   a0,d0
 sub.l    a1,d0
 rts


**********************************************************************
*
* d0 = char *env_get(a0 = char *env, a1 = char *var)
*
* var ist etwa "_PNAM="
*
*  Prueft, ob die Variable <var> im environment existiert
*  Rueckgabe: Zeiger auf den WERT der Variablen (im Env.) oder NULL
*  Rueckgabe: a0 = Zeiger auf die Variable selbst
*  Z-Flag korrekt beeinflusst
*

env_get:
 move.l   a5,-(sp)
 move.l   a0,a5                    ; a5 = env
 move.l   a1,a2                    ; a2 = var
 move.l   a1,a0
 bsr      strlen
 move.w   d0,d2
 bra.b    getenv_3
getenv_loop:
 move.w   d2,d0
 move.l   a2,a1
 move.l   a5,a0
 bsr      strncmp
 bne.b    getenv_next
* gefunden!
 move.l   a5,a0                    * Rueckgabe: Variable
getenv_4:
 tst.b    (a5)
 beq.b    getenv_90
 cmpi.b   #'=',(a5)+
 bne.b    getenv_4
 move.l   a5,d0                    * Rueckgabe: Wert
 bra.b    getenv_end
getenv_next:
 tst.b    (a5)+
 bne.b    getenv_next
getenv_3:
 tst.b    (a5)
 bne.b    getenv_loop
getenv_90:
 moveq    #0,d0
getenv_end:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void env_clr_int(a0 = char *env)
*
* Loescht die Variablen LINES,COLUMNS
* Wird vom AES aufgerufen
*

env_clr_int:
 move.l   a0,-(sp)
 lea      lines_s(pc),a1
 bsr.b    env_clr
 lea      columns_s(pc),a1
 move.l   (sp)+,a0
;bra      env_clr


**********************************************************************
*
* void env_clr(a0 = char *env, a1 = char *s)
*

env_clr:
 bsr.b    env_get
 beq.b    cev_ende
; Variable ueberlesen
 move.l   a0,a1
envset_8:
 tst.b    (a0)+
 bne.b    envset_8    * a0 auf erstes Zeichen hinter dem Eintrag

envset_10:
 move.b   (a0)+,(a1)+
 bne.b    envset_10
 tst.b    (a0)
 bne.b    envset_10   * Lasse Rest des Environments aufruecken
 clr.b    (a1)           * Am Ende wieder doppelte Null erzeugen
cev_ende:
 rts


**********************************************************************
*
* void env_set(a0 = char *env, a1 = char *var, a2 = char *val)
*
* var ist etwa "_PNAM="
* val ist etwa "C:\MIST"
*

env_set:
 movem.l  a0/a1/a2,-(sp)
 move.l   a1,a0
 bsr      strlen

 move.w   d0,d2
 move.l   a2,a0
 bsr      strlen
 add.w    d0,d2
 addq.w   #1,d2               ; EOS ergaenzen
 move.l   (sp),a0
 bsr      env_end             ; d0 = Env.-Laenge, aendert nicht d2

 move.l   (sp),a1             ; src
 lea      0(a1,d2.w),a0       ; dst
;move.w   d0,d0
 jsr      vmemcpy              ; Environment verschieben

 movem.l  (sp)+,a0/a1/a2
sev_loop1:
 move.b   (a1)+,(a0)+         ; Variablenname einschl. '='
 bne.b    sev_loop1
 subq.l   #1,a0
sev_loop2:
 move.b   (a2)+,(a0)+         ; Wert
 bne.b    sev_loop2
 rts


**********************************************************************
*
* long cmd2arglen( a0 = void *cmdline, a1 = char *arg0 )
*
* Berechnet, wieviel Platz das Umsetzen der Kommandozeile als ARGV-
* Parameter im Environment benoetigt.
*

cmd2arglen:
 cmpi.b   #$7f,(a0)                ; MTOS-ARGV-Konvention ?
 beq.b    c2a_argv                 ;  Environment nicht antasten
 cmpi.b   #$ff,(a0)                ; Zeile uebergeben ?
 bne.b    c2a_noargstr
 addq.l   #1,a0
 move.l   a1,a2
 bsr      strlen                   ; arg
 move.l   d0,d2
 move.l   a2,a0
 bsr      strlen                   ; arg0
 add.l    d2,d0
 addq.l   #8,d0                    ; fuer abschliessende Nullen und "ARGV=\0"
 rts
c2a_noargstr:
 cmpi.b   #$fe,(a0)+               ; argv[] direkt uebergeben ?
 bne.b    c2a_argv                 ; nein
 bra      env_end                  ; Laenge des argv[] berechnen
c2a_argv:
 moveq    #0,d0
 rts


**********************************************************************
*
* void cmd2argv( a0 = void *cmdline, a1 = void *env, a2 = void *arg0 )
*
* Setzt die Kommandozeile als ARGV- Parameter im Environment um.
*

_skip_spc:
 cmpi.b   #' ',(a5)                ; SPACE
 beq.b    _sk_sk
 cmpi.b   #9,(a5)                  ; TAB
 beq.b    _sk_sk
 rts
_sk_sk:
 addq.l   #1,a5
 bra.b    _skip_spc



cmd2argv:
 movem.l  a6/a5/a4,-(sp)
 move.l   a0,a5                    ; a5 = cmdline
 move.l   a1,a6                    ; a6 = env
 move.l   a2,a4
 cmpi.b   #$7f,(a0)                ; MTOS-ARGV-Konvention ?
 beq.b    c2v_ende                 ;  Environment nicht antasten
* zunaechst evtl. vorhandenes ARGV loeschen
 lea      argv_s(pc),a1
 move.l   a6,a0
 bsr      env_get                  ; Position der vorhandenen Variablen
 bne.b    c2v_clr                  ; existiert
 move.l   a6,a0
 bsr      env_end                  ; Ende des Environments
 subq.l   #1,a0                    ; aufs zweite Nullbyte
c2v_clr:
 clr.b    (a0)
 move.l   a0,a6

 cmpi.b   #$ff,(a5)                ; Zeile uebergeben ?
 bne.b    c2v_noargstr
 addq.l   #1,a5

* Leerstellen-getrennte Zeile umsetzen

 move.l   a5,a0
 bsr      strlen
 lea      argv_s(pc),a1
_cav_loop:
 move.b   (a1)+,(a6)+
 bne.b    _cav_loop
c2v_l2:
 move.b   (a4)+,(a6)+              ; arg0
 bne.b    c2v_l2
c2v_nxt2:
 bsr.b    _skip_spc                ; Leerzeichen ueberlesen
c2v_cloop:
 move.b   (a5)+,d0
 beq.b    c2v_eos
 cmpi.b   #' ',d0
 beq.b    c2v_nxt
 cmpi.b   #$d,d0
 beq.b    c2v_nxt
 cmpi.b   #$a,d0
 beq.b    c2v_nxt
 move.b   d0,(a6)+
 bra.b    c2v_cloop
c2v_nxt:
 clr.b    (a6)+
 bra.b    c2v_nxt2
c2v_eos:
 clr.b    (a6)+
 clr.b    (a6)
 bra.b    c2v_ende

*
* Argv direkt angegeben (sollte mit "ARGV=" beginnen)
*

c2v_noargstr:
 cmpi.b   #$fe,(a5)+               ; argv[] direkt uebergeben ?
 bne.b    c2v_ende                 ; nein
c2v_cploop:
 move.b   (a5)+,(a6)+              ; Variable kopieren
 bne.b    c2v_cploop
 tst.b    (a5)
 bne.b    c2v_cploop
 clr.b    (a6)
c2v_ende:
 movem.l  (sp)+,a6/a5/a4
 rts


**********************************************************************
*
* void create_env( a0 = src_env, a1 = dst_env, a2 = char *pname,
*                  d0 = void *cmdline, d1 = char *arg0 )
*

create_env:
 movem.l  a6/a5/a4/a3,-(sp)
 move.l   a1,a6                    ; a6 = dst_env
 move.l   a2,a5                    ; a5 = pname
 move.l   d0,a4                    ; a4 = cmdline
 move.l   d1,a3                    ; a3 = arg0

* Environment kopieren

;movea.l  a6,a1
 clr.w    (a1)                     ; sicherheitshalber 2 Nullbytes
;move.l   a0,a0                    ; Quelle (Environment)
crenv_cploop:
 move.b   (a0)+,(a1)+              ; Variable kopieren
 bne.b    crenv_cploop
 tst.b    (a0)
 bne.b    crenv_cploop
 clr.b    (a1)

* Variable _PNAM entfernen

 lea      pnam_s(pc),a1            ; zu loeschende Variable
 move.l   a6,a0                    ; Environment
 bsr      env_clr

* Variable _PNAM ggf. einsetzen

 tst.b    (a5)
 beq.b    crenv_no_npnam           ; Programmname
 move.l   a5,a2
 lea      pnam_s(pc),a1
 move.l   a6,a0
 bsr      env_set
crenv_no_npnam:

* Variable LINES, falls existent, belassen

 lea      lines_s(pc),a1
 move.l   a6,a0
 bsr      env_get
 bne.b    crenv_isl                ; Variable ist da

* LINES/COLUMNS einsetzen

 bsr      get_termdata             ; => d1 = mx,d2 = my
 subq.l   #8,sp                    ; Platz fuer String
 addq.w   #1,d1
 move.w   d1,-(sp)                 ; int cols
 clr.w    -(sp)
 addq.w   #1,d2
 move.w   d2,-(sp)                 ; int lines
 clr.w    -(sp)
 move.l   sp,-(sp)
 pea      zahl_s(pc)               ; "%L"
 pea      16(sp)                   ; Ziel
 jsr      _sprintf
 lea      20(sp),a2                ; Wert
 lea      lines_s(pc),a1           ; Variable
 move.l   a6,a0
 bsr      env_set                  ; LINES setzen
 addq.l   #4,8(sp)                 ; naechste Variable
 jsr      _sprintf
 lea      20(sp),a2
 lea      columns_s(pc),a1
 move.l   a6,a0
 bsr      env_set                  ; COLUMNS setzen
 lea      28(sp),sp

* ARGV ggf. erstellen

crenv_isl:
 move.l   a3,a2                    ; arg0
 move.l   a6,a1                    ; Environment
 move.l   a4,a0                    ; Kommandozeile
 bsr      cmd2argv                 ; ggf. ARGV erstellen

* Environment auf tatsaechliche Laenge schrumpfen

 move.l   a6,a0
 bsr      env_end
;move.l   d0,d0
 suba.l   a1,a1                    ; kein limit
 move.l   a6,a0
 bsr      Mxshrink

 movem.l  (sp)+,a6/a5/a4/a3
 rts


**********************************************************************
*
* PD *create_basepage( a0 = char *sem_flag,
*                        char *arg0,
*                        char *cmdline,
*                        char *env,
*                        PH *ph,
*                        PD *owner )
*
*  Parameter:
* sem_flag:    Rueckgabe, ob Pexec-Semaphore reserviert wurde.
*
* arg0:        Zeichenkette fuer arg[0] oder NULL
* cmdline:     Kommandozeile
* env:         Das zu setzende Environment
* ph:          Programm-Header
* owner:       Eigner des neuen Speichers (act_pd oder NULL)
*

ARG0      SET  0
CMDLINE   SET  4
ENV       SET  8
PH        SET  12
OWNER     SET  16

create_basepage:
 lea      4(sp),a1
 movem.l  d4/d5/d6/d7/a3-a6,-(sp)
 move.l   a0,a3                    ; a3 = sem_flag
 move.l   a1,a6                    ; a6: Parameter
 moveq    #0,d7                    ; env_mem = NULL
 moveq    #0,d4                    ; pr_mem = NULL
 suba.l   a5,a5                    ; pd_mem = NULL

*
* Speicher fuer PROCDATA allozieren und loeschen
*

 move.l   act_pd,a1
 move.w   #$2002,d1                ; lieber ST-RAM, nolimit
 move.l   #pr_sizeof,d0
 bsr      Mxalloc
 move.l   d0,d4
 beq      crb_ende
 move.l   d4,a0
 lea      pr_sizeof(a0),a1
 jsr      fast_clrmem              ; Block loeschen

*
* Daten in PROCDATA fuer PLOADINFO
*

 move.l   CMDLINE(a6),a1
 move.l   d4,a0
 lea      pr_cmdlin(a0),a0
 move.w   #128,d0
 jsr      vmemcpy                        ; genau 128 Bytes Basepage
 move.l   ARG0(a6),d0
 beq.b    crb_no_prfname                ; kein Pfad
 move.l   d0,a1                         ; von
 move.l   d4,a0
 lea      pr_fname(a0),a0               ; nach
 move.w   #128,d0
 bsr      pathcmpl                      ; kopieren und vervollstaendigen
; tst.l   d0
; bge.b   crb_namok                     ; kein Fehler
crb_no_prfname:
; move.l  p_procdata(a5),a0
; clr.b   pr_fname(a0)
;crb_namok:

* Benoetigte Blockgroesse berechnen: d5
* Wenn Bit 3 des Programmheaders gesetzt ist, darf BSS nicht leer sein,
* sonst kann nicht reloziert werden

 move.l   PH(a6),a0
 move.l   ph_flags(a0),d6               ; d6 = ph_flags
 moveq    #0,d5
 btst     #3,d6                         ; Bit 3 des Programmheaders
 bne.b    crb_minmem                    ; gesetzt => nur Minimalblock
 move.b   d6,d5                         ; ph_flags
 andi.b   #$f0,d5                       ; 4 Bits isolieren (jedes fuer 128k)
 addi.w   #$10,d5                       ; nochmal 128k addieren
 swap     d5                            ; um 16 Bit shiften
 add.l    d5,d5                         ; jetzt um 17 Bit geshiftet
crb_minmem:
 lea      ph_tlen(a0),a0
 add.l    #$100,d5                      ; Laenge der Basepage
 add.l    (a0)+,d5                      ; +tlen
 add.l    (a0)+,d5                      ; +dlen
 add.l    (a0)+,d5                      ; +blen
 add.l    (a0),d5                       ; +slen

* ARG0 bei NULL durch noname_s ersetzen

 move.l   ARG0(a6),d0
 bne.b    crb_arg0_given
 move.l   #noname_s,ARG0(a6)       ; kein arg0
crb_arg0_given:
* Semaphore reservieren
 lea      pexec_sem,a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 seq      (a3)                     ; merken, dass Semaphore gesetzt
* Falls env == NULL, das des parent einsetzen
 move.l   ENV(a6),d0
 bne.b    crb_env_given
 movea.l  act_pd,a0
 move.l   p_env(a0),ENV(a6)
crb_env_given:
 move.l   ENV(a6),a0               ; Zeiger auf das Environment
 move.l   a0,d0
 beq      crb_illenv               ; Environment war 0L
 addq.l   #1,d0
 beq      crb_illenv               ; Environment war -1L

* Laenge des Environments bestimmen und entsprechend Speicher holen

 bsr      env_end

* d0 ist jetzt die Laenge des Environments

 addi.l   #7+10+12,d0              ;   strlen("_PNAM=")+1
                                   ; + strlen("LINES=xxx")+1
                                   ; + strlen("COLUMNS=xxx")+1

 move.l   d0,-(sp)                 ; Env. + feste Zeichenketten
 move.l   ARG0(a6),a0              ; kompletter Pfad
 jsr      fn_name                  ; Dateinamen extrahieren...
 move.l   a0,a4                    ; ...und Zeiger merken (a4)
 bsr      strlen                   ; davon die Laenge
 add.l    d0,(sp)                  ; ...zum Environment addieren

 move.l   ARG0(a6),a1              ; arg0
 move.l   CMDLINE(a6),a0           ; Kommandozeile
 bsr      cmd2arglen               ; wieviel Environment brauchen wir ?
 add.l    (sp)+,d0

 btst     #0,d0
 beq.b    crb_envevn
 addq.l   #1,d0                    ; gerade Laenge erzwingen
crb_envevn:
 move.l   act_pd,a1
 move.w   #$2000,d1                ; nur ST-RAM, nolimit
 btst     #1,d6                    ; Load to FastRAM ?
 beq.b    crb_no_ttram             ; nein, ins ST-RAM
 addq.w   #3,d1                    ; TT-RAM preferred, nolimit
crb_no_ttram:
;move.l   d0,d0
 bsr      Mxalloc
 move.l   d0,d7
 beq      crb_freeenv

* Environment erstellen

 move.l   ARG0(a6),d1              ; arg0
 move.l   a4,a2                    ; Programmname fuer _PNAM
 move.l   d0,a1                    ; neues Environment
 move.l   ENV(a6),a0               ; Quelle (Environment)
 move.l   CMDLINE(a6),d0           ; Kommandozeile
 bsr      create_env

* Groesse freien Speichers feststellen
* Fehler, wenn nicht genug fuer Basepage

crb_illenv:
 move.l   d5,d0                         ; soviel Speicher minimal
 btst     #3,d6                         ; nur minimalen Speicher holen?
 bne.b    crb_enoughmem                 ; ja

 move.l   act_pd,a1
 move.w   #$2000,d1                     ; nur ST-RAM, nolimit
 moveq    #-1,d0
 bsr      Mxalloc
 btst     #1,d6                         ; Laden aus FastRAM ?
 beq.b    crb_mxav                      ; nein, Prg muss im ST-RAM liegen
 move.l   d0,-(sp)                      ; Groesse des ST-RAM merken
 move.l   act_pd,a1
 move.w   #$2001,d1                     ; nur TT-RAM, nolimit

 moveq    #-1,d0
 bsr      Mxalloc
 move.l   (sp)+,d1                      ; Groesse TT-RAM vergl. mit Groesse ST-RAM
 cmp.l    d1,d0
 bcc.b    crb_mxav                      ; TT-RAM hat groesseren Block, nehmen!

; checken, ob TT-RAM ausreicht fuer Heap ("TPA")

 cmp.l    d5,d0
 bcc.b    crb_mxav                      ; reicht!
 move.l   d1,d0                         ; nein, nimm ST-Block
crb_mxav:
 cmp.l    #$100,d0
 bcc.b    crb_enoughmem

* PROCDATA und Environment wieder freigeben

crb_freeenv:
 move.l   d7,d0
 beq.b    crb_freeenv1
 suba.l   a1,a1                         ; kein limit
 move.l   d0,a0
 bsr      Mxfree
crb_freeenv1:
 move.l   d4,d0
 beq.b    crb_freeenv2
 suba.l   a1,a1                         ; kein limit
 move.l   d0,a0
 bsr      Mxfree
crb_freeenv2:
 bra      crb_ende

* Speicher fuer Programm holen (alles, was frei ist)

crb_enoughmem:
 move.l   act_pd,a1
 move.w   #$2000,d1                ; nur ST-RAM, nolimit
 btst     #1,d6                    ; Load to FastRAM ?
 beq.b    crb_no_ttram2            ; nein, ins ST-RAM
 addq.w   #3,d1                    ; TT-RAM preferred, nolimit
crb_no_ttram2:
;move.l   d0,d0
 bsr      Mxalloc
 tst.l    d0
 beq      crb_freeenv              ; zuwenig MDs
 move.l   d0,a5                    ; a5 = neuer PD

* Prozess- Deskriptoren (owner) fuer beide MDs setzen
* In Modus "Load+Exec" ist es der neue Prozess, sonst der aktuelle

 move.l   OWNER(a6),d0             ; Eigner
 bne.b    crb_old_owner            ; ist angegeben
 move.l   a5,d0                    ; ist neuer Prozess
crb_old_owner:
 tst.l    d7
 beq.b    crb_noenv1
 move.l   d7,a0
 move.l   d0,a1
 move.l   d0,-(sp)
 bsr      Mchgown
 move.l   (sp)+,d0
crb_noenv1:
 tst.l    d4
 beq.b    crb_noenv2
 move.l   d4,a0
 move.l   d0,a1
 move.l   d0,-(sp)
 bsr      Mchgown
 move.l   (sp)+,d0
crb_noenv2:
 move.l   d0,a1
 move.l   a5,a0
 bsr      Mchgown

* Die Basepage wird initialisiert, d.h. p_lowtpa und p_hitpa und p_procdata
* eingesetzt, der Rest der Basepage = 0 gesetzt

 move.l   a5,p_lowtpa(a5)
 move.l   a5,a0
 bsr      Mgetlen
 add.l    a5,d0
 move.l   d0,p_hitpa(a5)
 lea      p_tbase(a5),a0
 moveq    #61,d0                   ; dbra- Zaehler
crb_clrloop:
 clr.l    (a0)+
 dbra     d0,crb_clrloop

* aktueller DTA- Puffer auf Offset $80 der Basepage

 lea      128(a5),a0
 move.l   a0,p_dta(a5)

* zunaechst Default- Standardhandles einsetzen

 lea      def_hdlx(pc),a0
 lea      p_devx(a5),a1
 move.l   (a0)+,(a1)+
 move.w   (a0),(a1)

* praeventiv hier schon einmal das Standardlaufwerk setzen

 move.l   act_pd,a0
 move.b   p_defdrv(a0),p_defdrv(a5)

* unter MagiC Speicherlimitierung vom Parent vererben

 bsr      pgetmemlim               ; d0 = aktuelle Einstellung (0=unlim)
 tst.l    d0                       ; limitiert ?
 bne.b    crb_lim                  ; ja, Limit einsetzen
 moveq    #-1,d0                   ; nein, als unlimitiert setzen
crb_lim:
 move.l   d0,p_mem(a5)             ; vererben
 move.l   d6,p_mflags(a5)

* p_env und p_procdata einsetzen

 move.l   d7,p_env(a5)
 move.l   d4,p_procdata(a5)

* Kommandozeile in die Basepage kopieren und mit '\0' abschliessen

 move.l   CMDLINE(a6),a1           ; Kommandozeile
 cmpi.b   #$fe,(a1)                ; Sonderbehandlung ?
 bcs.b    crb_noclfe               ; nein
 beq.b    crb_clfe

 lea      1(a1),a0
 bsr      strlen
 cmpi.w   #126,d0
 bhi.b    crb_clfe
 lea      128(a5),a0
 move.b   #$7f,(a0)+
 move.l   CMDLINE(a6),a1           ; Kommandozeile
 addq.l   #1,a1
 moveq    #1,d0
 bra.b    crb_nxtchar

crb_clfe:
 move.b   #$7f,128(a5)
 bra.b    crb_ende

crb_noclfe:
 lea      128(a5),a0
 moveq    #0,d0
 bra.b    crb_nxtchar
crb_charloop:
 move.b   (a1)+,(a0)+
 addq.w   #1,d0
crb_nxtchar:
 cmpi.w   #$7f,d0
 bcc.b    crb_endcharloop
 tst.b    (a1)
 bne.b    crb_charloop
crb_endcharloop:
 clr.b    (a0)

crb_ende:
 move.l   a5,d0
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4
 rts


**********************************************************************
*
* void chg_bp_owner( a0 = PD *bp )
*
* Eigner von Basepage und PROCDATA und Environment wird der
* Prozess selbst.
*

chg_bp_owner:
 move.l   a0,-(sp)                 ; bp merken
 move.l   a0,a1                    ; neuer Eigentuemer
;move.l   a0,a0                    ; Blockadresse
 bsr      Mchgown
 move.l   (sp),a1
 move.l   p_procdata(a1),d0
 ble.b    cbpl2
 move.l   d0,a0
 bsr      Mchgown
cbpl2:
 move.l   (sp)+,a1
 move.l   p_env(a1),d0
 ble.b    cbpend
 move.l   d0,a0
 bra      Mchgown
cbpend:
 rts


**********************************************************************
*
* long load_PH( a0 = char *fname, a1 = PH *ph )
*
* Laedt den Programm-Header und gibt das geoeffnete Handle zurueck.
* Negativer Rueckgabewert: Fehler
*

load_PH:
 move.l   a1,-(sp)
 moveq    #O_EXEC,d0
;move.l   a0,a0
 bsr      Fopen                    ; zum Lesen oeffnen
 move.l   d0,-(sp)                 ; Handle retten
 bmi.b    lph_ende                 ; Fehler beim Oeffnen
 move.l   4(sp),a0                 ; a0 = ph
 moveq    #ph_sizeof,d1
;move.w   d0,d0
 bsr      Fread
 move.l   d0,d1
 bmi.b    lph_close
 cmp.l    #ph_sizeof,d0
 bne.b    lph_eplfmt
 move.l   4(sp),a0
 cmpi.w   #$601a,ph_branch(a0)
 beq.b    lph_ende
lph_eplfmt:
 moveq    #EPLFMT,d1
lph_close:
 move.l   (sp),d0
 move.l   d1,(sp)
 bsr      Fclose
lph_ende:
 move.l   (sp)+,d0                 ; Handle oder Fehlercode
 addq.l   #4,sp
 rts


**********************************************************************
*
* void exec_PD( a0 = PD *pd )
*
* Startet den Prozess
*

exec_PD:
 move.l   a5,-(sp)
 move.l   a0,a5                    ; Basepage

 bsr      flush_cpu_cache

 cmpi.l   #'_ACC',p_res3(a5)
 beq.b    pxc_startacc
 move.l   p_hitpa(a5),a1           ; usp liegt am Ende der hitpa
* Zeiger auf Basepage auf den Stapel legen (bekommt das Pgm. auf 4(a7))
 move.l   a5,-(a1)
* oberstes Stapelelement = 0L (bekommt das Pgm. auf (a7))
 clr.l    -(a1)

pxc_startacc:

* MagiC 4.5: startende APPL (Thread) und ssp merken!

 move.l   act_appl.l,p_app(a5)
 move.l   sp,p_ssp(a5)

* Supervisorstack aufbauen (vom aktuellen Prozess geerbt) !
* Modus 106 nicht mehr unterstuetzt

 tst.w    cpu_typ.w
 beq.b    pxc_00
 clr.w    -(sp)                    ; Vektoroffset
pxc_00:
 move.l   8(a5),-(sp)              ; pc
 clr.w    -(sp)                    ; sr (Usermode, INT=0)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)                    ; d1/d2/a1/a2 sind alle 0
 pea      dt_ret(pc)               ; Ruecksprungadresse im DOS
 clr.l    -(sp)                    ; a6
 move.l   p_dbase(a5),-(sp)        ; a5
 move.l   p_bbase(a5),-(sp)        ; a4
 moveq    #6-1,d0
pxc_regloop:
 clr.l    -(sp)                    ; d3-d7/a3 sind 0
 dbra     d0,pxc_regloop
 move.l   a1,-(sp)                 ; usp  (bei ACC NULL)

 cmpi.l   #'_ACC',p_res3(a5)       ; ACC starten
 beq.b    pxc_scnt
 cmpi.l   #'_PRG',p_res3(a5)       ; PRG parallel starten
 bne.b    pxc_noacc

pxc_scnt:
 move.l   p_context(a5),p_res3+4(a5)    ; p_res3 ist p_context fuer Pterm

pxc_noacc:
 move.l   sp,p_context(a5)

* Prozess umschalten
 move.l   a5,act_pd
 move.l   act_appl.l,d0
 beq.b    pxc_noap
 move.l   d0,a0
 move.l   a5,ap_pd(a0)             ; in Applikationsstruktur eintragen
pxc_noap:

* Hier wird der neue Prozess gestartet
* wichtig: 2s Zeit, um den Mshrink durchzufuehren

 tst.w    pe_slice.w
 bmi.b    pxc_no_slice
 move.w   #400,pe_timer.w          ; 2s
pxc_no_slice:
 cmpi.l   #'_ACC',p_res3(a5)       ; Modus "ACC starten" ?
 beq      start_acc

 bra      start_proc               ; nein, Prozess starten


**********************************************************************
*
* void flush_cpu_cache( void )
*
* Loescht den CPU-Cache.
*

flush_cpu_cache:
 cmpi.w   #40,cpu_typ.l
 bcc.b    fcc_040
 cmpi.w   #20,cpu_typ.l
 beq.b    fcc_020
 cmpi.w   #30,cpu_typ.l
 bne.b    fcc_noflush
fcc_020:
* fuer den 020/030 die Caches loeschen
 movec    cacr,d0
 or.l     #$808,d0            ; data+instr invalid
 movec    d0,cacr
 bra.b    fcc_noflush
* fuer den 040 und 060 die Caches loeschen (cpusha)
fcc_040:
 DC.W     $f4f8
fcc_noflush:
 rts


**********************************************************************
*
* long Pexec(int mode, char name[], char cmdline[], char env[])
*
* 8(a6)        :    int  mode
* $a(a6)       :    char name[]
* $e(a6)       :    char cmdline[], PD * neuer Prozess
* $12(a6)      :    char env[]
*
* Standardmodi:
*
*  Modus   0:  EXE_LDEX
*              Laedt und startet ein Programm 2(a4)
*              mit Kommandozeile 6(a4) und Environment 10(a4)
*  Modus   3:  EXE_LD
*              Laedt ein Programm 2(a4)
*              mit Kommandozeile 6(a4) und Environment 10(a4)
*              Rueckgabe: Adresse der Basepage
*  Modus   4:  EXE_EX
*              Startet ein Programm 6(a4)
*  Modus   5:  EXE_BASE
*              Erstellt einen PD
*              mit Kommandozeile 6(a4) und Environment 10(a4)
*  Modus   6:  EXE_EXFR
*              wie Modus 4, aber PD und Env dem neuen Prozess
*  Modus   7:  EXE_XBASE
*              wie Modus 5, aber statt name prgflags
*
* Multitasking- Erweiterungen:
*
*  Modus 100:  MEXE_LDEX           (wird vom AES erledigt)
*              MiNT: Starte Prozess parallel (sonst wie Modus 0)
*  Modus 101:  XEXE_INIT, dummy,child,parent
*              Vererbt Pfad- und Dateihandles. Es wird aber kein
*              PROCDATA erstellt, kein PID vergeben und kein Eintrag
*              in u:\proc gemacht.
*              (wird vom AES verwendet, fuer den Loader-Prozess, der dann
*               das Programm normal per Pexec(EXE_LDEX) startet)
*  Modus 102:  XEXE_TERM
*              Loescht einen Prozess 6(a4)
*              (wird vom AES verwendet)
*  Modus 104:  MEXE_EX             (wird vom AES erledigt)
*              MiNT: Startet ein Programm 6(a4) parallel im selben
*              Adressraum
*  Modus 106:  MEXE_EXFR           (wird vom AES erledigt)
*              MiNT: Startet ein Programm 6(a4) parallel im eigenen
*              Adressraum
*  Modus 107:  XEXE_XBASE
*              wie Modus 7, aber Prozessname statt cmdline
*              (wird vom BIOS verwendet)
*  Modus 108:  XEXE_EXACC
*              Startet ein ACC. Es findet kein Kontextwechsel statt, es wird
*              nur der Programmname gesetzt und das Programm am Anfang des
*              Textsegments im Usermode mit a0 = NULL gestartet.
*              (wird vom AES verwendet)
*  Modus 200:  MEXE_LDEXOV         (wird von dpex_200 erledigt)
*              Starte Prozess als Overlay (sonst wie Modus 0).
*              D.h. der neue Prozess ueberschreibt den alten.
*
* FUNKTIONEN FUeR PARALLELE PEXEC-MODI (ab x.5.96):
*
*  Modus 301:  XXEXE_INIT, pinfo, child, parent, pname
*              Vererbt Pfad, Dateihandles und die PINFO-Struktur.
*              Setzt den Programmnamen. Wenn <pname> = NULL, wird der
*              Name des parent eingesetzt
*              (wird vom AES verwendet, nicht dokumentieren!!!)
*  Modus 401:  XXEXE_INITM, pinfo, child, parent, pname
*              Wie 301, vererbt zusaetzlich die Speicherbloecke (!)
*              (wird vom AES verwendet, nicht dokumentieren!!!)
*  Modus 300:  XXEXE_EX, dummy, basepage, dummy
*              Startet einen Prozess, der bereits komplett initialisiert ist,
*              (d.h. Dateihandles und PINFO-Struktur werden nicht mehr
*              veraendert).
*              (wird vom AES verwendet, nicht dokumentieren!!!)
*
* WEGEN INKOMPATIBILITAeT ZU MINT ENTFERNT:
*
*  Modus 106:  XEXE_EXFR
*              Wie Modus 6, jedoch wird statt <env> der ssp des zu startenden
*              Prozesses angegeben
*
*  unter XAES wird, ausser bei Modus 106, der SSP vererbt!
*
* Neu ab MagiC 24.8.94:
*  Unterstuetzung des ARGV-Prinzips. Ist die Kommandozeile zu lang, wird
*  eine Laenge von $7f eingetragen und die Argumente im Environment uebergeben.
*  Dabei ist die letzte Variable "ARGV=\0p1\0p2\0...pn\0\0".
*  Der Automatismus wird folgendermassen unterstuetzt:
*
*  - Wenn das Laengenbyte der Kommandozeile < $7f ist, weiss das Programm
*    nichts von ARGV. Wenn das Environment derartige Daten enthaelt, werden
*    sie beim Kopieren entfernt.
*  - Ist das Laengenbyte $7f, arbeitet das Programm mit ARGV im Sinne von
*    MultiTOS. Das Environment wird nicht angetastet.
*  - Ist das Laengenbyte $ff, wird die Kommandozeile als nullterminierte
*    Zeichenkette dahinter uebergeben. Wenn die Zeile kuerzer als 126 Zeichen
*    ist, werden die Leerzeichen durch EOS ersetzt, ein ARGV im Environment
*    erzeugt und $7f als Laenge der Kommandozeile eingetragen.
*    Ansonsten wird keine Kommandozeile eingetragen und nur das ARGV
*    erstellt.
*  - Ist das Laengenbyte $fe, folgt zunaechst die Zeichenkette "ARGV=xxx",
*    wobei "xxx" optional fuer die Kennzeichnung von leeren Argumenten
*    verwendet werden kann.
*    Es folgt eine nullterminierte Reihe von Argumenten,
*    die mit zwei Nullbytes abgeschlossen sind. Die Kommandozeilenlaenge wird
*    als $7f gesetzt und die Argumente ins Environment kopiert.
*
*
* Diese Aktionen bzw. Pexec-Modi werden NICHT innerhalb von Pexec()
* ausgefuehrt, sondern vorher abgefangen und entsprechend umgesetzt:
*
*
*    ACC laden und starten:
*
*         Programm mit Pexec(EXE_LD) laden
*         Basepage mit Mshrink bearbeiten
*         Prozess mit XEXE_EXACC starten
*
*    Parallele Applikation per shel_write() starten:
*
*         Basepage per Pexec(EXE_BASE) erstellen, kein Env
*         Eigner der Basepage wird das Programm selbst
*         Prozess mit XEXE_INIT initialisieren (Pfad-/Dateihandles)
*          Der Ladeprozess hat keine PROCDATA, keine pid und keinen
*          Eintrag in u:\proc\
*         Prozess einfach anspringen, laedt Programm per Pexec(EXE_LDEX)
*         Ladeprozess mit Pexec(XEXE_TERM) entfernen
*
*    Pexec(100 (MEXE_LDEX)):
*
*         Programm mit Pexec(EXE_LD) laden
*         Prozess mit Pexec(XXEXE_INIT) initialisieren
*         Neuer Prozess als Eigner von Basepage und Env
*         Prozess mit Pexec(XXEXE_EX) starten
*         
*    Pexec(104 (MEXE_EX)):
*
*         Prozess mit Pexec(XXEXE_MINIT) initialisieren
*         Prozess mit Pexec(XXEXE_EX) starten
*
*    Pexec(106 (MEXE_EXFR)):
*
*         Prozess mit Pexec(XXEXE_INIT) initialisieren
*         Neuer Prozess als Eigner von Basepage und Env
*         Prozess mit Pexec(XXEXE_EX) starten
*
*    Pexec(200 (MEXE_LDEXOV)):
*
*         Programm mit Pexec(EXE_LD) laden
*         ...
*

PH        SET  -ph_sizeof          ; Programm-Header
HAVE_SEM  SET  PH-2                ; Flag "Semaphore belegt"
STKOFFS   SET  HAVE_SEM

Pexec:
     DEBON
     DEBL (a0),'Pexec mit Modus '
 link     a6,#STKOFFS
 movem.l  d7/a4/a5,-(sp)
 moveq    #0,d7                    ; Datei nicht geoeffnet
 move.l   a0,a4

 clr.w    HAVE_SEM(a6)             ; noch keine Semaphore belegt

 lea      PH(a6),a0
 lea      ph_sizeof(a0),a1
 jsr      fast_clrmem              ; Laengen und prgflags auf 0

* switch(mode)

 lea      pxc_jmptab(pc),a0
pxc_switchloop:
 move.w   (a0)+,d0
 bmi      pxc_einvfn               ; ungueltiger Modus
 move.w   (a0)+,d1                 ; Sprung-Offset
 cmp.w    (a4),d0                  ; mode
 bne.b    pxc_switchloop
 jmp      pxc_jmptab(pc,d1.w)

pxc_jmptab:
 DC.W     0,pxc_mod0-pxc_jmptab
 DC.W     3,pxc_mod3-pxc_jmptab
 DC.W     4,pxc_mod4-pxc_jmptab
 DC.W     5,pxc_mod5-pxc_jmptab
 DC.W     6,pxc_mod6-pxc_jmptab
 DC.W     7,pxc_mod7-pxc_jmptab
 DC.W     101,pxc_mod101-pxc_jmptab
 DC.W     102,pxc_mod102-pxc_jmptab
 DC.W     107,pxc_mod107-pxc_jmptab
 DC.W     108,pxc_mod108-pxc_jmptab
 DC.W     300,pxc_mod300-pxc_jmptab
 DC.W     301,pxc_mod301-pxc_jmptab
 DC.W     401,pxc_mod401-pxc_jmptab
 DC.W     -1


*
* case EXE_LDEX (0):
*  2(a4) = path
*  6(a4) = cmdline
* 10(a4) = env
*

pxc_mod0:
     DEBT 2(a4),'Pexec(0) mit Datei '
 lea      PH(a6),a1
 move.l   2(a4),a0                 ; fname
 bsr      load_PH                  ; Oeffnen und PH einlesen
 move.l   d0,d7
 ble      pxc_ende                 ; Lesefehler

 clr.l    -(sp)                    ; owner ist neuer Prozess
 pea      PH(a6)
 move.l   10(a4),-(sp)             ; env
 move.l   6(a4),-(sp)
 move.l   2(a4),-(sp)
 lea      HAVE_SEM(a6),a0
 bsr      create_basepage
 lea      20(sp),sp
 tst.l    d0
 beq      pxc_ensmem
 move.l   d0,a5                    ; a5 = Basepage

 move.l   a5,-(sp)                 ; Basepage
 lea      PH(a6),a0                ; PH
 move.w   d7,d0                    ; Handle
 bsr      pload
 addq.l   #4,sp
 moveq    #0,d7                    ; Handle ist jetzt geschlossen
 tst.l    d0
 bmi      pxc_abort                ; Fehler

 move.l   act_pd,a1
 move.l   a5,a0
 bsr      init_pd
 move.l   act_pd,p_parent(a5)

 tst.w    HAVE_SEM(a6)
 beq.b    pxc_0f
 lea      pexec_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 clr.w    HAVE_SEM(a6)
pxc_0f:

 move.l   a5,a0
 bsr      exec_PD
 bra      pxc_ende                 ; hier kommen wir nicht mehr hin

*
* case EXE_LD (3):
*  2(a4) = path
*  6(a4) = cmdline
* 10(a4) = env
* 14(a4) = magic
* 18(a4) = flags                   ; Bit 0: minimaler Speicher
*

pxc_mod3:
 lea      PH(a6),a1
 move.l   2(a4),a0                 ; fname
 bsr      load_PH                  ; Oeffnen und PH einlesen
 move.l   d0,d7
 ble      pxc_ende                 ; Lesefehler

 cmpi.l   #'xld3',14(a4)
 bne.b    pxm3_no_magic
 btst     #0,18+1(a4)
 beq.b    pxm3_no_magic
 bset     #3,PH+ph_flags+3(a6)     ; minimaler Speicher
pxm3_no_magic:

 move.l   act_pd,-(sp)             ; owner ist aktueller Prozess
 pea      PH(a6)
 move.l   10(a4),-(sp)             ; env
 move.l   6(a4),-(sp)
 move.l   2(a4),-(sp)
 lea      HAVE_SEM(a6),a0
 bsr      create_basepage
 lea      20(sp),sp
 tst.l    d0
 beq      pxc_ensmem
 move.l   d0,a5                    ; a5 = Basepage

 move.l   a5,-(sp)                 ; Basepage
 lea      PH(a6),a0                ; PH
 move.w   d7,d0                    ; Handle
 bsr      pload
 addq.l   #4,sp
 moveq    #0,d7                    ; Handle ist jetzt geschlossen
 tst.l    d0
 bmi      pxc_abort                ; Fehler
 move.l   a5,d0                    ; PD *
 bra      pxc_ende                 ; Basepage zurueckgeben

*
* case EXE_EX (4):
*  2(a4) = NULL
*  6(a4) = PD *
* 10(a4) = NULL
*

pxc_mod4:
 move.l   6(a4),a5                 ; a5 = Basepage
 move.l   act_pd,a1
 move.l   a5,a0
 bsr      init_pd
 move.l   act_pd,p_parent(a5)

 move.l   a5,a0
 bsr      exec_PD
 bra      pxc_ende                 ; hier kommen wir nicht mehr hin

*
* case EXE_BASE (5):
*  2(a4) = NULL
*  6(a4) = cmdline
* 10(a4) = env
*

pxc_mod5:
 move.l   act_pd,-(sp)             ; owner ist aktueller Prozess
 pea      PH(a6)
 move.l   10(a4),-(sp)             ; env
 move.l   6(a4),-(sp)
 move.l   2(a4),-(sp)              ; ist i.a. NULL
 lea      HAVE_SEM(a6),a0
 bsr      create_basepage
 lea      20(sp),sp
 tst.l    d0
 beq      pxc_ensmem
;move.l   d0,d0
 bra      pxc_ende                 ; Basepage zurueckgeben

*
* case EXE_EXFR (6):
*  2(a4) = NULL
*  6(a4) = PD *
* 10(a4) = NULL
*

pxc_mod6:
 move.l   6(a4),a5                 ; a5 = Basepage
 move.l   a5,a0                    ; wird eigener Eigner
 bsr      chg_bp_owner

 move.l   act_pd,a1
 move.l   a5,a0
 bsr      init_pd
 move.l   act_pd,p_parent(a5)

 move.l   a5,a0
 bsr      exec_PD
 bra      pxc_ende                 ; hier kommen wir nicht mehr hin

*
* case EXE_XBASE (7):
*  2(a4) = prgflags
*  6(a4) = cmdline
* 10(a4) = env
*

pxc_mod7:
 move.l   2(a4),PH+ph_flags(a6)    ; prgflags statt name

 move.l   act_pd,-(sp)             ; owner ist aktueller Prozess
 pea      PH(a6)
 move.l   10(a4),-(sp)             ; env
 move.l   6(a4),-(sp)              ; cmdline
 clr.l    -(sp)                    ; kein Name
 lea      HAVE_SEM(a6),a0
 bsr      create_basepage
 lea      20(sp),sp
 tst.l    d0
 beq      pxc_ensmem
;move.l   d0,d0
 bra      pxc_ende                 ; Basepage zurueckgeben

*
* case XEXE_TERM (102):
*  2(a4) = NULL
*  6(a4) = PD *
* 10(a4) = NULL
*

pxc_mod102:
 moveq    #1,d0                    ; Speicher freigeben
 move.l   6(a4),a0
 bsr      PDkill
 moveq    #0,d0                    ; kein Fehler
 bra      pxc_ende

*
* case XEXE_XBASE (107):
*  2(a4) = prgflags
*  6(a4) = fname
* 10(a4) = env
*

pxc_mod107:
 move.l   2(a4),PH+ph_flags(a6)    ; prgflags statt name

 move.l   act_pd,-(sp)             ; owner ist aktueller Prozess
 pea      PH(a6)
 move.l   10(a4),-(sp)             ; env
 pea      nulb_s(pc)               ; cmdline
 move.l   6(a4),-(sp)              ; procname
 lea      HAVE_SEM(a6),a0
 bsr      create_basepage
 lea      20(sp),sp
 tst.l    d0
 beq      pxc_ensmem
;move.l   d0,d0
 bra      pxc_ende                 ; Basepage zurueckgeben

*
* case XEXE_EXACC (108):
*  2(a4) = NULL
*  6(a4) = PD *pd
* 10(a4) = NULL
*

pxc_mod108:
 move.l   6(a4),a0
 move.l   #'_ACC',p_res3(a0)
 bsr      exec_PD
 bra      pxc_ende                 ; hier kommen wir nicht mehr hin

*
* case XXEXE_EX (300):
*  2(a4) = NULL
*  6(a4) = PD *pd
* 10(a4) = NULL
*

pxc_mod300:
 move.l   6(a4),a0
 move.l   #'_PRG',p_res3(a0)
 bsr      exec_PD
 bra      pxc_ende                 ; hier kommen wir nicht mehr hin

*
* case XEXE_INIT (101):
*  2(a4) = NULL
*  6(a4) = PD *child
* 10(a4) = PD *parent
*

pxc_mod101:
 move.l   10(a4),a1                ; parent
 move.l   6(a4),a0                 ; child
 bsr      init_pd
 moveq    #0,d0
 bra      pxc_ende

*
* case XXEXE_INIT (301):
*  2(a4) = NULL
*  6(a4) = PD *child
* 10(a4) = PD *parent
* 14(a4) = char *fname oder NULL
*

pxc_mod301:
; Programmnamen
 move.l   14(a4),a0                ; fname
 move.l   a0,d0
 bne.b    pxc_isnam_x01            ; Name ist angegeben
 move.l   10(a4),a0
 move.l   p_procdata(a0),a0
 lea      pr_procname(a0),a0       ; Prozessnamen nehmen
pxc_isnam_x01:
 move.l   6(a4),a1
 move.l   p_procdata(a1),a1
 lea      pr_procname(a1),a1
 bsr      fnam2pnam                ; von a0 nach a1
pxc_nonam_x01:
 move.l   10(a4),a1                ; parent
 move.l   6(a4),a0                 ; child
 bsr      init_pd

 cmpi.w   #401,(a4)
 beq.b    pxc_no_chown             ; bei Pexec(104) Eigner nicht aendern
 move.l   6(a4),a0                 ; Basepage child wird eigener Eigner
 bsr      chg_bp_owner
pxc_no_chown:
 moveq    #0,d0
 bra      pxc_ende

*
* case XXEXE_INITM (401):
*  2(a4) = NULL
*  6(a4) = PD *child
* 10(a4) = PD *parent
* 14(a4) = char *fname
*

pxc_mod401:
* Bei Modus 401 wie 301, vorher noch Speicher sharen
 move.l   6(a4),a1                 ; child
 move.l   10(a4),a0                ; parent
 bsr      mshare                   ; Speicher von <src> "sharen"
 tst.l    d0
 bne      pxc_ende                 ; Fehler beim share
 move.l   6(a4),a1                 ; child
 move.l   10(a4),a0                ; parent
 bsr      mfork                    ; Speicher an <dst> "vererben"
 tst.l    d0
 bne      pxc_ende                 ; Fehler beim share
 bra.b    pxc_mod301

*
* end switch
*

pxc_ensmem:
 moveq    #ENSMEM,d0
 bra.b    pxc_ende
pxc_einvfn:
 moveq    #EINVFN,d0
; bra.b    pxc_ende
 
pxc_ende:
 tst.l    d7
 ble.b    pxc__ende
 exg      d0,d7
 bsr      Fclose
 move.l   d7,d0
pxc__ende:
 tst.w    HAVE_SEM(a6)
 beq.b    pxc_enden
 move.l   d0,d7
 lea      pexec_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 move.l   d7,d0
pxc_enden:
     DEBL d0,'Pexec => '
 movem.l  (sp)+,d7/a4/a5
 unlk     a6
 rts

* Es ist ein Fehler aufgetreten. a5 ist die Basepage.
pxc_abort:
 move.l   d0,-(sp)                 ; Fehlercode merken
 move.l   p_procdata(a5),d0
 beq.b    pxc_abnp
 suba.l   a1,a1                    ; kein limit
 move.l   d0,a0
 bsr      Mxfree                   ; PROCDATA freigeben
pxc_abnp:
 move.l   p_env(a5),d0
 beq.b    pxc_abne
 suba.l   a1,a1                    ; kein limit
 move.l   d0,a0
 bsr      Mxfree                   ; Environment freigeben
pxc_abne:
 suba.l   a1,a1                    ; kein Limit
 move.l   a5,a0
 bsr      Mxfree                   ; Basepage freigeben
 move.l   (sp)+,d0                 ; Fehlercode holen
 bra      pxc_ende


**********************************************************************
*
* long pload(d0 = int handle, a0 = PH *ph, PD *process)
*
* Lade- und Relozierroutine
*
* Unterschiede zu DOS 0.19: Datei wird geschlossen bei EPLFMT
*                                                      ENSMEM
*                                                      COM- Format
*                           Speicher wird auch bei COM- Format geloescht!
*
* Verbesserungen: - Abfrage auf ungerade Relocation- Adressen
*                 - Sicherheitsabfragen bei SAeMTLICHEN Fread- Aufrufen
*                 - Sichern und Schliessen des Handles bei longjmp
*                 - Optimierungen
*
* unbenutzt: long -$c(a6),-8(a6),-4(a6)
*
* Fuer den residenten Monitor kann man ueber Handle
* -1 den Monitor laden
*
* 17.9.95: In process->p_mem kann man die maximale Groesse des Heap
* uebergeben, die alternativ auch hinter den Relocationdaten liegen
* kann. Eine Laenge von -1L ist der Normalwert und heisst "unlimitiert".
*

pload:
 link     a6,#-$18
 movem.l  d3/d4/d5/d6/a3/a4/a5,-(sp)
     IFNE MONITOR
 move.l   d7,-(sp)
 moveq    #28,d7
     ENDIF
 move.w   d0,d4                    ; Handle
 move.l   a0,a4                    ; PH *
* a5 = PD
 movea.l  8(a6),a5                 ; PD *
* d3 = textlen + datalen
 move.l   ph_tlen(a4),d0           ; TEXT
 add.l    ph_dlen(a4),d0           ; + DATA
 move.l   d0,d3
* -$14(a6) = Laenge der TPA ohne Basepage - textlen - datalen (Platz fuer BSS)
 move.l   p_hitpa(a5),a0
 sub.l    p_lowtpa(a5),a0
 suba.w   #256,a0
 sub.l    d3,a0
 move.l   a0,-$14(a6)              ; kann negativ sein!
* bsslen <= Laenge der TPA ohne Basepage - textlen - datalen ?
 cmp.l    ph_blen(a4),a0
 blt      pld_ensmem               ; Kein Platz fuer BSS => return(ENSMEM)
* a5 = Zeiger hinter Basepage = Beginn von TEXT
 lea      $100(a5),a5
* a3 = Zeiger hinter Basepage + textlen + datalen,  also Beginn von BSS
 movea.l  a5,a3
 adda.l   d3,a3
* p_tbase,p_tlen,p_dbase,p_dlen,p_bbase,p_blen einsetzen
 move.l   8(a6),a0
 move.l   a5,p_tbase(a0)
 move.l   a5,p_dbase(a0)
 move.l   a5,p_bbase(a0)
 move.l   ph_tlen(a4),d0           ; Laenge des TEXT
 move.l   d0,p_tlen(a0)
 add.l    d0,p_dbase(a0)
 add.l    d0,p_bbase(a0)
 move.l   ph_dlen(a4),d0           ; Laenge des DATA
 move.l   d0,p_dlen(a0)
 add.l    d0,p_bbase(a0)
 move.l   ph_blen(a4),p_blen(a0)   ; Laenge des BSS
* TEXT und DATA lesen

     IFNE MONITOR
 tst.w    d4
 bge.b    __mon_1
 lea      mon,a1
 add.l    d7,a1
 move.l   d3,d1
 lsr.l    #3,d1                    ; /8 wg. 2*Langwort
 addq.l   #1,d1                    ; aufrunden
 move.l   a5,a0
__mon_3:
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 subq.l   #1,d1
 bgt.b    __mon_3
 add.l    d3,d7
 move.l   d3,d0
 bra      __mon_2
__mon_1:
 move.l   a5,a0
 move.l   d3,d1
 move.w   d4,d0
 bsr      Fread
__mon_2:
     ELSE

 move.l   a5,a0
 move.l   d3,d1
 move.w   d4,d0
 bsr      Fread
     ENDIF

 tst.l    d0
 bmi      pld_clende
 cmp.l    d3,d0
 bne      pld_eplfmt               ; Lesefehler
 tst.w    ph_reloflag(a4)          ; no_reloc ?
 bne      pld_endrelo

* Relozieren

* Dateizeiger auf Beginn der Relozierdaten (SYM ueberspringen)

     IFNE MONITOR
 tst.w    d4
 bge.b    __mon_6
 moveq    #ph_sizeof,d7            ; Header
 add.l    ph_slen(a4),d7           ; Laenge der Symboltabelle
 add.l    d3,d7
 lea      mon,a0
 move.b   0(a0,d7.l),-$18(a6)
 move.b   1(a0,d7.l),-$17(a6)
 move.b   2(a0,d7.l),-$16(a6)
 move.b   3(a0,d7.l),-$15(a6)
 addq.l   #4,d7
 moveq    #4,d0
 bra      __mon_7
__mon_6:
 clr.w    -(sp)                    ; ab Beginn
 move.w   d4,-(sp)                 ; Handle
 moveq    #ph_sizeof,d1            ; Header
 add.l    ph_slen(a4),d1           ; Laenge der Symboltabelle
 add.l    d3,d1
 move.l   d1,-(sp)                 ; pos
 move.l   sp,a0
 bsr      D_Fseek
 addq.l   #8,sp
 tst.l    d0
 bmi      pld_clende

* Erste Relocationadresse einlesen (Langwort)

 lea      -$18(a6),a0
 moveq    #4,d1
 move.w   d4,d0
 bsr      Fread
__mon_7:
     ELSE
 clr.w    -(sp)                    ; ab Beginn
 move.w   d4,-(sp)                 ; Handle
 moveq    #ph_sizeof,d1            ; Header
 add.l    ph_slen(a4),d1           ; Laenge der Symboltabelle
 add.l    d3,d1
 move.l   d1,-(sp)                 ; pos
 move.l   sp,a0
 bsr      D_Fseek
 addq.l   #8,sp
 tst.l    d0
 bmi      pld_clende

* Erste Relocationadresse einlesen (Langwort)

 lea      -$18(a6),a0
 moveq    #4,d1
 move.w   d4,d0
 bsr      Fread
     ENDIF

 tst.l    d0
 bmi      pld_clende
 subq.l   #4,d0
 bne      pld_eplfmt
 tst.l    -$18(a6)
 beq      pld_endrelo
* DIE ERSTE RELOCATIONADRESSE IST != 0: ES MUss RELOZIERT WERDEN
 move.l   a5,d6
 add.l    -$18(a6),d6
 cmp.l    a5,d6
 bcs      pld_eplfmt               ; Falscher Bereich
 cmp.l    a3,d6
 bhi      pld_eplfmt               ; dito
* Relozieren
 btst     #0,d6
 bne      pld_eplfmt               ; ungerade Relocationadresse
 move.l   a5,d0
 movea.l  d6,a1
 add.l    d0,(a1)

* Schleife fuers Einlesen der Relocationbytes

pload_loop2:
 cmp.l    a5,d6
 bcs      pld_eplfmt
 cmp.l    a3,d6
 bhi      pld_eplfmt
* Relocationdaten ins BSS und ins freie Segment laden (soviele wie moeglich)

     IFNE MONITOR
 tst.w    d4
 bge.b    __mon_11
 lea      mon,a1
 add.l    d7,a1
 move.l   -$14(a6),d1
 move.l   a3,a0
__mon_13:
 move.b   (a1)+,(a0)+
 subq.l   #1,d1
 bgt.b    __mon_13
 add.l    -$14(a6),d7
 move.l   -$14(a6),d0
 bra.b    __mon_10

__mon_11:
 move.l   a3,a0
 move.l   -$14(a6),d1
 move.w   d4,d0
 bsr      Fread
__mon_10:
     ELSE
 move.l   a3,a0
 move.l   -$14(a6),d1
 beq      pld_eplfmt                    ; kein Platz zum Laden
 move.w   d4,d0
 bsr      Fread
     ENDIF

 tst.l    d0
 bmi      pld_clende
* -$10(a6) = Anzahl geladener Relocationbytes
 move.l   d0,-$10(a6)
* d5 ist Zaehler
 move.l   d0,d5
* a2 ist laufender Zeiger
 movea.l  a3,a2
* alle Daten verarbeiten
 bra      pload_l1
pload_loop:
 moveq    #0,d0
 move.b   (a2)+,d0
 bne      pld_no_endrelo

* Ein Nullbyte beendet die Relocationtabelle
* Es folgt optional die Maximallaenge des Heap

 cmpi.l   #9,d5
 bcs      pld_endrelo              ; keine Speicherdaten
 subq.l   #8,sp
 move.l   sp,a0
 moveq    #8-1,d0
pld_lim_loop:
 move.b   (a2)+,(a0)+
 dbra     d0,pld_lim_loop
 move.l   (sp)+,d0                 ; magic
 move.l   (sp)+,d1                 ; limit
 cmpi.l   #'MAGX',d0
 bne.b    pld_endrelo              ; magic ist falsch
 move.l   8(a6),a0
 move.l   d1,p_mem(a0)             ; Speicherlimit im PD vermerken
 bra      pld_endrelo


pld_no_endrelo:
 cmp.w    #1,d0
 bne.b    pload_l2
* Ein 1 - Byte erhoeht den Zaehler um 254 Bytes
 add.l    #$fe,d6
 bra.b    pload_l3
* Ansonsten wird eben reloziert
pload_l2:
 add.l    d0,d6
 btst     #0,d6
 bne      pld_eplfmt               ; ungerade Relocation- Adresse
 move.l   a5,d0
 movea.l  d6,a1
 add.l    d0,(a1)
* naechstes Byte
pload_l3:
 subq.l   #1,d5
pload_l1:
 tst.l    d5
 bne      pload_loop
* Wenn Dateiende nicht erreicht, weiter einlesen und relozieren
 move.l   -$10(a6),d0
 cmp.l    -$14(a6),d0
 beq      pload_loop2

* Speicherlimit auswerten

pld_endrelo:
 move.l   8(a6),a0                 ; PD *
 move.l   p_mem(a0),d1
 addq.l   #1,d1
 beq      pld_unlimited            ; war -1 (unbeschraenkt)
 subq.l   #1,d1
 move.l   p_hitpa(a0),d0
 sub.l    p_lowtpa(a0),d0          ; aktuelle Laenge (BP+TEXT+DATA+BSS+HEAP)
 move.l   p_tlen(a0),d2
 add.l    p_dlen(a0),d2
 add.l    p_blen(a0),d2
 add.l    #256,d2                  ; BP+TEXT+DATA+BSS
 sub.l    d0,d1
 add.l    d2,d1                    ; maxheap - heap
 move.l   d1,p_mem(a0)
 bge.b    pld_unlimited            ; maxheap >= heap
 clr.l    p_mem(a0)                ; aller Speicher vergeben
 add.l    d1,d0                    ; aktuelle Laenge reduzieren
 add.l    d1,p_hitpa(a0)           ; und in PD korrigieren
 add.l    d1,-$14(a6)              ; und zu loeschenden Speicher verkleinern
;move.l   d0,d0
 suba.l   a1,a1                    ; nolimit
;move.l   a0,a0
 bsr      Mxshrink

* BSS und Heap loeschen, Datei schliessen

pld_unlimited:
 move.l   ph_blen(a4),d0           ; bsslen
 btst     #0,ph_flags+3(a4)        ; Bit 0 von res2
 bne.b    pld_clr                  ; nur BSS loeschen
 move.l   -$14(a6),d0              ; BSS und Heap loeschen
pld_clr:
 lea      0(a3,d0.l),a1
 move.l   a3,a0
 jsr      fast_clrmem

 bsr      flush_cpu_cache          ; CPU-Caches loeschen

 moveq    #E_OK,d0
 bra.b    pld_clende
pld_ensmem:
 moveq    #ENSMEM,d0
 bra.b    pld_clende
pld_eplfmt:
 moveq    #EPLFMT,d0
pld_clende:
     IFNE MONITOR
 tst.w    d4
 ble.b    __mon_12
 move.l   d0,-(sp)
 move.w   d4,d0
 bsr      Fclose
 move.l   (sp)+,d0

__mon_12:
     ELSE
 move.l   d0,-(sp)
 move.w   d4,d0
 bsr      Fclose
 move.l   (sp)+,d0
     ENDIF
pld_ende:
     IFNE MONITOR
 move.l   (sp)+,d7
     ENDIF
 movem.l  (sp)+,a5/a4/a3/d6/d5/d4/d3
 unlk     a6
 rts



**********************************************************************
**********************************************************************
*
* MAGIX- Speicherverwaltung
*
**********************************************************************

**********************************************************************
*
* long Maddalt( void *start, long size)
*

D_Maddalt:
 move.l   a0,-(sp)
 jsr      Bmaddalt                 ; ggf. FRB anlegen
 move.l   (sp)+,a0
 tst.l    d0
 bne.b    mada_err2
 move.l   (a0)+,d1                 ; d1 = Blockadresse
 btst     #0,d1
 bne      mada_err                 ; Blockadresse ungerade!
 move.l   (a0),d0                  ; Blocklaenge
 move.l   d1,a0                    ; Blockadresse
 jmp      Maddalt
mada_err:
 moveq    #ENSMEM,d0               ; keine Liste frei
mada_err2:
 rts


**********************************************************************
*
* EQ/NE APPL *get_act_appl( void )
*

get_act_appl:
 move.l   xaes_appls,d0            ; XAES ?
 beq.b    gaa_ende                 ; nein, return(EQ)
 move.l   d0,a0
 cmpi.l   #'XAES',(a0)+            ; magische Kennung ?
 bne.b    gaa_nix                  ; nein, return(EQ)
 move.l   (a0),d0                  ; act_appl
 rts
gaa_nix:
 moveq    #0,d0
gaa_ende:
 rts



**********************************************************************
**********************************************************************
*
* interne Speicherverwaltung
*
**********************************************************************

**********************************************************************
*
* int getkey( void )
*

getkey:
 move.w   #2,-(sp)                 ; CON
 move.w   #2,-(sp)
 trap     #$d
 addq.w   #4,sp
 jmp      toupper


**********************************************************************
*
* void intmem_err()
*

intmem_err:
 lea      out_of_int_mem(pc),a0
 bra.b    _fatal_err


**********************************************************************
*
* void dos_fatal_err()
*

dos_fatal_err:
 lea      dos_fatal_errs(pc),a0
_fatal_err:
 jmp      halt_system              ; im BIOS


**********************************************************************
*
* void str_to_con(a0 = char *s)
*
* Ausgabe auf BIOS-Device 2 (CON)
*

str_to_con:
 move.l   a5,-(sp)
 move.l   a0,a5
 bra.b    s2c_next
s2c_loop:
 bsr      Bputch
s2c_next:
 clr.w    d0
 move.b   (a5)+,d0
 bne.b    s2c_loop
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* char *err_to_str(d0 = char err)
*
* Rueckgabe: d0: Zeiger auf Fehlertext oder NULL
*              a0: Zeiger auf Fehlertext oder Default- Fehlertext
*

err_to_str:
 lea      errcodes(pc),a0
 lea      errstrs-2(pc),a1
errt_loop:
 addq.l   #2,a1                    ; wegen Wortzugriff
 tst.b    (a0)
 beq.b    errt_notfound
 cmp.b    (a0)+,d0
 bne.b    errt_loop
 lea      errstrs(pc),a0
 add.w    (a1),a0
 move.l   a0,d0
 rts
errt_notfound:
 lea      toserrs(pc),a0
 moveq    #0,d0
 rts


**********************************************************************
*
* long etv_critic(int errno)
*  Rueckgabe (long):      Abbruch: errno
*                        Wiederh. $10000
*                        Ignor.    0
* (aus KCMD)
*

etv_critic_vec:
 st       criticret                ; MagiC 6.01: Semaphore setzen
 moveq    #$d,d0
 bsr      Bputch
 moveq    #$a,d0
 bsr      Bputch

 cmpi.w   #EOTHER,4(sp)
 bne.b    etvc_err
 lea      change_s1(pc),a0
 bsr.b    str_to_con
 moveq    #'A',d0
 add.w    6(sp),d0                 ; Laufwerknummer
 bsr      Bputch
 lea      change_s2(pc),a0
 bsr.b    str_to_con
 bra.b    etvc_input
etvc_err:
 move.w   4(sp),d0
 bsr.b    err_to_str
 bsr.b    str_to_con
 lea      diskerr_s1(pc),a0
 bsr.b    str_to_con
 moveq    #'A',d0
 add.w    6(sp),d0                 ; Laufwerknummer
 bsr      Bputch
 lea      diskerr_s2(pc),a0
 bsr      str_to_con
etvc_input:
 move.w   #BIOS_CON,-(sp)
 move.w   #Bconin,-(sp)
 trap     #13                      ; bios     Bconin
 addq.l   #4,sp
 cmpi.b   #3,d0                    ; ^C ?
 bne.b    etvc_nocc
 sf       criticret                ; MagiC 6.01: Semaphore loeschen
 jmp      dos_break
etvc_nocc:
 cmpi.w   #EOTHER,4(sp)
 beq.b    etvc_nochoice
 jsr      toupper
 cmpi.b   #'R',d0
 beq.b    etvc_retry               ; [R]etry
 cmpi.b   #'A',d0   * Abbruch
 bne.b    etvc_noA
 move.w   4(sp),d1
 ext.l    d1
 bra.b    etvc_back
etvc_nochoice:
 moveq    #' ',d0
 bra.b    etvc_retry
etvc_noA:
 cmpi.b   #'W',d0   * Wiederh.
 bne.b    etvc_now
etvc_retry:
 move.l   #$10000,d1
 bra.b    etvc_back
etvc_now:
 cmpi.b   #'I',d0   * Ignor.
 bne.b    etvc_input
 moveq    #0,d1
etvc_back:
 move.l   d1,-(sp)  * Rueckgabewert auf Stapel retten
 move.w   d0,-(sp)  * Eingegebenes Zeichen ausgeben
 move.w   #5,-(sp)  ; Device 5 (RAWCON)
 move.w   #3,-(sp)
 trap     #13                      ; bios Bconout
 addq.l   #6,sp
 moveq    #$d,d0
 bsr      Bputch
 moveq    #$a,d0
 bsr      Bputch
 move.l   (sp)+,d0  * Rueckgabewert von Stapel
 sf       criticret                ; MagiC 6.01: Semaphore loeschen
 rts


**********************************************************************
*
* void resvb_intmem(d0 = int num)
*
* Alloziert und reserviert <num> Bloecke fuer internen Speicher.
*

resvb_intmem:
 mulu     #imb_sizeof,d0
 move.l   d0,-(sp)
 move.w   #$4002,d1           ; dontfree, ST-RAM preferred
 move.l   act_pd,a1
 bsr      Mxalloc
 move.l   d0,a0
 move.l   (sp)+,d0
 move.l   a0,d1
 bgt.b    resv_intmem
 rts


**********************************************************************
*
* void resv_intmem(a0 = void *mem, d0 = long bytes)
*
* reserviert ab Adresse <mem> <bytes> Bytes als internen Speicher
* Der Bereich wird in 70-Byte-Bloecke zersaegt, die als frei markiert
* und in die imbx[] - Liste eingetragen werden
*

resv_intmem:
 moveq    #imb_sizeof,d1
resv_loop:
 sub.l    d1,d0
 bcs.b    resv_end
 move.l   imbx,(a0)
 move.l   a0,imbx
 clr.b    imb_used(a0)
 adda.l   d1,a0
 bra.b    resv_loop
resv_end:
 rts


**********************************************************************
*
* long collect_IMB( void )
*
* Sucht ueberall nach einem unbenutzten IMB und gibt 1 oder 0 zurueck
*

collect_IMB:
 movem.l  d7/a5,-(sp)
* a5 durchlaeuft alle Laufwerke (DMDs) von 0 bis LASTDRIVE
 moveq    #0,d7                    ; noch nichts erreicht
 lea      dmdx,a5
coli_loop:
 move.l   (a5)+,d0
 beq.b    coli_next                ; Laufwerk nicht bekannt
 move.l   d0,a0
 move.l   d_xfs(a0),a2
 move.l   xfs_garbcoll(a2),d0
 beq.b    coli_next                ; keine garbage collection
 move.l   d0,a2
 jsr      (a2)
 or.l     d0,d7
* naechstes Laufwerk
coli_next:
 cmpa.l   #dmdx+4*LASTDRIVE,a5
 bls.b    coli_loop
 move.l   d7,d0
 movem.l  (sp)+,d7/a5
 rts


**********************************************************************
*
* d0 = long int_mblocks()
*
* ermittelt die Zahl der Bloecke, die fuer den internen Speicher zur
* Verfuegung stehen.
*

int_mblocks:
 moveq    #0,d0
 movea.l  imbx,a0
 bra.b    intmb_nextimb
intmb_imb_loop:
 addq.l   #1,d0
 movea.l  (a0),a0                  ; naechster IMB
intmb_nextimb:
 move.l   a0,d1
 bne.b    intmb_imb_loop
 rts


**********************************************************************
*
* d0 = DMD/DD/FD  *int_malloc()
*
* gibt einen Zeiger auf einen freien FD/DD/DMD zurueck (FDSIZE Bytes)
* der neue Block wird komplett genullt.
*

int_malloc:
 movea.l  imbx,a0
 bra.b    intm_nextimb
intm_imb_loop:
 tst.b    imb_used(a0)
 beq      intm_ende                ; Block frei
 movea.l  (a0),a0                  ; naechster IMB
intm_nextimb:
 move.l   a0,d0
 bne.b    intm_imb_loop

 bsr.s    collect_IMB
 tst.l    d0                       ; war erfolgreich ?
 bne.b    int_malloc               ; ja!
 bra      intmem_err

intm_ende:
 st       imb_used(a0)             ; "f",$81,"r DD/FD/DMD benutzt"
 addq.l   #imb_data,a0
 move.l   a0,-(sp)                 ; Zeiger auf Datenbereich merken
 lea      FDSIZE(a0),a1
 jsr      fast_clrmem
 move.l   (sp)+,d0                 ; Zeiger auf Datenbereich zurueck
 rts


**********************************************************************
*
* a0 = IMB *int_pmalloc()
*
* gibt einen Zeiger auf einen freien FD/DD/DMD zurueck
*    (FDSIZE+imb_data Bytes)
* Der Block wird aus der internen Speicherverwaltung entfernt.
* Der neue Block wird NICHT genullt.
*

int_pmalloc:
 lea      imbx,a1
 bra.b    intpm_nextimb
intpm_imb_loop:
 move.l   d0,a0
 tst.b    imb_used(a0)
 beq      intpm_ende               ; Block frei
 move.l   a0,a1
intpm_nextimb:
 move.l   (a1),d0
 bne.b    intpm_imb_loop

 bsr      collect_IMB
 tst.l    d0                       ; war erfolgreich ?
 bne.b    int_pmalloc              ; ja!
 bra      intmem_err

intpm_ende:
 move.l   (a0),(a1)                ; Block ausklinken
 rts


**********************************************************************
*
* d0 = long int_garbcoll( void )
*
* macht eine garbage collection und gibt 1, falls welche frei
* geworden sind.
*

int_garbcoll:
 bsr      collect_IMB
 tst.l    d0                       ; war erfolgreich ?
 beq.b    intg_ende
 moveq    #1,d0
intg_ende:
 rts


**********************************************************************
*
* d0 = long  int_mavail(a1 = long n[2])
*
* gibt Anzahl der freien+belegten Bloecke zurueck
*

int_mavail:
 clr.l    (a1)                     ; auf 0 initialisieren
 clr.l    4(a1)
 movea.l  imbx,a0
 bra.b    inta_nextimb
inta_imb_loop:
 tst.b    imb_used(a0)
 bne.b    inta_used
 addq.l   #1,(a1)
 bra.b    inta_both
inta_used:
 addq.l   #1,4(a1)
inta_both:
 movea.l  (a0),a0                  ; naechster IMB
inta_nextimb:
 move.l   a0,d0
 bne.b    inta_imb_loop
 rts


**********************************************************************
*
* void int_mfree(a0 = FD/DD/DMD *int_mblock)
*
* nichts korrigiert, nur stark optimiert
*

int_mfree:
 subq.l   #imb_data-imb_used,a0
* Ist freizugebender Block etwa schon frei ?
 tst.b    (a0)
 beq      dos_fatal_err            ; ja => interner Fehler, System anhalten
* Nein => Block freigeben
 clr.b    (a0)
 rts



**********************************************************************
**********************************************************************
*
* Systemfunktionen
*
**********************************************************************
**********************************************************************
*
* dos_trap2()
*
* TRAP #2 Routine des GEMDOS
*
* d0 =     0: Pterm(0)
* d0 = $0073: VDI
* d0 =    -1: Zeiger auf VDI- Dispatcher zurueckgeben (vq_driver)
* sonst        : alten Vektor aufrufen
*

dos_trap2:
 cmp.w    #$73,d0
 bne.b    dt2_no_vdi
 jsr      vdi_entry
 rte
dt2_no_vdi:
 cmpi.w   #$ca,d0
 bne.b    dtrp2_l1
 jmp      (a2)                ; MagiC 5.20: Schnell in den Supermode
dtrp2_l1:
 tst.w    d0
 beq.b    dtrp2_l2
 cmp.w    #-1,d0
 bne.b    dtrp2_l3
 move.l   #vdi_entry,d0
 rte
dtrp2_l3:
 move.l   otrap2,-(sp)
 rts
dtrp2_l2:
 bsr      Pterm0
 illegal
 rte


**********************************************************************
*
* dos_trap1(int old_sr) Parameter auf USP         * vom Usermode
* dos_trap1(int old_sr, int *old_pc, ... )        * vom Supervisormode
*
* zerstoert a0/d0, Super zerstoert auch d1
*

dos_trap1:
 move.l   usp,a0                   ; a0 = Parameter (user)
 btst     #5,(sp)
 beq.b    dt_fromusr
 lea      6(sp),a0                 ; a0 = Parameter (super, 68000)
 tst.w    cpu_typ.w
 beq.b    dt_fromany
 addq.l   #2,a0                    ;                (       680x0)
 bra.b    dt_fromany
dt_fromusr:
 tst.w    pe_slice.w
 bmi.b    dt_fromany               ; praeemptives Multitasking abgeschaltet
 cmpi.w   #$4a,(a0)                ; Mshrink ?
 bne.b    dt_yield                 ; nein, normale Funktion
 move.w   pe_slice.w,pe_timer.w    ; Mshrink: Timer korrigieren, kein yield
 bra.b    dt_fromany
dt_yield:
 jsr      appl_yield               ; aus Usermodus: YIELD
dt_fromany:
 cmpi.w   #$20,(a0)
 beq      Super

     IFNE DEBUG_FN
 bra.b    gogogo

hexw:
 movem.l  d6/d7,-(sp)
 move.w   d0,d7
 moveq    #4-1,d6                  ; 4 Hex- Stellen
hexw_loop:
 rol.w    #4,d7                    ; hoechstes Nibble in die unteren 4 Bit
 move.w   d7,d0
 bsr.b    _hex
 dbra     d6,hexw_loop
 movem.l  (sp)+,d6/d7
 rts

_hex:
 andi.w   #$f,d0
 addi.b   #'0',d0
 cmpi.b   #'9',d0
 ble.b    _hex_1
 addi.b   #'A'-'0'-10,d0
_hex_1:
 bra      Bputch

gogogo:
 movem.l  d0-d3/a0-a2,-(sp)
 move.w   (a0),d0
 bsr      hexw
 jsr      crlf
 bsr      getkey
 movem.l  (sp)+,d0-d3/a0-a2
     ENDIF

 movem.l  d1/d2/a1/a2,-(sp)        ; wegen Kompatibilitaet zu TOS

 lea      dos_fx(pc),a1
 move.w   (a0)+,d0                 ; Funktionsnummer
 cmpi.w   #$5c,d0
     IFNE DEBUG_FN
 bls      dt_go                    ; GEMDOS- Funktionsnummer
 cmpi.w   #$153,d0
 bhi      dt_einvfn
 subi.w   #$ff,d0
 bcs      dt_mac_xtension
     ELSE
 bls.b    dt_go                    ; GEMDOS- Funktionsnummer
 cmpi.w   #$153,d0
 bhi.b    dt_einvfn
 subi.w   #$ff,d0
 bcs.b    dt_mac_xtension
     ENDIF
 lea      dos_fx2(pc),a1           ; MiNT- Funktionsnummer
dt_go:
 add.w    d0,d0
 adda.w   0(a1,d0.w),a1

     IF   DEBUG_FN
 movem.l  d0-d3/a0-a2,-(sp)
 DEB      'DOS-Aufruf...'
 move.l   $1038272,d0
 DEBL     d0,' $1038272 = '
 move.l   $1038272+12,d0
 DEBL     d0,' $1038272+12 = '
 movem.l  (sp)+,d0-d3/a0-a2
     ENDIF

 jsr      (a1)
dt_ret:

     IF   DEBUG_FN
 movem.l  d0-d3/a0-a2,-(sp)
 DEB      '...DOS-Aufruf beendet'
 move.l   $1038272,d0
 DEBL     d0,' $1038272 = '
 move.l   $1038272+12,d0
 DEBL     d0,' $1038272+12 = '
 movem.l  (sp)+,d0-d3/a0-a2
     ENDIF

 movem.l  (sp)+,d1/d2/a1/a2
leave_dos:
 tst.w    pe_slice.w
 bmi.b    dt_rte                   ; praeemptives Multitasking abgeschaltet
 tst.w    pe_timer.w               ; Timer ist abgelaufen ?
 bne.b    dt_rte
 btst     #5,(sp)
 bne      dt_rte                   ; aus Supervisormode nicht abfangen
 jsr      appl_suspend
dt_rte:
 rte                               ; Ruecksprung

dt_mac_xtension:
 addi.w   #$ff,d0
 jsr      dos_macfn                ; spezielle Mac-Routinen
     IFNE DEBUG_FN
 bra      dt_ret
     ELSE
 bra.b    dt_ret
     ENDIF
dt_einvfn:
 moveq    #EINVFN,d0
 bra      dt_ret


**********************************************************************
*
* long Super ( d0 = char is_sup, a0 = void *param )
*
* Super() zerstoert d1 !!
*

Super:
 btst     #5,(sp)
 sne      d0                       ; d0 = TRUE, wenn aus dem Supervisormode
 move.l   2(a0),d1                 ; Super(0L) ?
 beq      super_0
 subq.l   #1,d1                    ; Super(1L) ?
 bne.b    super_sp                 ; nein
 ext.w    d0
 ext.l    d0                       ; Status 0L=user, -1L=super
 rte
super_sp:
 move.l   2(a0),a0                 ; neuer sp
super_0:
 bsr.b    exc_to_a0                ; sr/pc/vo von (sp) nach (a0)
 eori.w   #$2000,(a0)              ; Supervisorbit umdrehen
 tst.b    d0
 beq      super_usr                ; vom Usermodus
 move.l   sp,usp
super_usr:
 move.l   sp,d0                    ; alten ssp zurueck
 move.l   a0,sp
 bra      leave_dos


**********************************************************************
*
* long exc_to_a0 ( a0 = void *stack )
*
* kopiert sr/pc/(vo) vom Stack nach a0 um
*

exc_to_a0:
 tst.w    cpu_typ.w
 beq.b    eta_00
 move.l   8(sp),-(a0)
 move.l   4(sp),-(a0)              ; Vektoroffset/pc/sr umkopieren
 move.l   (sp),8(sp)               ; Ruecksprungadresse
 addq.l   #8,sp
 rts
eta_00:
 move.l   6(sp),-(a0)              ; pc umkopieren
 move.w   4(sp),-(a0)              ; sr umkopieren
 move.l   (sp),6(sp)               ; Ruecksprungadresse
 addq.l   #6,sp
 rts


**********************************************************************
*
* void _start_fork ( void )
*
* Startadresse fuer ge-fork-ten Prozess. Die Basepage hatte in
* p_tbase einen Zeiger auf diese Prozedur.
* Der neue Prozess wird dummerweise zunaechst im User-Mode
* gestartet.
*

_start_fork:
 lea      _stf_go(pc),a2
 move.w   #$ca,d0             ; schnell in den Supermode
 trap     #2
_stf_go:
 move.l   act_pd,a5
 move.l   256(a5),p_tbase(a5) ; tbase wieder korrigieren
 move.l   256+4(a5),d0        ; Laenge des geerbten Supervisor-Stack
 suba.l   d0,sp               ; Platz dafuer schaffen
 move.l   sp,a0               ; dst
 lea      256+8(a5),a1        ; src
 jsr      vmemcpy              ; Supervisorstack kopieren
 move.l   #256,d0
 move.l   a5,a0
 bsr      Mshrink             ; Platz fuer geerbten Stack wieder freigeben
; Signalhandler vererben
 move.l   p_parent(a5),d0
 beq.b    _stf_e1
 move.l   d0,a0
 move.l   p_procdata(a0),d0
 beq.b    _stf_e1
 move.l   d0,a1
 lea      pr_sigdata(a1),a1        ; Quelle
 move.l   p_procdata(a5),a0
 lea      pr_sigdata(a0),a0        ; Ziel
 move.l   #32*sa_sizeof,d0    ; Laenge
 jsr      vmemcpy
_stf_e1:
; neuen Prozess starten
 moveq    #0,d0               ; P(v)fork() liefert 0 fuer das Kind
 bra      fork_end            ; Kind starten


**********************************************************************
*
* long D_Pvfork ( void )
*
* legt eine Kopie des aktuellen Prozesses an. Haelt den aufrufenden
* Prozess an.
* Es werden nur die CPU-Register a3-a6/d3-d7/usp vererbt.
*
* Fork() erstellt eine neue Basepage, dahinter werden folgende
* Daten kopiert, die beim Start des neuen Prozesses benoetigt werden:
*
* LONG tbase                  ; Beginn des Textsegments
* LONG ssplen                 ; Laenge des Supervisorstacks
* char sstack[?]              ; Supervisor-Stack
*

D_Pfork:
 moveq    #1,d0
 bra.b    _pfork
D_Pvfork:
 moveq    #0,d0
_pfork:
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   usp,a0
 move.l   a0,-(sp)
 move.w   sr,-(sp)
 move.l   act_pd,a5
 suba.l   a4,a4               ; kein geretteter Speicher

* ggf. Speicher retten

 tst.w    d0
 beq.b    fork_nosave
 clr.l    -(sp)
 move.l   act_appl.l,-(sp)
 lea      (sp),a1             ; Ausnahmeliste
 move.l   a5,a0               ; alter Prozess
 bsr      Pmemsave
 addq.l   #8,sp
 tst.l    d0
 bmi      fork_end
 move.l   d0,a4               ; geretteter Speicher
fork_nosave:

* neue Basepage erstellen
 pea      -1                  ; kein Environment
 clr.l    -(sp)               ; Kommandozeile
 clr.l    -(sp)
 move.w   #5,-(sp)            ; Erstelle Basepage
 move.l   sp,a0
 bsr      D_Pexec
 adda.w   #14,sp
 tst.l    d0
 bmi      fork_end
 move.l   d0,a6               ; a6 := neue Basepage
* Bit 1 von pr_flags setzen, damit Handles vererbt werden.
 move.l   a6,a0
 move.l   p_procdata(a0),a0
 bset     #1,pr_flags+1(a0)
* Speicherbedarf fuer Kopie des Supervisor-Stacks berechnen
 move.l   act_appl.l,d0
 beq      fork_einvfn         ; kein MT
 move.l   d0,a0
 lea      ap_stack(a0),a0     ; Beginn des Stacks ...
 add.l    sust_len.w,a0       ; ... + Laenge ergibt das Ende

;  move.l a0,$4a8
;  move.l sp,$4ac

 sub.l    sp,a0               ; so gross ist der aktuelle Stack
 move.l   a0,d7
 lea      256+8(a0),a0        ; + Platz fuer Basepage
* Basepage enthaelt Kopie des Parent-Supervisor-Stacks
 move.l   a0,d0
 move.l   a6,a0
 bsr      Mshrink
 tst.l    d0
 bmi.b    fork_endfr          ; zuwenig Speicher!
* Basepage gehoert neuem Prozess
 move.l   a6,a1               ; neuer Eigentuemer
 move.l   a6,a0               ; Blockadresse
 bsr      Mchgown
* neuen Task mit neuer Basepage erstellen
 move.w   #104,d0             ; Pexec(104): Basepage parallel starten
 suba.l   a0,a0               ; Namen des Parent verwenden
 move.l   a6,a1               ; Basepage
 lea      -1,a2               ; kein Environment!
 jsr      exec_10x            ; -> AESMAIN
 tst.l    d0
 bmi.b    fork_endfr
 move.l   a5,p_parent(a6)     ; wichtig (!)
* Supervisor-Stack kopieren
 move.l   d7,d0               ; Stack-Groesse
 move.l   act_appl.l,a1
 lea      (sp),a1             ; src
 lea      256+8(a6),a0        ; dst
 jsr      vmemcpy              ; Supervisor-Stack kopieren
* Diverse Felder der Basepage kopieren
 move.l   a5,a1               ; src
 move.l   a6,a0               ; dst
 moveq    #p_dta,d0           ; len
 jsr      vmemcpy              ; lowpa,hitpa,tbase,tlen,dbase,dlen,bbase,blen
 move.l   p_env(a5),p_env(a6)
 move.l   p_tbase(a5),256(a6)
 btst     #0,p_flags(a5)      ; MiNT-Domain?
 beq.b    fork_tosdomain
 bset     #0,p_flags(a6)      ; Domain
fork_tosdomain:
 move.l   d7,256+4(a6)
 lea      _start_fork(pc),a1
 move.l   a1,p_tbase(a6)      ; Startadresse umsetzen

* einschlafen

 move.l   a6,a0               ; auf den warten wir
 jsr      evnt_fork
;move.l   d0,d0               ; => PID des Kindes
 bra.b    fork_end
fork_einvfn:
 moveq    #EINVFN,d0
* bei Fehler Basepage wieder freigeben
fork_endfr:
 move.l   a6,a0
 move.l   d0,a6
 bsr      Mfree
 move.l   a6,d0
fork_end:
 move.l   a4,d1               ; geretteter Speicher?
 beq.b    fork_nomems         ; nein
 move.l   d0,d6
 bmi.b    fork_was_err
 beq.b    fork_nomems         ; ich bin der Kindprozess
 moveq    #1,d0               ; war OK, zurueckkopieren
 bra.b    fork_was_both
fork_was_err:
 moveq    #0,d0               ; nur freigeben
fork_was_both:
 move.l   a5,a1               ; proc
 move.l   a4,a0               ; Liste
 bsr      Pmemrestore
 move.l   d6,d0
fork_nomems:
 move.w   (sp)+,sr
 move.l   (sp)+,a0
 move.l   a0,usp
 movem.l  (sp)+,d3-d7/a3-a6
 rts


**********************************************************************
*
* LONG dpex_200 ( a0 = void *params )
*
* MiNT-Pexec-Modus (ab 1.11.98)
*

dpex_200:
 movem.l  a4/a5/a6,-(sp)
* Programm laden
 move.l   10(a0),-(sp)             ; env
 move.l   6(a0),-(sp)              ; cmdline
 move.l   2(a0),-(sp)              ; name
 move.w   #EXE_LD,-(sp)
 move.l   sp,a0
 bsr      Pexec                    ; => Basepage
 adda.w   #14,sp
 tst.l    d0
 bmi      dpex200_ende             ; Fehler beim Laden
 move.l   d0,a6                    ; a6 = neue Basepage
* Einige Eintraege in PROCDATA vom neuen Prozess uebernehmen:
* pr_fname, pr_cmdlin, pr_flags, pr_procname
 move.l   p_procdata(a6),a1
 move.l   act_pd,a4                ; a4 := alter Prozess
 move.l   p_procdata(a4),a0
 lea      pr_fname(a0),a0
 lea      pr_fname(a1),a1
 move.w   #pr_bconmap-pr_fname,d0
 jsr      vmemcpy
 suba.l   a1,a1                    ; kein limit
 move.l   p_procdata(a6),a0
 jsr      Mxfree                   ; neues p_procdata freigeben
* wichtige Eintraege in der Basepage kopieren (ausser p_env)
* der Zeiger auf PROCDATA wird mitkopiert
 move.l   p_env(a6),-(sp)          ; neues Env. retten
 lea      p_parent(a4),a1          ; kopieren ab p_parent
 lea      p_parent(a6),a0
 move.w   #p_cmdlin-p_parent,d0    ; kopieren bis p_cmdlin
 jsr      vmemcpy
 move.l   (sp)+,p_env(a6)          ; neues Env zurueck
* neue Basepage, neues Env, altes PROCDATA gehoeren neuem Prozess
 move.l   a6,a0                    ; neuer PD
 bsr      chg_bp_owner
* Eigner der APPL, ap_env und ap_xtail aendern, falls sie altem Prozess gehoert
 move.l   act_appl.l,d0
 beq.b    dpex_no_appl             ; ??
 move.l   d0,a5                    ; a5 = APPL *
 move.l   a5,a0                    ; memadr
 lea      -1,a1                    ; nur Eigner ermitteln
 bsr      Mchgown
 cmpa.l   d0,a4                    ; gehoert APPL altem Prozess ?
 bne.b    dpex_no_appl             ; nein, nicht aendern
 move.l   a5,a0                    ; memadr
 move.l   a6,a1                    ; neuer Eigner
 bsr      Mchgown                  ; Eigner der APPL umsetzen
 move.l   ap_env(a5),d0
 beq.b    dpex_no_apenv
 move.l   d0,a0                    ; memadr
 move.l   a6,a1                    ; neuer Eigner
 bsr      Mchgown                  ; Eigner des ap_env umsetzen
dpex_no_apenv:
 move.l   ap_xtail(a5),d0
 beq.b    dpex_no_appl
 move.l   d0,a0                    ; memadr
 move.l   a6,a1                    ; neuer Eigner
 bsr      Mchgown                  ; Eigner des ap_xtail umsetzen
dpex_no_appl:
* Speicher des alten Prozesses freigeben
 move.l   a4,a0
 bsr      slb_close_all            ; alle shared libraries freigeben
* p_parent der Kinder korrigieren
 move.l   a6,a1                    ; new_pd
 move.l   a4,a0                    ; old_pd
 bsr      adjust_parents
* Threads entfernen
 move.l   act_appl.l,d0
 beq.b    dpex200_no_aes
 move.l   act_pd,a0
 jsr      pkill_threads            ; alle Threads ausser aktueller APP killen
dpex200_no_aes:
* Sprung ueber config_status+24
 move.l   (config_status+24).w,d0
 beq.b    dpex200_no_tidy
 move.l   d0,a2
 move.l   a4,a0                    ; PD *
 jsr      (a2)
dpex200_no_tidy:
* ggf. ge-fork-ten parent wieder aufwecken
 move.l   a4,a0
 jsr      hap_fork                 ; ggf. wartenden Parent aufwecken
* Prozessnamen aus procx[] und aus u:\proc entfernen
 move.l   a4,a0
 bsr      delete_procname
* neuen Prozessnamen eintragen
 move.l   a6,a0
 bsr      create_procname
* etv_term entfernen
 pea      dpex_rts(pc)
 move.l   #$50102,-(sp)            ; bios Setexc
 trap     #$d
 addq.w   #8,sp
* LOCKs entfernen
 move.l   a4,a0
 bsr      kill_locks
* Alle zum Prozess gehoerigen Semaphoren freigeben
 move.l   a4,a0
 moveq    #SEM_FPD,d0
 jsr      evnt_sem
* Alle Speicherbloecke freigeben. Da PROCDATA von neuem
* und alten Prozess identisch sind, wird dabei die pr_memlist
* auf NULL gesetzt
 move.l   a4,a0
 bsr      Pfree
* act_pd umsetzen
 move.l   a6,act_pd
 move.l   a5,d0
 beq.b    dpex200_noap
 move.l   a6,ap_pd(a5)             ; in Applikationsstruktur eintragen
dpex200_noap:
* User-Stack aufbauen
 move.l   p_hitpa(a6),a1           ; usp liegt am Ende der hitpa
 move.l   a6,-(a1)                 ; aufger. Pgm: 4(a7) = PD *
 clr.l    -(a1)                    ; aufger. Pgm (a7) = 0L
* Supervisor-Stack aufbauen
 move.l   p_ssp(a6),sp             ; ssp restaurieren
 tst.w    cpu_typ.w
 beq.b    dpex_00
 clr.w    -(sp)                    ; Vektoroffset
dpex_00:
 move.l   8(a6),-(sp)              ; pc
 clr.w    -(sp)                    ; sr (Usermode, INT=0)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)                    ; d1/d2/a1/a2 sind alle 0
 pea      dt_ret(pc)               ; Ruecksprungadresse im DOS
 clr.l    -(sp)                    ; a6
 move.l   p_dbase(a6),-(sp)        ; a5
 move.l   p_bbase(a6),-(sp)        ; a4
 moveq    #6-1,d0
dpex_regloop:
 clr.l    -(sp)                    ; d3-d7/a3 sind 0
 dbra     d0,dpex_regloop
 move.l   a1,-(sp)                 ; usp  (bei ACC NULL)
 move.l   sp,p_context(a6)
 moveq    #0,d0
 bra      start_proc               ; Prozess starten
dpex200_ende:
 movem.l  (sp)+,a6/a5/a4
dpex_rts:
 rts


**********************************************************************
*
* long dpex_10x ( a0 = void *params )
*
* MiNT-Pexec-Modus
*
* 29.9.96:     p_status wird bei Erfolg auf PROCSTATE_MINT gesetzt,
*              damit die Basepage bei der Terminierung nicht
*              freigegeben wird und stattdessen der Prozess in den
*              ZOMBIE-Status uebergeht.
*

dpex_10x:
 move.w   (a0)+,d0
 move.l   (a0)+,d1            ; path
 move.l   (a0)+,a1            ; tail
 move.l   (a0),a2             ; env
 move.l   d1,a0
 jsr      exec_10x            ; -> AESMAIN
 tst.l    d0
 bmi.b    dp100_err
 move.l   d0,a0               ; PD *
 move.w   #PROCSTATE_MINT,p_status(a0)  ; nach Terminierung => Zombie
 move.l   act_pd,p_parent(a0)           ; wichtig (!)
 moveq    #0,d0               ; unsigned
 move.w   p_procid(a0),d0
dp100_err:
 rts


**********************************************************************
*
* long D_Pexec ( a0 = void *params )
*
* rettet den Kontext des aktuellen Prozesses, fuehrt die DOS- Funktion
* aus und startet den Prozess wieder.
* d1/d2/a1/a2 sind bereits gerettet.
*

D_Pexec:
 cmpi.w   #100,(a0)
 beq      dpex_10x                 ; MiNT-Modus (->AES)
 cmpi.w   #104,(a0)
 beq      dpex_10x                 ; MiNT-Modus (->AES)
 cmpi.w   #106,(a0)
 beq      dpex_10x                 ; MiNT-Modus (->AES)
 cmpi.w   #200,(a0)
 beq      dpex_200

 movem.l  d3-d7/a3-a6,-(sp)        ; restliche Register sichern
 move.l   usp,a1
 move.l   a1,-(sp)                 ; usp sichern
 move.l   act_pd,a1
 move.l   sp,p_context(a1)         ; ssp sichern
 lea      -$34(a0),a2
 move.l   a2,p_reg(a1)             ; wegen Kompatibilitaet zu TOS stehen
                                   ; ab Offset $32 die Pexec- Parameter
                                   ; a0 war schon um 2 erhoeht, daher -$34
;move.l   a0,a0
 bsr      Pexec
;bra      start_proc               ; aktuellen Prozess starten


**********************************************************************
*
* long start_proc ( d0 = long retcode )
*
* startet einen "schlafenden" (den aktuellen) Prozess und gibt ihm
* den Rueckgabewert d0
*
* proc.p_context->  long      usp;
*                   long      d3_d7_a3_a6[9];
*                   long      pc        -> leave_dos
*                   long      d1_d2_a1_a2[4]
*                   long      user_pc
*                   int       sr
*                  [int       vo]
*

start_proc:
 move.l   act_pd,a0
 move.l   p_context(a0),sp
 move.l   (sp)+,a0
 move.l   a0,usp                   ; usp zurueck
 movem.l  (sp)+,d3-d7/a3-a6        ; Register zurueck
 suba.l   a0,a0                    ; GEMDOS startet mit a0=NULL !!!
                                   ; damit unterscheidet man, ob APP oder ACC
 rts                               ; pc zurueck


**********************************************************************
*
* long start_acc ( d0 = long retcode )
*
* startet ein ACC (den aktuellen) Prozess und gibt ihm
* den Rueckgabewert d0
*
* proc.p_context->  long      usp;
*                   long      d3_d7_a3_a6[9];
*                   long      pc        -> leave_dos
*                   long      d1_d2_a1_a2[4]
*                   long      user_pc
*                   int       sr
*                  [int       vo]
*

start_acc:
 move.l   act_pd,a0
 move.l   p_context(a0),sp
 move.l   (sp)+,a1
 move.l   a1,usp                   ; (usp ist NULL bei ACCs)
 movem.l  (sp)+,d3-d7/a3-a6        ; Register zurueck
 rts                               ; pc zurueck


**********************************************************************
*
* long ill_func()
*

ill_func:
D_Prusage:
D_Pmsg:
D_Fmidipipe:
D_Salert:
D_Psigintr:
D_Suptime:
D_Pgetgroups:
D_Psetgroups:
D_Tsetitimer:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long Ssync( void )
*
* synchronisiert alle Dateisysteme
*

Ssync:
 movem.l  a6/a5/d7/d6,-(sp)
 move.l   act_pd,a0
 cmpa.l   bufl_wback,a0       ; Ssync kommt vom Writeback-Daemon ?
 seq      d6                  ; d6.b = TRUE: WB aktiv
 lea      dmdx,a6
 lea      bufl_timer,a5
 moveq    #0,d7
sync_loop:
 move.l   (a6)+,d0
 ble.b    sync_nxtloop        ; Dateisystem ungueltig
 move.l   d0,a0
 tst.w    d_biosdev(a0)       ; BIOS-Laufwerk ?
 bmi.b    sync_sync           ; nein, immer synchronisieren
 move.l   (a5),d1
 beq.b    sync_nxtloop        ; Laufwerk gerade in Benutzung oder unbenutzt
 tst.b    d6                  ; Writeback aktiv ?
 beq.b    sync_sync           ; nein, immer synchronisieren
 move.l   _hz_200,d0
 sub.l    d1,d0               ; wie lange ist letzter Zugriff her ?
 cmp.l    #200,d0             ; 1s ?
 bcs.b    sync_nxtloop        ; < 2s
sync_sync:
 move.l   d_xfs(a0),a2
 move.l   xfs_sync(a2),a2
 jsr      (a2)
sync_nxtloop:
 addq.l   #4,a5
 addq.w   #1,d7
 cmpi.w   #LASTDRIVE,d7
 bls.b    sync_loop
 movem.l  (sp)+,a6/a5/d7/d6
 rts


**********************************************************************
*
* long Sunmount( a0 = DMD *dmd )
*
* sperrt alle Dateisysteme, die <dmd->d_devcode> haben
*

Sunmount:
 movem.l  a6/a5/a4/d7,-(sp)
 suba.w   #LASTDRIVE+LASTDRIVE+4,sp
 move.l   a0,a5               ; a5 = dmd
 lea      (sp),a4             ; noch nix gesperrt

; 1. Phase: DMDs sperren

 lea      dmdx,a6
 moveq    #0,d7
sunm_loop:
 move.l   (a6)+,d0
 ble.b    sunm_nxtloop        ; Dateisystem ungueltig
 move.l   d0,a0
 move.l   d_devcode(a5),d0    ; devcode ungueltig ?
 beq.b    sunm_nur1           ; ja, nur ein Dateisystem unmounten
 cmp.l    d_devcode(a0),d0    ; selber devcode
 bne.b    sunm_nxtloop        ; nein
 bra.b    sunm_dlock          ; ja, locken
sunm_nur1:
 cmpa.l   a5,a0               ; bin ich es ?
 bne.b    sunm_nxtloop        ; nein
sunm_dlock:
 move.w   d7,-(sp)            ; drive
 move.w   #1,-(sp)            ; sperren
 move.l   sp,a0
 bsr      D_Dlock
 addq.l   #4,sp
 tst.l    d0
 bne.b    sunm_unlock         ; Fehler, unlocken
sunm_locked:
 move.w   d7,(a4)+            ; Laufwerk merken !
sunm_nxtloop:
 addq.w   #1,d7
 cmpi.w   #LASTDRIVE,d7
 bls.b    sunm_loop
 moveq    #0,d0               ; kein Fehler

; 2. Phase: DMDs freigeben

sunm_unlock:
 move.l   d0,d7               ; Fehlercode merken
sunm_unlloop:
 move.w   -(a4),d0
 cmpa.l   sp,a4
 bcs.b    sunm_unllendloop
 move.w   d0,-(sp)
 clr.w    -(sp)
 move.l   sp,a0
 bsr      D_Dlock             ; freigeben !
 addq.l   #4,sp
 bra.b    sunm_unlloop
sunm_unllendloop:
 move.l   d7,d0               ; Fehlercode
 adda.w   #LASTDRIVE+LASTDRIVE+4,sp
 movem.l  (sp)+,a6/a5/a4/d7
 rts


**********************************************************************
*
* long Sversion()
*

Sversion:
 move.l   #$2000,d0           ; $2000 ab MagiC 6.20, vorher $1900
 rts


**********************************************************************
*
* long Sconfig(int subfn, ...)
*
*  Betriebssystemerweiterung, Funktionsnummer 0x33
*
* fn == SC_GETCONF  (0): Statuslangwort holen
* fn == SC_SETCONF  (1): Statuswert setzen
* fn == SC_DOSVARS  (2): Zeiger auf Systemvariable holen
* fn == SC_MOWNER   (3): Mowner
* fn == SC_WBACK    (4): WB-Daemon konfigurieren
*                        subfn == 0:    PD des WBDAEMON ermitteln
*                        subfn == 1:    PD setzen
*                        subfn == 2:    WB abschalten
* fn == SC_INTMAVAIL(5): Internen Speicher erfragen
* fn == SC_INTGARBC (6): garbage collection fuer internen Speicher
*
* sonst        : return(EINVFN)
*
* Bits des Status- Langworts:
*
*  Bit  0: Pfadueberpruefung ein
*  Bit  1: ovwr_flag fuer DOS und AES (KAOS 1.2: Diskwechselsim. (Desktop) ein)
*  Bit  2: Break ein
*  Bit  3: ^C fuer zeichenorientierte E/A aus
*  Bit  4: Fastload aus
*  Bit  5: Kompatibilitaet zu TOS 1.4 ein
*  Bit  6: ("Smart Redraw" aus)
*  Bit  7: (Grow- und Shrinkboxen aus)
*  Bit  8: (Halt nach TOS- Programmen)
*  Bit  9: MF2- Tastaturtabellen
*  Bit 10: Pulldown- Menues
*  Bit 11: Unterstuetzung des Elco- HD- Moduls (nur im KAOS)
*

D_Sconfig:
 move.w   (a0)+,d1
 cmpi.w   #6,d1
 bls.b    sc_ok1
 cmpi.w   #'AK',d1
 beq.b    sc_getconf               ; 'AK' wie SC_GETCONF
 cmpi.w   #'EL',d1
 beq.b    sc_setconf               ; 'EL' wie SC_SETCONF
 moveq    #EINVFN,d0
 rts
sc_ok1:
 add.w    d1,d1
 move.w   sconf_jmptab(pc,d1.w),d1
 jmp      sconf_jmptab(pc,d1.w)

sconf_jmptab:
 DC.W     sc_getconf-sconf_jmptab  ; 0
 DC.W     sc_setconf-sconf_jmptab  ; 1
 DC.W     sc_dosvars-sconf_jmptab  ; 2
 DC.W     sc_mowner-sconf_jmptab   ; 3
 DC.W     sc_wback-sconf_jmptab    ; 4
 DC.W     sc_intmavail-sconf_jmptab; 5
 DC.W     sc_intgarbc-sconf_jmptab ; 6

* Funktion 0 (SC_GETCONF):

sc_getconf:
 move.l   config_status.w,d0
 rts

* Funktion 1 (SC_SETCONF):

sc_setconf:
 move.l   config_status.w,d0
 move.l   (a0),config_status.w
 rts

* Funktion 2 (SC_DOSVARS):

sc_dosvars:
 lea      dosvars(pc),a0           ; '2' liefert die DOS- Variablen
 move.l   a0,d0
 rts

* Funktion 3 (SC_MOWNER):

sc_mowner:
 move.l   4(a0),a1            ; PD
 move.l   (a0),a0             ; memadr
 bra      Mchgown

* Funktion 4 (SC_WBACK):

sc_wback:
 move.w   (a0)+,d1            ; 0: PD ermitteln
 beq.b    dcw_get
 subq.w   #1,d1
 beq.b    dcw_set             ; 1: aktivieren
 subq.w   #1,d1
 beq.b    dcw_reset           ; 2: abschalten
dc_err:
 moveq    #EACCDN,d0
 rts
dcw_reset:
 tst.l    bufl_wback
 beq.b    dc_err                   ; schon abgeschaltet!
 clr.l    bufl_wback               ; Writeback ausschalten
 bra      Ssync                    ; alle Dateisysteme synchronisieren
dcw_set:
 tst.l    bufl_wback
 bne.b    dc_err                   ; schon belegt!
 move.l   act_pd,bufl_wback        ; Writeback einschalten
dcw_get:
 move.l   bufl_wback,d0
 rts

* Funktion 5 (SC_INTMAVAIL):

sc_intmavail:
 move.l   (a0),a1
 bra      int_mavail

* Funktion 6 (SC_INTGARBC):

sc_intgarbc:
 bra      int_garbcoll


dosvars:
 DC.L     0                   ;    0: Adresse der Semaphore
 DC.L     dos_time            ;     4: Adresse des Zeitfeldes
 DC.L     dos_date            ;     8: Adresse des Datumfeldes
 DC.L     0                   ;  $c: DOS- Stack
 DC.L     0                   ; $10: PGM- Supervisorstack (ist jetzt pointer)
 DC.L     0
 DC.L     act_pd              ; $18: Laufendes Programm
 DC.L     0                   ; $1c: Dateien
 DC.W     0                   ; $20: Laenge von fcbx[]
 DC.L     dmdx                ; $22: DMDs
 DC.L     imbx                ; $26: interner DOS- Speicher
 DC.L     resv_intmem         ; $2a: Adresse der Speichererweiterungsroutine
 DC.L     etv_critic_vec      ; $2e: Adresse des Event-Critic-Managers
 DC.L     err_to_str          ; $32: Adresse der Fehler->Klartext Routine
 DC.L     xaes_appls          ; $36: hier darf sich XAES einhaengen
 DC.L     mem_root            ; $3a: MAGIX- Speicherlisten
 DC.L     ur_pd               ; $3e: Ur- Prozess

**********************************************************************
*
* void Sysconf( WORD key )
*

D_Sysconf:
 move.w   (a0),d0
 addq.w   #1,d0
 cmpi.w   #3,d0
 bhi.b    sysc_err
 add.w    d0,d0
 add.w    d0,d0
 move.l   sysc_tab(pc,d0.w),d0
 rts
sysc_err:
 moveq    #EINVFN,d0
 rts

sysc_tab:
 DC.L     2              ; -1: max. Wert fuer Parameter: 2
 DC.L     -1             ;  0: max. Anzahl Speicherbereiche pro Prozess
 DC.L     -1             ;  1: max. Laenge der Kommandozeile bei Pexec
 DC.L     32             ;  2: Anz. offener Dateien pro Prozess
 

**********************************************************************
*
* void Syield( void )
*

D_Syield:
 move.l   act_appl.l,d0
 beq.b    syi_err
 jsr      appl_yield
syi_err:
 rts




**********************************************************************
**********************************************************************
*
* Diskwechsel- Routinen (fuer XKAOS erweitert)
*
**********************************************************************
*
* long diskchange( d0 = int drv )
*
* Das Kind ist schon in den Brunnen gefallen. Der
* XFS- Treiber gibt seine Dateien und Strukturen frei,
* anschliessend der Kernel.
*
* Wenn dieser Fehler z.B. beim Zurueckschreiben von Puffern beim
* Dlock passiert ist, gibt es hier eine Art Rekursion, die aber durch
* die Semaphore abgefangen wird.
* Entdecken mehrere Prozesse einen Diskfehler, werden sie mit Hilfe
* der Semaphore serialisiert.
*
* Rueckgabe: EDRIVE  Laufwerk ungueltig
*              E_CHNG    Laufwerk mit neuer Disk gueltig
*

diskchange:
 movem.l  a4/a6/d6/d7,-(sp)
 moveq    #E_CHNG,d7               ; errcode
 move.w   d0,d6                    ; d6 = int drv
 movea.w  d6,a0
 adda.w   a0,a0
 adda.w   a0,a0
 lea      dmdx(a0),a4              ; a4 = DMD- Eintrag
; Dlock testen
 tst.l    dlockx(a0)               ; Dlock gesetzt ?
 bne      derr_ok                  ; ja, nichts tun
 tst.l    (a4)                     ; Laufwerk gueltig ?
 beq      derr_ok                  ; nein, nichts tun

 lea      dskchg_drvs,a6

 move.l   (a6),d0
 bset     d6,d0
 move.l   d0,(a6)                  ; Bit fuer "change request"

 lea      dskchg_sem,a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 tst.l    d0
 bne      derr_ok                  ; Fehler (Rekursion ???)

 move.l   (a6),d0
 btst     d6,d0                    ; "change request" schon geloescht ?
 bne.b    derr_chg                 ; nein, Diskwechsel durchfuehren

* Diskwechsel ist schon anderweitig bearbeitet

 tst.l    (a4)                     ; DMD gueltig
 bne.b    derr_no_chg              ; ja => E_CHNG
 moveq    #EDRIVE,d7
 bra.b    derr_no_chg              ; nein => EDRIVE

* Diskwechsel wird bearbeitet

derr_chg:
 move.l   (a4),a0
 bsr      free_files               ; alle Dateien mit freigeben
 move.l   (a4),a0
 bsr      free_pathx               ; Alle Pfadhandles freigeben

 move.l   (a4),a0
 move.l   d_xfs(a0),a2
 move.l   xfs_drv_close(a2),a2
;move.l   a0,a0                    ; DMD *
 moveq    #1,d0                    ; kein Anfragemodus: schon passiert!
 jsr      (a2)

 move.l   (a4),a0
 bsr      int_mfree                ; DMD freigeben
 clr.l    (a4)                     ; DMD- Eintrag freigeben

* Neues Medium versuchen

 move.w   d6,d0
 bsr      DMD_create
 tst.l    d0
 bge.b    drvres_ok                ; Laufwerk mit neuem Medium => E_CHNG

* Das Laufwerk ist immer noch nicht zu gebrauchen

 moveq    #EDRIVE,d7               ; kein neues Medium => EDRIVE
 bra.b    drvres_ende

* Das Laufwerk ist mit einem neuen Medium funktionsbereit

drvres_ok:
 moveq    #E_CHNG,d7

drvres_ende:
 move.l   (a6),d1
 bclr     d6,d1
 move.l   d1,(a6)                  ; Bit fuer "change request" loeschen

derr_no_chg:

 lea      dskchg_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem

derr_ok:
 move.l   d7,d0
 movem.l  (sp)+,a4/a6/d6/d7
 rts


**********************************************************************
*
* long _dlock(d0 = int drvnr)
*
* Prueft, ob der Kernel geoeffnete Dateien kennt. Ggf. wird der
* Diskwechsel mit EACCDN verweigert.
* Es kann auch der DMD = NULL sein.
* Wenn nicht, wird der XFS- Treiber um Schliessen des Laufwerks gebeten.
* Wenn dieses Schliessen ohne Fehler durchgefuehrt wurde, gibt der
* Kernel seine Strukturen frei.
* Damit kein anderer Prozess mit Dlock dazwischenfunken kann, wird das
* gesperrt (per Dlock).
*
* (fuer Dlock und fuer Wechselplatten)
*

_dlock:
 movem.l  a4/a5/a6/d6,-(sp)
 move.w   d0,d6                    ; d6 = int drv
 add.w    d0,d0
 add.w    d0,d0
 lea      dmdx,a4
 add.w    d0,a4
; ggf. Dlock setzen
 move.w   d6,a5
 add.w    a5,a5
 add.w    a5,a5
 lea      dlockx(a5),a5
 tst.l    (a5)                     ; Dlock gesetzt ?
 bne      _dl_eaccdn               ; ja, verweigert !
 move.l   act_pd,(a5)              ; Dlock setzen
; Semaphore setzen
 lea      dskchg_drvs,a6
 move.l   (a6),d0
 bset     d6,d0
 move.l   d0,(a6)                  ; Bit fuer "change request"
 lea      dskchg_sem,a0
 moveq    #0,d1                    ; kein TimeOut
 moveq    #SEM_SET,d0
 jsr      evnt_sem

 move.l   (a4),d0                  ; neuer DMD ungueltig ?
 beq.b    _dl_ok0                  ; ja, Anfrage ok

; DMD ist noch gueltig, kann aber ausgetauscht worden sein!
; Wir muessen den Diskwechsel durchfuehren

 move.l   d0,a0
 bsr      chk_ofls
 bmi.b    _dl_ende2                ; Kernel hat geoeffnete Dateien

 move.l   (a4),a0
 move.l   d_xfs(a0),a2
 move.l   xfs_sync(a2),a2
 jsr      (a2)                     ; Write-Back synchronisieren

 move.l   (a4),a0
 move.l   d_xfs(a0),a2
 move.l   xfs_drv_close(a2),a2
;move.l   a0,a0                    ; DMD *
 moveq    #0,d0                    ; Anfragemodus
 jsr      (a2)
 tst.l    d0
 bmi.b    _dl_ende2                ; Anfrage verweigert

; der Kernel gibt seine Strukturen frei

; Dateien nicht freigeben, da unbenutzt (gerade getestet!)

;move.l   (a4),a0
;bsr      free_files               ; alle Dateien mit freigeben
 move.l   (a4),a0
 bsr      free_pathx               ; Alle Pfadhandles freigeben

 move.l   (a4),a0
 bsr      int_mfree                ; DMD freigeben
 clr.l    (a4)                     ; DMD- Eintrag freigeben

_dl_ok0:
 moveq    #0,d0                    ; kein Fehler
_dl_ende2:
 move.l   (a6),d1
 bclr     d6,d1
 move.l   d1,(a6)                  ; Bit fuer "change request" loeschen
_dl_ende:
 move.l   d0,-(sp)
 lea      dskchg_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 move.l   (sp)+,d0
 bge.b    _dl_ende4
 clr.l    (a5)                     ; Dlock wieder freigeben
_dl_ende4:
 movem.l  (sp)+,a6/a5/a4/d6
 rts
_dl_eaccdn:
 moveq    #EACCDN,d0
 bra.b    _dl_ende4


**********************************************************************
*
* NE/EQ long chk_ofls( a0 = LONG parm, a1 = void (*proc)() )
*
* Geht alle Dateien durch. Bei jeder Datei wird <proc> aufgerufen
* und bei einem Rueckgabewert ungleich 0 die Funktion beendet.
*

for_all_files:
 movem.l  d5/d6/d7/a3/a4/a6/a5,-(sp)
 move.l   procx,a6
 move.w   #N_PROCS-1,d7
 move.l   a1,a3
 move.l   a0,d5
faf_loop1:
 move.l   (a6)+,d0                      ; naechster Prozess
 beq.b    faf_nxtloop1                  ; Slot unbelegt
 move.l   d0,a1                         ; a1 = existierender Prozess

 moveq    #MAX_OPEN+MIN_FHANDLE-1,d6    ; dbra- Zaehler
 move.l   p_procdata(a1),a1
 lea      fh_sizeof*MIN_FHANDLE+pr_handle(a1),a4
faf_loop2:
 move.l   (a4),d0                       ; FD
 beq.b    faf_nxtloop2                  ; ungueltig

 move.l   a4,a0                         ; FD **
 move.l   d5,a1                         ; parm
 jsr      (a3)
 tst.l    d0
 bne.b    faf_ende
faf_nxtloop2:
 addq.l   #fh_sizeof,a4
 dbra     d6,faf_loop2

faf_nxtloop1:
 dbra     d7,faf_loop1
 moveq    #0,d0
faf_ende:
 movem.l  (sp)+,d5/d6/d7/a6/a5/a4/a3
 rts


**********************************************************************
*
* NE/EQ long chk_ofls( a0 = DMD *drv )
*
* Gibt EACCDN zurueck, wenn auf <drv> geoeffnete Dateien sind,
* ansonsten E_OK.
*

_chk_ofl:
 move.l   (a0),a0
 cmpa.l   fd_dmd(a0),a1                 ; DMDs gleich ?
 beq.b    cko_yes                       ; ja!
 moveq    #0,d0
 rts
cko_yes:
 moveq    #EACCDN,d0
 rts
 
chk_ofls:
;move.l   a0,a0
 lea      _chk_ofl(pc),a1
 bra      for_all_files


**********************************************************************
*
* void free_files(a0 = DMD *drive)
*
* Gibt alle FDs fuer die gewechselte Disk frei.
* Wird nur von dsk_chgd aufgerufen
*

_free_files:
 move.l   (a0),a2
 cmpa.l   fd_dmd(a2),a1                 ; DMDs gleich ?
 bne.b    frf_no                        ; nein
 clr.l    (a0)                          ; Handle ungueltig machen

 cmpi.w   #-1,fd_refcnt(a2)
 beq.b    frf_m1
 tst.w    fd_refcnt(a2)
 beq.b    frf_no                        ; ???
 subq.w   #1,fd_refcnt(a2)
 bne.b    frf_no                        ; noch referenziert!
frf_m1:
 move.l   fd_dev(a0),a1
 move.l   dev_close(a1),a1
 move.l   a2,a0                         ; FD
 jsr      (a1)                          ; freigeben!
frf_no:
 moveq    #0,d0
 rts

free_files:
;move.l   a0,a0
 lea      _free_files(pc),a1
 bra      for_all_files


*********************************************************************
*
* void free_stdpaths(a0 = PD *pd, a3 = APPL *, d5 = int drv)
*
* alle ungueltigen Pfadhandles fuer <pd>
* und alle parents freigeben
* <pd> kann NULL sein
* Fuer Threads bricht die Routine selbstaendig ab.
*
* wird nur von <free_pathx> aufgerufen
*
* d5 ist Laufwerk:
*    Es war ein Diskwechsel, alle Pfadhandles > 0, die ungueltig
*    geworden sind, auf Null setzen, d.h. auf die root.
*    Weiterhin alle ungueltigen Pfadhandles (-1) auf die root
*    setzen.
*
* d5 == -1:
*    Ein Standardverzeichnis ist geloescht worden. Alle
*    Pfadhandles >0, die ungueltig geworden sind, auf -1
*    setzen.
*

fsp_loop:
 move.l   p_app(a0),d0             ; gibt es zugehoerigen Haupt-Thread ?
 beq.b    fsp_no_aes               ; nein, stammt aus Boot-Zeit vor dem AES
 cmpa.l   d0,a3                    ; Haupt-Thread ?
 bne.b    fsp_ende                 ; nein!
fsp_no_aes:
 moveq    #0,d1                    ; Fuer jedes Laufwerk...
 lea      pathcntx,a2
 moveq    #0,d0                    ; Hibyte loeschen
 lea      p_drvx(a0),a1            ; a1 = Tabelle der Pfadhandles
fsp_loop2:
 move.b   (a1)+,d0                 ; Pfadhandle (->WORD)
 beq.b    fsp_nxtlp2               ;  ist schon root
 bgt.b    fsp_hdlvalid             ; ist > 0, Test, ob gueltig
; Handle < 0, d.h. schon ungueltig
 cmp.w    d1,d5                    ; unser Laufwerk ?
 bne.b    fsp_nxtlp2               ; nein, bleibt ungueltig
 bra.b    fsp_set_root             ; ja, auf root setzen
; Handle > 0, also vielleicht gueltig
fsp_hdlvalid:
 tst.b    0(a2,d0.w)               ; pathcntx[pathhandle] ?
 bne.b    fsp_nxtlp2               ; ist > 0, nicht aendern
 tst.w    d5                       ; Diskwechsel ?
 bge.b    fsp_set_root             ; ja, auf root setzen
 move.b   #-1,-1(a1)               ; nein, auf -1 setzen
 bra.b    fsp_nxtlp2
fsp_set_root:
 clr.b    -1(a1)                   ; Zaehler 0 => Pfadhandle im PD loeschen
fsp_nxtlp2:
 addq.w   #1,d1
 cmpi.w   #LASTDRIVE,d1
 bls.b    fsp_loop2

 cmpi.l   #'_PRG',p_res3(a0)       ; paralleler Prozess ?
 beq.b    fsp_ende                 ; ja, parent ist ungueltig

 movea.l  p_parent(a0),a0          ; naechstes Programm
free_stdpaths:
 move.l   a0,d1
 bne.b    fsp_loop
fsp_ende:
 rts


**********************************************************************
*
* void free_pathx(a0 = DMD *dmd)
*
* Pfadhandles in allen PDs korrigieren
*
* 2.12.95:
*    Diese Prozedur hat zwei Funktionen:
*    a)   Funktion fuer Diskwechsel. <a0> enthaelt einen DMD.
*         Dabei werden alle Pfadhandles, die sich auf diesen
*         gewechselten DMD beziehen, auf die root gesetzt, auch
*         die ungueltigen (!)
*    b)   Funktion fuer Loeschen von Standardpfaden. a0 == NULL.
*         Alle temporaer ungueltigen Pfadhandles, d.h. solche,
*         die auf einen temporaer ungueltigen Standardpfad zeigen, d.h.
*         (pathcntx[hdl] != 0) und (pathx[hdl] = 0), werden
*         ungueltig gemacht, d.h auf -1 gesetzt.
*

free_pathx:
 movem.l  d5/d6/d7/a3/a4/a5/a6,-(sp)
 move.l   a0,a4                    ; a4 = DMD *
 lea      pathcntx+1,a6            ; Referenzzaehler fuer pathx
 lea      pathx+4,a5
 moveq    #N_STDPATHS-2,d6         ; dbra- Zaehler

*
* 1. Phase: <pathx> und <pathcntx> aufraeumen
*

next_p:
 moveq    #0,d0
 move.b   (a6),d0                  ; Referenzzaehler, BYTE => UWORD
 beq.b    frp_nxtpth               ; Pfadhandle unbenutzt
 move.l   a4,d1
 bne.b    frpthx_dmd
* Funktion "Standardpfad ung",$81,"ltig"
 tst.l    (a5)                     ; temporaer ungueltig ?
 bne.b    frp_nxtpth               ; nein, nicht antasten
 bra.b    frp_stdpthinvalid        ; ja, freigeben
* Funktion "Diskwechsel"
frpthx_dmd:
 tst.l    (a5)
 beq.b    frp_nxtpth               ; Standard- DD ungueltig (?)
 movea.l  (a5),a0
 cmp.l    dd_dmd(a0),a4
 bne.b    frp_nxtpth               ; anderes Laufwerk
 sub.w    d0,dd_refcnt(a0)         ; DD um korrekte Zahl dereferenzieren
 bne.b    frp_nofdd

;move.l   a0,a0                    ; Zeiger auf DD uebergeben
 move.l   d_xfs(a4),a2
 move.l   xfs_freeDD(a2),a2
 jsr      (a2)                     ; DD freigeben

frp_nofdd:
 clr.l    (a5)                     ;  freigeben
frp_stdpthinvalid:
 clr.b    (a6)                     ; Pfadhandle
frp_nxtpth:
 addq.l   #1,a6
 addq.l   #4,a5
 dbra     d6,next_p

*
* 2. Phase: In den PDs p_drvx[] aufraeumen
*

 moveq    #-1,d5                   ; kein Laufwerk
 move.l   a4,d0                    ; Diskwechselfunktion ?
 beq.b    frp_no_drv               ; nein, kein Laufwerk
 move.w   d_drive(a4),d5           ; dieses Laufwerk freigeben
frp_no_drv:

 move.l   act_appl.l,a3
;move.w   d5,d5
 movea.l  act_pd,a0                ; PD *
 bsr.b    free_stdpaths

 move.l   xaes_appls,d0            ; XAES ?
 beq.b    frp_ende                 ; nein
 move.l   d0,a6
 cmpi.l   #'XAES',(a6)+            ; magische Kennung ?
 bne.b    frp_ende                 ; nein
 move.l   (a6)+,a5                 ; act_appl
 move.w   (a6)+,d6                 ; Offset fuer ap_pd
 addq.l   #2,a6                    ; Anzahl der APPLs unwichtig
 move.w   (a6)+,d7                 ; Tabellenlaenge
 bra.b    frp_nxtappl
frp_applloop:
 move.l   (a6)+,d0
 beq.b    frp_nxtappl              ; Slot unbelegt
 bclr     #31,d0                   ; eingefrorene APP auch behandeln!
 cmp.l    d0,a5                    ; ist die aktuelle Applikation ?
 beq.b    frp_nxtappl              ; ja, per act_pd schon erledigt
 move.l   d0,a3                    ; APPL *
;move.w   d5,d5
 move.l   0(a3,d6.w),a0            ; geretteter PD (=0?) der schlafenden APPL
 bsr      free_stdpaths
frp_nxtappl:
 dbra     d7,frp_applloop
frp_ende:
 movem.l  (sp)+,d5/d6/d7/a3/a4/a5/a6
 rts




**********************************************************************
**********************************************************************
*
* "shared libraries"
*
**********************************************************************
**********************************************************************
*
* LONG Slbx_fn( void *handle, LONG fn, ... )
*
* Wird vom Benutzerprogramm direkt ueber jsr angesprungen und im
* User-Mode ausgefuehrt. <handle> ist der Zeiger auf die LSLB-Struktur.
*

Slbx_fn:
 move.l   4(sp),a0                 ; handle: LSLB
 move.l   lslb_slb(a0),a0          ; SLB
 move.l   8(sp),d0                 ; Funktionsnummer
 cmp.l    slb_fnn(a0),d0           ; Anzahl vorhandener Funktionen
 bcc.b    slbx_einvfn              ; Fehler
 add.l    d0,d0
 add.l    d0,d0                    ; * 4 fuer Zeiger
 move.l   slb_fx(a0,d0.l),d0       ; Funktionszeiger
 beq.b    slbx_einvfn              ; ungueltig
 move.l   d0,a0
 move.l   act_pd,4(sp)             ; act_pd statt handle
 jmp      (a0)                     ; ... und rein in die Funktion ...
slbx_einvfn:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* LONG Slbopen( char *name, char *path, LONG min_ver,
*                   void **handle,
*                   void cdecl (**fn)(void *hdl, LONG fn, ...),
*                   void *param )
*
* Oeffnet eine "shared library".
*
* name         Name der Bibliothek inkl. Dateityp ".SLB".
* path         darf NULL sein. Dort wird die Datei zuerst gesucht.
*              sonst nur in "<bootdrv>:/gemsys/magic/xtension".
* min_ver      ist die minimale Versionsnummer der Bibliothek, die
*              benoetigt wird.
* param        MagiC 6: Parameter
*
* Rueckgabe:
* <ret>        Versionsnummer oder Fehlercode (ERANGE, falls
*              die Versionsnummer zu klein war, EFILNF, EPATH usw.)
* handle       Deskriptor (tats. Zeiger auf Verwaltungstruktur)
* fn           Zeiger auf eine Funktion. Sie wird aufgerufen mit
*              Parametern auf dem Stack, die beiden ersten Parameter
*              sind der Deskriptor und die Funktionsnummer.
*
* MagiC 6:     Auswertung der Environment-Variablen SLBPATH
*              Parameter an init und open
*

D_Slbopen:
 movem.l  a6/a5/a4/a3/d7,-(sp)
 suba.w   #xattr_sizeof+30+128,sp  ; 128 Bytes Platz fuer den gefundenen Pfad
                                   ; 30 Bytes Platz fuer Default-Suchpfad
 move.l   a0,a6                    ; Zeiger auf Parameter

; zunaechst pruefen wir, ob die Lib geladen ist

 move.l   lslb_list,a5
 bra.b    sbo_endloop1
sbo_loop1:
 move.l   lslb_slb(a5),a4          ; Zeiger auf Header
 move.l   slb_name(a4),a0          ; Name der Lib
 move.l   (a6),a1                  ; gesuchter Name
 jsr      stricmp
 tst.w    d0
 bne.b    sbo_nxtloop1
 move.l   slb_version(a4),d0
 cmp.l    8(a6),d0
 bcc      sbo_ok                   ; OK, Versionsnummer stimmt
 moveq    #ERANGE,d0
 bra      sbo_ende                 ; Versionsnummer zu klein
sbo_nxtloop1:
 move.l   lslb_next(a5),a5
sbo_endloop1:
 move.l   a5,d0
 bne.b    sbo_loop1

; Bibliothek nicht gefunden.
; Pfad zusammenbauen und Datei suchen/laden

 clr.l    -(sp)                    ; Ende-Zeichen fuer Liste der Suchpfadlisten

; Environment-Variable SLBPATH

 lea      slbpath_s(pc),a1         ; "SLBPATH="
 move.l   act_pd,a0
 move.l   p_env(a0),d0
 ble.b    slb_no_srch
 move.l   d0,a0
 bsr      env_get                  ; Environment durchsuchen
 beq.b    slb_no_srch
 move.l   d0,-(sp)                 ; Suchpfad eintragen
 bra.b    slb_is_srch

; kein SLBPATH, suche in X:\GEMSYS\MAGIC\XTENSION

slb_no_srch:
 lea      128+4(sp),a0             ; Zeiger auf 30-Byte-Puffer
 lea      xtpath(pc),a1
 move.b   _bootdev+1,d0
 add.b    #'A',d0
 move.b   d0,(a0)+
sbo_ispath:
 move.b   (a1)+,(a0)+
 bne.b    sbo_ispath
 pea      128+4(sp)                ; Default-Suchpfad eintragen
slb_is_srch:

; einzelner Suchpfad, falls angegeben

 clr.l    -(sp)                    ; Listenende
 move.l   4(a6),-(sp)              ; Suchpfad

; Dateinamen in den Puffer kopieren

 lea      16(sp),a0
 move.l   (a6),a1                  ; Name der Bibliothek
sbo_nloop:
 move.b   (a1)+,(a0)+
 bne.b    sbo_nloop

; Bibliothek suchen

 lea      8(sp),a2                 ; Suchpfadlisten
 lea      (sp),a1                  ; Suchpfade
 lea      16+128+30(sp),a0
 move.l   a0,d1                    ; (XATTR *)
 moveq    #2+8,d0                  ; Suchpfade+Suchpfadlisten
 lea      16(sp),a0                ; Puffer und Dateiname
 jsr      ffind
 adda.w   #16,sp
 bmi      sbo_ende                 ; Fehler

; Bibliothek laden

;    DEBON

 clr.l    -(sp)                    ; env
 pea      nulb_s(pc)               ; cmdline
 pea      8(sp)                    ; path
 move.w   #EXE_LD,-(sp)
 move.l   sp,a0
 bsr      Pexec                    ; Bibliothek laden
 lea      14(sp),sp

     DEBL d0,'SLB-Pexec EXE_LD => '

 tst.l    d0
 bmi      sbo_ende                 ; Fehler
 move.l   d0,a3
 lea      256(a3),a4

; Bibliothek ist geladen.
; a3 ist die Basepage
; a4 ist SLB

 moveq    #EPLFMT,d7
 cmpi.l   #$70004afc,slb_magic(a4) ; Textsegment beginnt mit magic ?
 bne      sbo_free                 ; nein, freigeben
 move.l   slb_version(a4),d0       ; Version
 moveq    #ERANGE,d7
 cmp.l    8(a6),d0                 ; min_ver
 bcs      sbo_free                 ; Versionsnummer zu klein

; Eigner von PD, PROCDATA und Basepage ist die SLB selbst

 move.l   a3,a0
 bsr      chg_bp_owner

; Speicher fuer LSLB holen

sbo_no_env:
 move.l   a3,a1                    ; Eigner wird die Lib selbst
 moveq    #2,d1                    ; lieber ST-RAM
 move.l   #lslb_sizeof,d0
 jsr      Mxalloc
 moveq    #ENSMEM,d7
 tst.l    d0
 ble      sbo_free                 ; zuwenig Speicher
 move.l   d0,a5                    ; a5 = Zeiger auf LSLB

; Lib initialisieren

     DEB 'Initialisiere SLB...'

 pea      ur_pd                    ; parent
 pea      (a3)                     ; child
 clr.l    -(sp)                    ; dummy
 move.w   #XEXE_INIT,-(sp)
 move.l   sp,a0
 bsr      Pexec                    ; Bibliothek laden
 lea      14(sp),sp

     DEBL d0,'SLB-Pexec XEXE_INIT => '

; Start-Pfad in die Basepage kopieren (MagiC 6)

 lea      p_cmdlin(a3),a0
 lea      (sp),a1
slb_n2loop:
 move.b   (a1)+,(a0)+
 bne.b    slb_n2loop

; slbinit aufrufen

 move.l   20(a6),d0                ; zusaetzlicher Parameter (MagiC 6)
 move.l   slb_init(a4),a1
 move.l   a3,a0
 bsr      Slbexec                  ; Initialisierung im Supervisormodus
 move.l   d0,d7                    ; Rueckgabewert vom Initialisieren
 bmi.b    sbo_free2

; Lib einklinken

 move.l   lslb_list,lslb_next(a5)
 move.l   a5,lslb_list
 move.l   a4,lslb_slb(a5)
 clr.w    lslb_refcnt(a5)
 lea      lslb_pdtab(a5),a0
 lea      NPDL*4(a0),a1
 jsr      fast_clrmem              ; Tabelle der PDs loeschen
 bra.b    sbo_ok                   ; gefunden!!!

; Bibliothek nicht OK.
; freigeben und Ende

sbo_free2:
 suba.l   a1,a1
 move.l   a5,a0
 jsr      Mxfree

 clr.l    -(sp)                    ; dummy
 move.l   a3,-(sp)                 ; child
 clr.l    -(sp)                    ; dummy
 move.w   #XEXE_TERM,-(sp)
 move.l   sp,a0
 bsr      Pexec                    ; Bibliothek loeschen
 lea      14(sp),sp
 move.l   d7,d0
 bra      sbo_ende

sbo_free:
 suba.l   a1,a1                    ; kein Limit
 move.l   p_env(a3),a0
 bsr      Mxfree
 move.l   a3,a0
 suba.l   a1,a1                    ; kein Limit
 bsr      Mxfree
 move.l   d7,d0
 bra      sbo_ende

; Bibliothek gefunden
; a5 ist Zeiger auf lslb, a4 ist Zeiger auf slb
; Pruefen, ob schon geoeffnet.
; Freien Platz suchen: a3

sbo_ok:
 move.l   act_pd,d2
 move.l   a5,a0
 bsr      lslb_pdsearch

 moveq    #EACCDN,d0
 move.l   a0,d1
 bne.b    sbo_ende                 ; Bibliothek schon geoeffnet => Fehler
 move.l   a1,a3                    ; freier Platz

; Bibliothek ist noch nicht geoeffnet. Oeffnen.
; a3 ist Zeiger auf freien Eintrag oder NULL

 move.l   a3,d0
 bne.b    sbo_ok3
 moveq    #ENSMEM,d0
 bra.b    sbo_ende                 ; kein freier Eintrag mehr
sbo_ok3:

; Aufruf im Usermode

 move.l   slb_open(a4),a0          ; fn
 move.l   20(a6),d1                ; zusaetzlicher Parameter (MagiC 6)
 move.l   act_pd,d0
 bsr.s    Slbexec2
 tst.l    d0
 bge.b    sbo_ok4

; Fehler beim Oeffnen.
; Wenn Referenzzaehler Null => Lib wegwerfen.

 tst.w    lslb_refcnt(a5)
 bne      sbo_ende
 move.l   d0,d7
 move.l   a5,a0
 bsr      Slbfree
 move.l   d7,d0
 bra.b    sbo_ende                 ; Fehler beim Oeffnen
sbo_ok4:
 move.l   act_pd,(a3)              ; PD eintragen
 addq.w   #1,lslb_refcnt(a5)       ; Referenzzaehler erhoehen
 lea      12(a6),a6
 move.l   (a6)+,a0                 ; void **handle
 move.l   a5,(a0)                  ; => Zeiger auf LSLB
 move.l   (a6)+,a0
 move.l   #Slbx_fn,(a0)            ; Funktionsaufruf
 move.l   slb_version(a4),d0       ; gib Versionsnummer zurueck

sbo_ende:
 adda.w   #xattr_sizeof+128+30,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7
 rts


**********************************************************************
*
* long Slbexec2( a0 = long (*fn)(), d0 = long param, d1 = long param2 )
*
* Fuehrt eine Funktion im Usermode aus, ohne den Kontext
* zu aendern. Fuer slb_open und slb_close.
*
* MagiC 6:     Ist der usp NULL, wird der Aufruf im
*              Supermode ausgefuehrt. 
*

Slbexec2:
 move.l   usp,a1
 move.l   a1,d2
 bne.b    sbx2_user
 move.l   d1,-(sp)
 move.l   d0,-(sp)                 ; Parameter: pd
 jsr      (a0)                     ; Funktion aufrufen
 addq.l   #8,sp
 rts
sbx2_user:
 movem.l  a6/d7,-(sp)
 move.l   sp,a6                    ; ssp merken
 andi.w   #$dfff,sr                ; Usermode
 move.l   d1,-(sp)                 ; Parameter: param
 move.l   d0,-(sp)                 ; Parameter: pd
 jsr      (a0)                     ; Funktion aufrufen
 addq.l   #8,sp
 move.l   d0,d7                    ; Rueckgabewert merken
 lea      sbx2_endinit(pc),a2
 move.w   #$ca,d0                  ; schnell in den Supermode
 trap     #2
sbx2_endinit:
 move.l   a6,sp                    ; ssp zurueck
 move.l   d7,d0
 movem.l  (sp)+,a6/d7
 rts


**********************************************************************
*
* long Slbexec( a0 = PD *lslb, a1 = long (*fn)(), d0 = long param )
*
* Fuehrt eine Funktion im Supervisormodus im Kontext der LSLB aus.
*
* MagiC 6: param wird uebergeben
*

Slbexec:
 movem.l  d7/a3/a6,-(sp)
 move.l   a0,a3                    ; PD *
 move.l   a1,a6                    ; fn
 move.l   d0,d7                    ; param
 pea      sbx_term(pc)
 move.l   #$50102,-(sp)            ; bios Setexc
 trap     #$d                      ; etv_term umsetzen, alten Vektor merken
 addq.w   #8,sp
 move.l   d0,-(sp)
 move.l   act_pd,-(sp)
 move.l   a3,act_pd
 move.l   usp,a0
 move.l   a0,-(sp)                 ; usp merken
 move.l   sp,p_res3+4(a3)          ; ssp merken
 move.l   d7,-(sp)                 ; parameter
 move.l   a3,-(sp)                 ; eigener PD
 jsr      (a6)
 addq.l   #8,sp
 move.l   d0,d7                    ; Rueckgabewert merken
 bra.b    sbx_endinit
sbx_term:
 moveq    #EXCPT,d7
sbx_endinit:
 move.l   act_pd,a0
 move.l   p_res3+4(a3),sp          ; ssp zurueck
 move.l   (sp)+,a0
 move.l   a0,usp                   ; usp zurueck
 move.l   (sp)+,act_pd
;move.l   (sp)+,-(sp)
 move.l   #$50102,-(sp)            ; bios Setexc
 trap     #$d                      ; etv_term restaurieren
 addq.w   #8,sp
 move.l   d7,d0
 movem.l  (sp)+,a3/d7/a6
 rts


**********************************************************************
*
* void Slbfree( LSLB *lslb )
*
* Gibt eine "shared library" frei
*

Slbfree:
 move.l   a4,-(sp)
 lea      lslb_list,a1
sbf_loop:
 move.l   (a1),a2
 move.l   a2,d0
 beq.b    sbf_ende
 cmpa.l   a0,a2
 beq.b    sbf_found
 lea      lslb_next(a2),a1
 bra.b    sbf_loop
sbf_found:
 move.l   lslb_next(a0),(a1)       ; ausklinken
 move.l   lslb_slb(a0),a4          ; SLB merken
 suba.l   a1,a1
;move.l   a0,a0
 jsr      Mxfree                   ; LSLB freigeben

 move.l   slb_exit(a4),a1
 lea      -256(a4),a0              ; PD
 bsr      Slbexec                  ; De-Initialisierung im Kontext der SLB

 clr.l    -(sp)                    ; dummy
 pea      -256(a4)                 ; child
 clr.l    -(sp)                    ; dummy
 move.w   #XEXE_TERM,-(sp)
 move.l   sp,a0
 bsr      Pexec                    ; Bibliothek loeschen
 lea      14(sp),sp

sbf_ende:
 move.l   (sp)+,a4
 rts


**********************************************************************
*
* lslb_pdsearch( a0 = LSLB *lslb, d2 = PD *pd )
*
* Sucht einen PD in der PD-Liste der SharedLib.
* => a0   Zeiger auf Eintrag
*    a1   Zeiger auf freien Eintrag
*

lslb_pdsearch:
 suba.l   a1,a1                    ; kein freier Platz
 lea      lslb_pdtab(a0),a0        ; Tabellenanfang
 lea      4*NPDL(a0),a2            ; Tabellenende
lspd_loop:
 cmpa.l   a2,a0
 bcc.b    lspd_nix
 move.l   (a0),d0                  ; Tabelleneintrag
 bne.b    lspd_isnz
 move.l   a1,d1                    ; schon freien Platz gefunden?
 bne.b    lspd_nxt                 ; ja, weitersuchen
 move.l   a0,a1
lspd_nxt:
 addq.l   #4,a0
 bra.b    lspd_loop
lspd_isnz:
 cmp.l    d0,d2
 bne.b    lspd_nxt
 rts                               ; PD gefunden
lspd_nix:
 suba.l   a0,a0                    ; PD nicht gefunden
 rts


**********************************************************************
*
* void slb_close_all( PD *pd )
*
* Schliesst alle "shared libraries", die von dem Prozess geoeffnet sind
*

slb_close_all:
 movem.l  a6/a5,-(sp)
 move.l   a0,a5
 move.l   lslb_list,a6
 bra.b    scla_nxt
scla_loop:
 move.l   a5,a1
 move.l   a6,a0
 move.l   lslb_next(a6),a6
 bsr.b    slbclose
scla_nxt:
 move.l   a6,d0
 bne.b    scla_loop
 movem.l  (sp)+,a6/a5
 rts


**********************************************************************
*
* LONG Slbclose( void *handle )
* LONG slbclose( a0 = LSLB *ls, a1 = PD *pd )
*
* Schliesst eine "shared library".
*
* MagiC 6: Zeiger -1 schliesst ALLE Bibliotheken.
*

D_Slbclose:
 move.l   (a0),a0
 move.l   act_pd,a1
 cmpa.l   #-1,a0
 bne.b    slbclose
 move.l   a1,a0
 bsr.s    slb_close_all            ; alle SLBs schliessen
 moveq    #0,d0
 rts
slbclose:
 movem.l  a3/a5/a4/a6,-(sp)
 move.l   a0,a5
 move.l   a1,a6
 move.l   lslb_slb(a5),a4

 move.l   a6,d2
 move.l   a5,a0
 bsr.s    lslb_pdsearch
 move.l   a0,d0
 beq.b    slc_err                  ; PD nicht gefunden
 move.l   a0,a3                    ; Zeiger merken

; Schliessfunktion im Usermode aufrufen

 move.l   slb_close(a4),a0         ; fn
 move.l   a6,d0
 bsr      Slbexec2                 ; Schliessfunktion aufrufen

 clr.l    (a3)                     ; PD austragen
 subq.w   #1,lslb_refcnt(a5)
 bne.b    slc_ok

 move.l   a5,a0
 bsr      Slbfree                  ; Zaehler auf Null => freigeben
slc_ok:
 moveq    #E_OK,d0
 bra.b    slc_ende
slc_err:
 moveq    #EACCDN,d0
slc_ende:
 movem.l  (sp)+,a6/a5/a3/a4
 rts




**********************************************************************
**********************************************************************
*
* Datum- und Zeitfunktionen
*
**********************************************************************
**********************************************************************
*
* int Tgetdate()
*

Tgetdate:
 moveq    #0,d0
 move.w   dos_date,d0
 rts


**********************************************************************
*
* int Tgettime()
*

Tgettime:
 moveq    #0,d0
 move.w   dos_time,d0
 rts


**********************************************************************
*
* int Tsetdate(int datecode)
*
* Korrektur: Der Monat oder Tag 0 wird als Fehler erkannt
*               Jahr > 2099 wird als Fehler erkannt
*

D_Tsetdate:
 move.w   (a0),d2
 move.w   d2,d0
 andi.w   #$fe00,d0

 cmpi.w   #$ee00,d0
 bhi      setclock_err             ; Jahr-1980 > 119
 move.w   d2,d0
 lsr.w    #5,d0
 andi.w   #$f,d0                   ; d0 = Monat
 beq      setclock_err             ; Monat == 0
 cmpi.w   #12,d0
 bhi      setclock_err             ; Monat > 12
 move.w   d2,d1
 and.w    #$1f,d1                  ; d1 = Tag
 beq      setclock_err             ; Tag == 0
 cmp.w    #2,d0
 bne.b    dtsetd_l1
* Sonderbehandlung fuer Februar
 andi.w   #$600,d2                 ; Jahr % 4
 bne.b    dtsetd_l1                ; kein Schaltjahr
* Schaltjahr
 cmpi.w   #29,d1
 bhi      setclock_err
 bra.b    dtsetd_l2
* kein Schaltjahr
dtsetd_l1:
 cmp.b    monthlenx-1(pc,d0.w),d1
 bhi      setclock_err
dtsetd_l2:
 move.w   (a0),dos_date
 bra      setclock_ok

monthlenx:
 DC.B     31,28,31,30,31,30,31,31,30,31,30,31


**********************************************************************
*
* long Tsettime(int time)
*
* Korrektur: Stunden > 23 werden als Fehler erkannt
*

D_Tsettime:
 move.w   (a0),d1
 move.w   d1,d0
 and.w    #$1f,d0        ; 2er Sekunden
 cmp.w    #30,d0
 bcc.b    setclock_err   ; Sekunden >= 60
 move.w   d1,d0
 and.w    #$7e0,d0
 cmp.w    #$780,d0
 bcc.b    setclock_err   ; Minuten >= 60
 move.w   d1,d0
 and.w    #$f800,d0
 cmp.w    #$c000,d0
 bcc.b    setclock_err   ; Stunden >= 24
 move.w   d1,dos_time

setclock_ok:
 bsr      dosclock_to_xbios
 moveq    #0,d0
 rts
setclock_err:
 moveq    #ERROR,d0
 rts


**********************************************************************
*
* dos_etv_timer(unsigned int elapsed_ms)
*
* etv_timer -  Routine des GEMDOS
* BIOS rettet vorher saemtliche Register, es duerfen also alle
* benutzt werden.
* d2 = Maske fuer 5 Bits ($1f)
* d7.hi = time
* d7.lo = date
*

dos_etv_timer:
 moveq    #0,d0
 moveq    #$1f,d2                  ; geht schneller!
 move.w   4(sp),d0                 ; verstrichene Zeit
 lea      last_ms,a0
 add.w    d0,(a0)                  ; auf last_ms addieren
 cmpi.w   #2000,(a0)               ; schon wieder 2s voll ?
 bcs      det_ende                 ; nein, Ende
 subi.w   #2000,(a0)               ; 2s in die Uhr uebertragen
 move.l   dos_time,d7
 swap     d7                       ; d7.lo ist jetzt dos_time
 addq.w   #1,d7                    ; Zeit erhoehen
 move.w   d7,d0
 and.w    d2,d0                    ; $1f, 2-Sekunden-Einheiten
 cmpi.w   #30,d0                   ; Eine Minute voll ?
 bne      det_wr_time              ; nein, Ende
 andi.w   #$ffe0,d7                ; Sekunden auf 0
 addi.w   #$20,d7                  ; Minuten weiterschalten
 move.w   d7,d0
 and.w    #$7e0,d0                 ; Minuten isolieren
 cmp.w    #$780,d0                 ; Eine Stunde voll ?
 bne      det_wr_time              ; nein, weiter
 andi.w   #$f81f,d7                ; Minuten auf 0
 addi.w   #$800,d7                 ; Stunden weiterschalten
 move.w   d7,d0
 and.w    #$f800,d0                ; Stunden isolieren
 cmp.w    #$c000,d0                ; 24 Stunden voll ?
 bne      det_wr_time              ; nein, weiter
 clr.w    d7                       ; Zeit auf 0:00:00
 swap     d7                       ; Zeit wieder ins Hiword, Datum ins Loword
 move.w   d7,d0
 and.w    d2,d0                    ; $1f, Tag isolieren
 cmp.w    d2,d0                    ; $1f, Tag ist 31 ?
 beq.b    dosevtt_l1                ; ja, Monat weiterschalten
 addq.w   #1,d7                    ; Tag erhoehen
 move.w   d7,d0
 and.w    d2,d0                    ; $1f, Tag holen
 cmp.w    #$28,d0                  ; Tag <= 28
 bls      det_wr                   ; ja, ok und Ende

 move.w   d7,d1
 asr.w    #5,d1
 and.w    #$f,d1                   ; d1 = Monat
 cmp.w    #2,d1                    ; Februar ?
 bne.b    dosevtt_l2                ; nein
* Februar
 move.w   d7,d0
 and.w    #$600,d0                 ; Jahr % 4
 bne.b    dosevtt_l2                ; kein Schaltjahr
* Februar und Schaltjahr
 move.w   d7,d0
 and.w    d2,d0                    ; $1f, Tag isolieren
 cmp.w    #29,d0
 bls.b    det_wr                   ; Tag <= 29
 bra.b    dosevtt_l1                ; Tag > 29, Monat weiterschalten
* nicht Februar oder kein Schaltjahr
dosevtt_l2:
 move.w   d7,d0
 and.w    d2,d0                    ; $1f, d0 = Tag
 lea      monthlenx(pc),a0
 cmp.b    -1(a0,d1.w),d0
 bls.b    det_wr                   ; kein Monatsende
dosevtt_l1:
 andi.w   #$ffe0,d7                ; Tag auf 0
 addi.w   #$21,d7                  ; Monat weiterzaehlen
 move.w   d7,d0
 and.w    #$1e0,d0                 ; Monat holen
 cmp.w    #$180,d0                 ; Monat > 12 ?
 bls.b    det_wr                   ; nein, ok
 andi.w   #$fe00,d7                ; Monat auf 0
 addi.w   #$221,d7                 ; Jahr weiterzaehlen
det_wr:
 move.l   d7,dos_time              ; dos_time/dos_date schreiben
 bra.b    det_ende
det_wr_time:
 move.w   d7,dos_time              ; nur Zeit hat sich geaendert
det_ende:
 move.l   otimer,-(sp)
 rts


**********************************************************************
*
* void restore_time()
*
* Schreibt die Hardwareuhr in die DOS - Uhr
* Wird nur von Pterm() aufgerufen
*

restore_time:
 jsr      chk_rtclock
 bcs.b    restrtm_end
 jsr      read_rtclock
 move     sr,d1
 ori      #$700,sr
 move.w   d0,dos_time
 swap     d0
 move.w   d0,dos_date
 move     d1,sr
restrtm_end:
 rts


**********************************************************************
*
* void dosclock_to_xbios()
*

dosclock_to_xbios:
 move.w   dos_time,-(sp)
 move.w   dos_date,-(sp)
 move.w   #$16,-(sp)
 trap     #$e                 ; xbios Settime
 addq.w   #6,sp
 rts


**********************************************************************
*
* LONG Tmalarm( LONG ms )
*

D_Tmalarm:
 move.l   act_appl.l,d0
 beq      ill_func            ; AES nicht gestartet
 move.l   (a0),d0
 jmp      appl_alrm


**********************************************************************
*
* LONG Talarm( LONG s )
*

D_Talarm:
 move.l   (a0),d0             ; Sekunden
 ble.b    tal_no1000          ; 0 oder < 0
 mulu     #1000,d0            ; -> Millisekunden
tal_no1000:
 move.l   d0,-(sp)
 move.l   sp,a0
 bsr.b    D_Tmalarm
 addq.l   #4,sp
 addi.l   #999,d0
 divu     #1000,d0            ; Millisekunden -> Sekunden
 andi.l   #$0000ffff,d0
 rts



**********************************************************************
**********************************************************************
*
* DATEN
*

auxnb_name_s:
 DC.B     'U:\DEV\AUXNB',0         ; 27.6.2002

con_name_s:
 DC.B     'U:\DEV\CON',0
aux_name_s:
 DC.B     'U:\DEV\AUX',0
nul_name_s:
 DC.B     'U:\DEV\NULL',0
prn_name_s:
 DC.B     'U:\DEV\PRN',0
nulb_s:
 DC.B     0
xtpath:
 DC.B     ':',$5c,'GEMSYS',$5c,'MAGIC',$5c,'XTENSION',$5c,0

     EVEN

u_devices:
 DC.L     con_name_s
 DC.L     aux_name_s
 DC.L     prn_name_s
 DC.L     nul_name_s


def_hdlx:
 DC.B     $ff,$ff,$fe,$fd,$ff,$ff

argv_s:
 DC.B     'ARGV=',0
slbpath_s:
 DC.B     'SLBPATH=',0
noname_s:
 DC.B     'NONAME',0
pnam_s:
 DC.B     '_PNAM=',0
lines_s:
 DC.B     'LINES=',0
columns_s:
 DC.B     'COLUMNS=',0
zahl_s:
 DC.B     '%L',0

     EVEN

dos_fx:
 DC.W     Pterm0-dos_fx            ; 0x00
 DC.W     D_Cconin-dos_fx
 DC.W     D_Cconout-dos_fx
 DC.W     D_Cauxin-dos_fx
 DC.W     D_Cauxout-dos_fx         ; 0x04
 DC.W     D_Cprnout-dos_fx
 DC.W     D_Crawio-dos_fx
 DC.W     D_Crawcin-dos_fx
 DC.W     D_Cnecin-dos_fx          ; 0x08
 DC.W     D_Cconws-dos_fx
 DC.W     D_Cconrs-dos_fx
 DC.W     D_Cconis-dos_fx
 DC.W     ill_func-dos_fx          ; 0x0c
 DC.W     ill_func-dos_fx
 DC.W     D_Dsetdrv-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     D_Cconos-dos_fx          ; 0x10
 DC.W     D_Cprnos-dos_fx
 DC.W     D_Cauxis-dos_fx
 DC.W     D_Cauxos-dos_fx
 DC.W     D_Maddalt-dos_fx         ; 0x14
 DC.W     D_Srealloc-dos_fx        ; 0x15
 DC.W     D_Slbopen-dos_fx
 DC.W     D_Slbclose-dos_fx
 DC.W     ill_func-dos_fx          ; 0x18
 DC.W     Dgetdrv-dos_fx
 DC.W     D_Fsetdta-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x1c
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x20
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x24
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x28
 DC.W     ill_func-dos_fx
 DC.W     Tgetdate-dos_fx
 DC.W     D_Tsetdate-dos_fx
 DC.W     Tgettime-dos_fx          ; 0x2c
 DC.W     D_Tsettime-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     Fgetdta-dos_fx
 DC.W     Sversion-dos_fx          ; 0x30
 DC.W     D_Ptermres-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     D_Sconfig-dos_fx
 DC.W     ill_func-dos_fx          ; 0x34
 DC.W     ill_func-dos_fx
 DC.W     D_Dfree-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x38
 DC.W     D_Dcreate-dos_fx
 DC.W     D_Ddelete-dos_fx
 DC.W     D_Dsetpath-dos_fx
 DC.W     D_Fcreate-dos_fx         ; 0x3c
 DC.W     D_Fopen-dos_fx
 DC.W     D_Fclose-dos_fx
 DC.W     D_Fread-dos_fx
 DC.W     D_Fwrite-dos_fx          ; 0x40
 DC.W     D_Fdelete-dos_fx
 DC.W     D_Fseek-dos_fx
 DC.W     D_Fattrib-dos_fx
 DC.W     D_Mxalloc-dos_fx         ; 0x44
 DC.W     D_Fdup-dos_fx
 DC.W     D_Fforce-dos_fx
 DC.W     D_Dgetpath-dos_fx
 DC.W     D_Malloc-dos_fx          ; 0x48
 DC.W     D_Mfree-dos_fx
 DC.W     D_Mshrink-dos_fx
 DC.W     D_Pexec-dos_fx
 DC.W     D_Pterm-dos_fx           ; 0x4c
 DC.W     ill_func-dos_fx
 DC.W     D_Fsfirst-dos_fx
 DC.W     Fsnext-dos_fx
 DC.W     ill_func-dos_fx          ; 0x50
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx          ; 0x54
 DC.W     ill_func-dos_fx
 DC.W     D_Frename-dos_fx         ; 0x56
 DC.W     D_Fdatime-dos_fx         ; 0x57
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     ill_func-dos_fx
 DC.W     D_Flock-dos_fx           ; 0x5c

dos_fx2:
 DC.W     D_Syield-dos_fx2         ; 0xff
 DC.W     D_Fpipe-dos_fx2          ; 0x100
 DC.W     ill_func-dos_fx2	; Ffchown
 DC.W     ill_func-dos_fx2	; Ffchmod
 DC.W     ill_func-dos_fx2	; Fsync
 DC.W     D_Fcntl-dos_fx2          ; 0x104
 DC.W     D_Finstat-dos_fx2        ; 0x105
 DC.W     D_Foutstat-dos_fx2       ; 0x106
 DC.W     D_Fgetchar-dos_fx2       ; 0x107
 DC.W     D_Fputchar-dos_fx2       ; 0x108
 DC.W     D_Pwait-dos_fx2          ; 0x109
 DC.W     D_Pnice-dos_fx2          ; 0x10a
 DC.W     D_Pgetpid-dos_fx2        ; 0x10b
 DC.W     D_Pgetppid-dos_fx2       ; 0x10c
 DC.W     D_Pgetpgrp-dos_fx2       ; 0x10d
 DC.W     D_Psetpgrp-dos_fx2       ; 0x10e
 DC.W     D_Pgetuid-dos_fx2        ; 0x10f
 DC.W     D_Psetuid-dos_fx2        ; 0x110
 DC.W     D_Pkill-dos_fx2          ; 0x111
 DC.W     D_Psignal-dos_fx2        ; 0x112
 DC.W     D_Pvfork-dos_fx2         ; 0x113
 DC.W     D_Pgetgid-dos_fx2        ; 0x114
 DC.W     D_Psetgid-dos_fx2        ; 0x115
 DC.W     D_Psigblock-dos_fx2      ; 0x116
 DC.W     D_Psigsetmask-dos_fx2    ; 0x117
 DC.W     D_Pusrval-dos_fx2        ; 0x118
 DC.W     D_Pdomain-dos_fx2        ; 0x119
 DC.W     D_Psigreturn-dos_fx2     ; 0x11a
 DC.W     D_Pfork-dos_fx2          ; 0x11b
 DC.W     D_Pwait3-dos_fx2         ; 0x11c
 DC.W     D_Fselect-dos_fx2        ; 0x11d
 DC.W     D_Prusage-dos_fx2        ; 0x11e
 DC.W     D_Psetlimit-dos_fx2      ; 0x11f
 DC.W     D_Talarm-dos_fx2         ; 0x120
 DC.W     D_Pause-dos_fx2          ; 0x121
 DC.W     D_Sysconf-dos_fx2        ; 0x122
 DC.W     D_Psigpending-dos_fx2    ; 0x123
 DC.W     D_Dpathconf-dos_fx2      ; 0x124
 DC.W     D_Pmsg-dos_fx2           ; 0x125
 DC.W     D_Fmidipipe-dos_fx2      ; 0x126
 DC.W     D_Prenice-dos_fx2        ; 0x127
 DC.W     D_Dopendir-dos_fx2       ; 0x128
 DC.W     D_Dreaddir-dos_fx2       ; 0x129
 DC.W     D_Drewinddir-dos_fx2     ; 0x12a
 DC.W     D_Dclosedir-dos_fx2      ; 0x12b
 DC.W     D_Fxattr-dos_fx2         ; 0x12c
 DC.W     D_Flink-dos_fx2          ; 0x12d
 DC.W     D_Fsymlink-dos_fx2       ; 0x12e
 DC.W     D_Freadlink-dos_fx2      ; 0x12f
 DC.W     D_Dcntl-dos_fx2          ; 0x130
 DC.W     D_Fchown-dos_fx2         ; 0x131
 DC.W     D_Fchmod-dos_fx2         ; 0x132
 DC.W     D_Pumask-dos_fx2         ; 0x133
 DC.W     D_Psemaphore-dos_fx2     ; 0x134
 DC.W     D_Dlock-dos_fx2          ; 0x135
 DC.W     D_Psigpause-dos_fx2      ; 0x136
 DC.W     D_Psigaction-dos_fx2     ; 0x137
 DC.W     D_Pgeteuid-dos_fx2       ; 0x138
 DC.W     D_Pgetegid-dos_fx2       ; 0x139
 DC.W     D_Pwaitpid-dos_fx2       ; 0x13a
 DC.W     D_Dgetcwd-dos_fx2        ; 0x13b
 DC.W     D_Salert-dos_fx2         ; 0x13c
 DC.W     D_Tmalarm-dos_fx2        ; 0x13d
 DC.W     D_Psigintr-dos_fx2       ; 0x13e
 DC.W     D_Suptime-dos_fx2        ; 0x13f
 DC.W     ill_func-dos_fx2         ; 0x140 ; Ptrace
 DC.W     ill_func-dos_fx2         ; 0x141 ; Mvalidate
 DC.W     D_Dxreaddir-dos_fx2      ; 0x142
 DC.W     D_Pseteuid-dos_fx2       ; 0x143
 DC.W     D_Psetegid-dos_fx2       ; 0x144
 DC.W     D_Pgetauid-dos_fx2       ; 0x145
 DC.W     D_Psetauid-dos_fx2       ; 0x146
 DC.W     D_Pgetgroups-dos_fx2     ; 0x147
 DC.W     D_Psetgroups-dos_fx2     ; 0x148
 DC.W     D_Tsetitimer-dos_fx2     ; 0x149
 DC.W     ill_func-dos_fx2         ; 0x14A ; Dchroot
 DC.W     ill_func-dos_fx2         ; 0x14B ; Fstat64
 DC.W     ill_func-dos_fx2         ; 0x14C ; Fseek64
 DC.W     ill_func-dos_fx2         ; 0x14D ; Dsetkey
 DC.W     Psetreuid-dos_fx2        ; 0x14E
 DC.W     Psetregid-dos_fx2        ; 0x14F
 DC.W     Ssync-dos_fx2            ; 0x150
 DC.W     ill_func-dos_fx2         ; 0x151
 DC.W     D_Dreadlabel-dos_fx2     ; 0x152   (338)
 DC.W     D_Dwritelabel-dos_fx2    ; 0x153


errcodes: DC.B  -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17
          DC.B  -32,-33,-34,-35,-36,-37,-39,-40,-46,-48,-49,-58,-59,-64,-65
          DC.B  -66,-67,-68,-69,-70,-80,0

     EVEN

errstrs:
*                BIOS- Fehler
 DC.W     err_1s-errstrs,err_02s-errstrs,err_03s-errstrs
 DC.W    err_04s-errstrs,err_05s-errstrs,err_06s-errstrs
 DC.W    err_07s-errstrs,err_08s-errstrs,err_09s-errstrs
 DC.W    err_10s-errstrs,err_11s-errstrs,err_12s-errstrs
 DC.W    err_13s-errstrs,err_14s-errstrs,err_15s-errstrs
 DC.W    err_16s-errstrs,err_17s-errstrs
*                GEMDOS- Fehler
 DC.W    err_32s-errstrs,err_33s-errstrs,err_34s-errstrs
 DC.W    err_35s-errstrs,err_36s-errstrs,err_37s-errstrs
 DC.W    err_39s-errstrs,err_40s-errstrs,err_46s-errstrs
 DC.W    err_48s-errstrs,err_49s-errstrs,err_58s-errstrs
 DC.W    err_59s-errstrs,err_64s-errstrs
 DC.W    err_65s-errstrs,err_66s-errstrs,err_67s-errstrs
 DC.W    err_68s-errstrs,err_69s-errstrs,err_70s-errstrs
 DC.W    err_80s-errstrs

     IF   COUNTRY=COUNTRY_DE

out_of_int_mem:
 DC.B     '*** KEIN INTERNER SPEICHER MEHR:',$1b,'K',$d,$a
 DC.B     '*** ADDMEM.PRG BENUTZEN!',0
dos_fatal_errs:
 DC.B     '*** FATALER FEHLER IM GEMDOS:',0

err_1s:  DC.B  'Schwerer Fehler',0
err_02s: DC.B  'Laufwerk nicht bereit',0
err_03s: DC.B  'Unbekanntes Kommando',0
err_04s: DC.B  'CRC- Fehler',0
err_05s: DC.B  'Kommando falsch',0
err_06s: DC.B  'Spur nicht gefunden',0
err_07s: DC.B  'Unbekanntes Medium',0
err_08s: DC.B  'Sektor nicht gefunden',0
err_09s: DC.B  'Kein Papier',0
err_10s: DC.B  'Schreibfehler',0
err_11s: DC.B  'Lesefehler',0
err_12s: DC.B  'Allgemeiner Fehler',0
err_13s: DC.B  'Disk schreibgesch',$81,'tzt',0
err_14s: DC.B  'Unerlaubter Diskwechsel',0
err_15s: DC.B  'Unbekanntes Ger',$84,'t',0
err_16s: DC.B  'Defekte Sektoren',0
err_17s: DC.B  'Andere Disk einlegen!',0

err_32s: DC.B  'Ung',$81,'ltige Funktionsnummer',0
err_33s: DC.B  'Datei nicht gefunden',0
err_34s: DC.B  'Pfad nicht gefunden',0
err_35s: DC.B  'Zuviele ge',$94,'ffnete Dateien',0
err_36s: DC.B  'Zugriff verweigert',0
err_37s: DC.B  'Ung',$81,'ltiges Handle',0
err_39s: DC.B  'Zuwenig Speicher',0
err_40s: DC.B  'Ung',$81,'ltiger Speicherblock',0
err_46s: DC.B  'Ung',$81,'ltiges Laufwerk',0
err_48s: DC.B  'Nicht dasselbe Laufwerk',0
err_49s: DC.B  'Keine weiteren Dateien',0
err_58s: DC.B  'Ger',$84,'t gesperrt',0
err_59s: DC.B  'Unlock- Fehler',0
err_64s: DC.B  'Falscher Bereich',0
err_65s: DC.B  'Interner Fehler',0
err_66s: DC.B  'Datei nicht ausf',$81,'hrbar',0
err_67s: DC.B  'Mshrink- Fehler',0
err_68s: DC.B  'Abbruch durch Benutzer',0         * KAOS
err_69s: DC.B  '68000 Exception',0                * KAOS
err_70s: DC.B  'Pfad zu tief',0                   * MAGIX
err_80s: DC.B  'Aliase zu tief verschachtelt',0   * MiNT
toserrs: DC.B  'TOS Fehler',0

change_s1:  DC.B  'Bitte Disk ',0
change_s2:  DC.B  ': in Laufwerk A: einlegen!',0
diskerr_s1: DC.B  ' auf Laufwerk ',0
diskerr_s2: DC.B  ':',$d,$a,'[A]bbruch, [W]iederholen, [I]gnorieren ? ',0

     ENDC
     IF   (COUNTRY=COUNTRY_US)|(COUNTRY=COUNTRY_UK)

out_of_int_mem:
 DC.B     '*** OUT OF INTERNAL MEMORY:',$1b,'K',$d,$a
 DC.B     '*** USE ADDMEM.PRG!',0
dos_fatal_errs:
 DC.B     '*** FATAL ERROR IN GEMDOS:',0

err_1s:  DC.B  'Basic error',0
err_02s: DC.B  'Drive not ready',0
err_03s: DC.B  'Unknown command',0
err_04s: DC.B  'CRC Error',0
err_05s: DC.B  'Bad request',0
err_06s: DC.B  'Seek error',0
err_07s: DC.B  'Unknown media',0
err_08s: DC.B  'Sector not found',0
err_09s: DC.B  'No paper',0
err_10s: DC.B  'Write fault',0
err_11s: DC.B  'Read fault',0
err_12s: DC.B  'General error',0
err_13s: DC.B  'Disk write protected',0
err_14s: DC.B  'Media changed',0
err_15s: DC.B  'Unknown device',0
err_16s: DC.B  'Bad sectors',0
err_17s: DC.B  'Insert other disk!',0

err_32s: DC.B  'Invalid function',0
err_33s: DC.B  'File not found',0
err_34s: DC.B  'Path not found',0
err_35s: DC.B  'Too many open files',0
err_36s: DC.B  'Access denied',0
err_37s: DC.B  'Invalid handle',0
err_39s: DC.B  'Insufficient memory',0
err_40s: DC.B  'Invalid memory block',0
err_46s: DC.B  'Invalid drive',0
err_48s: DC.B  'Not the same drive',0
err_49s: DC.B  'No more files',0
err_58s: DC.B  'Device locked',0
err_59s: DC.B  'Unlock error',0
err_64s: DC.B  'Range error',0
err_65s: DC.B  'Internal Error',0
err_66s: DC.B  'File not executable',0
err_67s: DC.B  'Mshrink failure',0
err_68s: DC.B  'User break',0                * KAOS
err_69s: DC.B  '68000 Exception',0           * KAOS
err_70s: DC.B  'Path overflow',0             * MAGIX
err_80s: DC.B  'Aliases overflow',0          * MiNT
toserrs: DC.B  'TOS Error',0

change_s1:  DC.B  'Please insert disk ',0
change_s2:  DC.B  ': in drive A: !',0
diskerr_s1: DC.B  ' at drive ',0
diskerr_s2: DC.B  ':',$d,$a,'[A]bort, [R]etry, [I]gnore ? ',0

     ENDC
    IF  COUNTRY=COUNTRY_FR

out_of_int_mem:
 DC.B   '*** PLUS DE M',$90,'MOIRE INTERNE:',$1b,'K',$d,$a
 DC.B   '*** UTILISER ADDMEM.PRG!',0
dos_fatal_errs:
 DC.B   '*** ERREUR FATALE DANS GEMDOS:',0

err_1s:  DC.B   'Erreur grave',0
err_02s: DC.B   'Lecteur non disponible',0
err_03s: DC.B   'Commande inconnue',0
err_04s: DC.B   'Erreur-CRC',0
err_05s: DC.B   'Commande erron',$82,'e',0
err_06s: DC.B   'Piste non trouv',$82,'e',0
err_07s: DC.B   'Support inconnu',0
err_08s: DC.B   'Secteur non trouv',$82,'',0
err_09s: DC.B   'Pas de papier',0
err_10s: DC.B   "Erreur d'",$82,"criture",0
err_11s: DC.B   'Erreur de lecture',0
err_12s: DC.B   'Erreur g',$82,'n',$82,'rale',0
err_13s: DC.B   'Disque prot',$82,'g',$82,' en ',$82,'criture',0
err_14s: DC.B   '',$90,'change de disque non autoris',$82,'',0
err_15s: DC.B   'P',$82,'riph',$82,'rique inconnu',0
err_16s: DC.B   'Secteurs d',$82,'fectueux',0
err_17s: DC.B   'Ins',$82,'rer un autre disque!',0

err_32s: DC.B   'Num',$82,'ro de fonction non valable',0
err_33s: DC.B   'Fichier non trouv',$82,'',0
err_34s: DC.B   'Chemin non trouv',$82,'',0
err_35s: DC.B   'Trop de fichiers ouverts',0
err_36s: DC.B   'Acc',$8a,'s refus',$82,'',0
err_37s: DC.B   'Handle non valable',0
err_39s: DC.B   'M',$82,'moire insuffisante',0
err_40s: DC.B   'Bloc de m',$82,'moire non valable',0
err_46s: DC.B   'Lecteur non valalble',0
err_48s: DC.B   "Ce n'est pas le m",$88,"me lecteur",0
err_49s: DC.B   "Pas d'autres fichiers",0
err_58s: DC.B   'P',$82,'riph',$82,'rique verrouill',$82,'',0
err_59s: DC.B   'Erreur-Unlock',0
err_64s: DC.B   'Zone erron',$82,'e',0
err_65s: DC.B   'Erreur interne',0
err_66s: DC.B   'Fichier non ex',$82,'cutable',0
err_67s: DC.B   'Erreur-Mshrink',0
err_68s: DC.B   "Abandon par l'utilisateur",0   * KAOS
err_69s: DC.B   'Exception 68000',0             * KAOS
err_70s: DC.B   'Chemin trop profond',0         * MAGIX
err_80s: DC.B   'Alias trop imbriqu',$82,'s',0            * MINT
toserrs: DC.B   'Erreur TOS',0


change_s1:  DC.B  'Svp, placer disque ',0
change_s2:  DC.B  ': dans lecteur A: !',0
diskerr_s1: DC.B  ' dans lecteur ',0
diskerr_s2: DC.B  ':',$d,$a,'[A]bandon, [R]ecommencer, [I]gnorer ? ',0

    ENDC


        END
