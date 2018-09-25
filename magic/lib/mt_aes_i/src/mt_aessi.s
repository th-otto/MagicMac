;Tabulatorweite 5

;Assemblerteil von MT_AES_I.C
;AK 16.3.96
;sb 11.9.96
;AK 20.5.98

;
; Enspricht mt_aess.s, mit dem Unterschied, daû, wenn initialisiert, Åber den
; internen AES-Dispatcher von MagiC gesprungen wird statt Åber den Trap.
; Ist der Zeiger nicht initialisiert, so wird automatisch der Trap
; verwendet (notwendig zur Initialisierung, denn der erste sys_set_xxx()) muû
; Åber den Trap gehen, um die Adresse des Dispatchers zu ermitteln).
;
				EXPORT	_mt_aes
				EXPORT	_GemParBlk
				EXPORT	aes_dispatcher

				OFFSET												;typedef struct
						;{
AESPB_contrl:		DS.l	1	;	WORD	*contrl;
AESPB_global:		DS.l	1	;	WORD	*global;
AESPB_intin:		DS.l	1	;	WORD	*intin;
AESPB_intout:		DS.l	1	;	WORD	*intout;
AESPB_addrin:		DS.l	1	;	void	**addrin;
AESPB_addrout:		DS.l	1	;	void	**addrout;
sizeof_AESPB:				;} AESPB;


				OFFSET	;typedef struct
						;{
APD_contrl:		DS.w	5	;	WORD	contrl[5];
APD_intin:		DS.w	16	;	WORD	intin[16];
APD_intout:		DS.w	16	;	WORD	intout[16];
APD_addrin:		DS.l	16	;	void	*addrin[16];
APD_addrout:		DS.l	16	;	void	*addrout[16];
sizeof_PARMDATA:			;} PARMDATA;

				OFFSET	;typedef struct
						;{
GPB_contrl:		DS.w	15	;	WORD	contrl[15];
GPB_global:		DS.w	15	;	WORD	global[15];
GPB_intin:		DS.w	16	;	WORD	intin[16];
GPB_intout:		DS.w	16	;	WORD	intout[16];
GPB_addrin:		DS.l	16	;	void	*addrin[16];
GPB_addrout:		DS.l	16	;	void	*addrout[16];
sizeof_GEMPARBLK:			;} GEMPARBLK;

				TEXT

;void _mt_aes( PARMDATA *d, WORD *ctrldata,	WORD *global );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;a0.l PARMDATA *d
;a1.l WORD *ctrldata
;4(sp).l WORD *global
;Ausgaben:
;-
_mt_aes:		move.l	a2,-(sp)
			lea		-sizeof_AESPB(sp),sp			;Platz fÅr AESPB
			movea.l	sp,a2
			move.l	a0,(a2)+						;contrl

			move.l	(a1)+,(a0)+					;contrl[0/1]
			move.l	(a1)+,(a0)+					;contrl[2/3]
			clr.w	(a0)+						;contrl[5]
						
			move.l	sizeof_AESPB+8(sp),(a2)+			;global Åbergeben?
			bne.s	aes_intin
			move.l	#_GemParBlk+GPB_global,-4(a2)
aes_intin:	move.l	a0,(a2)+						;WORD	intin[16]
			lea		APD_intout-APD_intin(a0),a0
			move.l	a0,(a2)+						;WORD	intout[16]
			lea		APD_addrin-APD_intout(a0),a0
			move.l	a0,(a2)+						;void	*addrin[16]
			lea		APD_addrout-APD_addrin(a0),a0
			move.l	a0,(a2)+						;void	*addrout[16]

			move.l	aes_dispatcher,d0		; interner Aufruf mîglich?
			beq.b	aes_ueber_trap			; nein!
			move.l	d0,a2
			move.l	sp,a0				; AESPB *
			movem.l	d3-d7/a3-a6,-(sp)
			jsr		(a2)					; interner Aufruf
			movem.l	(sp)+,d3-d7/a3-a6
			bra.b	aes_nach_trap

aes_ueber_trap:
			move.w	#200,d0				;AES
			move.l	sp,d1
			trap		#2
aes_nach_trap:
			lea		sizeof_AESPB(sp),sp
			movea.l	(sp)+,a2
			rts


			DATA

aes_dispatcher:DC.L		0

			BSS

			EVEN
_GemParBlk:	DS.b		sizeof_GEMPARBLK

			END
