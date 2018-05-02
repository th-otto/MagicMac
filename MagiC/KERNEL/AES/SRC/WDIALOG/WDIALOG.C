/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*

	Compilerschalter: -B-P
*/

#define DEBUG 0

#include	<PORTAB.H>
#include <AES.H>
#include <TOS.H>
#include <STRING.H>
#include	<STDARG.H>

#define WF_ICONIFY       26                                 /* AES 4.1     */
#define WF_UNICONIFY     27                                 /* AES 4.1     */

#if	DEBUG
#include <stdio.h>
#else
#include <stddef.h>
#endif

#define	CALL_MAGIC_KERNEL	1

#if	CALL_MAGIC_KERNEL

/*----------------------------------------------------------------------------------------*/ 
/* Makros und Funktionsdefinitionen fÅr Aufrufe an den MagiC-Kernel								*/
/*----------------------------------------------------------------------------------------*/ 

extern LONG malloc(LONG size);
extern WORD grects_intersect( GRECT *p1, GRECT *p2 );
extern void set_clip_grect(GRECT *g);

extern void _objc_draw(OBJECT *tree, WORD startob, WORD depth);
extern WORD _objc_edit(OBJECT *tree, WORD objnr, WORD c, WORD *didx, WORD kind, GRECT *g );
extern WORD _objc_find( OBJECT *tree, WORD startob, WORD depth, LONG xy );
extern void _form_center(OBJECT *ob, GRECT *out );
extern WORD _wind_create( WORD typ, GRECT *full );
extern WORD _wind_open(WORD whdl, GRECT *g);
extern WORD _wind_calc( WORD type,  WORD kind, GRECT *in, GRECT *out);
extern WORD _wind_get(WORD whdl, WORD code, WORD *g );
extern WORD _wind_set(WORD whdl, WORD opcode, WORD koor[4]);
extern WORD form_wbutton(OBJECT *tree, WORD objnr, WORD clicks,
					WORD *nxt_edit, WORD whandle);
extern WORD cdecl form_wkeybd(OBJECT *tree, WORD objnr, WORD *c, WORD *nxtob, WORD whandle);

#define	objc_draw( tree, obj, depth, clip ) \
			set_clip_grect( clip ), \
			_objc_draw( tree, obj, depth )

#define	objc_edit( tree, obj, c, x, kind, rect ) \
			_objc_edit( tree, obj, c, x, kind, rect )

#define	objc_find( tree, obj, depth, x, y ) \
			_objc_find( tree, obj, depth, (((LONG) x ) << 16 ) | y )

#define	form_center( tree, rect ) \
			_form_center( tree, rect )

#define	form_wkeybd( tree, obj, obnext, key, obnew, keynext, whandle ) \
			form_wkeybd( tree, obj, &(key), obnew, whandle )

#define	wind_calc( type, kind, in, out ) \
			_wind_calc( type, kind, in, out )

#define	wind_create( type, rect ) \
			_wind_create( type, rect )

#define	wind_open( handle, rect ) \
			_wind_open( handle, rect )

#define	Malloc( size )	((void *) malloc( size ))

#define rc_intersect(a,b)	grects_intersect(a,b)

#else

/*----------------------------------------------------------------------------------------*/ 
/* Makros fÅr die Pure C-GEMLIB																				*/
/*----------------------------------------------------------------------------------------*/ 

#define	form_center( tree, rect ) \
			form_center( tree, &(rect)->g_x, &(rect)->g_y, &(rect)->g_w, &(rect)->g_h )

#define	wind_calc( type, kind, in, out ) \
			wind_calc( type, kind, (in)->g_x, (in)->g_y, (in)->g_w, (in)->g_h, &(out->g_x), &(out->g_y), &(out->g_w), &(out->g_h) )

#define	wind_create( type, rect ) \
			wind_create( type, rect->g_x, rect->g_y, rect->g_w, rect->g_h )

#define	wind_open( handle, rect ) \
			wind_open( handle, rect->g_x, rect->g_y, rect->g_w, rect->g_h )

#define	objc_edit( tree, obj, c, x, kind, rect ) \
			_GemParBlk.addrin[1] = rect, \
			objc_edit( tree, obj, c, x, kind )

#define	objc_draw( tree, obj, depth, clip ) \
			objc_draw( tree, obj, depth, (clip)->g_x, (clip)->g_y, (clip)->g_w, (clip)->g_h )

extern WORD	aes_flags;
#include	"OBJCSYSV.H"
#endif

#include "wdialog.h"

/*----------------------------------------------------------------------------------------*/ 
/* extern aus WDINTRFC.S																						*/
/*----------------------------------------------------------------------------------------*/ 
extern WORD hndl_exit( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

/*----------------------------------------------------------------------------------------*/ 
/* interne Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	set_1st_edit( DIALOG *d );
static WORD	top_whdl( void );
static WORD	wdlg_button( DIALOG *d, EVNT *events, WORD clicks, WORD mx, WORD my, WORD button );
static WORD	wdlg_key( DIALOG *d, EVNT *events );
static WORD	wdlg_mesag( DIALOG *d, EVNT *events );
static void	get_obj_GRECT( OBJECT *tree, WORD obj, GRECT *rect );
WORD	rc_intersect( GRECT *p1, GRECT *p2 );


/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr Fensterdialog anfordern																	*/
/* Funktionsergebnis:	Zeiger auf die Dialog-Struktur oder 0L										*/
/*	handle_exit:			Zeiger auf Dialog-Service-Routine											*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	flags:					Verhalten des Fensterdialogs													*/
/*----------------------------------------------------------------------------------------*/ 
DIALOG	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags )
{
	DIALOG	*d;
	
	d = Malloc( sizeof( DIALOG ));									/* Speicher anfordern */
	
	if ( d )
	{
		d->magic1 = 'wdlg';												/* Magic 'wdlg' */
		d->version = 0x10000L;											/* Versionsnummer 1.0 */

		d->flags = flags;

		d->handle_exit = handle_exit;									/* Zeiger auf die Call-Back-Funktion */
		d->tree = tree;													/* Zeiger auf den Objektbaum */
		d->user_data = user_data;										/* Zeiger auf Benutzerinformation */
	
		if ( hndl_exit( d, 0L, HNDL_INIT, code, data ) == 0 )	/* Fehler? */
		{
			Mfree( d );
			d = 0L;
		}
	}
	
	return( d );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog îffnen																							*/
/* Funktionsergebnis:	Handle des Fensters oder 0 (Fehler)											*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	title:					Zeiger auf Fenstertitel oder 0L												*/
/* kind:						Fensterkomponenten																*/
/*	x:							x-Koordinate des Fensters (oder -1 fÅr zentriert)						*/
/*	y:							y-Koordinate des Fensters (oder -1 fÅr zentriert)						*/
/*	code:						wird handle_exit() in <clicks> Åbergeben									*/
/*	data:						wird handle_exit() in <data> Åbergeben										*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_open( DIALOG *d, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data )
{
	OBJECT 	*dialog_tree;
	GRECT		back;
	GRECT		*border;
	GRECT		work;
	
	dialog_tree = d->tree;												/* Zeiger auf den Objektbaum */

	d->root_ob_state = dialog_tree[0].ob_state;					/* ob_state und ob_spec merken */
	d->root_ob_spec = dialog_tree[0].ob_spec;

	dialog_tree[0].ob_state &= ~OUTLINED;							/* evtl. vorhandenen Outline-Effekt ausblenden */
	dialog_tree[0].ob_spec.obspec.framesize = 0;

	form_center( dialog_tree, &work );								/* Dialog zentrieren */

	if	((x != -1) || (y != -1))										/* Dialog nicht zentriert? */
	{
		work.g_x = dialog_tree->ob_x = x;
		work.g_y = dialog_tree->ob_y = y;
	}

	if	( title )															/* Fenstername vorhanden? */
		kind |= NAME;														/* und mit Fenstertitel */

	d->kind = kind;														/* Fensterattribute */ 
	border = &d->border;
	wind_calc( WC_BORDER, kind, &work, border );					/* Fensterausmaûe berechnen */

#if	CALL_MAGIC_KERNEL == 0
	wind_get( 0, WF_WORKXYWH, &back.g_x, &back.g_y, &back.g_w, &back.g_h );	/* Arbeitsbereich des Desktops */
#else
	_wind_get( 0, WF_WORKXYWH, (WORD *) &back );
#endif

	if ( border->g_x < back.g_x )										/* Fenster zu weit links? */
	{
		border->g_x = back.g_x;
		wind_calc( WC_WORK, kind, border, ( &work ));			/* Grîûe des Arbeitsbereichs berechnen */
		dialog_tree->ob_x = work.g_x;
	}

	if ( border->g_y < back.g_y )										/* Fenster zu weit oben? */
	{
		border->g_y = back.g_y;
		wind_calc( WC_WORK, kind, border, ( &work ));			/* Grîûe des Arbeitsbereichs berechnen */
		dialog_tree->ob_y = work.g_y;
	}

	d->whdl = wind_create( kind, border );

	if	( d->whdl < 0 )													/* lÑût sich das Fenster nicht îffnen? */
		{
		d->tree[0].ob_state = d->root_ob_state;		/* ob_state und ob_spec wieder zurÅcksetzen */
		d->tree[0].ob_spec = d->root_ob_spec;
		return( 0 );
		}

	d->rect = *(GRECT *) &d->tree->ob_x;							/* Dialog-Rechteck */

	if	( d->flags & WDLG_BKGD )										/* hintergrundbedienbar? */
#if	CALL_MAGIC_KERNEL == 0
		wind_set( d->whdl, WF_BEVENT, 1 );
#else
	{
		WORD	w1;
		
		w1 = 1;
		_wind_set( d->whdl, WF_BEVENT, (WORD *) &w1 );
	}
#endif

	if	( title )															/* Fenstertitel setzen? */
#if	CALL_MAGIC_KERNEL == 0
		wind_set( d->whdl, WF_NAME, title );
#else
		_wind_set( d->whdl, WF_NAME, (WORD *) &title );
#endif

	wind_open( d->whdl, border );										/* Fenster îffnen */
	set_1st_edit( d );													/* Eingabefeld setzen */

	hndl_exit( d, 0L, HNDL_OPEN, code, data );

	return( d->whdl );													/* Handle zurÅckliefern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog schlieûen und Speicher freigeben														*/
/* Funktionsergebnis:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	x:							x-Koordinate des Dialogs wird zurÅckgeliefert							*/
/*	y:							y-Koordinate des Dialogs wird zurÅckgeliefert							*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_close( DIALOG *d, WORD *x, WORD *y )
{
	if ( x && y )
	{
		*x = d->rect.g_x;													/* letzte Fensterkoordinate */
		*y = d->rect.g_y;
	}
	
	d->tree[0].ob_state = d->root_ob_state;						/* ob_state und ob_spec wieder zurÅcksetzen */
	d->tree[0].ob_spec = d->root_ob_spec;
	
	wind_close( d->whdl );												/* Fenster schlieûen */
	wind_delete( d->whdl );												/* Handle freigeben */
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Verwaltungsspeicher fÅr Fensterdialog freigeben														*/
/* Funktionsergebnis:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_delete( DIALOG *d )
{
	Mfree( d );																/* Speicher fÅr Dialog-Struktur freigeben */
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Event verarbeiten																								*/
/* Funktionsresultat:	0: Dialog geschlossen 1: alles in Ordnung									*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	mwhich:					Zeiger auf die Bitmaske der aufgetretenen Events						*/
/*	msg:						Message-Buffer																		*/
/*	kreturn:					Tastencode																			*/
/*	kstate:					Zustand der Sondertasten														*/
/*	button:					Maustaste																			*/
/*	anzclicks:				Anzahl der Mausclicks															*/
/*	mox:						x-Koordinate des Mauszeigers													*/
/*	moy:						y-Koordinate des Mauszeigers													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_evnt( DIALOG *d, EVNT *events )
{
	WORD	*mwhich;
	WORD	topw;
	WORD	retcode;

	retcode = 1;
	mwhich = &events->mwhich;

	if	(( *mwhich & MU_MESAG ) &&
			(events->msg[0] >= 20) &&
			(events->msg[0] < 40))			/* Nachricht? */
	{
		if	( d->whdl == events->msg[3] )								/* Nachricht fÅr das Dialog-Fenster? */
		{
			retcode = wdlg_mesag( d, events );

			if ( retcode == 0 )											/* Dialog schlieûen? */
				return( 0 );
		}
	}

	if	(( *mwhich & ( MU_KEYBD + MU_BUTTON )) == 0 )			/* kein Button und keine Taste? */
		return( 1 );										
	
	wind_update( BEG_UPDATE );
	topw = top_whdl();													/* Handle des obersten Fensters */

	if	( d->whdl == topw )												/* ist das Dialogfenster das oberste? */
	{
		if	( *mwhich & MU_KEYBD )										/* Taste betÑtigt? */
			retcode = wdlg_key( d, events );
	}
	
	if	(( d->whdl == topw ) || ( d->flags & WDLG_BKGD ))		/* im Vordergrund bzw. Hintergrundbedienung erlaubt? */ 
	{
		if	( *mwhich & MU_BUTTON )										/* Mausknopf betÑtigt? */
		{
			if	( wind_find( events->mx, events->my ) == d->whdl )	/* Klick in das Dialog-Fenster? */
			{
				*mwhich &= ~MU_BUTTON;									/* Button-Bit lîschen */
				if ( wdlg_button( d, events, events->mclicks, events->mx, events->my, events->mbutton ) == 0 )
					retcode = 0;
			}
		}
	}
	wind_update( END_UPDATE );

	return( retcode );
}

/*----------------------------------------------------------------------------------------*/ 
/* Redraw des Dialogs Åber die Rechteckliste																*/
/*	Funktionsresultat:	-																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	rect:						maximales Redraw-Rechteck														*/
/*	obj:						Nummer des Startobjekts															*/
/*	depth:					Anzahl der Ebenen																	*/
/*----------------------------------------------------------------------------------------*/ 
void	wdlg_redraw( DIALOG *d, GRECT *rect, WORD obj, WORD depth )
{
	GRECT w;

	graf_mouse( M_OFF, 0 );												/* Maus ausschalten */

#if	CALL_MAGIC_KERNEL == 0
	wind_get( d->whdl, WF_FIRSTXYWH, &w.g_x, &w.g_y, &w.g_w, &w.g_h );	/* erstes Redraw-Rechteck */
#else
	_wind_get( d->whdl, WF_FIRSTXYWH, (WORD *) &w );
#endif

	do
	{
		if	( rc_intersect( rect,&w ))									/* die Rechtecke schneiden... */
		{
			objc_draw( d->tree, obj, depth, &w );

			if	( d->act_editob > 0 )									/* aktuelles Edit-Objekt vorhanden? */
			{
				GRECT	root_rect;
				GRECT	edit_rect;
				
				get_obj_GRECT( d->tree, obj, &root_rect );		/* Rechteck des Startobjekts mit RÑndern */
				get_obj_GRECT( d->tree, d->act_editob, &edit_rect );	/* Rechteck des Edit-Objekts mit RÑndern */
				edit_rect.g_y -= 1;
				edit_rect.g_h += 2;										/* 2 Pixel wegen des Cursors addieren */
			
				if ( rc_intersect( &root_rect, &edit_rect ))		/* schneiden sich Root- und Edit-Objekt? */
				{
					if	( rc_intersect( &edit_rect,&w ))				/* mit dem Redraw-Rechteck schneiden... */
					{ 
						objc_draw( d->tree, ROOT, depth, &w );		/* Edit-Objekt sicherheitshalber nochmal zeichnen */
	
						objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, 103, &w );	/* Cursor zeichnen, falls innerhalb des Rechtecks */
					}
				}
			}
		}
#if	CALL_MAGIC_KERNEL == 0
		wind_get( d->whdl, WF_NEXTXYWH, &w.g_x, &w.g_y , &w.g_w, &w.g_h );	/* nÑchstes Redraw-Rechteck */
#else
		_wind_get( d->whdl, WF_NEXTXYWH, (WORD *) &w );
#endif
	} while ( w.g_w > 0 );												/* alle Rechtecke abgearbeitet? */

	graf_mouse( M_ON, 0 );												/* Maus einschalten */
}

/*----------------------------------------------------------------------------------------*/ 
/* Das ein Objekt umgebenden GRECT (d.h. inklusive RÑndern) berechnen							*/
/* Funktionsresultat:	-																						*/
/*	tree:						Zeiger auf den Zeiger auf den Objektbaum									*/
/*	obj:						Objektnummer																		*/
/*	rect:						Zeiger auf GRECT fÅr Objektausmaûe											*/
/*----------------------------------------------------------------------------------------*/ 
static void	get_obj_GRECT( OBJECT *tree, WORD obj, GRECT *rect )
{
	WORD	save_x;
	WORD	save_y;
	WORD	x;
	WORD	y;
	
	save_x = tree[obj].ob_x;											/* Objektkoordinaten sichern */		
	save_y = tree[obj].ob_y;
	
	form_center( tree + obj, rect );									/* Objekt zentrieren */
	objc_offset( tree + obj, 0, &x, &y );							/* Objektkoordinaten ohne RÑnder */
	
	tree[obj].ob_x = save_x;											/* Objektkoordinaten restaurieren */
	tree[obj].ob_y = save_y;

	rect->g_x -= x;														/* Breite des Randes */
	rect->g_y -= y;														/* Hîhe des Randes */

	objc_offset( tree, obj, &x, &y );								/* Objektkoordinaten ohne RÑnder */

	rect->g_x += x;
	rect->g_y += y;
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeiger auf den Objektbaum zurÅckliefern																*/
/* Funktionsresultat:	Nummer des Edit-Objekts	(0: kein Objekt aktiv)							*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	tree:						Zeiger auf den Zeiger auf den Objektbaum									*/
/*	r:							Zeiger auf GRECT fÅr Dialogausmaûe											*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_get_tree( DIALOG *d, OBJECT **tree, GRECT *r )
{
	*tree = d->tree;														/* Adresse des Objektbaums */
	*r = d->rect;															/* Rechteck des Dialogs */
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Nummer des aktiven Edit-Objekts zurÅckliefern														*/
/* Funktionsresultat:	Nummer des Edit-Objekts	(0: kein Objekt aktiv)							*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	cursor:					Position des Cursors																*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_get_edit( DIALOG *d, WORD *cursor )
{
	*cursor = d->cursorpos;
	return( d->act_editob );											/* Nummer des aktuellen Edit-Objekts */
}

/*----------------------------------------------------------------------------------------*/ 
/* Nummer des aktiven Edit-Objekts setzen																	*/
/* Funktionsresultat:	Nummer des Edit-Objekts															*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	obj:						Nummer des neuen Edit-Objekts oder 0 (kein Edit-Objekt)				*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_set_edit( DIALOG *d, WORD obj )
{
	if	( obj != d->act_editob )										/* wurde das Edit-Feld gewechselt? */
	{
		if	( d->act_editob > 0 )										/* war ein Edit-Feld aktiv? */
#if	CALL_MAGIC_KERNEL
			objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, ED_END + (d->whdl<<8), 0L );
#else
			objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, ED_END, 0L );
#endif
		if	( obj > 0 )														/* neues Edit-Feld aktiv? */
#if	CALL_MAGIC_KERNEL
			objc_edit( d->tree, obj, 0, &d->cursorpos, ED_INIT + (d->whdl<<8), 0L );
#else
			objc_edit( d->tree, obj, 0, &d->cursorpos, ED_INIT, 0L );
#endif
		d->act_editob = obj;												/* Nummer des neuen Edit-Objekts */

		hndl_exit( d, 0L, HNDL_EDCH, 0, &d->act_editob );		/* das Edit-Feld wurde gewechselt... */
	}

	return( obj );
}

/*----------------------------------------------------------------------------------------*/ 
/* Neuen Objektbaum fÅr ein Fenster setzen, Grîûe des Fensters evtl. verÑndern				*/
/* Funktionsresultat:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	tree:						Zeiger auf den neuen Objektbaum												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_set_tree( DIALOG *d, OBJECT *tree )
{
	tree->ob_state &= ~OUTLINED;										/* evtl. vorhandenen Outline-Effekt ausblenden */
	tree->ob_spec.obspec.framesize = 0;
	tree->ob_x = d->rect.g_x;											/* x-Koordinate setzen */
	tree->ob_y = d->rect.g_y;											/* y-Koordinate setzen */

	d->tree = tree;														/* Zeiger auf den neuen Baum */
	d->act_editob = 0;

	wdlg_set_size( d, (GRECT *) &tree->ob_x );					/* evtl. Grîûe Ñndern */

	wind_update( BEG_UPDATE );
	wdlg_redraw( d, &d->rect, ROOT, MAX_DEPTH );					/* neuzeichnen */
	wind_update( END_UPDATE );

	set_1st_edit( d );													/* Eingabefeld setzen */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fenstergrîûe und evtl. Position verÑndern																*/
/* Funktionsresultat:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	size:						GRECT mit neuen Dialogausmaûen (ArbeitsflÑche des Fensters)			*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_set_size( DIALOG *d, GRECT *size )
{
	WORD	change;

	change = 0;
	
	if (( size->g_x != d->rect.g_x ) || ( size->g_y != d->rect.g_y ))
	{
		d->rect.g_x = size->g_x;										/* x-Koordinate setzen */
		d->rect.g_y = size->g_y;										/* y-Koordinate setzen */
		change = 1;
	}

	if (( size->g_w != d->rect.g_w ) || ( size->g_h != d->rect.g_h ))	/* andere Ausmaûe? */
	{
		d->rect.g_w = size->g_w;										/* neue Breite */
		d->rect.g_h = size->g_h;										/* neue Hîhe */
		change = 1;
	}
	
	if ( change )															/* énderungen? */
	{
		GRECT	*border;
		
		border = &d->border;

		wind_calc( WC_BORDER, d->kind, ( &d->rect ), border );	/* Fensterausmaûe berechnen */
	
#if	CALL_MAGIC_KERNEL == 0		
		wind_set( d->whdl, WF_CURRXYWH, border->g_x, border->g_y, border->g_w, border->g_h );
#else
		_wind_set( d->whdl, WF_CURRXYWH, (WORD *) border );
#endif								
	}

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fenster ikonifizieren, Objektbaum ggf. austauschen.												*/
/* Ggf. ein Objekt (Icon) zentrieren.																		*/
/* Funktionsresultat:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	g:							Zeiger auf das neue GRECT														*/
/* tree:						Neuer Objektbaum oder NULL														*/
/* title:					Neuer Fenstertitel oder NULL													*/
/* obj:						Zu zentrierendes Objekt oder -1												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_set_iconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree, WORD obj )
{
#if	CALL_MAGIC_KERNEL == 0		

	wind_set( d->whdl, WF_ICONIFY, g->g_x, g->g_y, g->g_w, g->g_h );
	d->border = *g;														/* FensterrÑnder */
	wind_get( d->whdl, WF_WORKXYWH, &d->rect.g_x, &d->rect.g_y, &d->rect.g_w, &d->rect.g_h );

	if	( title )															/* neuer Fenstertitel? */
		wind_set( d->whdl, WF_NAME, title );
#else

	_wind_set( d->whdl, WF_ICONIFY, (WORD *) g );
	d->border = *g;														/* FensterrÑnder */
	_wind_get( d->whdl, WF_WORKXYWH, (WORD *) &d->rect );

	if	( title )															/* neuer Fenstertitel? */
		_wind_set( d->whdl, WF_NAME, (WORD *) &title );
#endif

	if	( tree )																/* neuen Objektbaum setzen? */
	{
		tree->ob_state &= ~OUTLINED;									/* evtl. vorhandenen Outline-Effekt ausblenden */
		tree->ob_spec.obspec.framesize = 0;
		d->tree = tree;													/* Zeiger auf den neuen Baum */
		d->act_editob = 0;
	}

	tree = d->tree;
	*((GRECT *) &tree->ob_x ) = d->rect;							/* Objekt-Koordinaten setzen */

	if	( obj >= 0 )														/* Objekt zentrieren? */
	{
		OBJECT *oi;
	
		oi = tree + obj;
																				/*	ICON: Das sollte das Benutzerprogramm erledigen */
																				/*		oi->ob_width  = 72; */
																				/*		oi->ob_height = (oi->ob_spec.iconblk->ib_hicon)+8; */

		oi->ob_x = (tree->ob_width  - oi->ob_width ) >> 1;
		oi->ob_y = (tree->ob_height - oi->ob_height) >> 1;
	}

	set_1st_edit( d );													/* Eingabefeld setzen */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fenster de-ikonifizieren, Objektbaum ggf. austauschen.											*/
/* Funktionsresultat:	1																						*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	g:							Zeiger auf das neue GRECT														*/
/* tree:						Neuer Objektbaum oder NULL														*/
/* title:					Neuer Fenstertitel oder NULL													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_set_uniconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree )
{
#if	CALL_MAGIC_KERNEL == 0		

	wind_set( d->whdl, WF_ICONIFY, g->g_x, g->g_y, g->g_w, g->g_h );
	d->border = *g;														/* FensterrÑnder */
	wind_get( d->whdl, WF_WORKXYWH, &d->rect.g_x, &d->rect.g_y, &d->rect.g_w, &d->rect.g_h );

	if	( title )															/* neuer Fenstertitel? */
		wind_set( d->whdl, WF_NAME, title );
#else
	_wind_set(d->whdl, WF_UNICONIFY, (WORD *) g);
	d->border = *g;
	_wind_get(d->whdl, WF_WORKXYWH, (WORD *) &d->rect );

	if	(title)																/* neuer Fenstertitel? */
		_wind_set( d->whdl, WF_NAME, (WORD *) &title );
#endif

	if	( tree )																/* neuen Objektbaum setzen? */
	{
		tree->ob_state &= ~OUTLINED;									/* evtl. vorhandenen Outline-Effekt ausblenden */
		tree->ob_spec.obspec.framesize = 0;
		d->tree = tree;													/* Zeiger auf den neuen Baum */
		d->act_editob = 0;
	}

	tree = d->tree;
	*((GRECT *) &tree->ob_x) = d->rect;								/* Objekt-Koordinaten setzen */
	set_1st_edit( d );													/* Eingabefeld setzen */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Nummer des aktiven Edit-Objekts zurÅckliefern														*/
/* Funktionsresultat:	Zeiger auf Benutzerinformationen												*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	*wdlg_get_udata( DIALOG *d )
{
	return( d->user_data );												/* Zeiger auf Benutzerinformationen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Handle des Dialog-Fensters zurÅckliefern																*/
/* Funktionsresultat:	Handle																				*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wdlg_get_handle( DIALOG *d )
{
	return( d->whdl );
}

/*----------------------------------------------------------------------------------------*/ 
/* Nachricht verarbeiten																						*/
/* Funktionsresultat:	0: Dialog schlieûen 1: alles in Ordnung									*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	msg:						Zeiger auf den Message-Buffer													*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	wdlg_mesag( DIALOG *d, EVNT *events )
{
	WORD	*msg;
	WORD	opcode;
	
	msg = events->msg;
	events->mwhich &= ~MU_MESAG;			/* Nachrichten-Bit lîschen */
	
	switch( msg[0] )
	{
		case WM_REDRAW:	wind_update( BEG_UPDATE );
						wdlg_redraw( d, (GRECT *) &msg[4], ROOT, MAX_DEPTH );
						wind_update( END_UPDATE );
								return( 1 );

		case WM_TOPPED:	
#if	CALL_MAGIC_KERNEL == 0		
								wind_set( d->whdl, WF_TOP );
#else
								_wind_set( d->whdl, WF_TOP, 0L );
#endif
								opcode = HNDL_TOPW;
								break;

		case WM_CLOSED:	opcode = HNDL_CLSD;
								break;
								
		case WM_MOVED:		
#if	CALL_MAGIC_KERNEL == 0		
								wind_set( d->whdl, WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7] );
#else
								_wind_set( d->whdl, WF_CURRXYWH, msg + 4 );
#endif								
								d->tree->ob_x += msg[4] - d->border.g_x;
		 						d->tree->ob_y += msg[5] - d->border.g_y;
								d->border.g_x = msg[4];
								d->border.g_y = msg[5];
								d->rect = *(GRECT *) &d->tree->ob_x;

								opcode = HNDL_MOVE;
								break;

		case WM_UNTOPPED:	opcode = HNDL_UNTP;
								break;
	
		default:				opcode = HNDL_MESG;
								break;
	}
	
	return( hndl_exit( d, events, opcode, 0, d->user_data ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Mausklick verarbeiten																						*/
/* Funktionsresultat:	0: Dialog schlieûen 1: alles in Ordnung									*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	clicks:					Anzahl der Mausklicks (wenn 0, dann enthÑlt mx die Objektnummer)	*/
/*	mx:						x-Koordinate des Mauszeigers													*/
/*	my:						y-Koordinate des Mauszeigers													*/
/*	button:					Maustaste																			*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	wdlg_button( DIALOG *d, EVNT *events, WORD clicks, WORD mx, WORD my, WORD button )
{
	WORD	obj;
	WORD	edit;
	WORD	no_exit;

	if	( button != 1 )													/* nicht linke Maustaste? */
		return( 1 );														/* ignorieren */

	if	( clicks )															/* Klicks vorhanden? */
	{
		obj = objc_find( d->tree, ROOT, MAX_DEPTH, mx, my );	/* Objekt suchen */
		if	( obj < 0 )														/* kein Objekt gefunden? */
			return( 1 );

		if	( d->tree[obj].ob_state & DISABLED )					/* ist das Objekt disabled? */
			return( 1 );
	}
	else																		/* Mausklick simulieren */
	{
		obj = mx;															/* Objektnummer */
		clicks = 1;															/* 1 Klick */
	}

#if CALL_MAGIC_KERNEL == 0
	wind_set( d->whdl, WF_TOP );										/* Fenster nach vorne bringen */
#else
	_wind_set( d->whdl, WF_TOP, 0L );
#endif

#if CALL_MAGIC_KERNEL == 1
	set_clip_grect( (GRECT *) &(d->tree->ob_x) );				/* Clipping-Rechteck fÅr form_button() setzen */
#endif

	no_exit = form_wbutton( d->tree, obj, clicks, &edit, d->whdl );		/* Mausklick behandeln */
	edit &= 0x7fff;														/* Doppelklickbit lîschen */

	if	( no_exit == 0 )													/* wurde ein Exit-Objekt angewÑhlt? */			
		return( hndl_exit( d, events, edit, clicks, d->user_data ));

	if	( edit > 0 )														/* wurde ein Edit-Feld angewÑhlt? */
	{
		if	(( d->act_editob != edit ) || ( obj == edit ))		/* wurde das Edit-Feld gewechselt? */
		{
#if CALL_MAGIC_KERNEL
			objc_edit(d->tree, d->act_editob, 0, &d->cursorpos, ED_END + (d->whdl<<8), 0L );	/* Cursor im alten Editfeld ausschalten */
#else
			objc_edit(d->tree, d->act_editob, 0, &d->cursorpos, ED_END, 0L );	/* Cursor im alten Editfeld ausschalten */
#endif
			d->act_editob = edit;										/* Nummer des Edit-Objekts */

#if CALL_MAGIC_KERNEL
			objc_edit( d->tree, d->act_editob, mx, &d->cursorpos, 100, 0L );	/* Cursor aufs neue Editfeld, ED_CRSR */
#else
			if ( aes_flags & GAI_MAGIC )
				objc_edit( d->tree, d->act_editob, mx, &d->cursorpos, 100, 0L );
			else
				objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, ED_INIT, 0L );

#endif
			hndl_exit( d, events, HNDL_EDCH, 0, &d->act_editob );	/* das Edit-Feld wurde gewechselt... */
		}
	}
	return( 1 );
}



/*
formkeybd
CTRL-Q 
HELP
UNDO

objc_edit:
Shift-Ins
CTRL-Curs-Links/Rechts
Shift-Curs-Links/Rechts
CTRL-X/C/V
Tab/Shift-Tab
ESC
		
*/

/*----------------------------------------------------------------------------------------*/ 
/* Tastendruck verarbeiten																						*/
/* Funktionsresultat:	0: Dialog schlieûen 1: alles in Ordnung									*/
/*	d:							Zeiger auf die Dialog-Struktur												*/
/*	key:						Tastencode																			*/
/*	kstate:					Zustand der Sondertasten														*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	wdlg_key( DIALOG *d, EVNT *events )
{
	WORD	key;
	WORD	kstate;
	WORD	no_exit;
	WORD	neu_editob;

	key = events->key;
	kstate = events->kstate;
	
#if CALL_MAGIC_KERNEL
	set_clip_grect( (GRECT *) &(d->tree->ob_x) );				/* Clipping-Rechteck fÅr form_keybd()/objc_edit() setzen */

	if	(!(key & 0xff) && ( kstate == K_ALT ))	/* Kein ASCII, sondern Alt-Buchstabe? */
#else
	if	(( aes_flags & GAI_MAGIC ) && (( key & 0xff ) == 0 ) && (  kstate == K_ALT ))	/* Tastenkombination mit ALT? */
#endif
	{
		if	( form_wkeybd( d->tree, 0x8765, d->act_editob, key, &neu_editob, &key, d->whdl ))
		{
			events->mwhich &= ~MU_KEYBD;								/* Tastatur-Bit lîschen */
			return( wdlg_button( d, events, 0, neu_editob, 0, 1 ));
		}
		else																	/* Button mit entsprechendem Shortcut ist nicht vorhanden */
			return( 1 );													/* Taste zurÅckliefern */
	}

	no_exit = form_wkeybd( d->tree, d->act_editob, d->act_editob, key, &neu_editob, &key, d->whdl );

	if	( key )																/* Code noch nicht verarbeitet */
	{
		if ( d->act_editob > 0 )										/* ist ein Edit-Objekt aktiv? */
		{
			if ( hndl_exit( d, events, HNDL_EDIT, 0, &key ))	/* soll der Code eingefÅgt werden? */
			{
#if	CALL_MAGIC_KERNEL
				objc_edit( d->tree, d->act_editob, key, &d->cursorpos, ED_CHAR + (d->whdl<<8), 0L );	/* Zeichen einfÅgen */
#else
				objc_edit( d->tree, d->act_editob, key, &d->cursorpos, ED_CHAR, 0L );	/* Zeichen einfÅgen */
#endif
				events->mwhich &= ~MU_KEYBD;							/* Tastatur-Bit lîschen */
				hndl_exit( d, events, HNDL_EDDN, 0, &key );		/* Code wurde eingefÅgt... */
			}
		}
	}	
	else
	{
		if	(( neu_editob != d->act_editob ) && no_exit )		/* wurde das Edit-Feld gewechselt? */
		{
			if	( d->act_editob > 0 )									/* war ein Edit-Feld aktiv? */
#if	CALL_MAGIC_KERNEL
				objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, ED_END + (d->whdl<<8), 0L );
#else
				objc_edit( d->tree, d->act_editob, 0, &d->cursorpos, ED_END, 0L );
#endif
			if	( neu_editob > 0 )										/* neues Edit-Feld aktiv? */
#if	CALL_MAGIC_KERNEL
				objc_edit( d->tree, neu_editob, 0, &d->cursorpos, ED_INIT + (d->whdl<<8), 0L );
#else
				objc_edit( d->tree, neu_editob, 0, &d->cursorpos, ED_INIT, 0L );
#endif
			d->act_editob = neu_editob;								/* Nummer des neuen Edit-Objekts */

			events->mwhich &= ~MU_KEYBD;								/* Tastatur-Bit lîschen */
			hndl_exit( d, events, HNDL_EDCH, 0, &d->act_editob );	/* das Edit-Feld wurde gewechselt... */
		}
	}

	if	( no_exit )															/* wurde kein Exit-Objekt angewÑhlt? */
		return( 1 );

	events->mwhich &= ~MU_KEYBD;	/* Tastatur-Bit lîschen */
	return( hndl_exit( d, events, neu_editob, 1, d->user_data ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Handle des obersten Fenster zurÅckliefern																*/
/* Funktionsresultat:	Handle des Fanster oder -1 (kein Fenster der eigenen Applikation)	*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	top_whdl( void )
{
	WORD	whdl;

#if	CALL_MAGIC_KERNEL == 0
	if	( wind_get( 0, WF_TOP, &whdl ) == 0 )						/* Fehler? */
		return( -1 );
#else
	WORD	buf[4];

	if ( _wind_get( 0, WF_TOP, buf ) == 0 )
		return( -1 );
	
	whdl = buf[0];															/* Handle des Fensters */
#endif

	if	( whdl < 0 )														/* liegt ein Fenster einer anderen Applikation vorne? */
		return( -1 );

	return( whdl );														/* Handle des obersten Fensters */
}

/*----------------------------------------------------------------------------------------*/ 
/* Erstes Editobjekt setzen																					*/
/*	Funktionsresultat:	Nummer des ersten Edit-Objekts oder - 1									*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	set_1st_edit( DIALOG *d )
{
	OBJECT	*tree;
	WORD	index;

	d->act_editob = 0;													/* initialisieren */
	index = 0;
	tree = d->tree - 1;

	do
	{
		tree++;																/* nÑchstes Objekt */

		if	( tree->ob_flags & EDITABLE )								/* Edit-Feld? */
		{
			d->act_editob = index;										/* Nummer des Edit-Objekts */
#if	CALL_MAGIC_KERNEL
			objc_edit( d->tree, index, 0, &d->cursorpos, ED_INIT + (d->whdl<<8), 0L );	/* Cursor ein */
#else
			objc_edit( d->tree, index, 0, &d->cursorpos, ED_INIT, 0L );	/* Cursor ein */
#endif
			break;
		}
		index++;
	} while(( tree->ob_flags & LASTOB ) == 0 );

	return( d->act_editob );											/* Objektnummer zurÅckliefern */
}

#if	CALL_MAGIC_KERNEL == 0

#define	max( A,B ) ( (A)>(B) ? (A) : (B) )
#define	min( A,B ) ( (A)<(B) ? (A) : (B) )

/*----------------------------------------------------------------------------------------*/ 
/* öberlappung von p1 und p2 ÅberprÅfen																	*/
/* Funktionsresultat:	bei öberlappung einen Wert ungleich 0, andernfalls 0;					*/
/*								die Struktur *p2 enthÑlt dann die SchnittflÑche							*/
/* p1, p2:					Zeiger auf die zu vergleichenden GRECTs									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	rc_intersect( GRECT *p1, GRECT *p2 )
{
	WORD tx, ty, tw, th;

	tw = min( p2->g_x + p2->g_w, p1->g_x + p1->g_w );
	th = min( p2->g_y + p2->g_h, p1->g_y + p1->g_h );
	tx = max( p2->g_x, p1->g_x );
	ty = max( p2->g_y, p1->g_y );
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}

#endif

