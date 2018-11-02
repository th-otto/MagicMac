#ifndef __WDIALOG_H__
#define __WDIALOG_H__ 1

#ifndef __EVNT
#define __EVNT
typedef struct
{
	WORD	mwhich;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;
	WORD	key;
	WORD	mclicks;
	WORD	reserved[9];
	WORD	msg[16];
} EVNT;
#endif

typedef	WORD	(cdecl *HNDL_OBJ)( struct _dialog *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

/*----------------------------------------------------------------------------------------*/ 
/* Bei aenderungen an der DIALOG-Struktur muss auch die Assembler-Definition angepasst 		*/
/*	werden!																											*/
/*----------------------------------------------------------------------------------------*/ 

typedef struct _dialog
{
	LONG			magic1;				/* Magic: 'wdlg' */
	LONG			version;			/* Versionsnummer: 0x10000L */
	
	WORD			flags;
	
	void			*user_data;			/* benutzerinterne Daten */

	OBJECT 		*tree;					/* Objektbaum */
	GRECT			rect;				/* Dialogposition und -ausmasse (nicht mit border geschnitten) */

	WORD			whdl;				/* Fensterhandle */
	WORD			kind;				/* Fensterattribute */
	GRECT			border;				/* Fensterposition und -ausmasse (auf den Rand bezogen) */

	HNDL_OBJ		handle_exit;		/* Zeiger auf die Service-Funktion */

	WORD			act_editob;			/* aktuelles Edit- Objekt */
	WORD			cursorpos;

	WORD			root_ob_state;		/* beim Aufruf von wdlg_open gesicherter ob_state des ROOT-Objekts */
	OBSPEC		root_ob_spec;			/* beim Aufruf von wdlg_open gesicherter ob_spec des ROOT-Objekts */
} DIALOG;

/* Definitionen fuer <flags> */
#ifndef WDLG_BKGD
#define	WDLG_BKGD	0x0001				/* Permit background operation */
#endif

/* Funktionsnummern fuer <obj> bei handle_exit(...) */
#ifndef HNDL_INIT
#define	HNDL_INIT	(-1)			/* Initialise dialog */
#define	HNDL_MESG	(-2)			/* Handle message */
#define	HNDL_CLSD	(-3)			/* Dialog window was closed */
#define	HNDL_OPEN	(-5)			/* End of dialog initialisation (second call at end of wdlg_init) */
#define	HNDL_EDIT	(-6)			/* Test characters for an edit-field */
#define	HNDL_EDDN	(-7)			/* Character was entered in edit-field */
#define	HNDL_EDCH	(-8)			/* Edit-field was changed */
#define	HNDL_MOVE	(-9)			/* Dialog was moved */
#define	HNDL_TOPW	(-10)			/* Dialog-window has been topped */
#define	HNDL_UNTP	(-11)			/* Dialog-window is not active */
#endif

/* Parameterbeschreibung fuer die Service-Routine handle_exit():

	WORD	handle_exit( struct _dialog *d, WORD obj, WORD clicks, void *data );
	
	d:			Zeiger auf eine Dialog-Struktur. Auf die Struktur sollte
				nicht direkt zugegriffen werden. Die wdlg_xx-Funktionen
				sollten benutzt werden!

	obj:		>= 0: Objektnummer
				< 0:	Funktionsnummer (siehe unten)
			
	clicks:	Anzahl der Mausklicks (falls es sich bei <obj>
				um eine Objektnummer handelt)
	
	data:		der Inhalt haengt von <obj> ab
					
	Bedeutung von <data> abhaengig von <obj>:

	Falls <obj> eine (positive) Objektnummer ist, wird in <data>
	die Variable <user_data> uebergeben (siehe wdlg_create).
	<clicks> enthaelt die Anzahl der Mausklicks auf dieses Objekt.
	
	HNDL_INIT: <data> ist die bei wdlg_init uebergebene Variable.
					Wenn handle_exit() 0 zurueckliefert, legt
					wdlg_create() keine Dialog-Struktur an (Fehler).
					Die Variable <code> wird in <clicks> uebergeben.
					
	HNDL_OPEN: <data> ist die bei wdlg_open uebergebene Variable.
					Die Variable <code> wird in <clicks> uebergeben.
					
	HNDL_CLSD: <data> ist <user_data>. Wenn handle_exit() 0 
					zurueckliefert, wird der Dialog geschlossen -
					wdlg_evnt() liefert 0 zurueck.

	HNDL_MOVE: <data> ist <user_data>. Wenn handle_exit() 0 
					zurueckliefert, wird der Dialog geschlossen -
					wdlg_evnt() liefert 0 zurueck.

	HNDL_TOPW: <data> ist <user_data>. Wenn handle_exit() 0 
					zurueckliefert, wird der Dialog geschlossen -
					wdlg_evnt() liefert 0 zurueck.

	HNDL_UNTP: <data> ist <user_data>. Wenn handle_exit() 0 
					zurueckliefert, wird der Dialog geschlossen -
					wdlg_evnt() liefert 0 zurueck.

	HNDL_UMSG: <data> ist ein Zeiger auf den Message-Buffer.
					Wenn handle_exit() 0 zurueckliefert, wird der
					Dialog geschlossen -	wdlg_evnt() liefert 0 zurueck.

	HNDL_EDIT:	<data> zeigt auf ein Wort mit dem Tastencode.
					Wenn handle_exit() 1 zurueckliefert, wird der
					Tastendruck verarbeitet, bei 0 ignoriert.
	
	HNDL_EDDN:	<data> zeigt auf ein Wort mit dem Tastencode.

	HNDL_EDCH:	<data> zeigt auf ein Wort mit der Objektnummer
					des neuen Edit-Felds.

*/

extern	DIALOG	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );
extern	WORD	wdlg_open( DIALOG *d, const char *title, WORD kind, WORD x, WORD y, WORD code, void *data );
extern	WORD	wdlg_close( DIALOG *d, WORD *x, WORD *y );
extern	WORD	wdlg_delete( DIALOG *d );

extern	WORD	wdlg_get_tree( DIALOG *d, OBJECT **tree, GRECT *r );
extern	WORD	wdlg_get_edit( DIALOG *d, WORD *cursor );
extern	void	*wdlg_get_udata( DIALOG *d );
extern	WORD	wdlg_get_handle( DIALOG *d );

extern	WORD	wdlg_set_edit( DIALOG *d, WORD obj );
extern	WORD	wdlg_set_tree( DIALOG *d, OBJECT *tree );
extern	WORD	wdlg_set_size( DIALOG *d, GRECT *size );
extern	WORD	wdlg_set_iconify( DIALOG *d, GRECT *g, const char *title, OBJECT *tree, WORD obj );
extern	WORD	wdlg_set_uniconify( DIALOG *d, GRECT *g, const char *title, OBJECT *tree );

extern 	WORD	wdlg_evnt( DIALOG *d, EVNT *events );
extern	void	wdlg_redraw( DIALOG *d, GRECT *rect, WORD obj, WORD depth );

#endif
