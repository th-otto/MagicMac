/*
*
* Dieser Quelltext enthÑlt die Routinen fÅr
* die Anmeldung des Edit-Objekts beim AES.
* Das Programm ist als SharedLib ausgefÅhrt.
*
* Installiert folgende AES-Funktionen:
*
*	210		XEDITINFO *edit_create( void );
*
*				XEDITINFO allozieren
*
*	211		WORD edit_open(OBJECT *tree, WORD obj);
*
*				Struktur initialisieren und Speicher
*				fÅr Zeilenzeiger anfordern
*
*	212		edit_close(OBJECT *tree, WORD obj);
*
*				Speicher fÅr Zeilenzeiger freigeben.
*
*	213		edit_delete( XEDITINFO *xi );
*
*				XEDITINFO freigeben
*
*	214		edit_cursor(OBJECT *tree, WORD obj, WORD whdl, WORD show);
*
*				Cursor ein/aus
*
*	215		edit_evnt(OBJECT *tree, WORD obj, WORD whdl, EVNT *ev);
*
*				Taste und/oder Mausklicks verarbeiten
*
*	216		edit_get(OBJECT *tree, WORD obj, WORD subcode, ... );
*				0: edit_get_buf: buf,buflen,curr_tlen
*				1: edit_get_format: tabsize,autowrap
*				2: edit_get_color: tcolour,bcolour
*				3: edit_get_font: fontID,fontH,fontmono
*				4: edit_get_cursor: (char *) ptr
*				5: edit_get_positions: ptr, xscroll, cx, cy
*				7: edit_get_dirty
*				8: edit_get_sel: char *bsel, char *esel
*				9: edit_get_scrollinfo: LONG nlines, LONG yscroll,
*									WORD ncolumns, WORD xscroll
*
*				Informationen holen
*
*	217		edit_set(OBJECT *tree, WORD obj, WORD subcode, ... );
*			  0: edit_set_buf: buf,buflen
*			  1: edit_set_format: tabsize,autowrap
*			  2: edit_set_color: tcolour,bcolour
*			  3: edit_set_font: fontID,fontH,fontPix,fontmono
*			  4: edit_set_cursor: whdl, (char *) ptr
*			  5: edit_set_positions: ptr, xscroll, cx, cy
*			  6: edit_resized: void
*			  7: edit_set_dirty
*
*				Einstellungen Ñndern
*
*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "editob.h"

#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif
#pragma warn -par

#define ERROR -1
#define E_OK 0

typedef void *PD;

int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int aes_handle;		/* Screen-Workstation des AES */
int vdi_handle;
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */



void *sys_set_editob( WORD cdecl (*editob)( PARMBLK *pb) )
{
	MX_PARMDATA d;
	static WORD	c[] = { 0, 1, 0, 1 };

	d.intin[0] = 4;	/* Subcode 4: Edit-Objekt definieren */
	d.addrin[0] = editob;	/* Funktionsnummer */
	_mt_aes_alt( &d, c, NULL );
	return( d.addrout[0] );
}
void *sys_set_getfn( WORD fn )
{
	MX_PARMDATA d;
	static WORD	c[] = { 0, 2, 0, 0 };

	d.intin[0] = 1;	/* Subcode 1: AES-Funktion ermitteln */
	d.intin[1] = fn;	/* Funktionsnummer */
	_mt_aes_alt( &d, c, NULL );
	return( d.addrout[0] );
}
WORD sys_set_setfn( WORD fn, void *f )
{
	MX_PARMDATA d;
	static WORD	c[] = { 0, 2, 1, 1 };

	d.intin[0] = 2;	/* Subcode 2: AES-Funktion Ñndern */
	d.intin[1] = fn;	/* Funktionsnummer */
	d.addrin[0] = f;
	_mt_aes_alt( &d, c, NULL );
	return( d.intout[0] );
}


/*************************************************************
*
* Die neuen AES- Funktionen
*
*************************************************************/

static void fn217( AESPB *pb )	/* edit_set() */
{
	XEDITINFO *xi;
	OBJECT *tree;
	OBJECT *ob;
	WORD ret;
	WORD fontPix;


	tree = (OBJECT *) pb->addrin[0];
	ob = tree + pb->intin[0];
	xi = (XEDITINFO *) ob->ob_spec.index;
	switch(pb->intin[1])
		{
		case 0:
			edit_set_buf(xi,
					pb->addrin[1],
					*((LONG *) (pb->intin+2)));
			break;
		case 1:
			edit_set_format(xi,
					pb->intin[2], pb->intin[3]);
			break;
		case 2:
			if	(pb->intin[2] >= 0)
				xi->tcolour = pb->intin[2];
			if	(pb->intin[3] >= 0)
				xi->bcolour = pb->intin[3];
			break;
		case 3:
			fontPix = FALSE;
			if	(pb->control[1] > 5)
				fontPix = pb->intin[5];
			ret = edit_set_font(xi,
							pb->intin[2],
							pb->intin[3],
							fontPix,
							pb->intin[4]
							);
			break;
		case 4:
			ret = edit_set_cursor( tree, pb->intin[0],
							pb->intin[2],
							xi,
							pb->addrin[1] );
			break;
		case 5:
			edit_set_scroll_and_cpos(xi,
						pb->intin[2],
						*((LONG *) (pb->intin+3)),
						pb->addrin[1],
						pb->addrin[2],
						pb->intin[5],
						pb->intin[6]
						);
			break;
		case 6:
			ret = edit_resized(ob, xi,
						&pb->intout[1],
						&pb->intout[2]);
			break;
		case 7:
			xi->dirty = pb->intin[2];
			break;
		case 9:
			ret = edit_scroll( tree, pb->intin[0],
							pb->intin[2],
							xi,
							*((LONG *) (pb->intin+3)),
							pb->intin[5]
							);
			break;

		default:
			ret = 0;
		}
	pb->intout[0] = ret;
}
static void fn216( AESPB *pb )	/* edit_get() */
{
	XEDITINFO *xi;
	OBJECT *ob;
	WORD ret = 1;

	ob = ((OBJECT *) pb->addrin[0]) + pb->intin[0];
	xi = (XEDITINFO *) ob->ob_spec.index;
	switch(pb->intin[1])
		{
		case 0:
			pb->addrout[0] = xi->buf;
			*((LONG *) (pb->intout+1)) = xi->buflen;
			*((LONG *) (pb->intout+3)) = xi->curr_tlen;
			break;
		case 1:
			pb->intout[1] = xi->tabwidth;
			pb->intout[2] = xi->autowrap;
			break;
		case 2:
			pb->intout[1] = xi->tcolour;
			pb->intout[2] = xi->bcolour;
			break;
		case 3:
			pb->intout[1] = xi->fontID;
			pb->intout[2] = xi->fontH;
			pb->intout[3] = xi->mono;
			if	(pb->control[2] > 4)
				pb->intout[4] = xi->fontPix;
			break;
		case 4:
			pb->addrout[0] = edit_get_cursor(xi);
			break;
		case 5:
			pb->intout[1] = xi->xscroll;
			*((LONG *) (pb->intout+2)) = xi->yscroll;
			pb->intout[4] = xi->ccurs_x;
			pb->intout[5] = xi->ccurs_y;
			pb->addrout[0] = xi->lines[0].line;
			pb->addrout[1] = edit_get_cursor(xi);
			break;
		case 7:
			ret = xi->dirty;
			break;
		case 8:
			pb->addrout[0] = xi->bsel;
			pb->addrout[1] = xi->esel;
			break;
		case 9:
			*((LONG *) (pb->intout+1)) = xi->nlines;
			*((LONG *) (pb->intout+3)) = xi->yscroll;
			pb->intout[5] = xi->lvis;	/* sichtbare Zeilen */
			pb->intout[6] = xi->leff;	/* angezeigte Zeilen */
			pb->intout[7] = xi->max_linew;/* max. Zeilenbreite */
			pb->intout[8] = xi->xscroll;
			pb->intout[9] = ob->ob_width;
			break;
		default:
			ret = 0;
		}
	pb->intout[0] = ret;
}
static void fn215( AESPB *pb )
{
	OBJECT *ob;
	LONG errcode;

	ob = ((OBJECT *) pb->addrin[0]) + pb->intin[0];
	pb->intout[0] = edit_evnt( ((OBJECT *) pb->addrin[0]),
						pb->intin[0],
						pb->intin[1],
						((EVNT *) pb->addrin[1]),
						(XEDITINFO *) ob->ob_spec.index,
						&errcode );
	if	(pb->control[2] >= 3)
		*((LONG *) (pb->intout+1)) = errcode;
}
static void fn214( AESPB *pb )
{
	OBJECT *ob;

	ob = ((OBJECT *) pb->addrin[0]) + pb->intin[0];
	pb->intout[0] = edit_cursor(((OBJECT *) pb->addrin[0]),
						pb->intin[0],
						pb->intin[1],
						pb->intin[2],
						(XEDITINFO *) ob->ob_spec.index );
}
static void fn213( AESPB *pb )
{
	edit_delete( (XEDITINFO *) pb->addrin[0] );
}
static void fn212( AESPB *pb )
{
	OBJECT *ob;

	ob = ((OBJECT *) pb->addrin[0]) + pb->intin[0];
	edit_close( (XEDITINFO *) ob->ob_spec.index );
}
static void fn211( AESPB *pb )
{
	OBJECT *ob;

	ob = ((OBJECT *) pb->addrin[0]) + pb->intin[0];
	pb->intout[0] = edit_open( ob, (XEDITINFO *) ob->ob_spec.index );
}
static void fn210( AESPB *pb )
{
	pb->addrout[0] = edit_create();
}


/*****************************************************************
*
* Bibliothek initialisieren.
* Die Bibliothek hat keine eigene ap_id. Trotzdem brauchen
* wir das appl_init() zur Initialisierung unseres global-Feldes.
*
*****************************************************************/

extern LONG cdecl slb_init( void )
{
	register int i;
	int dummy;



	/* AES initialisieren */
	/* ------------------ */

	if   (appl_init() < 0)
		return(ERROR);

	if	(sys_set_getfn(210))
		return(ERROR);		/* Funktion schon installiert */

	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar,
							&gl_hwbox, &gl_hhbox);

	/* VDI initialisieren */
	/* ------------------ */

	vdi_handle = aes_handle;
	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);
	vst_load_fonts(vdi_handle, 0);
	vsf_color(vdi_handle,WHITE);           /* FÅllfarbe weiû */
	/* linksbÅndig, Zeichenzellenoberkante */
	vst_alignment(vdi_handle, 0, 5, &dummy, &dummy);


	/* AES-Funktionen umdefinieren */
	/* --------------------------- */

	sys_set_setfn(217, fn217);
	sys_set_setfn(216, fn216);
	sys_set_setfn(215, fn215);
	sys_set_setfn(214, fn214);
	sys_set_setfn(213, fn213);
	sys_set_setfn(212, fn212);
	sys_set_setfn(211, fn211);
	sys_set_setfn(210, fn210);
	sys_set_editob( xeditob_userdef );

	return(E_OK);
}


/*****************************************************************
*
* Bibliothek aufrÑumen.
* Wir dÅrfen kein appl_exit() machen, weil wir keine
* ap_id haben. rsrc_free() dagegen wÑre erlaubt, weil die
* RSC-Strukturen im global-Feld liegen.
*
*****************************************************************/

extern void cdecl slb_exit( void )
{

	/* AES-Funktionen wieder entfernen */
	/* ------------------------------- */

	sys_set_editob( 0 );
	sys_set_setfn(217, NULL);
	sys_set_setfn(216, NULL);
	sys_set_setfn(215, NULL);
	sys_set_setfn(214, NULL);
	sys_set_setfn(213, NULL);
	sys_set_setfn(212, NULL);
	sys_set_setfn(211, NULL);
	sys_set_setfn(210, NULL);

	vst_unload_fonts(vdi_handle, 0);
	v_clsvwk(vdi_handle);
}


/*****************************************************************
*
* Bibliothek îffnen
*
*****************************************************************/

extern LONG cdecl slb_open( PD *pd )
{
	return(E_OK);
}


/*****************************************************************
*
* Bibliothek schlieûen
*
*****************************************************************/

extern void cdecl slb_close( PD *pd )
{
}
