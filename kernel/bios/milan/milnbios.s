;
; BIOS fuer MagiC-Milan
;
; Tabulatorbreite: 5
;

MACINTOSH EQU  0
MACOSX    EQU  0
MILANCOMP EQU  1

DEBUG     EQU  0
DEBUG2    EQU  0
DEBUG3    EQU  0
DEBUG4    EQU  0


     EXPORT    _start
     EXPORT    getcookie
     EXPORT    bios2devcode        ; BIOS-Device => devcode (32 Bit)
     EXPORT    bios_rawdrvr        ; raw-Driver aus dem BIOS
     EXPORT    chk_rtclock
     EXPORT    read_rtclock
     EXPORT    pling               ; nach VDI
     EXPORT    kbshift             ; nach VDI,XAES
     EXPORT    altcode_asc         ; nach XAES
     EXPORT    iorec_kb            ; nach DOS,XAES
     EXPORT    ctrl_status         ; nach DOS
     EXPORT    cpu020              ; nach MATH
     EXPORT    is_fpu              ; nach XAES
     EXPORT    halt_system         ; nach DOS,AES
     XDEF      p_mgxinf            ; nach XAES
     EXPORT    machine_type        ; nach VDI,DOS
     EXPORT    config_status       ; nach DOS und AES
     EXPORT    pkill_vector        ; nach DOS und AES
     XDEF      status_bits         ; nach DOS und AES
     EXPORT    pe_slice            ; nach XAES
     EXPORT    pe_timer            ; nach XAES
     EXPORT    first_sem           ; nach XAES
     EXPORT    app0                ; nach AES
     XDEF      sust_len            ; nach AES
     XDEF      datemode            ; nach STD
     EXPORT    Bmalloc             ; nach DOS
     EXPORT    Bmaddalt            ; nach DOS (ab 25.9.96)
     EXPORT    dos_macfn           ; nach DOS
     EXPORT mmx_yield

     XDEF      p_vt52              ; neues VT52 nach DOS
     EXPORT    warm_boot           ; nach AES
     EXPORT    warmbvec,coldbvec   ; nach AES
     EXPORT    scrbuf_adr,scrbuf_len    ; nach DOS

     XREF      putch
     XREF      putstr

;Import vom DOS

     IMPORT    dos_init            ; DOS
     IMPORT    secb_ext            ; DOS
     XREF      iniddev1
     XREF      iniddev2
     XREF      deleddev

;Import vom AES

     IMPORT    appl_yield          ; XAES
     IMPORT    appl_suspend        ; XAES
     IMPORT    appl_IOcomplete     ; XAES
     IMPORT    evnt_IO             ; XAES
     IMPORT    evnt_sem            ; XAES
     IMPORT    act_appl            ; XAES
     IMPORT    endofvars           ; AES: Ende aller Variablen
     IMPORT    _ende               ; AES: Ende des Betriebssystems
     IMPORT    gem_magics          ; AES: Parameterblock

;Import von STD

     IMPORT    fast_clrmem
     IMPORT    date2str            ; void date2str( a0 = char *s,
     IF   DEBUG
     XREF hexl,crlf
     ENDIF
                                   ;                   d0 = WORD date)
;Import aus READ_INF

     IMPORT    read_inf            ; char *read_inf( void );
     IMPORT    rinf_vfat           ; void rinf_vfa( a0 = char *inf );
     IMPORT    rinf_img            ; void rinf_img( a0 = char *inf );
     IMPORT    rinf_log            ; long rinf_log( a0 = char *inf );
     IMPORT    rinf_coo
     IMPORT    rinf_bdev
     IMPORT    rinf_dvh

;Import aus MILAN.S

     IMPORT    get_cpu_typ
     IMPORT    get_fpu_typ
     IMPORT    imilan
     IMPORT    icpu
     IMPORT    ihdv
     IMPORT    icookies
     IMPORT    ivideo
     IMPORT    get_odevv
     IMPORT    ibkgdma
     IMPORT    isndhooks
     IMPORT    iexcvecs
     IMPORT    iperiph
     IMPORT    dmaboot
     IMPORT    apkgboot
     IMPORT    coldboot
     IMPORT    ivideo2
     IMPORT    ivdi1
     IMPORT    iintmask
     IMPORT    ivdi2
     IMPORT    icpu2
     IMPORT    gethtime
     IMPORT    ihz200
     IMPORT    iikbd
     IMPORT    imaptab
     IMPORT    bombs

;Import aus MATH.S

     IMPORT    _lmul

;----------------------------------------

     INCLUDE "dos.inc"
     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "milan.inc"
	include "country.inc"
	 INCLUDE "..\dos\magicdos.inc"
	 INCLUDE "version.inc"
	
;----------------------------------------


NCOOKIES  EQU  35
NSERIAL   EQU  5              /* max. Anzahl serieller Schnittstellen */
ALTGR     EQU  $4c
ALT_NUMKEY     EQU  1
DEADKEYS       EQU  0
N_KEYTBL       EQU  9+DEADKEYS            ; 9 Tastaturtabellen

     OFFSET

hd_acsibegin:  DS.L 1
hd_acsiend:    DS.L 1
hd_acsiwait:   DS.L 1
hd_ncrbegin:   DS.L 1
hd_ncrend:     DS.L 1
hd_ncrwait:    DS.L 1
hd_idebegin:   DS.L 1
hd_ideend:     DS.L 1
hd_idewait:    DS.L 1

     OFFSET

fbpb_bpb:      DS.B $12                 /*   0: BPB              */
fbpb_ntracks:  DS.W 1                   /* $12: Anzahl Tracks    */
fbpb_nsides:   DS.W 1                   /* $14: NSIDES           */
fbpb_nst:      DS.W 1                   /* $16: NSIDES * SPT     */
fbpb_spt:      DS.W 1                   /* $18: SPT              */
fbpb_nhid:     DS.W 1                   /* $1a: NHID             */
fbpb_serial:   DS.L 1                   /* $1c: char serial[3]   */
fbpb_msserial: DS.L 1                   /* $20: char msserial[4] */
fbpb_sizeof:

     TEXT

;---------------------------------------------------------------
;
; aktuelle Speicherbelegung (8.10.95):
; VDI ab $1200
; DOS ab $2900
;
;---------------------------------------------------------------
;
; "Oeffentliche Variablen"
;

     INCLUDE "bios.inc"
     INCLUDE "lowmem.inc"
     INCLUDE "debug.inc"

;--------------------------------------------------------------
;
; BIOS- Variablen:

milan               EQU  $9a4      ; Zeiger auf Uebergabestruktur

clear_area          EQU  $9a8

     OFFSET clear_area

iorec_kb:           DS.B $e             /* IOREC ($e Bytes)           */
iorec_kb_buf:       DS.B 256            /* char [256]                 */
                    DS.L 1              /*  -4: handle_key            */
kbdvecs:            DS.L 9              /*   0: midivec               */
                                        /*   4: vkbderr               */
                                        /*   8: vmiderr               */
                                        /*  $c: statvec               */
                                        /* $10: mousevec              */
                                        /* $14: clockvec              */
                                        /* $18: joyvec                */
                                        /* $1c: midisys               */
                                        /* $20: ikbdsys               */
                    DS.B 2              /* $24: char ikbd_state       */
                                        /* $25: char ikbd_cnt         */
kbshift:            DS.B 1              /* char kbshift               */
keyrepeat:          DS.B 3              /* char keyrepeat[3]          */
                                        /* keyrepeat[0]: Scancode     */
                                        /* keyrepeat[1]: Verzoeg       */
                                        /* keyrepeat[2]: unben.       */
altgr_status:       DS.B 1              /* char altgr_status          */
     IF   ALT_NUMKEY
alt_numkey:         DS.B 1              /* Fuer Alt-Num0..Num9         */
     ENDIF
     EVEN
key_delay:          DS.B 1              /* char                       */
key_reprate:        DS.B 1              /* char                       */
     EVEN
ctrl_status:        DS.W 1              /* char ctrl_status[2]        */
                                        /* erstes Byte: einschalten   */
                                        /* Bit 7: CTRL-C              */
                                        /* Bit 1: CTRL-S/CTRL-Q       */
keytblx:            DS.L N_KEYTBL       /* char *keytblx[9 !!!]       */
default_keytblxp:   DS.L 1              /*  Zeiger auf Defaults       */
pr_conf:            DS.W 1              /* int                        */
prtblk_vec:         DS.L 1              /* -> xbios Prtblk            */
flg_50hz:           DS.W 1              /* int                        */
last_random:        DS.L 1              /* long                       */

machine_type:       DS.B 1              /* char machine_type          */
                                        /* 0=ST 1=STE 2=Mega-STE 3=TT */
                                        /* 4=Falcon                   */
is_fpu:             DS.B 1              /* LineF- FPU existiert       */
     EVEN
stack_offset:       DS.W 1              /* 6:68000, 8: 68010 ff       */
config_status:      DS.L 1
                    DS.L 1              /* 04: hier -> DOSVARS            */
                    DS.L 1              /* 08: hier -> AESVARS            */
                    DS.L 1              /* 12: hier -> vdi_tidy           */
hddf_vector:        DS.L 1              /* 16: -> hddriver_functions      */
status_bits:        DS.L 1              /* 20: Bit 0: APP-Manager ist aktiv */
pkill_vector:       DS.L  1             /* 24: VERKETTEN: z.B. fuer DSP   */

cookies:            DS.L NCOOKIES*2     /* long cookies[17][2]        */
bconmap_struct:     DS.L 1              /* long *maptab               */
                    DS.W 1              /* int  maptabsize            */
                    DS.W 1              /* aktueller serieller Port (>= 6) */
p_rsconf:           DS.L 1              /* Pointer auf Rsconf (device 1)   */
p_iorec:            DS.L 1              /* Pointer auf iorec (device 1)    */
scrbuf_adr:         DS.L 1              /* Startadresse (netto, ohne MCB)  */
scrbuf_len:         DS.L 1              /* tatsaechliche Laenge              */
pe_slice:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
pe_timer:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
first_sem:
dummy_sem:          DS.B bl_sizeof      /* Dummy- Semaphore                */
app0:               DS.L 1              /* APP #0 und Default- Superstack  */
pgm_superst:        DS.L 1              /* Default- Superstack             */
p_mgxinf:                               /* nicht glchztg. mit pgm_userst   */
pgm_userst:         DS.L 1

;dflt_maptable:     DS.L 4*6            /* fuer 4 Eintraege a 24 Bytes       */
intern_maptab:      DS.L NSERIAL*6      ;interne MapTab. Enthaelt die Adressen
                                        ;der seriellen Mag!X-Biosroutinen
;
; Anschliessend eine Kopie der Geraetevektoren.
; Ist der Eintrag 0, so ist eine externe Routine eingehaengt, andernfalls ist
; die Adresse der Mag!X-Biosroutine eingetragen.
; Derzeit nur benutzt, um bei umgemappter serieller Schnittstelle (1) zwischen
; Mag!X- und externen Routinen zu unterscheiden - eventuell in Zukunft aber
; auch fuer andere Devices nuetzlich, die sich an die Registerkonventionen des
; neuen (X)Bios-Dispatchers halten.
mbiosvecs:
Bconstatvec:        DS.L 8
Bconinvec:          DS.L 8
Bcostatvec:         DS.L 8
Bconoutvec:         DS.L 8
                    DS.W 1         /* Laenge der folgenden Tabelle */
hddrv_tab:          DS.L 6
warmbvec:           DS.L 1         /* Sprungadr. fuer Ctrl-Alt-Del     */
coldbvec:           DS.L 1         /* Sprungadr. fuer Ctrl-Alt-Rsh-Del */
sust_len:           DS.L 1         ;Supervisorstack pro Applikation
datemode:           DS.W 1         ;fuer date2str (->STD.S)
log_fd:             DS.L 1              /* DateiHandle fuer Bootlog */
log_fd_pd:          DS.L 1              /* Prozessdeskriptor fuer Handle */
log_oldconout:      DS.L 1              /* Alter Vektor fuer Bootlog */
p_vt52:             DS.L 1              /* fuer VT52.PRG */
magic_pc:           DS.L 1
cpu020:             DS.W 1         /* nach MATH */
__e_bios:

IF __e_bios > $1199
$9a,"berlauf der Bios-Variablen"
ENDIF

	XDEF act_pd
	
     TEXT


_start:
; nur fuer PASM

        MC68030
        MC68881
        SUPER

;
; Die syshdr-Variablen <gem_magics> und __e_dos werden vom
; Lader initialisiert.
;

syshdr:
 bra.b    sys_start
 DC.W     $0300               ; MagiX: Versionsnummer 3.00
 DC.L     sys_start           ; Startadresse
 DC.L     syshdr              ; Anfangsadresse
 DC.L     __e_dos             ; Beginn des freien RAMs
 DC.L     sys_start
 DC.L     gem_magics          ; GEM- Parameterblock
 DC.L     D_BCD               ; USA-Format!
 DC.W     COUNTRY+COUNTRY+1   ; immer PAL !
 DC.W     D_DOSDATE           ; Datum im GEMDOS- Format
 DC.L     _mifl_unused        ; _root
 DC.L     kbshift
 DC.L     act_pd              ; _run
 DC.L     0


*
* Die CPU braucht nicht initialisiert zu werden.
* Das uebernimmt das Milan-TOS. Wir setzen nur
* den Supervisorstack.
*

sys_start:

     IF   DEBUG
     DEBON
     lea  _start(pc),a0
     DEBL a0,'_start = '
     ENDIF

 lea      endofvars,sp             ; Hier Stack setzen wegen ggf. Exception
 jsr      imilan                   ; Uebergabestruktur bestimmen
 jsr      icpu                     ; dummy

* BIOS- Variablenbereich loeschen

 lea      clear_area,a0
 lea      __e_bios,a1
 jsr      fast_clrmem

* DOS- Variablenbereich loeschen

 lea      __a_dos,a0
 lea      __e_dos,a1
 jsr      fast_clrmem

 clr.l    p_vt52_winlst            ; damit DOS nicht verwirrt wird

 lea      config_status,a0         ; config-Status-Block loeschen
 moveq    #7-1,d0
ccfl_loop:
 clr.l    (a0)+
 dbra     d0,ccfl_loop

*
* CPU, Cookies und machine_type
*

 move.w   #6,stack_offset
 jsr      get_cpu_typ
 clr.w    cpu020                        ; MATHS.S: 68020-Arithmetik moeglich?
 cmpi.b   #20,d0
 bcs.b    scpu_typ
 addq.w   #1,cpu020                     ; mindestens 020-Prozessor
scpu_typ:
 move.w   d0,cpu_typ
 beq.b    inst_cook
 move.w   #8,stack_offset
inst_cook:
 jsr      get_fpu_typ
 cmp.w    #40,cpu_typ
 bcs.s    set_fpu
 bne.s    set_fpu_060
 moveq    #8,d0
 bra.s    set_fpu
set_fpu_060:
 moveq    #16,d0
set_fpu:
 move.b   d0,is_fpu

 jsr      ivideo                        ; Videosystem initialisieren

 lea      cookies,a0
 move.l   a0,_p_cookies
 moveq    #NCOOKIES,d0
 jsr      icookies                      ; maschinenspez. Cookies

 ; Fix a bug in MilanTOS, which sets a wrong _FPU cookie value
 clr.l    d1
 move.b   is_fpu,d1
 swap     d1                            ; Wert
 move.l   #'_FPU',d0                    ; key
 bsr      putcookie

*
* "soft"-Cookies (_IDT und MagX)
*

 moveq #0,d1
 move.w   syshdr+$1c(pc),d1
 bclr     #0,d1
 cmp.w    #(idt_tab_end-idt_tab),d1
 bcs.s    idt_ok
 moveq    #0,d1
idt_ok:
 move.w idt_tab(pc,d1.w),d1
 move.l   #'_IDT',d0                    ; key
 bsr      putcookie
 move.l   #config_status,d1             ; Wert
 move.l   #'MagX',d0                    ; key
 bsr      putcookie
 bra.s    idt_done

idt_tab:
   dc.w $002f ; COUNTRY_US: 12h/MDY/'/'
   dc.w $112e ; COUNTRY_DE: 24h/DMY/'.'
   dc.w $112f ; COUNTRY_FR: 24h/DMY/'/'
   dc.w $112f ; COUNTRY_UK: 24h/DMY/'/'
   dc.w $112f ; COUNTRY_ES: 24h/DMY/'/'
   dc.w $102f ; COUNTRY_IT: 24h/MDY/'/'
   dc.w $122d ; COUNTRY_SE: 24h/YMD/'-'
   dc.w $112e ; COUNTRY_SF: 24h/DMY/'/'
   dc.w $112e ; COUNTRY_SG: 24h/DMY/'.'
   dc.w $112d ; COUNTRY_TR: 24h/DMY/'-'
   dc.w $112e ; COUNTRY_FI: 24h/DMY/'.'
   dc.w $112e ; COUNTRY_NO: 24h/DMY/'.'
   dc.w $112d ; COUNTRY_DK: 24h/DMY/'-'
   dc.w $102f ; COUNTRY_SA: 24h/MDY/'/'
   dc.w $102d ; COUNTRY_NL: 24h/DMY/'-'
   dc.w $112e ; COUNTRY_CZ: 24h/DMY/'.'
   dc.w $122d ; COUNTRY_HU: 24h/YMD/'-'
idt_tab_end:
idt_done:

*
* Beginn der TPA setzen
* Wir gehen davon aus, dass MagiC vorn im Speicher
* liegt und die TPA dahinter beginnt.
*

 move.l   #_ende,d0                     ; Ende von MagiC
 add.l    #$ff,d0
 andi.l   #$ffffff00,d0                 ; auf 256-Byte-Grenze
 move.l   d0,end_os
 move.l   d0,exec_os
 DEBL     d0,'end_os = '
 movea.l  syshdr+os_magic(pc),a0        ; Zeiger auf GEM- Parameterblock
 cmpi.l   #$87654321,(a0)+              ; gueltig ?
 bne.b    bot_no_aes                    ; nein
;move.l   (a0)+,end_os                  ; Ende der AES-Variablen ist egal
 addq.l   #4,a0
 move.l   (a0),exec_os
bot_no_aes:

*
* Installation einiger Exceptionvektoren fuer Disk und Ausgabe
*

 jsr      ihdv                          ; hdv_xxx initialisieren
 DEB      'Hdv-Vektoren initialisiert'

 jsr      get_odevv
 move.l   2*32(a0),prv_lsto             ; Bcostat fuer Geraet 0
 move.l   3*32(a0),prv_lst              ; Bconout fuer Geraet 0
 move.l   2*32+4(a0),prv_auxo           ; Bcostat fuer Geraet 1
 move.l   3*32+4(a0),prv_aux            ; Bconout fuer Geraet 1
 move.l   #do_hardcopy,scr_dump         ; MagiC 3.0: Dummy-Routine
 move.l   #do_hardcopy,prtblk_vec       ; MagiC 3.0: Dummy-Routine
 DEB      'Hardcopy initialisiert'

*
* Initialisierung des FRB sowie end_os und _membot
* Irgendwo ist noch ein boeser Fehler: Wenn _membot
*  nicht vergroessert wird (4k sind zuwenig), stuerzt
*  die Dateiauswahl (!) ab.
*

 move.l   milan,a0
 move.l   milh_frb_adr(a0),d0
 beq.b    bot_no_frb
 move.l   d0,a0
 move.l   (a0),d0
 beq.b    bot_no_frb
;move.l   d0,d0
 bsr      bmada_cook               ; Cookie eintragen
 DEB      'FRB-Puffer angelegt'
bot_no_frb:
 move.l   end_os,d0
; add.l   #$2000,d0                ; 8k (??!!??) noetig, sonst Crash
; move.l  d0,end_os                ; nicht noetig, aber 3.06 will es so
 move.l   d0,_membot
 DEBL     d0,'_membot = '

*
* weitere Initialialisierungen
*

 move.w   #8,nvbls
 st       _fverify
 move.w   #3,seekrate
 move.w   #-1,_dumpflg
 move.w   #-1,pe_slice             ; Zeitscheibensteuerung abschalten
 clr.l    act_appl                 ; single task

*
* Funktionen fuer Plattentreiber
*

 jsr      ibkgdma                  ; ACSI/FDC-Semaphoren usw.
 DEB      'Hintergrund-DMA initialisiert'

*
* diverse
*

;move.l   #syshdr,_sysbase
 move.l   #savptr_area,savptr
 move.l   #dummyfn,swv_vec
 clr.l    _drvbits
 clr.l    _shell_p                 ; !!! wird jetzt geloescht
 jsr      isndhooks                ; bell_hook,kcl_hook initialisieren
 move.l   #warm_boot,warmbvec      ; Sprungvektor fuer Ctrl-Alt-Del
 move.l   #coldboot,coldbvec       ; Sprungvektor fuer Ctrl-Alt-Rshift-Del

* RAM- syshdr erstellen (wozu ?)

 bsr      create_ram_syshdr

*
* unbenutzte oder Bomben- Exceptionvektoren initialisieren
*

 lea      8,a0
 lea      exc_vector(pc),a1
 moveq    #64-3,d0                 ; Vektoren 2..63
bot_loop:
 move.l   a1,(a0)+                 ; immer denselben Vektor
 dbra     d0,bot_loop
 DEB      'Vektoren 2..63 initialisiert'

*
* Benutzte Exceptionroutinen initialisieren
*

 lea      only_rte(pc),a3
 lea      dummyfn(pc),a4
 move.l   a3,$14                   ; Division durch 0
 tst.w    cpu_typ
 beq.b    excp_00                  ; 68000: priv.viol. bringt Bomben
 lea      ipriv(pc),a2             ; 68010/20/30/40/60: move sr,xx emulieren
 move.l   a2,$20                   ; Privilege violation
excp_00:
 moveq    #6,d0
 lea      $64,a1                   ; Autovektor- Interrupt Levels 1..7
bot_loop2:
 move.l   a3,(a1)+
 dbf      d0,bot_loop2
 DEB      'benutzte Vektoren initialisiert'
 jsr      iexcvecs                 ; Belegte Interrupts: HBL,VBL usw.
 DEB      'Interrupts initialisiert'

 move.l   #BiosDisp,$b4            ; BIOS
 move.l   #XBiosDisp,$b8           ; XBIOS
 move.l   a3,$88.w                 ; Trap #2   (Dummy)
 move.l   #int_vbl,$70             ; VBL

* etv_timer und etv_term auf RTS, VBL- Queue loeschen

 move.l   a4,etv_timer
;move.l   #bios_critic,etv_critic  ; wird vom DOS erledigt
 move.l   a4,etv_term
 lea      _vbl_list,a0
 move.l   a0,_vblqueue
 moveq    #7,d0
bot_loop3:
 clr.l    (a0)+
 dbf      d0,bot_loop3
 DEB      'weitere Interrupts initialisiert'

* Devicevektoren initialisieren

 jsr      get_odevv                ; ROM-Geraetevektoren ermitteln => a0
 lea      dev_vecs,a1
 lea      mbiosvecs,a2
 moveq    #$1f,d0
bot_loop4:
 move.l   (a0),(a1)+
 move.l   (a0)+,(a2)+
 dbf      d0,bot_loop4
 move.l   #bconin_con,dev_vecs+$28      ; Bconin(2)
 move.l   #bconin_con,mbiosvecs+$28     ; Bconin(2)
 move.l   #bconstat_con,dev_vecs+$8     ; Bconstat(2)
 move.l   #bconstat_con,mbiosvecs+$8    ; Bconstat(2)
 DEB      'Ger',$84,'tevektoren initialisiert'

* MFP und Vektoren initialisieren, Interrupts fuer 200Hz und IKBD

 jsr      iperiph
 DEB      'Peripherie initialisiert'
 move.w   #$1111,flg_50hz          ; jedes vierte Bit gesetzt
 move.w   #20,_timer_ms            ; 50Hz
 lea      int_hz200(pc),a0
 jsr      ihz200
 DEB      'hz200 initialisiert'
 lea      int_ikbd(pc),a0
 jsr      iikbd
 DEB      'IKBD-Interrupt initialisiert'

* Bconmap

 bsr      init_bconmap
 DEB      'Bconmap initialisiert'

* Tastatur

 lea      dummyfn(pc),a1
 lea      kbdvecs-4,a0
 move.l   #handle_key,(a0)+        ; kbdvecs-4:   (TOS 2.05)
 move.l   #dummyfn,(a0)+           ; kbdvecs:     midivec
 move.l   a1,(a0)+                 ; kbdvecs+4:   vkbderr
 move.l   a1,(a0)+                 ; kbdvecs+8:   vmiderr
 move.l   a1,(a0)+                 ; kbdvecs+$c:  statvec
 move.l   a1,(a0)+                 ; kbdvecs+$10: mousevec
 move.l   a1,(a0)+                 ; kbdvecs+$14: clockvec
 move.l   a1,(a0)+                 ; kbdvecs+$18: joyvec
 move.l   #midisys,(a0)+           ; kbdvecs+$1c: midisys
 move.l   #ikbdsys,(a0)            ; kbdvecs+$20: ikbdsys

 move.l   syshdr+os_magic(pc),a0
 move.w   -8(a0),pr_conf
 move.w   -6(a0),key_delay         ; delay/key_reprate
 move.b   #7,conterm

 lea      iorec_kb,a0
 lea      ori_iorec_kb(pc),a1
 moveq    #$d,d0
_cpyloop3:
 move.b   (a1)+,(a0)+
 dbf      d0,_cpyloop3

 move.l   #default_keytblx,default_keytblxp
 bsr      _Bioskeys                ; 9 Standard-Tastaturtabellen (GER)
 DEB      'Tastatur initialisiert'

; Aufloesung setzen (MagiX)

 jsr      ivideo2

* VDI 1. Initialisierung (vor DOS), VT52 initialisieren.

 jsr      ivdi1                    ; Initialisierung VOR Bootvorgang
 move.w   #1,vblsem

* Interrupts zulassen

 jsr      iintmask
 DEB      'Interrups zugelassen'

* Diskpuffer anlegen

 move.l   #4096,d0
 bsr      Bmalloc
 move.l   a0,_dskbufp              ; _dskbufp = Malloc(4096L)
 DEB      'Diskpuffer angelegt'

* DOS initialisieren

 jsr      dos_init
 DEB      'DOS initialisiert'
 move.l   milan,a6
 move.l   milh_meminfo(a6),a6
 move.w   (a6)+,d7                 ; Tabellenlaenge
 subq.w   #1,d7                    ; ST-RAM schon erledigt
 bra.b    addmem_nxt
addmem_loop:
 move.l   4(a6),-(sp)              ; Blocklaenge
 move.l   (a6),-(sp)               ; Blockadresse
 move.w   #$14,-(sp)
 trap     #1                       ; gemdos Maddalt
 adda.w   #10,sp
addmem_nxt:
 addq.l   #8,a6
 dbra     d7,addmem_loop
 DEB      'Alternativen Speicher angemeldet'

* Supervisorstack anlegen

 move.l   #SUPERSTACKLEN,sust_len  ; Groesse des Supervisorstacks pro App
 move.w   #3,-(sp)                 ; lieber FastRAM
 lea      ap_stack,a0
 add.l    sust_len,a0
 move.l   a0,-(sp)                 ; APP #0 und Supervisorstack allozieren
 move.w   #$44,-(sp)               ; Mxalloc()
 trap     #1
 addq.l   #2,sp
 tst.l    d0
 beq      fatal_err
 move.l   d0,app0
 add.l    (sp)+,d0                 ; Stacklaenge addieren
 addq.l   #2,sp
 move.l   d0,pgm_superst
 move.l   d0,a0                    ; neu
 move.l   a0,sp                    ; neu: ssp setzen

* Userstack anlegen

 move.w   #3,-(sp)                 ; lieber FastRAM
 pea      4096                     ; 4k Puffer allozieren
 move.w   #$44,-(sp)
 trap     #1
 addq.l   #2,sp
 tst.l    d0
 beq      fatal_err
 move.l   d0,pgm_userst            ; merken
 add.l    (sp)+,d0                 ; Stacklaenge addieren
 addq.l   #2,sp
 move.l   d0,a0
 move.l   a0,usp

 bsr      init_dosclock
 DEB      'DOS-Uhr initialisiert'

*
* Prozessorcaches und PMMU initialisieren
*

 jsr      icpu2

*
* Falcon-Sound initialisieren
*

; entfaellt

*
* Bootroutinen (nach wie vor gilt: sp == endofvars)
*

 bsr      try_ext_scsidrvr              ; residentes SCSI.RAM initialisieren
 DEB      'SCSI.RAM initialisiert'
 move.l   hdv_rw,-(sp)
 bsr      dskboot                  ; von Floppy booten
 DEB      'dskboot ausgef',$81,'hrt'
 bsr      apkgboot                 ; Flash-PKGs starten
 DEB      'apkgboot ausgef',$81,'hrt'
 move.l   (sp)+,a0
 cmpa.l   hdv_rw,a0
 bne.b    boot_no_dma              ; hat schon von Floppy gebootet

 bsr      dmaboot                  ; von SCSI und ACSI booten
 DEB      'dmaboot ausgef',$81,'hrt'
 jsr      secb_ext                 ; (Sektorpufferliste!)
 DEB      'Sektorpuffer erweitert'

boot_no_dma:
 bsr      exec_respgms             ; residente Programme ausfuehren
 DEB      'residente Programme ausgef',$81,'hrt'

*
* VDI nach DMA-Boot initialisieren (muss Treiber laden)
*

 jsr      ivdi2

*
* Jetzt geht es los.
*

 move.l   pgm_userst,-(sp)         ; allozierten Userstack wieder freigeben
 move.w   #73,-(sp)                ; Mfree
 trap     #1
 addq.l   #6,sp
 tst.w    d0
 bne      fatal_err

 DEB      'user stack freigegeben'

* Bootlaufwerk setzen
* MAGX.INF lesen
* VFAT, Tastaturtabellen, Log-Datei, Startbild
* XTENSION, AUTO
* AES starten
* Aufloesungswechsel

     INCLUDE "auto.s"

cold_boot:
 jmp      coldboot

     INCLUDE "puntaes.s"



**********************************************************************
*
* long dos_macfn( d0 = int dos_fnr, a0 = void *params )
*
* ruft auf dem Macintosh spezielle DOS-Funktionen auf, deren
* Funktionsnummern zwischen 0x60 und 0xfe liegen
*

dos_macfn:
 moveq   #EINVFN,d0
 rts

**********************************************************************
*
* long bios_rawdrvr( d0 = int opcode, d1 = long devcode, ... )
*
* Fuehrt geraetespezifische Aktionen aus.
*
* d0 = 0: Medium auswerfen.
*
* Da dieser Treiber nur die Floppies A: und B: bedient, gibt
* es nur ein EINVFN. Anders wird es beim Mac.
*

bios_rawdrvr:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long bios2devcode( d0 = int biosdev )
*
* Rechnet ein BIOS-Device in einen devcode um (major/minor)
* Rueckgabe 0, wenn Fehler
* wird vom DOS aufgerufen
*

bios2devcode:
 cmpi.w   #1,d0               ; Laufwerke A: oder B: ?
 bhi.b    b2dc_err            ; nein
 swap     d0
 move.w   #64,d0
 swap     d0                  ; major = 64 (XHDI-Spezifikation)
 rts
b2dc_err:
 moveq    #0,d0
 rts


*********************************************************************
*
* Der Zugriff bei Rwabs ist bei gesetztem LOCK nur fuer den
* sperrenden Prozess erlaubt
*

IRwabs:
 movem.l  d3-d7/a3-a6,-(sp)
 subq.l   #4,sp                    ; Platz fuer Zeiger
 lea      12(a0),a0
 move.l   (a0),-(sp)               ; lrecno
 move.l   -(a0),d0                 ; recno/dev
; Auf LOCK testen und Zugriffszeit merken
 move.w   d0,a1
 add.w    a1,a1
 add.w    a1,a1
 move.l   a1,4(sp)                 ; merken fuer DOS- Writeback
 move.l   dlockx(a1),d3
 beq.b    rwabs_ok
 cmp.l    act_pd,d3
 bne.b    rwabs_elocked
rwabs_ok:
 clr.l    bufl_timer(a1)      ; fuer DOS-Writeback (als in Arbeit markieren)
 move.l   d0,-(sp)            ; recno/dev
 move.l   -(a0),-(sp)         ; count/buf.lo
 move.l   -(a0),-(sp)         ; buf.hi/rwflag
 move.l   hdv_rw,a1
 jsr      (a1)
 lea      16(sp),sp
rwabs_ende:
 move.l   (sp)+,a1
 move.l   _hz_200,bufl_timer(a1)   ; fuer DOS- Writeback
 movem.l  (sp)+,d3-d7/a3-a6
 rte
     
rwabs_elocked:
 moveq    #ELOCKED,d0
 addq.l   #4,sp
 bra.b    rwabs_ende


**********************************************************************
*
* void dskboot( void )
*
* versucht, vom internen Treiber zu booten
*

dskboot:
 move.l   hdv_boot,d0
 beq.b    dskb_ende
 move.l   d0,a0
     DEBL hdv_boot,'springe nach hdv_boot = '
 jsr      (a0)
; tst.w    d0
; bne.b    dskb_ende
;     IFNE DEBUG
; lea      strt_ss(pc),a0
; bsr      putstr
;     ENDIF
; bsr      hdl_pling
; move.l   _dskbufp,a0
; jsr      (a0)
dskb_ende:
 rts


**********************************************************************
*
* Fuehrt einen Warmstart aus
*
* beim 68020/30 werden die Caches abgeschaltet
*

warm_boot:
 jmp      MILAN_ROM
     IFNE 0
 move     #$2700,sr                ; Interrupts sperren, SUP
;cmpi.w   #20,cpu_typ
;bcs.b    warmb_00
;move.l   #$808,d0                 ; Bit  0=0: instr cache off
                                   ; Bit     3=1: instr cache clear
                                   ; Bit     8=0: data  cache off
                                   ; Bit 11=1: data  cache clear
;movec.l  d0,cacr
warmb_00:
;reset                             ;versuchsweise
 cmp.l    #$31415926,$00000426.w   ;resvalid
 bne      sys_start
 move.l   $42a.w,d0                ;resvector
 btst     #0,d0
 bne      sys_start
 move.l   d0,a0
 lea      warmb_00(pc),a6          ;Ruecksprungadresse
 jmp      (a0)
 bra      sys_start
     ENDIF

**********************************************************************
*
* void try_ext_scsidrvr( void )
*
* Versucht, ein residentes SCSI.RAM zu initialisieren.
*

try_ext_scsidrvr:
;Test auf SCSI-RAM. Setze Busfehlervektor fuer den Fall, dass die
; Systemvariable $868 Schrott enthalten sollte.
 movea.l  8.w,a0
 movea.l  sp,a1
 move.l   #no_scsiram,8.w               ;Busfehlervektor setzen

 move.l   ext_scsidrivr.w,d0
 beq.b    no_scsiram
 move.l   d0,a2
 cmp.l    #'SCSI',(a2)             ;SCSI.RAM-Magic vorhanden?
 bne.b    no_scsiram
 cmpa.l   4(a2),a2                 ;Dieser Pointer muss aufs SCSI-Magic zeigen
 bne.b    no_scsiram

 movea.l  a1,sp
 move.l   a0,8.w                   ;Busfehlervektor zurueck
 jsr      8(a2)                    ;Init des SCSI.RAM aufrufen (zerlegt Reg. ...)
 bra.b    try_dskboot

no_scsiram:
 movea.l  a1,sp
 move.l   a0,8.w                   ;Busfehlervektor zurueck
;
try_dskboot:
 rts


**********************************************************************
*
* long Drvmap( void )
*

Drvmap:
 move.l   _drvbits,d0
 rte


**********************************************************************
*
* long ret0( void )
*

ret0:
 moveq    #0,d0

**********************************************************************
*
* void dummyfn( void )
*

dummynopfn:
 nop        ;Eingefuegt wegen jsr 4(a2) in Bconout()!
 nop
dummyfn:
 rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Rsconf
Rsconf:
 move.l     p_rsconf,a1
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     10(a0),-(sp)   ;scr
 move.w     8(a0),-(sp)    ;tst
 move.w     6(a0),-(sp)    ;rsr
 move.w     4(a0),-(sp)    ;ucr
 move.w     2(a0),-(sp)    ;flowctl
 move.w     (a0),-(sp)     ;speed
 jsr        (a1)
 lea        12(sp),sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

**********************************************************************
*
* TRAP- Einspruenge fuer den 680x0
*
xbios_tab:
 DC.W     45
 DC.L     Initmous            ; 0
 DC.L     dummy_rte           ; 1=Ssbrk
 DC.L     Physbase
 DC.L     Logbase
 DC.L     Getrez
 DC.L     Setscreen           ; 5
 DC.L     Setpalette
 DC.L     Setcolor
 DC.L     Floprd
 DC.L     Flopwr
 DC.L     Flopfmt             ; 10
 DC.L     ret0_rte            ; Getdsb
 DC.L     Midiws
 DC.L     Mfpint
 DC.L     Iorec
 DC.L     Rsconf              ; 15
 DC.L     Keytbl
 DC.L     Random
 DC.L     Protobt
 DC.L     Flopver
 DC.L     Scrdmp              ; 20
 DC.L     Cursconf
 DC.L     Settime
 DC.L     Gettime
 DC.L     Bioskeys
 DC.L     Ikbdws              ; 25
 DC.L     Jdisint
 DC.L     Jenabint
 DC.L     Giaccess
 DC.L     Offgibit
 DC.L     Ongibit             ; 30
 DC.L     Xbtimer
 DC.L     Dosound
 DC.L     Setprt
 DC.L     Kbdvbase
 DC.L     Kbrate              ; 35
 DC.L     Prtblk
 DC.L     Vsync
 DC.L     Supexec
 DC.L     Puntaes             ; 39, Puntaes
 DC.L     dummy_rte
 DC.L     Floprate            ; 41
 DC.L     DMAread             ; 42
 DC.L     DMAwrite            ; 43
 DC.L     Bconmap             ; 44

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bios_tab:
 DC.W     12
 DC.L     Getmpb              ; 0
 DC.L     Bconstat
 DC.L     Bconin
 DC.L     Bconout
 DC.L     IRwabs              ;4
 DC.L     Setexc
 DC.L     Tickcal
 DC.L     IGetbpb             ;7
 DC.L     Bcostat
 DC.L     IMediach            ;9
 DC.L     Drvmap
 DC.L     Kbshift

;
; Der neue (X)Bios-Dispatcher sichert, wenn notwendig, die Register auf dem
; ssp => Um dies Stackbelastung moeglichst wenig zu halten, sollten kurze
; Unterroutinen (4-20 Bytes) expandiert werden.
XBiosDisp:
   lea      xbios_tab(pc),a1
   bra.b    _biosdisp

BiosDisp:
   lea      bios_tab(pc),a1
_biosdisp:
   move     usp,a0            ;Zeiger auf Parameter holen
   btst     #5,(sp)           ;Usermode ?
   beq.b    Bios_user
   movea.l  sp,a0
   adda.w   stack_offset,a0   ;Stack-Offset (6 bzw. 8 Bytes)
Bios_user:
   move.w   (a0)+,d0          ;Opcode
   cmp.w    (a1)+,d0
   bcc.b       exit_bios
_again:
   add.w    d0,d0
   add.w    d0,d0
   move.l   (a1,d0.w),a1      ;Adresse der Biosroutine holen
   jmp      (a1)
exit_bios:
 cmpa.l   #xbios_tab+2,a1     ; war XBIOS?
 bne.b    dummy_rte           ; nein, war BIOS
; Wir versuchen noch mal die XBIOS-Tabelle des ROMs
 move.l   milan,a1
 move.l   milh_xbios_fnx(a1),a1
 cmp.w    (a1)+,d0
 bcs.b    _again

dummy_rte:
   rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IGetbpb:
 move.l     hdv_bpb,a1  ; 7=Getbpb
 bra.b      _biossave

IMediach:
 move.l     hdv_mediach,a1   ; 9=Mediach

_biossave:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     (a0),-(sp)    ;Device eintragen
 jsr        (a1)
 addq.l     #2,sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte


**********************************************************************
*
* long Supexec( long (*pgm)() )
*

Supexec:
   move.l   (a0),a0
   movem.l  d3-d7/a3-a6,-(sp) ;aus Kompatibilitaetsgruenden sichern
   jsr      (a0)
   movem.l  (sp)+,d3-d7/a3-a6
   rte


**********************************************************************
*
* int Bconstat( int dev )
*

Bconstat:
   lea      dev_vecs,a1
   lea      Bconstatvec,a2
   moveq    #0,d1             ;Offset in Tabelle
   bra.b    calc_Bvec

**********************************************************************
*
* long Bconin( int dev )
*

Bconin:
   lea      dev_vecs+$20,a1
   lea      Bconinvec,a2
   moveq    #4,d1
   bra.b    calc_Bvec

**********************************************************************
*
* int Bcostat( int dev )
*

Bcostat:
   lea      dev_vecs+$40,a1
   lea      Bcostatvec,a2
   moveq    #8,d1

calc_Bvec:
   move.w   (a0)+,d0          ;Device
   cmp.w    #5,d0             ;ST-Geraet ?
   bls.b    Bdev_st           ;ja, normale Routine

   subq.w   #6,d0             ;Offset fuer erweiterte serielle Schnittstellen
   cmp.w    bconmap_struct+4,d0 ;Anzahl zusaetzlicher Schnittstellen
   bcc      ret0_rte          ;ueberschritten, return(0L) (kein Fehler??!!??)

   lea      intern_maptab,a2  ;max 4 * 6 Eintraege auf die seriellen-Routinen
   movea.l  bconmap_struct,a1
   lsl.w    #3,d0             ;*24...
   adda.w   d0,a1
   adda.w   d0,a2
   add.w    d0,d0
   add.w    d1,d0             ;+Offset der Routine innerhalb der Tabelle
   adda.w   d0,a1
   adda.w   d0,a2
   movea.l  (a1),a1           ;Adresse ermitteln...
   movea.l  (a2),a2
   cmpa.l   a1,a2             ;id. ?
   bne.b    Bvec_changed      ;andere Routine eingehaengt !
   jsr      (a2)
   rte

Bdev_st:
   add.w    d0,d0
   add.w    d0,d0
   movea.l  0(a1,d0.w),a1     ;Bios-Vektor
   movea.l  0(a2,d0.w),a2     ;Adr. der Orginalroutine
   cmpa.l   a1,a2             ;id. ?
   bne.b    Bvec_changed      ;andere Routine eingehaengt !
   jsr      (a2)              ;in die eigene Routine
   rte

Bvec_changed:
   movem.l  d3-d7/a3-a6,-(sp)
   move.w   -(a0),-(sp)       ;Device eintragen
   jsr      (a1)
   addq.l   #2,sp
   movem.l  (sp)+,d3-d7/a3-a6
   rte


**********************************************************************
*
* long Bconout( int dev, int c )
*

Bconout:
   lea      dev_vecs+$60,a1
   lea      Bconoutvec,a2

   move.w   (a0)+,d0          ;Device
   cmp.w    #5,d0             ;ST-Geraet ?
   bls.b    dev_st            ;ja, normale Routine

   subq.w   #6,d0             ;Offset fuer erweiterte serielle Schnittstellen
   cmp.w    bconmap_struct+4,d0 ;Anzahl zusaetzlicher Schnittstellen
   bcc      ret0_rte          ;ueberschritten, return(0L) (kein Fehler??!!??)

   lea      intern_maptab,a2  ;max 4 * 6 Eintraege auf die seriellen-Routinen
   moveq    #12,d1            ;Tabellen-Offset
   movea.l  bconmap_struct,a1
   lsl.w    #3,d0
   adda.w   d0,a1
   adda.w   d0,a2
   add.w    d0,d0
   add.w    d1,d0             ;+Offset der Routine innerhalb der Tabelle
   adda.w   d0,a1
   adda.w   d0,a2
   movea.l  (a1),a1           ;Adresse der Routine ermitteln...
   movea.l  (a2),a2
   cmpa.l   a1,a2             ;id. ?
   bne.b    Bovec_changed     ;andere Routine eingehaengt !
   jsr      4(a2)             ; "lea 6(sp),a0" ueberspringen
   rte

dev_st:
   add.w    d0,d0
   add.w    d0,d0
   movea.l  0(a1,d0.w),a1     ; Bios-Vektor
   movea.l  0(a2,d0.w),a2     ; Adr. der Orginalroutine
   cmpa.l   a1,a2             ; id. ?
   bne.b    Bovec_changed     ; andere Routine eingehaengt !
   jsr      4(a2)             ; "lea 6(sp),a0" ueberspringen
                              ; in die eigene Routine

   rte
;
Bovec_changed:
   movem.l  d3-d7/a3-a6,-(sp)
   move.w   (a0),-(sp)     ;Zeichen
   move.w   -(a0),-(sp)    ;Device eintragen
   jsr      (a1)
   addq.l   #4,sp
   movem.l  (sp)+,d3-d7/a3-a6
   rte

ret0_rte:
   moveq #0,d0
   rte


**********************************************************************
*
* Bconstat fuer Geraet 2 (CON) machen wir
* selber
*

bconstat_con:
 lea      iorec_kb+6,a0            ; *Head-Index
 cmpm.w   (a0)+,(a0)+              ; Head-Index mit Tail-Index vergleichen
 sne.b    d0                       ; TRUE, wenn Puffer nicht leer
 ext.w    d0
 ext.l    d0                       ; auf Langwort erweitern
 rts


**********************************************************************
*
* Bconin fuer Geraet 2 (CON) machen wir
* selber
*

bconin_con:
 lea      iorec_kb,a0              ; IKBD-Iorec
 moveq    #4,d2                    ; Groesse eines Arrayelementes
_bconin:
 lea      8(a0),a1                 ; *Tail
 move.w   (a1),d1                  ; Tail-Index
 cmp.w    -(a1),d1                 ; Head-Index
 beq.b    _bconin
; Head- Index ist ungleich Tail- Index, also Zeichen da!
 move     sr,-(sp)
 ori      #$700,sr                 ; Interrupts sperren
 move.w   (a1)+,d1                 ; Head-Index
 cmp.w    (a1),d1                  ; Tail-Index
 beq.b    bin_again                ; jetzt ist das Zeichen weg! (Fehler!)
; Das Zeichen ist immer noch da
 add.w    d2,d1                    ; Head-Index erhoehen
 movea.l  (a0)+,a1                 ; Pufferzeiger

 cmp.w    (a0)+,d1                 ; mit Puffergroesse vergleichen
 bcs.b    bin_l1
 moveq    #0,d1                    ; Pufferzeiger auf Pufferbeginn
bin_l1:
 add.w    d1,a1
 move.w   d1,(a0)                  ; neuer Head-Index
 subq.l   #4,d2                    ; long oder byte ?
 beq.b    bin_long
 moveq    #0,d0
 move.b   (a1),d0                  ; Zeichen (Byte)
 bra.b    bin_all
bin_long:
 move.l   (a1),d0                  ; Zeichen (Long)
bin_all:
 move.w   (sp)+,sr
 rts
* zwischen Abfrage und Sperren des Interrupts ist uns das Zeichen geklaut
* worden, daher gehen wir noch einmal in die Warteschleife
bin_again:
 move.w   (sp),sr
 bra.b    _bconin


**********************************************************************
*
* void Getmpb( MPB *mpb )
*
* Hier wird nur das "ST-RAM" eingerichtet. Die weiteren Bloecke
* werden manuell ueber Maddalt hinzugefuegt.
* Das ST-RAM laeuft einfach von _membot bis _memtop. Beide Variablen
* werden vom Ladeprogramm gesetzt, wobei _memtop eigentlich schon
* vorher gueltig sein muss. _membot zeigt hinter das geladene
* MAGIC.RAM.
*

Getmpb:
 movea.l  (a0),a0                  ; Tabelle, in die die drei Zeiger kommen
 lea      themd,a1
 move.l   a1,(a0)+                 ; themd in die freelist
 clr.l    (a0)+                    ; alloclist loeschen
 move.l   a1,(a0)                  ; themd als roving pointer
 clr.l    (a1)+                    ; Listenende
 move.l   _membot,(a1)+            ; Startadresse _membot
 move.l   _memtop,d0
 sub.l    _membot,d0
 move.l   d0,(a1)+                 ; Laenge
 clr.l    (a1)                     ; kein owner
 rte


**********************************************************************
*
* long Bmaddalt( void )
*
* 25.9.96:     Wird bei DOS Maddalt() aufgerufen, um ggf. einen FRB
*              anzulegen. Rueckgabe ENSMEM, falls dies nicht geht.
*              Legt keinen (!) Cookie _FRB an.
*
* MagiC 6:     Legt Cookie an, falls genuegend Platz im Jar
*
* Milan: Der Cookie wird immer schon beim Booten angelegt.
*

Bmaddalt:
 bra.b    bmada_ok       ; immer OK
bmada_cook:
 move.l   d0,d1          ; Wert
 move.l   #'_FRB',d0     ; key
 bsr      putcookie
bmada_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* long Setexc( int nr, long vec )
*

Setexc:
     IF   0
 movea.w  (a0)+,a1                 ; nr
 add.w    a1,a1
 add.w    a1,a1                    ; mal 4 fuer Langwortzugriff
 move.l   (a1),d0                  ; bisheriger Vektor
 move.l   (a0),d1                  ; -1 oder neuer Wert
 bmi.b    sxc_ende
 move.l   d1,(a1)                  ; setzen
sxc_ende:
 rte
     ENDIF
 moveq    #5,d0
 add.l    d0,d0
 add.l    d0,d0
 move.l   milan,a2
 move.l   milh_bios_fnx(a2),a2
 move.l   2(a2,d0.l),a2
 jmp      (a2)


**********************************************************************
*
* void init_dosclock(void)
*

init_dosclock:
 jsr      gethtime
 move.w   d0,dos_time
 swap     d0
 move.w   d0,dos_date
 rts


**********************************************************************
*
* CS chk_rtclock(void)
*
* Wird vom DOS aufgerufen
*

chk_rtclock:
 moveq    #0,d0
 subq.w   #1,d0                    ; Carry setzen
 rts


**********************************************************************
*
* long read_rtclock(void)
*
* Wird vom DOS aufgerufen
*

read_rtclock:
 moveq    #0,d0
 rts


**********************************************************************
*
* long Tickcal( void )
*

Tickcal:
 moveq    #0,d0
 move.w   _timer_ms,d0
 rte


**********************************************************************
*
* void *Bmalloc( d0 = long amount )
*
* Achtung: darf nur vor dos_init() aufgerufen werden.
* aendert nicht d0
*

Bmalloc:
 move.l   _membot,a0
 add.l    d0,_membot
 rts


**********************************************************************
*
* void fatal_err( void )
*
* Ein fataler Fehler fuehrt zum Anhalten des Systems
*

fatal_err:
 lea      fatal_bios_errs(pc),a0


**********************************************************************
*
* global void halt_system(a0 = char *errmsg)
*

halt_system:
 moveq    #$d,d0
 bsr      putch
 moveq    #$a,d0
 bsr      putch
 moveq    #$a,d0                   ; CR,LF,LF
 bsr      putch
 bsr      putstr                   ; Benutzermeldung
 lea      fatal_errs(pc),a0
 bsr      putstr                   ; "System angehalten"
halt_endless:
 bra      halt_endless

**********************************************************************
*
* Wir brauchen hier nur einen gemeinsamen Exceptionvektor, denn
* wir haben mindestens einen 030, der die Vektornummer sichert.
* Der Inhalt von proc_pc wird dabei daemlich gesetzt, denn die obersten
* 8 Bit werden durch die Vektornummer ersetzt.
*

exc_vector:
 movem.l  d0-d7/a0-a7,proc_regs
 move.l   2(sp),proc_pc.w
 move.w   6(sp),d0                 ; Frame-Typ und Vektor-Offset
 and.w    #$fff,d0                 ; Vektor-Offset isolieren
 lsr.w    #2,d0                    ; und in Vektornummer wandeln
 move.b   d0,proc_pc.w             ; ins Hibyte von proc_pc
 move     usp,a0
 move.l   a0,proc_usp
 moveq    #15,d0                   ; die obersten 16 Stack-Worte
 lea      proc_stk,a0
 movea.l  sp,a1
pb_loop:
 move.w   (a1)+,(a0)+
 dbf      d0,pb_loop
 move.l   #$12345678,proc_lives
 move.l   sp,a3
 move.l   act_pd,a4
 jsr      bombs
 move.l   #savptr_area,savptr
* Betriebssystem ueberpruefen
 lea      _start,a0
 lea      _ende,a1
 moveq    #0,d0
os_chkloop:
 add.l    (a0)+,d0
 cmpa.l   a0,a1
 bcs.b    os_chkloop
 cmp.l    os_chksum,d0
 beq.b    os_chk_ok
 lea      os_corr_s(pc),a0
 bsr      putstr
 jsr      get_odevv
 move.l   32+2*4(a0),a2            ; Bconin Geraet 2
 jsr      (a2)
os_chk_ok:
* Prozess beenden
 move.w   #-1,-(sp)
 btst.b   #5,config_status+3       ; KAOS oder TOS ?
 bne.b    pb_tos
 move.w   #$ffbb,(sp)              ; EXCPT

pb_tos:
 tst.b    $4ca                     ; debug mode ?
 bne.w    pb_tos

 move.w   #$4c,-(sp)
 trap     #1
 bra      sys_start


**********************************************************************
*
* void Prtblk( ??? *par, int subfn, ... )
*
* Neu: ist par == NULL, werden weitere Parameter ausgewertet.
*      subfn = 0:   Klinke andere Prtblk- Funktion ein
*

Prtblk:
 move.l   (a0),d0
 beq.b    prb_spec
 move.l   prtblk_vec,a1
 jmp      (a1)                     ; ab geht es
prb_spec:
 addq.l   #4,a0
 move.w   (a0)+,d0                 ; int subfn
 bne.b    prb_err
* Unterfunktion 0: Prtblk einklinken
 move.l   prtblk_vec,d0            ; alte Routine zurueckgeben
 move.l   (a0),prtblk_vec
 rte
prb_err:
 moveq    #ERANGE,d0
 rte


**********************************************************************
*
* void Scrdmp( void )
*
Scrdmp:
 movem.l    d3-d7/a3-a6,-(sp)
 bsr.b      _Scrdmp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Scrdmp:
 movea.l  scr_dump,a0
 move.l   a0,d0                    ; Hardcopy installiert ?
 beq.b    _scrd_err                ; nein !
 jsr      (a0)
* MagiC 3.0: DUMMY-ROUTINE FUeR HARDCOPY
do_hardcopy:
_scrd_err:
 move.w   #-1,_dumpflg
 rts


**********************************************************************
*
* void exec_respgms( void )
*
* Fuehrt resetfeste Programme aus
*

exec_respgms:
 movea.l  phystop,a0
exr_loop1:
 move.l   #$12123456,d0
 lea      $400,a1
 lea      $200,a2
exr_loop2:
 suba.w   a2,a0
 cmpa.l   a1,a0
 beq.b    exr_ende
 cmp.l    (a0),d0
 bne.b    exr_loop2
 cmpa.l   4(a0),a0
 bne.b    exr_loop2
 clr.w    d0
 movea.l  a0,a1
 move.w   #$ff,d1
exr_loop3:
 add.w    (a1)+,d0
 dbf      d1,exr_loop3
 cmp.w    #$5678,d0
 bne.b    exr_loop1
 move.l   a0,-(sp)
 jsr      8(a0)
 movea.l  (sp)+,a0
 bra.b    exr_loop1
exr_ende:
 rts


**********************************************************************
*
* void create_ram_syshdr( void )
*

create_ram_syshdr:
 lea      syshdr(pc),a0                 ; TOS- Header im ROM
 lea      ram_syshdr,a1                 ; TOS- Header im RAM
 moveq    #$2f,d0                       ; sicherheitshalber 48 Bytes
crsh_loop:
 move.b   0(a0,d0.w),0(a1,d0.w)
 dbf      d0,crsh_loop
 move.w   jmpop(pc),-6(a1)              ; Opcode fuer "jmp"
 move.l   4(a1),-4(a1)                  ;                  os_start
 move.w   braop(pc),(a1)                ; Branch auf "jmp os_start"
 ;move.w   $1e(a1),$1c(a1)               ; gendatg->palmode ??
 move.l   a1,_sysbase
 rts
jmpop:
 dc.w $4ef9
long_zero: dc.l 0
braop:
 bra.b    jmpop



**********************************************************************
*
* long Random( void )
*
* veraendert d0/d1/d2
*
Random:
 bsr.b   _Random
 rte

_Random:
 move.l   #$bb40e62d,d1            ; Pi (als unsigned long)
 move.l   last_random,d0
 bne.b    _ran_lok
 move.l   _hz_200,d0
 swap     d0
 clr.w    d0
 or.l     _hz_200,d0
 move.l   d0,last_random
_ran_lok:
 jsr       _lmul
 addq.l   #1,d0
 move.l   d0,last_random
 lsr.l    #8,d0
 rts


**********************************************************************
*
* EQ/NE d0 = long getcookie( d0 = long val )
*
* Rueckgabe:         d0 = 0    nicht gefunden
*                   sonst     d1.l = Wert des Cookies, a0 = Zeiger
*

getcookie:
 move.l   _p_cookies.w,d2          ; Zeiger auf die Cookies
 beq.b    search_ck_err            ; keine Cookies?
 movea.l  d2,a0
search_ck_loop:
 move.l   (a0)+,d2                 ; Cookie-ID
 beq.b    search_ck_err            ; Tabellenende
 move.l   (a0)+,d1                 ; Daten
 cmp.l    d0,d2                    ; gefunden?
 bne.b    search_ck_loop
 subq.l   #8,a0                    ; a0 = Zeiger auf gefundenen Cookie
 tst.l    d0
 rts
search_ck_err:
 moveq    #0,d0                    ; nix gefunden
 rts


**********************************************************************
*
* EQ/NE d0 = long putcookie( d0 = long key, d1 = long val )
*
* Rueckgabe:         d0 = 0    Cookie geaendert
*                   d0 = 1    Cookie installiert
*                   d0 = -1   Cookie Jar voll
*

putcookie:
 move.l   _p_cookies.w,d2          ; Zeiger auf die Cookies
 beq.b    pco_err                  ; keine Cookies?
 movea.l  d2,a0
pco_loop:
 move.l   (a0)+,d2                 ; Cookie-ID
 beq.b    pco_endloop              ; Tabellenende
 cmp.l    d0,d2                    ; gefunden?
 beq.b    pco_found
 addq.l   #4,a0                    ; Daten ueberspringen
 bra.b    pco_loop
pco_found:
 move.l   d1,(a0)                  ; Cookie geaendert
 moveq    #0,d0
 rts
pco_endloop:
 move.l   a0,d2
 addq.l   #4,d2                    ; Hinter den Leercookie
 sub.l    _p_cookies,d2            ; -Anfang der Cookies
 lsr.l    #3,d2                    ; 8 Bytes pro Cookie
 cmp.l    (a0),d2                  ; Platz im Cookie
 bcc.b    pco_err
 move.l   d0,-4(a0)                ; neuer Wert statt Null
 move.l   (a0),8(a0)
 move.l   d1,(a0)+
 clr.l    (a0)
 moveq    #1,d0
 rts
pco_err:
 moveq    #-1,d0
 rts


**********************************************************************
*
* long Bconmap( int devno )
*

Bconmap:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     (a0),-(sp)
 bsr.b      _Bconmap
 addq.l     #2,sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Bconmap:
 moveq    #0,d0
 move.w   4(sp),d1            ; d1 = devno
 move.w   bconmap_struct+6,d0 ; aktueller serieller Port
 cmp.w    #-1,d1              ; Nummer holen ?
 beq      _bmp_ende           ; ja, ende
 move.l   #bconmap_struct,d0
 cmp.w    #-2,d1              ; struct bconmap holen ?
 beq      _bmp_ende           ; ja, ende
 moveq    #0,d0               ; Rueckgabe: Fehler
 subq.w   #6,d1               ; Nummer um Offset 6 dekrementieren
 bmi      _bmp_ende           ; Wert war < 6, return(0)
 cmp.w    bconmap_struct+4,d1 ; Tabellenlaenge
 bcc      _bmp_ende           ; Wert war >= Tabellenlaenge, return(0)
 move.w   sr,-(sp)
 ori.w    #$700,sr            ; im TOS 2.05 vergessen!
* aktuellen Port in maptab retten (wozu, er kommt doch daher ?)
 move.w   bconmap_struct+6,d0 ; aktueller Port, diesen zurueckgeben
 move.w   d0,d1               ; aktueller Port

 subq.w   #6,d1               ; Offset abziehen
 asl.w    #3,d1
 move.w   d1,d2
 add.w    d1,d1
 add.w    d1,d2               ; * 24 (5 Funktionen, 1 Pointer)
 movea.l  bconmap_struct,a0   ; maptab (Tabelle mit je 6 Zeigern)
 adda.w   d2,a0

 move.l   dev_vecs+4,(a0)+    ; Bconstat(1)
 move.l   dev_vecs+$24,(a0)+  ; Bconin(1)
 move.l   dev_vecs+$44,(a0)+  ; Bcostat(a1)
 move.l   dev_vecs+$64,(a0)+  ; Bconout(1)
 move.l   p_rsconf,(a0)+      ; Rsconf fuer dev 1
 move.l   p_iorec,(a0)+       ; iorec  fuer dev 1
* neuen Port einsetzen
 move.w   4+2(sp),d1
 move.w   d1,bconmap_struct+6 ; umsetzen

 subq.w   #6,d1               ; Offset abziehen
 asl.w    #3,d1
 move.w   d1,d2
 add.w    d1,d1
 add.w    d1,d2               ; * 24 (5 Funktionen, 1 Pointer)
 movea.l  bconmap_struct,a0   ; maptab (Tabelle mit je 6 Zeigern)
 lea      intern_maptab,a1
 adda.w   d2,a0
 adda.w   d2,a1

 move.l   (a0)+,d1
 move.l   d1,dev_vecs+4       ; Bconstat(1)
 move.l   d1,Bconstatvec+4
 cmp.l    (a1)+,d1            ; MAG!XBIOS-Routine?
 beq.b    _bmp_conin
 clr.l    Bconstatvec+4       ; externe Routine

_bmp_conin:
 move.l  (a0)+,d1
 move.l  d1,dev_vecs+$24      ;Bconin(1)
 move.l  d1,Bconinvec+4
 cmp.l   (a1)+,d1             ;MAG!XBIOS-Routine?
 beq.b   _bmp_costat
 clr.l   Bconinvec+4          ;externe Routine

_bmp_costat:
 move.l  (a0)+,d1
 move.l  d1,dev_vecs+$44      ;Bcostat(1)
 move.l  d1,Bcostatvec+4
 cmp.l   (a1)+,d1             ;MAG!XBIOS-Routine?
 beq.b   _bmp_conout
 clr.l   Bcostatvec+4         ;externe Routine

_bmp_conout:
 move.l  (a0)+,d1
 move.l  d1,dev_vecs+$64      ;Bconout(1)
 move.l  d1,Bconoutvec+4
 cmp.l   (a1)+,d1             ;MAG!XBIOS-Routine?
 beq.b   _bmp_rsconf
 clr.l   Bconoutvec+4         ;externe Routine

_bmp_rsconf:
 move.l   (a0)+,p_rsconf
 move.l   (a0)+,p_iorec       ; iorec
 move.w   (sp)+,sr
_bmp_ende:
 rts


**********************************************************************
*
* void init_bconmap( void )
*
* Geraete:
*
*    ST:  Mega STE:  TT: Falcon:
* ------------------------------------------------------------------
*    6       6       6             ST-kompatibel seriell (Modem 1)    ser1
*            7       7     6/7     SCC Kanal B           (Modem 2)    sccb
*                    8             TTMFP                 (Serial 1)   ser2
*            8       9     8       SCC Kanal A           (Serial 2)   scca
*
* Der Milan unterstuetzt 5 serielle Schnittstellen.
* Hier ist eine Sicherheitsabfrage: Mehr als NSERIAL Schnittstellen
* werden ignoriert.
*

init_bconmap:
 lea      bconmap_struct,a0
 clr.w    4(a0)
;lea      dflt_maptable,a1
;move.l   a1,(a0)
 jsr      imaptab             ; erst initialisieren
 cmpi.w   #NSERIAL,bconmap_struct+4
 bls.b    inbcm_ok
 move.w   #NSERIAL,bconmap_struct+4     ; zuviele Schnittstellen!
inbcm_ok:
;lea      dflt_maptable,a0
 move.l   bconmap_struct,a0
 lea      intern_maptab,a1    ; dann eine Kopie anlegen
 moveq    #(NSERIAL*6)-1,d0
ins_internmap:                ;Maptab der Mag!X-eigenen Routinen erstellen
 move.l   (a0)+,(a1)+
 dbra     d0,ins_internmap

;lea      dflt_maptable,a0
 move.l   bconmap_struct,a0
 move.w   sr,-(sp)
 ori.w    #$700,sr            ;in Geraetevektoren eintragen...
 move.l   (a0)+,dev_vecs+4    ; Bconstat(1)
 move.l   (a0)+,dev_vecs+$24  ; Bconin(1)
 move.l   (a0)+,dev_vecs+$44  ; Bcostat(1)
 move.l   (a0)+,dev_vecs+$64  ; Bconout(1)
 move.l   (a0)+,p_rsconf
 move.l   (a0)+,p_iorec       ; iorec
 move.w   (sp)+,sr
 rts


**********************************************************************
*
* global void pling( void )
*
* Wird vom VDI (VT52) aufgerufen
*

pling:
 btst     #2,conterm               ; Glocke bei ^G ?
 beq.b    pling_ende               ; nein
 movea.l  bell_hook,a0
 jmp      (a0)
pling_ende:
 rts


**********************************************************************
*
* long Iorec( int dev )
*

Iorec:
 move.l   p_iorec,a1               ; fuer aux
 move.w   (a0),d1
 beq.b    iorec_ok                 ; 0
 lea      iorec_kb,a1
 subq.w   #1,d1
 beq.b    iorec_ok
 moveq    #14,d0
 bra      _go_milan
iorec_ok:
 move.l   a1,d0
 rte


**********************************************************************
*
* Initmous
*

Initmous:
 tst.w    (a0)                     ; Modus
 bne.b    initms_set
 move.l   #dummyfn,kbdvecs+$10     ; mousevec auf rts
 moveq    #0,d0
 bra.b    _go_milan
initms_set:
 move.l   6(a0),kbdvecs+$10        ; mousevec setzen
 moveq    #0,d0
 bra.b    _go_milan


**********************************************************************
*
* Routinen, die nur vom Milan-ROM erledigt werden
*

Physbase:
 moveq    #2,d0
 bra.b    _go_milan
Getrez:
 moveq    #4,d0
 bra.b    _go_milan
Setscreen:
 moveq    #5,d0
 bra.b    _go_milan
Setpalette:
 moveq    #6,d0
 bra.b    _go_milan
Setcolor:
 moveq    #7,d0
 bra.b    _go_milan
Floprd:
 moveq    #8,d0
 bra.b    _go_milan
Flopwr:
 moveq    #9,d0
 bra.b    _go_milan
Flopfmt:
 moveq    #10,d0
 bra.b    _go_milan
Midiws:
 moveq    #12,d0
 bra.b    _go_milan
Mfpint:
 moveq    #13,d0
 bra.b    _go_milan
Protobt:
 moveq    #18,d0
 bra.b    _go_milan
Flopver:
 moveq    #19,d0
 bra.b    _go_milan
Cursconf:
 moveq    #21,d0
 bra.b    _go_milan
Settime:
 moveq    #22,d0
 bra.b    _go_milan
Gettime:
 moveq    #23,d0
 bra.b    _go_milan
Ikbdws:
 moveq    #25,d0
 bra.b    _go_milan
Jdisint:
 moveq    #26,d0
 bra.b    _go_milan
Jenabint:
 moveq    #27,d0
 bra.b    _go_milan
Giaccess:
 moveq    #28,d0
 bra.b    _go_milan
Offgibit:
 moveq    #29,d0
 bra.b    _go_milan
Ongibit:
 moveq    #30,d0
 bra.b    _go_milan
Xbtimer:
 moveq    #31,d0
 bra.b    _go_milan
Dosound:
 moveq    #32,d0
 bra.b    _go_milan
Vsync:
 moveq    #37,d0
 bra.b    _go_milan
Floprate:
 moveq    #41,d0
 bra.b    _go_milan
DMAread:
 moveq    #42,d0
 bra.b    _go_milan
DMAwrite:
 moveq    #43,d0
 bra.b    _go_milan

 nop
_go_milan:
 add.l    d0,d0
 add.l    d0,d0
 move.l   milan,a2
 move.l   milh_xbios_fnx(a2),a2
 move.l   2(a2,d0.l),a2
 jmp      (a2)                     ; fuer MIDI und andere


**********************************************************************
*
* void Setprt( int config )
*

Setprt:
 move.w   pr_conf,d0
 tst.w    (a0)
 bmi.b    sprt_ende
 move.w   (a0),pr_conf
sprt_ende:
 rte

**********************************************************************
*
* long *Kbdvbase( void )
*

Kbdvbase:
 move.l   #kbdvecs,d0
 rte


**********************************************************************
*
* long Kbshift( void )
*

Kbshift:
 moveq    #0,d0
 move.b   kbshift,d0
 move.w   (a0),d1
 bmi.b    kbsh_ende
 move.b   d1,kbshift
kbsh_ende:
 rte


**********************************************************************
*
* int Kbrate( int delay, int repeat )
*

Kbrate:
 lea      key_delay,a1
 move.w   (a1),d0                  ; altes delay/repeat
 move.w   (a0)+,d1                 ; neues delay
 bmi.b    kbr_ende                 ; ist -1, keine Aenderung
 move.b   d1,(a1)+                 ; neues delay setzen
 move.w   (a0),d1                  ; neues repeat
 bmi.b    kbr_ende                 ; ist -1, keine Aenderung
 move.b   d1,(a1)                  ; neues repeat setzen
kbr_ende:
 rte


**********************************************************************
*
* char **Keytbl( char *unshift, char *shift, char *caps )
*

Keytbl:
 lea      keytblx,a1               ; Zeiger auf KEYTAB-Struktur
 move.l   a1,d0                    ; Rueckgabewert
 moveq    #3-1,d2                  ; Zaehler fuer 3 Durchlaeufe
ktbl_loop:
 move.l   (a0)+,d1
 bmi.b    ktbl_noset
 move.l   d1,(a1)
ktbl_noset:
 addq.l   #4,a1
 dbra     d2,ktbl_loop
 rte

**********************************************************************
*
* EQ/NE char altcode_asc( char c )
*
* Wandelt einen Scan-/Ascii- Code einer ALT-Buchstabenkombination um
* in ein ASCII-Zeichen (in Grossbuchstaben).
* Bsp.: Code $1e00 (Alt-A) ==> 'A'
*            $7800 (Alt-1) ==> '1'
*

altcode_asc:
 tst.b    d0
 bne      ala_nix                  ; hat ASCII-Code, also kein ALT
 lsr.w    #8,d0                    ; Scancode ins Loword
 cmpi.w   #$78,d0
 bcs.b    ala_nonum
* Sonderbehandlung fuer Alt-1 bis Alt-apostrophe
 cmpi.w   #$83,d0
 bhi.b    ala_nix
 subi.w   #$76,d0                  ; Umrechnung
ala_nonum:
 move.l   keytblx+8,a0
 move.b   0(a0,d0.w),d0            ; ASCII-Code holen
 rts
ala_nix:
 moveq    #0,d0
 rts


**********************************************************************
*
* long (!) Bioskeys( void )
*
* Setzt 6 statt 3 Tabellen. Fuer die MF- Tastatur werden fuer die ersten
* drei Tabellen andere genommen.
* Der AltGr- Status liegt immer hinter den 6 Tabellenzeigern.
* Gibt Adressen der Tastaturbehandlungsroutine zurueck.
*
Bioskeys:
 bsr.b   _Bioskeys
 rte

_Bioskeys:
 move.l   default_keytblxp,a1      ; Tabelle der 9 Default-Zeiger
 lea      keytblx,a0               ; aktive Zeiger
 moveq    #9-1,d0                  ; Zaehler
_bioskeys_loop:
 move.l   (a1)+,(a0)+
 dbra     d0,_bioskeys_loop
 lea      keybd_struct(pc),a0
 move.l   a0,d0
 rts

keybd_struct:
 DC.L     keytblx                  ; Adresse der 6 Tabellen
 DC.L     kbshift                  ; Adresse des Shiftstatus
 DC.L     altgr_status             ; Adresse des AltGr- Status
 DC.L     handle_key               ; Adresse der Tastaturroutine
 DC.L     keyrepeat                ; Adresse der Wiederholungsdaten


**********************************************************************
*
* void int_vbl( void )
*
* Bearbeitet den VBL- Interrupt
* TOS 3.06 bearbeitet zunaechst die VBL-Queue
*

int_vbl:
 addq.l   #1,_frclock              ; Anzahl aller VBLs mitzaehlen
 subq.w   #1,vblsem                ; VBL gesperrt ?
 bmi      ivbl_locked              ; ja, ende
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
 addq.l   #1,_vbclock              ; Anzahl aller VBL-Routinen mitzaehlen

 move.l   milan,a2
 move.l   milh_vblhook(a2),a2
 jsr      (a2)

 move.w   nvbls,d7
 beq.b    ivbl_noq
 subq.w   #1,d7
 movea.l  _vblqueue,a0
ivbl_qloop:
 move.l   (a0)+,d0
 beq.b    ivbl_nxtq
 move.l   d0,a1
 move.l   a0,-(sp)
 move.w   d7,-(sp)
 jsr      (a1)
 move.w   (sp)+,d7
 movea.l  (sp)+,a0
ivbl_nxtq:
 dbf      d7,ivbl_qloop
ivbl_noq:
 tst.w    _dumpflg
 bne.b    ivbl_nodmp
 bsr      _Scrdmp
ivbl_nodmp:
 movem.l  (sp)+,a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0
ivbl_locked:
 addq.w   #1,vblsem
only_rte:
 rte


**********************************************************************
*
* int_hz_200 (Atari: int_mfp5)
*

int_hz200:
 addq.l   #1,_hz_200
 rol.w    flg_50hz
 bpl.b    i200_yield               ; nur jeden vierten Interrupt (50Hz)
 movem.l  d0-d7/a0-a6,-(sp)
 move.l   milan,a2
 move.l   milh_dosound(a2),a2
 jsr      (a2)                     ; Sound verarbeiten
 eori.w   #$300,sr                 ; von IPL 6 auf 5 schalten
 btst     #1,conterm               ; Tastenwiederh. eingeschaltet ?
 beq.b    i200_nokey               ; nein
 lea      keyrepeat,a0
 move.b   (a0)+,d0                 ; Scancode, Taste gedrueckt ?
 beq.b    i200_nokey               ; nein
 subq.b   #1,(a0)                  ; Zaehler fuer Verzoegerung dekrementieren
 bne.b    i200_nokey               ; ist nicht 0
 move.b   key_reprate,(a0)         ; Zaehler neu laden
 lea      iorec_kb,a0              ; Taste <d0> in Tastaturpuffer ...
 bsr      keyrep_entry             ; ... eintragen
i200_nokey:
 move.w   _timer_ms,-(sp)
 movea.l  etv_timer,a0
 jsr      (a0)                     ; Userinterruptroutinen ausfuehren
 addq.w   #2,sp
 movem.l  (sp)+,d0-d7/a0-a6
i200_yield:
* Interrupt bestaetigen
 move.l   a2,-(sp)
 move.l   milan,a2
 move.l   milh_exit_hz200(a2),a2
 jsr      (a2)
 move.l   (sp)+,a2
/*
 ATARI:
 bclr     #5,isrb                  ; (Timer C) Interrupt-Service-Bit loeschen
;move.b   #$df,isrb           ; TOS 2.05
*/
 tst.w    pe_slice
 bmi.b    nix_hz
 subq.w   #1,pe_timer
 bgt.b    nix_hz
 clr.w    pe_timer                 ; ist abgelaufen
 btst     #5,(sp)
 bne      nix_hz                   ; aus Supervisormode nicht abfangen
 andi.w   #$f3ff,sr                ; INT=3
 jsr      appl_suspend
nix_hz:
 rte


**********************************************************************
*
* "Interrupt" fuer MIDI und Keyboard (MFP- Interrupt 6).
*
* Der Interrupt wird hier nur simuliert, und zwar folgendermassen:
*
*         (sp) = 'Miln':      Daten sind gueltig
* dann:   4(sp) = 0:          MIDI
*         4(sp) = 1:          Tastatur
*                                  5(sp) = Atari-Scancode
*         4(sp) = 2:          Mauspaket
*                                  5(sp),6(sp),7(sp) = char data[3]
*

int_ikbd:
 movem.l  d0/d1/d2/d3/a0/a1/a2/a3,-(sp)
 movea.l  kbdvecs+$1c,a2           ; midisys
 jsr      (a2)
 move.l   32(sp),d0                ; LONG magic 'Miln'
;    DEBL d0,'IKBD: (sp)='
 lea      32+4(sp),a0              ; Parameter
;    DEBL (a0),'IKBD: 4(sp)='
 movea.l  kbdvecs+$20,a2           ; ikbdsys
 jsr      (a2)
; Interrupt quittieren
 move.l   milan,a2
 move.l   milh_exit_ikbd(a2),a2
 jsr      (a2)
 movem.l  (sp)+,a3/a2/a1/a0/d3/d2/d1/d0
 cmpi.l   #'Miln',(sp)
 bne.b    mik_getuerkt
 addq.l   #8,sp                    ; Parameter abbauen
mik_getuerkt:
 tst.w    pe_slice
 bmi.b    mik_no_yield
 btst     #5,(sp)
 bne      mik_no_yield             ; aus Supervisormode nicht abfangen
 andi.w   #$f3ff,sr                ; INT=3
 jsr      appl_yield
mik_no_yield:
 rte


;------------------------------------------------------------
;
; "midisys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
;

midisys:
 rts


;------------------------------------------------------------
;
; "ikbdsys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
;

ikbdsys:
 cmpi.l   #'Miln',d0
 bne.b    iks_err
 move.b   (a0)+,d0
 subq.b   #1,d0
 beq.b    iks_key
 subq.b   #1,d0
 bne.b    iks_err
 move.l   a0,-(sp)                 ; Mauspaket
;    DEBL -1(a0),'Mausdaten'
 movea.l  kbdvecs+$10,a2           ; mousevec
 jsr      (a2)
 addq.l   #4,sp
 rts
iks_key:
 move.b   (a0),d0                  ; Zeichen
     DEBL d0,'Taste '
 lea      iorec_kb,a0              ; Tastatur-IOREC
 move.l   kbdvecs-4,a1             ; i.a. handle_key
 jmp      (a1)
iks_err:
 rts


;---------------------------------------------------------------------
;
; void handle_key( d0 = char scancode, a0 = IOREC *buffer )
;
; Wird von arcvint aufgerufen
; Darf d0-d3/a0-a3 benutzen
;
handle_key:
;   eori.w   #$300,sr          ;von IPL 6 auf 5 setzen
   bsr.b    _handlekey
;   eori.w   #$300,sr          ;von IPL 5 auf 6 zurueck
   rts

     INCLUDE "handlkey.s"


Logbase:
 move.l   _v_bas_ad,d0
 rte


; Stop the CPU until an interrupt occurs.
; This may save some host CPU time on emulators (i.e. ARAnyM).
mmx_yield:
  move.w sr,d0
  stop    #0x2300
  move.w d0,sr
  rts

**********************************************************************
*
* Emulation des 68000- Befehls "move sr,ea" auf dem 680x0
*
**********************************************************************

ipriv:
          movem.l a0/a1/d0,-(sp)
          movea.l 14(sp),a0
          move.w  (a0),d0
          subi.w  #$40c0,d0
          bcs.b   nosrea
          cmpi.w  #$3a,d0
          bcc.b   nosrea
          andi.w  #$38,d0
          lsr.w   #2,d0
          move.w  srea3(pc,d0.w),d0
          jmp     srea3(pc,d0.w)
nosrea:   movem.l (sp)+,a0/a1/d0
          pea     exc_vector(pc)             ; 8 Bomben: Priv.Viol.
;         move.l  Mac_old_priv,-(sp)
          rts

srea3:    DC.W    eaddd-srea3
          DC.W    nosrea-srea3
          DC.W    eaan-srea3
          DC.W    eaanp-srea3
          DC.W    ea_an-srea3
          DC.W    ead16-srea3
          DC.W    ead08-srea3
          DC.W    eaadr-srea3

eaddd:    moveq   #7,d0
          and.w   (a0),d0
          lsl.w   #2,d0
          lea     eaddd1(pc,d0.w),a0
          move.l  (sp)+,d0
          movea.w 8(sp),a1
          jmp     (a0)
eaddd1:   move.w  a1,d0
          bra.b   eaddd2
          move.w  a1,d1
          bra.b   eaddd2
          move.w  a1,d2
          bra.b   eaddd2
          move.w  a1,d3
          bra.b   eaddd2
          move.w  a1,d4
          bra.b   eaddd2
          move.w  a1,d5
          bra.b   eaddd2
          move.w  a1,d6
          bra.b   eaddd2
          move.w  a1,d7
eaddd2:   movea.l (sp)+,a0
          movea.l (sp)+,a1
          addq.l  #2,2(sp)
          rte
eaadr:    cmpi.w  #$40f8,(a0)+
          bne.b   eaadr1
          movea.w (a0),a0
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
eaadr1:   movea.l (a0),a0
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #6,2(sp)
          rte
eaan:     bsr.b   srea2
          move.w  12(sp),(a0)
          movem.l (sp)+,a0/a1/d0
          addq.l  #2,2(sp)
          rte
ea_an:    bsr.b   srea2
          move.w  12(sp),-(a0)
          bra.b   retan
eaanp:    bsr.b   srea2
          move.w  12(sp),(a0)+
retan:    pea     retan1(pc,d0.w)
          move.l  a0,d0
          movem.l 8(sp),a0/a1
          rts
retan1:   movea.l d0,a0
          bra.b   retan2
          movea.l d0,a1
          bra.b   retan2
          movea.l d0,a2
          bra.b   retan2
          movea.l d0,a3
          bra.b   retan2
          movea.l d0,a4
          bra.b   retan2
          movea.l d0,a5
          bra.b   retan2
          movea.l d0,a6
          bra.b   retan2
          movea.l d0,a0
          move    a0,usp
          movea.l 4(sp),a0
retan2:   move.l  (sp)+,d0
          addq.l  #8,sp
          addq.l  #2,2(sp)
          rte
srea2:    moveq   #7,d0
          and.w   (a0),d0
          lsl.w   #2,d0
          movea.l 8(sp),a0
          jmp     srea1(pc,d0.w)
srea1:    rts

          DC.W    $ffff

          movea.l a1,a0
          rts
          movea.l a2,a0
          rts

          movea.l a3,a0
          rts
          movea.l a4,a0
          rts
          movea.l a5,a0
          rts
          movea.l a6,a0
          rts
          move    usp,a0
          rts
ead16:    bsr.b  srea2
          movea.l 14(sp),a1
          move.l  (a1),d0
          move.w  12(sp),(a0,d0.w)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
ead08:    bsr.b  srea2
          movea.l 14(sp),a1
          addq.l  #2,a1
          move.w  (a1),d0
          ext.w   d0
          pea     0(a0,d0.w)
          move.b  (a1),d0
          move.w  d0,-(sp)
          andi.w  #$f0,d0
          lsr.w   #2,d0
          bclr    #5,d0
          bne.b   ead08a1
          lea     ead08d1(pc,d0.w),a0
          move.l  6(sp),d0
          jmp     (a0)
ead08a1:  movem.l 10(sp),a0/a1
          jsr     srea1(pc,d0.w)
ead081:   moveq   #8,d0
          and.w   (sp)+,d0
          movea.l (sp)+,a1
          bne.b   ead082
          movea.w a0,a0
ead082:   move.w  12(sp),(a1,a0.L)
          movem.l (sp)+,a0/a1/d0
          addq.l  #4,2(sp)
          rte
ead08d1:  movea.l d0,a0
          bra.b   ead081
          movea.l d1,a0
          bra.b   ead081
          movea.l d2,a0
          bra.b   ead081
          movea.l d3,a0
          bra.b   ead081
          movea.l d4,a0
          bra.b   ead081
          movea.l d5,a0
          bra.b   ead081
          movea.l d6,a0
          bra.b   ead081
          movea.l d7,a0
          bra.b   ead081

 INCLUDE "keytab.inc"


ori_iorec_kb:
 DC.L     iorec_kb_buf             ; Pufferadresse
 DC.W     $0100                    ; Groesse 256 Bytes = 64 Langworte
 DC.W     0                        ; Head Index
 DC.W     0                        ; Tail Index
 DC.W     $40                      ; Low water mark
 DC.W     $c0                      ; High water mark

 INCLUDE "biosmsg.inc"
 
     END
