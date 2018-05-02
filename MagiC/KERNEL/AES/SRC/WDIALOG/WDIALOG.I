						OFFSET	0											;typedef struct _dialog
																				;{
DIALOG_magic1:		DS.L	1												;	LONG			magic1;													/* Magic: 'wdlg' */
DIALOG_version:	DS.L	1												;	LONG			version;													/* Versionsnummer: 0x10000L */

DIALOG_flags:		DS.W	1
																				;	
DIALOG_user_data:	DS.L	1												;	void			*user_data;												/* benutzerinterne Daten */
																				;
DIALOG_tree:		DS.L	1												;	OBJECT 		*tree;													/* Objektbaum */
DIALOG_rect:		DS.W	4												;	GRECT			rect;														/* Dialogposition und -ausmaže (nicht mit border geschnitten) */
																				;
DIALOG_whdl:		DS.W	1												;	WORD			whdl;														/* Fensterhandle */
DIALOG_kind:		DS.W	1												;	WORD			kind;
DIALOG_border:		DS.W	4												;	GRECT			border;													/* Fensterposition und -ausmaže (auf den Rand bezogen) */
																				;
DIALOG_handle_exit:	DS.L	1											;	HNDL_OBJ		handle_exit;											/* Zeiger auf die Service-Funktion */
																				;
DIALOG_act_editob:	DS.W	1											;	WORD			act_editob;												/* aktuelles Edit- Objekt */
DIALOG_cursorpos:	DS.W	1												;	WORD			cursorpos;
sizeof_DIALOG:																;} DIALOG;



WDLG_CREATE			EQU	160
WDLG_OPEN			EQU	161
WDLG_CLOSE			EQU	162
WDLG_DELETE			EQU	163
WDLG_GET				EQU	164
WDLG_SET				EQU	165
WDLG_EVNT			EQU	166
WDLG_REDRAW			EQU	167

WDLG_GET_TREE		EQU	0
WDLG_GET_EDIT		EQU	1
WDLG_GET_UDATA		EQU	2
WDLG_GET_HANDLE	EQU	3

WDLG_SET_EDIT		EQU	0
WDLG_SET_TREE		EQU	1
WDLG_SET_SIZE		EQU	2
WDLG_SET_ICONIFY	EQU	3
WDLG_SET_UNICONIFY	EQU	4
