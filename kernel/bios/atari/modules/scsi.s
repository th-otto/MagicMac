*********************************************************************
*************************** SCSI ************************************
*********************************************************************

* Interruptsteuerung:
*
* SCSI-DMA-Busfehler: Eingang I5 des TT-MFP
* 1. aer fuer Bit 5 muss 0 sein, d.h. Interrupt wird ausgeloest beim
*    Uebergang von 1 auf 0
* Polling ueber Bit 5 von gpip
* Interrupt #7 des TT-MFP (Adresse $15c)

* SCSI: Eingang I7 des TT-MFP
* 1. aer fuer Bit 7 muss 1 sein, d.h. Interrupt wird ausgeloest beim
*    Uebergang von 0 auf 1
* Polling ueber Bit 7 von gpip
* Interrupt #15 des TT-MFP (Adresse $17c)

* Waehrend der Uebertragung muss offenbar im Betriebsartenregister
* $fff785 des ncr 5380 das Bit 3 (enable process interrupt)
* gesetzt sein.


**********************************************************************
*
* Interruptroutine fuer TT-MFP, Interruptkanal #7 = I/O-Port 5
* (SCSI-DMA Busfehler)
*
* Rueckgabewert -2
*

int_scsidma:
 tst.l    ncrdma_unsel                  ; Interrupt aktiviert ?
 beq.b    incrdma_ende                  ; nein, weiter
 movem.l  d0-d2/a0-a2,-(sp)

 moveq    #-2,d0                        ; eingetroffen (Fehler)
 move.l   ncrdma_unsel,a0
 clr.l    ncrdma_unsel                  ; Interrupt deaktivieren
 move.l   d0,(a0)                       ; als eingetroffen markieren

 move.l   ncrdma_appl,a0
 jsr      appl_IOcomplete               ; wartende APP aufwecken
 movem.l  (sp)+,d0-d2/a0-a2
incrdma_ende:
 move.b   #$7f,isrb+$80                 ; service- Bit loeschen (TT-MFP)
 rte


**********************************************************************
*
* Interruptroutine fuer TT-MFP, Interruptkanal #15 = I/O-Port 7
* (SCSI)
*
* Rueckgabewert 0
*

int_ncr:
 tst.l    ncrdma_unsel                  ; Interrupt aktiviert ?
 beq.b    incr_ende                     ; nein, weiter
 movem.l  d0-d2/a0-a2,-(sp)

 move.l   ncrdma_unsel,a0
 clr.l    ncrdma_unsel                  ; Interrupt deaktivieren
 clr.l    (a0)                          ; als eingetroffen markieren

 move.l   ncrdma_appl,a0
 jsr      appl_IOcomplete               ; wartende APP aufwecken
 movem.l  (sp)+,d0-d2/a0-a2
incr_ende:
 move.b   #$7f,isra+$80                 ; service- Bit loeschen (TT-MFP)
 rte


**********************************************************************
*
* void incrdma_unsel( a0 = long *unselect, a1 = APPL *ap );
*
* Deaktiviert den Interrupt wieder, wenn er nicht eingetroffen ist.
* (Rueckgabewert -1)
*

incrdma_unsel:
 clr.l    ncrdma_unsel                  ; Interrupt deaktivieren
 moveq    #-1,d0                        ; Timeout
 move.l   d0,(a0)                       ; nicht eingetroffen
 rts


**********************************************************************
*
* long wait_NCR( d0 = long ticks_200hz )
*
* RUeckgabe:    0    OK
*             -2    Busfehler
*             -1    TimeOut
*
* kein Register ausser d0 wird veraendert
*

wait_NCR:
 move.l   hddrv_tab+hd_ncrwait,-(sp)
 rts
_wait_NCR:
 movem.l  d1-d2/a0-a2,-(sp)
 tst.w    pe_slice            ; praeemptiv ?
 bmi.b    wncr_no_yield       ; nein, busy waiting
 move.l   act_appl,d2
 ble.b    wncr_no_yield       ; aktuelle Applikation ungueltig

* neue Routine ueber evnt_IO und MFP- Interrupt

 lsr.l    #2,d0               ; AES: 50Hz statt 200Hz
wncr_neu:
 move     sr,d1
 ori      #$700,sr
 btst     #5,gpip+$80         ; DMA- Busfehler ?
 beq.b    wncr_err2           ; ja, return(-2)
 btst     #7,gpip+$80         ; schon fertig ?
 bne.b    wncr_ok2            ; ja, enable interrupt, return(0)
; Interrupt aufsetzen
 pea      incrdma_unsel(pc)
 move.l   d2,ncrdma_appl      ; act_appl
 move.l   sp,ncrdma_unsel
; Interrupt freigeben
 move.w   d1,sr
; Auf Interrupt warten
 move.l   sp,a0
;move.w   d0,d0               ; TimeOut in 50Hz- Ticks
 jsr      evnt_IO
 addq.l   #4,sp
wncr_ende:
 movem.l  (sp)+,d1-d2/a0-a2
 rts

* alte Routine mit busy waiting ueber _hz_200

wncr_no_yield:
 add.l    _hz_200,d0
wncr_loop:
 btst     #5,gpip+$80
 beq.b    wncr_err
 btst     #7,gpip+$80
 bne.b    wncr_ok
 cmp.l    _hz_200,d0
 bcc.b    wncr_loop
 moveq    #-1,d0                   ; Timeout
 bra.b    wncr_ende
wncr_ok2:
 move.w   d1,sr
wncr_ok:
 moveq    #0,d0
 bra.b    wncr_ende
wncr_err2:
 move.w   d1,sr
wncr_err:
 moveq    #-2,d0
 bra.b    wncr_ende


**********************************************************************
*
* Sperre den NCR-SCSI
*
* kein Register ausser d0 wird veraendert
*
* und gib ihn wieder frei.
*
* Kein Register wird veraendert
*
* Fuer die Zeit, in der AES noch nicht initialisiert ist, kann evnt_sem
* nicht sperren, weil act_appl immer NULL ist.
*

ncr_begin:
 move.l   hddrv_tab+hd_ncrbegin,-(sp)
 rts
_ncr_begin:
 movem.l  d1-d2/a0-a2,-(sp)
 lea      ncr_sem,a0
 moveq    #0,d1               ; kein Timeout
 moveq    #SEM_SET,d0
 jsr      evnt_sem
 movem.l  (sp)+,d1-d2/a0-a2
 rts

ncr_end:
 move.l   hddrv_tab+hd_ncrend,-(sp)
 rts
_ncr_end:
 movem.l  d0-d2/a0-a2,-(sp)
 lea      ncr_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
 movem.l  (sp)+,d0-d2/a0-a2
 rts


**********************************************************************
*
* long dmarw_scsi(d0 = int wrflag, ... )
*

dmarw_scsi:
 cmpi.w   #$10,$e(sp)                   ;Target >= 16?
 bhs      dmarw_ide                ;dann IDE ansprechen
 
 cmpi.b   #4,machine_type          ;Falcon?
 beq      dmarw_fscsi                   ;dann Falcon-SCSI-Code
  
 move.b   d0,-(sp)
 bsr.b    ncr_begin
 moveq    #8,d1
 move.b   (sp)+,_scsi_wrflag
 beq.b    ncr_rd              ; Lesen
 moveq    #$a,d1
ncr_rd:
 lea      _scsi_cmdbuf,a0
 move.b   d1,(a0)+            ; dmacbuf[0] = 8 (lesen) 10 (schreiben)
 move.b   5(sp),(a0)+         ; dmacbuf[1] = secno.upmid
 move.b   6(sp),(a0)+         ; dmacbuf[2] = secno.lomid
 move.b   7(sp),(a0)+         ; dmacbuf[3] = secno.lo
 move.b   9(sp),(a0)+         ; dmacbuf[4] = count.lo
 clr.b    (a0)                ; dmacbuf[5] = 0
 move.w   $e(sp),d0           ; d0 = target
 moveq    #0,d1
 move.w   8(sp),d1            ; d1 = count
 lsl.l    #8,d1
 add.l    d1,d1               ; d1 = count << 9 (Sektoren in Bytes umrechnen)
 moveq    #6,d2               ; d2 = 6
 movea.l  $a(sp),a0           ; a0 = buf
 tst.b    _scsi_wrflag
 bne.b    dmarw_l1
* lesen
 bsr      _dmaread_scsi
 bra      ttdmarw_ende
* schreiben
dmarw_l1:
 bsr      _dmawrite_scsi

ttdmarw_ende:
 bsr      cache_invalid       ; Veraendert KEINE Register!
 tst.w    d0                  ; Rueckgabecode ist OK oder Fehler ?
 ble.b    dmarw_l2           ; ja, Code weiterreichen
* es ist ein Fehlercode > 0 aufgetreten
 moveq    #EREADF,d0
 tst.b    _scsi_wrflag        ; wollte lesen
 beq.b    dmarw_l2           ; ja
 moveq    #EWRITF,d0
dmarw_l2:
 bra      ncr_end


_dmaread_scsi:
 move.l   a0,-(sp)            ; buf
 andi.w   #7,d0               ; dev von 8..15 auf 0..7
 bsr.b    scsi_cmd            ; Kommando dmacbuf[] schreiben
 movea.l  (sp)+,a0            ; buf zurueck
 tst.w    d0                  ; Fehler ?
 bmi.b    dmarw_end           ; ja, Code zurueckgeben
 movea.l  a0,a1               ; a1 = buf
 movea.w  #$8781,a2           ; a2 = &scsi_data_register
 move.b   #1,$ffff8787        ; target command register
 move.b   $ffff878f,d0        ; SCSI dma initiator receive
dmarw_l3:
 bsr      vbl_165ms
 bsr      scsi_wait_ready
 bmi.b    dmarw_end           ; Timeout
 btst     #3,$a(a2)           ; SCSI dma status
 beq      scsi_dmarw_ende
 move.b   (a2),(a1)+          ; ohne DMA von Hand lesen !
 bsr      scsi_wait_busy
 bra.b    dmarw_l3
dmarw_end:
 rts

_dmawrite_scsi:
 andi.w   #7,d0
 move.l   a0,-(sp)
 move.w   d2,-(sp)
 bsr.b    scsi_cmd
 move.w   (sp)+,d2
 movea.l  (sp)+,a0
 tst.w    d0
 bmi.b    dmarw_l5
 movea.l  a0,a1
 movea.w  #$8781,a2
 move.b   #0,$ffff8787
 move.b   $ffff878f,d0
dmarw_l4:
 bsr      vbl_165ms
 bsr      scsi_wait_ready
 bmi.b    dmarw_l5
 btst     #3,$a(a2)
 beq      scsi_dmarw_ende
 move.b   (a1)+,(a2)
 bsr      scsi_wait_busy
 bra.b    dmarw_l4
dmarw_l5:
 rts


*********************************************************************
*
* long scsi_cmd( d0 = int target, d2 = int len )
*
* Schreibt dmacbuf[] als Kommando
*
scsi_cmd:
 move.l   d2,-(sp)            ; ist 6
 bsr      get_initiator_id_bit     ; UWE
 move.w   d1,-(sp)                 ; UWE: Bit fuer Initiator-ID
 move.w   d0,-(sp)            ; Target
 bsr.b    scsi_begin
 addq.w   #4,sp
 move.l   (sp)+,d2
 tst.w    d0                  ; ok ?
 bmi.b    scsicmd_end           ; Fehler, Fehlercode weiterreichen
 move.b   #2,$ffff8787        ; Target command register
 move.b   #1,$ffff8783        ; initiator command register
 lea      _scsi_cmdbuf,a1     ; Zu uebertragende Kommandos
 subq.w   #1,d2               ; wegen dbf
 bsr      vbl_165ms
scsicmd_loop:
 move.b   (a1)+,d0            ; Byte holen
 bsr      scsi_byte           ; und ausgeben
 tst.w    d0                  ; ok ?
 bmi.b    scsicmd_end           ; Fehler
 dbf      d2,scsicmd_loop        ; naechstes Byte
 moveq    #0,d0               ; kein Fehler
scsicmd_end:
 rts


*********************************************************************
*
* int scsi_begin( int target, int initiatorID )
*
* Beginnt die Unterhaltung mit dem Target, Rueckgabe -1 bei Timeout
* wird nur von scsi_cmd aufgerufen
*

scsi_begin:
 bsr      vbl_165ms           ; d1 = vbl-Zaehler + 165ms, a0 = &_hz_200
scsibeg_loop1:
 btst     #6,$ffff8789        ; SCSI control register
 beq.b    scsibeg_l1           ; in Ordnung
 cmp.l    (a0),d1             ; 165 ms Timeout
 bhi.b    scsibeg_loop1
 bra.b    scsibeg_l2           ; Timout-Fehler, return(-1)
scsibeg_l1:
 move.b   #0,$ffff8787        ; Target command register
 move.b   #0,$ffff8789        ; ID select
 move.b   #$c,$ffff8783       ; Initiator command register = 12
 clr.w    d0
 move.w   4(sp),d1            ; Target
 bset     d1,d0               ; in Bitnummer umrechnen
 or.w     6(sp),d0            ; Initiator-ID einblenden (UWE)
 move.b   d0,$ffff8781        ; ins scsi data register
 move.b   #$d,$ffff8783       ; mode register
 andi.b   #$fe,$ffff8785      ; target command register
 andi.b   #$f7,$ffff8783      ; mode register
 bsr      vbl_165ms
scsibeg_loop2:
 btst     #6,$ffff8789        ; SCSI control register
 bne.b    scsibeg_l3           ; ok
 cmp.l    (a0),d1             ; Timeout ?
 bhi.b    scsibeg_loop2           ; nein
scsibeg_l2:
 moveq    #-1,d0              ; Timeout
 bra.b    scsibeg_end
scsibeg_l3:
 clr.w    d0                  ; kein Fehler
scsibeg_end:
 move.b   #0,$ffff8783        ; initiator command register loeschen
 rts


scsi_dmarw_ende:
 bsr      vbl_165ms
 move.b   #3,$ffff8787        ; Target command register
 move.b   $ffff878f,d0        ; DMA initiator receive
 bsr.b    scsi_wait_ready
 bmi.b    scsidmarwe_end           ; Timeout
 moveq    #0,d0
 move.b   $ffff8781,d0        ; SCSI data register enthaelt Fehlercode
 bsr      vbl_165ms
 move.l   d0,-(sp)            ; Wert retten
 bsr.b    scsi_wait_busy
 tst.w    d0                  ; ok ?
 beq.b    scsidmarwe_l1       ; ja
scsidmarwe_loop:
 addq.l   #4,sp               ; Timeout: -1 zurueckgeben
 bra.b    scsidmarwe_end
scsidmarwe_l1:
 bsr.b    vbl_165ms
 bsr.b    scsi_wait_ready
 bmi.b    scsidmarwe_loop           ; Timeout
 move.b   $ffff8781,d0        ; SCSI data register
 bsr.b    scsi_wait_busy
 tst.w    d0
 bmi.b    scsidmarwe_loop           ; Timeout
 move.l   (sp)+,d0            ; OK, RUeckgabewert nach d0
scsidmarwe_end:
 rts


*********************************************************************
*
* int scsi_wait_ready( d1 = long timeout_ticks, a0 = long *timer )
*
* a0 == &_hz_200
* wartet, bis SCSI bereit ist oder Timeout
*

scsi_wait_ready:
scsiwaitrdy_loop:
 btst     #5,$ffff8789        ; SCSI control register
 bne.b    scsiwaitrdy_l2           ; ok
 cmp.l    (a0),d1             ; Zeit abgelaufen ?
 bhi.b    scsiwaitrdy_loop           ; nein
 moveq    #-1,d0              ; Timeout
 bra.b    scsiwaitrdy_l1
scsiwaitrdy_l2:
 moveq    #0,d0
scsiwaitrdy_l1:
 rts


*********************************************************************
*
* int scsi_wait_busy( d1 = long timeout_ticks, a0 = long *timer )
*
* a0 == &_hz_200
* wartet, bis SCSI beschaeftigt ist oder Timeout
*

scsi_wait_busy:
 ori.b    #$11,$ffff8783      ; initiator command register
scsiwaitbsy_loop:
 btst     #5,$ffff8789        ; SCSI bereit
 beq.b    scsiwaitbsy_l1      ; nein, return(0)
 cmp.l    (a0),d1             ; Timeout erreicht?
 bhi.b    scsiwaitbsy_loop    ; nein
 moveq    #-1,d0              ; Timeout
 bra.b    scsiwaitbsy_end
scsiwaitbsy_l1:
 moveq    #0,d0
scsiwaitbsy_end:
 andi.b   #$ef,$ffff8783      ; initiator command register
 rts


*********************************************************************
*
* int scsi_byte( d0 = char b )
*
* Verarbeitet ein Kommandobyte, RUeckgabe negativ bei Fehler
*

scsi_byte:
 move.w   d0,-(sp)            ; Byte retten
 bsr.b    scsi_wait_ready     ; warte bis Timeout oder SCSI ready
 bmi.b    scsibt_end           ; Timeout
 move.b   1(sp),$ffff8781     ; Byte nach scsi data register
 bsr.b    scsi_wait_busy
scsibt_end:
 addq.l   #2,sp
 rts


*********************************************************************
*
* Schreibt $80,$00 ins SCSI icr
*

scsi_init:
 move.b   #$80,$ffff8783      ; $80 -> SCSI initiator command register
 bsr.b    vbl_165ms
scsiinit_loop:
 cmp.l    (a0),d1
 bhi.b    scsiinit_loop
 move.b   #0,$ffff8783        ; $00 -> SCSI initiator command register
 bsr.b    vbl_1s
scsiinit_loop2:
 cmp.l    (a0),d1
 bhi.b    scsiinit_loop2
 rts

vbl_165ms:
 movea.w  #$4ba,a0
 moveq    #$33,d1             ; 0.165s
 add.l    (a0),d1
 rts

vbl_1s:
 movea.w  #$4ba,a0
 move.l   #$c9,d1             ; 1s
 add.l    (a0),d1
 rts

;-------------------------------------------------------
;Falcon SCSI-Routinen
;
;Es fehlt:
;- Kapselung mit ACSI-Semaphore (in Bootphase unkritisch)
;-------------------------------------------------------
;
;FSCI-DMAread/DMAwrite   (d0 = int rw_flag)
dmarw_fscsi:
 move.b   d0,-(sp)

;Hier muesste < bsr    acsi_begin    > hin

 moveq    #8,d1               ;Lesen
 move.b   (sp)+,_scsi_wrflag
 beq.b    fscsi_rw              
 moveq    #$a,d1              ;Schreiben
fscsi_rw:
 lea      _scsi_cmdbuf,a0
 move.b   d1,(a0)+
 move.b   5(sp),(a0)+
 move.b   6(sp),(a0)+
 move.b   7(sp),(a0)+
 move.b   9(sp),(a0)+
 clr.b    (a0)
 move.w   $e(sp),d0
 moveq    #6,d2
 movea.l  $a(sp),a0
 tst.b    _scsi_wrflag        ; 0=Read, 1=Write
 bne.s    _fscsi_wr           ; write

 bsr      fscsi_rd            ; FSCSI-Read
 bra      cache_flush

_fscsi_wr:
 bsr      fscsi_wr            ; FSCSI-Write

cache_flush:                  ; Cache-Flush beim 030
 bsr      cache_invalid       ; aendert keine Register
 tst.w    d0
 ble.s    rwfcsi_end
 moveq    #EREADF,d0
 tst.b    _scsi_wrflag
 beq.s    rwfcsi_end
 moveq    #EWRITF,d0
rwfcsi_end:
 rts

;---------------------------------------------
;
;FSCSI-Read
;
;Puffer in a0
;Device 8..15 in d0
;
fscsi_rd:
 st       $43e.w
 andi.w   #7,d0                    ;dev von 8..15 auf 0..7
 movem.l  d1/d2/a0,-(sp)
 bsr      fscsi_cmd           ;Kommando in dmacbuf[] schreiben
 movem.l  (sp)+,a0/d2/d1
 tst.w    d0                       ;Fehler?
 bmi.s    fscsi_rd_exit       ;ja

 move.w   #$89,$ffff8606.w
 move.w   #0,$ffff8604.w
 move.w   #$8b,$ffff8606.w
 move.w   #1,$ffff8604.w ;target command register
 move.w   #$8f,$ffff8606.w
 move.w   $ffff8604.w,d0 ;SCSI dma initiator receive
 movea.l  a0,a1                    ;Puffer
rdfcsi_loop:
 bsr      vbl_165ms
 bsr      fscsi_wait_ready
 bmi.s    fscsi_rd_exit       ;Timeout

 move.w   #$8d,$ffff8606.w
 move.w   $ffff8604.w,d0
 btst     #3,d0                    ;SCSI dma status
 beq.s    rdfcsi_l1

 move.w   #$88,$ffff8606.w
 move.w   $ffff8604.w,d0
 move.b   d0,(a1)+            ;ohne DMA von Hand lesen !
 bsr      fscsi_wait_busy
 bra.s    rdfcsi_loop

rdfcsi_l1:
 bsr      fscsi_dmarw_ende

fscsi_rd_exit:
 move.w   #$8f,$ffff8606.w
 move.w   $ffff8604.w,d1
 move.w   #$80,$ffff8606.w
 sf       $43e.w
 rts

;---------------------------------------------
;
;FSCI-Write
fscsi_wr:
 st       $43e.w
 andi.w   #7,d0
 movem.l  d1/d2/a0,-(sp)
 bsr.s    fscsi_cmd
 movem.l  (sp)+,a0/d2/d1
 tst.w    d0
 bmi.s    fscsi_wr_exit

 move.w   #$8b,$ffff8606.w
 move.w   #0,$ffff8604.w
 move.w   #$8f,$ffff8606.w
 move.w   $ffff8604.w,d0
 movea.l  a0,a1
wrfcsi_loop:
 bsr      vbl_165ms
 bsr      fscsi_wait_ready
 bmi.s    fscsi_wr_exit

 move.w   #$8d,$ffff8606.w
 move.w   $ffff8604.w,d0
 btst     #3,d0
 beq.s    wrfcsi_l1

 moveq    #0,d0
 move.b   (a1)+,d0
 move.w   #$88,$ffff8606.w
 move.w   d0,$ffff8604.w
 bsr      fscsi_wait_busy
 bra.s    wrfcsi_loop

wrfcsi_l1:
 bsr      fscsi_dmarw_ende
fscsi_wr_exit:
 move.w   #$8f,$ffff8606.w
 move.w   $ffff8604.w,d1
 move.w   #$80,$ffff8606.w
 sf       $43e.w
 rts

;-------------------------------------------
;
; Schreibt dmacbuf[] als Kommando
;
fscsi_cmd:
 movem.l  d1/d2/a0,-(sp)
 bsr      get_initiator_id_bit     ; UWE
 move.w   d1,-(sp)                 ; UWE: Bit fuer Initiator-ID
 move.w   d0,-(sp)            ;Target
 bsr.s    fscsi_begin
 addq.l   #4,sp
 movem.l  (sp)+,a0/d2/d1
 tst.w    d0
 bmi.s    fsc_cmd_exit        ;Fehler aufgetreten
 
 move.w   #$8b,$ffff8606.w
 move.w   #2,$ffff8604.w ;Target command register
 move.w   #$89,$ffff8606.w
 move.w   #1,$ffff8604.w ;initiator command register
 bsr      vbl_1505ms
 lea      _scsi_cmdbuf,a1
 subq.w   #1,d2
 
cmdfcsi_loop:
 move.b   (a1)+,d0            ;Byte aus Kommandoblock holen
 bsr      fscsi_byte               ;und ausgeben
 tst.w    d0                       ;ok?
 bmi.s    fsc_cmd_exit
 dbf      d2,cmdfcsi_loop        ;dann naechstes Byte
 moveq    #0,d0
 
fsc_cmd_exit:
 rts

;
; int fscsi_begin( int target, int initiatorID )
;
; Beginnt die Unterhaltung mit dem Target, Rueckgabe -1 bei Timeout
; wird nur von fscsi_cmd aufgerufen
fscsi_begin:
 bsr      vbl_165ms
begfcsi_loop:
 move.w   #$8c,$ffff8606.w
 move.w   $ffff8604.w,d0
 btst     #6,d0                         ;SCSI control register
 beq.s    begfcsi_l1                ;ok
 cmp.l    (a0),d1
 bhi.s    begfcsi_loop
 bra      begfcsi_l2                ;Timeout
 
begfcsi_l1:
 move.w   #$8b,$ffff8606.w
 move.w   #0,$ffff8604.w      ;Target command register
 move.w   #$8c,$ffff8606.w
 move.w   #0,$ffff8604.w      ;ID select
 move.w   #$89,$ffff8606.w
 move.w   #$c,$ffff8604.w          ;Initiator command register = 12
 clr.w    d0
 move.w   4(sp),d1                 ;Target in Bitnummer umrechnen
 bset     d1,d0
 or.w     6(sp),d0                 ; UWE
 move.w   #$88,$ffff8606.w
 move.w   d0,$ffff8604.w      ;und ins scsi data register
 move.w   #$89,$ffff8606.w
 move.w   #5,$ffff8604.w      ;mode register
 move.w   #$8a,$ffff8606.w
 move.w   $ffff8604.w,d0
 andi.b   #$fe,d0                       ;target command register
 move.w   #$8a,$ffff8606.w
 move.w   d0,$ffff8604.w
 move.w   #$89,$ffff8606.w
 move.w   $ffff8604.w,d0      ;mode register
 andi.b   #$f7,d0
 move.w   #$89,$ffff8606.w
 move.w   d0,$ffff8604.w
 nop
 nop
 bsr      vbl_165ms
begfcsi_loop2:
 move.w   #$8c,$ffff8606.w
 move.w   $ffff8604.w,d0      ;SCSI control register
 btst     #6,d0                         
 bne.s    begfcsi_l3                ;ok
 cmp.l    (a0),d1                       ;Timeout?
 bhi.s    begfcsi_loop2

begfcsi_l2:
 moveq    #-1,d0                        ;Timeout!
 bra.s    begfcsi_l4
begfcsi_l3:
 clr.w    d0                            ;ok
begfcsi_l4:
 move.w   #$89,$ffff8606.w
 move.w   #0,$ffff8604.w      ;initiator command register loeschen
 rts

;
fscsi_dmarw_ende:
 bsr      vbl_165ms
 move.w   #$8b,$ffff8606.w
 move.w   #3,$ffff8604.w      ;Target command register
 move.w   #$8f,$ffff8606.w         ;DMA initiator receive
 move.w   $ffff8604.w,d0
 bsr.s    fscsi_wait_ready
 bmi.s    endfcsi_l2                ;Timeout

 move.w   #$88,$ffff8606.w
 move.w   $ffff8604.w,d0      ;SCSI data register enthaelt Fehlercode
 andi.w   #$ff,d0
 move.l   d0,-(sp)
 bsr      vbl_165ms
 bsr.s    fscsi_wait_busy
 tst.w    d0
 beq.s    endfcsi_l3                ;ok
 
endfcsi_l1:
 addq.l   #4,sp
 bra.s    endfcsi_l2                ;Timeout
 
endfcsi_l3:
 bsr      vbl_165ms
 bsr.s    fscsi_wait_ready
 bmi.s    endfcsi_l1
 move.w   #$88,$ffff8606.w         
 move.w   $ffff8604.w,d0      ;SCSI data register
 bsr.s    fscsi_wait_busy
 tst.w    d0
 bmi.s    endfcsi_l1                ;Timeout
 move.l   (sp)+,d0
endfcsi_l2:
 rts

;
;int fscsi_wait_ready( d1 = long timeout_ticks, a0 = long *timer )
;
; a0 == &_hz_200
; wartet, bis SCSI bereit ist oder Timeout
;
fscsi_wait_ready:
 move.w   #$8c,$ffff8606.w
 move.w   $ffff8604.w,d0
 btst     #5,d0
 bne.s    wtrdyfcsi_l1
 cmp.l    (a0),d1
 bhi.s    fscsi_wait_ready
 
 moveq    #-1,d0
 bra.s    wtrdyfcsi_end
wtrdyfcsi_l1:
 moveq    #0,d0
wtrdyfcsi_end:
 rts

;
; int fscsi_wait_busy( d1 = long timeout_ticks, a0 = long *timer )
;
; a0 == &_hz_200
; wartet, bis SCSI beschaeftigt ist oder Timeout
;
fscsi_wait_busy:
 move.w   #$89,$ffff8606.w
 move.w   $ffff8604.w,d0
 ori.b    #$11,d0
 move.w   #$89,$ffff8606.w
 move.w   d0,$ffff8604.w
 andi.b   #$ef,d0
 move.w   #$89,$ffff8606.w
 move.w   d0,$ffff8604.w
 moveq    #0,d0
 rts

;
; int fscsi_byte( d0 = char b )
;
; Verarbeitet ein Kommandobyte, RUeckgabe negativ bei Fehler
;
fscsi_byte:
 move.w   d0,-(sp)
 bsr.s    fscsi_wait_ready              ;warte bis Timeout oder SCSI ready
 bmi.s    bytfcsi_end
 move.w   (sp),d0
 move.w   #$88,$ffff8606.w
 move.w   d0,$ffff8604.w           ;Byte nach scsi data register
 bsr.s    fscsi_wait_busy
bytfcsi_end:
 addq.l   #2,sp
 rts

;
vbl_1505ms:
 movea.w  #$4ba,a0
 move.l   #$12d,d1
 add.l    (a0),d1
 rts

;
; UWE:
; Bit fuer SCSI Initiator-ID aus NVRAM auslesen und nach D1
;
; d1 = WORD get_initiator_id_bit ( void )
; Aendert nicht d0
;
; Falls aus irgendeinem Grund keine Initiator-Identifizierung
; (kein NVRAM oder Initiator-Identifizierung nicht eingeschaltet)
; mit 0 in D1 zurueckkehren -> kein ID-Bit gesetzt
;

get_initiator_id_bit:
 move.w   d0,-(sp)            ; d0 retten
 subq.l   #2,sp               ; char buf[2]
 pea      (sp)                ; char *buffer
 move.w   #2,-(sp)            ; 2 Bytes aus NVRAM auslesen (warum 2?)
 move.w   #16,-(sp)           ; ab Offset 16
 clr.w    -(sp)               ; lesen
 bsr      _NVMaccess
 lea      10(sp),sp
 moveq    #0,d1               ; Default: kein ID-Bit
 tst.l    d0
 bmi.b    no_init_id          ; kein NVRAM (ist ein ST)
 move.b   (sp),d0             ; das gesuchte Byte
 bpl.b    no_init_id          ; ungueltig
 andi.w   #%00000111,d0       ; SCSI-ID isolieren
 moveq    #1,d1
 lsl.w    d0,d1               ; SCSI-ID in ID-Bit umrechnen
no_init_id:
 addq.l   #2,sp
 move.w   (sp)+,d0            ; d0 zurueck
 rts
