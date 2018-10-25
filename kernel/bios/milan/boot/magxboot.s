**********************************************************************
*
* BOOTLADER FUeR MagiC-Milan
* =========================
*
*                             erstellt            5.2.99
*                             letzte Aenderung     26.3.99
*
* Liest die Datei MMILAN.RAM, reloziert und verschiebt sie an
* den Beginn des freien ST-RAMs, d.h. hinter die Variablen des
* Milan-TOS.
* Startet das Betriebssystem.
* Alle Meldungen erfolgen je nach System in Deutsch oder Englisch.
* Achtung: Die Flags "FLA" der PRG- Datei muessen gesetzt sein!!!
*
**********************************************************************

OUTSIDE   EQU  0              ; Programmlaenge auf 32k-Pages
RESIDENT  EQU  0              ; resetfest

fstrm_beg EQU  $49e           ; ___md
os_chksum EQU  $486           ; trp14ret


     INCLUDE "osbind.inc"
     INCLUDE "milan.inc"

     TEXT
     SUPER

 movea.l  4(sp),a1
 lea      stack(pc),sp
 movea.w  #$100,a0                 ; Programmlaenge + $100
 adda.l   $c(a1),a0
 adda.l   $14(a1),a0
 adda.l   $1c(a1),a0
 move.l   a0,-(sp)
 move.l   a1,-(sp)
 clr.w    -(sp)
 gemdos   Mshrink
 adda.w   #$c,sp
 tst.l    d0                       ; KAOS liefert Fehlermeldung bei Mshrink()
 bmi      err

* Nationalitaet bestimmen und Titelzeile ausgeben

 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp

 move.l   _p_cookies,d0
 beq.b    is_st
 move.l   d0,a0
cookie_loop:
 move.l   (a0),d0                  ; Kennung
 beq.b    is_st                    ; Ende-Kennung
 addq.l   #8,a0
 cmpi.l   #'_MCH',d0
 beq.b    cookie_mch
 cmpi.l   #'MagX',d0
 beq      err                      ; MagiX schon aktiv
 bra.b    cookie_loop
cookie_mch:
 move.l   -4(a0),machine
 bra.b    cookie_loop
is_st:

* Nationalitaet und Milan-Uebergabestruktur bestimmen

 lea      MILAN_ROM,a6

 move.w   os_palmode(a6),d0
 lsr.w    #1,d0
 move.w   d0,d4                    ; nationality

 lea      titel(pc),a0
 bsr      cconws_country

 cmpi.l   #'Miln',osh_milan_magic(a6)
 bne      err_oldrom               ; altes ROM
 move.l   osh_milan_os(a6),milan   ; Zeiger merken

* auf Shift-Shift pruefen

 move.w   #-1,-(sp)
 bios     Kbshift
 addq.l   #4,sp
 andi.b   #3,d0
 subq.b   #3,d0
 bne.b    do_install
 lea      dont_install(pc),a0
err2:
 bsr      cconws_country
 lea      press_key(pc),a0
 bsr      cconws_country
 gemdos   Cconin
 gemdos   Pterm0

* Tatsaechlich installieren

do_install:

* Ermitteln der Dateidaten

 clr.w    -(sp)
 pea      name(pc)
 gemdos   Fsfirst
 addq.l   #8,sp
 tst.l    d0
 bmi      err

 gemdos   Fgetdta
 addq.l   #2,sp
 move.l   d0,a0
 move.l   $1a(a0),d6               ; d6 = Dateilaenge

* Oeffnen der Datei: Handle d7

 clr.w    -(sp)
 pea      name(pc)
 gemdos   Fopen
 addq.l   #8,sp
 move.w   d0,d7
 bmi      err

* Einlesen der gesamten Datei

 move.l   d6,-(sp)
 gemdos   Malloc
 addq.l   #6,sp
 tst.l    d0
 ble      err
 move.l   d0,a6
 pea      (a6)
 move.l   d6,-(sp)
 move.w   d7,-(sp)
 gemdos   Fread
 adda.w   #12,sp
 move.l   d0,-(sp)
 move.w   d7,-(sp)
 gemdos   Fclose
 addq.w   #4,sp
 cmp.l    (sp)+,d6
 bne      err
 tst.l    d0
 bmi      err
 cmpi.w   #$601a,(a6)
 bne      err

* pruefen, ob MagiX, und a5 auf Ladeadresse
* _memtop bleibt unveraendert

 move.l   $1c+os_magic(a6),a0
 lea      $1c(a6,a0.l),a0
 cmpi.l   #$87654321,(a0)+
 bne      err
 move.l   (a0)+,a5                 ; Ende der Variablen
 addq.l   #4,a0                    ; aes_start ueberspringen
 cmpi.l   #'MAGX',(a0)
 bne      err
 move.l   milan,a5
 move.l   milh_meminfo(a5),a5
 move.l   2(a5),a5                 ; adr

* MagiX modifizieren (Bootlaufwerk)

do_modify:
 gemdos   Dgetdrv
 addq.l   #2,sp
;buf+1c ist das Programm ohne den Programmheader
;bei Offset 0x14 steht der Zeiger auf die AES-Variablen
 move.l   ($14+$1c)(a6),a0
 lea      $1c(a6,a0.l),a0
 lea      $7a(a0),a0
 cmpi.l   #'____',(a0)             ; Sicherheitsfrage fuer alten Kernel
 bne.b    do_reloc
 addi.b   #'A',d0
 move.b   d0,(a0)+
 move.b   #':',(a0)+
 lea      name(pc),a1
namecpy_loop:
 move.b   (a1)+,(a0)+
 bne.b    namecpy_loop

* MagiX relozieren

do_reloc:
 move.l   2(a6),d0                 ; Laenge von TEXT
 add.l    6(a6),d0                 ; Laenge von DATA
 move.l   d0,d5                    ; tatsaechliche Laenge von MagiX
 add.l    $e(a6),d0                ; Laenge von SYM

 lea      $1c(a6,d0.l),a3          ; Beginn der Relocation- Daten
 lea      0(a6,d6.l),a2            ; Dateiende
 cmpa.l   a2,a3
 bcc.b    end_reloc
 lea      $1c(a6),a0
 move.l   (a3)+,d0                 ; erstes Relocation- Langwort
reloc_loop:
 add.l    d0,a0
 move.l   a5,d0
 add.l    d0,(a0)                  ; relozieren!
reloc_loop2:
 cmpa.l   a2,a3
 bhi.b    end_reloc                ; Dateiende!
 moveq    #0,d0
 move.b   (a3)+,d0
 beq.b    end_reloc                ; Ende der Tabelle
 cmpi.b   #1,d0
 bne.b    reloc_loop
 lea      254(a0),a0
 bra.b    reloc_loop2

end_reloc:

*
* Checksumme ermitteln
*

 lea      $1c(a6),a0
 lea      0(a0,d5.l),a1
 moveq    #0,d0
os_chkloop:
 add.l    (a0)+,d0
 cmpa.l   a0,a1
 bcs.b    os_chkloop
 move.l   d0,os_chksum

*
* CPU-Cache abschalten und MagiC starten
*

 clr.w    -(sp)                    ; disable
 move.w   #5,-(sp)                 ; set data cache mode
 move.w   #160,-(sp)               ; Xbios CachCtrl
 trap     #14
 addq.l   #6,sp

 clr.w    -(sp)                    ; disable
 move.w   #7,-(sp)                 ; set instruction cache mode
 move.w   #160,-(sp)               ; Xbios CachCtrl
 trap     #14
 addq.l   #6,sp

 ori.w    #$700,sr
;move.l   d3,$88                   ; Zeichensatzadresse fuer MAGIXVDI
 lea      toscopy(pc),a1           ; aktuelle Adresse der Startroutine
 lea      $600,a0                  ; neue Adresse der Startroutine
 move.w   #(err-toscopy)/4,d0
startcopy:
 move.l   (a1)+,(a0)+
 dbra     d0,startcopy
 jmp      $600                     ; Startroutine anspringen

toscopy:
 move.l   a5,a0
 lea      $1c(a6),a1
 move.l   d5,d0                    ; Laenge
 lsr.l    #3,d0                    ; /8
 cmpa.l   a0,a1
 bhi      cpy_uloop
 beq      cpy_end
 adda.l   d5,a1
 adda.l   d5,a0
cpy_dloop:
 move.l   -(a1),-(a0)
 move.l   -(a1),-(a0)
 dbra     d0,cpy_dloop             ; sicherheitshalber einen mehr kopieren
 bra      cpy_end
cpy_uloop:
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 dbra     d0,cpy_uloop

cpy_end:
 move.l   #$5555aaaa,$51a
     IFNE RESIDENT
 move.l   #$31415926,resvalid
 move.l   a5,resvector
     ENDIF
 cmpa.l   #$1000000,a5
 bne.b    cpy_st
 add.l    d5,fstrm_beg
     IFNE OUTSIDE
* Beginn des FastRAM hinter Mag!X auf 32k-Grenze
 move.l   fstrm_beg,d0
 add.l    #$00007fff,d0            ; 32k-1 addieren
 andi.w   #$8000,d0                ; auf volle 32k gehen
 move.l   d0,fstrm_beg
     ENDIF
 bra.b    startit
cpy_st:
 add.l    d5,os_membot(a5)         ; OS- Laenge auf TPA- Beginn addieren
     IFNE OUTSIDE
* Beginn des ST-RAM hinter Mag!X auf 32k-Grenze
 move.l   os_membot(a5),d0
 add.l    #$00007fff,d0            ; 32k-1 addieren
 andi.w   #$8000,d0                ; auf volle 32k gehen
 move.l   d0,os_membot(a5)
     ENDIF
 move.l   os_magic(a5),a0
 cmpi.l   #$87654321,(a0)+
 bne.b    startit
 add.l    d5,(a0)
     IFNE OUTSIDE
* Beginn des ST-RAM hinter Mag!X-AES auf 32k-Grenze
 move.l   (a0),d0
 add.l    #$00007fff,d0            ; 32k-1 addieren
 andi.w   #$8000,d0                ; auf volle 32k gehen
 move.l   d0,(a0)
     ENDIF
startit:
 clr.l    _hz_200                  ; Zeitpunkt des Kaltstarts festlegen
 jmp      (a5)                     ; MagiX starten


err_oldrom:
 lea      old_rom(pc),a0
 bsr      cconws_country
err:
 gemdos   Pterm0


**********************************************************************
*
* void cconws_country(a0 = char *s)
*
* in d4 steht die Nationalitaet
* Aufbau der Zeichenkette, auf die a0 zeigt:
* char n1,n2,...,-1      Nationalitaeten fuer erste Zeichenkette
* char s1[]              erste Zeichenkette
* char n3,n4,...,-1      Nationalitaeten fuer zweite Zeichenkette
* char s2[]              zweite Zeichenkette
* char -1                Abschluss
* char defs[]            Defaultstring (i.a. englisch)
*
**********************************************************************

cconws_country:
 bsr      _chk_nat
 bne.b    cconws_country
cconws:
 move.l   a0,-(sp)
 gemdos   Cconws
 addq.l   #6,sp
 rts

_chk_nat:
 move.b   (a0)+,d0
 bmi.b    _chk_ende                ; Abschlussbyte, Default verwenden
_chk_nxt:
 cmp.b    d0,d4                    ; unsere Nationalitaet ?
 beq.b    _chk_found
 move.b   (a0)+,d0                 ; naechste Nationalitaet
 bge.b    _chk_nxt                 ; weiter vergleichen
_chk_nxtstr:
 tst.b    (a0)+                    ; Zeichenkette ueberspringen
 bne.b    _chk_nxtstr
 moveq    #1,d0                    ; nicht gefunden
 rts
_chk_found:
 tst.b    (a0)+
 bge.b    _chk_found
_chk_ende:
 moveq    #0,d0                    ; gefunden, a0 ausdrucken
 rts

milan:
 DC.L     0
machine:
 DC.L     0
titel:
 DC.B     -1
     IFNE OUTSIDE
 DC.B     CR,LF,'MagiCMilan- BOOTER, ',$bd,' 1990-99 Andreas Kromke'
 DC.B     CR,LF,'Virtual Memory Version',CR,LF,0
     ELSE
 DC.B     CR,LF,'MagiCMilan- BOOTER, ',$bd,' 1990-99 Andreas Kromke',CR,LF,0
     ENDIF

old_rom:
 DC.B     COUNTRY_DE,COUNTRY_SG,-1
 DC.B     'Neuere Version des Milan-ROMs besorgen!',CR,LF,0
 DC.B     COUNTRY_FR,COUNTRY_SF,-1
 DC.B     'Le Milan ROM est tout vieux!',CR,LF,0
 DC.B     -1
 DC.B     'Get newer version of Milan ROM!',CR,LF,0

dont_install:
 DC.B     COUNTRY_DE,COUNTRY_SG,-1
 DC.B     'Shift-Shift: MagiC nicht installiert',CR,LF,0
 DC.B     COUNTRY_FR,COUNTRY_SF,-1
 DC.B     'Shift-Shift: MagiC pas install',$82,'',CR,LF,0
 DC.B     -1
 DC.B     'Shift-Shift: MagiC not installed',CR,LF,0

press_key:
 DC.B     COUNTRY_DE,COUNTRY_SG,-1
 DC.B     LF,'Taste dr',$81,'cken!',CR,LF,0
 DC.B     COUNTRY_FR,COUNTRY_SF,-1
 DC.B     LF,'Appuyez sur une touche!',CR,LF,0
 DC.B     -1
 DC.B     LF,'Press any key!',CR,LF,0

name:
 DC.B     '\magic.ram',0
 DCB.B    10,0

     EVEN

stack     EQU  *+800

     BSS

 DS.B     800

     END
