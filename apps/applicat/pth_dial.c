/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Ordner/Disk anmelden"
*
*/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "applicat.h"
#include "appl.h"
#include "appldata.h"
#include "icp_dial.h"
#include "pth_dial.h"


#define TXT(a)      ((((a) -> ob_spec.tedinfo))->te_ptext)

struct pth_file mypth;					/* Pfad/Ordner in Arbeit */
struct pth_file oldpth;					/* Daten vor énderung */


/*********************************************************************
*
* Initialisierung der Objektklasse "Ordner anmelden-Dialog"
*
*********************************************************************/

void pth_dial_init_rsc(void)
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

	c = *path++;
	if (!(c >= 'A' && c <= 'Z') ||
		 (c >= 'a' && c <= 'z') ||
		 (c >= '1' && c <= '6'))
		return FALSE;
	if (*path++ != ':')
		return FALSE;
	if (*path++ != '\\')
		return FALSE;
	return *path == '\0';
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

WORD cdecl hdl_pth(struct HNDL_OBJ_args args)
{
	OBJECT *tree;
	size_t len;
	char *s;
	int editob, cursorpos;

	tree = adr_newpath;

	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	if (args.obj == HNDL_INIT)
	{
		if (d_pth)						/* Dialog ist schon geîffnet ! */
		{
			wind_set(wdlg_get_handle(d_pth), WF_TOP, 0, 0, 0, 0);
			return (0);					/* create verweigern */
		}

		if (args.clicks == 0 && args.data)
		{								/* Pfad editieren */
			mypth = *((struct pth_file *) args.data);
			oldpth = mypth;
		} else
		{
			mypth.selected = /* mypth.sel_icon = */ FALSE;
			if (args.data)
				strcpy(mypth.path, (char *) args.data);
			else
				mypth.path[0] = EOS;	/* neuer Pfad */
			mypth.rscname[0] = EOS;
			mypth.rscindex = 0;
			mypth.iconnr = get_deficonnr('FLDR');
			oldpth.path[0] = EOS;		/* alter Wert ungÅltig */
		}

		TXT(tree + FLDN_PTH) = mypth.path;

		return (1);
	}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if (args.obj == HNDL_CLSD)
	{									/* Wenn Dialog geschlossen werden soll... */
	  close_dialog:
		save_dialog_xy(args.dialog);
		return (0);						/* ...dann schlieûen wir ihn auch */
	}

	if (args.obj < 0)
		return (1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if (args.clicks != 1)
		goto ende;

	if (args.obj == FLDN_REL)
	{
		len = strlen(mypth.path);
		if (!len)
			goto ende;
		if (mypth.path[len - 1] == '\\')
			mypth.path[len - 1] = EOS;
		s = strrchr(mypth.path, '\\');
		if (s)
			strcpy(mypth.path, s + 1);
		strcat(mypth.path, "\\");
		goto newpath;
	}

	if (args.obj == FLDN_OK)
	{
		ob_dsel(tree, args.obj);
		len = strlen(mypth.path);
		if ((!len) || (mypth.path[len - 1] != '\\'))
		{
			mypth.path[len] = '\\';
			mypth.path[len + 1] = EOS;
		}
		if (!oldpth.path[0] && is_disk(mypth.path))
			mypth.iconnr = get_deficonnr('DRVS');
		insert_pth(&mypth, &oldpth);
		goto close_dialog;
	}

	if (args.obj == FLDN_SEL)			/* Dateiauswahl */
	{
		char fname[MAX_NAMELEN];
		char path[MAX_PATHLEN];
		int ex;


		fname[0] = EOS;
		strcpy(path, mypth.path);
		len = strlen(path);
		if (len)
		{
			if (path[len - 1] == '\\')
			{
				path[len] = '.';
				path[len + 1] = EOS;
			}
		}
		fsel_exinput(path, fname, &ex, Rgetstring(STR_CHOOSE_PATH, NULL));
		if (!ex)
			goto ende;

		s = strrchr(path, '\\');
		if (s)
		{
			s++;
			*s = EOS;
		}
		strcpy(mypth.path, path);
	  newpath:
		editob = wdlg_get_edit(args.dialog, &cursorpos);
		if (editob == FLDN_PTH)
		{
			wdlg_set_edit(args.dialog, 0);	/* Cursor abmelden */
			subobj_wdraw(args.dialog, FLDN_PTH, FLDN_PTH, 1);
			wdlg_set_edit(args.dialog, editob);	/* Cursor anmelden */
		} else
			subobj_wdraw(args.dialog, FLDN_PTH, FLDN_PTH, 1);
		goto ende;
	}

	if (args.obj == FLDN_CN)			/* Abbruch */
	{
		ob_dsel(tree, args.obj);
		goto close_dialog;
	}

	return (1);

  ende:
	ob_dsel(tree, args.obj);
	subobj_wdraw(args.dialog, args.obj, args.obj, 1);
	return (1);							/* weiter */
}
