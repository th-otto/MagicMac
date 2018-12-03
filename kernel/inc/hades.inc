restdaten      equ     $ffff8710
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
Exept61             equ $00f4                   ; exception vector #61: unimplemented integer instruction

;video resolution  2=st high 6=tt high           
vidmo           equ 2
vidmo00         equ vidmo*$100           
pci_vga_base    equ $80000000   ;screen ram beginn
isa_vga_base    equ $ff000000   ;screen ram beginn
pci_vga_reg     equ $b0000000   ;vga register
isa_vga_reg     equ $fff00000   ;vga register
pci_conf1       equ $a0010000   ;pci config
pci_conf2       equ $a0020000   ;pci config
pci_conf3       equ $a0040000   ;pci config
pci_conf4       equ $a0080000   ;pci config
mem_max         equ $40000000   ;memory maximum 1 GB

;hades hardwareregister
main_status    equ $fff00080
data_reg       equ $fff00082
ldor           equ $fff000c0
ldcr           equ $fff000e0

; Hardwareregister
dmahigh        equ $FFFF8608
dmamid         equ $FFFF860B
dmalow         equ $FFFF860D

; sonstige Variablen
defhdinf       equ $302      ; Default hdinf. byt 0 -> anzahl versuche byt 1 -> taktrate (hd default)
ed             equ 0         ; clockraten fÿ verschiedene format
hd             equ 2
dd             equ 3
hlt            equ 3         ;head load time in milisekunden (in 1ms schriten 1-128ms)
hut            equ 120         ;head unload time in ms (in 16ms schritten 8-120ms)
