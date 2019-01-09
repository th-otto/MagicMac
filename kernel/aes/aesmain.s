/*
*
* Dieses Modul enthaelt die Hauptroutinen des AES
* fuer den MagiC Kernel.
*
* Die Routinen, die der Aufrufkonvention von PureC entsprechen,
* sind mit "PUREC" gekennzeichnet.
*
*/

DEBUG     EQU  0

     INCLUDE "aesinc.s"
     INCLUDE "vtsys.inc"
     INCLUDE "debug.inc"
     INCLUDE "basepage.inc"
     INCLUDE "bios.inc"
     INCLUDE "lowmem.inc"
	 INCLUDE "..\dos\magicdos.inc"

        TEXT
        SUPER

     XDEF      psig_freeze         ; ->DOS
     XDEF      exec_10x            ; ->DOS
     XDEF      gem_magics          ; ->BIOS
     XDEF      endofvars           ; ->BIOS
     XDEF      appl_break
     XDEF      serno_isok          ; ->SERNO
     XDEF      ss_serno            ; ->SERNO
     XDEF      prtstr              ; ->SERNO

     XDEF      _graf_mkstate
     XDEF      desk_g,full_g,pop_list
     XDEF      fslx_sortmode,fslx_flags,fslx_exts,fslx_d2s,fslx_dlw,fslx_dlm

     XDEF      leerstring
     XDEF      set_apname
     XDEF      set_topwind_app,any_app,set_app
     XDEF      gbest_app,gbest_wnd_app
     XDEF      make_app_main
     XDEF      enab_warmb
     XDEF      appl_unhide
     XDEF      wait_but_released,wait_n_clicks
     XDEF      xy_in_grect
     XDEF      kill_tree_structure
     XDEF      inq_screenbuf
     XDEF      clrmem,min,max,grects_intersect,grects_union
     XDEF      fillmem,fatal_err,fatal_w1,fatal_w2,fatal_stack
     XDEF      fsetdta
     XDEF      set_mouse_app
     XDEF      null_s
     XDEF      grect_in_scr
     XDEF      reset_mouse
     XDEF      appl_info
     XDEF      aes_dispatcher
     XDEF      graf_mouse
     XDEF      dsetdrv_path
     XDEF      _set_topwind_app
     XDEF      big_wchar,big_hchar,finfo_big
     XDEF      sigreturn,do_signals,pkill_threads,wait_signals
     XDEF      shel_find

     XDEF      scrp_cpy,scrp_pst

* von DOS

     XREF      config_status
     XREF	   status_bits
     XREF      env_end
     XREF      pd_used_mem
     XREF      swap_paths
     XREF      srch_process
     XREF      env_clr_int
     XREF      Mxalloc,Mxfree,Mchgown
     IF   DEBUG
     XREF      str_to_con
     ENDIF

* von BIOS

     XREF      app0
     XREF      p_mgxinf
     XREF      is_fpu
     XREF      warm_boot
     XREF      warmbvec
     XREF      sust_len
     XREF      pe_slice,pe_timer
     XREF      p_vt52

* von READ_INF

     XREF      rinf_sec
     XREF      rinf_tok
     XREF      rinf_nl
     XREF      rinf_ul
     XREF      scan_tok
     XREF      rinf_path

* von AESEVT

     XREF      halt_system
     XREF      rmv_lstelm
     XREF      rmv_ap_sem
     XREF      rmv_ap_io
     XREF      rmv_ap_timer
     XREF      rmv_ap_alrm
     XREF      _ap_to_last
     XREF      ad__kernel
     XREF      _end_mctrl
     XREF      flush_msgbuf
     XREF      mctrl_0,mctrl_1,update_0,update_1
     XREF      draw_int,timer_int
     XREF      aes_trap2

     XREF      ap_to_lastready,send_msg,_appl_exit
     XREF      end_update
     XREF      ctrl_timeslice
     XREF      gem_etvc
     XREF      appl_yield
     XREF      beg_mctrl
     XREF      read_keybuf
     XREF      end_mctrl
     XREF      send_mouse
     XREF      send_click
     XREF      _evnt_multi
     XREF      event_happened
     XREF      appl_read
     XREF      appl_write
     XREF      appl_tplay
     XREF      appl_trecord
     XREF      appl_exit
     XREF      evnt_keybd
     XREF      evnt_button
     XREF      evnt_mouse
     XREF      evnt_mesag
     XREF      evnt_xmesag
     XREF      _evnt_timer
     XREF      evnt_sem
     XREF      warmb_hdl
     XREF      stp_thr,cnt_thr
     XREF      app2ready

* von AESFRM

     XREF      form_do,_form_xdo
     XREF      form_alert,form_error,do_aes_alert
     XREF      _form_wkeybd,_form_button
     XREF      form_xerr
     XREF      xfrm_popup
     XREF      _form_popup
     XREF      _form_center
     XREF      __fm_xdial
     XREF      al_aeserr
     XREF      al_sigerr

* von AESOBJ

     XREF      objc_delete,_objc_find
     XREF      _objc_offset,_objc_change,objc_order
     XREF      _objc_edit,objc_wedit
     XREF      _objc_draw
     XREF      set_clip_grect
     XREF      objc_add
     XREF      mouse_on,mouse_off,mouse_immed
     XREF      set_xor_black,_set_xor_black
     XREF      _objc_sysvar
     XREF      init_vdi,vdi_quick,v_clswk,bitblk_to_mfdb
     XREF      set_scrmode
     XREF      set_mform
     XREF      set_full_clip
     XREF      v_drawgrect

* von AESWIN

     XREF      init_windows
     XREF      _wind_create,_wind_open,wind_close,wind_delete
     XREF      _wind_get,_wind_set,wind_update,_wind_calc
     XREF      objc_wdraw
     XREF      objc_wchange
     XREF      graf_wwatchbox
     XREF      whdl_to_wnd
     XREF      build_new_wgs
     XREF      app_wind_redraw
     XREF      wind0_draw
     XREF      send_all_redraws
     XREF      top_my_window
     XREF      all_untop
     XREF      wind_find
     XREF      wind_was_clicked
     XREF      _wbm_create,_wbm_skind,_wbm_calc,_wbm_ssize,_wbm_sslid
     XREF      _wbm_obfind,_wbm_sstr,_wbm_sattr

* von AESMEN

     XREF      menu_off
     XREF      menu_register
     XREF      menu_unregister
     XREF      desk_off,desk_on
     XREF      do_menu
     XREF      menu_modify
     XREF      menu_on
     XREF      menu_attach
     XREF      menu_istart
     XREF      menu_settings
     XREF      menu_popup
     XREF      set_desktop
     XREF      menu_draw
     XREF      menu_new
     XREF      _menu_off
     XREF      _scmgr_reinit

* von AESGRAF

     XREF      graf_dragbox
     XREF      graf_growbox
     XREF      graf_movebox
     XREF      graf_rubberbox
     XREF      graf_shrinkbox
     XREF      graf_slidebox
     XREF      graf_watchbox
     XREF      xgrf_stepcalc
     XREF      xgrf_2box

* von AESRSC

     XREF      rsrc_load
     XREF      rsrc_free
     XREF      rsrc_gaddr
     XREF      rsrc_saddr
     XREF      rsc_init
     XREF      rsrc_obfix
     XREF      _rsrc_rcfix

* von MATH

     XREF      _lmul

* von STD

     XREF      vmemcpy
     XREF      memmove
     XREF      _sprintf
     XREF      toupper
     XREF      strlen
     XREF      strrchr
     XREF      mmalloc
     XREF      mfree
     XREF      smalloc,smfree
     XREF      dgetdrv
     XREF      fn_name
     XREF      ffind
     IF   DEBUG
     XREF      hexl,crlf
     ENDIF

* von SERNO

     XREF      serno_t2
     XREF      serno_t3
     XREF      serno_t4

* von WDIALOG

     XREF      wdlg_create
     XREF      wdlg_open
     XREF      wdlg_close
     XREF      wdlg_delete
     XREF      wdlg_get_tree
     XREF      wdlg_get_edit
     XREF      wdlg_get_udata
     XREF      wdlg_get_handle
     XREF      wdlg_set_edit
     XREF      wdlg_set_tree
     XREF      wdlg_set_size
     XREF      wdlg_set_iconify
     XREF      wdlg_set_uniconify
     XREF      wdlg_evnt
     XREF      wdlg_redraw

* von LISTBOX

     XREF      lbox_create
     XREF      lbox_update
     XREF      lbox_do
     XREF      lbox_delete
     XREF      lbox_cnt_items
     XREF      lbox_get_tree
     XREF      lbox_get_avis
     XREF      lbox_get_udata
     XREF      lbox_get_afirst
     XREF      lbox_get_slct_idx
     XREF      lbox_get_items
     XREF      lbox_get_item
     XREF      lbox_get_slct_item
     XREF      lbox_get_idx
     XREF      lbox_set_asldr
     XREF      lbox_set_items
     XREF      lbox_free_items
     XREF      lbox_free_list
     XREF      lbox_ascroll_to
     XREF      lbox_get_bvis
     XREF      lbox_get_bfirst
     XREF      lbox_get_bentries
     XREF      lbox_set_bsldr
     XREF      lbox_bscroll_to
     XREF      lbox_set_bentries

* von FNT_MENU

     XREF      fnts_create
     XREF      fnts_delete
     XREF      fnts_open
     XREF      fnts_close
     XREF      fnts_get_no_styles
     XREF      fnts_get_style
     XREF      fnts_get_name
     XREF      fnts_get_info
     XREF      fnts_add,fnts_remove
     XREF      fnts_evnt
     XREF      fnts_do
     XREF      fnts_update

* von FSEL

     XREF      fsel_exinput
     XREF      fslx_open
     XREF      fslx_close
     XREF      fslx_getnxtfile
     XREF      fslx_evnt
     XREF      fslx_do
     XREF      fslx_set

* von FARBIC

     XREF      xp_colmp


	XDEF act_appl

**********************************************************************
**********************************************************************
*
* INITIALISIERUNG VON AES UND START VON AES
*

aes_start:
     DEBON
     DEB  'AES: vor dem ersten Befehl'
 jsr      serno_t3

 movea.l  4(sp),a5                 ; a5 = Zeiger auf Basepage
 move.l   a5,_basepage
 clr.l    -(sp)
 gemdos   Super
 addq.w   #6,sp
 move.l   d0,sp                    ; Stack ist Default-SSP
 suba.l   a0,a0
 move.l   a0,usp                   ; usp ist ungueltig

 move.l   $c(a5),a0                ; p_tlen  (0)
 add.l    $14(a5),a0               ; p_dlen  (0)
 add.l    $1c(a5),a0               ; p_blen  (0)
 lea      $100(a0),a0              ; + sizeof(PD)
 move.l   a0,-(sp)
 move.l   a5,-(sp)
 clr.w    -(sp)
 gemdos   Mshrink
 lea      12(sp),sp

     DEB  'AES: nach Mshrink()'

 move.l   _basepage,a0
 move.l   $2c(a0),a0
 jsr      env_clr_int              ; Environment saeubern von LINES+COLUMNS

/* AES-Dispatcher */

 move.w   #201,fn_rellen
 clr.l    fn_abstab
 clr.w    fn_abslen
 move.l   #appl_getinfo,fn_getinfo
 clr.l    fn_editor

/* Dateiauswahl: */

 move.l   #fsel_exinput,p_fsel
 clr.w    fslx_sortmode            ; SORTBYNAME
 move.w   #1,fslx_flags            ; SHOW_8P3
 move.w   #5,-(sp)                 ; subfn 5
 move.l   #'AnKr',-(sp)
 move.w   #39,-(sp)
 trap     #14                      ; xbios Puntaes
 addq.l   #8,sp
 move.l   d0,fslx_d2s              ; Datumanzeigeroutine

 move.l   etv_term,dflt_etvt       ; etv_term des DOS merken
 move.l   #draw_int,mdraw_int_adr  ; Dummyroutine
     DEB  'AES: vor Setzen von IPL7'
 ori      #$700,sr
 move.l   $88,old_trap2
 move.l   #aes_trap2,$88
 clr.w    aptr_flag                ; kein appl_trecord am Laufen
 clr.w    aptr_count
 clr.l    aptr_buf
 clr.w    aptp_dirtyint

 clr.w    bdrop_thdl               ; kein Backdrop am Laufen
 clr.w    topall_thdl              ; kein TopAll am Laufen

 clr.w    was_warmboot
 clr.l    old_warmbvec
 bsr      disa_warmb               ; Ctrl-Alt-Del => shutdown

 clr.l    menutree
 clr.l    pop_list
 clr.l    shel_vector
 clr.l    notready_list
 clr.l    suspend_list
 clr.l    timer_evlist             ; laufende Timerevents
 clr.l    alrm_evlist              ; laufende Talarm
 clr.l    iocpbuf_cnt
 clr.w    ringbuf_tail
 clr.w    ringbuf_head

* Semaphore fuer Bildschirm initialisieren

 move.l   #'_SCR',d1
 lea      upd_blockage,a0
 moveq    #SEM_CREATE,d0
 bsr      evnt_sem

 lea      vmn_set,a0
 move.l   #200,(a0)+               ; mns_Display
 move.l   #10000,(a0)+             ; mns_Drag
 move.l   #250,(a0)+               ; mns_Delay
 clr.l    (a0)+                    ; mns_Speed
 move.w   #16,(a0)                 ; mns_Height

 clr.w    beg_mctrl_cnt

 clr.w    int_butstate             ; Maustasten losgelassen
 clr.w    int_but_dirty            ; kein Ringpufferueberlauf
 clr.w    mcl_bstate
 clr.w    mcl_timer
 clr.w    mcl_count
 clr.w    mcl_in_events

 clr.w    gr_mkmstate
 clr.w    gr_mkkstate
 clr.w    gr_mnclicks
 clr.w    gr_evbstate
 clr.w    prev_mkmstate
 clr.w    prev_mnclicks
 clr.w    prev_count
 clr.w    prev_mkmx
 clr.w    prev_mkmy

 clr.b    hotkey_sem
 clr.b    serno_isok               ; noch ungetestet
 clr.w    dclick_val

* Startbild (Default-Desktop)

 move.w   #2*24+28,d0              ; 2 OBJECTs + 1 TEDINFO
 lea      title_tree(pc),a1
 lea      shelw_startpic,a0
 jsr      vmemcpy

 lea      shelw_startpic,a0
 lea      48(a0),a1                ; TEDINFO
 move.l   a1,24+ob_spec(a0)        ;  eintragen

* 2 APPLs initialisieren

 clr.w    appln                    ; noch keine APPL
 clr.l    act_appl
 clr.l    topwind_app
 move.w   #NAPPS,maxappln          ; Tabellenlaenge

 lea      iocpbuf,a0
 move.w   #NAPPS,d0
 bsr      clrmem                   ; iocpbuf loeschen

 lea      applx,a0
 move.w   #4*NAPPS,d0
 bsr      clrmem                   ; alle NAPPS Pointer loeschen

 move.l   _basepage,d1             ; Basepage des AES
 suba.l   a2,a2                    ; kein Usercode
 lea      leerstring(pc),a1        ; Leername
 moveq    #0,d0                    ; Stack nicht setzen
 move.l   app0,a0                  ; APPL (von BIOS bereits alloziert!)
 bsr      init_APPL

 move.l   #ap_stack,d0
 add.l    sust_len.w,d0
 jsr      mmalloc                   ; Speicher fuer APP #1 allozieren
 beq      fatal_err                ; zuwenig Speicher, FATAL
 movea.l  d0,a0

 moveq    #0,d1                    ; keine Basepage
 lea      screnmgr(pc),a2          ; Usercode
 lea      screnmgrname_s(pc),a1    ; 'SCRENMGR.LOC',0
 move.l   sust_len.w,d0            ; Stacklaenge: nur WORD !!!
;move.l   a0,a0
 bsr      init_APPL

 andi     #$f8ff,sr
     DEB  'AES: IPL wieder auf 3'

* Applikation 1 (SCRENMGR) initialisieren

 clr.w    no_of_menuregs
 lea      reg_entries,a0
 moveq    #4*NACCS,d0
 bsr      clrmem                   ; alle ACC-Menueeintraege loeschen

 clr.w    scmgr_wakeup

*
* INF-Datei verarbeiten
*

 bsr      read_magix_inf           ; hier wird das VDI- Device festgelegt

*
* Initialisierungen
*

 clr.l    xp_tab                   ; keine Farbicon-Farbtabelle
 jsr      init_vdi                 ; hier wird das VDI- Device geoeffnet
 bsr      alloc_screenbuf          ; mit diesen Infos Pufferspeicher holen

*
* ACCs und APPs laden
*

/*
 jsr      load_all_accs
 jsr      load_all_apps
 jsr      graph_mode
*/

 clr.l    alrm_cntdown
 clr.l    timer_cntdown
 clr.l    timer_cnt
 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; disable_interrupt

 pea      gem_etvc
 move.l   #$50101,-(sp)
 trap     #$d                      ; bios Setexc(etv_critic)
 addq.w   #8,sp
 move.l   d0,old_etvc
 move.l   #timer_int,vcontrl+14    ; Zusatzcode contrl[7]
 move.l   #$76000000,d0            ; Exchange timer interrupt vector
 jsr      vdi_quick                ; vex_timv
 move.l   vcontrl+18,old_timer_int ; Zusatzcode contrl[9]
 move.w   vintout,ms_per_click

 move.w   (sp)+,sr                 ; enable_interrupt

;DC.W     $a000                    ; A_INIT
;lea      -$358(a0),a0             ; Zeiger auf aktuelle Mausdaten
;move.l   a0,mousedata
 jsr      mouse_immed

 jsr      serno_t4

 moveq    #1,d1
 moveq    #3,d0
 bsr      evnt_dclicks

* 3D- Objekte erlauben je nach Modus

 btst     #1,look_flags+1
 seq      d2
 andi.w   #1,d2
 swap     d2                       ; 3D aktivieren
 moveq    #10,d1                   ; MX_ENABLE3D
 moveq    #1,d0                    ; set
 movem.l  d0-d2,-(sp)
 jsr      _objc_sysvar             ; hier wird erstmal enable_3d bestimmt

 jsr      init_windows

 movem.l  (sp)+,d0-d2
 jsr      _objc_sysvar             ; hier werden Fenster auf 2D/3D geaendert

* Groesse der Objekte des Desktophintergrunds festlegen

 lea      shelw_startpic,a0
 move.w   scr_w,ob_width(a0)
 move.w   scr_h,ob_height(a0)      ; Hoehe des Hintergrunds
 move.w   scr_w,24+ob_width(a0)
 move.w   big_hchar,d0
 addq.w   #2,d0
 move.w   d0,24+ob_height(a0)      ; Hoehe des weissen Textbalkens
     IF   MACOS_SUPPORT
 tst.w    shelw_startpic+ob_spec+2
 bne.b    swsp_set
 move.w   #G_IBOX,ob_type+shelw_startpic
 move.w   #G_IBOX,ob_type+24+shelw_startpic
swsp_set:
     ENDIF

* Breite der Dateiauswahl festlegen

 moveq    #39,d0
 mulu     big_wchar,d0
 addq.w   #3,d0
 move.w   d0,fslx_dlw              ; 39 Zeichen plus 3 Pixel
 move.w   d0,fslx_dlm              ; = minimale Breite

* Schnittstelle zu GEMDOS einrichten

 move.w   #2,-(sp)                 ; Parameterblock holen
 move.w   #$33,-(sp)               ; Sconfig
 trap     #1
 addq.l   #4,sp
 tst.l    d0
 ble.b    saes_nokaos
 move.l   d0,a0
 move.l   $36(a0),a0               ; xaes_appls
 lea      dos_magic,a1
 move.l   #'XAES',(a1)
 move.w   #ap_pd,8(a1)
 move.l   a1,(a0)

saes_nokaos:
 clr.w    inaes                    ; Taskwechsel erlauben
;clr.b    no_switch

 move.l   bdrop_timer,d0
 bsr      ctrl_timeslice

*
* SLBs, APPs, ACCs laden
*

 bsr      load_all_slbs
 move.l   p_mgxinf,d0
 beq.b    saes_no_inf
 move.l   d0,a0
 clr.l    p_mgxinf
 jsr      mfree
saes_no_inf:
 bsr      load_all_accs
 bsr      load_all_apps
 bsr      graph_mode

*
* START!!!
*

 move.l   #gem_magics,(config_status+8).w
 move.w   #400,d7
saes_yloop:
 jsr      _appl_exit
 dbra     d7,saes_yloop

* ggf. Autoexec- Programm im eigenen (!) Pfad starten

 move.l   act_appl,a4
 tst.w    ap_doex(a4)              ; Programm automatisch starten ?
 beq.b    saes_noautoex            ; nein, sofort in die Hauptschleife
 lea      ap_cmd(a4),a0
 bsr      dsetdrv_path             ; Pfad und Laufwerk setzen

*
* Jetzt geht es los mit Applikation #0
*

saes_noautoex:
 bsr      pgm_loader               ; Hauptschleife

*
* Jetzt kommt der Shutdown, AES runterfahren
*

; Time-Slicing deaktivieren

 move.w   #-1,pe_slice             ; Praeemption abschalten

; Semaphore fuer Bildschirm entfernen

 lea      upd_blockage,a0
 moveq    #SEM_DEL,d0
 bsr      evnt_sem

; Schnittstelle zu GEMDOS entfernen

 move.w   #2,-(sp)                 ; Parameterblock holen
 move.w   #$33,-(sp)               ; Sconfig
 trap     #1
 addq.l   #4,sp
 tst.l    d0
 ble.b    saes_nokaosex
 move.l   d0,a0
 move.l   $36(a0),a0               ; xaes_appls
 clr.l    (a0)
saes_nokaosex:

; keine Applikation mehr (Boot-Mode)

 clr.l    act_appl

; Vektoren fuer
;    etv_critic
;    timer
;    trap #2
; restaurieren

 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; disable_interrupt
 move.l   old_etvc,-(sp)
 move.l   #$50101,-(sp)
 trap     #$d                      ; bios Setexc(etv_critic)
 addq.w   #8,sp
 move.l   old_timer_int,vcontrl+14 ; Zusatzcode contrl[7]
 move.l   #$76000000,d0            ; Exchange timer interrupt vector
 jsr      vdi_quick                ; vex_timv
 moveq    #0,d0
 jsr      set_scrmode              ; Textmodus, Mausinterrupts ausschalten
 bsr.s    restore_trap2
 move.w   (sp)+,sr                 ; enable_interrupt

; Farbicon-Farbtabelle freigeben
; nicht noetig, das macht das Pterm!

/*
 move.l   xp_tab,d0
 beq.b    chgr_noxptab
 move.l   d0,a0
 jsr      mfree
chgr_noxptab:
*/

; Bildschirmpuffer freigeben nicht noetig, das macht das Pterm!

 pea      -1
 gemdos   Slbclose                 ; alle SLBs schliessen
 addq.l   #6,sp

 jsr      v_clswk                  ; Workstation schliessen
 gemdos   Pterm0



**********************************************************************
*
* Reinstalliert den alten Trap #2
*
* beruecksichtigt ggf. Programme, die sich im XBRA- Verfahren
* davorgehaengt haben
*

restore_trap2:
 lea      $8c,a0                   ; $88+4
rt2_loop:
 cmpi.l   #aes_trap2,-(a0)
 beq.b    rt2_restore
 move.l   (a0),a0                  ; naechster Vektor in der Kette
 move.l   a0,d0
 beq.b    rt2_ende                 ; NULL- Pointer ist Ende der Kette
 cmpi.l   #'XBRA',-12(a0)
 beq.b    rt2_loop
 bra.b    rt2_ende                 ; Fehler, keine XBRA- Struktur
rt2_restore:
 move.l   old_trap2,d0
 subq.l   #4,d0
 cmp.l    a0,d0
 beq.b    rt2_ende                 ; nicht deinstallieren, um Kreis zu verhindern
 move.l   old_trap2,(a0)
 clr.l    old_trap2                ; merken, dass ausgeklinkt
rt2_ende:
 rts

screnmgrname_s: DC.B    'SCRENMGR.LOC',0
     EVEN

title_tree:
 DC.W     -1,1,1
 DC.W     G_BOX,0,0
 DC.L     $1141                    ; frcol=BLACK,tcol=BLACK,IP_4PATT,BLACK
 DC.W     0,0,84,23

 DC.W     0,-1,-1
 DC.W     G_BOXTEXT,LASTOB,0
 DC.L     0
 DC.W     0,0,5,1


 DC.L     0                        ; TEDINFO
 DC.L     0
 DC.L     0
 DC.W     IBM,6,TE_CNTR
 DC.W     $1100                    ; frcol=BLACK,tcol=BLACK,IP_HOLLOW,WHITE
 DC.W     0
 DC.W     -1                       ; Rahmen
 DC.W     0,0


     MC68881

**********************************************************************
*
* void init_FPU( void )
*
* Erzeugt einen NULL-Stackframe fuer die FPU und holt ihn wieder
* vom Stack, damit die FPU geloescht wird.
*
* 8.10.97: Beruecksichtigung des 060 (12 Nullbytes)
*

init_FPU:
 tst.b    is_fpu
 beq.b    if_no_fpu
 cmpi.w   #60,(cpu_typ).l
 bcs.b    if_sml
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 bra.b    if_both
if_sml:
 move.l   #$00380000,-(sp)
if_both:
 frestore (sp)+
if_no_fpu:
 rts


**********************************************************************
*
* void init_ap_startadr(a0 = APP *ap, d0 = void (*usercode)())
*

init_ap_startadr:
;move     sr,d1
;ori      #$700,sr
 movea.l  ap_ssp(a0),a1

* FPU- Nullframe erzeugen
 tst.b    is_fpu
 beq.b    ias_no_fpu
 cmpi.w   #60,(cpu_typ).l
 bcs.b    ias_sml
 clr.l    32(a1)                   ; der 060 hat 12 Bytes Stackframe
 clr.l    36(a1)
 clr.l    40(a1)
 lea      12(a1),a1
 bra.b    ias_no_fpu
ias_sml:
 move.l   #$00380000,32(a1)        ; NULL-FPU-Frame
 addq.l   #4,a1                    ; laengerer Block bei FPU

ias_no_fpu:
 move.l   d0,64(a1)                ; 16 Register ueberspringen
 rts


**********************************************************************
*
* void init_APPL(a0 = APPL *ap,
*                d0 = int stacklen,
*                d1 = PD *basepag
*                a1 = char *name, a2 = void (*usercode)()
*               )
*
* Initialisiert eine APPL- Struktur
* Neu: statt ap_bufp auf ap_buf wird jetzt ap_desktree auf NULL gesetzt
* Die Applikation wird in die Liste applx eingetragen und appln erhoeht
*

init_APPL:
 movem.l  a3/a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = APPL/WDG/CONTEXT
 move.l   a1,a4                    ; a4 = name
 move.l   a2,a3                    ; a3 = usercode

 movem.l  d0/d1,-(sp)

 jsr      serno_t2                 ; Serno OK ?
 bmi.b    srk_err3                 ; nein

 move.w   #ap_stack,d0
 move.l   a5,a0
 bsr      clrmem                   ; APPL loeschen
srk_err3:
 movem.l  (sp)+,d0/d1

 move.l   #'AnKr',ap_stkchk(a5)    ; Magic fuer Pruefung auf Stackueberlauf
 move.w   #'  ',ap_dummy1(a5)      ; Name beginnt mit zwei Leerzeichen
 move.w   #1,ap_wasgr(a5)

 move.l   d1,ap_pd(a5)
 move.l   d1,ap_ldpd(a5)           ; Loader-Prozess merken
 move.l   dflt_etvt,ap_etvterm(a5) ; etv_term vom DOS uebernehmen
 ext.l    d0
 beq.b    iapl_nostack
 lea      ap_stack(a5),a0
 lea      -68(a0,d0.l),a1          ; 17 longs Kontext  (^^^)

* FPU-Status
 tst.b    is_fpu
 beq.b    iapl_no_fpu
 cmpi.w   #60,(cpu_typ).l
 bcs.b    iapl_sml
 lea      -12(a1),a1               ; NULL-Stackframe fuer 060 (12 Bytes)
 bra.b    iapl_no_fpu
iapl_sml:
 subq.l   #4,a1                    ; Platz fuer NULL-Stackframe (0x00380000)
iapl_no_fpu:

 move.l   a1,ap_ssp(a5)
iapl_nostack:
 lea      applx,a1
 moveq    #0,d0
iapl_loop:
 tst.l    (a1)+
 beq.b    iapl_fnd
 addq.w   #1,d0
 cmpi.w   #NAPPS,d0
 bcs.b    iapl_loop
 jmp      fatal_err
iapl_fnd:
 move.l   a5,-(a1)
 addq.w   #1,appln
 move.w   d0,ap_id(a5)
 move.w   d0,-(sp)
 move.l   #-1,ap_parent(a5)
;move.w   #-1,ap_parent2(a5)
 move.l   act_appl,d0
 ble.b    iapl_no_parent
 move.l   d0,a0
 move.w   ap_id(a0),ap_parent(a5)  ; ap_id des parent merken!
iapl_no_parent:
 move.l   a5,a0
 bsr      ap_to_lastready          ; ap in die Readyliste einfuegen (wenn != APPL #0)
 subq.w   #1,(sp)+                 ; APPL #1 ?
 bne.b    iapl_normal
 move.l   a5,keyb_app
 move.l   a5,menu_app
 move.l   a5,mouse_app
iapl_normal:
* Mausformen auf ARROW initialisieren
;clr.w    ap_mhidecnt(a5)
 lea      marrow_data(pc),a1
 lea      (a5),a2
 moveq    #37-1,d2
iapl_mloop:
 move.w   (a1)+,d0
 move.w   d0,ap_svd_mouse(a2)
 move.w   d0,ap_prv_mouse(a2)
 move.w   d0,ap_act_mouse(a2)
 addq.w   #2,a2
 dbra     d2,iapl_mloop             ; 37 Worte von marrow_data

 move.l   a4,a1
 move.l   a5,a0
 bsr      set_apname

 move.l   a3,d0
 beq.b    iapl_norun               ; keine Startadresse
 move.l   a5,a0
 bsr      init_ap_startadr
iapl_norun:
 movem.l  (sp)+,a3/a4/a5
 rts


**********************************************************************
*
* void exit_APPL( d0 = int ap_id, d1 = int exitcode )
*
* Die Applikation <ap_id> wird geloescht. Zunaechst werden die Waisen
* ermittelt (deren parent = ap_id ist), und deren ap_parent auf -1
* gesetzt.
*
* MagiC 3 ab 22.4.95:    verschicke PA_EXIT an alle Kinder
*
* Anschliessend bekommt der Parent von ap_id, falls gueltig
* ein CH_EXIT. Gehirnamputierterweise ist <exitcode> nur int, nicht
* long.
*
* MagiC 4.5:   Sowohl echter parent auch parent2 (vt52) bekommen
*              ein CH_EXIT
* MagiC 5.5:   Nur parent2 (vt52) bekommt CH_EXIT, da es von VT52
*              weitergereicht wird.
*

exit_APPL:
 movem.l  a6/d7/d6,-(sp)
 move.w   d0,d6                    ; apid
 clr.l    -(sp)
 clr.w    -(sp)
 move.w   d1,-(sp)                 ; exitcode
 lea      applx,a6
 moveq    #NAPPS-1,d7
eapl_tloop:
 move.l   (a6)+,d2                 ; Slot unbenutzt
 ble.b    eapl_tnext
 move.l   d2,a0
 addq.l   #ap_parent2,a0
 cmp.w    (a0),d6                  ; VT52 beendet ?
 bne.b    eapl_no52                ; nein
 move.w   #-1,(a0)                 ; VT52 hier austragen
eapl_no52:
 subq.l   #ap_parent2-ap_parent,a0
 cmp.w    (a0),d6                  ; bin ich der parent ?
 bne.b    eapl_tnext               ; nein
; verschicke PA_EXIT
 move.w   #-1,(a0)                 ; parent ist ungueltig ("Waise")
 move.w   d6,d2                    ; ap_id der beendeten Applikation
 move.w   ap_id-ap_parent(a0),d1   ; Ziel-ID
 moveq    #PA_EXIT,d0
 move.l   sp,a0
 jsr      send_msg
eapl_tnext:
 dbra     d7,eapl_tloop
 move.w   d6,d0
 bsr      id2app
 move.l   a0,a6
 move.w   ap_parent2(a6),d1        ; VT52 benachrichtigen ?
 bmi.b    eapl_nopar2              ; nein
 move.l   sp,a0
 move.w   d6,d2                    ; ap_id der beendeten Applikation
;move.w   d1,d1                    ; ID des VT52
 moveq    #CH_EXIT,d0
 jsr      send_msg
 bra.b    eapl_ende
eapl_nopar2:
 tst.w    ap_type(a6)              ; main thread ?
 bne.b    eapl_ende                ; nein, Thread oder sowas
 move.w   ap_parent(a6),d1
 bmi.b    eapl_ende                ; bin Waise
 move.l   sp,a0
 move.w   d6,d2                    ; ap_id der beendeten Applikation
;move.w   d1,d1                    ; Ziel-ID
 moveq    #CH_EXIT,d0
 jsr      send_msg
eapl_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a6/d7/d6
 rts


**********************************************************************
*
* void appl_info( void )
*
* darf a2 nicht aendern, weil von check_kb aufgerufen
*

info_init_s:
 DC.B     $1b,'E',$1b,'Y',22+32,2+32         ; CLS;Pos(2,22)
 DC.B     'cur_up: prev    |  '
 DC.B     'Space:  OK       |  '
 DC.B     'F:     Freeze   |  '
 DC.B     'C:      Control'
 DC.B     $d,$a,'  '
 DC.B     'cur_dn: next    |  '
 DC.B     'Return: Switch   |  '
 DC.B     'U:     Unfreeze |  '
 DC.B     'Del:    Terminate'
 DC.B     0

status_s:
 DC.B     'ready',0
 DC.B     'wait ',0
 DC.B     'suspd',0
 DC.B     'zmbie',0
 DC.B     'stopd',0
 DC.B     'run  ',0
 DC.B     'frozn',0

ev_s:
 DC.B     'kb'
 DC.B     'bt'
 DC.B     'm1'
 DC.B     'm2'
 DC.B     'ms'
 DC.B     'ti'
 DC.B     'se'
 DC.B     'io'
 DC.B     'pi'
 DC.B     'fk'

in1_s:
 DC.B     'MENU ',0
in2_s:
 DC.B     'MOUSE ',0
in3_s:
 DC.B     'KBD ',0
in4_s:
 DC.B     'SCR ',0
used_s:
 DC.B     '%L Byt',$1b,'q',$d,$a,0

     EVEN

putch:
 move.w   d0,-(sp)
 move.l   #$30002,-(sp)
 trap     #13                      ; bios Bconout
 addq.l   #6,sp
 rts


_appl_info:
 move.l   act_appl,-(sp)
 move.l   applx+4,act_appl         ; wegen Speicherzuteilung!
 movem.l  d7/a3/a4/a5,-(sp)
 move.w   d0,-(sp)
 moveq    #$1b,d0
 bsr.s      putch
 moveq    #'Y',d0
 bsr.s    putch
 moveq    #33,d0
 add.w    (sp),d0
 bsr.s    putch                    ; y
 moveq    #32,d0
 bsr.s    putch                    ; x
 cmp.w    (sp),d4                  ; Cursor- Pos. ?
 bne.b    _api_no_blk              ; nein
 moveq    #$1b,d0
 bsr.s    putch
 moveq    #'p',d0                  ; Invers ein
 bsr.s    putch
_api_no_blk:
 move.w   (sp)+,d0
 move.b   0(a6,d0.w),d0            ; Nr. -> ap_id
 ext.w    d0
 add.w    d0,d0
 add.w    d0,d0
 lea      applx,a3
 add.w    d0,a3
 move.l   (a3),d0
 bclr     #31,d0
 move.l   d0,a5

* ap_id: 2 Stellen dezimal

 move.w   ap_id(a5),d7
 ext.l    d7
 divu     #10,d7
 moveq    #' ',d0
 tst.w    d7
 beq.b    _api_l1
 moveq    #'0',d0
 add.w    d7,d0
_api_l1:
 bsr.s    putch
 swap     d7
 moveq    #'0',d0
 add.w    d7,d0
 bsr.s    putch

* eine Leerstelle

 moveq    #' ',d0
 bsr.s    putch

* Name

 lea      ap_name(a5),a0
 clr.b    ap_name+8(a5)
 bsr      prtstr
 move.b   #' ',ap_name+8(a5)

* eine Leerstelle

 moveq    #' ',d0
 bsr      putch

* Status

 moveq    #5,d0
 cmpa.l   act_appl,a5
 beq.b    _api_st                  ; running
 moveq    #6,d0
 tst.l    (a3)
 bmi.b    _api_st                  ; frozen
 move.b   ap_status(a5),d0
 ext.w    d0                       ; 0=ready 1=waiting
                                   ; 2=suspended 3=zombie 4=stopped
_api_st:
 mulu     #6,d0
 lea      status_s(pc),a0
 add.w    d0,a0
 bsr      prtstr

* eine Leerstelle

 moveq    #' ',d0
 bsr      putch

* wartet auf

 move.w   ap_rbits(a5),d7
 lea      ev_s(pc),a4
_api_loopev:
 btst     #0,d7
 bne.b    _api_ev
 moveq    #' ',d0
 bsr      putch
 moveq    #' ',d0
 bsr      putch
 addq.l   #2,a4
 bra.b    _api_nxtev
_api_ev:
 move.b   (a4)+,d0
 bsr      putch
 move.b   (a4)+,d0
 bsr      putch
_api_nxtev:
 moveq    #' ',d0
 bsr      putch
 lsr.w    #1,d7
 cmpa.l   #ev_s+20,a4
 bcs.b    _api_loopev

* bekommt

 moveq    #0,d7                    ; 0 Zeichen gedruckt
 cmpa.l   menu_app,a5
 bne.b    _api_no_mn
 lea      in1_s(pc),a0
 bsr      prtstr
 addq.w   #5,d7
_api_no_mn:
 cmpa.l   mouse_app,a5
 bne.b    _api_no_mo
 lea      in2_s(pc),a0
 bsr      prtstr
 addq.w   #6,d7
_api_no_mo:
 cmpa.l   keyb_app,a5
 bne.b    _api_no_ke
 lea      in3_s(pc),a0
 bsr      prtstr
 addq.w   #4,d7
_api_no_ke:
 lea      upd_blockage,a0
 tst.w    (a0)+
 beq.b    _api_no_sc
 cmpa.l   (a0),a5
 bne.b    _api_no_sc
 lea      in4_s(pc),a0
 bsr      prtstr
 addq.w   #4,d7
_api_no_sc:
 subi.w   #19,d7
 neg.w    d7
 bra.b    _api_snxt
_api_sloop:
 moveq    #' ',d0
 bsr      putch
_api_snxt:
 dbra     d7,_api_sloop

* belegter Speicher

 move.l   ap_pd(a5),a0
 jsr      pd_used_mem              ; aus MAGIDOS

 suba.w   #30,sp
 move.l   d0,-(sp)
 pea      (sp)
 pea      used_s(pc)
 pea      12(sp)
 jsr      _sprintf
 lea      16(sp),sp
 lea      (sp),a0
_api_lloop:
 cmpi.b   #' ',(a0)+
 bne.b    _api_lloop
 suba.l   sp,a0
 move.w   a0,d7
 subi.w   #10,d7
 neg.w    d7
 bra.b    _api_usnxt
_api_usloop:
 moveq    #' ',d0
 bsr      putch
_api_usnxt:
 dbra     d7,_api_usloop
 lea      (sp),a0
 bsr      prtstr
 adda.w   #30,sp
 movem.l  (sp)+,d7/a3/a4/a5
 move.l   (sp)+,act_appl
 rts


* global: a6 = Tabelle der ap_ids
*         d4 = Cursorposition

appl_info:
 movem.l  d4/d6/d7/a2/a5/a6,-(sp)
 bset     #0,status_bits+3
 DC.W     $a000                    ; AINIT
 move.l   V_CUR_XY(a0),-(sp)       ; Cursorposition retten
 move.l   V_CUR_AD(a0),-(sp)       ; Cursorposition retten
 suba.w   #NAPPS+2+4,sp
 lea      4(sp),a6                 ; Tabelle hier ablegen

 jsr      mouse_off

 lea      (sp),a2
 move.l   act_appl,a5
 move.l   applx+4,act_appl         ; wegen Speicherzuteilung!
 lea      full_g,a1
 moveq    #0,d0                    ; FMD_START
 jsr      __fm_xdial

 lea      info_init_s(pc),a0
 bsr      prtstr
 move.l   a5,act_appl

 move.l   menu_app,d0
 bgt.b    api_is_men               ; nimm menuebesitzende Applikation
 move.l   a5,d0                    ; act_appl
 bgt.b    api_is_men               ; nimm aktuelle Applikation
 move.l   applx+4,d0               ; APPL #1 (SCRENMGR)
api_is_men:
 move.l   d0,a0
 move.w   ap_id(a0),d2             ; aktive ap_id

 lea      applx,a1
 move.l   a6,a2
 moveq    #-1,d4                   ; aktuelle Cursorpos. ungueltig
 moveq    #0,d1                    ; lfd.Nr.
api_aploop:
 move.l   (a1)+,d0
 beq.b    api_nextap               ; unbenutzt
 bclr     #31,d0
 move.l   d0,a0
 move.w   ap_id(a0),d0             ; ap_id
 cmp.w    d2,d0                    ; Cursorpos. ?
 bne.b    api_no_cur
 move.w   d1,d4                    ; lfdNr. merken
api_no_cur:
 move.b   d0,(a2)+                 ; ap_id merken
 addq.w   #1,d1
api_nextap:
 cmpa.l   #applx+(4*NAPPS),a1
 bcs      api_aploop
 st.b     (a2)                     ; Tabelle mit -1 abschliessen
 suba.l   a6,a2
 move.w   a2,d6                    ; Tabellenlaenge

 moveq    #0,d7
 bra.b    api_shownxt
api_showloop:
 move.w   d7,d0
 bsr      _appl_info
 addq.w   #1,d7
api_shownxt:
 cmp.w    d6,d7
 bcs.b    api_showloop

*********************
*
* Die grosse Schleife:
*
*********************

api_cin:
 move.l   act_appl,-(sp)
 move.l   applx+4,act_appl         ; wegen Speicherzuteilung!
 move.l   #$20002,-(sp)
 trap     #13                      ; bios Bconin
 addq.w   #4,sp
 move.l   (sp)+,act_appl
 cmpi.b   #$1b,d0
 beq.b    api_cin
 move.b   0(a6,d4.w),d1
 ext.w    d1                       ; d1 = angewaehlte ap_id
 lea      applx,a0
 add.w    d1,a0
 add.w    d1,a0
 add.w    d1,a0
 add.w    d1,a0                    ; a0 = Tabelleneintrag (APPL **)

*
* ap_nr
*

 cmpi.b   #'0',d0
 bcs      ap_ok0
 cmpi.b   #'9',d0
 bhi      ap_ok0
 subi.b   #'0',d0
 ext.w    d0
 move.w   d0,d1
 cmp.w    d6,d1
 bcc      api_cin
 move.w   d4,d0
 move.w   d1,d4
 bra      api_l1

*
* Cursor hoch
*

ap_ok0:
 cmpi.l   #$480000,d0              ; Cursor hoch
 bne.b    api_ok1
 move.w   d4,d0                    ; alte Cursor- Pos. merken
 subq.w   #1,d4
 bcc.b    api_l1
 moveq    #0,d4
api_l1:
 bsr      _appl_info               ; alte zeichnen
 move.w   d4,d0
 bsr      _appl_info               ; neue zeichnen
 bra      api_cin

*
* Cursor runter
*

api_ok1:
 cmpi.l   #$500000,d0              ; Cursor runter
 bne.b    api_ok2
 move.w   d4,d0                    ; alte Cursor- Pos. merken
 addq.w   #1,d4
 cmp.w    d6,d4
 bcs.b    api_l2
 move.w   d6,d4
 subq.w   #1,d4
api_l2:
 bra      api_l1

*
* Delete
*

api_ok2:
 cmpi.l   #$53007f,d0              ; Del
 bne      api_ok3
 move.l   (a0),d1
 bclr     #31,d1                   ; APPL *
 move.l   d1,a2
 cmpi.b   #APSTAT_ZOMBIE,ap_status(a2)
 beq      api_cin
 move.l   ap_pd(a2),d1             ; PD
 beq      api_cin                  ; PD ungueltig (SCRENMGR)
* APPL in kritischer Phase ?
 tst.w    ap_critic(a2)            ; kritische Phase ?
 beq.b    api_nocritic             ; nein
 bset     #0,ap_crit_act(a2)       ; Flag fuer "muss terminieren"
 bra      api_ende

api_nocritic:
 move.l   d1,a1
;tst.l    p_parent(a1)
;beq      api_cin                  ; Parent ungueltig (ACC)
 tst.b    inaes                    ; von appl_yield aufgerufen ?
 bne.b    api_y                    ; ja, komplizierte Methode
 cmp.l    a5,a2                    ; laufende APPL loeschen ?
 beq      appl_break               ; ja, brutale Methode
api_y:
* Hier zu loeschende APPL am Starten hindern:
 tst.b    no_switch                ; bin im etv_critic ?
 bne.b    api_d1                   ; ja, nur Nachricht an screnmgr schicken
 cmpa.l   menu_app,a2
 beq.b    api_y1                   ; aktuelles Menue/Hintergrund nicht weg!
 clr.l    ap_menutree(a2)
 clr.l    ap_attached(a2)
 clr.l    ap_desktree(a2)
api_y1:
 tst.l    (a0)
 bmi.b    api_d3                   ; schon eingefroren
 move.l   a2,-(sp)
 move.l   a2,a0
 bsr      _appl_freeze
 move.l   (sp)+,a2
api_d3:
 move.b   #APSTAT_ZOMBIE,ap_status(a2)
 lea      upd_blockage,a0
 tst.w    (a0)
 beq.b    api_d1                   ; nicht blockiert
 cmp.l    bl_app(a0),a2            ; zu loeschende blockiert alles ?
 bne.b    api_d1                   ; nein
 move.w   #1,(a0)                  ; Zaehler auf 1
 move.l   a2,-(sp)
 bsr      end_update               ; Sperrung loesen
 move.l   (sp)+,a2
api_d1:
 moveq    #1,d0                    ; loeschen
api_sndmsg:
 subq.l   #8,sp
 move.l   sp,a0
 move.l   #'MAGX',(a0)+            ; mbuf[4,5] = magischer Wert
 move.w   d0,(a0)+                 ; mbuf[6]   = Fkt.Nr.
 move.w   ap_id(a2),(a0)+          ; mbuf[7]   = ap_id
 move.l   sp,a0
 moveq    #0,d2                    ; mbuf[3] ist 0
 moveq    #1,d1                    ; dst_apid = SCRENMGR
 moveq    #SM_M_SPECIAL,d0         ; Nachrichtencode (Mag!X 2.00)
 jsr      send_msg
 addq.l   #8,sp
 bra      api_ende

*
* Return
*

api_ok3:
 cmpi.b   #$d,d0                   ; Return
 bne.b    api_ok4
 move.l   (a0),d0                  ; APPL *
 ble      api_cin                  ; ungueltig
 move.l   d0,a2
 move.l   ap_menutree(a2),d0
 or.l     ap_desktree(a2),d0
 beq      api_cin                  ; hat weder Menue noch Hintergrund
 moveq    #2,d0                    ; Funktionsnummer fuer Umschalten
 bra      api_sndmsg

*
* F
*

api_ok4:
 jsr      toupper
 cmpi.b   #'F',d0                  ; 'F'
 bne.b    api_ok5
 move.l   (a0),d0                  ; APPL *
 ble      api_cin                  ; ungueltig oder schon eingefroren
 cmpi.w   #1,d1
 beq      api_cin                  ; screnmgr
 move.l   d0,a2
 moveq    #3,d0                    ; Funktionsnummer fuer Einfrieren
 bra      api_sndmsg

*
* U
*

api_ok5:
 cmpi.b   #'U',d0                  ; 'U'
 bne.b    api_ok6
 move.l   (a0),d0                  ; APPL *
 bge      api_cin                  ; ungueltig oder nicht eingefroren
 bclr     #31,d0
 move.l   d0,a2
 cmpi.b   #APSTAT_ZOMBIE,ap_status(a2)
 beq      api_cin                  ; zombie
 moveq    #4,d0                    ; Funktionsnummer fuer Auftauen
 bra      api_sndmsg

*
* C
*

api_ok6:
 cmpi.b   #'C',d0
 bne.b    api_ok7
 move.l   (a0),d0                  ; APPL *
 ble      api_cin                  ; ungueltig oder eingefroren
 move.l   d0,keyb_app
 move.l   d0,a0
 bsr      set_mouse_app
 bra      api_ende

* Ende

api_ok7:
 cmpi.b   #' ',d0
 bne      api_cin

api_ende:
 tst.l    (sp)
 beq.b    api_tidy
 lea      (sp),a2
 lea      full_g,a1
 moveq    #3,d0                    ; FMD_FINISH
 jsr      __fm_xdial
 bra      api_notidy

api_tidy:
 subq.l   #8,sp
 move.l   sp,a0
 move.l   #'MAGX',(a0)+            ; mbuf[4,5] = magischer Wert
 clr.l    (a0)                     ; mbuf[6]   = 0 (aufraeumen)
 move.l   sp,a0
 moveq    #0,d2                    ; mbuf[3] ist 0
 moveq    #1,d1                    ; dst_apid = SCRENMGR
 moveq    #SM_M_SPECIAL,d0         ; Nachrichtencode (Mag!X 2.00)
 jsr      send_msg
 addq.l   #8,sp

api_notidy:
 jsr      mouse_on

 adda.w   #NAPPS+2+4,sp
 DC.W     $a000                    ; AINIT
 move.l   (sp)+,V_CUR_AD(a0)
 move.l   (sp)+,V_CUR_XY(a0)       ; Cursorposition restaurieren
 bclr     #0,status_bits+3
 movem.l  (sp)+,a6/a5/a2/d4/d6/d7
 rts


**********************************************************************
*
* void change_resolution( d0 = newdevice, d1 = newtxt, d2 = xdv )
*
* Aendert das VDI- Device und verursacht einen Warmstart.
*
* Ab 11.11.95: <xdv> legt den zusaetzlichen Falcon-Modus fest.
*

     MC68020

change_resolution:
 lea      (xaes_area).l,a0
 move.l   #'XAES',(a0)+            ; magic merken
 move.w   d0,(a0)+                 ; VDI- Geraetenummer beim Neustart
 move.w   d1,(a0)+                 ; Fonthoehe
 move.w   d2,(a0)+                 ; xdv (Falcon)
 clr.w    (a0)                     ; Rest ausnullen
 rts
/*
 move.l   xp_tab,d0
 beq.b    chgr_noxptab
 move.l   d0,a0
 jsr      mfree                    ; Farbicon-Farbtabelle freigeben
chgr_noxptab:
 jsr      v_clswk                  ; Workstation schliessen
 pea      warm_boot                ; vom BIOS
 move.w   #38,-(sp)
 trap     #14                      ; xbios Supexec
*/


**********************************************************************
*
* void read_magix_inf( void )
*
* Wertet die MAGX.INF aus und legt das Environment sowie den put/get-
* puffer an.
*

     IF   COUNTRY=COUNTRY_DE
inf_errs:      DC.B $d,$a,'Fehler in MAGX.INF ',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
inf_errs:      DC.B $d,$a,'Error in MAGX.INF ',0
     ENDIF
     IF  COUNTRY=COUNTRY_FR
inf_errs:      DC.B $d,$a,'Erreur dans MAGX.INF ',0
     ENDIF
/*
ver_token:     DC.B '#_MAG MAG!X V',0
*/
aes_sec_token: DC.B '#[aes]',0
inf_defdata:
          DC.B "#a000000",$d,$a
          DC.B "#b001000",$d,$a
          DC.B "#c7770007000600070055200505552220770557075055507703111302",$d,$a
          DC.B "#d                                             ",$d,$a,0
     EVEN

_copy_line:
 tst.b    (a2)                     ; die ganze Zeile uebernehmen
 beq.b    _cl_ende
 cmpi.b   #$d,(a2)
 beq.b    _cl_ende
 move.b   (a2)+,(a0)+
 bra.b    _copy_line
_cl_ende:
 clr.b    (a0)
 rts

_copy_string:
 tst.b    (a2)                     ; Zeile bis Leerstelle uebernehmen
 beq.b    _cl_ende
 cmpi.b   #$d,(a2)
 beq.b    _cl_ende
 cmpi.b   #' ',(a2)
 beq.b    _cl_ende
 cmpi.b   #9,(a2)
 beq.b    _cl_ende
 move.b   (a2)+,(a0)+
 bra.b    _copy_string

_skip_spc:
 cmpi.b   #' ',(a2)                ; SPACE
 beq.b    _sk_sk
 cmpi.b   #9,(a2)                  ; TAB
 beq.b    _sk_sk
 rts
_sk_sk:
 addq.l   #1,a2
 bra.b    _skip_spc

read_magix_inf:
 movem.l  d6/d7/a3/a4/a5/a6,-(sp)
 subq.l   #4,sp
 move.l   act_appl,a3              ; sollte immer Applikation #0 sein
* Defaultdaten:

;clr.w    ap_doex(a3)              ; unnoetig, da schon von init_APPL geloescht
 move.w   #SHLBFLEN,shel_buf_len

 clr.w    inw_height
 clr.w    wsg_flags
 move.w   #MIN_NWIND,nwindows      ; Anzahl Fenster
 move.l   #w_sizeof,wsizeof        ; Speicherblockgroesse
 move.l   #_wbm_create,wbm_create            ; Callback
 move.l   #_wbm_skind,wbm_skind              ; Callback
 move.l   #_wbm_ssize,wbm_ssize              ; Callback
 move.l   #_wbm_sslid,wbm_sslid              ; Callback
 move.l   #_wbm_sstr,wbm_sstr                ; Callback
 move.l   #_wbm_sattr,wbm_sattr              ; Callback
 move.l   #_wbm_calc,wbm_calc                ; Callback
 move.l   #_wbm_obfind,wbm_obfind            ; Callback

 move.w   #$ffff,pe_un_susp        ; ### prae-emptiv ###  (wenig bremsen)
 move.w   #-1,bdrop_timer+2        ; ### prae-emptiv ###  (ausgeschaltet!)

 clr.w    big_wchar                ; grosse Zeichengroesse (brutto)
 clr.w    big_hchar
 clr.b    scrp_dir
 clr.b    shel_name
 clr.b    termprog
 clr.b    fslx_exts                ; keine zusaetzlichen Extensions
 clr.w    look_flags
 moveq    #1,d0
 move.w   d0,shel_isfirst
;clr.b    app1+ap_cmd              ; ACC- Pfad: applx[1].ap_cmd
 move.w   d0,vdi_device            ; Treiber fuer aktuelle Aufloesung
                                   ; (falls kein MAGX.INF da)
 clr.w    dflt_xdv                 ; Falcon-Aufloesungsmodus loeschen

 move.w   d0,finfo_big+fontID      ; Systemfont fuer das AES
 move.w   d0,finfo_sml+fontID      ; Systemfont fuer das AES
 move.w   d0,finfo_big+fontmono
 move.w   d0,finfo_sml+fontmono    ; Font ist "monospaced"
 move.w   d0,finfo_inw+fontmono
 clr.w    finfo_big+fontH          ; grosse Zeichenhoehe (netto)
 clr.w    finfo_sml+fontH          ; kleine Zeichenhoehe (netto)
 clr.w    finfo_inw+fontH
 clr.w    finfo_inw+fontID         ; Font zunaechst ungueltig

 suba.l   a6,a6                    ; keine put/get- Daten

 moveq    #0,d6                    ; Laenge des Environments

 move.l   #128000,d0               ; Environment + shbuf + Fenster
 jsr      mmalloc
 beq      fatal_err

 move.l   d0,a5                    ; Adresse merken

* durchsuchen und alle fuer uns interessanten Daten verarbeiten

 move.l   p_mgxinf,d0
 beq      rmi_set                  ; keine INF-Datei!
 move.l   d0,a2

/*

*
* Hier lesen wir erstmal die Versionsnummer der INF-Datei
*

 lea      (a2),a0
 lea      ver_token(pc),a1
 jsr      scan_tok
 beq.b    rmi_lineloop             ; Token ungueltig
;move.l   a0,a0
 jsr      rinf_ul                  ; (sp) = major version
 beq      rmi_lineloop
 move.w   d0,(sp)
 cmpi.b   #'.',(a0)+
 bne.b    rmi_lineloop
 jsr      rinf_ul
 move.w   d0,2(sp)                 ; 4(sp) = minor version
 cmpi.l   #$50001,(sp)             ; Version neuer als 5.1 ?
 bcs.b    rmi_lineloop             ; nein, keine AES-Kennung
*/

*
* Die INF-Datei hat eine Versionsnummer >= 5.1.
* Wir suchen bis zur Sektion [aes]
*

 lea      aes_sec_token(pc),a1     ; '#[aes]'
 move.l   a2,a0                    ; ab hier suchen
 jsr      rinf_sec
 tst.l    d0                       ; Section gefunden ?
 bne.b    rmi_found                ; ja
 move.l   p_mgxinf,a0              ; nein, ab Anfang suchen
rmi_found:
 move.l   a0,a2                    ; ja, ab dort lesen

*
* Die Schleife ueber alle Zeilen
*

rmi_lineloop:
 move.l   a2,a4                    ; Zeilenanfang merken
 cmpi.b   #'#',(a2)
 bne      rmi_endsw
 addq.l   #1,a2

* Zeile gefunden, die mit '#' beginnt. 4 Buchstaben holen.

 moveq    #4-1,d1
rmi_4:
 lsl.l    #8,d0
 move.b   (a2)+,d0
 beq      rmi_set                  ; Fehler
 dbra     d1,rmi_4

 lea      inf_codes(pc),a0
rmi_code:
 move.l   (a0)+,d1
 beq      rmi_endsw                ; nicht gefunden
 move.w   (a0)+,d2                 ; Sprungdistanz holen
 cmp.l    d1,d0                    ; unser Code ?
 bne.b    rmi_code                 ; nein, weiter

* Code erkannt

 bsr      _skip_spc                ; Leerstellen und TABs ueberlesen
 jmp      inf_codes(pc,d2.w)       ; switch()

inf_codes:
 DC.L     '_ACC'                  ; Pfad fuer ACCs
 DC.W     rmi_c_acc-inf_codes
 DC.L     '_APP'                  ; Pfad fuer Autostart- PRGs (Multit.)
 DC.W     rmi_c_app-inf_codes
 DC.L     '_AUT'                  ; Autostart- Programm      (Overlay)
 DC.W     rmi_c_aut-inf_codes
 DC.L     '_BUF'                  ; Groesse des put/get- Puffers in hex
 DC.W     rmi_c_buf-inf_codes
 DC.L     '_CTR'                  ; Beginn der shel_put/get- Daten
 DC.W     rmi_c_ctr-inf_codes
 DC.L     '_DEV'                  ; VDI- Geraetenummer fuer AES
 DC.W     rmi_c_dev-inf_codes
 DC.L     '_ENV'                  ; Environment- String
 DC.W     rmi_c_env-inf_codes
 DC.L     '_FLG'                  ; Bitvektor fuer Flags
 DC.W     rmi_c_flg-inf_codes
 DC.L     '_MAG'                  ; erstellende OS- Version
 DC.W     rmi_c_mag-inf_codes
 DC.L     '_SCP'                  ; Scrapdir
 DC.W     rmi_c_scp-inf_codes
 DC.L     '_SHL'                  ; Default- Shell
 DC.W     rmi_c_shl-inf_codes
 DC.L     '_TRM'                  ; Pfad fuer VT52- Emulatorprogramm
 DC.W     rmi_c_trm-inf_codes
 DC.L     '_TSL'                  ; Werte fuer Timeslice- Verfahren
 DC.W     rmi_c_tsl-inf_codes
 DC.L     '_TXT'                  ; Hoehe des grossen Zeichensatzes
 DC.W     rmi_c_txt-inf_codes
 DC.L     '_WND'                  ; Anzahl der Fenster
 DC.W     rmi_c_wnd-inf_codes
 DC.L     '_FSL'                  ; Dateiauswahl-Parameter
 DC.W     rmi_c_fsl-inf_codes
 DC.L     '_OBS'                  ; Objektgroessen (Zeichenzelle)
 DC.W     rmi_c_obs-inf_codes
 DC.L     '_TXB'                  ; grosser Font
 DC.W     rmi_c_txb-inf_codes
 DC.L     '_TXS'                  ; kleiner Font
 DC.W     rmi_c_txs-inf_codes
 DC.L     '_INW'                  ; INFO Zeile im Fenster
 DC.W     rmi_c_inw-inf_codes
 DC.L     '_BKG'                  ; Hintergrundfarbe (ob_spec)
 DC.W     rmi_c_bkg-inf_codes
 DC.L     0


rmi_c_ctr:
 tst.b    (a2)
 beq      rmi_set                  ; keine put/get- Daten
 cmpi.b   #$d,(a2)+
 bne.b    rmi_c_ctr
 cmpi.b   #$a,(a2)+
 bne      rmi_err                  ; Fehler
 move.l   a2,a6                    ; Position der put/get- Daten
rmi_pgloop:
 tst.b    (a2)+
 bne.b    rmi_pgloop               ; Bis zum Dateiende sind put/get-Daten
 move.l   a2,d7
 sub.l    a6,d7                    ; Laenge der put/get- Daten
 bra      rmi_set


rmi_c_scp:
 lea      scrp_dir,a0
 bra      rmi_c_a


rmi_c_trm:
 lea      termprog,a0
 bra      rmi_c_a


rmi_c_shl:
 lea      shel_name,a0
 bra      rmi_c_a


rmi_c_acc:
 move.l   applx+4,a0
 lea      ap_cmd(a0),a0            ; ACC- Pfad: applx[1].ap_cmd
 bra.b    rmi_c_a


rmi_c_app:
 move.l   applx+4,a0
 lea      ap_tail(a0),a0           ; APP- Pfad: applx[1].ap_tail
 bra.b    rmi_c_a


rmi_c_aut:
 move.w   #1,ap_doex(a3)           ; starten
 move.w   #1,ap_isover(a3)         ; normal
 move.w   #1,ap_isgr(a3)           ; ACHTUNG: IMMER IM GRAFIKMODUS
 lea      ap_cmd(a3),a0
rmi_c_a:

 bsr      _copy_string             ; Bis Leerstelle uebernehmen
 bra      rmi_endsw


rmi_c_buf:
 move.l   a2,a0
 jsr      rinf_ul
 beq      rmi_err                  ; Fehler
 cmpi.w   #SHLBFLEN,d0
 bls      rmi_endsw
 cmpi.w   #$ffff,d0                ; ungueltig wg. inquiry mode
 beq      rmi_endsw
 move.w   d0,shel_buf_len
 bra      rmi_endsw

rmi_c_obs:
 pea      0
 pea      gr_hhbox
 pea      gr_hwbox
 pea      big_hchar
 pea      big_wchar
 bra.b    rmi_m_num

rmi_c_txb:
 pea      0
 pea      finfo_big+fontH
 pea      finfo_big+fontmono
 pea      finfo_big+fontID
 bra.b    rmi_m_num

rmi_c_txs:
 pea      0
 pea      finfo_sml+fontH
 pea      finfo_sml+fontmono
 pea      finfo_sml+fontID
 bra.b    rmi_m_num

rmi_c_inw:
 pea      0
 pea      finfo_inw+fontH
 pea      finfo_inw+fontmono
 pea      finfo_inw+fontID
 pea      inw_height
 bra.b    rmi_m_num

rmi_c_txt:
 pea      0
 pea      finfo_big+fontID
 pea      finfo_sml+fontH
 pea      finfo_big+fontH
 bra.b    rmi_m_num

rmi_c_tsl:
 pea      0
 pea      bdrop_timer              ; Zeitscheibendauer in <Ticks>
 pea      bdrop_timer+2            ; statt pe_slice zwischenzeitlich!
rmi_m_num:
 bsr      _skip_spc
 move.l   a2,a0
 jsr      rinf_ul
 move.l   a0,a2
 beq      rmi_m_err
 move.l   (sp)+,a1
 move.w   d0,(a1)
 tst.l    (sp)                     ; weitere Variable
 bne.b    rmi_m_num                ; ja
 addq.l   #4,sp
 bra      rmi_endsw
rmi_m_err:
 tst.l    (sp)+
 bne.b    rmi_m_err
 bra      rmi_err

rmi_c_bkg:
 lea      shelw_startpic+ob_spec+2,a1
 bra.b    rmi_num

rmi_c_flg:
 lea      look_flags,a1
 bra.b    rmi_num

rmi_c_dev:
 pea      0
 pea      dflt_xdv
 pea      vdi_device
 bra.b    rmi_m_num


rmi_c_wnd:
 lea      nwindows,a1
rmi_num:
 move.l   a1,-(sp)
 move.l   a2,a0
 jsr      rinf_ul
 move.l   (sp)+,a1
 beq      rmi_err                  ; Fehler
 move.w   d0,(a1)
 bra      rmi_endsw


rmi_c_fsl:
 move.l   a2,a0
 jsr      rinf_ul                  ; Flags (ignorieren)
 move.l   a0,a2
 bsr      _skip_spc
 lea      fslx_exts,a0
 bsr      _copy_line
; ersetze alle ';' durch '\0'
 lea      fslx_exts,a0
rmicfsl_loop:
 cmpa.l   #fslx_exts+254,a0
 bcc.b    rmicfsl_ende
 move.b   (a0)+,d0
 beq.b    rmicfsl_ende2
 cmpi.b   #';',d0
 bne.b    rmicfsl_loop
 clr.b    -1(a0)                   ; durch Nullbyte trennen
 bra.b    rmicfsl_loop
rmicfsl_ende:
 clr.b    (a0)+                    ; mit zwei Nullbyte abschliessen
rmicfsl_ende2:
 clr.b    (a0)
 bra      rmi_endsw


rmi_c_env:
 lea      0(a5,d6.l),a0
 move.l   a0,a1
 bsr      _copy_line               ; bis Zeilenende uebernehmen
 suba.l   a1,a0
 add.l    a0,d6
 addq.l   #1,d6                    ; Nullbyte mitzaehlen
;bra      rmi_endsw


rmi_c_mag:

* naechste Zeile
rmi_endsw:
 tst.b    (a2)
 beq      rmi_set
 cmpi.b   #$d,(a2)+
 bne.b    rmi_endsw
 tst.b    (a2)
 beq.b    rmi_err
 cmpi.b   #$a,(a2)+
 bne.b    rmi_err
 tst.b    (a2)
 bne      rmi_lineloop
 bra.b    rmi_set

*
* Fehler in der INF-Datei. Gib die fehlerhafte Zeile aus.
*

rmi_err2:
 addq.l   #2,sp                    ; Stackinhalt wegwerfen
rmi_err:
 moveq    #0,d0
 move.b   (a4)+,d0
 beq.b    rmi_err_ende
 cmpi.b   #$d,d0
 beq.b    rmi_err_ende
 cmpi.b   #$a,d0
 beq.b    rmi_err_ende
 bsr      bios_putch
 bra.b    rmi_err
rmi_err_ende:
 lea      inf_errs(pc),a0
 bsr      wait                     ; Fehlermeldung
 moveq    #0,d6                    ; kein Environment
 suba.l   a6,a6                    ; keine Daten

/* Wir haben alles eingelesen und legen nun die Puffer an */

rmi_set:
; zunaechst das Environment
 tst.l    d6
 beq.b    rmi_no_env
 clr.b    0(a5,d6.l)               ; nochmals mit Nullbyte abschliessen
 addq.l   #1,d6
 move.l   _basepage,a1
 move.l   $2c(a1),a0
 move.l   a5,$2c(a1)               ; Environment anmelden
;move.l   a0,a0
 jsr      mfree                    ; altes Environment freigeben
 addq.l   #1,d6
 bclr     #0,d6                    ; Auf gerade Adresse erweitern
rmi_no_env:
; dann die Fenster
 lea      nwindows,a1
 cmpi.w   #MAX_NWIND,(a1)
 bls.b    rmi_wnd_ok
 move.w   #MAX_NWIND,(a1)
rmi_wnd_ok:
 lea      0(a5,d6.l),a0            ; Environment ueberspringen
 moveq    #0,d0                    ; unsigned
 move.w   (a1),d0                  ; Anzahl Fenster
 add.w    d0,d0
 add.w    d0,d0                    ; *4 wg. (void *)
 move.l   a0,windx                 ; Zeiger auf Fenstertabelle
 move.l   a0,(a0)
 add.l    d0,(a0)                  ; Zeiger auf Fenster #0
 add.l    #w_tree,d0               ; fuer Fenster #0
 add.l    d0,d6                    ; Laenge der Fenstertabelle addieren
 add.l    d0,a0
; dann die WGRECTs
 move.l   a0,wgrects
 move.w   (a1),d0                  ; Anzahl Fenster
 mulu     #7,d0
 add.w    #10,d0                   ; 7 * nwindows + 10 (Erfahrungswert!)
 move.w   d0,(a0)                  ; Anzahl WGRECTs merken
 mulu     #12,d0                   ; * sizeof(WGRECT)
 add.l    d0,a0
 add.l    d0,d6
; dann den put/get- Puffer
 move.l   a0,shel_buf
 move.l   a6,d0
 beq.b    rmi_no_buf
 move.w   d7,d0
 addq.w   #1,d0                    ; Platz fuer Nullbyte
 move.l   a6,a1
;move.l   a0,a0
 jsr      vmemcpy
 bra.b    rmi_is_buf
rmi_no_buf:
 clr.b    (a0)                     ; put/get- Puffer leer
rmi_is_buf:
 moveq    #0,d0
 move.w   shel_buf_len,d0          ; Laenge des put/get- Puffers
 add.l    d6,d0                    ; + Laenge des Environments + Fenster
 move.l   d0,-(sp)
 move.l   a5,-(sp)
 move.l   #$4a0000,-(sp)
 trap     #1                       ; gemdos Mshrink
 lea      12(sp),sp

 lea      (xaes_area).l,a0
 cmpi.l   #'XAES',(a0)
 bne.b    rmi_nowarm
 clr.l    (a0)+                    ; "verwendet"
 move.w   (a0)+,vdi_device         ; gewuenschte Aufloesung holen
 move.w   (a0)+,d0                 ; Fonthoehe
 beq.b    rmi_nofnt

 move.w   d0,finfo_big+fontH       ; nur uebernehmen, wenn Groesse angegeben
rmi_nofnt:
 move.w   (a0),dflt_xdv            ; zusaetzlicher Falcon-Aufloesungs-Modus
rmi_nowarm:
 move.l   shel_buf,a0
 tst.b    (a0)                     ; Kontrollfelddaten leer ?
 bne.b    rmi_ctr_ok               ; nein, ok
 lea      inf_defdata(pc),a1
 move.w   #128,d0                  ; 128 Bytes + EOS
 jsr      vmemcpy                   ; Default- Kontrollfeld- Daten
rmi_ctr_ok:
 addq.l   #4,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6
 rts


**********************************************************************
*
* void alloc_screenbuf( void )
*

alloc_screenbuf:
 suba.l   a1,a1
 lea      scrbuf_mfdb,a0
 jsr      bitblk_to_mfdb
 move.w   work_out+2,d0
 addq.w   #1,d0                    ; Bildschirmhoehe in Pixeln
 move.w   work_out,d1
 addq.w   #1,d1                    ; Bildschirmbreite in Pixeln
 mulu     d1,d0                    ; Pixel fuer den Bildschirm
 move.w   nplanes,d1
 ext.l    d1
 jsr      _lmul
 lsr.l    #5,d0                    ; /8 (in Bytes) /4 (Viertel Bildschirm)
 cmpi.l   #16384,d0
 bcs.b    alsb_st
 move.l   d0,d1
 lsr.l    #1,d1
 add.l    d1,d0                    ; Faktor 1.5 fuer den TT
alsb_st:
 move.l   #$3400,d1
 cmp.l    d1,d0
 bcc.b    alsb_ok
 move.l   d1,d0                    ; mindestens 13k holen
alsb_ok:

* Sicherheitsabfrage fuer Alertboxen
* Maximale Groesse: horizontal:    2   (linker Rand des Icons)
*                             +  4   (Icon)
*                             +  2   (linker Rand)
*                             + 40   (Text)
*                             +  2   (rechter Rand)
*                             ----
*                               50   Zeichen
*
*                 vertikal:      1   (oberer Rand)
*                             +  5   (Text)
*                             +  1   (Rand ueber Buttons)
*                             +  1   (Buttons)
*                             +  1   (unterer Rand)
*                             ----
*                                9   Zeichen
*

 moveq    #50,d1
 mulu     big_wchar,d1             ; Pixelbreite der Alertbox
 addq.l   #6,d1                    ; OUTLINED
 moveq    #0,d2
 move.w   scr_w,d2                 ; unsigned int in unsigned long
 cmp.l    d2,d1
 bls.b    allsc_noclip
 move.l   d2,d1                    ; auf Bildschirmbreite clippen
allsc_noclip:
 lsr.l    #5,d1                    ; Auf Langworte umrechnen
 addq.l   #1,d1                    ; Rundung immer nach oben

 moveq    #9,d2
 mulu     big_hchar,d2             ; Pixelhoehe der Alertbox
 addq.l   #6,d2                    ; OUTLINED

 mulu     d1,d2                    ; benoetigte Langworte pro Plane
 mulu     nplanes,d2               ; benoetigte Langworte
 lsl.l    #2,d2                    ; benoetigte Bytes
 add.l    #256,d2                  ; Vertrauen ist gut

 cmp.l    d2,d0
 bcc.b    allsc_alloc
 move.l   d2,d0

allsc_alloc:
 move.l   d0,screenbuf_len
;move.l   d0,d0

;    IFNE SECURE2

; lea     dos_date+$4321,a0
; move.w  #SECURE2-$1234,d1
; add.w   #$1234,d1
; cmp.w   -$4321(a0),d1
; bcc.b   secure_ok
; subi.l  #5000,d0
; jsr     mmalloc                   ; holen und nicht benutzen
; move.l  #5000,d0                 ; Zeitbombe: nur 5k reservieren
; secure_ok:

;    ENDIF

 jsr      mmalloc
 move.l   d0,scrbuf_mfdb
 beq      fatal_err
 rts


**********************************************************************
*
* void inq_screenbuf(a0 = int **bufadr, d0 = long *len)
*

inq_screenbuf:
 move.l   scrbuf_mfdb,(a0)         ; Adresse
 move.l   screenbuf_len,(a1)       ; Laenge
 rts



**********************************************************************
**********************************************************************
*
* GEMDOS- Bibliothek
*

leerstring: DC.B     0
     EVEN

**********************************************************************
*
* void fsetdta(a0 = DTA *dtabuffer)
*

fsetdta:
 move.l   a0,-(sp)
 move.w   #$1a,-(sp)
 trap     #1
 addq.l   #6,sp
 rts


**********************************************************************
*
* long dsetdrv_path(a0 = char *path)
*
* Setzt Laufwerk und Pfad, wobei ein vorhandener Dateiname
* ignoriert wird.
*

dsetdrv_path:
 move.l   a5,-(sp)
 move.l   a0,a5
;move.l   a0,a0
 jsr      fn_name
 move.b   (a0),-(sp)               ; Byte retten
 move.l   a0,-(sp)                 ; Zeiger retten
 clr.b    (a0)                     ; Dateiname abspalten
 cmpi.b   #':',1(a5)
 bne.b    dp_nodrv
 move.b   (a5),d0
 subi.b   #'A',d0
 bcs.b    dp_nodrv
 ext.w    d0
 move.w   d0,-(sp)
 move.w   #$e,-(sp)
 trap     #1                       ; Dsetdrv
 addq.l   #4,sp
dp_nodrv:
 move.l   a5,-(sp)
 move.w   #$3b,-(sp)
 trap     #1                       ; Dsetpath
 addq.l   #6,sp
 move.l   (sp)+,a0                 ; Zeiger auf Dateinamen zurueck
 move.b   (sp)+,(a0)               ; Dateiname restaurieren
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* int chk_signals(a0 = PD *pd)
*
* Testet, ob Signale anliegen.
* Wenn ja, gibt zurueck:
*
*    d0        Signalnummer 1..31
*    a2        struct sigaction
*    a1        PROCDATA
*    a0        PD
*

chk_signals:
 move.l   p_procdata(a0),a1
 move.l   pr_sigpending(a1),d1
 move.l   pr_sigmask(a1),d0
 not.l    d0                       ; sigmask sind die gesperrten!
 and.l    d0,d1

 beq.b    chks_null                ; es liegen keine Signale an
 moveq    #0,d0                    ; Signalnummer
 lea      pr_sigdata(a1),a2
chks_sigloop:
 btst     d0,d1                    ; Signal da ?
 bne.b    chks_ende                ; ja!
 addq.l   #1,d0
 adda.w   #sa_sizeof,a2
 cmpi.w   #32,d0
 bcs.b    chks_sigloop
chks_null:
 moveq    #0,d0
chks_ende:
 rts


**********************************************************************
*
* void do_signals(a0 = PD *pd)
*
* Testet, ob der Haupt-Thread des Prozesses diesen gerade bearbeitet,
* oder ob er bereits wieder ein Pexec() bearbeitet. Im zweiten Fall
* kann das Signal hier noch nicht bearbeitet werden.
*
* Testet, ob Signale anliegen, und erstellt den Thread fuer den
* Signalhandler.
* Es wird immer nur maximal ein Thread erzeugt. Wenn sich der Thread
* beendet, muss er die Signalmaske/Bits neu abfragen.
*

do_signals:
 move.l   p_app(a0),d0             ; Haupt-Thread (APPL *)
 beq      do_sigs_ende             ; ist ungueltig ??!!??
 move.l   d0,a1
 cmpa.l   ap_pd(a1),a0             ; wird gerade bearbeitet ?
 bne      do_sigs_ende             ; nein, Prozess schlaeft schon.
 bsr.b    chk_signals              ; warten Signale ?
 beq      do_sigs_ende             ; es liegen keine Signale an

* Bearbeite Signal

 movem.l  d6/d7/a3/a4/a5/a6,-(sp)

* Bestimme aus dem PD die zustaendige APPL a6
* Dies ist der Hauptthread, wenn kein Signalhandler aktiv ist,
* sonst der aktive Signalhandler

 move.l   p_app(a0),a6             ; a6 = APPL *
 move.l   a6,d6                    ; d6 = Haupt-Thread
 move.l   ap_sigthr(a6),d1         ; wird ein Signal bearbeitet ?
 beq.b    dosig_nosigact           ; nein
 move.l   d1,a6                    ; a6 = aktiver Signalhandler
dosig_nosigact:
 move.l   a1,a4                    ; a4 = PROCDATA *
 move.l   d0,d7                    ; Signalnummer
 move.l   a2,a3                    ; struct sigaction

*
* Behandle Signal mit der Nummer <d7>
*

 move.l   (a3),d0
 beq.b    dosig_dflt               ; 0L: default action
 subq.l   #1,d0
 bne      do_sigs_action

* Sonderfall "Signal ignorieren"

dosig_igno:
 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)     ; Signal ist bearbeitet
 bra      do_sigs_ende2            ; 1L: Signal ignorieren

* default-Aktionen

dosig_dflt:
 move.w   d7,d0
 add.w    d0,d0
 move.w   dfltsig_tab(pc,d0.w),d0
 jmp      dfltsig_tab(pc,d0.w)

dfltsig_tab:
 DC.W     dosig_igno-dfltsig_tab             ;  0: SIGNULL
 DC.W     dosig_term-dfltsig_tab             ;  1: SIGHUP
 DC.W     dosig_term-dfltsig_tab             ;  2: SIGINT
 DC.W     dosig_term-dfltsig_tab             ;  3: SIGQUIT
 DC.W     dosig_term-dfltsig_tab             ;  4: SIGILL
 DC.W     dosig_term-dfltsig_tab             ;  5: SIGTRAP
 DC.W     dosig_term-dfltsig_tab             ;  6: SIGABRT
 DC.W     dosig_term-dfltsig_tab             ;  7: SIGPRIV
 DC.W     dosig_igno-dfltsig_tab             ;  8: SIGFPE
 DC.W     dosig_term-dfltsig_tab             ;  9: SIGKILL
 DC.W     dosig_term-dfltsig_tab             ; 10: SIGBUS
 DC.W     dosig_term-dfltsig_tab             ; 11: SIGSEGV
 DC.W     dosig_term-dfltsig_tab             ; 12: SIGSYS
 DC.W     dosig_term-dfltsig_tab             ; 13: SIGPIPE
 DC.W     dosig_term-dfltsig_tab             ; 14: SIGALRM
 DC.W     dosig_term-dfltsig_tab             ; 15: SIGTERM
 DC.W     dosig_term-dfltsig_tab             ; 16: SIGURG
 DC.W     dosig_stop-dfltsig_tab             ; 17: SIGSTOP
 DC.W     dosig_stop-dfltsig_tab             ; 18: SIGTSTP
 DC.W     dosig_cont-dfltsig_tab             ; 19: SIGCONT
 DC.W     dosig_igno-dfltsig_tab             ; 20: SIGCHLD
 DC.W     dosig_stop-dfltsig_tab             ; 21: SIGTTIN
 DC.W     dosig_stop-dfltsig_tab             ; 22: SIGTTOU
 DC.W     dosig_term-dfltsig_tab             ; 23: SIGIO
 DC.W     dosig_term-dfltsig_tab             ; 24: SIGXCPU
 DC.W     dosig_term-dfltsig_tab             ; 25: SIGXFSZ
 DC.W     dosig_term-dfltsig_tab             ; 26: SIGVTALRM
 DC.W     dosig_term-dfltsig_tab             ; 27: SIGPROF
 DC.W     dosig_igno-dfltsig_tab             ; 28: SIGWINCH
 DC.W     dosig_term-dfltsig_tab             ; 29: SIGUSR1
 DC.W     dosig_term-dfltsig_tab             ; 30: SIGUSR2
 DC.W     dosig_igno-dfltsig_tab             ; 31: das Signal gibt es nicht

* SIGSTOP / SIGTSTP
*
* alle Threads eines Prozesses anhalten

dosig_stop:
 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)     ; Signal ist bearbeitet
 move.l   ap_pd(a6),a0
 bsr      stop_pd_threads          ; alle Threads eines PD anhalten
 bra      do_sigs_ende2

* SIGCONT
*
* alle durch Signal angehaltenen Threads eines Prozesses wieder
* starten.

dosig_cont:
 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)     ; Signal ist bearbeitet
 move.l   ap_pd(a6),a0
 bsr      cont_pd_threads          ; alle Threads eines PD fortfuehren
 bra      do_sigs_ende2

*
* Fatales Signal: Hauptthread killen, andere folgen automatisch
* bei Pterm.
*

dosig_term:
 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)     ; Signal ist bearbeitet
 move.l   d6,a0                    ; Haupt-Thread !!
 bsr      kill_thread              ; Programm killen
 bra      do_sigs_ende2

*
* Benutzerfunktion ausfuehren. Wir muessen erst testen, ob der
* behandelnde Thread (Hauptthread oder aktiver Signalhandler)
* in einem kritischen Zustand ist.
*

do_sigs_action:
 tst.w    ap_critic(a6)            ; kritisch ?
 beq.b    dosig_doaction           ; nein, Aktion ausfuehren!

* Der behandelnde Thread ist kritisch. Wir muessen hier das Flag
* setzen, dass der der Thread bei Beendigung des kritischen
* Zustand seine Signale bearbeitet.

 bset     #2,ap_crit_act(a6)       ; Flag "Signale testen!"
 bra      do_sigs_ende2

* Der behandelnde Thread ist momentan nicht kritisch. Wir
* erstellen den neuen Thread fuer den Signalhandler.

dosig_doaction:
 cmpi.w   #NAPPS,appln
 bcc      do_sigs_err              ; alle APPL-Slots belegt

 move.l   #ap_stack,d0             ; sizeof(APPL)
 add.l    sust_len.w,d0            ; + Supervisor-Stack
 move.l   ap_pd(a6),a1             ; PD *
 move.l   p_mflags(a1),d1          ; Malloc-Flags
 jsr      Mxalloc
 beq      do_sigs_err              ; zuwenig Speicher, return(NULL)
 movea.l  d0,a5                    ; a5 = neue APPL

* Signal als bearbeitet setzen

 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)     ; Signal ist bearbeitet

* Signalmaske umsetzen

 move.l   pr_sigmask(a4),ap_oldsigmask(a5)   ; alte Signalmaske merken
 move.l   sa_sigextra(a3),d0
 bset.l   d7,d0                              ; laufendes Signal sperren!
 or.l     d0,pr_sigmask(a4)                  ; zusaetzliche Signale sperren

* Halte behandelnden Thread an (entferne aus ready bzw. supended)
* oder setze nur (ap_status = APSTAT_STOPPED), wenn aktuelle app

 move.l   a6,a0
 jsr      stp_thr

* Wir erstellen jetzt den neuen Thread fuer den Signalhandler
* der usp wird vererbt

 lea      auto_tail_s(pc),a1       ; Name ist "\0\0AUTO"
 move.l   ap_pd(a6),d1             ; Basepage
 lea      start_signal(pc),a2      ; Startcode
 move.l   sust_len.w,d0            ; Stacklaenge (WORD !!)
 move.l   a5,a0                    ; APPL *
 bsr      init_APPL

 move.w   ap_id(a6),d1             ; von
 move.w   ap_id(a5),d0             ; nach
 bsr      vt52_inherit             ; VT52-Fenster vererben

 move.l   a6,ap_sigthr(a5)         ; Vorgaenger eintragen (ggf. Haupt-Thread)
 move.l   d6,a0                    ; Haupt-Thread
 move.l   a5,ap_sigthr(a0)         ; aktiver Signalhandler

 move.l   usp,a1
 cmpa.l   act_appl,a6              ; sind wir selbst der Vorgaenger
 beq.b    dosig_self               ; ja, nimm unseren usp
 move.l   ap_ssp(a6),a1
 move.l   (a1),a1                  ; geretteter usp
dosig_self:
 move.l   ap_ssp(a5),a0            ; Systemstack des Signalhandlers
 move.l   a1,(a0)                  ; usp fuer Thread ist oberstes Stackelement
 move.l   d7,ap_tail(a5)           ; param ist Signalnummer
 move.l   sa_handler(a3),ap_cmd(a5)     ; proc
 move.w   #2,ap_type(a5)           ; Typ: Signalhandler

 jsr      appl_yield               ; hier legen wir uns ggf. schlafen
 bra.b    do_sigs_ende2            ; keine weiteren Threads testen

do_sigs_err:

* Wir koennen das Signal nicht bearbeiten, weil nicht genuegend
* Speicher frei ist.

 moveq    #1,d0
 lea      al_sigerr(pc),a0
 bsr      form_alert

do_sigs_ende2:
 movem.l  (sp)+,d6/d7/a6/a5/a4/a3
do_sigs_ende:
 rts


**********************************************************************
*
* LONG sigreturn( void )
*
* Fuer Psigreturn().
* Beendet alle (!) Signalhandler.
*

sigreturn:
 movem.l  a4/a5/a6,-(sp)
 move.l   act_appl,a5
 cmpi.w   #2,ap_type(a5)           ; bin ich Signalhandler ?
 bne      sigr_eaccdn              ; nein, Fehler
 move.l   a5,a4                    ; act_appl merken
 move.l   act_pd.l,a0
 move.l   p_app(a0),a6             ; Hauptthread, hier laufen wir weiter!
 move.w   sr,-(sp)
 ori.w    #$700,sr
 st       inaes

*
* Schleife ueber alle Signalhandler:
*

* Aufraeumen. Wir koennen hier nur end_mctrl und Semaphoren freigeben

sigr_loop:
 move.l   a5,a0
 bsr      _appl_kill_events        ; ausstehende EVENTs abraeumen
 move.l   a5,a0
 bsr      appl_end_mctrl
 move.l   a5,a0                    ; appl
 moveq    #SEM_FALL,d0             ; alle freigeben
 jsr      evnt_sem

* ggf. aus Liste act_appl entfernen

 cmpa.l   act_appl,a5
 bne.b    sigr_no_act
 move.l   ap_next(a5),act_appl
sigr_no_act:

* Struktur freigeben. Hier wird unser aktueller ssp freigegeben!
 
 move.l   a5,a0
 bsr      appl_kill_struct         ; alte APPL a5 aus applx austragen
 move.l   ap_pd(a5),a1
 move.l   a5,a0
 jsr      Mxfree                   ; alte APPL a5 freigeben

* naechster Signalhandler

 move.l   a5,a0                    ; ersten Signalhandler merken
 move.l   ap_sigthr(a5),a5
 cmpi.w   #2,ap_type(a5)           ; immer noch ein Signalhandler ?
 beq.b    sigr_loop                ; ja, weiter

*
* Jetzt sind alle Signalhandler entfernt.
* APPL a6 wird unser "Erbe" sein, hier laufen wir weiter
*

* alte Signalmaske restaurieren. a0 ist der erste Handler.

 move.l   act_pd.l,a1
 move.l   p_procdata(a1),a1
 move.l   ap_oldsigmask(a0),pr_sigmask(a1)

 move.l   a6,a0
 jsr      app2ready                ; READY machen
 move.l   a6,a0
 bsr      _appl_kill_events        ; ausstehende EVENTs abraeumen

 move.l   a6,a0
 bsr      appl_end_mctrl

 move.l   a6,a0                    ; neue APPL
 moveq    #SEM_FALL,d0             ; alle Semaphoren freigeben
 jsr      evnt_sem

* Wir kopieren den Stack um

 lea      ap_stack(a4),a1          ; Anfangsadresse unseres Stack
 add.l    sust_len.w,a1            ; Endadresse unseres Stack
 move.l   a1,d0
 sub.l    sp,d0                    ; - Akt.Adr => verbrauchter Stack
 move.l   sp,a1                    ; Quelladresse
 move.l   act_pd.l,a0
 move.l   p_ssp(a0),a0             ; ssp des Main Thread
 sub.l    d0,a0                    ; - verbrauchter Teil
 move.l   a0,-(sp)                 ; Ende des neuen Stacks
 jsr      vmemcpy                   ; Stack kopieren
 move.l   (sp),sp                  ; Stack umschalten

* Wir setzen einfach den act_appl um

 move.l   a6,a0
 lea      act_appl,a1
 jsr      rmv_lstelm               ; neue APPL a6 aus Liste act_appl entfernen
 move.l   act_appl,ap_next(a6)
 move.l   a6,act_appl              ; neue vorn wieder einsetzen
 clr.l    ap_sigthr(a6)            ; Signalbehandlung beendet

 sf       inaes
 move.w   (sp)+,sr

 moveq    #0,d0                    ; kein Fehler
sigr_ende:
 movem.l  (sp)+,a4/a5/a6
 rts
sigr_eaccdn:
 moveq    #EACCDN,d0
 bra.b    sigr_ende


**********************************************************************
*
* void wait_signals( void )
*
* wartet, bis ein Signal uns wieder aufweckt.
*

wait_signals:
 move.l   act_appl,a0              ; wir sind es, die warten
 move.b   #1,ap_stpsig(a0)         ; wir halten an (nicht wg. Signalhandler)
 jsr      stp_thr                  ; aus allen Listen entfernen
 jmp      appl_yield               ; warten
 

**********************************************************************
*
* int create_thread(a0 = (WORD)(*proc)(),
*                   d0 = LONG par,
*                   d1 = LONG stacklen,
*                   a1 = void *userstack)
*
* Rueckgabe 0, wenn Fehler
* sonst ap_id
*
* Erstellt einen Thread.
* a1 enthaelt den BEGINN (!) des Userstacks, d.h. der usp wird auf
* (a1+d1) gesetzt.
*

create_thread:
 movem.l  d6/d7/a3/a5/a6,-(sp)
 move.l   d0,d7
 move.l   d1,d6
 move.l   a0,a6
 move.l   a1,a3

 cmpi.w   #NAPPS,appln
 bcc      cthr_err                 ; alle APPL-Slots belegt

 move.l   #ap_stack,d0
 add.l    sust_len.w,d0
 jsr      smalloc
 beq      cthr_err                 ; zuwenig Speicher, return(NULL)
 movea.l  d0,a5

 lea      auto_tail_s(pc),a1       ; Name ist "\0\0AUTO"
 move.l   act_pd.l,d1                ; Basepage
 lea      start_thread(pc),a2      ; Startcode
 move.l   sust_len.w,d0            ; Stacklaenge (WORD !!)
 move.l   a5,a0                    ; APPL *
 bsr      init_APPL

 move.w   #1,ap_type(a5)           ; Typ: Thread

 move.l   ap_ssp(a5),a0            ; Systemstack
 move.l   a3,(a0)
 add.l    d6,(a0)                  ; usp fuer Thread ist oberstes Stackelement
 move.l   d7,ap_tail(a5)           ; param
 move.l   a3,ap_thr_usp(a5)        ; Beginn des usp, merken fuer Mfree()
 move.l   a6,ap_cmd(a5)            ; proc
 addq.w   #1,ap_isgr(a5)           ; isgr = 1 (default)
 move.w   ap_id(a5),d0
cthr_ende:
 movem.l  (sp)+,d6/d7/a3/a5/a6
 rts
cthr_err:
 moveq    #0,d0
 bra      la_ende


**********************************************************************
*
* d0/d1 load_process(a0 = char *path, a1 = char *tail,
*                   a2 = void *startcode, d0 = int mode,
*                   d1 = char *env_resp_pd)
*
* mode    0x0001         1: Mshrink durchfuehren   (ACC)
*                        0: Handles und Signale vererben (PRG)
*         0x0002         Programm <path> mit Pexec(3) laden
*         0x0004         PD und Environment: Owner setzen
*
*    ACCs:          Mode 7
*    Pexec 100:     Mode 6
*    Pexec 104:     Mode 0
*    Pexec 106:     Mode 4
*
* Rueckgabe 0, wenn Fehler, sonst ap_id
* d1 enthaelt den DOS-Fehlercode von Pexec()
*
* Laedt ein Programm bzw. verwendet eine uebergebene Basepage und
* erstellt eine neue Task.
* 
* Wird verwendet fuer das Starten von ACCs sowie fuer das parallele
* Starten von Programmen ueber Pexec(100/104/106) und P(v)fork().
*
* Fuer das Programm wird ein ordnungsgemaesses shel_write durchgefuehrt,
* damit es spaeter sich selbst und seine Ressourcen finden kann.
*

load_process:
 movem.l  d5/d6/d7/a3/a4/a5/a6,-(sp)
 move.l   a0,a6                    ; a6 = path
 move.l   a1,a4                    ; a4 = tail
 move.l   a2,d5                    ; d5 = startcode

 move.w   d0,d7                    ; d7 = mode
 move.l   d1,d6                    ; d6 = env bzw. (PD *)

 cmpi.w   #NAPPS,appln
 bcc      la_err2                  ; alle APPL-Slots belegt

 move.l   #ap_stack,d0
 add.l    sust_len.w,d0
 jsr      smalloc
 beq      la_err2                  ; zuwenig Speicher, return(NULL)
 movea.l  d0,a5                    ; a5 = (APPL *)

 move.l   d6,a3
 btst     #1,d7                    ; Programm laden ?
 beq.b    la_no_load               ; nein, statt env: Basepage

 move.w   d7,-(sp)                 ; Bit 0: minimaler Speicher
 move.l   #'xld3',-(sp)            ; magic
 move.l   d6,-(sp)                 ; Env
 move.l   a4,-(sp)                 ; tail
 move.l   a6,-(sp)                 ; Pfad
 move.l   #$4b0003,-(sp)           ; Pexec (EXE_LD)
 trap     #1
 adda.w   #$16,sp
 tst.l    d0                       ; Basepage
 ble      la_err                   ; Fehler beim Laden
 move.l   d0,a3                    ; a3 = Basepage

la_no_load:
 move.l   a3,a1
 move.l   a5,a0                    ; APPL
 jsr      Mchgown                  ; gehoert dem neuen Prozess !

*
* fuer PRG: Pexec(XXEXE_INIT, ...) ausfuehren
* jetzt auch fuer ACC
*         Damit wird ordentlich vererbt.
*         Pexec104: Mfork durchfuehren
*

 move.l   a6,-(sp)                 ; Prozessname oder NULL
 beq.b    la_x01_nn
 move.l   a6,a0
 jsr      fn_name
 move.l   a0,(sp)                  ; ggf. Pfad abspalten
la_x01_nn:
 move.l   act_pd.l,-(sp)             ; Von hier wird geerbt
 move.l   a3,-(sp)                 ; neuer Prozess
 clr.l    -(sp)
 move.w   #301,-(sp)               ; XXEXE_INIT
 btst     #2,d7                    ; owner aendern ?
 bne.b    la_ok_chown              ; ja, keine Aktion
 move.w   #401,(sp)                ; XXEXE_MINIT  (Speicher verdoppeln)
la_ok_chown:
 move.w   #$4b,-(sp)               ; Pexec
 trap     #1
 adda.w   #$14,sp

 move.l   a6,d0
 bne.b    la_is_procname           ; Name war angegeben
 move.l   p_procdata(a3),a0        ; neuer Prozess
 lea      pr_procname(a0),a6       ; dessen Prozessnamen verwenden!
la_is_procname:
 move.l   a6,a0
 jsr      fn_name
 move.l   a0,a1                    ; Name

 move.l   a3,d1                    ; Basepage
 move.l   d5,a2                    ; Startcode
 move.l   sust_len.w,d0            ; Stacklaenge (WORD !!)
 move.l   a5,a0                    ; APPL *
 bsr      init_APPL

 clr.l    -(sp)                    ; keine erweiterten Parameter
 move.l   a5,a2                    ; APPL
 move.l   a4,a1                    ; tail
 move.l   a6,a0                    ; cmd
 moveq    #0,d2                    ; isover = egal
 moveq    #1,d1                    ; isgr = TRUE
 moveq    #0,d0                    ; doex = false
 bsr      _shel_write              ; => ap_id
 addq.l   #4,sp
la_ende:
 movem.l  (sp)+,a3/a4/a5/a6/d7/d6/d5
 rts
la_err:
 move.l   d0,-(sp)

 move.l   a5,a0
 jsr      smfree                   ; APPL wieder freigeben
 move.l   (sp)+,d0
la_err2:
 move.l   d0,d1                    ; DOS-Fehlercode
 moveq    #0,d0
 bra.b    la_ende


**********************************************************************
*
* d0 = PD * exec_10x(d0 = int mode,
*                   a0 = char *path, a1 = char *tail, a2 = char *env)
*
* Fuer Pexec(100, 104, 106)
* Fuer P(v)fork(): mode = 104, path = NULL, env = -1, a1 = Basepage
*
* erstellt eine neue Task und vererbt das VT52-Fenster des Aufrufers.
*

exec_10x:
 move.l   a2,d1                         ; env
 moveq    #6,d2                         ; kein Mshrink, aber: load,chown
 cmpi.w   #100,d0
 beq.b    ex_1x_go
 moveq    #4,d2                         ; kein Mshrink, load, aber: chown
 move.l   a1,d1                         ; PD statt env
 lea      leerstring(pc),a1             ; leere AES-Kommandozeile

 cmpi.w   #106,d0

 beq.b    ex_1x_go
 moveq    #0,d2                         ; kein Mshrink, kein load, kein chown
ex_1x_go:
 move.w   d2,d0
 lea      start_parall_proc(pc),a2      ; Startcode
;move.l   a1,a1                         ; tail
;move.l   a0,a0                         ; path
 bsr      load_process

 tst.w    d0                            ; ap_id
 beq.b    ex100_err                     ; Fehler

 move.w   d0,-(sp)
 move.l   act_appl,a0
 move.w   ap_id(a0),d1                  ; src
;move.w   d0,d0                         ; dst
 bsr      vt52_inherit                  ; VT52-Fenster vererben
 move.w   (sp)+,d0

 lea      applx,a0
 add.w    d0,d0
 add.w    d0,d0
 move.l   0(a0,d0.w),a0                 ; ap_id -> APPL
 move.l   ap_pd(a0),d1                  ; Prozess

ex100_err:
 move.l   d1,d0
 rts


**********************************************************************
*
* int load_acc(a0 = char *path)
*
* Rueckgabe 0, wenn Fehler
* sonst ap_id
*
* Fuer das ACC wird ein ordnungsgemaesses shel_write durchgefuehrt, damit
* es spaeter sich selbst und seine Ressourcen finden kann.
*

load_acc:
 cmpi.w   #NACCS,no_of_menuregs    ; alle Zeilen ausgenutzt
 bcs.b    lac_ok1                  ; nein, auf jeden Fall noch Platz!

* Pruefen, ob freier Eintrag da ist

 lea      reg_apidx,a1
 moveq    #0,d0
 bra.b    lac_srch
lac_srchnxt:
 tst.w    (a1)+                    ; freigegebener Slot ?
 bmi.b    lac_ok1                  ; ja, OK
 addq.w   #1,d0                    ; ...betrachten
lac_srch:
 cmp.w    no_of_menuregs,d0
 bcs.b    lac_srchnxt
 moveq    #0,d0
 rts                               ; kein freigegebener Slot!

lac_ok1:
 moveq    #0,d1                    ; aktuelles Env
 moveq    #7,d0                    ; Mshrink/load/chown
 lea      start_acc(pc),a2         ; Startcode
 lea      auto_tail_s(pc),a1       ; tail ist "\0\0AUTO"
;move.l   a0,a0
 bra      load_process


**********************************************************************
*
* void load_all_slbs( void )
*

slb_token:     DC.B '#_SLB ',0
     EVEN

load_all_slbs:
 movem.l  d7/a6,-(sp)
 suba.w   #128+8,sp
 move.l   p_mgxinf,d0
 beq.b    lasl_ende
 lea      aes_sec_token(pc),a1     ; '#[aes]'
 move.l   d0,a0                    ; ab hier suchen
 jsr      rinf_sec
 beq.b    lasl_ende                ; section nicht gefunden
lasl_loop:
 lea      slb_token(pc),a1         ; "#_SLB "
;move.l   a0,a0
 jsr      rinf_tok
 beq.b    lasl_ende                ; keine (weiteren) Eintraege
* Zeile gefunden
 addq.l   #6,a0                    ; Token ueberspringen

 jsr      rinf_ul                  ; Dezimalzahl (ULONG) einlesen
 beq.b    lasl_next                ; Fehler
 move.l   d0,d7                    ; Versionsnummer fuer SLB

 move.l   #128,d0                  ; Pufferlaenge inkl. EOS
 move.l   sp,a1                    ; Puffer
;move.l   a0,a0
 jsr      rinf_path                ; Pfad einlesen
 tst.b    (sp)                     ; Pfad eingelesen?
 beq.b    lasl_next                ; nein, weiter
* Pfad eingelesen
 move.l   a0,a6                    ; a0 merken
 move.l   sp,a0
 pea      128(a0)                  ; Fuer Rueckgabe des Fkt.-Zeigers
 pea      128+4(a0)                ; Fuer Rueckgabe des Handles
 move.l   d7,-(sp)                 ; minimale Version
 clr.l    -(sp)                    ; kein Suchpfad
 move.l   a0,-(sp)                 ; Name
 gemdos   Slbopen
 adda.w   #22,sp
 move.l   a6,a0                    ; a0 zurueck
lasl_next:
;move.l   a0,a0
 jsr      rinf_nl
 bne.b    lasl_loop
lasl_ende:
 adda.w   #128+8,sp
 movem.l  (sp)+,d7/a6
 rts


**********************************************************************
*
* void load_all_accs( void )
*

acc_s:    DC.B "*.ACC",0
     EVEN

load_all_accs:
 move.l   a6,-(sp)
 suba.w   #$2c,sp                  ; sizeof(DTA)

/* Bootlaufwerk merken */

 jsr      dgetdrv
 move.b   d0,aes_bootdrv

 move.l   applx+4,a0               ; screnmgr
 lea      ap_cmd(a0),a0            ; Pfad fuer ACCs
 lea      acc_s(pc),a1
 bsr      add_name                 ; ggf. "\\" als Pfad setzen
 move.l   d1,a6                    ; Zeiger auf reinen Namen merken

 move.l   applx+4,a0               ; screnmgr
 lea      ap_cmd(a0),a0            ; Pfad fuer ACCs
 bsr      dsetdrv_path
 tst.l    d0
 bne      laac_ende                ; Pfad nicht vorhanden

 lea      (sp),a0
 bsr      fsetdta

 clr.w    -(sp)                    ; nur normale Dateien
 move.l   applx+4,a0               ; screnmgr
 pea      ap_cmd(a0)               ; "....\*.ACC"
 move.w   #$4e,-(sp)
 trap     #1                       ; gemdos Fsfirst
 addq.l   #8,sp
 bra.b    laac_test

laac_loop:
 cmpi.w   #8,appln
 bcc.b    laac_ende                ; schon 2+6 APPLs

; Dateinamen hinter den Pfad kopieren

 lea      $1e(sp),a1               ; char *fname (ohne Pfad)
 lea      (a6),a0
laac_cloop:
 move.b   (a1)+,(a0)+
 bne.b    laac_cloop

 move.l   applx+4,a0               ; screnmgr
 lea      ap_cmd(a0),a0            ; Pfad fuer ACCs
 bsr      load_acc                 ; Rueckgabewert vernachlaessigt

 move.w   #$4f,-(sp)
 trap     #1
 addq.l   #2,sp                    ; naechstes ACC

laac_test:
 tst.l    d0
 beq.b    laac_loop
laac_ende:
 adda.w   #$2c,sp
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* void load_all_apps( void )
*

auto_tail_s:
          DC.B 0,0,"AUTO",0,0,0,0
app1_s:   DC.B '*.APP',0
app2_s:   DC.B '*.PRG',0
 EVEN

load_all_apps:
 move.l   applx+4,a0               ; screnmgr
 lea      ap_tail(a0),a0           ; Pfad fuer APPs
laap_loop:
 tst.b    (a0)+
 bne.b    laap_loop
 subq.l   #1,a0
 move.l   a0,-(sp)                 ; Zeiger auf EOS merken
 lea      app1_s(pc),a1
 bsr.s    _load_all_apps           ; *.APP laden
 move.l   (sp)+,a0
 clr.b    (a0)                     ; EOS restaurieren
 lea      app2_s(pc),a1            ; *.PRG laden

_load_all_apps:
 link     a6,#-$2c

 move.l   applx+4,a0               ; screnmgr
 lea      ap_tail(a0),a0           ; Pfad fuer APPs
 tst.b    (a0)
 beq      lap_ende                 ; kein Pfad angegeben
;move.l   a1,a1
 bsr      add_name

 move.l   applx+4,a0               ; screnmgr
 lea      ap_tail(a0),a0
 bsr      dsetdrv_path
 tst.l    d0
 bne      lap_ende                 ; Pfad nicht vorhanden

 lea      -$2c(a6),a0
 bsr      fsetdta

 clr.w    -(sp)                    ; nur normale Dateien
 move.l   applx+4,a0               ; screnmgr
 pea      ap_tail(a0)
 move.w   #$4e,-(sp)
 trap     #1                       ; gemdos Fsfirst
 addq.l   #8,sp
 bra.b    lap_test

lap_loop:
 clr.l    -(sp)                    ; keine erweiterten Parameter
 lea      auto_tail_s(pc),a1       ; tail ist "\0\0AUTO"
 lea      -$e(a6),a0               ; char *fname (ohne Pfad)
 moveq    #1,d1                    ; isgr
 moveq    #1,d0                    ; doex
 bsr      ap_create
 addq.l   #4,sp

 move.w   #$4f,-(sp)
 trap     #1                       ; gemdos Fsnext
 addq.l   #2,sp                    ; naechstes APP

lap_test:
 tst.l    d0
 beq.b    lap_loop
lap_ende:
 unlk     a6
 rts


**********************************************************************
*
* void wait_but_released( void )
*

wbr_loop:
 jsr      appl_yield
wait_but_released:
 btst     #0,gr_mkmstate+1
 bne.b    wbr_loop
 rts


**********************************************************************
*
* void set_app( a0 = APPL *ap )
*
* Setzt neue Applikation fuer Menue und Desktophintergrund,
* wenn sie solche besitzt
*

set_app:
 tst.l    ap_menutree(a0)
 bgt      _set_app
 tst.l    ap_desktree(a0)
 bgt      _set_app
 rts


**********************************************************************
*
* void _set_app( a0 = APPL *ap )
*
* Setzt neue Applikation fuer Menue und Desktophintergrund.
*

_set_app:
 move.l   a0,d0                    ; APPL gueltig ?
 ble.b    _stap_ende               ; nein, NULL oder eingefroren
 cmpa.l   menu_app,a0              ; schon menuebesitzend ?
 beq.b    _stap_ende               ; ja, nichts tun
 cmpi.b   #APSTAT_ZOMBIE,ap_status(a0)
 beq.b    _stap_ende               ; Zombie
 move.l   a0,menu_app              ; Berechtigung fuers Aendern

 move.l   ap_menutree(a0),a1       ; Menue
 move.l   a0,-(sp)
;move.l   a0,a0                    ; APPL
 jsr      menu_on
 move.l   (sp),a0
 jsr      set_desktop
 move.l   (sp)+,a0
 moveq    #0,d0
 bsr      appl_unhide
_stap_ende:
 moveq    #0,d0
 rts


**********************************************************************
*
* void fsel_app( d0 = int parallel )
*
* Fuehrt einen Fileselect- Dialog und laedt ggf. eine Applikation nach.
*

BUTTON    SET  -2
ONAME     SET  BUTTON-14
PATH      SET  ONAME-128

fsel_app:
 link     a6,#PATH
 move.w   d0,-(sp)

fsap_again:
 lea      PATH(a6),a0
 move.l   #'*.PR',(a0)+
 move.l   #'G,*.',(a0)+
 move.l   #$41505000,(a0)
 clr.b    ONAME(a6)

 lea      fsel_ldp(pc),a0
 tst.w    (sp)                     ; parallel ?
 bne.b    fsap_par
 lea      fsel_ldo(pc),a0
fsap_par:
 pea      (a0)
 pea      BUTTON(a6)
 pea      ONAME(a6)
 pea      PATH(a6)
 move.l   gem_magics+$60,a0        ; fsel_exinput
 move.l   (a0),a0
 jsr      (a0)
 lea      16(sp),sp

 tst.w    BUTTON(a6)
 bne      fsap_load                ; "OK"
 tst.w    (sp)
 beq      fsap_again               ; "Abbruch" bei Overlay nicht erlaubt
 bra      fsap_ende                ; "Abbruch"

* Pfad und Programmname werden verbunden

fsap_load:
 lea      PATH(a6),a0
 jsr      fn_name
 lea      ONAME(a6),a1
fsap_loop2:
 move.b   (a1)+,(a0)+              ; Dateiname dahinterkopieren
 bne.b    fsap_loop2

* Pfad setzen

 lea      PATH(a6),a0
 bsr      dsetdrv_path

* Programm laden

 lea      leerstring(pc),a1        ; tail ist leer
 lea      PATH(a6),a0              ; path
 moveq    #100,d2                  ; parallel
 tst.w    (sp)
 bne.b    fsap_par2
 moveq    #1,d2                    ; normal
fsap_par2:
 moveq    #1,d1                    ; isgr
 moveq    #1,d0                    ; doex
 bsr      shel_write

 tst.w    d0
 bne.b    fsap_ende
 lea      PATH(a6),a0
 moveq    #ENSMEM,d0
 jsr      form_xerr                ; "zuwenig Speicher"
fsap_ende:
 addq.w   #2,sp
 unlk     a6
 rts


**********************************************************************
*
* void tidy_up( void )
*

tidy_up:
 clr.w    -(sp)
 move.w   #21,-(sp)
 trap     #14                      ; Cursconf(CURS_HIDE)
 addq.w   #4,sp
 bsr      reset_mouse
 tst.w    moff_cnt
 bge.b    tidu_ok
 clr.w    moff_cnt                 ; negative Zahlen nicht zulassen
tidu_ok:
 move.l   menutree,d0
 beq.b    td_no_menu
 move.l   d0,a0
 jsr      menu_draw
td_no_menu:
 lea      desk_g,a0
 jsr      wind0_draw
 lea      desk_g,a0
 jmp      send_all_redraws


**********************************************************************
*
* int any_app( void )
*

any_app:
 suba.l   a0,a0


**********************************************************************
*
* int make_best_main( a0 = APPL *this_not )
*

make_best_main:
 bsr      gbest_app
 bne.b    make_app_main
 moveq    #1,d0                    ; hat kein Menue/Hintergrund
 rts

**********************************************************************
*
* void make_app_main( a0 = APPL *ap )
*

make_app_main:
 move.l   a0,-(sp)
 jsr      top_my_window            ; sonst Fenster nach oben ...
 move.l   (sp),a0
 bsr      set_app                  ; ... Menue nach oben
 move.l   (sp)+,a0
 moveq    #0,d0
 bsr      appl_unhide              ; sichtbar machen
 jsr      all_untop                ; ... oberstes Fenster ggf. deaktivieren
 moveq    #0,d0
 rts


**********************************************************************
*
* int app_visible( a0 = APPL *ap )
*
* Rueckgabe 1, wenn Applikation Menue oder Hintergrund oder Fenster hat.
* veraendert d0/d1/a1/a2
*

app_visible:
 move.l   ap_menutree(a0),d0
 bgt.b    apv_ok                   ; Applikation hat Menue
 move.l   ap_desktree(a0),d0
 bgt.b    apv_ok                   ; Applikation hat Hintergrund
 move.l   windx,a2
 move.w   nwindows,d0
 subq.w   #1,d0
sapp_wloop:
 move.l   (a2)+,d1
 beq.b    apv_wnxt                 ; Fenster unbenutzt
 move.l   d1,a1
 btst     #WSTAT_OPENED_B,w_state+1(a1)      ; Fenster geoeffnet ?
 beq.b    apv_wnxt
 cmpa.l   w_owner(a1),a0
 bne.b    apv_wnxt
apv_ok:
 moveq    #1,d0
 rts
apv_wnxt:
 dbra     d0,sapp_wloop
 moveq    #0,d0                    ; nix gefunden

 rts


*********************************************************************
*
* aktive Applikation ausblenden
*

hide_keyb_app:
 move.l   keyb_app,d0
 ble.b    hka_end
 move.l   d0,a0
 move.l   a0,-(sp)
 moveq    #0,d0                    ; nur aktive ausblenden
 bsr      appl_hide
 move.l   (sp)+,a0                 ; die will ich gerade nicht
; andere APP kommt nach oben
 bsr.s    make_best_main
/*
 move.l   a0,-(sp)
 jsr      set_app
 move.l   (sp),a0
 jsr      all_untop
 move.l   (sp)+,a0
;move.l   a0,a0
 jsr      top_my_window
*/
hka_end:
 rts


*********************************************************************
*
* andere Applikationen ausblenden
*

hide_other_apps:
 move.l   keyb_app,a0
 move.w   #$00ff,d0                ; alle ausser a0
 jmp      appl_hide


*********************************************************************
*
* alle einblenden
*

unhide_all_apps:
 moveq    #-1,d0                   ; alle
 jmp      appl_unhide


**********************************************************************
*
* void cdecl ins_app_names( OBJECT *ob, int scrollpos,
*                             int nlines, char *apps)
*
* Callback fuer xfrm_popup()
* Die APP-Namen ins Menue einsetzen
*

up_s:     DC.B '  ',1,0
down_s:   DC.B '  ',2,0
     EVEN

ins_app_names:
 lea      4(sp),a2
 move.l   (a2)+,a0                 ; a0 = OBJECT *ob
 move.w   (a2)+,d0                 ; d0 = int scrollpos
 move.w   (a2)+,d1                 ; d1 = int nlines
 move.l   (a2),a1                  ; a1 = char *apps
 add.w    d0,a1
 moveq    #NPOPAPPS,d2
 move.l   a0,a2                    ; Baum merken
 tst.w    d0
 beq.b    insan_no_up
; Scrollpfeil nach oben eintragen
 move.l   #up_s,ob_spec+24(a2)     ; 1. Zeile: Scrollpfeil
 andi.w   #!CHECKED,ob_state+24(a2)
 lea      24(a0),a0                ; 1. Zeile ueberspringen
 addq.l   #1,a1
 subq.w   #1,d2
insan_no_up:
 subi.w   #NPOPAPPS,d1             ; so haeufig kann ich scrollen
 bmi.b    insan_start2             ; kann garnicht scrollen
 cmp.w    d1,d0                    ; max-scroll erreicht ?
 bcc.b    insan_start              ; ja, Namen zeichnen
; Scrollpfeil nach unten eintragen
 move.l   #down_s,ob_spec+(24*NPOPAPPS)(a2)  ; letzte. Zeile: Scrollpfeil
 andi.w   #!CHECKED,ob_state+(24*NPOPAPPS)(a2)
 subq.w   #1,d2
 bra.b    insan_start
insan_start2:
 addi.w   #NPOPAPPS,d1             ; Subtraktion rueckgaengig machen
 move.w   d1,d2                    ; nur tatsaechliche Anzahl bearbeiten
 bra.b    insan_start

insan_loop:
 lea      24(a0),a0                ; Wurzelobjekt ueberspringen
 moveq    #0,d0
 move.b   (a1)+,d0                 ; ap_id
 move.w   d0,a2
 add.w    a2,a2
 add.w    a2,a2
 move.l   applx(a2),a2
 andi.w   #!CHECKED,ob_state(a0)
 cmpa.l   mctrl_karett,a2          ; gerettete keyb_app (vor BEG_MCTRL)
 bne.b    sapp_noact
 ori.w    #CHECKED,ob_state(a0)    ; aktive Applikation mit Haekchen
sapp_noact:
 lea      ap_dummy1(a2),a2         ; 2 Leerzeichen vor dem Namen
 move.l   a2,ob_spec(a0)
insan_start:
 dbra     d2,insan_loop
insan_ende:
 rts


**********************************************************************
*
* void select_app( d0 = {int x; int y} )
*
* Gibt das Popup- Menue fuer den Wechsel der aktuellen Applikation aus,
* fuehrt den Dialog und schaltet die menuebesitzende Applikation um.
*
* (sp)    Platz fuer String "xxx Bytes frei"
* 24(sp)  Platz fuer String "xxx ausblenden"
* 48(sp)  NAPPS+2 * char als EOS-terminierte Liste der zu zeigenden
*         APPs
*

select_app:
 movem.l  a3/a4/a5/d3/d4/d5/d6/d7,-(sp)
 suba.w   #48+NAPPS,sp


 lea      popup_tmp,a5
 move.l   d0,d5                    ; x,y
; Objektbaum ins RAM
 move.l   #(NPOPAPPS+9)*24,d0      ; 16+9 OBJECTS
 lea      sapp_tree(pc),a1
 move.l   a5,a0
 jsr      vmemcpy

; bestimme die Liste der anzuzeigenden APPs
; d4 = Anzahl

 moveq    #0,d4
 lea      applx,a4
 lea      48(sp),a3
sapp_getapploop:
 move.l   (a4)+,d0
 ble.b    sapp_nextapp             ; Slot leer
 move.l   d0,a0
 tst.w    ap_type(a0)              ; Haupt-Thread ?
 bne.b    sapp_nextapp             ; nein
 bsr      app_visible
 beq      sapp_nextapp             ; APP ist unsichtbar, veraend. nicht a0
 move.b   ap_id+1(a0),(a3)+        ; ap_id merken
 move.w   #'  ',ap_dummy2(a0)      ; APPL de-markieren
 addq.w   #1,d4
sapp_nextapp:
 cmpa.w   #applx+4*NAPPS,a4
 bcs.b    sapp_getapploop

; Hoehe des Menues bestimmen: d6

 moveq    #NPOPAPPS,d6             ; max. 16 in einem Stueck anzeigen
 cmp.w    d6,d4
 bcc.b    sapp_showmax
 move.w   d4,d6                    ; Anzahl auswaehlbarer APPs
sapp_showmax:

; Objektbaum zusammenbauen

 moveq    #0,d7                    ; erstes Objekt
 moveq    #0,d3                    ; Zaehler fuer y-Pos
 move.l   a5,a3
sapp_oploop:
 lea      24(a3),a3                ; naechstes OBJECT
 addq.w   #1,d7
 cmpi.w   #NPOPAPPS+1,d7
 bcc.b    sapp_add                 ; letzte Eintraege (aufraeumen,laden)
 cmp.w    d4,d7                    ; schon alle APPs ?
 bhi.b    sapp_next                ; ja

sapp_add:
 move.w   d3,ob_y(a3)
 addq.w   #1,d3                    ; Anzahl waehlbarer APPs

 move.w   d7,d1
 moveq    #0,d0
 move.l   a5,a0
 jsr      objc_add

 move.w   d7,d0
 move.l   a5,a0
 jsr      rsrc_obfix
sapp_next:
 cmpi.w   #NPOPAPPS+8,d7
 bcs.b    sapp_oploop

 move.l   keyb_app,d0
 beq.b    sapp_noa
 lea      24(sp),a0
 move.l   a0,-6*24+ob_spec(a3)     ; String fuer "xxxxxxxx ausblenden"
 clr.w    -6*24+ob_state(a3)
 move.l   d0,a1
 lea      ap_name(a1),a1
 move.w   #'  ',(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)+
 lea      aktaus_s+10(pc),a1
sapp_cpyt:
 move.b   (a1)+,(a0)+
 bne.b    sapp_cpyt
sapp_noa:
 moveq    #-2,d0                   ; testen
 bsr      appl_unhide
 beq.b    sapp_nou
 clr.w    -4*24+ob_state(a3)
sapp_nou:
 move.l   sp,ob_spec(a3)           ; String des letzten Objekts

 clr.w    -(sp)                    ; nur ST-RAM
 pea      -1
 move.w   #$44,-(sp)               ; gemdos Mxalloc
 trap     #1
 move.l   d0,d7                    ; Anzahl Bytes ST-RAM
 addq.w   #1,6(sp)                 ; nur TT-RAM
 trap     #1
 addq.l   #8,sp
 add.l    d7,d0

 lsr.l    #8,d0
 lsr.l    #2,d0                    ; /1024
 move.l   d0,-(sp)
 move.l   sp,-(sp)
 pea      bytes_s(pc)
 move.l   ob_spec(a3),-(sp)
 jsr      _sprintf
 lea      16(sp),sp

 move.w   d6,ob_height(a5)         ; Hoehe von Objekt 0
 add.w    #8,ob_height(a5)
 moveq    #0,d0
 move.l   a5,a0
 jsr      rsrc_obfix

*
* Jetzt ist der Objektbaum fertig.
*

 clr.w    -(sp)                    ; Platz fuer Rueckgabe des Scrollwerts
 move.w   #1,-(sp)                 ; festen Puffer verwenden
 pea      2(sp)                    ; Scrollwert
 move.w   d4,-(sp)                 ; Anzahl der Zeilen
 pea      48+10(sp)                ; Parameter zur Routine (a1)
 lea      ins_app_names(pc),a1     ; Routine zum Initial. der Objekte
 move.w   d6,d2                    ; letztes Scroll-Objekt
 moveq    #1,d1                    ; erstes Scroll-Objekt
 move.l   d5,d0                    ; x/y- Position der Maus
 move.l   a5,a0                    ; OBJECT *
 jsr      xfrm_popup               ; Menue ausfuehren
 adda.w   #12,sp
 move.w   (sp)+,d1                 ; letzte Scrollposition

 tst.w    d0
 ble      sapp_end                 ; Dialog abgebrochen

 cmpi.w   #NPOPAPPS,d0
 bhi.b    sapp_raum                ; "aufraeumen"

 subq.w   #1,d0                    ; in Index umrechnen
 add.w    d1,d0                    ; + scrollpos
 moveq    #0,d1
 move.b   48(sp,d0.w),d1           ; ap_id
 add.w    d1,d1
 add.w    d1,d1
 lea      applx,a0
 move.l   0(a0,d1.w),a0
 btst     #1,gr_mkmstate+1         ; rechte Maustaste gedrueckt ?
 bne.b    sapp_setmenu             ; ja, nur Menue umschalten
 btst     #3,gr_mkkstate+1         ; ALT gedrueckt ?
 bne.b    sapp_setmenu             ; ja, nur Menue umschalten
 bsr      make_app_main
 bra.b    sapp_end
sapp_setmenu:
 bsr      _set_app
 bra.b    sapp_end

sapp_raum:
 cmpi.w   #NPOPAPPS+2,d0
 bne.b    sapp_c1
 bsr      hide_keyb_app
 bra      sapp_end
sapp_c1:
 cmpi.w   #NPOPAPPS+3,d0
 bne.b    sapp_c2
 bsr      hide_other_apps
 bra      sapp_end
sapp_c2:
 cmpi.w   #NPOPAPPS+4,d0
 bne.b    sapp_c3
 bsr      unhide_all_apps
 bra      sapp_end
sapp_c3:
 cmpi.w   #NPOPAPPS+6,d0
 bhi.b    sapp_lade
 bsr      tidy_up
 bra.b    sapp_end
sapp_lade:
 moveq    #1,d0                    ; parallel
 bsr      fsel_app
sapp_end:
 adda.w   #48+NAPPS,sp
 movem.l  (sp)+,d3/d4/d5/d6/d7/a5/a4/a3
 rts


     IF   COUNTRY=COUNTRY_DE
aktaus_s: DC.B '  -------- ausblenden',0
allaus_s: DC.B '  andere   ausblenden',0
allein_s: DC.B '  alle     einblenden',0
strich_s: DC.B '-----------------------',0
aufr_s:   DC.B '  aufr',$84,'umen     ^',7,'Clr',0
laden_s:  DC.B '  Programm starten...',0
bytes_s:  DC.B '  %L kBytes frei',0
/*
aktaus_s: DC.B '  -------- ausblenden ^',7,'-',0
allaus_s: DC.B '  andere   ausblenden ^',7,',',0
allein_s: DC.B '  alle     einblenden ^',7,'<',0
strich_s: DC.B '-----------------------',0
aufr_s:   DC.B '  aufr',$84,'umen  ^',7,'Clr',0
laden_s:  DC.B '  Programm starten...',0
bytes_s:  DC.B '  %L kBytes frei',0
*/


fsel_ldp: DC.B 'Programm parallel ausf',$81,'hren:',0
fsel_ldo: DC.B 'Programm ausf',$81,'hren:',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
aktaus_s: DC.B '  xxxxxxxx hide',0
allaus_s: DC.B '  others   hide',0
allein_s: DC.B '  all      unhide',0
strich_s: DC.B '-----------------------',0
aufr_s:   DC.B '  tidy up',0
laden_s:  DC.B '  start program...',0
bytes_s:  DC.B '  %L kBytes free',0
fsel_ldp: DC.B 'run program simultaneously:',0
fsel_ldo: DC.B 'run program:',0
     ENDIF
     IF   COUNTRY=COUNTRY_FR
aktaus_s: DC.B '  -------- -> masquer',0
allaus_s: DC.B '  Autres   -> masquer',0
allein_s: DC.B '  R',$82,'afficher tout    ',0
strich_s: DC.B '-----------------------',0
aufr_s:   DC.B "  Ranger l'",$82,"cran",0
laden_s:  DC.B '  Lancer programme...',0
bytes_s:  DC.B '  %L kBytes libres',0
fsel_ldp: DC.B 'Ex',$82,'cuter programme en parall',$8A,'le:',0
fsel_ldo: DC.B 'Ex',$82,'cuter programme:',0
     ENDIF
     EVEN

sapp_tree:
 DC.W     -1,-1,-1                 ; Hintergrund
 DC.W     20,0,0
 DC.L     $ff1100
 DC.W     0,0,23,16

     IFNE NPOPAPPS-16
FAIL
     ENDIF

     REPT 16                       ; soviele APPs sind sichtbar

 DC.W     -1,-1,-1                 ; erster String
 DC.W     28,1,0                   ; G_STRING, SELECTABLE
 DC.L     0
 DC.W     0,0,23,1

     ENDM

 DC.W     -1,-1,-1
 DC.W     28,0,8                   ; NORMAL,DISABLED
 DC.L     strich_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,1,8                   ; SELECTABLE,DISABLED
 DC.L     aktaus_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,1,0                   ; SELECTABLE
 DC.L     allaus_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,1,8                   ; SELECTABLE,DISABLED
 DC.L     allein_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,0,8                   ; NORMAL,DISABLED
 DC.L     strich_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     G_SHORTCUT,1,0           ; SELECTABLE
 DC.L     aufr_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,1,0                   ; SELECTABLE
 DC.L     laden_s
 DC.W     0,0,23,1

 DC.W     -1,-1,-1
 DC.W     28,0,8                   ; NORMAL,DISABLED
 DC.L     0                        ; muss auf den Zahlstring zeigen
 DC.W     0,0,23,1


**********************************************************************
*
* void alt_ctrl_tab( void )
*

alt_ctrl_tab:
 movem.l  a5/d6/d7,-(sp)
 suba.w   #12,sp
 st       hotkey_sem
 lea      popup_tmp,a5
 lea      act_dialog(pc),a1
 move.l   a5,a0
 jsr      vmemcpy

 moveq    #0,d0
 move.l   a5,a0
 jsr      rsrc_obfix

 moveq    #1,d0
 move.l   a5,a0
 jsr      rsrc_obfix

; Dialogbox zentrieren
 lea      (sp),a1
 move.l   a5,a0
 jsr      _form_center

 lea      8(sp),a2                 ; FlyDials
 lea      (sp),a1                  ; Zeiger auf biggrect
;suba.l   a0,a0                    ; Zeiger auf littlegrect
 moveq    #0,d0                    ; FMD_START
 bsr      __fm_xdial

 lea      (sp),a0
 jsr      set_clip_grect           ; Clipping auf Box

 moveq    #0,d7                    ; per Default APP #0
 move.l   keyb_app,d0
 beq.b    act_nokb
 move.l   d0,a0
 move.w   ap_id(a0),d7
act_nokb:
 bsr      beg_mctrl

act_loop:
 move.w   d7,d6
act_loop2:
 addq.w   #1,d7
 cmpi.w   #NAPPS,d7
 bcs.b    act_ok1
 cmp.w    d6,d7
 beq      act_ende                 ; einmal durch, nix gefunden
 cmpi.w   #NAPPS,d7
 bcs.b    act_ok1
 moveq    #0,d7
act_ok1:
 lea      applx,a0
 add.w    d7,a0
 add.w    d7,a0
 add.w    d7,a0
 add.w    d7,a0
 move.l   (a0),d0
 ble.b    act_loop2
 move.l   d0,a0
 bsr      app_visible
 beq.b    act_loop2

 clr.b    ap_dummy2(a0)            ; Hide-Flags loeschen
 lea      ap_name(a0),a0
 move.l   a0,popup_tmp+24+ob_spec

 moveq    #8,d1
 moveq    #0,d0
 move.l   a5,a0                    ; tree
 jsr      _objc_draw               ; Box ausgeben

act_loop3:
 jsr      appl_yield
 move.l   act_appl,a0
 tst.w    ap_kbcnt(a0)
 beq.b    act_nix
;move.l   a0,a0
 bsr      read_keybuf
 cmpi.b   #9,d0
 beq      act_loop
act_nix:

 move.w   gr_mkkstate,d0
 cmpi.w   #K_CTRL+K_ALT,d0
 beq      act_loop3
act_ende:

 lea      8(sp),a2                 ; FlyDials
 lea      (sp),a1
;suba.l   a0,a0
 moveq    #3,d0                    ; FMD_FINISH
 bsr      __fm_xdial

 bsr      end_mctrl

 lea      applx,a0
 add.w    d7,d7
 add.w    d7,d7
 move.l   0(a0,d7.w),d0
 ble.b    act_err
 move.l   d0,a0
 bsr      make_app_main
act_err:
 sf       hotkey_sem
 adda.w   #12,sp
 movem.l  (sp)+,a5/d6/d7
 rts

act_dialog:
 DC.W     -1,1,1         ; ob_head, ob_next, ob_tail
 DC.W     G_BOX          ; ob_type
 DC.W     FL3DBAK        ; ob_flags
 DC.W     OUTLINED       ; ob_state
 DC.L     $21100         ; ob_spec
 DC.W     0,0,18,3       ; ob_x, ob_y, ob_width, ob_height

 DC.W     0,-1,-1        ; ob_head, ob_next, ob_tail

 DC.W     G_STRING       ; ob_type
 DC.W     LASTOB         ; ob_flags

 DC.W     0              ; ob_state
 DC.L     0              ; ob_spec
 DC.W     5,1,8,1        ; ob_x, ob_y, ob_width, ob_height


**********************************************************************
*
* void screnmgr_button(a0 = {x, y, bstate, kstate, key, nclicks} )
*
* Der Screenmanager hat eine Nachricht erhalten, dass die linke
* Maustaste betaetigt wurde.
*

screnmgr_button:
 move.l   a6,-(sp)
 move.l   a0,a6
 tst.w    scmgr_wakeup             ; beruecksichtigen ?
 bne.b    scbt_wakeup              ; ja
 move.w   2(a6),d1                 ; d1 = y
 move.w   (a6),d0                  ; d0 = x
 cmp.w    menubar_grect+g_h,d1     ; y <= Hoehe des Menuebalkens ?
 bhi.b    scbt_wind
*
* Mausklick innerhalb der Menueleiste
*
 tst.l    menutree                 ; ist ueberhaupt ein Menue angemeldet ?
 beq.b    scbt_select              ; nein, APP selektieren
     IF   MACOS_SUPPORT
 move.l   menutree,a0
 cmpi.w   #G_IBOX,24+ob_type(a0)
 beq.b    scbt_select              ; Mac-Menue ignorieren
     ENDIF
 lea      menu_grect,a0
;move.w   d1,d1                    ; y
;move.w   d0,d0                    ; x
 bsr      xy_in_grect              ; Ist der Mauszeiger im empfindl. Bereich ?
 bne      scbt_ende                ; ja, Ende
scbt_select:
 move.l   (a6),d0
 bsr      select_app
 bra.b    scbt_ende
*
* Mausklick unterhalb der Menueleiste
*
scbt_wind:
;move.w   d1,d1                    ; y
;move.w   d0,d0                    ; x
 jsr      wind_find
 tst.w    d0                       ; d0 = Windowhandle unter (x,y)
 ble.b    scbt_ende                ; Hintergrund oder ungueltig
 move.l   a6,a0                    ; x,y,bstate,kstate,key,nclicks
;move.w   d0,d0                    ; Handle
 jsr      wind_was_clicked
scbt_ende:
 move.l   (sp)+,a6
 rts
scbt_wakeup:
 subq.w   #1,scmgr_wakeup          ; Hide- Zaehler dekrementieren
 bra      scbt_ende                ; Ende


**********************************************************************
*
* void screnmgr_mouse(int x, int y)
*
* Der Screenmanager hat eine Nachricht erhalten, dass das Menue (?)
* beruehrt wurde.
*

screnmgr_mouse:
 tst.l    menutree                 ; ist ein Menue angemeldet ?
 beq      scmm_ende2               ; nein, Ende
     IF   MACOS_SUPPORT
 move.l   menutree,a0
 cmpi.w   #G_IBOX,24+ob_type(a0)
 beq      scmm_ende2               ; Mac-Menue ignorieren
     ENDIF
 lea      menu_grect,a0
 move.w   6(sp),d1
 move.w   4(sp),d0
 bsr      xy_in_grect              ; Ist der Mauszeiger im empfindl. Bereich ?
 beq      scmm_ende2               ; nein, Ende

 move.l   d7,-(sp)
 clr.w    -(sp)                    ; WORD pmenu
 move.l   menutree,-(sp)           ; OBJECT *tree
 clr.l    -(sp)                    ; int menu_obj
                                   ; int title
 lea      (sp),a0                  ; Titel,Eintrag,Baum,Menue-Parent
 move.l   menu_app,a1
 jsr      do_menu
 tst.w    d0                       ; Eintrag angewaehlt ?
 beq      scmm_waitrelease         ; nein, auf Maustaste loslassen warten

 move.l   menu_app,a0
 move.w   ap_id(a0),d7
 moveq    #MN_SELECTED,d0

 move.w   (sp),d2                  ; Menue
 cmpi.w   #3,d2                    ; Titelobjekt 3 (ACC- Menue) ?
 bne.b    scmm_send                ; nein

 move.l   menutree,a0
 move.w   ob_tail(a0),d1           ; rechter Teil (Menues)
 muls     #24,d1
 move.w   ob_head(a0,d1.l),d1      ; erstes Menue
 addq.w   #3,d1                    ; Titel/ueber.../--- ueberspringen
 sub.w    2(sp),d1                 ; - Eintrag
 neg.w    d1                       ; Eintrag - erstes Menue
 blt.b    scmm_send                ; "ueber..." oder "----"

 tst.w    no_of_menuregs           ; gibt es angemeldete ACCs
 beq.b    scmm_send                ; nein, Nachricht an Menueinhaber

 move.w   d1,2(sp)                 ; register- Nummer
 movea.w  d1,a0
 adda.w   a0,a0
 adda.l   #reg_apidx,a0
 move.w   (a0),d7                  ; zugehoerige ap_id
* Im Fall der Nachricht an ein ACC macht SCRENMGR das menu_tnormal()
 move.w   #1,-(sp)                 ; wenn DISABLED, nichts tun
 move.w   #1,-(sp)                 ; neu zeichnen, wenn aktives Menue
 moveq    #0,d2                    ; deaktivieren (deselektieren)
 moveq    #1,d1                    ; SELECTED
 moveq    #3,d0                    ; objnr
 move.l   menutree,a0              ; tree
 jsr      menu_modify
 addq.w   #4,sp
 move.w   2(sp),d2                 ; Patch: Menuenummer in buf[3] und buf[4]
 moveq    #AC_OPEN,d0

 tst.w    d7
 bmi.b    scmm_ende                ; ap_id ungueltig (unregistered ACC)

 btst     #2,gr_mkkstate+1         ; K_CTRL
 beq.b    scmm_do_send
 moveq    #SM_M_SPECIAL,d0         ; m[0] Nachrichtencode
 moveq    #0,d2                    ; m[3] = 0
 lea      2(sp),a0
 move.l   #'MAGX',(a0)+            ; buf[4,5]
 move.w   #SMC_TERMINATE,(a0)+     ; buf[6] = subfn
 move.w   d7,(a0)                  ; buf[7] = ap_id
 moveq    #1,d7                    ; dst_apid = 1 (SCRENMGR selbst!)

scmm_send:
 tst.w    d7
 bmi.b    scmm_ende                ; ap_id ungueltig (unregistered ACC)

scmm_do_send:
 lea      2(sp),a0
;move.w   d2,d2                    ; m[3] Objektnummer des Titels
 move.w   d7,d1                    ;      dst_apid
;move.w   d0,d0                    ; m[0] Nachrichtencode
 jsr      send_msg

scmm_waitrelease:
 bsr      wait_but_released
scmm_ende:
 lea      10(sp),sp
 move.l   (sp)+,d7
scmm_ende2:
 rts



**********************************************************************
*
* void _set_topwind_app(a0 = APPL *ap, a1 = GRECT *g)
*
* <g> ist WORKXYWH des obersten Fensters, das <ap> gehoert
*

_set_topwind_app:
 move.l   a5,-(sp)
 move.l   a0,a5                    ; a5 ist neue Applikation
;move.l   a1,a1
 lea      button_grect,a0          ; GRECT nach button_grect kopieren
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)
 move.l   a5,a0
 bsr      set_mouse_app            ; <ap> bekommt jetzt die Mausklicks
 clr.l    topwind_app
 tst.w    topwhdl
 bmi.b    _sta_notop               ; es gibt kein aktives Fenster
 move.l   a5,topwind_app

_sta_notop:
 move.w   gr_mkmy,d1
 move.w   gr_mkmx,d0
 move.l   a5,a0
 bsr      send_mouse

 moveq    #1,d1
 move.w   gr_mkmstate,d0
 move.l   a5,a0
 bsr      send_click

 move.l   a5,keyb_app      ; <ap> bekommt jetzt die Tastencodes
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void screnmgr( void )
*
* DER SCREEN- MANAGER (APPLIKATION 1)
*

screnmgr:
 suba.w   #16+12,sp                ; Platz fuer 6 ints und 8 ints

 lea      scmgr_mm,a1
 clr.w    (a1)+
 lea      menubar_grect,a0
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)

* Endlosschleife
scrmg_mainloop:
 bsr      set_topwind_app          ; Applikation, der oberstes Fenster
                                   ;  gehoert, bekommt Tasten und Klicks
 pea      (sp)                     ; Platz fuer Rueckgabewerte
 pea      12+4(sp)                 ; Messagepuffer: 12(sp)
 move.l   #$2ff01,-(sp)            ; clicks=2,mask=$ff,bstate=1(linke Taste gedrueckt)
 clr.l    -(sp)                    ; kein Timer
 clr.l    -(sp)                    ; Dummy
 pea      scmgr_mm                 ; MGRECT *mm1
 move.w   #EV_KEY+EV_BUT+EV_MG1+EV_MSG,-(sp)

     IF   MACOS_SUPPORT
 move.l   menutree,d0
 beq.b    scrmg_mennor
 move.l   d0,a0
 cmpi.w   #G_IBOX,24+ob_type(a0)
 bne.b    scrmg_mennor
 bclr.b   #EVB_MG1,1(sp)           ; Mac-Menue ignorieren
scrmg_mennor:
     ENDIF

 btst     #2,(config_status+2).w     ; Bit 10
 beq.b    scrmg_m1
 move.w   #EV_KEY+EV_BUT+EV_MSG,(sp)
scrmg_m1:
 jsr      _evnt_multi
 lea      26(sp),sp
 move.w   d0,d7                    ; eingetretene Ereignisse

 bsr      update_1

 btst     #EVB_MSG,d7
 beq      scrmg_nomsg
 lea      12(sp),a0                ; mbuf
 cmpi.w   #SM_M_SPECIAL,(a0)+      ; mbuf[0]
 bne      scrmg_nomsg
 addq.l   #4,a0                    ; Sender/Laenge ignorieren
 tst.w    (a0)+
 bne      scrmg_nomsg              ; mbuf[3] muss 0 sein
 cmpi.l   #'MAGX',(a0)+            ; mbuf[4],[5]
 bne      scrmg_nomsg

* switch( mbuf[6] )

 move.w   (a0)+,d0
 cmpi.w   #8,d0
 bhi      scrmg_nomsg              ; ungueltig
 move.w   (a0),d1                  ; ap_id
 cmpi.w   #NAPPS,d1
 bcc      scrmg_nomsg              ; ungueltig
 lea      applx,a1
 add.w    d1,d1
 add.w    d1,d1
 add.w    d1,a1
 move.l   (a1),d1                  ; APPL *
 bclr     #31,d1
 move.l   d1,a0                    ; a0 = APPL *
 add.w    d0,d0
 move.w   scrmg_switch(pc,d0.w),d0
 tst.l    (a1)                     ; mit gesetztem EQ/MI
 jmp      scrmg_switch(pc,d0.w)

scrmg_switch:
 DC.W     scrmg_0-scrmg_switch     ; SMC_TIDY_UP
 DC.W     scrmg_1-scrmg_switch     ; SMC_TERMINATE
 DC.W     scrmg_2-scrmg_switch     ; SMC_SWITCH
 DC.W     scrmg_3-scrmg_switch     ; SMC_FREEZE
 DC.W     scrmg_4-scrmg_switch     ; SMC_UNFREEZE
 DC.W     scrmg_5-scrmg_switch
 DC.W     scrmg_6-scrmg_switch
 DC.W     scrmg_7-scrmg_switch
 DC.W     scrmg_8-scrmg_switch

*
* mbuf[6] = 0 (SMC_TIDY_UP): Aufraeumen
*

scrmg_0:
 bsr      tidy_up
 bra      scrmg_nomsg

*
* mbuf[6] = 1 (SMC_TERMINATE): Entfernen
*

scrmg_1:
 beq      scrmg_nomsg              ; APPL ungueltig
 cmpi.w   #1,ap_id(a0)             ; Bin ich selbst ?
 beq      scrmg_nomsg              ; ja, nicht loeschen
 move.l   a0,d6
 tst.l    (a1)                     ; APPL *
 bgt.b    scrmg_d1                 ; nicht eingefroren
 move.l   d6,a0
 st       inaes
 bsr      appl_unfreeze            ; auftauen, Taskwechsel verhindern
                                   ; APP ist jetzt schon "ready"
 sf       inaes
scrmg_d1:
 move.l   d6,a0
 bsr      kill_thread
 bra      scrmg_nomsg

*
* mbuf[6] = 2 (SMC_SWITCH): umschalten
*

scrmg_2:
 ble      scrmg_nomsg              ; ungueltig
;move.l   a0,a0
 bsr      set_app
 jsr      all_untop
 bra      scrmg_nomsg

*
* mbuf[6] = 3 (SMC_FREEZE): freeze
*

scrmg_3:
 ble      scrmg_nomsg              ; ungueltig oder schon gefroren
;move.l   a0,a0
 bsr      appl_freeze
 bra      scrmg_nomsg

*
* mbuf[6] = 4 (SMC_UNFREEZE): unfreeze
*

scrmg_4:
 bge      scrmg_nomsg              ; ungueltig oder nicht gefroren
 cmpi.b   #APSTAT_ZOMBIE,ap_status(a0)
 beq      scrmg_nomsg              ; zombie
;move.l   a0,a0
 bsr      appl_unfreeze
 bra      scrmg_nomsg

*
* mbuf[6] = 5: umschalten
*

scrmg_5:
 bsr      alt_ctrl_tab
 bra      scrmg_nomsg

*
* mbuf[6] = 6: Alle einblenden
*

scrmg_6:
 bsr      unhide_all_apps

 bra      scrmg_nomsg

*
* mbuf[6] = 7: Andere ausblenden
*

scrmg_7:
 bsr      hide_other_apps
 bra      scrmg_nomsg

*
* mbuf[6] = 8: Aktuelle ausblenden
*

scrmg_8:
 bsr      hide_keyb_app
 bra      scrmg_nomsg


*
* ENDCASE
*

scrmg_nomsg:
 btst     #EVB_BUT,d7
 beq.b    scrmg_nobut
* Mausknopfereignis
 lea      (sp),a0                  ; x/y/bstate/kstate/key/nclicks
 bsr      screnmgr_button

scrmg_nobut:
* Mausereignis (Menue beruehrt)
 move.l   act_appl,a0
 bsr      set_mouse_app            ; !!
 btst     #2,(config_status+2).w     ; Bit 10
 beq.b    scrmg_noclick            ; nein, normale Funktion
 btst     #EVB_BUT,d7              ; linke Maustaste gedrueckt ?
 beq.b    scrmg_next               ; nein, keine Aktion
; bsr     wait_but_released        ; ja, auf Loslassen warten
 bset     #2,d7
scrmg_noclick:
 btst     #2,d7
 beq.b    scrmg_next
 move.l   (sp),-(sp)
 bsr      screnmgr_mouse
 addq.l   #4,sp
scrmg_next:
 bsr      update_0
 bra      scrmg_mainloop


**********************************************************************
*
* void appl_getinfo( d0 = int mode, a0 = int data[5] )
*
* Nach Spezifikation von MultiTOS implementiert.
*

appl_getinfo:
 clr.w    (a0)
 cmpi.w   #14,d0
 bhi.b    apgi_err                 ; Fehler
 addq.w   #1,(a0)+                 ; kein Fehler
 cmpi.w   #2,d0                    ; Unterfunktion 0 oder 1?
 bcc.b    apgi_weiter

; Unterfunktion 0 oder 1 (Zeichensaetze)
; Sonderbehandlung fuer unwillige Programme

 move.l   act_appl,a1
 btst     #0,ap_flags+3(a1)
 beq.b    apgi_weiter
 tst.w    d0
 bne.b    apgi_1
 move.w   finfo_sys+fontH,(a0)+
 bra.b    apgi_01
apgi_1:
 move.w   finfo_sml+fontH,(a0)+
apgi_01:
 move.w   finfo_sys+fontID,(a0)+
 clr.l    (a0)                     ; Systemfont, Wort 3 = 0
 rts

; normale Funktion

apgi_weiter:
 moveq    #3,d1                    ; 4 Durchlaeufe
 lsl.w    d1,d0                    ; * 8 fuer Tabellenzugriff
 lea      apgi_tab(pc,d0.w),a1
apgi_loop:
 move.w   (a1)+,d0                 ; Wort holen
 bge.b    apgi_ok                  ; nicht indirekt
 bclr     #15,d0
 move.w   d0,a2
 move.w   (a2),d0                  ; indirekt
apgi_ok:
 move.w   d0,(a0)+                 ; erstes Wort
 dbra     d1,apgi_loop
apgi_err:
 rts

apgi_tab:
* Tabelle fuer Unterfunktion 0 (normaler AES-Font)
 DC.W     $8000+finfo_big+fontH    ; grosse Hoehe
 DC.W     $8000+finfo_big+fontID   ; Font-ID
 DC.W     $8000+isfsm_big          ; 0=Systemfont 1=FSM(??)
 DC.W     0
* Tabelle fuer Unterfunktion 1 (kleiner AES-Font)
 DC.W     $8000+finfo_sml+fontH    ; kleine Hoehe
 DC.W     $8000+finfo_sml+fontID   ; Font-ID
 DC.W     $8000+isfsm_sml          ; 0=Systemfont 1=FSM(??)
 DC.W     0
* Tabelle fuer Unterfunktion 2 (Aufloesung)
 DC.W     $8000+vdi_device         ; VDI- Geraetenummer
 DC.W     16                       ; 16 Farben
 DC.W     1                        ; Farbicons vorhanden
 DC.W     1                        ; Neues Ressource-Format vorhanden
* Tabelle fuer Unterfunktion 3 (national)
 DC.W     COUNTRY                  ; Sprache des AES
 DC.W     0
 DC.W     0
 DC.W     0
* Tabelle fuer Unterfunktion 4 (allgemein)
 DC.W     1    ; praeemptives Multitasking
 DC.W     1    ; appl_find() konvertiert ap_id <-> MiNT id
 DC.W     1    ; appl_search() vorhanden
 DC.W     1    ; rsrc_rcfix() vorhanden
* Tabelle fuer Unterfunktion 5 (allgemein)
 DC.W     0    ; objc_xfind() NICHT vorhanden
 DC.W     0    ; reserviert
 DC.W     1    ; menu_click() aus GEM/3 vorhanden
 DC.W     1    ; shel_wdef/rdef vorhanden
* Tabelle fuer Unterfunktion 6 (allgemein)
 DC.W     1    ; appl_read(-1) vorhanden
 DC.W     1    ; shel_get(-1) vorhanden
 DC.W     1    ; menu_bar(-1) vorhanden
 DC.W     1    ; menu_bar(MENU_INSTL) vorhanden
* Tabelle fuer Unterfunktion 7
 DC.W     %0000000000011111   ; 0: WDIALOG-Bibliothek vorhanden
                              ; 1: SCROLLBOX-Bibliothek vorhanden
                              ; 2: FONTSEL-Bibliothek vorhanden
                              ; 3: FSLX-Bibliothek vorhanden
                              ; 4: PDIALOG-Bibliothek vorhanden
 DC.W     0
 DC.W     0
 DC.W     0
* Tabelle fuer Unterfunktion 8 (Maus)
 DC.W     1    ; graf_mouse(258..260) vorhanden
 DC.W     1    ; Mausform ist applikationslokal
 DC.W     0
 DC.W     0
* Tabelle fuer Unterfunktion 9 (Menue)
 DC.W     1    ; Submenues
 DC.W     1    ; MultiTOS- Popups
 DC.W     1    ; scrollbare Menues
 DC.W     1    ; erweiterte MN_SELECTED in Wort 5/6/7
* Tabelle fuer Unterfunktion 10 (shel_write)
 DC.B     %00010001 ; Bit 8 von (doex & 0xff00) unterstuetzt (Psetlimit)
                    ; Bit 12 von (doex & 0xff00): erweiterte Flags
 DC.B     1         ; gueltige Werte fuer doex: 0 oder 1
                    ;  Modus 0/1/4/5/9/10 unterstuetzt.
 DC.W     1         ; doex = 0 storniert vorherige shel_write()s
 DC.W     1         ; doex = 1 startet Programm nach Beendigung des aktuellen
 DC.W     0         ; ARGV- Uebergabe NICHT vorhanden
* Tabelle fuer Unterfunktion 11 (Fenster)
 DC.W     %0000000111111011   ; 0: erweitertes WF_TOP
                              ; 1: wind_get(WF_NEWDESK)
                              ; 2: kein WF_COLOR
                              ; 3: WF_DCOLOR
                              ; 4: WF_OWNER
                              ; 5: WF_BEVENT
                              ; 6: WF_BOTTOM
                              ; 7: WF_ICONIFY
                              ; 8: WF_UNICONIFY
 DC.W     0
 DC.W     %0000000000001011   ; 0: Button fuer Iconifier

                              ; 1: Button fuer Bottomer
                              ; 2: Bottomer ueber Shift-Click
                              ; 3: Hot close Box
 DC.W     1                   ; wind_update() check_and_set vorhanden
* Tabelle fuer Unterfunktion 12 (Nachrichten)
 DC.W     %0000001111111110   ; 0: WM_NEWTOP nicht vorhanden
                              ; 1: WM_UNTOPPED vorhanden
                              ; 2: WM_ONTOP vorhanden
                              ; 3: AP_TERM vorhanden
                              ; 4: shutdown vorhanden (Aufloesungswechsel ??)
                              ; 5: CH_EXIT wird verschickt
                              ; 6: WM_BOTTOM wird verschickt
                              ; 7: WM_ICONIFY wird verschickt
                              ; 8: WM_UNICONIFY wird verschickt
                              ; 9: WM_ALLICONIFY wird verschickt
 DC.W     0
 DC.W     %0000000000000001   ; 0: WM_ICONIFY liefert Koordinaten
 DC.W     0
* Tabelle fuer Unterfunktion 13 (OBJECTs)
 DC.W     $8000+enable_3d     ; 3D-Objekte ggf. ueber ob_flags
 DC.W     $8000+enable_3d     ; objc_sysvar ggf. vorhanden
 DC.W     0                   ; nur Systemfonts in TEDINFO
 DC.W     %0000000000001111   ; 0: G_SWBUTTON vorhanden
                              ; 1: G_POPUP vorhanden
                              ; 2: WHITEBAK steuert Unterstriche und Buttons
                              ; 3: G_SHORTCUT vorhanden
* Tabelle fuer Unterfunktion 14 (Formulare)
 DC.W     1    ; Flydials vorhanden
 DC.W     1    ; Mag!X Tastaturtabellen in form_xdo vorhanden
 DC.W     1    ; form_xdo gibt letzte Cursorposition zurueck
 DC.W     0



**********************************************************************
*
* void appl_search( d0 = smode, a0 = sname, a1 = sout, a2 = nxtmark )
*
* Nach Spezifikation von MultiTOS implementiert. Speichert die
* gelesene ap_id in *nxtmark fuer next.
* Achtung: MultiTOS liefert 10 als typ von NEWDESK, das wird hier
*          ebenfalls so gehandhabt.
*

appl_search:
 move.l   a6,-(sp)
 moveq    #0,d1                    ; ab hier suchen
 subq.w   #1,d0
 bcs.b    aps_first
 beq.b    aps_next
 move.l   applx,a6                 ; APPL #0
 subq.w   #1,d0
 beq.b    aps_found                ; Unterfunktion 2: Name der Shell
                                   ;   (ich nehme einfach app #0)
aps_err:
 clr.b    (a0)                     ; leerer Name
 clr.w    (a1)                     ; Fehler
 bra      aps_ende
aps_next:
 move.w   (a2),d1                  ; letzte gefundene ap_id
 addq.w   #1,d1                    ; hier weitersuchen
aps_first:
 lea      applx,a6
 add.w    d1,d1
 add.w    d1,d1
 add.w    d1,a6                    ; *4 wegen Wortzugriff
aps_loop:
 cmpa.l   #applx+4*NAPPS,a6
 bcc.b    aps_err
 move.l   (a6)+,d0
 ble.b    aps_loop                 ; leer oder eingefroren
 move.l   d0,a6
 move.w   ap_id(a6),(a2)           ; fuer search next merken
aps_found:
 move.w   #1,(a1)+                 ; Rueckgabe: OK
 moveq    #1,d1                    ; "system process"
 move.l   ap_pd(a6),d0             ; PD
 beq      aps_type                 ; PD ungueltig (SCRENMGR)
 move.l   d0,a2
 moveq    #4,d1                    ; "accessory"
 tst.l    p_parent(a2)
 beq.b    aps_type                 ; Parent ungueltig (APPL)
 moveq    #2,d1                    ; "application"
 cmpi.l   #'MAGX',ap_name(a6)
 bne.b    aps_type
 cmpi.l   #'DESK',ap_name+4(a6)
 bne.b    aps_type
 moveq    #10,d1                   ; MAGXDESK ist Typ 10
aps_type:
 move.w   d1,(a1)+
 move.w   ap_id(a6),(a1)
 moveq    #8-1,d0
 lea      ap_name(a6),a2
aps_cloop:
 move.b   (a2)+,(a0)+
 dbra     d0,aps_cloop
 clr.b    (a0)
aps_ende:
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* APPL *_appl_find(a0 = char *s)
*
* gibt ggf. NULL zurueck
*

_appl_find:
 movem.l  a5/a4,-(sp)
 move.l   a0,a4                    ; Name
 lea      applx,a5
 moveq    #NAPPS-1,d2
_apf_loop:
 move.l   (a5)+,d0                 ; wird ggf. Rueckgabewert
 ble.b    _apf_next

 move.l   d0,a0                    ; APPL *
 move.l   a4,a1                    ; char *s

 lea      ap_name(a0),a2
 moveq    #8-1,d1                  ; 8 Bytes vergleichen
_apm_loop:
 cmp.b    (a2)+,(a1)+
 dbne     d1,_apm_loop
 bne.b    _apf_next                ; ungleich
 tst.b    (a1)                     ; Vergleichsstring hat 8 Zeichen ?
 beq.b    _apf_ende                ; gefunden!
_apf_next:
 dbra     d2,_apf_loop
 moveq    #0,d0                    ; NULL, nicht gefunden
_apf_ende:
 movem.l  (sp)+,a5/a4
 rts


**********************************************************************
*
* void set_apname(a0 = APPL *ap, a1 = char *name)
*
* Wandelt in Grossbuchstaben um
*

set_apname:
 lea      ap_name(a0),a2
 move.l   #'    ',(a2)
 move.l   #'    ',4(a2)            ; als 8 Leerstellen setzen
 moveq    #8-1,d1                  ; max. 8 Zeichen
stu_loop:
 move.b   (a1)+,d0
 beq.b    stu_ende
 cmpi.b   #' ',d0
 beq.b    stu_loop
 cmpi.b   #'.',d0
 beq.b    stu_ende
 jsr      toupper
 move.b   d0,(a2)+
 dbra     d1,stu_loop

stu_ende:
 rts


**********************************************************************
*
* wait_n_clicks(d0 = long n)
*

wait_n_clicks:
 tst.l    d0
 beq.b    wnc_ende
 add.l    timer_cnt,d0
wnc_loop:
 cmp.l    timer_cnt,d0
 bcc.b    wnc_loop
wnc_ende:
 rts


**********************************************************************
*
* void aes_dispatcher(a0 = AESPB *pb)
*
* a1 = int  contrl[]
* a2 = int  global[]
* a3 = int  intin[]
* a4 = int  intout[]
* a5 = long addrin[]
* a6 = long addrout[]
*
* Darf alle Register ausser d3..d7 benutzen, da sie sowieso gerettet
* wurden
*

aes_dispatcher:
 movem.l  (a0),a1/a2/a3/a4/a5/a6

;move.l   (a0)+,a1                 ; contrl
;move.l   (a0)+,a2                 ; global
;move.l   (a0)+,a3                 ; intin
;move.l   (a0)+,a4                 ; intout
;move.l   (a0)+,a5                 ; addrin
;move.l   (a0),a6                  ; addrout

 move.w   (a1),d0                  ; opcode
 cmp.w    fn_rellen,d0
 bcc.b    dsp_absjmp
 add.w    d0,d0
 move.w   aesfn_tab(pc,d0.w),d0
 jmp      aesfn_tab(pc,d0.w)
dsp_absjmp:
 sub.w    fn_rellen,d0
 cmp.w    fn_abslen,d0
 bcc      dsp_error
 move.l   a0,d1                    ; a0 retten
 add.w    d0,d0
 add.w    d0,d0                    ; d0*4 fuer LONG-Zugriff
 move.l   fn_abstab,a0
 move.l   0(a0,d0.w),-(sp)
 move.l   d1,a0                    ; a0 zurueck
 rts                               ; Sprung ueber absolute Tabelle

aesfn_tab:
 DC.W     dsp_sys_set-aesfn_tab         ; 0            ab 4.10.97 (V5.20)
 DC.W     dsp_error-aesfn_tab           ; 1
 DC.W     dsp_error-aesfn_tab           ; 2
 DC.W     dsp_error-aesfn_tab           ; 3
 DC.W     dsp_error-aesfn_tab           ; 4
 DC.W     dsp_error-aesfn_tab           ; 5
 DC.W     dsp_error-aesfn_tab           ; 6
 DC.W     dsp_error-aesfn_tab           ; 7
 DC.W     dsp_error-aesfn_tab           ; 8
 DC.W     dsp_error-aesfn_tab           ; 9
 DC.W     dsp_appl_init-aesfn_tab       ; 10
 DC.W     dsp_appl_read-aesfn_tab       ; 11
 DC.W     dsp_appl_write-aesfn_tab      ; 12
 DC.W     dsp_appl_find-aesfn_tab       ; 13
 DC.W     dsp_appl_tplay-aesfn_tab      ; 14
 DC.W     dsp_appl_trecord-aesfn_tab    ; 15
 DC.W     dsp_appl_bvset-aesfn_tab      ; 16           (!)
 DC.W     dsp_appl_yield-aesfn_tab      ; 17           (!)
 DC.W     dsp_appl_search-aesfn_tab     ; 18           (MultiTOS)
 DC.W     dsp_appl_exit-aesfn_tab       ; 19
 DC.W     dsp_evnt_keybd-aesfn_tab      ; 20
 DC.W     dsp_evnt_button-aesfn_tab     ; 21
 DC.W     dsp_evnt_mouse-aesfn_tab      ; 22
 DC.W     dsp_evnt_mesag-aesfn_tab      ; 23
 DC.W     dsp_evnt_timer-aesfn_tab      ; 24
 DC.W     dsp_evnt_multi-aesfn_tab      ; 25
 DC.W     dsp_evnt_dclicks-aesfn_tab    ; 26
 DC.W     dsp_error-aesfn_tab           ; 27
 DC.W     dsp_error-aesfn_tab           ; 28
 DC.W     dsp_error-aesfn_tab           ; 29
 DC.W     dsp_menu_bar-aesfn_tab        ; 30
 DC.W     dsp_menu_icheck-aesfn_tab     ; 31
 DC.W     dsp_menu_ienable-aesfn_tab    ; 32
 DC.W     dsp_menu_tnormal-aesfn_tab    ; 33
 DC.W     dsp_menu_text-aesfn_tab       ; 34
 DC.W     dsp_menu_register-aesfn_tab   ; 35
 DC.W     dsp_menu_unregister-aesfn_tab ; 36           (!)       menu_popup
 DC.W     dsp_menu_click-aesfn_tab      ; 37           (! GEM/3) menu_attach
 DC.W     dsp_menu_istart-aesfn_tab     ; 38
 DC.W     dsp_menu_settings-aesfn_tab   ; 39
 DC.W     dsp_objc_add-aesfn_tab        ; 40
 DC.W     dsp_objc_delete-aesfn_tab     ; 41
 DC.W     dsp_objc_draw-aesfn_tab       ; 42
 DC.W     dsp_objc_find-aesfn_tab       ; 43
 DC.W     dsp_objc_offset-aesfn_tab     ; 44
 DC.W     dsp_objc_order-aesfn_tab      ; 45
 DC.W     dsp_objc_edit-aesfn_tab       ; 46
 DC.W     dsp_objc_change-aesfn_tab     ; 47
 DC.W     dsp_objc_sysvar-aesfn_tab     ; 48
 DC.W     dsp_error-aesfn_tab           ; 49
 DC.W     dsp_form_do-aesfn_tab         ; 50 form_xdo (!!!)
 DC.W     dsp_form_dial-aesfn_tab       ; 51 form_xdial (!!!)
 DC.W     dsp_form_alert-aesfn_tab      ; 52
 DC.W     dsp_form_error-aesfn_tab      ; 53
 DC.W     dsp_form_center-aesfn_tab     ; 54
 DC.W     dsp_form_keybd-aesfn_tab      ; 55
 DC.W     dsp_form_button-aesfn_tab     ; 56
 DC.W     dsp_error-aesfn_tab           ; 57
 DC.W     dsp_error-aesfn_tab           ; 58
 DC.W     dsp_error-aesfn_tab           ; 59
 DC.W     dsp_objc_wdraw-aesfn_tab      ; 60 ab 11.12.96
 DC.W     dsp_objc_wchange-aesfn_tab    ; 61 ab 11.12.96
 DC.W     dsp_graf_wwatchbox-aesfn_tab  ; 62 ab 11.12.96
 DC.W     dsp_form_wbutton-aesfn_tab    ; 63 ab 11.12.96
 DC.W     dsp_form_wkeybd-aesfn_tab     ; 64 ab 12.02.97
 DC.W     dsp_objc_wedit-aesfn_tab      ; 65 ab 19.02.97
 DC.W     dsp_error-aesfn_tab           ; 66
 DC.W     dsp_error-aesfn_tab           ; 67
 DC.W     dsp_error-aesfn_tab           ; 68
 DC.W     dsp_error-aesfn_tab           ; 69
 DC.W     dsp_graf_rubberbox-aesfn_tab  ; 70
 DC.W     dsp_graf_dragbox-aesfn_tab    ; 71
 DC.W     dsp_graf_movebox-aesfn_tab    ; 72
 DC.W     dsp_graf_growbox-aesfn_tab    ; 73
 DC.W     dsp_graf_shrinkbox-aesfn_tab  ; 74
 DC.W     dsp_graf_watchbox-aesfn_tab   ; 75
 DC.W     dsp_graf_slidebox-aesfn_tab   ; 76
 DC.W     dsp_graf_handle-aesfn_tab     ; 77
 DC.W     dsp_graf_mouse-aesfn_tab      ; 78
 DC.W     dsp_graf_mkstate-aesfn_tab    ; 79
 DC.W     dsp_scrp_read-aesfn_tab       ; 80
 DC.W     dsp_scrp_write-aesfn_tab      ; 81
 DC.W     dsp_scrp_clear-aesfn_tab      ; 82
 DC.W     dsp_error-aesfn_tab           ; 83
 DC.W     dsp_error-aesfn_tab           ; 84
 DC.W     dsp_error-aesfn_tab           ; 85
 DC.W     dsp_error-aesfn_tab           ; 86
 DC.W     dsp_error-aesfn_tab           ; 87
 DC.W     dsp_error-aesfn_tab           ; 88
 DC.W     dsp_error-aesfn_tab           ; 89
 DC.W     dsp_fsel_input-aesfn_tab      ; 90
 DC.W     dsp_fsel_exinput-aesfn_tab    ; 91
 DC.W     dsp_error-aesfn_tab           ; 92
 DC.W     dsp_error-aesfn_tab           ; 93
 DC.W     dsp_error-aesfn_tab           ; 94
 DC.W     dsp_error-aesfn_tab           ; 95
 DC.W     dsp_error-aesfn_tab           ; 96
 DC.W     dsp_error-aesfn_tab           ; 97
 DC.W     dsp_error-aesfn_tab           ; 98
 DC.W     dsp_error-aesfn_tab           ; 99
 DC.W     dsp_wind_create-aesfn_tab     ; 100
 DC.W     dsp_wind_open-aesfn_tab       ; 101
 DC.W     dsp_wind_close-aesfn_tab      ; 102
 DC.W     dsp_wind_delete-aesfn_tab     ; 103
 DC.W     dsp_wind_get-aesfn_tab        ; 104
 DC.W     dsp_wind_set-aesfn_tab        ; 105
 DC.W     dsp_wind_find-aesfn_tab       ; 106
 DC.W     dsp_wind_update-aesfn_tab     ; 107
 DC.W     dsp_wind_calc-aesfn_tab       ; 108
 DC.W     dsp_wind_new-aesfn_tab        ; 109
 DC.W     dsp_rsrc_load-aesfn_tab       ; 110
 DC.W     dsp_rsrc_free-aesfn_tab       ; 111
 DC.W     dsp_rsrc_gaddr-aesfn_tab      ; 112
 DC.W     dsp_rsrc_saddr-aesfn_tab      ; 113
 DC.W     dsp_rsrc_obfix-aesfn_tab      ; 114
 DC.W     dsp_rsrc_rcfix-aesfn_tab      ; 115 MultiTOS
 DC.W     dsp_error-aesfn_tab           ; 116
 DC.W     dsp_error-aesfn_tab           ; 117
 DC.W     dsp_error-aesfn_tab           ; 118
 DC.W     dsp_error-aesfn_tab           ; 119
 DC.W     dsp_shel_read-aesfn_tab       ; 120
 DC.W     dsp_shel_write-aesfn_tab      ; 121
 DC.W     dsp_shel_get-aesfn_tab        ; 122
 DC.W     dsp_shel_put-aesfn_tab        ; 123
 DC.W     dsp_shel_find-aesfn_tab       ; 124
 DC.W     dsp_shel_envrn-aesfn_tab      ; 125 ($7d)
 DC.W     dsp_shel_rdef-aesfn_tab       ; 126 ($7e)    (!)
 DC.W     dsp_shel_wdef-aesfn_tab       ; 127 ($7f)    (!)
 DC.W     dsp_error-aesfn_tab           ; 128
 DC.W     dsp_error-aesfn_tab           ; 129
 DC.W     dsp_xgrf_stepcalc-aesfn_tab   ; 130 ($82)    (!)  -> appl_getinfo
 DC.W     dsp_xgrf_2box-aesfn_tab       ; 131 ($83)    (!)
 DC.W     dsp_xgrf_rbox-aesfn_tab       ; 132 ($84)    (!)  ab 25.8.96
 DC.W     dsp_error-aesfn_tab           ; 133
 DC.W     dsp_error-aesfn_tab           ; 134
 DC.W     dsp_form_popup-aesfn_tab      ; 135          (!!!)
 DC.W     dsp_form_xerr-aesfn_tab       ; 136          (!!!)
 DC.W     dsp_error-aesfn_tab           ; 137
 DC.W     dsp_error-aesfn_tab           ; 138
 DC.W     dsp_error-aesfn_tab           ; 139
 DC.W     dsp_error-aesfn_tab           ; 140
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ; 150
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_wdlg_create-aesfn_tab     ; 160
 DC.W     dsp_wdlg_open-aesfn_tab       ; 161
 DC.W     dsp_wdlg_close-aesfn_tab      ; 162
 DC.W     dsp_wdlg_delete-aesfn_tab     ; 163
 DC.W     dsp_wdlg_get-aesfn_tab        ; 164
 DC.W     dsp_wdlg_set-aesfn_tab        ; 165
 DC.W     dsp_wdlg_evnt-aesfn_tab       ; 166
 DC.W     dsp_wdlg_redraw-aesfn_tab     ; 167
 DC.W     dsp_error-aesfn_tab           ; 168
 DC.W     dsp_error-aesfn_tab           ; 169
 DC.W     dsp_lbox_create-aesfn_tab     ; 170
 DC.W     dsp_lbox_update-aesfn_tab     ; 171
 DC.W     dsp_lbox_do-aesfn_tab         ; 172
 DC.W     dsp_lbox_delete-aesfn_tab     ; 173
 DC.W     dsp_lbox_get-aesfn_tab        ; 174
 DC.W     dsp_lbox_set-aesfn_tab        ; 175
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_fnts_create-aesfn_tab     ; 180
 DC.W     dsp_fnts_delete-aesfn_tab     ; 181
 DC.W     dsp_fnts_open-aesfn_tab       ; 182
 DC.W     dsp_fnts_close-aesfn_tab      ; 183
 DC.W     dsp_fnts_get-aesfn_tab        ; 184
 DC.W     dsp_fnts_set-aesfn_tab        ; 185
 DC.W     dsp_fnts_evnt-aesfn_tab       ; 186
 DC.W     dsp_fnts_do-aesfn_tab         ; 187
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_error-aesfn_tab           ;
 DC.W     dsp_fslx_open-aesfn_tab       ; 190 ($be)
 DC.W     dsp_fslx_close-aesfn_tab      ; 191
 DC.W     dsp_fslx_getnxtfile-aesfn_tab ; 192
 DC.W     dsp_fslx_evnt-aesfn_tab       ; 193
 DC.W     dsp_fslx_do-aesfn_tab         ; 194
 DC.W     dsp_fslx_set-aesfn_tab        ; 195
 DC.W     dsp_error-aesfn_tab           ; 196
 DC.W     dsp_error-aesfn_tab           ; 197
 DC.W     dsp_error-aesfn_tab           ; 198
 DC.W     dsp_error-aesfn_tab           ; 199
 DC.W     dsp_pdlg_create-aesfn_tab     ; 200 pdlg_create
     IFNE 0
 DC.W     dsp_error-aesfn_tab           ; 201 pdlg_delete
 DC.W     dsp_error-aesfn_tab           ; 202 pdlg_open
 DC.W     dsp_error-aesfn_tab           ; 203 pdlg_close
 DC.W     dsp_error-aesfn_tab           ; 204 pdlg_get
 DC.W     dsp_error-aesfn_tab           ; 205 pdlg_set
 DC.W     dsp_error-aesfn_tab           ; 206 pdlg_evnt
 DC.W     dsp_error-aesfn_tab           ; 207 pdlg_do
     ENDIF

*
* case $0 (0) = sys_set
*

dsp_sys_set:
 move.w   (a3)+,d0                 ; Unter-Funktionsnummer
 bmi      dsys_num
 beq      dsys_0
 subq.w   #1,d0
 beq      dsys_1
 subq.w   #1,d0
 beq      dsys_2
 subq.w   #1,d0
 beq      dsys_3
 subq.w   #1,d0
 beq.b    dsys_4
 subq.w   #1,d0
 beq.b    dsys_5
 subq.w   #1,d0
 beq.b    dsys_6
 bra      dsys_err

;
; Unterfunktion 6: Fensterrahmen-Manager austauschen
;

     WFRVERSION SET 2

dsys_6:
 move.l   (a5)+,a0                 ; alte Struktur
 cmpi.w   #WFRVERSION,(a0)+        ; Versionsnummer OK?
 bne      dsys_err                 ; nein, Fehler
 lea      wsizeof,a1               ; Quelladresse
 move.w   #wbm_endvars-wsizeof,d0  ; Laenge der Struktur
 jsr      vmemcpy                   ; umsetzen
 move.l   (a5),d0                  ; neue Struktur
 beq      dsys_ok                  ; keine neuen Werte
 move.l   d0,a1
 cmpi.w   #WFRVERSION,(a1)+        ; Versionsnummer OK?
 bne      dsys_err                 ; nein, Fehler
 lea      wsizeof,a0               ; Zieladresse
 move.w   #wbm_endvars-wsizeof,d0  ; Laenge der Struktur
 jsr      vmemcpy                   ; umsetzen
 move.l   #wsg_flags,(a6)          ; addrout[0]: Fenster-Einstellungen
 bra      dsys_ok

;
; Unterfunktion 5: Farbicon-Farbtabelle neu durchrechnen
;

dsys_5:
 move.l   (a5),a1                  ; Tabelle mit 256 Promille-Tripeln
 suba.l   a0,a0                    ; vq_scrninfo neu berechnen
 move.w   nplanes,d0
 jsr      xp_colmp                 ; Farbicon-Farbtabelle berechnen
 bra      dsys_ok

;
; Unterfunktion 4: Editor installieren
;

dsys_4:
 move.l   fn_editor,(a6)           ; alten Wert zurueck
 move.l   (a5),fn_editor
 bra      dsys_ok

;
; Unterfunktion 3: in appl_getinfo einklinken
;

dsys_3:
 move.l   fn_getinfo,(a6)          ; alten Wert zurueck
 move.l   (a5),fn_getinfo
 bra      dsys_ok

;
; Unterfunktion 2: AES-Funktion aendern
;

dsys_2:
 move.l   (a5),a0                  ; Funktion
 move.w   (a3),d0                  ; Funktionsnummer
 bsr      chg_aes_fn
 move.w   d0,(a4)
 rts

;
; Unterfunktion 1: AES-Funktion ermitteln
;

dsys_1:
 move.w   (a3),d0                  ; Funktionsnummer
 cmp.w    fn_rellen,d0
 bcc.b    dsys_abs
 lea      aesfn_tab(pc),a0
 add.w    d0,d0
 move.w   0(a0,d0.w),d0            ; Sprung-Offset berechnen
 add.w    d0,a0                    ; rel->abs
 bra.b    dsys_bth1
dsys_abs:
 sub.w    fn_rellen,d0
 cmp.w    fn_abslen,d0
 bcc.b    dsys_fe
 move.l   fn_abstab,a0
 add.w    d0,d0
 add.w    d0,d0
 move.l   0(a0,d0.w),a0
dsys_bth1:
 cmpa.l   #dsp_error,a0
 bne.b    dsys_nofe
dsys_fe:
 suba.l   a0,a0                    ; ungueltige AES-Funktion
dsys_nofe:
 move.l   a0,(a6)
 bra.b    dsys_ok

;
; Unterfunktion 0: Adresse des AES-Dispatchers und "ungueltige AES-Version"
;                   ermitteln

dsys_0:
 move.l   #aes_dispatcher,(a6)+
 move.l   #dsp_error,(a6)
dsys_ok:
 move.w   #1,(a4)
 rts
dsys_err:
 clr.w    (a4)
 rts
; Unterfunktion -1: Max.Unterfunktionsnummer ermitteln
dsys_num:
 move.w   #6,(a4)                  ; max.Funktionsnummer
 rts

*
* case $a = appl_init
*

dsp_appl_init:
 move.l   a2,a0
 move.l   a4,a1
;move.l   #'KAOS',(a3)             ; Erkennung von KGEM nach intin[0,1]

* appl_init(a0 = int global[], a1 = int intout[])

appl_init:
 movea.l  act_appl,a2
 move.w   ap_id(a2),(a1)
 move.w   #$0399,(a0)+             ; global[0]     (ap_version) = 4.00
 move.w   #NAPPS-1,(a0)+           ; global[1]     (ap_count)
 move.w   (a1),(a0)+               ; global[2]     (ap_id)
 adda.w   #14,a0                   ; global[3,4]   (ap_private)
                                   ; global[5,6]   (ap_ptree)
                                   ; global[7,8]   (ap_pmem)
                                   ; global[9]     (ap_lmem)
 move.w   nplanes,(a0)+            ; global[10]    (ap_nplanes)
 move.l   #gem_magics,(a0)+        ; global[11,12]
 move.w   work_out+$5c,(a0)+       ; global[13]    (GEM 3.0: ap_bvdisk)
                                   ;               (TOS 4.0: kl. Schrifthoehe)
 move.w   work_out+$60,(a0)        ; global[14]    (GEM 3.0: ap_bvhard)
                                   ;               (TOS 4.0: gr. Schrifthoehe)

 move.l   menu_app,a0
 cmpa.l   applx+4,a0               ; SCRENMGR ist Hauptapplikation ?
 bne.b    apinit_nochg             ; nein, weiter
 move.l   a2,a0
 bsr      _set_app                 ; wir werden Hauptapplikation
apinit_nochg:
 rts

*
* case $b = appl_read
*

dsp_appl_read:
 move.w   (a3)+,d0
 bge.b    dar_old
 addq.w   #1,d0
 beq.b    dar_m1
 addq.w   #1,d0
 bne.b    dar_err                  ; Fehler
; Sonderbehandlung fuer MagiX 3.0: ap_id == -2 => warten mit Timeout
 moveq    #0,d0
 move.w   (a3),d0                  ; Timeout in 50Hz- Ticks
 move.l   (a5),a0                  ; 16-int-Puffer
 bsr      evnt_xmesag
 move.w   d0,(a4)
 rts
dar_m1:
; Sonderbehandlung fuer MultiTOS: ap_id == -1 => nicht warten
 move.l   act_appl,a0
 tst.w    ap_len(a0)               ; liegen Daten an ?
 bne.b    dar_old                  ; ja, lesen
dar_err:
 clr.w    (a4)                     ; nichts gelesen
 rts
dar_old:
 move.w   (a3),d0                  ; ap_id ignorieren
 move.l   (a5),a0
 bsr      appl_read
 move.w   d0,(a4)
 rts

* case $c = appl_write

dsp_appl_write:
 move.w   (a3)+,d1                 ; apid
 move.w   (a3),d0                  ; len
 move.l   (a5),a0                  ; buf
 bsr      appl_write
 move.w   d0,(a4)
 rts

* case $d = appl_find

dsp_appl_find:
 move.l   (a5),a0                  ; ap_fname
 bsr      appl_find
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $e = appl_tplay

dsp_appl_tplay:
 move.w   #1,(a4)                  ; kein Fehler
 move.w   (a3)+,d0
 move.w   (a3),d1
 move.l   (a5),a0
 jmp      appl_tplay

* case $f = appl_trecord

dsp_appl_trecord:
 move.w   (a3),d0
 move.l   (a5),a0
 jsr      appl_trecord
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $10 = appl_bvset

dsp_appl_bvset:
 move.w   #1,(a4)                  ; Dummy
 rts

* case $11 = appl_yield

dsp_appl_yield:
 move.w   #1,(a4)
 jmp      appl_yield

* case $12 = appl_search           ; erst ab MultiTOS

dsp_appl_search:
 move.l   act_appl,a2
 lea      ap_srchflg(a2),a2        ; Marker fuer 1st/next
 lea      (a4),a1                  ; &ap_sreturn,&ap_stype,&ap_sid
 move.l   (a5),a0                  ; addrin[0] = ap_sname
 move.w   (a3),d0                  ; intin[0]  = ap_smode
 jmp      appl_search

* case $13 = appl_exit

dsp_appl_exit:
 move.w   #1,(a4)
 jmp      appl_exit

* case $14 = evnt_keybd

dsp_evnt_keybd:
 jsr      evnt_keybd
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $15 = evnt_button

dsp_evnt_button:
 lea      2(a4),a0                 ; ret
 move.w   (a3)+,d0                 ; NOT/clicks
 swap     d0                       ; ins Hiword
 move.w   (a3),d0                  ; mask ins Loword
 lsl.w    #8,d0                    ; mask ins Hibyte des Loword
 move.b   3(a3),d0                 ; state ins Lobyte des Loword
 bsr      evnt_button
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $16 = evnt_mouse

dsp_evnt_mouse:
 lea      2(a4),a1                 ; intout+1
 move.l   a3,a0                    ; intin
 jsr      evnt_mouse
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $17 = evnt_mesag

dsp_evnt_mesag:
 move.l   (a5),a0
 jsr      evnt_mesag
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $18 = evnt_timer

dsp_evnt_timer:
 move.l   (a3),d0
 swap     d0                       ; Schwachsinn, aber laut Doku
 jsr      _evnt_timer
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $19 = evnt_multi

dsp_evnt_multi:
 pea      2(a4)                    ; &intout[1]
 move.l   (a5),-(sp)               ; msgbuf

 move.w   2(a3),d0                 ; ev_mbclicks: Bits 16..23
 swap     d0                       ; ins Hiword
 move.w   4(a3),d1                 ; ev_mbmask  : Bits  8..15
 lsl.w    #8,d1
 or.w     6(a3),d1                 ; ev_mbstate : Bits  0..7
 move.w   d1,d0                    ; in Loword
 move.l   d0,-(sp)                 ; long clmsk

 move.l   $1c(a3),d0
 swap     d0                       ; Schwachsinn, aber Doku
 move.l   d0,-(sp)                 ; long tcount

 pea      $12(a3)                  ; int mm2[5]
 pea      8(a3)                    ; int mm1[5]
 move.w   (a3),-(sp)               ; int flags
 jsr      _evnt_multi
 adda.w   #26,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $1a = evnt_dclicks

dsp_evnt_dclicks:
 move.w   (a3)+,d0
 move.w   (a3),d1
 bsr      evnt_dclicks
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $1e (30) = menu_bar

dsp_menu_bar:
 move.l   act_appl,a0
 tst.w    (a3)                     ; intin[0]
 bmi.b    dsp_menu_inq             ; MultiTOS
 bne.b    dsp_menu_on_inst
* menu_bar(0) schaltet das Menue ab
 moveq    #0,d0                    ; kein anderes Menue suchen
 jsr      menu_off                 ; mode == 0:        Menuebaum abmelden
 bra.b    dsp_menu_ok
dsp_menu_on_inst:
 move.l   (a5),a1                  ; OBJECT *tree
 cmpi.w   #100,(a3)
 beq.b    dsp_menu_instl
* menu_bar(1) schaltet das Menue ein und schaltet die aktive Applikation um
 move.l   menu_app,-(sp)           ; alten Eigner des Menues merken
 jsr      menu_on                  ; default:          Menuebaum anzeigen
 move.l   (sp)+,a0
 cmpa.l   menu_app,a0              ; Eigner hat sich geaendert ?
 beq.b    dsp_menu_ok              ; nein!
 jsr      all_untop                ; ggf. oberstes Fenster deaktivieren
 bra.b    dsp_menu_ok
* menu_bar(100) schaltet das Menue ein und schaltet NICHT die aktive Applikation um
dsp_menu_instl:
 move.l   a1,ap_menutree(a0)       ; mode ==  100:     in APPL eintragen
dsp_menu_ok:
 move.w   #1,(a4)                  ; kein Fehler
 rts
* menu_bar(-1) liefert ap_id des Menue- Eigners (MultiTOS)
dsp_menu_inq:
 moveq    #-1,d0
 move.l   menu_app,d1
 ble.b    dsp_menu_err             ; kein Eigner
 move.l   d1,a0
 move.w   ap_id(a0),d0
dsp_menu_err:
 move.w   d0,(a4)
 rts

* case $1f = menu_icheck

dsp_menu_icheck:
 clr.l    -(sp)                    ; DISABLED ignorieren, nicht zeichnen
 move.w   2(a3),d2                 ; aktivieren bzw. deaktivieren
 moveq    #4,d1                    ; CHECKED
 move.w   (a3),d0                  ; objnr
 move.l   (a5),a0                  ; tree
 jsr      menu_modify
 addq.w   #4,sp
aesdisp_ok:
 move.w   #1,(a4)
 rts

* case $20 = menu_ienable

dsp_menu_ienable:
 clr.w    -(sp)                    ; DISABLED ignorieren
 move.w   (a3),d0                  ; objnr
 smi      d1                       ; Bit 15 von objnr gesetzt ?
 andi.w   #1,d1                    ; zeichnen, wenn aktives Menue
 move.w   d1,-(sp)                 ; zeichnen, wenn gesetzt
 tst.w    2(a3)
 seq      d2                       ; aktivieren bzw. nicht
 moveq    #8,d1                    ; DISABLED
 andi.w   #$7fff,d0                ; Bit 15 von objnr loeschen
 move.l   (a5),a0                  ; tree
 jsr      menu_modify
 addq.w   #4,sp
 bra      aesdisp_ok

* case $21 = menu_tnormal

dsp_menu_tnormal:
 move.w   #1,-(sp)                 ; wenn DISABLED, nichts tun
 move.w   #1,-(sp)                 ; zeichnen, wenn aktives Menue
 tst.w    2(a3)
 seq      d2                       ; aktivieren bzw. nicht
 moveq    #1,d1                    ; SELECTED
 move.w   (a3),d0                  ; intin[0]  == int    objnr
 move.l   (a5),a0                  ; addrin[0] == OBJECT *tree
 jsr      menu_modify
 addq.w   #4,sp
 bra      aesdisp_ok

* case $22 = menu_text

dsp_menu_text:
 move.l   4(a5),a1                 ; addrin[1] == char *text
 move.l   (a5),a0                  ; addrin[0] == OBJECT *tree
 move.w   (a3),d0                  ; intin[0]  == int  objnr
 muls     #24,d0
 move.l   ob_spec(a0,d0.l),a0
menutext_loop:
 move.b   (a1)+,(a0)+
 bne.b    menutext_loop
 bra      aesdisp_ok

* case $23 (35) = menu_register

dsp_menu_register:
 move.l   (a5),a0                  ; string
 move.w   (a3),d0                  ; ap_id
 jsr      menu_register
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $24 (36) = menu_unregister
*                 menu_popup

dsp_menu_unregister:
 tst.w    6(a1)                    ; cntrl[3], Anzahl addrin ?
 bne.b    dsp_menu_popup
 move.w   (a3),d0                  ; menu_id oder -1
 jsr      menu_unregister
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $24 (36) = menu_popup

dsp_menu_popup:
 move.w   (a3)+,d0                 ; xpos
 move.w   (a3),d1                  ; ypos
 move.l   (a5)+,a0                 ; menu
 move.l   (a5),a1                  ; data
 jsr      menu_popup
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben


* case $25 (37) = menu_click
*                 menu_attach

dsp_menu_click:
 tst.w    6(a1)                    ; contrl[3] = Anzahl addrin
 bne.b    dsp_menu_attach          ; menu_attach
 btst     #2,(config_status+2).w     ; Bit 10
 sne      d0
 andi.w   #1,d0                    ; alter Wert

 move.w   (a3)+,d1                 ; neuer Wert
 tst.w    (a3)                     ; aendern ?
 beq.b    dmc_get                  ; nein, alten zurueck
 tst.w    d1
 bne.b    dmc_on
 bclr     #2,(config_status+2).w     ; Bit 10

 bra.b    dmc_get
dmc_on:
 bset     #2,(config_status+2).w     ; Bit 10
dmc_get:
 move.w   d0,(a4)                  ; Rueckgabewert
 jmp      _scmgr_reinit

* case $25 (37) = menu_attach

dsp_menu_attach:
 move.w   (a3)+,d0                 ; flag
 move.w   (a3),d1                  ; item
 move.l   (a5)+,a0                 ; tree
 move.l   (a5),a1                  ; data
 jsr      menu_attach
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $26 (38) = menu_istart

dsp_menu_istart:
 move.w   (a3)+,d0                 ; flag
 move.w   (a3)+,d1                 ; obj
 move.w   (a3),d2                  ; item
 move.l   (a5),a0                  ; tree
 jsr      menu_istart
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $27 (39) = menu_settings

dsp_menu_settings:
 move.w   (a3),d0                  ; flag
 move.l   (a5),a0                  ; values
 jsr      menu_settings
 move.w   #1,(a4)
 rts

* case $28 = objc_add

dsp_objc_add:
 move.w   #1,(a4)                  ; kein Fehler
 move.w   (a3)+,d0
 move.w   (a3),d1
 move.l   (a5),a0
 jmp      objc_add

* case $29 = objc_delete

dsp_objc_delete:
 move.w   #1,(a4)                  ; kein Fehler
 move.w   (a3),d0
 move.l   (a5),a0
 jmp      objc_delete

* case $2a = objc_draw

dsp_objc_draw:
 move.l   act_appl,a0              ; aufrufende Applikation
 move.l   (a5),d0                  ; tree
 cmp.l    ap_desktree(a0),d0
 bne.b    dod_nodesk               ; nicht mein Hintergrund
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 cmpa.l   w_owner(a1),a0
 bne.b    dod_ende                 ; mein Hintergrund ist inaktiv
 bra.b    dod_active
dod_nodesk:
 cmp.l    ap_menutree(a0),d0
 bne.b    dod_active               ; ich will nicht mein Menue zeichnen
 cmpa.l   menu_app,a0              ; ist Menue/Hintergrund- Besitzende ?
 beq.b    dod_active               ; ja, zeichnen
 move.l   d0,a0
 btst     #RBUTTON_B,ob_flags+1(a0)     ; Spezial-Hack ?
 beq.b    dod_ende                 ; nein, inaktives Menue nicht zeichnen
dod_active:
 lea      4(a3),a0                 ; intin+2
 jsr      set_clip_grect
 move.w   (a3)+,d0                 ; startob
 move.w   (a3),d1                  ; depth
 move.l   (a5),a0                  ; tree
 jsr      _objc_draw               ; kann wegen VDI- Aufruf (a4) veraendern!
dod_ende:
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case $2b = objc_find

dsp_objc_find:
 move.w   (a3)+,d0                 ; startob
 move.w   (a3)+,d1                 ; depth
 move.l   (a3),d2                  ; x,y
 move.l   (a5),a0                  ; tree
 jsr      _objc_find
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $2c = objc_offset

dsp_objc_offset:
 move.w   (a3),d0
 move.l   (a5),a0
 jsr      _objc_offset
 move.w   #1,(a4)+                 ; kein Fehler (war void- Funktion)
 move.w   d0,(a4)+
 move.w   d1,(a4)
 rts

* case $2d = objc_order

dsp_objc_order:
 move.w   #1,(a4)                  ; kein Fehler
 move.w   (a3)+,d0
 move.w   (a3),d1
 move.l   (a5),a0
 jmp      objc_order

* case $2e = objc_edit

dsp_objc_edit:
 lea      2(a4),a1                 ; &ob_edidx
 move.w   (a3)+,d0                 ; objnr
 move.w   (a3)+,d1                 ; char
 move.w   (a3)+,(a1)               ; mit pos vorbesetzen
 move.w   (a3),d2                  ; kind
 move.l   (a5)+,a0                 ; tree
 move.l   (a5),-(sp)               ; optional: GRECT *  (Mag!X)
 jsr      _objc_edit
 addq.l   #4,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $2f = objc_change

dsp_objc_change:
 move.w   #1,(a4)                  ; kein Fehler
 move.l   act_appl,a0              ; aufrufende Applikation
 move.l   (a5),d0                  ; tree
 cmp.l    ap_desktree(a0),d0
 bne.b    doc_nodesk               ; nicht mein Hintergrund
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 cmpa.l   w_owner(a1),a0
 bne.b    doc_ende                 ; mein Hintergrund ist inaktiv
 bra.b    doc_active
doc_nodesk:
 cmp.l    ap_menutree(a0),d0
 bne.b    doc_active               ; nicht mein Menue
 cmpa.l   menu_app,a0              ; ist Menue/Hintergrund- Besitzende
 bne.b    doc_ende                 ; inaktives Menue nicht zeichnen
doc_active:
 lea      4(a3),a0
 jsr      set_clip_grect
 move.w   $e(a3),d2
 move.w   $c(a3),d1
 move.w   (a3),d0
 move.l   (a5),a0
 jmp      _objc_change
doc_ende:
 rts

* case $30 = objc_sysvar()

dsp_objc_sysvar:
 move.w   (a3)+,d0                 ; get/set
 move.w   (a3)+,d1                 ; which
 move.l   (a3),d2                  ; data
 jsr      _objc_sysvar
 move.w   d0,(a4)+
 move.l   d1,(a4)
 rts

* case $32 = form_(x)do

dsp_form_do:
 move.w   (a3),d0                  ; objnr
 move.l   (a5)+,a0                 ; tree
 cmpi.w   #2,6(a1)                 ; Anz. addrin >= 2 ?
 bcc.b    dsp_form_xdo
 jsr      form_do
 move.w   d0,(a4)                  ; objnr
 rts

dsp_form_xdo:
 move.l   (a5)+,a1                 ; keytab
 move.l   (a5),a2                  ; fuer FlyDial
 jsr      _form_xdo
 move.w   d0,(a4)+                 ; objnr
 move.w   d1,(a4)                  ; last cursor
 rts


* case $33 = form_(x)dial

dsp_form_dial:
 move.w   #1,(a4)                  ; kein Fehler
 move.l   (a5),a2                  ; void **flyinf
 cmpi.w   #2,6(a1)                 ; Anz. addrin >= 2 ? (wegen TC- Fehler!)
 bcc.b    dsp_form_xdial
 suba.l   a2,a2                    ; keine FlyDials
dsp_form_xdial:
 lea      10(a3),a1                ; GRECT *big
 lea      2(a3),a0                 ; GRECT *little
 move.w   (a3),d0                  ; int   flag
 jmp      __fm_xdial

* case $34 = form_alert

dsp_form_alert:
 move.l   (a5),a0
 move.w   (a3),d0
 jsr      form_alert
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $35 = form_error

dsp_form_error:
 move.w   (a3),d0
 jsr      form_error
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $36 = form_center

dsp_form_center:
 move.w   #1,(a4)                  ; kein Fehler
 lea      2(a4),a1
 move.l   (a5),a0
 jmp      _form_center

* case $37 = form_keybd

dsp_form_keybd:
 lea      desk_g,a0
 jsr      set_clip_grect
 move.w   2(a3),4(a4)              ; *fo_knxtchar = fo_kchar
 move.w   4(a3),2(a4)              ; *fo_knxtobject = fo_kobnext
 move.w   #-1,-(sp)                ; kein Window
 pea      2(a4)                    ; &fo_knxtobject
 pea      4(a4)                    ; &fo_knxtchar
 move.w   (a3),-(sp)               ; fo_kobject
 move.l   (a5),-(sp)               ; OBJECT *tree
 jsr      _form_wkeybd
 adda.w   #16,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $38 = form_button

dsp_form_button:
 lea      desk_g,a0
 jsr      set_clip_grect

 move.w   (a3)+,d0                 ; objnr
 moveq    #-1,d2                   ; winhdl
 move.w   (a3),d1                  ; nclicks
 move.l   (a5),a0                  ; tree
 jsr      _form_button
 move.w   d0,(a4)+
 move.w   d1,(a4)                  ; nxtobj
 rts                               ; d0 zurueckgeben

* case 60 ($3c) = objc_wdraw

dsp_objc_wdraw:
 move.w   (a3)+,d0                 ; startob
 move.w   (a3)+,d1                 ; depth
 move.w   (a3),d2                  ; whdl
 move.l   (a5)+,a0                 ; tree
 move.l   (a5),a1                  ; g
 jsr      objc_wdraw               ; kann wegen VDI- Aufruf (a4) veraendern!
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 61 ($3d) = objc_wchange

dsp_objc_wchange:
 move.w   (a3)+,d0                 ; obj
 move.w   (a3)+,d1                 ; newstate
 move.w   (a3),d2                  ; whdl
 move.l   (a5)+,a0                 ; tree
 move.l   (a5),a1                  ; g
 jsr      objc_wchange             ; kann wegen VDI- Aufruf (a4) veraendern!
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 62 ($3e) = graf_wwatchbox

dsp_graf_wwatchbox:
 move.w   (a3)+,d0                 ; obj
 move.w   (a3)+,d1                 ; instate
 move.w   (a3)+,d2                 ; outstate
 move.w   (a3),-(sp)               ; whdl
 move.l   (a5),a0                  ; tree
 jsr      graf_wwatchbox
 addq.l   #2,sp
 move.w   d0,(a4)
 rts

* case 63 ($3f) = form_wbutton

dsp_form_wbutton:
 lea      desk_g,a0
 jsr      set_clip_grect

 move.w   (a3)+,d0                 ; objnr
 move.w   (a3)+,d1                 ; nclicks
 move.w   (a3),d2                  ; winhdl
 move.l   (a5),a0                  ; tree
 jsr      _form_button
 move.w   d0,(a4)+
 move.w   d1,(a4)                  ; nxtobj
 rts                               ; d0 zurueckgeben

* case 64 ($40) = _form_wkeybd

dsp_form_wkeybd:
 lea      desk_g,a0
 jsr      set_clip_grect
 move.w   2(a3),4(a4)              ; *fo_knxtchar = fo_kchar
 move.w   4(a3),2(a4)              ; *fo_knxtobject = fo_kobnext
 move.w   6(a3),-(sp)              ; Window
 pea      2(a4)                    ; &fo_knxtobject
 pea      4(a4)                    ; &fo_knxtchar
 move.w   (a3),-(sp)               ; fo_kobject
 move.l   (a5),-(sp)               ; OBJECT *tree
 jsr      _form_wkeybd
 adda.w   #16,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case 65 ($41) = objc_wedit

dsp_objc_wedit:
 lea      2(a4),a1                 ; &ob_edidx
 move.w   (a3)+,d0                 ; objnr
 move.w   (a3)+,d1                 ; char
 move.w   (a3)+,(a1)               ; mit pos vorbesetzen
 move.w   (a3)+,d2                 ; kind
 move.w   (a3),-(sp)               ; whandle
 move.l   (a5)+,a0                 ; tree
 jsr      objc_wedit
 addq.l   #2,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $46 = graf_rubberbox

dsp_graf_rubberbox:
 move.l   (a3)+,d0                 ; x,y
 move.w   (a3)+,d1                 ; minw
 move.w   (a3),d2                  ; minh
 jsr      graf_rubberbox
 move.w   #1,(a4)+                 ; kein Fehler
 move.l   d0,(a4)                  ; w,h
 rts

* case $47 = graf_dragbox

dsp_graf_dragbox:
 lea      8(a3),a1                 ; aeusseres Rechteck
 move.l   (a3)+,-(sp)              ; w,h
 move.l   (a3),-(sp)               ; x,y
 move.l   sp,a0                    ; inneres Rechteck umdrehen
 moveq    #0,d0                    ; kein callback
 jsr      graf_dragbox
 addq.l   #8,sp
 move.w   #1,(a4)+                 ; kein Fehler
 move.l   d0,(a4)                  ; x,y
 rts

* case $48 = graf_movebox

dsp_graf_movebox:
 move.w   $a(a3),-(sp)
 move.l   6(a3),-(sp)
 move.l   2(a3),-(sp)
 move.w   (a3),-(sp)
 jsr      graf_movebox
 adda.w   #12,sp
 bra      aesdisp_ok

* case $49 = graf_growbox

dsp_graf_growbox:
 lea      graf_growbox,a0
 bra.b    dgs_l1

* case $4a = graf_shrinkbox

dsp_graf_shrinkbox:
 lea      graf_shrinkbox,a0
dgs_l1:
 pea      8(a3)                    ; GRECT
 pea      (a3)                     ; GRECT
 jsr      (a0)
 addq.w   #8,sp
 bra      aesdisp_ok

* case $4b = graf_watchbox

dsp_graf_watchbox:
 addq.l   #2,a3                    ; "reserviert"
 move.w   (a3)+,d0
 move.w   (a3)+,d1
 move.w   (a3),d2
 move.l   (a5),a0
 jsr      graf_watchbox
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $4c = graf_slidebox

dsp_graf_slidebox:
 move.w   (a3)+,d0
 move.w   (a3)+,d1
 move.w   (a3),d2
 move.l   (a5),a0
 jsr      graf_slidebox
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $4d = graf_handle

dsp_graf_handle:
 move.l   act_appl,a0
 btst     #0,ap_flags+3(a0)
 beq.b    dsgh_ok
 move.w   dummyvws,d0
 beq.b    dsgh_ok
 move.w   d0,(a4)+                 ; intout[0] = Dummy-Ws fuer MyDials
 bra.b    dsgh_both
dsgh_ok:
 move.w   vcontrl+12,(a4)+         ; intout[0] = Handle der AES- Workstation
dsgh_both:
 move.w   big_wchar,(a4)+          ; intout[1] = hwchar
 move.w   big_hchar,(a4)+          ; intout[2] = hhchar
 move.w   gr_hwbox,(a4)+           ; intout[3] = hwbox
 move.w   gr_hhbox,(a4)+           ; intout[4] = hhbox
 cmpi.w   #6,4(a1)                 ; contrl[2], #intout < 6 ?
 bcs.b    dgf_nod
 move.w   vdi_device,(a4)          ; intout[5] = Geraetenummer des AES !!!

dgf_nod:
 rts

* case $4e = graf_mouse

dsp_graf_mouse:
 move.l   (a5),a0
 move.w   (a3),d0
 bsr      _graf_mouse
 bra      aesdisp_ok

* case $4f = graf_mkstate

dsp_graf_mkstate:
 move.w   #1,(a4)+                 ; kein Fehler
 move.l   a4,a0
* PUREC void _graf_mkstate(int *data);
_graf_mkstate:
 move.w   gr_mkmx,(a0)+
 move.w   gr_mkmy,(a0)+
 move.w   gr_mkmstate,(a0)+
 move.w   gr_mkkstate,(a0)
 rts

* case $50 = scrp_read

dsp_scrp_read:
 move.l   (a5),a0
 bsr      scrp_read
 move.w   d0,(a4)
 rts

* case $51 = scrp_write

dsp_scrp_write:
 move.w   #1,(a4)                  ; kein Fehler
 move.l   (a5),a0
 jmp      scrp_write


* case $52 = scrp_clear

dsp_scrp_clear:
 bsr      scrp_clear
 move.w   d0,(a4)
 rts

* case $5a = fsel_input

dsp_fsel_input:
 clr.l    -(sp)                    ; Defaulttitel
 bra.b    dfe_l1

* case $5b = fsel_exinput

dsp_fsel_exinput:
 move.l   8(a5),-(sp)              ; char *title
dfe_l1:
 pea      2(a4)                    ; int *button
 move.l   4(a5),-(sp)              ; char *name
 move.l   (a5),-(sp)               ; char *path
 move.l   gem_magics+$60,a0        ; fsel_exinput
 move.l   (a0),a0
 jsr      (a0)
 adda.w   #16,sp
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $64 = wind_create

dsp_wind_create:
 move.w   (a3)+,d0
 move.l   a3,a0
 jsr      _wind_create
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $65 = wind_open

dsp_wind_open:
 move.w   (a3)+,d0
 move.l   a3,a0
 jsr      _wind_open
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $66 = wind_close

dsp_wind_close:
 move.w   (a3),d0
 jsr      wind_close
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $67 = wind_delete

dsp_wind_delete:
 move.w   (a3),d0
 jsr      wind_delete
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $68 = wind_get

dsp_wind_get:
 move.w   (a3)+,d0                 ; handle
 move.w   (a3)+,d1                 ; opcode
 move.w   (a3),d2                  ; opcode2 (WF_DCOLOR)
 lea      2(a4),a0                 ; GRECT *
 jsr      _wind_get
 move.w   d0,(a4)                  ; Rueckgabe 0, falls Handle ungueltig
 rts

* case $69 = wind_set

dsp_wind_set:
 move.w   (a3)+,d0                 ; handle
 move.w   (a3)+,d1                 ; opcode
 move.l   a3,a0                    ; GRECT *
 jsr      _wind_set
 move.w   d0,(a4)                  ; Rueckgabe 0, falls Handle ungueltig
 rts

* case $6a = wind_find

dsp_wind_find:
 move.w   (a3)+,d0
 move.w   (a3),d1
 jsr      wind_find
 move.w   d0,(a4)
 rts

* case $6b = wind_update

dsp_wind_update:
 move.w   (a3),d0
 bsr      wind_update
 move.w   d0,(a4)
 rts

* case $6c = wind_calc

dsp_wind_calc:
 move.w   (a3)+,d0                 ; flag
 move.w   (a3)+,d1                 ; kind
 move.l   a3,a0                    ; ing
 move.w   #1,(a4)+                 ; kein Fehler
 move.l   a4,a1                    ; outg
 jmp      _wind_calc

* case $6d = wind_new

dsp_wind_new:
 move.w   #1,(a4)                  ; kein Fehler
 jmp      wind_new

* case $6e = rsrc_load

dsp_rsrc_load:
 move.l   (a5),a1                  ; filename
 move.l   a2,a0                    ; global
 jsr      rsrc_load
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $6f = rsrc_free

dsp_rsrc_free:
 move.l   a2,a0                    ; global
 jsr      rsrc_free
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $70 = rsrc_gaddr

dsp_rsrc_gaddr:
 move.w   (a3)+,d0                 ; type
 move.w   (a3),d1                  ; index
 move.l   a2,a0                    ; global
 jsr      rsrc_gaddr
 move.l   d0,(a6)                  ; in addrout[0] merken
 addq.l   #1,d0                    ; ist -1L ?
 beq.b    drg_err                  ; ja, return(0)
 moveq    #1,d0                    ; nein, return(1)
drg_err:
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $71 = rsrc_saddr

dsp_rsrc_saddr:
 move.l   (a5),a1
 move.w   (a3)+,d0
 move.w   (a3),d1
 move.l   a2,a0                    ; global[]
 jsr      rsrc_saddr
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $72 = rsrc_obfix

dsp_rsrc_obfix:
 move.w   (a3),d0
 move.l   (a5),a0
 jsr      rsrc_obfix
 move.w   d0,(a4)
 rts

* case $73 = rsrc_rcfix

dsp_rsrc_rcfix:
 move.l   (a5),a1                  ; Datei
 move.l   a2,a0                    ; global
 jsr      rsc_init
 bra      aesdisp_ok

* case $78 = shel_read

dsp_shel_read:
 move.l   (a5)+,a0
 move.l   (a5),a1
 bsr      shel_read
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $79 = shel_write

dsp_shel_write:
 move.l   (a5)+,a0                 ; cmd
 move.l   (a5),a1                  ; tail
 move.w   (a3)+,d0                 ; doex
 move.w   (a3)+,d1                 ; isgr
 move.w   (a3),d2                  ; isover
 bsr      shel_write
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $7a = shel_get

dsp_shel_get:
 move.w   (a3),d0
 move.l   (a5),a0
 bsr      shel_get
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $7b = shel_put

dsp_shel_put:
 move.w   (a3),d0
 move.l   (a5),a0
 bsr      shel_put
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $7c = shel_find

dsp_shel_find:
 move.l   (a5),a0
 bsr      shel_find
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $7d = shel_envrn

dsp_shel_envrn:
 move.l   4(a5),a0                 ; gesuchte Variable
 bsr      shel_envrn
 move.l   (a5),a1
 move.l   a0,(a1)
 move.w   d0,(a4)
 rts                               ; d0 zurueckgeben

* case $7e = shel_rdef

dsp_shel_rdef:
 move.w   #1,(a4)                  ; kein Fehler
 move.l   #shel_name,(a6)          ; Adresse nach addrout[0]

 move.l   (a5)+,a0                 ; addrin[0] (lpcmd)
 move.l   (a5),a1                  ; addrin[1] (lpdir)
 jmp      shel_rdef

* case $7f = shel_wdef

dsp_shel_wdef:
 move.w   #1,(a4)                  ; kein Fehler
 move.l   (a5)+,a0                 ; addrin[0] (lpcmd)
 move.l   (a5),a1                  ; addrin[1] (lpdir)
 jmp      shel_wdef

* case $82 = xgrf_stepcalc

dsp_xgrf_stepcalc:
 cmpi.w   #5,4(a1)                 ; contrl[2] (Laenge intout) == 5 ?
 beq.b    dsp_appl_getinfo
 pea      10(a4)
 pea      8(a4)
 pea      6(a4)

 pea      4(a4)
 pea      2(a4)
 pea      4(a3)
 move.l   (a3),-(sp)
 jsr      xgrf_stepcalc
 adda.w   #28,sp
 bra      aesdisp_ok


dsp_appl_getinfo:
 lea      (a4),a0
 move.w   (a3),d0                  ; intin[0] == ap_gtype
 move.l   fn_getinfo,-(sp)         ; indirekter Sprung
 rts

* case $83 = xgrf_2box

dsp_xgrf_2box:
 jsr      set_xor_black
 jsr      mouse_off
 move.w   8(a3),-(sp)              ; doubled
 move.l   2(a3),-(sp)              ; xstep,ystep
 move.l   14(a3),-(sp)             ; w,h
 move.l   10(a3),-(sp)             ; x,y
 move.w   (a3),-(sp)               ; cnt
 move.w   6(a3),-(sp)              ; corners
 jsr      xgrf_2box
 adda.w   #18,sp
 jsr      mouse_on
 bra      aesdisp_ok

* case $84 = xgrf_rbox   (ab 25.8.96)

dsp_xgrf_rbox:
 jsr      mouse_off
 lea      (a3),a0                  ; intin
 jsr      set_clip_grect           ; Clipping setzen
 jsr      _set_xor_black
 lea      8(a3),a0                 ; zu zeichnendes GRECT
 jsr      v_drawgrect
 jsr      mouse_on
 bra      aesdisp_ok

* case $87 = form_popup / xfrm_popup (ab 18.8.96)

dsp_form_popup:
 move.l   (a3)+,d0                 ; intin[0] = x, intin[1] = y
 move.l   (a5)+,a0                 ; addrin[0] = OBJECT *
 cmpi.w   #6,2(a1)                 ; intin[0..5] ???
 bcs.b    dsp_pop
 cmpi.w   #3,6(a1)                 ; addrin[0..2] ???
 bcs.b    dsp_pop
 move.w   (a3)+,d1                 ; intin[2] = firstscrlobj
 move.w   (a3)+,d2                 ; intin[3] = lastscrlobj
 move.l   (a5)+,a1                 ; addrin[1] = init_objs()
 clr.w    -(sp)                    ; Bildschirmpuffer allozieren
 pea      2(a4)                    ; intout[1] = int *lastscrl
 move.w   (a3)+,-(sp)              ; intin[4] = nlines
 move.w   (a3),2(a4)               ; intin[5] = scrollpos (input)
 move.l   (a5),-(sp)               ; addrin[2] = void *param
 jsr      xfrm_popup
 adda.w   #12,sp
 move.w   d0,(a4)
 rts
dsp_pop:
 jsr      _form_popup
 move.w   d0,(a4)
 rts

* case $88 = form_xerr

dsp_form_xerr:
 move.l   (a3),d0                  ; GEMDOS- errcode
 move.l   (a5),a0                  ; errfile
 bsr      form_xerr
 move.w   d0,(a4)
 rts

* case 160 = wdlg_create

dsp_wdlg_create:
 lea      12(a5),a5                ; addrin+3
 move.l   (a5),-(sp)               ; addrin[3] = data
 move.w   (a3)+,d0                 ; intin[0] = code
 move.w   (a3),d1                  ; intin[1] = flags
 move.l   -(a5),-(sp)              ; addrin[2] = user_data
 movea.l  -(a5),a1                 ; addrin[1] = tree
 movea.l  -(a5),a0                 ; addrin[0] = handle_exit
 jsr      wdlg_create              ; DIALOG  *wdlg_create( HNDL_OBJ handle_exit,
;                                                 OBJECT *tree, void *user_data,
;                                                 WORD code, void *data )
 addq.l   #8,sp
 move.l   a0,(a6)                  ; addrout[0]
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 161 = wdlg_open

dsp_wdlg_open:
 lea      6(a3),a3                 ; intin+3
 lea      8(a5),a5                 ; addrin+2

 move.l   (a5),-(sp)               ; addrin[2] = data
 move.w   (a3),-(sp)               ; intin[3] = code
 move.w   -(a3),d2                 ; intin[2] = y
 move.w   -(a3),d1                 ; intin[1] = x
 move.w   -(a3),d0                 ; intin[0] = kind
 movea.l  -(a5),a1                 ; addrin[1] = title
 movea.l  -(a5),a0                 ; addrin[0] = dialog
 jsr      wdlg_open                ; WORD wdlg_open( DIALOG *d, BYTE *title,
;                                                      WORD kind, WORD x, WORD y,
;                                                      WORD code, void *data );
 addq.l   #6,sp
 move.w   d0,(a4)
 rts

* case 162 = wdlg_close

dsp_wdlg_close:
 pea      4(a4)                    ; intout[2] = y
 lea      2(a4),a1                 ; intout[1] = x
 movea.l  (a5),a0                  ; addrin[0] = dialog
 jsr      wdlg_close               ; WORD wdlg_close( DIALOG *d );
 addq.l   #4,sp
 move.w   d0,(a4)
 rts

* case 163 = wdlg_delete

dsp_wdlg_delete:
 movea.l  (a5),a0                  ; addrin[0] = dialog
 jsr      wdlg_delete              ; WORD wdlg_delete( DIALOG *d );
 move.w   d0,(a4)
 rts

* case 164 = wdlg_get

dsp_wdlg_get:
 movea.l  (a5)+,a0                 ; addrin[0]: dialog
 move.w   (a3)+,d0                 ; intin[0] = subcode, 0: wdlg_get_tree?
 beq.b    awdlg_get_tree
 subq.w   #1,d0                    ; 1: wdlg_get_edit ?
 beq.b    awdlg_get_edit
 subq.w   #1,d0                    ; 2: wdlg_get_udata ?
 beq.b    awdlg_get_udata
 subq.w   #1,d0                    ; 3: wdlg_get_handle ?
 beq.b    awdlg_get_handle
 clr.w    (a4)                     ; Fehler !

 rts

awdlg_get_tree:
;movea.l  a0,a0                    ; addrin[0]: dialog
 movea.l  (a5)+,a1                 ; addrin[1]: tree
 move.l   (a5)+,-(sp)              ; addrin[2]: r
 jsr      wdlg_get_tree            ; WORD wdlg_get_tree( DIALOG *d, OBJECT **tree,
;                                                       GRECT *r )
 addq.l   #4,sp
 move.w   d0,(a4)
 rts
awdlg_get_edit:
 lea      2(a4),a1                 ; &intout[1]
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_get_edit            ; WORD wdlg_get_edit( DIALOG *d, WORD *cursor )
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts
awdlg_get_udata:
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_get_udata           ; void *wdlg_get_udata( DIALOG *d )
 move.l   a0,(a6)                  ; addrout[0]
 move.w   #1,(a4)                  ; kein Fehler
 rts
awdlg_get_handle:
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_get_handle          ; WORD wdlg_get_handle( DIALOG *d )
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts

* case 165 = wdlg_set

dsp_wdlg_set:
 movea.l  (a5)+,a0                 ; addrin[0]: dialog
 move.l   (a5)+,a1                 ; addrin[1]: <versch.>
 move.w   (a3)+,d0                 ; intin[0] = 0: wdlg_set_edit?
 beq.b    awdlg_set_edit
 subq.w   #1,d0
 beq.b    awdlg_set_tree
 subq.w   #1,d0
 beq.b    awdlg_set_size
 subq.w   #1,d0
 beq.b    awdlg_set_iconify
 subq.w   #1,d0
 beq.b    awdlg_set_uniconify
 clr.w    (a4)                     ; Fehler !
 rts
awdlg_set_edit:
 move.w   (a3),d0                  ; intin[1]: obj
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_set_edit            ; WORD wdlg_set_edit( DIALOG *d, WORD obj )
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts
awdlg_set_tree:
;move.l   a1,a1                    ; addrin[1]: tree
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_set_tree            ; WORD wdlg_set_tree( DIALOG *d, OBJECT *tree )
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts
awdlg_set_size:
;move.l   a1,a1                    ; addrin[1]: size
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_set_size            ; WORD    wdlg_set_size( DIALOG *d, GRECT *size )
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts
awdlg_set_iconify:
 move.w   (a3),d0                  ; intin[1]: obj
 move.l   4(a5),-(sp)              ; addrin[3]: tree




 move.l   (a5),-(sp)               ; addrin[2]: title
;move.l   a1,a1                    ; addrin[1]: g
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_set_iconify         ; WORD wdlg_set_iconify( DIALOG *d, GRECT *g,
                                   ;                   char *title,
                                   ;                   OBJECT *tree, WORD obj )
 addq.l   #8,sp
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts
awdlg_set_uniconify:
 move.l   4(a5),-(sp)              ; addrin[3]: tree
 move.l   (a5),-(sp)               ; addrin[2]: title
;move.l   a1,a1                    ; addrin[1]: g
;movea.l  a0,a0                    ; addrin[0]: dialog
 jsr      wdlg_set_uniconify       ; WORD wdlg_set_uniconify( DIALOG *d,
                                   ;                   GRECT *size,
                                   ;                   char *title,
                                   ;                   OBJECT *tree)
 addq.l   #8,sp
 move.w   d0,(a4)                  ; intout[0]: Edit-Objekt
 rts

* case 166 = wdlg_evnt

dsp_wdlg_evnt:
 movea.l  (a5)+,a0                 ; addrin[0]: dialog
 movea.l  (a5),a1                  ; addrin[1]: events
 jsr      wdlg_evnt                ; WORD wdlg_evnt( DIALOG *d, EVNT *events )
 move.w   d0,(a4)
 rts

* case 167 = wdlg_redraw

dsp_wdlg_redraw:
 move.w   (a3)+,d0                 ; intin[0]: obj
 move.w   (a3)+,d1                 ; intin[1]: depth
 movea.l  (a5)+,a0                 ; addrin[0]: dialog
 movea.l  (a5),a1                  ; addrin[1]: rect
 jsr      wdlg_redraw              ; void wdlg_redraw( DIALOG *d, GRECT *rect,
;                                                      WORD obj, WORD depth )
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 170 = lbox_create

dsp_lbox_create:
 lea      14(a3),a3                ; intin+7
 lea      28(a5),a5                ; addrin+7

 move.w   (a3),-(sp)               ; intin[7]:    pause2

 move.w   -(a3),-(sp)              ; intin[6]:    width
 move.w   -(a3),-(sp)              ; intin[5]:    visible
 move.w   -(a3),-(sp)              ; intin[4]:    offset
 move.l   (a5),-(sp)               ; addrin[7]:   dialog
 move.l   -(a5),-(sp)              ; addrin[6]:   user_data
 move.w   -(a3),-(sp)              ; intin[3]:    pause
 move.w   -(a3),d2                 ; intin[2]:    flags
 move.l   -(a5),-(sp)              ; addrin[5]:   objs
 move.l   -(a5),-(sp)              ; addrin[4]:   ctrl_objs
 move.w   -(a3),d1                 ; intin[1]:    first
 move.w   -(a3),d0                 ; intin[0]:    entries
 move.l   -(a5),-(sp)              ; addrin[3]:   items
 move.l   -(a5),-(sp)              ; addrin[2]:   set
 movea.l  -(a5),a1                 ; addrin[1]:   slct
 movea.l  -(a5),a0                 ; addrin[0]:   tree
 jsr      lbox_create              ; void *lbox_create( OBJECT *tree,
;                                            SLCT_ITEM slct, SET_ITEM set,
;                                            SCROLL_ITEM *items,
;                                            WORD entries, WORD first,
;                                            WORD *ctrl_objs,
;                                            WORD *objs, WORD flags,
;                                            WORD pause, void *user_data,
;                                            WORD offset, WORD visible,
;                                            WORD width, WORD pause2 );
 lea      34(sp),sp
 move.l   a0,(a6)                  ; addrout[0]: Zeiger auf SCROLL_BOX
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 171 = lbox_update

dsp_lbox_update:
 movea.l  (a5)+,a0                 ; addrin[0]: box
 movea.l  (a5),a1                  ; addrin[1]: rect
 jsr      lbox_update              ; void lbox_update( void *box, GRECT *rect )
 move.w   #1,(a4)                  ; no error (unneccessary, function is void)
 rts

* case 172 = lbox_do

dsp_lbox_do:
 move.w   (a3),d0                  ; intin[0]: obj
 movea.l  (a5),a0                  ; addrin[0]: box
 jsr      lbox_do                  ; WORD lbox_do( void *box, WORD obj );
 move.w   d0,(a4)
 rts

* case 173 = lbox_delete

dsp_lbox_delete:
 movea.l  (a5),a0                  ; addrin[0]: box
 jsr      lbox_delete              ; WORD lbox_delete( void *box );
 move.w   d0,(a4)
 rts

* case 174 = lbox_get

dsp_lbox_get:
 movea.l  (a5)+,a0                 ; addrin[0]: box
 move.w   (a3)+,d0                 ; intin[0]: Funktionsnummer
 cmp.w    #LBOX_GET_BFIRST,d0
 bhi.b    albox_get_exit

 add.w    d0,d0
 move.w   albox_get_tab(pc,d0.w),d0
 jmp      albox_get_tab(pc,d0.w)

albox_get_exit:
albox_set_exit:
 clr.w    (a4)                     ; Fehler
 rts

albox_get_tab:
 DC.W     albox_cnt_items-albox_get_tab
 DC.W     albox_get_tree-albox_get_tab
 DC.W     albox_get_size-albox_get_tab
 DC.W     albox_get_udata-albox_get_tab
 DC.W     albox_get_first-albox_get_tab
 DC.W     albox_get_s_idx-albox_get_tab
 DC.W     albox_get_items-albox_get_tab
 DC.W     albox_get_item-albox_get_tab
 DC.W     albox_get_s_item-albox_get_tab
 DC.W     albox_get_idx-albox_get_tab
 DC.W     albox_get_bvis-albox_get_tab
 DC.W     albox_get_bentries-albox_get_tab
 DC.W     albox_get_bfirst-albox_get_tab

albox_cnt_items:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_cnt_items           ;WORD lbox_cnt_items( void *box );
 move.w   d0,(a4)
 rts
albox_get_tree:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_tree            ; OBJECT  *lbox_get_tree( void *box );
 bra.b    albox_puta0
albox_get_size:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_avis            ; WORD lbox_get_avis( void *box );
 move.w   d0,(a4)
 rts
albox_get_udata:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_udata           ; void *lbox_get_udata( void *box );
 bra.b    albox_puta0
albox_get_first:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_afirst          ; WORD lbox_get_afirst( void *box );
 move.w   d0,(a4)
 rts
albox_get_s_idx:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_slct_idx        ; WORD lbox_get_slct_idx( void *box );
 move.w   d0,(a4)
 rts
albox_get_items:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_items           ; SCROLL_ITEM *lbox_get_items( void *box )
 bra.b    albox_puta0
albox_get_item:
;movea.l  a0,a0                    ; addrin[0]: box
 move.w   (a3),d0                  ; intin[1]: n
 jsr      lbox_get_item            ; SCROLL_ITEM *lbox_get_item( void *box, WORD n );
 bra.b    albox_puta0
albox_get_s_item:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_slct_item       ; SCROLL_ITEM *lbox_get_slct_item( void *box )
 bra.b    albox_puta0
albox_get_idx:
;movea.l  a0,a0                    ; addrin[0]: box
 movea.l  (a5)+,a1                 ; addrin[1]: search
 jsr      lbox_get_idx             ; WORD lbox_get_idx( SCROLL_ITEM *items,
                                   ;    SCROLL_ITEM *search );
 move.w   d0,(a4)
 rts
albox_get_bvis:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_bvis            ; WORD lbox_get_bvis( void *box );
 move.w   d0,(a4)
 rts
albox_get_bentries:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_bentries        ; WORD lbox_get_bentries( void *box );
 move.w   d0,(a4)
 rts
albox_get_bfirst:
;movea.l  a0,a0                    ; addrin[0]: box
 jsr      lbox_get_bfirst          ; WORD lbox_get_bfirst( void *box );
 move.w   d0,(a4)
 rts
albox_puta0:
 move.l   a0,(a6)                  ; addrout[0]:
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 175 = lbox_set

dsp_lbox_set:
 move.w   (a3)+,d0                 ; intin[0]: Funktionsnummer
 cmp.w    #LBOX_BSCROLL_TO,d0
 bhi      albox_set_exit

 movea.l  (a5)+,a0                 ; addrin[0]: box
 move.w   #1,(a4)                  ; kein Fehler
 add.w    d0,d0
 move.w   albox_set_tab(pc,d0.w),d0
 jmp      albox_set_tab(pc,d0.w)

albox_set_tab:
 DC.W  albox_set_slider-albox_set_tab
 DC.W  albox_set_items-albox_set_tab
 DC.W  albox_free_items-albox_set_tab
 DC.W  albox_free_list-albox_set_tab
 DC.W  albox_scroll_to-albox_set_tab
 DC.W  albox_set_bsldr-albox_set_tab
 DC.W  albox_set_bentries-albox_set_tab
 DC.W  albox_bscroll_to-albox_set_tab

albox_set_slider:
 move.w   (a3),d0                  ; intin[1]: first
;move.l   a0,a0                    ; box
 movea.l  (a5),a1                  ; addrin[1]: rect
 jmp      lbox_set_asldr           ; void lbox_set_asldr( void *box, WORD first,
;                                                      GRECT *rect );
albox_set_items:
;move.l   a0,a0                    ; box
 movea.l  (a5),a1                  ; items
 jmp      lbox_set_items           ; void lbox_set_items( void *box,
;                                                 SCROLL_ITEM *items );
albox_free_items:
;move.l   a0,a0                    ; box
 jmp      lbox_free_items          ; void lbox_free_items( void *box );
;
albox_free_list:
;move.l   a0,a0                    ; items
 jmp      lbox_free_list           ; void lbox_free_list( SCROLL_ITEMS *items );
;
albox_scroll_to:
 move.w   (a3),d0                  ; intin[1]: first
;movea.l  a0,a0                    ; addrin[0]: box
 movea.l  (a5)+,a1                 ; addrin[1]: box_rect
 move.l   (a5),-(sp)               ; addrin[2]: slider_rect
 jsr      lbox_ascroll_to          ; void lbox_ascroll_to( void *box,
                                   ;    WORD first, GRECT *box_rect,
                                   ;    GRECT *slider_rect );
 addq.l   #4,sp
 move.w   #1,(a4)                  ; kein Fehler
 rts
;
albox_set_bsldr:
 move.w   (a3),d0                  ; intin[1]: first
;movea.l  a0,a0                    ; addrin[0]: box
;movea.l  (a5)+,a1                 ; addrin[1]: rect
 jmp      lbox_set_bsldr           ; void lbox_set_bsldr( void *box,
;                                       WORD first, GRECT *rect );
;
albox_set_bentries:
 move.w   (a3),d0                  ; intin[1]: entries
;movea.l  a0,a0                    ; addrin[0]: box
 jmp      lbox_set_bentries        ; void lbox_set_bentries( void *box,
;                                       WORD entries );
;
albox_bscroll_to:
 move.w   (a3)+,d0                 ; intin[1]: first
;movea.l  a0,a0                    ; addrin[0]: box
 movea.l  (a5)+,a1                 ; addrin[1]: box_rect
 move.l   (a5),-(sp)               ; addrin[2]: slider_rect
 jsr      lbox_bscroll_to          ; void lbox_bscroll_to( void *box,
;                                       WORD first, GRECT *box_rect,
;                                       GRECT *slider_rect );
 addq.l   #4,sp
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 180 = fnts_create

dsp_fnts_create:
 move.w   (a3)+,d0                 ; intin[0]: vdi_handle
 move.w   (a3)+,d1                 ; intin[1]: no_fonts
 move.w   (a3)+,d2                 ; intin[2]: font_flags
 move.w   (a3),-(sp)               ; intin[3]: dialog_flags

 move.l   (a5)+,a0                 ; addrin[0]: sample
 move.l   (a5)+,a1                 ; addrin[1]: opt_button

 jsr      fnts_create              ; void *fnts_create( WORD vdi_handle,
                                   ;              WORD no_fonts, WORD font_flags,
                                   ;              WORD dialog_flags, BYTE *sample,
                                   ;              BYTE *opt_button );
 addq.l   #2,sp

 move.l   a0,(a6)                  ; addrout[0]:
 move.w   #1,(a4)                  ; kein Fehler
 rts

* case 181 = fnts_delete

dsp_fnts_delete:
 move.w   (a3),d0                  ; intin[0]: vdi_handle
 movea.l  (a5),a0                  ; addrin[0]: fnt_dialog

 jsr      fnts_delete              ; WORD fnts_delete( void *fnt_dialog,
                                   ;         WORD vdi_handle );

 move.w   d0,(a4)                  ; intout[0]:
 rts

* case 182 = fnts_open

dsp_fnts_open:
 lea      14(a3),a3                ; 7 * 2, Zeiger auf intin[7]

 move.l   (a3),-(sp)               ; intin[7/8]: ratio
 move.l   -(a3),-(sp)              ; intin[5/6]: pt
 move.l   -(a3),-(sp)              ; intin[3/4]: id
 move.w   -(a3),d2                 ; intin[2]: y
 move.w   -(a3),d1                 ; intin[1]: x
 move.w   -(a3),d0                 ; intin[0]: button_flags
 movea.l  (a5),a0                  ; addrin[0]: fnt_dialog

 jsr      fnts_open                ; WORD fnts_open( void *fnt_dialog,
                                   ;         WORD button_flags, WORD x, WORD y,
                                   ;         LONG id, LONG pt, LONG ratio);
 lea      12(sp),sp

 move.w   d0,(a4)                  ; intout[0]:
 rts
                  
* case 183 = fnts_close

dsp_fnts_close:
 pea      4(a4)                    ; intout[2] = y
 lea      2(a4),a1                 ; intout[1] = x
 movea.l  (a5),a0                  ; addrin[0]: fnt_dialog
 jsr      fnts_close               ; WORD fnts_close( void *fnt_dialog );
 addq.l   #4,sp
 move.w   d0,(a4)                  ; intout[0]:
 rts

* case 184 = fnts_get

dsp_fnts_get:
 movea.l  (a5)+,a0                 ; addrin[0]: fnt_dialog
 move.w   (a3)+,d1                 ; intin[0]: function number
 move.l   (a3),d0                  ; intin[1/2]: id
 tst.w    d1                       ; subfn
 beq.b    dsp_fnts_get_no_styles
 subq.w   #1,d1
 beq.b    dsp_fnts_get_style

 subq.w   #1,d1
 beq.b    dsp_fnts_get_name
 subq.w   #1,d1
 beq.b    dsp_fnts_get_info
fnts_err:
 clr.w    (a4)
 rts

dsp_fnts_get_no_styles:
 jsr      fnts_get_no_styles       ; WORD fnts_get_no_styles
                                   ;         ( void *fnt_dialog,
                                   ;         LONG id );
 move.w   d0,(a4)
 rts

dsp_fnts_get_style:
 move.w   (a3),d1                  ; intin[3]: index

 jsr      fnts_get_style           ; LONG fnts_get_style( void *fnt_dialog,
                                   ;                   LONG id, WORD index );
 move.l   d0,(a4)                  ; intout[0/1]:
 rts

dsp_fnts_get_name:
 movea.l  (a5)+,a1                 ; addrin[1]: full_name
 move.l   4(a5),-(sp)              ; addrin[3]: style_name
 move.l   (a5),-(sp)               ; addrin[2]: family_name

 jsr      fnts_get_name            ; WORD fnts_get_name(
                                   ;         void *fnt_dialog,
                                   ;         LONG id, BYTE *full_name,
                                   ;         BYTE *family_name,
                                   ;         BYTE *style_name );
 addq.l   #8,sp
 move.w   d0,(a4)
 rts
                              
dsp_fnts_get_info:
 pea      4(a4)                    ; &intout[2]: outline
 lea      2(a4),a1                 ; &intout[1]: mono

 jsr      fnts_get_info            ; WORD fnts_get_info(
                                   ;              void *fnt_dialog,
                                   ;              LONG id, WORD *mono,
                                   ;              WORD *outline );
 addq.l   #4,sp
 move.w   d0,(a4)                  ; intout[0]: index oder 0 (Fehler)
 rts

* case 185 = fnts_set


dsp_fnts_set:
 movea.l  (a5)+,a0                 ; addrin[0]: fnt_dialog
 move.w   (a3)+,d0                 ; intin[0]: Funktionsnummer
 beq.b    dsp_fnts_add             ; 0: fnts_add
 subq.w   #1,d0
 beq.b    dsp_fnts_remove          ; 1: fnts_remove
 subq.w   #1,d0
 beq.b    dsp_fnts_update          ; 2: fnts_update
 clr.w    (a4)
 rts

dsp_fnts_add:
;movea.l  (a5)+,a0                 ; addrin[0]: fnt_dialog
 movea.l  (a5),a1                  ; addrin[1]: user_fonts

 jsr      fnts_add                 ; WORD fnts_add( void *fnt_dialog,
                                   ;    FNTS_ITEM *user_fonts );

 move.w   d0,(a4)
 rts

dsp_fnts_remove:
;movea.l  (a5),a0                  ; addrin[0]: fnt_dialog
 jsr      fnts_remove              ; void fnts_remove( void *fnt_dialog );
 move.w   #1,(a4)                  ; OK
 rts

dsp_fnts_update:
;movea.l  (a5)+,a0                 ; addrin[0]: fnt_dialog
 move.w   (a3)+,d0                 ; intin[1]: button_flags
 move.l   (a3)+,d1                 ; intin[2/3]: id
 move.l   (a3)+,d2                 ; intin[4/5]: pt
 move.l   (a3),-(sp)               ; intin[6/7]: ratio

 jsr      fnts_update              ; WORD fnts_update( void *fnt_dialog,
                                   ;         WORD button_flags,
 addq.l   #4,sp                    ;         LONG id, LONG pt, LONG ratio );
 move.w   d0,(a4)
 rts



* case 186 = fnts_evnt

dsp_fnts_evnt:
 pea      14(a4)                   ; &intout[7/8]: ratio
 pea      10(a4)                   ; &intout[5/6]: pt
 pea      6(a4)                    ; &intout[3/4]: id
 pea      4(a4)                    ; &intout[2]: check_boxes
 pea      2(a4)                    ; &intout[1]: button

 movea.l  (a5)+,a0                 ; addrin[0]: fnt_dialog
 movea.l  (a5),a1                  ; addrin[1]: events

 jsr      fnts_evnt                ; WORD fnts_evnt( void *fnt_dialog,
                                   ;         EVNT *events, WORD *button,
                                   ;         WORD *check_boxes, LONG *id,
                                   ;         LONG *pt, LONG *ratio );
 lea      20(sp),sp

 move.w   d0,(a4)                  ; intout[0]:
 rts

* case 187 = fnts_do

dsp_fnts_do:
 move.l   (a5),a0                  ; addrin[0]: fnt_dialog

 pea      12(a4)                   ; &intout[6/7]      (ratio)
 pea      8(a4)                    ; &intout[4/5]      (pt)
 pea      4(a4)                    ; &intout[2/3]      (id)
 lea      2(a4),a1                 ; &intout[1]        (check_boxes)

 move.w   (a3)+,d0                 ; intin[0]: button_flags
 move.l   (a3)+,d1                 ; intin[1/2]: id_in
 move.l   (a3)+,d2                 ; intin[3/4]: pt_in
 move.l   (a3),-(sp)               ; intin[5/6]: ratio_in

 jsr      fnts_do                  ; WORD fnts_do( void *fnt_dialog,
                                   ;         WORD button_flags,
                                   ;         LONG id_in, LONG pt_in,
                                   ;         LONG ratio_in, WORD *check_boxes,
                                   ;         LONG *id, LONG *pt, LONG *ratio );

 lea      16(sp),sp
 move.w   d0,(a4)                  ; intout[0]: button
 rts

* case 190 = fslx_open

dsp_fslx_open:
 lea      20(a5),a5                ; addrin+5
 lea      10(a3),a3                ; intin+5

 move.w   (a3),-(sp)               ; intin[5]:    flags
 move.w   -(a3),-(sp)              ; intin[4]:    sort_mode
 move.l   (a5),-(sp)               ; addrin[5]:   paths
 move.l   -(a5),-(sp)              ; addrin[4]:   filter
 move.l   -(a5),-(sp)              ; addrin[3]:   pattern
 move.w   -(a3),-(sp)              ; intin[3]:    fnamelen
 move.l   -(a5),-(sp)              ; addrin[2]:   fname
 move.w   -(a3),d2                 ; intin[2]:    pathlen
 move.l   -(a5),-(sp)              ; addrin[1]:   path
 lea      (a4),a1                  ; &intout[4]:  whdl
 move.w   -(a3),d1                 ; intin[1]:    y
 move.w   -(a3),d0                 ; intin[0]:    x
 move.l   -(a5),a0                 ; addrin[0]:   title
 jsr      fslx_open
 lea      26(sp),sp
 move.l   a0,(a6)                  ; addrout[0]
 rts

* case 191 = fslx_close

dsp_fslx_close:
 move.l   (a5),a0                  ; addrin[0]:   fsd
 jsr      fslx_close
 move.w   d0,(a4)
 rts

* case 192 = fslx_getnxtfile

dsp_fslx_getnxtfile:
 move.l   (a5)+,a0                 ; addrin[0]:   fsd
 move.l   (a5),a1                  ; addrin[0]:   fname
 jsr      fslx_getnxtfile
 move.w   d0,(a4)
 rts

* case 193 = fslx_evnt

dsp_fslx_evnt:
 pea      (a6)                     ; &addrout[0]: pattern
 pea      6(a4)                    ; &intout[3]:  sort_mode
 pea      4(a4)                    ; &intout[2]:  nfiles
 pea      2(a4)                    ; &intout[1]:  button
 move.l   (a5)+,a0                 ; addrin[0]:   fsd
 move.l   (a5)+,a1                 ; addrin[1]:   events
 move.l   4(a5),-(sp)              ; addrin[3]:   fname
 move.l   (a5),-(sp)               ; addrin[2]:   path
 jsr      fslx_evnt
 lea      24(sp),sp
 move.w   d0,(a4)
 rts
 
* case 194 = fslx_do

dsp_fslx_do:
 lea      20(a5),a5                ; addrin+5

 pea      4(a6)                    ; &addrout[1]: pattern
 pea      4(a4)                    ; &intout[2]:  nfiles
 pea      2(a4)                    ; &intout[1]:  button
 move.w   (a3)+,d0                 ; intin[0]:    pathlen
 move.w   (a3)+,d1                 ; intin[1]:    fnamelen
 move.w   (a3)+,6(a4)              ; intin[2]:    ->sort_mode
 move.w   (a3),d2                  ; intin[3]:    flags

 pea      6(a4)                    ; &intout[3]:  sort_mode->
 move.l   (a5),-(sp)               ; addrin[5]:   paths

 move.l   -(a5),-(sp)              ; addrin[4]:   filter
 move.l   -(a5),-(sp)              ; addrin[3]:   patterns
 move.l   -(a5),-(sp)              ; addrin[2]:   fname
 move.l   -(a5),a1                 ; addrin[1]:   path
 move.l   -(a5),a0                 ; addrin[0]:   title
 jsr      fslx_do
 lea      32(sp),sp
 move.l   a0,(a6)                  ; addrout[0]:  fsd
 move.w   #1,(a4)
 rts

* case 195 = fslx_set

dsp_fslx_set:
 move.l   a4,a0                    ; &intout[0]:  oldval->
 move.w   (a3)+,d0                 ; intin[0]:    subfn
 move.w   (a3),d1                  ; intin[1]:    flags
 jsr      fslx_set
 move.w   d0,(a4)
 rts

* case 200 = pdlg_create

pdlg_slbname:  DC.B "PDLG.SLB",0
     EVEN
dsp_pdlg_create:
 move.l   a0,a5                    ; a0 retten (AESPB *)
 clr.l    -(sp)                    ; dummy fuer Fkt.-Zeiger
 clr.l    -(sp)                    ; dummy fuer Handle
 lea      (sp),a0
 pea      4(a0)                    ; Fuer Rueckgabe des Fkt.-Zeigers
 pea      (a0)                     ; Fuer Rueckgabe des Handles
 clr.l    -(sp)                    ; minimale Version: 0
 clr.l    -(sp)                    ; kein Suchpfad
 pea      pdlg_slbname(pc)         ; Name
 gemdos   Slbopen
 adda.w   #30,sp
 move.l   a5,a0                    ; a0 zurueck (AESPB *)
 tst.l    d0                       ; SLB geladen ?
 bge      aes_dispatcher           ; Hurra, wir versuchen es noch einmal
 clr.l    (a6)                     ; addrout[0]: NULL
 clr.w    (a4)                     ; Fehler
 rts

* default

dsp_error:
 moveq    #0,d0
 move.w   (a1),d0                  ; contrl[0]
 move.l   d0,-(sp)
 move.l   sp,a0                    ; Parameter
 moveq    #1,d1                    ; Default-Button
 lea      al_aeserr(pc),a1         ; Text
 bsr      do_aes_alert
 addq.l   #4,sp
 move.w   #-1,(a4)
 rts


**********************************************************************
*
* void reset_mouse( void )
*
* Ueberprueft alle lokalen Hide- Counter und schaltet ggf. den
* Mauszeiger wieder ein.
*

reset_mouse:
 moveq    #0,d0
 lea      applx,a1
 moveq    #NAPPS-1,d1
rstm_tloop:
 move.l   (a1)+,d2                 ; Slot unbenutzt
 ble.b    rstm_tnext
 move.l   d2,a0
 add.w    ap_mhidecnt(a0),d0
rstm_tnext:
 dbra     d1,rstm_tloop
 cmp.w    moff_cnt,d0
 beq      rstm_ende                ; Synchronisation OK
 tst.w    d0
 beq      mouse_immed              ; soll sichtbar sein, ist aber nicht
 move.w   d0,-(sp)
 jsr      mouse_off
 move.w   (sp)+,moff_cnt
rstm_ende:
 rts


**********************************************************************
*
* void set_mouse_app(a0 = APPL *ap)
*
* Setzt neue mausbesitzende APP und schaltet ggf. den Mauszeiger um
*

set_mouse_app:
 move.l   mouse_app,d1
 move.l   a0,mouse_app
 bgt.b    sma_apok
 move.l   applx+4,d1
sma_apok:
 cmp.l    a0,d1
 beq.b    sma_ende
 lea      ap_act_mouse(a0),a0
 jmp      set_mform                ; Mausform aendern!
sma_ende:
 rts


**********************************************************************
*
* PUREC void graf_mouse( WORD typ, void *data)
*
* void graf_mouse(d0 = typ, a0 = void *data)
*
*      0 - arrow
*      1 - text cursor
*      2 - busy bee
*      3 - hand with pointing finger
*      4 - flat hand, extended fingers
*      5 - thin cross hair
*      6 - thich cross hair
*      7 - outline cross hair
*    255 - mouse form stored in gr_mofaddr
*    256 - hide mouse form
*    257 - show mouse form
*    ( MultiTOS: )
*    258 - save current mouse form
*    259 - restore to the last saved mouse form
*    260 - restore to previous mouse form
*

gm_spec:
 move.l   d1,a0
 ext.w    d0
 cmpi.w   #4,d0
 bhi      gm_ende                  ; Fehler!
 add.w    d0,d0                    ; 256 abziehen und Wortzugriff
 move.w   gm_jmptab(pc,d0.w),d0
 jmp      gm_jmptab(pc,d0.w)
gm_jmptab:
 DC.W     gm_hide-gm_jmptab
 DC.W     gm_show-gm_jmptab
 DC.W     gm_save-gm_jmptab
 DC.W     gm_rest-gm_jmptab
 DC.W     gm_prev-gm_jmptab

* case 256:
gm_hide:
 addq.w   #1,ap_mhidecnt(a0)       ; aus Sicherheitsgruenden lokaler Zaehler
 jmp      mouse_off

* case 257:
gm_show:
 subq.w   #1,ap_mhidecnt(a0)       ; aus Sicherheitsgruenden lokaler Zaehler
 jmp      mouse_on

* case 258:
gm_save:
 lea      ap_act_mouse(a0),a1      ; lokale aktuelle Mausdaten ...
 lea      ap_svd_mouse(a0),a2      ; ... in den Rettungspuffer kopieren
 moveq    #18-1,d2
gm_loop3:
 move.l   (a1)+,(a2)+
 dbra     d2,gm_loop3
 move.w   (a1),(a2)                ; 37 Worte von act_mouse -> prv_mouse

* case 259:
gm_rest:
 lea      ap_svd_mouse(a0),a0      ; gerettete Mausform
 bra      gm_form

* case 260:
gm_prev:
 lea      ap_act_mouse(a0),a1      ; lokale aktuelle Mausdaten ...
 lea      ap_prv_mouse(a0),a2      ; ... mit den vorherigen austauschen
 move.l   a1,a0                    ; aktuelle sind auch zukuenftige
 moveq    #37-1,d2
gm_loop4:
 move.w   (a2),d0
 move.w   (a1),(a2)+
 move.w   d0,(a1)+
 dbra     d2,gm_loop4              ; 37 Worte von act_mouse -> prv_mouse
 bra      gm_setform


graf_mouse:
 move.l   a2,-(sp)
 bsr.b    _graf_mouse
 move.l   (sp)+,a2
 rts
_graf_mouse:
 bclr     #15,d0                   ; MultiTOS- Feature ist hier unnoetig
 move.l   act_appl,d1
 bgt.b    gm_apok
 move.l   applx+4,d1               ; act_appl ungueltig: SCRENMGR nehmen
gm_apok:
* Sonderfunktionen abtesten
 cmpi.w   #255,d0
 bhi      gm_spec                  ; Spezialfunktion
 beq.b    gm_form                  ; a0 zeigt auf die Daten
 mulu     #74,d0                   ; 37 Worte = 74 Bytes pro Daten
 lea      mouseforms(pc,d0.w),a0
* a0 enthaelt jetzt die neue Mausform
* Die aktuelle Mausform wird zur vorherigen
gm_form:
 move.l   d1,a1
 lea      ap_prv_mouse(a1),a2
 lea      ap_act_mouse(a1),a1
 moveq    #18-1,d2
gm_loop1:
 move.l   (a1)+,(a2)+
 dbra     d2,gm_loop1
 move.w   (a1),(a2)                ; 37 Worte von act_mouse -> prv_mouse
* Die neue Mausform wird zur aktuellen
 move.l   d1,a2
 lea      ap_act_mouse(a2),a2
 move.l   a0,a1
 moveq    #18-1,d2
gm_loop2:
 move.l   (a1)+,(a2)+
 dbra     d2,gm_loop2
 move.w   (a1),(a2)                ; 37 Worte von neu -> act_mouse
gm_setform:
* Neue Mausform sichtbar, wenn wir mausbesitzend sind
 cmp.l    mouse_app,d1
 bne      gm_ende
;move.l   a0,a0
 jmp      set_mform
gm_ende:
 rts


mouseforms:
marrow_data:
 DC.W     0    ; xhot
 DC.W     0    ; yhot
 DC.W     1    ; planes
 DC.W     0    ; bg_col
 DC.W     1    ; fg_col
 DC.W     %1100000000000000
 DC.W     %1110000000000000
 DC.W     %1111000000000000
 DC.W     %1111100000000000
 DC.W     %1111110000000000
 DC.W     %1111111000000000
 DC.W     %1111111100000000
 DC.W     %1111111110000000
 DC.W     %1111111111000000
 DC.W     %1111111111100000
 DC.W     %1111111000000000
 DC.W     %1110111100000000
 DC.W     %1100111100000000
 DC.W     %1000011110000000
 DC.W     %0000011110000000
 DC.W     %0000001110000000
 DC.W     %0000000000000000
 DC.W     %0100000000000000
 DC.W     %0110000000000000
 DC.W     %0111000000000000
 DC.W     %0111100000000000
 DC.W     %0111110000000000
 DC.W     %0111111000000000
 DC.W     %0111111100000000
 DC.W     %0111111110000000
 DC.W     %0111110000000000
 DC.W     %0110110000000000
 DC.W     %0100011000000000
 DC.W     %0000011000000000
 DC.W     %0000001100000000
 DC.W     %0000001100000000
 DC.W     %0000000000000000

 DC.W     7
 DC.W     7
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0111111001111110
 DC.W     %0111111111111110
 DC.W     %0000011111100000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000001111000000
 DC.W     %0000011111100000
 DC.W     %0111111111111110
 DC.W     %0111111001111110
 DC.W     %0011110000111100
 DC.W     %0000011001100000
 DC.W     %0000001111000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000000110000000
 DC.W     %0000001111000000
 DC.W     %0000011001100000
 DC.W     %0011110000111100

mbee_data:
 DC.W     8
 DC.W     8
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0001110001111110
 DC.W     %0001110011111111
 DC.W     %0001110011111111
 DC.W     %1110111111111111
 DC.W     %1111111111111111
 DC.W     %1111111111111111
 DC.W     %0011111111111110
 DC.W     %0011111111111100
 DC.W     %0111111111111110
 DC.W     %1111111111111110
 DC.W     %1111111111111111
 DC.W     %1111111111111111
 DC.W     %1111111111111111

 DC.W     %1111111111111111
 DC.W     %1111111011111111
 DC.W     %0111110000111110
 DC.W     %0000100000000000
 DC.W     %0000100000111100
 DC.W     %0000000001100010
 DC.W     %0000011011000010
 DC.W     %1100011010000100
 DC.W     %0001100110001010
 DC.W     %0001101101010100
 DC.W     %0000011011100000
 DC.W     %0001110101011000
 DC.W     %0011001111111100
 DC.W     %0110000101100000
 DC.W     %0100001011011110
 DC.W     %0100010011011000
 DC.W     %0100101001010110
 DC.W     %0011010000010100
 DC.W     %0000000000000000

 DC.W     0
 DC.W     0
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0011000000000000
 DC.W     %0111110000000000
 DC.W     %0111111000000000
 DC.W     %0001111110000000
 DC.W     %0000111111000000
 DC.W     %0011111111111000
 DC.W     %0011111111111100
 DC.W     %0111111111111100
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %0111111111111111
 DC.W     %0011111111111111
 DC.W     %0001111111111111
 DC.W     %0000111111111111
 DC.W     %0000001111111111
 DC.W     %0000000011111111
 DC.W     %0011000000000000
 DC.W     %0100110000000000
 DC.W     %0110001000000000
 DC.W     %0001100110000000
 DC.W     %0000110001000000
 DC.W     %0011001011111000
 DC.W     %0010100100000100
 DC.W     %0110011000100100
 DC.W     %1001001111000010
 DC.W     %1100111101000010
 DC.W     %0111110001000011
 DC.W     %0010000000100001
 DC.W     %0001000000000001
 DC.W     %0000110001000001
 DC.W     %0000001110000000

 DC.W     %0000000011000000

mflat_data:
 DC.W     8
 DC.W     8
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0000001100000000
 DC.W     %0001111110110000
 DC.W     %0011111111111000
 DC.W     %0011111111111100
 DC.W     %0111111111111110
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %0111111111111111
 DC.W     %0111111111111111
 DC.W     %1111111111111111
 DC.W     %1111111111111111
 DC.W     %0111111111111111
 DC.W     %0011111111111111
 DC.W     %0000111111111111
 DC.W     %0000000111111111
 DC.W     %0000000000111111
 DC.W     %0000001100000000
 DC.W     %0001110010110000
 DC.W     %0010010001001000
 DC.W     %0010001000100100
 DC.W     %0111000100010010
 DC.W     %1001100010000010
 DC.W     %1000010000000010
 DC.W     %0100001000000001
 DC.W     %0111000000000001
 DC.W     %1001100000000001
 DC.W     %1000010000000001
 DC.W     %0100000000000000
 DC.W     %0011000000000000
 DC.W     %0000111000000000
 DC.W     %0000000111000000
 DC.W     %0000000000110000

 DC.W     7
 DC.W     7
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %1111111011111110
 DC.W     %1111000000011110
 DC.W     %1111111011111110
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0111111111111100
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000100000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000

 DC.W     7
 DC.W     7
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %1111111111111110
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0111111111111100
 DC.W     %0111111111111100
 DC.W     %0111111111111100
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000001110000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000

 DC.W     7
 DC.W     7
 DC.W     1
 DC.W     0
 DC.W     1
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000011011000000
 DC.W     %0000011011000000
 DC.W     %0000011011000000
 DC.W     %1111111011111110
 DC.W     %1111111011111110
 DC.W     %1100000000000110
 DC.W     %1111111011111110
 DC.W     %1111111011111110
 DC.W     %0000011011000000
 DC.W     %0000011011000000

 DC.W     %0000011011000000
 DC.W     %0000011111000000
 DC.W     %0000011111000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000001110000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0111111011111100
 DC.W     %0100000000000100
 DC.W     %0111111011111100
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001010000000
 DC.W     %0000001110000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000


**********************************************************************
*
* int chg_aes_fn(d0 = WORD n, a0 = void *f)
*
* Aendert eine AES-Funtion. Ist der Zeiger NULL, wird die error-
* Routine eingeklinkt.
*

chg_aes_fn:
 movem.l  d6/d7/a5/a6,-(sp)
 move.w   d0,d7                    ; d7 = nr
 move.l   a0,d1
 bne.b    caf_f
 lea      dsp_error(pc),a0
caf_f:
 move.l   a0,a6                    ; a6 = f
 sub.w    fn_rellen,d0
 bcc.b    caf_abs

;
; relative Tabelle modifizieren, nach unten um <d6> Eintraege vergroessern
;

 neg.w    d0
 move.w   d0,d6                    ; neue Nummer - alte hoechste Nummer
; neuen Block allozieren
 moveq    #0,d0
 move.w   d6,d0
 add.w    fn_abslen,d0
 add.l    d0,d0
 add.l    d0,d0
 jsr      smalloc
 beq      caf_err                  ; Zuwenig Speicher
 move.l   d0,a5                    ; Speicherblock-Adresse merken
 move.l   _basepage,a1             ; Neuer Eigner: AES
;move.l   a0,a0                    ; memadr
 jsr      Mchgown                  ; Eigner des Blocks wechseln
; relative Eintraege in abs. wandeln und kopieren
 move.l   a5,a0
 move.l   a6,(a0)+                 ; neue Funktion
 addq.w   #1,d7                    ; ab naechster kopieren
 move.w   d6,d0
 subq.w   #1,d0                    ; eine weniger kopieren
 lea      aesfn_tab(pc),a1
 add.w    d7,a1
 add.w    d7,a1
 bra.b    caf_begloop1
caf_loop1:
 lea      aesfn_tab,a2
 add.w    (a1)+,a2
 move.l   a2,(a0)+
caf_begloop1:
 dbra     d0,caf_loop1
; alte absolute Tabelle dahinterhaengen
 move.l   fn_abstab,a1
 move.w   fn_abslen,d0
 bra.b    caf_begloop2
caf_loop2:
 move.l   (a1)+,(a0)+
caf_begloop2:
 dbra     d0,caf_loop2
 move.w   fn_abslen,d0
 beq.b    caf_noold
 move.l   fn_abstab,a0
 jsr      smfree
caf_noold:
 move.l   a5,fn_abstab
 add.w    d6,fn_abslen
 sub.w    d6,fn_rellen
 bra.b    caf_ok

;
; absolute Tabelle modifizieren
;

caf_abs:
 sub.w    fn_rellen,d7
 cmp.w    fn_abslen,d7
 bcs.b    caf_chg                  ; einfach nur umsetzen

;
; absolute Tabelle verlaengern
;

 moveq    #0,d0
 move.w   d7,d0
 addq.w   #1,d0                    ; Funktionsnummer 8: Eintraege 0..7
 add.l    d0,d0
 add.l    d0,d0
 jsr      smalloc
 beq.b    caf_err
 move.l   d0,a5                    ; Speicherblock-Adresse merken
 move.l   _basepage,a1             ; Neuer Eigner: AES
;move.l   a0,a0                    ; memadr
 jsr      Mchgown                  ; Eigner des Blocks wechseln
 move.l   a5,a0
 move.l   fn_abstab,a1
 move.w   fn_abslen,d0
 bra.b    caf_begloop3
caf_loop3:
 move.l   (a1)+,(a0)+
caf_begloop3:
 dbra     d0,caf_loop3
 move.l   a5,a1
 add.w    d7,a1
 add.w    d7,a1
 add.w    d7,a1
 add.w    d7,a1
caf_loop4:
 cmpa.l   a1,a0
 bcc.b    caf_setit
 move.l   #dsp_error,(a0)+
 bra.b    caf_loop4

caf_setit:
 move.l   a6,(a0)
 move.w   fn_abslen,d0
 beq.b    caf_noold2
 move.l   fn_abstab,a0
 jsr      smfree
caf_noold2:
 move.l   a5,fn_abstab
 addq.w   #1,d7
 move.w   d7,fn_abslen
 bra.b    caf_ok

; nur modifizieren

caf_chg:
 move.l   fn_abstab,a0
 add.w    d7,a0
 add.w    d7,a0
 add.w    d7,a0
 add.w    d7,a0
 move.l   a6,(a0)                  ; umsetzen
caf_ok:
 moveq    #1,d0
 bra.b    caf_ende
caf_err:
 moveq    #0,d0
caf_ende:
 movem.l  (sp)+,d7/d6/a6/a5
 rts


**********************************************************************
*
* int appl_find(a0 = char *apname)
*
* Neu: ermittelt im Fall <apname == "?\0\n"> den Namen von APP #n.
*
* Neu (AES 4.0): appl_find( NULL ) => act_appl->ap_id
*

appl_find:
 move.l   a0,d0
; Zeiger == NULL ?
 beq.b    appf_act_id              ; GEM 4.0
 swap     d0
 addq.w   #1,d0
; Hiword == -1 ?
 beq      appf_p2a                 ; ProcessID => ap_id
 addq.w   #1,d0
; Hiword == -2 ?
 beq      appf_a2p                 ; ap_id => ProcessID
 move.l   a0,a1
 cmpi.b   #'?',(a1)+
 bne.b    appf_norm
; Name beginnt mit '?'
 move.b   (a1)+,d0                 ; Name "?" ?
 beq.b    appf_id2nam              ; ja, ap_id => Name
 cmpi.b   #'A',d0
 bne.b    appf_norm

 cmpi.b   #'G',(a1)+
 bne.b    appf_norm
 cmpi.b   #'I',(a1)+
 bne.b    appf_norm
 tst.b    (a1)
 bne.b    appf_norm                ; nein, normal suchen
 bra.b    appf_err                 ; appl_find("?AGI") => 0
appf_id2nam:
 move.b   (a1),d0
 ext.w    d0
 cmpi.w   #NAPPS,d0
 bcc.b    appf_err                 ; id nicht 0..15
 lea      applx,a1
 add.w    d0,d0
 add.w    d0,d0
 move.l   0(a1,d0.w),d0
 ble.b    appf_err                 ; ap_id unbelegt
 move.l   d0,a1
 lea      ap_name(a1),a1
 moveq    #8-1,d0
appf_loop:
 move.b   (a1)+,(a0)+
 dbra     d0,appf_loop
 clr.b    (a0)                     ; EOS
 moveq    #1,d0                    ; kein Fehler
 rts
appf_err:
 moveq    #0,d0
 rts
appf_act_id:
 move.l   act_appl,a0
 move.w   ap_id(a0),d0             ; ap_id der aktuellen Applikation
 rts
appf_norm:
;move.l   a0,a0                    ; nach diesem Namen suchen
 bsr      _appl_find
 movea.l  d0,a0                    ; APPL *
 move.l   a0,d0                    ; ungueltig ?
 beq.b    appf_inv                 ; ungueltig, return(-1)
 move.w   ap_id(a0),d0             ; ap_id zurueckgeben
 rts
appf_inv:
 moveq    #-1,d0
 rts

appf_p2a:
 move.w   a0,d0                    ; nach ProcessID suchen
 suba.l   a0,a0                    ; nicht nach PD * suchen
 jmp      srch_process

appf_a2p:
 move.l   a0,d0
 cmpi.w   #NAPPS,d0
 bcc.b    appf_inv                 ; id nicht 0..15
 move.w   d0,a0
 add.w    a0,a0
 add.w    a0,a0                    ; ap_id * 4 fuer Langwortzugriff
 move.l   applx(a0),d0
 ble.b    appf_inv                 ; Slot unbelegt
 move.l   d0,a0
 move.l   ap_pd(a0),d0
 ble.b    appf_inv                 ; Applikation ist kein Prozess
 move.l   d0,a0
 move.w   p_procid(a0),d0
 ble.b    appf_inv                 ; ProcessID ungueltig
 rts


**********************************************************************
*
* int evnt_dclicks(d0 = int val, d1 = int wflag)
*

evnt_dclicks:
 tst.w    d1                       ; lesen ?
 beq.b    evdc_ende                ; ja, nur alten Wert zurueckgeben
 cmpi.w   #4,d0
 bhi.b    evdc_ende                ; ausserhalb des gueltigen Bereichs
 move.w   d0,dclick_val            ; Woertlichen Wert merken
 add.w    d0,d0
 move.w   dclick_tab(pc,d0.w),d0
 ext.l    d0
 divu     ms_per_click,d0
 move.w   d0,dclick_clicks         ; in Clicks umrechnen
evdc_ende:
 move.w   dclick_val,d0
 rts

dclick_tab:
 DC.W     450,330,275,220,165


**********************************************************************
*
* void fatal_err( void )
*
* Ein fataler Fehler fuehrt zum Anhalten des Systems
*

fatal_stack:
 lea      fatal_stack_s(pc),a0
 bra.b    _fatal_err
fatal_w1:
 lea      fatal_win_mems(pc),a0
 bra.b    _fatal_err
fatal_w2:
 lea      fatal_wins(pc),a0
 bra.b    _fatal_err
fatal_err:
 lea      fatal_errs(pc),a0
_fatal_err:
 jmp      halt_system              ; ins BIOS

     IF   COUNTRY=COUNTRY_DE
fatal_errs:    DC.B      '*** FATALER FEHLER IM AES:',0
fatal_win_mems:DC.B      '*** ZUWENIG SPEICHER IN FENSTERVERWALTUNG:',0
fatal_wins:    DC.B      '*** FATALER FEHLER IN FENSTERVERWALTUNG:',0
fatal_stack_s: DC.B      '*** ',$9A,'BERLAUF DES SYSTEMSTAPELS:',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
fatal_errs:    DC.B      '*** FATAL ERROR IN AES:',0
fatal_win_mems:DC.B      '*** INSUFFICIENT MEMORY IN WINDOW MANAGER:',0
fatal_wins:    DC.B      '*** FATAL ERROR IN WINDOW MANAGER:',0
fatal_stack_s: DC.B      '*** SYSTEM STACK OVERFLOW:',0
     ENDIF
     IF   COUNTRY=COUNTRY_FR
fatal_errs:    DC.B      "*** ERREUR FATALE DANS L'AES:",0
fatal_win_mems:DC.B      '*** ZUWENIG SPEICHER IN FENSTERVERWALTUNG:',0
fatal_wins:    DC.B      '*** FATALER FEHLER IN FENSTERVERWALTUNG:',0
fatal_stack_s: DC.B      '*** D',$90,'BORDEMENT DES PILES SYSTEMES:',0
     ENDIF
     EVEN


**********************************************************************
**********************************************************************
*
* SCRAP MANAGER
*


**********************************************************************
*
* long scrp_open( d0 = int omode  )
*
* Oeffnet die Datei 'SCRAP.TXT' mit Open-Modus <omode>
*

_scrp_fname_s:
 DC.B     'SCRAP.TXT',0
 EVEN

scrp_open:
 suba.w   #256,sp
; Dateiname zusammenstellen
 lea      scrp_dir,a1
 lea      (sp),a0
scrp_op_loop1:
 move.b   (a1)+,(a0)+
 bne.b    scrp_op_loop1
 lea      _scrp_fname_s(pc),a1
 subq.l   #1,a0
 cmpi.b   #92,-1(a0)         ; Pfad korrekt abgeschlossen?
 beq.b    scrp_op_loop2       ; ja
 move.b   #92,(a0)+          ; nein, Backslash ergaenzen
scrp_op_loop2:
 move.b   (a1)+,(a0)+
 bne.b    scrp_op_loop2
; Oeffnen
 move.w   d0,-(sp)            ; omode
 pea      2(sp)               ; path
 move.w   #$3d,-(sp)          ; gemdos Fopen
 trap     #1
 adda.w   #8+256,sp
 rts


**********************************************************************
*
* void scrp_cpy( a0 = char *data, d0.l = long len )
*
* Schreibt <len> Bytes ab Adresse <data> nach SCRAP.TXT
*

scrp_cpy:
 move.l   a0,-(sp)
 move.l   d0,-(sp)
 move.w   #O_CREAT+O_TRUNC+O_WRONLY,d0  ; wie Fcreate()
 bsr.b    scrp_open
 tst.l    d0
 bmi.b    scrp_cpy_ende       ; Fehler beim Oeffnen
 move.w   d0,-(sp)            ; Handle
 move.w   #$40,-(sp)          ; gemdos Fwrite
 trap     #1
 move.w   #$3e,(sp)           ; gemdos Fclose
 trap     #1
 addq.l   #4,sp
scrp_cpy_ende:
 addq.l   #8,sp
 rts


**********************************************************************
*
* void scrp_pst( a0 = char *data, d0.l = long len )
*
* Liest <len> Bytes aus SCRAP.TXT nach Adresse <data>
*

scrp_pst:
 clr.b    (a0)                ; sicherheitshalber loeschen
 move.l   a0,-(sp)
 move.l   d0,-(sp)
 moveq    #O_RDONLY,d0        ; nur lesen
 bsr.b    scrp_open
 tst.l    d0
 bmi.b    scrp_pst_ende       ; Fehler beim Oeffnen
 move.w   d0,-(sp)            ; Handle
 move.w   #$3f,-(sp)          ; gemdos Fread
 trap     #1
 tst.l    d0
 bmi.b    scrp_pst_err        ; Fehler beim Lesen
 move.l   8(sp),a0            ; Adresse
 clr.b    0(a0,d0.l)          ; End-Byte setzen!
scrp_pst_err:
 move.w   #$3e,(sp)           ; gemdos Fclose
 trap     #1
 addq.l   #4,sp
scrp_pst_ende:
 addq.l   #8,sp
 rts


**********************************************************************
*
* int scrp_read(a0 = char *path)
*

scrp_read:
 lea      scrp_dir,a1
_scrp:
 move.b   (a1)+,(a0)+
 bne.b    _scrp
 moveq    #1,d0                    ; nicht ganz GEM 2.x
 rts



**********************************************************************
*
* void scrp_write( a0 = char *path )
*

scrp_write:
 lea      scrp_dir,a1
 exg      a0,a1
 bra.b    _scrp


**********************************************************************
*
* int scrp_clear( void )
*


allfiles: DC.B "*.*"
null_s:   DC.B 0
     EVEN

scrp_clear:
 lea      scrp_dir,a0
 tst.b    (a0)
 beq.b    scc_ok                   ; kein Verzeichnis angemeldet
scc_loop:
 lea      allfiles(pc),a1
 bsr      add_name
 move.l   d0,-(sp)                 ; Ende merken
scc_clr:
 pea      scrp_dir
 move.w   #$41,-(sp)
 trap     #1                       ; Fdelete
 addq.l   #6,sp
 tst.l    d0
 beq.b    scc_clr
 move.l   (sp)+,a0
 clr.b    (a0)                     ; Scrapdir in den Urzustand
scc_ok:
 moveq    #1,d0                    ; ok
 rts


**********************************************************************
**********************************************************************
*
* SHELL MANAGER
*


**********************************************************************
*
* void shel_read(a0 = char *cmd, a1 = char *tail)
*
* Holt die Zeichenketten aus der aktuellen APPL
*

shel_read:
 move.l   a1,-(sp)
 move.l   act_appl,a2
 move.w   #$80,d0
 lea      ap_cmd(a2),a1
;move.l   a0,a0
 jsr      vmemcpy
 move.l   ap_xtail(a2),d0     ; erweiterte Kommandozeile
 beq.b    shr_nxt             ; ist ungueltig
 move.l   (sp)+,a0
 clr.b    1(a0)
 clr.b    2(a0)
 bra.b    shr_7f              ; erweitert gibt immer $7f, weil zu lang
shr_nxt:
 move.w   #$80,d0
 lea      ap_tail(a2),a1
 move.l   (sp),a0
 jsr      vmemcpy
 move.l   (sp)+,a0
 cmpi.b   #$fe,(a0)           ; Sonder-Tail ?
 bcs.b    shr_ende            ; nein, OK
 bne.b    shr_7f              ; $ff -> $7f
 lea      1(a0),a1            ; $fe -> EOS durch ' ' ersetzen
 lea      128(a0),a2
shr_loop:
 cmpa.l   a1,a2
 bcc.b    shr_7f
 tst.b    (a1)+
 bne.b    shr_loop
 tst.b    (a1)
 beq.b    shr_7f
 move.b   #' ',-1(a1)
 bra.b    shr_loop
shr_7f:
 move.b   #$7f,(a0)
shr_ende:
 moveq    #1,d0
 rts


**********************************************************************
*
* int ap_create(d0 = doex, d1 = int isgr,
*               a0 = char *cmd, a1 = char *tail,
*               long extinf[4])
*
* Aufgerufen von load_all_apps und shel_write(isover=SHW_PARALLEL)
* Mag!X 2.00: Rueckgabe der ap_id, 0 ist nicht moeglich
*
* MagiX 3.0: extinf == NULL:  alte Funktion
*                     sonst:  extinf[0] = Psetlimit (noch ignoriert)
*                             extinf[1] = Prenice   (noch ignoriert)
*                             extinf[2] = Default-Pfad (noch ignoriert)
*                             extinf[3] = Environment
*

ap_create:
 movem.l  d0/d1/d2/a0/a1/a3/a5,-(sp)
 cmpi.w   #NAPPS,appln
 bcc      apc_err                  ; alle APPL-Slots belegt
 tst.w    d0
 beq      apc_err                  ; doex == FALSE

 move.l   #ap_stack,d0
 add.l    sust_len.w,d0
 jsr      smalloc
 beq      apc_err                  ; zuwenig Speicher, return(NULL)
 movea.l  d0,a5

 moveq    #-1,d0
 move.l   d0,-(sp)                 ; kein Env
 pea      leerstring               ; Leerstring, kein Pfad
 pea      8                        ; prgflags: nur text+daten+bss allozieren,
                                   ;  d.h. nur 256 Bytes fuer Basepage
 move.l   #$4b0007,-(sp)           ; Pexec (EXE_XBASE)
 trap     #1
 adda.w   #$10,sp
 tst.l    d0                       ; Basepage
 ble.b    apc_err2                 ; Fehler beim Erstellen
 move.l   d0,a3                    ; a3 = Basepage

 move.l   #pgm_loader,8(a3)        ; p_tbase: Startcode

 move.l   p_procdata(a3),a0
 bset     #0,pr_flags+1(a0)        ; kein Eintrag in u:\proc

/*
; brauchen wir nicht mehr wegen MagiC 5.20 (prgflags.bit3)

 pea      $100                     ; nur Basepage (256 bytes)
 move.l   a3,-(sp)
 move.l   #$4a0000,-(sp)
 trap     #1                       ; gemdos Mshrink
 adda.w   #$c,sp
 tst.l    d0
 bmi.b    apc_err3                 ; Fehler bei Mshrink
*/

* Eigner von APPL und PD wird der PD selbst!
 move.l   a3,-(sp)                 ; neuer Prozess
 move.l   a3,-(sp)                 ; PD
 move.l   #$00330003,-(sp)         ; Sconfig(SC_OWN,...)
 trap     #1
 move.l   a5,4(sp)                 ; APPL
 trap     #1
 lea      12(sp),sp

 move.l   act_pd.l,-(sp)             ; Von hier wird geerbt
 move.l   a3,-(sp)                 ; neuer Prozess
 clr.l    -(sp)                    ; kein Dateiname
 move.l   #$4b0065,-(sp)           ; Pexec (XEXE_INIT), vererben
 trap     #1
 adda.w   #$10,sp

 move.l   a3,d1                    ; Basepage
 lea      pgm_loader(pc),a2        ; Startcode
 lea      leerstring,a1            ; Name
 move.l   sust_len.w,d0            ; Stacklaenge (WORD)
 move.l   a5,a0                    ; APPL,WDG,CONTEXT
 bsr      init_APPL
 move.l   a5,a2
 movem.l  (sp)+,d0/d1/d2/a0/a1/a3/a5
 bra      _shel_write

apc_err3:
 move.l   a3,a0
 jsr      smfree
apc_err2:
 move.l   a5,a0
 jsr      smfree
apc_err:
 movem.l  (sp)+,d0/d1/d2/a0/a1/a3/a5
 moveq    #0,d0
 rts


******************************************************************
*
* void resvldmem(a6 = APPL *ap, d1 = int offs, a3 = char *src,
*                d0 = long len)
*
* 1. Gibt einen evtl. vorhandenen Speicherblock, der bei ap+offs
*    eingetragen ist, frei und traegt NULL ein
* 2. Reserviert <len> Bytes Speicher und traegt, wenn moeglich, den
*    loader (ap_ldpd) als Eigner ein
* 3. Kopiert die <len> Bytes in den neuen Block und traegt ihn in
*    ap+offs ein
*
* Ab 5.4.99 bis 2GB moeglich
*

__resvldmem:
 movem.l  d6/d7,-(sp)
 move.w   d1,d7                    ; d7 = offs
 move.l   d0,d6                    ; d6 = len
 move.l   0(a6,d7.w),d0            ; alter Block ?
 ble.b    __rsm_noold              ; keiner da
 move.l   d0,a0
 jsr      smfree                   ; alten Block freigeben
 clr.l    0(a6,d7.w)               ; und austragen
__rsm_noold:
 move.l   d6,d0
 beq.b    __rsm_ende               ; keinen neuen holen
 jsr      smalloc
 ble.b    __rsm_ende               ; nicht genuegend Speicher
 move.l   d0,0(a6,d7.w)            ; Block merken
 move.l   d0,a0                    ; Ziel
 move.l   a3,a1                    ; Quelle
 move.l   d6,d0                    ; Laenge (32 Bit)
 jsr      memmove
 move.l   ap_ldpd(a6),d1           ; Loader-Prozess
 ble.b    __rsm_ende               ;  ist ungueltig (?!?)
 move.l   d1,-(sp)                 ; Loader-Prozess wird Eigner
 move.l   0(a6,d7.w),-(sp)         ; Block

 move.l   #$00330003,-(sp)         ; Sconfig(SC_OWN,...)
 trap     #1
 lea      12(sp),sp
__rsm_ende:
 movem.l  (sp)+,d6/d7
 rts


**********************************************************************
*
* int  _shel_write(d0 = int doex, d1 = isgr, d2 = isover,
*                 a0 = char *cmd,
*                 a1 = char *tail,
*                 a2 = APPL *ap,
*                 long extinf[4])
*
* Mag!X 2.00: liefert ap_id
*
* MagiX 3.0: extinf == NULL:  alte Funktion
*                     sonst:  extinf[0] = Psetlimit (noch ignoriert)
*                             extinf[1] = Prenice   (noch ignoriert)
*                             extinf[2] = Default-Pfad (noch ignoriert)
*                             extinf[3] = Environment
* MagiC 6.0:                  extinf[4] = flags
*
*            tail kann auch laenger als 128 Bytes sein, dann wird in
*            der APPL-Struktur ap_xtail benutzt.
*

_shel_write:
 move.w   d0,ap_doex(a2)
 move.w   d1,ap_isgr(a2)
 move.w   d2,ap_isover(a2)
 move.l   4(sp),d0
 movem.l  a3/a4/a5/a6,-(sp)
 move.l   a0,a4                    ; cmd

 move.l   a1,a5                    ; tail
 move.l   a2,a6                    ; APPL
;tst.l    d0
 beq.b    _shw_noex                ; keine erweiterten Parameter
 move.l   d0,a0
 move.l   (a0)+,ap_memlimit(a6)
 move.l   (a0)+,ap_nice(a6)
 addq.l   #4,a0                    ; Default-Pfad ignoriert

* ggf. Environment setzen
* Eigner ist der Loader-Prozess, wenn moeglich

 move.l   4(a0),ap_flags(a6)       ; Flags
 move.l   (a0)+,d0                 ; env
 ble.b    _shw_noex                ; kein Environment, altes lassen
 move.l   d0,a3                    ; neues Env. merken
 move.l   a3,a0
 jsr      env_end                  ; Laenge des neuen Env bestimmen
 move.w   #ap_env,d1
 bsr      __resvldmem              ; Block freigeben/holen/kopieren...

* tail setzen

_shw_noex:
 move.l   a5,a3                    ; tail
 move.w   #ap_xtail,d1
 moveq    #0,d0                    ; kein neuer Block
 bsr      __resvldmem

 cmpi.b   #$fe,(a3)                ; Extralanges ap_tail ?
 bcs.b    _shw_normtail            ; nein, normale Funktion
 beq.b    _shw_argv                ; 1. Byte $fe: ARGV uebergeben
 move.l   a3,a0                    ; 1. Byte $ff: lange Zeile uebergeben
 jsr      strlen
 addq.l   #1,d0                    ; + EOS
 bra.b    _shw_xarg
_shw_argv:
 move.l   a3,a0
 jsr      env_end                  ; Laenge des ARGV bestimmen
_shw_xarg:
 cmpi.w   #$80,d0                  ; passt in ap_tail ?
 bls.b    _shw_normtail            ; ja!
 move.w   #ap_xtail,d1             ; xtail belegen
 bsr      __resvldmem
 bra.b    _shw_cmd

_shw_normtail:
 move.w   #ap_xtail,d1             ; xtail freigeben
 moveq    #0,d0                    ; kein neuer Block
 bsr      __resvldmem
 move.w   #$80,d0
 move.l   a3,a1                    ; tail
 lea      ap_tail(a6),a0
 jsr      vmemcpy


* Kommando merken

_shw_cmd:
 move.w   #$80,d0
 move.l   a4,a1                    ; cmd
 lea      ap_cmd(a6),a0
 jsr      vmemcpy

 cmpi.w   #101,ap_isover(a6)       ; SHW_SINGLE ?
 bne.b    _shw_ende                ; nein
; Pfade an den Parent vererben (d.h. eigentlich vertauschen)
 jsr      swap_paths               ; Aufruf des GEMDOS
_shw_ende:
 move.w   ap_id(a6),d0
 movem.l  (sp)+,a3/a4/a5/a6
 rts


**********************************************************************
*
* void vt52_uninherit(d0 = dst_apid)
*
* un-vererbe das vt52-Fenster
*

vt52_uninherit:
 move.l   p_vt52.w,d2
 beq.b    uninh_old
 move.l   d2,a0
 move.l   vt_uninherit(a0),a0
;move.w   d0,d0                    ; apid
 jmp      (a0)
uninh_old:
 move.l   (p_vt52_winlst).l,d2         ; VT52 aktiv ?
 beq.b    uninh_ende               ; nein
 move.l   d2,a0
 add.w    d0,d0
 add.w    d0,d0
 clr.l    0(a0,d0.w)               ; austragen
uninh_ende:
 rts


**********************************************************************
*
* void vt52_inherit(d0 = dst_apid, d1 = src_apid)
*
* vererbe das vt52-Fenster
*

vt52_inherit:
 move.l   p_vt52.w,d2
 beq.b    inh_old
 move.l   d2,a0
 move.l   vt_inherit(a0),a0
;move.w   d1,d1                    ; src_apid
;move.w   d0,d0                    ; dst_apid
 move.w   d0,-(sp)
 jsr      (a0)
 tst.w    d0                       ; vererbt?
 beq.b    inh_ok                   ; ja
 addq.l   #2,sp                    ; nein
 rts
inh_ok:
 move.w   (sp)+,d0
 bra.b    inh_both
inh_old:
 move.l   (p_vt52_winlst).l,d2         ; VT52 aktiv ?
 beq.b    inh_ende                 ; nein
 move.l   d2,a0
 move.w   d0,d2
 add.w    d2,d2
 add.w    d2,d2
 add.w    d1,d1
 add.w    d1,d1
 move.l   0(a0,d1.w),0(a0,d2.w)    ; vererben
 beq.b    inh_ende                 ; kein Fenster
;move.w   d2,d0
inh_both:
 bsr.b    id2app
 clr.w    ap_isgr(a0)              ; merken!
inh_ende:
 rts


**********************************************************************
*
* APPL *id2app(d0 = apid)
*

id2app:
 move.w   d0,a0
 add.w    a0,a0
 add.w    a0,a0
 move.l   applx(a0),a0
 rts


**********************************************************************
*
* void vt52_open(d0 = dst_apid)
*
* Oeffnet ein Fenster des VT52 fuer die Applikation dst_apid.
*

vt52_open:
 movem.l  d6/d7,-(sp)
 move.w   d0,d7                    ; d7 = ap_id
 bsr      get_vt52_id
 move.w   d0,d6                    ; d6 = ap_id des VT52
 ble.b    vto_err                  ; nein, return(0)

; der VT52 soll nach Programmende benachrichtigt werden

 move.w   d7,d0
 bsr.b    id2app
 move.w   d6,ap_parent2(a0)        ; VT52 adoptiert neue APPL
 move.w   #$4701,ap_isgr(a0)       ; Grafik-Modus mit Verzoegerung

; ich schicke die ap_id an den VT52

 move.w   d7,d2                    ; ap_id des neuen Prozesses uebergeben
 pea      ap_cmd(a0)               ; Bytepointer auf Programmpfad
 pea      ap_isgr(a0)              ; Bytepointer auf $47 dem VT52 uebergeben
 move.l   sp,a0
 move.w   d6,d1                    ; dst_apid (VT52)
 move.w   #$1411,d0                ; Nachricht fuer VT52
 bsr      send_msg
 addq.l   #8,sp
vto_err:
 movem.l  (sp)+,d6/d7
 rts


**********************************************************************
*
* int shel_write(d0 = int doex, d1 = int isgr, d2 = int isover,
*                a0 = char *cmd, a1 = char *tail)
*
* Der Parameter "isover" heisst in MTOS "iscr".
*
* isover:
*
* #define SHW_IMMED      0                        /* PC-GEM 2.x  */
* #define SHW_CHAIN      1                        /* TOS         */
* #define SHW_DOS        2                        /* PC-GEM 2.x  */
* #define SHW_PARALLEL   100                      /* MAGIX       */
* #define SHW_SINGLE     101                      /* MAGIX       */
*
* doex:
*
* #define SHW_NOEXEC     0
* #define SHW_EXEC       1
* #define SHW_EXEC_ACC   3
* #define SHW_SHUTDOWN   4                        /* MultiTOS */
* #define SHW_RESCHNG    5
* #define SHW_BROADCAST  7
* #define SHW_INFRECGN   9
* #define SHW_AESSEND    10
* ab 29.2.96:
* #define SHW_THR_CREATE 20
* #define SHW_THR_EXIT   21
* #define SHW_THR_KILL   22
*
*    MTOS:
*
*    doex:
*
*    #define SHW_MTOSEXEC_PAR_AUTO 0
*    #define SHW_MTOSEXEC_PAR_APP  1
*    #define SHW_AES_ENVIRONMENT   8
*
*    isover:
*
*    #define SHW_ARGV_NO      0
*    #define SHW_ARGV_YES     1
*
*
* MagiX 3.0:   Ist das Hibyte von <doex> gesetzt, ist <cmd> ein
*              Zeiger auf folgende Struktur:
*              char *cmd
*              long limit          gueltig, wenn Bit 8 gesetzt
*              long nice           gueltig, wenn Bit 9 gesetzt
*              char *defdir        gueltig, wenn Bit 10 gesetzt
*              char *env           gueltig, wenn Bit 11 gesetzt
*
* seit 15.9.95: Modus doex = SHW_EXEC_ACC
*
* MagiC 6.0:
*              Die Struktur ist erweitert um:
*              LONG flags          gueltig, wenn Bit 12 gesetzt
*
* <flags> wird in die APPLICATION-Struktur kopiert.
*    Bit 0:    wenn gesetzt, keine prop. AES-Zeichensatz
*

shel_write:
 cmpi.w   #SHW_THR_CREATE,d0
 beq      shw_create_thread
 cmpi.w   #SHW_THR_EXIT,d0
 beq      shw_exit_thread
 cmpi.w   #SHW_THR_KILL,d0
 beq      shw_kill_thread
 cmpi.w   #SHW_SHUTDOWN,d0         ; doex ?
 beq      shutdown
 cmpi.w   #SHW_RESCHNG,d0
 beq      shutdown_res
 cmpi.w   #SHW_INFRECGN,d0
 beq      inform_aes_recgn
 cmpi.w   #SHW_AESSEND,d0
 beq      send_aes_msg
 cmpi.w   #SHW_BROADCAST,d0
 beq      broadcast2
 cmpi.w   #8,d0                    ; Environment manipulieren
 beq.b    shw_err
 tst.w    shutdown_id              ; shutdown aktiv ?
 bmi.b    shw_noshut               ; nein, EXEC ist erlaubt
shw_err:
 moveq    #0,d0                    ; Fehler: Shutdown-Modus
 rts
shw_noshut:
 cmpi.w   #SHW_EXEC_ACC,d0
 beq      load_acc                 ; ACC laden, liefere ap_id

 tst.w    d1                       ; TOS- Programm ?
 bne.b    shw_isgem                ; nein!
 cmpi.w   #100,d2                  ; isover == SHW_PARALLEL ?
 bne.b    shw_isgem                ; nein
; Sonderbehandlung fuer parallele TOS- Programme
 movem.w  d0-d2,-(sp)
 move.l   a1,-(sp)                 ; tail
 move.l   a0,-(sp)                 ; cmd
 bsr      get_vt52_id
 tst.w    d0
 ble.b    shw_no_vt52              ; nein, normale Funktion
 move.w   d0,-(sp)                 ; ap_id des VT52 merken
; ich starte die neue APP, aber im Grafikmodus und verzoegert
 lea      2(sp),a2
 move.l   (a2)+,a0
 move.l   (a2)+,a1
 movem.w  (a2),d0-d2               ; alte Parameter wiederholen
 move.w   #$4701,d1                ; aber Grafikmodus und verzoegern !
 bsr.s      shw_isgem                ; Rekursion, Programm starten
; ich schicke die ap_id an den VT52
 move.w   (sp)+,d1                 ; dst_apid (VT52)
 lea      14(sp),sp                ; Stack zuruecksetzen
 move.w   d0,-(sp)                 ; ap_id des neuen Prozesses merken
 move.w   d0,d2                    ; ap_id des neuen Prozesses uebergeben
;move.w   d0,d0
 bsr      id2app
 move.w   d1,ap_parent2(a0)        ; VT52 eintragen
 pea      ap_cmd(a0)               ; Bytepointer auf Programmpfad
 pea      ap_isgr(a0)              ; Bytepointer auf $47 dem VT52 uebergeben
 move.l   sp,a0
 move.w   #$1411,d0                ; Nachricht fuer VT52
 bsr      send_msg
 addq.l   #8,sp
 move.w   (sp)+,d0                 ; ap_id des neuen Prozesses zurueckgeben
 rts

shw_no_vt52:
 move.l   (sp)+,a0
 move.l   (sp)+,a1
 movem.w  (sp)+,d0-d2


*
* Ende der Sonderbehandlung fuer den VT52.
* Hier kann auch rein ge-bsr-t werden.
*

shw_isgem:
 movem.l  a6/d7,-(sp)
 move.l   a0,a6                    ; a6 = cmd
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)                    ; Platz fuer 5 erweiterte Parameter
 clr.l    -(sp)                    ; keine erweiterten Parameter
* erweiterte Parameter auswerten
 cmpi.w   #$0100,d0                ; erweiterte Parameter ?
 bcs.b    shw_no_ext               ; nein
 move.l   (a0)+,a6                 ; a6 = cmd
 lea      (sp),a2
 move.l   a2,(a2)
 addq.l   #4,(a2)+                 ; Zeiger auf erweiterte Parameter
 moveq    #8,d7
shw_xloop:
 btst     d7,d0
 beq.b    shw_no_x
 move.l   (a0),(a2)
shw_no_x:
 addq.l   #4,a0
 addq.l   #4,a2
 addq.w   #1,d7
 cmpi.w   #12,d7
 bls.b    shw_xloop

shw_no_ext:
 cmpi.w   #100,d2                  ; isover == SHW_PARALLEL ?
 bne.b    shw_noispar

* parallel

 move.l   a6,a0
 bsr      ap_create                ; d0 = doex
                                   ; d1 = int isgr
                                   ; a0 = char *cmd
                                   ; a1 = char *tail,
                                   ; (sp) = long extinf[4]
 bra      shw_end

* verketten

shw_noispar:
 tst.w    d1
 sne.b    d1
 andi.w   #1,d1                    ; isgr auf {0,1} beschraenken
 move.l   act_appl,a2
 move.l   a6,a0
 bsr      _shel_write
 moveq    #1,d0
shw_end:
 lea      24(sp),sp
 movem.l  (sp)+,d7/a6
 rts

****************
*
* Thread erstellen
*
* d1 = isgr
* d2 = isover
* a1 = void *param
* a0 = THREADINFO *thri
*

shw_create_thread:
 movem.l  d6/d7,-(sp)
 move.l   a1,d0                    ; par
 move.w   d1,d7                    ; isgr
 move.l   a0,a2
 move.l   (a2)+,a0                 ; proc
 move.l   (a2)+,a1                 ; userstack oder NULL

 move.l   (a2),d1                  ; Stackgroesse
 move.l   a1,d2                    ; usp
 bne.b    shct_ok                  ; ja, explizit angegeben
; Erstelle Userstack
 movem.l  d0/d1/a0,-(sp)
 move.l   d1,d0
 jsr      mmalloc
 move.l   d0,a1                    ; ccr unveraendert, merke usp
 movem.l  (sp)+,d0/d1/a0           ; ccr unveraendert
 beq      shw_err                  ; Fehler bei Malloc
shct_ok:
 bsr      create_thread
 move.w   d0,d6                    ; Fehler ?
 ble.b    shct_ende                ; ja, Ende

* Sonderbehandlung bei VT52

 tst.w    d7                       ; isgr
 beq.b    shct_0                   ; 0, vt52-Fenster vererben
 subq.w   #1,d7
 beq.b    shct_ende2               ; isgr == 1, kein VT52

* 2: VT52-Fenster neu oeffnen

;move.w   d0,d0
 bsr      vt52_open
 bra.b    shct_ende2

* 0: VT52-Fenster vererben

shct_0:
 move.l   act_appl,a0
 move.w   ap_id(a0),d1
;move.w   d0,d0
 bsr      vt52_inherit             ; Fenster vererben.

* 1: kein VT52

shct_ende2:

shct_ende:
 move.w   d6,d0
 movem.l  (sp)+,d6/d7
 rts


****************
*
* Thread beendet sich
*
* d1 = isgr
* d2 = isover
* a1 = void *param
* a0 = cmd
*

shw_exit_thread:
 move.l   a0,d1                    ; cmd ist exitcode
 move.l   act_appl,a0
 cmpi.w   #1,ap_type(a0)
 bne.b    set_err                  ; ich bin kein Thread
 move.l   act_pd.l,a1
 cmpa.l   p_app(a1),a0             ; main thread ?
 beq.b    set_err                  ; ja, muss erst Pterm machen!
 move.l   d1,d7                    ; Rueckgabewert
 bra      end_thread
set_err:
 moveq    #0,d0
 rts


****************
*
* Thread wird entfernt
*
* d1 = isgr
* d2 = isover
*

shw_kill_thread:
 move.w   d2,d0                    ; zu killende ap_id
 cmpi.w   #NAPPS,d0
 bcc.b    skt_err
 bsr      id2app
 move.l   a0,d1
 ble.b    skt_err                  ; ap_id ungueltig
 cmpi.w   #1,ap_type(a0)           ; als Thread gestartet ?
 bne.b    skt_err                  ; nein!
 move.l   act_appl,a1
 move.w   ap_id(a1),d1
 cmp.w    ap_parent(a0),d1
 bne.b    skt_err                  ; bin nicht parent
;move.l   a0,a0
 bsr      kill_thread
 moveq    #1,d0
 rts
skt_err:

 moveq    #0,d0
 rts


**********************************************************************
*
* int get_vt52_id( void )
*
* Ermittelt die ap_id des VT52.PRG
*

vt52_s:
 DC.B     'VT52    '
vtg_nix_s:
 DC.B     0
 EVEN

get_vt52_id:
 lea      vt52_s(pc),a0
 bsr      appl_find                ; ist VT52- Emulator geladen ?
 bgt.b    gvt_ok                   ; ap_id gefunden
 moveq    #-1,d0
 tst.b    termprog
 beq.b    gvt_ok                   ; kein Terminalprogramm angegeben
 lea      vtg_nix_s(pc),a1         ; tail ist leer
 lea      termprog,a0              ; char *fname
 moveq    #1,d1                    ; isgr
 moveq    #1,d0                    ; doex
 clr.l    -(sp)                    ; keine erweiterten Parameter
 bsr      ap_create                ; gib ap_id zurueck
 addq.l   #4,sp
gvt_ok:
 rts


**********************************************************************
*
* unsigned int shel_get(a0 = char *dst, d0 = unsigned int len)
*
* Liefert die Pufferlaenge, falls d0<=0 (MultiTOS), sonst 1
*

shel_get:
 move.l   shel_buf,a1
 move.w   shel_buf_len,d1
 cmpi.w   #-1,d0
 beq.b    shg_len
 cmp.w    d1,d0               ; Ueberlauf ?
 bls.b    _shel_pg            ; nein, ok
 move.w   d1,d0               ; nur Pufferlaenge uebertragen
_shel_pg:
 jsr      vmemcpy
 moveq    #1,d0
 rts
shg_len:
 move.w   d1,d0
 rts


**********************************************************************
*
* int shel_put(a0 = char *src, d0 = unsigned int len)
*

shel_put:
 move.l   shel_buf,a1         ; dst
 exg      a1,a0
 cmp.w    shel_buf_len,d0     ; Ueberlauf ?
 bls.b    _shel_pg            ; nein, ok
sp_err:
 moveq    #0,d0               ; Ueberlauf beim Schreiben
 rts


**********************************************************************
*
* void shel_rdef(a0 = char *cmd, a1 = char *dir)
*

shel_rdef:
 lea      shel_name,a2
* Suche Zeiger hinter letztes ':' oder '\\'
srd_merke:
 move.l   a2,d1                    ; Zeiger hinter ':' oder '\\'
srd_loop1:
 move.b   (a2)+,d0
 beq.b    srd_endloop
 cmpi.b   #':',d0
 beq.b    srd_merke
 cmpi.b   #92,d0
 beq.b    srd_merke
 bra.b    srd_loop1
srd_endloop:
 move.l   d1,a2                    ; Zeiger hinter letztes ':' oder '\\'
srd_loop2:
 move.b   (a2)+,(a0)+              ; kopiere den Namen einschl. EOS
 bne.b    srd_loop2
 lea      shel_name,a2
srd_loop3:
 cmpa.l   d1,a2                    ; Dateinamen erreicht ?
 bcc.b    srd_endloop3
 move.b   (a2)+,(a1)+
 bra.b    srd_loop3
srd_endloop3:
 clr.b    (a1)                     ; EOS des Pfads setzen
 rts


**********************************************************************
*
* void shel_wdef(a0 = char *cmd, a1 = char *dir)
*
* Kopiert <dir> nach shel_name und haengt <cmd> an. Ggf. wird ein '\\'
* zwischen Pfad und Programmname ergaenzt
*

shel_wdef:
 lea      shel_name,a2
 tst.b    (a1)
 beq.b    swd_name                 ; Pfad ist leer
swd_loop1:
 move.b   (a1)+,(a2)+              ; zunaechst den Pfad kopieren
 bne.b    swd_loop1
 move.l   a0,a1
 lea      shel_name,a0
 bra      add_name
swd_name:
 move.b   (a0)+,(a2)+              ; dann den Namen anhaengen
 bne.b    swd_name
 rts


**********************************************************************
*
* EQ/NE int appl_hide  ( a0 = APPL *ap, d0 = int mode )
* EQ/NE int appl_unhide( a0 = APPL *ap, d0 = int mode )
*
* d0 = 0x0000: Nur Applikation <a0>
*      0x00ff: Alle ausser <a0>
*      0xffff: Alle
*      0xfffe: Nur testen, ob Fenster versteckt sind
*
* Verschiebt die Fenster von <a0> um scr_h nach unten, so dass sie
* ausserhalb des Bildschirms liegen, bzw. macht sie wieder sichtbar.
* Es wird nicht direkt verschoben, sondern ein WM_MOVED geschickt.
*
* Rueckgabe: es wurden Fenster veraendert
*

appl_unhide:
 move.w   scr_h,d1
 neg.w    d1
 bra.b    _appl_h_u
appl_hide:
 move.w   scr_h,d1
_appl_h_u:
 movem.l  d5/d6/d7/a5/a6,-(sp)
 move.l   a0,a6
 moveq    #0,d5                    ; noch nichts veraendert
 move.w   d0,d6
 move.w   d1,d7                    ; Offset
* Fenster verstecken
 lea      whdlx,a5
 bra      ah_wnd_nxt
ah_wnd_loop:
 move.w   d0,d2                    ; whdl
 jsr      whdl_to_wnd
 move.l   w_owner(a0),a1           ; a1 = Eigner des Fensters
 tst.w    d6                       ; mode
 bmi.b    ah_all                   ; ist -1, also alle behandeln
 cmpa.l   a1,a6
 sne.b    d1
 eor.b    d6,d1                    ; im Modus 1 alle ausser a0
 bne.b    ah_wnd_nxt
ah_all:
 move.w   w_curr+g_y(a0),d0
 tst.w    d7
 bmi.b    ah_unhide
 cmp.w    scr_h,d0
 bcc.b    ah_wnd_nxt
ah_unhide:
 add.w    d7,d0                    ; gewuenschte Zielposition
 bmi      ah_wnd_nxt               ; Fenster geht nicht weiter nach oben
 moveq    #1,d5                    ; hat was getan
 move.w   #' *',ap_dummy2(a1)      ; APPL markieren
 cmpi.w   #-2,d6                   ; nur testen ?
 beq.b    ah_wnd_nxt
 move.l   w_curr+g_w(a0),-(sp)     ; g_w, g_h
 btst     #WSTAT_SHADED_B,w_state+1(a0)      ; shaded?
 beq.b    ah_no_sh                 ; nein, OK
 move.w   w_oldheight(a0),2(sp)    ; ja, alte Hoehe
ah_no_sh:
 move.w   d0,-(sp)                 ; g_y + d7
 move.w   w_curr+g_x(a0),-(sp)     ; x
 move.l   sp,a0
;move.w   d2,d2
 move.w   ap_id(a1),d1
 moveq    #WM_MOVED,d0
 bsr      send_msg
 addq.l   #8,sp
ah_wnd_nxt:
 move.w   (a5)+,d0
 bmi.b    ah_wnd_nxt
 bne.b    ah_wnd_loop
 move.w   d5,d0
 movem.l  (sp)+,a5/a6/d7/d6/d5
 rts


**********************************************************************
*
* long psig_freeze( d0 = long handler )
*
* Fuer GEMDOS Psignal(SIGFREEZE, handler)
*

psig_freeze:
 move.l   act_appl,a0
 move.l   a0,d1                    ; act_appl gueltig ?
 ble.b    psf_err                  ; nein!
 move.l   ap_sigfreeze(a0),d1
 move.l   d0,ap_sigfreeze(a0)
 move.l   d1,d0
 rts
psf_err:
 moveq    #-1,d0
 rts


**********************************************************************
*
* void appl_freeze( a0 = APPL *ap )
*
* Friert Applikation ein.
* Ruft ggf. den Signalhandler auf.
*

_appl_freeze:
 lea      act_appl,a1              ; "ready"
 move.b   ap_status(a0),d0
 beq.b    af_is_ready
 lea      suspend_list,a1
 cmpi.b   #APSTAT_SUSPENDED,d0
 beq.b    af_is_ready
 lea      notready_list,a1         ; "waiting"
af_is_ready:

;move.l   a1,a1
;move.l   a0,a0
 bsr      rmv_lstelm               ; aus Liste ausklinken

 move.w   ap_id(a0),a1
 add.l    a1,a1
 add.l    a1,a1
 bset.b   #7,applx(a1)             ; Eintrag in applx ungueltig machen
* aus Semaphoren- Warteliste ausklinken
;move.l   a0,a0
 bra      rmv_ap_sem

appl_freeze:
 movem.l  d7/a5/a6,-(sp)
 subq.l   #8,sp
 move.l   a0,a6
 move.l   ap_sigfreeze(a6),d0      ; Signalhandler fuer SIGFREEZE
 beq.b    af_sigdef                ; Default- Aktion
 subq.l   #1,d0                    ; SIGIGN ?
 beq      af_err                   ; ja, nichts unternehmen
* Signalhandler aufrufen
 addq.l   #1,d0
 move.l   d0,a2
 moveq    #SIGFREEZE,d0
 move.l   d0,-(sp)                 ; Argument auf dem Stack: Signalnummer
 jsr      (a2)
 addq.l   #4,sp
af_sigdef:
 tst.w    ap_critic(a6)            ; kritische Phase ?
 bne      af_err                   ; ja, nichts unternehmen
 jsr      update_1
 st       inaes
* Menue abschalten
 move.l   ap_menutree(a6),d0
 beq.b    af_no_menu
 move.l   d0,-(sp)                 ; Adresse des Menuebaums merken
 move.l   a6,a0
 jsr      menu_new                 ; Menuebaum abschalten, anderen suchen
 move.l   (sp)+,d0
 bset.l   #31,d0
 move.l   d0,ap_menutree(a6)       ; mit gesetztem Bit 31 merken
af_no_menu:
* Desktop abschalten
 move.l   ap_desktree(a6),d0
 beq.b    af_no_desk
 move.l   d0,-(sp)
 move.l   a6,a0
 jsr      desk_off                 ; Hintergrund abschalten
 move.l   (sp)+,d0
 bset.l   #31,d0
 move.l   d0,ap_desktree(a6)       ; mit gesetztem Bit 31 merken
af_no_desk:
* aus Wartelisten ausklinken
 move.l   a6,a0
 bsr      _appl_freeze
* Fenster verstecken
 lea      whdlx,a5
 sf       d7                       ; noch kein Fenster
 bra.b    af_wnd_nxt
af_wnd_loop:
 move.l   windx,a1                 ; Fenstertabelle
 add.w    d0,a1
 add.w    d0,a1
 add.w    d0,a1
 add.w    d0,a1                    ; * 4 wg. (void *)
 move.l   (a1),d1
 beq.b    af_wnd_nxt               ; Fenster unbenutzt
 move.l   d1,a1
 cmpa.l   w_owner(a1),a6
 bne.b    af_wnd_nxt
 bset.b   #7,-2(a5)                ; Fenster verstecken
 tas      d7                       ; es hat sich was getan
 beq.b    af_wnd_1st               ; war das erste Fenster
 move.l   w_overall+g_w(a1),-(sp)
 move.l   w_overall+g_x(a1),-(sp)  ; Groesse nach (sp)
 lea      (sp),a0
 lea      8(sp),a1
 bsr      grects_union             ; mit altem Rechteck vereinigen
 addq.l   #8,sp
 bra.b    af_wnd_nxt
af_wnd_1st:
 move.l   w_overall+g_w(a1),4(sp)
 move.l   w_overall+g_x(a1),(sp)   ; Groesse nach (sp)
af_wnd_nxt:
 move.w   (a5)+,d0
 bmi.b    af_wnd_nxt               ; ist schon versteckt
 bne.b    af_wnd_loop
 tst.b    d7
 beq.b    af_no_winds
 moveq    #1,d0                    ; oberstes Fenster erneuern
 jsr      build_new_wgs
 lea      (sp),a0
 jsr      wind0_draw
 lea      (sp),a0
 jsr      send_all_redraws
af_no_winds:
 sf       inaes
 jsr      update_0
af_err:
 addq.l   #8,sp
 movem.l  (sp)+,d7/a5/a6
 rts


**********************************************************************
*
* void freeze_all_apps( void )
*
* Friert alle Applikationen ausser Hauptapplikation (APP #0) und
* Screenmanager (APP #1) ein.
*

freeze_all_apps:
 move.l   act_appl,a0
 cmpi.w   #1,ap_id(a0)
 bhi      fa_err                   ; das duerfen nur APP #0, APP #1
 move.l   a5,-(sp)
 jsr      update_1
 move.b   inaes,-(sp)
 st       inaes
 lea      applx+8,a5
fa_loop:

 move.l   (a5)+,d0
 ble.b    fa_nextapp
 move.l   d0,a0
 bsr      appl_freeze
fa_nextapp:
 cmpa.l   #applx+(NAPPS*4),a5
 bcs.b    fa_loop
 move.b   (sp)+,inaes
 jsr      update_0
fa_err:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void appl_unfreeze( a0 = APPL *ap )
*
* Taut Applikation auf.
* APPs vom Status "zombie" werden als "ready" eingestuft.
*

appl_unfreeze:
 movem.l  a5/a6,-(sp)
 move.l   a0,a6
 jsr      update_1
 move.b   inaes,-(sp)
 st       inaes
* Menue einschalten
 move.l   ap_menutree(a6),d0
 bge.b    au_no_menu
 bclr     #31,d0                   ; Hibit loeschen
 move.l   d0,a1                    ; Menuebaum
 move.l   a6,a0
 jsr      menu_on                  ; Menuebaum einschalten
 jsr      all_untop                ; ggf. oberstes Fenster deaktivieren
au_no_menu:
* Desktop einschalten
 move.l   ap_desktree(a6),d0
 beq.b    au_no_desk
 bclr     #31,d0                   ; Hibit loeschen
 move.w   ap_1stob(a6),d1
;move.l   d0,d0                    ; Desktop
 move.l   a6,a0
 jsr      desk_on                  ; Hintergrund einschalten
au_no_desk:
* in Wartelisten einklinken
 lea      notready_list,a2         ; "waiting"
 move.b   ap_status(a6),d0
 subq.b   #1,d0
 beq.b    au_is_nready             ; APSTAT_WAITING
 lea      suspend_list,a2
 subq.b   #1,d0
 beq.b    au_is_nready             ; APSTAT_SUSPENDED
 lea      act_appl,a2              ; "ready" oder "zombie"
 sf.b     ap_status(a6)            ; "zombie" -> "ready"

au_is_nready:
 move.l   a6,a0
 bsr      _ap_to_last              ; in Liste einklinken
 move.w   ap_id(a6),a0
 add.l    a0,a0
 add.l    a0,a0
 bclr.b   #7,applx(a0)             ; Eintrag in applx gueltig machen
* ggf. in Semaphorenliste wieder einklinken
 btst     #EVB_SEM,ap_rbits+1(a6)  ; wartete auf end_update ?
 beq.b    au_nosem                 ; nein
 btst     #EVB_SEM,ap_hbits+1(a6)  ; schon eingetroffen ?
 bne.b    au_nosem                 ; ja
 move.l   ap_semaph(a6),a1
 move.l   bl_waiting(a1),ap_nxtsem(a6)
 move.l   a6,bl_waiting(a1)
au_nosem:
* Fenster wieder oeffnen
 lea      whdlx,a0
 sf       d2
 bra.b    au_wnd_nxt
au_wnd_loop:
 bclr     #15,d0
 move.l   windx,a1
 add.w    d0,a1
 add.w    d0,a1
 add.w    d0,a1
 add.w    d0,a1                    ; * 4 wg (void *)
 move.l   (a1),d1
 beq.b    au_wnd_nxt               ; Fenster unbenutzt
 move.l   d1,a1
 cmpa.l   w_owner(a1),a6
 bne.b    au_wnd_nxt
 bclr.b   #7,-2(a0)                ; Fenster gueltig machen
 st       d2                       ; es hat sich was getan
au_wnd_nxt:
 move.w   (a0)+,d0
 bgt.b    au_wnd_nxt               ; ist schon gueltig!
 bmi.b    au_wnd_loop              ; muss behandelt werden
 tst.b    d2
 beq.b    au_no_winds
 moveq    #1,d0                    ; oberstes Fenster erneuern
 jsr      build_new_wgs
 move.l   a6,a0
 jsr      app_wind_redraw          ; alle Fenster neu zeichnen
au_no_winds:
 move.b   (sp)+,inaes
 jsr      update_0
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* void unfreeze_all_apps( void )
*

unfreeze_all_apps:
 move.l   a5,-(sp)
 jsr      update_1
 move.b   inaes,-(sp)
 st       inaes
 lea      applx,a5
ua_loop:
 move.l   (a5)+,d0
 bpl.b    ua_nextapp               ; NULL oder gueltig
 bclr.l   #31,d0
 move.l   d0,a0
 bsr      appl_unfreeze
ua_nextapp:
 cmpa.l   #applx+(NAPPS*4),a5
 bcs.b    ua_loop
 move.b   (sp)+,inaes
 jsr      update_0
 move.l   (sp)+,a5
 rts


* auf Grafikbildschirm schalten

graph_mode:
 moveq    #1,d0                    ; Grafikmodus
 jsr      set_scrmode
 jsr      set_full_clip
 jmp      reset_mouse

* auf Textbildschirm schalten

text_mode:
 jsr      mouse_off
 moveq    #0,d0                    ; Textmodus
 jmp      set_scrmode


**********************************************************************
*
* void male_startbild(a0 = char *pgmname)
*

male_startbild:
 suba.w   #20+8,sp                 ; GRECT+Programmname
 move.l   act_appl,a1
 tst.w    ap_wasgr(a1)
 beq.b    mstr_nopic               ; TOS- Programm, kein Titelbild
 tst.w    ap_id(a1)
 bne.b    mstr_nopic               ; nicht APPL #0
* als te_ptext eintragen
 lea      8(sp),a1
 move.l   a1,shelw_startpic+48     ; TEDINFO, te_ptext
* in Grossschrift wandeln
 bra.b    mstr_nxtchr
mstr_loop:
 jsr      toupper                  ; veraendert nur d0
 move.b   d0,(a1)+
mstr_nxtchr:
 move.b   (a0)+,d0
 bne.b    mstr_loop
 clr.b    (a1)

 move.l   full_g,(sp)
 move.l   full_g+4,4(sp)           ; GRECT kopieren

 moveq    #0,d2                    ; whdl
 move.l   sp,a1                    ; GRECT (wird veraendert!)
 moveq    #1,d1                    ; depth
 moveq    #0,d0                    ; startob
 lea      shelw_startpic,a0        ; tree
 jsr      objc_wdraw

 lea      menubar_grect,a0
 jsr      set_clip_grect

 moveq    #1,d1                    ; depth
 moveq    #0,d0                    ; startob
 lea      shelw_startpic,a0
 bsr      _objc_draw
 moveq    #2,d0                    ; Biene
 bsr      graf_mouse               ; Maus als Biene

mstr_nopic:
 adda.w   #8+20,sp
 rts


**********************************************************************
*
* d0 = char *add_name(a0 = char *path, a1 = char *name)
*
* <path> ist ein Pfad wie "C:\ACC" oder "C:\ACCS\\" oder "C:".
* <name> ist "*.*" oder "*.prg" oder "datei.ext".
* gibt Zeiger auf bisheriges String- Ende zurueck
* liefert in d1 Zeiger auf Namen (d.h. ggf. '\\' ergaenzt)
*

add_name:
 tst.b    (a0)
 beq.b    adn_setslash
adn_loop:
 tst.b    (a0)+
 bne.b    adn_loop
 subq.l   #1,a0                    ; a0 auf EOS
 move.l   a0,d0                    ; bisheriges Ende zurueckgeben
 cmpi.b   #92,-1(a0)
 beq.b    adn_cat
 cmpi.b   #':',-1(a0)
 beq.b    adn_cat
adn_setslash:
 move.b   #92,(a0)+
adn_cat:
 move.l   a0,d1                    ; hier beginnt der Name
adn_cat2:
 move.b   (a1)+,(a0)+
 bne.b    adn_cat2
 rts


**********************************************************************
*
* d0/a0 = char *shel_envrn( a0 = char *param )
*
* <param> muss die Form etwa "PATH=" haben, also mit '='
* Korrigiert, bisher wurden Anfangsstuecke auch als passend erkannt.
*
* gefunden:       a0 zeigt auf die Variable, d0 = 1
* nicht gefunden: a0 ist NULL, d0 = 0
*

shel_envrn:
 movea.l  _basepage,a1
 move.l   $2c(a1),a1               ; Environment
 tst.b    (a1)+                    ; erstes Byte ist Null ?
 beq.b    shev_tst0                ; ja, wenn naechstes auch, dann Ende
 subq.l   #1,a1                    ; Korrektur
shenv_nxtvar:
 movea.l  a0,a2                    ; gesuchter String
shev_loop:
 tst.b    (a2)                     ; unseren String ganz verglichen ?
 beq.b    snv_found                ; ja, a1 zurueckgeben
 cmpm.b   (a2)+,(a1)+              ; Zeichen identisch ?
 beq.b    shev_loop                ; ja, weiter vergleichen
 subq.l   #1,a1                    ; a1 auf zuletzt verglichenes Zeichen
shev_loop2:
 tst.b    (a1)+
 bne.b    shev_loop2
shev_tst0:
 tst.b    (a1)                     ; EOS ?
 bne.b    shenv_nxtvar             ; nein, weiter
 suba.l   a0,a0                    ; nicht gefunden
 moveq    #0,d0
 rts
snv_found:
 move.l   a1,a0
 moveq    #1,d0
 rts


**********************************************************************
*
* ULONG/int shel_find(a0 = char *path)
*
* Suchreihenfolge:
*    1) Falls <path> einen Pfad enthaelt, dort suchen.
*    2) Im Verzeichnis des Programms suchen
*    3) Im aktuellen Verzeichnis suchen
*    4) PATH= auswerten, Eintrag ";" ueberlesen (schon in (3) gesucht)
*
* Rueckgabe:
*    d0 = 0:   Fehler
*    d0 = 1:   OK, d1.l ist die Dateilaenge
*

pathvars:  DC.B     'PATH=',0
     EVEN

shel_find:
 move.l   a6,-(sp)
 suba.w   #xattr_sizeof+130,sp
 move.l   a0,a6

* Environment-Variable "PATH=" ermitteln

 clr.l    -(sp)                    ; Ende-Zeichen
 clr.l    -(sp)                    ; default: kein PATH
 lea      pathvars(pc),a0
 bsr.s    shel_envrn
 beq.b    shf_npath                ;
 move.l   a0,(sp)                  ; (sp) = Zeiger auf Pfadkette ohne "PATH="
shf_npath:

* Pfad des Programms ermitteln

 clr.l    -(sp)                    ; Ende-Zeichen
 clr.l    -(sp)                    ; default: kein Pfad
 move.l   act_appl,a0
 lea      ap_cmd(a0),a1            ; a1 = Kommandozeile
 move.l   a1,a0
 move.l   a1,-(sp)
 jsr      fn_name                  ; d0 auf reinen Dateinamen der KMDZeile
 move.l   (sp)+,a1
 cmp.l    a1,d0
 bls.b    shf_nocmdpath

 lea      16(sp),a0                ; 130 Bytes Platz fuer Pfad
 move.l   a0,(sp)                  ; Zeiger uebergeben
shf_cpyloop:
 move.b   (a1)+,(a0)+              ; Pfad bis zum Dateinamen kopieren
 cmpa.l   d0,a1
 bcs.b    shf_cpyloop
 clr.b    (a0)                     ; mit EOS abschliessen
shf_nocmdpath:

 lea      8(sp),a2                 ; Tabelle der Suchpfadlisten
 lea      (sp),a1                  ; Tabelle der Suchpfade
 lea      16+130(sp),a0
 move.l   a0,d1                    ; Zeiger auf XATTR
 moveq    #1+2+4+8,d0              ; alle 4 Modi
 move.l   a6,a0                    ; uebergebener Pfad
 jsr      ffind
 tst.l    d0
 beq.b    shf_found
 moveq    #0,d0
 bra.b    shf_ende
shf_found:
 move.l   16+130+xattr_size(sp),d1 ; Dateilaenge zurueckgeben
 moveq    #1,d0
shf_ende:
 adda.w   #16+xattr_sizeof+130,sp
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* void start_thread( void )
*
* Startet einen Thread (act_appl).
* Wichtig: Der Thread bekommt seinen Parameter auf dem Stack.
* Der usp ist bereits gesetzt.
*

start_thread:
 bsr      wait_vt52                ; Falls neues Fenster zu oeffnen ist
 movea.l  act_appl,a6
 andi.w   #$dfff,sr                ; Usermode
 move.l   ap_tail(a6),-(sp)        ; Parameter
 move.l   ap_cmd(a6),a0            ; Startadresse
 jsr      (a0)                     ; Thread ausfuehren
 addq.l   #4,sp
 move.l   d0,d7                    ; Rueckgabewert merken
 lea      end_thread(pc),a2
 move.w   #$ca,d0                  ; MagiC 4.5: Schnell in den Supermode
 trap     #2

end_thread:
 movea.l  act_appl,a6              ; zur Sicherheit

* Events aufraeumen

 move.w   sr,-(sp)
 ori.w    #$700,sr
;move.l   a6,a6
 bsr      appl_kill_events
 move.w   (sp)+,sr

 bsr      appl_wind_new            ; end_update/Fenster/Menue/Desktop

 move.l   ap_thr_usp(a6),d0
 beq.b    endthr_no_usp
 move.l   d0,a0
 jsr      mfree                    ; usp freigeben
endthr_no_usp:

* isgr = 0: Programm aus VT52-Fensterliste austragen

 tst.w    ap_isgr(a6)
 bne.b    endthr_no_uninherit
 move.w   ap_id(a6),d0
 bsr      vt52_uninherit           ; aus VT52- Fensterliste austragen
endthr_no_uninherit:

* ggf. Kinder und VT52 benachrichtigen

 move.w   d7,d1
 move.w   ap_id(a6),d0
 bsr      exit_APPL

* THR_EXIT verschicken

 clr.l    -(sp)                    ; msg[6,7] = 0
 move.l   d7,-(sp)                 ; msg[4,5] = errcode
 move.l   sp,a0
 move.w   ap_id(a6),d2             ; ap_id der beendeten Applikation
 move.w   ap_parent(a6),d1         ; Ziel-ID: Parent-Thread
 moveq    #THR_EXIT,d0
 jsr      send_msg
 addq.l   #8,sp

* Thread entfernen

 move.l   d7,d0                    ; Rueckgabewert
 moveq    #1,d7                    ; vorher kein Desktop
 moveq    #0,d6                    ; nicht single mode
;move.l   a6,a6                    ; a6 = act_appl
 suba.l   a5,a5                    ; kein zugehoeriger PD
 moveq    #EBREAK,d0

pgml_term_thread:
 st       inaes                    ; Kontextwechsel verbieten
 move.l   applx,a0
 move.l   ap_ssp(a0),sp            ; Stack der APPL #0 verwenden

 move.w   sr,-(sp)
 ori.w    #$700,sr
 move.l   (a6),act_appl            ; ap_next
 move.l   a6,a0
 bsr      appl_kill_struct
 move.l   a6,a0
 jsr      smfree
 move.w   (sp)+,sr

 bra      _pgml_term_thread


**********************************************************************
*
* void start_signal( void )
*
* Startet einen Signalhandler (act_appl).
* Wichtig: Der Signalhandler bekommt seinen Parameter auf dem Stack.
* Der usp ist bereits gesetzt.
*

start_signal:
 movea.l  act_appl,a6
 move.l   sp,ap_tail+4(a6)         ; fuer den longjmp meinen ssp retten
 move.l   ap_sigthr(a6),a0         ; Vorgaenger (schlaeft jetzt)
 move.l   ap_ssp(a0),a0
 move.l   (a0),a0                  ; geretteter usp
 move.l   a0,ap_tail+8(a6)
 move.l   a0,usp

* Schleife fuer mehrere Signale:
* Fuer die User-Funktion den ssp des Main Thread verwenden
restart_signal:
/*
 move.l   act_pd.l,a0
 move.l   p_app(a0),a0
;move.l   ap_ssp(a0),sp            ; ssp des Main Thread !!!
*/
 andi.w   #$dfff,sr                ; Usermode
 move.l   ap_tail(a6),-(sp)        ; Parameter
 move.l   ap_cmd(a6),a0            ; Startadresse
 jsr      (a0)                     ; Signalhandler ausfuehren
 addq.l   #4,sp
 move.l   d0,d7                    ; Rueckgabewert merken
 lea      end_signal(pc),a2
 move.w   #$ca,d0                  ; MagiC 4.5: Schnell in den Supermode
 trap     #2

end_signal:
 move.l   ap_tail+4(a6),sp         ; ssp restaurieren
 move.l   ap_tail+8(a6),a0
 move.l   a0,usp                   ; usp restaurieren

* alte Signalmaske restaurieren

 move.l   ap_pd(a6),d0             ; PD noch gueltig?
 beq      endsig_pd_invalid        ; nein, Thread sofort beenden !!!
 move.l   d0,a0
 move.l   p_procdata(a0),a1
 move.l   ap_oldsigmask(a6),pr_sigmask(a1)

* Teste, ob weiter Signale anliegen

;move.l   ap_pd(a6),a0
 bsr      chk_signals
 beq.b    no_further_sigs          ; es liegen keine Signale an

 move.l   a1,a4                    ; a4 = PROCDATA *
 move.l   d0,d7                    ; Signalnummer
 move.l   a2,a3                    ; struct sigaction
 move.l   pr_sigmask(a4),ap_oldsigmask(a6)   ; alte Signalmaske merken

 move.l   sa_sigextra(a3),d0
 or.l     d0,pr_sigmask(a4)             ; zusaetzliche Signale sperren
 move.l   pr_sigpending(a4),d0
 bclr     d7,d0
 move.l   d0,pr_sigpending(a4)          ; Signal ist bearbeitet
 move.l   d7,ap_tail(a6)                ; param ist Signalnummer
 move.l   sa_handler(a3),ap_cmd(a6)     ; proc
 bra      restart_signal                ; naechstes Signal

*
* Es liegen keine weiteren Signale an
*

no_further_sigs:
 move.l   act_pd.l,a5
 move.l   p_app(a5),a1             ; mein Haupt-Thread
 move.l   ap_sigthr(a6),a4         ; Vorgaenger
 clr.l    ap_sigthr(a1)
 cmpa.l   a1,a4                    ; Vorgaenger ist Haupt-Thread ?
 beq.b    endsig_waslast           ; ja, keine Schachtelung
 move.l   a4,ap_sigthr(a1)         ; nein, Vorgaenger ist jetzt Signalhandler
 bra.b    endsig_weiter
endsig_waslast:
 move.l   a5,a0
 bsr      cont_pd_threads          ; alle wartenden Threads wieder starten
endsig_weiter:
 move.l   a4,a0
 jsr      cnt_thr                  ; Vorgaenger wieder starten

endsig_pd_invalid:
 move.w   ap_id(a6),d0
 bsr      vt52_uninherit           ; aus VT52- Fensterliste austragen

 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; Interrupts sperren
;move.l   a6,a6
 bsr      appl_kill_events         ; ausstehende Events entfernen
 move.w   (sp)+,sr

 bsr      appl_wind_new            ; end_update/Fenster/Menue/Desktop

 bra      pgml_term_thread         ; sang- und klanglos terminieren


**********************************************************************
*
* void start_acc( void )
*
* Startet ein Accessory (act_appl).
* Wichtig: Das ACC bekommt in a0 einen Zeiger auf die Basepage
* Wird nur beim ersten Starten eines ACC aufgerufen
*
* Setzt jetzt auch den aktuellen Pfad korrekt!
* Setzt den Programmnamen
*
* Die APPL-Struktur gehoert dem jeweiligen ACC-Prozess.
* Der mit Modus EXACC gestartete Prozess ist sein eigener
* Eigner. Er wird aber _NICHT_ vom DOS entfernt. Sondern erst
* von pgml_afterexec.
*

start_acc:
 suba.l   a0,a0
 move.l   a0,usp                   ; usp = NULL (->Kontext des ACC)
 movea.l  act_appl,a6
 lea      ap_cmd(a6),a0
 bsr      dsetdrv_path
 clr.l    -(sp)                    ; kein Environment
 move.l   ap_pd(a6),-(sp)          ; PD
 clr.l    -(sp)                    ; kein Name
 move.w   #108,-(sp)               ; XEXE_EXACC
 move.w   #$4b,-(sp)
 trap     #1                       ; gemdos Pexec(EXACC)
 adda.w   #16,sp

 moveq    #1,d7                    ; vorher kein Desktop
 moveq    #0,d6                    ; nicht single mode
;move.l   a6,a6                    ; a6 = act_appl
 movea.l  ap_pd(a6),a5             ; a5 = zugehoeriger PD
                                   ; diesen Prozess loeschen!
 moveq    #EBREAK,d0
 bra      pgml_afterexec           ; hier sollte usp noch NULL sein


**********************************************************************
*
* void start_parall_proc( void )
*
* Startet einen parallelen Prozess (act_appl).
*
* Die APPL-Struktur gehoert dem jeweiligen Prozess.
* Der mit Modus XXEXE_EX gestartete Prozess ist sein eigener
* Eigner. Er wird aber _NICHT_ vom DOS entfernt. Sondern erst
* von pgml_afterexec.
*

start_parall_proc:
 movea.l  act_appl,a6
 clr.l    -(sp)                    ; dummy
 move.l   ap_pd(a6),-(sp)          ; PD
 clr.l    -(sp)                    ; dummy
 move.w   #300,-(sp)               ; XXEXE_EX
 move.w   #$4b,-(sp)
 trap     #1                       ; gemdos Pexec(EXACC)
 adda.w   #16,sp

 move.l   d0,-(sp)                 ; Rueckgabewert der APP merken
 move.w   ap_id(a6),d0
 bsr      vt52_uninherit           ; aus VT52- Fensterliste austragen
 move.l   (sp)+,d0                 ; Rueckgabewert der APP

 moveq    #1,d7                    ; vorher kein Desktop
 moveq    #0,d6                    ; nicht single mode
;move.l   a6,a6                    ; a6 = act_appl
 movea.l  ap_pd(a6),a5             ; a5 = zugehoeriger PD
                                   ; diesen Prozess loeschen!
 bra      pgml_afterexec


**********************************************************************
*
* int inform_aes_recgn(d0 = int 4, d1 = int isgr, d2 = int isover,
*                a0 = char *cmd, a1 = char *tail)
*
* (doex Mode 9)
*
* d1:     Bitvektor fuer verstandene Nachrichten
*
* Ein Programm hat shel_write() mit doex=9 aufgerufen.
* Diese Funktion informiert das AES, ob AP_TERM verstanden wird.
* Bit 0 von isgr: "verstehe AP_TERM"
*

inform_aes_recgn:
 move.l   act_appl,a0
 move.w   d1,ap_recogn(a0)         ; Bitvektor fuer verstandene Codes
 moveq    #1,d0
 rts


**********************************************************************
*
* EQ/NE enab_warmb( void )
* void disa_warmb( void )
*
* Schaltet den Ctrl-Alt-Del- Sprungvektor um
*

enab_warmb:
 tst.l    old_warmbvec
 beq.b    enwab_ende
 move.l   old_warmbvec,warmbvec         ; Naechstes Mal Reset machen
 clr.l    old_warmbvec                  ; warmboot pending
enwab_ende:
 rts

disa_warmb:
 tst.l    old_warmbvec
 bne.b    diwab_ende
 move.l   warmbvec,old_warmbvec
 move.l   #warmb_hdl,warmbvec
diwab_ende:
 move.w   #-1,shutdown_id          ; kein Shutdown-Modus
 rts


**********************************************************************
*
* void check_shutdown( d0 = int id )
*
* Testet nach jeder Beendigung einer Applikation <id> den Shutdown-
* Status.
*


check_shutdown:
 movem.l  d7/d6,-(sp)
 move.w   d0,d7
 tst.w    shutdown_id              ; shutdown Modus ?
 bmi.b    cshut_ende               ; nein
; suche nach nicht terminierten Programmen
 clr.l    -(sp)
 clr.l    -(sp)                    ; word[4] = word[5] = word[6] = word[7] = 0
 moveq    #1,d2                    ; word[3]: Shutdown erfolgreich
 lea      applx,a0
 moveq    #NAPPS-1,d1
cshut_tloop:
 move.l   (a0)+,d6                 ; Slot unbenutzt
 ble.b    cshut_tnext
 move.l   d6,a1
 move.w   ap_id(a1),d0             ; Ziel-ID
 cmp.w    shutdown_id,d0           ; ist Initiator ?
 beq.b    cshut_tnext              ; ja, ueberschlagen
 cmp.w    d7,d0                    ; terminiert gerade ?
 beq.b    cshut_tnext              ; ja, ueberschlagen
 btst     #0,ap_recogn+1(a1)       ; versteht AP_TERM ?
 bne.b    cshut_ende2              ; ja, Ende
 move.l   ap_pd(a1),d6             ; APP ist Prozess ?
 beq.b    cshut_tnext              ; nein, ist unkritisch
 move.l   d6,a2
 tst.l    p_parent(a2)             ; ACC ?
 beq.b    cshut_tnext              ; ACCs sind unkritisch
 moveq    #0,d2                    ; merken: dumme APP ist im System
 move.w   #-1,(sp)                 ; word[4] = -1 (kein TFAIL von APP)
cshut_tnext:
 dbra     d1,cshut_tloop
; niemand versteht mehr AP_TERM => SHUT_COMPLETED
; dumme APP im System: FAIL, sonst OK
 move.w   d2,d6                    ; status merken
 move.l   sp,a0
;move.l   d2,d2                    ; shutdown erfolgreich bzw. nicht
 bsr.s    send_shutcompl
 tst.w    d6                       ; erfolgreich ?
 bne.b    cshut_ende2              ; ja
 bsr.s    disa_warmb               ; nein, Shutdown-Modus deaktivieren
cshut_ende2:
 addq.l   #8,sp
cshut_ende:
 movem.l  (sp)+,d6/d7
 rts


**********************************************************************
*
* void send_shutcompl(d2 = int success, a0 = int *buf)
*

send_shutcompl:
 move.w   shutdown_id,d1           ; Ziel-ID
 moveq    #SHUT_COMPLETED,d0
 tst.w    shutdown_dev             ; Aufloesungswechsel
 bmi.b    cshut_onld               ; nein
 moveq    #RESCH_COMPLETED,d0      ; ja!
cshut_onld:
 jmp      send_msg


**********************************************************************
*
* int inform_aes_recgn(d0 = int 4, d1 = int isgr, d2 = int isover,
*                a0 = char *cmd, a1 = char *tail)
*
* (doex Mode 10)
*
* a0:     Zeiger auf Nachrichtenpuffer
*
* Ein Programm hat shel_write() mit doex=10 aufgerufen.
* Diese Funktion schickt dem AES eine Nachricht.
*
* Zur Zeit wird nur ausgewertet:
*
*  AP_TFAIL
*

send_aes_msg:
 cmpi.w   #AP_TFAIL,(a0)
 bne.b    saem_ende
; AP_TFAIL
 tst.w    shutdown_id              ; shutdown-Modus ?
 bmi.b    saem_ende                ; nein
 clr.l    -(sp)                    ; buf[6,7]
 move.w   2(a0),-(sp)              ; buf[5] = Fehlercode
 move.l   act_appl,a1
 move.w   ap_id(a1),-(sp)          ; buf[4] = ap_id des "Stoerers"

 move.l   sp,a0
 moveq    #0,d2                    ; Fehler !
 bsr.s    send_shutcompl
 addq.l   #8,sp

saem_ende:
 bsr      disa_warmb               ; Ctrl-Alt-Del => shutdown
 moveq    #1,d0
 rts


**********************************************************************
*
* int broadcast(a0 = int *msg, d0 = int initiator_apid)
*
* (doex Mode 7)
*
* Verschickt die Nachricht an alle Applikationen ausser
* SCRENMGR und den Initiator
*

broadcast2:
 move.l   act_appl,a1
 move.w   ap_id(a1),d0
broadcast:
 movem.l  a5/d7,-(sp)
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 lea      applx,a5
 moveq    #NAPPS-1,d7
broadc_tloop:
 move.l   (a5)+,d2
 ble.b    broadc_tnext             ; Slot unbenutzt
 move.l   d2,a1
 move.w   ap_id(a1),d1             ; Ziel-ID
 cmpi.w   #1,d1                    ; SCRENMGR ?
 beq.b    broadc_tnext             ; ja, nicht schicken
 cmp.w    (sp),d1                  ; ist Initiator ?
 beq.b    broadc_tnext             ; ja, ueberschlagen
 move.l   2(sp),a0                 ; message
 moveq    #16,d0                   ; 16 Bytes
;move.w   d1,d1                    ; dst_apid
 jsr      appl_write
broadc_tnext:
 dbra     d7,broadc_tloop
 addq.l   #6,sp
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* int shutdown_res(d0 = int 5, d1 = int isgr, d2 = int isover,
*                a0 = char *cmd, a1 = char *tail)
*
* (doex Mode 5)
*
*  MultiTOS:
* d2 == 0:     d1 ist der VDI-Treiber fuer den Aufloesungswechsel
* d2 == 1:     d1 ist der Videomodus fuer den Falcon
*  MagiC 3:
* d2 >= 100:   d1 ist der VDI-Treiber
*              d2 - 100 ist die Texthoehe
* stattdessen MagiC 4:
* d2.bit0:     0 oder 1 wie oben
* d2.bit1..4:  device
* d2.hi:       Texthoehe
*

shutdown_res:
 move.w   d2,d0
 lsr.w    #8,d0
 move.w   d0,shutdown_txt          ; Texthoehe im Hibyte von <isover>
 clr.w    shutdown_xdv             ; kein Falcon-Modus
 tst.b    d2                       ; VDI-Device ?
 beq.b    shut_start               ; ja, dieses benutzen
;Falcon-Kram
 move.w   d1,shutdown_xdv          ; Falcon-Modus statt device
 moveq    #5,d1                    ; VDI-Device fuer Falcon
 move.b   d2,d0
 andi.w   #$1e,d0                  ; device angegeben ?
 beq.b    shut_start               ; nein, Device 5 nehmen
 lsr.w    #1,d0
 move.w   d0,d1                    ; device aus Bit 1..4 holen
 bra.b    shut_start


**********************************************************************
*
* int shutdown(d0 = int 4, d1 = int isgr, d2 = int isover,
*                a0 = char *cmd, a1 = char *tail)
*

* (doex Mode 4)
*
* d1 != 0:     shutdown einleiten
*              (MultiTOS unterscheidet hier zwischen:
*                   1 == partial shutdown (kein AP_TERM an ACCs)
*                   2 == complete shutdown
* d1 == 0:     shutdown abbrechen
*

; Shutdown abbrechen
shut_cancel:
 move.l   act_appl,a0
 move.w   ap_id(a0),d0
 cmp.w    shutdown_id,d0
 bne.b    shut_err                 ; Fehler, bin nicht Initiator
 bsr      disa_warmb
 moveq    #1,d0
 rts
shut_err:
 moveq    #0,d0
 rts

shutdown:
 tst.w    d1                       ; shutdown einleiten ?
 beq.b    shut_cancel              ; nein, abbrechen

*
* Shutdown einleiten
*    a0 = act_appl
*    a1 = &shutdown_id
*    d1 = dev
*    d0 = ap_id
*

shut_startw:
 moveq    #-1,d1
shut_start:
 move.l   act_appl,a0
 move.w   ap_id(a0),d0
 lea      shutdown_id,a1
 tst.w    (a1)                     ; shutdown schon aktiv ?
 bge.b    shut_err                 ; ja!
;cmpa.l   upd_blockage+bl_app,a0   ; habe ich BEG_UPDATE ?
;beq      shut_err                 ; ja, Fehler !!!
 move.w   d0,(a1)                  ; shutdown Initiator eintragen
 move.w   d1,shutdown_dev
 bsr      enab_warmb               ; Ctrl-Alt-Del => Warmstart

 bsr      unfreeze_all_apps        ; alle Applikationen auftauen
 moveq    #-1,d0                   ; niemand terminiert gerade
 bsr      check_shutdown           ; ob ueberhaupt jemand AP_TERM kann ?

 clr.l    -(sp)
 move.w   #AP_TERM,-(sp)           ; buf[5] = Grund fuer AP_TERM: shutdown
 tst.w    shutdown_dev             ; Aufloesungswechsel
 bmi.b    shut_onld                ; nein
 move.w   #AP_RESCHG,(sp)          ; ja!
shut_onld:
 clr.w    -(sp)                    ; buf[4]
 move.w   shutdown_id,-(sp)        ; buf[3]: egal (ap_id des Initiators)
 clr.w    -(sp)                    ; buf[2]: Ueberlaenge
 movea.l  act_appl,a2
 move.w   ap_id(a2),-(sp)          ; buf[1] = id des Senders
 move.w   #AP_TERM,-(sp)           ; buf[0] = Nachrichtentyp
 move.l   sp,a0
 move.w   shutdown_id,d0
 bsr      broadcast
 adda.w   #16,sp

 moveq    #1,d0
 rts


**********************************************************************
*
* void appl_break( void )
*

appl_break:
 move.l   act_appl,a6
 moveq    #EBREAK,d7
 move.l   ap_pd(a6),a0
 move.l   a0,d0
 beq      end_thread               ; kein PD ???

 cmpa.l   p_app(a0),a6             ; main thread ?
 beq.b    appl_break_mainthr       ; ja => Pterm
 move.w   ap_type(a6),d0
 subq.w   #2,d0
 beq      end_signal               ; 2: signal
 bra      end_thread               ; Thread
appl_break_mainthr:
 move.l   etv_term,a0
 lea      -12(a0),a0
 cmpi.l   #'XBRA',(a0)+
 bne.b    apbr_no_xbra
 cmpi.l   #'KLME',(a0)+
 bne.b    apbr_no_xbra
 move.l   (a0),etv_term            ; Programm deinstallieren
apbr_no_xbra:
 move.w   d7,-(sp)
 move.w   #$4c,-(sp)
 trap     #1                       ; Pterm(EBREAK)


**********************************************************************
*
* void wait_vt52( void )
*
* wartet max. 10s auf den vt52.
* Rueckgabe 1:  OK
*          0:  vt52 nicht da.
*

wait_vt52:
 move.l   timer_cnt,d1
 add.l    #50*10,d1                ; warte max. 10 s
wvt_loop:
 move.l   act_appl,a0
 cmpi.b   #$47,ap_isgr(a0)         ; Programm vom VT52 gebremst ?
 bne.b    wvt_ok
 jsr      appl_yield
 cmp.l    timer_cnt,d1
 bcc.b    wvt_loop
 moveq    #0,d0
 rts
wvt_ok:
 moveq    #1,d0
 rts


**********************************************************************
*
* Programmlade- "Accessory"
* Wird im Supervisormodus gestartet
*
* d7: long     letzer Fehler
* d6: byte     single mode
*


pgml_unfreeze:
 tst.b    d6                       ; noch single mode ?
 beq.b    pgml_3                   ; nein
 bsr      unfreeze_all_apps        ; single mode abschalten
 swap     d6
 move.w   d6,pe_slice              ; Praeemption restaurieren
 move.w   d6,pe_timer
 sf       d6                       ; single als abgeschaltet markieren
pgml_3:
 rts

pgm_loader:
 movea.l  act_appl,a6              ; a6 = zugehoerige APPL
 movea.l  ap_pd(a6),a5             ; a5 = zugehoeriger PD
 move.w   curr_scrmode,ap_wasgr(a6)
 moveq    #0,d7                    ; kein letzter Fehler
 moveq    #0,d6                    ; noch kein single mode

 bsr.b    wait_vt52
 bne.b    pgml_loop                ; OK
 clr.w    ap_isgr(a6)              ; Fehler: Programm im TOS- Modus starten

pgml_loop:
 clr.w    ap_recogn(a6)            ; verstandene Nachrichten: keine

 bsr      init_FPU

                                   ; erst weiter, wenn alle anderen Programme
 bsr      update_1                 ;  die Menues entsperrt haben
 st       inaes
 bsr      update_0
 sf       inaes

 tst.w    ap_doex(a6)              ; Programm starten ?
 bne.b    pgml_start               ; ja, ok
 tst.w    ap_id(a6)                ; bin APPL #0 ?
 bne      pgml_term                ; nein, Loader beenden!

* doex = 0, ap_id = 0: DESKTOP starten

 move.w   #ap_xtail,d1
 moveq    #0,d0                    ; kein neuer Block
;move.l   a6,a6
 bsr      __resvldmem              ; ap_xtail freigeben

 lea      shel_name,a0
 lea      ap_cmd(a6),a1
shl_cpshloop:
 move.b   (a0)+,(a1)+              ; ggf. leeren Namen kopieren
 bne.b    shl_cpshloop
 lea      ap_tail(a6),a1
 clr.w    (a1)+                    ; In der Basepage steht dann nichts
 move.l   #'SHEL',(a1)+            ; magic: ich bin die Shell
 move.w   shel_isfirst,(a1)+       ; ob erster Aufruf
 clr.w    shel_isfirst
 move.l   d7,(a1)+                 ; letzten Fehler uebergeben
 move.w   ap_wasgr(a6),(a1)

pgml_start:
 bsr      switch_gr_txt

 move.w   ap_doex(a6),d7           ; merken, ob DESKTOP
 bne.b    pgml_1
 bsr      pgml_unfreeze            ; single mode abschalten
pgml_1:

 clr.w    ap_doex(a6)

 lea      ap_cmd(a6),a0
 jsr      fn_name
 tst.b    (a0)
 bne.b    pgml_name                ; Name gueltig => Programm starten
 moveq    #0,d0
 tst.w    ap_id(a6)                ; bin APPL #0 ?
 bne      pgml_afterexec           ; nein, Loader beenden, kein Fehler

* integrierter DESKTOP (MAGXDESK)

 bsr      pgml_unfreeze            ; single mode abschalten
 clr.l    ap_memlimit(a6)
 clr.l    ap_flags(a6)             ; kann prop.Zeichensaetze
 clr.l    -(sp)
 move.w   #LIM_MEMHEAP,-(sp)
 gemdos   Psetlimit                ; ggf. Speicherbeschraenkung ausschalten
 addq.l   #8,sp
 lea      desktop_s(pc),a1
 move.l   a6,a0
 bsr      set_apname               ; "MAGXDESK.APP" als Applikationsname
 lea      desktop_s(pc),a0
 bsr      male_startbild
 move.l   shel_vector,a0
 move.l   a0,d0
 bne.b    pgml_vector
 lea      d_desktop,a0
pgml_vector:
 jsr      (a0)
 tst.l    d0
 bge.b    pgml_shl_ok
 clr.l    shel_vector
pgml_shl_ok:
 bra      pgml_afterexec

pgml_name:
 move.l   a0,-(sp)                 ; Name merken
 move.l   a0,a1
 move.l   a6,a0
 bsr      set_apname

 move.l   ap_memlimit(a6),-(sp)
 move.w   #LIM_MEMHEAP,-(sp)
 gemdos   Psetlimit                ; ggf. Speicherbeschraenkung aktivieren
 addq.l   #8,sp

 tst.w    d7
 beq.b    pgml_no_single           ; war Desktop!
 tst.b    d6
 bne.b    pgml_no_single           ; ist schon single mode
 cmpi.w   #101,ap_isover(a6)       ; single mode ?
 bne.b    pgml_no_single
 move.w   pe_slice,d6
 move.w   #-1,pe_slice             ; Praeemption abschalten
 swap     d6                       ; im Hiword von d6 merken
 bsr      freeze_all_apps
 st       d6                       ; merken, dass single war!
pgml_no_single:

 move.l   (sp)+,a0                 ; Dateiname
 bsr      male_startbild

 move.l   ap_env(a6),-(sp)         ; Environment
 bgt.b    pgml_env_ok              ; ist gueltig
 move.l   _basepage,a0
 move.l   $2c(a0),(sp)             ; Environment des AES benutzen
pgml_env_ok:
 move.l   ap_xtail(a6),-(sp)       ; erweiterte Kommandozeile ?
 bgt.b    pgml_xtl_ok              ; ist gueltig
 lea      ap_tail(a6),a0
 move.l   a0,(sp)                  ; einfache Kommandozeile benutzen
pgml_xtl_ok:
 pea      ap_cmd(a6)
 clr.w    -(sp)                    ; LOAD+EXEC
 move.w   #$4b,-(sp)
 trap     #1                       ; gemdos Pexec (EXE_LDEX)
 lea      16(sp),sp


*********************************************************************
*
* Beendet einen Task.
*
*    a6        APPL *
*    a5        PD *  bzw. NULL bei Threads
*    d0.l      retcode
*    d7.w      Flag "Es ist die Systemshell, die beendet wird"
*
* Hier springt auch die Beendigung von Threads und ACCs rein
*

pgml_afterexec:
 move.l   dflt_etvt,etv_term       ; Default- etv_term setzen
 move.w   sr,-(sp)
 ori.w    #$700,sr                 ; Interrupts sperren

 move.l   d0,-(sp)
;move.l   a6,a6
 bsr      appl_kill_events
 bsr      init_FPU
 move.l   (sp)+,d0                 ; Rueckgabewert der Applikation

 tst.w    d0
 bge.b    pgml_nocanc              ; kein Fehler
 tst.w    d7                       ; vorher DESKTOP gestartet ?
 bne.b    pgml_nocanc              ; nein
 clr.b    shel_name                ; ja, fehlerhaftes DESKTOP abmelden
pgml_nocanc:

 move.w   (sp)+,sr

 move.l   d0,d7                    ; Fehlercode merken
 bsr      appl_wind_new            ; end_update/Fenster/Menue/Desktop

 move.w   ap_id(a6),d0
 cmp.w    shutdown_id,d0           ; terminiert shutdown-Initiator ?
 bne.b    eapl_noshut              ; nein
 tst.w    shutdown_dev             ; Aufloesungswechsel ?
 bmi.b    eapl_wasshut             ; nein
 move.w   shutdown_dev,d0
 move.w   shutdown_txt,d1
 move.w   shutdown_xdv,d2
;bsr      change_resolution        ; ordentlicher Aufloesungswechsel!
 jmp      change_resolution        ; dann kommt der "rts"
;rts

eapl_wasshut:
 bsr      disa_warmb
eapl_noshut:
;move.w   d0,d0
 bsr      check_shutdown           ; ggf. SHUT_COMPLETED verschicken

 tst.w    ap_id(a6)
 beq      pgml_loop                ; APPL #0 bricht nie ab

/* das folgende verstehe ich nicht mehr:
 tst.w    d7                       ; auch Rueckgabewerte auswerten!
 bge      pgml_loop
*/
 tst.w    ap_doex(a6)              ; Programm starten ?
 bne      pgml_loop                ; ja, wieder in die Schleife

*
* Zu diesem Zeitpunkt ist wind_new() durchgefuehrt, d.h. wind_update()s der
* act_appl sind annulliert. Alle act_appl gehoerenden Fenster wurden
* geschlossen und freigegeben.
* Ausserdem wurden Menue und Hintergrund abgeschaltet, falls sie der act_appl
* gehoeren.
* Falls keine andere Applikation zur Verfuegung steht, die Menue oder
* Hintergrund besitzt, kann act_appl noch die menu_app sein sowie Maus-
* und Tastaturkontrolle haben. Diese werden ggf. auf den SCRENMGR
* umgebogen
*

pgml_term:
 bsr      pgml_unfreeze

 st       inaes                    ; Kontextwechsel verbieten

 tst.w    ap_wasgr(a6)
 beq.b    pgml_tidy_tos            ; TOS- Programme umschalten und aufraeumen
 cmpi.w   #EBREAK,d7
 bne.b    pgml_notidy              ; GEM- Programme nur bei EBREAK aufraeumen
 bra.b    pgml_tidy
pgml_tidy_tos:
 move.w   #1,ap_isgr(a6)
 bsr      switch_gr_txt            ; ggf. auf Grafik zurueckschalten...
pgml_tidy:
 bsr      tidy_up                  ; ... und Bildschirm aufraeumen

pgml_notidy:
 move.l   applx,a0
 move.l   ap_ssp(a0),sp            ; Stack der APPL #0 verwenden

 lea      applx,a1                 ; suche neuen aktiven GEMDOS- Prozess,
 moveq    #NAPPS-1,d1              ;  da der aktive gleich vernichtet wird
pgml_tloop:
 move.l   (a1)+,d0                 ; Slot unbenutzt
 ble.b    pgml_tnext
 cmpa.l   d0,a6
 beq.b    pgml_tnext               ; unsere eigene APPL
 move.l   d0,a0
 move.l   ap_pd(a0),d0
 bne.b    pgml_endtloop
pgml_tnext:
 dbra     d1,pgml_tloop

pgml_endtloop:
 move.l   d0,act_pd.l                ; neuen PD setzen, notfalls NULL (?)

 move.w   d7,d1                    ; exitcode
 move.w   ap_id(a6),d0
 bsr      exit_APPL                ; CH_EXIT verschicken

 move.l   a5,-(sp)
 clr.l    -(sp)
 move.l   #$4b0066,-(sp)           ; 102, Prozess loeschen (Basepage u. APPL)
 trap     #1                       ; gemdos Pexec (XEXE_TERM)
 lea      12(sp),sp

 move.w   sr,d1
 ori.w    #$700,sr
 move.l   (a6),act_appl            ; ap_next
 move.l   a6,a0
 bsr.s    appl_kill_struct
 move.w   d1,sr


_pgml_term_thread:
 sf.b     no_switch
 lea      act_appl,a4              ; wichtig!!
 suba.l   a3,a3                    ; wichtig!!
 jmp      ad__kernel               ; ^^^


**********************************************************************
*
* void appl_kill_struct(a0 = APPL *ap)
*
* Entfernt eine Applikation aus der Tabelle
*

appl_kill_struct:
 move.w   ap_id(a0),a0
 add.w    a0,a0
 add.w    a0,a0
 clr.l    applx(a0)                ; APPL- Eintrag loeschen
 subq.w   #1,appln
 rts


**********************************************************************
*
* void appl_kill_events(a6 = APPL *ap)
*
* Entfernt eine Applikation aus den Event-Wartelisten und loescht
* den Applikationsnamen
*

appl_kill_events:
 move.l   a6,a0
 lea      leerstring(pc),a1
 bsr      set_apname               ; Applikationsnamen loeschen
 move.l   a6,a0


**********************************************************************
*
* void _appl_kill_events(a0 = APPL *ap)
*
* Entfernt eine Applikation aus den Event-Wartelisten
*

_appl_kill_events:
 move.l   a0,-(sp)
 bsr      rmv_ap_timer             ; ausstehende Timerevents entfernen
 move.l   (sp),a0
 bsr      rmv_ap_alrm              ; ausstehende Alarme entfernen
 move.l   (sp),a0
 bsr      rmv_ap_io                ; ausstehende IO-Events entfernen
 move.l   (sp)+,a0
 bra      rmv_ap_sem               ; Semaphoren freigeben


**********************************************************************
*
* void appl_wind_new( d0 = long errcode, a6 = APPL *ap )
*
* Entfernt die wind_update-Semaphore und gibt alle Fenster,
* Menue und Desktophintergrund frei.
* Gibt Maus- und Tastaturkontrolle ab.
*

appl_wind_new:
 move.l   d0,-(sp)

 jsr      update_1

 move.l   (sp)+,d0
 bsr      pgm_err                  ; evtl. Fehlercodes anzeigen

pgml_no_serr:
 st       inaes                    ; Kontextwechsel verbieten
 bsr      wind_new                 ; aufraeumen, end_update

     IFEQ NEU_SUBMEN

 tst.l    xmenu_info
 beq.b    eapl_noxmen
 move.l   xmenu_info,a2
 move.l   20(a2),a2
 move.l   act_appl,a0
 move.w   ap_id(a0),-(sp)
 jsr      (a2)
 addq.l   #2,sp
eapl_noxmen:

     ENDIF

 cmpa.l   menu_app,a6              ; Eigner des Menues
 bne.b    pgml_no_menu
 move.l   applx+4,menu_app         ; SCRENMGR
pgml_no_menu:
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 cmpa.l   w_owner(a1),a6           ; Eigner des Desktop- Hintergrunds
 bne.b    pgml_no_wind0
 move.l   applx+4,w_owner(a1)      ; SCRENMGR
pgml_no_wind0:

 cmpa.l   topwind_app,a6
 beq.b    apwn_chg
 cmpa.l   mouse_app,a6
 beq.b    apwn_chg
 cmpa.l   keyb_app,a6
 bne.b    apwn_no_chg              ; unsere Applikation ist uninteressant
apwn_chg:
 bsr      set_topwind_app          ; Maus-/Tastaturkontrolle abgeben
apwn_no_chg:
 sf       inaes
 rts


**********************************************************************
*
* int stop_thread( a0 = APPL *app )
*
* Haelt eine Applikation an.
* Rueckgabe:    1, falls die Applikation im kritischen Zustand ist.
*              0 sonst
*

stop_thread:
 tst.b    ap_stpsig(a0)            ; bereits durch Signal gestoppt ?
 bmi.b    stpap_ende               ; ja, Ende

 tst.w    ap_critic(a0)            ; kritische Phase ?
 beq.b    stpap_nocritic           ; nein
 bset     #1,ap_crit_act(a0)       ; Flag fuer "muss anhalten"
 moveq    #1,d0                    ; ist kritisch
 rts
stpap_nocritic:
 st.b     ap_stpsig(a0)            ; durch Signal gestoppt
 jsr      stp_thr
stpap_ende:
 moveq    #0,d0                    ; OK
 rts


**********************************************************************
*
* void stop_pd_threads( a0 = PD *pd )
*
* Haelt alle Threads an, die zu dem Prozess gehoeren.
* In ap_oldsigmask des main thread wird die Signalmaske gesichert,
* dann alle Signale ausser UNMASKABLE+SIGTERM ausmaskiert.
*

stop_pd_threads:
 movem.l  a5/a6/d7,-(sp)
 move.l   a0,a5                    ; PD *
 move.l   p_procdata(a5),d0
 beq.b    stath_ende
 move.l   d0,a1                    ; a1 = PROCDATA *
 move.l   p_app(a5),a0             ; a0 = main thread
 tst.b    ap_stpsig(a0)            ; schon angehalten ?
 bmi.b    stath_loop2              ; ja, nix tun!
 move.l   pr_sigmask(a1),ap_oldsigmask(a0)   ; Signalmaske retten!
 move.l   #MASKWHILESTOP,pr_sigmask(a1)      ; Signalmaske umsetzen
stath_loop2:
 lea      applx,a6
 moveq    #0,d7
stath_loop:
 move.l   (a6)+,d0
 ble.b    stath_nxt                ; leer oder eingefroren
 move.l   d0,a0
 cmpa.l   ap_pd(a0),a5             ; unser Prozess ?
 bne.b    stath_nxt                ; nein

 bsr.b    stop_thread
stath_nxt:
 addq.w   #1,d7
 cmpi.w   #NAPPS,d7
 bcs.b    stath_loop
 jsr      appl_yield               ; hier legen wir uns ggf. schlafen
stath_ende:
 movem.l  (sp)+,a5/a6/d7
 rts


**********************************************************************
*
* void cont_thread( a0 = APPL *app )
*
* Fuehrt eine Applikation fort, die durch ein Signal angehalten ist.
*

cont_thread:
 bclr.b   #1,ap_crit_act(a0)       ; "Stopped" Bit loeschen
 tst.b    ap_stpsig(a0)            ; durch Signal gestoppt ?
 beq.b    contthr_ende             ; nein, Ende
 jsr      cnt_thr
contthr_ende:
 moveq    #0,d0                    ; OK
 rts


**********************************************************************
*
* void cont_pd_threads( a0 = PD *pd )
*
* Fuehrt alle Threads fort, die zu dem Prozess gehoeren
*

cont_pd_threads:
 movem.l  a5/a6/d7,-(sp)
 move.l   a0,a5                    ; PD *
 move.l   p_procdata(a5),d0
 beq.b    coath_ende
 move.l   d0,a1                    ; a1 = PROCDATA *
 move.l   p_app(a5),a0             ; a0 = main thread
 tst.b    ap_stpsig(a0)            ; angehalten ?
 bge.b    coath_loop2              ; nein, nix tun
 move.l   ap_oldsigmask(a0),pr_sigmask(a1)   ; Signalmaske zurueck
 andi.l   #!STOPSIGS,pr_sigpending(a1)       ; haltende Signale loeschen
coath_loop2:
 lea      applx,a6
 moveq    #0,d7
coath_loop:
 move.l   (a6)+,d0
 ble.b    coath_nxt                ; leer oder eingefroren
 move.l   d0,a0
 cmpa.l   ap_pd(a0),a5             ; unser Prozess ?
 bne.b    coath_nxt                ; nein

 bsr.b    cont_thread
coath_nxt:
 addq.w   #1,d7
 cmpi.w   #NAPPS,d7
 bcs.b    coath_loop
coath_ende:
 movem.l  (sp)+,a5/a6/d7
 rts


**********************************************************************
*
* int kill_thread( a0 = APPL *app )
*
* Entfernt eine Applikation.
* Rueckgabe:    1, falls die Applikation im kritischen Zustand ist.
*              0 sonst
*

kill_thread:
 tst.w    ap_critic(a0)            ; kritische Phase ?
 beq.b    scapi_nocritic           ; nein
 bset     #0,ap_crit_act(a0)       ; Flag fuer "muss terminieren"
 moveq    #1,d0                    ; ist kritisch
 rts
scapi_nocritic:
 cmpa.l   act_appl,a0              ; laufe ich gerade ?
 beq      appl_break               ; ja, ich beende mich
 move.l   a0,-(sp)
 move.l   #appl_break,d0
 bsr      init_ap_startadr         ; Startadresse aendern
 move.l   (sp)+,a0
 jsr      app2ready
 moveq    #0,d0                    ; OK
 rts


**********************************************************************
*
* void pkill_threads( a0 = PD *pd )
*
* Entfernt alle Threads ausser dem aktuellen,
* die zu einem Prozess gehoeren.
* Wird von DOS aufgerufen (PDkill).
*

pkill_threads:
 movem.l  a4/a5/a6/d6/d7,-(sp)
 move.l   a0,a5                    ; PD *
kat_loop:
 lea      applx,a6
 moveq    #0,d7
 sf       d6                       ; nix gefunden
kith_loop:
 move.l   (a6)+,d0
 ble.b    kith_nxt                 ; leer oder eingefroren
 cmp.l    act_appl,d0
 beq.b    kith_nxt                 ; aktuelle Applikation
 move.l   d0,a4
 cmpa.l   ap_pd(a4),a5             ; unser Prozess ?
 bne.b    kith_nxt                 ; nein

 move.l   _basepage,-(sp)          ; PD
 move.l   a4,-(sp)                 ; APPL
 move.l   #$00330003,-(sp)         ; Sconfig(SC_OWN,...)
 trap     #1                       ; Eigner der APPL wird jetzt das AES!
 lea      12(sp),sp

 move.l   ap_thr_usp(a4),d0
 beq.b    kith_no_usp
 clr.l    ap_thr_usp(a4)
 move.l   d0,a0
 jsr      mfree                    ; usp eines Thread freigeben
kith_no_usp:
 move.l   a4,a0
 bsr.b    kill_thread
 tst.b    d0                       ; kritisch?
 bne.b    kith_was_crit            ; ja, ap_pd nicht anfassen
 clr.l    ap_pd(a4)                ; ap_pd ungueltig machen
kith_was_crit:
 or.b     d0,d6                    ; kritische APPLs merken
kith_nxt:
 addq.w   #1,d7
 cmpi.w   #NAPPS,d7
 bcs.b    kith_loop
 tst.b    d6                       ; waren kritische ?
 beq.b    kith_ende                ; nein
 move.w   #499,d6
kat_yieldloop:
 jsr      appl_yield               ; 500 Yields machen
 dbra     d6,kat_yieldloop
 bra.b    kat_loop                 ; und nochmal reingehen
kith_ende:
 movem.l  (sp)+,a4/a5/a6/d6/d7
 rts


**********************************************************************
*
* void pgm_err(d0 = long err)
*
* Fehlercodes werden in GEM- Programmen immer, in TOS- Programmen nur
* dann angezeigt, wenn sie auf Tastendruck warten sollen
*

pgm_err:
 move.l   act_appl,a0
 tst.w    ap_type(a0)              ; main thread ?
 bne.b    pge_ende                 ; nein!
 tst.w    ap_wasgr(a0)
 bne.b    pge_wasgem
* Programm war unter DOS gelaufen
 movem.l  d0/a0,-(sp)
 tst.l    d0
 bne      pge_wait
 btst     #0,(config_status+2).w
 bne.b    pge_nowait
pge_wait:
 bsr      waitkey
pge_nowait:
 bsr      graph_mode
 movem.l  (sp)+,d0/a0
* Programm war unter GEM gelaufen
pge_wasgem:
 tst.w    d0
 bge.b    pge_ende
 lea      ap_cmd(a0),a0            ; Programmdatei
 move.l   d0,d1
 swap     d1
 tst.w    d1                       ; Hiword negativ
 bmi.b    pge_err                  ; ja, Systemfehler
 lea      -1,a0                    ; Programm- Rueckgabewert
pge_err:
;move.l   d0,d0
 jsr      form_xerr
pge_ende:
 rts


**********************************************************************
*
* void switch_gr_txt( void )
*


switch_gr_txt:

 move.l   act_appl,a0
 move.l   a0,-(sp)
 tst.w    ap_doex(a0)
 bne.b    sgt_user
 move.w   #1,ap_isgr(a0)           ; Desktop laeuft IMMER im Grafikmodus
sgt_user:
 tst.w    ap_isgr(a0)              ; TOS- Programme sperren den
 bne.b    sgt_no_waitupd           ;  Bildschirm
 move.l   a0,-(sp)
                                   ; erst weiter, wenn alle anderen Programme
 bsr      update_1                 ;  die Menues entsperrt haben
 move.l   (sp)+,a0
sgt_no_waitupd:
 move.w   ap_wasgr(a0),d0
 cmp.w    ap_isgr(a0),d0
 beq.b    sgt_ende
* Bildschirmmodus (Grafik/Text) hat sich geaendert
 tst.w    d0
 beq.b    sgt_t_g
* Bildschirmmodus hat sich von Grafik -> Text geaendert
 bsr      text_mode
 bra.b    sgt_ende
sgt_t_g:
* Bildschirmmodus hat sich von Text -> Grafik geaendert
 bsr      graph_mode
sgt_ende:
 move.l   (sp)+,a0
 move.w   ap_isgr(a0),ap_wasgr(a0) ; neuer ist jetzt aktueller Wert
 beq.b    sgt_ende_tos
* Das Programm soll im Grafikmodus laufen
 clr.w    -(sp)
 move.w   #21,-(sp)
 trap     #14                      ; Cursconf(CURS_HIDE)
 addq.w   #4,sp
 jmp      reset_mouse
sgt_ende_tos:
 rts


**********************************************************************
*
* long d_desktop(void)
*
* Ist das rudimentaere ROM- Desktop, das versucht, eine Shell zu finden
*

root_path:
 DC.B     92,0
desktop_path:
 DC.B     '\GEMSYS\GEMDESK',0
desktop_s:
 DC.B     'MAGXDESK.APP',0
 EVEN

d_desktop:
* Zunaechst wird das Bootlaufwerk das aktuelle
 move.b   aes_bootdrv,d0
 ext.w    d0
 move.w   d0,-(sp)
 move.w   #$e,-(sp)
 trap     #1                       ; Dsetdrv
 addq.l   #4,sp
* Dann setzen wir das Wurzelverzeichnis als Pfad
 pea      root_path(pc)            ; "\\"
 move.w   #$3b,-(sp)
 trap     #1                       ; Dsetpath
 addq.l   #6,sp
* Jetzt setzen wir das Desktop- Verzeichnis als Pfad.
* Falls es nicht existiert, bleibt das Wurzelverzeichnis aktueller Pfad!
 pea      desktop_path(pc)         ; "GEMSYS\GEMDESK"
 move.w   #$3b,-(sp)
 trap     #1                       ; Dsetpath
 addq.l   #6,sp
 clr.l    -(sp)                    ; akt. Env.
 move.l   act_appl,a0
 pea      ap_tail(a0)              ; Kommandozeile
 pea      desktop_s(pc)            ; "MAGXDESK.APP"
 move.l   #$4b0000,-(sp)
 trap     #1                       ; Pexec (EXE_LDEX)
 lea      16(sp),sp
 tst.l    d0
 beq.b    d_d_ok                   ; kein noch so winziger Fehler
* kein Programm gefunden
 moveq    #0,d0                    ; Overlay

 bsr      fsel_app                 ; Programm auswaehlen
 moveq    #0,d0                    ; kein Fehler
d_d_ok:
 rts


**********************************************************************
*
* void bios_putch(d0 = char c)
*
*  Druckt das Zeichen nach Device 2 (CON)
*

bios_putch:
 move.w   d0,-(sp)
 move.w   #2,-(sp)
 move.w   #3,-(sp)
 trap     #13                      ; bios Bconout
 addq.l   #6,sp
 rts


**********************************************************************
*
* void prtstr(a0 = char *s)
*
*  Druckt die Zeichen in a0[] nach Device 2 (CON)
*

prs_putch:
 move.l   a0,-(sp)
 bsr.b    bios_putch
 move.l   (sp)+,a0
prtstr:
 move.b   (a0)+,d0
 bne.b    prs_putch
 rts


**********************************************************************
*
* void wait(a0 = char *s)
*
*  Druckt die Zeichen in a0[] nach Device 2 (CON) und wartet
*

     IF   COUNTRY=COUNTRY_DE
waitkeys: DC.B $1b,'e',$d,$a,'Taste dr',$81,'cken : ',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
waitkeys: DC.B $1b,'e',$d,$a,'press any key : ',0
     ENDIF
     IF   COUNTRY=COUNTRY_FR
waitkeys: DC.B $1b,'e',$d,$a,'Appuyez sur une touche : ',0
     ENDIF
     EVEN

waitkey:
 lea      waitkeys(pc),a0
wait:
 bsr.s    prtstr
_wait:
 move.w   #2,-(sp)
 move.w   #1,-(sp)
 trap     #13                      ; bios Bconstat
 addq.w   #4,sp
 tst.w    d0
 bne.b    is_key
 DC.W     $a000
 btst.b   #0,-$253(a0)
 bne.b    is_klick
 bra.b    _wait
is_key:
 move.w   #2,-(sp)
 move.w   #2,-(sp)
 trap     #13                      ; bios Bconin
 addq.w   #4,sp
is_klick:
 rts


**********************************************************************
*
* void kill_tree_structure( d0 = int count, a0 = OBJECT *tree )
*
* aendert nur d1/d0/a0
*

kill_tree_structure:
 moveq    #-1,d1
 bra.b    klts_loop_cont
klts_loop:
 move.l   d1,(a0)+                 ; ob_next,ob_head
 move.w   d1,(a0)                  ; ob_tail
 lea      20(a0),a0                ; 24-4
klts_loop_cont:
 dbra     d0,klts_loop
 rts


**********************************************************************
*
* void set_topwind_app( void )
*
* Setzt die Applikation
*    des obersten Fensters
*    bzw. des Menues
* als tastaturaktiv und mausknopfaktiv
*

set_topwind_app:
 move.w   topwhdl,d0               ; aktives Fenster gueltig ?
 bgt.b    sta_istop                ; ja, dessen Eigner nehmen
 move.l   menu_app,a0              ; Eigner des Menues
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 lea      w_hslide(a1),a1          ; leeres GRECT
 tst.l    menutree                 ; Menuebaum da ?
 bne.b    sta_app                  ; ja, Tasten an Menue
 moveq    #0,d0                    ; kein aktives Fenster, nimm Fenster #0

sta_istop:
 bsr      whdl_to_wnd
 move.l   a0,a1
 move.l   w_owner(a1),a0           ; zustaendige Applikation
 btst     #WSTAT_ICONIFIED_B,w_state+1(a1)   ; iconified ?
 beq.b    sta_apok
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 lea      w_hslide(a1),a1          ; leeres GRECT
 bra.b    sta_app
sta_apok:
 lea      w_work(a1),a1
sta_app:
;move.l   a0,a0
 tst.w    beg_mctrl_cnt
 beq      _set_topwind_app
 move.l   a0,mctrl_karett
 lea      mctrl_btrett,a0          ; geretteter Fensterbereich
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)
 rts


**********************************************************************
*
* void appl_end_mctrl( a0 = APPL *ap )
*
* Gibt ggf. die Mauskontrolle frei, falls diese von <ap> geholt
* worden ist.
*

appl_end_mctrl:
 lea      upd_blockage,a1
 cmpa.l   bl_app(a1),a0            ; sind wir die sperrende APP ?
 bne.b    wn_nomctrl               ; nein
 tst.w    beg_mctrl_cnt            ; Mauskontrolle geholt ?
 beq.b    wn_nomctrl               ; nein
 cmpa.l   topwind_app,a0           ; bin ich auch Eigner ?
 bne.b    wn_nomctrl               ; nein
 clr.w    beg_mctrl_cnt
 jmp      _end_mctrl               ; Menuebaum usw. zurueck
wn_nomctrl:
 rts

**********************************************************************
*
* void wind_new( void )
*
* neu fuer XGEM
*

wind_new:
 movem.l  d7/a4/a5,-(sp)
 move.l   act_appl,a4
* menu_unregister
 moveq    #-1,d0
 jsr      menu_unregister
* END_MCTRL
 move.l   a4,a0
 bsr.b    appl_end_mctrl
* Hintergrund abschalten
 clr.l    -(sp)
 move.l   sp,a0
 moveq    #14,d1                   ; WF_NEWDESK
 moveq    #0,d0
 jsr      _wind_set
 addq.l   #4,sp

*
* Menue abschalten, attach-Liste freigeben, anderes Menue suchen
*

 clr.l    ap_menutree(a4)          ; Menue "aus"tragen
 move.l   ap_attached(a4),d0
 beq.b    wn_no_attached
 clr.l    ap_attached(a4)
 move.l   d0,a0
 jsr      mfree
wn_no_attached:
 move.l   a4,a0                    ; APPL *
 moveq    #1,d0                    ; neues Menue suchen
 jsr      _menu_off                ; In jedem Fall anderes Menue suchen
* Fenster schliessen und loeschen
 moveq    #1,d7
 move.l   windx,a5
 addq.l   #4,a5                    ; ab Fenster 1
wn_loop:
 move.l   (a5)+,d0
 beq.b    wn_nxtwnd                ; Fenster unbenutzt
 move.l   d0,a0
 cmpa.l   w_owner(a0),a4           ; mein Fenster ?
 bne.b    wn_nxtwnd
 btst     #WSTAT_OPENED_B,w_state+1(a0)      ; geoeffnet?
 beq.b    wn_noclose               ; nein, nur entfernen
 move.w   d7,d0
 jsr      wind_close
wn_noclose:
 move.w   d7,d0
 jsr      wind_delete
wn_nxtwnd:

 addq.w   #1,d7
 cmp.w    nwindows,d7
 bcs.b    wn_loop
* end_update
 lea      upd_blockage,a0
 cmpa.l   bl_app(a0),a4            ; sind wir die sperrende APP ?
 bne.b    wn_noupdate              ; nein

; clr.w   beg_mctrl_cnt            ; END_MTCRL schon oben erledigt
 tst.w    bl_cnt(a0)               ; Zaehler schon auf 0 ?
 beq.b    wn_noupdate              ; ja, Ende
 bmi.b    wn_update_minus          ; Zaehler war < 0 !
 move.w   #1,bl_cnt(a0)
 jsr      end_update               ; Blockierung loesen
 bra.b    wn_noupdate
wn_update_minus:
 clr.w    bl_cnt(a0)
 clr.l    bl_app(a0)
wn_noupdate:
* Alle Semaphoren, die wir besitzen, freigeben
 move.l   a4,a0                    ; appl
 moveq    #SEM_FALL,d0             ; alle freigeben
 jsr      evnt_sem
* Maus einschalten
 clr.w    ap_mhidecnt(a4)          ; lokalen Zaehler loeschen
 bsr      reset_mouse              ; globalen Zaehler neu synchronisieren
 moveq    #0,d0                    ; Mauszeiger: Pfeil
 bsr      graf_mouse
* Nachrichten wegwerfen
 move.l   a4,a0
 jsr      flush_msgbuf
 movem.l  (sp)+,d7/a4/a5
 rts


**********************************************************************
*
* PUREC WORD xy_in_grect( WORD x, WORD y, GRECT *g )
*
* int xy_in_grect(d0 = int x, d1 = int y, a0 = GRECT *g)
*
* Rueckgabe TRUE gdw. (x,y) liegt in <g>
* Z-Flag gesetzt bzw. geloescht
*
* aendert nur d2/d0
*

xy_in_grect:
 cmp.w    (a0),d0
 blt.b    xyig_ret0
 cmp.w    2(a0),d1
 blt.b    xyig_ret0
 move.w   (a0),d2
 add.w    4(a0),d2
 cmp.w    d2,d0
 bge.b    xyig_ret0
 move.w   2(a0),d2
 add.w    6(a0),d2
 cmp.w    d2,d1
 bge.b    xyig_ret0
 moveq    #1,d0
 rts
xyig_ret0:
 moveq    #0,d0
 rts


**********************************************************************
*
* EQ/NE int grect_in_grect(a0 = GRECT *outg, a1 = GRECT *ing)
*
* Testet, ob <ing> vollstaendig in <outg> liegt und gibt dann
* 1 (NE) zurueck, sonst 0 (EQ)
*

grect_in_scr:
 lea      full_g,a0                ; vorher: desk_g
grect_in_grect:
 movem.l  a0/a1,-(sp)
 move.w   (a1)+,d0

 move.w   (a1)+,d1
 bsr.s    xy_in_grect
 movem.l  (sp)+,a0/a1
 beq      gig_ende
 move.w   (a1)+,d0
 move.w   (a1)+,d1
 add.w    (a1)+,d0
 subq.w   #1,d0                    ; x+w-1
 add.w    (a1)+,d1
 subq.w   #1,d1                    ; y+h-1
 bra      xy_in_grect
gig_ende:
 rts


**********************************************************************
*
* PUREC WORD grects_intersect( const GRECT *srcg, GRECT *dstg)
*
* EQ/NE int grects_intersect(a0 = GRECT *srcg, a1 = GRECT *dstg)
*
* <dstg> wird mit <srcg> geschnitten und der Schnitt nach <dstg>
* geschrieben.
* Rueckgabe != 0, wenn Schnitt nicht leer
*

grects_intersect:
 move.w   (a1),d0
 cmp.w    (a0),d0
 bge.b    gris_l1
 move.w   (a0),d0
gris_l1:
 move.w   (a0),d1
 add.w    4(a0),d1
 move.w   (a1),d2
 add.w    4(a1),d2
 cmp.w    d1,d2
 ble.b    gris_l2
 move.w   d1,d2
gris_l2:
 move.w   d0,(a1)
 sub.w    d0,d2
 move     sr,-(sp)
 move.w   d2,4(a1)
 move.w   2(a1),d0
 cmp.w    2(a0),d0
 bge.b    gris_l3
 move.w   2(a0),d0
gris_l3:
 move.w   2(a0),d1
 add.w    6(a0),d1
 move.w   2(a1),d2
 add.w    6(a1),d2
 cmp.w    d1,d2

 ble.b    gris_l4
 move.w   d1,d2
gris_l4:
 move.w   d0,2(a1)
 sub.w    d0,d2
 move     sr,d0
 move.w   d2,6(a1)
 move     (sp)+,ccr
 ble.b    gi_ret0
 move     d0,ccr
 ble.b    gi_ret0
 moveq    #1,d0
 rts
gi_ret0:
 moveq    #0,d0
 rts


**********************************************************************
*
* void grects_union(a0 = GRECT *srcg, a1 = GRECT *dstg)
*
* <dstg> wird mit <srcg> vereinigt und das resultierende Rechteck
* nach <dstg> geschrieben.
*

grects_union:
 move.w   (a1),d0
 cmp.w    (a0),d0
 blt.b    grun_l1
 move.w   (a0),d0
grun_l1:
 move.w   (a0),d1
 add.w    4(a0),d1
 move.w   (a1),d2
 add.w    4(a1),d2
 cmp.w    d1,d2
 bgt.b    grun_l2
 move.w   d1,d2
grun_l2:
 sub.w    d0,d2
 move.w   d0,(a1)
 move.w   d2,4(a1)
 move.w   2(a1),d0
 cmp.w    2(a0),d0
 blt.b    grun_l3
 move.w   2(a0),d0
grun_l3:
 move.w   2(a0),d1
 add.w    6(a0),d1
 move.w   2(a1),d2
 add.w    6(a1),d2
 cmp.w    d1,d2
 bgt.b    grun_l4
 move.w   d1,d2
grun_l4:
 sub.w    d0,d2
 move.w   d0,2(a1)
 move.w   d2,6(a1)
 rts


**********************************************************************
*
* d0 = int/a0 = APPL *gbest_app( a0 = APPL *notthis )
*
* Ermittelt die "beste" APP ausser <notthis> in a0.
* Gibt d0 = 1 zurueck, falls Menue oder Hintergrund
*

_tst_nohide:
 move.w   w_curr+g_y(a0),d0
 cmp.w    scr_h,d0
 bcc.b    _tnm_nix                 ; Fenster ist versteckt
_tnm_ok2:
 move.l   w_owner(a0),a0
 bra.b    _tnm_ok

_tst_noha_menu:
 cmpi.b   #' ',ap_dummy2+1(a0)
 bne.b    _tnm_nix                 ; APPL versteckt
 bra.b    _tst_menu                ; APPL nicht versteckt, Menue suchen

_tst_nohide_menu:
 move.w   w_curr+g_y(a0),d0
 move.l   w_owner(a0),a0           ; Menue testen
 cmp.w    scr_h,d0
 bcs.b    _tst_menu                ; Fenster ok
 move.w   #' *',ap_dummy2(a0)      ; APPL versteckt
 bra.b    _tnm_nix                 ; Fenster ist versteckt

_tst_menu:
 tst.l    ap_menutree(a0)
 bgt.b    _tnm_ok
 tst.l    ap_desktree(a0)
 ble.b    _tnm_nix
_tnm_ok:
 cmpa.l   d2,a0
 beq.b    _tnm_nix                 ; den nun gerade nicht!
 move.l   a0,d0
 addq.l   #4,sp                    ; Ruecksprungadresse vergessen
_tnm_nix:
 rts

_tst_do_unmark:
 move.w   #'  ',ap_dummy2(a0)      ; Hide-Flag demarkieren
 rts


_srch_wnd:
 lea      whdlx,a1
 bra      srw_wnd_nxt
srw_wnd_loop:
 bsr      whdl_to_wnd
 jsr      (a2)                     ; test(a0 = WINDOW *)
srw_wnd_nxt:
 move.w   (a1)+,d0
 bmi.b    srw_wnd_nxt              ; eingefrorene Fenster ueberlesen
 bne.b    srw_wnd_loop
 moveq    #0,d0                    ; nichts gefunden
 rts


_srch_app:
 lea      applx,a1
 moveq    #NAPPS-1,d1
sra_loop:
 move.l   (a1)+,d0
 ble.b    sra_next                 ; Applikation ungueltig oder eingefroren
 move.l   d0,a0
 jsr      (a2)
sra_next:
 dbra     d1,sra_loop
 moveq    #0,d0
 rts


gbest_wnd_app:

*
* 4.: Suche APP mit oberstem, nicht versteckten Fenster
*

 lea      _tst_nohide(pc),a2
 bsr.s    _srch_wnd
 bne      gb_found2
 suba.l   a0,a0

gbest_app:
 move.l   a0,d2                    ; diese will ich nicht!

*
* 0.: Entferne alle Hide-Markierungen
*

 lea      _tst_do_unmark(pc),a2
 bsr.s    _srch_app

*
* 1.: Suche oberstes nichtverstecktes Fenster, dessen Eigner Menue hat
*     markiere dabei "hidden" APPs
*

 lea      _tst_nohide_menu(pc),a2
 bsr.s    _srch_wnd
 bne      gb_found

*

* 2.: Suche erste gueltige, nichtversteckte APP, die ein Menue hat
*

 lea      _tst_noha_menu(pc),a2
 bsr.s    _srch_app
 bne      gb_found

*
* 3.: Suche erste gueltige APP, die ein Menue hat
*

 lea      _tst_menu(pc),a2
 bsr.s    _srch_app
 bne      gb_found

*
* 4.: Suche APP mit oberstem, nicht versteckten Fenster
*

 lea      _tst_nohide(pc),a2
 bsr.s    _srch_wnd
 bne      gb_found2

*
* 5.: Suche APP mit oberstem Fenster
*

 lea      _tnm_ok2(pc),a2
 bsr.s    _srch_wnd
 bne      gb_found2

*
* 6.: Suche APP
*

 lea      _tnm_ok(pc),a2
 bsr.s    _srch_app
 bne      gb_found2

*
* 7.: Gib SCRENMGR
*

 move.l   applx+4,d0
gb_found2:
 move.l   d0,a0
 moveq    #0,d0                    ; hat kein Menue/Hintergrund
 rts
gb_found:
 move.l   d0,a0
 moveq    #1,d0                    ; hat Menue/Hintergrund
 rts


**********************************************************************


min:
 cmp.w    d1,d0
 ble.b    min_end
 move.w   d1,d0
min_end:
 rts

max:
 cmp.w    d1,d0
 bge.b    max_end
 move.w   d1,d0
max_end:
 rts


**********************************************************************
*
* void fillmem(d0 = int count, d1 = char c, a0 = char *adr)
*
*

clrmem:
 moveq    #0,d1
 bra.b    fillmem
fillm_loop:
 move.b   d1,(a0)+
fillmem:
 dbf      d0,fillm_loop
 rts

     EVEN

*        DATA

ss_serno:
 DC.L     $17bf5c5d                        ; Seriennummer
ss_nams: ; Name
 dc.b $93,$aa,$e4,$c3,$81,$ea,$f0,$08
 dc.b $fe,$07,$1a,$2b,$3c,$41,$55,$4b
 dc.b $54,$67,$69,$75,$8e,$91,$ad,$9f
 dc.b $b3,$bb,$cd,$ca,$e5,$e2,$05,$f6
 dc.b $08,$16,$19,$25,$3d,$52,$4e,$4d
 dc.b $5e,$7a,$71,$7d,$96,$99,$b5,$52
 dc.b $9f,$c3
ss_adrs: ; Adresse
 dc.b $ab,$9d,$e3,$dd,$ed,$a0,$06,$cc
 dc.b $1f,$23,$2f,$3d,$51,$0e,$5e,$6d
 dc.b $7d,$7f,$45,$96,$9c,$b2,$c4,$bf
 dc.b $cf,$d7,$9d,$db,$f8,$10,$12,$19
 dc.b $2d,$38,$4a,$4d,$58,$5b,$73,$88
 dc.b $7c,$8b,$9b,$9f,$a8,$b5,$be,$67
 dc.b $b6,$ed
 EVEN
ss_kaos:
 DC.L     $21071965                ; Platz fuer Benutzerkennung (KAOS)
 DC.L     $21071965
 DC.L     $21071965
 DC.L     $21071965
 DC.L     $21071965
 DC.W     0,0,0,0                  ; unbenutzt
 DC.W     4                        ; Default- Druckeranpassung: Epson
 DC.B     13                       ; Default- Verzoegerung fuer Tastatur
 DC.B     2                        ; Default- Rate fuer Tastatur
 DC.L     0                        ; Defaultwert fuer KAOS- Konfigurationsbits
gem_magics:
 DC.L     $87654321                ; $00: AES- magic
 DC.L     endofvars                ; $04: Ende der  AES- Variablen
 DC.L     aes_start                ; $08: Start von AES/DESKTOP

 DC.L     'MAGX'                   ; $0c: bei KAOS : 'KAOS'
 DC.L     $02102000                ; $10: Erstelldatum
 DC.L     change_resolution        ; $14: d0=dev/d1=txt/d2=xdv
 DC.L     shel_vector              ; $18: ROM- Desktop
 DC.L     aes_bootdrv              ; $1c: char *, hierhin kommt DESKTOP.INF
 DC.L     vdi_device               ; $20: int, aktueller Geraetetreiber
 DC.L     nvdi_workstn             ; $24: void *, NVDI- Workstationpointer

 DC.L     0    ;DC.L     app0+ap_doex             ; $28
 DC.L     0    ;DC.L     app0+ap_isgr             ; $2c

* ab MAGIX:

 DC.W     $0620                    ; $30: Versionsnummer
 DC.W     3                        ;   0=alpha 1=beta 2=gamma 3=release
 DC.L     _basepage                ; $34:
 DC.L     moff_cnt                 ; $38:
 DC.L     shel_buf_len             ; $3c: unsigned int, Laenge
 DC.L     shel_buf                 ; $40: void *, Puffer
 DC.L     notready_list            ; $44:
 DC.L     menu_app                 ; $48: "Hauptapplikation"
 DC.L     menutree                 ; $4c:  ihr Menue
 DC.L     desktree                 ; $50:  ihr Hintergrund
 DC.L     desktree_1stob           ; $54:  dessen erstes Objekt
 DC.L     dos_magic                ; $58: long 'XAES'
                                   ; long act_appl
                                   ; int  appln
                                   ; int  maxappln
                                   ; long applx[maxappln]
 DC.L     0                        ; MagiC 6.0: NULL
                                   ; $5c: int  maxwindn
                                   ; int  topwhdl
                                   ; int  whdlx[maxwindn]
                                   ; WINDOWS *windx
 DC.L     p_fsel                   ; $60
 DC.L     ctrl_timeslice           ; $64
 DC.L     topwind_app              ; $68
 DC.L     mouse_app                ; $6c
 DC.L     keyb_app                 ; $70
 DC.L     suspend_list             ; $74
 DC.W     2                        ; $78 Installationslaufwerk (C:)
 DC.B     '_______________',0      ; $7a Dateiname, z.B. "c:\magic.ram"
 DC.L     xp_mode                  ; $8a xp_mode/xp_ptr
 DC.L     0                        ; $8e
