/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Anwendung anmelden"
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
#include "ica_dial.h"
#include "anw_dial.h"


#define TXT(a)      ((((a) -> ob_spec.tedinfo))->te_ptext)

struct pgm_file mypgm;	/* Anwendung in Arbeit */


/*********************************************************************
*
* Initialisierung der Objektklasse "Anwendung anmelden-Dialog"
*
*********************************************************************/

void anw_dial_init_rsc( void )
{
}


/*********************************************************************
*
* Berechnet den Dateityp, und zwar:
*
* Endung PRG,TOS,TTP,APP	: Programm
* Endung BAT,BTP		: Batchdatei
* sonst				: Textdatei
*
* vorbereitet fÅr lange Dateinamen: Die Extension darf groû oder
* klein geschrieben werden.
*
*********************************************************************/

static int suffixtyp(char *s)
{
	char ext[4];

	s = strrchr(s, '.');
	if	(s)
		{
		s++;
		ext[0] = (*s++ & 0x5f);
		ext[1] = (*s++ & 0x5f);
		ext[2] = (*s++ & 0x5f);
		ext[3] = '\0';
		if	(!strcmp(ext, "PRG") || !strcmp(ext, "APP"))
			return(PGMT_ISGEM);
		if	(!strcmp(ext, "TOS"))
			return(0);
		if	(!strcmp(ext, "TTP"))
			return(PGMT_TP);
		}
	return(PGMT_ISGEM);
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs "Anwendung anmelden"
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*			clicks == 0:	data ist NULL oder struct pgm_file *
*			clicks == 1:	data ist NULL oder char *
*		-2:	Nachricht int data[8] wurde Åbergeben
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/

WORD cdecl hdl_anwndg(struct HNDL_OBJ_args args)
{
	OBJECT *tree;
	char fname[MAX_NAMELEN+10];
	int only_fname;
	char *s;
	char c;
	int cursorpos;
	int editob;


	tree = adr_anwndg;

	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	if	(args.obj == HNDL_INIT)
		{
		if	(d_anw)			/* Dialog ist schon geîffnet ! */
			{
			wind_set(wdlg_get_handle(d_anw), WF_TOP, 0,0,0,0);
			return(0);		/* create verweigern */
			}

		if	(args.data && args.clicks == 0)
			{
								/* Anwendung editieren */
			mypgm = *((struct pgm_file *) args.data);
			if	(!mypgm.path[0])
				strcpy(mypgm.path, mypgm.name);
			}
		else	{
			mypgm.sel = /* mypgm.sel_icon = */ FALSE;
			mypgm.name[0] = EOS;	/* neue Anwendung */
			mypgm.rscname[0] = EOS;
			mypgm.rscindex = 0;
			mypgm.iconnr = get_deficonnr('APPS');
			mypgm.path[0] = EOS;
			if	(args.data)
				{
				strcpy(mypgm.path, (char *) args.data);
				mypgm.config = suffixtyp(mypgm.path);
				}
			else	mypgm.config = PGMT_ISGEM;
			mypgm.memlimit = 0L;
			mypgm.ntypes = 0;
			mypgm.types = -1;
			}

		TXT(tree+ANWNDG_T) = mypgm.path;

		ob_dsel(tree, ANWND_TO);
		ob_dsel(tree, ANWND_TP);
		ob_dsel(tree, ANWND_PR);
		if	(mypgm.config & PGMT_ISGEM)
			ob_sel(tree, ANWND_PR);
		else	{
			if	(mypgm.config & PGMT_TP)
				ob_sel(tree, ANWND_TP);
			else	ob_sel(tree, ANWND_TO);
			}

		if	(mypgm.config & PGMT_SINGLE)
			ob_sel(tree, ANWND_SI);
		else	ob_dsel(tree, ANWND_SI);

		if	(mypgm.config & PGMT_NVASTART)
			ob_dsel(tree, ANWND_VA);
		else	ob_sel(tree, ANWND_VA);

		if	(mypgm.config & PGMT_NO_PROPFNT)
			ob_dsel(tree, ANWND_PROP_FNT);
		else	ob_sel(tree, ANWND_PROP_FNT);

		if	(mypgm.memlimit)
			{
			ob_sel(tree, DO_LIMIT);
			tree[LIMITMEM].ob_state &= ~DISABLED;
			}
		else	{
			ob_dsel(tree, DO_LIMIT);
			tree[LIMITMEM].ob_state |= DISABLED;
			}
		ltoa(mypgm.memlimit,
				tree[LIMITMEM].ob_spec.tedinfo->te_ptext, 10);


		objs_setradio(tree,
			(mypgm.config & PGMT_WINPATH) ? ANW_WPTH : ANW_OPTH,
			ANW_WPTH, ANW_OPTH, 0);

		return(1);
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		save_dialog_xy(args.dialog);
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	if	(args.obj == ANWND_OK)
		{

		/* Programmflags aus dem Dialog berechnen */
		/* -------------------------------------- */

		mypgm.config = 0;
		if	(selected(tree, ANWND_PR))	/* .PRG */
			mypgm.config |= PGMT_ISGEM;
		if	(selected(tree, ANWND_TP))
			mypgm.config |= PGMT_TP;		/* .TTP */
		if	(selected(tree, ANWND_SI))
			mypgm.config |= PGMT_SINGLE;
		if	(selected(tree, ANW_WPTH))
			mypgm.config |= PGMT_WINPATH;
		if	(!selected(tree, ANWND_VA))
			mypgm.config |= PGMT_NVASTART;
		if	(!selected(tree, ANWND_PROP_FNT))
			mypgm.config |= PGMT_NO_PROPFNT;
		if	(selected(tree, DO_LIMIT))	/* .PRG */
			mypgm.memlimit = atol(tree[LIMITMEM].ob_spec.tedinfo->te_ptext);
		else	mypgm.memlimit = 0;

		/* Dateiname isolieren und öberlauf testen */
		/* --------------------------------------- */

		only_fname = extract_apname(mypgm.path, fname);
		if	(only_fname < 0)	/* Fehler */
			goto ende;

		/* Test auf énderung des Applikationsnamens */
		/* ---------------------------------------- */

		if	(mypgm.name[0] && stricmp(mypgm.name, fname))
			{
			if	(2 == Rform_alert(1, ALRT_APPNAMECHGD, NULL))
				goto ende;
			}

		/* Name ohne Extension => mypgm.name		*/
		/* Name mit Pfad und Extension => mypgm.path */
		/* ----------------------------------------- */

		strcpy(mypgm.name, fname);
		if	(only_fname)		/* nur Name, kein Pfad */
			mypgm.path[0] = EOS;
		else	if	(!is_absolute_path(mypgm.path))
				{
				Rform_alert(1, ALRT_PATH_NOTABS, NULL);
				goto ende;
				}
		ob_dsel(tree, args.obj);
		insert_pgm(&mypgm);
		goto close_dialog;
		}

	if	(args.obj == ANWND_FS)			/* Dateiauswahl */
		{
		char fname[MAX_NAMELEN];
		char path[MAX_PATHLEN];
		int ex,old;

		path[0] = fname[0] = EOS;
		if	(mypgm.path[0])
			{
			s = get_name(mypgm.path);
			if	(strlen(s) < 64)
				{
				strcpy(fname, s);
				c = *s;
				*s = EOS;
				strcpy(path, mypgm.path);
				*s = c;
				}
			}
		fsel_exinput(path, fname, &ex, Rgetstring(STR_SEARCH_PGM, NULL));
		if	(!ex)
			goto ende;
		strcpy(mypgm.path, path);
		strcpy(get_name(mypgm.path), fname);
		editob = wdlg_get_edit(args.dialog, &cursorpos);
		if	(editob == ANWNDG_T)
			{
			wdlg_set_edit(args.dialog, 0);		/* Cursor abmelden */
			subobj_wdraw(args.dialog, ANWNDG_T, ANWNDG_T, 1);
			wdlg_set_edit(args.dialog, editob);	/* Cursor anmelden */
			}
		else	subobj_wdraw(args.dialog, ANWNDG_T, ANWNDG_T, 1);
		old = mypgm.config;
		mypgm.config &= ~(PGMT_ISGEM+PGMT_TP);
		mypgm.config |= suffixtyp(mypgm.path);

		if	(mypgm.config != old)
			{
			if	(mypgm.config & PGMT_ISGEM)
				ex = ANWND_PR;
			else	{
				if	(mypgm.config & PGMT_TP)
					ex = ANWND_TP;
				else	ex = ANWND_TO;
				}
			objs_setradio(tree, ex,
						ANWND_PR, ANWND_TO, ANWND_TP, 0);
			subobj_wdraw(args.dialog, ANW_XTYP, ANW_XTYP, 1);
			}

		goto ende;
		}

	if	(args.obj == ANWND_CN)			/* Abbruch */
		{
		ob_dsel(tree, args.obj);
		goto close_dialog;
		}

	if	(args.obj == DO_LIMIT)			/* Dateiauswahl */
		{
		if	(selected(tree, DO_LIMIT))
			{
			tree[LIMITMEM].ob_state &= ~DISABLED;
			}
		else	{
			tree[LIMITMEM].ob_state |= DISABLED;
			}
		subobj_wdraw(args.dialog, LIMITMEM, LIMITMEM, 1);
		}

	return(1);

	ende:
	ob_dsel(tree, args.obj);
	subobj_wdraw(args.dialog, args.obj, args.obj, 1);
	return(1);		/* weiter */
}
