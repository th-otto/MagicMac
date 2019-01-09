


; Exception-Handler vom Hades-TOS




;*********************************************************************************************                
; .22 
;neue exception routine fuer mehr Information

exception:
		addq.l #2,sp
move.l	2(SP),proc_pc.w ;pc merken
		movem.l D0-D7/A0-A7,proc_regs.w ;die Register merken
		move	USP,A0
		move.l	A0,proc_usp.w	;den USP merken
		move.l	SP,A1
		moveq	#0,D1
		move.w	6(SP),D1	;formatword holen
		and.w	#$0FFF,D1	;format weg=offset
		asr.w	#2,D1		;/4 ergibt vector
exception4:	lea	startup_stk.w,SP ;den Stack initialisieren
		moveq	#15,D0
		lea	proc_stk.w,A0
exception2:	move.w	(A1)+,(A0)+	;16 Worte vom SSP merken
		dbra	D0,exception2
		move.l	#$12345678,proc_lives.w ;Daten fuer gueltig erklaeren

bombs:		lea	tb1(PC),A0	;zeiger auf starttext
		bsr	string_out	;ausgeben
		cmp.w	#56,D1		;vector =56?
		blt	bomb_fa4	;nein kleiner->
		lea	tbuv(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben
		move.w	D1,D2		;vector nummer nach d2
		move.w	d1,d7
		ror.l	#8,D2		;an richtige stelle bringen
		moveq	#1,D0		;2 Stellen
		bsr	reg_aus1	;ausgeben
		bra	bomb_fa5
bomb_fa4:	lea	tbev(PC),A0	;zeiger auf exception text
		subq.w	#1,D1		;mit bus error beginnen
bomb_fa1:	subq.w	#1,D1		;
		beq	bomb_fa2	;ok->weg
bomb_fa3:	move.b	(A0)+,D6	;naechstes zeichen
		beq	bomb_fa1	;ende zeichenkette->
		bra	bomb_fa3	;nein next
bomb_fa2:	bsr	string_out	;text ausgeben
bomb_fa5:	lea	tb2(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben PC=
		move.l	proc_pc.w,D2	;pc wert hohlen
		bsr	reg_aus 	;ausgeben
		bsr	string_out	;sr=
		move.w	proc_stk.w,D2	;sr hohlen
		swap	D2		;an richtige position bringen
		moveq	#3,D0		;nur 4 stellen
		bsr	reg_aus1	;ausgeben
		bsr	string_out	;usp=
		move.l	proc_usp.w,D2	;usp wert hohlen
		bsr	reg_aus 	;und ausgeben
		bsr	string_out	;formatword=
		move.w	proc_stk+6.w,D2 ;formatword hohlen
		swap	D2		;an richtige position bringen
		moveq	#3,D0		;nur 4 stellen
		bsr	reg_aus1	;und ausgeben
		bsr	string_out	;(PC-4)=
		move.l	8.w,a4		;buserrorvektor sichern
		move.l	#bomb_fa6,8.w	;buserrorvektor setzen
		move.l	sp,a5		;stack sichern
		move.l	proc_pc.w,a6	;pc laden
		move.l	-4(a6),d2	;werte vor pc stand
		bsr	reg_aus
		move.l	(a6),d2 	;werte bei pc stand
		bsr	reg_aus
bomb_fa6:	move.l	a4,8.w		;alter buserrorvektor
		move.l	a5,sp		;alter stack
		lea	tb3(PC),A0	;zeiger auf text
		lea	proc_regs.w,A1	;zeiger auf registerwerte
		moveq	#2,D4		;daten,adressregister und stack
bomb_fa8:	bsr	string_out	;text ausgeben
		moveq	#7,D3		;8 register
bomb_fa7:	move.l	(A1)+,D2	;wert hohlen
		bsr	reg_aus 	;und ausgeben
		dbra	D3,bomb_fa7	;
		subq.l	#1,D4		;-1
		bgt	bomb_fa8	;>0 wiederhohlen
		lea	proc_stk.w,A1	;zeiger auf stackwert
		beq	bomb_fa8	;=0->wiederhohlen
		lea	tb4(PC),A0	;zeiger auf text
		bsr	string_out	;text ausgeben
		move	#$2100,SR	;Interrupts erlauben
		move.w	#2,-(SP)	;tastatur
		move.w	#2,-(SP)
		trap	#13		;auf tastendruck warten
		addq.l	#4,SP		;stack korrigieren
;fa:14.9.97 neu: trap #3-> mit return normal ins programm zurueck->testpunkt
exitcrash:	cmp.w	#$8c,d7		;trap #3?
		beq	trap3exit	;ja->
		move.l	#$093A,$04A2.w	;BIOS-Stackpointer zuruecksetzen
		move.l	#$4CFFFF,-(SP)	;
		trap	#1		;Pterm(-1) versuchen
;		jmp	kaltstart	;RESET, wenn misslungen
move.w #3,-(SP)
move.l #'AnKr',-(SP)
jmp Puntaes
trap3exit:	move.l	proc_usp.w,a0
		move	a0,usp          	;user stack pointer zurueck
		movem.l proc_regs.w,D0-D7/A0-A7 ;die Register zurueck
		rte				;ruecksprung

reg_aus:	moveq	#7,D0
reg_aus1:	rol.l	#4,D2		;next hex zahl
		move.b	D2,D6
		and.b	#$0F,D6 	;nur 4 bits werden gebraucht
		add.b	#'0',D6 	;+ ascii 0
		cmp.b	#'9',D6 	;<=9?
		ble	reg_aus2	;ja,ok->
		add.b	#'A'-'9'-1,D6	;sonst differenz zuaddieren
reg_aus2:	bsr	zei_out 	;ausgeben
		dbra	D0,reg_aus1	;wiederhohlen bis fertig
		moveq	#32,D6
		bra	zei_out 	;ein leerschlag

string_out:	move.b	(A0)+,D6	;zeichen holen
		bne	str_out1	;fertig? nein->
		rts			;zurueck
str_out1:	bsr	zei_out 	;zeichen out
		bra	string_out	;und von vorn

zei_out:	movem.l D0-D4/A0-A1,-(SP) ;register sichern
		and.w	#$FF,D6 	;nur bytwert
		move.w	D6,-(SP)	;zeichen
		move.w	#2,-(SP)	;bildschirm
		move.w	#3,-(SP)
		trap	#13		;zeichen ausgeben
		addq.l	#6,SP
		movem.l (SP)+,D0-D4/A0-A1 ;register zurueck
		rts

; .24 .28
; ... und die Texte des Handlers auch gleich noch ein wenig aufgeraeumt ...
; .29
; ausserdem sind auch noch die 68060 exeptions dabei.


tb1:		DC.B 27,'H',10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,27,'p',27,'KException ausgel',$94,'st durch: ',0
tb2:		DC.B 10,13,27,'K',10,13,27,'KPC=', 0,' SR=',0,' USP=',0,' Formatword=',0,' (PC-4)=',0
tb3:		DC.B 10,13,27,'KD0-D7=',0,10,13,27,'KA0-A7=',0,10,13,27,'KStack=',0
tb4:		DC.B 10,13,27,'K',10,13,27,'K < weiter mit beliebiger Taste >',27,'q',0
tbuv:		DC.B 'Vector nummer $',0
tbev:		DC.B 'Access fault (Bus Error) !',0
		DC.B 'Adress error !',0
		DC.B 'Illegal instruction !',0
		DC.B 'Integer divide by zero !',0
		DC.B 'CHK, CHK2 instruction !',0
		DC.B 'FTRAPcc, TRAPcc, TRAPV instruction !',0
		DC.B 'Privileg violation !',0
		DC.B 'Trace !',0
		DC.B 'Line A Emulator !',0
		DC.B 'Line F Emulator !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Coprocessor protocol violation !',0
		DC.B 'Format error !',0
		DC.B 'Uninitialized interrupt !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Spurious interrupt !',0
		DC.B 'Level 1 interrupt autovektor !',0
		DC.B 'Level 2 interrupt autovektor !',0
		DC.B 'Level 3 interrupt autovektor !',0
		DC.B 'Level 4 interrupt autovektor !',0
		DC.B 'Level 5 interrupt autovektor !',0
		DC.B 'Level 6 interrupt autovektor !',0
		DC.B 'Level 7 interrupt autovektor !',0
		DC.B 'Trap #0 instruction vector !',0
		DC.B 'Trap #1 instruction vector !',0
		DC.B 'Trap #2 instruction vector !',0
		DC.B 'Trap #3 instruction vector !',0
		DC.B 'Trap #4 instruction vector !',0
		DC.B 'Trap #5 instruction vector !',0
		DC.B 'Trap #6 instruction vector !',0
		DC.B 'Trap #7 instruction vector !',0
		DC.B 'Trap #8 instruction vector !',0
		DC.B 'Trap #9 instruction vector !',0
		DC.B 'Trap #10 instruction vector !',0
		DC.B 'Trap #11 instruction vector !',0
		DC.B 'Trap #12 instruction vector !',0
		DC.B 'Trap #13 instruction vector !',0
		DC.B 'Trap #14 instruction vector !',0
		DC.B 'Trap #15 instruction vector !',0
		DC.B 'FPCP Branch or Set on unordered condition !',0
		DC.B 'FPCP inexact result !',0
		DC.B 'FPCP divide by zero !',0
		DC.B 'FPCP underflow !',0
		DC.B 'FPCP operand error !',0
		DC.B 'FPCP overflow !',0
		DC.B 'FPCP signaling NAN !',0
		DC.B 'FPCP unimplemented data type !',0
		DC.B '68030/68851 PMMU configuration error !',0
		DC.B 'Unassigned, reserved for 68851 !',0
		DC.B 'Unassigned, reserved for 68851 !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Addressing mode unimplemented in 68060 !',0
		DC.B 'Integer instruction unimplemented in 68060 !',0
		DC.B 'Unassigned, reserved !',0
		DC.B 'Unassigned, reserved !',0

		even
