*********************************************************************
*
* a0 = IOREC *init_aux_iorec( d0 = char flag )
*
* Alloziert Speicher fuer serielle Schnittstelle und legt IOREC an
* d0 != 0, wenn SCC, sonst MFP
*


init_aux_iorec:
 move.l   d0,-(sp)
 move.l   #256+256+$24,d0          ; 2*IOREC + 2*Puffer
 bsr      Bmalloc
 move.l   (sp)+,d0
 lea      $24(a0),a1               ; Eingabepuffer hinter IOREC
 move.w   #256,d1                  ; Pufferlaenge
 move.l   a1,(a0)+
 adda.w   d1,a1                    ; Ausgabepuffer hinter Eingabepuffer
 move.w   d1,(a0)+
 clr.l    (a0)+
 move.l   #$008000c0,(a0)+         ;ibuflow, ibufhi Eingabe-IOREC
 move.l   a1,(a0)+
 move.w   d1,(a0)+
 clr.l    (a0)+
 move.l   -14(a0),(a0)+            ; Ausgabepuffer wie Eingabepuffer
 clr.l    (a0)+                    ;aux_lock_rcv, aux_lock_tmt
 move.l   #$010001ff,(a0)          ;aux_handshake (XON/XOFF), aux_x_buf, baudrate (9600), bitchr
 tst.b    d0                       ;MFP?
 beq.b    iai_ende
;move.l   #$01000001,(a0)          ; Fehler in Mag!X 1.11, SCC
 move.w   #$08ea,-4(a0)            ;aux_status_rcv2, aux_status_tmt
iai_ende:
 lea      -32(a0),a0               ; a0 zeigt auf IOREC
 rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Serielle MFP-Routinen
;
;neue Interruptroutinen fuer ST- und TT-MFP

;IPL6 und IPL7 haben die gleiche Auswirkung auf die CPU: Es werden ausser
;Level7-Interrupts keine anderen bearbeitet. IPL6 wird bei der MFP-
;Interruptannahme automatisch gesetzt und erst bei RTE automatisch zurueck-
;gesetzt. Deshalb in den MFP-I.routinen kein IPL7 bei Soundchipzugriffen.

;Immer erst den MFP-Status lesen, wenn man ihn lesen will,
;dann das Byte lesen oder schreiben,
;sonst killt man beim Statuslesen schon den naechsten Interrupt.

;Die Originalroutinen schreiben alle das RSR / TSR nach +$1c / +$1d,
;aber wozu ist das gut? Wird vom TOS nie ausgewertet. Fuer High Speed
;weglassen! Zum Lesen&Ruecksetzen einer Fehlermeldung ist es doch nur
;in den Fehlerinterrupts des MFP sinnvoll und notwendig.

;Nur bei XON/XOFF-Handshake und RTS/CTS-Empfang wird
;iorecm1 +$1e / +$1f benutzt. Bei RTS/CTS-Senden nicht!

;Es ist lebenswichtig, dass die in den Interruptroutinen gesicherten
;Register aufeinander abgestimmt sind, da sie z.T. ineinander hopsen.

;Da es sich um Ringpuffer handelt, ist folgende exakte Definition fuer Puffer
;voll und Puffer leer notwendig:
;- Puffer leer: Schreibzeiger = Lesezeiger
;- Puffer voll: ((Schreibzeiger + 1) modulo Pufferlaenge) = Lesezeiger

;Ein Zeiger wird erst benutzt (an dieser Position gelesen / geschrieben)
;und dann erhoeht. Wird beim Erhoehen das Pufferende erreicht
;(Zeiger = Pufferlaenge), so wird der Zeiger sofort auf 0 gesetzt.

;Lese minus Schreibzeiger
;BHI ueberspringe naechstes
;plus Laenge
;ergibt Anzahl freier Plaetze

;Schreib minus Lesezeiger
;BCC ueberspringe naechstes
;plus Laenge
;ergibt Anzahl belegter Plaetze

;Der MFP setzt zuerst das entsprechende Bit im Statusregister
;(z.B. Sendepuffer leer), meldet einen Interrupt in IPRA bzw. IPRA an und
;aktiviert dann die Interruptleitung zur CPU. Deshalb muss eine Abfrage der
;Statusregister immer unter Interruptsperre erfolgen und wenn z.B.
;Senderegister leer, muss noch durch Schreiben einer 0 in dem Bit nach IPRx
;der Interrupt wieder deaktiviert werden, wenn man das Senderegister direkt
;nachladen will. In IPRx und ISRx koennen Bits per CPU nur auf 0 geloescht,
;aber nie auf 1 gesetzt werden, deshalb uninteressante Bits beim Schreiben
;eines Bytes auf 1 lassen.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; int_mfp12
;
;MFP-Empfangsregister voll, Vektor auf $130 (iva_mfp_rbf)
;Interrupt MFP-Empfangsregister voll fuer RTS/CTS (HardwareHS)
;
; Nur fuer ST-MFP!
int_mfp12:
                  movem.l  d0-d1/a0-a1,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  move.b   udr.w,d0       ;Byte aus Empfangsregister holen
                  move.w   ibuftl(a0),d1  ;Schreibzeiger holen
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    anobufend
                  moveq    #0,d1
anobufend:
                  cmp.w    ibufhd(a0),d1
                  beq.b    aende          ;Puffer voll, Byte wegwerfen
                  movea.l  (a0),a1        ;Pufferadresse
                  move.b   d0,0(a1,d1.l)  ;Byte -> Puffer
                  move.w   d1,ibuftl(a0)  ;Schreibzeiger aktualisieren
;Anzahl belegter Byte berechnen
                  sub.w    ibufhd(a0),d1  ;minus Lesezeiger
                  bcc.b    ainbuf         ;keine Korrektur
                  add.w    ibufsiz(a0),d1 ;sonst plus Puffergroesse
ainbuf:
                  cmp.w    ibufhi(a0),d1  ;vergleiche mit High Water Mark
                  bcs.b    aende          ;noch kein Hochwasser, hops (wohl angebrachter als BLT)
                  tst.b    aux_lock_rcv(a0)
                  bne.b    aende          ;Empfaenger schon inaktiv
                  st       aux_lock_rcv(a0) ;Empfaenger sperren
;da IPL6, sind schon alle Interrupts gesperrt
                  move.b   #$0e,giselect.w ;RTS inaktiv (TTL-High) schalten
                  moveq    #8,d1
                  or.b     giread.w,d1
                  move.b   d1,giwrite.w      ; Register 14, Bit 3 setzen
aende:
                  move.b   #$ef,isra.w    ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d0-d1/a0-a1
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interrupt MFP-Empfangsregister voll fuer XON/XOFF (SoftwareHS)
int_mfptt12X:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser2.w,a0
                  lea      UDR_TT.w,a2
                  bra.b    _int_mfp12X
int_mfp12X:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  lea      udr.w,a2
_int_mfp12X:
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  move.b   (a2),d0        ;Byte aus Empfangsregister
                  cmpi.b   #XOFF,d0       ;XOFF?
                  beq.b    brexoff        ; ja
                  cmpi.b   #XON,d0        ;XON ?
                  beq.b    brexon         ; ja
                  move.w   ibuftl(a0),d1  ;Schreibzeiger holen
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    bnobufend
                  moveq    #0,d1
bnobufend:
                  cmp.w    ibufhd(a0),d1
                  beq.b    bende          ;Puffer voll, Byte wegwerfen
                  movea.l  (a0),a1        ;Pufferadresse
                  move.b   d0,0(a1,d1.l)  ;Byte -> Puffer
                  move.w   d1,ibuftl(a0)  ;Schreibzeiger aktualisieren
;Anzahl belegter Byte errechnen
                  sub.w    ibufhd(a0),d1  ;minus Lesezeiger
                  bcc.b    binbuf         ;keine Korrektur
                  add.w    ibufsiz(a0),d1 ; sonst plus Puffergroesse
binbuf:
                  cmp.w    ibufhi(a0),d1  ;vergleiche mit High Water Mark
                  bcs.b    bende          ;noch kein Hochwasser, hops (wohl angebrachter als BLT)
                  tst.b    aux_lock_rcv(a0)
                  bne.b    bende          ;Empfaenger schon inaktiv
                  st       aux_lock_rcv(a0) ;Empfaenger sperren und XOFF senden
                  moveq    #XOFF,d0       ;XOFF
;da IPL6, ist schon totale Interruptsperre
                  tst.b    tsr-udr(a2)
                  bpl.b    btrfull        ;Senderegister voll, XOFF spaeter senden
                  move.b   #$fb,ipra-udr(a2) ;evtl. Interrupt loeschen
                  move.b   d0,(a2)        ;XOFF sofort senden (->udr)
                  clr.b    d0             ;loeschen, da schon gesendet
btrfull:
                  move.b   d0,aux_x_buf(a0)
bende:
                  move.b   #$ef,isra-udr(a2) ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte
brexoff:
                  st       aux_lock_tmt(a0) ;XOFF empfangen, Sender sperren
                  bra.b    bende
brexon:
                  sf       aux_lock_tmt(a0) ;XON empfangen, Sender freigeben
;da IPL6, ist schon totale Interruptsperre
                  tst.b    tsr-udr(a2)
                  bpl.b    bende          ;Senderegister noch voll, keine Aktion weiter
                  move.b   #$ef,isra-udr(a2) ;anhaengigen Interrupt loeschen
                  move.b   #$fb,ipra-udr(a2) ;evtl. Senderegister leer Int. loeschen
                  bra      i_mfp_tesx     ;Sprung in den Sendeinterrupt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interrupt MFP-Empfangsregister voll ohne Handshake
;
int_mfptt12NH:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser2.w,a0
                  lea      UDR_TT.w,a2
                  bra.b    _int_mfp12NH
int_mfp12NH:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  lea      udr.w,a2
_int_mfp12NH:
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  move.b   (a2),d0        ;Byte aus Empfangsregister
                  move.w   ibuftl(a0),d1  ;Schreibzeiger holen
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    cnobufend
                  moveq    #0,d1
cnobufend:
                  cmp.w    ibufhd(a0),d1
                  beq.b    cende          ;Puffer voll, Byte wegwerfen
                  movea.l  (a0),a1        ;Pufferadresse
                  move.b   d0,0(a1,d1.l)  ;Byte -> Puffer
                  move.w   d1,ibuftl(a0)  ;Schreibzeiger aktualisieren
cende:
                  move.b   #$ef,isra-udr(a2) ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte

;--------------------------------------------------
;
;MFP-Senderegister leer, Vektor auf $128 (iva_mfp_tbe)
;
;Interrupt MFP-Senderegister leer mit RTS/CTS (HardwareHS)
;
; Nur fuer ST-MFP!
int_mfp10:
                  movem.l  d1/a0-a1,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
i_mfp_tehx:                               ;hierhin kann i_mfp_cts springen;
                  move.w   ibufhd+$e(a0),d1 ;Lesezeiger
                  cmp.w    ibuftl+$e(a0),d1
                  beq.b    dende          ;Puffer leider leer
                  btst     #2,gpip.w      ;teste CTS-Eingang
                  bne.b    dende          ;leider darf ich nicht da CTS inaktiv
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz+$e(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    dnobufend
                  moveq    #0,d1
dnobufend:
                  movea.l  $0e(a0),a1     ;Pufferadresse Ausgabe-IOREC
                  move.b   0(a1,d1.l),udr.w ;Puffer -> Senderegister
                  move.w   d1,ibufhd+$e(a0) ;Lesezeiger aktualisieren
dende:
                  move.b   #$fb,isra.w ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d1/a0-a1
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interrupt MFP-Senderegister leer XON/XOFF (SoftwareHS)
int_mfptt10X:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser2.w,a0
                  lea      UDR_TT.w,a2
                  bra.b    _int_mfp10X
int_mfp10X:
                  movem.l  d0-d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  lea      udr.w,a2
_int_mfp10X:
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  move.b   aux_x_buf(a0),d0 ;wenn hier <>0, das sofort ungeachtet Sperre senden
                  clr.b    aux_x_buf(a0)  ;loeschen, clr und auch sf aendert Flags
                  tst.b    d0             ;deshalb nochmal setzen
                  bne.b    esendim
i_mfp_tesx:                               ;hier kann i_mfp_rfs hinspringen; Achtung: a2=udr!
                  move.w   ibufhd+$e(a0),d1 ;Lesezeiger
                  cmp.w    ibuftl+$e(a0),d1
                  beq.b    eende          ;Puffer leider leer
                  tst.b    aux_lock_tmt(a0)
                  bne.b    eende          ;darf leider nicht da Sender gesperrt
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz+$e(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    enobufend
                  moveq    #0,d1
enobufend:
                  movea.l  $0e(a0),a1     ;Pufferadresse Ausgabe-IOREC
                  move.b   0(a1,d1.l),d0  ;Puffer ->
                  move.w   d1,ibufhd+$e(a0) ;Lesezeiger aktualisieren
esendim:
                  move.b   d0,(a2)        ;-> Senderegister (udr)
eende:
                  move.b   #$fb,isra-udr(a2) ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interrupt MFP-Senderegister leer ohne Handshake
int_mfptt10NH:
                  movem.l  d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser2.w,a0
                  lea      UDR_TT.w,a2
                  bra.b    _int_mfp10NH
int_mfp10NH:
                  movem.l  d1/a0-a2,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  lea      udr.w,a2
_int_mfp10NH:
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  move.w   ibufhd+$e(a0),d1 ;Lesezeiger
                  cmp.w    ibuftl+$e(a0),d1
                  beq.b    fende          ;Puffer leider leer
                  addq.w   #1,d1          ;erhoehen, durch .w automatisch auf 64KByte beschraenkt
                  cmp.w    ibufsiz+$e(a0),d1 ;im Puffer umlaufen lassen
                  bcs.b    fnobufend
                  moveq    #0,d1
fnobufend:
                  movea.l  $0e(a0),a1     ;Pufferadresse Ausgabe-IOREC
                  move.b   0(a1,d1.l),(a2) ;Puffer -> Senderegister
                  move.w   d1,ibufhd+$e(a0) ;Lesezeiger aktualisieren
fende:
                  move.b   #$fb,isra-udr(a2) ;anhaengigen Interrupt loeschen
                  movem.l  (sp)+,d1/a0-a2
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CTS Interrupt
;
;Interrupt MFP-IO-Pin CTS aendert Pegel, Vektor auf $108 (iva_mfp_cts)
;Int. wirkt nur bei RTS/CTS-Handshake. Wird nochmal auf die H/L-Flanke
;angesetzt. Das ist die CTS wird aktiv Flanke. Ist das Senderegister leer
;und der Puffer nicht, so wird ein Byte gesendet.
;
; Nur fuer ST-MFP!
int_mfp2:
                  movem.l  d1/a0-a1,-(sp)
                  movea.l  p_iorec_ser1.w,a0
                  moveq    #0,d1          ;loesche vor allem Bit31-16, die muessen 0 bleiben!
                  bclr     #2,aer.w       ;nochmal auf H/L-Flanke ansetzen
                  move.b   #$fb,isrb.w    ;anhaengigen CTS-Interrupt loeschen
                  btst     #1,aux_handshake(a0) ;RTS/CTS-Handshake aktiv?
                  beq.b    gende          ;nein
;durch IPL6 sind schon alle Ints gesperrt
                  tst.b    tsr.w
                  bpl.b    gende          ;Senderegister nicht leer
                  move.b   #$fb,ipra.w    ;evtl. Interrupt loeschen
                  bra      i_mfp_tehx     ;Senderegister leer, Sprung in Sendeint.
gende:
                  movem.l  (sp)+,d1/a0-a1
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interrupt MFP-Sendefehler, z.B. waehrend BREAK-Sendens
int_mfptt9:
                  tst.b    TSR_TT.w       ;lesen -> loescht Fehlerstatus
                  move.b   #$fd,ISRA_TT.w ;Interrupt loeschen
                  rte
int_mfp9:
                  tst.b    tsr.w          ;lesen -> loescht Fehlerstatus
                  move.b   #$fd,isra.w    ;Interrupt loeschen
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Interrupt MFP-Empfangsfehler
int_mfptt11:
                  tst.b    RSR_TT.w       ;lesen -> loescht Fehlerstatus
                  tst.b    UDR_TT.w       ;Zeichen verwerfen
                  move.b   #$f7,ISRA_TT.w ;Interrupt loeschen
                  rte
int_mfp11:
                  tst.b    rsr.w          ;lesen -> loescht Fehlerstatus
                  tst.b    udr.w          ;Zeichen verwerfen
                  move.b   #$f7,isra.w    ;Interrupt loeschen
                  rte

;---------------------------------------------------
;
; int Rsconf( int baud, int ctrl, int ucr, int rsr, int tsr, int scr )
;
; baud: 0 = 19200
;       1 =  9600
;       2 =  4800
;        ...
;      13 =  110
;      14 =   75
;      15 =   50
;
; ctrl = 0     kein Handshake
;        1     XON/XOFF
;        2     RTS/CTS  (nicht fuer TT-MFP!)
;        3     XON/XOFF und RTS/CTS, nicht sinnvoll
;

;Rsconf fuer TT-MFP
rsconf_ser2:
                  movea.l  p_iorec_ser2.w,a0
                  lea      GPIP_TT.w,a2
                  bra.b    _rsconf_mfp
;Rsconf fuer ST-MFP
rsconf_ser1:
                  movea.l  p_iorec_ser1.w,a0
                  lea      gpip.w,a2
_rsconf_mfp:
                  moveq    #0,d0
                  cmpi.w   #$fffe,4(sp)   ;Parameter speed
                  bne.b    rsm1nob
                  move.b   baudrate(a0),d0 ;bei speed = -2 nur die eingestellte
                  rts                     ;Baudrate zurueckgeben
rsm1nob:
                  move     sr,d1
                  swap     d1             ;sichern, Highword nicht nutzen!
                  ori      #$0700,sr      ;Interruptsperre
                  movep.l  ucr-gpip(a2),d0 ;ucr,rsr,tsr,udr lesen als Returnwert

                  move.w   4(sp),d1       ;Parameter speed
                  bmi.b    rsm1nosp       ;Sprung fuer nicht aendern
                  bclr     #0,rsr-gpip(a2) ;RS232-Empfaenger aus
                  bclr     #0,tsr-gpip(a2) ;RS232-Sender aus
                  move.b   d1,baudrate(a0) ;Parameter speed speichern
                  lea      rsm1tps(pc),a1 ;zum Uebersetzen mit Tabelle
                  andi.b   #$70,tcdcr-gpip(a2) ;MFP-Timer D Reset
;MFP-Timer D Data register setzen (Zaehler)
                  move.b   rsm1tct-rsm1tps(a1,d1.w),tddr-gpip(a2)
                  move.b   0(a1,d1.w),d2
                  or.b     d2,tcdcr-gpip(a2) ;Vorteilerregister setzen
                  bset     #0,rsr-gpip(a2) ;RS232-Empfaenger ein
                  bset     #0,tsr-gpip(a2) ;RS232-Sender ein

rsm1nosp:
                  move.w   $08(sp),d2     ;Parameter ucr
                  bmi.b    rsm1fcu0       ;Sprung fuer nicht aendern
                  move.b   d2,ucr-gpip(a2) ;Byte ins ucr-Register des MFP
rsm1fcu0:
                  move.w   $0a(sp),d2     ;Parameter rsr
                  bmi.b    rsm1fcr0       ;Sprung fuer nicht aendern
                  move.b   d2,rsr-gpip(a2) ;Byte ins rsr-Register des MFP
rsm1fcr0:
                  move.w   $0c(sp),d2     ;Parameter tsr
                  bmi.b    rsm1fct0       ;Sprung fuer nicht aendern
                  move.b   d2,tsr-gpip(a2) ;Byte ins tsr-Register des MFP
rsm1fct0:
                  move.w   $0e(sp),d2     ;Parameter scr
                  bmi.b    rsm1fcs0       ;Sprung fuer nicht aendern
                  move.b   d2,scr-gpip(a2) ;Byte ins scr-Register des MFP
rsm1fcs0:
                  move.w   6(sp),d2       ;Parameter flowctl
                  cmpi.w   #3,d2
                  bhi.b    rsm1fcbi       ;flowctl ist zu gross
                  bne.b    rsm1fcnb       ;flowctl nicht XON/XOFF & RTS/CTS
                  moveq    #1,d2          ;"beides" aendere auf XON/XOFF
rsm1fcnb:
                  cmp.l    #GPIP_TT,a2    ;TT-MFP?
                  bne.b    rsm1cnfhs
                  cmp.w    #2,d2          ;RTS/CTS-Handshake ist mit TT-MFP
                  bne.b    rsm1cnfhs      ;nicht moeglich!
                  moveq    #0,d2          ;"kein Handshake" einstellen!
rsm1cnfhs:
                  cmp.b    aux_handshake(a0),d2 ;vergleiche mit altem
                  beq.b    rsm1fcbi       ;neues = altes, keine Sonderaktion
;Das bedeutet, die erste RTS-Aktivierung nach Reset muss ein anderer machen.
                  move.b   d2,aux_handshake(a0) ;flowctl speichern (noch in d2 gebraucht)

                  clr.w    aux_lock_rcv(a0) ;Empfaenger und Sender (+$1f) freigeben
;
;Wenn der Empfangspuffer voll ist, gehen evtl. gleich nach dieser
;Umschaltung ein paar Zeichen verloren. Das ist aber TOS-kompatibel.
;Ansonsten muss man umstaendlich pruefen, ob der Empfaenger freigegeben werden
;darf.
                  move.b   #$0e,giselect.w ;RTS aktiv (TTL-Low) schalten
                  move.b   #$f7,d1
                  and.b    giread.w,d1
                  move.b   d1,giwrite.w      ; Register 14, Bit 3 loeschen

                  cmpi.b   #1,d2          ;welcher Handshake?
                  bne.b    rsm1nosh       ;kein XON/XOFF
;
;Bei XON/XOFF-HS jetzt ein XON senden, und zwar mit den neuen
;Einstellungen, deshalb erst hier. Hinweis: hier ist IPL7
rsm1wfte:         tst.b    tsr-gpip(a2)   ;MFP-Senderegister leer ?
                  bpl.b    rsm1wfte       ;nicht leer, warten
                  move.b   #$fb,ipra-gpip(a2) ;evtl. Interrupt loeschen
                  move.b   #XON,udr-gpip(a2) ;XON -> Senderegister
rsm1nosh:
                  lsl.w    #3,d2          ;Handshakemode * 8, je 2 longs
                  lea      iva_mfp_tbe,a0 ;Sendepuffer leer Int.

                  lea      rsm1tiad(pc),a1 ;IR-Routinen fuer Modem 1
                  cmpa.l   #gpip,a2
                  beq.b    _rsset_irfunc
                  lea      rss1tiad(pc),a1 ;IR-Routinen fuer Serial 1
                  lea      $40(a0),a0     ;auf TT-MFP setzen

_rsset_irfunc:    move.l   0(a1,d2.w),(a0)
                  move.l   4(a1,d2.w),$130-$128(a0);Empfangspuffer voll Int.
rsm1fcbi:
;Rueckgabewert in d0: ucr,rsr,tsr,udr in Bit31-0
                  swap     d1
                  move     d1,sr          ;alte Interruptmaske
                  rts

;Baudratenuebersetzungstabelle:
rsm1tps:          DC.B 1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2 ;Vorteiler
rsm1tct:          DC.B 1,2,4,5,8,$0a,$0b,$10,$20,$40,$60,$80,$8f,$af,$40,$60 ;Zaehler
;Statt 50 werden 80 und statt 75 werden 120 Baud eingestellt. Dies ist
;ebenso wie der Rueckgabewert inzwischen von ATARI als Fehler dokumentiert
;und wird sich nicht aendern (laut Profibuch).

;Interruptroutinenadresstabelle (Send/Empf fuer OHNE, XON/XOFF, RTS/CTS)
rsm1tiad:
                  DC.L int_mfp10NH,int_mfp12NH ;Modem 1 - Routinen
                  DC.L int_mfp10X,int_mfp12X
                  DC.L int_mfp10,int_mfp12

rss1tiad:
                  DC.L int_mfptt10NH,int_mfptt12NH ;Serial 1 - Routinen
                  DC.L int_mfptt10X,int_mfptt12X
                  DC.L int_mfptt10NH,int_mfptt12NH ;RTS/CTS wird hardwaremaessig nicht unterstuetzt!

;Modem1, bconout, Zeichenausgabe
;fuer alle drei Flusskontrollarten
bconout_ser2:
                  lea      6(sp),a0
                  move.w   (a0),d0

                  movea.l  p_iorec_ser2.w,a0
                  lea      GPIP_TT.w,a2
                  bra.b    _rsbconout
bconout_ser1:
;word mit dem Ausgabebyte liegt bei 6(sp)
                  lea      6(sp),a0
_bconout_ser1:
                  move.w   (a0),d0        ;Einsprung fuer die serielle Druckerroutine!
                  movea.l  p_iorec_ser1.w,a0
                  lea      gpip.w,a2

_rsbconout:       moveq    #0,d1          ;Bit31-16 muss 0 bleiben!
                  move.w   ibuftl+$e(a0),d1  ;Schreibzeiger holen
                  move.w   ibufsiz+$e(a0),d2 ;Puffergroesse holen
                  addq.w   #1,d1          ;erhoehen, auf 64KByte beschraenkt durch .w
                  cmp.w    d2,d1          ;im Puffer umlaufen lassen
                  bcs.b    _m1_bconbx
                  moveq    #0,d1
_m1_bconbx:       movea.l  $0e(a0),a1     ;Pufferadresse, auch fuer spaeter
                  move.b   d0,0(a1,d1.l)  ;Byte -> Puffer
                  move.w   d1,ibuftl+$e(a0) ;Schreibzeiger aktualisieren
_m1_bcobfu:       move     sr,d0          ;damit kein Interrupt zwischendurch
                  ori      #$0700,sr      ; das Senderegister fuellt
                  tst.b    tsr-gpip(a2)   ;MFP-Senderegister leer ?
                  bpl.b    _m1_bcondl     ;nicht leer
                  cmpi.b   #1,aux_handshake(a0) ;leer, welcher Handshake ?
                  bls.b    _m1_bconhh     ;nicht RTS/CTS
                  btst     #2,(a2)        ;teste CTS-Eingang
                  bne.b    _m1_bcondl     ;leider CTS inaktiv
;Wenn Senden erlaubt und Senderegister leer dann selbst senden.
_m1_bcoscd:       move.w   ibufhd+$e(a0),d1 ;Lesezeiger holen
                  cmp.w    ibuftl+$e(a0),d1 ;gleich Schreibzeiger?
                  beq.b    _m1_bcoend     ;ja, ein Interrupt war schneller
                  addq.w   #1,d1          ;erhoehen, auf 64KByte beschraenkt durch .w
                  cmp.w    d2,d1          ;im Puffer umlaufen lassen
                  bcs.b    _m1_bconbc
                  moveq    #0,d1
_m1_bconbc:
                  move.b   #$fb,ipra-gpip(a2) ;evtl. Interrupt loeschen
                  move.b   0(a1,d1.l),udr-gpip(a2) ;Puffer -> Senderegister
                  move.w   d1,ibufhd+$e(a0) ;Lesezeiger aktualisieren
_m1_bcoend:       move     d0,sr
                  rts

_m1_bconhh:       bcs.b    _m1_bcoscd     ;kein Handshake, sofort senden
                  tst.b    aux_lock_tmt(a0) ;XON/XOFF, teste ob Sender freigegeben
                  beq.b    _m1_bcoscd     ;Sender frei, Zeichen senden
_m1_bcondl:       move     d0,sr          ;Interrupts wieder frei
;Freigabe extrem wichtig, sonst laeuft die Schleife komplett mit IPL 7.
;Anzahl noch freier Plaetze im Puffer ermitteln
                  move.w   ibufhd+$e(a0),d1 ;Lesezeiger
                  sub.w    ibuftl+$e(a0),d1 ;minus Schreibzeiger
                  bhi.b    _m1_bcoxnx     ;keine Korrektur
                  add.w    d2,d1          ;plus Pufferlaenge
_m1_bcoxnx:       subq.w   #1,d1          ;minus 1 statt cmp #1
                  beq.b    _m1_bcobfu     ;voll, warten auf Leerung(smoeglichkeit)
                  rts                     ;Ende (zweites)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Modem1, bcostat, Ausgabestatus
;Da bconout immer mindestens einen freien Platz im Puffer braucht,
;sagt bcostat schon voll, wenn nur noch ein Platz frei ist.
;Wird bconout dann doch aufgerufen, verhaelt es sich wie bei vollem Puffer:
;Es wartet bis das Zeichen raus ist.
bcostat_ser2:
                  movea.l  p_iorec_ser2.w,a0
                  bra.b    _rsbcostat
bcostat_ser1:
                  movea.l  p_iorec_ser1.w,a0
_rsbcostat:
                  move.w   ibufhd+$e(a0),d1 ;freien Platz berechnen, Lesezeiger
                  sub.w    ibuftl+$e(a0),d1 ;minus Schreibzeiger
                  bhi.b    _m1_bcostat    ;keine Korrektur
                  add.w    ibufsiz+$e(a0),d1 ;Pufferlaenge dazu
_m1_bcostat:      subq.w   #3,d1          ;Differenz muss >=3 sein fuer frei
                  scc      d0             ;ja, noch mind. 2 Plaetze frei
                  ext.w    d0
                  ext.l    d0
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Modem1, bconin, Zeicheneingabe
;Fuer alle drei Flusskontrollarten
bconin_ser2:
                  movea.l  p_iorec_ser2.w,a0
                  lea      GPIP_TT.w,a2
                  bra.b    _rsbconin
bconin_ser1:
                  movea.l  p_iorec_ser1.w,a0
                  lea      gpip.w,a2

_rsbconin:        moveq    #0,d1          ;Bit31-16 muss 0 bleiben!
                  moveq    #0,d0          ;beim Returncharacter Bit31-8 =0
                  move.w   ibufhd(a0),d1  ;Lesezeiger holen
m1_cibem:         cmp.w    ibuftl(a0),d1  ;Vergleich mit Schreibzeiger
                  beq.b    m1_cibem       ;Puffer leer, warten
                  addq.w   #1,d1          ;Lesezeiger +1 im Puffer umlaufend
                  cmp.w    ibufsiz(a0),d1
                  bcs.b    m1_cinbt
                  moveq    #0,d1
m1_cinbt:         movea.l  (a0),a1        ;Pufferadresse
                  move.b   0(a1,d1.l),d0  ;Puffer -> Byte
                  move.w   d1,ibufhd(a0)  ;Lesezeiger aktualisieren
                  tst.b    aux_handshake(a0) ;Handshake ?
                  beq.b    m1_ciend       ;kein Handshake
;Teste zuerst, ob der Empfaenger freigegeben ist. Das ist schneller, als
;wenn erst auf untere Wassermarke getestet wird.
                  tst.b    aux_lock_rcv(a0)
                  beq.b    m1_ciend       ;Empfaenger ist freigegeben
;Anzahl belegter Byte berechnen
                  move.w   ibuftl(a0),d1  ;Schreibzeiger
                  sub.w    ibufhd(a0),d1  ;minus Lesezeiger
                  bcc.b    m1_cincd       ;keine Korrektur
                  add.w    ibufsiz(a0),d1 ;sonst Laenge dazu
m1_cincd:         cmp.w    ibuflow(a0),d1 ;untere Wassermarke
                  bhi.b    m1_ciend       ;untere W. noch nicht unterschritten
                  sf       aux_lock_rcv(a0) ;Empfaenger freigeben
                  move     sr,d2
                  ori      #$0700,sr      ;sonst koennten noch Interrupts erfolgen
                  btst     #1,aux_handshake(a0) ;welcher Handshake?
                  beq.b    m1_cish        ;XON/XOFF (kein RTS/CTS)
                  move.b   #$0e,giselect.w ;RTS aktiv (TTL-Low) schalten
                  moveq    #-9,d1
                  and.b    giread.w,d1
                  move.b   d1,giwrite.w      ; Register 14, Bit 3 loeschen
                  move     d2,sr          ;Interruptlevel wieder herstellen
m1_ciend:         rts                     ;Ende (1)
m1_cish:
                  moveq    #XON,d1        ;XON bei XON/XOFF-Handshake
                  tst.b    tsr-gpip(a2)   ;Interrupts sind schon gesperrt
                  bpl.b    m1_citf        ;Senderegister voll, XON spaeter senden
                  move.b   #$fb,ipra-gpip(a2) ;evtl. Interrupt loeschen
                  move.b   d1,udr-gpip(a2) ;XON sofort senden
                  move     d2,sr          ;Interruptlevel wieder herstellen
                  rts                     ;Ende (2)
m1_citf:
                  move     d2,sr          ;Interruptlevel wieder herstellen
                  move.b   d1,aux_x_buf(a0) ;XON vormerken
                  rts                     ;Ende (3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Serial1/Modem1, bconstat, Eingabestatus
bconstat_ser2:
                  movea.l  p_iorec_ser2.w,a0
                  moveq    #-1,d0
                  move.w   ibufhd(a0),d1
                  cmp.w    ibuftl(a0),d1
                  sne      d0
                  ext.w    d0
                  ext.l    d0
                  rts
bconstat_ser1:
                  movea.l  p_iorec_ser1.w,a0
                  moveq    #-1,d0
                  move.w   ibufhd(a0),d1
                  cmp.w    ibuftl(a0),d1
                  sne      d0
                  ext.w    d0
                  ext.l    d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SCC-Routinen
;
;-------------------------------------------------------------
;
; void init_scc( void )
;
; wird von init_mfp aufgerufen.
; Initialisiert SCC A und SCC B
;
init_scc:
 lea      $180,a0                  ; Interruptvektoren
 lea      autointr_scc(pc),a1      ; 8 Interruptroutinen, 8 Nullen (!)
 moveq    #$f,d0
iscc_loop:
 move.l   (a1)+,(a0)+              ; Interrupts setzen
 dbf      d0,iscc_loop

 cmpi.b   #3,machine_type
 bne.b    isc_ste
 clr.w    $ffff8c14                ; TOS 3.06, Kontrollregister SCC DMA
isc_ste:
 cmpi.b    #4,machine_type
 beq.b    isc_falc                 ;Bit 7 schaltet beim Falcon das IDE-Laufwerk aus

 bsr.b    set_porta_bit7           ; mit Bit 7 auf Ser2-Schnittstelle setzen

isc_falc: 
 st       d0                       ; SCC, nicht MFP
 bsr      init_aux_iorec
 move.l   a0,p_iorec_scca
 st       d0
 bsr      init_aux_iorec
 move.l   a0,p_iorec_sccb

 lea      sccctl_a.w,a2
 move.b   #9,(a2)        ;Master Interrupt Control
 move.b   #$c0,(a2)      ;Hardware-RESET durchfuehren

 move.w   #$104,d0
 bsr      timerA_delay

 lea      sccctl_a.w,a0
 lea      initdata_scc(pc),a1
 bsr      isc_l1

 lea      sccctl_b.w,a0
 lea      initdata_scc(pc),a1
 bsr      isc_l1

 cmpi.b   #4,machine_type          ;Falcon
 beq.b    ics_exit                 ;dann kein Zugriff auf SCU
 bset     #5,$ffff8e0d             ;IRQ von SCC
ics_exit: 
     rts

* kopiere (a1)->(a0) bis Byte < 0
isc_l1:
 move.b   (a1)+,d0
 bmi.b    isc_end
 move.b   d0,(a0)
 move.b   (a1)+,(a0)
 bra.b    isc_l1
isc_end:
 rts

set_porta_bit7:
 move     sr,d1
 ori      #$700,sr
 move.b   #$e,giselect        ; Soundchip: I/O Port A selektieren
 move.b   giread,d0           ; Port A lesen
 bset     #7,d0               ; Bit 7 setzen (beim ST nicht benutzt)
 move.b   #$e,giselect        ; nochmal selektieren
 move.b   d0,giwrite          ; und Bit 7 setzen
 move     d1,sr
 rts

;Daten in der Form: Registernummer, Wert
initdata_scc:
;
; Sequenz zum Einstellen der Konstanten und Betriebsmodi
;
;Reg 4: Takt=16*Datenrate, MONOSYNC-Betrieb ,Asynchronbetrieb mit 1 Stopbit, keine Paritaet
                  DC.B $04,$44
;
;Reg 1: Empfaengerinterupts spereen, Paritaetsfehler als Special Condition behandeln
                  DC.B $01,$04
;
;Reg 2: Special Condition beim Empfang
                  DC.B $02,$60
;
;Reg 3: Empfang mit 8 Bits/Zeichen, Empfaenger gesperrt
                  DC.B $03,$c0
;
;Reg 5: DTR auf Low, Senden mit 8 Bits/Zeichen, keine Daten senden, CRC-16, RTS auf High
                  DC.B $05,$e2
;
;Reg 6: Enthaelt im MONOSYNC-Betrieb  das vom Sender verwendete SYNC-Zeichen
                  DC.B $06,$00
;
;Reg 7: Enthaelt im MONOSYNC-Betrieb das verwendete Empfangs-SYNC-Zeichen
                  DC.B $07,$00
;
;Reg 9: Bit 1..3 der Vektornummer beeinflussen, keine RESET,
;       SCC liefert durch Statusinformationen beeinflusste Vektornummer ($180, etc.)
                  DC.B $09,$01
;
;Reg 10: CRC-Schieberegister in Sender und Empfaenger mit 0 vorbesetzen, 8 Bit SYNC
                  DC.B $0a,$00
;
;Reg 11: RTxC ist TTL-Eingang(TTL-Taktgenerator oder Timer C-Takt verwendet)
;        Sende- und Empfangstakt vom Baudratengenerator-Ausgang,  TRxC Out als Eingang
                  DC.B $0b,$50
;
;Reg 12/13: Low/Highbyte fuer Baudratentimer = 9600 Baud
                  DC.B $0c,$18
                  DC.B $0d,$00
;
;Reg 14: _DTR/_REG-Anschluss als DTR, PCLK des SCC (8 MHz) liefert Mastertakt fuer Baudratengenerator
                  DC.B $0e,$02

;
; Jetzt Freigabe der Hardware-Funktionen
;
;Reg 14: s.o, aber jetzt Baudratengenerator freigeben (Bit 0)
                  DC.B $0e,$03
;
;Reg 3: s.o., aber jetzt auch Empaenger freigeben
                  DC.B $03,$c1
;
;Reg 5. s.o, aber jetzt auch Sender freigeben
                  DC.B $05,$ea
;
; Freigabe der Interrupts
;
;Reg 15: Enable Break/Abort, Tx Underrun, CTS, DCD, "Zero Count"
                  DC.B $0f,$20
;
;Reg 0: Reset Ext./Status-Interrupt; muss zweimal durchgefuehrt werden
                  DC.B $00,$10
                  DC.B $00,$10
;
;Reg 1: RxINT bei jedem Zeichen oder Special Condition, Special Cond. bei Parity Error,
;       Freigabe fuer Sender- und Ext./Status-Interrupts
                  DC.B $01,$17
;
;Reg 9: s.o, zusaetzlich MASTER Interrupt Enable
                  DC.B $09,$09
;
; Freigabe der Interrupts beendet

                  DC.B $ff,$00            ;Zeigt das Ende fuer Init-Routine an

 EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  'SCC Interruptroutinen'
;
; SCC Kanal A
; Empfangszeichen verfuegbar/ Special Condition beim Empfang
; in $1b0 und 1b8 eingetragen
scca_int2:
scca_int3:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_a.w,a2
                  move.l   p_iorec_scca,a0
                  bra.b    scc_int2
;
; SCC B
; Empfangszeichen verfuegbar/ Special Condition beim Empfang
; in $190 und $198 eingetragen
sccb_int2:
sccb_int3:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_b.w,a2
                  move.l   p_iorec_sccb,a0
;
; a0: *IOREC
; a2: *SCC Control Register
;
scc_int2:
                  move.b   aux_handshake(a0),d0 ;1: XON/XOF, 2:RTS/CTS, 0: kein Handshake
                  cmp.b    #1,d0
                  bhi      sccint2_RTS    ;2
                  bcs      sccint2_noHS   ;0
;
; SCC Int 2/3 mit XON/XOFF-Handshake
                  move.b   _scc_dat(a2),d0 ;Byte aus Empfangspuffer holen

                  and.b    bitchr(a0),d0  ;Bits pro Zeichen

                  cmp.b    #XOFF,d0
                  bne.b    L00F4
                  st       aux_lock_tmt(a0) ;Sender gesperrt
                  bra      exit_sccint2
L00F4:
                  cmp.b    #XON,d0
                  bne.b    L00F5
                  tst.b    aux_lock_tmt(a0)
                  sf       aux_lock_tmt(a0) ;Sender freigegeben
                  bne.b    sccint2_rdstate
L00F5:
                  moveq    #0,d1
                  move.w   ibuftl(a0),d1

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _L00D6
                  moveq    #0,d1          ;Auf den Anfang setzen
_L00D6:
                  cmp.w    ibufhd(a0),d1
                  beq.b    exit_sccint2   ;raus

                  movea.l  (a0),a1        ;ibuf
                  move.b   d0,0(a1,d1.l)  ;Zeichen eintragen
                  move.w   d1,ibuftl(a0)  ;Tail korrigieren

                  tst.b    aux_lock_rcv(a0)
                  bne.b    exit_sccint2   ;Empfaenger bereits inaktiv

                  move.w   ibuftl(a0),d0  ;Tail
                  sub.w    ibufhd(a0),d0  ;Head
                  bpl.b    L00F6
                  add.w    ibufsiz(a0),d0
L00F6:
                  cmp.w    ibufhi(a0),d0  ;obere "Wassermarke"
                  blt.b    exit_sccint2

                  st       aux_lock_rcv(a0) ;Empfaenger sperren

                  move.b   #XOFF,aux_x_buf(a0) ;und XOFF senden
sccint2_rdstate:
                  move.b   #0,(a2)
                  move.b   (a2),d0        ;Sende- und Empfangsstatus lesen
                  btst     #2,d0          ;1: Senderegister muá "nachgeladen" werden
                  beq.b    exit_sccint2

                  move.b   aux_x_buf(a0),d0 ;<> 0, wenn XON/XOFF
                  beq.b    SL00FD

                  clr.b    aux_x_buf(a0)
                  bra.b    SL00FF

SL00FD:           tst.b    aux_lock_tmt(a0)
                  bne.b    exit_sccint2   ;Sender gesperrt->raus

                  lea      $0e(a0),a0

                  moveq    #0,d1
                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
                  cmp.w    ibuftl(a0),d1
                  beq.b    exit_sccint2   ;kein Zeichen im Buffer -> raus

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _SL00FE
                  moveq    #0,d1          ;Auf den Anfang setzen
_SL00FE:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren
SL00FF:
                  move.b   d0,_scc_dat(a2) ;Byte in Sendedatenregister schreiben
exit_sccint2:
                  move.b   #0,(a2)
                  move.b   #ResetHighIUS,(a2)
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte
;
; SCC Int 2/3 mit RTS/CTS-Handshake
sccint2_RTS:
                  move.b   _scc_dat(a2),d0 ;Byte aus Empfangspuffer holen
                  and.b    bitchr(a0),d0  ;Bits pro Zeichen

                  moveq    #0,d1
                  move.w   ibuftl(a0),d1

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _RTL00D6
                  moveq    #0,d1          ;Auf den Anfang setzen
_RTL00D6:
                  cmp.w    ibufhd(a0),d1
                  beq.b    exit_sccint2RTS ;raus

                  movea.l  (a0),a1        ;ibuf
                  move.b   d0,0(a1,d1.l)  ;Zeichen eintragen
                  move.w   d1,ibuftl(a0)  ;Tail korrigieren

                  tst.b    aux_lock_rcv(a0)
                  bne.b    exit_sccint2RTS   ;Empfaenger bereits inaktiv

                  move.w   ibuftl(a0),d0  ;Tail
                  sub.w    ibufhd(a0),d0  ;Head
                  bpl.b    RTL00F6
                  add.w    ibufsiz(a0),d0
RTL00F6:
                  cmp.w    ibufhi(a0),d0  ;obere "Wassermarke"
                  blt.b    exit_sccint2RTS

                  st       aux_lock_rcv(a0) ;Empfaenger sperren

                  move.b   aux_status_tmt(a0),d0
                  bclr     #1,d0          ;RTS auf High
                  move.b   d0,aux_status_tmt(a0)
                  move.b   #5,(a2)        ;Sendersteuerung
                  move.b   d0,(a2)

exit_sccint2RTS:  move.b   #0,(a2)
                  move.b   #ResetHighIUS,(a2)
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte

;
; SCC Int 2/3 - kein Handshake
sccint2_noHS:
                  move.b   _scc_dat(a2),d0 ;Byte aus Empfangspuffer holen
                  and.b    bitchr(a0),d0  ;Bits pro Zeichen

                  moveq    #0,d1
                  move.w   ibuftl(a0),d1

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _NHSL00D6
                  moveq    #0,d1          ;Auf den Anfang setzen
_NHSL00D6:
                  cmp.w    ibufhd(a0),d1
                  beq.b    exit_sccint2NHS ;raus

                  movea.l  (a0),a1        ;ibuf
                  move.b   d0,0(a1,d1.l)  ;Zeichen eintragen
                  move.w   d1,ibuftl(a0)  ;Tail korrigieren

exit_sccint2NHS:  move.b   #0,(a2)
                  move.b   #ResetHighIUS,(a2)
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; a0: *Buffer
; a2: *SCC Control-Register
Ringbuf2SCC:      move.l   a0,-(sp)
                  move.b   aux_handshake(a0),d0
                  cmp.b    #1,d0
                  bhi.b    r2scc_RTS
                  bcs      r2scc_noHS

                  tst.b    aux_x_buf(a0)  ;<> 0, wenn XON/XOFF
                  bne.b    L00FD
                  tst.b    aux_lock_tmt(a0)
                  bne.b    ring2scc_exit  ;Sender gesperrt -> raus
L00FD:
                  move.b   #0,(a2)        ;Register 0 auslesen
                  move.b   (a2),d0        ;Status der Sende- und Empfangsbuffer
                  btst     #2,d0          ;1: Senderegister muá "nachgeladen" werden
                  beq.b    ring2scc_exit
                  move.b   aux_x_buf(a0),d0
                  beq.b    L00FE
                  clr.b    aux_x_buf(a0)
                  bra.b    L00FF
L00FE:
                  lea      $0e(a0),a0     ;Ausgabe-Iorec

                  moveq    #0,d0
                  moveq    #0,d1
                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
                  cmp.w    ibuftl(a0),d1
                  beq.b    ring2scc_exit  ;kein Zeichen im Buffer -> raus

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _L00FE
                  moveq    #0,d1          ;Auf den Anfang setzen
_L00FE:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren
L00FF:
                  move.b   d0,_scc_dat(a2) ;Sendedatenregister beschreiben
ring2scc_exit:
                  movea.l  (sp)+,a0
                  rts

r2scc_RTS:
                  move.b   #0,(a2)        ;Register 0 auslesen
                  move.b   (a2),d0        ;Status der Sende und Empfangsbuffer
                  btst     #5,d0          ;Zustand des CTS-Anschlusses (0=High, 1=Low)
                  beq.b    exit_r2scc_RTS ;High

                  btst     #2,d0          ;1: Senderegister muá "nachgeladen" werden
                  beq.b    exit_r2scc_RTS

                  lea      $0e(a0),a0     ;Ausgabe-Iorec

                  moveq    #0,d0
                  moveq    #0,d1
                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
                  cmp.w    ibuftl(a0),d1
                  beq.b    ring2scc_exit  ;kein Zeichen im Buffer -> raus

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _RTL00FE
                  moveq    #0,d1          ;Auf den Anfang setzen
_RTL00FE:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren

                  move.b   d0,_scc_dat(a2) ;Sendedatenregister beschreiben
exit_r2scc_RTS:
                  movea.l  (sp)+,a0
                  rts


r2scc_noHS:
                  move.b   #0,(a2)        ;Register 0 auslesen
                  move.b   (a2),d0        ;Status der Sende- und Empfangsbuffer
                  btst     #2,d0          ;1: Senderegister muá "nachgeladen" werden
                  beq.b    exit_r2scc_noHS

;                  move.b   aux_x_buf(a0),d0
;                  beq.b    NHL00FE
;                  clr.b    aux_x_buf(a0)
;                  bra.b    NHL00FF
NHL00FE:
                  lea      $0e(a0),a0     ;Ausgabe-Iorec

                  moveq    #0,d0
                  moveq    #0,d1
                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
                  cmp.w    ibuftl(a0),d1
                  beq.b    exit_r2scc_noHS ;kein Zeichen im Buffer -> raus

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _NHL00FE
                  moveq    #0,d1          ;Auf den Anfang setzen
_NHL00FE:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren
NHL00FF:
                  move.b   d0,_scc_dat(a2) ;Sendedatenregister beschreiben
exit_r2scc_noHS:
                  movea.l  (sp)+,a0
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SCC Kanal A
; in $1a0 eingetragen
scca_int0:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_a.w,a2
                  move.l   p_iorec_scca,a0
                  bra.b    scc_int0
;
; SCC Kanal B
; Sendepuffer leer
; in $180 eingetragen
sccb_int0:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_b.w,a2
                  move.l   p_iorec_sccb,a0
;
; SCC Sendepuffer leer
;
; a2: SCC-Control-Register
; a0: *IOREC
scc_int0:         move.b   #0,(a2)        ;Register 0 beschreiben
                  move.b   #ResetTxINTPending,(a2)
                  move.b   #0,(a2)
                  move.b   #ResetHighIUS,(a2)
                  bsr      Ringbuf2SCC
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SCC Kanal A
; in $1a8 eingetragen
scca_int1:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_a.w,a2
                  move.l   p_iorec_scca,a0
                  bra.b    scc_int1
;
; SCC B
; in $188 eingetragen
sccb_int1:        movem.l  d0-d1/a0-a2,-(sp)
                  lea      sccctl_b.w,a2
                  move.l   p_iorec_sccb,a0
;
; Externer/Status Interrupt
;
; a2: SCC-Control-Register
; a0: *IOREC
scc_int1:         btst     #1,aux_handshake(a0)
                  beq.b    exit_sccint1   ;kein RTS/CTS-Handshake
                  move.b   #0,(a2)
                  move.b   (a2),d0        ;Status der Sende- und Empfangspuffer auslesen
                  btst     #5,d0          ;Zustand des CTS-Anschlusses (0=High, 1=Low)
                  seq      aux_lock_tmt(a0) ;Flag setzen ($ff), wenn CTS= High
                  beq.b    exit_sccint1   ;CTS=High -> exit

                  btst     #2,d0          ;1: Senderegister muá "nachgeladen" werden
                  beq.b    exit_sccint1

                  lea      $0e(a0),a0     ;Ausgabe-Iorec

                  moveq    #0,d1
                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
                  cmp.w    ibuftl(a0),d1
                  beq.b    exit_sccint1   ;kein Zeichen im Buffer -> raus

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _scc_int1
                  moveq    #0,d1          ;Auf den Anfang setzen
_scc_int1:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren

                  move.b   d0,_scc_dat(a2) ;Sendedatenregister beschreiben
exit_sccint1:
                  move.b   #0,(a2)
                  move.b   #ResetExtStatIntr,(a2)
                  move.b   #0,(a2)
                  move.b   #ResetHighIUS,(a2)
                  movem.l  (sp)+,d0-d1/a0-a2
                  rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  'Bios Ger',$84,'te-Vektoren'

Bconstat_scca:
                  move.l   p_iorec_scca,a0
                  bra.b    _bconstatS
Bconstat_sccb:
                  move.l   p_iorec_sccb,a0
_bconstatS:
                  moveq    #-1,d0
                  move.w   ibufhd(a0),d1
                  cmp.w    ibuftl(a0),d1
                  sne      d0
                  ext.w    d0
                  ext.l    d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bcostat_scca:
                  move.l   p_iorec_scca,a0
                  bra.b    _bcostat_auxS
Bcostat_sccb:
                  move.l   p_iorec_sccb,a0
_bcostat_auxS:
                  move.w   ibufhd(a0),d1
                  sub.w    ibuftl(a0),d1
                  bhi.b    _bcost_aux
                  add.w    ibufsiz(a0),d1
_bcost_aux:
                  subq.w   #3,d1
                  scc      d0
                  ext.w    d0
                  ext.l    d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bconin_scca:
                  move.l   p_iorec_scca,a0
                  lea      sccctl_a.w,a2
                  bra.b    _bconin_auxS

Bconin_sccb:
                  move.l   p_iorec_sccb,a0
                  lea      sccctl_b.w,a2

_bconin_auxS:
                  moveq    #0,d0
                  moveq    #0,d1

                  move.w   ibufhd(a0),d1  ;Head und Tail vergleichen
_bconin_auxtl:
                  cmp.w    ibuftl(a0),d1
                  beq.b    _bconin_auxtl  ;warten bis Zeichen im Buffer

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _bconin_auxsize
                  moveq    #0,d1          ;Auf den Anfang setzen
_bconin_auxsize:
                  movea.l  (a0),a1        ;ibuf: Zeiger auf den Puffer
                  move.b   0(a1,d1.l),d0  ;Zeichen holen
                  move.w   d1,ibufhd(a0)  ;Head korrigieren

                  tst.b    aux_handshake(a0)
                  beq.b    exit_bconin_aux ;kein Handshake

                  tst.b    aux_lock_rcv(a0)
                  beq.b    exit_bconin_aux   ;Empfaenger bereit

                  move.w   ibuftl(a0),d1
                  sub.w    ibufhd(a0),d1
                  bcc.b    _bconin_auxhd
                  add.w    ibufsiz(a0),d1
_bconin_auxhd:
                  cmp.w    ibuflow(a0),d1
                  bhi.b    exit_bconin_aux

                  clr.b    aux_lock_rcv(a0)  ;Empfaenger freigeben
                  btst     #0,aux_handshake(a0)
                  bne.b    _bconin_auxXON ;XON/XOFF-Handshake

                  move.b   aux_status_tmt(a0),d1
                  bset     #1,d1          ;RTS auf LOW setzen!
                  move.b   d1,aux_status_tmt(a0)
                  move.b   #5,(a2)        ;Sendersteuerung
                  move.b   d1,(a2)        ;RTS, DTR, etc. setzen
exit_bconin_aux:
                  rts

_bconin_auxXON:
                  move.b   #XON,aux_x_buf(a0)
                  move.w   d0,-(sp)
                  bsr.b    _out_aux
                  move.w   (sp)+,d0
                  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bconout_scca:
                  lea   6(sp),a0
                  move.w   (a0),d0
                  move.l   p_iorec_scca,a0
                  lea      sccctl_a.w,a2
                  bra.b    _bcnout_aux_entry

Bconout_sccb:
                  lea   6(sp),a0
                  move.w   (a0),d0
                  move.l   p_iorec_sccb,a0
                  lea      sccctl_b.w,a2

_bcnout_aux_entry:
                  lea      $0e(a0),a0     ;IOREC fuer Ausgabe

                  moveq    #0,d1
                  move.w   ibuftl(a0),d1

                  addq.w   #1,d1          ;Position des naechsten Zeichens
                  cmp.w    ibufsiz(a0),d1 ; Laenge des Puffers
                  bcs.b    _bconout_auxsize
                  moveq    #0,d1          ;Auf den Anfang setzen
_bconout_auxsize:
                  cmp.w    ibufhd(a0),d1
                  beq.b    _bconout_auxsize ;Puffer voll -> warten

                  movea.l  (a0),a1        ;ibuf
                  move.b   d0,0(a1,d1.l)  ;Zeichen eintragen
                  move.w   d1,ibuftl(a0)  ;Tail korrigieren

                  suba.w   #$0e,a0        ;IOREC fuer Eingabe

_out_aux:         move.b   #0,(a2)        ;Sende- und Empfangstatus einlesen
                  move.b   (a2),d0
                  btst     #2,d0
                  beq.b    exit_bconout_aux ;1: Senderegister muá "nachgeladen" werden (Sendepuffer nicht leer)
                  move     sr,-(sp)
                  ori      #$0700,sr
                  bsr      Ringbuf2SCC
                  move     (sp)+,sr
exit_bconout_aux:
                  rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 Rsconf fuer SCC
handleHandshake:  clr.b    aux_lock_rcv(a0)  ;Empfaenger freigeben
                  btst     #0,aux_handshake(a0)
                  beq.b    L010C          ;RTS/CTS-Handshake
                  move.b   #XON,aux_x_buf(a0)
                  bra.b    _out_aux

L010C:            move.b   aux_status_tmt(a0),d0
                  bset     #1,d0          ;RTS auf LOW setzen!
                  move.b   d0,aux_status_tmt(a0)
                  move.b   #5,(a2)        ;Sendersteuerung
                  move.b   d0,(a2)        ;RTS, DTR, etc. setzen
                  rts

Rsconf_scca:      move.l   p_iorec_scca,a0
                  lea      sccctl_a.w,a2
                  bra.b    _rsconf_scc

Rsconf_sccb:      move.l   p_iorec_sccb,a0
                  lea      sccctl_b.w,a2
;
; 4(sp): speed
; 6(sp): flowctl
; 8(sp): ucr
;$a(sp): rsr
;$c(sp): tsr
;$e(sp): scr
;
; a0: *IOREC
; a2: SCC Control-Register
_rsconf_scc:
                  moveq    #0,d0
                  cmpi.w   #-2,4(sp)      ;speed erfragen?
                  bne.b    L0111
                  move.b   baudrate(a0),d0
                  rts

L0111:            ori      #$0700,sr
                  moveq    #0,d7
                  move.b   aux_status_rcv(a0),d7
                  asl.w    #8,d7
                  swap     d7
                  move.b   aux_status_tmt(a0),d7
                  lsr.b    #1,d7
                  and.b    #4,d7
                  asl.w    #8,d7
                  move.w   6(sp),d0       ;flowctl
                  cmp.w    #3,d0
                  bhi.b    L0115
                  bne.b    L0112
                  moveq    #1,d0          ;Modus 3 (RTS/CTS + XON/XOFF) in 1 (XON/XOFF) umsetzen
L0112:
                  cmp.b    aux_handshake(a0),d0
                  beq.b    L0115
                  tst.b    aux_lock_tmt(a0)
                  beq.b    L0113          ;Sender freigegeben
                  clr.b    aux_lock_tmt(a0)
                  bsr      Ringbuf2SCC
L0113:
                  tst.b    aux_lock_rcv(a0)
                  beq.b    L0114          ;Empfaenger freigegeben
                  move.w   d0,-(sp)
                  bsr      handleHandshake
                  move.w   (sp)+,d0
L0114:
                  move.b   d0,aux_handshake(a0)
L0115:
                  move.w   4(sp),d0       ;speed
                  cmp.w    #$0f,d0
                  bhi.b    L0116
                  move.b   d0,baudrate(a0)
                  asl.w    #1,d0
                  lea      bauddata_scc(pc),a1
                  move.w   0(a1,d0.w),d0
                  move.b   #$0c,(a2)      ;enthaelt Lowbyte des Baudratentimers
                  move.b   d0,(a2)
                  lsr.w    #8,d0
                  move.b   #$0d,(a2)      ;enthaelt Hibyte des Baudratentimers
                  move.b   d0,(a2)
L0116:
                  move.w   8(sp),d0       ;ucr
                  bmi.b    L011B          ;nicht zulaessig
                  move.b   d0,aux_status_rcv(a0)
                  move.b   d0,d1
                  and.b    #$60,d1        ;Wortlaenge (Bit [6..5]) ausmaskieren
                  lsr.b    #5,d1          ;[00]: 8, [01]:7, [10]:6, [11]:5
                  moveq    #-1,d2         ;Maske fuer Bits pro Zeichen generieren
                  lsr.b    d1,d2
                  move.b   d2,bitchr(a0)

                  move.b   d0,d1
                  and.b    #$60,d1        ;Wortlaenge ausmaskieren
                  beq.b    L0117          ;8 Bit/Zeichen?
                  cmp.b    #$60,d1        ;5 Bit/Zeichen?
                  bne.b    L0118          ;6 und 7 Bit-Kombination darf nicht gedreht werden
L0117:
                  eori.b   #$60,d1        ;Bits drehen, da SCC anderer Kombination arbeitet
L0118:                                    ;[00]:5, [01]:7, [10]:6, [11]:8
                  move.b   aux_status_tmt(a0),d2
                  and.b    #$9f,d2        ;Bits [6..5] neu setzen
                  or.b     d1,d2
                  move.b   d2,aux_status_tmt(a0)
                  move.b   #5,(a2)        ;Sendersteuerung
                  move.b   d2,(a2)

                  asl.b    #1,d1          ;Der Empfaenger moechte die Daten um ein Bit verschoben haben...
                  or.b     #1,d1          ;1: Empfaenger eingeschaltet, 0: Empf. aus
                  move.b   #3,(a2)        ;Empfaengersteuerung
                  move.b   d1,(a2)

                  move.b   d0,d1          ;ucr
                  and.b    #$1e,d1        ;Bit [4..1] auswerten
                  lsr.b    #1,d1          ;alles ins Low-Nibble verschieben
                  bclr     #1,d1          ;Parity?
                  sne      d2             ;ja
                  bclr     #0,d1          ;odd (0) or even (1) parity
                  bne.b    L0119          ;even
                  bclr     #1,d2          ;odd parity
                  bra.b    L011A
L0119:
                  bset     #1,d2          ;even parity
L011A:
                  and.b    #3,d2          ;[00]: ohne Parity, [01]: odd, [11]: even
                  or.b     d2,d1          ;Bit[3..2]->Stopbits; [01]:1, [10]:1.5, [11]:2, [00]: Synchronbetrieb ein!!
                  or.b     #$40,d1        ;Takt= 1*Datenrate
                  move.b   #4,(a2)        ;Moduseinstellungen fuer Sender/Empfaenger
                  move.b   d1,(a2)
L011B:
                  move.w   12(sp),d0      ;tsr
                  bmi.b    L011D
                  btst     #3,d0          ;Bit 3: Break (1)
                  beq.b    L011C
                  bset     #4,aux_status_tmt(a0) ;Break setzen
                  bne.b    L011D
                  move.b   #5,(a2)        ;Sendersteuerung
                  move.b   aux_status_tmt(a0),(a2)
                  bra.b    L011D

L011C:
                  bclr     #4,aux_status_tmt(a0) ;Break loeschen
                  beq.b    L011D
                  move.b   #5,(a2)
                  move.b   aux_status_tmt(a0),(a2)
L011D:
                  move.l   d7,d0
                  rts
bauddata_scc:
                  DC.W $0b
                  DC.W $18
                  DC.W $32
                  DC.W $44
                  DC.W $67
                  DC.W $7c
                  DC.W $8a
                  DC.W $d0
                  DC.W $01a1
                  DC.W $0345
                  DC.W $04e8
                  DC.W $068c
                  DC.W $074d
                  DC.W $08ee
                  DC.W $0d1a
                  DC.W $13a8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
autointr_scc:
                  DC.L sccb_int0,0
                  DC.L sccb_int1,0
                  DC.L sccb_int2,0
                  DC.L sccb_int3,0
                  DC.L scca_int0,0
                  DC.L scca_int1,0
                  DC.L scca_int2,0
                  DC.L scca_int3,0

