;Trapnummern
GEMDOS              EQU 1
BIOS                EQU 13
XBIOS               EQU 14

;Vektornummern
VBLVEC              EQU 28
GEMDOSVEC           EQU 33
BIOSVEC             EQU 45
XBIOSVEC            EQU 46

;Trapadressen
GEMDOSVEC_ADDR  EQU $84
BIOSVEC_ADDR        EQU $b4
XBIOSVEC_ADDR       EQU $b8

;GEMDOS-Funktiosnummern
CCONWS              EQU 9
DSETDRV             EQU 14
SCRNMALLOC          EQU 21
DGETDRV             EQU 25
FSETDTA             EQU 26
TGETDATE            EQU 42
FGETDTA             EQU 47
PTERMRES            EQU 49
DSETPATH            EQU 59
FCREATE             EQU 60
FOPEN               EQU 61
FCLOSE              EQU 62
FREAD               EQU 63
FWRITE              EQU 64
FSEEK               EQU 66
MXALLOC             EQU 68
DGETPATH            EQU 71
MALLOC              EQU 72
MFREE               EQU 73
MSHRINK             EQU 74
PEXEC               EQU 75
FSFIRST             EQU 78
FSNEXT              EQU 79

;Bios-Funktionsnummern
BCONSTAT            EQU 1
BCONIN              EQU 2
BCONOUT             EQU 3
SETEXC              EQU 5
TICKCAL             EQU 6
KBSHIFT             EQU 11

;Device Console
CON                 EQU 2

;Xbios-Funktiosnummern
PHYSBASE            EQU 2
LOGBASE             EQU 3
GETREZ              EQU 4
SETSCREEN           EQU 5
SETPALETTE          EQU 6
SETCOLOR            EQU 7
IOREC               EQU 14
SCRDMP              EQU 20
CURSCONF            EQU 21

DOSOUND             EQU 32
KBDVBASE            EQU 34
SUPEXEC             EQU 38
BLITMODE            EQU 64
ESETSHIFT           EQU 80
ESETBANK            EQU 82
ESETCOLOR           EQU 83
ESETPALETTE         EQU 84
ESETGRAY            EQU 86
ESETSMEAR           EQU 87
VSETMODE            EQU 88
MON_TYPE            EQU 89
VSETSYNC            EQU 90
VGETSIZE            EQU 91
VSETRGB             EQU 93
VGETRGB             EQU 94
VSETMASK            EQU 150

CURS_GETRATE        EQU 5

ST_RAM_only         EQU $00                     ;nur ST-RAM
TT_RAM_only         EQU $01                     ;nur Alternative-RAM
ST_RAM_pref         EQU $02                     ;ST-RAM bevorzugt
TT_RAM_pref         EQU $03                     ;Alternative-RAM bevorzugt

PRIVATE_MEM         EQU $10                     ;nur fuer Prozess und OS beschreibbar
GLOBAL_MEM          EQU $20                     ;fuer alle zugaenglich
SUPER_MEM           EQU $30                     ;fuer alle dem Supervisor-Mode zugaenglich
PRIVATER_MEM        EQU $40                     ;kann von allen gelesen werden, ansonsten wei PRIVATE

DONT_FREE           EQU $4000                   ;Bit 14 gesetzt

EINVFN              EQU -32                     ;Funktion nicht vorhanden

/* system variables */
etv_timer           EQU $0400                   ;System-Timer
resvalid            EQU $0426                   ;RESET-Wert
resvector           EQU $042a                   ;RESET-Vektor
timer_ms            EQU $0442                   ;Timer-Intervall
sshiftmd            EQU $044c                   ;Aufloesung wie bei Getrez
v_bas_ad            EQU $044e                   ;Zeiger auf den Bildspeicher
vblsem              EQU $0452                   ;Semaphore fuer VBL
nvbls               EQU $0454                   ;Laenge der VBL-Queue
vbl_queue           EQU $0456                   ;Zeiger auf die Tabelle der VBlank-Prozesse
frclock             EQU $0466                   ;Anzahl der VBlanks
conterm             EQU $0484                   ;CON-Attributes
con_state           EQU $04a8                   ;Sprungvektor fuer VT52
hz_200              EQU $04ba                   ;200Hz-Interrupt
dumpflag            EQU $04ee                   ;Flag fuer die Druckerausgabe
sysbase             EQU $04f2                   ;Zeiger auf Betriebssystemheader
dump_vec            EQU $0502                   ;Zeiger auf Hardcopy-Routine
o_con               EQU $0586                   ;Sprungvektor fuer Bconout ueber CON
o_rawcon            EQU $0592                   ;Sprungvektor fuer Bconout ueber RAWCON
longframe           EQU $059e                   ;Flag fuers Stackframe
p_cookies           EQU $05a0                   ;Zeiger auf den Cookie-Jar
bell_hook           EQU $05ac                   ;Routine fuer Glocke

;Systemheader-Offsets
os_version          EQU $02                     ;TOS-Version
os_beg              EQU $08                     ;Zeiger auf den Betriebssytemstart
os_magic            EQU $14                     ;Zeiger auf die AES-Variablen
os_conf             EQU $1c                     ;Konfigurationsbits
kbshift             EQU $24                     ;Zeiger auf Tastenstatus (relativ zu sysbase)
run                 EQU $28                     ;Zeiger auf die Basepage des aktuellen Prozesses

/* PH (program header) */
		OFFSET 0
ph_branch:  ds.w 1
ph_tlen:    ds.l 1
ph_dlen:    ds.l 1
ph_blen:    ds.l 1
ph_slen:    ds.l 1
ph_res1:    ds.l 1
ph_prgflgs: ds.l 1
ph_flag:    ds.w 1
sizeof_PH:
PH_MAGIC            EQU $601a                   ;Magic des Programmheaders

/* BASEPAGE offsets */
		OFFSET 0
p_lowtpa:  ds.l 1
p_hitpa:   ds.l 1
p_tbase:   ds.l 1
p_tlen:    ds.l 1
p_dbase:   ds.l 1
p_dlen:    ds.l 1
p_bbase:   ds.l 1
p_blen:    ds.l 1
p_dta:     ds.l 1
p_parent:  ds.l 1
p_flags:   ds.l 1
p_env:     ds.l 1
p_devx:    ds.b 6
p_resrvd1: ds.b 1
p_defdrv:  ds.b 1
p_undef:   ds.l 17
p_usp:     ds.l 1
p_cmdlin:  ds.b 128

;Defines fuer den _VDO-Cookie
ST_VIDEO            EQU 0
STE_VIDEO           EQU 1
TT_VIDEO            EQU 2
FALCON_VIDEO        EQU 3

E_OK                    EQU 0

;XBIOS-Video-Modi
ST_LOW              EQU 0
ST_MID              EQU 1
ST_HIGH             EQU 2
FALCONMDS           EQU 3
TT_MID              EQU 4
TT_HIGH             EQU 6
TT_LOW              EQU 7

;Defines fuer Falcon-modecode
VERTFLAG            EQU $0100
STMODES             EQU $80
OVERSCAN            EQU $40
PAL                 EQU $20
VGA                 EQU $10
TV                  EQU $00

COL80               EQU $08
COL40               EQU $00
NUMCOLS             EQU $07
BPS16               EQU $04
BPS8                EQU $03
BPS4                EQU $02
BPS2                EQU $01
BPS1                EQU $00

VTF_BIT             EQU 8
STC_BIT             EQU 7
OVS_BIT             EQU 6
PAL_BIT             EQU 5
VGA_BIT             EQU 4
CLM_BIT             EQU 3

;Prozessornummern
M68000              EQU 0
M68010              EQU 10
M68020              EQU 20
M68030              EQU 30
M68040              EQU 40

;Werte fuer malloc_info
MALLOC_dontfree EQU 0
MALLOC_ttram        EQU 1
MALLOC_malloc       EQU 2
MALLOC_act_pd       EQU 3
