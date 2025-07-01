**********************************************************************
*
* Installation der Cookies auf dem Raven.
* Ich uebernehme hier Alvars Quelltext nur fuer den Raven
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
 move.l   #-1,(a5)+             ; non atari hardware
 ;clr.l    (a5)+                    ; ST

* _MCH Cookie:
* $00000:      ST und Mega ST
* $10000:      STe
* $10001:      Mega STE
* $20000:      TT
* $30000:      Falcon
 move.l   #'_MCH',(a5)+            ; Maschine: RAVEN
 move.l   #$00070000,(a5)+
 move.b   #0,machine_type          ; MagiC-interne Maschinen-Variable: ST

* _SND Cookie austesten (DMA Sound ?)
 moveq    #1,d0                    ; d0 initialisieren (kein DMA Sound)
 move.l   #'_SND',(a5)+
 move.l   d0,(a5)+                 ; und _SND eintragen

* _IDT-Cookie
 moveq #0,d0
 move.w   syshdr+$1c,d0
 bclr     #0,d0
 cmp.w    #(idt_tab_end-idt_tab),d0
 bcs.s    idt_ok
 moveq    #0,d0
idt_ok:
 move.w   idt_tab(pc,d0.w),d0
 move.l   #'_IDT',(a5)+
 move.l   d0,(a5)+

* MagiX- Cookie
 move.l   #'MagX',(a5)+
 move.l   #config_status,(a5)+

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
