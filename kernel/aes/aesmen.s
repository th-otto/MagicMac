**********************************************************************
**********************************************************************
*
* MENU MANAGER (+ Desktophintergrund)
*

     INCLUDE "aesinc.s"
     INCLUDE "basepage.inc"
     
        TEXT

XMENU     EQU  1

     XREF      obj_to_g,_objc_find,_objc_draw,objc_add
     XREF      set_full_clip
     XREF      _objc_change
     XREF      fast_save_scr,restore_scr                    ; AESFRM
     XREF      _evnt_multi
     XREF      strplc_pcolor,draw_line,draw_bitblk
     XREF      any_app,send_click,appl_yield
     XREF      wind0_draw,set_topwind_app,set_apname
     XREF      leerstring

     XREF      set_clip_grect
     XREF      mouse_off
     XREF      mouse_on
     XREF      mctrl_0
     XREF      mctrl_1
     XREF      vro_cpyfm
     XREF      __fm_xdial
     XREF      evnt_button
     XREF      objc_delete
     XREF      _objc_offset
     XREF      xy_in_grect
     XREF      grects_intersect
     XREF      grects_union
     XREF      graf_mouse

     XDEF      desk_on,desk_off
     XDEF      menu_on,menu_off,menu_new,menu_draw
     XDEF      menu_register,menu_unregister
     XDEF      menu_modify
     XDEF      _menu_off
     XDEF      _scmgr_reinit

     IFEQ XMENU
     XDEF      do_menu
     ENDIF

     XDEF      set_desktop
     XDEF      objc2mgrect

     XDEF      menu_attach
     XDEF      menu_istart
     XDEF      menu_settings
     XDEF      menu_popup

     XREF      update_0,update_1

* von AESOBJ

     XREF      stw_title

* von STD

     XREF      mmalloc
     XREF      mfree

* von MTSMN

     IF   XMENU
     XDEF      mn_at_get
     XDEF      vmn_set
     XREF      smn_popup
     ENDIF


**********************************************************************
*
* void objc2mgrect(a0 = OBJECT *, a1 = MGRECT *mg,
*                  d0 = int objnr, d1 = int flag)
*

objc2mgrect:
 move.w   d1,(a1)+                 ; mg_flag setzen, a1=Zeiger auf mg_grect
;move.w   d0,d0                    ; objnr
;move.l   a0,a0
 jmp      obj_to_g


**********************************************************************
*
* PUREC WORD menu_modify( OBJECT *tree, WORD objnr, WORD statemask,
*                        WORD active, WORD do_draw, WORD not_disabled);
*
* int menu_modify(a0 = OBJECT *tree, d0 = int objnr,
*                 d1 = int statemask, d2 = char active,
*                 int do_draw, char not_disabled)
*
* statemask    = SELECTED oder CHECKED oder DISABLED
* active       = TRUE:  state setzen
*                FALSE: state loeschen
* not_disabled = TRUE: wenn Objekt DISABLED ist, return(0)
* do_draw      = 1: malen, wenn es das aktive Menue ist
*              = 2: immer malen
*              = 0: nicht malen
*

menu_modify:
 clr.l    -(sp)                    ; do_draw ist FALSE, newstate ist Dummy
 move.w   d0,-(sp)                 ; objnr
 move.l   a0,-(sp)                 ; tree
 muls     #OBJECT_SIZE,d0
 move.w   ob_state(a0,d0.l),d0     ; d0 = aktueller Status
 tst.b    7+10(sp)                 ; DISABLED pruefen ?
 beq.b    mmo_go                   ; nein
 btst     #3,d0                    ; DISABLED ?
 beq.b    mmo_go                   ; nein
 moveq    #0,d0
 bra.b    mmo_dont                 ; nix tun
mmo_go:
 tst.b    d2                       ; aktivieren ?
 beq.b    mmod_l1
 or.w     d1,d0                    ; aktivieren => statemask ORen
 bra.b    mmod_l2
mmod_l1:
 not.w    d1
 and.w    d1,d0                    ; deaktivieren => statemask loeschen
mmod_l2:
 move.w   d0,6(sp)                 ; newstate eintragen
 move.w   4+10(sp),d0              ; do_redraw ?
 beq.b    mmo_nodraw
 subq.w   #2,d0
 beq.b    mmo_draw                 ; immer zeichnen
 cmpa.l   menutree,a0              ; Menue wird gerade angezeigt ?
 beq.b    mmo_draw                 ; ja, zeichnen
 tst.w    beg_mctrl_cnt            ; laeuft ein BEG_MCTRL ?
 beq.b    mmo_nodraw               ; nein, nicht zeichnen
 cmpa.l   mctrl_mnrett,a0          ; ist gefrorenes Menue ?
 bne.b    mmo_nodraw               ; nein
mmo_draw:
 jsr      set_full_clip            ; Clipping ausschalten
 st.b     8+1(sp)                  ; do_draw = TRUE
mmo_nodraw:
 move.l   (sp)+,a0
 move.w   (sp)+,d0
 move.w   (sp)+,d1
 move.w   (sp)+,d2
 jsr      _objc_change
 moveq    #1,d0                    ; kein Fehler
 rts
mmo_dont:
 adda.w   #10,sp
 rts


     IFEQ XMENU
**********************************************************************
*
* int sel_dsel_menu(d0 = int objnr, d1 = int prevobjnr, d2 = int state,
*                   a0 = OBJECT *tree)
*

sel_dsel_menu:
 cmp.w    #$ffff,d0
 beq.b    sdsm_l1
 cmp.w    d1,d0
 beq.b    sdsm_l1
 move.w   #1,-(sp)                 ; wenn DISABLED, nix tun
 move.w   #1,-(sp)                 ; neu zeichnen, wenn aktives Menue
;move.w   d2,d2                    ; active
 moveq    #1,d1                    ; SELECTED
;move.w   d0,d0                    ; objnr
;move.l   a0,a0                    ; tree
 bsr      menu_modify
 addq.w   #4,sp
 rts
sdsm_l1:
 moveq    #0,d0
 rts


**********************************************************************
*
* void sav_rst_menu(d0 = int objnr, a0 = OBJECT *tree, d1 = int sav)
*

sav_rst_menu:
 subq.l   #8,sp                    ; Platz fuer ein GRECT
 lea      (sp),a1
;move.w   d0,d0
;move.l   a0,a0
 move.w   d1,-(sp)                 ; Flag merken
 jsr      obj_to_g
 subq.w   #1,g_x+2(sp)
 subq.w   #1,g_y+2(sp)
 addq.w   #2,g_w+2(sp)
 addq.w   #2,g_h+2(sp)
 tst.w    (sp)+
 lea      (sp),a0
 beq.b    srmn_l1
 jsr      fast_save_scr            ; schneidet mit Schirm und full_clip()
 bra.b    srmn_l2
srmn_l1:
 jsr      restore_scr
srmn_l2:
 addq.l   #8,sp
 rts


**********************************************************************
*
* int do_menu( void *retvals)
*
* Rueckgabe 0, wenn Menue abgebrochen, d.h. nichts angewaehlt,
* sonst != 0
*
* Rueckgabewerte:
*    retvals        int       titel
*    retvals+2      int       Menueeintrag
*    retvals+4      OBJECT *  Objektbaum (ggf. Submenue)
*    retvals+8      int       Parentobjekt des Menues
*
* Aufbau eines Menues:
*    Objekt 0       IBOX      umfasst Bildschirm und Menueleiste
*    Objekt 1       BOX       weisse Box, Menueleiste
*    Objekt 2       IBOX      Parent fuer alle Menuetitel
*    Objekt 3...n   TITLE     Menuetitel
*    Objekt n+1     IBOX      Bildschirm ohne Menueleiste, Parent fuer Menues
*
*
* d3           : int pentry,  vorheriger Menueeintrag
* d4           : int pmenu,   vorheriges Dropdownmenue
* d5           : int entry,   Objektnummer des Menueeintrags
* d6           : int menu,    Objektnummer des heruntergefallenen Menues
*
* -$38(a6)     : int dsacc,   Ungueltig gemachte ACC- Eintraege
* -$36(a6)     : int tstate,  ob_state des Menuetitels
* -$34(a6)     : int out[6],  Rueckgabe von _evnt_multi
*                -$34(a6)     x
*                -$32(a6)     y
*                -$30(a6)     bstate
*                -$2e(a6)     kstate
*                -$2c(a6)     key
*                -$2a(a6)     nclicks
* -$28(a6)     : int ob2,     Objektnummer fuer erstes Mausrechteck
* -$26(a6)     : int fn,      Funktionscode 1..4
* -$24(a6)     : MGRECT mm2,  zweites Mausrechteck
* -$1a(a6)     : MGRECT mm1,  erstes Mausrechteck
* -$10(a6)     : int evts,    eingetroffene EVENTs
*  -$e(ap)     : int ptit,    vorheriger Menuetitel
*  -$c(a6)     : int flag1,   mg_flag fuer mm1
*  -$a(a6)     : int tit,     Menuetitel
*   -8(a6)     : int ende,    Schleifenkontrolle, Abbruch, wenn != 0
*   -6(a6)     : int mtypes,  Eventtypen fuer _evnt_multi
*   -4(a6)     : long but,    Buttonstatus fuer _evnt_multi
*

do_menu:
     IFNE SUBMEN
 tst.l    xmenu_info
 beq.b    _dmn
 move.l   xmenu_info,a2
 move.l   16(a2),a2
 jmp      (a2)
_dmn:
     ENDIF
 link     a6,#-$38
 movem.l  d3/d4/d5/d6/a5,-(sp)
 move.l   #$10101,-4(a6)           ; st=1(gedrueckt),msk=1(linke),n=1
 move.w   gr_mkmstate,d0
 andi.w   #1,d0
 eor.w    d0,-2(a6)
 move.l   menutree,a5              ; a5 ist das zu zeigende Menue
 move.l   a5,a0
 bsr      modify_acc_menu
 move.w   d0,-$38(a6)
 clr.w    -$26(a6)                 ; zunaechst Unterfunktion 0
 clr.w    -8(a6)                   ; Schleife noch nicht beenden
 moveq    #-1,d5                   ; Eintrag ungueltig
 moveq    #-1,d6                   ; Dropdown-Menue ungueltig
 move.w   d6,-$a(a6)               ; Menuetitel ungueltig
/*
 jsr      save_mouse               ; Mausdaten retten
*/
 bra      domn_l15

* while(-8(a6) == 0)

domn_l1:
 move.w   #6,-6(a6)                ; mtypes = MU_BUTTON+MU_M1
 move.w   #1,-$c(a6)               ; bei mm1 warten auf Verlassen
 move.w   -$26(a6),d0
 beq.b    dmn_case_0               ; case 0
 subq.w   #1,d0
 beq.b    dmn_case_1               ; case 1
 subq.w   #1,d0
 beq.b    dmn_case_2               ; case 2
 bra.b    dmn_case_3               ; case 3


* case 0:
* Der Mauszeiger befindet sich innerhalb der Menueleiste.
* Wir warten auf das Beruehren eines Menuetitels oder dass der
* Menuebalken verlassen wird.


dmn_case_0:
* mm1 festlegen
 move.w   #2,-$28(a6)              ; Objekt 2, alle Menuetitel
 clr.w    -$c(a6)                  ; Bei mm1 warten auf Betreten
* mm2 initialisieren
 ori.w    #8,-6(a6)                ; mtypes |= MU_M2
 moveq    #1,d1                    ; Warten auf Verlassen
 moveq    #1,d0                    ; Objektnummer 1 (Menuebalken)
 lea      -$24(a6),a1              ; MGRECT
 move.l   a5,a0                    ; Objektbaum
 bsr      objc2mgrect

 bra.b    dmn_endswitch


* case 1:
* Ein heruntergefallenes Menue ziert den Bildschirm, und der Mauszeiger
* schwebt noch ueber dem Menuetitel
* wir warten darauf, dass der Menuetitel verlassen wird


dmn_case_1:
 move.w   -$a(a6),-$28(a6)         ; Menuetitel fuer mm1
 bra.b    dmn_endswitch

* case 3:
* Ein heruntergefallenes Menue ziert den Bildschirm, aber der Mauszeiger
* befindet sich ausserhalb dieses Menues.
* Wir warten darauf, dass das Menue betreten wird oder ein anderer Menuetitel
* beruehrt wird

dmn_case_3:
* mm1 festlegen
 move.w   #2,-$28(a6)              ; Objekt 2, alle Menuetitel
 clr.w    -$c(a6)                  ; Bei mm1 warten auf Betreten
* mm2 festlegen
 ori.w    #8,-6(a6)                ; mtypes |= MU_M2
 moveq    #0,d1                    ; warten auf Betreten
 move.w   d6,d0                    ; Objektnummer d6, Dropdown- Menue
 lea      -$24(a6),a1              ; MGRECT
 move.l   a5,a0
 bsr      objc2mgrect

 bra.b    dmn_endswitch


* case 2:
* Der Mauszeiger schwebt ueber einem Eintrag
* wir warten darauf, dass der Menueeintrag verlassen wird oder dass die
* linke Maustaste sich aendert


dmn_case_2:
* mm1 festlegen
 move.w   d5,-$28(a6)              ; Objektnummer von mm1: entry (Menueeintrag)
 move.w   gr_mkmstate,d0           ; Maustastenstatus
 and.w    #1,d0                    ; linke Maustaste gedrueckt ?
 beq.b    domn_l2                  ; nein
 move.l   #$10100,d0               ; warten auf Loslassen
 bra.b    domn_l3
domn_l2:
 move.l   #$10101,d0               ; warten auf Druecken
domn_l3:
 move.l   d0,-4(a6)


* END switch


dmn_endswitch:
 move.w   -$c(a6),d1               ; mg_flag (Betreten oder Verlassen)
 move.w   -$28(a6),d0              ; Objektnummer
 lea      -$1a(a6),a1              ; MGRECT
 move.l   a5,a0
 bsr      objc2mgrect

 pea      -$34(a6)                 ; Ausgabearray
 clr.l    -(sp)                    ; mbuf (fuer mesag)
 move.l   -4(a6),-(sp)             ; but
 clr.l    -(sp)                    ; ms (fuer timer)
 pea      -$24(a6)                 ; GRECT *mm2
 pea      -$1a(a6)                 ; GRECT *mm1
 move.w   -6(a6),-(sp)             ; mtypes
 jsr      _evnt_multi
 adda.w   #$1a,sp
 move.w   d0,-$10(a6)              ; eingetroffene EVENTs
 btst     #EVB_BUT,-$f(a6)         ; MU_BUTTON ?
 beq.b    domn_l5                  ; nein
* MU_BUTTON ist eingetroffen

 cmpi.w   #1,-$26(a6)              ; Funktionscode 1 ?
 beq.b    domn_l4                  ; ja
* MU_BUTTON, nicht Funktionscode 2 => Prozedur beenden
 move.w   #1,-8(a6)
 bra.b    domn_l5
domn_l4:
 eori.w   #1,-2(a6)                ; erwarteten Status toggeln
domn_l5:
 tst.w    -8(a6)                   ; Prozedur beenden ?
 bne      domn_l15                 ; ja
 move.w   -$a(a6),-$e(a6)          ; aktuellen Menuetitel retten
 move.w   d5,d3                    ; Menueeintrag nach d3
 move.w   d6,d4

 move.l   -$34(a6),d2              ; x,y (Mausposition bei Event)
 moveq    #1,d1                    ; eine Ebene
 moveq    #2,d0                    ; ab Objekt 2 (alle Menuetitel)
 move.l   a5,a0
 jsr      _objc_find

 cmpi.w   #-1,d0                   ; gueltig ?
 beq.b    domn_l6                  ; nein
 move.w   d0,-$a(a6)               ; gefundenen (?) Menuetitel
 movea.l  a5,a0
 muls     #$18,d0
 move.w   ob_state(a0,d0.l),-$36(a6)    ; seinen ob_state merken
 cmpi.w   #8,-$36(a6)              ; DISABLED ?
 beq.b    domn_l6                  ; ja, ungueltig
 moveq    #-1,d5
 move.w   #1,-$26(a6)              ; Funktionscode 1
 bra.b    domn_l10
domn_l6:
 move.w   -$e(a6),-$a(a6)          ; war ungueltig, vorherigen wieder einsetzen
 cmp.w    #$ffff,d4                ; Menue heruntergefallen, Objnr gueltig ?
 beq.b    domn_l9                  ; nein

 move.l   -$34(a6),d2              ; x,y (Mausposition bei Event)
 moveq    #1,d1                    ; eine Ebene
 move.w   d4,d0                    ; ab Objekt d4
 move.l   a5,a0
 jsr      _objc_find

 move.w   d0,d5                    ; d5 = Menueeintrag
 cmp.w    #$ffff,d5                ; gueltig ?
 beq.b    domn_l7                  ; nein
 moveq    #2,d0                    ; ja, Funktionscode 2
 bra.b    domn_l8
domn_l7:
 moveq    #3,d0                    ; Menueeintrag ungueltig, Funktionscode 3
domn_l8:
 move.w   d0,-$26(a6)              ; neuen Funktionscode merken
 bra.b    domn_l10
* Es ist kein heruntergefallenes Menue aktiv
domn_l9:
 clr.w    -$26(a6)                 ; Funktionscode 0
 cmpi.w   #8,-$36(a6)              ; Menuetitel DISABLED ?
 beq.b    domn_l10                 ; ja
 move.w   #1,-8(a6)                ; nein, Prozedur beenden
domn_l10:
 moveq    #0,d2                    ; deselektieren
 move.w   d5,d1
 move.w   d3,d0
 move.l   a5,a0
 bsr      sel_dsel_menu
 moveq    #0,d2                    ; deselektieren
 move.w   -$a(a6),d1
 move.w   -$e(a6),d0
 move.l   a5,a0
 jsr      sel_dsel_menu
 tst.w    d0
 beq.b    domn_l11

 move.w   d4,d0
 move.l   a5,a0
 moveq    #0,d1                    ; wiederherstellen
 bsr      sav_rst_menu

domn_l11:
 moveq    #1,d2                    ; selektieren
 move.w   -$e(a6),d1               ; vorheriger Menuetitel
 move.w   -$a(a6),d0               ; aktueller Menuetitel
 move.l   a5,a0
 bsr      sel_dsel_menu
 tst.w    d0                       ; wurde aktiviert ?
 beq.b    domn_l14                 ; nein, weiter

 move.w   ob_tail(a5),d0           ; enthaelt Boxen fuer die Menues
 muls     #$18,d0
 move.w   ob_head(a5,d0.l),d6      ; d6 = erstes Menue
 move.w   -$a(a6),d1
 subq.w   #3,d1                    ; d1 = 0(linkes Menue),1(naechstes) usw.
 bra.b    domn_l13
domn_l12:
 muls     #$18,d6
 move.w   ob_next(a5,d6.l),d6
 subq.w   #1,d1
domn_l13:
 bgt.b    domn_l12

 move.w   d6,d0
 move.l   a5,a0
 moveq    #1,d1                    ; retten
 bsr      sav_rst_menu

 moveq    #8,d1
 move.w   d6,d0
 move.l   a5,a0
 jsr      _objc_draw

domn_l14:
 moveq    #1,d2                    ; selektieren
 move.w   d3,d1
 move.w   d5,d0
 move.l   a5,a0
 bsr      sel_dsel_menu
domn_l15:
 tst.w    -8(a6)
 beq      domn_l1

 clr.w    -$c(a6)
 cmpi.w   #$ffff,-$a(a6)
 beq.b    domn_l17

 move.w   d6,d0
 move.l   a5,a0
 moveq    #0,d1                    ; wiederherstellen
 bsr      sav_rst_menu

 cmp.w    #$ffff,d5
 beq.b    domn_l16
 move.w   #1,-(sp)                 ; wenn DISABLED, nix tun
 clr.w    -(sp)                    ; nicht neu zeichnen
 moveq    #0,d2                    ; deaktivieren
 moveq    #1,d1                    ; SELECTED
 move.w   d5,d0                    ; objnr
 move.l   a5,a0                    ; tree
 jsr      menu_modify
 addq.w   #4,sp
 tst.w    d0
 beq.b    domn_l16
 movea.l  8(a6),a0                 ; Rueckgabewerte
 move.w   -$a(a6),(a0)+            ; int      Titel-Objekt
 move.w   d5,(a0)+                 ; int      Menue-Eintrag
* erweiterte Werte laut AES 3.3
 move.l   a5,(a0)+                 ; OBJECT * Menuebaum
 move.w   d6,(a0)                  ; int      menu_parent

 move.w   #1,-$c(a6)
 bra.b    domn_l17
domn_l16:
 move.w   #1,-(sp)                 ; wenn DISABLED, nix tun
 move.w   #1,-(sp)                 ; neu zeichnen, wenn aktives Menue
 moveq    #0,d2                    ; deaktivieren
 moveq    #1,d1                    ; SELECTED
 move.w   -$a(a6),d0               ; objnr
 move.l   a5,a0                    ; tree
 jsr      menu_modify
 addq.w   #4,sp
domn_l17:
/*
 jsr      restore_mouse            ; Mausdaten reaktivieren
*/
 move.l   a5,a0
 move.w   -$38(a6),d0
 bsr      restore_acc_menu
 move.w   -$c(a6),d0
 movem.l  (sp)+,a5/d6/d5/d4/d3
 unlk     a6
 rts
     ENDIF


**********************************************************************
*
* void menu_draw(a0 = OBJECT *tree)
*

menu_draw:
 move.l   a0,-(sp)

 jsr      set_full_clip
 moveq    #8,d1
 moveq    #1,d0
 move.l   (sp),a0
 jsr      _objc_draw               ; Menue ausgeben, ab Objekt 1

 moveq    #1,d1                    ; BLACK
 jsr      strplc_pcolor            ; Linienfarbe setzen

 move.w   menubar_grect+g_h,-(sp)  ; war gr_hhbox
 subq.w   #1,(sp)
 move.w   scr_w,-(sp)
 subq.w   #1,(sp)
 move.w   menubar_grect+g_h,-(sp)  ; war gr_hhbox
 subq.w   #1,(sp)
 clr.w    -(sp)
 jsr      draw_line                ; Linie unter die Menueleiste setzen
 addq.l   #8,sp

 move.l   (sp)+,a0                 ; Menuebaum
     IF   MACOS_SUPPORT
 cmpi.w   #G_IBOX,OBJECT_SIZE+ob_type(a0)
 beq.b    mdr_ende                 ; kein MagiC-Logo ins Mac-Menue
     ENDIF
 cmpi.w   #16,menubar_grect+g_h    ; war gr_hhbox
 bcs.b    mdr_ende                 ; Zeichensatz zu klein
 lea      magxlogo_s(pc),a1
 clr.w    -(sp)
 move.w   #BLACK,-(sp)             ; Farbe
 move.w   #TRANSPARENT,-(sp)
 move.w   (a1)+,-(sp)              ; Hoehe in Pixelzeilen
 move.w   (a1)+,-(sp)              ; Breite in Pixeln
 subq.l   #2,sp                    ; Dummy fuer Zielbreite (autom. Bildsch.)
 move.w   ob_y(a0),-(sp)           ; y - Position ganz oben
 move.w   ob_x(a0),d0
 btst     #0,look_flags+1
 bne.b    mdr_leftjust             ; Icon auf Wunsch linksbuendig
 add.w    scr_w,d0                 ; Breite des Menues ( statt ob_width(a0) )
 sub.w    4(sp),d0                 ; Breite des Icons abziehen
mdr_leftjust:
 move.w   d0,-(sp)                 ; Zielposition: rechter Rand
 clr.l    -(sp)                    ; Ziel: Bildschirm
 move.w   #2,-(sp)                 ; Quellbreite in Bytes
 clr.l    -(sp)                    ; Quellposition: bi_x,bi_y
 pea      (a1)                     ; Quelldaten
 bsr      draw_bitblk
 lea      30(sp),sp
mdr_ende:
 rts


magxlogo_s:
 DC.W     16                       ; Hoehe 14 Pixel
 DC.W     16                       ; Breite 16 Pixel
 DC.W     %0000000000000000
 DC.W     %0000001111100000
 DC.W     %0100111111111000
 DC.W     %0111111111111100
 DC.W     %0111111000011100
 DC.W     %0111110000000110
 DC.W     %0111110000000010
 DC.W     %0111111000000000
 DC.W     %0000000001111110
 DC.W     %0100000000111110
 DC.W     %0110000000111110
 DC.W     %0011100001111110
 DC.W     %0011111111111110
 DC.W     %0001111111110010
 DC.W     %0000011111000000
 DC.W     %0000000000000000


**********************************************************************
*
* void menu_on(a0 = APPL *ap, a1 = OBJECT *tree)
*
* Aufbau eines Menues:
*    Objekt 0       IBOX      umfasst Bildschirm und Menueleiste
*     Objekt 1      BOX       weisse Box, Menueleiste
*     Objekt 2      IBOX      Parent fuer alle Menuetitel
*      Objekt 3...n TITLE     Menuetitel
*     Objekt n+1    IBOX      Bildschirm ohne Menueleiste, Parent fuer Menues
*

_add:
 addq.w   #1,d5                    ; naechstes Objekt
_add2:
 move.w   d5,d1
 move.w   d7,d0                    ; wird Kind des ersten Menues
 move.l   a5,a0                    ; Baumadresse
 bra      objc_add

menu_on:
 move.l   a1,d0
 beq      menu_new                 ; Menue aus, ggf. neues suchen
 movem.l  d4/d5/d6/d7/a4/a5/a6,-(sp)
 move.l   a1,a5                    ; a5 = tree
 move.l   a0,a4                    ; a4 = app

 jsr      update_1

* Menue einschalten

 move.l   a5,ap_menutree(a4)       ; in APPL eintragen
 cmpa.l   menu_app,a4              ; ist es schon das aktuelle Menue ?
 beq.b    mon__ismine              ; ja, bin schon aktiv

* Menue neu eingeschaltet. Auf mich umschalten

 move.l   a4,menu_app              ; Eigner des Menues umsetzen
 move.l   a4,a0
 bsr      set_desktop              ; und Hintergrund mit umschalten
mon__ismine:
 move.l   a5,menutree              ; Menuebaum merken

* Set menu background color

 btst     #7,look_flags+1          ; 3D look for menu
 beq.b    mon_co_end
mon_col_loop:
 move.w	 ob_type(a5),d1
 and.w	 #$ff,d1
 cmp.w	 #G_BOX,d1                  ; G_BOX ?
 bne.s	 mon_col_box
 andi.w  #$ff80,ob_spec+2(a5)
 ori.w	 #$0070+LWHITE,ob_spec+2(a5) ; interiorcol = LWHITE, fillpattern = IP_SOLID
 bra.s	 mon_col_box1
mon_col_box:
 ori.w    #FL3DBAK,ob_flags(a5)
mon_col_box1:
 moveq    #LASTOB,d1
 movea.l  a5,a4
 lea      OBJECT_SIZE(a5),a5
 and.w    ob_flags(a4),d1
 beq.s    mon_col_loop
 move.l   menutree,a5
mon_co_end:

* Proportional-Systemfont: Menuetitel neu ausrichten

 tst.w    finfo_big+fontmono
 bne      mon_fontmono
 move.w   2*OBJECT_SIZE+ob_head(a5),d0      ; erster Menuetitel
 move.w   2*OBJECT_SIZE+ob_x(a5),d7         ; abs. Pos. des ersten Titels
 bmi      mon_fontmono             ; keine Menuetitel
 move.w   ob_tail(a5),d1           ; rechter Teil (Menues)
 mulu     #OBJECT_SIZE,d1
 move.w   ob_head(a5,d1.l),d1      ; erstes Menue
 moveq    #0,d5                    ; Pos. des ersten Titels
mon_title_loop:
 mulu     #OBJECT_SIZE,d0
 lea      0(a5,d0.l),a4            ; a4 = OBJECT *
 move.w   d5,ob_x(a4)              ; x-Pos fuer Menuetitel
 mulu     #OBJECT_SIZE,d1
 lea      0(a5,d1.l),a6
 move.w   d5,ob_x(a6)              ; Position auch fuer Menue
 add.w    d7,ob_x(a6)
 move.l   a4,a0                    ; OBJECT *
 jsr      stw_title                ; Breite setzen
 add.w    ob_width(a4),d5          ; Breite addieren
 move.w   ob_next(a6),d1           ; naechtes Menue
 move.w   ob_next(a4),d0           ; naechter Titel
 cmpi.w   #2,d0                    ; ist der Parent ?
 bne.b    mon_title_loop           ; nein
 move.w   d5,2*OBJECT_SIZE+ob_width(a5)     ; Breite des Parent setzen

* erstes Menue modifizieren: Accessories eintragen

mon_fontmono:
 lea      menu_grect,a1
 moveq    #2,d0
 move.l   a5,a0
 jsr      obj_to_g                 ; Objekt 2 ist Menuezeile

 move.w   ob_tail(a5),d1           ; rechter Teil (Menues)
 muls     #OBJECT_SIZE,d1
 move.w   ob_head(a5,d1.l),d7      ; erstes Menue

 move.w   d7,d1
 muls     #OBJECT_SIZE,d1
 move.l   #-1,ob_head(a5,d1.l)     ; ob_head und ob_tail des ersten Menues

 move.w   d7,d5
 bsr      _add                     ; "ueber ..."

 move.w   d7,d1
 muls     #OBJECT_SIZE,d1
 lea      ob_height(a5,d1.l),a0    ; Hoehe des ACC- Menues

 move.w   big_hchar,d4
 move.w   d4,(a0)                  ; Gesamthoehe
 move.w   no_of_menuregs,d0        ; Eingetragene ACCs ?
 beq.b    mon_endloop              ; nein, nur diese eine Zeile

 addq.w   #2,d0                    ; 2 Zeilen ueber den ACCs
 mulu     (a0),d0                  ; Hoehe = big_hchar * (2+no_of_menuregs)
 move.w   d0,(a0)

 bsr      _add                     ; "-------"

 add.w    d4,d4                    ; y-Position aufrechnen, beginnend bei 2
 lea      reg_entries,a4           ; Strings fuer die ACCs
 moveq    #NACCS-1,d6
mon_loop:
 addq.w   #1,d5                    ; naechstes Objekt
 tst.l    (a4)                     ; freier Eintrag ?
 beq.b    mon_noset                ; ja, ueberspringen

 bsr      _add2

 move.w   d5,d1
 muls     #OBJECT_SIZE,d1
 move.w   d4,ob_y(a5,d1.l)
 add.w    big_hchar,d4
 move.w   ob_type(a5,d1.l),d0      ; Objekttyp des Menueeintrags
 cmpi.b   #G_STRING,d0             ; Nur solche aendern, die Strings sind!
 beq.b    mon_setacc
 cmpi.b   #G_BUTTON,d0
 beq.b    mon_setacc
 cmpi.b   #G_TITLE,d0
 bne.b    mon_noset
mon_setacc:
 move.l   (a4),ob_spec(a5,d1.l)    ; String eintragen
mon_noset:
 addq.l   #4,a4                    ; naechstes ACC
mon_nxtob:
 dbra     d6,mon_loop

mon_endloop:
 move.l   a5,a0
 bsr      menu_draw                ; Menue zeichnen
 lea      menu_grect,a0
 bsr.s    scmgr_reinit

mon__ende:
 jsr      update_0

 movem.l  (sp)+,a6/a5/a4/d7/d6/d5/d4
 rts


**********************************************************************
*
* void menu_off(a0 = APPL *ap, d0 = int search_other)
*

menu_new:
 moveq    #1,d0                    ; neues suchen
menu_off:
 clr.l    ap_menutree(a0)          ; Menue "aus"tragen
 tst.l    menutree
 beq.b    moff_ende                ; war sowieso kein Menue aktiv
_menu_off:
 cmp.l    menu_app,a0              ; ist meines gerade aktiv ?
 bne.b    moff_ende                ; nein

 movem.l  a0/d0,-(sp)
 jsr      update_1                 ; jetzt wird es kritisch...
 movem.l  (sp)+,a0/d0

* Aktives Menue wurde abgeschaltet. Hat die Applikation einen Desktop ?
 move.l   ap_desktree(a0),d1
 bgt.b    mo_off                   ; ja, keine Umschaltung
 tst.w    d0                       ; andere APP suchen ?
 beq.b    mo_off                   ; nein, weiter

 jsr      any_app                  ; nein, andere APP suchen
 beq      moff_up0                 ; eine gefunden
mo_off:
 clr.l    menutree
 lea      menubar_grect,a0
 bsr.b    scmgr_reinit
moff_up0:
 jsr      update_0
moff_ende:
 rts


**********************************************************************
*
* void scmgr_reinit( a0 = GRECT *scmgr_grect )
*
* Gewaehrt dem screnmgr einen dummy- Durchlauf, um sich mit neuen
* Daten in den _evnt_multi zu haengen.
*

scmgr_reinit:
 lea      scmgr_mm+2,a1
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)                ; GRECT kopieren
_scmgr_reinit:
 tst.w    scmgr_wakeup             ; vorherigen verarbeitet
 bne.b    sci_apy                  ; nein, keinen weiteren
 move.l   applx+4,a0               ; SCRENMGR
 tst.b    ap_status(a0)            ; schon "ready"
 beq.b    sci_apy                  ; ja
 addq.w   #1,scmgr_wakeup          ; Klick nicht beruecksichtigen

 moveq    #1,d1                    ; ein Klick
 moveq    #1,d0                    ; linke Maustaste
;move.l   a0,a0                    ; der Screenmanager bekommt einen Klick
 jsr      send_click
sci_apy:
 jmp      appl_yield


**********************************************************************
*
* d0 = long modify_acc_menu( a0 = OBJECT *menu )
*
* DISABLE-d Menueeintraege eingefrorener ACCs
* gibt Bitmuster geaenderter Menueeintraege zurueck
*

modify_acc_menu:
 move.l   a6,-(sp)
 move.w   ob_tail(a0),d0           ; rechter Teil (Menues)
 muls     #OBJECT_SIZE,d0
 move.w   ob_head(a0,d0.l),d0      ; erstes Menue
 addq.w   #2,d0                    ; G_BOX,"ueber ..." und "------"
 muls     #OBJECT_SIZE,d0
 add.l    d0,a0
 moveq    #NACCS,d1                ; Tabellenlaenge
 lea      reg_apidx,a1
 lea      reg_entries,a6
 moveq    #0,d0
 bra.b    mom_nxtob
mom_loop:
 move.w   (a1)+,a2                      ; reg_apidx[i]
 tst.l    (a6)+                         ; Eintrag gueltig ?
 beq.b    mom_nxtob                     ; nein, Nullzeiger
 add.w    a2,a2
 add.w    a2,a2
 btst     #DISABLED_B,ob_state+1(a0)    ; schon ungueltig ?
 bne.b    mom_nxtob                     ; ja
 tst.l    applx(a2)                     ; zugehoerige APPL
 bgt.b    mom_nxtob                     ; ist gueltig
 bset     #DISABLED_B,ob_state+1(a0)    ; ungueltig machen
 bset     d1,d0                         ; und vermerken
mom_nxtob:
 lea      OBJECT_SIZE(a0),a0
 dbra     d1,mom_loop
 move.l   (sp)+,a6
 rts


**********************************************************************
*
* void restore_acc_menu( a0 = OBJECT *menu, d0 = int bitvec )
*
* Un- DISABLE-d Menueeintraege eingefrorener ACCs
*
* d0: Bit 0:   ACC #5 disabled
*         1:   ACC #4 disabled
*    ...
*     Bit 5:   ACC #0 disabled
*

restore_acc_menu:
 move.w   ob_tail(a0),d1           ; rechter Teil (Menues)
 muls     #OBJECT_SIZE,d1
 move.w   ob_head(a0,d1.l),d1      ; erstes Menue
 addq.w   #2,d1                    ; G_BOX,"ueber ..." und "------"
 muls     #OBJECT_SIZE,d1
 add.l    d1,a0
 moveq    #NACCS,d1                ; Tabellenlaenge
 bra.b    ram_nxtob
ram_loop:
 btst     d1,d0                    ; wieder enablen ?
 beq.b    ram_nxtob                ; nein
 bclr     #DISABLED_B,ob_state+1(a0)    ; gueltig machen
ram_nxtob:
 lea      OBJECT_SIZE(a0),a0
 dbra     d1,ram_loop
 rts


**********************************************************************
*
* void desk_on(a0 = APPL *ap, d0 = OBJECT *tree, d1 = int firstob)
*

desk_on:
 move.l   d0,a1
 move.l   d0,ap_desktree(a0)
 move.w   d1,ap_1stob(a0)
 move.l   windx,a2
 move.l   (a2),a2                  ; Fenster #0
 cmpa.l   w_owner(a2),a0           ; sind wir Eigner des Hintergrunds ?
 beq.b    ndon_set                 ; ja, alles in Ordnung
 cmpa.l   menu_app,a0              ; sind wir "Hauptapplikation" ?
 beq.b    ndon_switch              ; ja, alles in Ordnung
 ori.w    #$0080,ob_flags(a1)      ; HIDETREE aktivieren
 rts
ndon_switch:
 move.l   a0,w_owner(a2)           ; neuer Eigner von Window 0
 move.l   desktree,d2
 beq.b    ndon_set                 ; kein alter Hintergrund
 move.l   d2,a2
 ori.w    #$0080,ob_flags(a2)      ; alter Hintergrund: HIDETREE aktivieren
ndon_set:
 move.l   d0,desktree
 move.w   d1,desktree_1stob
 andi.w   #$ff7f,ob_flags(a1)      ; neuer Hintergrund: HIDETREE deaktivieren
 rts


/*
 move.l   d0,a1
 ori.w    #$0080,ob_flags(a1)      ; HIDETREE aktivieren
 move.l   d0,ap_desktree(a0)
 move.w   d1,ap_1stob(a0)
 cmpa.l   menu_app,a0              ; ist "Hauptapplikation"
 bne.b    ndon_ende                ; nein
 move.l   desktree,d2
 beq.b    ndon_noold
 move.l   d2,a1
 ori.w    #$0080,ob_flags(a1)      ; alter Hintergrund: HIDETREE aktivieren
ndon_noold:
 move.l   d0,desktree
 move.w   d1,desktree_1stob
 move.l   d0,a1
 andi.w   #$ff7f,ob_flags(a1)      ; neuer Hintergrund: HIDETREE deaktivieren
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 move.l   a0,w_owner(a1)           ; Eigner = Eigner von Window 0
ndon_ende:
 rts
*/

**********************************************************************
*
* void desk_off( a0 = APPL *ap )
*

desk_off:
 tst.l    ap_desktree(a0)          ; ist schon leer ?
 beq.b    ndoff_ende               ; ja, Ende
 clr.l    ap_desktree(a0)          ; in der Applikation abmelden
 cmpa.l   menu_app,a0              ; ist "Hauptapplikation"
 beq.b    ndoff_is_main            ; ja
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 cmpa.l   w_owner(a1),a0           ; sind wir Eigner des Hintergrunds ?
 bne.b    ndoff_ende               ; nein, Ende
 bra.b    ndoff_off                ; ja, Hintergrund abmelden
ndoff_is_main:
 tst.l    ap_menutree(a0)          ; hat Menue
 bgt.b    ndoff_off                ; ja
 jsr      any_app                  ; nein, suche irgendeine APP
 beq.b    ndoff_ende               ; ja, gefunden
ndoff_off:
 clr.l    desktree                 ; ja, nur Hintergrund abmelden
ndoff_ende:
 rts


**********************************************************************
*
* void set_desktop( a0 = APPL *ap )
*

set_desktop:
* Falls kein Hintergrund da, den von APP #0 nehmen
 move.l   ap_desktree(a0),d0
 bclr     #31,d0
 tst.l    d0
 bne.b    sdk_is
 move.l   applx,a0                 ; APPL #0
sdk_is:
 move.l   windx,a1
 move.l   (a1),a1                  ; Fenster #0
 move.l   a0,w_owner(a1)           ; Eigner = Eigner von Window 0
 bclr     #7,ap_desktree(a0)       ; Hintergrund einer bisher eingefrorenen APP
 move.l   ap_desktree(a0),d0
 move.l   desktree,d1
 cmp.l    d1,d0
 beq.b    std_ende                 ; Desktophintergrund schon aktiv
 tst.l    d0
 beq.b    sdk_newoff
 move.l   d0,a1
 andi.w   #$ff7f,ob_flags(a1)      ; neuer Hintergrund: HIDETREE deaktivieren
sdk_newoff:
 tst.l    d1
 beq.b    sdk_oldoff
 move.l   d1,a1
 ori.w    #$0080,ob_flags(a1)      ; alter Hintergrund: HIDETREE aktivieren
sdk_oldoff:
 move.l   d0,desktree
 move.w   ap_1stob(a0),desktree_1stob

 subq.l   #8,sp
 lea      desk_g,a0
 move.l   (a0)+,(sp)
 move.l   (a0),4(sp)
 move.l   sp,a0
 jsr      wind0_draw               ; Hintergrund neumalen
 addq.l   #8,sp
std_ende:
 tst.w    topwhdl
 bne.b    std_no0
 jmp      set_topwind_app          ; Hintergrund ist oberstes Fenster
                                   ;  daher Maus/Tastatur umsetzen
std_no0:
 rts


**********************************************************************
*
* int menu_register(d0 = int ap_id, a0 = char *entry)
*

menu_register:
 move.w   d0,d1                    ; d1 = ap_id
 bmi.b    mnrg_setname

* Nur ACCs duerfen menu_register machen

 move.w   d0,a1
 add.w    a1,a1
 add.w    a1,a1
 move.l   applx(a1),d2
 ble.b    mnrg_weiteracc           ; ???
 move.l   d2,a2
 move.l   ap_pd(a2),d2             ; PD
 ble.b    mnrg_weiteracc           ; PD ungueltig (SCRENMGR)
 move.l   d2,a1
 tst.l    p_parent(a1)
 bne.b    mnrg_err                 ; Parent gueltig (kein ACC)

* freien Slot suchen

mnrg_weiteracc:
 lea      reg_apidx,a1
 lea      reg_entries,a2
 moveq    #0,d0
 bra.b    mnrg_srch
mnrg_srchnxt:
 tst.l    (a2)                     ; freier Slot ?
 beq.b    mnrg_set                 ; ja, sofort besetzen
 addq.l   #2,a1                    ; naechsten...
 addq.l   #4,a2                    ; ...Slot
 addq.w   #1,d0                    ; ...betrachten
mnrg_srch:
 cmp.w    #NACCS,d0
 bcs.b    mnrg_srchnxt
mnrg_err:
 moveq    #-1,d0                   ; kein freier Slot
 rts

mnrg_set:
 addq.w   #1,no_of_menuregs
 move.w   d1,(a1)                  ; ap_id merken
 move.l   a0,(a2)                  ; Menueeintrag merken
 move.w   d0,-(sp)
 bsr      reg_unreg_modify
 move.w   (sp)+,d0
 rts


**********************************************************************
*
* Die Applikation aendert ihren eigenen Namen
*

mnrg_setname:
 suba.w   #128,sp
 lea      (sp),a1
strloop6:
 move.b   (a0)+,(a1)+
 bne.b    strloop6

 lea      (sp),a1
 move.l   act_appl,a0
 jsr      set_apname
 adda.w   #128,sp
 moveq    #1,d0
 rts


**********************************************************************
*
* int menu_unregister(d0 = int menu_id)
*
* menu_id == -1: alle menu_ids der act_appl loeschen
*

menu_unregister:
 move.w   d0,d1                    ; d1 = menu_id
 addq.w   #1,d0                    ; menu_id = -1: aktuelle Applikation
 bne.b    munrg_mid

* 1. Fall: aktuelle Applikation ist angegeben

 move.l   act_appl,a0
 move.w   ap_id(a0),d1             ; ap_id der aktuellen Applikation
 sf       d2                       ; merken, wenn sich etwas getan hat
 lea      reg_apidx,a1
 lea      reg_entries,a0
 moveq    #0,d0
 bra.b    munrg_srch
munrg_srchnxt:
 tst.l    (a0)
 beq.b    munrg_weiter             ; ungueltig
 cmp.w    (a1),d1
 bne.b    munrg_weiter             ; nicht meine
 move.w   #-1,(a1)                 ; ungueltig machen
 clr.l    (a0)                     ; auch ungueltig machen
 subq.w   #1,no_of_menuregs
 st       d2
munrg_weiter:
 addq.l   #2,a1
 addq.l   #4,a0
 addq.w   #1,d0
munrg_srch:
 cmp.w    #NACCS,d0
 bcs.b    munrg_srchnxt
 tst.b    d2
 bne.b    munrg_modify
munrg_err:
 moveq    #0,d0                    ; nichts gefunden
 rts
* 2. Fall: menu_id ist angegeben
munrg_mid:
 cmpi.w   #NACCS,d1
 bcc.b    munrg_err                ; ungueltig, nicht 0..5
 move.w   d1,a0
 add.w    a0,a0                    ; fuer Wortzugriff
 lea      reg_apidx,a1
 move.w   #-1,0(a1,a0.w)
 add.w    a0,a0                    ; fuer Langwortzugriff
 add.l    #reg_entries,a0
 tst.l    (a0)
 beq.b    munrg_err                ; ist schon ungueltig
 clr.l    (a0)
 subq.w   #1,no_of_menuregs
munrg_modify:
 bsr.s    reg_unreg_modify
 moveq    #1,d0
 rts


reg_unreg_modify:
 move.l   menutree,d0
 beq.b    ru_ende
 move.l   d0,a1                    ; tree
 move.l   menu_app,a0              ; APPL *
 jmp      menu_on                  ; modifizieren und anzeigen
ru_ende:
 rts


**********************************************************************
*
* int menu_popup(d0 = int xpos, d1 = int ypos, a0 = MENU *pmenu,
*                a1 = MENU *dmenu)
*
*
*   typedef struct _menu
*   {
*      OBJECT *mn_tree;   - the object tree of the menu
*      WORD    mn_menu;   - the parent object of the menu items
*      WORD    mn_item;   - the starting menu item
*      WORD    mn_scroll; - the scroll field status of the menu
*                           0  - The menu will not scroll
*                           >0 - The menu will scroll if the number of menu
*                                items exceed the menu scroll height. The
*                    non-zero value is the object at which
*                    scrolling will begin.  This will allow one
*                    to have a menu in which the scrollable region
*                    is only a part of the whole menu.  The value
*                    must be a menu item in the menu.
*
*                                menu_settings can be used to change the
*                                menu scroll height.
*
*                         NOTE: If the scroll field status is >0, the menu
*                               items must consist entirely of G_STRINGS.
*
*                <0  - The menu will be displayed as a Drop-Down List.
*
*      WORD   mn_keystate; - The CTRL, ALT, SHIFT Key state at the time the
*                   mouse button was pressed.
*   } MENU;
*

menu_popup:
     IFNE XMENU

 cmpi.w   #'XM',d0
 bne.b    menp_ok
 cmpi.w   #'EN',d1
 beq.b    menp_err

menp_ok:
 clr.l    -(sp)
 clr.l    -(sp)
 clr.l    -(sp)
 move.l   act_appl,-(sp)           ; app
;move.l   a1,a1                    ; resmdesc
;move.l   a0,a0                    ; a1 = mdesc
;move.w   d1,d1                    ; d1 = ypos
;move.w   d0,d0                    ; d0 = xpos
 jsr      smn_popup
 adda.w   #16,sp
 rts
menp_err:
 clr.w    -(sp)                    ; XMEN_MGR terminieren
 trap     #1

     ELSE

 move.w   d0,d2
 swap     d2
 move.w   d1,d2
 cmpi.l   #'XMEN',d2
 bne.b    menp_err
     IFNE NEU_SUBMEN

 tst.l    4(a1)                    ; neue Version des XMEN?
 bne.b    menp_err                 ; nein, Fehler

     ENDIF

     IFNE SUBMEN
* XMENU installieren
 move.l   a1,xmenu_info
 move.w   #1,is_sub
 move.l   #xmenu_export,(a0)       ; Funktionen exportieren!
 moveq    #1,d0
 rts
     ENDIF
menp_err:
 tst.l    xmenu_info               ; XMENU installiert ?
 beq.b    menp_err2
 move.l   a1,-(sp)                 ; MENU *dmenu
 move.l   a0,-(sp)                 ; MENU *pmenu
 move.w   d1,-(sp)                 ; ypos
 move.w   d0,-(sp)                 ; xpos
 move.l   xmenu_info,a2
 move.l   (a2),a2
 jsr      (a2)
 adda.w   #12,sp
 rts
menp_err2:
 moveq    #0,d0
 rts

xmenu_export:
 DC.W     1                        ; Versionsnummer
 DC.L     act_appl
 DC.L     menu_app
 DC.W     ap_id
 DC.L     desk_g
 DC.L     full_g
 DC.L     big_wchar
 DC.L     big_hchar
 DC.L     nplanes
 DC.L     set_full_clip
 DC.L     set_clip_grect
 DC.L     menutree
 DC.L     gr_mkmx
 DC.L     gr_mkmy
 DC.L     gr_mkmstate
 DC.L     gr_mkkstate
 DC.L     mouse_off
 DC.L     mouse_on
 DC.L     mctrl_0
 DC.L     mctrl_1
 DC.L     vro_cpyfm
 DC.L     vptsin
 DC.L     fast_save_scr
 DC.L     __fm_xdial
 DC.L     restore_scr
 DC.L     _evnt_multi
 DC.L     evnt_button
 DC.L     _objc_draw
 DC.L     _objc_change
 DC.L     objc_add
 DC.L     objc_delete
 DC.L     _objc_find
 DC.L     _objc_offset
 DC.L     obj_to_g
 DC.L     xy_in_grect
 DC.L     grects_intersect
 DC.L     grects_union
 DC.L     graf_mouse
 DC.L     appl_yield
 DC.L     applx
 DC.L     mn_at_get
 DC.L     menu_set

     ENDIF

**********************************************************************
*
* int menu_attach(d0 = int flag, d1 = int obj, a0 = OBJECT *tree,
*                 a1 = MENU *menu)
*
* flag:
*
*   0  Inquire data about the submenu that is associated with the
*      menu item. The data concerning the submenu is returned in
*      me_mdata.
*
*   1  Attach or change a submenu associated with a menu item.
*      me_mdata must be initialized by the application. The data
*      object must consist tree of the submenu, the menu object,
*      the starting menu item and the scroll field status. Attaching
*      a NULLPTR structure will remove the submenu associated with
*      the menu item. There can be a maximum of 64 associations per
*      process.  Bit 11 of the objects ObFlag will be set if a
*      submenu is actually attached.
*
*   2  Remove a submenu associated with a menu item.  me_mdata should
*      be set to NULLPTR. Bit 11 of the objects ObFlag will be
*      cleared.
*

     IFNE NEU_SUBMEN

menu_attach:
 movem.l  a6/a5,-(sp)
 mulu     #OBJECT_SIZE,d1
 lea      0(a0,d1.l),a6            ; a6 = OBJECT *
 move.l   a1,a5
 tst.w    d0
 bne.b    menat_no0

;
; Modus 0:
;

 move.l   act_appl,a1
 move.l   a6,a0
 bsr      mn_at_get
 beq      menat_err                ; Fehler, return(0)
 move.l   (a0)+,(a5)+              ; atpop_tree -> mn_tree
 move.l   (a0)+,(a5)+              ; atpop_menu -> mn_menu
                                   ; atpop_item -> mn_item
 move.w   (a0),(a5)                ; atpop_scroll -> mn_scroll
 bra      menat_ok

;
; Modus 1:
;

menat_no0:
 subq.w   #1,d0
 bne      menat_no1
menat1:
; erstmal das Submenue ermitteln
 move.l   act_appl,a1
 move.l   a6,a0
 bsr      mn_at_get
 beq.b    menat1_set               ; ist keins da, neues eintragen
; Es ist eins da. Entfernen.
 bclr     #(SUBMENU_B-8),ob_flags(a6)
 clr.b    ob_type(a6)
 subq.w   #1,atpop_refcnt(a0)      ; Referenzzaehler dekrementieren
 move.l   ob_spec(a6),a0           ; char *
menat1_loop1:
 move.b   (a0)+,d0
 beq.b    menat1_set               ; EOS
 cmpi.b   #3,d0                    ; Pfeil nach rechts
 bne.b    menat1_loop1
 cmpi.b   #' ',(a0)                ; naechstes Zeichen Leerstelle?
 bne.b    menat1_loop1
 tst.b    1(a1)                    ; uebernaechstes Zeichen EOS ?
 bne.b    menat1_loop1
 move.b   #' ',-1(a0)              ; Pfeil entfernen
; neues Menue setzen
menat1_set:
 move.l   a5,d0                    ; neues Menue ?
 beq      menat_ok                 ; nein, Ende, OK
 cmpi.b   #G_STRING,ob_type+1(a6)
 bne      menat_err
 move.l   act_appl,a0
 move.l   ap_attached(a0),d0
 bne.b    menat1_weiter
 move.l   #64*atpop_sizeof,d0
 jsr      mmalloc                   ; Speicher allozieren
 beq      menat_err                ; zuwenig Speicher
 move.l   act_appl,a0
 move.l   d0,ap_attached(a0)
 move.l   d0,a0
 moveq    #64-1,d1
menat1_loop2:
 clr.w    atpop_refcnt(a0)
 lea      atpop_sizeof(a0),a0
 dbra     d1,menat1_loop2
; suche, ob wir schon drin sind
; parallel freien Slot suchen
menat1_weiter:
 move.l   d0,a0
 move.l   a0,d2                    ; Tabellenanfang merken
 moveq    #64-1,d1
 suba.l   a1,a1                    ; noch kein freier Slot
menat1_loop3:
 tst.w    atpop_refcnt(a0)
 bne.b    menat1_used
 move.l   a1,d0                    ; habe schon freien Slot?
 bne.b    menat1_next              ; ja, weiter
 move.l   a0,a1                    ; freien Slot merken
 bra.b    menat1_next
menat1_used:
 move.l   (a5),d0                  ; mn_tree
 cmp.l    atpop_tree(a0),d0
 beq.b    menat1_found
menat1_next:
 lea      atpop_sizeof(a0),a0
 dbra     d1,menat1_loop3
 move.l   a1,d0                    ; freier Slot?
 beq.b    menat_err                ; kein freier Slot
; freien Slot benutzen
 move.l   a1,a0
 move.l   (a5)+,(a1)+              ; mn_tree -> atpop_tree
 move.l   (a5)+,(a1)+              ; mn_menu -> atpop_menu
                                   ; mn_item -> atpop_item
 move.w   (a5),(a1)                ; mn_scroll -> atpop_scroll
; Submenue ggf. grau machen
 btst     #7,look_flags+1
 beq.b    menat_2d
 move.w   4(a0),d0                 ; mn_menu (parent fuer Submenue)
 mulu     #OBJECT_SIZE,d0
 add.l    (a0),d0                  ; mn_tree
 move.l   d0,a1
 ori.w    #FL3DBAK,ob_flags(a1)
menat_2d:
; Referenzzaehler erhoehen
menat1_found:
 addq.w   #1,atpop_refcnt(a0)
; Code ermitteln: d0
 sub.l    d2,a0                    ; Tabellenanfang abziehen
 move.l   a0,d0
 divu     #atpop_sizeof,d0         ; durch Elementlaenge teilen
; Objekt modifizieren
 bset     #(SUBMENU_B-8),ob_flags(a6)
 add.b    #128,d0
 move.b   d0,ob_type(a6)
; Pfeil eintragen
 move.l   ob_spec(a6),a0           ; char *
menat1_loop4:
 move.b   (a0)+,d0
 bne.b    menat1_loop4             ; String-Ende suchen
 subq.l   #3,a0                    ; a0 auf das vorletzte Zeichen
 cmpa.l   ob_spec(a6),a0           ; sind wir noch im String?
 bcs.b    menat_ok                 ; nein, Ende
 move.b   #3,(a0)                  ; Pfeil einsetzen
 bra.b    menat_ok

;
; Modus 2:
;

menat_no1:
 subq.w   #1,d0
 bne.b    menat_err
 suba.l   a5,a5                    ; kein neues Menue
 bra      menat1                   ; sonst wie Modus 1

menat_ok:
 moveq    #1,d0
 bra.b    menat_ende
menat_err:
 moveq    #0,d0                    ; Falsche Unterfunktion
menat_ende:
 movem.l  (sp)+,a6/a5
 rts

 
**********************************************************************
*
* PUREC ATPOP *mn_at_get( OBJECT *ob, APPL *ap );
*
* EQ/NE d0/a0 ATPOP *mn_at_get( a0 = OBJECT *ob, a1 = APPL *ap )
*
* Gibt einen Zeiger auf die Submenu-Informationen zum Menueeintrag
* (tree, object) zurueck.
*

mn_at_get:
 cmpi.b   #G_STRING,ob_type+1(a0)
 bne.b    menatg_err
 btst     #(SUBMENU_B-8),ob_flags(a0)
 beq.b    menatg_err
; MultiTOS prueft hier noch, ob der Pfeil im String eingetragen ist.
; Das schenken wir uns aber hier...
 moveq    #0,d0
 move.b   ob_type(a0),d0           ; Hibyte von ob_type
 subi.b   #128,d0
 bcs.b    menatg_err
 cmpi.b   #64,d0
 bcc.b    menatg_err               ; ... muss zwischen 128 und 192 liegen
; d0 enthaelt jetzt die Attached-Menu-ID zwischen 0 und 63
 move.l   ap_attached(a1),d1
 beq.b    menatg_err               ; keine Attached-Popup-Liste vorhanden
 mulu     #atpop_sizeof,d0
 add.l    d0,d1
 move.l   d1,a0
 tst.w    atpop_refcnt(a0)         ; Eintrag ueberhaupt belegt?
 bne.b    menatg_ende              ; ja, Zeiger auf Tabelleneintrag zurueck
menatg_err:
 suba.l   a0,a0                    ; Fehler
menatg_ende:
 move.l   a0,d0
 rts


**********************************************************************
*
* int menu_istart(d0 = int flag, d1 = int menobj, d2 = int popobj,
*                 a0 = OBJECT *menutree)
*
*    me_flag - the action to be performed by menu_istart
*
*     0  Inquire the starting menu item for the submenu
*     1  Set the starting menu item for the submenu to be me_item
*
*    menobj  - the menu object of the submenu that is either to be set
*               or inquired
*
*    popobj  - the starting menu item that is either to be set or inquired
*
*    menutree- the object tree of the menu item that we are setting or
*              inquiring about
*

menu_istart:
 move.w   d0,-(sp)
 move.w   d2,-(sp)
 mulu     #OBJECT_SIZE,d1
 pea      0(a0,d1.l)               ; OBJECT * merken
 move.l   act_appl,a1
 move.l   (sp),a0
 bsr.s    mn_at_get                ; ATPOP ermitteln
 beq.b    meni_err                 ; da haengt keins dran!
; a0 zeigt nun auf das ATPOP
 subq.w   #1,6(sp)
 bcs.b    meni_0                   ; nur Info holen
 bne.b    meni_err                 ; falsche Unterfunktion

; 1: setzen

 move.l   (sp),a1                  ; OBJECT *
 move.w   4(sp),d0                 ; neues Startobjekt
 cmp.w    ob_tail(a1),d0
 bls.b    meni_ok1
 move.w   ob_tail(a1),d0
meni_ok1:
 cmp.w    ob_head(a1),d0
 bcc.b    meni_ok2
 move.w   ob_head(a1),d0
meni_ok2:
 move.w   d0,atpop_item(a0)        ; Wert aendern
 bra.b    meni_ende

; 0: holen

meni_0:
 move.w   atpop_item(a0),d0
 bra.b    meni_ende
meni_err:
 moveq    #0,d0
meni_ende:
 addq.l   #8,sp
 rts


**********************************************************************
*
* void menu_settings(d0 = int flag, a0 = MN_SET *values)
*
* flag == 0:   Werte ermitteln
*         1:   Werte setzen
*
*
*    typedef struct _mn_set
*    {
*       LONG  Display; - the submenu display delay
*       LONG  Drag;    - the submenu drag delay
*       LONG  Delay;   - the single-click scroll delay
*       LONG  Speed;   - the continuous scroll delay
*       WORD  Height;  - the menu scroll height
*    } MN_SET;
*

menu_settings:
 lea      vmn_set,a1
 tst.w    d0
 beq.b    mnse_get

 moveq    #4-1,d1             ; Display, Drag, Delay, Speed

mnse_loop:
 move.l   (a0)+,d0
 bmi.b    si1
 move.l   d0,(a1)
si1:
 addq.l   #4,a1
 dbra     d1,mnse_loop

 move.w   (a0)+,d0            ; Height
 bmi.b    si2
 cmpi.w   #5,d0               ; Hoehe mindestens 5
 bcc.b    si3
 moveq    #5,d0
si3:
 move.w   big_hchar,d1
 lsr.w    #1,d1
 neg.w    d1
 add.w    desk_g+g_h,d1       ; Bildschirm ohne Menue
 subq.w   #1,d1
 divu     big_hchar,d1        ; (h-hchar/2-1)/hchar
 cmp.w    d1,d0
 bls.b    si4
 move.w   d1,d0
si4:
 move.w   d0,(a1)
si2:
 bra.b    mnse_ok

mnse_get:
 move.l   (a1)+,(a0)+         ; Display
 move.l   (a1)+,(a0)+         ; Drag
 move.l   (a1)+,(a0)+         ; Delay
 move.l   (a1)+,(a0)+         ; Speed
 move.w   (a1),(a0)           ; Height
mnse_ok:
 moveq    #1,d0
 rts

     ELSE

menu_attach:
 tst.l    xmenu_info               ; XMENU installiert ?
 beq.b    mena_err2
 move.l   a1,-(sp)
 move.l   a0,-(sp)
 move.w   d1,-(sp)
 move.w   d0,-(sp)
 move.l   xmenu_info,a2
 move.l   4(a2),a2
 jsr      (a2)
 adda.w   #12,sp
 rts
mena_err2:
 moveq    #0,d0
 rts

menu_istart:
 tst.l    xmenu_info               ; XMENU installiert ?
 beq.b    meni_err2
 move.l   a0,-(sp)
 move.w   d2,-(sp)
 move.w   d1,-(sp)
 move.w   d0,-(sp)
 move.l   xmenu_info,a2
 move.l   8(a2),a2
 jsr      (a2)
 adda.w   #10,sp
 rts
meni_err2:
 moveq    #0,d0
 rts

menu_settings:
 tst.l    xmenu_info               ; XMENU installiert ?
 beq.b    mens_err2
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 move.l   xmenu_info,a2
 move.l   12(a2),a2
 jsr      (a2)
 addq.l   #6,sp
 rts
mens_err2:
 moveq    #0,d0
 rts

     ENDIF
