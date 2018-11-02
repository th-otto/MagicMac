**********************************************************************
**********************************************************************
*
* WINDOW MANAGER
*

     INCLUDE "aesinc.s"
        TEXT

     XREF      config_status       ; DOS

     XREF      _objc_draw
     XREF      _objc_change
     XREF      min,max,vmemcpy,leerstring,clrmem,fatal_w1,fatal_w2
     XREF      grects_intersect,grects_union
     XREF      set_clip_grect,get_clip_grect,xy_in_grect
     XREF      mouse_off,mouse_on
     XREF      update_1,update_0,mctrl_1,mctrl_0
     XREF      send_msg,kill_tree_structure
     XREF      inq_screenbuf
     XREF      blitcopy_rectangle,set_xor_black,_drawgrect
     XREF      gr_xslidbx,graf_slidebox
     XREF      graf_dragbox
     XREF      set_mouse_app,appl_yield,wait_n_clicks,wait_but_released
     XREF      _objc_offset,_objc_find
     XREF      set_topwind_app,appl_unhide,make_app_main
     XREF      gbest_wnd_app
     XREF      desk_on,desk_off,set_app

     XREF      graf_mouse

* von STD

     XREF      smalloc,smfree

* von DOS

     XREF      Mchgown

* von AESOBJ

     XREF      objc_draw
     XREF      objc_add
     XREF      set_full_clip
     XREF      obj_to_g

* von AESGRAF

     XREF      evnt_rel_mm



     XDEF      wind_find
     XDEF      _wind_calc
     XDEF      _wind_get
     XDEF      _wind_get_grect
     XDEF      _wind_set
     XDEF      _wind_create
     XDEF      _wind_open
     XDEF      wind_close
     XDEF      wind_delete
     XDEF      whdl_to_wnd
     XDEF      wind0_draw
     XDEF      objc_wdraw,_objc_wdraw
     XDEF      objc_wchange
     XDEF      send_all_redraws
     XDEF      alloc_wgrect
     XDEF      calc_wgrect_overlaps
     XDEF      app_wind_redraw
     XDEF      build_new_wgs
     XDEF      wind_was_clicked
     XDEF      all_untop
     XDEF      top_my_window
     XDEF      init_windows
;    XDEF      wind_s3d
     XDEF      chg_3d
     XDEF      _wbm_create,_wbm_skind,_wbm_calc,_wbm_ssize,_wbm_sslid
     XDEF      _wbm_obfind,_wbm_sstr,_wbm_sattr


WINDXMINUS     EQU  1         ; Fenster duerfen links herausragen.

/* Fensterrahmen-Elemente */

O_FRAME        EQU  0   /* BOX in Baum T_WINDOW */
O_CLOSER       EQU  1   /* USERDEF in Baum T_WINDOW */
O_NAME         EQU  2   /* TEXT in Baum T_WINDOW */
O_BDROP        EQU  3   /* USERDEF in Baum T_WINDOW */
O_FULLER       EQU  4   /* USERDEF in Baum T_WINDOW */
O_INFO         EQU  5   /* BOXTEXT in Baum T_WINDOW */
O_SIZER        EQU  6   /* USERDEF in Baum T_WINDOW */
O_UP           EQU  7   /* BOX in Baum T_WINDOW */
O_DOWN         EQU  8   /* BOX in Baum T_WINDOW */
O_VSCROLL      EQU  9   /* BOX in Baum T_WINDOW */
O_VSLIDE       EQU  10  /* BOX in Baum T_WINDOW */
O_LEFT         EQU  11  /* BOX in Baum T_WINDOW */
O_RIGHT        EQU  12  /* BOX in Baum T_WINDOW */
O_HSCROLL      EQU  13  /* BOX in Baum T_WINDOW */
O_HSLIDE       EQU  14  /* BOX in Baum T_WINDOW */
O_ICONIFIER    EQU  15  /* USERDEF in Baum T_WINDOW */


whdl_to_wnd:                       ; aendert nur d0/a0
 cmp.w    nwindows,d0
 bcc.b    w2w_err
 move.l   windx,a0
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0
 add.w    d0,a0
 move.l   (a0),d0                  ; EQ/NE
 move.l   d0,a0                    ; a0 = WINDOW *
 rts
w2w_err:
 moveq    #0,d0
 move.l   d0,a0
 rts


**********************************************************************
*
* WINDOW *__wind_create( a0 = WINDOW *w, a1 = APPL *ap, d0 = int whdl,
*                        d1 = int kind)
*
* aendert nicht a2
*

__wind_create:
 move.w   d0,w_whdl(a0)
 move.w   d1,w_kind(a0)            ; alle Bits gnadenlos uebernehmen
 move.l   a1,w_owner(a0)
 clr.w    w_attr(a0)               ; alle Attribute loeschen
 clr.w    w_state(a0)
 clr.w    w_vslide(a0)
 clr.w    w_hslide(a0)
 moveq    #-1,d0
 move.w   d0,w_vslsize(a0)
 move.w   d0,w_hslsize(a0)
 lea      leerstring,a1
 move.l   a1,w_name(a0)            ; NAME/INFO auf Leerstring
 move.l   a1,w_info(a0)
 rts


**********************************************************************
*
* void get_hwout(a0 = GRECT *dst, d0 = int whdl)
*
* Ermittelt Umriss des Fensters, d.h. CURRXYWH mit Schatten
*

get_hwout:
 add.w    d0,d0
 add.w    d0,d0
 move.l   windx,a1
 move.l   0(a1,d0.w),a1
 move.l   w_overall(a1),(a0)+
 move.l   w_overall+g_w(a1),(a0)
 rts


**********************************************************************
*
* PUREC void objc_wchange(OBJECT *tree, WORD objnr,
*                  WORD newstate, GRECT *g, WORD whdl )
*
* void objc_wchange(a0 = OBJECT *tree, d0 = int objnr,
*                  d1 = int newstate, a1 = GRECT *g, d2 = WORD whdl)
*
* Bei <whdl> == -1 wird <g> ignoriert, und _objc_change aufgerufen
*

objc_wchange:
 tst.w    d2
 bge.b    __objc_wchange
 moveq    #1,d2                    ; zeichnen
 jmp      _objc_change
__objc_wchange:
 movem.l  d0/d2/a0/a1/a2,-(sp)
 moveq    #0,d2                    ; nicht zeichnen
;move.w   d1,d1                    ; newstate
;move.w   d0,d0                    ; objnr
;move.l   a0,a0                    ; tree
 jsr      _objc_change
 movem.l  (sp)+,d0/d2/a0/a1/a2

;move.w   d2,d2                    ; whdl
;move.l   a1,a1                    ; &g
 moveq    #1,d1                    ; nur Objekt selbst malen
;move.w   d0,d0                    ; startob
;move.l   a0,a0                    ; tree
 bra.b    objc_wdraw


**********************************************************************
*
* void _objc_wdraw( a0 = OBJECT *tree, d0 = WORD startob, d1 = WORD depth,
*                        a1 = GRECT *g, d2 = WORD whdl,
*                   (void *) (function)() )
*

_objc_wdraw:
 movem.l  d6/d7/a2/a3/a4/a5/a6,-(sp)
 move.l   4+28(sp),a3                   ; function()
 bra.b    __objc_wdraw


**********************************************************************
*
* PUREC void objc_wdraw( OBJECT *tree, WORD startob, WORD depth,
*                        GRECT *g, WORD whdl)
*
* void objc_wdraw( a0 = OBJECT *tree, d0 = WORD startob, d1 = WORD depth,
*                        a1 = GRECT *g, d2 = WORD whdl)
*
* Wie objc_draw(), beruecksichtigt aber die Fenster-Rechteckliste des
* angegebenen Fensters.
* Wenn <tree> == windowbox, wird _NICHT_ mit WORKXYWH geschnitten.
* Wenn whdl < 0: Wie objc_draw()
*

objc_wdraw:
 tst.w    d2
 bge.b    obw_go
 jmp      objc_draw
obw_go:
 movem.l  d6/d7/a2/a3/a4/a5/a6,-(sp)
 lea      _objc_draw(pc),a3
__objc_wdraw:
 subq.l   #8,sp                    ; sizeof(GRECT)
 move.l   a0,a6                    ; a6 = tree
 move.w   d0,d7                    ; d7 = startob
 move.w   d1,d6                    ; d6 = depth
 movea.l  a1,a5                    ; a5 = GRECT

 move.w   d2,d0                    ; whdl
 bsr      whdl_to_wnd
 beq.b    obw_err                  ; Fenster ungueltig
 move.l   w_wg(a0),a4

 move.l   a5,d0                    ; GRECT angegeben?
 beq.b    obw_no_clip              ; nein, ganzer Bildschirm

 move.l   (a5)+,(sp)
 move.l   (a5),4(sp)               ; Kopie des GRECT anlegen

;cmpa.l   #windowbox,a6
;beq.b    obw_no_work
 lea      w_tree(a0),a1
 cmpa.l   a1,a6                    ; es ist der Rahmen
 beq.b    obw_no_work

 lea      (sp),a1
 lea      w_work(a0),a0
 jsr      grects_intersect         ; GRECT mit WORKXYWH schneiden
 beq.b    obw_err
obw_no_work:
 move.l   sp,a1
 lea      desk_g,a0
 jsr      grects_intersect         ; GRECT mit Bildschirm schneiden
 beq.b    obw_err
 move.l   sp,a5                    ; mit dem Schnitt weiterarbeiten

 bra.b    obw_weiter
obw_no_clip:
 lea      desk_g,a5
obw_weiter:
 bra.b    obw_next_wg

* Schleife fuer jedes Rechteck der Rechteckliste

obw_loop:
 move.l   8(a4),-(sp)
 move.l   4(a4),-(sp)              ; Fenster-Rechteck auf den Stack
 move.l   sp,a1
 move.l   a5,a0
 jsr      grects_intersect         ; Rechteck schneiden
 beq.b    obw_next                 ; leerer Schnitt

 move.l   sp,a0
 jsr      set_clip_grect

 move.w   d6,d1                    ; depth
 move.w   d7,d0                    ; startob
 move.l   a6,a0                    ; tree
 jsr      (a3)

obw_next:
 addq.l   #8,sp
 movea.l  (a4),a4
obw_next_wg:
 move.l   a4,d0
 bne.b    obw_loop
obw_err:
 addq.l   #8,sp
 movem.l  (sp)+,a6/a5/a4/a3/a2/d7/d6
 rts


**********************************************************************
*
* void wind0_draw(a0 = GRECT *g)
*

wind0_draw:
 move.l   a0,-(sp)
 bsr      mouse_off
 move.l   (sp)+,a1                 ; a1 = GRECT
 move.l   desktree,d0
 beq.b    w0d_no_user_tree
* benutzerdefinierter Desktophintergrund
 move.l   d0,a0                    ; tree
 moveq    #8,d1                    ; Tiefe = MAXDEPTH
 move.w   desktree_1stob,d0        ; erstes Objekt
 bra.b    w0d_draw
w0d_no_user_tree:
 lea      shelw_startpic,a0        ; tree
 moveq    #0,d1                    ; nur Wurzelobjekt
 moveq    #0,d0                    ; ab Objekt 0
w0d_draw:
;addq.w   #2,g_w(a1)               ; ??
;addq.w   #2,g_h(a1)               ; ??
 moveq    #0,d2                    ; Handle 0
;move.l   a1,a1                    ; GRECT
;move.w   d1,d1                    ; depth
;move.w   d0,d0                    ; startob
;move.l   a0,a0                    ; tree
 bsr      objc_wdraw
 bra      mouse_on


**********************************************************************
*
* void wind_draw_whole( d0 = int whdl )
*
* Erstellt den Objektbaum fuer <whdl> und zeichnet ihn komplett.
*

wind_draw_whole:
 suba.l   a0,a0                    ; ganzer Rahmen (nicht nur Ausschnitt)
 moveq    #0,d1                    ; ab Objekt 0
;move.w   d0,d0                    ; neues oberstes Fenster neu zeichnen
;bra.b    wind_draw


**********************************************************************
*
* void wind_draw( d0 = int whdl, d1 = int startobj,
*                   a0 = GRECT *clipg )
*
* Erstellt den Objektbaum fuer <whdl> und zeichnet ihn.
* <clipg> kann NULL sein.
*

wind_draw:
 movem.l  a4/d6/d7,-(sp)
 subq.l   #8,sp
 move.w   d0,d7                    ; whdl
 move.l   a0,a1                    ; clipg
 move.w   d1,d6                    ; startob
 move.w   d7,d0
 bsr      whdl_to_wnd
 move.l   a0,a4                    ; a4 = WINDOW *
 move.l   a1,d0                    ; clipg?
 bne.b    wdr_clip

* ganzes Fenster

 move.l   w_overall(a4),(sp)
 move.l   w_overall+g_w(a4),g_w(sp)     ; CURRXYWH mit Schatten
 bra.b    wdr_both

* Clipping setzen

wdr_clip:
 move.l   g_x(a1),g_x(sp)
 move.l   g_w(a1),g_w(sp)
 move.l   a1,a0
 jsr      set_clip_grect

wdr_both:
 move.w   d7,d2                    ; whdl
 lea      (sp),a1                  ; GRECT
 moveq    #MAXDEPTH,d1             ; depth
 move.w   d6,d0                    ; startob
 lea      w_tree(a4),a0
 bsr      objc_wdraw

 addq.l   #8,sp
 movem.l  (sp)+,d6/d7/a4
 rts


**********************************************************************
*
* void _wbm_create( a0 = WINDOW *w )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion)
*
* Kopiert den Objektbaum in die Fenster-Struktur
*

_wtedinfo:
 DC.L     leerstring
 DC.L     0,0                      ; TEDINFO fuer NAME/INFO
 DC.W     3                        ; te_font IBM
 DC.W     1                        ; te_resvd
 DC.W     0                        ; te_just TE_LEFT
 DC.W     $1100                    ; te_color
 DC.W     0                        ; te_resvd2
 DC.W     1                        ; te_thickness
 DC.W     80                       ; te_txtlen
 DC.W     50                       ; te_tmplen

_wbm_create:
 move.l   a0,d2                    ; w merken
 lea      w_tree(a0),a0            ; Ziel

* erst den Baum

 lea      windowbox_types(pc),a1
 moveq    #0,d1
 lea      windowbox_specs(pc),a2
 moveq    #N_WINOBJS-1,d0
 move.w   #SHADOWED,ob_state(a0)   ; Fenster haben einen Schatten
 bra.b    _wbc_l1

_wbc_loop:
 clr.w    ob_state(a0)
_wbc_l1:
 clr.w    ob_flags(a0)
 move.b   (a1)+,d1                 ; Objekttyp holen (Hibyte ist 0)
 move.w   d1,ob_type(a0)

 move.l   (a2)+,ob_spec(a0)
 clr.l    ob_x(a0)                 ; Default: x=y=0
 move.w   gr_hwbox,ob_width(a0)    ; Default: w=gr_hwbox
 move.w   gr_hhbox,ob_height(a0)   ; Default: h=gr_hhbox
 lea      24(a0),a0                ; naechstes OBJECT
 dbra     d0,_wbc_loop

 move.l   d2,a2                    ; w

* Hoehe der INFO Zeile

 move.w   inw_height,w_tree+O_INFO*24+ob_height(a2)

* 3D-Flag

 btst.b   #3,look_flags+1          ; Fenstertitel mit Linien ?
 beq.b    _wbc_noold               ; ja, WINTITLE nicht austauschen
 move.w   #G_BOXTEXT,w_tree+O_NAME*24+ob_type(a2)
_wbc_noold:

* dann die TEDINFOs

 lea      w_ted1(a2),a0
 move.l   a0,d1                    ; tedinfo1 merken
 move.l   a0,w_tree+O_NAME*24+ob_spec(a2)
 lea      w_ted2(a2),a1
 move.l   a1,w_tree+O_INFO*24+ob_spec(a2)

 lea      _wtedinfo(pc),a2
 moveq    #(te_sizeof/2)-1,d0
_wbc_tloop:
 move.w   (a2),(a0)+
 move.w   (a2)+,(a1)+
 dbra     d0,_wbc_tloop

 move.l   d1,a2
 move.w   #TE_CNTR,te_just(a2)     ; tedinfo1 (NAME zentriert)

 move.w   #PFINFO,te_sizeof+te_font(a2)      ; tedinfo2 (INFO Zeichensatz)
 pea      finfo_inw
 move.w   (sp)+,te_sizeof+te_resvd1(a2)      ; Hiword auf FINFO
 move.w   (sp)+,te_sizeof+te_resvd2(a2)      ; Loword auf FINFO
 move.w   #TE_SPECIAL,te_sizeof+te_just(a2)  ; INFO: Spezialausrichtung

 move.l   d2,a0                    ; w
 move.w   enable_3d,d0             ; alten Modus behalten
 bra      wind_s3d                 ; Fenster 2D/3D umschalten


**********************************************************************
*
* void __wbm_sk_slider( d0 = WORD firstob,
*                         d1 = WORD bits, d6 = WORD kind,
*                         a6 = OBJECT *tree)
*
* wird nur von _wbm_skind() aufgerufen
*

__wbm_sk_slider:
 movem.l  d4/d5,-(sp)
 move.w   d0,d4                    ; objnr
 move.w   d1,d5                    ; bits (6/7/8 bzw. 9/10/11)

 btst     d5,d6                    ; uparrow bzw. lfarrow
 beq.b    _wsks_no_upar_lfar
 move.w   d4,d1                    ; Objekt fuer uparrow/lfarrow
 moveq    #0,d0                    ; parent
 move.l   a6,a0
 bsr      objc_add

_wsks_no_upar_lfar:
 addq.w   #1,d5                    ; naechstes Bit
 addq.w   #1,d4                    ; naechstes OBJECT
 btst     d5,d6
 beq.b    _wsks_no_dnar_rtar
 move.w   d4,d1                    ; Objekt fuer dnarrow/rtarrow
 moveq    #0,d0                    ; parent
 move.l   a6,a0
 bsr      objc_add

_wsks_no_dnar_rtar:
 addq.w   #1,d4                    ; naechstes OBJECT (scroll)
 move.w   d4,d1                    ; Objekt fuer vscroll/hscroll
 moveq    #0,d0                    ; parent
 move.l   a6,a0
 bsr      objc_add

 addq.w   #1,d5                    ; naechstes Bit (H/VSLIDE)
 btst     d5,d6
 beq.b    _wsks_no_slide

 move.w   d4,d1
 addq.w   #1,d1                    ; slider ist scroll+1
 move.w   d4,d0                    ; parent ist scroll
 move.l   a6,a0
 bsr      objc_add                 ; Slider

_wsks_no_slide:
 movem.l  (sp)+,d5/d4
 rts


**********************************************************************
*
* long _minimal_size(a0 = WINDOW *w)
*
* gibt in d0 die Minimalgroesse (w/h) eines Fensters zurueck.
*

_minimal_size:
 move.w   w_kind(a0),d2
 move.w   gr_hhbox,d1
 move.w   d1,d0                    ; unterer Rand immer!
 and.w    #NAME+CLOSER+FULLER+ICONIFIER,d2   ;obere Randelem.?
 beq.b    minsize_notop            ; nein
 add.w    d1,d0                    ; ja!
minsize_notop:
 move.w   w_kind(a0),d2
 btst     #INFO_B,d2
 beq.b    minsize_noinfo           ; nein
 add.w    inw_height,d0            ; ja, Hoehe addieren
 subq.w   #1,d0
minsize_noinfo:
 btst     #UPARROW_B,d2
 beq.b    minsize_noup
 add.w    d1,d0
minsize_noup:
 btst     #DNARROW_B,d2
 beq.b    minsize_nodn
 add.w    d1,d0
minsize_nodn:
 move.w   d0,-(sp)                 ; Minimalhoehe

 move.w   gr_hwbox,d1
 move.w   d1,d0                    ; rechter Rand immer!
 btst     #LFARROW_B,d2
 beq.b    minsize_nolf
 add.w    d1,d0
minsize_nolf:
 btst     #RTARROW_B,d2
 beq.b    minsize_nort
 add.w    d1,d0
minsize_nort:
 move.w   d0,-(sp)                 ; Minimalbreite
 move.w   d1,d0
 addq.w   #1,d0
 btst     #CLOSER_B,d2
 beq.b    minsize_nocl
 add.w    d1,d0
minsize_nocl:
 btst     #ICONIFIER_B,d2
 beq.b    minsize_no_iconifier
 add.w    d1,d0
minsize_no_iconifier:
 and.w    #7,d2
 beq.b    minsize_nobk
 add.w    d1,d0                    ; Backdrop beruecksichtigen
minsize_nobk:
 cmp.w    (sp),d0
 ble.b    minsize_ok2
 move.w   d0,(sp)                  ; Maximum bilden
minsize_ok2:
 move.l   (sp)+,d0
 rts


**********************************************************************
*
* void _wbm_skind( a0 = WINDOW *w )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion),
* wird aufgerufen bei wind_create() und wind_set(WF_KIND).
*
* Verkettet den Objektbaum in der Fenster-Struktur
*

_wbm_skind:
 movem.l  d3/d4/d6/a4/a6,-(sp)
 move.l   a0,a4                         ; a4 = WINDOW *
 bsr.s    _minimal_size
 move.l   d0,w_min_g+g_w(a4)            ; Minimalgroesse initialisieren
 lea      w_tree(a0),a6
 move.w   w_kind(a0),d6
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 beq.b    _wbsk_no_ic
 move.w   #NAME+MOVER,d6                ; Ikonifiziert: Nur Balken
_wbsk_no_ic:

; erst die ganze Verkettung loesen

 moveq    #N_WINOBJS,d0
 move.l   a6,a0
 bsr      kill_tree_structure

; nur die unveraenderlichen Objektpositionen hier setzen

 move.w   gr_hwbox,d3
 subq.w   #1,d3
 move.w   gr_hhbox,d4
 subq.w   #1,d4

 clr.w    O_NAME*24+ob_x(a6)            ; name ganz links
 clr.w    O_INFO*24+ob_y(a6)            ; info ganz oben
 clr.w    O_UP*24+ob_y(a6)              ; uparrow ganz oben

; dann Verkettung aufbauen

 move.w   d6,d0
 andi.w   #NAME+CLOSER+FULLER+ICONIFIER,d0   ; obere Randelem.
 beq      _wbsk_no_top


* 1. oberer Rand:
* ===============

 btst     #CLOSER_B,d6
 beq.b    _wbsk_noclose                 ; keine Closebox
* CLOSE Box erstellen
 add.w    d3,O_NAME*24+ob_x(a6)         ; NAME nach rechts
 moveq    #O_CLOSER,d1                  ; Objekt 1
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0
 bsr      objc_add                      ; Closebox

_wbsk_noclose:
 btst     #FULLER_B,d6
 beq.b    _wbsk_nofull                  ; keine Fullbox

* Fullbox

 moveq    #O_FULLER,d1                  ; Objekt 4
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0
 bsr      objc_add                      ; Fullbox

* Iconifier

_wbsk_nofull:
 moveq    #ICONIFIER_B,d0
 btst     d0,d6
 beq.b    _wbsk_noicon                  ; kein Iconifier
 moveq    #O_ICONIFIER,d1               ; Objekt 15
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0
 bsr      objc_add                      ; Iconifier

* links von der Fullbox bzw. vom Iconifier fuehren wir die Drop- Box ein:

_wbsk_noicon:
 btst     #2,look_flags+1               ; expliziter Backdrop-Button ?
 bne.b    _wbsk_nobckdr                 ; nein, deaktiviert
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 bne.b    _wbsk_nobckdr                 ; ja, kein Backdrop-Button
 moveq    #3,d1                         ; Objekt 3
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0
 bsr      objc_add                      ; Dropbox

_wbsk_nobckdr:
 moveq    #2,d1                         ; Objekt 2
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0
 bsr      objc_add                      ; Namensfeld

 add.w    d4,O_INFO*24+ob_y(a6)         ; INFO nach unten verschieben
 add.w    d4,O_UP*24+ob_y(a6)           ; UPARROW nach unten verschieben

* 2. Infozeile:
* ===============

_wbsk_no_top:
 btst     #INFO_B,d6
 beq.b    _wbsk_no_info                 ; nein
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    _wbsk_no_info                 ; ja, kein Info

 moveq    #O_INFO,d1
 moveq    #0,d0                         ; als Kind von Objekt 0
 move.l   a6,a0
 bsr      objc_add                      ; Infozeile

 move.w   O_INFO*24+ob_height(a6),d0
 add.w    d0,O_UP*24+ob_y(a6)           ; UPARROW nach unten verschieben

_wbsk_no_info:
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    _wbsk_no_right                ; ja, kein rechter Teil
 move.w   d6,d0
 andi.w   #VSLIDE+DNARROW+UPARROW,d0    ; rechte Elemente?
 bne.b    _wbsk_right                   ; ja
 move.w   d6,d0
 andi.w   #SIZER,d0                     ; unten rechts?
 beq.b    _wbsk_no_right                ; nein
; keine rechten Elemente, aber den SIZER
 move.w   d6,d0
 andi.w   #HSLIDE+LFARROW+RTARROW,d0    ; untere Elemente?
 bne.b    _wbsk_no_right                ; ja, nimm SIZER unten auf


* 3. rechter Teil
* ===============

_wbsk_right:
; Position des Scroll-Hintergrunds berechnen
 move.w   O_UP*24+ob_y(a6),O_VSCROLL*24+ob_y(a6)
;move.w   dcol_vsld,O_VSCROLL*24+ob_spec+2(a6)
 btst     #UPARROW_B,d6
 beq.b    _wbsk_no_upa
 add.w    d4,O_VSCROLL*24+ob_y(a6)
_wbsk_no_upa:
 moveq    #UPARROW_B,d1
 moveq    #7,d0                    ; Objekte 7,8,9,10
 bsr      __wbm_sk_slider
 move.w   d6,d0
 andi.w   #HSLIDE+RTARROW+LFARROW,d0
 bne.b    _wbsk_isbottom
 bra      _wbsk_no_bottom

* 4. unterer Teil
* ===============

_wbsk_no_right:
 move.w   d6,d0
 andi.w   #HSLIDE+RTARROW+LFARROW,d0
 beq      _wbsk_no_rightbottom
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    _wbsk_no_rightbottom     ; ja, kein unterer Teil

_wbsk_isbottom:
; Position des Scroll-Hintergrunds berechnen
 move.w   O_LEFT*24+ob_y(a6),O_HSCROLL*24+ob_y(a6)
;move.w   dcol_hsld,O_HSCROLL*24+ob_spec+2(a6)
 btst     #LFARROW_B,d6
 beq.b    _wbsk_no_lfa
 add.w    d3,O_HSCROLL*24+ob_y(a6)
_wbsk_no_lfa:
 moveq    #LFARROW_B,d1
 moveq    #11,d0                   ; Objekte 11,12,13,14
 bsr      __wbm_sk_slider

* 5. rechts unterer Teil
* ======================

* Der Sizer bzw. das leere Feld wird nur dann benoetigt, wenn er
* explizit verlangt wurde oder wenn sowohl rechte als auch untere
* Randelemente angefordert wurden

_wbsk_no_bottom:
 moveq    #6,d1                         ; Zeichen fuer SIZER
 btst     #SIZER_B,d6                   ; SIZER explizit verlangt ?
 bne.b    _wbsk_size                    ; ja, Objekt setzen
 move.w   d6,d0
 andi.w   #VSLIDE+DNARROW+UPARROW,d0    ; rechte Randelemente ?
 beq.b    _wbsk_no_rightbottom          ; nein
 move.w   d6,d0
 andi.w   #HSLIDE+LFARROW+RTARROW,d0    ; untere Randelemente ?
 beq.b    _wbsk_no_rightbottom          ; nein
 moveq    #0,d1                         ; kein Zeichen
_wbsk_size:
 move.b   d1,O_SIZER*24+ob_spec(a6)     ; size
 moveq    #O_SIZER,d1
 moveq    #0,d0                         ; Kind von 0
 move.l   a6,a0                         ; tree
 bsr      objc_add                      ; SIZER
_wbsk_no_rightbottom:

 movem.l  (sp)+,d3/d4/d6/a4/a6
 rts


**********************************************************************
*
* void _wbm_sattr( a0 = WINDOW *w, d0 = WORD chbits )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion).
* Wird aufgerufen, wenn das Attribut sich geaendert hat, d.h. wenn
* das Fenster z.B. aktiv oder inaktiv geworden ist.
*

_wbm_sattr:
 movem.l  a4/d7,-(sp)
 move.l   a0,a4
 move.w   d0,d7

 btst     #WSTAT_ACTIVE_B,d7
 beq      _wbsa_s2

* Status aktiv/nicht aktiv

 btst     #WSTAT_ACTIVE_B,w_state+1(a4)
 sne      d1
 andi.w   #2,d1                         ; d1 = 0 oder 2 (fuer int- Offset)

 lea      dcol_closer,a1
 move.w   0(a1,d1.w),w_tree+O_CLOSER*24+ob_spec+2(a4)
 lea      dcol_fuller,a1
 move.w   0(a1,d1.w),w_tree+O_FULLER*24+ob_spec+2(a4)
 lea      dcol_bdrop,a1
 move.w   0(a1,d1.w),w_tree+O_BDROP*24+ob_spec+2(a4)
 lea      dcol_iconify,a1
 move.w   0(a1,d1.w),w_tree+O_ICONIFIER*24+ob_spec+2(a4)
 lea      dcol_arup,a1
 move.w   0(a1,d1.w),w_tree+O_UP*24+ob_spec+2(a4)
 lea      dcol_ardwn,a1
 move.w   0(a1,d1.w),w_tree+O_DOWN*24+ob_spec+2(a4)
 lea      dcol_arlft,a1
 move.w   0(a1,d1.w),w_tree+O_LEFT*24+ob_spec+2(a4)
 lea      dcol_arrgt,a1
 move.w   0(a1,d1.w),w_tree+O_RIGHT*24+ob_spec+2(a4)

 lea      dcol_name,a1
 move.w   0(a1,d1.w),w_ted1+te_color(a4)
 lea      dcol_info,a1
 move.w   0(a1,d1.w),w_ted2+te_color(a4)
 btst     #SIZER_B,w_kind+1(a4)
 beq.b    _wbsa_nosiz
 lea      dcol_sizer,a1
 move.w   0(a1,d1.w),w_tree+O_SIZER*24+ob_spec+2(a4)
_wbsa_nosiz:
 btst     #3,w_kind(a4)                 ; HSLIDE
 beq.b    _wbsa_noh                     ; nein
 lea      dcol_hsld,a1
 move.w   0(a1,d1.w),w_tree+O_HSCROLL*24+ob_spec+2(a4)
 lea      dcol_hbar,a1
 move.w   0(a1,d1.w),w_tree+O_HSLIDE*24+ob_spec+2(a4)
_wbsa_noh:
 btst     #0,w_kind(a4)                 ; VSLIDE?
 beq.b    _wbsa_nov                     ; nein
 lea      dcol_vsld,a1
 move.w   0(a1,d1.w),w_tree+O_VSCROLL*24+ob_spec+2(a4)
 lea      dcol_vbar,a1
 move.w   0(a1,d1.w),w_tree+O_VSLIDE*24+ob_spec+2(a4)
_wbsa_nov:

_wbsa_s2:
 btst     #WSTAT_ICONIFIED_B,d7
 beq.b    _wbsa_s3

* Status ikonifiziert/normal

 moveq    #IBM,d1
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 beq.b    _wbsa_noic
 moveq    #SMALL,d1
_wbsa_noic:
 move.w   d1,w_ted1+te_font(a4)
 move.l   a4,a0
 bsr      _wbm_skind                    ; Baum neu aufbauen

_wbsa_s3:
 btst     #WSTAT_SHADED_B,d7
 beq.b    _wbsa_s4

* Status shaded/normal

 move.l   a4,a0
 bsr      _wbm_skind                    ; Baum neu aufbauen

_wbsa_s4:

 movem.l  (sp)+,a4/d7
 rts


**********************************************************************
*
* void _wbm_sslid( a0 = WINDOW *w, d0 = WORD vertical )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion).
* Wird aufgerufen, wenn die Sliderobjekte neu zu berechnen sind,
* d.h. bei Aenderung und Skalierung des Fensters.
* Wird nur aufgerufen, wenn ein ensprechender VSLIDE/HSLIDE
* angemeldet ist.
*

__sslid:
 add.w    d0,d0
 muls     d1,d0
 divs     #1000,d0
 bmi.b    _ssl_ovf
 addq.w   #1,d0
 asr.w    #1,d0
 rts
_ssl_ovf:
 subq.w   #1,d0
 asr.w    #1,d0
 rts

_wbm_sslid:
 lea      w_tree+13*24(a0),a1      ; Objekte 13/14
 lea      w_hslsize(a0),a0
 move.w   gr_hwbox,d1
 tst.b    d0                       ; isvertical
 beq.b    _wbsl_hor1
 lea      2-4*24(a1),a1            ; Objekte 9/10, x->x und ob_w->ob_h
 addq.l   #2,a0                    ; vslsize statt hslsize
 move.w   gr_hhbox,d1
_wbsl_hor1:

* Minimalgroesse bestimmen

 move.w   ob_width(a1),d2          ; Breite/Hoehe des Scrollers
 cmp.w    d1,d2
 bge.b    _wbsl_enough             ; Scrollergroesse >= Slidergroesse
 moveq    #0,d1
 tst.w    d2
 bmi.b    _wbsl_enough             ; Scrollergroesse negativ!
 move.w   d2,d1

* gewuenschte Groesse

_wbsl_enough:
 move.w   d1,ob_width+24(a1)       ; zulaessige Minimalgroesse setzen
 move.w   (a0),d1                  ; hslsize/vslsize
 addq.w   #1,d1
 beq.b    _wbsl_little             ; ganz klein, ist schon eingestellt

 subq.w   #1,d1
 move.w   d2,d0                    ; Breite/Hoehe von scroll
 bsr.s    __sslid                  ; aendert nur d0
;move.w   d0,d0
 cmp.w    ob_width+24(a1),d0       ; minimale Breite/Hoehe von slide
 ble.b    _wbsl_little
 move.w   d0,ob_width+24(a1)
_wbsl_little:
 subq.l   #4,a0
 move.w   (a0),d0                  ; w_hslide/w_vslide
 move.w   ob_width(a1),d1
 sub.w    ob_width+24(a1),d1
 bsr.s    __sslid                  ; aendert nur d0
 move.w   d0,ob_x+24(a1)
 rts


**********************************************************************
*
* void _wbm_sstr( a0 = WINDOW *w )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion),
*
* Wird aufgerufen, wenn die Zeichenkette fuer INFO oder NAME
* geaendert wurde.
*

_wbm_sstr:
 move.l   w_name(a0),w_ted1+te_ptext(a0);    tedinfo1
 move.l   w_info(a0),w_ted2+te_ptext(a0);    tedinfo2
 rts


**********************************************************************
*
* void _wbm_ssize( a0 = WINDOW *w )
*
* Fensterstruktur initialisieren (Default-Callback-Funktion),
* wird aufgerufen bei set_wind_xywh() und wind_set(WF_KIND).
*
* Berechnet w_work und modifiziert die Groessen der Fensterobjekte.
*

_wbm_ssize:
 movem.l  d3/d4/d6/a4,-(sp)
 move.l   a0,a4
 move.w   w_kind(a4),d6            ; d6 = w_kind
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 beq.b    _wbss_no_ic
 move.w   #NAME+MOVER,d6           ; Ikonifiziert: Nur Balken
_wbss_no_ic:

* Fensterstruktur modifizieren

 move.l   w_curr(a0),w_overall(a0)
 move.l   w_curr+g_w(a0),w_overall+g_w(a0)
 addq.w   #2,w_overall+g_w(a0)
 addq.w   #2,w_overall+g_h(a0)               ; Schatten!

 moveq    #1,d0                    ; WC_WORK
 move.w   d6,d1                    ; w_kind
 lea      w_work(a0),a1            ; out: WORKXYWH neu berechnen
 lea      w_curr(a0),a0            ; ing
 bsr      _wind_calc

* Objektbaum skalieren

 move.l   w_curr(a4),w_tree+ob_x(a4)    ; neue Position setzen
 move.l   w_curr+g_w(a4),d0             ; neue Groesse
 cmp.l    w_tree+ob_width(a4),d0        ; == alte Groesse?
 beq      _wbss_ende                    ; ja, keine Modifikation noetig
 move.l   d0,w_tree+ob_width(a4)        ; neue Groesse setzen

 move.w   gr_hwbox,d3
 move.w   gr_hhbox,d4

/* Objekte am rechten Rand: */

 move.w   w_curr+g_w(a4),d0
 sub.w    d3,d0                    ; Breite des rechten Randes
 move.w   d0,w_tree+O_BDROP*24+ob_x(a4)
 move.w   d0,w_tree+O_FULLER*24+ob_x(a4)
 move.w   d0,w_tree+O_ICONIFIER*24+ob_x(a4)
 move.w   d0,w_tree+O_SIZER*24+ob_x(a4)
 move.w   d0,w_tree+O_UP*24+ob_x(a4)
 move.w   d0,w_tree+O_DOWN*24+ob_x(a4)
 move.w   d0,w_tree+O_VSCROLL*24+ob_x(a4)

/* Objekte am unteren Rand: */

 move.w   w_curr+g_h(a4),d0
 sub.w    d4,d0
 move.w   d0,w_tree+O_SIZER*24+ob_y(a4)
 move.w   d0,w_tree+O_LEFT*24+ob_y(a4)
 move.w   d0,w_tree+O_RIGHT*24+ob_y(a4)
 move.w   d0,w_tree+O_HSCROLL*24+ob_y(a4)

 subq.w   #1,d3
 subq.w   #1,d4
 move.w   w_curr+g_w(a4),w_tree+2*24+ob_width(a4) ; name volle Breite
 move.w   w_curr+g_w(a4),w_tree+5*24+ob_width(a4) ; info volle Breite

 move.w   d6,d0
 andi.w   #NAME+CLOSER+FULLER+ICONIFIER,d0   ; obere Randelem.
 beq      _wbss_no_top


* 1. oberer Rand:
* ===============

 btst     #1,d6                         ; CLOSE ?
 beq.b    _wbss_noclose                 ; keine Closebox
* CLOSE Box erstellen
 sub.w    d3,w_tree+O_NAME*24+ob_width(a4)   ; Breite anpassen

_wbss_noclose:
 btst     #2,d6                         ; FULL ?
 beq.b    _wbss_nofull                  ; keine Fullbox

* Fullbox

 sub.w    d3,w_tree+O_BDROP*24+ob_x(a4)      ; Backdrop nach links
 sub.w    d3,w_tree+O_ICONIFIER*24+ob_x(a4)  ; Iconify nach links
 sub.w    d3,w_tree+O_NAME*24+ob_width(a4)   ; NAME Breite anpassen

* Iconifier

_wbss_nofull:
 moveq    #14,d0
 btst     d0,d6
 beq.b    _wbss_noicon
 sub.w    d3,w_tree+O_BDROP*24+ob_x(a4)      ; Backdrop nach links
 sub.w    d3,w_tree+O_NAME*24+ob_width(a4)   ; NAME Breite anpassen

* links von der Fullbox bzw. vom Iconifier fuehren wir die Drop- Box ein:

_wbss_noicon:
 btst     #2,look_flags+1                    ; expliziter Backdrop-Button ?
 bne.b    _wbss_nobckdr                      ; nein, deaktiviert
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 bne.b    _wbss_nobckdr                      ; ja, kein Backdrop-Button
 sub.w    d3,w_tree+O_NAME*24+ob_width(a4)   ; NAME Breite anpassen

_wbss_nobckdr:

* 2. Infozeile: Pos. stimmt jetzt immer
* =====================================

_wbss_no_top:
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    _wbss_no_right                ; ja, kein rechter Teil
 move.w   d6,d0
 andi.w   #VSLIDE+DNARROW+UPARROW,d0    ; rechte Elemente?
 bne.b    _wbss_right                   ; ja
 move.w   d6,d0
 andi.w   #SIZER,d0                     ; unten rechts?
 beq.b    _wbss_no_right                ; nein
; keine rechten Elemente, aber den SIZER
 move.w   d6,d0
 andi.w   #HSLIDE+LFARROW+RTARROW,d0    ; untere Elemente?
 bne.b    _wbss_no_right                ; ja, nimm SIZER unten auf


* 3. rechter Teil
* ===============

_wbss_right:
 move.w   w_work+g_y(a4),d1
 sub.w    w_curr+g_y(a4),d1
 subq.w   #1,d1                    ; Pos. von uparrow/Slider
 move.w   w_work+g_h(a4),d0        ; Laenge des Sliders
 addq.w   #2,d0                    ;  oben und unten 1 Pixel Rand

 btst     #6,d6
 beq.b    _wbss_no_upar
 move.w   d1,w_tree+O_UP*24+ob_y(a4)
 add.w    d4,d1                    ; Slider tiefersetzen
 sub.w    d4,d0                    ; Hoehe fuer uparrow abziehen
_wbss_no_upar:
 btst     #7,d6
 beq.b    _wbss_no_dnar
 sub.w    d4,d0                    ; Hoehe fuer dnarrow abziehen
_wbss_no_dnar:
 move.w   d6,d2
 andi.w   #HSLIDE+RTARROW+LFARROW,d2    ; unterer Rand ?
 bne.b    _wbss_no_sizecorner           ; ja, schon beruecksichtigt
 btst     #5,d6                         ; SIZER ?
 beq.b    _wbss_no_sizecorner           ; nein
 sub.w    d4,d0                         ; Hoehe fuer Sizer abziehen
_wbss_no_sizecorner:
 move.w   d1,w_tree+O_VSCROLL*24+ob_y(a4)         ; y    von vscroll
 move.w   d0,w_tree+O_VSCROLL*24+ob_height(a4)    ; Hoehe von vscroll
 add.w    d1,d0
 subq.w   #1,d0
 move.w   d0,w_tree+8*24+ob_y(a4)       ; y    von dnarrow

 addq.w   #1,d4
 move.w   d4,w_tree+10*24+ob_height(a4) ; Minimalgroesse des Sliders

 moveq    #1,d0                    ; vertikal
 move.l   a4,a0                    ; WINDOW *
 bsr      _wbm_sslid
 move.w   d6,d0
 andi.w   #HSLIDE+RTARROW+LFARROW,d0
 bne.b    _wbss_isbottom
 bra      _wbss_no_bottom

* 4. unterer Teil
* ===============

_wbss_no_right:
 move.w   d6,d0
 andi.w   #HSLIDE+RTARROW+LFARROW,d0
 beq      _wbss_no_rightbottom
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    _wbss_no_rightbottom     ; ja, kein unterer Teil

_wbss_isbottom:
 moveq    #0,d1                    ; Pos. von lfarrow
 move.w   w_work+g_w(a4),d0
 addq.w   #2,d0                    ; 1 Pixel Rand links und rechts

;tst.b    d7
;beq.b    bwb_h_noact

 btst     #9,d6
 beq.b    _wbss_no_lfar
 sub.w    d3,d0                    ; Breite fuer lfarrow abziehen
 move.w   d1,w_tree+11*24+ob_x(a4) ; lfarrow
 add.w    d3,d1                    ; Slider rechtersetzen
_wbss_no_lfar:
 btst     #10,d6
 beq.b    _wbss_no_rtar
 sub.w    d3,d0                    ; Breite fuer rtarrow abziehen
_wbss_no_rtar:
 move.w   d1,w_tree+13*24+ob_x(a4)      ; x      von hscroll
 move.w   d0,w_tree+13*24+ob_width(a4)  ; Breite von hscroll
 add.w    d1,d0
 subq.w   #1,d0
 move.w   d0,w_tree+12*24+ob_x(a4)      ; x    von rtarrow

 addq.w   #1,d3
 move.w   d3,w_tree+14*24+ob_width(a4)  ; Minimalgroesse des Sliders

 moveq    #0,d0                    ; horizontal
 move.l   a4,a0                    ; WINDOW *
 bsr      _wbm_sslid

* 5. rechts unterer Teil
* ======================

* Der Sizer bzw. das leere Feld wird nur dann benoetigt, wenn er
* explizit verlangt wurde oder wenn sowohl rechte als auch untere
* Randelemente angefordert wurden

_wbss_no_bottom:
_wbss_no_rightbottom:

_wbss_ende:
 movem.l  (sp)+,a4/d3/d4/d6
 rts


**********************************************************************
*
* void send_rdrmsg( d0 = int handle, a0 = GRECT *g )
*
* Schneidet <g> vorher mit dem Bildschirm, <g> wird zerstoert.
*

send_rdrmsg:
 movem.l  d7/a4,-(sp)
 suba.w   #16,sp                   ; Platz fuer 2 GRECTs
 move.w   d0,d7
 move.l   (a0)+,(sp)
 move.l   (a0),4(sp)               ; GRECT kopieren
 lea      (sp),a1
 lea      desk_g,a0
 jsr      grects_intersect
 bne      _srd
 bra      end_rdr                  ; kein Schnitt mit Bildschirm


**********************************************************************
*
* void send_redraw_message(d0 = int handle, a0 = GRECT *g)
*

send_redraw_message:
 movem.l  d7/a4,-(sp)
 suba.w   #16,sp
 move.w   d0,d7
 move.l   (a0)+,(sp)               ; GRECT kopieren
 move.l   (a0),4(sp)
_srd:
 move.w   d7,d0
 bsr      whdl_to_wnd
 beq.b    end_rdr                  ; ungueltig???
 movea.l  a0,a4

 lea      (sp),a1
 lea      w_work(a4),a0
 jsr      grects_intersect         ; g mit WORKXYWH schneiden

 beq.b    end_rdr                  ; Schnitt leer

 move.l   w_wg(a4),d0
 beq.b    end_rdr                  ; WGRECT- Liste leer

 lea      8(sp),a1
 move.l   d0,a0
 bsr.s    get_wgs_union

 lea      (sp),a1
 lea      8(sp),a0
 jsr      grects_intersect         ; mit Vereinigung der WGRECTs schneiden

 beq.b    end_rdr
 lea      (sp),a0                  ; 4 Datenworte
 move.w   d7,d2                    ; 1. Datenwort
 movea.l  w_owner(a4),a2
 move.w   ap_id(a2),d1
 moveq    #WM_REDRAW,d0
 jsr      send_msg
end_rdr:
 adda.w   #16,sp
 movem.l  (sp)+,a4/d7
 rts


**********************************************************************
*
* void get_visb_wg( a0 = WINDOW *w, d0 = WGRECT *wg,
*                   a1 = GRECT *work, a2 = GRECT *ret)
*
* Holt ein in <work> sichtbares Rechteck aus der Rechteckliste des
* Fensters <w> und gibt es in <ret> zurueck
*

get_visb_wg:
 movem.l  a4/a5/a6,-(sp)
 move.l   a0,a4                    ; a4 = WINDOW *w
 movea.l  d0,a5                    ; wg
 move.l   a1,a6                    ; work
 bra.b    gvw_next
gvw_loop:
 move.l   wg_grect+g_x(a5),g_x(a2)
 move.l   wg_grect+g_w(a5),g_w(a2) ; GRECT kopieren
 movea.l  (a5),a5                  ; naechstes WGRECT
 move.l   a5,w_nextwg(a4)          ; w_nextwg setzen

 move.l   a2,a1                    ; <ret> mit
 move.l   a6,a0                    ;  <work> schneiden
 jsr      grects_intersect         ; aendert nicht a2

 bne.b    gvw_ende                 ; Schnitt nicht leer, Ende
gvw_next:
 move.l   a5,d0                    ; Ende der Liste ?
 bne.b    gvw_loop                 ; nein, weiter
 move.l   d0,g_w(a2)               ; g_w und g_h loeschen
gvw_ende:
 movem.l  (sp)+,a6/a5/a4
 rts


**********************************************************************
*
* int get_wgs_union( a0 = WGRECT *wglist, a1 = GRECT *g )
*
* Vereinigt alle WGs der Liste im Rueckgabe- GRECT <g>
* Dass die Liste nicht leer ist, muss vorher geprueft werden
*

get_wgs_union:
 movem.l  a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = wg
 movea.l  a1,a4                    ; g

 addq.l   #4,a0                    ; a0 = wg+4
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)                ; erstes GRECT nach <g>

 bra.b    gwu_nextg
gwu_loop:

 move.l   a4,a1
 lea      4(a5),a0
 jsr      grects_union

gwu_nextg:
 movea.l  (a5),a5
 move.l   a5,d0
 bne.b    gwu_loop
 movem.l  (sp)+,a5/a4
 rts


**********************************************************************
*
* void init_windows( void )
*
* Fenster initialisieren
*

init_windows:
* Variablen
 move.l   #finfo_inw,pfinfo_inw
 move.w   look_flags,d0
 andi.w   #4,d0                    ; Bit 2 isolieren
 lsr.w    #2,d0                    ; Bit 2 => Bit 0
 or.w     d0,wsg_flags             ; globale Fenster-Flags
 move.w   gr_hhbox,wbm_hshade      ; Hoehe fuer ge-shade-te Fenster
 tst.w    inw_height
 bne.b    iw_inwhset
 move.w   gr_hhbox,inw_height      ; Hoehe der INFO-Zeile
iw_inwhset:
* Fenstertabelle loeschen
 move.l   windx,a0
 addq.l   #4,a0                    ; alle ausser Fenster #0 loeschen
 moveq    #0,d0
 move.w   nwindows,d0
 subq.w   #1,d0
 add.w    d0,d0
 add.w    d0,d0
 jsr      clrmem                   ; iocpbuf loeschen
* alle NWGS WGRECTs in die freelist haengen
 lea      wg_freelist,a1
 clr.l    (a1)
 move.l   wgrects,a0
 move.w   (a0),d1                  ; erstes Wort gibt Anzahl der WGRECTs an
 subq.w   #1,d1
iw_wgloop:
 move.l   (a1),(a0)                ; wg_nextwg
 move.l   a0,(a1)
 lea      wg_sizeof(a0),a0
 dbra     d1,iw_wgloop

 move.l   windx,a0
 move.l   (a0),a0                  ; Fenster #0
 clr.w    w_state(a0)              ; geschlossen
 clr.w    w_attr(a0)
 clr.l    w_wg(a0)                 ; keine WGRECT- Liste

* Fenster 0 initialisieren

*
* Desktop-Muster: Farbe ungueltig => Muster 4 einsetzen
*

 cmpi.w   #1,nplanes                    ; Monochrom ?
 bhi.b    iniw_sw                       ; nein, Einstellung nehmen
 move.b   shelw_startpic+ob_spec+3,d0
 andi.b   #$0f,d0                       ; Farbe isolieren
 cmpi.b   #1,d0                         ; Farbe 0 oder 1 ?
 bls.b    iniw_sw                       ; ja, Farbe OK
 move.b   #$41,shelw_startpic+ob_spec+3 ; nein, auf grau setzen
iniw_sw:

* WGRECT- Liste fuer Fenster 0 initialisieren
 bsr      alloc_wgrect
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 move.l   a0,w_wg(a1)              ; windx[0].w_wg = a0
 clr.l    (a0)+                    ; a0->wg_nextwg = NULL
 clr.w    (a0)+                    ; a0->wg_grect.g_x = 0
 move.w   gr_hhbox,(a0)+           ; a0->wg_grect.g_y = gr_hhbox
 move.w   scr_w,(a0)+              ; a0->wg_grect.g_w = scr_w
 move.w   scr_h,d0
 sub.w    gr_hhbox,d0
 move.w   d0,(a0)                  ; a0->wg_grect.g_h = scr_h-gr-hhbox

 moveq    #0,d1                    ; Typ 0
 moveq    #0,d0                    ; Handle 0
 move.l   act_appl,a1
 move.l   windx,a0
 move.l   (a0),a0
 bsr      __wind_create            ; => a0 = WINDOW *

 lea      w_curr(a0),a0
 move.l   full_g,(a0)+
 move.l   full_g+4,(a0)+           ; CURRXYWH ist full_grect

 move.l   full_g,(a0)+
 move.l   full_g+4,(a0)+           ; PREVXYWH ist full_grect

 move.l   desk_g,(a0)+
 move.l   desk_g+4,(a0)+           ; FULLXYWH ist screen_grect

 move.l   desk_g,(a0)+
 move.l   desk_g+4,(a0)+           ; WORKXYWH ist screen_grect

 move.l   full_g,(a0)+
 move.l   full_g+4,(a0)+           ; OVERALLXYWH ist full_grect

 move.w   #-1,topwhdl              ; kein oberstes Fenster
 clr.w    whdlx                    ; leere Fensterliste
 clr.l    desktree                 ; kein angemeldetes Desktop

; Tabelle der 3D-Flags fuer die Fensterelemente initialisieren

 lea      f3d_box,a0
 lea      windowbox_3dflags(pc),a1
 moveq    #N_WINOBJS-1,d1
inw_3dloop:
 move.b   (a1)+,(a0)+
 dbra     d1,inw_3dloop

; Tabelle der Farben/Muster fuer die Fensterelemente initialisieren

 lea      dcol_box,a0
 lea      windowbox_specs+2(pc),a1 ; jeweils Loword von ob_spec
 moveq    #N_WINOBJS-1,d1
inw_sloop:
 move.w   (a1),d0
 move.w   d0,(a0)+                 ; fuer inaktives Fenster
 move.w   d0,(a0)+                 ; genauso wie fuer aktives
 addq.l   #4,a1
 dbra     d1,inw_sloop

 move.w   #$1100,d0                ; inaktiv: Innenfarbe WHITE, IP_HOLLOW, Text transparent, Textfarbe BLACK, Rahmenfarbe BLACK
 lea      dcol_name,a0
 move.w   d0,(a0)+
 move.w   #$1180,(a0)              ; aktiv: WHITE/HOLLOW/Linien
 btst.b   #3,look_flags+1          ; Fenstertitel mit Linien ?
 beq.b    iw_linien
 move.w   #$11a1,(a0)              ; aktiv: Innenfarbe BLACK, IP_5PATT, Text deckend, Textfarbe BLACK, Rahmenfarbe BLACK
iw_linien:
 lea      dcol_info,a0
 move.w   d0,(a0)+
 move.w   d0,(a0)
 tst.w    enable_3d
 beq.b    inw_no_3d

* Modifikation fuer 3D-Fenster
* dcol = $abcdefgh, dabei $abcd fuer inaktive Fenster, $efgh fuer aktive
*         h = Innenfarbe
*         g = Muster (0..7), hoechstes Bit: Text deckend (1), transp (0)
*         f = Textfarbe
*         e = Rahmenfarbe

 move.l   #$19001180,dcol_name     ; Innenfarbe immer weiss (wg. 3D)
                                   ; Muster immer hohl (wg. 3D)
                                   ; inaktiv: Text transparent
                                   ; aktiv: Text deckend, d.h. Linien sichtbar
                                   ; inaktiv: Textfarbe 9 (dunkelgrau)
                                   ; aktiv: Textfarbe 1 (schwarz)
 move.w   #$1900,dcol_info         ; inaktiv: Textfarbe 9 (dunkelgrau)
 move.l   #$11481179,d0
 move.l   d0,dcol_hsld             ; horiz. Scroll-Hintergrund
 move.l   d0,dcol_vsld             ; vert. Scroll-Hintergrund
 move.w   #$1900,d0                ; graue Schrift fuer inaktive Buttons
 move.w   d0,dcol_closer           /* Schliessknopf */
 move.w   d0,dcol_bdrop            /* Backdrop-Button      (wie W_FULLER)  */
 move.w   d0,dcol_fuller           /* Maximalknopf               W_FULLER  */
 move.w   d0,dcol_sizer            /* Groessenknopf                W_SIZER   */
 move.w   d0,dcol_arup             /* Pfeil hoch                 W_UPARROW */
 move.w   d0,dcol_ardwn            /* Pfeil runter               W_DNARROW */
 move.w   d0,dcol_arlft            /* Pfeil links                W_LFARROW */
 move.w   d0,dcol_arrgt            /* Pfeil rechts               W_RTARROW */
 move.w   d0,dcol_iconify          /* Iconifier (wie W_FULLER)             */
inw_no_3d:
 rts

* ob_types fuer die N_WINOBJS Fensterelemente

windowbox_types:
 DC.B     G_IBOX         ;  0: umfassende Box
 DC.B     G_BOXCHAR      ;  1: Schliessfeld
 DC.B     G_WINTITLE     ;    G_BOXTEXT      ;  2: Titelbalken
 DC.B     G_BOXCHAR      ;  3: Drop- Button (!)
 DC.B     G_BOXCHAR      ;  4: Maximalgroessenfeld
 DC.B     G_BOXTEXT      ;  5: Infozeile
 DC.B     G_BOXCHAR      ;  6: Groessenfeld
 DC.B     G_BOXCHAR      ;  7: Pfeil hoch
 DC.B     G_BOXCHAR      ;  8: Pfeil runter
 DC.B     G_BOX          ;  9: vertikaler Scrollhintergrund
 DC.B     G_BOX          ; 10: vertikaler Scrollbalken
 DC.B     G_BOXCHAR      ; 11: Pfeil links
 DC.B     G_BOXCHAR      ; 12: Pfeil rechts
 DC.B     G_BOX          ; 13: horizontaler Scrollhintergrund
 DC.B     G_BOX          ; 14: horizontaler Scrollbalken
 DC.B     G_BOXCHAR      ; 15: Iconifier (AES 4.1)
 EVEN

* ob_specs fuer die N_WINOBJS Fensterelemente
*          ||       Zeichen
*            ||     Rahmendicke
*              |    Rahmenfarbe
*               |   Textfarbe
*                |  0:hohl,1:Muster,7:voll,Bit7:textflag
*                 | Innenfarbe
windowbox_specs:
 DC.L     $00011100      ;  0: Rahmen 1
 DC.L     $05021100      ;  1: Rahmen 1, Zeichen fuer Closebox
 DC.L     0              ;  2: TEDINFO (NAME)
 DC.L     $1f021100      ;  3: Drop- Button, Zeichen $1f
 DC.L     $07021100      ;  4: Fullbutton
 DC.L     0              ;  5: TEDINFO (INFO)
 DC.L     $06021100      ;  6: Sizebutton
 DC.L     $01021100      ;  7: up
 DC.L     $02021100      ;  8: down
 DC.L     $00011111      ;  9: vscroll
 DC.L     $00021100      ; 10: vslide
 DC.L     $04021100      ; 11: left
 DC.L     $03021100      ; 12: right
 DC.L     $00011111      ; 13: hscroll
 DC.L     $00021100      ; 14: hslide
 DC.L     $7f021100      ; 15: Iconify- Button, Zeichen $7f

windowbox_3dflags:
 DC.B     0              ;  0: umfassende Box
 DC.B     1              ;  1: Closebox
 DC.B     1              ;  2: NAME
 DC.B     1              ;  3: Drop- Button
 DC.B     1              ;  4: Fullbutton
 DC.B     0              ;  5: INFO
 DC.B     1              ;  6: Sizebutton
 DC.B     1              ;  7: up
 DC.B     1              ;  8: down
 DC.B     0              ;  9: vscroll
 DC.B     1              ; 10: vslide
 DC.B     1              ; 11: left
 DC.B     1              ; 12: right
 DC.B     0              ; 13: hscroll
 DC.B     1              ; 14: hslide
 DC.B     1              ; 15: Iconify- Button, Zeichen $7f


**********************************************************************
*
* int wind_s3d( a0 = WINDOW *w, d0 = int is3d )
*
* Schaltet ein Fenster von 2D auf 3D und zurueck
*

wind_s3d:
 suba.w   #N_WINOBJS,sp
 lea      f3d_box,a1
 lea      (sp),a2
 moveq    #0,d1
wins3d_loop:
 tst.b    (a1)+               ; 3D ?
 beq.b    wins3d_n3d          ; nein
 move.b   d1,(a2)+
wins3d_n3d:
 addq.w   #1,d1
 cmpi.w   #N_WINOBJS,d1
 bcs.b    wins3d_loop
 st.b     (a2)                ; mit -1 abschliessen

 lea      w_tree(a0),a1
 lea      (sp),a0
 bsr.b    chg_3d
 adda.w   #N_WINOBJS,sp
 rts


**********************************************************************
*
* int chg_3d( a0 = char *objs, a1 = OBJECT *tree, d0 = int is3d )
*
* Schaltet einen Dialog von 2D auf 3D und zurueck
*

chg_3d:
 moveq    #1,d2                          ; Rahmen 1 innen
 tst.w    d0
 beq.b    ws3d_loop                     ; 2D => Rahmen 1 innen
 move.w   gr_hwbox,d1                   ; Breite der Box
 sub.w    big_wchar,d1                  ; - Breite des Zeichens
 subq.w   #4,d1                         ; 2 * 2 Pixel Rand
 bmi.b    ws3d_loop                     ; 3D, aber zu klein => 1 innen
 moveq    #2,d2                         ; 3D => Rahmen 2 innen
ws3d_loop:
 move.b   (a0)+,d1
 bmi.b    ws3d_ende
 ext.w    d1
 mulu     #24,d1
 tst.w    d0
 beq.b    ws3d_2d
 ori.w    #FL3DACT,ob_flags(a1,d1.w)
 bra.b    ws3d_both
ws3d_2d:
 andi.w   #!FL3DACT,ob_flags(a1,d1.w)   ; 3D loeschen
ws3d_both:
 cmpi.w   #G_WINTITLE,ob_type(a1,d1.w)
 beq.b    ws3d_tedi
 cmpi.w   #G_BOXTEXT,ob_type(a1,d1.w)
 bne.b    ws3d_spec
ws3d_tedi:
 move.l   ob_spec(a1,d1.w),a2           ; TEDINFO !
 move.b   d2,te_thickness+1(a2)         ; Rahmen 1 innen
 bra.b    ws3d_loop
ws3d_spec:
 move.b   d2,ob_spec+1(a1,d1.w)         ; Rahmen 1 innen
 bra.b    ws3d_loop
ws3d_ende:
 rts


**********************************************************************
*
* PUREC WORD _wind_create( WORD typ, GRECT *full )
*
* int _wind_create( d0 = int typ, a0 = GRECT *full )
*

_wind_create:
 movem.l  d6/d7/a2/a6/a5,-(sp)
 move.w   d0,d7                    ; d7 = typ
 move.l   a0,a6                    ; a6 = full

* freien Slot suchen

 moveq    #0,d6                    ; d6 = whdl
 move.l   windx,a5
_wcr_loop:
 move.l   (a5)+,d1
 beq.b    _wcr_found               ; unbenutztes Handle gefunden
 addq.w   #1,d6
 cmp.w    nwindows,d6
 bcs.b    _wcr_loop
_wcr_err:
 moveq    #XE_INVWHDL,d0
 bra.b    _wcr_ende
_wcr_found:
 subq.l   #4,a5

* WINDOW-Struktur allozieren.

 move.l   wsizeof,d0               ; Speicherblockgroesse
 jsr      smalloc
 beq.b    _wcr_err

* WINDOW-Struktur eintragen und dem AES zuweisen.

 move.l   d0,(a5)                  ; Struktur eintragen

 move.l   _basepage,a1             ; Neuer Eigner: AES
 move.l   d0,a0                    ; memadr
 jsr      Mchgown                  ; Eigner des Blocks wechseln

 move.w   d7,d1                    ; kind
 move.w   d6,d0                    ; whdl
 move.l   act_appl,a1
 move.l   (a5),a0
 bsr      __wind_create            ; gibt WINDOW * zurueck, a2 unveraendert

 clr.l    w_wg(a0)                 ; leere Rechteckliste!
 clr.l    w_nextwg(a0)

 clr.l    w_min_g+g_x(a0)          ; Minimalgroesse
 move.l   gr_hwbox,w_min_g+g_w(a0)

 lea      w_curr(a0),a0
 clr.l    (a0)+
 clr.l    (a0)+                    ; CURRXYWH ist leer

 clr.l    (a0)+
 clr.l    (a0)+                    ; PREVXYWH ist leer

 move.l   (a6)+,(a0)+
 move.l   (a6),(a0)                ; FULLXYWH

* Manager-spezifische Initialisierung

 move.l   (a5),a0
 move.l   wbm_create,a1
 jsr      (a1)                     ; Callback fuer Initialisierung

 move.l   (a5),a0
 move.l   wbm_skind,a1
 jsr      (a1)                     ; Callback fuer Initialisierung

 move.w   d6,d0                    ; whdl
_wcr_ende:
 movem.l  (sp)+,d6/d7/a6/a5/a2
 rts


**********************************************************************
*
* PUREC WORD wind_delete(WORD whdl)
*
* int wind_delete(d0 = int whdl)
*
* Achtung: Jetzt Rueckgabewert 0 bei ungueltigem Handle
*

wind_delete:
 tst.w    d0
 beq.b    wdl_err                  ; !!!
 bsr      whdl_to_wnd
 beq.b    wdl_err
 move.l   act_appl,a1
 cmpa.l   w_owner(a0),a1           ; gehoert uns ?
 bne.b    wdl_err
 btst     #WSTAT_OPENED_B,w_state+1(a0)
 bne.b    wdl_err                  ; ja, nicht loeschen
 move.l   windx,a1
 move.w   w_whdl(a0),d0
 add.w    d0,d0
 add.w    d0,d0
 add.w    d0,a1
 clr.l    (a1)                     ; austragen
;move.l   a0,a0
 move.l   a2,-(sp)
 jsr      smfree                   ; Speicher freigeben
 move.l   (sp)+,a2
 moveq    #1,d0                    ; OK
 rts
wdl_err:
 moveq    #0,d0
 rts


**********************************************************************
*
* void wind_skind( a0 = WINDOW *w, d0 = WORD kind )
*

wind_skind:
 movem.l  a4/d7,-(sp)
 subq.l   #8,sp
 move.l   a0,a4                         ; a4 = WINDOW *

; neuen Typ setzen

 move.w   w_kind(a4),d7                 ; d7 = alter Typ
 cmp.w    d7,d0                         ; wie neuer?
 beq      wsk_ende                      ; ja, nicht aendern
 move.w   d0,w_kind(a4)                 ; neuen Fenstertyp setzen

; alten Arbeitsbereich sichern

 move.l   w_work+g_x(a4),g_x(sp)
 move.l   w_work+g_w(a4),g_w(sp)

; Fensterrahmen neu initialisieren

;move.l   a0,a0                         ; WINDOW *
 move.l   wbm_skind,a1
 jsr      (a1)

 move.l   a4,a0                         ; WINDOW *
 clr.l    w_tree+ob_width(a0)           ; damit ssize alles neu berechnet
 move.l   wbm_ssize,a1
 jsr      (a1)

; Redraw

 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq      wsk_ende                      ; nein, nicht zeichnen
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 bne      wsk_ende                      ; ja, nicht zeichnen
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 bne      wsk_ende                      ; ja, nicht zeichnen

 jsr      mouse_off

 move.l   w_work+g_x(a4),d0
 cmp.l    g_x(sp),d0                    ; Pos. des Arbeitsbereichs geaendert?
 bne.b    wsk_all                       ; ja, alles neu

 move.l   w_work+g_w(a4),d0
 cmp.l    g_w(sp),d0                    ; Groesse des Arbeitsbereichs geaendert?
 beq.b    wsk_complframe                ; nein, Rahmen komplett neu

 move.w   w_work+g_h(a4),d0             ; neue Hoehe
 sub.w    g_h(sp),d0
 beq.b    wsk_sameh                     ; Hoehe unveraendert

* Hoehe hat sich geaendert

 bmi.b    wsk_hsmaller

* Hoehe hat sich vergroessert

 move.w   d0,g_h(sp)
 move.w   g_h(sp),d0                    ; alte Hoehe
 add.w    d0,g_y(sp)
wsk_msg:
 lea      (sp),a0
 move.w   w_whdl(a4),d0
 bsr      send_redraw_message
 bra.b    wsk_mende

* Hoehe hat sich verkleinert

wsk_hsmaller:
 neg.w    d0
 move.w   d0,g_h(sp)
 move.w   w_work+g_h(a4),d0
 add.w    d0,g_y(sp)
wsk_frame:
 lea      (sp),a0                       ; nur Ausschnitt
 moveq    #0,d1                         ; startob
 move.w   w_whdl(a4),d0
 bsr      wind_draw                     ; Rahmen
 bra.b    wsk_mende

* Breite hat sich geaendert

wsk_sameh:
 move.w   w_work+g_w(a4),d0             ; neue Breite
 sub.w    g_w(sp),d0
 bmi.b    wsk_wsmaller

* Breite hat sich vergroessert

 move.w   d0,g_w(sp)
 move.w   g_w(sp),d0                    ; alte Breite
 add.w    d0,g_x(sp)
 bra.b    wsk_msg

* Breite hat sich verkleinert

wsk_wsmaller:
 neg.w    d0
 move.w   d0,g_w(sp)
 move.w   w_work+g_w(a4),d0
 add.w    d0,g_x(sp)
 bra.b    wsk_frame

* Rahmen komplett neu zeichnen

wsk_complframe:
 move.w   w_whdl(a4),d0
 bsr      wind_draw_whole
 bra.b    wsk_mende

* Fenster komplett neu zeichnen

wsk_all:
 lea      w_overall(a4),a0              ; nur Ausschnitt
 moveq    #0,d1                         ; startob
 move.w   w_whdl(a4),d0
 bsr      wind_draw
 lea      w_overall(a4),a0
 move.w   w_whdl(a4),d0
 bsr      send_redraw_message

wsk_mende:
 jsr      mouse_on

wsk_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a4/d7
 rts


**********************************************************************
*
* int calc_dcol(d1 = int elem)
*
* Rechnet ein Fensterelement um in eine MagiC-Objektnummer
*

dcol_codes:
 DC.B     0    ;W_BOX:         umschliessende Box
 DC.B     -1   ;W_TITLE:
 DC.B     4*1  ;W_CLOSER:      Schliessfeld
 DC.B     4*2  ;W_NAME         Titelzeile
 DC.B     4*4  ;W_FULLER       Maximalgroessenknopf
 DC.B     4*5  ;W_INFO         Infozeile
 DC.B     -1   ;W_DATA
 DC.B     -1   ;W_WORK
 DC.B     4*6  ;W_SIZER        Groessenknopf
 DC.B     -1   ;W_VBAR
 DC.B     4*7  ;W_UPARROW      Pfeil nach oben
 DC.B     4*8  ;W_DNARROW      Pfeil nach unten
 DC.B     4*9  ;W_VSLIDE       vertikaler Scrollbalkenhintergrund
 DC.B     4*10 ;W_VELEV        vertikaler Scrollbalken
 DC.B     -1   ;W_HBAR
 DC.B     4*11 ;W_LFARROW      Pfeil nach links
 DC.B     4*12 ;W_RTARROW      Pfeil nach rechts
 DC.B     4*13 ;W_HSLIDE       horizontaler Scrollhintergrund
 DC.B     4*14 ;W_HELEV        18: horizontaler Scrollbalken
 DC.B     4*15 ;W_SMALLER      19: Iconifier
 DC.B     4*3  ;W_BOTTOMER     20: Backdrop-Button
 EVEN

calc_dcol:
 cmpi.w   #20,d1
 bhi.b    dcdc_err                 ; ungueltiger Wert
 move.b   dcol_codes(pc,d1.w),d0   ; umrechnen fuer Objektnummer Mag!X
 bmi.b    dcdc_err                 ; gibt es in Mag!X nicht
 ext.w    d0
 rts
dcdc_err:
 moveq    #-1,d0
 rts


**********************************************************************
*
* PUREC WORD _wind_get(WORD whdl, WORD code, WORD code2, WORD *g)
*
* int _wind_get(d0 = int whdl, d1 = int code,
*               d2 = int code2, a0 = int *g)
*
* Rueckgabewert 0 bei ungueltigem Handle
*
* 11.2.96:     d2 fuer intin[2], fuer WF_DCOLOR benoetigt
*

_wind_get:
_wind_get_grect:
 movem.l  d7/a2/a3/a5,-(sp)
 subq.l   #8,sp                    ; Platz fuer ein GRECT
 movea.l  a0,a5

 cmpi.w   #WF_TOP,d1
 beq      wg_top
 cmpi.w   #WF_DCOLOR,d1
 beq      wg_dcolor
 cmpi.w   #WF_NEWDESK,d1
 beq      wg_newdesk
 cmpi.w   #WF_SCREEN,d1
 beq      wg_screen
 cmpi.w   #WF_BOTTOM,d1
 beq      wg_bottom
 cmpi.w   #WF_M_WINDLIST,d1
 beq      wg_list

 move.w   d0,d7
 bsr      whdl_to_wnd              ; aendert nur d0/a0
 beq      wg_err                   ; ungueltiges Handle
 movea.l  a0,a3

 cmpi.w   #WF_FIRSTXYWH,d1
 beq      wg_first
 cmpi.w   #WF_NEXTXYWH,d1
 beq      wg_next
 cmpi.w   #WF_BEVENT,d1            ; MultiTOS
 beq      wg_bevent
 cmpi.w   #WF_OWNER,d1             ; MultiTOS
 beq      wg_own
 cmpi.w   #WF_ICONIFY,d1
 beq      wg_iconify
 cmpi.w   #WF_UNICONIFY,d1
 beq      wg_uniconify
 cmpi.w   #WF_M_OWNER,d1           ; KAOS
 beq      wg_own
 cmpi.w   #WF_MINXYWH,d1           ; MagiC 6
 beq      wg_minxywh
 cmpi.w   #WF_INFOXYWH,d1          ; MagiC 6.10
 beq      wg_infoxywh
 cmpi.w   #WF_SHADE,d1             ; WINX 2.3
 beq      wg_shade
 cmpi.w   #WF_NAME,d1              ; WINX 2.3 (?)
 beq      wg_name
 cmp.w    #WF_VSLSIZE,d1
 bhi      wg_err
 move.b   wg_offs(pc,d1.w),d0
 ext.w    d0
 beq      wg_err                   ; ungueltig
 bmi      wg_xywh                  ; GRECTs holen
 move.w   0(a3,d0.w),(a5)          ; einen int aus WINDOW holen
 bra      wg_endsw
wg_xywh:
 neg.w    d0
 lea      0(a3,d0.w),a0
 move.l   (a0)+,(a5)+
 move.l   (a0),(a5)
 btst     #WSTAT_SHADED_B,w_state+1(a3)
 beq      wg_endsw                 ; nein, normal
;btst     #1,w_tattr(a3)           ; ICONIFIED
;bne      wg_endsw                 ; ja, normal
 cmpi.w   #WF_FULLXYWH,d1
 beq      wg_endsw                 ; FULLXYWH ist immer korrekt
 cmpi.w   #WF_PREVXYWH,d1
 beq      wg_endsw                 ; PREVXYWH ist immer korrekt
 move.w   w_oldheight(a3),d2
 sub.w    w_curr+g_h(a3),d2
 add.w    d2,2(a5)                 ; Hoehe, als ob nicht ge-shaded
 bra      wg_endsw

wg_offs:
 DC.B     0,w_kind,0,0,-w_work,-w_curr,-w_prev,-w_full
 DC.B     w_hslide,w_vslide,0,0,0,0,0,w_hslsize,w_vslsize

     EVEN

wg_name:
 move.l   w_name(a3),(a5)          ; Zeiger auf Name zurueckgeben
 bra      wg_endsw

wg_iconify:
 btst     #WSTAT_ICONIFIED_B,w_state+1(a3)
 sne      d0
 andi.w   #1,d0
 move.w   d0,(a5)+
 subq.l   #8,sp
 lea      (sp),a0
 bsr      find_icon_pos            ; Groesse eines ikonifizierten Fensters
 addq.l   #4,sp                    ; x/y ignorieren
 move.l   (sp)+,(a5)               ; w/h zurueckgeben
 bra      wg_endsw

wg_uniconify:
 btst     #WSTAT_ICONIFIED_B,w_state+1(a3)
 beq      wg_err                   ; Fehler!
 move.l   w_unic(a3),(a5)+
 move.l   w_unic+g_w(a3),(a5)
 bra      wg_endsw

wg_shade:
 btst     #WSTAT_SHADED_B,w_state+1(a3)
 sne      d0
 andi.w   #1,d0
 move.w   d0,(a5)                  ; g[0] = flag
 bra      wg_endsw

wg_bevent:
 moveq    #0,d0
 move.b   w_attr+1(a3),d0          ; Nur 7 Bits
 move.w   d0,(a5)
 bra      wg_endsw

wg_own:
 move.l   w_owner(a3),a0           ; Eigner des Fensters
 move.w   ap_id(a0),(a5)+          ; seine ap_id
 btst     #WSTAT_OPENED_B,w_state+1(a3)
 sne      d0
 andi.w   #1,d0
 move.w   d0,(a5)+                 ; 1, falls geoeffnet
 moveq    #-1,d1                   ; ungueltiges Handle
 move.l   d1,(a5)                  ; Fenster darueber ungueltig
 lea      whdlx,a0
wgo_loop:
 move.w   (a0)+,d0
 bmi.b    wgo_loop                 ; eingefrorene Fenster ueberlesen
 cmp.w    d0,d7
 beq.b    wgo_fnd                  ; gefunden
 move.w   d0,d1                    ; gueltiges Handle
 bne.b    wgo_loop                 ; noch nicht das Listenende
 bra      wg_endsw                 ; nicht gefunden
wgo_fnd:
 move.w   d1,(a5)+                 ; Fenster ueber unserem
 tst.w    d7
 beq      wg_endsw                 ; Wir sind Fenster 0
wgo_loop2:
 move.w   (a0)+,d0
 bmi.b    wgo_loop2                ; ungueltige Fenster ueberlesen
 move.w   d0,(a5)                  ; Fenster unter unserem
 bra      wg_endsw

* case WF_BOTTOM
*    liefere letztes gueltiges Fenster vor SCREEN
*
*    ab 27.12.96 (MagiC 5.05):
*         liefere in intout[2] weitere Informationen:
*         intin[2] enthaelt die ap_id, deren Fensterliste
*         erfragt wird.

wg_bottom:
 lea      whdlx,a0
 moveq    #-1,d1                   ; noch kein Fenster gefunden
wgb_loop:
 tst.w    (a0)+
 bmi.b    wgb_loop                 ; eingefrorene Fenster ueberlesen
 beq      wgb_endloop              ; Listenende
 move.w   -2(a0),d1                ; gueltiges Fenster
 bra.b    wgb_loop
wgb_endloop:
 move.w   d1,(a5)+
; MagiC:
 cmpi.w   #NAPPS,d2
 bcc      wg_endsw                 ; ap_id ungueltig
 add.w    d2,d2
 add.w    d2,d2
 lea      applx,a0
 add.w    d2,a0
 move.l   (a0),a0                  ; app
;move.w   d0,d0                    ; whdl
 bsr      get_next_window
 move.w   d0,(a5)
 bra      wg_endsw

* case WF_INFOXYWH

wg_infoxywh:
 tst.w    w_tree+O_INFO*24+ob_next(a3)       ; INFO gueltig ?
 bmi.b    wg_infoinv                         ; nein!
 move.l   w_tree+O_INFO*24+ob_x(a3),(a5)+    ; x/y
 move.l   w_tree+O_INFO*24+ob_width(a3),(a5) ; w/h
 bra      wg_endsw
wg_infoinv:
 clr.l    (a5)+
 clr.l    (a5)
 bra      wg_endsw

* case WF_MINXYWH

wg_minxywh:
 move.l   w_min_g+g_x(a3),(a5)+
 move.l   w_min_g+g_w(a3),(a5)
 bra      wg_endsw

* case WF_M_WINDLIST

wg_list:
 move.l   #whdlx,(a5)              ; unter KAOS nur temporaer gueltig
                                   ; unter MAGIX immer gueltig
 bra      wg_endsw

wg_top:
 move.w   topwhdl,d0
 beq.b    wgt_desk                 ; ist 0
 addq.w   #1,d0
 beq.b    wgt_desk                 ; war -1, also ungueltig, gib 0 zurueck
 subq.w   #1,d0
wgt_desk:
 move.w   d0,(a5)+                 ; Handle des obersten Fensters
 move.w   #-1,(a5)                 ; ap_id erstmal ungueltig
 bsr      whdl_to_wnd
 beq.b    wg_winv
 move.l   w_owner(a0),a0
 move.w   ap_id(a0),(a5)+          ; ap_id des obersten Fensters
wg_winv:
 move.w   #-1,(a5)                 ; Handle darunter erstmal ungueltig
 tst.w    d0
 beq      wg_endsw                 ; Hintergrund hat kein naechstes Fenster

* Hack fuer alte Programme:
/*
 cmpa.l   act_appl,a0              ; oberstes Fenster gehoert mir
 beq.b    wgt_ok
 move.w   -4(a5),2(a5)             ; wi_gw3 bekommt tatsaechlichen Wert
 move.w   #XE_OTHWHDL,-4(a5)       ; gehoert mir nicht => return(XE_OTHWHDL)
wgt_ok:
* end-of-hack
*/

 lea      whdlx+2,a0
wgt_loop:
 move.w   (a0)+,d0
 bmi.b    wgt_loop                 ; eingefrorene Fenster
 move.w   d0,(a5)                  ; naechstes Fenster
 bra.b    wg_endsw

* FIRSTXYWH

wg_first:
 move.l   w_work(a3),(sp)
 move.l   w_work+4(a3),4(sp)
 move.l   w_wg(a3),d0              ; erstes Rechteck
 bra.b    wg_fstnxt

* NEXTXYWH

wg_next:
 move.l   w_work(a3),(sp)
 move.l   w_work+4(a3),4(sp)
 move.l   w_nextwg(a3),d0          ; naechstes Rechteck

wg_fstnxt:
 move.l   a5,a2                    ; Rueckgabe- GRECT
 lea      (sp),a1                  ; Arbeitsbereich
;move.l   d0,d0                    ; WGRECT
 move.l   a3,a0                    ; WINDOW *w
 bsr      get_visb_wg
 bra.b    wg_endsw

* case 19 (WF_DCOLOR)

wg_dcolor:
 move.w   d2,d1
 bsr      calc_dcol
 bmi.b    wg_endsw
 lea      dcol_box+2,a0
 add.w    d0,a0
 addq.l   #2,a5
 move.w   (a0),(a5)+
 move.w   -(a0),(a5)+
 lsr.w    #2,d0
 lea      f3d_box,a0
 add.w    d0,a0
 move.w   #$0100,d1                ; nur kFore3D unterstuetzt
 move.b   (a0),d1
 move.w   d1,(a5)
 bra.b    wg_endsw

* case 14 (WF_NEWDESK)

wg_newdesk:
 move.l   desktree,(a5)+           ; Desktop- Hintergrund
 move.w   desktree_1stob,(a5)      ; erstes zu zeichnendes Objekt
 bra.b    wg_endsw

* case 17 (WF_SCREEN)

wg_screen:
 lea      4(a5),a1
 move.l   a5,a0
 jsr      inq_screenbuf

wg_endsw:
 moveq    #1,d0
wg_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a5/a3/a2/d7
 rts
wg_err:
 clr.l    (a5)+                    ; gib 4 Nullen zurueck
 clr.l    (a5)
 moveq    #0,d0
 bra.b    wg_ende


**********************************************************************
*
* PUREC WORD _wind_set(WORD whdl, WORD opcode, WORD koor[4])
*
* int _wind_set(d0 = int whdl, d1 = int opcode, a0 = int koor[4])
*
* 5.10.95:     wind_set(-1, WF_TOP, -1);
*               bringt eigenes Menue und Hintergrund nach oben.
*              wind_set(-1, WF_TOP, ap_id);
*               bringt Menue und Hintergrund anderer APP nach oben
*

_wind_set:
 movem.l  d6/d7/a2/a4/a5,-(sp)
 cmp.w    nwindows,d0
 bcs.b    ws_normal
 cmpi.w   #WF_TOP,d1
 bne      ws_err
 addq.w   #1,d0
 bne      ws_err
 move.l   act_appl,d2
 move.w   (a0),d1
 bmi.b    top_menu
 cmpi.w   #NAPPS,d1
 bcc      ws_err
 move.w   d1,a1
 add.w    a1,a1
 add.w    a1,a1
 move.l   applx(a1),d2
 ble      ws_err
top_menu:
 move.l   d2,a0
 jsr      set_app                  ; Menue und Hintergrund nach oben
 bsr      all_untop                ; oberstes Fenster deakt. falls andere APP
 moveq    #1,d0                    ; kein Fehler
 bra      ws_ende

ws_normal:
 move.w   d0,d7                    ; d7 = Window- Handle
 move.w   d1,d6                    ; d6 = opcode
 movea.l  a0,a5                    ; a5 = Zeiger auf Koordinaten
;move.w   d7,d0
 bsr      whdl_to_wnd
 beq      ws_err

 movea.l  a0,a4
 jsr      update_1
 move.w   d6,d0
 cmpi.w   #29,d0
 bcs.b    ws_jmplist               ; 0..28
 cmpi.w   #WF_M_BACKDROP,d0
 beq      ws_back                  ; WF_BACK
 cmpi.w   #WF_STACK,d0
 beq      ws_stack
 cmpi.w   #WF_TOPALL,d0
 beq      ws_topall
 cmpi.w   #WF_BOTTOMALL,d0
 beq      ws_bottomall
 cmpi.w   #WF_SHADE,d0
 beq      ws_shade
 cmp.w    #WF_UNICONIFYXYWH,d0
 bhi      ws_err2                  ; ungueltige Unterfunktion
ws_jmplist:
 add.w    d0,d0
 move.w   ws_jmptab(pc,d0.w),d0
 jmp      ws_jmptab(pc,d0.w)

ws_jmptab:
 DC.W     ws_err2-ws_jmptab             ;  0 = fehler
 DC.W     ws_kind-ws_jmptab             ;  1 = WF_KIND
 DC.W     ws_name-ws_jmptab             ;  2 = WF_NAME
 DC.W     ws_info-ws_jmptab             ;  3 = WF_INFO
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_curr-ws_jmptab             ;  5 = WF_CURRXYWH
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_slide-ws_jmptab            ;  8 = WF_HSLIDE
 DC.W     ws_slide-ws_jmptab            ;  9 = WF_VSLIDE
 DC.W     ws_top-ws_jmptab              ; 10 = WF_TOP
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_resvd-ws_jmptab            ; 13 = WF_RESVD2
 DC.W     ws_newdesk-ws_jmptab          ; 14 = WF_NEWDESK
 DC.W     ws_slide-ws_jmptab            ; 15 = WF_HSLSIZE
 DC.W     ws_slide-ws_jmptab            ; 16 = WF_VSLSIZE
 DC.W     ws_err2-ws_jmptab
 DC.W     ws_endsw-ws_jmptab            ; 18 = WF_TATTRB    (dummy)
 DC.W     ws_siztop-ws_jmptab           ; 19 = WF_SIZTOP/WF_DCOLOR
 DC.W     ws_err2-ws_jmptab             ; 20 = ungueltig (get: WF_OWNER)
 DC.W     ws_err2-ws_jmptab             ; 21 = ungueltig
 DC.W     ws_err2-ws_jmptab             ; 22 = ungueltig
 DC.W     ws_err2-ws_jmptab             ; 23 = ungueltig
 DC.W     ws_bevent-ws_jmptab           ; 24 = WF_BEVENT
 DC.W     ws_back-ws_jmptab             ; 25 = WF_BOTTOM
 DC.W     ws_iconify-ws_jmptab          ; 26 = WF_ICONIFY
 DC.W     ws_unicon-ws_jmptab           ; 27 = WF_UNICONIFY
 DC.W     ws_unicong-ws_jmptab          ; 28 = WF_UNICONIFYXYWH

* case 1 = WF_KIND

ws_kind:
 move.w   (a5),d0                       ; neuer Fenstertyp
 move.l   a4,a0
 bsr      wind_skind
 bra      ws_endsw

* case 26 = WF_ICONIFY

ws_iconify:
 move.l   a5,a1                         ; GRECT *
 move.l   a4,a0                         ; WINDOW *
 move.w   d7,d0                         ; whdl
 bsr      wind_iconify
 bra      ws_endsw_ret

* case 27 = WF_UNICONIFY

ws_unicon:
 move.l   a5,a1
 move.l   a4,a0
 move.w   d7,d0
 bsr      wind_uniconify
 bra      ws_endsw_ret

* case 28 = WF_UNICONIFYXYWH

ws_unicong:
 move.l   (a5)+,w_unic(a4)
 move.l   (a5),w_unic+g_w(a4)
 bra      ws_endsw

* case  24 = WF_BEVENT   (MultiTOS)

ws_bevent:
 move.b   1(a5),w_attr+1(a4)       ; Nur Bits 0..7 merken
 bra      ws_endsw

* case 100 = WF_BACK     (Mag!X 1.x)
* case  25 = WF_BOTTOM   (MultiTOS)

ws_back:
 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq      ws_err2                  ; nein, Ende
 bset     #WSTAT_QUIET_B,w_state+1(a4)       ; WM_UNTOPPED verhindern

 move.l   a4,a0
 moveq    #-1,d1                   ; wind_bottom (ganz nach unten)
 move.w   d7,d0
 bsr      wind_rearrange

 bclr     #WSTAT_QUIET_B,w_state+1(a4)       ; WM_UNTOPPED ermoeglichen
 bra      ws_set_app               ; MagiC 5.05: Menue umschalten
;bra      ws_endsw

* case 2 = WF_NAME

ws_name:
 btst     #NAME_B,w_kind+1(a4)
 beq      ws_err2
 moveq    #O_NAME,d6               ; Fensterobjekt fuer NAME (G_BOXTEXT)
 moveq    #w_name,d0

ws_naminf:
 move.l   (a5),0(a4,d0.w)
 move.l   a4,a0
 move.l   wbm_sstr,a2
 jsr      (a2)                     ; Callback fuer "geaendert"

 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq.b    ws_nami_nodr             ; nein, nicht zeichnen

 lea      w_tree(a4),a0
 move.w   d6,d0
 mulu     #24,d0
 cmpi.w   #-1,ob_next(a0,d0.w)     ; Objekt nicht eingelinkt ?
 beq.b    ws_nami_nodr             ; nicht eingelinkt, nicht zeichnen

 subq.l   #8,sp                    ; Platz fuer ein GRECT
 move.l   sp,a1                    ; GRECT *g
 move.w   d6,d0                    ; obj
;lea      w_tree(a4),a0            ; tree
 jsr      obj_to_g                 ; Objektausmasse berechnen

;suba.l   a0,a0                    ; alles neu
 move.l   sp,a0                    ; GRECT
;move.w   d6,d1                    ; start = Objektnummer
 moveq    #0,d1                    ; ab root
 move.w   d7,d0                    ; whdl
 bsr      wind_draw
 addq.l   #8,sp
ws_nami_nodr:
 bra      ws_endsw

* case 3 = WF_INFO

ws_info:
 btst     #INFO_B,w_kind+1(a4)
 beq      ws_err2
 moveq    #O_INFO,d6               ; Fensterobjekt fuer INFO (G_TEXT)
 moveq    #w_info,d0
 bra.b    ws_naminf

* case 19 = WF_SIZTOP/WF_DCOLOR

* koor[0]      Fensterobjektnummer
* koor[1]      Farben fuer aktives Fenster
* koor[2]      Farben fuer inaktives Fenster

ws_siztop:
 move.w   d7,d0
 bne      ws_sizetop               ; Handle > 0: WF_SIZETOP
; Bei Handle 0 muss es WF_DCOLOR sein
 move.w   (a5),d1
 bsr      calc_dcol
 bmi      ws_endsw                 ; gibt es in Mag!X nicht
 move.w   d0,d1                    ; Index merken
 lea      dcol_box,a0
 add.w    d0,a0
 move.w   4(a5),d0
 cmpi.w   #-1,d0
 beq.b    ws_s_old
 move.w   d0,(a0)
ws_s_old:
 addq.l   #2,a0
 move.w   2(a5),d0
 cmpi.w   #-1,d0
 beq.b    ws_s_old2
 move.w   d0,(a0)
ws_s_old2:
 move.w   6(a5),d0                 ; 3D-Flags
 cmpi.w   #-1,d0
 beq.b    ws_s_old3                ; nein, nicht aendern
 andi.w   #$f00,d0                 ; eine der Masken gesetzt ?
 beq.b    ws_s_old3                ; nein, nicht aendern
 lsr.w    #2,d1                    ; Langwortindex => Byteindex
 move.w   d1,-(sp)
 lea      f3d_box,a0
 adda.w   (sp)+,a0
 move.w   6(a5),d0
 andi.w   #3,d0                    ; 3D-Flag isolieren
 move.b   d0,(a0)                  ; Flag aendern
ws_s_old3:
 cmpi.w   #W_FULLER,(a5)           ; Fuller geaendert ?
 bne      ws_endsw                 ; nein
 move.l   dcol_fuller,dcol_bdrop   ; fuer Backdrop-Button
 move.l   dcol_fuller,dcol_iconify ; fuer Iconifier
 bra      ws_endsw
; sonst WF_SIZETOP
ws_sizetop:
 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq      ws_err2                  ; nein, Ende

 moveq    #0,d1                    ; wind_top (Fenster ganz nach oben)
 move.l   a4,a0                    ; WINDOW *
;move.w   d0,d0                    ; whdl
 bsr      wind_rearrange

* case 5 = WF_CURRXYWH

ws_curr:
 move.l   w_curr(a4),w_prev(a4)    ; altes Rechteck als vorheriges
 move.l   w_curr+g_w(a4),w_prev+g_w(a4)
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 beq.b    ws_no_csh                ; nein, OK
;btst     #1,w_tattr(a4)           ; ikonifiziert?
;bne.b    ws_no_csh                ; ja, OK
 move.w   w_oldheight(a4),d2
 sub.w    w_curr+g_h(a4),d2
 add.w    d2,w_prev+g_h(a4)        ; Hoehe, als ob nicht ge-shaded
 move.w   g_h(a5),w_oldheight(a4)
 move.w   wbm_hshade,g_h(a5)       ; Hoehe immer minimal!
ws_no_csh:
 move.l   a5,a1
 move.l   a4,a0                    ; WINDOW *
 moveq    #0,d1                    ; kein neues oberstes
 move.w   d7,d0
 bsr      set_windxywh
 bra      ws_endsw

* case WF_SHADE (WINX)

ws_shade:
 move.l   a4,a0
 move.w   d7,d0                    ; d0 = whdl, a0 = WINDOW *

 tst.w    (a5)                     ; shadeMode
 bgt.b    ws_shsh                  ; ->shade-n
 beq.b    ws_shunsh                ; ->un-shade-n
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 beq.b    ws_shsh                  ; nein, shaden
ws_shunsh:
 bsr      wind_unshade
 bra.b    ws_shend
ws_shsh:
 bsr      wind_shade
ws_shend:
 bra      ws_endsw_ret

* case WF_STACK (WINX)

ws_stack:
; erstmal sehen, wo im Stapel das andere Fenster ist
 move.w   (a5),d0                  ; aboveWinID
 beq      ws_back                  ; Sonderfall
 bmi      ws_top                   ; Sonderfall
 bsr      wind_stack_getpos
 bmi      ws_err2                  ; Fenster ist nicht geoeffnet!
 addq.w   #1,d0                    ; wir wollen eins drunter
 move.w   d0,d1                    ; neue Stapelposition
 move.l   a4,a0
 move.w   d7,d0
 bsr      wind_rearrange
 bra      ws_endsw

* case WF_TOPALL (WINX)

ws_topall:
 move.w   (a5),d0
 cmpi.w   #NAPPS,d0
 bcc      ws_err2                  ; ap_id ungueltig
 add.w    d0,d0
 add.w    d0,d0                    ; *4
 lea      applx,a0
 move.l   0(a0,d0.w),d6
 ble      ws_err2                  ; ap_id ungueltig
ws_topall_d6:
 clr.w    -(sp)                    ; Zaehler
 clr.w    -(sp)                    ; letztes behandeltes Fenster
ws_topall_loop:
 move.l   d6,a0
 move.w   (sp),d0                  ; ermittle Fenster unter <d0>
 bsr      get_next_window
 tst.w    d0                       ; whdl ?
 beq.b    ws_topall_endloop        ; keins mehr vorhanden
 move.w   d0,(sp)
 bsr      whdl_to_wnd
 beq.b    ws_topall_endloop        ; ???
;move.l   a0,a0
 move.w   2(sp),d1
 move.w   (sp),d0
 bsr      wind_rearrange
 addq.w   #1,2(sp)
 bra.b    ws_topall_loop
ws_topall_endloop:
 addq.l   #4,sp
 bra      ws_endsw

* case WF_BOTTOMALL (WINX)

ws_bottomall:
; ermittle Listenende
 lea      whdlx,a2
 moveq    #-2,d6                   ; Fensterpositionen
wsba_loop1:
 addq.l   #1,d6                    ; Fensterpositionen mitzaehlen
 tst.w    (a2)+
 bne.b    wsba_loop1
 subq.l   #2,a2                    ; a2 auf DESKWINDOW (0)
wsba_loop2:
 cmpa.l   #whdlx,a2                ; schon ueber Tabellenbeginn?
 bls.b    wsba_endloop2            ; ja, Ende
 move.w   -(a2),d0                 ; vorheriges WinHandle
 bmi.b    wsba_loop2               ; eingefrorenes Fenster
 bsr      whdl_to_wnd
 beq.b    wsba_loop2               ; ???
 move.l   w_owner(a0),a1           ; Fenstereigner
 move.w   ap_id(a1),d0
 cmp.w    (a5),d0                  ; unsere Applikation?
 bne.b    wsba_loop2               ; nein, weiter
 move.l   a2,-(sp)                 ; a2 retten
;move.l   a0,a0                    ; WINDOW
 move.w   d6,d1                    ; neue Stapelposition
 bne.b    wsba_no_top              ; nicht nach hinten
 move.w   whdlx,d0
 cmp.w    (a2),d0                  ; sind wir schon oben?
 beq.b    wsba_no_totop            ; ja, Menuezeilenumschaltung verhindern
wsba_no_top:
 move.w   (a2),d0                  ; WindowHandle
 bsr      wind_rearrange           ; umsortieren
wsba_no_totop:
 move.l   (sp)+,a2                 ; a2 zurueck
 subq.l   #1,d6
 bra.b    wsba_loop2
wsba_endloop2:
 bra      ws_set_app               ; MagiC 5.05: Menue umschalten
;bra      ws_endsw

* case 10 = WF_TOP

ws_top:
 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq      ws_err2                  ; nein, Ende
 cmp.w    bdrop_thdl,d7
 bne.b    ws_t_clr
 lea      200,a0                   ; 200/200 s = 1 Sekunde Timeout
 add.l    bdrop_timer,a0
 cmpa.l   timer_cnt,a0
 bcs.b    ws_t_clr                 ; mehr als eine halbe Sekunde her

* verzoegertes Backdrop

 move.w   bdrop_hdl,d0             ; dies soll ganz nach hinten
 clr.w    bdrop_thdl               ; Backdrop- Vorgang canceln

 move.l   a4,a0
 moveq    #-1,d1                   ; Fenster nach hinten
 bsr      wind_rearrange           ; stattdessen Backdrop ausfuehren

 bra.b    ws_set_app               ; MagiC 3.01: Menue umschalten

ws_t_clr:
 clr.w    bdrop_thdl               ; Backdrop- Vorgang canceln

 cmp.w    topall_thdl,d7
 bne.b    ws_t_clr2
 lea      200,a0                   ; 200/200 s = 1 Sekunde Timeout
 add.l    topall_timer,a0
 cmpa.l   timer_cnt,a0
 bcs.b    ws_t_clr2                ; mehr als eine halbe Sekunde her

* verzoegertes TopAll

 clr.w    topall_thdl              ; TopAll- Vorgang canceln
 move.l   w_owner(a4),d6
 bra      ws_topall_d6

ws_t_clr2:
 clr.w    topall_thdl              ; TopAll- Vorgang canceln
 bset     #WSTAT_QUIET_B,w_state+1(a4)       ; WM_ONTOP verhindern

 moveq    #0,d1                    ; wind_top (Fenster ganz nach oben)
 move.l   a4,a0
 move.w   d7,d0
 bsr      wind_rearrange

 bclr     #WSTAT_QUIET_B,w_state+1(a4)       ; WM_ONTOP ermoeglichen
ws_set_app:
 move.l   topwind_app,a0
 jsr      set_app                  ; MagiC 5.05: Menue umschalten

 bra      ws_endsw

* case 13 = Redraw aussschalten bzw. einschalten und ausfuehren
* Achtung: unter MAGIX nicht mehr vorhanden, Redraw jedoch erlaubt

ws_resvd:
 tst.w    d7
 bne      ws_endsw                 ; Ausschalten nicht erlaubt
 move.l   a5,a0
 bsr      wind0_draw               ; Fenster 0 neumalen
 move.l   a5,a0
 bsr      send_all_redraws         ; andere Fenster neumalen
 bra      ws_endsw

* case 14 = WF_NEWDESK

ws_newdesk:
 move.l   act_appl,a0
 move.l   (a5)+,d0                 ; OBJECT *tree
 beq.b    wsnd_off
 move.w   (a5),d1                  ; int    firstob
 bsr      desk_on
 bra      ws_endsw
wsnd_off:
 bsr      desk_off
 bra      ws_endsw

* case  8 = WF_HSLIDE
* case  9 = WF_VSLIDE
* case 15 = WF_HSLSIZE
* case 16 = WF_VSLSIZE

ws_slide:
 move.w   (a5),d1                  ; neue Groesse/Position
 bge.b    ws_sll1
 moveq    #-1,d1                   ; nicht kleiner als -1
ws_sll1:
 cmpi.w   #1000,d1
 ble.b    ws_sll2
 move.w   #1000,d1
ws_sll2:
 subq.w   #8,d6
 bne.b    ws_sl1
* WF_HSLIDE
 lea      w_hslide(a4),a0
 bra.b    ws_sl_hori
ws_sl1:
 subq.w   #1,d6
 bne.b    ws_sl2
* WF_VSLIDE
 lea      w_vslide(a4),a0
 bra.b    ws_sl_verti
ws_sl2:
 subq.w   #6,d6
 bne.b    ws_sl3
* WF_HSLSIZEE
 lea      w_hslsize(a4),a0
ws_sl_hori:
 moveq    #O_HSCROLL,d6            ; uebergeordnetes Objekt
 moveq    #0,d0                    ; horizontal
 bra.b    ws_slend
ws_sl3:
* WF_VSLSIZE
 lea      w_vslsize(a4),a0
ws_sl_verti:
 moveq    #O_VSCROLL,d6            ; uebergeordnetes Objekt
 moveq    #1,d0                    ; vertikal
ws_slend:
 btst     #6,(config_status+3).w
 bne.b    ws_nosmart               ; Smart Redraw OFF
 cmp.w    (a0),d1
 beq.b    ws_endsw                 ; Wert hat sich nicht geaendert
ws_nosmart:
 move.w   d1,(a0)                  ; Wert setzen
;move.w   d0,d0                    ; Flag "vertikal"
 move.l   a4,a0                    ; WINDOW *
 move.l   wbm_sslid,a1
 jsr      (a1)                     ; Fensterrahmen aendern

 btst     #WSTAT_OPENED_B,w_state+1(a4)
 beq.b    ws_sl_nodr               ; nein, nicht zeichnen

 suba.l   a0,a0                    ; alles zeichnen
 move.w   d6,d1                    ; startob
 move.w   d7,d0                    ; whdl
 bsr      wind_draw
ws_sl_nodr:

ws_endsw:
 moveq    #1,d6                    ; kein Fehler
ws_endsw_ret:
 jsr      update_0
 move.l   d6,d0
ws_ende:
 movem.l  (sp)+,a5/a4/a2/d7/d6
 rts
ws_err2:
 moveq    #0,d6
 bra.b    ws_endsw_ret
ws_err:
 moveq    #0,d0                    ; Fehler
 bra.b    ws_ende


**********************************************************************
*
* PUREC WORD wind_find(WORD x, WORD y )
*
* int wind_find(d0 = int x, d1 = int y )
*

wind_find:
 move.w   d7,-(sp)
 move.l   a2,-(sp)
 move.w   d0,d7                    ; x retten
 lea      whdlx,a2
 move.l   windx,a1
wf_loop:
 move.w   (a2),d0                  ; Fenster- Handle
 bmi.b    wf_invalid               ; ungueltiges Handle
 bsr      whdl_to_wnd              ;  aendert nur d0/a0
 beq.b    wf_invalid               ; ???
 lea      w_curr(a0),a0            ; Fenster- Rechteck
;move.w   d1,d1
 move.w   d7,d0
 jsr      xy_in_grect              ; aendert nur d2
 bne.b    wf_found
wf_invalid:
 tst.w    (a2)+                    ; war schon Fenster 0 ?
 bne.b    wf_loop                  ; nein, weiter
 moveq    #-1,d0
 bra.b    wf_ende
wf_found:
 move.w   (a2),d0
wf_ende:
 move.l   (sp)+,a2
 move.w   (sp)+,d7
 rts


**********************************************************************
*
* void _wbm_calc( d0 = WORD kind, a0 = WORD *border)
*
* Callback fuer wind_calc().
* Gibt zu einem Fenstertyp den Rahmen zurueck, und zwar:
*
*    border[0]      linken Rahmen
*    border[1]      oberen Rahmen
*    border[2]      rechten Rahmen
*    border[3]      unteren Rahmen
*

_wbm_calc:
 moveq    #1,d2
 move.w   d2,(a0)+                 ; linker Rand = 1
 move.w   d2,(a0)+                 ; oberer Rand = 1
 move.w   d2,(a0)+                 ; rechter Rand = 1
 move.w   d2,(a0)                  ; unterer Rand = 1
 subq.l   #6,a0

 move.w   gr_hhbox,d2
 subq.w   #1,d2                    ; d2 = gr_hhbox-1

 move.w   d0,d1
 andi.w   #NAME+CLOSER+FULLER+ICONIFIER,d1
 beq.b    _wbmb_no_top
 add.w    d2,2(a0)                 ; oberer Rand += gr_hhbox-1
_wbmb_no_top:
 btst     #INFO_B,d0
 beq.b    _wbmb_no_info
 move.l   d2,a1                    ; d2 retten
 move.w   inw_height,d2
 subq.w   #1,d2                    ; d2 = gr_hhbox-1
 add.w    d2,2(a0)                 ; oberer Rand += gr_hhbox-1
 move.l   a1,d2                    ; d2 zurueck
_wbmb_no_info:
 move.w   d0,d1
 andi.w   #VSLIDE+DNARROW+UPARROW,d1
 bne.b    _wbmb_isright
 move.w   d0,d1
 andi.w   #SIZER,d1
 beq.b    _wbmb_no_right
 move.w   d0,d1
 andi.w   #HSLIDE+RTARROW+LFARROW,d1
 bne.b    _wbmb_no_right
_wbmb_isright:
 move.w   gr_hwbox,d1
 subq.w   #1,d1
 add.w    d1,4(a0)                 ; rechter Rand += gr_hwbox-1
_wbmb_no_right:
 move.w   d0,d1
 and.w    #HSLIDE+RTARROW+LFARROW,d1
 beq.b    _wbmb_no_bot
 add.w    d2,6(a0)                 ; unterer Rand += gr_hhbox-1
_wbmb_no_bot:
 rts


**********************************************************************
*
* PUREC WORD _wind_calc( WORD type,  WORD kind,
*               GRECT *in, GRECT *out)
*
* int _wind_calc(d0 = int type,  d1 = int kind,
*               a0 = GRECT *in, a1 = GRECT *out)
*
* type = 0 (WC_BORDER)   errechne Aussenmasse
* type = 1 (WC_WORK)     errechne Innenmasse
*

_wind_calc:
 move.l   a2,-(sp)                 ; a2 retten

 move.w   d0,-(sp)                 ; type retten
 move.l   a1,-(sp)                 ; outg retten
 move.l   a0,-(sp)                 ; ing retten

 move.w   d1,d0
 move.l   a1,a0                    ; outg
 move.l   wbm_calc,a1
 jsr      (a1)                     ; outg wird der Rahmen

 move.l   (sp)+,a0                 ; ing
 move.l   (sp)+,a1                 ; outg

 move.w   (a1),d1                  ; linker Rand
 add.w    4(a1),d1                 ; d1 = linker + rechter Rand
 move.w   2(a1),d2                 ; oberer Rand
 add.w    6(a1),d2                 ; d2 = oberer + unterer Rand

 tst.w    (sp)+                    ; type ?
 bne.b    _wca_work
* type == 0 (WC_BORDER)
 move.w   (a0)+,d0                 ; g.g_x
 sub.w    (a1),d0                  ; - linker Rand
 move.w   d0,(a1)+
 move.w   (a0)+,d0                 ; g.g_y
 sub.w    (a1),d0                  ; - oberer Rand
 move.w   d0,(a1)+
 add.w    (a0)+,d1                 ; g.g_w + (linker Rand + rechter Rand)
 move.w   d1,(a1)+
 add.w    (a0)+,d2                 ; g.g_h + (oberer Rand + unterer Rand)
 move.w   d2,(a1)
 bra.b    _wcalc_ende
_wca_work:
* type == 0 (WC_WORK)
 move.w   (a0)+,d0                 ; g.g_x
 add.w    d0,(a1)+                 ; + linker Rand
 move.w   (a0)+,d0                 ; g.g_y
 add.w    d0,(a1)+                 ; + oberer Rand
 move.w   (a0)+,d0                 ; g.g_w
 sub.w    d1,d0                    ; - (linker Rand + rechter Rand)
 move.w   d0,(a1)+
 move.w   (a0)+,d0                 ; g.g_h
 sub.w    d2,d0                    ; - (oberer Rand + unterer Rand)
 move.w   d0,(a1)
_wcalc_ende:
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* void _wbm_obfind( d0 = int x, d1 = int y, a0 = WINDOW *w)
*
* Callback fuer wind_was_clicked().
*

_wbm_obfind:
 swap     d0                       ; x ins Hiword
 move.w   d1,d0                    ; y ins Loword
 move.l   d0,d2                    ; y/x
 moveq    #MAXDEPTH,d1
 moveq    #0,d0                    ; startob
 lea      w_tree(a0),a0
 jmp      _objc_find


**********************************************************************
*
* void find_icon_pos( a0 = GRECT *g )
*

find_icon_pos:
 movem.l  a5/a6,-(sp)
 subq.l   #8,sp
 move.l   a0,a6

 clr.l    (a0)+               ; GRECT mit je 72 Pixel aussen
 move.l   #$00480048,(a0)

/*
 move.l   a0,a1               ; out
 move.l   #$00480048,-(sp)
 clr.l    -(sp)               ; GRECT mit je 72 Pixel innen
 lea      (sp),a0
 moveq    #NAME,d1
 moveq    #0,d0               ; (WC_BORDER)   errechne Aussenmasse
 bsr      _wind_calc
 addq.l   #8,sp
*/

 move.w   scr_h,d0
 sub.w    g_h(a6),d0
 move.w   d0,g_y(a6)          ; Beginne Suche am unteren Rand
fip_yloop:
 clr.w    g_x(a6)             ; Beginne Suche nach freiem Platz bei x=0
fip_xloop:
* Durchsuche Fensterliste
 lea      whdlx,a5
fip_hloop:
 move.w   (a5)+,d0
 bmi.b    fip_hloop
 beq.b    fip_ende            ; Listenende, alles OK !
 bsr      whdl_to_wnd
 beq.b    fip_ende            ; ???
 btst     #WSTAT_ICONIFIED_B,w_state+1(a0)
 beq.b    fip_hloop           ; Fenster nicht ikonifiziert
 lea      w_curr(a0),a0       ; Fensterausmasse
 move.l   g_x(a6),(sp)
 move.l   g_w(a6),g_w(sp)
 lea      (sp),a1
 jsr      grects_intersect    ; liegt da das Fenster ?
 beq.b    fip_hloop           ; nein, naechstes Fenster
* der Platz ist schon belegt
 move.w   g_w(a6),d0
 add.w    d0,g_x(a6)          ; einen Platz weiter nach rechts
 add.w    g_x(a6),d0          ; rechter Rand
 cmp.w    scr_w,d0            ; rechts vom Bildschirm ?
 bls.b    fip_xloop           ; nein, weitermachen
 move.w   g_h(a6),d0
 sub.w    d0,g_y(a6)          ; einen Platz weiter nach oben
 move.w   g_y(a6),d1
 cmp.w    desk_g+g_y,d1       ; ueber Bildschirm ?
 bcc.b    fip_yloop           ; nein, weitermachen
* alle Plaetze belegt
 move.l   desk_g+g_x,g_x(a6)  ; Default: links oben
fip_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* Callback fuer gr_xslidbx.
* Auch verwendet fuer neue Fenster-Vergroesserung und Verschieben
*
* Eingabe:
*    d0   int Sliderpos 0..1000 bei WM_V/HSLID
*         bzw. w/h bei WM_SIZED
*         bzw. x/y bei WM_MOVED
*    a0   ->   long winslid_callback
*              int  *daten
*              int  whdl
*              int  dst_apid
*              int  msgcode
*
* Rueckgabe:
*    d0   TRUE, wenn weitermachen
*

windslid_callback:
 movem.l  d3/d7/a6/a5,-(sp)
 move.l   a0,a6                    ; Parameter nach a6
 move.l   d0,d7                    ; geaenderte Daten nach d7
 move.w   8(a0),d0                 ; whdl
 bsr      whdl_to_wnd
 beq      wwsl_break               ; ???
 move.l   a0,a5                    ; a5 = (WINDOW *)

 btst     #WSTAT_OPENED_B,w_state+1(a5)
 bne.b    wwsl_unblock             ; ja
wwsl_wait_rel2:
 btst     #0,gr_mkmstate+1
 beq      wwsl_break
 jsr      appl_yield               ; warte unbedingt auf Loslassen der Maus
 bra.b    wwsl_wait_rel2

wwsl_unblock:
 move.w   upd_blockage,-(sp)       ; Update-Counter retten
 move.w   #1,upd_blockage          ; auf 1 setzen, damit er gleich frei wird
 move.l   mouse_app,-(sp)          ; retten
 move.l   applx+4,a0
 jsr      set_mouse_app            ; umsetzen auf SCRENMGR
 jsr      update_0                 ; Applikation wieder freigeben

 btst     #WSTAT_OPENED_B,w_state+1(a5)
 beq.b    wwsl_nicht_weiter        ; nein!!!

 addq.l   #4,a6                    ; Funktionsadresse ueberspringen
 move.l   (a6)+,a1                 ; Daten
 cmpi.w   #WM_MOVED,4(a6)
 beq.b    wwsl_mover
 cmpi.w   #WM_SIZED,4(a6)
 beq.b    wwsl_sizer
 move.w   d7,(a1)                  ; Scrollpos. eintragen
 bra.b    wwsl_all
* fuer WM_SIZED
wwsl_sizer:
 move.l   d7,g_w(a1)
 bra.b    wwsl_all
* fuer WM_MOVED
wwsl_mover:
 move.l   d7,(a1)
wwsl_all:
 move.w   (a6)+,d2                 ; whdl
 move.w   (a6)+,d1                 ; dst_apid
 move.w   (a6)+,d0                 ; Message- Code
 move.l   a1,a0
 jsr      send_msg

 move.w   #1000,d3
wwsl_apy_loop:
 btst     #0,gr_mkmstate+1
 beq.b    wwsl_nicht_weiter
 btst     #WSTAT_OPENED_B,w_state+1(a5)      ; Fenster noch geoeffnet
 beq.b    wwsl_wait_rel            ; nein!!!
 jsr      appl_yield
 dbra     d3,wwsl_apy_loop
 moveq    #1,d7                    ; weitermachen
 bra.b    wwc_endslloop

wwsl_wait_rel:
 btst     #0,gr_mkmstate+1
 beq.b    wwsl_nicht_weiter
 jsr      appl_yield               ; warte unbedingt auf Loslassen der Maus
 bra.b    wwsl_wait_rel
wwsl_nicht_weiter:
 moveq    #0,d7
wwc_endslloop:
 jsr      update_1                 ; Applikation wieder sperren
 move.l   (sp)+,a0
; move.l  applx+4,a1
; cmpa.l  mouse_app,a1             ; Maus-Applikation inzwischen geaendert?
; bne.b   wwsl_mchanged            ; ja, nicht zuruecksetzen
 jsr      set_mouse_app            ; ja, zuruecksetzen
; wwsl_mchanged:
 move.w   (sp)+,upd_blockage       ; Update-Counter zurueck
 tst.w    d7                       ; weitermachen?
 bne.b    wwsl_weiter              ; ja!
wwsl_break:
; bclr    #WSTAT_LOCKED_B,w_state+1(a5)      ; unlock!
 moveq    #0,d0                    ; abbrechen
 bra.b    wwsl_ende
wwsl_weiter:
 btst     #0,gr_mkmstate+1
 sne      d0
 ext.w    d0
wwsl_ende:
 movem.l  (sp)+,d3/a6/a5/d7
 rts


**********************************************************************
*
* int wind_graf_watchbox(a0 = WINDOW *w, d0 = int objnr )
*

wind_graf_watchbox:
 movem.l  d5/d7/a5/a3,-(sp)
 move.w   d0,d7                    ; d7 = int objnr
 lea      w_tree(a0),a5            ; a5 = tree
 move.w   w_whdl(a0),d5            ; d5 = windowhandle
 subq.l   #8,sp
 clr.w    -(sp)                    ; MGRECT (10 Bytes)

 jsr      mctrl_1

 jsr      set_full_clip

 lea      2(sp),a1                 ; GRECT *
 move.w   d7,d0
 move.l   a5,a0
 jsr      obj_to_g                 ; Objektausmasse nach GRECT 2(sp)

* Zeiger auf Objekte bestimmen

 move.w   d7,d0
 mulu     #24,d0
 lea      0(a5,d0.w),a3            ; Das Objekt selbst

* Schleife

gwb_loop:
 bchg.b   #SELECTED_B,ob_state+1(a3) ; Zustand umsetzen

 move.w   d5,d2                    ; whdl
 lea      2(sp),a1                 ; &g
 moveq    #MAXDEPTH,d1
 move.w   d7,d0                    ; startob
 move.l   a5,a0                    ; tree
 bsr      objc_wdraw

 eori.w   #1,(sp)                  ; in/out- Flag fuer MGRECT toggeln

 move.l   sp,a0
 bsr      evnt_rel_mm              ; warte auf Mausbewegung und Loslassen der linken Taste
 beq.b    gwb_loop                 ; nicht losgelassen

 move.w   d7,d0
 mulu     #24,d0
 bclr.b   #SELECTED_B,ob_state+1(a3) ; testen und loeschen
 beq.b    gwb_normal3              ; war schon geloescht

 move.w   d5,d2                    ; whdl
 lea      2(sp),a1                 ; &g
 moveq    #MAXDEPTH,d1
 move.w   d7,d0                    ; startob
 move.l   a5,a0                    ; tree
 bsr      objc_wdraw

gwb_normal3:
 jsr      mctrl_0

 move.w   (sp)+,d0                 ; in/out- Flag
 addq.l   #8,sp
 movem.l  (sp)+,a3/a5/d7/d5
 rts


**********************************************************************
*
* void wind_was_clicked(d0 = int whdl,
*                       a0 = {x, y, bstate, kstate, key, nclicks})
*
* Wird nur von screnmgr_button aufgerufen
*
* a3           WINDOW *
* -8(a6)       GRECT     fuer CURRXYWH
* -$10(a6)     GRECT     (temporaer)
*

wind_was_clicked:
 link     a6,#-$12
 movem.l  d3/d4/d5/d6/d7/a5/a4/a3,-(sp)
 move.l   a0,a5
 move.w   d0,d7                    ; d7 = whdl
 bsr      whdl_to_wnd
 beq      wwc_ende                 ; ???
 move.l   a0,a3
 lea      -$10(a6),a4
 clr.w    d5
 cmp.w    topwhdl,d7               ; d7 ist oberstes Fenster ?
 seq      -$12(a6)                 ; merken
 beq.b    wwc_dialog               ; ja
*
* Ein Mausklick auf ein nicht aktives Fenster ist ausgefuehrt worden
* Wenn die Maustaste nicht mehr gedrueckt ist, wird das Fenster nach oben
* gebracht und ggf. vorher noch die "aktive" Applikation umgeschaltet.
* Dasselbe passiert, wenn nicht auf den Rahmen geklickt wurde.
*
 lea      w_work(a3),a0
 move.w   2(a5),d1
 move.w   (a5),d0
 jsr      xy_in_grect
 beq.b    wwc_dialog               ; nicht im Arbeitsbereich

* nicht aktives Fenster, Klick in den Arbeitsbereich.
* Doppelklick: iconifizierte Fenster wieder oeffnen.

wwc_unicon:
 cmpi.w   #2,10(a5)                ; Doppelklick ?
 bne.b    wwc_topit                ; nein
 btst     #WSTAT_ICONIFIED_B,w_state+1(a3)
 beq.b    wwc_topit                ; nein
 moveq    #WM_UNICONIFY,d5
 move.l   w_unic(a3),-8(a6)
 move.l   w_unic+4(a3),-8+4(a6)
 btst     #WSTAT_SHADED_B,w_state+1(a3)
 beq      wwc_endsw                ; nein, normal
 move.w   w_oldheight(a3),-8+g_h(a6)    ; Hoehe tuerken
 bra      wwc_endsw

*
* Das Fenster soll per Mausklick nach oben gebracht werden.
* Applikation umschalten, wenn moeglich
*
wwc_topit:
 move.l   w_owner(a3),a0
 cmp.l    topwind_app,a0
 beq      wwc_topped               ; hat sich nicht geaendert
 jsr      set_app
 bra      wwc_topped

wwc_dialog:
* Das angeklickte Fenster ist das oberste, oder ein unteres soll
* verschoben werden. Objektbaum erstellen

 move.w   (a5),d0                  ; x
 move.w   2(a5),d1                 ; y
 move.l   a3,a0
 move.l   wbm_obfind,a1
 jsr      (a1)                     ; angeklickte Objektnummer ermitteln

 move.w   d0,d6                    ; angeklickte Objektnummer nach d6

 move.l   w_curr(a3),-8(a6)
 move.l   w_curr+g_w(a3),-8+g_w(a6)
 
 
 btst     #WSTAT_SHADED_B,w_state+1(a3)
 beq.b    wwc_l1                   ; nein, normal
;btst     #1,w_tattr(a3)           ; ICONIFIED?
;bne.b    wwc_l1                   ; ja, normal
 move.w   w_oldheight(a3),d2
 sub.w    w_curr+g_h(a3),d2
 add.w    d2,-8+g_h(a6)            ; Hoehe, als ob nicht ge-shaded
wwc_l1:


 move.w   d6,d0
 bra      wwc_switch

wwc_topped:
 moveq    #WM_TOPPED,d5
 bra      wwc_endsw

**
* case 1  (CLOSE- Box)
**

wwc_close:
 btst     #12,d1                   ; HOTCLOSEBOX ?
 beq.b    wwc_full                 ; nein, normale Reaktion
 moveq    #WM_CLOSED,d5
 clr.w    -(sp)                    ; nicht auf Loslassen der Maustaste warten
 bra      wwc_hot

**
* case 4  (FULL- Box)
* case 3  (DROP- Box)
* case 15 (ICONIFIER)
**

wwc_icon:
wwc_full:
wwc_drop:
 move.l   a3,a0                    ; WINDOW
 move.w   d6,d0                    ; objnr
 bsr      wind_graf_watchbox
 tst.w    d0
 beq      wwc_endsw                ; Objekt war nicht invertiert, ende

 cmpi.w   #3,d6
 bne.b    wwc_nodrop

wwc_do_drop:
 btst     #5,w_kind(a3)            ; BACKDROP ? (Bit 13)
 bne      wwc_send_drop            ; ja, nicht selbst ausfuehren
 btst     #2,7(a5)                 ; K_CTRL ?
 bne.b    wwc_bottomall            ; ja
 cmp.w    topwhdl,d7               ; bin ich oberstes Fenster
 bne.b    wwc_bnt                  ; nein, einfach nach hinten klappen
 move.w   d7,bdrop_hdl             ; dieses Fenster nach hinten
 move.l   timer_cnt,bdrop_timer    ; Zaehler fuer den Fall "timeout"
; naechstes Fenster ermitteln
 lea      whdlx+2,a1
 move.w   scr_h,d1                 ; y > scr_h heisst "ausgeblendet"
wwc_bloop:
 move.w   (a1)+,d0
 bmi.b    wwc_bloop                ; unsichtbares Fenster
 beq      wwc_ende                 ; kein unteres Fenster
 bsr      whdl_to_wnd
 beq.b    wwc_bloop                ; ???
 cmp.w    w_curr+g_y(a0),d1        ; ausgeblendet ?
 bls.b    wwc_bloop                ; ja, weitersuchen

 move.w   -(a1),d0                 ; neues oberes Fenster merken
 move.w   d0,bdrop_thdl            ; dieses wird getopped
 move.w   d0,d7
 move.l   a0,a3                    ; WINDOW *
 bra      wwc_topped               ; TOPPED -> naechstes Fenster
wwc_bottomall:
 clr.l    -(sp)
 clr.w    -(sp)
 move.l   w_owner(a3),a0           ; Fenstereigner
 move.w   ap_id(a0),-(sp)
 lea      (sp),a0                  ; WORD koor[4]
 move.w   #WF_BOTTOMALL,d1
 move.w   d7,d0
 bsr      _wind_set
 addq.l   #8,sp
 bra      wwc_ende
wwc_bnt:
 move.l   a3,a0
 moveq    #-1,d1                   ; Fenster nach hinten
 move.w   d7,d0
 bsr      wind_rearrange
 bra      wwc_ende

**
* ICONIFY
**

wwc_nodrop:
 cmpi.w   #15,d6
 bne.b    wwc_noicon
 moveq    #WM_ICONIFY,d5
 btst     #2,7(a5)                 ; K_CTRL ?
 beq.b    wwc_noall                ; nein
 moveq    #WM_ALLICONIFY,d5        ; Ctrl: alle Fenster ikonifizieren
wwc_noall:
 lea      -8(a6),a0                ; GRECT fuer Icon
 bsr      find_icon_pos            ; Setze GRECT fuer ikonifiziertes Fenster
 bra      wwc_endsw

* FULLER/CLOSER

wwc_noicon:
 moveq    #WM_FULLED,d5
 cmpi.w   #1,d6
 bne.b    wwc_cl1
 moveq    #WM_CLOSED,d5
wwc_cl1:
 bra      wwc_endsw
wwc_send_drop:
 moveq    #WM_BOTTOMED,d5          ; ab Mag!X 2.00
 bra.b    wwc_cl1

**
* case 5 (INFO)
**

wwc_info:
 tst.b    -$12(a6)                 ; Fenster ist aktiv ?
 beq      wwc_topit                ; nein, aktiv machen
 bra      wwc_endsw                ; nein, nichts tun

**
* case 2 (NAME)
**

wwc_name:
 cmpi.w   #2,10(a5)                ; Doppelklick ?
 bne.b    wwc_no_shade             ; nein
 btst     #WSTAT_SHADED_B,w_state+1(a3)
 bne.b    wwc_unshade
 move.l   a3,a0
 move.w   d7,d0
 bsr      wind_shade
 tst.w    d0
 beq      wwc_ende                 ; Fehler beim Shaden
 move.w   #WM_SHADED,d5
 bra      wwc_endsw
wwc_unshade:
 move.l   a3,a0
 move.w   d7,d0
 bsr      wind_unshade
 tst.w    d0
 beq      wwc_ende                 ; Fehler beim UnShaden
 move.w   #WM_UNSHADED,d5
 bra      wwc_endsw
 
wwc_no_shade:
 btst     #0,gr_mkmstate+1         ; Langer Klick ?
 bne.b    wwc_n1                   ; ja, immer verschieben
 tst.b    -$12(a6)                 ; Fenster ist aktiv ?
 beq      wwc_topit                ; nein, Fenster toppen
 btst     #2,look_flags+1          ; expliziter Backdropper ?
 beq.b    wwc_n1                   ; ja, verschieben
 bra      wwc_do_drop              ; nein, Backdrop

wwc_n1:
 btst     #MOVER_B,d1
 beq      wwc_endsw                ; nein, nichts tun

; GRECT bound berechnen.

     IF   WINDXMINUS
 move.w   -8+g_w(a6),d0            ; Fensterbreite
 neg.w    d0
 move.w   d0,g_x(a4)               ; Fenster duerfen links herausragen
     ELSE
 clr.w    g_x(a4)                  ; Fenster duerfen links nicht herausragen
     ENDIF
 move.w   gr_hhbox,g_y(a4)
 move.w   g_x(a4),d0
 neg.w    d0
 add.w    full_g+g_w,d0
 add.w    -8+g_w(a6),d0
 sub.w    gr_hwbox,d0
 subq.w   #6,d0
 move.w   d0,g_w(a4)               ; komische Berechnung
 move.w   #$2710,g_h(a4)           ; dezimal 10000

 btst     #6,look_flags+1          ; Online-Vergroesserung per Default aus ?
 beq.b    wwc_6_off2
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne.b    wwc_new_mover
 btst     #2,7(a5)                 ; K_CTRL ?
 bne.b    wwc_new_mover
 bra      wwc_old_mover
wwc_6_off2:
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne      wwc_old_mover
 btst     #2,7(a5)                 ; K_CTRL ?
 bne      wwc_old_mover

* NEUER MOVER

wwc_new_mover:
 moveq    #4,d0                    ; flat hand
 jsr      graf_mouse

; verhindern, dass das Fenster inzwischen geschlossen wird.
 bset     #WSTAT_LOCKED_B,w_state+1(a3)      ; locked !!!
 move.w   #WM_MOVED,-(sp)          ; msgcode
 move.l   w_owner(a3),a2
 move.w   ap_id(a2),-(sp)          ; dst_apid
 move.w   d7,-(sp)                 ; whdl
 pea      -8(a6)                   ; data
 pea      windslid_callback(pc)
 move.l   sp,d0                    ; callback_data
 move.l   a4,a1                    ; GRECT *bound
 lea      -8(a6),a0                ; CURRXYWH
 jsr      graf_dragbox
 adda.w   #14,sp

 bclr     #WSTAT_LOCKED_B,w_state+1(a3)      ; unlocked !!!

 moveq    #0,d0                    ; arrow
 jsr      graf_mouse

 bra      wwc_ende

* ALTER MOVER

wwc_old_mover:
 moveq    #0,d0                    ; kein callback
 move.l   a4,a1                    ; GRECT *bound
 lea      -8(a6),a0                ; CURRXYWH
 jsr      graf_dragbox
 move.l   d0,-8+g_x(a6)            ; x,y
 moveq    #WM_MOVED,d5
 bra      wwc_endsw

**
* case 6 (SIZE)
**

wwc_size:
 btst     #SIZER_B,d1
 beq      wwc_endsw                ; nein, nichts tun

 btst     #6,look_flags+1          ; Online-Vergroesserung per Default aus ?
 beq.b    wwc_6_off
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne.b    wwc_new_sizer
 btst     #2,7(a5)                 ; K_CTRL ?
 bne.b    wwc_new_sizer
 bra      wwc_old_sizer
wwc_6_off:
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne      wwc_old_sizer
 btst     #2,7(a5)                 ; K_CTRL ?
 bne      wwc_old_sizer

* NEUER SIZER

wwc_new_sizer:
 jsr      mctrl_1

 moveq    #4,d0                    ; flat hand
 jsr      graf_mouse

 bset     #WSTAT_LOCKED_B,w_state+1(a3)      ; locked !!!

 move.l   w_min_g+g_w(a3),-(sp)    ; Minimalbreite/-hoehe
 move.l   g_w-8(a6),-(sp)          ; alte Fenstergroesse (w/h)
 move.l   (a5),-(sp)               ; aktuelle Mausposition

* Schleife

wwc_nsize_loop:
; warte auf Mausbewegung
 moveq    #1,d0
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 move.l   4(sp),-(sp)              ; x/y
 move.w   d0,-(sp)                 ; warte auf Verlassen
 move.l   sp,a0
 bsr      evnt_rel_mm              ; warte auf Loslassen der Taste oder Mausbewegung
 adda.w   #10,sp
 bne.b    wwc_size_ende            ; Maustaste losgelassen, Ende
; Mausbewegung!
 move.w   gr_mkmx,(sp)
 move.w   gr_mkmy,2(sp)            ; neue Mausposition merken

 move.w   gr_mkmx,d0               ; aktuelle Mausposition
 sub.w    (a5),d0                  ; - alte Mausposition
 add.w    4(sp),d0                 ; auf Breite addieren
 cmp.w    8(sp),d0                 ; kleiner als minimale Breite ?
 bge.b    wwc_nsize_ok
 move.w   8(sp),d0
wwc_nsize_ok:
 move.w   d0,d4
 swap     d4                       ; neue Breite ins Hiword
 move.w   gr_mkmy,d0               ; aktuelle Mausposition
 sub.w    2(a5),d0                 ; - alte Mausposition
 add.w    6(sp),d0                 ; auf Hoehe addieren
 cmp.w    10(sp),d0                ; kleiner als minimale Hoehe ?
 bge.b    wwc_nh_ok
 move.w   10(sp),d0
wwc_nh_ok:
 move.w   d0,d4                    ; neue Hoehe ins Loword
 cmp.l    g_w-8(a6),d4             ; haben sich Breite oder Hoehe geaendert ?
 beq.b    wwc_nsize_loop           ; nein, weiter warten

;move.l   d4,g_w-8(a6)             ; neue Breite und Hoehe: erledigt callback

 move.w   #WM_SIZED,-(sp)          ; msgcode
 move.l   w_owner(a3),a2
 move.w   ap_id(a2),-(sp)          ; dst_apid
 move.w   d7,-(sp)                 ; whdl
 pea      -8(a6)                   ; data
 clr.l    -(sp)                    ; dummy
 move.l   sp,a0                    ; callback_data
 move.l   d4,d0
 bsr      windslid_callback
 adda.w   #14,sp
 bra.b    wwc_nsize_loop

wwc_size_ende:
 lea      12(sp),sp

 bclr     #WSTAT_LOCKED_B,w_state+1(a3)      ; unlocked

 moveq    #0,d0                    ; arrow
 jsr      graf_mouse

 jsr      mctrl_0
 bra      wwc_ende

* ALTER SIZER

wwc_old_sizer:
 move.l   w_work(a3),(a4)
 move.l   w_work+4(a3),4(a4)

 lea      -8(a6),a0
 move.l   a4,a1
 move.w   (a0)+,d0                 ; x von CURRXYWH
 sub.w    d0,(a1)+                 ; von work_x abziehen
 move.w   (a0)+,d0                 ; y von CURRXYWH
 addq.w   #1,d0
 sub.w    d0,(a1)+                 ; von work_y abziehen
 bne.b    wwcs_ok                  ; ist ungleich 0, ok
 addq.w   #1,g_y(a4)
 subq.w   #1,g_h(a4)               ; Korrektur
wwcs_ok:
 move.w   (a0)+,d0                 ; w von CURRXYWH
 subq.w   #1,d0
 sub.w    d0,(a1)+                 ; von work_w abziehen
 move.w   (a0),d0                  ; h von CURRXYWH
 subq.w   #2,d0
 sub.w    d0,(a1)                  ; von work_h abziehen

 move.w   g_y(a4),d0
 add.w    g_h(a4),d0
 bne.b    wwcs_lok1
 subq.w   #1,g_h(a4)               ; untere Linien waren uebereinander!
wwcs_lok1:
 move.w   g_x(a4),d0
 add.w    g_w(a4),d0
 bne.b    wwcs_lok2
 subq.w   #1,g_w(a4)               ; rechte Linien waren uebereinander!
wwcs_lok2:

 move.l   w_min_g+g_w(a3),-(sp)
 move.l   a4,-(sp)                 ; Offsets fuer inneres Rechteck
 pea      -8(a6)                   ; aeusseres Anfangsrechteck
 move.l   (a5),-(sp)               ; x/y
 bsr      size_wind
 adda.w   #16,sp
 moveq    #WM_SIZED,d5
 bra      wwc_endsw

**
* case  9 (y - Scrollfeld)
**

wwc_vscroll:
 btst     #VSLIDE_B,d1
 beq      wwc_endsw
 bra.b    wwc_scroll

**
* case 13 (x - Scrollfeld)
**

wwc_hscroll:
 btst     #HSLIDE_B,d1
 beq      wwc_endsw
wwc_scroll:
 move.w   d6,d0
 addq.w   #1,d0
 lea      w_tree(a3),a0
 bsr      _objc_offset
 move.w   d0,(a4)
 move.w   d1,g_y(a4)

 cmp.w    #13,d6
 bne.b    wwc_srolly
 move.w   (a5),d0                  ; x
 cmp.w    g_x(a4),d0
 blt.b    wwc_scoll2
 addq.w   #1,d6
wwc_scoll2:
 bra.b    _wwc_arrow
wwc_srolly:
 move.w   2(a5),d0                 ; y
 cmp.w    g_y(a4),d0
 blt.b    _wwc_arrow
 addq.w   #1,d6
 bra.b    _wwc_arrow

**
* case 7  (Scrollpfeile)
* case 8
* case 11
* case 12
**

wwc_arrow:
 lea      w_tree(a3),a0
 move.w   d6,d0
 mulu     #24,d0
 move.w   ob_head(a0,d0.l),d1      ; Kinder?
 suba.l   a1,a1
 beq.b    _wwc_ar_noc              ; nein
 move.w   ob_flags(a0,d0.l),d2
 andi.w   #FL3DACT,d2
 cmpi.w   #FL3DACT,d2
 bne.b    _wwc_ar_noc              ; kein ACTIVATOR
 mulu     #24,d1
 lea      ob_x(a0,d1.l),a1
 addq.w   #1,g_x(a1)
 addq.w   #1,g_y(a1)               ; Kind versetzen
_wwc_ar_noc:
 move.l   a1,-(sp)
 lea      ob_state+1(a0,d0.l),a0
 bset     #SELECTED_B,(a0)         ; SELECTED
 move.l   a0,-(sp)                 ; a0 retten

 move.w   d7,d2                    ; whdl
 lea      desk_g,a1                ; GRECT
 moveq    #MAXDEPTH,d1             ; depth
 move.w   d6,d0                    ; startob
 lea      w_tree(a3),a0            ; OBJECT *
 bsr      objc_wdraw

 move.l   (sp)+,a0
 bclr     #SELECTED_B,(a0)

 move.l   (sp)+,d0
 beq.b    _wwc_ar_noc2             ; nein
 move.l   d0,a1
 subq.w   #1,g_x(a1)
 subq.w   #1,g_y(a1)               ; Kind zuruecksetzen
_wwc_ar_noc2:

_wwc_arrow:
 moveq    #WM_ARROWED,d5
 lea      wwc_obtab(pc),a0
 move.b   -7(a0,d6.w),d0
 ext.w    d0
 move.w   d0,-8+g_x(a6)
 move.l   mouse_app,a4             ; retten
 move.l   applx+4,a0
 jsr      set_mouse_app            ; umsetzen auf SCRENMGR
 jsr      update_0                 ; Applikation wieder freigeben
 moveq    #1,d4
wwc_arloop:
 lea      -8(a6),a0                ; 4 Datenworte
 move.w   d7,d2                    ; erstes Datenwort: whdl
 movea.l  w_owner(a3),a2
 move.w   ap_id(a2),d1             ; dst_apid
 move.w   d5,d0                    ; Nachrichtentyp
 jsr      send_msg
wwc_arnomsg:
 jsr      appl_yield
 tst.w    d4
 beq.b    wwc_nodelay
 clr.w    d4

 moveq    #20,d3
wwc_apy_loop:
 btst     #0,gr_mkmstate+1
 beq.b    wwc_endarloop
 jsr      appl_yield
 dbra     d3,wwc_apy_loop

 moveq    #0,d0
 move.w   dclick_clicks,d0         ; Verzoegerung: Ein Doppelklick
 jsr      wait_n_clicks            ; Zeitschleife
* wiederhole, solange linke Maustaste gedrueckt
wwc_nodelay:
 btst     #0,gr_mkmstate+1
 bne      wwc_arloop
* Die Scrollbalken bzw. der Hintergrund werden nicht neu gezeichnet
wwc_endarloop:
 cmpi.w   #9,d6
 beq.b    wwc_noardraw
 cmpi.w   #10,d6
 beq.b    wwc_noardraw
 cmpi.w   #13,d6
 beq.b    wwc_noardraw
 cmpi.w   #14,d6
 beq.b    wwc_noardraw
* Wenn sich das Fenster geaendert hat, nicht neu zeichnen
;cmp.w    topwhdl,d7               ; Fenster noch oberstes ?
;bne.b    wwc_noardraw             ; nein, Scrollpfeil nicht neu

 move.w   d7,d2                    ; whdl
 lea      desk_g,a1                ; GRECT
 moveq    #MAXDEPTH,d1             ; depth
 move.w   d6,d0                    ; startob
 lea      w_tree(a3),a0            ; tree
 bsr      objc_wdraw

wwc_noardraw:
 move.l   a4,a0
 jsr      set_mouse_app            ; zuruecksetzen
 jsr      update_1                 ; Applikation wieder sperren
 bra      wwc_ende

**
* case  10 (VSLID)
**

wwc_vslid:
 moveq    #WM_VSLID,d5
 moveq    #1,d4                    ; vertikal
 bra.b    wwc_slid

**
* case 14 (HSLID)
**

wwc_hslid:
 moveq    #WM_HSLID,d5
 moveq    #0,d4                    ; horizontal
wwc_slid:
;bra      wwc_old_slider

 btst     #5,look_flags+1          ; Online-Scrolling per Default aus ?
 beq.b    wwc_5_off
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne.b    wwc_new_slider
 btst     #2,7(a5)                 ; K_CTRL ?
 bne.b    wwc_new_slider
 bra.b    wwc_old_slider
wwc_5_off:
 btst     #1,5(a5)                 ; rechte Mtaste gedrueckt ?
 bne.b    wwc_old_slider
 btst     #2,7(a5)                 ; K_CTRL ?
 bne.b    wwc_old_slider

* NEUE SLIDER

wwc_new_slider:
 bset     #WSTAT_LOCKED_B,w_state+1(a3)      ; locked !!!

 moveq    #4,d0                    ; flat hand
 jsr      graf_mouse

 move.w   d5,-(sp)                 ; msgcode
 move.l   w_owner(a3),a2
 move.w   ap_id(a2),-(sp)          ; dst_apid
 move.w   d7,-(sp)                 ; whdl
 pea      -8(a6)                   ; data
 pea      windslid_callback(pc)
 move.l   sp,-(sp)                 ; callback_data
 move.w   d4,d2
 move.w   d6,d1
 move.w   d6,d0
 subq.w   #1,d0
 lea      w_tree(a3),a0
 jsr      gr_xslidbx
 adda.w   #18,sp

 bclr     #WSTAT_LOCKED_B,w_state+1(a3)      ; unlocked

 moveq    #0,d0                    ; arrow
 jsr      graf_mouse

 bra      wwc_ende

* ALTE SLIDER

wwc_old_slider:
 move.w   d4,d2
 move.w   d6,d1
 move.w   d6,d0
 subq.w   #1,d0
 lea      w_tree(a3),a0
 jsr      graf_slidebox
 move.w   d0,-8(a6)
 bra.b    wwc_endsw


* switch (d6 (== Fensterobjekt- Nummer))

wwc_switch:
 cmp.w    #15,d0
 bhi.b    wwc_endsw
 move.w   w_kind(a3),d1
 add.w    d0,d0
 move.w   wwc_jmptab(pc,d0.w),d0
 jmp      wwc_jmptab(pc,d0.w)

wwc_jmptab:
 DC.W     wwc_unicon-wwc_jmptab              ;  0
 DC.W     wwc_close-wwc_jmptab               ;  1 = CLOSER
 DC.W     wwc_name-wwc_jmptab                ;  2 = NAME
 DC.W     wwc_drop-wwc_jmptab                ;  3 = DROP
 DC.W     wwc_full-wwc_jmptab                ;  4 = FULLER
 DC.W     wwc_info-wwc_jmptab                ;  5 = INFO
 DC.W     wwc_size-wwc_jmptab                ;  6 = SIZER
 DC.W     wwc_arrow-wwc_jmptab               ;  7 = Scrollpfeil
 DC.W     wwc_arrow-wwc_jmptab               ;  8 = Scrollpfeil
 DC.W     wwc_vscroll-wwc_jmptab             ;  9 = VSCROLL
 DC.W     wwc_vslid-wwc_jmptab               ; 10 = VSLID
 DC.W     wwc_arrow-wwc_jmptab               ; 11 = Scrollpfeil
 DC.W     wwc_arrow-wwc_jmptab               ; 12 = Scrollpfeil
 DC.W     wwc_hscroll-wwc_jmptab             ; 13 = HSCROLL
 DC.W     wwc_hslid-wwc_jmptab               ; 14 = HSLID
 DC.W     wwc_icon-wwc_jmptab                ; 15 = ICONIFIER

wwc_endsw:
 move.w   #1,-(sp)                 ; auf Loslassen des Mausknopfs warten
wwc_hot:
 lea      -8(a6),a0                ; Daten
 move.w   d7,d2                    ; whdl
 move.l   w_owner(a3),a2
 move.w   ap_id(a2),d1             ; dst_apid
 move.w   d5,d0                    ; Message- Code
 jsr      send_msg
 tst.w    (sp)+
 beq.b    wwc_ende
 jsr      wait_but_released
wwc_ende:
 movem.l  (sp)+,a3/a4/a5/d7/d6/d5/d4/d3
 unlk     a6
 rts

wwc_obtab:
 DC.B     2    ; Objekt  7 (Scrollpfeil hoch)  : WA_UPLINE
 DC.B     3    ; Objekt  8 (Scrollpfeil runter): WA_DNLINE
 DC.B     0    ; Objekt  9 (graue Box)         : WA_UPPAGE
 DC.B     1    ; Objekt 10 (Scrollbalken vert.): WA_DNPAGE
 DC.B     6    ; Objekt 11 (Scrollpfeil links) : WA_LFLINE
 DC.B     7    ; Objekt 12 (Scrollpfeil rechts): WA_RTLINE
 DC.B     4    ; Objekt 13 (graue Box)         : WA_LFPAGE
 DC.B     5    ; Objekt 14 (Scrollbalken hor.) : WA_RTPAGE

     EVEN


**********************************************************************
*
* size_wind(int mx, int my, GRECT *outg, GRECT *ing,
*           int minw, int minh)
*
*   8(a6) <mx>      Mausposition bei Event
*  $a(a6) <my>      Mausposition bei Event
*  $c(a6) <outg>    aeusseres Anfangs- Rechteck, Rueckgabe des Endrechtecks
* $10(a6) <ing>     Offsets fuer inneres Rechteck
* $14(a6) <minw>    minimale Breite fuer aeusseres Rechteck
* $16(a6) <minh>    minimale Hoehe   fuer aeusseres Rechteck
*
* -8(a6)            aeusseres GRECT
*

size_wind:
 link     a6,#-12
 movem.l  a3/a5/d6/d7,-(sp)

 jsr      mctrl_1                  ; Bildschirm sperren

 jsr      set_xor_black            ; Linienfarbe schwarz

 move.l   8(a6),-12(a6)            ; jew. aktuelle Mausposition
 move.l   $10(a6),a4               ; inneres Rechteck
 moveq    #1,d7                    ; immer 2 Rechtecke zeichnen
 move.l   $c(a6),a3
 lea      -8(a6),a5
 move.l   (a3),(a5)                ; x,y kopieren
 moveq    #-1,d0
 move.l   d0,g_w(a5)               ; w,h = -1
 bra.b    size_bgn
size_weiter:
; jsr     appl_yield
 move.l   gr_mkmx,-12(a6)          ; aktuelle Mausposition
size_bgn:
 move.w   gr_mkmx,d0               ; aktuelle Mausposition
 sub.w    8(a6),d0                 ; - alte Mausposition
 add.w    g_w(a3),d0               ; auf Breite addieren
 cmp.w    $14(a6),d0               ; kleiner als minimale Breite ?
 bge.b    w_ok
 move.w   $14(a6),d0
w_ok:
 move.w   d0,d6
 swap     d6                       ; neue Breite ins Hiword
 move.w   gr_mkmy,d0               ; aktuelle Mausposition
 sub.w    $a(a6),d0                ; - alte Mausposition
 add.w    g_h(a3),d0               ; auf Hoehe addieren
 cmp.w    $16(a6),d0               ; kleiner als minimale Hoehe ?
 bge.b    h_ok
 move.w   $16(a6),d0
h_ok:
 move.w   d0,d6                    ; neue Hoehe ins Loword
 cmp.l    g_w(a5),d6               ; haben sich Breite oder Hoehe geaendert ?
 beq.b    size_nochange

 addq.l   #1,g_w(a5)               ; war vorher -1 ?
 beq.b    size_noclr               ; ja, nichts zu loeschen
 subq.l   #1,g_w(a5)
 jsr      _drawgrect               ; altes Rechteck loeschen
size_noclr:
 move.l   d6,g_w(a5)               ; neue Breite und Hoehe
 jsr      _drawgrect               ; neues Rechteck malen (a5,a4,d7)

size_nochange:
 moveq    #1,d0
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 move.l   -12(a6),-(sp)       ; x/y
 move.w   d0,-(sp)            ; warte auf Verlassen
 move.l   sp,a0
 bsr      evnt_rel_mm         ; warte auf Loslassen der Taste oder Mausbewegung
 adda.w   #10,sp
 beq.b    size_weiter              ; Maustaste noch gedrueckt, weiter

 jsr      _drawgrect               ; Rechteck loeschen (a5,a4,d7)
 move.w   g_w(a5),g_w(a3)          ; *lw zurueckgeben
 move.w   g_h(a5),g_h(a3)          ; *lh zurueckgeben
 jsr      mctrl_0
 movem.l  (sp)+,a5/a3/d7/d6
 unlk     a6
 rts


**********************************************************************
*
* a0/d0 = WGRECT *alloc_wgrect( void )
*
* aendert nur d0/a0
*

alloc_wgrect:
 move.l   wg_freelist,d0
 beq.b    fatal_err_2
 move.l   d0,a0
 move.l   (a0),wg_freelist
 rts
fatal_err_2:
 jmp      fatal_w1

__cwo:
 move.w   g_y(a5),d0
 move.w   4+g_y(a1),d1
 jsr      max
 move.w   d0,(a0)+                 ; maximales y

 move.w   d2,(a0)+                 ; w eintragen

 move.w   g_y(a5),d0
 add.w    g_h(a5),d0               ; unterer Rand des Cutters
 move.w   4+g_y(a1),d1
 add.w    4+g_h(a1),d1             ; unterer Rand des wg
 jsr      min
 sub.w    -4(a0),d0                ; y abziehen
 move.w   d0,(a0)                  ; Hoehe
 rts


**********************************************************************
*
* WGRECT *calc_wgrect_overlaps(a0 = GRECT *cutter,
*                              a1 = WGRECT *wg,
*                              a2 = WGRECT *prev_wg)
*
* zerschneidet <wg>, das (womoeglich) von <cutter> ueberdeckt wird,
* in mehrere WGRECTS, diese werden in die Liste eingehaengt.
* Wenn neue WGRECTs erstellt wurden, gib Zeiger auf deren letzten
* zurueck, der damit neuer Vorgaenger von <wg> geworden ist;
* andernfalls gib NULL zurueck.
*

calc_wgrect_overlaps:
 move.l   a5,-(sp)
 movea.l  a0,a5                    ; a5 = cutter

 move.w   4+g_x(a1),d0
 add.w    4+g_w(a1),d0
 cmp.w    g_x(a5),d0
 ble      cwgo_ret0                ; <wg> liegt vollst. links von <cutter>
 move.w   g_x(a5),d0
 add.w    g_w(a5),d0
 cmp.w    4+g_x(a1),d0
 ble      cwgo_ret0                ; <cutter> liegt vollst. links von <wg>
 move.w   4+g_y(a1),d0
 add.w    4+g_h(a1),d0
 cmp.w    g_y(a5),d0
 ble      cwgo_ret0                ; <wg> liegt vollst. ueber <cutter>
 move.w   g_y(a5),d0
 add.w    g_h(a5),d0
 cmp.w    4+g_y(a1),d0
 ble      cwgo_ret0                ; <cutter> liegt vollst. ueber <wg>

*
* Der obere Rand wird berechnet
*

 move.w   g_y(a5),d2
 sub.w    4+g_y(a1),d2
 ble.b    cwo_n_oben               ; der obere Rand schneidet nicht

 bsr      alloc_wgrect             ; a0 = neues WGRECT, aendert nur d0/a0
 move.l   a0,(a2)                  ; neues WGRECT an prev_wg anhaengen
 movea.l  a0,a2                    ; und wird neues prev_wg
 move.l   a1,(a0)+                 ; wg als Nachfolger eintragen
 move.l   4+g_x(a1),(a0)+          ; x,y uebernehmen
 move.w   4+g_w(a1),(a0)+          ; w uebernehmen
 move.w   d2,(a0)
cwo_n_oben:

*
* Der linke Rand wird berechnet
*

 move.w   g_x(a5),d2
 sub.w    4+g_x(a1),d2
 ble.b    cwo_n_links              ; der linke Rand schneidet nicht

 bsr      alloc_wgrect             ; a0 = neues WGRECT, aendert nur d0/a0
 move.l   a0,(a2)                  ; neues WGRECT an prev_wg anhaengen
 movea.l  a0,a2                    ; und wird neues prev_wg
 move.l   a1,(a0)+                 ; wg als Nachfolger eintragen
 move.w   4+g_x(a1),(a0)+          ; x uebernehmen
 bsr      __cwo                    ; y/w/h berechnen
cwo_n_links:

*
* Der rechte Rand wird berechnet
*

 move.w   4+g_x(a1),d2
 add.w    4+g_w(a1),d2
 sub.w    g_x(a5),d2
 sub.w    g_w(a5),d2
 ble.b    cwo_n_rechts             ; der rechte Rand schneidet nicht

 bsr      alloc_wgrect             ; a0 = neues WGRECT, aendert nur d0/a0
 move.l   a0,(a2)                  ; neues WGRECT an prev_wg anhaengen
 movea.l  a0,a2                    ; und wird neues prev_wg
 move.l   a1,(a0)+                 ; wg als Nachfolger eintragen
 move.w   g_x(a5),d0
 add.w    g_w(a5),d0
 move.w   d0,(a0)+                 ; x = c.x+c.w
 bsr      __cwo                    ; y/w/h berechnen
cwo_n_rechts:

*
* Der untere Rand wird berechnet
*

 move.w   4+g_y(a1),d2
 add.w    4+g_h(a1),d2
 sub.w    g_y(a5),d2
 sub.w    g_h(a5),d2
 ble.b    cwo_n_unten              ; der untere Rand schneidet nicht

 bsr      alloc_wgrect             ; a0 = neues WGRECT, aendert nur d0/a0
 move.l   a0,(a2)                  ; neues WGRECT an prev_wg anhaengen
 movea.l  a0,a2                    ; und wird neues prev_wg
 move.l   a1,(a0)+                 ; wg als Nachfolger eintragen
 move.w   4+g_x(a1),(a0)+          ; x uebernehmen
 move.w   g_y(a5),d0
 add.w    g_h(a5),d0
 move.w   d0,(a0)+                 ; y = c.y+c.h
 move.w   4+g_w(a1),(a0)+          ; w uebernehmen
 move.w   d2,(a0)
cwo_n_unten:

 move.l   (a1),(a2)                ; unser WGRECT aushaengen
 move.l   wg_freelist,(a1)
 move.l   a1,wg_freelist       ; und freigeben
 move.l   a2,d0
cwgo_ret:
 move.l   (sp)+,a5
 rts
cwgo_ret0:
 moveq    #0,d0
 bra.b    cwgo_ret



**********************************************************************
*
* void calc_wind_overlaps( d0 = int whdl, a0 = GRECT *cutter )
*
* Wird von set_wind_wgrect bei der Reorganisation
* der Fensterrechtecklisten aufgerufen, und zwar fuer alle Fenster,
* die UNTER dem Fenster von set_wind_wgrect liegen.
* cutter ist der Umriss des Fensters, das set_wind_wgrect bearbeitet.
*
* Aufrufschema:
*  Die Fenster seien geordnet: oberstes=3,2,1,0=unterstes
*
*  set_wind_wgrect(0)
*  set_wind_wgrect(1) -> calc_wind_overlaps(0)
*  set_wind_wgrect(2) -> calc_wind_overlaps(0)
*                        calc_wind_overlaps(1)
*  set_wind_wgrect(3) -> calc_wind_overlaps(0)
*                        calc_wind_overlaps(1)
*                        calc_wind_overlaps(2)
*
* Wenn unser Fenster also in calc_wind_overlaps bearbeitet wird,
* ist es bereits von set_wind_wgrect bearbeitet worden!
* Insbesondere ist die Rechteckliste bereits initialisiert.
*

calc_wind_overlaps:
 movem.l  a3/a4/a5/a6,-(sp)
 move.l   a0,a6                    ; cutter
;move.w   d0,d0
 bsr      whdl_to_wnd
 beq.b    cwio_ende                ; ???
 movea.l  a0,a5

* Durchlaufe unsere Rechteckliste bis zum bitteren Ende

 lea      w_wg(a5),a3              ; Zeiger auf unsere Rechteckliste
 bra.b    cwio_next
cwio_loop:
 move.l   a3,a2                    ; Vorgaenger in der Liste
 move.l   a4,a1                    ; bearbeitetes WGRECT
 move.l   a6,a0                    ; hiervon wird <a2> "zerschnitten"
 bsr      calc_wgrect_overlaps
 movea.l  d0,a3
 move.l   a3,d0                    ; neuer Vorgaenger, d.h. neue WGRECTs
                                   ;  eingehaengt ?
 beq.b    cwio_weiter              ; nein, normal weiter
 bset     #WSTAT_COVERED_B,w_state+1(a5)     ; "ueberdeckt"
 bra.b    cwio_next
cwio_weiter:
 movea.l  a4,a3
cwio_next:
 movea.l  (a3),a4                  ; naechstes WGRECT
 move.l   a4,d0                    ; Listenende ?
 bne.b    cwio_loop                ; nein, weiter
cwio_ende:
 movem.l  (sp)+,a6/a5/a4/a3
 rts


**********************************************************************
*
* void set_wind_wgrect(d0 = int whdl, a0 = wlist[])
*
* Wird von walk_obj_tree() bei der Reorganisation der Fenster-
* rechtecklisten aufgerufen
*
* Der Baum der Fenster hat die Fenster als Kinder von Fenster #0,
* dabei ist das erste Kind das unterste, das letzte das oberste
* Fenster.
*
* Die Rechteckliste ist bereits von build_new_wgs freigegeben.
* a0[] enthaelt die tiefer liegenden Fenster EINSCHLIESSLICH d0
*

set_wind_wgrect:
 movem.l  a4/a5,-(sp)
 move.w   d0,d1
 move.l   a0,a4
 bsr      whdl_to_wnd              ; aendert nur d0/a0
 beq      swg_ende                 ; ???
 movea.l  a0,a2

* Initialisiere tmp_grect mit unserem Fenster und durchlaufe alle
* tieferliegenden (von uns ueberdeckten) Fenster

 lea      w_curr(a2),a0
 addq.l   #g_w,a0
 tst.w    (a0)+
 beq.b    swg_ende                 ; Rechteck ist leer, Ende
 tst.w    (a0)+
 beq.b    swg_ende                 ; Rechteck ist leer, Ende

* Initialisiere unsere Rechteckliste mit dem Gesamt- Fensterumriss,
* also mit einem Rechteck

 bsr      alloc_wgrect             ; aendert nur d0/a0
 move.l   a0,w_wg(a2)              ; in unsere Liste
 clr.l    (a0)+                    ; kein Nachfolger
 move.l   a0,a5                    ; GRECT merken
 move.l   w_overall(a2),(a0)+      ; x,y kopieren
 move.l   w_overall+g_w(a2),(a0)   ; w,h kopieren
 tst.w    d1                       ; Handle 0 ?
 beq.b    swg_ende                 ; Window #0, fertig

 addq.l   #2,a4                    ; Liste der tiefer liegenden Fenster
                                   ; uns ueberspringen
swg_calcloop:
 move.l   a5,a0                    ; cut- Rechteck
 move.w   (a4),d0                  ; whdl
 bmi.b    swg_inv                  ; Fenster ungueltig (eingefroren)
 bsr.s    calc_wind_overlaps
swg_inv:
 tst.w    (a4)+                    ; war das Fenster 0 ?
 bne.b    swg_calcloop             ; nein, weiter

swg_ende:
 movem.l  (sp)+,a4/a5
 rts


**********************************************************************
*
* a0 = WINDOW *wgfree( a0 = WINDOW *w )
*
* Gibt die Rechteckliste fuer das Fenster frei.
*

wgfree:
 move.l   w_wg(a0),d0              ; d0 = erstes Rechteck
 beq.b    wgf_ende                 ; Liste ist leer
 movea.l  d0,a1
 bra.b    wgf_nxtwg
wgf_wgloop:
 movea.l  (a1),a1
wgf_nxtwg:
 tst.l    (a1)
 bne.b    wgf_wgloop
 move.l   wg_freelist,(a1)         ; haenge die freelist hinter unsere Liste
 move.l   d0,wg_freelist           ; und unsere in die freelist
 clr.l    w_wg(a0)                 ; leere Rechteckliste
wgf_ende:
 rts


**********************************************************************
*
* void build_new_wgs( d0 = int newtop )
*
* Baut neue Rechtecklisten fuer die Fenster und schaltet ggf. die
* Applikation des obersten Fensters um.
*

build_new_wgs:
 move.l   a5,-(sp)
 move.w   d0,-(sp)
 lea      whdlx,a5

*
* Fensterliste so trimmen, dass nach Moeglichkeit kein ungueltiges
* Fenster oben liegt
*

 move.w   (a5),d0                  ; oberstes Fenster
 bge      bnw_wgfreeloop           ; ist gueltig!
bnw_trmloop:
 addq.l   #2,a5
 move.w   (a5),d2
 bmi.b    bnw_trmloop              ; immer noch ungueltig
 beq.b    bnw_ok1                  ; Listenende
 lea      whdlx,a1                 ; src
 lea      whdlx+2,a0               ; dst
 move.l   a5,d0
 sub.l    a1,d0
 jsr      vmemcpy                   ; ungueltige nach hinten
 move.w   d2,whdlx                 ; gueltiges nach vorn

*
* Rechtecklisten aller Fenster erneuern
*

* Zunaechst alle Rechtecklisten freigeben

bnw_ok1:
 lea      whdlx,a5
bnw_wgfreeloop:
 move.w   (a5),d0                  ; whdl
 bclr     #15,d0                   ; auch ungueltige Handles behandeln!
 bsr      whdl_to_wnd
 beq.b    bnw_nextwin
;move.l   a0,a0
 bsr.s    wgfree
bnw_nextwin:
 bclr     #WSTAT_COVERED_B,w_state+1(a0)     ; "nicht ueberdeckt"

 tst.w    (a5)+                    ; war dies das Fenster 0 ?
 bne.b    bnw_wgfreeloop           ; nein, weiter

* Dann, beginnend beim untersten Fenster (#0), die Fensterliste
* durchlaufen

bnw_swgloop:
 move.w   -(a5),d0
 bmi.b    bnw_sw_inv               ; Fenster ungueltig
 move.l   a5,a0                    ; Fensterliste (selbst und alle tieferen)
 bsr      set_wind_wgrect
bnw_sw_inv:
 cmpa.l   #whdlx,a5
 bhi.b    bnw_swgloop
 tst.w    (sp)+
 beq.b    b_ende2
 bsr.s    set_new_top
b_ende2:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* void win_inactive( d0 = WORD whdl )
*
* Setzt ein Fenster als inaktiv.
*

win_inactive:
 tst.w    d0
 ble.b    _wun_ende
 bsr      whdl_to_wnd
 beq.b    _wun_ende
 bclr     #WSTAT_ACTIVE_B,w_state+1(a0)      ; ACTIVE loeschen
 move.l   wbm_sattr,a1
 moveq    #WSTAT_ACTIVE,d0
;move.l   a0,a0
 jmp      (a1)
_wun_ende:
 rts


**********************************************************************
*
* void set_new_top( void )
*
* Setzt ein neues Fenster als aktiv.
*

set_new_top:
 move.l   d6,-(sp)
 move.w   topwhdl,d6               ;    altes oberstes Fenster
 move.w   whdlx,d0                 ;    neues oberstes Fenster
 bge.b    snt_new_valid            ;     ist gueltig
 moveq    #0,d0                    ;     ist ungueltig => Hintergrund nehmen
snt_new_valid:
 cmp.w    d6,d0                    ; == altes oberstes Fenster ?
 bne.b    snt_changed              ; nein
 jsr      set_topwind_app          ; aktive Applikation umschalten
 bra.b    snt_ende2
snt_changed:
* oberstes Fenster ist jetzt ein anderes
 move.w   d0,topwhdl

 move.w   d6,d0
 bsr.s    win_inactive

 move.w   topwhdl,d0
 ble.b    snt_no_new_top
 bsr      whdl_to_wnd
 beq.b    snt_no_new_top
 bset     #WSTAT_ACTIVE_B,w_state+1(a0)      ; ACTIVE setzen
 move.l   wbm_sattr,a1
 moveq    #WSTAT_ACTIVE,d0
;move.l   a0,a0
 jsr      (a1)
snt_no_new_top:
snt_ende:
 jsr      set_topwind_app          ; aktive Applikation umschalten
 move.w   d6,d0
 ble.b    snt_ende3                ; kein altes oberstes Fenster
;move.w   d0,d0
 bsr      wind_untopped
 move.w   d6,d0
 bsr      wind_draw_whole          ; altes oberstes Fenster neu zeichnen
snt_ende3:
 move.w   topwhdl,d0
 ble.b    snt_ende2                ; kein neues oberstes Fenster
;move.w   d0,d0                    ; neues oberstes Fenster neu zeichnen
 bsr      wind_draw_whole
 move.w   topwhdl,d0
 bsr      wind_ontop               ; MultiTOS
snt_ende2:
 move.l   (sp)+,d6
 rts


**********************************************************************
*
* send_all_redraws(a0 = GRECT *g)
*
* alle Fenster werden im Ausschnitt <g> neu gezeichnet (sowohl Rand
* als auch Inneres)
*
* wird etwa von form_dial(FMD_FINISH, ...) aufgerufen
*

send_all_redraws:
 move.l   a0,a1                    ; <g>
 lea      whdlx,a0                 ; alle Window- Handles
 moveq    #-1,d1                   ; keine Anzahlbegrenzung
 moveq    #1,d0                    ; aktiven Rahmen malen
;bra      _do_redraw


**********************************************************************
*
* _do_redraw(a0 = int whdls[], a1 = GRECT *g, d0 = int flag, d1 = int num)
*
* alle Fenster, deren Handles in der Liste <whdls> liegen, werden
* nacheinander gezeichnet, maximal werden <num> Stueck gezeichnet.
* Die Liste ist ausserdem durch 0 abgeschlossen.
* Es wird nur der Ausschnitt <g> gezeichnet, der mit dem Bildschirm ge-
* schnitten wird.
* Fuer das oberste Fenster <topwhdl> wird NICHT der Rahmen gezeichnet,
* wenn nicht <flag> != 0 ist.
*

_do_redraw:
 tst.w    (a0)
 beq      nix_redraw               ; Liste ist leer
 tst.w    d1
 beq      nix_redraw               ; Liste ist leer
 movem.l  a4/a5/d5/d6/d7,-(sp)
 move.l   a0,a4
 move.l   a1,a5
 move.w   d0,d7
 move.w   d1,d5
* schneide <g> mit dem Bildschirmausschnitt
 move.l   a5,a1
 lea      desk_g,a0
 jsr      grects_intersect

* Maus abschalten
 jsr      mouse_off
* do-Schleife:
do_loop:
 subq.w   #1,d5
 bcs.b    end_loop                 ; Schluss
 move.w   (a4)+,d6                 ; naechstes Fenster
 beq.b    end_loop                 ; Schluss
 bmi.b    do_loop                  ; ungueltig
 tst.w    d7
 bne.b    doch_rahmen
 cmp.w    topwhdl,d6
 beq.b    kein_rahmen
doch_rahmen:
 move.l   a5,a0                    ; nur Ausschnitt
 moveq    #0,d1                    ; startob
 move.w   d6,d0
 bsr      wind_draw
kein_rahmen:
 move.l   a5,a0
 move.w   d6,d0
 bsr      send_redraw_message
 bra.b    do_loop
end_loop:
 jsr      mouse_on
 movem.l  (sp)+,a5/a4/d7/d6/d5
nix_redraw:
 rts


**********************************************************************
*
* void get_wind_hierar(d0 = int firstwhdl, a0 = int w[NWINDOWS])
*
* Liefert die Liste aller Fenster von oben (letztes Kind) nach unten
* (erstes Kind) ab <firstwhdl>.
* Die Liste beginnt also mit unserem Fenster und enthaelt alle darunter
* liegenden, sie wird durch 0 abgeschlossen
*

get_wind_hierar:
 lea      whdlx,a1
gwh_loop:
 cmp.w    (a1)+,d0
 bne.b    gwh_loop
 move.w   d0,(a0)+
 beq.b    gwh_ende
gwh_loop2:
 move.w   (a1)+,(a0)+
 bne.b    gwh_loop2
gwh_ende:
 rts


**********************************************************************
*
* PUREC WORD _wind_open(WORD whdl, GRECT *g)
*
* int _wind_open(d0 = int whdl, a0 = GRECT *g)
*
* Achtung: Jetzt Rueckgabewert 0 bei ungueltigem Handle
*

_wind_open:
 movem.l  a2/a4/a5/d7,-(sp)
 subq.l   #8,sp                    ; Platz fuer GRECT
 tst.w    d0
 beq      wop_err                  ; Fenster #0 nicht oeffnen!
 move.w   d0,d7                    ; d7 = whdl
 move.l   a0,a5                    ; a5 = g
 bsr      whdl_to_wnd
 beq      wop_err
 move.l   a0,a4                    ; a4 = WINDOW *
 bset     #WSTAT_OPENED_B,w_state+1(a4)
 bne      wop_err                  ; war schon geoeffnet

* Sonderfall g = {-1,-1,-1,-1}

 moveq    #-1,d0
 cmp.l    g_w(a5),d0               ; w/h = -1 uebergeben ?
 bne.b    wop_g                    ; nein, uebergebenes GRECT nehmen
 move.l   sp,a0
 bsr      find_icon_pos            ; ja, Default-Werte nehmen
 move.l   sp,a5

wop_g:
* Beginn des Bildschirmaufbaus
 jsr      update_1
* Verhindere, dass WM_ONTOP kommt
 bset     #WSTAT_QUIET_B,w_state+1(a4)
* setze d7 als oberstes Fenster
 moveq    #0,d1                    ; oberste Position
 move.w   d7,d0
 bsr      _wind_to_stackpos
* Groesse setzen:
 btst     #WSTAT_SHADED_B,w_state+1(a4)
 beq.b    wop_notsh
* Groesse setzen: shaded
 move.w   g_h(a5),w_oldheight(a4)  ; Hoehe fuer unge-shade-tes Fenster
 move.w   wbm_hshade,-(sp)         ; minimale Hoehe
 move.w   g_w(a5),-(sp)
 move.l   g_x(a5),-(sp)
 move.l   sp,a1
 move.l   a4,a0
 moveq    #1,d1                    ; neues oberstes
 move.w   d7,d0
 bsr      set_windxywh
 addq.l   #8,sp
 bra.b    wop_shunsh
* Groesse setzen: nicht shaded
wop_notsh:
 move.l   a5,a1
 move.l   a4,a0                    ; WINDOW *
 moveq    #1,d1                    ; neues oberstes
 move.w   d7,d0
 bsr      set_windxywh
* Groesse fuer PREVXYWH setzen
wop_shunsh:
 lea      w_prev(a4),a0
 move.l   (a5)+,(a0)+
 move.l   (a5),(a0)
* Menueleiste ggf. umschalten
 move.l   w_owner(a4),a0
 jsr      set_app
* Ermoegliche wieder WM_ONTOP
 bclr     #WSTAT_QUIET_B,w_state+1(a4)
* Ende des Bildschirmaufbaus
 jsr      update_0
 moveq    #1,d0                    ; kein Fehler
wop_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a5/a4/a2/d7
 rts
wop_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wop_ende


**********************************************************************
*
* void _wind_close(d0 = int whdl)
*
* Entfernt das Handle aus der Liste whdlx
*

_wind_close:
 lea      whdlx,a1
_wcl_loop:
 move.w   (a1)+,d1
 beq.b    fatal_err_3              ; Ende der Liste erreicht!
 cmp.w    d0,d1
 bne.b    _wcl_loop
 lea      -2(a1),a0                ; Ziel
 move.l   #whdlx+2*MAX_NWIND,d0
 sub.l    a1,d0
 jmp      vmemcpy                   ; Rest aufruecken
fatal_err_3:
 jmp      fatal_w2


**********************************************************************
*
* PUREC WORD wind_close( WORD whdl)
*
* int wind_close(d0 = int whdl)
*
* Achtung: Jetzt Rueckgabewert 0 bei ungueltigem Handle
*

SIZE      SET  -8
WTAB      SET  SIZE-2*MAX_NWIND

wind_close:
 link     a6,#WTAB
 movem.l  d7/a2/a4,-(sp)
 tst.w    d0
 beq      wcl_err                  ; Fenster #0 nicht schliessen!
 move.w   d0,d7                    ; d7 = whdl
 bsr      whdl_to_wnd
 beq      wcl_err
 move.l   a0,a4                    ; a4 = WINDOW *

 move.l   act_appl,a1
 cmpa.l   w_owner(a4),a1           ; gehoert uns ?
 bne      wcl_err                  ; nein, Fehler

 bclr     #WSTAT_OPENED_B,w_state+1(a4)
 beq      wcl_err                  ; war nicht geoeffnet

* testen, ob das Fenster ge-locked ist, d.h. ob gerade Echtzeit-
* Scrolling/Verschieben/Vergroessern durchgefuehrt wird.

 btst     #WSTAT_LOCKED_B,w_state+1(a4)      ; locked ?
 beq.b    wcl_not_locked           ; nein, weiter

 clr.w    -(sp)
 move.l   upd_blockage+bl_app,a0
 cmpa.l   act_appl,a0              ; blockieren wir?
 bne.b    wcl_wait_lock_loop       ; nein
 move.w   upd_blockage,(sp)        ; Update-Counter retten
 beq.b    wcl_wait_lock_loop       ; war Null
 move.w   #1,upd_blockage          ; auf 1 setzen, damit er gleich frei wird
 jsr      update_0                 ; Applikation wieder freigeben
wcl_wait_lock_loop:
 jsr      appl_yield               ; ge-locked. Wir warten...
 btst     #WSTAT_LOCKED_B,w_state+1(a4)      ; locked ?
 bne.b    wcl_wait_lock_loop       ; ja, immer noch
 tst.w    (sp)                     ; wir hatten wind_update?
 beq.b    wcl_no_1                 ; nein
 jsr      update_1                 ; Kontrolle wiederholen
 move.w   (sp),upd_blockage        ; Update-Counter zurueck
wcl_no_1:
 addq.l   #2,sp

wcl_not_locked:

* aktuelle Groesse nach -8(a6)[]

 move.l   w_overall(a4),SIZE(a6)
 move.l   w_overall+g_w(a4),SIZE+g_w(a6)     ; CURRXYWH+Schatten nach -8(a6)[]

* CURRXYWH und WORKXYWH auf Null setzen
* Bit fuer "shaded" loeschen

 clr.l    w_curr(a4)
 clr.l    w_curr+g_w(a4)
 clr.l    w_work(a4)
 clr.l    w_work+g_w(a4)
 bclr     #WSTAT_SHADED_B,w_state+1(a4)

 jsr      update_1                 ; Beginn des Bildschirmaufbaus

 lea      WTAB(a6),a0
 move.w   d7,d0
 bsr      get_wind_hierar          ; darunterliegende Fenster nach -24(a6)[]
 move.l   a4,a0
 bsr      wgfree                   ; Rechteckliste freigeben!
 move.w   d7,d0
 bsr      _wind_close              ; Fenster aus der Liste entfernen
 moveq    #0,d0                    ; oberstes Fenster nicht erneuern
 bsr      build_new_wgs            ; Rechtecklisten erneuern
* Wenn Fenster oberstes Fenster war, oberstes ungueltig machen
 cmp.w    topwhdl,d7
 bne.b    wcl_weiter               ; keine Umschaltung
 move.w   #-1,topwhdl
* Wenn naechstes Fenster unseres, in den Vordergrund bringen
 move.w   whdlx,d1                 ; d1 = neues oberstes Fenster
 ble      wcl_newtop               ; ungueltig
 move.w   d1,d0
 bsr      whdl_to_wnd              ; a0 = WINDOW *
 beq.b    wcl_notop                ; ???
 move.l   act_appl,a1
 cmpa.l   w_owner(a0),a1           ; gehoert uns ?
 bne      wcl_notop                ; nein, kein oberstes Fenster!
wcl_newtop:
 bsr      set_new_top              ; oberstes Fenster aktivieren
 bra.b    wcl_weiter
wcl_notop:
 move.l   a1,-(sp)
 jsr      set_topwind_app
 move.l   (sp),a0
 bsr      top_my_window            ; unser oberstes bekommt WM_TOPPED
 move.l   (sp)+,a0
 bne.b    wcl_weiter               ; ok, Nachricht wurde verschickt
 cmpa.l   menu_app,a0              ; sind wir menuebesitzend ?
 beq.b    wcl_weiter               ; ja, alle Fenster deaktiviert lassen
* Letztes Fenster einer nicht-menuebesitzenden APP wurde geschlossen
 jsr      gbest_wnd_app
 jsr      make_app_main
wcl_weiter:
* Hintergrund malen
 lea      SIZE(a6),a0
 bsr      wind0_draw
* Rest neumalen
 lea      SIZE(a6),a1
 lea      WTAB(a6),a0
 tst.w    (a0)+                    ; unser Fenster nicht malen
 beq.b    close_fehler
 moveq    #-1,d1                   ; keine Anzahlbegrenzung
 moveq    #0,d0                    ; aktiven Rahmen nicht malen
 bsr      _do_redraw
close_fehler:
* Ende des Bildschirmaufbaus
 jsr      update_0
 moveq    #1,d0                    ; OK
wcl_ende:
 movem.l  (sp)+,a4/a2/d7
 unlk     a6
 rts
wcl_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wcl_ende


**********************************************************************
*
* int wind_iconify( d0 = int whdl, a0 = WINDOW *w, a1 = GRECT *g )
*

wind_iconify:
 movem.l  d7/a4,-(sp)
 subq.l   #8,sp                    ; Platz fuer GRECT
 move.l   a0,a4                    ; a4 = WINDOW *
 move.w   d0,d7                    ; d7 = whdl
 btst     #WSTAT_ICONIFIED_B,w_state+1(a4)
 bne      wico_err                      ; ist schon ikonifiziert
 move.l   w_curr(a4),w_unic(a4)         ; alte Fensterposition...
 move.l   w_curr+4(a4),w_unic+4(a4)     ; ... merken

;move.l   a1,a1
 moveq    #-1,d0
 cmp.l    g_w(a1),d0               ; w/h = -1 uebergeben ?
 bne.b    wico_icg                 ; nein, uebergebenes GRECT nehmen
 move.l   sp,a0
 bsr      find_icon_pos            ; ja, Default-Werte nehmen
 move.l   sp,a1
wico_icg:
; erst hier ikonifizieren, damit <find_icon_pos> es nicht beruecksichtigt
 bset     #WSTAT_ICONIFIED_B,w_state+1(a4)

 btst     #WSTAT_SHADED_B,w_state+1(a4)
 beq.b    wico_no_uicsh                      ; nein, OK
 move.w   w_oldheight(a4),w_unic+g_h(a4)     ; ja, tats. Hoehe merken
 move.w   g_h(a1),w_oldheight(a4)            ; un-shade-Hoehe merken
 move.w   wbm_hshade,g_h(a1)                 ; Hoehe minimal
wico_no_uicsh:

 move.l   a1,-(sp)
 move.l   wbm_sattr,a1
 moveq    #WSTAT_ICONIFIED,d0
 move.l   a4,a0
 jsr      (a1)
 move.l   (sp)+,a1

;move.l   a1,a1                    ; g
 move.l   a4,a0                    ; WINDOW *
 moveq    #0,d1                    ; kein neues oberstes
 move.w   d7,d0
 bsr      set_windxywh

 lea      desk_g,a0
 move.w   d7,d0
 bsr      send_redraw_message
wico_ende:
 addq.l   #8,sp
 movem.l  (sp)+,a4/d7
 rts
wico_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wico_ende


**********************************************************************
*
* int wind_uniconify( d0 = int whdl, a0 = WINDOW *w, a1 = GRECT *g )
*

wind_uniconify:
 bclr     #WSTAT_ICONIFIED_B,w_state+1(a0)
 beq.b    wuico_err                ; war nicht ikonifiziert
 btst     #WSTAT_SHADED_B,w_state+1(a0)
 beq.b    wuico_no_uicsh           ; nein, OK
 move.w   g_h(a1),w_oldheight(a0)  ; un-shade-Hoehe merken
 move.w   wbm_hshade,g_h(a1)       ; Hoehe immer minimal!
wuico_no_uicsh:
 movem.l  d0/a0/a1,-(sp)
 move.l   wbm_sattr,a1
 moveq    #WSTAT_ICONIFIED,d0
;move.l   a0,a0
 jsr      (a1)
 movem.l  (sp)+,d0/a0/a1

 move.w   d0,-(sp)                 ; whdl retten

;lea      (a1),a1                  ; alte Groesse
;move.l   a0,a0                    ; WINDOW *
 moveq    #0,d1                    ; kein neues oberstes
;move.w   d0,d0
 bsr      set_windxywh

 lea      desk_g,a0
 move.w   (sp)+,d0                 ; whdl
 bsr      send_redraw_message
 moveq    #1,d0
wuico_ende:
 rts
wuico_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wuico_ende


**********************************************************************
*
* int wind_shade(d0 = int whdl, a0 = WINDOW *w)
*

wind_shade:
 movem.l  d7/a4,-(sp)
 move.w   d0,d7                    ; d7 = whdl
 move.l   a0,a4                    ; a4 = WINDOW *
 bset     #WSTAT_SHADED_B,w_state+1(a4)
 bne.b    wshd_err                 ; war schon gesetzt!

 move.l   wbm_sattr,a1
 moveq    #WSTAT_SHADED,d0
;move.l   a0,a0
 jsr      (a1)

 btst     #WSTAT_OPENED_B,w_state+1(a4)      ; geoeffnet?
 beq.b    wshd_ok                  ; nein, nur Bit setzen
;btst     #1,w_tattr(a4)           ; ICONIFIED?
;bne.b    wshd_err                 ; ja, nicht erlaubt!!!
 move.w   w_curr+g_h(a4),w_oldheight(a4)     ; alte Hoehe retten
 move.w   wbm_hshade,-(sp)         ; neue Hoehe: minimal
 move.w   w_curr+g_w(a4),-(sp)
 move.l   w_curr+g_x(a4),-(sp)     ; x/y/w unveraendert
 move.l   sp,a1
 move.l   a4,a0                    ; WINDOW *
 moveq    #0,d1                    ; kein neues oberstes
 move.w   d7,d0
 bsr      set_windxywh
 addq.l   #8,sp
wshd_ok:
 moveq    #1,d0                    ; kein Fehler
wshd_ende:
 movem.l  (sp)+,a4/d7
 rts
wshd_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wshd_ende


**********************************************************************
*
* int wind_unshade(d0 = int whdl, a0 = WINDOW *w)
*

wind_unshade:
 movem.l  d7/a4,-(sp)
 move.w   d0,d7                    ; d7 = whdl
 move.l   a0,a4                    ; a4 = WINDOW *
 bclr     #WSTAT_SHADED_B,w_state+1(a4)
 beq.b    wshu_err                 ; war schon geloescht

 move.l   wbm_sattr,a1
 moveq    #WSTAT_SHADED,d0
;move.l   a0,a0
 jsr      (a1)

 btst     #WSTAT_OPENED_B,w_state+1(a4)      ; geoeffnet?
 beq.b    wshu_ok                  ; nein, nur Bit loeschen
;btst     #1,w_tattr(a4)           ; ICONIFIED?
;bne.b    wshu_err                 ; ja, nicht erlaubt!!!
 move.w   w_oldheight(a4),-(sp)    ; neue Hoehe: gerettete Hoehe
 move.w   w_curr+g_w(a4),-(sp)
 move.l   w_curr+g_x(a4),-(sp)     ; x/y/w unveraendert
 move.l   sp,a1
 move.l   a4,a0                    ; WINDOW *
 moveq    #0,d1                    ; kein neues oberstes
 move.w   d7,d0
 bsr      set_windxywh
 addq.l   #8,sp
wshu_ok:
 moveq    #1,d0                    ; kein Fehler
wshu_ende:
 movem.l  (sp)+,a4/d7
 rts
wshu_err:
 moveq    #0,d0                    ; Fehler
 bra.b    wshd_ende


**********************************************************************
*
* void all_untop( void )
*
* Deaktiviert das oberste Fenster, falls vorhanden und nicht zur
* Menueleiste gehoerig
*

all_untop:
 move.w   topwhdl,d0               ; altes oberstes Fenster
 ble      alut_ende                ; ist sowieso ungueltig
 bsr      whdl_to_wnd
 beq.b    alut_ende                ; ???
 move.l   w_owner(a0),a0
 cmp.l    menu_app,a0
 beq      alut_ende                ; oberstes Fenster ist das des Menues
 jsr      update_1
 move.w   topwhdl,d0
 move.w   #-1,topwhdl              ; oberstes ungueltig machen
 move.w   d0,-(sp)
 bsr      win_inactive             ; oberstes inaktiv machen
 move.w   (sp),d0
 bsr      wind_untopped            ; WM_UNTOPPED verschicken
 move.w   (sp)+,d0
 bsr      wind_draw_whole          ; altes oberstes neu zeichnen
 jsr      set_topwind_app          ; aktive Applikation umschalten
 jmp      update_0
alut_ende:
 rts


**********************************************************************
*
* MI/PL d0/a0 = wind_stack_getpos(d0 = int whdl)
*
* Ermittelt die Position des Fensters <whdl> im Fensterstapel
* Rueckgabe -1, wenn das Fenster nicht geoeffnet ist.
*

wind_stack_getpos:
 moveq    #0,d1
 lea      whdlx,a0
wstpos_loop:
 cmp.w    (a0),d0
 beq.b    wstpos_found
 tst.w    (a0)+
 beq.b    wstpos_err               ; nicht gefunden
 addq.l   #1,d1
 bra.b    wstpos_loop
wstpos_err:
 moveq    #-1,d1
wstpos_found:
;move.l   a0,a0
 move.w   d1,d0
 rts


**********************************************************************
*
* void _wind_to_stackpos(d0 = int whdl, d1 = int pos)
*
* Setzt das Fenster <whdl> an Position <pos> in den Fensterstapel.
*

_wind_to_stackpos:
 move.w   d0,-(sp)                 ; whdl
 moveq #0,d0
 move.w   nwindows,d0
 subq.w   #1,d0
 sub.w    d1,d0
 add.w    d0,d0                    ; sizeof(int)
 lea      whdlx,a1
 add.w    d1,a1
 add.w    d1,a1                    ; von
 move.l   a1,-(sp)
 lea      2(a1),a0                 ; nach
 jsr      vmemcpy                   ; alle Handles einen nach hinten
; dann einfuegen
 move.l   (sp)+,a0
 move.w   (sp)+,(a0)
 rts


**********************************************************************
*
* void wind_rearrange(d0 = int whdl, d1 = int newpos, a0 = WINDOW *w)
*
* d0 und a0 beschreiben dasselbe Fenster, nur aus Geschwindigkeits-
* gruenden. d0 ist < nwindos und >= 0.
* d1 ist die neue Fensterposition im Fensterstapel. d1=0 entspricht
* WF_TOP, d1=-1 entspricht WF_BOTTOM.
*

SIZE      SET  -8
REDR_GR   SET  -16
OUR_WIN   SET  -24

wind_rearrange:
 link     a6,#OUR_WIN
 movem.l  d3/d4/d5/d6/d7/a5/a4/a3,-(sp)
 move.l   a0,a4                    ; a4 = WINDOW *
 move.w   d0,d7
 beq      end_rearr                ; Hintergrundfenster ist immer hinten!!!
 move.w   d1,d4                    ; d4 = neue Fensterstapelpos.
* Beginn des Bildschirmaufbaus
 jsr      update_1
* neue und aktuelle Position im Stack ermitteln (Gueltigkeit pruefen)
 lea      whdlx,a0
 moveq    #-1,d5                   ; unser Fenster noch nicht gefunden
 moveq    #-1,d0
wrear_loop1:
 addq.l   #1,d0
 cmp.w    (a0),d7
 bne.b    wrear_nof
 move.w   d0,d5                    ; gefunden!
wrear_nof:
 tst.w    (a0)+
 bne.b    wrear_loop1
 tst.w    d5                       ; d5 = momentane Fensterstapelpos.
 bmi      end_rearr                ; Fenster ungueltig
 cmp.w    d0,d4
 bcs.b    wrear_npos_ok
 move.w   d0,d4                    ; Maximum fuer neue Stapelpos. einsetzen
 subq.w   #1,d4
wrear_npos_ok:
 cmp.w    d5,d4                    ; Fensterstapelpos. aendern ?
 bne.b    wrear_newpos             ; ja
 tst.w    d4                       ; Fenster toppen?
 bne      end_rearr                ; nein, Ende

;
; Sonderfall: Fenster wurde getoppt, das schon oben, aber nicht
; aktiviert ist. Fenster aktivieren und ggf. Menueleiste umschalten.
;

 bsr      set_new_top              ; Fenster aktiveren, ggf. Menueleiste

 move.w   w_curr+g_y(a4),d0
 cmp.w    scr_h,d0
 bcc.b    wrear_no_unh1

 move.l   w_owner(a4),a0
 moveq    #0,d0
 jsr      appl_unhide              ; Alle Fenster sichtbar machen
wrear_no_unh1:
 bra      end_rearr                ; Ende
wrear_newpos:

;
; Fallunterscheidung:
;

 cmp.w    d5,d4
 bhi      rearr_down               ; runter stufen

*
* 1. Fall: Fenster wurde nach oben gesetzt, d4 < d5
*
;  Wenn unser Fenster in der Liste nach oben wandert, muessen alle
;  Fenster zwischen (neuer+1) und (alter Stapelposition)
;  vereinigt werden und fuer deren Vereinigungsrechteck ein Redraw unseres
;  Fensters veranlasst werden.
;

* Fenster ggf. un-hide
 move.w   w_curr+g_y(a4),d0
 cmp.w    scr_h,d0
 bcc.b    wrear_no_unh2
 move.l   w_owner(a4),a0
 moveq    #0,d0
 jsr      appl_unhide              ; Alle Fenster sichtbar machen
wrear_no_unh2:

* Fenster umsortieren
 move.w   d7,d0
 bsr      _wind_close              ; uns erstmal entfernen
 move.w   d4,d1                    ; neue Fensterstapelpos.
 move.w   d7,d0
 bsr      _wind_to_stackpos        ; unser Fenster wieder einfuegen

* GRECT fuer unser Fenster:
* 1. Fall: Fenster wurde getoppt
*          Dann wird der Fensterrahmen sowieso neu gezeichnet, d.h.
*          wir betrachten nur den Arbeitsbereich unseres Fensters.
* 2. Fall: Fenster wurde nicht getoppt
*          Wir das gesamte Fenster einschl. Schatten

 lea      OUR_WIN(a6),a0
 tst.w    d4
 beq.b    rearr_onlywork1

 move.l   w_overall(a4),(a0)
 move.l   w_overall+g_w(a4),g_w(a0)     ; CURRXYWH mit Schatten

 bra.b    rearr_getothers
rearr_onlywork1:
 move.l   w_work(a4),(a0)+         ; Arbeitsbereich
 move.l   w_work+g_w(a4),(a0)

* Vereinigungsrechteck aller vorher bedeckenden Fenster
rearr_getothers:
 moveq    #0,d6                    ; noch kein Schnitt
 lea      whdlx,a3
 move.w   d4,d3
 add.w    d3,a3
 add.w    d3,a3                    ; in Fensterliste
 lea      REDR_GR(a6),a5
rearr_loop3:
 addq.w   #1,d3                    ; beginne ab neuer Position+1
 addq.l   #2,a3
 cmp.w    d5,d3                    ; schon alte Position ?
 bhi.b    rearr_end_loop3          ; ja, Schleifenende
 move.w   (a3),d0
 bmi.b    rearr_loop3              ; versteckte Fenster
 beq.b    rearr_end_loop3          ; Listenende

 lea      SIZE(a6),a0
;move.w   d0,d0                    ; untersuchtes Fenster
 bsr      get_hwout                ; berechne CURRXYWH mit Schatten

 lea      SIZE(a6),a1
 lea      OUR_WIN(a6),a0           ; unser Fenster
 jsr      grects_intersect         ; Schnitt mit unserem Arbeitsbereich ?
 beq.b    rearr_loop3              ; nein, Schnitt ist leer

 move.l   a5,a1
 lea      SIZE(a6),a0
 tst.w    d6
 beq.b    rearr_copy_gr
 jsr      grects_union
 bra.b    rearr_loop3

rearr_copy_gr:
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)
 moveq    #1,d6                    ; merken, dass Schnitt nicht leer
 bra.b    rearr_loop3

rearr_end_loop3:

 tst.w    d4                       ; neue Position: ganz oben?
 seq      d0
 ext.w    d0                       ; ggf. aktives Fenster umschalten
 bsr      build_new_wgs            ; Rechteckliste, Fensterrahmen
 tst.w    d6                       ; Redraw noetig ?
 beq      end_rearr                ; nein

 tst.w    d4                       ; neue Position oben?
 beq.b    rearr_onlywork           ; ja, Fensterrand ist schon gezeichnet
 move.l   a5,a0
 move.w   d7,d0
 bsr      wind_redraw              ; Fensterrahmen + Message fuer Innenbereich
 bra      end_rearr
rearr_onlywork:
 move.l   a5,a0
 move.w   d7,d0
 bsr      send_rdrmsg              ; nur Message fuer Innenbereich
 bra      end_rearr

*
* 2. Fall: Fenster wurde nach unten gesetzt, d5 < d4
*
;  Wenn unser Fenster in der Liste nach unten wandert, bekommen alle
;  Fenster zwischen (alter Stapelposition) und (neuer Stapelposition-1)
;  einen Redraw mit der Groesse unseres Fensters.
;

rearr_down:
 lea      SIZE(a6),a0              ; Groesse nach -8(a6)[]
 move.w   d7,d0
 bsr      get_hwout                ; CURRXYWH mit Schatten

* Suche das naechste Fenster, das nach oben kommen soll.
* 1.9.96: Das darf kein ausgeblendetes sein

 tst.w    d5                       ; war vorher oberstes Fenster ?
 bne      rearr_notopbot           ; nein

 move.w   scr_h,d2                 ; y > scr_h heisst "ausgeblendet"
 lea      whdlx+2,a1               ; a1 auf das naechste Fenster
 moveq    #0,d1
rearr_whloop:
 addq.w   #1,d1
 cmp.w    d4,d1
 bhi      end_rearr                ; kein geeignetes Fenster ueber unserem
 move.w   (a1)+,d0                 ; unter unserem nur noch Fenster 0 ?
 bmi.b    rearr_whloop             ; gehoert eingefrorener APP
 beq      end_rearr                ; ja, wir sind schon unterstes
 bsr      whdl_to_wnd
 beq.b    rearr_whloop             ; ???
 cmp.w    w_curr+g_y(a0),d2        ; ausgeblendet ?
 bls.b    rearr_whloop             ; ja, weitersuchen
 move.w   -(a1),d0                 ; neues oberes Fenster merken
rearr_hloop2:
 move.w   -(a1),d1                 ; darueberliegendes Fenster
 cmp.w    d1,d7                    ; bin schon oben ?
 beq.b    rearr_setvalid           ; ja!
 move.w   d1,2(a1)                 ; umkopieren
 bra.b    rearr_hloop2
rearr_setvalid:
 move.w   d0,2(a1)                 ; das kommt nach vorn

* aktuelle Groesse nach -8(a6)[]

rearr_notopbot:

* Fenster umsortieren
 move.w   d7,d0
 bsr      _wind_close              ; uns erstmal entfernen
 move.w   d4,d1                    ; neue Fensterstapelpos.
 move.w   d7,d0
 bsr      _wind_to_stackpos        ; unser Fenster wieder einfuegen

* Rechtecklisten erneuern
 tst.w    topwhdl                  ; war aktives Fenster gueltig?
 sge      d0                       ; ja => ggf. umschalten, sonst nicht (!)
 ext.w    d0
 bsr      build_new_wgs
* Rest neumalen
 lea      SIZE(a6),a1
 lea      whdlx,a0
 add.w    d5,a0
 add.w    d5,a0                    ; ab alter Position
 move.w   d4,d1
 sub.w    d5,d1                    ; soviele Fenster zeichnen
 moveq    #0,d0                    ; aktiven Rahmen nicht malen
 bsr      _do_redraw

end_rearr:
* Ende des Bildschirmaufbaus
 jsr      update_0
 movem.l  (sp)+,d7/d6/d5/d4/d3/a5/a4/a3
 unlk     a6
 rts


**********************************************************************
*
* void app_wind_redraw(a0 = APPL *ap)
*
* malt alle Fenster der APP <ap> neu
*

app_wind_redraw:
 movem.l  a5/a6,-(sp)
 move.l   a0,a6
 lea      whdlx,a5
awr_wloop:
 move.w   (a5)+,d0
 beq.b    awr_ende
 bmi.b    awr_wloop
 move.w   d0,d1
 bsr      whdl_to_wnd
 beq.b    awr_wloop
 cmpa.l   w_owner(a0),a6
 bne.b    awr_wloop                ; nicht unser Fenster
 move.l   a0,a1
 lea      desk_g,a0
 move.w   d1,d0
 bsr.s    wind_redraw
 bra.b    awr_wloop
awr_ende:
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* void wind_redraw(d0 = int whdl, a0 = GRECT *g)
*
* malt Rand des Fensters <whdl> neu und schickt eine Redraw-
* Message.
*

wind_redraw:
 movem.l  a5/d7,-(sp)
 move.w   d0,d7
 move.l   a0,a5
 move.l   a5,a0                    ; nur Ausschnitt
 moveq    #0,d1                    ; startob
 move.w   d7,d0
 bsr      wind_draw
 move.l   a5,a0
 move.w   d7,d0
 bsr      send_redraw_message
 movem.l  (sp)+,a5/d7
 rts


**********************************************************************
*
* void topwind_move(d0 = int whdl, a0 = WINDOW *w, a1 = GRECT *oldg)
*
* wird nur von set_windxywh() aufgerufen
*
* <whdl> ist oberstes Fenster und wurde nicht in der Groesse veraendert,
* sondern nur verschoben.
* Diese Routine macht alle Redraws des Fensters, nicht die des
* Hintergrunds
*

topwind_move:
 movem.l  d5/d6/d7,-(sp)
 suba.w   #16,sp
 move.w   d0,d7                    ; d7 = <whdl>
 move.w   (a1)+,d6                 ; d6 = oldx
 move.w   (a1),d5                  ; d5 = oldy

 move.l   w_overall(a0),(sp)
 move.l   w_overall+g_w(a0),g_w(sp)     ; CURRXYWH mit Schatten

 lea      8(sp),a0                 ; 8(sp): Blit-Bereich
 move.w   d6,(a0)+                 ; zunaechst Quell-Position
 move.w   d5,(a0)+
 move.l   g_w(sp),(a0)
 lea      8(sp),a1
 lea      desk_g,a0
 jsr      grects_intersect
 beq.b    tpm_noblit               ; Quelle leer, nichts blitten

 sub.w    g_x(sp),d6               ; d6 = oldx-newx
 sub.w    g_y(sp),d5               ; d5 = oldy-newy

 sub.w    d6,8+g_x(sp)             ; Blit-Bereich auf Ziel-Position
 sub.w    d5,8+g_y(sp)

 lea      desk_g,a0
 jsr      set_clip_grect

 lea      8(sp),a0                 ; zu blittendes GRECT

 move.l   g_w(a0),-(sp)            ; w/h
 move.l   g_x(a0),-(sp)            ; Ziel-x/y

 move.l   g_x(a0),-(sp)
 add.w    d5,g_y(sp)               ; Quell-y
 add.w    d6,g_x(sp)               ; Quell-x
 jsr      blitcopy_rectangle       ; Bildschirmblock verschieben
 adda.w   #12,sp

* nicht ge-blit-tete Bereiche neuzeichnen:
* oberen Rest neu malen

tpm_noblit:
 move.w   8+g_y(sp),d0             ; y geblittet (Ziel)
 sub.w    g_y(sp),d0               ; - y (Fenster, neu)
 ble.b    tpm_redr1                ; OK
 add.w    d0,8+g_h(sp)             ; geblitteten Bereich vergroessern
 move.w   g_y(sp),d1               ; zu zeichnen: y
 add.w    d0,d1                    ; + zu zeichnen: Hoehe
 cmp.w    desk_g+g_y,d1
 ble.b    tpm_redr1                ; => ausserhalb des Bildschirms
 move.w   d0,-(sp)                 ; h
 move.w   8+2+g_w(sp),-(sp)        ; w (geblittet)

 move.w   8+4+g_x(sp),d0           ; x geblittet (Ziel)
 sub.w    4+g_x(sp),d0             ; - x (Fenster, neu)
 ble.b    tpm_rnw                  ; OK
 add.w    d0,(sp)
tpm_rnw:

 move.l   4+g_x(sp),-(sp)          ; x/y
 lea      (sp),a0
 move.w   d7,d0
 bsr      wind_redraw              ; Rand und Inneres malen
 addq.l   #8,sp

* linken Rest neu malen

tpm_redr1:
 move.w   8+g_x(sp),d0             ; x geblittet (Ziel)
 sub.w    g_x(sp),d0               ; - x (Fenster, neu)
 ble.b    tpm_redr2                ; OK

 add.w    d0,8+g_w(sp)             ; geblitteten Bereich vergroessern
 move.w   g_x(sp),d1               ; zu zeichnen: x
 add.w    d0,d1                    ; + zu zeichnen: Breite
 ble.b    tpm_redr2                ; => ausserhalb des Bildschirms
 move.w   8+g_h(sp),-(sp)          ; h (geblittet)
 move.w   d0,-(sp)                 ; w
 move.l   4+g_x(sp),-(sp)          ; x/y
 lea      (sp),a0
 move.w   d7,d0
 bsr      wind_redraw              ; Rand und Inneres malen
 addq.l   #8,sp

tpm_redr2:
 move.w   g_w(sp),d6               ; noetige Breite
 sub.w    8+g_w(sp),d6             ; - kopierte Breite
 move.w   g_h(sp),d5               ; noetige Hoehe
 sub.w    8+g_h(sp),d5             ; - kopierte Hoehe
 bgt.b    tp_redr
 tst.w    d6
 ble      tpm_end                  ; volle Hoehe und Breite kopiert

* rechten Rest neumalen

tp_redr:
 tst.w    d6
 ble      tp_redr2
 move.w   g_x(sp),d0
 add.w    8+g_w(sp),d0             ; x + kopierte Breite
 cmp.w    scr_w,d0
 bcc.b    tp_redr2                 ; ausserhalb des Bildschirms
 move.w   g_h(sp),-(sp)            ; h
 move.w   d6,-(sp)                 ; w: noetige - kopierte Breite
 move.w   g_y+4(sp),-(sp)          ; y
 move.w   d0,-(sp)                 ; x + kopierte Breite
 lea      (sp),a0
 move.w   d7,d0
 bsr      wind_redraw              ; Rand und Inneres malen
 addq.l   #8,sp

* unteren Rest neumalen

tp_redr2:
 tst.w    d5
 ble      tpm_end
 move.w   g_y(sp),d0
 add.w    8+g_h(sp),d0             ; y + kopierte Hoehe
 cmp.w    scr_h,d0
 bcc.b    tpm_end                  ; ausserhalb des Bildschirms
 move.w   d5,-(sp)                 ; h: noetige - kopierte Hoehe
 move.w   8+2+g_w(sp),-(sp)        ; noetige Breite
 move.w   d0,-(sp)                 ; y + kopierte Hoehe
 move.w   g_x+6(sp),-(sp)          ; x
 lea      (sp),a0
 move.w   d7,d0
 bsr      wind_redraw              ; Rand und Inneres malen
 addq.l   #8,sp

tpm_end:
 adda.w   #16,sp 
 movem.l  (sp)+,d5/d6/d7
 rts


**********************************************************************
*
* set_windxywh(d0 = int whdl, d1 = newtop,
*              a0 = WINDOW *w, a1 = GRECT *g_neu)
* Setzt Position und Groesse eines Fensters
*
* int     d7             : whdl
* int     d6             : altes oberstes Fenster
*                        : Flag fuer "bei alter Position kein Redraw"
* GRECT   *a5            : neues      CURRXYWH
* GRECT   *a4            : bisheriges CURRXYWH
* int     a3[8]          ; Arbeitsfeld fuer GRECT oder 8 Window- Handles
*

OLDSIZE   SET  -8
OLDALL    SET  OLDSIZE-8
WORK      SET  OLDALL-2*MAX_NWIND ; mind. 16 Bytes!!!

set_windxywh:
 link     a6,#WORK
 movem.l  d4/d5/d6/d7/a3/a4/a5,-(sp)
 move.w   d1,-(sp)

 move.w   d0,d7                    ; d7 := Handle
 move.l   a0,d4                    ; d4 = WINDOW *
 movea.l  a1,a5                    ; a5 := xywh[]
 lea      OLDSIZE(a6),a4           ; a4 := altes Rechteck
 lea      WORK(a6),a3              ; a3 := Arbeitsfeld

 move.l   w_curr(a0),(a4)          ; altes Rechteck nach OLDSIZE(a6)
 move.l   w_curr+g_w(a0),g_w(a4)

 move.l   w_overall(a0),OLDALL(a6) ; alter Umriss nach OLDALL(a6)
 move.l   w_overall+g_w(a0),OLDALL+g_w(a6)

 move.l   w_work(a0),8(a3)         ; altes WORKXYWH merken
 move.l   w_work+g_w(a0),12(a3)

 move.l   (a5),(a3)                ; Rechteck ins Arbeitsfeld
 move.l   g_w(a5),g_w(a3)

 move.l   (a5),w_curr(a0)          ; neue Position setzen
 move.l   g_w(a5),w_curr+g_w(a0)   ; neue Groesse setzen

;move.l   a0,a0                    ; WINDOW *
 move.l   wbm_ssize,a1
 jsr      (a1)

* Rechtecklisten aller Fenster erneuern

 move.l   d4,a0                    ; a0 WINDOW *
 move.w   w_state(a0),d5
 move.w   topwhdl,d6               ; d6 = altes oberstes Fenster
 move.w   (sp),d0                  ; aktives Fenster umschalten ?
 bsr      build_new_wgs
 tst.w    (sp)+                    ; wurde aktives Fenster umgeschaltet ?
 bne.b    swxy_weiter              ; ja
 jsr      set_topwind_app          ; nein, button_grect aktualisieren

swxy_weiter:
 cmp.w    topwhdl,d7
 bne.b    no_to_top
 cmp.w    d6,d7
 beq.b    no_to_top

* Fenster nach oben gebracht (open). Rand ist schon gezeichnet.
* Nur Inneres neu zeichnen und Ende

 move.l   a5,a0
 move.w   d7,d0
 bsr      send_rdrmsg
 bra      sub_redr                 ; alte Groesse war sowieso 0

* Fenster ist und war oberes.
no_to_top:
 btst     #WSTAT_COVERED_B,d5
 bne      no_top                   ; Fenster war vorher ueberdeckt
 move.l   d4,a0
 move.w   w_state(a0),d5
 btst     #WSTAT_COVERED_B,d5
 bne      no_top                   ; Fenster ist jetzt ueberdeckt
* Fenster war und ist nicht ueberdeckt
 move.l   g_w(a4),d0
 cmp.l    g_w(a5),d0
 bne.b    no_top                   ; Groesse hat sich geaendert
 move.l   g_x(a4),d0
 cmp.l    g_x(a5),d0
 beq      setg_end                 ; Position und Groesse gleich

* Fenster ist und war oberes, die Groesse hat sich nicht geaendert
* Also ist das obere Fenster verschoben worden

 move.l   a4,a1                    ; OLDSIZE
 move.l   d4,a0                    ; WINDOW *
 move.w   d7,d0
 bsr      topwind_move
 bra      sub_redr

no_top:
 cmp.w    topwhdl,d6               ; hat sich oberstes geaendert ?
 bne      kein_rahmen2             ; ja, Rahmen schon gezeichnet

* Fenster ist weder altes noch neues oberstes. Rahmen zeichnen, wenn sich
* Groesse oder Position geaendert haben

 move.l   g_x(a4),d0
 cmp.l    g_x(a5),d0
 bne.b    rahmen
 move.l   g_w(a4),d0
 cmp.l    g_w(a5),d0
 beq      setg_end                 ; Position und Groesse gleich => Ende
rahmen:
 move.w   d7,d0
 bsr      wind_draw_whole

kein_rahmen2:
 moveq    #0,d6                    ; per Default Hintergrund nachmalen
 move.l   g_x(a4),d0
 cmp.l    g_x(a5),d0
 bne      no_sizer

* Es wurde nur die Groesse veraendert, bei gleicher Position
* Maximal werden 2 Redraws verschickt

 move.l   g_w(a5),d0
 cmp.l    g_w(a4),d0
 beq      setg_end                 ; Position und Groesse gleich => Ende
 move.w   g_w(a5),d0
 cmp.w    g_w(a4),d0
 shi      d1                       ; d1 = nach rechts vergroessert
 move.w   g_h(a5),d0
 cmp.w    g_h(a4),d0
 shi      d2                       ; d2 = nach unten vergroessert
 move.b   d1,d0
 or.b     d2,d0
 beq      sub_redr                 ; nur verkleinert oder gleich geblieben
 cmp.b    d1,d2                    ; ganz vergroessert
 seq      d6                       ; ja, kein Hintergrund

 move.l   (a5),(a3)
 move.l   g_w(a3),g_w(a3)          ; CURRXYWH neu nach a3[]
 btst     #6,(config_status+3).w
 bne.b    no_sizer                 ; Smart Redraw OFF

 tst.b    d1
 beq.b    nicht_rechts
* Fenster ist nach rechts vergroessert worden
 move.l   8(a3),(a3)               ; y_work_alt
 move.w   8+g_w(a3),d0
 add.w    d0,g_x(a3)               ; x_work_alt + w_work_alt
 move.w   8+g_h(a3),g_h(a3)        ; h_work_alt
 move.w   g_w(a5),d0
 sub.w    g_w(a4),d0
 move.w   d0,g_w(a3)               ; w - w_alt
 move.w   d2,-(sp)

 move.l   a3,a0
 move.w   d7,d0
 bsr      send_rdrmsg

 move.w   (sp)+,d2
* Fenster ist nach unten vergroessert worden
nicht_rechts:
 tst.b    d2
 beq      sub_redr
 move.l   8(a3),(a3)               ; x_work_alt
 move.w   8+g_h(a3),d0
 add.w    d0,g_y(a3)               ; y_work_alt + h_work_alt
 move.w   g_w(a5),g_w(a3)          ; w_neu
 move.w   g_h(a5),d0
 sub.w    g_h(a4),d0
 move.w   d0,g_h(a3)               ; h - h_alt
no_sizer:
 move.l   a3,a0
 move.w   d7,d0
 bsr      send_rdrmsg

 tst.b    d6
 bne      setg_end                 ; nach unten und rechts vergroessert

* der riesengrosse Redraw
sub_redr:
 tst.l    g_w(a4)
 beq.b    setg_end                 ; altes Rechteck war w=h=0
 lea      OLDALL(a6),a0            ; Fensterumriss (inkl. Schatten)
 bsr      wind0_draw
 move.l   a3,a0                    ; Platz fuer nwindows Fenster
 move.w   d7,d0
 bsr      get_wind_hierar          ; Liste aller unteren Fenster
 move.l   a3,a0
 cmp.w    (a0)+,d7                 ; unseres ueberspringen
 bne.b    setg_end                 ; Fehler
 lea      OLDALL(a6),a1            ; Redraw- Bereich
 moveq    #-1,d1                   ; keine Anzahlbegrenzung
 moveq    #0,d0                    ; aktiven Rahmen nicht malen
 bsr      _do_redraw
setg_end:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4
 unlk     a6
 rts


**********************************************************************
*
* void wind_ontop( d0 = int whdl )
*
* Schickt ein WM_ONTOP an das Fenster <whdl>.
*

wind_ontop:
 moveq    #WM_ONTOP,d1             ; Message- Code
 bra.b    _w_u


**********************************************************************
*
* void wind_untopped( d0 = int whdl )
*
* Schickt ein WM_UNTOPPED an das Fenster <whdl>.
*

wind_untopped:
 moveq    #WM_UNTOPPED,d1          ; Message- Code
_w_u:
 move.w   d0,d2                    ; whdl
 bsr      whdl_to_wnd
 beq.b    w_u_ende                 ; ???
 btst     #WSTAT_QUIET_B,w_state+1(a0)       ; quiet mode ?
 bne      w_u_ende                 ; ja, keine Nachricht
 move.l   w_owner(a0),a2
 move.l   sp,a0                    ; Daten: 4 Dummyworte
;move.w   d2,d2                    ; whdl
 move.w   d1,d0                    ; Message- Code
 move.w   ap_id(a2),d1             ; dst_apid
 jmp      send_msg
w_u_ende:
 rts


**********************************************************************
*
* int get_next_window( d0 = int whdl, a0 = APPL *ap )
*
* ermittelt das naechste Fenster der Applikation <ap>, welches unter
* dem Fenster <whdl> liegt.
* Bei <whdl> == 0 ermittle oberstes Fenster der Applikation.
*            == -1 ermittle unterstes Fenster der Applikation.
* Rueckgabe 0, wenn keins vorhanden.
*

get_next_window:
 move.l   a0,a2                    ; a2 = app
 move.w   d0,d2
 clr.w    -(sp)                    ; Rueckgabe: 0 per Default
 lea      whdlx,a1
gnw_next:
 move.w   (a1)+,d0
 beq.b    gnw_ende                 ; Listenende, return
 bmi.b    gnw_next                 ; eingefroren
 tst.w    d2
 ble.b    gnw_weiter
 cmp.w    d0,d2                    ; Fenster gefunden
 bne.b    gnw_next                 ; nein
 moveq    #0,d2                    ; unser naechstes!
 bra.b    gnw_next                 ; dieses noch ueberspringen
gnw_weiter:
 bsr      whdl_to_wnd
 beq.b    gnw_next                 ; ???
 cmpa.l   w_owner(a0),a2           ; unser Fenster ?
 bne.b    gnw_next                 ; nein, weitersuchen
 move.w   -2(a1),(sp)              ; whdl merken
 tst.w    d2                       ; fertig?
 bmi.b    gnw_next                 ; nein, weitersuchen (letztes passendes)
gnw_ende:
 move.w   (sp)+,d0
 rts


**********************************************************************
*
* EQ/NE top_my_window( a0 = APPL *ap )
*
* Schickt ein WM_TOPPED an das oberste Fenster der Applikation <ap>.
* Rueckgabe 1, falls Nachricht verschickt wurde.
*
* MagiC 5.10: Den verzoegerten TopAll einleiten, d.h. bei Ausfuehrung
* werden _alle_ Fenster der Applikation getoppt
*

top_my_window:
 move.w   ap_id(a0),-(sp)          ; ap_id merken
 moveq    #0,d0                    ; ermittle oberstes Fenster der app
 bsr.b    get_next_window
 tst.w    d0
 beq.b    tmw_ende                 ; wir haben kein Fenster
;cmp.w    topwhdl,d0               ; Fenster schon aktiv ?
;beq.b    tmw_ok                   ; ja, nichts tun

 move.w   d0,topall_thdl           ; verzoegertes TopAll
 move.l   timer_cnt,topall_timer   ; Zaehler fuer den Fall "timeout"

 move.l   sp,a0                    ; Daten: 4 Dummyworte
 move.w   d0,d2                    ; whdl
 move.w   (sp),d1                  ; dst_apid
 moveq    #WM_TOPPED,d0            ; Message- Code
 jsr      send_msg
tmw_ok:
 moveq    #1,d0                    ; Erfolg!
tmw_ende:
 addq.l   #2,sp
 rts

