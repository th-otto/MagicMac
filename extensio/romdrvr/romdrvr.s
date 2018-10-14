**********************************************************************
*
* DOS- Treiber fÅr das Rommodul                   16.07.90
* =============================
*
*                             letzte énderung     18.07.90
*                             Fsnext korrigiert   22.06.93
*
* installiert fÅr das Rommodul:
*
* Fsfirst("R:dateiname")
* Fsfirst("R:*.*")
* Fattrib("R:...");
* Fopen  ("R:...");
* Fsnext()
* Dsetpath()
* Dgetpath()
* Pexec(0, ...)
* Dfree()
* Dcreate()
* Ddelete()
* Fcreate()
* Fdelete()
* Frename()
*
* lÑuft sowieso:
*
* Dgetdrv()
* Dsetdrv()
*
**********************************************************************


MODULBASE   EQU  $fa0000


     INCLUDE "osbind.inc"

     TEXT
     SUPER

_base     EQU  *-$100              ; Adresse der Basepage

 bra      main

xbra:
 DC.B     'XBRA'                   ; Magische Zahlen
 DC.B     'ROMD'                   ; Programm-ID : ROM-Driver
 DS.L     1                        ; Platz fÅr alten Vektor

 move     usp,a0
 btst     #5,(sp)
 beq.b    teste                    ; komme aus dem Usermodus
 lea      6(sp),a0                 ; Stackoffset fÅr 68000
 tst.w    $59e                     ; ist 68000 ?
 beq.b    teste                    ; ja, ok
 addq.l   #2,a0                    ; 680x0, Vektoroffset Åberspringen
teste:
 move.w   (a0)+,d0                 ; DOS- Funktionsopcode
 cmpi.w   #Fsfirst,d0
 beq      rom_fsfirst
 cmpi.w   #Fattrib,d0
 beq      rom_fattrib
 cmpi.w   #Fopen,d0
 beq      rom_fopen
 cmpi.w   #Fsnext,d0
 beq      rom_fsnext
 cmpi.w   #Dfree,d0
 beq      rom_dfree
 cmpi.w   #Dgetpath,d0
 beq      rom_dgetpath
 cmpi.w   #Dsetpath,d0
 beq      rom_dsetpath
 cmpi.w   #Pexec,d0
 beq      rom_pexec
 cmpi.w   #Dcreate,d0
 beq      rom_dcreate
 cmpi.w   #Ddelete,d0
 beq      rom_ddelete
 cmpi.w   #Fcreate,d0
 beq      rom_fcreate
 cmpi.w   #Fdelete,d0
 beq      rom_fdelete
 cmpi.w   #Frename,d0
 beq      rom_frename
original:
 move.l   xbra+8(pc),a0
 jmp      (a0)
original_a1:
 move.l   (sp)+,a1
 bra.b    original


* Sucht eine Datei mit Muster <a1>, gibt Zeiger auf ROM- Header in d0
* zurÅck. Wenn nicht auf Laufwerk R: gesucht wird, RÅckgabe 0L
* Ñndert weder a0 noch a2

_fsfirst:
 move.l   a2,-(sp)
 cmpi.b   #':',1(a1)
 beq.b    _fs_nostd
 move.l   p_act_pd(pc),a2
 move.l   (a2),a2
 cmpi.b   #17,p_defdrv(a2)
 bne      _fs_norom
 bra.b    _fs_rom
_fs_nostd:
 move.b   (a1)+,d0
 andi.b   #$5f,d0
 cmpi.b   #'R',d0
 bne      _fs_norom
 addq.l   #1,a1                    ; ':' Åberlesen
* Hier ist ein evtl. Vorspann "R:" eingelesen
_fs_rom:
 cmpi.b   #'.',(a1)
 bne.b    _fs_nopt
 cmpi.b   #'\',1(a1)
 bne.b    _fs_nob
 addq.l   #1,a1
_fs_nopt:
 cmpi.b   #'\',(a1)
 bne.b    _fs_nob
 addq.l   #1,a1
* Hier ist ein weiterer Vorspann ".\" oder "\" eingelesen
_fs_nob:
 lea      $fa0000,a2
 cmpi.l   #$abcdef42,(a2)+
 bne      _fs_efilnf               ; kein ROM
 cmpi.b   #'*',(a1)
 bne.b    _fs_nxtpgm
 cmpi.b   #'.',1(a1)
 bne.b    _fs_nxtpgm
 cmpi.b   #'*',2(a1)
 bne.b    _fs_nxtpgm
 tst.b    3(a1)
 beq      _fs_found                ; war "*.*"
_fs_nxtpgm:
 move.l   a2,d0
 beq      _fs_efilnf
 move.l   a1,-(sp)
 move.l   a2,-(sp)
 lea      $14(a2),a2               ; a2 auf Programmname
_fs_cmploop:
 move.b   (a1)+,d0
 beq.b    _fs_endcmp
 cmpi.b   #'a',d0
 bcs.b    _fs_noup
 cmpi.b   #'z',d0
 bhi.b    _fs_noup
 andi.b   #$5f,d0
_fs_noup:
 cmp.b    (a2)+,d0
 beq.b    _fs_cmploop
_fs_srch:
 move.l   (sp)+,a2
 move.l   (sp)+,a1
 move.l   (a2),a2
 bra.b    _fs_nxtpgm
_fs_endcmp:
 tst.b    (a2)
 bne.b    _fs_srch
 move.l   (sp)+,a2
 move.l   (sp)+,a1
_fs_found:
 move.l   a2,d0
 bra.b    _fs_ende
_fs_efilnf:
 moveq    #EFILNF,d0
 bra.b    _fs_ende
_fs_norom:
 moveq    #0,d0
_fs_ende:
 move.l   (sp)+,a2
 rts


rom_frename:
 addq.l   #2,a0                    ; Dummyparameter Åberlesen
rom_ddelete:
rom_fdelete:
 move.l   a1,-(sp)
 move.l   (a0)+,a1
 bsr      _fsfirst
 beq      original_a1              ; nicht angesprochen
 bmi      return                   ; nicht gefunden
ewrpro:
 moveq    #EWRPRO,d0               ; Schreibfehler
 bra      return


rom_dcreate:
rom_fcreate:
 move.l   a1,-(sp)
 move.l   (a0)+,a1                 ; Pfadmuster
 bsr      _fsfirst
 beq      original_a1              ; wir sind nicht angesprochen
 bra.b    ewrpro                   ; Schreibfehler


rom_fopen:
rom_fattrib:
 move.l   a1,-(sp)
 move.l   (a0)+,a1                 ; Pfadmuster
 bsr      _fsfirst
 beq      original_a1              ; wir sind nicht angesprochen
 bmi      return
 tst.w    (a0)                     ; zu schreiben => EWRPROT
 bne.b    ewrpro
 moveq    #1,d0
 cmpi.w   #Fattrib,-6(a0)
 beq      return                   ; Attribut lesen => 1
 move.l   #$0000fffc,d0
 bra      return                   ; Datei zum Lesen îffnen => nul


rom_fsfirst:
 move.l   a1,-(sp)
 move.l   (a0)+,a1                 ; Pfadmuster
 bsr      _fsfirst
 beq      original_a1              ; wir sind nicht angesprochen
 cmpi.b   #8,1(a0)                 ; Attribut 8 (Disknamen ermitteln)
 bne.b    _fs_no_dname
 moveq    #0,d0
 bra.b    _fs_both
_fs_no_dname:
 tst.l    d0
 bmi      return
 move.l   d0,a1
_fs_both:
 move.l   p_act_pd(pc),a0
 move.l   (a0),a0
 move.l   p_dta(a0),a0             ; a0 auf aktuelle DTA
 move.l   #$21071965,(a0)+         ; magic in die DTA
 tst.l    d0
 bne.b    _fsnext
* Disknamen ermitteln
 clr.l    (a0)+                    ; kein nÑchster Programheader
 clr.l    (a0)+
 clr.l    (a0)+
 clr.l    (a0)+
 move.w   #8,(a0)+                 ; Volume
 clr.l    (a0)+                    ; Datum und Zeit sind 0
 clr.l    (a0)+                    ; DateilÑnge ist 0
 move.l   #'ROMM',(a0)+
 move.l   #'ODUL',(a0)+
 clr.b    (a0)
 bra.b    e_ok

_fsnext:
 move.l   (a1)+,(a0)+              ; nÑchster Programmheader
 addq.l   #8,a1                    ; init und run Åberspringen
 clr.l    (a0)+
 clr.l    (a0)+
 clr.l    (a0)+
 move.w   #1,(a0)+                 ; ReadOnly
 move.l   (a1)+,(a0)+              ; Datum und Zeit
 move.l   (a1)+,(a0)+              ; ProgrammlÑnge
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 move.w   (a1),(a0)                ; Name (14 Bytes)
e_ok:
 moveq    #0,d0
return:
 move.l   (sp)+,a1
 rte
efilnf:
 move.l   (sp)+,a1
 moveq    #EFILNF,d0
 rte

rom_fsnext:
 move.l   a1,-(sp)
 move.l   p_act_pd(pc),a0
 move.l   (a0),a0
 move.l   $20(a0),a0               ; a0 auf aktuelle DTA
 cmpi.l   #$21071965,(a0)+         ; magic in der DTA ?
 bne      original_a1
 moveq    #ENMFIL,d0
 tst.l    (a0)
 beq.b    return                   ; keine weiteren Dateien
 move.l   (a0),a1
 bra.b    _fsnext


rom_dfree:
rom_dgetpath:
 move.l   a1,-(sp)
 move.l   (a0)+,a1
 cmpi.w   #'R'-'A'+1,(a0)
 beq.b    _dfg_doit
 tst.w    (a0)
 bne      original_a1
 move.l   p_act_pd(pc),a0
 move.l   (a0),a0
 cmpi.b   #17,p_defdrv(a0)
 bne      original_a1
_dfg_doit:
 cmpi.w   #Dfree,d0
 beq      _dfg_dfree
* Dgetpath
 move.b   #'\',(a1)+
 clr.b    (a1)
 bra      e_ok
* Dfree
_dfg_dfree:
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 clr.l    (a1)+
 bra      e_ok


rom_dsetdrv:
 cmpi.w   #'R'-'A',(a0)
 bne      original
 moveq    #EDRIVE,d0
 rte


rom_dsetpath:
 move.l   a1,-(sp)
 move.l   (a0)+,a1                 ; Pfad
 move.b   (a1)+,d0
 cmpi.b   #':',(a1)
 beq.b    _ds_nostd
 move.l   p_act_pd(pc),a2
 move.l   (a2),a2
 cmpi.b   #17,p_defdrv(a2)
 bne      original_a1
 bra.b    _ds_rom
_ds_nostd:
 andi.b   #$5f,d0
 cmpi.b   #'R',d0
 bne      original_a1
 addq.l   #1,a1                    ; ':' Åberlesen
_ds_rom:
 cmpi.b   #'\',(a1)
 bne.b    _ds_nob
 addq.l   #1,a1
_ds_nob:
 moveq    #EPTHNF,d0
 tst.b    (a1)
 bne      return
 bra      e_ok


rom_pexec:
 tst.w    (a0)
 bne      original                 ; nicht Modus 0
 move.l   a1,-(sp)
 move.l   2(a0),a1                 ; Pfad
 bsr      _fsfirst
 beq      original_a1              ; wir sind nicht angesprochen
 bmi      return                   ; nicht gefunden
* a2 zeigt auf den Programmheader
 move.l   d0,-(sp)                 ; Programmheader merken
 move.l   a0,-(sp)                 ; a0 merken
 move.l   10(a0),-(sp)             ; env
 move.l   6(a0),-(sp)              ; cmdline
 move.l   2(a0),-(sp)              ; path
 move.w   #5,-(sp)                 ; Basepage erstellen
 gemdos   Pexec
 adda.w   #16,sp
 move.l   (sp)+,a0
 move.l   (sp)+,a1
 tst.l    d0
 bmi      return
 move.l   d0,6(a0)                 ; Basepage statt cmdline
 move.w   #6,(a0)                  ; Exec+Free
 move.l   d0,a0
 move.l   8(a1),8(a0)              ; Textsegmentadresse eintragen
 bra      original_a1

p_act_pd:
 DC.L     os10_run


**********************************************************************
************************ Installationsteil ***************************
**********************************************************************

main:
 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp
 move.l   _sysbase,a0
 cmpi.w   #$0102,os_version(a0)
 bcs.b    tos10
 lea      p_act_pd(pc),a1
 move.l   os_run(a0),(a1)
tos10:
 move.l   $84,a0
 lea      -12(a0),a0
 lea      xbra(pc),a1
 cmp.l    (a0)+,(a1)+
 bne.b    install
 cmp.l    (a0)+,(a1)+
 bne.b    install
wrongtos:
 move.w   #-1,-(sp)
 gemdos   Pterm                    ; schon installiert oder falsches TOS

install:
 pea      titel(pc)
 gemdos   Cconws
 addq.l   #6,sp
 bset     #1,_drvbits+1            ; Laufwerk R: anmelden
 lea      xbra+8(pc),a1
 move.l   $84,(a1)+
 move.l   a1,$84

 lea      _base(pc),a0             ; Beginn des residenten Teils
 lea      main(pc),a1              ; Ende des residenten Teils
 suba.l   a0,a1                    ; Abziehen vom Ende desselbigen
 clr.w    -(sp)                    ; kein Fehler
 move.l   a1,-(sp)
 gemdos   Ptermres                 ; festkrallen


titel:
 DC.B     'Mag!X Rommodul- Treiber V1.01, Ω 1990-93 Andreas Kromke',$d,$a,0

     END

