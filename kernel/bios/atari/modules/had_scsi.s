* Original-SCSI-Routinen aus HADES-TOS

* (Tabsize=8)


;**********************************************************************************************
;fa 1.1.96:pseudo dma fuer scsi
; a0=basis adresse register
; a1=dma adresse
; a2=alter stackwert/adresse letztes zu uebertragendes long (restdaten!!)
; a3=sprungadresse/write back 3 adresse 
; a4=endadresse
; d0=divers
; d1=anzahl byts resp. restbyts des letzten sectors -1
; d2=dma start adresse
; d3=dtt0 alt
; d4=10000-anzahl buserrors
; d5=anzahl sectoren-1
*restdaten:     equ     $ffff8710
*sctr1:         equ     $ffff8715       ;normales scsi control register.    bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror
*sctr2:         equ     $ffff8717       ;zusaetzlicher scsi control register.bit 0 = count0/eop. bit 1 = buserror
*psdm:          equ     $ffff8741       ;pseudo dma adresse fuer daten
*auu:           equ     $ffff8701
*amu:           equ     $ffff8703
*aml:           equ     $ffff8705
*all:           equ     $ffff8707
*cuu:           equ     $ffff8709
*cmu:           equ     $ffff870B
*cml:           equ     $ffff870D
*cll:           equ     $ffff870F

scsi_int2:      movem.l d0-d7/a0-a4,-(sp)
                move.b  auu.w,d2
                lsl.l   #8,d2
                move.b  amu.w,d2
                lsl.l   #8,d2
                move.b  aml.w,d2
                lsl.l   #8,d2
                move.b  all.w,d2
                move.b  cuu.w,d1
                lsl.l   #8,d1
                move.b  cmu.w,d1
                lsl.l   #8,d1
                move.b  cml.w,d1
                lsl.l   #8,d1
                move.b  cll.w,d1
;               tst.l   d1
;               beq     scsiendx
                move.l  8.w,-(sp)               ;alter buserrorvector sichern
                bclr    #1,sctr1.w              ;dma off -> int 2 off
                and.b   #$fc,sctr2.w            ;eop, bus error off
                move.l  #scsibuserror,8.w       ;neuen setzen
                dc.w    _movecd,_dtt0+$3000     ;dtt0 nach d3
                dc.w    _movecd,_itt0+$6000       ;itt0 nach d6
                dc.w    _movecd,_cacr+$7000       ;cacr nach d7
                move.l  #$7fc020,d0             ;ram und eprom copy back
                dc.w    _movec,_dtt0            ;copy back setzen
                dc.w    _movec,_itt0            
                move.l  #$80008000,d0
                dc.w    _movec,_cacr              ;cache on
                dc.w    cpusha
                nop
                move.l  a7,a2                   ;alter stack
                move.w  #10000,d4               ;10000 versuche = ca. 40ms (1 buserror ist 4us(=min. transferrate=250kb/sec)) -> min. 1500U/min
                lea     psdm.w,a0
                move.l  d2,a1                   ;dma adresse
                move.l  d2,a4                   ;startadresse
                add.l   d1,a4                   ;+laenge=endadresse
scsijmp:        subq.l  #1,d1
                move.l  d1,d5                   ;anzahl byts-1
                lsr.l   #8,d5                   ;/512
                lsr.l   #1,d5                   ;=anzahl ganze sectoren
                and.l   #$1ff,d1                ;anzahl byts -1 im naechsten sector
                lea     scsiwrlb,a3             ;sonst tabelle read nach a3
                btst    #0,sctr1.w              ;write?
                bne     scsibs                  ;ja->
                lea     scsirdlb,a3             ;sonst tabelle read nach a3
scsibs:         sub.l   d1,a3                   ;x2 weil jeder befehl wordlaenge hat
                sub.l   d1,a3                   ;- = aktuelle einsprungadresse
                jmp     (a3)                    ;verzweigen
scsiwrloop:     move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
                move.b  (a1)+,(a0)      ;byt verschieben
scsiwrlb:       tst     d5              ;letztes byt?
                bne     scsiwrlb1       ;nein->
                bset    #0,sctr2.w      ;sonst count0/eop on
scsiwrlb1:      move.b  (a1)+,(a0)      ;byt verschieben
                dbf     d5,scsiwrloop   ;wiederholen bis fertig
                bra     scsiweiter
scsirdloop:     move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
                move.b  (a0),(a1)+              ;byt verschieben
scsirdlb:       tst     d5                      ;letztes byt?
                bne     scsirdlb1               ;nein->
                bset    #0,sctr2.w              ;count0/eop on
scsirdlb1:      move.b  (a0),(a1)+              ;byt verschieben
                dbf     d5,scsirdloop           ;wiederholen bis fertig
                move.l  a1,d2
                and.b   #$fc,d2                 ;letztes long
                move.l  d2,a0
                move.l  (a0),restdaten.w        ;restdaten nach register
scsiweiter:     moveq   #0,d1                   ;fertig
scsiend:        bset    #1,sctr1.w              ;dma on = ein int 7 scharf
                dc.w    _movec,_dtt0+$3000      ;dtt0 zurueck
                dc.w    _movec,_itt0+$6000      ;itt0 zurueck
                dc.w    _movec,_cacr+$7000      ;cacr zurueck
                dc.w    cpusha
                nop
                move.b  d1,cll.w                ;byt zaehler zurueck
                lsr.l   #8,d1
                move.b  d1,cml.w
                lsr.l   #8,d1
                move.b  d1,cmu.w
                lsr.l   #8,d1
                move.b  d1,cuu.w
                move.l  a1,d1                   ;neue dma adresse
                move.b  d1,all.w
                lsr.l   #8,d1
                move.b  d1,aml.w
                lsr.l   #8,d1
                move.b  d1,amu.w
                lsr.l   #8,d1
                move.b  d1,auu.w
                move.l  (sp)+,8.w               ;alter buserrorvector wieder herstellen
                movem.l (sp)+,d0-d7/a0-a4
                rte
;----------------------------------------------- scsi buserror
scsibuserror:   cmp.w   #40,longframe.w         ;mc68040?
                bne     scsibuer60              ;nein-> mc68060
                btst    #0,sctr1.w              ;read?
                beq     scbueread40             ;ja->
                move.b  $f(a7),d0               ;wb3s?
                bpl     scb2                    ;nein
                cmp.l   $18(a7),a0              ;scsiadresse
                bne     scb2x                   ;nein
                subq.l  #1,a1                   ;-1 wegen prefecht (a1)+,(a0)
scb2:           tst.b   $11(a7)                 ;wb2s?
                bpl     scb1                    ;nein
                cmp.l   $20(a7),a0              ;scsiadresse
                bne     scb1x                   ;nein->
                subq.l  #1,a1                   ;-1 wegen prefecht (a1)+,(a0)
scb1:           tst.b   $13(a7)                 ;wb1s?
                bpl     scbuer40w               ;nein->
                cmp.l   $28(a7),a0              ;scsiadresse
                bne     scbuer40w               ;nein->
                subq.l  #1,a1                   ;-1 wegen prefecht (a1)+,(a0)
                bra     scbuer40w
scbueread40:    move.b  $0f(a7),d0              ;wb3s
                bpl     scbuer40w               ;nein->
                move.l  $18(a7),a3              ;adresse
                move.l  $1c(a7),d1              ;daten
                bsr     savewb
scbuer40w:      cmp.l   $14(a7),a0              ;scsidaten bereich?
                beq     scsitimeout             ;ja -> timout
scsibuerer:     bset    #1,sctr1.w              ;dma on = ein, int 7 scharf
                move.l  a2,a7                   ;alter stack
                dc.w    _movec,_dtt0+$3000      ;dtt0 zurueck
                dc.w    _movec,_itt0+$6000      ;itt0 zurueck
                dc.w    _movec,_cacr+$7000      ;cacr zurueck
                dc.w    cpusha
                nop
                or.b    #$03,sctr2.w            ;buserror- und eop-bit setzen
                move.l  (sp)+,8.w               ;alter buserrorvector wieder herstellen
                movem.l (sp)+,d0-d7/a0-a4
                rte
scsibuer60:     cmp.l   8(a7),a0                ;scsidaten bereich?
                bne     scsibuerer              ;nein-> bus error
scsitimeout:    move.l  a2,a7                   ;alter stack
                move.l  a4,d1                   ;enadresse
                sub.l   a1,d1                   ;-aktelle adresse=restbyt
                subq.w  #1,d4                   ;-1 versuch
                bpl     scsijmp                 ;abgelaufen?nein->wiedereinstieg
                bra     scsiend
scb2x:          move.l  $18(a7),a3
                move.l  $1c(a7),d1
                bsr     savewb
                bra     scb2
scb1x:          move.l  $20(a7),a3
                move.l  $24(a7),d1
                bsr     savewb
                bra     scb1
;-------------------------------------------------------------------------------------------------------------------
savewb:         move.l  #savewbber,8.w          ;neuer buserrorvector
                and.b   #$60,d0                 ;relevante bits
                bne     nolong                  ;ist nicht long->
                move.l  d1,(a3)                 ;sonst long schreiben
                nop
                rts
nolong:         cmp.b   #$20,d0                 ;byt?
                beq     ibyt                    ;ja->
nolong2:        move.w  d1,(a3)                 ;sonst word speichern
                nop
                rts
ibyt:           move.b  d1,(a3)                 ;byt speichern
                nop
                rts
savewbber:      move.l  #scsibuserror,8.w
                rte
