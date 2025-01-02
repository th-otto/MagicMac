/*
 *
 * Video-Initialisierung fuer Hades
 *
 */

boot_init_video:
                bsr screen_init

                move.l  #$8000,d0               ;instruction cache on
                dc.w    _movec,_cacr            ;cache setzen

                if vidmo=2
                move.w #1999,d1                 ; 640x400 bits = 32000/16-1 byt loeschen
                else
                move.w #9599,d1                 ;1280*960 bits = 153600/16-1
                endif
                
                move.l  a0,$44e.w               ;screen adr setzen
L0020:          clr.l   (a0)+                   ;screen loeschen
                clr.l   (a0)+
                clr.l   (a0)+
                clr.l   (a0)+
                dbf d1,L0020

                rts


;grafik karte initialisieren
screen_init:    lea     pci_conf1,a3
                cmp.b   #$32,3(a3)
                beq     config
                lea     pci_conf2,a3
                cmp.b   #$32,3(a3)
                beq     config
                lea     pci_conf3,a3
                cmp.b   #$32,3(a3)
                beq     config
                lea     pci_conf4,a3
                cmp.b   #$32,3(a3)
                beq     config

pcim64t:        cmp.w   #$5847,pci_conf1+2
                beq     m64init
                cmp.w   #$5847,pci_conf2+2
                beq     m64init
                cmp.w   #$5847,pci_conf3+2
                beq     m64init
                cmp.w   #$5847,pci_conf4+2
                bne     isainit

m64init:
                lea     $7fe70000,a0           ;source emulator.bin mach64 pci

m64init2:       lea     $300000,a1             ;dest (uebersetzt mit org $300000)
                move.l  a1,a2
                move.w  #430,d0                ;laenge(6824)/16
m64copy:        move.l  (a0)+,(a1)+            ;copieren
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                dbf     d0,m64copy             ;wiedeholen bis fertig
                jmp     (a2)                   ;einsprung
                rts
                
;pci et4000 grafikkarte initialisieren
config:         move.b  #3,4(a3)                ;io und mem on
                lea     pci_vga_reg,a2
                cmp.b   #8,2(a3)                ;et6000?
                bne     no_et6000               ;nein->
                move.b  #3,$40(a3)              ;et6000 init
                move.b  #$15,$44(a3)            ;et6000 init
no_et6000:      move.b  #$27,$03C2(A2)          ;misc
                move.b  #1,$03C3(A2)            ;videosub
                move.b  #$17,$03D4(A2)      
                clr.b   $03D5(A2)               ;color
                move.b  #$11,$03D4(A2)          ;color
                clr.b   $03D5(A2)
                move.b  #$ff,$3c6(a2)           ;pel mask
                clr.b   $03C4(A2)               ;ts
                clr.b   $03C5(A2)
                move.b  #3,$03BF(A2) 
                move.b  #$A0,$03D8(A2)

                lea     $03C4(A2),A0
                lea     ts+1,A1
                cmp.b   #8,2(a3)                ;et6000?
                bne     iset1                   ;nein->
                lea     ts6+1,a1
iset1:          moveq   #1,D1
                moveq   #8,D0
;ts registersatz transferieren
loop_ts:        move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   loop_ts
                clr.b   (A0)
                move.b  ts,1(A0)                ;fa_8.11.94:
                
                lea     $03c6(a2),a0            ;pel mask
                move.b  (a0),d0
                move.b  (a0),d0
                move.b  (a0),d0
                move.b  (a0),d0
                moveq   #0,d0
                cmp.b   #8,2(a3)                ;et6000?
                bne     iset2                   ;nein->
                moveq   #-1,d0
iset2:          move.b  d0,(a0)                 ;pel mask
                
                lea     $03D4(A2),A0
                lea     crtc,A1
                moveq   #0,D1
                moveq   #$3e,D0                 
;crtc registersatz transferieren
loop_crtc:      move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   loop_crtc
                lea     $03CE(A2),A0
                lea     gdc,A1
                moveq   #0,D1
                moveq   #9,D0
;gdc registersatz transferieren
loop_gdc:       move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   loop_gdc
                move.b  $03DA(A2),D0
                lea     $03C0(A2),A0
                lea     atc,A1
                moveq   #0,D1
                moveq   #$18,D0
;atc registersatz transferieren
loop_atc:       move.b  D1,(A0)
                move.b  (A1)+,(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   loop_atc
                move.b  #$20,(A0)
                lea     $03C8(A2),A0
                moveq   #0,D1
                move.w  #$0100,D0
                move.b  D1,(A0)
                move.b  #$FF,1(A0)
                move.b  #$FF,1(A0)
                move.b  #$FF,1(A0)
                addq.w  #1,D1
;farbregister auf monochrom
loop_dac:       move.b  D1,(A0)
                clr.b   1(A0)
                clr.b   1(A0)
                clr.b   1(A0)
                addq.w  #1,D1
                cmp.w   D0,D1
                bne.s   loop_dac
                lea     pci_vga_base,a0
                rts

atc:            DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
                DC.B $01,$00,$0F,$00,$00,$00,$00,$00
crtc:           DC.B $60,$4F,$4F,$84,$56,$86,$c1,$1F,$00,$40,$00,$00,$00,$00,$07,$30
                DC.B $98,$00,$8F,$28,$40,$8F,$C2,$a3,$FF,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$80,$28,$00,$00,$00,$13,$09,$00,$00,$00,$00,$00,$00,$00,$00
gdc:            DC.B $00,$00,$00,$00,$00,$00,$01,$0F,$FF
ts:             DC.B $03,$01,$0F,$00,$06,$00,$00,$B4
ts6:            DC.B $03,$05,$0F,$00,$06,$00,$00,$B4
                even

;isa et4000 grafikkarte initialisieren
isainit:        lea     $7fe72000,a0            ;source emulator.bin mach64 isa
                cmp.b   #$ff,$fff103c0          ;mach64?
                beq     m64init2                ;ja->
                lea     isa_vga_reg,A2
                move.b  #7,$03C2(A2)            ;misc
                move.b  #1,$03C3(A2)            ;videosub
                move.b  #$17,$03B4(A2)          ;crtc mode control
                clr.b   $03B5(A2)               ;mono
                move.b  #$17,$03D4(A2)      
                clr.b   $03D5(A2)               ;color
                move.b  #$11,$03B4(A2)          ;vertical start
                clr.b   $03B5(A2)
                move.b  #$11,$03D4(A2)          ;color
                clr.b   $03D5(A2)
                move.b  #$FF,$03C6(A2)          ;pel mask
                clr.b   $03C4(A2)               ;ts
                clr.b   $03C5(A2)
                move.b  #3,$03BF(A2) 
                move.b  #$A0,$03D8(A2)
                lea     $03C4(A2),A0
                lea     isats+1,A1
                moveq   #1,D1
                moveq   #$07,D0
;ts registersatz transferieren
isaloop_ts:     move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   isaloop_ts
                clr.b   (A0)
                move.b  isats,1(A0)              ;fa_8.11.94:
                
                lea     $03c6(a2),a0             ;pel mask
                move.b  (a0),d0
                move.b  (a0),d0
                move.b  (a0),d0
                move.b  (a0),d0
                move.b  #0,(a0)
                
                lea     $03D4(A2),A0
                lea     isacrtc,A1
                moveq   #0,D1
                moveq   #$38,D0
;crtc registersatz transferieren
isaloop_crtc:   move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   isaloop_crtc
                lea     $03CE(A2),A0
                lea     isagdc,A1
                moveq   #0,D1
                moveq   #10,D0
;gdc registersatz transferieren
isaloop_gdc:    move.b  D1,(A0)
                move.b  (A1)+,1(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   isaloop_gdc
                move.b  $03DA(A2),D0
                lea     $03C0(A2),A0
                lea     isaatc,A1
                moveq   #0,D1
                moveq   #$18,D0
;atc registersatz transferieren
isaloop_atc:    move.b  D1,(A0)
                move.b  (A1)+,(A0)
                addq.w  #1,D1
                cmp.w   D1,D0
                bne.s   isaloop_atc
                move.b  #$20,(A0)
                lea     $03C8(A2),A0
                moveq   #0,D1
                move.w  #$0100,D0
                move.b  D1,(A0)
                move.b  #$FF,1(A0)
                move.b  #$FF,1(A0)
                move.b  #$FF,1(A0)
                addq.w  #1,D1
;farbregister auf monochrom
isaloop_dac:    move.b  D1,(A0)
                clr.b   1(A0)
                clr.b   1(A0)
                clr.b   1(A0)
                addq.w  #1,D1
                cmp.w   D0,D1
                bne.s   isaloop_dac
                lea     isa_vga_base,a0
                rts

isaatc:         DC.B $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
                DC.B $01,$FF,$0F,$00,$00,$00,$00,$00
isacrtc:        DC.B $6A,$4F,$4F,$8E,$59,$87,$BF,$1F,$00,$40,$00,$00,$00,$00,$00,$00
                DC.B $9A,$04,$8F,$28,$00,$8F,$C0,$C3,$FF,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$00,$10,$70,$0F
isagdc:         DC.B $00,$00,$00,$00,$00,$00,$01,$0F,$FF,0
isats:          DC.B $03,$09,$0F,$00,$06,$00,$00,$A4
                even
 
