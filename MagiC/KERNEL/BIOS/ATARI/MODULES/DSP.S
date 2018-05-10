;
;DSP-Routinen
;

;
;noch zu überarbeiten:
;
;  devconnect (139)
;

;
ch_attenuation equ   $ffff893a   ;word Channel attenuation

;-------------------------------------;
;
;DSP
;
;typedef struct
;{
;    int     blocktype;
;    long    blocksize;
;    void    *blockaddr;
;} DSPBLOCK;

_int_dsp    equ   $3fc  ;Hier wird die IR-Routine eingetragen

;Größe der Strukturelemente: 12 Bytes; Anzahl: 8 
sizeof_subs       equ   96    ;8*12 = 96 Bytes

RXDF        equ   $0          ;Bitnummer: ISR Receive Data Register Full (RXDF)
TXDE        equ   $1          ;Bitnummer: ISR Transmit Data Register Empty (TXDE
TRDY        equ   $2          ;Bitnummer: ISR Transmitter Ready (TRDY)
DSP_HF2     equ   $3          ;Bitnummer: Hostflag 2
DSP_HF3     equ   $4          ;Bitnummer: Hostflag 3

dsp_irctrl  equ   $ffffa200   ;Interrupt Ctrl Register
dsp_cmdvec  equ   $ffffa201   ;Command Vector Register
dsp_irstat  equ   $ffffa202   ;Interrupt Status Register
dsp_irvec   equ   $ffffa203   ;Interrupt Vector Register
dsp_longwd  equ   $ffffa204   ;unbenutztes Byte ->für LONG-Zugriff benutzt
dsp_high    equ   $ffffa205      
dsp_mid     equ   $ffffa206
dsp_low     equ   $ffffa207

;
;INIT-Routine für die DSP-Routinen
dsp_stdinit:
;lblE05624:
   lea      _dsp_codebuf,a0
   lea      lblE48F06,a1         ;DSP-Code der internen dspexec-Routine
   moveq    #71,d0               ;3*24 Bytes = 24 DSP-Worte in Puffer schreiben
lblE061AA:
   move.b   (a1)+,(a0)+
   dbf      d0,lblE061AA
   
   moveq    #$17,d0
   lea      _dsp_subs,a0         ;Array mit SUBS-Strukturen
   bra.s    lblE05650
   
lblE0563A:
   clr.l    (a0)                 ;Adresse
   clr.w    10(a0)               ;Ability
   move.w   d0,8(a0)             ;Handle?
   addq.w   #1,d0
   lea      12(a0),a0            ;12 Bytes pro Eintrag
   
lblE05650:  ;Ende des Arrays mit Subroutine-Einträgen erreicht?
   cmpa.l   #_dsp_subs+sizeof_subs,a0
   bcs.s    lblE0563A
   
   move.l   #$7ea8,d0
   move.l   d0,_dsp_max_avail_mem
   move.l   d0,_dsp_avail_pmem
   clr.l    _dsp_xreserve
   clr.w    _dsp_ability
   clr.w    _dsp_free_subridx
   move.w   #$8000,_dsp_uniqueability
   
   moveq    #82,d0               ;codesize (DSP-Wörter)
   lea      lblE48B24,a0         ;*codeptr
   bsr      _Dsp_ExecBoot
   
   move.w   #152,d0              ;size_in
   lea      lblE48C1A.l,a1       ;*data_in
   bsr      tmt_to_DSP
   rts

;-------------------------------------
;
;Xbios 96   
;
;void Dsp_DoBlock(char *data_in,long size_in,char *data_out,long size_out);
;
;Wenn vorhanden, dann übertrage zuerst <size_in> Daten von <data_in> zum DSP
;und hole dann soviele Daten <data_out>, wie in <size_out> erfragt.
;
Dsp_DoBlock:
;lblE050BA:
   movea.l  (a0)+,a1             ;*data_in
   move.l   (a0)+,d0             ;size_in
   beq      lblE050EA
   subq.w   #1,d0
lblE050D2:
   btst     #TXDE,dsp_irstat.w   ;Sendregister leer?
   beq.s    lblE050D2

lblE050DA:
   move.b   (a1)+,dsp_high.w
   move.b   (a1)+,dsp_mid.w
   move.b   (a1)+,dsp_low.w
   dbf      d0,lblE050DA
   
lblE050EA:
   movea.l  (a0)+,a1             ;*data_out
   move.l   (a0),d0              ;size_out
   beq      lblE0510A
   subq.w   #1,d0
lblE050F2:
   btst     #RXDF,dsp_irstat.w   ;Empfangsregister gefüllt?
   beq.s    lblE050F2

lblE050FA:
   move.b   dsp_high.w,(a1)+
   move.b   dsp_mid.w,(a1)+
   move.b   dsp_low.w,(a1)+
   dbf      d0,lblE050FA
lblE0510A:
   rte

;
;Xbios 97
;
;void Dsp_BlkHandShake(char *data_in,long size_in,char *data_out,long size_out);
;
Dsp_BlkHandShake:
;lblE0510C:
   movea.l  (a0)+,a1             ;*data_in
   move.l   (a0)+,d0             ;size_in
   beq      lblE0513C
   subq.w   #1,d0
lblE05124:
   btst     #TXDE,dsp_irstat.w   ;Senderegister leer?
   beq.s    lblE05124
   
   move.b   (a1)+,dsp_high.w
   move.b   (a1)+,dsp_mid.w
   move.b   (a1)+,dsp_low.w
   dbf      d0,lblE05124
   
lblE0513C:
   movea.l  (a0)+,a1             ;*data_out
   move.l   (a0),d0              ;size_out
   beq      lblE0515C
   subq.w   #1,d0
lblE05144:
   btst     #RXDF,dsp_irstat.w   ;Empfangsregister gefüllt?
   beq.s    lblE05144
   
   move.b   dsp_high.w,(a1)+
   move.b   dsp_mid.w,(a1)+
   move.b   dsp_low.w,(a1)+
   dbf      d0,lblE05144
lblE0515C:
   rte

;
;Xbios 98
;
;void Dsp_BlkUnpacked(long *data_in,long size_in,long *data_out,long size_out);
;
Dsp_BlkUnpacked:
;lblE0515E:
   movea.l  (a0)+,a1 ;*data_int
   move.l   (a0)+,d0 ;size_in
   beq      lblE05186
   subq.w   #1,d0
lblE05176:
   btst     #TXDE,dsp_irstat.w   ;Senderegister leer?
   beq.s    lblE05176
lblE0517E:
   move.l   (a1)+,dsp_longwd.w
   dbf      d0,lblE0517E
   
lblE05186:
   movea.l  (a0)+,a1 ;*data_out
   move.l   (a0),d0  ;size_out
   beq      lblE0519E
   subq.w   #1,d0
lblE0518E:
   btst     #RXDF,dsp_irstat.w   ;Empfangsregister gefüllt?
   beq.s    lblE0518E
lblE05196:
   move.l   dsp_longwd.w,(a1)+
   dbf      d0,lblE05196
lblE0519E:
   rte
 
;
;XBios 99
;
;void Dsp_InStream(char *data_in,long block_size,long num_blocks,long *blocks_done);
;
Dsp_InStream:
;lblE05324:
   move.l   (a0)+,_dsp_tmtbuf_ptr      ;*data_in
   move.l   (a0)+,_dsp_tmtsize         ;block_insize
   move.l   (a0)+,_dsp_num_tmtblks     ;num_blocks
   move.l   (a0),_dsp_tmtblks_done_ptr ;*blocks_done
   movea.l  _dsp_tmtblks_done_ptr,a0
   clr.l (a0)                    ;0 blocks ready
   move.l   _dsp_tmtsize,d0
   beq      lblE0536E            ;keine Sendedaten vorhanden
   move.l   #DSP_Stream_IR,_int_dsp.w
   move.b   #$ff,dsp_irvec.w     ;IR freigeben
   ori.b    #2,dsp_irctrl.w      ;TXDE Request
lblE0536E:
   rte

;
;Xbios 100
;
;void Dsp_OutStream(data_out,block_size,num_blocks,blocks_done);
;
Dsp_OutStream:
;lblE05370:
   move.l   (a0)+,_dsp_rcvbuf_ptr      ;*data_out
   move.l   (a0)+,_dsp_rcvsize         ;block_outsize
   move.l   (a0)+,_dsp_num_rcvblks     ;num_blocks
   move.l   (a0),_dsp_rcvblks_done_ptr ;*blocks_done
   movea.l  _dsp_rcvblks_done_ptr,a0
   clr.l (a0)                    ;0 blocks ready
   move.l   _dsp_rcvsize,d0
   beq      lblE053BA            ;sollen Daten abgeholt werden?
   move.l   #DSP_Stream_IR,_int_dsp.w
   move.b   #$ff,dsp_irvec.w     ;IR freigeben
   ori.b    #1,dsp_irctrl.w      ;RXDF Request
lblE053BA:
   rte

;
;DSP-Interrupt-Routine
;
DSP_Stream_IR:
;lblE053BC:
   movem.l  d0/a0,-(sp)
   btst     #RXDF,dsp_irstat.w
   beq      lblE05412            ;keine Daten im Empfangspuffer -> Daten zum DSP schicken
   move.l   _dsp_rcvsize,d0
   subq.w   #1,d0
   movea.l  _dsp_rcvbuf_ptr,a0
lblE053D8:
   move.b   dsp_high.w,(a0)+
   move.b   dsp_mid.w,(a0)+
   move.b   dsp_low.w,(a0)+
   dbf      d0,lblE053D8
   move.l   a0,_dsp_rcvbuf_ptr
   movea.l  _dsp_rcvblks_done_ptr,a0
   addq.l   #1,(a0)
   move.l   (a0),d0
   cmp.l    _dsp_num_rcvblks,d0
   bne      lblE05454
   andi.b   #$fe,dsp_irctrl.w    ;RXDF Request löschen
   bra      lblE05454.l

lblE05412:                       ;Daten zum DSP schicken
   move.l   _dsp_tmtsize,d0
   subq.w   #1,d0
   movea.l  _dsp_tmtbuf_ptr,a0
lblE05420:
   move.b   (a0)+,dsp_high.w
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   dbf      d0,lblE05420
   move.l   a0,_dsp_tmtbuf_ptr   ;neue Adresse des Sendepuffers
   movea.l  _dsp_tmtblks_done_ptr,a0
   addq.l   #1,(a0)              ;Block abgeschickt
   move.l   (a0),d0
   cmp.l    _dsp_num_tmtblks,d0  ;alle Blöcke abgeschickt?
   bne      lblE05454
   andi.b   #$fd,dsp_irctrl.w    ;TXDE Request löschen
lblE05454:
   movem.l  (sp)+,a0/d0
   rte

;
;Xbios 101
;
;void Dsp_IOStream(char *data_in,char *data_out,long block_insize,long block_outsize,
;                  long num_blocks,long *blocks_done);
Dsp_IOStream:
;lblE0523C:
   move.l   (a0)+,_dsp_tmtbuf_ptr      ;*data_in
   move.l   (a0)+,_dsp_rcvbuf_ptr      ;*data_out
   move.l   (a0)+,_dsp_tmtsize         ;block_insize
   move.l   (a0)+,_dsp_rcvsize         ;block_outsize
   move.l   (a0)+,_dsp_num_tmtblks     ;num_blocks
   move.l   (a0),_dsp_tmtblks_done_ptr ;*blocks_done
   movea.l  _dsp_tmtblks_done_ptr,a0
   clr.l    (a0)                 ;0 blocks ready
   move.l   _dsp_tmtsize,d0      ;Größe des Blocks
   subq.w   #1,d0
   movea.l  _dsp_tmtbuf_ptr,a0   ;*data_in
lblE05286:
   move.b   (a0)+,dsp_high.w     ;ersten Datenblock zum DSP schicken
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   dbf      d0,lblE05286
   
   move.l   a0,_dsp_tmtbuf_ptr   ;nun 1 Byte hinter erstem Datenblock
   move.l   #DSP_IOStream_IR,_int_dsp.w
   move.b   #$ff,dsp_irvec.w
   ori.b    #1,dsp_irctrl.w
   rte

;
;DSP-Interrupt-Routine
;
DSP_IOStream_IR:
;lblE052B2:
 movem.l  d0/a0,-(sp)
   move.l   _dsp_rcvsize,d0      ;block_outsize 
   subq.w   #1,d0
   movea.l  _dsp_rcvbuf_ptr,a0   ;*data_out
lblE052C4:
   move.b   dsp_high.w,(a0)+     ;ersten Datenblock vom DSP abholen
   move.b   dsp_mid.w,(a0)+
   move.b   dsp_low.w,(a0)+
   dbf      d0,lblE052C4
   
   move.l   a0,_dsp_rcvbuf_ptr   ;nächste Adresse für Empfangsdatenblock
   movea.l  _dsp_tmtblks_done_ptr,a0   ;blocks_done erhöhen
   addq.l   #1,(a0)
   move.l   (a0),d0
   cmp.l    _dsp_num_tmtblks,d0  ;==num_blocks?
   bne      lblE052FA
   andi.b   #$fe,dsp_irctrl.w    ;fertig ->IR disablen
   bra      lblE0531E.l          ;raus

lblE052FA:
 move.l   _dsp_tmtsize,d0        ;block_insize
 subq.w   #1,d0
 movea.l  _dsp_tmtbuf_ptr,a0     ;Adresse für Sendepuffer holen
lblE05308:
   move.b   (a0)+,dsp_high.w
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   dbf      d0,lblE05308
   move.l   a0,_dsp_tmtbuf_ptr   ;neue Adresse für Sendepuffer merken
lblE0531E:
   movem.l  (sp)+,a0/d0
   rte

;
;Xbios 102
;
;void Dsp_RemoveInterrupts(int mask);
;
Dsp_RemoveInterrupts:
;lblE0545A:
   move.w   (a0),d0
   not.b    d0
   and.b    d0,dsp_irctrl.w
   rte

;
;XBios 103
;
;int  Dsp_GetWordSize(void);
Dsp_GetWordSize:
;lblE05466:
   moveq    #3,d0
   rte

;
;Xbios 104
;int  Dsp_Lock(void);
Dsp_Lock:
;lblE05FE0:
   move.w   _dsp_lock,d0
   bne      lblE05FF4
   moveq    #-1,d1
   move.w   d1,_dsp_lock
lblE05FF4:
   rte

;
;Xbios 105
;void Dsp_Unlock(void);
;
Dsp_Unlock:
;lblE05FF6:
   clr.w   _dsp_lock
   rte

;
;Xbios 106
;void Dsp_Available(long *xavailable,long *yavailable);
Dsp_Available:
;lblE06022:
   movea.l  (a0)+,a1          ;*xavailable
   movea.l  (a0),a0           ;*yavailable
   move.l   #$3eff,(a0)       ;4k - 256 Bytes
   move.l   _dsp_avail_pmem,d0
   sub.l    #$4000,d0
   move.l   d0,(a1)
   rte

;
;Xbios 107
;int Dsp_Reserve(long xreserve, long yreserve);
;
Dsp_Reserve:
;lblE06040:
   move.l   (a0)+,d0          ;xreserve
   add.l    #$4000,d0
   move.l   _dsp_avail_pmem,d1
   cmp.l    d1,d0
   bgt      lblE06074
   move.l   d0,_dsp_xreserve  ;Größe des reserierten X-Speichers + $4000
   move.l   (a0),d0           ;yreserve
   cmp.l    #$3eff,d0
   bgt      lblE06074
   moveq    #0,d0
   rte
 
lblE06074:
   moveq    #-1,d0
   rte

;
;Xbios 108
;
;int  Dsp_LoadProg(char *file,int ability,char *buffer);
;
Dsp_LoadProg:
;lblE05888:
   move.l   (a0)+,a1          ;char *file
   move.w   (a0)+,d0          ;int ability
   move.l   (a0),a0           ;char *buffer
   
   move.l   a0,-(sp)          ;sichern
   move.w   d0,-(sp)          ;sichern
   
   bsr      _Dsp_LodToBinary  ;liefert <codesize> oder -1 zurück, ! a0=codeptr, a1=file !
   
   move.w   (sp)+,d1          ;abitlity
   move.l   (sp)+,a0          ;char *codeptr
   tst.l    d0                ;codesize
   ble.s    lblE058C2
   
   move.w   d1,_dsp_ability
   move.w   d1,-(sp)          ;ability
   move.l   d0,-(sp)          ;codesize
   move.l   a0,-(sp)          ;*codeptr
   move.l   sp,a0
   bsr      _Dsp_ExecProg
   lea      10(sp),sp
   moveq    #0,d0
   rte

lblE058C2:
   moveq    #-1,d0
   rte
;
;Xbios 109
;void Dsp_ExecProg(char *codeptr,long codesize,int ability);
;
Dsp_ExecProg:
;lblE058D4:
   bsr.b    _Dsp_ExecProg
   rte
   
_Dsp_ExecProg:
   move.l   a0,-(sp)          ;sichern

   moveq    #71,d0            ;codesize (Anzahl der _DSP-Wörter_)
   lea      lblE48DE2,a0      ;*codeptr für Dsp_ExecBoot
   bsr      _Dsp_ExecBoot

   move.l   (sp)+,a0
   move.l   (a0)+,a1          ;codeptr
   move.l   (a0)+,d0          ;codesize
   beq      exit_Dsp_Exec
   bsr      tmt_to_DSP

   lea      _dsp_codebuf,a1   ;und "interne" exec-Routine anwerfen
   moveq    #24,d0            ;24 _DSP-Worte_ senden
   bsr      tmt_to_DSP     

   move.w   (a0),_dsp_ability ;ability merken
exit_Dsp_Exec:
   rts

;
; a1.l: Quelle
; d0.w: Anzahl der DSP-Worte
;zerstört d0,a1
tmt_to_DSP:
   subq.w   #1,d0
tmt_req:
   btst     #TXDE,dsp_irstat.w   ;DSP bereit Sendedaten anzunehmen?
   beq.s    tmt_req
   
   move.b   (a1)+,dsp_high.w
   move.b   (a1)+,dsp_mid.w
   move.b   (a1)+,dsp_low.w
   dbf      d0,tmt_req
   rts

;
;Xbios 110
;
;void Dsp_ExecBoot(char *codeptr,long codesize,int ability);
;<ability> wird ignoriert!
;
Dsp_ExecBoot:
   move.l   4(a0),d0          ;codesize
   move.l   (a0),a0           ;codeptr
   bsr.b    _Dsp_ExecBoot
   rte
   
_Dsp_ExecBoot:
   move     sr,d2
   move     #$2700,sr
   move.b   #$e,giselect.w
   move.b   giread.w,d1
   andi.b   #$ef,d1
   move.b   d1,giwrite.w
   ori.b    #$10,d1
   move.b   d1,giwrite.w
   move     d2,sr
   move.l   _hz_200.w,d1
   addq.l   #2,d1
lblE05E4A:
   move.l   _hz_200.w,d2
   cmp.l    d1,d2
   blt.s    lblE05E4A
   
   move     sr,d2
   move     #$2700,sr
   move.b   #$e,giselect.w
   move.b   giread.w,d1
   andi.b   #$ef,d1
   move.b   d1,giwrite.w
   move     d2,sr
   
   move.l   #512,d1           ;Größe des interen DSP-Speichers
   sub.l    d0,d1             ;noch verbleibender interner Speicher
   subq.l   #1,d0
lblE05E8A:
   move.b   (a0)+,dsp_high.w
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   dbf      d0,lblE05E8A
   tst.l    d1
   beq      lblE05EBC
   
   subq.l   #1,d1             ;noch verbleibenden freien internen Speicher ausnullen
lblE05EA6:
   move.b   #0,dsp_high.w
   move.b   #0,dsp_mid.w
   move.b   #0,dsp_low.w
   dbf      d1,lblE05EA6
lblE05EBC:
   rts

;
;Xbios 111
;
;long Dsp_LodToBinary(char *file,char *codeptr);
;
Dsp_LodToBinary:
   move.l   (a0)+,a1          ;file
   move.l   (a0),a0           ;codeptr
   bsr.b    _Dsp_LodToBinary
   rte
   
_Dsp_LodToBinary:
   move.l   a0,-(sp)          ;codeptr sichern

   move.l   a1,a0             ;*file
   bsr      read_LODfile      ;Datei einlesen, Pufferspeicher allozieren

   move.l   (sp)+,a1          ;codeptr

   tst.l    d0                ;Pufferadr
   bne.s    lblE0586A
   moveq    #-1,d0            ;Pufferadr == 0
   rts
   
lblE0586A:
   move.l   a0,a2             ;Endadresse des LOD-Files
   move.l   d0,a0             ;Startadr des LOD-Files
   move.l   a0,-(sp)          ;Pufferadr der LOD-Datei auf den Stack wg. folgendem Mfree
   bsr      conv_LOD_to_bin   ;LOD-Datei konvertieren, a0 = codeptr, liefert BIN-Länge in d0 zurück
   move.l   (sp)+,a0
   move.l   d0,-(sp)          ;_dsp_bin_len sichern
   
   move.l   a0,-(sp)          ;Pufferadr.
   move.w   #$49,-(sp)        ;Mfree
   trap     #GEMDOS
   addq.l   #6,sp             ;Opcode + Pufferadr abräumen

   move.l   (sp)+,d0          ;_dsp_bin_len
   divs.l   #3,d0             ;Länge in DSP-Worten
   rts

;
;Xbios 112
;void Dsp_TriggerHC(int vector);
;
Dsp_TriggerHC:
;lblE05FD2:
   move.w   (a0),d0           ;vector
   ori.b    #$80,d0
   move.b   d0,dsp_cmdvec.w
   rte

;
;Xbios 113
;int  Dsp_RequestUniqueAbility(void);
;
Dsp_RequestUniqueAbility:
;lblE0607A:
   move.w   _dsp_uniqueability,d0
   addq.w   #1,d0
   move.w   d0,_dsp_uniqueability
   rte

;
;Xbios 114
;int  Dsp_GetProgAbility(void);
;
Dsp_GetProgAbility:
;lblE0608C:
   move.w   _dsp_ability,d0
   rte

;
;Xbios 115
;void Dsp_FlushSubroutines(void);
;
Dsp_FlushSubroutines:
;lblE056B4:
   lea      _dsp_subs,a0
   bra.s    lblE056CC
   
lblE056C2:
   clr.l    (a0)              ;Adresse löschen
   clr.w    10(a0)            ;ability löschen
   adda.w   #12,a0
lblE056CC:
   cmpa.l   #_dsp_subs.l+sizeof_subs,a0
   bcs.s    lblE056C2
   
   move.l   _dsp_max_avail_mem,_dsp_avail_pmem
   clr.w    _dsp_free_subridx
   rte

;
;Xbios 116
;int  Dsp_LoadSubroutine(char *ptr,long size, int ability);
;
Dsp_LoadSubroutine:
   movem.l  d5/d6/d7,-(sp)
   move.l   (a0)+,a1          ;Adresse der Subroutine
   move.l   (a0)+,d0
   move.w   (a0),d1
   
   move.l   d0,d7             ;size
   move.w   d1,d6             ;ability
   cmpi.l   #1024,d7
   ble.s    lblE05708

   moveq    #0,d0             ;Subroutine ist zu groß -> Fehler
   bra      exit_LdSub
   
lblE05708:
   move.l   _dsp_xreserve,d0
   add.l    d7,d0
   move.l   _dsp_avail_pmem,d1
   cmp.l    d1,d0
   ble.s    lblE05720         

   moveq    #0,d0             ;Subroutine ist zu groß
   bra      exit_LdSub
 
lblE05720:
   move.w   _dsp_free_subridx,d0
   muls.w   #12,d0
   lea      _dsp_subs,a2
   adda.l   d0,a2
   tst.l    (a2)
   beq      DSP_loadsub_entry_free  ;Eintrag ist noch frei
   
   move.l   (a2),d0           ;Adresse der vorhandenen Subroutine
   subq.l   #1,d0
   move.l   d0,d2
   sub.l    d1,d0

   move.l   d0,-(sp)
   move.l   _dsp_max_avail_mem,-(sp)
   move.l   d2,-(sp)          

;3 DSP-Worte im Handshake-Modus zum DSP
   move.b   #$96,dsp_cmdvec.w ;Handshake, Hostvektor 22
lblE05EEA:
   btst     #7,dsp_cmdvec.w
   bne.s    lblE05EEA
   move.b   1(sp),dsp_high.w
   move.b   2(sp),dsp_mid.w
   move.b   3(sp),dsp_low.w
   
   move.b   5(sp),dsp_high.w
   move.b   6(sp),dsp_mid.w
   move.b   7(sp),dsp_low.w
   
   move.b   9(sp),dsp_high.w
   move.b   10(sp),dsp_mid.w
   move.b   11(sp),dsp_low.w
   
   lea      $c(sp),sp         ;Stack kor.
   
   move.w   _dsp_free_subridx,d0
   muls.w   #12,d0
   lea      _dsp_subs,a2
   move.l   4(a2,d0.l),d5     ;size
   bra.s    lblE0578E

lblE0577C:
   add.l    d5,(a2)           ;Größe + Startadresse = Endadresse der DSP-Routine
   move.l   (a2),d0           ;Endadresse
   moveq    #-$17,d2
   add.w    8(a2),d2          ;Handle beginnen mit $17 (bis $1e)
   
   muls     #6,d2             ;6 Byte pro Eintrag
   lea      _dsp_subr_adr.l,a0
   move.w   d0,4(a0,d2.w)     ;Nur Lo- und Mid-Byte eintragen, Hi-Byte ist null
   lea.l    12(a2),a2
lblE0578E:
   cmpa.l   #_dsp_subs+sizeof_subs,a2
   bcs.s    lblE0577C      
 
   add.l    d5,_dsp_avail_pmem

DSP_loadsub_entry_free:
   move.l   _dsp_avail_pmem,d1
   sub.l    d7,d1             ;size
   move.l   d1,_dsp_avail_pmem

   lea      _dsp_subs,a0
   move.w   _dsp_free_subridx,d2
   muls.w   #12,d2
   adda.l   d2,a0             ;Adresse der Struktur
   
   addq.l   #1,d1
   move.l   d1,(a0)           ;Adresse
   move.l   d7,4(a0)          ;size
   move.w   d6,$a(a0)         ;Ability

   lea      _dsp_subr_adr.l,a0
   moveq    #-$17,d2
   add.w    8(a0),d2          ;Handle
   muls     #6,d2             ;6 Byte pro Eintrag
   move.w   d1,4(a0,d2.w)     ;3-Byte-Adresse eintragen - Annahme: High-Byte ist null

lblE05F3A:
   move.b   #$95,dsp_cmdvec.w ;Handshake, Hostvektor 21
lblE05F40:
   btst     #7,dsp_cmdvec.w
   bne.s    lblE05F40

   moveq    #0,d0
   move.b   d0,dsp_high.w
   move.b   d0,dsp_mid.w
   move.b   #$2e,dsp_low.w
   
   move.b   d0,dsp_high.w
   move.b   d0,dsp_mid.w
   move.b   #16,dsp_low.w     ;16 DSP-Worte senden

   moveq    #15,d0
; a0 zeigt noch auf _dsp_subr_adr, Tabelle mit Opcodes und Subr-Adr. an DSP übertragen
lblE05F74:                 
   move.b   (a0)+,dsp_high.w
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   dbf      d0,lblE05F74

lblE05F2A:
   move.b   #$95,dsp_cmdvec.w ;Handshake, Hostvektor 21
lblE05F30:
   btst     #7,dsp_cmdvec.w
   bne.s    lblE05F30

   move.w   _dsp_free_subridx,d0
   muls.w   #12,d0
   lea      _dsp_subs,a0
   adda.l   d0,a0
   move.l   4(a0),(sp)     ;size
   move.l   (a0),-(sp)     ;Adr
   move.b   1(sp),dsp_high.w     ;Adresse in DSP schreiben
   move.b   2(sp),dsp_mid.w
   move.b   3(sp),dsp_low.w
   
   move.b   5(sp),dsp_high.w     ;Größe
   move.b   6(sp),dsp_mid.w
   move.b   7(sp),dsp_low.w

   move.l   d7,d0                ;size_in
;Register a1 enthält bereits den Zeiger auf die Subroutine
   bsr      tmt_to_DSP
   
   move.w   _dsp_free_subridx,d6
   addq.w   #1,_dsp_free_subridx
   cmpi.w   #8,_dsp_free_subridx
   blt.s    lblE05834
   
   clr.w    _dsp_free_subridx
lblE05834:
   muls.w   #12,d6
   lea      _dsp_subs,a0
   move.w   8(a0,d6.l),d0              ;Handle der Subroutine
exit_LdSub:
   movem.l  (sp)+,d7/d6/d5
   rte

;
;Xbios 117
;
;int  Dsp_InqSubrAbility(int ability);
;Liefert das Handle oder 0 zurück
;
Dsp_InqSubrAbility:
;lblE06094:
   move.w   (a0),d1              ;ability
   lea      _dsp_subs,a0
   moveq    #$16,d0              ;$17 ist das erste Handle für eine Subroutine
lblE060A0:
   addq.w   #1,d0                ;Handle
   cmp.w    10(a0),d1            ;== Handle der Subroutine?
   beq      lblE060BA            ;dann raus
   
   lea      12(a0),a0
   cmp.w    #$1e,d0              ;max. 30 ist das Handle
   bne.s    lblE060A0
   moveq   #0,d0
lblE060BA:
   rte

;
;Xbios 118
;
;int  Dsp_RunSubroutine(int handle);
;0: ok, -1: Subroutine konnte nicht ausgeführt werden
; 
;Diese Funktion setzt voraus, daß die gesuchte Subroutine bereits geladen ist
;
Dsp_RunSubroutine:
;lblE05F86:
   move.w   (a0),d0              ;handle
   move.w   d0,d1
   cmp.b    #$17,d0              ;ungültiges Handle?
   blt      lblE05FCC
   
   cmp.b    #$1e,d0              ;ungültiges Handle?
   bgt      lblE05FCC
   
   sub.w    #$17,d1
   muls     #6,d1                ;6 Byte pro Eintrag
   addq.w   #3,d1                ;erstes DSP-Wort überspringen
   lea      _dsp_subr_adr,a0
   adda.w   d1,a0
   move.b   (a0)+,dsp_high.w
   move.b   (a0)+,dsp_mid.w
   move.b   (a0)+,dsp_low.w
   ori.b    #$80,d0
   move.b   d0,dsp_cmdvec.w
   moveq    #0,d0
   rte

lblE05FCC:
   moveq   #-1,d0
   rte
   
;
;Xbios 119
;int  Dsp_Hf0(int flag);
;
Dsp_Hf0:
;lblE060E0:
   move.w   (a0),d1              ;flag
   cmp.w    #$ffff,d1
   beq      lblE06110            ;Erfragen des Wertes
   cmp.w    #1,d1
   bne      lblE060FE
   bset.b   #3,dsp_irctrl.w
   rte
   
lblE060FE:
   cmp.w    #0,d1
   bne      lblE06122
   bclr     #3,dsp_irctrl.w
   rte
   
lblE06110:
   moveq   #0,d0
   btst     #3,dsp_irctrl.w
   beq      lblE06122
   moveq   #1,d0
lblE06122:
   rte

;
;Xbios 120
;int  Dsp_Hf1(int flag);
;
Dsp_Hf1:
;lblE06124:
   move.w   (a0),d1     ;flag
   cmp.w    #$ffff,d1
   beq      lblE06154
   
   cmp.w    #1,d1
   bne      lblE06142
   bset.b   #4,dsp_irctrl.w
   rte

lblE06142:
   cmp.w    #0,d1
   bne      lblE06166
   bclr     #4,dsp_irctrl.w
   rte

lblE06154:
   moveq   #0,d0
   btst     #4,dsp_irctrl.w
   beq      lblE06166
   moveq   #1,d0
lblE06166:
   rte

;
;Xbios 121
;int  Dsp_Hf2(int flag);
;
Dsp_Hf2:
;lblE06168:
   moveq   #0,d0
   btst     #DSP_HF2,dsp_irstat.w
   beq      lblE0617A
   moveq   #1,d0
lblE0617A:
   rte

;
;Xbios 122
;int  Dsp_Hf3(int flag);
;
Dsp_Hf3:
;lblE0617C:
   moveq   #0,d0
   btst     #DSP_HF3,dsp_irstat.w
   beq      lblE0618E
   moveq   #1,d0
lblE0618E:
   rte

;
;Xbios 123
;
;void Dsp_BlkWords(int *data_in,long size_in,int *data_out,long size_out);
;
Dsp_BlkWords:
;lblE051A0:
   movea.l  (a0)+,a1             ;*data_in
   move.l   (a0)+,d0             ;size_in
   beq      lblE051CC
   subq.w   #1,d0
lblE051B8:
   btst     #TXDE,dsp_irstat.w   ;Senderegister leer?
   beq.s    lblE051B8

lblE051C0:
   move.w   (a1)+,d2
   ext.l    d2
   move.l   d2,dsp_longwd.w
   dbf      d0,lblE051C0
   
lblE051CC:
   movea.l  (a0)+,a1             ;*data_out
   move.l   (a0),d0              ;size_out
   beq      lblE051E8
   subq.w   #1,d0
lblE051D4:
   btst     #RXDF,dsp_irstat.w   ;Empfangsregister gefüllt?
   beq.s    lblE051D4
lblE051DC:
   move.b   dsp_mid.w,(a1)+      ;wieso hier kein move.w?
   move.b   dsp_low.w,(a1)+
   dbf      d0,lblE051DC
lblE051E8:
   rte

;
;Xbios 124
;
;void Dps_BlkBytes(long *data_in,long size_in,long *data_out,long size_out);
;
Dsp_BlkBytes:
;lblE051EA:
 movea.l  (a0)+,a1               ;*data_in
   move.l   (a0)+,d0             ;size_in
   beq      lblE0521E
   subq.w   #1,d0
lblE05202:
   btst     #TXDE,dsp_irstat.w
   beq.s    lblE05202

lblE0520A:
   move.b   #0,dsp_high.w
   move.b   #0,dsp_mid.w
   move.b   (a1)+,dsp_low.w
   dbf      d0,lblE0520A
   
lblE0521E:
   movea.l  (a0)+,a1             ;*data_out
   move.l   (a0),d0              ;size_out
   beq      lblE0523A
   subq.w   #1,d0
lblE05226:
   btst     #RXDF,dsp_irstat.w
   beq.s    lblE05226

lblE0522E:
   move.b   dsp_mid.w,d1      ;??
   move.b   dsp_low.w,(a1)+
   dbf      d0,lblE0522E

lblE0523A:
   rte

;
;Xbios 125
;char Dsp_HStat();
;
Dsp_HStat:
;lblE06190:
   move.b   dsp_irstat.w,d0
   move.b   dsp_cmdvec.w,d1
   rte

;
;Xbios 126
;void Dsp_SetVectors(void (*receiver)(),long (*transmitter)() );
;
Dsp_SetVectors:
;lblE0546C:
   clr.l    _dsp_rcv_ptr
   clr.l    _dsp_tmt_ptr
   move.l   (a0)+,d0             ;*receiver
   beq      lblE054A2
   move.l   d0,_dsp_rcv_ptr
   move.l   #DSP_TRM_RCV_IR,_int_dsp.w
   move.b   #$ff,dsp_irvec.w
   ori.b    #1,dsp_irctrl.w      ;Enable RXDF Request
   
lblE054A2:
   move.l   (a0),d0              ;*transmitter
   beq      lblE054C4
   move.l   d0,_dsp_tmt_ptr
   move.l   #DSP_TRM_RCV_IR,_int_dsp.w
   move.b   #$ff,dsp_irvec.w
   ori.b    #2,dsp_irctrl.w      ;Enable TXDE Request
lblE054C4:
   rte

;
;DSP-Interrupt-Routine
;
DSP_TRM_RCV_IR:
;lblE054C6:
   movem.l  d0/d1/d2/a0/a1/a2,-(sp)
   btst     #RXDF,dsp_irstat.w
   beq      lblE054F8
   move.l   _dsp_rcv_ptr,d0
   beq      lblE054F8
   movea.l  d0,a0
   moveq    #0,d0
   move.b   dsp_high.w,d0
   rol.l    #8,d0
   move.b   dsp_mid.w,d0
   rol.l    #8,d0
   move.b   dsp_low.w,d0
   move.l   d0,-(sp)
   jsr      (a0)
   addq.l   #4,sp
   
lblE054F8:
   btst     #TXDE,dsp_irstat.w   ;DSP bereit Sendedaten anzunehmen?
   beq      lblE05528
   move.l   _dsp_tmt_ptr,d0
   beq      lblE05528            ;keine Senderoutine installiert
   movea.l  d0,a0
   jsr      (a0)
   tst.l    d0                   
   beq      lblE05528            ;falls != 0L, dann Daten zum DSP schicken
   swap     d0
   move.b   d0,dsp_high.w
   rol.l    #8,d0
   move.b   d0,dsp_mid.w
   rol.l    #8,d0
   move.b   d0,dsp_low.w
lblE05528:
   movem.l  (sp)+,a2/a1/a0/d2/d1/d0
   rte

;
;Xbios 127
;void Dsp_MultBlocks(long numsend,long numreceive,DSPBLOCK *sendblocks,DSPBLOCK *receiveblocks);
;
Dsp_MultBlocks:
;lblE0552E:
   move.l   (a0),d0              ;numsend
   beq      no_sendblks
lblE05536:
   btst     #TXDE,dsp_irstat.w
   beq.s    lblE05536
   movea.l  8(a0),a0             ;sendblocks
   subq.w    #1,d0
   
nxt_sendblk:
   move.w   (a0)+,d1             ;blocktype
   move.l   (a0)+,d2             ;blocksize
   subq.l   #1,d2
   movea.l  (a0)+,a1             ;blockaddr
   tst.w    d1                   ;blocktype == LONG?
   beq      lblE05570
   subq.w    #1,d1               ;WORD?
   beq      lblE0557E
   subq.w    #1,d1               ;UBYTE?
   beq      lblE05590
   bra      no_sendblks
   
lblE05570:
   move.l   (a1)+,dsp_longwd.w
   dbf      d2,lblE05570
   dbf      d0,nxt_sendblk
   bra      no_sendblks
   
lblE0557E:
   move.w   (a1)+,d1
   ext.l    d1
   move.l   d1,dsp_longwd.w
   dbf      d2,lblE0557E
   dbf      d0,nxt_sendblk
   bra      no_sendblks
   
lblE05590:
   move.b   #0,dsp_high.w
   move.b   #0,dsp_mid.w
   move.b   (a1)+,dsp_low.w
   dbf      d2,lblE05590
   dbf      d0,nxt_sendblk

no_sendblks:
   move.l   4(a0),d0             ;num_receive
   beq      lblE05622
lblE055B4:
   btst     #RXDF,dsp_irstat.w
   beq.s    lblE055B4
   movea.l  12(a0),a0            ;receive_blocks[]
   subq.w    #1,d0
   
nxt_rcvblk:
   move.w   (a0)+,d1             ;blocktype
   move.l   (a0)+,d2             ;blocksize
   subq.l   #1,d2
   movea.l  (a0)+,a1             ;blockaddr
   tst.w    d1                   ;LONG?
   beq      lblE055EE
   subq.w    #1,d1               ;WORD?
   beq      lblE055FC
   subq.w    #1,d1               ;UBYTE?
   beq      lblE0560E
   bra      lblE05622            ;raus
   
lblE055EE:
   move.l   dsp_longwd.w,(a1)+
   dbf      d2,lblE055EE
   dbf      d0,nxt_rcvblk
   rte
   
lblE055FC:
   move.b   dsp_mid.w,(a1)+
   move.b   dsp_low.w,(a1)+
   dbf      d2,lblE055FC
   dbf      d0,nxt_rcvblk
   rte
   
lblE0560E:
   move.b   dsp_mid.w,d1
   move.b   dsp_low.w,(a1)+
   dbf      d2,lblE0560E
   dbf      d0,nxt_rcvblk

lblE05622:
   rte

;----------------
;
;Xbios 128
;long locksnd(void);
;
locksnd:
;lblE0630A:
   bset.b   #1,_snd_lock.l
   bne      lblE06320
   st       _snd_lock.l
   moveq    #1,d0
   rte

lblE06320:
   move.l   #$ffffff7f,d0
   rte

;
;Xbios 129
;long unlocksnd(void);
;
unlocksnd:
;lblE06328:
   tst.b    _snd_lock.l
   beq      lblE0633C
   sf       _snd_lock.l
   clr.l    d0
   rte

lblE0633C:
   moveq    #-$80,d0
   rte

;
;Xbios 130
;long soundcmd(int mode,int data);
;
soundcmd:
;lblE061B2:
   move.w   (a0)+,d0
   cmp.w    #6,d0
   bgt      lblE061D2
   tst.w    d0
   blt      lblE061D2
   asl.w    #2,d0
   lea      scmd_tab,a1
   movea.l  0(a1,d0.w),a1
   jmp      (a1)
lblE061D2:
   clr.l    d0
   rte

scmd_tab:
   dc.l  lblE061D6
   dc.l  lblE0620C
   dc.l  lblE0623E
   dc.l  lblE06266
   dc.l  lblE06292
   dc.l  lblE062BA
   dc.l  lblE062E2
   
lblE061D6:
   move.w   (a0),d0
   bmi      lblE061FC
   asl.w    #4,d0
   and.w    #$f00,d0
   andi.w   #$f0ff,ch_attenuation.w
   or.w     d0,ch_attenuation.w
   move.w   ch_attenuation.w,_snd_ch_att
lblE061FC:
   clr.l    d0
   move.w   ch_attenuation.w,d0
   and.w    #$f00,d0
   asr.w    #4,d0
   rte
   
lblE0620C:
   move.w   (a0),d0
   bmi      lblE06230
   and.w    #$f0,d0
   andi.w   #$ff0f,ch_attenuation.w
   or.w     d0,ch_attenuation.w
   move.w   ch_attenuation.w,_snd_ch_att
lblE06230:
   clr.l    d0
   move.w   ch_attenuation.w,d0
   and.w    #$f0,d0
   rte
   
lblE0623E:
   move.w   (a0),d0
   bmi      lblE06258
   and.w    #$f0,d0
   andi.w   #$ff0f,$ffff8938.w
   or.w     d0,$ffff8938.w
lblE06258:
   clr.l    d0
   move.w   $ffff8938.w,d0
   and.w    #$f0,d0
   rte
   
lblE06266:
   move.w   (a0),d0
   bmi      lblE06282
   asr.w    #4,d0
   and.w    #$f,d0
   andi.w   #$fff0,$ffff8938.w
   or.w     d0,$ffff8938.w
lblE06282:
   clr.l    d0
   move.w   $ffff8938.w,d0
   and.w    #$f,d0
   asl.w    #4,d0
   rte
   
lblE06292:
   move.w   (a0),d0
   bmi      lblE062AC
   and.w    #3,d0
   andi.w   #$fffc,$ffff8936.w
   or.w     d0,$ffff8936.w
lblE062AC:
   clr.l    d0
   move.w   $ffff8936.w,d0
   and.w    #3,d0
   rte
   
lblE062BA:
   move.w   (a0),d0
   bmi      lblE062D6
   asl.w    #8,d0
   and.w    #$300,d0
   andi.w   #$fcff,$ffff8938.w
   or.w     d0,$ffff8938.w
lblE062D6:
   clr.l    d0
   move.w   $ffff8938.w,d0
   asr.w    #8,d0
   rte
   
lblE062E2:
   move.w   (a0),d0
   bmi      lblE062FC
   and.w    #3,d0
   andi.w   #$fffc,$ffff8920.w
   or.w     d0,$ffff8920.w
lblE062FC:
   clr.l    d0
   move.w   $ffff8920.w,d0
   and.w    #3,d0
   rte

;
;Xbios 131
;long setbuffer(int reg,long begaddr,long endaddr);
;
setbuffer:
;lblE06340:
   tst.w    (a0)+
   beq      lblE06354
   bset.b   #7,$ffff8901.w
   bra      lblE0635C
lblE06354:
   bclr     #7,$ffff8901.w
lblE0635C:
   clr.w    d0
   move.b   3(a0),d0
   move.w   d0,$ffff8906.w
   move.b   2(a0),d0
   move.w   d0,$ffff8904.w
   move.b   1(a0),d0
   move.w   d0,$ffff8902.w
   
   move.b   7(a0),d0
   move.w   d0,$ffff8912.w
   move.b   6(a0),d0
   move.w   d0,$ffff8910.w
   move.b   5(a0),d0
   move.w   d0,$ffff890e.w
   clr.l    d0
   rte

;
;Xbios 132
;long setmode(int mode);
;
setmode:
;lblE0639E:
   move.w   (a0),d0
   asl.w    #6,d0
   andi.w   #$ff3f,$ffff8920.w
   or.w     d0,$ffff8920.w
   clr.l    d0
   rte

;
;Xbios 133
;long settracks(int playtracks,int rectracks);
;
settracks:
;lblE063B6:
   move.w   (a0)+,d0
   asl.w    #8,d0
   andi.w   #$fcff,$ffff8920.w
   or.w     d0,$ffff8920.w
   move.w   (a0)+,d0
   asl.w    #8,d0
   andi.w   #$fcff,$ffff8936.w
   or.w     d0,$ffff8936.w
   clr.l    d0
   rte

;
;Xbios 134
;long setmontracks(int montrack);
;
setmontracks:
;lblE063E2:
   move.w   (a0),d0
   asl.w    #8,d0
   asl.w    #4,d0
   andi.w   #$cfff,$ffff8920.w
   or.w     d0,$ffff8920.w
   clr.l    d0
   rte

;
;Xbios 135
;long setinterrupt(int src_inter,int cause);
;
setinterrupt:
;lblE063FC:
   move.w   $ffff8900.w,d1
   move.w   2(a0),d0
   asl.w    #8,d0
   tst.w    (a0)
   bne      lblE0641A
   asl.w    #2,d0
   and.w    #$f3ff,d1
   bra      lblE0641E
lblE0641A:
   and.w    #$fcff,d1
lblE0641E:
   or.w     d1,d0
   move.w   d0,$ffff8900.w
   clr.l    d0
   rte
   
lblE0642A:
   moveq    #-1,d0
   rte

;
;Xbios 136
;long buffoper(int mode);
;
buffoper:
;lblE066FE:
   move.w   (a0),d0
   bmi      lblE0674A
   move.w   $ffff8900.w,d1
   and.w    #$ff00,d1
   btst     #1,d0
   beq      lblE0671C
   bset  #1,d1
lblE0671C:
   btst     #3,d0
   beq      lblE06728
   bset  #5,d1
lblE06728:
   btst     #0,d0
   beq      lblE06734
   bset  #0,d1
lblE06734:
   btst     #2,d0
   beq      lblE06740
   bset #4,d1
lblE06740:
   move.w   d1,$ffff8900.w
   clr.l    d0
   rte
   
lblE0674A:
   clr.l    d0
   btst     #1,$ffff8901.w
   beq      lblE0675C
   bset  #1,d0
lblE0675C:
   btst     #5,$ffff8901.w
   beq      lblE0676C
   bset  #3,d0
lblE0676C:
   btst     #0,$ffff8901.w
   beq      lblE0677C
   bset #0,d0
lblE0677C:
   btst     #4,$ffff8901.w
   beq      lblE0678C
   bset #2,d0
lblE0678C:
   rte

;
;Xbios 137
;long dsptristate(int dspxmit,int dsprec);
;
dsptristate:
;lblE0642E:
   tst.w    (a0)+
   beq      lblE06442
   bset.b   #7,$ffff8931.w
   bra      lblE0644A
lblE06442:
   bclr     #7,$ffff8931.w
lblE0644A:
   tst.w    (a0)
   beq      lblE0645E
   bset.b   #7,$ffff8933.w
   bra      lblE06466
lblE0645E:
   bclr     #7,$ffff8933.w
lblE06466:
   clr.l    d0
   rte

;
;Xbios 138
;long gpio(int mode,int data);
;
gpio:
;lblE0646A:
   clr.l    d0
   move.w   (a0)+,d1
   beq      lblE06498
   cmpi.w   #1,d1
   beq      lblE0648C
   move.w   (a0),d0
   move.w   d0,$ffff8942.w
   clr.l    d0
   rte

lblE0648C:
   move.w   $ffff8942.w,d0
   and.w    #7,d0
   rte

lblE06498:
   move.w   (a0),d0
   and.w    #7,d0
   move.w   d0,$ffff8940.w
   clr.l    d0
   rte

;
;Xbios 139
;long devconnect(int src,int dst,int srcclk,int prescale,int protocol);
devconnect:
      move.w   (a0)+,d0          ;src
      move.w   (a0)+,d1          ;dst
      move.w   (a0)+,d2          ;srcclk
      move.w   2(a0),-(sp)       ;protocol
      move.w   (a0),-(sp)        ;prescale
      move.w   d2,-(sp)
      move.w   d1,-(sp)
      move.w   d0,-(sp)
      bsr.b    _devcon
      lea      10(sp),sp
      rte
      
_devcon:
;lblE064AA:
 move.w   4(sp),d0
 bmi      lblE064C8
 cmp.w    #3,d0
 bgt      lblE064C8
 asl.w    #2,d0
 lea      devco_tab,a0
 movea.l  0(a0,d0.w),a0
 jmp      (a0)
lblE064C8:
 clr.l    d0
 rts

;lblE48F6A
devco_tab:
   dc.l  DMAPLAY
   dc.l  DSPXMIT
   dc.l  EXTINP
   dc.l  MicroPSG

MicroPSG:   
;lblE064CC:
 andi.w   #$fff,$ffff8930.w
 btst     #0,9(sp)            ;<srcclk> zulässig 0: 25,175 MHz oder 1: External Clock
 beq      lblE065B4
 ori.w    #$6000,$ffff8930.w     ;vorher: $2000
 bra      lblE0659C
 
EXTINP: 
 move.w   8(sp),d0
; asl.w    #8,d0
; asl.w    #1,d0
; andi.w   #$f0ff,$ffff8930.w ;Löschen und HS on
; or.w     d0,$ffff8930.w
   asl.w #1,d0
   and.b #$f0,$ffff8930.w  ;Löschen und HS on
   or.b  d0,$ffff8930.w
   
; bset.b #0,$ffff8930.w
; tst.w    $c(sp)
; bne      lblE06592       ;Disable HS
; bclr     #0,$ffff8930.w  ;Enable HS

   tst.w $c(sp)
   beq.b    lblE06592
   bset.b   #0,$ffff8930.w ;Disable HS

 bra      lblE06592

DSPXMIT:
 move.w   8(sp),d0         ;srcclk
 asl.w    #5,d0
 andi.w   #$ff8f,$ffff8930.w  ;Löschen und HS on
 or.w     d0,$ffff8930.w
; bset.b #4,$ffff8931.w
; tst.w    $c(sp)
; bne      lblE06592       ;Disable HS
; bclr     #4,$ffff8931.w  ;Enable HS

   tst.w $c(sp)
   beq.b lblE06592
   bset.b   #4,$ffff8931.w ;Disable HS
   
 bra      lblE06592

DMAPLAY:
 move.w   8(sp),d0         ;srcclk
 asl.w    #1,d0
 andi.w   #$fff0,$ffff8930.w
 or.w     d0,$ffff8930.w
 
 bset.b  #0,$ffff8931.w
 tst.w    $c(sp)
 bne      lblE06592        ;Disable HS
 bclr     #3,$ffff8931.w   ;HS on, dest DSP-REC
 btst     #1,7(sp)         ;dst?
 bne      lblE0658A        ;dst==DSP Receive
 bset.b  #3,$ffff8931.w    ;dst!=DSP Receive
lblE0658A:
 bclr     #0,$ffff8931.w   ;Enable HS

lblE06592:
 btst     #0,9(sp)         ;srcclk
 beq      lblE065B4        ;internal clock

lblE0659C:
 move.w   $a(sp),d0        ;prescale
; andi.w   #$ff,$ffff8934.w   ;Freq. divider external clock
; asl.w    #8,d0
; or.w     d0,$ffff8934.w
   move.b   d0,$ffff8934.w
 bra      lblE065CC

lblE065B4:
 move.w   $a(sp),d0           ;prescale
; andi.w   #$ff00,$ffff8934.w ;STe compatible mode
; or.w     d0,$ffff8934.w
   move.b   d0,$ffff8935.w

lblE065CC:
 move.w   $ffff8932.w,d2      ;Crossbar Destination Controller
 move.w   6(sp),d1            ;dst
 btst     #0,d1               ;DMA Record?
 beq      lblE06606           ;nein
 move.w   4(sp),d0            ;src
 asl.w    #1,d0
 and.w    #$fff0,d2
 or.w     d0,d2
 bset    #0,d2
 tst.w    $c(sp)
 bne      lblE06606           ;Disable HS
 bclr     #0,d2
 bclr     #3,d2
 cmpi.w   #1,4(sp)            ;DSPXMIT?
 beq      lblE06606           ;nein
 bset #3,d2                   ;HS ON, src DSPXMIT

lblE06606:
 btst     #1,d1               ;dst == DSP Receive?
 beq      lblE0662A           ;nein
 move.w   4(sp),d0            ;src
 asl.w    #5,d0
 and.w    #$ff8f,d2
 or.w     d0,d2
 bset #4,d2       
 tst.w    $c(sp)
 bne      lblE0662A           ;Disable HS
 bclr     #4,d2               ;Enable HS
lblE0662A:
 btst     #2,d1               ;dst == External out?
 beq      lblE06650           ;nein
 move.w   4(sp),d0            ;src
 asl.w    #8,d0
 asl.w    #1,d0
 and.w    #$f0ff,d2
 or.w     d0,d2
 or.w     #$100,d2
 tst.w    $c(sp)
 bne      lblE06650           ;Disable HS
 and.w    #$feff,d2           ;Enable HS
lblE06650:
 btst     #3,d1               ;dst == DAC?
 beq      lblE06666           ;nein
 move.w   4(sp),d0            ;src
 asl.w    #8,d0
 asl.w    #5,d0
 and.w    #$fff,d2
 or.w     d0,d2
lblE06666:
 move.w   d2,$ffff8932.w
 rts

;
;Xbios 140
;long sndstatus(int reset);
;
sndstatus:
;lblE0666E:
   tst.w    (a0)
   beq      lblE0668E
   bsr      lblE0669C
   bsr      lblE066D8
   bset.b   #3,$ffff8937.w ;Mit der Leitung klappern
   bclr     #3,$ffff8937.w

lblE0668E:
   move.w   $ffff893c.w,d0
   asr.w    #4,d0
   and.w    #$3f,d0
   rte

lblE0669C:
   move.w   ch_attenuation.w,_snd_ch_att
   andi.w   #$f00f,_snd_ch_att
   andi.w   #$f11f,ch_attenuation.w
   andi.w   #$f22f,ch_attenuation.w
   andi.w   #$f44f,ch_attenuation.w
   andi.w   #$f88f,ch_attenuation.w
   bset.b   #2,$ffff8938.w
   rts

lblE066D8:
   andi.w   #$f00f,ch_attenuation.w
   move.w   _snd_ch_att,d0
   and.w    d0,ch_attenuation.w
   andi.w   #$f3ff,$ffff8938.w
   nop
   nop
   nop
   nop
   rts

;
;Xbios 141
;long buffptr(pointer);
;
buffptr:
;lblE0678E:
   movea.l  (a0),a0
   clr.l -(sp)
   bclr     #7,$ffff8901.w
   move.w   $ffff890c.w,d0
   move.w   $ffff890a.w,d1
   move.w   $ffff8908.w,d2
   move.b   d0,3(sp)
   move.b   d1,2(sp)
   move.b   d2,1(sp)
   move.l   (sp),(a0)+
   bset.b   #7,$ffff8901.w
   move.w   $ffff890c.w,d0
   move.w   $ffff890a.w,d1
   move.w   $ffff8908.w,d2
   move.b   d0,3(sp)
   move.b   d1,2(sp)
   move.b   d2,1(sp)
   move.l   (sp)+,(a0)
   clr.l    d0
   rte

;--------------------------------------
;
;Länge der LOD-Datei über Fseek ermitteln (keine DTA notwendig),
;Puffer allozieren und Datei laden
;
;Eingaben
;  a0:   Zeiger auf Dateiname
;
;Ausgabe
;  d0:   Pufferadr oder 0L
;  a0:   LOD-Endadresse
;
read_LODfile:
   movem.l  d5-d7,-(sp) ;sichern
   
   clr.w    -(sp)       ;READ_ONLY
   move.l   a0,-(sp)    ;Zeiger auf den Dateinamen
   move.w   #$3d,-(sp)  ;Fopen
   trap     #GEMDOS
   addq.l   #8,sp
   move.l   d0,d7       ;handle
   bpl.b    get_LOD_len ;Datei vorhanden
   moveq    #0,d0       ;Fehler aufgetreten
   bra.b    exit_read_LODfile

get_LOD_len:
   move.w   #2,-(sp)    ;ans Dateiende
   move.w   d7,-(sp)    ;handle
   clr.l    -(sp)       ;offset
   move.w   #$42,-(sp)  ;Fseek
   trap     #GEMDOS
   lea      10(sp),sp
   move.l   d0,d6       ;Dateilänge
   bgt.b    seek_LOD_start ;Datei > 0 Bytes
   moveq    #0,d0       ;Fehler aufgetreten
   bra.b    exit_read_LODfile

seek_LOD_start:
   clr.w    -(sp)       ;an Dateianfang
   move.w   d7,-(sp)    ;handle
   clr.l    -(sp)       ;offset
   move.w   #$42,-(sp)  ;Fseek
   trap     #GEMDOS
   lea      10(sp),sp

   move.l   d6,-(sp)    ;Dateilänge
   move.w   #$48,-(sp)  ;Malloc
   trap     #GEMDOS
   addq.l   #6,sp
   move.l   d0,d5       ;Pufferadresse
   bne.b    _read_LOD
   moveq    #0,d0       ;Fehler aufgetreten
   bra.b    exit_read_LODfile

_read_LOD:
   move.l   d5,-(sp)    ;Puffer
   move.l   d6,-(sp)    ;count
   move.w   d7,-(sp)    ;handle
   move.w   #$3f,-(sp)  ;Fread
   trap     #GEMDOS
   lea      12(sp),sp
   cmp.l    d0,d6       ;alle Bytes gelesen?
   beq.b    _close_LOD
   moveq    #0,d0       ;Fehler aufgetreten
   bra.b    exit_read_LODfile

_close_LOD:
   move.w   d7,-(sp)    ;handle
   move.w   #$3e,-(sp)  ;Fclose
   trap     #GEMDOS
   addq.l   #4,sp
   
   move.l   d5,a0       ;Pufferadr
   adda.l   d6,a0       ;Puffer + Länge = _dsp_LOD_endadr

   move.l   d5,d0       ;Pufferadr != 0: alles ok
exit_read_LODfile:
   movem.l  (sp)+,d5-d7 ;Register zurück
   rts   

;
;LOD-Datei in Binärformat konvertieren
;
;Eingaben
;  a0: *LOD-Datei ,aktuelle Dateiposition
;  a1: *codeptr
;  a2: Endadr. des LOD-Files
;
;Ausgabe
;  d0:   _dsp_bin_len
;
conv_LOD_to_bin:
   move.l   a1,-(sp)             ;_dsp_bin_ptr
   clr.l    -(sp)                ;_dsp_bin_len
   bra.s    lblE05D18
   
lblE05D02:
   subq.w   #1,d0                ;Index aus cmp_keyw: Schlüsselwort 1, DATA?
   bne.s    lblE05D14            ;nein -> überspringe Zeile, suche nach Schlüsselwort ...
   addq.l   #4,a0                ;Länge von 'DATA' auf akt. Dateipos.
   move.l   (sp), d0             ;bin_len
   move.l   4(sp),a1             ;bin_ptr
   bsr      conv_DATA_args       ;wandle Daten hinter DATA-Token, neue Dateiposition in a0
   move.l   d0,(sp)              ;aktuelle Länge der DSP-Binärdaten
   bra.s    lblE05D20            ;vergleiche mit Schlüsselworten
 
lblE05D14:
   move.l   a2,a1                ;_dsp_LOD_endadr
   bsr      skip_line            ;Zeilenden ermitteln und Zeile überspringen -> neue Pos in a0
lblE05D18:
   cmp.b    #'_',(a0)
   bne.b    lblE05D14            ;kein Unterstrich -> nächste Zeile
   addq.l   #1,a0                ;aktuelle Dateipos. auf nächstes Zeichen
   
lblE05D20:
   move.l   a0,-(sp)             ;akt. Dateiposition sichern
   bsr      cmp_keyw             ;Vergleich mit den Schlüsselworten, aktuelle Dateiposition unverändert!
   move.l   (sp)+,a0
   cmp.w    #5,d0                ;Schlüsselwort 5, END?
   bne.s    lblE05D02            ;nein, dann weiter suchen

   move.l   (sp)+,d0             ;_dsp_bin_len
   addq.l   #4,sp
   rts
   
;
;Vergleiche ab aktueller Dateiposition mit Schlüsselwörtern
;
;Eingabe
;  a0:   Zeiger auf aktuelle Dateiposition
;
;Ausgabe
;  d0: Index (0-5) oder 6 (Fehler)
;zerstört a0-a1/d1-d2
;
cmp_keyw:
   movem.l  d3/a3-a5,-(sp)
   move.l   a0,a3             ;Zeiger auf aktuelle Dateiposition
   moveq    #0,d3
   lea      token_adr,a5      ;Tabelle mit Zeigern auf Schlüsselworte
   lea      token_len,a4      ;Tabelle mit Längen der Schlüsselworte
   bra.s    chk_keyw_index
   
lblE05988:
   move.w   (a4)+,d0          ;Länge des Strings ohne Nullbyte
   move.l   (a5)+,a1          ;Zeiger auf den String
   move.l   a3,a0             ;Zeiger auf die aktuelle Zeilenposition
   bsr      strn_cmp          ;vergleiche Zeichen der angegebenen Länge
   tst.w    d0                ;Strings gleich?
   bne.s    lblE059AA         ;ja -> raus mit Index in d7 (->d0)
   
   addq.w   #1,d3             ;Index erhöhen
chk_keyw_index:
   cmp.w    #6,d3             ;Index > 5?
   blt.s    lblE05988
lblE059AA:
   move.l   d3,d0             ;Index des Schlüsselworts
   movem.l  (sp)+,d3/a3-a5
   rts

;
;Vergleiche ab aktueller Dateiposition mit Schlüsselwort der angegebenen Länge
;
;Eingaben
;  a0:   Zeiger auf aktuelle Dateiposition
;  a1:   Zeiger auf Schlüsselwort
;  d0:   Länge des Schlüsselworts (W)
;
;Ausgabe
;  d0: 0 falls Strings unterschiedlich, 1 falls identisch
;zerstört a0-a1/d1-d2
;
strn_cmp:
   bra.s    lblE05940

lblE05926:
   move.b   (a0)+,d2
   move.b   (a1)+,d1
   cmp.b    d1,d2          ;gleiches Zeichen?
   beq.s    lblE05940
   addi.b   #$20,d1
   cmp.b    d1,d2          ;Zeichen evtl. klein?
   beq.s    lblE05940

   moveq    #0,d0          ;unterschiedlicher String
   rts
   
lblE05940:
   subq.w   #1,d0          ;Länge dec.
   bpl.b    lblE05926      ;noch nicht alle Zeichen verglichen ...
   moveq    #1,d0          ;Strings identisch 
   rts

;
; Suche Zeilenende und überspringe diese Zeile
;
;Eingabe
;  a0:   aktuelle Zeilenposition
;  a1:   Endadr. der LOD-Datei
;Ausgabe
;  a0:   neue Dateiposition
;zerstört a1
;
skip_line:
tst_CR:
   cmp.b    #13,(a0)+            ;Zeilenende?
   beq.b    tst_endadr
   cmpa.l   a1,a0
   bls.b    tst_CR
   
tst_endadr:    
   cmpa.l   a1,a0                ;bereits am Dateiende?
   bhi.s    exit_skip_line       ;ja
   addq.l   #1,a0                ;CR/LF überspringen
exit_skip_line:
   rts

;
;LOD-File: DATA-Instruktion bearbeiten
;          Speicherbereich erkennen und 4-stellige ASCII-Zahl konvertieren
;
;Eingabe
;  a0:   Zeiger auf Zeichen P/X/Y hinter 'DATA'
;  a1:   Zeiger auf Anfang der DSP-Binärdaten
;  a2:   Endadr. des LOD-Files
;  d0:   Länge der DSP-Binärdaten
;Ausgabe
;  a0:   aktuelle Dateiposition
;  d0:   Länge der Binärdaten
conv_DATA_args:
   movem.l  d3-d5/a3,-(sp)
   move.l   a1,a3
   move.l   d0,d3
   
_chk_spaces:
   cmp.b    #32,(a0)+            ;Leerzeichen?
   beq.s    _chk_spaces          ;Leerzeichen überspringen

   move.b   -1(a0),d0            ;Zeichen

   move.l   a3,a1
   adda.l   d3,a1                ;aktuelle Position
   clr.b    (a1)+
   clr.b    (a1)+

   cmp.b    #'P',d0              ;Programm-Data?
   bne.s    lblE05ADC
 
   clr.b    (a1)+
   bra.s    lblE05AFA

lblE05ADC:
   cmp.b    #'X',d0              ;X-Mem-Data?
   bne.s    lblE05AEE
   move.b   #1,(a1)+
   bra.s    lblE05AFA

lblE05AEE:                 
   move.b   #2,(a1)+             ;dann "muß" es Y-Mem-Data sein ...

lblE05AFA:

   moveq    #4,d0                ;4-stellige ASCII-Zahl ab Dateipos. konvertieren
   addq.l   #1,a0                ;hinter P/X/Y muß ein Leerzeichen stehen, dann die ASCII-Zahl
   bsr      cnv_asci_hex         ;-> Zahl in d0, akt. Pos in a0, a1 unverändert!

   clr.b    (a1)+                ;Hi-Byte löschen
   move.b   d0,1(a1)             ;Lo-Byte eintragen
   asr.w    #8,d0
   move.b   d0,(a1)              ;Mid-Byte eintragen
   
   addq.l   #6,d3                ;_dsp_bin_len
   move.l   d3,d4                ;Offset zu _dsp_bin_ptr
   clr.w    d5                   ;Anzahl der gefunden 6-stelligen Zahlen
   addq.l   #3,d3

   move.l   a2,a1                ;Endadr. des LOD-Files
   bsr      skip_line            ;aktuelle Dateiposition in a0
   bra.s    lblE05CA0            ;'DATA P/X/Y' konvertieren und zum Anfang der nächsten Zeile
 
lblE05C8A:
   cmp.b    #13,(a0)             ;CR?
   bne.s    lblE05C00            ;nein, Leerzeichen überspringen, Zahlen konvertieren
   
   move.l   a2,a1                ;Endadr. des LOD-Files
   bsr      skip_line
   bra.s    lblE05CA0

lblE05C00:
   cmp.b    #32,(a0)+            ;Leerzeichen?
   beq.s    lblE05C00            ;Leerzeichen überspringen
   subq.l   #1,a0
   
   cmp.b    #13,(a0)             ;CR?
   beq.s    lblE05CA0            ;Zeilenende erreicht
 
   moveq    #6,d0                ;6-stellige ASCII-Zahl in Binärdarstellung wandeln
   bsr      cnv_asci_hex         ;-> konvertierte Zahl in d0

   move.l   a3,a1                ;_dsp_bin_ptr
   addq.l   #3,d3                ;_dsp_bin_len um hinzukommende Bytes erhöhen
   adda.l   d3,a1                ;mit Lo-Byte beginnend eintragen
   move.b   d0,-(a1)             ;Lo-Byte
   lsr.l    #8,d0
   move.b   d0,-(a1)             ;Mid-Byte
   lsr.l    #8,d0
   move.b   d0,-(a1)             ;Hi-Byte
   addq.w   #1,d5                ;Anzahl der eingetragenen 6-stelligen DATA-Werte
 
lblE05C1C:
   cmp.b    #13,(a0)
   bne.s    lblE05C00            ;Zeilenende noch nicht erreicht

lblE05CA0:
   cmp.b    #'_',(a0)            ;Unterstrich?
   bne      lblE05C8A            ;kein Unterstrich gefunden

   addq.l   #1,a0                ;nächstes Zeichen
 
   movea.l  a3,a1                ;_dsp_bin_ptr
   adda.l   d4,a1                ;Offset zum Beginn der Binärdaten, Anzahld der DATA-Werte eintragen
   clr.b    (a1)+                ;Hi-Byte löschen
   move.b   d5,1(a1)             ;Lo-Byte eintragen
   lsr.w    #8,d5
   move.b   d5,(a1)              ;Mid-Byte eintragen

   move.l   d3,d0                ;_dsp_bin_len zurückliefern
   movem.l  (sp)+,d3-d5/a3
   rts

;
;Konvertiere Hex-ASCII-Zahl mit 1-8 Ziffern in Binärdarstellung
;
;Eingaben
;  a0:   Zeiger auf ASCII-Zahl
;  d0:   Anzahl der Ziffern
;
;Ausgaben
;  d0:   gewandelte Zahl in Binärdarstellung
;  a0:   zeigt hinter ASCII-Zahl
;zerstört d1-d2
;
cnv_asci_hex:
   moveq    #0,d1          ;löschen
   bra      cnv_dbra

cnv_loop:
   lsl.l    #4,d1          ;Platz für die nächste Ziffer

   moveq    #-'0',d2       ;'0'
   add.b    (a0)+,d2       ;ASCII-Zeichen
   cmp.b    #'9'-'0',d2    ;Ziffer von '0' bis '9'?
   bls.b    ins_digit

   sub.b    #'A'-'0',d2
   cmp.b    #'F'-'A',d2    ;Ziffer von 'A' bis 'F'?
   bls.b    ins_cipher

   sub.b    #'a'-'A',d2
   cmp.b    #'f'-'a',d2    ;Ziffer von 'a' bis 'f'?
   bhi.b    cnv_dbra

ins_cipher:
   add.b    #10,d2         ;10 addieren für Bereich a bis f

ins_digit:
   add.b    d2,d1          ;Ziffer hinzufügen
      
cnv_dbra:
   dbra     d0,cnv_loop
   
   move.l   d1,d0          ;der gewandelte Binärwert ...
   rts
   
;-----------------------------------------
EVEN 
tok_strt:      dc.b  'START',0
tok_data:      dc.b  'DATA',0
tok_blkdata:   dc.b  'BLOCKDATA',0
tok_symb:      dc.b  'SYMBOL',0
tok_comment:   dc.b  'COMMENT',0
tok_end:       dc.b  'END',0

EVEN
token_adr:
;lblE48EE2:
   dc.l  tok_strt
   dc.l  tok_data
   dc.l  tok_blkdata
   dc.l  tok_symb
   dc.l  tok_comment
   dc.l  tok_end

token_len:
;lblE48EFA:
   dc.w  5,4,9,6,7,3    ;Länge der Schlüsselworte


EVEN

lblE48B24:     ;246 Bytes = 82 DSP-Worte
 DC.L     $af08000,$400000,0            
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     $bf08000,$7f000bf0,$80007eef  
 DC.L     $bf08000,$7edc0bf0,$80007f00  
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     $8f4a800,$408f4,$bf000c00     
 DC.L     $feb808,$f4a00000,$108f4be    
 DC.L     $60,$f400007e,$a9319800       
 DC.L     $6d10000,$500aa9,$8000004e    
 DC.L     $8586b0c                      
 DC.W     $5108                         

EVEN

lblE48C1A:        ;152 DSP-Worte = 456 Bytes
 DC.L     $8f4a000,$108f4,$be000000     
 DC.L     $aa98000,$7ead2000,$13084c2b  
 DC.L     $45f40000,$32000,$650ea000    
 DC.L     $aa98000,$7eb50850,$2b0aa980  
lblE48C4A:
 DC.L     $7eb808,$512b45f4,1           
 DC.L     $2000650a,$f0aa007e,$ce45f400 
 DC.W     0                      
lblE48C64:
 DC.L     $2200065,$af0aa00,$7ed50af0   
 DC.L     $80007ec7,$6d10000,$7ecb0aa9  
 DC.L     $80007ec9,$8586b0a,$f080007e  
 DC.L     $ad06d100                     
 DC.W     $7e                           
lblE48C8E:
 DC.L     $d20aa980,$7ed008,$58ab0af0   
 DC.L     $80007ead,$6d10000,$7ed90aa9  
 DC.L     $80007ed7,$858eb0a,$f080007e  
 DC.L     $ad08f4a0,$108,$f4be0000      
 DC.L     $aa980,$7ee008,$502b0aa9      
 DC.L     $80007ee3,$8512b0a,$a980007e  
 DC.L     $e608522b,$6d20000,$7eec07d0  
 DC.L     $8c07518c,0,$408f4            
 DC.L     $a0000001,$8f4be00,$aa9       
 DC.L     $80007ef3,$8502b0a,$a980007e  
 DC.L     $f608512b,$6d10000,$7efd0aa9  
 DC.L     $80007efb,$8586b00            
lblE48D1A:
 DC.L     0,$408f4a0,$108               
 DC.L     $f4be0000,$aa980,$7f0420      
 DC.L     $13084c,$2b45f400,$120        
 DC.L     $650af0,$aa007f23,$45f40000   
 DC.L     $22000,$650af0aa,$7f320a      
 DC.L     $f080007f                     
lblE48D5A:
 DC.L     $140aa980,$7f1408,$502b0aa9   
 DC.L     $80007f17,$8512b06,$d100007f  
 DC.L     $2007d88c,$aa98100,$7f1d5470  
 DC.L     $ffeb,0,$40aa9                
 DC.L     $80007f23,$8502b0a,$a980007f  
 DC.L     $2608512b,$6d10000,$7f2f54d8  
 DC.L     $aa981,$7f2c54,$700000ff      
 DC.L     $eb000000,$40a,$a980007f      
 DC.L     $3208502b,$aa98000,$7f350851  
 DC.L     $2b06d100,$7f3e5c,$d8000aa9   
 DC.L     $81007f3b,$54700000,$ffeb0000 
 DC.L     4                             


lblE48DE2:     ;213 Bytes = 71 DSP-Worte     
 DC.L     $af08000,$400000,0            
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     0,0,0                         
 DC.L     $8f4a800,$408f4,$bf000c00     
 DC.L     $feb80a,$f080007e             
 dc.b    $a9


EVEN

lblE48F06:     ;72 Bytes = 24 DSP-Worte
 DC.L     0,$2a0000,$140bf080          
 DC.L     $7eef0b,$f080007e,$dc0bf080  
 DC.L     $7f000b,$f0800000,$bf080     
 DC.L     $b,$f0800000,$bf080          
 DC.L     $b,$f0800000,$bf080          
 DC.L     $b,$f0800000,3               
;---------------------------------------------



