     INCLUDE "AESINC.S"
        TEXT

     XREF      config_status       ; vom DOS

     XREF      set_full_clip
     XREF      v_drawedges,v_drawgrect
     XREF      mctrl_0,mctrl_1,update_0,update_1
     XREF      mouse_on,mouse_off
     XREF      set_xor_black
     XREF      obj_to_g
     XREF      _objc_change
     XREF      objc_wdraw
     XREF      objc_wchange
     XREF      _evnt_multi
     XREF      get_ob_xywh

     XDEF      graf_dragbox
     XDEF      graf_growbox
     XDEF      graf_movebox
     XDEF      graf_rubberbox
     XDEF      graf_shrinkbox
     XDEF      gr_xslidbx,graf_slidebox
     XDEF      graf_watchbox
     XDEF      graf_wwatchbox
     XDEF      xgrf_stepcalc
     XDEF      xgrf_2box

     XDEF      evnt_rel_mm
     XDEF      _drawgrect
     XDEF      graf_rbox      ; nach FSELX


**********************************************************************
**********************************************************************
*
* Die graf- Bibliothek
*

**********************************************************************
*
* void xgrf_stepcalc(int anfw, int anfw, GRECT *end,
*                    int *cx, int *cy, int *cnt, int *xstep, int *ystep)
*

_xgs:
 move.w   4(a3,d2.w),d0
 lsr.w    #1,d0
 move.w   $14(sp,d2.w),d1
 lsr.w    #1,d1
 sub.w    d1,d0
 rts

xgrf_stepcalc:
 movem.l  a3/a4/a5,-(sp)
 lea      $14(sp),a0
 movem.l  (a0)+,a5/a4/a3
 moveq    #0,d2
 bsr.b    _xgs
 move.w   d0,(a4)
 moveq    #2,d2
 bsr.b    _xgs
 move.w   d0,(a5)
 addq.l   #8,a0
 move.l   (a0),-(sp)
 move.l   -(a0),-(sp)
 move.l   -(a0),-(sp)
 move.w   (a5),-(sp)
 move.w   (a4),-(sp)
 bsr      grfhelper
 move.w   (a3)+,d0
 add.w    d0,(a4)
 move.w   (a3),d0
 add.w    d0,(a5)
 adda.w   #$10,sp
 movem.l  (sp)+,a5/a4/a3
 rts

grfhelper2:
 movem.l  $2c(sp),a5/a4            ; a4 = GRECT *anf/a5 = GRECT *end
 lea      $10(sp),a6
 moveq    #4,d0
grh2_loop:
 subq.l   #2,a6
 move.l   a6,-(sp)
 dbf      d0,grh2_loop
 move.l   a5,-(sp)                 ; GRECT *end
 move.l   4(a4),-(sp)              ; w/h von <anf>
 bsr.b    xgrf_stepcalc
 adda.w   #$1c,sp
 rts


**********************************************************************
*
* void graf_growbox(GRECT *anf, GRECT *end)
*
*   2(sp): cx
*   4(sp): cy
*   6(sp): cnt
*   8(sp): xstep
*  $a(sp): ystep
*  $c(sp) - $20(sp): gerettete Register d5-d7/a4-a6
* $24(sp): Rücksprungadresse
* $28(sp): GRECT *anf
* $2c(sp): GRECT *end
*

graf_growbox:
 btst     #7,config_status+3.w
 bne.b    no_growbox
 movem.l  d2/d3/d4/d5/d6/d7/a4/a5/a6,-(sp)
 bsr.b    grfhelper2
 move.l   (a6),-(sp)               ; cx,cy        (nach)
 move.l   (a4)+,-(sp)              ; anfx, anfy   (von)
 move.l   (a4),-(sp)               ; anfw, anfh   (Breite, Höhe)
 jsr      graf_movebox
 jsr      mouse_off
 moveq    #1,d7                    ; zweimal durchlaufen wegen XOR
grgr_l1:
 moveq    #1,d0
 move.w   d0,-(sp)
 move.l   6(a6),-(sp)              ; xstep, ystep
 move.l   (a4),-(sp)               ; anfw, anfh
 move.l   (a6),-(sp)               ; cx, cy
 move.w   4(a6),-(sp)              ; cnt
 move.w   d0,-(sp)                 ; nur Ecken zeichnen
 bsr.b    xgrf_2box
 adda.w   #$12,sp
 dbf      d7,grgr_l1
 jsr      mouse_on
 adda.w   #$18,sp
 movem.l  (sp)+,a6/a5/a4/d7/d6/d5
no_growbox:
 rts


**********************************************************************
*
* void graf_shrinkbox(GRECT *anf, GRECT *end)
*

graf_shrinkbox:
 btst     #7,config_status+3.w
 bne.b    no_shrinkbox
 movem.l  d2/d3/d4/d5/d6/d7/a4/a5/a6,-(sp)
 bsr.b    grfhelper2
 jsr      mouse_off
 moveq    #1,d7
grsr_l1:
 addq.l   #4,a5
 moveq    #1,d0
 move.w   d0,-(sp)
 move.w   8(a6),-(sp)
 neg.w    (sp)
 move.w   6(a6),-(sp)
 neg.w    (sp)
 move.l   (a5),-(sp)
 move.l   -(a5),-(sp)
 move.w   4(a6),-(sp)
 move.w   d0,-(sp)                 ; nur Ecken zeichnen
 bsr.b    xgrf_2box
 adda.w   #$12,sp
 dbf      d7,grsr_l1
 jsr      mouse_on
 move.l   (a4)+,-(sp)
 move.l   (a6),-(sp)
 move.l   (a4),-(sp)
 bsr.b    graf_movebox
 adda.w   #$18,sp
 movem.l  (sp)+,a6/a5/a4/d7/d6/d5
no_shrinkbox:
 rts


**********************************************************************
*
* xgrf_2box(int only_corners, int cnt, int x, int y, int w, int h,
*           int xstep, int ystep, int sizing)
*
*

xgrf_2box:
 movem.l  d4/d5/d6/d7/a4/a5,-(sp)
 lea      24+4(sp),a0
 lea      v_drawedges,a4
 tst.w    (a0)+                    ; nur Ecken ?
 bne.b    xg2_edges
 lea      v_drawgrect,a4
xg2_edges:
 move.w   (a0)+,d5                 ; d5 = cnt
 move.l   a0,a5                    ; &x,y,w,h
 addq.l   #8,a0
 move.w   (a0)+,d7                 ; d7 = xstep
 move.w   (a0)+,d6                 ; d6 = ystep
 move.w   (a0)+,d4                 ; sizing: gesetzt, falls Größe sich ändert
xgrt_l1:
 move.l   a5,a0                    ; &x,y,w,h
 jsr      (a4)                     ; Da geht die Post ab!
 move.l   a5,a0                    ; &x,y,w,h
 sub.w    d7,(a0)+                 ; x -= xstep
 sub.w    d6,(a0)+                 ; y -= ystep
 tst.w    d4                       ; flag2 (Rechteckausmaße auch ändern ?)
 beq.b    xgrt_loop_cont           ; nein, weiter
 move.w   d7,d0
 add.w    d0,d0
 add.w    d0,(a0)+                 ; w += 2*xstep
 move.w   d6,d0
 add.w    d0,d0
 add.w    d0,(a0)+                 ; h += 2*ystep
xgrt_loop_cont:
 dbf      d5,xgrt_l1               ; cnt-1 Durchläufe
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4
 rts

graf_movebox:
 movem.l  d1/d2/d3/d4/d5/d6/d7/a5,-(sp)
 movea.l  sp,a5
 movem.l  $24(sp),d7/d6/d5
 move.w   d6,d4
 sub.w    d7,d4
 move.l   d6,d3
 swap     d3
 swap     d7
 sub.w    d7,d3
 pea      6(sp)
 pea      8(sp)
 pea      $a(sp)
 move.w   d3,d0
 bpl.b    grfm_l1
 neg.w    d0
grfm_l1:
 swap     d0
 move.w   d4,d0
 bpl.b    grfm_l2
 neg.w    d0
grfm_l2:
 move.l   d0,-(sp)
 bsr.b    grfhelper
 move.l   (a5)+,d0
 move.w   (a5)+,d7
 tst.w    d3
 bpl.b    grfm_l3
 neg.w    d7
grfm_l3:
 swap     d7
 move.w   (a5)+,d7
 tst.w    d4
 bpl.b    grfm_l4
 neg.w    d7
grfm_l4:
 moveq    #0,d4                    ; Hiword: ganze Rechtecke zeichnen
 move.w   d0,d4
 jsr      mouse_off
 exg      d5,d6
 moveq    #1,d3
grfm_l5:
 clr.w    -(sp)
 movem.l  d4/d5/d6/d7,-(sp)
 jsr      xgrf_2box
 adda.w   #$12,sp
 dbf      d3,grfm_l5
 jsr      mouse_on
 adda.w   #$18,sp
 movem.l  (sp)+,a5/d7/d6/d5/d4/d3
 rts

grfhelper:
 movem.l  d4/d5/d6/d7/a4/a5/a6,-(sp)
 movem.l  $20(sp),a6/a5/a4/d7
 move.w   d7,d6
 swap     d7
 jsr      set_xor_black
 move.w   d7,d4
 add.w    d6,d4
 moveq    #-1,d5
grhl_l1:
 addq.w   #1,d5
 lsr.w    #1,d4
 bne.b    grhl_l1
 moveq    #1,d0
 moveq    #1,d1
 move.w   d5,(a4)
 beq.b    grhl_l3
 ext.l    d7
 divs     d5,d7
 cmp.w    d7,d0
 bge.b    grhl_l2
 move.w   d7,d0
grhl_l2:
 ext.l    d6
 divs     d5,d6
 cmp.w    d6,d1
 bge.b    grhl_l3
 move.w   d6,d1
grhl_l3:
 move.w   d0,(a5)
 move.w   d1,(a6)
 movem.l  (sp)+,a6/a5/a4/d7/d6/d5/d4
 rts


**********************************************************************
*
* int graf_watchbox(a0 = OBJECT *tree, d0 = int objnr
*                   d1 = int instate,  d2 = int outstate )
*

graf_watchbox:
 move.w   #-1,-(sp)                ; kein Fenster
 bsr.b    graf_wwatchbox
 addq.l   #2,sp
 rts


**********************************************************************
*
* int graf_wwatchbox(a0 = OBJECT *tree, d0 = int objnr
*                   d1 = int instate,  d2 = int outstate,
*                   int windowhandle )
*
* Wie <graf_watchbox>, aber in <windowhandle> kann ein Fenster
* übergeben werden, dessen Rechteckliste beim Redraw verwendet wird.
* ggf. <windowhandle == -1>, dann kein Fenster.
*

graf_wwatchbox:
 movem.l  d5/d6/d7/a5,-(sp)
 move.w   4+16(sp),d5              ; d5 = windowhandle
 subq.l   #8,sp
 clr.w    -(sp)                    ; MGRECT (10 Bytes)
 movea.l  a0,a5                    ; a5 = OBJECT *tree
 move.w   d0,d7                    ; d7 = int objnr
 move.w   d1,d6
 swap     d6
 move.w   d2,d6                    ; d6 = int instate/int outstate

 jsr      mctrl_1

 jsr      set_full_clip

 lea      2(sp),a1                 ; GRECT *
 move.w   d7,d0
 move.l   a5,a0
 jsr      obj_to_g                 ; Objektausmaße nach GRECT 2(sp)

gwb_loop:
 swap     d6                       ; instate/outstate vertauschen, bei
                                   ; Start instate ins Loword
 move.w   d5,d2                    ; winhdl, ggf. -1
 suba.l   a1,a1                    ; kein GRECT
 move.w   d6,d1
 move.w   d7,d0
 move.l   a5,a0
 jsr      objc_wchange

gwb_both:
 eori.w   #1,(sp)                  ; in/out- Flag für MGRECT toggeln

 move.l   sp,a0
 bsr      evnt_rel_mm              ; warte auf Mausbewegung und Loslassen der linken Taste
 beq.b    gwb_loop                 ; nicht losgelassen

 jsr      mctrl_0

 move.w   (sp)+,d0                 ; in/out- Flag
 addq.l   #8,sp
 movem.l  (sp)+,a5/d7/d6/d5
 rts


**********************************************************************
*
* int evnt_rel_mm(MGRECT *mm)
*
* Wartet auf Loslassen der linken Maustaste sowie auf das Mausereignis
* <mm>
* Rückgabe 0, wenn Maustaste losgelassen
*

evnt_rel_mm:
 suba.w   #$c,sp
 move.l   sp,-(sp)                 ; out[]
 clr.l    -(sp)                    ; kein Messagebuffer
 move.l   #$10100,-(sp)            ; 1 Klick, Maske 1, Status 0
 clr.l    -(sp)                    ; kein Timer
 clr.l    -(sp)                    ; kein zweites Rechteck
 move.l   a0,-(sp)                 ; MGRECT *mm
 move.w   #6,-(sp)                 ; MU_BUTTON + MU_M1
 jsr      _evnt_multi
 adda.w   #$26,sp
 btst     #1,d0                    ; Rückgabe NE, wenn Taste losgelassen
 rts


**********************************************************************
*
* void _drawgrect( d7 = int two, a5 = GRECT *g1, a4 = GRECT *g2 )
*
* malt eins (d7 = 0) oder zwei (d7 != 0) Rechtecke.
* <g2> ist ein Offset zu g1 oder nullgrect.
* wird von draw_2grects und auch von size_wind() aufgerufen.
*

_drawgrect:
 jsr      mouse_off
 move.l   a5,a0                    ; Hauptrechteck
 jsr      v_drawgrect              ; malen
 tst.w    d7
 beq.b    drgr_mouse               ; kein zweites Rechteck
 subq.l   #8,sp                    ; Platz für GRECT
 lea      (sp),a0                  ; Platz für 4 ints
 moveq    #3,d1
drgr_loop:
 move.w   (a4)+,d0
 add.w    (a5)+,d0                 ; relativ zu absolut umrechnen
 move.w   d0,(a0)+
 dbf      d1,drgr_loop
 subq.l   #8,a4                    ; a4 restaurieren
 subq.l   #8,a5                    ; a5 restaurieren
 lea      (sp),a0
 jsr      v_drawgrect
 addq.l   #8,sp
drgr_mouse:
 bra      mouse_on


**********************************************************************
*
* int draw_2grects(a0 = GRECT *g1, d0 = {int x, int y})
*
* Malt das Rechteck, wartet auf Verlassen der Position x,y oder auf
* Loslassen der Maustaste und löscht das Rechteck wieder.
* Gibt Status der linken Maustaste zurück (0, wenn losgelassen).
*

draw_2grects:
 movem.l  d5/d6/d7/a5,-(sp)
 move.l   a0,a5                    ; GRECT *
 move.l   d0,d5                    ; x,y
 moveq    #0,d7                    ; kein inneres Rechteck
 jsr      set_xor_black
 bsr.b    _drawgrect               ; Rechteck malen
 moveq    #1,d0
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 move.l   d5,-(sp)
 move.w   d0,-(sp)
 move.l   sp,a0
 bsr      evnt_rel_mm              ; warte auf Loslassen der Taste oder Mausbewegung
 adda.w   #10,sp
 seq      d6
 ext.w    d6                       ; Taste losgelassen ?
 jsr      set_xor_black
 bsr.b    _drawgrect               ; Rechteck wieder löschen
 move.w   d6,d0
 movem.l  (sp)+,a5/d7/d6/d5
 rts


**********************************************************************
*
* PUREC void graf_rbox(d0 = int x, d1 = int y, d2 = int minw,
*                       int minh, a0 = int *neuw, a1 = int *neuh)
*

graf_rbox:
 move.l   a2,-(sp)
 swap     d0
 move.w   d1,d0
 move.w   d2,d1
 move.w   8(sp),d2
 movem.l  a0/a1,-(sp)
 bsr.b    graf_rubberbox
 movem.l  (sp)+,a0/a1
 move.w   d0,(a1)
 swap     d0
 move.w   d0,(a0)
 moveq    #1,d0
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* d0.l = graf_rubberbox(d0 = {int x, int y}, d1 = int minw,
*                       d2 = int minh)
*
* Rückgabe: d0.l = {intw, int h}
*

graf_rubberbox:
 move.w   d7,-(sp)
 move.w   d6,-(sp)
 subq.l   #8,sp
 move.l   d0,(sp)                  ; x,y
 move.w   d1,d7                    ; d7 = minw
 move.w   d2,d6                    ; d6 = minh

 jsr      mctrl_1
;jsr      set_xor_black

rub_loop:
 move.w   gr_mkmx,d0               ; Mauspos.
 sub.w    (sp),d0                  ; - linke Ecke
 addq.w   #1,d0
 cmp.w    d7,d0                    ; >= minw ?
 bge.b    rub_m1
 move.w   d7,d0
rub_m1:
 move.w   d0,g_w(sp)

 move.w   gr_mkmy,d0               ; Mauspos.
 sub.w    2(sp),d0                 ; - linke Ecke
 addq.w   #1,d0
 cmp.w    d6,d0                    ; >= minh ?
 bge.b    rub_m2
 move.w   d6,d0
rub_m2:
 move.w   d0,g_h(sp)

 move.w   gr_mkmx,d0
 swap     d0
 move.w   gr_mkmy,d0
 move.l   sp,a0                    ; g
 bsr      draw_2grects
 tst.w    d0                       ; Maustaste losgelassen ?
 bne.b    rub_loop                 ; nein

 jsr      mctrl_0

 addq.l   #4,sp
 move.l   (sp)+,d0                 ; w und h zurück

 move.w   (sp)+,d6
 move.w   (sp)+,d7
 rts


**********************************************************************
*
* long graf_dragbox(a0 = GRECT *boxg, a1 = GRECT *outg,
*                   d0 = void *callback_data )
*
* Achtung:  der AES- Dispatcher muß das erste GRECT umdrehen!
* Rückgabe: d0 = {int x, int y}
*
*  0(sp)  gr_mkmx
*  2(sp)  gr_mkmy
*  4(sp)  GRECT der laufenden Box
* 12(sp)  x: Anf.diff. zwischen Mausposition und linker Ecke
* 14(sp)  y
*
* 15.10.95:    Die <callback_data> geben eine Funktion an, die
*              bei jeder Mausbewegung aufgerufen wird.
*              callback_data ist Zeiger auf:
*                   long      Adresse einer Funktion
*                             Parameter ist callback_data selbst,
*                              werden in a0 übergeben. Rückgabe in d0
*                              FALSE, wenn beendet wird.
*

graf_dragbox:
 move.l   a5,-(sp)
 clr.w    -(sp)                    ; 20(sp): erster Durchlauf
 move.l   d0,-(sp)                 ; 16(sp) = callback_data
 suba.w   #16,sp
 move.l   a1,a5                    ; a5 = outg
 lea      4(sp),a2
 move.l   (a0)+,(a2)+              ; linke obere Ecke der laufenden Box
 move.l   (a0)+,(a2)+              ; Breite und Höhe der laufenden Box
 move.w   gr_mkmx,d0
 sub.w    4+g_x(sp),d0
 move.w   d0,(a2)+
 move.w   gr_mkmy,d0
 sub.w    4+g_y(sp),d0
 move.w   d0,(a2)

 jsr      mctrl_1

gdb_loop2:
;jsr      set_xor_black

gdb_loop:
 move.w   gr_mkmx,(sp)
 move.w   gr_mkmy,2(sp)

 move.w   (sp),d0
 sub.w    4+8(sp),d0
 move.w   2(sp),d1
 sub.w    4+8+g_y(sp),d1
 move.w   d0,4+g_x(sp)
 move.w   d1,4+g_y(sp)

 lea      4(sp),a1                 ; inneres GRECT
 move.l   a5,a0                    ; äußeres GRECT

 move.w   (a0),d0
 cmp.w    (a1),d0
 blt.b    grdb_l1
 move.w   d0,(a1)
grdb_l1:
 add.w    4(a0),d0
 move.w   (a1),d1
 add.w    4(a1),d1
 cmp.w    d1,d0
 bge.b    grdb_l2
 sub.w    4(a1),d0
 move.w   d0,(a1)
grdb_l2:
 move.w   2(a0),d0
 cmp.w    2(a1),d0
 blt.b    grdb_l3
 move.w   d0,2(a1)
grdb_l3:
 add.w    6(a0),d0
 move.w   2(a1),d1
 add.w    6(a1),d1
 cmp.w    d1,d0
 bge.b    grdb_l4
 sub.w    6(a1),d0
 move.w   d0,2(a1)
grdb_l4:

 move.l   16(sp),d0           ; realtime_flag ?
 beq.b    gdb_noreal          ; nein
 tst.b    20(sp)              ; erster Durchlauf ?
 beq.b    gdb_nosend          ; ja
 move.l   d0,a0               ; Parameter
 move.l   (a0),a2
 move.l   4(sp),d0            ; x/y
 jsr      (a2)                ; Callback
 tst.w    d0
 beq.b    gdrb_ende

; warten auf Maustaste, ohne Zeichnen des Geisterrahmens

gdb_nosend:
 st       20(sp)              ; nicht mehr erster Durchlauf
 moveq    #1,d0
 move.w   d0,-(sp)
 move.w   d0,-(sp)
 move.l   4(sp),-(sp)         ; x/y
 move.w   d0,-(sp)
 move.l   sp,a0
 bsr      evnt_rel_mm         ; warte auf Loslassen der Taste oder Mausbewegung
 adda.w   #10,sp
 seq      d0
 ext.w    d0                  ; Taste losgelassen ?
 bra.b    gdb_ask             ; weiter

gdb_noreal:
 lea      (sp),a0
 move.l   (a0)+,d0
;move.l   a0,a0
 jsr      draw_2grects

gdb_ask:
 tst.w    d0                  ; Maus losgelassen ?
 bne      gdb_loop            ; nein, weiter

gdrb_ende:
 jsr      mctrl_0

 move.l   4(sp),d0
 adda.w   #16+4+2,sp
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* PUREC WORD graf_slidebox( OBJECT *tree, WORD parent,
*                   WORD objnr, WORD is_vertikal)
*
* int graf_slidebox(a0 = OBJECT *tree, d0 = int parent,
*                   d1 = int objnr, d2 = int is_vertikal)
*
* Rückgabe: 0..1000
*

graf_slidebox:
 move.l   a2,-(sp)                 ; a2 retten
 clr.l    -(sp)                    ; kein Callback
 bsr.b    gr_xslidbx
 addq.l   #4,sp
 move.l   (sp)+,a2                 ; a2 zurück
 rts
 

**********************************************************************
*
* d0 = gr_xslidbx(a0 = OBJECT *tree, d0 = int parent,
*                   d1 = int objnr, d2 = int is_vertikal,
*                   void *callback_data)
*
* Rückgabe:    d0 = 0..1000
*

gr_xslidbx:
 suba.w   #16,sp

 move.w   d2,-(sp)                 ; is_vertikal retten

 move.l   a0,-(sp)                 ; tree retten
 move.w   d1,-(sp)                 ; objnr retten

 lea      8+8(sp),a1
;move.w   d0,d0                    ; parent
;move.l   a0,a0
 jsr      obj_to_g                 ; 8(fp) = absolutes GRECT des parent

 lea      0+8(sp),a2

 move.l   a2,a1
 move.w   (sp)+,d0                 ; objnr
 move.l   (sp)+,a0                 ; tree
 jsr      get_ob_xywh              ; 0(fp) = relatives GRECT des objnr

 lea      8(a2),a1                 ; äußeres Rechteck
 move.l   a2,a0                    ; inneres Rechteck

 move.w   (a1),d0
 add.w    d0,(a2)+
 move.w   2(a1),d0
 add.w    d0,(a2)                  ; inneres in absolutes umrechnen

 pea      gr_xcallback(pc)
 move.l   26(sp),d0                ; callback_data
 beq.b    grxs_noc
 move.l   sp,d0
grxs_noc:
;move.l   a1,a1
;move.l   a0,a0
 bsr      graf_dragbox
 addq.l   #4,sp
 move.l   d0,2(sp)                 ; x,y

 tst.w    (sp)+                    ; is_vertikal
 move.l   sp,a2
 beq.b    grxs_l1
 addq.l   #2,a2                    ; y statt x und h statt w
grxs_l1:
 move.w   8+g_w(a2),d0             ; äußeres w bzw. h
 sub.w    g_w(a2),d0               ; - inneres   w bzw. h
 beq.b    grxs_ret
 move.w   (a2),d2                  ; finales x bzw. y
 sub.w    8(a2),d2                 ; - initiales x bzw. y
 mulu     #1000,d2
 divu     d0,d2
 move.w   d2,d0
grxs_ret:
 adda.w   #16,sp
 rts


* Rechnet Objektpos. in 0..1000 um und macht Callback
* d0 -> Rückgabe von graf_dragbox
* a0 -> long gr_xcallback
*       int  is_vertikal
*         usw. (Stack von gr_xslidbx)

gr_xcallback:
 addq.l   #4,a0
 move.l   d0,2(a0)                 ; x/y
 tst.w    (a0)+                    ; is_vertikal
 move.l   a0,a2
 beq.b    gxc_v
 addq.l   #2,a2                    ; y statt x und h statt w
gxc_v:
 move.w   8+g_w(a2),d0             ; äußeres w bzw. h
 sub.w    g_w(a2),d0               ; - inneres   w bzw. h
 beq.b    gxc_e
 move.w   (a2),d2                  ; finales x bzw. y
 sub.w    8(a2),d2                 ; - initiales x bzw. y
 mulu     #1000,d2
 divu     d0,d2
 move.w   d2,d0                    ; 0..1000
gxc_e:
 move.l   20(a0),a0                ; callback_data von graf_slidebox
 move.l   (a0),a2
 jmp      (a2)
 
