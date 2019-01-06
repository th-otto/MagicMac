**********************************************************************
*******************     Floppy- Treiber   ****************************
**********************************************************************


/*
*
* wird beim Booten aufgerufen, um die Floppies zu deselektieren
*
*/

boot_dsel_floppies:
/*
 lea      giselect,a0              ; Soundchip
 move.b   #7,(a0)                  ; Register 7 selektieren
 move.b   #$c7,2(a0)               ; Port A/B auf Ausgang,
                                   ;  Kanaele A/B/C Sound aus
 move.b   #$f8,2(a0)               ; Port A/B auf Ausgang,
                                   ;  Kanaele A/B/C Rauschen aus
 move.b   #$e,(a0)                 ; Register 14 selektieren
 move.b   #7,2(a0)                 ; Floppies A/B deselektieren und Seite 0
*/
 lea      giselect,a0              ; Soundchip
 move.b   #7,(a0)                  ; Register 7 selektieren
 move.b   #$c0,2(a0)
 move.b   #$e,(a0)                 ; Register 14 selektieren
 move.b   #7,2(a0)                 ; Floppies A/B deselektieren und Seite 0
 rts


*********************************************************************
*
* Interruptsteuerung:
*
* Alles geht ueber den Eingang I5 des ST-MFP, hat den Interrupt #7
* (aktiviert mit Bit 7 von ierb)
* Polling ueber Bit 5 von gpip
* 1. aer fuer Bit 5 muss 0 sein, d.h. Interrupt wird ausgeloest beim
*    Uebergang von 1 auf 0
* 2. Interrupt _mfpint (7) aktivieren und Vektor setzen (Adr. $11c)
*

**********************************************************************
*
* Sperre den FDC/ACSI-DMA
* und gib ihn wieder frei.
* Kein Register (ausser d0 bei acsi_end) wird veraendert
*
* Fuer die Zeit, in der AES noch nicht initialisiert ist, kann evnt_sem
* nicht sperren, weil act_appl immer NULL ist.
*

     IFNE DEBUG2
     OFFSET

ap_next:       DS.L 1
ap_id:         DS.W 1
ap_parent:     DS.W 1
ap_menutree:   DS.L 1
ap_desktree:   DS.L 1
ap_1stob:      DS.W 1
ap_dummy1:     DS.B 2
ap_name:       DS.B 8
ap_dummy2:     DS.B 2
ap_dummy3:     DS.B 1
     TEXT

sem1: DC.B     $1b,'v1',0
sem0: DC.B     '0',0
     EVEN
     ENDIF

acsi_begin:
 move.l   hddrv_tab+hd_acsibegin,-(sp)
 rts
_acsi_begin:
 movem.l  d1-d2/a0-a2,-(sp)
 lea      dma_sem,a0
 moveq    #0,d1               ; kein Timeout
 moveq    #SEM_SET,d0
 jsr      evnt_sem
     IFNE DEBUG2
 move.l   d0,-(sp)
 move.l   act_appl,d0
 ble.b    sss1
 move.l   d0,a0
 lea      ap_name(a0),a0
 bsr      putstr
sss1:
 lea      sem1(pc),a0
 bsr      putstr
 move.l   (sp)+,d0
     ENDIF
 st       flock
 movem.l  (sp)+,d1-d2/a0-a2
 rts

acsi_end:
 move.l   hddrv_tab+hd_acsiend,-(sp)
 rts
_acsi_end:
 movem.l  d0-d2/a0-a2,-(sp)
 lea      dma_sem,a0
 moveq    #SEM_FREE,d0
 jsr      evnt_sem
     IFNE DEBUG2
 lea      sem0(pc),a0
 bsr      putstr
     ENDIF
 clr.w    flock
 movem.l  (sp)+,d0-d2/a0-a2
 rts


**********************************************************************
*
* long cond_wait_ACSI( d0 = long ticks_200hz )
*
* RUeckgabe:    0    OK
*             -1    TimeOut
*             -2    Busfehler
*

cond_wait_ACSI:
 btst     #3,config_status+2  ; Bit 11: disable FDC-parallel
 bne.b    wait_ACSI           ; nein, normale Funktion
 movem.l  d1-d2/a0-a2,-(sp)
 bra.b    wdma_no_yield


**********************************************************************
*
* long wait_ACSI( d0 = long ticks_200hz )
*
* RUeckgabe:    0    OK
*             -1    TimeOut
*             -2    Busfehler
*

wait_ACSI:
 move.l   hddrv_tab+hd_acsiwait,-(sp)
 rts
_wait_ACSI:
 movem.l  d1-d2/a0-a2,-(sp)
 tst.w    pe_slice            ; praeemptiv ?
 bmi.b    wdma_no_yield       ; nein, busy waiting
 move.l   act_appl,d2
 ble.b    wdma_no_yield       ; aktuelle Applikation ungueltig

* neue Routine ueber evnt_IO und MFP- Interrupt

 lsr.l    #2,d0               ; AES: 50Hz statt 200Hz
wdma_neu:
 move     sr,d1
 ori      #$700,sr
 btst     #5,gpip             ; schon fertig ?
 beq.b    wdma_ok2            ; ja, enable interrupt
; Interrupt aufsetzen
 pea      int_mfp7_unsel(pc)
 move.l   d2,imfp7_appl       ; act_appl
 move.l   sp,imfp7_unsel
; Interrupt freigeben
 move.w   d1,sr
; Auf Interrupt warten
 move.l   sp,a0
;move.w   d0,d0               ; TimeOut in 50Hz- Ticks
 jsr      evnt_IO
 addq.l   #4,sp
wdma_ende:
 movem.l  (sp)+,d1-d2/a0-a2
 rts

* alte Routine mit busy waiting ueber _hz_200

wdma_no_yield:
 add.l    _hz_200,d0
wdma_loop:
 btst     #5,gpip
 beq.b    wdma_ok
 cmp.l    _hz_200,d0
 bcc.b    wdma_loop
wdma_timeout:
 moveq    #-1,d0              ; Timeout
 bra.b    wdma_ende
wdma_ok2:
 move.w   d1,sr
wdma_ok:
 moveq    #0,d0               ; OK
 bra.b    wdma_ende


**********************************************************************
*
* Interruptroutine fuer MFP, Interruptkanal #7 = I/O-Port 5
* (DMA/FDC busy)
*
* Rueckgabewert 0 (OK)
*

int_mfp7:
 tst.l    imfp7_unsel                   ; Interrupt aktiviert ?
 beq.b    imfp7_ende                    ; nein, weiter
 movem.l  d0-d2/a0-a2,-(sp)

 move.l   imfp7_unsel,a0
 clr.l    imfp7_unsel                   ; Interrupt deaktivieren
 clr.l    (a0)                          ; als eingetroffen markieren

 move.l   imfp7_appl,a0
 jsr      appl_IOcomplete               ; wartende APP aufwecken
 movem.l  (sp)+,d0-d2/a0-a2
imfp7_ende:
 move.b   #$7f,isrb                     ; service- Bit loeschen
 rte


**********************************************************************
*
* void int_mfp7_unsel( a0 = long *unselect, a1 = APPL *ap );
*
* Deaktiviert den Interrupt wieder, wenn er nicht eingetroffen ist
* Rueckgabewert -1 (Timeout)
*

int_mfp7_unsel:
 clr.l    imfp7_unsel                   ; Interrupt deaktivieren
 moveq    #-1,d0
 move.l   d0,(a0)                       ; nicht eingetroffen
 rts


**********************************************************************
*
* long set_DMA_write( d0 = int tr_cnt, d1 = int fdc_cmd )
*
* Loescht den FIFO und setzt DMA auf Schreiben.
* Schreibt <tr_cnt> in den DMA- Sektorzaehler
* Anschliessend wird das Command/Status-Register des FDC selektiert
* und ein <fdc_cmd> abgesetzt.
*
* Setzt bei TimeOut den FDC zurueck
*
* RUeckgabe:    0  und EQ OK
*              -1 und NE TimeOut
*

set_DMA_write:
 move.w   #$90,(a6)                ; DMA-FIFO durch Klappern loeschen
 bsr      teste_fa01
 move.w   #$190,(a6)               ; Bit 8  : DMA auf Schreiben
                                   ; Bit 4  : DMA selektieren
 bsr      teste_fa01
 move.w   d0,d7                    ; DMA: Anz. Sektoren
 bsr      d7_todma

; FIXME: CT60 patches this to bsr dma_delay
 bsr      teste_fa01               ; neu - andernfalls Busfehler bei Falcon-DMA
                                   ; (zu schneller Zugriff)

 move.w   #$180,(a6)               ; Bit 8  : DMA auf Schreiben
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 move.w   d1,d7                    ; fdc_cmd
 bsr      d7_todma
 bra      wait_FDC_300


**********************************************************************
*
* long set_DMA_read( )
*
* Loescht den FIFO und setzt DMA auf Lesen.
* Schreibt eine "1" in den DMA- Sektorzaehler
* Anschliessend wird das Command/Status-Register des FDC selektiert
* und ein READ SECTOR abgesetzt.
*
* Setzt bei TimeOut den FDC zurueck
*
* RUeckgabe:    0  und EQ OK
*              -1 und NE TimeOut
*

set_DMA_read:
 move.w   #$190,(a6)               ; DMA-FIFO durch Klappern loeschen
 bsr      teste_fa01
 move.w   #$90,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : DMA selektieren
 bsr      teste_fa01
 move.w   #1,$ffff8604             ; DMA: 1 Sektor
 move.w   #$80,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 move.w   #$80,d7                  ; READ SECTOR
                                   ;  single sector Zugriff
                                   ;  mit SpinUp
                                   ;  keine Verzoegerung
 bsr      d7_todma                 ; FDC-Kommando abschicken
;bra      wait_FDC_300


**********************************************************************
*
* long wait_FDC( d0 = long ticks_200hz )
*
* Setzt bei TimeOut den FDC zurueck
*

wait_FDC_300:
 move.l   flptimeout,d0       ; normalerweise 1,5s
wait_FDC:
 bsr      cond_wait_ACSI      ; aendert kein Register
 tst.l    d0
 beq.b    wfdc_ok
* TimeOut: FDC zuruecksetzen
 bsr      _resetfdc
 moveq    #-1,d0
 rts
wfdc_ok:
 rts


_dsb_toa1:
 lea      dsb0,a1                  ; fuer A:
 beq.b    _dsb_ende
 addq.l   #(dsb1-dsb0),a1          ; fuer B:
_dsb_ende:
 rts


flopini:
 lea      4(sp),a0
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   a0,a5
 tst.w    8(a5)
 bsr      _dsb_toa1
 move.w   seekrate,dsb_seekrate(a1)
 move.w   #3,dsb_hdmode(a1)        ; zunaechst HD
 clr.w    dsb_track(a1)            ; Track #0
 move.l   a5,a0
 moveq    #-1,d0                   ; Default- Fehler ERROR
 bsr      floplock                 ; Initialisierung und Semaphore
 bsr      _select                  ; Laufwerk selektieren und
                                   ; FDC- Register setzen
 move.w   #$ff00,(a1)              ; Track ungueltig
 bsr      _seek0                   ; nach Spur #0 gehen
 beq.b    flpi_ok                  ; kein Fehler
 moveq    #10,d7                   ; Fehler: seek Track 10 versuchen
 bsr      _hseek
 bne.b    flpi_err                 ; Fehler
 bsr      _seek0                   ; OK, wieder nach Track 0
 beq.b    flpi_ok                  ; jetzt OK
flpi_err:
 bsr      flopfail                 ; nein, immer noch Fehler
 bra.b    flpi_ende
flpi_ok:
 bsr      flopok
flpi_ende:
 movem.l  (sp)+,d3-d7/a3-a6
 rts


**********************************************************************
*
* long Floprd( void *buf, long filler, int dev, int secno,
*              int trackno, int sideno, int count )
*

Floprd:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr      acsi_begin
 bsr.b    _Floprd
 bsr      acsi_end
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte

_Floprd:
 lea      4(sp),a0
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   a0,a5
 lea      8(a5),a0                 ; &dev
 bsr      _tstchng
 bmi      flprd_ende
 move.l   (a5),a1
 cmpa.l   phystop,a1               ; Pufferadresse > Ende ST-RAM ?
 bcs.b    flprd_st_ram
 move.l   a1,flp_fstbuf            ; tatsaechliche Adresse merken
 move.l   ptr_frb,(a5)             ; Puffer statt Adressen "einpatchen"
 move.w   16(a5),flp_fstcnt
flprd_st_ram:
 move.l   a5,a0
 moveq    #EREADF,d0
 bsr      floplock
_floprd_l3:
 bsr      _select
 bsr      fgo2track                ; nach ctrack gehen
 bcs.b    flprd_err                ; boeser Fehler
 bne      _retry                   ; kleiner Fehler
_floprd_loopsect:
 move.w   #ERROR,_cerror
 bsr      set_DMA_read             ; DMA lesen und FDC-Commandreg. sel.

 beq.b    _floprd_l1                ; OK, Ende
; TimeOut
 move.w   #EDRVNR,_cerror
 bra.b    _retry

; OK, Befehl ausgefuehrt
_floprd_l1:
 move.w   #$90,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : DMA selektieren
 move.w   (a6),d0                  ; d0 = DMA-Status
 btst     #0,d0                    ; DMA-Fehler ?
 beq.b    _retry                   ; ja, nochmal versuchen
 move.w   #$80,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 bsr      dma_tod0                 ; d0 = FDC-Status
 and.b    #$1c,d0                  ; "motor on" ignorieren
                                   ; Bit 6 ist ohne Funktion
                                   ; Bit 5 ignorieren (Valid data)
                                   ; Bit 0 (busy) ignorieren
                                   ; Bit 1 (DRQ) ignorieren
 bne.b    _floprd_l2                ; Fehler aufgetreten
 move.w   #2,_rtrycnt              ; beim naechsten Mal wieder 2 Versuche
 addq.w   #1,csect                 ; naechster Sektor
 addi.l   #$200,cdma               ; 512 Bytes gelesen
 subq.w   #1,ccount                ; noch weitere Sektoren ?
 beq.b    flprd_ok                 ; nein, Ende
 bsr      fdc_set_sec_adr          ; Sektor => FDC, Adresse => DMA
 bra      _floprd_loopsect                ; naechster Sektor
_floprd_l2:
 bsr.b    errbits                  ; FDC-Fehler dekodieren
_retry:
 cmpi.w   #1,_rtrycnt              ; schon zweiter Versuch ?
 bne.b    _floprd_l4                ; nein
 bsr      again_go2track           ; war schon zweiter Versuch
_floprd_l4:
 subq.w   #1,_rtrycnt
 bpl      _floprd_l3
flprd_err:
 bsr      flopfail
 bra.b    flprd_ende
flprd_ok:
 bsr      flopok
flprd_ende:
 movem.l  (sp)+,d3-d7/a3-a6
 rts


***********************************************************
*
* Rechnet d0 in Fehlercodes um, nimmt notfalls _deferror.
* Fehlercode wird nach _cerror geschrieben
*

errbits:
 moveq    #EWRPRO,d1
 btst     #6,d0
 bne.b    errbits_end
 moveq    #ESECNF,d1
 btst     #4,d0
 bne.b    errbits_end
 moveq    #E_CRC,d1
 btst     #3,d0
 bne.b    errbits_end
 move.w   _deferror,d1
errbits_end:
 move.w   d1,_cerror
 rts


**********************************************************************
*
* long Flopwr(void *buf, long filler, int dev, int secno,
*             int trackno, int sideno, int count )
*
Flopwr:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr      acsi_begin
 bsr.b    _Flopwr
 bsr      acsi_end
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte

_Flopwr:
 lea      4(sp),a0
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   a0,a5
 lea      8(a5),a0                 ; &dev
 bsr      _tstchng
 bmi      flprd_ende
 move.l   (a5),a1
 cmpa.l   phystop,a1               ; Pufferadresse > Ende ST-RAM ?
 bcs.b    flpwr_st_ram
;move.l   a1,a1
 move.l   ptr_frb,a0
 move.l   a0,(a5)
 move.w   16(a5),d1
 bsr      flp_fstcpy               ; Vorher Daten in den FRB schreiben
flpwr_st_ram:
 move.l   a5,a0
 moveq    #EWRITF,d0
 bsr      floplock
; Wenn Seite 0/Track 0/Sektor 1 beschrieben wird, ist das so,
; als ob die Diskette gewechselt worden ist!
 move.w   csect,d0
 subq.w   #1,d0
 or.w     ctrack,d0
 or.w     cside,d0
 bne.b    _flopwr_l1
 bsr      setdmode_2               ; Disk ist gewechselt worden
_flopwr_l1:
 bsr      _select
 bsr      go2track
 bcs      flprd_err                ; boeser Fehler
 bne      _flopwr_l2                ; kleinerer Fehler
_flopwr_l4:
 move.w   #ERROR,_cerror

 moveq    #1,d0                    ; DMA: 1 Sektor
 move.w   #$a0,d1                  ; WRITE SECTOR
                                   ;  single sector Zugriff
                                   ;  mit SpinUp
                                   ;  keine Verzoegerung
                                   ;  Prekomp. aus
                                   ;  Normale Daten
 bsr      set_DMA_write

 bne.b    _flopwr_l3                ; TimeOut
; OK, kein Fehler
 move.w   #$180,(a6)               ; Bit 8  : DMA auf Schreiben
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 bsr      dma_tod0                 ; d0 = FDC- Status
 bsr      errbits                  ; in Fehlercodes umrechnen
 btst     #6,d0                    ; Schreibschutz ?
 bne      flprd_err                ; ja, Ende
 and.b    #$5c,d0
 bne.b    _flopwr_l3                ; Fehler, naechster Versuch
 move.w   #2,_rtrycnt              ; wieder 2 Versuche
 addq.w   #1,csect                 ; naechster Sektor
 addi.l   #$200,cdma               ; naechste Adresse
 subq.w   #1,ccount                ; naechster Sektor
 beq      flprd_ok                 ; war letzter
 bsr      fdc_set_sec_adr          ; Sektornummer und DMA- Adresse aendern
 bra      _flopwr_l4                ; und naechster Sektor
; naechster Versuch
_flopwr_l3:
 cmpi.w   #1,_rtrycnt              ; schon zweiter Versuch ?
 bne.b    _flopwr_l5                ; nein
_flopwr_l2:
 bsr      again_go2track           ; ggf. DD/HD umschalten
_flopwr_l5:
 subq.w   #1,_rtrycnt
 bpl      _flopwr_l1                ; naechster Versuch
 bra      flprd_err                ; Fehler


**********************************************************************
*
* long Flopfmt( void *buf, long filler, int dev, int spt, int trackno,
*              int sideno, int interleave, long magic, int virgin )
*

Flopfmt:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   22(a0),-(sp)   ; virgin
 move.l   18(a0),-(sp)   ; magic
 move.w   16(a0),-(sp)   ; interleave
 move.w   14(a0),-(sp)   ; sideno
 move.w   12(a0),-(sp)   ; trackno
 move.w   10(a0),-(sp)   ; spt
 move.w   8(a0),-(sp)    ; dev
 move.l   4(a0),-(sp)    ; filler
 move.l   (a0),-(sp)     ; *buf
 bsr      acsi_begin
 bsr.b    _Flopfmt
 bsr      acsi_end
 lea.l    24(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte

_Flopfmt:
 lea      4(sp),a0
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   a0,a5
 cmpi.l   #$87654321,18(a5)
 bne      flprd_err
 lea      8(a5),a0                 ; &dev
 bsr      _tstchng
 bmi      flprd_ende
 move.l   (a5),a1
 cmpa.l   phystop,a1               ; Pufferadresse > Ende ST-RAM ?
 bcs.b    flpfmt_st_ram
 move.l   a1,flp_fstbuf            ; *buf
 move.l   ptr_frb,(a5)
 move.w   #1,flp_fstcnt            ; nach Aktion einen Sektor kopieren
flpfmt_st_ram:
 move.l   a5,a0
 moveq    #ERROR,d0
 bsr      floplock
 bsr      _select
 move.w   10(a5),flpfmt_spt        ; spt
 move.w   16(a5),flpfmt_intlv      ; interleave
 move.w   22(a5),flpfmt_vrgn       ; virgin
 bsr      setdmode_2               ; Disk ist gewechselt worden
; DD/HD umschalten
 moveq    #0,d0
 cmpi.b   #2,machine_type
 bcs.b    fmt_st
 cmpi.w   #$d,flpfmt_spt           ; Sektoren pro Track >= 13 ?
 bcs.b    _flopfmt_l1                ; nein, nimm 0
 moveq    #3,d0                    ; sonst 3
_flopfmt_l1:
 move.w   d0,M_fdc_hdmode
fmt_st:
 move.w   d0,dsb_hdmode(a1)

 bsr      hseek                    ; gehe zum Track
 bne      flprd_err                ; Fehler
 move.w   ctrack,dsb_track(a1)
 move.w   #ERROR,_cerror
 move.l   4(a5),a3                 ; NULL oder Sektornummern
 bsr.b    fmtrack
 bne      flprd_err                ; Fehler, Ende
 move.w   flpfmt_spt,ccount        ; alle Sektoren verifizieren
 move.w   #1,csect                 ; ab Sektor 1 der Spur
 bsr      flpverify                ; verifizieren
 movea.l  cdma,a2                  ; Nummern der fehlerhaften Sektoren
 tst.w    (a2)                     ; Liste leer ?
 beq      flprd_ok                 ; ja, OK
 move.w   #EBADSF,_cerror          ; Fehler
 bra      flprd_ok


fmtrack:
 move.w   #EWRITF,_deferror
 movea.l  cdma,a2

; Baue im Puffer den zu schreibenden Track zusammen

 cmpi.b   #2,machine_type
 bcs.b    fmtt_st
 moveq    #$77,d1
 cmpi.w   #$d,flpfmt_spt           ; flpfmt_spt >= 13 ?
 bcc.b    _flopfmt_l2
fmtt_st:
 moveq    #$3b,d1
_flopfmt_l2:

 moveq    #$4e,d0
 bsr      wmult
 clr.w    d3
 tst.w    flpfmt_intlv
 bmi      _flopfmt_l3
 moveq    #1,d3
_flopfmt_l10:
 move.w   d3,d4
_flopfmt_l6:
 moveq    #$b,d1
 clr.b    d0
 bsr      wmult
 moveq    #2,d1
 moveq    #$fffffff5,d0
 bsr      wmult
 move.b   #$fe,(a2)+
 move.b   ctrack+1,(a2)+
 move.b   cside+1,(a2)+
 move.b   d4,(a2)+
 move.b   #2,(a2)+
 move.b   #$f7,(a2)+
 moveq    #$15,d1
 moveq    #$4e,d0
 bsr      wmult
 moveq    #$b,d1
 moveq    #0,d0
 bsr      wmult
 moveq    #2,d1
 moveq    #$fffffff5,d0
 bsr      wmult
 move.b   #$fb,(a2)+
 move.w   #$ff,d1
_flopfmt_l9:
 move.b   flpfmt_vrgn,(a2)+
 move.b   flpfmt_vrgn+1,(a2)+
 dbf      d1,_flopfmt_l9
 move.b   #$f7,(a2)+
 moveq    #$27,d1
 moveq    #$4e,d0
 bsr      wmult
 tst.w    flpfmt_intlv
 bmi      _flopfmt_l3
 add.w    flpfmt_intlv,d4
 cmp.w    flpfmt_spt,d4
 ble      _flopfmt_l6
 addq.w   #1,d3
 cmp.w    flpfmt_intlv,d3
 ble      _flopfmt_l10
_flopfmt_l5:

 cmpi.b   #2,machine_type
 bcs.b    fmtt2_st
 move.w   #$af0,d1                 ; TOS 2.05
 cmpi.w   #$d,flpfmt_spt
 bcc.b    _flopfmt_l8
fmtt2_st:
 move.w   #$578,d1
_flopfmt_l8:

 moveq    #$4e,d0
 bsr      wmult

; Der Track ist jetzt aufgebaut

 move.b   cdma+3,$ffff860d
 move.b   cdma+2,$ffff860b
 move.b   cdma+1,$ffff8609

 moveq    #$30,d0                  ; DMA-Sektorzaehler auf 48 (???)
 move.w   #$f0,d1                  ; WRITE TRACK
                                   ;  mit SpinUp
                                   ;  ohne Verzoegerung
                                   ;  Prekomp. ein
 bsr      set_DMA_write
 beq.b    _flopfmt_l4                ; OK
; TimeOut
_flopfmt_l7:
 moveq    #1,d7
 rts

* Sonderbehandlung fuer vorgegebene Sektornummern

_flopfmt_l3:
 cmp.w    flpfmt_spt,d3
 beq.b    _flopfmt_l5
 move.w   d3,d6
 add.w    d6,d6
 move.w   0(a3,d6.w),d4
 addq.w   #1,d3
 bra      _flopfmt_l6

; kein TimeOut
_flopfmt_l4:
 move.w   #$190,(a6)               ; Bit 8  : DMA auf Schreiben
                                   ; Bit 4  : DMA selektieren
 move.w   (a6),d0                  ; DMA- Status
 btst     #0,d0                    ; Fehler ?
 beq.b    _flopfmt_l7                ; DMA- Fehler
 move.w   #$180,(a6)               ; Bit 8  : DMA auf Schreiben
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 bsr      dma_tod0                 ; d0 = FDC- Status
 bsr      errbits                  ; in Fehlercodes umrechnen
 and.b    #$44,d0                  ; wichtige Bits isolieren
 rts

wmult:
 move.b   d0,(a2)+
 dbf      d1,wmult
 rts


**********************************************************************
*
* long Flopver( char *buf, long filler, int dev, int secno,
*               int trackno, int sideno, int count )
*

Flopver:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr      acsi_begin
 bsr.b    _Flopver
 bsr      acsi_end
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte

_Flopver:
 lea      4(sp),a0
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   a0,a5
 lea      8(a5),a0                      ; &dev
 bsr      _tstchng
 bmi      flprd_ende
 move.l   (a5),a1
 cmpa.l   phystop,a1                    ; Pufferadresse > Ende ST-RAM ?
 bcs.b    flpver_st_ram
 move.l   a1,flp_fstbuf
 move.l   ptr_frb,(a5)
 move.w   #1,flp_fstcnt                 ; nach Aktion einen Sektor kopieren
flpver_st_ram:
 move.l   a5,a0
 moveq    #EREADF,d0
 bsr      floplock
 bsr      _select
 bsr      fgo2track
 bne      flprd_err
 bsr.b    flpverify
 bra      flprd_ok


flpverify:
 move.w   #EREADF,_deferror
 movea.l  cdma,a2                  ; a2 enthaelt fehlerhafte Sektoren
 addi.l   #$200,cdma               ; 512 Bytes Platz fuer Fehlerliste
flopver_loopsect:
 move.w   #2,_rtrycnt
 move.w   #$84,(a6)                ; DMA auf Lesen
                                   ; FDC selektieren
                                   ; FDC-Sector-Register selektieren
 move.w   csect,d7
 bsr      d7_todma                 ; csect ins FDC-Sector-Register
flopver_retrloop:
 move.b   cdma+3,$ffff860d
 move.b   cdma+2,$ffff860b
 move.b   cdma+1,$ffff8609
 bsr      set_DMA_read             ; DMA auf Lesen und FDC-Commandreg. sel.

 bne.b    flopver_l1                ; TimeOut
; kein TimeOut
 move.w   #$90,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : DMA selektieren
 move.w   (a6),d0                  ; d0 = DMA- Status
 btst     #0,d0
 beq.b    flopver_l1                ; DMA- Fehler
 move.w   #$80,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 bsr      dma_tod0                 ; d0 = FDC-Status
 bsr      errbits                  ; in Fehlercodes umrechnen
 and.b    #$1c,d0
 bne.b    flopver_l1                ; echte Fehler
flopver_l3:
 addq.w   #1,csect
 subq.w   #1,ccount
 bne      flopver_loopsect                ; naechster Sektor
 subi.l   #$200,cdma               ; dma wieder auf Sektortabelle
 clr.w    (a2)                     ; Sektortabelle mit 0 abschliessen
 rts

; Retry, ggf. fehlerhafte Sektornummer merken
flopver_l1:
 cmpi.w   #1,_rtrycnt
 bne.b    flopver_l2
 bsr      again_go2track
flopver_l2:
 subq.w   #1,_rtrycnt
 bpl      flopver_retrloop
 move.w   csect,(a2)+         ; fehlerhafte Sektornummer merken
 bra.b    flopver_l3


**********************************************************************
*
* floppy_vbl( void )
*
* VBL- Routine fuer Floppies
* wird von int_vbl aufgerufen, der 68030- Datencache ist abgeschaltet
*

floppy_vbl:
 st       motoronflg
 tst.w    flock
 bne.b    flopvbl_l1
 move.l   _frclock,d0
 move.b   d0,d1
 and.b    #7,d1
 bne.b    flopvbl_l2                ; nur in jedem 8. Interrupt
 move.w   #$80,$ffff8606           ; DMA- Mode:
                                   ;  Read/FDC/0/0/Contr/FDC/0/0/x
 lsr.b    #3,d0                    ; immer abwechselnd Floppy A/B
 and.w    #1,d0
 lea      wpstat,a0
 adda.w   d0,a0
 cmp.w    _nflops,d0
 bne.b    flopvbl_l3
 clr.w    d0
flopvbl_l3:
 addq.b   #1,d0                    ; A=1 B=2
 lsl.b    #1,d0                    ; A=Bit1 B=Bit2
 eori.b   #7,d0                    ; Bits sind low-aktiv, Seite 0 anwaehlen
 bsr      setporta_flp             ; selektieren und Seite 0
                                   ; TOS 2.05: "bsr dma_tod0" statt move...
 bsr      dma_tod0                      ; #### NEU
;move.w   $ffff8604,d0                  ; #### ALT
                                   ; Controller Access Register (FDC)
 btst     #6,d0
 sne      (a0)                     ; Write Protect merken
 move.b   d2,d0
 bsr      setporta_flp             ; alten Status von Port A restaurieren
flopvbl_l2:
 move.w   wpstat,d0
 or.w     d0,wplatch
 tst.b    deslflg                  ; Floppies schon deselektiert ?
 bne.b    flopvbl_l4                ; ja

 move.l   _hz_200,d0               ; #### NEU
 cmp.l    flp_led_out,d0           ; #### NEU
 bcc.b    flopvbl_l5                ; #### NEU

 bsr      dma_tod0
 btst     #7,d0                    ; Motor on Bit gesetzt ?
 bne.b    flopvbl_l1                ; ja, nicht deselektieren

flopvbl_l5:
 moveq    #7,d0                    ; beide Floppies
 bsr      setporta_flp             ;  deselektieren
 st       deslflg                  ; merken
flopvbl_l4:
 sf       motoronflg
flopvbl_l1:
 rts


************************************************************
*
* Wird bei Beginn einer Floppy- Operation aufgerufen.
* Setzt die flock- Semaphore.
* Initialisiert die cxxxx- Variablen
* Faehrt bei ungueltigem dsb_track Spur #0 an, ggf. bleibt
*  dsb_track bei einem Fehler ungueltig
*
* Eingabe:  d0 = Default- Fehlercode
*           (a0) und folgende: Parameter
*
* Rueckgabe: a6 = $ffff8606 (dma_diskctl)
*           a1 = dsb
*

floplock:
 lea      $ffff8606,a6
 st       motoronflg
 move.w   d0,_deferror
 move.w   d0,_cerror
 move.l   (a0)+,cdma               ; void *buf
 addq.l   #4,a0                    ; long filler
 move.w   (a0)+,cdev               ; int  devno
 move.w   (a0)+,csect              ; int  secno
 move.w   (a0)+,ctrack             ; int  trackno
 move.w   (a0)+,cside              ; int  sideno
 move.w   (a0),ccount              ; int  count
 move.w   #2,_rtrycnt
 tst.w    cdev
 bsr      _dsb_toa1
 tst.w    dsb_track(a1)            ; Track gueltig ?
 bpl.b    floplk_l1                ; ja
 bsr      _select                  ; Laufwerk neu selektieren
 clr.w    dsb_track(a1)
 bsr      _seek0                   ; nach Spur 0
 beq.b    floplk_l1                ; alles in Ordnung
 moveq    #10,d7                   ; Track #10 anfahren
 bsr      _hseek
 bne.b    floplk_l2                ; Fehler
 bsr      _seek0                   ; Track #0 anfahren
 beq.b    floplk_l1                ; OK
floplk_l2:
 move.w   #$ff00,dsb_track(a1)     ; Fehler: Track ungueltig
floplk_l1:
 rts

     IFNE DEBUG2
failss: DC.B     $d,$a,'FAIL',$d,$a,0
     EVEN
     ENDIF

flopfail:
     IFNE DEBUG2
 movem.l  d0-d2/a0-a2,-(sp)
 lea      failss(pc),a0
 bsr      putstr
 movem.l  (sp)+,d0-d2/a0-a2
     ENDIF
 moveq    #1,d0
 bsr      setdmode
 move.w   _cerror,d0
 ext.l    d0
 bra.b    flopfl_l1

flopok:
 moveq    #0,d0                    ; kein Fehler
flopfl_l1:
 move.l   d0,-(sp)
 bsr      cache_invalid
 move.w   #$86,(a6)
 move.w   (a1),d7
 bsr      d7_todma
 bsr      flopcmds_10

 move.l   _hz_200,d0               ; #### NEU
 add.l    #1000,d0                 ; #### NEU: 5s nach letztem Zugriff
 move.l   d0,flp_led_out           ; #### NEU

 move.w   cdev,a0
 adda.w   a0,a0
 adda.w   a0,a0                    ; *4 fuer Langwortzugriff
 move.l   _frclock,wplatch+2(a0)   ; acctim, _frclock letzten Zugriffs
 cmpi.w   #1,_nflops
 bne.b    flopfl_l2
 move.l   _frclock,wplatch+6       ; acctim fuer virtuelles Laufwerk B:
flopfl_l2:
 move.l   (sp)+,d0
* TT-RAM-Unterstuetzung ("Nachsorge")
 move.w   flp_fstcnt,d1       ; Anzahl Sektoren
 beq.b    flopfl_l3           ; keine
 bsr      cache_invalid
 clr.w    flp_fstcnt          ; ist erledigt
 movea.l  flp_fstbuf,a0       ; Zieladresse
 movea.l  ptr_frb,a1
flp_fstcpy:
 lsl.w    #4,d1               ; Sektoren in 32-Byte-Bloecke
 subq.w   #1,d1               ; einer weniger
flopfl_cpyloop:
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 dbf      d1,flopfl_cpyloop        ; Daten umkopieren
flopfl_l3:
 rts


************************************************************
*
* Schickt Kommando SEEK ohne Verify und mit SpinUp an
* den FDC (d.h. Spur ctrack wird angefahren).
* Rueckgabe: NZ und C     Fehler bei flopcmds
*           Z  und NC    OK
*

hseek:
 move.w   ctrack,d7
;bra      _hseek

************************************************************
*
* Schickt Kommando SEEK ohne Verify und mit SpinUp an
* den FDC (d.h. Spur wird angefahren).
* Rueckgabe: NZ und C     Fehler bei flopcmds
*           Z  und NC    OK
*
* Eingabe: d7 = Tracknummer
*          a1/a6 = dsb/diskctl
*

_hseek:
 move.w   #E_SEEK,_cerror
 move.w   #$86,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Data-Register
 bsr      d7_todma                 ; FDC-Data-Register := neue Spurnummer
 bra      flopcmds_10              ; Kommando an den FDC


************************************************************
*
* Sucht die aktuelle Spur nach Kopfzittern nochmal auf.
*
* Geht nach Spur 0
*           Spur 5
*           Spur ctrack
*
*

again_go2track:
 move.w   #E_SEEK,_cerror
 bsr      _seek0                   ; Spur 0 anfahren
 bne      aggtt_loop                ; Fehler
 clr.w    dsb_track(a1)            ; OK, Tracknummer aktualisieren
 move.w   #$82,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Track-Register
 clr.w    d7
 bsr      d7_todma                 ; FDC-Track-Register auf 0
 move.w   #$86,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Data-Register
 moveq    #5,d7                    ; Spur 5 ins Datenregister
 bsr      d7_todma                 ; FDC-Command-Register beschreiben
 bsr      flopcmds_10              ; seek, SpinUp, kein Verify
 bne.b    aggtt_loop                ; Fehler
 move.w   #5,dsb_track(a1)         ; Tracknummer aktualisieren
;bra      go2track


**********************************************************************
*
* Rueckgabe: Carry = fataler Fehler
*           NE    = Fehler, ggf. nochmal versuchen
*

go2track:
 moveq    #$14,d6             ; seek mit SpinUp UND VERIFY
_go2track:
 move.w   #1,-(sp)            ; (erster Versuch)
go2_loop:
 move.w   #E_SEEK,_cerror
 move.w   #$86,(a6)           ; Bit 8  : DMA auf Lesen
                              ; Bit 4  : FDC selektieren
                              ; Bit 1/2: FDC-Data-Register
 move.w   ctrack,d7           ; Spur ctrack ins Datenregister
 bsr      d7_todma
 bsr.b    flopcmds            ; Kommando d6 an den FDC

 bcs.b    gtt_l1           ; Carry: boeser Fehler

 and.b    #$18,d7             ; CRC- Fehler ?
 beq.b    gtt_l2           ; nein, OK und Ende

 cmpi.b   #2,machine_type
 bcs.b    gtt_l3           ; NE und NC zurueckgeben

 tst.b    hd_flag
 bne.b    is_hd_1
 move.w   #0,M_fdc_hdmode
 clr.w    dsb_hdmode(a1)
 bra      gtt_l3
is_hd_1:

 move.w   dsb_hdmode(a1),d0
 and.w    #3,d0
 eori.w   #3,d0
 move.w   d0,M_fdc_hdmode     ; DD/HD umschalten
 move.w   d0,dsb_hdmode(a1)   ; DD/HD im DSB merken
 subq.w   #1,(sp)
 bne.b    gtt_l3           ; schon zweiter Versuch, NE zurueckgeben
 bsr.b    _seek0              ; nochmal nach Spur 0
 bra.b    go2_loop            ; und nochmal versuchen
gtt_l2:
 move.w   ctrack,dsb_track(a1)
 clr.w    d7                  ; kein Fehler
gtt_l3:
 tst.w    d7                  ; Carry loeschen
gtt_l1:
 addq.w   #2,sp
aggtt_loop:
 rts


**********************************************************************
*
* fgo2track()
*
* "go2track()" fuer Fastload. Wird bei Lesen/Verifizieren aufgerufen
* Mit Setzen von Bit 4 des Konfigurationsbytes ueber Sconfig() kann
* Fastload ausgeschaltet werden.
*

fgo2track:
 btst     #4,config_status+3
 bne.b    go2track                 ; Bit 4 != 0 ==> Originalroutine
 moveq    #$10,d6                  ; Seek ohne Verify
 bra.b    _go2track


************************************************************
*
* Schickt Kommando RESTORE ohne Verify und mit SpinUp an
* den FDC (d.h. Spur 0 wird angefahren).
* Rueckgabe: NZ und C     Fehler bei flopcmds
*           NZ und NC    Fehler bei Restore (Track nicht bei 0)
*           Z  und NC    OK
*

_seek0:
 clr.w    d6             ; Restore ohne Verify, mit SpinUp
 bsr.b    flopcmds       ; Kommando an den FDC
 bne.b    seek0_l1      ; Fehler
 btst     #2,d7          ; Kopf ueber Spur 0 ?
 eori     #4,ccr         ; Z-Flag invertieren (Z=OK/NZ=Error)
 bne.b    seek0_l1      ; Fehler
 clr.w    dsb_track(a1)  ; DSB aktualisieren
seek0_l1:
 rts

seek0_table:     DC.B 1,1,0,0
     EVEN

flopcmds_10:
 moveq    #$10,d6        ; Seek
                         ; erst Motor starten
                         ; kein Verify


************************************************************
*
* Schickt ein Kommando des Typs I an den FDC.
* Wartet, bis das Kommando verarbeitet wurde (busy).
*
* Eingabe:     a6 = dma_diskctl
*              a1 = dsb
*              d6 = Bit 2..7 des FDC-Kommandos
*                   %0000hv00      Restore
*                   %0001hv00      Seek
*                   %001uhv00      Step
*                   %010uhv00      Step-in
*                   %011uhv00      Step-out
*                   v    Verify
*                   h    0=erst Motor starten
*                   u    Update des Track-Registers
*
* Rueckgabe:    C-Flag: Fehler
*              d7 = FDC-Status-Register
*              d6 = 0  OK
*              d6 = -1 Fehler
*
* Schaltet den FDC-Takt entsprechend DD/HD um.
* Bit 0/1 des Kommandobytes enthalten dabei die seekrate.
* Ein Fehler setzt den FDC zurueck und gibt C-Flag zurueck.
*

flopcmds:
 move.w   dsb_seekrate(a1),d0
 and.b    #3,d0                    ; sicherheitshalber auf 0..3 kuerzen
 tst.b    hd_flag
 beq.b    flc_st                   ; Rechner kann kein HD

 tst.w    dsb_hdmode(a1)           ; HD ?
 beq.b    flpcmds_l3                ; nein, wie TOS 1.x
 lea      seek0_table(pc),a0         ; DC.B 1,1,0,0
                                   ; 6  ms => 12 ms
                                   ; 12 ms => 12 ms
                                   ; 2  ms => 6  ms
                                   ; 3  ms => 6  ms
 move.b   0(a0,d0.w),d0            ; seekrate fuer HD anpassen!
flpcmds_l3:
 move.w   dsb_hdmode(a1),M_fdc_hdmode   ; FDC- Takt umschalten

flc_st:
 or.b     d0,d6                    ; Steprate (Bit 0/1)
 move.l   flptimeout,d7            ; normalerweise 1,5s
 move.w   #$80,(a6)                ; Bit 8  : DMA auf Lesen
                                   ; Bit 4  : FDC selektieren
                                   ; Bit 1/2: FDC-Status bzw. FDC-Command
 bsr      dma_tod0                 ; d0 = FDC-Status
 btst     #7,d0                    ; Motor on ?
 bne.b    flpcmds_l1                ; ja, 1,5s TimeOut
 add.l    d7,d7                    ; nein, 3s TimeOut
flpcmds_l1:
 bsr      d6_todma                 ; FDC-Command-Register beschreiben
 move.l   d7,d0
 bsr      wait_FDC
 bne.b    flpcmds_l2                ; TimeOut
 bsr      dma_tod7                 ; FDC- Status-Register auslesen
 clr.w    d6                       ; Carry loeschen
 rts
flpcmds_l2:
 moveq    #0,d6
 subq.w   #1,d6                    ; Carry setzen
 rts


************************************************************
*
* Setzt den FDC per "force interrupt" zurueck.
*
*  Eingabe:    a6 = $ffff8606  (dma_fifo)
*              a1 = dsb
*
*  Ausgabe:    d7 = FDC- Status
*

_resetfdc:
 move.w   #$80,(a6)           ; Bit 8  : DMA auf Lesen
                              ; Bit 4  : FDC selektieren
                              ; Bit 1/2: FDC-Status bzw. FDC-Command
 move.w   #$d0,d7             ; FORCE INTERRUPT
                              ;  ohne Unterbrechungs- Signalisierung
 bsr      d7_todma            ; Kommando ins FDC-Command-Register
* Nach "force interrupt" muss 16 us gewartet werden
 moveq    #2,d0               ; 3 Durchlaeufe
_rstfdc_loop2:
 move.b   tcdr,d1             ; Timer C Data Register
_rstfdc_loop:
 cmp.b    tcdr,d1             ; gleich ?
 beq.b    _rstfdc_loop           ; ja, weiter
 dbf      d0,_rstfdc_loop2        ; dreimal

 bra      dma_tod7            ; FDC- Status auslesen


************************************************************
*
* Selektiert das in cdev angegebene Floppylaufwerk und
* die in cside angegebene Diskettenseite.
* Setzt das FDC-Track-Register aus dem DSB
* Setzt das FDC-Sector-Register aus csect
* Setzt das DMA-Adressregister aus cdma
*
*  Eingabe:    a6 = $ffff8606  (dma_fifo)
*              a1 = dsb
*

_select:
 sf       deslflg
 move.w   cdev,d0             ; A = %00000000 B = %00000001
 addq.b   #1,d0               ; A = %00000001 B = %00000010
 lsl.b    #1,d0               ; A = %00000010 B = %00000100
 or.w     cside,d0            ; A = %0000001s B = %0000010s
 eori.b   #7,d0
 and.b    #7,d0               ; A = %0000010s B = %0000001s
 bsr.b    setporta_flp
 move.w   #$82,(a6)           ; DMA auf Lesen
                              ; FDC selektieren
                              ; FDC-Track-Register selektieren
 move.w   dsb_track(a1),d7
 bsr.b    d7_todma            ; FDC-Track-Register aus dem DSB
;bra      fdc_set_sec_adr


************************************************************
*
* Setzt das FDC-Sector-Register aus csect
* Setzt das DMA-Adressregister aus cdma
*
*  Eingabe:    a6 = $ffff8606  (dma_fifo)
*              a1 = dsb
*

fdc_set_sec_adr:
 move.w   #$84,(a6)           ; DMA auf Lesen
                              ; FDC selektieren
                              ; FDC-Sector-Register selektieren
 move.w   csect,d7
 bsr.b    d7_todma            ; FDC-Sector-Register aus dem DSB
 move.b   cdma+3,$ffff860d    ; DMA- Adresse setzen
 move.b   cdma+2,$ffff860b
 move.b   cdma+1,$ffff8609
 rts


**********************************************************************
*
* d2 = char setporta_flp(d0 = char setbits)
*
* Setzt einige der Bits 0/1/2 fuer die Floppysteuerung und gibt den
* alten Registerinhalt in d2 zurueck.
*

setporta_flp:
 move     sr,-(sp)
 ori      #$700,sr
 move.b   #$e,giselect             ; Soundchip Register 14 selektieren
 move.b   giread,d1                ; Register 14 (I/O Port A) auslesen
 move.b   d1,d2                    ; alten Wert merken
 and.b    #$f8,d1                  ; Bits 0/1/2 loeschen
 or.b     d0,d1                    ; neue Bits setzen
 move.b   d1,giwrite               ; Register schreiben
 move     (sp)+,sr
 rts

d6_todma:
 bsr.b    dma_delay
 move.w   d6,$ffff8604
 rts                               ; TOS 2.05
d7_todma:
 bsr.b    dma_delay
 move.w   d7,$ffff8604
 rts                               ; TOS 2.05

dma_tod7:
 bsr.b    dma_delay
 move.w   $ffff8604,d7
 rts                               ; TOS 2.05

dma_tod0:
 bsr.b    dma_delay
 move.w   $ffff8604,d0
 rts                               ; TOS 2.05: "rts"

dma_delay:
 movem.l  d0/d1,-(sp)              ; TOS 2.05
 cmpi.w   #20,cpu_typ              ; CPU hat einen Befehlscache ?
 bcs.b    _dma_delay               ; nein, normal weiter
 movec.l  cacr,d0
 bset     #3,d0                    ; Instruction cache invalid
 movec.l  d0,cacr
_dma_delay:
 moveq    #2,d0
dmadelay_loop1:
 move.b   tcdr,d1                   ;Timer C Data Register
dmadelay_loop2:
 cmp.b    tcdr,d1
 beq.b    dmadelay_loop2
 dbf      d0,dmadelay_loop1
 movem.l  (sp)+,d1/d0
 rts


*********************************************************************
*
* EQ/MI long _tstchng( a0 = int *dev )
*
* Wird zu Beginn von _Floprd/wr/ver/fmt aufgerufen.
* Managet den Diskwechsel A/B.
* In Mag!X wird auch Bereichsueberpruefung vorgenommen, leider in
* TOS 3.06 nur unvollkommen geloest
*

_tstchng:
 move.w   _nflops,d1
 beq.b    _tstc_eundev             ; ueberhaupt kein Laufwerk da
 move.w   (a0),d0                  ; angewaehltes Laufwerk
 cmpi.w   #1,d0
 bhi.b    _tstc_eundev             ; ist weder A: noch B:
 subq.w   #1,d1
 bne.b    _tstc_ok                 ; habe zwei Laufwerke
 cmp.w    current_disk,d0          ; habe nur ein Laufwerk
 beq.b    _tstc_a                  ; aber ich muss jetzt nicht wechseln
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 move.w   #$ffef,-(sp)             ; EOTHER
 bsr      critical_error
 addq.w   #4,sp
 move.l   (sp)+,a0
 lea      wplatch,a1
 move.w   #-1,(a1)+
 clr.l    (a1)+
 clr.l    (a1)
 move.w   (a0),current_disk
_tstc_a:
 clr.w    (a0)                     ; ab hier immer A: vorgaukeln
_tstc_ok:
 moveq    #0,d0                    ; kein Fehler
 rts
_tstc_eundev:
 moveq    #EUNDEV,d0
 rts

setdmode_2:
 moveq    #2,d0
setdmode:
 lea      mediach_statx,a0
 move.b   d0,-(sp)
 move.w   cdev,d0

 cmpi.w   #1,_nflops               ; TOS 2.05
 bne.b    setdmd_l1                ; TOS 2.05
 move.w   current_disk,d0          ; TOS 2.05
setdmd_l1:

 move.b   (sp)+,0(a0,d0.w)         ; drive change Modus setzen
 rts


**********************************************************************
*
* int Floprate( int devno, int rate )
*

Floprate:
 move.w   (a0)+,d0
 bmi.b    flprt_spec
 bsr      _dsb_toa1
 addq.l   #dsb_seekrate,a1
 move.w   (a1),d0                  ; alter Wert
 move.w   (a0),d1                  ; neuer Wert
 cmpi.w   #-1,d1
 beq.b    flprt_ende               ; -1, nur holen
 move.w   d1,(a1)                  ; setzen
flprt_ende:
 ext.l    d0
 rte
flprt_spec:
 addq.w   #1,d0
 bne.b    flprt_err
; Unterfunktion -1: Floppy-Timeout setzen
 move.l   flptimeout,d0            ; alter Wert
 moveq    #0,d1
 move.w   (a0),d1
 bmi.b    flprt_rte
 move.l   d1,flptimeout
flprt_rte:
 rte
flprt_err:
 moveq    #EBADRQ,d0
 rte
