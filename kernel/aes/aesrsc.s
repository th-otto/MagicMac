/*
*
* Dieses Modul enthaelt den Ressouce-Manager des AES
*
* Die Routinen, die der Aufrufkonvention von PureC entsprechen,
* sind mit "PUREC" gekennzeichnet.
*
*/

     INCLUDE "aesinc.s"
        TEXT
        SUPER

     XDEF      rsrc_load
     XDEF      rsrc_free
     XDEF      rsrc_gaddr
     XDEF      rsrc_saddr
     XDEF      rsc_init
     XDEF      rsrc_obfix
     XDEF      _rsrc_rcfix

* von AESMAIN

     XREF      shel_find

* von AESOBJ

     XREF      xp_raster

* von STD

     XREF      vmemcpy
     XREF      strlen
     XREF      mmalloc
     XREF      mfree


**********************************************************************
*
* void _rsrc_obfix(a0 = int *i, d0 = char ishorizontal)
*
* Eingabe: Lobyte von *i: Anzahl Zeicheneinheiten (unsigned)
*          Hibyte von *i: Pixel- Offset (signed)
*
* erhoeht a0 um 2, komplementiert d0
*

__rsrc_obfix:
 moveq    #0,d1
 move.b   1(a0),d1                 ; Lobyte (unsigned)
 tst.b    d0                       ; Byte
 beq.b    rsof_l1
 cmp.w    #80,d1
 bne.b    rsof_l1
* Horizontal, Lobyte ist 80, gib scr_w zurueck
 move.w   scr_w,d1
 bra.b    rsof_l3
* Multipliziere Lobyte mit Zeichengroesse
rsof_l1:
 move.w   big_hchar,d2
 tst.b    d0
 beq.b    rsof_l2
 move.w   big_wchar,d2
rsof_l2:
 mulu     d2,d1                    ; Lobyte (Zeichenraster) ist unsigned
rsof_l3:
 move.b   (a0),d2                  ; Hibyte
 ext.w    d2                       ; Vorzeichenerweiterung
 add.w    d2,d1
 move.w   d1,(a0)+                 ; Rueckgabe
 not.b    d0
 rts


**********************************************************************
*
* int rsrc_obfix(a0 = OBJECT *tree, d0 = int objnr)
*

rsrc_obfix:
 muls     #24,d0
 lea      ob_x(a0,d0.l),a0         ; auf ob_x
 st.b     d0
 bsr.s    __rsrc_obfix             ; x
 bsr.s    __rsrc_obfix             ; y
 bsr.s    __rsrc_obfix             ; w
 bsr.s    __rsrc_obfix             ; h
 moveq    #1,d0
 rts


**********************************************************************
*
* long rsrc_gaddr(a0 = int *global, d0 = int type, d1 = int index)
*
* Rueckgabe -1L bedeutet Fehler
*

rsrc_gaddr:
 subq.w   #1,d0
 bcs.b    rg_tree                  ; war 0, also R_TREE
 cmpi.w   #15,d0
 bhi.b    rg_err                   ; ungueltiger Code
 add.w    d0,d0
 move.w   rg_tab(pc,d0.w),d0
 move.w   d0,-(sp)                 ; merken
;move.w   d1,d1                    ; index
 lsr.w    #8,d0                    ; Hibyte ist typ

 move.b   struct_len_tab(pc,d0.w),d2
 ext.w    d2                       ; Laenge eines Objekts
 mulu     d1,d2                    ; index * Laenge -> offset
 add.w    d0,d0                    ; fuer int- Zugriff
 move.l   $e(a0),a0                ; Zeiger auf eine Ressource- Datei
 moveq    #0,d1                    ; unsigned
 move.w   0(a0,d0.w),d1            ; Feldelement holen (rel.Untertabadr.)
 add.l    d1,a0                    ; + Offset in der Untertabelle
 add.l    d2,a0                    ; + Anfangsadresse der Datei

 move.w   (sp)+,d0
 ext.w    d0                       ; Lobyte
 bmi.b    rg_deref
 adda.w   d0,a0                    ; ggf. Offset addieren
 move.l   a0,d0
 rts
rg_deref:
 move.l   (a0),d0
 rts
rg_tree:
 lsl.w    #2,d1                    ; Fuer Langwortzugriff
 movea.l  $a(a0),a0                ; ap_ptree
 move.l   0(a0,d1.w),d0            ; Adresse zurueckgeben
 rts
rg_err:
 moveq    #-1,d0
 rts

struct_len_tab:
 DC.B     0,$18,$1c,$22,$e,4,0,0,4,4
 EVEN

rg_tab:
 DC.B     1,0                      ; R_OBJECT:   rsh_object, kein Offset
 DC.B     2,0                      ; R_TEDINFO:  rsh_tedinfo, kein Offset
 DC.B     3,0                      ; R_ICONBLK:  rsh_iconblk, kein Offset
 DC.B     4,0                      ; R_BITBLK:   rsh_bitblk,  kein Offset
 DC.B     5,-1                     ; R_STRING:   rsh_frstr, dereferenzieren
 DC.B     8,-1                     ; R_IMAGEDATA:rsh_frimg, dereferenzieren
 DC.B     1,ob_spec                ; R_OBSPEC:
 DC.B     2,te_ptext               ; R_TEPTEXT:
 DC.B     2,te_ptmplt              ; R_TEPTMPLT
 DC.B     2,te_pvalid              ; R_TEPVALID
 DC.B     3,0                      ; R_IBPMASK
 DC.B     3,4                      ; R_IBPDATA
 DC.B     3,8                      ; R_IBPTEXT
 DC.B     4,0                      ; R_BIPDATA
 DC.B     5,0                      ; R_FRSTR
 DC.B     8,0                      ; R_FRIMG


**********************************************************************
*
* int set_abs_adr(a0 = int global[], d0 = int stype, d1 = int index)
*
* Rueckgabe 0, wenn Eintrag -1L
*

set_abs_adr:
;move.w   d1,d1
;move.w   d0,d0
;move.l   a0,a0
 move.l   a0,-(sp)
 bsr.s    rsrc_gaddr
 move.l   d0,a1
 move.l   (sp)+,a0
;bra      rel_to_abs_adr


**********************************************************************
*
* int rel_to_abs_adr( a0 = int global[], a1 = OBJECT **tree)
*
* rechnet in der Objektbaumtabelle relative Adressen in absolute um
* Rueckgabe 0, wenn Eintrag -1L
*

rel_to_abs_adr:
 move.l   (a1),d0                  ; Adresse (rel. zum Dateianfang)
 addq.l   #1,d0                    ; ungueltig ?
 beq.b    r2aa_ende                ; ungueltig, return(0)
 subq.l   #1,d0                    ; korrigieren
 add.l    $e(a0),d0                ; Dateianfang addieren
 move.l   d0,(a1)                  ; zurueckgeben
 moveq    #1,d0                    ; ok
r2aa_ende:
 rts


**********************************************************************
*
* int rsrc_free( a0 = int global[] )
*

rsrc_free:
 move.l   $e(a0),a1
 clr.l    $e(a0)                   ; sicherheitshalber
 move.l   a1,a0                    ; RSC freigeben
 jsr      mfree
 tst.l    d0                       ; Fehler ?
 seq.b    d0                       ; wenn nein, d0 setzen
 andi.w   #1,d0
 rts


**********************************************************************
*
* int rsrc_saddr(a0 = int global[], d0 = int type, d1 = int index,
*                a1 = long value)
*

rsrc_saddr:
 move.l   a1,-(sp)
;move.l   a0,a0                    ; global
;move.w   d1,d1
;move.w   d0,d0
 bsr      rsrc_gaddr
 move.l   d0,a0
 addq.l   #1,d0
 beq.b    rscsad_err
 move.l   (sp),(a0)
 moveq    #1,d0
rscsad_err:
 addq.l   #2,sp
 rts


**********************************************************************
*
* int rsrc_load(a0 = int *global, a1 = char *pathname)
*
* <global> ist das Feld der aufrufenden Applikation
* Rueckgabe 0 bei Fehler
* Laedt Datei und setzt absolute Adressen ein
* Setzt Felder des global
*
* MagiX 3.0: Laedt auch erweitertes Dateiformat von MultiTOS.
*

rsrc_load:
 movem.l  d6/d7/a4/a5,-(sp)
 suba.w   #128,sp                  ; Platz fuer 128 Bytes

 moveq    #-1,d6                   ; Handle ungueltig
 suba.l   a4,a4                    ; noch kein Speicher alloziert
 move.l   a0,a5                    ; a5 = global[]
;move.l   a1,a1
 lea      (sp),a0
strloop15:
 move.b   (a1)+,(a0)+              ; Pfad in den 128-Bytes-Puffer kopieren
 bne.b    strloop15

 lea      (sp),a0
 jsr      shel_find                ; Resourcedatei suchen, d1.l = Dateilaenge
 tst.w    d0
 beq      rsld_ende                ; nicht gefunden, Rueckgabe 0
 move.l   d1,d7                    ; Dateilaenge

 move.l   sp,a0
 clr.w    -(sp)
 pea      (a0)
 move.w   #$3d,-(sp)
 trap     #1                       ; gemdos Fopen
 addq.l   #8,sp
 move.w   d0,d6
 bmi      rsld_err                 ; Fehler

* Header einlesen
 pea      (sp)                     ; genug Platz
 pea      rsh_sizeof               ; sizeof(RSHDR)
 move.w   d6,-(sp)                 ; Handle
 move.w   #$3f,-(sp)
 trap     #1
 lea      12(sp),sp
 cmpi.l   #$24,d0                  ; Header komplett eingelesen ?
 bne      rsld_err                 ; nein, Fehler
* Unterscheidung fuer erweitertes Format (MultiTOS)
 cmpi.w   #4,rsh_vrsn(sp)          ; erweitertes Format ?
 beq.b    rsld_newform             ; ja, ganze Datei laden (d7 ist Laenge)
 moveq    #0,d7
 move.w   rsh_rssize(sp),d7        ; rsh_rssize (Laenge der Datei)
* Speicher allozieren
rsld_newform:
 move.l   d7,d0
 jsr      mmalloc                   ; Speicher fuer Resource holen
 beq.b    rsld_err                 ; Zuwenig Speicher, schliessen und Ende
 move.l   d0,a4                    ; a4 = Dateiadresse
* Dateizeiger zurueckstellen
 clr.w    -(sp)                    ; mode: ab Anfang
 move.w   d6,-(sp)                 ; handle
 clr.l    -(sp)                    ; offset 0
 move.w   #$42,-(sp)
 trap     #1                       ; gemdos Fseek
 lea      10(sp),sp
 tst.l    d0
 bne      rsld_err
* ganze Datei einlesen
 move.l   a4,-(sp)
 move.l   d7,-(sp)
 move.w   d6,-(sp)
 move.w   #$3f,-(sp)
 trap     #1                       ; gemdos Fread
 lea      12(sp),sp
 cmp.l    d0,d7
 bne      rsld_err

 move.l   a4,a1                    ; Datei
 move.l   a5,a0                    ; global[]
 bsr      rsc_init                 ; Adressen verarbeiten

 moveq    #1,d0                    ; kein Fehler
 bra.b    rsld_ende
rsld_err:
 moveq    #0,d0
rsld_ende:
 move.w   d0,-(sp)

 tst.w    d6
 bmi.b    rsld_nohdl
 move.w   d6,-(sp)
 move.w   #$3e,-(sp)
 trap     #1                       ; gemdos Fclose
 addq.l   #4,sp
rsld_nohdl:
 move.l   a4,d0
 beq.b    rsld_nomem               ; Speicherbl. ungueltig  => nicht freigeben
 tst.w    (sp)
 bne.b    rsld_nomem               ; rsrc_load erfolgreich => nicht freigeben
 move.l   a4,a0
 jsr      mfree
rsld_nomem:

 move.w   (sp)+,d0
 adda.w   #128,sp
 movem.l  (sp)+,a5/a4/d7/d6
 rts


**********************************************************************
*
* void sort_cicons( a0 = ICONBLK *icons )
*
* Sortiert die CICONs so, dass das optimale CICON vorn in der Liste
* liegt.
*

sort_cicons:
 movem.l  a3/a4,-(sp)
 move.w   nplanes,d2
 suba.l   a2,a2               ; noch kein guenstigstes Icon
 moveq    #1,d0               ; benutze 1 Plane (monochrom)
 lea      cib_mainlist-ci_next_res(a0),a1
srtic_loop:
 lea      ci_next_res(a1),a3  ; Vorgaenger zum Aushaengen
 move.l   (a3),d1             ; CICONBLK *
 beq.b    srtic_set
 move.l   d1,a1
 cmp.w    ci_num_planes(a1),d2
 bcs.b    srtic_loop          ; zuviele Planes, kann nicht komprimieren
 cmp.w    ci_num_planes(a1),d0
 bcc.b    srtic_loop          ; gemerktes CICON ist besser, mehr Planes
 move.l   a1,a2               ; CICON ist besser, merken
 move.l   a3,a4               ; Vorgaenger merken
 move.w   ci_num_planes(a2),d0
 bra.b    srtic_loop
srtic_set:
 move.l   a2,d0               ; CICON gefunden ?
 beq.b    srtic_noprev        ; nein, nichts aushaengen
 move.l   ci_next_res(a2),(a4)               ; CICON aushaengen
 move.l   cib_mainlist(a0),ci_next_res(a2)   ; und neu einhaengen
srtic_noprev:
 move.l   a2,cib_mainlist(a0)     ; merken
 movem.l  (sp)+,a3/a4
 rts


**********************************************************************
*
* char * init_colicons(d0 = int count, a0 = CICONBLK *icn_tab,
*                    a1 = void *data, d1 = int save_flg)
*
* save_flg:    FALSE     normale Funktion
*              TRUE      keine 12 Bytes Text, unnoetige Icondaten
*                        entfernen (andere Aufloesungen)
*
* Rueckgabe: Zeiger auf das erste freie Byte (beim Komprimieren)
*

init_colicons:
 movem.l  d4-d7/a4-a6,-(sp)
 move.l   a0,a6
 move.l   a1,a5                    ; Quelladresse
 move.l   a1,a4                    ; Zieladresse, fuers Komprimieren
 move.w   d0,d7
 move.w   d1,d4                    ; Flag save_flg
incol_endci:
 subq.w   #1,d7
 bcs      incol_ende
; Zeiger auf CICONBLK setzen
 move.l   a5,(a6)                  ; Zeiger auf CICONBLK
; ICONBLK fuer Monochrom-Icon, d5 := Anzahl Bytes pro Bitblock
 moveq    #15,d5                   ; fuers Runden auf 16 Pixel
 add.w    ib_wicon(a5),d5          ; Breite in Pixeln
 lsr.w    #4,d5                    ; /16 => WORDs pro Zeile
 add.w    d5,d5                    ; in Bytes umrechnen
 mulu     ib_hicon(a5),d5          ; * Anzahl Zeilen

 lea      ib_sizeof(a5),a2         ; a2 Anzahl CICONS/verkettete Liste
 lea      4(a2),a1                 ; a1 auf Daten
 move.l   a1,ib_pdata(a5)
 adda.w   d5,a1                    ; a1 auf Maske
 move.l   a1,ib_pmask(a5)
 adda.w   d5,a1                    ; a1 auf Text
 tst.w    d4
 bne.b    incol_notxt              ; kein Zeiger auf Text
 move.l   a1,ib_ptext(a5)
 lea      12(a1),a1
incol_notxt:

; Zeiger auf verkettete Liste der CICONs
 move.l   (a2),d6                  ; d6 = Anzahl Alternativicons
 clr.l    (a2)
; Daten fuer Monochrom-Icon ueberspringen
 move.l   a1,a5                    ; hinter Text

; einzelne Farbicons bearbeiten, <d6> Stueck
incol_cicloop:
 subq.w   #1,d6
 bcs.b    incol_endcic
; a5 zeigt auf ein CICON, a2 auf Verweis
 move.l   a5,(a2)                  ; Verkettung ...
 lea      ci_next_res(a5),a2       ; ... einrichten
 clr.l    (a2)                     ; ... und abschliessen
 lea      ci_sizeof(a5),a1         ; Daten
 move.l   a1,ci_col_data(a5)
 move.w   ci_num_planes(a5),d0
 mulu     d5,d0                    ; Bytes berechnen
 adda.l   d0,a1                    ; hinter Daten
 move.l   a1,ci_col_mask(a5)
 adda.w   d5,a1                    ; Maske hat nur 1 Plane
 tst.l    ci_sel_data(a5)
 beq.b    incol_noseldata
 move.l   a1,ci_sel_data(a5)
 adda.l   d0,a1
 move.l   a1,ci_sel_mask(a5)
 adda.w   d5,a1
incol_noseldata:
 move.l   a1,a5
 bra      incol_cicloop            ; naechstes CICON
incol_endcic:
 move.l   (a6),a0                  ; bearbeitetes CICONBLK
 tst.l    cib_mainlist(a0)         ; sind ueberhaupt CICONs da ?
 bne.b    incol_sortc
 subq.l   #1,cib_mainlist(a0)      ; nein, auf -1L setzen
 bra.b    incol_no_sortc
incol_sortc:
 bsr      sort_cicons              ; der Aufloesung entsprechendes nach vorn
incol_no_sortc:

;
; CICONBLK und Daten umkopieren, wenn noetig
;

 tst.w    d4
 beq.b    incol_no_compress
 moveq    #ib_sizeof+4,d6
 add.l    d5,d6
 add.l    d5,d6                    ; Anzahl Bytes: CICONBLK und Mono-Daten
 cmpa.l   (a6),a4                  ; schon Speicher gespart ?
 beq.b    incol_no_compress2       ; nein
; CICONBLK und Monochrom-Daten kopieren
 move.l   d6,d0
 move.l   (a6),a1                  ; Quelladresse
 move.l   a4,a0                    ; Zieladresse
 jsr      vmemcpy
 move.l   (a6),d0
 sub.l    a4,d0                    ; soviel Bytes gespart
 sub.l    d0,ib_pdata(a4)
 sub.l    d0,ib_pmask(a4)
 move.l   a4,(a6)
; CICON kopieren
incol_no_compress2:
 move.l   cib_mainlist(a4),d0      ; CICONs ?
 ble.b    incol_mo                 ; nein
 move.l   d0,a1

; d0 = Bytes fuer Farbicon
 move.w   ci_num_planes(a1),d0
 mulu     d5,d0                    ; Bytes fuer Daten berechnen
 tst.l    ci_sel_data(a1)
 beq.b    incol_noseldata3
 add.l    d0,d0                    ; sel. Daten
 add.l    d5,d0                    ; sel. Maske
incol_noseldata3:
 addi.l   #ci_sizeof,d0
 add.l    d5,d0                    ; +norm. Maske

 lea      0(a4,d6.l),a0            ; Zeiger hinter Mono-Daten
 cmp.l    a0,a1                    ; CICON direkt hinter Mono-Daten ?
; beq.b    incol_no_cicp            ; ja, keine CICON-Daten kopieren

incol_no_cicp:
;move.l   a1,a1                    ; Quelladresse
;move.l   a0,a0                    ; Zieladresse
;move.w   d0,d0                    ; Bytes
 move.l   d0,-(sp)                 ; merken
 jsr      vmemcpy
 lea      0(a4,d6.l),a0            ; Zeiger hinter Mono-Daten...
 move.l   cib_mainlist(a4),d0      ; alte Pos.
 sub.l    a0,d0                    ; - neue Pos.
 sub.l    d0,ci_col_data(a0)
 sub.l    d0,ci_col_mask(a0)
 tst.l    ci_sel_data(a0)
 beq.b    incol_noseldata2
 sub.l    d0,ci_sel_data(a0)
 sub.l    d0,ci_sel_mask(a0)
incol_noseldata2:
 move.l   a0,cib_mainlist(a4)      ; ist die Mainlist
 clr.l    ci_next_res(a0)          ; keine weiteren CICONs
 add.l    (sp)+,a4                 ; a4 hinter die CICON-Daten
incol_mo:
 adda.l   d6,a4                    ; Zeiger hinter Mono-Daten
incol_no_compress:
 addq.l   #4,a6
 bra      incol_endci              ; naechstes CICONBLK
incol_ende:
 move.l   a4,d0
 movem.l  (sp)+,d4-d7/a4-a6
 rts



**********************************************************************
*
* cdecl WORD xp_rasterC( LONG words, LONG len, WORD planes,
* void *src, void *des );
*

xp_rasterC:
 movem.l  d3-d7/a2-a6,-(sp)
 lea      44(sp),a2
 move.l   (a2)+,d0                 ; Worte/Ebene
 move.l   (a2)+,d1                 ; Laenge Ebene
 move.w   (a2)+,d2                 ; Planes Quelle
 move.l   (a2)+,a0                 ; Quelle
 move.l   (a2),a1                  ; Ziel
 jsr      xp_raster
 movem.l  (sp)+,d3-d7/a2-a6
 rts


**********************************************************************
*
* PUREC void _rsrc_rcfix(void *global, RSHDR *rsc)
*

_rsrc_rcfix:
 move.l   a2,-(sp)
 bsr.b    rsc_init
 move.l   (sp)+,a2
 rts


**********************************************************************
*
* void rsc_init(a0 = global[], a1 = RSHDR *rsc)
*
* Initialisiert die Resourcedatei, die im Speicher liegt und auf die
* <rsc> zeigt. <len> ist die Dateilaenge einschliesslich Header.
* Initialisieren bedeutet hier, dass alle relativen Adressen in absolute
* umgerechnet werden und Laengen von TEDINFO- Strings eingesetzt werden
*
* MagiC 3: Spezialfunktion, wenn (a1) == 'MagC' ist
*          int 4(a1)     Unterfunktionsnummer
*           function 0   Farbicons initialisieren
*                        6(a1)     Anzahl CICONBLKs
*                        8(a1)     Zeiger auf CICONBLK-Tabelle
*                        12(a1)    Zeiger auf Daten
*                        16(a1)    hier kommt Zeiger hinter das Ende rein
*
*           function 1   Adresse der Funktion xp_raster ermitteln
*                        6(a1)     ->xp_mode
*                        8(a1)     Zeiger auf die Funktion
*                        12(a1)    Zeiger auf ein Binding fuer 'C'
*

rsc_init:
 cmpi.l   #'MagC',(a1)             ; special MagiC function
 bne.b    _rsc_init
 addq.l   #4,a1
 move.w   (a1)+,d0                 ; Unterfunktion
 bne.b    rsci_mg_1
 move.w   (a1)+,d0                 ; Anzahl CICONBLKs
 move.l   (a1)+,a0                 ; CICONBLK-Tabelle
 move.l   a1,-(sp)
 move.l   (a1),a1                  ; Daten
 moveq    #1,d1                    ; Speicher sparen
 bsr      init_colicons
 move.l   (sp)+,a1
 move.l   d0,4(a1)
 moveq    #0,d0
 rts
rsci_mg_err:
 moveq    #-1,d0                   ; Fehler
 rts
rsci_mg_1:
 subq.w   #1,d0
 bne.b    rsci_mg_err
 move.w   xp_mode,(a1)+
 move.l   #xp_raster,(a1)+
 move.l   #xp_rasterC,(a1)
 moveq    #0,d0
 rts

_rsc_init:
 movem.l  d4/d6/d7/a3/a4/a5/a6,-(sp)
 move.l   a0,a5                    ; a5 = global[]
 move.l   a1,a4                    ; a4 = Resourcedatei
 moveq    #-1,d4                   ; keine Farbicons

 move.l   a4,$e(a5)                ; Anfangsadresse nach ap_pmem
 move.w   rsh_rssize(a4),$12(a5)   ; Laenge nach ap_lmem (erweit. Format ?)

 moveq    #0,d0
 move.w   rsh_trindex(a4),d0
 add.l    a4,d0                    ; Dateiadresse addieren
 move.l   d0,$a(a5)                ; ap_ptree setzen

*
* Objektbaeume initialisieren
*

 move.l   d0,a3                    ; a3 = Position der Objektbaumtabelle
 move.w   rsh_ntree(a4),d7         ; d7 = Anzahl der Objektbaeume
 bra.b    rsci_nxttree
rsci_looptree:
 move.l   a3,a1                    ; Zeiger auf Objektbaum
 move.l   a5,a0
 bsr      rel_to_abs_adr           ; in absolute Adresse umrechnen
 addq.l   #4,a3
rsci_nxttree:
 subq.w   #1,d7
 bge.b    rsci_looptree

*
* Tabelle der Erweiterungen initialisieren
*

 cmpi.w   #4,rsh_vrsn(a4)          ; erweitertes Format ?
 bne      rsci_noex                ; nein

 move.l   a4,a3
 moveq    #0,d0
 move.w   rsh_rssize(a4),d0        ; unsigned int => long
 add.l    d0,a3
 move.l   a3,d4                    ; merken
 addq.l   #4,a3                    ; Dateilaenge ueberspringen
rsci_exloop:
 move.l   a3,a1
 tst.l    (a3)+                     ; Tabellenende ?
 beq.b    rsci_exend
 move.l   a5,a0
 bsr      rel_to_abs_adr
 bra.b    rsci_exloop
rsci_exend:

*
* CICONs initialisieren
*

 move.l   d4,a3                    ; a3 zurueck
 move.l   4(a3),d0
 ble      rsci_noex                ; keine Farbicons

 move.l   d0,a1
 move.l   d0,a0                    ; a0 = Tabelle CICONBLKs
 move.l   a0,d4                    ; merken fuer spaeter
 moveq    #0,d0                    ; d0 = Anzahl CICONs
rsci_cntci:
 tst.l    (a1)+
 bmi.b    rsci_endci
 addq.l   #1,d0
 bra.b    rsci_cntci
rsci_endci:

;move.l   a1,a1                    ; void *data
;move.l   a0,a0                    ; Tabelle CICONBLKs
 moveq    #0,d1                    ; normale Funktion
;move.w   d0,d0                    ; int colicn_count
 bsr      init_colicons

rsci_noex:

*
* TEDINFOs initialisieren
*

 move.w   rsh_nted(a4),d7          ; Anzahl der TEDINFOs
 bra      rit_nxt_ted

rit_loop:
 move.w   d7,d1                    ; Indexnummer
 moveq    #2,d0                    ; R_TEDINFO
 move.l   a5,a0                    ; global[]
 bsr      rsrc_gaddr
 move.l   d0,a3                    ; TEDINFO *

 lea      tedinfo_tab(pc),a6
rit_loop2:
 move.w   (a6)+,d0                 ; R_TEPTEXT,R_TEPTMPLT,R_TEPVALID
 move.w   d7,d1
 move.l   a5,a0
 bsr      set_abs_adr
 move.w   (a6)+,d1                 ; te_ptext,te_ptmplt,-1
 bmi.b    rit_nxt_ted              ; Listenende
 tst.w    d0                       ; gueltig ?
 beq.b    rit_inval                ; Adresse war -1L
 move.l   0(a3,d1.w),a0
 jsr      strlen
 addq.w   #1,d0
 move.w   (a6)+,d1                 ; te_txtlen,te_tmplen
 move.w   d0,0(a3,d1.w)
rit_inval:
 bra.b    rit_loop2

rit_nxt_ted:
 subq.w   #1,d7
 bge      rit_loop

*
* ICONBLKs initialisieren
* BITBLKs initialisieren
* freie Strings initialisieren
* freie Images initialisieren
*

 lea      rsh_nib(a4),a3
 moveq    #11,d7
ri_loop:
                   ; d7: R_IBPMASK R_IBPDATA R_IBPTEXT R_BIPDATA R_FRSTR  R_FRIMG
 move.w   (a3)+,d6 ; d6: rsh_nib   rsh_nib   rsh_nib   rsh_nbb   rsh_nstr rsh_nim

 bra.b    rcin_l1
rcin_l2:
 move.w   d6,d1                    ; index
 move.w   d7,d0
 move.l   a5,a0
 bsr      set_abs_adr
rcin_l1:
 subq.w   #1,d6
 bge.b    rcin_l2

 addq.w   #1,d7
 cmpi.w   #$11,d7
 beq.b    ri_endloop
 cmpi.w   #$d,d7
 bhi.b    ri_loop
 subq.l   #2,a3     ; fuer R_IBPMASK R_IBPDATA R_IBPTEXT dieselbe Anzahl
 bra.b    ri_loop
ri_endloop:

*
* OBJECTs initialisieren
*

 move.w   rsh_nobs(a4),d7          ; Gesamtanzahl der Objekte
 bra.b    rsci_nxtobj
rsci_loopobj:
 move.w   d7,d1
 moveq    #1,d0                    ; R_OBJECT
 move.l   a5,a0
 bsr      rsrc_gaddr
 move.l   d0,a3

 clr.w    d0                       ; ist direkt das Objekt
 move.l   a3,a0                    ; tree
 bsr      rsrc_obfix

 move.w   ob_type(a3),d0           ; d0 = ob_type
 cmpi.b   #G_BOX,d0
 beq.b    rsci_nxtobj
 cmpi.b   #G_IBOX,d0
 beq.b    rsci_nxtobj
 cmpi.b   #G_BOXCHAR,d0
 beq.b    rsci_nxtobj
 cmpi.b   #G_CICON,d0
 bne.b    rsci_r2a
; CICONBLK eintragen
 move.l   ob_spec(a3),a0           ; index
 add.w    a0,a0
 add.w    a0,a0                    ; fuer LONG-Zugriff
 add.l    d4,a0                    ; Tabelle der CICONBLKs
 move.l   (a0),ob_spec(a3)         ; Zeiger einsetzen
 bra.b    rsci_nxtobj

rsci_r2a:
 lea      ob_spec(a3),a1
 move.l   a5,a0
 bsr      rel_to_abs_adr

rsci_nxtobj:
 subq.w   #1,d7
 bge.b    rsci_loopobj

rsci_ende:
 movem.l  (sp)+,d4/d6/d7/a3/a4/a5/a6
 rts


tedinfo_tab:
 DC.W     8,te_ptext,te_txtlen
 DC.W     9,te_ptmplt,te_tmplen
 DC.W     10,-1

     END
