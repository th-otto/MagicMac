**********************************************************************
*
* Installation der Cookies auf dem Hades.
* Ich uebernehme hier Alvars Quelltext nur fuer den Hades
* und behalte meinen eigenen fuer Atari.
*
* Installiert werden:
*
*    _CPU
*    _FPU
*    _VDO
*    _MCH
*    _SND
*    _SWI (wenn Maschine >= STe)
*    _FDC (wenn HD-Floppy installiert)
*    MagX
*

install_cookies:
 move.l   a5,-(sp)
 lea      cookies,a5               ; Adresse der Cookies
 move.l   a5,_p_cookies            ; Pointer setzen
* _CPU Cookie, Loword enthaelt den <cpu_typ>
 move.l   #'_CPU',(a5)+
 clr.w    (a5)+
 move.w   cpu_typ,(a5)+


INCLUDE "..\..\bios\atari\modules\fpudetec.inc"


* _VDO Cookie eintragen
 move.l   #'_VDO',(a5)+
 clr.l    (a5)+                    ; ST

; _MCH Cookie:
; $00000:      ST und Mega ST
; $10000:      STe
; $10001:      Mega STE
; $20000:      TT
; $30000:      Falcon

 move.b   #3,machine_type          ; MagiC-interne Maschinen-Variable: TT
 moveq    #2,d0
 swap     D0
; move.w  d0,-4(a5)                ; Video: TT (OK, ist erstmal nicht richtig!)
; move #0,-4(a5)
;move -1,-4(a5)
 move.l #-1,-4(a5)                 ; Video: -1 = nix an Hardware herumfummeln!
 move.l   #'_MCH',(a5)+            ; Maschine: TT
 move.l   d0,(a5)+




; *** Der 'id'-Cookie:
; Hier kann man nun die im Hades vorhandene Zusatzhardware
; abfragen bzw. eintragen.
; 16 Bits duerften erst einmal eine Weile reichen

;Bit 0..15:  im Hades gefundene Hardware
;         (ist das jeweilige Bit Null ist diese Hardware nicht vorhanden).
; Bit     0    ROM-Port 
; Bit     1    VME-Bus
; Bit     2    SCSI-Karte
; Bit   3       Atari DMA
; Bit 4-11     reserviert
; Bit 12-15    reserviert fuer Video Hardware
;         Bit 12 = ET4000 am ISA Bus 
;         Bit 13 = Viedeokarte am VME Bus
;         Bit 14 = PCI-Bus Graphikkarte 
; Bit 16-31     Maschinenversion (derzeit 0)

          moveq     #6,d0                   ; scsi und vme immer

; Test auf Atari DMA
          move.l    a7,a2
          move.l    $8.w,a1
          move.l    #no_atari_dma,$8.w      ;buserrorvector setzen
          moveq     #6,d0                   ;vme und scsi immer
          tst.w     $ffff8604
          bset #3,d0               ; merken
no_atari_dma:   move.l   a2,a7
          move.l    a1,8.w

          move.l    #'hade',(a5)+
      move.l   $44e.w,d1      ; adresse bildspeicher
      cmp.l    #$a0000000,d1       ;pci
      bcc nopcigk             ;nein->
        bset   #14,d0              ;pci grafikkarte eintragen
          bra  gkset
nopcigk:  cmp.l     #$ff000000,d1       ;vme?
          bcc  novmegk                 ;nein->
          bset #13,d0                  ;set vme grafikkarte
          bra  gkset
novmegk:  bset #12,d0              ;sonst isa bus grafikkarte eintragen
gkset: move.l  d0,(a5)+       ;Hade setzen








* _SND Cookie austesten (DMA Sound ?)
 moveq    #1,d0                    ; d0 initialisieren (kein DMA Sound)
 move.l   #'_SND',(a5)+
 move.l   d0,(a5)+                 ; und _SND eintragen

* _SWI eintragen (nur bei STe und hoeher)
* machine_type: 0=ST, 1=STE, 2=MegaSTE, 3=TT
 move.l   #'_FDC',(a5)+
 move.l   #'hade',(a5)+
 st.b     hd_flag

cok_nosw:
 move.l   a0,8                     ; alten Busfehler restaurieren
 move.l   a2,sp                    ; Stack wiederherstellen

* _IDT-Cookie

 move.l   #'_IDT',(a5)+
 moveq #0,d0
 move.w   syshdr+$1c,d0
 bclr     #0,d0
 cmp.w    #(idt_tab_end-idt_tab),d0
 bcs.s    idt_ok
 moveq    #0,d0
idt_ok:
 move.w idt_tab(pc,d0.w),d0
 move.l d0,(a5)+



* MagiX- Cookie
 move.l   #'MagX',(a5)+
 move.l   #config_status,(a5)+

* Hades-Cookie
*move.l   #'hade',(a5)+
*clr.l    (a5)+

* Endmarkierung
 clr.l    (a5)+
 move.l   #NCOOKIES,(a5)           ; Platz fuer insgesamt 20+1 Cookies
 move.l   (sp)+,a5
 rts


idt_tab:
   dc.w $002f ; COUNTRY_US: 12h/MDY/'/'
   dc.w $112e ; COUNTRY_DE: 24h/DMY/'.'
   dc.w $112f ; COUNTRY_FR: 24h/DMY/'/'
   dc.w $112f ; COUNTRY_UK: 24h/DMY/'/'
   dc.w $112f ; COUNTRY_ES: 24h/DMY/'/'
   dc.w $102f ; COUNTRY_IT: 24h/MDY/'/'
   dc.w $122d ; COUNTRY_SE: 24h/YMD/'-'
   dc.w $112e ; COUNTRY_SF: 24h/DMY/'/'
   dc.w $112e ; COUNTRY_SG: 24h/DMY/'.'
   dc.w $112d ; COUNTRY_TR: 24h/DMY/'-'
   dc.w $112e ; COUNTRY_FI: 24h/DMY/'.'
   dc.w $112e ; COUNTRY_NO: 24h/DMY/'.'
   dc.w $112d ; COUNTRY_DK: 24h/DMY/'-'
   dc.w $102f ; COUNTRY_SA: 24h/MDY/'/'
   dc.w $102d ; COUNTRY_NL: 24h/DMY/'-'
   dc.w $112e ; COUNTRY_CZ: 24h/DMY/'.'
   dc.w $122d ; COUNTRY_HU: 24h/YMD/'-'
idt_tab_end:
