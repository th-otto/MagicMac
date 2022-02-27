;
; BIOS fuer MagiC
;
; Tabulatorbreite: 5
;
; Enthaelt:
; - Puntaes-Erweiterung (AND)
; - bios2devcode und bios_rawdrvr (AND)
; - Falcon-Video-Routinen
; - DSP-Routinen
; - IDE-Routinen
; - speziellem Falcon-Mapping (SCC auf 6 & 7) in init_bconmap
; - init_scc fuer Falcon veraendert (keine SCU, Port-Bit 7 schaltet IDE-Laufwerk
;         aus)
; - Sonderbehandlung fuer Warmstart beim Falcon
; - Verzoegerung in set_DMA_write, um Busfehler beim Falcon zu vermeiden
; - RTE-Fehler in Initmous beseitigt
; - Unterstuetzung fuer systemuebergreifende SCSI-Routinen von SE (SCSI.RAM)
; - dma_boot aufgeraeumt. Rechnerunabhaengig durch Busfehlertest auf IDE/SCSI-
;         Hardware (NATUeRLICH mit Falcon-Sonderabfrage ...)
; - Fehler in VSetSync korrigiert (V/H-Sync wurde in SP_SHIFT mit
;         $ffbf statt $ff9f maskiert
; - Bootaufloesung fuer RGB/TV korrigiert
; - Vsetmode fuer RGB/TV korrigiert und zusammengefasst
; - prn_wrts ergaenzt (AND)
;
; Es fehlt:
; - DSP-Aufraeumroutine (dazu muessen die DSP-Code-Verwaltungsroutinen noch
;    erweitert werden)
; - Bootsektor ueber Trap (DMARead) lesen, anstatt DMARead direkt aufzurufen;
;    ist sinnvoll, sobald SCSI.RAM sich auch in DMARead/DMAWrite einklinkt.
;
FALCON    EQU  1
MACINTOSH EQU  0
MILANCOMP EQU  0
;HADES     EQU  0
DEBUG     EQU  0
DEBUG2    EQU  0
DEBUG3    EQU  0

;    IFNB COUNTRY
;COUNTRY  EQU  1
;    ENDIF

     IFNE HADES
XFS95     EQU  0
     INCLUDE "hades.inc"
     ELSE
XFS95     EQU  1
     ENDIF

     EXPORT      _start
     EXPORT      getcookie
     EXPORT      bios2devcode        ; BIOS-Device => devcode (32 Bit)
     EXPORT      bios_rawdrvr        ; raw-Driver aus dem BIOS
     EXPORT      chk_rtclock
     EXPORT      read_rtclock
     EXPORT      pling               ; nach VDI
     EXPORT      kbshift             ; nach VDI,XAES
     EXPORT      altcode_asc         ; nach XAES
     EXPORT      iorec_kb            ; nach DOS,XAES
     EXPORT      ctrl_status         ; nach DOS
     EXPORT      is_fpu              ; nach XAES
     EXPORT      halt_system         ; nach DOS,AES
     EXPORT      p_mgxinf            ; nach XAES
     EXPORT      machine_type        ; nach VDI,DOS
     EXPORT      config_status       ; nach DOS und AES
     EXPORT      pkill_vector        ; nach DOS und AES
     EXPORT      status_bits         ; nach DOS und AES
     EXPORT      pe_slice            ; nach XAES
     EXPORT      pe_timer            ; nach XAES
     EXPORT      first_sem           ; nach XAES
     EXPORT      app0                ; nach AES
     EXPORT      sust_len            ; nach AES
     EXPORT      datemode            ; nach STD
     EXPORT      Bmalloc             ; nach DOS
     EXPORT      Bmaddalt            ; nach DOS (ab 25.9.96)
     EXPORT      dos_macfn           ; nach DOS

     EXPORT      p_vt52              ; neues VT52 nach DOS
     EXPORT      warm_boot           ; nach AES
     EXPORT      warmbvec,coldbvec   ; nach AES
     EXPORT      ideparm             ; nach IDE.C
     EXPORT      prn_wrts            ; -> DEV_BIOS
     IFNE FALCON
     EXPORT      scrbuf_adr,scrbuf_len    ; nach DOS
     ENDIF
     EXPORT mmx_yield
	EXPORT putch

;Import vom DOS

     IMPORT    dos_init            ; DOS
     IMPORT    secb_ext            ; DOS
     XREF      iniddev1
     XREF      iniddev2
     XREF      deleddev
	XDEF act_pd

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

;Import vom VDI

     IMPORT    vdi_conout          ; VDI: Bconout(CON)
     IMPORT    vdi_rawout          ; VDI: Bconout(RAWCON)
     IMPORT    vdi_cursor          ; VDI: Cursorblinken
     IMPORT    int_linea           ; VDI: LineA- Interrupt
     IMPORT    Blitmode            ; VDI
     IMPORT    vt_seq_e            ; VDI: Cursor ein
     IMPORT    vt_seq_f            ; VDI: Cursor aus
     IMPORT    vdi_init            ; VDI: initialisieren (fuer MXVDI)
     IMPORT    vdi_blinit          ; VDI: Blitterstatus initialisieren (d0)
     IMPORT    vt52_init           ; VDI: VT52 initialisieren
     IMPORT    cpu020              ; liegt im VDI

;Import vom IDE-Modul

     IMPORT    IDEIdentify         ;IDEIdentify (dev, &ide_daten)
     IMPORT    IDEInitDrive        ;IDEInitDrive (dev, ide_daten.heads, ide_daten.sectors_per_track, ide_daten.cylinders, 1)
     IMPORT    IDERead             ;IDERead (dev, sector, count, (void *)daten, &jiffies)
     IMPORT    IDEWrite            ;IDEWrite (unit device, ULONG sector, WORD count, void *data)

;Import von XFS95

     IFNE XFS95
     IMPORT    mpc_da              ; fuer MagiC-PC
     IMPORT    xfs95ini
     ENDIF

;Import von STD

     IMPORT    fast_clrmem
     IMPORT    date2str            ; void date2str( a0 = char *s, d0 = WORD date)
     IF   DEBUG
     XREF hexl,crlf
     ENDIF

;Import aus MATH.S

     IMPORT    _lmul

;----------------------------------------
     INCLUDE "lowmem.inc"
	 include "country.inc"
     INCLUDE "bios.inc"
     INCLUDE "dos.inc"
     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "hardware.inc"
     INCLUDE "debug.inc"
	 INCLUDE "..\dos\magicdos.inc"

	 INCLUDE "version.inc"

IF COUNTRY==COUNTRY_US
PALMODE equ 0
else
PALMODE equ 1
endc

;----------------------------------------

     IFNE HADES
_movecd equ $4e7a ; used for movec xx,dn
_movec  equ $4e7b ; used for movec d0,xx
_cacr   equ $0002
_itt0   equ $0004
_itt1   equ $0005
_dtt0   equ $0006
_dtt1   equ $0007
_pcr    equ $0808
     ENDC
cinva   equ $f4d8 ; cinva bc
cpusha  equ $f4f8 ; cpusha bc

;----------------------------------------

FDC_TIMEOUT    EQU  400            ; war vorher 300
;  FDC_TIMEOUT    EQU  600            ; fuer Julian

ALTGR          EQU  0                   ; keine AltGr-Unterstuetzung
ALT_NUMKEY     EQU  1
DEADKEYS       EQU  0
N_KEYTBL       EQU  9+DEADKEYS          ; 9 Tastaturtabellen

NCOOKIES  EQU  35

     OFFSET

dsb_track:    DS.W 1               ; Momentane Tracknummer
dsb_hdmode:   DS.W 1               ; 0 = DD / 3 = HD
dsb_seekrate: DS.W 1               ; 3 = HD / 0 = DD
dsb_sizeof:

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

fbpb_bpb:      DS.B $12                 /*   0: BPB                   */
fbpb_ntracks:  DS.W 1                   /* $12: Anzahl Tracks         */
fbpb_nsides:   DS.W 1                   /* $14: NSIDES                */
fbpb_nst:      DS.W 1                   /* $16: NSIDES * SPT          */
fbpb_spt:      DS.W 1                   /* $18: SPT                   */
fbpb_nhid:     DS.W 1                   /* $1a: NHID                  */
fbpb_serial:   DS.L 1                   /* $1c: char serial[3]        */
fbpb_msserial: DS.L 1                   /* $20: char msserial[4]      */
fbpb_sizeof:

     TEXT

;---------------------------------------------------------------
SCRNMALLOC        EQU 21
GEMDOS            EQU 1
XBIOS                         equ 14
SOUNDCMD                 equ 130
SETMODE                  equ 132
DEVCONNECT               equ 139
;---------------------------------------------------------------
;
; aktuelle Speicherbelegung (8.10.95):
; VDI ab $1200
; DOS ab $2900
;
;---------------------------------------------------------------


;Geraetevektoren
_is_aux           EQU $0522               ;Bconstat fuer AUX

BUS_ERR           EQU 8

;--------------------------------------------------------------
;
; BIOS- Variablen:

clear_area          EQU $9a4            /* war vorher auf $98c        */

     OFFSET clear_area

bpbx:               DS.B 2*fbpb_sizeof
_rtrycnt:           DS.W 1              /* int                        */
wpstat:             DS.B 2              /* char [2]                   */
wplatch:            DS.W 1              /* wplatch fuer A: und B:      */
                    DS.L 2              /* acctim fuer A: und B:       */
maxacctim:          DS.L 1              /* long   fuer Floppy          */
motoronflg:         DS.B 1              /* char                       */
deslflg:            DS.B 1              /* char deslflg               */
current_disk:       DS.W 1              /* int  current_disk          */
cdev:               DS.W 1              /* int  cdev                  */
ctrack:             DS.W 1              /* int  ctrack                */
csect:              DS.W 1              /* int  csect                 */
cside:              DS.W 1              /* int  cside                 */
ccount:             DS.W 1              /* int  ccount                */
cdma:               DS.L 1              /* void *cdma                 */
flpfmt_spt:         DS.W 1              /* int  flpfmt_spt            */
flpfmt_intlv:       DS.W 1              /* int  flpfmt_intlv          */
flpfmt_vrgn:        DS.W 1              /* int  flpfmt_vrgn           */
_deferror:          DS.W 1              /* int                        */
_cerror:            DS.W 1              /* int  _cerror               */
dsb0:               DS.B dsb_sizeof     /* DSB fuer Floppy A           */
dsb1:               DS.B dsb_sizeof     /* DSB fuer Floppy B           */
flptimeout:         DS.L 1              /* Timeout fuer den FDC        */
mediach_statx:      DS.B 2              /* char mediach_statx[2]      */

rtclockbuf1:        DS.B 13             /* char [13]                  */
rtclockbuf2:        DS.B 13             /* char [13]                  */
p_iorec_ser1:       DS.L 1              /* IOREC *p_iorec_ser1        */
p_iorec_ser2:       DS.L 1              /* IOREC *p_iorec_ser2        */
p_iorec_sccb:       DS.L 1              /* IOREC *p_iorec_sccb        */
p_iorec_scca:       DS.L 1              /* IOREC *p_iorec_scca        */
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
iorec_midi:         DS.B $e             /* IOREC ($e Bytes)           */
iorec_midi_buf:     DS.B 128            /* char [128]                 */
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
pack_state:         DS.B 7              /* char [7]                   */
pack_absmouse:      DS.B 5              /* char [5]                   */
pack_relmouse:      DS.B 3              /* char [3]                   */
pack_clock:         DS.B 6              /* char [6]                   */
pack_joy:           DS.B 3              /* char [3],$fe/$ff,joy0,joy1 */
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
ikbdclock_flag:     DS.B 1              /* char                       */
hd_flag:            DS.B 1              /* char                       */
     EVEN
ctrl_status:        DS.W 1              /* char ctrl_status[2]        */
                                        /* erstes Byte: einschalten   */
                                        /* Bit 7: CTRL-C              */
                                        /* Bit 1: CTRL-S/CTRL-Q       */
timedate:           DS.L 1              /* long                       */
keytblx:            DS.L N_KEYTBL       /* char *keytblx[9 !!!]       */
default_keytblxp:   DS.L 1              /*  Zeiger auf Defaults       */
prt_last_timeout:   DS.L 1              /* long                       */
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
ptr_frb:            DS.L 1              /* ggf. Zeiger auf 64k Puffer      */
ttram_md:           DS.L 4              /* MD fuer TTRAM-Block              */
     IFNE FALCON
scrbuf_adr:         DS.L 1              /* Startadresse (netto, ohne MCB)  */
scrbuf_len:         DS.L 1              /* tatsaechliche Laenge              */
     ENDIF
flp_fstbuf:         DS.L 1              /* Zeiger fuer Floppy -> TT-RAM     */
flp_fstcnt:         DS.W 1              /* Zaehler fuer Floppy -> TT-RAM     */
flp_led_out:        DS.L 1              /* LED brutal abwuergen             */
pe_slice:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
pe_timer:           DS.W 1              /* fuer XAES (Zeitscheibe)          */
first_sem:
dma_sem:            DS.B bl_sizeof      /* Semaphore fuer ACSI/FDC          */
ncr_sem:            DS.B bl_sizeof      /* Semaphore fuer SCSI              */
imfp7_unsel:        DS.L 1              /* fuer MFP- Interrupt 7 (DMA busy) */
imfp7_appl:         DS.L 1              /* dito                             */
ncrdma_unsel:       DS.L 1              /* fuer SCSI-DMA                    */
ncrdma_appl:        DS.L 1              /* dito                             */
app0:               DS.L 1              /* APP #0 und Default- Superstack  */
pgm_superst:        DS.L 1              /* Default- Superstack             */
p_mgxinf:                               /* nicht glchztg. mit pgm_userst   */
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
                    DS.W 1         /* Laenge der folgenden Tabelle */
hddrv_tab:          DS.L 6
_scsi_cmdbuf:       DS.B 10
_scsi_wrflag:       DS.B 2
warmbvec:           DS.L 1         /* Sprungadr. fuer Ctrl-Alt-Del     */
coldbvec:           DS.L 1         /* Sprungadr. fuer Ctrl-Alt-Rsh-Del */
sust_len:           DS.L 1         ;Supervisorstack pro Applikation
datemode:           DS.W 1         ;fuer date2str (->STD.S)
clocktype:          DS.W 1         ; 0 = IKBD 1 = MegaST 2 = TT/Falcon
log_fd:             DS.L 1              /* DateiHandle fuer Bootlog */
log_fd_pd:          DS.L 1              /* Prozessdeskriptor fuer Handle */
log_oldconout:      DS.L 1              /* Alter Vektor fuer Bootlog */
p_vt52:             DS.L 1              /* fuer VT52.PRG */

ideparm:            DS.W 16        ;IDE_PARAM ideparm[2];
monitor:            DS.W 1
modecode:           DS.W 1
palette_ptr:        DS.L 1         ;Zeiger auf LONG p[256]
palette_first:      DS.W 1         ;Index des ersten zu aendernden Eintrags
palette_last:       DS.W 1         ;Index des letzten zu aendernden Eintrags

_dsp_rcv_ptr:       DS.L 1         ;Zeiger auf Empfangs-IR-Routine
_dsp_tmt_ptr:       DS.L 1         ;Zeiger auf Sende-IR-Routine
_dsp_tmtbuf_ptr:    DS.L 1         ;Enthaelt Zeiger auf Sendedaten fuer den DSP
_dsp_rcvbuf_ptr:    DS.L 1         ;Enthaelt Zeiger auf Empfangsdaten des DSP
_dsp_tmtsize:       DS.L 1         ;Groesse des Sendeblocks
_dsp_rcvsize:       DS.L 1         ;Groesse des Empfangsblocks
_dsp_num_tmtblks:   DS.L 1         ;Anzahl der zu bearbeitenden Sendebloecke
_dsp_num_rcvblks:   DS.L 1         ;Anzahl der zu bearbeitenden Empfangsbloecke
_dsp_tmtblks_done_ptr:   DS.L 1    ;Zeiger auf Anzahl der schon erledigten Sendebloecke
_dsp_rcvblks_done_ptr:   DS.L 1    ;Zeiger auf Anzahl der schon erledigten Empfangsbloecke
_dsp_subs:               DS.L 24   ;Array mit Struktur, die Adr(L), Groesse(L), Handle(W) und Ability(W) der Subroutinen enthaelt
;Groesse der Strukturelemente: 12 Bytes; Anzahl: 8

_dsp_avail_pmem:    DS.L 1         ;verfuegbare    P-Speicher
_dsp_max_avail_mem: DS.L 1
_dsp_xreserve:      DS.L 1         ;xreserve + $4000
_dsp_ability:       DS.W 1         ;(W) Ability der aktuellen Subroutine
_dsp_free_subridx:  DS.W 1    ;(W) Index des naechsten (freien oder frei zu machenden) Eintrags in Subr.-Array
_dsp_uniqueability: DS.W 1    ;(W)

_dsp_lock:          DS.W 1         ;(W) -1:locked, 0: unlocked
;_dsp_codebuf und _dsp_subr_adr muessen in dieser Form hintereinander stehen!
_dsp_codebuf:       DS.B 21        ;Platz fuer 24 DSP-Worte = 72 Bytes, Ende bei $1829
_dsp_subr_adr:      DS.B 48        ;16 DSP-Worte mit Adressen von Subroutinen, Ende bei $1826
                    DS.B 3         ;davon je 3 Bytes Opcode, 3 Bytes Adresse
;
;Falcon-Soundsystem
;
_snd_ch_att:        DS.W 1    ;(W)
_snd_lock:          DS.W 1

;
; MagicPC
;

magic_pc:           DS.L 1         ; Rueckgabewert von mpc_da()

;
; Hades
;

IF HADES
rwflag:             DS.B 1         ; lesen=0 schreiben=1
                    DS.B 1         ; lesen=0 verify=1 Daten ungl.bei Ver.=2
cbuffer:            DS.L 1         ; L: zeigt auf Puffer fuer DMA
verifyflag:         DS.W 1         ; W: 0 = Sektortest. <> 0 = verify
cfiller:            DS.L 1         ; L: (Format)
regsave:            DS.L 16        ; L: zeigt auf gesicherte Register
status_buffer:      DS.B 8         ; max. 7 Bytes bis $1838
ENDIF

__e_bios:

IF __e_bios > $1199
   error "bios variables overflow"
ENDIF



     TEXT


_start:
; nur fuer PASM

        MC68030
        MC68881
        SUPER

syshdr:
 bra.b    syshdr_code
 DC.W     $0200               ; MagiX: Versionsnummer 2.00
 DC.L     syshdr_code           ; Startadresse
 DC.L     syshdr              ; Anfangsadresse
 DC.L     __e_dos             ; Beginn des freien RAMs
 DC.L     syshdr_code
 DC.L     gem_magics          ; GEM- Parameterblock
 DC.L     D_BCD               ; USA-Format!
 DC.W     COUNTRY+COUNTRY+PALMODE
 DC.W     D_DOSDATE           ; Datum im GEMDOS- Format
 DC.L     _mifl_unused        ; _root
 DC.L     kbshift
 DC.L     act_pd              ; _run
 DC.L     0

; referenced by MXVDIKNL
MSys:
  EXPORT MSys


syshdr_code:
     IFNE HADES
 move.w   #$2700,sr
 reset
 move.l   #$807fc040,d0       ; transparent 2: $8000'0000-ffff'ffff =
                              ;  no cache serialized
 DC.W     _movec,_dtt1
 DC.W     _movec,_itt1
 move.l   #$7fc040,d0         ; no cache serialized
 DC.W     _movec,_dtt0        ; transparent translation daten 0
 move.l   #$7fc000,d0         ; instruction = write trough
 DC.W     _movec,_itt0        ; transparent translation intstruction 0
 clr.l    d0                  ; Cache aus
 DC.W     _movec,_cacr        ; Cache setzen
 DC.W     cinva               ; caches invalid
 DC.W     _movec,$801         ; VBR = 0
 move.l   #$210,d0
 DC.W     _movec,3            ;setze no cache, precise fuer mc68060
;                             ;    (geht auch fuer mc68040)
 clr.b    dma_sctr2           ;vme int off, scsi count0/eop und buserror off
     ELSE
 move     #$2700,sr
 move.w   #$100,$ffff8606          ; 3.06: DMA-Write an Peripherie
 move.w   #0,$ffff8606             ; 3.06: DMA-Read (nur Leitung geklappert)
 cmpi.l   #$fa52235f,$fa0000       ; Diagnostic cartridge ?
 bne.b    syshdr_l1                ; nein
 lea      syshdr_l1(pc),a6
 jmp      $fa0004                  ; Cartridge starten

* PMMU abschalten

syshdr_l1:
 lea      endofvars,sp             ; Hier Stack setzen wegen ggf. Exception
 lea      bot_ok1(pc),a0
 move.l   a0,8                     ; Busfehler
 move.l   a0,$10                   ; Illegaler Befehl
 move.l   a0,$2c                   ; Line-F
 moveq    #0,d0
 movec    d0,vbr                   ; fuer 68010/20/30
 move.l   #$808,d0                 ; instr/data-cache off/clear
 movec    d0,cacr                  ; fuer 68020/30
 pmove    long_zero,tc             ; fuer 68030: disable translation
 pmove    long_zero,tt0            ; keine pc-relative Adr. wg. PASM/MASM-Fehler
 pmove    long_zero,tt1
 frestore long_zero                ; fuer 68882
bot_ok1:


* BIOS- Variablenbereich loeschen
 lea      clear_area,a0
 lea      __e_dos.l,a1
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

 lea      endofvars,sp             ; Hier Stack nochmal setzen
 move.w   #6,stack_offset
 jsr      get_cpu_typ

;fuer MATH.S:

 clr.w    cpu020                   ; 68020-Arithmetik moeglich?
 cmpi.b   #20,d0
 bcs.b    scpu_typ
 addq.w   #1,cpu020                ; mindestens 020-Prozessor
scpu_typ:
 move.w   d0,cpu_typ
 beq.b    inst_cook
 move.w   #8,stack_offset
inst_cook:
 jsr      install_cookies

 bsr      boot_dsel_floppies            ; Floppies deselektieren

 bsr      boot_init_video               ; Videosystem initialisieren

* Beginn der TPA setzen (je nachdem, ob GEM enthalten ist)

 movea.l  syshdr+os_magic(pc),a0        ; Zeiger auf GEM- Parameterblock
 cmpi.l   #$87654321,(a0)+              ; gueltig ?
 beq.b    bot_aestpa                    ; ja
 lea      syshdr+os_membot(pc),a0       ; TPA- Daten ohne AES
bot_aestpa:
 move.l   (a0)+,end_os
 move.l   (a0),exec_os

* Installation einiger Exceptionvektoren fuer Disk und Ausgabe

 move.l   #flp_hdv_init,hdv_init
 move.l   #flp_rwabs,hdv_rw
 move.l   #flp_getbpb,hdv_bpb
 move.l   #flp_mediach,hdv_mediach
 move.l   #flp_boot,hdv_boot
 move.l   #FDC_TIMEOUT,flptimeout
 move.l   #bcostat_prt,prv_lsto
 move.l   #bconout_prt,prv_lst
 move.l   #bcostat_ser1,prv_auxo   ; immer ST_MFP
 move.l   #bconout_ser1,prv_aux
 move.l   #do_hardcopy,scr_dump    ; MagiC 3.0: Dummy-Routine
 move.l   #do_hardcopy,prtblk_vec  ; MagiC 3.0: Dummy-Routine

* Initialisierung des FRB sowie end_os und _membot
* Der FRB-Cookie wird nur angelegt, wenn beim Booten TT-RAM vorhanden ist.
*  Bei nachtraeglicher Anmeldung von alternativem RAM ueber Maddalt() wird der
*  Cookie nicht (!) angelegt (zu umstaendlich).

 clr.l    ptr_frb                  ; Default: kein alternatives RAM
 move.l   end_os,d0
 cmpi.l   #$1357bd13,ramvalid      ; TT-RAM gueltig ?
 bne.b    bot_nofast               ; nein, wir brauchen keinen FRB
 move.l   d0,ptr_frb               ; fuer Floppytreiber merken
 move.l   d0,-(sp)
 bsr      bmada_cook               ; Cookie eintragen
 move.l   (sp)+,d0
 add.l    #$10000,d0               ; ist 64K lang
 move.l   d0,end_os                ; nicht noetig, aber 3.06 will es so
bot_nofast:
 move.l   d0,_membot

* weitere Initialisierungen

 move.w   #8,nvbls
 st       _fverify
 move.w   #3,seekrate
 move.w   #-1,_dumpflg
 move.w   #-1,pe_slice             ; Zeitscheibensteuerung abschalten
 clr.l    act_appl                 ; single task

* Funktionen fuer Plattentreiber

 move.l   #'_DMA',dma_sem+bl_name  ; ACSI/FDC- Semaphore initialisieren
 move.l   #'_NCR',ncr_sem+bl_name  ; SCSI- Semaphore
 move.l   #ncr_sem,dma_sem+bl_next
 lea      hddrv_tab-2,a0           ; Tabellenlaenge
 move.w   #6,(a0)+                 ; 6 Zeiger
 move.l   a0,hddf_vector           ; Cookie -> Tabelle
 lea      _acsi_begin(pc),a1
 move.l   a1,(a0)+
 lea      _acsi_end(pc),a1
 move.l   a1,(a0)+
 lea      _wait_ACSI(pc),a1
 move.l   a1,(a0)+
 lea      _ncr_begin(pc),a1
 move.l   a1,(a0)+
 lea      _ncr_end(pc),a1
 move.l   a1,(a0)+
 lea      _wait_NCR(pc),a1
 move.l   a1,(a0)

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

* unbenutzte oder Bomben- Exceptionvektoren initialisieren

 lea      only_rte(pc),a3
 lea      dummyfn(pc),a4
 lea      8,a0
; FIXME: might need adjustment for CT60
 moveq    #$3d,d0
 lea      exc02(pc),a1
 move.l  #exc03-exc02,d1

* Benutzte Exceptionroutinen initialisieren

 cmpi.l   #$fa52235f,$fa0000
 beq.b    bot_l1
; FIXME: might need adjustment for CT60
 moveq    #$3d,d0
bot_loop:
 move.l   a1,(a0)+
 adda.l   d1,a1
 dbf      d0,bot_loop
bot_l1:
 move.l   a3,$14                   ; Division durch 0
 tst.w    cpu_typ
 beq.b    excp_00                  ; 68000: priv.viol. bringt Bomben

;
; 68010/20/30/40/60: move sr,xx emulieren
;

 lea      my_priv_exception(pc),a2
 move.l   a2,$20                   ; Privilege violation

;
; 68060: jede Menge Schweinkram (hier nur fuer den Hades einbinden)
;

     IFNE HADES
 cmp.w    #60,cpu_typ              ; 68060: movep bringt Bomben!
 bcs.b    excp_00
 move.l   #unim_int_instr,$f4.w
 move.l   #xFP_CALL_TOP+$80+$30,$2c.w   ;fline
 move.l   #xFP_CALL_TOP+$80+$00,$d8.w   ;snan
 move.l   #xFP_CALL_TOP+$80+$08,$d0.w   ;operr
 move.l   #xFP_CALL_TOP+$80+$10,$d4.w   ;overflow
 move.l   #xFP_CALL_TOP+$80+$18,$cc.w   ;underflow
 move.l   #xFP_CALL_TOP+$80+$20,$c8.w   ;divide by zero
 move.l   #xFP_CALL_TOP+$80+$28,$c4.w   ;inex
 move.l   #xFP_CALL_TOP+$80+$38,$dc.w   ;unsupp
 move.l   #xFP_CALL_TOP+$80+$40,$f0.w   ;effadd
 DC.L     $f23c,$9000,0,0               ;fmove.l #0,fpcr
     ENDIF

;
; Weiter mit der Initialisierung
;

excp_00:
 moveq    #6,d0
 lea      $64,a1                   ; Autovektor- Interrupt Levels 1..7
bot_loop2:
 move.l   a3,(a1)+
 dbf      d0,bot_loop2

 move.w   #-1,palette_last.w       ; Palette fuer den Falcon nicht aendern!

 move.l   #BiosDisp,$b4            ; BIOS
 move.l   #XBiosDisp,$b8           ; XBIOS
 move.l   #int_vbl,$70             ; VBL
     IFNE HADES
 move.l   #scsi_int2,$68.w         ; Hades-SCSI-DMA-Emu
     ELSE
 move.l   #int_hbl,$68.w           ; HBL
     ENDIF
 move.l   a3,$88.w                 ; Trap #2      (Dummy)
 move.l   #int_linea,$28.w         ; Line-A

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

* Devicevektoren initialisieren

 lea      ori_dev_vecs(pc),a0      ; ROM-Geraetevektoren
 lea      dev_vecs,a1
 lea      mbiosvecs,a2
 moveq    #$1f,d0
bot_loop4:
 move.l   (a0),(a1)+
 move.l   (a0)+,(a2)+
 dbf      d0,bot_loop4

* TOS 2.05 hat folgende Initialisierung:

 movea.l  8,a0
 movea.l  sp,a1
 move.l   #bot_l2,8
 move.b   #$40,$ffff8e0d           ; VME Interrupt Mask
 move.b   #$14,$ffff8e01           ; System Interrupt Mask
bot_l2:
 move.l   a0,8
 movea.l  a1,sp

* MFP und Vektoren initialisieren

 bsr      init_mfp

 move.w   #$400,d0
 bsr      timerA_delay             ; TOS 2.05

* IKBD initialisieren

 moveq    #$ffffff80,d1            ; Byte $80
 bsr      _bconout_ikbd
 moveq    #1,d1                    ; Byte $01
 bsr      _bconout_ikbd

 move.w   #$700,d0                 ; TOS 2.05:
 move.w   #$e,d1
bot_l3:
 bsr      timerA_delay             ; TOS 2.05
 dbf      d1,bot_l3

* Cartridge testen

;    IFEQ HADES
 moveq    #2,d0
 bsr      cartscan
;    ENDIF

; Aufloesung setzen (MagiX)

     IFNE HADES
 move.b   #2,sshiftmd.w            ; Aufloesung: ST-High
     ELSE
 cmpi.b   #4,machine_type          ; Falcon?
 bne.b    bot_ressttt              ; nein, ST oder TT

 move.l   #1024+32,d0              ; 4*256 Bytes Palette + 2*16 fuer ST-Shifter
 bsr      Bmalloc
 move.l   a0,palette_ptr.w
 clr.w    palette_first.w
 move.w   #-1,palette_last.w       ; Palette nicht aendern

 move.b   sshiftmd.w,d1
 bra.b    bot_resol_ok

bot_ressttt:
 lea      $ffff8260,a0             ; ST: Register $ffff8260
 moveq    #1,d1                    ; ST: Default- Farbaufloesung: ST-Mittel
 moveq    #2,d2                    ; ST: Default- SW: ST-Hoch
 cmpi.b   #3,machine_type
 bcs.b    bot_res_st
 addq.l   #2,a0                    ; TT: Register $ffff8262
 moveq    #4,d1                    ; TT: Default- Farbaufloesung: TT-Mittel
 moveq    #6,d2                    ; TT: Default- SW: TT-Hoch
bot_res_st:
 move.b   (a0),d0                  ; d0 = aktuelle Aufloesung
 tst.b    gpip
 bmi.b    bot_res_col
 move.b   d2,d1                    ; monochrome detect

bot_res_col:
 cmp.b    d1,d0
 beq.b    bot_resol_ok             ; Aufloesung stimmt schon!
 bsr      delay_special            ; Verzoegerung (TOS 2.05)
 move.b   d1,(a0)                  ; Aufloesung setzen
bot_resol_ok:
 move.b   d1,sshiftmd.w            ; und merken
     ENDIF

* Grafikausgabe initialisieren

 suba.l   a0,a0                    ; Behne-Wunsch 20.10.94 wg. Macintosh
 jsr      vdi_blinit               ; Blitterstatus des VDI initialisieren
                                   ; (fuer Atari VDI)
 move.w   modecode.w,d0
 jsr      vt52_init                ; VT52 initialisieren
 cmpi.b   #1,sshiftmd
 bne.b    bot_l4
 move.w   $ffff825e,$ffff8246      ; Farbreg. 15 -> Farbreg. 3   (???)
bot_l4:
 move.l   #syshdr_code,swv_vec       ; Monitorwechsel ist Reset
 move.w   #1,vblsem

* Cartridge testen

;    IFEQ HADES
 clr.w    d0
 bsr      cartscan
;    ENDIF

* Interrupts zulassen

     IFNE HADES
 move     #$2100,sr                ; Auf Hades: Auch HBL-Int zulassen: SCSI
     ELSE
 move     #$2300,sr
     ENDIF

* Cartridge testen

; FIXME: boot loader for CTPCI invokes trap #0 here

;    IFEQ HADES
 moveq    #1,d0
 bsr      cartscan
;    ENDIF

* DOS initialisieren, Supervisorstack und Diskpuffer anlegen

 move.l   #4096,d0
 bsr      Bmalloc
 move.l   a0,_dskbufp              ; _dskbufp = Malloc(4096L)

 move.l  #SUPERSTACKLEN,sust_len ; Groesse des Supervisorstacks pro App
 jsr      dos_init

     IFNE XFS95
 jsr      mpc_da                   ; fuer MagiC-PC
 move.l   d0,magic_pc              ; Rueckgabewert merken!
 beq.b    no_magic_pc
 jsr      xfs95ini
no_magic_pc:
     ENDIF

 move.w   #3,-(sp)                 ; lieber FastRAM
 lea      ap_stack,a0
 add.l    sust_len,a0
 move.l   a0,-(sp)                 ; APP #0 und Supervisorstack allozieren
 move.w   #$44,-(sp)               ; Mxalloc()
 trap     #GEMDOS
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
 trap     #GEMDOS
 addq.l   #2,sp
 tst.l    d0
 beq      fatal_err
 move.l   d0,pgm_userst            ; merken
 add.l    (sp)+,d0                 ; Stacklaenge addieren
 addq.l   #2,sp
 move.l   d0,a0
 move.l   a0,usp

; Uhrentyp erkennen (5.4.99)

 bsr      get_clocktype
 move.b   d0,clocktype

 bsr      init_dosclock

* Timer A initialisieren

 clr.b    tacr                ; Timer A: STOP
 bclr     #5,iera             ; Timer A (Busy bei ST)

* Prozessorcaches und PMMU initialisieren

 cmpi.w   #20,cpu_typ
 bcs.b    bot_cpu_weiter      ; 68000 oder 68010
 cmpi.w   #30,cpu_typ
 bcs.b    bot_cpu_nopmmu
 lea      $700,a0
 lea      pmmutab,a1
 moveq    #$3f,d0             ; 64 Langworte
bot_loop5:
 move.l   (a1)+,(a0)+         ; Tabelle initialisieren
 dbf      d0,bot_loop5
 pmove    pmmu_crp,crp       ; DC.W     $f039,$4c00,$00e3,$6520
 pmove    pmmu_tc,tc         ; DC.W     $f039,$4000,$00e3,$6528
 pmove    pmmu_tt0,tt0       ; DC.W     $f039,$0800,$00e3,$652c
 pmove    pmmu_tt1,tt1       ; DC.W     $f039,$0c00,$00e3,$6530
bot_cpu_nopmmu:
 move.l   #$3111,d0           ;     1: enable instruction cache
                              ;   $10: instruction burst enable
                              ;  $100: enable data cache
                              ; $1000: data burst enable
                              ; $2000: write allocate
 movec    d0,cacr
bot_cpu_weiter:

;
     IFEQ HADES
 cmp.b    #4,machine_type
 bne.b    try_ext_scsidrvr
 bsr      dsp_stdinit              ;DSP-Code hochladen

;Falcon-Soundhardware initialisieren
 move.w   #1,-(sp)                 ;kein Handshake
 clr.w    -(sp)                    ;prescale = 0 -> nutze Compatibility mode
 clr.w    -(sp)                    ;interne 25.175 MHz-Clock
 move.w   #8,-(sp)                 ;dst = DAC
 clr.w    -(sp)                    ;src = DMAPLAY
 move.w   #DEVCONNECT,-(sp)
 trap     #XBIOS
 lea      12(sp),sp

 clr.w    -(sp)                    ;8 Bit Stereo
 move.w   #SETMODE,-(sp)
 trap     #XBIOS
 addq.l   #4,sp

;Setze Verstaerkung der Eingabekanaele
 move.w   #64,-(sp)                ;9 db Verstaerkung
 move.w   #2,-(sp)                 ;linker Kanal
 move.w   #SOUNDCMD,-(sp)
 trap     #XBIOS

 move.w   #3,2(sp)                 ;rechter Kanal
 trap     #XBIOS
 addq.l   #6,sp

;Setze Vorteiler (wobei <Compatiblity mode> fuer devconnect(DMAPLAY)
; vorausgesetzt wird)
 move.w   #3,-(sp)                 ;50 kHz
 move.w   #6,-(sp)                 ;SETPRESCALE
 move.w   #SOUNDCMD,-(sp)
 trap     #XBIOS

;Verknuepfe 16 Bit-Addierer der Sound-Hardware mit der
; Sound-Matrix und ADC (Bit 1 + 0)
 move.w   #4,2(sp)                 ;ADDERIN
 trap     #XBIOS

;Verknuefe Eingang des ADC mit linkem und rechtem Kanal des PSD   (Bit 1 + 0)
 move.w   #5,2(sp)                 ;ADCINPUT
 trap     #XBIOS
 addq.w   #6,sp

;Bootroutinen (nach wie vor gilt: sp == endofvars)
try_ext_scsidrvr:
     ENDIF

;Test auf SCSI-RAM. Setze Busfehlervektor fuer den Fall, dass die
; Systemvariable $868 Schrott enthalten sollte.
 movea.l  8.w,a0
 movea.l  sp,a1
 move.l   #no_scsiram,8.w          ;Busfehlervektor setzen

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
 move.l   hdv_rw,-(sp)
 bsr      dskboot                  ; von Floppy booten
 move.l   (sp)+,a0
 cmpa.l   hdv_rw,a0
 bne.b    boot_no_dma              ; hat schon von Floppy gebootet

     IFNE HADES
 move.b   #4,machine_type          ; Booten von IDE erzwingen?!?
 bsr      dmaboot                  ; von SCSI und ACSI booten
 jsr      secb_ext                 ; (Sektorpufferliste!)
 move.b   #3,machine_type          ; wieder TT eintragen
     ELSE
 bsr      dmaboot                  ; von SCSI und ACSI booten
 jsr      secb_ext                 ; (Sektorpufferliste!)
     ENDIF

boot_no_dma:
 bsr      exec_respgms             ; residente Programme ausfuehren

;Das VDI muss nach dem DMA-Boot initialisiert werden, da es auf die HD zugreift
 jsr      vdi_init                 ; VDI initialisieren (MXVDI)

 move.l   pgm_userst,-(sp)         ; allozierten Userstack wieder freigeben
 move.w   #73,-(sp)                ; Mfree
 trap     #GEMDOS
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
 moveq   #EINVFN,d0
 rts

;-----------------------------------------------------------------------
     INCLUDE "..\..\bios\atari\modules\scsi.s"
     IFNE HADES
     INCLUDE "..\..\bios\atari\modules\had_fdc.s"
     ELSE
     INCLUDE "..\..\bios\atari\modules\fdc.s"
     ENDIF
     INCLUDE "..\..\bios\atari\modules\drive.s"
;-----------------------------------------------------------------------
     INCLUDE "..\..\bios\atari\modules\dsp.s"
;-----------------------------------------------------------------------

**********************************************************************
*
* void cartscan( d0 = int bitnr )
*
* zerstoert Register a0
*

     IFEQ HADES
cartscan:
 lea      $fffa0000,a0
 cmpi.l   #$abcdef42,(a0)+
 bne.b    cartscan_end
cartscan_loop:
 btst     d0,4(a0)
 beq.b    cartscan_skip
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
 move.l   4(a0),d0
 and.l    #$ffffff,d0              ; TOS 2.05
 movea.l  d0,a0
 jsr      (a0)
 movem.l  (sp)+,a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0
cartscan_skip:
 tst.l    (a0)
 movea.l  (a0),a0
 bne.b    cartscan_loop
cartscan_end:
 rts
     ELSE
cartscan:
 rts
     ENDIF


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
; Bei Gelegenheit spezielle VBL-Routinen fuer ST/TT/Falcon einbauen
int_vbl:
 addq.l   #1,_frclock              ; Anzahl aller VBLs mitzaehlen
 subq.w   #1,vblsem                ; VBL gesperrt ?
 bmi      ivbl_locked              ; ja, ende
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
 addq.l   #1,_vbclock              ; Anzahl aller VBL-Routinen mitzaehlen
     IFEQ HADES
 tst.b    machine_type
 beq.b    ivbl_st                  ; kein DMA-Sound !

 move     sr,-(sp)                 ; TOS 2.05
 ori      #$700,sr
ivbl_5loop:
 move.b   $ffff8901,d0             ; TOS 2.05: Sound DMA Control
 move.b   gpip,d1
 btst     #7,d1
 sne      d1                       ; d1 = monochrome detect
 move.b   gpip,d2
 btst     #7,d2
 sne      d2                       ; d2 = monochrome detect
 cmp.b    d1,d2                    ; identisch ?
 bne.b    ivbl_5loop               ; nein, nochmal
 cmp.b    $ffff8901,d0             ; ist sdc gleich geblieben ?
 bne.b    ivbl_5loop               ; nein, nochmal
 move     (sp)+,sr
 btst     #0,d0                    ; sound dma enabled?
 beq.b    ivbl_5inv                ; nein, normal
 not.b    d1                       ; ja, monochrome detect invertieren
ivbl_5inv:
 cmpi.b   #4,machine_type          ; Falcon?
 beq      ivbl_monitor_ok

ivbl_st_tt:
 cmpi.b   #3,machine_type
 bcs.b    ivbl_both                ; STE oder Mega STE
* TT
 move.b   $ffff8262,d0             ; TT shift mode
 and.b    #7,d0                    ; Aufloesung extrahieren
 cmp.b    #6,d0                    ; TT High ?
 beq.b    ivbl_l1                ; ja
 btst     #7,d1                    ; monochrome detect ?
 bne.b    ivbl_monitor_ok          ; nein
* Farbe, aber SW-Monitor
 bsr      _Vsync
 moveq    #6,d0                    ; auf TT High umschalten
 bra      ivbl_monitor_change
ivbl_l1:
 btst     #7,d1                    ; monochrome detect ?
 beq.b    ivbl_monitor_ok          ; ja
* SW, aber Farbmonitor
 move.b   $44a,d0                  ; defshiftmd
 cmp.b    #6,d0                    ; ist SW ? ###
 bne.b    ivbl_monitor_change      ; nein
 clr.b    d0                       ; ja, ST Low verwenden
 bra.b    ivbl_monitor_change
* ST,STE
ivbl_st:
 move.b   gpip,d1                  ; monochrom detect
ivbl_both:
 moveq    #3,d0
 and.b    $ffff8260,d0             ; Shifter- Modus
 subq.b   #2,d0                    ; Hardware auf Highres ?
 bge.b    ivbl_l2                ; ja
* Farbe
 tst.b    d1                       ; Bit 7, monochrom detect ?
 bmi.b    ivbl_monitor_ok          ; nein, Farbmonitor
* Farbe, aber SW- Monitor
 bsr      delay_special                ; TOS 2.05
ivbl_hires:
 moveq    #2,d0                    ; auf Highres
 bra.b    ivbl_monitor_change      ; Aufloesung umschalten
* SW
ivbl_l2:
 tst.b    d1                       ; Bit7, monochrom detect ?
 bpl.b    ivbl_monitor_ok          ; ja, ok
* SW, aber Farbmonitor
 move.b   defshiftmd,d0            ; gewuenschte Aufloesung
 cmp.b    #2,d0                    ; Highres ?
 blt.b    ivbl_monitor_change      ; nein
 clr.b    d0                       ; Lowres, wenn Highres gewuenscht
* Aufloesung umschalten
ivbl_monitor_change:
 move.b   d0,sshiftmd              ; neue Aufloesung merken
 move.b   d0,$ffff8260             ; neue Aufloesung setzen
 movea.l  swv_vec,a0
 jsr      (a0)                     ; Aufloesungsaenderungsvektor anspringen
ivbl_monitor_ok:
     ENDIF
 jsr      vdi_cursor               ; Cursorblinken
     IFEQ HADES
 move.w   palette_last.w,d1        ; Palette fuer den Falcon aendern?
 bmi.s    ivbl_setcolor

 move.w   palette_first.w,d0       ; erster zu aendernder Eintrag
 sub.w    d0,d1

 movea.l  palette_ptr.w,a0
 lea      $ffff9800.w,a1
 add.w    d0,d0
 add.w    d0,d0
 adda.w   d0,a0
 adda.w   d0,a1

ivbl_srgb_loop:
 move.l   (a0)+,d0                 ; xRGB
 rol.l    #8,d0
 rol.w    #8,d0
 move.l   d0,(a1)+                 ; RGxB
 dbra     d1,ivbl_srgb_loop

 move.w   #-1,palette_last.w       ; Palette ist gesetzt
 bra.b    ivbl_nocol

ivbl_setcolor:
 move.l   colorptr,d0
 beq.b    ivbl_nocol
 movea.l  d0,a0
 lea      $ffff8240,a1
 move.l   (a0)+,(a1)+              ; 16 Farbeintraege (32 Bytes) kopieren
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)+
 clr.l    colorptr
ivbl_nocol:
 move.l   screenpt,d0
 beq.b    ivbl_l3
 move.l   d0,_v_bas_ad
 move.b   d0,$ffff820d             ; STe
 lsr.l #8,d0
 lea      $ffff8201,a1             ; low byte
 movep.w    d0,0(a1)
 clr.l    screenpt
ivbl_l3:
     ENDIF
 bsr      floppy_vbl
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
 andi     #$fbff,sr           ; !!!
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
 DC.W     142
 DC.L     Initmous            ; 0
 DC.L     not_implemented     ; 1=Ssbrk
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
 DC.L     Puntaes           ; 39, Puntaes
 DC.L     not_implemented
 DC.L     Floprate            ; 41
 DC.L     DMAread             ; 42
 DC.L     DMAwrite            ; 43
 DC.L     Bconmap             ; 44
 DC.L     not_implemented
 DC.L     NVMaccess           ; 46
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     Blitmode            ; 64
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented     ; 70
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented     ; 75
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     not_implemented
 DC.L     Esetshift           ; 80
 DC.L     Egetshift           ; 81
 DC.L     Esetbank            ; 82
 DC.L     Esetcolor           ; 83
 DC.L     Esetpalette         ; 84
 DC.L     Egetpalette         ; 85
 DC.L     Esetgray            ; 86
 DC.L     Esetsmear           ; 87
;
;Falcon-Video
   DC.L  Vsetmode             ;88
   DC.L  mon_type             ;89
   DC.L  VsetSync             ;90
   DC.L  VgetSize             ;91
   DC.L  not_implemented
   DC.L  VsetRGB              ;93
   DC.L  VgetRGB              ;94
     DC.L     not_implemented
;Falcon DSP/Soundsystem 96-141
     dc.l Dsp_DoBlock
     dc.l Dsp_BlkHandShake
     dc.l Dsp_BlkUnpacked
     dc.l Dsp_InStream
     dc.l Dsp_OutStream
     dc.l Dsp_IOStream
     dc.l Dsp_RemoveInterrupts
     dc.l Dsp_GetWordSize
     dc.l Dsp_Lock
     dc.l Dsp_Unlock
     dc.l Dsp_Available
     dc.l Dsp_Reserve
     dc.l Dsp_LoadProg
     dc.l Dsp_ExecProg
     dc.l Dsp_ExecBoot
     dc.l Dsp_LodToBinary
     dc.l Dsp_TriggerHC
     dc.l Dsp_RequestUniqueAbility
     dc.l Dsp_GetProgAbility
     dc.l Dsp_FlushSubroutines
     dc.l Dsp_LoadSubroutine
     dc.l Dsp_InqSubrAbility
     dc.l Dsp_RunSubroutine
     dc.l Dsp_Hf0
     dc.l Dsp_Hf1
     dc.l Dsp_Hf2
     dc.l Dsp_Hf3
     dc.l Dsp_BlkWords
     dc.l Dsp_BlkBytes
     dc.l Dsp_HStat
     dc.l Dsp_SetVectors
     dc.l Dsp_MultBlocks
     dc.l locksnd
     dc.l unlocksnd
     dc.l soundcmd
     dc.l setbuffer
     dc.l setmode
     dc.l settracks
     dc.l setmontracks
     dc.l setinterrupt
     dc.l buffoper
     dc.l dsptristate
     dc.l gpio
     dc.l devconnect
     dc.l sndstatus
     dc.l buffptr

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
not_implemented:
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

ori_dev_vecs:
 DC.L     ret0                     ; Bconstat(0)       PRT
 DC.L     bconstat_ser1            ;                   AUX
 DC.L     bconstat_con             ;                   CON
 DC.L     bconstat_midi            ;                   MIDI
 DC.L     dummyfn                  ;                   IKBD
 DC.L     dummyfn                  ;                   RAWCON
 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bconin_prt               ; Bconin(0)         PRT
 DC.L     bconin_ser1              ;                   AUX
 DC.L     bconin_con               ;                   CON
 DC.L     bconin_midi              ;                   MIDI
 DC.L     dummyfn                  ;                   IKBD
 DC.L     dummyfn                  ;                   RAWCON
 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bcostat_prt              ; Bcostat(0)        PRT
 DC.L     bcostat_ser1             ;                   AUX
 DC.L     bcostat_con              ;                   CON
 DC.L     bcostat_ikbd             ;                   MIDI (!!!)
 DC.L     bcostat_midi             ;                   IKBD (!!!)
 DC.L     dummyfn                  ;                   RAWCON

 DC.L     dummyfn
 DC.L     dummyfn
 DC.L     bconout_prt              ; Bconout(0,c)      PRT
 DC.L     bconout_ser1             ;                   AUX
 DC.L     vdi_conout               ;                   CON
 DC.L     bconout_midi             ;                   MIDI
 DC.L     bconout_ikbd             ;                   IKBD
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
 cmpi.l   #$1357bd13,ramvalid   ; TT-RAM gueltig ?
 bne.b    gmp_ende            ; nein, Ende
 move.l   fstrm_beg,d0
 move.l   ramtop,d1
 sub.l    d0,d1               ; ramtop (Ende des TT-RAMs) <= sein Anfang
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
*
* MagiC 6:     Legt Cookie an, falls genuegend Platz im Jar
*

Bmaddalt:
 tst.l    ptr_frb        ; FRB schon da ?
 bne.b    bmada_ok       ; ja, return(E_OK)
 clr.w    -(sp)          ; nur ST-RAM
 move.l   #$10000,-(sp)  ; 64k Puffer
 move.w   #$44,-(sp)     ; gemdos Mxalloc()
 trap     #GEMDOS
 addq.l   #8,sp
 move.l   d0,ptr_frb     ; FRB setzen
 bne.b    bmada_cook     ; OK
 moveq    #ENSMEM,d0     ; Fehler, zuwenig Speicher
 rts
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
 bsr.s    putch
 moveq    #$a,d0
 bsr.s    putch
 moveq    #$a,d0                   ; CR,LF,LF
 bsr.s    putch
 bsr.b    putstr                   ; Benutzermeldung
 lea      fatal_errs(pc),a0
 bsr      putstr                   ; "System angehalten"
halt_endless:
 bra      halt_endless

putstr:
 move.b   (a0)+,d0
 beq.b    puts_ende
 bsr      putch
 bra.b    putstr
puts_ende:
 rts

putch:
 move.l	a2,-(sp)				; wg. PureC
 andi.w   #$00ff,d0
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 move.w   #2,-(sp)                 ; CON
 move.l   dev_vecs+$68,a0          ; Bconout CON
 jsr      (a0)
 addq.l   #4,sp
 move.l   (sp)+,a0
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* Exceptionvektoren 2 bis 64 (d.h. 62 Stueck)
*

exc02:    move.b    #2,-(sp)
          bra.w     exc
exc03:    move.b    #3,-(sp)
          bra.w     exc
          GLOBL exc04
exc04:    move.b    #4,-(sp)
          bra.w     exc
exc05:    move.b    #5,-(sp)
          bra.w     exc
exc06:    move.b    #6,-(sp)
          bra.w     exc
exc07:    move.b    #7,-(sp)
          bra.w     exc
exc08:    move.b    #8,-(sp)
          bra.w     exc
exc09:    move.b    #9,-(sp)
          bra.w     exc
exc10:    move.b    #10,-(sp)
          bra.w     exc
exc11:    move.b    #11,-(sp)
          bra.w     exc
exc12:    move.b    #12,-(sp)
          bra.w     exc
exc13:    move.b    #13,-(sp)
          bra.w     exc
exc14:    move.b    #14,-(sp)
          bra.w     exc
exc15:    move.b    #15,-(sp)
          bra.w     exc
exc16:    move.b    #16,-(sp)
          bra.w     exc
exc17:    move.b    #17,-(sp)
          bra.w     exc
exc18:    move.b    #18,-(sp)
          bra.w     exc
exc19:    move.b    #19,-(sp)
          bra.w     exc
exc20:    move.b    #20,-(sp)
          bra.w     exc
exc21:    move.b    #21,-(sp)
          bra.w     exc
exc22:    move.b    #22,-(sp)
          bra.w     exc
exc23:    move.b    #23,-(sp)
          bra.w     exc
exc24:    move.b    #24,-(sp)
          bra.w     exc
exc25:    move.b    #25,-(sp)
          bra.w     exc
exc26:    move.b    #26,-(sp)
          bra.w     exc
exc27:    move.b    #27,-(sp)
          bra.w     exc
exc28:    move.b    #28,-(sp)
          bra.w     exc
exc29:    move.b    #29,-(sp)
          bra.w     exc
exc30:    move.b    #30,-(sp)
          bra.w     exc
exc31:    move.b    #31,-(sp)
          bra.w     exc
exc32:    move.b    #32,-(sp)
          bra.w     exc
exc33:    move.b    #33,-(sp)
          bra.w     exc
exc34:    move.b    #34,-(sp)
          bra.w     exc
exc35:    move.b    #35,-(sp)
          bra.w     exc
exc36:    move.b    #36,-(sp)
          bra.w     exc
exc37:    move.b    #37,-(sp)
          bra.w     exc
exc38:    move.b    #38,-(sp)
          bra.w     exc
exc39:    move.b    #39,-(sp)
          bra.w     exc
exc40:    move.b    #40,-(sp)
          bra.w     exc
exc41:    move.b    #41,-(sp)
          bra.w     exc
exc42:    move.b    #42,-(sp)
          bra.w     exc
exc43:    move.b    #43,-(sp)
          bra.w     exc
exc44:    move.b    #44,-(sp)
          bra.w     exc
exc45:    move.b    #45,-(sp)
          bra.w     exc
exc46:    move.b    #46,-(sp)
          bra.w     exc
exc47:    move.b    #47,-(sp)
          bra.w     exc
exc48:    move.b    #48,-(sp)
          bra.w     exc
exc49:    move.b    #49,-(sp)
          bra.w     exc
exc50:    move.b    #50,-(sp)
          bra.w     exc
exc51:    move.b    #51,-(sp)
          bra.w     exc
exc52:    move.b    #52,-(sp)
          bra.w     exc
exc53:    move.b    #53,-(sp)
          bra.w     exc
exc54:    move.b    #54,-(sp)
          bra.w     exc
exc55:    move.b    #55,-(sp)
          bra.w     exc
exc56:    move.b    #56,-(sp)
          bra.w     exc
exc57:    move.b    #57,-(sp)
          bra.w     exc
exc58:    move.b    #58,-(sp)
          bra.w     exc
exc59:    move.b    #59,-(sp)
          bra.w     exc
exc60:    move.b    #60,-(sp)
          bra.w     exc
exc61:    move.b    #61,-(sp)
          bra.w     exc
exc62:    move.b    #62,-(sp)
          bra.w     exc
exc63:    move.b    #63,-(sp)

exc:
     IFNE HADES
     INCLUDE "..\..\bios\atari\modules\had_exc.s"
     ELSE
 move.b   (sp)+,proc_pc            ; Vektornummer
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6/sp,proc_regs
 move     usp,a0
 move.l   a0,proc_usp
 moveq    #15,d0                   ; die obersten 16 Stack-Worte
 lea      proc_stk,a0
 movea.l  sp,a1
pb_loop:
 move.w   (a1)+,(a0)+
 dbf      d0,pb_loop
 move.l   #$12345678,proc_lives
 moveq    #0,d1
 move.b   proc_pc,d1
 subq.w   #1,d1
 bsr      __printbombs
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
 bsr      bconin_con
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
 trap     #GEMDOS
 bra      syshdr_code
     ENDIF


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
* void timerA_delay( d0 = long delay )
*

timerA_delay:
 bsr.b    tmadel_sub
tmadel_loop:
 btst     #5,ipra             ;Timer A (BUSY beim ST, Frame Ende bei TT): UeBERPRUeFEN!!
 beq.b    tmadel_loop
 clr.b    tacr                ;Timer A: STOP
 rts
tmadel_sub:
 move     sr,-(sp)
 ori      #$700,sr
 clr.b    tacr                ;Timer A: STOP
 bclr     #5,iera             ;Timer A (BUSY-Signal bei ST)
 move.b   #$df,ipra           ;IR-Pending loeschen
 bclr     #5,imra             ;IR Mask register
 bset     #5,iera             ;IR Enable setzen
 move     (sp)+,sr
 move.b   d0,tadr             ;Timer A Data Register
 ror.w    #8,d0
 move.b   d0,tacr             ;Bit [3..0]: Vorteiler, Bit 4: Timer Ausgang auf Low
 rol.w    #8,d0
 rts


**********************************************************************
*
* Wartet auf 240 Ereignisse von Timer B, dessen TBI immer dann
* auf High geht, wenn eine Bildschirmzeile geschrieben wird.
* Anschliessend wird gewartet, bis der Zaehlerstand 615mal konstant
* war. Wartet auf VBL ?
* Wird bei PAL- Modus und bei "monochrom detect" aufgerufen,
*

delay_special:
                                   ; aus TOS 2.05:
 bclr     #0,iera                  ; Timer B (display enable) aktivieren


**********************************************************************
*
* Wird von boot_init_video() aufgerufen
*

delay_special_b:
 move.b   #0,tbcr                  ; Timer B stoppen
 clr.b    tbdr                     ; 0 in den Abwaertszaehler
 move.b   #8,tbcr                  ; Ereigniszaehlung
delaysp_loop:
 tst.b    tbdr                     ; Abwaertszaehler auf 0 ?
 beq.b    delaysp_loop             ; ja, weiter
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
 lea      -6(a0),a4
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


;----------------------------------------------------
bconout_midi:
 lea  6(sp),a0
 move.w   (a0),d1
_bconout_midi:
bcomidi_loop:
 btst     #1,midictl             ; MIDI-ACIA
 beq.b    bcomidi_loop
 move.b   d1,midi             ; MIDI-Senderegister
 rts


**********************************************************************
*
* void Midiws( int count, char *buf )
*

Midiws:
 move.w   (a0)+,d0
 movea.l  (a0),a0
midiws_loop:
 move.b   (a0)+,d1
 bsr.b    _bconout_midi
 dbf      d0,midiws_loop
 rte

**********************************************************************
*
* long bconout_prt( int dummy, int c )
*                                                 ^^^^^^^
*
* Beschleunigt
*

bconout_prt:
 lea      6(sp),a0                 ; MUSS hier stehen bleiben (wg. jsr 4(a2) im Dispatcher)
 btst     #4,pr_conf+1             ; Drucker seriell ?
 bne      _bconout_ser1            ; ja, nach ST_MFP
 move.l   _hz_200,d2               ; aktuelle Zeit
 sub.l    prt_last_timeout,d2      ; - Zeit des letzten Timout
 cmpi.l   #1000,d2                 ; schon 5s her ?
 bcs.b    bcoprt_end                ; nein, immer noch Timeout
 move.l   _hz_200,d2               ; Zeit bei Beginn
 addq.l   #1,a0                    ; damit <move.b (a0)+> moeglich ist
bcoprt_loop:

 btst.b   #0,gpip                  ; MFP-BUSY (parallele Schnittstelle)
 beq.b    outprn_putc              ; nein, abschicken

 move.l   _hz_200,d0               ; aktuelle Zeit
 sub.l    d2,d0                    ; - Zeit seit Beginn
 cmpi.l   #6000,d0                 ; schon 30s gewartet ?
 blt.b    bcoprt_loop              ; nein, weiter warten
bcoprt_end:
 moveq    #0,d0                    ; Timeout
 move.l   _hz_200,prt_last_timeout ; Zeit des letzten Timeouts merken
 rts

outprn_putc:
 move     sr,d1
 ori      #$700,sr
 lea      giselect,a1              ; Soundchip: Register selektieren/lesen
 lea      2(a1),a2                 ; Soundchip: Register schreiben
 move.b   #7,(a1)                  ; Register 7 auswaehlen
 move.b   (a1),d0                  ; Wert holen
 ori.b    #%11000000,d0            ; Port A (Centr.Strobe) und
 move.b   d0,(a2)                  ; Port B (Centr.Data) auf Ausgang
 move.b   #15,(a1)                 ; Register 15 waehlen: Port B
 move.b  (a0)+,(a2)                ; Zeichen ausgeben
 move.b   #14,(a1)                 ; Register 14 waehlen: Port A
 move.b   (a1),d0
 andi.b   #%11011111,d0            ; Strobe low
 move.b   d0,(a2)                  ; Strobe low -> Drucker
 move.b   d0,(a2)                  ; Verzoegerung (=> Mail Ben Sommer)
;hier ggf. Verzoegerung
 ori.b    #%00100000,d0            ; Strobe high
 move.b   d0,(a2)                  ; Strobe high -> Drucker
 move     d1,sr
 moveq    #-1,d0                   ; Ausgabe ok
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
 movem.l  d7/a6,-(sp)
 move.l   a0,a6                    ; Zeiger merken
 move.l   d0,d7
 beq.b    pwrts_ende
 move.l   _hz_200,d2               ; aktuelle Zeit
 sub.l    prt_last_timeout,d2      ; - Zeit des letzten Timout
 cmpi.l   #1000,d2                 ; schon 5s her ?
 bcs.b    pwrts_timeout            ; nein, immer noch Timeout
pwrts_cloop:
 move.l   _hz_200,d2               ; Zeit bei Beginn
pwrts_tiloop:

 btst.b   #0,gpip                  ; MFP-BUSY (parallele Schnittstelle)
 bne.b    pwrts_wait               ; ja, noch busy
 bsr.b    outprn_putc              ; nein, (a0)+ abschicken
 subq.l   #1,d7                    ; weitere Zeichen ?
 beq.b    pwrts_ende               ; nein, Ende
 bra.b    pwrts_cloop              ; ja, weiter

pwrts_wait:
 move.l   _hz_200,d0               ; aktuelle Zeit
 sub.l    d2,d0                    ; - Zeit seit Beginn
 cmpi.l   #6000,d0                 ; schon 30s gewartet ?
 blt.b    pwrts_tiloop             ; nein, weiter warten

pwrts_timeout:
 move.l   _hz_200,prt_last_timeout ; Zeit des letzten Timeouts merken
pwrts_ende:
 suba.l   a6,a0                    ; alten Zeiger abziehen
 move.l   a0,d0                    ; soviele Zeichen ausgegeben
 movem.l  (sp)+,d7/a6
 rts


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
*
* long bconin_prt( void )
*
bconin_prt:
 moveq    #7,d1
 bsr      _giaccess
 andi.b   #$7f,d0
 moveq    #-$79,d1
 bsr      _giaccess
 moveq    #$20,d2
 bsr      _ongibit
bconinprt_loop:
 bsr.b    bcostat_prt
 tst.w    d0
 bne.b    bconinprt_loop
 moveq    #-$21,d2
 bsr      _offgibit
 moveq    #$f,d1
 bra      _giaccess

**********************************************************************
*
* Bcostat fuer die Devices 0=PRT,1=AUX,2=CON,3=MIDI,4=IKBD
*

bcostat_prt:
 btst     #4,pr_conf+1
 bne      bcostat_ser1             ; ST_MFP
 moveq    #-1,d0
 btst.b   #0,gpip             ; MFP-BUSY (parallele Schnittstelle)
 beq.b    bop_ende
 moveq.l  #0,d0
bop_ende:
 rts

bcostat_con:
 moveq    #-1,d0                   ; immer Zeichen sendbar
 rts

bcostat_ikbd:
 move.b   keyctl,d2             ; IKBD-ACIA
 bra.b    _bcostat

bcostat_midi:
 move.b   midictl,d2             ; MIDI-ACIA
_bcostat:
 moveq    #-1,d0
 btst     #1,d2
 bne.b    bcostatmidi_end
 moveq    #0,d0                    ; ACIA sendet gerade
bcostatmidi_end:
 rts

;
; darf <d0> nicht zerstoeren, da als Schleifenzaehler in ikbd_ws benutzt!
bconout_ikbd:
   lea      6(sp),a0
   move.w   (a0),d1

_bconout_ikbd:
   btst     #1,keyctl            ;Keyboard-ACIA
   beq.b    _bconout_ikbd        ;Sender noch nicht bereit

   move.w    d0,-(sp)
   move.w   #199,d0               ;200 mal (Vorteiler ist 64) warten
_o_ikbd_timc:
   move.b   tcdr,d2
_o_ikbd_wait:
   cmp.b    tcdr,d2
   beq.b    _o_ikbd_wait
   dbf      d0,_o_ikbd_timc
   move.b   d1,keybd             ;Zeichen in Senderegister schreiben
   move.w (sp)+,d0
   rts


**********************************************************************
*
* void Ikbdws( int dbf_count, char *buf )
*

Ikbdws:
 move.w   (a0)+,d0   ;int dbf_count
 movea.l  (a0),a0    ;char *buf
 bsr.b   _ikbdws
 rte

;
; void _ikbdws( d0 = int dbf_count, a0 = char *buf )
;
_ikbdws:
 move.b   (a0)+,d1
 bsr.b    _bconout_ikbd
 dbf      d0,_ikbdws
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
*    ST:  Mega STE:  TT: Falcon:
* ------------------------------------------------------------------
*    6       6       6             ST-kompatibel seriell (Modem 1)      ser1
*            7       7     6/7     SCC Kanal B           (Modem 2)      sccb
*                    8             TTMFP                 (Serial 1)     ser2
*            8       9     8       SCC Kanal A           (Serial 2)     scca
*

init_bconmap:
 lea      dflt_maptable,a0
 lea      bconmap_struct,a1
 move.l   a0,(a1)+
 lea      maptab_data(pc),a2
 cmpi.b   #4,machine_type
 bne.b    inb_st
 lea      24(a2),a2           ; beim Falcon den SCC-B unter 6 und 7 eintragen
inb_st:
 bsr      _bco_cpy            ; ser1 (ST-MFP)
 moveq    #1,d0               ; zunaechst eine Schnittstelle
 cmpi.b   #2,machine_type
 bcs.b    inbc_weiter         ; ist nur ST oder STE

 lea      maptab_data_sccb(pc),a2
 moveq    #4,d0               ; TT: 4 serielle Schnittstellen
 bsr      _bco_cpy            ; sccb
 bsr      _bco_cpy            ; ser2
 cmpi.b   #3,machine_type
 beq.b    inbc_tt             ; ist TT

 moveq    #3,d0
 lea      -24(a0),a0          ; Mega-STE: keine TT-MFP
inbc_tt:
 bsr      _bco_cpy            ; scca
inbc_weiter:
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

; fuer Modem 2 (SCC Channel B)
maptab_data_sccb:
 DC.L Bconstat_sccb
 DC.L Bconin_sccb
 DC.L Bcostat_sccb
 DC.L Bconout_sccb
 DC.L Rsconf_sccb
 DC.L p_iorec_sccb

 dc.l bconstat_ser2      ; Bconstat
 DC.L bconin_ser2        ; Bconin
 DC.L bcostat_ser2       ; Bcostat
 DC.L bconout_ser2       ; Bconout
 DC.L rsconf_ser2        ; Rsconf
 DC.L p_iorec_ser2       ; iorec fuer TT-MFP

; fuer Serial 2 (SCC Channel A)
 DC.L Bconstat_scca
 DC.L Bconin_scca
 DC.L Bcostat_scca
 DC.L Bconout_scca
 DC.L Rsconf_scca
 DC.L p_iorec_scca



bconstat_midi:
 lea      iorec_midi+6,a0          ; *Head-Index
 bra.b    _bconstat

bconstat_con:
 lea      iorec_kb+6,a0            ; *Head-Index

_bconstat:
 cmpm.w   (a0)+,(a0)+              ; Head-Index mit Tail-Index vergleichen
 sne.b    d0                       ; TRUE, wenn Puffer nicht leer
 ext.w    d0
 ext.l    d0                       ; auf Langwort erweitern
 rts

bconin_con:
 lea      iorec_kb,a0              ; IKBD-Iorec
 moveq    #4,d2                    ; Groesse eines Arrayelementes
 bra.b    _bconin

bconin_midi:
 lea      iorec_midi,a0            ; MIDI-Iorec
 moveq    #1,d2                    ; Groesse eines Arrayelementes

_bconin:
 lea      8(a0),a1                 ; *Tail
 move.w   (a1),d1                  ; Tail-Index
 cmp.w    -(a1),d1                 ; Head-Index
 beq.s _bconin
_bconin_in:
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

**********************************************************************
*
* der MFP und seine Vektoren werden initialisiert
*

init_mfp:
 move.l   d7,-(sp)
 lea      gpip,a0
 moveq    #0,d1
; clear all interrupt masks, pending bits etc.
 movep.l  d1,0(a0)
 movep.l  d1,8(a0)
 movep.l  d1,16(a0)
 move.b   #$48,$16(a0)             ; fa17: VR = Hinibble der Vektornummer=4
                                   ;            Automatic-EOI-Modus
 bset     #2,2(a0)                 ; Eingang I2 (CTS) soll Interrupt ausloesen
                                   ; bei steigender Flanke
 move.w   #$1111,flg_50hz          ; jedes vierte Bit gesetzt
 move.w   #20,_timer_ms            ; 50Hz

 moveq    #2,d0                    ; Timer C (200Hz)
 moveq    #$50,d1                  ; ctrl = Teilerverhaeltnis 1:64
 move.w   #$c0,d2                  ; data
 bsr      _xbtimer

 lea      int_hz_200(pc),a2        ; der 200Hz- Zaehler ...
 moveq    #5,d0                    ; ... wird MFP- Interrupt 5
 move.l   a0,-(sp)
 bsr      _mfpint
 move.l   (sp)+,a0

 moveq    #3,d0                    ; Timer D (Baudrate)
 moveq    #1,d1                    ; ctrl
 moveq    #2,d2                    ; data
 bsr      _xbtimer

;move.b   #1,iorec_ser1+$22        ; baudrate, unnoetig, weil unten gesetzt
;move.l   #$880101,d0              ; TOS 1.xx: #$880101


 move.l   #$880105,d0            ; TOS 2.05: #$880105
 movep.l  d0,$26(a0)
 cmpi.b   #4,machine_type          ; Falcon wie Mega STe behandeln
 beq.b    imf_ste
 cmpi.b   #2,machine_type
 bcs.b    imf_st                   ; ST oder STE
 cmpi.b   #3,machine_type
 bne.b    imf_ste                  ; Mega STE
 moveq    #0,d1
 lea      GPIP_TT,a0               ; MFP_TT
 movep.l  d1,0(a0)
 movep.l  d1,8(a0)
 movep.l  d1,16(a0)
 move.b   #$58,$16(a0)             ; andere Vektornummer als MFP_ST
 bset     #7,2(a0)                 ; Eingang I7 (SCSI) soll Interrupt ausloesen
                                   ; bei steigender Flanke
;move.l   #$880105,d0
 movep.l  d0,$26(a0)
 move.b   #1,$fffffa9d
 move.b   #2,$fffffaa5
;move.b   #1,iorec_ser2+$22        ; baudrate fuer TT_MFP, unnoetig, s.u.
imf_ste:
 bsr      init_scc                 ; Mega STE und hoeher
imf_st:
 moveq    #-$11,d2
 bsr      _offgibit

 move     sr,-(sp)
 ori      #$700,sr                 ; keine Interupts
 move.b   #14,giselect             ; Soundchip PORT A selektieren
 move.b   giread,d1                ; Register lesen
 and.b    #$f7,d1                  ; Bit 3 (RTS- Leitung) loeschen
 move.b   d1,giwrite               ; Daten in selektiertes Register schreiben
 move     (sp)+,sr

 moveq    #0,d0                    ; MFP, nicht SCC
 bsr      init_aux_iorec
 move.l   a0,p_iorec_ser1

 cmpi.b   #3,machine_type
 bne.b    imf_no_tt

 moveq    #0,d0                    ; MFP, nicht SCC
 bsr      init_aux_iorec
 move.l   a0,p_iorec_ser2          ; TT-MFP

imf_no_tt:
 lea      iorec_midi,a0
 lea      ori_iorec_midi(pc),a1
 moveq    #$d,d0
_cpyloop2:
 move.b   (a1)+,(a0)+
 dbf      d0,_cpyloop2

 lea      dummyfn(pc),a1
 lea      kbdvecs-4,a0
 move.l   #handle_key,(a0)+        ; kbdvecs-4:   (TOS 2.05)
 move.l   #midivec,(a0)+           ; kbdvecs:     midivec
 move.l   a1,(a0)+                 ; kbdvecs+4:   vkbderr
 move.l   a1,(a0)+                 ; kbdvecs+8:   vmiderr
 move.l   a1,(a0)+                 ; kbdvecs+$c:  statvec
 move.l   a1,(a0)+                 ; kbdvecs+$10: mousevec
 move.l   #clockvec,(a0)+          ; kbdvecs+$14: clockvec
 move.l   a1,(a0)+                 ; kbdvecs+$18: joyvec
 move.l   #midisys,(a0)+           ; kbdvecs+$1c: midisys
 move.l   #ikbdsys,(a0)            ; kbdvecs+$20: ikbdsys

 bsr      init_bconmap

 move.b   #3,midictl             ; MIDI-ACIA reset
 move.b   #$95,midictl           ; MIDI-ACIA %1 00 101 01
                                   ;           Baudrate = Takt/16
                                   ;           8 Bit, keine Paritaet, 1 Stop
                                   ;           RTS=Low, TxINT gesperrt
                                   ;           RxINT freigeben
 move.b   #7,conterm
 moveq    #0,d0
 move.l   d0,sound_data
 move.b   d0,sound_delay
 move.b   d0,sound_byte
 move.l   d0,prt_last_timeout
 moveq    #$20,d2
 bsr      _ongibit

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
 bsr      _Bioskeys                ; 9 Standard-Tastaturtabellen (GER)

 move.b   #3,keyctl
 move.b   #$96,keyctl

 lea      mfp_int_tab(pc),a3
 moveq    #3,d7
imfp_loop:
 move.l   d7,d2
 move.l   d7,d0
 addi.b   #9,d0                    ; Interruptnummer
 asl.l    #2,d2
 movea.l  0(a3,d2.w),a2            ; Interruptroutine
 bsr      _mfpint
 dbf      d7,imfp_loop

 lea      midikey_int(pc),a2
 moveq    #6,d0
 bsr      _mfpint

 lea      int_mfp2(pc),a2          ; CTS- Interruptroutine
 moveq    #2,d0
 bsr      _mfpint

 cmpi.b   #3,machine_type
 bne.b    imf_st3                  ; ST, keine TT-MFP
 lea      mfp_int_tab_xo(pc),a1         ; Interrupts fuer TT-MFP
 lea      $164,a0
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)
 ori.b    #$1e,$fffffa87           ; IERA_TT
                                   ; enable: Bit 1 (XMIT Error)
                                   ;         Bit 2 (XMIT Buffer empty)
                                   ;         Bit 3 (RCV Error)
                                   ;         Bit 4 (RCV Buffer full)
 ori.b    #$1e,$fffffa93           ; dito mit IMRA_TT
imf_st3:
 move.l   (sp)+,d7
 rts

;
; Standard-Init mit XON/XOFF-Routinen!
mfp_int_tab_xo:
 DC.L     int_mfptt9
 DC.L     int_mfptt10X
 DC.L     int_mfptt11
 DC.L     int_mfptt12X

ori_iorec_kb:
 DC.L     iorec_kb_buf             ; Pufferadresse
 DC.W     $0100                    ; Groesse 256 Bytes = 64 Langworte
 DC.W     0                        ; Head Index
 DC.W     0                        ; Tail Index
 DC.W     $40                      ; Low water mark
 DC.W     $c0                      ; High water mark

ori_iorec_midi:
 DC.L     iorec_midi_buf           ; Pufferadresse
 DC.W     $0080                    ; Groesse 128 Bytes
 DC.W     0
 DC.W     0
 DC.W     $20
 DC.W     $60

* MFP Interrupt-Vektor Tabelle

mfp_int_tab:
 DC.L     int_mfp9                 ; Transmitter error
 DC.L     int_mfp10X               ; Transmitter buffer empty
 DC.L     int_mfp11                ; Receiver error
 DC.L     int_mfp12X               ; Receiver buffer full


**********************************************************************
*
* void _xbtimer( d0 = int timer, d1 = int ctrl, d2 = int data )
*
* Timerwerte setzen, darf a0 nicht aendern (von Xbtimer aufgerufen)
* erhaelt saemtliche Register
*
_xbtimer:
;Einstellung eines ausgewaehlten Timers des MFP inklusive Sperren aller
;dazugehoerigen Interruptregister, neue Version von Harun Scheutzow
;D0= 0, 1, 2, 3 entsprechend Timer A, B, C, D
;D1= am Ende zum TxCR (Timer Control Register) dazu OR-verknuepfen
;D2= Wert fuer das TxDR (Timer Data Register)
 movem.l    d3-d4/a0-a1,-(a7) ;D0, D1, D2 duerfen nicht modifiziert werden!
 lea.l         gpip.w,a0           ;MFP-Adresse, automatisch auf $FFFFFA01
 lea        xbofba,a1         ;Basisadresse fuer Daten
 moveq.l    #2,d3             ;Bit1 bleibt, -> Offset =0 fuer Timer 0 und 1
 and.w      d0,d3             ; -> Offset =2 fuer Timer 2 und 3
;bit15..8 in D3 bleiben immer 0
 move.b     0(a1,d0.w),d4     ;AND-Wert fuer alle 4 "AND"s
 move.w     sr,-(a7)          ;SR sichern
 ori.w      #$0700,sr         ;INTERRUPTSPERRE
 and.b      d4,$12(a0,d3.w)   ;Interrupt im IMRx ($12/$14) verbieten
 and.b      d4,$06(a0,d3.w)   ;Interrupt im IERx ($06/$08) verbieten
;beim Schreiben nach IPRx und ISRx werden nur 0-Bits geschrieben,
;1-Bits werden nicht eingeschrieben sondern bleiben unveraendert
 move.b     d4,$0a(a0,d3.w)   ;evtl. angemeldeten Int. in IPRx ($0A/$0C) loeschen
 move.b     d4,$0e(a0,d3.w)   ;evtl. laufenden Int. in ISRx ($0E/$10) loeschen
 move.w     (a7)+,sr          ;ENDE INTERRUPTSPERRE
 move.b     4(a1,d0.w),d3     ;Offset TxCR, wird spaeter noch gebraucht
 move.b     8(a1,d0.w),d4     ;AND-Wert fuer TxCR-Reset
 and.b      d4,0(a0,d3.w)     ;Timer Reset im TxCR
 move.w     d0,d4
 add.w      d0,d4             ;Offset = (0,2,4,6) fuer Timer (0,1,2,3)
wabisgl:
 move.b     d2,$1e(a0,d4.w)   ;schreibe D2 ins TxDR ($1E/$20/$22/$24)
 cmp.b      $1e(a0,d4.w),d2   ;da Timer Reset, sollte es sofort = sein ?
 bne wabisgl                  ;warte auf Gleichheit
 or.b       d1,0(a0,d3.w)     ;OR-verknuepfe D1 zum TxCR dazu
 movem.l    (a7)+,d3-d4/a0-a1
 rts


xbofba:
;Offsets beziehen sich auf die MFP-Adresse $FFFFFA01
 .dc.b $DF,$FE,$DF,$EF  ;AND-Werte Timer 0,1,2,3 fuer IERx&IPRx&ISRx&IMRx
 .dc.b $18,$1A,$1C,$1C  ;Offsets der TxCR
 .dc.b $00,$00,$8F,$F8  ;AND-Werte fuer TimerReset fuer TxCR


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

* d0 = Vektornummer
* a2 = Vektor

_mfpint_tt:
 lea      iera+$80,a1              ; TT-MFP
 lea      $140,a0                  ; Sprungvektoren
 bra.b    __mfpint
_mfpint:
 lea      iera,a1                  ; ST-MFP
 lea      $100,a0                  ; Sprungvektoren
__mfpint:
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0                    ; * 4 fuer Langwortzugriff
; Interrupt <d0> sperren
 bsr.b    __jint
 bclr     d0,imra-iera(a1)         ; IMRA: Interrupt maskieren
 bclr     d0,(a1)                  ; IERA: Interrupt ausschalten
 bclr     d0,ipra-iera(a1)         ; IPRA: ggf. laufenden Interrupt bestaetigen
 st       d1                       ; d0 = $ff
 bclr     d0,d1                    ; alle Bits 1 ausser einem
 move.b   d1,isra-iera(a1)         ; ISRA: und service bit loeschen

 move.l   a2,(a0)                  ; Interrupt umsetzen
; Interrupt wieder freigeben
 bset     d0,(a1)                  ; IERA
 bset     d0,imra-iera(a1)         ; IMRA
 rts


**********************************************************************
*
* void Jdisint( int nr )
*

Jdisint:
 move.w  (a0),d0
 andi.w   #$f,d0
 bsr.b    _jint
 bclr     d0,imra-iera(a1)          ; IMRA: Interrupt maskieren
 bclr     d0,(a1)                   ; IERA: Interrupt ausschalten
 bclr     d0,ipra-iera(a1)          ; IPRA: ggf. laufenden Interrupt bestaetigen
 st       d1                        ; d0 = $ff
 bclr     d0,d1                     ; alle Bits 1 ausser einem
 move.b   d1,isra-iera(a1)          ; ISRA: und service bit loeschen
 rte

**********************************************************************
*
* void Jenabint( int nr )
*

Jenabint:
 move.w  (a0),d0
 andi.w   #$f,d0
 bsr.b    _jint
 bset     d0,(a1)                   ; IERA
 bset     d0,imra-iera(a1)          ; IMRA
 rte


*         d0 =  8..15 : iera
*         d0 =  0..7  : ierb
_jint:
 lea      iera,a1
__jint:
 subq.w   #8,d0
 bcc.b    _mfpn_ende                ; Interrupt 8..15: Bit0..7, erstes Byte
 addq.w   #8,d0                     ; d0 restaurieren
 addq.l   #2,a1                     ; Interrupt 0..7 : Bit0..7, zweites Byte
_mfpn_ende:
 rts


**********************************************************************
*
* long Iorec( int dev )
*

Iorec:
 move.l   p_iorec,a1               ; fuer aux
 move.w  (a0),d1
 beq.b    iorec_ok                 ; 0
 lea      iorec_kb,a1
 subq.w   #1,d1
 beq.b    iorec_ok
 lea      iorec_midi,a1
iorec_ok:
 move.l   a1,d0
 rte


**********************************************************************
*
* char Giaccess( char dat, int regno )
*

Giaccess:
 move.w   (a0)+,d0
 move.w   (a0),d1
 bsr.b   _giaccess
 rte

_giaccess:
 move     sr,-(sp)
 ori      #$700,sr
 move.l   d2,-(sp)
 move.b   d1,d2
 andi.b   #$f,d1                   ; es sind nur nur 15 Register
 move.b   d1,giselect              ; Soundchip, Register auswaehlen
 tst.b    d2                       ; Schreiben ?
 bpl.b    giac_skip                ; nein
 move.b   d0,giwrite               ; data schreiben
giac_skip:
 moveq    #0,d0
 move.b   giread,d0                ; Register auslesen
 move.l   (sp)+,d2
 move     (sp)+,sr
 rts


**********************************************************************
*
* void Ongibit( int nr )
*

Ongibit:
 move.w  (a0),d2
 bsr.b   _ongibit
 rte

_ongibit:
 movem.l  d0/d1/d2,-(sp)
 move     sr,-(sp)
 ori      #$700,sr
 moveq    #$e,d1
 bsr.b    _giaccess
 or.b     d2,d0
 moveq    #-$72,d1
 bsr.b    _giaccess
 move     (sp)+,sr
 movem.l  (sp)+,d2/d1/d0
 rts


**********************************************************************
*
* void Offgibit( int nr )
*

Offgibit:
 move.w  (a0),d2
 bsr.b   _offgibit
 rte

_offgibit:
 movem.l  d0/d1/d2,-(sp)
 move     sr,-(sp)
 ori      #$700,sr
 moveq    #$e,d1
 bsr.b    _giaccess
 and.b    d2,d0
 moveq    #-$72,d1
 bsr.b    _giaccess
 move     (sp)+,sr
 movem.l  (sp)+,d2/d1/d0
 rts


**********************************************************************
*
* void Initmous(int typ, long par, long vec )
*

Initmous:
 suba.w   #18,sp                   ; Platz fuer 17 Bytes
 move.w   (a0)+,d0
 beq.b    initms_t0                ; typ == 0
 movea.l  (a0)+,a1
 move.l   (a0),kbdvecs+$10         ; mousevec
 subq.w   #1,d0
 beq.b    initms_t1                ; typ == 1
 subq.w   #1,d0
 beq.b    initms_t2                ; typ == 2
 subq.w   #2,d0
 beq.b    initms_t4                ; typ == 4
 moveq    #0,d0
 bra.b    initm_ende

; Maus ausschalten
initms_t0:
 moveq    #$12,d1
 bsr      _bconout_ikbd
 move.l   #dummyfn,kbdvecs+$10   ; mousevec auf rts
 bra.b    initms_retm1

; relativer Modus
initms_t1:
 lea      (sp),a2
 move.b   #8,(a2)+
 move.b   #$b,(a2)+
 bsr.b    initms_sub
 moveq    #6,d0
 lea      (sp),a0
 bsr      _ikbdws
 bra.b    initms_retm1

; absoluter Modus
initms_t2:
 lea      (sp),a2
 move.b   #9,(a2)+
 move.b   4(a1),(a2)+
 move.b   5(a1),(a2)+
 move.b   6(a1),(a2)+
 move.b   7(a1),(a2)+
 move.b   #$c,(a2)+
 bsr.b    initms_sub
 move.b   #$e,(a2)+
 clr.b    (a2)+
 move.b   8(a1),(a2)+
 move.b   9(a1),(a2)+
 move.b   $a(a1),(a2)+
 move.b   $b(a1),(a2)+
 moveq    #$10,d0
 lea      (sp),a0
 bsr      _ikbdws
 bra.b    initms_retm1
initms_t4:
 lea      (sp),a2
 move.b   #$a,(a2)+
 bsr.b    initms_sub
 moveq    #5,d0
 lea      (sp),a0
 bsr      _ikbdws
initms_retm1:
 moveq    #-1,d0
initm_ende:
 adda.w   #18,sp                   ; lokale Variable abbauen
 rte

initms_sub:
 move.b   2(a1),(a2)+
 move.b   3(a1),(a2)+
 moveq    #$10,d1
 sub.b    (a1),d1
 move.b   d1,(a2)+
 move.b   #7,(a2)+
 move.b   1(a1),(a2)+
 rts


**********************************************************************
*
* void Xbtimer( int timer, int ctrl, int data, long vec )
*

Xbtimer:
 movem.w  (a0)+,d0/d1/d2           ; timer, ctrl, data
 bsr      _xbtimer
 tst.l    (a0)                     ; Vektor
 bmi.b    xbtim_end
 movea.l  (a0),a2
 lea      xbtim_table(pc),a1
 andi.w   #$ff,d0
 move.b   0(a1,d0.w),d0
 bsr      _mfpint                  ; Interruptvektor setzen
xbtim_end:
 rte

xbtim_table:
 DC.B     $0d,$08,$05,$04


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
 movem.l  d0-d7/a0-a6,-(sp)
 bsr.b    _dosound                 ; Sound verarbeiten
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
 bclr     #5,isrb                  ; (Timer C) Interrupt-Service-Bit loeschen
;move.b   #$df,isrb                ; TOS 2.05
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
* Verarbeitet den Sound, wird von int_hz_200 aufgerufen
*

_dosound:
 move.l   sound_data,d0
 beq      dsnd_end
 movea.l  d0,a0
 move.b   sound_delay,d0           ; Verzoegerung ?
 beq.b    dsnd_del0                ; ist schon abgelaufen
 subq.b   #1,d0                    ; herunterzaehlen
 move.b   d0,sound_delay
 bra.b    dsnd_end                 ; und Ende
dsnd_del0:
 move.b   (a0)+,d0                 ; Sound- Befehl holen
 bmi.b    _dosnd_spec              ; Bit 7 gesetzt, dann spezieller Befehl
 move.b   d0,giselect              ; Register selektieren
 cmpi.b   #7,d0                    ; Register 7 ?
 bne.b    dsnd_l1                 ; nein, weiter
 move.b   (a0)+,d1
 andi.b   #$3f,d1
 move.b   giread,d0
 andi.b   #$c0,d0
 or.b     d1,d0
 move.b   d0,giwrite
 bra.b    dsnd_del0
dsnd_l1:
 move.b   (a0)+,giwrite
 bra.b    dsnd_del0

* $80..$ff
_dosnd_spec:
 addq.b   #1,d0                    ; war Befehl $ff ?
 bpl.b    dsnd_l2                  ; ja
 cmpi.b   #$81,d0                  ; war Befehl $80 ?
 bne.b    dsnd_l3                  ; nein
* $80
 move.b   (a0)+,sound_byte         ; Byte merken
 bra.b    dsnd_del0
* $81..$fe
dsnd_l3:
 cmpi.b   #$82,d0
 bne.b    dsnd_l2
* $83
 move.b   (a0)+,giselect
 move.b   (a0)+,d0
 add.b    d0,sound_byte
 move.b   (a0)+,d0
 move.b   sound_byte,giwrite
 cmp.b    sound_byte,d0
 beq.b    dsnd_reta0
 subq.w   #4,a0
 bra.b    dsnd_reta0
dsnd_l2:
 move.b   (a0)+,sound_delay
 bne.b    dsnd_reta0
 suba.l   a0,a0
dsnd_reta0:
 move.l   a0,sound_data
dsnd_end:
 rts


**********************************************************************
*
* Emulation des 68000- Befehls "move sr,ea" auf dem 680x0
*
**********************************************************************

my_priv_exception:
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
          pea     exc08(pc)             ; 8 Bomben: Priv.Viol.
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






     INCLUDE "..\..\bios\atari\modules\serial.s"
     INCLUDE "..\..\bios\atari\modules\clock.s"
     INCLUDE "..\..\bios\atari\modules\video.s"
     INCLUDE "..\..\bios\atari\modules\keyb.s"



*********************************************************************
*
* Loescht alle Caches
*

cache_invalid:
 cmpi.w   #40,cpu_typ         ; ab 40er Cache anders loeschen ...
 bcs.b    ci_20
 nop
 DC.W     cpusha              ; cpusha -- alle Caches zurueck und loeschen
 nop
 rts
ci_20:
 cmpi.w   #20,cpu_typ
 bcs.b    ci_0
 move     sr,-(sp)
 move.l   d0,-(sp)
 ori      #$700,sr
 movec    cacr,d0
 or.l     #$808,d0            ; data+instr invalid
 movec    d0,cacr
 move.l   (sp)+,d0
 move     (sp)+,sr
ci_0:
 rts

**********************************************************************
*
* int get_cpu_typ( void )
*
* Bestimmung des Prozessors
*

get_cpu_typ:
 move.l   sp,a0                    ; Hier Stack retten wegen ggf. Exception
 moveq    #0,d0                    ; Default CPU ist 68000
 move.l   #set_cpu_typ,$10                   ; illegal instruction

 move     ccr,d1
 moveq    #10,d0                   ; War OK ? Kennung fuer 68010 nach d1
 movec.l  cacr,d1
 move.l   d1,d0
 ori.w    #$8200,d1

 movec    d1,cacr
 movec    cacr,d1
 movec    d0,cacr                  ; always restore cacr
 moveq    #20,d0                   ; assume 68020
 btst     #9,d1                    ; check if 68030 data cache was enabled
 beq.b    set_cpu_typ              ; no data cache, we are done
 moveq    #30,d0                   ; no fault -> this is a 030
 btst     #15,d1                   ; Bit 15 testen
 beq.b    set_cpu_typ              ; War 0, obwohl gesetzt ? -> 68030
; Ab hier kann es nur noch ein 040 oder ein 060 sein 
 moveq    #40,d0                   ; Kennung für 68040 nach d0 
 move.l   $f4.w,a1                 ; Exeption61 retten 
 lea      chk68060(pc),a2          ; bei 060 fliegen wir nach dort raus
 move.l   a2,$f4.w                 ; Exception umsetzen 
 cmp2.b   (a0),d0                  ; erzeugt Exception beim 060
 bra.b    cpu_40_60_ok
chk68060:
 moveq    #60,d0                   ; Kennung für 68060 nach d0
cpu_40_60_ok:
move.l   a1,$f4.w                 ; Exeption61 restaurieren 

set_cpu_typ:
 move.l   a0,sp                    ; Stack wiederherstellen
 rts

     IFNE HADES
     INCLUDE "..\..\bios\atari\modules\had_cook.s"
     ELSE
     INCLUDE "..\..\bios\atari\modules\cook.s"
     ENDIF


**********************************************************************
**********************************************************************
*
* DATA
*

 INCLUDE "biosmsg.inc"

pling_data:  /* Ton fuer "pling" */
 DC.B     $00,$34,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
 DC.B     $08,$10,$09,$00,$0a,$00,$0b,$00,$0c,$10,$0d,$09,$ff,$00

klick_data:  /* Ton fuer "klick" */
 DC.B     $00,$3b,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$fe
 DC.B     $08,$10,$0d,$03,$0b,$80,$0c,$01,$ff,$00,$00

   EVEN
* 64 Langworte fuer PMMU-Tabelle (nach $700 kopiert)
* PMMU- Tabelle: kurze Deskriptoren (4 Byte), TIA=TIB=TIC=4.
pmmutab:

** erste Stufe (TIA = 4 => 16 Eintraege)

; Adresse $0xxxxxxx
 DC.L     $00000742 ; DT = 2: naechste Tabelle ist valid/4 Bytes
                    ; Tabellenadresse $740
; Adresse $1xxxxxxx
 DC.L     $10000001 ; DT = 1: dies ist ein page descriptor (early termination)
                    ; WP = 0: Schreiben erlaubt
                    ; CI = 0: Caching erlaubt
                    ; Page-Adresse $10000000
; Adresse $2xxxxxxx
 DC.L     $20000001
; Adresse $3xxxxxxx
 DC.L     $30000001
; Adresse $4xxxxxxx
 DC.L     $40000001
; Adresse $5xxxxxxx
 DC.L     $50000001
; Adresse $6xxxxxxx
 DC.L     $60000001
; Adresse $7xxxxxxx
 DC.L     $70000001
; Adresse $8xxxxxxx
 DC.L     $80000041 ; DT = 1: dies ist ein page descriptor (early termination)
                    ; WP = 0: Schreiben erlaubt
                    ; CI = 1: Caching verboten
                    ; Page-Adresse $10000000
; Adresse $9xxxxxxx
 DC.L     $90000041
; Adresse $axxxxxxx
 DC.L     $a0000041
; Adresse $bxxxxxxx
 DC.L     $b0000041
; Adresse $cxxxxxxx
 DC.L     $c0000041
; Adresse $dxxxxxxx
 DC.L     $d0000041
; Adresse $exxxxxxx
 DC.L     $e0000041
; Adresse $fxxxxxxx
 DC.L     $00000782 ; DT = 2: naechste Tabelle ist valid/4 Bytes
                    ; Tabellenadresse $780

** zweite Stufe (TIB = 4 => 16 Eintraege) fuer $0xxxxxxx

; Adresse $00xxxxxx
 DC.L     $000007c2 ; DT = 2: naechste Tabelle ist valid/4 Bytes
                    ; Tabellenadresse $7c0
; Adresse $01xxxxxx
 DC.L     $01000001 ; restliche sind page descriptoren, Caching erlaubt
 DC.L     $02000001
 DC.L     $03000001
 DC.L     $04000001
 DC.L     $05000001
 DC.L     $06000001
 DC.L     $07000001
 DC.L     $08000001
 DC.L     $09000001
 DC.L     $0a000001
 DC.L     $0b000001
 DC.L     $0c000001
 DC.L     $0d000001
 DC.L     $0e000001
 DC.L     $0f000001

** zweite Stufe (TIB = 4 => 16 Eintraege) fuer $fxxxxxxx

; Adresse $f0xxxxxx
 DC.L     $00000041      ; log. $fzxxxxxx wird zu physikalisch
 DC.L     $01000041      ;  $0zxxxxxx, Caching verboten
 DC.L     $02000041
 DC.L     $03000041
 DC.L     $04000041
 DC.L     $05000041
 DC.L     $06000041
 DC.L     $07000041
 DC.L     $08000041
 DC.L     $09000041
 DC.L     $0a000041
 DC.L     $0b000041
 DC.L     $0c000041
 DC.L     $0d000041
 DC.L     $0e000041
; Adresse $ffxxxxxx
 DC.L     $000007c2 ; DT = 2: naechste Tabelle ist valid/4 Bytes
                    ; Tabellenadresse $7c0

** zweite Stufe (TIB = 4 => 16 Eintraege) fuer $00xxxxxx und $ffxxxxxx

 DC.L     $00000001      ; $ffxxxxxx wird immer zu physikalisch
 DC.L     $00100001      ;  $00xxxxxx, Caching erlauben
 DC.L     $00200001
 DC.L     $00300001
 DC.L     $00400001
 DC.L     $00500001
 DC.L     $00600001
 DC.L     $00700001
 DC.L     $00800001
 DC.L     $00900001

 DC.L     $00a00001
 DC.L     $00b00001
 DC.L     $00c00001
 DC.L     $00d00001
 DC.L     $00e00001
; Adresse $00fxxxxx
; Adresse $fffxxxxx
 DC.L     $00f00041      ; Caching verbieten


* PMMU: crp
* Die Deskriptortabelle hat kurze Eintraege, das untere Limit ist 0,
* d.h. es gibt kein Limit fuer die Adressumsetzung
pmmu_crp:
 DC.L     $80000002      ; 63    : L/U = 1: unsigned lower limit
                         ; 48..62: limit = 0
                         ; 16..17: descriptor type = valid/4 Byte
 DC.L     $700           ; Tabellenadresse (Langwortgrenze!)

* PMMU: tc
pmmu_tc:
 DC.L     $80f04445      ; 31:     PMMU enable
                         ; 25:     SRE disable
                         ; 24:     FCL disable
                         ; 20..23: page size 32kB
                         ; 16..19: initial shift 0
                         ; 12..15: TIA = 4
                         ;  8..11: TIB = 4
                         ;  4.. 7: TIC = 4
                         ;  0.. 3: TID = 5   (3stufige Tabelle)

* PMMU: tt0
* jedes zweite (!) 16MB-Segment vom Beginn des TT-RAMS an wird
* nicht umgesetzt (Fehler???!!!???)
pmmu_tt0:
 DC.L     $017e8107      ; 24..31: Adressbereich $01000000..$01ffffff
                         ; 16..23: Adressmaske $7e
                         ; 15    : enable
                         ;  8    : ignore R/W, (egal, ob lesen od. schreiben)
                         ;  4.. 7: FC-Base = 0
                         ;  0.. 3: FC-Mask = 7    (FC ignorieren)

* PMMU: tt1
* Der Bereich $80000000 bis $feffffff wird nicht umgesetzt
* und nicht ge-cache-t (u.a. VME-Bereich $fexxxxxx)
*
pmmu_tt1:
 DC.L     $807e8507      ; 24..31: Adressbereich $80000000..$80ffffff
                         ; 16..23: Adressmaske $7e
                         ; 15    : enable
                         ; 10    : cache inhibit
                         ;  8    : ignore R/W
                         ;  4.. 7: FC-Base = 0
                         ;  0.. 3: FC-Mask = 7    (FC ignorieren)


; ***
; *** Ganz zum Schluss noch Hades-SCSI dazu (da langer Code)
; ***


     IFNE    HADES
     INCLUDE "..\..\bios\atari\modules\had_scsi.s"
     INCLUDE "..\..\bios\atari\modules\unim_int.s"
     ENDIF
     
     END

