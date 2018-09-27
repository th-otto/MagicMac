MACRO     gemdos    fnummer
          IF fnummer = 0
          clr.w     -(sp)
          ELSE
          move.w    #fnummer,-(sp)
          ENDIF
          trap      #1
          ENDM

MACRO     xbios fnummer
          move.w    #fnummer,-(sp)
          trap      #14
          ENDM

MACRO     bios fnummer
          move.w    #fnummer,-(sp)
          trap      #13
          ENDM

******************************************************

* BIOS:

Getmpb    EQU 0
Bconstat  EQU 1
Bconin    EQU 2
Bconout   EQU 3
Rwabs     EQU 4
Setexc    EQU 5
Tickcal   EQU 6
Getbpb    EQU 7
Bcostat   EQU 8
Mediach   EQU 9
Drvmap    EQU 10
Kbshift   EQU 11

* XBIOS:

Initmous  EQU 0
Physbase  EQU 2
Logbase   EQU 3
Getrez    EQU 4
Setscreen EQU 5
Setpalette  EQU 6
Setcolor  EQU 7
Floprd    EQU 8
Flopwr    EQU 9
Flopfmt   EQU 10
Midiws    EQU 12
Mfpint    EQU 13
Iorec     EQU 14
Rsconf    EQU 15
Keytbl    EQU 16
Random    EQU 17
Protobt   EQU 18
Flopver   EQU 19
Scrdmp    EQU 20
Cursconf  EQU 21
Settime   EQU 22
Gettime   EQU 23
Bioskeys  EQU 24
Ikbdws    EQU 25
Jdisint   EQU 26
Jenabint  EQU 27
Giaccess  EQU 28
Offgibit  EQU 29
Ongibit   EQU 30
Xbtimer   EQU 31
Dosound   EQU 32
Setprt    EQU 33
Kbdvbase  EQU 34
Kbrate    EQU 35
Prtblk    EQU 36
Vsync     EQU 37
Wvbl      EQU Vsync
Supexec   EQU 38
Puntaes   EQU 39
Floprate EQU 41
DMAread  EQU 42
DMAwrite EQU 43
Bconmap  EQU 44
NVMaccess   EQU 46
Blitmode  EQU 64


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
Fshrink   EQU Fwrite          * KAOS
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

* BIOS- und GEMDOS- Fehlercodes:

E_OK      EQU 0
ERROR     EQU -1
EDRVNR    EQU -2
EUNCMD    EQU -3
E_CRC     EQU -4
EBADRQ    EQU -5
E_SEEK    EQU -6
EMEDIA    EQU -7
ESECNF    EQU -8
EPAPER    EQU -9
EWRITF    EQU -10
EREADF    EQU -11
EWRPRO    EQU -13
E_CHNG    EQU -14
EUNDEV    EQU -15
EBADSF    EQU -16
EOTHER    EQU -17

EINVFN    EQU -32
EFILNF    EQU -33
EPTHNF    EQU -34
ENHNDL    EQU -35
EACCDN    EQU -36
EIHNDL    EQU -37
ENSMEM    EQU -39
EIMBA     EQU -40
EDRIVE    EQU -46
ENSAME    EQU -48
ENMFIL    EQU -49
ERANGE    EQU -64
EINTRN    EQU -65
EPLFMT    EQU -66
EGSBF     EQU -67

EBREAK    EQU -68             * KAOS
EXCPT     EQU -69             * KAOS

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

******************************************************

TAB       EQU 9
ESC       EQU 27
CR        EQU 13
LF        EQU 10

K_CR      EQU $1C000D
K_BS      EQU $0E0008
K_UPARROW EQU $480000
K_DNARROW EQU $500000
K_LTARROW EQU $4B0000
K_RTARROW EQU $4D0000
K_DEL     EQU $53007F
K_UNDO    EQU $610000
K_INSERT  EQU $520000
K_CLR     EQU $470037
K_HOME    EQU $470000
K_RETURN  EQU $1C000D
K_ENTER   EQU $72000D
K_TAB     EQU $0F0009
K_F1      EQU $3B0000
K_F10     EQU $440000
K_ESC     EQU $01001B
K_CTRL_C  EQU $2e0003

* Struktur "VDIESC" (relativ zu LINEA)

v_cel_mx  EQU -$2c
v_cel_my  EQU -$2a
v_cur_cx  EQU -$1c
v_cur_cy  EQU -$1a

* Struktur "SYSHDR" (TOS- Header, auf den _sysbase zeigt)

os_version     EQU  2
os_start       EQU  4
os_base        EQU  8
os_membot      EQU  $c
os_shell       EQU  $10
os_magic       EQU  $14
os_gendat      EQU  $18
os_palmode     EQU  $1c
os_gendatg     EQU  $1e
os_root        EQU  $20
os_kbshift     EQU  $24
os_run         EQU  $28
os10_root      EQU  $56fa     * fÅr TOS 1.0
os10_kbshift   EQU  $e1b      * fÅr TOS 1.0
os10_run       EQU  $602c     * fÅr TOS 1.0

* Systemvariablen

proc_lives     EQU $380
proc_regs      EQU $384
proc_pc        EQU $3c4
proc_usp       EQU $3c8
proc_stk       EQU $3cc
etv_timer      EQU $400
etv_critic     EQU $404
etv_term       EQU $408
etv_xtra       EQU $40c
memvalid       EQU $420
memctrl        EQU $424
resvalid       EQU $426
resvector      EQU $42a
phystop        EQU $42e
_memboot       EQU $432
_memtop        EQU $436
memval2        EQU $43a
flock          EQU $43e
seekrate       EQU $440
_timer_ms      EQU $442
_fverify       EQU $444
_bootdev       EQU $446
palmode        EQU $448
defshiftmd     EQU $44a
sshiftmd       EQU $44c
_v_bas_ad      EQU $44e
vblsem         EQU $452
nvbls          EQU $454
_vblqueue      EQU $456
colorptr       EQU $45a
screenpt       EQU $45e
_vbclock       EQU $462
_frclock       EQU $466
hdv_init       EQU $46a
swv_vec        EQU $46e
hdv_bpb        EQU $472
hdv_rw         EQU $476
hdv_boot       EQU $47a
hdv_mediach    EQU $47e
_cmdload       EQU $482
conterm        EQU $484
trp14ret       EQU $486
criticret      EQU $48a
themd          EQU $48e
____md         EQU $49e
savptr         EQU $4a2
_nflops        EQU $4a6
con_state      EQU $4a8
save_row       EQU $4ac
sav_context    EQU $4ae
_bufl          EQU $4b2
_hz_200        EQU $4ba
the_env        EQU $4be
_drvbits       EQU $4c2
_dskbufp       EQU $4c6
_autopath      EQU $4ca
_vbl_list      EQU $4ce
_dumpflg       EQU $4ee
_prtabt        EQU $4f0
_sysbase       EQU $4f2
_shell_p       EQU $4f6
end_os         EQU $4fa
exec_os        EQU $4fe
scr_dump       EQU $502
prv_lsto       EQU $506
prv_lst        EQU $50a
prv_auxo       EQU $50e
prv_aux        EQU $512
pun_ptr        EQU $516
memval3        EQU $51a
dev_vecs       EQU $51e       /* long dev_vecs[8*4]         */
cpu_typ        EQU $59e       /* int cpy_typ                */
_p_cookies     EQU $5a0       /* long *cookie               */
fstrm_top      EQU $5a4
fstrm_valid    EQU $5a8
bell_hook      EQU $5ac       /* long *pointer auf pling    */
kcl_hook       EQU $5b0       /* long *pointer auf keyklick */

* Line-A Funktionen

A_INIT              EQU $A000
A_PUT_PIXEL         EQU $A001
A_GET_PIXEL         EQU $A002
A_LINE              EQU $A003
A_HORIZONTAL_LINE   EQU $A004
A_FILLED_RECTANGLE  EQU $A005
A_FILLED_POLYGON    EQU $A006
A_BITBLT            EQU $A007
A_TEXTBLT           EQU $A008
A_SHOW_MOUSE        EQU $A009
A_HIDE_MOUSE        EQU $A00A
A_TRANSFORM_MOUSE   EQU $A00B
A_UNDRAW_SPRITE     EQU $A00C
A_DRAW_SPRITE       EQU $A00D
A_COPY_RASTER_FORM  EQU $A00E

* Offsets fÅr Line-A Variablen

MOUSE_BT            EQU -$254

* Offsets fÅr Basepage

p_lowtpa            EQU  0
p_hitpa             EQU  4
p_tbase             EQU  8
p_tlen              EQU  12
p_dbase             EQU  16
p_dlen              EQU  20
p_bbase             EQU  24
p_blen              EQU  28
p_dta               EQU  32
p_parent            EQU  36
p_res1              EQU  40
p_env               EQU  44
p_devx              EQU  48
p_defdrv            EQU  55

p_cmdlin            EQU  128

	include "country.inc"
