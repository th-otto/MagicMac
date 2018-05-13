**********************************************************************
*
* BOOTLADER FöR KAOS                              14.08.88
* ==================
*
*                             letzte énderung     08.08.90
*
* liest Datei "KAOS*.ROM" in den dafÅr vorgesehenen Speicherbereich
* und startet KAOS.
*
**********************************************************************

USA		EQU	0
FRG		EQU	1
FRA		EQU	2
UK		EQU	3
SPA		EQU	4
ITA		EQU	5				; Country- Codes laut Atari Doku


TOSLEN    EQU  $30000


     INCLUDE "OSBIND.INC"

     TEXT
     SUPER

     lea       stack,sp

* prÅfen, ob ein RAM-TOS da ist

     clr.l     -(sp)
     gemdos    Super
     addq.l    #6,sp
     move.l    _sysbase,a0
     move.l    4,a1                ; ROM- Startadresse
     cmp.l     os_start(a0),a1     ; vergleichen mit TOS- Startadresse
     bhi       err                 ; RAMTOS aktiv !

* ôffnen der Datei: Handle d7

     lea       puffer,a6
     clr.w     -(sp)
     pea       name
     gemdos    Fopen
     addq.l    #8,sp
     move.w    d0,d7
     bmi       err

* Einlesen des Dateiheaders (12 Bytes)

     pea       (a6)
     move.l    #12,-(sp)
     move.w    d7,-(sp)
     gemdos    Fread
     adda.w    #12,sp
     subi.l    #12,d0
     bne       err
     move.l    os_base(a6),a5      ; Ladeadresse

* a4 zeigt auf neue Bildschirmspeicheradresse

     move.l    a5,a4
     suba.l    #$8000,a4           ; neuer Bildschirmspeicher

* öberprÅfung der Ladeadresse

     move.l    a5,d0
     btst      #0,d0
     bne       err2                ; ungerade Ladeadresse
     cmpa.l    a7,a4
     bcs       err2                ; Ladeadresse zu tief
     move.l    #$12345678,d0
     move.l    (a5),d1
     move.l    d0,(a5)
     move.l    (a5),d2
     move.l    d1,(a5)
     cmp.l     d2,d0
     bne       err2                ; kein RAM bei Ladeadresse
     move.l    a5,a0
     add.l     #TOSLEN-4,a0        ; letztes Langwort von KAOS
     move.l    (a0),d1
     move.l    d0,(a0)
     move.l    (a0),d2
     move.l    d1,(a0)
     cmp.l     d2,d0
     bne       err2                ; kein RAM bei Ende der Ladeadresse

* PrÅfen, ob ein KAOS schon da ist

     move.l    a6,a0
     move.l    a5,a1
     cmpm.l    (a0)+,(a1)+
     bne       do_load

* KAOS schon da => weiter mit AUTO- Ordner ?

     move.l    a5,a6               ; hier liegt es
     move.w    d7,-(sp)
     gemdos    Fclose
     addq.w    #4,sp
     moveq     #0,d0
     bsr       info
     move.w    d0,d6               ; Residentmodus merken
     bra       do_start

do_load:

* Ausgabe der Betriebssystemversion und Ladeadresse

     moveq     #1,d0
     bsr       info
     move.w    d0,d6               ; Residentmodus merken

* Einlesen der 192 kB

     pea       12(a6)
     move.l    #TOSLEN-12,-(sp)
     move.w    d7,-(sp)
     gemdos    Fread               ; Datei einlesen
     adda.w    #12,sp
     subi.l    #TOSLEN-12,d0       ; alles eingelesen ?
     bne       err

     move      d7,-(sp)
     gemdos    Fclose              ; Datei schlieûen
     addq.l    #4,sp

* KAOS modifizieren, verschieben und starten

     move.l    a6,a1               ; a1 = Anfang des TOS
     move.l    a6,a2
     adda.l    #TOSLEN,a2          ; a2 = Ende des TOS
     move.b    1(a1),d0
     ext.w     d0                  ; Branch- Offset
     lea       6(a1,d0.w),a1
     move.w    #$4e71,(a1)+        ; Befehl "reset" durch "nop" ersetzen
     sf        d1
desk_loop:
     move.l    a1,a0               ; Test auf "DESK"
     cmpi.b    #'D',(a0)+
     bne.b     ck2
     cmpi.b    #'E',(a0)+
     bne.b     ck2
     cmpi.b    #'S',(a0)+
     bne.b     ck2
     cmpi.b    #'K',(a0)+
     bne.b     ck2
     cmpi.b    #' ',(a0)
     bne.b     ck2
     tst.b     1(a0)
     bne.b     ck2
     move.b    #'S',-(a0)
     move.b    #'O',-(a0)
     move.b    #'A',-(a0)
     move.b    #'K',-(a0)
     bra.b     desk_endloop
ck2:
     tst.b     d1
     bne.b     desk_endloop        ; schon modifiziert
     move.w    a1,d0               ; Test auf $31415926,$0426
     btst      #0,d0
     bne.b     desk_endloop
     move.l    a1,a0
     cmpi.l    #$31415926,(a0)+
     bne.b     desk_endloop
     cmpi.w    #$0426,(a0)+
     bne.b     desk_endloop
     move.b    #$60,(a0)           ; "bra" statt "bne"
     st        d1
     move.l    a6,a1
     adda.l    #$10000,a1          ; RSCs liegen in den letzten 128k
desk_endloop:
     addq.l    #1,a1
     cmpa.l    a2,a1
     bcs.b     desk_loop

     move.l    a4,a0
     move.w    #$3fff,d0
loop:
     clr.l     (a0)+               ; neuen Bildschirm lîschen
     dbra      d0,loop

     move.w    #-1,-(sp)           ; Auflîsung unverÑndert
     move.l    a4,-(sp)
     move.l    a4,-(sp)            ; logische = physikalische Adresse
     xbios     Setscreen           ; Bildschirmspeicher verschieben
     adda.w    #12,sp

     ori.w     #$700,sr

     move.l    a5,a0
     move.l    a6,a1
     bsr       toscpy

     move.l    a5,phystop          ; Systemvariablen setzen
     move.l    a4,_memtop
do_start:
     move.l    #$5555aaaa,$51a
     cmpi.b    #$1b,d6
     beq.b     no_reset            ; Esc => nicht resetfest machen
     move.l    #$31415926,resvalid
     move.l    a5,resvector
no_reset:
     jmp       (a5)                ; KAOS starten


err2:
     lea       fehler,a0
     bsr       cconws
err:
     gemdos    Pterm0


**********************************************************************
*
* int info( d0 = int isload )
*
**********************************************************************

info:
     movem.l   d3/d4/d5/d6,-(sp)
     move.w    d0,d6
     lea       titel,a0
     bsr       cconws
     lea       titel_load,a0
     tst.w     d6
     bne.b     info_load
     lea       titel_act,a0
     lea       nach+2,a1
     move.b    #'b',(a1)+
     move.b    #'e',(a1)+
     move.b    #'i',(a1)+
     move.b    #' ',(a1)
info_load:
     bsr       cconws              ; Titelzeile ausgeben

     moveq     #'0',d0
     add.b     os_version(a6),d0
     bsr       cconout
     moveq     #'.',d0
     bsr       cconout
     moveq     #'0',d0
     add.b     os_version+1(a6),d0
     bsr       cconout
     lea       nach,a0
     bsr       cconws
     moveq     #7,d3
     move.l    a5,d4
     st        d5                  ; Flag fÅr fÅhrende Nullen
wloop:
     move.l    d4,d1
     lsl.l     #4,d4
     moveq     #28,d0
     lsr.l     d0,d1
     moveq     #'0',d0
     cmpi.b    #9,d1
     bcs.b     w_lt9
     moveq     #'A'-10,d0
w_lt9:
     tst.b     d5
     beq.b     w_print
     tst.b     d1
     beq.b     w_noprint
     sf        d5
w_print:
     add.b     d1,d0
     bsr       cconout
w_noprint:
     dbra      d3,wloop

     lea       titel2_load,a0
     tst.w     d6
     bne.b     info_load2
     lea       titel2_act,a0
info_load2:
     bsr       cconws
     gemdos    Cnecin              ; Taste zurÅckgeben
     addq.l    #2,sp
     movem.l   (sp)+,d3/d4/d5/d6
     rts


**********************************************************************
*
* void cconout(d0 = char c)
*
**********************************************************************

cconout:
 andi.w   #$ff,d0
 move.w   d0,-(sp)
 gemdos   Cconout
 addq.w   #4,sp
 rts


**********************************************************************
*
* void cconws(a0 = char *s)
*
**********************************************************************

cconws:
 move.l   a0,-(sp)
 gemdos   Cconws
 addq.l   #6,sp
 rts


**********************************************************************
*
* void toscpy(a0 = void *dst, a1 = void *src)
*
**********************************************************************

toscpy:
 move.w   #(TOSLEN/8)-1,d0
 cmpa.l   a0,a1
 bhi      cpy_uloop
 beq      cpy_end
 adda.l   #TOSLEN,a1
 adda.l   #TOSLEN,a0
cpy_dloop:
 move.l   -(a1),-(a0)
 move.l   -(a1),-(a0)
 dbra     d0,cpy_dloop
cpy_end:
 rts
cpy_uloop:
 move.l   (a1)+,(a0)+
 move.l   (a1)+,(a0)+
 dbra     d0,cpy_uloop
 rts


     DATA

	IF	COUNTRY=FRG
name:          DC.B    '\kaos*.rom',0
fehler:        DC.B    'KAOSBOOT: Falsche Ladeadresse (kein RAM vorhanden ?)',0
titel:         DC.B    CR,LF,'KAOSø- Bootprogramm, Ω 1990 Andreas Kromke',CR,LF,0
titel_load:    DC.B    '\KAOS*.ROM wird gebootet : Version ',0
titel_act:     DC.B    'nicht aktives TOS im RAM: Version ',0
nach:          DC.B    '  nach $',0
titel2_load:   DC.B    CR,LF,LF,'Leertaste:   laden und resetfest machen'
               DC.B       CR,LF,'Esc:         laden'
               DC.B       CR,LF,'^C:          nicht laden',CR,LF,LF,0
titel2_act:    DC.B    CR,LF,LF,'Leertaste:   resetfest machen und starten'
               DC.B       CR,LF,'Esc:         nur starten'
               DC.B       CR,LF,'^C:          nicht starten',CR,LF,LF,0
	ENDIF
	IF	COUNTRY=USA
name:          DC.B    '\kaos*.rom',0
fehler:        DC.B    'KAOSBOOT: Invalid load address (no RAM there ?)',0
titel:         DC.B    CR,LF,'KAOSø boot program, Ω 1990 Andreas Kromke',CR,LF,0
titel_load:    DC.B    '\KAOS*.ROM will be booted : version ',0
titel_act:     DC.B    'inactive TOS in RAM: version ',0
nach:          DC.B    '  to $',0
titel2_load:   DC.B    CR,LF,LF,'Space:       load and make reset resident'
               DC.B       CR,LF,'Esc:         load'
               DC.B       CR,LF,"^C:          don't load",CR,LF,LF,0
titel2_act:    DC.B    CR,LF,LF,'Space:       make reset resident and start'
               DC.B       CR,LF,'Esc:         only start'
               DC.B       CR,LF,"^C:          don't start",CR,LF,LF,0
	ENDIF

     BSS

     EVEN

     DS.L      200
stack:

puffer:
     DS.B      TOSLEN

     END
