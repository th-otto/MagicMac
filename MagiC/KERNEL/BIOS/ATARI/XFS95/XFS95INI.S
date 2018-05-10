
*                                                  30.05.96
*                                                        FS
*                                                  06.06.96
*                                                        AK
* __________________________________________________________________________


     EXPORT mpc_da
     EXPORT xfs95ini

* __________________________________________________________________________

mec1     .equ  $43bf       * mec1-Befehle
m1vers   .equ  1

mec2     .equ  $45bf       * mec2-Befehle
m2ld0xfs .equ  36
m2ld1xfs .equ  37
* __________________________________________________________________________


     TEXT


**************** Anwerfen des XFS-Dateisystem in MagiC_PC ******************
*
* [für den MAGIC-Booter zum Einbinden]
*
*    long xfs95ini( void )
*    ---------------
*    return: >=0 : ok, <0: Fehler
* 
*________
xfs95ini:
*--------
         movem.l  d3-d7/a3-a6,-(sp)

         dc.w     mec2,m2ld0xfs  * Speicherbedarf ermitteln
         tst.l    d0
         ble.b    e_nfd
         move.l   d0,d5          * Länge in d5 merken

         move.l   d0,-(sp)
         move.w   #$48,-(sp)     * Malloc
         trap     #1
         addq.l   #6,sp
         tst.l    d0             * ok?
         ble.b    e_malloc
         movea.l  d0,a5          * Startadresse in a5 merken

         movea.l  a5,a0
         move.l   d5,d0
         dc.w     mec2,m2ld1xfs  * Laden! (Adr. a0, Länge d0)
         tst.l    d0             * Ladefehler?
         ble.b    e_load

         jsr      (a5)           * AUFRUFEN

lab900:  movem.l  (sp)+,d3-d7/a3-a6
         rts

* Die Fehlerausgänge:
* -------------------
e_malloc: moveq   #-39,d0
         bra.b    lab900
e_load:  moveq    #-1,d0
         bra.b    lab900
e_nfd:   moveq    #-33,d0
         bra.b    lab900
*
****************************************************************************


*******************  MagicPC - Detektor / Versionsabfrage ******************
*                    ====================================
* --------------
* d0 = void * mpc_da( void );
* --------------
* return: d0 == 0: nicht da,
*            != 0: MAGIC_PC vorhanden, Adresse der folgenden Struktur:
*

mpc_vers: dc.l    0        * Versionsnummer (z.Zt $00001000 für 0.1)
mpc_date: dc.l    0        * Versionsdatum (z.B.  $19960530 für 30.05.1996
mpc_flags: dc.l   0        * Bit 0: Demo-Version, Rest noch uu, 0

mpc_da:
;    Löschen unnötig, da im DATA-Segment auf 0 initialisiert

;         lea      mpc_vers(pc),a0
;         clr.l    (a0)+          * Übergabe-Struktur löschen
;         clr.l    (a0)+
;         clr.l    (a0)

         lea      $10,a0         * Vektor4 für Illegal
         move.l   (a0),a2        * Vektor4 merken
         move.l   #det900,(a0)   * gleich dorthin, wenn's rummst
         move.l   sp,a1          * ssp merken

         dc.w     mec1,m1vers    * hier ist der illegale Franz-Opcode
                                 * ändert hoffentlich nur d0-d2
         lea      mpc_vers+8(pc),a0
         move.l   d2,(a0)        * mpc_flags: Bit 0: Demo-Version
         move.l   d1,-(a0)       * mpc_date: Versionsdatum
         move.l   d0,-(a0)       * mpc_vers: Versionsangabe merken
         move.l   a0,d0          * return(&MPC)
         bra.b    ende

det900:  move.l   a1,sp          * ssp restaurieren
         moveq    #0,d0          * return(NULL)
ende:
         move.l   a2,(a0)        * Vektor4 restaurieren
         rts

     END
