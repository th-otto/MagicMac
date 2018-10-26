; Diese Datei enthaelt die Debugging- Makros
; Es gibt verschiedene Debugging- Level:
;
; Level 0:     Bootphasen- Kommentare
; Level 1:     Userfunktionen des Kernels
; Level 2:     Funktionen des XFS
; Level 3:     Funktionen des DFS
; Level 4:     Funktionen der Dateitreiber
;

DEBLEVEL  EQU  1

     MACRO     DEBON
     IF   (DEBUG&DEBLEVEL)
     st   $4ca
     ENDIF
     ENDM

     MACRO     DEBOFF
     IF   (DEBUG&DEBLEVEL)
     sf   $4ca
     ENDIF
     ENDM

     MACRO     DEB  text,text2,text3
     LOCAL     t1,t2,t3
     IF   (DEBUG&DEBLEVEL)
 move.w   sr,-(sp)
 tst.b    $4ca
 beq      t3
 movem.l  d0-d2/a0-a2,-(sp)
 bra.b    t1
t2: DC.B  text
    IFNB text2
    dc.b text2
    ENDC
    IFNB text3
    dc.b text3
    ENDC
     dc.b $d,$a,0
     EVEN
t1:
 lea      t2(pc),a0
 bsr      debug_puts
 movem.l  (sp)+,d0-d2/a0-a2
t3:
 move.w   (sp)+,sr
     ENDIF
     ENDM

     MACRO     DEBL  val,text,text2,text3
     LOCAL     t1,t2,t3
     IF   (DEBUG&DEBLEVEL)
 move.w   sr,-(sp)
 tst.b    $4ca
 beq      t3
 movem.l  d0/d1/d2/d7/a0-a2,-(sp)
 move.l   val,d7
 bra.b    t1
t2: DC.B  text
    IFNB text2
    dc.b text2
    ENDC
    IFNB text3
    dc.b text3
    ENDC
     dc.b 0
     EVEN
t1:
 lea      t2(pc),a0
 bsr      debug_puts
 move.l   d7,d0
 bsr      hexl
 bsr      crlf
 movem.l  (sp)+,d0/d1/d2/d7/a0-a2
t3:
 move.w   (sp)+,sr
     ENDIF
     ENDM

     MACRO     DEBT  val,text,text2,text3
     LOCAL     t1,t2,t3
     IF   (DEBUG&DEBLEVEL)
 move.w   sr,-(sp)
 tst.b    $4ca
 beq      t3
 movem.l  d0/d1/d2/d7/a0-a2,-(sp)
 move.l   val,d7
 bra.b    t1
t2: DC.B  text
    IFNB text2
    dc.b text2
    ENDC
    IFNB text3
    dc.b text3
    ENDC
     dc.b 0
     EVEN
t1:
 lea      t2(pc),a0
 bsr      debug_puts
 move.l   d7,a0
 bsr      debug_puts
 bsr      crlf
 movem.l  (sp)+,d0/d1/d2/d7/a0-a2
t3:
 move.w   (sp)+,sr
     ENDIF
     ENDM
