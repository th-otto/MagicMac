;Tabulatorgr”že:	3
;Kommentare:																;ab Spalte 60

;Assemblerteil von MT_AES.C
;AK	16.3.96
;sb	11.9.96

						EXPORT	_mt_aes
						EXPORT	_GemParBlk

						OFFSET												;typedef struct
																				;{
AESPB_contrl:		DS.l	1												;	WORD	*contrl;
AESPB_global:		DS.l	1												;	WORD	*global;
AESPB_intin:		DS.l	1												;	WORD	*intin;
AESPB_intout:		DS.l	1												;	WORD	*intout;
AESPB_addrin:		DS.l	1												;	void	**addrin;
AESPB_addrout:		DS.l	1												;	void	**addrout;
sizeof_AESPB:																;} AESPB;


						OFFSET												;typedef struct
																				;{
APD_contrl:			DS.w	5												;	WORD	contrl[5];
APD_intin:			DS.w	16												;	WORD	intin[16];
APD_intout:			DS.w	16												;	WORD	intout[16];
APD_addrin:			DS.l	16												;	void	*addrin[16];
APD_addrout:		DS.l	16												;	void	*addrout[16];
sizeof_PARMDATA:															;} PARMDATA;

						OFFSET												;typedef struct
																				;{
GPB_contrl:			DS.w	15												;	WORD	contrl[15];
GPB_global:			DS.w	15												;	WORD	global[15];
GPB_intin:			DS.w	16												;	WORD	intin[16];
GPB_intout:			DS.w	16												;	WORD	intout[16];
GPB_addrin:			DS.l	16												;	void	*addrin[16];
GPB_addrout:		DS.l	16												;	void	*addrout[16];
sizeof_GEMPARBLK:															;} GEMPARBLK;

						TEXT


						BSS

						EVEN
_GemParBlk:			DS.b	sizeof_GEMPARBLK

						END
