* Modul mit VDI-Funktionen und OBJECT- Funktionen

     INCLUDE "aesinc.s"
     INCLUDE "farbicon.s"
        TEXT


     FONTPROP  EQU  1


     XREF      config_status       ; von DOS

     XREF      but_int,mov_int
     XREF      fatal_err
     XREF      strlen,toupper,min,max,fillmem,null_s
     XREF      xy_in_grect,grects_intersect
     XREF      objc_wdraw,_objc_wdraw
;    XREF      wind_s3d

     XREF      xp_init             ; von FARBICON

     XDEF      objc_add
     XDEF      _objc_sysvar
     XDEF      objc_order
     XDEF      objc_delete
     XDEF      objc_draw
     XDEF      _objc_draw
     XDEF      _objc_find
     XDEF      _objc_change
     XDEF      _objc_offset,objc_offset
     XDEF      _objc_edit,objc_wedit
     XDEF      _form_center
     XDEF      _form_center_grect

     XDEF      obj_to_g
     XDEF      calc_obsize
     XDEF      set_xor_black,_set_xor_black
     XDEF      parentob
     XDEF      ob_modes
     XDEF      mouse_off,mouse_on,mouse_immed
     XDEF      vdi
     XDEF      vdi_quick
     XDEF      draw_bitblk
     XDEF      draw_line
     XDEF      drawbox
     XDEF      strplc_pcolor
     XDEF      blitcopy_rectangle
     XDEF      get_clip_grect
     XDEF      set_clip_grect
     XDEF      set_full_clip
     XDEF      set_ob_xywh
     XDEF      get_ob_xywh
     XDEF      v_clswk             ; => AESMAIN, MAC_BIOS (fuer Shutdown)
     XDEF      init_vdi
     XDEF      vq_gdos
     XDEF      v_pline
     XDEF      vro_cpyfm
     XDEF      v_drawgrect
     XDEF      v_drawedges
     XDEF      vq_color,vq_scrninfo,vintout
     XDEF      set_mform
     XDEF      bitblk_to_mfdb
     XDEF      set_scrmode
     XDEF      xp_raster
     XDEF      stw_title      ; nach AESMEN
     XDEF      fs_txt,fs_rtxt,fs_xtnt,fs_effct    ; => FSEL

     XDEF      enable_3d      ; WORD,  -> fnt_menu

* von AESMAIN

     XREF      scrp_cpy,scrp_pst


     OFFSET

xte_ptmplt:    DS.L 1
xte_pvalid:    DS.L 1
xte_vislen:    DS.W 1
xte_scroll:    DS.W 1

     TEXT

**********************************************************************
**********************************************************************
*
* VDI- Funktionen
*


**********************************************************************
*
* PUREC int vq_gdos( void )
*

vq_gdos:
 move.l   a2,-(sp)
 moveq    #-2,d0
 trap     #2
 addq.w   #2,d0
 movea.l  (sp)+,a2
 rts


**********************************************************************
*
* void vq_scrninfo( a0 = int *work_out )
*
* gibt es nur bei NVDI oder anderen erweiterten VDIs
* fuer Farbicons verwendet
*

vq_scrninfo:
 move.l   #$66000002,d0            ; 102: vq_scrninfo, intin[0] = 2
 move.w   #1,vcontrl+10            ; contrl[5] = 1
 move.l   a0,vdipb+12              ; intout auf work_out setzen
 bsr      vdi_1
 move.l   #vintout,vdipb+12        ; intout restaurieren
 rts


**********************************************************************
*
* void vst_effects( d0 = int effects )
* fuer Farbicons verwendet
*

vst_effects:
 move.w   d0,vintin                ; Bitmuster fuer Effekte
 move.l   #$6A000001,d0            ; 106: vst_effects
 bra      vdi_quick


**********************************************************************
*
* void vq_color( d0 = int index, d1 = int setflag )
* fuer Farbicons verwendet
*

vq_color:
 move.w   d0,vintin                ; index
 move.w   d1,vintin+2              ; setflag
 move.l   #$1a000002,d0            ; 26: vq_color
 bra      vdi_quick


**********************************************************************
*
* void v_clswk( void )
*
* Achtung: Ab MagiC 6 wird erst eine evtl. vorhandene Dummy-WS
* geschlossen
*

v_clswk:
 move.w   dummyvws,d0
 beq.b    vclw_weiter
 move.w   vcontrl+12,-(sp)         ; handle retten
 move.w   d0,vcontrl+12
 move.l   #$65000000,d0            ; close virtual workstation
 bsr      vdi_quick
 move.w   (sp)+,vcontrl+12         ; handle zurueck
vclw_weiter:
 move.l   #$02000000,d0            ; close workstation
 bra      vdi_quick


**********************************************************************
*
* PUREC void vdi( VDIPB *pb )
*

vdi:
 move.l   a0,d1
 moveq    #$73,d0
 trap     #2
 rts


**********************************************************************
*
* int vdi_1(d0.hi = int opcode, d0.lo = int val)
*
* Eingabe: opcode : Opcode der Funktion
*          val    : intin[0]
*
* Ruft einfache VDI- Funktionen auf, die nur einen Eingabewert haben
* (intin[0]) und keine Koordinatenpaare.
*

vdi_1:
 move.w   d0,vintin                ; intin[0]
 move.w   #1,d0                    ; intlen = 1
;bra.b    vdi_quick

**********************************************************************
*
* int vdi_quick(d0 = long code)
*
* Eingabe: code : Bit 24..31 = Opcode der Funktion
*                 Bit 16..24 = ptsin_len
*                 Bit  8..15 = dummy
*                 Bit  0.. 7 = intin_len
*
* Das Workstationhandle wird eingesetzt und das vcontrl[]- Array
* eingesetzt und das VDI aufgerufen
*

vdi_quick:
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 rts


**********************************************************************
*
* init_vdi( void )
*
* Oeffnet Workstation, setzt Mausinterrupts
*

init_vdi:
 clr.l    xp_ptr                   ; hier kann sich jemand einklinken
 bsr      open_wstn
 jsr      init_vdivars

 move.l   #$00000005,vintin        ; linksbuendig, Zeichenzellenoberkante
 move.l   #$27000002,d0            ; vst_alignment
 bsr      vdi_quick

 clr.w    dummyvws
 tst.w    finfo_big+fontmono       ; grosser Zeichensatz proportional?
 bne.b    initvdi_nodummy          ; nein, keine Dummy-WS

* Dummy-Ws fuer daemliche MyDials

 suba.w   #2*128,sp                ; Platz fuer work_out[] (dummy)
 lea      vintin+2,a0              ; ab vintin[1]
 moveq    #8,d0                    ; vintin[1..9] = 1
initvdi_loop1:
 move.w   #1,(a0)+
 dbra     d0,initvdi_loop1
 move.w   #2,(a0)                  ; vintin[10] = 2 (Rasterkoordinaten)

 move.l   sp,vdipb+12              ; intout auf dummy setzen
 move.w   vcontrl+12,-(sp)         ; handle retten
 move.l   #$6400000b,d0            ; v_opnvwk
 bsr      vdi_quick
 move.l   #vintout,vdipb+12        ; intout restaurieren
 move.w   vcontrl+12,dummyvws      ; Dummy-WS merken
 move.w   (sp)+,vcontrl+12         ; handle zurueck
 adda.w   #2*128,sp


initvdi_nodummy:
 tst.l    xp_ptr                   ; hat sich jemand eingeklinkt ?
 bne.b    initvdi_ptr              ; ja
 move.w   nplanes,d0
 jsr      xp_init                  ; Farbicons
 move.w   d0,xp_mode               ; 0=err 1=wandeln -1=nicht_wandeln
initvdi_ptr:
 bsr.b    set_mouse_ints           ; Maus- und Buttoninterrupts setzen
 move.l   #$7c000000,d0            ; sample mouse button state
 bsr      vdi_quick                ; vq_mouse
 lea      vptsout,a0
 move.w   (a0)+,gr_mkmx
 move.w   (a0)+,gr_mkmy
 rts


**********************************************************************
*
* set_scrmode(d0 = int mode)
*

set_scrmode:
 lea      curr_scrmode,a1          ; Adresse des alten Werts
 cmp.w    (a1),d0                  ; Modus aendern
 beq.b    sscr_ret                ; nein, nichts tun
 move.w   d0,(a1)                  ; neuen Modus sichern
 beq.b    sscr_l1                ; neuer ist Textmodus
 moveq    #2,d0                    ; Exit alpha mode
 bsr.b    v_escape
set_mouse_ints:
 move.l   #but_int,vcontrl+14      ; Zusatzcode contrl[7]
 move.l   #$7d000000,d0            ; Exchange button change vector
 bsr      vdi_quick                ; vex_butv
 move.l   vcontrl+18,old_but_int   ; Zusatzcode contrl[9]
 move.l   #mov_int,vcontrl+14      ; Zusatzcode contrl[7]
 move.l   #$7e000000,d0            ; exchange mouse movement vector
 bsr      vdi_quick                ; vex_motv
 move.l   vcontrl+18,old_mov_int   ; Zusatzcode contrl[9]
sscr_ret:
 rts
sscr_l1:
 moveq    #3,d0                    ; Enter alpha mode
 bsr.b    v_escape                 ; Bildschirm loeschen und Cursor ein
 move.l   old_but_int,vcontrl+14   ; Zusatzcode contrl[7]
 move.l   #$7d000000,d0            ; Exchange button change vector
 bsr      vdi_quick                ; vex_butv
 move.l   old_mov_int,vcontrl+14   ; Zusatzcode contrl[7]
 move.l   #$7e000000,d0            ; exchange mouse movement vector
 bra      vdi_quick                ; vex_motv

v_escape:
 move.w   d0,vcontrl+10            ; Id fuer Unter- Opcode
 move.l   #$05000000,d0            ; v_escape
 bra      vdi_quick

graf_mouse_off_immded:
 move.l   #$7b000000,d0            ; Hide cursor
 bra      vdi_quick                ; v_hide_c

mouse_immed:
 clr.w    moff_cnt
 move.l   #$7a000000,d0            ; show cursor, sofort einschalten
 bra      vdi_1                    ; v_show_c(FALSE)


**********************************************************************
*
* void set_mform(a0 = int *mform)
*

set_mform:
 move.l   a0,-(sp)
 bsr.b    mouse_off
 move.l   (sp)+,a0
 move.w   vcontrl+12,-(sp)         ; contrl[6] = handle
 clr.l    -(sp)                    ; contrl[5] = 0
                                   ; contrl[4] = #intout = 0
 move.l   #$00000025,-(sp)         ; contrl[3] = #intin = 37
                                   ; contrl[2] = #ptsout = 0
 move.l   #$006f0000,-(sp)         ; contrl[1] = #ptsin = 0
                                   ; contrl[0] = 111 (vsc_form)
 move.l   sp,a1                    ; a1 = contrl
 clr.l    -(sp)                    ; ->ptsout = NULL
 clr.l    -(sp)                    ; ->intout = NULL
 clr.l    -(sp)                    ; ->ptsin = NULL
 move.l   a0,-(sp)                 ; ->intin
 move.l   a1,-(sp)                 ; ->contrl
 move.l   sp,d1
 moveq    #$73,d0
 trap     #2
 adda.w   #34,sp
;bra.b    mouse_on

/* alte Routine: */
/*
 moveq    #$24,d0                  ; 37 WORDs
 lea      vintin,a1
smfr_loop:
 move.w   (a0)+,(a1)+
 dbf      d0,smfr_loop
 move.l   #$6f000025,d0            ; set mouse form
 bsr      vdi_quick                ; vsc_form
;bra.b    mouse_on
*/

mouse_on:
 subq.w   #1,moff_cnt
 bne.b    mouse_ende
 move.l   #$7a000001,d0            ; show cursor, schachteln
 bra      vdi_1                    ; v_show_c

mouse_off:
 tst.w    moff_cnt
 bne.b    mouse_inc_counter
 move.l   #$7b000000,d0            ; Hide cursor
 bsr      vdi_quick                ; v_hide_c
mouse_inc_counter:
 addq.w   #1,moff_cnt
mouse_ende:
 rts


**********************************************************************
*
* void open_wstn( void )
*
* Oeffnet die Workstation.
*
* Achtung: Setzt jetzt auch <ptsin> auf vptsin[]
*          <ptsin> darf nicht mehr geaendert werden!
*
* Achtung: Hier wird contrl[6] mit der Workstation initialisiert
*          und darf nicht mehr geaendert werden
*
* Achtung: Unterstuetzung von NVDI
*
* 11.11.95:    dflt_xdv fuer den Falcon ergaenzt
*

open_wstn:
 lea      vdipb,a0
* contrl einsetzen und initialisieren
 lea      vcontrl,a1
 move.l   a1,(a0)+                 ; vdipb[0] = vcontrl
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)                     ; contrl[0..11] loeschen (Hibytes!)
* intin einsetzen und initialisieren
 lea      vintin,a1
 move.l   a1,(a0)+                 ; vdipb[1] = work_in          (intin)
 move.w   vdi_device,(a1)+
 moveq    #8,d0
owst_loop:
 move.w   #1,(a1)+
 dbf      d0,owst_loop
 move.w   #2,(a1)+                 ; RC- Koordinaten

; fuer NVDI:
 move.l   #'XRES',(a1)+
 move.w   dflt_xdv,(a1)

 move.l   #vptsin,(a0)+            ; vdipb[2] = ptsin
 move.l   #work_out,(a0)+          ; vdipb[3] = work_out         (intout)
 move.l   #work_out+90,(a0)        ; vdipb[4] = work_out+90      (ptsout)
 move.w   dflt_xdv,work_out+90     ; FALCON!!!
;move.l   #$0100000b,d0            ; open workstation
 move.l   #$0100000e,d0            ; open workstation (xtended NVDI mode)
 bsr      vdi_quick
 move.l   #vintout,vdipb+12
 move.l   #vptsout,vdipb+16
 tst.w    vcontrl+12               ; wstn_handle
 bne.b    opw_ok                   ; handle != 0, OK
 subq.w   #1,vdi_device            ; war das Geraet bereits 1 ?
 beq      fatal_err                ; ja, System anhalten
 move.w   #1,vdi_device            ; Geraet auf 1 setzen
 bra      open_wstn                ; und nochmal versuchen
opw_ok:
 lea      nvdi_workstn,a2
 clr.l    (a2)                     ; Default: kein NVDI

     IFNE NVDI

 lea      vcontrl+14,a0
 cmpi.l   #'NVDI',(a0)+
 bne.b    no_nvdi
 move.l   (a0),a0                  ; &nvdi_struc
 addq.l   #8,a0                    ; &nvdi_struc.nvdi_wk
 move.l   (a0)+,a1                 ; a1 = Workstationpointer fuer NVDI
 move.l   a1,(a2)+                 ; Workstationpointer fuer NVDI
 move.l   (a0),(a2)                ; Fuellmuster fuer NVDI
 move.w   NVDI_device_id(a1),d0    ; Geraete- Id - 1
 addq.w   #1,d0                    ; auf Geraete- Id umrechnen
 bra.b    opw_setdev               ; und als vdi_device setzen

no_nvdi:

     ENDIF

 move.w   #4,-(sp)
 trap     #14                      ; xbios Getrez
 addq.w   #2,sp
 addq.w   #2,d0

/*
 lea      work_out,a1
 moveq    #2,d0
 cmpi.w   #319,(a1)+
 beq.b    opw_setdev               ; 320 Punkte horizontal: vdi_device = 2
 moveq    #3,d0
 cmpi.w   #399,(a1)
 bne.b    opw_setdev
 moveq    #4,d0                    ; 400 Punkte vertikal: vdi_device = 4
*/

opw_setdev:
 move.w   d0,vdi_device
 move.w   #1,curr_scrmode          ; Grafikmodus
 rts


**********************************************************************
*
* d0 = int/d1 = long _objc_sysvar(d0 = int get_set,
*                                d1 = int which, d2 = long data)
*
* Eingabe:
*    d0 = mode (set/get)
*    d1 = which
*    d2 = data
*
* Ausgabe:
*    d0 = errcode
*    d1 = data
*
* LK3DIND      1
* LK3DACT      2
* INDBUTCOL    3
* ACTBUTCOL    4
* BACKGRCOL    5
* AD3DVALUE    6
*
* MX_ENABLE3D  10
* MX_MENUCOL   11        Menuefarbe ab MagiC 6
*

_objc_sysvar:
 cmpi.w   #10,d1					; MX_ENABLE3D
 beq.b    obs_10                   ; Spezialfunktion fuer MagiC
 cmpi.w   #11,d1					; MX_MENUCOL
 beq.b    obs_11                   ; Spezialfunktion fuer MagiC
 tst.w    d0                       ; mode == set ?
 bne.b    obs_err                  ; ja, ist immer Fehler
 subq.w   #1,d1
 cmpi.w   #5,d1                    ; AD3DVALUE-1
 bhi.b    obs_err                  ; Falscher Code
 tst.w    enable_3d
 beq.b    obs_err
 add.w    d1,d1
 add.w    d1,d1
 move.l   obst(pc,d1.w),d1
 bra.b    obs_ok
obs_err:
 moveq    #0,d0
 rts

obs_11:
 tst.w    d0                       ; Wert aendern?
 bne.b    obs_err                  ; nicht erlaubt
 tst.w    enable_3d                ; 3D-Objekte aktiviert?
 beq.b    obs_11_white             ; nein, Menue ist weiss
 btst     #7,look_flags+1          ; 3D-Menues aktiviert?
 beq.b    obs_11_white             ; nein
 tst.w    finfo_big+fontmono       ; grosser Zeichensatz aequidistant?
 bne.b    obs_11_white             ; ja, Menue ist weiss
 moveq    #8,d1                    ; Menue ist hellgrau
 bra.b    obs_ok2
obs_11_white:
 moveq    #WHITE,d1                ; Menue ist weiss
obs_ok2:
 swap     d1
 bra.b    obs_ok

obs_10:
 move.w   enable_3d,d1             ; alter Wert
 swap     d1
 tst.w    d0                       ; nur Wert holen ?
 beq.b    obs_ok                   ; ja, OK
 swap     d2
 move.w   d2,d0                    ; neuer Wert
 beq.b    obs_setok                ; 3D deaktivieren, OK
 cmpi.w   #4,nplanes
 bcc.b    obs_setok                ; genuegend Planes
 move.l   d1,-(sp)
 clr.w    enable_3d
; moveq   #0,d0
; jsr     wind_s3d                 ; Fenster umschalten
 move.l   (sp)+,d1
 bra.b    obs_err
obs_setok:
 move.w   d0,enable_3d
; move.l  d1,-(sp)
;move.w   d0,d0
; jsr     wind_s3d                 ; Fenster umschalten
; move.l  (sp)+,d1
obs_ok:
 moveq    #1,d0
 rts


obst:
 DC.L     $00010001                ; LK3IND: eindruecken und Farbaenderung
 DC.L     $00010000                ; LK3DACT: nur eindruecken
 DC.L     $00080000                ; INDBUTCOL: Farbe 8 (hellgrau)
 DC.L     $00080000                ; ACTBUTCOL: Farbe 8 (hellgrau)
 DC.L     $00080000                ; BACKGRCOL: Farbe 8 (hellgrau)
 DC.L     $00000000                ; AD3DVALUE: 0 (kein Offset)


**********************************************************************
*
* void v_pline(d0 = int count, a0 = int *pxy)
*

v_pline:
 lea      vcontrl,a1
 move.w   #6,(a1)+
 move.w   d0,(a1)+
 clr.l    (a1)
 lea      vdipb,a1
 move.l   a1,d1
 move.l   a0,8(a1)                 ; vdipb+8 aendern
 moveq    #$73,d0
 trap     #2
 move.l   #vptsin,vdipb+8          ; vdipb+8 restaurieren
 rts


**********************************************************************
*
* void vro_cpyfm(d0 = int wr_mode, MFDB *psrcMFDB, MFDB *pdestMFDB)
*

vro_cpyfm:
 move.w   d0,vintin                ; intin[0] = wr_mode
 lea      4(sp),a0
 lea      vcontrl+14,a1            ; Zusatzcode contrl[7]
 move.l   (a0)+,(a1)+              ; contrl[7..8] = MFDB *
 move.l   (a0),(a1)                ; contrl[9.10] = MFDB *
 move.l   #$6d040001,d0            ; copy raster, opaque
 movep.l  d0,-17(a1)               ; (vcontrl+18)-1
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 rts


**********************************************************************
*
* void vrt_cpyfm(d0 = int wr_mode, MFDB *psrcMFDB,
*                MFDB *pdestMFDB, int color_index0, int color_index1)
*

vrt_cpyfm:
 lea      vintin,a2
 move.w   d0,(a2)+
 lea      4(sp),a0
 lea      vcontrl+14,a1            ; Zusatzcode contrl[7]
 move.l   (a0)+,(a1)+
 move.l   (a0)+,(a1)
 move.l   (a0),(a2)
 move.l   #$79040003,d0            ; copy raster, transparent
 movep.l  d0,-17(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 rts


**********************************************************************
*
* void vsl_width(d0 = int width)
*

vsl_width:
 lea      vptsin,a1
 move.w   d0,(a1)+
 clr.w    (a1)
 move.l   #$10010000,d0            ; set polyline width
 bra      vdi_quick




**********************************************************************
**********************************************************************
*
* Zeichenroutinen, uebergeordnete VDI- Routinen
*


**********************************************************************
*
* void drawbox(d0 = int wmode, d1 = int color, d2 = int aes_patt,
*              a0 = GRECT *g)
*

drawbox:

     IFNE NVDI

 move.w   d1,a1                    ; a1 = color
 move.l   nvdi_workstn,d1
 bne      drab_nvdi

     ENDIF

* OHNE NVDI

 movem.l  d6/d7/a0,-(sp)
 move.w   a1,d6                    ; d6 = color
 move.w   d2,d7                    ; #^# VDI zerstoert manchmal d2
;move.w   d2,d2                    ; d2 = aes_patt
* Schreibmodus
;move.w   d0,d0
 bsr      set_wmode
* Fuellfarbe
 lea      curr_fcolor,a0
 cmp.w    (a0),d6
 beq.b    drab_nocol
 move.w   d6,(a0)
 move.w   d6,vintin                ; color_index
 move.l   #$19000001,d0            ; set fill color index (vsf_color())
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
drab_nocol:
* Fuelltyp
 moveq    #0,d6                    ; bei IP_HOLLOW d6 = 0 (leer)
 tst.w    d7                       ; patt, IP_HOLLOW ?
 beq.b    drab_filltype
 moveq    #1,d6                    ; bei IP_SOLID d6 = 1 (voll)
 cmpi.w   #7,d7                    ; IP_SOLID ?
 beq.b    drab_filltype
 moveq    #2,d6                    ; per Default style = 2 (Muster)
drab_filltype:
 lea      curr_style,a0
 cmp.w    (a0),d6
 beq.b    drab_nostyle
 move.w   d6,(a0)
 move.w   d6,vintin                ; style
 move.l   #$17000001,d0            ; set fill interior style
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
drab_nostyle:
* Muster
 lea      curr_patt,a0
 cmp.w    (a0),d7
 beq.b    drab_nopatt
 move.w   d7,(a0)
 move.w   d7,vintin
 move.l   #$18000001,d0            ; set fill style index (Fuellmuster)
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
drab_nopatt:
 move.l   a5,a0
 movem.l  (sp)+,d6/d7/a0

     IFNE NVDI

 bra      drab_draw

* MIT NVDI

drab_nvdi:
 move.l   d1,a2                    ; a2 = WORKSTATION
 subq.w   #1,d0
 move.w   d0,NVDI_wr_mode(a2)      ; Schreibmodus setzen
 move.w   a1,d0                    ; Fuellfarbe
 cmp.w    NVDI_colors(a2),d0       ; im zulaessigen Bereich ?
 bls.b    drab_nvdi_ok             ; ja
 moveq    #1,d0                    ; zu gross, setze Schwarz
drab_nvdi_ok:
 move.w   d0,NVDI_f_color(a2)      ; Fuellfarbe setzen
 move.l   nvdi_patterns,a1         ; a1 = Zeiger auf Muster
 moveq    #0,d0                    ; FIS_HOLLOW
 move.w   d2,NVDI_f_style(a2)      ; Musterindex setzen (aes_pattern)
 beq.b    drab_setpatt
 lea      32(a1),a1
 moveq    #1,d0                    ; FIS_SOLID
 cmpi.w   #7,d2                    ; IP_SOLID ?
 beq.b    drab_setpatt
 moveq    #2,d0                    ; FIS_PATTERN
 lsl.w    #5,d2                    ; * 32 fuer Musterzugriff (d1 >= 1)
 add.w    d2,a1                    ; auf Tabelle addieren
drab_setpatt:
 move.w   d0,NVDI_f_interior(a2)   ; Fuelltyp setzen
 move.l   a1,NVDI_f_pointer(a2)
drab_draw:
 lea      vptsin,a1
 move.l   (a0),(a1)+               ;  GRECT in ORECT umrechnen
 move.l   (a0)+,(a1)
 move.w   (a0)+,d0
 subq.w   #1,d0
 add.w    d0,(a1)+
 move.w   (a0),d0
 subq.w   #1,d0
 add.w    d0,(a1)

/*
move.l    vptsin,$4a8
move.l    vptsin+4,$4ac
move.l    xclip,$384
move.l    wclip,$388
*/

 lea      vcontrl,a1
 move.l   #$72020000,d0            ; vr_recfl  (fill rectangle)
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 rts

     ENDIF


**********************************************************************
*
* FINFO * tjust( d0 = int font, d1 = char just, d2 = int width,
*             a0 = GRECT *g, a1 = GRECT *outg)
*
* Justiert den Text, der bereits mit str_to_ints() nach txvintin[]
* kopiert wurde, horizontal und vertikal im Rechteck g. Vertikal wird
* der Text stets zentriert, horizontal je nach <just>.
* Wenn <width> vorgegeben ist, wird es verwendet.
*
* Wenn der Text vertikal nicht passt, wird er trotzdem nicht verkuerzt.
* Wenn der Text horizontal nicht passt, wird er verkuerzt.
*
* Die Funktion modifiziert ggf. die Anzahl der darstellbaren Zeichen
* in vintin_len.
* Rueckgabe: in <outg> x,y,w,h fuer den justierten Text.
*

tjust:
 movem.l  a6/a5/a4/d7/d6,-(sp)
 move.l   a0,a6               ; a6 = ing
 move.l   a1,a5               ; a5 = outg
 move.b   d1,d7               ; d7 = just
 move.w   d2,d6
;move.w   d0,d0
 bsr      setfont
 move.l   a0,a4               ; a4 = (FINFO *)

* vertikaler Randausgleich

 move.l   g_x(a6),g_x(a5)     ; x und y zunaechst kopieren
 move.w   fontcharH(a4),d0    ; Texthoehe
 move.w   g_h(a6),d1          ; Eingabehoehe (Objekthoehe)
 sub.w    d1,d0               ; Zeichenhoehe - Objekthoehe
 bgt.b    tju_hori            ; Zeichen zu hoch, nicht zentrieren
 neg.w    d0                  ; Objekthoehe - Zeichenhoehe
 addq.w   #1,d0
 lsr.w    #1,d0
 add.w    d0,g_y(a5)          ; vertikaler Randausgleich
 move.w   fontcharH(a4),d1    ; Ausgabehoehe <= Objekthoehe

* horizontaler Randausgleich

tju_hori:
 move.w   d1,g_h(a5)          ; Ausgabe-Hoehe
 move.w   d6,d0
 bne.b    tju_is_hori
 move.w   vintin_len,d0
 bsr      extent              ; Breite in Pixel

tju_is_hori:
 move.w   d0,d2
 sub.w    g_w(a6),d2
 ble.b    tju_fits            ; passt
 subq.w   #1,vintin_len       ; nein, verkuerzen
 bne.b    tju_hori            ; Schleife

tju_fits:
 move.w   d0,g_w(a5)          ; tats. Breite zurueckgeben
 tst.b    d7
 beq.b    tju_end             ; TE_LEFT
 neg.w    d2                  ; d2 = freie Breite
 subq.b   #1,d7
 bne.b    tju_centr
* TE_RIGHT
 add.w    d2,g_x(a5)          ; horizontaler Rand
 bra.b    tju_end
tju_centr:
* TE_CNTR
 addq.w   #1,d2
 lsr.w    #1,d2
 add.w    d2,g_x(a5)          ; horizontal zentrieren
tju_end:
 move.l   a4,a0
 movem.l  (sp)+,a6/a5/a4/d7/d6
 rts


**********************************************************************
*
* EQ/NE int str_to_ints(a0 = char *source)
*
* kopiert die "char"- Zeichenkette ins txvintin- Feld und gibt die
* Laenge zurueck (max. 256). Schreibt die Laenge auch nach vintin_len.
* Fuer VDI- Aufrufe
*
* Merkt im Feld "vintin_dirty", ob Steuerzeichen dabei sind. Die
* Steuerzeichen muessen spaeter im Systemzeichensatz ausgegeben werden.
*

str_to_ints:
 move.l   a0,d0                    ; Stringanfang merken
 lea      txvintin,a1
 sf       vintin_dirty             ; kein Steuerzeichen
 moveq    #0,d1
 moveq    #' ',d2
s2i_loop:
 move.b   (a0)+,d1
 beq.b    s2i_ende
 cmp.b    d2,d1
 bcc.b    s2i_cont
 st       vintin_dirty
s2i_cont:
 move.w   d1,(a1)+
 bra.b    s2i_loop
s2i_ende:
 subq.l   #1,a0                    ; das ()+ korrigieren
 sub.l    d0,a0                    ; Stringanfang abziehen
 move.l   a0,d0                    ; Differenz zurueckgeben
 move.w   d0,vintin_len
 rts


**********************************************************************
*
* EQ/NE int lstr2int(a0 = char *source, d0 = WORD len)
*
* Wie "str_to_ints", aber die Laenge wird vorgegeben
*

lstr2int:
 lea      txvintin,a1
 sf       vintin_dirty             ; kein Steuerzeichen
 moveq    #0,d1
 moveq    #' ',d2
 move.w   d0,vintin_len
 bra.b    ls2i_next
ls2i_loop:
 move.b   (a0)+,d1
 cmp.b    d2,d1
 bcc.b    ls2i_cont
 st       vintin_dirty
ls2i_cont:
 move.w   d1,(a1)+
ls2i_next:
 dbra     d0,ls2i_loop
ls2i_ende:
 moveq    #0,d0
 move.w   vintin_len,d0
 rts


**********************************************************************
*
* PUREC void fs_rtxt( a0 = char *text, a1 = GRECT *rahmen )
*
* rechtsbuendige Text-Ausgabe fuer die Dateiauswahl.
*

fs_rtxt:
 move.l   a2,-(sp)
 movem.l  a0/a1,-(sp)
 moveq    #REPLACE,d0
 bsr      set_wmode
 lea      finfo_big,a0
 bsr      _setfont
;rechtsbuendig, Zeichenzellenoberkante
 move.l   #$00020005,vintin        ; rechtsbuendig, Zeichenzellenoberkante
 move.l   #$27000002,d0            ; vst_alignment
 bsr      vdi_quick
 movem.l  (sp)+,a0/a1
 move.l   g_x(a1),vptsin
 bsr      str_to_ints
 beq.b    rs_rnix
 bsr      gtext
rs_rnix:
;wieder linksbuendig, Zeichenzellenoberkante
 move.l   #$00000005,vintin        ; linksbuendig, Zeichenzellenoberkante
 move.l   #$27000002,d0            ; vst_alignment
 bsr      vdi_quick
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* PUREC void fs_effct( d0 = WORD texteffects )
*
* Text-Ausgabe fuer die Dateiauswahl.
*

fs_effct:
 bra      vst_effects


**********************************************************************
*
* PUREC void fs_txt( a0 = char *text, a1 = GRECT *rahmen )
*
* Text-Ausgabe fuer die Dateiauswahl.
*

fs_txt:
 move.l   a2,-(sp)
 movem.l  a0/a1,-(sp)
 moveq    #REPLACE,d0
 bsr      set_wmode
 lea      finfo_big,a0
 bsr      _setfont
 movem.l  (sp)+,a0/a1
 move.l   g_x(a1),vptsin
 bsr      str_to_ints
 beq.b    rs_nix
 bsr      gtext
rs_nix:
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* void draw_text(d0 = char just, d1 = int font, d2 = int wmode,
*                   a0 = GRECT *rahmen, a1 = char *text)
*
* Der Schreibmodus ist schon gesetzt
*

draw_text:
 movem.l  a6/d7/d6/d5,-(sp)
 subq.l   #8,sp
 move.l   a0,a6                    ; GRECT retten
 move.w   d2,d7                    ; d7 = wmode
 move.b   d0,d6                    ; d6 = just
 move.w   d1,d5                    ; d5 = font

 move.l   a1,a0
 jsr      str_to_ints
 beq      dtx_ende

 move.l   xclip,g_x(sp)
 move.l   wclip,g_w(sp)
 move.l   a6,a0
 bsr      set_iclip                ; Clipping-Rechteck einschraenken

 beq      dtx_ende                 ; Clipping-Rechteck ist leer!

 move.w   d5,d0                    ; font
 move.l   a6,a0                    ; g
 move.b   d6,d1                    ; just
 lea      vptsin,a1                ; outg
 moveq    #0,d2                    ; Breite berechnen
 bsr      tjust                    ; setzt den Font und justiert

*
* Im Fall Deckend/Linksbuendig/Zeichen<Objekthoehe muessen wir
* eine weisse Box unterlegen.
*

 cmpi.w   #TRANSPARENT,d7          ; Text transparent ?
 beq.b    dtx_no_ttr               ; ja, keine Sonderbehandlung
 cmpi.b   #TE_LEFT,d6
 bne      dtx_no_ttr
 tst.w    fontmono(a0)             ; Font mono ?
 beq.b    dtx_ttr_prop             ; nein, Sonderbehandlung

* aequidist. Zeichensatz. Box, wenn Zeichensatz zu klein

 move.w   big_hchar,d1
 move.w   big_wchar,d0             ; w/h fuer Resource-Einheit (8*16)
 cmpa.l   #finfo_big,a0
 beq.b    dtx_big2
 moveq    #6,d0
 moveq    #6,d1
dtx_big2:
 cmp.w    fontcharH(a0),d1         ; Zeichensatz zu klein?
 bls.b    dtx_no_ttr               ; nein, keine Box
 cmp.w    g_h(a6),d1               ; urspr. Hoehe wie Objekthoehe ?
 bne.b    dtx_no_ttr               ; nein, keine Box
 move.w   d1,-(sp)                 ; Hoehe: Objekthoehe = eine RSC-Einheit
 mulu     vintin_len,d0
 move.w   d0,-(sp)                 ; Breite = Anzahl Zeichen * Zeichenbreite
 move.w   g_y(a6),-(sp)            ; y: obere Kante des Objekts
 move.w   vptsin+g_x,-(sp)         ; x: Textanfang
 bra.b    dtx_no_chgh

* prop. Zeichensatz. Immer eine Box zeichnen

dtx_ttr_prop:
 move.l   vptsin+g_w,-(sp)
 move.l   vptsin+g_x,-(sp)
 move.w   big_hchar,d1
 move.w   big_wchar,d0             ; w/h fuer Resource-Einheit (8*16)
 cmpa.l   #finfo_big,a0
 beq.b    dtx_big
 moveq    #6,d0
 moveq    #6,d1
dtx_big:
 mulu     vintin_len,d0
 move.w   d0,g_w(sp)               ; Breite nach festem Font richten
 cmp.w    g_h(a6),d1               ; urspr. Hoehe wie Objekthoehe ?
 bne.b    dtx_no_chgh              ; nein, nicht aendern
 move.w   d1,g_h(sp)               ; Hoehe wie Objekthoehe
 move.w   g_y(a6),g_y(sp)          ; y-Pos. wie Objekt
dtx_no_chgh:
 move.l   sp,a0                    ; GRECT *
 moveq    #WHITE,d1
 moveq    #IP_SOLID,d2
 moveq    #REPLACE,d0
 bsr      drawbox                  ; Box malen
 addq.l   #8,sp

*
* Jetzt erst den Text zeichnen
*

dtx_no_ttr:
 bsr      gtext

 lea      (sp),a0
 bsr      set_clip_grect           ; Clipping restaurieren
dtx_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a6/d7/d6/d5
 rts


**********************************************************************
*
* void draw_icon( d0 = int ob_state, d1 = long offset,
*                 a0 = ICONBLK *icn )
*

draw_icon:
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   ib_pdata(a0),a6          ; a6: Daten
 move.l   ib_pmask(a0),a3          ; a3: Maske
 moveq    #1,d7                    ; 1 Plane
 bra      _draw_cicon


**********************************************************************
*
* void draw_cicon( d0 = int ob_state, d1 = long offset,
*                  a0 = CICONBLK *icn )
*

draw_cicon:
 movem.l  d3-d7/a3-a6,-(sp)
 move.l   cib_mainlist(a0),a2
 move.l   ci_col_data(a2),a6
 move.l   ci_col_mask(a2),a3       ; a3: Maske
 btst     #SELECTED_B,d0
 beq.b    dcic_nodark
 move.l   a3,a4                    ; verdunkeln mit Maske
 move.l   ci_sel_data(a2),d2
 beq.b    dcic_nosel1              ; keine Daten, nur verdunkeln
; Spezialdaten fuer sel. Icon
 move.l   ci_sel_mask(a2),a3       ; a3: Maske
 move.l   d2,a6                    ; a6: Daten
dcic_nodark:
 suba.l   a4,a4                    ; a4: keine Verdunklung
dcic_nosel1:
 move.w   ci_num_planes(a2),d7     ; d7: Anzahl Planes


**********************************************************************
*
* void _draw_cicon(d0 = int ob_state, d1 = long offset,
*                  a0 = CICONBLK *icn, a3 = int *mask,
*                  a6 = int *data, d7 = int numplanes)
*
* a5      CICONBLK *
* a6      Icondaten (ggf. fuer selektiertes Icon)
* d7      num_planes
* d6      ob_state
* d5      Flag Hintergrund nicht zeichnen
*
* ab 29.4.95:       (ob_state & SHADOWED) => Spezialfunktionen
*                             & Bit 15    => kursive Schrift
*

GRECTICN  SET  0
GRECTTXT  SET  GRECTICN+g_sizeof
MFDBSRC   SET  GRECTTXT+g_sizeof
MFDBDST   SET  MFDBSRC+fd_sizeof
PTSIN     SET  MFDBDST+fd_sizeof
OFFS      SET  PTSIN+16

_draw_cicon:
 lea      -OFFS(sp),sp
 move.l   a0,a5                    ; icn merken
 move.w   d0,d6                    ; state merken

*
* GRECTs fuer Icon und Text kopieren und Offset berechnen
*

 move.l   sp,a1
 lea      ib_xicon(a5),a2
 move.l   (a2)+,(a1)               ; xicon/yicon
 add.l    d1,(a1)+                 ;  + offset
 move.l   (a2)+,(a1)+              ; wicon/hicon
 add.l    (a2)+,d1                 ; xtext/ytext + offset
 move.l   d1,(a1)+
 tst.w    (a2)                     ; Breite 0 ?
 sne      d5                       ; Default: Texthintergrund zeichnen
                                   ;          aber nur, wenn g_w > 0
 move.l   (a2),(a1)                ; wtext/htext

*
* GRECT des Icons (liegt bei (sp)) => ptsin[]
*

 lea      PTSIN(sp),a0
 clr.l    (a0)+          ; pxyarray[0]: srcx (ganzes Icon, also (0,0))
                         ; pxyarray[1]: srcy
 move.w   ib_wicon(a5),d2
 subq.w   #1,d2
 move.w   d2,(a0)+       ; pxyarray[2]: srcx+w-1 (also w-1)
 move.w   ib_hicon(a5),d1
 subq.w   #1,d1
 move.w   d1,(a0)+       ; pxyarray[3]: srcy+h-1 (also h-1)
 move.l   (sp),(a0)+     ; pxyarray[4]: dstx
                         ; pxyarray[5]: dsty
 move.l   (sp),(a0)
 add.w    d2,(a0)+       ; pxyarray[6]: dstx+w-1
 add.w    d1,(a0)        ; pxyarray[7]: dstx+h-1

*
* allgemeine Eintraege der MFDBs erstellen (ohne fd_addr)
* vcontrl[7,8] setzen
* Hier die Schleife, wenn Raster nicht gewandelt werden konnte
*

dcic_err_col:
 lea      vcontrl+14,a1            ; Zusatzcode contrl[7]
 lea      MFDBSRC(sp),a0
 move.l   a0,(a1)+                 ; contrl[7..8] = MFDB *src
 addq.l   #fd_w,a0
 move.l   ib_wicon(a5),(a0)+       ; fd_w = Breite in Pixeln (Vielf. von 16)
                                   ; fd_h = Hoehe in Pixeln
 move.w   ib_wicon(a5),d1
 lsr.w    #4,d1                    ;         Pixel in WORDs umrechnen
 move.w   d1,(a0)+                 ; fd_wdwidth
 clr.w    (a0)+                    ; fd_stand = FALSE (geraetespezifisch)
 move.w   #1,(a0)                  ; fd_nplanes = 1 (Monochrom)

 lea      MFDBDST(sp),a0
 move.l   a0,(a1)                  ; contrl[9..10] = MFDB *dst
 clr.l    fd_addr(a0)              ; fd_addr = NULL (Ziel: Bildschirm)

*
* Farben bestimmen
*

 moveq    #0,d3
 move.b   ib_char(a5),d3
 move.l   d3,d4
 andi.w   #$f,d3                   ; d3 = Hintergrundfarbe
 lsr.w    #4,d4                    ; d4 = Vordergrundfarbe

**
**
** Fallunterscheidung
**
**

dcic_noback:
 lea      PTSIN(sp),a0
 move.l   a0,vdipb+8
 cmpi.w   #1,d7                    ; Monochrom-Icon ?
 bne      dcic_color

*
* Monochrom-Maske
*

 btst     #SELECTED_B,d0           ; Icon selektiert ?
 beq.b    mcic_normal
 exg      d3,d4                    ; Vorder-/Hintergrundfarbe vertauschen
mcic_normal:
 btst     #WHITEBAK_B,d0
 beq.b    mcic_maske
 tst.w    d3                       ; Hintergrundfarbe weiss ?
 beq.b    mcic_icon                ; ja, bei WHITEBAK weglassen
mcic_maske:
 move.l   a3,MFDBSRC(sp)           ; fd_addr = Maske
 lea      vintin,a2
 move.w   #TRANSPARENT,(a2)+       ; intin[0] = wr_mode
 move.w   d3,(a2)+                 ; colour[0]
 move.w   d4,(a2)                  ; colour[1]
 lea      vcontrl,a1
 move.l   #$79040003,d0            ; copy raster, transparent
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 bsr      __dit                    ; Textmaske

*
* Monochrom-Icon
*

mcic_icon:
* MFDBs vervollstaendigen
 move.l   a6,MFDBSRC(sp)           ; fd_addr = Icondaten (ib_pdata)
* Bitblt
 lea      vintin,a2
 move.w   #TRANSPARENT,(a2)+       ; intin[0] = wr_mode
 move.w   d4,(a2)+                 ; colour[0]
 move.w   d3,(a2)                  ; colour[1]
 lea      vcontrl,a1
 move.l   #$79040003,d0            ; copy raster, transparent
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 bra      dcic_text

*
* Farbicon-Maske
*

dcic_color:
 lea      vintin,a2
 move.w   #TRANSPARENT,(a2)+       ; intin[0] = wr_mode
 move.w   d3,(a2)+                 ; colour[0]
 move.w   d4,(a2)                  ; colour[1]
 btst     #SELECTED_B,d0           ; Icon selektiert ?
 beq.b    dcic_normal
 exg      d3,d4                    ; Vorder-/Hintergrundfarbe vertauschen
dcic_normal:
 btst     #WHITEBAK_B,d0
 beq.b    dcic_nowhb
 tst.w    d3                       ; Hintergrundfarbe fuer Text weiss ?
 bne.b    dcic_dotxt               ; nein, zeichnen
 sf       d5                       ; ja, nicht zeichnen
dcic_dotxt:
 tst.w    vintin+2                 ; Hintergrundfarbe weiss ?
 beq.b    dcic_replace             ; ja, bei WHITEBAK weglassen
dcic_nowhb:
 move.l   a3,MFDBSRC(sp)           ; fd_addr = Maske
* Bitblt
 lea      vcontrl,a1
 move.l   #$79040003,d0            ; copy raster, transparent
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2

 bsr      __dit

*
* Farbicon
*

; Maske: Modus je nach Bildschirmorganisation
 move.w   #S_OR_D,vintin
 cmpi.w   #8,nplanes               ; LUT oder direct colour ?
 bls.b    dcic_icon                ; LUT, ORen
 move.w   #S_AND_D,vintin          ; direct, ANDen
 bra.b    dcic_icon
; keine Maske: Modus REPLACE (D=S)
dcic_replace:
 bsr      __dit
 move.w   #S_ONLY,vintin           ; intin[0] = wr_mode
dcic_icon:
 tst.w    xp_mode
 bmi.b    dcic_dummy               ; brauche nicht zu wandeln

 movem.l  d3/d4/d6/a3-a5,-(sp)     ; d7/a6 gehen kaputt
 move.w   ib_wicon(a5),d0
 lsr.w    #4,d0                    ; Worte pro Zeile
 mulu     ib_hicon(a5),d0          ; zu wandelnde Worte pro Ebene
 move.l   d0,d1
 add.l    d1,d1                    ; Laenge einer Ebene in Bytes
 move.w   d7,d2                    ; Anz. Ebenen des Quellrasters
 move.l   a6,a0                    ; Quelle im Standardformat
 move.l   scrbuf_mfdb+fd_addr,a1   ; Zielraster
 bsr      xp_raster
 movem.l  (sp)+,d3/d4/d6/a3-a5
 tst.w    d0                       ; konnte wandeln ?
 bne.b    dcic_ok                  ; ja
* Fehler beim Wandeln, monochrom zeigen, Pointer loeschen!!!
 clr.l    cib_mainlist(a5)         ; fuers naechste Mal!
 move.l   ib_pdata(a5),a6          ; a6: Daten
 move.l   ib_pmask(a5),a3          ; a3: Maske
 moveq    #1,d7                    ; 1 Plane
 move.w   d6,d0                    ; ob_state restaurieren
 bra      dcic_err_col

* MFDBs vervollstaendigen
dcic_dummy:
 move.l   a6,MFDBSRC(sp)                     ; fd_addr = Icondaten (original)
 bra.b    dcic_both_ok
dcic_ok:
 move.l   scrbuf_mfdb+fd_addr,MFDBSRC(sp)    ; fd_addr = Icondaten (gewandelt)
dcic_both_ok:
 move.w   nplanes,MFDBSRC+fd_nplanes(sp)     ; akt. Aufloesung
* Bitblt
 lea      vcontrl,a1
 move.l   #$6d040001,d0            ; copy raster, opaque
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2

*
* Verdunklung
*

 move.l   a4,d0                    ; Verdunklung ?
 beq.b    dcic_text                ; nein
* Maske grau machen
 move.l   scrbuf_mfdb+fd_addr,a1   ; Zielraster
 move.w   MFDBSRC+fd_h(sp),d0           ; d0 = Anzahl Zeilen
 move.w   MFDBSRC+fd_wdwidth(sp),d2     ; d2 = Anzahl Worte pro Zeile
 subq.w   #1,d2                         ; fuer dbra
 ble.b    dcic_text                     ; Fehler ??
 move.w   #$5555,d7                     ; d7 = Maskierung
 bra.b    dcic_nxtline
dcic_lineloop:
 move.w   d2,d1                         ; d1 = Anzahl Worte pro Zeile
dcic_wloop:
 move.w   (a4)+,(a1)                    ; Wort holen
 and.w    d7,(a1)+                      ; und maskieren
 dbra     d1,dcic_wloop
 ror.w    #1,d7                         ; Maske rotieren
dcic_nxtline:
 dbra     d0,dcic_lineloop
 move.w   #1,MFDBSRC+fd_nplanes(sp)
 move.l   scrbuf_mfdb+fd_addr,MFDBSRC+fd_addr(sp)
* Bitblt
 lea      vintin,a2
 move.w   #TRANSPARENT,(a2)+       ; intin[0] = wr_mode
 move.w   #BLACK,(a2)+             ; colour[0]
 clr.w    (a2)                     ; colour[1] (WHITE)
 lea      vcontrl,a1
 move.l   #$79040003,d0            ; copy raster, transparent
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2

*
* Text und Zeichen
*

* Texthintergrund ausgeben
dcic_text:
 move.l   #vptsin,vdipb+8
* Textattribute
 move.w   d4,d1                    ; color: Vordergrundfarbe
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor
* Zeichen ausgeben
 moveq    #0,d0
 move.b   ib_char+1(a5),d0         ; Zeichen ?
 beq.b    dcic_nochar              ; nein
 move.w   d0,txvintin
 move.w   #1,vintin_len

 moveq    #SMALL,d0                ; kleiner Font
 bsr      setfont

 move.l   (sp),d0                  ;   (x,y)
 add.l    ib_xchar(a5),d0          ; + (ib_xchar,ib_ychar)
 move.l   d0,vptsin
 bsr      gtext

* Beschriftung ausgeben
dcic_nochar:
 btst     #SHADOWED_B,d6           ; MagiC- Spezialeffekte ?
 beq.b    dcic_no_spec             ; nein
 btst     #15,d6                   ; Texteffekte ?
 beq.b    dcic_no_spec             ; nein

; Text mit Texteffekten
 move.w   d6,d0
 lsr.w    #8,d0
 andi.w   #15,d0                   ; Bits 8/9/10/11 => Texteffekte
 bsr      vst_effects
 move.l   ib_ptext(a5),a1          ; String
 lea      GRECTTXT(sp),a0          ; gtxt
 moveq    #TRANSPARENT,d2
 moveq    #SMALL,d1                ; kleine Zeichen
 moveq    #2,d0                    ; zentriert
 bsr      draw_text
 moveq    #0,d0
 bsr      vst_effects              ; Texteffekte wieder aus
 bra.b    dcic_no_txt

dcic_no_spec:
 move.l   ib_ptext(a5),a1          ; String
 lea      GRECTTXT(sp),a0          ; gtxt
 moveq    #TRANSPARENT,d2
 moveq    #SMALL,d1                ; kleine Zeichen
 moveq    #2,d0                    ; zentriert
 bsr      draw_text
dcic_no_txt:
 lea      OFFS(sp),sp
 movem.l  (sp)+,d3-d7/a3-a6
 rts


**********************************************************************
*
* (Teil von draw_icon)
*

__dit:
 tst.b    d5
 beq.b    __dit_no                 ; WHITEBAK: Kein Hintergrund
 move.l   #vptsin,vdipb+8
 lea      GRECTTXT+4(sp),a0        ; GRECT:   gtxt
 moveq    #7,d2                    ; Pattern: IP_SOLID
 move.w   d3,d1                    ; color:   Hintergrundfarbe
 moveq    #REPLACE,d0
 bsr      drawbox                  ; Box fuer den Text ausgeben
 lea      PTSIN+4(sp),a0
 move.l   a0,vdipb+8
__dit_no:
 rts


**********************************************************************
*
* WORD EQ/NE set_iclip( a0 = GRECT *new_g )
*
* Schraenkt den bereits eingestellten Clipping-Bereich weiter ein.
*

set_iclip:
 move.l   wclip,-(sp)
 move.l   xclip,-(sp)
 tst.l    4(sp)                    ; Clipping ein?
 beq.b    sicl_set                 ; nein, einfach neues GRECT setzen
 move.l   sp,a1
;move.l   a0,a0
 bsr      grects_intersect
 beq.b    sicl_nix                 ; Schnitt ist bereits leer
 move.l   sp,a0
sicl_set:
 bsr.b    set_clip_grect
 moveq    #1,d0                    ; Schnitt nicht leer
sicl_nix:
 addq.l   #8,sp
 rts
 

**********************************************************************
*
* void set_full_clip( void )
*
* aendert d0/d1/a0/a1
*

set_full_clip:
 lea      full_g,a0


**********************************************************************
*
* PUREC void set_clip_grect( GRECT *g )
*
* void set_clip_grect(a0 = GRECT *g)
*

set_clip_grect:
 move.l   (a0),xclip               ; x,y
 move.l   g_w(a0),wclip            ; w,h
 lea      vptsin,a1
 bne.b    scg_normal
; undokumentierte Eigenschaft: Clipping aus
 lea      full_g,a0                ; stattdessen volles Rechteck nehmen
scg_normal:
 move.l   (a0),(a1)+               ; x,y
 move.l   (a0)+,(a1)               ; x,y
 move.w   (a0)+,d0
 subq.w   #1,d0
 add.w    d0,(a1)+                 ; x+w-1
 move.w   (a0)+,d0
 subq.w   #1,d0
 add.w    d0,(a1)+                 ; y+h-1
 move.w   #1,vintin
 move.l   #$81020001,d0            ; vs_clip (set clipping rectangle)
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 rts

get_clip_grect:
 move.l   xclip,(a0)+              ; x,y
 move.l   wclip,(a0)               ; w,h
 rts


**********************************************************************
*
* int in_clip (a0 = GRECT *g)
*
* sieht nach, ob <g> im sichtbaren Bereich liegt.
*

in_clip:
 lea      hclip,a1
 move.w   (a1),d2                  ; d2 = hclip
;beq.b    incl_ret1                ; Clipping ist nicht mehr leer
 move.w   -(a1),d1                 ; d1 = wclip
;beq.b    incl_ret1
 subq.l   #4,a1                    ; a1 = &xclip

 move.w   (a0)+,d0
 add.w    (a1)+,d1
 cmp.w    d1,d0
 bge.b    incl_ret0
 move.w   (a0)+,d1
 add.w    (a1),d2
 cmp.w    d2,d1
 bge.b    incl_ret0

 subq.l   #2,a1
 add.w    (a0)+,d0
 cmp.w    (a1)+,d0
 blt.b    incl_ret0
 add.w    (a0)+,d1
 cmp.w    (a1),d1
 blt.b    incl_ret0
incl_ret1:
 moveq    #1,d0
 rts
incl_ret0:
 moveq    #0,d0
 rts


**********************************************************************
*
* draw_line(int x1, int y1, int x2, int y2)
*

draw_line:
 jsr      mouse_off
 lea      4(sp),a0
 moveq    #2,d0
 bsr      v_pline                  ; eine Linie
 jmp      mouse_on


**********************************************************************
*
* void strplc_pcolor(d1 = int pcolor)
*
* Setzt Polylinefarbe auf <d1> und Modus REPLACE
*

strplc_pcolor:
 moveq    #REPLACE,d0

**********************************************************************
*
* void stwmod_pcolor(d0 = int wmode, d1 = int pcolor)
*
* Setzt Schreibmodus und Polylinefarbe
*

stwmod_pcolor:

     IFNE NVDI

 move.l   nvdi_workstn,d2
 beq.b    swpc_no_nvdi
 move.l   d2,a0
 subq.w   #1,d0
 move.w   d0,NVDI_wr_mode(a0)
 cmp.w    NVDI_colors(a0),d1       ; Farbe im zulaessigen Bereich ?
 bls.b    swpc_nvdi_ok             ; ja
 moveq    #1,d1                    ; nein, setze Schwarz
swpc_nvdi_ok:
 move.w   d1,NVDI_l_color(a0)
 rts
swpc_no_nvdi:

     ENDIF

 lea      curr_pcolor,a0
 cmp.w    (a0),d1                  ; Polylinefarbe geaendert ?
 beq.b    set_wmode
 move.w   d0,-(sp)                 ; d0 retten
 move.w   d1,(a0)
 move.w   d1,vintin
 lea      vcontrl,a1
 move.l   #$11000001,d0            ; vsl_color
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 move.w   (sp)+,d0                 ; d0 holen
 bra.b    set_wmode


**********************************************************************
*
* void stwmod_tcolor(d0 = int wmode, d1 = int tcolor)
*
* Setzt Schreibmodus und Textfarbe
*

stwmod_tcolor:

     IFNE NVDI

 move.l   nvdi_workstn,d2
 beq.b    swtc_no_nvdi
 move.l   d2,a0
 subq.w   #1,d0
 move.w   d0,NVDI_wr_mode(a0)
 cmp.w    NVDI_colors(a0),d1       ; Farbe im zulaessigen Bereich ?
 bls.b    swtc_nvdi_ok             ; ja
 moveq    #1,d1                    ; nein, setze Schwarz
swtc_nvdi_ok:
 move.w   d1,NVDI_t_color(a0)
 rts
swtc_no_nvdi:

     ENDIF

 lea      curr_tcolor,a0
 cmp.w    (a0),d1                  ; Textfarbe geaendert ?
 beq.b    set_wmode
 move.w   d0,-(sp)                 ; d0 retten
 move.w   d1,(a0)
 move.w   d1,vintin
 lea      vcontrl,a1
 move.l   #$16000001,d0            ; vst_color
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 move.w   (sp)+,d0                 ; d0 holen


**********************************************************************
*
* void set_wmode(d0 = int mode)
*
* darf unter NVDI nicht aufgerufen werden
*

set_wmode:
 lea      curr_wmode,a0
 cmp.w    (a0),d0                  ; Schreibmodus geaendert ?
 beq.b    swp_nomode               ; nein, kein VDI- Aufruf
 move.w   d0,(a0)
 move.w   d0,vintin
 lea      vcontrl,a1
 move.l   #$20000001,d0            ; vswr_mode
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
swp_nomode:
 rts


**********************************************************************
*
* void zeichne_3drahmen(a0 = GRECT *g, d0 = int width,
*                       d1 = int sel_shad)
*
* <width> kann auch negativ sein, ist aber immer ungleich 0
* Die Maus ist bereits von _objc_draw() bzw. _objc_change()
* ausgeschaltet worden.
*
* width < 0 (aussen): male im Abstand -1,-2,-3,...,-width
* width > 0 (innen): male im Abstand  0, 1, 2,...,width-1
*
* Ist der Rahmen breiter als 1, wird ein schwarzer Rand gezeichnet.
*

zeichne_3drahmen:
 movem.l  a5/d7/d6/d4,-(sp)
 move.l   a0,a5                    ; grect
 move.w   d1,d4                    ; selected/shadowed
 move.l   4(a5),-(sp)
 move.l   (a5),-(sp)               ; grect fuer 3D-Schatten
 move.w   d0,d7
 move.w   d7,d6
 bgt.b    z3dr_n3d1
; Rahmen aussen
 addq.w   #1,d0
 beq.b    z3dr_3d
 exg      d6,d0
 bra.b    _obdrw_n3d2
z3dr_n3d1:
; Rahmen innen
 subq.w   #1,d0
 beq.b    z3dr_3d
 addq.w   #1,g_x(sp)
 addq.w   #1,g_y(sp)
 subq.w   #2,g_w(sp)
 subq.w   #2,g_h(sp)
 subq.w   #1,d6
 moveq    #0,d0
_obdrw_n3d2:
 move.l   4(a5),-(sp)
 move.l   (a5),-(sp)
 move.l   sp,a0

 add.w    d0,(a0)+                 ; g.g_x += offs
 add.w    d0,(a0)+                 ; g.g_y += offs
 add.w    d0,d0
 sub.w    d0,(a0)+                 ; g.g_w -= 2*offs
 sub.w    d0,(a0)                  ; g.g_h -= 2*offs
 moveq    #1,d0
 move.l   sp,a0
 bsr      zeichne_rahmen           ; (schwarzer) Rahmen, 1 Pixel
 addq.l   #8,sp
z3dr_3d:

 move.l   sp,a0
 move.w   d6,d0
 move.w   d4,d1
 bsr      zeichne_3d
 addq.l   #8,sp

 btst     #SHADOWED_B,d4

 bra      z3dr_ende

/* beq.b    z3dr_ende */
 moveq    #BLACK,d1
 bsr      strplc_pcolor
 move.l   4(a5),-(sp)
 move.l   (a5),-(sp)               ; grect fuer 3D-Schatten
 tst.w    d7                       ; Rahmen innen ?
 bge.b    z3dr_ni3d                ; ja, ignorieren
 add.w    d7,g_x(sp)
 addq.w   #1,g_x(sp)
 add.w    d7,g_y(sp)
 addq.w   #1,g_y(sp)
 sub.w    d7,g_w(sp)
 sub.w    d7,g_w(sp)
 sub.w    d7,g_h(sp)
 sub.w    d7,g_h(sp)
z3dr_ni3d:
 lea      (sp),a0
 moveq    #1,d0                    ; Rahmendicke
 bsr      zeichne_3d_ru
 addq.l   #8,sp
z3dr_ende:
 movem.l  (sp)+,a5/d7/d6/d4
 rts


**********************************************************************
*
* void zeichne_3d(a0 = GRECT *g, d0 = int width, d1 = int sel)
*
* <width> kann auch negativ sein, ist aber immer ungleich 0
* Die Maus ist bereits von _objc_draw() bzw. _objc_change()
* ausgeschaltet worden.
*
* width < 0 (aussen): male im Abstand -1,-2,-3,...,-width
* width > 0 (innen): male im Abstand  0, 1, 2,...,width-1
*
* Zeichnet nur den 3D-Effekt
*

zeichne_3d:
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 move.w   d1,-(sp)
; hellgraue Striche
 lea      vptsin,a1
 move.w   (a0)+,d1                 ; x
 move.w   (a0)+,d2                 ; y
 add.w    (a0),d1                  ; x+w
 tst.w    d0
 bgt.b    z3d_l1
; width < 0
 move.w   d1,(a1)+
 subq.w   #1,d2
 move.w   d2,(a1)+
 subq.w   #1,d1
 addq.w   #1,d2
 bra.b    z3d_ld
; width > 0
z3d_l1:
 subq.w   #1,d1                    ; x+w-1
 move.w   d1,(a1)+
 move.w   d2,(a1)+                 ; y
 addq.w   #1,d1                    ; x+w-d
 subq.w   #1,d2
z3d_ld:
 sub.w    d0,d1
 move.w   d1,(a1)+
 add.w    d0,d2
 move.w   d2,(a1)+                 ; y+d
 move.w   (a0)+,d1                 ; w
 sub.w    d0,d1                    ; w + abs(width)
 move.w   (a0),d2                  ; h
 sub.w    d0,d2                    ; h + abs(width)
 move.l   -8(a1),(a1)
 move.l   -4(a1),4(a1)             ; 2 Punkte kopieren
 sub.w    d1,(a1)+
 add.w    d2,(a1)+
 sub.w    d1,(a1)+
 add.w    d2,(a1)                  ; und um Offset verschieben
 moveq    #LWHITE,d1               ; hellgrau
 bsr      strplc_pcolor
 lea      vptsin,a0
 moveq    #2,d0                    ; 2 Paare
 bsr      v_pline
 lea      vptsin+8,a0
 moveq    #2,d0                    ; nochmal 2 Paare
 bsr      v_pline
; Farben bestimmen je nach Selektion
 move.w   (sp)+,d2                 ; sel
 moveq    #WHITE,d1
 move.w   #LBLACK,-(sp)
 btst     #SELECTED_B,d2
 bne.b    z3d_ns3d
 move.w   d1,(sp)
 moveq    #LBLACK,d1
z3d_ns3d:
; Linien rechts und unten
 bsr      strplc_pcolor
 move.l   4(sp),a0
 move.w   2(sp),d0                 ; Rahmendicke
 bsr      zeichne_3d_ru
; Linien links und oben
 move.w   (sp)+,d1
 bsr      strplc_pcolor
 move.w   (sp)+,d0
 move.l   (sp)+,a0
;bra      zeichne_3d_lo


**********************************************************************
*
* void zeichne_3d_lo(a0 = GRECT *g, d0 = int width)
*
* Teil links oben.
*
* <width> kann auch negativ sein, ist aber immer ungleich 0
* Die Maus ist bereits von _objc_draw() bzw. _objc_change()
* ausgeschaltet worden.
*
* width < 0 (aussen): male im Abstand -1,-2,-3,...,-width
* width > 0 (innen): male im Abstand  0, 1, 2,...,width-1
*

zeichne_3d_lo:
 movem.l  a5/d7,-(sp)
;move.l   a0,a0                    ; GRECT
 move.w   d0,d7
 lea      vptsin,a5                ; a5 = vptsin
 move.l   a5,a1
 move.w   (a0)+,d0                 ; x
 move.w   d0,(a1)+                 ;              x1 = x
 move.w   (a0),d1                  ; y
 add.w    4(a0),d1                 ; y+h
 subq.w   #2,d1
 move.w   d1,(a1)+                 ;              y1 = y+h-2
 move.w   d0,(a1)+                 ;              x2 = x
 move.w   (a0)+,d1
 move.w   d1,(a1)+                 ;              y2 = y
 add.w    (a0)+,d0                 ; x+w
 subq.w   #2,d0
 move.w   d0,(a1)+                 ;              x3 = x+w-2
 move.w   d1,(a1)                  ;              y3 = y

 lea      vcontrl,a1
 move.l   #$06030000,d1            ; v_pline, 3 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1                ; ab hier darf sich d1 nicht mehr aendern

 tst.w    d7
 bgt.b    z3dlo_innen              ; Rand innen

* 1. Fall:
* Rand < 0, also aussen

z3dlo_aloop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 subq.w   #1,(a1)+                 ; x1 -= 1
 addq.w   #1,(a1)+                 ; y1 += 1
 subq.w   #1,(a1)+                 ; x2 -= 1
 subq.w   #1,(a1)+                 ; y2 -= 1
 addq.w   #1,(a1)+                 ; x3 += 1
 subq.w   #1,(a1)                  ; y3 -= 1

 moveq    #$73,d0
 trap     #2

 addq.w   #1,d7
 bne.b    z3dlo_aloop
 movem.l  (sp)+,a5/d7
 rts

* 2. Fall:
* Rand > 0, also innen

z3dlo_iloop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 addq.w   #1,(a1)+                 ; x1 += 1
 subq.w   #1,(a1)+                 ; y1 -= 1
 addq.w   #1,(a1)+                 ; x2 += 1
 addq.w   #1,(a1)+                 ; y2 += 1
 subq.w   #1,(a1)+                 ; x3 -= 1
 addq.w   #1,(a1)+                 ; y3 += 1

z3dlo_innen:
 moveq    #$73,d0
 trap     #2

 subq.w   #1,d7
 bne.b    z3dlo_iloop
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* void zeichne_3d_ru(a0 = GRECT *g, d0 = int width)
*
* Teil rechts unten.
*
* <width> kann auch negativ sein, ist aber immer ungleich 0
* Die Maus ist bereits von _objc_draw() bzw. _objc_change()
* ausgeschaltet worden.
*
* width < 0 (aussen): male im Abstand -1,-2,-3,...,-width
* width > 0 (innen): male im Abstand  0, 1, 2,...,width-1
*

zeichne_3d_ru:
 movem.l  a5/d7,-(sp)
;move.l   a0,a0                    ; GRECT
 move.w   d0,d7
 lea      vptsin,a5                ; a5 = vptsin
 move.l   a5,a1
 move.w   (a0)+,d0                 ; x
 move.w   d0,(a1)
 addq.w   #1,d0
 move.w   d0,(a1)+                 ;              x1 = x+1
 move.w   (a0),d1                  ; y
 addq.w   #1,d1                    ; y+1
 move.w   d1,8(a1)                 ;              y3 = y+1
 add.w    4(a0),d1                 ; y+h
 subq.w   #2,d1
 move.w   d1,(a1)+                 ;              y1 = y+h-1
 add.w    2(a0),d0                 ; x+w+1
 subq.w   #2,d0
 move.w   d0,(a1)+                 ;              x2 = x+w-1
 move.w   d1,(a1)+                 ;              y2 = y+h-1
 move.w   d0,(a1)                  ;              x3 = x+w-1

 lea      vcontrl,a1
 move.l   #$06030000,d1            ; v_pline, 3 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1                ; ab hier darf sich d1 nicht mehr aendern

 tst.w    d7
 bgt.b    z3dru_innen              ; Rand innen

* 1. Fall:
* Rand < 0, also aussen

z3dru_aloop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 subq.w   #1,(a1)+                 ; x1 -= 1
 addq.w   #1,(a1)+                 ; y1 += 1
 addq.w   #1,(a1)+                 ; x2 += 1
 addq.w   #1,(a1)+                 ; y2 += 1
 addq.w   #1,(a1)+                 ; x3 += 1
 subq.w   #1,(a1)                  ; y3 -= 1

 moveq    #$73,d0
 trap     #2

 addq.w   #1,d7
 bne.b    z3dru_aloop
 movem.l  (sp)+,a5/d7
 rts

* 2. Fall:
* Rand > 0, also innen

z3dru_iloop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 addq.w   #1,(a1)+                 ; x1 += 1
 subq.w   #1,(a1)+                 ; y1 -= 1
 subq.w   #1,(a1)+                 ; x2 -= 1
 subq.w   #1,(a1)+                 ; y2 -= 1
 subq.w   #1,(a1)+                 ; x3 -= 1
 addq.w   #1,(a1)+                 ; y3 += 1

z3dru_innen:
 moveq    #$73,d0
 trap     #2

 subq.w   #1,d7
 bne.b    z3dru_iloop
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* void grect_to_ptsin(a0 = GRECT *g)
*

grect_to_ptsin:
 move.l   (a0)+,d0                 ; d0 = x,y
 move.w   (a0)+,d1
 subq.w   #1,d1                    ; d1 = w-1
 move.w   (a0)+,d2
 subq.w   #1,d2                    ; d2 = h-1
 lea      vptsin,a1
* ptsin[0,1] = linke obere Ecke
 move.l   d0,(a1)+                 ; ptsin[0] = x, ptsin[1] = y
* ptsin[2,3] = rechte obere Ecke
 move.l   d0,(a1)                  ; ptsin[2] = x, ptsin[3] = y
 add.w    d1,(a1)                  ; ptsin[2] = x+(w-1)
* ptsin[4,5] = rechte untere Ecke
 move.l   (a1)+,(a1)+              ; ptsin[4] = x+(w-1)
                                   ; ptsin[5] = y
* ptsin[6,7] = linke untere Ecke
 move.l   d0,(a1)                  ; ptsin[6] = x, ptsin[7] = y
 add.w    d2,-(a1)                 ; ptsin[5] = y+(h-1)
 move.l   (a1)+,(a1)+              ; ptsin[7] = y+(h-1)
* ptsin[8,9] = linke obere Ecke
                                   ; ptsin[8] = x
 move.w   d0,(a1)                  ; ptsin[9] = y
 rts


**********************************************************************
*
* void zeichne_rahmen(a0 = GRECT *g, d0 = int width)
*
* <width> kann auch negativ sein, ist aber immer ungleich 0
* Die Maus ist bereits von _objc_draw() bzw. _objc_change()
* ausgeschaltet worden.
*
* width < 0 (aussen): male im Abstand -1,-2,-3,...,-width
* width > 0 (innen): male im Abstand  0, 1, 2,...,width-1
*

zeichne_rahmen:
 movem.l  a5/d7,-(sp)
;move.l   a0,a0                    ; GRECT
 move.w   d0,d7                    ; weil VDI manchmal d2 zerstoert #^#
 bsr.b    grect_to_ptsin

 lea      vcontrl,a1
 move.l   #$06050000,d1            ; v_pline, 5 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1                ; ab hier darf sich d1 nicht mehr aendern

 lea      vptsin,a5                ; a5 = vptsin
 tst.w    d7
 bgt.b    zr_innen                 ; Rand innen

* 1. Fall:
* Rand < 0, also aussen

zra_loop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 subq.w   #1,(a1)+                 ; x1 -= 1
 subq.w   #1,(a1)+                 ; y1 -= 1
 addq.w   #1,(a1)+                 ; x2 += 1
 subq.w   #1,(a1)+                 ; y2 -= 1
 addq.w   #1,(a1)+                 ; x3 += 1
 addq.w   #1,(a1)+                 ; y3 += 1
 subq.w   #1,(a1)+                 ; x4 -= 1
 addq.w   #1,(a1)+                 ; y4 += 1
 subq.w   #1,(a1)+                 ; x5 = x1
 subq.w   #1,(a1)                  ; y5 = x1

 moveq    #$73,d0
 trap     #2

 addq.w   #1,d7
 bne.b    zra_loop
 movem.l  (sp)+,a5/d7
 rts

* 2. Fall:
* Rand > 0, also innen

zri_loop:
 move.l   a5,a1
                                   ; einen Schritt weiter gehen
 addq.w   #1,(a1)+                 ; x1 += 1
 addq.w   #1,(a1)+                 ; y1 += 1
 subq.w   #1,(a1)+                 ; x2 -= 1
 addq.w   #1,(a1)+                 ; y2 += 1
 subq.w   #1,(a1)+                 ; x3 -= 1
 subq.w   #1,(a1)+                 ; y3 -= 1
 addq.w   #1,(a1)+                 ; x4 += 1
 subq.w   #1,(a1)+                 ; y4 -= 1
 addq.w   #1,(a1)+                 ; x5 = x1
 addq.w   #1,(a1)                  ; y5 = x1

zr_innen:
 moveq    #$73,d0
 trap     #2

 subq.w   #1,d7
 bne.b    zri_loop
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* void bitblk_to_mfdb(a0 = MFDB *mfdb, a1 = int *data,
*                     d0 = int wb, d1 = int hl)
*
* data: Zeiger auf Bitmusterdaten
* wb:   Breite des Bilds in Bytes
* hl:   Hoehe des Bild in Pixeln
*
* Ist <data> == NULL, werden <wb> und <hl> ignoriert und der MFDB
* des Bildschirms eingesetzt
*
* aendert nicht a2
*

bitblk_to_mfdb:
 move.l   a1,(a0)+                 ; mfdb->fd_addr = data
 bne.b    mtmf_l1
* data == NULL: ganzen Bildschirm einsetzen
 lea      work_out,a1
 move.w   (a1)+,d0
 addq.w   #1,d0                    ; Bildschirmbreite in Pixeln
 move.w   d0,(a0)+                 ; mfdb->fd_w = Pixel/Bildschirm horizontal
 move.w   (a1)+,(a0)
 addq.w   #1,(a0)+                 ; mfdb->fd_h = Pixel/Bildschirm vertikal
 lsr.w    #4,d0                    ; /16 wegen Worte / Bildschirmzeile
 move.w   d0,(a0)+                 ; mfdb->fd_wdwidth
 clr.w    (a0)+                    ; geraeteabhaengiges Format
 move.w   nplanes,(a0)             ; mfdb->fd_nplanes = nplanes
 rts
* data != NULL
mtmf_l1:
;                                  ; wb (Breite in Bytes)
 lsl.w    #3,d0                    ; *8
 move.w   d0,(a0)+                 ; ergibt Breite in Pixeln
 move.w   d1,(a0)+                 ; hl (Hoehe in Pixeln)
 lsr.w    #4,d0                    ; Breite in Pixeln / 16
 move.w   d0,(a0)+                 ; ergibt Breite in Words
 clr.w    (a0)+                    ; geraetespezifisches Format
 move.w   #1,(a0)                  ; eine Ebene !
 rts


**********************************************************************
*
* void draw_bitblk(int *srcdata, int srcx, int srcy, int srcwb,
*                  int *dstdata, int dstx, int dsty, int dstwb,
*                  int w, int h, int mode, int color0, int color1)
*
* srcdata:     Zeiger auf Bitmusterdaten fuer Quelle
* srcx,srcy:   Position des Quell- BITBLKs
* srcwb:       Breite des Quell- BITBLKs in Bytes
*
* dstdata:     Daten des Ziel- BITBLKs
* dstx,dsty:   Position des Ziel- BITBLKs
* dstwb:       Breite des Ziel- BITBLKs in Bytes
*
* w,h:         Breite/Hoehe des zu kopierenden BITBLKs in Pixeln
* mode:        Schreib- (bei transparent) bzw. Verknuepfungsmodus (bei opaque)
* color0:      Farbe der gesetzten Punkte (-1: opaque, sonst transparent)
* color1:      Farbe der nicht gesetzten Punkte
*

draw_bitblk:
 movem.l  d3/d4/a3/a4/a5,-(sp)
 lea      $18(sp),a3               ; Anfang der Parameterliste
 lea      mfdb1,a4                 ; MFDB fuer Quelle
 lea      mfdb2,a5                 ; MFDB fuer Ziel
 move.w   $16(a3),d3               ; h (Breite in Pixeln)
* MFDB fuer Quelle erstellen, d4 = srcx,srcy
 move.w   d3,d1                    ; h
 movea.l  (a3)+,a1                 ; a0 = srcdata
 move.l   (a3)+,d4                 ; d4 = x,y
 move.w   (a3)+,d0                 ; srcwb        (Breite in Bytes)
;lea      (a1),a1                  ; srcdata
 lea      (a4),a0                  ; MFDB
 bsr.b    bitblk_to_mfdb
* Maus ausschalten
 jsr      mouse_off
* MFDB fuer Ziel erstellen, d3 = dstx,dsty
 move.w   d3,d1                    ; h
 movea.l  (a3)+,a1
 move.l   (a3)+,d3                 ; dstx,dsty
 move.w   (a3)+,d0                 ; dstwb
;lea      (a1),a1                  ; dstdata
 lea      (a5),a0                  ; MFDB
 bsr.b    bitblk_to_mfdb

 lea      vptsin,a0
 move.w   (a3)+,d0
 subq.w   #1,d0                    ; w-1
 move.w   (a3)+,d1
 subq.w   #1,d1                    ; h-1
 move.l   d4,(a0)+       ; pxyarray[0]: srcx
                         ; pxyarray[1]: srcy
 move.l   d4,(a0)
 add.w    d0,(a0)+       ; pxyarray[2]: scrx+w-1
 add.w    d1,(a0)+       ; pxyarray[3]: scry+h-1
 move.l   d3,(a0)+       ; pxyarray[4]: dstx
                         ; pxyarray[5]: dsty
 move.l   d3,(a0)
 add.w    d0,(a0)+       ; pxyarray[6]: dstx+w-1
 add.w    d1,(a0)        ; pxyarray[7]: dstx+h-1

 move.w   (a3)+,d0       ; d0 ist mode (wird von vro/t_cpyfm gesetzt
 move.l   (a3),-(sp)     ; color0 und color1
 pea      (a5)           ; pdstMFDB
 pea      (a4)           ; psrcMFDB
 cmpi.w   #$ffff,(a3)
 beq.b    dbtb_l1
* color0 != -1: Transparenter BITBLIT
 bsr      vrt_cpyfm
 bra.b    dbtb_l2
* color0 == -1: Undurchsichtiger BITBLIT
dbtb_l1:
 bsr      vro_cpyfm
* Maus wieder einschalten
dbtb_l2:
 jsr      mouse_on
 lea      12(sp),sp
 movem.l  (sp)+,a5/a4/a3/d4/d3
 rts


**********************************************************************
*
* void cdecl blitcopy_rectangle(int src_x, int src_y,
*                         int dst_x, int dst_y, int w, int h)
*
* void blitcopy_rectangle(int src_x, int src_y,
*                         int dst_x, int dst_y, int w, int h)
*

blitcopy_rectangle:
 lea      12(sp),a0
 moveq    #-1,d0
 move.l   d0,-(sp)                 ; color0 = color1 = -1 (vro_cpyfm)
 move.w   #3,-(sp)                 ; mode = REPLACE
 move.l   (a0),-(sp)               ; w,h
 clr.w    -(sp)                    ; dstwb = 0 (wird automatisch eingesetzt)
 move.l   -(a0),-(sp)              ; dstx, dsty
 clr.l    -(sp)                    ; dstdata = NULL (Bildschirm)
 clr.w    -(sp)                    ; srcwb = 0 (wird automatisch eingesetzt)
 move.l   -(a0),-(sp)              ; srcx, srcy
 clr.l    -(sp)                    ; srcdata = NULL (Bildschirm)
 bsr      draw_bitblk
 lea      $1e(sp),sp
 rts


**********************************************************************
*
* int calc_quadr( d0 = int height )
*
* Gibt die Breite eines Rechtecks zurueck, das die Hoehe <height>
* hat und auf dem Bildschirm moeglichst quadratisch aussieht.
* aendert nur d0/d1/d2
*

calc_quadr:
 muls     work_out+8,d0            ; * work_out[4] = Hoehe eines Pixels in mm
 move.w   work_out+6,d2            ; work_out[3], Breite eines Pixels in mm
 divs     d2,d0                    ;  / Breite eines Pixels in mm
 move.l   d0,d1
 swap     d1                       ; d1 = Rest (Sonderbehandlung fuer TT)
 add.w    d1,d1
 cmp.w    d2,d1
 bcs.b    cq_nicht_aufrunden
 addq.w   #1,d0                    ; 1/2 wird aufgerundet
cq_nicht_aufrunden:
 rts


**********************************************************************
*
* void init_font( a0 = FINFO *fi )
*

init_font:
 cmpi.w   #1,fontID(a0)            ; Default- Font ?
 bls.b    ifo_standardfont         ; 0 oder 1: Systemfont (default) verwenden
 move.l   a0,-(sp)
 move.l   #$77000000,d0            ; vst_load_fonts(intin[0] = 0)
 bsr      vdi_1
 move.l   (sp)+,a0
 tst.w    vintout
 bne.b    ifo_arefonts             ; zusaetzliche Fonts gefunden
ifo_standardfont:
 move.w   #1,fontID(a0)
 move.w   #1,fontmono(a0)
ifo_arefonts:

     IFEQ FONTPROP

 move.w   #1,fontmono(a0)

     ENDIF

;move.l   a0,a0
 bsr      _setfont
 lea      vptsout+2,a1             ; char_width ist uninteressant
 move.w   (a1)+,fontH(a0)          ; char_height
 move.w   (a1)+,fontcharW(a0)      ; cell_width
 move.w   (a1),fontcharH(a0)       ; cell_height

 move.l   a0,-(sp)
 move.l   #$83000000,d0            ; vqt_fontinfo()
 bsr      vdi_quick
 move.l   (sp)+,a0
 move.w   vptsout+18,d0            ; Abstand Zeichenzellobergrenze/Basislinie
 addq.w   #2,d0
 move.w   d0,fontUpos(a0)          ; Position des Unterstrichs
 rts


**********************************************************************
*
* void init_vdivars( void )
*
* Bestimmt u.a. die Zeichensaetze
*

init_vdivars:
 movem.l  d3/d4/d6/a3/a6,-(sp)
 subq.l   #4,sp                    ; Platz fuer zwei Dummy-WORDs

 moveq    #-1,d0
 move.w   d0,curr_pcolor
 move.w   d0,curr_tcolor
 move.w   d0,curr_fcolor
 move.w   d0,curr_wmode
 move.w   #1,curr_fid              ; Font-ID
 move.l   #finfo_sys,curr_finfo
 move.w   d0,curr_patt
 move.w   d0,curr_style

* Bildschirmbreite, -hoehe und Clipping

 clr.w    xclip
 clr.w    yclip

 lea      work_out,a3
 move.w   (a3)+,d3
 addq.w   #1,d3                    ; d3 := work_out[0] + 1
 move.w   d3,wclip                 ; wclip =
 move.w   d3,scr_w                 ; scr_w = Bildschirmbreite
 move.w   (a3)+,d4
 addq.w   #1,d4                    ; d4 := work_out[1] + 1
 move.w   d4,hclip                 ; hclip =
 move.w   d4,scr_h                 ; scr_h = Bildschirmhoehe

* nplanes bestimmen

 suba.w   #114,sp                  ; Platz fuer 57 ints
 move.l   sp,vdipb+12              ; intout
 lea      90(sp),a0
 move.l   a0,vdipb+16              ; ptsout
 move.l   #$66000001,d0            ; vq_extend, erweiterte Parameter
 bsr      vdi_1
 move.w   8(sp),nplanes            ; work_out[4]
 move.l   #vintout,vdipb+12
 move.l   #vptsout,vdipb+16
 adda.w   #114,sp

/*
 move.w   $16(a3),d0               ; d0 = work_out[13] Anzahl vordef. Farben
 clr.w    d1
ivdi_loop:
 lsr.w    #1,d0
 beq.b    ivdi_loop_cont
 addq.w   #1,d1
 bra.b    ivdi_loop
ivdi_loop_cont:
 move.w   d1,nplanes
*/

* Textbreiten und -hoehen bestimmen

* grosser Systemfont (fuer Pfeile usw. benoetigt):

 move.w   #1,finfo_sys+fontID      ; Systemfont
 move.l   #$26000000,d0            ; aktuelle Zeichenhoehe ermitteln
 bsr      vdi_quick                ; vqt_attributes()
 move.w   vptsout+2,finfo_sys+fontH
 lea      finfo_sys,a0
 bsr      init_font

* grosser Font:

 tst.w    finfo_big+fontH          ; Texthoehe fuer grosse Zeichen festgelegt ?
 bne.b    ivv_setbig               ; ja, verwenden
 move.w   finfo_sys+fontH,finfo_big+fontH
ivv_setbig:
 lea      finfo_big,a0
 bsr      init_font
 cmpi.w   #1,finfo_big+fontID
 sne      d0
 andi.w   #1,d0
 move.w   d0,isfsm_big             ; fuer appl_getinfo(0)

 tst.w    big_wchar                ; Objektgroessen gesetzt ?
 bne.b    ivv_now                  ; ja, uebernehmen
 move.w   finfo_big+fontcharW,big_wchar
ivv_now:
 tst.w    big_hchar                ; Objekthoehe gesetzt ?
 bne.b    ivv_noh                  ; ja, uebernehmen
 move.w   finfo_big+fontcharH,big_hchar
ivv_noh:

* kleiner Font

 tst.w    finfo_sml+fontH
 bne.b    ivv_setsml
 move.w   $58(a3),finfo_sml+fontH  ; geringstmoegliche Zeichenhoehe
ivv_setsml:
 lea      finfo_sml,a0
 bsr      init_font
 cmpi.w   #1,finfo_sml+fontID
 sne      d0
 andi.w   #1,d0
 move.w   d0,isfsm_sml             ; fuer appl_getinfo(1)

* INFO-Zeilen Font

 tst.w    finfo_inw+fontID
 bne.b    ivv_setinw2
 move.w   finfo_big+fontID,finfo_inw+fontID
 move.w   finfo_big+fontmono,finfo_inw+fontmono
ivv_setinw2:
 tst.w    finfo_inw+fontH          ; Texthoehe festgelegt ?
 bne.b    ivv_setinw               ; ja, verwenden
 move.w   finfo_big+fontH,finfo_inw+fontH
ivv_setinw:
 lea      finfo_inw,a0
 bsr      init_font
 
* Fensterrahmendicke

 move.w   big_hchar,d6
 addq.w   #3,d6
 move.w   d6,gr_hhbox              ; gr_hhbox := big_hchar + 3
 move.w   d6,d0
 bsr      calc_quadr
 move.w   d0,gr_hwbox              ;  = Anzahl Pixel fuer gleiche Breite

* Verschiedenes

 move.l   #$0f000007,d0       ; set polyline line type, 7
 bsr      vdi_1               ; vsl_type(USERLINE)

 moveq    #1,d0
 bsr      vsl_width

 move.l   #$7100ffff,d0       ; set user defined linestyle
 bsr      vdi_1               ; vsl_udsty(-1)

 clr.l    full_g              ; x,y = 0, w ist scr_w, h ist scr_h

     IF   MACOS_SUPPORT

 move.l   #'MgMc',-(sp)
 move.w   #4,-(sp)            ; get cookie
 move.l   #'AnKr',-(sp)
 move.w   #39,-(sp)
 trap     #14                 ; Xbios Puntaes
 adda.w   #12,sp
 tst.l    d0
 beq.b    ivv_nomacos
 move.l   d0,a1
 move.l   4(a1),a1
 cmpi.w   #$0116,(a1)         ; Version >= 0x116?
 bcs.b    ivv_nomacos
 move.w   140(a1),d6          ; Menue-Hoehe aus dem MacOS uebernehmen
ivv_nomacos:

     ENDIF

 lea      desk_g,a0
 clr.w    (a0)+               ; x = 0
 move.w   d6,(a0)+            ; y = gr_hhbox
 move.w   d3,(a0)+            ; w = scrw
 move.w   d4,(a0)
 sub.w    d6,(a0)             ; h = scrh-gr_hhbox

 lea      menubar_grect,a0
 clr.l    (a0)+               ; x = y = 0
 move.w   d3,(a0)+            ; w = scrw
 move.w   d6,(a0)             ; h = gr_hhbox

 addq.l   #4,sp
 movem.l  (sp)+,a6/a3/d6/d4/d3
 rts


**********************************************************************
*
* FINFO *setfont( d0 = WORD font )
* FINFO *_setfont( a0 = FINFO *fi )
*
* font ist IBM oder SMALL. Sonst: nicht veraendern
* liefert eine FONTINFO-Struktur
*
* DARF AUF KEINEN FALL txvintin[] veraendern (hier liegen die Zeichen)
*

setfont:
 lea      finfo_big,a0             ; grosser Font
 cmpi.w   #IBM,d0                  ; font == IBM ?
 beq.b    _setfont                 ; ja
 lea      finfo_sml,a0             ; kleiner Font
 cmpi.w   #SMALL,d0
 beq.b    _setfont
 move.l   curr_finfo,a0
 rts
_setfont:
 lea      curr_finfo,a1
 cmpa.l   (a1),a0                  ; aktueller = gewuenschter Font ?
 beq.b    sf_ende                  ; ja
 move.l   a0,(a1)
 move.l   a0,-(sp)                 ; a0 retten

; Font-ID setzen

 move.w   fontID(a0),d1
 cmp.w    curr_fid,d1
 beq.b    sf_sheight
 move.w   d1,curr_fid
 move.l   #$15000000,d0            ; vst_font
 move.w   d1,d0                    ; Font fuer AES (i.a. 1)
 bsr      vdi_1
 move.l   (sp),a0

; Font-Hoehe setzen

sf_sheight:
 moveq    #0,d0                    ; ptsin[0] = 0
 move.w   fontH(a0),d0
 move.l   d0,vptsin
 move.l   #$0c010000,d0            ; vst_height()
 bsr      vdi_quick
 move.l   (sp)+,a0
sf_ende:
 rts


**********************************************************************
*
* WORD gtext( void )
*
* gibt den Text in txvintin[] per v_gtext() aus. Setzt ggf.
* Steuerzeichen ein.
*

gtext:

     IFNE FONTPROP

 tst.b    vintin_dirty             ; Zeichenkette enthaelt Steuerzeichen?
 beq      gt_ok                    ; nein
 move.l   curr_finfo,a0
 tst.w    fontmono(a0)             ; "monospaced"
 bne      gt_ok                    ; ja, einfach ausgeben
 cmpa.l   #finfo_big,a0            ; grosser Zeichensatz?
 bne      gt_ok                    ; nein

 movem.l  a3/a4/a5/a6/d6,-(sp)
 move.l   a0,a4                    ; eigentlichen Zeichensatz merken
 lea      txvintin,a6
 move.l   a6,a3
 add.w    vintin_len,a3
 add.w    vintin_len,a3

; Bestimme Block von Steuerzeichen

gt_loop:
 move.l   a6,a5
gt_loop1:
 cmpa.l   a3,a6
 bcc.b    gt_endl1
 cmpi.w   #' ',(a6)+
 bcs.b    gt_loop1
 subq.l   #2,a6                    ; a6 aufs erste "echte" Zeichen
gt_endl1:
 move.l   a6,d6
 sub.l    a5,d6
 beq.b    gt_nix_steuer            ; keine Steuerzeichen
 lsr.w    #1,d6                    ; WORD -> BYTE

; Gib Block von Steuerzeichen aus

 move.l   vptsin,-(sp)
 lea      finfo_sys,a0
 bsr      _setfont                 ; Systemfont setzen
 move.l   (sp)+,vptsin

 move.l   a5,vdipb+4               ; vintin auf Beginn des Teil-Strings
 move.l   #$08010000,d0            ; v_gtext
 move.b   d6,d0                    ; Laenge von intin setzen
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 move.l   #vintin,vdipb+4          ; vintin restaurieren

 mulu     finfo_sys+fontcharW,d6
 add.w    d6,vptsin                ; x-Koordinate weiterrechnen

; Bestimme Block von "echten" Zeichen

gt_nix_steuer:
 cmpa.l   a3,a6
 bcc.b    gt_ende
 move.l   a6,a5
gt_loop2:
 cmpa.l   a3,a6
 bcc.b    gt_endl2
 cmpi.w   #' ',(a6)+
 bcc.b    gt_loop2
 subq.l   #2,a6                    ; a6 aufs erste Steuerzeichen
gt_endl2:
 move.l   a6,d6
 sub.l    a5,d6
 beq.b    gt_nix_normal            ; keine echten Zeichen
 lsr.w    #1,d6                    ; WORD -> BYTE

; Gib Block von echten Zeichen aus

 move.l   vptsin,-(sp)
 move.l   a4,a0
 bsr      _setfont                 ; grossen Font setzen
 move.l   (sp)+,vptsin

 move.l   a5,vdipb+4               ; vintin auf Beginn des Teil-Strings

 move.l   #$08010000,d0            ; v_gtext
 move.b   d6,d0                    ; Laenge von intin setzen
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 move.l   #vintin,vdipb+4          ; vintin restaurieren

 sf       vintin_dirty
 move.w   d6,d0
 bsr      extent
 add.w    d0,vptsin                ; x-Koordinate weiterrechnen
 st       vintin_dirty

gt_nix_normal:
 cmpa.l   a3,a6
 bcs      gt_loop

gt_ende:
 move.l   a4,a0
 bsr      _setfont                 ; sicherstellen: grossen Font setzen
 movem.l  (sp)+,a3/a4/a5/a6/d6
 rts

gt_ok:

     ENDIF

 move.l   #$08010000,d0            ; v_gtext
 move.b   vintin_len+1,d0          ; Laenge von intin setzen
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 move.l   #txvintin,vdipb+4        ; vintin auf Text setzen
 moveq    #$73,d0
 trap     #2
 move.l   #vintin,vdipb+4          ; vintin restaurieren
 rts


**********************************************************************
*
* PUREC WORD fs_xtnt( a0 = char *s )
*
* Fuer die Dateiauswahl
*

fs_xtnt:
 tst.w    finfo_big+fontmono
 bne.b    fs_x_mono
 move.l   a2,-(sp)
;move.l   a0,a0
 bsr      str_to_ints
 beq.b    fs_x_nix
 lea      finfo_big,a0
 bsr      _setfont
 move.w   vintin_len,d0
 bsr.b    extent
fs_x_nix:
 move.l   (sp)+,a2
 rts
fs_x_mono:
 jsr      strlen
 mulu     finfo_big+fontcharW,d0
 rts


**********************************************************************
*
* WORD extent( d0 = WORD textlen )
*
* Berechnet die Laenge einer Zeichenkette in Pixeln. Die Zeichenkette
* muss bereits per "str_to_ints()" in txvintin[] vorliegen.
* Die Zeichenkette darf maximal 256 Zeichen lang sein.
*

extent:
 move.l   curr_finfo,a0

     IFNE FONTPROP

 tst.w    fontmono(a0)             ; "monospaced"
 bne      extn_mono                ; ja, einfach multiplizieren
 tst.b    vintin_dirty             ; Zeichenkette enthaelt Steuerzeichen?
 beq      _ex_ok                   ; nein
 cmpa.l   #finfo_big,a0            ; grosser Zeichensatz?
 bne      _ex_ok                   ; nein

* komplizierter Fall

 movem.l  a3/a4/a5/a6/d6/d7,-(sp)
 move.l   a0,a4                    ; eigentlichen Zeichensatz merken
 lea      txvintin,a6
 move.l   a6,a3
 add.w    d0,a3
 add.w    d0,a3
 moveq    #0,d7                    ; Gesamtbreite

; Bestimme Block von Steuerzeichen

extnd_loop:
 move.l   a6,a5
extnd_loop1:
 cmpa.l   a3,a6
 bcc.b    extnd_endl1
 cmpi.w   #' ',(a6)+
 bcs.b    extnd_loop1
 subq.l   #2,a6                    ; a6 aufs erste "echte" Zeichen
extnd_endl1:
 move.l   a6,d6
 sub.l    a5,d6
 beq.b    extnd_nix_steuer         ; keine Steuerzeichen
 lsr.w    #1,d6                    ; WORD -> BYTE

; Gib Block von Steuerzeichen aus

 mulu     finfo_sys+fontcharW,d6
 add.w    d6,d7                    ; Pixelbreite

; Bestimme Block von "echten" Zeichen

extnd_nix_steuer:
 cmpa.l   a3,a6
 bcc.b    extnd_ende
 move.l   a6,a5
extnd_loop2:
 cmpa.l   a3,a6
 bcc.b    extnd_endl2
 cmpi.w   #' ',(a6)+
 bcc.b    extnd_loop2
 subq.l   #2,a6                    ; a6 aufs erste Steuerzeichen
extnd_endl2:
 move.l   a6,d6
 sub.l    a5,d6
 beq.b    extnd_nix_normal              ; keine echten Zeichen
 lsr.w    #1,d6                    ; WORD -> BYTE

; Gib Block von echten Zeichen aus

 move.l   a4,a0
 bsr      _setfont                 ; grossen Font setzen

 move.l   a5,vdipb+4               ; vintin auf Beginn des Teil-Strings

 move.l   #$74000000,d0            ; vqt_extent
 move.b   d6,d0                    ; Laenge von intin
 bsr      vdi_quick
 move.l   #vintin,vdipb+4          ; vintin restaurieren

 move.w   vptsout+4,d0
 sub.w    vptsout,d0
 addq.w   #1,d0                    ; out[2] - out[0] + 1
 add.w    d0,d7                    ; Breite addieren

extnd_nix_normal:
 cmpa.l   a3,a6
 bcs      extnd_loop

extnd_ende:
 move.l   a4,a0
 bsr      _setfont                 ; sicherstellen: grossen Font setzen
 move.w   d7,d0
 movem.l  (sp)+,a3/a4/a5/a6/d6/d7
 rts

* einfacher Fall

_ex_ok:
 move.l   #txvintin,vdipb+4        ; vintin auf Text setzen
 move.l   #$74000000,d1            ; vqt_extent
 move.b   d0,d1                    ; Laenge von intin
 move.l   d1,d0
 bsr      vdi_quick
 move.l   #vintin,vdipb+4          ; vintin restaurieren
 move.w   vptsout+4,d0
 sub.w    vptsout,d0
 addq.w   #1,d0                    ; out[2] - out[0] + 1
 rts
extn_mono:

     ENDIF

 mulu     fontcharW(a0),d0
 rts


*********************************************************************
*
* WORD r_extent( d0 = UWORD x )
*
* Pixelposition in Zeichenposition umrechnen.
*
* Die Zeichenkette muss bereits per "str_to_ints()" in vintin[]
* vorliegen, der Font mit setfont() gesetzt sein.
* Die Zeichenkette darf maximal 256 Zeichen lang sein.
*
* Da es hierzu keine VDI-Funktion gibt, muss man mit Hilfe
* von vqt_extend() und binaerer Suche schachteln.
*

r_extent:
 movem.l  d3/d4/d5/d6,-(sp)
 move.w   d0,d3               ; d3 = x
 move.w   vintin_len,d5       ; d5 = len_o
 move.l   curr_finfo,a0
 tst.w    fontmono(a0)
 beq.b    rx_prop

; 1. Fall: Font ist "mono", einfach dividieren

 moveq    #0,d1               ; Hiword loeschen
 move.w   d0,d1               ; unsigned
 divu     fontcharW(a0),d1
 move.w   d1,d0
 cmp.w    d5,d0
 bcs.b    rx_ende
 move.w   d5,d0
 bra.b    rx_ende

; 2. Fall: Font ist proportional

rx_prop:
 moveq    #0,d6               ; len_u = 0
 moveq    #0,d4               ; len = 0
 bra.b    rx_while

; while (len_u < len_o)

rx_loop:
 move.w   d5,d0
 sub.w    d6,d0
 subq.w   #1,d0               ; len_o - len_u - 1
 bne.b    rx_noz
 move.w   d5,d0               ; len
 bsr      extent
 cmp.w    d0,d3
 bls.b    rx_le
 move.w   d5,d4
 bra.b    rx_endloop
rx_le:
 move.w   d6,d4
 bra.b    rx_endloop

rx_noz:
 move.w   d6,d4
 add.w    d5,d4
 lsr.w    #1,d4               ; (len_u + len_o) / 2

 move.w   d4,d0
 bsr      extent
 cmp.w    d0,d3
 bls.b    rx_ls
 move.w   d4,d6
 bra.b    rx_while
rx_ls:
 move.w   d4,d5
rx_while:
 cmp.w    d6,d5
 bgt.b    rx_loop
rx_endloop:
 move.w   d4,d0
rx_ende:
 movem.l  (sp)+,d6/d5/d4/d3
 rts


**********************************************************************
*
* void v_drawgrect(a0 = GRECT *g)
*
* zeichnet ein ganzes Rechteck (etwa fuer xgrf_2box oder graf_rubberbox)
*

v_drawgrect:
;move.l   a0,a0
 bsr      grect_to_ptsin
 moveq    #4,d0                    ; 4 Punkte (zunaechst nur 3 Linien)
 bsr      v_draw_dashed_line
 lea      vptsin+4,a0              ; 2. Paar (rechte obere Ecke)
 move.l   8(a0),(a0)+              ; 4. Paar (lu) nach 2. Paar (ro)
 subq.w   #1,-(a0)                 ; 1 von y der rechten oberen Ecke abz.
 moveq    #2,d0                    ; 2 Punkte (letzte Linie links vertikal)
 bra.b    v_draw_dashed_line


**********************************************************************
*
* void v_drawedges(a0 = GRECT *g)
*
* zeichnet nur die Ecken des Rechtecks (etwa fuer xgrf_2box)
*

v_drawedges:
 movem.l  d3/d4/d5/d6/a3,-(sp)
;move.l   a0,a0
 move.w   gr_hwbox,d5
 add.w    d5,d5
 move.w   gr_hhbox,d6
 add.w    d6,d6
 lea      vptsin,a3
 move.l   (a0),(a3)+
 add.w    d6,-2(a3)
 move.l   (a0),(a3)+
 move.l   (a0)+,(a3)
 add.w    d5,(a3)
 move.w   (a0)+,d3
 subq.w   #1,d3
 move.w   (a0)+,d4
 subq.w   #1,d4
 moveq    #3,d0                    ; 3 Punkte (2 Linien)
 bsr.b    v_draw_dashed_line
 sub.w    d5,(a3)
 add.w    d3,(a3)
 move.l   (a3),-(a3)
 move.l   (a3),-(a3)
 sub.w    d5,(a3)
 add.w    d6,$a(a3)
 moveq    #3,d0                    ; 3 Punkte (2 Linien)
 bsr.b    v_draw_dashed_line
 add.w    d4,2(a3)
 move.l   (a3)+,(a3)
 add.w    d5,(a3)
 move.l   (a3)+,(a3)+
 sub.w    d6,-(a3)
 moveq    #3,d0                    ; 3 Punkte (2 Linien)
 bsr.b    v_draw_dashed_line
 sub.w    d3,-(a3)
 move.l   (a3),-(a3)
 add.w    d6,2(a3)
 move.l   (a3),-(a3)
 add.w    d5,(a3)
 moveq    #3,d0                    ; 3 Punkte (2 Linien)
 movem.l  (sp)+,a3/d6/d5/d4/d3
;bra.b    v_draw_dashed_line


**********************************************************************
*
* void v_draw_dashed_line(d0 = int n)
*
* Malt <n-1> Linien mit Linientyp $5555 und setzt anschliessend den
* Linientyp wieder auf $ffff (durchgezogen)
*

v_draw_dashed_line:
 movem.l  a5/a4/d7,-(sp)
     IFNE NVDI

 move.l   nvdi_workstn,a5          ; WORKSTATION

     ENDIF

 move.w   d0,d7                    ; Anzahl Paare
 subq.w   #2,d7                    ; < 2 ?
 bcs      vvdl_ende                ; keine Linie
 lea      vptsin,a4                ; Eingabepaare
vddl_l1:
 move.w   (a4)+,d0                 ; d0 = x des ersten Paares
 move.w   (a4)+,d1                 ; d1 = y des ersten Paares
 cmp.w    (a4),d0                  ; senkrecht ?
 bne.b    vddl_l2                ; nein
* Linie senkrecht
 eor.w    d0,d1
 bra.b    vddl_l3
vddl_l2:
 blt.b    vddl_l3
 move.w   2(a4),d1                 ; y des zweiten Paares
vddl_l3:
 move.w   #$5555,d0
 btst     #0,d1                    ; Bit 0 von x isolieren
 beq.b    vddl_l4
 add.w    d0,d0
vddl_l4:

     IFNE NVDI

 move.l   a5,d1
 bne.b    vddl_nvdi

     ENDIF

* Linienstil ohne NVDI aendern

 swap     d0
 move.w   #$7100,d0                ; set user-defined linestyle
 swap     d0
 bsr      vdi_1                    ; vsl_udsty(d0), aendert a1/d0/d1

     IFNE NVDI

 bra.b    vddl_both

* Linienstil mit NVDI aendern

vddl_nvdi:
 move.w   d0,NVDI_l_sdstyle(a5)

* endif

vddl_both:

     ENDIF

 move.l   #$06020000,d0            ; v_pline mit 2 Koordinaten
 lea      vcontrl,a1
 movep.l  d0,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 addq.l   #4,vdipb+8               ; ptsin weiterzaehlen
 dbra     d7,vddl_l1             ; alle Linien
 move.l   #vptsin,vdipb+8          ; ptsin restaurieren

     IFNE NVDI

 move.l   a5,d1
 bne.b    vddl_nvdi_2

     ENDIF

* Linienstil ohne NVDI aendern

 move.l   #$7100ffff,d0            ; set user-defined linestyle
 bsr      vdi_1                    ; vsl_udsty(-1)
vvdl_ende:
 movem.l  (sp)+,a5/a4/d7
 rts

     IFNE NVDI

* Linienstil mit NVDI aendern

vddl_nvdi_2:
 move.w   #$ffff,NVDI_l_sdstyle(a5)
 movem.l  (sp)+,a5/a4/d7
 rts

     ENDIF


**********************************************************************
**********************************************************************
*
* OBJECT MANAGER
*


**********************************************************************
*
* PUREC void _form_center(OBJECT *ob, GRECT *out)




*
* void _form_center(a0 = OBJECT *ob, a1 = GRECT *out)
*

* zentriert erst das OBJECT und berechnet dann die wahren
* Ausmasse in <out>
*

_form_center:
_form_center_grect:
 move.w   scr_w,d0                 ; ganze Breite
 sub.w    ob_width(a0),d0          ; - Objektbreite gibt Rand links+rechts
 asr.w    #1,d0                    ; /2 gibt Rand links
 move.w   d0,ob_x(a0)

 move.w   scr_h,d0                 ; ganze Hoehe
 add.w    gr_hhbox,d0              ; +Menueleiste
 sub.w    ob_height(a0),d0         ; - Objekthoehe gibt Rand oben+unten
 asr.w    #1,d0                    ; /2
 move.w   d0,ob_y(a0)

;move.l   a1,a1
;move.l   a0,a0
;jmp      calc_obsize              ; wahre Groesse berechnen


**********************************************************************
*
* PUREC void calc_obsize( OBJECT *tree, GRECT *size )
*
* void calc_obsize(a0 = OBJECT *tree, a1 = GRECT *size )
*
* Berechnet das "wahre" Rechteck fuer die Objektgroesse, also
* einschliesslich Rand und Schatten
*

calc_obsize:
 movem.l  a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = OBJECT *
 move.l   a1,a4
 move.l   ob_x(a5),(a4)
 move.l   ob_width(a5),4(a4)
 moveq    #0,d0                    ; Objekt 0
 move.l   a5,a0
 bsr      unpack_objc              ; aendert nicht a2
 move.w   d0,d1                    ; Rand
 btst     #4,ob_state+1(a5)        ; OUTLINED ?
 beq.b    cobs_nooutl
 moveq    #-3,d0                   ; OUTLINED bringt Rand 3 aussen
cobs_nooutl:
 tst.w    d0
 bge.b    cobs_in                  ; nur innerer Rand
 move.l   a4,a0
 add.w    d0,(a0)+                 ; x verkleinern
 add.w    d0,(a0)+                 ; y verkleinern
 neg.w    d0
 add.w    d0,d0
 add.w    d0,(a0)+                 ; w vergroessern
 add.w    d0,(a0)                  ; h vergroessern
cobs_in:
 btst     #SHADOWED_B,ob_state+1(a5)
 beq.b    cobs_noshad
 tst.w    d1
 bge.b    cobs_shadout
 neg.w    d1                       ; Betrag bilden, da Schatten immer aussen
cobs_shadout:
 add.w    d1,d1                    ; immer doppelte Schattenbreite
 add.w    d1,g_w(a4)
 add.w    d1,g_h(a4)
cobs_noshad:
 movem.l  (sp)+,a4/a5
 rts


**********************************************************************
*
* int srch_tmplt_c(a0 = char *tmplt, d0 = int a, d1 = char c)
*
* Sucht in <tmplt> nach dem Zeichen <c> und erhoeht <a> fuer jedes
* ueberlesene '_'
*

srtc_loop:
 cmpi.b   #'_',(a0)+               ; Eingabefeld ?
 bne.b    srtc_l2                  ; nein, weiter
 addq.w   #1,d0                    ; Schablonenzeichen mitzaehlen
srtc_l2:
srch_tmplt_c:
 move.b   (a0),d2                  ; d1 = Zeichen aus der Schablone
 beq.b    srtc_ret                 ; ist EOS, Ende
 cmp.b    d1,d2                    ; ist es unser Zeichen ?
 bne.b    srtc_loop                ; nein, suchen
srtc_ret:
;move.w   d0,d0                    ; Position zurueckgeben
 rts


**********************************************************************
*
* insert_char(a0 = char *txt, d0 = char c, d1 = int pos, d2 = maxlen)
*

insert_char:
 move.w   d6,-(sp)
 move.w   d7,-(sp)
 movea.l  a0,a2
 move.w   d0,d7                    ; d7 = c
 move.w   d1,d6                    ; d6 = pos
 move.l   a2,a0
 jsr      strlen
 move.w   d0,d1
 addq.w   #1,d0
 bra.b    insc_loop_cont
insc_loop:
 move.b   -1(a2,d1.w),0(a2,d1.w)
 subq.w   #1,d1
insc_loop_cont:
 cmp.w    d6,d1
 bgt.b    insc_loop
 move.b   d7,0(a2,d1.w)
 cmp.w    d0,d2                    ; maxlen <= d0
 ble.b    insc_l1
 clr.b    0(a2,d0.w)
 bra.b    insc_l2
insc_l1:
 clr.b    -1(a2,d2.w)
insc_l2:
 move.w   (sp)+,d7                 ; movem.w macht sign-extension!
 move.w   (sp)+,d6
 rts


**********************************************************************
*
* txtpos_to_tmpltpos(a0 = TEDINFO *tedinfo, d0 = int ptxtpos)
*
* <ptxtpos> ist die Position des Cursors bezueglich des reinen
* Textstrings. Die davor liegenden Schablonenzeichen muessen fuer die
* Position im Mischstring/Schablone mitgezaehlt werden.
* Es wird vermieden, dass der Cursor auf einem Schablonenzeichen
* steht.
*

txtpos_to_tmpltpos:
 move.w   d0,d1                    ; d1 = pos
 move.l   te_ptmplt(a0),d0         ; Scrollbares TEDINFO ?
 bne.b    txtp2tmpp_ok             ; nein, OK
 move.l   te_pvalid(a0),a0
 move.l   xte_ptmplt(a0),d0
txtp2tmpp_ok:
 move.l   d0,a0
 moveq    #0,d0
 bra.b    txtt_l3
txtt_l1:
 cmpi.b   #'_',(a0)+               ; Eingabefeld ?
 bne.b    txtt_l2                  ; nein, weiter
 subq.w   #1,d1                    ; Platz fuer ein Zeichen gefunden
txtt_l2:
 addq.w   #1,d0                    ; Stringposition
txtt_l3:
 tst.w    d1                       ; solange noch nicht alle Zeichen
                                   ;  ihren Platz auf '_' gefunden haben
 bgt.b    txtt_l1                  ; ja, weiter

* d0/a0 zeigt hinter das letzte der <ptxtpos> Zeichen, und zwar bezueglich
* des Mischstrings und der Schablone
* verhindere, dass der Cursor auf einem Schablonenzeichen steht

 bra.b    txtt_l5
txtt_l4:
 addq.w   #1,d0
 addq.l   #1,a0
txtt_l5:
 tst.b    (a0)                     ; Ende der Schablone ?
 beq.b    txtt_l7                  ; ja
 cmpi.b   #'_',(a0)                ; weiteres Eingabefeld ?
 bne.b    txtt_l4                  ; nein, weiter
 bra.b    txtt_ret                 ; ja, fertig: darauf kommt der Cursor

* rechts befindet sich kein Eingabefeld mehr, suche das rechteste
* Schablonenzeichen

txtt_l6:
 cmpi.b   #'_',-(a0)               ; links von uns Eingabefeld ?
 beq.b    txtt_ret                 ; ja, Ende
 subq.w   #1,d0                    ; gehe einen nach links
txtt_l7:
 tst.w    d0                       ; sind wir noch im String ?
 bge.b    txtt_l6                  ; ja, weiter
 tst.b    (a0)                     ; String leer ?
 beq.b    txtt_ret                 ; ja, Ende
 addq.w   #1,d0                    ; nein, einen nach rechts
txtt_ret:
;move.w   d0,d0
 rts


**********************************************************************
*
* WORD objc_cur_calc( a0 = OBJECT *tree, a1 = TEDINFO *te,
*                        d0 = int objnr, d1 = int pos,
*                        a2 = void *retvals )
*
* Berechnet die x-Position des Cursors (in Pixeln) relativ zum
* Objekt-Anfang. Rueckgabe -1 bei Fehler (Cursor zu weit links).
*
* <pos> ist die absolute Cursorposition relativ zum Mischstring
* und der Schablone
*
* retvals:     +0   x-Position des Eingabe-Bereichs rel. zum Obj.
*              +2   y-Pos. des ...
*              +4   Breite des Eingabe-Bereichs in Pixeln
*              +6   Hoehe
*

objc_cur_calc:
 movem.l  a6/a5/a4/a3/d7/d6/d3,-(sp)
 suba.w   #20,sp              ; 20 Bytes: Platz fuer Rueckgabewerte calc_ftext
 mulu     #24,d0
 lea      0(a0,d0.l),a5       ; a5 = OBJECT *ob
 move.l   a1,a3               ; a3 = TEDINFO *te
 move.l   a2,a6
 move.w   d1,d6               ; d6 = absolute Cursorposition in Zeichen

; Objekt-Rechteck ermitteln

 clr.l    g_x(sp)                  ; x = y = 0
 move.l   ob_width(a5),g_w(sp)     ; w/h vom Objekt uebernehmen

; Font umschalten und ermitteln

 move.w   te_font(a3),d0
 bsr      setfont                  ; Font ermitteln
 move.l   a0,a4                    ; a4 = FINFO *

; Schablone ermitteln
; wenn Proportionalfont: Misch-String erzeugen

 moveq    #-1,d3                   ; d3 = Laenge der Schablone (Auto)
 moveq    #0,d7
 move.b   te_just(a3),d7           ; Scroll-Offset
 move.l   te_ptmplt(a3),d0         ; Scrollbares TEDINFO ?
 bne.b    occ_no_xscroll           ; nein, OK

; scrollendes Eingabefeld

 move.l   te_pvalid(a3),a0
 move.w   xte_vislen(a0),d3        ; sichtbare Laenge
 move.l   xte_ptmplt(a0),d0        ; Schablone
 move.w   xte_scroll(a0),d7

; nicht scrollendes Eingabefeld

occ_no_xscroll:
 sub.w    d7,d6                    ; Cursorposition korrigieren
 move.l   d0,a0                    ; Schablone merken
 tst.w    fontmono(a4)
 bne.b    occ_just
 move.l   a0,-(sp)
 move.l   a0,a1                    ; Schablone
 move.b   te_just+1(a3),d0         ; te_just
 move.l   (a3),a0                  ; text
 lea      popup_tmp,a2             ; dest (Mischstring)
 bsr      txt_tmplt_to_merge       ; formatieren
 move.l   (sp)+,a0                 ; Schablone zurueck

; Justieren

occ_just:
 move.l   sp,a2                    ; data
 move.l   a3,a1                    ; TEDINFO
;move.l   a0,a0                    ; a0 = Schablone
 move.w   d3,d0                    ; Laenge der Schablone
 bsr      calc_ftext               ; Zeichenpositionen berechnen

; Cursorposition von Zeichen in Pixel

 move.w   10(sp),d0                ; Breite des Anfangs in Pixeln
 add.w    d0,g_x(sp)               ; Zur x-Pos addieren
 sub.w    8(sp),d6                 ; Anfang der Schablone von Cursorpos. sub.
 move.w   d6,d0
 bmi.b    occ_ende                 ; Fehler

 tst.w    fontmono(a4)
 bne.b    occ_mono1
 lea      popup_tmp,a0             ; Misch-String
 add.w    8(sp),a0                 ; + Laenge des Anfangs
 move.w   12(sp),d0                ; Laenge des Eingabefelds
 clr.b    0(a0,d0.w)               ; EOS setzen
 add.w    d7,a0                    ; Scroll-Offset
 bsr      str_to_ints
occ_mono1:
 move.w   d6,d0
 bsr      extent
 tst.w    fontmono(a4)
 bne.b    occ_isz
 tst.w    d0
 beq.b    occ_isz
 subq.w   #1,d0                    ; offenbar notwendig???
occ_isz:
 add.w    g_x(sp),d0               ; Zeichenpos. zur x-Pos. addieren
 move.w   g_x(sp),(a6)+            ; Beginn des Eingabe-Bereichs
 move.w   g_y(sp),(a6)+
 move.w   14(sp),(a6)+             ; Breite des Eingabe-Bereichs in Pixeln
 move.w   g_h(sp),d1               ; Hoehe des Eingabe-Bereichs in Pixeln
 cmp.w    ob_height(a5),d1         ; groesser als das Objekt selbst?
 bls.b    occ_seth                 ; nein, Texthoehe nehmen
 move.w   ob_height(a5),d1         ; auf Objekthoehe stutzen
occ_seth:
 move.w   d1,(a6)
occ_ende:
;move.w   d0,d0
 adda.w   #20,sp
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d3
 rts


**********************************************************************
*
* void objc_cur_draw( a0 = OBJECT *tree, a1 = TEDINFO *tedinfo,
*                     d0 = int objnr,
*                     d1 = int pos, d2 = int handle/int nchars,
*                     a2 = GRECT *clip )
*
* <pos> ist die absolute Cursorposition relativ zum Mischstring
* und der Schablone
* <clip> ist i.a. NULL, nur fuer Window- Redraw
*
* <nchars> == 0: normale Funktion, Cursor malen (XOR)
*          != 0: <nchars> Zeichen unter und rechts vom Cursor
*                zeichnen (etwa bei BS oder DEL)
*
* Hiword enthaelt das Fensterhandle
*
* XGEM: arbeitet auch fuer kleine Fonts
*       arbeitet auch in Fenstern
*

__cursor:
 moveq    #2,d0
 bra      v_pline                  ; eine Linie, a0 ist ptsin[]


objc_cur_draw:
 movem.l  a6/a5/a3/d7/d6/d5/d4/d3,-(sp)
 suba.w   #18,sp              ;  8 Bytes: GRECT fuer Objekt
                              ;  8 Bytes: gerettetes Clipping
                              ;  2 Bytes: Flag: gescrollt
 move.l   a2,a6               ; a6 = GRECT *clip
 move.l   a0,a5               ; a5 = OBJECT *tree
 move.l   a1,a3               ; a3 = TEDINFO *
 move.w   d0,d7               ; d7 = objnr
 move.w   d1,d6
 move.w   d2,d5
 swap     d2
 move.w   d2,d4               ; d4 = whdl oder 0
 bne.b    ocd_wh
 moveq    #-1,d4              ; 0 => -1
ocd_wh:
 sf       16(sp)              ; nicht gescrollt

;move.w   d1,d1
;move.l   a0,a0
;move.w   d0,d0
;move.l   a1,a1
ocd_scroll_loop:
 lea      (sp),a2
 bsr      objc_cur_calc       ; in Pixel-Koordinaten umrechnen
 moveq    #-1,d1

; Testen, ob der Cursor zu weit links liegt

 tst.w    d0
 bmi.b    ocd_links

; Testen, ob der Cusor zu weit rechts liegt

 move.w   g_x(sp),d3
 add.w    g_w(sp),d3               ; d3 = Ende des Eingabe-Bereichs
 cmp.w    d3,d0
 bls.b    ocd_is_visible
 moveq    #1,d1
ocd_links:
 tst.w    d5
 bne      ocd_ende2
 move.l   te_ptmplt(a3),d2         ; TEDINFO scrollbar?
 bne.b    ocd_no_xc                ; nein
 move.l   te_pvalid(a3),a0
 add.w    d1,xte_scroll(a0)        ; scrollen
 bra.b    ocd_sc1

ocd_no_xc:
 add.b    d1,te_just(a3)
ocd_sc1:
 st       16(sp)                   ; gescrollt

 move.w   d6,d1
 move.l   a5,a0
 move.w   d7,d0
 move.l   a3,a1
 bra.b    ocd_scroll_loop

ocd_is_visible:
 move.w   d0,d6                    ; x-Pos. des Cursors merken

; Clipping- Rechteck merken

 lea      8(sp),a0
 bsr      get_clip_grect           ; aktuelles Clippingrechteck merken

; Objekt-Position in absolute Werte umrechnen

 move.l   a5,a0                    ; tree
 move.w   d7,d0                    ; objnr
 bsr      _objc_offset
 add.w    d0,g_x(sp)
 add.w    d1,g_y(sp)
 add.w    d0,d6                    ; x-Pos. des Cursors absolut
 add.w    d0,d3                    ; Ende des Eingabefelds absolut

; Maus ausschalten

 bsr      mouse_off

; wenn gescrollt: Objekt neu zeichnen

 tst.b    16(sp)
 beq.b    ocd_no_all
 move.w   d4,d2                    ; whdl
 lea      (sp),a1                  ; g
 moveq    #0,d0                    ; depth
 move.w   d7,d0                    ; objnr
 move.l   a5,a0
 bsr      objc_wdraw
 tst.w    d5                       ; irgendwas neu zeichnen ?
 bne      ocd_ende                 ; ja, erledigt

ocd_no_all:
 move.w   d6,g_x(sp)
 move.w   d5,d1
 beq.b    ocd_case0

* if nchars != 0

 move.w   te_font(a3),d0
 bsr      setfont
 tst.w    fontmono(a0)
 bne.b    ocd_mono2
 move.w   d3,d1                    ; Ende des Eingabefelds
 sub.w    d0,d1                    ; - Zeichen-Offset
 bra.b    ocd_cbo
ocd_mono2:
 mulu     fontcharW(a0),d1         ; wchar, auf Pixel umrechnen
ocd_cbo:
 move.w   d1,g_w(sp)               ; Soviel Breite ausgeben
 bra.b    ocd_caseboth

* if nchars == 0

ocd_case0:
 move.w   #1,g_w(sp)
 bsr      set_xor_black
* der Cursor ragt ein wenig ueber das Zeichen (3 Pixel oben und unten)
 moveq    #3,d0                    ; grosser Cursor
 cmpi.w   #3,te_font(a3)
 beq.b    ocd_big2
 moveq    #2,d0                    ; kleiner Cursor
ocd_big2:
 sub.w    d0,g_y(sp)               ; y um 3 verkleinern
 add.w    d0,d0
 add.w    d0,g_h(sp)               ; h um 6 vergroessern

* endif

ocd_caseboth:
 tst.w    d4                       ; Ausgabe in Fenster ?
 bmi.b    ocd_nowin                ; nein, alte Funktion

* Ausgabe in Fenster

 tst.w    d5
 beq.b    ocd_cursor
; nchars != 0, also Objekt malen
 move.w   d4,d2                    ; whdl
 lea      (sp),a1                  ; g
 moveq    #0,d0                    ; depth
 move.w   d7,d0                    ; objnr
 move.l   a5,a0
 bsr      objc_wdraw
 bra      ocd_restoreclip
ocd_cursor:
; nchars = 0, also nur Cursor malen
 move.l   sp,a2
 move.w   g_y(a2),-(sp)
 move.w   g_h(a2),d0
 add.w    d0,(sp)
 subq.w   #1,(sp)                  ;       y+h-1
 move.w   g_x(a2),-(sp)            ; nach: x
 move.l   g_x(a2),-(sp)            ; von:  x,y
 move.l   sp,a0                    ; zu uebergebende Daten

 pea      __cursor(pc)             ; function
 move.w   d4,d2                    ; whdl
 move.l   a2,a1                    ; g
;moveq    #0,d1                    ; depth (dummy)
;moveq    #0,d0                    ; startob (dummy)
;move.l   a0,a0                    ; Daten
 bsr      _objc_wdraw
 addq.l   #4,sp
 bra      ocd_a2

* Ausgabe ohne Fenster

ocd_nowin:
 move.l   sp,a2
 move.l   a6,d0                    ; Clipping- Rechteck ?
 beq.b    ocd_noclip
 move.l   g_w(a6),-(sp)
 move.l   g_x(a6),-(sp)
 move.l   sp,a1
 move.l   a2,a0
 bsr      grects_intersect         ; mit Rechteck schneiden
 bne.b    ocd_weiter
 addq.l   #8,sp
 bra      ocd_ende                 ; Schnitt ist leer
ocd_weiter:
 move.l   sp,a0
 bsr      set_clip_grect           ; neues Clippingrechteck setzen
 addq.l   #8,sp
 bra.b    ocd_both
ocd_noclip:
 move.l   a2,a0
 bsr      set_clip_grect           ; neues Clippingrechteck setzen
ocd_both:
 tst.w    d5
 beq.b    ocd_l1

* if nchars != 0

 moveq    #0,d1                    ; nur Objekt selbst
 move.w   d7,d0                    ; objnr
 move.l   a5,a0                    ; tree
 bsr      _objc_draw

 bra.b    ocd_restoreclip

* if nchars == 0

ocd_l1:
 move.l   sp,a2
 move.w   g_y(a2),-(sp)
 move.w   g_h(a2),d0
 add.w    d0,(sp)
 subq.w   #1,(sp)                  ;       y+h-1
 move.w   g_x(a2),-(sp)            ; nach: x
 move.l   g_x(a2),-(sp)            ; von:  x,y
 jsr      draw_line                ; Cursor malen
ocd_a2:
 addq.l   #8,sp
ocd_restoreclip:
 lea      8(sp),a0
 jsr      set_clip_grect           ; Clipping wiederherstellen
ocd_ende:
 bsr      mouse_on
ocd_ende2:
 adda.w   #18,sp
 movem.l  (sp)+,a6/a5/a3/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* int match(d0 = char c, a0 = char *valids)
*

mtch_loop:
 move.b   d2,d1
 cmpi.b   #'.',(a0)
 bne.b    mtch_l1
 cmpi.b   #'.',1(a0)
 bne.b    mtch_l1
 addq.l   #2,a0
 move.b   (a0)+,d2
mtch_l1:
 cmp.b    d1,d0                    ; untere Intervallgrenze
 bcs.b    mtch_l2
 cmp.b    d2,d0                    ; obere Intervallgrenze
 bls.b    match_true
match:
mtch_l2:
 move.b   (a0)+,d2
 bne.b    mtch_loop
 moveq    #0,d0
 rts
match_true:
 moveq    #1,d0
 rts


**********************************************************************
*
* int is_valid(a0 = char *c, d0 = char mask)
*
* Prueft das Zeichen <*c>, ob es zu <mask> ('9','A','N',...) passt.
* Wandelt ggf. <*c> in Grossschrift um
*

is_valid:
 move.b   d0,d1                    ; d1 = mask
 cmpi.b   #'X',d1
 beq      ret_valid                ; 'X' passt immer
 move.l   a0,a1
 move.b   (a1),d0                  ; d0 = *c
 cmpi.b   #'x',d1
 bne.b    switch
 jsr      toupper
 move.b   d0,(a1)                  ; 'x' wandelt in Grossschrift um
 bra      ret_valid
switch:
 lea      masks(pc),a0
 move.l   a0,a2
isv_loop:
 tst.b    (a0)
 beq.b    ret_invalid              ; Maske nicht gefunden
 cmp.b    (a0)+,d1
 bne.b    isv_loop
 suba.l   a2,a0
 move.w   a0,d1                    ; d1 = Nummer (1..9)
 cmpi.w   #7,d1
 bhi.b    not_upper                ; bei 'a','n','m' keine Umwandlung
 jsr      toupper
 move.b   d0,(a1)                  ; in Grossschrift wandeln
not_upper:

 add.w    d1,d1
 add.w    d1,d1                    ; Langwortzugriff
 move.l   valid_s-4(pc,d1.w),a0    ; Validstring holen

 bra      match                    ; Match- Funktion
ret_valid:
 moveq    #1,d0
 rts
ret_invalid:
 moveq    #0,d0
 rts

masks:
 DC.B     '9','A','N','P','p','F','f','a','n','m',0

     EVEN
valid_s:
 DC.L     valid_9
 DC.L     valid_A
 DC.L     valid_N
 DC.L     valid_P
 DC.L     valid_p
 DC.L     valid_F
 DC.L     valid_f
 DC.L     valid_a
 DC.L     valid_n
 DC.L     valid_m   ; Mac-Dateinamen (alles ausser ':' und '\' und '\'')

valid_9:  DC.B	"0..9",0
valid_A:  DC.B	"A..Z ",$80,$8e,$8f,$90,$92,$99,$9a,$a5,$b5,$b2,$c1,$b6,$b7,$b8,$9e,$c2,"..",$dc,0
valid_N:  DC.B	"0..9A..Z ",$80,$8e,$8f,$90,$92,$99,$9a,$a5,$b5,$b2,$c1,$b6,$b7,$b8,$9e,$c2,"..",$dc,0
valid_P:  DC.B	"0..9a..zA..Z\?*:._",$80,"..",$ff,0
valid_p:  DC.B	"0..9a..zA..Z\:_",$80,"..",$ff,0
valid_F:  DC.B	"a..z0..9A..Z-:?*_",$80,"..",$ff,0     ; '-' !
valid_f:  DC.B	"a..z0..9A..Z-_:",$80,"..",$ff,0       ; ':' und '-' !!
valid_a:  DC.B	"a..zA..Z ",$80,"..",$ff,0
valid_n:  DC.B	"0..9a..zA..Z ",$80,"..",$ff,0
valid_m:  DC.B	" ..&(..9;..[]..",$ff,0
     EVEN


**********************************************************************
*
* d0/d1 = get_curpos_txtend(a0 = TEDINFO *tedinfo, d0 = int pos,
*                        a6 = char *curr_ptext)
*
* Eingabe: d0 enthaelt die Cursorposition relativ zum Textfeld,
*          d.h. ohne Schablonenzeichen.
* Ausgabe: d0 enthaelt die (physikalische) Cursorposition relativ

*           zum Mischstring und der Schablone
*          d1 enthaelt die Laenge des Textfeldes relativ zum
*           Mischstring und der Schablone, d.h. d1 zeigt dann hinter
*           das letzte Textzeichen im Mischstring
*

get_curpos_txtend:
 move.l   a0,a2                    ; tedinfo merken

;move.w   d0,d0                    ; pos
;move.l   a0,a0                    ; tedinfo
 bsr      txtpos_to_tmpltpos
 move.w   d0,-(sp)                 ; Cursorposition merken

 move.l   a6,a0                    ; curr_ptext
 jsr      strlen

;move.w   d0,d0
 move.l   a2,a0                    ; tedinfo
 bsr      txtpos_to_tmpltpos
 move.w   d0,d1                    ; Textende nach d1

 move.w   (sp)+,d0                 ; Cursorposition
 rts


**********************************************************************
*
* EQ/NE c_is_sep(d0 = char c)
*

separator_s:
 DC.B     " !../:..?[\]{|}~",$f6,$f7,$f8,$f9,$fa,0

c_is_sep:
 move.l   a0,-(sp)
 lea      separator_s(pc),a0
 bsr      match
 move.l   (sp)+,a0
 rts


**********************************************************************
*
* int objc_crsr(a0 = OBJECT *tree, d0 = int objnr,
*               d1 = int x, d2 = WORD kind, a1 = int *didx )
*
* Eingabe:
*  kind:       Hiword enthaelt ggf. ein WindowHandle
*  x:          Pixelposition des Cursors (z.B. von einem Mausklick)
*  x < 0:      Cursor auf Defaultposition
*
* Rueckgabe:
*  *didx:      Cursorposition in Zeichen relativ zu te_ptext
*
* Diese Funktion wird fuer objc_edit(ED_CRSR) aufgerufen und
* ist ein erweiterter Ersatz fuer objc_edit(ED_INIT).
* Aendert nicht a2.
*

objc_crsr:
 movem.l  a2/a3/a5/a6/d7/d6/d4,-(sp)
 suba.w   #26,sp                   ; 0: Platz fuer Rueckgabe von calc_ftext
                                   ; 20: xte_scroll
                                   ; 22: didx
 moveq    #0,d4
 lsr.w    #8,d2
 move.w   d2,d4                    ; Fenster-Handle

 move.l   a0,a5                    ; a5 = OBJECT *tree
 move.w   d0,d6                    ; d6 = WORD objnr
 move.l   a1,22(sp)                ; 22(sp) = WORD *didx  (Rueckgabe)

 mulu     #24,d0
 move.l   ob_spec(a0,d0.l),a3      ; a3 = TEDINFO *

 move.w   d1,d7
 bmi      ocr_dfltpos              ; x < 0 => Default-Cursorposition

; x >= 0: Cursorposition berechnen

 move.l   sp,a1                    ; GRECT
 move.w   d6,d0                    ; objnr
;move.l   a0,a0                    ; tree
 jsr      obj_to_g                 ; Objektausmasse nach GRECT

 moveq    #0,d1
 move.b   te_just(a3),d1           ; Scroll-Offset
 moveq    #-1,d0                   ; vislen ist Default
 move.l   te_ptmplt(a3),d2
 bne.b    ocr_noscrl
 move.l   te_pvalid(a3),a0
 move.l   xte_ptmplt(a0),d2
 move.w   xte_scroll(a0),d1
 move.w   xte_vislen(a0),d0
ocr_noscrl:
 move.w   d1,20(sp)                ; xte_scroll
 move.l   d2,a6                    ; a6 = Schablone

; Feldelemente berechnen

 move.l   sp,a2                    ; data
 move.l   a3,a1                    ; TEDINFO
 move.l   a6,a0                    ; a0 = Schablone
;move.w   d0,d0                    ; Anzahl sichtbarer RSC-Einheiten
 bsr      calc_ftext               ; Zeichenpositionen berechnen

; GRECT des reinen Eingabefelds berechnen

 move.w   10(sp),d0                ; Breite des Anfangs in Pixeln
 add.w    d0,g_x(sp)               ; auf x-Position addieren
 move.w   14(sp),g_w(sp)           ; Breite des Eingabefelds in Pixeln
 sub.w    g_x(sp),d7               ; x von Klickpos. abziehen

; Font bestimmen

 move.w   te_font(a3),d0
 bsr      setfont

; Wenn Prop.Font, muss der Misch-String berechnet werden

 move.w   12(sp),vintin_len        ; Breite des Eingabefelds (!)
 tst.w    fontmono(a0)
 bne.b    ocr_no_merge
 move.b   te_just+1(a3),d0
 lea      popup_tmp,a2             ; dest (Mischstring)
 move.l   a6,a1                    ; Schablone
 move.l   (a3),a0                  ; text
 bsr      txt_tmplt_to_merge       ; formatieren
 lea      popup_tmp,a0
 add.w    8(sp),a0                 ; + Anzahl Zeichen des Anfangs
 move.w   12(sp),d0                ; Anzahl Zeichen des Eingabefelds
 clr.b    0(a0,d0.w)               ; EOS setzen
 add.w    20(sp),a0                ; Scroll-Offset
 bsr      str_to_ints

ocr_no_merge:
 move.w   d7,d0                    ; x 
 bsr      r_extent
 move.w   d0,d7                    ; d7 = Zeichenposition bzgl. Schablone
 add.w    20(sp),d7                ; xte_scroll ergaenzen
 add.w    8(sp),d7                 ; Anzahl Zeichen des Anfangs ergaenzen

 move.l   a6,a0                    ; Stringanfang
 lea      0(a0,d7.w),a1            ; gewuenschte Pos.
 moveq    #0,d0
ocr_loop:
 cmp.l    a0,a1
 ble.b    ocr_set
 move.b   (a0)+,d1
 beq.b    ocr_set
 cmpi.b   #'_',d1
 beq.b    ocr_loop
 subq.w   #1,d7
 bra.b    ocr_loop

; x < 0: Default-Cursorposition

ocr_dfltpos:
 tst.l    te_ptmplt(a3)            ; Text scrollbar ?
 bne.b    ocr_endpos               ; nein

 moveq    #0,d1                    ; neue Scrollposition
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; TEDINFO
 move.l   a5,a0                    ; tree
 bsr      scroll_tedinfo

 move.l   te_ptext(a3),a0          ; ptext
 jsr      strlen                   ; d0 = Stringlaenge
 move.l   te_pvalid(a3),a0         ; XTED
 cmp.w    xte_vislen(a0),d0        ; Stringlaenge <= sichtbare Laenge ?
 bls.b    ocr_setcurpos            ; ja, OK
 moveq    #0,d0                    ; Cursor an Textanfang !!!
 bra.b    ocr_setcurpos
ocr_set:
ocr_endpos:
 move.l   te_ptext(a3),a0
 jsr      strlen
ocr_setcurpos:
 cmp.w    d0,d7
 bls.b    ocr_ok
 move.w   d0,d7
ocr_ok:
 move.l   22(sp),a0                ; didx
 move.w   d7,(a0)
 move.w   d7,d0
 move.l   a3,a0                    ; tedinfo
 bsr      txtpos_to_tmpltpos

 suba.l   a2,a2
 move.w   d4,d2                    ; Handle
 swap     d2
 clr.w    d2                       ; nur Cursor
 move.w   d0,d1                    ; pos
 move.w   d6,d0                    ; objnr
 move.l   a3,a1
 move.l   a5,a0                    ; tree
 bsr      objc_cur_draw

 adda.w   #26,sp
 movem.l  (sp)+,a2/a3/a5/a6/d7/d6/d4
 rts


**********************************************************************
*
* input_char( d0 = int key, a6 = char *curr_ptext )
*

input_char:
 move.w   d0,-(sp)
                                   ; schon hier fragen, damit wir nicht
                                   ; umsonst nach links gehen
 tst.b    1(sp)                    ; nur ASCII- Teil
 beq      inptc_ende               ; Nullzeichen, nichts tun
 moveq    #0,d4                    ; Cursor war nicht ganz rechts
 move.w   te_txtlen(a3),d0
 subq.w   #2,d0
 cmp.w    (a4),d0
 bge.b    ichr_l1                  ; txtlen >= curpos
* Cursor zu weit rechts, einen nach links gehen
 subq.w   #1,d3                    ; phys. Cursorpos. einen nach links
 moveq    #1,d4                    ; Cursor war ganz rechts
 subq.w   #1,(a4)                  ; einen nach links
ichr_l1:
 lea      258(a6),a0               ; curr_pvalid
 adda.w   (a4),a0                  ; Valid ist Text 1-1 zugeordnet

 move.b   (a0),d0                  ; Valid- Zeichen ('A','9',...)
 lea      1(sp),a0
 bsr      is_valid                 ; pruefen, ggf. umwandeln

 tst.w    d0
 beq.b    ichr_l2                  ; Zeichen ungueltig
* Zeichen gueltig
 move.b   1(sp),d0                 ; Zeichen
 btst.b   #1,config_status+3.w     ; inp_ovwrmode ?
 beq.b    is_ins
* Ueberschreibmodus
 move.l   a6,a0                    ; curr_ptext
 adda.w   (a4),a0
 tst.b    (a0)
 beq.b    is_ins                   ; am String- Ende wie "Einfuegen"
 move.b   d0,(a0)                  ; sonst Zeichen speichern
 bra.b    no_ins
is_ins:
 move.w   te_txtlen(a3),d2         ; Maximallaenge
;move.w   d0,d0                    ; Zeichen
 move.w   (a4),d1                  ; Einfuegeposition
 move.l   a6,a0                    ; curr_ptext
 bsr      insert_char
no_ins:
 addq.w   #1,(a4)                  ; Cursor einen nach rechts
 sf       d5                       ; muss rechts von Cursor neu zeichnen
 bra.b    inptc_ende

* Zeichen ungueltig. Gibt es ein passendes Schablonenzeichen rechts davon ?

ichr_l2:
 tst.w    d4                       ; war Cursor nach links gelaufen ?
 beq.b    ichr_l3                  ; nein, keine Korrektur
 addq.w   #1,(a4)                  ; Korrektur
 addq.w   #1,d3
ichr_l3:
 move.l   te_ptmplt(a3),d0         ; Schablone
 bne.b    inptc_ok
 move.l   te_pvalid(a3),a0
 move.l   xte_ptmplt(a0),d0
inptc_ok:
 move.l   d0,a0

 move.b   1(sp),d1                 ; unser Zeichen
 move.w   (a4),d0                  ; Cursorposition
 adda.w   d3,a0                    ; ab abs. Cursorposition suchen
 bsr      srch_tmplt_c

 move.w   te_txtlen(a3),d1
 subq.w   #2,d1
 cmp.w    d0,d1                    ; neue Pos (d0) >= Maximallaenge ?
 ble.b    inptc_ende               ; uebers Ziel hinaus
 move.l   a6,a0                    ; curr_ptext
 adda.w   (a4),a0
 move.w   d0,-(sp)                 ; d0 retten

;move.l   a0,a0
 moveq    #' ',d1                  ; mit ' ' fuellen
;move.w   d0,d0                    ; Pos des gefundenen Schablonenzeichens
 sub.w    (a4),d0                  ; Cursorpos. abziehen
 jsr      fillmem

 move.w   (sp)+,d0                 ; d0 holen
 move.l   a6,a0                    ; curr_ptext
 adda.w   d0,a0
 clr.b    (a0)
 move.w   d0,(a4)
 sf       d5                       ; muss neu zeichnen
inptc_ende:
 move.w   (sp)+,d0
 rts


**********************************************************************
*
* void scroll_tedinfo(a0 = OBJECT *tree, a1 = TEDINFO *ted,
*              d0 = int objnr, d1 = int new_scroll)
*
* Scrollt ein TEDINFO von alter Position xte_scroll auf neue
* Position <d1>
*

scroll_tedinfo:
 move.l   te_pvalid(a1),a2
 cmp.w    xte_scroll(a2),d1
 beq.b    scrlte_ende
 move.w   d1,xte_scroll(a2)        ; neue ScrollPosition eintragen
 moveq    #0,d2                    ; kein WindowHandle
 move.w   xte_vislen(a2),d2        ; Gesamtbreite
 suba.l   a2,a2                    ; kein Clipping
;move.w   d1,d1                    ; pos
;move.w   d0,d0                    ; objnr
;move.l   a1,a1                    ; tedinfo
;move.l   a0,a0                    ; tree
 bra      objc_cur_draw            ; Zeichen rechts vom Cursor malen
scrlte_ende:
 rts


/*
scroll_tedinfo:
 movem.l  a6/a5/a4/a3/d7/d6/d5/d4,-(sp)
 move.l   a0,a5               ; a5 = tree
 move.w   d0,d4
 move.l   a1,a3               ; a3 = ted
 move.w   d1,d6               ; d6 = new_scroll

 move.l   te_pvalid(a3),a6
 move.w   xte_scroll(a6),d5
 sub.w    d6,d5               ; Scroll-Offset = aktuelle minus neue Scrollpos.
 beq      scrlte_nix
 move.w   d6,xte_scroll(a6)   ; neue Scrollpos. eintragen
 move.w   d5,d7               ; d7 = Offset
 bge.b    scrlte_p1
 neg.w    d5                  ; Absolutwert
scrlte_p1:
 sub.w    xte_vislen(a6),d5   ; > sichtbare Breite ?
 neg.w    d5
 ble      scrlte_draw_all     ; ja, nix scrollen, alles neu zeichnen

 move.w   te_font(a3),d0
 bsr      setfont             ; Font ermitteln
 move.l   a0,a4               ; a4 = Font
 tst.w    fontmono(a4)        ; Proportionalfont ?
 beq      scrlte_draw_all     ; ja, alles neu zeichnen

 move.w   d4,d0               ; obj
 move.l   a5,a0               ; tree
 bsr      _objc_offset        ; -> d0 = x / d1 = y

 move.w   fontcharH(a4),-(sp) ; h
 move.w   d5,d2               ; d5 ist Anzahl der gescrollten Zeichen
 mulu     fontcharW(a4),d2
 move.w   d2,-(sp)            ; w
 move.w   d1,-(sp)            ; dst_y
 tst.w    d7
 bmi.b    scrlte_lft          ; links scrollen
* nach rechts
 move.w   d7,d2
 mulu     fontcharW(a4),d2
 add.w    d0,d2
 move.w   d2,-(sp)            ; dst_x
 move.w   d1,-(sp)            ; src_y
 move.w   d0,-(sp)            ; src_x
 moveq    #0,d6               ; ab Position 0 neu zeichnen
 bra.b    scrlte_blit
* nach links:
scrlte_lft:
 move.w   d0,-(sp)            ; dst_x
 move.w   d1,-(sp)            ; src_y
 muls     fontcharW(a4),d7
 sub.w    d7,d0
 move.w   d0,-(sp)            ; src_x
 move.w   d5,d6               ; ab Position (sichtbar - Offset) zeichnen
scrlte_blit:
 bsr      blitcopy_rectangle
 adda.w   #12,sp
 bra.b    scrlte_weiter

scrlte_draw_all:
 moveq    #0,d6               ; alle neue zeichnen, da nix geblittet
scrlte_weiter:
* Mischen und malen
* soviele muessen gezeichnet werden, wie Offset ist.
* maximal Anzahl sichtbarer Zeichen
 moveq    #0,d2
 move.w   xte_vislen(a6),d2        ; Gesamtbreite
 tst.w    d5
 ble.b    scrlte_p
 sub.w    d5,d2                    ; - gescrollter Bereich
scrlte_p:
 suba.l   a2,a2
 move.w   xte_scroll(a6),d1
 add.w    d6,d1                    ; pos
 move.w   d4,d0                    ; objnr
 move.l   a3,a1                    ; tedinfo
 move.l   a5,a0                    ; tree
 bsr      objc_cur_draw            ; Zeichen rechts vom Cursor malen
scrlte_nix:
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4
 rts
*/


/*
**********************************************************************
*
* void make_cursor_visible(a0 = OBJECT *tree, d0 = WORD objnr,
*               a1 = TEDINFO *te, a2 = WORD *cursor_pos)
*

make_cursor_visible:
 movem.l  a5/a4/a3,-(sp)
 move.l   a0,a5                    ; a5 = OBJECT *tree
 move.l   a1,a3                    ; a3 = TEDINFO *te
 move.l   a2,a4                    ; a4 = WORD *cursor_pos

 tst.l    te_ptmplt(a3)            ; Text scrollbar ?
 bne.b    mkvi_ende                ; nein
 move.w   (a4),d0                  ; Cursorposition im Text
 move.l   a3,a0
 bsr      txtpos_to_tmpltpos       ; => d0 = Cursorposition in Schablone

 move.l   te_pvalid(a3),a0
 cmp.w    xte_scroll(a0),d0        ; aktuelle Scrollposition
 bcc.b    mkvi_noscroll2           ; Cursor >= Anfang sichtbarer Bereich, OK

* Der Cursor ist links vom sichtbaren Bereich der Schablone. Wir
* muessen die Schablone nach rechts scrollen, so dass der Cursor wieder
* sichtbar wird.

 move.w   d0,d1                    ; neue Scrollposition
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; TEDINFO
 move.l   a5,a0                    ; tree
 bsr      scroll_tedinfo
 bra.b    mkvi_ende                ; fertig

mkvi_noscroll2:
 move.w   xte_scroll(a0),d1        ; aktuelle Scrollposition
 add.w    xte_vislen(a0),d1        ; + sichtbare Breite
 cmp.w    d1,d0                    ; Cursor zu weit rechts ?
 bls.b    mkvi_ende                ; nein, weiter
 
* Der Cursor ist rechts vom sichtbaren Bereich der Schablone. Wir
* muessen die Schablone nach links scrollen, so dass der Cursor wieder
* sichtbar wird.

 move.w   d0,d1                    ; neue Scrollposition = Cursorpos. ...
 sub.w    xte_vislen(a0),d1        ; ... - sichtbare Breite
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; TEDINFO
 move.l   a5,a0                    ; tree
 bsr      scroll_tedinfo
mkvi_ende:
 movem.l  (sp)+,a5/a4/a3
 rts
*/


**********************************************************************
*
* PUREC WORD objc_wedit(OBJECT *tree, WORD objnr,
*               WORD c, WORD *didx, WORD kind, WORD whandle)
*

objc_wedit:
 move.b   d2,-(sp)       ; d2 merken
 move.w   4+2(sp),d2     ; whandle
 lsl.w    #8,d2          ; ins Hiword
 move.b   (sp)+,d2       ; d2 ins Loword
 clr.l    -(sp)          ; kein GRECT
 bsr.b    _objc_edit
 addq.l   #4,sp
 rts


**********************************************************************
*
* PUREC WORD _objc_edit(OBJECT *tree, WORD objnr,
*               WORD c, WORD *didx, WORD kind, GRECT *g)
*
* int _objc_edit(a0 = OBJECT *tree, d0 = int objnr,
*               d1 = int c, a1 = int *didx, d2 = int kind, GRECT *g)
*
* <didx> haelt die Cursor-Position relativ zu te_ptext, d.h. ohne
* Beruecksichtigung der Schablone.
* Der Parameter <g> wird nur bei Modus 101 verwendet
*
* d2 = ED_START (0)      dummy
*      ED_CRSR  (100)    erweiterter Ersatz fuer ED_INIT
*      ED_INIT  (1)
*      ED_CHAR  (2)
*      ED_END   (3)
*      ED_DRAW  (103)    Cursor in Rechteck <g> zeichnen
*
* *didx ist Ein- und Ausgabefeld (Position des eingegebenen Zeichens
*
* Neu ab Mag!X 2.00:
*  Fuer die Fenster-Dialogroutine kann im Hiword von d2 ein
*  Fenster-Handle uebergeben werden, auf das die Ausgabe ge-clipped wird.
*  Modus 102 fuer Fenster-Redraw
*
* a5           OBJECT    *tree
* a4           int       *didx     (x-Pos des Cursors rel. zu ptext)
* a3           TEDINFO   *obspec   ob_spec unseres Objekts
* d7           int       abs_txt   phys. Textendposition
* d3           int       abs_cur   phys. Cursorposition
* d6           int       objnr
* d5           char      nodraw    Flag fuer "muss nicht neu zeichnen"
* d4           int       flag
*
*    -6(a6)    int       flags     ob_flags unseres Objekts
* [-$22(a6)]   int       v_len     Laenge von pvalid
*  -$24(a6)    int       flag
*  -$26(a6)    int       cur_pos   abs. Position des Cursors
*  -$28(a6)    int       end_pos   abs. Position des letzten ptext- Zeichens
*
* Aufbau eines TEDINFO:
*
* te_ptext     char *    reiner Text
* te_ptmplt    char *    Schablone, Eingabebereich '_'
* te_pvalid    char *    gueltige Zeichen, Laenge wie Text
* te_font      int       IBM oder SMALL
* te_just      int       TE_LEFT, TE_RIGHT, TE_CNTR
*                             ab 11.10.97: Hiword enthaelt Scroll-Offset
* te_color     int       Farbe, Modus usw.
* te_thickness int       Dicke des Randes
* te_txtlen    int       Maximallaenge des Texts
* te_tmplen    int       Laenge der Schablone (unbenutzt)
*
*
* 8.7.95:
*    valid auf Laenge von txtlen bringen, nicht auf tmplen
*
* MagiC 3:
*    Eingabefelder koennen scrollen. Die Schablone scrollt mit.
*    Dabei:
*         te_ptmplt == NULL
*         te_pvalid zeigt auf Struktur:
*              char *ptmplt;       /* Schablone */
*              char *pvalid;       /* Valid-Zeichen */
*              int  vislen;        /* sichtbare Breite der Schablone */
*              int  scroll;        /* Scrollpos (0..te_txlen-te_tmplen-1) */
*         Die tatsaechliche Breite des Eingabefelds ist
*              te_txtlen
*
* 8.9.95:
*    statisches globales Feld curr_ptext (80 Zeichen) durch Stackobjekt
*    ersetzt (256 Zeichen)
*    statisches globales Feld curr_pvalid (80 Zeichen) durch Stackobjekt
*    ersetzt (256 Zeichen)
*

_objc_edit:
 cmpi.b   #100,d2
 beq      objc_crsr
 move.l   a2,-(sp)                 ; wg PureC
 move.l   8(sp),a2                 ; GRECT *g
 cmpi.b   #103,d2
 bne.b    obed_weiter
 moveq    #3,d2                    ; wie Modus 3, aber a2 ist gueltig
 bra.b    obed_weiter2
obed_weiter:
 suba.l   a2,a2                    ; a2 ist ungueltig
obed_weiter2:
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
 suba.w   #258+258+258,sp          ; max. Laenge des Textfelds+valid+scrap
 move.l   sp,a6                    ; a6 = curr_ptext

 move.l   a2,-(sp)
 move.w   d2,-(sp)
 move.b   (sp),1(sp)
 clr.b    (sp)                     ; Hiword von d2 merken
 move.w   d1,-(sp)                 ; Zeichen c
 tst.b    d2                       ; kind == ED_START ?
 beq      edit_ende
 move.w   d0,d6                    ; d6 = objnr
 ble      edit_ende

 move.b   d2,-(sp)                 ; d2 retten

 move.l   a0,a5                    ; a5 = tree
 movea.l  a1,a4                    ; a4 = didx

**
*
* in jedem Fall: te_ptext nach curr_ptext kopieren
*
**

 move.w   d6,d0
 muls     #24,d0
 move.l   ob_spec(a5,d0.l),a3      ; a1 = ob_spec unseres Objekts
 btst     #0,ob_flags(a5,d0.l)     ; INDIRECT ?
 beq.b    obed_no_indir            ; nein
 move.l   (a3),a3
obed_no_indir:
 move.l   te_ptext(a3),a1
 move.l   a6,a0                    ; te_ptext  nach curr_ptext
strloop8:
 move.b   (a1)+,(a0)+
 bne.b    strloop8

 move.l   a6,a0
 cmpi.b   #'@',(a0)
 bne.b    obed_no_alpha
 clr.b    (a0)                     ; Mit '@' initialisiert->Leerstring
obed_no_alpha:

**
*
* in jedem Fall: te_pvalid nach curr_pvalid kopieren
*
**

 lea      258(a6),a2               ; a2 = curr_pvalid
 move.l   te_pvalid(a3),a1
 move.l   te_ptmplt(a3),d0
 bne.b    ed_noscroll5
 move.l   xte_pvalid(a1),a1
ed_noscroll5:
 move.l   a2,a0
strloop20:
 move.b   (a1)+,(a0)+
 bne.b    strloop20

 subq.l   #1,a0                    ; a0 auf das EOS
 adda.w   te_txtlen(a3),a2         ; a2 auf gewuenschtes EOS von curr_pvalid
 bra.b    obed_begloop

; Falls "pvalid" zu kurz ist, wird das letzte Zeichen solange kopiert, bis
; "pvalid" die Laenge "txtlen" hat
; "pvalid" darf nicht leer sein, sonst gibt es Muell

obed_loop:
 move.b   -2(a1),(a0)+             ; letztes Zeichen vervielfaeltigen
obed_begloop:
 cmpa.l   a2,a0                    ; Ende erreicht ?
 bcs.b    obed_loop                ; nein, weiter
 clr.b    (a0)                     ; pvalid durch EOS abschliessen

**
*
* Jetzt kommt der switch()
*
**

 move.b   (sp)+,d0                 ; kind
 bra      obed_switch              ; switch

* case 1 (ED_INIT)

obed_ed_init:
 tst.l    te_ptmplt(a3)            ; Text scrollbar ?
 bne.b    ed_noscrol3              ; nein
 moveq    #0,d1                    ; neue Scrollposition
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; TEDINFO
 move.l   a5,a0                    ; tree
 bsr      scroll_tedinfo
 move.l   a6,a0                    ; ptext
 jsr      strlen                   ; d0 = Stringlaenge
 move.l   te_pvalid(a3),a0         ; XTED
 cmp.w    xte_vislen(a0),d0        ; Stringlaenge <= sichtbare Laenge ?
 bls.b    ed_setcurpos             ; ja, OK
 moveq    #0,d0                    ; Cursor an Textanfang !!!
 bra.b    ed_setcurpos
ed_noscrol3:
 move.l   a6,a0                    ; ptext
 jsr      strlen
ed_setcurpos:
 move.w   d0,(a4)                  ; Cursor ans String- Ende
 bra      obed_draw_cursor         ; Cursor malen und Ende

* case 2 (ED_CHAR)

obed_ed_char:
 st       d5                       ; Text muss nicht neu gezeichnet werden

 move.l   a3,a0                    ; tedinfo
;move.l   a6,a6
 move.w   (a4),d0                  ; Zeichenposition
 bsr      get_curpos_txtend
 move.w   d1,d7                    ; phys. Textende
 move.w   d0,d3                    ; phys. Cursorposition

 suba.l   a2,a2
 move.w   2(sp),d2
 swap     d2                       ; Fensterhandle ins Hiword
 clr.w    d2                       ; nur Cursor malen
 move.w   d3,d1                    ; phys. Pos.
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; tedinfo
 move.l   a5,a0                    ; tree
 bsr      objc_cur_draw            ; Cursor ausschalten

 lea      objc_tab(pc),a0
objc_ltab:
 move.w   (a0)+,d0
 beq      no_ctrl                  ; nicht gefunden
 move.w   (a0)+,d1                 ; Sprung- Offset
 cmp.w    (sp),d0                  ; Zeichen gefunden ?
 bne.b    objc_ltab                ; nein, weiter
 move.l   a6,a0
 jmp      objc_tab(pc,d1.w)

objc_tab:
 DC.W     $011b,escape-objc_tab         ; Esc
 DC.W     $4737,escape-objc_tab         ; SH- Clr/Home
 DC.W     $0e08,backspace-objc_tab      ; BS
 DC.W     $4b00,curleft-objc_tab        ; Cursor links
 DC.W     $4b34,ganzlinks-objc_tab      ; SH- Cursor links
 DC.W     $7300,wordleft-objc_tab       ; CTRL- Cursor links
 DC.W     $4d00,curright-objc_tab       ; Cursor rechts
 DC.W     $4d36,ganzrechts-objc_tab     ; SH- Cursor rechts
 DC.W     $7400,wordright-objc_tab      ; CTRL- Cursor rechts
 DC.W     $4700,ganzlinks-objc_tab      ; Home
 DC.W     $3700,ganzrechts-objc_tab     ; Ende
 DC.W     $537f,delete-objc_tab         ; Del
 DC.W     $531f,del_to_eol-objc_tab     ; ^Del
 DC.W     $5200,ins_mode-objc_tab       ; Einfg
 DC.W     $5230,ovwr_mode-objc_tab      ; SH-Einfg
 DC.W     $2d18,ed_cut-objc_tab         ; ^X
 DC.W     $2e03,ed_copy-objc_tab        ; ^C
 DC.W     $2f16,ed_paste-objc_tab       ; ^V
 DC.W     0

*
* case $5200 (Einfg)
*

ins_mode:
 bclr.b   #1,config_status+3.w     ; Ueberschreibmodus aus
 bra      endswitch

*
* case $5230 (SH-Einfg)
*

ovwr_mode:
 bset.b   #1,config_status+3.w     ; Ueberschreibmodus ein
 bra      endswitch

*
* case $0e08 (Backspace):
*

backspace:
 tst.w    (a4)                     ; Cursor schon links ?
 ble      endswitch                ; ja, nichts tun
 subq.w   #1,(a4)                  ; Cursor einen nach links
 bra.b    del                      ; und wie Del

*
* case $011b (Esc)
*

escape:
 clr.b    (a0)                     ; Text loeschen
 sf       d5                       ; Text muss neu gezeichnet werden

*
* case $4700 (Home)
* case $4b34 (SH- Cursor links)
*

ganzlinks:
 clr.w    (a4)                     ; Cursor an linke Position
 bra      endswitch

*
* case $537f (Del)
*

delete:
 move.w   te_txtlen(a3),d0
 subq.w   #2,d0
 cmp.w    (a4),d0
 blt      endswitch                ; curpos > txtlen, Cursor ganz rechts
del:
 moveq    #1,d0
 move.l   a6,a0
 adda.w   (a4),a0
 tst.b    (a0)                     ; Cursor steht auf Zeichen ?
 beq      endswitch                ; nein
dlc_loop:
 move.b   1(a0),(a0)+
 bne.b    dlc_loop                 ; String umkopieren
 sf       d5                       ; Text muss neu gezeichnet werden
 bra      endswitch

*
* case $531f (^Del)
*

del_to_eol:
 adda.w   (a4),a0

 tst.b    (a0)
 beq      endswitch
 clr.b    (a0)
 sf       d5                       ; Text muss neu gezeichnet werden
 bra      endswitch

*
* case $4b00 (Cursor links)
*

curleft:
 tst.w    (a4)                     ; Position schon 0 ?
 ble      endswitch                ; ja, nichts tun
 subq.w   #1,(a4)                  ; sonst nach links gehen
 bra      endswitch

*
* case $7300 (^curleft)
*

wordleft:
* ueberspringe Blanks
wl_loop:
 move.w   (a4),d0
 beq.b    wl_loop2                 ; bin schon am Anfang
 subq.w   #1,(a4)                  ; Cursor eine Pos. nach links
 move.b   -1(a0,d0.w),d0           ; Zeichen unter Cursor
 bsr      c_is_sep                 ; ist Wort- Trenner ?
 bne.b    wl_loop                  ; ja
* ueberspringe Zeichen
wl_loop2:
 move.w   (a4),d0
 beq      wl_endloop               ; Cursor steht am Anfang!
 move.b   -1(a0,d0.w),d0           ; Zeichen links von Cursor
 bsr      c_is_sep                 ; ist Wort- Trenner ?
 bne.b    wl_endloop               ; ja
 subq.w   #1,(a4)                  ; Cursor eine Pos. nach links
 bra.b    wl_loop2
wl_endloop:
 bra      endswitch

*
* case $7400 (^curright)
*

wordright:
 jsr      strlen
 move.w   d0,d4                    ; Stringlaenge
 move.l   a6,a0                    ; Text
* ueberspringe Zeichen
wr_loop:
 move.w   (a4),d0
 move.b   0(a0,d0.w),d0            ; Zeichen unter Cursor
 bsr      c_is_sep                 ; ist Wort- Trenner ?
 bne.b    wr_loop2                 ; ja
 addq.w   #1,(a4)                  ; Cursor eine Pos. nach rechts
 cmp.w    (a4),d4
 bcc.b    wr_loop                  ; Beginn noch nicht erreicht
 subq.w   #1,(a4)
* ueberspringe Blanks
wr_loop2:
 move.w   (a4),d0
 move.b   0(a0,d0.w),d0            ; Zeichen unter Cursor
 bsr      c_is_sep                 ; ist Wort- Trenner ?
 beq.b    wr_endloop               ; nein
 addq.w   #1,(a4)                  ; Cursor eine Pos. nach rechts
 cmp.w    d0,d4
 bcc.b    wr_loop2                 ; Cursor nicht am Ende
 subq.w   #1,(a4)
wr_endloop:
 bra      endswitch

*
* case $4d36 (SH- Cursor rechts)
*

ganzrechts:
 jsr      strlen
 move.w   d0,(a4)                  ; letztmoegliche Position
 bra      endswitch

*
* case $4d00 (Cursor rechts)
*

curright:
 jsr      strlen
 cmp.w    (a4),d0
 ble      endswitch                ; Cursor noch links vom Maximum
 addq.w   #1,(a4)                  ; nach rechts gehen
 bra      endswitch

*
*
*

ed_cut:
 jsr      strlen
 tst.l    d0
 beq      endswitch
 move.l   a6,a0
 jsr      scrp_cpy                 ; nach SCRAP.TXT schreiben
 clr.b    (a6)                     ; String loeschen
 clr.w    (a4)                     ; Cursor nach links
 sf.b     d5                       ; neu zeichnen
 bra      endswitch

*
*
*

ed_copy:
 jsr      strlen
 tst.l    d0
 beq      endswitch
 move.l   a6,a0
 jsr      scrp_cpy                 ; nach SCRAP.TXT schreiben
 bra      endswitch

*
*
*

ed_paste:
 lea      258+258(a6),a0
 move.l   #256,d0
 jsr      scrp_pst                 ; Text laden
 lea      258+258(a6),a0
edp_loop:
 move.b   (a0)+,d0
 beq      endswitch
 move.l   a0,-(sp)
;move.l   a6,a6
 bsr      input_char
 move.l   (sp)+,a0
 bra.b    edp_loop

*
* default (kein Steuerzeichen):
*

no_ctrl:
 move.w   (sp),d0
;move.l   a6,a6
 bsr      input_char
;bra.b    endswitch

* ENDSWITCH

endswitch:
 move.l   a6,a1
 move.l   te_ptext(a3),a0
strloop9:
 move.b   (a1)+,(a0)+              ; Text in den Userbereich kopieren
 bne.b    strloop9

* Testen, ob bei scrollbarem Editfeld der Cursor ausserhalb
* des sichtbaren Bereichs liegt. Wenn ja, scrollen.

/*
 move.l   a4,a2                    ; WORD *curpos
 move.l   a3,a1                    ; TEDINFO
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; OBJECT *tree
 bsr      make_cursor_visible
*/

 tst.b    d5                       ; Text muss neu gezeichnet werden ?
 bne.b    obed_draw_cursor         ; nein

* Mischen und malen (ab Cursor)

/*
 lea      curr_pmerge,a2           ; dest (Mischstring)
 move.l   te_ptmplt(a3),d0         ; ptmplt
 bne.b    ed_noscroll4
 move.l   te_pvalid(a3),a0
 move.l   xte_ptmplt(a0),d0
ed_noscroll4:
 move.l   d0,a1                    ; ptmplt
 move.l   a6,a0                    ; ptext
 move.b   te_just+1(a3),d0         ; te_just
 bsr      txt_tmplt_to_merge
*/

 move.l   a3,a0                    ; tedinfo
;move.l   a6,a6
 move.w   (a4),d0
 bsr      get_curpos_txtend
 move.w   d1,d4                    ; phys. Textende

;move.w   d0,d0                    ; Cursor neu
 move.w   d3,d1                    ; Cursor alt
 jsr      min
 move.w   d0,d3                    ; Minimum merken

 move.w   d4,d0                    ; Text neu
 move.w   d7,d1                    ; Text alt
 jsr      max
 sub.w    d3,d0                    ; Breite ausrechnen

 beq.b    obed_draw_cursor         ; ist 0, nichts malen
 suba.l   a2,a2
 move.w   2(sp),d2
 swap     d2                       ; Handle ins Hiword
 move.w   d0,d2                    ; Anz. Zeichen rechts vom Cursor
 move.w   d3,d1                    ; pos (alte Cursorpos.)
                                   ; d.h. Cursor an alter Position loeschen
 move.w   d6,d0                    ; objnr
 move.l   a3,a1                    ; tedinfo
 move.l   a5,a0                    ; tree
 bsr      objc_cur_draw            ; Zeichen rechts vom Cursor malen
 bra.b    obed_draw_cursor         ; Cursor neu malen

**
*
* switch(kind)
*
**

obed_switch:
 subq.b   #1,d0
 beq      obed_ed_init             ; kind == 1
 subq.b   #1,d0
 beq      obed_ed_char             ; kind == 2
;subq.b   #1,d0
;beq.b    obed_ed_end              ; kind == 3

* case 3 (ED_END)   (Cursor aus)

obed_draw_cursor:
 move.w   (a4),d0
 move.l   a3,a0                    ; tedinfo
 bsr      txtpos_to_tmpltpos

 move.l   4(sp),a2                 ; GRECT * oder NULL
 move.w   2(sp),d2
 swap     d2                       ; Handle ins Hiword
 clr.w    d2                       ; nur Cursor
 move.w   d0,d1                    ; pos
 move.w   d6,d0                    ; objnr
 move.l   a3,a1
 move.l   a5,a0                    ; tree
 bsr      objc_cur_draw

edit_ende:
 moveq    #1,d0
 addq.l   #8,sp                    ; d1 und d2 und a2 abbauen
 adda.w   #258+258+258,sp          ; lokale Variable abbauen
 movem.l  (sp)+,d3/d4/d5/d6/d7/a3/a4/a5/a6
 move.l   (sp)+,a2                 ; wg. PureC
 rts


**********************************************************************
*
* void txt_tmplt_to_merge(d0 = char just, a0 = char *txt,
*                         a1 = char *tmplt, a2 = char *dest)
*
* Mischt fuer F(BOX)TEXT Schablone und Text
* Die Laenge von <tmplt> bestimmt die Laenge von <dest>
*

txt_tmplt_to_merge:
 cmpi.b   #'@',(a0)                ; erstes Zeichen '@' ?
 bne.b    ttm_nodummy              ; nein
 lea      null_s(pc),a0            ; ja, txt ist leer
ttm_nodummy:
 subq.b   #TE_RIGHT,d0
 beq.b    ttm_rueckwaerts
ttm_vloop:
 move.b   (a1)+,d0                 ; Zeichen von tmplt
 cmpi.b   #'_',d0
 bne.b    ttm_vtmplt               ; kein Unterstrich, *tmplt kopieren
 tst.b    (a0)                     ; Zeichen von text
 beq.b    ttm_vtmplt               ; ist leer, tmplt kopieren
 move.b   (a0)+,d0                 ; *txt kopieren
ttm_vtmplt:
 move.b   d0,(a2)+
 bne.b    ttm_vloop
ttm_ende:
 clr.b    (a2)                     ; EOS von <dest> setzen
 rts

ttm_rueckwaerts:
 movem.l  a4/a5,-(sp)
 move.l   a0,a4                    ; a4 = Stringanfang von txt
 move.l   a1,a5                    ; a5 = Stringanfang von tmplt
ttm_rsloop1:
 tst.b    (a0)+
 bne.b    ttm_rsloop1
 subq.l   #1,a0                    ; a0 auf das EOS von txt
ttm_rsloop2:
 addq.l   #1,a2
 tst.b    (a1)+
 bne.b    ttm_rsloop2              ; a1 hinter das EOS von tmplt, a2 von dest
ttm_rloop:
 move.b   -(a1),d0                 ; Zeichen von tmplt
 cmpi.b   #'_',d0
 bne.b    ttm_rtmplt               ; kein Unterstrich, *tmplt kopieren
 cmpa.l   a4,a0                    ; Anfang von text ?
 bls.b    ttm_rtmplt               ; ist leer, tmplt kopieren
 move.b   -(a0),d0                 ; *txt kopieren
ttm_rtmplt:
 move.b   d0,-(a2)
 cmpa.l   a5,a1
 bhi.b    ttm_rloop
 movem.l  (sp)+,a4/a5
 rts


**********************************************************************
*
* int do_userdef(OBJECT *tree, int objnr, GRECT *g, USERBLK *u,
*                int prevstate, int currstate)
*

do_userdef:
 lea      4(sp),a0
 suba.w   #30,sp                   ; sizeof(PARMBLK)
 lea      (sp),a1
 move.l   (a0)+,(a1)+              ; pb_tree
 move.w   (a0)+,(a1)+              ; pb_obj
 move.l   (a0)+,a2                 ; g
 move.l   (a0)+,d0                 ; u

 move.l   (a0),(a1)+               ; pb_prevstate,pb_currstate
 move.l   (a2)+,(a1)+              ; pb_x,pb_y
 move.l   (a2),(a1)+               ; pb_w,pb_h
 move.l   a1,a0
 bsr      get_clip_grect           ; pb_xc,pb_yc,pb_wc,pb_hc
 addq.w   #8,a1
 move.l   d0,a0                    ; u
 move.l   (a0)+,a2                 ; ub_code
 move.l   (a0),(a1)                ; ub_parm
 pea      (sp)
 jsr      (a2)
 adda.w   #34,sp
 rts


**********************************************************************
*
* int unpack_objc(a0 = OBJECT *tree, d0 = int ob)
*   a0    = OBJECT *tree
*   d0    = int ob
*
* Rueckgabe: Rahmendicke in d0
*           ob_type-20  in d1 (negativ bei Fehler)
*           OBJECT *    in a0
*           ob_spec     in a1
*
* aendert nicht a2
*

unpack_objc:
 moveq    #0,d2                    ; Hiword loeschen
 move.w   d0,d2                    ; Objektnummer
 lsl.l    #3,d2
 add.l    d2,a0
 add.l    d2,a0
 add.l    d2,a0                    ; a0 = OBJECT *

**********************************************************************
*
* int _unpack_objc(a0 = OBJECT *ob)
*

_unpack_objc:
 moveq    #0,d1
 move.b   ob_type+1(a0),d1         ; d1 = (char) ob_type
 move.w   ob_flags(a0),d2          ; d2 = ob_flags

 move.l   ob_spec(a0),a1           ; a1 = ob_spec
 btst     #8,d2                    ; INDIRECT ?
 beq.b    unpk_direct
 move.l   (a1),a1                  ; INDIRECT
unpk_direct:
 subi.w   #20,d1
 cmpi.w   #NOBTYPES-1,d1
 bhi.b    unpk_err
 move.b   ob_modes(pc,d1.w),d0
 ext.w    d0
 bge.b    unpk_endsw
 addq.w   #1,d0
 bne.b    unpk_l1
* ob_modes war -1: TEDINFO holen
 move.b   te_thickness+1(a1),d0
 ext.w    d0
 rts
unpk_l1:
 addq.w   #1,d0
 bne.b    unpk_l2
* ob_modes war -2: aus ob_spec holen
 move.l   a1,d0
 swap     d0
 ext.w    d0
 rts
* ob_modes war -3: aus ob_flags holen (G_BUTTON)
unpk_l2:
 cmpi.b   #6,d1
 bne.b    unpk_flg                 ; nicht BUTTON
 btst     #6,ob_state+1(a0)
 beq.b    unpk_flg
 moveq    #0,d0
 btst     #15,ob_state(a0)
 bne      unpk_endsw               ; WHITEBAK => bei Sonderbuttons kein Rand
unpk_flg:
 moveq    #-1,d0                   ; Rahmen: 1 Pixel ausserhalb des Objekts
 btst     #2,d2                    ; EXIT ?
 beq.b    unpk_noex
 subq.w   #1,d0                    ; 2 Pixel ausserhalb des Objekts
unpk_noex:
 btst     #1,d2                    ; DEFAULT ?
 beq.b    unpk_endsw
 subq.w   #1,d0                    ; 3 Pixel ausserhalb des Objekts

unpk_endsw:
;move.l   a1,a1
;move.l   a0,a0
;move.w   d1,d1
;move.w   d0,d0                    ; Rahmendicke zurueck
 rts
unpk_err:
 moveq    #0,d0
 moveq    #-1,d1                   ; ungueltiger Objekttyp
 bra.b    unpk_endsw

* Rahmendicken fuer Objekte: 0=0,1=1,-1=TEDINFO holen,-2=ob_spec holen,
* -3 = Flags holen

ob_modes:
 DC.B     -2        ; G_BOX        (ob_spec)
 DC.B     -1        ; G_TEXT       (TEDINFO)
 DC.B     -1        ; G_BOXTEXT    (sonder oder TEDINFO)
 DC.B     0         ; G_IMAGE
 DC.B     0         ; G_USERDEF
 DC.B     -2        ; G_IBOX       (ob_spec)
 DC.B     -3        ; G_BUTTON     (flags)
 DC.B     -2        ; G_BOXCHAR    (ob_spec)
 DC.B     0         ; G_STRING
 DC.B     -1        ; G_FTEXT      (TEDINFO)
 DC.B     -1        ; G_FBOXTEXT   (TEDINFO)
 DC.B     0         ; G_ICON
 DC.B     1         ; G_TITLE
 DC.B     0         ; G_CICON
 DC.B     -3        ; G_SWBUTTON   (flags)
 DC.B     -3        ; G_POPUP      (flags)
 DC.B     -1        ; G_WINTITLE   (TEDINFO)
 DC.B     0         ; G_EDIT
 DC.B     0         ; G_SHORTCUT

     EVEN

/*
**********************************************************************
*
* void walk_obj_tree(OBJECT *tree, int firstob, int lastob,
*                    void (*pgm(OBJECT *tree, int objnr, int x, int y)),
*                    int offsx, int offsy, int maxdepth)
*
*   8(a6) = OBJECT *tree
*  $c(a6) = int firstob
*  $e(a6) = int lastob
* $10(a6) = pgm
* $14(a6) = offsx
* $16(a6) = offsy
* $18(a6) = maxdepth
*
* Bei jedem Eintritt in eine neue Ebene wird <pgm> aufgerufen, und zwar
* mit den absoluten x- und y- Werten. Es wird angenommen, dass das
* Wurzelobjekt bei offsx und offsy auf dem Bildschirm liegt.
* Es werden maximal <maxdepth> Objekte der Nummern <firstobjnr> bis
* <lastobjnr> durchlaufen.
*

YTAB SET  -(4*MAXDEPTH)
XTAB SET  -(2*MAXDEPTH)

walk_obj_tree:
 link     a6,#YTAB
 movem.l  d4/d5/d6/d7/a3/a4/a5,-(sp)
 lea      8(a6),a0                 ; Zeiger auf Parameter
 move.l   (a0)+,a5                 ; tree
 move.w   (a0)+,d7                 ; erstes Objekt
 move.w   (a0)+,d5                 ; letztes Objekt
 move.l   (a0)+,a3                 ; pgm
 move.w   (a0)+,XTAB(a6)           ; offsx
 move.w   (a0)+,YTAB(a6)           ; offsy
 move.w   (a0),d4
 add.w    d4,d4                    ; maxdepth fuer int- Zugriff
 moveq    #2,d6                    ; Zaehler auf 1 (fuer int- Zugriff)
* Durchlaufe Schleife, bis letztes Element erreicht
walk_loop:
 cmp.w    d5,d7                    ; aktuelles == letztes Element ?
 beq      walk_end                 ; ja, Ende

 moveq    #0,d0                    ; Hiword loeschen
 move.w   d7,d0
 lsl.l    #3,d0
 move.l   a5,a4
 add.l    d0,a4
 add.l    d0,a4
 add.l    d0,a4                    ; a4 auf OBJECT

walk_loop_tiny:
 lea      YTAB-2(a6,d6.w),a0
 move.w   (a0)+,d0                 ; ykoor[d6-1]
 add.w    ob_y(a4),d0
 move.w   d0,(a0)                  ; ykoor[d6]
 move.w   d0,-(sp)                 ; y als Parameter uebergeben

 lea      XTAB-2(a6,d6.w),a0
 move.w   (a0)+,d0                 ; xkoor[d6-1]
 add.w    ob_x(a4),d0
 move.w   d0,(a0)                  ; xkoor[d6]
 move.w   d0,-(sp)                 ; x als Parameter uebergeben

 move.w   d7,-(sp)                 ; aktuelle Objektnummer
 move.l   a5,-(sp)                 ; tree
 jsr      (a3)                     ; Routine aufrufen
 adda.w   #10,sp

 move.w   ob_head(a4),d1           ; d1 = ob_head
 cmp.w    #-1,d1
 beq.b    walk_loop2               ; hat keine Kinder

* d7 hat d1 als erstes Kind

 btst     #7,ob_flags+1(a4)        ; HIDETREE ?
 bne.b    walk_loop2               ; ja
 cmp.w    d4,d6                    ; maximale Tiefe erreicht ?
 bhi.b    walk_loop2

* Eine Ebene weiter gehen

 addq.w   #2,d6                    ; Zaehler erhoehen (2 wegen int- Zugriff)
 move.w   d1,d7                    ; erstes Kind betrachten
 bra      walk_loop                ; -> loop

* d7 hat keine Kinder, oder ist HIDETREE, oder maximale Tiefe erreicht

walk_loop2:
 move.w   d7,d1                    ; Root erreicht ? (vorheriges Obj. retten)
 beq.b    walk_end                 ; ja, Ende
 move.w   ob_next(a4),d7           ; d7 = ob_next
 cmp.w    d5,d7                    ; Endobjekt erreicht ?
 beq.b    walk_end                 ; ja, Ende
 moveq    #0,d0                    ; Hiword loeschen
 move.w   d7,d0
 lsl.l    #3,d0
 move.l   a5,a4
 add.l    d0,a4
 add.l    d0,a4
 add.l    d0,a4                    ; OBJECT aktualisieren
 cmp.w    ob_tail(a4),d1           ; akt. Objekt == ob_tail(ob_next) ?
 bne      walk_loop_tiny           ; nein, naechstes Objekt

* Ende der Ebene erreicht, eine Stufe zurueckgehen

 subq.w   #2,d6                    ; Zaehler dekrementieren (wegen int)
 bgt.b    walk_loop2               ; Objekt ueberspringen (schon bearbeitet)
walk_end:
 movem.l  (sp)+,d4/d5/d6/d7/a5/a4/a3
 unlk     a6
 rts
*/


**********************************************************************
*
* int parentob(a0 = OBJECT *tree, d0 = int startob)
*
* Rueckgabe : bleibt haengen, wenn Objekt bereits Wurzelobjekt ist
* sonst    : Nummer des Elterobjekts
*
* veraendert d2,d1
*

parentob:
 move.w   d0,d2
 muls     #24,d2
parob_loop:
 move.w   d0,d1                    ; d1 = vorheriges Objekt
 move.w   0(a0,d2.l),d0            ; d0 = naechstes Objekt
 move.w   d0,d2
 muls     #24,d2
 cmp.w    ob_tail(a0,d2.l),d1      ; tail ist vorheriges ?
 bne.b    parob_loop
parob_ende:
 rts


**********************************************************************
*
* void split_menu_entry(a0 = char *me)
*
* Zerlegt einen Menue-Eintrag
*
* => a0 =      Zeiger auf rechtsbuendigen Teilstring oder NULL
* => d0 = WORD Anzahl rechtsbuendiger Leerzeichen
*

split_menu_entry:
 moveq    #' ',d1
sme_loop0:
 cmp.b    (a0)+,d1            ; fuehrende Leerzeichen ueberlesen
 beq.b    sme_loop0
 subq.l   #1,a0
 move.l   a0,a1
sme_loop1:
 tst.b    (a1)+
 bne.b    sme_loop1
 subq.l   #1,a1               ; a1 zeigt jetzt aufs EOS
 moveq    #-1,d0
sme_loop2:
 addq.w   #1,d0               ; Anzahl Leerzeichen mitzaehlen
 cmpa.l   a0,a1
 bls.b    sme_err
 cmp.b    -(a1),d1
 beq.b    sme_loop2           ; rechtsb. Leerzeichen
sme_loop3:
 cmpa.l   a0,a1
 bls.b    sme_err
 cmp.b    -(a1),d1
 bne.b    sme_loop3           ; gueltige Zeichen
 addq.l   #1,a1
 move.b   (a1),d1
 cmpi.b   #'^',d1             ; fuer Ctrl
 beq.b    sme_ok
 cmpi.b   #7,d1               ; fuer Alt (Maximalgroessenfeld)
 beq.b    sme_ok
 cmpi.b   #1,d1               ; fuer Shift (Pfeil hoch)
 beq.b    sme_ok
 cmpi.b   #3,d1               ; fuer Submenue (Pfeil rechts)
 beq.b    sme_ok
 cmpi.b   #' ',-2(a1)         ; mind. zwei Leerzeichen ?
 bne.b    sme_err
 andi.b   #$5f,d1             ; Grossschrift
 cmpi.b   #'I',d1             ; INSERT ?
 beq.b    sme_ok
 cmpi.b   #'D',d1             ; DELETE
 beq.b    sme_ok
 cmpi.b   #'U',d1             ; UNDO
 beq.b    sme_ok
 cmpi.b   #'H',d1             ; HELP,HOME
 beq.b    sme_ok
 cmpi.b   #'R',d1             ; Return
 beq.b    sme_ok
 cmpi.b   #'S',d1             ; SPACE
 beq.b    sme_ok
 cmpi.b   #'T',d1             ; Tab
 beq.b    sme_ok
 cmpi.b   #'F',d1             ; Fn
 beq.b    sme_ok
 cmpi.b   #'E',d1             ; Esc
 bne.b    sme_err
 move.b   1(a1),d1
 andi.b   #$5f,d1
 cmpi.b   #'S',d1
 beq.b    sme_ok
sme_err:
 suba.l   a0,a0
 rts
sme_ok:
 move.l   a1,a0
 rts


**********************************************************************
*
* void stw_title( a0 = OBJECT *ob )
*
* Legt die Breite eines Objekts vom Typ G_TITLE fest.
* Wird beim Einschalten eines Menues aufgerufen
*

stw_title:
 move.l   a5,-(sp)
 move.l   a0,a5
 cmpi.b   #G_TITLE,ob_type+1(a5)
 bne.b    stwt_ende
 move.l   ob_spec(a5),a0           ; char *string
 btst     #0,ob_flags(a5)          ; INDIRECT ?
 beq.b    stwt_no_indir            ; nein
 move.l   (a0),a0
stwt_no_indir:
; fuehrende Leerstellen entfernen
 moveq    #' ',d1
stwt_loop1:
 cmp.b    (a0)+,d1
 beq.b    stwt_loop1
 subq.l   #1,a0
 move.l   a0,-(sp)
 bsr      str_to_ints
 move.l   (sp)+,a1
 lea      0(a1,d0.w),a0            ; a0 aufs String-Ende
 moveq    #' ',d1
stwt_loop2:
 cmpa.l   a1,a0
 bls.b    stwt_endloop2
 cmp.b    -(a0),d1
 beq.b    stwt_loop2
 addq.l   #1,a0
stwt_endloop2:
 suba.l   a1,a0
 move.w   a0,vintin_len            ; rechtsb. Leerstellen entfernen
 moveq    #IBM,d0
 bsr      setfont
 move.w   vintin_len,d0
 bsr      extent
 add.w    big_wchar,d0
 add.w    big_wchar,d0
 move.w   d0,ob_width(a5)
stwt_ende:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void calc_ftext(a0 = char *tmplt, d0 = WORD len, a1 = TEDINFO *te,
*                   a2 = void *data)
*
* Berechnet die Positionen und Ausmasse der drei Komponenten eines
* F(BOX)TEXT-Objekts:
*
* - Fester Bestandteil der Schablone (Anfang)
* - Eingabebereich
* - Fester Bestandteil der Schablone (Ende)
*
* Eingabe:     len                 sichtbare Objektbreite in
*                                   RSC-Einheiten oder -1, wenn
*                                   ganze Schablonenbreite
*              GRECT data.g        Objektposition (x,y,w,h)
*              tmplt               Eingabe-Schablone
* Ausgabe:     GRECT data.g   0    Ausmasse des Textes (x,y,w,h)
*              WORD n1        8    Anzahl Zeichen des Anfangs
*              WORD w1        10   Breite des Anfangs in Pixeln
*              WORD n2        12   Anzahl Zeichen des Eingabefelds
*              WORD w2        14   Breite des Eingabefelds in Pixeln
*              WORD n3        16   Anzahl Zeichen des Endes
*              WORD w3        18   Breite des Endes in Pixeln
*

calc_ftext:
 movem.l  d3/d6/a3/a4/a5,-(sp)
 move.l   a2,a4                    ; a4 = data
 move.l   a0,a5                    ; a5 = tmplt
 move.l   a1,a3                    ; a3 = te
 move.w   d0,d6                    ; d6 = sichtbare Breite
 bge.b    cft_is
;move.l   a0,a0
 jsr      strlen
 move.w   d0,d6                    ; ganze Objektbreite

cft_is:
 move.w   big_wchar,d3             ; Zeichenbreite gross
 move.w   te_font(a3),d0
 cmpi.w   #IBM,d0
 beq.b    cft_ibm
 moveq    #6,d3                    ; Zeichenbreite klein
cft_ibm:

; justieren, dabei Textbreite vorgeben

 move.l   g_w(a4),-(sp)
 move.l   g_x(a4),-(sp)            ; Kopie
 move.l   a4,a1                    ; outg
 move.l   sp,a0                    ; ing
 move.b   te_just+1(a3),d1
;move.w   d0,d0                    ; te_font
 move.w   d6,d2
 mulu     d3,d2                    ; Breite vorgeben
 bsr      tjust
 addq.l   #8,sp                    ; Kopie wegwerfen

; links vom Eingabefeld

 move.l   a5,a0
cft_loop:
 tst.b    (a0)
 beq.b    cft_el1
 cmpi.b   #'_',(a0)+
 bne.b    cft_loop
 subq.l   #1,a0
cft_el1:
 move.l   a0,a1
 suba.l   a5,a0
 move.w   a0,8(a4)                 ; Anzahl Zeichen des Anfangs
 move.w   a0,d0
 mulu     d3,d0
 move.w   d0,10(a4)                ; Breite des Anfangs

; rechts vom letzten Eingabefeld: hinter das letzte '_'

 move.l   a1,a2                    ; Anfang des Eingabefelds merken
 move.l   a1,a0
cft_loop2:
 tst.b    (a1)
 beq.b    cft_el2
 cmpi.b   #'_',(a1)+
 bne.b    cft_loop2
 move.l   a1,a0                    ; Zeiger hinter das '_' merken
 bra.b    cft_loop2
cft_el2:
 move.l   a0,a1
 suba.l   a2,a1
 move.w   a1,12(a4)                ; Laenge des Eingabefeldes

;move.l   a0,a0
 jsr      strlen
 move.w   d0,16(a4)                ; Laenge des rechten Schablonenteils
 move.w   d6,d1                    ; sichtbare Gesamtbreite
 sub.w    8(a4),d1                 ; - Anzahl Zeichen des Anfangs
 sub.w    d0,d1                    ; - Anzahl Zeichen des Endes
 mulu     d3,d1
 move.w   d1,14(a4)                ; Breite des Eingabefelds
 mulu     d3,d0
 move.w   d0,18(a4)                ; Breite des Endes
 movem.l  (sp)+,d3/d6/a3/a4/a5
 rts


**********************************************************************
*
* void split_tecolor(d0 = int color, a0 = int codes[5])
*
* Wertet "te_color" aus: code[0]: innenfarbe     Bits  0..3
*                        code[1]: pattern        Bits  4..6
*                        code[2]: wmode          Bit 7 (1=REPL,2=TRANS)
*                        code[3]: textfarbe      Bits  8..11
*                        code[4]: rahmenfarbe    Bits 12..15
*

split_tecolor:
 move.w   d0,d1
 lsr.w    #4,d0
 andi.w   #$f,d1
 move.w   d1,(a0)+                 ; Innenfarbe (Bits 0..3)

 move.w   d0,d1
 andi.w   #7,d1
 move.w   d1,(a0)+                 ; Pattern (Bits 4..6)

 moveq    #REPLACE,d1
 btst     #3,d0
 bne.b    sptc_repl
 moveq    #TRANSPARENT,d1
sptc_repl:
 move.w   d1,(a0)+                 ; REPLACE bzw. TRANSPARENT
 lsr.w    #4,d0

 move.w   d0,d1
 lsr.w    #4,d0
 andi.w   #$f,d1
 move.w   d1,(a0)+                 ; Textfarbe (Bits 8..11)

 move.w   d0,(a0)                  ; Rahmenfarbe (Bits 12..15)
 rts

* Daten fuer runde Buttons
* 2D-Modus (schwarz)

rbut_g:
 DC.W     0                        ; 1 Plane
 DC.W     REPLACE
 DC.W     14                       ; Hoehe 14 Pixel
 DC.W     16                       ; Breite 16 Pixel
 DC.W     BLACK                    ; Farbe
 DC.W     %0000011110000000
 DC.W     %0001100001100000
 DC.W     %0010000000010000
 DC.W     %0100000000001000
 DC.W     %0100000000001000
 DC.W     %1000000000000100
 DC.W     %1000000000000100
 DC.W     %1000000000000100
 DC.W     %1000000000000100
 DC.W     %0100000000001000
 DC.W     %0100000000001000
 DC.W     %0010000000010000
 DC.W     %0001100001100000
 DC.W     %0000011110000000
rbut_gs:
 DC.W     %0000011110000000
 DC.W     %0001100001100000
 DC.W     %0010000000010000
 DC.W     %0100011110001000
 DC.W     %0100111111001000
 DC.W     %1001111111100100
 DC.W     %1001111111100100
 DC.W     %1001111111100100
 DC.W     %1001111111100100
 DC.W     %0100111111001000
 DC.W     %0100011110001000
 DC.W     %0010000000010000
 DC.W     %0001100001100000
 DC.W     %0000011110000000
rbut_m:
 DC.W     0                        ; 1 Plane
 DC.W     REPLACE
 DC.W     7                        ; Hoehe 7 Pixel
 DC.W     16                       ; Breite 16 Pixel
 DC.W     BLACK                    ; Farbe
 DC.W     %0000111111000000
 DC.W     %0011000000110000
 DC.W     %0100000000001000
 DC.W     %1000000000000100
 DC.W     %0100000000001000
 DC.W     %0011000000110000
 DC.W     %0000111111000000
rbut_ms:
 DC.W     %0000111111000000
 DC.W     %0011000000110000
 DC.W     %0100011110001000
 DC.W     %1000111111000100
 DC.W     %0100011110001000
 DC.W     %0011000000110000
 DC.W     %0000111111000000
rbut_k:
 DC.W     0                        ; 1 Plane
 DC.W     REPLACE
 DC.W     7                        ; Hoehe 7 Pixel
 DC.W     8                        ; Breite 8 Pixel
 DC.W     BLACK                    ; Farbe
 DC.W     %0011100000000000
 DC.W     %0100010000000000
 DC.W     %1000001000000000
 DC.W     %1000001000000000
 DC.W     %1000001000000000
 DC.W     %0100010000000000
 DC.W     %0011100000000000
rbut_ks:
 DC.W     %0011100000000000
 DC.W     %0100010000000000
 DC.W     %1001001000000000
 DC.W     %1011101000000000
 DC.W     %1001001000000000
 DC.W     %0100010000000000
 DC.W     %0011100000000000

* 3D- Icon (s=schwarz/h=hellgrau/g=dklgrau/w=weiss)

* deselektiert:
*           00000gggg0000000
*           000ggwwwwgg00000
*           00gwwwhhhhws0000
*           0gwwhhhhhhhgs000
*           0gwhhhhhhhhhs000
*           gwwhhhhhhhhhgs00
*           gwhhhhhhhhhhgs00
*           gwhhhhhhhhhhgs00
*           gwhhhhhhhhhggs00
*           0ghhhhhhhhhgs000
*           0gwhhhhhhhggs000
*           00sghhhhgggs0000
*           000ssggggss00000
*           00000ssss0000000

* selektiert:
*           00000ssss0000000
*           000ssggggss00000
*           00sggghhhhgs0000
*           0sgg0000000wg000
*           0sg00gssg000g000
*           sgg0gssssg00wg00
*           sg00ssssss00wg00
*           sg00ssssss00wg00
*           sg00gssssg0wwg00
*           0s000gssg00wg000
*           0sg0000000wwg000
*           00sw0000wwwg0000
*           000ggwwwwgg00000
*           00000gggg0000000

* 3D-Modus (schwarz)

rbut_3d:
 DC.W     3                        ; 4 Planes
 DC.W     TRANSPARENT
 DC.W     14                       ; Hoehe 14 Pixel
 DC.W     16                       ; Breite 16 Pixel
 DC.W     BLACK                    ; Farbe
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000010000
 DC.W     %0000000000001000
 DC.W     %0000000000001000
 DC.W     %0000000000000100
 DC.W     %0000000000000100
 DC.W     %0000000000000100
 DC.W     %0000000000000100
 DC.W     %0000000000001000
 DC.W     %0000000000001000
 DC.W     %0010000000010000
 DC.W     %0001100001100000
 DC.W     %0000011110000000

 DC.W     %0000011110000000
 DC.W     %0001100001100000
 DC.W     %0010000000010000
 DC.W     %0100000000000000
 DC.W     %0100001100000000
 DC.W     %1000011110000000
 DC.W     %1000111111000000
 DC.W     %1000111111000000
 DC.W     %1000011110000000
 DC.W     %0100001100000000
 DC.W     %0100000000000000
 DC.W     %0010000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000

 DC.W     LBLACK                        ; Farbe dunkelgrau
 DC.W     %0000011110000000
 DC.W     %0001100001100000
 DC.W     %0010000000000000
 DC.W     %0100000000010000
 DC.W     %0100000000000000
 DC.W     %1000000000001000
 DC.W     %1000000000001000
 DC.W     %1000000000001000
 DC.W     %1000000000011000
 DC.W     %0100000000010000
 DC.W     %0100000000110000
 DC.W     %0001000011100000
 DC.W     %0000011110000000
 DC.W     %0000000000000000

 DC.W     %0000000000000000
 DC.W     %0000011110000000
 DC.W     %0001110000100000
 DC.W     %0011000000001000
 DC.W     %0010010010001000
 DC.W     %0110100001000100
 DC.W     %0100000000000100
 DC.W     %0100000000000100
 DC.W     %0100100001000100
 DC.W     %0000010010001000
 DC.W     %0010000000001000
 DC.W     %0000000000010000
 DC.W     %0001100001100000
 DC.W     %0000011110000000

 DC.W     WHITE
 DC.W     %0000000000000000
 DC.W     %0000011110000000
 DC.W     %0001110000100000
 DC.W     %0011000000000000
 DC.W     %0010000000000000
 DC.W     %0110000000000000
 DC.W     %0100000000000000
 DC.W     %0100000000000000
 DC.W     %0100000000000000
 DC.W     %0000000000000000
 DC.W     %0010000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000

 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000000000010000
 DC.W     %0000000000000000
 DC.W     %0000000000001000
 DC.W     %0000000000001000
 DC.W     %0000000000001000
 DC.W     %0000000000011000
 DC.W     %0000000000010000
 DC.W     %0000000000110000
 DC.W     %0001000011100000

 DC.W     %0000011110000000
 DC.W     %0000000000000000

 DC.W     LWHITE                   ; hellgrau
 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000001111000000
 DC.W     %0000111111100000
 DC.W     %0001111111110000
 DC.W     %0001111111110000
 DC.W     %0011111111110000
 DC.W     %0011111111110000
 DC.W     %0011111111100000
 DC.W     %0011111111100000
 DC.W     %0001111111000000
 DC.W     %0000111100000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000

 DC.W     %0000000000000000
 DC.W     %0000000000000000
 DC.W     %0000001111000000
 DC.W     %0000111111100000
 DC.W     %0001100001110000
 DC.W     %0001000000110000
 DC.W     %0011000000110000
 DC.W     %0011000000110000
 DC.W     %0011000000100000
 DC.W     %0011100001100000
 DC.W     %0001111111000000
 DC.W     %0000111100000000
 DC.W     %0000000000000000
 DC.W     %0000000000000000



**********************************************************************
*
* void _obd_rbutton( d0 = int ob_state, a0 = GRECT *g,
*                    d1 = char flag_3d )
*

_obd_rbutton:
 movem.l  d3/d4/d5/d6/d7/a4/a5,-(sp)
 move.w   d0,d6
 move.l   a0,a4

 lea      rbut_m(pc),a5            ; ST Mittel
 move.w   work_out+6,d2
 add.w    d2,d2                    ; 2 * Pixelbreite
 cmp.w    work_out+8,d2
 bls.b    _obdr_rbt                ; 2 * Pixelbreite <= Pixelhoehe
 lea      rbut_k(pc),a5
 cmpi.w   #16,gr_hhbox
 bcs.b    _obdr_rbt
 lea      rbut_g(pc),a5
 tst.b    d1
 beq.b    _obdr_rbt
 lea      rbut_3d(pc),a5           ; 3D
_obdr_rbt:

 move.w   (a5)+,d7                 ; d7 = Anz. Planes - 1
 move.w   (a5)+,d3                 ; d3 = Schreibmodus
 move.w   (a5)+,d5                 ; d5 = Hoehe in Pixeln
 move.w   (a5)+,d4                 ; d4 = Breite in Pixeln
_obdr_rloop:
 clr.w    -(sp)
 move.w   (a5)+,-(sp)              ; Farbe
 move.w   d3,-(sp)                 ; Schreibmodus
 move.w   d5,-(sp)                 ; Hoehe in Pixelzeilen
 move.w   d4,-(sp)                 ; Breite in Pixeln
 subq.l   #2,sp                    ; Dummy fuer Zielbreite (autom. Bildsch.)
 move.l   (a4),-(sp)               ; Zielposition:  ob_x,ob_y ohne Rand
 move.w   g_h(a4),d2
 sub.w    d5,d2
 ble.b    _obdr_3dnth2
 lsr.w    #1,d2
 add.w    d2,g_y(sp)               ; vertikal zentrieren
_obdr_3dnth2:
 clr.l    -(sp)                    ; Ziel: Bildschirm
 move.w   #2,-(sp)                 ; Quellbreite in Bytes
 clr.l    -(sp)                    ; Quellposition: bi_x,bi_y
 move.l   a5,a1
 btst     #0,d6                    ; SELECTED ?
 beq.b    _obdr_3dtns2
; ausgefuellt bei Selektierung
 add.w    d5,a1
 add.w    d5,a1
_obdr_3dtns2:
 pea      (a1)                     ; Quelldaten
 bsr      draw_bitblk
 lea      30(sp),sp
 add.w    d5,a5
 add.w    d5,a5
 add.w    d5,a5
 add.w    d5,a5
 dbra     d7,_obdr_rloop
 movem.l  (sp)+,d3/d4/d5/d6/d7/a4/a5
 rts


*********************************************************************
*
* void drw_cross( a0 = GRECT *g, d0 = int DRAWMODE, d1 = int col )
*
* Das Kreuz wird in das Rechteck reingelegt.
*

drw_cross:
 move.l   4(a0),-(sp)
 move.l   (a0),-(sp)
;move.w   d1,d1                    ; Rahmenfarbe
;move.w   d0,d0                    ; Schreibmodus
 bsr      stwmod_pcolor            ; Polylinefarbe setzen
 move.l   sp,a0
 move.w   (a0),d0
 addq.w   #1,(a0)+                 ; x1 = x+1
 move.w   (a0),d1
 addq.w   #1,(a0)+                 ; y1 = y+1
 subq.w   #2,d0
 add.w    d0,(a0)+                 ; x2 = x+w-2
 subq.w   #2,d1
 add.w    d1,(a0)                  ; y2 = y+h-2
 bsr      draw_line
 move.w   2(sp),d0
 move.w   6(sp),2(sp)
 move.w   d0,6(sp)                 ; y1/y2 vertauschen
 bsr      draw_line
 addq.l   #8,sp
 rts


*********************************************************************
*
* void _obd_crossbutton( d0 = int selected, a0 = GRECT *g,
*                        d1 = int flag_3d )
*
* ist d0 & 0x8000 == 1, kommt der Aufruf von _objc_change().
* d0 & 1 ist der Selected- Status
*

_obd_crossbutton:
 move.w   d0,-(sp)                 ; d0 merken
 move.w   d1,-(sp)                 ; 3D-Flag merken

; Box berechnen (muss quadratisch sein)

 move.w   big_hchar,d0
 subq.w   #2,d0
 btst     #0,d0
 bne.b    dcr_odd
 addq.w   #1,d0                    ; Hoehe muss ungerade sein!
dcr_odd:
 move.w   d0,-(sp)                 ; h
 bsr      calc_quadr               ; erhaelt a0
 move.w   d0,-(sp)                 ; w
 move.l   g_x(a0),-(sp)            ; x,y
 move.w   g_h(a0),d0
 sub.w    g_h(sp),d0
 ble.b    _obdc_nth
 lsr.w    #1,d0
 add.w    d0,g_y(sp)               ; vertikal zentrieren
_obdc_nth:

; Box selbst ausgeben (MagiC 5.10, Objekt war vorher hohl)

/*
 tst.w    10(sp)                   ; komme von objc_change() ?
 bmi.b    _obdc_nobox              ; ja, Box nicht zeichnen
*/
 moveq    #WHITE,d1
 moveq    #IP_SOLID,d2             ; => Hellgrau und IP_SOLID
 tst.b    8(sp)                    ; 3D ?
 beq.b    _obdc_whitebox           ; nein
 moveq    #LWHITE,d1
_obdc_whitebox:
 lea      (sp),a0                  ; GRECT *
 moveq    #REPLACE,d0
 bsr      drawbox                  ; Box malen

_obdc_nobox:
 tst.w    8(sp)                    ; 3D ?
 beq.b    _obdc_2d

; 3D
 move.w   10(sp),d1                ; selected
 moveq    #1,d0                    ; Rahmendicke
 lea      (sp),a0                  ; GRECT
 bsr      zeichne_3d               ; 3D-Effekt
/*
 tst.w    10(sp)                   ; von _objc_change ?
 bmi.b    dcr_cr                   ; ja, immer Kreuzchen zeichnen
*/
 btst     #0,10+1(sp)              ; SELECTED ?
 beq      _obdc_tns                ; nein, kein Kreuz, Ende
/*
dcr_cr:
*/
 moveq    #BLACK,d1
/*
 btst     #0,10+1(sp)              ; SELECTED ?
 bne.b    dcr_3dsel                ; ja, Kreuz in Schwarz
 moveq    #LWHITE,d1               ; nein, kein Kreuz (d.h. hellgrau)
dcr_3dsel:
*/
 moveq    #REPLACE,d0
 move.l   sp,a0
 bsr      drw_cross
 moveq    #LBLACK,d1               ; dgrau
/*
 btst     #0,10+1(sp)              ; SELECTED ?
 bne.b    dcr_3dsel2               ; ja, Kreuz in dgrau
 moveq    #LWHITE,d1               ; nein, kein Kreuz (d.h. hellgrau)
dcr_3dsel2:
*/
;move.w   d1,d1                    ; Rahmenfarbe
 moveq    #REPLACE,d0
 bsr      stwmod_pcolor            ; Polylinefarbe setzen
 move.l   sp,a0
 move.w   (a0),d0
 addq.w   #1,(a0)+                 ; x1 = x+1
 move.w   (a0),d1
 addq.w   #2,(a0)+                 ; y1 = y+2
 subq.w   #3,d0
 add.w    d0,(a0)+                 ; x2 = x+w-3
 subq.w   #2,d1
 add.w    d1,(a0)                  ; y2 = y+h-2
 bsr      draw_line
 move.l   sp,a0
 addq.w   #1,4(sp)                 ; x2 = x+w-2
 addq.w   #1,(a0)+                 ; x1 = x+2
 move.w   (a0),d0
 move.w   4(a0),(a0)
 move.w   d0,4(a0)                 ; y1/y2 vertauschen
 bsr      draw_line
 bra     _obdc_tns

; 2D
_obdc_2d:
/*
 tst.w    10(sp)
 bmi.b    _obdc_cross              ; komme von _objc_change
*/
 moveq    #BLACK,d1                ; Rahmenfarbe
 moveq    #REPLACE,d0
 bsr      stwmod_pcolor            ; Polylinefarbe setzen
 move.l   sp,a0
 moveq    #1,d0                    ; Rahmen 1 Pixel innen
 bsr      zeichne_rahmen
/*
_obdc_cross:
*/
 btst     #0,10+1(sp)              ; SELECTED ?
 beq      _obdc_tns                ; nein, kein Kreuz, Ende
/*
 move.w   10(sp),d0
 beq.b    _obdc_tns                ; draw und nicht selektiert => leer
*/
 moveq    #BLACK,d1
/*
 btst     #0,d0                    ; SELECTED ?
 bne.b    _obdc_sel
 moveq    #WHITE,d1
_obdc_sel:
 ; Kreuzchen weiss bzw. schwarz je nach Selektierung
*/
 move.l   sp,a0
 moveq    #REPLACE,d0              ; Schreibmodus
 bsr      drw_cross
_obdc_tns:
 lea      12(sp),sp
 rts


**********************************************************************
*
* void __objc_draw(a0 = OBJECT *tree, d0 = int ob, d1 = {int x, int y})
*                 a1 = OBJECT *ob
*
* malt genau ein Objekt bei absoluter Position (x,y)
* Das Clipping ist bereits mit set_clip_grect() eingeschaltet
*
* a4:          OBJECT *tree
* d6:          frei
* d5:          int    x
* d4:          ob_flags ins Hiword, ob_state ins Loword
* a5:          GRECT  g
* d7:          int    rahmen
* -$36(a6):    int    flag_rahmen_zeichnen
* d5 =
* -$34(a6):    OBJECT *tree
* -$30(a6):    GRECT  g2
* -$28(a6):    GRECT  g (<- a5)
* -$20(a6):    char   c (bei G_BOXCHAR)
* -$1e(a6):    int    irahmen >= 0 (Dicke des inneren Rahmens)
* a3 =
* -$18(a6):    long   spec
* -$14(a6):    unbenutzt
* -$13(a6):    char   is_3d_background
* -$10(a6):    int    is3dact      3D, SELECTED durch Text verschieben
* -$e(a6):     char   is3d         ueberhaupt 3D
* -$d(a6):     char   is_3d_indicator
* -$c(a6):     int    objnr
* -$a(a6):     int    icolor (Innenfarbe bei TEDINFO oder G_?BOX???)
* -8(a6):      int    patt   (Muster bei TEDINFO oder G_?BOX??)
* -6(a6):      int    wmode (Default: 1=REPLACE, sonst 0=TRANSPARENT)
* -4(a6):      int    tcolor (Textfarbe, Default: 1=BLACK)
* -2(a6):      int    rcolor (Rahmenfarbe bei TEDINFO oder G_?BOX??)
*


* Berechnet das innere GRECT ohne inneren Rand

__calc_innergrect:
 move.w   -$1e(a6),d0              ; Dicke des inneren Rahmens ( >= 0 )
 lea      -$30(a6),a0              ; grect nach -$30(a6) kopieren
 move.l   (a5),(a0)
 add.w    d0,(a0)+                 ; g.g_x += offs
 add.w    d0,(a0)+                 ; g.g_y += offs
 move.l   4(a5),(a0)
 add.w    d0,d0
 sub.w    d0,(a0)+                 ; g.g_w -= 2*offs
 sub.w    d0,(a0)                  ; g.g_h -= 2*offs
 rts


* Setze Textfarbe von G_TITLE/G_STRING

_set_transptc:
 cmpi.w   #4,nplanes               ; gibt es hellgrau ?
 bcs.b    _set_transp_tcolor       ; nein
 tst.b    -$d(a6)                  ; INDICATOR ?
 bne.b    _set_transp_tcolor       ; ja
 bclr     #DISABLED_B,d4           ; DISABLED ?
 beq.b    _set_transp_tcolor       ; nein
 moveq    #LBLACK,d1
 bra.b    _odr_nostr_ind

* Setze Textfarbe von G_BUTTON

_set_transp_tcolor:
 moveq    #BLACK,d1
 tst.b    -$d(a6)                  ; INDICATOR ?
 beq.b    _odr_nostr_ind           ; nein
 btst     #SELECTED_B,d4           ; SELECTED ?
 beq.b    _odr_nostr_ind           ; nein
 moveq    #WHITE,d1
_odr_nostr_ind:
 move.w   d1,-4(a6)                ; Textfarbe merken
 moveq    #TRANSPARENT,d0
 bra      stwmod_tcolor


__objc_draw:
 link     a6,#-$36
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5,-(sp)
 lea      -$28(a6),a5

 move.l   a0,-$34(a6)              ; tree
 move.w   d0,-$c(a6)               ; ob
 move.l   d1,(a5)                  ; x,y
 lea      -$30(a6),a4

 move.l   a1,a0                    ; ob
 bsr      _unpack_objc

 btst     #7,ob_flags+1(a0)        ; HIDETREE
 bne      _odr_ende                ; -> ende
 move.l   ob_flags(a0),d4          ; ob_flags ins Hiword, ob_state ins Loword
;move.w   ob_state(a0),d4
 move.l   ob_width(a0),4(a5)       ; w und h ins GRECT schreiben
 move.w   d0,d7                    ; d7 = Rahmendicke
 move.w   d7,-$36(a6)              ; Flag "Rahmen zeichnen"

 sf.b     -$13(a6)                 ; kein 3D-Background-Objekt
 clr.l    -$10(a6)
;clr.b    -$e(a6)                  ; kein Offset fuer 3D, kein 3D

;clr.b    -$d(a6)                  ; kein Indicator
 tst.w    enable_3d
 beq.b    _obdrw_no33d             ; zuwenig Planes
 btst     #9+16,d4                 ; Bit fuer Indicator oder Activator
 beq.b    _obdrw_no33d1
 btst     #10+16,d4                ; Activator ?
 seq.b    -$d(a6)                  ; wenn Bit == 0 => Indicator
 beq.b    _obdrw_is33d             ; nein
 addq.w   #1,-$10(a6)              ; Activator, Offset fuer Text
 bra.b    _obdrw_is33d
_obdrw_no33d1:
 btst     #10+16,d4                ; Bit fuer Background
 beq.b    _obdrw_no33d             ; ist 0
 st.b     -$13(a6)
_obdrw_is33d:
 st.b     -$e(a6)                  ; ist ueberhaupt 3D
_obdrw_no33d:
 move.l   a1,d0
 addq.l   #1,d0
 beq      _odr_ende                ; -> ende
 move.l   a1,a3                    ; a3 = ob_spec
 move.w   d1,d3                    ; type
 bmi      _odr_ende                ; Objektnummer ungueltig
 tst.w    wclip
 beq.b    _obdrw_noclip            ; kein Clipping -> _obdrw_noclip
 tst.w    hclip
 beq.b    _obdrw_noclip            ; kein Clipping -> _obdrw_noclip

* Schnitt mit Clippingbereich ueberpruefen
* Objekte mit OUTLINED haben immer einen Rand von 3 Pixeln ausserhalb
* Rahmen > 0 (innen): Rahmen mit -3 multiplizieren
* Rahmen < 0 (aussen): Rahmen mit 3  multiplizieren
* Der Rahmen sieht so immer aus wie aussen (Sicherheitsabstand!)

 move.l   g_x(a5),g_x(a4)          ; grect nach -$30(a6) kopieren
 move.l   g_w(a5),g_w(a4)
 moveq    #-3,d0
 btst     #OUTLINED_B,d4
 bne.b    obdrw_l1                 ; ja, Rahmen aussen (-3)
 move.w   d7,d0                    ; Rahmendicke
 beq.b    _obdrw_keinrahmen
 add.w    d7,d0
 add.w    d7,d0
 ble.b    obdrw_l1                 ; Rahmen *3 aussen
 neg.w    d0                       ; Rahmen *3 nach aussen stuelpen
obdrw_l1:
 move.l   a4,a0                    ; inneres bzw. aeusseres Rechteck

 add.w    d0,(a0)+                 ; g.g_x += offs
 add.w    d0,(a0)+                 ; g.g_y += offs
 add.w    d0,d0
 sub.w    d0,(a0)+                 ; g.g_w -= 2*offs
 sub.w    d0,(a0)                  ; g.g_h -= 2*offs

_obdrw_keinrahmen:
 move.l   a4,a0
 bsr      in_clip                  ; im Clipping- Bereich ?
 beq      _odr_ende                ; nicht im Clipping- Bereich -> ende

* Ende der Schnittueberpruefung mit Clippingbereich

_obdrw_noclip:
 cmpi.w   #8,d3                    ; 8+20 == G_STRING
 beq      _odr_string              ; G_STRING -> _odr_string
 move.w   d7,d0                    ; Rahmen
 bge.b    obdrw_l2                 ; >= 0 (innen)
 moveq    #0,d0                    ; Rahmen aussen
obdrw_l2:
 move.w   d0,-$1e(a6)              ; -$1e(a6) = Dicke des inneren Rahmens
 move.l   #$10001,-6(a6)           ; wmode = REPLACE
                                   ; tcolor = BLACK
 lea      ob_modes(pc),a0          ; Modi der Objekttypen
 move.b   0(a0,d3.w),d0
 cmpi.b   #-1,d0                   ; TEDINFO ?
 bne.b    _obdrw_notedinfo         ; nein

* im Fall G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT,G_WINTITLE: TEDINFO auswerten

 lea      -$a(a6),a0               ; Innenfarbe,Muster,Schreibmodus,
                                   ; Textfarbe,Rahmenfarbe
 move.w   te_color(a3),d0
 bsr      split_tecolor

* G_(F)BOXTEXT:     immer eine Box zeichnen
* G_TEXT:           Box zeichnen, wenn 3D-Modus. Dann Text transparent
*                   ( wg. MultiTOS )
* G_FTEXT:          nicht die MultiTOS-Marotte mitmachen

 cmpi.w   #G_FBOXTEXT-20,d3        ; FBOXTEXT immer normal behandeln
 beq.b    _obdrw_boxtxt
 cmpi.w   #G_FTEXT-20,d3           ; FTEXT ebenfalls immer normal behandeln
 beq.b    _obdrw_tedi_nobox
 cmpi.w   #G_WINTITLE-20,d3        ; WINTITLE immer normal behandeln
 beq.b    _obdrw_boxtxt
 tst.b    -$e(a6)                  ; 3D ?
 beq.b    _obdrw_text2d            ; nein, keine Sonderbehandlung
; 3D
 cmpi.w   #TRANSPARENT,-6(a6)      ; Text transparent ?
 beq.b    _obdrw_text2d            ; ja, keine Sonderbehandlung
; 3D, deckend: immer Box, immer transparent
 move.w   #TRANSPARENT,-6(a6)      ; Text immer transparent
 cmpi.w   #G_BOXTEXT-20,d3
 beq.b    _obdrw_boxtxt
 bra      _obdrw_keinrahm          ; immer eine Box, aber kein Rahmen
; 2D
_obdrw_text2d:
 cmpi.w   #G_BOXTEXT-20,d3
 beq.b    _obdrw_boxtxt
_obdrw_tedi_nobox:
 clr.w    -$36(a6)                 ; G_(F)TEXT: keine Umrahmung zeichnen
 bra      _obdrw_nobox

* d0 enthaelt immer noch das Modusbyte

_obdrw_notedinfo:
 addq.b   #3,d0
 beq.b    _obdrw_buttons           ; -3: G_BUTTON,G_SWBUTTON,G_POPUP
 subq.b   #1,d0                    ; -2: Boxen
 bne      _obdrw_nobox

* case G_BOX,G_IBOX,G_BOXCHAR

 lea      -$a(a6),a0               ; Innenfarbe,Muster,Schreibmodus,
                                   ; Textfarbe,Rahmenfarbe
 move.w   a3,d0                    ; ob_spec, Loword
 bsr      split_tecolor
 bra.b    _obdrw_boxtxt

* case G_BUTTON,G_SWBUTTON,G_POPUP:
* bekommt Rahmenfarbe BLACK, Innenfarbe WHITE und Muster IP_HOLLOW

_obdrw_buttons:
 btst     #WHITEBAK_B,d4           ; Spezialbuttons ?
 beq.b    odr_nbut                 ; nein
 bclr     #15,d4
 bne      _odr_special             ; ja, Spezialbutton!
odr_nbut:
 move.w   #BLACK,-2(a6)            ; Rahmenfarbe
 clr.l    -$a(a6)                  ; Innenfarbe WHITE, Muster IP_HOLLOW

* case G_BOXTEXT,G_FBOXTEXT

_obdrw_boxtxt:
 tst.w    d7                       ; Rahmendicke
 beq      _obdrw_keinrahm          ; ist 0

 move.w   -2(a6),d1                ; Rahmenfarbe
 bsr      strplc_pcolor            ; Polylinefarbe setzen

* 3D- Rahmen werden nur gezeichnet, wenn man mindestens 4 Planes hat (d.h.
* mindestens 16 Farben.

 tst.b    -$e(a6)                  ; 3D ?
 beq      _obdrw_rahmen

; Farbe weiss in 3D => grau

 tst.l    -$a(a6)                  ; WHITE und IP_HOLLOW ?
 bne.b    _obdrw_nowhite
 move.l   #$80007,-$a(a6)          ; => Hellgrau und IP_SOLID
 tst.b    -$d(a6)                  ; Indicator ?
 beq.b    _obdrw_nowhite           ; nein, SELECTED egal
; Indicator oder Background: SELECTED => dunkler Hintergrund
 btst     #SELECTED_B,d4
 beq.b    _obdrw_nowhite
 move.w   #LBLACK,-$a(a6)

; schwarzen Rahmen malen (optional, wenn Rahmen > 2)

_obdrw_nowhite:
 cmpi.w   #2,d7
 bne      _odr_noroot
 btst     #OUTLINED_B,d4
 beq      _odr_noroot

* Sonderbehandlung fuer Objekt mit Rahmen 2 Pixel innen
* und OUTLINED (d.h. das Wurzelobjekt) in 3D

 move.l   4(a5),-(sp)
 move.l   (a5),-(sp)               ; grect fuer 3D-Schatten
 addq.w   #1,-$1e(a6)              ; inneren Rahmen vergroessern (schwarze Linie)
 bclr     #OUTLINED_B,d4
 moveq    #9,d1                    ; dunkelgrau
 bsr      strplc_pcolor
 move.l   sp,a0
 addq.w   #1,(a0)+
 addq.w   #1,(a0)+
 subq.w   #2,(a0)+
 subq.w   #2,(a0)
 moveq    #1,d0                    ; Rahmendicke
 lea      (sp),a0
 bsr      zeichne_3d_lo
 moveq    #WHITE,d1
 bsr      strplc_pcolor
 moveq    #1,d0                    ; Rahmendicke
 lea      (sp),a0
 bsr      zeichne_3d_ru
 moveq    #LWHITE,d1               ; hellgrau
 bsr      strplc_pcolor
 moveq    #-2,d0
 lea      (sp),a0
 bsr      zeichne_rahmen
 move.l   sp,a0
 addq.w   #1,(a0)+
 addq.w   #1,(a0)+
 subq.w   #2,(a0)+
 subq.w   #2,(a0)
 moveq    #BLACK,d1
 bsr      strplc_pcolor
 moveq    #1,d0
 lea      (sp),a0
 bsr      zeichne_rahmen
 move.l   sp,a0
 subq.w   #4,(a0)+
 subq.w   #4,(a0)+
 addq.w   #8,(a0)+
 addq.w   #8,(a0)
 moveq    #9,d1                    ; dunkelgrau
 bsr      strplc_pcolor
 moveq    #1,d0                    ; Rahmendicke
 lea      (sp),a0
 bsr      zeichne_3d_ru
 moveq    #WHITE,d1
 bsr      strplc_pcolor
 moveq    #1,d0                    ; Rahmendicke
 lea      (sp),a0
 bsr      zeichne_3d_lo
 moveq    #BLACK,d1
 bsr      strplc_pcolor
 moveq    #-1,d0
 lea      (sp),a0
 bsr      zeichne_rahmen
 addq.l   #8,sp
 bra      _obdrw_keinrahm

* ueblicher 3D-Rahmen:

_odr_noroot:
 move.l   a5,a0                    ; grect
 move.w   d7,d0                    ; width
 move.w   d4,d1                    ; selected
 bsr      zeichne_3drahmen
/* bclr     #SHADOWED_B,d4    */
 bra.b    _obdrw_keinrahm

_obdrw_rahmen:
 move.w   d7,d0
 move.l   a5,a0
 bsr      zeichne_rahmen
_obdrw_keinrahm:
 cmpi.w   #G_IBOX-20,d3
 beq.b    _obdrw_nobox             ; ja, nix mehr
 cmpi.w   #G_WINTITLE-20,d3
 bne.b    _obdrw_dobox
 btst     #DRAW3D_B,d4
 bne.b    _obdrw_nobox             ; WINTITLE und DRAW3D: keine Box
_obdrw_dobox:
 bsr      __calc_innergrect

 move.w   -8(a6),d2                ; Muster
 move.w   -$a(a6),d1               ; Innenfarbe
 bne.b    _odr_2din
 tst.w    d2                       ; WHITE und IP_HOLLOW ?
 bne.b    _odr_2din
 tst.b    -$e(a6)                  ; 3D ?
 beq.b    _odr_2din                ; nein
 moveq    #LWHITE,d1
 moveq    #IP_SOLID,d2             ; => Hellgrau und IP_SOLID
; Indicator: SELECTED => dunkler Hintergrund
 tst.b    -$d(a6)                  ; INDICATOR ?
 beq.b    _odr_2din                ; nein, SELECTED ist egal
 btst     #SELECTED_B,d4
 beq.b    _odr_2din
 moveq    #LBLACK,d1
_odr_2din:
 move.l   a4,a0                    ; GRECT *
 moveq    #REPLACE,d0
 bsr      drawbox                  ; Box malen

_obdrw_nobox:
 tst.b    -$d(a6)                  ; INDICATOR ?
 beq.b    _odr_txtnind             ; nein
 btst     #SELECTED_B,d4           ; SELECTED ?
 beq.b    _odr_txtnind             ; nein
; Indicator: SELECTED: Textfarbe wechseln
 move.w   -4(a6),d1                ; textcolor
;andi.w   #15,d1                   ; unnoetig
 move.b   _odr_chgcol(pc,d1.w),d1
 ext.w    d1
 move.w   d1,-4(a6)                ; Textfarbe umsetzen
_odr_txtnind:
 move.w   -4(a6),d1                ; textcolor
 move.w   -6(a6),d0                ; wmode
 bsr      stwmod_tcolor

 move.w   d3,d0
 add.w    d0,d0
 move.w   _obdrw_jmptab(pc,d0.w),d0
 jmp      _obdrw_jmptab(pc,d0.w)        ; der grosse switch()

_odr_chgcol:
 DC.B     1                             ; 0 <-> 1
 DC.B     0
 DC.B     10                            ; 2 <-> 10
 DC.B     11                            ; 3 <-> 11
 DC.B     12                            ; 4 <-> 12
 DC.B     13                            ; 5 <-> 13
 DC.B     14                            ; 6 <-> 14
 DC.B     15                            ; 7 <-> 15
 DC.B     9                             ; 8 <-> 9
 DC.B     8
 DC.B     2
 DC.B     3
 DC.B     4
 DC.B     5
 DC.B     6
 DC.B     7


_obdrw_jmptab:
 DC.W     _odr_tstact-_obdrw_jmptab     ; G_BOX
 DC.W     _odr_text-_obdrw_jmptab       ; G_TEXT
 DC.W     _odr_boxtext-_obdrw_jmptab    ; G_BOXTEXT
 DC.W     _odr_image-_obdrw_jmptab
 DC.W     _odr_userdef-_obdrw_jmptab
 DC.W     _odr_tstact-_obdrw_jmptab     ; G_IBOX
 DC.W     _odr_button-_obdrw_jmptab     ; G_BUTTON
 DC.W     _odr_boxchar-_obdrw_jmptab
 DC.W     _odr_string-_obdrw_jmptab     ; G_STRING
 DC.W     _odr_ftext-_obdrw_jmptab      ; G_FTEXT
 DC.W     _odr_ftext-_obdrw_jmptab      ; G_FBOXTEXT
 DC.W     _odr_icon-_obdrw_jmptab       ; G_ICON
 DC.W     _odr_gtitle-_obdrw_jmptab     ; G_TITLE
 DC.W     _odr_cicon-_obdrw_jmptab      ; G_CICON
 DC.W     _odr_swbutton-_obdrw_jmptab   ; G_SWBUTTON
 DC.W     _odr_popup-_obdrw_jmptab      ; G_POPUP
 DC.W     _odr_wintitle-_obdrw_jmptab   ; G_WINTITLE
 DC.W     _odr_edit-_obdrw_jmptab       ; G_EDIT
 DC.W     _odr_shortcut-_obdrw_jmptab   ; G_SHORTCUT

* case G_BOXCHAR:

_odr_boxchar:
 bsr      __calc_innergrect

 lea      -$18(a6),a1              ; Adresse des Ausgabestrings (1 Zeichen)
 move.l   a3,(a1)                  ; ob_spec
 clr.b    1(a1)                    ; EOS setzen

 tst.w    -$10(a6)                 ; 3D-Activator ?
 beq.b    _obdrw_s2                ; nein
 bclr     #SELECTED_B,d4
 beq.b    _obdrw_s2
 addq.w   #1,g_x(a4)
 addq.w   #1,g_y(a4)

_obdrw_s2:
 move.l   a4,a0                    ; Rahmen
 moveq    #TRANSPARENT,d2
 moveq    #IBM,d1                  ; te_font
 moveq    #TE_CNTR,d0              ; te_just
 bsr      draw_text                ; Ausgabe
 bra      _odr_endsw

* case G_FTEXT
* case G_FBOXTEXT

_odr_ftext:
 move.w   te_font(a3),d0
 bsr      setfont                  ; Font ermitteln
 tst.w    fontmono(a0)             ; ist "mono" ?
 beq.b    _odr_ftxt_kompl          ; nein, komplizierte Ausgabe
 move.l   te_ptmplt(a3),d0         ; scrollbares Editfeld ?
 beq.b    _odr_ftxt_kompl          ; ja, komplizierte Ausgabe
 tst.b    -$e(a6)                  ; 3D ?
 beq.b    _odr_ft_simple           ; nein, einfache Ausgabe
 tst.w    -$10(a6)                 ; Activator ?
 beq.b    _odr_ftxt_kompl          ; nein, komplizierte Ausgabe
_odr_ft_simple:

* Der einfache Fall: nicht scrollend, 2D und aequidistanter Font

 lea      popup_tmp,a2             ; dest (Mischstring)
 move.l   d0,a1                    ; Schablone
 move.b   te_just+1(a3),d0         ; te_just
 move.l   te_ptext(a3),a0
 bsr      txt_tmplt_to_merge       ; formatieren
 lea      popup_tmp,a1             ; Ausgabestring
 bra      __obdrw_text

* Der komplizierte Fall

_odr_ftxt_kompl:
 suba.w   #30,sp                   ; 0: Platz fuer Rueckgabewerte
                                   ; 20: Scroll-Offset
                                   ; 22: gerettetes Clipping-Rechteck
 moveq    #-1,d3                   ; d3 = ganze Objektbreite
 clr.w    20(sp)
 move.b   te_just(a3),21(sp)       ; Scroll-Offset
 move.l   te_ptmplt(a3),d5         ; scrollbares Editfeld ?
 bne.b    _odr_ftxt_noscr          ; nein, normal
; scrollendes Eingabefeld
 move.l   te_pvalid(a3),a0
 move.l   xte_ptmplt(a0),d5        ; d5 = Schablone
 move.w   xte_scroll(a0),20(sp)    ; Scroll-Offset
 move.w   xte_vislen(a0),d3        ; d3 = sichtbare Laenge
; nicht scrollendes Eingabefeld
_odr_ftxt_noscr:
 lea      popup_tmp,a2             ; dest (Mischstring)
 move.l   d5,a1                    ; Schablone
 move.b   te_just+1(a3),d0         ; te_just
 move.l   te_ptext(a3),a0          ; text
 bsr      txt_tmplt_to_merge       ; formatieren

*
* F(BOX)TEXT proportional oder in 3D, aber kein Activator.
* Der feste Teil wird schwarz auf grau
* ausgegeben, das Eingabefeld bekommt einen 3D- Rahmen
*

 bsr      __calc_innergrect

 move.l   -$30+g_x(a6),g_x(sp)
 move.l   -$30+g_w(a6),g_w(sp)     ; GRECT, auch Rueckgabe

 move.l   sp,a2                    ; data
 move.l   a3,a1                    ; TEDINFO
 move.l   d5,a0                    ; tmplt
 move.w   d3,d0                    ; Laenge der Schablone oder -1 (alles)
 bsr      calc_ftext               ; Zeichenpositionen berechnen

 move.l   xclip,22+g_x(sp)
 move.l   wclip,22+g_w(sp)         ; altes Clipping-Rechteck retten
 lea      (sp),a0
 bsr      set_iclip                ; Clipping-Rechteck fuer Textausgabe

 beq      _obdt_after_rcl          ; leeres Clipping-Rechteck (kein Text!)

; links vom Eingabefeld ausgeben (transparent!)

 move.w   8(sp),d0                 ; Anzahl Zeichen des Anfangs
 beq.b    _odr_ftxt_zero1          ; kein Anfang
 lea      popup_tmp,a0             ; Misch-String
 add.w    d0,a0                    ; Ende des Anfangs
 move.b   (a0),-(sp)               ; Zeichen merken
 move.l   a0,-(sp)                 ; pos merken (Anfang Eingabefeld)
 clr.b    (a0)                     ; EOS setzen
 move.w   -4(a6),d1                ; textcolor
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 lea      popup_tmp,a0
 jsr      str_to_ints

 move.l   6(sp),vptsin             ; x,y
 bsr      gtext
 move.l   (sp)+,a0
 move.b   (sp)+,(a0)               ; Zeichen wieder einsetzen

; rechts vom letzten Eingabefeld ausgeben (transparent!)

_odr_ftxt_zero1:
 move.w   16(sp),d0                ; Anzahl Zeichen des Endes
 beq.b    _odr_ftxt_zero2          ; kein Ende

 move.w   -4(a6),d1                ; textcolor
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 lea      popup_tmp,a0             ; Misch-String
 add.w    8(sp),a0                 ; + Anfang
 add.w    12(sp),a0                ; + Mitte (ggf. nur teilw. sichtbar)
 jsr      str_to_ints

 move.w   g_x(sp),d0               ; x-Pos
 add.w    10(sp),d0                ; + Anfang
 add.w    14(sp),d0                ; + Mitte
 move.w   d0,vptsin
 move.w   g_y(sp),vptsin+2
 bsr      gtext

; Eingabefeld ausgeben (i.a. replace!)
; Wenn REPLACE und Vektorfont: Weisses Rechteck unterlegen

_odr_ftxt_zero2:
 move.w   12(sp),d0                ; Laenge Eingabefeld
 beq      _odr_ftxt_zero3          ; kein Eingabefeld
 move.w   -6(a6),d0
 move.w   -4(a6),d1                ; textcolor
 bsr      stwmod_tcolor
; Eingabefeld-String bestimmen
; Bei einfacher Schablone & Rand & nicht rechtsbuendig: nur Text ausgeben
 move.l   curr_finfo,a0
 tst.w    fontmono(a0)             ; "monospaced"
 bne.b    _odr_ftxt_un             ; ja, Unterstriche ausgeben
; cmpi.b  #TE_RIGHT,te_just+1(a3)
; beq.b   _odr_ftxt_un
 tst.w    d7
 beq.b    _odr_ftxt_un             ; kein Rand
 tst.b    -$e(a6)                  ; 3D
 bne.b    _odr_ftxt_tstun          ; ja, keine Unterstriche
 tst.w    -$36(a6)                 ; Rahmen?
 beq.b    _odr_ftxt_un             ; nein, Unterstriche ausgeben
_odr_ftxt_tstun:
 move.l   d5,a0                    ; Schablone
 add.w    8(sp),a0                 ; + Anfang
 move.l   a0,a1
 add.w    12(sp),a1
 moveq    #'_',d1
_odr_ftxt_un_loop:
 cmp.l    a1,a0
 bcc.b    _odr_ftxt_no_un
 move.b   (a0)+,d0
 beq.b    _odr_ftxt_no_un
 cmp.b    d1,d0
 bne.b    _odr_ftxt_un
 bra.b    _odr_ftxt_un_loop
_odr_ftxt_no_un:
 move.l   te_ptext(a3),a0
 bra.b    _odr_ftxt_wun

_odr_ftxt_un:
 lea      popup_tmp,a0             ; Misch-String
 add.w    8(sp),a0                 ; + Laenge des Anfangs
 move.w   12(sp),d0                ; Laenge des Eingabefelds
 clr.b    0(a0,d0.w)               ; EOS setzen
_odr_ftxt_wun:
 add.w    20(sp),a0                ; + Scroll-Offset
 bsr      str_to_ints

 move.w   14(sp),d0                ; Breite des Eingabefelds
 addq.w   #2,d0                    ; !!!
 bsr      r_extent                 ; => Anzahl sichtbarer Zeichen
 move.w   d0,vintin_len            ; hier ggf. "clippen"

 move.w   10(sp),d0                ; Breite des Anfangs
 add.w    d0,g_x(sp)               ; auf x-Pos. addieren
 move.w   14(sp),g_w(sp)           ; Breite des Eingabefelds

 cmpi.w   #TRANSPARENT,-6(a6)      ; Text transparent ?
 beq.b    _obdt_ttr                ; ja, keine Sonderbehandlung

 lea      (sp),a0                  ; GRECT *
 moveq    #WHITE,d1
 moveq    #IP_SOLID,d2
 moveq    #REPLACE,d0
 bsr      drawbox                  ; Box malen

_obdt_ttr:
 move.l   g_x(sp),vptsin           ; x/y
 bsr      gtext

; Ggf. diverse Rahmen. Dazu Clipping restaurieren

 lea      22(sp),a0
 bsr      set_clip_grect

; kein 3D oder 3D-Activator: kein Rahmen

_obdt_after_rcl:
 tst.b    -$e(a6)                  ; 3D ?
 beq      _odr_ftxt_zero           ; nein, kein Rahmen
 tst.w    -$10(a6)                 ; Activator ?
 bne      _odr_ftxt_zero           ; ja, kein Rahmen

; einfacher Rahmen um Eingabefeld (Rahmenbreite -1)

 cmpi.w   #-1,d7
 bne.b    _obdtf3_nom1
 moveq    #LBLACK,d1
 bsr      strplc_pcolor            ; dunkelgraue Ecke
 move.l   sp,a0
 moveq    #-1,d0
 bsr      zeichne_3d_lo
 bra      _odr_ftxt_zero
_obdtf3_nom1:
; Rahmen um Eingabefeld (wenn Rahmenbreite mindestens -2)
 cmpi.w   #-2,d7
 bgt      _odr_ftxt_zero
 moveq    #LWHITE,d1               ; hellgrauer Rahmen
 bsr      strplc_pcolor
 move.l   sp,a0
 moveq    #-1,d0
 bsr      zeichne_rahmen
 moveq    #LBLACK,d1
 bsr      strplc_pcolor
 move.l   sp,a0
 subq.w   #1,g_x(a0)
 subq.w   #1,g_y(a0)
 addq.w   #2,g_w(a0)
 addq.w   #2,g_h(a0)
 moveq    #-1,d0
 bsr      zeichne_3d_lo
 moveq    #WHITE,d1
 bsr      strplc_pcolor
 moveq    #-1,d0
 move.l   sp,a0
 bsr      zeichne_3d_ru
 bra.b    _odr_ftxt_zero

_odr_ftxt_zero3:
 lea      22(sp),a0
 bsr      set_clip_grect

_odr_ftxt_zero:
 adda.w   #30,sp
 bra      _odr_endsw

* case G_TEXT:
* case G_BOXTEXT:

_odr_text:
_odr_boxtext:
 cmpi.w   #PFINFO,te_font(a3)
 bne.b    _odr_txt_no4
; te_font ist 4.
; => te_resvd1 und te_resvd2 sind Zeiger auf FINFO
 move.w   te_resvd1(a3),d0         ; te_resvd1 ist Hiword
 swap     d0
 move.w   te_resvd2(a3),d0         ; te_resvd2 ist Loword
 move.l   d0,a0
 bsr      _setfont                 ; FINFO direkt setzen!
_odr_txt_no4:
 move.l   te_ptext(a3),a1
__obdrw_text:
 bsr      __calc_innergrect

 tst.w    -$10(a6)                 ; Activator ?
 beq.b    _odr_s1                  ; nein
 bclr     #SELECTED_B,d4
 beq.b    _odr_s1
 addq.w   #1,g_x(a4)
 addq.w   #1,g_y(a4)
_odr_s1:

 move.b   te_just+1(a3),d0         ; te_just
 cmpi.b   #TE_SPECIAL,d0
 bne.b    _odr_tx_no3
 moveq    #TE_LEFT,d0              ; erster Teil linksbuendig
; te_just = 3.
; Suche nach "||" und gib Teil rechts-, Teil linksbuendig aus.
 moveq    #'|',d1
 move.l   a1,a0
_odr_tx_l1:
 move.b   (a0)+,d2
 beq.b    _odr_tx_no3
 cmp.b    d2,d1
 bne.b    _odr_tx_l1
 cmp.b    (a0),d1
 bne.b    _odr_tx_l1
; erster Teil linksbuendig
; aber erst testen, ob der ganze Text passt

 movem.l  d0/a0/a1,-(sp)
 move.l   a1,a0
 bsr      str_to_ints
 move.w   vintin_len,d0
 bsr      extent              ; Breite in Pixeln
 sub.w    g_w(a4),d0          ; >0: zu breit
 move.w   d0,d1
 movem.l  (sp)+,a0/a1/d0
 move.w   d1,-(sp)            ; >=0: rechten Teil weglassen

 clr.b    -1(a0)
 move.l   a0,-(sp)

 move.l   a4,a0                    ; Rahmen
 move.w   -6(a6),d2                ; wmode
 move.w   te_font(a3),d1           ; te_font
;move.l   a1,a1
 bsr      draw_text                ; Ausgabe
 move.l   (sp)+,a1
 move.b   #'|',-1(a1)
 tst.w    (sp)+                    ; war Text zu breit?
 bgt.b    _odr_tx_ende
 addq.l   #1,a1

; zweiter Teil rechtsbuendig
 moveq    #TE_RIGHT,d0

_odr_tx_no3:
 move.l   a4,a0                    ; Rahmen
 move.w   -6(a6),d2                ; wmode
 move.w   te_font(a3),d1           ; te_font
 bsr      draw_text                ; Ausgabe
_odr_tx_ende:
 bra      _odr_endsw

* case G_WINTITLE:

_odr_wintitle:

* leading und trailing blank entfernen und String-Laenge ermitteln

 move.l   (a3),a0                  ; te_ptext
 cmpi.b   #' ',(a0)                ; Beginnt mit Leerzeichen ?
 bne.b    _odrw_wtns               ; nein
 addq.l   #1,a0                    ; fuehrendes Leerzeichen entfernen
_odrw_wtns:
 jsr      str_to_ints              ; String ins txvintin[]-Feld => d0 = strlen
 beq.b    _odrw_wt_l1              ; kein Zeichen
 lea      txvintin,a0
 add.w    d0,a0
 add.w    d0,a0
 cmpi.w   #' ',-2(a0)              ; letztes Zeichen Leerzeichen ?
 bne.b    _odrw_wt_l1              ; nein
 subq.w   #1,vintin_len            ; letztes Zeichen entfernen
_odrw_wt_l1:

* inneres Rechteck bestimmen und Text darin zentrieren

 bsr      __calc_innergrect        ; Rahmen nach a4[]

 move.l   g_w(a4),-(sp)
 move.l   g_x(a4),-(sp)            ; Kopie
 move.l   a4,a1                    ; outg
 move.l   sp,a0                    ; ing
 moveq    #TE_CNTR,d1
 move.w   te_font(a3),d0
 moveq    #0,d2                    ; Breite berechnen
 bsr      tjust
 moveq    #8,d3                    ; Leerzeichen mit 8 Pixeln annehmen
;move.w   fontcharW(a0),d3         ; Zeichenbreite: d3
 addq.l   #8,sp                    ; Kopie wegwerfen

* if (ist 2D)

 tst.w    vintin_len               ; ist ueberhaupt Text ?
 beq      _odr_wtl                 ; nein
 tst.b    -$e(a6)                  ; 3D ?
 bne.b    _odr_wt3d

*
* 1. Fall: Fenstertitel 2D
*

 move.l   g_x(a4),vptsin           ; x,y
 bsr      gtext
 bra      _odr_wt_txt

*
* 2. Fall: Fenstertitel 3D
*

_odr_wt3d:
 tst.w    -$10(a6)                 ; Activator ?
 beq      _odr_s1                  ; nein, normales G_TEXT Objekt
 bclr     #SELECTED_B,d4
 beq.b    _odr_wt1
 addq.w   #1,g_x(a4)
 addq.w   #1,g_y(a4)
_odr_wt1:
 btst.b   #4,look_flags+1          ; Name 3D ?
 bne.b    _odr_wtnon3d

* Ausgabe 3D-Titelname (weiss und tcolour)

 moveq    #WHITE,d1                ; Text zuerst weiss fuer 3D-Effekt
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor            ; zerstoert u.U. vintin[0]

 move.l   g_x(a4),vptsin           ; x,y
 bsr      gtext

 move.w   -4(a6),d1                ; Text wieder in textcolor
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 move.l   g_x(a4),vptsin           ; x,y
 subq.w   #1,vptsin                ; x
 subq.w   #1,vptsin+2              ; y
 bsr      gtext

 addq.w   #1,g_w(a4)               ; Textbreite (!) erhoehen wg. 3D
 bra.b    _odr_wt_txt

* Ausgabe 2D-Titelname

_odr_wtnon3d:
 move.w   -4(a6),d1                ; Text wieder in textcolor
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 move.l   g_x(a4),vptsin           ; x,y
 subq.w   #1,vptsin+2              ; y
 bsr      gtext

*
* Korrektur zur Simulation fuehrender und abschliessender Leerzeichen
* Nur, falls Text da ist
*

_odr_wt_txt:
 sub.w    d3,g_x(a4)               ; "Text" nach links ...
 add.w    d3,g_w(a4)
 add.w    d3,g_w(a4)               ; ... und Breite erhoehen

*
* Beide Faelle: Linien
*

_odr_wtl:

 cmpi.w   #1,-6(a6)                ; REPLACE oder TRANSPARENT ?
 bne      _odr_endsw               ; Replace => Linien weglassen

 move.w   g_w(a5),d0               ; Breite des Objekts
 sub.w    g_w(a4),d0               ; - Breite des Texts
 subi.w   #8+4,d0                  ; - innerer Rand - 2*4 Pixel
 blt      _odr_txt_end             ; kein Platz fuer Linien
 move.w   g_h(a5),d3               ; Objekthoehe
 subq.w   #4,d3                    ; - innerer Rand
                                   ; norm.weise 15 Pixel
 divu     #5,d3                    ; Anzahl Linien
 beq      _odr_txt_end

* Linie links

 move.w   g_y(a5),-(sp)
 tst.b    -$e(a6)                  ; 3D ?
 bne.b    _odr_wtn5                ; ja, Offset 4 Pixel
 addq.w   #1,(sp)                  ; nein, Offset 3 Pixel
_odr_wtn5:
 addq.w   #4,(sp)                  ; y2 = ob_y+5
 move.w   g_x(a4),-(sp)            ; x2
 tst.w    g_h(a4)                  ; ist ueberhaupt Text ?
 beq.b    _odr_wtn6                ; nein
 subq.w   #1,(sp)
_odr_wtn6:
 move.w   2(sp),-(sp)              ; y1 = y2
 move.w   g_x(a5),-(sp)
 addq.w   #6,(sp)                  ; x1 = ob_x+6

* Linie rechts

 move.w   6(sp),-(sp)              ; y2 = s.o.
 move.w   g_x(a5),d0
 add.w    g_w(a5),d0
 subq.w   #1+2+4,d0
 move.w   d0,-(sp)                 ; x2
 move.w   2(sp),-(sp)              ; y1 = s.o.
 move.w   g_x(a4),d0               ; Textpos
 add.w    g_w(a4),d0               ; + Breite => Endpos des Textes
 move.w   d0,-(sp)                 ; x1

_odr_txt_loop:
 moveq    #BLACK,d1
 tst.b    -$e(a6)                  ; 3D ?
 beq.b    _odr_wtn4                ; nein, schwarze Linien
 moveq    #LBLACK,d1               ; dunkelgrau
_odr_wtn4:
 bsr      strplc_pcolor
 moveq    #2,d0
 move.l   sp,a0
 bsr      v_pline                  ; eine Linie
 moveq    #2,d0
 lea      8(sp),a0
 bsr      v_pline                  ; eine Linie

 addq.w   #1,2(sp)                 ; y1++
 addq.w   #1,6(sp)                 ; y2++
 addq.w   #1,2+8(sp)               ; y1++
 addq.w   #1,6+8(sp)               ; y2++

 tst.b    -$e(a6)                  ; 3D ?
 beq.b    _odr_wtn3

 moveq    #WHITE,d1
 bsr      strplc_pcolor

 addq.w   #1,4(sp)                 ; x2++
 addq.w   #1,8(sp)                 ; x1++

 moveq    #2,d0
 move.l   sp,a0
 bsr      v_pline                  ; eine Linie
 moveq    #2,d0
 lea      8(sp),a0
 bsr      v_pline                  ; eine Linie
 subq.w   #1,4(sp)                 ; x2--
 subq.w   #1,8(sp)                 ; x1--

_odr_wtn3:
 addq.w   #3,2(sp)                 ; y1 += 3
 addq.w   #3,6(sp)                 ; y2 += 3
 addq.w   #3,2+8(sp)               ; y1 += 3
 addq.w   #3,6+8(sp)               ; y2 += 3

 subq.w   #1,d3
 bne.b    _odr_txt_loop
 adda.w   #16,sp
_odr_txt_end:
 bra      _odr_endsw

* case G_IMAGE:

_odr_image:
 clr.w    -(sp)
 move.w   bi_color(a3),-(sp)
 move.w   #TRANSPARENT,-(sp)
 move.w   bi_hl(a3),-(sp)          ; Hoehe in Pixelzeilen
 move.w   bi_wb(a3),d0             ; Bytes ...
 lsl.w    #3,d0                    ; ... in Pixel umrechnen
 move.w   d0,-(sp)                 ; Breite in Pixeln
 subq.l   #2,sp                    ; Dummy fuer Zielbreite (autom. Bildsch.)
 move.l   (a5),-(sp)               ; Zielposition:  ob_x,ob_y
 clr.l    -(sp)                    ; Ziel: Bildschirm
 move.w   bi_wb(a3),-(sp)          ; Quellbreite
 move.l   bi_x(a3),-(sp)           ; Quellposition: bi_x,bi_y
 move.l   bi_pdata(a3),-(sp)       ; Quelldaten
 bsr      draw_bitblk
 lea      30(sp),sp
 bra      _odr_endsw

* case G_CICON:

_odr_cicon:
 tst.l    cib_mainlist(a3)         ; Zeigt auf ICONBLK, gefolgt von <mainlist>.
 ble.b    _odr_icon                ; muss monochrom ausgeben
 move.l   a3,a0                    ; ICONBLK *ob_spec
 move.l   (a5),d1                  ; x,y Offset
 move.w   d4,d0                    ; ob_state
 bsr      draw_cicon               ; Colour-Icon ausgeben

 andi.w   #$fffe,d4                ; SELECTED ist schon beruecksichtigt
 bra      _odr_endsw

* case G_ICON:

_odr_icon:
 move.l   a3,a0                    ; ICONBLK *ob_spec
 move.l   (a5),d1                  ; x,y Offset
 move.w   d4,d0                    ; ob_state
 bsr      draw_icon                ; Icon ausgeben

 andi.w   #$fffe,d4                ; SELECTED ist schon beruecksichtigt
 bra      _odr_endsw

* case G_EDIT:

_odr_edit:
 move.l   fn_editor,d0             ; Editor aktiv ?
 beq      _odr_endsw               ; nein
 move.l   a3,-(sp)                 ; ub_parm
 move.l   d0,-(sp)                 ; ub_code
 move.w   d4,-(sp)                 ; current:  ob_state
 move.w   d4,-(sp)                 ; previous: ob_state
 pea      4(sp)                    ; USERBLK ob_spec
 pea      (a5)                     ; GRECT
 move.w   -$c(a6),-(sp)            ; objnr
 move.l   -$34(a6),-(sp)           ; tree
 bsr      do_userdef
 lea      26(sp),sp
 move.w   d0,d4
 bra      _odr_endsw

* case G_USERDEF:

_odr_userdef:
 move.w   d4,-(sp)                 ; current:  ob_state
 move.w   d4,-(sp)                 ; previous: ob_state
 move.l   a3,-(sp)                 ; USERBLK ob_spec
 pea      (a5)                     ; GRECT
 move.w   -$c(a6),-(sp)            ; objnr
 move.l   -$34(a6),-(sp)           ; tree
 bsr      do_userdef
 lea      18(sp),sp
 move.w   d0,d4
 bra      _odr_endsw

* case OB_POPUP:

_odr_popup:
 move.l   (a3)+,a0                 ; OBJECT *menutree
 move.w   (a3),d0                  ; int objnr
 mulu     #24,d0
 move.l   ob_spec(a0,d0.l),a3      ; Teilstring des Menues nehmen
;bra      _obdrw_swb4              ; wie G_BUTTON
 bra      _odr_string              ; wie G_STRING

* Spezialbuttons zeichnen
* (G_BUTTON mit WHITEBAK und Bit 15 von ob_state gesetzt)
* MagiC 3.0: Bit 14 nicht gesetzt: runder/Kreuzchenbutton
*                         gesetzt: Gruppe


_odr_special:
 move.w   d4,d0
 andi.w   #$7f00,d0
 cmpi.w   #$7e00,d0
 bne      _odr_sbut

*
* G_BUTTON mit WHITEBAK und Bit 15,
*  ansonsten Wert -2
*  Gruppenrahmen
*

 moveq    #IBM,d0
 bsr      setfont

 move.l   a3,a0                    ; ob_spec
 jsr      str_to_ints

;move.w   d0,d0
 bsr      extent

 move.w   d0,d6                    ; d6 = Textbreite in Pixeln
 lea      vptsin,a1
 move.w   g_x(a5),d0
 add.w    big_wchar,d0
 move.w   d0,(a1)+                 ; x1 = x + wchar
 move.w   big_hchar,d1
 lsr.w    #1,d1
 add.w    g_y(a5),d1
 move.w   d1,(a1)+                 ; y1 = y + hchar/2
 move.w   g_x(a5),(a1)+            ; x2 = x
 move.w   d1,(a1)+                 ; y2 = y1
 move.w   g_x(a5),(a1)+            ; x3 = x2
 move.w   g_y(a5),d2
 add.w    g_h(a5),d2
 subq.w   #1,d2
 move.w   d2,(a1)+                 ; y3 = y + h - 1
 move.w   g_x(a5),d0
 add.w    g_w(a5),d0
 subq.w   #1,d0
 move.w   d0,(a1)+                 ; x4 = x + w - 1
 move.w   d2,(a1)+                 ; y4 = y3
 move.w   d0,(a1)+                 ; x5 = x4
 move.w   d1,(a1)+                 ; y5 = y1
 move.w   vptsin,d0
 add.w    d6,d0
 move.w   d0,(a1)+                 ; x6 = x1 + Textlen (+ 2)
 move.w   d1,(a1)                  ; y6 = y1
 tst.b    -$e(a6)
 bne      _odr_grp_3d
 moveq    #BLACK,d1                ; Rahmenfarbe
 bsr      strplc_pcolor            ; Polylinefarbe setzen
 lea      vcontrl,a1
 move.l   #$06060000,d1            ; v_pline, 6 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
 bra      _odr_gsptext
_odr_grp_3d:
 move.l   vptsin+8,-(sp)           ; x3/y3 merken
; dgrau links oben
 moveq    #9,d1                    ; dunkelgrau
 bsr      strplc_pcolor            ; Polylinefarbe setzen
 subq.w   #1,vptsin+10             ; y5--
 lea      vcontrl,a1
 move.l   #$06030000,d1            ; v_pline, 3 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
; weiss links oben
 moveq    #WHITE,d1
 bsr      strplc_pcolor            ; Polylinefarbe setzen
 lea      vptsin+2,a1
 addq.w   #1,(a1)+                 ; y1++
 addq.w   #1,(a1)+                 ; x2++
 addq.w   #1,(a1)+                 ; y2++
 addq.w   #1,(a1)+                 ; x3++
 subq.w   #1,(a1)                  ; y3--
 lea      vcontrl,a1
 move.l   #$06030000,d1            ; v_pline, 3 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
; weiss rechts unten
 lea      vptsin,a1
 move.l   (sp)+,(a1)+              ; Ecke lu
 move.l   8(a1),(a1)+              ; Ecke ru
 move.l   8(a1),(a1)               ; Ecke ro
 addq.w   #1,vptsin                ; x1++
 addq.w   #1,vptsin+10             ; y3++
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
; grau rechts unten
 moveq    #9,d1
 bsr      strplc_pcolor            ; Polylinefarbe setzen
 lea      vptsin,a1
 addq.w   #1,(a1)+
 subq.w   #1,(a1)+
 subq.w   #1,(a1)+
 subq.w   #1,(a1)+
 subq.w   #1,(a1)+
 addq.w   #1,(a1)
 lea      vcontrl,a1
 move.l   #$06030000,d1            ; v_pline, 3 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
; grau rechts oben (2 Punkte)
 move.l   vptsin+16,vptsin
 move.l   vptsin+20,vptsin+4
 subq.w   #1,vptsin
 lea      vcontrl,a1
 move.l   #$06020000,d1            ; v_pline, 2 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2
; weiss rechts oben (2 Punkte)
 moveq    #WHITE,d1
 bsr      strplc_pcolor            ; Polylinefarbe setzen

 lea      vptsin,a1
 subq.w   #1,(a1)+
 addq.w   #1,(a1)+
 addq.w   #1,2(a1)
 lea      vcontrl,a1
 move.l   #$06020000,d1            ; v_pline, 2 Paare
 movep.l  d1,1(a1)
 move.l   #vdipb,d1
 moveq    #$73,d0
 trap     #2

_odr_gsptext:
 moveq    #BLACK,d1
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 move.w   g_x(a5),d0               ; x
 add.w    big_wchar,d0             ; Offset
;add.w    big_wchar,d0             ; fuehrendes Leerzeichen
 move.w   d0,vptsin
 move.w   g_y(a5),vptsin+2
 bsr      gtext
 bra      _odr_endsw

*
* G_BUTTON mit WHITEBAK und Bit 15 von ob_state
*  und Highbyte != -2
*  Kreuzchenbutton und runder Button
*

_odr_sbut:
 move.w   big_wchar,d5
 mulu     #3,d5                    ; 3 Zeichen zwischen Button und Text
 sub.w    d5,g_w(a4)
 bmi      _odr_endsw               ; Objekt zu klein
 btst     #4+16,d4                 ; RBUTTON ?
 beq      _obdrw_no_rb
; Radio-Button
 move.l   a4,a0
 move.w   d4,d0
 move.b   -$e(a6),d1               ; 3d
 bsr      _obd_rbutton
 bclr     #0,d4                    ; SELECTED ist bearbeitet
 bra      _obd_rn

; Normal-Button
_obdrw_no_rb:
 move.w   d4,d0
 andi.w   #1,d0                    ; selected
 move.b   -$e(a6),d1               ; 3D ?
 ext.w    d1
 move.l   a4,a0                    ; GRECT
 bsr      _obd_crossbutton
 bclr     #0,d4                    ; SELECTED ist erledigt

_obd_rn:
 add.w    d5,g_x(a4)

 bsr      _set_transp_tcolor

 moveq    #IBM,d0
 bsr      setfont

 move.l   a3,a0                    ; ob_spec
 jsr      str_to_ints
 move.l   (a4),vptsin              ; x,y
 bsr      gtext
 move.w   d4,d0
 andi.w   #$7f00,d0
 cmpi.w   #$7f00,d0
 beq      _odr_endsw               ; Hiword -1 : nicht unterstreichen
 move.l   (a4),d1                  ; x,y
 bra      _obdrw_unterstr

* case OB_SWBUTTON:

_odr_swbutton:
 move.l   (a3)+,a0                 ; Strings, durch '|' getrennt
 move.w   (a3),d0                  ; Nummer des anzuzeigenden Strings
 beq.b    _obdrw_swb2
_obdrw_swb1:
 move.b   (a0)+,d1
 beq      _odr_endsw               ; ploetzliches String- Ende
 cmpi.b   #'|',d1
 bne.b    _obdrw_swb1
 subq.w   #1,d0
 bne.b    _obdrw_swb1
_obdrw_swb2:
 lea      popup_tmp,a1
 move.l   a1,a3                    ; dieses ausgeben
_obdrw_swb3:
 move.b   (a0)+,(a1)+
 beq.b    _obdrw_swb4
 cmpi.b   #'|',-1(a1)
 bne.b    _obdrw_swb3
 clr.b    -1(a1)
_obdrw_swb4:
 moveq    #6,d3                    ; wie G_BUTTON
 bsr      _set_transp_tcolor
 bra      _odr_string2

_odr_tstact:
 tst.w    -$10(a6)                 ; Activator ?
 beq      _odr_endsw               ; nein
 bclr     #SELECTED_B,d4           ; ja, SELECTED ist verarbeitet
 bra      _odr_endsw

*
* case G_BUTTON:
*

_odr_button:
 bsr      _set_transp_tcolor
 btst     #WHITEBAK_B,d4
 beq      _odr_string2
 bclr     #15,d4
 bne      _odr_special             ; Spezialbuttons!
 bra      _odr_string2

*
* case G_SHORTCUT:
*

_odr_shortcut:
 move.l   d4,d3                    ; DISABLED und SUBMENU retten
 bsr      _set_transptc

 moveq    #IBM,d0
 bsr      setfont                  ; a0 = grosser Zeichensatz

; Rechteck fuer Text, dabei ggf. 2 Zeichen fuer linken Rand beruecksichtigen

 move.l   g_x(a5),g_x(a4)
 move.l   g_w(a5),g_w(a4)
 moveq    #' ',d0
 cmp.b    (a3),d0                  ; Beginnt mit Leerzeichen?
 bne.b    _odr_sc1                 ; nein
 cmp.b    1(a3),d0                 ; noch ein Leerzeichen?
 bne.b    _odr_sc1                 ; nein
 addq.l   #2,a3
 move.w   big_wchar,d0
 add.w    d0,d0
 add.w    d0,g_x(a4)
 sub.w    d0,g_w(a4)
_odr_sc1:
 tst.w    fontmono(a0)
 bne.b    _odr_ssimple             ; aequidistant
 bra.b    _odr_str_men             ; Menue

*
* case G_STRING:
*

_odr_string:
 move.l   d4,d3                    ; DISABLED und SUBMENU retten
 bsr      _set_transptc

 moveq    #IBM,d0
 bsr      setfont                  ; a0 = grosser Zeichensatz

; Rechteck fuer Text, dabei ggf. 2 Zeichen fuer linken Rand beruecksichtigen

 move.l   g_x(a5),g_x(a4)
 move.l   g_w(a5),g_w(a4)
 moveq    #' ',d0
 cmp.b    (a3),d0                  ; Beginnt mit Leerzeichen?
 bne.b    _odr_st1                 ; nein
 cmp.b    1(a3),d0                 ; noch ein Leerzeichen?
 bne.b    _odr_st1                 ; nein
 addq.l   #2,a3
 move.w   big_wchar,d0
 add.w    d0,d0
 add.w    d0,g_x(a4)
 sub.w    d0,g_w(a4)
_odr_st1:
 tst.w    fontmono(a0)
 bne.b    _odr_ssimple             ; aequidistant

; proportionaler Zeichensatz: Menues gesondert behandeln

 moveq    #SUBMENU_B+16,d0
 btst.l   d0,d3                    ; Submenue-Eintrag?
 bne.b    _odr_str_men             ; ja (hat rechts einen Pfeil!)
 move.l   -$34(a6),a1              ; tree
 cmpa.l   menutree,a1              ; ist gerade gezeichneter Menuebaum ?
 beq.b    _odr_str_men             ; ja
 cmpa.l   mctrl_mnrett,a1          ; ist gerade gezeichneter Menuebaum ?
 beq.b    _odr_str_men             ; ja
 cmpa.l   #popup_tmp,a1            ; ist MagiC-Popup ?
 beq.b    _odr_str_men             ; ja

; aequidistanter Zeichensatz: Ausgabe

_odr_ssimple: 
 move.l   a3,a0                    ; ob_spec
 bsr      str_to_ints
 beq      _odr_tstact              ; Text ist leer
 move.w   g_x(a4),d1
 bra      _odr_snoh

; Menue-Eintrag und Proportionalfont

_odr_str_men:
 move.b   (a3),d0

; Trenn-Zeile ?

 cmpi.b   #'-',d0
 bne.b    _odr_str_no_trenn 
 btst     #DISABLED_B,d3
 beq      _odr_ssimple                  ; kann kein Trenner sein
 move.l   a3,a0
 addq.l   #1,a0
_odr_tr_loop:
 move.b   (a0)+,d0
 beq.b    _odr_tr_endloop
 cmpi.b   #'-',d0
 bne      _odr_ssimple                  ; kann kein Trenner sein
 bra.b    _odr_tr_loop
_odr_tr_endloop:
 moveq    #LBLACK,d1
 bsr      strplc_pcolor                 ; Polylinefarbe setzen
 lea      vptsin,a0
 move.w   g_x(a5),d0
 move.w   d0,(a0)+                      ; x1 = x
 move.w   g_h(a5),d1
 lsr.w    #1,d1
 add.w    g_y(a5),d1
 move.w   d1,(a0)+                      ; y1 = y+h/2
 add.w    g_w(a5),d0
 subq.w   #1,d0
 move.w   d0,(a0)+                      ; x2 = x+w-1
 move.w   d1,(a0)                       ; y2 = y1
 lea      vptsin,a0
 moveq    #2,d0
 bsr      v_pline
 bra      _odr_endsw

_odr_str_no_trenn:
 move.l   a3,a0
 bsr      split_menu_entry
 move.l   a0,d5                    ; Zeiger auf rechtsbuendigen Teilstring
 beq.b    _odr_me_svi              ; ist leer!

 move.w   d0,-(sp)                 ; Anzahl rechtsbuendiger Leerzeichen

; rechtsbuendigen Teil-String zeichnen

;move.l   d5,a0
 bsr      str_to_ints
 sub.w    (sp)+,d0
 move.w   d0,vintin_len            ; rechtsb. Leerzeichen wegnehmen
 move.l   d5,d1
 sub.l    a3,d1                    ; d1 = Laenge des Anfangs-Strings
 add.w    d0,d1                    ; + Laenge des End-Strings - Leerzeichen
 mulu     big_wchar,d1
 move.w   d1,g_w(a4)
 
 lea      vptsin,a1                ; GRECT *outg
 move.l   a4,a0                    ; GRECT *g
 moveq    #0,d2                    ; Breite berechnen
 moveq    #TE_RIGHT,d1
 moveq    #IBM,d0
 bsr      tjust
 bsr      gtext

; linksbuendigen Teil-String ins txvintin[]-Feld

 move.l   d5,a0                    ; Beginn des rechtsb. Teils
_odr_me_loop:
 cmpa.l   a3,a0
 bls.b    _odr_me_endloop
 cmpi.b   #' ',-(a0)
 beq.b    _odr_me_loop             ; rechtsb. Leerzeichen entfernen
 addq.l   #1,a0
_odr_me_endloop:
 move.l   a0,d0
 sub.l    a3,d0                    ; Laenge der Zeichenkette
 move.l   a3,a0                    ; Anfang der Zeichenkette
 bsr      lstr2int                 ; ins vintin[]-Feld
 beq      _odr_tstact              ; Text ist leer
 move.w   g_x(a4),d1
 bra.b    _odr_snoh

; kein Tastaturkuerzel: ganzen Teil ins txvintin-Feld

_odr_me_svi:
 move.l   a3,a0                    ; ob_spec
 bsr      str_to_ints
 beq      _odr_tstact              ; Text ist leer
 move.w   g_x(a4),d1
 bra.b    _odr_snoh

*
* case G_TITLE:
*

_odr_gtitle:
 bsr      _set_transptc

 moveq    #IBM,d0
 bsr      setfont

 tst.w    fontmono(a0)
 bne.b    _odr_string2

 move.l   a3,a0                    ; ob_spec
_odr_gt_loop:
 cmpi.b   #' ',(a0)+               ; Leerzeichen ueberlesen
 beq.b    _odr_gt_loop
 subq.l   #1,a0

;move.l   a0,a0
 bsr      str_to_ints
 beq      _odr_tstact              ; Text ist leer

 move.w   g_x(a5),d1
 add.w    big_wchar,d1             ; dafuer links Rand lassen
 bra.b    _odr_snoh

* einfacher String

_odr_string2:
 move.l   a3,a0                    ; ob_spec
 bsr      str_to_ints
 beq      _odr_tstact              ; Text ist leer

 moveq    #IBM,d0
 bsr      setfont

 move.w   g_x(a5),d1               ; xpos = x  (d5 wird nicht mehr benoetigt)
 subq.w   #6,d3                    ; G_BUTTON, d3 wird nicht mehr benoetigt)
 bne.b    _odr_snoh                ; nein

* G_BUTTON: horizontal zentrieren

 move.w   vintin_len,d0            ; Textlaenge
 bsr      extent
 move.w   g_w(a5),d1
 sub.w    d0,d1
 asr.w    #1,d1
 add.w    g_x(a5),d1

* G_BUTTON und G_STRING: vertikal zentrieren

_odr_snoh:
 swap     d1                       ; x ins Hiword

 move.w   g_h(a5),d0
 sub.w    finfo_big+fontcharH,d0   ; - Zeichenhoehe
 bgt.b    _odr_snohok
 moveq    #0,d0
_odr_snohok:
 lsr.w    #1,d0                    ; /2
 add.w    g_y(a5),d0               ; + y
 move.w   d0,d1                    ; ypos = y + (g_h-charh)/2

 move.l   d1,-(sp)                 ; d1 retten
 tst.w    -$10(a6)                 ; Activator ?
 beq.b    _obdrw_s3                ; nein
 bclr     #SELECTED_B,d4
 beq.b    _obdrw_s3
 addq.w   #1,d1
 swap     d1
 addq.w   #1,d1
 swap     d1
 move.l   d1,(sp)

_obdrw_s3:
 move.l   d1,vptsin                ; x,y
 bsr      gtext
 move.l   (sp)+,d1                 ; x,y zurueck
* auf Unterstrich pruefen
 bclr     #6,d4                    ; WHITEBAK ?
 beq      _odr_endsw               ; nein

* verschiedene Objekttypen: Unterstrich zeichnen
* in txvintin[] liegt noch der Text

_obdrw_unterstr:
 move.w   d4,d0
 lsr.w    #8,d0                    ; Hibyte von ob_state nach d0
 cmpi.b   #-1,d0
 bne.b    _obdrw_no_allu           ; nicht alles unterstreichen

; alles unterstreichen. Im Fall 3D oben weiss, unten dklgrau.

 move.w   g_h(a5),d1
 add.w    g_y(a5),d1
 subq.w   #1,d1
 move.w   d1,-(sp)                 ; y2
 move.w   g_x(a5),d1
 add.w    g_w(a5),d1
 subq.w   #1,d1
 move.w   d1,-(sp)                 ; x2
 move.w   2(sp),-(sp)              ; y1 = y2
 move.w   g_x(a5),-(sp)            ; x1
 tst.b    -$e(a6)                  ; 3D ?
 beq      _obdrw_dl                ; nein
 moveq    #9,d1                    ; dklgrau
 moveq    #REPLACE,d0
 bsr      stwmod_pcolor            ; unterer Unterstrich
 bsr      draw_line
 subq.w   #1,2(sp)
 subq.w   #1,6(sp)
 moveq    #WHITE,d1                ; oberer ist weiss
 bra.b    _obdrw_dl2

; nur einen Buchstaben unterstreichen.
; Position innerhalb des Textes: d0

_obdrw_no_allu:
 andi.w   #$0f,d0                  ; nur 4 Bits (27.6.99)
 cmp.w    vintin_len,d0
 bcc.b    _obdrw_no_under          ; ausserhalb der Zeichenkette

 add.w    finfo_big+fontUpos,d1
 move.w   d1,-(sp)                 ; y2
 subq.l   #2,sp
 move.w   d1,-(sp)                 ; y1
 swap     d1
 lea      finfo_big,a0
 tst.w    fontmono(a0)
 bne.b    _odr_un_mono
 move.w   d1,d5                    ; x
 move.w   d0,d3                    ; charpos retten

; fuer prop. Font

;move.w   d0,d0                    ; Textlaenge
 bsr      extent                   ; Pos. des Unterstrichs
 add.w    d5,d0
 subq.w   #1,d0
 move.w   d0,-(sp)                 ; x1
 move.w   d3,d0
 addq.w   #1,d0
 bsr      extent
 add.w    d5,d0
 subq.w   #2,d0
 move.w   d0,4(sp)                 ; x2
 bra.b    _obdrw_dl

; fuer mono Font

_odr_un_mono:
 mulu     big_wchar,d0
 add.w    d0,d1
 subq.w   #1,d1
 move.w   d1,-(sp)
 add.w    big_wchar,d1
 move.w   d1,4(sp)
_obdrw_dl:
 move.w   -4(a6),d1                ; tcolor
_obdrw_dl2:
 moveq    #REPLACE,d0
 bsr      stwmod_pcolor            ; Unterstrich wie Textfarbe
 bsr      draw_line
 addq.l   #8,sp
_obdrw_no_under:

*
* Jetzt nur noch das Statuswort auswerten
* wir benoetigen noch d4/d7/a5
*

_odr_endsw:
 tst.w    d4                       ; state
 beq      _odr_ende                ; nix
 bclr     #OUTLINED_B,d4
 beq.b    obdrw_l3
* OUTLINED

 moveq    #BLACK,d1
 bsr      strplc_pcolor

 move.l   4(a5),-(sp)              ; w+6
 addi.l   #$60006,(sp)             ; und h+6
 move.l   (a5),-(sp)
 subq.w   #3,2(sp)                 ; y - 3 (kann negativ werden!)
 subq.w   #3,(sp)                  ; x - 3 (kann negativ werden!)
 move.l   sp,a0
 moveq    #1,d0                    ; Rahmendicke 1
 bsr      zeichne_rahmen           ; Rahmen im Abstand von 3

 moveq    #WHITE,d1
 bsr      strplc_pcolor

 subi.l   #$20002,4(sp)            ;  6-2 = 4
 addq.w   #1,2(sp)
 addq.w   #1,(sp)                  ; -3+1 = 2
 move.l   sp,a0
 moveq    #2,d0                    ; Rahmendicke 2
 bsr      zeichne_rahmen           ; Rahmen im Abstand von 2
 addq.l   #8,sp

obdrw_l3:
 tst.w    d4                       ; state ausser OUTLINED
 beq      _odr_ende                ; nix
 move.w   d7,d0
 ble.b    obdrw_l4
* INNERER RAND
 move.l   a5,a0

 add.w    d0,(a0)+                 ; g.g_x += offs
 add.w    d0,(a0)+                 ; g.g_y += offs
 add.w    d0,d0
 sub.w    d0,(a0)+                 ; g.g_w -= 2*offs
 sub.w    d0,(a0)                  ; g.g_h -= 2*offs

 bra.b    obdrw_l5
obdrw_l4:
 neg.w    d7
obdrw_l5:
 btst     #SHADOWED_B,d4
 beq.b    obdrw_l6
* SHADOWED
 tst.w    d7                       ; Rahmendicke ?
 beq.b    obdrw_l6                 ; ist 0

* Schatten unten
 move.w   d7,d0
 add.w    d0,d0
 move.w   d0,-(sp)                 ; h = 2 * Breite
 move.w   4(a5),-(sp)
 add.w    d7,(sp)                  ; w = g.w + Breite
 move.w   2(a5),-(sp)
 move.w   6(a5),d0
 add.w    d0,(sp)
 add.w    d7,(sp)                  ; y = g.y + g.h + Breite
 move.w   (a5),-(sp)               ; x = g.x
 move.l   sp,a0                    ; GRECT *
 moveq    #IP_SOLID,d2
 move.w   -2(a6),d1                ; Farbe
 moveq    #REPLACE,d0
 bsr      drawbox
 addq.l   #8,sp
* Schatten rechts
 move.w   d7,d0
 add.w    d0,d0
 add.w    d7,d0                    ; * 3
 move.w   d0,-(sp)
 move.w   6(a5),d0
 add.w    d0,(sp)                  ; h = g.h + 3 * Breite
 move.w   d7,d0
 add.w    d0,d0
 move.w   d0,-(sp)                 ; w = 2 * Breite
 move.l   (a5),-(sp)               ; y = g.y
 move.w   4(a5),d0
 add.w    d0,(sp)
 add.w    d7,(sp)                  ; x = g.x + g.w + Breite
 move.l   sp,a0                    ; GRECT *
 moveq    #IP_SOLID,d2
 move.w   -2(a6),d1                ; Farbe
 moveq    #REPLACE,d0
 bsr      drawbox
 addq.l   #8,sp
obdrw_l6:
 btst     #CHECKED_B,d4
 beq.b    obdrw_l7
* CHECKED
 moveq    #BLACK,d1
 moveq    #TRANSPARENT,d0
 bsr      stwmod_tcolor

 moveq    #IBM,d0                  ; grosse Zeichen
 bsr      setfont

 move.w   #8,txvintin              ; Das Haekchen
 move.w   #1,vintin_len            ; 1 Zeichen
 st       vintin_dirty             ; Steuerzeichen!
 move.l   g_x(a5),vptsin
 addq.w   #2,vptsin                ; x+2,y
 bsr      gtext
obdrw_l7:
 btst     #CROSSED_B,d4
 beq.b    obdrw_l8
* CROSSED
 moveq    #WHITE,d1
 moveq    #TRANSPARENT,d0
 bsr      stwmod_pcolor

 move.l   (a5),-(sp)
 move.l   4(a5),d0
 sub.l    #$10001,d0
 add.l    d0,(sp)
 move.l   (a5),-(sp)
 bsr      draw_line
 addq.l   #8,sp

 move.w   2(a5),-(sp)
 move.l   (a5),d1
 move.l   4(a5),d0
 sub.l    #$10001,d0
 add.l    d0,d1
 swap     d1
 move.l   d1,-(sp)
 move.w   (a5),-(sp)
 bsr      draw_line
 addq.l   #8,sp

obdrw_l8:
 btst     #DISABLED_B,d4
 beq.b    obdrw_l9
* DISABLED
 move.l   a5,a0
 moveq    #IP_4PATT,d2             ; Muster: grau
 moveq    #WHITE,d1
 tst.b    -$13(a6)                 ; 3D Background ?
 beq.b    _odr_disab_white
 moveq    #LWHITE,d1
_odr_disab_white:
 moveq    #TRANSPARENT,d0
 bsr      drawbox
obdrw_l9:
 btst     #SELECTED_B,d4
 beq.b    _odr_ende
 tst.b    -$e(a6)                  ; 3D ?

 beq.b    _odr_xorsel              ; nein, XOR-Maske!
 tst.b    -$13(a6)                 ; FL3DBAK ?
 beq.b    _odr_ende                ; nein
_odr_xorsel:
* SELECTED
 move.l   a5,a0
 moveq    #IP_SOLID,d2             ; voll (einfarbig)
 moveq    #BLACK,d1                ; color (vom Original nicht gesetzt)
 moveq    #XOR,d0
 bsr      drawbox
_odr_ende:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts



**********************************************************************
*
* PUREC void objc_draw(OBJECT *tree, GRECT *g, WORD startob, WORD depth)
*
* void objc_draw(a0 = OBJECT *tree, a1 = GRECT *g, d0 = int startob,
*              d1 = int depth)
*

objc_draw:
 movem.l  a0/d0/d1,-(sp)
 move.l   a1,d0
 bne.b    obdr_ok
 lea      desk_g,a1
obdr_ok:
 move.l   a1,a0
 bsr      set_clip_grect
 movem.l  (sp)+,a0/d0/d1
;bra.b    _objc_draw


**********************************************************************
*
* PUREC void _objc_draw(OBJECT *tree, WORD startob, WORD depth)
*
* void _objc_draw(a0 = OBJECT *tree, d0 = int startob, d1 = int depth)
*
* Das Clipping ist bereits mit set_clip_grect() eingeschaltet
*

YTAB SET  -(4*MAXDEPTH)
XTAB SET  -(2*MAXDEPTH)

_objc_draw:
 link     a6,#YTAB
 movem.l  d3/d5/d6/d7/a2/a3/a4/a5,-(sp)
 move.l   a0,a5                    ; tree
 move.w   d1,d5                    ; d5 = depth
 move.w   d0,d6                    ; startob
 moveq    #-1,d7                   ; endob = -1
 bsr      mouse_off
 moveq    #0,d2                    ; Offset x,y = 0
 move.w   d6,d0
 beq.b    objcd_all                ; alle Objekte (ab Root)
* nicht Objekt 0, also bis folgendes Objekt malen, dies kann auch das
* Elterobjekt sein (ob_next)
 muls     #24,d0
 move.w   0(a5,d0.l),d7            ; endob = ob_next
 bmi      walk_end                 ; Fehler! (siehe Technobox CAD)
 move.w   d6,d0                    ; startob
 move.l   a5,a0                    ; tree
 bsr      parentob
* d0 ist jetzt das Elterobjekt
;move.w   d0,d0                    ; Elterobjekt
 move.l   a5,a0                    ; tree
 bsr      _objc_offset
 move.w   d0,d2                    ; x
 swap     d2                       ; ins Hiword
 move.w   d1,d2                    ; y ins Loword
objcd_all:


**********************************************************************
*
* void draw_obj_tree(a5 = OBJECT *tree, d6 = int firstob, d7 = int lastob,
*                    a3 = void (*pgm(OBJECT *tree, int objnr, int x, int y)),
*                    d2 = {int offsx, int offsy}, d5 = int maxdepth)
*
* Spezialfall von "walk_obj_tree", nur fuer das Zeichnen von Objekten
*

draw_obj_tree:
 lea      __objc_draw(pc),a3

 move.w   d2,YTAB(a6)              ; offsy
 swap     d2
 move.w   d2,XTAB(a6)              ; offsx

 add.w    d5,d5                    ; maxdepth fuer int- Zugriff
 moveq    #2,d3                    ; Zaehler auf 1 (fuer int- Zugriff)
* Durchlaufe Schleife, bis letztes Element erreicht
walk_loop:
 cmp.w    d7,d6                    ; aktuelles == letztes Element ?
 beq      walk_end                 ; ja, Ende

 moveq    #0,d0                    ; Hiword loeschen
 move.w   d6,d0
 lsl.l    #3,d0
 move.l   a5,a4
 add.l    d0,a4
 add.l    d0,a4
 add.l    d0,a4                    ; a4 auf OBJECT

walk_loop_tiny:
 lea      XTAB-2(a6,d3.w),a0
 move.w   (a0)+,d1                 ; xkoor[d3-1]
 add.w    ob_x(a4),d1
 move.w   d1,(a0)                  ; xkoor[d3]
 swap     d1                       ; ins Hiword

 lea      YTAB-2(a6,d3.w),a0
 move.w   (a0)+,d1                 ; ykoor[d3-1]
 add.w    ob_y(a4),d1
 move.w   d1,(a0)                  ; ykoor[d3]
                                   ; ins Loword

 move.w   d6,d0                    ; aktuelle Objektnummer
 move.l   a4,a1                    ; ob, Zeiger auf aktuelles Objekt
 move.l   a5,a0                    ; tree
 jsr      (a3)                     ; Routine aufrufen

 move.w   ob_head(a4),d1           ; d1 = ob_head
 cmp.w    #-1,d1
 beq.b    walk_loop2               ; hat keine Kinder

* d6 hat d1 als erstes Kind

 btst     #7,ob_flags+1(a4)        ; HIDETREE ?
 bne.b    walk_loop2               ; ja
 cmp.w    d5,d3                    ; maximale Tiefe erreicht ?
 bhi.b    walk_loop2

* Eine Ebene weiter gehen

 addq.w   #2,d3                    ; Zaehler erhoehen (2 wegen int- Zugriff)
 move.w   d1,d6                    ; erstes Kind betrachten
 bra      walk_loop                ; -> loop

* d6 hat keine Kinder, oder ist HIDETREE, oder maximale Tiefe erreicht

walk_loop2:
 move.w   d6,d1                    ; Root erreicht ? (vorheriges Obj. retten)
 beq.b    walk_end                 ; ja, Ende
 move.w   ob_next(a4),d6           ; d6 = ob_next
 cmp.w    d7,d6                    ; Endobjekt erreicht ?
 beq.b    walk_end                 ; ja, Ende
 moveq    #0,d0                    ; Hiword loeschen
 move.w   d6,d0
 lsl.l    #3,d0
 move.l   a5,a4
 add.l    d0,a4
 add.l    d0,a4
 add.l    d0,a4                    ; OBJECT aktualisieren
 cmp.w    ob_tail(a4),d1           ; akt. Objekt == ob_tail(ob_next) ?
 bne      walk_loop_tiny           ; nein, naechstes Objekt

* Ende der Ebene erreicht, eine Stufe zurueckgehen

 subq.w   #2,d3                    ; Zaehler dekrementieren (wegen int)
 bgt.b    walk_loop2               ; Objekt ueberspringen (schon bearbeitet)
walk_end:
 movem.l  (sp)+,d3/d5/d6/d7/a5/a4/a3/a2
 unlk     a6
 bra      mouse_on                 ; aendert nicht a2


**********************************************************************
*
* PUREC WORD _objc_find( OBJECT *tree, WORD startob,
*                        WORD depth, LONG xy )
*
* int _objc_find(a0 = OBJECT *tree, d0 = int startob, d1 = int depth,
*               d2 = {int x, int y} )
*

_objc_find:
 movem.l  d3/d4/d5/d6/d7/a4/a5,-(sp)
 subq.l   #8,sp
 move.l   sp,a4                    ; GRECT des parent
 subq.l   #8,sp                    ; GRECT
 moveq    #-1,d7                   ; noch nichts gefunden


 move.l   a0,a5                    ; a5 = tree
 move.w   d1,d5                    ; d5 = depth
 move.w   d2,d4
 swap     d2
 move.w   d2,d3

 move.w   d0,d6                    ; d6 = startob, ist root ?
 bne.b    obfn_l1                  ; nein

* Wir starten bei Objekt #0 und daher mit einem Offset (0,0)

 clr.l    (a4)                     ; parent hat (0,0)
 bra.b    obf_loop

* Wir starten mit einem Objekt ungleich #0

obfn_l1:
 move.w   d6,d0                    ; objnr != 0
 move.l   a5,a0                    ; tree
 bsr      parentob
 move.l   a4,a1
;move.w   d0,d0
 move.l   a5,a0
 jsr      obj_to_g                 ; GRECT des parent
                                   ; aendert nicht a2

* endif

obf_loop:
 move.l   sp,a1
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; tree
 bsr      get_ob_xywh              ; relatives GRECT nach sp
                                   ; aendert nicht a2
 move.w   (a4),d0
 add.w    d0,(sp)                  ; x des parent addieren
 move.w   g_y(a4),d0
 add.w    d0,g_y(sp)               ; y des parent addieren
 move.w   d6,d1
 muls     #24,d1
 lea      0(a5,d1.l),a1            ; a1 auf unser OBJECT

 move.l   sp,a0
 move.w   d4,d1
 move.w   d3,d0
 jsr      xy_in_grect              ; liegen wir drin ?
                                   ; aendert nicht a2

 beq.b    obfn_l2                  ; nein, isnich
 btst     #7,ob_flags+1(a1)        ; HIDETREE ?
 bne.b    obfn_l2                  ; ja,   isnich
* (x,y) passt
 move.w   d6,d7                    ; gefundene Objektnummer merken
 move.w   d6,d1
 muls     #24,d1
 move.w   ob_tail(a1),d0           ; letztes Kind
 addq.w   #1,d0                    ; existiert nicht ?
 beq      obf_ende                 ; nein, keine Kinder mehr suchen
 tst.w    d5                       ; depth Null ?
 beq.b    obf_ende                 ; ja, keine Kinder mehr suchen

* von aktuellem OBJECT zum letzen Kind
 subq.w   #1,d0
 move.w   d0,d6                    ; letztes Kind suchen
 subq.w   #1,d5                    ; depth herunterzaehlen
 move.l   (sp),(a4)                ; (x,y) des parent initialisieren
 bra.b    obf_loop                 ; weitersuchen

* passt nicht

obfn_l2:
 move.w   d7,d0
 addq.w   #1,d0                    ; noch nichts gefunden
 beq.b    obf_ende                 ; ja, parent passte auch schon nicht

 move.w   d6,d1                    ; suche Vorgaenger von d1 unter den Kindern
 move.w   d7,d0                    ;  von d7
 move.l   a5,a0                    ; tree
 bsr      pred_objc

 move.w   d0,d6                    ; d6 = Vorgaenger
 addq.w   #1,d0                    ; ist ungueltig ?
 bne      obf_loop                 ; nein, weiter
obf_ende:
 move.w   d7,d0
 adda.w   #16,sp
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* PUREC void objc_add( OBJECT *tree, WORD parent, WORD child);
*
* void objc_add(a0 = OBJECT *tree, d0 = int parent, d1 = int child)
*

objc_add:
 move.l   d3,-(sp)
 cmp.w    #$ffff,d0                ; parent
 beq.b    obad_ret
 cmp.w    #$ffff,d1                ; child
 beq.b    obad_ret
 move.w   d1,d3
 muls     #24,d3
 move.w   d0,0(a0,d3.l)            ; parent wird mein ob_next
 move.w   d0,d3
 muls     #24,d3
 lea      4(a0,d3.l),a1            ; &ob_tail des parent
 move.w   (a1),d2                  ; d2 = bisheriger tail
 cmp.w    #$ffff,d2                ; bisher kein tail ?
 bne.b    obad_l1                  ; doch
;move.w   d0,d3
;muls     #24,d3
 move.w   d1,2(a0,d3.l)            ; ich werde head
 bra.b    obad_l2
obad_l1:
 move.w   d2,d3
 muls     #24,d3
 move.w   d1,0(a0,d3.l)            ; ich werde ob_next des bisherigen tail
obad_l2:
 move.w   d1,(a1)                  ; ich werde tail
obad_ret:
 move.l   (sp)+,d3
 rts


**********************************************************************
*
* PUREC void objc_delete( OBJECT *tree, WORD objnr)
*
* void objc_delete(a0 = OBJECT *tree, d0 = int objnr)
*

objc_delete:
 movem.l  d4/d5/d7/a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = tree
 move.w   d0,d7                    ; d7 = objnr
 beq      obdl_ret                 ; ist Root, Ende
 move.w   d7,d0
 muls     #24,d0
 move.w   0(a5,d0.l),d4            ; ob_next in d4 merken
 move.w   d7,d0
 move.l   a5,a0
 bsr      parentob
 move.w   d0,d5                    ; d5 ist Parent- Objekt
 muls     #24,d0
 lea      ob_head(a5,d0.l),a0      ; a0 ist Zeiger auf ob_head
 lea      ob_tail(a5,d0.l),a4      ; a1 ist Zeiger auf ob_tail
 cmp.w    (a0),d7                  ; sind wir erstes Kind unseres Parent ?
 bne.b    obdl_l2                  ; nein
* Wir sind erstes Kind
 cmp.w    (a4),d7                  ; sind wir letztes Kind ?
 bne.b    obdl_l1                  ; nein
* Wir sind erstes und letztes Kind
 moveq    #-1,d4                   ; ob_next ist NIL
 move.w   d4,(a4)                  ; ob_tail des Parent loeschen
obdl_l1:
 move.w   d4,(a0)                  ; unser Nachfolger als ob_head
 bra.b    obdl_ret                 ; Ende

* Wir sind nicht erstes Kind

obdl_l2:
 move.w   d7,d1                    ; Vorgaenger von objnr suchen
 move.w   d5,d0                    ; in der Kinderliste von d5
 move.l   a5,a0                    ; tree
 bsr      pred_objc

 move.w   d0,d1                    ; d1 ist der Vorgaenger
 muls     #24,d0
 move.w   d4,0(a5,d0.l)            ; unser Nachfolger als ob_next
 cmp.w    (a4),d7                  ; sind wir letztes Kind
 bne.b    obdl_ret
* Wir sind letztes Kind
 move.w   d1,(a4)                  ; unseren Nachfolger eintragen
obdl_ret:
 movem.l  (sp)+,a5/a4/d7/d5/d4
 rts


**********************************************************************
*
* void objc_order(a0 = OBJECT *tree, d0 = int objnr, d1 = int pos)
*
* haengt das Objekt <objnr> in der Liste der Kinder seines parent,
* d.h. in der Liste seiner Geschwister an eine andere Position, z.B.:
*  <pos> =  0: Wir werden erstes  Kind, d.h. unterstes!
*  <pos> = -1: Wir werden letztes Kind, d.h. oberstes!
*

objc_order:
 movem.l  d5/d6/d7/a5,-(sp)
 move.l   a0,a5                    ; a5 = tree
 move.w   d0,d6                    ; d6 = objnr
 beq      obor_end                 ; Objekt selbst ist Parent, Ende
 move.w   d1,d7
;move.w   d6,d0
;move.l   a5,a0
 bsr      parentob
 move.w   d0,d5                    ; d5 ist Parent

 move.w   d6,d0
 move.l   a5,a0
 bsr      objc_delete              ; Objekt ausklinken

 move.l   a5,a1
 move.w   d5,d0
 muls     #24,d0
 add.l    d0,a1                    ; a1 = Zeiger auf Parent
 move.w   ob_head(a1),d1           ; d1 = ob_head des Parent
 move.l   a5,a2
 move.w   d6,d0
 muls     #24,d0
 add.l    d0,a2                    ; a2 = Zeiger auf unser Objekt
 tst.w    d7
 bne.b    obor_l1
* neue Position soll 0 sein
 move.w   d1,ob_next(a2)           ; wir werden erstes Kind
 move.w   d6,ob_head(a1)
 bra.b    obor_l6
obor_l1:
 cmpi.w   #-1,d7
 bne.b    obor_l2
* neue Position soll -1 sein
 move.w   d5,d0
 muls     #24,d0
 move.w   ob_tail(a5,d0.l),d1
 bra.b    obor_l5
obor_l2:
 moveq    #1,d2
 bra.b    obor_l4
obor_l3:
 move.w   d1,d0
 muls     #24,d0
 move.w   ob_next(a5,d0.l),d1
 addq.w   #1,d2
obor_l4:
 cmp.w    d7,d2
 blt.b    obor_l3
obor_l5:
 move.l   a5,a0
 move.w   d1,d0
 muls     #24,d0
 add.l    d0,a0
 move.w   (a0),ob_next(a2)
 move.w   d6,(a0)
obor_l6:
 cmp.w    (a2),d5
 bne.b    obor_end
 move.w   d5,d0
 muls     #24,d0
 move.w   d6,ob_tail(a5,d0.l)
obor_end:
 movem.l  (sp)+,a5/d7/d6/d5
 rts


**********************************************************************
*
* PUREC void _objc_change(OBJECT *tree, WORD objnr,
*                  WORD newstate, WORD draw)
*
* void _objc_change(a0 = OBJECT *tree, d0 = int objnr,
*                  d1 = int newstate, d2 = int draw)
*

_objc_change:
 movem.l  d7/d6/d5/d4/d3/a5/a3/a2,-(sp)
 subq.l   #8,sp                    ; GRECT
 move.l   a0,a5                    ; a5 = tree
 move.w   d0,d6                    ; d6 = objnr
 move.w   d1,d3

 move.w   d2,-(sp)

;move.w   d6,d0
;move.l   a5,a0
 bsr      unpack_objc

 move.w   (sp)+,d2

 move.w   d0,d7                    ; rahmen
 moveq    #20,d5                   ; Objekttyp wieder korrigieren
 add.w    d1,d5
 move.l   a1,a3                    ; ob_spec
 cmp.l    #-1,a3                   ; ob_spec ungueltig ?
 beq      obc_ende                 ; ja, nix tun
 move.l   ob_flags(a0),d0
;move.w   ob_state(a0),d0          ; alter Status
 cmp.w    d3,d0                    ; gleich neuem Status ?
 beq      obc_ende                 ; ja, nix tun
 move.l   d0,d4                    ; alter Status, Hiword ist ob_flags
 move.w   d3,ob_state(a0)          ; neuen Status setzen

 tst.w    d2                       ; zeichnen ?
 beq      obc_ende                 ; nein, Ende

 move.l   ob_width(a0),4(sp)       ; w und h ins GRECT schreiben

 move.w   d6,d0
 move.l   a5,a0
 bsr      _objc_offset             ; GRECT berechnen
 move.w   d0,(sp)                  ; x
 move.w   d1,2(sp)                 ; y
 jsr      mouse_off                ; Maus abschalten
 tst.w    d7                       ; rahmen
 bge.b    obch_l1                  ; ist innen
 clr.w    d7                       ; aeusseren loeschen
obch_l1:
 cmpi.w   #G_USERDEF,d5
 bne.b    obch_l2

* USERDEF
 move.l   sp,a0
 move.w   d3,-(sp)                 ; currstate
 move.w   d4,-(sp)                 ; prevstate
 move.l   a3,-(sp)                 ; USERBLK *
 move.l   a0,-(sp)                 ; GRECT *
 move.w   d6,-(sp)                 ; objnr
 move.l   a5,-(sp)                 ; tree
 jsr      do_userdef
 lea      18(sp),sp
 bra      obchg_mon_ende                ; Maus ein und Ende

* ELSE

obch_l2:
 move.w   d3,d0                    ; currstate
 eor.w    d4,d0                    ; prevstate, Aenderungen
 and.w    #1,d0                    ; bei SELECTED ?
 beq      obchg_draw               ; nein, ganz zeichnen
* SELECTED hat sich geaendert
 cmpi.w   #G_ICON,d5
 beq      obchg_draw
 cmpi.w   #G_CICON,d5
 beq      obchg_draw
 cmpi.w   #G_BUTTON,d5
 bne      objc_nob
 btst     #WHITEBAK_B,d3
 beq      objc_nob                 ; nein, normale Funktion
 btst     #15,d3
 beq      objc_nob
* Spezialbutton
 moveq    #0,d1                    ; 2D
 tst.w    enable_3d
 beq.b    objc_no3d2
 btst     #9+16,d4
 bne.b    objc_3d2
 btst     #10+16,d4
 beq.b    objc_no3d2
objc_3d2:
 moveq    #-1,d1                   ; 3D, nur SELECTED toggeln
objc_no3d2:
 btst     #RBUTTON_B+16,d4
 move.l   sp,a0                    ; GRECT
 beq.b    objc_no_rb
; Radiobutton
;move.l   sp,a0                    ; GRECT
;move.w   d1,d1                    ; 3D
 move.w   d3,d0                    ; ob_state
 bsr      _obd_rbutton
 bra      obchg_mon_ende
; Kreuzchenbutton
objc_no_rb:
;move.l   sp,a0
 move.w   d3,d0                    ; 3D: nicht nur Kreuzchen
 ori.w    #$8000,d0                ; komme von _objc_change
 bsr      _obd_crossbutton
 bra      obchg_mon_ende

objc_nob:
* kein Icon
 tst.w    enable_3d
 beq.b    objc_no3d
 move.l   d4,d0
 swap     d0
 andi.w   #FL3DACT,d0              ; 3D-Flags extrahieren
 beq.b    objc_no3d                ; keine gesetzt
 cmpi.w   #FL3DBAK,d0              ; Background-Objekt ?
 bne.b    obchg_draw               ; ACTIVATOR oder INDICATOR => ist 3D
objc_no3d:
 move.l   sp,a0
 move.w   g_h(a0),-(sp)
 move.w   d7,d0
 add.w    d0,d0
 sub.w    d0,(sp)
 move.w   g_w(a0),-(sp)
 sub.w    d0,(sp)
 move.w   g_y(a0),-(sp)
 add.w    d7,(sp)
 move.w   (a0),-(sp)
 add.w    d7,(sp)
 move.l   sp,a0                    ; GRECT *
 moveq    #7,d2                    ; IP_SOLID
 moveq    #1,d1                    ; Farbe
 moveq    #XOR,d0
 jsr      drawbox
 addq.l   #8,sp
 bra.b    obchg_mon_ende                ; Maus ein und Ende

obchg_draw:
 move.w   d6,d0
 mulu     #24,d0
 lea      0(a5,d0.l),a1            ; Zeiger auf OBJECT selbst

 move.l   (sp),d1                  ; x/y
 move.w   d6,d0                    ; objnr
;move.l   a1,a1                    ; OBJECT
 move.l   a5,a0                    ; Tree
 bsr      __objc_draw              ; neu zeichnen
obchg_mon_ende:
 jsr      mouse_on

obc_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a5/a3/a2/d3/d4/d5/d6/d7
 rts


**********************************************************************
*
* PUREC void obj_to_g( OBJECT *tree, WORD objnr, GRECT *g)
*
* void obj_to_g(a0 = OBJECT *tree, d0 = int objnr, a1 = GRECT *g)
*
* aendert nicht a2
*

obj_to_g:
 move.w   d0,d1
 muls     #24,d1
 move.l   ob_width(a0,d1.l),4(a1)  ; w/h
;move.l   a0,a0
;move.w   d0,d0
 bsr      _objc_offset
 move.w   d0,(a1)                  ; x
 move.w   d1,2(a1)                 ; y
 rts


**********************************************************************
*
* void get_ob_xywh(a0 = OBJECT *tree, d0 = int objnr, a1 = GRECT *g)
*
* aendert nicht a2
*

get_ob_xywh:
 muls     #24,d0
 lea      ob_x(a0,d0.l),a0         ; a0 auf ob_x
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)                ; GRECT kopieren
 rts


**********************************************************************
*
* void set_ob_xywh(a0 = OBJECT *tree, d0 = int objnr, a1 = GRECT *g)
*

set_ob_xywh:
 muls     #24,d0
 lea      ob_x(a0,d0.l),a0         ; a0 auf ob_x
 move.l   (a1)+,(a0)+
 move.l   (a1),(a0)                ; GRECT kopieren
 rts


**********************************************************************
*
* PUREC void objc_offset(OBJECT *tree, WORD objnr, WORD *x, WORD *y)
*

objc_offset:
 bsr.b    _objc_offset
 move.w   d0,(a1)
 move.l   4(sp),a1
 move.w   d1,(a1)
 rts


**********************************************************************
*
* d0/d1 = _objc_offset(a0 = OBJECT *tree, d0 = int objnr)
*
* aendert nur d0/d1/d2
*

_objc_offset:
 move.w   d3,-(sp)
 move.w   d4,-(sp)
 clr.w    d3
 clr.w    d4
offs_loop:
 move.w   d0,d1
 muls     #24,d1
 move.l   $10(a0,d1.l),d1          ; Hi: ob_x, Lo: ob_y
 add.w    d1,d4
 swap     d1
 add.w    d1,d3
 tst.w    d0
 ble.b    offs_ende                ; ist schon Root oder Fehler
;move.l   a0,a0
 bsr      parentob
 bra.b    offs_loop
offs_ende:
 move.w   d3,d0                    ; x
 move.w   d4,d1                    ; y
 move.w   (sp)+,d4
 move.w   (sp)+,d3
 rts


**********************************************************************
*
* pred_objc(a0 = OBJECT *tree, d0 = int parent, d1 = int objnr)
*
* Liefert den Vorgaenger von Objekt <objnr> in der Kinderliste von
* <parent>
*
* aendert nicht a2
*

pred_objc:
 move.w   d0,d2
 muls     #24,d2
 move.w   ob_head(a0,d2.l),d0      ; d0 = erstes Kind von <parent>
 cmp.w    d1,d0                    ; Ende erreicht ?
 beq.b    prdo_ret_m1              ; ja, return(-1)
prdo_loop:
 move.w   d0,d2
 muls     #24,d2
 move.w   ob_next(a0,d2.l),d2      ; d2 = naechstes Kind
 cmp.w    d1,d2                    ; Ende erreicht ?
 beq.b    prdo_ret                 ; ja, Vorgaenger von <d1> zurueckgeben
 move.w   d2,d0                    ; naechstes Kind
 bra.b    prdo_loop
prdo_ret_m1:
 moveq    #-1,d0
prdo_ret:
 rts




**********************************************************************
*
* void set_xor_black( void )
*
* Setzt Schreibmodus auf XOR und Linienfarbe auf BLACK
*

set_xor_black:
 jsr      set_full_clip
_set_xor_black:
 moveq    #BLACK,d1
 moveq    #XOR,d0
 jmp      stwmod_pcolor


