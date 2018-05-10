**********************************************************************
*
* Installation der Cookies
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
 move.l   sp,a2                    ; Stackpointer retten
 move.l   a5,_p_cookies            ; Pointer setzen
* _CPU Cookie, Loword enthält den <cpu_typ>
 move.l   #'_CPU',(a5)+
 clr.w    (a5)+
 move.w   cpu_typ,(a5)+

* FPU bestimmen

* Nach Atari Dokumentation ist die Belegung wie folgt:
* _FPU Cookie ist IMMER da !!!
* Belegung im Highword:
*  0 = keine Hardware- FPU
*  1 = Atari Register FPU (memory mapped)
*  2 = LineF FPU
*  3 = Atari Register FPU + LineF FPU
*  4 = mit Sicherheit 68881 LineF FPU
*  5 = Atari Register FPU + mit Sicherheit 68881 LineF FPU
*  6 = mit Sicherheit 68882 LineF FPU
*  7 = Atari Register FPU + mit Sicherheit 68882 LineF FPU
*  8 = 68040 internal LineF FPU
*  9 = Atari Register FPU + 68040 internal LineF FPU
* Das Loword ist für eine spätere eventuelle
* softwaremäßige LineF- Emulation reserviert und derzeit immer 0

 moveq    #0,d1
* Test auf (Atari) FPU
 movea.l  8,a0                     ; Busfehler retten
 move.l   #_noafpu,8               ; neuen Busfehler eintragen
 move.l   $fffffa46,d0
 move.l   d1,$fffffa46             ; Atari FPU initialisieren
 addq.w   #1,d1                    ; Bit0: SFP004 ("Atari FPU")
_noafpu:
* Test auf (Line F) FPU
 movea.l  $2c,a1                   ; LineF retten
 move.l   #_nolfpu,$2c             ; bei LineF Trap gehts dahin
;move.l   #_nolfpu,$34             ; TOS 2.05
 fsave    -(sp)                    ; und noch testen, was für eine FPU
 move.w   (sp),d0                  ; Version Bytes ($18=881,$38=882,$40=68040)
 cmp.b    #$18,d0                  ; 68881 ?
 beq.b    _is881
 cmp.b    #$38,d0                  ; 68882 ?
 beq.b    _is882
 cmp.b    #$40,d0                  ; 68040 internal FPU ?
 bne.b    _no040
 addq.w   #2,d1                    ; 8: 68040
_is882:
 addq.w   #2,d1                    ; 6: 68882
_is881:
 addq.w   #2,d1                    ; 4: 68881
_no040:
 addq.w   #2,d1                    ; 2: LineF- FPU
 st.b     is_fpu
_nolfpu:                           ; keine LineF FPU
 swap     d1                       ; Kennung ins Hiword
 move.l   a1,$2c                   ; alten LineF restaurieren
 move.l   a2,sp                    ; Stack wiederherstellen
 move.l   #'_FPU',(a5)+
 move.l   d1,(a5)+                 ; und FPUs eintragen

* _VDO Cookie eintragen
 move.l   #'_VDO',(a5)+
 clr.l    (a5)+                    ; ST

; _MCH Cookie:
; $00000:      ST und Mega ST
; $10000:      STe
; $10001:      Mega STE
; $20000:      TT
; $30000:      Falcon

 clr.b    machine_type             ; normaler ST
 moveq    #0,d0
 move.l   #_inst_tt,8
 move.b   VXX.w,d1                 ; Pixelclock-Register Falcon (Busfehler
                                   ;   bei anderen Rechnern)
 move.b   MON_ID.w,d1              ; Monitor-ID-Bits des Falcon auslesen
                                   ;   dieses Register ergibt
                                   ;   auf STs mit IMP-MMU keinen Busfehler ...
 lsr.w    #6,d1
 and.w    #3,d1                    ; Monitortyp
 move.w   d1,monitor
 moveq    #3,d0                    ; ist Falcon
 move.w   d0,-4(a5)                ; Video auf Falcon
 addq.b   #4,machine_type          ; Falcon erkannt
 bra.b    _instmch

_inst_tt:
 move.l   #_instmch,8
 move.w   $ffff8400,d1             ; TT Palette Reg 0
 moveq    #2,d0                    ; ist TT
 move.w   d0,-4(a5)                ; Video auf TT
 addq.b   #3,machine_type          ; TT erkannt
_instmch:
 swap     d0                       ; Kennung ins Hiword
 move.l   #'_MCH',(a5)+
 move.l   d0,(a5)+

* _SND Cookie austesten (DMA Sound ?)
 moveq    #1,d0                    ; d0 initialisieren (kein DMA Sound)
 move.l   #_nodmasound,8
* DMA Sound initialisieren (STe)
 clr.w    $ffff8900                ; Sound DMA Control, ST -> Busfehler
 lea      icook_dmastable(pc),a1
 move.w   (a1)+,$ffff8924          ; Microwire mask register
 bra.b    icook_l1
icook_dmastable:
 DC.W     $0ffe
 DC.W     $09d1
 DC.W     $0aa9
 DC.W     $0a29
 DC.W     $090d
 DC.W     $088d
 DC.W     $0803
 DC.W     $0000
icook_loop:
 move.w   d1,$ffff8922             ; Microwire data register
icook_loop2:
 tst.w    $ffff8922
 bne.b    icook_loop2
icook_l1:
 move.w   (a1)+,d1
 bne.b    icook_loop

 addq.w   #2,d0                    ; ging gut, also DMA Sound

;Falcon? Dann Bits für neue Soundhardware setzen

 cmp.b    #4,machine_type
 bne.b    tst_tt_snd
 moveq    #$1f,d0                  ; SND-Cookie setzen
 bra.b    _nodmasound

tst_tt_snd:
 tst.b    machine_type             ; TT ?
 bne.b    _nodmasound              ; ja dann nur eintragen
 addq.b   #1,machine_type          ; mindestens 1040 STE
 move.w   #1,-4(a5)                ; ansonsten STe in _MCH eintr.
 move.w   #1,-12(a5)               ; und in _VDO auch
 tst.b    $ffff8e09                ; Test auf Mega STe
                                   ; nein -> _nodmasound
 move.w   #$10,-2(a5)              ; Loword von _MCH
 addq.b   #1,machine_type          ; 2=Mega STE
_nodmasound:
 move.l   #'_SND',(a5)+
 move.l   d0,(a5)+                 ; und _SND eintragen

* _SWI eintragen (nur bei STe und höher)
* machine_type: 0=ST, 1=STE, 2=MegaSTE, 3=TT
 sf.b     hd_flag                  ; keine HD-Unterstützung
 tst.b    machine_type             ; ST ?
 beq.b    cok_nosw                 ; ja, kein _SWI
 move.l   #'_SWI',(a5)+
 move.w   $ffff9200,d0             ; Joystick fire buttons ?
 lsr.w    #8,d0                    ; Lobyte wegschieben
 move.l   d0,(a5)+
* _FDC
 btst     #6,d0                    ; HD-Laufwerk da ?
 bne.b    icook_l2                ; nein
;move.b   #8,$1820                 ; TOS 3.06: Fastload für A: aktivieren
 move.l   #'_FDC',(a5)+
 move.l   #$1415443,(a5)+          ; '\1ATC'
 st.b     hd_flag                  ; HD-Unterstützung ein
icook_l2:

cok_nosw:
 move.l   a0,8                     ; alten Busfehler restaurieren
 move.l   a2,sp                    ; Stack wiederherstellen

* _IDT-Cookie

 move.l   #'_IDT',(a5)+
     IF   COUNTRY=FRG
 move.l   #$112e,(a5)+             ; 24h/DMY/'.'
     ENDIF
     IF   COUNTRY=USA
 move.l   #$002f,(a5)+             ; 12h/MDY/'/'
     ENDIF
     IF   COUNTRY=UK
 move.l   #$112d,(a5)+             ; 24h/DMY/'-'
     ENDIF
     IF   COUNTRY=FRA
 move.l   #$112f,(a5)+             ; 24h/DMY/'/'
     ENDIF

* MagiX- Cookie
 move.l   #'MagX',(a5)+
 move.l   #config_status,(a5)+

* Endmarkierung
 clr.l    (a5)+
 move.l   #NCOOKIES,(a5)           ; Platz für insgesamt 20+1 Cookies
 move.l   (sp)+,a5
 rts
