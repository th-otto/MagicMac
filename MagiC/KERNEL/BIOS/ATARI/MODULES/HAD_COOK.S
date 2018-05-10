**********************************************************************
*
* Installation der Cookies auf dem Hades.
* Ich übernehme hier Alvars Quelltext nur für den Hades
* und behalte meinen eigenen für Atari.
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



*********
* Ausschnitt aus Hades-Doku zur FPU:

; .28
; Diese Stelle war eine der trickreichsten !!!
; Beim 68881 und 68882 reicht ein schlichtes FNOP um beim
; naechsten FSAVE statt eines NULL-Frame (habe noch nichts getan)
; einen IDLE-Frame (habe schon was getan, aber gerade nix mehr zu tun)
; zu erhalten, der dann auch ein Version Byte enthaelt. Das dieses Version
; Byte beim 68040 und 68060 an anderer Stelle zu finden ist, konnte man
; ja noch so halbwegs der Doku entnehmen, dass der 68040 ein FNOP aber
; schlichtweg wegoptimiert und danach immer noch einen NULL-Frame liefert
; allerdings nicht (Puh, DAS zu finden hat mich 2 Tage und ich weiss nicht
; wie viele gebrannte Eproms gekostet (wann bekommt die Medusa endlich
; Static-Rams statt EPROMs ...), denn wenn ich's als externes
; Programm probiert habe, hatte die FPU ja schon was getan und antwortete
; auch auf ein FNOP mit dem erwarteten IDLE-Frame. Beim Booten stand im
; FPU-cookie aber natuerlich immer nur 2 (LineF-FPU Typ unbekannt)). Jetzt
; wird statt FNOP einfach ein FTST.X FP0 verwendet - und siehe da - es geht ...

;(fa_10.11.94)(1_12_94):einigie änderungen

;         dc.l $F2004000      ; fmove.l d0,fp0
;         dc.w $F327               ; fsave   -(sp)
;         move.l    (sp),d2        ; Version Bytes ($18=881,$38=882,...


************ /Ende HADES-Doku/


; ===> FPU-Abfrage geändert; ist nun ähnlich zum Hades-TOS


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

          dc.l $F2004000      ; fmove.l d0,fp0
          dc.w $F327               ; fsave   -(sp)
          move.l    (sp),d2        ; Version Bytes ($18=881,$38=882,...
          move.l    a2,sp               ; Stack korrigieren
          move.l    d2,d0               ;

          cmp.w     #60,longframe.w          ; mc68060
          bne  no060               ; ja->
          cmp.w     #$6000,d2      ; 68060 internal FPU ?
          beq  is060               ; ja->

no060:         rol.l     #8,d0
          cmp.b     #$41,d0             ; 68040 internal FPU ?
          beq  is040
          cmp.b     #$40,d0             ; 68040 internal FPU ?
          beq  is040
          move.l    d2,d0
          ror.l     #8,d0
          ror.l     #8,d0
          cmp.b     #$18,d0             ; 68881 ?
          beq  is881
          cmp.b     #$38,d0             ; 68882 ?
          beq  is882                   ; ja ->
                bne     nolfpu                  ; sonst linef
                
is060:
          addq.w    #8,d1               ;16: 68060
is040:
          addq.w    #2,d1               ; 8: 68040
is882:
          addq.w    #2,d1               ; 6: 68882
is881:
          addq.w    #2,d1               ; 4: 68881
linef_emu:
          addq.w    #2,d1               ; 2: LineF- FPU
nolfpu:                            ; keine LineF FPU


; clr.b is_fpu
;seq is_fpu
 move.b   #-1,is_fpu

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
; Bit 12-15    reserviert für Video Hardware
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

          move.l    #id,(a5)+
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

* _SWI eintragen (nur bei STe und höher)
* machine_type: 0=ST, 1=STE, 2=MegaSTE, 3=TT
 move.l   #'_FDC',(a5)+
 move.l   #'hade',(a5)+
 st.b     hd_flag

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

* Hades-Cookie
*move.l   #'hade',(a5)+
*clr.l    (a5)+

* Endmarkierung
 clr.l    (a5)+
 move.l   #NCOOKIES,(a5)           ; Platz für insgesamt 20+1 Cookies
 move.l   (sp)+,a5
 rts
