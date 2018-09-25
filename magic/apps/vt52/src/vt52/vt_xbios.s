	SUPER

CURS_GETRATE		EQU	5

IMPORT	app_window, pact_appl, stack_offset
EXPORT	xbios_disp, old_xbios_vec

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xbios_vec:		DC.L 0
xbios_disp:       move     usp,a0
                  btst     #5,(sp)        ;Usermode ?
                  beq.s    xbios_user
                  movea.l  sp,a0
                  adda.w   stack_offset,a0 ;Stack-Offset (6 bzw. 8 Bytes)
xbios_user:       move.w	(a0)+,d0
						cmp.w		#21,d0			;Cursconf()?
						beq.s		Cursconf
old_xbios:        movea.l  old_xbios_vec(pc),a0
                  jmp      (a0)


Cursconf:			move.w   (a0)+,d0       ;Funktionsnummer

						move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq.s		old_xbios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq.s		old_xbios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur
                  
                  cmp.w    #CURS_GETRATE,d0
                  bhi.s    Cursconf_exit
                  move.b   Cursconf_tab(pc,d0.w),d0
                  jsr      Cursconf_tab(pc,d0.w)
Cursconf_exit:    rte

Cursconf_tab:     DC.B Cursconf_hide-Cursconf_tab
                  DC.B Cursconf_show-Cursconf_tab
                  DC.B Cursconf_blink-Cursconf_tab
                  DC.B Cursconf_noblink-Cursconf_tab
                  DC.B Cursconf_setrate-Cursconf_tab
                  DC.B Cursconf_getrate-Cursconf_tab

Cursconf_hide:    rts
Cursconf_show:    rts
Cursconf_blink:   rts
Cursconf_noblink: rts
Cursconf_setrate: rts
Cursconf_getrate: rts
