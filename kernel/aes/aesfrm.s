*********************************************************************
*
* FORM-Manager
*

     INCLUDE "aesinc.s"
     TEXT

     XDEF      form_alert
     XDEF      do_aes_alert
     XDEF      xfrm_popup
     XDEF      _form_popup
     XDEF      form_xdo,_form_xdo
     XDEF      form_do
     XDEF      _form_button,form_button,form_wbutton
     XDEF      _form_wkeybd
     XDEF      form_error
     XDEF      frm_xdial
     XDEF      __fm_xdial
     XDEF      gem_etvc
     XDEF      form_xerr
     XDEF      fast_save_scr,restore_scr
     XDEF      scrg_sav,scrg_rst
     XDEF      al_aeserr
     XDEF      al_sigerr

* vom BIOS

     XREF      altcode_asc

* von AESWIN

     XREF      objc_wdraw
     XREF      objc_wchange

* von AESOBJ

     XREF      blitcopy_rectangle
     XREF      graf_mouse,mouse_on,mouse_off
     XREF      set_mouse_app
     XREF      mouse_immed,reset_mouse
     XREF      beg_mctrl,end_mctrl,update_0,update_1
     XREF      mctrl_0,mctrl_1
     XREF      max,vmemcpy,toupper,_sprintf
     XREF      wait_but_released,evnt_button,_evnt_multi
     XREF      flush_keybuf
     XREF      _objc_find,set_ob_xywh,calc_obsize,_objc_edit,parentob,ob_modes
     XREF      _objc_draw,kill_tree_structure,objc_add,_objc_offset
     XREF      objc2mgrect,_form_center
     XREF      strplc_pcolor,vro_cpyfm,v_pline,drawbox
     XREF      get_clip_grect,set_clip_grect,set_full_clip
     XREF      xy_in_grect,grects_intersect,grect_in_scr
     XREF      fatal_err
     XREF      graf_growbox,graf_shrinkbox
     XREF      graf_watchbox,graf_dragbox,graf_slidebox
     XREF      graf_wwatchbox
     XREF      rsrc_obfix
     XREF      calc_wgrect_overlaps,alloc_wgrect,send_all_redraws,wind0_draw
     XREF      menu_modify
     XREF      smalloc,smfree

* von STD

     XREF      fn_name


**********************************************************************
*
* char *_scan_alrts(a0 = char *alrts, a1 = OBJECT *tree,
*                   d0 = int firstob, d1 = int maxlen,
*                   d2 = int maxstrs)
*
* a0 : gibt String hinter den gescannten Bereich zurueck
* d0 : Anzahl Strings
* d1 : maximale Laenge
*

_scan_alrts:
 movem.l  d7/d6/d5/d3,-(sp)
 move.w   d1,d5                    ; maximale Stringlaenge
 move.w   d0,d7                    ; d7 ist Objektnummer
 moveq    #0,d1                    ; maximale Laenge
 moveq    #0,d3                    ; Anzahl Strings
 move.b   (a0)+,d0
 beq      _sca_ende                ; Fehler!
;cmpi.b   #'[',d0
;bne.b    _sca_ende                ; wegen Tempus nicht ueberprueft
_sca_next_string:
 move.w   d7,d6
 muls     #24,d6
 move.l   ob_spec(a1,d6.l),a2      ; a2 ist Zielstring
 moveq    #0,d6                    ; d6 ist Laenge
_sca_copy:
 move.b   (a0)+,d0
 beq.b    _sca_eos
 cmpi.b   #'|',d0
 beq.b    _sca_steuer
 cmpi.b   #']',d0
 beq.b    _sca_steuer
_sca_set:
 cmp.w    d5,d6
 bcc.b    _sca_copy                ; Ueberlauf
 move.b   d0,(a2)+
 addq.w   #1,d6
 bra.b    _sca_copy
_sca_eos:
 clr.b    (a2)
 addq.w   #1,d3
 cmp.w    d1,d6
 bls      _sca_ende
 move.w   d6,d1
 bra      _sca_ende
_sca_steuer:
 cmp.b    (a0)+,d0
 beq.b    _sca_set
 subq.l   #1,a0
 cmpi.b   #']',d0
 beq.b    _sca_eos
 cmp.w    d1,d6
 bls.b    _sca_nomax
 move.w   d6,d1
_sca_nomax:
 clr.b    (a2)
 addq.w   #1,d7
 addq.w   #1,d3
 cmp.w    d2,d3
 bls      _sca_next_string
_sca_ende:
 move.w   d3,d0
 movem.l  (sp)+,d3/d7/d6/d5
 rts


**********************************************************************
*
* init_alrt_tree(OBJECT *tree, int is_icon, int anz_t, int max_t,
*                              int anz_b, int max_b)
*
*    8(a6)          OBJECT *tree
*   $c(a6)          int    is_icon
*   $e(a6)          anz_t
*  $10(a6)          max_t
*  $12(a6)          anz_b
*  $14(a6)          max_b
*
* -$24(a6)          Breite des Icons (immer 4)
* -$22(a6)          Hoehe   des Icons (immer 4)
* -$20(a6)          GRECT fuer Textzeilen
* -$18(a6)          GRECT fuer Buttons
* -$10(a6)          GRECT fuer Icon
*   -8(a6)          GRECT fuer die Alertbox
*

init_alrt_tree:
 link     a6,#-$24
 movem.l  d4/d5/d6/d7/a5,-(sp)
 move.l   8(a6),a5                 ; a5 = tree
 move.w   #4,-$22(a6)
 move.w   #4,-$24(a6)
* Jeder Button wird auf die Breite des maximalen Buttons gebracht, innerhalb
* des Buttons ist je ein halbes Zeichen Rand links und rechts
* Zwischen je zwei Buttons sind 2 Zeichen Platz
* d6 wird die erforderliche Breite des Alerts in Zeicheneinheiten
 addq.w   #1,$14(a6)               ; 1 auf maximale Buttonlaenge addieren
                                   ;   fuer den Rand im Button selbst
 move.w   $14(a6),d7               ; d6 = max_buttons
 mulu     $12(a6),d7               ;      * anz_buttons
 move.w   d7,d4
 move.w   $12(a6),d0
 subq.w   #1,d0
 cmpi.w   #39,d7
 bhi.b    iat_wide1
 add.w    d0,d0                    ; ggf. 2 Zeichen Rand dazwischen
iat_wide1:
 add.w    d0,d4                    ; d4 = (max_b*anz_b)+(anz_b-1)*2
 move.w   $10(a6),d0
 move.w   d4,d1
 jsr      max
 move.w   d0,d6                    ; d6 = max(d4, max_t)
* mindestens die Hoehe einer Textzeile
* d5 wird die erforderliche Hoehe
 moveq    #1,d0
 move.w   $e(a6),d1
 addq.w   #1,d1                    ; oberste Zeile bleibt frei
 jsr      max
 move.w   d0,d5
* -8(a6) wird das GRECT
 lea      -8(a6),a0                ; GRECT fuer Hauptbox
 clr.l    (a0)+                    ; x,y = 0
 move.w   d6,(a0)                  ; Breite
 addq.w   #4,(a0)+                 ; + 2 (Rand fuer links) + 2 (rechts)
 move.w   d5,(a0)                  ; Hoehe

 lea      -$20(a6),a0              ; GRECT fuer Textzeilen
 move.l   #$20001,(a0)+            ; x = 2 Zeichen, y = 1 Zeichen
 move.w   $10(a6),(a0)+            ; w = max_t
 move.w   #1,(a0)                  ; h = 1

 tst.w    $c(a6)
 beq.b    iart_l1

* Icon ist gewuenscht

 lea      -$10(a6),a0              ; GRECT fuer Icon
 move.l   #$20001,(a0)+            ; x=2,y=1
 move.w   -$22(a6),(a0)+           ; w=4
 move.w   -$24(a6),(a0)            ; h=4

 move.w   -$22(a6),d0              ; Iconbreite
 addq.w   #2,d0                    ; + 2 Rand
 add.w    d0,-$20(a6)              ; Textposition nach rechts
 cmpi.w   #42,d7
 bhi.b    iat_wide2
 add.w    d0,-4(a6)                ; Gesamt- GRECT um Iconbreite+2 erhoehen
iat_wide2:
 move.w   -$24(a6),d0
 addq.w   #1,d0
 move.w   -2(a6),d1
 jsr      max
 move.w   d0,-2(a6)                ; Hoehe nur ggf. erhoehen

iart_l1:
 addq.w   #3,-2(a6)                ; Hoehe nochmals um 3 erhoehen, und zwar
                                   ; fuer Buttons und Rand ueber/unter Buttons
 move.w   -4(a6),d1                ; Gesamtbreite
 sub.w    d4,d1                    ; Breite der Buttonzeile abziehen
                                   ; es bleibt der Rand links und rechts
 lsr.w    #1,d1                    ; durch 2 teilen

 lea      -$18(a6),a0              ; GRECT fuer Buttons
 move.w   d1,(a0)+                 ; x = Rand links/rechts
 move.w   -2(a6),(a0)
 subq.w   #2,(a0)+                 ; y = Gesamthoehe - 2
 move.w   $14(a6),(a0)+            ; w = max_b
 move.w   #$0101,(a0)              ; h = 1 Zeichen + 1 Pixel

 lea      -8(a6),a1
 moveq    #0,d0
 move.l   a5,a0
 jsr      set_ob_xywh              ; GRECT fuer Hauptobjekt setzen

* fuer die Objekte 0..9 jeweils ob_head, ob_tail, ob_next loeschen

 moveq    #10,d0
 move.l   a5,a0
 jsr      kill_tree_structure

 tst.w    $c(a6)
 beq.b    iart_l2
* ein Icon ist erwuenscht
 lea      -$10(a6),a1
 moveq    #1,d0
 move.l   a5,a0
 jsr      set_ob_xywh              ; GRECT fuer Icon setzen

 moveq    #1,d1
 moveq    #0,d0
 move.l   a5,a0
 jsr      objc_add                 ; Objekt 1 ist das Icon

* Textzeilen setzen
iart_l2:
 clr.w    d6
 bra.b    iart_l4
iart_l3:

 lea      -$20(a6),a1              ; GRECT fuer Textzeile
 move.w   d6,d0
 addq.w   #2,d0                    ; ab Objekt 2
 move.l   a5,a0
 jsr      set_ob_xywh

 addq.w   #1,-$1e(a6)              ; GRECT.y erhoehen

 move.w   d6,d1
 addq.w   #2,d1
 moveq    #0,d0
 move.l   a5,a0
 jsr      objc_add                 ; Objekt einbauen

 addq.w   #1,d6
iart_l4:
 cmp.w    $e(a6),d6                ; naechste Textzeile
 blt.b    iart_l3

* Buttons einbauen

 clr.w    d6
 bra.b    iart_l6
iart_l5:
 movea.l  a5,a0
 move.w   d6,d1
 addq.w   #7,d1                    ; ab Objekt 7
 muls     #24,d1
 adda.l   d1,a0
 move.w   #SELECTABLE+EXIT+FL3DACT,ob_flags(a0)
 clr.w    $a(a0)

 lea      -$18(a6),a1              ; GRECT fuer Buttons
 move.w   d6,d0
 addq.w   #7,d0
 move.l   a5,a0
 jsr      set_ob_xywh

 move.w   $14(a6),d0               ; max_b
 addq.w   #1,d0
 cmpi.w   #39,d7
 bhi.b    iat_wide3
 addq.w   #1,d0                    ; +2 (Rand rechts)
iat_wide3:
 add.w    d0,-$18(a6)              ; auf x addieren

 move.w   d6,d1
 addq.w   #7,d1                    ; ab Objekt 7
 moveq    #0,d0
 move.l   a5,a0
 jsr      objc_add

 addq.w   #1,d6
iart_l6:
 cmp.w    $12(a6),d6
 blt.b    iart_l5
 movea.l  a5,a0
 move.w   $12(a6),d1               ; anz_b
 addq.w   #6,d1                    ; + 1 (Icon) + 5 (Textzeilen)
 muls     #$18,d1
 move.w   #SELECTABLE+EXIT+LASTOB+FL3DACT,ob_flags(a0,d1.l)
 movem.l  (sp)+,a5/d7/d4/d6/d5
 unlk     a6
 rts


**********************************************************************
*
* void draw_n_objects( a0 = OBJECT *tree, d0 = int n,
*                        a1 = int objx[] )
*
* Zeichnet Unterobjekte, jeweils ab Wurzel.
* Das Unterobjekt muss auf Stufe #1 liegen
*

draw_n_objects:
 movem.l  a5/a4/d7,-(sp)
 suba.w   #16,sp                   ; altes Clipping-GRECT
 move.l   a0,a5
 move.l   a1,a4
 move.w   d0,d7
 lea      (sp),a0
 jsr      get_clip_grect           ; Clipping retten
 bra.b    dno_start
dno_loop:
 move.w   (a4)+,d0                 ; Objektnummer ?
 beq.b    dno_start                ; ungueltig
; GRECT des Objekts bestimmen
 mulu     #24,d0
 lea      ob_x(a5,d0.w),a0
 move.l   (a0)+,g_x+8(sp)          ; x/y
 move.l   (a0),g_w+8(sp)           ; w/h
 move.w   ob_x(a5),d0
 add.w    d0,g_x+8(sp)
 move.w   ob_y(a5),d0
 add.w    d0,g_y+8(sp)
 lea      8(sp),a0
 jsr      set_clip_grect           ; neuen Clippingbereich setzen
; Objekt zeichnen
 moveq    #8,d1                    ; Tiefe 8
 moveq    #0,d0                    ; ab Objekt 0
 move.l   a5,a0
 jsr      _objc_draw               ; Box ausgeben
; naechstes Objekt
dno_start:
 dbra     d7,dno_loop
 lea      (sp),a0
 jsr      set_clip_grect           ; Clipping zurueck
 adda.w   #16,sp
 movem.l  (sp)+,a5/a4/d7
 rts


**********************************************************************
*
* int _form_popup( a0 = OBJECT *ob, d0 = {int x; int y} )
*
* PUREC WORD _form_popup( OBJECT *ob,  LONG xy )
*
* Die Box darf nicht links oder oberhalb des Bildschirms liegen, sie
* wird in diesem Fall umgesetzt.
* Sind x und y Null, wird die Position nicht beeinflusst.
*

_form_popup:
 suba.l   a1,a1               ; kein Scrolling
;bra.b    xfrm_popup


**********************************************************************
*
* int xfrm_popup(   a0 = OBJECT *ob, d0 = {int x; int y},
*                   d1 = int firstscrlobj, d2 = int lastscrlobj,
*                   a1 = cdecl init_objs(OBJECT *tree,
*                                  int scrloffs,
*                                  int nlines,
*                                  void *param ),
*                   void *param,
*                   int nlines,
*                   int *lastscrl,
*                   int fixed_buf )
*
* Die Box darf nicht links oder oberhalb des Bildschirms liegen, sie
* wird in diesem Fall umgesetzt.
* Sind x und y Null, wird die Position nicht beeinflusst.
*
*    8(a6)     : void *param
*    12(a6)    : int nlines        tatsaechliche Anzahl Zeilen
*    14(a6)    : int *retscrl      zur Rueckgabe der Scrollposition
*
*      d7      : int  ob,     aktuelle Objektnummer
*      d6      : int  obo,    vorherige Objektnummer
*      d5      : char valid,  Flag fuer "aktuelle Objektnummer gueltig"
*      d4      : char valido, Flag fuer "vorherige Objektnummer gueltig"
*      d3      : int bstat,   erwarteter Maustastenstatus
* -52(a6)      : int fixedb,  Flag "festen Puffer verwenden"
* -50(a6)      : void *sbuf,  geretteter Bildschirminhalt
* -46(a6)      : int lheight, Hoehe einer Zeile (fuer Scrolling)
* -44(a6)      : int yblpix,  soviele Pixel sind immer zu blitten
* -42(a6)      : int maxscrl, soviel kann ich scrollen
* -40(a6)      : int scrlpos, akt. Scrollposition
* -36(a6)      : int first
* -38(a6)      : int last     Scrollobjektnummern
* -34(a6)      : init_objs,   Routine zum Scrollen
* -30(a6)      : int out[6],  Rueckgabe von _evnt_multi
*                -30(a6)      x
*                -28(a6)      y
*                -26(a6)      bstate
*                -24(a6)      kstate
*                -22(a6)      key
*                -20(a6)      nclicks
*  -18(a6)     : MGRECT mg
*   -8(a6)     : GRECT out,   Aussenmasse des Menues einschl. Rand usw.
*

xfrm_popup:
 link     a6,#-52
 movem.l  d3/d4/d5/d6/d7/a2/a3/a4/a5,-(sp)

 move.l   a0,a5                    ; a5 = OBJECT *

; Initialialisierung fuers Scrolling

 clr.w    -52(a6)                  ; default: keinen festen Puffer verwenden
 move.l   a1,-34(a6)               ; Scrollroutine
 beq.b    xf_noscrli               ; keine, nix sonst initialisieren
 move.w   d1,-36(a6)               ; erstes Scrollobjekt
 move.w   d2,-38(a6)               ; letztes Scrollobjekt
 sub.w    d1,d2
 addq.w   #1,d2                    ; soviele Zeilen sind sichtbar
 move.w   12(a6),d1
 sub.w    d2,d1
 move.w   d1,-42(a6)               ; soviel kann ich scrollen

 subq.w   #3,d2                    ; soviele Zeilen sind immer zu blitten
 move.w   -36(a6),d1               ; erstes Scrollobjekt
 mulu     #24,d1
 move.w   ob_height(a5,d1.w),-46(a6)    ; Hoehe einer Zeile
 mulu     -46(a6),d2               ; soviele Pixel sind immer zu blitten
 move.w   d2,-44(a6)

 move.l   14(a6),a0
 move.w   (a0),-40(a6)             ; Scrollpos initialisieren
 move.w   16(a6),-52(a6)           ; Flag "festen Puffer verwenden"
xf_noscrli:

; Ende der Initialisierung fuers Scrolling

 move.w   gr_mkmstate,d3           ; Maustastenstatus
 andi.w   #1,d3                    ; nur linke Taste
 eori.w   #1,d3                    ; warte auf Aenderung dieser Taste

 lea      -8(a6),a4
 lea      -18(a6),a3               ; MGRECT
 tst.l    d0
 beq.b    xf_nokoor

 move.w   d0,ob_y(a5)              ; y
 subq.w   #4,ob_y(a5)
 swap     d0
 move.w   d0,ob_x(a5)              ; x
 move.w   ob_width(a5),d0
 lsr.w    #1,d0                    ; halbe Breite
 sub.w    d0,ob_x(a5)

xf_nokoor:
 move.l   a4,a1
 move.l   a5,a0
 jsr      calc_obsize

 move.w   desk_g+g_x,d0
 sub.w    (a4),d0                  ; x
 ble.b    xf_noxn
* x ist kleiner als Null. Box linksbuendig machen
 add.w    d0,(a4)
 add.w    d0,ob_x(a5)
xf_noxn:
 move.w   desk_g+g_y,d0
 sub.w    g_y(a4),d0               ; y
 ble.b    xf_noyn
* y ist kleiner als der Bildschirm. Box topbuendig machen
 add.w    d0,g_y(a4)
 add.w    d0,ob_y(a5)
xf_noyn:

 move.w   desk_g+g_x,d0
 add.w    desk_g+g_w,d0
 sub.w    (a4),d0
 sub.w    g_w(a4),d0
 bge.b    xf_noxp
 add.w    d0,(a4)
 add.w    d0,ob_x(a5)
xf_noxp:
 move.w   desk_g+g_y,d0
 add.w    desk_g+g_h,d0
 sub.w    g_y(a4),d0
 sub.w    g_h(a4),d0
 bge.b    xf_noyp
 add.w    d0,g_y(a4)
 add.w    d0,ob_y(a5)
xf_noyp:


 moveq    #0,d0                    ; kein check and set
 jsr      beg_mctrl                ; Bildschirm sperren

 move.l   a4,a0                    ; Dialoggroesse
 tst.w    -52(a6)                  ; fester Puffer ?
 beq.b    xf_no_fixb1              ; nein
 bsr      fast_save_scr
 bra.b    xf_no_fixb2
xf_no_fixb1:
 lea      -50(a6),a1               ; Bildschirmpuffer-Adresse
 bsr      scrg_sav                 ; Hintergrund retten
xf_no_fixb2:

 move.l   a4,a0
 jsr      set_clip_grect           ; neuen Clippingbereich setzen

* Box scrollbar => initialisieren

 move.l   -34(a6),d0
 beq.b    xf_no_scrl1
 move.l   d0,a2
 move.l   8(a6),-(sp)              ; param
 move.w   12(a6),-(sp)             ; Anz. Zeilen
 move.w   -40(a6),-(sp)            ; Scrollpos
 move.l   a5,-(sp)                 ; OBJECT *
 jsr      (a2)                     ; initialisieren
 lea      12(sp),sp

* Box zeichnen

xf_no_scrl1:
 moveq    #8,d1                    ; Tiefe 8
 moveq    #0,d0                    ; ab Objekt 0
 move.l   a5,a0
 jsr      _objc_draw               ; Box ausgeben

/*
 jsr      save_mouse               ; Mausdaten merken
*/

* "Dialog"

; bsr     wait_but_released
 moveq    #-1,d7                   ; vorheriges ungueltig

**
*
* Die grosse Schleife
*
**

xf_loop:
 move.w   d5,d4
 move.w   d7,d6
 bgt.b    xf_wait_exit             ; ueber Eintrag, warten auf Verlassen

* Wir schweben ueber einem ungueltigen Eintrag und warten darauf, dass wir
* in das Menue hineinkommen

 moveq    #0,d1                    ; warten auf Betreten
 moveq    #0,d0                    ; objnr 0
 bra.b    xf_wait

* Wir schweben ueber einem gueltigen Eintrag und warten auf Verlassen
* dieses Eintrags oder des Menues

xf_wait_exit:
 moveq    #1,d1                    ; warten auf Verlassen
 move.w   d7,d0                    ; objnr d7

* beide Faelle:

xf_wait:
 move.l   a3,a1                    ; MGRECT *mg
 move.l   a5,a0                    ; OBJECT *tree
 bsr      objc2mgrect

 pea      -30(a6)                  ; Ausgabearray
 clr.l    -(sp)                    ; mbuf (fuer mesag)
;move.l   #$10101,-(sp)            ; st=1(gedrueckt),msk=1(linke),n=1
 move.l   #$10100,d0
 or.w     d3,d0                    ; erwarteten Maustatus dazumischen
 move.l   d0,-(sp)
 pea      250                      ; 250 ms (fuer Autoscroll-Timer)
 clr.l    -(sp)                    ; GRECT *mm2
 move.l   a3,-(sp)                 ; GRECT *mm1
 move.w   #6,-(sp)                 ; mtypes = MU_BUTTON+MU_M1
; Autoscrolling ?
 tst.l    -34(a6)                  ; Menue scrollbar ?
 beq.b    xf_no_scrl2              ; nein
 cmp.w    -36(a6),d7               ; Maus ueber erstem Scrollobjekt ?
 bne.b    xf_sweiter               ; nein
 tst.w    -40(a6)                  ; Menue schon ganz nach oben gescrollt ?
 beq.b    xf_no_scrl2              ; ja
 bra.b    xf_scrl                  ; nein, kann noch scrollen
xf_sweiter:
 cmp.w    -38(a6),d7               ; Maus ueber letztem Scrollobjekt ?
 bne.b    xf_no_scrl2              ; nein
 move.w   -40(a6),d0               ; soviel habe ich gescrollt
 cmp.w    -42(a6),d0               ; soviel kann ich noch scrollen
 bge.b    xf_no_scrl2              ; habe schon nach unten gescrollt
xf_scrl:
; Warte auf Timer fuers Scrolling
 ori.w    #EV_TIM,(sp)
xf_no_scrl2:
 jsr      _evnt_multi
 adda.w   #$1a,sp
 btst     #EVB_TIM,d0              ; Timer vom Autoscrolling ?
 beq      xf_didnotscroll

* TIMER ist eingetroffen. Wir muessen scrollen
* wir zeichnen maximal 3 Objekte neu, Objektnummern auf den Stack.
* Wenn nicht zeichnen, objnr = 0

xf_scroll_now:
 move.w   d0,-(sp)
 clr.l    -(sp)                    ; zwei Objekte zum Neuzeichnen
 move.w   -42(a6),d1               ; soviel kann ich scrollen
 cmp.w    -38(a6),d7               ; Maus ueber letztem Scrollobjekt ?
 beq.b    xf_runter                ; ja

; ## 1. ##
; Scrollpfeil nach oben, d.h. erstes Scroll-Objekt
; Scrolle runter, d.h. (scroll--)

 cmp.w    -40(a6),d1               ; war vorher Anschlag ?
 bne.b    xf_no2                   ; nein
 move.w   -38(a6),2(sp)            ; unteren Pfeil neu zeichnen
xf_no2:
 move.w   -36(a6),-(sp)
 addq.w   #1,(sp)                  ; firstob+1 neu zeichnen
 subq.w   #1,-40(a6)               ; neue Scrollpos.
 bne.b    xf_beide                 ; ist nicht 0, d.h. firstob nicht neu
 move.w   -36(a6),2(sp)            ; zeichne firstob neu
 bra.b    xf_beide

; ## 2. ##
; Scrollpfeil nach unten, d.h. letztes Scroll-Objekt
; Scrolle hoch, d.h. (scroll++)

xf_runter:
 tst.w    -40(a6)                  ; bisher nicht gescrollt ?
 bne.b    xf_no1                   ; doch, oberer Pfeil ist schon da
 move.w   -36(a6),2(sp)            ; oberen Pfeil neu zeichnen
xf_no1:
 move.w   -38(a6),-(sp)
 subq.w   #1,(sp)                  ; lastscrollob-1 neu zeichnen
 addq.w   #1,-40(a6)               ; neue Scrollpos. (hoch scrollen)
 cmp.w    -40(a6),d1               ; jetzt Anschlag ?
 bne.b    xf_beide                 ; nein lastscrollob nicht neu zeichnen
 move.w   -38(a6),2(sp)            ; doch, lastscrollob neu zeichnen

; ## beide ##

xf_beide:
; Objekte umsetzen
 move.l   8(a6),-(sp)              ; param
 move.w   12(a6),-(sp)             ; Anz. Zeilen
 move.w   -40(a6),-(sp)            ; Scrollpos
 move.l   a5,-(sp)                 ; OBJECT *
 move.l   -34(a6),a2
 jsr      (a2)                     ; initialisieren
 lea      12(sp),sp
; Scrolling (Bitblt)
 move.w   -44(a6),-(sp)            ; h: ((visob-3) * Hoehe eines Objekts)
 move.w   ob_width(a5),-(sp)       ; w: Breite des Menues
 move.w   -36(a6),d0
 addq.w   #1,d0
 mulu     #24,d0
 move.w   ob_y(a5,d0.w),d0         ; y-Pos. von firstob+1
 add.w    ob_y(a5),d0              ; + y-Pos des parent
 move.w   d0,d1
 add.w    -46(a6),d1               ; y-Pos von firstob+2
 cmp.w    -36(a6),d7               ; Maus ueber erstem Scrollobjekt ?
 bne.b    xf_hoch1                 ; ja
; war Scrollpfeil nach unten
 exg      d0,d1
xf_hoch1:
 move.w   d0,-(sp)                 ; dst_y
 move.w   ob_x(a5),-(sp)           ; dst_x
 move.w   d1,-(sp)                 ; src_y
 move.w   ob_x(a5),-(sp)           ; src_x
 jsr      blitcopy_rectangle
 adda.w   #12,sp

* Neuzeichnen von maximal 3 Objekten. Die Objektnummern liegen
  * auf dem Stack

 lea      (sp),a1                  ; Tabelle
 moveq    #3,d0                    ; Tabellenlaenge
 move.l   a5,a0
 bsr      draw_n_objects           ; Objekte zeichnen
 addq.l   #6,sp                    ; Stack aufraeumen
 move.w   (sp)+,d0 

* Ende der Scrollbehandlung

xf_didnotscroll:
 btst     #EVB_BUT,d0              ; MU_BUTTON ?
 bne      xf_button                ; ja, Schleife beenden
 btst     #EVB_MG1,d0
 beq      xf_loop
* MU_M1 ist eingetroffen

 move.l   -30(a6),d2               ; x,y
 moveq    #8,d1                    ; depth
 moveq    #0,d0                    ; ab Objekt 0
 move.l   a5,a0
 jsr      _objc_find

 move.w   d0,d7
 bmi.b    xf_abled                 ; nicht gefunden, d7 = -1
 muls     #24,d0
 btst     #0,ob_flags+1(a5,d0.l)   ; SELECTABLE ?
 sne.b    d5                       ; ja, ok
 beq.b    xf_abled                 ; nein
 btst     #3,ob_state+1(a5,d0.l)   ; DISABLED ?
 seq.b    d5                       ; nein, ok
xf_abled:
 cmp.w    d6,d7                    ; Position geaendert ?
 beq.b    xf_nochg
 tst.w    d6
 bmi.b    xf_noold
 tst.b    d4
 beq.b    xf_noold
 moveq    #0,d1                    ; deselektieren
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; OBJECT *tree
 bsr      _select
xf_noold:
 tst.w    d7
 bmi.b    xf_nochg
 tst.b    d5
 beq.b    xf_nochg
 moveq    #1,d1                    ; selektieren
 move.w   d7,d0                    ; objnr
 move.l   a5,a0                    ; OBJECT *tree
 bsr.s    _select
xf_nochg:
 bra      xf_loop

*
* Die Maustaste ist gedrueckt (bzw. losgelassen) worden.
* Wenn der Mauszeiger ueber einem Scrollpfeil war, wird
* gescrollt, ansonsten die Schleife beendet.
*

xf_button:
 tst.w    d7
 bsr      wait_but_released

 tst.l    -34(a6)                  ; Menue scrollbar ?
 beq.b    xf_endloop               ; nein
 cmp.w    -36(a6),d7               ; Maus ueber erstem Scrollobjekt ?
 bne.b    xf_bweiter               ; nein
 tst.w    -40(a6)                  ; Menue schon ganz nach oben gescrollt ?
 beq.b    xf_endloop               ; ja
xf_scrlnw:
 moveq    #0,d0
 bra      xf_scroll_now            ; nein, kann noch scrollen
xf_bweiter:
 cmp.w    -38(a6),d7               ; Maus ueber letztem Scrollobjekt ?
 bne.b    xf_endloop               ; nein
 move.w   -40(a6),d0               ; soviel habe ich gescrollt
 cmp.w    -42(a6),d0               ; soviel kann ich noch scrollen
 bcs.b    xf_scrlnw                ; kann noch scrollen

xf_endloop:
/*
 jsr      restore_mouse            ; Mausdaten reaktivieren
*/

 tst.w    -52(a6)                  ; fester Puffer ?
 beq.b    xf_no_fixb3              ; nein
 bsr      restore_scr
 bra.b    xf_no_fixb4
xf_no_fixb3:
 lea      -50(a6),a0               ; Bildschirmhintergrund
 bsr      scrg_rst                 ; restaurieren
xf_no_fixb4:

 moveq    #0,d0                    ; kein check and set
 jsr      end_mctrl                ; Bildschirm freigeben

 moveq    #-1,d0                   ; Rueckgabewert erstmal ungueltig
 tst.w    d7                       ; gueltig
 bmi.b    xf_ende                  ; ausserhalb
 tst.b    d5                       ; gueltig ?
 beq.b    xf_ende                  ; nein
 move.w   d7,d0                    ; Rueckgabewert
 muls     #24,d7
 bclr     #0,ob_state+1(a5,d7.l)   ; deselektieren
 tst.l    -34(a6)                  ; Menue scrollbar ?
 beq.b    xf_ende                  ; nein
 move.l   14(a6),a0
 move.w   -40(a6),(a0)             ; Scrollpos zurueckgeben
xf_ende:
 movem.l  (sp)+,d3/d4/d5/d6/d7/a2/a3/a4/a5
 unlk     a6
 rts


_select:
 move.w   #1,-(sp)                 ; nicht malen, wenn DISABLED
 move.w   #2,-(sp)                 ; immer malen
 move.w   d1,d2                    ; active
 moveq    #1,d1                    ; statemask SELECTED
;move.w   d0,d0                    ; objnr
;move.l   a0,a0                    ; OBJECT *tree
 jsr      menu_modify
 addq.l   #4,sp
 rts


**********************************************************************
*
* (nur von form_alert() aufgerufen)
*

__set_under:
 move.l   ob_spec(a4),a0           ; Zeichenkette
alrt_under_chloop:
 move.b   (a0)+,d0                 ; Zeichen d0 unterstreichen?
 beq.b    alrt_under_end           ; keins mehr da
 cmpi.b   #' ',d0                  ; Leerzeichen ueberspringen
 beq.b    alrt_under_chloop
 jsr      toupper                  ; in Grossschrift wandeln
* Pruefe Zeichen d0 auf Kollision mit den vorherigen Buttons
 lea      UNDER_CH(a6),a1
alrt_used_loop:
 move.b   (a1)+,d1
 beq.b    alrt_set_under           ; Listenende erreicht
 cmp.b    d1,d0                    ; Zeichen schon verwendet?
 bne.b    alrt_used_loop           ; nein, weitersuchen
 bra.b    alrt_under_chloop        ; schon verwendet, naechstes Zeichen
* Unterstrich setzen
alrt_set_under:
 move.b   d0,-(a1)                 ; Zeichen merken
 subq.l   #1,a0
 suba.l   ob_spec(a4),a0
 move.l   a0,d0                    ; Zeichenposition berechnen
 lsl.w    #8,d0                    ; Position des Unterstrichs
 ori.w    #WHITEBAK,d0
 or.w     d0,ob_state(a4)          ; Unterstrich aktivieren
alrt_under_end:
 rts


UNDER_CH  SET  -4                  ; char[4]: Zeichen fuer Alt-<ch>
ICON_NR   SET  UNDER_CH-2          ; int,   Iconnummer
LINE_CNT  SET  ICON_NR-2           ; int,   Anzahl Textzeilen
LINE_WID  SET  LINE_CNT-2          ; int,   maximale Textzeilenbreite
BUTT_CNT  SET  LINE_WID-2          ; int,   Anzahl Buttons
BUTT_WID  SET  BUTT_CNT-2          ; int,   maximale Buttonbreite
FLYINF    SET  BUTT_WID-4          ; void*  fuer Flydials
SVD_GRECT SET  FLYINF-8            ; GRECT, geretteter Bildschirmbereich
DLG_GRECT SET  SVD_GRECT-8         ; GRECT, Dialogboxgroesse
SVD_CLIP  SET  DLG_GRECT-8         ; GRECT, geretteter Clippingbereich
TREE      SET  SVD_CLIP-240-270    ; 24 Objekte+5 Textzeilen+3 Buttons

form_alert:
 link     a6,#TREE
 movem.l  a4/a5/d6/d7,-(sp)
 move.w   d0,d6
 move.l   a0,a4
 clr.l    UNDER_CH(a6)             ; noch keine Unterstriche

* Objektbaumadresse der Alertbox nach a5, relozieren

 lea      TREE(a6),a5
;lea      popup_tmp,a5

 move.w   #alert_tree_end-alert_tree,d0
 move.l   a5,a0
 lea      alert_tree(pc),a1
 jsr      vmemcpy

 move.b   #1,ob_spec+1(a5)         ; Aussenrand normalerweise 1
 tst.w    enable_3d
 beq.b    alrt_2d
 addq.b   #1,ob_spec+1(a5)         ; Aussenrand 2, wenn 3D
alrt_2d:
 moveq    #8-1,d1                  ; 5 Strings + 3 Buttons
 lea      48(a5),a1                ; BOX und Icon ueberspringen
alrt_relo_loop:
 move.l   a5,d0
 add.l    d0,ob_spec(a1)           ; relozieren
 lea      24(a1),a1
 dbra     d1,alrt_relo_loop

 move.l   a4,a0                    ; a0 = alrts
* Iconnummer
 moveq    #0,d0
 move.b   1(a0),d0                 ; Icontyp
 subi.w   #'0',d0                  ; auf 0,1,2,3 reduzieren
 cmpi.w   #3,d0
 bls.b    sca_ok
 moveq    #1,d0                    ; Icon fehlerhaft => Icon 1
sca_ok:
 move.w   d0,ICON_NR(a6)           ; Iconnummer
* ab Offset 4 durchsuchen
 addq.l   #3,a0                    ; ab alrts+3 scannen

* Text scannen

 moveq    #5,d2                    ; Maximal 5 Zeilen
 moveq    #40,d1                   ; Maximal 40 Zeichen (Original: 31)
 moveq    #2,d0                    ; in <tree> ab Objekt 2 setzen
 move.l   a5,a1                    ; tree
;move.l   a0,a0                    ; alrts
 bsr      _scan_alrts
;move.l   a0,a0
 move.w   d0,LINE_CNT(a6)
 move.w   d1,LINE_WID(a6)

* Buttons scannen

 moveq    #3,d2                    ; maximal 3 Buttons
 moveq    #20,d1                   ; maximal 20 Zeichen (Original: 10)
 moveq    #7,d0                    ; in <tree> ab Objekt 7 setzen
 move.l   a5,a1
;move.l   a0,a0
 bsr      _scan_alrts
 move.w   d0,BUTT_CNT(a6)
 move.w   d1,BUTT_WID(a6)


 move.w   BUTT_WID(a6),-(sp)       ; maximale Buttonbreite
 move.w   BUTT_CNT(a6),-(sp)       ; Anzahl Buttons
 move.w   LINE_WID(a6),-(sp)       ; maximale Textzeilenbreite
 move.w   LINE_CNT(a6),-(sp)       ; Anzahl Textzeilen
 move.w   ICON_NR(a6),-(sp)        ; Icon
 move.l   a5,-(sp)                 ; tree
 bsr      init_alrt_tree
 lea      14(sp),sp

* Defaultbutton setzen

 move.w   d6,d0                    ; Defaultbutton ?
 beq.b    alrt_no_defbut           ; nein
 addq.w   #6,d0
 mulu     #24,d0
 lea      0(a5,d0.l),a4            ; Button-Objekt
 ori.w    #DEFAULT,ob_flags(a4)
 bsr      __set_under              ; Unterstrich festlegen

* Unterstriche setzen

alrt_no_defbut:
 moveq    #0,d7                    ; 1. Button
alrt_under_loop:
 move.w   d7,d0
 addq.w   #7,d0                    ; Button-Objekte sind 7..9
 mulu     #24,d0
 lea      0(a5,d0.l),a4            ; a4 = aktuell untersuchter Button
 btst.b   #WHITEBAK_B,ob_state+1(a4)    ; schon Unterstrich gesetzt ?
 bne.b    alrt_under_nextbut       ; ja, naechster Button
 bsr      __set_under              ; Unterstrich festlegen
alrt_under_nextbut:
 addq.w   #1,d7                    ; naechster Button
 cmp.w    BUTT_CNT(a6),d7          ; gueltig ?
 bcs.b    alrt_under_loop

* Icon setzen

 move.w   ICON_NR(a6),d0           ; Icon erwuenscht ?
 beq.b    alrt_no_icon             ; nein
 subq.w   #1,d0
 mulu     #14,d0                   ; sizeof(BITBLK)
 lea      bitblk_note(pc),a0
 add.w    d0,a0
 move.l   a0,24+ob_spec(a5)        ; Icon auf BITBLK setzen

* Alert von Zeichen- auf Pixelkoordinaten umsetzen

alrt_no_icon:
 moveq    #0,d7
alrt_obfix_loop:
 move.w   d7,d0
 move.l   a5,a0
 jsr      rsrc_obfix
 addq.w   #1,d7
 cmp.w    #10,d7
 bcs.b    alrt_obfix_loop

 move.l   #$200020,24+ob_width(a5) ; Breite/Hoehe des Icons = 32 Pixel

 lea      DLG_GRECT(a6),a1         ; hier kommt das GRECT hin
 move.l   a5,a0
 jsr      _form_center             ; Dialog zentrieren

 move.l   DLG_GRECT(a6),SVD_GRECT(a6)
 move.l   DLG_GRECT+4(a6),SVD_GRECT+4(a6)

 jsr      update_1                 ; Bildschirm sperren

 lea      SVD_CLIP(a6),a0
 jsr      get_clip_grect           ; aktuellen Clippingbereich retten

 lea      FLYINF(a6),a2            ; Fuer den etv_critic per Malloc holen
 tst.b    no_switch                ; bin ich im etv_critic ?
 bne.b    fa_critic                ; ja, Puffer per Malloc !
 move.l   #scrbuf,(a2)
 lea      -1,a2                    ; internen Puffer verwenden
fa_critic:
 lea      SVD_GRECT(a6),a1         ; Dialoggroesse
 moveq    #0,d0
 bsr      __fm_xdial               ; schneidet automatisch mit Schirm

 lea      DLG_GRECT(a6),a0
 jsr      set_clip_grect           ; neuen Clippingbereich setzen

 moveq    #8,d1                    ; Tiefe 8
 moveq    #0,d0                    ; ab Objekt 0
 move.l   a5,a0
 jsr      _objc_draw               ; Box ausgeben

 move.w   #258,d0                  ; M_SAVE
 bsr      graf_mouse               ; Maus retten
 moveq    #0,d0
 bsr      graf_mouse               ; Maus als Pfeil
 tst.w    moff_cnt
 beq.b    fa_ok1
 jsr      mouse_immed              ; Einschalten erzwingen
fa_ok1:

 move.l   FLYINF(a6),a2            ; flyinf bzw. #scrbuf
 lea      alrt_keys(pc),a1
;suba.l   a1,a1
 move.l   a5,a0
 moveq    #0,d0
 bsr      _form_xdo                ; Dialog ausfuehren

 move.w   d0,d7
 and.w    #$7fff,d7                ; Rueckgabe merken, Doppelklickbit loeschen

 bsr      reset_mouse              ; Hide- Counter wieder in Ordnung bringen
 move.w   #259,d0                  ; M_RESTORE
 bsr      graf_mouse               ; Maus wiederherstellen

 lea      DLG_GRECT(a6),a0
 jsr      set_clip_grect           ; neuen Clippingbereich setzen

 lea      -1,a2
 tst.b    no_switch

 beq.b    fa_nocritic
 lea      FLYINF(a6),a2
fa_nocritic:
 lea      DLG_GRECT(a6),a1
 moveq    #3,d0
 bsr      __fm_xdial

 lea      SVD_CLIP(a6),a0
 jsr      set_clip_grect           ; geretteten Clippingbereich zurueck

 jsr      update_0                 ; Bildschirm freigeben

 move.w   d7,d0
 subq.w   #6,d0                    ; Buttonnummer zurueckgeben
 movem.l  (sp)+,d7/d6/a5/a4
 unlk     a6
 rts


/* am 30.9.98 entfernt, da jetzt Buttons unterstrichen werden
   am 6.3 auf Wunsch von Oliver wieder aktiviert */

alrt_keys:
 DC.L     alrt_unsh_keys           ; unshift
 DC.L     0                        ; shift
 DC.L     0                        ; ctrl
 DC.L     0                        ; alt
 DC.L     0                        ; (Filter)

alrt_unsh_keys:
 DC.B     $3b,1,0,7
 DC.B     $3c,1,0,8
 DC.B     $3d,1,0,9
 DC.W     0


alert_tree:
 DC.W     -1,1,9                   ; 0: umgebende Box
 DC.W     G_BOX,FL3DBAK,OUTLINED
 DC.L     $11100
 DC.W     12,1538,57,15

 DC.W     2,-1,-1                  ; 1: Icon
 DC.W     G_IMAGE,0,0
 DC.L     0                        ; Zeiger auf BITBLK hier einsetzen!
 DC.W     3,1,6,2

 DC.W     3,-1,-1                  ; 2: Textzeile 1
 DC.W     G_STRING,0,0
 DC.L     alert_tree_end-alert_tree
 DC.W     3,3,40,1

 DC.W     4,-1,-1                  ; 3: Textzeile 2
 DC.W     G_STRING,0,0
 DC.L     alert_tree_end-alert_tree+41
 DC.W     3,4,40,1

 DC.W     5,-1,-1                  ; 4: Textzeile 3
 DC.W     G_STRING,0,0
 DC.L     alert_tree_end-alert_tree+82
 DC.W     3,5,40,1

 DC.W     6,-1,-1                  ; 5: Textzeile 4
 DC.W     G_STRING,0,0
 DC.L     alert_tree_end-alert_tree+123
 DC.W     3,6,40,1

 DC.W     7,-1,-1                  ; 6: Textzeile 5
 DC.W     G_STRING,0,0
 DC.L     alert_tree_end-alert_tree+164
 DC.W     3,7,40,1

 DC.W     8,-1,-1                  ; 7: Button 1
 DC.W     G_BUTTON,6+FL3DACT,0
 DC.L     alert_tree_end-alert_tree+205
 DC.W     3,9,20,$0101             ; eine Zeichenhoehe plus ein Pixel

 DC.W     9,-1,-1                  ; 8: Button 2
 DC.W     G_BUTTON,6+FL3DACT,0
 DC.L     alert_tree_end-alert_tree+226
 DC.W     3,11,20,$0101

 DC.W     0,-1,-1                  ; 9: Button 3
 DC.W     G_BUTTON,$26+FL3DACT,0
 DC.L     alert_tree_end-alert_tree+247
 DC.W     3,13,20,$0101

alert_tree_end:

bitblk_note:
 DC.L     image_note     ; Imagedaten
 DC.W     4              ; Breite 4 Bytes
 DC.W     32             ; Hoehe 32 Pixel
 DC.W     0              ; x
 DC.W     0              ; y
 DC.W     LRED

bitblk_wait:
 DC.L     image_wait
 DC.W     4
 DC.W     32
 DC.W     0
 DC.W     0
 DC.W     LRED

bitblk_stop:
 DC.L     image_stop
 DC.W     4
 DC.W     32
 DC.W     0
 DC.W     0
 DC.W     LRED

image_note:
 DC.L     %00000000000000111100000000000000
 DC.L     %00000000000001100110000000000000
 DC.L     %00000000000011011011000000000000
 DC.L     %00000000000110111101100000000000
 DC.L     %00000000001101111110110000000000
 DC.L     %00000000011011111111011000000000
 DC.L     %00000000110111000011101100000000
 DC.L     %00000001101111000011110110000000
 DC.L     %00000011011111000011111011000000
 DC.L     %00000110111111000011111101100000
 DC.L     %00001101111111000011111110110000
 DC.L     %00011011111111000011111111011000
 DC.L     %00110111111111000011111111101100
 DC.L     %01101111111111000011111111110110
 DC.L     %11011111111111000011111111111011
 DC.L     %10111111111111000011111111111101
 DC.L     %10111111111111000011111111111101
 DC.L     %11011111111111000011111111111011
 DC.L     %01101111111111000011111111110110
 DC.L     %00110111111111000011111111101100
 DC.L     %00011011111111111111111111011000
 DC.L     %00001101111111111111111110110000
 DC.L     %00000110111111000011111101100000
 DC.L     %00000011011111000011111011000000
 DC.L     %00000001101111000011110110000000
 DC.L     %00000000110111000011101100000000
 DC.L     %00000000011011111111011000000000
 DC.L     %00000000001101111110110000000000
 DC.L     %00000000000110111101100000000000
 DC.L     %00000000000011011011000000000000
 DC.L     %00000000000001100110000000000000
 DC.L     %00000000000000111100000000000000

image_wait:
 DC.L     %00111111111111111111111111111100
 DC.L     %11000000000000000000000000000011
 DC.L     %10011111111111111111111111111001
 DC.L     %10111111111111111111111111111101
 DC.L     %11011111111110000011111111111011
 DC.L     %01011111111000000000111111111010
 DC.L     %01101111110000000000011111110110
 DC.L     %00101111100000111000001111110100
 DC.L     %00110111100001111100001111101100
 DC.L     %00010111100001111100001111101000
 DC.L     %00011011111111111000001111011000
 DC.L     %00001011111111110000011111010000
 DC.L     %00001101111111100000111110110000
 DC.L     %00000101111111000001111110100000
 DC.L     %00000110111111000011111101100000
 DC.L     %00000010111111000011111101000000
 DC.L     %00000011011111000011111011000000
 DC.L     %00000001011111000011111010000000
 DC.L     %00000001101111111111110110000000
 DC.L     %00000000101111111111110100000000
 DC.L     %00000000110111000011101100000000
 DC.L     %00000000010111000011101000000000
 DC.L     %00000000011011000011011000000000
 DC.L     %00000000001011111111010000000000
 DC.L     %00000000001101111110110000000000
 DC.L     %00000000000101111110100000000000
 DC.L     %00000000000110111101100000000000
 DC.L     %00000000000010111101000000000000
 DC.L     %00000000000011011011000000000000
 DC.L     %00000000000001011010000000000000
 DC.L     %00000000000001100110000000000000
 DC.L     %00000000000000111100000000000000

image_stop:
 DC.L     %00000000011111111111111000000000
 DC.L     %00000000110000000000001100000000
 DC.L     %00000001101111111111110110000000
 DC.L     %00000011011111111111111011000000
 DC.L     %00000110111111111111111101100000
 DC.L     %00001101111111111111111110110000
 DC.L     %00011011111111111111111111011000
 DC.L     %00110111111111111111111111101100
 DC.L     %01101111111111111111111111110110
 DC.L     %11011111111111111111111111111011
 DC.L     %10110001100000011000011000001101
 DC.L     %10100000100000010000001000000101
 DC.L     %10100100111001110011001001100101
 DC.L     %10100111111001110011001001100101
 DC.L     %10100011111001110011001001100101
 DC.L     %10110001111001110011001000000101
 DC.L     %10111000111001110011001000001101
 DC.L     %10111100111001110011001001111101
 DC.L     %10100100111001110011001001111101
 DC.L     %10100000111001110000001001111101
 DC.L     %10110001111001111000011001111101
 DC.L     %10111111111111111111111111111101
 DC.L     %11011111111111111111111111111011
 DC.L     %01101111111111111111111111110110
 DC.L     %00110111111111111111111111101100
 DC.L     %00011011111111111111111111011000
 DC.L     %00001101111111111111111110110000
 DC.L     %00000110111111111111111101100000
 DC.L     %00000011011111111111111011000000
 DC.L     %00000001101111111111110110000000
 DC.L     %00000000110000000000001100000000
 DC.L     %00000000011111111111111000000000


**********************************************************************
*
* int get_next_edit(a0 = OBJECT *tree, d0 = int objnr, d1 = int function)
*
* function == 0: Cursor runter
* function == 1: Cursor hoch
* function == 2: Return
* function == 3: Help
* function == 4: Undo
* function == 5: ^Q
*

get_next_edit:
 movem.l  d3/d4/d5/d6/d7/a5,-(sp)
;move.l   a0,a0                    ; a0 = tree
 move.w   d0,d7                    ; d7 = objnr
 moveq    #8,d5                    ; nach EDITABLE suchen
 moveq    #0,d6                    ; ab Objekt 0
 moveq    #1,d3                    ; Richtung: per Default vorwaerts
 move.w   d1,d0
 beq.b    gned_c0
 subq.w   #1,d0
 beq.b    gned_c1
 subq.w   #1,d0
 beq.b    gned_c2
 subq.w   #1,d0
 beq.b    gne_help
 subq.w   #1,d0
 beq.b    gne_undo
 subq.w   #1,d0
 bne      gne_notfound
* case 5 (^Q)
 moveq    #-40,d5                  ; keine Flags, Strings mit Offset -40
 bra      gne_nextob
* case 4 (Undo)
gne_undo:
 moveq    #-20,d5                  ; keine Flags, Strings mit Offset -20
 bra      gne_nextob
* case 3 (Help)
gne_help:
 moveq    #0,d5                    ; keine Flags
 bra      gne_nextob
* case 1 (Cursor hoch):
gned_c1:
 moveq    #-1,d3                   ; Suchrichtung: nach oben
 move.w   d3,d6                    ; ab hier suchen
 add.w    d7,d6
 bra      gne_nextob
* case 0 (Cursor runter):
gned_c0:
 move.w   d7,d1
 muls     #24,d1
 btst     #5,9(a0,d1.l)            ; LASTOB ?
 bne.b    gne_notfound             ; ja, beenden
 move.w   d3,d6
 add.w    d7,d6                    ; d6 = objnr+Richtung, Editfeld suchen
 bra.b    gne_nextob
* case 2 (Return):
gned_c2:
 moveq    #2,d5                    ; nach DEFAULT suchen
 bra.b    gne_nextob

gned_cn:
 move.w   d6,d1
 muls     #24,d1
 lea      0(a0,d1.l),a1            ; a1 auf das Objekt
 tst.w    d5
 bgt.b    gne_srchflags            ; nach Flags suchen
 cmpi.w   #G_BUTTON,ob_type(a1)
 bne.b    gne_next                 ; kein Button, weiter
 btst     #EXIT_B,ob_flags+1(a1)
 beq.b    gne_next                 ; kein Exitobjekt, weiter
 btst     #DISABLED_B,ob_state+1(a1)
 bne.b    gne_next                 ; disabled, weiter
 lea      gne_helps(pc),a5
 adda.w   d5,a5                    ; Offset fuer Help/Undo
 moveq    #5-1,d2                  ; 5 Strings
gne_str:
 move.l   ob_spec(a1),a2           ; Zeiger auf den Text
gne_space:
 cmpi.b   #' ',(a2)+
 beq.b    gne_space                ; Leerstellen ueberlesen
 subq.l   #1,a2
 moveq    #4-1,d1                  ; 4 Zeichen
 move.l   a5,-(sp)
gne_c:
 move.b   (a2)+,d0
 jsr      toupper                  ; zerstoert nur d0
 cmp.b    (a5)+,d0
 dbne     d1,gne_c
 move.l   (sp)+,a5
 beq.b    gne_found                ; gefunden !!
 addq.l   #4,a5                    ; nein, naechste Vergleichszeichenkette
 dbra     d2,gne_str
 bra.b    gne_next

gne_srchflags:
 move.w   ob_flags(a1),d0          ; Flags holen
 and.w    d5,d0
 bne.b    gne_found                ; gesuchtes Flag gesetzt
gne_next:
 btst     #5,ob_flags+1(a1)
 bne.b    gne_notfound             ; LASTOB
 add.w    d3,d6
gne_nextob:
 tst.w    d6                       ; vor dem ersten Objekt ?
 bge.b    gned_cn                  ; nein, weiter
gne_notfound:
 move.w   d7,d0                    ; nix gefunden, akt. Obj. zurueckgeben
gned_ret:
 movem.l  (sp)+,a5/d7/d6/d5/d4/d3
 rts
gne_found:
 move.w   d6,d0
 bra.b    gned_ret

     IF   COUNTRY=COUNTRY_FR
gne_cq:
 DC.B     'FIN',0
 DC.B     'SORT'
 DC.B     'EXIT'
 DC.B     'QUIT'
 DC.B     'quit'                   ; noch frei

gne_undos:
 DC.B     'ABAN'
 DC.B     'RETO'
 DC.B     'CANC'
 DC.B     'ABOR'
 DC.B     'abor'

gne_helps:
 DC.B     'AIDE'
 DC.B     'HELP'
 DC.B     'help'                   ; noch frei
 DC.B     'help'                   ; noch frei
 DC.B     'help'                   ; noch frei
     ELSE
gne_cq:
 DC.B     'ENDE'
 DC.B     'VERL'
 DC.B     'AUSG'
 DC.B     'EXIT'
 DC.B     'QUIT'

gne_undos:
 DC.B     'ABBR'
 DC.B     'ZUR',$9a
 DC.B     'CANC'
 DC.B     'ABOR'
 DC.B     'abor'

gne_helps:
 DC.B     'HILF'
 DC.B     'HELP'
 DC.B     'help'                   ; noch frei
 DC.B     'help'                   ; noch frei
 DC.B     'help'                   ; noch frei
     ENDIF


**********************************************************************
*
* WORD cdecl wform_keybd( OBJECT *tree, int objnr, int *c, int *nxtob,
*                        WORD whandle )
*
* Eingabe: 4(sp) = tree, 8(sp) = objnr, $a(sp) = &c, $e(sp) = whandle
* Ausgabe: $a(sp) = &c, $e(sp) = &nxtob
* Rueckgabe == 0 gdw. Exitbutton mit Return angewaehlt
*
* Mag!X 2.00: Mit <objnr> = $8765 wird in *c zurueckgegeben, ob mit
*             Alt-Taste ein Objekt angewaehlt wurde.
*
* MagiC 5.10: Ist <whandle != -1>, wird der Redraw aufs Fenster
*             beschraenkt
*

_form_wkeybd:
 lea      4(sp),a0
 movem.l  d6/d7/a2/a4/a5/a6,-(sp)
 move.l   (a0)+,a6                 ; a6 = tree
 move.w   (a0)+,d7                 ; d7 = objnr
 move.l   (a0)+,a5                 ; a5 = &c
 move.l   (a0)+,a4                 ; a4 = &nxtob
 move.w   (a0),d6                  ; d6 = whandle
 move.w   (a5),d0
 cmpi.w   #$8765,d7
 beq      form_altkey              ; Neue Mag!X 2.00- Funktion
 moveq    #0,d1
 moveq    #0,d2
 cmpi.w   #$0f09,d0                ; Tab
 beq.b    down
 cmpi.w   #$5000,d0                ; Cursor runter
 beq.b    down
 cmpi.w   #$4800,d0                ; Cursor hoch
 beq.b    up
 cmpi.w   #$0f00,d0                ; Shift Tab
 beq.b    up
 cmpi.w   #$1c0d,d0                ; Return
 beq.b    ret
 cmpi.w   #$720d,d0                ; Enter
 beq.b    ret
 cmpi.w   #$6200,d0                ; Help
 beq.b    help
 cmpi.w   #$6100,d0                ; Undo
 beq.b    undo
 cmpi.w   #$1011,d0                ; ^Q
 beq.b    ctrlq
 moveq    #1,d2                    ; Shift merken
 cmpi.w   #$4838,d0                ; Shift- Cursor hoch
 beq.b    up
 cmpi.w   #$5032,d0                ; Shift- Cursor runter
 beq.b    down
no_end:
 moveq    #1,d0                    ; Dialog nicht beendet
 bra      fkb_ende
ctrlq:
 addq.w   #1,d1                    ; d1 = 5
undo:
 addq.w   #1,d1                    ; d1 = 4
help:
 addq.w   #1,d1                    ; d1 = 3
ret:
 addq.w   #1,d1                    ; d1 = 2
 clr.w    d7                       ; bei Return/Help/Undo/^Q ab 0 suchen
up:
 addq.w   #1,d1                    ; d1 = 1
down:
* d1 = 0 (Cursor runter) = 1 (Cursor hoch) = 2 (Return)
*    = 3 (Help) = 4 (Undo) = 5 (^Q)
fkb_again:
 move.w   d2,-(sp)                 ; Shiftstatus retten
 move.w   d1,-(sp)                 ; d1 retten
;move.w   d1,d1
 move.w   d7,d0                    ; objnr
 move.l   a6,a0                    ; tree
 bsr      get_next_edit            ; naechsten Editstring suchen
 move.w   (sp)+,d1
 move.w   (sp)+,d2                 ; Shiftstatus
 beq.b    no_shift
 cmp.w    d7,d0                    ; objnr hat sich geaendert ?
 beq.b    no_shift                 ; nein, fertig
 move.w   d0,d7                    ; merken
 bra.b    fkb_again                ; nochmal Cursorbewegung

no_shift:
 cmpi.w   #3,d1
 bcs.b    fkb_no_sfn
 tst.w    d0                       ; Undo,Help oder ^Q erfolgreich ?
 beq      no_end                   ; nein, einfach ignorieren
fkb_no_sfn:
 clr.w    (a5)                     ; Zeichen loeschen, da verarbeitet
 move.w   d0,(a4)                  ; *nxtob
 beq.b    no_end                   ; kein Defaultbutton oder nxtob
 subq.w   #2,d1
 bcs.b    no_end                   ; < 2, nur Cursorbewegung
* Defaultbutton selektieren und ausgeben
 move.w   (a4),-(sp)               ; merken wegen Reentranz bei TC
 move.w   d6,d2                    ; whandle oder -1
 movea.l  a6,a1                    ; tree
 mulu     #$18,d0
 move.w   ob_state(a1,d0.l),d1
 ori.w    #1,d1                    ; state | SELECTED
 move.w   (a4),d0                  ; objnr
 move.l   a1,a0                    ; tree
 jsr      objc_wchange
; wegen TC und Reentranz hier noch einmal setzen:
 move.w   (sp)+,(a4)               ; *nxtob
 clr.w    (a5)                     ; Zeichen verarbeitet
fkb_nix:
 moveq    #0,d0
fkb_ende:
 movem.l  (sp)+,d6/d7/a2/a4/a5/a6
 rts


form_altkey:
;move.w   d0,d0
 jsr      altcode_asc              ; Alt-Alnum ?
 beq      fkb_nix                  ; es liegt kein ALT-AlNum vor!
;move.w   d0,d0                    ; Zeichen A..Z,1..0
 move.l   a6,a0                    ; tree
 bsr      asc_objnr                ; suche passenden Button/String
 beq.b    fkb_nix                  ; kein passender da
 move.w   d0,(a4)                  ; Objektnummer
 clr.w    (a5)                     ; Zeichen verarbeitet
 bra      no_end                   ; return(1)


**********************************************************************
*
* PUREC WORD form_button(OBJECT *tree, WORD objnr, WORD clicks,
*              WORD *nxt_edit)
*

form_button:
 moveq    #-1,d2              ; winhdl


**********************************************************************
*
* PUREC WORD form_wbutton(OBJECT *tree, WORD objnr, WORD clicks,
*              WORD *nxt_edit, WORD whandle )
*

form_wbutton:
 move.l   a2,-(sp)
 move.l   a1,-(sp)
 bsr.b    _form_button
 move.l   (sp)+,a1
 move.w   d1,(a1)
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* d0/d1 = _form_button(a0 = OBJECT *tree, d0 = int objnr,
*                        d1 = int clicks, d2 = int winhdl)
*
* Rueckgabe d0 = 0, wenn Dialog abgeschlossen (TOUCH(EXIT))
*          d1 = naechstes OBJECT
*
* 11.12.96:    Per <windhdl> ist Hintergrundbedienung eines Dialogs
*              moeglich. Bei <winhdl> == -1 alte Funktion.
*

_form_button:
 movem.l  d3/d4/d5/d6/d7/a4/a5,-(sp)
 move.w   d2,-(sp)                 ; winhdl merken)
 move.w   d1,-(sp)                 ; clicks merken

 move.l   a0,a5                    ; a5 = OBJECT *tree
 move.w   d0,d6                    ; d6 = objnr

 move.w   d6,d0
 muls     #24,d0
 lea      0(a5,d0.l),a4            ; a4 = OBJECT *ob
 move.w   ob_state(a4),d3
 move.w   ob_flags(a4),d4

 btst     #0,d4                    ; SELECTABLE ?
 beq      frbt_noaction            ; nein, Ende
 btst     #3,d3                    ; DISABLED
 bne      frbt_noaction            ; ja, Ende

* SELECTABLE und nicht DISABLED
 btst     #4,d4                    ; RBUTTON ?
 beq      fb_no_rbutton            ; nein

*
* Radiobutton bearbeiten
*

 move.w   d6,d0
 beq      fatal_err
 move.l   a5,a0
 bsr      parentob
 move.w   d0,d7                    ; parent
 muls     #24,d0

* Durchlaufe die Liste aller Kinder des Parent

 move.w   ob_head(a5,d0.l),d5      ; erstes Kind
 bra.b    fb_begloop
fb_loop1:
 move.w   d5,d0
 muls     #24,d0

 btst     #4,ob_flags+1(a5,d0.l)   ; RBUTTON ?
 beq.b    frbt_nxtchld             ; nein, naechstes Kind

 move.w   ob_state(a5,d0.l),d1
 cmp.w    d5,d6
 beq.b    frbt_wir
 bclr     #0,d1
 beq.b    frbt_nxtchld             ; der andere Button ist schon deselektiert
 bra.b    frb_chg

frbt_wir:
 bset     #0,d1
 bne.b    frbt_nxtchld             ; Wir sind schon selektiert

frb_chg:
 move.w   2(sp),d2                 ; winhdl, ggf. -1
 suba.l   a1,a1
;move.w   d1,d1                    ; newstate
 move.w   d5,d0                    ; objnr
 move.l   a5,a0                    ; tree
 jsr      objc_wchange

frbt_nxtchld:
 move.w   d5,d0
 muls     #24,d0
 move.w   ob_next(a5,d0.l),d5      ; naechstes Kind
fb_begloop:
 tst.w    d5
 bmi      fb_weiter                ; Fehler
 cmp.w    d7,d5                    ; beim Parent angekommen ?
 bne.b    fb_loop1                 ; nein, weiter

 bset     #0,d3                    ; Wir sind jetzt SELECTED
 bra      fb_weiter

*
* kein RBUTTON
*

fb_no_rbutton:
 cmpi.w   #G_POPUP,ob_type(a4)
 beq.b    fb_popup
 move.w   2(sp),-(sp)              ; winhdl
 move.w   d3,d2                    ; outstate
 move.w   d3,d1
 eori.w   #1,d1                    ; instate (mit getoggeltem SELECTED)
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; tree
 jsr      graf_wwatchbox
 addq.l   #2,sp
 tst.w    d0                       ; im Feld losgelassen ?
 beq      fb_weiter                ; nein
 move.w   ob_type(a4),d0
 cmpi.w   #G_SWBUTTON,d0
 bne      fb_no_pop
;bne.b    fb_no_swb

* SWITCHBUTTON

 move.l   ob_spec(a4),a0
 addq.l   #6,a0                    ; maxnum
 move.w   (a0),d0
 cmpi.w   #1,(sp)                  ; ein Klick ?
 beq.b    fb_swb_1
 subq.w   #1,-(a0)                 ; 2 Klicks: verringern
 bge.b    fb_swb_ok
 move.w   d0,(a0)
 bra.b    fb_swb_ok
fb_swb_1:
 addq.w   #1,-(a0)                 ; 1 Klick: erhoehen
 cmp.w    (a0),d0
 bcc.b    fb_swb_ok
 clr.w    (a0)
fb_swb_ok:
 bra      fb_pop_swb_draw

/*
fb_no_swb:
 cmpi.w   #G_POPUP,d0
 bne.b    fb_no_pop
*/

* POPUP-MENUe

fb_popup:
 move.l   a5,a0
 move.w   d6,d0
 bsr      _objc_offset
 move.l   ob_spec(a4),a1
 move.l   (a1)+,a0                 ; Menuebaum
 move.w   (a1),d2                  ; num
 mulu     #24,d2
 lea      ob_state+1(a0,d2.l),a1
 move.l   a1,-(sp)                 ; zum Ent- CHECK- en merken
 bset     #2,(a1)                  ; unser Objekt ist CHECKED
 move.l   ob_x(a0),-(sp)           ; x/y merken
 move.l   a0,-(sp)                 ; Baum merken
 add.w    ob_x(a0),d0
 move.w   d0,ob_x(a0)              ; x relativ zu parent
 add.w    ob_y(a0),d1
 move.w   d1,ob_y(a0)              ; y relativ zu parent
 moveq    #0,d0

;move.l   a0,a0
 bsr      _form_popup
 move.l   (sp)+,a0
 move.l   (sp)+,ob_x(a0)           ; x/y restaurieren
 move.l   (sp)+,a1
 bclr     #2,(a1)                  ; das CHECKED loeschen
 tst.w    d0                       ; Rueckgabewert von form_popup
 ble.b    fb_pop_swb_draw          ; ungueltig
 move.l   ob_spec(a4),a0
 move.w   d0,4(a0)                 ; gueltig, umsetzen
fb_pop_swb_draw:
 bclr     #0,ob_state+1(a4)        ; nicht SELECTED

 move.w   2(sp),d2                 ; winhdl (ggf. -1)
 suba.l   a1,a1                    ; GRECT
 moveq    #0,d1                    ; depth
 move.w   d6,d0                    ; startob
 move.l   a5,a0                    ; tree
 jsr      objc_wdraw
 bra      fb_weiter

fb_no_pop:
 eori.w   #1,d3                    ; ja, SELECTED toggeln

*
* In beiden Faellen
*

fb_weiter:
 btst     #6,d4                    ; TOUCHEXIT ?
 bne.b    frbt_noaction
 move.w   d4,d0
 and.w    #9,d0
 beq.b    frbt_noaction            ; weder SELECTABLE noch EDITABLE

 subq.l   #8,sp                    ; Platz fuer 4 ints
 lea      (sp),a0
 move.l   #$10100,d0               ; clk=1,msk=1,state=0
 bsr      evnt_button
 addq.l   #8,sp

* nicht SELECTABLE
* DISABLED

frbt_noaction:
 btst     #6,d4                    ; TOUCHEXIT ?
 bne.b    frbt_exit                ; ja
 moveq    #1,d0                    ; Dialog noch nicht abgeschlossen
 btst     #0,d3                    ; state SELECTED ?
 beq.b    frmb_l1                  ; nein
 btst     #2,d4                    ; EXIT ?
 beq.b    frmb_l1                  ; nein
frbt_exit:
 moveq    #0,d0                    ; SELECTED und EXIT => d0 = 0
frmb_l1:
 tst.w    d0
 beq.b    frbt_ende
 btst     #3,d4                    ; EDITABLE ?
 bne.b    frbt_ende                ; ja
 clr.w    d6                       ; nein
frbt_ende:
 subq.w   #2,(sp)                  ; 2 clicks ?
 bne.b    frbt_nodouble            ; nein
 btst     #6,d4                    ; TOUCHEXIT ?
 beq.b    frbt_nodouble            ; nein
 or.w     #$8000,d6                ; Doppelklick merken

frbt_nodouble:
 addq.l   #4,sp
 move.w   d6,d1                    ; naechstes OBJECT
;move.w   d0,d0                    ; Null, wenn Dialog abgeschlossen
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* EQ/NE int asc_objnr(a0 = OBJECT *tree, d0 = char c)
*
* Sucht einen unterstrichenen String oder Button.
*

asc_objnr:
 move.l   a0,a2                    ; a2 = tree
 move.b   d0,d2                    ; d2 = c
 moveq    #0,d1                    ; Objektnummer 0
asco_loop:
 move.w   ob_type(a2),d0
;cmpi.b   #G_BOXTEXT,d0
;beq.b    asco_test
 cmpi.b   #G_BUTTON,d0
 beq.b    asco_test
 cmpi.b   #G_STRING,d0
 beq.b    asco_test
 cmpi.b   #G_TITLE,d0
 bne.b    asco_next
asco_test:
 btst     #6,ob_state+1(a2)        ; WHITEBAK ?
 beq      asco_next                ; nein
 btst     #7,ob_flags+1(a2)        ; MagiC 5.10: HIDETREE ?
 bne      asco_next                ; ja
 move.b   ob_state(a2),d0          ; Hibyte von ob_state
 cmpi.b   #$fe,d0
 bcc      asco_next                ; -1: alles bzw. nichts unterstrichen
                                   ; -2: Gruppenrahmen
 bclr     #7,d0                    ; Info "Spezialbutton" ignorieren
 ext.w    d0                       ; Position des Unterstrichs
 move.l   ob_spec(a2),a1
 btst     #0,ob_flags(a2)          ; INDIRECT ?
 beq.b    asco_di
 move.l   (a1),a1
asco_di:
;cmpi.b   #G_BOXTEXT,ob_type+1(a2)
;bne.b    asco_txt
;move.l   te_ptext(a1),a1
;asco_txt:
 move.b   0(a1,d0.w),d0            ; unterstrichenes Zeichen
 jsr      toupper                  ; Zeichen in Grossschrift
 cmp.b    d0,d2                    ; gefunden ?
 bne.b    asco_next
; MagiC 5.10: falls irgendein parent HIDETREE hat, Objekt ignorieren
 movem.l  d2/d1,-(sp)
asco_good_loop:
 move.w   d1,d0                    ; Objekt ist schon root ?
 beq.b    asco_is_good             ; ja, d1 ist OK
;move.w   d0,d0
;move.l   a0,a0
 jsr      parentob                 ; parent ermitteln, aendert nur d1/d2
 move.w   d0,d1
 mulu     #24,d0
 btst     #7,ob_flags+1(a0,d0.w)   ; HIDETREE ?
 beq.b    asco_good_loop           ; nein, weitersuchen
 movem.l  (sp)+,d2/d1
 bra.b    asco_next
asco_is_good:
 movem.l  (sp)+,d2/d1
 move.w   d1,d0
 rts                               ; gefunden !
asco_next:
 addq.w   #1,d1                    ; naechste Objektnummer
 btst     #5,ob_flags+1(a2)        ; LASTOB ?
 lea      24(a2),a2
 beq      asco_loop                ; nein, weiter
 moveq    #0,d0                    ; nix gefunden
 rts


**********************************************************************
*
* PUREC WORD form_xdo( OBJECT *tree, WORD startob, WORD *endob,
*                   void *keytab, FLYINF *fi )

form_xdo:
 move.l   a2,-(sp)
 move.l   a1,-(sp)            ; endob
 move.l   8+8(sp),a2          ; flyinf
 move.l   4+8(sp),a1          ; keytab
;move.w   d0,d0               ; startob
;move.l   a0,a0               ; tree
 bsr.b    _form_xdo
 move.l   (sp)+,a1
 move.w   d1,(a1)             ; *endob setzen
 move.l   (sp)+,a2
 rts


***************************************
*
* Callback fuer form_xdo
*

__fdo_callback:
 move.l   a4,d1                    ; keytab ?
 beq.b    _fdocb_ende
 move.l   16(a4),d1
 beq.b    _fdocb_ende
 move.w   d6,-(sp)
 pea      (sp)
 pea      -6(a6)
 move.l   a4,-(sp)                 ; XDO_INF *
 move.l   a5,a0                    ; OBJECT *tree
;move.l   a1,a1
;move.w   d0,d0                    ; Eventtypen bzw. 0
 move.l   d1,a2
 jsr      (a2)                     ; int xdo_callback( ... )
 adda.w   #12,sp
 move.w   (sp)+,d6                 ; aktuelles Editobjekt zurueck
_fdocb_ende:
 rts


**********************************************************************
*
* d0/d1 form_do(a0 = OBJECT *tree, d0 = int startob)
*

form_do:
 suba.l   a1,a1                    ; keine Tastatur- Tabelle
 suba.l   a2,a2                    ; keine FlyDials

**********************************************************************
*
* d0/d1 _form_xdo( a0 = OBJECT *tree, d0 = int startob,
*                   a1 = XDO_INF *xdo_inf,  a2 = FLYINF *fi )
*
* -$20(a6)     GRECT fuer FlyDial
* -$18(a6)     MFDB *mfdb
* -$14(a6)     int  last_curpos
* -$12(a6)     int  x
* -$10(a6)     int  y
*  -$e(a6)     int  bstate
*  -$c(a6)     int  kstate
*  -$a(a6)     int  key
*  -$8(a6)     int  nclicks
*
*  -6(a6)      int  curpos
*
* <xdo_inf> ist NULL oder zeigt auf 4 Tabellen, die jeweils Eintraege
*          der Form haben: char scancode (0 = Tabellenende)
*                          char nclicks
*                          int  objnr
*          die Tabellen sind fuer unshift/shift/ctrl/alt
*
*         Es folgt NULL oder der Zeiger auf eine Callback-
*         Funktion, die undokumentiert war und deshalb fuer MagiC 4.0
*         geaendert wird:
*
*         void xdo_callback(WORD events, OBJECT *tree,
*                             WORD *evt_data, XDO_INF *info,
*                             WORD *cursorpos, WORD *editob)
*

_form_xdo:
 link     a6,#-$20
 movem.l  d3/d4/d5/d6/d7/a4/a5,-(sp)
 move.l   a0,a5                    ; a5 = tree
 move.l   a1,a4
 move.l   a2,-$18(a6)
 move.w   d0,d7                    ; d7 = startob

 jsr      mctrl_1                  ; Bildschirm sperren

 jsr      flush_keybuf             ; Tastaturpuffer leeren

 lea      desk_g,a0
 jsr      set_clip_grect           ; Clipping auf gesamten Bildschirm

 move.l   -$18(a6),d0
 beq.b    fdo_no_corner            ; keine FlyDials
 moveq    #-1,d0
 jsr      smalloc                  ; verfuegbare Bytes
 move.l   -$18(a6),a0              ; a0 = altes GRECT
 move.w   8+fd_wdwidth(a0),d1      ; Breite in Worten
 mulu     8+fd_nplanes(a0),d1      ; * Planes
 mulu     8+fd_h(a0),d1            ; * Hoehe
 add.l    d1,d1                    ; in Bytes umrechnen
 cmp.l    d1,d0                    ; d0 kann negativ sein!
 blt.b    fdo_no_corner            ; zuwenig Speicher
 tst.w    enable_3d
 beq.b    fdo_2d
 move.w   ob_flags(a5),d0
 andi.w   #FL3DACT,d0
 cmpi.w   #FL3DBAK,d0
 bne.b    fdo_2d
;move.l   a0,a0
 bsr      draw_3dcorner
 bra.b    fdo_no_corner
fdo_2d:
;move.l   a0,a0
 bsr      draw_2dcorner            ; umgeknickte Ecke zeichnen

fdo_no_corner:
 moveq    #-1,d3                   ; Mausklick- Cursorpos ungueltig
 move.w   d3,-$14(a6)              ; letztes Editfeld ungueltig
 tst.w    d7
 bgt.b    fdo_startob              ; startob definitiv angegeben (>0)

* startob == 0

 moveq    #0,d1
 moveq    #0,d0
 move.l   a5,a0
 bsr      get_next_edit            ; erstes Editfeld holen
 move.w   d0,d7

fdo_startob:
 clr.w    d6                       ; vorheriges Editfeld ungueltig
 moveq    #1,d5

*
* while (d5 != 0)
*

fdo_loop:
 tst.w    d7                       ; Editfeld existiert ?
 beq.b    fdo_no_new_edit          ; nein
 cmp.w    d7,d6                    ; neues Editfeld ?
 beq.b    fdo_no_new_edit          ; nein
 move.w   d7,d6                    ; altes := neues
 clr.w    d7                       ; neues := ungueltig

* neues Editfeld initialisieren und Cursor ein

 moveq    #100,d2                  ; ED_CRSR (statt 1=ED_INIT)
 lea      -6(a6),a1                ; Cursorpos. wird initialisiert
 move.w   d3,d1                    ; x-Klickposition statt Zeichen
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; tree
 jsr      _objc_edit

fdo_no_new_edit:

*
* pre-Callback
*

 suba.l   a1,a1                    ; keine Rueckgabewerte von _evnt_multi !
 moveq    #0,d0                    ; keine Events
 bsr      __fdo_callback

*
* Event
*

 pea      -$12(a6)                 ; Platz fuer Rueckgabewerte
 clr.l    -(sp)                    ; kein Messagepuffer
 move.l   #$020101,-(sp)           ; state (1, also gedrueckt), mask, clicks (=2)
 clr.l    -(sp)                    ; (kein tcount)
 clr.l    -(sp)                    ; (kein mm2)
 clr.l    -(sp)                    ; (kein mm1)
 move.w   #3,-(sp)                 ; MU_KEYBD+MU_BUTTON
 jsr      _evnt_multi
 adda.w   #26,sp

*
* Post-Callback
*

 lea      -$12(a6),a1
 bsr      __fdo_callback

 move.w   d0,d4
 moveq    #-1,d3                   ; x zunaechst ungueltig
 btst     #EVB_KEY,d4
 beq      fdo_no_keybd

* MU_KEYBD ist eingetreten

 move.l   a4,d0                    ; keytab ?
 beq.b    fdo_nokbtab

*
* Durchsuche die angegebene Tastencode-Tabelle
*

 move.w   -$c(a6),d0               ; Tastaturstatus
 move.l   8(a4),a0                 ; Tabelle fuer CTRL
 btst     #2,d0                    ; K_CTRL
 bne.b    fdo_ksrch                ; ja, Tabelle durchsuchen
 move.l   12(a4),a0                ; Tabelle fuer ALT
 btst     #3,d0                    ; K_ALT ?
 bne.b    fdo_ksrch                ; ja, Tabelle durchsuchen
 move.l   4(a4),a0                 ; Tabelle fuer SHIFT
 andi.w   #3,d0
 bne.b    fdo_ksrch                ; ja, Tabelle durchsuchen
 move.l   (a4),a0                  ; unshift
fdo_ksrch:
 move.l   a0,d0
 beq.b    fdo_nokbtab              ; Tabelle ungueltig
 move.w   -$a(a6),d0               ; Zeichen
 lsr.w    #8,d0                    ; Scancode ins Lobyte



fdo_srchloop:
 tst.b    (a0)
 beq.b    fdo_nokbtab              ; Tabellenende
 cmp.b    (a0),d0                  ; unser Scancode ?
 beq.b    fdo_kbfound              ; ja
 addq.l   #4,a0                    ; nein, weiter
 bra.b    fdo_srchloop
fdo_kbfound:
 move.b   1(a0),d0
 move.w   d0,-8(a6)                ; nclicks setzen
 move.w   2(a0),d7                 ; objnr
 bra      fdo_nofly

*
* Alt-Tastencode
*

fdo_nokbtab:
 cmpi.w   #8,-$c(a6)               ; Tastaturstatus = K_ALT ?
 bne      fdo_fk                   ; nein, _form_keybd aufrufen
 move.w   -$a(a6),d0               ; Zeichen
 jsr      altcode_asc              ; Alt-Alnum ?
 beq      fdo_fk                   ; es liegt kein ALT-AlNum vor!
;move.w   d0,d0                    ; Zeichen A..Z,1..0
 move.l   a5,a0                    ; tree
 bsr      asc_objnr                ; suche passenden Button/String
 beq.b    fdo_fk                   ; kein passender da
 move.w   d0,d7                    ; Objektnummer
 move.w   #1,-8(a6)                ; ein Klick
 bra      fdo_nofly

*
* form_keybd versuchen
*

fdo_fk:
 move.w   d7,-(sp)

 move.w   #-1,-(sp)                ; kein Window
 pea      2(sp)                    ; neues aktuelles Edit- Objekt
 pea      -$a(a6)                  ; Zeichen
 move.w   d6,-(sp)                 ; objnr
 move.l   a5,-(sp)                 ; tree
 bsr      _form_wkeybd
 adda.w   #$10,sp

 move.w   (sp)+,d7

 move.w   d0,d5                    ; == 0, wenn Dialog beendet
 move.w   -$a(a6),d1               ; Zeichen eingegeben ?
;beq.b    fdo_no_keybd             ; nein, weiter
 beq      fdo_no_but               ; verarbeitet, Button ignorieren

 moveq    #2,d2                    ; ED_CHAR
 lea      -6(a6),a1                ; Zeichenposition
;move.w   d1,d1                    ; Zeichen
 move.w   d6,d0                    ; objnr
 move.l   a5,a0                    ; tree
 jsr      _objc_edit

fdo_no_keybd:
 btst     #EVB_BUT,d4
 beq      fdo_no_but

* MU_BUTTON ist eingetreten

 move.l   -$12(a6),d2              ; x,y
 moveq    #8,d1                    ; depth
 moveq    #0,d0                    ; startob
 move.l   a5,a0                    ; tree
 jsr      _objc_find

 move.w   d0,d7                    ; d7 = angeklicktes Objekt
 addq.w   #1,d0                    ; gueltig ?
 bne.b    fdo_validob              ; ja

 move.w   #7,-(sp)                 ; Pling
 move.l   #$30002,-(sp)            ; Bconout(CON)
 trap     #13                      ; bios
 addq.l   #6,sp
 clr.w    d7                       ; Objekt ungueltig
 bra      fdo_no_but

fdo_validob:
 cmpi.w   #1,-8(a6)                ; nclicks
 bne.b    fdo_nofly                ; nicht ein Klick
 btst     #1,gr_mkmstate+1         ; rechte Maustaste gedrueckt ?
 bne.b    fdo_myfly                ; ja, meine Fliegroutine
 btst     #3,gr_mkkstate+1         ; ALT gedrueckt ?
 bne.b    fdo_myfly                ; ja, meine Fliegroutine

* Flydial per linker Maustaste
 move.l   -$18(a6),d0
 beq.b    fdo_nofly                ; keine FlyDials
* empfindliches GRECT berechnen
 lea      -$20(a6),a0
 move.l   d0,a1
 move.w   (a1)+,d0                 ; x
 move.w   (a1)+,d1                 ; y
 add.w    (a1),d0                  ; x+w
 sub.w    gr_hwbox,d0
 subq.w   #1,d0                    ; x+w-1-gr_hwbox
 move.w   d0,(a0)+
 move.w   d1,(a0)+
 move.w   gr_hwbox,(a0)+
 move.w   gr_hhbox,(a0)
 lea      -$20(a6),a0
 move.w   -$12(a6),d0
 move.w   -$10(a6),d1
 jsr      xy_in_grect              ; Mausklick auf "Corner"!
 beq      fdo_nofly                ; nein

* Flydial per rechter Maustaste
fdo_myfly:
 moveq    #0,d7                    ; Objekt ungueltig machen
 btst     #0,gr_mkmstate+1         ; linke Maustaste noch gedrueckt ?
 beq.b    fdo_no_but               ; nein, nichts tun
 move.l   -$18(a6),d0
 beq.b    fdo_no_but               ; keine FlyDials
 move.l   d0,a1                    ; FLYINF *fi
 move.l   a5,a0                    ; OBJECT *tree
 bsr      flydial
 bra      fdo_no_but
fdo_nofly:
 moveq    #-1,d2                   ; winhdl
 move.w   -8(a6),d1                ; nclicks
 move.w   d7,d0
 move.l   a5,a0
 bsr      _form_button

 move.w   d1,d7
 move.w   d0,d5                    ; == 0, falls Dialog beendet
 beq      fdo_cur_off
 tst.w    d7                       ; ggf. neues Editfeld
 beq.b    fdo_no_but

 btst     #EVB_KEY,d4
 bne.b    fdo_no_but

* Editfeld wurde angeklickt, keine Taste betaetigt

 move.w   -$12(a6),d3              ; x des Klicks ist gueltig

fdo_no_but:
 tst.w    d5                       ; Dialog beendet ?
 beq.b    fdo_cur_off              ; ja, Cursor aus
 tst.w    d7                       ; neues Editfeld gueltig
 beq.b    fdo_no_cur_off           ; nein
 tst.w    d3
 bpl.b    fdo_cur_off              ; Cursor positionieren (aus und wieder an)
 cmp.w    d7,d6                    ; hat sich geaendert ?
 beq.b    fdo_no_cur_off           ; nein, Cursor lassen
fdo_cur_off:

 moveq    #3,d2                    ; ED_END
 lea      -6(a6),a1
 moveq    #0,d1
 move.w   d6,d0
 move.l   a5,a0
 jsr      _objc_edit

 move.w   d6,-$14(a6)              ; letztes Editfeld merken

 tst.w    d3
 bmi.b    fdo_no_cur_off
 moveq    #0,d6                    ; tu so, als ob neues Editfeld geklickt

fdo_no_cur_off:
 tst.w    d5
 bne      fdo_loop

 jsr      mctrl_0                  ; Bildschirm freigeben



 move.w   d7,d0
 move.w   -$14(a6),d1              ; letztes Editfeld
 movem.l  (sp)+,a5/a4/d7/d6/d5/d4/d3
 unlk     a6
 rts


**********************************************************************
*
* void draw_3dcorner( a0 = FLYINF *fi )
*

draw_3dcorner:
 move.w   gr_hhbox,-(sp)
 move.w   gr_hwbox,-(sp)
 move.w   g_y(a0),-(sp)
 addq.w   #2,(sp)
 move.w   g_x(a0),d0
 add.w    g_w(a0),d0
 sub.w    gr_hwbox,d0
 subq.w   #2,d0
 move.w   d0,-(sp)
 jsr      mouse_off
 move.l   sp,a0
 moveq    #IP_SOLID,d2             ; Pattern
 moveq    #LWHITE,d1               ; hellgrau
 moveq    #REPLACE,d0
 bsr      drawbox

 moveq    #WHITE,d1
 bsr      strplc_pcolor
 lea      vptsin,a0
 move.l   g_x(sp),(a0)+
 move.w   g_x(sp),(a0)+
 move.w   g_y(sp),d0
 add.w    g_h(sp),d0
 subq.w   #2,d0
 move.w   d0,(a0)
 lea      vptsin,a0
 moveq    #2,d0
 bsr      v_pline

 moveq    #LBLACK,d1
 bsr      strplc_pcolor
 lea      vptsin,a0
 move.w   g_x(sp),d0
 addq.w   #1,d0
 move.w   d0,(a0)+
 move.w   g_y(sp),d1
 add.w    g_h(sp),d1
 subq.w   #1,d1
 move.w   d1,(a0)+
 add.w    g_w(sp),d0
 subq.w   #2,d0
 move.w   d0,(a0)+
 move.w   d1,(a0)
 lea      vptsin,a0
 moveq    #2,d0
 bsr      v_pline

 lea      vptsin,a0
 move.l   g_x(sp),(a0)
 addq.w   #1,(a0)
 addq.w   #1,4(a0)
 moveq    #2,d0
 bsr      v_pline

 addq.l   #8,sp
 jmp      mouse_on


**********************************************************************
*
* void draw_2dcorner( a0 = FLYINF *fi )
*

draw_2dcorner:
 lea      vptsin,a1
* erste 3 Linien
 move.w   (a0)+,d0                 ; x
 move.w   (a0)+,d1                 ; y
 add.w    (a0),d0                  ; x+w
 subq.w   #1,d0                    ; x+w-1
 sub.w    gr_hwbox,d0
 move.w   d0,(a1)+                 ; x1 = x+w-1-gr_hwbox
 move.w   d1,(a1)+                 ; y1 = y
 move.w   d0,(a1)+                 ; x2 = x+w-1-gr_hwbox
 add.w    gr_hhbox,d1
 move.w   d1,(a1)+                 ; y2 = y+gr_hhbox
 add.w    gr_hwbox,d0
 move.w   d0,(a1)+                 ; x3 = x+w-1
 move.w   d1,(a1)+                 ; y2 = y+gr_hhbox
 move.l   -12(a1),(a1)+            ; x4/y4 = x1/y1
* zweite 2 Linien
 move.l   -16(a1),(a1)
 addq.w   #3,(a1)+
 addq.w   #3,(a1)+
 move.l   -16(a1),(a1)
 addq.w   #3,(a1)+
 subq.w   #3,(a1)+
 move.l   -16(a1),(a1)
 subq.w   #3,(a1)+
 subq.w   #3,(a1)+
* zwei weisse Linien
 move.l   -28(a1),(a1)
 addq.w   #1,(a1)+
 addq.w   #1,(a1)+
 move.l   -28(a1),(a1)
 addq.w   #1,(a1)+
 subq.w   #1,(a1)+
 move.l   -28(a1),(a1)
 subq.w   #1,(a1)+
 subq.w   #1,(a1)+
* noch zwei weisse Linien
 move.l   -12(a1),(a1)
 addq.w   #1,(a1)+
 addq.w   #2,a1
 move.l   -12(a1),(a1)
 addq.w   #1,(a1)+
 subq.w   #1,(a1)+
 move.l   -12(a1),(a1)
 addq.w   #2,a1
 subq.w   #1,(a1)

 jsr      mouse_off
 moveq    #WHITE,d1
 bsr      strplc_pcolor
 lea      vptsin+28,a0
 moveq    #3,d0
 bsr      v_pline
 lea      vptsin+40,a0
 moveq    #3,d0
 bsr      v_pline
 moveq    #1,d1                    ; BLACK
 bsr      strplc_pcolor
 lea      vptsin,a0
 moveq    #4,d0
 bsr      v_pline
 lea      vptsin+16,a0
 moveq    #3,d0
 bsr      v_pline
 jmp      mouse_on


**********************************************************************
*
* void flydial( a0 = OBJECT *tree, a1 = FLYINF *fi )
*
*     a4       MFDB *    fuer Hintergrund (= a6+8)
*     a6       GRECT *   fuer Hintergrund
*   (sp)       GRECT
*  8(sp)       MFDB      fuer Dialogbox
* 28(sp)       WGRECT *  neue Grects    } bilden zusammen die alte Box
* 32(sp)       GRECT     Ueberschneidung }
* 40(sp)       int[41]   gerettete Mausdaten
*

GRECTNEU  SET  0
MFDB_BOX  SET  GRECTNEU+8
WGRECTS   SET  MFDB_BOX+20
GRECTINT  SET  WGRECTS+4
;MOUSE     SET  GRECTINT+8
;SPT       SET  MOUSE+82
SPT       SET  GRECTINT+8

flydial:
 movem.l  d7/d6/d5/a3/a4/a5/a6,-(sp)
 suba.w   #SPT,sp
 move.l   a0,a5                    ; a5 = OBJECT *tree
 move.l   a1,a6                    ; a6 = altes GRECT
 lea      8(a1),a4                 ; a4 = mfdb
 btst     #1,gr_mkmstate+1         ; rechte Maustaste gedrueckt ?
 bne.b    fly_r                    ; ja
 btst     #3,gr_mkkstate+1         ; ALT gedrueckt ?
fly_r:
 sne      d5                       ; merken

* testen, ob unser Rechteck vollstaendig im Bildschirm liegt

 move.l   a6,a1
 bsr      grect_in_scr             ; liegt <a6> in desk_g ?
 beq      fly_ende                 ; Box ausserhalb!

* Puffer allozieren

 move.w   fd_wdwidth(a4),d0        ; Breite in Worten
 mulu     fd_nplanes(a4),d0        ; * Planes
 mulu     fd_h(a4),d0              ; * Hoehe
 add.l    d0,d0                    ; in Bytes umrechnen
 jsr      smalloc
 lea      MFDB_BOX(sp),a0
 move.l   d0,(a0)+
 ble      fly_ende                 ; zuwenig Speicher oder EINTRN

 lea      fd_w(a4),a1
 move.l   (a1)+,(a0)+              ; fd_w,fd_h kopieren
 move.l   (a1)+,(a0)+              ; fd_wdwidth,fd_stand kopieren
 move.w   (a1),(a0)                ; fd_planes kopieren

 moveq    #4,d0                    ; flache Hand
 bsr      graf_mouse

/*
 lea      saved_mouse,a1
 lea      MOUSE(sp),a0
 moveq    #41-1,d0
fly_sv_loop:
 move.w   (a1)+,(a0)+
 dbra     d0,fly_sv_loop

 lea      mflat_data,a0
 bsr      _save_mouse
*/

 tst.b    d5
 beq.b    fly_noright

* Operation bei gedrueckter rechter Maustaste
 lea      MFDB_BOX(sp),a1          ; MFDB fuer Box
 lea      (a6),a0                  ; GRECT fuer Box
 moveq    #0,d0                    ; nach (0,0) des mfdb
 bsr      scr_to_mfdb              ; Dialogbox retten
 move.l   a4,a1                    ; MFDB fuer Hintergrund
 move.l   a6,a0                    ; altes GRECT
 moveq    #0,d0                    ; kein Offset
 bsr      mfdb_to_scr              ; Hintergrund restaurieren
 moveq    #0,d0                    ; kein callback
 lea      desk_g,a1
 move.l   a6,a0
 bsr      graf_dragbox
 move.l   d0,GRECTNEU(sp)          ; neue Position x/y
 bsr      mouse_off
 move.l   g_w(a6),GRECTNEU+g_w(sp) ; neue Position w/h
 move.w   GRECTNEU+g_x(sp),d6      ;   x_neu
 sub.w    g_x(a6),d6               ; - x_alt
 add.w    d6,ob_x(a5)
 move.w   GRECTNEU+g_y(sp),d7      ;   x_neu
 sub.w    g_y(a6),d7               ; - x_alt
 add.w    d7,ob_y(a5)
 move.l   a4,a1                    ; MFDB fuer Hintergrund
 lea      GRECTNEU(sp),a0          ; GRECT fuer Box
 moveq    #0,d0                    ; nach (0,0) des mfdb
 bsr      scr_to_mfdb              ; neuen Hintergrund retten
 bra      fly_drawbox


fly_noright:
 moveq    #0,d0                    ; kein callback
 lea      desk_g,a1
 move.l   a6,a0
 bsr      graf_dragbox
 cmp.l    (a6),d0
 beq      fly_free                 ; Position nicht geaendert

 move.l   d0,GRECTNEU(sp)          ; neue Position x/y
 move.l   g_w(a6),GRECTNEU+g_w(sp) ; neue Position w/h
 move.w   GRECTNEU+g_x(sp),d6      ;   x_neu
 sub.w    g_x(a6),d6               ; - x_alt
 add.w    d6,ob_x(a5)
 move.w   GRECTNEU+g_y(sp),d7      ;   x_neu
 sub.w    g_y(a6),d7               ; - x_alt
 add.w    d7,ob_y(a5)
 bsr      mouse_off

* 1. Box nach Box-MFDB

 lea      MFDB_BOX(sp),a1          ; MFDB fuer Box
 lea      (a6),a0                  ; GRECT fuer Box
 moveq    #0,d0                    ; nach (0,0) des mfdb
 bsr      scr_to_mfdb

* 2. Hintergrund-MFDB nach Bildschirm
*    nur die Rechtecke, die nicht in der neuen Position liegen

 bsr      alloc_wgrect             ; WGRECT holen
 move.l   a0,WGRECTS(sp)           ; Liste beginnt bei 28(sp)
 clr.l    (a0)                     ; Liste ist hier zu Ende
 move.l   (a6),4(a0)
 move.l   g_w(a6),4+g_w(a0)        ; altes Rechteck ins WGRECT holen

 lea      WGRECTS(sp),a2           ; Listenanfang
 move.l   a0,a1                    ; unser altes Rechteck
 lea      GRECTNEU(sp),a0          ; neues Rechteck ist <cutter>
 bsr      calc_wgrect_overlaps

 move.l   WGRECTS(sp),a3
 bra.b    fly_nxt1
fly_loop1:
 move.l   a4,a1
 lea      4(a3),a0                 ; WGRECT.grect
 move.w   g_x(a0),d0
 sub.w    g_x(a6),d0
 swap     d0
 move.w   g_y(a0),d0
 sub.w    g_y(a6),d0
 bsr      mfdb_to_scr
 move.l   (a3),a0
 move.l   wg_freelist,(a3)
 move.l   a3,wg_freelist
 move.l   a0,a3
fly_nxt1:
 move.l   a3,d0
 bne.b    fly_loop1

* 3. verbleibendes gerettetes Rechteck verschieben

 lea      GRECTINT(sp),a1          ; dstg
 move.l   GRECTNEU(sp),(a1)
 move.l   GRECTNEU+g_w(sp),g_w(a1)
 move.l   a6,a0                    ; scrg
 bsr      grects_intersect
 beq      fly_no_inter             ; ueberschneiden sich nicht

 lea      GRECTINT(sp),a0
 move.w   g_x(a6),d0
 sub.w    d0,g_x(a0)
 move.w   g_y(a6),d0
 sub.w    d0,g_y(a0)               ; Durchschnitt relativ zum alten GRECT
 bsr      grect_to_orect_s
 lea      GRECTINT(sp),a0          ; Zielg
 sub.w    d6,g_x(a0)
 sub.w    d7,g_y(a0)
 bsr      grect_to_orect_d

 pea      (a4)                     ; Ziel
 pea      (a4)                     ; Quelle
 moveq    #3,d0                    ; mode = nur_Quelle
 bsr      vro_cpyfm
 addq.l   #8,sp

* Bildschirm nach Hintergrund-MFDB

fly_no_inter:
 bsr      alloc_wgrect             ; WGRECT holen
 move.l   a0,WGRECTS(sp)           ; Liste beginnt bei 28(sp)
 clr.l    (a0)                     ; Liste ist hier zu Ende
 move.l   GRECTNEU(sp),4(a0)
 move.l   GRECTNEU+g_w(sp),4+g_w(a0)    ; neues Rechteck ins WGRECT holen

 lea      WGRECTS(sp),a2           ; Listenanfang
 move.l   a0,a1                    ; unser neues Rechteck
 move.l   a6,a0                    ; altes Rechteck ist <cutter>
 bsr      calc_wgrect_overlaps

 move.l   WGRECTS(sp),a3
 bra.b    fly_nxt2
fly_loop2:
 move.l   a4,a1
 lea      4(a3),a0                 ; WGRECT.grect
 move.w   g_x(a0),d0
 sub.w    GRECTNEU+g_x(sp),d0
 swap     d0
 move.w   g_y(a0),d0
 sub.w    GRECTNEU+g_y(sp),d0
 bsr      scr_to_mfdb
 move.l   (a3),a0
 move.l   wg_freelist,(a3)
 move.l   a3,wg_freelist
 move.l   a0,a3
fly_nxt2:
 move.l   a3,d0
 bne.b    fly_loop2

* Box-MFDB nach Bildschirm

fly_drawbox:
 lea      MFDB_BOX(sp),a1
 lea      GRECTNEU(sp),a0
 moveq    #0,d0
 bsr      mfdb_to_scr
 jsr      mouse_on

* Box auch logisch verschieben

 move.l   GRECTNEU+g_x(sp),g_x(a6) ; neues GRECT eintragen

fly_free:
 move.l   MFDB_BOX+fd_addr(sp),a0
 jsr      smfree                   ; Speicher fuer Box wieder freigeben

 move.w   #260,d0
 bsr      graf_mouse               ; previous form

/*
 bsr      restore_mouse

 lea      saved_mouse,a1
 lea      MOUSE(sp),a0
 moveq    #41-1,d0
fly_rs_loop:
 move.w   (a0)+,(a1)+
 dbra     d0,fly_rs_loop
*/

fly_ende:
 adda.w   #SPT,sp
 movem.l  (sp)+,d7/d6/d5/a3/a4/a5/a6
 rts


**********************************************************************
*
* PUREC int scrg_sav(a0 = GRECT *g, a1 = void **pbuf)
*
* Rettet einen Bildschirmausschnitt in einen zu allozierenden
* Puffer. Schreibt bei Erfolg die Adresse des Puffers nach <*pbuf>.
* Der Puffer enthaelt erst das GRECT, dann den MFDB und schliesslich
* die Daten.
*
* Gibt 0 bei Fehler, 1 bei OK zurueck
*
* Ist <pbuf> = -1, wird der feste Bildschirmpuffer verwendet.
*

scrg_sav:
 movem.l  a5/a2/d7,-(sp)
 move.l   a1,a5                    ; a5 = pbuf

 move.l   a0,-(sp)
 jsr      set_full_clip
 move.l   (sp)+,a2

 moveq    #15,d0                   ; fuers Aufrunden
 add.w    g_w(a2),d0               ; Breite in Pixeln
 lsr.w    #4,d0                    ; in Worte umrechnen (aufrunden)
 move.w   d0,d7                    ; Breite in Worten merken
 mulu     nplanes,d0               ; * planes (< 32767 hoffentlich)
 mulu     g_h(a2),d0               ; * Hoehe
 add.l    d0,d0                    ; in Bytes umrechnen
 add.l    #8+20,d0                 ; + sizeof(GRECT) + sizeof(MFDB)
 cmpa.l   #-1,a5                   ; festen Puffer verwenden?
 bne.b    ssav_no_intern2          ; nein
 clr.w    scrbuf+g_w               ; zunaechst auf ungueltig (w = 0).
 cmp.l    screenbuf_len,d0
 bhi      ssav_err                 ; fester Puffer zu klein
 lea      scrbuf,a0
 move.l   (a2)+,(a0)+
 move.l   (a2),(a0)+               ; GRECT kopieren
 move.l   a0,a1                    ; a1 = MFDB *
 addq.l   #4,a0                    ; fd_addr nicht aendern
 bra.b    ssav_both_2
ssav_no_intern2:
 jsr      smalloc
 ble.b    ssav_err                 ; zuwenig Speicher, return(0)

 move.l   d0,a0                    ; -> GRECT,MFDB,mem
 move.l   a0,(a5)                  ; fuer die Rueckgabe merken
 move.l   (a2)+,(a0)+
 move.l   (a2),(a0)+               ; GRECT kopieren

 move.l   a0,a1                    ; a1 = MFDB *
 add.l    #8+20,d0
 move.l   d0,(a0)+                 ; fd_addr
ssav_both_2:
 move.l   (a2),(a0)+               ; fd_w,fd_h
 move.w   d7,(a0)+                 ; fd_wdwidth
 clr.w    (a0)+                    ; fd_stand
 move.w   nplanes,(a0)             ; Planes soviele wie Bildschirm

 moveq    #0,d0                    ; Zielx, Ziely = 0
;move.l   a1,a1
 lea      -8(a1),a0                ; GRECT liegt vor MFDB
 bsr      scr_to_mfdb
 moveq    #1,d0                    ; OK
ssav_ende:
 movem.l  (sp)+,a5/a2/d7
 rts
ssav_err:
 moveq    #0,d0                    ; return(0)
 bra.b    ssav_ende


**********************************************************************
*
* PUREC void scrg_rst(a0 = void **pbuf )
*
* Holt den Bildschirminhalt zurueck. Ist <pbuf> = -1, wird der feste
* Bildschirmpuffer verwendet, ansonsten ist *pbuf der Puffer. Wenn
* *pbuf = NULL ist, war beim Allozieren ein Fehler aufgetreten
*

scrg_rst:
 move.l   a2,-(sp)
 move.l   a0,-(sp)
 jsr      set_full_clip
 move.l   (sp)+,a0
 cmpa.l   #-1,a0
 bne.b    ssrst_no_intern
 lea      scrbuf,a0                ; interner Puffer
 tst.w    g_w(a0)                  ; gueltig (w != 0)?
 beq.b    ssrst_ende               ; nein, Fehler
 clr.l    -(sp)                    ; nichts freigeben
 bra.b    ssrst_both
ssrst_no_intern:
 move.l   (a0),d0
 beq.b    ssrst_ende               ; Fehler
 clr.l    (a0)
 move.l   d0,-(sp)                 ; GRECT
 move.l   d0,a0                    ; GRECT
ssrst_both:
 lea      8(a0),a1                 ; MFDB
 moveq    #0,d0
 bsr      mfdb_to_scr
 move.l   (sp)+,d0
 beq.b    ssrst_ende
 move.l   d0,a0
 jsr      smfree
ssrst_ende:
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* PUREC void fast_save_scr( GRECT *g )
*
* void fast_save_scr(a0 = GRECT *g)
*
* Rundet das GRECT auf Wortgrenzen auf und rettet den Bildschirm
*

fast_save_scr:
 move.w   (a0)+,d0
 move.l   (a0)+,d1
 move.w   (a0)+,-(sp)              ; h kopieren
 move.w   d0,d2
 andi.w   #15,d2
 add.w    d2,d1                    ; w korrigieren
 add.w    #15,d1
 and.w    #!15,d1                  ; w auf naechste obere  Wortgrenze
 move.l   d1,-(sp)
 andi.w   #!15,d0                  ; x auf naechste untere Wortgrenze
 move.w   d0,-(sp)
 moveq    #0,d0
 lea      (sp),a0
 lea      -1,a1                    ; festen Puffer verwenden
 bsr      scrg_sav
 addq.l   #8,sp
 rts


**********************************************************************
*
* void restore_scr( void )
*

restore_scr:
 lea      -1,a0                    ; von festem Puffer restaurieren
 bra.b    scrg_rst


**********************************************************************
*
* PUREC void frm_xdial(WORD flag, GRECT *little, GRECT *big,
*                        void **flyinf)
*

frm_xdial:
 move.l   a2,-(sp)
 move.l   8(sp),a2            ; flyinf
 bsr.b    __fm_xdial
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* void __fm_xdial(d0 = int flag, a0 = GRECT *little, a1 = GRECT *big,
*                 a2 = void **flyinf)
*
* flag = 0   (FMD_START)  : normaler Dialogbeginn (Dummyfunktion)
* flyinf != NULL          : Dialogbeginn, Bildschirm in <flyinf> retten
* flag = 3   (FMD_FINISH) : normales Dialogende (Redraw)
* flyinf != NULL          : Dialogende, Bildschirm aus <flyinf> restaurieren
*

__fm_xdial:
 movem.l  a4/a5,-(sp)
 move.l   a1,a4                    ; a4 = big
 move.l   a2,a5                    ; a5 = flyinf
 move.w   d0,-(sp)
 move.l   a0,-(sp)                 ; little
 jsr      set_full_clip
 move.l   (sp)+,a0
 move.w   (sp)+,d0
 beq      fmd_start
 lea      graf_growbox(pc),a1
 subq.w   #1,d0
 beq.b    fmd_grow                 ; FMD_GROW
 subq.w   #1,d0
 beq.b    fmd_shrink               ; FMD_SHRINK
 subq.w   #1,d0
 bne.b    fmd_ende
* FMD_FINISH
 move.l   a5,d0
 beq      fmd_finish
 bmi      fmd_xfinish              ; -1 uebergeben
 move.l   (a5),d0
 bgt      fmd_xfinish
fmd_finish:
 move.l   a4,a0
 jsr      wind0_draw
 move.l   a4,a0                    ; GRECT *big
 jsr      send_all_redraws
 bra.b    fmd_ende
* FMD_START
fmd_start:
 move.l   a5,d0
 beq      fmd_ende
 bra      fmd_xstart
* FMD_SHRINK
fmd_shrink:
 lea      graf_shrinkbox(pc),a1
* FMD_GROW
fmd_grow:
 move.l   a4,-(sp)                 ; GRECT *big
 move.l   a0,-(sp)                 ; GRECT *little
 jsr      (a1)                     ; graf_????box()
 addq.l   #8,sp
fmd_ende:
 movem.l  (sp)+,a4/a5
 rts

fmd_xstart:
 move.l   a4,a1
 cmpa.l   #-1,a5
 bne.b    fmd_no_intern

 lea      full_g,a0
 jsr      grects_intersect
 move.l   a5,a1                    ; -1
 move.l   a4,a0                    ; GRECT
 bsr      scrg_sav
 tst.w    d0
 bne      fmd_ende
 bra      fatal_err

fmd_no_intern:
 bsr      grect_in_scr             ; liegt <a4> in desk_g ?
 beq.b    fmd_m1                   ; nein, Box zu gross
 move.l   a5,a1
 move.l   a4,a0                    ; GRECT
 bsr      scrg_sav
 bra      fmd_ende
fmd_m1:
 clr.l    (a5)                     ; (FLYINF *) ist jetzt NULL
 bra      fmd_ende

fmd_xfinish:
 move.l   a5,a0
 bsr      scrg_rst
 bra      fmd_ende


**********************************************************************
*
* void scr_to_mfdb( a0 = GRECT *g, a1 = MFDB *mfdb, d0 = dstx_y)
*
* a0 gibt das Bildschirmrechteck an, das nach <mfdb> nach Offset
* (dst_x_y) gerettet wird
*

scr_to_mfdb:
 move.l   a1,-(sp)

 move.l   g_w(a0),-(sp)
 move.l   d0,-(sp)
;move.l   a0,a0
 bsr.s    grect_to_orect_s
 move.l   sp,a0                    ; Zielg
 bsr.s    grect_to_orect_d
 addq.l   #8,sp

 clr.l    mfdb1                    ; fd_addr der Quelle ist Bildschirm
 bsr      mouse_off
;move.l   (sp)+,-(sp)              ; Ziel
 pea      mfdb1                    ; Quelle
 moveq    #3,d0                    ; mode = nur_Quelle
 bsr      vro_cpyfm
 addq.l   #8,sp
 bra      mouse_on


**********************************************************************
*
* void mfdb_to_scr( a0 = GRECT *g, a1 = MFDB *mfdb, d0 = long dst_x_y )
*
* a0 gibt das Bildschirmrechteck an, in den <mfdb> kopiert wird,
* der Ausschnitt liegt im mfdb bei Offset (dst_x_y)
*

mfdb_to_scr:
 move.l   a1,-(sp)

 move.l   g_w(a0),-(sp)            ; w/h
 move.l   d0,-(sp)                 ; x/y
 bsr.s    grect_to_orect_d         ; Bildschirmausschnitt
 move.l   sp,a0
 bsr.s    grect_to_orect_s         ; Puffer
 addq.l   #8,sp

 clr.l    mfdb1                    ; fd_addr des Ziels ist Bildschirm
 bsr      mouse_off
 move.l   (sp)+,a1                 ; MFDB *
 pea      mfdb1                    ; Ziel ist Bildschirm
 move.l   a1,-(sp)                 ; Quelle
 moveq    #3,d0                    ; mode = nur_Quelle
 bsr      vro_cpyfm
 addq.l   #8,sp
 bra      mouse_on

grect_to_orect_d:
 lea      vptsin+8,a1              ; Ziel- ORECT
 bra.b    grect_to_orect
grect_to_orect_s:
 lea      vptsin,a1                ; Quell- ORECT
grect_to_orect:
 move.l   (a0),(a1)+               ; GRECT in ORECT umrechnen
 move.l   (a0)+,(a1)
 move.w   (a0)+,d0
 subq.w   #1,d0
 add.w    d0,(a1)+
 move.w   (a0),d0
 subq.w   #1,d0
 add.w    d0,(a1)
 subq.l   #6,a0                    ; a0 restaurieren
 rts


**********************************************************************
*
* long gem_etvc(int errcode, int drv)
*
* etv_critic des AES
*
* Achtung: ruft ggf. (act_appl ist im Textmodus) den DOS- Manager auf.
* ungueltige Fehlercodes werden jetzt sinnvoll behandelt
* (vorher Absturz)
* Eigenen Stack etvc_stk entfernt, weil der auf dem Mac zu klein war.
*

etvc_tab:
 DC.W     0
 DC.W     al_ewritf-etvc_tab       ; E_OK
 DC.W     -1             ;    "Ihr Ausgabegeraet empfaengt keine Daten."
 DC.W     al_ewritf-etvc_tab       ; ERROR
 DC.W     -2             ;    "Laufwerk %S antwortet nicht..."
 DC.W     al_edrvnr-etvc_tab       ; EDRVNR
 DC.W     -3
 DC.W     al_edrvnr-etvc_tab       ; EUNCMD
 DC.W     -4             ;    "Daten auf Diskette in Laufwerk %S evtl. defekt"
 DC.W     al_rwfault-etvc_tab      ; E_CRC
 DC.W     -5
 DC.W     al_edrvnr-etvc_tab       ; EBADRQ
 DC.W     -6
 DC.W     al_edrvnr-etvc_tab       ; E_SEEK
 DC.W     -7
 DC.W     al_rwfault-etvc_tab      ; EMEDIA
 DC.W     -8
 DC.W     al_rwfault-etvc_tab      ; ESECNF
 DC.W     -9
 DC.W     al_ewritf-etvc_tab       ; EPAPER
 DC.W     -10
 DC.W     al_rwfault-etvc_tab      ; EWRITF
 DC.W     -11
 DC.W     al_rwfault-etvc_tab      ; EREADF
 DC.W     -12
 DC.W     al_rwfault-etvc_tab      ; EGENRL
 DC.W     -13            ;    "Diskette in Laufwerk %S ist schreibgeschuetzt"
 DC.W     al_ewrpro-etvc_tab       ; EWRPRO
 DC.W     -14
 DC.W     al_ereadf-etvc_tab       ; E_CHNG
 DC.W     -15
 DC.W     al_ewritf-etvc_tab       ; EUNDEV
 DC.W     -16
 DC.W     al_rwfault-etvc_tab      ; EBADSF
 DC.W     -17            ;    "Bitte Diskette %S in Laufw. A: einlegen!"
 DC.W     al_echgab-etvc_tab       ; EOTHER
 DC.W     1    ; Tabellen-Ende

gem_etvc:
 move.l   act_appl,a0
 tst.w    ap_wasgr(a0)             ; Grafikmodus ?
 beq      etvc_dos                 ; nein, alten (DOS-) etv-critic aufrufen
 lea      4(sp),a2
 movem.l  d3-d7/a3-a6,-(sp)
 move.w   (a2)+,d0                 ; d0 = errcode
 move.w   (a2)+,d1                 ; d1 = drv
 lea      al_ewrpro(pc),a1         ; a1 = Default-Alert
 cmpi.l   #'XMSG',(a2)+            ; erweiterter Fehlercode ?
 bne.b    getvc_nox                ; nein
 move.w   (a2)+,d0                 ; Fehlercode durch erweiterten ersetzen
 cmpi.l   #'XMSG',(a2)+            ; Fehlertext uebergeben?
 bne.b    getvc_nox                ; nein
 move.l   (a2),a1                  ; Default-Text durch erweiterten ersetzen
getvc_nox:
; Fehlercode in Text umrechnen
 lea      etvc_tab(pc),a0          ; Tabelle der Fehlercodes
getvc_loop:
 move.w   (a0)+,d2
 bgt.b    getvc_weiter             ; Tabellenende, nicht gefunden
 move.w   (a0)+,a2
 cmp.w    d2,d0                    ; Fehlercode gefunden?
 bne.b    getvc_loop               ; nein, weitersuchen
; Fehlercode gefunden
 lea      etvc_tab(pc),a1
 add.w    a2,a1

; a1 zeigt jetzt auf den Alert-String

getvc_weiter:
 move.w   d0,-(sp)                 ; urspruenglichen Fehlercode retten

; Taskwechsel verhindern

 st       no_switch

; wind_update- Status sichern
; wir bekommen die Semaphore!

 lea      upd_blockage,a0
 move.w   (a0),-(sp)
 move.w   #1,(a0)+                 ; bl_cnt = 1
 move.l   (a0),-(sp)
 move.l   act_appl,(a0)+           ; bl_app = act_appl
 move.l   (a0),-(sp)
 clr.l    (a0)                     ; upd_blockage auf den Stack
 move.l   a0,-(sp)

; wind_mctrl- Status sichern

 move.w   beg_mctrl_cnt,-(sp)
 move.l   keyb_app,-(sp)
 move.l   mouse_app,-(sp)
 move.l   mctrl_karett,-(sp)
 move.l   mctrl_mnrett,-(sp)
 move.l   mctrl_btrett,-(sp)
 move.l   mctrl_btrett+4,-(sp)     ; letzte Einstellung sichern
 clr.w    beg_mctrl_cnt            ; alles bereit machen fuer Umschaltung

 addi.b   #'A',d1
 lsl.w    #8,d1                    ; Laufwerbuchstabe "X",EOS
 move.w   d1,-(sp)
 move.l   sp,-(sp)                 ; String "X"
 moveq    #0,d1
 move.b   (a1)+,d1                 ; Defaultbutton
 move.l   sp,a0                    ; Parameter fuer _sprintf()

 bsr.s    do_aes_alert
 addq.l   #6,sp

 move.w   d0,d7
 subq.w   #1,d7
 beq.b    getvc_l1
 moveq    #1,d7
getvc_l1:

; wind_mctrl- Status restaurieren

 move.l   (sp)+,mctrl_btrett+4
 move.l   (sp)+,mctrl_btrett
 move.l   (sp)+,mctrl_mnrett
 move.l   (sp)+,mctrl_karett
 move.l   (sp)+,a0
 jsr      set_mouse_app
 move.l   (sp)+,keyb_app
 move.w   (sp)+,beg_mctrl_cnt
; wind_update- Status restaurieren
 move.l   (sp)+,a0
 move.l   (sp)+,(a0)
 move.l   (sp)+,-(a0)
 move.w   (sp)+,-(a0)              ; upd_blockage vom Stack wieder runter
 sf       no_switch
 move.w   (sp)+,d1                 ; urspruenglichen Fehlercode nach d1
 ext.l    d1
 tst.w    d7
 beq.b    gevc_ret_d1
 move.l   #$10000,d1               ; RETRY
gevc_ret_d1:
 move.l   d1,d0
 movem.l  (sp)+,a3-a6/d3-d7
 rts
etvc_dos:
 move.l   old_etvc,a0
 jmp      (a0)


**********************************************************************
*
* int do_aes_alert(a1 = char *alrts, a0 = int *val, d1 = int button)
*
* gibt eine Alertbox aus.
* Wird aufgerufen von gem_etvc und disp_err
*

do_aes_alert:
 move.l   a5,-(sp)
 suba.w   #256,sp                  ; Platz fuer Alertstring

 move.w   d1,-(sp)

 move.l   a1,a5

 move.l   a0,d0                    ; Pointer angegeben ?
 beq.b    dalt_skip                ; nein, ueberspringen
 move.l   d0,-(sp)                 ; Zeiger auf int oder long usw.
 move.l   a5,-(sp)                 ; Alertstring
 lea      10(sp),a5                ; Platz fuer 256 Bytes
 pea      (a5)                     ; Zieladresse
 jsr      _sprintf
 adda.w   #12,sp
dalt_skip:
 move.w   (sp)+,d0
 move.l   a5,a0
 bsr      form_alert

 adda.w   #256,sp
 move.l   (sp)+,a5
 rts


     IF   COUNTRY=COUNTRY_DE
al_ewrpro:     DC.B 2,'[1][Das Medium in Laufwerk %S:|ist schreibgesch',$81,'tzt.][Abbruch| Nochmal ]',0
al_edrvnr:     DC.B 2,'[2][Laufwerk %S: antwortet nicht.|Bitte Laufwerk ',$81,'berpr',$81,'fen oder|Medium einlegen!][Abbruch| Nochmal ]',0
al_rwfault:    DC.B 2,'[1][Daten auf Diskette in Laufwerk|%S: eventuell defekt.][Abbruch| Nochmal ]',0
al_ereadf:     DC.B 1,'[2][Lesefehler auf Laufwerk %S:.][Abbruch| Nochmal ]',0
al_ewritf:     DC.B 2,'[1][Ihr Ausgabeger',$84,'t empf',$84,'ngt|keine Daten.][Abbruch| Nochmal ]',0
al_echgab:     DC.B 1,'[3][Bitte Diskette %S in|Laufwerk A: einlegen!][  OK  ]',0

al_aeserr:     DC.B '[3][Falscher AES-Aufruf %L.][Abbruch]',0
al_sigerr:     DC.B '[3][System hat keinen freien Speicher mehr!][ Weiter ]',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
al_ewrpro:     DC.B 2,'[1][Disk in drive %S:|is write protected.][Cancel| Retry ]',0
al_edrvnr:     DC.B 2,'[2][Drive %S: not connected.|Check drive|or insert disk!][Cancel| Retry ]',0
al_rwfault:    DC.B 2,'[1][Data in drive|%S: may be damaged.][Cancel| Retry ]',0
al_ereadf:     DC.B 1,'[2][Read error on drive %S:.][Cancel| Retry ]',0
al_ewritf:     DC.B 2,"[1][Output device hasn't received|any data.][Cancel| Retry ]",0
al_echgab:     DC.B 1,'[3][Please insert|disk %S into drive A: ?][  OK  ]',0

al_aeserr:     DC.B '[3][AES call %L not implemented.][Cancel]',0
               ;    al_fserr:      DC.B '[1][Not enough memory for|file selector!][Cancel]',0
al_sigerr:     DC.B '[3][System is out of memory!][Continue]',0
     ENDIF
     IF  COUNTRY=COUNTRY_FR
al_ewrpro:     DC.B 2,'[1][La disquette dans le lecteur %S:|est prot',$82,'g',$82,'e en ',$82,'criture.][Abandon| R',$82,'peter ]',0
al_edrvnr:     DC.B 2,'[2][Lecteur %S: ne r',$82,'pond pas.|V',$82,'rifiez le lecteur ou|ins',$82,'rez une disquette !][Abandon| R',$82,'peter ]',0
al_rwfault:    DC.B 2,'[1][Donn',$82,'es sur disquette du lecteur|%S: ',$82,'ventuellement d',$82,'fectueuses.][Abandon | R',$82,'peter ]',0
al_ereadf:     DC.B 1,'[2][Erreur de lecture sur lecteur %S:.][Abandon| R',$82,'peter ]',0
al_ewritf:     DC.B 2,'[1][Votre p',$82,'riphique de sortie ne|re',$87,'oit pas de donn',$82,'es.][Abandon| R',$82,'peter ]',0
al_echgab:     DC.B 1,'[3][Svp, ins',$82,'rez disquette %S |dans le lecteur A: !][  OK  ]',0

al_aeserr:     DC.B '[3][Appel AES %L erron',$82,'.][Abandon]',0
               ;    al_fserr:      DC.B '[1][M',$82,'moire insuffisante pour|s',$82,'lection de fichiersl!][Abandon]',0
al_sigerr:     DC.B '[3][Le syst',$8a,'me n''a plus de m',$82,'moire libre!][ Suite ]',0
     ENDIF
     EVEN


**********************************************************************
*
* int form_error(d0 = int errcode)
*
* d0 ist ein MSDOS- Fehlercode
*

form_error:
 ext.l    d0
 bmi.b    fe_gemdos                ; ist schon GEMDOS- Code
 neg.l    d0
 subi.l   #31,d0                   ; umrechnen in GEMDOS- Fehler
fe_gemdos:
 suba.l   a0,a0                    ; kein Dateiname
 bsr.s    form_xerr
 moveq    #0,d0                    ; Rueckgabe immer 0
 rts


**********************************************************************
*
* PUREC long form_xerr(d0 = long errcode, a0 = char *err_file)
*
* aus KAOSDESK, Fehlertexte aus GEMDOS
*

     IF   COUNTRY=COUNTRY_DE
pgm_s:    DC.B "Programm gab zur",$81,"ck :|",0
err_s:    DC.B "| |(Fehler #%L)|][Abbruch]",0
     ENDIF
     IF   COUNTRY=COUNTRY_US
pgm_s:    DC.B "Program returned :|",0
err_s:    DC.B "| |(Error #%L)|][Cancel]",0
     ENDIF
    IF  COUNTRY=COUNTRY_FR
pgm_s:    DC.B "Le programme a retourn",$82," :|",0
err_s:    DC.B "| |(Erreur #%L)|][Abandon]",0
     ENDIF
     EVEN

form_xerr:
 movem.l  a2/d7/a5/a4/a3,-(sp)
 suba.w   #100,sp
 move.l   d0,d7                    ; E_OK
 beq      eal_ende
 cmpi.w   #-$44,d7                 ; (int) EBREAK
 beq      eal_ende
 move.l   a0,a5                    ; a5 = err_file
 move.l   #$330002,-(sp)           ; Sconfig(SC_VARS)
 trap     #1
 addq.l   #4,sp
 move.l   d0,a0                    ; Zeiger auf DOS- Variablen
 move.l   50(a0),a0                ; err_to_str
 move.b   d7,d0                    ; laut KAOS- Doku
 jsr      (a0)
 move.l   a0,a4                    ; errstr
 move.l   sp,a3                    ; hier kommt der Alertstring rein
 move.l   #'[3][',(a3)+
 move.l   a5,d0
 addq.l   #1,d0
 bne.b    eal_nopgm
 lea      pgm_s(pc),a1
eal_loop1:
 move.b   (a1)+,(a3)+
 bne.b    eal_loop1
 subq.l   #1,a3
 bra.b    eal_cat_errs
eal_nopgm:
 move.l   a5,d0
 beq.b    eal_cat_errs
 cmpi.b   #':',1(a5)
 bne.b    eal_nodrv
 move.b   (a5),d0
 beq.b    eal_nodrv
 addq.l   #1,a5
 jsr      toupper
 move.b   d0,(a3)+                 ; Laufwerkname
 move.b   (a5)+,(a3)+              ; ':'
eal_nodrv:
 move.l   a5,a0
 jsr      fn_name
eal_loop2:
 move.b   (a0)+,(a3)+              ; Dateiname
 bne.b    eal_loop2
 move.b   #'|',-1(a3)              ; neue Zeile
eal_cat_errs:
 move.b   (a4)+,(a3)+
 bne.b    eal_cat_errs             ; Fehlertext
 subq.l   #1,a3
 move.l   d7,d0
 ext.l    d0                       ; nur Wort auswerten
 move.l   d0,-(sp)
 pea      (sp)                     ; Zeiger auf %L
 pea      err_s(pc)
 move.l   a3,-(sp)
 jsr      _sprintf
 lea      16(sp),sp
 move.l   sp,a0
 moveq    #1,d0
 bsr      form_alert
eal_ende:
 move.l   d7,d0
 adda.w   #100,sp
 movem.l  (sp)+,d7/a5/a4/a3/a2
 rts


     END

