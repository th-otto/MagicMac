/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Dateityp anmelden"
*
*/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "appl.h"
#include "appldata.h"
#include "applicat.h"
#include "typ_dial.h"


#define TRUE   1
#define FALSE  0
#define EOS    '\0'
#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif
#define USA	0
#define FRG	1

#define TXT(a)      ((((a) -> ob_spec.tedinfo))->te_ptext)

static struct dat_file mydat;	/* Anwendung in Arbeit */
static struct pgm_file mypgm;	/* Anwendung in Arbeit */

extern int  rsrc_gtree(int gindex, OBJECT **tree );
extern int  selected(OBJECT *tree, int which);
extern void ob_dsel(OBJECT *tree, int which);
extern void ob_sel (OBJECT *tree, int which);
extern void objs_hide(OBJECT *tree, ...);
extern void objs_unhide(OBJECT *tree, ...);

extern void fname_ext(char *s, char *d);
extern void Mgraf_mouse(int type);
extern long err_alert(long e);

extern int insert_dat( struct pgm_file *pgm, struct dat_file *dat );
extern int change_dat( struct pgm_file *pgm, struct dat_file *dat,
				char *newname );

/*********************************************************************
*
* Initialisierung der Objektklasse "Dateityp anmelden-Dialog"
*
*********************************************************************/

void typ_dial_init_rsc( void )
{
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs "Dateityp anmelden"
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*		-2:	Nachricht int data[8] wurde Åbergeben
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/

#pragma warn -par

WORD cdecl hdl_ftypes( DIALOG *d, EVNT *ev, int exitbutton, int clicks, void *data )
{
	OBJECT *tree;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_ftypes;

	if	(exitbutton == HNDL_INIT)
		{
		if	(d_typ)			/* Dialog ist schon geîffnet ! */
			{
			wind_set(wdlg_get_handle(d_typ), WF_TOP, 0,0,0,0);
			return(0);		/* create verweigern */
			}

		(TXT(tree+FTYPE_2))[0] = EOS;
		(TXT(tree+FTYPE_3))[0] = EOS;
		(TXT(tree+FTYPE_4))[0] = EOS;

		if	(clicks == 1)
			{
								/* Dateityp editieren */
			mydat = *((struct dat_file *) data);
			mypgm = *((struct pgm_file *) pgmx+mydat.pgm);
			strcpy(TXT(tree+FTYPE_1), mydat.name);
			objs_hide(tree, FTYPE_2, FTYPE_3, FTYPE_4, 0);
			}
		else	{
			if	(clicks == 2)
				{
				extern char *def_txt;

				mypgm = *((struct pgm_file *) data);
				strcpy(TXT(tree+FTYPE_1), def_txt);
				}
				
			else	{
				mypgm = *((struct pgm_file *) data);
				(TXT(tree+FTYPE_1))[0] = EOS;
				}
			mydat.sel = FALSE;
			mydat.name[0] = EOS;
			mydat.rscname[0] = EOS;
			mydat.rscindex = 0;
			mydat.iconnr = get_deficonnr('DATS');
			mydat.pgm = -1;
			objs_unhide(tree, FTYPE_2, FTYPE_3, FTYPE_4, 0);
			(tree[FTYPE_2]).ob_flags |= EDITABLE;
			(tree[FTYPE_3]).ob_flags |= EDITABLE;
			(tree[FTYPE_4]).ob_flags |= EDITABLE;
			}

		strcpy((tree+FTYPE_ANW)->ob_spec.free_string, mypgm.name);

		return(1);
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(exitbutton == HNDL_CLSD) /* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		save_dialog_xy(d);
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(exitbutton < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(clicks != 1)
		goto ende;

	if	(exitbutton == FTYPE_OK)
		{
		register int i;

		ob_dsel(tree, exitbutton);
		if	(mydat.name[0])	/* Zeichenkette editieren */
			{
			change_dat( &mypgm, &mydat,TXT(tree+FTYPE_1));
			}
		else	{				/* neue Dateitypen */
			for	(i = 0; i < 4; i++)
				{
				strcpy(mydat.name, TXT(tree+FTYPE_1+i));
				if	(mydat.name[0])
					insert_dat( &mypgm, &mydat );
				}
			}
		goto close_dialog;
		}

	if	(exitbutton == FTYPE_CN)			/* Abbruch */
		{
		ob_dsel(tree, exitbutton);
		goto close_dialog;
		}

	return(1);

	ende:
	ob_dsel(tree, exitbutton);
	subobj_wdraw(d, exitbutton, exitbutton, 1);
	return(1);		/* weiter */
}
#pragma warn +par
