     SUPER
     INCLUDE "osbind.inc"


ANZ_SUFFIX     EQU  6	; siehe unten!


**********************************************************************
*
* CMD, letzte énderung 28.5.92, dann 8.2.2026
*
* Switches:                   CMD.PRG
*           KAOS              KCMD.PRG
*           ACC+KAOS          KCMD.ACC
*
**********************************************************************

* OFFSETS FöR PARAMETER DER _COM -  UNTERPROGRAMME

ARGC      EQU  8                   ; Anzahl Parameter
ARGV      EQU  $a                  ; Parametertabelle
PARGC     EQU  $e                  ; Zeiger auf Anzahl Parameter
PARGV     EQU  $12                 ; Zeiger auf argv
BATCH     EQU  $16                 ; Handle der Batchdatei

* DITO FöR PROZEDUREN OHNE "LINK"

SP_ARGC   EQU  ARGC-4
SP_ARGV   EQU  ARGV-4
SP_PARGC  EQU  PARGC-4
SP_PARGV  EQU  PARGV-4
SP_BATCH  EQU  BATCH-4


     XREF    _StkSize
     GLOBL	_stksize

     OFFSET    0

environment:   DS.B      $3ff
env_ende:      DS.B      1

c_sysbase:     DS.L      1              * Merker fÅr "_sysbase"
c_phystop:     DS.L      1              * Merker fÅr "phystop"
query_flag:    DS.W      1
treelevel      EQU       query_flag     * Zum Durchsuchen des Dir- Baums
errlv2         EQU       query_flag     * letzter Errorlevel
t_flag         EQU       query_flag     * Touch- Flag fÅr COPY
dir_zeilen:    DS.W      1              * Bei DIR
schluessel     EQU       dir_zeilen     * Bei SORT

w_flag:        DS.B      1              * Bei DIR
r_flag         EQU       w_flag         * Bei SORT
p_flag:        DS.B      1              * Bei DIR
c_flag         EQU       p_flag         * Bei SORT
q_flag:        DS.B      1              * Bei DIR
attrplus       EQU       q_flag         * Bei ATTRIB
s_flag:        DS.B      1              * Bei DIR
attrminus      EQU       s_flag         * Bei ATTRIB

language:      DS.B      1

               EVEN
     IFEQ MAGIX
etvcritic_alt: DS.L      1			; unter TOS und KAOS verwenden wir einen eigenen etv_critic-Handler
     ENDC

config_alt:    DS.L      1

normal_no:     DS.W      1
ausgabepuffer  EQU       normal_no      * fÅr TOS- Korrektur
hid_sys_no:    DS.W      1
subdir_no:     DS.W      1
normal_len:    DS.L      1
hid_sys_len:   DS.L      1
puffer_adr:    DS.L      1              * Bei DIR
zeiger_adr     EQU       hid_sys_len    * Bei DIR

jmp_env:       DS.L      4

	IFF KAOS
laststring:    DS.B      130            * UNDO- Puffer fÅr den Zeilen-Editor (nur TOS)
home_ypos:     DS.W      1              * fÅr den Zeilen-Editor (nur TOS)
	ENDC
	IF ACC
screenbuf:     DS.L      ZEILEN*20
pnt_of_boot:   DS.L      1
ap_id:         DS.W      1
isxaes:        DS.W      1         ; Flag fÅr "XAES"
menu_id:       DS.W      1
whdl:          DS.W      1
xdesk:         DS.W      1
ydesk:         DS.W      1
wdesk:         DS.W      1
hdesk:         DS.W      1
control:       DS.W      5
global:        DS.W      15
intin:         DS.W      16
intout:        DS.W      16
addrin:        DS.L      2
addrout:       DS.L      1
ev_mgpbuff:    DS.W      8
alt_ssp:       DS.L      1
evnt_ret:      DS.L      20        * oberste Langworte des ssp hier sichern
	ENDC

stacktop:      DS.L      1

bsslen:


	text


_base     EQU  *-$100

* main()
*  Hauptschleife
*  Nach AusfÅhren eines Befehls wird jeweils batchlevel = 0 gesetzt.


__text:
Start:          bra     Start0

                dc.l    0 ; _RedirTab
_stksize:       dc.l    _StkSize                * Stack size entry

***** Speicher zurÅckgeben ************************

Start0:

	IFF ACC					; Wir laufen NICHT als .ACC

 movea.l  4(sp),a1
 move.l   #$100,d0                 ; ProgrammlÑnge + $100
 add.l    $c(a1),d0
 add.l    $14(a1),d0
 add.l    $1c(a1),d0
 lea      -32(a1,d0.l),sp
 lea      d+stacktop(pc),a0
 move.l   sp,(a0)
 move.l   d0,-(sp)
 move.l   a1,-(sp)
 clr.w    -(sp)
 gemdos   Mshrink
 adda.w   #$c,sp
 tst.l    d0                       ; KAOS liefert Fehlermeldung bei Mshrink()
 bmi      exit
 pea      get_sysvars(pc)
 xbios    Supexec
 addq.l   #6,sp

	ENDC

	IF ACC					; Wir laufen als .ACC
 INCLUDE "acc_init.s"
	ENDC

* DOS- Vektoren auf CMD lenken

 clr.w    -(sp)
 gemdos   Sconfig                  ; alten Status lesen
 addq.l   #4,sp

 lea      d+config_alt(pc),a0
 move.l   d0,(a0)
 bmi.b    no_kaos
 lea      is_kaos(pc),a0
 st       (a0)
 bset     #0,d0                    ; PfadÅberprÅfung ein
 move.l   d0,-(sp)
 move.w   #1,-(sp)                 ; setzen
 gemdos   Sconfig
 addq.l   #8,sp
no_kaos:

	IFEQ MAGIX				; Wir laufen NICHT unter MagiC: aktiviere unseren etc-critic-Handler
 pea      etv_critic_neu(pc)
 move.w   #$101,-(sp)    * etv_critic
 bios     Setexc
 addq.l   #8,sp
 lea      d+etvcritic_alt(pc),a0
 move.l   d0,(a0)
	ENDC

 pea      etv_term_neu(pc)
 move.w   #$102,-(sp)    * etv_term
 bios     Setexc
 addq.l   #8,sp
 lea      etv_term_neu-4(pc),a0   ; XBRA- Struktur
 move.l   d0,(a0)

* Behandlung der Kommandozeile
 lea      _base+$80(pc),a5         * a5 auf Kommandozeile
 cmpi.l   #$02736800,(a5)
 bne.b    not_from_tc
* von TC gestartet, Befehl "sh" ignorieren
 clr.b    (a5)
not_from_tc:
	IF ACC
 clr.b    (a5)
	ENDC
 move.b   (a5)+,d7
 ext.w    d7                       * LÑnge der Kommandozeile
 clr.b    0(a5,d7.w)               * Kommandozeile mit EOS abschlieûen

	IFF ACC					; Wir laufen NICHT als .ACC

* Environment-Behandlung
 lea      _base+$2c(pc),a2
 move.l   (a2),a0                  * Zeiger auf altes Environment
 lea      d+environment(pc),a1
 move.l   a1,(a2)                  * Zeiger in Basepage auf neues Environment setzen
 move.l   a0,d0				* altes Environment NULL (unwahrscheinlich)?
 beq.s	ini_22				* ja, nix kopieren
* Environment kopieren
 move.w   #env_ende-environment-2,d1
ini_23:
 move.b   (a0)+,(a1)+
 dbeq     d1,ini_23
 bne.s    ini_22
 tst.b    (a0)
 beq.s    ini_22
 subq.w   #1,d1
 bcc.s    ini_23
ini_22:
 clr.b    (a1)+                    * Kopie mit zwei Nullbytes abschlieûen
 clr.b    (a1)

	ENDC					; IFF ACC

* Maus aus, Cursor ein, Bildschirm lîschen, Titelmeldung

 bsr      cursor                   * Cursor ein/Maus aus

     IFEQ BOOT
 bsr      cls_com				; Bildschirm lîschen und VT52 initialisieren
     ENDC

 lea      titels(pc),a0            * Titelmeldung
 bsr      strcon

* AUTOEXEC.BAT, BOOT.BAT oder Kommandozeile ausfÅhren
 tst.w    d7                       * LÑnge der Kommandozeile
 bne.b    ini_setjmp               ; Kommandozeile existiert

	IF ACC
 lea      acc_init(pc),a0
 tst.w    (a0)                     ; AUTOEXEC schon einmal ausgefÅhrt ?
 bne.b    ini_nocmd                ; ja, nichts tun
 st       (a0)
	ENDC

 lea      autoexec1s(pc),a5
	IFF ACC
 DC.W     A_INIT
 tst.l    8(a0)                    * GEM initialisiert ?
 bne.b    ini_srchauto
 lea      bootbats(pc),a5          * GEM nicht init., also "boot.bat"
	ENDC
ini_srchauto:
 clr.w    d0
 move.l   a5,a0
 bsr      open
 ble.b    ini_srchauto2
ini_isauto:
* \AUTOEXEC.BAT statt Kommandozeile
 bsr      close
 bra.b    ini_setjmp
ini_srchauto2:
* \AUTOEXEC.BAT existiert nicht, alternativen Pfad probieren
 lea      autoexec2s(pc),a5
 moveq    #0,d0
 move.l   a5,a0
 bsr      open
 bgt.b    ini_isauto
ini_nocmd:
 suba.l   a5,a5
ini_setjmp:
 bsr      setjmp

* HAUTPTSCHLEIFE VON CMD :
* ------------------------

ini_mainloop:
 lea      batchlevel(pc),a0        * <==== An diese Stelle wird ge-break-et
 clr.w    (a0)
 move.l   a5,(sp)
 bsr      cmd_exec                 * Eingabezeile ausfÅhren, falls != NULL
 suba.l   a5,a5                    * ab jetzt alle Eingaben von Tastatur holen
 bra.b    ini_mainloop



* void get_sysvars
*  MUû IM SUPERVISOR-MODUS AUSGEFöHRT WERDEN
*
get_sysvars:
 lea      d+c_sysbase(pc),a0
 move.l   _sysbase,a1
 move.l   os_base(a1),a1
 move.b   os_palmode+1(a1),d0
 lsr.b    #1,d0
 move.b   d0,language-c_sysbase(a0)
 move.l   a1,(a0)+           * Zeiger auf Beginn des Betriebssystems
 IF c_phystop-c_sysbase!=4
 ERROR "wrong offset for c_phystop"
 ENDC
 move.l   phystop,(a0)
 rts


* AES Handler fÅr den Betrieb als Accessory

	IF ACC
_aes:
 lea      d+control(pc),a0
 clr.l    (a0)
 clr.l    4(a0)
 movep    d0,5(a0)
 swap     d0
 movep    d0,1(a0)
 move.w   #$c8,d0
 lea      aespb(pc),a0
 move.l   a0,d1
 trap     #2
 move.w   d+intout(pc),d0
 rts
	ENDC


* Alle etv-Vektoren wieder zurÅcksetzen und exit()

restore_etv:
 move.l   d+config_alt(pc),-(sp)
 move.w   #1,-(sp)
 gemdos   Sconfig
 addq.l   #8,sp

     IFEQ MAGIX				; Wir laufen NICHT mit MagiC
 move.l   d+etvcritic_alt(pc),-(sp)
 move.w   #$101,-(sp)              * etv_critic
 bios     Setexc
 addq.l   #8,sp
     ENDC

 move.l   etv_term_neu-4(pc),-(sp)
 move.w   #$102,-(sp)
 bios     Setexc                   * etv_term
 addq.l   #8,sp
exit:
	IF ACC					; Wir laufen als .ACC
 INCLUDE "acc_exit.s"
	ENDC

	IFF ACC
	IFF BOOT
 bsr      mouse
 clr.w    -(sp)
 move.b   is_kaos(pc),d0
 beq.b    ini_exnk
 move.w   #EBREAK,(sp)             ; fÅr MagiX Bildschirm aufrÑumen
ini_exnk:
 gemdos   Pterm
	ENDC
	IF BOOT
 gemdos   Pterm0
	ENDC
	ENDC

* void setjmp()
*  Setzt die RÅcksprungadresse fÅr alle Unterbrechungen und
*  gibt den freien Speicher aus

setjmp:
 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp
 move.l   sp,usp                   ; USP restaurieren
 lea      d+jmp_env(pc),a0
 move.l   d0,sp                    ; SSP restaurieren
 andi.w   #$dfff,sr                ; User mode

 move.l   d0,(a0)+                 ; ssp merken
 move.l   sp,(a0)+                 ; usp merken
 move.l   a6,(a0)+                 ; a6 merken
 move.l   (sp),(a0)+               ; pc merken
 bsr      memavail
 bsr      lwrite_long
 lea      bytes_free_s(pc),a0
 bsr      get_country_str
 bra      strstdout


* COMMAND- eigene etv_term Routine zum Abbruch von
* Programmen

 DC.L     'XBRA'
 DC.L     'KLME'
 DC.L     0
etv_term_neu:
 move.l   d+jmp_env(pc),sp         ; ssp
 andi     #$dfff,sr                ; User mode

* void break()
*  fÅhrt einen Software- Interrupt in die Hauptschleife des CMD aus.
*  Vorher werden alle benutzten Handles zurÅckgegeben und die
*   temporÑren Dateien gelîscht.

break:
 lea      d+jmp_env+4(pc),a0
 movea.l  (a0)+,sp                 ; usp
 movea.l  (a0)+,a6                 ; a6
 move.l   (a0)+,(sp)               ; pc

 lea      _base(pc),a4             ; act_pd (Zeiger auf Basepage)
 moveq    #0,d7
brk_cl:
 move.w   d7,d0
 bsr      close
 addq.w   #1,d7
 cmpi.w   #81,d7              * maximal 81 Dateien
 bcs.b    brk_cl

 move.l   #$fffffefd,$30(a4)  * stdin/stdout/stdaux/stdprn zurÅcklenken
 move.w   #$ffff,$34(a4)      * Handles 4 und 5 ebenfalls

 bsr      clr_pipename        * temporÑre Dateien (fÅr Pipes) lîschen
 suba.l   a5,a5

* void free_tpa()
*  Gibt ggf. reservierten Speicher frei, verÑndert nicht Register d0

free_tpa:
 move.l   d0,-(sp)
 lea      tpa_base(pc),a0
 move.l   (a0),-(sp)
 beq.b    ft_notpa
 clr.l    (a0)
 gemdos   Mfree
 addq.l   #2,sp
ft_notpa:
 addq.l   #4,sp
 move.l   (sp)+,d0
 rts

* long sfirst(a0 = char *path, a1 = DTA *dta, d0 = int attr_pat)

sfirst:
 move.w   d0,-(sp)
 move.l   a0,-(sp)
 move.l   a1,-(sp)
 gemdos   Fsetdta
 addq.l   #6,sp
 gemdos   Fsfirst
 addq.l   #8,sp
 tst.l    d0
 rts


* long snext(a0 = DTA *dta)

snext:
 move.l   a0,-(sp)
 gemdos   Fsetdta
 gemdos   Fsnext
 addq.l   #8,sp
 tst.l    d0
 rts


* long read(d0 = int handle, d1 = long count, a0 = char *buf)

read:
 moveq    #Fread,d2
 bra.b    r_w


* long write(d0 = int handle, d1 = long count, a0 = char *buf)

write:
 moveq    #Fwrite,d2
r_w:
 move.l   a0,-(sp)                 ; buffer
 move.l   d1,-(sp)                 ; count
 move.w   d0,-(sp)                 ; handle
 move.w   d2,-(sp)                 ; DOS- Funktionscode
 trap     #1
 adda.w   #$c,sp
 rts


* long create(a0 = char filename[], d0 = int attr)
*  Erstellt eine Datei und merkt das Handle in handle_tab, indem
*  das entsprechende Bit gesetzt wird.

create:
 moveq    #Fcreate,d1
 bra.b    op_cr

* long open(a0 = char filename[], d0 = int mode)
*  ôffnet eine Datei und merkt das Handle in handle_tab, indem
*  das entsprechende Bit gesetzt wird.

open:
 moveq    #Fopen,d1
op_cr:
 move.w   d0,-(sp)                 ; mode bzw. Attribut
 move.l   a0,-(sp)                 ; Dateiname
 move.w   d1,-(sp)                 ; DOS- Befehlscode
 trap     #1
 addq.l   #8,sp
merke_hdl:
 tst.w    d0
 bmi.b    mh_err
 move.w   d0,d1
 bsr.b    hdl_to_tab
 bset.b   d2,(a0)                  * Handle als "offen" merken
mh_err:
 tst.l    d0
 rts

* long close(), d0 = int handle
*  Schlieût eine Datei und merkt das Handle in handle_tab, indem
*  das entsprechende Bit gelîscht wird.

close:
 cmpi.w   #6,d0
 blt.b    cl_60                    * GerÑte oder Standarddateien
 move.w   d0,d1
 bsr.b    hdl_to_tab
 btst.b   d2,(a0)                  * Ist Handle geîffnet ?
 beq.b    cl_50
 move.l   a0,-(sp)
 move.w   d2,-(sp)
 move.w   d0,-(sp)
 gemdos   Fclose
 addq.l   #4,sp
 move.w   (sp)+,d2
 move.l   (sp)+,a0
 tst.w    d0
 bmi.b    cl_end
 bclr.b   d2,(a0)                  * Handle als "geschlossen" merken
cl_end:
 rts
cl_50:
 moveq    #EIHNDL,d0
 rts
cl_60:
 move.w   d0,-(sp)
 gemdos   Fclose
 addq.l   #4,sp
 rts

hdl_to_tab:
 lea      handle_tab(pc),a0
 move.w   d1,d2                    * d1 ist das Handle
 lsr.w    #3,d1
 add.w    d1,a0
 andi.w   #$7,d2                   * Zugriff Åber "bxxx d2,(a0)"
 rts

handle_tab:
 DCB.B    1+(129/8),0              * 128 Handles merken
 EVEN

* char *alloc_tpa(d0 = long size)
*  Holt Speicher vom Betriebssystem, und zwar <size> Bytes.
*  Sind diese nicht vorhanden, wird eine Fehlermeldung ausgegeben.
*  Falls OK : Flag: Z=0, a0 = tpa_base
*  Fehler   : Flag: Z=1

alloc_tpa:
 move.l   d0,-(sp)
 gemdos   Malloc
 addq.l   #6,sp
 lea      tpa_base(pc),a0
 move.l   d0,(a0)
 bne.b    atpa_end                 * alles ok
 lea      err_39s(pc),a0
 bsr      strcon
 clr.l    d0                       * Fehler : NULL- Pointer
atpa_end:
 rts


* long memavail()
*  Gibt Malloc(-1L) zurÅck

memavail:
 moveq.l  #-1,d0
 move.l   d0,-(sp)
 gemdos   Malloc
 addq.l   #6,sp
 rts


* void rwrite_long(d0 = unsigned long zahl, d1 = int len)
* Schreibt eine Langzahl rechtsbÅndig

rwrite_long:
 moveq    #' ',d2
 bra.b    write_long


* void lwrite_long(d0 = unsigned long zahl)
* Schreibt eine Langzahl linksbÅndig

lwrite_long:
 moveq    #0,d2
 moveq    #10,d1
;bra.b    write_long


* void write_long(d0 = unsigned long zahl, d1 = int len, d2 = char leader)
*  Gibt in einem Feld der LÑnge <len> rechtsbÅndig eine Zahl aus (>stdout).
*  Das Feld wird links mit <fill_char> aufgefÅllt.


STRBUFSIZE    SET  12

write_long:
 link     a6,#-STRBUFSIZE
 movem.l  d6/d7,-(sp)
 move.w   d1,d7                    * len
 move.b   d2,d6                    * leader
 lea      -STRBUFSIZE(a6),a0
 bsr      long_to_str			; gibt d0 und a0 zurÅck
 sub.w    d0,d7                    * d0 ist tatsÑchliche LÑnge, a0 der Anfang
 ble.s    wl_nofill				; alles belegt, nicht auffÅllen
 tst.b    d6					; Åberhaupt auffÅllen?
 beq.s    wl_nofill				; nein
 move.l   a0,-(sp)
 bra.b    wl_put
wl_loop:
 move.b   d6,d0
 bsr      putchar
wl_put:
 dbra     d7,wl_loop
 move.l   (sp)+,a0
wl_nofill:
 bsr      strstdout                * Zahl ausgeben
 movem.l  (sp)+,d6/d7
 unlk     a6
 rts


*
* d0/a0 = long_to_str(d0 = unsigned long zahl, a0 = char string[])
*  Wandelt eine Zahl dezimal in eine Zeichenkette um.
* In d0 wird die LÑnge zurÅckgegeben.
* In a0 wird der Zeiger auf das erste Zeichen zurÅckgegeben.
*
* d0,d1,d2,a0,a1 werden zerstîrt.
*
long_to_str:
 lea		STRBUFSIZE(a0),a1	; wir fangen rechts an ...
 clr.b	-(a1)			; ... und schreiben erstmal das Null-Byte
 move.l	a1,a0
lts_loop:
 bsr		_uldiv10		; niedrigstwertige Dezimalziffer nach -(a0)
 tst.l	d0			; verbleibender Quotient?
 bne.s	lts_loop		; ja, weitere Ziffern folgen
 suba.l   a0,a1         ; Zeichenketten-Anfang abziehen
 move.l   a1,d0         ; ZeichenkettenlÑnge zurÅckgeben
 rts


*
* Teile d0.l durch 10 und wandle den Divisionsrest in eine
* Dezimalziffer um, die nach -(a0) geschrieben wird.
* Gib den Quotienten in d0.l zurÅck.
* d1 und d2 werden zerstîrt, a0 um 1 verringert.
*

*
* Der Befehl "divu" des 68000 teilt 32 Bit durch 16 Bit, aber
* Quotient und Rest dÅrfen nur je 16 Bit groû sein.
* Teile ich 1048576 durch 10, dann ist das 104857 mit Rest 6,
* d.h. der Quotient ist 0x19999 und paût nicht in 16 Bit.
*
* TODO: Statt die oberen 16 Bit des Dividenden abfragen, also
*       dividend > 65535, dann besser abfragen, ob
*       dividend > 655350
*
_uldiv10:
 move.l	d0,d2
 swap	d2
 tst.w	d2			; obere 16 Bit
 bne.s	_uldiv1		; sind ungleich Null, komplizierte Methode
 divu	#10,d0		; Durch 10 teilen
 swap	d0			; Rest in den unteren 16 Bit
 add.b	#'0',d0		; in Dezimalziffer wandeln
 move.b	d0,-(a0)	; Ziffer abspeichern
 clr.w	d0
 swap	d0			; d0.l = Quotient
 rts
_uldiv1:
 clr.w	d0
 swap	d0
 swap	d2
 divu	#10,d0
 move.w	d0,d1
 move.w	d2,d0
 divu	#10,d0
 swap	d0
 add.b	#'0',d0
 move.b	d0,-(a0)
 move.w	d1,d0
 swap	d0
 rts

*
* d0 = d0 * d1
* Zerstîrt d0/d2
*
_ulmul:
 move.l	d0,d2
 swap	d2
 tst.w	d2
 bne.s	_ulmul2
 move.l	d1,d2
 swap	d2
 tst.w	d2
 bne.s	_ulmul1
 mulu	d1,d0
 rts
_ulmul1:
 mulu	d0,d2
 swap	d2
 mulu	d1,d0
 add.l	d2,d0
 rts
_ulmul2:
 mulu	d1,d2
 swap	d2
 mulu	d1,d0
 add.l	d2,d0
 rts


* char *skip_sep(a0 = string)
* a0 = char *string;

skip_sep:
 move.b   (a0)+,d0
 cmpi.b   #' ',d0
 beq.b    skip_sep
 cmpi.b   #TAB,d0
 beq.b    skip_sep
;cmpi.b   #LF,d0
;beq.b    skip_sep
skip1:
 move.l   a0,d0
 subq.l   #1,d0
 rts


* char *search_sep(a0 = string)
* a0 = char *string;

search_sep:
 move.b   (a0)+,d0
 beq.b    ssep_2
 cmpi.b   #' ',d0
 beq.b    ssep_2
 cmpi.b   #TAB,d0
;beq.b    ssep_2
;cmpi.b   #LF,d0
 bne.b    search_sep
ssep_2:
 bra.b    skip1


* char *chrsrch(a0 = string, d0 = c)
* a0 = char *string;
* d0 = char c;
*  RÅckgabe: Zeiger auf gefundenes Zeichen oder NULL
* Kommt mit gesetztem/gelîschtem Z-Flag zurÅck
*

chrsrch:
 tst.b    (a0)
 beq.b    chs_notfound
 cmp.b    (a0)+,d0
 bne.b    chrsrch
 move.l   a0,d0
 subq.l   #1,d0
 rts
chs_notfound:
 moveq    #0,d0
 rts


* int enth_jok(a0 = string)
* a0 = char string[];
*  Die Zeichenkette <string> wird untersucht, ob sie einen Joker
*  '*' oder '?' enthÑlt
*  RÅckgabe 1, wenn ja. Sonst 0. Z-Flag ggf. gesetzt

enth_jok:
 moveq    #1,d0
ej_loop:
 cmpi.b   #'?',(a0)
 beq.b    ej_end
 cmpi.b   #'*',(a0)
 beq.b    ej_end
 tst.b    (a0)+
 bne.b    ej_loop
 moveq    #0,d0
ej_end:
 tst.w    d0
 rts

*
*
* int strncmp(a0 = char *s1, a1 = char *s2, d0 = int n)
* Kommt mit gesetztem/gelîschtem Z-Flag zurÅck
*

strncmp:
 move.w  d0,d1
 subq.w  #1,d1
 bcs.b   snc_4            * n = 0
 bra.b   snc_2
snc_loop:
 tst.b   -1(a0)
 beq.b   snc_4
snc_2:
 cmp.b   (a1)+,(a0)+
 beq.b   snc_3
 move.b  -1(a0),d0
 sub.b   -1(a1),d0
 ext.w   d0
 bra.b   snc_5
snc_3:
 dbra    d1,snc_loop
snc_4:
 moveq    #0,d0
snc_5:
 rts


* long strlen(a0 = string)

strlen:
 move.l   a0,a1
sl_loop:
 tst.b    (a0)+
 bne.b    sl_loop
 suba.l   a1,a0
 move.l   a0,d0
 subq.l   #1,d0
 rts


* void strcpy(a0 = string1, a1 = string2)

strcpy:
 move.b   (a1)+,(a0)+
 bne.b    strcpy
 rts


* void strcat(a0 = string1, a1 = string2)

strcat:
 tst.b    (a0)+
 bne.b    strcat
 subq.l   #1,a0
stct_loop:
 move.b   (a1)+,(a0)+
 bne.b    stct_loop
 rts


* int strcmp(a0 = char *string1, a1 = char *string2)
*  RÅckgabe: string1-string2 (als Vektoren)

str2:
 tst.b    -1(a0)
 bne.b    strcmp
 moveq    #0,d0
 bra.b    str3
strcmp:
 cmp.b    (a1)+,(a0)+
 beq.b    str2
 move.b   -1(a0),d0
 sub.b    -1(a1),d0
 ext.w    d0
str3:
 rts


* int str_toi(a0 = char *string)
*  Wandelt String ohne Vorzeichen in int

str_toi:
 clr.w    d0
 clr.w    d1
stoi_loop:
 move.b   (a0)+,d1
 subi.b   #'0',d1
 cmpi.b   #9,d1
 bhi.b    stoi_end
 muls     #10,d0
 add.w    d1,d0
 bra.b    stoi_loop
stoi_end:
 rts


* d0_upper
*  wandelt in d0.b Klein- in Groûbuchstaben um.

d0_upper:
 cmpi.b   #'a',d0
 blt.b    up_end
 cmpi.b   #'z',d0
 bgt.b    up_end
 sub.b    #'a'-'A',d0
up_end:
 rts


* void str_upper(a0 = string)
* a0 = char *string;
*  Wandelt einen String in Groûschrift um

str_upper:
 move.b   (a0),d0
 beq.b    su_end
 bsr.b    d0_upper
 move.b   d0,(a0)+
 bra.b    str_upper
su_end:
 rts

*
*
* void upper_strcmp(a0 = char *string1, a1 = char *string2)
* Kommt mit gesetztem oder gelîschtem Z-Flag zurÅck
*

ustr1:
 tst.b    d1
 beq.b    ustr100
upper_strcmp:
 move.b   (a1)+,d0
 bsr      d0_upper
 move.b   d0,d1
 move.b   (a0)+,d0
 bsr      d0_upper
 sub.b    d1,d0
 beq.b    ustr1
ustr100:
 ext.w    d0
 rts


* int isdrive(a0 = char *string)
*  RÅckgabe Laufwerksnummer <=> string[0] enth. zul. Laufwerks- Bezeichnung
*  sonst: Fehlermeldung und Erhîhung des errorlevel, RÅckgabe -1
*  Falls alles ok:
*  PrÅft, ob die Diskette des in <path> spezifizierten Laufwerks
*  gewechselt wurde, und veranlaût, wenn ja, GEMDOS zur Neuinitialisierung
*  seiner internen Pfadpuffer.

isdrive:
 move.w   d5,-(sp)
 clr.w    d5
 move.b   (a0),d5
 cmpi.w   #'1',d5
 blt.s    isd_err
 cmpi.w   #'6',d5
 bhi.s    isdrivea
 subi.w   #'1'-26,d5
 bra.s    chkdrive
isdrivea:
 andi.w   #$5f,d5             * toupper
 subi.w   #'A',d5
 blt.b    isd_err
chkdrive:
 bios     Drvmap
 addq.l   #2,sp
 moveq    #1,d1
 lsl.l    d5,d1
 and.l    d1,d0
 beq.b    isd_err

 IFF      KAOS
 move.w   d5,-(sp)
 bsr.b    chgdrive
 addq.l   #2,sp
 ENDC

 move.w   d5,d0          * Laufwerksnummer zurÅckgeben
 bra.b    isd_end
isd_err:
 bsr      inc_errlv
 bsr      crlf_con
 lea      err_46s(pc),a0           * "UngÅltiges Laufwerk"
 bsr      strcon
 bsr      crlf_con
 moveq    #-1,d0
isd_end:
 move.w   (sp)+,d5
 rts

drive_to_letter:
 dc.b    "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456"

 IFF      KAOS
* int chgdrive(drive)
* int drive;
*  PrÅft, ob die Diskette des in <drive> spezifizierten Laufwerks
*  gewechselt wurde und veranlaût, wenn ja, GEMDOS zur Neuinitialisierung
*  seiner internen Pfadpuffer.
*  RÅckgabe -1, wenn dabei Lesefehler auftrat
*  Macht KAOS automatisch

DTA       SET  -44            * char DTA[44]

chgdrive:
 link     a6,#DTA
 move.w   d7,-(sp)
 move.w   8(a6),d7
 move.w   d7,-(sp)
 bios     Mediach             * Disk gewechselt ?
 addq.l   #4,sp
 tst.l    d0
 beq.b    chgd_end            * nein => chgd_end

 lea      DTA(a6),a1
 move.w   #%111110,d0         * alle Attribute
 lea      drive_to_letter(pc),a0
 add.b    0(a0,d7.w),d7
 lea      croots(pc),a0       * "X:\*.*"
 move.b   d7,(a0)
 bsr      sfirst

 beq.b    chgd_end
 moveq    #ENMFIL,d1
 sub.l    d1,d0               * Fehlercode "Keine Dateien" abziehen
 beq.b    chgd_end            * "Keine Dateien" ist kein Fehler
 moveq    #-1,d0
chgd_end:
 move.w   (sp)+,d7
 unlk     a6
 rts
 ENDC


* int is_newdrive(a0 = char *string)
*  stellt fest, ob ein String das Kommando ist, ein neues
*  Default- Laufwerk zu wÑhlen ("X:")
*  Falls ja, wird auf Diskwechsel geprÅft
*  RÅckgabe :  -2       Nein
*              -1       Ja, aber Laufwerk unzulÑssig
*           Drivenummer alles ok

is_newdrive:
 moveq    #-2,d0
 tst.b    (a0)+
 beq.b    isnd_end
 cmpi.b   #':',(a0)+
 bne.b    isnd_end
 tst.b    (a0)
 bne.b    isnd_end
 subq.l   #2,a0
;move.l   a0,a0
 bsr      isdrive
isnd_end:
 rts


* int str_to_drive(a0 = char *string)
*  strlen <= 1:       RÅckgabe Defaultdrive
*  string[1] != ':'       "        "
*  sonst RÅckgabe der Drivenummer, wenn ok, sonst -1
*  Das angesprochene Laufwerk wird auf Diskwechsel geprÅft
* Flags gesetzt
*

str_to_drive:
 move.b   (a0)+,d1
 beq.b    std_50              * Leerstring
 tst.b    (a0)
 beq.b    std_50              * String mit 1 Zeichen
 cmpi.b   #':',(a0)
 bne.b    std_50              * Zweites Zeichen kein ':'
 subq.l   #1,a0
;move.l   a0,a0
 bsr      isdrive             * Laufwerkscode oder -1
 IFF      KAOS
 tst.w    d0
 bge.b    std_51
 ENDC
 bra.b    std_end
std_50:
 gemdos   Dgetdrv
 addq.l   #2,sp               * Default- Laufwerk nach d0
std_51:
 IFF      KAOS
 move.w   d0,-(sp)
 bsr      chgdrive
 or.w     (sp)+,d0
 ENDC
std_end:
 tst.w    d0
 rts


*
* void fatal(d0 = errno)
* int errno;
*  Falls <errno> < 0, wird der Fehlercode ausgedruckt und CMD
*  neu gestartet (break)
*
fatal:
 tst      d0
 bge.b    fat_end
 bsr      crprint_err
 bra      break
fat_end:
 rts


*
* void print_err(d0 = errno)
* int errno;
*  Schreibt den zum DOS- Fehlercode <errno> gehîrenden Fehlertext nach CON:
*

print_err:
 lea      errcodes(pc),a0
 bsr      chrsrch                  * errno suchen
 lea      toserrs(pc),a0
 beq.b    pre_print
 lea      errcodes(pc),a1
 sub.l    a1,d0
 lsl.l    #1,d0
 lea      errstrs(pc),a1
 move.w   0(a1,d0.l),a0
 add.l    a1,a0
pre_print:
 bsr      strcon
 rts


*
* int crprint_err(d0 = int errcode)
*  wie print_err, gibt vorher und nachher cr/lf nach CON
*  Gibt Fehlercode wieder in d0 zurÅck
*
crprint_err:
 move.w   d0,-(sp)
 bsr      crlf_con
 move.w   (sp),d0
 bsr.b    print_err
 bsr      crlf_con
 move.w   (sp)+,d0
 rts


* int checkpath(a0 = char *eingabe, a1 = char *string)
*  Falls <eingabe> ein Pfad oder ein Verzeichnis ist:
*   Kopiere <eingabe> nach <string>, hÑnge bei Bedarf '\' dahinter
*   RÅckgabe : 1
*  Sonst:
*   Kopieren <eingabe> einfach nach <string>
*   RÅckgabe : 0


DTA       SET  -44

checkpath:
 link     a6,#DTA
 movem.l  d7/a5,-(sp)
 movea.l  a1,a5                    ; Ausgabe merken
 exg      a0,a1                    ; Eingabe nach Ausgabe
 bsr      strcpy         * kopiere Ein- nach Ausgabe
 move.l   a5,a0
 bsr      is_newdrive
 addq.w   #1,d0          * korrekte Laufwerksnummer wie "x:" ?
 bge.b    chp_end        * ja => return(>0), Fehler => return(0)

	IFF KAOS
 move.l   a5,a0
 bsr      str_to_drive   * Diskwechsel prÅfen
 bmi.b    chp_end        * Fehler => return(<0)
	ENDC

 move.l   a5,a0
 bsr      strlen
 move.l   d0,d7
 moveq    #1,d0
 move.b   -1(a5,d7.l),d1 * d1 = letztes Zeichen der Eingabe
 cmpi.b   #'\',d1
 beq.b    chp_end        * <eingabe> endet mit '\' => return(>0)
 cmpi.b   #'.',d1        * <eingabe> endet mit '.' => '\' anhÑngen
 beq.b    chp_sl

 lea      DTA(a6),a1
 moveq    #$16,d0
 move.l   a5,a0
 bsr      sfirst

 move.l   d0,d1
 clr.w    d0
 tst.l    d1             * Fsfirst() erfolgreich ?
 bmi.b    chp_end        * Keine Datei => return(0)
 btst.b   #4,21+DTA(a6)  * Attrib = Subdir ?
 beq.b    chp_end        * nein => return(0)
chp_sl:
 add.l    d7,a5
 move.b   #'\',(a5)+     * "\" anhÑngen
 clr.b    (a5)
 moveq    #1,d0
chp_end:
 movem.l  (sp)+,a5/d7
 unlk     a6
 rts


*
* int split_path(a0 = string1, a1 = string2, a2 = string3)
*  strcpy(string3,string1)
*  strcpy(string2,string1)
*  1. Fall: string1 = "" oder "x:" oder "xxx...xxx\"
*           strcat(string2,"*.*")
*           return(1)
*  2. Fall: sonst
*           1.Fall: string1 enthÑlt Joker '*' oder '?'
*                   LABEL: setze in string3 EOS hinter letztes '\' oder ':'
*                          (d.h. isoliere Pfad in string3)
*                   return(1)
*           2.Fall: sonst
*                   1. Fall: string1 ist kein korrekter Pfad
*                            return(0)
*                   2. Fall: sonst
*                            1. Fall: string1 ist Subdirectory, oder Datei
*                                             existiert nicht
*                                     strcat(string2,"\*.*")
*                                     strcat(string3,"\")
*                                     return(1)
*                            2. Fall: string1 ist korrekte Datei
*                                     goto LABEL
*
* Wird benutzt von DEL, DIR, MV, COPY, FOR
*
split_path:
 movem.l  d7/a3/a4/a5,-(sp)
 movea.l  a0,a3
 movea.l  a1,a4
 movea.l  a2,a5
 move.l   a3,a1
 move.l   a4,a0
 bsr      strcpy
 move.l   a3,a1
 move.l   a5,a0
 bsr      strcpy
 move.l   a3,a0
 bsr      strlen
 move.l   d0,d7            * strlen(string1) == 0 ?
 beq.b    splp_2
 cmpi.w   #2,d0
 bne.b    splp_1
 cmpi.b   #':',1(a3)
 beq.b    splp_2
splp_1:
 cmpi.b   #'\',-1(a3,d0.l)
 bne.b    splp_3
splp_2:
 lea      star_pt_star(pc),a1 * string1 == "" oder "x:" oder "xxx...xxx\"
 move.l   a4,a0
 bsr      strcat              * string2 = string1 + "*.*"
 moveq    #1,d0
 bra.b    splp_20
splp_3:
 move.l   a3,a0
 bsr      enth_jok
 beq.b    splp_9
splp_11:
 move.l   a5,a0
 adda.w   d7,a0
splp_4:
 move.b   -(a0),d0
 cmpi.b   #'\',d0
 beq.b    splp_7
 cmpi.b   #':',d0
 beq.b    splp_7
 cmpa.l   a0,a5
 bcs.b    splp_4
 bra.b    splp_8
splp_7:
 addq.l   #1,a0
splp_8:
 clr.b    (a0)             * in string3 hinter letztes ':' oder '\' EOS setzen
 moveq    #1,d0
 bra.b    splp_20
splp_9:
 move.w   #$16,-(sp)       * string1 enthÑlt keine Joker '*' oder '?'
 clr.w    -(sp)
 move.l   a3,-(sp)
 gemdos   Fattrib                  * Dateiattribute fÅr Datei <string1> holen
 adda.w   #$a,sp
 cmpi.w   #-34,d0
 bne.b    splp_10
 clr.w    d0                       * "Path not found"
 bra.b    splp_20
splp_10:
 btst     #4,d0
 bne.b    splp_12
 tst.w    d0
 blt.b    splp_12
 bra.b    splp_11
splp_12:
 lea      allroots(pc),a1             * "\*.*"
 move.l   a4,a0
 bsr      strcat                   * string2 = string1 + "\*.*"
 adda.l   d7,a5
 move.b   #'\',(a5)+               * string3 = string1 + "\"
 clr.b    (a5)
 moveq    #1,d0
splp_20:
 movem.l   (sp)+,d7/a3/a4/a5
 rts


*
* Erst Cursor aus-, dann Mauszeiger einschalten
*
mouse:
     IFEQ BOOT
 clr.w    -(sp)
 xbios    Cursconf
 addq.l   #4,sp
 DC.W     A_INIT
 move.l   8(a0),a1                 ; intin
 move.l   a1,d0                    ; LineA schon initialisiert ?
 beq.b    mo_no                    ; nein
 clr.w    (a1)                     ; intin[0] = 0
 DC.W     A_SHOW_MOUSE
mo_no:
     ENDC
 rts


*
* Erst Mauszeiger aus-, dann Cursor einschalten
*
cursor:
     IFEQ BOOT
 DC.W     A_HIDE_MOUSE
 move.w   #1,-(sp)
 xbios    Cursconf
 addq.l   #4,sp
     ENDC
 rts


cls_com:
 lea      clss(pc),a0


*
* void strcon(string)
* a0 = char *string;
*  gibt eine Zeichenkette an die Konsole CON:
*
strcon:
 move.l   a5,-(sp)
 move.l   a0,a5                    * string in a5[]
strc_loop:
 move.b   (a5)+,d0
 beq.b    strc_end
 bsr.b    putch
 bra.b    strc_loop
strc_end:
 move.l   (sp)+,a5
 rts


*
* void crlf_con()
*
crlf_con:
 moveq    #CR,d0
 bsr.b    putch
 moveq    #LF,d0


*
* void putch()
*  Druckt das Zeichen in d0 nach Device 2 (CON)
*
putch:
 move.w   d0,-(sp)
 move.w   #2,-(sp)
 bios     Bconout
 addq.l   #6,sp
 rts


*
* void crlf_stdout()
*
crlf_stdout:
 moveq    #CR,d0
 bsr.b    putchar
 moveq    #LF,d0


*
* long putchar()
*  Druckt das Zeichen in d0 nach stdout
*
putchar:
 move.w   d0,-(sp)
 lea      1(sp),a0
 moveq    #STDOUT,d0               * Handle 1 = STDOUT
 moveq    #1,d1                    * Anzahl = 1
 bsr      write
 addq.l   #2,sp
 rts


*
* void strstdout(a0 = string)
* a0 = char *string;
*  Ersatz fÅr fehlerhafte Funktion gemdos Cconws(), deren Ausgabe man nicht
*  auf den Drucker lenken kann.
*
strstdout:
 move.l   a0,-(sp)                 * string retten
 bsr      strlen
 move.l   (sp)+,a0                 * string
 move.l   d0,d1                    * len
 moveq    #STDOUT,d0
 bra      write


     IFEQ MAGIX
* long etv_critic_neu(errno)
* int errno;
*  RÅckgabe (long):      Abbruch: errno
*                        Wiederh. $10000
*                        Ignor.   0

etv_critic_neu:
 bsr      crlf_con
 lea      change_s(pc),a0
 move.w   4(sp),d0                 * Fehlercode
 cmpi.w   #EOTHER,d0
 beq.s    etc_4
 bsr      print_err
 lea      diskerr_s(pc),a0
etc_4:
 move.w   6(sp),d0                 * Laufwerknummer
 lea      strcon(pc),a1
 bsr      print_with_driveletter
etc_getkey:
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
 cmpi.b   #3,d0				* ^C
 bne.b    etc_nobreak
 move.w   #EBREAK,-(sp)
 gemdos   Pterm
 addq.l   #4,sp
etc_nobreak:
 cmpi.w   #EOTHER,4(sp)
 beq.b    etc_6
 bsr      d0_upper
 cmpi.b   #'A',d0   			* A: "Abbruch" oder "Abort"
 bne.b    etc_2
	* Abort
 move.w   4(sp),d1
 ext.l    d1
 bra.b    etc_11
etc_6:
 move.b   #' ',d0
 bra.b    etc_retry
etc_2:
 cmpi.b	#'R',d0
 beq.b	etc_retry				* R: "Retry"
 cmpi.b   #'W',d0   * Wiederh.
 bne.b    etc_3
 	* Retry
etc_retry:
 move.l   #$10000,d1
 bra.b    etc_11
etc_3:
 cmpi.b   #'I',d0			* I: "Ignore" oder "Ignorieren"
 bne.b    etc_getkey
 	* Ignore
 clr.l    d1
etc_11:
 move.l   d1,-(sp)  * RÅckgabewert auf Stapel retten
 move.w   d0,-(sp)  * Eingegebenes Zeichen ausgeben
 move.w   #5,-(sp)
 bios     Bconout
 addq.l   #6,sp
 bsr      crlf_con
 move.l   (sp)+,d0  * RÅckgabewert von Stapel
 rts
     ENDC


* d0 = char *getenv(a0 = char *string)
*  PrÅft, ob die Variable <string> im environment existiert
*  RÅckgabe: d0 = Zeiger auf den WERT der Variablen (im Env.) oder NULL
*  RÅckgabe: a0 = Zeiger auf die Variable selbst
*  Z-Flag korrekt beeinfluût

getenv:
 move.l   a5,-(sp)
 move.l   a0,a2                    * string[] nach a4
 bsr      str_upper
 move.l   a2,a0
 bsr      strlen
 move.w   d0,d2
 lea      d+environment(pc),a5
 bra.b    getenv_3
getenv_loop:
 move.w   d2,d0
 move.l   a2,a1
 move.l   a5,a0
 bsr      strncmp
 bne.b    getenv_next
* gefunden!
 move.l   a5,a0                    * RÅckgabe: Variable
getenv_4:
 tst.b    (a5)
 beq.b    getenv_90
 cmpi.b   #'=',(a5)+
 bne.b    getenv_4
 move.l   a5,d0                    * RÅckgabe: Wert
 bra.b    getenv_end
getenv_next:
 tst.b    (a5)+
 bne.b    getenv_next
getenv_3:
 tst.b    (a5)
 bne.b    getenv_loop
getenv_90:
 moveq    #0,d0
getenv_end:
 move.l   (sp)+,a5
 rts


*
* int env_set(a0 = char *zuweisung)
*  Setzt eine Variable im Environment. RÅckgabe: 0 = OK
*                                                1 = Syntaxfehler
*                                                2 = Environment voll
*
env_set:
 movem.l  d7/a5/a4,-(sp)
 move.l   a0,a5
 moveq    #'=',d0
 move.l   a5,a0
 bsr      chrsrch
 beq.b    envset_5
 cmpi.b   #'=',(a5)
 bne.b    envset_6
envset_5:
 moveq    #1,d0          * Syntaxfehler
 bra.b    envset_end
envset_6:
 move.l   d0,a4
 addq.l   #1,a4       * a4 zeigt hinter das '=' im Parameter a5[]
 move.b   (a4),d7     * Zeichen hinter '=' retten.
 clr.b    (a4)        * stattdessen hinter '=' ein EOS setzen
 move.l   a5,a0
 bsr      str_upper   * String (bis einschl. '=') in Groûschrift
 move.l   a5,a0
 bsr      getenv      * Suche im Environment
;move.l   d0,a0       * a0[] ist Kopie im Environment oder NULL
 beq.b    envset_7
 move.l   a0,a1
envset_8:
 tst.b    (a0)+
 bne.b    envset_8    * a0 auf erstes Zeichen hinter dem Eintrag
envset_10:
 move.b   (a0)+,(a1)+
 bne.b    envset_10
 tst.b    (a0)
 bne.b    envset_10   * Lasse Rest des Environments aufrÅcken
 clr.b    (a1)        * Am Ende wieder doppelte Null erzeugen
envset_7:
 clr.w    d0          * kein Fehler
 move.b   d7,(a4)     * Stand im Parameter etwas hinter dem '=' ?
 beq.b    envset_end  * War das Ende => ok
 move.l   a5,a0       * LÑnge des Parameters
 bsr      strlen
 addq.w   #3,d0
 lea      d+environment(pc),a4
 bra.b    envset_14   * PrÅfen, ob Environment vîllig leer ist
envset_11:
 tst.b    (a4)+
 bne.b    envset_11
envset_14:
 tst.b    (a4)
 bne.b    envset_11      * Suche nach dem Ende des Environments (in a4)
 lea      d+env_ende(pc),a0
 suba.l   a4,a0
 cmp.l    a0,d0
 ble.b    envset_12
 lea      out_of_envs(pc),a0
 bsr      get_country_str
 bsr      strcon
 moveq    #2,d0       * Environment ist voll
 bra.b    envset_end
envset_12:
 move.l   a5,a1
 move.l   a4,a0
 bsr      strcpy
envset_13:
 tst.b    (a4)+
 bne.b    envset_13
 clr.b    (a4)           * Erzeuge wieder doppelte Null am Ende
 clr.w    d0             * kein Fehler
envset_end:
 movem.l  (sp)+,d7/a5/a4
 rts


	INCLUDE "intern\set.s"


* void time_to_str(a0 = char *string)
*  Packt aktuelle Zeit in der Form "hh:mm:ss" in <string>


time_to_str:
 move.l   a0,-(sp)
 gemdos   Tgettime
 addq.l   #2,sp
 move.l   (sp)+,a0
 move.w   d0,-(sp)
 andi.w   #%11111,(sp)
 asl.w    (sp)            * Sec.
 lsr.w    #5,d0
 move.w   d0,-(sp)
 andi.w   #%111111,(sp)   * Min.
 lsr.w    #6,d0
 move.w   d0,-(sp)        * Std.
 moveq    #':',d2
ausgabe:
 moveq    #2,d1          * 3 Zahlen sind auszugeben
ausg_loop:
 clr.l    d0             * Hiword lîschen
 move.w   (sp)+,d0
 divu     #10,d0
 addi.b   #'0',d0
 move.b   d0,(a0)+       * Zehnerziffer
 swap     d0
 addi.b   #'0',d0
 move.b   d0,(a0)+       * Einerziffer
 move.b   d2,(a0)+       * Trennzeichen
 dbra     d1,ausg_loop
 clr.b    -1(a0)
 rts


* void date_to_str(a0 = char *string)
*  Packt aktuelles Datum in der Form "tt/mm/jj" in <string>

date_to_str:
 move.l   a0,-(sp)
 gemdos   Tgetdate
 addq.l   #2,sp
 move.l   (sp)+,a0

* void _date_to_str(d0 = int date, a0 = char *string)
*  Packt Datum <d0> in der Form "tt/mm/jj" in <string>

_date_to_str:
 move.w   d0,d1
 andi.w   #%11111,d1   * Tag nach d1
 lsr.w    #5,d0
 move.w   d0,d2
 andi.w   #%1111,d2    * Monat nach d2
 lsr.w    #4,d0
 addi.w   #80,d0       * 80 von 1980 addieren
 cmpi.w   #100,d0      * < Jahr 2000 ?
 bcs.b    dats_1
 subi.w   #100,d0
dats_1:
 move.w   d0,-(sp)     * Jahr
 move.w   d2,-(sp)     * Monat
 move.w   d1,-(sp)     * Monat
 moveq    #'/',d2
 bra.b    ausgabe      * Rest wie bei Uhrzeit


* void drive_to_defpath(d0 = int drive, a0 = char *string)
*  Kopiert den Default- Pfad fÅr das angegebene Laufwerk

drive_to_defpath:
 lea      drive_to_letter(pc),a1
 move.b   0(a1,d0.w),d1
 move.b   d1,(a0)+
 move.b   #':',(a0)+
 clr.b    (a0)                     * Falls Dgetpath() Fehler meldet
 addq.w   #1,d0
 move.w   d0,-(sp)
 move.l   a0,-(sp)
 gemdos   Dgetpath
 addq.l   #2,sp
 move.l   (sp)+,a0
 addq.l   #2,sp
 tst.b    (a0)
 bne.b    dtd_end
 move.b   #'\',(a0)+
 clr.b    (a0)
dtd_end:
 rts


* void label_to_stdout(d0 = int nr)
*  Gibt den Diskettennamen, falls vorhanden, nach stdout
*
label_to_stdout:
 link     a6,#-$30
 lea      croots(pc),a1
 lea      disk_in_lw_s(pc),a0
 lea      strstdout(pc),a1         * a0[] ausdrucken
 bsr      print_with_driveletter

 lea      -$2c(a6),a1              * DTA
 moveq    #8,d0                    * Suchen nach "Volume"
 lea      croots(pc),a0            * "x:\*.*"
 bsr      sfirst

 lea      keinname_s(pc),a0
 bsr      get_country_str
 tst.l    d0
 bne.b    lts_print
 lea      ist_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
 lea      -$e(a6),a0
lts_print:
 bsr      strstdout
 bsr      crlf_stdout
 unlk     a6
 rts



* int is_off_on(a0 = string)
*  RÅckgabe: 1 wenn upper_str(string) = "ON"
*            0                          "OFF"
*           -1                          sonst

is_off_on:
 move.l   a0,-(sp)
 lea      offs(pc),a1    * "OFF"
 bsr      upper_strcmp
 move.l   (sp)+,a0
 beq.b    isoo_end
 lea      ons(pc),a1     * "ON"
 bsr      upper_strcmp
 beq.b    isoo_2
 moveq    #-2,d0
isoo_2:
 addq.w   #1,d0
isoo_end:
 rts


* void prompt_to_con( void )

STRING    SET  -250

prompt_to_con:
 link     a6,#STRING
 movem.l  d7/a5/a4,-(sp)
 lea      STRING(a6),a5
 move.w   #256*CR+LF,(a5)+    * CR,LF
 lea      promptis(pc),a0     * "PROMPT="
 bsr      getenv
 lea      def_prompt(pc),a4
 beq.b    ptc_def             * kein Eintrag im Environment => Default- prompt
 move.l   d0,a4            * a4 zeigt auf Prompteintrag im Environment
ptc_def:
 bra      p_next
p_caseof:
 cmpi.b   #'$',d7
 bne.b    p_d7next
 tst.b    (a4)
 beq.b    p_eos
 move.b   (a4)+,d7                 * Zeichen hinter '$'
 lea      prompt_zeichen(pc),a0    * Beginn der Sprungtabelle
 moveq    #11,d1                   * Anzahl EintrÑge in Tabelle - 1
 clr.l    d0
ptc_srch:
 move.b   (a0)+,d0                 * relative Sprungadresse nach d0
 cmp.b    (a0)+,d7                 * Zeichen gefunden
 dbeq     d1,ptc_srch
 lea      p_t(pc),a0               * Sprungadressen relativ zu p_t
 jmp      0(a0,d0.w)
p_t:
 move.l   a5,a0
 bsr      time_to_str
p_ins_str:
 tst.b    (a5)+
 bne.b    p_ins_str
 subq.l   #1,a5
 bra.b    p_next
p_d:
 move.l   a5,a0
 bsr      date_to_str
 bra.b    p_ins_str
p_p:
 gemdos   Dgetdrv
 addq.l   #2,sp
 move.l   a5,a0
* move.w   d0,d0
 bsr      drive_to_defpath
 bra.b    p_ins_str
p_n:
 gemdos   Dgetdrv
 addq.l   #2,sp
 lea      drive_to_letter(pc),a0
 moveq    #0,d7
 move.b   0(a0,d0.w),d7
 bra.b    p_d7next
p_g:
 moveq    #'>',d7
 bra.b    p_d7next
p_l:
 moveq    #'<',d7
 bra.b    p_d7next
p_b:
 moveq    #'|',d7
 bra.b    p_d7next
p_q:
 moveq    #'=',d7
 bra.b    p_d7next
p_h:
 moveq    #8,d7
 bra.b    p_d7next
p_e:
 moveq    #ESC,d7
 bra.b    p_d7next
p_unterstr:
 move.b   #CR,(a5)+
 moveq    #LF,d7
 bra.b    p_d7next
p_eos:
 moveq    #' ',d7
p_d7next:
 move.b   d7,(a5)+
p_next:
 move.b   (a4)+,d7
 beq.b    ptc_50                     * String- Ende
 lea      STRING+150(a6),a0
 cmpa.l   a5,a0
 bhi      p_caseof
ptc_50:
 clr.b    (a5)
 lea      STRING(a6),a0
 bsr      strcon
 movem.l  (sp)+,a5/a4/d7
 unlk     a6
 rts


* int for_all(a0 = char *inpath, d0 = int patt,
*             a1 = int (*proc)(char *s, DTA *dta))
* Kommt mit Z-Flag zurÅck
*
* Verwendet von ATTRIB, DEL, DIR, TOUCH, TYPE

DTA       SET  -544           * DTA  dta
STRING3   SET  -500           * char string3[200]
STRING1   SET  -300           * char string1[150]
STRING2   SET  -150           * char string2[150]

for_all:
 link     a6,#DTA
 movem.l  d6/d7/a3/a4/a5,-(sp)
 move.l   a0,a3                    * a3 = Pfad
 move.w   d0,d7                    * d7 = Attr
 move.l   a1,d6                    * d6 = proc
 lea      DTA(a6),a4
 lea      STRING3(a6),a5
 move.l   a3,a0
 bsr      str_to_drive
 bmi      forall_end
 lea      STRING1(a6),a2
 lea      STRING2(a6),a1
 move.l   a3,a0
 bsr      split_path
 tst.w    d0
 beq.b    forall_end

 move.l   a4,a1
 move.w   d7,d0
 lea      STRING2(a6),a0
 bsr      sfirst

 beq.b    forall_ok
 clr.w    d0
 bra.b    forall_end
forall_ok:
 lea      STRING1(a6),a1
 move.l   a5,a0
 bsr      strcpy
 lea      $1e(a4),a1
 move.l   a5,a0
 bsr      strcat
 move.l   a5,a0
 bsr      str_upper
 gemdos   Cconis                   ; ^C abfragen
 addq.w   #2,sp
 move.l   a4,-(sp)       * DTA
 move.l   a5,-(sp)       * Dateimuster
 movea.l  d6,a0
 jsr      (a0)
 addq.l   #8,sp
 tst.w    d0
 bne.b    forall_err

 gemdos   Cconis                   ; ^C abfragen
 addq.w   #2,sp

 move.l   a4,a0          * DTA
 bsr      snext
 beq.b    forall_ok

forall_err:
 moveq    #1,d0
forall_end:
 movem.l  (sp)+,d6/d7/a3/a4/a5
 unlk     a6
 tst.w    d0
 rts


STRING    SET   -8

*void print_attr(d0 = char attr)
* Rechnet Attribut in vierstelligen String um (RSHA) und schreibt nach stdout
* Dahinter werden zwei Leerstellen geschrieben

print_attr:
 link     a6,#STRING
 lea      STRING(a6),a0
 move.l   #$20202020,(a0)
 move.l   #$20200000,4(a0)
 btst     #0,d0                    * char attr
 beq.b    pa_1
 move.b   #'R',(a0)
pa_1:
 btst     #1,d0
 beq.b    pa_2
 move.b   #'H',1(a0)
pa_2:
 btst     #2,d0
 beq.b    pa_3
 move.b   #'S',2(a0)
pa_3:
 btst     #5,d0
 beq.b    pa_4
 move.b   #'A',3(a0)
pa_4:
 bsr      strstdout
 unlk     a6
 rts

	INCLUDE "intern\attrib.s"

	INCLUDE "intern\cd.s"

	INCLUDE "intern\tr_fr_ck.s"


*
* void print_free(a0 = long *dfree_buffer, d0 = output_width)
*  Druckt die Grîûe des freien Diskettenplatzes
*  mit Ausgabebreite <outp_len>
*
* Wird benutzt von DIR, CK, TREE und FREE.
*

print_free:
 move.l   12(a0),d0                     * Sektoren/Cluster
 move.l   8(a0),d1                      * Bytes/Sektor
 bsr      _ulmul                        * d0 = Bytes/Cluster
 cmpi.l	#1024,d0
 bcs.b	prf_1					; Cluster < 1 kB
 lsr.l    #8,d0					; Bytes -> kBytes
 lsr.l    #2,d0
 move.l   (a0),d1                       * Anzahl Cluster
 bsr      _ulmul                        * d0 = kBytes
 bra.b	prf_kb
prf_1:
 move.l   (a0),d1                       * Anzahl Cluster
 bsr      _ulmul                        * d0 = Bytes
 lea      nbytesfreis(pc),a2			; in Bytes?
 cmpi.l	#$100000,d0				* unter 1 MB?
 bcs.b	prf_print					* ja, drucke Bytes
 lsr.l    #8,d0					; Bytes -> kBytes
 lsr.l    #2,d0
prf_kb:
 lea      nkbfree(pc),a2				; in kBbytes
 cmpi.l	#$100000,d0				* unter 1 GB?
 bcs.b	prf_print					* ja, drucke kB
 lsr.l    #8,d0					; kBytes -> MBytes
 lsr.l    #2,d0
 lea      nmbfree(pc),a2				; in MBbytes
prf_print:
 moveq    #10,d1                        * Feld 10 Zeichen breit
 bsr      rwrite_long				; rechtsbÅndig
 move.l	a2,a0					; in B/kB/MB
 bsr      get_country_str
 bsr      strstdout
 rts


	INCLUDE "intern\mv_copy.s"	* MV, COPY

	INCLUDE "intern\tim_dat.s"	* TIME, DATE

	INCLUDE "intern\del.s"		* DEL

	INCLUDE "intern\dir.s"		* DIR

	INCLUDE "intern\pause.s"		* PAUSE

	INCLUDE "intern\echo.s"		* ECHO

	INCLUDE "intern\md_rd.s"		* MD, RD

	INCLUDE "intern\ren.s"		* REN

	INCLUDE "intern\path.s"		* PATH

	INCLUDE "intern\prompt.s"	* PROMPT

	INCLUDE "intern\tch_type.s"	* TOUCH, TYPE

	INCLUDE "intern\ver.s"		* VER

	INCLUDE "intern\brk_verf.s"	* BREAK, VERIFY


* int cmps(a0 = char *string1, a1 = char *string2)

cmps:
 move.b   d+r_flag(pc),d0 * reverse_flag ?
 beq.b    cmps_1
 exg.l    a0,a1
cmps_1:
 moveq    #1,d0
 move.w   d+schluessel(pc),d1
 beq.b    cpms_6
 subq.w   #1,d1
cmps_3:
 tst.b    (a0)
 beq.b    cpms_6
 addq.l   #1,a0
 tst.b    (a1)+
 beq.b    cpms_end           * '1' zurÅckgeben, da string1 lÑnger ist
 dbra     d1,cmps_3
cpms_6:
 lea      upper_strcmp(pc),a2
 move.b   d+c_flag(pc),d0         * cases_flag
 beq.b    cmps_4
 lea      strcmp(pc),a2
cmps_4:
 jsr      (a2)
cpms_end:
 rts


* void shellsort(vergleich, anzahl, pointerfeld)
* int (*vergleich)(a0 = void *s1, a1 = void *s2);
* unsigned long anzahl;
* char *pointerfeld[];
*  Sortiert mit Shellsort
*
* Verwendet von DIR und SORT

shellsort:
 link     a6,#0
 movem.l  d5/d6/d7/a5/a4,-(sp)
 move.l   $c(a6),d7
 bra.b    sor_7
sor_1:
 move.l   d7,d6
 bra.b    sor_6
sor_2:
 move.l   d6,d5
 sub.l    d7,d5
 bra.b    sor_4
sor_3:
 movea.l  $10(a6),a5
 movea.l  a5,a4
 move.l   d5,d0
 add.l    d7,d0
 lsl.l    #2,d0
 adda.l   d0,a5
 move.l   (a5),a1             * pointerfeld[d5+d7]
 move.l   d5,d0
 lsl.l    #2,d0
 adda.l   d0,a4
 move.l   (a4),a0             * pointerfeld[d5]
 move.l   8(a6),a2
 jsr      (a2)                * Vergleichsfunktion
 tst.w    d0
 ble.b    sor_5
 move.l   (a5),a0
 move.l   (a4),(a5)
 move.l   a0,(a4)             * vertausche Pointer
 sub.l    d7,d5
sor_4:
 tst.l    d5
 bge.b    sor_3
sor_5:
 addq.l   #1,d6
sor_6:
 cmp.l    $c(a6),d6
 bcs.b    sor_2
sor_7:
 lsr.l    #1,d7         * kÅrzer fÅr "/2"
 bne      sor_1
 movem.l  (sp)+,a4/a5/d7/d6/d5
 unlk     a6
 rts

	INCLUDE "intern\sort.s"


* int content(a0 = char *string1, a1 = char *string2)
*  Stellt fest, ob <string1> als Teilstring in <string2> enthalten ist.
*  Dabei werden Klein- in Groûbuchstaben umgewandelt

STRING    SET  -200

content:
 link     a6,#STRING
 movem.l  d7/a4/a5,-(sp)
 lea      STRING(a6),a4
 movea.l  a0,a5
* move.l   a1,a1
 move.l   a4,a0
 bsr      strcpy
 move.l   a4,a0
 bsr      str_upper
 move.l   a5,a0
 bsr      str_upper
 move.l   a5,a0
 bsr      strlen
 move.w   d0,d7
cnt_1:
 move.b   (a5),d0
 move.l   a4,a0
 bsr      chrsrch
 beq.b    cnt_end           * nicht gefunden
 movea.l  d0,a4
 move.w   d7,d0
 move.l   a4,a1
 move.l   a5,a0
 bsr      strncmp
 addq.l   #1,a4
 bne.b    cnt_1
 moveq    #1,d0          * d0 = 0, also String gefunden
cnt_end:
 movem.l  (sp)+,a5/a4/d7
 unlk     a6
 rts

	INCLUDE "intern\find.s"

	INCLUDE "intern\more.s"


* void cat_strings(a0 = char zielstring[],
*                  d0 = int anzahl, a1 = char *feld[anzahl])
*  Verkettet die Strings in <feld[]>, durch Leerzeichen getrennt, nach
*  <zielstring>, beginnend ab <feld[1]>. Wird mit ' ' auch abgeschlossen.
*
* Verwendet von IF und externen Kommandos

cat_1:
 move.l   (a1),a2
cat_11:
 move.b   (a2)+,(a0)+
 bne.b    cat_11
 move.b   #' ',-1(a0)
cat_strings:
 addq.l   #4,a1
 subq.w   #1,d0
 bgt.b    cat_1
 clr.b    (a0)
 rts


	INCLUDE "intern\if.s"	* IF

	INCLUDE "intern\shift.s"	* SHIFT

	INCLUDE "intern\goto.s"	* GOTO

	INCLUDE "intern\end.s"	* END

	INCLUDE "intern\for.s"	* FOR



	IFF KAOS				; Wir laufen unter TOS, also weder KAOS noch MagiC
 INCLUDE "input.s"			; TOS hat keinen Zeilen-Editor, wir benutzen deshalb einen eigenen
	ENDC


* int read_str(d0 = int handle, a0 = char *string)
*
*  liest einen mit LF abgeschlossen String ( <= 79 Z.) ein und Åberliest CR.
*  FÅr handle = 0 wird von CON: gelesen.
*  Der eingelesene String wird immer mit '\0' abgeschlossen
*  RÅckgabe = -1, wenn Fehler, sonst 0

read_str:
 movem.l  d6/d7/a5/a4,-(sp)
 move.l   a0,a4
 move.w   d0,d6
 moveq    #126,d7
 tst.w    d0
 bne.b    rs_4

 IFF      KAOS
 move.w   d7,-(sp)
 move.l   a4,-(sp)
 bsr      input                    * Handle = 0  => von stdin lesen
 addq.l   #6,sp
 ENDC
 IF       KAOS
 move.l   a4,a0
 move.w   d7,d1
 moveq    #STDIN,d0
 bsr      read                     * einfach von STDIN lesen
 bsr      fatal
 clr.b    0(a4,d0.w)               * EOS markieren
 ENDC

 bra.b    rs_51                      * return(0)
rs_2:
 move.l   a4,a0                    * Handle != 0 => von Datei lesen
 moveq    #1,d1
 move.w   d6,d0
 bsr      read                     * Ein Byte lesen
 tst.l    d0                       ; Wirklich ein Byte gelesen ?
 bgt.b    rs_ok                    ; ja
 bmi.b    rs_end                   ; Fehler => return(TRUE)
 cmpi.w   #126,d7                  ; schon was gelesen ?
 bne.b    rs_50                    ; ja, String-Ende
 moveq    #1,d0
 bra      rs_end                   ; EOF: return(TRUE)
rs_ok:
 cmpi.b   #CR,(a4)
 beq.b    rs_4
 cmpi.b   #LF,(a4)
 beq.b    rs_50
 addq.l   #1,a4
 subq.w   #1,d7
rs_4:
 tst.w    d7
 bne.b    rs_2
rs_50:
 clr.b    (a4)
rs_51:
 clr.w    d0
rs_end:
 movem.l  (sp)+,d6/d7/a5/a4
 rts


* char *intern_com_search(a0 = char *string)
*  Sucht, ob <string> ein internes Kommando ist
*  Liefert Zeiger auf die Funktion oder NULL zurÅck

*    DATA
     EVEN
intern_com_tab:
 DC.W     attrib_s-intern_com_tab,attrib_com-_base
 DC.W     break_s-intern_com_tab,break_com-_base
 DC.W     cd_s-intern_com_tab,cd_com-_base
 DC.W     cls_s-intern_com_tab,cls_com-_base
 DC.W     ck_s-intern_com_tab,ck_com-_base
 DC.W     copy_s-intern_com_tab,copy_com-_base
 DC.W     date_s-intern_com_tab,date_com-_base
 DC.W     del_s-intern_com_tab,del_com-_base
 DC.W     dir_s-intern_com_tab,dir_com-_base
 DC.W     echo_s-intern_com_tab,echo_com-_base
 DC.W     end_s-intern_com_tab,end_com-_base
 DC.W     exit_s-intern_com_tab,restore_etv-_base
 DC.W     find_s-intern_com_tab,find_com-_base
 DC.W     for_s-intern_com_tab,for_com-_base
 DC.W     free_s-intern_com_tab,free_com-_base
 DC.W     goto_s-intern_com_tab,goto_com-_base
 DC.W     if_s-intern_com_tab,if_com-_base
 DC.W     md_s-intern_com_tab,md_com-_base
 DC.W     more_s-intern_com_tab,more_com-_base
 DC.W     mv_s-intern_com_tab,mv_com-_base
 DC.W     path_s-intern_com_tab,path_com-_base
 DC.W     pause_s-intern_com_tab,pause_com-_base
 DC.W     prompt_s-intern_com_tab,prompt_com-_base
 DC.W     ren_s-intern_com_tab,ren_com-_base
 DC.W     rd_s-intern_com_tab,rd_com-_base
 DC.W     set_s-intern_com_tab,set_com-_base
 DC.W     shift_s-intern_com_tab,shift_com-_base
 DC.W     sort_s-intern_com_tab,sort_com-_base
 DC.W     time_s-intern_com_tab,time_com-_base
 DC.W     touch_s-intern_com_tab,touch_com-_base
 DC.W     tree_s-intern_com_tab,tree_com-_base
 DC.W     type_s-intern_com_tab,type_com-_base
 DC.W     ver_s-intern_com_tab,ver_com-_base
 DC.W     verify_s-intern_com_tab,verify_com-_base
 DC.W     0
*    TEXT

intern_com_search:
 lea      intern_com_tab(pc),a2
ics_1:
 lea      intern_com_tab(pc),a1    * Stringadr. sind relativ zu intern_com_tab
 add.w    (a2)+,a1
 move.l   a0,-(sp)
 bsr      upper_strcmp
 move.l   (sp)+,a0
 lea      _base(pc),a1             * Sprungadressen sind relativ zu _base
 adda.w   (a2)+,a1
 beq.b    ics_50
 tst.w    (a2)
 bne.b    ics_1
 suba.l   a1,a1
ics_50:
 move.l   a1,d0
 rts


* void sav_errlv()
*  Wird aufgerufen, wenn das interne Kommando den errorlevel nicht
*  lîschen soll

sav_errlv:
 lea      errorlevel(pc),a0
 move     d+errlv2(pc),(a0)
 rts


* void inc_errlv()
*  Erhîht den errorlevel um 1

inc_errlv:
 lea      errorlevel(pc),a0
 addq.w   #1,(a0)
 rts


* void expand_macros(a0 = char *aus_str, a1 = char ein_str[],
*                   d0 = int anzpar, a2 = char *par[anzpar])
*
*  ein_str wird unter Expansion nach aus_str kopiert
*  Es werden nur die Parameter %n und %var% eingesetzt

expand_macros:
 movem.l  d4/d6/d7/a3/a4/a5,-(sp)
 move.l   a1,a3          * Eingabe
 move.l   a0,a4          * Ausgabe
 move.l   a2,a5
 move.w   d0,d7          * anz_parameter
 clr.w    d6
 clr.w    d4             * nicht innerhalb eines '....'
 bra      exm_14
exm_1:
 move.b   (a3)+,d0
 cmpi.b   #$27,d0        * '
 beq.b    exm_30
 cmpi.b   #$22,d0        * "
 bne.b    exm_40
exm_30:
 cmp.b    d0,d4          * Abschlieûendes Pendant ?
 beq.b    exm_39
 tst.b    d4             * innerhalb eines "..." oder '...'
 bne.b    exm_40            * ja => normal weiter
 move.b   d0,d4          * noch nicht => Anfangszeichen merken
 bra.b    exm_40
exm_39:
 clr.w    d4
exm_40:
 cmpi.b   #$27,d4        * innerhalb eines '...'
 beq      exm_13            * ja => nicht interpretieren
 cmpi.b   #'%',d0
 bne      exm_13            * Kein Sonderzeichen => einfach kopieren
 cmpi.b   #'0',(a3)
 blt.b    exm_5
 cmpi.b   #'9',(a3)
 bgt.b    exm_5

* %1 bis %9

 move.b   (a3)+,d0       * Zeichen war Parameter %1 .. %9
 ext.w    d0
 subi.w   #'0',d0
 cmp.w    d7,d0
 bcc.b    exm_4             * Zuwenige Parameter
 add.w    d0,d0
 add.w    d0,d0
 movea.l  0(a5,d0.w),a2  * a2[] ist der einzusetzende Parameter
 bra.b    exm_3
exm_2:
 move.b   (a2)+,(a4)+    * setze Parameter ein
 addq.w   #1,d6
exm_3:
 cmpi.w   #$7f,d6
 bge.b    exm_4
 tst.b    (a2)
 bne.b    exm_2
exm_4:
 bra.b    exm_14
exm_5:
 move.b   (a3)+,d0
 cmpi.b   #'%',d0
 beq.b    exm_13            * "%%" in "%" expandieren
 cmpi.b   #'\',d0
 bne.b    exm_21

* %\

 cmpi.b   #'%',1(a3)
 bne.b    exm_21

* %\?%

 moveq    #LF,d0
 cmpi.b   #'n',(a3)
 beq.b    exm_22
 moveq    #CR,d0
 cmpi.b   #'r',(a3)
 beq.b    exm_22
 moveq    #TAB,d0
 cmpi.b   #'t',(a3)
 beq.b    exm_22
 moveq    #8,d0
 cmpi.b   #'b',(a3)
 beq.b    exm_22
 moveq    #'?',d0
exm_22:
 addq.l   #2,a3
 bra.b    exm_13

* %env_var%

exm_21:
 subq.l   #1,a3          * Jetzt kommt ein Ausdruch wie "%var%"
 movea.l  a3,a0          * Wenn var geSETtet ist, expandieren
exm_20:
 tst.b    (a3)
 beq.b    exm_15            * Ende der Zeile, kein rechtes '%' gefunden
 cmpi.b   #'%',(a3)+
 bne.b    exm_20
 move.b   #'=',-1(a3)    * a3 zeigt aufs Zeilenende oder auf '%'
 move.b   (a3),d0        * Zeichen retten
 move.w   d0,-(sp)
 clr.b    (a3)           * Ende des Parameters festsetzen
* move.l   a0,a0
 bsr      getenv
 move.w   (sp)+,d1
 move.b   d1,(a3)        * Zeichen wieder einsetzen
 movea.l  d0,a2
 move.l   a2,d0
 beq.b    exm_12
 bra.b    exm_11
exm_10:
 move.b   (a2)+,(a4)+
 addq.w   #1,d6
exm_11:
 cmpi.w   #$7f,d6
 bge.b    exm_12
 tst.b    (a2)
 bne.b    exm_10
exm_12:
 bra.b    exm_14
exm_13:
 move.b   d0,(a4)+       * Ohne Expansion einfach kopieren
 addq.w   #1,d6
exm_14:
 cmpi.w   #$7f,d6        * Aufhîren bei 128 Zeichen oder Ende der Zeichenkette
 bge.b    exm_15
 tst.b    (a3)
 bne      exm_1
exm_15:
 cmpi.w   #$7f,d6
 blt.b    exm_16
 lea      zeile_gekuerzt_s(pc),a0
 bsr      get_country_str
 bsr      strcon
exm_16:
 clr.b    (a4)
 movem.l  (sp)+,a5/a4/a3/d7/d6/d4
 rts


* void restore_stdx(a0 = int handles[6*2])
*  Restauriert sÑmtliche Standard- Handles 0..5

restore_stdx:
 movem.l  a5/d7,-(sp)
 movea.l  a0,a5
 clr.w    d7                       * erstes Handle: 0 = STDIN
rstd_1:
 move.w   2(a5),d0
 cmp.w    (a5),d0
 beq.b    rstd_2             * altes und neues Handle identisch
 move.w   d0,-(sp)
 move.w   d7,-(sp)
 gemdos   Fforce         * stdxx auf alte Datei umlenken
 addq.l   #6,sp
rstd_2:
 move.w   (a5),d0
 bsr      close          * feld2[0] schlieûen
 move.w   2(a5),d0
 bsr      close          * feld2[1] schlieûen
 moveq    #-2,d0
 cmpi.w   #2,d7
 beq.b    rstd_3             * STDAUX : -2
 moveq    #-3,d0
 cmpi.w   #3,d7
 beq.b    rstd_3             * STDPRN : -3
 moveq    #-1,d0         * sonst  : -1
rstd_3:
 move.l   d0,(a5)+       * feld[0]=feld[1] = Default setzen
 addq.w   #1,d7
 cmpi.w   #6,d7
 bcs.b    rstd_1
 movem.l  (sp)+,a5/d7
 rts


* int redirect_stdx(d0 = int stdhdl, a0 = int feld[2*6],
*                   a1 = char dateiname[], d1 = int flag)
*
* char *dateiname;
*  Falls stdhdl <=1, mÅssen feld[stdhdl] und feld[stdhdl+1] -1 sein,
*   sonst "pipe error"
*  Lenkt STDX nach <dateiname> um. Das alte Handle wird in
*  feld[stdhdl+1], das neue in feld[stdhdl] gespeichert.
*  Wenn Flag == TRUE, wird die Datei <dateiname> am Dateiende zum
*  Schreiben geîffnet (falls vorhanden), andernfalls gleich create()
*  RÅckgabewert 1, falls ok; sonst 0

redirect_stdx:
 movem.l  d5/d6/d7/a5,-(sp)
 move.w   d0,d5
 move.l   a0,a5
 lsl.w    #2,d0                    * mal 2 fÅr Doppelwortzugriff
 add.w    d0,a5                    * a0 auf zug. Tabelle
 moveq    #-1,d7
 moveq    #-1,d6
 cmpi.w   #1,d5
 bhi.b    rx_2
 lea      pipe_errs(pc),a0
 bsr      get_country_str
 cmp.l    (a5),d7
 bne.b    rx_15
rx_2:
 tst.w    d5
 beq.b    rx_3
 tst.w    d1
 beq.b    rx_3             * create() statt anhÑngen
 moveq    #2,d0          * zum Lesen UND Schreiben îffnen
 move.l   a1,a0
 move.l   a1,-(sp)
 bsr      open
 move.l   (sp)+,a1
 move.l   d0,d6
 ble.b    rx_3             * Datei existiert nicht => create
 move.w   #2,-(sp)
 move.w   d6,-(sp)
 clr.l    -(sp)
 gemdos   Fseek          * Dateipointer ans Dateiende
 adda.w   #$a,sp
 bra.b    rx_4
rx_3:
 clr.w    d0
 move.l   a1,a0
 moveq    #Fopen,d1
 tst.w    d5
 beq.b    rx_10
 moveq    #Fcreate,d1
rx_10:
 bsr      op_cr
 move.l   d0,d6
 ble.b    rx_5
rx_4:
 move.w   d5,-(sp)
 gemdos   Fdup           * Hole Handle fÅr STDX
 addq.l   #4,sp
 move.l   d0,d7
 ble.b    rx_5
 bsr      merke_hdl
 move.w   d6,-(sp)
 move.w   d5,-(sp)
 gemdos   Fforce         * lenke STDX nach d6
 addq.l   #6,sp
 move.w   d6,(a5)+       * neues Handle
 move.w   d7,(a5)        * altes Handle
 moveq    #1,d0
 bra.b    rx_end
rx_5:
 lea      redir_errs(pc),a0
 bsr      get_country_str
 bsr      strcon
 lea      stdx_namtab(pc),a0
 mulu.w   #4,d5
 add.w    d5,a0
rx_15:
 bsr      strcon
 bsr      crlf_con
 tst.l    d6
 ble.b    rx_50
 move.w   d6,d0
 bsr      close
rx_50:
 bsr      inc_errlv
 clr.w    d0
rx_end:
 movem.l  (sp)+,d5/d7/d6/a5
 rts


* void cmd_exec(string)
*  FÅhrt ein Kommando aus. Ist String = NULL, wird ein Befehl
*  von der Konsole geholt.

EINGABE   SET   -130
ANZPAR    SET   EINGABE-2
PAR       SET   ANZPAR-4

cmd_exec:
 link     a6,#PAR
 tst.l    8(a6)
 bne.b    cmde_1
 lea      for_flag(pc),a0
 clr.w    (a0)
 bsr      prompt_to_con
 lea      EINGABE(a6),a0
 clr.w    d0
 bsr      read_str
 lea      EINGABE(a6),a0
 move.l   a0,8(a6)
 bsr      crlf_con
cmde_1:
 clr.w    ANZPAR(a6)          * Kein Parameter %1..%9
 pea      PAR(a6)             * Zeiger auf Parameter
 pea      ANZPAR(a6)          * Zeiger auf Anzahl Parameter
 move.l   8(a6),-(sp)         * Kommando
 clr.w    -(sp)               * Batch-Flag = 0
 bsr      cmdline_exec
 adda.w   #$e,sp
 unlk     a6
 rts


* void batch_exec(handle,anzahl_param,parameter)
* int  handle;
* int  anzahl_param;
* char *parameter[];

batch_exec:
 link     a6,#-130
 move.l   a5,-(sp)
 lea      batchlevel(pc),a5
 addq.w   #1,(a5)
 cmpi.w   #4,(a5)
 ble.b    bate_6
 lea      batch_errs(pc),a0   * "BATCH zu tief verschachtelt"
 bsr      get_country_str
 bsr      strcon
 bra      break
bate_1:
 bsr      search_ctrl_c       * Tastaturpuffer nach CTRL-C durchsuchen
 pea      $c(a6)
 pea      $a(a6)
 pea      -130(a6)
 move.w   8(a6),-(sp)
 bsr      cmdline_exec        * Kommando ausfÅhren
 adda.w   #$e,sp
 bsr      search_ctrl_c       * Tastaturpuffer nach CTRL-C durchsuchen
bate_6:
 lea      -130(a6),a0
 move.w   8(a6),d0
 bsr      read_str            * Kommandozeile von Handle 8(a6) holen
 tst.w    d0
 beq.b    bate_1
 move.w   8(a6),d0
 bsr      close
 tst.w    (a5)
 beq.b    bate_end
 subq.w   #1,(a5)
bate_end:
 move.l   (sp)+,a5
 unlk     a6
 rts


* void search_ctrl_c()
*  PrÅft, ob CTRL-C im Tastaturpuffer steht.
*  Wenn ja, wird alles abgebrochen

search_ctrl_c:
 move.w   #1,-(sp)       * Pufferdatensatz fÅr Tastatur holen
 xbios    Iorec
 addq.l   #4,sp
 move.l   d0,a0          * Adresse des Puffer- Datensatzes
 move.w   $6(a0),d1      * Head- Index
 move.w   $8(a0),d0      * Tail- Index
 cmp.w    d0,d1
 beq.b    scc_end           * Head = Tail => Puffer leer
 move.l   (a0),a1        * Puffer- Adresse
scc_1:
 addq.w   #4,d1
 cmp.w    $4(a0),d1      * LÑnge des Puffers Åberschritten ?
 bcs.b    scc_3
 moveq    #0,d1          * Zeiger wieder auf Pufferanfang setzen
scc_3:
 cmpi.w   #3,2(a1,d1.w)  * Nur ASCII- Code nach CTRL-C abfragen
 bne.b    scc_2
 bra      break          * Brutal alles abbrechen
scc_2:
 cmp.w    d1,d0          * Alles durchgecheckt ?
 bne.b    scc_1
scc_end:
 rts


* void cmdline_exec(batch_hdl, command, pointer_to_anz_par, pointer_to_parameter)
* int  batch_hdl;
* char *command;
* int  *pointer_to_anz_par;
* char **pointer_to_parameter[*pointer_to_anz_par];


BATCH_HDL      SET  8
COMMAND        SET  $a
P_ANZPAR       SET  $e
PP_PAR         SET  $12
ARGV_TAB       SET  -$50      * char *par_tab[20]
EXPAND_BUF     SET  -$d0      * char expand_buf[128]
STDX_TAB       SET  -$e8      * int  stdx_tab[6*2]
PIPEOUT_FLAG   SET  -$e9      * char pipeout_flag
PIPEIN_FLAG    SET  -$ea      * char pipein_flag


cmdline_exec:
 link     a6,#PIPEIN_FLAG
 movem.l  d3/d4/d5/d6/d7/a3/a4/a5,-(sp)
 lea      _base+$80(pc),a3    * Puffer fÅr Pipedatei- Namen

* Tabelle der Default- Standarddateien initialisieren

 moveq    #-1,d0
 lea      STDX_TAB(a6),a0
 move.l   d0,(a0)+            * STDIN  = CON:
 move.l   d0,(a0)+            * STDOUT = CON:
 clr.l    (a0)
 subq.l   #2,(a0)+            * STDAUX
 clr.l    (a0)
 subq.l   #3,(a0)+            * STDPRN
 move.l   d0,(a0)+            * STDERR
 move.l   d0,(a0)+            * STDXTRA
 clr.w    PIPEIN_FLAG(a6)     * PIPEIN_FLAG und PIPEOUT_FLAG lîschen

* Kommandozeile expandieren

 movea.l  PP_PAR(a6),a0
 move.l   (a0),a2                  * Parameter- Feld
 movea.l  P_ANZPAR(a6),a0
 move.w   (a0),d0                  * Anzahl der Parameter
 move.l   COMMAND(a6),a1           * Zu expandierende Kommandozeile
 lea      EXPAND_BUF(a6),a0        * FÅr Ergebnis der Expansion
 bsr      expand_macros            * z.B. %1 und %PATH% ggf. expandieren
 lea      EXPAND_BUF(a6),a0
 move.l   a0,COMMAND(a6)      * COMMAND(a6)[] ist jetzt expandierte Zeile

* ggf. im Batchbetrieb Prompt und Kommandozeile echoen

 tst.w    BATCH_HDL(a6)
 beq.b    cle_2
 move.b   is_echo(pc),d0
 beq.b    cle_2
 bsr      prompt_to_con       * Prompt und Kommandozeile ECHOen
 move.l   COMMAND(a6),a0
 bsr      strcon
 bsr      crlf_con

* argv[][] und argc initialisieren

cle_2:
 movea.l  COMMAND(a6),a5
 clr.l    COMMAND(a6)
 lea      ARGV_TAB(a6),a0          * Parameter- Tabelle
 moveq    #20-1,d0                 * Tabelle hat 20 EintrÑge
cle_3:
 lea      leers(pc),a1
 move.l   a1,(a0)+                 * EintrÑge mit Zeigern auf Nullstring
 dbra     d0,cle_3                    *  initialisieren

* For d7 = 0..19: Schleife

 clr.w    d7
cle_argloop:
 move.l   a5,a0
 bsr      skip_sep      * Åberspringe Leerzeichen und Tabulatoren
 move.l   d0,a5         * a5 auf erstes Nicht-Trenn-Zeichen

* Test auf Ende der Kommandozeile

 tst.b    (a5)
 beq      cle_argloop_end                      * Zeilenende

* Test auf Pipe- Zeichen

 cmpi.b   #'|',(a5)
 bne.b    cle_no_pipe
 addq.l   #1,a5
 move.l   a5,a0
 bsr      skip_sep
 move.l   d0,COMMAND(a6)           * COMMAND(a6) auf nÑchstes Kommando der Pipe

* STDOUT auf temporÑre Datei lenken und Flags setzen

 st.b     PIPEOUT_FLAG(a6)
 moveq    #1,d0
 move.l   a3,a0                    * Name fÅr PIPExx.OUT
 bsr      make_pipename
 clr.w    d1                       * Datei erstellen
 move.l   a3,a1
 lea      STDX_TAB(a6),a0
 moveq    #1,d0                    * STDOUT
 bsr      redirect_stdx
 tst.w    d0
 bne.b    cle_pipe_ok                       * Ok
 clr.w    d7                        * argc lîschen
 clr.l    COMMAND(a6)              * Kommandozeile, lîschen, weil Fehler
cle_pipe_ok:
 bra      cle_argloop_end

* Test auf Standarddatei- Umlenkung

cle_no_pipe:
 cmpi.b   #'>',1(a5)               * Test auf "0>" bis "5>"
 bne.b    cle_no_redir_stdnout
 move.b   (a5),d5
 sub.b    #'0',d5
 bcs.b    cle_no_redir_stdnout
 cmpi.b   #5,d5
 bhi.b    cle_no_redir_stdnout
 addq.l   #1,a5
 bra.b    cle_redir
cle_no_redir_stdnout:
 moveq    #1,d5                    * d5 = STDOUT
 cmpi.b   #'>',(a5)
 beq.b    cle_redir
 cmpi.b   #'<',(a5)
 bne.b    cle_no_redirect
 clr.w    d5                       * d5 = STDIN

* Standard-Kanal d5 (0..5) wird umgelenkt

cle_redir:
 addq.l   #1,a5
 clr.w    d4
 tst.w    d5                * stdin?
 beq.b    cle_12            * ja
 cmpi.b   #'>',(a5)           * STDOUT mit ">>" an Datei anhÑngen
 bne.b    cle_12
 moveq    #1,d4
 addq.l   #1,a5
cle_12:
 move.l   a5,a0
 bsr      skip_sep
 move.l   d0,a5
 movea.l  a5,a4
 move.l   a5,a0
 bsr      search_sep
 move.l   d0,a5
 move.b   (a5),d3
 clr.b    (a5)
 tst.b    (a4)
 beq.b    cle_redir_ok
 move.w   d4,d1                    * Flag fÅr create/append
 move.l   a4,a1
 lea      STDX_TAB(a6),a0
 move.w   d5,d0                    * STD- Handle
 bsr      redirect_stdx
 tst.w    d0
 bne.b    cle_redir_ok
 clr.w    d7                    * Fehler
 clr.l    COMMAND(a6)
 bra.b    cle_argloop_end
cle_redir_ok:
 move.b   d3,(a5)
 bra.b    cle_argloop_continue

* Keine Umlenkung. a5 zeigt auf den gerade bearbeiteten Parameter

cle_no_redirect:
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   a0,a0
 move.l   a5,ARGV_TAB(a6,a0.l)     * Parameter eintragen
 addq.w   #1,d7                     * argc++
cle_cont_arg:
 cmpi.b   #$27,(a5)   * '
 beq.b    cle_param_quoted
 cmpi.b   #$22,(a5)   * "
 bne.b    cle_param_unquoted

* Ein Abschnitt beginnt mit " oder '
cle_param_quoted:
 move.b   (a5),d3           * d3 ist das Quote-Zeichen " oder '
 move.l   a5,a0             * destination for copy loop
* Schleife fÅrs Suchen nach dem korrespondierenden Abschluû, " oder '
cle_loop_endquote:
 addq.l   #1,a5
 move.b   (a5),d0
 move.b   d0,(a0)+
 bne.b    cle_q1
 subq.l   #1,a0
 move.l   a0,a5
 bra.b    cle_argloop_continue            * Zeilenende kommt vor dem abschlieûenden Quote
cle_q1:
 cmp.b    (a5),d3           * Quote passend?
 bne.b    cle_loop_endquote   * weiter nach passendem Quote suchen
 subq.l   #1,a0
* end quote gefunden. a0 zeigt auf Ziel fÅr den Rest der Zeile, a5 auf das end quote
* kopiere ab a5+1 nach a0, bis Ende
 move.l   a5,a1
 move.l   a0,a5             * hier geht's nachher weiter
cle_q3:
 addq.l   #1,a1
 move.b   (a1),d0
 move.b   d0,(a0)+
 bne      cle_q3
 ; Es kînnten weitere Abschnitte ".." oder '..'kommen
 bra      cle_cont_arg

* Der Parameter beginnt weder mit " noch '
cle_param_unquoted:
 * wir kopieren bis Separator oder quote
 move.b   (a5),d0
 beq.b    cle_argloop_end
 cmpi.b   #$27,d0   * '
 beq.b    cle_param_quoted
 cmpi.b   #$22,d0   * "
 beq.b    cle_param_quoted
 cmpi.b   #' ',d0       * separator
 beq.b    cle_argloop_continue
 cmpi.b   #TAB,d0       * separator
 beq.b    cle_argloop_continue
 addq.l   #1,a5
 bra.b cle_param_unquoted
* a5 zeigt direkt hinter das derzeitige argv, also auf Separator oder NUL
cle_argloop_continue:
 move.b   (a5),d3
 clr.b    (a5)+
 tst.b    d3
 beq.b    cle_argloop_end
 cmpi.w   #20,d7
 blt      cle_argloop     * Schleife fÅr d7 = 0..19 (20 argv)

* Ende der ARGV-Schleife

cle_argloop_end:
 tst.w    d7
 ble.b    cle_27
 movea.l  ARGV_TAB(a6),a5
 cmpi.b   #':',(a5)           * Kommandozeile beginnt mit ':' (Label)
 beq.b    cle_27
 cmpi.b   #':',1(a5)          * Kommando beginnt mit Laufwerksangabe
 bne.b    cle_25
 move.l   a5,a0
 bsr      isdrive
 tst.w    d0                  * Laufwerkscode ?
 bmi.b    cle_27                 * Fehler => cle_27
 tst.b    2(a5)               * Kommandozeile nur 2 Zeichen ?
 bne.b    cle_25
 move.w   d0,-(sp)
 gemdos   Dsetdrv             * Kommando war "X:"
 addq.l   #4,sp
 bra.b    cle_27
cle_25:
 lea      errorlevel(pc),a0
 lea      d+errlv2(pc),a1
 move.w   (a0),(a1)           * alten Wert von errorlevel retten
 clr.w    (a0)                * errorlevel lîschen
 move.l   a5,a0
 bsr      intern_com_search
 tst.l    d0                  * d0 ist Zeiger auf Funktion, wenn gefunden
 beq.b    cle_26
 move.w   BATCH_HDL(a6),-(sp)
 move.l   PP_PAR(a6),-(sp)
 move.l   P_ANZPAR(a6),-(sp)
 pea      ARGV_TAB(a6)             * argv
 move.w   d7,-(sp)                 * argc
 movea.l  d0,a0
 jsr      (a0)                     * Internes Kommando ausfÅhren
 adda.w   #$10,sp
 bra.b    cle_27
cle_26:
 lea      ARGV_TAB(a6),a0          * argv[]
 move.w   d7,d0                    * argc
 bsr      extern_cmd_exec          * Externes Kommando ausfÅhren
cle_27:
 lea      STDX_TAB(a6),a0
 bsr      restore_stdx
 clr.w    d0
 move.l   a3,a0
 bsr      make_pipename
 tst.b    PIPEIN_FLAG(a6)
 beq.b    cle_28
 move.l   a3,-(sp)
 gemdos   Fdelete
 addq.l   #6,sp
cle_28:
 clr.b    PIPEIN_FLAG(a6)
 tst.b    PIPEOUT_FLAG(a6)
 beq.b    cle_30
* temporÑre Eingabedatei lîschen
 clr.w    d0
 move.l   a3,a0
 bsr      make_pipename
 move.l   a3,-(sp)
 gemdos   Fdelete
 addq.l   #6,sp
* temporÑre Ausgabedatei in Eingabedatei umbenennen
 suba.w   #200,sp
 moveq    #1,d0
 lea      4(sp),a0
 bsr      make_pipename
 move.l   a3,(sp)
 pea      4(sp)
 clr.w    -(sp)
 gemdos   Frename
 adda.w   #8+200,sp
* Eingabe auf temporÑre Datei umlenken
 move.l   a3,a1
 lea      STDX_TAB(a6),a0
 moveq    #0,d0                    * STDIN
 bsr      redirect_stdx
 tst.w    d0
 bne.b    cle_29
 clr.l    COMMAND(a6)
cle_29:
 clr.b    PIPEOUT_FLAG(a6)
 st.b     PIPEIN_FLAG(a6)
cle_30:
 tst.l    COMMAND(a6)
 bne      cle_2
 clr.w    d0
 move.l   a3,a0
 bsr      make_pipename
 tst.b    PIPEIN_FLAG(a6)
 beq.b    cle_end
 move.l   a3,-(sp)
 gemdos   Fdelete
 addq.l   #6,sp
cle_end:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts


* load_exec_pgm(a0 = char filename[], a1 = char commandline[])

load_exec_pgm:
 movem.l  d7/a3/a4/a5,-(sp)
 move.l   a0,a5                    * Kommando
 move.l   a0,a3
 move.l   a1,a4                    * Kommandozeile
* Pfad Åberspringen
lep_5:
 moveq    #'\',d0
 move.l   a5,a0
 bsr      chrsrch
 beq.b    lep_4
 move.l   d0,a5
 addq.l   #1,a5
 bra.b    lep_5
* Extension isolieren
lep_4:
 moveq    #'.',d0
 move.l   a5,a0
 bsr      chrsrch
 beq.b    lep_1
 move.l   d0,a5
 move.l   a5,a1
 lea      acc_s(pc),a0
 bsr      upper_strcmp             ; .ACC => mit GEM
 beq.b    lep_2
 move.l   a5,a1
 lea      prg_s(pc),a0             ; .PRG => mit GEM
 bsr      upper_strcmp
 beq.b    lep_2
 move.l   a5,a1
 lea      app_s(pc),a0             ; .APP => mit GEM
 bsr      upper_strcmp
 bne.b    lep_1
lep_2:
 bsr      mouse                * GEM- Programme (*.app, *.prg) mit Maus
     IFEQ MAGIX
 move.l   d+etvcritic_alt(pc),-(sp)  * Diskettenfehler vom Desktop korrigieren
 bra.b    lep_3                   *  lassen (per Alert- Box)
     ENDC
lep_1:
     IFEQ MAGIX
 pea      etv_critic_neu(pc)
     ENDC
lep_3:
     IFEQ MAGIX
 move.w   #$101,-(sp)
 bios     Setexc
 addq.l   #8,sp
     ENDC

 move.l   etv_term_neu-4(pc),-(sp)
 move.w   #$102,-(sp)
 bios     Setexc
 addq.l   #8,sp
 clr.l    -(sp)               * Environment des cmd
 move.l   a4,-(sp)            * Kommandozeile
 move.l   a3,-(sp)            * Dateiname
 clr.w    -(sp)               * Laden und ausfÅhren
 gemdos   Pexec
 adda.w   #$10,sp
 move.w   d0,d7
 lea      errorlevel(pc),a0
 move.w   d0,(a0)
     IFEQ MAGIX
 pea      etv_critic_neu(pc)
 move.w   #$101,-(sp)
 bios     Setexc
 addq.l   #8,sp
     ENDC
 pea      etv_term_neu(pc)
 move.w   #$102,-(sp)
 bios     Setexc
 addq.l   #8,sp
 bsr      cursor
 tst.w    d7
 bge.b    lep_end
 cmpi.w   #EBREAK,d7
 beq      break
 lea      exec_fehler1_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 move.w   d7,d0
 bsr      print_err
 lea      exec_fehler2_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 cmpi.w   #EXCPT,d7
 beq      break
lep_end:
 movem.l  (sp)+,d7/a5/a4/a3
 rts


* int check_pgm_type(a0 = char dateiname[], a1 = int *handle_pointer)
*  RÅckgabe:        0  = Fehler
*                   1  = ok
*  *handlepointer   0  = normale Programmdatei
*                sonst = Handle der Batchdatei

check_pgm_type:
 movem.l  d7/a6/a5/a4/a3,-(sp)
 move.l   a0,a5
 move.l   a1,a6
 lea      pgm_typ_tab(pc),a3
* <dateiname> (ohne Pfad!!) von hinten nach '.' durchsuchen
* a4 := Zeiger auf '.', sonst => cpty_1
 move.l   a5,a4
cpty_20:
 tst.b    (a4)+
 bne.b    cpty_20
cpty_21:
 cmpa.l   a5,a4
 bls.b    cpty_1              ; ganzen String durchsucht ?
 move.b   -(a4),d0
 cmpi.b   #'\',d0             ; schon beim Pfad angekommen, kein '.'
 beq.b    cpty_1
 cmpi.b   #':',d0             ; dito
 beq.b    cpty_1
 cmpi.b   #'.',d0             ; '.' gefunden!
 bne.b    cpty_21
 clr.w    d0
 move.l   a5,a0
 bsr      open
 tst.l    d0
 blt.b    cpty_5              ; Fehler
 bra.b    cpty_4
cpty_1:
 move.l   a5,a4
cpty_2:
 tst.b    (a4)+
 bne.b    cpty_2
 subq.l   #1,a4               ; a4 auf Ende des Dateinamens

	IFF ACC
 moveq    #ANZ_SUFFIX-1,d7
	ENDC
	IF ACC
 moveq    #ANZ_SUFFIX-2-1,d7  ; im ACC nicht nach APP/PRG suchen
	ENDC

cpty_3:
 move.l   a3,a1
 addq.l   #5,a3
 move.l   a4,a0           * Extension anhÑngen
 bsr      strcpy
 clr.w    d0
 move.l   a5,a0
 bsr      open
 tst.l    d0
 bgt.b    cpty_4
 dbra     d7,cpty_3
cpty_5:
 clr.w    d0                  * nicht gefunden (error)
 bra.b    cpty_end
cpty_4:
 move.w   d0,d7               * Handle nach d7
 lea      bat_s(pc),a1        * ".BAT"
 move.l   a4,a0
 bsr      upper_strcmp
 beq.b    cpty_11             * war Batch- Datei
 lea      btp_s(pc),a1        * ".BTP"
 move.l   a4,a0
 bsr      upper_strcmp
 beq.b    cpty_11             * war Batch- Datei


* Bei Programmen wird die Datei geschlossen

 move.w   d7,d0
 bsr      close
 clr.w    d7                       * Null zurÅckgeben => Programm

* Bei Batchdateien wird das Handle zurÅckgegeben

cpty_11:
 move.w   d7,(a6)                  * Handle zurÅckgeben => Batch
 moveq    #1,d0                    * kein Fehler
cpty_end:
 movem.l  (sp)+,a6/a5/a4/a3/d7
 rts


* void extern_cmd_exec(d0 = int argc, a0 = char *argv[])

parameter_len   EQU      _base+$80
parameter       EQU      _base+$80+1
pfadpuffer      EQU      _base+$80+$90

extern_cmd_exec:
 movem.l  d6/d7/a3/a4/a5,-(sp)
 lea      parameter_len(pc),a5
 movea.l  a0,a4               * argv
 move.w   d0,d6
 clr.b    (a5)+               * StringlÑnge lîschen
 clr.b    (a5)                * String = "" setzen
 move.l   a4,a1
* move.w   d0,d0
 move.l   a5,a0
 bsr      cat_strings
 move.l   a5,a0
 bsr      strlen
 subq.w   #1,d0
 bcs.b    ece_1
 move.b   #CR,0(a5,d0.w) * RechtsbÅndiges ' ' mit CR lîschen
 move.b   d0,-(a5)       * StringlÑnge setzen
ece_1:
 lea      leers(pc),a3             * per Default ist path = ""
 lea      pathis(pc),a0            * "PATH="
 bsr      getenv
 beq.b    ece_3
 move.l   d0,a3
 moveq    #'\',d0
 move.l   (a4),a0
 bsr      chrsrch
 bne.b    ece_13
 moveq    #':',d0
 move.l   (a4),a0
 bsr      chrsrch             ; enthÑlt Programmname '\' oder ':' ?
 beq.b    ece_3
ece_13:
 lea      leers(pc),a3
ece_3:
 movea.l  (a4),a1             * 0ter Parameter = Programmname
 lea      pfadpuffer(pc),a2   * Pfadpuffer ist a2[]
 moveq    #$48,d7
 bra.b    ece_8               * zunÑchst ohne Pfad testen
ece_4:
 movea.l  (a4),a1             * 0ter Parameter = Programmname
 lea      pfadpuffer(pc),a2   * Pfadpuffer ist a2[]
 moveq    #$48,d7
ece_5:
 tst.b    (a3)
 beq.b    ece_6
 cmpi.b   #';',(a3)
 beq.b    ece_6
 cmpi.b   #',',(a3)
 beq.b    ece_6
 subq.w   #1,d7
 bcs.b    ece_11              * Pfad- öberlauf
 move.b   (a3)+,(a2)+         * Pfad holen
 bra.b    ece_5
ece_6:
 cmpi.b   #'\',-1(a2)
 beq.b    ece_7
 move.b   #'\',(a2)+
ece_7:
 tst.b    (a3)
 beq.b    ece_8
 addq.l   #1,a3
ece_8:
 tst.b    (a1)
 beq.b    ece_9
 subq.w   #1,d7
 bcs.b    ece_11              * Pfad- öberlauf
 move.b   (a1)+,(a2)+         * Dateiname anhÑngen
 bra.b    ece_8
ece_9:
 clr.b    (a2)
 subq.l   #2,sp
 lea      (sp),a1             * Platz fÅr Handle
 lea      pfadpuffer(pc),a0   * Pfadpuffer
 bsr      check_pgm_type
 move.w   (sp)+,d1            * ggf. Batch- Handle
 tst.w    d0
 beq.b    ece_12              * nicht gefunden
 tst.w    d1                  * wenn > 0, dann Handle fÅr Batchdatei
 beq.b    ece_10              * Kein Handle
 move.l   a4,-(sp)            * argv
 move.w   d6,-(sp)            * argc
 move.w   d1,-(sp)            * Handle
 bsr      batch_exec
 addq.l   #8,sp
 bra.b    ece_end
ece_10:
 move.l   a5,a1               * Kommandozeile
 lea      pfadpuffer(pc),a0   * Programmname
 bsr      load_exec_pgm
 bra.b    ece_end
ece_11:
 lea      pfad_ueberl_s(pc),a0
 bsr      get_country_str
 bsr      strcon
ece_12:
 tst.b    (a3)
 bne.b    ece_4
 lea      kmd_nicht_gef_s(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
ece_end:
 movem.l  (sp)+,d6/d7/a5/a4/a3
 rts


* void clr_pipes( void )
*
* Lîscht alle temporÑren Dateien

clr_pipename:
 suba.w   #200,sp
 lea      (sp),a0
 moveq    #-1,d0
 bsr.b    make_pipename
clpi_1:
 pea      (sp)
 gemdos   Fdelete             * temporÑre Dateien (fÅr Pipes) lîschen
 addq.l   #6,sp
 tst.l    d0
 beq.b    clpi_1
 adda.w   #200,sp
 rts


* void make_pipename(a0 = char *ziel, d0 = int is_out)
*
* Gibt den Namen auf eine TemporÑrdatei in <ziel> zurÅck.
* Ist im Environment ein entsprechender Eintrag fÅr einen Ordner fÅr
*  TemporÑrdateien vorhanden, wird er genutzt.
*  is_out = 0  :  Eingabedatei pipen.i
*  is_out > 0  :  Ausgabedatei pipen.o
*  is_out < 0  :  global       pipe?.?

make_pipename:
 move.l   a5,-(sp)
 move.l   a0,a5
* Name nach Ein-/Ausgabe und Batchlevel festlegen
 lea      pipe_nams(pc),a0
 moveq    #'?',d1
 moveq    #'?',d2
 tst      d0
 blt.b    mpi_5
 moveq    #'o',d1
 tst      d0
 bne.b    mpi_1
 moveq    #'i',d1
mpi_1:
 moveq    #'0',d2
 add.w    batchlevel(pc),d2
* ggf. Pfad fÅr TemporÑrdateien benutzen
mpi_5:
 move.b   d2,7(a0)
 move.b   d1,9(a0)
 lea      pipe_path(pc),a0
 bsr      getenv
 beq.b    mpi_2
 move.l   d0,a1
 move.l   a5,a0
 bsr      strcpy
* ggf. '\' anhÑngen. a0 zeigt hier hinter EOS
 subq.l   #2,a0
 cmpi.b   #'\',(a0)
 beq.b    mpi_4
 cmpi.b   #':',(a0)+
 beq.b    mpi_4
 move.b   #'\',(a0)+
 clr.b    (a0)
mpi_4:
 lea      pipe_nams+1(pc),a1
 move.l   a5,a0
 bsr      strcat
 bra.b    mpi_end
mpi_2:
 lea      pipe_nams(pc),a1
 move.l   a5,a0
 bsr      strcpy
mpi_end:
 move.l   (sp)+,a5
 rts

**********************************************************************
*
* char *get_county_str(a0 = char *s)
*
* language: country code
* a0: ptr to countries & strings, as below:
* char n1,n2,...,-1      countries for 1st string
* char s1[]              1st string
* char n3,n4,...,-1      countries for 2nd string
* char s2[]              2nd string
* char -1                terminator
* char defs[]            default string (usually english)
*
**********************************************************************

get_country_str:
		move.l  d4,-(a7)
		move.l  d1,-(a7)
		move.b  d+language(pc),d4
get_country_str_loop:
        move.b  (a0)+,d1
        bmi.s   _chk_ende                       ; Abschlussbyte, Default verwenden
_chk_nxt:
        cmp.b   d4,d1                           ; unsere Nationalitaet ?
        beq.s   _chk_found
        move.b  (a0)+,d1                        ; naechste Nationalitaet
        bge.s   _chk_nxt                        ; weiter vergleichen
_chk_nxtstr:
        tst.b   (a0)+                           ; Zeichenkette ueberspringen
        bne.s   _chk_nxtstr
        bra.s   get_country_str_loop            ; nicht gefunden

_chk_found:
        tst.b   (a0)+
        bge.s   _chk_found
_chk_ende:
		move.l  (a7)+,d1
		move.l  (a7)+,d4
        rts


print_with_driveletter:
		bsr.s   get_country_str
		lea     -80(sp),sp
		pea     (a1)
        lea     drive_to_letter(pc),a1
        move.b  0(a1,d0.w),d0
		lea     4(sp),a1
insert_drive_letter_loop:
		move.b  (a0)+,d1
		cmp.b   #'%',d1
		bne.s   insert_drive_letter_put
		move.b  d0,d1
insert_drive_letter_put:
		move.b  d1,(a1)+
		bne.s   insert_drive_letter_loop
insert_drive_letter_end:
        move.l  (sp)+,a1
        move.l  sp,a0
        jsr     (a1)
		lea     80(sp),sp
		rts

*    DATA

autoexec1s: DC.B  'C:\AUTOEXEC.BAT',0
autoexec2s: DC.B  '\AUTOEXEC.BAT',0

	IFF ACC
bootbats:     DC.B  '\BOOT.BAT',0
	ENDC

	IFF KAOS
func_s:       DC.B  'F0=',0
titels:       DC.B  'GEMDOSø SHELL v2.68 Ω ',$27,'90 Andreas Kromke',CR,LF
	ENDC
	IF KAOS
	IFNE MAGIX
titels:       DC.B  'MagiC SHELL v2.68 Ω ',$27,'93/',$27,'26 Andreas Kromke',CR,LF
	ELSE
titels:       DC.B  'KAOSø   SHELL v2.68 Ω ',$27,'90 Andreas Kromke',CR,LF
	ENDC
	ENDC
	IF ACC
              DC.B  'Accessory- Version',CR,LF
	ENDC
              DC.B  LF,0

     IFNE MAGIX
kaos_s:     DC.B  LF,'MagiC v',0
     ELSE
kaos_s:     DC.B  LF,'KAOS v',0
     ENDC
tos_s:      DC.B  LF,'TOS v',0
gemdos_s:   DC.B  ',  GEMDOS v',0
	IF ACC
aes_s:      DC.B  'AES v',0
	ENDC

croots:       DC.B  'A:'
allroots:     DC.B  '\'
star_pt_star: DC.B  '*.*',0
dellines:     DC.B  $1b,'l',0
offs:         DC.B  'OFF',0
ons:          DC.B  'ON',0
spaces:       DC.B  ' '
leers:        DC.B  0
promptis:     DC.B  'PROMPT=',0
pathis:       DC.B  'PATH=',0
crlfs:        DC.B  $d,$a,0

not_s:        DC.B  'NOT',0
errorlevel_s: DC.B  'ERRORLEVEL',0
exist_s:      DC.B  'EXIST',0
equal_s:      DC.B  '='
gleich_s:     DC.B  '=',0

stdx_namtab: DC.B  'IN ',0,'OUT',0,'AUX',0
             DC.B  'PRN',0,'ERR',0,'XTRA',0

pipe_path: DC.B  'TMPDIR=',0
pipe_nams: DC.B  '\$$pipe?.?',0

clss:  DC.B  ESC,'E',ESC,'v',ESC,'q',0    * clear screen/wrap ON/inverse OFF

device_s:  DC.B  'CON'
           DC.B  'AUX'
           DC.B  'PRN'
           DC.B  'NUL'

pgm_typ_tab:
bat_s:    DC.B  '.BAT',0           ; Batch
btp_s:    DC.B  '.BTP',0           ; Batch takes parameter (NeoDesk)
          DC.B  '.TTP',0
          DC.B  '.TOS',0
prg_s:    DC.B  '.PRG',0
app_s:    DC.B  '.APP',0
acc_s:    DC.B  '.ACC',0
* ANZ_SUFFIX     EQU  6 siehe oben!

prompt_zeichen:
 DC.B     p_unterstr-p_t,'_'
 DC.B     p_b-p_t,'b'
 DC.B     p_d-p_t,'d'
 DC.B     p_e-p_t,'e'
 DC.B     p_g-p_t,'g'
 DC.B     p_h-p_t,'h'
 DC.B     p_l-p_t,'l'
 DC.B     p_n-p_t,'n'
 DC.B     p_p-p_t,'p'
 DC.B     p_q-p_t,'q'
 DC.B     p_t-p_t,'t'
 DC.B     p_d7next-p_t,0

def_prompt: DC.B    '$n$g',0       * Default- Prompt

errcodes: DC.B  -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-13,-14,-15,-16,-17
          DC.B  -32,-33,-34,-35,-36,-37,-39,-40,-46,-48,-49,-64,-65,-66
          DC.B  -67,-69,0

     EVEN
errstrs:
*                BIOS- Fehler
 DC.W     err_1s-errstrs,err_02s-errstrs,err_03s-errstrs
 DC.W    err_04s-errstrs,err_05s-errstrs,err_06s-errstrs
 DC.W    err_07s-errstrs,err_08s-errstrs,err_09s-errstrs
 DC.W    err_10s-errstrs,err_11s-errstrs
 DC.W    err_13s-errstrs,err_14s-errstrs,err_15s-errstrs
 DC.W    err_16s-errstrs,err_17s-errstrs
*                GEMDOS- Fehler
 DC.W    err_32s-errstrs,err_33s-errstrs,err_34s-errstrs
 DC.W    err_35s-errstrs,err_36s-errstrs,err_37s-errstrs
 DC.W    err_39s-errstrs,err_40s-errstrs,err_46s-errstrs,err_48s-errstrs
 DC.W    err_49s-errstrs,err_64s-errstrs,err_65s-errstrs
 DC.W    err_66s-errstrs,err_67s-errstrs,err_69s-errstrs

attrib_s: DC.B  'attrib',0
break_s:  DC.B  'break',0
cd_s:     DC.B  'cd',0
cls_s:    DC.B  'cls',0
ck_s:     DC.B  'ck',0
copy_s:   DC.B  'copy',0
date_s:   DC.B  'date',0
del_s:    DC.B  'del',0
dir_s:    DC.B  'dir',0
echo_s:   DC.B  'echo',0
end_s:    DC.B  'end',0
exit_s:   DC.B  'exit',0
find_s:   DC.B  'find',0
for_s:    DC.B  'for',0
free_s:   DC.B  'free',0
goto_s:   DC.B  'goto',0
if_s:     DC.B  'if',0
md_s:     DC.B  'md',0
more_s:   DC.B  'more',0
mv_s:     DC.B  'mv',0
path_s:   DC.B  'path',0
pause_s:  DC.B  'pause',0
prompt_s: DC.B  'prompt',0
ren_s:    DC.B  'ren',0
rd_s:     DC.B  'rd',0
set_s:    DC.B  'set',0
shift_s:  DC.B  'shift',0
sort_s:   DC.B  'sort',0
time_s:   DC.B  'time',0
touch_s:  DC.B  'touch',0
tree_s:   DC.B  'tree',0
type_s:   DC.B  'type',0
ver_s:    DC.B  'ver',0
verify_s: DC.B  'verify',0

sort_mode:     DC.B    'N'
is_echo:       DC.B    0
is_kaos:       DC.B    0
          EVEN
tpa_base:      DC.L    0
	IFF KAOS
ovwr_flag:     DC.W    0			; fÅr den Zeilen-Editor, den wir nur unter TOS brauchen
	ENDC
for_flag:      DC.W    0
for_hdl:       DC.W    0
for_pos:       DC.L    0
errorlevel:    DC.W    0
batchlevel:    DC.W    0

	IF ACC
_run:          DC.L    os10_run
acc_init:      DC.W    0
* Default-SSP fÅr jeden neuen Prozeû (von GEMDOS- Pexec() festgesetzt)
intssp:        DC.W    $4db8       * TOS 1.0
               DC.W    $755a       * TOS 1.2
               DC.W    $378a       * TOS 1.4
* Da der Metacomco- Assembler ungerade Relo- Adressen erzeugt:
aespb:    DC.L      (d+control)-_base
          DC.L      (d+global)-_base
          DC.L      (d+intin)-_base
          DC.L      (d+intout)-_base
          DC.L      (d+addrin)-_base
          DC.L      (d+addrout)-_base
pgmname:  DC.B      '  CMD',0
	ENDC

     INCLUDE "messages.inc"

************ BEGINN DES BSS ***********

        BSS

d:
     DS.B  bsslen
