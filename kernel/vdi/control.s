                  /* '1. Kontrollfunktionen' */


/*
 * XBIOS-Aufloesung fuer NVDI-Treiber setzen
 * Vorgaben:
 * kein Register wird veraendert
 * Eingaben:
 * d1.l pb
 * d3.w Geraetekennung - 1
 * Ausgaben
 * XBIOS-Aufloesung wird evtl. veraendert
 */
set_xbios_res:    cmp.w    #FALCONMDS+1,d3 /* Falcon-Modus? */
                  bne.s    set_xbios_rsave
                  cmpi.w   #FALCON_VIDEO,(nvdi_cookie_VDO).w /* Falcon? */
                  beq.s    set_falcon_res
set_xbios_rsave:  movem.l  d0-d1,-(sp)
                  move.w   (resolution).w,d0  /* Xbios-Aufloesung +1 */
                  tst.w    d3             /* aktuelle Aufloesung ? */
                  beq.s    set_res_exit
                  moveq.l  #ST_HIGH+1,d1  /* hohe ST-Aufloesung (Xbios) */
                  cmpi.w   #TT_VIDEO,(nvdi_cookie_VDO).w /* TT ? */
                  bne.s    set_res_mono
                  moveq.l  #TT_HIGH+1,d1  /* hohe TT-Aufloesung (Xbios) */
set_res_mono:     cmp.w    d1,d0          /* momentan Monochrombetrieb ? */
                  beq.s    set_res_exit
                  cmp.w    d1,d3          /* Monochrombetrieb gewuenscht ? */
                  beq.s    set_res_exit
                  move.w   d3,d0          /* gewuenschte Aufloesung */
                  subq.w   #1,d0          /* XBIOS-Aufloesung */
                  cmp.w    #7,d0          /* Aufloesung vorhanden ? */
                  bgt.s    set_act_res
                  btst     d0,#%101000    /* Aufloesung vorhanden ? */
                  beq.s    set_xbios_res2
set_act_res:      move.w   (resolution).w,d0
                  subq.w   #1,d0
set_xbios_res2:   bsr      set_resolution /* neue Aufloesung setzen */
set_res_exit:     movem.l  (sp)+,d0-d1
                  rts

/*
 * XBIOS-Aufloesung auf Falcon fuer NVDI-Treiber setzen
 * Vorgaben:
 * kein Register wird veraendert
 * Eingaben:
 * d1.l pb
 * d3.w Geraetekennung - 1
 * Ausgaben
 * XBIOS-Aufloesung wird evtl. veraendert
 */
set_falcon_res:   movem.l  d0-d2/a0-a2,-(sp)

                  move.l   d1,-(sp)
                  move.w   #-1,-(sp)
                  move.w   #VSETMODE,-(sp)
                  trap     #XBIOS
                  addq.l   #4,sp
                  movea.l  (sp)+,a0       /* pb */
                  movea.l  pb_ptsout(a0),a0
                  move.w   d0,(modecode).w    /* aktuellen modecode sichern */
                  cmp.w    (a0),d0        /* gewuenschte Aufloesung schon eingestellt? */
                  beq.s    set_flc_res_exit

                  move.w   (a0),(modecode).w

                  move.w   (a0),-(sp)     /* modecode */
                  move.w   #FALCONMDS,-(sp) /* Falcon-Aufloesungen */
                  moveq.l  #-1,d0         /* Adressen nicht aendern */
                  move.l   d0,-(sp)       /* Physbase */
                  move.l   d0,-(sp)       /* Logbase */
                  move.w   #SETSCREEN,-(sp)
                  trap     #XBIOS

                  lea.l    14(sp),sp

set_flc_res_exit: movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * Geraetetreiber laden
 * Vorgaben:
 * 
 * Eingaben:
 * d3.w Geraetekennung - 1
 * a3.l Zeiger auf Treibereintrag in der Treibertabelle
 * Ausgaben
 * d0.l Zeiger auf den Treiberstart oder 0 (keinen Treiber gefunden)
 *      oder NO_NVDI_DRVR (keinen NVDI-Treiber gefunden)
 * d1.l pb
 * d3.w Geraetekennung - 1
 * a0.l Zeiger auf den Treiberstart
 * a3.l Zeiger auf Treibereintrag in der Treibertabelle
 */
opnwk_load_drvr:  bsr      set_xbios_res  /* XBIOS-Aufloesung setzen => Treiber wird geladen */
                  move.l   (screen_driver+driver_addr).w,d0  /* Zeiger auf den Treiber */
                  movea.l  d0,a0                         /* Treiberstart */
                  tst.l    d0                            /* Treiber vorhanden? */
                  bne.s    opnwk_drv_planes
                  rts

opnwk_drv_planes: movem.l  d0-d2/a0-a2,-(sp)
                  move.w   DRVR_planes(a0),d0            /* unterstuetzte Plane-Anzahl des geladenen Treibers */
                  cmp.w    (PLANES).w,d0                 /* ist der richtige Treiber geladen? */
                  beq.s    opnwk_dpl_exit

                  bsr      unload_scr_drvr               /* vorhandenen Treiber entfernen */
                  bsr      load_scr_drvr                 /* neuen Bilschirmtreiber laden */

opnwk_dpl_exit:   movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * Bildschirmtreiber oeffnen
 * Vorgaben:
 * 
 * Eingaben:
 * d1.l pb
 * d3.w Geraetekennung - 1
 * a1.l contrl
 * a2.l intin
 * a3.l Treiberstruktur
 * a4.l intout
 * a5.l ptsout
 * Ausgaben:
 * d1.l pb
 * d3.w Geraetekennung - 1
 * d4.w Handle 1
 * a1.l contrl
 * a2.l intin
 * a4.l intout
 * a5.l ptsout
 */
open_nvdi_drvr:   move.w   d3,(first_device).w
                  movea.l  (aes_wk_ptr).w,a6 /* Workstation des AES */
                  move.l   a6,(wk_tab).w     /* in die Wk-Tabelle eintragen */
                  moveq.l  #1,d4             /* Handle */
                  move.w   d3,driver_id(a6)  /* Treiber-ID speichern */
                  move.w   d4,wk_handle(a6)
                  move.w   d4,handle(a1)
                  addq.w   #1,driver_use(a3) /* Semaphore erhoehen */
                  move.w   d4,driver_open_hdl(a3)
                  bsr      init_fonthdr      /* Fontheader fuer LINE-A erstellen */
                  bsr      init_res          /* Line-A/VDI-Variablen initialisieren */
                  bsr      init_interrupts   /* Interrupts einklinken */
                  movem.l  d1/a0-a1,-(sp)
                  movea.l  a3,a0
                  movea.l  driver_offscreen(a3),a1
                  bsr      wk_defaults       /* Workstation initialisieren */
                  movem.l  (sp)+,d1/a0-a1
                  movem.l  d1/a0-a1/a6,-(sp)
                  movea.l  a3,a0
                  movea.l  driver_offscreen(a3),a1
                  movea.l  (linea_wk_ptr).w,a6
                  bsr      wk_defaults       /* LINEA-Workstation initialisieren */
                  movem.l  (sp)+,d1/a0-a1/a6

/*
 * Seit MagiC 6 wird der Bildschirm beim v_opnwk() nicht mehr geloescht,
 * da waehrend des Bootens ein Logo angezeigt wird.
 */
                  .IFNE 0
                  moveq.l  #V_CLRWK,d0
                  movem.l  d1/a0-a1,-(sp)
                  bsr      call_nvdi_fkt
                  movem.l  (sp)+,d1/a0-a1
                  .ENDC

                  bra      opnwk_io

/*
 * Ausgabekoordinaten noetigenfalls ins NDC-Format konvertieren
 * Dispatcher eintragen und Koordinaten noetigenfalls ins NDC-Format konvertieren
 * Vorgaben:
 * Register d0-d4/a0-a2.l werden veraendert
 * Eingaben:
 * d1.l pb
 * a2.l intin
 * a3.l Zeiger auf Treibereintrag in der Treibertabelle
 * a6.l Workstation
 * Ausgaben:
 * die Koordinaten im ptsout werden, wenn noetig, ins NDC-System gewandelt
 */
set_dispatcher:   move.l   #handle_found,disp_addr1(a6) /* RC-Dispatcher-Adresse */
                  move.b   driver_status(a3),driver_type(a6)
                  rts

/*
 * OPEN WORKSTATION (VDI 1)
 */
v_opnwk:          movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a5           /* contrl, intin, ptsin, intout, ptsout */

                  bsr      get_resolution       /* aktuelle Aufloesung erfragen */

                  move.w   (a2),d3              /* Geraetekennung */
                  subq.w   #1,d3                /* - 1 */
                  cmpi.w   #MAX_ID-1,d3         /* gueltig ? */
                  bhi      opnwk_err_exit

                  lea.l    (screen_driver).w,a3
                  tst.w    driver_use(a3)       /* Geraet schon geoeffnet? */
                  bne.s    opnwk_open_error
                  bsr      opnwk_load_drvr      /* Geraetetreiber laden */
                  tst.l    d0                   /* keinen Treiber gefunden? */
                  beq.s    opnwk_err_load

                  bsr      open_nvdi_drvr /* NVDI-Treiber initialisieren */

                  tst.l    (vdi_setup_ptr).w    /* kein direkter Hardware-Zugriff (Mac)? */
                  beq.s    v_opnwk_eddi

                  lea.l    (CONTRL).w,a0        /* Zeiger auf den LineA-PB */
                  move.l   a0,d1                /* eigener pb */
                  lea.l    (contrl).w,a1        /* contrl */
                  move.l   a1,(a0)+
                  lea.l    (intin).w,a2         /* intin */
                  move.l   a2,(a0)+
                  move.l   #ptsin,(a0)+
                  move.l   #intout,(a0)+
                  move.l   #ptsout,(a0)+

                  move.w   #VST_FONT,(a1)
                  move.w   #1,n_intin(a1)
                  clr.w    n_ptsin(a1)
                  move.w   #1,handle(a1)

                  move.w   #1,(a2)              /* Systemfont einstellen */

                  moveq.l  #115,d0
                  trap     #2                   /* reentranter Aufruf fuer MagiCMac (killt SpeedoGDOS) */

v_opnwk_eddi:     move.l   #$45644449,d0        /* 'EdDI' Offscreen-Funktionen sind vorhanden */
                  move.l   #eddi_dispatcher,d1
                  bsr      init_cookie

opn_handle_exit:  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/*
 * Treiber schon per v_opnwk geoeffnet
 * Eingaben
 * d3.w Geraetekennung -1
 * d4.w Handle
 * a6.l Workstation
 */
opnwk_open_error: move.l   a6,d0
                  bsr      Mfree          /* Workstation-Speicher zurueckgeben */
                  lsl.w    #2,d4
                  lea.l    (wk_tab0).w,a6
                  move.l   #closed,0(a6,d4.w) /* Workstation-Eintrag loeschen */
                  move.w   d3,d0
                  addq.w   #1,d0          /* Geraetekennung */

opnwk_err_no_wk:                          /* Alle Workstations belegt */
opnwk_err_id:                             /* Ungueltige Geraetekennung wurde uebergeben */
opnwk_err_mem:                            /* Nicht genuegend Speicher zum oeffnen einer Workstation vorhanden */
opnwk_err_msg:    
opnwk_err_load:                           /* Fehler beim Laden des Geraetetreibers */
opnwk_err_exit:   movem.l  (sp)+,d1-d7/a2-a5
                  movea.l  d1,a0
                  movea.l  pb_control(a0),a1
                  clr.w    handle(a1)     /* Fehler */
                  rts

/*
 * Speicher fuer eine Workstation allozieren
 * Vorgaben:
 * Register d0/d2/d4/a6.l werden veraendert
 * Eingaben:
 * a1.l contrl
 * d3.w Geraetekennung -1
 * Ausgaben
 * d0.w evtl. Fehlermeldung
 * d3.w Geraetekennung -1
 * d4.w Handle oder 0 im Fehlerfall
 * a1.l contrl, contrl[6] enthaelt das Handle
 * a3.l Zeiger auf den Treibereintrag
 * a6.l Workstationadresse, wk_handle und driver_id werden gesetzt
 */
alloc_wk:         moveq.l  #0,d4          /* Vorbesetzung mit Handle 0 */
                  moveq.l  #MAX_HANDLES-2,d2 /* Zaehler fuers Handle */
                  lea.l    (wk_tab+4).w,a6 /* Zeiger auf die Workstationtabelle, ersten Eintrag ignorieren */
opnwk_loop:       cmpi.l   #closed,(a6)+  /* Eintrag frei ? */
                  dbeq     d2,opnwk_loop
                  eori.w   #MAX_HANDLES-1,d2 /* Handle -1 */
                  bpl.s    opnwk_all_len  /* alles belegt ? */
                  moveq.l  #NOT_ENOUGH_WKS,d0
                  bra.s    alloc_wk_exit
opnwk_all_len:    move.l   #WK_LENGTH,d0  /* minimale Laenge der WK */
                  cmpi.b   #DRIVER_NVDI,driver_status(a3) /* NVDI-Treiber? */
                  bne.s    opnwk_get_mem
                  move.l   driver_wk_len(a3),d0
opnwk_get_mem:    move.w   d0,-(sp)
                  bsr      MallocA        /* Speicher fuer die WK anfordern */
                  tst.l    d0             /* Fehler ? */
                  bne.s    opnwk_save_wk
                  addq.l   #2,sp
                  moveq.l  #NOT_ENOUGH_MEM,d0
                  bra.s    alloc_wk_exit
opnwk_save_wk:    move.w   d2,d4
                  addq.w   #1,d4          /* Handle */
                  move.l   d0,-(a6)       /* WK-Adresse speichern */
                  movea.l  d0,a6
                  move.w   (sp)+,d2
                  lsr.w    #1,d2
                  subq.w   #1,d2
opnwk_clr_wk:     clr.w    (a6)+
                  dbra     d2,opnwk_clr_wk
                  movea.l  d0,a6
                  move.w   d3,driver_id(a6) /* Treiber-ID speichern */
                  move.w   d4,wk_handle(a6)
alloc_wk_exit:    move.w   d4,handle(a1)
                  rts

/*
 * Speicher fuer Workstation zurueckgeben
 * Vorgaben:
 * Register d0/a0 werden veraendert
 * Eingaben:
 * d0.w Handle
 * a6.l Workstation
 * Ausgaben:
 * -
 */
free_wk:          lsl.w    #2,d0
                  lea.l    (wk_tab0).w,a0 /* Zeiger auf die Workstationtabelle */
                  move.l   #closed,0(a0,d0.w) /* Eintrag frei */
                  move.l   a6,d0
                  bra      Mfree          /* Speicher zurueckgeben */

/*
 * Aufloesung ermitteln
 * Ausgaben:
 * resolution.w  aktuelle Aufloesung +1
 */
get_resolution:   movem.l  d0-d2/a0-a2,-(sp)
                  moveq.l  #0,d0
                  move.b   (sshiftmd).w,d0
                  addq.w   #1,d0
                  move.w   d0,(resolution).w  /* aktuelle Aufloesung +1 */
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * Aufloesung setzen
 * Eingaben:
 * d0.w gewuenschte Aufloesung
 * Ausgaben:
 *  -
 */
set_resolution:   movem.l  d0-d2/a0-a2,-(sp)
                  move.w   d0,-(sp)       /* neue Aufloesung */
                  moveq.l  #-1,d0         /* Adressen nicht aendern */
                  move.l   d0,-(sp)       /* Physbase */
                  move.l   d0,-(sp)       /* Logbase */
                  move.w   #SETSCREEN,-(sp)
                  trap     #XBIOS
                  lea.l    12(sp),sp
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * Eingaben:
 * d1.l pb
 * a3.l Zeiger auf die Treiberstruktur
 * a6.l Workstation
 */
opnwk_io:         bsr      init_arrays    /* LINE-A-Variablen setzen */
                  bsr.s    v_opnwk_in     /* intin beruecksichtigen */
                  bsr.s    v_opnwk_out    /* intout/ptsout besetzen */
opnwk_io_exit:    rts

/*
 * Ausgaben von v_opnwk/v_opnvwk in intout und ptsout
 * Vorgaben:
 * kein Register wird veraendert
 * Eingaben:
 * d1.l pb
 * a4.l intout
 * a5.l ptsout
 * a6.l Workstation
 * Ausgaben:
 * work_out[0..56] in intout und ptsout
 */
v_opnwk_out:      movem.l  d0-d2/a0-a5,-(sp)
                  move.l   device_drvr(a6),d0
                  beq.s    v_opnwk_out_off
                  movea.l  d0,a2
                  movea.l  driver_addr(a2),a2
                  bra.s    v_opnwk_out_call
v_opnwk_out_off:  movea.l  bitmap_drvr(a6),a2
                  movea.l  DRIVER_code(a2),a2
v_opnwk_out_call: movea.l  DRVR_opnwkinfo(a2),a2
                  movea.l  a4,a0
                  movea.l  a5,a1
                  jsr      (a2)
v_opnwk_out_exit: movem.l  (sp)+,d0-d2/a0-a5
                  rts

/*
 * NVDI-Funktion aufrufen
 * Vorgaben:
 * d0/a0/a1 werden veraendert
 * Eingaben:
 * d0.w Funktionsnummer
 * d1.l pb
 * a6.l Workstation
 * Ausgaben:
 * d1.l pb
 */
call_nvdi_fkt:    lsl.w    #3,d0
                  lea.l    vdi_tab(pc),a0
                  move.l   4(a0,d0.w),-(sp)
                  movea.l  d1,a0          /* pb */
                  rts

/*
 * Eingaben aus intin bei v_opnwk()/v_opnvwk() setzen
 * Vorgaben:
 * kein Register wird veraendert
 * Eingaben:
 * d1.l pb
 * a6.l Workstation
 * Ausgaben:
 * verschiedene Eintragungen in der Workstation
 */
v_opnwk_in:       movem.l  d0-d1/a0-a1/a3,-(sp)
                  movea.l  d1,a0
                  lea.l    pb_intin(a0),a3
                  addq.l   #2,(a3)        /* Linientyp       intin[1] */
                  moveq.l  #VSL_TYPE,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Linienfarbe     intin[2] */
                  moveq.l  #VSL_COLOR,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Markertyp       intin[3] */
                  moveq.l  #VSM_TYPE,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Markerfarbe     intin[4] */
                  moveq.l  #VSM_COLOR,d0
                  bsr.s    call_nvdi_fkt
                  movea.l  d1,a0
                  pea.l    opnwk_tcolor(pc)
                  cmpi.w   #320-1,res_y(a6) /* mindestens 320 Pixel Hoehe? */
                  blt      vst_height6
                  bra      vst_height13   /* Zeichenhoehe */
opnwk_tcolor:     addq.l   #4,(a3)        /* Textfarbe       intin[6] */
                  moveq.l  #VST_COLOR,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Fuellmustertyp  intin[7] */
                  moveq.l  #VSF_INTERIOR,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Fuellmusterindex intin[8] */
                  moveq.l  #VSF_STYLE,d0
                  bsr.s    call_nvdi_fkt
                  addq.l   #2,(a3)        /* Fuellmusterfarbe intin[9] */
                  moveq.l  #VSF_COLOR,d0
                  bsr.s    call_nvdi_fkt
                  subi.l   #18,(a3)       /* Zeiger auf intin korrigieren */
                  movem.l  (sp)+,d0-d1/a0-a1/a3
                  rts

init_fonthdr:     movem.l  d0-d1/a0-a2,-(sp)
                  lea.l    (font_hdr1).w,a1 /* 6*6  Fontheader */
                  lea.l    (font_hdr2).w,a2 /* 8*8  Fontheader */
                  lea.l    (FONT_RING).w,a0
                  move.l   a1,(a0)+
                  move.l   a2,(a0)+
                  clr.l    (a0)+          /* keine GDOS-Fonts */
                  clr.l    (a0)+          /* Ende der Liste */
                  move.w   #1,(FONT_COUNT).w /* Anzahl der Zeichensaetze */
                  move.l   a2,(DEF_FONT).w  /* Zeiger auf den Systemfont */
                  move.l   dat_table(a2),(V_FNT_AD).w
                  moveq.l  #8,d0          /* Zeichenhoehe */
                  moveq.l  #0,d1
                  move.w   (V_REZ_VT).w,d1  /* vertikale Aufloesung */
                  cmpi.w   #400,d1        /* kleinen Font verwenden? */
                  blt.s    init_nvdi_exit
                  moveq.l  #16,d0         /* Zeichenhoehe */
                  lea.l    (font_hdr3).w,a2   /* 8*16 Fontheader */
init_nvdi_exit:   move.l   a2,(DEF_FONT).w  /* Zeiger auf den Systemfont */
                  move.l   dat_table(a2),(V_FNT_AD).w
                  move.w   d0,(V_CEL_HT).w  /* Zeichenhoehe */
                  divu.w   d0,d1
                  subq.w   #1,d1
                  move.w   d1,(V_CEL_MY).w  /* hoechste Zeilennummer */
                  movem.l  (sp)+,d0-d1/a0-a2
                  /* FIXME: should also set T_DEF_FONT_BIT, and clear it in all others */
                  rts

/*
 * VDI-Variablen in LINEA abhaengig von der XBIOS-Aufloesung initialisieren
 * Vorgaben:
 * kein Register wird zerstoert
 * Eingaben:
 * resolution
 * a3.l Zeiger auf aktuellen Treibereintrag
 * a6.l Zeiger auf die Workstation
 * Ausgaben:
 * DEV_TAB, SIZ_TAB und INQ_TAB werden gesetzt
 */
init_res:         movem.l  d0-d2/a0-a2,-(sp)
                  movea.l  driver_addr(a3),a2
                  movea.l  DRVR_opnwkinfo(a2),a2
                  lea.l    (DEV_TAB).w,a0
                  lea.l    (SIZ_TAB).w,a1
                  jsr      (a2)

                  movea.l  driver_addr(a3),a2
                  movea.l  DRVR_extndinfo(a2),a2
                  lea.l    (INQ_TAB).w,a0  /* intout fuer vq_extnd */
                  lea.l    -64(sp),sp
                  movea.l  sp,a1          /* ptsout fuer vq_extnd */
                  jsr      (a2)
                  lea.l    64(sp),sp

init_res_exit:    movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * Timer-Interrupts, Mausinterruptroutine und Mauszeichenroutine installieren
 * Vorgaben:
 * kein Register wird veraendert
 * Eingaben:
 * -
 * Ausgaben:
 * etv_timer, USER_TIM, NEXT_TIM, USER_BUT, USER_CUR, USER_MOT, ... werden gesetzt
 */
init_interrupts:  movem.l  d0-d7/a0-a6,-(sp)
                  move.w   sr,-(sp)
                  ori.w    #$0700,sr      /* disable interrupts */

                  move.w   #etv_timer/4,d0
                  lea.l    sys_timer(pc),a0 /* new etv_timer function */
                  lea.l    (old_etv_timer).w,a1
                  bsr      change_vec

                  move.l   #dummy_rts,(USER_TIM).w
                  move.l   (old_etv_timer).w,(NEXT_TIM).w
                  move.l   #dummy_rts,(USER_BUT).w
                  move.l   #user_cur,(USER_CUR).w
                  move.l   #dummy_rts,(USER_MOT).w

                  lea.l    mouse_form(pc),a2
                  bsr      transform_in   /* mouse shape */
                  clr.w    (MOUSE_BT).w   /* no button pressed */
                  clr.b    (CUR_MS_STAT).w /* no mouse move */
                  clr.b    (MOUSE_FLAG).w /* mouse drawing possible */
                  moveq.l  #1,d0
                  move.b   d0,(M_HID_CNT).w /* mouse is hidden */
                  move.b   d0,(CUR_FLAG).w
                  move.l   (DEV_TAB0).w,d0
                  lsr.l    #1,d0
                  bclr     #15,d0          /* clear overflow bit */
                  move.l   d0,(GCURX).w
                  move.l   d0,(CUR_X).w
                  movea.l  (vbl_queue).w,a0
                  move.l   #vbl_mouse,(a0) /* VBL mouse routine */

                  lea.l    mouse_int_lower(pc),a0
                  move.l   a0,-(sp)       /* mouse interrupt routine */
                  pea.l    mouse_param(pc) /* parameters for Initmouse */
                  moveq.l  #1,d0          /* Initmouse(1) (relative mode) */
                  move.l   d0,-(sp)
                  trap     #XBIOS
                  lea.l    12(sp),sp
                  move.w   (sp)+,sr
                  movem.l  (sp)+,d0-d7/a0-a6
                  rts

mouse_param:      DC.B 0                  /* topmode */
                  DC.B 0                  /* buttons */
                  DC.B 1                  /* xparam */
                  DC.B 1                  /* yparam */

/* mouse shape */
mouse_form:       DC.W 1                  /* mf_xhot */
                  DC.W 1                  /* mf_yhot */
                  DC.W 1                  /* mf_nplanes - immer 1 */
                  DC.W 0                  /* mf_fg - Maskenfarbe */
                  DC.W 1                  /* mf_bg - Cursorfarbe */
/* mask */
                  DC.W %1100000000000000  /* 1 */
                  DC.W %1110000000000000  /* 2 */
                  DC.W %1111000000000000  /* 3 */
                  DC.W %1111100000000000  /* 4 */
                  DC.W %1111110000000000  /* 5 */
                  DC.W %1111111000000000  /* 6 */
                  DC.W %1111111100000000  /* 7 */
                  DC.W %1111111110000000  /* 8 */
                  DC.W %1111111111000000  /* 9 */
                  DC.W %1111111111100000  /* 10 */
                  DC.W %1111111000000000  /* 11 */
                  DC.W %1110111100000000  /* 12 */
                  DC.W %1100111100000000  /* 13 */
                  DC.W %1000011110000000  /* 14 */
                  DC.W %0000011110000000  /* 15 */
                  DC.W %0000001110000000  /* 16 */
/* data */
                  DC.W %000000000000000   /* 1 */
                  DC.W %100000000000000   /* 2 */
                  DC.W %110000000000000   /* 3 */
                  DC.W %111000000000000   /* 4 */
                  DC.W %111100000000000   /* 5 */
                  DC.W %111110000000000   /* 6 */
                  DC.W %111111000000000   /* 7 */
                  DC.W %111111100000000   /* 8 */
                  DC.W %111111110000000   /* 9 */
                  DC.W %111110000000000   /* 10 */
                  DC.W %110110000000000   /* 11 */
                  DC.W %100011000000000   /* 12 */
                  DC.W %000011000000000   /* 13 */
                  DC.W %000001100000000   /* 14 */
                  DC.W %000001100000000   /* 15 */
                  DC.W %000000000000000   /* 16 */

/* LINE-A-Variablen beim oeffnen der Workstation besetzen (Kompatibilitaet!) */
init_arrays:      movem.l  d0/a0/a6,-(sp)
                  moveq.l  #-1,d0
                  lea.l    (intin).w,a6
                  move.l   d0,(a6)        /* for TEMPUS WORD */
                  lea.l    (COLBIT0).w,a0
                  move.l   d0,(a0)+       /* COLBIT0/COLBIT1 */
                  move.l   d0,(a0)+       /* COLBIT2/COLBIT3 */
                  move.l   d0,(a0)+       /* LSTLIN/LNMASK */
                  move.w   d0,(TEXTFG).w
                  clr.w    (TEXTBG).w
                  move.l   (font_hdr3+dat_table).w,(FBASE).w
                  move.w   (font_hdr3+form_width).w,(FWIDTH).w
                  move.l   (buffer_ptr).w,(SCRTCHP).w
                  move.w   #NVDI_BUF_SIZE/2,(SCRPT2).w
                  move.l   #fill0,(PATPTR).w
                  clr.w    (PATMSK).w
                  move.w   #1,(V_HID_CNT).w /* cursor off ! */
                  clr.w    (MFILL).w      /* no multi-plane pattern */
                  cmpi.w   #8,(PLANES).w
                  blt.s    init_la_exit
                  clr.l    (COLBIT4).w
                  clr.l    (COLBIT6).w
init_la_exit:     movem.l  (sp)+,d0/a0/a6
                  rts

/* wk_init( DEVICE_DRIVER *dev, DRIVER *off, WK *wk ) */
wk_init:          move.l   a6,-(sp)
                  movea.l  8(sp),a6
                  moveq.l  #0,d1
                  bsr.s    wk_defaults
                  movea.l  (sp)+,a6
                  rts

/*
 * Initialize workstation
 * Requirements:
 * no register changed
 * Inputs:
 * d1.l pb or NULL
 * a0.l pointer to screen driver DEVICE_DRIVER or NULL
 * a1.l pointer to offscreen driver DRIVER or NULL
 * a6.l workstation
 * Outputs:
 * workstation parameters intialized
 */
wk_defaults:      movem.l  d0-d2/a0-a1,-(sp)

                  move.l   #handle_found,disp_addr1(a6) /* RC-Dispatcher-Adresse */
                  clr.l    disp_addr2(a6)
                  move.l   (DEV_TAB0).w,res_x(a6) /* resolution */
                  move.l   (DEV_TAB3).w,pixel_width(a6)

                  move.w   (PLANES).w,d0  /* number of planes */
                  subq.w   #1,d0
                  move.w   d0,r_planes(a6)  /* number of planes - 1 */
                  move.w   (DEV_TAB13).w,d0
                  subq.w   #1,d0
                  move.w   d0,colors(a6)  /* number of colors -1 */

                  move.b   #DRIVER_NVDI,driver_type(a6) /* NVDI driver */

                  clr.w    t_bitmap_gdos(a6) /* no fonts loaded yet */
                  clr.w    res_ratio(a6)  /* resolution ratio */
                  cmpa.l   (aes_wk_ptr).w,a6     /* first WK ? */
                  beq.s    wk_arrays
                  movea.l  (aes_wk_ptr).w,a0
                  move.w   res_ratio(a0),res_ratio(a6)
wk_arrays:
                  move.b   #$0f,input_mode(a6)  /* all I_SAMPLE */
/* bezier */
                  move.w   #5,bez_qual(a6) /* bezier max quality */
                  clr.l    bez_buffer(a6) /* no special bezier buffer yet */
                  clr.l    bez_buf_len(a6) /* length of bezier buffers is 0 */
/* clipping */
                  clr.l    clip_xmin(a6)  /* clip_xmin/clip_ymin */
                  move.l   res_x(a6),clip_xmax(a6) /* clip_xmax/clip_ymax */
                  clr.w    wr_mode(a6)    /* wr_mode */

/* line attributes */
                  lea.l    l_width(a6),a0
                  move.w   #L_WIDTH_MIN,l_width(a6) /* l_width */
                  clr.l    l_start(a6)    /* l_start/l_end */
                  clr.l    l_lastpix(a6)  /* l_lastpix/l_style */
                  lea.l    l_styles(a6),a0
                  move.l   #$fffffff0,(a0)+
                  move.l   #$e0e0ff18,(a0)+
                  move.l   #$ff00f198,(a0)+
                  move.w   #$ffff,(a0)+   /* l_udstyle */

/* text attributes */
                  clr.w    t_effects(a6)
                  clr.w    t_light_pct(a6)
                  clr.w    t_rotation(a6)
                  clr.l    t_hor(a6)            /* t_hor/t_ver */
                  move.w   #T_SYSTEM_FACE,t_number(a6)   /* t_number */
                  move.l   #font_hdr1,t_pointer(a6)   /* t_pointer */
                  move.l   (buffer_ptr).w,buffer_addr(a6) /* t_buffer */
                  move.l   #NVDI_BUF_SIZE,buffer_len(a6)
                  clr.l    t_point_height(a6)   /* Hoehe per vst_height gesetzt */
                  clr.l    t_bitmap_fonts(a6)   /* t_next_font */
                  clr.b    t_font_type(a6)      /* Bitmap-Font */
                  move.b   #1,t_mapping(a6)     /* ASCII-Mapping */
                  move.w   #-1,t_no_kern(a6)    /* Pair-Kerning aus! */
                  clr.w    t_no_track(a6)       /* keine Kerning-Tracks vorhanden */
                  clr.w    t_skew(a6)           /* keine Schraegstellung */
                  clr.w    t_track_index(a6)    /* kein Track-Index */
                  clr.l    t_track_offset(a6)
                  move.w   #255,t_ades(a6)

/* fill attributes */
                  move.w   #1,f_perimeter(a6)  /* Umrahmung ein */
                  lea.l    f_saddr(a6),a0
                  move.l   a0,f_spointer(a6)   /* Zeiger */
                  clr.w    f_splanes(a6)
                  move.l   #fill0,f_fill0(a6)
                  move.l   #fill1,f_fill1(a6)
                  move.l   #fill2_1,f_fill2(a6)
                  move.l   #fill3_1,f_fill3(a6)
                  lea.l    fill4_1,a1
                  moveq.l  #7,d0              /* Langwortzaehler */
init_wk_fill:     move.l   (a1)+,(a0)+
                  dbra     d0,init_wk_fill

                  move.w   #9,m_height(a6)    /* Default-Markerhoehe */
                  move.l   #text,p_gtext(a6)
                  move.l   #v_escape_in,p_escapes(a6)

                  movem.l  (sp),d0-d2/a0-a1
/* Off-Screen-Bitmap */
                  move.l   a0,device_drvr(a6)
                  move.l   a1,bitmap_drvr(a6)

                  move.l   a0,d0          /* Geraetetreiber vorhanden? */
                  beq.s    wkdef_off
                  movea.l  driver_addr(a0),a0

                  move.l   DRVR_colors(a0),bitmap_colors(a6)   /* Anzahl der gleichzeitig darstellbaren Farben */
                  move.w   DRVR_planes(a0),bitmap_planes(a6)   /* Anzahl der Ebenen */
                  move.w   DRVR_format(a0),bitmap_format(a6)   /* Pixelformat */
                  move.w   DRVR_flags(a0),bitmap_flags(a6)     /* Bit-Organisation */

wkdef_off:        move.l   a1,d0          /* Offscreen-Treiber vorhanden? */
                  beq.s    wkdef_drv
                  movea.l  DRIVER_code(a1),a1
                  movea.l  DRVR_wk_init(a1),a1
                  jsr      (a1)           /* Offscreen-Treiber anspringen */

wkdef_drv:        movem.l  (sp),d0-d2/a0-a1
                  move.l   a0,d0          /* Geraetetreiber vorhanden? */
                  beq.s    wkdef_exit
                  movea.l  driver_addr(a0),a0
                  movea.l  DRVR_wk_init(a0),a0
                  jsr      (a0)           /* Geraetetreiber anspringen */

wkdef_exit:       moveq.l  #0,d0
                  move.w   pixel_width(a6),d0         /* Pixelbreite */
                  move.w   pixel_height(a6),d1        /* Pixelhoehe */
                  move.w   d0,d2
                  lsr.w    #1,d2
                  add.w    d2,d0                      /* Pixelbreite * 1.5 */
                  divu.w   d1,d0                      /* durch Pixelhoehe teilen */
                  subq.w   #1,d0                      /* Seitenverhaeltnis */
                                                      /* < 0: vertikal stauchen */
                                                      /* 0  : quadratisches Pixelverhaeltnis */
                                                      /* > 0: vertikal dehnen */
                  move.w   d0,res_ratio(a6)
                  movem.l  (sp)+,d0-d2/a0-a1
                  rts

init_mono_NOD:    movem.l  d3-d7/a2-a6,-(sp)
                  move.l   a0,(mono_DRVR).w
                  movea.l  (linea_wk_ptr).w,a6
                  move.l   DRVR_wk_init(a0),a1
                  jsr      (a1)
                  move.l   p_bitblt(a6),(mono_bitblt).w
                  move.l   p_expblt(a6),(mono_expblt).w
                  movem.l  (sp)+,d3-d7/a2-a6
                  rts

Bconout: /*  not exported! */
                  movem.l  d0-d2/a0-a2,-(sp)
                  move.w   d0,-(sp)
                  move.w   #CON,-(sp)
                  move.w   #BCONOUT,-(sp)
                  trap     #BIOS
                  addq.l   #6,sp
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts


/*
 * Treiber mit in contrl[6] vorgegebenem Handle aufrufen
 * Vorgaben:
 * kein Register wird zerstoert
 * Eingaben:
 * d1.l pblock
 * a6.l Workstation (disp_addr2)
 * Ausgaben:
 * -
 */
cldrvr:           movem.l  d0-d2/a0-a2,-(sp)
                  movea.l  disp_addr2(a6),a0 /* Zeiger auf den Treiber */
                  jsr      (a0)           /* Treiber aufrufen */
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * OPEN VIRTUAL SCREEN WORKSTATION (VDI 100)
 */
v_opnvwk:         movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a5
                  cmpi.w   #1,opcode2(a1) /* v_opnbm()? */
                  bne.s    v_opnvwk_id
                  cmpi.w   #20,n_intin(a1) /* richtige Parameteranzahl? */
                  beq.s    v_opnbm
v_opnvwk_id:      move.w   driver_id(a6),d3 /* Geraetekennung */
                  movea.l  device_drvr(a6),a3
                  move.w   wk_handle(a6),d7 /* Handle der physikalischen Workstation */
                  bsr      alloc_wk       /* Workstation-Speicher allozieren */
                  tst.w    d4             /* Fehler? */
                  beq.s    v_opnvwk_exit
                  movem.l  a0-a1,-(sp)
                  movea.l  a3,a0
                  movea.l  driver_offscreen(a3),a1
                  bsr      wk_defaults    /* Workstation initialisieren */
                  movem.l  (sp)+,a0-a1
                  addq.w   #1,driver_use(a3) /* Semaphore inkrementieren */
v_opnvwk_io:      bsr      opnwk_io
/*                  bsr      set_dispatcher */ /* Dispatcher eintragen */
v_opnvwk_exit:    movem.l  (sp)+,d1-d7/a2-a5
                  rts
v_opnvwk_err:     move.w   d4,d0          /* Handle */
                  bsr      free_wk        /* Workstation freigeben */
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/*
 * Eingaben:
 * d1.l pb
 * d4.w Handle
 * a1.l contrl
 * a2.l intin
 * a3.l ptsin
 * a6.l Workstation
 * Ausgaben:
 * ...
 */
v_opnbm:          move.l   a2,-(sp)       /* intout */
                  move.l   s_addr(a1),-(sp)  /* MFDB * */
                  movea.l  a6,a1
                  movea.l  device_drvr(a6),a0
                  jsr      create_bitmap  /* WK   *create_bitmap( DEVICE_DRIVER *device_driver, WK *dev_wk, MFDB *m, WORD *intin ) */
                  addq.l   #8,sp          /* Stack korrigieren */
                  move.l   a0,d0
                  beq.s    v_opnbm_err
                  movea.l  a0,a6
                  movea.l  (sp),a0        /* pb */
                  move.l   a0,d1
                  movem.l  (a0),a1-a5
                  move.w   wk_handle(a6),handle(a1)   /* Handle ausgeben */
                  bsr      v_opnwk_in     /* intin beruecksichtigen */
                  movea.l  bitmap_drvr(a6),a2
                  movea.l  DRIVER_code(a2),a2
                  movea.l  DRVR_opnwkinfo(a2),a2
                  movea.l  a4,a0
                  movea.l  a5,a1
                  jsr      (a2)
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

v_opnbm_err:      move.l   (sp),a0        /* pb */
                  move.l   (a0),a1        /* contrl */
                  clr.w    handle(a1)
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/* void clear_bitmap( WK *wk ) */
clear_bitmap:     move.l   a6,-(sp)
                  movea.l  a0,a6
                  bsr      v_clrwk
                  movea.l  (sp)+,a6
                  rts

/* void transform_bitmap( MFDB *src, MFDB *des, WK *wk ) */
transform_bitmap: movem.l  a2/a6,-(sp)
                  movea.l  12(sp),a6
                  movea.l  p_transform(a6),a2
                  jsr      (a2)
                  movem.l  (sp)+,a2/a6
                  rts

/*
 * Fehler bei v_clswk
 * Eingaben
 * d0.w handle
 */
v_clswk_err:      movem.l  (sp)+,d1-d2/a2
                  bra      v_clsvwk       /* dann v_clsvwk */

/*
 * CLOSE WORKSTATION (VDI 2)
 */
v_clswk:          movem.l  d1-d3/a2,-(sp)
                  movea.l  pb_control(a0),a1
                  move.w   handle(a1),d0  /* contrl[6] = Handle */
                  beq.s    v_clswk_exit   /* Handle = 0 ? */
                  movea.l  device_drvr(a6),a2   /* Zeiger auf die Treiberstruktur */
                  move.l   a2,d2          /* kein Geraetetreiber? */
                  beq.s    v_clswk_exit
                  cmp.w    driver_open_hdl(a2),d0  /* erstes Handle des Geraetes? */
                  bne.s    v_clswk_err
                  move.w   driver_id(a6),d2 /* Geraetenummer - 1 */
                  moveq.l  #MAX_HANDLES-1,d3
                  lea.l    (wk_tab).w,a1
v_clswk_all:      movea.l  (a1)+,a2
                  cmp.w    driver_id(a2),d2 /* zu schliessenden Workstation? */
                  bne.s    v_clswk_next
                  cmpa.l   (aes_wk_ptr).w,a2     /* statische Workstation? */
                  beq.s    v_clswk_phys
                  cmpa.l   a6,a2          /* physikalische Workstation? */
                  beq.s    v_clswk_phys
                  bsr      call_clsvwk
                  bra.s    v_clswk_next
v_clswk_phys:     move.l   #closed,-4(a1) /* schliessen */
v_clswk_next:     dbra     d3,v_clswk_all
                  movem.l  d0/a0-a1/a6,-(sp)
                  movea.l  pb_control(a0),a1
                  move.w   #VST_UNLOAD_FONTS,opcode(a1) /* neue Funktionsnummer */
                  bsr      vst_unload_fonts /* Fonts der phys. WK entfernen */
                  movem.l  (sp)+,d0/a0-a1/a6
                  movea.l  pb_control(a0),a1
                  move.w   #V_CLSWK,(a1)
                  movea.l  device_drvr(a6),a2   /* Zeiger auf die Treiberstruktur */
                  clr.w    driver_use(a2) /* Treiber nicht in Gebrauch ! */
                  movea.l  driver_addr(a2),a1
                  movea.l  DRVR_wk_reset(a1),a1
                  lea.l    (nvdi_struct).w,a0    /* NVDI-Struktur uebergeben */
                  jsr      (a1)           /* Workstation zuruecksetzen */
                  bsr      reset_interrupts  /* Interrupts ausklinken */
                  move.l   #$45644449,d0        /*  'EdDI' Offscreen-Funktionen sind nicht mehr vorhanden */
                  bsr      reset_cookie
v_clswk_exit:     movem.l  (sp)+,d1-d3/a2
                  rts

/*
 * v_clsvwk() oder v_clsbm() aufrufen
 * kein Register wird veraendert
 * Eingaben:
 * d1.l pb
 * a0.l pb
 * a2.l Workstation
 * Ausgaben:
 * ...
 */
call_clsvwk:      rts

/*
 * CLOSE VIRTUAL SCREEN WORKSTATION (VDI 101)
 */
v_clsvwk:         movem.l  d1-d2/a2,-(sp)
                  movea.l  (a0),a1        /* contrl */
                  move.w   handle(a1),d0  /* contrl[6] = Handle */
                  beq.s    v_clsvwk_exit  /* Handle = 0 ? */
                  cmp.w    #1,d0          /* AES-Workstation? */
                  beq.s    v_clsvwk_err
                  tst.l    bitmap_addr(a6)   /* Offscreen? */
                  bne.s    v_clsbm
                  movea.l  device_drvr(a6),a2
v_clsvwk_nvdi:    movea.l  driver_addr(a2),a1
                  movea.l  DRVR_wk_reset(a1),a1
                  lea.l    (nvdi_struct).w,a0
                  jsr      (a1)           /* Workstation zuruecksetzen */
                  subq.w   #1,driver_use(a2) /* Semaphore dekrementieren */
                  bsr      free_wk        /* Workstation schliessen */
v_clsvwk_exit:    movem.l  (sp)+,d1-d2/a2
                  rts

v_clsbm:          movea.l  bitmap_drvr(a6),a1
                  movea.l  DRIVER_code(a1),a1
                  movea.l  DRVR_wk_reset(a1),a1
                  lea.l    (nvdi_struct).w,a0
                  jsr      (a1)           /* Workstation zuruecksetzen */
                  movea.l  a6,a0
                  jsr      delete_bitmap  /* WORD delete_bitmap( WK *wk ) */
                  movem.l  (sp)+,d1-d2/a2
                  rts

/*
 * Fehler bei v_clsvwk
 * Eingaben
 * d0.w handle
 */
v_clsvwk_err:     movem.l  (sp)+,d1-d2/a2
                  cmp.w    #1,d0          /* statische Workstation ? */
                  beq.s    v_clsvwk_err_exit
                  bra      v_clswk        /* dann v_clswk */
v_clsvwk_err_exit:rts

/* Verschiedene Interrupts fuers NVDI deinstallieren */
reset_interrupts: movem.l  d0-d2/a0-a2,-(sp)
                  move.w   sr,-(sp)
                  ori.w    #$0700,sr
/* Interrupt-Vektoren setzen */
                  move.l   (old_etv_timer).w,(etv_timer).w
                  lea.l    (USER_TIM).w,a0  /* Line-A-Vektoren loeschen */
                  clr.l    (a0)+          /* USER_TIM */
                  clr.l    (a0)+          /* NEXT_TIM */
                  clr.l    (a0)+          /* USER_BUT */
                  clr.l    (a0)+          /* USER_CUR */
                  clr.l    (a0)+          /* USER_MOT */
                  clr.l    -(sp)
                  clr.l    -(sp)
                  clr.l    -(sp)          /* turn off mouse Initmouse(0) */
                  trap     #XBIOS
                  lea.l    12(sp),sp
                  movea.l  (vbl_queue).w,a0
                  clr.l    (a0)           /* reset VBL routine */
                  move.w   (sp)+,sr
                  movem.l  (sp)+,d0-d2/a0-a2
                  rts

/*
 * CLEAR WORKSTATION (VDI 3)
 */
v_clrwk:          movem.l  d1-d7/a2-a5,-(sp)
                  move.w   wr_mode(a6),-(sp)
                  move.w   f_interior(a6),-(sp)
                  move.l   f_pointer(a6),-(sp)
                  move.w   f_planes(a6),-(sp)
                  clr.w    wr_mode(a6)                /* Replace */
                  move.l   f_fill0(a6),f_pointer(a6)  /* leeres Fuellmuster */
                  clr.w    f_planes(a6)               /* monochrom */
                  clr.w    f_interior(a6)             /* weiss */
                  moveq.l  #0,d0
                  moveq.l  #0,d1
                  move.w   res_x(a6),d2               /* Breite - 1 */
                  move.w   res_y(a6),d3               /* Hoehe - 1 */
                  move.l   a6,-(sp)
                  bsr      fbox_noreg
                  movea.l  (sp)+,a6
                  move.w   (sp)+,f_planes(a6)
                  move.l   (sp)+,f_pointer(a6)
                  move.w   (sp)+,f_interior(a6)
                  move.w   (sp)+,wr_mode(a6)

/* Fuer Bildschirmtreiber sollte noch die Initialisierung des vt52 eingebaut werden. */

                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/*
 * UPDATE WORKSTATION (VDI 4)
 */
v_updwk:          rts                     /* Funktion ist beim Bildschirm unnoetig */

/*
 * LOAD FONTS (VDI 119)
 */
vst_load_fonts:   movem.l  d1-d3/a2-a5,-(sp)
                  movea.l  pb_control(a0),a1 /* contrl */
                  movea.l  pb_intout(a0),a4 /* intout */

                  tst.l    t_bitmap_fonts(a6) /* bereits Zeichensaetze geladen ? */
                  bne.s    vst_lfg_err2

                  move.l   20(a1),d0      /* keine Adresse ? ??? was: f_addr, thats contrl[10-11]??? */
                  beq.s    vst_lfg_err2
                  btst     #0,d0          /* ungerade Adresse ? */
                  bne.s    vst_lfg_err2
                  clr.w    t_bitmap_gdos(a6) /* Fonts nicht per GDOS geladen */
vst_lf_nvdi:      movea.l  d0,a0
                  move.l   a0,t_bitmap_fonts(a6)
vst_lf_in:        moveq.l  #-1,d0
                  moveq.l  #0,d1
vst_lf_loop:      cmp.w    font_id(a0),d0 /* gleiche Nummer ? */
                  beq.s    vst_lf_format
                  move.w   font_id(a0),d0
                  addq.w   #1,d1          /* Anzahl inkrementieren */
vst_lf_format:    tst.b    flags+1(a0)    /* Motorola- oder Intel- Format ? BUG: should btst #T_SWAP_BIT */
                  bne.s    vst_lf_mot
/* big nonsense: if the font is swapped, the header is swapped, too (and the bit to test would be in flags, not flags+1) */
                  movea.l  dat_table(a0),a1 /* Zeiger aufs Fontimage */
                  move.w   form_width(a0),d2
                  mulu.w   form_height(a0),d2
                  lsr.w    #1,d2
                  subq.w   #1,d2          /* Zaehler */
vst_lf_swap:      move.w   (a1),d3
                  ror.w    #8,d3          /* Byte-Reihenfolge umkehren */
                  move.w   d3,(a1)+
                  dbra     d2,vst_lf_swap
vst_lf_mot:       bset     #T_SWAP_BIT,flags+1(a0) /* Motorola-Format */
                  movea.l  next_font(a0),a0
                  move.l   a0,d2          /* weitere Fonts vorhanden */
                  bne.s    vst_lf_loop
                  move.w   d1,(a4)        /* intout[0] = zusaetzliche Fontanzahl */
                  move.l   t_bitmap_fonts(a6),(FONT_RING+8).w /* Kompatibilitaet */
                  movem.l  (sp)+,d1-d3/a2-a5
                  rts

vst_lfg_err2:     clr.w    (a4)
                  movem.l  (sp)+,d1-d3/a2-a5
                  rts

/*
 * UNLOAD FONTS (VDI 120)
 */
vst_unload_fonts: movem.l  d1-d2/a2,-(sp)
                  movea.l  pb_control(a0),a1
                  tst.l    t_bitmap_fonts(a6) /* Zeichensaetze geladen ? */
                  beq.s    vst_unload_exit
                  clr.l    t_bitmap_fonts(a6) /* keine Zeichensaetze ueber GDOS verf. */

vst_ulf_nvdi:     movem.l  (sp)+,d1-d2/a2
                  movea.l  d1,a0          /* pblock */
                  movem.l  d1-d7/a2,-(sp)
                  moveq.l  #T_SYSTEM_FACE,d0  /* Systemfont einstellen */
                  lea.l    (font_hdr1).w,a0
                  bra      vst_font_found

vst_unload_exit:  movem.l  (sp)+,d1-d2/a2
                  rts

/*
 * SET CLIPPING RECTANGLE (VDI 129)
 */
vs_clip:          movem.l  pb_intin(a0),a0-a1 /* intin/ptsin */
                  tst.w    bitmap_width(a6) /* Off-Screen-Bitmap? */
                  bne.s    vs_clip_bitmap
                  movem.l  d1-d5,-(sp)
                  movem.w  (DEV_TAB0).w,d4/d5  /* Breite -1/ Hoehe -1 */
                  move.w   (a0),d0        /* Clipping-Flag */
                  move.w   d0,(CLIP).w    /* wegen der Kompatibilitaet */
                  beq.s    vs_clip_off    /* Clipping ausgeschaltet ? */
                  move.w   (a1)+,d0
                  bpl.s    vs_clip_x1max
                  moveq.l  #0,d0
vs_clip_x1max:    cmp.w    d4,d0
                  ble.s    vs_clip_y1min
                  move.w   d4,d0
vs_clip_y1min:    move.w   (a1)+,d1
                  bpl.s    vs_clip_y1max
                  moveq.l  #0,d1
vs_clip_y1max:    cmp.w    d5,d1
                  ble.s    vs_clip_x2min
                  move.w   d5,d1
vs_clip_x2min:    move.w   (a1)+,d2
                  bpl.s    vs_clip_x2max
                  moveq.l  #0,d2
vs_clip_x2max:    cmp.w    d4,d2
                  ble.s    vs_clip_y2min
                  move.w   d4,d2
vs_clip_y2min:    move.w   (a1)+,d3
                  bpl.s    vs_clip_y2max
                  moveq.l  #0,d3
vs_clip_y2max:    cmp.w    d5,d3
                  ble.s    vs_clip_exgx
                  move.w   d5,d3
vs_clip_exgx:     cmp.w    d0,d2
                  bge.s    vs_clip_exgy
                  exg      d0,d2
vs_clip_exgy:     cmp.w    d1,d3
                  bge.s    vs_clip_save
                  exg      d1,d3
vs_clip_save:     movem.w  d0-d3,clip_xmin(a6)
                  movem.w  d0-d3,(XMINCL).w /* Kompatibilitaet (NEODESK etc.) */
vs_clip_exit:     movem.l  (sp)+,d1-d5
                  rts

vs_clip_off:      moveq.l  #0,d0
                  moveq.l  #0,d1
                  move.w   d4,d2
                  move.w   d5,d3
                  bra.s    vs_clip_save

vs_clip_bitmap:   movem.l  d1-d7,-(sp)
                  movem.w  (a1),d0-d3
                  movem.w  bitmap_off_x(a6),d4-d7  /* die Bitmap eingrenzendes Rechteck, bitmap_off_x, bitmap_off_y, bitmap_dx, bitmap_dy */
                  add.w    d4,d6
                  add.w    d5,d7
                  tst.w    (a0)           /* Clipping ein? */
                  bne.s    vs_clip_bx1min
                  move.w   d4,d0
                  move.w   d5,d1
                  move.w   d6,d2
                  move.w   d7,d3
vs_clip_bx1min:   cmp.w    d4,d0
                  bge.s    vs_clip_bx1max
                  move.w   d4,d0
vs_clip_bx1max:   cmp.w    d6,d0
                  ble.s    vs_clip_by1min
                  move.w   d6,d0
vs_clip_by1min:   cmp.w    d5,d1
                  bge.s    vs_clip_by1max
                  move.w   d5,d1
vs_clip_by1max:   cmp.w    d7,d1
                  ble.s    vs_clip_bx2min
                  move.w   d7,d1
vs_clip_bx2min:   cmp.w    d4,d2
                  bge.s    vs_clip_bx2max
                  move.w   d4,d2
vs_clip_bx2max:   cmp.w    d6,d2
                  ble.s    vs_clip_by2min
                  move.w   d6,d2
vs_clip_by2min:   cmp.w    d5,d3
                  bge.s    vs_clip_by2max
                  move.w   d5,d3
vs_clip_by2max:   cmp.w    d7,d3
                  ble.s    vs_clip_bexgx
                  move.w   d7,d3
vs_clip_bexgx:    cmp.w    d0,d2
                  bge.s    vs_clip_bexgy
                  exg      d0,d2
vs_clip_bexgy:    cmp.w    d1,d3
                  bge.s    vs_clip_bsave
                  exg      d1,d3
vs_clip_bsave:    movem.w  d0-d3,clip_xmin(a6)
                  movem.l  (sp)+,d1-d7
                  rts
