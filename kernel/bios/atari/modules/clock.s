**********************************************************************
*
* char get_clocktype( void )
*
* Liefert 0 = IKBD, 1 = MegaST, 2 = TT/Falcon
*

get_clocktype:
 movea.l  sp,a2                    ; sp retten
 movea.l  8,a1                     ; Busfehlervektor retten
 move.l   #gclt_ikbd,8             ; neuer Busfehlervektor
 cmpi.b   #3,machine_type          ; TT oder Falcon?
 bcc.b    gclt_tt                  ; -> TT-RTC benutzen

; Mega-ST

 lea      $fffffc20,a0
* die Alarmzeit wird nicht zerstoert
 bset     #0,$1b(a0)               ; Bank 1 beschreiben (ggf. Busfehler)
 movep.w  5(a0),d2                 ; rette alte Alarm-Minuten
 move.w   #$a05,d0                 ; beschreibe Alarm-Minuten
 movep.w  d0,5(a0)
 movep.w  5(a0),d1                 ; hole Alarm-Minuten
 movep.w  d2,5(a0)                 ; repariere Alarm-Minuten
 and.w    #$f0f,d1                 ; maskiere Muell weg
 cmp.w    d0,d1                    ; Chip enthielt den Testwert ?
 bne.b    gclt_ikbd                ; Nein: Uhr nicht aktiv, Fehler
 bclr.b   #0,27(a0)                ; selektiere wieder Bank 0
 moveq    #1,d0                    ; Mega-ST Uhr
 bra.b    gclt_ende

; TT und Falcon

gclt_tt:
 move.b   #0,$ffff8961             ; TT-RTC address register
 move.b   $ffff8963,d0             ; TT-RTC data register
 moveq    #2,d0                    ; TT-RTC
 bra.b    gclt_ende
gclt_ikbd:
 moveq    #0,d0                    ; nur IKBD
gclt_ende:
 movea.l  a2,sp
 move.l   a1,8
 rts


**********************************************************************
*
* Rueckgabe gesetztes Carry, wenn keine Uhr eingebaut ist.
*

chk_rtclock:
 cmpi.b   #1,clocktype
 rts


**********************************************************************
*
* void init_dosclock(void)
*
* Initialisiert die 200Hz-Uhr des GEMDOS
*

init_dosclock:
 move.w   syshdr+os_gendatg(pc),dos_date
 bsr      _Gettime
 addq.l   #1,d0
 beq.b    idcl_ikbd                ; Zeit -1 = ungueltig -> IKBD probieren
 subq.l   #1,d0
inidc_set:
 move.w   d0,dos_time
 swap     d0
 move.w   d0,dos_date
 rts
idcl_ikbd:
 bsr      read_ikbdclock
 swap     d0
 tst.b    d0
 swap     d0
 bne.b    inidc_set
 rts


**********************************************************************
*
* long read_rtclock( void )
*
* fuer DOS
*

read_rtclock:
 move.b   clocktype,d0
 beq.b    rrtcl_err                     ; 0 = IKBD
 subq.b   #1,d0
 beq      read_megaclock                ; 1 = MegaST
 bra      read_ttclock                  ; 2 = TT/Falcon
rrtcl_err:
 moveq    #-1,d0
 rts


**********************************************************************
*
* long Gettime( void )
*

Gettime:
 bsr.b      _Gettime
 rte

_Gettime:
 move.b   clocktype,d0
 beq      read_ikbdclock                ; 0 = IKBD
 subq.b   #1,d0
 beq      read_megaclock                ; 1 = MegaST
 bra      read_ttclock                  ; 2 = TT/Falcon


**********************************************************************
*
* void Settime( long timedate )
*

Settime:
 move.l     (a0),-(sp)
 bsr.b      _Settime
 addq.l     #4,sp
 rte

_Settime:
 move.b   clocktype,d0
 beq      write_ikbdclock               ; 0 = IKBD
 subq.b   #1,d0
 beq      write_megaclock               ; 1 = MegaST
 bra      write_ttclock                 ; 2 = TT/Falcon


**********************************************************************
************ MegaST- UHR *********************************************
**********************************************************************

**********************************************************************
*
* void read_megaclock( void)
*
* Mega- Uhr auslesen
*

read_megaclock:
 lea      $fffffc20,a0        ; Adresse des Uhrenchips
 lea      rtclockbuf1,a1
 lea      rtclockbuf2,a2
 bsr      rmegac_l3
rmegac_l1:
 exg      a1,a2
 bsr      rmegac_l3
 moveq    #$c,d0
rmegac_l2:
 move.b   0(a1,d0.w),d1
 cmp.b    0(a2,d0.w),d1
 bne.b    rmegac_l1
 dbf      d0,rmegac_l2
 moveq    #0,d0
 move.b   $b(a1),d0
 mulu     #$a,d0
 add.b    $c(a1),d0
 asr.w    #1,d0
 move.w   d0,d1
 moveq    #0,d0
 move.b   9(a1),d0
 mulu     #$a,d0
 add.b    $a(a1),d0
 asl.w    #5,d0
 add.w    d0,d1
 moveq    #0,d0
 move.b   7(a1),d0
 mulu     #$a,d0
 add.b    8(a1),d0
 asl.w    #8,d0
 asl.w    #3,d0
 add.w    d0,d1
 swap     d1
 moveq    #0,d0
 move.b   4(a1),d0
 mulu     #$a,d0
 add.b    5(a1),d0
 move.w   d0,d1
 moveq    #0,d0
 move.b   2(a1),d0
 mulu     #$a,d0
 add.b    3(a1),d0
 asl.w    #5,d0
 add.w    d0,d1
 moveq    #0,d0
 move.b   (a1),d0
 mulu     #$a,d0
 add.b    1(a1),d0
 asl.w    #8,d0
 asl.w    #1,d0
 add.w    d0,d1
 swap     d1
 move.l   d1,d0
 rts

rmegac_l3:
 moveq    #$c,d0
 moveq    #1,d1
rmegac_l4:
 move.b   0(a0,d1.w),d2
 and.b    #$f,d2
 move.b   d2,0(a1,d0.w)
 addq.w   #2,d1
 dbf      d0,rmegac_l4
 rts

rmegac_rm1:
 moveq    #-1,d0
 rts


**********************************************************************
*
* void write_megaclock( long timedate )
*
* Mega- Uhr setzen
*

write_megaclock:
 lea      $fffffc20,a0        ; Adresse des Uhrenchips
 lea      rtclockbuf1,a1
 move.w   6(sp),d1
 move.w   d1,d0
 and.l    #$1f,d0
 add.w    d0,d0
 divu     #$a,d0
 move.b   d0,$b(a1)
 swap     d0
 move.b   d0,$c(a1)
 move.w   d1,d0
 lsr.w    #5,d0
 and.l    #$3f,d0
 divu     #$a,d0
 move.b   d0,9(a1)
 swap     d0
 move.b   d0,$a(a1)
 lsr.w    #8,d1
 lsr.w    #3,d1
 ext.l    d1
 divu     #$a,d1
 move.b   d1,7(a1)
 swap     d1
 move.b   d1,8(a1)
 move.w   4(sp),d1
 move.w   d1,d0
 and.l    #$1f,d0
 divu     #$a,d0
 move.b   d0,4(a1)
 swap     d0
 move.b   d0,5(a1)
 move.w   d1,d0
 lsr.w    #5,d0
 and.l    #$f,d0
 divu     #$a,d0
 move.b   d0,2(a1)
 swap     d0
 move.b   d0,3(a1)
 lsr.w    #1,d1
 lsr.w    #8,d1
 ext.l    d1
 move.l   d1,d2
 divu     #$a,d1
 move.b   d1,(a1)
 swap     d1
 move.b   d1,1(a1)
 divu     #4,d2
 swap     d2
 clr.b    6(a1)
 move.b   #2,$1f(a0)

 ori.b    #9,$1b(a0)               ; Uhr an, Bank 1 anwaehlen
 move.b   #1,$15(a0)               ; 24 Stunden-Modus
 move.b   d2,$17(a0)               ; Schaltjahrzaehler setzen
 andi.b   #$fe,$1b(a0)             ; Uhr an, Bank 0 anwaehlen

 moveq    #$c,d0
 moveq    #1,d1
wmegac_l1:
 move.b   0(a1,d0.w),0(a0,d1.w)
 addq.w   #2,d1
 dbf      d0,wmegac_l1
 moveq    #0,d0
 rts
wmegac_l2:
 moveq    #-1,d0
 rts


**********************************************************************
************ IKBD- UHR ***********************************************
**********************************************************************

**********************************************************************
*
* "clockvec" des Betriebssystems
*
* Darf d0-d3/a0-a3/a5 benutzen
*
* 5.4.99: IKBD-Datum 0..79 wird als 2000..2079 interpretiert
*

clockvec:
 lea      pack_clock,a0            ; Adresse des Pakets vom IKBD
 bsr.b    bcd_to_bin               ; Jahr 0..99
 subi.b   #80,d0
 bge.b    clvec_under_2000         ; Jahr 80..99 => 0..19
 addi.b   #100,d0                  ; Jahr 0..79 => 20..99
clvec_under_2000:
 move.b   d0,d2
 asl.l    #4,d2                    ; 4 Bit fuer Monat
 bsr.b    bcd_to_bin               ; Monat 1..12
 add.b    d0,d2
 asl.l    #5,d2                    ; 5 Bit fuer Tag
 bsr.b    bcd_to_bin               ; Tag 0..31
 add.b    d0,d2
 asl.l    #5,d2                    ; 5 Bit fuer Stunde
 bsr.b    bcd_to_bin               ; Stunde 0..23
 add.b    d0,d2
 asl.l    #6,d2                    ; 6 Bit fuer Minute
 bsr.b    bcd_to_bin               ; Minute 0..59
 add.b    d0,d2
 asl.l    #5,d2                    ; 5 Bit fuer 30*2 Sekunden
 bsr.b    bcd_to_bin               ; Sekunden 0..59
 lsr.b    #1,d0                    ; umrechnen in 2s-Takt
 add.b    d0,d2
 move.l   d2,timedate              ; Zeit/Datum im DOS- Format
 clr.b    ikbdclock_flag           ; Handshake, erledigt!
 rts

bcd_to_bin:
 move.b   (a0)+,d0                 ; Zeichen holen
 move.b   d0,d1                    ; merken
 and.w    #$f,d0                   ; untere Dezimalstelle
 and.w    #$f0,d1                  ; obere Dezimalstelle
 asr.w    #4,d1                    ; nach rechts schieben
 mulu     #$a,d1                   ; * 10
 add.w    d1,d0                    ; Wert ausrechnen
 rts


**********************************************************************
*
* void read_ikbdclock( void)
*
* IKBD- Uhr auslesen
*

read_ikbdclock:
 st.b     ikbdclock_flag           ; ist zu erledigen
 moveq    #$1c,d1                  ; Befehl zum Holen der Zeit ...
 bsr      _bconout_ikbd            ; ... an IKBD schicken
 movea.l  _hz_200,a0
 adda.w   #200,a0                  ; maximal 1s warten
 moveq    #0,d0
rics_loop:
 cmpa.l   _hz_200,a0
 bcs.b    rics_ende                ; Timeout, keine (!) Fehlermeldung
 tst.b    ikbdclock_flag           ; inzwischen gelesen ?
 bne.b    rics_loop                ; nein, weiter
 move.l   timedate,d0              ; Zeit/Datum im DOS- Format
rics_ende:
 rts


**********************************************************************
*
* void write_ikbdclock( long timedate )
*
* IKBD- Uhr setzen
*
* 5.4.99: BIOS-Datum 20..119 (2000 bis 2099) wird als
* 0..99 zum IKBD geschickt.
*

write_ikbdclock:
 move.l   4(sp),d2
 subq.l   #6,sp                    ; Platz fuer 6 Bytes
 lea      6(sp),a0
 move.b   d2,d0
 andi.b   #$1f,d0
 asl.b    #1,d0
 bsr.b    bin_to_bcd               ; s
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$3f,d0
 bsr.b    bin_to_bcd               ; min
 lsr.l    #6,d2
 move.b   d2,d0
 andi.b   #$1f,d0
 bsr.b    bin_to_bcd               ; h
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$1f,d0
 bsr.b    bin_to_bcd               ; Tag
 lsr.l    #5,d2
 move.b   d2,d0
 andi.b   #$f,d0
 bsr.b    bin_to_bcd               ; Monat
 lsr.l    #4,d2
 move.b   d2,d0
 andi.b   #$7f,d0                  ; 7 Bit fuer Jahr (0..127)
 addi.b   #80,d0                   ; Jahr (80..207)
 cmpi.b   #100,d0
 bcs.b    wics_under_2000          ; Jahr 80..99
 subi.b   #100,d0                  ; Jahr 0..79
wics_under_2000:
 bsr.b    bin_to_bcd               ; Jahr
 moveq    #$1b,d1                  ; Time-of-day clock set
 bsr      _bconout_ikbd
 moveq    #5,d0                    ; 6 Bytes
 lea      (sp),a0                  ; Pufferadresse
 bsr      _ikbdws
 addq.l   #6,sp
 moveq    #$1c,d1                  ; Interrogate time-of-day clock
 bra      _bconout_ikbd

bin_to_bcd:
 moveq    #0,d1
 move.b   d0,d1
 divs     #$a,d1
 asl.w    #4,d1
 move.w   d1,d0
 swap     d1
 add.w    d1,d0
 move.b   d0,-(a0)
 rts


*********************************************************************
**************************** TT-RTC *********************************
*********************************************************************

read_ttclock:
 move.b   #$d,$ffff8961
 btst     #7,$ffff8963
 beq      rttc_rm1
 move     sr,d2
 move.w   d2,d0
 or.w     #$700,d0
rttc_l1:
 move.b   #$a,$ffff8961
 btst     #7,$ffff8963
 bne.b    rttc_l1
 moveq    #0,d0
 move.l   d0,d1
 move.b   #0,$ffff8961
 move.b   $ffff8963,d0
 asr.w    #1,d0
 move.b   #2,$ffff8961
 move.b   $ffff8963,d1
 bfins    d1,d0{$15:6}
 move.b   #4,$ffff8961
 move.b   $ffff8963,d1
 bfins    d1,d0{$10:5}
 move.b   #7,$ffff8961
 move.b   $ffff8963,d1
 bfins    d1,d0{$b:5}
 move.b   #8,$ffff8961
 move.b   $ffff8963,d1
 bfins    d1,d0{7:4}
 move.b   #9,$ffff8961
 move.b   $ffff8963,d1
 sub.b    #$c,d1
 bfins    d1,d0{0:7}
 move     d2,sr
 move     sr,d2
 ori      #$700,sr
 move.w   d0,dos_time
 swap     d0
 move.w   d0,dos_date
 swap     d0
 move     d2,sr
 rts
rttc_rm1:
 moveq    #-1,d0
 rts

write_ttclock:
 move.l   4(sp),d0
 move.b   #$b,$ffff8961
 move.b   #$80,$ffff8963
 move.b   #$a,$ffff8961
 move.b   #$2a,$ffff8963
 move.b   #$b,$ffff8961
 move.b   #$8e,$ffff8963
 move.b   #0,$ffff8961
 bfextu   d0{$1b:5},d1
 add.b    d1,d1
 move.b   d1,$ffff8963
 move.b   #2,$ffff8961
 bfextu   d0{$15:6},d1
 move.b   d1,$ffff8963
 move.b   #4,$ffff8961
 bfextu   d0{$10:5},d1
 move.b   d1,$ffff8963
 move.b   #7,$ffff8961
 bfextu   d0{$b:5},d1
 move.b   d1,$ffff8963
 move.b   #8,$ffff8961
 bfextu   d0{7:4},d1
 move.b   d1,$ffff8963
 move.b   #9,$ffff8961
 bfextu   d0{0:7},d1
 add.b    #$c,d1
 move.b   d1,$ffff8963
 move.b   #$b,$ffff8961
 move.b   #$e,$ffff8963
 rts


**********************************************************************
*
* long NVMAccess(int op, int start, int count, char *buf)
*
* op == 0: NVM -> buffer                     READ
*       1: buffer -> NVM                     WRITE
*       2: 0 -> NVM und initialisieren       INIT
*

NVMaccess:
 move.l     6(a0),-(sp)    ;*buf
 move.w     4(a0),-(sp)    ;count
 move.w     2(a0),-(sp)    ;start
 move.w     (a0),-(sp)     ;op
 bsr.b      _NVMaccess
 lea.l      10(sp),sp
 rte

_NVMaccess:
 moveq    #-5,d0              ; EBADRQ
 cmpi.b   #3,machine_type     ; TT oder Falcon?
 bcs.b    nvm_ende            ; der ST kennt kein NVM
 move.w   4(sp),d1            ; d1 = op
 beq.b    nvmac_l3           ; READ
 cmp.w    #2,d1               ; INIT ?
 beq.b    nvmac_l6           ; Ja
 bhi.b    nvm_ende            ; > 2 => EBADRQ

* op == 1 (WRITE)
 bsr.b    NVM_consistency
 tst.w    d0                  ; Daten und Parameter gueltig ?
 bne.b    nvm_ende            ; nein, Fehler zurueckgeben
 movea.l  $a(sp),a0           ; buffer
 bra.b    nvmac_l2
nvmac_l1:
 move.b   d1,(a1)             ; Register selektieren
 move.b   (a0)+,(a2)          ; und beschreiben
 addq.w   #1,d1
nvmac_l2:
 dbf      d2,nvmac_l1
 bsr      NVM_chksum
 move.b   #$3f,(a1)           ; Register 63
 move.b   d0,(a2)             ;  wird Checksumme
 not.b    d0
 move.b   #$3e,(a1)           ; Register 62
 move.b   d0,(a2)             ;  wird invertierte Checksumme
 moveq    #0,d0               ; kein Fehler
nvm_ende:
 rts

* op == 0 (READ)
nvmac_l3:
 bsr.b    NVM_consistency
 cmp.w    #-5,d0              ; EBADRQ (Parameter falsch)
 beq.b    nvm_ende            ; ja, beenden
 movea.l  $a(sp),a0           ; buffer
 bra.b    nvmac_l5
nvmac_l4:
 move.b   d1,(a1)             ; Register auswaehlen
 move.b   (a2),(a0)+          ; auslesen
 addq.w   #1,d1
nvmac_l5:
 dbf      d2,nvmac_l4
 rts

* op == 2 (INIT)
nvmac_l6:
 lea      $ffff8961,a1        ; RTCadr
 lea      $ffff8963,a2        ; RTCdata
 moveq    #0,d0
 moveq    #$e,d1              ; ab Register 14
 moveq    #$31,d2             ; 50 Register (14..63) mit je 1 Byte
nvmac_l7:
 move.b   d1,(a1)             ; Registernummer auswaehlen
 move.b   d0,(a2)             ; Register auf 0 setzen
 addq.w   #1,d1               ; naechstes Register
 dbf      d2,nvmac_l7
 move.b   #$3e,(a1)           ; Register 62
 move.b   #$ff,(a2)           ;  auf -1 setzen
 rts                          ; Rueckgabewert ist 0L

NVM_consistency:
 bsr.b    NVM_chksum
 move.b   d0,d1               ; Summe der Register 14..61
 moveq    #EGENRL,d0
 move.b   #$3f,(a1)           ; Register 63 enthaelt die Checksumme
 cmp.b    (a2),d1             ; stimmt Checksumme ?
 bne.b    nvmac_l8           ; nein, return(EGENRL)
 not.b    d1                  ; Checksumme invertieren
 move.b   #$3e,(a1)           ; Register 62
 cmp.b    (a2),d1             ; stimmt Checksumme ?
 bne.b    nvmac_l8           ; nein, return(EGENRL)
 moveq    #EBADRQ,d0
 move.w   $a(sp),d1
 cmp.w    #$30,d1
 bcc.b    nvmac_l8           ; Startregister >= 48
 move.w   $c(sp),d2
 bmi.b    nvmac_l8           ; count < 0
 add.w    d1,d2
 cmp.w    #$30,d2
 bhi.b    nvmac_l8           ; Startregister + count > 48
 moveq    #0,d0               ; kein Fehler
nvmac_l8:
 move.w   $c(sp),d2           ; d2 = count
 move.w   $a(sp),d1           ; d1 = start
 add.w    #$e,d1              ; d1 = start+14 (Registernummer)
 rts


**********************************************************************
*
* long NVM_chksum( void )
*
* Berechnet die Summe der RTC-Register 14..61
*

NVM_chksum:
 lea      $ffff8961,a1        ; RTCadr
 lea      $ffff8963,a2        ; RTCdata
 moveq    #0,d0
 moveq    #$e,d1              ; ab Register 14
 moveq    #$2f,d2             ; 48 Register (14..61)
nvmcs_loop:
 move.b   d1,(a1)             ; Register selektieren
 add.b    (a2),d0             ; Checksumme bilden
 addq.w   #1,d1               ; naechstes Register
 dbf      d2,nvmcs_loop
 rts
