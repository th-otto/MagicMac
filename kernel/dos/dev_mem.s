**********************************************************************
*
* Dieses Modul enthaelt die Dateitreiber fuer Speicherbloecke, d.h.
*
*  FT_MEMBLK        virtuelle Verzeichnisse
*  FT_SHM           shared memory
*  FT_PROCESS       Prozess
*

DEBUG     EQU  16

     INCLUDE "errno.inc"
     INCLUDE "structs.inc"
     INCLUDE "kernel.inc"
     INCLUDE "basepage.inc"
     INCLUDE "magicdos.inc"

     XDEF memblk_drv
     XDEF shm_drv,shm_create
     XDEF proc_drv,proc_create


     XREF Memshare,Memunsh
     XREF vmemcpy
     XREF strlen


; unterstuetzte Fcntl- Modi:

SHMGETBLK      EQU  $4d00
SHMSETBLK      EQU  $4d01

;PPROCADDR     EQU  $5001          ; *arg = ProcessControlStructure
PBASEADDR      EQU  $5002          ; *arg = Basepage
;PCTXTSIZE     EQU  $5003          ; *arg = Laenge der ProcessContextStructure
                                   ;        (2 Stueck liegen vor der
                                   ;         ProcessControlStructure)
;PSETFLAGS     EQU  $5004          ; Malloc-Modus = arg
;PGETFLAGS     EQU  $5005          ; *arg = Malloc-Modus
;PTRACESFLAGS  EQU  $5006
;PTRACEGFLAGS  EQU  $5007
;PTRACEGO      EQU  $5008
;PTRACEFLOW    EQU  $5009
;PTRACESTEP    EQU  $500a
PLOADINFO      EQU  $500c          ; Fuelle (struct ploadinfo *) arg


	TEXT


memblk_drv:
 DC.L     memblk_open
 DC.L     memblk_close
 DC.L     memblk_read
 DC.L     memblk_write
 DC.L     0                   ; kein stat
 DC.L     memblk_lseek
 DC.L     0                   ; normales Fdatime()
 DC.L     0                   ; kein ioctl
 DC.L     memblk_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc

shm_drv:
 DC.L     shm_open
 DC.L     shm_close
 DC.L     shm_read
 DC.L     shm_write
 DC.L     shm_stat
 DC.L     shm_lseek
 DC.L     0                   ; normales Fdatime()
 DC.L     shm_ioctl
 DC.L     shm_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc

proc_drv:
 DC.L     proc_open
 DC.L     proc_close
 DC.L     abs_read
 DC.L     abs_write
 DC.L     proc_stat
 DC.L     proc_lseek
 DC.L     0                   ; normales Fdatime()
 DC.L     proc_ioctl
 DC.L     proc_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc


**********************************************************************
*
* long memblk_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Pseudodateien ignoriert
*

;memblk_open  EQU  shm_close


**********************************************************************
*
* long shm_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*
; shm_read  EQU  memblk_read



**********************************************************************
*
* long memblk_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Da es ein Verzeichnis ist, muss die Funktion beruecksichtigt werden,
* die bei a1 == NULL die Pufferadresse liefert.
* d0 wird als "int" behandelt!
*

abs_read:
 suba.l   a2,a2
 bra.b    _memblk_read
shm_read:
memblk_read:
 move.l   fd_xdata(a0),a2
_memblk_read:
 exg      a1,a0                    ; a0 = Zielpuffer oder NULL
 add.l    fd_fpos(a1),a2           ; a2 ist Lese/Schreibposition
 add.l    d0,fd_fpos(a1)           ; fseek schon ausfuehren
 move.l   a0,d2
 beq.b    mbr_ptr                  ; Pufferadresse zurueckgeben
;move.l   a0,a0                    ; dst
 move.l   a2,a1                    ; src
;move.w   d0,d0
 move.w   d0,-(sp)
 jsr      vmemcpy
 moveq    #0,d0
 move.w   (sp)+,d0                 ; auf Word verkleinern
 rts
mbr_ptr:
 move.l   a2,d0
 rts



**********************************************************************
*
* long memblk_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* d0 wird als "int" behandelt!
*

abs_write:
 moveq    #0,d2
 bra.b    _memblk_write
shm_write:
proc_write:
memblk_write:
 move.l   fd_xdata(a0),d2
_memblk_write:
; Schreibzugriff auf Blockgroesse einschraenken
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d1
 sub.l    fd_fpos(a0),d1
 cmp.l    d1,d0
 ble.b    mbw_weiter
 move.l   d1,d0                    ; nicht ueber Dateiende schreiben!
mbw_weiter:
 tst.l    d0
 ble.b    mbw_ende
 add.l    fd_fpos(a0),d2           ; d2 ist Lese/Schreibposition
 add.l    d0,fd_fpos(a0)           ; fseek schon ausfuehren
 move.l   d2,a0                    ; dst
;move.l   a1,a1                    ; src
;move.w   d0,d0
 move.w   d0,-(sp)
 jsr      vmemcpy
 moveq    #0,d0
 move.w   (sp)+,d0                 ; auf Word verkleinern
mbw_ende:
 rts



**********************************************************************
*
* long memblk_lseek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

shm_lseek:
memblk_lseek:
 move.l   fd_multi1(a0),a2
 tst.w    d1                       ; mode
 beq.b    ms_beg                   ; 0: vom Anfang an
 subq.w   #1,d1
 bne.b    ms_end
 add.l    fd_fpos(a0),d0           ; 1: von aktueller Position
 bra.b    ms_beg
ms_end:
 subq.w   #1,d1
 bne      ms_einvfn                ; nicht 0/1/2
 add.l    fd_len(a2),d0            ; 2: vom Ende
ms_beg:
 cmp.l    fd_len(a2),d0
 bls.b    ms_ok
 moveq    #ERANGE,d0
 rts
ms_ok:
 move.l   d0,fd_fpos(a0)
 rts
ms_einvfn:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long memblk_close(a0 = FD *f)
*

memblk_close:
 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 rts


**********************************************************************
*
* long memblk_delete( a1 = DIR *dir )
*

memblk_delete:
 moveq    #0,d0
 rts


**********************************************************************
*
* long shm_create(a0 = DIR *d)
*
* Im Gegensatz zu Pipes usw. wird beim Fcreate nur der Verzeichnis-
* eintrag erzeugt, kein Speicher alloziert.
* Die Laenge der Datei ist 0.
*

shm_create:
 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 rts


**********************************************************************
*
* long shm_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Pseudodateien ignoriert
*

shm_open:

**********************************************************************
*
* long shm_close(a0 = FD *f)
*
* Laut MTOS- Doku muss die Applikation selbst den Speicher freigeben,
* deshalb passiert hier nichts.
* Ich finde das daemlich, aber was hilft es ?
*

memblk_open:
shm_close:
 moveq    #0,d0                    ; keine Aktionen, kein Fehler
 rts


**********************************************************************
*
* long shm_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

;shm_write EQU  memblk_write


**********************************************************************
*
* long shm_lseek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

;shm_lseek EQU  memblk_lseek


**********************************************************************
*
* long shm_ioctl(a0 = FD *f, d0 = int cmd, a1 = void *buf)
*

shm_ioctl:
 cmpi.w   #FIONREAD,d0
 beq.b    shmf_fionread
 cmpi.w   #FIONWRITE,d0
 beq.b    shmf_fionwrite
 move.l   fd_multi1(a0),a0              ; Prototyp-FD !
 cmpi.w   #SHMGETBLK,d0
 beq.b    shm_get
 cmpi.w   #SHMSETBLK,d0
 beq.b    shm_set
shm_err:
 moveq    #EINVFN,d0
 rts
shm_set:
 tst.l    fd_xdata(a0)             ; schon gesetzt?
 bne.b    shm_erange               ; ja, Fehler
 tst.l    fd_parent(a0)
 beq.b    shm_err                  ; kann eigentlich nicht sein ???

 movem.l  a0/a1,-(sp)
 move.l   a1,a0                    ; memblk
 move.l   act_pd.l,a1                ; PROC
 jsr      Memshare                 ; -> d0 ist Laenge oder Fehlercode
 movem.l  (sp)+,a0/a1
 tst.l    d0
 bmi.b    shm_rts                  ; EIMBA ?
 move.l   a1,fd_xdata(a0)
 move.l   d0,fd_len(a0)
 move.l   fd_parent(a0),a2         ; a2 = Parent-FD
 move.l   fd_xdata(a2),a2          ; a2 = Daten des Parent-FD
 add.l    fd_dirpos(a0),a2         ; a2 = Unser DIR- Eintrag
 move.l   a1,dir_xdata(a2)         ; Block ins Verzeichnis eintragen
 ror.w    #8,d0
 swap     d0
 ror.w    #8,d0                    ; -> intel
 move.l   d0,dir_flen(a2)
 moveq    #0,d0
 rts
shm_erange:
 moveq    #ERANGE,d0
 rts
shm_get:
 move.l   fd_xdata(a0),d0
shm_rts:
 rts

*
* long shmf_fionread(a0 = FD *f, a1 = long *val)
* long dosf_fionwrite(a0 = FD *f, a1 = long *val)
*

shmf_fionread:
shmf_fionwrite:
 move.l   fd_multi1(a0),a2
 move.l   fd_len(a2),d0
 sub.l    fd_fpos(a0),d0
 move.l   d0,(a1)
 moveq    #0,d0
 rts


**********************************************************************
*
* long shm_delete( a1 = DIR *dir )
*
* MagiC 6.10: Der Speicherblock-Referenzzaehler wird dekrementiert.
*

shm_delete:
 move.l   dir_xdata(a1),a0
 jmp      Memunsh


**********************************************************************
*
* long shm_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*               d1 = long apcode );
*
* shared memory ist immer lese- und schreibbereit
*

proc_stat:
shm_stat:
 moveq    #1,d0
 move.l   a1,d1
 beq.b    shs_ende
 move.l   d0,(a1)
shs_ende:
 rts


**********************************************************************
*
* long proc_create(a0 = DIR *d, a1 = long arg)
*
* Die Laenge der Datei ist 0, aber wird beim Fsnext/first korrigiert.
*

proc_create:
 clr.b    dir_attr(a0)
 move.l   a1,dir_xdata(a0)         ; PD einsetzen
 moveq    #0,d0
 rts


**********************************************************************
*
* long proc_open(a0 = FD *f)
*
* fd_xdata ist bereits eingetragen. Da die Laenge hier 0 war, muss die
* korrekte Laenge eingetragen werden.
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Pseudodateien ignoriert
*

proc_close:
proc_open:
 moveq    #-1,d0
 move.l   fd_multi1(a0),a2
 move.l   d0,fd_len(a2)            ; Dateilaenge unendlich
 moveq    #0,d0                    ; kein Fehler
 rts


**********************************************************************
*
* long proc_close(a0 = FD *f)
*

;proc_close     EQU  proc_open


**********************************************************************
*
* long proc_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Hier wird wie aus einem Speicherblock gelesen.
* Man kann gnadenlos auf jeden Speicher zugreifen.
*

proc_read:
 bra      memblk_read


**********************************************************************
*
* long proc_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Hier wird wie in einen Speicherblock geschrieben.
* Man kann gnadenlos auf jeden Speicher zugreifen.
*

;proc_write     EQU  memblk_write


**********************************************************************
*
* long proc_lseek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

proc_lseek:
 tst.w    d1                       ; mode
 beq.b    ps_beg                   ; 0: vom Anfang an
 subq.w   #1,d1
 bne.b    ps_end
 add.l    fd_fpos(a0),d0           ; 1: von aktueller Position
 bra.b    ps_beg
ps_end:
 subq.w   #1,d1
 bne.b    ps_einvfn                ; nicht 0/1/2
 neg.l    d0
ps_beg:
 move.l   d0,fd_fpos(a0)
 rts
ps_einvfn:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long proc_ioctl(a0 = FD *f, d0 = int cmd, a1 = void *buf)
*

proc_ioctl:
 movem.l  a5/a6,-(sp)
 move.l   fd_multi1(a0),a0         ; Prototyp-FD
 cmpi.w   #PBASEADDR,d0
 beq.b    pio_pbaseaddr
 cmpi.w   #PLOADINFO,d0
 bne.b    pio_err
 move.l   fd_xdata(a0),a0          ; Basepage
 move.l   p_procdata(a0),d0
 beq.b    pio_err2                 ; PROCDATA ungueltig
 move.l   d0,a6                    ; a6 = PROCDATA *
 tst.b    pr_fname(a6)             ; Dateiname gueltig?
 beq.b    pio_err4                 ; nein, Fehler
 move.l   a1,a5                    ; a5 = PLOADINFO *
 lea      pr_cmdlin(a6),a1
 move.l   2(a5),a0
 move.w   #128,d0                  ; immer die ganzen 128 Bytes
 jsr      vmemcpy                   ; Kommandozeile kopieren
 lea      pr_fname(a6),a0
 jsr      strlen
 addq.l   #1,d0                    ; fuer EOS
 cmp.w    (a5),d0
 bhi.b    pio_err3                 ; Ueberlauf
 move.l   6(a5),a0
 lea      pr_fname(a6),a1
 jsr      vmemcpy                   ; Pfad kopieren
 bra.b    pio_ok
pio_err4:
 moveq    #ERROR,d0
 bra.b    pio_end
pio_err3:
 moveq    #ERANGE,d0
 bra.b    pio_end
pio_err2:
 moveq    #EACCDN,d0
 bra.b    pio_end
pio_pbaseaddr:
 move.l   fd_xdata(a0),(a1)
pio_ok:
 moveq    #0,d0
 bra.b    pio_end
pio_err:
 moveq    #EINVFN,d0
pio_end:
 movem.l  (sp)+,a5/a6
 rts


**********************************************************************
*
* long proc_delete( a1 = DIR *dir )
*

proc_delete:
 move.l   dir_xdata(a1),a0         ; Basepage
 move.w   p_procid(a0),d0          ; pid gueltig ?
 ble.b    prdel_ende               ; nein, einfach loeschen

 move.w   #SIGTERM,-(sp)
 move.w   d0,-(sp)                 ; pid
 move.w   #$111,-(sp)
 trap     #1                       ; gemdos Pkill
 addq.l   #6,sp

 tst.l    d0
 bmi.b    prdel_rts                ; irgendein Fehler
 moveq    #1,d0                    ; ignorieren, d.h. noch nix loeschen!
prdel_rts:
 rts

/*
     alte Version ohne Pkill(SIGTERM):

 moveq    #-1,d0                   ; suche nach PD
;move.l   a0,a0
 bsr      srch_process
 bmi.b    prdel_eaccdn             ; kein AES aktiv
 tst.l    d1                       ; Prozess wartet auf Kind- Terminierung ?
 bne.b    prdel_kill               ; ja, Prozess einfach killen

 subq.l   #8,sp
 move.l   sp,a0
 move.l   #'MAGX',(a0)+            ; mbuf[4,5] = magischer Wert
 move.w   #1,(a0)+                 ; mbuf[6]   = Fkt.Nr. (SMC_TERMINATE)
 move.w   d0,(a0)+                 ; mbuf[7]   = ap_id
 move.l   sp,a0
 moveq    #0,d2                    ; mbuf[3] ist 0
 moveq    #1,d1                    ; dst_apid = SCRENMGR
 moveq    #101,d0                  ; Nachrichtencode SM_M_SPECIAL (Mag!X 2.00)
 jsr      send_msg
 addq.l   #8,sp
 bra.b    prdel_ende

prdel_kill:
 move.l   d1,a0
 move.l   p_parent(a1),p_parent(a0)
 move.l   p_context(a1),p_context(a0)
 move.l   p_reg(a1),p_reg(a0)           ; normaler Kontext
 move.l   p_res3(a1),p_res3(a0)
 move.l   p_res3+4(a1),p_res3+4(a0)     ; Kontext fuer ACC- Terminierung
 moveq    #1,d0                         ; Speicher freigeben
 move.l   a1,a0                         ; Prozess loeschen
 bsr      PDkill
*/

prdel_ende:
 moveq    #0,d0
 rts
prdel_eaccdn:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long proc_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                d1 = long apcode );
*
* proc ist wie shared memory ist immer lese- und schreibbereit
*

;proc_stat EQU  shm_stat

