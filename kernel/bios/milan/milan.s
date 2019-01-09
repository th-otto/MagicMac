;Export

DEBUG     EQU  0

     EXPORT    imilan
     EXPORT    icpu
     EXPORT    ihdv
     EXPORT    icookies
     EXPORT    ivideo
     EXPORT    get_odevv
     EXPORT    ibkgdma
     EXPORT    isndhooks
     EXPORT    iexcvecs
     EXPORT    iperiph
     EXPORT    dmaboot
     EXPORT    apkgboot
     EXPORT    coldboot
     EXPORT    prn_wrts
     EXPORT    imaptab
     EXPORT    ivideo2
     EXPORT    ivdi1
     EXPORT    iintmask
     EXPORT    ivdi2
     EXPORT    gethtime
     EXPORT    icpu2
     EXPORT    get_cpu_typ
     EXPORT    get_fpu_typ
     EXPORT    ihz200
     EXPORT    iikbd
     EXPORT    bombs
     EXPORT    vdi_entry


     IF   DEBUG
     XREF hexl,putstr,crlf
     ENDIF

; Include

     INCLUDE   "debug.inc"
     INCLUDE   "milan.inc"

milan               EQU  $9a4      ; Zeiger auf Uebergabestruktur

bell_hook equ $05ac
kcl_hook       EQU $5b0

     TEXT
     SUPER

*********************************************************************
*
* Diese Routine wird als zuerst ausgefuehrt.
* Zeiger auf Uebergabestruktur fuers Milan-ROM initialisieren.
*

imilan:
 lea      MILAN_ROM+osh_milan_magic,a0
 cmpi.l   #'Miln',(a0)+
 bne.b    imln_err
 move.l   (a0),milan.w        ; Zeiger auf Uebergabestruktur merken
 rts
imln_err:
 jmp      (a0)                ; Warmstart


*********************************************************************
*
* Diese Routine wird als zweite ausgefuehrt.
* sr,vbr,tc,tt0,tt1 initialisieren, CPU-Cache aus.
*

icpu:
 ori.w    #$700,sr                 ; Interrupts sperren
 move.l   milan,a2
 move.l   milh_init_cpu1(a2),a2
 jmp      (a2)                     ; Roh-Initialisierung


*********************************************************************
*
* Initialisiert auf dem Atari den Prozessorcache und die PMMU.

icpu2:
 move.l   milan,a2
 move.l   milh_init_cpu2(a2),a2
 jmp      (a2)                     ; Fein-Initialisierung


*********************************************************************
*
* Interrupts zulassen. Schreibt auf dem Atari $2300 nach sr, auf
* dem Hades $2100.
*

iintmask:
 move.w   #$2300,sr                ; Interrupts zulassen
 rts


**********************************************************************
*
* int get_cpu_typ( void )
*
* Bestimmung des Prozessors:
* Rueckgabe 0,10,20,30,40,60
*

get_cpu_typ:
 move.l   milan,a2
 move.l   milh_get_cpu(a2),a2
 jmp      (a2)


**********************************************************************
*
* int get_fpu_typ( void )
*
* Bestimmung des Prozessors:
* Rueckgabe 0,10,20,30,40,60
*

get_fpu_typ:
 move.l   milan,a2
 move.l   milh_get_fpu(a2),a2
 jmp      (a2)


**********************************************************************
*
* void icookies( a0 = COOKIE *co, d0 = LONG ncookies )
*
* <ncookies> ist der Brutto-Platz in der Tabelle, d.h. sie hat
* Platz fuer <ncookies-1> Cookies plus Ende-Kennung.
*
* Installiert alle maschinenspezifischen Cookies:
*    _CPU
*    _FPU
*    _VDO
*    _MCH
*    _SND
*    _FDC
*
* Weitere Cookies werden woanders installiert:
*    _IDT
*    MagX
*    MgMc bzw. MgPC
*

icookies:
 move.l   milan,a2
 move.l   milh_inst_cookies(a2),a2
 jmp      (a2)


**********************************************************************
*
* Video-System initialisieren (ohne VDI, nur Hardware)
* Ist beim Milan (noch) dummy.
*

ivideo:
 rts


**********************************************************************
*
* Video-System initialisieren (Phase 2)
* Beim Atari wird hier die Aufloesung gesetzt.
* Ist beim Milan (noch) dummy.
*

ivideo2:
 rts


**********************************************************************
*
* VDI initialisieren (Phase 1), DOS noch nicht initialisiert.
* Beim Atari wird hier der VT52 initialisiert.
* Ist beim Milan (noch) dummy.
*

ivdi1:
 rts


**********************************************************************
*
* Video-System initialisieren (Phase 2), DOS initialisiert,
* System gebootet.
* Beim Atari werden hier die Treiber geladen.
* Ist beim Milan (noch) dummy.
*

ivdi2:
 rts


**********************************************************************
*
* void ihdv( void )
*
* Initialisiert hdv_xxx
*

ihdv:
 move.l   milan,a2
 move.l   milh_ihdvvecs(a2),a2
 jmp      (a2)


**********************************************************************
*
* void *get_odevv( void )
*
* Liefert Zeiger auf Geraetevektoren.
* Die Routinen duerfen d0-d2/a0-a2 aendern und erhalten
* ihre Parameter in (a0), 2(a0) usw.
*
* Der erste Assembler-Befehl jeder Routine muss lauten:
*  lea 6(sp),a0
*

get_odevv:
 move.l   milan,a0
 move.l   milh_devvecs(a0),a0
 rts


*********************************************************************
*
* Semaphoren und Variablen fuer Hintergrund-DMA initialisieren.
*
* Ist beim Milan (noch) dummy.
*

ibkgdma:
 rts


*********************************************************************
*
* Sound-Hooks fuer Klick und Pling initialisieren.
*

isndhooks:
 move.l   milan,a0
 move.l   milh_hdl_pling(a0),bell_hook  ; Ton fuer ^G
 move.l   milh_hdl_klick(a0),kcl_hook   ; Tastenklickroutine
 rts


*********************************************************************
*
* Interrupt-Vektoren (0..63) initialisieren, welche nicht zu
* Bomben fuehren sollen.
* Beim Atari sind dies HBL und Line-A, 
*

iexcvecs:
 move.l   milan,a2
 move.l   milh_iexcvecs(a2),a2
 jmp      (a2)


**********************************************************************
*
* void iperiph( void )
*
* Initialisiert die Hardware. Auf dem Atari waeren das die
* MFPs und ihre Vektoren.
*
* darf d0-d2/a0-a2 aendern
*

iperiph:
 move.l   milan,a2
 move.l   milh_iperiph(a2),a2
 jmp      (a2)


**********************************************************************
*
* void ihz200( a0 = void *routine )
*
* Meldet den Interrupt an.
*

ihz200:
 move.l   milan,a2
 move.l   milh_iinit_hz200(a2),a2
;move.l   a0,a0
 jmp      (a2)


**********************************************************************
*
* void iikbd( a0 = void *routine )
*
* Meldet den Interrupt an.
*

iikbd:
 move.l   milan,a2
 move.l   milh_iinit_ikbd(a2),a2
;move.l   a0,a0
 jmp      (a2)


**********************************************************************
*
* void dmaboot( void )
*
* Bootet von HD
*

dmaboot:
 move.l   milan,a2
 move.l   milh_dmaboot(a2),a2
 jmp      (a2)


**********************************************************************
*
* void apkgboot( void )
*
* Fuerht die "PKGs im Flash" aus
*

apkgboot:
 move.l   milan,a2
 move.l   milh_autopacks(a2),a2
 jmp      (a2)


**********************************************************************
*
* Fuehrt einen Kaltstart aus
*

coldboot:
 move.l   milan,a2
 move.l   milh_coldboot(a2),a2
 jmp      (a2)


**********************************************************************
*
* void imaptab( BCONMAP *bco )
*
* Initialisiert die BCONMAP-Struktur
*
* darf d0-d2/a0-a2 aendern
*

imaptab:
 move.l   milan,a2
 move.l   milh_init_maptab(a2),a2
 jmp      (a2)


**********************************************************************
*
* LONG gethtime( void )
*
* Liefert Datum und Uhrzeit im GEMDOS-Format.

gethtime:
 move.l   milan,a2
 move.l   milh_gethtime(a2),a2
 jmp      (a2)


**********************************************************************
*
* long prn_wrts( a0 = char *buf, d0 = long count )
*
* Gibt mehrere Zeichen auf die parallele Schnittstelle aus.
* Gibt die Anzahl der ausgegebenen Zeichen zurueck.
*
* darf d0-d2/a0-a2 aendern
*

prn_wrts:
 move.l   milan,a2
 move.l   milh_prn_wrts(a2),a2
 jmp      (a2)


*********************************************************************
*
* Bomben ausgeben. a3 = Stack, a4 = *act_pd
*

bombs:
 move.l   milan,a2
 move.l   milh_prtbombs(a2),a2
 jmp      (a2)


*********************************************************************
*
* VDI-Entry fuers DOS (!)
*

vdi_entry:
 move.l   milan,a0
 move.l   milh_gsx_entry(a0),a0
; move.l  (a0),a0
 jmp      (a0)


     END