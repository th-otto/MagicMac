**********************************************************************
*
* DOS_MON (Zeigt DOS- Aufrufe genau an)
*
* erstellt 19.6.93
* letzte Žnderung
*
**********************************************************************

     INCLUDE "osbind.inc"

	 XDEF main

     TEXT
     SUPER

_base     EQU    *-$100

 bra      main


**********************************************************************
*
* der neue Trap #1
*

xbra1:
 DC.B     'XBRA'                   ; Magische Zahlen
 DC.B     'DSMN'                   ; Programm-ID : Shell- Manager
 DS.L     1                        ; Platz fr alten Vektor

neu_trap1:
 move.l   usp,a0
 btst     #5,(sp)
 beq      cpu_00                   ; aus Usermode
 lea      6(sp),a0                 ; fr 68000
 tst.w    cpu_typ
 beq.b    cpu_00
 addq.l   #2,a0                    ; fr 68010 usw.
cpu_00:
 cmpi.l   #'dsmn',16(a0)
 beq      to_old1
 movem.l  a5/a6/d7/d6/a1/a2/d1/d2,-(sp)
 move.l   a0,-(sp)
 lea      dos_tab(pc),a5
 move.l   a0,a6
 move.w   (a6)+,d0
 cmp.w    (a5)+,d0
 bhi      tr_err
 mulu     #x2-x1,d0
 add.l    d0,a5
 lea      crlf(pc),a0
 bsr      prtstr
 move.l   a5,a0
 bsr      prtstr
 lea      9(a5),a5
 moveq    #4-1,d7                  ; max. 4 Parameter
tr_par_loop:
 move.b   4(a5),d6                 ; Parameterl„nge
 ext.w    d6
 beq.b    tr_par_end               ; kein Parameter mehr
 lea      space(pc),a0
 bsr      prtstr
 move.l   a5,a0
 bsr      prtstr                   ; Parametername
 lea      gleich(pc),a0
 bsr      prtstr
 subq.w   #1,d6
tr_par_loop2:
 move.b   (a6)+,d0
 move.b   d0,-(sp)
 lsr.b    #4,d0
 bsr      _hex
 move.b   (sp)+,d0
 bsr      _hex
 dbra     d6,tr_par_loop2
 addq.l   #5,a5                    ; n„chster Parameter
 dbra     d7,tr_par_loop
tr_par_end:
 bsr      wait

 move.l   (sp)+,a0                 ; Parameterliste
 cmpi.w   #Super,(a0)
 bne.b    tr_weiter                ; Super nicht abfangen!
 bra      tr_err

tr_weiter:
; Parameter umkopieren
 lea      12(a0),a0
 move.l   #'dsmn',-(sp)
 move.l   (a0),-(sp)
 move.l   -(a0),-(sp)
 move.l   -(a0),-(sp)
 move.l   -(a0),-(sp)
 trap     #1
 lea      20(sp),sp
 move.l   d0,-(sp)
 lea      gibt(pc),a0
 bsr      prtstr
 move.l   (sp),d0
 bsr      hexl
 move.l   (sp)+,d0
 movem.l  (sp)+,a5/a6/d7/d6/a1/a2/d1/d2
 rte

tr_err:
 movem.l  (sp)+,a5/a6/d7/d6/a1/a2/d1/d2

to_old1:
 move.l   xbra1+8(pc),-(sp)
 rts


**********************************************************************
*
* void hexl( d0 = long i )
*

hexl:
 move.l   d0,-(sp)
 swap     d0                       ; Hiword
 bsr      hexw
 move.l   (sp)+,d0                 ; Loword
;bra      hexw


**********************************************************************
*
* void hexw( d0 = int i )
*

hexw:
 movem.l  d6/d7,-(sp)
 move.w   d0,d7
 moveq    #4-1,d6                  ; 4 Hex- Stellen
hexw_loop:
 rol.w    #4,d7                    ; h”chstes Nibble in die unteren 4 Bit
 move.w   d7,d0
 bsr.b    _hex
 dbra     d6,hexw_loop
 movem.l  (sp)+,d6/d7
 rts

_hex:
 andi.w   #$f,d0
 addi.b   #'0',d0
 cmpi.b   #'9',d0
 ble.b    _hex_1
 addi.b   #'A'-'0'-10,d0
_hex_1:
;bra      putch

**********************************************************************
*
* void prtstr(a0 = char *s)
*
*  Druckt die Zeichen in a0[] nach Device 2 (CON)
*

putch:
 move.w   d0,-(sp)
 move.w   #2,-(sp)
 move.w   #3,-(sp)
 trap     #13                      ; bios Bconout
 addq.l   #6,sp
 rts

prs_putch:
 move.l   a0,-(sp)
 bsr      putch
 move.l   (sp)+,a0
prtstr:
 move.b   (a0)+,d0
 bne.b    prs_putch
 rts


**********************************************************************
*
* void wait(a0 = char *s)
*
*  Druckt die Zeichen in a0[] nach Device 2 (CON) und wartet
*

wait:
 move.w   #2,-(sp)
 move.w   #1,-(sp)
 trap     #13                      ; bios Bconstat
 addq.w   #4,sp
 tst.w    d0
 bne.b    is_key
 DC.W     $a000
 btst.b   #0,-$253(a0)
 bne.b    is_klick
 bra.b    wait
is_key:
 move.w   #2,-(sp)
 move.w   #2,-(sp)
 trap     #13                      ; bios Bconin
 addq.w   #4,sp
is_klick:
 rts


crlf:
 DC.B     $d,$a,0
gleich:
 DC.B     '=',0
space:
 DC.B     '  ',0
gibt:
 DC.B     ' => ',0

     EVEN

* Aufbau der Tabelle:
*  Name der Funktion:         9 Zeichen
*  Name  des 1. Parameters:   4 Zeichen
*  L„nge des 1. Parameters:   1 Zeichen
*  Name  des 2. Parameters:   4 Zeichen
*  L„nge des 2. Parameters:   1 Zeichen
*  Name  des 3. Parameters:   4 Zeichen
*  L„nge des 3. Parameters:   1 Zeichen
*  Name  des 4. Parameters:   4 Zeichen
*  L„nge des 4. Parameters:   1 Zeichen
*

dos_tab:
 DC.W     87                       ; Tabellenl„nge

x1:
 DC.B     'Pterm0  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0    ; 0
x2:
 DC.B     'Cconin  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cconout ',0, 'chr',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cauxin  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cauxout ',0, 'chr',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cprnout ',0, 'chr',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Crawio  ',0, 'chr',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Crawcin ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cnecin  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cconws  ',0, 'str',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cconrs  ',0, 'buf',0,4, '   ',0,0, '   ',0,0, '   ',0,0    ; 10
 DC.B     'Cconis  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #12',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #13',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Dsetdrv ',0, 'drv',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #15',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cconos  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cprnos  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cauxis  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Cauxos  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #20',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0    ; 20
 DC.B     'dos  #21',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #22',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #23',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #24',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Dgetdrv ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fsetdta ',0, 'dta',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #27',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #28',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #29',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #30',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0    ; 30
 DC.B     'dos  #31',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Super   ',0, 'stk',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #33',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #34',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #35',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #36',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #37',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #38',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #39',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #40',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0    ; 40
 DC.B     'dos  #41',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Tgetdate',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Tsetdate',0, 'dat',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Tgettime',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Tsettime',0, 'tim',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #46',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fgetdta ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Sversion',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Ptermres',0, 'siz',0,4, 'cod',0,2, '   ',0,0, '   ',0,0
 DC.B     'dos  #50',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0    ; 50
 DC.B     'dos  #51',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #52',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #53',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Dfree   ',0, 'buf',0,4, 'drv',0,2, '   ',0,0, '   ',0,0
 DC.B     'dos  #55',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #56',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Dcreate ',0, 'nam',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Ddelete ',0, 'nam',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Dsetpath',0, 'nam',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fcreate ',0, 'nam',0,4, 'atr',0,2, '   ',0,0, '   ',0,0    ; 60
 DC.B     'Fopen   ',0, 'nam',0,4, 'mod',0,2, '   ',0,0, '   ',0,0
 DC.B     'Fclose  ',0, 'hdl',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fread   ',0, 'hdl',0,2, 'cnt',0,4, 'buf',0,4, '   ',0,0
 DC.B     'Fwrite  ',0, 'hdl',0,2, 'cnt',0,4, 'buf',0,4, '   ',0,0
 DC.B     'Fdelete ',0, 'nam',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fseek   ',0, 'off',0,4, 'hdl',0,2, 'mod',0,2, '   ',0,0
 DC.B     'Fattrib ',0, 'nam',0,4, 'flg',0,2, 'atr',0,2, '   ',0,0
 DC.B     'Mxalloc ',0, 'mod',0,2, 'siz',0,4, '   ',0,0, '   ',0,0
 DC.B     'Fdup    ',0, 'sth',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fforce  ',0, 'sth',0,2, 'hdl',0,2, '   ',0,0, '   ',0,0    ; 70
 DC.B     'Dgetpath',0, 'buf',0,4, 'drv',0,2, '   ',0,0, '   ',0,0
 DC.B     'Malloc  ',0, 'siz',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Mfree   ',0, 'buf',0,4, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Mshrink ',0, 'dum',0,2, 'buf',0,4, 'siz',0,4, '   ',0,0
 DC.B     'Pexec   ',0, 'mod',0,2, 'nam',0,4, 'par',0,4, 'env',0,4
 DC.B     'Pterm   ',0, 'cod',0,2, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #77',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Fsfirst ',0, 'nam',0,4, 'atr',0,2, '   ',0,0, '   ',0,0
 DC.B     'Fsnext  ',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #80',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #81',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #82',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #83',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #84',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'dos  #85',0, '   ',0,0, '   ',0,0, '   ',0,0, '   ',0,0
 DC.B     'Frename ',0, 'dum',0,2, 'old',0,4, 'new',0,4, '   ',0,0
 DC.B     'Fdatime ',0, 'buf',0,4, 'hdl',0,2, 'flg',0,2, '   ',0,0



ende:

************* nichtresidenter Teil ***********************************

main:
* Supervisormodus ein
 clr.l    -(sp)
 gemdos   Super
 addq.w   #6,sp
 move.l   d0,-(sp)
* nachsehen, ob schon installiert
 move.l   $84,a0
 lea      -12(a0),a1               ; ggf. Zeiger auf XBRA
 cmpi.l   #'XBRA',(a1)+
 bne.b    inst
 cmpi.l   #'DSMN',(a1)+
 beq      inst_err
* neuen Trap #1 installieren
inst:
 move.l   a0,xbra1+8
 move.l   #neu_trap1,$84
* wieder in den Usermodus
 gemdos   Super
 addq.w   #6,sp
* Titelzeile
 pea      hallos(pc)
 gemdos   Cconws
 addq.w   #6,sp
* Environment freigeben
 move.l   _base+$2c(pc),-(sp)
 gemdos   Mfree
 addq.w   #6,sp
* Resident beenden
 clr.w    -(sp)
 move.l   #ende-_base,-(sp)
 gemdos   Ptermres


* Schon installiert: deinstallieren

inst_err:
 move.l   (a1),$84                 ; Trap restaurieren
 subq.l   #8,a1
 suba.w   #xbra1-_base,a1
 move.l   a1,-(sp)
 gemdos   Mfree
 addq.l   #6,sp
 pea      errs2(pc)
 gemdos   Cconws
 addq.w   #6,sp
 gemdos   Super
 addq.w   #6,sp
 move.w   #ERROR,-(sp)
 gemdos   Pterm

hallos:   DC.B CR,LF,LF,TAB,TAB,'DOS- MONITOR V0.00 FšR Mag!X',CR,LF
          DC.B TAB,TAB,'Copyright (C) 1993 Andreas Kromke',CR,LF,LF,0
errs2:    DC.B 'Deinstalliert!',0

     END

