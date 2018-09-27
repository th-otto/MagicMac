	SUPER

CON					EQU	2
RAW					EQU	5

IMPORT	app_window, pact_appl, vt_jmp, rawcon_jmp, stack_offset, vt_Bconstat, vt_Bconin, vt_Kbshift
EXPORT	bios_disp, old_bios_vec
EXPORT	old_xconstat, old_xconin, old_xconout_con, old_xconout_raw, old_xcostat_con, old_xcostat_raw
EXPORT	xconstat, xconin, xconout_con, xconout_raw, xcostat_con, xcostat_raw

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_bios_vec:     DC.L 0
bios_disp:        move     usp,a0
                  btst     #5,(sp)        ;Usermode ?
                  beq.s    bios_user
                  movea.l  sp,a0
                  adda.w   stack_offset,a0 ;Stack-Offset (6 bzw. 8 Bytes)
bios_user:        move.w	(a0)+,d0
						cmp.w		#11,d0
						bhi.s		old_bios
						add.w		d0,d0
						move.w	bios_tab(pc,d0.w),d0
						jmp		bios_tab(pc,d0.w)

bios_tab:			dc.w		old_bios-bios_tab	;0
						dc.w		Bconstat-bios_tab	;1
						dc.w		Bconin-bios_tab	;2
						dc.w		Bconout-bios_tab	;3
						dc.w		old_bios-bios_tab	;4
						dc.w		old_bios-bios_tab	;5
						dc.w		old_bios-bios_tab	;6
						dc.w		old_bios-bios_tab	;7
						dc.w		Bcostat-bios_tab	;8
						dc.w		old_bios-bios_tab	;9
						dc.w		old_bios-bios_tab	;10
						dc.w		Kbshift-bios_tab	;11

old_bios:         movea.l  old_bios_vec(pc),a0
                  jmp      (a0)

;WORD	Bconstat( WORD dev );
Bconstat:			cmp.w		#CON,(a0)		;Tastatur?
						bne.s		old_bios
						move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq.s		old_bios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq.s		old_bios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur
					
						bsr		vt_Bconstat		;C-Routine aufrufen
						rte

;LONG	Bconin( WORD dev );
Bconin:				cmp.w		#CON,(a0)		;Tastatur?
						bne.s		old_bios
						move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq.s		old_bios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq.s		old_bios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur
					
						bsr		vt_Bconin		;C-Routine Aufrufen
						rte
						
;void	Bconout( WORD dev, WORD c );
Bconout:				move.w	(a0)+,d1			;Bios-Device
						move.w	(a0)+,d0			
						and.w		#$ff,d0			;Zeichen
						subq.w	#CON,d1
						bne.s		Bconout_raw

						move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq.s		old_bios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq		old_bios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur

						bsr		vt_jmp
						rte

Bconout_raw:		subq.w	#RAW-CON,d1
						bne		old_bios

						move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq		old_bios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq		old_bios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur

						bsr		rawcon_jmp
						rte

;LONG Bcostat( WORD dev );
Bcostat:				move.w	(a0),d0
						subq.w	#CON,d0
						beq		Bcostat_con
						subq.w	#RAW-CON,d0
						bne		old_bios
Bcostat_con:		moveq		#-1,d0			;Zeichen ist ausgegeben worden
						rte

;LONG	Kbshift( WORD mode );
Kbshift:				move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),d1			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						beq		old_bios			;NULL: keine Task aktiv
						move.l	d1,a0
						move.w	4(a0),d1			;AES-ID des aktuellen Prozesses
						add.w		d1,d1
						add.w		d1,d1
						lea		app_window,a0
						move.l	0(a0,d1.w),d1	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
						beq		old_bios
						move.l	d1,a0				;Zeiger auf die Fensterstruktur

						bsr		vt_Kbshift
						rte

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xconstat:		DC.L 0
xconstat:			bsr		get_struct
						move.l	a0,d0
						beq.s		call_xconstat
						bra		vt_Bconstat		;C-Routine aufrufen
call_xconstat:		move.l	old_xconstat(pc),a0
						jmp		(a0)
                  
                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xconin:			DC.L 0
xconin:				bsr		get_struct
						move.l	a0,d0
						beq.s		call_xconin
						bra		vt_Bconin		;C-Routine Aufrufen
call_xconin:		move.l	old_xconin(pc),a0
						jmp		(a0)
						
                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xconout_con:	DC.L 0
xconout_con:		bsr		get_struct
						move.l	a0,d0
						beq.s		call_xconout_con
						move.w	6(sp),d0
						and.w		#$ff,d0
						bra		vt_jmp
call_xconout_con:	move.l	old_xconout_con(pc),a0
						jmp		(a0)

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xconout_raw:	DC.L 0
xconout_raw:		bsr		get_struct
						move.l	a0,d0
						beq.s		call_xconout_raw
						move.w	6(sp),d0
						and.w		#$ff,d0
						bra		rawcon_jmp
call_xconout_raw:	move.l	old_xconout_raw(pc),a0
						jmp		(a0)

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xcostat_con:	DC.L 0
xcostat_con:		bsr		get_struct
						move.l	a0,d0
						beq.s		call_xcostat_con
						moveq		#-1,d0			;Zeichen ist ausgegeben worden						
						rts
call_xcostat_con:	move.l	old_xcostat_con(pc),a0
						jmp		(a0)

                  DC.L 'XBRA'
                  DC.L 'VT52'
old_xcostat_raw:	DC.L 0
xcostat_raw:		bsr		get_struct
						move.l	a0,d0
						beq.s		call_xcostat_raw
						moveq		#-1,d0			;Zeichen ist ausgegeben worden
						rts
call_xcostat_raw:	move.l	old_xcostat_raw(pc),a0
						jmp		(a0)

;Zeiger auf die Fensterstruktur oder NULL zurÅckliefern
;Vorgaben:
;Register d0 und a0 werden verÑndert
;Eingaben:
;-
;Ausgaben:
;a0.l Zeiger auf die Fensterstruktur oder NULL
get_struct:			move.l	pact_appl,a0		;Adresse des des Zeigers auf die aktuelle Applikationsstruktur
						move.l	(a0),a0			;Zeiger auf aktuelle Applikationsstruktur oder NULL
						move.l	a0,d0
						beq.s		get_struct_exit ;NULL: keine Task aktiv
						move.w	4(a0),d0			;AES-ID des aktuellen Prozesses
						add.w		d0,d0
						add.w		d0,d0
						lea		app_window,a0
						move.l	0(a0,d0.w),a0	;Zeiger auf die Fensterstruktur fÅr den Prozeû oder NULL
get_struct_exit:	rts

