**********************************************************************
**********************************************************************
*
* EVENT- MANAGER, INTERRUPT und KERNEL
*
*

     INCLUDE "aesinc.s"
     INCLUDE "basepage.inc"
     INCLUDE "lowmem.inc"
     INCLUDE "..\dos\magicdos.inc"

        TEXT
        SUPER
        MC68881

     XDEF      appl_yield          ; nach BIOS
     XDEF      appl_suspend        ; nach BIOS
     XDEF      appl_begcritic      ; nach DOS
     XDEF      appl_endcritic      ; nach DOS
     XDEF      appl_alrm           ; nach DOS
     XDEF      evnt_IO             ; nach DOS,BIOS usw.
     XDEF      evnt_mIO            ; nach DOS,BIOS usw.
     XDEF      evnt_emIO           ; nach DOS,BIOS usw.
     XDEF      evnt_sem            ; nach DOS,BIOS usw.
     XDEF      evnt_pid,hap_pid    ; nach DOS (fuer Pwaitpid())
     XDEF      evnt_fork,hap_fork  ; nach DOS (fuer P(v)fork())
     XDEF      appl_IOcomplete     ; nach DOS,BIOS usw.
     XDEF      Mappl_IOcomplete    ; nach MACXFS
     XDEF      keyb_app            ; nach DOS,BIOS usw.

     XREF      pe_slice,pe_timer   ; von BIOS
     XREF      first_sem           ; vom BIOS
     XREF      iorec_kb            ; vom BIOS
     XREF      is_fpu              ; vom BIOS
     XREF      config_status       ; vom DOS
     XREF      Mchgown             ; vom DOS
     XREF      srch_process        ; vom DOS
     XREF      match_pid           ; vom DOS (fuer Pwaitpid())
     XREF      appl_break
     XREF      funselect           ; DOS
     XREF      kbshift             ; vom BIOS
	 XREF      mmx_yield           ; vom BIOS

     XREF      fatal_stack         ; von AESMAIN
     XREF      enab_warmb          ; von AESMAIN
     XREF      wind_find           ; von AESWIN
     XREF      whdl_to_wnd         ; von AESWIN
     XREF      aes_dispatcher,_set_topwind_app,appl_info,set_mouse_app
     XREF      grects_union,grects_intersect,xy_in_grect
     XREF      _lmul,_ldiv,vmemcpy
     XREF      dsetdrv_path
     XREF      vdi_quick

     XDEF      send_msg
     XDEF      appl_write
     XDEF      appl_read
     XDEF      _evnt_multi,evnt_button,evnt_keybd,evnt_mouse
     XDEF      _evnt_timer
     XDEF      evnt_mesag
     XDEF      evnt_xmesag
     XDEF      appl_exit,appl_trecord,appl_tplay
     XDEF      update_0,update_1,mctrl_0,mctrl_1
     XDEF      mov_int,but_int,timer_int,draw_int
     XDEF      event_happened,send_click,send_mouse
     XDEF      beg_mctrl,end_mctrl
     XDEF      ap_to_lastready
     XDEF      flush_keybuf,flush_msgbuf
     XDEF      wind_update,end_update
     XDEF      ad__kernel
     XDEF      rmv_ap_timer
     XDEF      rmv_ap_alrm
     XDEF      rmv_ap_io
     XDEF      aes_trap2
     XDEF      _end_mctrl
     XDEF      _ap_to_last
     XDEF      rmv_ap_sem
     XDEF      rmv_lstelm
     XDEF      read_keybuf
     XDEF      _appl_exit
     XDEF      ctrl_timeslice
     XDEF      warmb_hdl

     XDEF      app2ready
     XDEF      stp_thr,cnt_thr

* von AESMAIN

     XREF      do_signals


**********************************************************************
*
* void flush_msgbuf( APPL *ap )
*

flush_msgbuf:
 move.w   ap_len(a0),d0
 beq.b    fmb_ende
 lea      popup_tmp,a0             ; Platz fuer mind. 256 Bytes
 bra      appl_read
fmb_ende:
 rts


**********************************************************************
*
* void appl_exit( void )
*
* Schickt den Accessories AC_CLOSE- Meldungen, leert den Messagepuffer
* und nach _appl_exit
*

appl_exit:
 movea.l  act_appl,a0
 bsr.s    flush_msgbuf
;bra      _appl_exit


**********************************************************************
*
* void _appl_exit( void )
*
* macht jetzt 10 statt einem appl_yield
*

_appl_exit:
 moveq    #20-1,d1                 ; GEM 2.0: 3 Aufrufe
_ap_y:
 bsr.s    appl_yield               ; aendert nur d0/a0
 dbra     d1,_ap_y
                                   ; erst beenden, wenn alle anderen Programme
 bsr      update_1                 ;  die Menues entsperrt haben
 bra      update_0


*********************************************************************
*
* d0.l = long ctrl_timeslice( d0.lo = int ticks, d0.hi = int count )
*
* Hiermit (ueber Cookie-Ptr, Offset $64 aufgerufen) kann man die
* Zeitscheibensteuerung aktivieren und Zeitscheibe sowie
* Hintergrund- Prioritaet festlegen.
* Ist d0 = -1L, wird der gesamte Mechanismus deaktiviert.
* Ist ein Wert < -2, wird er nicht beeinflusst.
*

ctrl_timeslice:
 move.w   pe_un_susp,d1
 swap     d1
 move.w   pe_slice,d1              ; alte Werte nach d1.l
 cmpi.w   #-2,d0
 ble.b    ctt_weiter
 move.w   d0,pe_slice
 move.w   d0,pe_timer
ctt_weiter:
 swap     d0
 cmpi.w   #-2,d0
 ble.b    ctt_weiter2
 move.w   d0,pe_un_susp
 move.w   d0,pe_unsuspcnt
ctt_weiter2:
 move.l   d1,d0
 rts


*********************************************************************
*
* Programm hat Rechenzeit verbraucht.
* zerstoert sr (d.h. ccr)
*

appl_suspend:
 move.l   a0,-(sp)
 move.l   act_appl,a0
 move.b   #APSTAT_SUSPENDED,ap_status(a0)
 move.l   (sp)+,a0

*********************************************************************
*
* Neuer Kernel
* zerstoert sr (d.h. ccr)
*
* gesicherte Register auf dem Stack:
*
*    pc                            ; 64: Ruecksprungadresse
*    d0-d2/a0-a4                   ; 32: long regs1[8];
*   [                              ;  wenn FPU existiert:
*    FPU-Status                    ; char fpu_st[4 ~ 218]   (je nach Status)
*    [                             ;  wenn status != NULL:
*     fp0-fp7                      ; long double fregs[8]   Datenregister
*     fpcr/fpsr/fpiar              ; long fpu_sregs[3]      Statusregister
*     flag                         ; int  flag              ist -1
*    ]
*   ]
*    a5-a6/d3-d7,-(sp)             ; 4: long regs2[7]
*    usp                           ; 0: long usp
*

appl_yield:
 tas.b    inaes                    ; Kernel gesperrt ?
 bne      ad_locked                ; ja
 movem.l  d0/d1/d2/a0/a1/a2/a3/a4,-(sp)      ; notwendige Register
 lea      act_appl,a4
* alle 10 Aufrufe suspend-list umsetzen
 subq.w   #1,pe_unsuspcnt
 bcc.b    ad_no_unsus
 move.w   pe_un_susp,pe_unsuspcnt
 lea      suspend_list,a1          ; angehaltene Programme
 move.l   (a1),d0
 beq.b    ad_no_unsus
 move.l   d0,a0
 move.l   (a0),(a1)                ; aus suspend_liste raus ...
;move.l   a0,a0
 bsr      ap_to_lastready          ; ... und hinten in die ready-Liste
ad_no_unsus:
 movea.l  (a4),a3                  ; aktuelle Applikation nach a3
 move.l   (a3),(a4)                ; die aktuelle Applikation ausklinken
 move.b   ap_status(a3),d0
 beq.b    ad_isready               ; ist ready, nach hinten haengen
 subq.b   #1,d0                    ; ap_status == APSTAT_WAITING ?
 beq.b    ad_iswaiting             ; ja
 subq.b   #1,d0                    ; ap_status == APSTAT_SUSPENDED ?
 bne      ad__kernel               ; nein
* Die aktuelle Applikation ist SUSPENDED, hat also keine Rechenzeit mehr
 move.l   a3,a0
 lea      suspend_list,a2
 bsr      _ap_to_last
 bra      ad__kernel
* Die aktuelle Applikation ist WAITING, wartet also auf einen Event
ad_iswaiting:
 move.w   ap_rbits(a3),d0          ; erwartete Events
 and.w    ap_hbits(a3),d0          ; eingetroffene Events
 bne.b    ad_isready               ; Uebereinstimmung!
* Haenge a3 an den Anfang der NOTREADY- Liste
 move.l   notready_list,(a3)
 move.l   a3,notready_list
 bra.b    ad__kernel
* bei der aktuellen Applikation ist ein Event eingetroffen
ad_isready:
 move.l   a3,a0
ad_loop2:
 bsr      ap_to_lastready

* hier springt appl_term ein, da ein Kontext zurueckgeholt werden muss,
* aber keiner gerettet werden darf

ad__kernel:
 bsr      read_evnts_from_ringbuf
ad_loop:
 bsr      check_kb

 tst.l    (a4)                     ; lauffaehige Programme
 bne.b    ad_newready              ; ist nicht leer
 tst.l    suspend_list             ; angehaltene Programme
 bne.b    ad_newsuspend
 tst.l    iocpbuf_cnt              ; sind inzwischen Ereignisse eingetroffen ?
 beq.b    ad_loop                  ; nein, zurueck in die Schleife
 bra.b    ad__kernel

ad_newsuspend:
 tst.l    iocpbuf_cnt
 bne.b    ad__kernel
 move.l   suspend_list,a0
 move.l   ap_next(a0),suspend_list ; ausklinken
 sf.b     ap_status(a0)            ; Status READY statt SUSPENDED
 clr.l    ap_next(a0)
 move.l   a0,(a4)                  ; einziges Element der ready-Liste
 bra.b    ad_switch
ad_newready:
 tst.l    iocpbuf_cnt
 bne.b    ad__kernel
 movea.l  (a4),a0                  ; act_appl

* Jetzt kommt der Kontextwechsel: a0 ist neue Applikation

ad_switch:
 cmpa.l   a0,a3                    ; ist neue APP = alte APP ?
 beq      ad_return                ; ja, kein Kontextwechsel
 tst.b    no_switch
 beq.b    ad_chgcntxt              ; kein Kontextwechsel erlaubt!
 move.l   (a0),(a4)                ; unerwuenschte APPL ausklinken
 bra      ad_loop2                 ; kein Kontextwechsel erlaubt!
ad_chgcntxt:
; alten Kontext retten
 move.l   a3,d1
 beq      ad_no_old                     ; es gibt keinen alten Kontext!


* FPU retten
 tst.b    is_fpu                        ; LineF- FPU installiert ?
 beq.b    ad_no_fpu                     ; nein!
 fsave -(a7)
 tst.b (a7)
 beq ad_no_fpu
 fmovem.x fp0-fp7,-(sp)                 ; Datenregister
 fmovem.l fpcr/fpsr/fpiar,-(sp)         ; Statusregister
 move.w   #-1,-(sp)                     ; Flag fuer "FPU komplett gesichert"


ad_no_fpu:
 movem.l  a5/a6/d3/d4/d5/d6/d7,-(sp)    ; restliche Register auf Stack
 move.l   usp,a1
 move.l   a1,-(sp)                      ; usp auf Stack
 lea      ap_ssp(a3),a1
 move.l   sp,(a1)+                      ; ap_ssp
 move.l   (a1),d1
 beq.b    ad_no_old                     ; ist kein Prozess!
 move.l   act_pd.l,(a1)+                  ; ap_pd
 move.l   etv_term,(a1)                 ; ap_etvterm
ad_no_old:


; neuen Kontext zurueck
 move.w   SUPERSTACKLEN+ap_stack(a0),d0      ; erzwingt Einlagern eines Blocks, fuer OUTSIDE
 lea      ap_ssp(a0),a1
 move.l   (a1)+,sp                      ; ap_ssp

 move.l   (a1)+,d1                      ; ap_pd
 beq.b    ad_nopd                       ; ist kein Prozess!
 move.l   d1,act_pd.l
 move.l   (a1),etv_term                 ; ap_etvterm
ad_nopd:
 move.l   (sp)+,a1
 move.l   a1,usp
 movem.l  (sp)+,a5/a6/d3/d4/d5/d6/d7

* FPU restaurieren
 tst.b    is_fpu
 beq.b    ad_return
 tst.b    (sp)
 beq.b    ad_fp_null                    ; war Status NULL
 addq.l   #2,sp                         ; Flag ueberspringen
 fmovem.l (sp)+,fpcr/fpsr/fpiar         ; Statusregister
 fmovem.x (sp)+,fp0-fp7                 ; Datenregister


ad_fp_null:
 frestore (sp)+

ad_return:
 movem.l  (sp)+,d0/d1/d2/a0/a1/a2/a3/a4
 move.w   pe_slice,pe_timer             ; ### prae-emptiv ###
 sf       inaes
ad_locked:
 rts


 DC.L     'IBRA'                   ; IBRA- Struktur, mit indirekter Adresse
 DC.L     'MAGX'
 DC.L     old_trap2

**********************************************************************
*
* Einsprung (trap #2)
*

aes_trap2:
 cmpi.w   #$c8,d0
 beq.b    trap_aesfn               ; d0 = $c8:    AES
 cmpi.w   #$c9,d0
 beq.b    trap_yield               ; d0 = $c9:    appl_yield
 cmpi.w   #$ca,d0
 beq.b    trap_super               ; d0 = $ca:    MagiC 4.5: Supermode
 tst.w    d0
 beq.b    trap_term                ; d0 = 0:      Pterm(0)
 move.l   old_trap2,-(sp)          ; sonst:       alter Vektor
 rts

trap_super:
 jmp      (a2)

trap_term:
 clr.w    -(sp)
 move.w   #$4c,-(sp)
 trap     #1                       ; gemdos Pterm

trap_yield:
 tst.l    suspend_list
 bne.b    exec_yield
 move.l   act_appl,a0
 tst.l    (a0)                     ; gibt es weitere "ready" Applikationen?
 bne.b    exec_yield               ; ja, Kernel aufrufen
 tst.l    iocpbuf_cnt              ; sind inzw. Ereignisse eingetroffen ?
 bne.b    exec_yield               ; ja, Kernel aufrufen
 movem.l  d1/d2/a1,-(sp)
 bsr      check_kb                 ; Tastatur pollen, aendert nicht a2
 movem.l  (sp)+,d1/d2/a1
 tst.l    iocpbuf_cnt              ; sind jetzt Ereignisse eingetroffen ?
 bne.b    exec_yield               ; ja, Kernel aufrufen
 rte                               ; nix passiert, kein Aufruf

trap_aesfn:
 move.l   d1,d0                    ; Zeiger auf die Parameter
 beq.b    exec_yield
 move.l   d0,a0
 movem.l  d1/d2/a1-a6,-(sp)
 bsr      aes_dispatcher           ; keine entry- Prozedur
 movem.l  (sp)+,d1/d2/a1-a6

* "Multitasking"

exec_yield:
 bsr      appl_yield

* Kontext zurueck und auf User zurueckschalten

 clr.w    d0
 rte


**********************************************************************
*
* event_happened(a0 = APPL *ap, d0 = int evtyp)
*
* EVENT(s) <evtyp> ist/sind eingetroffen
* Traegt <ev> in ap_hbits ein und prueft Status der Applikation
*

event_happened:
 or.w     d0,ap_hbits(a0)          ; eingetroffene EVENTs
 move.b   ap_status(a0),d0         ; schon ready ?
 beq.b    evh_ende                 ; ja!
 subq.b   #APSTAT_STOPPED,d0       ; angehalten ?
 beq.b    evh_ende                 ; ja, nicht freigeben!
 move.w   ap_hbits(a0),d0          ; eingetroffene EVENTs
 and.w    ap_rbits(a0),d0
 beq      evh_ende                 ; kein erwarteter eingetroffen
* aus Notready- Liste ausklinken

 lea      notready_list,a1
;move.l   a0,a0
 bsr      rmv_lstelm               ; ausklinken
 tst.l    d0
;move.l   a0,a0
 bne      ap_to_lastready          ; ans Ende der ready-Liste, ap_status
; nicht gefunden, weil eingefroren (?)
 cmpi.b   #APSTAT_ZOMBIE,ap_status(a0)
 beq.b    evh_ende
 sf.b     ap_status(a0)            ; nicht gefunden (eingefroren?) => ready
evh_ende:
 rts


**********************************************************************
*
* stp_thr(a0 = APPL *ap)
*
* Haelt eine Applikation an.
*

stp_thr:
 move.b   ap_status(a0),d0         ; APSTAT_READY
 bne.b    stp_ap_weiter1

; Die APP ist "ready"
; Entferne sie aus der Queue, wenn sie nicht die
; aktuelle APP ist.

 cmpa.l   act_appl,a0
 beq.b    stp_ap_newstate
 lea      act_appl,a1
 bra.b    stp_ap_unlist
 
stp_ap_weiter1:
 subq.b   #1,d0                    ; APSTAT_WAITING ?
 bne.b    stp_ap_weiter2

; Die APP ist "waiting".
; Entferne sie aus der Warteliste

 lea      notready_list,a1
 bra.b    stp_ap_unlist

stp_ap_weiter2:
 subq.b   #1,d0                    ; APSTAT_SUSPENDED ?
 bne.b    stp_ap_newstate          ; ist schon gestoppt

; Die APP ist "suspended".
; Entferne sie aus der entsprechenden Liste

 lea      suspend_list,a1
stp_ap_unlist:
;move.l   a0,a0
 bsr      rmv_lstelm               ; ausklinken, veraendert nur d0/a1

; Status in APSTAT_STOPPED aendern
 
stp_ap_newstate:
 move.b   #APSTAT_STOPPED,ap_status(a0)
 rts


**********************************************************************
*
* cnt_thr(a0 = APPL *ap)
*
* Laesst eine Applikation weiterlaufen, die auf ein Signal wartet.
*

cnt_thr:
 cmpi.b   #APSTAT_STOPPED,ap_status(a0)
 bne.b    _rstrt_ende
 sf.b     ap_stpsig(a0)            ; sicherheitshalber

; Reihe APPL in ready bzw. notready-Liste ein

 move.w   ap_rbits(a0),d0          ; erwartete Events
 beq.b    _rstrt_ready             ; keine, d.h. ready
 and.w    ap_hbits(a0),d0          ; eingetroffene EVENTs
 beq.b    _rstrt_wait              ; kein erwarteter eingetroffen

_rstrt_ready:
 bra      ap_to_lastready
 
_rstrt_wait:
 move.b   #APSTAT_WAITING,ap_status(a0)
 move.l   notready_list,ap_next(a0)
 move.l   a0,notready_list
_rstrt_ende:
 rts


**********************************************************************
*
* void app2ready(a0 = APPL *ap)
*
* Stellt sicher, dass eine Applikation weiterlaeuft, i.a. damit
* sie terminieren kann.
*

app2ready:
 move.l   a0,-(sp)
 bsr.b    cnt_thr
 move.l   (sp)+,a0
 move.b   ap_status(a0),d0
 subq.b   #APSTAT_WAITING,d0
 bne.b    app2r_ende               ; ist schon READY
 move.w   #EV_RESVD,d0             ; fiktives Ereignis (0x8000)
 or.w     d0,ap_rbits(a0)          ; warte auf dieses
 bra      event_happened           ; APPL -> ready
app2r_ende:
 rts


**********************************************************************
*
* int wind_mctrl(d0 = int flag)
* int mctrl_0( void )
* int mctrl_1( void )
*
* Neu: flag || 0x100: check and set
*

mctrl_1:
 moveq    #1,d0

wind_mctrl:
 tst.b    d0
 beq.b    end_mctrl

beg_mctrl:
 move.b   #1,d0                    ; Hibyte unveraendert
 bsr      wind_update
 beq      begm_ende                ; Fehler bei "check and set"
 tst.w    beg_mctrl_cnt            ; schon gesetzt ?
 beq.b    begm_set_new             ; nein, setzen
 move.l   act_appl,a0
 cmpa.l   topwind_app,a0           ; bin ich auch Eigner ?
 beq.b    begm_increment           ; ja, nur Zaehler erhoehen
 bra.b    begm_set_again           ; workaround fuer Echtzeitscrolling

begm_set_new:
 move.l   menutree,mctrl_mnrett    ; Menuebaum retten
 clr.l    menutree                 ; und ungueltig machen
 lea      mctrl_btrett,a0          ; Innenbereich des obersten Fensters...
 lea      button_grect,a1          ; ...retten
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)
 move.l   keyb_app,mctrl_karett

begm_set_again:
 lea      full_g,a1                ; mir gehoert der ganze Bildschirm
 move.l   act_appl,a0
 jsr      _set_topwind_app
 move.l   act_appl,a0
 move.l   a0,topwind_app           ; auch bei keinem obersten Fenster

begm_increment:
 addq.w   #1,beg_mctrl_cnt
 bra.b    begm_ok

mctrl_0:

end_mctrl:
 subq.w   #1,beg_mctrl_cnt
 bne.b    begm_not0
 bsr.s    _end_mctrl
begm_not0:
 bsr      update_0
begm_ok:
 moveq    #1,d0                    ; kein Fehler
begm_ende:
 rts


_end_mctrl:
 lea      mctrl_btrett,a1
 move.l   mctrl_karett,a0
 jsr      _set_topwind_app
 move.l   mctrl_mnrett,menutree
 rts


**********************************************************************
*
* void Mappl_IOcomplete(a0 = APPL *ap, a1 = void *zeropage)
*
* wie appl_IOcomplete, aber kann im Mac-Interrupt aufgerufen werden.
* Dazu muss ein Zeiger auf die unteren 32k des Atari-Speichers
* uebergeben werden.
*

Mappl_IOcomplete:
 move     sr,d1
 ori.w    #$700,sr
 move.w   ap_id(a0),a0
 add.l    a1,a0
 tas.b    iocpbuf(a0)
 bne.b    aioc_err                 ; war schon gesetzt ???!!!???
 addq.w   #1,iocpbuf_cnt(a1)       ; Atari-Zeropage
Maioc_err:
 move.w   d1,sr
 rts


**********************************************************************
*
* void appl_IOcomplete(a0 = APPL *ap)
*
* wird im Interrupt aufgerufen und weckt die Applikation <ap> auf,
* die gerade auf ein Hardware- Ereignis (z.B. DMA complete oder
* Centronics busy) wartet.
*

appl_IOcomplete:
 move     sr,d1
 ori.w    #$700,sr
 move.w   ap_id(a0),a0
 tas.b    iocpbuf(a0)
 bne.b    aioc_err                 ; war schon gesetzt ???!!!???
 addq.w   #1,iocpbuf_cnt
aioc_err:
 move.w   d1,sr
 rts


**********************************************************************
*
* int write_evnt_to_ringbuf(void (*pgm)(long code), long code)
*
* Wird im Interrupt aufgerufen. aendert d0/d1/a0
* Schreibt die Adresse einer Routine und einen Code in den
* Event- Ringpuffer, falls genuegend Platz da ist.
* Anhand der Behandlungsroutine <pgm> kann man spaeter unterscheiden, ob
* es sich um einen Tastaturcode, Mauskoordinaten oder einen Timerzaehler
* handelt.
* Rueckgabe 0, wenn Puffer voll (32 Eintraege)
*
* Tastatur:     code == int  taste;int shiftstatus
* Timer:        code == long timer_cntup (Clicks seit Start des letzten Countdowns)
* Maustaste:    code == int  status;int nclicks
* Mausposition: code == int  x;int y
*

write_evnt_to_ringbuf:
 move     sr,d1
 ori.w    #$700,sr
 cmpi.w   #RNGBFLEN,ringbuf_cnt    ; Ringpuffer mehr als 32 Eintraege ?
 bcc.b    we2r_overflow            ; ja, Puffer voll
 lea      ringbuf,a0               ; Ringpuffer
 move.w   ringbuf_tail,d0          ; Pufferoffset
 lsl.w    #3,d0                    ; fuer Eintraege mit 2 Langworten
 add.w    d0,a0
 addq.w   #1,ringbuf_tail          ; Pufferoffset erhoehen
 cmpi.w   #RNGBFLEN,ringbuf_tail   ; Ende erreicht ?
 bne.b    we2r_cycle               ; nein
 clr.w    ringbuf_tail             ; zyklisch weiter
we2r_cycle:
 move.l   4(sp),(a0)+              ; Behandlungsroutine
 move.l   8(sp),(a0)               ; Code
 addq.w   #1,ringbuf_cnt           ; Fuellzaehler erhoehen
 moveq    #1,d0
 move     d1,sr
 rts
we2r_overflow:
 moveq    #0,d0
 move     d1,sr
 rts


**********************************************************************
*
* void ap_to_lastready(a0 = APPL *ap)
*
* Haengt <ap> an das Ende der durch act_appl vorgegebenen Liste
*

ap_to_lastready:
 sf.b     ap_status(a0)            ; ap_status = ready
 lea      act_appl,a2              ; Vorgaenger
_ap_to_last:
 movea.l  (a2),a1                  ; zu testende Applikation
 bra.b    a2l_next
a2l_loop:
 movea.l  a1,a2
 movea.l  (a2),a1                  ; Naechste APP
a2l_next:
 move.l   a1,d0                    ; Ende der Liste ?
 bne.b    a2l_loop                 ; noch nicht erreicht
 move.l   a1,(a0)                  ; NULL wird Nachfolger von ap
 move.l   a0,(a2)                  ; ap wird Nachfolger des letzten der Liste
 rts


**********************************************************************
*
* void read_evnts_from_ringbuf(void)
*


* Schleife: Puffereintrag holen
refr_loop:
 subq.w   #1,ringbuf_cnt
 lea      ringbuf_head,a0
 move.w   (a0),d0
 addq.w   #1,(a0)
 cmpi.w   #RNGBFLEN-1,d0
 bne.b    refr_nowrap
 clr.w    (a0)                     ; Zyklisch erhoehen
refr_nowrap:
 lea      ringbuf,a1               ; Ringpuffer
 lsl.w    #3,d0                    ; wegen 2 Langwort- Zugriff
 adda.w   d0,a1
 movea.l  (a1)+,a0                 ; Behandlungsroutine
 move.l   (a1),-(sp)               ; Daten
 move.w   d1,sr                    ; enable_interrupt (erst HIER!!!)

 tst.w    aptr_flag                ; appl_trecord laeuft ?
 bne      refr_aptr                ; ja
refr_exec:
 jsr      (a0)                     ; Behandlungsroutine aufrufen
 addq.l   #4,sp

* naechster Event

read_evnts_from_ringbuf:
 move.w   sr,d1
 ori.w    #$700,sr                 ; die einzig korrekte Methode
 tst.w    ringbuf_cnt              ; solange noch Eintraege drin sind...
 bne      refr_loop                ; weitermachen
 tst.w    iocpbuf_cnt
 beq.b    refr_ende

* Signale IOcomplete abarbeiten

 movem.l  a4/a5/d7,-(sp)
 lea      iocpbuf,a5
 lea      applx,a4
 moveq    #NAPPS-1,d7
refr_loop2:
 move.l   (a4)+,a0
 tst.b    (a5)+
 beq.b    refr_nxt2
 clr.b    -1(a5)

 move.l   a0,d0
 ble.b    refr_nxt2                ; ungueltig oder eingefroren
;move.l   a0,a0
 move.w   #EV_IO,d0
 bsr      event_happened

refr_nxt2:
 dbra     d7,refr_loop2
 clr.w    iocpbuf_cnt
 movem.l  (sp)+,a4/a5/d7

* Sonder-Events
* =============

* Warmstart auf Ctrl-Alt-Del

 tst.w    was_warmboot
 beq.b    refr_spec_nxt
 clr.w    was_warmboot
 jsr      enab_warmb                    ; Naechstes Mal Reset machen
 move.w   d1,sr
 bra.b    init_shutdown

* Maustaste nach Ringpufferueberlauf "nachholen"

refr_spec_nxt:
 tst.w    int_but_dirty                 ; war Ueberlauf des Ringpuffers ?
 beq.b    refr_ende                     ; nein
 clr.w    int_but_dirty
 move.w   int_butstate,d0               ; gueltiger Zustand
 move.w   #-1,int_butstate              ; gespeicherter Wert ist ungueltig!
 bsr      but_int                       ; Neudruecken der Maustaste simulieren
refr_ende:
 move.w   d1,sr
 rts


**********************************************************************
*
* void init_shutdown(void)
*
* Wenn ein "write back daemon" geladen ist, bekommt er sicherheits-
* halber eine AP_TERM-Nachricht.
* Weiterhin bekommt die Applikation #0 eine AP_TERM-Nachricht.
* Als Initiator des "shutdown" wird die ap_id -1 angegeben, weil es
* per Ctrl-Alt-Del ausgeloest wurde. Die Applikation #0 sollte den
* Prozess SHUTDOWN starten, der alles weitere erledigt.
*

init_shutdown:
 tst.l    (bufl_wback).l           ; write back daemon geladen ?
 beq.b    inisd_nowb               ; nein
 moveq    #-1,d0
 move.l   (bufl_wback).l,a0            ; PD => APPL
 jsr      srch_process
 move.w   d0,d1                    ; dst_apid
 bmi.b    inisd_nowb               ; ???
 bsr.b    inisd_send
inisd_nowb:
 moveq    #0,d1                    ; dst_apid
inisd_send:
 moveq    #AP_TERM,d0
 moveq    #-1,d2
 clr.l    -(sp)                    ; buf[6,7] = 0
 move.w   d0,-(sp)                 ; buf[5] = Grund fuer AP_TERM: shutdown
 clr.w    -(sp)                    ; buf[4] = 0
 move.w   d2,-(sp)                 ; buf[3]: Initiator unbekannt (System)
 clr.w    -(sp)                    ; buf[2] = 0 (keine Ueberlaenge)
 move.w   d2,-(sp)                 ; buf[1]: Absender unbekannt (System)
 move.w   d0,-(sp)                 ; buf[0] = Nachrichtennummer

 move.l   sp,a0                    ; buf
 moveq    #16,d0                   ; 16 Bytes
;move.w   d1,d1                    ; dst_apid
 bsr      appl_write
 adda.w   #16,sp
 rts

refr_aptr:
* bei appl_trecord Timerevents zusammenfassen
 cmpa.l   #handle_tim,a0
 bne.b    refr_notim
 movea.l  aptr_buf,a1
 subq.l   #8,a1                    ; vorheriger Eintrag
 cmp.l    #handle_tim,(a1)+
 bne.b    refr_notim
 move.l   (sp),d0
 add.l    d0,(a1)
 bra      refr_exec
refr_notim:
 move.l   a0,-(sp)
 moveq    #8,d0
 move.l   sp,a1
 move.l   aptr_buf,a0
 jsr      vmemcpy                   ; Puffereintrag nach (aptr_buf) kopieren
 move.l   (sp)+,a0

 addq.l   #8,aptr_buf              ; Zeiger erhoehen
 subq.w   #1,aptr_count            ; Anzahl der freien Eintraeger dekrementieren
 move.w   aptr_count,aptr_flag     ; weitermachen, wenn != 0
 bra      refr_exec


**********************************************************************
*
* void check_kb( void )
*
* Pollt die Tastatur, aendert d0/d1/d2/a0/a1
* Wird nicht im Interrupt aufgerufen, darf aber jetzt in MAGIX
*

check_kb:
 move.w   sr,d2
 ori.w    #$700,sr
 move.b   kbshift,d1
     IF   MACOS_SUPPORT
 andi.w   #$2f,d1                  ; Command beruecksichtigen
     ELSE
 andi.w   #$f,d1
     ENDIF
 lea      iorec_kb+6,a0            ; *Head-Index
 cmpm.w   (a0)+,(a0)+              ; Head-Index mit Tail-Index vergleichen
 beq      ckb_nokey                ; Puffer ist leer
 movea.l  keyb_app,a0
 cmpi.w   #8,ap_kbcnt(a0)
 scc.b    d0                       ; Tastaturpuffer voll
 move.w   d2,-(sp)
 lea      iorec_kb,a0
 move.w   6(a0),d2                 ; head
 addq.w   #4,d2
 move.l   (a0)+,a1                 ; Pufferzeiger
 cmp.w    (a0)+,d2                 ; head mit Puffergroesse vergleichen
 bcs.b    ckb_noturn
 moveq    #0,d2                    ; Pufferzeiger auf Pufferbeginn
ckb_noturn:
 add.w    d2,a1                    ; Puffer+head
 cmpi.b   #4+8,d1                  ; CTRL+ALT ?
 bne      ckb_no_ca                ; nein

* SONDERBEHANDLUNG DER CTRL-ALT-xxx

 cmpi.b   #$1b,3(a1)               ; ja, war Esc ?
 bne      ckb_no_esc               ; nein
* CTRL-ALT-ESC
 move.w   d2,(a0)                  ; Taste entfernen
 move.w   (sp)+,sr
 bsr      appl_info                ; Aktion, aendert nicht a2
 bra      check_kb                 ; wieder zurueck

ckb_no_esc:
 cmpi.b   #$60,1(a1)
 bne.b    ckb_nxtca
* CTRL-ALT-'<'
 moveq    #6,d1                    ; Spezialfunktion #6: Alle einblenden
 bra.b    ckb_send_spec
ckb_nxtca:
 cmpi.b   #$33,1(a1)
 bne.b    ckb_nxtca2
* CTRL-ALT-','
 moveq    #7,d1                    ; Spezialfunktion #7: Andere ausblenden
 bra.b    ckb_send_spec
ckb_nxtca2:
 cmpi.b   #$35,1(a1)
 bne.b    ckb_nxtca3
* CTRL-ALT-'-'
 moveq    #8,d1                    ; Spezialfunktion #8: Aktuelle ausblenden
 bra.b    ckb_send_spec
ckb_nxtca3:
 cmpi.b   #$47,1(a1)
 bne.b    ckb_nxtca4
* CTRL-ALT-Clr
 moveq    #0,d1                    ; Spezialfunktion #0: Aufraeumen
 bra.b    ckb_send_spec
ckb_nxtca4:
 cmpi.b   #9,3(a1)                 ; ja, war Tab ?
 bne      ckb_no_ca                ; nein
 tst.b    hotkey_sem
 bne.b    ckb_no_ca
* CTRL-ALT-TAB
 moveq    #5,d1                    ; Spezialfunktion #5: APP wechseln
ckb_send_spec:
 move.w   d2,(a0)                  ; Taste entfernen
 move.w   (sp)+,sr
 clr.w    -(sp)                    ; Dummy
 move.w   d1,-(sp)
 pea      handle_spec(pc)          ; Tastaturbehandlungsroutine
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 bra      check_kb                 ; wieder zurueck

* ENDE DER SONDERBEHANDLUNG

ckb_no_ca:
 tst.b    d0                       ; APP- Tastaturpuffer voll ?
 bne      ckb_nosend               ; ja, Taste nicht holen
ckb_getkey:
 move.w   d2,(a0)                  ; neuer Head-Index
 move.l   (a1),d2                  ; Zeichen (Long)
 move.l   d2,d0
 lsr.l    #8,d0                    ; Scancode nach Bit 8..15
 move.b   d2,d0                    ; ASCII    nach Bit 0..7
 move.w   (sp)+,d2
ckb_send:
 move.w   d2,sr
 move.w   d1,-(sp)                 ; Shiftstatus
 move.w   d0,-(sp)                 ; Taste
 pea      handle_key(pc)           ; Tastaturbehandlungsroutine
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 rts
ckb_nosend:
 move.w   (sp)+,d2
ckb_nokey:
 moveq    #0,d0
 cmp.w    gr_mkkstate,d1
 bne.b    ckb_send
 move.w   d2,sr
 rts


**********************************************************************
*
* void handle_tim(long clicks)
*
* Bearbeitet einen aus dem Ringpuffer geholten Timerablauf
*

handle_tim:
 move.l   4(sp),d1
 lea      timer_evlist,a1
 bra.b    ht_next
ht_loop:
 move.l   d0,a0
 move.l   d1,d0
 sub.l    4(a0),d1                 ; ap_ms: Offset in absolut umrechnen
 sub.l    d0,4(a0)                 ; soviele Klicks sind passiert
 bgt.b    ht_end                   ; noch nicht abgelaufen
 move.l   (a0),(a1)                ; aus timer_evlist ausklinken

 suba.w   #ap_nxttim,a0            ; in APPL umrechnen
 btst     #EVB_TIM,ap_rbits+1(a0)  ; wartet auf EV_TIM ?
 beq.b    ht_err                   ; nein
 btst     #EVB_TIM,ap_hbits+1(a0)  ; EV_TIM schon eingetroffen?
 bne.b    ht_err                   ; ja

 move.l   d1,-(sp)
;move.l   a0,a0
 moveq    #EV_TIM,d0
 bsr      event_happened
 move.l   (sp)+,d1

ht_err:
 lea      timer_evlist,a1          ; von vorn anfangen
ht_next:
 move.l   (a1),d0
 bne.b    ht_loop
 rts
ht_end:
 move.w   sr,d0
 ori.w    #$700,sr
 move.l   4(a0),timer_cntdown
 clr.l    timer_cntup
 move.w   d0,sr
 rts


**********************************************************************
*
* void handle_alm(long clicks)
*
* Bearbeitet einen aus dem Ringpuffer geholten Alarm-Ablauf
*

handle_alm:
 move.l   4(sp),d1
 lea      alrm_evlist,a1
 bra.b    ha_next
ha_loop:
 move.l   d0,a0
 move.l   d1,d0
 sub.l    4(a0),d1                 ; ap_alrmms: Offset in absolut umrechnen
 sub.l    d0,4(a0)                 ; soviele Klicks sind passiert
 bgt.b    ha_end                   ; noch nicht abgelaufen
 move.l   (a0),(a1)                ; aus alrm_evlist ausklinken

 suba.w   #ap_nxtalrm,a0           ; in APPL umrechnen
 move.l   ap_pd(a0),d0
 beq.b    ha_err
 move.l   d0,a0
 move.l   d1,-(sp)

 move.w   #SIGALRM,-(sp)
 move.w   p_procid(a0),-(sp)       ; pid
 move.w   #$111,-(sp)              ; Gemdos Pkill
 trap     #1
 addq.l   #6,sp

 move.l   (sp)+,d1

ha_err:
 lea      alrm_evlist,a1      ; von vorn anfangen
ha_next:
 move.l   (a1),d0
 bne.b    ha_loop
 rts
ha_end:
 move.w   sr,d0
 ori.w    #$700,sr
 move.l   4(a0),alrm_cntdown
 clr.l    alrm_cntup
 move.w   d0,sr
 rts


**********************************************************************
*
* void appl_begcritic( void  )
*
* Die Applikation <act_appl> tritt in eine kritische Phase ein,
* d.h. sie darf nicht terminiert werden.
* Der ap_critic- Zaehler wird erhoeht.
*
* aendert nur a2/d2
*

appl_begcritic:
 move.l   act_appl,d2
 ble.b    apbc_end
 move.l   d2,a2
 addq.w   #1,ap_critic(a2)
apbc_end:
 rts


**********************************************************************
*
* void appl_endcritic(a0 = APPL *ap )
*
* Die Applikation <act_appl> tritt aus einer kritische Phase aus,
* d.h. sie darf wieder terminiert werden, wenn der ap_critic-
* Zaehler 0 ist.
* Wenn zwischenzeitlich eine Terminierung des Prozesses verlangt
* worden ist, wird sie hier durchgefuehrt.
*
* Wenn zwischenzeitlich ein Anhalten der Applikation verlangt
* worden ist, wird sie hier durchgefuehrt.
*
* aendert nur a2/d2
*

appl_endcritic:
 move.l   act_appl,d2
 ble.b    apec_end
 move.l   d2,a2
 subq.w   #1,ap_critic(a2)
 bne.b    apec_end
 move.b   ap_crit_act(a2),d2            ; Aktionen ?
 beq.b    apec_end                      ; nein
 clr.b    ap_crit_act(a2)               ; bearbeitet
 btst     #0,d2
 bne.b    apec_killed
 btst     #1,d2                         ; soll angehalten werden ?
 bne.b    apec_sigstop                  ; ja
 btst     #2,d2
 beq.b    apec_end
* Signale behandeln
 movem.l  d0-d1/a0-a1,-(sp)
 move.l   act_pd.l,a0
 jsr      do_signals
 movem.l  (sp)+,d0-d1/a0-a1
 rts
apec_sigstop:
 st.b     ap_stpsig(a2)                 ; bin durch Signal gestoppt
 move.l   a2,a0
 bsr      stp_thr                       ; wir halten uns an
 bra      appl_yield                    ; hier schlafen wir ein
apec_killed:
 jmp      appl_break
apec_end:
 rts


**********************************************************************
*
* int evnt_sem(d0 = int mode, a0 = BLOCKAGE *bl, d1 = long timeout )
*
* 0  SEM_FREE  Semaphore freigeben
*              a0 = Zeiger auf Semaphore
*    -> 0      OK
*    -> -1     Semaphore unbenutzt oder von anderer APP benutzt
*
* 1  SEM_SET   Semaphore setzen, ggf. warten
*              a0 = Zeiger auf Semaphore
*              d1 = Timeout in 50Hz- Ticks
*    -> 0      OK
*    -> 1      Timeout
*    -> -1     Semaphore war schon von mir gesetzt
*    -> -2     Semaphore zwischenzeitlich entfernt
*
* 2  SEM_TEST  Eigner der Semaphore zurueckgeben (ggf. NULL)
*              a0 = Zeiger auf Semaphore
*    -> >0     Eigner
*    ->  0     nicht benutzt
*
* 3  SEM_CSET  Semaphore setzen, falls nicht schon gesetzt
*              a0 = Zeiger auf Semaphore
*    ->  0     OK
*    ->  1     Semaphore von anderer APPL gesetzt
*    ->  -1    Semaphore war schon von mir gesetzt
*
* 4  SEM_GET   Semaphore ermitteln, falls Name bekannt ist.
*              d1 = Name der Semaphore
*    ->  >0    Zeiger auf Semaphore
*    ->  -1    Semaphore nicht gefunden
*
* 5  SEM_CREATE Semaphore erstellen, d.h. neue einrichten
*              a0 = Zeiger auf Semaphore
*              d1 = Name
*    void
*
* 6  SEM_DEL   Semaphore entfernen
*              a0 = Zeiger auf Semaphore
*    ->   0    OK
*    ->  -1    Semaphore nicht gueltig
*
* 7  SEM_FALL  alle Semaphoren fuer appl freigeben
*              a0 = APPL *
*
* 8  SEM_FPD   alle Semaphoren fuer <pd> freigeben
*              a0 = PD *
*

evnt_sem:
 cmpi.w   #8,d0
 bhi      evs_err
 move.l   act_appl,a1
 add.w    d0,d0
 move.w   evstab(pc,d0.w),d0
 jmp      evstab(pc,d0.w)

evstab:
 DC.W     evs_free-evstab     ; 0
 DC.W     evs_set-evstab      ; 1
 DC.W     evs_test-evstab     ; 2
 DC.W     evs_cset-evstab     ; 3
 DC.W     evs_get-evstab      ; 4
 DC.W     evs_create-evstab   ; 5
 DC.W     evs_del-evstab      ; 6
 DC.W     evs_fall-evstab     ; 7
 DC.W     evs_fpd-evstab      ; 8

* case 0 (SEM_FREE):

evs_free:
 cmpa.l   bl_app(a0),a1       ; bin ich ueberhaupt Eigner ?
 bne      evs_err             ; nein, Fehler
 bsr      free_semaphore      ; Semaphore freigeben
 moveq    #0,d0
 rts

* case 1 (SEM_SET):

evs_set:
 move.l   bl_app(a0),d2
 beq.b    evs_s1              ; unbenutzt, sofort besetzen
 cmpa.l   d2,a1               ; bin ich schon Eigner ?
 beq      evs_err             ; ja, Fehler
 move.l   bl_waiting(a0),ap_nxtsem(a1)
 move.l   a1,bl_waiting(a0)   ; vorn einhaengen
 move.l   a0,ap_semaph(a1)    ; zur Info

 move.l   d1,d0               ; mit TimeOut ?
 beq.b    evs_notim           ; nein, warte unbegrenzt
;move.l   d0,d0
 bsr      wait_timer
 move.l   #EV_TIM+EV_SEM,d0
 move.l   act_appl,a1
 bsr      appl_wait
 move.l   act_appl,a0
 bsr      __rmv_ap_timer
 move.l   act_appl,a0
 btst     #EVB_SEM,ap_hbits+1(a0)
 bne.b    evs_tstdel          ; evnt_sem eingetroffen
 moveq    #1,d0               ; TimeOut
 rts
evs_notim:
 moveq    #EV_SEM,d0
;move.l   a1,a1
 bsr      appl_wait
 move.l   act_appl,a0
evs_tstdel:
 tst.l    ap_semaph(a0)       ; Semaphore noch gueltig ?
 bne.b    evs_ok              ; ja!
 moveq    #-2,d0              ; Semaphore zwischenzeitlich geloescht
 rts
evs_s1:
 move.l   a1,bl_app(a0)
 beq.b    evs_ok              ; !neu! AES noch nicht initialisiert
 move.l   ap_pd(a1),bl_pd(a0) ; !neu!
evs_ok:
 moveq    #0,d0
 rts

* case 2 (SEM_TEST):

evs_test:
 move.l   bl_app(a0),d0
 rts

* case 3 (SEM_CSET):

evs_cset:
 move.l   bl_app(a0),d2
 beq.b    evs_s1              ; unbenutzt, sofort besetzen
 cmpa.l   d2,a1               ; bin ich schon Eigner ?
 beq      evs_err             ; ja, Fehler
 moveq    #1,d0               ; anderer Eigner
 rts

* case 4 (SEM_GET):

evs_get:
 lea      first_sem,a0
evg_loop:
 cmp.l    bl_name(a0),d1
 beq.b    evg_ok
 move.l   bl_next(a0),d0
 move.l   d0,a0
 bne.b    evg_loop
 moveq    #-1,d0
 rts
evg_ok:
 move.l   a0,d0
 rts

* case 5 (SEM_CREATE):

evs_create:
 lea      first_sem,a1
evc_loop:
 move.l   bl_next(a1),d0
 beq.b    evc_eloop
 move.l   d0,a1
 bra.b    evc_loop
evc_eloop:
 move.l   d1,bl_name(a0)
 clr.l    bl_next(a0)
 clr.l    bl_app(a0)
 clr.l    bl_waiting(a0)
 clr.w    bl_cnt(a0)          ; nur fuer _SCR von Bedeutung
 move.l   a0,bl_next(a1)
 rts

* case 6 (SEM_DEL):

evs_del:
 move.l   bl_app(a0),d2
 beq.b    evd_weiter          ; unbenutzt, kann geloescht werden
 cmpa.l   d2,a1               ; bin ich Eigner ?
 bne      evs_err             ; nein, Fehler
evd_weiter:
 lea      first_sem,a1
evd_loop:
 move.l   bl_next(a1),d0
 beq.b    evs_err             ; nicht gefunden
 cmp.l    d0,a0
 beq.b    evd_ok
 move.l   d0,a1
 bra.b    evd_loop
evd_ok:
 move.l   bl_next(a0),bl_next(a1)  ; ausklinken
;move.l   a0,a0
 bsr      destroy_semaphore   ; alle APPs freigeben
 moveq    #0,d0
 rts

* case 8 (SEM_FPD):

evs_fpd:
 movem.l  a6/a5,-(sp)
 move.l   a0,a5               ; pd
 lea      first_sem,a6
evsp_loop:
 tst.l    bl_app(a6)          ; belegt ?
 beq.b    evsp_nxt            ; nein
 cmpa.l   bl_pd(a6),a5        ; unser PD ?
 bne.b    evsp_nxt            ; nein
 clr.w    bl_cnt(a6)          ; Verschachtelungszaehler auf 0 (wind_update!)
 move.l   a6,a0
 bsr      free_semaphore      ; Semaphore freigeben
evsp_nxt:
 move.l   bl_next(a6),a6
 move.l   a6,d0
 bne.b    evsp_loop
 bra.b    evs_e2

* case 7 (SEM_FALL):

evs_fall:
 movem.l  a6/a5,-(sp)
 move.l   a0,a5               ; appl
 lea      first_sem,a6
evsf_loop:
 move.l   a6,a0
 move.l   a5,a1
 bsr      evs_free            ; freigeben, ggf. Fehler ignorieren
 move.l   bl_next(a6),a6
 move.l   a6,d0
 bne.b    evsf_loop
evs_e2:
 movem.l  (sp)+,a6/a5

evs_err:
 moveq    #-1,d0
 rts


**********************************************************************
*
* PUREC int wind_update( WORD mode)
*
* int wind_update(d0 = int mode)
*
* END_UPDATE   0
* BEG_UPDATE   1
* END_MCTRL    2
* BEG_MCTRL    3
*
* "check and set" mode per (n || 0x100)
* Rueckgabe: 0 (Bildschirm nicht bekommen, bei BEG_UPDATE||0x100
*           1 sonst
*

wind_update:
 move.l   a2,-(sp)
 bsr.b    _wind_update
 move.l   (sp)+,a2
 rts
update_0:
 moveq    #0,d0
 bra.b    _wind_update
update_1:
 moveq    #1,d0
_wind_update:
 subq.b   #2,d0                    ; END_MCTRL
 bge      wind_mctrl
 addq.b   #2,d0
 lea      upd_blockage,a0
 beq      end_update
* BEG_UPDATE
 move.w   d0,d1                    ; Hibyte merken
 move.l   act_appl,a1
;lea      upd_blockage,a0
 bsr.s    _beg_update              ; veraendert nur d0
;                                  ; sind wir die sperrende Applikation ?
 bne.b    wu_ende                  ; ja, alles ok, d.h. return(1)
 andi.w   #$100,d1
 bne.b    wu_err                   ; wir haben nicht die Kontrolle
                                   ; wir werden VORNE in die Liste der
                                   ; auf die Update- Semaphore wartenden
                                   ; APPLs gehaengt
;lea      upd_blockage,a0
 move.l   bl_waiting(a0),ap_nxtsem(a1)
 move.l   a1,bl_waiting(a0)        ; einhaengen
 move.l   a0,ap_semaph(a1)         ; zur Info
 moveq    #EV_SEM,d0
;move.l   a1,a1
 bsr      appl_wait
 moveq    #1,d0
wu_ende:
 rts
wu_err:
 moveq    #0,d0                    ; Fehler: wir haben nicht die Semaphore
 rts


**********************************************************************
*
* EQ/NE int _beg_update(a0 = BLOCKAGE *b, a1 = APPL *act_appl)
*
* Gibt eine 1 zurueck, wenn wir die sperrende Applikation sind, ansonsten
* eine 0 (wenn wir gesperrt sind).
* Veraendert nur d0
*

_beg_update:
 addq.w   #1,(a0)                  ; Zaehler inkrementieren
 cmp.l    bl_app(a0),a1            ; ist es unsere Semaphore ?
 beq.b    _begu_ok                 ; ja, return(1)
 cmpi.w   #1,(a0)                  ; nein, war Zaehler vorher 0 ?
 beq.b    _begu_set                ; ja, unsere Applikation setzen, return(1)
 subq.w   #1,(a0)                  ; Zaehler wieder dekrementieren
 moveq    #0,d0                    ; return(0)
 rts
_begu_set:
 move.l   a1,bl_app(a0)
 move.l   ap_pd(a1),bl_pd(a0)      ; !neu!
_begu_ok:
 moveq    #1,d0
 rts


**********************************************************************
*
* void end_update(a0 = BLOCKAGE *b)
*
* BLOCKAGE: int     count
*           APPL    *ap
*           APPL    *ap_waiting
*
* fuer wind_update(END_UPDATE)
*

end_update:
 tst.w    (a0)                     ; Zaehler auf 0 oder kleiner
 ble.b    eupd_err                 ; ja, Fehler
 subq.w   #1,(a0)                  ; Zaehler dekrementieren
 bne.b    eupd_ok                  ; noch nicht 0
 bsr.s    free_semaphore
 bsr      appl_yield
eupd_ok:
 moveq    #1,d0                    ; kein Fehler
 rts
eupd_err:
 moveq    #0,d0                    ; Fehler, Zaehler schon 0
 rts


**********************************************************************
*
* void free_semaphore(a0 = BLOCKAGE *b)
*
* gibt eine Semaphore frei und erhebt die am laengsten darauf wartende
* Applikation in den Ready- Zustand.
* Es wird KEIN Taskwechsel durchgefuehrt.
*

free_semaphore:
 lea      bl_waiting(a0),a2
 move.l   (a2),d0
 beq.b    fsem_free                ; keine Applikation
 move.l   d0,a1                    ; die zuletzt haengengebliebene APPL liegt
                                   ; VORN in der Doppelliste, daher die
                                   ; letzte APPL freigeben, das ist die, die
                                   ; am laengsten wartet (MagiX!!)
fsem_loop:
 move.l   ap_nxtsem(a1),d0
 beq.b    fsem_makeready
 lea      ap_nxtsem(a1),a2
 move.l   d0,a1
 bra.b    fsem_loop
fsem_makeready:
 clr.l    (a2)                     ; letzte APP aushaengen
 move.l   a1,bl_app(a0)            ; ev_appl umsetzen
 move.l   ap_pd(a1),bl_pd(a0)      ; !neu!
 move.w   #1,(a0)                  ; Zaehler auf 1

 moveq    #EV_SEM,d0               ; eingetroffen
 move.l   a1,a0
 bra      event_happened           ; gesperrte APPL freigeben
fsem_free:
 clr.l    bl_app(a0)               ; keine zugehoerige Applikation
 rts


**********************************************************************
*
* void destroy_semaphore(a0 = BLOCKAGE *b)
*
* gibt eine Semaphore voellig frei und erhebt alle wartenden
* Applikationen in den Ready- Zustand. Die Eintraege ap_semaph werden
* geloescht, um zu signalisieren, dass die Semaphore ungueltig ist.
* Nur Psemaphore kuemmert sich um den Rueckgabewert.
* Es wird KEIN Taskwechsel durchgefuehrt.
*

destroy_semaphore:
 move.l   a5,-(sp)
 move.l   bl_waiting(a0),a5
 clr.l    bl_waiting(a0)
 bra.b    dsem_nxt
dsem_loop:
 moveq    #EV_SEM,d0               ; eingetroffen
 move.l   a5,a0
 bsr      event_happened           ; gesperrte APPL freigeben
 clr.l    ap_semaph(a5)            ; !! signalisiere Fehler !!
 move.l   ap_nxtsem(a5),a5
dsem_nxt:
 move.l   a5,d0
 bne.b    dsem_loop
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* int read_keybuf(a0 = APPL *ap)
*

read_keybuf:
 subq.w   #1,ap_kbcnt(a0)          ; Fuellzaehler dekrementieren
 lea      ap_kbhead(a0),a1
 move.w   (a1),d0                  ; Leseposition
 addq.w   #1,(a1)                  ; kb_head erhoehen
 cmpi.w   #8,(a1)
 bne.b    rkb_nowrap
 clr.w    (a1)                     ; zyklisch erhoehen
rkb_nowrap:
 add.w    d0,d0                    ; fuer int
 move.w   ap_kbbuf(a0,d0.w),d0     ; Zeichen holen
 rts


fkb_loop:
 bsr.s    read_keybuf
flush_keybuf:
 movea.l  act_appl,a0
 tst.w    ap_kbcnt(a0)
 bne.b    fkb_loop
 rts


**********************************************************************
*
* void handle_spec(int code1, int code2)
*
* Bearbeitet ein aus dem Ringpuffer geholtes Ereignis
*

handle_spec:
 subq.l   #8,sp
 move.l   sp,a0
 move.l   #'MAGX',(a0)+            ; mbuf[4,5] = magischer Wert
 move.w   4+8(sp),(a0)+            ; mbuf[6]   = Fkt.Nr.
 clr.w    (a0)+                    ; mbuf[7]   = ap_id (dummy)
 move.l   sp,a0
 moveq    #0,d2                    ; mbuf[3] ist 0
 moveq    #1,d1                    ; dst_apid = SCRENMGR
 moveq    #SM_M_SPECIAL,d0         ; Nachrichtencode
 bsr      send_msg
 addq.l   #8,sp
 rts


**********************************************************************
*
* void handle_key(int key, int state)
*
* Bearbeitet einen aus dem Ringpuffer geholten Tastendruck
*

handle_key:
 move.w   6(sp),gr_mkkstate
 move.w   4(sp),d0
 beq.b    wrky_ende
 move.l   keyb_app,a0


**********************************************************************
*
* void write_key(a0 = APPL *ap, d0 = int key)
*
* Schreibt einen Tastendruck in die Applikation <ap>
*

write_key:
 cmpi.w   #8,ap_kbcnt(a0)          ; Puffer voll (8 Zeichen?)
 bcc.b    wrky_ende                ; ja, Ende
 lea      ap_kbtail(a0),a1
 move.w   (a1),d1                  ; kb_tail
 add.w    d1,d1                    ; * 2 fuer Wortzugriff
 move.w   d0,ap_kbbuf(a0,d1.w)     ; Taste eintragen
 addq.w   #1,(a1)                  ; kb_tail erhoehen
 cmpi.w   #8,(a1)                  ; zyklisch ?
 bne.b    wrky_nowrap
 clr.w    (a1)                     ; ja, zyklisch inkrementieren
wrky_nowrap:
 addq.w   #1,ap_kbcnt(a0)          ; Anzahl Zeichen im Puffer erhoeht
 btst     #EVB_KEY,ap_rbits+1(a0)  ; warte auf Zeichen ?
 beq.b    wrky_ende                ; nein
 btst     #EVB_KEY,ap_hbits+1(a0)  ; schon eingetroffen ?
 bne.b    wrky_ende                ; ja
;move.l   a0,a0
 moveq    #EV_KEY,d0
 bra      event_happened           ; Status pruefen
wrky_ende:
 rts

O_INFO    EQU  5

**********************************************************************
*
* void handle_but(int bstate, int nclicks)
*
* Bearbeitet einen aus dem Ringpuffer geholten Mausklick
*

handle_but:
 move.l   mouse_app,a0             ; diese Applikation bekommt den Mausklick
 cmp.l    applx+4,a0               ; ist es der Screenmanager ?
 beq      hdb_send                 ; ja

 move.w   gr_mkmstate,d0           ; bisheriger Zustand der Maustasten
 not.w    d0                       ; alte Bits loeschen
 and.w    4(sp),d0                 ; nur neue Maustasten behalten
 beq      hdb_send                 ; keine Maustaste wurde niedergedrueckt

/*
;alte Version:
 cmpi.w   #1,4(sp)                 ; nur linke Taste gedrueckt ?
 bne      hdb_send                 ; nein
 tst.w    gr_mkmstate              ; war vorher keine Taste gedrueckt ?
 bne      hdb_send                 ; doch
*/

* Nicht der Screenmanager bekommt den Klick
* Der Status wechselte von "keine Maustaste gedrueckt" nach
* "linke Maustaste gedrueckt"

* Mausklick ins oberste Fenster ?

 lea      button_grect,a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; Maus im Rechteck des obersten Fensters ?
 beq.b    hdb_notop                ; nein, weiter
 move.l   topwind_app,a0           ; Applikation des obersten Fensters
 move.l   a0,d0
 bne      hdb_send                 ; ist gueltig

* Mausklick in der Menuezeile ?

hdb_notop:
     IF   MACOS_SUPPORT
 lea      menubar_grect,a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; Maus in der Menuezeile ?
 beq      hdb_mennor               ; nein
 move.l   menutree,d0
 beq      hdb_scrnm                ; Klick an SCRENMGR
 move.l   d0,a0
 cmpi.w   #G_IBOX,24+ob_type(a0)
 bne      hdb_scrnm                ; Klick an SCRENMGR
 move.l   menu_app,a0
 bra      hdb_send                 ; Mac-Menue: Klick an Applikation
hdb_mennor:
     ELSE
 lea      menubar_grect,a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; Maus in der Menuezeile ?
 bne      hdb_scrnm                ; ja, Klick an SCRENMGR
     ENDIF

* Mausklick auf den Desktop- Hintergrund ?

 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      wind_find                ; Fenster unter Mauskoordinaten ?
 tst.w    d0
 move.l   windx,a0
 move.l   (a0),a0                  ; Fenster #0
 beq      hdb_send_owner           ; nein, Hintergrund => Eigner von Wind #0

* Mausklick auf ein Fenster, aber nicht den Arbeitsbereich des obersten
* Bei WF_BEVENT und Klick in Arbeitsbereich an entsprechende Applikation
* verschicken.

 bsr      whdl_to_wnd
 cmpi.w   #1,4(sp)                 ; nur linke Maustaste ?
 bne.b    hdb_nol                  ; nein, Klick verschicken
 btst     #WSTAT_ICONIFIED_B,w_state+1(a0)
 beq.b    hdb_noic                 ; nein

* Bei ICONIFIED und Einzelklick an die Applikation verschicken, sonst an
* den SCRENMGR

 cmpi.w   #2,6(sp)                 ; Doppelklick ?
 bne.b    hdb_nol                  ; nein, zum Owner schicken!
 bra.b    hdb_scrnm                ; ja, zum SCRENMGR

* Nicht ICONIFIED

hdb_noic:
 btst     #WATTR_BEVENT_B,w_attr+1(a0)       ; WF_BEVENT ?
 beq.b    hdb_scrnm                ; nein, Klick zum SCRENMGR
hdb_nol:
 move.l   a0,-(sp)                 ; WINDOW merken

 lea      w_work(a0),a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; Mausklick in den Arbeitsbereich ?

 move.l   (sp)+,a0                 ; WINDOW zurueck
 bne.b    hdb_send_owner           ; Mausklick an besitzende Applikation

* Kein Klick in den Arbeitsbereich.
* Bei WATTR_INFOEVENT und Klick in INFO trotzdem Nachricht an Fenstereigner

 btst     #WATTR_INFOEVENT_B,w_attr+1(a0)
 beq.b    hdb_scrnm
 tst.w    w_tree+O_INFO*24+ob_next(a0)  ; INFO gueltig ?
 bmi.b    hdb_scrnm                     ; nein!
 move.l   a0,-(sp)                 ; WINDOW merken

 move.l   w_tree+O_INFO*24+ob_width(a0),-(sp)     ; w/h
 move.l   w_tree+O_INFO*24+ob_x(a0),-(sp)         ; x/y
 move.w   w_tree+ob_x(a0),d0
 add.w    d0,g_x(sp)
 move.w   w_tree+ob_y(a0),d0
 add.w    d0,g_y(sp)

 lea      (sp),a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; Mausklick in den INFO-Bereich ?

 addq.l   #8,sp
 move.l   (sp)+,a0                 ; WINDOW zurueck
 bne.b    hdb_send_owner           ; Mausklick an besitzende Applikation

* Der Screenmanager bekommt den Klick

hdb_scrnm:
 move.l   applx+4,a0               ; an SCRENMGR senden
 bra.b    hdb_send

hdb_send_owner:
 move.l   w_owner(a0),a0

hdb_send:
 addq.w   #1,prev_count
 move.w   gr_mkmstate,prev_mkmstate     ; alten Maustastenstatus retten
 move.w   gr_mnclicks,prev_mnclicks
 move.l   gr_mkmx,prev_mkmx
;move.w   gr_mkmy,prev_mkmy

 move.w   6(sp),d1
 move.w   4(sp),d0
 move.w   d1,gr_mnclicks
 move.w   d0,gr_mkmstate           ; neuen Maustastenstatus setzen ...
;move.l   a0,a0
 bra      send_click               ; ... und senden


**********************************************************************
*
* bstate_match(int bstate, long but)
*
* Prueft einen Mauszustand anhand eines Buttoncodes
*
* but: Bits 31..24: 0:normal 1:Match invertieren
*      Bits 23..16: Anzahl Klicks
*      Bits  8..15: mask
*      Bits  0..7:  state
*

bstate_match:
 move.l   d6,-(sp)
 lea      8(sp),a0
 move.w   (a0)+,d2                 ; d2: bstate (aktueller Zustand)
 move.b   (a0),d6                  ; d6: Bits 24..31
 addq.l   #2,a0                    ; Anzahl Klicks ist egal
 move.b   (a0)+,d0                 ; d0: Bits 8..15   (mask)
 move.b   (a0),d1                  ; d1: Bits 0..7    (state)
 eor.b    d2,d1                    ; Unterschiede zwischen state und bstate
 and.b    d1,d0                    ; Unterschiede mit <mask> ANDen
 beq.b    bsm_l1                   ; keine Unterschiede => d0 = 1
 moveq    #0,d0
 bra.b    bsm_l2                   ; Unterschiede => d0 = 0
bsm_l1:
 moveq    #1,d0
bsm_l2:
 cmp.b    d0,d6                    ; Matchergebnis invertieren, wenn d6 = 1
 bne.b    bsm_l3
 moveq    #0,d0
 bra.b    bsm_l4
bsm_l3:
 moveq    #1,d0
bsm_l4:
 move.l   (sp)+,d6
 rts


**********************************************************************
*
* void send_click(a0 = APPL *dstap, d0 = int newbstate, d1 = int nclicks)
*

send_click:
 btst     #EVB_BUT,ap_rbits+1(a0)  ; warte auf EV_BUT ?
 beq      sc_ende                  ; nein
 btst     #EVB_BUT,ap_hbits+1(a0)  ; EV_BUT schon eingetroffen ?
 bne      sc_ende                  ; ja
 move.l   a0,-(sp)
 move.w   d1,-(sp)

 move.l   ap_evbut(a0),-(sp)
 move.w   d0,-(sp)
 bsr.s    bstate_match
 tst.w    d0
 beq.b    sc_end2
 move.w   (sp)+,d0
 addq.l   #4,sp
 move.w   (sp)+,d1
 move.l   (sp)+,a0
 move.w   d0,ap_evbut+2(a0)        ; mask und state setzen
 cmpi.b   #1,ap_evbut+1(a0)        ; wurde auf Mehrfachklicks gewartet ?
 bls.b    sc_nom                   ; nein
 subq.w   #1,mcl_in_events         ; ja, Zaehler dekrementieren
sc_nom:
 cmp.b    ap_evbut+1(a0),d1
 bhi.b    sc_ok
 move.b   d1,ap_evbut+1(a0)
sc_ok:
;move.l   a0,a0
 moveq    #EV_BUT,d0
 bra      event_happened
sc_end2:
 lea      12(sp),sp
sc_ende:
 rts


**********************************************************************
*
* void handle_mov(int x, int y)
*
* Bearbeitet eine aus dem Ringpuffer geholte Mausbewegung
*

handle_mov:
; move.l  #$7c000000,d0            ; sample mouse button state
; bsr     vdi_quick
 move.l   int_mx,-(sp)             ; Int-Mausposition holen

 move.w   mcl_timer,d0             ; warte ich auf einen Mehrfachklicks ?
 beq.b    hm_dcl_ok                ; nein
 move.w   gr_mkmx,d1               ; X alt
 sub.w    (sp),d1                  ; - X aktuell
 bge.b    hm_pl1
 neg.w    d1                       ; Absolutwert der Differenz
hm_pl1:
 subq.w   #2,d1
 bhi.b    hm_dcl_clr               ; Maus um > 2 bewegt => Doppelklick loeschen
 move.w   gr_mkmy,d1               ; Y alt
 sub.w    2(sp),d1                 ; - Y aktuell
 bge.b    hm_pl2
 neg.w    d1
hm_pl2:
 subq.w   #2,d1
 bls.b    hm_dcl_ok
hm_dcl_clr:
;move.w   d0,d0                    ; mcl_timer, Doppelklick loeschen
 bsr      mclick_countdown
hm_dcl_ok:
 move.l   (sp)+,gr_mkmx            ; Int -> AES-Variablen
;move.w   vptsout,gr_mkmx
;move.w   vptsout+2,gr_mkmy
 tst.w    aptp_dirtyint            ; appl_tplay aktiv ?
 beq.b    hm_no_aptp               ; nein, weiter


 move.l   #$00010002,vintin        ; vintin[0]=Maus, vintin[1]=SAMPLE
 move.l   #$21000002,d0            ; set input mode
 bsr      vdi_quick
 move.l   4(sp),d0                 ; hi:x,lo:y
 move.l   d0,vptsin                ; x,y
 move.l   d0,gr_mkmx               ; x,y

 move.w   d0,d1                    ; d1 = y
 swap     d0                       ; d0 = x
 move.l   mdraw_int_adr,a0         ; Aufruf der alten Routine
 jsr      (a0)

;move.w   4(sp),vptsin
;move.w   6(sp),vptsin+2
 move.l   #$1c010000,d0            ; input locator, request mode
 bsr      vdi_quick                ; vsm_locator
;move.w   4(sp),gr_mkmx
;move.w   6(sp),gr_mkmy


hm_no_aptp:
 tst.w    gr_mkmstate              ; Maustaste gedrueckt ?
 bne.b    hm_send                  ; ja,  weiter
 tst.w    beg_mctrl_cnt            ; Umschaltung gesperrt ?
 bne.b    hm_send                  ; ja,  weiter
* keine Maustaste gedrueckt
 tst.l    menutree                 ; Menue angemeldet ?
 beq.b    hm_send                  ; nein, weiter
 btst     #2,(config_status+2).w     ; Bit 10, pulldown menus
 bne.b    hm_send                  ; ja, weiter
     IF   MACOS_SUPPORT
 move.l   menutree,a0
 cmpi.w   #G_IBOX,24+ob_type(a0)
 beq.b    hm_send                  ; Mac-Menue!
     ENDIF
 lea      scmgr_mm+2,a0
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect
 cmp.w    scmgr_mm,d0              ; gewuenschtes Ergebnis ?
 beq.b    hm_send                  ; nein
 move.l   applx+4,a0
 bsr      set_mouse_app            ; SCRENMGR uebernimmt Mauskontrolle
hm_send:

 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 move.l   mouse_app,a0
;bra      send_mouse


**********************************************************************
*
* send_mouse(a0 = APPL *ap, d0 = int mx, d1 = int my)
*

send_mouse:
 movem.l  a5/d6/d7,-(sp)
 move.w   d0,d6                    ; d6 = x
 move.w   d1,d7                    ; d7 = y
 move.l   a0,a5                    ; a5 = ap

 btst     #EVB_MG1,ap_rbits+1(a5)  ; warte auf EV_MG1 ?
 beq.b    sm_m2                    ; nein
 btst     #EVB_MG1,ap_hbits+1(a5)  ; EV_MG1 schon eingetroffen ?
 bne.b    sm_m2                    ; ja

 move.w   d7,d1                    ; y
 move.w   d6,d0                    ; x
 move.l   ap_mgrect1(a5),a0        ; MGRECT *
 bsr.s    mouse_match
 beq.b    sm_m2                    ; nein, weiter

 move.l   a5,a0
 moveq    #EV_MG1,d0
 bsr      event_happened

sm_m2:
 btst     #EVB_MG2,ap_rbits+1(a5)  ; warte auf EV_MG2 ?
 beq      sm_ende                  ; nein, auch nicht
 btst     #EVB_MG2,ap_hbits+1(a5)  ; EV_MG2 schon eingetroffen ?
 bne      sm_ende                  ; ja

 move.w   d7,d1                    ; y
 move.w   d6,d0                    ; x
 move.l   ap_mgrect2(a5),a0        ; MGRECT *
 bsr.s    mouse_match
 beq.b    sm_ende                  ; nein, weiter

 move.l   a5,a0
 moveq    #EV_MG2,d0
 bsr      event_happened

sm_ende:
 movem.l  (sp)+,a5/d6/d7
 rts


**********************************************************************
*
* EQ/NE mouse_match(a0 = MGRECT *mg, d0 = int x, d1 = int y)
*

mouse_match:
 subq.l   #8,sp
 tst.w    (a0)+                    ; mg_flag bei evnt_mouse
 sne      d2
 andi.w   #1,d2
 move.l   (a0)+,(sp)               ; ev_data1 (x,y)

 move.l   (a0),4(sp)               ; ev_data2 (w,h)

 lea      (sp),a0
 move.w   d2,-(sp)                 ; d2 retten
;move.w   d1,d1
;move.w   d0,d0
 jsr      xy_in_grect
 cmp.w    (sp)+,d0
 addq.l   #8,sp
 rts


**********************************************************************
*
* rw_ap_buf(d0 = char rwflag, a0 = PARM *parm)
*
* Wird beim Schreiben von Nachrichten aufgerufen mit:
*
*  rwflag = 0:      lesen
*  rwflag = 2:      schreiben, Nachrichten verschmelzen
*  rwflag = 1:      schreiben, ggf. Nachrichten verschmelzen
*
*  parm   Zeiger auf eine Struktur mit Offset 0: APPL *dst_ap
*                                             4: int  msg_len
*                                             6: char *buf
*  dst_ap    Zielapplikation
*
* Schreibt eine Message in den 256- Byte- Puffer der Applikation und
* verschmilzt Redraws und WM_ARROWED.
*

rw_ap_buf:
 movem.l  d5/d6/d7/a3/a4/a5,-(sp)
 suba.w   #16,sp                   ; GRECT[2]
 movea.l  (a0)+,a5                 ; a5 = app
 move.w   (a0)+,d7                 ; d7 = msg_len
 move.l   (a0),a3                  ; a3 = buf
 move.b   d0,d2
 beq      rwap_read

* schreiben aufs Pufferende
* Einfach die ganze Nachricht in den Puffer hauen (hinter die dort schon
* stehenden Daten)
 move.w   d7,d0                    ; Anzahl Bytes
 move.l   a3,a1                    ; Quelle = buf
 lea      ap_buf(a5),a3            ; ap_buf
 adda.w   ap_len(a5),a3            ; ap_buf+ap_len
 move.l   a3,a0                    ; Ziel = Ende des Puffers
 jsr      vmemcpy                   ; aendert nicht d2 !
* a3 = Zeiger auf unsere kopierte Nachricht
 subq.b   #2,d2                    ; Nachricht verschmelzen ?
 beq.b    scan_msgs                ; ja!
 cmpi.w   #WM_ONTOP,(a3)           ; MultiTOS !
 beq.b    scan_msgs
 cmpi.w   #WM_REDRAW,(a3)
 beq.b    scan_msgs
 cmpi.w   #WM_ARROWED,(a3)         ; WM_ARROWED,WM_HSLID,WM_VSLID
 bcs      rwap_wr_ready
 cmpi.w   #WM_VSLID,(a3)
 bhi      rwap_wr_ready

* neue Nachricht war WM_REDRAW oder WM_ARROWED oder WM_HSLID oder WM_VSLID
* oder WM_ONTOP (neu!) oder mode == 2 (neu!!)
* for  (d6 = 0; Anzahl Bytes != 0)

scan_msgs:
 clr.w    d5                       ; noch kein Redraw- Rechteck
 clr.w    d6                       ; bei Pufferoffset 0 beginnen
 bra.b    rwap_l1

* Schleife
scan_loop:
 lea      ap_buf(a5,d6.w),a4       ; a4 auf Message
 move.w   (a4),d0                  ; d0 = Nachrichtencode
 cmp.w    (a3),d0                  ;  stimmt mit neuer Nachricht ueberein?
 bne      rwap_l2                  ;   nein, naechste Nachricht
 cmpi.w   #WM_REDRAW,d0
 beq.b    rab_redraw

* WM_ARROWED, WM_HSLID, WM_VSLID, WM_ONTOP
* alte Nachricht einfach ueberschreiben und Ende
rab_overwr:
 move.l   (a3)+,(a4)+
 move.l   (a3)+,(a4)+
 move.l   (a3)+,(a4)+
 move.l   (a3),(a4)
 bra      rwap_end

* WM_REDRAW
rab_redraw:
 move.w   6(a3),d0
 cmp.w    6(a4),d0
 bne.b    rwap_l2
* WM_REDRAW und Handles identisch (dasselbe Fenster):
* Message merken und Anzahl mitzaehlen
 cmpi.w   #2,d5
 bge.b    scanloop_end
 move.w   d5,d0
 add.w    d0,d0
 add.w    d0,d0                    ; fuer Langwortzugriff
 lea      (sp),a0
 move.l   a4,0(a0,d0.w)            ; REDRAW- Message merken
 addq.w   #1,d5                    ; Zaehler erhoehen

* d6 zeigt auf die naechste Nachricht
rwap_l2:
 moveq    #$10,d0
 cmpi.w   #$ffff,4(a4)             ; Ueberlaenge == -1 ?
 beq.b    rwap_l3
 add.w    4(a4),d0
rwap_l3:
 add.w    d0,d6
rwap_l1:
 cmp.w    ap_len(a5),d6
 bcs.b    scan_loop                ; noch nicht Puffer- Ende

scanloop_end:
 tst.w    d5                       ; zusaetzliche GRECTS ?
 beq.b    rwap_wr_ready            ; nein, ok

* Wir haben schon Redraw- Rechtecke. Pruefen, ob verschmelzen usw.

 lea      (sp),a4
 cmpi.w   #2,d5
 blt.b    rwap_weiter

* Wir haben schon zwei Rechtecke, also insgesamt jetzt 3
* Alle werden einfach mit dem ersten verschmolzen und das zweite eliminiert
 move.l   (a4),a1
 addq.l   #8,a1                    ; erstes Rechteck
 lea      8(a3),a0                 ; neues Rechteck
 jsr      grects_union

 move.l   (a4)+,a1
 addq.l   #8,a1                    ; erstes Rechteck
 move.l   (a4),a0
 addq.l   #8,a0                    ; zweites Rechteck
 jsr      grects_union

 moveq    #$10,d0
 add.l    (a4),d0                  ; d0 aufs Ende der zu loeschenden Msg.
 move.w   ap_len(a5),d1
 lea      ap_buf(a5,d1.w),a0
 move.l   a0,d1                    ; d1 aufs Ende des Puffers
 sub.l    d0,d1                    ; d1 = Anzahl der zu kopierenden Bytes
 beq.b    cfertig                  ; nix zu kopieren
 move.l   d0,a1                    ; Quelle
 move.w   d1,d0                    ; Anzahl Bytes
 move.l   (a4),a0
 jsr      vmemcpy
cfertig:
 moveq    #-$10,d7                 ; Puffer um 16 verkleinert
 bra.b    rwap_wr_ready

* Wir haben erst ein Rechteck, also insgesamt jetzt 2
* Wenn sie sich nicht ueberlappen, sind wir fertig
rwap_weiter:
 addq.l   #8,(a4)                  ; Offset fuers GRECT in der Message
 addq.l   #8,a3                    ; Offset fuers GRECT in der neuen Message
 btst     #6,(config_status+3).w
 bne.b    rwap_nosmart             ; Smart Redraw OFF

 lea      8(sp),a0
 move.l   a0,a1
 move.l   (a3),(a0)+
 move.l   4(a3),(a0)               ; neues Rechteck in temporaeren Puffer
 move.l   (a4),a0
 jsr      grects_intersect

 tst.w    d0
 beq.b    rwap_wr_ready                  ; kein Schnitt => fertig
* wir haben zwei Rechtecke, die sich ueberlappen, also verschmelzen
rwap_nosmart:
 move.l   (a4),a1
 move.l   a3,a0
 jsr      grects_union

 moveq    #0,d7                    ; Pufferlaenge nicht veraendert

rwap_wr_ready:
 add.w    d7,ap_len(a5)            ; Pufferoffset erhoehen
 bra.b    rwap_end

* lesen vom Pufferanfang
rwap_read:
 move.w   d7,d0
 lea      ap_buf(a5),a1
 move.l   a3,a0
 jsr      vmemcpy

 sub.w    d7,ap_len(a5)
 move.w   ap_len(a5),d0
 beq.b    rwap_end

;move.w   d0,d0
 lea      ap_buf(a5,d7.w),a1       ; Quelle
 lea      ap_buf(a5),a0            ; Ziel
 jsr      vmemcpy

rwap_end:
 adda.w   #16,sp
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5
 rts



**********************************************************************
**********************************************************************
*
* Interruptroutinen, die in den Vektoren des VDI haengen
*

* Mausbutton- Interrupt

but_int:
 movem.l  d0/d1/d2/a0/a1/a2,-(sp)
 cmp.w    int_butstate,d0          ; Hat sich Zustand geaendert ?
 beq.b    but_int_ignore           ; nein, Ende
 tst.w    mcl_timer                ; warte ich auf einen (n+1)-ten Klick ?
 beq.b    but_int_1st              ; nein
 cmp.w    mcl_bstate,d0            ; gleicher Status wie beim 1. Klick ?
 bne.b    but_int_store            ; nein, vergessen
 addq.w   #1,mcl_count             ; Zaehler fuer Mehrfachklicks erhoehen
 addq.w   #3,mcl_timer             ; Zeitintervall fuer weitere Klicks erhoehen
 bra.b    but_int_store            ; Klick noch nicht uebermitteln
* Vorher kam kein Klick, dies ist kein 2ter eines vorherigen Klick
but_int_1st:
 tst.w    mcl_in_events            ; warte ich auf mehrfach- Klicks ?
 beq.b    but_int_send1            ; nein
 tst.w    d0                       ; ist ueberhaupt geklickt worden ?
 beq.b    but_int_send1            ; nein
 move.w   #1,mcl_count             ; Zaehler fuer Mehrfachklicks auf 1
 move.w   d0,mcl_bstate            ; Status des Mehrfachklicks
 move.w   dclick_clicks,mcl_timer  ; Zeitintervall fuer weitere Klicks
 bra.b    but_int_store            ; schicke noch keinen Klick
* schicke einen Einfachklick
but_int_send1:
 move.w   d0,-(sp)
 move.w   #1,-(sp)                 ; 1-fach
 move.w   d0,-(sp)                 ; Status
 pea      handle_but(pc)
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 tst.w    d0                       ; Ueberlauf des Ringpuffers ?
 bne.b    but_int_ok               ; nein, OK
 tst.w    int_but_dirty            ; Ueberlauf schon gemerkt ?
 bne.b    but_int_ok               ; ja!
 st.b     int_but_dirty            ; merken, dass Maustastenstatus kaputt
 addq.w   #1,iocpbuf_cnt           ; merken, dass was passiert ist
but_int_ok:
 move.w   (sp)+,d0
but_int_store:
 move.w   d0,int_butstate
but_int_ignore:
 movem.l  (sp)+,a2/a1/a0/d2/d1/d0
 rts

* Mausbewegungs- Interrupt

mov_int:
 movem.l  d0/d1/d2/a0/a1/a2,-(sp)
 move.w   d1,-(sp)                 ; neue y- Koordinate
 move.w   d0,-(sp)                 ; neue x- Koordinate
 move.l   (sp),int_mx              ; Interrupt-Mausdaten merken
;move.w   2(sp),int_my
 pea      handle_mov(pc)
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 movem.l  (sp)+,a2/a1/a0/d2/d1/d0
 rts

* Mauszeichen- Interrupt (?), Dummy

draw_int:
 rts


*********************************************************************
*
* Timer- Interrupt
*
* Erledigt die Timer-Ereignisse.
* Erledigt den Doppelklick.
* MagiC 3.0: Ueberpruefung auf Stackueberlauf der act_appl
*

timer_int:
 addq.l   #1,timer_cnt
 move.l   act_appl,d0
 beq.b    ti_int_n
 move.l   d0,a0
 cmpi.l   #'AnKr',ap_stkchk(a0)
 bne.b    err_stkovl
ti_int_n:

 tst.l    timer_cntdown
 beq.b    ti_int_weiter
 addq.l   #1,timer_cntup
 subq.l   #1,timer_cntdown
 bne.b    ti_int_weiter
 move.l   timer_cntup,-(sp)
 pea      handle_tim(pc)
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 tst.w    d0                            ; Puffer voll ?
 bne.b    ti_int_weiter                 ; nein
 addq.l   #1,timer_cntdown              ; Ereignis verzoegern
ti_int_weiter:

 tst.l    alrm_cntdown
 beq.b    ti_int_weiter2
 addq.l   #1,alrm_cntup
 subq.l   #1,alrm_cntdown
 bne.b    ti_int_weiter2
 move.l   alrm_cntup,-(sp)
 pea      handle_alm(pc)
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
 tst.w    d0                            ; Puffer voll ?
 bne.b    ti_int_weiter2                ; nein
 addq.l   #1,alrm_cntdown               ; Ereignis verzoegern
ti_int_weiter2:

 moveq    #1,d0
 bsr.b    mclick_countdown
 move.l   old_timer_int,-(sp)
 rts
err_stkovl:
 clr.l    act_appl                      ; Reentranz verhindern
 jmp      fatal_stack


**********************************************************************
*
* void mclick_countdown(d0 = int clicks)
*

mclick_countdown:
 tst.w    mcl_timer                ; Laeuft Doppelklick ?
 beq.b    mccd_ende                ; nein
 sub.w    d0,mcl_timer             ; Countdown
 bne.b    mccd_ende                ; noch nicht 0
 move.w   mcl_count,-(sp)          ; n-fach Klick
 move.w   mcl_bstate,-(sp)         ; dabei Mausstatus
 pea      handle_but(pc)
 bsr      write_evnt_to_ringbuf    ; in den Ringpuffer schreiben
 addq.l   #8,sp
 move.w   int_butstate,d0          ; gegenwaertiger Zustand
 cmp.w    mcl_bstate,d0            ; wie zu Beginn des Doppelklicks ?
 beq.b    mccd_ende                ; ja
 move.w   #1,-(sp)                 ; Einfachklick
 move.w   d0,-(sp)                 ; neuer Zustand
 pea      handle_but(pc)
 bsr      write_evnt_to_ringbuf    ; in den Ringpuffer schreiben
 addq.l   #8,sp
mccd_ende:
 rts


**********************************************************************
*
* void warmb_hdl( void )
*
* Handler fuer Ctrl-Alt-Del
*

warmb_hdl:
 st       was_warmboot
 addq.w   #1,iocpbuf_cnt           ; merken, dass was passiert ist
 rts


**********************************************************************
*
* void appl_tplay(a0 = int *mem, d0 = int count, d1 = int scale)
*

appl_tplay:
 movem.l  d4/d5/d6/d7/a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = mem
 move.w   d0,d7
 move.w   d1,d5
 bsr      appl_yield
 clr.w    aptp_dirtyint            ; Interrupts noch nicht umgesetzt
* durchlaufe d6 = 0..count-1
 clr.w    d6
 bra      aptp_loop_cont
aptp_loop:
 move.l   (a5)+,d0                 ; Event- Typ
 move.l   (a5)+,d4                 ; Daten

 tst.w    d0                       ; switch(typ.loword)
 beq      aptp_c0
 subq.w   #1,d0
 beq      aptp_c1
 subq.w   #1,d0
 beq      aptp_c2
 subq.w   #1,d0
 beq.b    aptp_c3

* case 0 (Timer)

aptp_c0:
 tst.w    d5                       ; scale
 beq.b    apt_noscale              ; ist 0

 moveq    #100,d1
 move.l   d4,d0
 jsr      _lmul

 move.w   d5,d1                    ; scale
 ext.l    d1
;move.l   d0,d0
 jsr      _ldiv

;move.l   d0,d0
 bsr      _evnt_timer
apt_noscale:
 bra      aptp_yield

* case 2 (Maus)

aptp_c2:
 tst.w    aptp_dirtyint            ; Interrupts schon umgesetzt ?
 bne.b    aptp_l1                  ; ja
 move.l   #draw_int,vcontrl+14     ; rts- Routine
 move.l   #$7f000000,d0            ; exchange cursor change vector
 bsr      vdi_quick
 move.l   vcontrl+18,mdraw_int_adr
 move.l   #draw_int,vcontrl+14     ; rts- Routine
 move.l   #$7e000000,d0            ; exchange mouse movement vector
 bsr      vdi_quick
 move.l   vcontrl+18,a4            ; alten Vektor retten
aptp_l1:
 move.w   #1,aptp_dirtyint

 lea      handle_mov(pc),a0
 bra.b    aptp_l2

* case 1 (Button)

aptp_c1:
 lea      handle_but(pc),a0
 bra.b    aptp_l2

* case 3 (Taste)

aptp_c3:
 lea      handle_key(pc),a0

aptp_l2:
 move.l   d4,-(sp)
 move.l   a0,-(sp)
 bsr      write_evnt_to_ringbuf
 addq.l   #8,sp
aptp_yield:
 bsr      appl_yield
 addq.w   #1,d6
aptp_loop_cont:
 cmp.w    d7,d6
 blt      aptp_loop
 tst.w    aptp_dirtyint
 beq.b    aptp_l3
 move.l   mdraw_int_adr,vcontrl+14
 move.l   #$7f000000,d0
 bsr      vdi_quick
 move.l   a4,vcontrl+14
 move.l   #$7e000000,d0
 bsr      vdi_quick
 clr.w    aptp_dirtyint
aptp_l3:
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4
 rts


**********************************************************************
*
* int appl_trecord(a0 = char *mem, d0 = int count)
*

appl_trecord:
 movem.l  d4/d5/d6/a5,-(sp)
 move.l   a0,a5                    ; a5 = mem
 move.w   d0,d6                    ; d6 = count

 move.w   sr,d1
 ori.w    #$700,sr                 ; disable_interrupt
 move.w   #1,aptr_flag
 move.w   d6,aptr_count            ; count
 move.l   a5,aptr_buf              ; mem
 move.w   d1,sr                    ; enable_interrupt
 bra.b    aptr_loop_cont1
aptr_loop1:
 moveq    #100,d0
 bsr      _evnt_timer              ; 0.1 s warten
aptr_loop_cont1:
 tst.w    aptr_flag                ; muss noch gelesen werden ?
 bne.b    aptr_loop1               ; ja

 move.w   sr,d1
 ori.w    #$700,sr                 ; disable_interrupt
 clr.w    aptr_flag                ; Flag nochmal auf 0
 clr.w    aptr_count               ; Counter auf 0
 move.l   aptr_buf,d6              ; mem
 sub.l    a5,d6                    ; minus Anfangswert
 divs     #8,d6                    ; Anzahl Eintraege
 clr.l    aptr_buf                 ; mem loeschen
 move.w   d1,sr                    ; enable_interrupt

* alle Eintraege durchlaufen
* Achtung: laeuft nicht mit handle_spec !

 clr.w    d5
 bra.b    aptr_loop_cont2
aptr_loop2:
 moveq    #0,d4
 move.l   (a5),d0                  ; Behandlungsroutine
 cmp.l    #handle_mov,d0
 bne.b    aptr_l1
 moveq    #2,d4                    ; war Mausereignis
aptr_l1:
 cmp.l    #handle_key,d0
 bne.b    aptr_l2
 moveq    #3,d4                    ; war Tastaturereignis
aptr_l2:
 cmp.l    #handle_but,d0
 bne.b    aptr_l3
 moveq    #1,d4                    ; war Buttonereignis
aptr_l3:
 move.l   d4,(a5)                  ; Code statt Behandlungsroutine
 addq.l   #8,a5                    ; Pointer erhoehen
 addq.w   #1,d5                    ; Zaehler erhoehen
aptr_loop_cont2:
 cmp.w    d6,d5
 blt.b    aptr_loop2
 move.w   d6,d0
 movem.l  (sp)+,a5/d6/d5/d4
 rts


**********************************************************************
*
* void get_ev_xy_bkstate(a0 = int *out)
*
* aendert nur a0
*

get_ev_xy_bkstate:
 tst.w    prev_count
 beq.b    gexy_0
 clr.w    prev_count
 move.w   prev_mkmx,(a0)+          ; out[0] = x- Position der Maus bei Event
 move.w   prev_mkmy,(a0)+          ; out[1] = y- Position der Maus bei Event
 bra.b    gexy_n0
gexy_0:
 move.w   gr_mkmx,(a0)+
 move.w   gr_mkmy,(a0)+
gexy_n0:
 move.w   gr_evbstate,(a0)+        ; out[2] = bstate bei Event
 move.w   gr_mkkstate,(a0)         ; out[3] = kstate bei Event
 rts


**********************************************************************
*
* int appl_wait( a1 = APPL *ap, d0 = long evtyp )
*

appl_wait:
 move.l   d0,ap_hbits(a1)          ; ap_hbits werden geloescht
 move.b   #APSTAT_WAITING,ap_status(a1)
 bsr      appl_yield
 clr.w    ap_rbits(a1)             ; ich warte nicht mehr
 rts


**********************************************************************
*
* int evnt_keybd( void )
*

evnt_keybd:
 movea.l  act_appl,a0
 tst.w    ap_kbcnt(a0)             ; Zeichen im Puffer ?
 bne      read_keybuf              ; Zeichen holen
evk_wait:
 moveq    #EV_KEY,d0
 move.l   a0,a1
 bsr.s    appl_wait
 move.l   act_appl,a0
 bra      read_keybuf              ; Zeichen holen


**********************************************************************
*
* int evnt_button(d0 = long but, a0 = int *ret)
* int nclicks, int mask, int state, int ret[])
*
* but: Bits 24..31: NOT
*      Bits 16..23: Anzahl Klicks
*      Bits  8..15: mask
*      Bits  0..7:  state
*
* Rueckgabe: Anzahl der aufgetretenen Klicks
*           ret[0] = x
*           ret[1] = y
*           ret[2] = bstate bei Event
*           ret[3] = kstate bei Event
*

evnt_button:
 movem.l  a3/d7,-(sp)
 move.l   a0,a3
 move.l   d0,d7

 move.l   d7,-(sp)
 move.w   gr_mkmstate,-(sp)
 bsr      bstate_match             ; gerade eingetroffen ?
 addq.l   #6,sp

 tst.w    d0
 beq.b    evb_wait                 ; nein
 move.w   gr_mkmstate,gr_evbstate  ; bstate bei EVENT
 move.l   a3,a0
 bsr.s    get_ev_xy_bkstate
 move.w   gr_mnclicks,d0
 movem.l  (sp)+,a3/d7
 rts
evb_wait:
 move.l   d7,d0
 swap     d0
 cmpi.b   #1,d0                    ; bt_n (Anzahl Klicks)
 bls.b    evb_nomulti
 addq.w   #1,mcl_in_events         ; Anzahl der erwarteten Mehrfachklicks
evb_nomulti:
 move.l   act_appl,a1
 move.l   d7,ap_evbut(a1)
 moveq    #EV_BUT,d0
;move.l   a1,a1
 bsr.s    appl_wait
 move.l   a3,a0
 bsr      get_ev_xy_bkstate        ; aendert nur a0
 moveq    #0,d0                    ; Hibyte loeschen
 move.b   ap_evbut+3(a1),d0        ; Ausloesender Zustand
 move.w   d0,4(a3)                 ; Hiword (Button) nach out[2]
 move.b   ap_evbut+1(a1),d0        ; Anzahl Klicks
 movem.l  (sp)+,a3/d7
 rts


**********************************************************************
*
* int evnt_mouse(a0 = int in[], a1 = int ret[])
*
* Eingabe:  in[0]  = flag fuer Betreten (0) oder Verlassen (1)
*           in[1]  = x
*           in[2]  = y
*           in[3]  = w
*           in[4]  = h
* Rueckgabe: ???
*           out[0] = x
*           out[1] = y                       (wie bei
*           out[2] = bstate bei Event         evnt_button)
*           out[3] = kstate bei Event
*

evnt_mouse:
 movem.l  a4/a5,-(sp)
 move.l   a0,a4                    ; MGRECT
 move.l   a1,a5                    ; out

 lea      2(a4),a0                 ; GRECT
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; gerade eingetroffen ?
 cmp.w    (a4),d0                  ; gewuenschtes Ergebnis
 bne.b    evm_ende                 ; ja
* Das Mausrechteck ist nicht gerade aktiv
 move.l   act_appl,a1
 move.l   a4,ap_mgrect1(a1)
 moveq    #EV_MG1,d0
;move.l   a1,a1
 bsr      appl_wait
evm_ende:
 move.w   gr_mkmstate,gr_evbstate
 move.l   a5,a0
 bsr      get_ev_xy_bkstate
 move.w   gr_mnclicks,d0
 movem.l  (sp)+,a4/a5
 rts


**********************************************************************
*
* int evnt_xmesag(d0 = long timeout, a0 = int *mbuf)
*
* ab MagiX 3.0
* wird per appl_read(-2, timeout, buf) aufgerufen
*

evnt_xmesag:
 move.l   a0,-(sp)                 ; char *buf
 move.w   #16,-(sp)                ; int  size
 move.l   act_appl,a1
 move.l   a1,-(sp)
 tst.w    ap_len(a1)               ; liegen Daten an ?
 beq.b    evmx_wait                ; nein, warten
 move.l   sp,a0
 moveq    #0,d0
 bsr      rw_ap_buf                ; einfach sofort lesen
 moveq    #EV_MSG,d0               ; Nachricht eingetroffen
 bra.b    evmx_ok

evmx_wait:
;move.l   d0,d0
 bsr      wait_timer
 move.l   act_appl,a1
 move.l   sp,ap_evparm(a1)
 moveq    #EV_MSG+EV_TIM,d0
;move.l   a1,a1
 bsr      appl_wait
 move.l   act_appl,a0
 bsr      __rmv_ap_timer
 move.l   act_appl,a0
 move.w   ap_hbits(a0),d0     ; eingetroffene Ereignisse
evmx_ok:
 lea      10(sp),sp
 rts


**********************************************************************
*
* LONG evnt_fork( a0 = PD *waitforchild )
*
* MagiC 6.10: Fuer P(v)fork()
*
* Nachdem wir aus dem Wartezustand aufgeweckt worden sind, finden
* wir in ap_evparm die PID des terminierten bzw. ueberladenen
* Kindprozesses vor, durch dessen Pterm() bzw. Pexec(200) wir
* aufgeweckt worden sind.
*

evnt_fork:
 movea.l  act_appl,a1
 move.l   a0,ap_evparm(a1)
 move.l   #EV_FORK,d0
 bsr      appl_wait
 movea.l  act_appl,a1
 move.l   ap_evparm(a1),d0
 rts


**********************************************************************
*
* void hap_fork( PD *pd )
*
* Ein Ereignis "Prozess ist terminiert" bzw. "Prozess wurde ueberladen"
* ist eingetroffen. Wecke ggf. den parent auf, wenn er auf
* ein P(v)fork() wartet.
*

hap_fork:
 move.l   a0,a1                    ; a1 = terminierter bzw. ueberladener PD
 move.l   p_parent(a1),d1          ; parent (PD *)
 beq.b    hpfrk_ok                 ; Habe keinen Parent
 move.l   d1,a0                    ; a0 = parent (ggf. wartender PD)
 move.l   p_app(a1),d0             ; APP, die mich gestartet hat
                                   ;  (ist immer == act_appl)
 beq.b    hpfrk_ok                 ; ist ungueltig (??)
 move.l   d0,a2                    ; a2 = APP des terminierten PD
 move.w   ap_parent(a2),d0         ; sein parent-APP
 bmi.b    hpfrk_ok                 ; ?!? parent-APP ist ungueltig
 add.w    d0,d0
 add.w    d0,d0
 lea      applx,a2
 add.w    d0,a2                    ; a2 = parent-APP
 move.l   (a2),a2
 btst     #EVB_FORK-8,ap_rbits(a2) ; Parent wartet auf fork ?
 beq.b    hpfrk_ok                 ; nein
 btst     #EVB_FORK-8,ap_hbits(a2) ; Event war schon eingetroffen ?
 bne.b    hpfrk_ok                 ; ja, nicht nochmal aufwecken
 cmpa.l   ap_evparm(a2),a1         ; Parent wartet auf uns ?
 bne.b    hpfrk_ok                 ; nein, auf anderes Kind (?)
; Parent aufwecken
 moveq    #0,d0
 move.w   p_procid(a1),d0
 move.l   d0,ap_evparm(a2)         ; merken: ProcID des child
 move.l   #EV_FORK,d0
 move.l   a2,a0
 bra      event_happened           ; Applikation aufwecken
hpfrk_ok:
 rts


**********************************************************************
*
* void * evnt_pid( WORD pid )
*
* MagiC 5.04: Fuer Pwaitpid()
*
* Terminierte Kinder sind hier schon vom DOS gesucht und nicht
* gefunden worden. Es ist auch schon sichergestellt, dass wir noch
* Kinder haben, auf die wir warten. Wir muessen also in den
* Wartezustand uebergehen.
* Nachdem wir aus dem Wartezustand aufgeweckt worden sind, finden
* wir in ap_evparm den Zeiger auf den procx-Eintrag des Kinds vor, durch
* dessen Beendigung wir aufgeweckt worden sind.
* D.h. (a0) ist der PD. a0 ist ein procx[]-Tabelleneintrag.
*

evnt_pid:
 movea.l  act_appl,a1
 move.w   d0,ap_evparm(a1)
 move.l   #EV_PID,d0
 bsr      appl_wait
 movea.l  act_appl,a1
 move.l   ap_evparm(a1),a0
 rts


**********************************************************************
*
* int hap_pid( PD *pd )
*
* Ein Ereignis "Prozess ist terminiert" ist eingetroffen. D.h. der
* Prozess <pd> ist terminiert. Wecke ggf. den parent auf.
*
* Rueckgabe:    0    Der Prozess darf entfernt werden.
*              1    Der Prozess muss zum Zombie werden.
*

hap_pid:
 move.l   a0,a1                    ; a1 = terminierter PD
 move.l   p_parent(a1),d1          ; parent (PD *)
 beq.b    hpid_ok                  ; Habe keinen Parent
 move.l   d1,a0                    ; a0 = parent (ggf. wartender PD)
 move.l   p_app(a1),d0             ; APP, die mich gestartet hat
                                   ;  (ist immer == act_appl)
 beq.b    hpid_ok                  ; ist ungueltig (??)
 move.l   d0,a2                    ; a2 = APP des terminierten PD
 move.w   ap_parent(a2),d0         ; sein parent-APP
 bmi.b    hpid_ok                  ; ?!? parent-APP ist ungueltig
 add.w    d0,d0
 add.w    d0,d0
 lea      applx,a2
 add.w    d0,a2                    ; a2 = parent-APP
 move.l   (a2),a2
 cmp.l    ap_pd(a2),a0             ; PD stimmt (es ist der parent ?)
 bne.b    hpid_zombie              ; nein, APP hat wohl Pexec() gemacht.
 btst     #EVB_PID-8,ap_rbits(a2)  ; Parent wartet auf pid ?
 beq.b    hpid_zombie              ; nein
 btst     #EVB_PID-8,ap_hbits(a2)  ; Event war schon eingetroffen ?
 bne.b    hpid_zombie              ; ja, nicht nochmal aufwecken
;move.l   a1,a1                    ; wir (child)
;move.l   a0,a0                    ; parent
 move.w   ap_evparm(a2),d0         ; Suchkriterium fuer Pwaitpid()
 jsr      match_pid                ; -> DOS, aendert nur d0/d1
 tst.w    d0                       ; wartet auf uns ?
 beq.b    hpid_zombie              ; nein
; Parent aufwecken
 move.l   a1,ap_evparm(a2)         ; merken: PD des child
 move.l   #EV_PID,d0
 move.l   a2,a0
 bsr      event_happened           ; Applikation aufwecken
hpid_zombie:
 moveq    #1,d0                    ; Prozess darf nicht entfernt werden
 rts
hpid_ok:
 moveq    #0,d0                    ; Prozess darf entfernt werden
 rts


**********************************************************************
*
* int evnt_mesag(a0 = int *mbuf)
*

evnt_mesag:
;move.l   a0,a0                    ; mbuf
 moveq    #16,d0                   ; 16 Bytes lesen
;bra.b    appl_read


**********************************************************************
*
* int appl_read(d0 = int size, a0 = char *buf)
*
* Es wird IMMER (!) von der aktuellen Applikation gelesen
* GEM ist in anderen Faellen immer abgestuerzt
*

appl_read:
 move.l   act_appl,a1
 move.l   a0,-(sp)                 ; char *buf
 move.w   d0,-(sp)                 ; int  size
 move.l   a1,-(sp)                 ; APPL *dst_ap
 tst.w    ap_len(a1)               ; liegen Daten an ?
 beq.b    ar_wait                  ; nein, warten
 move.l   sp,a0
 moveq    #0,d0
 bsr      rw_ap_buf                ; einfach sofort lesen
 bra.b    ar_ok

ar_wait:
 move.l   sp,ap_evparm(a1)
 moveq    #EV_MSG,d0
;move.l   a1,a1
 bsr      appl_wait
ar_ok:
 lea      10(sp),sp
 moveq    #1,d0                    ; ok
 rts


**********************************************************************
*
* int appl_write(d0 = int size, a0 = char *buf, d1 = int dst_id)
*
* Achtung: schreibt nur, wenn Puffer genuegend Platz hat.
* Rueckgabe 0, wenn Puffer voll oder dst_id ungueltig
*
* ueblicher Inhalt:
*
*    buf[0] = Nachrichtentyp
*    buf[1] = id des Senders
*    buf[2] = Ueberlaenge (immer 0)
*    buf[3] = i1 (etwa whdl)
*    buf[4,5,6,7] frei
*
* Erweiterung fuer MagiC 3 ab 15.4.95:
*
*  dst_id = -2:
*    => a0 zeigt auf folgende Struktur:
*
*    int dst_apid                  ; Ziel-App
*    int unique_flag               ; Nachrichtentyp verschmelzen
*    void *attached_mem            ; wenn != NULL:
*                                  ; Speicherblock anhaengen, Adresse
*                                  ; wird in buf[6,7] eingetragen, der Eigner
*                                  ; wird die Ziel-App
*    int *msg                      ; eigentliche Nachricht
*

appl_write:
 move.l   a5,-(sp)
 moveq    #1,d2                    ; unique-flag: normal
 suba.l   a2,a2                    ; kein "attached memory"
 cmpi.w   #NAPPS,d1
 bcs.b    aw_write                 ; id ist 0..NAPPS-1
 addq.w   #2,d1                    ; id == -2 ?
 bne      aw_err                   ; nein, Fehler

* Sonderbehandlung MagiC

 move.w   (a0)+,d1                 ; d1 = dst_apid
 cmpi.w   #NAPPS,d1
 bcc      aw_err
 tst.w    (a0)+                    ; unique_flag
 beq.b    aw_unique_normal
 moveq    #2,d2                    ; verschmelzen!
aw_unique_normal:
 move.l   (a0)+,a2                 ; "attached memory" oder NULL
 move.l   (a0),a0                  ; Nachricht

* weiter

aw_write:
 lea      applx,a1
 add.w    d1,d1
 add.w    d1,d1
 move.l   0(a1,d1.w),d1
 ble.b    aw_err                   ; ap_id unbelegt oder eingefroren
 move.l   d1,a5                    ; a5 := dst_ap

 move.w   #ap_buflen,d1            ; Puffer- Gesamtlaenge (MAGIX: 256 Bytes)
 sub.w    ap_len(a5),d1            ; d0 = freie Pufferlaenge
 cmp.w    d0,d1                    ; freier Platz < msglen ?
 bcs      aw_full                  ; Zielpuffer voll!

* "attached memory" behandeln

 move.l   a2,d1                    ; "attached memory" ?
 beq.b    aw_no_atmem              ; nein!
 move.l   ap_pd(a5),d1
 ble.b    aw_err                   ; Zielapp ist kein Prozess !
 movem.l  a2/a0/d0/d2,-(sp)
 move.l   d1,a1                    ; Neuer Eigner
 move.l   a2,a0                    ; memadr
 jsr      Mchgown                  ; Eigner des Blocks wechseln
 tst.l    d0                       ; Fehler bei Mchgown ?
 movem.l  (sp)+,a2/a0/d0/d2
 bne.b    aw_err                   ; ja, Fehler
 move.l   a2,12(a0)                ; buf[6,7] = memadr

aw_no_atmem:
 move.l   a0,-(sp)                 ; char *buf
 move.w   d0,-(sp)                 ; int  size
 move.l   a5,-(sp)                 ; APPL *dst_ap
 move.l   sp,a0
 move.w   d2,d0                    ; mode (1 oder 2)
 bsr      rw_ap_buf                ; einfach sofort schreiben
 lea      10(sp),sp

 btst     #EVB_MSG,ap_rbits+1(a5)  ; warte auf Message ?
 beq      aw_ok                    ; nein
 btst     #EVB_MSG,ap_hbits+1(a5)  ; eingetroffen !
 bne      aw_ok                    ; war schon eingetroffen

 move.l   ap_evparm(a5),a0         ; a2 = EVPARM * der Zielapp.
 moveq    #0,d0
 bsr      rw_ap_buf                ; Das Lesen der Zielapp.

 move.l   a5,a0
 moveq    #EV_MSG,d0
 bsr      event_happened           ; Zielapp freigeben
aw_ok:
 moveq    #1,d0                    ; ok
aw_ende:
 move.l   (sp)+,a5
 rts
aw_full:
 moveq    #0,d0
 bra.b    aw_ende
aw_err:
 moveq    #-1,d0
 bra.b    aw_ende


**********************************************************************
*
* void wait_timer( d0 = long ms )
*
* act_appl soll auf Timerereignis <ms> warten.
* ap_rbits oder ap_status werden noch nicht beeinflusst.
*

wait_timer:
 move.l   act_appl,a0
 lea      ap_nxttim(a0),a0
 tst.l    d0                       ; 0 ms ?
 bne.b    wt_no_0
 moveq    #1,d0                    ; ja, stattdessen 1 ms
wt_no_0:
 move.w   sr,d2
 ori.w    #$700,sr                 ; disable_interrupt
 tst.l    timer_cntdown            ; laeuft schon ein Countdown ?
 beq.b    wt_no_cd                 ; nein
 cmp.l    timer_cntdown,d0
 bhi.b    wt_sort                  ; Vorzeichenfehler korrigiert
 move.l   d0,timer_cntdown         ; unser Countdown wird vorher eintreffen
 bra.b    wt_sort
* Es laeuft noch kein Countdown. Einfach Timer setzen
wt_no_cd:
 move.l   d0,timer_cntdown
 clr.l    timer_cntup
* Timer EVENT in die Liste timer_evlist einhaengen.
* ap_ms enthaelt jeweils den Tickoffset zum vorangegangenen Timerevent
wt_sort:
 lea      timer_evlist,a2          ; Liste aller laufenden Timer
 movea.l  (a2),a1                  ; a1 auf naechste APPL
 move.l   a1,d1                    ; Listenende ?
 beq.b    wt_endloop               ; ja, Liste ist leer
 move.l   4(a1),d1                 ; ap_ms fuer erstes Listenelement
 sub.l    timer_cntup,d1           ; solange muss er noch warten
 bra.b    wt_cmp

wt_loop:
 move.l   4(a1),d1
wt_cmp:
 cmp.l    d1,d0                    ; ap_ms
 ble.b    wt_endloop               ; unser trifft frueher ein
 sub.l    d1,d0                    ; trifft vorher ein, Zeit abziehen
 movea.l  a1,a2                    ; a2 wird Vorgaenger
 movea.l  (a2),a1                  ; a1 auf naechsten EVENT
 move.l   a1,d1                    ; Listenende ?
 bne.b    wt_loop                  ; nein, weiter
wt_endloop:
 move.l   a0,(a2)                  ; Vorgaenger auf uns
 move.l   d0,4(a0)                 ; ap_ms setzen
 move.l   a1,(a0)                  ; Nachfolger
 beq.b    wt_ende                  ; nein
 move.l   4(a1),d1                 ; ap_ms des Nachfolgers
 sub.l    d0,d1
 move.l   d1,4(a1)                 ; Offset korrigieren
wt_ende:
 move.w   d2,sr                    ; enable_interrupt
 rts


**********************************************************************
*
* LONG appl_alrm( d0 = long ms )
*
* act_appl soll per Psignal alarmiert werden.
*

appl_alrm:
 move.l   d0,-(sp)                 ; Alarm setzen/deaktivieren/ermitteln
 bmi.b    apal_get
 move.l   act_appl,a0
 bsr      rmv_ap_alrm              ; Alarm entfernen
 move.l   (sp),d0
 beq.b    apal_get
 divu     ms_per_click,d0          ; Millisekunden -> Timerticks
 andi.l   #$0000ffff,d0
 bsr.s    wait_alrm
apal_get:
 move.l   act_appl,a0
 moveq    #0,d0
 tst.b    ap_isalarm(a0)           ; Alarm gesetzt?
 beq.b    apal_ende                ; nein

 lea      alrm_evlist,a1           ; Liste aller laufenden Alarme
 lea      ap_nxtalrm(a0),a0
apal_loop:
 movea.l  (a1),a1                  ; a1 auf naechste APPL
 move.l   a1,d1                    ; Listenende ?
 beq.b    apal_endloop             ; ja (kann eigentlich nicht sein)
 add.l    4(a1),d0                 ; ap_ms aufsummieren
 cmpa.l   a1,a0
 bne.b    apal_loop
 sub.l    alrm_cntup,d0            ; die habe ich schon
apal_endloop:
 mulu     ms_per_click,d0          ; Timerticks -> Millisekunden
apal_ende:
 addq.l   #4,sp
 rts


**********************************************************************
*
* void wait_alrm( d0 = long ms )
*
* act_appl soll per Psignal alarmiert werden.
*

wait_alrm:
 move.l   act_appl,a0
 st.b     ap_isalarm(a0)           ; Flag setzen
 lea      ap_nxtalrm(a0),a0
 tst.l    d0                       ; 0 ms ?
 bne.b    wa_no_0
 moveq    #1,d0                    ; ja, stattdessen 1 ms
wa_no_0:
 move.w   sr,d2
 ori.w    #$700,sr                 ; disable_interrupt
 tst.l    alrm_cntdown             ; laeuft schon ein Countdown ?
 beq.b    wa_no_cd                 ; nein
 cmp.l    alrm_cntdown,d0
 bhi.b    wa_sort                  ; Vorzeichenfehler korrigiert
 move.l   d0,alrm_cntdown          ; unser Countdown wird vorher eintreffen
 bra.b    wa_sort
* Es laeuft noch kein Countdown. Einfach Timer setzen
wa_no_cd:
 move.l   d0,alrm_cntdown
 clr.l    alrm_cntup
* Alarm EVENT in die Liste alrm_evlist einhaengen.
* ap_alrmms enthaelt jeweils den Tickoffset zum vorangegangenen Timerevent
wa_sort:
 lea      alrm_evlist,a2           ; Liste aller laufenden Alarme
 movea.l  (a2),a1                  ; a1 auf naechste APPL
 move.l   a1,d1                    ; Listenende ?
 beq.b    wa_endloop               ; ja, Liste ist leer
 move.l   4(a1),d1                 ; ap_ms fuer erstes Listenelement
 sub.l    alrm_cntup,d1            ; solange muss er noch warten
 bra.b    wa_cmp

wa_loop:
 move.l   4(a1),d1
wa_cmp:
 cmp.l    d1,d0                    ; ap_ms
 ble.b    wa_endloop               ; unser trifft frueher ein
 sub.l    d1,d0                    ; trifft vorher ein, Zeit abziehen
 movea.l  a1,a2                    ; a2 wird Vorgaenger
 movea.l  (a2),a1                  ; a1 auf naechsten EVENT
 move.l   a1,d1                    ; Listenende ?
 bne.b    wa_loop                  ; nein, weiter
wa_endloop:
 move.l   a0,(a2)                  ; Vorgaenger auf uns
 move.l   d0,4(a0)                 ; ap_alrmms setzen
 move.l   a1,(a0)                  ; Nachfolger
 beq.b    wa_ende                  ; nein
 move.l   4(a1),d1                 ; ap_alrmms des Nachfolgers
 sub.l    d0,d1
 move.l   d1,4(a1)                 ; Offset korrigieren
wa_ende:
 move.w   d2,sr                    ; enable_interrupt
 rts


**********************************************************************
*
* void rmv_ap_sem( a0 = APPL *ap )
*
* Entfernt ap aus der Semaphoren- Warteliste
*

rmv_ap_sem:
 btst     #EVB_SEM,ap_rbits+1(a0)  ; wartete auf end_update ?
 beq.b    rmas_nosem               ; nein
 btst     #EVB_SEM,ap_hbits+1(a0)  ; schon eingetroffen ?
 bne.b    rmas_nosem               ; ja
 move.l   ap_semaph(a0),a1
 lea      bl_waiting(a1),a1
 bra.b    rmas_sem_nxt1
rmas_sem_loop:
 cmp.l    d1,a0
 bne.b    rmas_sem_nxt
 move.l   ap_nxtsem(a0),(a1)       ; APP aus der Liste entfernen
 bra.b    rmas_nosem
rmas_sem_nxt:
 move.l   d1,a1
 lea      ap_nxtsem(a1),a1
rmas_sem_nxt1:
 move.l   (a1),d1
 bne.b    rmas_sem_loop
rmas_nosem:
rmat_notim:
rmat_noio:
rmat_oalrm:
 rts


**********************************************************************
*
* void rmv_ap_timer( a0 = APPL *ap )
*
* Entfernt ausstehendes Timer- Ereignis aus <ap>
*

rmv_ap_timer:
 move.w   ap_rbits(a0),d0
_rmv_ap_timer:
 btst     #EVB_TIM,d0              ; wartete auf evnt_timer ?
 beq.b    rmat_notim               ; nein
__rmv_ap_timer:
 btst     #EVB_TIM,ap_hbits+1(a0)  ; etv_timer eingetroffen ?
 bne.b    rmat_notim               ; ja
 move.l   ap_nxttim(a0),d0
 beq.b    rmat_remove              ; kein Nachfolger

 move.l   d0,a1
 move.l   ap_ms(a0),d0
 add.l    d0,4(a1)                 ; Timerzeit korrigieren
rmat_remove:
 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; disable_interrupt
 lea      ap_nxttim(a0),a0         ; Element
 lea      timer_evlist,a1          ; Liste
 bsr      rmv_lstelm               ; Listenelement ausklinken
 tst.l    timer_evlist
 bne.b    rmat_noclr
 clr.l    timer_cntdown            ; Liste ist leer, kein Interrupt mehr!
rmat_noclr:
 move.w   (sp)+,sr                 ; enable_interrupt
 rts


**********************************************************************
*
* void rmv_ap_alrm( a0 = APPL *ap )
*
* Entfernt ausstehendes Alarm- Ereignis aus <ap>
*

rmv_ap_alrm:
 tst.w    ap_isalarm(a0)
 beq.b    rmat_oalrm
 move.l   ap_nxtalrm(a0),d0
 beq.b    rmaa_remove              ; kein Nachfolger

 move.l   d0,a1
 move.l   ap_alrmms(a0),d0
 beq.b    rmaa_remove
 add.l    d0,4(a1)                 ; Alarmzeit korrigieren
rmaa_remove:
 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; disable_interrupt
 clr.w    ap_isalarm(a0)           ; entfernt
 lea      ap_nxtalrm(a0),a0        ; Element
 lea      alrm_evlist,a1           ; Liste
 bsr      rmv_lstelm               ; Listenelement ausklinken
 tst.l    alrm_evlist
 bne.b    rmaa_noclr
 clr.l    alrm_cntdown             ; Liste ist leer, kein Interrupt mehr!
rmaa_noclr:
 move.w   (sp)+,sr                 ; enable_interrupt
 rts


**********************************************************************
*
* void rmv_ap_io( a0 = APPL *ap )
*
* Entfernt ausstehendes IO- Ereignis aus <ap>
*

rmv_ap_io:
 move.w   ap_rbits(a0),d0
_rmv_ap_io:
 bclr     #EVB_IO,d0               ; wartete auf evnt_IO ?
 beq      rmat_noio                ; nein
 btst     #EVB_IO,ap_hbits+1(a0)   ; evnt_IO eingetroffen ?
 bne      rmat_noio                ; ja
 move.w   d0,ap_rbits(a0)
 move.l   a0,a1
 move.l   ap_unselx(a1),a0
 move.w   ap_unselcnt(a1),d0
 move.l   a0,-(sp)
 jsr      funselect                ; Interrupts deaktivieren
 move.l   (sp)+,a0
;bra      evnt_emIO                ; eingetroffene loeschen


**********************************************************************
*
* void evnt_emIO( a0 = APPL *ap )
*
* ggf. ausstehendes IOcomplete loeschen.
* Muss nach der unselect- Prozedur aufgerufen werden, wenn kein
* IOcomplete mehr eintreffen kann.
*

evnt_emIO:
 move.w   ap_id(a0),a0
 clr.b    iocpbuf(a0)
 rts


**********************************************************************
*
* long evnt_IO( d0 = long timeout_clicks, a0 = long *unsel )
*
* wartet auf EINEN Interrupt.
* Rueckgabe: Das, was die Interruptroutine in *unsel reingeschrieben
*           hat, das unselect wird hier erledigt.
*

evnt_IO:
 movem.l  a5/a6,-(sp)
 move.l   a0,a6
 move.l   act_appl,a5

 tst.l    d0
 beq.b    evio_notim              ; warte unbegrenzt
;move.l   d0,d0
 bsr      wait_timer
 moveq    #EV_TIM,d0
evio_notim:

 move.l   a6,ap_unselx(a5)
 move.w   #1,ap_unselcnt(a5)

 move.l   a6,a0
 bset     #EVB_IO,d0
 move.l   a5,a1

 move.w   d0,-(sp)                 ; rbits merken
 bsr      appl_wait
 move.w   (sp)+,d0                 ; rbits zurueck

 move.l   a5,a0
 bsr      _rmv_ap_timer

 move.w   ap_hbits(a5),d0          ; eingetroffene EVENTs
 btst     #EVB_IO,d0               ; EV_IO eingetroffen ?
 bne.b    evio_ende                ; ja, Interrupt war eingetroffen

* Timeout eingetroffen, Interrupt abmelden

 move.l   (a6),d0
 ble.b    evio_ende                ; Rueckgabewert des Interrupts: Fehler
 move.l   d0,a2
 subq.l   #1,d0
 beq.b    evio_ende                ; Rueckgabewert des Interrupts: OK

 move.l   a5,a1                    ; APPL *
 move.l   a6,a0                    ; void *unsel
 jsr      (a2)                     ; Interrupt abmelden

* ggf. ausstehendes IOcomplete loeschen

 move.w   ap_id(a5),a0
 clr.b    iocpbuf(a0)

* Rueckgabewert des Interrupts liefern
evio_ende:
 move.l   (a6),d0
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* void evnt_mIO( d0 = long timeout_50hz, a0 = long *unsel,
*                d1 = int cnt )
*
* wartet auf MEHRERE Interrupts.
* Das unselect muss vom Aufrufer erledigt werden.
*

evnt_mIO:
 tst.l    d0
 beq.b    evmio_notim              ; warte unbegrenzt
;move.l   d0,d0
 movem.l  d1/a0,-(sp)
 bsr      wait_timer
 movem.l  (sp)+,d1/a0
 move.l   #EV_TIM+EV_IO,d0
 move.l   act_appl,a1
 bsr      appl_wait
 move.l   act_appl,a0
 bra      __rmv_ap_timer
evmio_notim:
 move.l   #EV_IO,d0
 move.l   act_appl,a1
 bra      appl_wait


**********************************************************************
*
* PUREC WORD _evnt_timer(LONG clicks_50hz)
*
* int _evnt_timer(d0 = long clicks_50hz)
*

_evnt_timer:
 move.l   a2,-(sp)
 move.w   ms_per_click,d1          ; 20ms
 ext.l    d1
 jsr      _ldiv                    ; ms in Klicks umrechnen
;move.l   d0,d0
 bsr      wait_timer
 moveq    #EV_TIM,d0
 move.l   act_appl,a1
 bsr      appl_wait
 moveq    #1,d0                    ; ok
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* int match_mkmxy_mgrect(a0 = MGRECT *mm)
*
* Prueft nach, ob (gr_mkmx,gr_mkmy) je nach mg_flag innerhalb bzw.
* ausserhalb von mg_grect liegen.
* Setzt das Z-Flag.
*

match_mkmxy_mgrect:
 movea.l  a0,a1
 move.l   act_appl,d0
 cmp.l    mouse_app,d0
 bne.b    mxyg_n                ; passt nicht

 lea      2(a1),a0                 ; GRECT
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 jsr      xy_in_grect              ; passt ?

 cmp.w    (a1),d0
 beq.b    mxyg_n
 moveq    #1,d0
 rts
mxyg_n:
 moveq    #0,d0
 rts


**********************************************************************
*
* long rmv_lstelm( a0 = void *elem, a1 = void *liste )
*
* Klinkt <a0> aus Liste <a1> aus
* Veraendert nur d0/a1
* Rueckgabe d0 == NULL: nicht gefunden
* sonst:   d0 == a0
*

rls_loop:
 cmp.l    a0,d0                    ; unser ?
 bne.b    rls_nxt
 move.l   (a0),(a1)                ; ausklinken
 rts
rls_nxt:
 move.l   d0,a1
rmv_lstelm:
 move.l   (a1),d0                  ; Listenende ?
 bne.b    rls_loop                 ; nein, weiter
 rts


**********************************************************************
*
* int cdecl _evnt_multi(int mtypes, MGRECT *mm1, MGRECT *mm2, long ms,
*                long but, int *mbuf, int *out)
*
* int _evnt_multi(int mtypes, MGRECT *mm1, MGRECT *mm2, long ms,
*                long but, int *mbuf, int *out)
*
* but: Bits 24..31: NOT
*      Bits 16..23: Anzahl Klicks
*      Bits  8..15: mask
*      Bits  0..7:  state
*
* out[0] = x
* out[1] = y
* out[2] = bstate
* out[3] = kstate
* out[4] = key
* out[5] = nclicks
*

_evnt_multi:
 link     a6,#-$a
 movem.l  d6/d7/a2/a3/a5,-(sp)
 move.l   act_appl,a5
 moveq    #0,d7
 move.w   8(a6),d7                 ; erwartete Ereignisse
 movea.l  $1e(a6),a3               ; out
 clr.l    ap_evbut(a5)             ; keine Mehrfachklicks erwarten
 moveq    #0,d6                    ; eingetroffene Ereignisse
 bsr      check_kb                 ; Vorher nochmal Tastatur abfragen
 bsr      read_evnts_from_ringbuf  ; und Ringpuffer auswerten
 btst     #EVB_KEY,d7
 beq.b    evm_l1
* MU_KEYBD
 tst.w    ap_kbcnt(a5)             ; kb_cnt > 0 (Zeichen im Puffer)?
 beq.b    evm_l1                   ; nein
 move.l   a5,a0
 bsr      read_keybuf
 move.w   d0,8(a3)                 ; Taste eintragen
 or.w     #EV_KEY,d6               ; MU_KEYBD ist eingetroffen
evm_l1:
 btst     #EVB_BUT,d7
 beq.b    evm_l3
* MU_BUTTON
 cmpa.l   mouse_app,a5             ; bekommt Mausklicks ?
 bne.b    evm_l3                   ; nein, keine Abfrage
 cmpi.w   #1,prev_count
 ble.b    evm_l2
 move.l   $16(a6),-(sp)            ; but
 move.w   prev_mkmstate,-(sp)
 bsr      bstate_match
 addq.l   #6,sp
 tst.w    d0                       ; Mausklick passt ?
 beq.b    evm_l2                   ; nein
 move.w   prev_mkmstate,gr_evbstate
 or.w     #EV_BUT,d6               ; MU_BUTTON eingetroffen
 move.w   prev_mnclicks,$a(a3)     ; nclicks eintragen
 bra.b    evm_l3
evm_l2:
 move.l   $16(a6),-(sp)            ; but
 move.w   gr_mkmstate,-(sp)
 bsr      bstate_match
 addq.l   #6,sp
 tst.w    d0                       ; Mausklick passt ?
 beq.b    evm_l3                   ; nein
 move.w   gr_mkmstate,gr_evbstate
 or.w     #EV_BUT,d6               ; MU_BUTTON eingetroffen
 move.w   gr_mnclicks,$a(a3)       ; nclicks eintragen
evm_l3:
 btst     #EVB_MG1,d7
 beq.b    evm_l4
* MU_M1
 move.l   $a(a6),a0                ; mm1
 bsr      match_mkmxy_mgrect
 beq.b    evm_l4
 or.w     #EV_MG1,d6               ; MU_M1 eingetroffen
evm_l4:
 btst     #EVB_MG2,d7
 beq.b    evm_l5
* MU_M2
 move.l   $e(a6),a0
 bsr      match_mkmxy_mgrect
 beq.b    evm_l5
 or.w     #EV_MG2,d6               ; MU_M2 eingetroffen
evm_l5:
 btst     #EVB_TIM,d7
 beq.b    evm_l6
* MU_TIMER
 tst.l    $12(a6)                  ; Millisekunden
 bne.b    evm_l6                   ; ungleich 0
 or.w     #EV_TIM,d6               ; sonst MU_TIMER eingetroffen
evm_l6:
 btst     #EVB_MSG,d7
 beq.b    evm_l7
* MU_MESAG
 tst.w    ap_len(a5)               ; ap_len
 ble.b    evm_l7                   ; keine Nachricht im Puffer
 move.l   $1a(a6),a0               ; Pufferadresse
 bsr      evnt_mesag               ; Nachricht holen
 or.w     #EV_MSG,d6               ; MU_MESAG eingetroffen
evm_l7:
 tst.w    d6                       ; schon ein Event eingetroffen ?
 beq      evm_wait                 ; nein
 move.l   a3,a0                    ; out - Feld
 bsr      get_ev_xy_bkstate        ; out[0..3] setzen
 btst     #EVB_BUT,d7              ; MU_BUTTON ?
 bne.b    evm_l8
* kein MU_BUTTON
 move.w   gr_mkmstate,4(a3)        ; out[2] = gr_mkmstate statt gr_evbstate
evm_l8:
 bra      evm_l16

*
* noch keine Nachricht eingetroffen:
*

evm_wait:
 btst     #EVB_BUT,d7
 beq.b    evm_l9
* MU_BUTTON
 move.l   $16(a6),ap_evbut(a5)
evm_l9:
 btst     #EVB_MG1,d7
 beq.b    evm_l10
* MU_M1
 move.l   $a(a6),ap_mgrect1(a5)
evm_l10:
 btst     #EVB_MG2,d7
 beq.b    evm_l11
* MU_M2
 move.l   $e(a6),ap_mgrect2(a5)
evm_l11:
 btst     #EVB_MSG,d7
 beq.b    evm_l12
* MU_MESAG
 lea      -$a(a6),a0
 move.l   a0,ap_evparm(a5)
 move.l   a5,(a0)+                 ; APPL *
 move.w   #$10,(a0)+               ; 16 Bytes
 move.l   $1a(a6),(a0)             ; Pufferadresse
evm_l12:
 btst     #EVB_TIM,d7
 beq.b    evm_l13
* MU_TIMER
 move.w   ms_per_click,d1
 ext.l    d1
 move.l   $12(a6),d0
 jsr      _ldiv                    ; ms in Klicks umrechnen
;move.l   d0,d0
 bsr      wait_timer
evm_l13:
 cmpi.b   #1,ap_evbut+1(a5)
 shi      d1
 bls.b    emu_nomul1
 addq.w   #1,mcl_in_events
emu_nomul1:
 move.l   d7,d0                    ; hbits/rbits
 move.l   a5,a1
 bsr      appl_wait
 move.w   ap_hbits(a5),d6          ; eingetroffene EVENTs
 btst     #EVB_BUT,d6              ; EV_BUT eingetroffen ?
 bne.b    emu_nomul                ; ja, mcl_in_events schon dekrementiert
 tst.b    d1                       ; Mehrfachklicks ?
 beq.b    emu_nomul
 tst.w    mcl_in_events
 beq.b    emu_nomul
 subq.w   #1,mcl_in_events         ; Zaehler dekrementieren, da verarbeitet
emu_nomul:
 move.w   d7,d0
 move.l   a5,a0
 bsr      _rmv_ap_timer

*
* Wartezustand beendet
*

 move.l   a3,a0                    ; out - Feld
 bsr      get_ev_xy_bkstate        ; out[0..3] setzen
 btst     #EVB_BUT,d7              ; MU_BUTTON ?
 bne.b    evm_l14
* kein MU_BUTTON
 move.w   gr_mkmstate,4(a3)        ; out[2] = gr_mkmstate statt gr_evbstate
evm_l14:
 btst     #EVB_KEY,d6              ; MU_KEYBD eingetroffen ?
 beq.b    evm_l15                  ; nein
 move.l   a5,a0
 bsr      read_keybuf              ; Taste lesen
 move.w   d0,8(a3)                 ; Taste eintragen
evm_l15:
 btst     #EVB_BUT,d6              ; MU_BUTTON eingetroffen ?
 beq.b    evm_l16                  ; nein
 moveq    #0,d0                    ; Hibyte loeschen
 move.b   ap_evbut+1(a5),d0        ; Anzahl Klicks
 move.w   d0,$a(a3)
 move.b   ap_evbut+3(a5),d0        ; Ausloesender Zustand
 move.w   d0,4(a3)                 ; Hiword (Button) nach out[2]
evm_l16:
 move.w   d6,d0
 movem.l  (sp)+,a5/a3/a2/d7/d6
 unlk     a6
 rts


**********************************************************************
*
* int send_msg(d0 = int typ, d1 = int dst_apid, d2 = int i1
*              a0 = int[4])
*
* Schickt eine 8-Wort-Nachricht an <dst_apid>
* i1 ist das erste Datenwort, also meistens das whdl
*

send_msg:
 suba.w   #16,sp                   ; Platz fuer 8 ints
 move.l   sp,a1
 move.w   d0,(a1)+                 ; buf[0] = Nachrichtentyp
 movea.l  act_appl,a2
 move.w   ap_id(a2),(a1)+          ; buf[1] = id des Senders
 clr.w    (a1)+                    ; buf[2] = Ueberlaenge
 move.w   d2,(a1)+                 ; buf[3] = i1 (etwa whdl)
 move.l   (a0)+,(a1)+              ; buf[4,5,6,7]
 move.l   (a0),(a1)
 move.l   sp,a0                    ; buf
 moveq    #16,d0                   ; 16 Bytes
;move.w   d1,d1                    ; dst_apid
 bsr      appl_write
 adda.w   #16,sp
 rts
