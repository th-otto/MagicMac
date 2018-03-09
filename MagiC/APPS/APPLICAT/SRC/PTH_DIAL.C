/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Ordner/Disk anmelden"
*
*/

#include <mgx_dos.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "applicat.h"
#include "appl.h"
#include "appldata.h"
#include "icp_dial.h"
#include "pth_dial.h"


#define TXT(a)      ((((a) -> ob_spec.tedinfo))->te_ptext)

struct pth_file mypth;	/* Pfad/Ordner in Arbeit */
struct pth_file oldpth;	/* Daten vor énderung */


/*********************************************************************
*
* Initialisierung der Objektklasse "Ordner anmelden-Dialog"
*
*********************************************************************/

void pth_dial_init_rsc( void )
{
}


/*********************************************************************
*
* Stellt fest, ob ein Pfad ein Laufwerk ist
*
*********************************************************************/

static int is_disk(char *path)
{
	char c;

	c = (*path++) & 0x5f;
	if	((c < 'A') || (c > 'Z'))
		return(FALSE);
	if	(*path++ != ':')
		return(FALSE);
	if	(*path++ != '\\')
		return(FALSE);
	return(!(*path));
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs "Ordner anmelden"
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*			clicks == 0:	data ist NULL oder struct pth_file *
*			clicks == 1:	data ist NULL oder char *
*		-2:	Nachricht int data[8] wurde Åbergeben
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*		-5:	Initialisierung _NACH_ ôffnen des Fensters
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/

#pragma warn -par

WORD cdecl hdl_pth( DIALOG *d, EVNT *ev, int exitbutton, int clicks, void *data )
{
	OBJECT *tree;
	size_t len;
	char *s;
	int editob,cursorpos;

	tree = adr_newpath;

	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	if	(exitbutton == HNDL_INIT)
		{
		if	(d_pth)			/* Dialog ist schon geîffnet ! */
			{
			wind_set(wdlg_get_handle(d_pth), WF_TOP, 0,0,0,0);
			return(0);		/* create verweigern */
			}

		if	(!clicks && data)
			{			/* Pfad editieren */
			mypth = *((struct pth_file *) data);
			oldpth = mypth;
			}
		else	{
			mypth.sel = /* mypth.sel_icon = */ FALSE;
			if	(data)
				strcpy(mypth.path, (char *) data);
			else	mypth.path[0] = EOS;	/* neuer Pfad */
			mypth.rscname[0] = EOS;
			mypth.rscindex = 0;
			mypth.iconnr = get_deficonnr('FLDR');
			oldpth.path[0] = EOS;	/* alter Wert ungÅltig */
			}

		TXT(tree+FLDN_PTH) = mypth.path;

		return(1);
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(exitbutton == HNDL_CLSD)
		{	/* Wenn Dialog geschlossen werden soll... */
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

	if	(exitbutton == FLDN_REL)
		{
		len = strlen(mypth.path);
		if	(!len)
			goto ende;
		if	(mypth.path[len-1] == '\\')
			mypth.path[len-1] = EOS;
		s = strrchr(mypth.path, '\\');
		if	(s)
			strcpy(mypth.path, s+1);
		strcat(mypth.path, "\\");
		goto newpath;
		}

	if	(exitbutton == FLDN_OK)
		{
		ob_dsel(tree, exitbutton);
		len = strlen(mypth.path);
		if	((!len) || (mypth.path[len-1] != '\\'))
			{
			mypth.path[len] = '\\';
			mypth.path[len+1] = EOS;
			}
		if	(!oldpth.path[0] && is_disk(mypth.path))
			mypth.iconnr = get_deficonnr('DRVS');
		insert_pth(&mypth, &oldpth);
		goto close_dialog;
		}

	if	(exitbutton == FLDN_SEL)			/* Dateiauswahl */
		{
		char fname[MAX_NAMELEN];
		char path[MAX_PATHLEN];
		int ex;


		fname[0] = EOS;
		strcpy(path, mypth.path);
		len = strlen(path);
		if	(len)
			{
			if	(path[len-1] == '\\')
				{
				path[len] = '.';
				path[len+1] = EOS;
				}
			}
		fsel_exinput(path, fname, &ex, Rgetstring(STR_CHOOSE_PATH, NULL));
		if	(!ex)
			goto ende;

		s = strrchr(path, '\\');
		if	(s)
			{
			s++;
			*s = EOS;
			}
		strcpy(mypth.path, path);
		newpath:
		editob = wdlg_get_edit(d, &cursorpos);
		if	(editob == FLDN_PTH)
			{
			wdlg_set_edit(d, 0);		/* Cursor abmelden */
			subobj_wdraw(d, FLDN_PTH, FLDN_PTH, 1);
			wdlg_set_edit(d, editob);	/* Cursor anmelden */
			}
		else	subobj_wdraw(d, FLDN_PTH, FLDN_PTH, 1);
		goto ende;
		}

	if	(exitbutton == FLDN_CN)			/* Abbruch */
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
