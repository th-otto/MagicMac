**********************************************************************
*
* ADDMEM  (FOLDRXXX fÅr KAOS 1.4)
*
* erstellt        26.12.89
* letzte énderung 26.12.89
*
**********************************************************************


     INCLUDE "osbind.inc"

/* KAOS Konstanten */

SC_GET    EQU  0
SC_SET    EQU  1
SC_VARS   EQU  2
SC_VER    EQU  3

BSIZE     EQU  7000                ; 70 IMBs

Mblavail  EQU  Mshrink

     OFFSET

sc_in_dos:          DS.L      1
sc_dos_time:        DS.L      1
sc_dos_date:        DS.L      1
sc_dos_stack:       DS.L      1
sc_pgm_superst:     DS.L      1
sc_memlist:         DS.L      1
sc_act_pd:          DS.L      1
sc_fcbx:            DS.L      1
sc_fcbn:            DS.W      1
sc_dmdx:            DS.L      1
sc_imbx:            DS.L      1
sc_resv_intmem:     DS.L      1
sc_etv_critic:      DS.L      1
sc_err_to_str:      DS.L      1

     TEXT

_base     EQU    *-$100

 lea      _base(pc),a6             ; Basepage
 move.l   $2c(a6),-(sp)            ; Environment
 gemdos   Mfree                    ;  freigeben
 addq.l   #6,sp
 gemdos   Sversion
 addq.w   #2,sp
 cmpi.w   #$1600,d0
 bcs.b    ver_err
 move.w   #SC_VARS,-(sp)
 gemdos   Sconfig
 addq.w   #4,sp
 tst.l    d0
 bmi.b    ver_err
 move.l   d0,a0
 move.l   sc_resv_intmem(a0),a5

 lea      beg_res(pc),a3           ; Anfang des zu reservierenden Bereichs
 lea      b+BSIZE(pc),a4           ; Ende des zu reservierenden Bereichs

 move.l   a4,d7
 sub.l    a3,d7
 divu     #70,d7
 mulu     #70,d7                   ; auf 70-Byte-Einheiten runden
 move.l   a3,a0
 move.l   d7,d0
 jsr      (a5)                     ; Speicher an GEMDOS Åbergeben
 add.l    a3,d7
 sub.l    a6,d7
 clr.w    -(sp)
 move.l   d7,-(sp)
 gemdos   Ptermres

beg_res:

ver_err:
 pea      ver_errs(pc)
 gemdos   Cconws
 addq.w   #6,sp
 move.w   #-1,-(sp)
 gemdos   Pterm

ver_errs:
 DC.B     'ADDMEM: Kein KAOS installiert oder falsche TOS- Version',$d,$a,0


     BSS

b:

 DS.B     BSIZE

     END
