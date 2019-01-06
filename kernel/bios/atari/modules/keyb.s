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
 moveq    #9-1,d0                  ; Zaehler
_bioskeys_loop:
 move.l   (a1)+,(a0)+
 dbra     d0,_bioskeys_loop
 lea      keybd_struct(pc),a0
 move.l   a0,d0
 rts

/*
 lea      mf_tab_altgr(pc),a0
 lea      mf_tab_shaltgr(pc),a1
 move.l   a0,a2
 movem.l  a0/a1/a2,keytblx+12
 btst     #1,config_status+2  ; MF-2 ?
 beq.b    bky_no_mf2
 lea      mf_tab_unshift(pc),a0
 lea      mf_tab_shift(pc),a1
 lea      mf_tab_caps(pc),a2
 bra.b    bky_both
bky_no_mf2:
 lea      tab_unshift(pc),a0
 lea      tab_shift(pc),a1
 lea      tab_caps(pc),a2
bky_both:
 movem.l  a0/a1/a2,keytblx
 lea      keybd_struct(pc),a0
 move.l   a0,d0
 rts
*/

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
; Interrupt fuer MIDI und Keyboard (MFP- Interrupt 6)
;
; Ruft <midisys> und <ikbdsys> auf. Rettet d0-d3/a0-a3
;
; Seit TOS 4.x wird Register a5 nicht mehr gesichert
;
midikey_int:
 movem.l  d0/d1/d2/d3/a0/a1/a2/a3,-(sp)
mik_loop:
 movea.l  kbdvecs+$1c,a2           ; midisys
 jsr      (a2)
 movea.l  kbdvecs+$20,a2           ; ikbdsys
 jsr      (a2)
 btst     #4,gpip                  ; steht noch ein Interrupt aus ?
 beq.b    mik_loop                ; ja, weiter
 bclr     #6,isrb                  ; IRQ Key/MIDI-ACIA Interrupt-Servcice-Bit loeschen
                                   ; TOS 2.05: move.b #$bf
 movem.l  (sp)+,a3/a2/a1/a0/d3/d2/d1/d0
 tst.b    kbdvecs+$24              ; ikbd_state
 bne.b    mik_no_yield
 tst.w    pe_slice
 bmi.b    mik_no_yield
 btst     #5,(sp)
 bne      mik_no_yield             ; aus Supervisormode nicht abfangen
 andi.w   #$f3ff,sr                ; INT=3
 jsr      appl_yield
mik_no_yield:
 rte


;------------------------------------------------------------
;
; "midisys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
midisys:
   move.b   midictl.w,d2            ;ACIA- Status holen
   btst     #7,d2                   ;Interrupt request ?
   beq.b    exit_midisys            ;nein, schnell wieder raus

   btst     #0,d2                   ;Receiver buffer full ?
   beq.b    _midi_rcvbuf_empty      ;nein

   move.w   d2,-(sp)                ;Status sichern
   move.b   midi.w,d0               ;Daten vom ACIA holen
   lea      iorec_midi,a0
   movea.l  kbdvecs+0,a2            ;midivec
   jsr      (a2)
   move.w   (sp)+,d2

_midi_rcvbuf_empty:
   andi.b   #$20,d2
   beq.b    exit_midisys            ;kein Fehler
   move.b   midi.w,d0               ;Daten von ACIA holen
   lea      iorec_midi,a0
   movea.l  kbdvecs+8,a1            ;vmiderr
   jmp      (a1)                    ;Fehlerroutine ausfuehren

exit_midisys:
   rts

;------------------------------------------------------------
;
; "ikbdsys" des Betriebssystems
;
; Darf d0-d3/a0-a3 benutzen
;
ikbdsys:
   move.b   keyctl.w,d2             ;ACIA- Status holen
   btst     #7,d2                   ;Interrupt request ?
   beq.b    exit_ikbdsys            ;nein, schnell wieder raus

   btst     #0,d2                   ;Receiver buffer full ?
   beq.b    _ikbd_rcvbuf_empty      ;nein

   move.w   d2,-(sp)                ;sichern
   bsr.b    arcvint
   move.w   (sp)+,d2

_ikbd_rcvbuf_empty:
   andi.b   #$20,d2
   beq.b    exit_ikbdsys            ;kein Fehler
   move.b   keybd.w,d0              ;ACIA Data Register
   lea      iorec_kb,a0
   movea.l  kbdvecs+4,a1            ;vkbderr
   jmp      (a1)                    ;Fehlerroutine ausfuehren

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
   move.b   keybd.w,d0              ;Daten vom ACIA holen
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
* beim 68020/30 werden die Caches abgeschaltet
*

warm_boot:
 move     #$2700,sr                ; Interrupts sperren, SUP
 cmpi.b   #4,machine_type          ; Falcon?
 bne.b    warmb_02                 ; nein

wb_01send:
 move.b   #7,giselect.w            ; Register 7 auswaehlen
 move.b   #$c0,giwrite.w           ; Auf Ausgang schalten
 move.b   #15,giselect.w           ; Register 15 waehlen: Port B
 move.b   #0,giwrite.w             ; Datenleitungen Centronics auf 0
 move.b   #14,giselect.w           ; Register 14
 move.b   #$27,giwrite.w           ; Floppy deselektieren,
                                   ;  RTS und DTR auf 0

warmb_02:
 cmpi.w   #40,cpu_typ
 bcs.b    warmb_020
 dc.w     cinva
 nop
 bra.s    warmb_00
 
warmb_020:
 cmpi.w   #20,cpu_typ
 bcs.b    warmb_00
 move.l   #$808,d0                 ; Bit  0=0: instr cache off
                                   ; Bit     3=1: instr cache clear
                                   ; Bit     8=0: data  cache off
                                   ; Bit 11=1: data  cache clear
 movec.l  d0,cacr

warmb_00:
 cmpi.b   #4,machine_type          ; Falcon?
 beq.b    warmb_03                 ; ja, kein Reset !

 reset                             ; beim Falcon kein Reset (Videomimik ...)

warmb_03: 
 cmp.l    #$31415926,$00000426.w   ; resvalid gueltig ?
 bne      syshdr_code                ; nein, Warmstart
 move.l   $42a.w,d0                ; resvector holen
 btst     #0,d0                    ; gueltig ?
 bne      syshdr_code                ; nein, Warmstart
 move.l   d0,a0
 lea      warmb_00(pc),a6          ; Ruecksprungadresse von resvector
 jmp      (a0)                     ; resvector anspringen
 bra      syshdr_code


**********************************************************************
*
* Fuehrt einen Kaltstart aus
*
* beim 68020/30 werden die Caches abgeschaltet
* Spezielle Mimik fuer 040/060.
*

cold_boot:
 move     #$2700,sr                ; Interrupts sperren, SUP
 cmpi.w   #10,cpu_typ
 bcs.b    coldb_00
 moveq    #0,d0
 movec    d0,vbr
 cmpi.w   #20,cpu_typ
 bcs.b    coldb_00
 cmpi.w   #40,cpu_typ
 bcs.b    coldb_20

* 040/060: (AF)

 move.l   #$ffc040,d0              ; no cache serialized
 DC.W     $4e7b,6                  ; _movec,_dtt0
                                   ;  transparent translation daten 0
 move.l   #$7fc000,d0              ; write trough
 DC.W     $4e7b,4                  ; _movec,_itt0
                                   ;  transparent translation intstruction 0
 move.l   #$8000,d0                ; instruction cache on
 movec    d0,cacr                  ; cache set
 DC.W     $f4d8                    ; cinva: caches invalid
 moveq    #0,d0
 DC.W     $4e7b,7                  ; _movec,_dtt1
                                   ;  transparent translation daten 1 aus
 DC.W     $4e7b,5                  ; _movec,_itt1
                                   ;  transparent translation instruction 1 aus
 bra.b    coldb_00

* ab 68020 alle Caches aus
coldb_20:
 move.l   #$808,d0                 ; Bit  0=0: instr cache off
                                   ; Bit     3=1: instr cache clear
                                   ; Bit     8=0: data  cache off
                                   ; Bit 11=1: data  cache clear
 movec.l  d0,cacr
 cmpi.w   #30,cpu_typ
 bcs.b    coldb_00
* ab 68030 MMU deaktivieren
;pmove    long_zero(pc),tc         ; fuer 68030: disable translation
;pmove    long_zero(pc),tt0
;pmove    long_zero(pc),tt1
 pmove    long_zero,tc             ; fuer 68030: disable translation
 pmove    long_zero,tt0
 pmove    long_zero,tt1
coldb_00:
 move.l   4,8                      ; Busfehler auf reset
 lea      memkill_st(pc),a0
 cmpi.b   #3,machine_type          ; TT mit Fastram? Falcon beachten
 bne.b    coldb_st
 subq.l   #8,a0                    ; wegen PASM-Fehler
;suba.l   #memkill_st-memkill_tt,a0
coldb_st:
 moveq    #(coldb_sclr-memkill_tt)/2,d0
 lea      $c,a1
coldb_loop:
 move.w   (a0)+,(a1)+              ; Routine kopieren
 dbf      d0,coldb_loop
 jmp      $c                       ;  und anspringen
memkill_tt:
 lea      coldb_busf(pc),a0        ; beim TT-RAM weitermachen
 move.l   a0,8
memkill_st:
 lea      coldb_sclr(pc),a0
 moveq    #0,d0
 move.l   d0,d1
 move.l   d0,d2
 move.l   d0,d3
 move.l   d0,d4
 move.l   d0,d5
 move.l   d0,d6
 move.l   d0,d7
coldb_loop2:
 movem.l  d0/d1/d2/d3/d4/d5/d6/d7,(a0)  ; Speicher loeschen bis Busfehler
 lea      $20(a0),a0
 bra.b    coldb_loop2
coldb_busf:
 reset
 move.l   4,8                 ; Jetzt Busfehler auf Reset
 lea      $1000000,a0         ; TT-RAM!
 bra.b    coldb_loop2
coldb_sclr:

 INCLUDE "keytab.inc"
