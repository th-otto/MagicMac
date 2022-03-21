;Blitteradressen
HalftoneRAM         EQU $ffff8a00
SrcX_Inc            EQU $ffff8a20
SrcY_Inc            EQU $ffff8a22
SrcAddress          EQU $ffff8a24
ENDMASK1            EQU $ffff8a28
ENDMASK2            EQU $ffff8a2a
ENDMASK3            EQU $ffff8a2c
DestX_Inc           EQU $ffff8a2e
DestY_Inc           EQU $ffff8a30
DestAddress         EQU $ffff8a32
X_Cnt               EQU $ffff8a36
Y_Cnt               EQU $ffff8a38
HOP                 EQU $ffff8a3a
OP                  EQU $ffff8a3b
Line_Num            EQU $ffff8a3c

;Bitmaske fuer ST-SHFTMODE
SHFTMODE_ST         EQU $0300

;Bitmasken im TT_SHFTMODE
SAMPLEMODE          EQU $8000
GRAYMODE            EQU $1000
SHFTMODE            EQU $0700
PALETTE             EQU $0f

;Bitnummern im TT_SHFTMODE
SAMPLE_BIT          EQU 15
GRAY_BIT            EQU 12

;Adressen der Grafikhardware
ST_SHFTMODE         EQU $ffff8260
ST_PALETTE          EQU $ffff8240
TT_SHFTMODE         EQU $ffff8262
TT_PALETTE          EQU $ffff8400

MSTE_CACHE_CTRL     EQU $ffff8e21
