;---------------------------------------------------------------------
;
; Tabelle zur Umsetzung der kbshift-Bits
;
;           Shift-L | Shift-R | CTRL  | ALT   | CAPS  | Cmd
;--------------------------------------------------------------------
;MakeCode:  $2a     | $36     | $1d   | $38   | $3a   | $37
;           Bit 1   | Bit 0   | Bit 2 | Bit 3 | Bit 4 | Bit 5 toggeln
;
knvkey:  dc.b 4,0,0,0,0,0,0,0,0,0,0,0,0   ;Code $1d (Ctrl) - $29
         dc.b 2,0,0,0,0,0,0,0,0,0,0,0     ;Code $2a (LShift) - $35
         dc.b 1,32,8,0,$80                ;Code $36 (Rshift) - $3a

_handlekey:
 moveq    #0,d1               ; Bits 8-15 saeubern
 move.b   d0,d1               ; Scancode
 bmi.b    and_kbshift
     IF   ALTGR
 cmpi.b   #ALTGR,d0
     IF   ALT_NUMKEY
 beq      key_set_altgr
     ELSE
 beq.b    key_set_altgr
     ENDIF
     ENDIF
     IF   ALT_NUMKEY
 cmpi.b   #$38,d1             ; Alt-Taste betaetigt
 bne.b    key_noaltmak
 clr.b    alt_numkey          ; ASCII-Code-Akkumulator loeschen
key_noaltmak:
     ENDIF
 sub.b    #$1d,d1             ; Erster Eintrag der Tabelle
 bmi      mk_init_keyrep      ; keine Sondertaste
 cmp.b    #$3a-$1d,d1         ; Letzer Eintrag der Tabelle
 bhi      mk_init_keyrep      ; keine Sondertaste

 move.b   knvkey(pc,d1.w),d1
     IF   MILANCOMP
 beq      mk_init_keyrep      ; keine Sondertaste
     ELSE
     IF   ALT_NUMKEY
 beq      mk_init_keyrep      ; keine Sondertaste
     ELSE
 beq.b    mk_init_keyrep      ; keine Sondertaste
     ENDIF
     ENDIF
 bmi.b    toggle_capslock     ; muss $3a sein
 or.b     d1,kbshift
 rts

toggle_capslock:
 bsr      klick
 btst     #3,kbshift          ; ALT-Capslock ?
 beq.b    no_altgr_emu
 not.b    altgr_status        ; Emulation von AltGr ueber ALT-CapsLock
 rts
no_altgr_emu:
 bchg     #4,kbshift
     IF   MILANCOMP
 bra      keyb_led
     ELSE
 rts
     ENDIF

;
; Scancode mit gesetzem Bit 7
and_kbshift:
     IF   ALTGR
 cmpi.b   #ALTGR+$80,d1
 beq.b    key_reset_altgr
     ENDIF
     IF   ALT_NUMKEY
 cmpi.b   #$38+$80,d1         ; Alt-Taste losgelassen
 bne.b    key_noaltbrk
 tst.b    alt_numkey          ; ASCII-Code akkumuliert?
 beq.b    key_noaltbrk        ; nein
 bclr     #3,kbshift
 move.l   a0,-(sp)            ; Tastaturpufferadresse merken
 move.b   alt_numkey,d0       ; ASCII
 moveq    #$5f,d1             ; Scancode ist immer $5f wie bei AltGr
 bra      put_key_to_buf
key_noaltbrk:
     ENDIF
 sub.b    #$1d+$80,d1         ; Erster Eintrag der Tabelle
 bmi.b    brk_keyrep          ; keine Sondertaste
 cmp.b    #$38-$1d,d1         ; Letzter Eintrag der Tabelle (CAPS interessiert nicht!)
 bhi.b    brk_keyrep          ; Keine Sondertaste
     IF   ALT_NUMKEY
 lea      knvkey(pc),a0
 move.b   0(a0,d1.w),d1
     ELSE
 move.b   knvkey(pc,d1.w),d1
     ENDIF
 beq.b    brk_keyrep          ; keine Sondertaste
 not.b    d1                  ; Bits invertieren
 or.b     #16,d1              ; Bit 4 NICHT veraendern!
 and.b    d1,kbshift
 rts

     IF   ALTGR
key_set_altgr:
 st       altgr_status
 rts
key_reset_altgr:
 sf       altgr_status
 rts
     ENDIF

;
; Es war keine der Umschalttasten
; Break
brk_keyrep:
   move.b   d0,d1
   bclr     #7,d1                   ;d1 = Scancode
   cmp.b    keyrepeat+0,d1          ;wiederholter Scancode
   bne.b    hndk_norep
;  Taste wird gerade wiederholt: Wiederholung abbrechen, da losgelassen
   moveq    #0,d1
   move.b   d1,keyrepeat+0
   move.b   d1,keyrepeat+1
hndk_norep:
   cmpi.b   #$c7,d0                 ;Home ?
   beq.b    hndk_nohome
   cmpi.b   #$d2,d0                 ;Insert ?
   bne      exit_brk_keyrep

hndk_nohome:
   btst     #3,kbshift              ;ALT-Home bzw. ALT-Insert ?
   bne.b    keyrep_entry
exit_brk_keyrep:
   rts

; Make: Tastaturwiederholung initialisieren
mk_init_keyrep:

     IF   ALT_NUMKEY
 move.b   kbshift,d1
 andi.w   #$2f,d1             ; alle ausser CapsLock
 cmpi.w   #8,d1               ; nur Alt?
 bne.b    key_noaltnum
 cmpi.b   #$67,d0             ; Num7
 bcs.b    key_noaltnum2
 cmpi.b   #$70,d0             ; Num0
 bhi.b    key_noaltnum2
 move.l   keytblx,a0
 move.b   0(a0,d0.w),d0       ; in ASCII wandeln
 subi.b   #'0',d0             ; in 0..9
 moveq    #0,d1
 move.b   alt_numkey,d1
 mulu     #10,d1
 add.b    d0,d1
 move.b   d1,alt_numkey
 rts
key_noaltnum2:
 clr.b    alt_numkey          ; ASCII-Code-Akkumulator loeschen
key_noaltnum:
     ENDIF

   move.b   d0,keyrepeat            ;Scancode
   move.b   key_delay,d1
   cmp.b    key_reprate,d1
   bcc.b    hk_initdel
   move.b   key_reprate,d1
hk_initdel:
   move.b   d1,keyrepeat+1          ;initiale Verzoegerung = max(rep,delay)
;
; Hier BSR-t die 200Hz- Routine rein, wenn Tastenwiederholung anliegt
; a0 = IOREC *buffer
keyrep_entry:
   move.l   a0,-(sp)                ;Tastaturpufferadresse merken
   move.b   kbshift,d1
   and.w    #$f,d1                  ;nur Bits 0-3 beachten
   add.w    d1,d1
   move.w   keyctab(pc,d1.w),d1
   jmp      keyctab(pc,d1.w)

keyctab:
;
; Die nachfolgenden Routinen erhalten:
;
;  d0.b: Scancode
;
; IOREC *buffer ist auf dem Stack gesichert! -> Stack-Korrektur nicht vergessen!
;
   dc.w     plain_ascii-keyctab     ;0, "normales" Zeichen
   dc.w     ShRKey-keyctab          ;1, Shift-R
   dc.w     ShLKey-keyctab          ;2, Shift-L
   dc.w     ShRLKey-keyctab         ;3, Shift-R+Shift-L
   dc.w     CtrlKey-keyctab         ;4,
   dc.w     ShRCtrlKey-keyctab      ;5, Shift-R+Ctrl
   dc.w     ShLCtrlKey-keyctab      ;6, Shift-L+Ctrl
   dc.w     ShRLCtrlKey-keyctab     ;7, Shift-R+Shift-L+Ctrl
   dc.w     AltKey-keyctab          ;8
   dc.w     ShRAltKey-keyctab       ;9
   dc.w     ShLAltKey-keyctab       ;10
   dc.w     ShRLAltKey-keyctab      ;11
   dc.w     CtrlAltKey-keyctab      ;12 -> auf DEL abtesten!
   dc.w     ShRCtrlAltKey-keyctab   ;13 -> auf DEL abtesten!
   dc.w     ShLCtrlAltKey-keyctab   ;14
   dc.w     ShRLCtrlAltKey-keyctab  ;15

;--------------------------------------------------------
;
; <klick> sichert im Gegensatz zur alten <klick>-Routine
; nur das von den Tastatur IR-Routinen benoetigte Register d0.b!
klick:
   btst     #0,conterm
   beq.b    kl_silent
   move.w   d0,-(sp)
   movea.l  kcl_hook,a1            ; Die aufgerufene Routine darf
   jsr      (a1)                   ; Register d0-d2/a0-a2 zerstoeren
   move.w   (sp)+,d0
kl_silent:
   rts
;---------------------------------------------------------
ShRCtrlKey:
ShLCtrlKey:
ShRLCtrlKey:
 bsr      klick
 moveq    #0,d1
 move.b   d0,d1                    ; Scancode in d1 merken
 andi.w   #$7f,d0                  ; d0 = Offset fuer Tabellenzugriff
 lea      keytblx+4,a0             ; Tabelle Shift
 tst.b    altgr_status
 bne.b    ctrl_altgr               ; ausfuehren...
 move.l   (a0),a0
 move.b   0(a0,d0.w),d0            ; ASCII nach d0 holen

hndk_wsc2:
 cmpi.b   #$32,d0                  ; CTRL-SHIFT-Num2 (ASCII 0)
 bne.b    hndk_wsc3
 moveq    #0,d0
 bra      put_key_to_buf

hndk_wsc3:
 cmpi.b   #$36,d0                  ; CTRL-SHIFT-Num6
 bne.b    hndk_wsc4
 moveq    #$1e,d0
 bra      put_key_to_buf

hndk_wsc4:
 andi.w   #$1f,d0                  ; bei gedrueckter CTRL- Taste nur bis $1f
 bra      put_key_to_buf

;-----------------------------------------------------

CtrlKey:
 tst.b    ctrl_status
 beq      ctrl_kein_sonder
 cmpi.b   #$2e,d0                   ;Ctrl-C
 beq      ctrl_c
 cmpi.b   #$1f,d0                   ;CTRL-S
 beq      ctrl_s
 cmpi.b   #$10,d0                   ;CTRL-Q
 bne      ctrl_kein_sonder

 bclr     #0,ctrl_status+1
 bra.b    ctrl_kein_sonder

ctrl_s:
 moveq    #0,d1
 bra.b    set_ctrl

ctrl_c:
 moveq    #7,d1
set_ctrl:
 bset     d1,ctrl_status+1

ctrl_kein_sonder:
   bsr      klick
   move.b   d0,d1                   ;Scancode in d1 merken
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   lea      keytblx,a0              ;a0 = Standard- Tastaturtabelle
   btst     #4,kbshift.w            ;CapsLock aktiv ?
   beq.b    ctrl_tst_altgr
   lea      keytblx+8,a0            ;Tabelle Caps

ctrl_tst_altgr:
   tst.b    altgr_status
   beq.b    ctrl_no_altgr
ctrl_altgr:
   lea      12(a0),a1               ;3 Tabellen weiter
   move.l   (a1),a1
   add.w    d0,a1
   cmpi.b   #$20,(a1)               ;zulaessig ?
   beq.b    ctrl_no_altgr
   move.b   (a1),d0                 ;ASCII
   moveq    #$5f,d1                 ;Scancode ist immer $5f
   bra      put_key_to_buf

ctrl_no_altgr:
   move.l   (a0),a0
   move.b   0(a0,d0.w),d0           ;ASCII nach d0 holen
;
 cmpi.b   #$d,d0           ;Return
 bne.b    hndk_noret
 moveq    #$a,d0           ;CTRL-Return in LF wandeln
 bra      put_key_to_buf

hndk_noret:
 cmpi.b   #$47,d1          ;HOME
 bne.b    hndk_nohome2
 addi.w   #$30,d1          ;CTRL-Home
 bra      put_key_to_buf

hndk_nohome2:
 cmpi.b   #$4b,d1          ;CursL
 bne.b    hndk_w1
 moveq    #$73,d1          ;CTRL-CursL
 moveq    #0,d0
 bra      put_key_to_buf

hndk_w1:
 cmpi.b   #$4d,d1          ;CursR
 bne.b    hndk_w2
 moveq    #$74,d1          ;CTRL-CursR
 moveq    #0,d0
 bra      put_key_to_buf

hndk_w2:
 cmpi.b   #$32,d0          ;CTRL-2 (ASCII 0)
 bne.b    hndk_w3
 moveq    #0,d0
 bra      put_key_to_buf

hndk_w3:
 cmpi.b   #$36,d0          ;CTRL-6
 bne.b    hndk_w4
 moveq    #$1e,d0
 bra      put_key_to_buf

hndk_w4:
 cmpi.b   #$2d,d0          ;CTRL-apostrophe
 bne.b    other_ctrl
 moveq    #$1f,d0
 bra      put_key_to_buf

other_ctrl:
 andi.w   #$1f,d0                  ; bei gedrueckter CTRL- Taste nur bis $1f
 bra      put_key_to_buf

;----------------------------------------------------

AltKey:
   bsr      klick
   moveq    #0,d1
   move.b   d0,d1                   ;Scancode in d1 merken
   lea      keytblx,a0              ;a0 = Standard- Tastaturtabelle
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   btst     #4,kbshift.w            ;CapsLock aktiv ?
   beq.b    alt_tst_altgr
   lea      keytblx+8,a0            ;Tabelle Caps
alt_tst_altgr:
   tst.b    altgr_status
   beq.b    alt_no_altgr
alt_altgr:
   lea      12(a0),a1              ; 3 Tabellen weiter
   move.l   (a1),a1
   add.w    d0,a1
   cmpi.b   #$20,(a1)              ; zulaessig ?
   beq.b    alt_no_altgr
   move.b   (a1),d0                ; ASCII
   moveq    #$5f,d1                ; Scancode ist immer $5f
   bra      put_key_to_buf

; Alt-Ebene (Extra-Tabelle!)

alt_no_altgr:
   move.l   24(a0),a0              ; 6 Tabellen weiter (Alt-Ebene)
   move.b   0(a0,d0.w),d0          ; ASCII nach d0 holen
   bne      put_key_to_buf         ; ist belegt!

   cmpi.b   #$62,d1                ; ALT-Help
   bne.b    hndk_w13
   addq.w   #1,_dumpflg            ; Hardcopy anwerfen
   move.l   (sp)+,a0               ; Stack korrigieren
   rts

;
; Maus-Emulation
hndk_w13:
   move.b   d1,d2                ;Scancode
   bmi.b    tst_InsHome          ;Break-Code der Insert- oder Home-Taste?
   ext.w    d2
   sub.w    #$47,d2              ;Insert (Make)
   bmi      tst_AltNum
   cmp.w    #$52-$47,d2          ;Home (Make)
   bhi      tst_AltNum

   add.w    d2,d2
   move.w   AltMousEmu_tab(pc,d2.w),d2
   jmp      AltMousEmu_tab(pc,d2.w)

AltMousEmu_tab:
   dc.w  AltIns - AltMousEmu_tab       ;$47: ALT-Insert (Make)
   dc.w  AltCursUp - AltMousEmu_tab    ;$48: ALT-CursUp
   dc.w  tst_AltNum - AltMousEmu_tab   ;$49: normale Taste
   dc.w  tst_AltNum - AltMousEmu_tab   ;$4a: ...
   dc.w  AltCursL - AltMousEmu_tab     ;$4b: ALT-CursL
   dc.w  tst_AltNum - AltMousEmu_tab   ;$4c: normale Taste
   dc.w  AltCursR - AltMousEmu_tab     ;$4d: ALT-CursR
   dc.w  tst_AltNum - AltMousEmu_tab   ;$4e: normale Taste
   dc.w  tst_AltNum - AltMousEmu_tab   ;$4f: ...
   dc.w  AltCursDown - AltMousEmu_tab  ;$50: ALT-CursDown
   dc.w  tst_AltNum - AltMousEmu_tab   ;$51: ...
   dc.w  AltHome - AltMousEmu_tab      ;$52: ALT-Home (Make)

AltCursUp:
   moveq    #0,d1
   moveq    #-8,d2         ;$f8
   bra      _mouse_emu

AltCursL:
   moveq    #-8,d1         ;$f8
   moveq    #0,d2
   bra      _mouse_emu

AltCursR:
   moveq    #8,d1
   moveq    #0,d2
   bra      _mouse_emu

AltCursDown:
   moveq    #0,d1
   moveq    #8,d2
   bra      _mouse_emu

AltIns:                    ;(Make)
   bset     #5,kbshift
   moveq    #0,d1
   moveq    #0,d2
   bra      _mouse_emu

AltHome:                   ;(Make)
   bset     #6,kbshift
   moveq    #0,d1
   move     #0,d2
   bra      _mouse_emu

tst_InsHome:
   cmp.b    #$c7,d1        ;ALT-Insert (Break)
   bne      tst_AltHome
   bclr     #5,kbshift
   moveq    #0,d1
   moveq    #0,d2
   bra      _mouse_emu

tst_AltHome:
   cmp.b    #$d2,d1        ;ALT-Home (Break)
   bne      tst_AltNum
   bclr     #6,kbshift
   moveq    #0,d1
   move     #0,d2
   bra      _mouse_emu
;--- Ende der Maus-Emulation

tst_AltNum:
 cmpi.b   #2,d1                    ; Scancode fuer Taste "1"
 bcs.b    hndk_w15                 ; nein, Esc-Taste
 cmpi.b   #$d,d1                   ; Taste apostrophe (rechts von ss)
 bhi.b    hndk_w15
 addi.b   #$76,d1                  ; ALT-(obere Zahlenreihe, ss und apostrophe)
;move.b   d1,$380
 bra.b    hndk_w16

hndk_w15:
   cmpi.b   #$41,d0                 ;ALT-'A' bis ALT-'Z'
   bcs.b    hndk_w17
   cmpi.b   #$5a,d0
   bhi.b    hndk_w17
   bra.b    hndk_w16

hndk_w17:
   cmpi.b   #$61,d0                 ;ALT-'a' bis ALT-'z'
   bcs      put_key_to_buf
   cmpi.b   #$7a,d0
   bhi      put_key_to_buf

hndk_w16:
   moveq    #0,d0
   bra      put_key_to_buf

;-----------------------------------------------------
;
; Maus-Emulation
;
; INPUT
; d1.b
; d2.b
_mouse_emu:
   subq.l   #4,sp                   ;Platz fuer 3 Bytes
   lea      (sp),a0
   movea.l  kbdvecs+$10,a2          ;mousevec
   moveq    #0,d0
   move.b   kbshift,d0
   lsr.b    #5,d0
   addi.b   #$f8,d0
   move.b   d0,(a0)+
   move.b   d1,(a0)+
   move.b   d2,(a0)
   lea      (sp),a0
   move.l   a0,-(sp)                ;Fehlt im Original-TOS
   jsr      (a2)
   addq.l   #8,sp                   ;Stack korrigieren und 4 Bytes freigeben
   movea.l  (sp)+,a0
   rts
;-----------------------------------------------------

ShRAltKey:
ShLAltKey:
ShRLAltKey:
   bsr      klick
   moveq    #0,d1
   move.b   d0,d1                   ;Scancode in d1 merken
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   lea      keytblx+4,a0            ;Tabelle Shift
   tst.b    altgr_status
   bne      alt_altgr

; Shift-Alt-Ebene (Extra-Tabelle!)

   move.l   24(a0),a0              ; 6 Tabellen weiter (Alt-Ebene)
   move.b   0(a0,d0.w),d0          ; ASCII nach d0 holen
   bne      put_key_to_buf         ; ist belegt!

;
; Maus-Emulation
   move.b   d1,d2                ;Scancode
   bmi.b    tst_ShInsHome        ;Break-Code der Insert- oder Home-Taste?
   ext.w    d2
   sub.w    #$47,d2              ;ALT-Shift-Insert (Make)
   bmi      AltShKey
   cmp.w    #$52-$47,d2          ;ALT-Shift-Home (Make)
   bhi      AltShKey

   add.w    d2,d2
   move.w   AltShMousEmu_tab(pc,d2.w),d2
   jmp      AltShMousEmu_tab(pc,d2.w)

AltShMousEmu_tab:
   dc.w  AltIns - AltShMousEmu_tab        ;$47: ALT-Shift-Insert=ALT-Insert
   dc.w  AltShCursUp - AltShMousEmu_tab   ;$48: ALT-Shift-CursUp
   dc.w  AltShKey - AltShMousEmu_tab      ;$49: normale Taste
   dc.w  AltShKey - AltShMousEmu_tab      ;$4a: ...
   dc.w  AltShCursL - AltShMousEmu_tab    ;$4b: ALT-Shift-CursL
   dc.w  AltShKey - AltShMousEmu_tab      ;$4c: normale Taste
   dc.w  AltShCursR - AltShMousEmu_tab    ;$4d: ALT-Shift-CursR
   dc.w  AltShKey - AltShMousEmu_tab      ;$4e: normale Taste
   dc.w  AltShKey - AltShMousEmu_tab      ;$4f: ...
   dc.w  AltShCursDown - AltShMousEmu_tab ;$50: ALT-Shift-CursDown
   dc.w  AltShKey - AltShMousEmu_tab      ;$51: ...
   dc.w  AltHome - AltShMousEmu_tab       ;$52: ALT-Shift-Home=ALT-Home

AltShCursUp:
   moveq    #0,d1
   moveq    #-1,d2         ;$ff
   bra      _mouse_emu

AltShCursL:
   moveq    #-1,d1         ;$ff
   moveq    #0,d2
   bra      _mouse_emu

AltShCursR:
   moveq    #1,d1
   moveq    #0,d2
   bra      _mouse_emu

AltShCursDown:
   moveq    #0,d1
   moveq    #1,d2
   bra      _mouse_emu

tst_ShInsHome:
   cmp.b    #$c7,d1        ;ALT-Insert (Break)
   bne      tst_AltHome
   bclr     #5,kbshift
   moveq    #0,d1
   moveq    #0,d2
   bra      _mouse_emu

tst_AltShHome:
   cmp.b    #$d2,d1        ;ALT-Home (Break)
   bne      AltShKey
   bclr     #6,kbshift
   moveq    #0,d1
   move     #0,d2
   bra      _mouse_emu

;--- Ende der Maus-Emulation
AltShKey:
   moveq    #0,d0
   bra   put_key_to_buf

;------------------------------------------------------

CtrlAltKey:                         ;12 -> auf DEL abtesten!
   cmpi.b   #$53,d0                 ;Ctrl,Alt-Del
   bne.b    ShRCtrlAltKey
   addq.l   #4,sp                   ;Stack korrigieren
   move.l   warmbvec,a0
   jmp      (a0)

ShRCtrlAltKey:                      ;13 -> auf DEL abtesten!
   cmpi.b   #$53,d0                 ;ShiftR,Ctrl,Alt-Del
   bne.b    ShLCtrlAltKey
   addq.l   #4,sp                   ;Stack korrigieren
   move.l   coldbvec,a0
   jmp      (a0)

ShLCtrlAltKey:
ShRLCtrlAltKey:
   bsr      klick
   moveq    #0,d1
   move.b   d0,d1                   ;Scancode in d1 merken
   lea      keytblx,a0              ;a0 = Standard- Tastaturtabelle
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   move.b   kbshift.w,d2
   btst     #4,d2                   ;CapsLock aktiv ?
   beq.b    hndk_w18
   lea      keytblx+8,a0            ;Tabelle Caps
hndk_w18:
   and.w    #3,d2                   ;Shift aktiv?
   beq.b    hkey_altgr
   lea      keytblx+4,a0            ;Tabelle Shift

hkey_altgr:
   tst.b    altgr_status
   beq.b    no_altgr
   lea      12(a0),a1                ; 3 Tabellen weiter
   move.l   (a1),a1
   add.w    d0,a1
   cmpi.b   #$20,(a1)                ; zulaessig ?
   beq.b    no_altgr
   move.b   (a1),d0                  ; ASCII
   moveq    #$5f,d1                  ; Scancode ist immer $5f
   bra      put_key_to_buf

no_altgr:
   move.l   (a0),a0
   move.b   0(a0,d0.w),d0            ; ASCII nach d0 holen
   andi.w   #$1f,d0                  ; bei gedrueckter CTRL- Taste nur bis $1f
   bra      put_key_to_buf

;------------------------------------------------------

plain_ascii:
   bsr      klick
   move.b   d0,d1                   ;Scancode in d1 merken
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   lea      keytblx,a0              ;a0 = Standard- Tastaturtabelle

   btst     #4,kbshift.w            ;CapsLock aktiv ?
   beq.b    Key_tst_altgr
   lea      keytblx+8,a0            ;Tabelle Caps

Key_tst_altgr:
   tst.b    altgr_status
   bne.b    Key_hdl_altgr
Key_no_altgr:
   move.l   (a0),a0
   move.b   0(a0,d0.w),d0           ;ASCII nach d0 holen
   bra      put_key_to_buf

Key_hdl_altgr:
   lea      12(a0),a1               ;3 Tabellen weiter
   move.l   (a1),a1
   add.w    d0,a1
   cmpi.b   #$20,(a1)               ;zulaessig ?
   beq.b    Key_no_altgr
   move.b   (a1),d0                 ;ASCII
   moveq    #$5f,d1                 ;Scancode ist immer $5f
   bra      put_key_to_buf

;-----------------------------------------------------

ShRKey:
ShLKey:
ShRLKey:
   bsr      klick
   move.b   d0,d1                   ;Scancode in d1 merken
   andi.w   #$7f,d0                 ;d0 = Offset fuer Tabellenzugriff
   lea      keytblx+4,a0            ;Tabelle Shift
   tst.b    altgr_status            ;auf ALTGR testen
   bne.b    Key_hdl_altgr

;Funktionstasten SHIFT- (F1...F10) umsetzen?
   cmpi.b   #$3b,d0                 ;$3b-$44 = F1...F10
   bcs.b    Key_no_altgr
   cmpi.b   #$44,d0
   bhi.b    Key_no_altgr            ;keine Funktionstaste

;Shift- Funktionstaste: $19 zum Scancode
   addi.w   #$19,d1                 ;Shift- Funktionstaste nach GSX
   moveq    #0,d0                   ;ASCII = 0
;  bra      put_key_to_buf



put_key_to_buf:
     IF   DEADKEYS
 move.b   deadkey_asc,d2
 beq      no_deadkey_active
 clr.b    deadkey_asc              ; verarbeitet
 cmpi.b   #' ',d0
 beq.b    deadkey_space
 cmpi.b   #'A',d0
 bcs.b    deadkey_both
 cmpi.b   #'Z',d0
 bls.b    deadkey_dead
 cmpi.b   #'a',d0
 bcs.b    deadkey_both
 cmpi.b   #'z',d0
 bls.b    deadkey_dead
 bra      no_deadkey

; Auf dead key folgt ein Leerzeichen. Nur dead key.

deadkey_space:
 move.l   (sp)+,a0                 ; IOREC holen und entfernen
 move.b   kbshift,-(sp)
 move.b   deadkey_kbsh,d0
 move.b   d0,kbshift
 pea      deadkey_after2(pc)
 move.b   d2,d0
 move.b   deadkey_scan,d1
 move.l   a0,-(sp)
 bra      no_deadkey               ; dead key nachtraeglich eintragen, statt bsr
deadkey_after2:
 move.b   (sp)+,d0
 move.b   d0,kbshift
 rts

; Auf dead key folgt ein Buchstabe. Verschmelzen.

deadkey_dead:
 move.l   deadkey_subtab,a1
dkf_loop:
 tst.b    (a1)
 beq.b    no_deadkey
 cmp.b    (a1)+,d0
 beq.b    deadkey_dead_found
 addq.l   #1,a1
 bra.b    dkf_loop

deadkey_dead_found:
 move.b   (a1),d0
 bra.b    no_deadkey

; Auf dead key folgt ein Nicht-Buchstabe. Verarbeite beide Tasten.

deadkey_both:
 move.l   (sp),a0                  ; IOREC holen
 move.w   d0,-(sp)
 move.w   d1,-(sp)
 move.b   kbshift,-(sp)
 move.b   deadkey_kbsh,d0
 move.b   d0,kbshift
 pea      deadkey_after(pc)
 move.b   d2,d0
 move.b   deadkey_scan,d1
 move.l   a0,-(sp)
 bra      no_deadkey               ; dead key nachtraeglich eintragen, statt bsr
deadkey_after:
 move.b   (sp)+,d0
 move.b   d0,kbshift
 move.w   (sp)+,d1
 move.w   (sp)+,d0
 bra.b    no_deadkey

; Pruefe, ob die Taste ein dead key ist

no_deadkey_active:
 move.l   keytblx+9*4,a0            ; dead key table
 move.l   a0,d2
 beq.b    no_deadkey               ; no table
ndk_loop:
 tst.b    (a0)
 beq.b    no_deadkey               ; Ende der Tabelle
 cmp.b    (a0)+,d0
 bne.b    ndk_loop
 move.l   a0,a1
 suba.l   d2,a0                    ; Index berechnen
 subq.l   #1,a0
 move.l   a0,d2                    ; d2 ist der Index des dead key

; Ein dead key wurde eingegeben

 move.b   d0,deadkey_asc
 move.b   d1,deadkey_scan
; berechne subtab
ndk_loop2:
 tst.b    (a1)+
 bne.b    ndk_loop2
 dbra     d2,ndk_loop2
 move.l   a1,deadkey_subtab

 move.b   kbshift,d2
 move.b   d2,deadkey_kbsh
 addq.l   #4,sp                    ;IOREC entfernen
 rts

no_deadkey:
     ENDIF
 clr.l    -(sp)
 move.b   d1,1(sp)                 ; Scancode nach Bit 16..23
 move.b   d0,3(sp)                 ; ASCII    nach Bit 0..7
 btst     #3,conterm
 beq.b    no_kbshift_status
 move.b   kbshift,(sp)             ; ggf. kbshift nach Bit 24..31
no_kbshift_status:
 move.l   (sp)+,d0
 movea.l  (sp)+,a0                 ; IOREC
 move.w   sr,d2                    ; sr retten
 ori.w    #$700,sr                 ; Interrupts sperren
 move.w   ibuftl(a0),d1
 addq.w   #4,d1
 cmp.w    ibufsiz(a0),d1
 bcs.b    hndk_w20
 moveq    #0,d1
hndk_w20:
 cmp.w    ibufhd(a0),d1
 beq.b    hndk_w21                ; Puffer voll
 movea.l  (a0),a2
 move.l   d0,0(a2,d1.w)
 move.w   d1,ibuftl(a0)
hndk_w21:
 move.w   d2,sr                    ; sr restaurieren
exit_handlekey:
 rts

     IF   MILANCOMP

keyb_led:
 movem.l  a0-a2/d0-d2,-(sp)
 move.l   milan,a2
 move.l   milh_caps_led(a2),d0
 beq.b    milh_no_led         ; altes ROM
 move.l   d0,a2
 moveq    #0,d0
 move.b   kbshift,d0
 jsr      (a2)                ; LED schalten
milh_no_led:
 movem.l  (sp)+,a0-a2/d0-d2
 rts
     ENDIF
