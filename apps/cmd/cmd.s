     SUPER
     INCLUDE "osbind.inc"



**********************************************************************
*
* CMD, letzte énderung 28.5.92
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

     IFEQ MAGIX
etvcritic_alt: DS.L      1
     ENDIF

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

 IFF      KAOS
laststring:    DS.B      130            * UNDO- Puffer
home_ypos:     DS.W      1              * FÅr Editor
 ENDC
 IF       ACC
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

 IFF      ACC

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

 ENDIF

 IF       ACC

 INCLUDE  "aesbind.inc"

ZEILEN    EQU  19                  * soviele Bildschirmzeilen retten

 move.l   a0,a1
 move.l   #$100,d0                 ; ProgrammlÑnge + $100
 add.l    $c(a1),d0
 add.l    $14(a1),d0
 add.l    $1c(a1),d0
 lea      -32(a1,d0.l),sp
 lea      d+stacktop(pc),a0
 move.l   sp,(a0)
* ssp retten
 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp
 move.l   sp,usp                   * USP restaurieren
 lea      d+alt_ssp(pc),a0
 move.l   d0,(a0)
 move.l   d0,sp                    * SSP restaurieren
 lea      d+c_sysbase(pc),a0
 move.l   _sysbase,a1
 move.l   a1,(a0)+                 * Zeiger auf Beginn des Betriebssystems
 move.l   phystop,(a0)
 andi.w   #$dfff,sr                * User mode

 move.w   os_version(a1),d1
 cmpi.w   #$0102,d1                * TOS - Version >= 1.2 ?
 bcs.b    tos_10
 move.l   os_run(a1),d0
 lea      _run(pc),a0
 move.l   d0,(a0)
tos_10:
* Default-Interrupt-SSP feststellen
 lea      intssp(pc),a0
 cmpi.w   #$0104,d1                * TOS - Version > 1.4 ?
 bhi.b    unknown
 andi.w   #6,d1
 move.w   0(a0,d1.w),(a0)          * ssp holen und in <intssp> merken
unknown:

 lea      aespb(pc),a0
 lea      _base(pc),a1
 moveq    #6-1,d0
ini_53:
 move.l   (a0),d1
 add.l    a1,d1
 move.l   d1,(a0)+
 dbra     d0,ini_53
* noch leeres Environment anmelden (vorher haben ACCs kein Environment)
 lea      _base+$2c(pc),a0
 lea      d+environment(pc),a1
 move.l   a1,(a0)
 clr.b    (a1)+
 clr.b    (a1)

** ap_id = appl_init();
** if (ap_id < 0) Pterm0();
 M_appl_init
 bmi      exit
 lea      d+ap_id(pc),a0
 move.w   d0,(a0)
 lea      d+global+2(pc),a0        ; ap_count
 cmpi.w   #1,(a0)
 lea      d+isxaes(pc),a0
 shi.b    (a0)                     ; merken, wenn XAES

** menu_id=menu_register(gl_apid,"  CMD");
** if     (menu_id == -1) Pterm0();
 lea      d+intin(pc),a0
 move.w   d0,(a0)
 lea      d+addrin(pc),a0
 lea      pgmname(pc),a1
 move.l   a1,(a0)
 M_menu_register
 bmi      exit
 lea      d+menu_id(pc),a0
 move.w   d0,(a0)

** wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
 lea      d+intin(pc),a0
 move.l   #$00000004,(a0)
 M_wind_get
 bmi      exit
 lea      d+intout+2(pc),a0
 lea      d+xdesk(pc),a1
 move.l   (a0)+,(a1)+
 move.l   (a0),(a1)

* Zeiger auf Ur- Prozeû merken
 move.b   d+isxaes(pc),d0
 bne.b    ini_xaes_nopd
 move.l   _run(pc),a0
 move.l   (a0),d0
ini_parent:
 move.l   d0,a0
 adda.w   #$24,a0
 move.l   (a0),d0                  * Elter- Prozeû
 bne.b    ini_parent
 lea      d+pnt_of_boot(pc),a1
 move.l   a0,(a1)
ini_xaes_nopd:

again:
 move.l   d+stacktop(pc),sp
* ssp und usp rÅcksetzen
 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp
 move.l   sp,usp                   * USP restaurieren
 move.l   d+alt_ssp(pc),sp         * SSP restaurieren
 andi.w   #$dfff,sr                * User mode

* Prozeû umschalten (vor den Ur- PD einhÑngen), wenn nicht XAES
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes
 move.l   d+pnt_of_boot(pc),a0
 lea      _base(pc),a1
 move.l   a1,(a0)                  * ACC als Elter des Ur- PD anmelden
ini_isxaes:

** evnt_mesag(ev_mgpbuff);
ini_waitmesag:
 lea      d+addrin(pc),a0
 lea      d+ev_mgpbuff(pc),a1
 move.l   a1,(a0)
 M_evnt_mesag
 move.w   d+ev_mgpbuff(pc),d0
 cmpi.w   #AC_OPEN,d0
 bne.b    ini_waitmesag

* Die folgenden Befehle klappen nicht unter Atari- MistGEM
* move.w   d+menu_id(pc),d0
* cmp.w    d+ev_mgpbuff+3*2(pc),d0
* bne.b    init_waitmesag

* Die Nachricht ist angekommen, daû wir aufgerufen werden.

* Oberste Interrupt- Stack- Werte retten
* (AES - Fehler korrigieren)
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes2
 move.w   intssp(pc),a1
 moveq    #20-1,d0
 lea      d+evnt_ret(pc),a0
ini_stkrett:
 move.l   -(a1),(a0)+
 dbra     d0,ini_stkrett

* Wir melden uns als aktuellen Prozeû an.
 move.l   d+pnt_of_boot(pc),a0
 clr.l    (a0)                     * als Elter des Ur-PD abmelden
 move.l   _run(pc),a0
 lea      _base+$24(pc),a1
 move.l   (a0),(a1)                * Hauptapp als unser Elter
 lea      _base(pc),a1
 move.l   a1,(a0)                  * Wir als aktueller Prozeû
ini_isxaes2:

* Mauszeiger abschalten
 DC.W     A_HIDE_MOUSE

** wind_update(TRUE);
 lea      d+intin(pc),a0
 move.w   #1,(a0)
 M_wind_update
 beq      again

** whdl = wind_create(0,xdesk,ydesk,wdesk,hdesk);
** if   (whdl < 0) goto err;
 lea      d+intin(pc),a0
 clr.w    (a0)+
 move.l   d+xdesk(pc),(a0)+
 move.l   d+wdesk(pc),(a0)+
 M_wind_create
 bmi      err
 lea      d+whdl(pc),a0
 move.w   d0,(a0)

** wind_open(whdl,xdesk,ydesk,wdesk,hdesk);
 lea      d+intin(pc),a0
 move.w   d0,(a0)+
 move.l   d+xdesk(pc),(a0)+
 move.l   d+wdesk(pc),(a0)+
 M_wind_open
 bmi      err1

* Bildschirmspeicher (MenÅleiste) sichern
 xbios    Physbase
 addq.l   #2,sp
 move.l   d0,a0
 lea      d+screenbuf(pc),a1
 move.w   #ZEILEN*20-1,d0
ini_52:
 move.l   (a0)+,(a1)+
 dbra     d0,ini_52
 ENDIF

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

     IFEQ MAGIX
 pea      etv_critic_neu(pc)
 move.w   #$101,-(sp)    * etv_critic
 bios     Setexc
 addq.l   #8,sp
 lea      d+etvcritic_alt(pc),a0
 move.l   d0,(a0)
     ENDIF

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
 IF       ACC
 clr.b    (a5)
 ENDIF
 move.b   (a5)+,d7
 ext.w    d7                       * LÑnge der Kommandozeile
 clr.b    0(a5,d7.w)               * Kommandozeile mit EOS abschlieûen

 IFF      ACC
* Environment- Behandlung
 lea      _base+$2c(pc),a2
 move.l   (a2),a0                  * Zeiger auf Environment- String
 lea      d+environment(pc),a1
 move.l   a1,(a2)                  * Zeiger in Basepage auf neues Environment setzen
 move.l a0,d0
 beq.s ini_22
* Environment kopieren
 move.w   #env_ende-environment-2,d1
ini_23:
 move.b   (a0)+,(a1)+
 dbeq     d1,ini_23
 tst.b    (a0)
 beq.b    ini_22
 tst.w    d1
 bhi.b    ini_23
ini_22:
 clr.b    (a1)+                    * Kopie mit zwei Nullbytes abschlieûen
 clr.b    (a1)
 ENDIF

* Maus aus, Cursor ein, Bildschirm lîschen, Titelmeldung

 bsr      cursor                   * Cursor ein/Maus aus

     IFEQ BOOT
 bsr      cls_com
     ENDIF

 lea      titels(pc),a0            * Titelmeldung
 bsr      strcon

* AUTOEXEC.BAT, BOOT.BAT oder Kommandozeile ausfÅhren
 tst.w    d7                       * LÑnge der Kommandozeile
 bne.b    ini_setjmp               ; Kommandozeile existiert
 IF       ACC
 lea      acc_init(pc),a0
 tst.w    (a0)                     ; AUTOEXEC schon einmal ausgefÅhrt ?
 bne.b    ini_nocmd                ; ja, nichts tun
 st       (a0)
 ENDC
 lea      autoexec1s(pc),a5
 IFF      ACC
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



 IFF      ACC
* void get_sysvars
*  MUû IM SUPERVISOR-MODUS AUSGEFöHRT WERDEN
*

get_sysvars:
 lea      d+c_sysbase(pc),a0
 move.l   _sysbase,(a0)+           * Zeiger auf Beginn des Betriebssystems
 move.l   phystop,(a0)
 rts
 ENDC


* AES Handler fÅr den Betrieb als Accessory

 IF       ACC
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


* Alle etv- Vektoren wieder zurÅcksetzen und exit()

restore_etv:
 move.l   d+config_alt(pc),-(sp)
 move.w   #1,-(sp)
 gemdos   Sconfig
 addq.l   #8,sp

     IFEQ MAGIX
 move.l   d+etvcritic_alt(pc),-(sp)
 move.w   #$101,-(sp)              * etv_critic
 bios     Setexc
 addq.l   #8,sp
     ENDIF

 move.l   etv_term_neu-4(pc),-(sp)
 move.w   #$102,-(sp)
 bios     Setexc                   * etv_term
 addq.l   #8,sp
exit:
 IF       ACC
* Zuallererst Cursor ausschalten
 clr.w    -(sp)
 xbios    Cursconf
 addq.l   #4,sp
* Oberste Interrupt- Stack- Werte rÅcksetzen
* (AES - Fehler korrigieren)
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes3
 move.w   intssp(pc),a1
 moveq    #20-1,d0
 lea      d+evnt_ret(pc),a0
ini_menurett:
 move.l   (a0)+,-(a1)
 dbra     d0,ini_menurett
* Bildschirmspeicher (MenÅleiste) restaurieren
ini_isxaes3:
err3:
 xbios    Physbase
 addq.l   #2,sp
 move.l   d0,a0
 lea      d+screenbuf(pc),a1
 move.w   #ZEILEN*20-1,d0
ini_menurst:
 move.l   (a1)+,(a0)+
 dbra     d0,ini_menurst


** wind_close(whdl);
err2:
 lea      d+intin(pc),a0
 move.w   d+whdl(pc),(a0)
 M_wind_close

** wind_delete(whdl);
err1:
 lea      d+intin(pc),a0
 move.w   d+whdl(pc),(a0)
 M_wind_delete

** wind_update(FALSE);
err:
 lea      d+intin(pc),a0
 clr.w    (a0)
 M_wind_update

* Maus einschalten
 bsr      mouse

* Wir melden uns als aktueller Prozeû wieder ab
 move.b   d+isxaes(pc),d0
 bne.b    ini_isxaes4
 move.l   _run(pc),a0
 lea      _base+$24(pc),a1
 move.l   (a1),(a0)                * Hauptapp als aktueller Prozeû
 clr.l    (a1)                     * kein Elter
ini_isxaes4:
 bra      again
 ENDC
 IFF      ACC
 IFF      BOOT
 bsr      mouse
 clr.w    -(sp)
 move.b   is_kaos(pc),d0
 beq.b    ini_exnk
 move.w   #EBREAK,(sp)             ; fÅr MagiX Bildschirm aufrÑumen
ini_exnk:
 gemdos   Pterm
 ENDC
 IF       BOOT
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
 bsr      strcon
 rts


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
* Schreibt eine Langzahl linksbÅndig

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


PUFFER    SET  -20

write_long:
 link     a6,#PUFFER
 movem.l  d6/d7,-(sp)
 move.w   d1,d7                    * len
 move.b   d2,d6                    * leader
 lea      PUFFER(a6),a0
;move.l   d0,d0                    * zahl
 bsr      long_to_str
 sub.w    d0,d7                    * d0 ist tatsÑchliche LÑnge
 bra.b    wl_put
wl_loop:
 move.b   d6,d0
 bsr      putchar
wl_put:
 dbra     d7,wl_loop
 lea      PUFFER(a6),a0
 bsr      strstdout                * Zahl ausgeben
 movem.l  (sp)+,d6/d7
 unlk     a6
 rts


* int long_to_str(d0 = unsigned long zahl, a0 = char string[])
*  Rechnet eine Zahl dezimal in einen String um, dessen LÑnge zurÅckgegeben
*  wird.

*    DATA
deztab:   DC.L 10000000,1000000,100000,10000,1000,100,10,1,0
*    TEXT

long_to_str:
 move.l   d7,-(sp)
 move.l   d0,d7
 move.l   a0,a1
 st       d2             * Flag fÅr fÅhrende Null setzen
 lea      deztab(pc),a2
lts_loop:
 move.l   (a2)+,d1       * Divisor
 beq.b    its_10
 moveq    #-1,d0         * ZÑhler
lts_loop2:
 addq.w   #1,d0
 sub.l    d1,d7
 bcc.b    lts_loop2
 add.l    d1,d7
 tst.w    d0
 bne.b    its_3          * Ziffer > 0
 cmpi.w   #1,d1
 beq.b    its_3          * letzte Ziffer muû gedruckt werden
 tst.w    d2
 bne.b    lts_loop       * fÅhrende Nullen unterdrÅcken
its_3:
 addi.w   #'0',d0
 move.b   d0,(a1)+       * Zahl abspeichern
 clr.w    d2             * Flag fÅr fÅhrende Null lîschen
 bra.b    lts_loop       * NÑchste Ziffer
its_10:
 clr.b    (a1)
 suba.l   a0,a1          * Stringanfang abziehen
 move.l   a1,d0          * StringlÑnge zurÅckgeben
 move.l   (sp)+,d7
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
*  gewechselt wurde und veranlaût, wenn ja, GEMDOS zur Neuinitialisierung
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


* void fatal(d0 = errno)
* int errno;
*  Falls <errno> < 0, wird der Fehlercode ausgedruckt und CMD
*  neu gestartet (break)

fatal:
 tst      d0
 bge.b    fat_end
 bsr      crprint_err
 bra      break
fat_end:
 rts


* void print_err(d0 = errno)
* int errno;
*  Schreibt den zum DOS- Fehlercode <errno> gehîrenden Fehlerstring nach CON:

*    DATA
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

err_1s:  DC.B  'Allgemeiner Fehler',0
err_02s: DC.B  'Laufwerk nicht bereit',0
err_03s: DC.B  'Unbekanntes Kommando',0
err_04s: DC.B  'CRC- Fehler',0
err_05s: DC.B  'Kommando falsch',0
err_06s: DC.B  'Spur nicht gefunden',0
err_07s: DC.B  'Unbekanntes Medium',0
err_08s: DC.B  'Sektor nicht gefunden',0
err_09s: DC.B  'Kein Papier',0
err_10s: DC.B  'Schreibfehler',0
err_11s: DC.B  'Lesefehler',0
err_13s: DC.B  'Disk schreibgeschÅtzt',0
err_14s: DC.B  'Unerlaubter Diskwechsel',0
err_15s: DC.B  'Unbekanntes GerÑt',0
err_16s: DC.B  'Defekte Sektoren',0
err_17s: DC.B  'Andere Disk einlegen!',0

err_32s: DC.B  'UngÅltige Funktionsnummer',0
err_33s: DC.B  'Datei nicht gefunden',0
err_34s: DC.B  'Pfad nicht gefunden',0
err_35s: DC.B  'Zuviele geîffnete Dateien',0
err_36s: DC.B  'Zugriff unmîglich',0
err_37s: DC.B  'UngÅltiges Handle',0
err_39s: DC.B  'Zuwenig Speicher',0
err_40s: DC.B  'UngÅltiger Speicherblock',0
err_46s: DC.B  'UngÅltiges Laufwerk',0
err_48s: DC.B  'Nicht dasselbe Laufwerk',0
err_49s: DC.B  'Keine weiteren Dateien',0
err_64s: DC.B  'Falscher Bereich',0
err_65s: DC.B  'Interner Fehler',0
err_66s: DC.B  'Datei nicht ausfÅhrbar',0
err_67s: DC.B  'Mshrink- Fehler',0
err_69s: DC.B  '68000 Exception',0           * KAOS
toserrs: DC.B  'TOS Fehler',0
*    TEXT
     EVEN

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


* int crprint_err(d0 = int errcode)
*  wie print_err, gibt vorher und nachher cr/lf nach CON
*  Gibt Fehlercode wieder in d0 zurÅck

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

 IFF      KAOS
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

* Erst Cursor aus-, dann Mauszeiger einschalten

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
     ENDIF
 rts

* Erst Mauszeiger aus-, dann Cursor einschalten

cursor:
     IFEQ BOOT
 DC.W     A_HIDE_MOUSE
 move.w   #1,-(sp)
 xbios    Cursconf
 addq.l   #4,sp
     ENDIF
 rts


*    DATA
clss:  DC.B  ESC,'E',ESC,'v',ESC,'q',0    * Csr/CLS/WRAP/Normal
*    TEXT
     EVEN

cls_com:
 lea      clss(pc),a0


* void strcon(string)
* a0 = char *string;
*  gibt einen String an die Konsole CON:

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


* void crlf_con()

crlf_con:
 moveq    #CR,d0
 bsr.b    putch
 moveq    #LF,d0


* void putch()
*  Druckt das Zeichen in d0 nach Device 2 (CON)

putch:
 move.w   d0,-(sp)
 move.w   #2,-(sp)
 bios     Bconout
 addq.l   #6,sp
 rts


* void crlf_stdout()

crlf_stdout:
 moveq    #CR,d0
 bsr.b    putchar
 moveq    #LF,d0


* long putchar()
*  Druckt das Zeichen in d0 nach stdout

putchar:
 move.w   d0,-(sp)
 lea      1(sp),a0
 moveq    #STDOUT,d0               * Handle 1 = STDOUT
 moveq    #1,d1                    * Anzahl = 1
 bsr      write
 addq.l   #2,sp
 rts


* void strstdout(a0 = string)
* a0 = char *string;
*  Ersatz fÅr fehlerhafte Funktion gemdos Cconws(), deren Ausgabe man nicht
*  auf den Drucker lenken kann.

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

*         DATA
change_s:     DC.B     'Bitte Disk '
change_s_dr:  DC.B     'X: in Laufwerk A: einlegen!',0
diskerr_s:    DC.B     '  auf Laufwerk '
diskerr_s_dr: DC.B  'X:',$d,$a
           DC.B  '[A]bbruch, [W]iederholen, [I]gnorieren ?',0
*         TEXT
          EVEN

etv_critic_neu:
 lea      drive_to_letter(pc),a0
 move.w   6(sp),d0                 * Laufwerknummer
 move.b   0(a0,d0.w),d0
 lea      diskerr_s(pc),a0
 lea      change_s(pc),a1
 move.b   d0,diskerr_s_dr-diskerr_s(a0)
 move.b   d0,change_s_dr-change_s(a1)
 bsr      crlf_con
 lea      change_s(pc),a0
 cmpi.w   #EOTHER,4(sp)
 beq.b    etc_4
 move.w   4(sp),d0                 * Fehlercode
 bsr      print_err
 lea      diskerr_s(pc),a0
etc_4:
 bsr      strcon
etc_getkey:
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
 cmpi.b   #3,d0
 bne.b    etc_nobreak
 move.w   #EBREAK,-(sp)
 gemdos   Pterm
 addq.l   #4,sp
etc_nobreak:
 cmpi.w   #EOTHER,4(sp)
 beq.b    etc_6
 bsr      d0_upper
 cmpi.b   #'A',d0   * Abbruch
 bne.b    etc_2
 move.w   4(sp),d1
 ext.l    d1
 bra.b    etc_11
etc_6:
 move.b   #' ',d0
 bra.b    etc_5
etc_2:
 cmpi.b   #'W',d0   * Wiederh.
 bne.b    etc_3
etc_5:
 move.l   #$10000,d1
 bra.b    etc_11
etc_3:
 cmpi.b   #'I',d0   * Ignor.
 bne.b    etc_getkey
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
     ENDIF


* d0 = char *getenv(a0 = char *string)
*  PrÅft, ob die Variable <string> im environment existiert
*  RÅckgabe: Zeiger auf den WERT der Variablen (im Env.) oder NULL
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


* int env_set(a0 = char *zuweisung)
*  Setzt eine Variable im Environment. RÅckgabe: 0 = OK
*                                                1 = Syntaxfehler
*                                                2 = Environment voll

*    DATA
out_of_envs:   DC.B  $d,$a,'Environment voll',$d,$a,0
*    TEXT
     EVEN

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


*    DATA
syntaxfehlers: DC.B  $d,$a,'Syntax: SET [var=[wert]]',$d,$a,0
*    TEXT
     EVEN

set_com:
 subq.w   #2,SP_ARGC(sp)
 bge.b    setcom_4
 move.l   a5,-(sp)
 lea      d+environment(pc),a5     * keine Parameter
 bra.b    setcom_3                 * Environment ausgeben
setcom_loop:
 bsr      crlf_stdout              * newline und Eintrag ausdrucken
 move.l   a5,a0
 bsr      strstdout
setcom_2:
 tst.b    (a5)+                    * Suchen nÑchsten Eintrag
 bne.b    setcom_2
setcom_3:
 tst.b    (a5)                     * Zwei Nullbytes hintereinander => Ende
 bne.b    setcom_loop
 bsr      crlf_stdout
 move.l   (sp)+,a5
 bra.b    setcom_end
setcom_4:
 movea.l  SP_ARGV(sp),a0
 move.l   4(a0),a0
 bsr      env_set
 tst.w    d0
 beq.b    setcom_end
 subq.w   #2,d0
 beq.b    setcom_5
 lea      syntaxfehlers(pc),a0
 bsr      strcon
setcom_5:
 bsr      inc_errlv
setcom_end:
 rts


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

* void d_ate_to_str(d0 = int date, a0 = char *string)
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

*    DATA
disk_in_lw_s:    DC.B  $d,$a,' Disk in Laufwerk '
disk_in_lw_s_dr: DC.B  'A ',0
keinname_s:      DC.B  'hat keinen Namen',0
ist_s:           DC.B  'ist ',0
*    TEXT
     EVEN

label_to_stdout:
 link     a6,#-$30
 lea      croots(pc),a1
 lea      drive_to_letter(pc),a0
 move.b   0(a0,d0.w),d0
 move.b   d0,(a1)
 lea      disk_in_lw_s(pc),a0
 move.b   (a1),disk_in_lw_s_dr-disk_in_lw_s(a0)
 bsr      strstdout                * a0[] ausdrucken

 lea      -$2c(a6),a1              * DTA
 moveq    #8,d0                    * Suchen nach "Volume"
 lea      croots(pc),a0            * "x:\*.*"
 bsr      sfirst

 lea      keinname_s(pc),a0
 bne.b    lts_print
 lea      ist_s(pc),a0
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

*    DATA
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
     EVEN
*    TEXT

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
* Dahinter werden 2 Leerstellen geschrieben

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


DTA       SET  8
DATEINAME SET  4

* int attr(char *dateiname, DTA *)
* char *dateiname;
*  Setzt/Lîscht oder zeigt Attribute an

attr:
 lea      d+attrplus(pc),a0
 lea      d+attrminus(pc),a1
 move.l   DTA(sp),a2
 clr.w    d2
 move.b   $15(a2),d2          * Attribut
 move.b   (a0),d0
 or.b     (a1),d0
 beq.b    attr_10             * nur anzeigen
 or.b     (a0),d2             * Bits setzen
 move.b   (a1),d0
 not.b    d0
 and.b    d0,d2               * Bits lîschen
 cmp.b    $15(a2),d2          * hat sich Attribut geÑndert
 beq      attr_99             * nein => Ende
 move.w   d2,-(sp)
 move.w   #1,-(sp)
 move.l   DATEINAME+2+2(a7),-(sp)
 gemdos   Fattrib
 adda.w   #$a,sp
 move.l   d0,d2
 bge.b    attr_10
 bsr      print_err
 lea      auf_s(pc),a0
 bsr      strcon
 bra.b    attr_20
attr_10:
 move.w   d2,d0
 bsr      print_attr
attr_20:
 move.l   DATEINAME(sp),a0
 bsr      strstdout
 bsr      crlf_stdout
attr_99:
 clr.w    d0
 rts


*    DATA
syntaxattrs:  DC.B  'Syntax: ATTRIB [[+|-]{rash}] datei(en)',CR,LF,0
*    TEXT
     EVEN

attrib_com:
 move.l   a5,-(sp)
 bsr      crlf_con
 lea      d+attrplus(pc),a0
 clr.b    (a0)
 clr.b    attrminus-attrplus(a0)
 subq     #1,SP_ARGC+4(sp)
* Attribute holen
atcom_3:
 subq     #1,SP_ARGC+4(sp)
 bcs      atcom_50
 addq.l   #4,SP_ARGV+4(sp)
 move.l   SP_ARGV+4(sp),a5
 move.l   (a5),a5
 move.l   a0,a1
 cmpi.b   #'+',(a5)
 beq.b    atcom_1
 lea      d+attrminus(pc),a1
 cmpi.b   #'-',(a5)
 bne.b    atcom_20
atcom_1:
 addq.l   #1,a5
 move.b   (a5),d0
 beq.b    atcom_3
 bsr      d0_upper
 moveq    #1,d1
 cmpi.b   #'R',d0
 beq.b    atcom_2
 moveq    #2,d1
 cmpi.b   #'H',d0
 beq.b    atcom_2
 moveq    #4,d1
 cmpi.b   #'S',d0
 beq.b    atcom_2
 moveq    #32,d1
 cmpi.b   #'A',d0
 bne.b    atcom_50
atcom_2:
 or.b     d1,(a1)
 bra.b    atcom_1
* Dateinamen holen
atcom_20:
 lea      attr(pc),a1    * auszufÅhrende Routine
 moveq    #6,d0          * Dateityp = alle auûer Subdir
 move.l   a5,a0          * Dateiname(nsmuster)
 bsr      for_all
 bne.b    atcom_21
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      strcon
 bsr      inc_errlv
atcom_21:
 addq.l   #4,SP_ARGV+4(sp)
 move.l   SP_ARGV+4(sp),a5
 move.l   (a5),a5
 subq.w   #1,SP_ARGC+4(sp)
 bcc.b    atcom_20
 bra.b    atcom_end
atcom_50:
 lea      syntaxattrs(pc),a0
 bsr      strcon              * Fehlermeldung ausgeben und Ende
 bsr      inc_errlv
atcom_end:
 move.l   (sp)+,a5
 rts


PUFFER    SET  -200

cd_com:
 link     a6,#PUFFER
 movem.l  d6/d7/a5,-(sp)
 movea.l  ARGV(a6),a0
 movea.l  4(a0),a5
 move.l   a5,a0
 bsr      str_to_drive
 move.w   d0,d7
 blt.b    cdcom_50              * ungÅltiges Laufwerk

 cmpi.w   #1,ARGC(a6)
 ble.b    cdcom_4               * kein Parameter
 move.l   a5,a0
 bsr      is_newdrive
 tst.w    d0
 bge.b    cdcom_4               * Eingabe:  "CD X:"

 move.l   a5,-(sp)
 gemdos   Dsetpath              * Pfad setzen
 addq.l   #6,sp
 move.w   d0,d7                 * RÅckgabewert in d7 merken

 beq.b    cdcom_end
 bsr      crprint_err
cdcom_50:
 bsr      inc_errlv             * ungÅltiger Pfad
 bra.b    cdcom_end
cdcom_4:
 bsr      crlf_stdout
 lea      PUFFER(a6),a0
 move.w   d7,d0
 bsr      drive_to_defpath
 lea      PUFFER(a6),a0
 bsr      strstdout
 bsr      crlf_stdout
cdcom_end:
 movem.l  (sp)+,a5/d7/d6
 unlk     a6
 rts




* void search_whole_tree(d0 = drive, d1 = is_ck)
* int drive,is_ck;
*  is_ck = 0 : von tree_com() aufgerufen
*  is_ck = 1 : von ck_com()   aufgerufen
*  Durchsucht, ausgehend von der Wurzel, rekursiv den Directory- Baum

search_whole_tree:
 link     a6,#-110
 movem.l  a5/d7,-(sp)
 lea      -110(a6),a5              ; Pufferadresse
 move.w   d1,d7                    ; is_ck
 lea      drive_to_letter(pc),a0
 move.b   0(a0,d0.w),d0
 lea      d+treelevel(pc),a0
 move.w   #8,(a0)
 move.b   d0,(a5)+
 move.b   #':',(a5)+
 move.b   #'\',(a5)+
 clr.b    (a5)
 subq.w   #3,a5
 bsr.b    search_tree
 movem.l  (sp)+,a5/d7
 unlk     a6
 rts


* void search_tree( void )
*  DurchlÑuft rekursiv den Directory- Baum, ausgehend von dem <directory>
*  <is_ck> wie oben.
*  global: a5 (Pfad), a7 (is_ck)
*  Jeder Aufruf schreibt 48 Bytes auf den Stapel

*    DATA
pfadzutiefs: DC.B  $d,$a,'Pfad zu tief',$d,$a,0
pfads:       DC.B  $d,$a,'Pfad: ',0
*    TEXT
     EVEN

DTA       SET  -44                 * char DTA[44]

search_tree:
 link     a6,#DTA
 move.l   a4,-(sp)
 lea      d+treelevel(pc),a0
 subq.w   #1,(a0)
 bcs      srcht_6                  * Pfad tiefer als 8 Directories
 move.l   a5,a4
srcht_11:
 tst.b    (a4)+
 bne.b    srcht_11
 subq.w   #1,a4
 move.l   a4,a0
 lea      star_pt_star(pc),a1
 bsr      strcpy
 tst.w    d7                       * d7 = 0 => nur "tree"s ausgeben
 beq.b    srcht_3
 lea      pfads(pc),a0             * Vollen Pfadnamen angeben (ck_com())
 bsr      strstdout
 move.l   a5,a0
 bsr      strstdout
 bra.b    srcht_4
srcht_3:
 clr.b    (a4)                     * Nur Directories ausgeben (tree_com())
 lea      2(a5),a0                 * Laufwerksnamen "X:" weglassen (2 Bytes)
 bsr      strstdout
 bsr      crlf_stdout
 move.b   #'*',(a4)
srcht_4:

 lea      DTA(a6),a1
 moveq    #$16,d0                  * Subdirectories + hidden + system
 move.l   a5,a0
 bsr      sfirst

 bne      srcht_end                * Directory leer
srcht_5:
 cmpi.w   #$2e2e,DTA+30(a6)        * Dateiname beginnt mit '..' => Åbergehen
 beq.b    srcht_9
 cmpi.w   #$2e00,DTA+30(a6)        * Dateiname ist '.' => Åbergehen
 beq.b    srcht_9
 move.b   DTA+21(a6),d0            * Datei- Attribute
 btst     #3,d0                    * Volume- Eintrag => Åbergehen
 bne.b    srcht_9
 btst     #4,d0                    * Subdirectory ?
 beq.b    srcht_7                  * nein
 lea      d+subdir_no(pc),a0
 addq.w   #1,(a0)                  * Anzahl der Subdirectories mitzÑhlen
 lea      DTA+30(a6),a1
 move.l   a4,a0                    * Directory- Name nach a5[] kopieren (statt "*.*")
 bsr      strcpy
 move.b   #'\',-1(a0)
 clr.b    (a0)                     * '\' anhÑngen
 bsr      search_tree              * rekursiv neuen Pfad bearbeiten
 move.l   a4,a0
 lea      star_pt_star(pc),a1
 bsr      strcpy
 bra.b    srcht_9
srcht_6:
 lea      pfadzutiefs(pc),a0
 bsr      strcon
 bsr      inc_errlv
 bra.b    srcht_end
srcht_7:
 move.l   DTA+26(a6),d1      * DateilÑnge
 lea      d+normal_no(pc),a0
 lea      d+normal_len(pc),a1
 and.b    #6,d0          * alle Bits bis auf hidden & system lîschen
 beq.b    srcht_8
 addq.w   #2,a0
 addq.w   #4,a1
srcht_8:
 addq.w   #1,(a0)
 add.l    d1,(a1)
srcht_9:

 lea      DTA(a6),a0
 bsr      snext
 beq      srcht_5

srcht_end:
 lea      d+treelevel(pc),a0
 addq.w   #1,(a0)
 move.l   (sp)+,a4
 unlk     a6
 rts


* Routinen zur Freigabe von GEMDOS- Speicher

free_mediach:
 moveq    #2,d0
 rts
free_rw:
 moveq    #E_CHNG,d0
 rts
free_bpb:
 moveq    #0,d0
 rts


*    DATA
bytesinsg_s:  DC.B  '  Bytes insgesamt verfÅgbar',$d,$a,0
bytes_in_s:   DC.B  '  Bytes in ',0
hauptsp_s:    DC.B  '  Bytes Hauptspeicher',$d,$a,0
nbytesvers:   DC.B  ' versteckten/System- Datei(en)',$d,$a,0
nbytesbens:   DC.B  ' Benutzerdatei(en)',$d,$a,0
nverzeichns:  DC.B  '  Verzeichnis(sse)',$d,$a,0
*    TEXT
     EVEN

DFREE_BUFFER   SET   -16

tree_com:
 moveq    #0,d0
 bra.b    ck_tree_free

free_com:
 moveq    #2,d0
 bra.b    ck_tree_free

ck_com:
 moveq    #1,d0

ck_tree_free:
 link     a6,#DFREE_BUFFER
 movem.l  d6/d7/a5,-(sp)
 move     d0,d6               * 0 fÅr TREE, 1 fÅr CK
 lea      d+normal_no(pc),a0
 clr.l    (a0)+
 clr.w    (a0)+
 clr.l    (a0)+
 clr.l    (a0)
* clr.l    normal_len
* clr.l    hid_sys_len
* clr      normal_no
* clr      hid_sys_no
* clr      subdir_no
 movea.l  ARGV(a6),a0
 movea.l  4(a0),a5
 gemdos   Dgetdrv
 addq.l   #2,sp
 move.w   d0,d7
 cmpi.w   #1,ARGC(a6)
 ble.b    ctf_1             * kein Parameter
 move.l   a5,a0
 bsr      is_newdrive
 cmpi.w   #-2,d0
 beq.b    ctf_1             * nicht "X:"
 move.w   d0,d7          * Laufwerkscode ?
 bmi      ctf_50           * Fehler
ctf_1:
 tst      d6
 beq.b    ctf_30         * TREE
 cmpi.w   #2,d6
 bne.b    ctf_31
* FREE
 clr.l    -(sp)
 gemdos   Super          * in Super- Mode
 addq.l   #6,sp
 move.l   d0,-(sp)       * alten SP merken
 move.l   hdv_bpb,-(sp)
 move.l   hdv_rw,-(sp)
 move.l   hdv_mediach,-(sp)
 lea      free_bpb(pc),a0
 move.l   a0,hdv_bpb
 lea      free_rw(pc),a0
 move.l   a0,hdv_rw
 lea      free_mediach(pc),a0
 move.l   a0,hdv_mediach
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree               * Zugriff gibt Speicher frei
 addq.l   #8,sp
 move.l   (sp)+,hdv_mediach
 move.l   (sp)+,hdv_rw
 move.l   (sp)+,hdv_bpb
 gemdos   Super          * in User Mode
 addq.l   #6,sp
 bra      ctf_end
ctf_31:
 move.w   d7,d0
 bsr      label_to_stdout
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree
 addq.l   #8,sp
ctf_30:
 move.w   d6,d1
 move.w   d7,d0
 bsr      search_whole_tree
 tst      d6
 beq      ctf_end           * TREE
 bsr      crlf_stdout
 bsr      crlf_stdout
 lea      DFREE_BUFFER(a6),a0
* Multiplikation geht in die Hose, wenn Zahlen > 16 Bit!
 move.l   $c(a0),d0                     * Sektoren/Cluster
 move.l   8(a0),d1                      * Bytes/Sektor
 mulu     d1,d0                         * d0 = Bytes/Cluster
 move.l   4(a0),d1                      * Cluster
 mulu     d1,d0                         * d0 = Bytes
* Gesamtplatz auf Disk
 moveq    #10,d1         * Feld 10 Zeichen lang
* move.l   d0,d0
 bsr      rwrite_long
 lea      bytesinsg_s(pc),a0
 bsr      strstdout
 move.w   d+hid_sys_no(pc),d0
 beq.b    ctf_2
* Gesamtgrîûe und Anzahl der Systemdateien
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+hid_sys_len(pc),d0
 bsr      rwrite_long
 lea      bytes_in_s(pc),a0
 bsr      strstdout
 move.w   d+hid_sys_no(pc),d0
 ext.l    d0
 bsr      lwrite_long
 lea      nbytesvers(pc),a0
 bsr      strstdout
ctf_2:
* Gesamtgrîûe und Anzahl der Benutzerdateien
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+normal_len(pc),d0
 bsr      rwrite_long
 lea      bytes_in_s(pc),a0
 bsr      strstdout
 move.w   d+normal_no(pc),d0
 ext.l    d0
 bsr      lwrite_long
 lea      nbytesbens(pc),a0
 bsr      strstdout
* Anzahl der Subdirectories
 move.w   d+subdir_no(pc),d0
 beq.b    ctf_3
 moveq    #10,d1         * Feld 10 Zeichen lang
* move.l  d0,d0
 bsr      rwrite_long
 lea      nverzeichns(pc),a0
 bsr      strstdout
ctf_3:
 moveq    #10,d0
 lea      DFREE_BUFFER(a6),a0
 bsr      print_free
* Jetzt Grîûe des Hauptspeichers ermitteln
 bsr      crlf_stdout
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+c_phystop(pc),d0
 bsr      rwrite_long
 lea      hauptsp_s(pc),a0
 bsr      strstdout
* Jetzt Grîûe des freien Speichers
 bsr      memavail
 moveq    #10,d1
* move.l   d0,d0
 bsr      rwrite_long
 lea      nbytesfreis(pc),a0
 bsr      strstdout
 bra.b    ctf_end
ctf_50:
 bsr      inc_errlv
ctf_end:
 movem.l  (sp)+,a5/d7/d6
 unlk     a6
 rts


* void print_free(a0 = long *dfree_buffer, d0 = int outp_len)
*  Druckt die Grîûe des freien Diskettenplatzes
*  mit Ausgabebreite <outp_len>

*    DATA
nbytesfreis:  DC.B  '  Bytes frei',$d,$a,0
*    TEXT
     EVEN

print_free:
 move.w   d0,d1
* Multiplikation geht in die Hose, wenn Zahlen > 16 Bit!
 move.l   $c(a0),d0                     * Sektoren/Cluster
 move.l   8(a0),d2                      * Bytes/Sektor
 mulu     d2,d0                         * d0 = Bytes/Cluster
 move.l   (a0),d2                       * Cluster
 mulu     d2,d0                         * d0 = Bytes
* move.w   d1,d1
* move.l   d0,d0
 bsr      rwrite_long
 lea      nbytesfreis(pc),a0
 bsr      strstdout
 rts


* int isdevice(a0 = char dateiname[])
*  Stellt fest, ob ein Dateiname ein Device 'CON:', 'AUX:', 'PRN:' ist.

*    DATA
device_s:  DC.B  'CON'
           DC.B  'AUX'
           DC.B  'PRN'
           DC.B  'NUL'
*    TEXT
     EVEN

isdevice:
 movem.l  d7/a4,-(sp)
 subq.l   #4,sp
 tst.b    3(a0)
 beq.b    isdv_4                   ; String ist <= 3 Zeichen
 cmpi.b   #':',3(a0)               ; 4. Zeichen ':' ?
 bne      isdv_nix                 ; nein, kein GerÑt
 tst.b    4(a0)
 bne.b    isdv_nix                 ; zwar ':', aber danach noch was
isdv_4:
 move.l   sp,a1
 moveq    #2,d1                    ; 3 Zeichen kopieren
isdv_2:
 move.b   (a0)+,d0
 andi.b   #$5f,d0                  ; toupper
 move.b   d0,(a1)+
 dbra     d1,isdv_2
 lea      device_s(pc),a4          ; a4 = GerÑtenamen
 moveq    #3,d7                    ; 4 GerÑtenamen
isdv_1:
 move.l   sp,a0
 move.l   a4,a1
 moveq    #3,d0
 bsr      strncmp
 beq.b    isdv_5                   ; gefunden!
 addq.l   #3,a4
 dbra     d7,isdv_1
isdv_nix:
 moveq    #0,d0                    ; nicht gefunden
isdv_ende:
 addq.l   #4,sp
 movem.l  (sp)+,d7/a4
 rts
isdv_5:
 moveq    #1,d0
 bra.b    isdv_ende


* int fileren(alt_name,neu_name)
*  verschiebt eine Datei
*  RÅckgabewert 0, wenn alles in Ordnung

*    DATA
rens:      DC.B  'MV ',0
err_rens:  DC.B  ' => Fehler : ',0
*    TEXT
     EVEN

ALT_NAME  SET  8
NEU_NAME  SET  $c

fileren:
 link     a6,#-4
 move.l   NEU_NAME(a6),(sp)
 move.l   ALT_NAME(a6),-(sp)
 clr.w    -(sp)
 gemdos   Frename
 addq.l   #8,sp
 move.l   d0,(sp)
 lea      rens(pc),a0              * "MV "
 bsr      strcon
 move.l   ALT_NAME(a6),a0          * "altername"
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 move.l   (sp),d0
 bne.b    renf_1
 move.l   NEU_NAME(a6),a0          * "neuername"
 bsr      strcon
 bra.b    renf_end
renf_1:
 lea      err_rens(pc),a0
 bsr      strcon
 move.w   2(sp),d0                 * Low- Word des Fehlercodes
 bsr      print_err
renf_end:
 bsr      crlf_con
 move.l   (sp),d0
 unlk     a6
 rts


* int filecopy(quell_dateiname,ziel_dateiname)
*  kopiert eine Datei
*  RÅckgabewert 0, wenn alles in Ordnung

*    DATA
isidents:  DC.B  ' Quelle und Ziel identisch',$d,$a,0
copys:     DC.B  'COPY ',0
auf_s:     DC.B  ' auf ',0
zielvolls: DC.B  ' Zieldisk voll',$d,$a,0
     EVEN
*    TEXT

DTA_ZIEL       SET  -44
DTA_QUELL      SET  DTA_ZIEL-44
DATE_TIME      SET  DTA_QUELL-4

filecopy:
 link     a6,#DATE_TIME
 movem.l  d0/d3/d4/d6/d7/a3/a4/a5,-(sp)
 movem.l  8(a6),a3/a4         * 8(a6) -> a3 / $c(a6) -> a4
 bsr      memavail
 move.l   d0,d4               * Åberhaupt Speicher frei ?
 beq      fc_80
 cmp.l    #10240,d4           * mehr als 10k frei ?
 bcs.b    fc_30                 * nein => ganzen Speicher holen
 lsr.l    #1,d4               * sonst den halben Speicher holen
 andi.w   #$fffe,d4           * auf gerade Adressen zwingen
fc_30:
 move.l   d4,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq      fc_80
 move.l   d0,a5               * a5 ist Pufferadresse

 lea      DTA_ZIEL(a6),a1
 moveq    #0,d0
 move.l   a4,a0
 bsr      sfirst              * Datei- Informationen fÅr Ziel
 bne.b    fc_2

 lea      DTA_QUELL(a6),a1
 moveq    #0,d0
 move.l   a3,a0
 bsr      sfirst              * Datei- Informationen fÅr Quelle
 bne.b    fc_2

* Es wird nachgesehen, ob die beiden Dateien identisch sind. Dies ist der
* Fall, wenn DD (Bytes $11..$14) und Directory- Position (Bytes $d..$10)
* identisch sind

 lea      DTA_ZIEL+$d(a6),a0  * DTA- Puffer nur ab Byte 21 vergl.
 lea      DTA_QUELL+$d(a6),a1
 moveq    #8-1,d0             * vergl. DD/diroffs
fc_1:
 cmp.b    (a0)+,(a1)+
 dbne     d0,fc_1
 bne.b    fc_2
 lea      isidents(pc),a0
 bra      fc_70

* AUSGABE DES KOMMENTARS "COPY quelle ziel"

fc_2:
 lea      copys(pc),a0             * "COPY "
 bsr      strcon
 move.l   a3,a0
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 move.l   a4,a0
 bsr      strcon
 bsr      crlf_con
 gemdos   Cconis                   ; ^C abfragen
 addq.w   #2,sp

* ôFFNEN VON QUELL- UND ZIELDATEI

 clr.w    d0
 move.l   a3,a0
 bsr      open                * Quelldatei zum Lesen îffnen
 move.l   d0,d6               * LANGWORT testen !!! ('CON' ergibt 65535)
 bge.b    fc_4
 move.l   a3,(sp)             * Name der Fehlerhaften Datei
fc_3:
 bsr      print_err
 lea      auf_s(pc),a0
 bsr      strcon
 move.l   (sp),a0
 bra      fc_70
fc_4:
 tst.w    d6                  * GerÑt ?
 bge.b    fc_6
 move.l   #1024,d4            * Immer maximal nur 1024 Bytes lesen
fc_6:
 clr.w    d0                  * Zieldatei hat immer Attribut 0
 move.l   a4,a0
 bsr      create              * Zieldatei zum Schreiben îffnen
 move.l   d0,d7               * LANGWORT testen !!! ('CON' ergibt 65535)
 bge.b    fc_5
 move.w   d6,d0               * Fehler aufgetreten:
 bsr      close               * Quelldatei wieder schlieûen
 move.l   a4,(sp)             * Name der fehlerhaften Datei
 move.w   d7,d0
 bra.b    fc_3

* KOPIER- SCHLEIFE

fc_5:
 move.l   a5,a0               * pbuffer
 move.l   d4,d1               * count
 move.w   d6,d0               * handle
 bsr      read
 move.l   d0,d3               * Anzahl gelesener Bytes
 bge.b    fc_10
 move.l   a3,(sp)             * Fehler auf Quelldatei
fc_11:
 move.w   d6,d0
 bsr      close
 move.w   d7,d0
 bsr      close
 move.l   a4,-(sp)
 gemdos   Fdelete             * Zieldatei wieder lîschen
 addq.l   #6,sp
 move.l   d3,d0               * Fehlercode in d0
 blt.b    fc_3
 move.l   (sp),a0
 bra      fc_70
fc_10:
 tst.w    d6                  * Disk- Datei oder Device ?
 bge.b    fc_8

* SONDERBEHANDLUNG FöR GERéTE

 cmpi.w   #-3,d6              * NUL: oder PRN: ?
 ble.b    fc_7                  * Beenden
 cmpi.l   #1,d3
 bne.b    fc_9
 cmpi.b   #$1a,(a5)           * Zeile nur mit EOF gelesen
 beq.b    fc_7
fc_9:
 move.b   #CR,0(a5,d3.l)
 move.b   #LF,1(a5,d3.l)
 addq.l   #2,d3               * Zeichenfolge CR/LF ergÑnzen
 lea      -1(a5,d3.l),a0
 moveq    #1,d1
 move.w   d6,d0
 bsr      write               * LF echoen
fc_8:
 move.l   a5,a0               * pbuffer
 move.l   d3,d1               * count
 move.w   d7,d0               * handle
 bsr      write
 move.l   a4,(sp)
 tst.l    d0
 blt.b    fc_11                 * Fehler auf Zieldatei
 cmpi.w   #-4,d7              * Zieldatei NUL: ?
 beq.b    fc_31
 addq.l   #4,sp
 pea      zielvolls(pc)
 cmp.l    d3,d0
 bcs.b    fc_11                 * weniger geschrieben als vorhin gelesen
fc_31:
 tst.w    d6
 bmi      fc_5                  * Quelle = Device : Weitermachen
 cmp.l    d3,d4
 beq      fc_5                  * Noch nicht EOF:   Weitermachen

* Jetzt ist der Kopiervorgang korrekt beendet. Zeit/Datum der Zieldatei
* mÅssen von der Quelldatei Åbernommen werden, falls vorhanden.

fc_7:
 tst      d6
 bmi.b    fc_12
 tst      d7
 bmi.b    fc_12
 clr.w    (sp)                * Datum der Quelldatei holen
 move.w   d6,-(sp)
 pea      DATE_TIME(a6)
 gemdos   Fdatime
 addq.l   #8,sp

* ACHTUNG: Gemdos- Fehler erfordert Schlieûen und Wieder-ôffnen !!!
* Wenn t_flag = TRUE (TOUCH), wird die Uhrzeit nicht kopiert

 move     d+t_flag(pc),d0
 bne.b    fc_12

 IFF      KAOS
 move.w   d7,d0
 bsr      close               * Zieldatei schlieûen
 clr.w    d0
 move.l   a4,a0
 bsr      open                * Zieldatei wieder îffnen
 move.l   d0,d7
 bmi.b    fc_12
 ENDC

 move.w   #1,(sp)             * Datum der Zieldatei setzen
 move.w   d7,-(sp)
 pea      DATE_TIME(a6)
 gemdos   Fdatime
 addq.l   #8,sp
fc_12:
 move.w   d6,d0
 bsr      close
 move.w   d7,d0
 bsr      close
 clr.w    d0                  * kein Fehler
 bra.b    fc_90
fc_70:
 bsr      strcon              * Fehlermeldung ausgeben und Ende
fc_80:
 bsr      inc_errlv
 moveq    #1,d0
fc_90:
 bsr      free_tpa
 tst.l    (sp)+
 movem.l  (sp)+,d3/d4/d6/d7/a3/a4/a5
 unlk     a6
 rts


*    DATA
syntaxrens:   DC.B  'Syntax: MV Quelle Ziel',$d,$a,0
syntaxcopys:  DC.B  'Syntax: COPY [-t] Quelle Ziel',$d,$a,0
unerlcopy_s:  DC.B  'UngÅltiges COPY',$d,$a,0
unerlren_s:   DC.B  'UngÅltiges MV',$d,$a,0
ndateiens:    DC.B  ' Datei(en) kopiert',$d,$a,0
*    TEXT
     EVEN

DTA        SET  -44            * char DTA[44]
ZIELPFAD   SET  DTA-150        * char ZIELPFAD[150]
STRING1    SET  ZIELPFAD-150   * char STRING1[150]
STRING2    SET  STRING1-150    * char STRING2[150]
ZIELDATEI  SET  STRING2-170    * char ZIELDATEI[170]
QUELLDATEI SET  ZIELDATEI-170  * char QUELLDATEI[170]

mv_com:
 moveq    #0,d0
 bra.b    copy_ren
copy_com:
 lea      d+t_flag(pc),a1
 clr      (a1)                * per Default Datum mitkopieren
 cmpi.w   #2,SP_ARGC(sp)      * keine Parameter
 blt.b    cp_1
 move.l   SP_ARGV(sp),a0
 move.l   4(a0),a0            * erster Parameter
 cmpi.b   #'-',(a0)+          * Switch ?
 bne.b    cp_1
 move.b   (a0)+,d0
 bsr      d0_upper
 cmpi.b   #'T',d0
 bne.b    cp_1
 tst.b    (a0)                * "-T" durch EOS abgeschlossen ?
 bne.b    cp_1
 st       (a1)                * t_flag setzen
 addq.l   #4,SP_ARGV(sp)
 subq.w   #1,SP_ARGC(sp)      * ersten Parameter Åberspringen
cp_1:
 moveq    #1,d0
copy_ren:
 link     a6,#QUELLDATEI
 movem.l  d3/d4/d5/d6/d7/a5/a4/a3,-(sp)
 lea      ZIELDATEI(a6),a5
 move     d0,d7               * Flag = 1 (COPY), 0 (REN)
 move.l   ARGV(a6),a0
 move.l   4(a0),a3            * erster  Parameter (Quelle)
 move.l   8(a0),a4            * zweiter Parameter (Ziel)
 move.l   a3,a0
 bsr      isdevice            * Quelle = 'CON:', 'AUX:' oder 'PRN:' ?
 move.w   d0,d3
 bsr      crlf_con
 clr.w    d6
 lea      syntaxcopys(pc),a0
 tst      d7
 bne.b    cr_30
 lea      syntaxrens(pc),a0
cr_30:
 cmpi.w   #2,ARGC(a6)
 blt.b    cr_4                  * keine Parameter => error
 bne.b    cr_3                  * 2 oder mehr => cr_3
 movea.l  a3,a1               * nur ein Parameter
cr_2:
 tst.b    (a1)+
 bne.b    cr_2
 move.l   a1,a4               * zweiten Parameter setzen
 gemdos   Dgetdrv
 addq.l   #2,sp
* move.w   d0,d0
 move.l   a4,a0
 bsr      drive_to_defpath    * als zweiter Parameter aktueller Pfad
cr_3:
 lea      ZIELPFAD(a6),a1
 move.l   a4,a0               * prÅfe, ob Ziel ein Pfadname ist
 bsr      checkpath
 move.w   d0,d4

 IFF      KAOS
 move.l   a3,a0
 bsr      str_to_drive        * Diskwechsel erkennen
 ENDC

 lea      STRING1(a6),a2
 lea      STRING2(a6),a1
 move.l   a3,a0
 bsr      split_path          * fÅr Quelle
 tst.w    d3
 beq.b    cr_20

 move.b   #':',STRING2+3(a6)
 clr.b    STRING2+4(a6)
 move.b   #':',STRING1+3(a6)
 clr.b    STRING1+4(a6)

* IFF      KAOS
* clr.b    STRING2+4(a6)       * im Falle 'CON:' usw. ausgleichen
* clr.b    STRING1+4(a6)
* ENDC
* IF       KAOS
* clr.b    STRING2+3(a6)       * im Falle 'CON' usw. ausgleichen
* clr.b    STRING1+3(a6)
* ENDC

 clr.b    DTA+30(a6)
cr_20:
 tst.w    d0
 bne.b    cr_5
 move.l   a3,a0               * <Quelle> nicht gefunden
 bsr      strcon
 lea      not_founds(pc),a0
cr_4:
 bsr      strcon              * Fehlermeldung ausgeben und Ende
 bsr      inc_errlv
 bra      cr_end
cr_5:
 lea      STRING2(a6),a0
 bsr      enth_jok
 move.w   d0,d5
 move.l   a4,a0               * zweiten Parameter (Ziel) prÅfen
 bsr      enth_jok
 lea      unerlcopy_s(pc),a0
 tst.w    d7
 bne.b    cr_31
 lea      unerlren_s(pc),a0
cr_31:
 tst.w    d0
 bne.b    cr_4                  * Ziel enthÑlt Joker '*' oder '?'

 IFF      KAOS
 move.l   a4,a0               * Ziel ist GerÑt ?
 bsr      isdevice
 tst.w    d0
 beq.b    cr_32
 tst.w    d7
 beq.b    cr_4                  * bei REN GerÑt als Ziel ungÅltig
 ENDC

cr_32:
 tst.w    d5
 beq.b    cr_6
 tst.w    d4
 beq.b    cr_4
cr_6:
 tst.w    d3
 bne.b    cr_7                            * Quelle ist Standard- Device

 lea      DTA(a6),a1
 moveq    #6,d0                         * Dateityp = alle auûer Subdir
 lea      STRING2(a6),a0
 bsr      sfirst
 beq.b    cr_7

 lea      keine_dateiens+3(pc),a0       * "Keine Dateien"
 bsr      strcon
 lea      crlfs(pc),a0
 bra.b    cr_4
cr_7:
 lea      STRING1(a6),a1                * Pfad der Quelldatei
 lea      QUELLDATEI(a6),a0
 bsr      strcpy
 lea      DTA+30(a6),a1
 lea      QUELLDATEI(a6),a0
 bsr      strcat
 lea      QUELLDATEI(a6),a0
 bsr      str_upper
 tst.w    d5
 bne.b    cr_8
 tst.w    d4
 beq.b    cr_9
cr_8:
 lea      ZIELPFAD(a6),a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcpy
 lea      DTA+30(a6),a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcat
 bra.b    cr_10
cr_9:
 move.l   a4,a1
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      strcpy
cr_10:
 move.l   a5,a0               * ZIELDATEI(a6)
 bsr      str_upper
 move.l   a5,-(sp)            * ZIELDATEI(a6)
 pea      QUELLDATEI(a6)
 lea      filecopy(pc),a0
 tst.w    d7
 bne.b    cr_22
 lea      fileren(pc),a0
cr_22:
 jsr      (a0)
 addq.l   #8,sp
 tst.w    d0
 bne.b    cr_11
 addq.w   #1,d6
 tst.w    d3
 bne.b    cr_11                    * Quelle war Standard- Device

 lea      DTA(a6),a0
 bsr      snext
 beq      cr_7

cr_11:
 tst.w    d7
 beq.b    cr_end
 lea      STRING1(a6),a4
 bsr      crlf_con
 move.l   a4,a0
 ext.l    d6
 move.l   d6,d0
 bsr      long_to_str
 move.l   a4,a0
 bsr      strcon
 lea      ndateiens(pc),a0
 bsr      strcon
cr_end:
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4/d3
 unlk     a6
 rts


* void wholepath(a0 = char string[])
*  Wandelt eine Pfad- + Dateiangabe in den vollstÑndigen Pfad
*  (mit Laufwerk, ab Root) um.

STRING    SET  -200

wholepath:
 link     a6,#STRING
 movem.l  a4/a5,-(sp)
 movea.l  a0,a5
 bsr      str_upper
 lea      STRING(a6),a4
 move.l   a5,a0
 bsr      str_to_drive        * Laufwerksbezeichnung aus Pfad holen
 move.l   a4,a0
* move.w   d0,d0
 bsr      drive_to_defpath    * FÅr dieses Laufwerk Default- Pfad holen
 bsr      fatal
 move.l   a4,a0
 bsr      strlen
 lea      0(a4,d0.l),a0       * a0 = Ende des Strings
 move.l   a5,a2
 cmpi.b   #'\',-1(a0)         * Endet Default- Path mit '\' ?
 beq.b    wpt_1
 move.b   #'\',(a0)+
 clr.b    (a0)
wpt_1:
 cmpi.b   #':',1(a5)
 bne.b    wpt_2
 addq.l   #2,a2
wpt_2:
 cmpi.b   #'\',(a2)
 beq.b    wpt_end
 move.l   a2,a1
 move.l   a4,a0
 bsr      strcat
 move.l   a4,a1
 move.l   a5,a0
 bsr      strcpy
wpt_end:
 movem.l  (sp)+,a4/a5
 unlk     a6
 rts


* int number_a5(a5 = char *string, d0 = int default)
*  Zeiger auf einen Stringzeiger in a5 als Ein- und Ausgabe
*  Rechnet den String in einen int- Wert um und gibt diesen zurÅck.
*  Ist der String = "", wird <default> zurÅckgegeben.
*  Der Stringzeiger a5 wird nach Einlesen auf den Beginn der nÑchsten
*  Zahl gestellt.

number_a5:
 tst.b    (a5)
 beq.b    numa5_5
 clr.w    d0
 bra.b    numa5_2
numa5_1:
 muls     #10,d0
 add.w    d1,d0
numa5_2:
 move.b   (a5)+,d1            * Zeichen aus String holen
 ext.w    d1
 subi.w   #'0',d1
 cmpi.w   #9,d1
 bls.b    numa5_1
 subq.l   #1,a5               * a1 auf erstes nichtnumerisches Zeichen
numa5_3:
 move.b   (a5)+,d1
 beq.b    numa5_6
 subi.b   #'0',d1
 cmpi.b   #9,d1
 bhi.b    numa5_3
numa5_6:
 subq.l   #1,a5
numa5_5:
 rts


*    DATA
akt_date_is:     DC.B  $d,$a,'Aktuelles Datum ist ',0
give_dates:      DC.B  $d,$a,'Neues Datum (tt/mm/jj) : ',0
akt_time_is:     DC.B  $d,$a,'Aktuelle Zeit ist ',0
give_times:      DC.B  $d,$a,'Neue Zeit (hh:mm:ss) : ',0
falsches_forms:  DC.B  $d,$a,'Falsches Format',$d,$a,0
*    TEXT
     EVEN

STRING         SET  -140

time_com:
 lea      akt_time_is(pc),a0
 lea      time_to_str(pc),a1
 lea      give_times(pc),a2
 moveq    #Tgettime,d0
 moveq    #$3f,d2
 moveq    #0,d1
 bra.b    da_ti
date_com:
 lea      akt_date_is(pc),a0
 lea      date_to_str(pc),a1
 lea      give_dates(pc),a2
 moveq    #Tgetdate,d0
 moveq    #$f,d2
 moveq    #1,d1
da_ti:
 link     a6,#STRING
 movem.l  d4/d5/d6/d7/a5,-(sp)
 move.w   d0,d5
 move.w   d1,d4
 move.w   d2,d6
 movea.l  ARGV(a6),a5
 move.l   4(a5),a5
 subq.w   #2,ARGC(a6)              * mindestens ein Parameter
 bge.b    timec_1
*
* Falls kein Parameter eingegeben wurde, wird von STDIN gelesen
*
 lea      STRING(a6),a5
* move.l a0,a0
 move.l   a2,-(sp)
 move.l   a1,-(sp)
 bsr      strstdout
 move.l   (sp)+,a1
 move.l   a5,a0
 jsr      (a1)                     * date/time_to_str
 move.l   a5,a0
 bsr      strstdout
 move.l   (sp)+,a0
 bsr      strcon
 move.l   a5,a0
 clr.w    d0
 bsr      read_str
 tst.b    (a5)
 beq      dati_20
*
* Aktuelle Zeit/Datum in TMJ bzw. SMS zerlegen (d5,d6,d7)
*
timec_1:
 move.w   d5,-(sp)       * Tgettime/Tgetdate
 trap     #1
 addq.l   #2,sp
 move.w   d0,d5
 and.w    #$1f,d5        * d5 = aktueller Tag
 moveq    #1,d1
 sub.w    d4,d1
 asl.w    d1,d5          * Sekunden
 lsr.w    #5,d0
 and.w    d0,d6
 moveq    #6,d1
 sub.w    d4,d1
 sub.w    d4,d1
 lsr.w    d1,d0
 move.w   d0,d7          * d7 = aktuelles Jahr
 tst.w    d4
 beq.b    dati_2
 add.w    #1980,d7
 bra.b    dati_3
dati_2:
 exg      d7,d5
*
* String in Zahlen umwandeln. d5,d6,d7 als Default.
*
dati_3:
 move.w   d5,d0
 bsr      number_a5      * lies Tag ein
 move.w   d0,d5          * Tag nach d5
 move.w   d6,d0
 bsr      number_a5      * lies Monat ein
 move.w   d0,d6          * Monat nach d6
 move.w   d7,d0
 bsr      number_a5      * lies Jahr ein
 move.w   d0,d7          * Jahr nach d7
*
* d5,d6,d7 wieder packen und Uhrzeit/Datum setzen
*
 tst.w    d4
 beq.b    dati_4
 subi.w   #1980,d7
 bge.b    dati_5
 addi.w   #1900,d7
 bgt.b    dati_5
 addi.w   #100,d7
dati_5:
 moveq    #Tsetdate,d2
 moveq    #4,d1
 bra.b    dati_6
dati_4:
 exg      d5,d7
 asr.w    #1,d5          * Sekunden
 moveq    #Tsettime,d2
 moveq    #6,d1
dati_6:
 move.w   d7,d0
 lsl.w    d1,d0
 or.w     d6,d0
 lsl.w    #5,d0
 or.w     d5,d0
 move.w   d0,-(sp)
 move.w   d2,-(sp)
 trap     #1
 addq.l   #4,sp
 tst.l    d0
 bge.b    dati_20
 bsr      inc_errlv
 lea      falsches_forms(pc),a0
 bsr      strcon
dati_20:
 movem.l  (sp)+,a5/d7/d6/d5/d4
 unlk     a6
 rts


* int unlink(dateiname)
*  Lîscht eine Datei, deren Name als Parameter Åbergeben wurde
*  Ist query_flag != 0, wird vorher die Sicherheitsfrage gestellt
*  RÅckgabe 1, wenn Fehler aufgetreten

*    DATA
loesch_s:  DC.B  $d,$a,'Lîsche ',0
auswahl_s: DC.B  ' (J/N/G/A) ? ',0
global_s:  DC.B  'Global',0
nein_s:    DC.B  'Nein',0
ja_s:      DC.B  'Ja',0
quit_s:    DC.B  'Abbruch',0
dels:      DC.B  $d,$a,'DEL ',0
*    TEXT
     EVEN

unlink:
 link     a6,#-4
 move.b   d+query_flag(pc),d0
 beq      unl_6
 lea      loesch_s(pc),a0
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      auswahl_s(pc),a0
 bsr      strcon
unl_9:
 gemdos   Cnecin
 addq.l   #2,sp
 bsr      d0_upper

 IFF      KAOS
 cmpi.b   #3,d0
 beq.b    unl_2
 ENDC

 cmpi.b   #'G',d0
 beq.b    unl_3
 cmpi.b   #'A',d0
 beq.b    unl_4
 cmpi.b   #'Q',d0
 beq.b    unl_4
 cmpi.b   #'J',d0
 beq.b    unl_5
 cmpi.b   #'Y',d0
 beq.b    unl_5
 cmpi.b   #'N',d0
 bne.b    unl_9
 lea      nein_s(pc),a0            * Nein
 bsr      strcon
 clr.w    d0
 bra.b    unl_7

 IFF      KAOS
unl_2:
 bra      break     * CTRL-C
 ENDC

unl_3:
 lea      d+query_flag(pc),a0
 clr.b    (a0)                     * Global: Flag fÅr Sicherheitsfrage lîschen
 lea      global_s(pc),a0
 bra.b    unl_1
unl_4:
 lea      quit_s(pc),a0            * Quit
 bsr      strcon
 moveq    #1,d0
 bra.b    unl_7
unl_5:
 lea      ja_s(pc),a0              * Ja
unl_1:
 bsr      strcon
unl_6:
 move.l   8(a6),(sp)
 gemdos   Fdelete
 addq.l   #2,sp
 tst.l    d0
 bge.b    unl_8                       * alles ok
 move.w   d0,-(sp)
 bsr      crlf_con
 move.w   (sp)+,d0
 bsr      print_err
 lea      auf_s(pc),a0             * Fehler
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 bsr      inc_errlv
 bra.b    unl_10
unl_8:
 move.b   d+query_flag(pc),d0
 bne.b    unl_10
 lea      dels(pc),a0
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
unl_10:
 clr.w    d0
unl_7:
 unlk     a6
 rts


*    DATA
syntax_dels: DC.B  $d,$a,'Syntax: DEL [-n] datei1 ...',$d,$a,0
*    TEXT
     EVEN

STRING1   SET  -150                * char *STRING1[150]
STRING2   SET  STRING1-150         * char *STRING2[150]

del_com:
 link     a6,#STRING2
 movem.l  a5/d7,-(sp)
 moveq    #1,d7                    ; kein N- Flag
 subq.w   #1,ARGC(a6)
 bgt.b    del_1
 lea      syntax_dels(pc),a0
 bsr      strcon
 bsr      inc_errlv
 bra.b    del_end
del_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5
 move.l   a5,a0
 cmpi.b   #'-',(a0)+
 bne.b    del_4
 move.b   (a0)+,d0
 bsr      d0_upper
 cmpi.b   #'N',d0
 bne.b    del_4
 move.b   (a0),d0
 bne.b    del_4
* "-N"
 moveq    #0,d7
 bra.b    del_3                       ; nÑchste Datei
del_4:
 lea      STRING1(a6),a2
 lea      STRING2(a6),a1
 move.l   a5,a0
 bsr      split_path
 tst.w    d0
 beq.b    del_2
 lea      STRING2(a6),a0
 bsr      enth_jok
del_2:
 lea      d+query_flag(pc),a0
 and.b    d7,d0
 move.b   d0,(a0)
 lea      unlink(pc),a1  * auszufÅhrende Routine
 moveq    #6,d0          * Dateityp = alle auûer Subdir
 move.l   a5,a0          * Dateiname(nsmuster)
 bsr      for_all
 bne.b    del_3
 bsr      crlf_con
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      strcon
 bsr      inc_errlv
del_3:
 subq.w   #1,ARGC(a6)
 bne.b    del_1
 bsr      crlf_con
del_end:
 movem.l  (sp)+,a5/d7
 unlk     a6
 rts


* int dir_entry(name,dta)
* char *name, *dta;
*  Speichert den wichtigen Teil des DTA- Puffers fÅrs spÑtere Sortieren ab.

MAXDIR    EQU  512            * Maximal 512 Directory- EintrÑge

dir_entry:
 moveq    #1,d0
 lea      d+dir_zeilen(pc),a0
 cmpi.w   #MAXDIR,(a0)
 bge.b    dire_end              * Zuviele EintrÑge
 addq.w   #1,(a0)             * Anzahl der EintrÑge mitzÑhlen
 move.l   d+zeiger_adr(pc),a0
 lea      d+puffer_adr(pc),a2
 move.l   (a2),a1
 move.l   a1,(a0)+            * Zeiger auf Inhalt sichern
 move.l   a0,zeiger_adr-puffer_adr(a2)
 moveq    #44-20-1,d0         * sizeof(struct dta)-20(unwichtige Daten)
 move.l   8(sp),a0
 adda.w   #20,a0
dire_1:
 move.b   (a0)+,(a1)+         * Inhalt sichern
 dbra     d0,dire_1
 move.l   a1,(a2)             * neues Pufferende setzen
 clr.w    d0
dire_end:
 rts


* void dir_entry_print(filler, eintrag)
* long filler;
* DTA  *eintrag;
*  Druckt einen Directory- Eintrag (DTA-Struktur)
*  Er wird mit CR/LF abgeschlossen, wenn das w-Flag NICHT gesetzt war

*    DATA
space3_s:        DC.B  '   ',0
dir_zeichens:    DC.B  '   <DIR>',0
*    TEXT
     EVEN

dir_entry_print:
 link     a6,#0
 movem.l  d6/d7/a5/a4,-(sp)
 lea      d+dir_zeilen(pc),a0
 addq.w   #1,(a0)
 move.w   (a0),d6
 ext.l    d6
 movea.l  $c(a6),a5                * a5 = DTA
 btst     #4,21(a5)                          * Subdirectory ?
 bne.b    dep_30
 move.l   26(a5),d0
 add.l    d0,normal_len-dir_zeilen(a0)       * LÑnge akkumulieren
 addq.w   #1,normal_no-dir_zeilen(a0)        * Anzahl Dateien
dep_30:
 lea      leers(pc),a4
 cmpi.b   #'.',30(a5)              * Name beginnt mit '.'
 beq.b    dep_1
 moveq    #'.',d0
 lea      30(a5),a0      * Dateiname
 bsr      chrsrch
 beq.b    dep_1
 move.l   d0,a4          * a4 zeigt auf die Extension, sonst ""
 clr.b    (a4)+          * Den Punkt im Dateinamen lîschen
dep_1:
* Dateiname ausgeben
 move.b   d+w_flag(pc),d1
 beq.b    dep_12
 moveq    #' ',d0
 btst     #4,21(a5)                * Subdirectory ?
 beq.b    dep_13
 moveq    #'#',d0
dep_13:
 bsr      putchar
dep_12:
 lea      30(a5),a0
 bsr      strstdout                * Dateiname
 lea      30(a5),a0
 bsr      strlen
 move.w   #9,d7
 sub.w    d0,d7
 bra.b    dep_20
dep_21:
 moveq    #' ',d0
 bsr      putchar
dep_20:
 dbra     d7,dep_21
* Extension ausgeben
 move.l   a4,a0
 bsr      strstdout                * Extension
 move.l   a4,a0
 bsr      strlen
 move.w   #3,d7
 sub.w    d0,d7
 bra.b    dep_23
dep_22:
 moveq    #' ',d0
 bsr      putchar
dep_23:
 dbra     d7,dep_22
* Jetzt wird unterschieden, ob kurze oder lange Darstellung
 move.b   d+w_flag(pc),d1
 beq.b    dep_4
 move.l   d6,d0
 ext.l    d0
 divs     #5,d0
 swap     d0
 lea      space3_s(pc),a0
 tst.w    d0
 bne.b    dep_2
 lea      crlfs(pc),a0
dep_2:
 move.w   #115,d0
 bra      dep_7
* Jetzt kommt die lange Darstellung
dep_4:
 btst     #4,21(a5)                * Subdirectory ?
 beq.b    dep_5
 lea      dir_zeichens(pc),a0      * Ja
 bsr      strstdout
 bra.b    dep_25
dep_5:
 moveq    #8,d1
 move.l   26(a5),d0                * Grîûe
 bsr      rwrite_long
dep_25:
 move.w   24(a5),d7                * Datum
 move.w   d7,d0
 andi.w   #$1f,d0
* Tag ausgeben (4 Zeichen, ohne fÅhrende '0')
 moveq    #4,d1
 ext.l    d0
 bsr      rwrite_long
* Minuszeichen ausgeben
 moveq    #'-',d0
 bsr      putchar
 lsr.w    #5,d7
 move.w   d7,d0
 andi.w   #$f,d0
* Monat ausgeben (2 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #2,d1
 ext.l    d0
 bsr      write_long
 lsr.w    #4,d7
 addi.w   #1980,d7
* Minuszeichen ausgeben
 moveq    #'-',d0
 bsr      putchar
* Jahr ausgeben (4 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #4,d1
 ext.l    d7
 move.l   d7,d0
 bsr      write_long
 move.w   22(a5),d7      * Zeit
 lsr.w    #5,d7          * Sekunden vergessen
* Stunden ausgeben (4 Zeichen, ohne fÅhrende '0')
 moveq    #4,d1
 move.w   d7,d0
 lsr.w    #6,d0
 ext.l    d0
 bsr      rwrite_long
* Doppelpunkt ausgeben
 moveq    #':',d0
 bsr      putchar
* Minuten ausgeben (2 Zeichen, mit fÅhrender '0')
 moveq    #'0',d2
 moveq    #2,d1
 andi.w   #$3f,d7
 ext.l    d7
 move.l   d7,d0
 bsr      write_long
 move.b   d+s_flag(pc),d0
 beq.b    dep_14
 lea      space3_s+1(pc),a0
 bsr      strstdout
 clr.w    d0
 move.b   21(a5),d0
 bsr      print_attr
dep_14:
* mit crlf abschlieûen
 lea      crlfs(pc),a0
 move.w   #20,d0
dep_7:
 divu     d0,d6
 swap     d6
 bsr      strstdout
 move.b   d+p_flag(pc),d0
 beq.b    dep_11
 tst.w    d6
 bne.b    dep_11
 lea      taste_drueckens(pc),a0
 bsr      strcon
 bra.b    dep_9
dep_8:
 gemdos   Cnecin
 addq.l   #2,sp
dep_9:
 gemdos   Cconis
 addq.l   #2,sp
 tst.w    d0
 bne.b    dep_8
 gemdos   Cnecin
 addq.l   #2,sp

 IFF      KAOS

 cmpi.b   #3,d0               * CTRL-C ?
 beq      break

 ENDIF

 lea      dellines(pc),a0
 bsr      strcon
dep_11:
 clr.w    d0
 movem.l  (sp)+,a5/a4/d7/d6
 unlk     a6
 rts


* int cmp_dta(a0 = char *eintrag1, a1 = char *eintrag2)
*  Vergleicht zwei Directory- EintrÑge (ab Byte 21)
*  sort_mode : 'A'    nach Art (Extension)
*              'G'    nach Grîûe
*              'D'    nach Datum/Zeit
*              sonst: nach Namen

cmp_dta:
 move.b   sort_mode(pc),d2
 btst     #4,21-20(a0)   * Attribut = Subdir ?
 beq.b    cmpd_1             * nein
 btst     #4,21-20(a1)
 bne.b    cmpd_2             * Beides Subdirs => sortiere nach Namen
* Jetzt ist e1 subdir, e2 nicht => e2 > e1
 moveq    #-1,d0
 bra      cmpd_end
cmpd_1:
 btst     #4,21-20(a1)
 beq.b    cmpd_3             * Beides normale Dateien
* Jetzt ist e1 normal, e2 Subdir => e2 < e1
 moveq    #1,d0
 bra      cmpd_end
cmpd_3:
 cmpi.w   #'G',d2
 bne.b    cmpd_6
 move.l   26-20(a1),d1   * nach Grîûe sortieren
 sub.l    26-20(a0),d1
cmpd_12:
 tst.l    d1
 beq.b    cmpd_2             * Grîûe oder Datum+Zeit gleich => Namensvergleich
 moveq    #1,d0
 tst.l    d1
 bgt.b    cmpd_5             * erster Eintrag grîûer
 moveq    #-1,d0
cmpd_5:
 bra.b    cmpd_end
cmpd_6:
 cmpi.w   #'A',d2
 bne.b    cmpd_10
 movem.l  a0/a1,-(sp)
 adda.w   #30-20,a0      * Zeiger auf den Namen
 adda.w   #30-20,a1
cmpd_7:
 tst.b    (a0)
 beq.b    cmpd_8
 cmpi.b   #'.',(a0)+
 bne.b    cmpd_7
cmpd_8:
 tst.b    (a1)
 beq.b    cmpd_9
 cmpi.b   #'.',(a1)+
 bne.b    cmpd_8
cmpd_9:
* move.l   a1,a1
* move.l   a0,a0
 bsr      strcmp
 movem.l  (sp)+,a0/a1
 bne.b    cmpd_end
 bra.b    cmpd_2             * Typ gleich => Namensvergleich
cmpd_10:
 cmpi.w   #'D',d2
 beq.b    cmpd_13
cmpd_2:
 lea      30-20(a1),a1   * Namen vergleichen
 lea      30-20(a0),a0
 bsr      strcmp
 bra.b    cmpd_end
cmpd_13:
 move.w   24-20(a1),d1   * Datum vergleichen
 sub.w    24-20(a0),d1
 ext.l    d1
 bne.b    cmpd_11            * Wie bei LÑnge
 move.w   22-20(a1),d1   * Datum gleich => Zeit vergleichen
 sub.w    22-20(a0),d1
 ext.l    d1
cmpd_11:
 bra.b    cmpd_12
cmpd_end:
 rts


*    DATA
verzchn_vons:   DC.B  ' Verzeichnis von ',0
n_dbytes:       DC.B  '  Bytes in',0
n_dateiens:     DC.B  ' Datei(en)',0
*    TEXT
     EVEN

STRING         SET  -(16+150+200)       * char STRING[200]
DUMMYSTRING    SET  -(16+150)           * char DUMMYSTRING[150]
DFREE_BUFFER   SET  -16                 * long DFREE_BUFFER[4]

dir_com:
 link     a6,#STRING
 movem.l  d7/a3/a4/a5,-(sp)
 lea      d+w_flag(pc),a3
 clr.w    (a3)
 clr.b    q_flag-w_flag(a3)
 clr.b    s_flag-w_flag(a3)
 clr.l    normal_len-w_flag(a3)
 clr.w    normal_no-w_flag(a3)
* clr.b    w_flag
* clr.b    p_flag
* clr.b    q_flag
 bsr      memavail
 move.l   #MAXDIR*28,d1       * 512 Eintr. * (24 Byt. LÑnge + 4 Byt. Zeiger)
 suba.l   a4,a4
 cmp.l    d1,d0
 bcs.b    dir_30
 move.l   d1,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq      dir_end
 move.l   d0,a4               * a4 ist Pufferadresse
dir_30:
 subq.w   #1,ARGC(a6)
 bgt.b    dir_1
 movea.l  ARGV(a6),a0
 lea      star_pt_star(pc),a1   * "*.*"
 move.l   a1,4(a0)
 move.w   #1,ARGC(a6)
dir_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5                  * a5[] ist Parameter
 cmpi.b   #'-',(a5)
 bne.b    dir_6
 addq.l   #1,a5
dir_13:
 move.b   (a5)+,d0
 bsr      d0_upper
 cmpi.b   #'W',d0                  * "WIDE" = breite Ausgabe
 bne.b    dir_2
 st       (a3)
 bra.b    dir_4
dir_2:
 cmpi.b   #'P',d0                  * "PAGE" = seitenweise Ausgabe
 bne.b    dir_10
 st       p_flag-w_flag(a3)
 bra.b    dir_4
dir_10:
 cmpi.b   #'S',d0                  * "SYSTEM" = alle Dateien + Attribute
 bne.b    dir_3
 st       s_flag-w_flag(a3)
 bra.b    dir_4
dir_3:
 cmpi.b   #'Q',d0                  * "QUICK" = ohne freier Speicher
 bne.b    dir_5
 st       q_flag-w_flag(a3)
 bra.b    dir_4
dir_5:
 lea      sort_mode(pc),a0
 move.b   d0,(a0)                  * Falls weder -W noch -P noch -Q, dann Sortiermodus
dir_4:
 tst.b    (a5)
 bne.b    dir_13
 cmpi.w   #1,ARGC(a6)
 bne      dir_11
 addq.w   #1,ARGC(a6)
 movea.l  ARGV(a6),a0
 lea      star_pt_star(pc),a1 * "*.*"
 move.l   a1,4(a0)
 bra      dir_11
*
* Verzeichnis ausgeben
*
dir_6:
 cmpi.w   #1,ARGC(a6)
 beq.b    dir_32
 st       q_flag-w_flag(a3)   * mehrere Verzeichnisse: q- Flag setzen
dir_32:
 move.l   a5,a0
 bsr      str_to_drive
 move.w   d0,d7               * d7 enthÑlt den Laufwerks- Code
 blt      dir_11                 * Fehler => nÑchstes Argument
 tst.b    q_flag-w_flag(a3)
 bne.b    dir_7
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree
 addq.l   #8,sp
 bsr      fatal
 move.w   d7,d0
 bsr      label_to_stdout
 bra.b    dir_14
dir_7:
 bsr      crlf_stdout
dir_14:
 lea      DUMMYSTRING(a6),a2
 lea      STRING(a6),a1
 move.l   a5,a0
 bsr      split_path
 lea      verzchn_vons(pc),a0      * "Verzeichnis von "
 bsr      strstdout
 lea      STRING(a6),a0
 bsr      wholepath
 lea      STRING(a6),a0
 bsr      strstdout
 lea      sort_mode(pc),a0
 move.l   a4,d0                    * Speicher da ?
 bne.b    dir_31
 move.b   #'U',(a0)                * kein Speicher => nicht sortieren
dir_31:
 move.b   (a0),d0
 lea      nach_art_s(pc),a0
 cmpi.b   #'A',d0
 beq.b    dir_16
 lea      nach_grs_s(pc),a0
 cmpi.b   #'G',d0
 beq.b    dir_16
 lea      nach_dat_s(pc),a0
 cmpi.b   #'D',d0
 beq.b    dir_16
 lea      nach_nix_s(pc),a0
 cmpi.b   #'U',d0
 bne.b    dir_15
dir_16:
 bsr      strstdout
dir_15:
 bsr      crlf_stdout
 bsr      crlf_stdout
* Jetzt wird das komplette Verzeichnis in den Puffer geschrieben
* oder gleich ausgedruckt, falls <sort_mode> = 'U'(nsortiert)
 move.l   a4,zeiger_adr-w_flag(a3)
 lea      4*MAXDIR(a4),a0
 move.l   a0,puffer_adr-w_flag(a3)
 clr.w    dir_zeilen-w_flag(a3)
 lea      dir_entry(pc),a1
 lea      sort_mode(pc),a0
 cmpi.b   #'U',(a0)
 bne.b    dir_27
 lea      dir_entry_print(pc),a1
dir_27:
 moveq    #$10,d0                  * normale Dateien + Subdir
 tst.b    s_flag-w_flag(a3)
 beq.b    dir_12
 addq.w   #6,d0                    * norm + Subdir + Hid + Syst
dir_12:
 move.l   a5,a0
 bsr      for_all
 lea      keine_dateiens(pc),a0
 beq.b    dir_8
 lea      sort_mode(pc),a0
 cmpi.b   #'U',(a0)
 beq.b    dir_28
*
* Das Verzeichnis wird jetzt sortiert, falls <sort_mode> <> 'U'
*
 move.l   a4,-(sp)
 lea      d+dir_zeilen(pc),a0
 move.w   (a0),d7
 clr.w    (a0)
 ext.l    d7
 move.l   d7,-(sp)
 pea      cmp_dta(pc)        * Vergleichs- Routine
 bsr      sortiere
 adda.w   #12,sp
* Das Verzeichnis wird ausgegeben
 subq.w   #1,d7
 move.l   a4,a5
dir_21:
 move.l   (a5)+,-(sp)
 subi.l   #20,(sp)            * Die Puffer werden nur ab Byte 20 gespeichert
 clr.l    -(sp)
 bsr      dir_entry_print
 addq.l   #8,sp
 dbra     d7,dir_21
*
* Korrektur fÅr w- Format
*
dir_28:
 move.b   d+w_flag(pc),d0
 beq.b    dir_29
 bsr      crlf_stdout
*
* Jetzt noch die Schluûzeilen
*
dir_29:
 cmpi.w   #1,ARGC(a6)              * war letztes Argument ?
 bne.b    dir_11                      * nein
 bsr      crlf_stdout
 moveq    #8,d1
 move.l   d+normal_len(pc),d0
 bsr      rwrite_long
 lea      n_dbytes(pc),a0
 bsr      strstdout
 moveq    #11,d1
 move.w   d+normal_no(pc),d0
 ext.l    d0
 bsr      rwrite_long
 lea      n_dateiens(pc),a0
dir_8:
 bsr      strstdout
 bsr      crlf_stdout
 tst.b    q_flag-w_flag(a3)
 bne.b    dir_11
 moveq    #8,d0
 lea      DFREE_BUFFER(a6),a0
 bsr      print_free
dir_11:
 subq.w   #1,ARGC(a6)
 bne      dir_1
 bsr      free_tpa
dir_end:
 movem.l  (sp)+,a5/a4/a3/d7
 unlk     a6
 rts


pause_com:
 move.l   a5,-(sp)
 move.l   SP_ARGV+4(sp),a5
 addq.l   #4,a5          * a5 auf ersten Parameter (argv[1])
 lea      taste_drueckens(pc),a0
 subq.w   #1,SP_ARGC+4(sp)
 bne.b    pause_1
 move.l   a0,(a5)
pause_1:
 move.l   (a5)+,a0
 bsr      strcon
 moveq    #' ',d0
 bsr      putch
 subq.w   #1,SP_ARGC+4(sp)
 bgt.b    pause_1
 bra.b    pause_4
pause_3:
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
pause_4:
 move.w   #2,-(sp)
 bios     Bconstat
 addq.l   #4,sp
 tst.w    d0
 bne.b    pause_3
 move.w   #2,-(sp)
 bios     Bconin
 addq.l   #4,sp
 cmpi.b   #3,d0          * CTRL-C
 beq      break
 lea      errorlevel(pc),a0
 move.w   d0,(a0)        * Taste merken fÅr Abfrage
 moveq    #CR,d0
 bsr      putch
 move.l   (sp)+,a5
 rts


*    DATA
echo_ists:  DC.B  $d,$a,'ECHO ist ',0
*    TEXT
     EVEN

echo_com:
 movem.l  d7/a5,-(sp)
 sf       d7
echo_7:
 lea      is_echo(pc),a5
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    echo_2
 lea      echo_ists(pc),a0
 bsr      strstdout
 lea      ons(pc),a0               * "ON"
 tst.b    (a5)
 bne.b    echo_1
 lea      offs(pc),a0              * "OFF"
echo_1:
 bsr      strstdout
 bra.b    echo_6
echo_2:
 movea.l  SP_ARGV+8(sp),a0
 move.l   4(a0),a1
 cmpi.b   #'-',(a1)+
 bne.b    echo_5
 move.b   (a1)+,d0
 bsr      d0_upper
 cmpi.b   #'N',d0
 bne.b    echo_5
 tst.b    (a1)
 bne.b    echo_5
* Erstes Argument: "-n" : CR/LF unterdrÅcken
 addq.l   #4,SP_ARGV+8(sp)
 subq.w   #1,SP_ARGC+8(sp)
 st       d7
 bra.b    echo_7
echo_5:
 move.l   4(a0),a0
 bsr      is_off_on
 tst.w    d0
 bmi.b    echo_4                       * negativ => String ausgeben
 sne      (a5)                     * ECHO- Status merken
 bra.b    echo_6
echo_3:
 addq.l   #4,SP_ARGV+8(sp)
 movea.l  SP_ARGV+8(sp),a0
 move.l   (a0),a0
 bsr      strstdout
 cmpi.w   #1,SP_ARGC+8(sp)
 beq.b    echo_4
 moveq    #' ',d0
 bsr      putchar
echo_4:
 subq.w   #1,SP_ARGC+8(sp)
 bne.b    echo_3
echo_6:
 tst.b    d7
 bne.b    echo_8
 bsr      crlf_stdout
echo_8:
 movem.l  (sp)+,a5/d7
 rts


*    DATA
rmd_syntaxs: DC.B  $d,$a,'Syntax: MD/RD Verzeichnis',$d,$a,0
*    TEXT
     EVEN

rd_com:
 moveq    #Ddelete,d0
 bra.b    rmd_com
md_com:
 moveq    #Dcreate,d0
rmd_com:
 lea      rmd_syntaxs(pc),a0
 cmpi.w   #2,SP_ARGC(sp)      * Genau ein Argument ?
 bne.b    rmd_1
 movea.l  SP_ARGV(sp),a0
 move.l   4(a0),-(sp)
 move.w   d0,-(sp)            * Dcreate oder Ddelete
 trap     #1
 addq.l   #6,sp
 tst.w    d0
 beq.b    rmd_end
 bsr      crprint_err
 bra.b    rmd_50
rmd_1:
 bsr      strcon
rmd_50:
 bsr      inc_errlv
rmd_end:
 rts


*    DATA
ren_syntaxs: DC.B  $d,$a,'Syntax: REN Quelle Name',$d,$a,0
*    TEXT
     EVEN

DEST      SET  -128

ren_com:
 link     a6,#DEST
 movem.l  a4/a5,-(sp)
 cmpi.w   #3,ARGC(a6)         * Genau zwei Argumente ?
 bne.b    ren_1
 movea.l  ARGV(a6),a0
 tst.l    (a0)+
 move.l   (a0)+,a4            * Pfadname (Quelle)
 move.l   (a0),a5             * Dateiname (Ziel)
 move.l   a4,a0
 bsr      enth_jok            * Quelle darf keinen Joker enthalten
 bne.b    ren_1
 move.l   a5,a0
 bsr      enth_jok            * Ziel darf keinen Joker enthalten
 bne.b    ren_1
 moveq    #':',d0
 move.l   a5,a0
 bsr      chrsrch
 bne.b    ren_1
 moveq    #'\',d0
 move.l   a5,a0
 bsr      chrsrch             * Ziel darf keine Pfadangabe enthalten
 bne.b    ren_1
 move.l   a4,a1
 lea      DEST(a6),a2
 move.l   a2,a0
 bsr      strcpy
 move.l   a2,a0
ren_2:
 tst.b    (a2)+
 bne.b    ren_2
ren_3:
 subq.l   #1,a2
 cmpa.l   a2,a0
 bhi.b    ren_5                  * nichts gefunden
 cmpi.b   #':',(a2)
 beq.b    ren_5                  * bis hier geht der Pfad
 cmpi.b   #'\',(a2)
 bne.b    ren_3
ren_5:
 clr.b    1(a2)
 move.l   a5,a1
* move.l   a0,a0
 bsr      strcat
 pea      DEST(a6)
 move.l   a4,-(sp)
 bsr      fileren
 addq.l   #8,sp
 tst.w    d0
 bne.b    ren_50
 bra.b    ren_end
ren_1:
 lea      ren_syntaxs(pc),a0
 bsr      strcon
ren_50:
 bsr      inc_errlv
ren_end:
 movem.l  (sp)+,a4/a5
 unlk     a6
 rts


*    DATA
kein_pfads: DC.B  'Kein Pfad',0
*    TEXT
     EVEN

STRING    SET       -150        * char STRING[150]
DUMMY     SET       -(4+150)

path_com:
 link     a6,#DUMMY
 cmpi.w   #2,ARGC(a6)
 bge.b    path_2
 bsr      crlf_stdout
 lea      pathis(pc),a0            * "PATH="
 bsr      getenv
 bne.b    path_1
 lea      kein_pfads(pc),a0
path_1:
 bsr      strstdout
 bsr      crlf_stdout
 bra.b    path_ende
path_2:
 lea      pathis(pc),a1
 lea      STRING(a6),a0
 bsr      strcpy
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1                 * erster Parameter
set_parameter:
 lea      STRING(a6),a0
 bsr      strcat
 lea      STRING(a6),a0
 bsr      env_set
path_ende:
 unlk     a6
 rts


prompt_com:
 link     a6,#DUMMY
 lea      promptis(pc),a1
 lea      STRING(a6),a0
 bsr      strcpy
 lea      leers(pc),a1
 cmpi.w   #1,ARGC(a6)
 ble.b    prompt_1
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1
prompt_1:
 bra.b    set_parameter       * Siehe path_com


TIME      SET  -4
DATE      SET  -2

touch_file:
 link     a6,#-4
 move.l   d7,-(sp)
 clr.w    d0
 move.l   8(a6),a0
 bsr      open
 move.w   d0,d7                    * nur echte Dateien
 bge.b    tf_2
 lea      kann_s(pc),a0
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      nicht_offn_s(pc),a0
 bsr      strcon
 bsr      inc_errlv
 moveq    #1,d0
 bra.b    tf_50
tf_2:
 move.l   8(a6),a0
 bsr      strcon
 bsr      crlf_con
 gemdos   Tgettime
 addq.l   #2,sp
 move.w   d0,TIME(a6)
 gemdos   Tgetdate
 addq.l   #2,sp
 move.w   d0,DATE(a6)
 move.w   #1,-(sp)
 move.w   d7,-(sp)
 pea      TIME(a6)
 gemdos   Fdatime
 adda.w   #$a,sp
 move.w   d7,d0
 bsr      close
tf_50:
 move.l   (sp)+,d7
 unlk     a6
 rts


*    DATA
datei_s:      DC.B  $d,$a,'Datei: ',0
kann_s:       DC.B  $d,$a,'Kann ',0
nicht_offn_s: DC.B  ' nicht îffnen',$d,$a,0
*    TEXT
     EVEN

type_file:
 link     a6,#0
 movem.l  d6/d7/a5/a4,-(sp)
 bsr      memavail
 move.l   #1024,d6            * maximal 1k reservieren
 tst.l    d0
 beq.b    tyf_3               * kein Speicher frei => Fehler provozieren
 cmp.l    d6,d0               * mehr als 1k frei ?
 bhi.b    tyf_3               * trotzdem nur 1k holen
 move.l   d0,d6               * Sonst gesamten Speicher holen
tyf_3:
 move.l   d6,d0
 bsr      alloc_tpa           * Z=1, wenn Fehler
 beq.b    tyf_12
 move.l   d0,a4               * a4 = Pufferadresse
 lea      datei_s(pc),a0
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 bsr      crlf_con
 bsr      crlf_con
 clr.w    d0
 move.l   8(a6),a0
 bsr      open
 move.l   d0,d7
 bge.b    tyf_2
 lea      kann_s(pc),a0
 bsr      strcon
 move.l   8(a6),a0
 bsr      strcon
 lea      nicht_offn_s(pc),a0
 bsr      strcon
tyf_12:
 bsr      inc_errlv
 moveq    #1,d0
 bra.b    tyf_50
tyf_1:
 move.l   a4,a0
 move.l   d0,d1
 moveq    #STDOUT,d0
 bsr      write
tyf_2:
 move.l   a4,a0
 move.l   d6,d1
 move.w   d7,d0
 bsr      read
 tst.l    d0
 bgt.b    tyf_1
 move.w   d7,d0
 bsr      close
 clr.w    d0
tyf_50:
 bsr      free_tpa
 movem.l  (sp)+,a4/a5/d7/d6
 unlk     a6
 rts


*    DATA
syntax_ts:  DC.B  $d,$a,'Syntax: TYPE|TOUCH Dateiname(n)',$d,$a,0
*    TEXT
     EVEN

touch_com:
 lea      touch_file(pc),a1
 bra.b    t_com
type_com:
 lea      type_file(pc),a1
t_com:
 movem.l  a5/a4,-(sp)
 move.l   a1,a4
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    toty_2
 lea      syntax_ts(pc),a0
 bsr      strcon
 bsr      inc_errlv
 bra.b    toty_end
toty_1:
 addq.l   #4,SP_ARGV+8(sp)
 movea.l  SP_ARGV+8(sp),a0
 movea.l  (a0),a5
 move.l   a4,a1
 moveq    #6,d0
 move.l   a5,a0
 bsr      for_all
 bne.b    toty_2
 bsr      crlf_con
 move.l   a5,a0
 bsr      strcon
 lea      not_founds(pc),a0
 bsr      strcon
toty_2:
 subq.w   #1,SP_ARGC+8(sp)
 bne.b    toty_1
toty_end:
 movem.l  (sp)+,a5/a4
 rts


*    DATA
     IFNE MAGIX
kaos_s:     DC.B  LF,'MagiC v',0
     ELSE
kaos_s:     DC.B  LF,'KAOS v',0
     ENDIF
tos_s:      DC.B  LF,'TOS v',0
gemdos_s:   DC.B  ',  GEMDOS v',0
 IF       ACC
aes_s:      DC.B  'AES v',0
 ENDC
     EVEN
*    TEXT

ver_com:
 lea      kaos_s(pc),a0
 move.b   is_kaos(pc),d0
 bne.b    ver_1
 lea      tos_s(pc),a0
ver_1:
 bsr      strstdout
 move.l   d+c_sysbase(pc),a0
 move.w   os_version(a0),d0
 move.w   os_gendatg(a0),-(sp)
 bsr.b    print_ver
 moveq    #' ',d0
 bsr      putchar
 move.w   (sp)+,d0
 suba.w   #10,sp
 lea      (sp),a0
 bsr      _date_to_str
 lea      (sp),a0
 bsr      strstdout
 adda.w   #10,sp
 lea      gemdos_s(pc),a0
 bsr      strstdout
 gemdos   Sversion
 addq.l   #2,sp
 ror.w    #8,d0                    * Low/High - Byte vertauschen
 bsr.b    print_ver
 bsr      crlf_stdout
 IFF      ACC
 lea      titels(pc),a0
 IFNE     MAGIX
 clr.b    17(a0)
 ELSE
 clr.b    19(a0)
 ENDIF
 bsr      strstdout
 ENDC
 IF       ACC
 lea      aes_s(pc),a0
 bsr      strstdout
 move.w   d+global(pc),d0
 bsr.b    print_ver
 ENDC
 bra      crlf_stdout

print_ver:
 move.w   d0,-(sp)
 lsr.w    #8,d0
 bsr.b    prv_1                       * oberste Ziffer ausgeben
 moveq    #'.',d0                  * '.' ausgeben
 bsr      putchar
 move.w   (sp)+,d0                 * unterste Ziffer ausgeben
prv_1:
 andi.l   #$ff,d0
 bsr      lwrite_long
 rts


*    DATA
status_s:      DC.B  $d,$a,'Flag ist ',0
error_verifys: DC.B  'UngÅltiger Zustand',$d,$a,0
*    TEXT
     EVEN


break_com:
 moveq    #1,d0
 bra.b    vb_com
verify_com:
 moveq    #0,d0
vb_com:
 movem.l  d6/d7,-(sp)
 move     d0,d7
 cmpi.w   #2,SP_ARGC+8(sp)
 bge.b    vb_2
 tst      d7
 bne.b    vb_11
* 1. Fall: Verify- Flag holen
 clr.l    -(sp)
 gemdos   Super          * in Super- Mode
 addq.l   #6,sp
 move.l   d0,-(sp)
 move.w   _fverify,d6
 gemdos   Super          * in User Mode
 addq.l   #6,sp
 bra.b    vb_12
* 2. Fall: Break- Flag holen
vb_11:
 clr.w    -(sp)
 gemdos   Sconfig
 addq.l   #4,sp
 andi.w   #4,d0                    * Bit 2 isolieren
 move     d0,d6
vb_12:
 lea      status_s(pc),a0
 bsr      strstdout
 lea      ons(pc),a0               * "ON"
 tst.w    d6
 bne.b    vb_1
 lea      offs(pc),a0              * "OFF"
vb_1:
 bsr      strstdout
 bsr      crlf_stdout
 bra.b    vb_end
vb_2:
 movea.l  SP_ARGV+8(sp),a0
 move.l   4(a0),a0
 bsr      is_off_on
 move.w   d0,d6
 bge.b    vb_3
 bsr      inc_errlv
 lea      error_verifys(pc),a0
 bsr      strcon
 bra.b    vb_end
vb_3:
 tst      d7
 bne.b    vb_21
* 1. Fall: Verify- Flag setzen
 clr.l    -(sp)
 gemdos   Super          * in Super- Mode
 addq.l   #6,sp
 move.l   d0,-(sp)
 move.w   d6,_fverify
 gemdos   Super          * in User- Mode
 addq.l   #6,sp
 bra.b    vb_end
* 2. Fall: Break Flag setzen
vb_21:
 clr.w    -(sp)                    * Bitvektor holen
 gemdos   Sconfig
 addq.l   #4,sp
 tst      d6
 beq.b    vb_22
 bset     #2,d0
 bra.b    vb_23
vb_22:
 bclr     #2,d0
vb_23:
 move.l   d0,-(sp)
 move.w   #1,-(sp)                 * Bitvektor setzen
 gemdos   Sconfig
 addq.l   #8,sp
vb_end:
 movem.l  (sp)+,d6/d7
 rts


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


* void sortiere(vergleich, anzahl, pointerfeld)
* int (*vergleich)(a0 = void *s1, a1 = void *s2);
* unsigned long anzahl;
* char *pointerfeld[];
*  Sortiert mit Shellsort

sortiere:
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


*    DATA
syntax_sorts:   DC.B  $d,$a,'Syntax: SORT -C -R -n',$d,$a,0
sort_memerrs:   DC.B  $d,$a,'SORT: Zuwenig Speicher',$d,$a,0
sort_zielvolls: DC.B  'SORT: Zieldisk voll',$d,$a,0
*    TEXT
     EVEN

sort_com:
 link     a6,#0
 movem.l  d4/d5/d7/a3/a4/a5,-(sp)
 lea      d+r_flag(pc),a2
 clr.w    (a2)
* clr.b    r_flag
* clr.b    c_flag
 clr.w    schluessel-r_flag(a2)
 bra.b    sort_8
sort_1:
 addq.l   #4,ARGV(a6)
 movea.l  ARGV(a6),a0
 movea.l  (a0),a5
 lea      syntax_sorts(pc),a0
 cmpi.b   #'-',(a5)+
 bne.b    sort_11
 cmpi.b   #'1',(a5)
 blt.b    sort_4
 cmpi.b   #'9',(a5)
 bgt.b    sort_4
 move.l   a5,a0
 bsr      str_toi
 subq.w   #1,d0
 blt.b    sort_4
 move.w   d0,schluessel-r_flag(a2)
sort_4:
 move.b   (a5),d0
 bsr      d0_upper
 cmpi.b   #'R',d0
 bne.b    sort_5
 st       (a2)           * r_flag
sort_5:
 cmpi.b   #'C',d0
 bne.b    sort_8
 st       c_flag-r_flag(a2)
sort_8:
 subq.w   #1,8(a6)
 bne.b    sort_1
 bsr      memavail
 move.l   d0,d5
 beq.b    sort_10
* move.l   d5,d0
 bsr      alloc_tpa                * Z=1, wenn Fehler
 beq.b    sort_50
 move.l   d0,a3
 cmpi.l   #1000,d5
 bcc.b    sort_12
sort_10:
 lea      sort_memerrs(pc),a0
sort_11:
 bsr      strcon
sort_50:
 bsr      inc_errlv
 bra      sort_25
sort_12:
* Zeigerpuffer a4 bis d4, Stringpuffer a5 bis d5
 movea.l  a3,a4          * Anfang des Zeigerpuffers
 move.l   a3,a5
 move.l   d5,d4
 lsr.l    #3,d4
 sub.l    d4,d5          * d5 = LÑnge des Stringpuffers a5[]
 add.l    a4,d4
 move.l   d4,a5          * a5 = Anfang des Stringpuffers
 subq.l   #4,d4          * d4 = Ende des Zeigerpuffers
 add.l    a5,d5
 subq.l   #4,d5          * d5 = Ende des Stringpuffers
 clr.l    d7             * Anzahl gelesener Strings
 move.l   a5,(a4)+       * Adresse des ersten Strings
 bra.b    sort_18
sort_13:
 move.l   a5,a0
 moveq    #1,d1
 moveq    #STDIN,d0      * lies ein Byte von stdin nach a5[]
 bsr      read
 bsr      fatal
 subq.l   #1,d0
 bne.b    sort_21            * Datei- Ende
 cmpi.b   #$1a,(a5)      * EOF ?
 beq.b    sort_21
 cmpi.b   #CR,(a5)       * CR einfach Åberlesen
 beq.b    sort_18
 cmpi.b   #LF,(a5)+
 bne.b    sort_18
 clr.b    -1(a5)         * LF bedeutet EOL => EOL speichern
 addq.l   #1,d7          * Anzahl gelesener Strings
 move.l   a5,(a4)+
sort_18:
 cmpa.l   d5,a5          * a4[] schon voll ?
 bcc.b    sort_10            * Zuwenig Speicher (Stringbereich)
 cmpa.l   d4,a4
 bcc.b    sort_10            * Zuwenig Speicher (Pointerfeld)
 bra.b    sort_13            * weiter einlesen
* Hier ist das Einlesen fertig, und wir kommen zum Sortieren:
sort_21:
 clr.b    (a5)
 move.l   a3,-(sp)                 * Adresse des Pointerfeldes
 move.l   d7,-(sp)                 * Anzahl gelesener Strings = LÑnge desselben
 pea      cmps(pc)                 * Vergleichsfunktion
 bsr      sortiere
 adda.w   #12,sp
 tst.l    d7
 beq.b    sort_25                      * Anzahl ist Null
sort_22:
 move.l   (a3)+,a0
 bsr      strstdout                * String ausgeben
 bsr      crlf_stdout              * CR/LF hinterhersenden
 lea      sort_zielvolls(pc),a0
 bsr      fatal
 subq.l   #1,d0
 bne      sort_11
 subq.l   #1,d7
 bne.b    sort_22
sort_25:
 bsr      free_tpa
sort_end:
 movem.l  (sp)+,a5/a4/a3/d7/d5/d4
 unlk     a6
 rts


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


*    DATA
syntax_finds:  DC.B  $d,$a,'Syntax: FIND string',$d,$a,0
*    TEXT
     EVEN

STRING    SET  -200

find_com:
 link     a6,#STRING
 movem.l  d6/d7/a5/a4,-(sp)
 cmpi.w   #2,ARGC(a6)
 bge.b    find_1
 bsr      inc_errlv
 lea      syntax_finds(pc),a0
 bsr      strcon
 bra.b    find_end
find_1:
 lea      STRING(a6),a5
 movea.l  a5,a4
 move.w   #200,d7
find_2:
 clr.b    1(a5)
 move.l   a5,a0
 moveq    #1,d1
 moveq    #STDIN,d0           * 1 Byte von stdin lesen
 bsr      read
 bsr      fatal
 moveq    #1,d6               * Setze EOF = TRUE
 subq.l   #1,d0
 bne.b    find_4                  * EOF
 cmpi.b   #$1a,(a5)
 beq.b    find_4                  * EOF
 clr.w    d6                  * Setze EOF = FALSE
 cmpi.b   #CR,(a5)
 beq.b    find_3
 cmpi.b   #LF,(a5)
 beq.b    find_4
 addq.l   #1,a5
 subq.w   #1,d7
find_3:
 tst.w    d7
 bne.b    find_2
find_4:
 clr.b    (a5)
 move.l   a4,a1
 movea.l  ARGV(a6),a0
 move.l   4(a0),a0
 bsr      content
 tst.w    d0
 beq.b    find_5
 move.l   a4,a0
 bsr      strstdout
 bsr      crlf_stdout
find_5:
 tst.w    d6
 beq.b    find_1        * noch nicht EOF
find_end:
 movem.l  (sp)+,a5/a4/d7/d6
 unlk     a6
 rts


*    DATA
mehrs:  DC.B  $d,'--Mehr--',0
*    TEXT
     EVEN

more_com:
 movem.l  d7/a5,-(sp)
 lea      _base+$80(pc),a5
 clr.w    d7
 bra.b    more_1
more_2:
 move.b   (a5),d0
 bsr      putchar
 cmpi.b   #$1a,(a5)           * EOF (CTRL-Z)
 beq.b    more_end
 cmpi.b   #LF,(a5)
 bne.b    more_3
 subq.w   #1,d7
 bhi.b    more_3
 lea      mehrs(pc),a0
 bsr      strcon
 clr.w    -(sp)                    ; Platz fÅr 2 Bytes schaffen
 lea      (sp),a0                  ; Puffer
 moveq    #1,d1                    ; 1 Byte lesen
 moveq    #-1,d0                   ; CON:
 bsr      read
 move.w   (sp)+,d7                 ; Zeichen holen
 cmpi.w   #$0300,d7                ; CTRL-C ?
 beq.b    more_end                 ;  ja => Abbruch
 lea      dellines(pc),a0
 bsr      strcon
 cmpi.w   #$2000,d7                ; Leertaste ?
 beq.b    more_1                   ;  ja => eine Seite weiter
 moveq    #1,d7                    ; sonst  eine Zeile weiter
 bra.b    more_3
more_1:
 moveq    #22,d7
more_3:
 move.l   a5,a0
 moveq    #1,d1
 moveq    #STDIN,d0
 bsr      read
 subq.l   #1,d0
 beq.b    more_2
more_end:
 movem.l  (sp)+,a5/d7
 rts


* void cat_strings(a0 = char zielstring[],
*                  d0 = int anzahl, a1 = char *feld[anzahl])
*  Verkettet die Strings in <feld[]>, durch Leerzeichen getrennt, nach
*  <zielstring>, beginnend ab <feld[1]>. Wird mit ' ' auch abgeschlossen.

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


*    DATA
syntax_ifs:   DC.B  $d,$a,'Fehler in IF- Ausdruck',$d,$a,0
not_s:        DC.B  'NOT',0
errorlevel_s: DC.B  'ERRORLEVEL',0
exist_s:      DC.B  'EXIST',0
equal_s:      DC.B  '='
gleich_s:     DC.B  '=',0
*    TEXT
     EVEN

if_com:
 link     a6,#-$80
 movem.l  d6/d7/a4/a5,-(sp)
 bsr      sav_errlv
 tst.w    BATCH(a6)           * checken, ob im Batch-Modus
 beq      i100
 move.l   ARGV(a6),a5
 clr.w    d7
 addq.l   #4,a5               * nÑchster Parameter
 subq.w   #1,ARGC(a6)
 bne.b    i1
i11:
 lea      syntax_ifs(pc),a0
 bsr      strcon
 bsr      inc_errlv
 bra      i100
i1:
 lea      not_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i2
 moveq    #1,d7
 subq.w   #1,ARGC(a6)
 addq.l   #4,a5
i2:
 tst.w    ARGC(a6)
 beq.b    i11
 lea      errorlevel_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i5
 cmpi.w   #3,ARGC(a6)
 blt.b    i5
 move.l   4(a5),a0
 bsr      str_toi
 clr.w    d6
 cmp.w    errorlevel(pc),d0
 bhi.b    i3
 moveq    #1,d6
i3:
 addq.l   #4,a5
 subq.w   #1,ARGC(a6)
exe_restzeile:
 eor.w    d7,d6          * d6 umdrehen, falls d7 = 1, sonst lassen
 beq.b    i4            * Damit ist d7 die Operation NOT auf 0 und 1
 move.l   a5,a1
 move.w   ARGC(a6),d0
 lea      -$80(a6),a0
 bsr      cat_strings
 move.l   PARGV(a6),-(sp)
 move.l   PARGC(a6),-(sp)
 pea      -$80(a6)
 move.w   BATCH(a6),-(sp)
 bsr      cmdline_exec        * Rest der Kommandozeile ausfÅhren
 adda.w   #14,sp
i4:
 bra.b    i100
i5:
 lea      exist_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    i7
 cmpi.w   #3,ARGC(a6)
 blt.b    i7
 clr.w    d0
 move.l   4(a5),a0
 bsr      open
 clr.w    d6
 tst.l    d0
 blt.b    i6
* move.w   d0,,d0
 bsr      close
 moveq    #1,d6
i6:
 bra.b    i3             * Weiter wie bei "errorlevel"
i7:
 cmpi.w   #4,ARGC(a6)
 blt.b    i100           * Fehlermeldung unterdrÅcken
 lea      equal_s(pc),a1
 move.l   4(a5),a0
 bsr      upper_strcmp
 bne.b    i100           * Fehlermeldung unterdrÅcken
 subq.w   #1,ARGC(a6)    * Ausdruck "string1 == string2"
 moveq    #0,d6
 move.l   8(a5),a1
 move.l   (a5)+,a0
 bsr      upper_strcmp
 bne.b    i8
 moveq    #1,d6
i8:
 bra      i3
i100:
 movem.l  (sp)+,a4/a5/d7/d6
 unlk     a6
 rts


*    DATA
syntax_shifts:    DC.B  $d,$a,'SHIFT: Operand fehlt',$d,$a,0
*    TEXT
     EVEN

shift_com:
 tst.w    SP_BATCH(sp)             * checken, ob im Batch- Modus
 beq.b    shf_end
 lea      syntax_shifts(pc),a0
 movea.l  SP_PARGC(sp),a1
 tst.w    (a1)
 beq.b    shf_1
 subq.w   #1,(a1)
 movea.l  SP_PARGV(sp),a0
 addq.l   #4,(a0)
 bra.b    shf_end
shf_1:
 bsr      strcon
 bsr      inc_errlv
shf_end:
 rts


*    DATA
lbl_not_found_s: DC.B  $d,$a,'GOTO: Label nicht gefunden',$d,$a,0
*    TEXT
     EVEN

goto_com:
 link     a6,#-130
 movem.l  a5/a4,-(sp)
 bsr      sav_errlv
 move.w   BATCH(a6),d0        * checken, ob im Batch- Modus
 beq.b    goto_end
 lea      -90(a6),a5
 cmpi.w   #2,ARGC(a6)
 blt.b    goto_50
 clr.w    -(sp)
 move.w   d0,-(sp)            * Handle der Batchdatei
 clr.l    -(sp)               * An den Anfang der Batchdatei gehen
 gemdos   Fseek
 adda.w   #$a,sp
 bra.b    goto_5
goto_1:
 move.l   a5,a0
 bsr      skip_sep
 move.l   d0,a4
 cmpi.b   #':',(a4)+
 bne.b    goto_5             * NÑchste Zeile
 move.l   a4,a0
 bsr      search_sep
 clr.b    (a0)
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1
 move.l   a4,a0
 bsr      upper_strcmp   * Ist es das richtige Label ?
 beq.b    goto_end         * Gefunden !!
goto_5:
 move.l   a5,a0
 move.w   BATCH(a6),d0   * Batch- Handle
 bsr      read_str
 tst.w    d0
 beq.b    goto_1
goto_50:
 lea      lbl_not_found_s(pc),a0
 bsr      strcon
goto_end:
 movem.l  (sp)+,a5/a4
 unlk     a6
 rts


end_com:
 bsr      sav_errlv
 move.w   SP_BATCH(sp),d0     * checken, ob im Batch- Modus
 beq.b    end_end
 move.w   #2,-(sp)
 move.w   d0,-(sp)            * Handle der Batchdatei = $16(a6)
 clr.l    -(sp)               * Ans Ende der Batchdatei gehen
 gemdos   Fseek
 adda.w   #$a,sp
end_end:
 rts


*    DATA
for_error_s:     DC.B  $d,$a,'FOR: Syntaxfehler oder Schachtelung',$d,$a,0
*    TEXT
     EVEN

for_com:
 link     a6,#-$80
 movem.l  a5/a4/a3/d6/d7,-(sp)
 lea      for_flag(pc),a3
 bsr      sav_errlv
 move.w   BATCH(a6),d6        * checken, ob im Batch- Modus
 beq      for_end
 clr.w    d7
 lea      -$80(a6),a4
 move.l   ARGV(a6),a5
for_11:
 addq.l   #4,a5
 subq.w   #1,ARGC(a6)         * Auf ersten Parameter
 beq      for_50
 lea      not_s(pc),a1
 move.l   (a5),a0
 bsr      upper_strcmp
 bne.b    for_10
 moveq    #1,d7
 bra.b    for_11
for_10:
* Handle und Position der FOR- Anweisung feststellen
 move.w   #1,-(sp)
 move.w   d6,-(sp)
 clr.l    -(sp)
 gemdos   Fseek               * Ftell(d7)
 adda.w   #10,sp
 tst.w    (a3)                * for_flag
 beq.b    for_1                  * erstes Erreichen einer FOR- Schleife
 cmp.w    for_hdl(pc),d6
 bne      for_50
 cmp.l    for_pos(pc),d0
 bne      for_50
for_1:
 move.w   d6,for_hdl-for_flag(a3)
 move.l   d0,for_pos-for_flag(a3)
* Erstes Argument (die Laufvariable) holen
 move.l   (a5)+,a1            * Variable
 subq.w   #1,ARGC(a6)
 beq      for_50
 move.l   a4,a0
 bsr      strcpy              * Name der Variablen speichern
 lea      gleich_s(pc),a1        * "="
 move.l   a4,a0
 bsr      strcat
* Laufvariable neu setzen oder FOR- Schleife abbrechen
 addq.l   #4,a5               * Argument "(" Åberspringen
 subq.w   #1,ARGC(a6)
 ble.b    for_50
 move.w   (a3),d0             * for_flag, nÑchster Zustand der Laufvariablen
 move.w   ARGC(a6),d1
 sub.w    d0,d1
 ble.b    for_50                 * Ende der Argumentreihe (')' fehlt)
 move.w   d1,ARGC(a6)
 lsl.w    #2,d0               * mal 4 fÅr Index
 adda.w   d0,a5               * a5 zeigt auf neuen Wert
 move.l   (a5),a0
 cmpi.b   #')',(a0)
 bne.b    for_2
 tst.b    1(a0)
 bne.b    for_2
* ')' erreicht, nÑchster Befehl wird nicht ausgefÅhrt (wenn nicht NOT)
 clr.w    (a3)                * for_flag
 clr.w    d6
 bra.b    for_3
* Variablen- Zuweisung
for_2:
 moveq    #1,d6
 move.l   a0,a1
 move.l   a4,a0
 bsr      strcat
 addq.w   #1,(a3)             * for_flag
 move.l   a4,a0
 bsr      env_set             * Variable setzen
* Suche Ende der Zuweisungskette (Argument ')' )
for_3:
 move.l   (a5)+,a0
 subq.w   #1,ARGC(a6)
 bls.b    for_50                 * Zuwenig Argumente ( ')' fehlt)
 cmpi.b   #')',(a0)
 bne.b    for_3
 tst.b    1(a0)
 bne.b    for_3
 subq.l   #4,a5
 addq.w   #1,ARGC(a6)
 bra      exe_restzeile       * Wie bei IF
for_50:
 lea      for_error_s(pc),a0
 bsr      strcon
for_end:
 movem.l  (sp)+,a5/a4/d6/d7
 unlk     a6
 rts


 IFF      KAOS

* int input(string,len)
* char *string;
* int  len;
*            Register a3 ist global in diesem Modul

* lokal  akt_len d6
*        zeiger  d7
*        x       d4
*        string  a5
*        maxlen  d5
*        Ftaste  a4
*            Register a3 ist global in diesem Modul

input:
 link     a6,#0
 movem.l  a5/a4/a3/d7/d6/d5/d4,-(sp)
 DC.W     A_INIT
 move.l   a0,a3               * a3 = Zeiger auf LineA
 move.l   8(a6),a5
 move.w   $c(a6),d5
 bsr      cursor              * Cursor einschalten
 lea      d+home_ypos(pc),a0
 move.w   v_cur_cx(a3),d4     * Cursorspalte
 move.w   v_cur_cy(a3),(a0)   * home_ypos,  Cursorzeile
 clr.w    d7
 clr.w    d6
 suba.l   a4,a4
inp_1:
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr      gotox               * gotox(x+zeiger)
 addq.l   #2,sp
 move.l   a4,d0
 beq.b    inp_15
 move.b   (a4),d0
 beq.b    inp_15
 addq.l   #1,a4
 cmpi.b   #LF,d0
 beq      inp_end
 cmpi.b   #CR,d0
 beq      inp_end
 bra      inp_20
inp_15:
 gemdos   Cnecin
 addq.l   #2,sp
 andi.l   #$00ffffff,d0       * evtl. Shiftstatus lîschen
 cmpi.l   #K_CTRL_C,d0        * CTRL-C bewirkt Warmstart
 bne.b    inp_80
 gemdos   Pterm0
inp_80:
 cmpi.l   #CR,d0              * CR Åberlesen, wenn Tastaturcode 0
 beq.b    inp_1
 cmpi.l   #LF,d0              * LF schlieût ab, wenn Tastaturcode 0
 beq      inp_end
 cmpi.l   #K_RETURN,d0
 beq      inp_90
 cmpi.l   #K_ENTER,d0
 beq      inp_end                * RETURN und ENTER beenden die Eingabe
 cmpi.l   #K_BS,d0
 bne.b    inp_2
 tst.w    d7
 beq.b    inp_1                  * Zeiger ist auf Feldanfang
 subq.w   #1,d7
inp_3:
 bsr      str_del             * Zeichen vor Cursorposition lîschen
 bsr      string_at
 moveq    #' ',d0
 bsr      putch
 bra      inp_1                  * weiter
inp_2:
 cmpi.l   #K_DEL,d0
 beq.b    inp_3                  * analog zu BACKSPACE
 cmpi.l   #K_TAB,d0
 bne.b    inp_4
 cmp.w    d6,d7               * zeiger am Feldende ?
 bcs.b    inp_5
 clr.w    d7                  * zeiger nach Feldanfang
 bra      inp_1
inp_5:
 move.w   d6,d7               * zeiger nach Feldende
 bra      inp_1
inp_4:
 cmpi.l   #K_LTARROW,d0
 bne.b    inp_6
 tst.w    d7
 beq      inp_1
 subq.w   #1,d7
 bra      inp_1
inp_6:
 cmpi.l   #K_RTARROW,d0
 bne.b    inp_7
 cmp.w    d6,d7
 bcc      inp_1
 addq.w   #1,d7
 bra      inp_1
inp_7:
 cmpi.l   #K_INSERT,d0
 bne.b    inp_8
 lea      ovwr_flag(pc),a0
 not.w    (a0)
 bra      inp_1
inp_8:
 cmpi.l   #K_CLR,d0
 bne.b    inp_9
 move.w   d6,-(sp)
 move.w   d4,-(sp)
 bsr      spacestr_at
 addq.l   #4,sp
 clr.w    d6
 clr.w    d7
 bra      inp_1
inp_9:
 cmpi.l   #K_UNDO,d0
 bne.b    inp_10
 lea      d+laststring(pc),a4
 bra      inp_1
inp_10:
 cmpi.l   #K_F1,d0
 blt      inp_20
 cmpi.l   #K_F10,d0
 bgt      inp_20
 swap     d0
 addi.b   #'0'-$3b+1,d0
 cmpi.b   #'9',d0
 ble.b    inp_11
 move.b   #'0',d0             * F10 als F0 darstellen
inp_11:
 lea      func_s(pc),a0
 move.b   d0,1(a0)
* move.l   a0,a0
 bsr      getenv
 tst.l    d0
 beq      inp_1                  * Funktionstaste nicht belegt
 move.l   d0,a4
 bra      inp_1
* Jetzt kommen die druckbaren Zeichen:
inp_20:
 clr.w    d2
 move.b   d0,d2                    * obere 8 Bit lîschen
 beq      inp_1
 cmp.w    d5,d7                    * Eingabefeld voll ?
 bge      inp_1
 move.w   ovwr_flag(pc),d0
 beq.b    inp_21
 bsr      str_del
inp_21:
 bsr      str_ins
 bsr      string_at
 addq.w   #1,d7
 bra      inp_1
inp_90:
 move.w   d6,d0
 subq.w   #1,d0
 bcs.b    inp_end                * Leerstring eingegeben
 move.l   a5,a1
 lea      d+laststring(pc),a0
 cmpi.w   #128,d0
 bls.b    inp_91
 move.w   #128,d0
inp_91:
 move.b   (a1)+,(a0)+
 dbra     d0,inp_91
 clr.b    (a0)
inp_end:
 clr.b    0(a5,d6.w)          * Erzeuge EOS am Ende
 move.l   a5,-(sp)
 bsr      str_adjust
 addq.l   #4,sp
 moveq    #CR,d0
 bsr      putch
 movem.l  (sp)+,a5/a4/a3/d7/d6/d5/d4
 unlk     a6
 rts



* void gotox(x)
* int x;


gotox:
 moveq    #$1b,d0
 bsr      putch
 moveq    #'Y',d0
 bsr      putch
 moveq    #32,d0
 add.w    d+home_ypos(pc),d0
 clr.l    d1
 move.w   4(sp),d1
 move.w   v_cel_mx(a3),d2
 addq.w   #1,d2
 divu     d2,d1
 add.w    d1,d0
 swap     d1
 move.w   d1,-(sp)
 bsr      putch
 moveq    #32,d0
 add.w    (sp)+,d0
 bsr      putch
 rts


**********************************************************************
*
* void str_at()
*
*  Schreibt den String <char a5[]>, der eine LÑnge von <int d6> hat,
*  ab Position <int d7> nach Bildschirm- Position <int d4>
*

string_at:
 movem.l  d3/a4,-(sp)
 move.w   d4,-(sp)
 add.w    d7,(sp)
 bsr.b    gotox
 addq.l   #2,sp
 move.l   a5,a4
 adda.w   d7,a4                    ; a4 = ab hier ausgeben
 move.w   d6,d3
 sub.w    d7,d3                    ; d3 = Anzahl auszugebender Zeichen
 bra.b    strat_2
strat_1:
 move.w   v_cur_cy(a3),-(sp)
 clr.w    d0
 move.b   (a4)+,d0
 move.w   d0,-(sp)
 move.w   #5,-(sp)
 bios     Bconout
 addq.l   #6,sp
 move.w   (sp)+,d0

* Falls sich der Cursor nach der Ausgabe links befindet und er vorher
* auf der letzten Zeile stand, muû der Bildschirm gescrollt haben.
* Folglich wandert unsere Home- Position nach oben

 tst.w    v_cur_cx(a3)
 bne.b    strat_2
 cmp.w    v_cel_my(a3),d0
 bcs.b    strat_2
 lea      d+home_ypos(pc),a0
 subq.w   #1,(a0)
strat_2:
 dbra     d3,strat_1
 movem.l  (sp)+,d3/a4
 rts


* void spacestr_at(x,len)
* int x,len;

spacestr_at:
 link     a6,#0
 move.w   8(a6),-(sp)
 bsr      gotox
 addq.l   #2,sp
sstrat_1:
 subq.w   #1,$a(a6)
 bcs.b    sstrat_end
 moveq    #' ',d0
 bsr      putch
 bra.b    sstrat_1
sstrat_end:
 unlk     a6
 rts


**************************************************************
*
* fÅgt in einen String <char a5[]> der MaximallÑnge <int d5>
* an Position <int d7> das Zeichen <char d2> ein.
* akt_len (d6) wird entsprechend erhîht
*
**************************************************************

* void str_ins()

str_ins:
 move.l   a5,a1
 adda.w   d7,a1                    ; a0 = EinfÅgeposition
 move.l   a5,a0
 add.w    d6,a0                    ; a0 = String- Ende
 cmp.w    d5,d6
 beq.b    strins_90                ; akt_len == max_len
 bra.b    strins_1
strins_2:
 move.b   (a0),1(a0)
strins_1:
 subq.l   #1,a0
 cmpa.l   a1,a0
 bcc.b    strins_2
 addq.w   #1,d6
strins_90:
 move.b   d2,(a1)
 rts


**************************************************************
*
* nimmt aus einem <char a5[]> der LÑnge <int d6> an Position
* <int d7> ein Zeichen heraus.
* Die LÑnge wird entsprechend korrigiert
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


**************************************************************
*
* Entfernt aus einem <string> die rechtsbÅndigen Leerstellen.
* Wenn <string> nur aus Leerstellen besteht, bekommt <string>
* die LÑnge 0.
*
**************************************************************

* void str_adjust(string)
* char string[];

str_adjust:
 move.l   4(sp),a0
 move.l   a0,a1
stradj_1:
 tst.b    (a0)+
 bne.b    stradj_1
 subq.l   #1,a0
stradj_2:
 cmpa.l   a0,a1
 bcc.b    stradj_end
 cmpi.b   #' ',-(a0)
 beq.b    stradj_2
 addq.l   #1,a0
stradj_end:
 clr.b    (a0)
 rts

 ENDIF


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


* void expand_macro(a0 = char *aus_str, a1 = char ein_str[],
*                   d0 = int anzpar, a2 = char *par[anzpar])
*
*  ein_str wird unter Expansion nach aus_str kopiert
*  Es werden nur die Parameter %n und %var% eingesetzt

*    DATA
zeile_gekuerzt_s:  DC.B  $d,$a,'Kommandozeile gekÅrzt',$d,$a,0
*    TEXT
     EVEN

expand_macro:
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
 bcc.b    exm_4             * Zuwenig Parameter
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
 cmpi.w   #$7f,d6        * Aufhîren bei 128 Zeichen oder Stringende
 bge.b    exm_15
 tst.b    (a3)
 bne      exm_1
exm_15:
 cmpi.w   #$7f,d6
 blt.b    exm_16
 lea      zeile_gekuerzt_s(pc),a0
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

*    DATA
pipe_errs:   DC.B  CR,LF,' Pipe- Fehler',0
redir_errs:  DC.B  CR,LF,' Fehler beim Umlenken von STD',0
stdx_namtab: DC.B  'IN ',0,'OUT',0,'AUX',0
             DC.B  'PRN',0,'ERR',0,'XTRA',0
*    TEXT
     EVEN

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

*    DATA
batch_errs:  DC.B  $d,$a,'BATCH zu tief verschachtelt',$d,$a,0
*    TEXT
     EVEN

batch_exec:
 link     a6,#-130
 move.l   a5,-(sp)
 lea      batchlevel(pc),a5
 addq.w   #1,(a5)
 cmpi.w   #4,(a5)
 ble.b    bate_6
 lea      batch_errs(pc),a0   * "BATCH zu tief verschachtelt"
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
 bsr      expand_macro
 lea      EXPAND_BUF(a6),a0
 move.l   a0,COMMAND(a6)      * COMMAND(a6)[] ist expandierte Zeile

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
 clr.w    d7
cle_4:
 move.l   a5,a0
 bsr      skip_sep
 move.l   d0,a5

* Test auf Ende der Kommandozeile

 tst.b    (a5)
 beq      cle_22                      * Zeilenende

* Test auf Pipe- Zeichen

 cmpi.b   #'|',(a5)
 bne.b    cle_7
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
 bne.b    cle_6                       * Ok
 clr.w    d7
 clr.l    COMMAND(a6)              * Fehler
cle_6:
 bra      cle_22

* Test auf Standarddatei- Umlenkung

cle_7:
 cmpi.b   #'>',1(a5)               * Test auf "0>" bis "5>"
 bne.b    cle_40
 move.b   (a5),d5
 sub.b    #'0',d5
 bcs.b    cle_40
 cmpi.b   #5,d5
 bhi.b    cle_40
 addq.l   #1,a5
 bra.b    cle_8
cle_40:
 moveq    #1,d5                    * d5 = STDOUT
 cmpi.b   #'>',(a5)
 beq.b    cle_8
 cmpi.b   #'<',(a5)
 bne.b    cle_16
 clr.w    d5                       * d5 = STDIN
cle_8:
 addq.l   #1,a5
 clr.w    d4
 tst.w    d5
 beq.b    cle_12
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
 beq.b    cle_15
 move.w   d4,d1                    * Flag fÅr create/append
 move.l   a4,a1
 lea      STDX_TAB(a6),a0
 move.w   d5,d0                    * STD- Handle
 bsr      redirect_stdx
 tst.w    d0
 bne.b    cle_15
 clr.w    d7
 clr.l    COMMAND(a6)
 bra.b    cle_22
cle_15:
 move.b   d3,(a5)
 bra.b    cle_21
cle_16:
 movea.w  d7,a0
 adda.l   a0,a0
 adda.l   a0,a0
 move.l   a5,ARGV_TAB(a6,a0.l)     * Parameter eintragen
 addq.w   #1,d7
 cmpi.b   #$27,(a5)   * '
 beq.b    cle_17
 cmpi.b   #$22,(a5)   * "
 bne.b    cle_20
cle_17:
 move.b   (a5),d3
 movea.w  d7,a0
 subq.w   #1,a0
 adda.l   a0,a0
 adda.l   a0,a0
 addq.l   #1,ARGV_TAB(a6,a0.l)
cle_18:
 addq.l   #1,a5
 tst.b    (a5)
 beq.b    cle_21
 cmp.b    (a5),d3
 beq.b    cle_21
 bra.b    cle_18
cle_20:
 move.l   a5,a0
 bsr      search_sep
 move.l   d0,a5
cle_21:
 move.b   (a5),d3
 clr.b    (a5)+
 tst.b    d3
 beq.b    cle_22
 cmpi.w   #20,d7
 blt      cle_4
cle_22:
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
 move.w   (a0),(a1) * alten Wert von errorlevel retten
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

*    DATA
exec_fehler1_s:  DC.B  $d,$a,'EXEC Fehler =>',0
exec_fehler2_s:  DC.B  '<=',$d,$a,0
*    TEXT
     EVEN

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
     ENDIF
lep_1:
     IFEQ MAGIX
 pea      etv_critic_neu(pc)
     ENDIF
lep_3:
     IFEQ MAGIX
 move.w   #$101,-(sp)
 bios     Setexc
 addq.l   #8,sp
     ENDIF

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
     ENDIF
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
 bsr      strcon
 move.w   d7,d0
 bsr      print_err
 lea      exec_fehler2_s(pc),a0
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

*    DATA
pgm_typ_tab:
bat_s:    DC.B  '.BAT',0           ; Batch
btp_s:    DC.B  '.BTP',0           ; Batch takes parameter (NeoDesk)
          DC.B  '.TTP',0
          DC.B  '.TOS',0
prg_s:    DC.B  '.PRG',0
app_s:    DC.B  '.APP',0
acc_s:    DC.B  '.ACC',0
ANZ_SUFFIX     EQU  6

*    TEXT
     EVEN

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

 IFF      ACC
 moveq    #ANZ_SUFFIX-1,d7
 ENDC
 IF       ACC
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

*    DATA
pfad_ueberl_s:   DC.B  $d,$a,'PfadÅberlauf',0
kmd_nicht_gef_s: DC.B  $d,$a,'Kommando nicht gefunden',$d,$a,0
*    TEXT
     EVEN

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
 bsr      strcon
ece_12:
 tst.b    (a3)
 bne.b    ece_4
 lea      kmd_nicht_gef_s(pc),a0
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

*    DATA
pipe_path: DC.B  'TMPDIR=',0
pipe_nams: DC.B  '\$$pipe?.?',0
*    TEXT
     EVEN

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

* TODO: Localization

*       DATA

autoexec1s: DC.B  'C:\AUTOEXEC.BAT',0
autoexec2s: DC.B  '\AUTOEXEC.BAT',0

 IFF      ACC
bootbats:     DC.B  '\BOOT.BAT',0
 ENDC

 IFF      KAOS
func_s:       DC.B  'F0=',0
titels:       DC.B  'GEMDOSø SHELL v2.62 Ω ''90 Andreas Kromke',$d,$a
 ENDC
 IF       KAOS
 IFNE     MAGIX
titels:       DC.B  'MagiC SHELL v2.66 Ω ''93 Andreas Kromke',$d,$a
 ELSE
titels:       DC.B  'KAOSø   SHELL v2.62 Ω ''90 Andreas Kromke',$d,$a
 ENDIF
 ENDC

 IF       ACC
              DC.B  'Accessory- Version',CR,LF
 ENDC
              DC.B  $a,0
nach_art_s:   DC.B  ' nach Art',0
nach_dat_s:   DC.B  ' nach Datum',0
nach_grs_s:   DC.B  ' nach Grîûe',0
nach_nix_s:   DC.B  ' unsortiert',0
bytes_free_s: DC.B  ' Bytes frei',$d,$a,$a,0

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
taste_drueckens: DC.B  'Taste drÅcken ',0
not_founds:      DC.B  '  nicht gefunden'
crlfs:        DC.B  $d,$a,0
keine_dateiens:  DC.B  $d,$a,' Keine Dateien',0

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
     IFF  KAOS
ovwr_flag:     DC.W    0
     ENDC
for_flag:      DC.W    0
for_hdl:       DC.W    0
for_pos:       DC.L    0
errorlevel:    DC.W    0
batchlevel:    DC.W    0

     IF   ACC
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


************ BEGINN DES BSS ***********


        BSS

d:

	    DS.B  bsslen
