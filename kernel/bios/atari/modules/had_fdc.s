**********************************************************************
**************     Floppy- Treiber fuer Hades     *********************
**************         anstelle von FDC.S        *********************
**********************************************************************

/*
*
* wird beim Booten aufgerufen, um die Floppies zu deselektieren
*
*/

boot_dsel_floppies:
 rts                     ; gibt es wohl beim Hades nicht ?!?


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

/*
*
* Ab hier der Code von Alvar...
*
*/

; zu testen:
; _Flopver, _Floprd, _Flopwr -- kann das so klappen?!? Wohl NICHT, Grrr!

;**********************************     flopini    Laufwerk initialisieren) S.113    ***
flopini:  
               lea  dsb0.w,A1           ;Disk Status Block setzen
               tst.w     12(A7)              ;dev=0?
               beq.s     flopini1       ;ja->
               lea  dsb1.w,A1
;-------------------------------------------------
flopini1: lea       wpstat.w,a0                             ;status auf diskette gewechselt
               move.l    #-1,(a0)                           ;beide laufwerke    
               move.w    seekrate.w,dsb_seekrate(A1)
               move.w    #defhdinf,dsb_hdmode(a1)           ;dsb_hdmode auf default

               move.w    #-256,dsb_track(A1)                ;*negativ, damit restore ausgefuehrt wird
               moveq     #-1,d0                                  ;def error
               bsr  floplock                                ;*incl. select0 und restore
               bne  flopfail                                ;*
;sense drive status
               moveq     #4,d7
               bsr       sendcom
               bmi       flopfail
               move.w    cdev.w,d7
               bsr       sendcom
               bmi       flopfail
               moveq     #0,d3
               bsr       holdata
               bmi       flopfail
               move.b    status_buffer.w,d0
               and.b     #$50,d0             ;track00 oder wp
               beq       flopfail
               bra  flopok              ;*

;------------------------------------------------------------------------------
;*********************** no_flops  keine Floppies vorhanden (Neu ggue. 2.06)     ***
no_flops: moveq     #-15,D0
               rts
;****************************** floplock  Floppy Parameter uebernehmen S.119     ***
;hades

floplock: 
          movem.l   D1-D7/a2-a3,regsave ;.w
          move.w    D0,_deferror.w
          move.w    D0,_cerror.w
          move.l    8(A7),a3                ;a3 zeigt auf buffer
          move.l    a3,cbuffer.w
          move.w    14(a7),verifyflag.w
          move.w    16(A7),cdev.w
          move.w    18(A7),d4               ;startsector nach d4
          move.w    d4,csect.w
          move.w    20(A7),ctrack.w
          move.w    22(A7),cside.w
          move.w    24(A7),ccount.w
          move.w    #2,_rtrycnt.w
;-------------------------------------------------
          lea  dsb0.w,A1      ;Disk Status Block setzen
          tst.w     cdev.w
          beq  flplock1
          lea  dsb1.w,A1
;-------------------------------------------------
flplock1: tst.w     dsb_track(A1)       ;dsb[devno].curtrack
          bpl  lock_rts       ;positiv? dann fertig
;-------------------------------------------------
          bsr  select0             ;negativ? dann restore
          bsr  restore             ;Track 0
          beq  end_ok
          move.w    #-1,dsb_track(A1)
end_err:    
              moveq #-1,d0              ;fehler
            rts                             ;zurueck
;************************************* flopfail  Fehler     in Floppy Routine aufgetreten S.120     ---
flopfail: 
          bsr  fdc_reset
          moveq     #1,D0
          bsr  setdmode
          move.w    _cerror.w,D0
          ext.l     D0
          bra  flopok1
;*************************************** flopok   Floppy Routine fehlerfrei beendet S.120 ---

flopok:
               clr.l     D0
flopok1:  move.l    D0,-(A7)
;-------------------------------------------------
          tst.b     motoronflg.w                 ;motor aus?
          beq  flopok3                 ;ja ->
          move.l    _hz_200.w,D0
          add.l     #1000,D0       ;Nachlaufzeit 5 sec
          move.l    D0,flp_led_out.w
          move.b    #$3e,ldor      ;select aus,motor bleibt on

flopok3:  move.w    cdev.w,D0
          lsl.w     #2,D0
          lea       wplatch+2.w,A0
          move.l    _frclock.w,0(A0,D0.w)    ;Zugriffszeitpunkt
          cmp.w     #1,_nflops.w        ;merken
          bne.s     flopok2
          move.l    _frclock.w,4(A0)
;-------------------------------------------------
flopok2:  move.l    (A7)+,D0
          movem.l   regsave.w,D1-D7/a2-a3
lock_rts: rts
;******************************************************* Xbios(41) Floprate     ***
;         PART 'floprate'
Floprate: lea  dsb0,A1                  ;.w A1    zeigt auf DSB
          tst.w     4(A7)                    ;von Laufwerk A:
          beq.s     floprat1
          lea  dsb1,A1                  ;.w oder Laufwerk B:
;-------------------------------------------------
floprat1: move.w    dsb_seekrate(A1),D0           ;alte seekrate holen
          move.w    6(A7),D1            ;Parameter vom Stack
          bmi  floprat2            ;get log_seekrate
          move.w    D1,dsb_seekrate(A1)           ;set log_seekrate
          lea  steptab(pc),a0
          and.w     #3,d1
          moveq     #3,d7                    ;specify
          bsr  sendcom
          bmi  floprat2
          move.b    0(a0,d1.w),d7            ;steprate, head unload time
          bsr  sendcom
          bmi  floprat2
          moveq     #hlt*2+1,d7              ;head load time, non dma
          bsr  sendcom
floprat2: ext.l     D0
          rts
steptab:  dc.b      hut/8+$40,hut/8+$20,hut/8+$C0,hut/8+$a0
;                       6         7         2         3 ms   steprate
;**************************************** restore Kopf auf Track 0 positionieren S.121    ---
restore:
               moveq     #$03,d7             ;specify
               bsr  sendcom             ;send command
               bmi  end_err
               lea  steptab(pc),a2          ;seekrate wandeln
               move.w    dsb_seekrate(a1),d7
               and.w     #3,d7
               move.b  0(a2,d7.w),d7           ;steprate und head unload time
               bsr  sendcom
               bmi  end_err
               moveq     #hlt*2+1,d7         ;head load time, non dma
            bsr     sendcom
            bmi     end_err
;recalibrate
               moveq     #$07,D7             ;*FDC Kommando "recalibrate"
               bsr  sendcom
               bmi  end_err
               move.w    cdev.w,d7             ;laufwerksnummer
               bsr  sendcom
               bmi  end_err
;int status
               bsr  int_status          ;interrupt status erfragen
               bmi  end_err
               move.b    status_buffer.w,d0
               and.b     #$e0,d0
               cmp.b     #$20,d0
               bne       end_err
               bra  end_ok

;--------------------------------- laufwerk interrupt status erfragen
int_status:    bsr  wait_int       ;auf interrupt warten
               bmi  end_err
               moveq     #$08,d7             ;sense interrupt status
               bsr  sendcom
               bmi  end_err
               moveq     #1,d3          ;2 byts holen
               bsr  holdata
               bmi  end_err
               clr.l     d0
               move.b  status_buffer+1.w,d0
               move.w    d0,dsb_track(a1)         ;aktueller track setzen
               moveq     #0,d0
               rts
;--------------------------------- sende daten in d7 nach fdc
sendcom:
               move.l    _hz_200.w,d6
               add.l     #100,d6                 ;0.5 sec
sdloop:        cmp.l     _hz_200.w,d6        ;zeit abgelaufen?
               bcs       end_err                       ;ja
          move.b    main_status,d0      ;status
          and.b   #$e0,d0               ;maske
          cmp.b     #$80,d0             ;bereit
          bne       sdloop              ;nein->
               move.b    d7,data_reg
               bsr       wait_mast
               bra       end_ok
;--------------------------------- status holen anzahl byts in d3
holdata:  lea  status_buffer.w,a2            ;
holdatl:  move.l    _hz_200.w,d6
               add.l     #100,d6                 ;0.5 sec
               bsr  wait_mast
hdloop:        cmp.l     _hz_200.w,d6
               bcs  end_err                            ;wenn zeit abgelaufen->
               move.b    main_status,d0
               and.b     #$e0,d0
               cmp.b     #$c0,d0                       ;status bereit?
               bne  hdloop                             ;nein->
               move.b    data_reg,(a2)+           ;statusdaten holen
               bsr  wait_mast
               dbf  d3,hdloop
               bra  end_ok
;--------------------------------- wait auf interrupt
wait_int: move.l    _hz_200.w,d6
               add.l     #200,d6                       ;1 sec warten
wait_int1:  cmp.l   _hz_200.w,d6             ;zeit abgelaufen?
            bcs     end_err                            ;ja->
               btst #4,GPIP_TT.w             ;int?
            beq     wait_int1                     ;nein nochmal->
end_ok:   
               moveq     #0,d0                         ;kein fehler
            rts                    ;zurueck
;-----------------------------------wait bis master status register valid
wait_mast:     moveq     #48,d0              ; --     -- ED=6us HD=12us DD=24us
               cmp.b     #dd,dsb_hdmode+1(a1)     ;dd?
               beq  wait_mastl              ;ja->
               moveq     #12,d0
               cmp.b   #ed,dsb_hdmode+1(a1)  ;ed?
               beq  wait_mastl              ;ja->
wait6us:  moveq     #24,d0                  ;sonst dd
wait_mastl:    tst.b     $fffffc00.w             ;dauert 0.5us wenn folgend
               dbf  d0,wait_mastl
               rts
;************************************ fdc_reset
fdc_reset:     lea       wpstat.w,a0                        ;status auf diskette gewechselt
               move.l    #-1,(a0)                      ;beide laufwerke    
               move.w    #defhdinf,dsb_hdmode(a1)    ;dsb_hdmode auf default
               move.b    #$0A,ldor                     ;softreset, irq aktiv
               move.l    _hz_200.w,d6
               add.l     #40,d6                             ;0.2 sec
fdc_res2:   cmp.l   _hz_200.w,d6             ;zeit abgelaufen
            bcc     fdc_res2                      ;nein->
               move.b  #$0E,ldor
               clr.b     motoronflg.w                  ;motor ist aus
fdc_res_rts:rts
;***************************** select taktrate  Laufwerk motor on
select0:  move.b    dsb_hdmode+1(a1),ldcr    ;takt setzen
               move.w    cdev.w,D0                ;laufwerk nummer
               add.b     #$3C,d0                  ;motoren on kein softreset
               move.b  d0,ldor                         ;setzen
               tst.b     motoronflg.w
               bne  select0_rts                        ;ja
          move.l    _hz_200.w,d6
          add.l     #100,d6                  ;0.5 sec motoranlaufzeit
sel1:          cmp.l     _hz_200.w,d6            ;abgelaufen
               bcc  sel1                    ;nein->
          bsr  restore             ;zum anfang
               move.b    #1,motoronflg.w              ;moton on
select0_rts:rts
;***************************************** flopvbl Floppy VBL-Handler S.118     ***
;         PART 'flopvbl'
floppy_vbl:    tst.w     _nflops.w
               beq  vbl_rts
               tst.w     flock.w             ;aktiv?
               bne  vbl_rts             ;ja->
;------------------------------------------ test auf diskettenwechsel ueber wp
               move.l    _frclock.w,D1
               move.b    D1,D0
               and.b     #7,D0                   ;8. vbl ?
               bne.s     vbl_rts                 ;nein -> 
;-------------------------------------------------
               lsr.b     #3,D1                           ;
               and.w     #1,D1                                   ;abwechslungsweise Laufwerk A: oder B: 0 or 1
               lea       wpstat.w,A0
               add.w     D1,A0                           ;floppy A byt 0. floppy B byt 1
               cmp.w     _nflops.w,D1                    ;floppy B und vorhanden? wenn nur 1 und ist 1 (nur lw A)
               bne.s     vbl1                            ;nein -> lw B vorhanden
               clr.w     D1                              ;sonst lw A
;-------------------------------------------------
vbl1:          lea       dsb0.w,a1
          tst.b     d1                                      ;lw B
          beq       vbl3
          lea       dsb1.w,a1
vbl3:          move.b    #$3c,d6
               add.w     d1,d6                           ;+lw
               move.b    d6,ldor                                 ;floppy on
               moveq     #4,d7                                   ;sense drive status
               bsr       sendcom
               move.w    d1,d7                           ;lw
               bsr       sendcom
               moveq     #0,d3                                   ;1 byt holen
               bsr       holdata
               btst #6,status_buffer.w                 ;H=Schreibgeschuetzt
          sne       (a0)                            ;wpstat setzen
          beq       vbl2                            ;nicht gewechselt resp. nicht wp
               move.w    #defhdinf,dsb_hdmode(a1)           ;dsb_hdmode auf default
;-------------------------------------------------
vbl2:          move.w    wpstat.w,D0                   ;
               or.w D0,wplatch.w                       ;wenn gewechselt auf gewechselt oder halten
          tst.b     motoronflg.w                    ;motor on?
          beq  vbl4                               ;nein
;------------------------------------------------- motor abstellen ?
               move.l    _hz_200.w,D0
               cmp.l     flp_led_out.w,D0                   ; waehrend Nachlaufzeit   ...
               bcs.s     vbl5                         ;nein nicht abstellen
;-------------------------------------------------
vbl4:          move.b  #$0E,ldor             ;alle LW abschalten
               clr.b     motoronflg.w
vbl_rts:  rts
vbl5:          move.b    #$3e,ldor
               rts
;********************************* seek_cur   aktuellen Track anfahren S.120    ***
;         PART 'flopseek'
;-------------------------------------------- homeseek Home und Seek S.120 ---
homeseek: move.w    #-6,_cerror.w
               bra  restore
;---------------------------- seek_ver  aktuellen Track     anfahren mit Verify ---
seek_ver: move.w    #-6,_cerror.w
;-------------------------------------------------
               moveq     #$0f,d7                       ;seek
               bsr  sendcom
               bmi  end_err
               move.w    cside.w,d7                    ;side
               lsl.w     #2,d7                           ;nach bit 2
               add.w     cdev.w,d7                     ;+lw nr.
               bsr  sendcom
               bmi  end_err
               move.w    ctrack.w,D7                   ;track
               bsr  sendcom
               bmi  end_err
            bsr     int_status
            bmi     end_err
               move.w    ctrack.w,d0                   ;soll
               cmp.w     dsb_track(A1),d0              ;richtig?
               beq  end_ok
               bra  end_err
;**********************************     change    Test auf Diskettenwechsel bei einem lw S.123 ***
*
* EQ/MI long _tstchng( a0 = int *dev )
*
* Wird zu Beginn von _Floprd/wr/ver/fmt aufgerufen.
* Managet den Diskwechsel A/B.
* In Mag!X wird auch Bereichsueberpruefung vorgenommen, leider in
* TOS 3.06 nur unvollkommen geloest
*

change:
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

setdmode:
 lea      mediach_statx,a0
 move.b   d0,-(sp)
 move.w   cdev.w,d0

 cmpi.w   #1,_nflops               ; TOS 2.05
 bne.b    setdmd_l1           ; TOS 2.05
 move.w   current_disk,d0          ; TOS 2.05
setdmd_l1:

 move.b   (sp)+,0(a0,d0.w)         ; drive change Modus setzen
 rts

;**************************************************** Xbios(8,9,19) Floprd,Flopwr,Flopver S.113     ***
;------------------------------------------------- daten transfer VOM fdc
fdc_rdint:  bclr    #6,$fffffa89.w                  ;int off
               movem.l   a0/d0-d1,-(sp)                  ;register sichern
            move.l  cbuffer.w,a0                    ;transferadresse
            move.w  #512,d0                         ;1 sector a 512 byts
fdc_rdint2:    btst #4,GPIP_TT.w                       ;daten?
            beq     fdc_rdint3                                   ;nein -> ende daten oder error
            move.b  data_reg,(a0)+                     ;daten transportieren
               subq.w    #1,d0                           ;-1
               beq  fdc_rdint1                         ;wenn 0 dann ende
               moveq     #100,d1                         ;timeout 50us
fdc_rdint3:    tst.b     $fffffc00.w                             ;0.5us warten
               dbf       d1,fdc_rdint2
fdc_rdint1:    move.l    a0,cbuffer.w
               movem.l (sp)+,a0/d0-d1
               bclr #6,$fffffa91
               rte
;------------------------------------------------- daten transfer ZUM fdc
fdc_wrint:  bclr    #6,$fffffa89.w                  ;int off
               movem.l   a0/d0-d1,-(sp)                  ;register sichern
            move.l  cbuffer.w,a0
            move.w  #512,d0                         ;1 sector a 512 byts
fdc_wrint2:    btst #4,GPIP_TT.w                       ;daten?
            beq          fdc_wrint3                              ;nein -> ende daten oder error
            move.b  (a0)+,data_reg                     ;daten transportieren
               subq.w    #1,d0                           ;-1
               beq       fdc_wrint1                      ;wenn 0 dann ende
               moveq     #100,d1                         ;timeout 50us
fdc_wrint3:    tst.b     $fffffc00.w                             ;0.5us warten
               dbf       d1,fdc_wrint2
fdc_wrint1:    move.l    a0,cbuffer.w
               movem.l (sp)+,a0/d0-d1
               bclr #6,$fffffa91
               rte
;------------------------------------------------- daten transfer per interrupt VOM fdc fuer verify
fdc_vrint:  bclr    #6,$fffffa89.w                  ;int off
               movem.l   a0/d0-d2,-(sp)                  ;register sichern
            move.l  cbuffer.w,a0
            move.w  #512,d0                         ;1 sector a 512 byts
fdc_vrint2:    btst #4,GPIP_TT.w                       ;daten?
            beq          fdc_vrint3                              ;nein -> ende daten oder error
            move.b  data_reg,d2                             ;daten holen
               tst.w     verifyflag.w                       ;sectortest?
               beq       fdc_vrint4
               cmp.b     (a0)+,d2                           ;daten vergleichen
               beq       fdc_vrint4                      ;ok gleich->
               move.b    #2,rwflag+1.w                 ;sonst fehler setzen
fdc_vrint4:    subq.w    #1,d0                         ;-1
               beq       fdc_vrint1                      ;wenn 0 dann ende
               moveq     #100,d1                         ;timeout 50us
fdc_vrint3: tst.b   $fffffc00.w                             ;0.5us warten
               dbf       d1,fdc_vrint2
fdc_vrint1:    move.l    a0,cbuffer.w
               movem.l (sp)+,a0/d0-d2
               bclr #6,$fffffa91
               rte
;-----------------------------------------------------------------------------------------

Floprd:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr.b    _Floprd
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte

;-----------------------------------------
_Floprd:
               clr.w     rwflag.w            ;auf lesen
               move.l    #fdc_rdint,$158.w        ;vector setzen

floprdwr: tst.w     _nflops.w
               beq  no_flops
                
               lea  12(a7),a0                ;dev
               bsr  change
               move.w    #-11,_cerror.w
floprd11: bsr  floplock
            tst.b   rwflag.w            ;write
            beq     floprd1                         ;nein->
;-------------------------------------------------  nur write
               move.w    csect.w,D0               ;Zugriff auf Boosektor?
               subq.w    #1,D0
               or.w ctrack.w,D0
               or.w cside.w,D0
               bne.s     floprd13
               moveq     #2,D0
               bsr  setdmode            ;...dann chg_mode[dev]=2
floprd13: move.w    #-10,_cerror.w
;-------------------------------------------------
floprd1:    bsr     select0
               bsr  seek_ver
               bmi  floprd5                  ;error -> end evt. nochmal
;------------------------------------------------- floppy read,write,scan commando
;init int
floprd2:  move.l    cbuffer.w,d5                    ;start sichern
               bset #4,$fffffa83.w                     ;int bei low to high
               bclr #6,$fffffa8d.w                     ;interrupt pending loeschen
               bclr #6,$fffffa91.w                  ;in service loeschen
               bset #6,$fffffa95.w                  ;maske freigeben -> interrupt
               bset #6,$fffffa89.w                     ;int enable
;-----------------------------------------------------      

;---------------------------------------------------------
            moveq   #$46,d7                                 ;mfm read sectoren
            sub.b   rwflag.w,d7                     ;$45 fuer write
               bsr  sendcom
            move.w  cside.w,d7                    ;seite
            move.w  d7,d1
            lsl.w   #2,d7                         ;nach bit 2
            add.w   cdev.w,d7                     ;lw nr
            bsr     sendcom
            move.w  ctrack.w,d7                        ;tracknummer
            bsr     sendcom
            move.w  d1,d7                                   ;nochmal seite
            bsr     sendcom
            move.w  csect.w,d7                              ;secktor nr.
            move.w  d7,d1
            bsr     sendcom
            moveq   #2,d7                                   ;512 byt sektoren
            bsr     sendcom
            move.w  d1,d7                                   ;eot=gleicher sector
            bsr     sendcom
            moveq   #$1B,d7                                 ;gap length
            bsr     sendcom
            moveq   #-1,d7                             ;data length not valid
               bsr  sendcom
               move.l    _hz_200.w,d6
            add.l   #300,d6                                 ;1.5 sec warten
floprd3:  cmp.l     _hz_200.w,d6                    ;abgelaufen?
               bcs  floprd4
            btst    #6,$fffffa89.w                     ;int off? = kommando ende
            bne     floprd3                                ;nein
floprd4:  bclr #6,$fffffa89.w                  ;int disable
;-------------------------------------------------------
             moveq  #6,d3                           ;7 byt status lesen
            bsr          holdata
            bmi          floprd5
;-------------------------------------------------
               move.b    status_buffer+1.w,d0                    ;FDC Status register 1
               and.b     #$37,d0                                 ;relevante bits
               bne.s     floprd5                            ;wenn nicht null dann error
               tst.b     rwflag+1.w                                   ;verify?
               beq       floprd8                                      ;nein->
               tst.w     verifyflag.w                            ;setortest?
               beq       floprd8                                      ;ja->
               cmp.b     #1,rwflag+1.w                           ;daten gleich ?
               bne  floprd5                                 ;nein ->
;-------------------------------------------------
floprd8:  move.w    #2,_rtrycnt.w                           ;3 versuch
               addq.w    #1,csect.w                              ;naechster sector
               subq.w    #1,ccount.w                        ;anzahl -1
               bne  floprd2
               tst.b     rwflag+1.w                                   ;verify?
               beq  flopok                                  ;nein->
               tst.w     verifyflag.w                            ;sectortest
               bne       flopok                                       ;nein->
               clr.w     (a3)                               ;def. sector abschluss
               bra  flopok                   ;fertig
;-------------------------------------------------
floprd5:  move.l    d5,cbuffer.w                            ;alter start
               cmp.w     #1,_rtrycnt.w                           ;2.versuch
               bne       floprd9                                      ;nein->
               cmp.w     csect.w,d4                                   ;startsector?
               bne       floprd9                                      ;nein->
               tst.b     rwflag.w                                ;read?
               bne       floprd9                                      ;nein->
               tst.b     dsb_hdmode(a1)                               ;versuchszaehler = 0
               beq       floprd9                               ;ja->
               subq.b    #1,dsb_hdmode(a1)                            ;1 versuche weniger
               move.w    #2,_rtrycnt.w                           ;retry wieder auf 2
               cmp.b     #ed,dsb_hdmode+1(a1)                         ;ed?
               bne       noed                                    ;nein->
               move.b    #hd,dsb_hdmode+1(a1)                         ;ist ed weiter nach hd
               bra       floprd12
noed:          cmp.b     #dd,dsb_hdmode+1(a1)                         ;dd?
               bne       nodd                                    ;nein
               move.b    #ed,dsb_hdmode+1(a1)                         ;ist dd weiter nach ed
               bra       floprd12
nodd:          move.b    #dd,dsb_hdmode+1(a1)                         ;bleibt noch dd
floprd12: move.b    dsb_hdmode+1(a1),ldcr                        ;takt setzen
               bsr       restore                                 ;alles auf anfang
               bra       floprd1                                      ;mit andererm takt probieren
floprd9:  bsr.s     errbits                                      ;Fehlerbehandlung
floprd6:  cmp.w     #1,_rtrycnt.w
               bne.s     floprd7
               bsr       homeseek
floprd7:  subq.w    #1,_rtrycnt.w
               bpl       floprd2                                      ;nochmal versuchen
               tst.b     rwflag+1.w                                   ;verify?
               beq       flopfail                                ;nein->
               tst.w     verifyflag.w                            ;sectortest?
               bne       flopfail                                ;nein-> error end
               move.w    csect.w,(a3)+                        ;defekter sector eintragen
               bra       floprd8                                      ;und naechster
;************************************ errbits  Fehlernummer bestimmen S.114     ***
errbits:  moveq     #-13,D1                       ;write protect
          btst #1,d0
          bne.s     errbits1

          moveq     #-8,D1                        ;sektor error
          btst #0,d0               
          bne.s     errbits1

          moveq     #-6,D1                        ;seek error
          btst #1,status_buffer+2.w          ;st2
          bne.s     errbits1

          moveq     #-4,D1                        ;crc error
          btst #5,D0
          bne.s     errbits1

          moveq     #-2,D1              ;timeout
          btst #4,D0                
          bne.s     errbits1

          move.w    _deferror.w,D1
errbits1: move.w    D1,_cerror.w
          rts
;**************************************************** Xbios(9) Flopwr S.114     ***
;         PART 'flopwr'

Flopwr:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr.b    _Flopwr
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte


_Flopwr:
          move.w    #$100,rwflag.w
          move.l    #fdc_wrint,$158.w        ;vector setzen
          bra  floprdwr
;**************************************************    Xbios(19) Flopver S.117  ***
;         PART 'flopver'
;# hmmmmm!!!

Flopver:
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   16(a0),-(sp);count
 move.w   14(a0),-(sp);sideno
 move.w   12(a0),-(sp);trackno
 move.w   10(a0),-(sp);secno
 move.w   8(a0),-(sp) ;dev
 move.l   4(a0),-(sp) ;filler
 move.l   (a0),-(sp)  ;*buf
 bsr.b    _Flopver
 lea.l    18(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rte



_Flopver:
     move.w    #1,rwflag.w                        ;read zum verify
          move.l    #fdc_vrint,$158.w        ;vector setzen
          bra  floprdwr
;======================================================================================== hades end

;**************************************************    Xbios(10) Flopfmt S.115  ***
;         PART 'flopfmt'
;**************************************************
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

_Flopfmt: cmp.l     #-$789ABCDF,22(A7)
               beq       fmtflp
               moveq     #-1,d0
               rts
fmtflp:
               tst.w     _nflops             ;.w
               beq  no_flops

               lea  12(a7),a0
               bsr  change
               bsr  floplock

               move.w  14(a7),flpfmt_spt.w                   ;anzahl sectoren
               move.l    8(A7),cfiller.w                    ;sectortabelle
               move.w    20(A7),flpfmt_intlv.w               ;sectortabelle vorhanden?
               bmi  fmt31                           ;ja
;---------------------------------------------- sectorreihenfolge in tabelle erzeugen
;d0 = anzahl sectoren. d1 = standort im buffer. d2 = interleave. d3 = schleifenzaehler. d4 = momentane sectornummer.
               moveq     #1,d4
               moveq     #0,d1                           ;1. tabellenplatz
               move.w    flpfmt_spt.w,d0                       ;anzahl sectoren
               move.w    d0,d3                           ;nach d3 als zaehler
fmt24:         clr.b     0(a3,d3.w)                      ;sectortabelle loeschen
               dbf  d3,fmt24
               move.w    d0,d3
               move.w    flpfmt_intlv.w,d2
               subq.w    #2,d3                    ;-1 umlauf (resp. 2 wegen dbf)
               move.b    d4,(a3)                  ;1. sector
fmt22:         add.w     d2,d1
               cmp.w     d1,d0                           ;groesser oder gleich max
               bge  fmt23                    ;nein->
               sub.w     d0,d1
fmt23:         addq.w    #1,d4                           ;naechster sector
fmt26:         tst.b     0(a3,d1.w)               ;frei?
               beq  fmt25
               addq.w    #1,d1                    ;sonst next
               bra  fmt26
fmt25:         move.b    d4,0(a3,d1.w)            ;eintragen
               dbf  d3,fmt22            ;next bis ende
               moveq     #40,d3                   ;rest fuellen
fmt27:         addq.w    #1,d4                           ;naechste sectornummer
               addq.w    #1,d1                           ;naechster platz
               move.b    d4,0(a3,d1.w)                   ;eintragen
               dbf  d3,fmt27
;-----------------------------------------------
fmt21:         move.w    26(A7),flpfmt_vrgn.w          ;datenwert
               moveq     #2,D0
               bsr  setdmode
;-------------------------------------------------
               moveq     #dd,D0
               cmp.w     #12,flpfmt_spt.w              ;DD?
               blt  fmt1                          ;ja->
               moveq     #ed,d0
               cmp.w     #24,flpfmt_spt.w              ;ed?
               bgt     fmt1                            ;ja
               moveq     #hd,D0
;-------------------------------------------------
fmt1:          add.w     #$300,d0                 ;3 versuche
               move.w    D0,dsb_hdmode(A1)             ;dsb.dsb_hdmode setzen
               bsr  select0
fmt6:          move.w    #1,csect.w               ;startsector auf 1
               bsr  seek_ver
               move.w    #-1,_cerror.w
;init int
            move.l  #fdc_format,$158.w       ;vector setzen
               bset #4,$fffffa83.w           ;int bei low to high
               bclr #6,$fffffa8d.w           ;interrupt pending loeschen
               bclr #6,$fffffa91.w                  ;in service loeschen
               bset #6,$fffffa95.w                  ;maske freigeben -> interrupt
               bset #6,$fffffa89.w           ;int enable
;-----------------------------------------------------      
            moveq   #$4D,d7                  ;mfm format track
               bsr  sendcom
            move.w  cside.w,d7               ;seite
            lsl.w   #2,d7                    ;nach bit 2
            add.w   cdev.w,d7                ;lw nr
            bsr     sendcom
            moveq   #2,d7                    ;512 byt sektoren
            bsr     sendcom
            move.w  flpfmt_spt.w,d7               ;anzahl sectoren
            bsr     sendcom
            moveq   #$54,d7                  ;gap length
            bsr     sendcom
            move.b  flpfmt_vrgn.w,d7              ;datawert
               bsr  sendcom
               move.l    _hz_200.w,d6
            add.l   #300,d6                  ;1.5 sec warten
fmt2:          cmp.l     _hz_200.w,d6                    ;abgelaufen?
               bcs  fmt3
               btst #6,$fffffa89.w           ;fertig?
               bne  fmt2                ;nein
;----------------------------------------------------------
fmt3:         bclr  #6,$fffffa89.w           ;int off
               moveq     #6,d3                           ;7 byt status lesen
            bsr     holdata
            bmi     flopfail
;-------------------------------------------------
               move.b    status_buffer+1.w,d0          ;FDC Status register 1
               and.b     #$37,d0                         ;relevante bits
               bne.s     fmt5                     ;wenn nicht null dann error
;------------------------------------------------- sectortest ausfuehren
fmt8:         clr.w (a3)                ;keine def. sectoren
               tst.w     _fverify                 ;verfiy?
               beq  flopok                          ;nein->
            move.l  a3,cbuffer.w             ;bufferzeiger auf anfang
               move.w    #1,csect.w                     ;beginnen bei sector 1
               move.w    flpfmt_spt.w,ccount.w                 ;alle sectoren pruefen
               clr.w     verifyflag.w             ;sectortest
               move.w    #2,_rtrycnt.w            ;3 Versuche
               move.w    #1,rwflag.w                        ;read zum verify
               move.l    #fdc_vrint,$158.w        ;vector setzen
               bra  floprd2
;-------------------------------------------------
fmt5:          bsr  errbits                  ;Fehlerbehandlung
               cmp.w     #1,_rtrycnt.w
               bne.s     fmt7
               bsr  homeseek
fmt7:          subq.w    #1,_rtrycnt.w
               bpl  fmt6                ;nochmal versuchen
               bra       flopfail
               rts
;------------------------------------------------------------ sectortabelle uebertragen
fmt31:         move.w    flpfmt_spt.w,d0                       ;anzahl sectoren
               move.w    d0,d2
               move.l    cfiller.w,a0                    ;tabelle
               move.l    a3,a2                           ;bufferadresse
               subq.w    #1,d0                           ;-1 wegen dbf
fmt32:         move.w    (a0)+,d1                        ;sectornr. als word holen
               move.b    d1,(a2)+                        ;und als byt speichern
               dbf  d0,fmt32                        ;wiederholen bis fertig
               move.w    #40,d0                          ;rest fuellen
fmt33:         addq.w    #1,d2
               move.b    d2,(a2)+                        ;eintragen
               dbf  d0,fmt33                        ;bis fertig
               bra  fmt21                           ;weiter
;----------------------------------------------- format int
fdc_format:    movem.l   d0-d1/a0,-(sp)                  ;register retten
               bclr #6,$fffffa89.w                     ;int off
               move.l    cbuffer.w,a0                    ;bufferregister holen
               move.w    flpfmt_spt.w,d0                         ;anzahl sectoren
               subq.w    #1,d0                                   ;-1 wegen dbf
               btst #4,GPIP_TT.w                   ;daten?
               beq       form2                           ;nein -> fertig
               bra       form3
form1:         bsr       formintwaitb
               bmi       form2                                   ;error
form3:         move.b    ctrack+1.w,data_reg                ;track nummer
               bsr       formintwait                     ;wait auf int
               bmi       form2                           ;error->
               move.b    cside+1.w,data_reg                 ;seite
            bsr          formintwait
            bmi          form2                           ;error
               move.b    (a0)+,data_reg                     ;sector nummer
            bsr          formintwait
            bmi          form2                           ;error
               move.b    #2,data_reg                             ;512 byt sectoren
            dbf          d0,form1                        ;wiederholen bis fertig
form2:         move.l    a0,cbuffer.w                    ;bufferregister zurueck
               movem.l   (sp)+,d0-d1/a0                     ;register zurueck
               rte
;-----------------------------------------------------------------------
formintwaitb:move.l #100000,d1                      ;timeout 50ms
               bra  formintwait1             
formintwait:moveq   #100,d1                         ;timeout 50us
formintwait1:btst   #4,GPIP_TT.w                    ;int?
               bne  formintwait2                       ;ja->
               tst.b     $fffffc00.w                             ;0.5us warten
            subq.l  #1,d1                           ;abgelaufen
            bpl     formintwait1                            ;nein->
               rts
formintwait2:btst   #4,GPIP_TT.w                       ;daten?
            bne     formintwait3                            ;ja
            moveq   #-1,d1                          ;sonst error
               rts
formintwait3:moveq  #0,d1                           ;ok
               rts
