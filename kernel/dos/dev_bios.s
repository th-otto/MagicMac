**********************************************************************
*
* Dieses Modul enthaelt die Dateitreiber fuer BIOS- Geraete
*

DEBUG     EQU  16

     INCLUDE "errno.inc"
     INCLUDE "structs.inc"
     INCLUDE "kernel.inc"
     INCLUDE "vtsys.inc"
     INCLUDE "basepage.inc"
	 include "country.inc"
     INCLUDE "bios.inc"
     INCLUDE "magicdos.inc"
     SUPER


* vom BIOS

     XREF      p_vt52              ; neue Methode
     XREF      iorec_kb            ; Tastaturpuffer
     XREF      ctrl_status
     XREF      config_status
     XREF      prn_wrts

* from AES

	 XREF act_appl

* vom DOS

     XREF      get_act_appl
     XREF      Pterm
     XREF      str_to_con

* Exportieren

     XDEF      Bputch,get_termdata,dos_break

     XDEF      _anb_devdrv    ; 27.6.2002
     XDEF      _con_devdrv
     XDEF      _bios_devdrv
     XDEF      _midi_devdrv
     XDEF      _nul_devdrv

* Struktur "VDIESC" (relativ zu LINEA)

v_cel_mx  EQU -$2c
v_cel_my  EQU -$2a
v_cur_cx  EQU -$1c
v_cur_cy  EQU -$1a

	TEXT

_con_devdrv:
 DC.L     bios_ddev_open
 DC.L     bios_ddev_close
 DC.L     con_read
 DC.L     con_write
 DC.L     bios_ddev_stat
 DC.L     bios_ddev_lseek
 DC.L     0                        ; Standard- Fdatime
 DC.L     bios_ddev_ioctl
 DC.L     ret_0                    ; Loeschen erlaubt
 DC.L     con_getc
 DC.L     con_getline
 DC.L     con_putc
_nul_devdrv:
 DC.L     nul_ddev_open
 DC.L     bios_ddev_close
 DC.L     nul_ddev_read
 DC.L     nul_ddev_write
 DC.L     nul_ddev_stat
 DC.L     bios_ddev_lseek
 DC.L     0                   ; Standard- Fdatime
 DC.L     bios_ddev_ioctl
 DC.L     ret_0               ; Loeschen erlaubt
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc
_midi_devdrv:
 DC.L     bios_ddev_open
 DC.L     bios_ddev_close
 DC.L     bios_ddev_read
 DC.L     bios_ddev_write
 DC.L     midi_ddev_stat                ; wg. BIOS- Fehler!
 DC.L     bios_ddev_lseek
 DC.L     0                   ; Standard- Fdatime
 DC.L     bios_ddev_ioctl
 DC.L     ret_0               ; Loeschen erlaubt
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc
_bios_devdrv:
 DC.L     bios_ddev_open
 DC.L     bios_ddev_close
 DC.L     bios_ddev_read
 DC.L     bios_ddev_write
 DC.L     bios_ddev_stat
 DC.L     bios_ddev_lseek
 DC.L     0
 DC.L     bios_ddev_ioctl
 DC.L     ret_0                    ; Loeschen erlaubt
 DC.L     0                   ; kein getc
 DC.L     0                   ; kein getline
 DC.L     0                   ; kein putc



**********************************************************************
*
* long con_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Per Default ist CON ein "cooked" Geraet, d.h. Fread verwendet
* den "cooked" Modus
*
* TOS 1.4 limitiert das Einlesen auf 64K und gibt bei Ueberschreitung
* einen Fehler aus. Da dies keinen Sinn ergibt, wurde die Abfrage
* hier entfernt.
*

con_read:
 move.l   d0,d1
 moveq    #CMODE_ECHO+CMODE_COOKED,d0
 cmpi.l   #1,d1
 bne      con_getline              ; mehrere Zeichen: getline
 move.l   a1,-(sp)
 bsr      con_getc
 movea.l  (sp)+,a1                 ; buf
 move.b   d0,(a1)                  ; Zeichen eintragen
 moveq    #1,d0
 rts


**********************************************************************
*
* long con_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Per Default ist CON ein "cooked" Geraet, d.h. Fwrite verwendet
* den "cooked" Modus
*

con_write:
 movem.l  d0/d7/a4/a5,-(sp)
 move.l   a1,a5                    ; a5 = s
 move.l   d0,d7                    ; d7 = len

* neuer VT52: Wir uebergeben der Routine den Zeiger die Daten
* und den Zeiger auf die aktuelle Applikation. Gehoeren wir nicht
* dem VT52, erhalten wir Fehlercode -2

 move.l   p_vt52.w,d1
 beq.b    fasts_vtold
 move.l   d1,a2
 move.l   vt_sout_cooked(a2),a2
 move.l   act_appl.l,a0
;move.l   a5,a1
;move.l   d7,d0
 jsr      (a2)
 tst.l    d0
 bge.b    fasts_ende               ; OK
 cmpi.l   #-2,d0
 beq.b    fasts_novt               ; laeuft nicht im Fenster
 bra      break_vt                 ; ^C wurde betaetigt

fasts_vtold:
 bsr      vtwindow
 beq.b    fasts_novt
 move.l   d0,a0                    ; Zeiger auf Struktur WINDOW
 move.l   a5,a1
 move.l   d7,d0
 move.l   p_vt_sout.w,a2
fasts_vtboth:
 jsr      (a2)
 tst.l    d0
 bge      fasts_ende
 bra      break_vt                 ; ^C wurde betaetigt

fasts_novt:
 lea      (ctrl_status+1).w,a4
 bsr      _cook_conbuf             ; Steuerzeichen im Tastaturpuffer ?
 bra.b    fasts_standard
fasts_loopst:
 moveq    #0,d1
 move.b   (a5)+,d1
 move.w   d1,-(sp)
 move.l   #$30002,-(sp)                 ; Bconout(CON)
 trap     #$d
 addq.l   #6,sp
fasts_standard:
 move.b   (a4),d0
 bmi      dos_break
 beq.b    fasts_sok
 bsr      was_ctrl_s
fasts_sok:
 subq.l   #1,d7
 bcc.b    fasts_loopst
 sf.b     -(a4)
fasts_ende:
 movem.l  (sp)+,a4/a5/d7/d0
 rts


**********************************************************************
*
* long con_getc(a0 = FD *fd, d0 = int mode)
*
* cooked/raw Eingabe von CON mit/ohne Echo
*

con_getc:
 move.w   d0,-(sp)                 ; mode merken
 btst     #BCMODE_COOKED,d0        ; cooked ?
 beq.b    cgc_raw                  ; nein

*
* "cooked"
*

 move.l   p_vt52.w,d1
 beq.b    cico_vtold

*
* "cooked" im neuen VT52
*

 move.l   d1,a2                    ; VTSYS
 move.l   vt_cin_cooked(a2),a2
 move.l   act_appl.l,a0
 jsr      (a2)
 tst.l    d0
 bge      cgc_afterget             ; OK
 cmpi.l   #-2,d0
 beq.b    cico_novt                ; wir laufen nicht im Fenster
 bra      break_vt                 ; ^C wurde betaetigt

*
* "cooked" im alten VT52
*

cico_vtold:
 bsr      vtwindow                 ; laufen wir in einem VT52- Fenster ?
 beq.b    cico_novt                ; nein
 move.l   d0,a0                    ; Zeiger auf Struktur WINDOW
 move.l   p_vt_cin.w,a2
cico_vtboth:
 jsr      (a2)                     ; direkt den VT52 aufrufen
 tst.l    d0
 bge      cgc_afterget
 bra      break_vt                 ; ^C wurde betaetigt

*
* "cooked" ohne VT52
*

cico_novt:
 bsr      _cook_conbuf
cico_loop:
 tst.b    (ctrl_status+1).w
 beq      cico_ok
 bmi      dos_break
 bsr      was_ctrl_s
cico_ok:
 bsr      _cook_conbuf
 tst.b    (ctrl_status+1).w
 bne.b    cico_loop
 move.w   #BIOS_CON,-(sp)
 move.w   #Bconstat,-(sp)
 trap     #$d
 addq.w   #4,sp
 tst.w    d0
 beq.b    cico_loop                ; kein oder Steuerzeichen
 tst.b    (ctrl_status+1).w
 bne.b    cico_novt
 sf.b     ctrl_status.w            ; nicht weiter testen

*
* "raw"
*

cgc_raw:
 move.w   #BIOS_CON,-(sp)
 move.w   #Bconin,-(sp)
 trap     #13
 addq.l   #4,sp

*
* ggf. ECHO ausfuehren
*

cgc_afterget:
 move.w   (sp)+,d1
 btst     #BCMODE_ECHO,d1          ; Echo ?
 beq.b    cgc_noecho               ; nein
 move.l   d0,-(sp)                 ; d0 retten
 move.w   d0,-(sp)
 move.w   #BIOS_CON,-(sp)
 move.w   #Bconout,-(sp)
 trap     #13
 addq.l   #6,sp
 move.l   (sp)+,d0
cgc_noecho:
 rts


**********************************************************************
*
* long con_getline(a0 = FD *fd, d0 = int mode,
*                  a1 = char *buf, d1 = long len)
*
* Zeilenweise cooked/raw Eingabe mit/ohne Echo von CON
* Rueckgabe: immer Anzahl gelesener Bytes
*
* Achtung: <mode> wird hier ignoriert und ist immer ECHO+COOKED
*

con_getline:
 move.l   a1,a0
 move.w   d1,d0
 bra      input


**********************************************************************
*
* long con_putc(a0 = FD *fd, d0 = int mode, d1 = long c)
*
* cooked/raw Ausgabe auf CON
* Rueckgabe: immer 4L nach MiNT- Konvention
*

con_putc:
 move.w   d1,-(sp)                 ; (int) c
 btst     #BCMODE_COOKED,d0
 beq.b    cpc_raw
 bsr      cook_conbuf
 sf.b     ctrl_status.w
cpc_raw:
 move.w   #BIOS_CON,-(sp)
 move.w   #Bconout,-(sp)
 trap     #$d
 addq.l   #6,sp
 moveq    #4,d0
 rts


**********************************************************************
*
* void cook_conbuf( void )
*
* Durchsucht den Tastaturpuffer nach ^C,^S,^Q
* Setzt die Flags von ctrl_status entsprechend
*

cook_conbuf:
 bsr.b    _cook_conbuf
coc_wloop:
 tst.b    (ctrl_status+1).w
 beq      coc_rts


**********************************************************************
*
*  was_ctrl_s( void )
*
* Wartet auf das erloesende CTRL-Q und loescht anschliessend die
* Steuercodes aus dem Eingabepuffer.
* Kommt zwischendurch ein ^C, wird abgebrochen.
* head zeigt vor das aelteste Zeichen (naechstes auszulesendes)
* tail zeigt vor das naechstes einzulesendes Zeichen
*

was_ctrl_s:
 tst.b    (ctrl_status+1).w
 bmi      dos_break
 bne.b    was_ctrl_s

_cook_conbuf:
 lea      (iorec_kb+6).w,a0
 st.b     ctrl_status.w            ; ab jetzt kann BIOS absuchen
 cmpm.w   (a0)+,(a0)+              ; cmp.w (a0),2(a0);addq.l #4,a0
 beq      coc_rts                  ; kein Zeichen da
 move     sr,-(sp)
 move.w   d3,-(sp)
 ori.w    #$700,sr
 lea      iorec_kb.w,a0
 movea.l  (a0)+,a1                 ; Pufferzeiger
 move.w   (a0)+,d3                 ; Pufferlaenge
 move.w   (a0)+,d1                 ; head
 move.w   (a0),d2                  ; tail
coc_loop:
 addq.w   #4,d1                    ; Head-Index erhoehen
 cmp.w    d3,d1                    ; mit Puffergroesse vergleichen
 bcs.b    coc_nosw
 moveq    #0,d1                    ; Pufferzeiger auf Pufferbeginn
coc_nosw:
 move.l   0(a1,d1.w),d0            ; Zeichen (Long)
 cmpi.w   #$3,d0                   ; ^C
 bne.b    coc_weiter
 bset     #7,(ctrl_status+1).w
 bra.b    coc_kill
coc_weiter:
 cmpi.w   #$13,d0                  ; ^S
 bne.b    coc_weiter2
 bset     #0,(ctrl_status+1).w
 bra.b    coc_kill
coc_weiter2:
 cmpi.w   #$11,d0                  ; ^Q
 bne.b    coc_next
 bclr     #0,(ctrl_status+1).w
coc_kill:
; move.l  #$5f,0(a1,d1.w)
; bra          coc_next
 move.w   d1,-(sp)                 ; aktuelle Position merken
coc_loop2:
 lea      0(a1,d1.w),a2            ; zu loeschende Position
 subq.w   #4,d1
 bcc.b    coc_nosw2
 move.w   d3,d1
 subq.w   #4,d1                    ; Pufferindex 0..len-1 a 4 Bytes
coc_nosw2:
 cmp.w    (iorec_kb+6).w,d1        ; ist Head ?
 beq.b    coc_iskill               ; ja, fertig
 move.l   0(a1,d1.w),(a2)          ; aufruecken
 bra.b    coc_loop2
coc_iskill:
 addq.w   #4,d1                    ; Head erhoehen
 cmp.w    d3,d1
 bcs.b    coc_nosw3
 moveq    #0,d1
coc_nosw3:
 move.w   d1,(iorec_kb+6).w
 move.w   (sp)+,d1
coc_next:
 cmp.w    d1,d2
 bne.b    coc_loop
 move.w   (sp)+,d3
 move.w   (sp)+,sr
coc_rts:
 rts


**********************************************************************
*
* dos_break( void )
*

ctrlc_s: DC.B '^C',13,10,0
     EVEN

dos_break:
 clr.w    ctrl_status.w
 clr.l    (iorec_kb+6).w            ; Tastaturpuffer loeschen

break_vt:
* Zeichenfolge ^C,cr,lf auf die Konsole

 lea      ctrlc_s(pc),a0
 jsr      str_to_con

* Prozess beenden mit Rueckgabewert EBREAK

 moveq    #1,d1                    ; Speicher freigeben
 moveq    #EBREAK,d0
 jmp      Pterm


**********************************************************************
*
* EQ/NE VTWINDOW *vtwindow( void )
*
* Ist der VT52.PRG Server fuer unsere Applikation, wird ein Zeiger auf
* die WINDOW- Struktur geliefert, sonst NULL
*

vtwindow:
 tst.l    p_vt52_winlst.w
 beq.b    vtw_novt
 jsr      get_act_appl
 beq.b    vtw_novt
 move.l   d0,a0                    ; a1 = aktuelle Applikation
 move.w   ap_id(a0),a0
 add.w    a0,a0
 add.w    a0,a0                    ; a0 = apid * 4
 add.l    p_vt52_winlst.w,a0
 move.l   (a0),d0                  ; Zeiger auf Struktur WINDOW
vtw_novt:
 rts


**********************************************************************
*
* int get_termdata( void )
*
* Ermittelt aktuelle Terminaldaten
*
* RUeckgabe:    d0   FALSE, wenn kein VT52-Emulator
*              d1   Anzahl Cursorspalten
*              d2   Anzahl Cursorzeilen
*              a0   Zeiger auf aktuelle x-Cursorposition
*              a1   Zeiger auf Datenstruktur VT52 bzw. LineA
*

get_termdata:
 move.l   p_vt52.w,d0              ; neue Methode?
 beq.b    gtrd_old                 ; nein, alte
 move.l   act_appl.l,a0
 move.l   d0,a2
 move.l   vt_getVDIESC(a2),a2
 jsr      (a2)
 tst.l    d0
 bmi.b    gtd_no_vtemu             ; kein Fenster zustaendig
 move.l   d0,a1                    ; a1 = Zeiger auf Pseudo-LineA
 bra.b    gtd_la

gtrd_old:
 bsr      vtwindow
 beq.b    gtd_no_vtemu
 move.l   d0,a1                    ; Zeiger auf Struktur WINDOW
 add.w    p_vt_interior_off.w,a1
 move.l   (a1),a1                  ; Zeiger auf Struktur TSCREEN
 move.w   p_vt_columns_off.w,d0
 move.w   0(a1,d0.w),d1            ; Cursorspalten (x)
 move.w   p_vt_visible_off.w,d0
 move.w   0(a1,d0.w),d2            ; Cursorzeilen (y)
 move.l   a1,a0
 add.w    p_vt_x_off.w,a0
 st       d0
 rts
gtd_no_vtemu:
 DC.W     $a000
 move.l   a0,a1                    ; a1 = Zeiger auf LineA
gtd_la:
 move.w   v_cel_mx(a1),d1          ; Cursorspalten (x)
 move.w   v_cel_my(a1),d2          ; Cursorzeilen (y)
 lea      v_cur_cx(a1),a0          ; Cursorspalte
 sf       d0
 rts


* void crlf( void )
*

crlf:
 moveq    #$d,d0
 bsr.b    Bputch
 moveq    #$a,d0

* void Bputch()
*  Druckt das Zeichen in d0 nach Device 2 (CON)

Bputch:
 move.w   d0,-(sp)
 move.l   #$30002,-(sp)
 trap     #$d
 addq.l   #6,sp
 rts



**********************************************************************
*
* long ???_ddev_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Geraeten ignoriert
*

bios_ddev_open:
 move.w   fd_usr3+2(a0),fd_usr1(a0)     ; BIOS- Geraet
 moveq    #0,d0
 rts

**********************************************************************
*
* long bios_ddev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
*
* 10.3.2002: Spezialparameter fuer Spezial-Rsconf
*

bios_ddev_ioctl:
 moveq    #EINVFN,d0
 rts


**********************************************************************
*
* long bios_ddev_lseek(a0 = FD *f,  d0 = long where, d1 = int mode)
*

bios_ddev_lseek:
;bra      nul_ddev_open


**********************************************************************
*
* long bios_ddev_close(a0 = FD *f)
*

bios_ddev_close:
;bra      nul_ddev_open


**********************************************************************
*
* long nul_ddev_read(a0 = FD *f, a1 = void *buf, d0 = long len)
*

nul_ddev_read:
;bra      nul_ddev_open


**********************************************************************
*
* long nul_ddev_open(a0 = FD *f)
*
* O_TRUNC muss ausgewertet werden.
* Der Dateizeiger ist auf 0 zu stellen, falls nicht fd_fpos := 0
* ausreicht.
*
* O_TRUNC wird bei Geraeten ignoriert
*

nul_ddev_open:
ret_0:
 moveq    #0,d0
 rts


**********************************************************************
*
* long nul_ddev_write(a0 = FD *f, a1 = char *s, d0 = long cnt)
*

nul_ddev_write:
 rts


**********************************************************************
*
* long bios_ddev_read(a0 = FD *f, a1 = char *buf, d0 = long count)
*

bios_ddev_read:
 movem.l  d6/d7/a6,-(sp)
 move.l   d0,-(sp)
 move.l   a1,a6                         ; a6 = Puffer
 moveq    #2,d6
 swap     d6
 move.w   fd_usr1(a0),d6                ; Fcode Bconin/BIOS- Geraet
 move.l   d0,d7
 bra.b    bmr_nextloop
bmr_loop:
 move.l   d6,-(sp)                      ; Bconin(dev, c)
 trap     #$d
 addq.l   #4,sp
 move.b   d0,(a6)+
bmr_nextloop:
 subq.l   #1,d7
 bcc.b    bmr_loop
 move.l   (sp)+,d0
 movem.l  (sp)+,d6/d7/a6
 rts


**********************************************************************
*
* long bios_ddev_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*

bios_ddev_write:
 tst.w    fd_usr1(a0)                   ; Drucker?
 beq.b    bios_prn_write                ; ja, schnelle Spezialbehandlung

 movem.l  d6/d7/a6,-(sp)
 move.l   d0,-(sp)
 move.l   a1,a6                         ; a6 = Puffer
 moveq    #3,d6
 swap     d6
 move.w   fd_usr1(a0),d6                ; Fcode Bconout/BIOS- Geraet
 move.l   d0,d7
 bra.b    bmw_nextloop
bmw_loop:
 moveq    #0,d0
 move.b   (a6)+,d0
 move.w   d0,-(sp)
 move.l   d6,-(sp)                      ; Bconout(dev, c)
 trap     #$d
 addq.l   #6,sp
bmw_nextloop:
 subq.l   #1,d7
 bcc.b    bmw_loop
 move.l   (sp)+,d0
 movem.l  (sp)+,d6/d7/a6
 rts


**********************************************************************
*
* long bios_prn_write(a0 = FD *f, a1 = char *buf, d0 = long count)
*
* Druckerstatus beruecksichtigen!
*
* 2.12.95:     Die Funktion geht nicht mehr einzelbyteweise ueber den
*              Trap, sondern wird direkt ausgefuehrt
*

bios_prn_write:
 move.l   a1,a0
 jmp      prn_wrts                      ; -> BIOS
/*
 movem.l  d6/d7/a6,-(sp)
 move.l   d0,-(sp)
 move.l   a1,a6                         ; a6 = Puffer
 moveq    #3,d6
 swap     d6
 move.w   fd_usr1(a0),d6                ; Fcode Bconout/BIOS- Geraet
 move.l   d0,d7
 bra.b    bpw_nextloop
bpw_loop:
 moveq    #0,d0
 move.b   (a6)+,d0
 move.w   d0,-(sp)
 move.l   d6,-(sp)                      ; Bconout(dev, c)
 trap     #$d
 addq.l   #6,sp
 tst.w    d0                            ; bei PRN Status pruefen !
 bne.b    bpw_nextloop                  ; kein Fehler
* Fehler, Timeout
 addq.l   #1,d7
 sub.l    d7,(sp)
 bra.b    bpw_ende
bpw_nextloop:
 subq.l   #1,d7
 bcc.b    bpw_loop
bpw_ende:
 move.l   (sp)+,d0
 movem.l  (sp)+,d6/d7/a6
 rts
*/


**********************************************************************
*
* long nul_ddev_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                                d1 = long apcode );
*
* will schreiben:
*    liefere immer eine '1' fuer OK.
* will lesen:
*    d0 = 0 (polling):   liefere '0' (nicht bereit)
*    d0 = apcode     :   liefere unselect- Routine zurueck.
*

nul_ddev_stat:
 move.l   a1,-(sp)
 tst.w    d0
 beq.b    nstat_read
 moveq    #1,d0
 bra      _bmstat2                      ; bereit
nstat_read:
 move.l   d1,d0                         ; polling erwuenscht ?
 beq      _bmstat2                      ; ja, liefere 0
 lea      nstat_unsel(pc),a0
 move.l   a0,d0
 bra      _bmstat2


**********************************************************************
*
* void nstat_unsel( a0 = long *unselect, a1 = void *apcode );
*
*

nstat_unsel:
 clr.l    (a0)                ; nicht eingetroffen
 rts


**********************************************************************
*
* long bios_ddev_stat(a0 = FD *f, a1 = long *unselect, d0 = int rwflag,
*                                 d1 = long apcode );
*

bios_ddev_stat:
 move.l   a1,-(sp)
 move.w   fd_usr1(a0),-(sp)             ; dev
 move.w   #Bconstat,-(sp)
 tst.w    d0
 beq.b    _bmstat
 move.w   #Bcostat,(sp)
_bmstat:
 trap     #13
 addq.l   #4,sp
 moveq    #1,d1
 and.l    d1,d0                         ; auf 0 oder 1 normieren
_bmstat2:
 move.l   (sp)+,d1
 beq.b    bms_ok
 move.l   d1,a1
 move.l   d0,(a1)
bms_ok:
 rts


**********************************************************************
*
* long midi_ddev_stat(a0 = FD *f, a2 = long apcode, d0 = int rwflag,
*                                a1 = long *unselect );
*

midi_ddev_stat:
 tst.w    d0
 beq.b    bios_ddev_stat
 move.l   a1,-(sp)
 move.l   #$80004,-(sp)                 ; bei Bcostat: dev 4 statt 3
 bra.b    _bmstat




**********************************************************************
**********************************************************************
*********************** INPUT fuer CON ********************************
**********************************************************************
**********************************************************************


* int (long) input(a0 = char *string, d0 = int len)

*            Register a3,a6 ist global in diesem Modul
*            Hiword von d4 (home_ypos) ist global in diesem Modul

* lokal  akt_len d6
*        zeiger  d7
*        x       d4
*        string  a5
*        maxlen  d5
*        Ftaste  a4
*        undo    -4(a6)
*        columns -6(a6)
*        p_cx    -10(a6)
*        is_emu  -12(a6)
*        rows    -14(a6)

input:
 link     a6,#-14
 movem.l  a5/a4/a3/d7/d6/d5/d4,-(sp)
 clr.l    -4(a6)                   ; noch kein Undo
 move.l   a0,a5
 move.w   d0,d5
 move.w   #1,-(sp)
 move.w   #$15,-(sp)
 trap     #$e                      ; xbios Cursconf(CUR_ON)
 addq.w   #4,sp

 bsr      get_termdata
 move.b   d0,-12(a6)               ; true, wenn vt-in-Fenster
 move.w   d1,-6(a6)                ; mx
 move.w   d2,-14(a6)               ; my
 move.l   a0,-10(a6)               ; &cx
 move.l   a1,a3

 bsr      get_cy                   ; cur_cy
 move.w   d0,d4
 swap     d4                       ; home_ypos ins Hiword
 move.l   -10(a6),a0               ; &cur_cx
 move.w   (a0),d4                  ; home_xpos in d4.low
 addq.w   #1,-6(a6)                ; Zeilenbreite
 clr.w    d7
 clr.w    d6                       ; Laenge per Default 0
 suba.l   a4,a4                    ; noch keine Ftaste
inp_mainloop:
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr      gotox                    ; gotox(x+zeiger)
 addq.l   #2,sp
 move.l   a4,d0                    ; gerade beim Ausfuehren einer F-Taste ?
 beq.b    inp15
 move.b   (a4),d0
 beq.b    inp15                    ; Ende der Ftaste
 addq.l   #1,a4
 cmpi.b   #10,d0                   ; LF
 beq      inp100
 cmpi.b   #13,d0                   ; CR
 beq      inp100
 bra      inp20
inp15:
 moveq    #CMODE_COOKED,d0
 bsr      con_getc
 andi.l   #$00ffffff,d0            ; Kbshift ausmaskieren
 cmpi.l   #$1c000d,d0              ; K_RETURN
 beq      inp90
 cmpi.l   #$72000d,d0              ; K_ENTER
 beq      inp100                   ; RETURN und ENTER beenden die Eingabe
 cmpi.l   #$0e0008,d0              ; K_BS
 bne.b    inp2
 tst.w    d7
 beq.b    inp_mainloop             ; Zeiger ist auf Feldanfang
 subq.w   #1,d7
inp_del:
 bsr      str_del                  ; Zeichen vor Cursorposition loeschen
 bsr      str_at
 moveq    #' ',d0
 bsr      Bputch
 bra      inp_mainloop             ; weiter
inp2:
 cmpi.l   #$53007f,d0              ; K_DEL
 beq.b    inp_del                  ;  analog zu BACKSPACE
 cmpi.l   #$4b0034,d0              ; SHIFT-LTARROW
 beq.b    inp_pos0                 ;  an Eingabeanfang
 cmpi.l   #$4d0036,d0              ; SHIFT-RTARROW
 beq.b    inp_posend               ;  an Eingabeende
 cmpi.l   #$470000,d0              ; Home/Pos1
 beq.b    inp_pos0                 ;  (wie SHIFT-LTARROW)
 cmpi.l   #$370000,d0              ; Ende
 beq.b    inp_posend               ;  (wie SHIFT-RTARROW)
 cmpi.l   #$0f0009,d0              ; K_TAB
 bne.b    inp4
 cmp.w    d6,d7                    ; zeiger am Feldende ?
 bcs.b    inp_posend
inp_pos0:
 clr.w    d7                       ; zeiger nach Feldanfang
 bra      inp_mainloop
inp_posend:
 move.w   d6,d7                    ; zeiger nach Feldende
 bra      inp_mainloop
inp4:
 cmpi.l   #$4b0000,d0              ; K_LTARROW
 bne.b    inp6
 tst.w    d7
 beq      inp_mainloop
 subq.w   #1,d7
 bra      inp_mainloop
inp6:
 cmpi.l   #$4d0000,d0              ; K_RTARROW
 bne.b    inp7
 cmp.w    d6,d7
 bcc      inp_mainloop
 addq.w   #1,d7
 bra      inp_mainloop
inp7:
 cmpi.l   #$520000,d0              ; K_INSERT : Einfuegemodus ein
 bne.b    inp8
 bclr.b   #1,(config_status+3).w
 bra      inp_mainloop
inp8:
 cmpi.l   #$520030,d0              ; SH-K_INSERT: Einfuegemodus aus
 bne.b    inp_nxt1
 bset.b   #1,(config_status+3).w
 bra      inp_mainloop
inp_nxt1:
 cmpi.l   #$470037,d0              ; K_CLR
 bne.b    inp9
inp_clr:
 move.w   d6,-(sp)
 move.w   d4,-(sp)
 bsr      spacestr_at
 addq.l   #4,sp
 clr.w    d6
 clr.w    d7
 bra      inp_mainloop
inp9:
 cmpi.l   #$610000,d0              ; K_UNDO
 bne.b    inp30
 lea      (undo_buf).l,a4              ; Undo- Puffer wie F-Taste
 bra      inp_mainloop

inp30:
 cmpi.l   #$480000,d0              ; K_UPARROW
 bne.b    inp35
 move.l   -4(a6),d1
 bne.b    inp31
 lea      (undo_buf).l,a0
 bra.b    inp33
inp31:
 move.l   d1,a0                    ; letzte Eingabe
inp32:
 tst.b    (a0)+
 bne.b    inp32                    ; naechsten String suchen
 /* cmpa.l   #(undo_buf+319),a0 */ /* BINEXACT */
 dc.w $b1fc
 dc.l undo_buf+319
 bcc.b    inp10                    ; bin am Ende, nichts tun
inp33:
 tst.b    (a0)
 beq.b    inp10                    ; Nullstring nicht beruecksichtigen
 move.l   a0,-4(a6)
 move.l   a0,a4
 bra.b    inp_clr                  ; loeschen, dann Undo

inp35:
 cmpi.l   #$500000,d0              ; K_DNARROW
 bne.b    inp10
 move.l   -4(a6),d1
 beq.b    inp10                    ; noch kein Undo
 move.l   d1,a0                    ; letzter Undo
inp37:
 subq.l   #1,a0
 /* cmpa.l   #(undo_buf),a0 */ /* BINEXACT */
 dc.w $b1fc
 dc.l undo_buf
 bcs.b    inp38
 tst.b    -1(a0)
 bne.b    inp37
 bra.b    inp33
inp38:
 lea      (undo_buf).l,a0
 bra.b    inp33

inp10:
 cmpi.l   #$3b0000,d0              ; K_F1
 blt      inp20
 cmpi.l   #$440000,d0              ; K_F10
 bgt      inp20
 swap     d0
 subi.w   #$3a,d0
 bsr      f_taste
 tst.l    d0
 beq      inp_mainloop             ; Funktionstaste nicht belegt
 move.l   d0,a4
 addq.l   #3,a4                    ; bei "Fx=" sind 3 Zeichen zu ueberspringen
 bra      inp_mainloop
* Jetzt kommen die druckbaren Zeichen:
inp20:
 clr.w    d2
 move.b   d0,d2                    ; obere 8 Bit loeschen
 beq      inp_mainloop
 cmp.w    d5,d7                    ; Eingabefeld voll ?
 bge      inp_mainloop
 btst.b   #1,(config_status+3).w
 beq.b    inp21
 bsr      str_del
inp21:
 bsr      str_ins
 bsr      str_at
 addq.w   #1,d7
 bra      inp_mainloop

* Eingabestring in den UNDO- Puffer kopieren

inp90:
 move.w   d6,d0
 subq.w   #1,d0
 bcs.b    inp100                   ; 0 Zeichen
 lea      (undo_buf).l,a0
 cmpi.w   #318,d0
 bls.b    inp92
 move.w   #318,d0                  ; maximal 319 Zeichen
inp92:
* Rest des Undo- Puffers nach hinten
 move.w   d0,d1
 addq.w   #2,d1                    ; Platz fuer neuen String
 lea      (undo_buf+320).l,a1          ; Ziel
 move.l   a1,a2
 sub.w    d1,a2                    ; Quelle
 move.w   #319,d2
 sub.w    d1,d2                    ; Anzahl zu kopierender Zeichen - 1
 bcs.b    inp91                    ; nichts zu kopieren
inp93:
 move.b   -(a2),-(a1)
 dbra     d2,inp93
* Eingabe in den Undo- Puffer
inp91:
 move.b   (a5)+,(a0)+
 dbra     d0,inp91
 clr.b    (a0)                     ;  String- Ende markieren
inp100:
 move.w   #$d,d0
 bsr      Bputch
 moveq    #0,d0
 move.w   d6,d0                    ; Anzahl eingegebener Zeichen
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4
 unlk     a6
 rts


* int get_cy

get_cy:
 tst.b    -12(a6)
 beq.b    gcy_ori
* alter VT52.PRG
 move.w   d1,-(sp)
 move.w   p_vt_y_off.w,d1
 move.w   0(a3,d1.w),d0
 move.w   p_vt_visible_off.w,d1
 add.w    0(a3,d1.w),d0
 move.w   p_vt_rows_off.w,d1
 sub.w    0(a3,d1.w),d0
 move.w   (sp)+,d1
 rts
* BIOS
gcy_ori:
 move.w   v_cur_cy(a3),d0          ; Cursorzeile
 rts


* void gotox(x)
* int x;

gotox:
 moveq    #$1b,d0
 bsr      Bputch
 moveq    #'Y',d0
 bsr      Bputch
 move.l   d4,d0
 swap     d0                       ; Anfangs- y- Position
 add.w    #32,d0
 clr.l    d1
 move.w   4(sp),d1
 move.w   -6(a6),d2                ; d2 = Zeilenbreite
 divu     d2,d1
 add.w    d1,d0                    ; volle Zeilen zu y addieren
 swap     d1
 move.w   d1,-(sp)                 ; Rest- x merken
 bsr      Bputch                   ; y ausgeben
 moveq    #32,d0
 add.w    (sp)+,d0                 ; x holen
 bsr      Bputch                   ; x ausgeben
 rts


**********************************************************************
*
* void str_at()
*
*  Schreibt den String <char a5[]>, der eine Laenge von <int d6> hat,
*  ab Position <int d7> nach Bildschirm- Position <int d4>
*

str_at:
 movem.l  d3/a4,-(sp)
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr.b    gotox
 addq.l   #2,sp
 move.l   a5,a4
 adda.w   d7,a4                    ; a4 = ab hier ausgeben
 move.w   d6,d3
 sub.w    d7,d3                    ; d3 = Anzahl auszugebender Zeichen
 bra.b    sa2
sa1:
 bsr      get_cy
 move.w   d0,-(sp)
 clr.w    d0
 move.b   (a4)+,d0
 move.w   d0,-(sp)
 move.w   #5,-(sp)
 move.w   #3,-(sp)
 trap     #$d                      ; bios     Bconout
 addq.l   #6,sp
 move.w   (sp)+,d0                 ; ypos vor Ausgabe

* Falls sich der Cursor nach der Ausgabe links befindet und er vorher
* auf der letzten Zeile stand, muss der Bildschirm gescrollt haben.
* Folglich wandert unsere Home- Position nach oben

 move.l   -10(a6),a0
 tst.w    (a0)                     ; Cursorposition x
 bne.b    sa2
 cmp.w    -14(a6),d0               ; Zeilen des Bildschirms
 bcs.b    sa2
 swap     d4
 subq.w   #1,d4                    ; home_ypos
 swap     d4
sa2:
 dbra     d3,sa1
 movem.l  (sp)+,d3/a4
 rts


* void spacestr_at(x,len)
* int x,len;

spacestr_at:
 move.w   4(sp),-(sp)
 bsr      gotox
 addq.w   #2,sp
spa1:
 subq.w   #1,6(sp)
 bcs.b    spa100
 move.w   #' ',d0
 bsr      Bputch
 bra.b    spa1
spa100:
 rts


**************************************************************
*
* fuegt in einen String <char a5[]> der Maximallaenge <int d5>
* an Position <int d7> das Zeichen <char d2> ein.
* akt_len (d6) wird entsprechend erhoeht
*
**************************************************************

* void str_ins()

str_ins:
 move.l   a5,a1
 adda.w   d7,a1                    ; a0 = Einfuegeposition
 move.l   a5,a0
 add.w    d6,a0                    ; a0 = String- Ende
 cmp.w    d5,d6
 beq.b    ins90                    ; akt_len == max_len
 bra.b    ins1
ins2:
 move.b   (a0),1(a0)
ins1:
 subq.l   #1,a0
 cmpa.l   a1,a0
 bcc.b    ins2
 addq.w   #1,d6
ins90:
 move.b   d2,(a1)
 rts


**************************************************************
*
* nimmt aus einem <char a5[]> der Laenge <int d6> an Position
* <int d7> ein Zeichen heraus.
* Die Laenge wird entsprechend korrigiert
*
**************************************************************

* void str_del()

str_del:
 move.l   a5,a0
 adda.w   d7,a0                    ; a0 = string + pos
 move.w   d6,d0
 sub.w    d7,d0                    ; d1 = len - pos
 beq.b    sd100
 bra.b    sd3
sd2:
 move.b   1(a0),(a0)+
sd3:
 dbra     d0,sd2
 subq.w   #1,d6                    ; len = len - 1
sd100:
 rts

* int f_taste(d0 = int nr)
*  Prueft, ob die Variable "F<nr>" im environment existiert
*  Rueckgabe: Zeiger auf gefundenen String (im env.) oder NULL

f_taste:
 cmpi.b   #10,d0
 bne.b    f0
 clr.w    d0
f0:
 add.w    #'0',d0                  ; F10 ist F0
 move.l   act_pd.l,a0
 move.l   p_env(a0),a0             ; p_env
 bra.b    f3
f1:
 cmpi.b   #'F',(a0)
 bne.b    f2
 cmp.b    1(a0),d0
 bne.b    f2
 cmpi.b   #'=',2(a0)
 bne.b    f2
 move.l   a0,d0
 rts
f2:
 tst.b    (a0)+
 bne.b    f2
f3:
 tst.b    (a0)
 bne.b    f1
 clr.l    d0
 rts
