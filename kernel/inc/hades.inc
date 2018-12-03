sctr1          equ     $ffff8715       ;normales scsi control register.    bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror
sctr2          equ     $ffff8717       ;zusaetzlicher scsi control register.bit 0 = count0/eop. bit 1 = buserror
psdm           equ     $ffff8741       ;pseudo dma adresse fuer daten
auu            equ     $ffff8701
amu            equ     $ffff8703
aml            equ     $ffff8705
all            equ     $ffff8707
cuu            equ     $ffff8709
cmu            equ     $ffff870B
cml            equ     $ffff870D
cll            equ     $ffff870F

longframe           EQU $059e                   ;Flag fuers Stackframe
