**********************************************************************
*
* void Protobt( char *buf, long serial, int typ, int isexec )
*

Protobt:
 movem.l    d3-d7/a3-a6,-(sp)
 move.w     10(a0),-(sp);isexec
 move.w     8(a0),-(sp) ;typ
 move.l     4(a0),-(sp) ;serial
 move.l     (a0),-(sp)  ;*buf
 bsr.b      _Protobt
 lea.l      12(sp),sp
 movem.l    (sp)+,d3-d7/a3-a6
 rte

_Protobt:
 lea      4(sp),a0
 lea      $a(a0),a1
 move.l   (a0)+,a2                 ; a2 ist der Puffer
 tst.w    (a1)                     ; isexec
 bge.b    proto_w1                 ; wird hiermit festgelegt
* execflag soll bleiben, also merken
 clr.w    (a1)                     ; per Default nicht ausführbar
 move.l   a2,a0
 bsr      prfsum                   ; liefert ZERO, falls = $1234
 lea      8(sp),a0                 ; a0 restaurieren
 bne.b    proto_w1                 ; nicht ausführbar, ok
 st       (a1)                     ; ausführbar
proto_w1:
 move.l   (a0)+,d0                 ; serial
 blt.b    proto_noser              ; nicht ändern
 cmp.l    #$ffffff,d0
 ble.b    proto_w2                 ; angegeben
 bsr      _Random
 move.l   d0,-4(a0)                ; neue Zufallsnummer
proto_w2:
 move.b   -1(a0),8(a2)
 move.b   -2(a0),9(a2)
 move.b   -3(a0),10(a2)            ; 3 Bytes kopieren
proto_noser:
 move.w   (a0)+,d0                 ; Disktyp
 blt.b    proto_notyp              ; < 0, nicht ändern
 cmpi.w   #4,d0                    ; 4 ist HD !
 bls.b    proto_ok                 ; <= 3, ok
 moveq    #3,d0                    ; Falscher Disktyp => 3 wählen
proto_ok:
 lea      proto_data(pc),a1
 mulu     #$13,d0                  ; Länge der Tabellenelemente
 add.w    d0,a1                    ; Quelle
 lea      $b(a2),a0                ; Ziel
 moveq    #$13-1,d1
proto_loop:
 move.b   (a1)+,(a0)+
 dbra     d1,proto_loop            ; Bootsektordaten kopieren
proto_notyp:
 move.l   a2,a0                    ; Sektorprüfsumme
 move.w   #255-1,d1                ; der ersten 255 Worte
 bsr      prfsum2                  ; schon $1234 subtrahiert
 neg.w    d0
 move.w   d0,(a0)                  ; letztes Wort, damit Summe $1234 stimmt
 tst.w    $e(sp)                   ; soll Bootsektor ausführbar sein ?
 bne.b    proto_ende               ; ja, Ende
 addq.w   #1,(a0)                  ; nein, Summe erhöhen
proto_ende:
 moveq    #0,d0                    ; trotz "void" geben wir E_OK
 rts

**********************************************************************
*
* int prfsum(a0 = int *sector)
*
* Setzt d0 = 0 und setzt das Z- Flag, falls Summe $1234 ist
*

prfsum:
 move.w   #256-1,d1                ; 256 Worte addieren
prfsum2:
 moveq    #0,d0
prfsum_loop:
 add.w    (a0)+,d0
 dbra     d1,prfsum_loop
 subi.w   #$1234,d0
 rts


proto_data:  /* Daten für Protobt */

/* Disktyp 0: Einseitig, LD (180k) */
 DC.B     $00,$02   ; BPS     = 512     Bytes/Sektor
 DC.B     $01       ; SPC     = 1       Sektor/Cluster
 DC.B     $01,$00   ; RES     = 1       reservierter Sektor
 DC.B     $02       ; NFATS   = 2       FATs
 DC.B     $40,$00   ; NDIRS   = 64      Einträge im Wurzelverzeichnis
 DC.B     $68,$01   ; NSECTS  = 360     Sektoren gesamt
 DC.B     $fc       ; MEDIA   = $fc     Media Byte
 DC.B     $02,$00   ; SPF     = 2       Sektoren/FAT
 DC.B     $09,$00   ; SPT     = 9       Sektoren/Spur
 DC.B     $01       ; NSIDES  = 1       Seiten
 DC.B     $00,$00   ; NHID    = 0       versteckte Sektoren
 DC.B     $00       ; EXECFLAG= 0       kein COMMAND.PRG

/* Disktyp 1: Zweiseitig, LD (360k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $d0,$02   ; NSECTS  = 720
 DC.B     $fd       ; MEDIA   = $fd
 DC.B     $02,$00   ; SPF     = 2
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 2: Einseitig, DD (360k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $d0,$02   ; NSECTS  = 720
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $05,$00   ; SPF     = 5
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $01       ; NSIDES  = 1
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 3: Zweiseitig, DD (720k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $70,$00   ; NDIRS   = 112
 DC.B     $a0,$05   ; NSECTS  = 1440
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $05,$00   ; SPF     = 5
 DC.B     $09,$00   ; SPT     = 9
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

/* Disktyp 4: Zweiseitig, HD (1440k) */
 DC.B     $00,$02   ; BPS     = 512
 DC.B     $02       ; SPC     = 2
 DC.B     $01,$00   ; RES     = 1
 DC.B     $02       ; NFATS   = 2
 DC.B     $e0,$00   ; NDIRS   = 224
 DC.B     $40,$0b   ; NSECTS  = 2880
 DC.B     $f9       ; MEDIA   = $f9
 DC.B     $06,$00   ; SPF     = 6
 DC.B     $12,$00   ; SPT     = 18
 DC.B     $02       ; NSIDES  = 2
 DC.B     $00,$00   ; NHID    = 0
 DC.B     $00       ; EXECFLAG= 0

     EVEN
