* BIOS fuer MagiX MAC
* *******************

*
* Dieses Modul enthaelt die Atari-seitige Nachbildung des BIOS
*
* Auf der MAC- Seite passiert vorher folgendes:
*
* - PMMU, vbr und Prozessorcaches werden initialisiert.
* - phystop, _v_bas_ad, _memtop werden initialisiert.
* - Exceptionvektoren werden initialisiert, ausser priv.viol. und div0
* - hdv_xxx werden initialisiert.
* - Farbpalette wird gesetzt (ggf. bei Initialisierung des VDI ?)
* - sshiftmd auf einen halbwegs sinnvollen Wert gesetzt
* - end_os und exec_os im Variablenheader des BIOS und des AES aendern
*   (macht z.Zt. das MAGXBOOT, ggf. noch elegantere Methode suchen)
* - cpu_typ ($59e) initialisieren auf 40(dez) fuer 68040 bzw. 30(dez)
*   fuer 68030
* - Alle Eintraege der Uebergabestruktur fuellen
*   Die Routinen fuer Drucker und AUX bekommen ihre Parameter immer ueber
*   Register a0, das zeigt auf die Parameter auf dem Stack. Es duerfen keine
*   Register ausser d0-d2 und a0-a2 veraendert werden.
* - 200Hz- Interrupt einfuettern ($114)
* - VBL einfuettern ($70)
* - In $f0 (Atari->MAC) und $f4 (MAC->Atari) Vektoren fuer die Umschaltung
*   einsetzen.
*   Die Vektoren muessen alle Register retten.
* - Tastendruecke und Mausdaten in den MFP-Interrupt 6 einfuettern
*   (Vektor bei $118):
*    d7 = 'MAGC': Daten sind gueltig
*
*    dann:   d6 = 0:   MIDI
*            d6 = 1:   Tastatur
*              d5 = Atari-Scancode
*            d6 = 2:   Mauspaket
*              a6 = char data[3]
*
* Der "Atari" macht folgendes:
*
* - FPU wird auf NULL initialisiert.
* - keine Cartridges
* - kein Booten von Floppy oder DMA
* - colorptr und screenpt werden ignoriert, Umschalten der Farbpalette
*   ausschliesslich ueber VDI
* - Physbase und Logbase liefern _v_bas_ad
* - Getrez liefert sshiftmd
* - Setscreen springt fuer Aenderungen der physikalischen Adresse MacSys_set_physbase an
* - Die Einspruenge in den MAC im XFS erfolgen nach Aufruf von [$f0], vor
*   Fortfuehrung des Atari wird [$f4] aufgerufen. Im MAC-Modus wird das
*   MAC-Register a5 geladen und anschliessend restauriert.
* - im 200hz-Interrupt alle 2s die DOS-Uhrzeit vom MAC holen
*


FALCON    EQU  1
MACINTOSH EQU  1
MACOSX    EQU  0
MILANCOMP EQU  0
DEBUG     EQU  0
DEBUG3    EQU  0

ALTGR          EQU  $4c
ALT_NUMKEY     EQU  1
COMMAND        EQU  $37            ; "Apple"-Taste fuer Calamus-Unterstuetzung
DEADKEYS       EQU  0
N_KEYTBL       EQU  9             ; 9 Tastaturtabellen

; 0x37 ist Scancode fuer Command (Apple)
; 0x49 ist Scancode fuer PgUp
; 0x51 ist Scancode fuer PgDn
; 0x4c ist Scancode fuer AltGr
; 0x4f ist Scancode fuer Ende

     XDEF      _start
     XDEF      MSys
     XDEF      getcookie
     XDEF      drv2devcode         ; BIOS-Device => devcode (32 Bit)
     XDEF      bios2devcode        ; BIOS-Device => devcode (32 Bit)
     XDEF      bios_rawdrvr        ; raw-Driver aus dem BIOS
     XDEF      chk_rtclock
     XDEF      read_rtclock
     XDEF      pling               ; nach VDI
     XDEF      kbshift             ; nach VDI,XAES
     XDEF      altcode_asc         ; nach XAES
     XDEF      iorec_kb            ; nach DOS,XAES
     XDEF      ctrl_status         ; nach DOS
     XDEF      is_fpu              ; nach XAES
     XDEF      halt_system         ; nach DOS,AES
     XDEF      p_mgxinf            ; nach XAES
     XDEF      machine_type        ; nach VDI,DOS
     XDEF      config_status       ; nach DOS und AES
     XDEF      pe_slice            ; nach XAES
     XDEF      pe_timer            ; nach XAES
     XDEF      first_sem           ; nach XAES
     XDEF      app0                ; nach AES
     XDEF      sust_len            ; nach AES
     XDEF      datemode            ; nach STD
     XDEF      Bmalloc             ; nach DOS
     EXPORT    Bmaddalt            ; nach DOS (ab 25.9.96)
     XDEF      dos_macfn           ; nach DOS

     XDEF      p_vt52              ; neues VT52 nach DOS
     XDEF      warm_boot           ; nach AES
     XDEF      warmbvec,coldbvec   ; nach AES
     XDEF      prn_wrts            ; -> DEV_BIOS
     XDEF      Mac_xfsx            ; -> MACXFS
     IFNE FALCON
     XDEF      scrbuf_adr,scrbuf_len    ; nach DOS
     ENDIF
	 XDEF MSys_BehneError

* Import aus STD

     XREF      putch,putstr
     IMPORT    date2str            ; void date2str( a0 = char *s, d0 = WORD date)

* Import aus READ_INF

     XREF      read_inf            ; char *read_inf( void );
     IMPORT    rinf_vfat           ; void rinf_vfa( a0 = char *inf );
     IMPORT    rinf_img            ; void rinf_img( a0 = char *inf );
     IMPORT    rinf_log            ; long rinf_log( a0 = char *inf );
     IMPORT    rinf_coo
     IMPORT    rinf_bdev
     IMPORT    rinf_dvh

* Import von MATH

     XREF      _lmul

* Import vom DOS

     XREF      dos_init            ; DOS
     XREF      secb_ext            ; DOS
     XREF      iniddev1
     XREF      iniddev2
     XREF      deleddev

* Import vom AES

     XREF      appl_yield          ; XAES
     XREF      appl_suspend        ; XAES
     XREF      appl_IOcomplete     ; XAES
     XREF      evnt_IO             ; XAES
     XREF      evnt_sem            ; XAES
     XREF      act_appl            ; XAES
     XREF      endofvars           ; AES: Ende aller Variablen
     XREF      _ende               ; AES: Ende des Betriebssystems
     XREF      gem_magics          ; AES: Parameterblock

* Import von AESOBJ

     XREF      v_clswk             ; fuer Shutdown

* Import vom MACXFS

     XREF      mxfs_init

* Import vom VDI

     XREF      vdi_conout          ; VDI: Bconout(CON)
     XREF      vdi_rawout          ; VDI: Bconout(RAWCON)
     XREF      vdi_cursor          ; VDI: Cursorblinken
     XREF      int_linea           ; VDI: LineA- Interrupt
     XREF      Blitmode            ; VDI
     XREF      vt_seq_e            ; VDI: Cursor ein
     XREF      vt_seq_f            ; VDI: Cursor aus
     XREF      vdi_init            ; VDI: initialisieren (fuer MXVDI)
     XREF      vdi_blinit          ; VDI: Blitterstatus initialisieren (d0)
     XREF      vt52_init           ; VDI: VT52 initialisieren


     INCLUDE "lowmem.inc"
	 include "country.inc"
     INCLUDE "bios.inc"
     INCLUDE "dos.inc"
     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "mac_ker.inc"
     INCLUDE "debug.inc"
	 INCLUDE "..\dos\magicdos.inc"


D_DAY     EQU  9
D_MONTH   EQU  1
D_YEAR    EQU  2000
D_BCD     EQU  $01092000

NCOOKIES  EQU  21

	XDEF act_pd
	

     TEXT


;--------------------------------------------------------------
;
; BIOS- Variablen:

clear_area          EQU $9a4            /* war vorher auf $98c        */

     OFFSET clear_area

p_iorec_ser1:       DS.L 1              /* IOREC *p_iorec_ser1        */
; IOREC:            DS.B $e             /*   0: IOREC fuer Eingabe     */
;                   DS.B $e             /*  $e: IOREC fuer Ausgabe     */
;                   DS.B 1              /* $1c: aux_status_rcv        */
;                   DS.B 1              /* $1d: aux_status_tmt        */
;                   DS.B 1              /* $1e: aux_lock_rcv          */
;                   DS.B 1              /* $1f: aux_lock_tmt          */
;                   DS.B 1              /* $20: aux_handshake         */
;                   DS.B 1              /* $21: aux_x_buf             */
;                   DS.B 1              /* $22: baudrate              */
;                   DS.B 1              /* $23: bitchr                */
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
sound_data:         DS.L 1              /* long                       */
sound_delay:        DS.B 1              /* char                       */
sound_byte:         DS.B 1              /* char                       */
last_random:        DS.L 1              /* long                       */

machine_type:       DS.B 1              /* char machine_type          */
                                        /* 0=ST 1=STE 2=Mega-STE 3=TT */
                                        /* 4=Falcon                   */
                                        /* 0=MAC (wie ST)             */
is_fpu:             DS.B 1              /* LineF- FPU existiert       */
     EVEN
stack_offset:       DS.W 1              /* 6:68000, 8: 68010 ff       */
config_status:      DS.L 1
                    DS.L 1              /* 04: hier -> DOSVARS            */
                    DS.L 1              /* 08: hier -> AESVARS            */
                    DS.L 1              /* 12: hier -> vdi_tidy           */
                    DS.L 1              /* 16: -> hddriver_functions      */
status_bits:        DS.L 1              /* 20: Bit 0: APP-Manager ist aktiv */
pkill_vector:       DS.L 1              /* 24: VERKETTEN: z.B. fuer DSP     */

cookies:            DS.L NCOOKIES*2     /* long cookies[17][2]        */
bconmap_struct:     DS.L 1              /* long *maptab               */
                    DS.W 1              /* int  maptabsize            */
                    DS.W 1              /* aktueller serieller Port (>= 6) */
p_rsconf:           DS.L 1              /* Pointer auf Rsconf (device 1)   */
p_iorec:            DS.L 1              /* Pointer auf iorec (device 1)    */
ttram_md:           DS.L 4              /* MD fuer TTRAM-Block              */
     IFNE FALCON
scrbuf_adr:         DS.L 1              /* Startadresse (netto, ohne MCB)  */
scrbuf_len:         DS.L 1              /* tatsaechliche Laenge              */
     ENDIF
pe_slice:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
pe_timer:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
first_sem:
dummy_sem:          DS.B bl_sizeof      /* Dummy- Semaphore                */
app0:               DS.L 1              /* APP #0 und Default- Superstack  */
pgm_superst:        DS.L 1              /* Default- Superstack             */
p_mgxinf:
pgm_userst:         DS.L 1
dflt_maptable:      DS.L 4*6            /* fuer 4 Eintraege a 24 Bytes       */
intern_maptab:      DS.L 4*6           ;interne MapTab. Enthaelt die Adressen
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
do_gettime:         DS.W 1
Mac_old_priv:       DS.L 1              ; alter Priv.viol.vektor (MAC)
Mac_xfsx:           DS.L 1              /* ->Tabelle mit XFS-Daten         */
warmbvec:           DS.L 1              /* Sprungadr. fuer Ctrl-Alt-Del     */
coldbvec:           DS.L 1              /* Sprungadr. fuer Ctrl-Alt-Rsh-Del */
sust_len:           DS.L 1              /* Supervisorstack pro Applikation */
datemode:           DS.W 1         ;fuer date2str (->STD.S)
log_fd:             DS.L 1              /* DateiHandle fuer Bootlog */
log_fd_pd:          DS.L 1              /* Prozessdeskriptor fuer Handle */
log_oldconout:      DS.L 1              /* Alter Vektor fuer Bootlog */
p_vt52:             DS.L 1              /* fuer VT52.PRG */
__e_bios:


        TEXT

        MC68030
        MC68881
        SUPER

MSys:
 DC.L     'MagC'
 DC.L     syshdr              ; Adresse des Atari-Syshdr
 DC.L     tab_unshift         ; 5*128 Bytes fuer Tastaturtabellen
 DC.L     0                   ; Version
 DC.W     0                   ; CPU (30=68030, 40=68040)
 DC.W     0                   ; FPU-Typ
 DC.L     0                   ; MacSys_boot_sp
 DC.L     0                   ; MacSys_biosinit
 DC.L     0                   ; MacSys_pixmap
 DC.L     0                   ; MacSys_offs_32k
 DC.L     0                   ; MacSys_a5
 DC.L     0                   ; MacSys_tasksw
 DC.L     0                   ; MacSys_gettime
 DC.L     print_bombs10       ; MacSys_bombs
 DC.L     0                   ; MacSys_syshalt
 DC.L     0                   ; MacSys_coldboot
 DC.L     0                   ; MacSys_debugout
 DC.L     0                   ; prt_cis      Fuer Drucker (Atari -> MAC)
 DC.L     0                   ; prt_cos
 DC.L     0                   ; prt_cin
 DC.L     0                   ; prt_cout
 DC.L     0                   ; ser_rsconf
 DC.L     0                   ; ser_cis      FUer ser1 (Atari -> MAC)
 DC.L     0                   ; ser_cos
 DC.L     0                   ; ser_cin
 DC.L     0                   ; ser_cout
 DC.L     0                   ; MacSys_xfs
 DC.L     0                   ; MacSys_xfs_dev
 DC.L     0                   ; MacSys_set_physbase
 DC.L     0                   ; MacSys_VsetRGB
 DC.L     0                   ; MacSys_VgetRGB
MSys_BehneError:
 DC.L     0                   ; MacSys_error
 DC.L     0                   ; MacSys_init
 DC.L     0                   ; MacSys_drv2devcode
 DC.L     0                   ; MacSys_rawdrvr
 DC.L     0                   ; MacSys_floprd
 DC.L     0                   ; MacSys_flopwr
 DC.L     0                   ; MacSys_flopfmt
 DC.L     0                   ; MacSys_flopver
 DC.L     SUPERSTACKLEN       ; MacSys_superstlen
 DC.L     0                   ; MacSys_dos_macfn
 DC.L     0                   ; MacSys_settime
 DC.L     0                   ; MacSys_prn_wrts
 DC.L     0                   ; MagiC 6: Versionsnummer, von Mac gesetzt
 DC.L     0                   ; in_interrupt
 DC.L     0                   ; MacSys_drv_fsspec
 DC.L     0                   ; MacSys_cnverr
 DC.L     0                   ; res1
 DC.L     0                   ; res2
 DC.L     0                   ; res3

_start:
; nur fuer PASM
;COUNTRY equ 1
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
 DC.W     D_DAY+(D_MONTH<<5)+((D_YEAR-1980)<<9) ; Datum im GEMDOS- Format
 DC.L     _mifl_unused        ; _root
 DC.L     kbshift
 DC.L     act_pd              ; _run
 DC.L     0


sys_start:
 move.l   MSys+MacSys_version(pc),d0    ; Versionsnummer von MagicMac
 subq.l   #2,d0
 beq.b    bot_ver_ok
 illegal                           ; was sonst ?
bot_ver_ok:
 move     #$2700,sr

 move.l   MSys+MacSys_boot_sp(pc),sp
 move.l   MSys+MacSys_init(pc),d0
 beq.b    bot_oldmac               ; init-Routine ungueltig (alter Emu)
 move.l   d0,a0
 jsr      (a0)
bot_oldmac:
 move.w   MSys+MacSys_fpu(pc),d0
 beq.b    bot_ok1                  ; keine FPU
 frestore long_zero                ; fuer 68882

bot_ok1:
* BIOS- Variablenbereich loeschen
 lea      clear_area,a0
 lea      __e_dos,a1
 moveq    #0,d0
bot_vclear:
 move.l   d0,(a0)+
 move.l   d0,(a0)+
 move.l   d0,(a0)+
 move.l   d0,(a0)+
 cmpa.l   a0,a1
 bhi.b    bot_vclear

 clr.l    p_vt52_winlst            ; damit DOS nicht verwirrt wird
 lea      config_status,a0         ; config-Status-Block loeschen
 moveq    #7-1,d0
ccfl_loop:
 clr.l    (a0)+
 dbra     d0,ccfl_loop

* CPU, Cookies und machine_type

 move.w   #6,stack_offset
 move.w   MSys+MacSys_cpu(pc),cpu_typ
 beq.b    inst_cook
 move.w   #8,stack_offset
inst_cook:
 bsr      install_cookies

 clr.l    scrbuf_adr                    ; TOS 4.xx
 clr.l    scrbuf_len

* Beginn der TPA setzen (je nachdem, ob GEM enthalten ist)

 movea.l  syshdr+os_magic(pc),a0        ; Zeiger auf GEM- Parameterblock
 cmpi.l   #$87654321,(a0)+              ; gueltig ?
 beq.b    bot_aestpa                    ; ja
 lea      syshdr+os_membot(pc),a0       ; TPA- Daten ohne AES
bot_aestpa:
 move.l   (a0)+,end_os
 move.l   (a0),exec_os

* Installation einiger Exceptionvektoren fuer Disk und Ausgabe

 move.l   #bcostat_prt,prv_lsto
 move.l   #bconout_prt,prv_lst
 move.l   #bcostat_ser1,prv_auxo   ; immer ST_MFP
 move.l   #bconout_ser1,prv_aux
 move.l   #do_hardcopy,scr_dump    ; MagiC 3.0: Dummy-Routine
 move.l   #do_hardcopy,prtblk_vec  ; MagiC 3.0: Dummy-Routine

* Initialisierung einiger Systemvariablen

 move.l   end_os,_membot
 move.w   #8,nvbls
 st       _fverify
 move.w   #3,seekrate
 move.w   #-1,_dumpflg
 move.w   #-1,pe_slice             ; Zeitscheibensteuerung abschalten
 clr.l    act_appl                 ; single task

 move.l   #'_DMY',dummy_sem+bl_name  ; Dummy- Semaphore initialisieren
 clr.l    config_status+16         ; kein paralleler Plattentransfer

;move.l   #syshdr,_sysbase
 move.l   #savptr_area,savptr
 move.l   #dummyfn,swv_vec
 clr.l    _drvbits
 clr.l    _shell_p                 ; !!! wird jetzt geloescht
 move.l   #hdl_pling,bell_hook     ; Ton fuer ^G
 move.l   #hdl_klick,kcl_hook      ; Tastenklickroutine
 move.l   #warm_boot,warmbvec      ; Sprungvektor fuer Ctrl-Alt-Del
 move.l   #cold_boot,coldbvec      ; Sprungvektor fuer Ctrl-Alt-Rshift-Del

* RAM- syshdr erstellen (wozu ?)

 bsr      create_ram_syshdr

* Exception- Vektoren nur noch div0 und priv.viol.

 lea      only_rte(pc),a3
 move.l   a3,$14                   ; Division durch 0
 lea      my_priv_exception(pc),a2 ; Privilege violation: move sr,xx emulieren
 move.l   $20,Mac_old_priv         ; alten Vektor retten
 move.l   a2,$20                   ; Privilege violation


 move.l   #BiosDisp,$b4            ;BIOS
 move.l   #XBiosDisp,$b8           ;XBIOS
 move.l   #int_vbl,$70             ; VBL
 move.l   #int_hbl,$68             ; HBL
 move.l    a3,$88
 move.l   #int_linea,$28

* etv_timer und etv_term auf RTS, VBL- Queue loeschen

 lea      dummyfn(pc),a4
 move.l   a4,etv_timer
;move.l   #bios_critic,etv_critic  ; wird vom DOS erledigt
 move.l   a4,etv_term
 lea      _vbl_list,a0
 move.l   a0,_vblqueue
 moveq    #7,d0
bot_loop3:
 clr.l    (a0)+
 dbf      d0,bot_loop3

* Devicevektoren initialisieren

 lea      ori_dev_vecs(pc),a0      ; ROM-Geraetevektoren
 lea      dev_vecs,a1
 lea      mbiosvecs,a2
 moveq    #$1f,d0
bot_loop4:
 move.l   (a0),(a1)+
 move.l   (a0)+,(a2)+
 dbf      d0,bot_loop4

* MFP und Vektoren initialisieren ( bsr init_mfp )

 move.w   #$1111,flg_50hz          ; jedes vierte Bit gesetzt
 move.w   #20,_timer_ms            ; 50Hz
 lea      int_hz_200(pc),a2        ; der 200Hz- Zaehler ...
 moveq    #5,d0                    ; ... wird MFP- Interrupt 5
 bsr      _mfpint
 moveq    #0,d0                    ; MFP, nicht SCC
 bsr      init_aux_iorec
 move.l   a0,p_iorec_ser1
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

 lea      midikey_int(pc),a2
 moveq    #6,d0
 bsr      _mfpint

 bsr      init_bconmap

 move.b   #7,conterm
 moveq    #0,d0
 move.l   d0,sound_data
 move.b   d0,sound_delay
 move.b   d0,sound_byte

 move.l   syshdr+os_magic(pc),a0
 move.w   -8(a0),pr_conf
 move.w   -6(a0),key_delay         ; delay/key_reprate

 lea      iorec_kb,a0
 lea      ori_iorec_kb(pc),a1
 moveq    #$d,d0
_cpyloop3:
 move.b   (a1)+,(a0)+
 dbf      d0,_cpyloop3

* Default-Tastaturtabellen

 move.l   #default_keytblx,default_keytblxp
 clr.b    kbshift
 clr.b    altgr_status   
     IF   ALT_NUMKEY
 clr.b    alt_numkey
     ENDIF
 bsr      _Bioskeys                ; 9 Standard-Tastaturtabellen (GER)

* Grafikausgabe initialisieren

 move.l   MSys+MacSys_pixmap(pc),a0
 jsr      vdi_blinit               ; Blitterstatus des VDI initialisieren
                                   ; (fuer Atari VDI)
 jsr      vt52_init                ; VT52 initialisieren

 move.l   #sys_start,swv_vec       ; Monitorwechsel ist Reset
 move.w   #1,vblsem

* Nochmal den MAC aufrufen

 jsr_mi   MSys+MacSys_biosinit     ; memory indirect

* Interrupts zulassen

 andi.w   #$f8ff,sr

* DOS initialisieren, Supervisorstack und Diskpuffer anlegen

 move.l   #4096,d0
 bsr      Bmalloc
 move.l   a0,_dskbufp              ; _dskbufp = Malloc(4096L)

 move.l   MSys+MacSys_superstlen(pc),sust_len     ; Groesse des Supervisorstacks pro App
 bsr      dos_init

 jsr      mxfs_init                ; MAC-XFS initialisieren

 move.w   #3,-(sp)                 ; lieber FastRAM
 lea      ap_stack,a0
 add.l    sust_len,a0
 move.l   a0,-(sp)                 ; APP #0 und Supervisorstack allozieren
 move.w   #$44,-(sp)
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

* MagiX- VDI initialisieren

 jsr      vdi_init                 ; VDI initialisieren (MXVDI)

* Bootroutinen (nach wie vor gilt: sp == endofvars)

;bsr      exec_respgms             ; residente Programme ausfuehren
 bsr      dskboot                  ; hdv_boot aufrufen
 jsr      secb_ext                 ; Sektorpufferliste erweitern

;
; allozierten Userstack wieder freigeben
 move.l   pgm_userst,-(sp)
 move.w   #73,-(sp)                ; Mfree
 trap     #1
 addq.l   #6,sp
 tst.w    d0
 bne      fatal_err

* Bootlaufwerk setzen
* MAGX.INF lesen
* VFAT, Tastaturtabellen, Log-Datei, Startbild
* XTENSION, AUTO
* AES starten
* Aufloesungswechsel

     INCLUDE "auto.s"


     INCLUDE "puntaes.s"


**********************************************************************
*
* long dos_macfn( d0 = int dos_fnr, a0 = void *params )
*
* ruft auf dem Macintosh spezielle DOS-Funktionen auf, deren
* Funktionsnummern zwischen 0x60 und 0xfe liegen
*

dos_macfn:
 move.l   MSys+MacSys_dos_macfn(pc),d1
 beq.b    dmfn_err
 move.l   d1,a1
 jmp      (a1)
dmfn_err:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*******************     Floppy- Treiber   ****************************
**********************************************************************


**********************************************************************
*
* long Floprd( void *buf, long filler, int dev, int secno,
*              int trackno, int sideno, int count )
*

Floprd:
 move.l   MSys+MacSys_floprd,d0         ; Mac-System eingeklinkt?
 beq.b    floprd_exit
 movea.l  d0,a1
;move.l   a0,a0                         ; a0 ist Zeiger auf Parameter
 jsr      (a1)
 rte
 moveq    #FLOPRD,d0
floprd_exit:
 rte



**********************************************************************
*
* long Flopwr(void *buf, long filler, int dev, int secno,
*             int trackno, int sideno, int count )
*
Flopwr:
 move.l   MSys+MacSys_flopwr,d0         ; Mac-System eingeklinkt?
 beq.b    flopwr_exit
 movea.l  d0,a1
;move.l   a0,a0                         ; a0 ist Zeiger auf Parameter
 jsr      (a1)
 rte
flopwr_exit:
 moveq    #FLOPWR,d0
 rte



**********************************************************************
*
* long Flopfmt( void *buf, long filler, int dev, int spt, int trackno,
*              int sideno, int interleave, long magic, int virgin )
*

Flopfmt:
 move.l   MSys+MacSys_flopfmt,d0        ; Mac-System eingeklinkt?
 beq.b    flopfmt_exit
 movea.l  d0,a1
;move.l   a0,a0                         ; a0 ist Zeiger auf Parameter
 jsr      (a1)
 rte
flopfmt_exit:
 moveq    #FLOPFMT,d0
 rte


**********************************************************************
*
* long Flopver( char *buf, long filler, int dev, int secno,
*               int trackno, int sideno, int count )
*

Flopver:
 move.l   MSys+MacSys_flopver,d0        ; Mac-System eingeklinkt?
 beq.b    flopver_exit
 movea.l  d0,a1
;move.l   a0,a0                         ; a0 ist Zeiger auf Parameter
 jsr      (a1)
 rte
flopver_exit:
 moveq    #FLOPVER,d0
 rte


**********************************************************************
*
* int Floprate( int devno, int rate )
*

Floprate:
 moveq    #FLOPRATE,d0
 rte


**********************************************************************
***************     DMA- und Floppy- Bootroutinen   ******************
**********************************************************************


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
* long DMAread( long sector, int count, void *buf, int target )
*
* Die Bits 21..24 von <sector> enthalten die Device- Nummer
* des betreffenden Targets
* Target 0..7:  ASCI
* Target 8..15: SCSI
*

DMAread:
 moveq    #DMAREAD,d0
 rte


**********************************************************************
*
* long DMAwrite( long sector, int count, void *buf, int target )
*

DMAwrite:
 moveq    #DMAWRITE,d0
 rte


**********************************************************************
*
* long critical_error(int err, int dev)
*

critical_error:
 move.l   etv_critic,-(sp)
 moveq    #-1,d0
 rts


*********************************************************************
*
* Der Zugriff bei Rwabs ist bei gesetztem LOCK nur fuer den
* sperrenden Prozess erlaubt
*

IRwabs:
 movem.l  d3-d7/a3-a6,-(sp)
 subq.l   #4,sp               ; Platz fuer Zeiger
 lea      12(a0),a0
 move.l   (a0),-(sp)          ; lrecno
 move.l   -(a0),d0            ; recno/dev
* Auf LOCK testen und Zugriffszeit merken
 move.w   d0,a1
 add.w    a1,a1
 add.w    a1,a1
 move.l   a1,4(sp)            ; merken fuer DOS- Writeback
 move.l   dlockx(a1),d3
 beq.b    rwabs_ok
 cmp.l    act_pd,d3
 bne.b    rwabs_elocked
rwabs_ok:
 clr.l    bufl_timer(a1)      ; fuer DOS- Writeback (als in Arbeit markieren)
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
* long Drvmap( void )
*

Drvmap:
 move.l   _drvbits,d0
 rte


     INCLUDE "protobt.s"


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


**********************************************************************
*
* void int_hbl( void )
*
* Bearbeitet den HBL- Interrupt
* (wird beim MAC nie angesprungen)
*

int_hbl:
 move.w   d0,-(sp)                 ; d0 retten
 move.w   2(sp),d0                 ; sr holen
 and.w    #$700,d0                 ; Interruptmaske 0 ?
 bne.b    ihbl_ende                ; nein, ende
 ori.w    #$300,2(sp)              ; Interruptmaske 3 setzen
ihbl_ende:
 move.w   (sp)+,d0                 ; d0 restaurieren
 rte


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

 jsr      vdi_cursor               ; Cursorblinken

* colorptr ignoriert
* screenpt ignoriert

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
* void Vsync( void )
*

Vsync:
 bsr.b   _Vsync
 rte

_Vsync:
 move     sr,-(sp)
 andi     #$f8ff,sr
 move.l   _frclock,d0
vsy_loop:
 cmp.l    _frclock,d0
 beq.b    vsy_loop
 move     (sp)+,sr
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
 DC.W     95
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
 DC.L     dummy_rte
 DC.L     NVMaccess           ; 46
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     Blitmode            ; 64
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte           ; 70
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte           ; 75
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     dummy_rte
 DC.L     Esetshift           ; 80
 DC.L     Egetshift           ; 81
 DC.L     Esetbank            ; 82
 DC.L     Esetcolor           ; 83
 DC.L     Esetpalette         ; 84
 DC.L     Egetpalette         ; 85
 DC.L     Esetgray            ; 86
 DC.L     Esetsmear           ; 87
 DC.L     dummy_rte           ; 88
 DC.L     dummy_rte           ; 89
 DC.L     dummy_rte           ; 90
 DC.L     dummy_rte           ; 91
 DC.L     dummy_rte           ; 92
 DC.L     VsetRGB             ; 93
 DC.L     VgetRGB             ; 94

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
   bcc.b    exit_bios
   add.w    d0,d0
   add.w    d0,d0
   move.l   (a1,d0.w),a1      ;Adresse der Biosroutine holen
   jmp      (a1)
exit_bios:
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
   jsr      4(a2)             ; in die eigene Routine
                              ; "lea 6(sp),a0" ueberspringen

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

ori_dev_vecs:
 DC.L     ret0                     ; Bconstat(0)       PRT
 DC.L     bconstat_ser1            ;                   AUX
 DC.L     bconstat_con             ;                   CON
 DC.L     ret0                     ;                   MIDI
 DC.L     dummyfn                  ;                   IKBD
 DC.L     dummyfn                  ;                   RAWCON
 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bconin_prt               ; Bconin(0)         PRT
 DC.L     bconin_ser1              ;                   AUX
 DC.L     bconin_con               ;                   CON
 DC.L     ret0                     ;                   MIDI
 DC.L     dummyfn                  ;                   IKBD
 DC.L     dummyfn                  ;                   RAWCON
 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bcostat_prt              ; Bcostat(0)        PRT
 DC.L     bcostat_ser1             ;                   AUX
 DC.L     bcostat_con              ;                   CON
 DC.L     ret0                     ;                   MIDI (!!!)
 DC.L     ret0                     ;                   IKBD (!!!)

 DC.L     dummyfn                  ;                   RAWCON
 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bconout_prt              ; Bconout(0,c)      PRT
 DC.L     bconout_ser1             ;                   AUX
 DC.L     vdi_conout               ;                   CON
 DC.L     ret0                     ;                   MIDI
 DC.L     ret0                     ;                   IKBD
 DC.L     vdi_rawout               ;                   RAWCON
 DC.L     dummynopfn
 DC.L     dummynopfn


**********************************************************************
*
* void Getmpb( MPB *mpb )
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
* ggf. zweiten MD fuer TT-RAM einrichten
 cmpi.l   #$1357bd13,fstrm_valid   ; TT-RAM gueltig ?
 bne.b    gmp_ende            ; nein, Ende
 move.l   fstrm_beg,d0
 move.l   fstrm_top,d1
 sub.l    d0,d1               ; fstrm_top (Ende des TT-RAMs) <= sein Anfang
 bls.b    gmp_ende            ; ja, Ende
 lea      ttram_md,a1
 move.l   a1,themd            ; hineinketten
 clr.l    (a1)+               ; letzter MD
 move.l   d0,(a1)+            ; Startadresse
 move.l   d1,(a1)+            ; Laenge
 clr.l    (a1)                ; unbenutzt
gmp_ende:
 rte

**********************************************************************
*
* long Bmaddalt( void )
*
* 25.9.96:     Wird bei DOS Maddalt() aufgerufen, um ggf. einen FRB
*              anzulegen. Rueckgabe ENSMEM, falls dies nicht geht.
*              Legt keinen (!) Cookie _FRB an.
*              Ist auf dem Mac ueberfluessig

Bmaddalt:
 moveq    #0,d0
 rts


**********************************************************************
*
* long Setexc( int nr, long vec )
*
Setexc:
 movea.w  (a0)+,a1                 ; nr
 add.w    a1,a1
 add.w    a1,a1                    ; mal 4 fuer Langwortzugriff
 move.l   (a1),d0                  ; bisheriger Vektor
 move.l   (a0),d1                  ; -1 oder neuer Wert
 bmi.b    sxc_ende
 move.l   d1,(a1)                  ; setzen
sxc_ende:
 rte

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
* global void mac_puts(a0 = char *errmsg)
*
* Gibt eine Zeichenkette auf dem MAC-Bildschirm aus
* (zu Debugging-Zwecken)
*

mac_puts:
debug_puts:
 jsr_mi   MSys+MacSys_debugout     ; memory indirect
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
 jsr_mi   MSys+MacSys_syshalt


**********************************************************************
*
* void print_bombs10( void )
*
* Routine fuer 68010/20/30/40
*

print_bombs10:
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/sp,proc_regs
 move.w   6(sp),d0                 ; Vektoroffset
 lsr.w    #2,d0                    ; /4 ist Vektornummer
 move.b   d0,proc_pc
 move     usp,a0
 move.l   a0,proc_usp
 moveq    #$f,d0
 lea      proc_stk,a0
 movea.l  sp,a1
pb_loop:
 move.w   (a1)+,(a0)+
 dbf      d0,pb_loop
 move.l   #$12345678,proc_lives
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
 jsr      putstr
 bsr      bconin_con
os_chk_ok:
* Prozess beenden
 move.w   #-1,-(sp)
 btst.b   #5,config_status+3       ; KAOS oder TOS ?
 bne.b    pb_tos
 move.w   #$ffbb,(sp)              ; EXCPT
pb_tos:
     IFNE DEBUG
 bra.w    pb_tos
     ENDIF
 move.w   #$4c,-(sp)
 trap     #1
 bra      sys_start


**********************************************************************
*
* long bios_rawdrvr( d0 = int opcode, d1 = long devcode, ... )
*
* Fuehrt geraetespezifische Aktionen aus.
*
* d0 = 0: Medium auswerfen.
*
* Da der Treiber im Atari nur die Floppies A: und B: bedient, gibt
* es dort nur ein EINVFN. Anders beim Mac:
*

bios_rawdrvr:
 move.l   MSys+MacSys_rawdrvr(pc),d2
 beq.b    brw_err             ; alte Kernel-Version
 move.l   d2,a0
 jmp      (a0)                ; d0.w (BIOS) => d0.l (device)
brw_err:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long drv2devcode( d0 = int biosdev )
*
* Rechnet ein BIOS-Device in einen devcode um (major/minor)
* Rueckgabe 0, wenn Fehler
* wird vom DOS aufgerufen
*

bios2devcode:
drv2devcode:
 move.l   MSys+MacSys_drv2devcode(pc),d2
 beq.b    b2dc_err            ; alte Kernel-Version
 move.l   d2,a0
 jmp      (a0)                ; d0.w (BIOS) => d0.l (device)
b2dc_err:
 moveq    #0,d0
 rts


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
* global int Cursconf( int dummy, int mode )
*

Cursconf:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     2(a0),-(sp) ;mode
 move.w     (a0),-(sp)  ;dummy
 bsr.b      _Cursconf
 addq.l     #4,sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Cursconf:
 DC.W     $a000
 lea      -6(a0),a4      ; Adresse linea-Vektoren
 move.w   4(sp),d0
 cmp.w    #7,d0
 bhi.b    ccnf_err
 add.w    d0,d0

 add.w    d0,d0
 move.l   ccnf_tab(pc,d0.w),a0
 jmp      (a0)

ccnf_tab:
 DC.L     vt_seq_f       ; CURS_HIDE
 DC.L     vt_seq_e       ; CURS_SHOW
 DC.L     ccnf_blink     ; CURS_BLINK
 DC.L     ccnf_noblink   ; CURS_NOBLINK
 DC.L     ccnf_setrate   ; CURS_SETRATE
 DC.L     ccnf_getrate   ; CURS_GETRATE
 DC.L     ccnf_setdelay  ; CURS_SETDELAY
 DC.L     ccnf_getdelay  ; CURS_GETDELAY

ccnf_blink:
 bset     #0,(a4)
ccnf_err:
 rts
ccnf_noblink:
 bclr     #0,(a4)
 rts
ccnf_setrate:
 move.b   7(sp),-$12(a4)
 rts
ccnf_getrate:
 moveq    #0,d0
 move.b   -$12(a4),d0
 rts
ccnf_setdelay:
 move.b   7(sp),d0
 move.b   d0,1(a4)
 rts
ccnf_getdelay:
 moveq    #0,d0
 move.b   1(a4),d0
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
 move.w   $1e(a1),$1c(a1)               ; gendatg->palmode ??
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
 jsr      _lmul
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
* void Midiws( int count, char *buf )
*

Midiws:
 moveq    #0,d0
 rte


bcostat_con:
 moveq    #-1,d0                   ; immer Zeichen sendbar
 rts


**********************************************************************
*
* void timedate_to_bcd( d0 = long timedate, a0 = char *bcd )
*
* 15.9.96:     Wandelt eine Uhrzeit im normalen Format um in das
*              BCD-Format, das vom ST-Tastaturchip verwendet wird.
*

timedate_to_bcd:
 move.l   d0,d2                    ; d2 = timedate
 lea      6(a0),a0                 ; a0 = bcd+6
;move.b   d2,d0
 andi.b   #$1f,d0
 asl.b    #1,d0
 bsr.b    bin_to_bcd               ; s
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$3f,d0
 bsr.b    bin_to_bcd               ; min
 lsr.l    #6,d2
 move.b   d2,d0
 andi.b   #$1f,d0
 bsr.b    bin_to_bcd               ; h
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$1f,d0
 bsr.b    bin_to_bcd               ; tag
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$f,d0
 bsr.b    bin_to_bcd               ; monat
 lsr.l    #4,d2
 move.b   d2,d0
 andi.b   #$7f,d0
 bsr.b    bin_to_bcd               ; jahr
 addi.b   #$80,(a0)                ; BCD: 80
 rts

bin_to_bcd:
 moveq    #0,d1
 move.b   d0,d1
 divs     #$a,d1
 asl.w    #4,d1
 move.w   d1,d0
 swap     d1
 add.w    d1,d0
 move.b   d0,-(a0)
 rts


**********************************************************************
*
* void Ikbdws( int count_minus_1, char *buf )
*
* 15.9.96:     Das Schicken des Einzelbytes $1c an den Tastaturchip
*              wird simuliert. Es wird kbdvecvs.clockvec aufgerufen
*              und die Uhrzeit uebergeben.
*

Ikbdws:
 move.w   (a0)+,d0                 ; Anzahl Zeichen
 bne.b    ikbdws_ende              ; ungleich 1, fertig
 move.l   (a0),a0                  ; Daten
 cmpi.b   #$1c,(a0)                ; IKBD: Interrogate time-of-day ?
 bne.b    ikbdws_ende              ; nein, fertig
; Uhr des Tastaturchips auslesen
 subq.l   #6,sp                    ; char data[6]
 bsr      _Gettime                 ; d0 = Uhrzeit vom Mac holen
 lea      (sp),a0
 bsr      timedate_to_bcd
 pea      (sp)                     ; Paketadresse
 move.l   kbdvecs+$14,a2           ; clockvec
 jsr      (a2)
 addq.l   #4,sp
 addq.l   #6,sp
ikbdws_ende:
 moveq    #0,d0
 rte


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
 lea     intern_maptab,a1
 adda.w   d2,a0
 adda.w  d2,a1

 move.l  (a0)+,d1
 move.l  d1,dev_vecs+4        ;Bconstat(1)
 move.l  d1,Bconstatvec+4
 cmp.l   (a1)+,d1             ;MAG!XBIOS-Routine?
 beq.b   _bmp_conin
 clr.l   Bconstatvec+4        ;externe Routine

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
*    ST:  Mega STE:  TT:
* ------------------------------------------------------------------
*    6       6       6     ST-kompatibel seriell (Modem 1)      ser1
*            7       7     SCC Kanal B           (Modem 2)      sccb
*                    8     TTMFP                 (Serial 1)     ser2
*            8       9     SCC Kanal A           (Serial 2)     scca
*

init_bconmap:
 lea      dflt_maptable,a0
 lea      bconmap_struct,a1
 move.l   a0,(a1)+
 lea      maptab_data(pc),a2
 bsr      _bco_cpy            ; ser1 (ST-MFP)
 moveq    #1,d0               ; zunaechst eine Schnittstelle
 move.w   d0,(a1)+            ; Laenge festlegen
 move.w   #6,(a1)             ; aktueller ist ST-kompatibler serieller Port

 lea      dflt_maptable,a0
 lea     intern_maptab,a1
 moveq   #23,d0
ins_internmap:                ;Maptab der Mag!X-eigenen Routinen erstellen
 move.l  (a0)+,(a1)+
 dbra    d0,ins_internmap

 lea      dflt_maptable,a0
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

_bco_cpy:
 move.l   (a2)+,(a0)+
 move.l   (a2)+,(a0)+
 move.l   (a2)+,(a0)+
 move.l   (a2)+,(a0)+
 move.l   (a2)+,(a0)+
 move.l   a1,-(sp)
 move.l   (a2)+,a1
 move.l   (a1),(a0)+          ; iorec ist indirekt
 move.l   (sp)+,a1
 rts

maptab_data:
 DC.L bconstat_ser1      ; Bconstat
 DC.L bconin_ser1        ; Bconin
 DC.L bcostat_ser1       ; Bcostat
 DC.L bconout_ser1       ; Bconout
 DC.L rsconf_ser1        ; Rsconf
 DC.L p_iorec_ser1       ; iorec fuer ST-MFP



bconstat_con:
 lea      iorec_kb+6,a0            ; *Head-Index
 cmpm.w   (a0)+,(a0)+              ; Head-Index mit Tail-Index vergleichen
 sne.b    d0                       ; TRUE, wenn Puffer nicht leer
 ext.w    d0
 ext.l    d0                       ; auf Langwort erweitern
 rts

bconin_con:
 lea      iorec_kb,a0              ; IKBD-Iorec
 moveq    #4,d2                    ; Groesse eines Arrayelementes
_bconin:
 lea      8(a0),a1                 ; *Tail
 move.w   (a1),d1                  ; Tail-Index
 cmp.w    -(a1),d1                 ; Head-Index
 beq.b    _bconin
* Head- Index ist ungleich Tail- Index, also Zeichen da!
 move     sr,-(sp)
 ori      #$700,sr                 ; Interrupts sperren
 move.w   (a1)+,d1                 ; Head-Index
 cmp.w    (a1),d1                  ; Tail-Index
 beq.b    bin_again                ; jetzt ist das Zeichen weg! (Fehler!)
* Das Zeichen ist immer noch da
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
* global void pling( void )
*
* Wird vom VDI (VT52) aufgerufen
*

pling:
 btst     #2,conterm               ; Glocke bei ^G ?
 beq.b    pling_ende               ; nein
 movea.l  bell_hook,a0
 jmp      (a0)

hdl_pling:
 move.l   #pling_data,sound_data
 clr.b    sound_delay
pling_ende:
 rts

hdl_klick:
 move.l   #klick_data,sound_data
 clr.b    sound_delay
 rts


ori_iorec_kb:
 DC.L     iorec_kb_buf             ; Pufferadresse
 DC.W     $0100                    ; Groesse 256 Bytes = 64 Langworte
 DC.W     0                        ; Head Index
 DC.W     0                        ; Tail Index
 DC.W     $40                      ; Low water mark
 DC.W     $c0                      ; High water mark


**********************************************************************
*
* void Mfpint( int nr, long vec )
*

Mfpint:
 move.w   (a0)+,d0                 ; Vektornummer
 movea.l  (a0),a2                  ; Interruptvektor
 andi.w   #$f,d0                   ; auf [0..15] begrenzen
 bsr.b   _mfpint
 rte


_mfpint:
 lea      $100,a0                  ; Sprungvektoren
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0                    ; * 4 fuer Langwortzugriff
 move.l   a2,(a0)                  ; Interrupt umsetzen
 rts


**********************************************************************
*
* void Jdisint( int nr )
* void Jenabint( int nr )
* char Giaccess( char dat, int regno )
* void Ongibit( int nr )
* void Offgibit( int nr )
* void Xbtimer( int timer, int ctrl, int data, long vec )
* long NVMAccess(int op, int start, int count, char *buf)
* long Esetshift( int shiftmode )
* long Egetshift( void )
* long Esetbank( int num )
* long Esetcolor( int num, int col )
* long Esetpalette( int num, int count, int *cols )
* long Egetpalette( int num, int count, int *cols )
* long Esetgray( int switch )
* long Esetsmear( int switch )
*

Jdisint:
Jenabint:
Giaccess:
Ongibit:
Offgibit:
Xbtimer:
NVMaccess:
Esetshift:
Egetshift:
Esetbank:
Esetcolor:
Esetpalette:
Egetpalette:
Esetsmear:
 lsr.w    #2,d0          ; Damit d0 == opcode
 rte


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
 suba.l   a1,a1                    ; iorec_midi
iorec_ok:
 move.l   a1,d0
 rte


**********************************************************************
*
* void Initmous(int typ, long par, long vec )
*

Initmous:
 move.w   (a0)+,d0
 beq.b    inims_0                  ; typ == 0
 movea.l  (a0)+,a1
 move.l   (a0),kbdvecs+$10         ; mousevec
 subq.w   #1,d0
 beq.b    inims_1                  ; typ == 1
 subq.w   #1,d0
 beq.b    inims_2                  ; typ == 2
 subq.w   #2,d0
 beq.b    inims_4                  ; typ == 4
 moveq    #0,d0
 bra.b    initm_ende
* Maus ausschalten
inims_0:
 move.l   #dummyfn,kbdvecs+$10     ; mousevec
 bra.b    initm_neg
* relativer Modus
inims_1:
 bra.b    initm_neg
* absoluter Modus
inims_2:
 bra.b    initm_neg
inims_4:
initm_neg:
 moveq    #-1,d0
initm_ende:
 rte


**********************************************************************
*
* void Dosound( char *ptr )
*

Dosound:
 lea      sound_data,a1
 move.l   (a1),d0                  ; laufendes Tonprogramm
 move.l   (a0),d1                  ; neues Tonprogramm
 bmi.b    dsnd_get                 ;  ist -1 => laufendes zurueckgeben
 move.l   d1,(a1)+                 ; neues setzen
 clr.b    (a1)                     ; Flag loeschen
dsnd_get:
 rte


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
* int_hz_200 (int_mfp5)
*

int_hz_200:
 addq.l   #1,_hz_200
 rol.w    flg_50hz
 bpl.b    i200_yield               ; nur jeden vierten Interrupt (50Hz)
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
; alle 2s die Uhrzeit vom MAC holen
 subq.w   #1,do_gettime
 bcc.b    i200_noti
 bsr      init_dosclock
 move.w   #100,do_gettime
i200_noti:
;bsr.b    _dosound                 ; Sound verarbeiten
; eori.w   #$300,sr                 ; von IPL 6 auf 5 schalten
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
 movem.l  (sp)+,a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0
i200_yield:
 tst.w    pe_slice
 bmi.b    nix_hz
 subq.w   #1,pe_timer
 bgt.b    nix_hz
 clr.w    pe_timer                 ; ist abgelaufen
;btst     #5,(sp)
;bne      nix_hz                   ; aus Supervisormode nicht abfangen
;andi.w   #$f3ff,sr                ; INT=3
;jsr      appl_suspend
 move.l   #my_tasksw,MSys+MacSys_tasksw
nix_hz:
 rte


**********************************************************************
*
* Taskswitch
*
**********************************************************************

my_tasksw:
 clr.l    MSys+MacSys_tasksw       ; fuer Timer
 jmp      appl_suspend
my_tasksw2:
 clr.l    MSys+MacSys_tasksw       ; fuer Event
 jmp      appl_yield


     INCLUDE "priv_exc.s"


**********************************************************************
*
* long Gettime( void )
*

Gettime:
 bsr.b    _Gettime
 rte
_Gettime:
 jsr_mi   MSys+MacSys_gettime
 rts


**********************************************************************
*
* void Settime( long timedat )
*

Settime:
 move.l   MSys+MacSys_settime(pc),d1
 beq.b    settime_err
 move.l   d1,a1
 jsr      (a1)
settime_err:
 rte


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
* void init_dosclock(void)
*

init_dosclock:
 bsr      _Gettime
 move.w   d0,dos_time
 swap     d0
 move.w   d0,dos_date
 rts


**********************************************************************
*
* void *Physbase( void )
*

Physbase:
 move.l   _v_bas_ad,d0
 rte


**********************************************************************
*
* void *Logbase( void )
*

Logbase:
 move.l   _v_bas_ad,d0
 rte


**********************************************************************
*
* int Getrez( void )
*

Getrez:
 moveq    #0,d0
 move.w   sshiftmd,d0
 rte


**********************************************************************
*
* void Setscreen( void *log, void *phys, int res )
*

Setscreen:
 move.l   (a0),d0                 ; *log
 moveq    #-1,d1
 cmp.l    d0,d1
 beq.b    setscr_nolog            ; log. Adr. nicht aendern
 move.l   d0,_v_bas_ad
setscr_nolog:
 move.l   MSys+MacSys_set_physbase,d0   ;Mac-System eingeklinkt?
 beq.b    setscr_exit
 movea.l  d0,a1
 jsr      (a1)
setscr_exit:
 rte


**********************************************************************
*
* void Setpalette( int ptr[16] )
*

Setpalette:
 move.l (a0),colorptr
 rte


**********************************************************************
*
* int Setcolor( int nr, int val )
*

Setcolor:
 moveq    #0,d0
 rte


**********************************************************************
*
* WORD Esetgray( WORD flag )
*

Esetgray:
 moveq         #0,d0
 rte


**********************************************************************
*
* void VsetRGB( WORD index, WORD count, LONG *array )
*

VsetRGB:
 move.l        MSys+MacSys_VsetRGB,d0        ;Mac-System eingeklinkt?
 beq.b         VsetRGB_exit
 movea.l       d0,a1
 jsr           (a1)
VsetRGB_exit:
 rte


**********************************************************************
*
* void VgetRGB( WORD index, WORD count, LONG *array )
*

VgetRGB:
 move.l        MSys+MacSys_VgetRGB,d0        ;Mac-System eingeklinkt?
 beq.b         VgetRGB_exit
 movea.l       d0,a1
 jsr           (a1)
VgetRGB_exit:
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
* Setzt im TOS nur 3 Tabellen.
* In MagiC drei weitere (fuer AltGr)
* IN MagiC ab 1.6.97 nochmals 3 weitere (fuer Alt)
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
***************     Interruptroutinen   ******************************
**********************************************************************


**********************************************************************
*
* "Interrupt" fuer MIDI und Keyboard (MFP- Interrupt 6).
*
* Der Interrupt wird hier nur simuliert, und zwar folgendermassen:
*
* d7 = 'MAGC': Daten sind gueltig
*
* dann:   d6 = 0:   MIDI
*         d6 = 1:   Tastatur
*              d5 = Atari-Scancode
*         d6 = 2:   Mauspaket
*              a6 = char data[3]
*

midikey_int:
 movem.l  d0/d1/d2/d3/a0/a1/a2/a3,-(sp)
 movea.l  kbdvecs+$1c,a2           ; midisys
 jsr      (a2)
 movea.l  kbdvecs+$20,a2           ; ikbdsys
 jsr      (a2)
 movem.l  (sp)+,a3/a2/a1/a0/d3/d2/d1/d0
 tst.w    pe_slice
 bmi.b    mik_no_yield
;btst     #5,(sp)
;bne      mik_no_yield             ; aus Supervisormode nicht abfangen
;andi.w   #$f3ff,sr                ; INT=3
;jsr      appl_yield
 move.l   #my_tasksw2,MSys+MacSys_tasksw
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
* d7 = 'MAGC': Daten sind gueltig
*
* dann:   d6 = 0:   MIDI



*         d6 = 1:   Tastatur
*              d5 = Atari-Scancode
*         d6 = 2:   Mauspaket
*              a6 = char data[3]
*

ikbdsys:
 cmpi.l   #'MAGC',d7
 bne.b    iks_err
 cmpi.w   #1,d6
 beq.b    iks_key
 cmpi.w   #2,d6
 bne.b    iks_err
 move.l   a6,a0
 move.l   a0,-(sp)
 movea.l  kbdvecs+$10,a2          ;mousevec
 jsr      (a2)
 addq.l   #4,sp
 rts
iks_key:
 lea      iorec_kb,a0              ; Tastatur-IOREC
 move.l   kbdvecs-4,a1             ; i.a. handle_key

 move.w   d5,d0
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

**********************************************************************
*
* Wird aufgerufen, wenn das resvalid/resvector- Programm einen
* Systemfehler provoziert hat. Fuehrt einen Warmstart aus.
*

kill_resval:
 clr.b    resvalid

**********************************************************************
*
* Fuehrt einen Warmstart aus
*
* beim 68020/30 werden die Caches abgeschaltet
*

warm_boot:
 move     #$2700,sr                ; Interrupts sperren, SUP
; cmpi.w   #20,cpu_typ
; bcs.b    warmb_00
; move.l   #$808,d0                 ; Bit  0=0: instr cache off
                                   ; Bit     3=1: instr cache clear
                                   ; Bit     8=0: data  cache off
                                   ; Bit 11=1: data  cache clear
; movec.l  d0,cacr
warmb_00:
;  reset                            ;versuchsweise
   cmp.l    #$31415926,$00000426.w  ;resvalid
   bne      sys_start
   move.l   $42a.w,d0               ;resvector
   btst     #0,d0
   bne      sys_start
   move.l   d0,a0
   lea      warmb_00(pc),a6         ;Ruecksprungadresse
   jmp      (a0)
   bra      sys_start


**********************************************************************
*
* Fuehrt einen Kaltstart aus
*

cold_boot:
 move.l   a5,-(sp)
 jsr_mi   MSys+MacSys_coldboot
 rts


*
* Tabelle der Default-Tastaturtabellen (GER)
*

default_keytblx:
 DC.L     tab_unshift
 DC.L     tab_shift
 DC.L     tab_caps
 DC.L     tab_altgr
 DC.L     tab_shaltgr
 DC.L     tab_altgr
 DC.L     tab_alt
 DC.L     tab_shalt
 DC.L     tab_alt

tab_unshift:
 DC.B     $00,$1b,'1','2','3','4','5','6','7','8','9','0',$9e,$27,$08,$09
 DC.B     'q','w','e','r','t','z','u','i','o','p',$81,'+',$0d,$00,'a','s'
 DC.B     'd','f','g','h','j','k','l',$94,$84,'#',$00,$7e,'y','x','c','v'
 DC.B     'b','n','m',',','.','-',$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,'-',$00,$00,$00,'+',$00
 DC.B     $00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     '<',$00,$00,'(',')','/','*','7','8','9','4','5','6','1','2','3'
 DC.B     '0','.',$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_shift:
 DC.B     $00,$1b,'!',$22,$dd,'$','%','&','/','(',')','=','?',$60,$08,$09
 DC.B     'Q','W','E','R','T','Z','U','I','O','P',$9a,'*',$0d,$00,'A','S'
 DC.B     'D','F','G','H','J','K','L',$99,$8e,'^',$00,$7c,'Y','X','C','V'
 DC.B     'B','N','M',';',':','_',$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,'7','8',$00,'-','4',$00,'6','+',$00
 DC.B     '2',$00,'0',$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     '>',$00,$00,'(',')','/','*','7','8','9','4','5','6','1','2','3'
 DC.B     '0','.',$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_caps:
 DC.B     $00,$1b,'1','2','3','4','5','6','7','8','9','0',$9e,$27,$08,$09
 DC.B     'Q','W','E','R','T','Z','U','I','O','P',$9a,'+',$0d,$00,'A','S'
 DC.B     'D','F','G','H','J','K','L',$99,$8e,'#',$00,$7e,'Y','X','C','V'
 DC.B     'B','N','M',',','.','-',$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,'-',$00,$00,$00,'+',$00
 DC.B     $00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     '<',$00,$00,'(',')','/','*','7','8','9','4','5','6','1','2','3'
 DC.B     '0','.',$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_alt:
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,'@',$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,'[',']',$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_shalt:
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5c,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,'{','}',$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

XXX  EQU  $20       ; darf nicht belegt werden
YYY  EQU  XXX       ; ist  nicht belegt

tab_altgr:
*       $0              $4              $8              $c
 DC.B  $00,YYY,$fc,$fd,$fe,$fb,$ae,$ee,$7b,'[',']',$7d,$5c,$f4,YYY,YYY  * $0
 DC.B  '@',$8a,$82,$00,$00,$97,$a3,$a1,$a2,$95,$b1,$7e,YYY,XXX,$a0,$85
 DC.B  $b0,$86,$a6,$00,$c0,$8d,$b3,$b4,$91,$f0,XXX,$f3,$98,$00,$87,$00  * $2
 DC.B  $00,$a4,$e6,$a9,$fa,$ff,XXX,$00,XXX,YYY,XXX,$c2,$c3,$c4,$c5,$c6
 DC.B  $c7,$c8,$c9,$ca,$cb,$cc,$cd,YYY,YYY,$00,$bf,YYY,$00,YYY,$f1,$00  * $4
 DC.B  YYY,$00,YYY,YYY,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B  $7c,$db,$da,$00,$00,$f6,$f8,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8  * $6
 DC.B  $00,$bd,YYY,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

tab_shaltgr:
*       $0              $4              $8              $c
 DC.B  $00,YYY,$ad,$ab,$bb,$ac,$af,$ef,$9b,$9c,$9d,$df,$a8,$f5,$00,$00  * $0
 DC.B  $89,$88,$90,$00,$00,$96,$00,$8b,$a7,$93,$b8,$b9,YYY,XXX,$83,$b6
 DC.B  $b7,$8f,$00,$00,$c1,$8c,$b2,$b5,$92,$f7,XXX,$f2,$00,$00,$80,$00  * $2
 DC.B  $00,$a5,$00,$aa,$7f,$9f,XXX,$00,XXX,YYY,XXX,$ce,$cf,$d0,$d1,$d2
 DC.B  $d3,$d4,$d5,$d6,$d7,$d8,$d9,YYY,YYY,$bc,$00,YYY,$00,YYY,$00,$00  * $4
 DC.B  YYY,$00,YYY,YYY,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 DC.B  $00,$00,$dc,$00,$00,$00,$f9,$e9,$ea,$eb,$ec,$ed,$00,$00,$00,$00  * $6
 DC.B  $00,$be,YYY,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



**********************************************************************
*
* Installation der Cookies
*
* auf dem Mac:
*
*    _CPU
*    _FPU
*    _VDO
*    _MCH
*    _SND
*    _FDC
*    _IDT
*    MagX
*    MgMc
*    

install_cookies:
 move.l   a5,-(sp)
 lea      cookies,a5               ; Adresse der Cookies
 move.l   a5,_p_cookies            ; Pointer setzen
* _CPU Cookie, Loword enthaelt den <cpu_typ>
 move.l   #'_CPU',(a5)+
 clr.w    (a5)+
 move.w   cpu_typ,(a5)+

* FPU bestimmen

* Nach Atari Dokumentation ist die Belegung wie folgt:
* _FPU Cookie ist IMMER da !!!
* Belegung im Highword:
*  0 = keine Hardware- FPU
*  1 = Atari Register FPU (memory mapped)
*  2 = LineF FPU
*  3 = Atari Register FPU + LineF FPU
*  4 = mit Sicherheit 68881 LineF FPU
*  5 = Atari Register FPU + mit Sicherheit 68881 LineF FPU
*  6 = mit Sicherheit 68882 LineF FPU
*  7 = Atari Register FPU + mit Sicherheit 68882 LineF FPU
*  8 = 68040 internal LineF FPU
*  9 = Atari Register FPU + 68040 internal LineF FPU
* Das Loword ist fuer eine spaetere eventuelle
* softwaremaessige LineF- Emulation reserviert und derzeit immer 0

 moveq    #0,d1
 move.w   MSys+MacSys_fpu(pc),d1
 cmpi.w   #2,d1                    ; LineF FPU ?
 scc.b    is_fpu                   ; ja !
 swap     d1                       ; Kennung ins Hiword
 move.l   #'_FPU',(a5)+
 move.l   d1,(a5)+                 ; und FPUs eintragen

 moveq    #-1,d0                   ; kein ST

* _VDO Cookie eintragen
 move.l   #'_VDO',(a5)+
 move.l   d0,(a5)+                 ; MAC

* _MCH Cookie:
* $00000:      ST und Mega ST
* $10000:      STe
* $10001:      Mega STE
* $20000:      TT
* $ffffffff:   MAC

 clr.b    machine_type             ; normaler ST
 move.l   #'_MCH',(a5)+
 move.l   d0,(a5)+                 ; MAC

* _SND Cookie
 moveq    #0,d0                    ; d0 initialisieren (kein Sound)
 move.l   #'_SND',(a5)+
 move.l   d0,(a5)+                 ; und _SND eintragen

* FDC-Cookie
 move.l   #'_FDC',(a5)+
 move.l   #$014d6163,(a5)+         ; '\1Mac'

* _IDT-Cookie

 move.l   #'_IDT',(a5)+
     IF   COUNTRY=COUNTRY_DE
 move.l   #$112e,(a5)+             ; 24h/DMY/'.'
     ENDIF
     IF   COUNTRY=COUNTRY_US
 move.l   #$002f,(a5)+             ; 12h/MDY/'/'
     ENDIF
     IF   COUNTRY=COUNTRY_UK

 move.l   #$112d,(a5)+             ; 24h/DMY/'-'
     ENDIF
     IF   COUNTRY=COUNTRY_FR
 move.l   #$112f,(a5)+             ; 24h/DMY/'/'
     ENDIF

* MagiX- Cookie
 move.l   #'MagX',(a5)+
 move.l   #config_status,(a5)+

* MacIntosh- Cookie
 move.l   #'MgMc',(a5)+
 clr.l    (a5)+

* Endmarkierung
 clr.l    (a5)+
 move.l   #NCOOKIES,(a5)           ; Platz fuer insgesamt 20+1 Cookies
 move.l   (sp)+,a5
 rts


**********************************************************************
***************    Schnittstellen- Routinen   ************************
**********************************************************************

rsconf_ser1:
 jsr_mi   MSys+MacSys_serconf
 rts

init_aux_iorec:
 suba.l   a0,a0
 rts

bconin_ser1:
 jsr_mi   MSys+MacSys_serin
 rts

bconout_ser1:
 lea      6(sp),a0
 jsr_mi   MSys+MacSys_serout
 rts

bconstat_ser1:
 jsr_mi   MSys+MacSys_seris
 rts

bcostat_ser1:
 jsr_mi   MSys+MacSys_seros
 rts

bconout_prt:
 lea      6(sp),a0
 jsr_mi   MSys+MacSys_prtout
 rts

bconin_prt:
 jsr_mi   MSys+MacSys_prtin
 rts

bcostat_prt:
 jsr_mi   MSys+MacSys_prtos
 rts


**********************************************************************
*
* long prn_wrts( a0 = char *buf, d0 = long count )
*
* Wird vom DOS aufgerufen, gibt mehrere Zeichen auf die
* parallele Schnittstelle aus.
* Gibt die Anzahl der ausgegebenen Zeichen zurueck.
*

prn_wrts:
 cmpi.l   #bconout_prt,$57e        ; bconout fuer PRT
 bne.b    old_prn_wrts             ; hat sich geaendert !!!
 move.l   MSys+MacSys_prn_wrts(pc),d1
 beq.b    old_prn_wrts             ; alte Mac-Version
 move.l   d1,a1
 jmp      (a1)


**********************************************************************
*
* long old_prn_wrts( a0 = char *buf, d0 = long count )
*
* Wie prn_wrts, geht aber ueber BIOS
*

old_prn_wrts:
 movem.l  d6/d7/a6,-(sp)
 move.l   d0,-(sp)
 move.l   a0,a6                         ; a6 = Puffer
 moveq    #3,d6
 swap     d6                            ; Fcode Bconout/BIOS- Geraet
 move.l   d0,d7
 bra.b    bpw_nextloop
bpw_loop:
 moveq    #0,d0
 move.b   (a6)+,d0
 move.w   d0,-(sp)
 move.l   d6,-(sp)                      ; Bconout(dev, c)
 trap     #$d
 addq.l   #6,sp
 tst.w    d0                            ; bei PRN Status pruefen !
 bne.b    bpw_nextloop                  ; kein Fehler
* Fehler, Timeout
 addq.l   #1,d7
 sub.l    d7,(sp)
 bra.b    bpw_ende
bpw_nextloop:
 subq.l   #1,d7
 bcc.b    bpw_loop
bpw_ende:
 move.l   (sp)+,d0
 movem.l  (sp)+,d6/d7/a6
 rts



**********************************************************************
**********************************************************************
*
* DATA
*

     IF   COUNTRY=COUNTRY_DE
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM ',$9a,'BERSCHRIEBEN ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATALER FEHLER BEIM BOOTEN:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM ANGEHALTEN ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM DESTROYED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATAL ERROR WHILE BOOTING:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM HALTED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
     IF   COUNTRY=COUNTRY_UK
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM DESTROYED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATAL ERROR WHILE BOOTING:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM HALTED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
    IF  COUNTRY=COUNTRY_FR
os_corr_s:
 DC.B   $1b,'K',$d,$a
 DC.B   $1b,'K',$d,$a
 DC.B   '*** RECOUVREMENT DU SYSTEME ***',$1b,'K',$d,$a
 DC.B   $1b,'K',0
fatal_bios_errs:
 DC.B   '*** ERREUR FATALE AU BOOT:',0
fatal_errs:
 DC.B   $1b,'K',$d,$a
 DC.B   $1b,'K',$d,$a
 DC.B   '*** SYSTEME STOPP',$90,' ***',$1b,'K',$d,$a
 DC.B   $1b,'K',0
    ENDIF

     EVEN


pling_data:  /* Ton fuer "pling" */
 DC.B     $00,$34,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
 DC.B     $08,$10,$09,$00,$0a,$00,$0b,$00,$0c,$10,$0d,$09,$ff,$00

klick_data:  /* Ton fuer "klick" */
 DC.B     $00,$3b,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
 DC.B     $08,$10,$0d,$03,$0b,$80,$0c,$01,$ff,$00,$00

     END

