**********************************************************************
***************     DMA- und Floppy- Bootroutinen   ******************
**********************************************************************
**********************************************************************
*
* long bios_rawdrvr( d0 = int opcode, d1 = long devcode, ... )
*
* Führt gerätespezifische Aktionen aus.
*
* d0 = 0: Medium auswerfen.
*
* Da dieser Treiber nur die Floppies A: und B: bedient, gibt
* es nur ein EINVFN. Anders wird es beim Mac.
*

bios_rawdrvr:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long bios2devcode( d0 = int biosdev )
*
* Rechnet ein BIOS-Device in einen devcode um (major/minor)
* Rückgabe 0, wenn Fehler
* wird vom DOS aufgerufen
*

bios2devcode:
 cmpi.w   #1,d0               ; Laufwerke A: oder B: ?
 bhi.b    b2dc_err            ; nein
 swap     d0
 move.w   #64,d0
 swap     d0                  ; major = 64 (XHDI-Spezifikation)
 rts
b2dc_err:
 moveq    #0,d0
 rts


**********************************************************************
*
* long DMAread( long sector, int count, void *buf, int target )
*
* Die Bits 21..24 von <sector> enthalten die Device- Nummer
* des betreffenden Targets
* Target 0..7:  ASCI
* Target 8..15: SCSI
*

DMAread:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     10(a0),-(sp);target
 move.l     6(a0),-(sp) ;*buf
 move.w     4(a0),-(sp) ;count
 move.l     (a0),-(sp)  ;sector
 bsr.b      _DMAread
 lea.l      12(sp),sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_DMAread:
 moveq    #0,d0               ; lesen
 bra.b    dmarw


**********************************************************************
*
* long DMAwrite( long sector, int count, void *buf, int target )
*

DMAwrite:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     10(a0),-(sp);target
 move.l     6(a0),-(sp) ;*buf
 move.w     4(a0),-(sp) ;count
 move.l     (a0),-(sp)  ;sector
 bsr.b      _DMAwrite
 lea.l      12(sp),sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_DMAwrite:
 moveq    #1,d0               ; schreiben
dmarw:
 move.w   14(sp),d1           ; target
 cmpi.w   #7,d1               ; target > 7 ?
 bhi      dmarw_scsi          ; ja, SCSI  => Quelltext "SCSI.S"

 lea      5(sp),a0            ; sector (devno+hibyte)
 subq.l   #6,sp               ; Platz für 6 Bytes
 lsl.b    #5,d1               ; Targetnummer in Bits 7,6,5
 addq.b   #8,d1
 add.b    d0,d1
 add.b    d0,d1               ; Bits 0..4: 8(lesen) 10 (schreiben)
 lea      (sp),a1
 move.b   d1,(a1)+            ; Byte 0: Target+Kommando
 move.b   (a0)+,(a1)+         ; Byte 1: devno+secno(hi)
 move.b   (a0)+,(a1)+         ; Byte 2: secno(mid)
 move.b   (a0)+,(a1)+         ; Byte 3: secno(lo)
 addq.l   #1,a0               ; count(hi) überspringen
 move.b   (a0)+,(a1)+         ; Byte 4: count
 clr.b    (a1)                ; Byte 5: 0

* FDC/ACSI sperren

 movem.l  d0/a0,-(sp)
 bsr      acsi_begin
 movem.l  (sp)+,d0/a0

 move.l  _hz_200,d1           ; WICHTIG: Vor dem ersten Zugriff auf die
 addq.l   #2,d1               ; DMA-Bausteine 1/100 s warten
dmarw_del1:
 cmp.l    _hz_200,d1
 bcc.b    dmarw_del1          ; letzter Zugriff noch zu kurz her
 lea      $ffff8604,a1        ; a1 = Daten
 lea      2(a1),a2            ; a2 = Kontrolle
 addq.l   #1,a0               ; buf, erstes Byte überspringen
 move.b   (a0)+,d1            ; buf(hi)
 move.b   (a0)+,d2            ; buf(mid)
;Achtung: Bytes müssen in der Reihenfolge LOW, MID, HIGH geschrieben werden
; (in Mag!X 1.10/1.11 fehlerhaft!!)
 move.b   (a0)+,$ffff860d     ; buf(lo)
 move.b   d2,$ffff860b        ; buf(mid)
 move.b   d1,$ffff8609        ; buf(hi)

* FIFO- Puffer durch Klappern des rw- Bits löschen
* zunächst DMA mit FDC, sector count register
 tst.b    d0
 bne.b    dmarw_w1            ; war "DMAwrite"

 move.w   #$90,(a2)           ; DMA auf Lesen
;bsr      teste_fa01
 nop                          ; neu

dmarw_w1:
 move.w   #$190,(a2)          ; DMA auf Schreiben (#neu)
;bsr      teste_fa01
 nop                          ; neu
 move.w   #$90,(a2)           ; DMA auf Lesen
;bsr      teste_fa01
 nop                          ; neu
 tst.b    d0
 beq.b    dmarw_r1            ; war "DMAread"

 move.w   #$190,(a2)          ; DMA auf Schreiben
;bsr      teste_fa01
 nop                          ; neu
dmarw_r1:
 moveq    #0,d1               ; Bit 8 auf 0
 move.b   4(sp),d1
; TOS 2.05 hat hier 4*count
 move.w   d1,(a1)             ; sector counter
 tst.b    d0
 beq.b    dmarw_r2
 move.w   #$100,d1            ; Bit 8 auf 1 (schreiben)
dmarw_r2:
 move.b   #$88,d1             ; Bits 0..7 des Status: ACSI- Registerzugriff
 move.w   d1,(a2)
 move.b   #$8a,d1             ; Bits 0..7 des Status: CMD- Phase für ACSI
 lea      (sp),a0             ; DMA- Daten
 moveq    #4,d2               ; zunächst 5 Bytes senden
dmarw_loop:
 swap     d1
 move.b   (a0)+,d1            ; DMA- Byte ins Hiword (für ffff8604)
 swap     d1
 move.l   d1,(a1)             ; und abschicken
 moveq    #20,d0              ; 20/200s
 bsr      wait_acsi           ; 1/10s Timeout
 bmi.b    dmarw_err           ; war Timeout
 dbf      d2,dmarw_loop       ; weitere Kommandos
 move.w   d1,(a2)             ; letzten Status nochmal setzen
 clr.b    d1                  ; Status auf 0 (DMA mit ACSI)
 swap     d1
 move.b   (a0),d1             ; letztes Command Byte ins Hiword
 swap     d1
 move.l   d1,(a1)             ; und abschicken
 move.b   #$8a,d1             ; Zugriff auf Controller Access Register
 move.l   #600,d0
 bsr.b    wait_acsi
 bmi.b    dmarw_err           ; timeout

 bsr      cache_invalid       ; Daten- und Befehls-Cache löschen

acsi_st:
 move.w   d1,(a2)             ; d1 -> DMA Mode
 move.w   (a1),d0             ; Sector counter
 and.w    #$ff,d0             ; auf 8 Bit reduzieren
dmarw_err:
 bsr      cache_invalid
 move.w   #$80,(a2)           ; $80 -> DMA mode (DMA auf FDC)

* FDC/ACSI freigeben

 bsr      acsi_end

; TOS 2.05 hat hier nur WORD !!
 ext.l    d0                  ; Fehler ?
 beq.b    dmarw_ende          ; nein
 bmi.b    dmarw_ende          ; ja, negativer Fehlercode
 moveq    #EREADF,d0
 btst.b   #1,(sp)             ; 8=lesen,10=schreiben
 beq.b    dmarw_ende
 moveq    #EWRITF,d0
dmarw_ende:
 addq.l   #6,sp
 rts

* wartet darauf, daß Bit 5 von fffffa01 (gpip) low wird, d.h. Abschluß des
* Datenaustauschs über ACSI
* Rückgabe 0=ok, -1=timeout

wait_acsi:
 move.l  d0,-(sp)
 moveq   #2,d0
 add.l   _hz_200,d0
wa_2ticks:
 cmp.l   _hz_200,d0
 bge.b   wa_2ticks
 move.l  (sp)+,d0

 add.l    _hz_200,d0
wa_loop:
 cmp.l    _hz_200,d0
 bcs.b    wa_timeout
 btst     #5,gpip
 bne.b    wa_loop
 moveq    #0,d0
 rts
wa_timeout:
 moveq    #-1,d0
 rts


teste_fa01:
 lea      gpip,a0
 tst.b    (a0)
 tst.b    (a0)
 tst.b    (a0)
 tst.b    (a0)
 rts

;-------------------------------------------------------
;Binding für IDE-Routinen in IDE.C
;
;Es fehlt:
;- Kapselung mit ACSI-Semaphore (in Bootphase unkritisch),
;  da DMA-Chip und IDE-IR auf demselben MFP-IR liegen ...
;-------------------------------------------------------
;(d0 = int wrflag, ... )
dmarw_ide:
 move.w   14(sp),d1 ;dev
 cmp.w    #17,d1
 bls.b    _dmarw_ide
 moveq    #EUNDEV,d0
 rts

_dmarw_ide:
 tst.w    d0                       ; Lesen?
 beq.b    rd_ide

 move.w   d1,d0                    ; dev
 move.l   4(sp),d1                 ; sector
 move.w   8(sp),d2                 ; count
 move.l   10(sp),a0                ; (void *) daten
 jsr      IDEWrite                 ; IDEWrite (unit device, ULONG sector,
                                   ;           WORD count, void *data)
 ext.l    d0                       ; Fehler?
 beq.b    _wr_ide_ende
 moveq    #EWRITF,d0
_wr_ide_ende:
 rts

rd_ide:
 move.w   d1,d0                    ; dev
 move.l   4(sp),d1                 ; sector
 move.w   8(sp),d2                 ; count
 move.l   10(sp),a0                ; (void *)daten
 suba.l   a1,a1                    ; &jiffies
 jsr      IDERead                  ; IDERead (dev, sector, count,
                                   ;         (void *)daten, &jiffies)
 ext.l    d0                       ; Fehler?
 beq.b    _rd_ide_ende
 moveq    #EREADF,d0
_rd_ide_ende:
 rts



**********************************************************************
*
* void dskboot( void )
*
* versucht, von Floppy zu booten
*

dskboot:
     IFEQ HADES
 moveq    #3,d0
 bsr      cartscan
     ENDIF
 movea.l  hdv_boot,a0
 jsr      (a0)
 tst.w    d0
 bne.b    dskboot_end
     IFNE DEBUG
 lea      strt_ss(pc),a0
 bsr      putstr
 bsr      hdl_pling
     ENDIF
 move.l   _dskbufp,a0
 jsr      (a0)
dskboot_end:
 rts


;------------------------------------------------------
;
; void dmaboot( void )
;
; zerstört Register d0/d1/d2/d4/d5/d6/d7/a5/a6
; Achtung: d4 ist das Target (0..15), das an den Plattentreiber
; übergeben wird.
;------------------------------------------------------
     IFNE   DEBUG
ini_ides: DC.B 'Initialisiere IDE',$d,$a,0
ini_ss:   DC.B 'Initialisiere SCSI',$d,$a,0
bt_ides:  DC.B 'IDE-Gerät',$d,$a,0
bt_fscs:  DC.B 'Falcon-SCSI',13,10,0
bt_scs:   DC.B 'SCSI (5380)',13,10,0
bt_acs:   DC.B 'ACSI',$d,$a,0
rdbs_s:   DC.B 'Lese Bootsektor',13,10,0
prf_ss:   DC.B 'Berechne Prüfsumme',$d,$a,0
prf_oks:  DC.B 'Prüfsumme OK',13,10,0
prf_bads: DC.B 'Prüfsumme fehlerhaft',$d,$a,0
strt_ss:  DC.B 'Starte Bootprogramm',$d,$a,0
bt_ok:    DC.B 'Bootprogramm war OK',$d,$a,0
bt_can:   DC.B 'Bootprogramm schlug fehl!',$d,$a,0
     EVEN
     ENDIF
;------------------------------------------------------
dmaboot:
;IDE
 movea.l  8.w,a0                   ; Falcon/ST/Hades/Medusa mit IDE-Platte?
 movea.l  sp,a1                    ; Stack für dma_noide
 move.l   #dma_noide,8.w           ; Busfehlervektor setzen

 tst.b    IDE_StatReg2             ; Dieses Register kann gelesen werden,
                                   ;   ohne daß IR-Bits sich verändern
 move.l   a0,8.w                   ; Busfehlervektor zurücksetzen

 moveq    #16,d0                   ; dev
 move.l   _dskbufp,a0              ; zeigt auf 4 kB großen Puffer
 lea      2048(a0),a0              ; Platz für IDE-Daten
 jsr      IDEIdentify              ; IDEIdentify (dev, &ide_daten)

IFNE DEBUG
 lea      ini_ides(pc),a0
 bsr      putstr
ENDIF

 moveq    #16,d0                   ; dev
 move.l   _dskbufp,a0
 lea      2048(a0),a0              ; Platz für IDE-Daten
 jsr      IDEInitDrive             ; IDEInitDrive (dev, &ide_daten)

IFNE DEBUG
 lea      bt_ides(pc),a0
 bsr      putstr
ENDIF

 moveq    #16,d4                   ; dev
 bsr      dmrd_boot
 tst.w    d0
 bne      db_scsidev               ; Fehler, nächstes dev testen

 bsr      dmab_exec                ; Bootsektor eingelesen, Prüfsumme OK,
                                   ;  versuche Bootsektor auszuführen
 tst.w    d0
 bne      db_scsidev               ; Fehler, nächstes dev testen
 rts

dma_noide:
 movea.l  a1,sp                    ; Stack zurück
 move.l   a0,8.w                   ; Busfehlervektor zurück
     
;SCSI
db_scsidev:
 movea.l  8.w,a0                   ; TT/Medusa mit "echtem" SCSI-Chip?
 movea.l  sp,a1
 move.l   #dma_noscsi,8.w          ; Busfehlervektor setzen
 move.b   $ffff8781.w,d0           ; Busfehlertest mit scsi_data-Register
 move.l   a0,8.w                   ; Busfehlervektor zurücksetzen

IFNE DEBUG
 lea      ini_ss(pc),a0
 bsr      putstr
ENDIF

 lea      int_ncr(pc),a2           ; Interrupt SCSI busy
 moveq    #15,d0
 bsr      _mfpint_tt

 lea      int_scsidma(pc),a2       ; Interrupt SCSI-DMA Buserror
 moveq    #7,d0
 bsr      _mfpint_tt

 bsr      scsi_init
IFNE DEBUG
 lea      bt_scs(pc),a0
 bsr      putstr
ENDIF
 bra.b    db_sc                    ; SCSI-dev abtesten
     
dma_noscsi:
 movea.l  a1,sp                    ; Stack zurück
 move.l   a0,8.w                   ; Busfehlervektor zurück

 cmpi.b   #4,machine_type          ; Keine echter SCSI-Chip. Vielleicht Falcon?
 bne.b    dmab_acsi                ; nein, dann ACSI ...
IFNE DEBUG
 lea      bt_fscs(pc),a0
 bsr      putstr
ENDIF

db_sc:    
 lea      dbd_scsi(pc),a0          ; -1 markiert das Ende der Liste
db_sc_loop:
 move.w   (a0)+,d4                 ; dev
 bmi.b    dmab_acsi
 move.l   a0,-(sp)
 bsr      dmrd_boot
 move.l   (sp)+,a0
 tst.w    d0
 bne.b    db_sc_loop               ; Fehler, nächstes dev probieren
 bsr.b    dmab_exec                ; Lesen geklappt, Prüfsumme OK,
                                   ;  versuche Bootsektor auszuführen
 tst.w    d0
 bne.b    db_sc_loop               ; Fehler beim Ausführen des Bootsektors
 rts                               ; Bootsektor ausgeführt, alles ok

;ACSI
dmab_acsi:
 cmpi.b   #4,machine_type          ; Falcon?
 beq.b    dmab_ende                ; hat kein ACSI
IFNE DEBUG
 lea      bt_acs(pc),a0
 bsr      putstr
ENDIF

 lea      dbd_acsi(pc),a0          ; -1 markiert das Ende der Liste
db_ac_loop:
 move.w   (a0)+,d4                 ; dev
 bmi.b    dmab_ende
 move.l   a0,-(sp)
 bsr      dmrd_boot
 move.l   (sp)+,a0
 tst.w    d0
 bne.b    db_ac_loop               ; Fehler, nächstes dev probieren
 bsr.b    dmab_exec                ; Lesen geklappt, Prüfsumme OK,
                                   ;   versuche Bootsektor auszuführen
 tst.w    d0
 bne.b    db_ac_loop               ; Fehler beim Ausführen des Bootsektors
     
dmab_ende:
 rts


;-------------------------------------------
;
;Bootsektor ausführen
;
;Register a0 bleibt erhalten
;
dmab_exec:     
 move.l   hdv_rw,-(sp)
 movea.l  _dskbufp,a0
 move.l   #'DMAr',d3               ; Kennung für Platte: habe DMAread/write
 moveq    #0,d5                    ; ST: von erster bootfähiger Partition booten
 cmpi.b   #3,machine_type
 bne.b    dmab_no_scu              ; nur der TT hat eine SCU
 move.b   $ffff8e09,d1             ; SCU_1
 and.w    #$f8,d1
 bne.b    dmab_set_flag            ; Wert aus SCU übernehmen
 move.l   a0,-(sp)                 ; a0 retten
 subq.l   #2,sp
 pea      (sp)
 move.w   #2,-(sp)                 ; 2 Bytes von RTC lesen
 clr.l    -(sp)                    ; Lesen ab Register 0
 bsr      _NVMaccess
 adda.w   #$a,sp
 move.w   (sp)+,d1                 ; RTC-Daten nach d1
 move.l   (sp)+,a0                 ; a0 zurück
 tst.w    d0                       ; Fehler ?
 bne.b    dmab_no_scu              ; ja

dmab_set_flag:
 move.w   d1,d5                    ; Bootflag aus SCU holen

dmab_no_scu:
     IFNE DEBUG
 move.l   a0,-(sp)                 ; enthält den hdv_rw!
 lea      strt_ss(pc),a0
 bsr      putstr
 move.l   (sp)+,a0
     ENDIF

 move.w   d4,d7                    ; TOS 3.06: Gerätenummer
 lsl.w    #5,d7                    ; TOS 3.06: (Kompat. zu TOS 1.0 ?)
 jsr      (a0)
 move.l   (sp)+,a0

 moveq    #0,d0
 cmpa.l   hdv_rw,a0
 bne      db_exe_ende              ; Treiber installiert
 moveq    #-1,d0                   ; Treiber nicht installiert, nächstes dev
                                   ;  Alvar hatte diesen Befehl
                                   ;  auskommentiert !!??!! (=> d0 = ?)
     IFNE DEBUG
 move.l   d0,-(sp)
 move.l   a0,-(sp)
 lea      bt_can(pc),a0
 bsr      putstr
 move.l   (sp)+,a0
 move.l   (sp)+,d0
 rts
     ENDIF
db_exe_ende:
     IFNE DEBUG
 move.l   d0,-(sp)
 move.l   a0,-(sp)
 lea      bt_ok(pc),a0
 bsr      putstr
 move.l   (sp)+,a0
 move.l   (sp)+,d0
     ENDIF
     rts

;-----------------------------------------------------------
;
;Bootsektor von Platte lesen, Prüfsumme bilden
;
;IN
;    d4.w: dev
;OUT
;    d0.w: 0 (OK), -1 Fehler
;-----------------------------------------------------------
dmrd_boot:
 moveq    #1,d6                    ; 2 Versuche
dmrd_loop:
     IFNE DEBUG
 lea      rdbs_s(pc),a0
 bsr      putstr
     ENDIF
 move.w   d4,-(sp)                 ; Target
 move.l   _dskbufp,-(sp)           ; buf
 move.w   #1,-(sp)                 ; Ein Sektor
 clr.l    -(sp)                    ; Sektor #0
 bsr      _DMAread
 lea      12(sp),sp
 tst.l    d0
 beq.b    dmrd_prf                 ; Lesen hat geklappt, Prüfsumme bilden
 dbra     d6,dmrd_loop
 moveq    #-1,d0                   ; Fehler aufgetreten
 rts
     
dmrd_prf:                          ; Lesen hat geklappt, Prüfsumme bilden
     IFNE DEBUG
 lea      prf_ss(pc),a0
 bsr      putstr

 movea.l  _dskbufp,a0
 bsr      prfsum
 tst.w    d0
 bne.b    dmrd_pbad

 lea      prf_oks(pc),a0
 bsr      putstr
 moveq    #0,d0
 rts

dmrd_pbad:
 lea      prf_bads(pc),a0
 bsr      putstr
 moveq    #-1,d0
 rts
     ELSE
 movea.l  _dskbufp,a0
 bra      prfsum                   ; d0.w == 0, wenn Prüfsumme ok
     ENDIF

;
;Abzutestende Geräte
dbd_scsi: dc.w 8, 9,10,11,12,13,14,15,-1
dbd_acsi: dc.w 0, 1, 2, 3, 4, 5, 6, 7,-1


**********************************************************************
*
* long critical_error(int err, int dev)
*

critical_error:
 move.l   etv_critic,-(sp)
 moveq    #-1,d0
 rts


*********************************************************************
*
* Der Zugriff bei Rwabs ist bei gesetztem LOCK nur für den
* sperrenden Prozeß erlaubt
*

IRwabs:
 movem.l  d3-d7/a3-a6,-(sp)
 subq.l   #4,sp                    ; Platz für Zeiger
 lea      12(a0),a0
 move.l   (a0),-(sp)               ; lrecno
 move.l   -(a0),d0                 ; recno/dev
; Auf LOCK testen und Zugriffszeit merken
 move.w   d0,a1
 add.w    a1,a1
 add.w    a1,a1
 move.l   a1,4(sp)                 ; merken für DOS- Writeback
 move.l   dlockx(a1),d3
 beq.b    rwabs_ok
 cmp.l    act_pd,d3
 bne.b    rwabs_elocked
rwabs_ok:
 clr.l    bufl_timer(a1)           ; für DOS- Writeback (als in Arbeit markieren)
 move.l   d0,-(sp)                 ; recno/dev
 move.l   -(a0),-(sp)              ; count/buf.lo
 move.l   -(a0),-(sp)              ; buf.hi/rwflag
 move.l   hdv_rw,a1
 jsr      (a1)
 lea      16(sp),sp
rwabs_ende:
 move.l   (sp)+,a1
 move.l   _hz_200,bufl_timer(a1)   ; für DOS- Writeback
 movem.l  (sp)+,d3-d7/a3-a6
 rte
     
rwabs_elocked:
 moveq    #ELOCKED,d0
 addq.l   #4,sp
 bra.b    rwabs_ende


**********************************************************************
*
* long Drvmap( void )
*

Drvmap:
 move.l   _drvbits,d0
 rte


**********************************************************************
*
* void copy_sector(a0 = char *dst, a1 = char *src)
*

copy_sector:
 moveq    #$3f,d0
 cmpi.w   #20,cpu_typ
 bcc.b    cps_20
cpysct_loop:
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 move.b   (a1)+,(a0)+
 dbf      d0,cpysct_loop
 rts
cps_20:
 move.l   (a1)+,(a0)+              ; der 68020 kann ungerade Langwortadressen
 move.l   (a1)+,(a0)+
 dbra     d0,cps_20
 rts


**********************************************************************
*
* void flp_hdv_init( void )
*

flp_hdv_init:
 move.w   d7,-(sp)

     IFEQ HADES
 lea      int_mfp7(pc),a2          ; Interrupt DMA busy initialisieren
 moveq    #7,d0
 bsr      _mfpint
     ENDIF

 move.l   #$52,maxacctim           ; 0,4sec
 clr.w    _nflops
 clr.w    mediach_statx            ; 2*char, für A: und B: kein Diskwechsel
 clr.w    current_disk             ; Disk A: liegt in Drive A:
 clr.w    d7                       ; mit Laufwerk A: beginnen
fhi_loop:
 clr.l    -(sp)
 clr.w    -(sp)
 move.w   d7,-(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 bsr      acsi_begin
 bsr      flopini
 bsr      acsi_end
 lea      $10(sp),sp
 tst.w    d0
 bne.b    fhi_nxt
 addq.w   #1,_nflops               ; noch eine Floppy gültig
 ori.w    #3,_drvbits+2            ; A: und B:
fhi_nxt:
 addq.w   #1,d7
 cmpi.w   #2,d7
 bcs.b    fhi_loop
 move.w   (sp)+,d7
 rts


**********************************************************************
*
* long flp_getbpb(int drv)
*

flp_getbpb:
 move.w   4(sp),d0
 movem.l  a4/a5/a6,-(sp)
 move.l   _dskbufp,a6              ; Pufferadresse
 move.w   d0,a4                    ; a4 = Laufwerknummer
 cmpi.w   #1,d0
 bhi      fbpb_err
 lea      bpbx,a5
 mulu     #fbpb_sizeof,d0
 add.w    d0,a5                    ; a5 = Zeiger auf BPB
fbpb_read:
 move.w   #1,-(sp)                 ; 1 Sektor
 clr.l    -(sp)                    ; Seite 0, Spur 0
 move.w   #1,-(sp)                 ; Sektor 1
 move.w   a4,-(sp)                 ; Laufwerk
 clr.l    -(sp)                    ; filler
 move.l   a6,-(sp)                 ; Pufferadresse
 bsr      acsi_begin
 bsr      _Floprd
 bsr      acsi_end
 lea      $12(sp),sp
 tst.l    d0                       ; Fehler ?
 beq.b    fbpb_read_ok             ; nein, ok
 move.w   a4,-(sp)
 move.w   d0,-(sp)
 bsr      critical_error           ; Abbruch/Wiederh./Ignorieren ?
 addq.l   #4,sp
 cmpi.l   #$10000,d0               ; Wiederholen ?
 beq.b    fbpb_read                ; ja
 bra      fbpb_err                 ; Ignorieren wird nicht zugelassen
fbpb_read_ok:

* Hier wird der "öffentliche" BiosParameterBlock berechnet

 move.l   a5,a2

 moveq    #$b,d0
 bsr      intel16
 move.w   d0,d1                    ; d1 = Bytes pro Sektor
 ble      fbpb_err                 ; negativ oder Null

 moveq    #0,d0
 move.b   13(a6),d0                ; d0 = Sektoren pro Cluster
 ble      fbpb_err                 ; negativ oder Null
 move.w   d1,(a2)+                 ; b_recsiz     (0)
 move.w   d0,(a2)+                 ; b_clsiz      (2)
 mulu     d1,d0
 move.w   d0,(a2)+                 ; b_clsizb = b_clsiz * b_recsiz        (4)

 moveq    #$11,d0                  ; NDIRS
 bsr      intel16
 lsl.w    #5,d0                    ; *32 Bytes/Eintrag
 ext.l    d0
 divu     (a5),d0                  ; /b_recsiz (Sektorgröße)
 move.w   d0,(a2)+                 ; b_rdlen eintragen, Rest ignorieren   (6)

 moveq    #$16,d0
 bsr      intel16
 move.w   d0,(a2)+                 ; b_fsiz = Sektoren pro FAT            (8)

 addq.w   #1,d0
 move.w   d0,(a2)+                 ; b_fatrec = b_fsiz + 1               (10)

 add.w    6(a5),d0                 ; + b_rdlen  (Länge Root)
 add.w    8(a5),d0                 ; + b_fsiz   (Länge der 2. FAT)
 move.w   d0,(a2)+                 ; = b_datrec (Anfang des Datenbereichs)

 moveq    #$13,d0                  ; NSECTS
 bsr      intel16
 sub.w    $c(a5),d0                ; - b_datrec
 ext.l    d0
 divu     2(a5),d0                 ; / b_clsiz
 move.w   d0,(a2)+                 ; = b_numcl

 cmpi.b   #2,16(a6)                ; NFATS
 scs      d0
 andi.w   #2,d0
 move.w   d0,(a2)+                 ; Bit 0: FAT- Typ 12 Bit
                                   ; Bit 1: nur eine FAT

* Es folgt der "nichtöffentliche" Teil

 addq.l   #2,a2                    ; $12(a5) zunächst überspringen

 moveq    #$1a,d0                  ; NSIDES
 bsr      intel16
 move.w   d0,(a2)+                 ; $14(a5) = NSIDES

 addq.l   #2,a2                    ; $16(a5) zunächst überspringen

 moveq    #$18,d0
 bsr      intel16
 move.w   d0,(a2)+                 ; $18(a5) = SPT

 mulu     $14(a5),d0
 move.w   d0,$16(a5)               ; $16(a5) = NSIDES * SPT

 moveq    #$13,d0
 bsr      intel16
 ext.l    d0
 divu     $16(a5),d0
 move.w   d0,$12(a5)               ; $12(a5) = NSECTS / (NSIDES * SPT) (Tracks)

 moveq    #$1c,d0
 bsr      intel16
 move.w   d0,(a2)+                 ; $1a(a5) = NHID

 move.l   8(a6),d0                 ; serial
 clr.b    d0                       ; nur 24 Bit (unnötig, aber sicherheitsh.)
 move.l   d0,(a2)+

; eingefügt 12.10.97:

 move.b   $27(a6),d0
 lsl.w    #8,d0
 move.b   $28(a6),d0
 swap     d0
 move.b   $29(a6),d0
 lsl.w    #8,d0
 move.b   $2a(a6),d0
 move.l   d0,(a2)                  ; MS-Seriennummer im BPB

; Ende der Einfügung

* Mediach- Status berechnen

 moveq    #0,d0
 move.b   wpstat(a4),wplatch(a4)
 beq.b    fbpb_setmed
 moveq    #1,d0
fbpb_setmed:
 move.b   d0,mediach_statx(a4)
 move.l   a5,d0                    ; BPB zurückgeben
fbpb_ende:
 movem.l  (sp)+,a6/a5/a4
 rts
fbpb_err:
 moveq    #0,d0
 bra.b    fbpb_ende


**********************************************************************
*
* int intel16( d0+a6 = char intelword[2] )
*
* a6 muß _dskbufp sein
*

intel16:
 move.l   a6,a0                    ; Diskpuffer
 add.w    d0,a0                    ; + Offset
 movep.w  1(a0),d0                 ; Hibyte holen, d0 = {1(a0),3(a0)}
 move.b   (a0),d0                  ; Lobyte holen
 rts


**********************************************************************
*
* long flp_mediach(int drive)
*

flp_mediach:
 move.w   4(sp),d1                 ; Gerätenummer (0 oder 1)
 moveq    #EUNDEV,d0
 cmpi.w   #2,d1
 bcc.b    flpmediach_end                ; Nummer >= 2
 lea      mediach_statx,a0
 adda.w   d1,a0
 moveq    #2,d0
 cmp.b    (a0),d0
 beq.b    flpmediach_end                ; Disk definitiv gewechselt
 lea      wplatch,a1
 tst.b    0(a1,d1.w)               ; wplatch[drive]
 beq.b    flpmediach_l1
 move.b   #1,(a0)                  ; Status unsicher
flpmediach_l1:
 addq.l   #2,a1                    ; acctim
 add.w    d1,d1
 add.w    d1,d1
 add.w    d1,a1
 move.l   _frclock,d1
 sub.l    (a1),d1                  ; Differenz zur letzten Zugriffszeit
 moveq    #0,d0
 cmp.l    maxacctim,d1
 blt.b    flpmediach_end
 move.b   (a0),d0
flpmediach_end:
 rts


**********************************************************************
*
* long tst_mediach(d0 = int drv)
*
* Testet auf Diskwechsel, liest ggf. im Bootsektor nach
*

tst_mediach:
 movem.l  d5/d6/a5,-(sp)
 move.w   d0,d6                    ; d6 = dev
 lea      bpbx,a5
 mulu     #fbpb_sizeof,d0
 add.w    d0,a5                    ; a5 auf BPB
 move.w   d6,-(sp)
 bsr      flp_mediach
 addq.l   #2,sp
 ext.l    d0
 beq      tstmc_ende               ; Disk nicht gewechselt => return(0L)
 cmpi.w   #2,d0
 beq      tstmc_ende               ; Disk sicher gewechselt => return(2L)
tstmediach_loop:
 move.w   #1,-(sp)                 ; 1 Sektor
 clr.l    -(sp)                    ; Track 0/Seite 0
 move.w   #1,-(sp)                 ; Sektor 1
 move.w   d6,-(sp)                 ; dev
 clr.l    -(sp)                    ; filler = 0L
 move.l   _dskbufp,-(sp)           ; buf = dskbuf
 bsr      _Floprd                   ; Bootsektor einlesen
 lea      $12(sp),sp
 move.l   d0,d5
 bge.b    tstmediach_l1                ; kein Fehler
 move.w   d6,-(sp)
 move.w   d5,-(sp)
 bsr      critical_error
 addq.l   #4,sp
 move.l   d0,d5
tstmediach_l1:
 cmp.l    #$10000,d5               ; Retry ?
 beq.b    tstmediach_loop                ; ja
 move.l   d5,d0
 bmi.b    tstmc_ende               ; Fehlercode zurückgeben
 move.l   _dskbufp,a0
 move.l   8(a0),d1
 clr.b    d1                       ; Seriennummer im Diskpuffer
 move.l   $1c(a5),d2
 clr.b    d2                       ; Seriennummer im BPBe
 moveq    #2,d0
 cmp.l    d1,d2
 bne.b    tstmc_ende               ; ungleich => return(2L)

; eingefügt 12.10.97:

 move.b   $27(a0),d1
 lsl.w    #8,d1
 move.b   $28(a0),d1
 swap     d1
 move.b   $29(a0),d1
 lsl.w    #8,d1
 move.b   $2a(a0),d1               ; MS-Seriennummer im Diskpuffer
 cmp.l    $20(a5),d1               ; MS-Seriennummer im BPB
 bne.b    tstmc_ende               ; ungleich => return(2L)

; Ende der Einfügung

 movea.w  d6,a0
 move.b   wpstat(a0),wplatch(a0)   ; kopiere Schreibschutzstatus (?)
 bne.b    tstmc_ok
 clr.b    mediach_statx(a0)        ; lösche Mediach-Flag
tstmc_ok:
 moveq    #0,d0
tstmc_ende:
 movem.l  (sp)+,a5/d6/d5
 rts


**********************************************************************
*
* long flp_rwabs(int flag, void *buf, int count, int recno, int dev)
*

flp_rwabs:
 link     a6,#0
 moveq    #EUNDEV,d0
 move.w   $12(a6),d1               ; d1 = dev
 cmpi.w   #1,d1
 bhi.b    rw_ende                  ; dev > 1 (nicht A: oder B:)
 moveq    #EDRVNR,d0
 tst.w    _nflops
 beq.b    rw_ende                  ; kein Laufwerk
 tst.l    $a(a6)                   ; buf ?
 bne.b    flprwabs_l1
* <buf> == NULL: <count> als Mediach- Status setzen
 move.w   $e(a6),d0                ; count
 lea      mediach_statx,a1
 move.b   d0,(a1,d1.w)
 moveq    #0,d0                    ; E_OK
 bra.b    rw_ende
flprwabs_l1:
 bsr      acsi_begin
 cmpi.w   #2,8(a6)
 bge.b    flprwabs_l2
* flag < 2, also ohne Ignorieren des Diskwechsels
 move.w   $12(a6),d0
 bsr      tst_mediach              ; Diskwechsel testen
 ext.l    d0
 beq.b    flprwabs_l2                ; kein Wechsel
 cmpi.l   #2,d0
 bne.b    rw_ende2                 ; Fehlercode
 moveq    #E_CHNG,d0
 bra.b    rw_ende2
flprwabs_l2:
 move.w   $10(a6),-(sp)            ; recno
 move.w   8(a6),-(sp)              ; flag
 move.l   $a(a6),a0                ; buf
 move.w   $12(a6),d1               ; dev
 move.w   $e(a6),d0                ; count
 bsr.b    _flp_rwabs
 addq.l   #4,sp
rw_ende2:
 bsr      acsi_end
rw_ende:
 unlk     a6
 rts


**********************************************************************
*
* long _flp_rwabs(d0 = int count, d1 = int dev, a0 = void *buf,
*                 int flag, int recno )
*
* flag: Bit 0 = 0: Lesen
*               1: Schreiben
*
* Achtung: geht von 512 Byte - Sektoren aus
*

_flp_rwabs:
 link     a6,#0
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5,-(sp)
 move.l   a0,a3                    ; buf
 move.w   d1,d4                    ; d4 = dev
 move.w   d0,d3                    ; d3 = count
 lea      bpbx,a5
 mulu     #fbpb_sizeof,d1
 add.w    d1,a5                    ; a5 zeigt auf den BPB
     IFNE HADES
 sf       d7                       ; beim Hades auch ungerade möglich
     ELSE
 move.l   a3,d0
 btst     #0,d0
 sne      d7                       ; ungerade Pufferadresse merken
     ENDIF
 tst.w    $16(a5)                  ; NSIDES * SPT
 bne.b    _flprwabs_l1
* unsinniger BPB: setze 9 Sektoren, einseitig
 moveq    #9,d0
 move.w   d0,$16(a5)               ; NSIDES * SPT
 move.w   d0,$18(a5)               ; SPT
_flprwabs_l1:
 bra      _flprwabs_l2

* while (count)

_flprwabs_l9:
 move.l   a3,a4                    ; gerade Adresse: <buf> als Puffer
 tst.b    d7                       ; ungerade Adresse ?
 beq.b    _flprwabs_l3
 move.l   _dskbufp,a4              ; ungerade Adresse: dskbuf als Puffer
_flprwabs_l3:
* d6.lo = Track
* d6.hi = Sektor und Seite des Tracks
 moveq    #0,d6                    ; unsigned !
 move.w   10(a6),d6                ; <recno>
 divu     $16(a5),d6               ; /(SPT * NSIDES)
 cmp.w    $12(a5),d6               ; Track >= Anzahl Tracks ?
 bcc      _rwabs_eseek             ; ja => Fehler
* d5.hi = Seite (0 oder 1), d6.hi = Sektor
 swap     d6                       ; d6 umdrehen, Sektor ins Loword
 moveq    #0,d5                    ; Seite 0
 cmp.w    $18(a5),d6               ; SPT
 bcs.b    _flprwabs_l4
 moveq    #1,d5                    ; Seite 1
 sub.w    $18(a5),d6               ; Sektornummer korrigieren
* d5.lo = Anzahl der Sektoren
_flprwabs_l4:
 swap     d5                       ; Seite ins Hiword
 move.w   #1,d5                    ; 1 Sektor
 tst.b    d7                       ; Pufferadresse ungerade ?
 bne.b    _flprwabs_l5                ; Pufferadresse ungerade: d5.lo = 1
* Pufferadresse gerade: d5 = min(count, SPT - Sektor)
 move.w   $18(a5),d5               ; SPT * NSIDES
 sub.w    d6,d5                    ; - Sektor
 cmp.w    d3,d5                    ; > count
 bcs.b    _flprwabs_l5
 move.w   d3,d5
* Sektornummer von [0..SPT-1] ins Intervall [1..SPT]
_flprwabs_l5:
 addq.w   #1,d6
 swap     d6                       ; d6 zurückdrehen, Sektor ins Hiword

* Critical- Error- Retry- Schleife

_rwabs_again:
 btst     #0,9(a6)                 ; Lesen oder Schreiben ?
 beq      _flprwabs_l8

* Schreiben:

* ggf. einen Sektor in den Diskpuffer kopieren
 tst.b    d7
 beq.b    _flprwabs_l6                ; gerade Adresse: Direktzugriff
 move.l   a3,a1                    ; Quelle
 move.l   a4,a0                    ; Ziel
 bsr      copy_sector

_flprwabs_l6:
 move.l   d5,-(sp)                 ; Seite und Anzahl
 move.l   d6,-(sp)                 ; Track und Sektor
 move.w   d4,-(sp)                 ; dev
 clr.l    -(sp)
 move.l   a4,-(sp)
 bsr      _Flopwr
 lea      $12(sp),sp
 tst.l    d0
 bne.b    _flprwabs_l7                ; Fehler
 tst.w    _fverify
 beq.b    _flprwabs_l7
* verifizieren
 move.l   d5,-(sp)                 ; Seite und Anzahl
 move.l   d6,-(sp)                 ; Track und Sektor
 move.w   d4,-(sp)                 ; dev
     IFNE HADES
 pea      -1.w                     ; Daten verifizieren
 move.l   a4,-(sp)                 ; Puffer Daten + def. Sektorablage
 bsr      _Flopver
 lea      $12(sp),sp
 tst.l    d0
 beq      _rwabs_ok
_flprwabs_l7:
 bra.b    _rwabs_critic
     ELSE
 clr.l    -(sp)
 move.l   _dskbufp,-(sp)
 bsr      _Flopver
 lea      $12(sp),sp
 tst.l    d0
 bne.b    _flprwabs_l7                ; Fehler
 move.l   _dskbufp,a0
 move.w   (a0),d0                  ; Liste fehlerhafter Sektoren ?
 beq.b    _flprwabs_l7                ; nein
 moveq    #EBADSF,d0
_flprwabs_l7:
 bra.b    _rwabs_critic
     ENDIF

* Lesen

_flprwabs_l8:
 move.l   d5,-(sp)                 ; Seite und Anzahl
 move.l   d6,-(sp)                 ; Track und Sektor
 move.w   d4,-(sp)                 ; dev
 clr.l    -(sp)
 move.l   a4,-(sp)
 bsr      _Floprd
 lea      $12(sp),sp
* ggf. Sektor kopieren
 tst.b    d7
 beq.b    _rwabs_critic

 move.l   d0,-(sp)
 move.l   a4,a1                    ; Quelle
 move.l   a3,a0                    ; Ziel
 bsr      copy_sector
 move.l   (sp)+,d0

* Fehlerbehandlung (Critical error), d0 = errcode

_rwabs_critic:
 tst.l    d0                       ; Fehler ?
 bge.b    _rwabs_ok                ; nein
 move.w   d4,-(sp)                 ; dev
 move.w   d0,-(sp)
 bsr      critical_error           ; Abbruch,Wiederholen,Ignorieren ?
 addq.l   #4,sp
 tst.l    d0
 bmi      _rwabs_ende              ; Abbruch, Fehlercode zurückgeben
 cmp.l    #$10000,d0
 bne.b    _rwabs_ok                ; Ignorieren, weitermachen
* Der Benutzer forderte: "NOCHMAL"
 cmpi.w   #2,8(a6)                 ; Diskwechsel ignorieren ?
 bcc      _rwabs_again             ; ja, Retry
* Diskwechsel nicht ignorieren, Retry: ggf. E_CHNG
 move.w   d4,d0                    ; dev
 bsr      tst_mediach
 subq.w   #2,d0
 bne      _rwabs_again             ; nicht gewechselt, Retry
 moveq    #E_CHNG,d0
 bra      _rwabs_ende

* Endlich ist die Operation ausgeführt worden

_rwabs_ok:
 moveq    #0,d0
 move.w   d5,d0                    ; Anzahl Sektoren
 moveq    #9,d1
 lsl.l    d1,d0                    ; * 512
 add.l    d0,a3                    ; Auf buf addieren
 add.w    d5,10(a6)                ; Anzahl Sektoren auf recno addieren
 sub.w    d5,d3                    ; und von count abziehen

* endwhile (count)

_flprwabs_l2:
 tst.w    d3                       ; count != 0
 bne      _flprwabs_l9                ; ja weiter
 moveq    #0,d0                    ; kein Fehler
_rwabs_ende:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts
_rwabs_eseek:
 moveq    #E_SEEK,d0
 bra.b    _rwabs_ende


**********************************************************************
*
* long flp_boot()
*

     IFNE DEBUG
fi_ss:    DC.B 'Floppies initialisieren',$d,$a,0
fr_ss:    DC.B 'Floppy-Bootsektor lesen',$d,$a,0
     ENDIF

flp_boot:
     IFNE DEBUG
 lea      fi_ss(pc),a0
 bsr      putstr
     ENDIF
 move.l   hdv_init,a0
 jsr      (a0)                     ; Initialisierungsroutine aufrufen
 moveq    #1,d0
 tst.w    _nflops                  ; Diskettenlaufwerke vorhanden ?
 beq.b    flpbt_end                ; nein, return(1)

     IFNE DEBUG
 lea      fr_ss(pc),a0
 bsr      putstr
     ENDIF
 move.w   #1,-(sp)                 ; 1 Sektor
 clr.l    -(sp)                    ; track 0
 move.w   #1,-(sp)                 ; Sektor 1
 clr.w    -(sp)                    ; dev A:
 clr.l    -(sp)                    ; filler
 move.l   _dskbufp,-(sp)           ; buf
 bsr      acsi_begin
 bsr      _Floprd                  ; Bootsektor lesen
 bsr      acsi_end
 lea      $12(sp),sp

 tst.l    d0
 beq.b    flpbt_l1                ; kein Fehler

 moveq    #3,d0
 tst.b    wpstat
 beq.b    flpbt_end                ; Fehler und wpstat[0] = 0 : return(3)
 moveq    #2,d0
 bra.b    flpbt_end                ; Fehler und wpstat[0] = 1 : return(2)
flpbt_l1:
     IFNE DEBUG
 lea      prf_ss(pc),a0
 bsr      putstr
     ENDIF
 move.l   _dskbufp,a0
 bsr      prfsum                   ; liefert ZERO, falls = $1234
 beq.b    flpbt_end                ; return(0)
 moveq    #4,d0
flpbt_end:
 rts


**********************************************************************
*
* void Protobt( char *buf, long serial, int typ, int isexec )
*

Protobt:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     10(a0),-(sp);isexec
 move.w     8(a0),-(sp) ;typ
 move.l     4(a0),-(sp) ;serial
 move.l     (a0),-(sp)  ;*buf
 bsr.b      _Protobt
 lea.l      12(sp),sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Protobt:
 lea      4(sp),a0
 lea      $a(a0),a1
 move.l   (a0)+,a2                 ; a2 ist der Puffer
 tst.w    (a1)                     ; isexec
 bge.b    proto_w1                 ; wird hiermit festgelegt
* execflag soll bleiben, also merken
 clr.w    (a1)                     ; per Default nicht ausführbar
 move.l   a2,a0
 bsr      prfsum                   ; liefert ZERO, falls = $1234
 lea      8(sp),a0                 ; a0 restaurieren
 bne.b    proto_w1                 ; nicht ausführbar, ok
 st       (a1)                     ; ausführbar
proto_w1:
 move.l   (a0)+,d0                 ; serial
 blt.b    proto_noser              ; nicht ändern
 cmp.l    #$ffffff,d0
 ble.b    proto_w2                 ; angegeben
 bsr      _Random
 move.l   d0,-4(a0)                ; neue Zufallsnummer
proto_w2:
 move.b   -1(a0),8(a2)
 move.b   -2(a0),9(a2)
 move.b   -3(a0),10(a2)            ; 3 Bytes kopieren
proto_noser:
 move.w   (a0)+,d0                 ; Disktyp
 blt.b    proto_notyp              ; < 0, nicht ändern
 cmpi.w   #4,d0                    ; 4 ist HD !
 bls.b    proto_ok                 ; <= 3, ok
 moveq    #3,d0                    ; Falscher Disktyp => 3 wählen
proto_ok:
 lea      proto_data(pc),a1
 mulu     #$13,d0                  ; Länge der Tabellenelemente
 add.w    d0,a1                    ; Quelle
 lea      $b(a2),a0                ; Ziel
 moveq    #$13-1,d1
proto_loop:
 move.b   (a1)+,(a0)+
 dbra     d1,proto_loop            ; Bootsektordaten kopieren
proto_notyp:
 move.l   a2,a0                    ; Sektorprüfsumme
 move.w   #255-1,d1                ; der ersten 255 Worte
 bsr      prfsum2                  ; schon $1234 subtrahiert
 neg.w    d0
 move.w   d0,(a0)                  ; letztes Wort, damit Summe $1234 stimmt
 tst.w    $e(sp)                   ; soll Bootsektor ausführbar sein ?
 bne.b    proto_ende               ; ja, Ende
 addq.w   #1,(a0)                  ; nein, Summe erhöhen
proto_ende:
 moveq    #0,d0                    ; trotz "void" geben wir E_OK
 rts

**********************************************************************
*
* int prfsum(a0 = int *sector)
*
* Setzt d0 = 0 und setzt das Z- Flag, falls Summe $1234 ist
*

prfsum:
 move.w   #256-1,d1                ; 256 Worte addieren
prfsum2:
 moveq    #0,d0
prfsum_loop:
 add.w    (a0)+,d0
 dbra     d1,prfsum_loop
 subi.w   #$1234,d0
 rts


proto_data:  /* Daten für Protobt */

/* Disktyp 0: Einseitig, LD (180k) */
 DC.B     $00,$02   ; BPS     = 512     Bytes/Sektor
 DC.B     $01       ; SPC     = 1       Sektor/Cluster
 DC.B     $01,$00   ; RES     = 1       reservierter Sektor
 DC.B     $02       ; NFATS   = 2       FATs
 DC.B     $40,$00   ; NDIRS   = 64      Einträge im Wurzelverzeichnis
 DC.B     $68,$01   ; NSECTS  = 360     Sektoren gesamt
 DC.B     $fc       ; MEDIA   = $fc     Media Byte
 DC.B     $02,$00   ; SPF     = 2       Sektoren/FAT
 DC.B     $09,$00   ; SPT     = 9       Sektoren/Spur
 DC.B     $01       ; NSIDES  = 1       Seiten
 DC.B     $00,$00   ; NHID    = 0       versteckte Sektoren
 DC.B     $00       ; EXECFLAG= 0       kein COMMAND.PRG

/* Disktyp 1: Zweiseitig, LD (360k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $d0,$02   ; NSECTS  = 720
 DC.B     $fd       ; MEDIA   = $fd
 DC.B     $02,$00   ; SPF     = 2
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 2: Einseitig, DD (360k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $d0,$02   ; NSECTS  = 720
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $05,$00   ; SPF     = 5
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $01       ; NSIDES  = 1
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 3: Zweiseitig, DD (720k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $a0,$05   ; NSECTS  = 1440
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $05,$00   ; SPF     = 5
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 4: Zweiseitig, HD (1440k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $e0,$00   ; NDIRS   = 224
 DC.B     $40,$0b   ; NSECTS  = 2880
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $06,$00   ; SPF     = 6
 DC.B     $12,$00   ; SPT     = 18
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

     EVEN
