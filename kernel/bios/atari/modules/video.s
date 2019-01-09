**********************************************************************
*
* initialisiert das Video-System
*

     IFNE HADES
     INCLUDE "..\..\bios\atari\modules\had_ivid.s"
     ELSE
     INCLUDE "..\..\bios\atari\modules\ivid.s"
     ENDIF

**********************************************************************
*
* void *Physbase( void )
*
Physbase:
 moveq    #0,d0
 move.l   d0,a0
 movep.w  -$7dff(a0),d0            ; $ffff8201 und $ffff8203 auslesen
 lsl.l    #8,d0
 tst.b    machine_type
 beq.b    phb_st
 move.b   $ffff820d,d0             ; STe
phb_st:
 rte

**********************************************************************
*
* void *Logbase( void )
*
Logbase:
 move.l   _v_bas_ad,d0
 rte


**********************************************************************
*
* int Getrez( void )
*

Getrez:
     IFNE HADES
 moveq #2,d0
 rte
     ELSE
 moveq    #0,d0
 cmpi.b   #4,machine_type
 bne.b    getr_tt
 move.b   sshiftmd.w,d0
 and.b    #7,d0
 rte
getr_tt:
 cmpi.b   #3,machine_type
 bcs.b    getr_st
 move.b   $ffff8262,d0
 and.b    #7,d0
 rte

getr_st:
 move.b   $ffff8260,d0
 and.b    #3,d0
 rte
     ENDIF


**********************************************************************
*
* void Setscreen( void *log, void *phys, int res )
*
Setscreen:
 move.l   (a0)+,d0                 ; *log
 bmi.b    setscr_l1                ; log. Adr. nicht aendern
 move.l   d0,_v_bas_ad
setscr_l1:
 move.l   (a0)+,d0                 ; *phys
 bmi.b    setscr_l2                ; phys. Adr. nicht aendern
 move.b   d0,$ffff820d             ; STe
 lsr.l    #8,d0                    ; Hi- und Mid-Byte ins Low-Word
 suba.l   a1,a1
 movep.w  d0,-$7dff(a1)            ; $ffff8201 und $ffff8203 schreiben
setscr_l2:
 move.w   (a0)+,d0                 ; res
 bmi.b    setscr_rte               ; Aufloesung nicht aendern
 cmpi.b    #4,machine_type         ;Falcon?
 bne.s     setsc_tt
 bsr       setres_falcon
 bra       setsc_both
setsc_tt:
 move.b   d0,sshiftmd.w            ; TOS 3.06: erst _Vsync, dann d0->sshiftmd
 bsr      _Vsync                   ; TOS 2.05: $E0108C
 cmpi.b   #3,machine_type
 bcs.b    setsc_st
 move.b   $ffff8262,d0             ; TT-Shiftermodus
 and.b    #$f8,d0                  ; TT-spez. Bits holen
 or.b     sshiftmd,d0              ; mit gewuenschter Aufloesung verbinden
 move.b   d0,$ffff8262             ; TT-Aufloesung umsetzen
 bra.b    setsc_both
setsc_st:
 move.b   sshiftmd,$ffff8260
setsc_both:
 clr.w    vblsem                   ; VBlank-Handler deaktiviert
 move.w   modecode.w,d0            ; Moduswort fuer Falcon
 jsr      vt52_init                ; sichert alle benutzten Register
 move.w   #1,vblsem                ; VBlank-Handler aktiviert
setscr_rte:
 rte

setres_flc_cmp:
     DC.W STMODES+COL40+BPS4 ;niedrige ST-Aufloesung
     DC.W STMODES+COL80+BPS2 ;mittlere ST-Aufloesung
     DC.W STMODES+COL80+BPS1 ;hohe ST-Aufloesung
     DC.W 0                        ;Falcon-Aufloesungen
     DC.W COL80+BPS4               ;mittlere TT-Aufloesung
     DC.W COL80+BPS1               ;nicht definiert -> 640*480 monochrom
     DC.W COL80+BPS1               ;hohe TT-Aufloesung -> 640*480 monochrom
     DC.W COL40+BPS8               ;niedrige TT-Aufloesung

;Aufloesung fuer Falcon setzen
;Eingaben:
;d0.w Aufloesung
;a0.l Zeiger auf modecode
;Ausgaben:
;-
setres_falcon:      movem.l   d0-d2/a0-a2,-(sp)

                              cmp.w     #TT_LOW,d0          ;ungueltige Modusnummer
                              bhi.s     setres_falcon_exit
                              move.b    d0,sshiftmd.w
                              cmp.w          #FALCONMDS,d0
                              bls.s          setres_mode
                              move.b    #FALCONMDS,sshiftmd.w
setres_mode:        add.w     d0,d0
                              move.w    setres_flc_cmp(pc,d0.w),d1 ;Falcon-Aufloesungen?
                              bne.s     setres_checkmode
                              move.w    (a0),d1             ;modecode fuer Falcon-Aufloesungen
setres_checkmode:   bsr       Checkmode      ;Modus in d1 ueberpruefen
                              move.w    d1,d0
                              bsr       falcon_vsize   ;Groesse fuer Modus in d0 ausgeben
                              bsr       ScrnMalloc          ;Bildschirmspeicher allozieren

                              tst.l     d0                  ;Fehler?
                              beq.s     setres_falcon_exit
                              move.l    d0,_v_bas_ad.w ;v_bas_ad setzen
                              move.l    d0,-(sp)
                              move.b    1(sp),$ffff8201.w ;Video Base High
                              move.b    2(sp),$ffff8203.w ;Video Base Mid
                              move.b    3(sp),$ffff820d.w ;Video Base Low, fuer STE/TT/FALCON
                              addq.l    #4,sp

                              move.w    d1,d0
                              bsr       falcon_vmode        ;Aufloesung setzen

setres_falcon_exit:movem.l (sp)+,d0-d2/a0-a2
                              btst      #STC_BIT,modecode+1
                              beq.s     setres_falcon_ret
                              moveq     #3,d0
                              and.w     modecode.w,d0
                              neg.w     d0
                              addq.w    #2,d0
setres_falcon_ret:rts

;Bildschirmspeicher allozieren
;Vorgaben:
;Register d0 wird veraendert
;Eingaben:
;d0.l Laenge des Speichers
;Ausgaben:
;d0.l Adresse des Speichers
ScrnMalloc:         movem.l   d1-d2/a0-a2,-(sp)
                              move.l    d0,-(sp)
                              move.w    #SCRNMALLOC,-(sp) ;Bereich am Ende des Speichers allozieren
                              trap      #GEMDOS
                              addq.w    #6,sp
                              movem.l   (sp)+,d1-d2/a0-a2
                              rts

;modecode ueberpruefen
;Vorgaben:
;Register d1 wird veraendert
;Eingaben:
;d1.w modecode
;Ausgaben:
;d1.w modecode (evtl. korrigiert)
Checkmode:               movem.l   d0/d2/a0-a2,-(sp)
                              move.w    monitor.w,d0             ;Monitor
                              move.w    modecode.w,d2                 ;bisheriger Modus
                              tst.w     d0                            ;Monochrommonitor?
                              bne.s     checkmode_pal
                              move.w    #STMODES+COL80,d1   ;ST-Monochrom
                              bra.s     checkmode_exit

checkmode_pal:      bclr      #PAL_BIT,d1
                              btst      #PAL_BIT,d2              ;bisher PAL-Modus? (Bit 5)
                              beq.s     checkmode_vga
                              bset      #PAL_BIT,d1

checkmode_vga:      cmp.w     #2,d0                         ;VGA-Monitor?
                              bne.s     checkmode_tv
                              or.w      #VGA,d1                       ;VGA-Bit setzen

checkmode_vga_st: btst        #STC_BIT,d1              ;ST-Kompatibilitaet?
                              beq.s     checkmode_exit
                              bset      #VTF_BIT,d1              ;Double-Scan
                              moveq     #7,d0
                              and.w     d1,d0                         ;Farbtiefe
                              bne.s     checkmode_exit
                              bclr      #VTF_BIT,d1              ;kein Interlace, da 640*400 mono
                              bra.s     checkmode_exit

checkmode_tv:       btst      #VGA_BIT,d1              ;VGA-Monitor?
                              beq.s     checkmode_tv_st
                              eori.w    #VERTFLAG+VGA,d1         ;kein VGA-Monitor, evtl. Interlace

checkmode_tv_st:    btst      #STC_BIT,d1              ;ST-Kompatibilitaet?
                              beq.s     checkmode_exit
                              bclr      #VTF_BIT,d1              ;kein Interlace
                              moveq     #7,d0
                              and.w     d1,d0                         ;ST monochrom?
                              bne.s     checkmode_exit

                              bset      #VTF_BIT,d1              ;Interlace, da 640*400 mono
checkmode_exit:     movem.l   (sp)+,d0/d2/a0-a2
                              rts


**********************************************************************
*
* void Setpalette( int ptr[16] )
*
Setpalette:              move.l    (a0),colorptr.w
                              rte  

**********************************************************************
*
* int Setcolor( int nr, int val )
*
Setcolor:
 move.w   (a0)+,d0       ; Farbnummer
 add.w    d0,d0
 and.w    #$1f,d0
 lea      $ffff8240,a1   ; Farbregister 0
 adda.w   d0,a1
 move.w   (a1),d0        ; alter Farbwert
 and.w    #$fff,d0       ; RGB (STe)
 tst.b    machine_type
 bne.b    setc_ste
 and.w    #$777,d0       ; RGB
setc_ste:
 tst.w    (a0)           ; val
 bmi.b    setc_rte      ; alten Farbwert zurueckgeben
 move.w   (a0),(a1)      ; color setzen
setc_rte:
 rte


;Tabulatorgroesse:  3
;Kommentare:                                                ;ab Spalte 60

;Bomben ausgeben
;Eingaben:
;d1.w Anzahl der Bomben - 1
;Ausgaben:
;-
__printbombs:
 move.b   sshiftmd,d7
 and.w    #7,d7          ; auf STE/TT/Falcon Aufloesungen 0 bis 7 zulassen
 tst.b    machine_type
 bne.b    prbo_ste
 and.w    #3,d7          ; beim ST nur Aufloesungen 0 bis 2
prbo_ste:
 moveq    #0,d0
 suba.l   a0,a0
 movep.w  $ffff8201(a0),d0
 lsl.l    #8,d0
 tst.b    machine_type
 beq.b    prbo_st
 move.b   $ffff820d,d0   ; STe/TT/Falcon: Lowbyte der Bildschirmadresse
prbo_st:
 movea.l  d0,a0          ; Bildschirmadresse
 cmp.w    #6,d7          ; TT-Hoch?
 blt.b    prbo_offset_st
 adda.l   #$12c00,a0     ; Offset der Bildschirmmitte bei TT-Hoch
 bra.b    prbo_image_out
prbo_offset_st:
 adda.w   #$3e80,a0      ; Offset der Bildschirmmitte bei ST-High/ST-Mid/ST-Low

prbo_image_out:
 lea      prbo_image(pc),a1        ; Image der Bombe
 moveq    #15,d6                   ; 16 Zeilen
 add.w    d7,d7
prbo_bloop:
 move.w   d1,d2                    ; Anzahl der Bomben - 1
 movea.l  a0,a2
prbo_planes:
 move.w   prbo_restab1(pc,d7.w),d5 ; Ebenen - 1
prbo_copy:
 move.w   (a1),(a2)+
 dbf      d5,prbo_copy
 dbf      d2,prbo_planes
 addq.w   #2,a1                    ; naechste Bombenzeile
 adda.w   prbo_restab2(pc,d7.w),a0 ; naechste Bildschirmzeile
 dbf      d6,prbo_bloop

 moveq    #29,d7                   ; TOS 2.05: warten
prbo_wait:
 bsr      _Vsync
 dbf      d7,prbo_wait
 rts

prbo_restab1:
 DC.W     3
 DC.W     1
 DC.W     0
 DC.W     0
 DC.W     3                        ; TT- Aufloesungen:
 DC.W     0
 DC.W     0
 DC.W     7

prbo_restab2:
 DC.W     $a0
 DC.W     $a0
 DC.W     $50
 DC.W     0                        ; TT- Aufloesungen
 DC.W     $140
 DC.W     0
 DC.W     $a0
 DC.W     $140


prbo_image:
 DC.W     %0000011000000000
 DC.W     %0010100100000000
 DC.W     %0000000010000000
 DC.W     %0001001011101000
 DC.W     %0001000111110000
 DC.W     %0000000111110000
 DC.W     %0000011111111100
 DC.W     %0000111111111110
 DC.W     %0000110111111110
 DC.W     %0001111111111111
 DC.W     %0001111111101111
 DC.W     %0000111111101110
 DC.W     %0000111111011110
 DC.W     %0000011111111100
 DC.W     %0000001111111000
 DC.W     %0000000011100000


**********************************************************************
***************************  TT - Video    ***************************
**********************************************************************

*********************************************************************
*
* long Esetshift( int shiftmode )
*

Esetshift:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetshift
 bsr      _Vsync              ; zerstoert d0
 moveq    #0,d0
 move.w   $ffff8262,-(sp)     ; alten TT-Shiftermodus/Bank retten
 move.w   (a0),$ffff8262      ; TT-Shiftermodus/Bank setzen
 move.b   $ffff8262,d0        ; neuen Wert holen
 and.w    #7,d0               ; Aufloesung extrahieren
 move.b   d0,sshiftmd
 clr.w    vblsem              ; VBL deaktivieren
 move.w   modecode.w,d0                 ;Moduswort fuer Falcon
 jsr      vt52_init           ; sichert alle benutzten Register
 move.w   #1,vblsem           ; VBL aktivieren
 move.w   (sp)+,d0            ; alter Wert
exit_Esetshift:
 rte


********************************************************************
*
* long Egetshift( void )
*

Egetshift:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b     exit_Egetshift
 move.w   $ffff8262,d0        ; TT- Shiftermodus
exit_Egetshift:
 rte

********************************************************************
*
* long Esetbank( int num )
*

Esetbank:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetbank
 move.w   $ffff8262,d0        ; TT-Shiftermodus/Bank
 and.w    #$f,d0              ; Banknummer extrahieren
 move.w   (a0),d1             ; aendern ?
 bmi.b    exit_Esetbank       ; nein, nur Wert zurueckgeben
 move.b   d1,$ffff8263        ; Bank aendern
exit_Esetbank:
 rte


********************************************************************
*
* long Esetcolor( int num, int col )
*

Esetcolor:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetcolor
 lea      $ffff8400,a1        ; TT-Palette
 move.w   (a0)+,d0            ; num (0..255)
 add.w    d0,d0               ; fuer Wortzugriff
 adda.w   d0,a1
 move.w   (a1),d0             ; alten Wert holen
 and.w    #$fff,d0            ; je 4 Bits fuer RGB extrahieren
 move.w   (a0),d1             ; neuer Wert
 bmi.b    exit_Esetcolor      ; nicht aendern
 move.w   d1,(a1)             ; aendern
exit_Esetcolor:
 rte


********************************************************************
*
* long Esetpalette( int num, int count, int *cols )
*

Esetpalette:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetpalette
 move.w   (a0)+,d0            ; erster Eintrag
 movea.w  d0,a1
 adda.w   a1,a1
 sub.w    #$100,d0
 neg.w    d0                  ; d0 = Eintraege hinter einschl. <num>
 move.w   (a0)+,d1            ; count
 cmp.w    d0,d1
 ble.b    esetpl_l1           ; ist ok
 move.w   d0,d1               ; Maximum nehmen
esetpl_l1:
 movea.l  (a0)+,a0            ; cols
 lea      $ffff8400(a1),a1
 bra.b    esetpl_eloop
esetpl_loop:
 move.w   (a0)+,(a1)+
esetpl_eloop:
 dbf      d1,esetpl_loop
exit_Esetpalette:
 rte


********************************************************************
*
* long Egetpalette( int num, int count, int *cols )
*

Egetpalette:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Egetpalette
 move.w   (a0)+,d0
 movea.w  d0,a1
 adda.w   a1,a1
 sub.w    #$100,d0
 neg.w    d0
 move.w   (a0)+,d1
 cmp.w    d0,d1
 ble.b    egetpl_l1
 move.w   d0,d1
egetpl_l1:
 movea.l  (a0),a0
 lea      $ffff8400(a1),a1
 bra.b    egetpl_eloop
egetpl_loop:
 move.w   (a1)+,(a0)+
egetpl_eloop:
 dbf      d1,egetpl_loop
exit_Egetpalette:
 rte


********************************************************************
*
* long Esetgray( int switch )
*
* switch == 0: Farbe
* switch >  0: grau
* switch <  0: Wert holen
*

Esetgray:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetgray
 move.b   $ffff8262,d1        ; TT-Shiftmode
 bclr     #4,d1               ; gray_mode in d1 loeschen
 sne      d0
 andi.l   #1,d0               ; d1 = 1, falls Bit 4 gesetzt war
 tst.w    (a0)
 beq.b    esetgr_l1           ; Farbe
 bmi.b    exit_Esetgray       ; nur holen
 bset     #4,d1               ; grau
esetgr_l1:
 move.b   d1,$ffff8262
exit_Esetgray:
 rte


********************************************************************
*
* long Esetsmear( int switch )
*
* switch == 0: normal
* switch >  0: smear
* switch <  0: Wert holen
*

Esetsmear:
 moveq    #0,d0
 cmpi.b   #3,machine_type
 bne.b    exit_Esetsmear
 move.b   $ffff8262,d1
 bclr     #7,d1
 sne      d0
 andi.l   #1,d0
 tst.w    (a0)
 beq.b    esetsm_l1
 bmi.b    exit_Esetsmear
 bset     #7,d1
esetsm_l1:
 move.b   d1,$ffff8262
exit_Esetsmear:
 rte

;Vsetmode() (XBIOS 88)
;Vorgaben:
;Register d0-d2/a0-a2 koennen veraendert werden
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;d0.w modecode
Vsetmode:           move.w    modecode.w,-(sp)
                              move.w    (a0),d0                       ;Modus nur zurueckliefern?
                              bmi.s          Vsetmode_exit
                              bsr.s          falcon_vmode
Vsetmode_exit:      move.w    (sp)+,d0                      ;alter modecode
                              rte

                              
falcon_vmode:       move.b    MON_ID.w,d1
                              lsr.w          #6,d1
                              and.w          #3,d1                              
                              move.w    d1,monitor.w             ;Monitortyp

                              cmp.w          #MONO_MON,d1             ;SM 124
                              bne.s          falcon_comp
                              
                              move.w    #STMODES+COL80+BPS1,d0   ;modecode
                              lea       sm2_640_400(pc),a0
                              bra.s          falcon_vmode_set

falcon_comp:        add.w          d1,d1
                              add.w          d1,d1

                              btst      #STC_BIT,d0                   ;ST-kompatibel?
                              beq.s          falcon_vmode_nc
                              
                              lea       mon_st_tab(pc),a0
                              movea.l   0(a0,d1.w),a0
                              moveq          #7,d1
                              and.w          d0,d1
                              cmp.w          #BPS4,d1                      ;ungueltige Bittiefe?
                              bhi.s          Vsetmode_exit
                              add.w          d1,d1
                              add.w          d1,d1
                              movea.l   0(a0,d1.w),a0
                              bra.s          falcon_vmode_set
                              
falcon_vmode_nc:    movea.l   mon_mode_tab(pc,d1.w),a0
                              
                              bsr       check_modecode           ;modecode ueberpruefen
                              
                              moveq          #COL80,d1
                              and.w          d0,d1                              ;Bit fuer Spaltenanzahl (Bit 3)
                              lsr.w          #1,d1                              ;/8*4
                              move.l    0(a0,d1.w),d2            ;Tabelle mit Zeigern auf Registerdaten
                              beq.s          Vsetmode_exit
                              movea.l   d2,a0
                              moveq          #7,d1
                              and.w          d0,d1                              ;Bittiefe
                              cmp.w          #BPS16,d1                ;ungueltige Bittiefe?
                              bhi.s          Vsetmode_exit
                              moveq          #OVERSCAN,d2
                              and.w          d0,d2                              ;Bit fuer Overscan (Bit 6)
                              lsr.w          #OVS_BIT,d2
                              add.w          d1,d1
                              add.w          d2,d1
                              add.w          d1,d1
                              add.w          d1,d1
                              move.l    0(a0,d1.w),d2            ;Zeiger auf Registerdaten
                              beq.s          Vsetmode_exit
                              movea.l   d2,a0
falcon_vmode_set:   move.w    d0,modecode.w            ;Modus merken
                              bsr       sync_screen                   ;Sync
                              bsr       falcon_set_mode          ;Modus setzen
                              rts

;Falcon-Modi
mon_mode_tab:       DC.L 0                                       ;SM 124 wird vorher abgefangen
                              DC.L rgb_tab
                              DC.L vga_tab
                              DC.L rgb_tab                            ;TV-Monitor - Achtung VXX-Bit 1 von Hand setzen!

vga_tab:                 DC.L vga320_tab
                              DC.L vga640_tab

rgb_tab:                 DC.L rgb320_tab
                              DC.L rgb640_tab

;ST-Komp.-Modi
mon_st_tab:              DC.L 0                                       ;SM 124 wird vorher abgefangen
                              DC.L rgb_st_tab
                              DC.L vga_st_tab
                              DC.L rgb_st_tab                         ;TV-Monitor - Achtung VXX-Bit 1 von Hand setzen!

rgb_st_tab:              DC.L rgb_st_high
                              DC.L rgb_st_mid
                              DC.L rgb_st_low

vga_st_tab:              DC.L vga_st_high
                              DC.L vga_st_mid
                              DC.L vga_st_low
;-----------------------------------------------
rgb320_tab:              DC.L 0
                              DC.L 0
                              DC.L rgb4_320_200
                              DC.L rgb4_384_240
                              DC.L rgb16_320_200
                              DC.L rgb16_384_240
                              DC.L rgb256_320_200
                              DC.L rgb256_384_240
                              DC.L rgb32k_320_200
                              DC.L rgb32k_384_240

rgb640_tab:              DC.L rgb2_640_200
                              DC.L rgb2_768_240
                              DC.L rgb4_640_200
                              DC.L rgb4_768_240
                              DC.L rgb16_640_200
                              DC.L rgb16_768_240
                              DC.L rgb256_640_200
                              DC.L rgb256_768_240
                              DC.L rgb32k_640_200
                              DC.L rgb32k_768_240
;-----------------------------------------------
vga640_tab:              DC.L vga2_640_480
                              DC.L 0
                              DC.L vga4_640_480
                              DC.L 0
                              DC.L vga16_640_480
                              DC.L 0
                              DC.L vga256_640_480
                              DC.L 0
                              DC.L 0
                              DC.L 0

vga320_tab:              DC.L 0
                              DC.L 0
                              DC.L vga4_320_480
                              DC.L 0
                              DC.L vga16_320_480
                              DC.L 0
                              DC.L vga256_320_480
                              DC.L 0
                              DC.L vga32k_320_480
                              DC.L 0
;-----------------------------------------------
sync_screen:      movem.l     d0-d1,-(sp)
                              move     sr,d0
                  andi     #$fbff,sr
                  move.l   _frclock.w,d1
sync_scr_loop:      cmp.l    _frclock.w,d1
                  beq.s       sync_scr_loop
                  move     d0,sr
                  movem.l     (sp)+,d0-d1
                              rts
;-----------------------------------------------
;Video-Modus fuer Falcon setzen
;Vorgaben:
;Register d0-d2/a0-a2 koennen veraendert werden
;Eingaben:
;d0.w modecode (es wird nur Bit 8 - VERTFLAG - getestet und evtl in VCO gesetzt) 
;a0.l Zeiger auf die Registerdaten
;Ausgaben:
;-
falcon_set_mode:    clr.w     HSCROLL.w           ;keine bitweise Verschiebung
                              clr.w     LINE_OFFSET.w       ;keine zusaetzlichen Worte pro Zeile

                              cmp.w          #VGA_MON,monitor.w  ;bei VGA-Monitor Doublescan einschalten
                              bne.s          falcon_set_rgb

                              move.w    (a0)+,VFT.w
                              move.w    (a0)+,VSS.w
                              move.w    (a0)+,VBB.w
                              move.w    (a0)+,VBE.w
                              move.w    (a0)+,VDB.w
                              move.w    (a0)+,VDE.w
                              move.w    (a0)+,HHT.w
                              move.w    (a0)+,HSS.w
                              move.w    (a0)+,HBB.w
                              move.w    (a0)+,HBE.w
                              move.w    (a0)+,HDB.w
                              move.w    (a0)+,HDE.w
                              move.w    (a0)+,HFS.w
                              move.w    (a0)+,HEE.w
                              move.w    (a0)+,d1
                              cmp.w          #-1,d1
                              beq.s          falcon_set_st
                              bsr       sync_screen              ;#neu
                              move.w    d1,SP_SHIFT.w
falcon_set_st:      move.w    (a0)+,d1
                              cmp.w          #-1,d1
                              beq.s          falcon_set_vco
                              clr.w          SP_SHIFT.w               ;bei Kompatibilitaetsmodi auf 0 setzen
                              move.w    d1,ST_SHIFT.w
falcon_set_vco:     move.w    (a0)+,d1
                              btst      #8,d0                         ;Doublescan?
                              beq.s          falcon_set_vco2
                              or.w      #1,d1                         ;bei VGA-Monitor Doublescan einschalten
falcon_set_vco2:    move.w    d1,VCO.w
                              move.w    (a0)+,VWRAP.w
                              move.w    (a0)+,VXX.w
                              move.w    (a0)+,EXTCLK.w
                              rts
;-----------------------------------------------
falcon_set_rgb:     move.w    (a0)+,d1                 ;VFT
                              btst      #8,d0                         ;Interlace?
                              beq.s          falcon_set_vfti
                              and.w          #$fffe,d1           ;nur gerade Werte bei Interlace
falcon_set_vfti:    move.w    d1,VFT.w
                              move.w    (a0)+,VSS.w
                              move.w    (a0)+,VBB.w
                              move.w    (a0)+,VBE.w
                              
                              move.w    (a0)+,d1                 ;VDB
                              btst      #8,d0                         ;Interlace?
                              beq.s          falcon_set_vdbi
                              and.w          #$fffe,d1           ;nur gerade Werte bei Interlace
falcon_set_vdbi:    move.w    d1,VDB.w
                              
                              move.w    (a0)+,d1                 ;VDE
                              btst      #8,d0                         ;Interlace?
                              beq.s          falcon_set_vdei
                              and.w          #$fffe,d1           ;nur gerade Werte bei Interlace
falcon_set_vdei:    move.w    d1,VDE.w
                              
                              move.w    (a0)+,HHT.w
                              move.w    (a0)+,HSS.w
                              move.w    (a0)+,HBB.w
                              move.w    (a0)+,HBE.w
                              move.w    (a0)+,HDB.w
                              move.w    (a0)+,HDE.w
                              move.w    (a0)+,HFS.w
                              move.w    (a0)+,HEE.w
                              move.w    (a0)+,d1
                              cmp.w          #-1,d1
                              beq.s          falcon_set_sti
                              bsr       sync_screen              ;#neu
                              move.w    d1,SP_SHIFT.w
falcon_set_sti:     move.w    (a0)+,d1
                              cmp.w          #-1,d1
                              beq.s          falcon_set_vcoi
                              clr.w          SP_SHIFT.w               ;bei Kompatibilitaetsmodi auf 0 setzen
                              move.w    d1,ST_SHIFT.w
falcon_set_vcoi:    move.w    (a0)+,d1
                              btst      #8,d0                         ;Interlace?
                              beq.s          falcon_set_vcoj
                              or.w      #2,d1                              ;bei RGB und TV Interlace einschalten
falcon_set_vcoj:    move.w    d1,VCO.w
                              move.w    (a0)+,VWRAP.w
                              move.w    (a0)+,d0                 ;VXX
                              cmp.w          #TV_MON,monitor.w
                              bne.b          falc_set_vxx
                              ori.w          #2,d0                         ;bei TV-Monitor Bit 1 im VXX setzen
falc_set_vxx:                           
                              move.w    d0,VXX.w
                              move.w    (a0)+,EXTCLK.w
                              rts

;;;;;;;;;;;;;;;;;;;;;;;;

check_modecode:     movem.l   d1-d2/a0-a2,-(sp)

                              and.w          #$01ff,d0           ;alle ungueltigen Bits ausmaskieren

                              moveq          #NUMCOLS,d1
                              and.w          d0,d1                         ;2 Farben?
                              bne.s          check_mode_mon
                              
                              bset      #CLM_BIT,d0              ;80 Spalten

check_mode_mon:     move.w    monitor.w,d1
                              moveq          #1,d2
                              and.w          syshdr+os_palmode(pc),d2 ;0:NTSC 1:PAL

                              cmp.w          #TV_MON,d1               ;TV?
                              beq.s          check_mode_rgb
                              
                              cmp.w          #COLOR_MON,d1       ;RGB-Monitor?
                              bne.s          check_mode_vga

check_mode_rgb:     bclr      #VGA_BIT,d0              ;kein VGA-Monitor
                              bclr      #PAL_BIT,d0              ;kein PAL
                              
                              tst.w          d2                            ;PAL?
                              beq.s          check_mode_exit
                              
                              bset      #PAL_BIT,d0
                              bra.s          check_mode_exit                              

check_mode_vga:     cmp.w          #VGA_MON,d1              ;VGA-Monitor?
                              bne.s          check_mode_exit

                              bclr      #PAL_BIT,d0              ;kein PAL
                              bclr      #OVS_BIT,d0              ;kein Overscan
                              bset      #VGA_BIT,d0              ;VGA-Monitor

                              moveq          #NUMCOLS,d1
                              and.w          d0,d1
                              cmp.w          #BPS16,d1           ;32k?
                              bne.s          check_mode_exit
                              bclr      #CLM_BIT,d0              ;nur 40 Spalten bei VGA und 32k

check_mode_exit:    movem.l   (sp)+,d1-d2/a0-a2
                              rts
                              
;Jeder Modus enthaelt die folgende Registerreihenfolge (insgesamt 20 Eintraege)
;VFT
;VSS
;VBB
;VBE
;VDB
;VDE
;HHT
;HSS
;HBB
;HBE
;HDB
;HDE
;HFS
;HEE
;SP_SHIFT (-1, wenn er nicht gesetzt werden soll)
;ST_SHIFT (-1, wenn er nicht gesetzt werden soll)
;VCO (Bit 0: Doublescan Bit 1: Interlace)
;VWRAP
;VXX (385 bei RGB, 387 bei TV, 390 bei VGA - siehe auch ST-Modi)
;EXTCLK

;                                       VFT   VSS VBB VBE VDB VDE HHT HSS HBB HBE HDB HDE
rgb_st_low:              DC.W  625, 619,613, 47,111,511, 62, 52, 50,  9,575, 28,0,0,  -1,  0,0, 80,129,512
rgb_st_mid:              DC.W  625, 619,613, 47,111,511, 62, 52, 50,  9,575, 28,0,0,  -1,256,4, 80,129,512
rgb_st_high:        DC.W  624, 619,613, 47,126,526,510,434,409, 80,1007,160,0,0,1024,-1,6, 40,385,512

rgb4_320_200:       DC.W  625, 619,613, 47,127,527, 62, 52, 48,  8,569, 18,0,0,  -1,256,0, 40,385,512
rgb16_320_200:      DC.W  625, 619,613, 47,127,527,254,216,203, 39, 12,109,0,0,   0, -1,0, 80,385,512
rgb256_320_200:     DC.W  625, 619,613, 47,127,527,254,216,203, 39, 28,125,0,0,  16, -1,0,160,385,512
rgb32k_320_200:     DC.W  625, 619,613, 47,127,527,254,216,203, 39, 46,143,0,0, 256, -1,0,320,385,512

rgb2_640_200:       DC.W  625, 619,613, 47,127,527,510,434,409, 80,1007,160,0,0,1024,-1,4, 40,385,512
rgb4_640_200:       DC.W  625, 619,613, 47,127,527, 62, 52, 48,  8,  2, 32,0,0,  -1,256,4, 80,385,512
rgb16_640_200:      DC.W  625, 619,613, 47,127,527,510,434,409, 80, 77,254,0,0,   0, -1,4,160,385,512
rgb256_640_200:     DC.W  625, 619,613, 47,127,527,510,434,409, 80, 93,270,0,0,  16, -1,4,320,385,512
rgb32k_640_200:     DC.W  625, 619,613, 47,127,527,510,434,409, 80,113,290,0,0, 256, -1,4,640,385,512

rgb4_384_240:       DC.W  625, 619,613, 47, 86,566, 62, 52, 48,  8,562, 27,0,0,  -1,256,0, 48,385,512
rgb16_384_240:      DC.W  625, 619,613, 47, 86,566,254,216,203, 39,748,141,0,0,   0, -1,0, 96,385,512
rgb256_384_240:     DC.W  625, 619,613, 47, 86,566,254,216,203, 39,764,157,0,0,  16, -1,0,192,385,512
rgb32k_384_240:     DC.W  625, 619,613, 47, 86,566,254,216,203, 39, 14,175,0,0, 256, -1,0,384,385,512

rgb2_768_240:       DC.W  625, 619,613, 47, 86,566,510,434,409, 80,943,224,0,0,1024, -1,4, 48,385,512
rgb4_768_240:       DC.W  625, 619,613, 47, 86,566, 62, 52, 48,  8,567, 32,0,0,  -1,256,4, 96,385,512
rgb16_768_240:      DC.W  625, 619,613, 47, 86,566,510,434,409, 80, 13,318,0,0,   0, -1,4,192,385,512
rgb256_768_240:     DC.W  625, 619,613, 47, 86,566,510,434,409, 80, 29,334,0,0,  16, -1,4,384,385,512
rgb32k_768_240:     DC.W  625, 619,613, 47, 86,566,510,434,409, 80, 49,354,0,0, 256, -1,4,768,385,512

;                                       VFT   VSS VBB VBE VDB VDE HHT HSS HBB HBE HDB HDE
vga_st_low:              DC.W 1049,1045,943,143,143,943, 23, 17, 18,  1,526, 13,0,0,  -1,  0,5, 80,390,512
vga_st_mid:              DC.W 1049,1045,943,143,143,943, 23, 17, 18,  1,526, 13,0,0,  -1,256,9, 80,390,512
vga_st_high:        DC.W 1049,1045,943,143,143,943,198,150,141, 21,627, 80,0,0,1024, -1,8, 40,390,512

vga2_640_480:       DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,627, 80,0,0,1024, -1,8, 40,390,512
vga4_640_480:       DC.W 1049,1045,1023,63,63,1023, 23, 17, 18,  1,526, 13,0,0,  -1,256,8, 80,390,512
vga16_640_480:      DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,675,124,0,0,   0, -1,8,160,390,512
vga256_640_480:     DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,683,132,0,0,  16, -1,8,320,390,512

vga4_320_480:       DC.W 1049,1045,1023,63,63,1023, 23, 17, 18,  1,522,  9,0,0,  -1,256,4, 40,390,512
vga16_320_480:      DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,650,107,0,0,   0, -1,4, 80,390,512
vga256_320_480:     DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,666,123,0,0,  16, -1,4,160,390,512
vga32k_320_480:     DC.W 1049,1045,1023,63,63,1023,198,150,141, 21,684,145,0,0, 256, -1,4,320,390,512

;                                       VFT   VSS VBB VBE VDB VDE HHT HSS HBB HBE HDB HDE
sm2_640_400:        DC.W 1001, 999,   0, 0,67, 867, 26, 20,  0,  0,527, 12,0,0,  -1,512,8, 40,128,512


;WORD     mon_type( void ) (XBIOS 89)
;Vorgaben:
;
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;d0.w monitor
mon_type:           move.b    MON_ID.w,d0
                              lsr.w          #6,d0
                              and.w          #3,d0               ;Monitortyp
                              move.w    d0,monitor
                              rte

;void     VsetSync( WORD external ) (XBIOS 90)
;Vorgaben:
;
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;-
VsetSync:           move.w    (a0),d0        ;external
                              btst      #0,d0               ;external clock?
                              beq.b          VsS_intclk
                              bset.b    #0,EXTCLK.w
                              bra.b          VsS_tstVS
                              
VsS_intclk:              bclr.b    #0,EXTCLK.w

VsS_tstVS:               move.w    SP_SHIFT.w,d1
                              and.w          #$ff9f,d1 ;setze internen VS & HS
                              btst      #1,d0               ;use external VSync?
                              beq.b          VsS_tstHS
                              bset.b    #5,d1               ;ext. VS

VsS_tstHS:               btst      #2,d0               ;use external HSync?
                              beq.b          VsS_setSync
                              bset.b    #6,d1               ;ext. HS

VsS_setSync:        move.w    d1,SP_SHIFT.w
                              rte

;VgetSize() (XBIOS 91)
;Vorgaben:
;Wenn der ScreenBlaster nicht aktiv ist, wird die TOS-Routine angesprungen
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;d0.l Speicherbedarf
VgetSize:           move.w    (a0),d0             ;modecode
                              bsr.s          falcon_vsize
                              rte

rez_bps_tab:        DC.W 1,2,4,8,16

;Groesse einer Aufloesung berechnen
;Eingaben:
;d0.w modecode
;Ausgaben:
;d0.l Laenge des Bildschirmspeichers in Bytes
falcon_vsize:       movem.l   d1-d3,-(sp)
                              moveq     #7,d1
                              and.w     d0,d1               ;Farbtiefe
                              add.w     d1,d1
                              move.w    rez_bps_tab(pc,d1.w),d3  ;Ebenenanzahl

                              mulu      #40,d3              ;40 Bytes pro Zeile
                              btst      #CLM_BIT,d0    ;80 Spalten?
                              beq.s     flc_hor_over
                              add.w     d3,d3               ;80 Spalten - Breite verdoppeln
flc_hor_over:       btst      #OVS_BIT,d0    ;Overscan?
                              beq.s     flc_st_mode
                              mulu      #12,d3
                              divu      #10,d3              ;Overscan-Faktor 1.2

flc_st_mode:        btst      #STC_BIT,d0    ;ST-Kompatibilitaet?
                              beq.s     flc_vga_mode
                              move.w    #200,d2             ;200 Zeilen in Farbe
                              moveq     #7,d1
                              and.w     d0,d1               ;Farbtiefe
                              bne.s     flc_vsize_exit
                              add.w     d2,d2               ;400 Zeilen in monochrom
                              bra.s     flc_vsize_exit

flc_vga_mode:       btst      #VGA_BIT,d0    ;VGA-Monitor?
                              beq.s     flc_tv_mode
                              move.w    #240,d2             ;240 Zeilen
                              btst      #VTF_BIT,d0    ;Interlace oder Doublescan?
                              bne.s     flc_ver_over
                              add.w     d2,d2               ;480 Zeilen
                              bra.s     flc_ver_over
flc_tv_mode:        move.w    #200,d2             ;200 Zeilen
                              btst      #VTF_BIT,d0    ;Interlace oder Doublescan?
                              beq.s     flc_ver_over
                              add.w     d2,d2               ;400 Zeilen
flc_ver_over:       btst      #OVS_BIT,d0    ;Overscan?
                              beq.s     flc_vsize_exit
                              muls      #12,d2
                              divs      #10,d2              ;Overscan-Faktor 1.2
flc_vsize_exit:     mulu      d2,d3                    ;Groesse des Bildschirmspeichers in Bytes
                              move.l    d3,d0
                              movem.l   (sp)+,d1-d3
                              rts

;void     VsetRGB( WORD index, WORD count, LONG *array ) (XBIOS 93)
;Vorgaben:
;
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;-
VsetRGB:                 movea.l   palette_ptr.w,a1
                              move.w    (a0)+,d0                 ;index
                              move.w    (a0)+,d1                 ;count
                              move.l    (a0)+,a0                 ;array

                              cmp.w          #255,d0
                              bhi.s          VsetRGB_exit
                              
                              subq.w    #1,d1
                              bmi.s          VsetRGB_exit

                              cmp.w          #100,HHT.w               ;Kompatibilitaetsmodus?
                              blo.s          VsetRGB_comp

                              move     sr,-(sp)                  ;sr sichern
                  ori         #$0700,sr
          
                              move.w    d0,d2
                              add.w          d1,d2                         ;Index der letzten Farbe
                              
                              cmp.w          palette_first.w,d0
                              bge.s          VsetRGB_last

                              move.w    d0,palette_first.w

VsetRGB_last:       cmp.w          palette_last.w,d2
                              ble.s          VsetRGB_offset

                              move.w    d2,palette_last.w

VsetRGB_offset:     add.w          d0,d0
                              add.w          d0,d0
                              adda.w    d0,a1

VsetRGB_loop:       move.l    (a0)+,(a1)+
                              dbra      d1,VsetRGB_loop
                              
                              move      (sp)+,sr
                              
VsetRGB_exit:       rte

;VsetRGB() fuer Modi, die auf den ST-Shifter zugreifen
;d0.w index
;d1.w count - 1
;a0.l array
;a1.l palette_ptr
VsetRGB_comp:       move     sr,-(sp)                  ;sr sichern
                  ori         #$0700,sr

                              lea       1024(a1),a2              ;Zeiger auf WORD [16]
                              move.l    a2,colorptr.w
                              
                              add.w          d0,d0
                              adda.w    d0,a2
                              add.w          d0,d0
                              adda.w    d0,a1

VsetRGB_cloop:      move.l    (a0)+,d0
                              move.l    d0,(a1)+

                              swap      d0
                              lsr.w          #4,d0
                              and.w          #$000f,d0           ;die obersten 4 Bits des Rot-Anteils
                              move.b    VsetRGB_conv(pc,d0.w),d2
                              lsl.w          #4,d2

                              clr.w          d0
                              rol.l          #4,d0                         ;die obersten 4 Bits des Gruen-Anteils
                              or.b      VsetRGB_conv(pc,d0.w),d2
                              lsl.w          #4,d2

                              rol.l          #8,d0
                              and.w          #$000f,d0           ;die obersten 4 Bits der Blau-Anteils
                              or.b      VsetRGB_conv(pc,d0.w),d2

                              move.w    d2,(a2)+
                              
                              dbra      d1,VsetRGB_cloop
                              
                              move      (sp)+,sr
                              rte

VsetRGB_conv:       DC.b      %0000                         ;0
                              DC.b      %1000                         ;1
                              DC.b      %0001                         ;2
                              DC.b      %1001                         ;3
                              DC.b      %0010                         ;4
                              DC.b      %1010                         ;5
                              DC.b      %0011                         ;6
                              DC.b      %1011                         ;7
                              DC.b      %0100                         ;8
                              DC.b      %1100                         ;9
                              DC.b      %0101                         ;10
                              DC.b      %1101                         ;11
                              DC.b      %0110                         ;12
                              DC.b      %1110                         ;13
                              DC.b      %0111                         ;14
                              DC.b      %1111                         ;15
                              
                              
                              
;void     VgetRGB( WORD index, WORD count, LONG *array ) (XBIOS 94)
;Vorgaben:
;
;Eingaben:
;a0.l Zeiger auf die Parameter
;Ausgaben:
;-
VgetRGB:                 movea.l   palette_ptr.w,a1
                              move.w    (a0)+,d0                 ;index
                              move.w    (a0)+,d1                 ;count
                              move.l    (a0)+,a0                 ;array
                              
                              cmp.w          #255,d0
                              bhi.s          VgetRGB_exit
                              
                              add.w          d0,d0
                              add.w          d0,d0
                              adda.w    d0,a1
                              
                              subq.w    #1,d1
                              bmi.s          VgetRGB_exit
VgetRGB_loop:       move.l    (a1)+,(a0)+
                              dbra      d1,VgetRGB_loop

VgetRGB_exit:       rte
