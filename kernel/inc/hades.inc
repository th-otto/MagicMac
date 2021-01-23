dma_sctr2      =     0xffff8717       /* extra scsi control register.bit 0 = count0/eop. bit 1 = buserror */

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
