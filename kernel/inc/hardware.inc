
BPS1 equ 0
BPS2 equ 1
BPS4 equ 2
BPS8 equ 3
BPS16 equ 4
BPS32 equ 5
BPS8C equ 7
NUMCOLS equ 7

COL80 equ $08
COL40 equ 0
CLM_BIT equ 3
VGA equ $10
TV equ 0
VGA_BIT equ 4
PAL equ $20
NTSC equ 0
PAL_BIT equ 5
OVERSCAN equ $40
OVS_BIT equ 6
STMODES equ $80
STC_BIT equ 7
VERTFLAG equ $100
VTF_BIT equ 8

MONO_MON  equ 0
COLOR_MON equ 1
VGA_MON   equ 2
TV_MON    equ 3

ST_SHIFT equ $ffff8260

TT_LOW  equ 7
FALCONMDS equ 3

MON_ID      equ $ffff8006
EXTCLK      equ $ffff820a
LINE_OFFSET equ $ffff820e

VWRAP equ $ffff8210
HSCROLL equ $ffff8264
SP_SHIFT equ $ffff8266
HHC equ $ffff8280
HHT equ $ffff8282
HBB equ $ffff8284
HBE equ $ffff8286
HDB equ $ffff8288
HDE equ $ffff828a
HSS equ $ffff828c
HFS equ $ffff828e
HEE equ $ffff8290
VFC equ $ffff82a0
VFT equ $ffff82a2
VBB equ $ffff82a4
VBE equ $ffff82a6
VDB equ $ffff82a8
VDE equ $ffff82aa
VSS equ $ffff82ac
VXX equ $ffff82c0
VCO equ $ffff82c2

XON  equ $11
XOFF equ $13

gpip   equ $fffffa01
aer    equ $fffffa03
ddr    equ $fffffa05
iera   equ $fffffa07
ierb   equ $fffffa09
ipra   equ $fffffa0b
iprb   equ $fffffa0d
isra   equ $fffffa0f
isrb   equ $fffffa11
imra   equ $fffffa13
imrb   equ $fffffa15
vr     equ $fffffa17
tacr   equ $fffffa19
tbcr   equ $fffffa1b
tcdcr  equ $fffffa1d
tadr   equ $fffffa1f
tbdr   equ $fffffa21
tcdr   equ $fffffa23
tddr   equ $fffffa25
scr    equ $fffffa27
ucr    equ $fffffa29
rsr    equ $fffffa2b
tsr    equ $fffffa2d
udr    equ $fffffa2f

GPIP_TT   equ $fffffa81
ISRA_TT   equ $fffffa8f
RSR_TT    equ $fffffaab
TSR_TT    equ $fffffaad
UDR_TT    equ $fffffaaf


giselect equ $ffff8800
giread   equ $ffff8800
giwrite  equ $ffff8802

keyctl   equ $fffffc00
keybd    equ $fffffc02
midictl  equ $fffffc04
midi     equ $fffffc06

sccctl_a equ $ffff8c81
_scc_dat equ 2
sccctl_b equ $ffff8c85

IDE_Base         equ $fff00000
IDE_Data         equ $00
IDE_SectorCount  equ $09
IDE_SectorNumber equ $0d
IDE_CylL         equ $11
IDE_CylH         equ $15
IDE_DriveHead    equ $19
IDE_StatReg      equ $1d
IDE_Command      equ $1d
IDE_StatReg2     equ $39

M_fdc_hdmode equ $ffff860E
