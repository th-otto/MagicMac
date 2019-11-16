**********************************************************************
*
* MagXBoot for Milan
*
* Alle Meldungen erfolgen je nach System in Deutsch oder Englisch.
*
**********************************************************************

        INCLUDE "osbind.inc"

fstrm_beg EQU  ____md
os_chksum EQU  trp14ret

        .TEXT

        SUPER

        movea.l $0004(a7),a1                    ; BasePagePointer from Stack
        lea     stack(pc),a7
        movea.w #$0100,a0                       ; Programmlaenge + $100
        adda.l  p_tlen(a1),a0
        adda.l  p_dlen(a1),a0
        adda.l  p_blen(a1),a0
        move.l  a0,-(a7)
        move.l  a1,-(a7)
        clr.w   -(a7)
        gemdos   Mshrink
        adda.w  #$000C,a7
        tst.l   d0
        bmi     err

* Nationalitaet bestimmen und Titelzeile ausgeben

        clr.l    -(sp)
        gemdos   Super
        addq.l  #6,a7

; Search cookie

        move.l  _p_cookies,d0
        beq.s   is_milan
        movea.l d0,a0
cookie_loop:
        move.l  (a0),d0                         ; Kennung
        beq.s   cookie_loop                     ; Ende-Kennung
        addq.l  #8,a0
        cmpi.l  #'_MCH',d0                      ; _MCH
        beq.s   cookie_mch
        cmpi.l  #'MagX',d0                      ; MagX
        beq     err                             ; MagiX schon aktiv
        bra.s   cookie_loop
cookie_mch:
        move.l  -4(a0),machine
        bra.s   cookie_loop

is_milan:
        lea     $00E00000.l,a6                  ; OS-Header
        move.w  os_palmode(a6),d0               ; os_conf
        lsr.w   #1,d0
        move.w  d0,d4                           ; nationality

        lea     titel(pc),a0
        bsr     cconws_country

        cmpi.l  #'Miln',$0038(a6)               ; Miln
        bne     NeuesMilanROMnoetig
        move.l  $003C(a6),MilanTOS_einsprung

* auf Shift-Shift pruefen

        move.w  #-1,-(a7)
        bios    Kbshift
        addq.l  #4,a7
        andi.b  #$03,d0
        subq.b  #3,d0                           ; Shift preset?
        bne.s   do_install
        lea     dont_install(pc),a0
        bsr     cconws_country
        lea     press_key(pc),a0
        bsr     cconws_country
        gemdos  Cconin
        gemdos  Pterm0

* Tatsaechlich installieren
* Ermitteln der Dateidaten

do_install:
        clr.w   -(a7)                           ; search Magic.ram
        pea     magx_name(pc)
        gemdos   Fsfirst
        addq.l  #8,a7
        tst.l   d0
        bmi     err

        gemdos  Fgetdta
        addq.l  #2,a7
        movea.l d0,a0
        move.l  $001A(a0),d6                    ; d6 = Dateilaenge

* Oeffnen der Datei: Handle d7

        clr.w   -(a7)                           ; open file
        pea     magx_name(pc)
        gemdos  Fopen
        addq.l  #8,a7
        move.w  d0,d7
        bmi     err

* Einlesen der gesamten Datei

        move.l  d6,-(a7)
        gemdos  Malloc
        addq.l  #6,a7
        tst.l   d0
        ble     err
        movea.l d0,a6                           ; memory
        pea     (a6)                            ; read file to memory
        move.l  d6,-(a7)                        ; count
        move.w  d7,-(a7)                        ; handle
        gemdos  Fread
        adda.w  #$000C,a7
        move.l  d0,-(a7)
        move.w  d7,-(a7)
        gemdos  Fclose
        addq.w  #4,a7
        cmp.l   (a7)+,d6                        ; all data reads?
        bne     err                             ; No
        tst.l   d0
        bmi     err
        cmpi.w  #$601A,(a6)                     ; Test ob normales Programm, ja dann Ende
        bne     err

* pruefen, ob MagiX, und a5 auf Ladeadresse

        movea.l $0030(a6),a0
        lea     $1C(a6,a0.l),a0
        cmpi.l  #$87654321,(a0)+
        bne     err
        movea.l (a0)+,a5
        addq.l  #4,a0
        cmpi.l  #'MAGX',(a0)                    ; MAGX
        bne     err

        movea.l MilanTOS_einsprung,a5
        movea.l $0004(a5),a5                    ; BIOS Tabelle
        movea.l $0002(a5),a5                    ; Getmpb
        gemdos  Dgetdrv
        addq.l  #2,a7
;buf+1c ist das Programm ohne den Programmheader
;bei Offset 0x14 steht der Zeiger auf die AES-Variablen
        movea.l $0030(a6),a0
        lea     $1C(a6,a0.l),a0
        lea     $7A(a0),a0
        cmpi.l  #'____',(a0)                    ; Sicherheitsfrage fuer alten Kernel
        bne.s   do_reloc
        addi.b  #"A",d0                         ; Pfad + Dateinamen zusammensetzen
        move.b  d0,(a0)+
        move.b  #":",(a0)+
        lea     magx_name(pc),a1
namecpy_loop:
        move.b  (a1)+,(a0)+
        bne.s   namecpy_loop

* MagiX relozieren

do_reloc:
        move.l  $0002(a6),d0                    ; Laenge von TEXT
        add.l   $0006(a6),d0                    ; Laenge von DATA
        move.l  d0,d5                           ; tatsaechliche Laenge von MagiX
        add.l   $000E(a6),d0                    ; Laenge von SYM

        lea     $1C(a6,d0.l),a3                 ; Beginn der Relocation- Daten
        lea     $00(a6,d6.l),a2                 ; Dateiende
        cmpa.l  a2,a3
        bcc.s   end_reloc
        lea     $001C(a6),a0
        move.l  (a3)+,d0                        ; erstes Relocation- Langwort
reloc_loop:
        adda.l  d0,a0
        move.l  a5,d0
        add.l   d0,(a0)                         ; relozieren!
reloc_loop2:
        cmpa.l  a2,a3
        bhi.s   end_reloc                       ; Dateiende!
        moveq   #$00,d0
        move.b  (a3)+,d0
        beq.s   end_reloc                       ; Ende der Tabelle
        cmpi.b  #$01,d0
        bne.s   reloc_loop
        lea     $00FE(a0),a0
        bra.s   reloc_loop2

end_reloc:
* Checksumme ermitteln
        lea     $001C(a6),a0
        lea     $00(a0,d5.l),a1
        moveq   #$00,d0
os_chkloop:
        add.l   (a0)+,d0
        cmpa.l  a0,a1
        bcs.s   os_chkloop
        move.l  d0,os_chksum

        clr.w   -(a7)                           ; ausschalten
        move.w  #$0005,-(a7)                    ; Datencaches
        move.w  #$00A0,-(a7)                    ; CacheCtrl
        trap    #14
        addq.l  #6,a7
        clr.w   -(a7)                           ; ausschalten
        move.w  #$0007,-(a7)                    ; Befehlcaches
        move.w  #$00A0,-(a7)                    ; CacheCtrl
        trap    #14
        addq.l  #6,a7
        ori     #$0700,sr
        lea     toscopy(pc),a1                  ; aktuelle Adresse der Startroutine
        lea     $0600  ,a0                      ; neue Adresse der Startroutine
        move.w  #$0016,d0
startcopy:
        move.l  (a1)+,(a0)+
        dbf     d0,startcopy
        jmp     $0600

toscopy:
        movea.l a5,a0
        lea     $001C(a6),a1
        move.l  d5,d0                           ; Laenge
        lsr.l   #3,d0                           ; /8
        cmpa.l  a0,a1
        bhi.s   cpy_uloop
        beq.s   cpy_end
        adda.l  d5,a1
        adda.l  d5,a0
cpy_dloop:
        move.l  -(a1),-(a0)
        move.l  -(a1),-(a0)
        dbf     d0,cpy_dloop                    ; sicherheitshalber einen mehr kopieren
        bra.s   cpy_end

cpy_uloop:
        move.l  (a1)+,(a0)+
        move.l  (a1)+,(a0)+
        dbf     d0,cpy_uloop
cpy_end:
        move.l  #$5555AAAA,memval3
        cmpa.l  #$01000000,a5
        bne.s   cpy_st
        add.l   d5,fstrm_beg
        bra.s   startit

cpy_st:
        add.l   d5,$000C(a5)
        movea.l $0014(a5),a0
        cmpi.l  #$87654321,(a0)+
        bne.s   startit
        add.l   d5,(a0)
startit:
        clr.l   _hz_200
        jmp     (a5)

NeuesMilanROMnoetig:
        lea     Text_Neue_Version_noetig(pc),a0
        bsr.s   cconws_country

err:
 gemdos   Pterm0

**********************************************************************
*
* void cconws_country(a0 = char *s)
*
* d4: country code
* a0: ptr to countries & strings, as below:
* char n1,n2,...,-1      countries for 1st string
* char s1[]              1st string
* char n3,n4,...,-1      countries for 2nd string
* char s2[]              2nd string
* char -1                terminator
* char defs[]            default string (usually english)
*
**********************************************************************

cconws_country:
        bsr.s   _chk_nat
        bne.s   cconws_country
        move.l  a0,-(a7)
        move.w  #$0009,-(a7)                    ; Cconws
        trap    #1
        addq.l  #6,a7
        rts

_chk_nat:
        move.b  (a0)+,d0
        bmi.s   _chk_ende                       ; Abschlussbyte, Default verwenden
_chk_nxt:
        cmp.b   d0,d4                           ; unsere Nationalitaet ?
        beq.s   _chk_found
        move.b  (a0)+,d0                        ; naechste Nationalitaet
        bge.s   _chk_nxt                        ; weiter vergleichen
_chk_nxtstr:
        tst.b   (a0)+                           ; Zeichenkette ueberspringen
        bne.s   _chk_nxtstr
        moveq   #$01,d0                         ; nicht gefunden
        rts

_chk_found:
        tst.b   (a0)+
        bge.s   _chk_found
_chk_ende:
        moveq   #$00,d0                         ; gefunden, a0 ausdrucken
        rts

MilanTOS_einsprung:
        dc.l    $00000000
machine:
        dc.l    $00000000
titel:
        DC.B     -1
        DC.B     CR,LF,'MagiCMilan- BOOTER, ',$bd,' 1990-99 Andreas Kromke',CR,LF,0

Text_Neue_Version_noetig:
        dc.b    $01,$08,$FF,'Neuere Version des Milan-ROMs besorgen!',$0D,$0A
        dc.b    $00,$02,$FF,'Le Milan ROM est tout vieux!',$0D
        dc.b    $0A,$00,$FF,'Get newer version of Milan ROM!',$0D,$0A
        dc.b    $00

dont_install:
        DC.B    COUNTRY_DE,COUNTRY_SG,-1
        DC.B    'Shift-Shift: MagiC nicht installiert',CR,LF,0
        DC.B    COUNTRY_FR,COUNTRY_SF,-1
        DC.B    'Shift-Shift: MagiC pas install',$82,'',CR,LF,0
        DC.B    -1
        DC.B    'Shift-Shift: MagiC not installed',CR,LF,0

press_key:
        DC.B    COUNTRY_DE,COUNTRY_SG,-1
        DC.B    LF,'Taste dr',$81,'cken!',CR,LF,0
        DC.B    COUNTRY_FR,COUNTRY_SF,-1
        DC.B    LF,'Appuyez sur une touche!',CR,LF,0
        DC.B    -1
        DC.B    LF,'Press any key!',CR,LF,0

magx_name:
        DC.B    '\magic.ram',0
        DCB.B   10,0

        EVEN

        BSS

        DS.B    800
stack:
        end
