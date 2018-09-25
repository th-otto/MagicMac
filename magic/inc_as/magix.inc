MACRO          M_form_xdial
               move.l    #$33090102,d0
               bsr       _aes
               ENDM

MACRO          M_form_xdo
               move.l    #$32010202,d0
               bsr       _aes
               ENDM

G_SWBUTTON	EQU	34			; Switchbutton
G_POPUP		EQU	35			; Popup- MenÅ

	OFFSET

aev_magic:	DS.L	1				/* muû $87654321 sein			*/
aev_membot:	DS.L	1				/* Ende der AES- Variablen		*/
aev_aes_start:	DS.L	1				/* Startadresse				*/
	/* KAOS */
aev_magic2:	DS.L	1				/* ist 'MAGX' oder 'KAOS'		*/
aev_date:		DS.L	1				/* Erstelldatum				*/
aev_chgres:	DS.L	1				/* Auflîsung Ñndern				*/
aev_shel_vec:	DS.L	1				/* ROM- Desktop				*/
aev_aes_btdrv:	DS.L	1				/* Hierhin kommt DESKTOP.INF		*/
aev_vdi_dev:	DS.L	1				/* vom AES benutzter Treiber		*/
aev_nvdi_wks:	DS.L	1				/* vom AES benutzte Workst.		*/
aev_shw_doex:	DS.L	1
aev_shw_isgr:	DS.L	1
	/* MAGIX */
aev_version:	DS.W	1
aev_release:	DS.W	1
aev__basepage:	DS.L	1
aev_moff_cnt:	DS.L	1
aev_shb_len:	DS.L	1
aev_shb:		DS.L	1
aev_notr_list:	DS.L	1
aev_menu_app:	DS.L	1
aev_menutree:	DS.L	1
aev_dsk:		DS.L	1
aev_dsk_1stob:	DS.L	1
aev_dos_magic:	DS.L	1
aev_maxwindn:	DS.L	1
aev_dummy:	DS.L	1

	TEXT

