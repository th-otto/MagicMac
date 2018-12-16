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
* 16 = 68060 internal LineF FPU
* 17 = Atari Register FPU + 68060 internal LineF FPU
* Das Loword ist fuer eine spaetere eventuelle
* softwaremaessige LineF- Emulation reserviert und derzeit immer 0



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
; Static-Rams statt EPROMs ...), denn wenn ich es als externes
; Programm probiert habe, hatte die FPU ja schon was getan und antwortete
; auch auf ein FNOP mit dem erwarteten IDLE-Frame. Beim Booten stand im
; FPU-cookie aber natuerlich immer nur 2 (LineF-FPU Typ unbekannt)). Jetzt
; wird statt FNOP einfach ein FTST.X FP0 verwendet - und siehe da - es geht ...

;(fa_10.11.94)(1_12_94):einige aenderungen

;         dc.l $F2004000      ; fmove.l d0,fp0
;         dc.w $F327               ; fsave   -(sp)
;         move.l    (sp),d2        ; Version Bytes ($18=881,$38=882,...


************ /Ende HADES-Doku/


; ===> FPU-Abfrage geaendert; ist nun aehnlich zum Hades-TOS


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

          cmp.w     #60,cpu_typ.w  ; mc68060
          bcs.s  no060             ; nein->

        dc.l $4e7a0808             ; movec pcr,d0: get revision number etc
        swap    d0
        cmp.w   #0x0431,d0         ; "broken" 68LC/EC060
        beq.s   no060
        swap    d0
        bclr    #0x01,d0
        dc.l $4e7b0808             ; movec d0,pcr: clear DFP (the disable-FPU bit)

no060:
          dc.l $F2004000           ; fmove.l d0,fp0
          dc.w $F327               ; fsave   -(sp)
          move.w    (sp),d0        ; Version Bytes ($18=881,$38=882,...
          move.l    a2,sp          ; Stack korrigieren

          cmp.w     #60,cpu_typ.w  ; mc68060?
          beq.s  is060             ; ja->
          cmp.w     #40,cpu_typ.w  ; mc68040?
          beq.s  is040             ; ja->
          cmp.b     #$18,d0        ; 68881 ?
          beq.s  is881
          cmp.b     #$38,d0        ; 68882 ?
          beq.s  is882               ; ja ->
          bne.s     linef_emu      ; sonst linef
                
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


_nolfpu:                           ; keine LineF FPU
 move.w   d1,d0
 bclr     #0,d0
 move.b   d0,is_fpu
 swap     d1                       ; Kennung ins Hiword
 move.l   a1,$2c                   ; alten LineF restaurieren
 move.l   a2,sp                    ; Stack wiederherstellen
 move.l   #'_FPU',(a5)+
 move.l   d1,(a5)+                 ; und FPUs eintragen
