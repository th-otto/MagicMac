**********************************************************************
**********************************************************************
*
* MAGIX- Speicherverwaltung
*
**********************************************************************

 FALCON        EQU  1
 NBLOCKS       EQU  16
 MEMLEN_OFFS   EQU  (4*NBLOCKS)
 DEBUG         EQU  0

	include "country.inc"

 SUPER

fstrm_beg      EQU $49e            ; in Mag!X Beginn des TT-RAMs
fstrm_top      EQU $5a4
_memtop        EQU $436

     INCLUDE "errno.inc"
     INCLUDE "kernel.inc"
     INCLUDE "structs.inc"
     INCLUDE "debug.inc"
     INCLUDE "basepage.inc"

     XDEF mc_init
     XDEF Mxalloc
     XDEF Memxavail
     XDEF Mxfree
     XDEF Mxshrink
     XDEF Srealloc
     XDEF Maddalt
     XDEF Pfree
     XDEF Mchgown
     XDEF Mgetlen
     XDEF Mzombie,Mfzombie
     XDEF pd_used_mem
     XDEF total_mem       ; an DFS_U
     XDEF mshare
     XDEF mfork
     XDEF Memshare,Memunsh         ; an DEV_MEM für F_SETSHMBLK
     XDEF Pmemsave,Pmemrestore     ; an MAGIDOS für Pfork()

* Importe aus dem BIOS

     XREF halt_system
     XREF config_status
     XREF scrbuf_adr,scrbuf_len

* von MAGIDOS

     XREF mem_root
     XREF ur_pd
     XREF str_to_con
     XREF getkey,dump
     XREF Pterm

* von STD

     XREF fast_clrmem
     XREF hexl,putch,crlf
     XREF memmove



     OFFSET

mcb_magic:     DS.L      1    /* 0x00: 'ANDR' oder 'KROM' (letzter)        */
mcb_len:       DS.L      1    /* 0x04: Nettolänge                          */
mcb_owner:     DS.L      1    /* 0x08: PD *                                */
mcb_prev:      DS.L      1    /* 0x0c: vorh. Block oder NULL               */
mcb_data:

     OFFSET

md_link:       DS.L      1    /* 0x00: Zeiger auf nächsten Block           */
md_start:      DS.L      1    /* 0x04: Zeiger auf Speicherblock            */
md_len:        DS.L      1    /* 0x08: Länge des Speicherblocks            */
md_own:        DS.L      1    /* 0x0c: Prozeß (1 = "unbenutzt")            */

     TEXT

**********************************************************************
*
* mc_init()
*  Initialisierung der Speicherverwaltung, Ur- PD einrichten.
*  Puffer für zeichenorientierten I/O initialisieren.
*  Wird von os_init nach einem Reset aufgerufen.
*

mc_init:

     DEBON
     DEB  'Initialisierung der Speicherverwaltung'

* MemoryParameterBlock initialisieren (bios Getmpb)
 lea      mem_root.w,a0
 lea      MEMLEN_OFFS(a0),a1
 jsr      fast_clrmem              ; 16 Zeiger löschen

     DEB  'Getmpb() aufrufen'

 subq.l   #8,sp
 clr.l    -(sp)                    ; Platz für drei Zeiger
 pea      (sp)
 clr.w    -(sp)
 trap     #$d
 addq.w   #6,sp
 move.l   (sp)+,a0                 ; erstes Element der TOS-freelist
 addq.l   #8,sp                    ; alloclist und rover vergessen
 lea      mem_root.w,a1
 moveq    #16,d1                   ; sizeof(MCB)
mci_loop:
 clr.l    (a1)
 move.l   md_start(a0),a2          ; a2 = Startadresse
     DEBL 'Block beginnt bei ',a2
 move.l   md_len(a0),d2            ; d2 = Länge
     DEBL 'Block hat Länge ',d2

* Korrektur für Langwortgrenze

 move.l   a2,d0
 btst     #1,d0                    ; Adresse long-aligned ?
 beq.b    mci_is_4                 ; ja, OK
 addq.l   #2,a2                    ; nein, Startadresse 2 Bytes nach hinten
 subq.l   #2,d2                    ; und Länge verkleinern
mci_is_4:
 andi.w   #$fffc,d2                ; Länge auf long-aligned

 cmp.l    d1,d2                    ; Brutto->Netto
 bls.b    mci_nxt_md               ; Block zu klein

 move.l   a2,(a1)                  ; Startadresse in mem_root[n] eintragen
 move.l   a2,MEMLEN_OFFS(a1)
 add.l    d2,MEMLEN_OFFS(a1)       ; Blockende merken
/*
 move.l   a2,mem_top-mem_root(a1)
 add.l    d2,mem_top-mem_root(a1)  ; Blockende merken
*/
 sub.l    d1,d2
 move.l   #'KROM',(a2)+            ; mcb_magic: kein weiterer Block
 move.l   d2,(a2)+                 ; mcb_len  : Nettolänge
 move.l   md_own(a0),(a2)+         ; mcb_owner: vom MD kopieren
 clr.l    (a2)                     ; mcb_prev : kein vorheriger Block
mci_nxt_md:
 addq.l   #4,a1                    ; nächste Liste
 cmpa.l   #(mem_root+4).w,a1
 bne.b    mci_no_end_st
 move.l   #-1,(a1)+                ; mem_root+4 ist immer -1L
mci_no_end_st:
 clr.l    (a1)                     ; schon mal Listenende markieren
 move.l   md_link(a0),a0           ; nächster MD
 move.l   a0,d0
 bne      mci_loop
* MCB für Bildschirmspeicher beim Falcon
     IFNE FALCON
 move.l   scrbuf_adr,d0
 beq.b    mci_no_scrbuf
     DEB  'Bildschirmspeicher allozieren'
 cmp.l    (mem_root+MEMLEN_OFFS).w,d0   ; Ende ST-RAM == Anfang Bildschirm ?
/*
 cmp.l    mem_top,d0               ; Ende ST-RAM == Anfang Bildschirm ?
*/
 bne      mem_fatal_err            ; ?? nein ??
 move.l   d0,a0
 moveq    #mcb_data,d0
 move.l   mem_root.w,a1
 sub.l    d0,mcb_len(a1)           ; Block verkleinern, Platz für MD
 sub.l    d0,a0
 move.l   mcb_magic(a1),mcb_magic(a0)   ; neuer Block ist letzter
 move.l   #'ANDR',mcb_magic(a1)         ; alter Block ist nicht letzter
 move.l   scrbuf_len,d0
 move.l   d0,mcb_len(a0)
 add.l    d0,(mem_root+MEMLEN_OFFS).w
/*
 add.l    d0,mem_top.w
*/
 move.l   a1,mcb_prev(a0)
 move.l   #ur_pd,mcb_owner(a0)          ; Block belegen
mci_no_scrbuf:
     ENDIF
     DEB  'Initialisierung der Speicherverwaltung beendet'
 rts


**********************************************************************
*
* void mem_fatal_err()
*

mem_fatal_err:
 lea      mem_fatal_errs(pc),a0
 jmp      halt_system              ; im BIOS


**********************************************************************
*
* void print_mem_err( a0 = MCB *mcb )
*

print_mem_err:
 movem.l  d7/a5,-(sp)
 move.l   a0,a5
 lea      mem_err_s(pc),a0
 bsr      str_to_con
 lea      adrmcb_s(pc),a0
 bsr      str_to_con
 move.l   a5,d0
 bsr      hexl
 jsr      crlf
 lea      datmcb_s(pc),a0
 bsr      str_to_con
 moveq    #4-1,d7
meme_loop:
 moveq    #'$',d0
 jsr      putch
 move.l   (a5)+,d0
 bsr      hexl
 moveq    #' ',d0
 jsr      putch
 dbra     d7,meme_loop
 movem.l  (sp)+,d7/a5
 rts


**********************************************************************
*
* a0 = MCB *last_block( a0 = MCB *list )
*
* ermittelt in den letzten Block der Liste.
* zerstört kein Register, ändert nur a0
*

last_block:
 cmpi.l   #'KROM',(a0)             ; mcb_magic
 beq.b    lb_ende                  ; gefunden
 cmpi.l   #'ANDR',(a0)+
 bne      mem_err_4
 add.l    (a0)+,a0                 ; Nettolänge addieren
 addq.l   #8,a0                    ; 2 Pointer überspringen
 bra.b    last_block
lb_ende:
 rts


**********************************************************************
*
* void mem_repair( a0 = MCB *mcb, PD *owner, MCB *mcb )
*
* Gibt eine Fehlerbeschreibung aus und repariert ggf. die
* Speicherverwaltung, indem der "unbekannte" Speicher als
* <owner> gehörig markiert wird.
*

mem_repair:
 bsr.b    print_mem_err            ; Fehlermeldung ausgeben
 lea      do_repair_s(pc),a0
 bsr      str_to_con
memr_getkey:
 bsr      getkey
 cmpi.b   #'N',d0
 beq      mem_err_dump             ; nicht reparieren, System anhalten
 cmpi.b   #'J',d0                  ; COUNTRY_DE: "Ja"
 beq.b    memr_do
 cmpi.b   #'O',d0                  ; COUNTRY_FR: "Oui"
 beq.b    memr_do
 cmpi.b   #'Y',d0                  ; COUNTRY_US/COUNTRY_UK: "Yes"
 bne.b    memr_getkey
memr_do:
 jsr      putch

 move.l   8(sp),a1                 ; Fehlerhafter MCB
 move.l   mem_root.w,a0            ; Beginn ST_RAM
 move.l   _memtop,d2
 cmpa.l   a0,a1
 bcs      mem_err_dump             ; Adresse < ST_RAM
 cmpa.l   d2,a1
 bcs.b    memr_rep                 ; Adresse >= ST_RAM && < ST_RAM_TOP
 move.l   (mem_root+4).w,d0
 ble      mem_err_dump             ; Fehler
 move.l   d0,a0
 move.l   fstrm_top,d2
 cmpa.l   a0,a1
 bcs      mem_err_dump             ; Adresse < TT_RAM
 cmpa.l   d2,a1
 bcc      mem_err_dump
; a0 ist Beginn des zu untersuchenden Speichers
; d2 ist Ende
memr_rep:
 moveq    #0,d0                    ; kein vorheriger Block
memr_memloop:
 cmpi.l   #'KROM',(a0)
 beq.b    memr_ende                ; letzter Block
 cmpi.l   #'ANDR',(a0)
 bne.b    memr_repair              ; dies ist der kaputte
memr_next:
 move.l   a0,d0                    ; d0 ist vorheriger Block
 addq.l   #4,a0                    ; a0 zeigt auf len
 adda.l   (a0)+,a0                 ; nächster Block
 addq.l   #8,a0                    ; mcb_owner, mcb_prev überspringen
 bra      memr_memloop

memr_repair:
; a0 ist der kaputte MCB, d0 ist der vorherige MCB
 move.l   #'KROM',d1
 move.l   a0,a2
 move.l   d1,(a2)+                 ; als letzten MCB
 clr.l    (a2)+                    ; Länge zunächst 0
 move.l   4(sp),(a2)+              ; mcb_owner
 move.l   d0,(a2)+                 ; mcb_prev
 move.l   a2,a1
 move.l   #'ANDR',d0
memr_reploop:
 addq.l   #4,a1                    ; mindestens ein LONG
 cmpa.l   d2,a1
 bcc      memr_doit
 cmp.l    (a1),d0
 beq.b    memr_doit2
 cmp.l    (a1),d1
 bne.b    memr_reploop
; a0 ist der kaputte Block
; a2 zeigt hinter den kaputten Block
; a1 ist der nächste Block, dessen mcb_magic gültig ist
memr_doit2:
 move.l   d0,(a0)                  ; #'ANDR', kaputter Block nicht letzter
 move.l   a0,mcb_prev(a1)          ; falls mehr als ein Block kaputt!
memr_doit:
 sub.l    a2,a1                    ; a2 war Beginn des freien Speichers
 bcs.b    memr_ende                ; Fehler (?)
 move.l   a1,mcb_len(a0)           ; Länge eintragen
memr_ende:
 rts


**********************************************************************
*
* void mem_err( a0 = MCB *mcb )
*

mem_err_12:
 subq.l   #4,a0
mem_err_8:
 subq.l   #4,a0
mem_err_4:
 subq.l   #4,a0
mem_err:
 bsr      print_mem_err
mem_err_dump:
 lea      do_dump_s(pc),a0
 bsr      str_to_con
 bsr      getkey
 move.w   d0,d7
 subi.b   #'A',d7
 bcs.b    meme_nodmp
 cmpi.b   #LASTDRIVE,d7
 bhi.b    meme_nodmp
 jsr      putch
 ext.w    d7
 move.w   d7,d0
 bsr      dump
meme_nodmp:
 lea      do_term_s(pc),a0
 bsr      str_to_con
 moveq    #1,d1                    ; Speicher freigeben
 moveq    #-1,d0                   ; RÜckgabecode
 bra      Pterm


**********************************************************************
*
* EQ/NE a0 = d0 = MCB *_malloc(d0 = long amount, d1 = int limitflag,
*                        a0 = MCB *list, a1 = PD *pd)
*
*  Rückgabe d0 = 0L, wenn kein passender Block da, sonst a0 = MCB *
*  "First fit"- Strategie
*
* Abfrage/Modifikation von p_mem(a1) nur dann, wenn <limitflag> = 1.
*
* ändert nicht a1/d1
*

_malloc:
 move.w   d1,-(sp)                 ; limitflag merken
 move.l   (a0),d1
 beq      _mal_nix                 ; Liste ist leer

 tst.w    (sp)                     ; Beschränkung ?
 beq.b    _mal_weiter              ; nein, Speicher nicht beschränken
 cmp.l    p_mem(a1),d0
 bhi.b    _mal_nix                 ; Beschränkung schlägt zu
_mal_weiter:

 move.l   d1,a0
_mal_loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 tst.l    (a0)
 bne.b    _mal_used                ; Block ist belegt
 cmp.l    d0,d2
 bcc      _mal_found               ; Block ist groß genug
_mal_used:
 cmpi.l   #'KROM',d1
 beq      _mal_nix
 cmpi.l   #'ANDR',d1
 bne      mem_err_8
_mal_next:
 lea      8(a0,d2.l),a0            ; nächster Block
 bra      _mal_loop
_mal_nix:
 suba.l   a0,a0
 bra.b    _mal_end

_mal_found:
 move.l   a1,(a0)                  ; neuer Eigner
 subq.l   #8,a0                    ; hier beginnt der Block
 sub.l    d0,d2
 sub.l    #16,d2                   ; mehr als 16 Bytes abspalten ?
 bls.b    _mal_ende                ; nein, lohnt sich nicht
 move.l   #'ANDR',(a0)             ; alter ist nicht letzter
 move.l   d0,mcb_len(a0)           ; neue Länge
 lea      mcb_data(a0,d0.l),a2     ; a2 = neuer Block
 move.l   a2,-(sp)
 move.l   d1,(a2)+                 ; magic kopieren
 move.l   d2,(a2)+                 ; Länge des abgespaltenen
 clr.l    (a2)+                    ; neuer Block ist frei
 move.l   a0,(a2)+                 ; Zeiger auf vorherigen Block
 cmpi.l   #'ANDR',d1
 bne.b    _mal_nonext              ; folgt kein nächster Block
 move.l   (sp),mcb_prev(a2,d2.l)   ; Zeiger auf dessen vorherigen
_mal_nonext:
 addq.l   #4,sp
_mal_ende:
 tst.w    (sp)                     ; Limitierung ?
 beq.b    _mal_end                 ; nein
 tst.l    p_mem(a1)
 bmi.b    _mal_end
 moveq    #mcb_data,d0
 add.l    mcb_len(a0),d0
 sub.l    d0,p_mem(a1)             ; Bruttogröße des Blocks abziehen
 bcc.b    _mal_end
 clr.l    p_mem(a1)                ; nicht unter 0 treiben
_mal_end:
 move.w   (sp)+,d1
 move.l   a0,d0
 rts


     IFNE FALCON
**********************************************************************
*
* EQ/NE a0 = d0 = MCB *_malloc_last(d0 = long amount, a0 = MCB *list)
*
*  Rückgabe d0 = 0L, wenn kein passender Block da, sonst a0 = MCB *
*  "Last fit"- Strategie (für Allozierung des Bildschirmspeichers).
*  Keine Speicherbegrenzung.
*

_malloc_last:
 suba.l   a1,a1                    ; noch keinen Block gefunden
 move.l   (a0),d1
 beq      _mll_nix                 ; Liste ist leer

 move.l   d1,a0
_mll_loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 tst.l    (a0)
 bne.b    _mll_used                ; Block ist belegt
 cmp.l    d0,d2
 bcs.b    _mll_used
 move.l   a0,a1                    ; Block ist groß genug
_mll_used:
 cmpi.l   #'KROM',d1
 beq      _mll_nix
 cmpi.l   #'ANDR',d1
 bne      mem_err_8
_mll_next:
 lea      8(a0,d2.l),a0            ; nächster Block
 bra      _mll_loop
_mll_nix:
 move.l   a1,d1                    ; wurde ein Block gefunden ?
 bne.b    _mll_found               ; ja!
 moveq    #0,d0
 rts

_mll_found:
 move.l   a1,a0
 subq.l   #8,a0                    ; hier beginnt der Block
 move.l   mcb_len(a0),d2           ; Nettolänge des Blocks
 sub.l    d0,d2                    ; Gewünschte Blocklänge
 sub.l    #16,d2                   ; mehr als 16 Bytes abspalten ?
 bls.b    _mll_set                 ; nein, lohnt sich nicht, allozieren
 move.l   d2,mcb_len(a0)           ; Block verkleinern
 lea      mcb_data(a0,d2.l),a1     ; a1 = neuer Block
 move.l   mcb_magic(a0),mcb_magic(a1)
 move.l   #'ANDR',mcb_magic(a0)    ; Block ist nicht mehr letzter
 move.l   d0,mcb_len(a1)           ; mcb_len
 move.l   a0,mcb_prev(a1)
 cmpi.l   #'ANDR',mcb_magic(a1)    ; Neuer Block ist letzter ?
 bne.b    _mll_nl                  ; ja !
 move.l   a1,mcb_data+mcb_prev(a1,d0.l) ; neuer mcb_prev
_mll_nl:
 move.l   a1,a0
_mll_set:
 move.l   #ur_pd,mcb_owner(a0)     ; Block allozieren
 move.l   a0,d0
 rts
     ENDIF


**********************************************************************
*
* long Memxavail( d1 = int mode, a1 = PD *pd )
*
* mode == 0: nur ST-RAM
*         1: nur FastRAM
*         2: lieber ST-RAM
*         3: lieber FastRAM
*
* Bit 13:      nolimit
*

Memxavail:
 move.w   d1,-(sp)                 ; Modus merken
 andi.b   #3,d1
 bne.b    mxavail_w1
 bsr.b    mxavail_st
 bra.b    mxavail_ende
mxavail_w1:
 subq.b   #1,d1
 bne.b    mxavail_w2
 bsr.b    mxavail_tt
 bra.b    mxavail_ende
mxavail_w2:
 bsr.b    mxavail_tt               ; erst TT
 move.l   d0,-(sp)
;move.l   a1,a1                    ; PD
 bsr.b    mxavail_st               ; dann ST
 move.l   (sp)+,d1
 cmp.l    d1,d0
 bcc.b    mxavail_ende
 move.l   d1,d0
mxavail_ende:
 btst     #5,(sp)                  ; nolimit ?
 bne.b    mxavail_rts              ; kein, kein p_mem prüfen
 cmp.l    p_mem(a1),d0
 bls.b    mxavail_rts
 move.l   p_mem(a1),d0
mxavail_rts:
 addq.l   #2,sp
;    andi.w    #$fffc,d0           ; ggf. runden!!!
 rts


mxavail_tt:
 movem.l  a5/d7,-(sp)
 lea      (mem_root+8).w,a5
 moveq    #0,d7                    ; Maximum
mxav_tt_loop:
 move.l   (a5),d0
 beq.b    mxav_ende
;move.l   a1,a1
 move.l   a5,a0
 bsr.b    _Memavail
 addq.l   #4,a5
 cmp.l    d0,d7
 bhi.b    mxav_tt_loop             ; nächste Liste
 move.l   d0,d7
 bra.b    mxav_tt_loop
mxav_ende:
 move.l   d7,d0
 movem.l  (sp)+,a5/d7
mxav_rts:
 rts


**********************************************************************
*
* long _Memavail( a0 = MCB *list)
* long mxavail_st( void )
*
* ändert nicht a1
*

mxavail_st:
 lea      mem_root.w,a0
_Memavail:
 moveq    #0,d0                    ; bisheriges Maximum
 move.l   (a0),d1
 beq      mavl_ende
 move.l   d1,a0
mavl_loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 cmpi.l   #'ANDR',d1
 beq.b    mavl_isnxt
 cmpi.l   #'KROM',d1
 bne      mem_err_8
 tst.l    (a0)
 bne.b    mavl_ende                ; Block belegt
 cmp.l    d2,d0
 bcc      mavl_ende
 move.l   d2,d0
 bra      mavl_ende
mavl_isnxt:
 tst.l    (a0)+
 bne.b    mavl_next                ; Block belegt
 cmp.l    d2,d0
 bcc      mavl_next
 move.l   d2,d0
mavl_next:
 lea      4(a0,d2.l),a0            ; nächster Block
 bra      mavl_loop
mavl_ende:
 rts


     IFNE FALCON

**********************************************************************
*
* long Srealloc( long size)
*
* size == -1L: maximal mögliche Größe ermitteln
* sonst:       alten Block freigeben, neuen allozieren
*
* => NULL      Fehler
*    sonst     Adresse des Puffers
*

Srealloc:
 movem.l  a6/d7/d6,-(sp)
 move.l   d0,d7                    ; d7 = neue Länge
 addq.l   #1,d0
 beq.b    sra_nom1
 addi.l   #259,d7
 andi.w   #$fffc,d7                ; Langwortgrenze
sra_nom1:
; zunächst prüfen, ob genügend Speicher frei ist
 lea      mem_root.w,a6
 moveq    #0,d6                    ; bisheriges Maximum
 move.l   (a6),d1
 beq      sra_endloop
 move.l   d1,a6
sra_loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 cmpi.l   #'ANDR',mcb_magic(a6)
 beq.b    sra_isnxt
; dies ist der letzte Block
 tst.l    mcb_owner(a6)
 bne.b    sra_endloop              ; Block belegt
 move.l   a6,a0
 bsr      sra_blen                 ; Blocklänge ermitteln
 cmp.l    d0,d6
 bcc      sra_endloop
 move.l   d0,d6
 bra      sra_endloop
sra_isnxt:
 tst.l    mcb_owner(a6)
 bne.b    sra_next                 ; Block belegt
 move.l   a6,a0
 bsr      sra_blen                 ; Blocklänge ermitteln
 cmp.l    d0,d6
 bcc      sra_next
 move.l   d0,d6
sra_next:
 add.l    mcb_len(a6),a6
 lea      mcb_data(a6),a6          ; nächster Block
 bra      sra_loop
sra_endloop:
 cmp.l    scrbuf_len,d6
 bhi.b    sra_w1
 move.l   scrbuf_len,d6
sra_w1:
; nachsehen, ob Nachfragemodus
 move.l   d6,d0
 subi.l   #256,d0
 cmpi.l   #-1,d7
 beq      sra_ende
; nachsehen, ob genügend Speicher frei ist
 moveq    #0,d0
 cmp.l    d6,d7
 bhi      sra_ende                 ; nicht genügend frei
; alten Block einfach freigeben
 suba.l   a1,a1                    ; kein PD
 move.l   scrbuf_adr,a0
 bsr      Mxfree                   ; versuchsweise Block freigeben
 tst.l    d0
 bne      mem_fatal_err            ; ?? Fehler ??
; neuen Block allozieren
 lea      mem_root.w,a0
 move.l   d7,d0
 bsr      _malloc_last
 tst.l    d0
 beq      mem_fatal_err            ; ?? Fehler ??
 move.l   d0,a0
 addi.l   #mcb_data,d0
 move.l   d0,scrbuf_adr
 move.l   mcb_len(a0),scrbuf_len
sra_ende:
 movem.l  (sp)+,a6/d7/d6
 rts

*
* Ermittle Blockgröße des freien Blocks <a0>, inklusive ggf. davor oder da-
* hinter liegender Bildschirmspeicher
*

sra_blen:
 move.l   mcb_len(a0),d0
 move.l   scrbuf_adr,a2
 lea      -mcb_data(a2),a2         ; MCB des Bildschirmspeichers
 cmp.l    mcb_prev(a0),a2
 bne.b    srab_weiter              ; kein Bildschirmspeicher davor
; Bildschirmspeicher liegt davor
 add.l    mcb_len(a2),d0           ; Bildschirmspeicher addieren
 addi.l   #mcb_data,d0             ; ein MCB fällt weg
 tst.l    mcb_prev(a2)             ; davor noch ein Block ?
 beq.b    srab_ende                ; nein
 move.l   mcb_prev(a2),a2
 tst.l    mcb_owner(a2)            ; dieser frei ?
 bne.b    srab_ende                ; nein
 add.l    mcb_len(a2),d0           ; Blocklänge addieren
 addi.l   #mcb_data,d0             ; ein weiterer MCB fällt weg
 rts
srab_weiter:
 cmpi.l   #'KROM',mcb_magic(a0)    ; letzter Block ?
 beq.b    srab_ende                ; ja, Ende
 lea      mcb_data(a0,d0.l),a0     ; nächster Block
 cmp.l    a0,a2                    ; ist Bildschirmspeicher ?
 bne.b    srab_ende                ; nein
; Bildschirmspeicher liegt dahinter
 add.l    mcb_len(a2),d0           ; Bildschirmspeicher addieren
 addi.l   #mcb_data,d0             ; ein MCB fällt weg
 cmpi.l   #'ANDR',mcb_magic(a2)    ; folgt weiterer Block ?
 bne.b    srab_ende                ; nein
 add.l    mcb_len(a2),a2
 lea      mcb_data(a2),a2
 tst.l    mcb_owner(a2)
 bne.b    srab_ende
 add.l    mcb_len(a2),d0
 addi.l   #mcb_data,d0             ; ein MCB fällt weg
srab_ende:
 rts
     ENDIF


**********************************************************************
*
* long Maddalt( a0 = void *start, d0 = long size)
*

Maddalt:
 add.l    d0,a0                    ; a0 = Blockende
 sub.l    #16,d0                   ; d0 = Netto-Blocklänge
 bcs      mada_err                 ; Block kleiner als 16 Bytes
 btst     #0,d0
 bne      mada_err                 ; Blocklänge ungerade

* 1. Versuch: Blöcke verschmelzen

 lea      (mem_root+8).w,a1        ; TT-RAM-Blöcke (mem_root+4 ist -1L)
mada_loop:
 tst.l    (a1)
 beq.b    mada_neu                 ; Listendende, neue Liste erstellen
 bmi.b    mada_nxt
 cmp.l    (a1),a0                  ; neues Blockende == alter Blockanfang ?
 bne.b    mada_weiter

; neuen Block vorn einklinken
 move.l   d1,(a1)                  ; neuen Blockanfang setzen
 move.l   d1,mcb_prev(a0)          ; vor nächsten setzen
 move.l   d1,a1
 move.l   #'ANDR',(a1)+            ; mcb_magic: kein weiterer Block
 move.l   d0,(a1)+                 ; mcb_len  : Nettolänge
 clr.l    (a1)+                    ; mcb_owner: unbenutzt
 clr.l    (a1)                     ; mcb_prev : kein vorheriger Block
 tst.l    mcb_owner(a0)            ; nächster Block frei ?
 bne.b    mada_ende                ; nein, Ende
 lea      -12(a1),a1
 bra.b    mada_melt

mada_weiter:
 cmp.l    MEMLEN_OFFS(a1),d1       ; neuer Blockanfang == altes Blockende ?
/*
 cmp.l    mem_top-mem_root(a1),d1  ; neuer Blockanfang == altes Blockende ?
*/
 bne.b    mada_nxt

; neuen Block hinten einklinken
 move.l   a0,MEMLEN_OFFS(a1)       ; neues Blockende setzen
/*
 move.l   a0,mem_top-mem_root(a1)  ; neues Blockende setzen
*/
 move.l   (a1),a0                  ; alter Blockanfang
 bsr      last_block               ; letzten Block ermitteln (ändert nur a0)
 move.l   #'ANDR',(a0)             ; nicht mehr letzter Block
 move.l   d1,a1
 move.l   #'KROM',(a1)+
 move.l   d0,(a1)+                 ; Nettolänge
 clr.l    (a1)+                    ; kein owner
 move.l   a0,(a1)                  ; vorheriger Block
 tst.l    mcb_owner(a0)
 bne.b    mada_ende                ; vorheriger Block ist belegt
 lea      -12(a1),a1
 exg      a1,a0
mada_melt:
 bsr      melt_mcbs
 bra      mada_ende

mada_nxt:
 addq.l   #4,a1
 bra.b    mada_loop

* 2. Versuch: Neuen Block einrichten

mada_neu:
 cmpa.l   #(mem_root+60).w,a1
 bcc.b    mada_err                 ; keine Liste mehr frei
 move.l   d1,a2
 move.l   a2,(a1)                  ; Block in Liste eintragen
 move.l   a0,MEMLEN_OFFS(a1)       ;    ebenso das Speicherende
/*
 move.l   a0,mem_top-mem_root(a1)  ;    ebenso das Speicherende
*/
 move.l   #'KROM',(a2)+            ; mcb_magic: kein weiterer Block
 move.l   d0,(a2)+                 ; mcb_len  : Nettolänge
 clr.l    (a2)+                    ; mcb_owner: unbenutzt

 clr.l    (a2)                     ; mcb_prev : kein vorheriger Block
mada_ende:
 moveq    #0,d0
 rts
mada_err:
 moveq    #ENSMEM,d0               ; keine Liste frei
 rts


**********************************************************************
*
* void *Mxalloc(d0 = long size, d1 = int mode, a1 = PD *pd)
*
* mode == 0: nur ST-RAM
*         1: nur FastRAM
*         2: lieber ST-RAM
*         3: lieber FastRAM
*
* (Bit 4-7:    MiNT: Speicherschutz-Modi)
* Bit 13:      nolimit
* Bit 14:      dontfree
*

Mxalloc:
* Korrektur auf Langwortgrenze
 addq.l   #1,d0
 beq      Memxavail
 addq.l   #2,d0
 andi.w   #$fffc,d0
* Modus
 move.w   d1,d2                    ; d2 ist Moduswort, Bit 14: dontfree
                                   ;                   Bit 13: nolimit
 andi.b   #3,d1
 beq.b    mxalloc_st               ; nur ST-RAM
 subq.b   #1,d1
 beq.b    mxalloc_tt               ; nur FastRAM
 subq.b   #1,d1
 beq.b    mxal_st_tt
* Modus 3: TT,ST
 move.l   d0,-(sp)
 bsr.b    mxalloc_tt               ; zunächst TT, ändert nicht a1
 move.l   (sp)+,a2
 bne.b    mxal_rts                 ; gefunden
 move.l   a2,d0                    ; d0 zurück
 bra      mxalloc_st
mxal_st_tt:
* Modus 2: ST,TT
 move.l   d0,-(sp)
 bsr.b    mxalloc_st               ; zunächst ST, ändert nicht a1
 move.l   (sp)+,a2
 bne.b    mxal_rts
 move.l   a2,d0
;bra      mxalloc_tt               ; dann TT

mxalloc_tt:
 moveq    #1,d1                    ; limitflag
 movem.l  d7/a5,-(sp)
 lea      (mem_root+8).w,a5
 move.l   d0,d7
mxal_tt_loop:
 move.l   (a5),d0
 beq.b    mxal_ende
;move.l   a1,a1                    ; PD *
 move.l   a5,a0
 move.l   d7,d0
 bsr.b    _Malloc                  ; ändert nicht a1/d1
 addq.l   #4,a5
 beq.b    mxal_tt_loop             ; nächste Liste
mxal_ende:
 movem.l  (sp)+,d7/a5
mxal_rts:
 rts

* ändern nicht a1

mxalloc_st:
 lea      mem_root.w,a0
_Malloc:
 move.w   d2,-(sp)                 ; Modusbits
 btst     #13,d2
 seq      d1
 ext.w    d1                       ; limitflag
;move.l   a1,a1                    ; PD
 bsr      _malloc                  ; ändert nicht a1/d1
 move.w   (sp)+,d2
 tst.l    d0
 beq.b    _Mal_ende                ; NULL- Pointer
 btst     #14,d2                   ; Bit 14: "dontfree"
 beq.b    _Mal_ok
 bset     #7,mcb_owner(a0)         ; don't free !!!
_Mal_ok:
 lea      mcb_data(a0),a0          ; Speicheradresse
 move.l   a0,d0
_Mal_ende:
 rts


**********************************************************************
*
* PUREC LONG Mxfree( void *memblk, PD *pd )
*
* <pd> darf NULL sein, dann wird kein p_mem modifiziert
*

Mxfree:

     DEB  'Mxfree'

 move.l   a2,-(sp)                 ; wegen PUREC-Konvention
 move.l   a1,-(sp)                 ; PD merken
 move.l   a0,d0
 andi.b   #3,d0
 bne.b    mfree_eimba              ; keine Langwortadresse
 lea      -mcb_data(a0),a0         ; MCB ermitteln
 lea      mem_root.w,a1
mfree_listloop:
 cmpa.l   (a1),a0
 bcs.b    mfree_nxtlist            ; MCB unterhalb des Blockbeginns
 cmpa.l   MEMLEN_OFFS(a1),a0
/*
 cmpa.l   mem_top-mem_root(a1),a0
*/
 bcs.b    mfree_free               ; MCB unterhalb des Blockendes => OK
mfree_nxtlist:
 addq.l   #4,a1
 tst.l    (a1)
 bgt.b    mfree_listloop
 bmi.b    mfree_nxtlist
 cmpa.w   #1,a0
 beq      mfree_ret0               ; Mfree(1L) ist OK
mfree_eimba:
 moveq    #EIMBA,d0
 bra      mfree_ende

mfree_free:

* Test auf shared memory blocks

 move.l   (sp),d0
 beq.b    mfree_no_shm             ; kein PD angegeben
 cmpi.l   #$1000,mcb_owner(a0)     ; kann es ein shared block sein ?
 bcc.b    mfree_no_shm             ; nein, ist nicht
 move.l   d0,a1
 move.l   p_procdata(a1),d0
 beq.b    mfree_eimba              ; ???
 move.l   d0,a1
 move.l   pr_memlist(a1),d0
 beq.b    mfree_eimba              ; keine memlist ???
 move.l   d0,a1
 move.l   (a1)+,d2                 ; Länge der Liste
 lea      mcb_data(a0),a2
mfree_shm_loop:
 subq.l   #1,d2
 bcs.b    mfree_eimba              ; Block nicht gefunden
 cmpa.l   (a1)+,a2
 bne.b    mfree_shm_loop           ; nächster Block
 clr.l    -(a1)                    ; Block austragen
 subq.l   #1,mcb_owner(a0)         ; Referenzzähler verkleinern
 bne.b    mfree_ret0               ; ist noch nicht 0
 move.l   (sp),mcb_owner(a0)       ; PD ist jetzt exklusiver Eigner

* Block tatsächlich freigeben

mfree_no_shm:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 suba.l   a2,a2                    ; per Default kein Nachfolger
 cmpi.l   #'KROM',d1
 beq      mfree_ok
 cmpi.l   #'ANDR',d1
 bne.b    mfree_eimba              ; return(EIMBA)
 lea      8(a0,d2.l),a2            ; a2 = Nachfolger
mfree_ok:
 tst.l    (a0)                     ; Block frei ?
 beq.b    mfree_eimba              ; ja, return(EIMBA)
 clr.l    (a0)                     ; Block freigeben

 move.l   (sp),d0
 beq.b    mfree_no_ovl             ; kein PD angegeben
 move.l   d0,a1                    ; PD
 add.l    #mcb_data,d2
 add.l    d2,p_mem(a1)             ; Speicher zum Limit addieren
 bcc.b    mfree_no_ovl             ; kein Überlauf
 move.l   #$ffffffff,p_mem(a1)     ; Überlauf: Maximum setzen

mfree_no_ovl:
 subq.l   #8,a0                    ; a0 wieder auf Blockanfang
* ggf. mit Vorgänger verschmelzen
 move.l   mcb_prev(a0),d0
 beq.b    mfree_no_prev
 move.l   d0,a1                    ; a1 = Vorgänger
 tst.l    mcb_owner(a1)
 bne.b    mfree_no_prev            ; Vorgänger ist belegt
 move.l   a2,-(sp)                 ; Nachfolger merken
 move.l   a1,-(sp)                 ; Vorgänger merken
 bsr.b    melt_mcbs
 move.l   (sp)+,a0                 ; Vorgänger ist jetzt aktueller
 move.l   (sp)+,a2
mfree_no_prev:
* ggf. mit Nachfolger verschmelzen
 move.l   a2,d0
 beq.b    mfree_ende               ; kein Nachfolger, return(0L)
 tst.l    mcb_owner(a2)
 bne.b    mfree_ret0               ; Nachfolger belegt
 move.l   a0,a1
 move.l   a2,a0
 bsr.b    melt_mcbs
mfree_ret0:
 moveq    #0,d0
mfree_ende:
 addq.l   #4,sp
 move.l   (sp)+,a2                 ; wegen PUREC-Konvention

     DEB  'END Mxfree'

 rts


**********************************************************************
*
* void melt_mcbs(a0 = MCB *blk, a1 = MCB *prev_blk)
*
* <blk> und <prev_blk> sind freie Blöcke, die übereinander liegen
* Die beiden Blöcke werden verschmolzen
* Gibt Nachfolger von <blk> zurück
*

melt_mcbs:
 move.l   (a0),d1                  ; d1 = magic
 clr.l    (a0)+                    ; magic sicherheitshalber löschen
 moveq    #mcb_data,d2
 add.l    (a0)+,d2                 ; d2 = len (Brutto)
 cmpi.l   #'KROM',d1
 beq.b    ml_no_nxt
 cmpi.l   #'ANDR',d1
 bne      mem_err_8
 move.l   a1,mcb_prev-8(a0,d2.l)   ; Rückw.zeiger im nächsten Block umsetzen
ml_no_nxt:
 move.l   d1,(a1)+                 ; magic in Vorgänger kopieren
 add.l    d2,(a1)                  ; Länge auf unteren Block addieren
 rts


**********************************************************************
*
* long Mxshrink(a0 = char *memblock, d0 = long size, a1 = PD *pd)
*
* Im wesentlichen aus KAOS 1.2, also gegenüber TOS 1.4 noch folgendes:
*  - Es kann ein Block vergrößert werden (wie in MS-DOS) !!
*  - Wird -1L als Größe übergeben, wird die größtmögliche Größe
*    des Speicherblocks zurückgegeben.
*  - Bei neuer Größe 0L, bringt TOS 1.4 den Block sowohl in die freelist
*    als auch in die alloc-list, was tödlich ist und daher nicht
*    übernommen wurde.
* Neu gegenüber KAOS 1.2:
*  - Bei neuer Größe 0L einfach Block freigeben
*
* a1 = 0:      kein Limit
*

Mxshrink:

     DEB  'Mxshrink'

 tst.l    d0                       ; auf 0 Bytes verkürzen ?
 beq      Mxfree                   ; ja, einfach freigeben
 movem.l  d6/d7/a3/a5/a6,-(sp)
 move.l   d0,d7                    ; d7 = neue Blocklänge
 move.l   a1,a3                    ; PD
 lea      -mcb_data(a0),a6         ; a6 = MCB *
 cmpa.l   #$ff000000,a6
 bhi      msh_eimba                ; für TT
;cmp.l    _memtop,a6
;bhi      msh_eimba                ; return(EIMBA)
 move.l   (a6)+,d1                 ; d1 = mcb_magic
 move.l   (a6)+,d2                 ; d2 = mcb_len
 tst.l    (a6)                     ; mcb_owner
 beq      msh_eimba                ; Block ist frei
 subq.l   #8,a6                    ; a6 wieder auf Blockanfang
 move.l   d2,d6
 suba.l   a5,a5                    ; per Default kein Nachfolger
 cmpi.l   #'KROM',d1
 beq.b    msh_ok1                  ; ist letzter Block
 cmpi.l   #'ANDR',d1
 move.l   a6,a0
 bne      mem_err
 lea      mcb_data(a6,d2.l),a5     ; a5 = nächster MCB
 tst.l    mcb_owner(a5)
 bne.b    msh_ok1                  ; Nachfolger belegt
 add.l    #mcb_data,d6
 add.l    mcb_len(a5),d6           ; d6 = maximale mögliche Größe
msh_ok1:
 addq.l   #1,d7
 beq      msh_avail
 addq.l   #2,d7
 andi.w   #$fffc,d7                ; Langwortgrenze!

 cmp.l    d2,d7
 beq      msh_ok                   ; keine Veränderung
 bcs.b    msh_shrink               ; Blockverkleinerung
 btst     #5,(config_status+3).w
 bne      msh_egsbf                ; im TOS- Modus Blockvergrößerung nicht
                                   ; erlaubt

* Blockvergrößerung (nur unter KAOS)

 cmp.l    d6,d7
 bhi      msh_egsbf                ; Nachfolgerblock zu klein

* Die bisherige Größe + neue Größe ist groß genug für die Anforderung
* Die Blöcke werden verschmolzen (der freie in a5[] mit dem in a6[])

 move.l   a3,d0                    ; limit ?
 beq.b    msh_scrnmgr              ; nein, Speicher nicht beschränken
 tst.l    p_mem(a3)
 bge      msh_egsbf                ; nur Blockvergrößerung, wenn Speicher
                                   ; unbeschränkt

msh_scrnmgr:
 move.l   a6,a1
 move.l   a5,a0
 bsr      melt_mcbs

* ein Teil unseres Speicherblocks abspalten

msh_shrink:
 move.l   mcb_len(a6),d2
 sub.l    d7,d2
 subi.l   #mcb_data,d2
 bls      msh_ok                   ; es blieben <= 16 Bytes frei
 lea      mcb_data(a6,d7.l),a0     ; Beginn eines neuen Blocks
 move.l   a5,d0
 beq      msh_weiter               ; Nachfolger existiert nicht
 move.l   a0,mcb_prev(a5)          ; neuen Block als Vorgänger einsetzen
msh_weiter:
 move.l   a6,a1
 move.l   (a6),(a0)+               ; magic vom Vorgänger kopieren
 move.l   #'ANDR',(a1)+            ; Vorgänger kann nicht letzter sein
 move.l   d7,(a1)+                 ; neue Länge
 move.l   d2,(a0)+                 ; Länge des neuen Blocks
 move.l   act_pd,(a0)+             ; neuer Block gehört zunächst uns
 move.l   a6,(a0)+                 ; mcb_prev einsetzen
 move.l   a3,a1                    ; PD
;move.l   a0,a0
 bsr      Mxfree                   ; neuen Block freigeben
msh_ende:
 movem.l  (sp)+,a6/a5/a3/d7/d6

     DEB  'END Mxshrink'

 rts
msh_eimba:
 moveq    #EIMBA,d0
 bra.b    msh_ende
msh_egsbf:
 moveq    #EGSBF,d0
 bra.b    msh_ende
msh_ok:
 moveq    #0,d0
 bra.b    msh_ende

msh_avail:
 move.l   a3,d0                    ; Speicher beschränken ?
 beq.b    msh_ende2                ; nein, Speicher nicht beschränken
 tst.l    p_mem(a3)
 bmi.b    msh_ende2
 move.l   mcb_len(a6),d6           ; Block darf nicht vergrößert werden
msh_ende2:
 move.l   d6,d0
 bra.b    msh_ende


**********************************************************************
*
* long Mgetlen(a0 = void *memadr)
*

Mgetlen:
 move.l   mcb_len-mcb_data(a0),d0
 rts


**********************************************************************
*
* long Mzombie(a0 = PD *process, a1 = PD *new_owner)
*
*  Ändert den Eigentümer der Basepage des Prozesses <process>. Neuer
*  Eigentümer wird <new_owner> (der ur_pd). Der Block wird auf
*  128 Bytes verkürzt.
*
*  Wenn die Basepage "exklusiv" ist, wird <new_owner> einfach der
*  neue Eigner. Wenn die Basepage "shared" ist, wird sie
*  aus der Liste von <process> ausgetragen, aber nicht freigegeben.
*  Der Referenzzähler ist dann quasi "eine Nummer zu groß".
*

Mzombie:
 cmpi.l   #$0fff,mcb_owner-mcb_data(a0) ; kann es ein shared block sein ?
 bcc.b    mzombie_no_shm                ; nein, ist nicht
 addq.l   #1,mcb_owner-mcb_data(a0)     ; Referenzzähler erhöhen (!)
 movem.l  a0/a1,-(sp)
 move.l   a0,a1                         ; PD
;move.l   a0,a0                         ; memblk
 bsr      Mxfree
 movem.l  (sp)+,a0/a1
 bra.b    mzombie_both
mzombie_no_shm:
 move.l   a1,mcb_owner-mcb_data(a0)
mzombie_both:
;move.l   a1,a1                         ; PD
 move.l   #128,d0                       ; size
;move.l   a0,a0                         ; memblk
 bra      Mxshrink


**********************************************************************
*
* void Mfzombie(a0 = PD *process, a1 = PD *new_pd)
*
*  Gibt einen mit <Mzombie()> manipulierten Block frei.
*  <new_pd> ist der Urprozeß, dem der Block gehört.
*

Mfzombie:
 cmpi.l   #$0fff,mcb_owner-mcb_data(a0) ; kann es ein shared block sein ?
 bcc.b    mfzombie_no_shm               ; nein, ist nicht
 subq.l   #1,mcb_owner-mcb_data(a0)     ; Referenzzähler verkleinern
 bne.b    mfzombie_ende                 ; noch nicht Null
 move.l   a1,mcb_owner-mcb_data(a0)     ; ist Null, als exklusiv setzen
mfzombie_no_shm:
;move.l   a1,a1
;move.l   a0,a0
 bra      Mxfree                        ; einfach freigeben
mfzombie_ende:
 rts


**********************************************************************
*
* long Mchgown(a0 = void *memadr, a1 = PD *process)
*
*  Ändert Eigentümer des Speicherblocks ab (Benutzer-) adresse <memadr>
*  <process> == -1  :    Nur Eigner ermitteln
*               -2  :    Block -> dontfree, liefere Nettolänge
*

Mchgown:
 lea      -mcb_data(a0),a0         ; MCB ermitteln
 moveq    #EIMBA,d0
 move.l   (a0)+,d1
 cmpi.l   #'ANDR',d1
 beq.b    chgo_ok
 cmpi.l   #'KROM',d1
 bne.b    chgo_ende                ; return(EIMBA)
chgo_ok:
 move.l   (a0)+,d1                 ; Länge
 tst.l    (a0)
 beq      chgo_ende                ; return(EIMBA)
 cmpa.l   #-2,a1
 beq.b    chgo_setshm
 move.l   (a0),d0                  ; alter Eigner
 cmpa.l   #-1,a1
 beq.b    chgo_ende                ; PD ist -1L, Eigner zurückgeben
 move.l   a1,(a0)
 moveq    #0,d0                    ; ok
chgo_ende:
 rts
chgo_setshm:
 bset     #7,(a0)                  ; don't free
 move.l   d1,d0
 rts


**********************************************************************
*
* d0 = long pd_used_mem( a0 = PD *pd )
*
* Gibt zurück, wieviel Speicher vom Prozeß <pd> belegt wird.
* Wenn <pd> == NULL, wird der freie Speicher berechnet.
* Rückgabe 0L, falls Prozeß nicht existiert.
* Blöcke mit "dontfree"-Bit werden nicht berücksichtigt.
*
* Berechnet exklusive und shared blocks
*

pd_used_mem:
 move.l   a0,-(sp)
 bsr.b    get_n_excl               ; erst exklusive Blöcke
 move.l   (sp)+,a0
 move.l   a0,d1
 beq.b    pdusm_ende               ; freier Speicher
 move.l   p_procdata(a0),d1
 beq.b    pdusm_ende               ; keine PROCDATA
 move.l   d1,a0
 move.l   pr_memlist(a0),d1
 beq.b    pdusm_ende               ; keine shared blocks
 move.l   d1,a0
 move.l   (a0)+,d2                 ; Tabellenlänge
pdusm_loop:
 subq.l   #1,d2
 bcs.b    pdusm_ende
 move.l   (a0)+,d1
 beq.b    pdusm_loop               ; freier Eintrag
 move.l   d1,a1
 add.l    mcb_len-mcb_data(a1),d0  ; gültiger Eintrag
 bra.b    pdusm_loop
pdusm_ende:
 rts


**********************************************************************
*
* d0/d1 = long get_n_excl( a0 = PD *pd )
*
* Gibt zurück, wieviel Speicher vom Prozeß <pd> belegt wird.
* Wenn <pd> == NULL, wird der freie Speicher berechnet.
* Rückgabe 0L, falls Prozeß nicht existiert.
* Blöcke mit "dontfree"-Bit werden nicht berücksichtigt.
*
* Neu:    d1.l gibt die Anzahl der Blöcke zurück, die von einem
*         Prozeß belegt werden.
*

get_n_excl:
 move.l   a0,a1
 lea      mem_root.w,a2            ; Tabelle der Speicherlisten
 moveq    #0,d0                    ; belegter Speicher
 clr.l    -(sp)                    ; Anzahl Blöcke
pmu_2_loop:
 move.l   (a2)+,d1
 beq      pmu__ende                ; Tabellenende
 bmi.b    pmu_2_loop               ; ungültiger Eintrag
 move.l   d1,a0
pmu__loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 cmpi.l   #'ANDR',d1
 beq.b    pmu__isnxt
 cmpi.l   #'KROM',d1
 bne      mem_err_12               ; Speicherfehler!
 cmp.l    (a0),a1                  ; unser Block (bzw. leer bei SCRENMGR) ?
 bne      pmu_2_loop               ; nein, nächste Liste
 add.l    d2,d0
 addq.l   #1,(sp)
 bra      pmu_2_loop               ; nächste Liste
pmu__isnxt:
 cmp.l    (a0)+,a1
 bne.b    pmu__next                ; Block nicht unserer
 add.l    d2,d0
 addq.l   #1,(sp)
pmu__next:
 lea      4(a0,d2.l),a0            ; nächster Block
 bra      pmu__loop
pmu__ende:
 move.l   (sp)+,d1                 ; Anzahl Blöcke
 rts


**********************************************************************
*
* void excl2shared( a0 = PD *pd, a1 = void **list )
*
* Wandelt alle exklusiven Blöcke des Prozesses um und trägt sie in
* die Tabelle <list> ein, die groß genug sein muß.
* Blöcke mit "dontfree"-Bit werden nicht berücksichtigt.
*

excl2shared:
 move.l   a3,-(sp)
 move.l   a1,a3
 move.l   a0,a1
 lea      mem_root.w,a2            ; Tabelle der Speicherlisten
e2s_2_loop:
 move.l   (a2)+,d1
 beq      e2s__ende                ; Tabellenende
 bmi.b    e2s_2_loop               ; ungültiger Eintrag
 move.l   d1,a0
e2s__loop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 cmpi.l   #'ANDR',d1
 beq.b    e2s__isnxt
;cmpi.l   #'KROM',d1
;bne      mem_err_12               ; Speicherfehler!
 cmp.l    (a0),a1                  ; unser Block (bzw. leer bei SCRENMGR) ?
 bne      e2s_2_loop               ; nein, nächste Liste
 move.l   #1,(a0)                  ; als Eigner "1" eintragen
 addq.l   #8,a0                    ; owner und prev überspringen
 move.l   a0,(a3)+                 ; Block merken
 bra      e2s_2_loop               ; nächste Liste
e2s__isnxt:
 cmp.l    (a0),a1
 bne.b    e2s__next                ; Block nicht unserer
 move.l   #1,(a0)                  ; als Eigner "1" eintragen
 addq.l   #8,a0                    ; owner und prev überspringen
 move.l   a0,(a3)+                 ; Block merken
 subq.l   #8,a0
e2s__next:
 lea      8(a0,d2.l),a0            ; nächster Block
 bra      e2s__loop
e2s__ende:
 move.l   (sp)+,a3
 rts


**********************************************************************
*
* long get_n_shb( a0 = PD *pd )
*
* Zählt die Anzahl der "shared blocks" eines Prozesses.
* -> d0   Anzahl der shared blocks
*    d1   aktuelle Länge der shared block table
*

get_n_shb:
 moveq    #0,d0
 move.l   p_procdata(a0),d1
 beq.b    gnshb_ende               ; keine PROCDATA, d1 = 0
 move.l   d1,a1
 move.l   pr_memlist(a1),d1
 beq.b    gnshb_ende               ; keine shared blocks, d1 = 0
 move.l   d1,a1
 move.l   (a1)+,d1                 ; Tabellenlänge
 move.l   d1,d2
gnshb_loop:
 subq.l   #1,d2
 bcs.b    gnshb_ende
 tst.l    (a1)+
 beq.b    gnshb_loop               ; freier Eintrag
 addq.l   #1,d0                    ; gültiger Eintrag
 bra.b    gnshb_loop
gnshb_ende:
 rts


**********************************************************************
*
* void **expand_sharelist( a0 = PD *pd, d0 = LONG num)
*
* Schafft Platz für mindestens <num> neue Einträge in der
* "shared memory list" des Prozesses <PD>.
* Rückgabe ENSMEM bzw. Zeiger auf mindestens <num> freie Zeiger,
* der Speicher ist nicht initialisiert.
*

expand_sharelist:
 movem.l  d6/d7/a6/a5/a4/a3,-(sp)
 move.l   a0,a6                    ; a6 = PD
 move.l   d0,d7                    ; d7 = mum

 move.l   p_procdata(a6),a4        ; a4 = procdata
 move.l   a4,d0
 beq      expsh_err                ; ???

;move.l   a6,a0
 bsr      get_n_shb
 add.l    d0,d7                    ; + Anzahl "shared blocks"

 move.l   d1,d6                    ; Aktuelle Länge der "shared block table"
 cmp.l    d7,d6
 bcc.b    expsh_enough             ; Tabelle ist lang genug

* Tabelle ist zu kurz. Wir müssen umsortieren

 move.l   d7,d0
 addq.l   #1,d0                    ; + Eintrag für Länge
 add.l    d0,d0
 add.l    d0,d0                    ; * 4 für LONGs

 move.l   a6,a1                    ; PD
 move.w   #$6002,d1                ; ST_PREF/nolimit/dontfree
 bsr      Mxalloc
 tst.l    d0
 beq.b    expsh_err                ; nicht genügend Speicher
 move.l   d0,a5                    ; a5 = neue Liste

 move.l   a5,a3
 move.l   d7,(a3)+                 ; Länge eintragen, a3 = akt. Zeiger
 move.l   pr_memlist(a4),d0
 beq.b    expsh_no_copy            ; keine alte Tabelle

* die alte shared memory block list umkopieren und freigeben

 move.l   d0,a0                    ; alte Liste
 move.l   (a0)+,d2                 ; Tabellenlänge
expsh_loop1:
 subq.l   #1,d2
 bcs.b    expsh_endloop1
 move.l   (a0)+,d0
 beq.b    expsh_loop1              ; freier Eintrag
 move.l   d0,(a3)+                 ; gültiger Eintrag
 bra.b    expsh_loop1
expsh_endloop1:
 suba.l   a1,a1
 move.l   pr_memlist(a4),a0
 bsr      Mxfree                   ; alten Block freigeben

* den neuen Block in die PROCDATA eintragen

expsh_no_copy:
 move.l   a5,pr_memlist(a4)

 bra.b    expsh_ok

* die alte Tabelle komprimieren, a3 auf ersten freien Eintrag

expsh_enough:
 move.l   pr_memlist(a4),a5
 move.l   a5,a3
 move.l   (a3)+,d2                 ; Tabellenlänge
 move.l   d2,d0
 add.l    d0,d0
 add.l    d0,d0
 lea      0(a5,d0.l),a1            ; letzter Eintrag
expsh_loop2:
 subq.l   #1,d2
 bcs.b    expsh_ok
 move.l   (a3)+,d0
 bne.b    expsh_loop2              ; gültiger Eintrag
expsh_loop3:
 cmpa.l   a3,a1
 bcs.b    expsh_ende2              ; a1 < a3
 tst.l    (a1)                     ; gültiger Eintrag hinten ?
 bne.b    expsh_move               ; ja, umkopieren
 subq.l   #4,a1                    ; nach vorn suchen
 bra.b    expsh_loop3
expsh_move:
 move.l   (a1),-4(a3)              ; gültigen Eintrag kopieren
 clr.l    (a1)                     ; Quelle löschen
 subq.l   #4,a1                    ; a1 läuft rückwärts
 bra.b    expsh_loop2
expsh_ende2:
 subq.l   #4,a3
expsh_ok:
 move.l   a3,d0
 bra.b    expsh_ende
expsh_err:
 moveq    #ENSMEM,d0
expsh_ende:
 movem.l  (sp)+,d6/d7/a3/a4/a5/a6
 rts


**********************************************************************
*
* long mshare( a0 = PD *pd )
*
* Wandelt alle exklusiv belegten Blöcke des Prozesses um in
* "shared blocks".
*

mshare:
 move.l   a0,-(sp)

* Ermittle die notwendige Länge der "shared" Liste

;move.l   a0,a0                    ; PD
 bsr      get_n_excl
 move.l   d1,d0                    ; d0 = Anzahl Speicherblöcke
 beq.b    mshare_ok                ; keine exklusiven Blöcke

;move.l   d0,d0
 move.l   (sp),a0
 bsr      expand_sharelist
 tst.l    d0
 bmi.b    mshare_ende

 move.l   d0,a1                    ; Ziel: Platz für <d7> Einträge
 move.l   (sp),a0                  ; PD
 bsr      excl2shared              ; umwandeln

mshare_ok:
 moveq    #0,d0                    ; kein Fehler
mshare_ende:
 addq.l   #4,sp
 rts


**********************************************************************
*
* long Memshare( a0 = void *memblk, a1 = PD *pd )
*
* Wandelt einen von Prozeß <pd> belegten Speicherblock <memblk> um
* in einen "shared block" mit Referenzzähler 2 bzw. inkrementiert
* den Referenzzähler, wenn der Block bereits "shared" ist.
* Gibt die Blocklänge oder einen Fehlercode zurück.
*
* Wird für F_SETSHMBLK benötigt.
*

Memshare:
 movem.l  a5/a6,-(sp)
 move.l   a0,a5
 move.l   a1,a6                    ; a6 = PD *

 move.l   a0,d0
 andi.b   #3,d0
 bne.b    memsh_eimba              ; keine Langwortadresse
 lea      -mcb_data(a0),a0         ; MCB ermitteln

 cmpi.l   #$1000,mcb_owner(a0)     ; kann es ein shared block sein ?
 bcc.b    memsh_no_shm             ; nein, ist nicht

* Block war "shared"

 move.l   p_procdata(a6),d0
 beq.b    memsh_eimba              ; ???
 move.l   d0,a1
 move.l   pr_memlist(a1),d0
 beq.b    memsh_eimba              ; keine memlist ???
 move.l   d0,a1
 move.l   (a1)+,d2                 ; Länge der Liste
 lea      mcb_data(a0),a2
memsh_shm_loop:
 subq.l   #1,d2
 bcs.b    memsh_eimba              ; Block nicht gefunden
 cmpa.l   (a1)+,a2
 bne.b    memsh_shm_loop           ; nächster Block
 addq.l   #1,mcb_owner(a0)         ; Referenzzähler vergrößern
 bra.b    memsh_ok

* Block war exklusiv

memsh_no_shm:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 cmpi.l   #'KROM',d1
 beq      memsh_magic_ok
 cmpi.l   #'ANDR',d1
 bne.b    memsh_eimba              ; return(EIMBA)
memsh_magic_ok:
 moveq    #1,d0                    ; ein neuer Eintrag
 move.l   a6,a0                    ; PD
 bsr      expand_sharelist
 tst.l    d0
 bmi.b    memsh_ende               ; Fehler!
 move.l   d0,a0                    ; freier Platz
 move.l   a5,(a0)                       ; Block eintragen!
 move.l   #2,mcb_owner-mcb_data(a5)     ; Referenzzähler 2
memsh_ok:
 move.l   mcb_len-mcb_data(a5),d0
 bra.b    memsh_ende
memsh_eimba:
 moveq    #EIMBA,d0
memsh_ende:
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* long Memunsh( a0 = void *memblk )
*
* Dekrementiert den von Memshare() inkrementierten Referenzzähler
* des Blocks und gibt ihn ggf. frei.
*
* Wird für F_SETSHMBLK benötigt.
*

Memunsh:
 move.l   a0,d0
 andi.b   #3,d0
 bne.b    munsh_eimba              ; keine Langwortadresse
 lea      mcb_owner-mcb_data(a0),a1
 cmpi.l   #$1000,(a1)              ; kann es ein shared block sein ?
 bcc.b    munsh_eimba              ; nein, ist nicht
 subq.l   #1,(a1)
 bne.b    munsh_ok
 move.l   #ur_pd,(a1)
 suba.l   a1,a1
;move.l   a0,a0
 bra      Mxfree
munsh_eimba:
 moveq    #EIMBA,d0
 rts
munsh_ok:
 moveq    #0,d0
 rts


**********************************************************************
*
* long mfork( a0 = PD *src_pd, a1 = PD *dst_pd )
*
* Kopiert die "shared block list" für den neuen Prozeß und
* inkrementiert die Referenzzähler
*

mfork:
 movem.l  d6/d7/a3/a4/a5/a6,-(sp)
 move.l   a0,a6                    ; a6 = src
 move.l   a1,a5                    ; a5 = dst

 move.l   p_procdata(a6),d0        ; a4 = procdata
 beq.b    mfork_ok                 ; ???
 move.l   d0,a4
 move.l   pr_memlist(a4),d0
 beq.b    mfork_ok                 ; kein "shared memory"
 move.l   d0,a4                    ; a4 = Quell-Liste

 move.l   p_procdata(a5),d0        ; procdata
 beq.b    mfork_ok                 ; ???
 move.l   d0,a3                    ; a3 = procdata für neuen Prozeß

 move.l   (a4),d0                  ; Länge der alten Tabelle
 addq.l   #1,d0                    ; + Eintrag für Länge
 add.l    d0,d0
 add.l    d0,d0                    ; * 4 für LONGs

* Speicher für neue Tabelle anfordern

 move.l   a5,a1                    ; Eigner ist der neue Prozeß
 move.w   #$6002,d1                ; ST_PREF/nolimit/dontfree
 bsr      Mxalloc
 tst.l    d0
 beq.b    mfork_err                ; nicht genügend Speicher
 move.l   d0,pr_memlist(a3)        ; für neuen Prozeß
 move.l   d0,a3                    ; a3 = neue Liste

* Liste kopieren und Referenzzähler erhöhen
* Null-Elemente mit kopieren!!!

 move.l   (a4)+,d2                 ; Länge
 move.l   d2,(a3)+                 ;  einfach übernehmen
mfork_loop:
 subq.l   #1,d2
 bcs.b    mforkloop_ende
 move.l   (a4)+,d0
 move.l   d0,a1
 beq.b    mfork_invblk             ; ungültiger Eintrag
 addq.l   #1,mcb_owner-mcb_data(a1)     ; Ref.zähler erhöhen
mfork_invblk:
 move.l   a1,(a3)+
 bra.b    mfork_loop
mforkloop_ende:
 bra.b    mfork_ok

mfork_err:
 moveq    #ENSMEM,d0
 bra.b    mfork_ende
mfork_ok:
 moveq    #0,d0
mfork_ende:
 movem.l  (sp)+,d6/d7/a3/a4/a5/a6
 rts


**********************************************************************
*
* void Pfree(a0 = PD *process)
*
* gibt den Speicher zu einem Prozeß frei
* (benötigt für Freigabe von Gerätetreibern)
*

Pfree:

     DEB  'Pfree'

 movem.l  a3/a4/a5/d7,-(sp)
 move.l   a0,a5

* shared memory blocks freigeben

 move.l   p_procdata(a5),d0
 beq.b    pf_no_procdata
 move.l   d0,a0
 move.l   pr_memlist(a0),d0
 beq.b    pf_noshm
 move.l   d0,a4                    ; a4 = memlist
 move.l   a4,a3
 move.l   (a3)+,d7                 ; Länge
pf_shmloop:
 subq.l   #1,d7
 bcs.b    pf_shmloop_ende
 move.l   (a3)+,d0
 beq.b    pf_shmloop                    ; ungültiger Eintrag
 move.l   d0,a0
 subq.l   #1,mcb_owner-mcb_data(a0)
 bne.b    pf_shmloop                    ; noch nicht freigeben
 move.l   a5,mcb_owner-mcb_data(a0)     ; als exklusiv markieren
 suba.l   a1,a1
;move.l   a0,a0
 bsr      Mxfree
 bra.b    pf_shmloop
pf_shmloop_ende:
 suba.l   a1,a1
 move.l   a4,a0
 bsr      Mxfree                   ; pr_memlist freigeben
 move.l   p_procdata(a5),a0
 clr.l    pr_memlist(a0)           ; sicherheitshalber Zeiger löschen

* exclusive memory blocks freigeben

pf_noshm:
 clr.l    p_procdata(a5)           ; sicherheitshalber
pf_no_procdata:
 lea      mem_root,a4              ; Tabelle der Speicherlisten
pf_memloop2:
 move.l   (a4)+,d1                 ; Speicherliste
 bmi      pf_memloop2              ; ungültig
 beq      pf_ende                  ; ist leer, Tabellenende
 move.l   d1,a0
pf_memloop:
 move.l   (a0)+,d1                 ; d1 = magic
 move.l   (a0)+,d2                 ; d2 = len
 move.l   (a0)+,d0                 ; d0 = owner
 addq.l   #4,a0                    ; mcb_prev überspringen
 cmpi.l   #'ANDR',d1
 beq.b    pf_isnxt
 cmpi.l   #'KROM',d1
 beq.b    pf_krom
 suba.w   #12,a0
pf_do_repair:
 move.l   a0,-(sp)                 ; Adresse des MCB auf Stack UND in a0
 move.l   a5,-(sp)                 ; owner für verwaiste Blöcke
 bsr      mem_repair               ; Versuch, zu reparieren
 addq.l   #8,sp
 subq.l   #4,a4
 bra      pf_memloop2              ; gelungen, Wiederholung
pf_krom:
 cmp.l    d0,a5
 bne      pf_memloop2              ; letzter Block hatte anderen owner
 suba.l   a1,a1
;move.l   a0,a0
 bsr      Mxfree                   ; Freigabe des letzten Blocks
 bra      pf_memloop2              ; nächste Liste
pf_isnxt:
 cmp.l    d0,a5
 bne.b    pf_next
; Sicherheits- Check
 move.l   a0,a1
 add.l    d2,a1                    ; a1 = nächster Block
 cmpi.l   #'ANDR',(a1)
 beq.b    pf_do_free
 cmpi.l   #'KROM',(a1)
 beq.b    pf_do_free
 move.l   a1,a0
 bra      pf_do_repair
pf_do_free:
 suba.l   a1,a1
;move.l   a0,a0
 bsr      Mxfree                   ; Freigabe eines nicht letzten Blocks
 subq.l   #4,a4                    ; Liste nochmal durchlaufen
 bra      pf_memloop2
pf_next:
 add.l    d2,a0                    ; nächster Block
 bra      pf_memloop
pf_ende:
 movem.l  (sp)+,a3/a4/a5/d7

     DEB  'END Pfree'

 rts


**********************************************************************
*
* void *Pmemsave(a0 = PD *proc, a1 = void *excl_list[])
*
* Legt für jeden Speicherblock des Prozesses <proc> eine Kopie an,
* verkettet diese Kopien miteinander und gibt den Zeiger auf den
* ersten kopierten Block zurück.
* Die durch excl_list[] angegebenen Blöcke (Liste durch NULL
* abgeschlossen) werden nicht kopiert.
*
* wird für Pfork() benötigt.
*

     OFFSET                        ; Struktur "saved memory block"

svmb_link:     DS.L 1              ; Verkettungszeiger
svmb_adr:      DS.L 1              ; Anfangsadresse des ger. Blocks
svmb_len:      DS.L 1              ; Länge des ger. Blocks
svmb_data:                         ; Daten

     TEXT

_memsave:
 move.l   a6,a1
_mems_loop:
 move.l   (a1)+,d0
 beq.b    _mems_doit               ; Listenende
 cmpa.l   d0,a0                    ; Block ist ausgenommen?
 bne.b    _mems_loop               ; nein
 moveq    #0,d0                    ; OK, nichts tun
 rts
_mems_doit:
 moveq    #svmb_data,d0
 add.l    mcb_len-mcb_data(a5),d0  ; Blocklänge
 moveq    #2,d1                    ; ST preferred
 lea      ur_pd,a1                 ; PD
 bsr      Mxalloc
 tst.l    d0
 bne.b    _mems_ok
* zuwenig Speicher. Bisherige Blöcke wieder freigeben
_mems_freeloop:
 move.l   a3,d0
 beq.b    _mems_reterr
 move.l   svmb_link(a3),a3
 lea      ur_pd,a1                 ; proc
 move.l   d0,a0
 bsr      Mxfree                   ; Block freigeben
 bra.b    _mems_freeloop
_mems_reterr:
 moveq    #ENSMEM,d0               ; Fehler
 rts
_mems_ok:
 move.l   d0,a0                    ; a0 = neuer Block
 move.l   a3,(a0)+                 ; svmb_link, einklinken
 move.l   d0,a3
 move.l   a5,(a0)+                 ; svmb_adr, Adresse
 move.l   mcb_len-mcb_data(a5),d0  ; Blocklänge
 move.l   d0,(a0)+                 ; svmb_len
 move.l   a5,a1                    ; Quelle
 jsr      memmove                  ; Block kopieren
 moveq    #0,d0                    ; OK
 rts

Pmemsave:
 movem.l  d6/d7/a3/a4/a5/a6,-(sp)
 move.l   a0,d6                    ; d6 = proc
 move.l   a1,a6                    ; a6 = excl_list
 suba.l   a3,a3                    ; noch keine Liste

* zunächst die "exclusive blocks"

 lea      mem_root,a4              ; Tabelle der Speicherlisten
pms_memloop2:
 move.l   (a4)+,d1                 ; Speicherliste
 bmi      pms_memloop2             ; ungültig
 beq      pms_end_exclloop         ; ist leer, Tabellenende
 move.l   d1,a5
pms_memloop:
 move.l   (a5)+,d1                 ; d1 = magic
 move.l   (a5)+,d7                 ; d7 = len
 move.l   (a5)+,d0                 ; d0 = owner
 addq.l   #4,a5                    ; mcb_prev überspringen
 cmpi.l   #'ANDR',d1
 beq.b    pms_isnxt
 cmpi.l   #'KROM',d1
 beq.b    pms_krom
 suba.w   #12,a5
pms_do_repair:
 move.l   a5,-(sp)                 ; Adresse des MCB auf Stack UND in a5
 move.l   d6,-(sp)                 ; owner für verwaiste Blöcke
 bsr      mem_repair               ; Versuch, zu reparieren
 addq.l   #8,sp
 subq.l   #4,a4
 bra      pms_memloop2             ; gelungen, Wiederholung
pms_krom:
 cmp.l    d0,d6
 bne      pms_memloop2             ; letzter Block hatte anderen owner

 bsr      _memsave                 ; Block sichern
 bmi.b    pms_end                  ; Fehler

 bra      pms_memloop2             ; nächste Liste
pms_isnxt:
 cmp.l    d0,d6
 bne.b    pms_next
; Sicherheits- Check
 move.l   a5,a1
 add.l    d7,a1                    ; a1 = nächster Block
 cmpi.l   #'ANDR',(a1)
 beq.b    pms_do_free
 cmpi.l   #'KROM',(a1)
 beq.b    pms_do_free
 move.l   a1,a5
 bra      pms_do_repair
pms_do_free:

 bsr      _memsave                 ; Block sichern
 bmi.b    pms_end

pms_next:
 add.l    d7,a5                    ; nächster Block
 bra      pms_memloop
pms_end_exclloop:

* dann die "shared memory blocks"

 move.l   d6,a0
 move.l   p_procdata(a0),d0
 beq.b    pms_ok                   ; keine procdata
 move.l   d0,a0
 move.l   pr_memlist(a0),d0
 beq.b    pms_ok                   ; keine shared blocks
 move.l   d0,a4                    ; a4 = memlist
 move.l   (a4)+,d7                 ; Länge
pms_shmloop:
 subq.l   #1,d7
 bcs.b    pms_ok
 move.l   (a4)+,d0
 beq.b    pms_shmloop              ; ungültiger Eintrag
 move.l   d0,a0

 bsr      _memsave                 ; Block sichern
 bmi.b    pms_end
 bra.b    pms_shmloop

pms_ok:

* schließlich Block-Eigner ändern

 move.l   a3,a0
pms_ownloop:
 move.l   a0,d0
 beq.b    pms_ok2
 move.l   d6,mcb_owner-mcb_data(a0)
 move.l   svmb_link(a0),a0
 bra.b    pms_ownloop
pms_ok2:

 move.l   a3,d0
pms_end:
 movem.l  (sp)+,d6/d7/a3/a4/a5/a6
 rts


**********************************************************************
*
* void Pmemrestore(a0 = void *saved_mem_list,
*                   a1 = PD *proc, d0 = int copy)
*
* Gegenstück zu Pmemsave. Kopiert die Daten zurück und gibt die
* Liste frei.
*
* wird für Pfork() benötigt.
*

Pmemrestore:
 movem.l  d7/a4/a5/a6,-(sp)
 move.l   a0,a6
 move.w   d0,d7
 move.l   a1,a4                    ; proc
pmr_loop:
 move.l   a6,d0
 beq.b    pmr_ende
 move.l   d0,a1
 move.l   a1,a5
 move.l   (a1)+,a6            ; a6 = svmb_link
 move.l   (a1)+,a0            ; a0 = adr
 move.l   (a1)+,d0            ; d0 = len
 tst.w    d7                  ; kopieren?
 beq.b    pmr_free            ; nein, nur freigeben
 cmp.l    mcb_len-mcb_data(a0),d0  ; Block verkleinert?
 bls.b    pmr_copy
 move.l   mcb_len-mcb_data(a0),d0  ; neue Größe nehmen
pmr_copy:
 jsr      memmove
pmr_free:
 move.l   a4,a1
 move.l   a5,a0
 bsr      Mxfree
 bra.b    pmr_loop
pmr_ende:
 movem.l  (sp)+,a6/a5/a4/d7
 rts


**********************************************************************
*
* long total_mem( void )
*
* Gibt zurück, wieviel Speicher dem Malloc-Mechanismus insgesamt
* zur Verfügung steht
*

total_mem:
 lea      mem_root.w,a2            ; Tabelle der Speicherlisten
 moveq    #0,d0                    ; gesamter Speicher
tmu_loop:
 move.l   (a2)+,d1
 beq.b    tmu_ende                 ; Tabellenende
 bmi.b    tmu_loop                 ; ungültiger Eintrag
 move.l   MEMLEN_OFFS-4(a2),a0
/*
 move.l   mem_top-mem_root-4(a2),a0
*/
 suba.l   d1,a0
 add.l    a0,d0
 bra      tmu_loop
tmu_ende:
 rts

     IF   COUNTRY=COUNTRY_DE

mem_fatal_errs:
 DC.B     '*** FATALER FEHLER IN DER SPEICHERVERWALTUNG:',0
mem_err_s:
 DC.B     '*** SPEICHERBLOCK DURCH BENUTZERPROGRAMM ZERSTÖRT:',$1b,'K'
 DC.B     $d,$a,$1b,'K',$a,0
adrmcb_s:
 DC.B     'Adresse des MCB: $',$1b,'K',0
datmcb_s:
 DC.B     'Daten des MCB: ',$1b,'K',0
do_dump_s:
 DC.B     $d,$a,$1b,'K',$a,'Systemauszug auf Disk: ',$1b,'K',$1b,'e',0
do_repair_s:
 DC.B     $d,$a,$1b,'K',$a,'Reparaturversuch (j/n) ? ',$1b,'K',$1b,'e',0
do_term_s:
 DC.B     $d,$a,$1b,'K',$a,'Programm wird terminiert',$d,$a,$1b,'K',$1b,'e',0

     ENDC
     IF   COUNTRY=COUNTRY_US

mem_fatal_errs:
 DC.B     '*** FATAL ERROR IN MEMORY MANAGEMENT:',0
mem_err_s:
 DC.B     '*** MEMORY BLOCK DESTROYED BY USER PROGRAM:',$1b,'K'
 DC.B     $d,$a,$1b,'K',$a,0
adrmcb_s:
 DC.B     'Address of MCB: $',$1b,'K',0
datmcb_s:
 DC.B     'Data of MCB: ',$1b,'K',0
do_dump_s:
 DC.B     $d,$a,$1b,'K',$a,'System dump to disk: ',$1b,'K',$1b,'e',0
do_repair_s:
 DC.B     $d,$a,$1b,'K',$a,'Try to repair (y/n) ? ',$1b,'K',$1b,'e',0
do_term_s:
 DC.B     $d,$a,$1b,'K',$a,'Program will be terminated',$d,$a,$1b,'K',$1b,'e',0

     ENDC
    IF  COUNTRY=COUNTRY_FR

mem_fatal_errs:
 DC.B   '*** ERREUR FATALE DANS LA GESTION DE MEMOIR:',0
mem_err_s:
 DC.B   '*** BLOC MÉMOIRE DÉTRUIT PAR PROGRAMME UTILISATEUR:',$1b,'K'
 DC.B   $d,$a,$1b,'K',$a,0
adrmcb_s:
 DC.B   'Adresse du MCB: $',$1b,'K',0
datmcb_s:
 DC.B   'Données  du MCB: ',$1b,'K',0
do_dump_s:
 DC.B   $d,$a,$1b,'K',$a,'Relève du système sur disque: ',$1b,'K',$1b,'e',0
do_repair_s:
 DC.B   $d,$a,$1b,'K',$a,'Essai de réparer (o/n) ? ',$1b,'K',$1b,'e',0; TPAK o=oui/ n=non
do_term_s:
 DC.B   $d,$a,$1b,'K',$a,'Le programme sera terminé',$d,$a,$1b,'K',$1b,'e',0

    ENDC

     END
