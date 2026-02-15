 INCLUDE  "aesbind.inc"

ZEILEN    EQU  19                  * soviele Bildschirmzeilen retten

 move.l   a0,a1
 move.l   #$100,d0                 ; Programml„nge + $100
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
 bsr      get_sysvars
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

* Zeiger auf Ur- Prozež merken
 move.b   d+isxaes(pc),d0
 bne.b    ini_xaes_nopd
 move.l   _run(pc),a0
 move.l   (a0),d0
ini_parent:
 move.l   d0,a0
 adda.w   #$24,a0
 move.l   (a0),d0                  * Elter- Prozež
 bne.b    ini_parent
 lea      d+pnt_of_boot(pc),a1
 move.l   a0,(a1)
ini_xaes_nopd:

again:
 move.l   d+stacktop(pc),sp
* ssp und usp rcksetzen
 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp
 move.l   sp,usp                   * USP restaurieren
 move.l   d+alt_ssp(pc),sp         * SSP restaurieren
 andi.w   #$dfff,sr                * User mode

* Prozež umschalten (vor den Ur- PD einh„ngen), wenn nicht XAES
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

* Die Nachricht ist angekommen, daž wir aufgerufen werden.

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

* Wir melden uns als aktuellen Prozež an.
 move.l   d+pnt_of_boot(pc),a0
 clr.l    (a0)                     * als Elter des Ur-PD abmelden
 move.l   _run(pc),a0
 lea      _base+$24(pc),a1
 move.l   (a0),(a1)                * Hauptapp als unser Elter
 lea      _base(pc),a1
 move.l   a1,(a0)                  * Wir als aktueller Prozež
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

* Bildschirmspeicher (Menleiste) sichern
 xbios    Physbase
 addq.l   #2,sp
 move.l   d0,a0
 lea      d+screenbuf(pc),a1
 move.w   #ZEILEN*20-1,d0
ini_52:
 move.l   (a0)+,(a1)+
 dbra     d0,ini_52
