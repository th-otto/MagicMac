*
* Alle Hardware- Adressen beginnen mit "M_"
*
* Hardware- Adressen fuer den FDC/DMA

M_dma_diskctl  EQU  $ffff8604           ; Word
                                        ; FDC- Modus:
                                        ;  lesen: FDC-Status
                                        ;  schreiben: FDC-Kommando
                                        ; DMA- Modus:
                                        ;  schreiben: Sektorzaehler
                                        ;  lesen:     Status (Bit0=0:Fehler)
M_dma_fifo     EQU  $ffff8606           ; Word
                                        ; schreiben:
                                        ;  Bit 4 = 0: FDC selektieren
                                        ;          1: DMA selektieren
                                        ;  Bit 8 = 0: DMA liest
                                        ;          1: DMA schreibt
                                        ;  Bit 1/2: FDC-Register selektieren
                                        ;   $(1)80     lesen: FDC-Status
                                        ;              schr.: FDC-Command
                                        ;   $(1)82     FDC-Track
                                        ;   $(1)84     FDC-Sector
                                        ;   $(1)86     FDC-Data
                                        ;
                                        ; klappern:
                                        ; $90/$190/$90  = loeschen,DMA lesen
                                        ; $190/$90/$190 = loeschen,DMA schr.
M_dma_high     EQU  $ffff8609           ; Byte, schreiben
M_dma_mid      EQU  $ffff860b           ; Byte, schreiben
M_dma_low      EQU  $ffff860d           ; Byte, schreiben
M_fdc_hdmode   EQU  $ffff860e           ; Word (ab Mega STE)
                                        ; schreiben
                                        ; 0 = DD / 3 = HD

IDE_Base         equ $fff00000
IDE_Data         equ $00
IDE_SectorCount  equ $09
IDE_SectorNumber equ $0d
IDE_CylL         equ $11
IDE_CylH         equ $15
IDE_DriveHead    equ $19
IDE_StatReg      equ $1d
IDE_Command      equ $1d
IDE_StatReg2     equ $39		; (R) - dieses Register kann gelesen
					; werden, ohne dass IR-Bits sich veraendern

;--------------------------------------------------------------------------
;
; Definitionen fuer die serielle Schnittstelle
;
;
; Dieses Kommando verhindert, dass ein weiterer Sender-Interrupt ausgeloest wird,
; obwohl alle zu sendenden Zeichen ausgegeben wurden und der Sendebuffer
; "leerlaeuft".
; Es kann erst dann wieder ein Sendeinterrupt auftreten, wenn das naechsten zu
; sendende Zeichen in das Sendeschieberegister uebergeben wurde oder ev. CRC-Bytes
; komplett ausgesendet wurden
;
ResetTxINTPending EQU $28
;
; Mit diesem Kommando koennen die von manchen Betriebsarten gesetzten Status-
; informationen zurueckgesetzt und der eingefrorene Zustand aufgehoben werden.
ErrorReset        EQU $30

;
; Setzt die Status Bits (die z.B. von CTS,DCD, etc. gesetzt wurden) zurueck
ResetExtStatIntr  EQU $10

;
; Mit diesem Kommando kann man gezielt den im Moment am hoechsten priorisierten
; Interrupt "abschalten". Das sollte immer am Ende einer Interrupt-Service-
; Routine geschehen, um dann den "weniger wichtigen" Interrupts die Moeglichkeit
; zur Bearbeitung zu geben
ResetHighIUS      EQU $38

;
; Mit POINT HIGH wird zwischen den Register 0-7 und 8-15 umgeschaltet
PointHigh         EQU $08

aux_status_rcv    EQU $1c
aux_status_tmt    EQU $1d
aux_lock_rcv      EQU $1e
aux_lock_tmt      EQU $1f
aux_handshake     EQU $20
aux_x_buf         EQU $21
baudrate          EQU $22
bitchr            EQU $23

XOFF              EQU $13
XON               EQU $11

scu_gp1           EQU $ffff8e09
sccctl_b          EQU $ffff8c85
sccctl_a          EQU $ffff8c81
sccdat_a          EQU $ffff8c83
sccdat_b          EQU $ffff8c87

_scc_dat          EQU 2                   ;offset to the control register

;
; MFP
giread            EQU $ffff8800           ;Selektiertes Register auslesen
giselect          EQU $ffff8800           ;select Chip-Register anwaehlen
giwrite           EQU $ffff8802           ;Schreiben in angewaehltes Register
gpip              EQU $fffffa01           ;GPIP-Data-Register
aer               EQU $fffffa03           ;Active-Edge-Register
ddr               EQU $fffffa05           ;data direction register
iera              EQU $fffffa07           ;Interrupt-Enable-Register A
ierb              EQU $fffffa09           ;Interrupt-Enable-Register B
ipra              EQU $fffffa0b           ;Interrupt-Pending-Register A
iprb              EQU $fffffa0d           ;Interrupt-Pending-Register B
isra              EQU $fffffa0f           ;Interrupt-In-Service-Register A
isrb              EQU $fffffa11           ;Interrupt-In-Service-Register B
imra              EQU $fffffa13           ;Interrupt-Mask-Register A
imrb              EQU $fffffa15           ;Interrupt-Mask-Register B
vr                EQU $fffffa17           ;vector register
tacr              EQU $fffffa19           ;Timer A Control Register
tbcr              EQU $fffffa1b           ;Timer B Control Register
tcdcr             EQU $fffffa1d           ;Timer C+D Control Register
tadr              EQU $fffffa1f           ;Timer A Data Register
tbdr              EQU $fffffa21           ;Timer B Data Register
tcdr              EQU $fffffa23           ;Timer C Data Register
tddr              EQU $fffffa25           ;Timer D Data Register
scr               EQU $fffffa27           ;Sync.-Character Register
ucr               EQU $fffffa29           ;USART-Control-Register
rsr               EQU $fffffa2b           ;Receiver-Status-Register
tsr               EQU $fffffa2d           ;Transmitter-Status-Register
udr               EQU $fffffa2f           ;USART-Data-Register

GPIP_TT           EQU $fffffa81
IPRA_TT           EQU $fffffa8b
ISRA_TT           EQU $fffffa8f
RSR_TT            EQU $fffffaab
TSR_TT            EQU $fffffaad
UDR_TT            EQU $fffffaaf


;MFP-Interrupts
iva_mfp_cts       EQU $0108               ;CTS-Interrupt
iva_mfp_tic       EQU $0114               ;TimerC (200Hz)
iva_mfp_ter       EQU $0124               ;Transmitter Error
iva_mfp_tbe       EQU $0128               ;Transmitter Buffer Empty
iva_mfp_rer       EQU $012c               ;Receiver Error
iva_mfp_rbf       EQU $0130               ;Receiver Buffer Full

;
; ACIA
keyctl            EQU $fffffc00           ;ACIA Status Register
keybd             EQU $fffffc02           ;ACIA Data Register
midictl           EQU $fffffc04           ;MIDI-ACIA Status Register
midi              EQU $fffffc06           ;MIDI-ACIA Data Register

;-------------------------------------------------
;
; Falcon-Video-Adressen
;
VFC               EQU $ffff82a0
VFT               EQU $ffff82a2
VBB               EQU $ffff82a4
VBE               EQU $ffff82a6
VDB               EQU $ffff82a8
VDE               EQU $ffff82aa
VSS               EQU $ffff82ac
HHC               EQU $ffff8280
HHT               EQU $ffff8282
HBB               EQU $ffff8284
HBE               EQU $ffff8286
HDB               EQU $ffff8288
HDE               EQU $ffff828a
HSS               EQU $ffff828c
HFS               EQU $ffff828e
HEE               EQU $ffff8290
VXX               EQU $ffff82c0
VCO               EQU $ffff82c2
VWRAP             EQU $ffff8210
LINE_OFFSET       EQU $ffff820e
HSCROLL           EQU $ffff8264
ST_SHIFT          EQU $ffff8260
SP_SHIFT          EQU $ffff8266
EXTCLK            EQU $ffff820a

MON_ID            EQU $ffff8006           ;Monitor-ID-Bits

VADDR_HIGH        EQU $ffff8205
VADDR_MID         EQU $ffff8207
VADDR_LOW         EQU $ffff8209
VBASE_HIGH        EQU $ffff8201
VBASE_MID         EQU $ffff8203
VBASE_LOW         EQU $ffff820d

;XBIOS-Video-Modi
ST_LOW            EQU 0
ST_MID            EQU 1
ST_HIGH           EQU 2
FALCONMDS         EQU 3
TT_MID            EQU 4
TT_HIGH           EQU 6
TT_LOW            EQU 7

;Defines for Falcon-modecode
VERTFLAG          EQU $0100
STMODES           EQU $80
OVERSCAN          EQU $40
PAL               EQU $20
NTSC              EQU $00
VGA               EQU $10
TV                EQU $00

COL80             EQU $08
COL40             EQU $00
BPS8C             EQU $07
NUMCOLS           EQU $07
BPS32             EQU $05
BPS16             EQU $04
BPS8              EQU $03
BPS4              EQU $02
BPS2              EQU $01
BPS1              EQU $00

VTF_BIT           EQU 8
STC_BIT           EQU 7
OVS_BIT           EQU 6
PAL_BIT           EQU 5
VGA_BIT           EQU 4
CLM_BIT           EQU 3

MONO_MON          EQU 0                   ;ST-Monochrommonitor
COLOR_MON         EQU 1                   ;ST-Farbmonitor
VGA_MON           EQU 2                   ;VGA-Monitor
TV_MON            EQU 3                   ;Fernseher
