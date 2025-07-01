**********************************************************************
*
* long Kbshift( void )
*

Kbshift:
 moveq    #0,d0
 move.b   kbshift,d0
 move.w   (a0),d1
 bmi.b    kbsh_ende
 move.b   d1,kbshift
kbsh_ende:
 rte


**********************************************************************
*
* int Kbrate( int delay, int repeat )
*

Kbrate:
 lea      key_delay,a1
 move.w   (a1),d0                  ; altes delay/repeat
 move.w   (a0)+,d1                 ; neues delay
 bmi.b    kbr_ende                 ; ist -1, keine Aenderung
 move.b   d1,(a1)+                 ; neues delay setzen
 move.w   (a0),d1                  ; neues repeat
 bmi.b    kbr_ende                 ; ist -1, keine Aenderung
 move.b   d1,(a1)                  ; neues repeat setzen
kbr_ende:
 rte


**********************************************************************
*
* char **Keytbl( char *unshift, char *shift, char *caps )
*

Keytbl:
 lea      keytblx,a1               ; Zeiger auf KEYTAB-Struktur
 move.l   a1,d0                    ; Rueckgabewert
 moveq    #3-1,d2                  ; Zaehler fuer 3 Durchlaeufe
ktbl_loop:
 move.l   (a0)+,d1
 bmi.b    ktbl_noset
 move.l   d1,(a1)
ktbl_noset:
 addq.l   #4,a1
 dbra     d2,ktbl_loop
 rte

**********************************************************************
*
* EQ/NE char altcode_asc( char c )
*
* Wandelt einen Scan-/Ascii- Code einer ALT-Buchstabenkombination um
* in ein ASCII-Zeichen (in Grossbuchstaben).
* Bsp.: Code $1e00 (Alt-A) ==> 'A'
*            $7800 (Alt-1) ==> '1'
*

altcode_asc:
 tst.b    d0
 bne      ala_nix                  ; hat ASCII-Code, also kein ALT
 lsr.w    #8,d0                    ; Scancode ins Loword
 cmpi.w   #$78,d0
 bcs.b    ala_nonum
* Sonderbehandlung fuer Alt-1 bis Alt-apostrophe
 cmpi.w   #$83,d0
 bhi.b    ala_nix
 subi.w   #$76,d0                  ; Umrechnung
ala_nonum:
 move.l   keytblx+8,a0
 move.b   0(a0,d0.w),d0            ; ASCII-Code holen
 rts
ala_nix:
 moveq    #0,d0
 rts


**********************************************************************
*
* long (!) Bioskeys( void )
*
* Setzt 6 statt 3 Tabellen. Fuer die MF- Tastatur werden fuer die ersten
* drei Tabellen andere genommen.
* Der AltGr- Status liegt immer hinter den 6 Tabellenzeigern.
* Gibt Adressen der Tastaturbehandlungsroutine zurueck.
*
Bioskeys:
 bsr.b   _Bioskeys
 rte

_Bioskeys:
 move.l   default_keytblxp,a1      ; Tabelle der 9 Default-Zeiger
 lea      keytblx,a0               ; aktive Zeiger
 moveq    #N_KEYTBL-1,d0           ; Zaehler
_bioskeys_loop:
 move.l   (a1)+,(a0)+
 dbra     d0,_bioskeys_loop
 lea      keybd_struct(pc),a0
 move.l   a0,d0
 rts


keybd_struct:
 DC.L     keytblx                  ; Adresse der 6 Tabellen
 DC.L     kbshift                  ; Adresse des Shiftstatus
 DC.L     altgr_status             ; Adresse des AltGr- Status
 DC.L     handle_key               ; Adresse der Tastaturroutine
 DC.L     keyrepeat                ; Adresse der Wiederholungsdaten


**********************************************************************
***************     Interruptroutinen   ******************************
**********************************************************************


;==============================================================
;
; Interrupt fuer MIDI (MFP2- RS232 Puffer voll)
;
; Ruft <midisys> auf. Rettet d0-d3/a0-a3
;
; Seit TOS 4.x wird Register a5 nicht mehr gesichert
;

midi_int:
 movem.l  d0/d1/d2/d3/a0/a1/a2/a3,-(sp)
 bsr.s    midisys
 bclr     #4,RAVEN_PADDR_MFP2+$0F ; IRQ MFP2-RS232 Puffer voll Interrupt-Servcice-Bit loeschen
 movem.l  (sp)+,a3/a2/a1/a0/d3/d2/d1/d0
 rte

;------------------------------------------------------------
;
; "midisys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
midisys:
   btst     #7,RAVEN_PADDR_MFP2+$2B ;MFP2-RS232 Puffer voll?
   beq.b    exit_midisys            ;nein, schnell wieder raus
   move.w   d2,-(sp)                ;Status sichern
   move.b   RAVEN_PADDR_MFP2+$2F,d0 ;Daten vom MFP2-RS232 holen
   lea      iorec_midi,a0
   movea.l  kbdvecs+0,a2            ;midivec
   jsr      (a2)
   move.w   (sp)+,d2
exit_midisys:
   rts

;==============================================================
;
; Interrupt fuer Keyboard (UART1- Interrupt RX)
;
; Ruft <ikbdsys> auf. Rettet d0-d3/a0-a3
;
; Seit TOS 4.x wird Register a5 nicht mehr gesichert
;
 
key_int:
 movem.l  d0/d1/d2/d3/a0/a1/a2/a3,-(sp)
IFNE RAVEN
 move.w   #$2700,sr
 move.w   32(sp),d0
 and.w    #$0F00,d0                     ; get current ipl
 cmp.w    #$0500,d0                     ; skip if >= 6
 bhi.b    key_int_done
 move.w   #$2600,sr                     ; set level 6
 bsr.s    ikbdsys
key_int_done: 
 movem.l  (sp)+,a3/a2/a1/a0/d3/d2/d1/d0
 rte


;------------------------------------------------------------
;
; "ikbdsys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
;
ikbdsys:
 move.w   #7,d2
ikbdsys_loop:
 btst.b   #0,RAVEN_PADDR_UART1+$14  ; uart byte ready?
 beq.b    exit_ikbdsys
 move.b   RAVEN_PADDR_UART1+$00,d0  ; get byte
 move.w   d2,-(sp)
 jsr      arcvint                   ; call ikbd handler
 move.w   (sp)+,d2
 dbra.w   d2,ikbdsys_loop
exit_ikbdsys:
 rts


;--------------------------------------------------------------
;
; arcvint
;
; Byte vom IKBD-ACIA holen und verarbeiten (etwa puffern)
; Darf d0-d3/a0-a3 benutzen
;
arcvint:
IFEQ RAVEN
   move.b   keybd.w,d0              ;Daten vom ACIA holen
ENDIF   
   move.b   kbdvecs+$24,d1          ;ikbd_state
   bne.b    handle_package          ;bin gerade beim Empfangen eines Pakets!
;  Es ist kein Paket oder der Anfang eines solchen
   cmpi.b   #$f6,d0                 ;Tastendruck ?
   bcc.b    no_key
   lea      iorec_kb,a0             ;Tastatur-IOREC
   move.l   kbdvecs-4,a1            ;i.a. handle_key
   jmp      (a1)

;Es ist kein Tastendruck, also Beginn eines Pakets
no_key:
   moveq    #0,d2                   ;nur Lobyte soll Daten enthalten
   move.b   d0,d2
   subi.b   #$f6,d2                 ;d2 enthaelt Paketnummer 0..9

   add.w    d2,d2
   move.w   pk_code_len(pc,d2.w),kbdvecs+$24 ;setze <ikbd_state> und <ikbd_cnt>
   move.w   pak_subr_tab(pc,d2.w),d2
   jmp      pak_subr_tab(pc,d2.w)

pak_subr_tab:
   dc.w  subr_dummy-pak_subr_tab     ;$f6: Statusheader
   dc.w  subr_dummy-pak_subr_tab     ;$f7: absolute Mausposition
   dc.w  subr_relmouse-pak_subr_tab  ;$f8: relative Mausposition
   dc.w  subr_relmouse-pak_subr_tab  ;$f9:...
   dc.w  subr_relmouse-pak_subr_tab  ;$fa:...
   dc.w  subr_relmouse-pak_subr_tab  ;$fb: realtive Mausposition
   dc.w  subr_dummy-pak_subr_tab     ;$fc: Uhrzeit
   dc.w  subr_joy-pak_subr_tab       ;$fd: ??
   dc.w  subr_joy-pak_subr_tab       ;$fe: Joystick 0
   dc.w  subr_joy-pak_subr_tab       ;$ff: Joystick 1

subr_joy:
   move.b   d0,pack_joy+0
   rts

subr_relmouse:
   move.b   d0,pack_relmouse
subr_dummy:
   rts

   .EVEN
; ikbd_state:
; 1=$f6: Statusheader (z.B. 6301 lesen)
; 2=$f7: absolute Mausposition
; 3=$f8..$fb: relative Mausposition
; 4=$fc: Uhrzeit
; 5=$fd: ???????
; 6=$fe: Joystick 0
; 7=$ff: Joystick 1
pk_code_len:         ;in der Form: ikbd_state, Paket-Laenge
 dc.b 1,7
 dc.b 2,5
 dc.b 3,2
 dc.b 3,2
 dc.b 3,2
 dc.b 3,2
 dc.b 4,6
 dc.b 5,2
 dc.b 6,1
 dc.b 7,1
 .EVEN
;-------------------------------------------------------------
;
; Aufruf von handle_package mit
;
; d1.b:  <ikbd_state>
;
handle_package:
   cmpi.b   #6,d1
   bcc      handle_joy              ;Codes $fe/$ff
   ext.w    d1                      ;muss fuer Indizierung auf .w gebracht werden
   add.w    d1,d1                   ;d1 = ikbd_state (1,2,3,4,5)
   add.w    d1,d1
   add.w    d1,d1                   ;* 8
   lea      hdlpckg_table-8(pc,d1.w),a2 ;ikbd_state auf 0..4 umrechnen
   movea.l  (a2)+,a0                ;Paketanfang
   move.w   (a2)+,d1                ;Paketlaenge
   lea      0(a0,d1.w),a1           ;Paketende
   move.w   (a2),a2                 ;Sprungvektor rel. zu kbdvecs
   move.l   kbdvecs(a2),a2          ;Sprungvektor
   moveq    #0,d1
   move.b   kbdvecs+$25,d1          ;ikbd_cnt waren noch zu empfangen
   suba.l   d1,a1
   move.b   d0,(a1)                 ;eintragen
   subq.b   #1,kbdvecs+$25          ;ikbd_cnt
   bne.b    hdlpckg_l1               ;noch nicht fertig
hdlpckg_l2:
                                    ;aus Komp.gruenden bleibt d0 = (a1).b
   move.l   a0,-(sp)                ;Paketanfang als Parameter
   jsr      (a2)
   addq.w   #4,sp
   clr.b    kbdvecs+$24             ;ikbd_state
hdlpckg_l1:
   rts
;--------------------------------------------------
;
; Aufruf von handle_joy mit
;
; d0.b:  <ikbd_state>   (6=Joy0,7=Joy1)
handle_joy:
   ext.w    d1                      ;muss fuer Indizierung auf .w gebracht werden
   lea      pack_joy+1,a2
   move.b   d0,-6(a2,d1.w)          ;Wert merken (z.B. Bit 7 = Feuerknopf)
   movea.l  kbdvecs+$18,a2          ;joyvec
   lea      pack_joy,a0             ;Paketanfang
   bra.b    hdlpckg_l2               ;Vektor anspringen
;--------------------------------------------------
hdlpckg_table:
 DC.L     pack_state
 DC.W     7
 DC.W     $c                       ; statvec

 DC.L     pack_absmouse            ; abs. Mouse
 DC.W     5
 DC.W     $10                      ; mousevec

 DC.L     pack_relmouse            ; rel. Mouse
 DC.W     3
 DC.W     $10                      ; mousevec

 DC.L     pack_clock
 DC.W     6
 DC.W     $14                      ; clockvec

 DC.L     pack_joy                 ; Joystick- Dauermeldung ?
 DC.W     2
 DC.W     $18                      ; joyvec

;---------------------------------------------------------------------
;
; void handle_key( d0 = char scancode, a0 = IOREC *buffer )
;
; Wird von arcvint aufgerufen
; Darf d0-d3/a0-a3 benutzen
;
handle_key:
   eori.w   #$300,sr          ;von IPL 6 auf 5 setzen
   bsr.b    _handlekey
   eori.w   #$300,sr          ;von IPL 5 auf 6 zurueck
   rts

     INCLUDE   "handlkey.s"

;-------------------------------------------------------
;
; "midivec" des Betriebssystems
;
; a0.l:  buffer *IOREC
; d0.b:  UBYTE c
;
; Darf d0-d3/a0-a3 benutzen
;
midivec:
 move.w   ibuftl(a0),d1
 addq.w   #1,d1
 cmp.w    ibufsiz(a0),d1
 bcs.b    midivc_l1
 moveq    #0,d1
midivc_l1:
 cmp.w    ibufhd(a0),d1
 beq.b    midivc_end
 movea.l  (a0),a2
 move.b   d0,0(a2,d1.w)
 move.w   d1,ibuftl(a0)
midivc_end:
 rts

**********************************************************************
*
* Wird aufgerufen, wenn das resvalid/resvector- Programm einen
* Systemfehler provoziert hat. Fuehrt einen Warmstart aus.
*

kill_resval:
 clr.b    resvalid

**********************************************************************
*
* Fuehrt einen Warmstart aus
*
warm_boot:
 jmp     cold_boot

**********************************************************************
*
* Fuehrt einen Kaltstart aus
*

cold_boot:
 move    #$2700,sr
 clr.l   resvalid.w
 clr.l   resvector.w
 move.l  RAVEN_PADDR_SIMM3+$4,a0
 jmp     (a0)


 INCLUDE "keytab.inc"
