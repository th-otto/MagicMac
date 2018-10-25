**********************************************************************
*
* Dieses Modul enthaelt die Dateitreiber fuer uni- und
* bidirektionale Pipes
*

DEBUG     EQU  16

     INCLUDE "errno.inc"
     INCLUDE "structs.inc"

     XDEF upipe_drv,bipipe_drv
     XDEF upipe_create,bipipe_create


     XREF __fseek,_fwrite
     XREF Mfree,Mxalloc
     XREF act_pd
     XREF appl_IOcomplete
     XREF evnt_IO
     XREF vmemcpy
     XREF ncopy_from

act_appl equ $3982 ; from AES FIXME

     OFFSET

pipe_len:      DS.W      1    /* soviele Bytes sind drin                   */
pipe_waiting:  DS.L      1    /* wartende Applikation                      */
pipe_waitunsl: DS.L      1    /*  zugeh. Zeiger auf unselect- Struktur     */
pipe_data:     DS.B      2048
pipe_sizeof:

     OFFSET

upipe_owner:   DS.L      1    /* 0x00: PD *, Eigner der Pipe               */
upipe_refcnt:  DS.W      1    /* 0x02: Referenzzaehler                      */
upipe_flag:    DS.W      1    ; Flag (unbenutzt)
upipe_pipe:    DS.B      pipe_sizeof
upipe_sizeof:

     OFFSET

bipipe_owner:  DS.L      1    /* 0x00: PD *, Eigner der Pipe               */
bipipe_refcnt: DS.W      1    /* 0x02: Referenzzaehler                      */
bipipe_flag:   DS.W      1    ; Flag (O_HEAD, wenn noch nicht geoeffnet)
bipipe_crpipe: DS.B      pipe_sizeof                  /* creator -> client */
bipipe_clpipe: DS.B      pipe_sizeof                  /* client -> creator */
bipipe_sizeof:

     TEXT


upipe_drv:
 DC.L     upipe_open
 DC.L     upipe_close
 DC.L     upipe_read
 DC.L     upipe_write
 DC.L     upipe_stat
 DC.L     upipe_seek
 DC.L     0                   ; normales Fdatime()
 DC.L     upipe_ioctl
 DC.L     upipe_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc

bipipe_drv:
 DC.L     bipipe_open
 DC.L     bipipe_close
 DC.L     bipipe_read
 DC.L     bipipe_write
 DC.L     bipipe_stat
 DC.L     bipipe_seek
 DC.L     0                   ; normales Fdatime()
 DC.L     bipipe_ioctl
 DC.L     bipipe_delete
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc


upipe_create:
 move.l   a5,-(sp)
 move.l   a0,a5
 move.l   #upipe_sizeof,d0
 move.l   act_pd,a1
 move.w   #$4002,d1                ; dontfree || STRAM_PREFERRED
 jsr      Mxalloc
 moveq    #ENSMEM,d1
 exg      d0,d1
 tst.l    d1
 beq      ucr_ende                 ; return(ENSMEM)
 move.l   d1,a0
 move.l   a0,dir_xdata(a5)
 move.l   act_pd,(a0)+             ; upipe_owner
 clr.l    (a0)+                    ; refcnt/flag
 clr.w    (a0)+                    ; pipe_len
 clr.l    (a0)+                    ; pipe_waiting
 move.l   #$00080000,dir_flen(a5)  ; Dateilaenge immer 2k (intel)
 moveq    #0,d0
ucr_ende:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long upipe_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Pipes ignoriert
*

upipe_open:
 move.l   #2048,fd_len(a0)
 move.l   fd_multi1(a0),a0              ; sonst nur Refcnt erhoehen
 move.l   fd_xdata(a0),a1               ; -> Daten
 addq.w   #1,upipe_refcnt(a1)           ; Referenzzaehler erhoehen
 moveq    #0,d0
 rts


**********************************************************************
*
* long upipe_close(a0 = FD *f)
*

upipe_close:
 movem.l  a4/a5/a6,-(sp)
 move.l   fd_multi1(a0),a5
 move.l   fd_xdata(a5),a4          ; UPIPE *

 lea      upipe_pipe(a4),a6        ; PIPE *
 bsr      pipe_wakeup              ; falls jemand noch wartet!
_upipe_close:
 subq.w   #1,upipe_refcnt(a4)      ; == bipipe_refcnt
 bgt.b    upc_ok                   ; Referenzzaehler noch nicht 0
 move.l   a4,a0
 jsr      Mfree                    ; Pipe freigeben
 move.l   fd_parent(a5),a0         ; zugehoeriges Verzeichnis
 move.l   fd_xdata(a0),a0          ; Verzeichnisdaten
 add.l    fd_dirpos(a5),a0         ; meine Verzeichnisposition
 move.b   #$e5,(a0)                ; Datei als geloescht markieren
/*
* Datei als geloescht markieren
 move.l   fd_dirpos(a5),d0
 move.l   fd_parent(a5),a0
 jsr      __fseek
 move.w   #$e500,-(sp)             ; geloeschte Datei
 move.l   sp,a1
 moveq    #1,d0                    ; 1 Byte
 move.l   fd_parent(a5),a0         ; FD
 jsr      _fwrite
 addq.l   #2,sp
 bmi.b    upc_ende                 ; Schreibfehler
*/
upc_ok:
 moveq    #0,d0
upc_ende:
 movem.l  (sp)+,a4/a5/a6
 rts


**********************************************************************
*
* long upipe_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*

upipe_read:
 move.l   d0,-(sp)
 movem.l  d7/a4/a5/a6,-(sp)
 move.l   a1,a5                    ; a5 = buf *
 move.l   d0,d7                    ; d7 = count
 beq      prw_ende                 ; count ist 0L
 move.l   fd_xdata(a0),a6          ; Zeiger auf UPipe
 lea      upipe_refcnt(a6),a4
 lea      upipe_pipe(a6),a6
pr_loop:
 moveq    #0,d2
 move.w   pipe_len(a6),d2          ; soviele Bytes sind schon drin
 bne.b    pr_ok1                   ; Pipe nicht leer
 cmpi.w   #1,(a4)                  ; Pipe ueberhaupt nochmal geoeffnet ?
 bls      prw_ende                 ; nein, Ende
; warte darauf, dass wieder Daten kommen
 move.l   a6,-(sp)                 ; PIPE *
 pea      pipe_unsel(pc)           ; unsel()
 move.l   act_appl.l,pipe_waiting(a6)     ; ich bin es, der wartet
 move.l   sp,pipe_waitunsl(a6)          ; fuer unselect
 move.l   sp,a0
 moveq    #0,d0                    ; ewig warten
 jsr      evnt_IO
 addq.l   #8,sp
 bra.b    pr_loop                  ; warten!
pr_ok1:
 move.l   d7,d0
 cmp.l    d2,d0
 bls.b    pr_ok
 move.l   d2,d0
pr_ok:
 lea      pipe_data(a6),a0         ; Leseposition
 move.l   a5,a1                    ; Schreibposition = Puffer
 move.l   d0,-(sp)
 jsr      ncopy_from               ; (a0)->(a1)
 move.l   (sp),d0
; Daten aufruecken
 sub.w    d0,pipe_len(a6)
 beq.b    pr_ok2                   ; Pipe leer, keine Daten aufruecken
 lea      pipe_data(a6),a0         ; Ziel
 lea      pipe_data(a6,d0.w),a1    ; naechste Daten
 move.w   pipe_len(a6),d0          ; Restdaten verschieben
 jsr      vmemcpy
pr_ok2:
 move.l   (sp)+,d0
 add.l    d0,a5                    ; Pufferposition weiter
 sub.l    d0,d7                    ; count runterzaehlen

* evtl. wartende Applikationen aufwecken
;move.l   a6,a6
 bsr      pipe_wakeup

 tst.l    d7
 bne.b    pr_loop
 bra      prw_ende


**********************************************************************
*
* long upipe_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

upipe_write:
 move.l   d0,-(sp)
 movem.l  d7/a4/a5/a6,-(sp)
 move.l   a1,a5                    ; a5 = buf *
 move.l   d0,d7                    ; d7 = count
 beq      prw_ende                 ; count ist 0L
 move.l   fd_xdata(a0),a6          ; Zeiger auf UPipe
 lea      upipe_refcnt(a6),a4
 lea      upipe_pipe(a6),a6
pw_loop:
 move.w   #2048,d2
 move.w   pipe_len(a6),d1          ; soviele Bytes sind drin
 sub.w    d1,d2                    ; soviele Bytes sind noch frei
 ext.l    d2
 bgt.b    pw_ok1                   ; Pipe noch nicht ueberfuellt
 cmpi.w   #1,(a4)                  ; Pipe ueberhaupt nochmal geoeffnet ?
 bls      prw_ende                 ; nein, Ende
; warte darauf, dass wieder Daten frei werden
 move.l   a6,-(sp)                 ; PIPE *
 pea      pipe_unsel(pc)           ; unsel()
 move.l   act_appl.l,pipe_waiting(a6)     ; ich bin es, der wartet
 move.l   sp,pipe_waitunsl(a6)          ; fuer unselect
 move.l   sp,a0
 moveq    #0,d0                    ; ewig warten
 jsr      evnt_IO
 addq.l   #8,sp
 bra.b    pw_loop                  ; warten!
pw_ok1:
 move.l   d7,d0
 cmp.l    d2,d0
 bls.b    pw_ok
 move.l   d2,d0
pw_ok:
 lea      pipe_data(a6,d1.w),a1    ; Schreibposition
 move.l   a5,a0                    ; Position = Puffer
 move.l   d0,-(sp)
 jsr      ncopy_from               ; (a0)->(a1)
 move.l   (sp)+,d0
 add.w    d0,pipe_len(a6)
 add.l    d0,a5                    ; Pufferposition weiter
 sub.l    d0,d7                    ; count runterzaehlen

* evtl. wartende Applikationen aufwecken
;move.l   a6,a6
 bsr      pipe_wakeup

 tst.l    d7
 bne.b    pw_loop
prw_ende:
 move.l   d7,d1
 movem.l  (sp)+,d7/a4/a5/a6
 move.l   (sp)+,d0                 ; soviele sollten geschrieben werden
 sub.l    d1,d0                    ; minus (nicht geschriebene)
 rts


**********************************************************************
*
* long upipe_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*
* Liefert E_OK auf Pseudo-TTYs, sonst 0.
*

bipipe_seek:
upipe_seek:
 moveq    #EACCDN,d0
 move.l   fd_multi1(a0),a0
 btst     #2,fd_attr(a0)
 beq.b    ups_end
 moveq    #0,d0
ups_end:
 rts


**********************************************************************
*
* long upipe_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*

upipe_ioctl:
 move.l   fd_xdata(a0),a0               ; Zeiger auf Pipe
 addq.l   #upipe_pipe,a0                ; (a0) = vorhandene Daten
 cmpi.w   #FIONREAD,d0
 beq.b    pipe_fionread
 cmpi.w   #FIONWRITE,d0
 beq.b    pipe_fionwrite
 moveq    #EINVFN,d0
 rts


*
* long pipe_fionread(a0 = FD *f, a1 = long *val)
*

pipe_fionread:
 moveq    #0,d0
 move.w   pipe_len(a0),d0    ; vorhandene Daten
 move.l   d0,(a1)
 moveq    #0,d0
 rts


*
* long pipe_fionwrite(a0 = FD *f, a1 = long *val)
*

pipe_fionwrite:
 moveq    #0,d0
 move.w   #2048,d0
 sub.w    pipe_len(a0),d0    ; vorhandene Daten
 move.l   d0,(a1)
 moveq    #0,d0
 rts


**********************************************************************
*
* long upipe_delete( a1 = DIR *dir )
*

upipe_delete:
 moveq    #0,d0
 rts


**********************************************************************
*
* long upipe_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                 d1 = long apcode );
*

upipe_stat:
 move.l   fd_xdata(a0),a0               ; Zeiger auf Pipe
 addq.l   #upipe_pipe,a0                ; (a0) = vorhandene Daten
pipe_stat:
 move.l   d1,a2
 tst.w    d0
 beq.b    upipe_rstat
; will schreiben
 cmpi.w   #2048,(a0)+                   ; Puffer voll ?
 bcs      us_ok                         ; nein, OK
 bra      upipe_wait                    ; warte
; will lesen
upipe_rstat:
 move.l   a0,d1                         ; Zeiger auf Pipe merken
 tst.w    (a0)+                         ; Daten da ?
 bne      us_ok                         ; ja, gib 1 zurueck
upipe_wait:
 move.l   a2,d0                         ; will Polling ?
 beq      us_ende2                      ; ja, gib 0 zurueck
; warte auf Lesen
 tst.l    (a0)                          ; wartet schon jemand ?
 bne      us_ende2                      ; ? kann eigentlich nicht sein ?
 move.l   a2,(a0)+                      ; pipe_waiting = APPL *
 move.l   a1,(a0)                       ; pipe_waitunsl = unselect
 lea      pipe_unsel(pc),a0
 move.l   a0,d0
 move.l   d0,(a1)+                      ; Adresse unselect- Routine
 move.l   d1,(a1)                       ; Parameter: Zeiger auf Pipe
 rts
us_ok:
 moveq    #1,d0
us_ende2:
 move.l   a1,d1
 beq.b    us_ende
 move.l   d0,(a1)
us_ende:
 rts


**********************************************************************
*
* void pipe_unsel( a0 = long *unselect, a1 = void *apcode );
*
*

pipe_unsel:
 clr.l    (a0)+               ; nicht eingetroffen
 move.l   (a0),a0             ; PIPE *
 clr.l    pipe_waiting(a0)    ; ich warte nicht mehr
 rts



**********************************************************************
*
* a0 = PIPE *bipipe_pipe(a0 = FD *fd, d0 = int rwflag );
*
* veraendert nur a0
*
* Gibt die zugehoerige PIPE zurueck.
*  der client liest vom creator
*  der creator liest vom client
*  der creator schreibt auf creator
*  der client schreibt auf client
*

bipipe_pipe:
 move.l   a1,-(sp)
 btst     #BO_HEAD-8,fd_mode(a0)        ; "creator"?
 move.l   fd_xdata(a0),a0
 lea      bipipe_clpipe(a0),a1
 lea      bipipe_crpipe(a0),a0
 bne.b    bip_n2                        ; ja
 exg      a1,a0
bip_n2:
 tst.w    d0
 bne.b    bip_n1
 exg      a1,a0
bip_n1:
 move.l   (sp)+,a1
 rts


**********************************************************************
*
* long bipipe_create(a0 = DIR *d)
*
* MagiC 6.20:
* Hier wird das Flag in <bipipe> auf O_HEAD gesetzt, was bedeutet,
* dass die Pipe erstellt, aber noch nicht geoeffnet wurde. Der erste,
* der die Pipe oeffnet (von Fcreate()) erhaelt das "creator"-Ende der
* Pipe. Alle weiteren Fopen()-Aufrufe erhalten das "client"-Ende.
* Damit unterscheidet sich das Vorgehen von dem bis MagiC 6.10, wo
* der erstellende Prozess _immer_ die "creator"-Seite erhielt.
*

bipipe_create:
 move.l   a5,-(sp)
 move.l   a0,a5
 move.l   #bipipe_sizeof,d0
 move.l   act_pd,a1
 move.w   #$4002,d1                ; dontfree || STRAM_PREFERRED
 jsr      Mxalloc
 moveq    #ENSMEM,d1
 exg      d0,d1
 tst.l    d1
 beq      bicr_ende                ; return(ENSMEM)
 move.l   d1,a0
 move.l   a0,dir_xdata(a5)
 move.l   act_pd,(a0)+             ; bipipe_owner
 clr.w    (a0)+                    ; bipipe_refcnt
 move.w   #O_HEAD,(a0)+            ; bipipe_flag

 clr.w    (a0)+                    ; pipe_len
 clr.l    (a0)                     ; pipe_waiting
 lea      pipe_sizeof-2(a0),a0
 clr.w    (a0)+                    ; Laenge fuer Client
 clr.l    (a0)                     ; wartend fuer Client
 move.l   #$00100000,dir_flen(a5)  ; Dateilaenge immer 4k (intel)
 moveq    #0,d0
bicr_ende:
 move.l   (sp)+,a5
 rts


**********************************************************************
*
* long bipipe_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* Bidirektionale Pipes werden zweimal jeweils zum Lesen und
* Schreiben geoeffnet. O_TRUNC zeigt hier an, dass die Pipe ueber
* Fcreate() geoeffnet wird. Wenn nun ein zweites Fcreate kommt, wird
* dies wegen OM_NOCHECK nicht vom DOS-XFS abgewiesen. Daher muss hier
* der Treiber mit EACCDN reagieren.
*
* MagiC 6.20:
* bipipe_flag = O_HEAD zeigt an, dass die "creator"-Seite der Pipe
* geoeffnet wird. Das Flag wird in den FD kopiert und anschliessend
* geloescht, damit nachfolgende Fopen()-Aufrufe die "client"-Seite
* oeffnen.
*

bipipe_open:
 move.l   fd_multi1(a0),a1              ; Prototyp holen
 move.l   fd_xdata(a1),a1               ; -> Daten
 tst.w    bipipe_flag(a1)               ; schon geoeffnet?
 beq.b    bipop_client                  ; ja, jetzt "client"
 clr.w    bipipe_flag(a1)               ; naechster wird "client"
 ori.w    #O_HEAD,fd_mode(a0)           ; markieren, dass "creator"
 bra.b    bipop_both
bipop_client:
 btst     #(BO_TRUNC-8),fd_mode(a0)     ; von Fcreate() ?
 bne.b    bipop_eaccdn                  ; ja, zweites Fcreate() => err
bipop_both:
 move.l   #4096,fd_len(a0)
 ori.w    #OM_NOCHECK,fd_mode(a0)       ; Datei mehrmals oeffnen erlaubt
 addq.w   #1,upipe_refcnt(a1)           ; Referenzzaehler erhoehen
 moveq    #E_OK,d0
 rts
bipop_eaccdn:
 moveq    #EACCDN,d0
 rts


**********************************************************************
*
* long bipipe_close(a0 = FD *f)
*

bipipe_close:
 movem.l  a4/a5/a6,-(sp)
 move.l   fd_multi1(a0),a5
 move.l   fd_xdata(a5),a4          ; UPIPE *

 lea      bipipe_crpipe(a4),a6     ; PIPE *       (creator)
 bsr      pipe_wakeup              ; falls jemand noch wartet!
 lea      bipipe_clpipe(a4),a6     ; PIPE *       (client)
 bsr      pipe_wakeup              ; falls jemand noch wartet!
 bra      _upipe_close


**********************************************************************
*
* long bipipe_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*

bipipe_read:
 move.l   d0,-(sp)
 movem.l  d7/a4/a5/a6,-(sp)
 move.l   a1,a5                    ; a5 = buf *
 move.l   d0,d7                    ; d7 = count
 beq      prw_ende                 ; count ist 0L
 move.l   fd_xdata(a0),a1          ; Zeiger auf UPipe
 lea      bipipe_refcnt(a1),a4
;move.l   a0,a0                    ; FD
 moveq    #0,d0                    ; lesen
 bsr      bipipe_pipe
 move.l   a0,a6
 bra      pr_loop                  ; a6 = PIPE, a4 = &refcnt


**********************************************************************
*
* long bipipe_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

bipipe_write:
 move.l   d0,-(sp)
 movem.l  d7/a4/a5/a6,-(sp)
 move.l   a1,a5                    ; a5 = buf *
 move.l   d0,d7                    ; d7 = count
 beq      prw_ende                 ; count ist 0L
 move.l   fd_xdata(a0),a1          ; Zeiger auf UPipe
 lea      bipipe_refcnt(a1),a4
;move.l   a0,a0                    ; FD
 moveq    #1,d0                    ; schreiben
 bsr      bipipe_pipe
 move.l   a0,a6
 bra      pw_loop


**********************************************************************
*
* long bipipe_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

;bipipe_seek   EQU  upipe_seek


**********************************************************************
*
* long bipipe_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*

bipipe_ioctl:
 sub.w    #FIONREAD,d0
 beq.b    bipipe_fio
 cmpi.w   #FIONWRITE-FIONREAD,d0
 beq.b    bipipe_fio
 moveq    #EINVFN,d0
 rts
bipipe_fio:
;move.l   a0,a0                         ; Zeiger auf FD
;move.w   d0,d0                         ; rwflag
 bsr      bipipe_pipe                   ; Pipe ermitteln
 tst.w    d0
 beq      pipe_fionread
 bra      pipe_fionwrite


**********************************************************************
*
* long bipipe_delete( a1 = DIR *dir )
*

bipipe_delete:
 moveq    #0,d0
 rts


**********************************************************************
*
* long bipipe_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                  d1 = long apcode );
*

bipipe_stat:
;move.l   a0,a0                         ; Zeiger auf FD
;move.w   d0,d0                         ; rwflag
 bsr      bipipe_pipe                   ; Pipe ermitteln
 bra      pipe_stat



**********************************************************************
*
* void pipe_wakeup(a6 = PIPE *p);
*

pipe_wakeup:
 move.l   pipe_waiting(a6),d0
 beq.b    pr_ok3                   ; keine wartende Applikation

 clr.l    pipe_waiting(a6)

 move.l   d0,a0                    ; APPL *
 move.l   pipe_waitunsl(a6),a1
 moveq    #1,d0                    ; eingetroffen
 move.l   d0,(a1)                  ; Zeiger auf unselect() durch OK ersetzen
                                   ; in 4(a1) muss nochmal a6 liegen
 jmp      appl_IOcomplete          ; wartende Applikation aufwecken
pr_ok3:
 rts
