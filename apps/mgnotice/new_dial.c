/*
*
* EnthÑlt die spezifischen Routinen fÅr den Hauptdialog
* "Nachricht eingeben oder Ñndern"
*
*/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "toserror.h"
#include "windows.h"
#include "globals.h"
#include "de/mgnotice.h"

/* Zeilen / Anzahl Zeichen pro Zeile */

#define LINES 5
#define LINEWIDTH 40

static unsigned char *mem;		/* LINES * (LINEWIDTH+1) Bytes */
static int id_code;				/* editiertes Fenster, -1 = Neu */
static int line_objs[LINES] = {
						INPUT_T1,
						INPUT_T2,
						INPUT_T3,
						INPUT_T4,
						INPUT_T5
						};

/*********************************************************************
*
* Initialisierung
*
*********************************************************************/

void input_dial_init_rsc( void )
{
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs
* Beim Initialisieren wird in <data> ggf. ein Zeiger auf einen
* Text Åbergeben.
*
*********************************************************************/

WORD cdecl hdl_input(struct HNDL_OBJ_args args)
{
	OBJECT *tree;
	WINDOW *newwin;
	unsigned char *s,*t,*u;
	register int i;
	long l;
	long errcode;



	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_input;

	if	(args.obj == HNDL_INIT)
		{
		if	(d_input)			/* Dialog ist schon geîffnet ! */
			return(0);
		mem = Malloc(LINES * (LINEWIDTH+2) + 1);
		if	(!mem)
			{
			form_xerr(ENSMEM, NULL);
			return(0);		/* zuwenig Speicher */
			}

		ob_dsel(tree, INPUT_OK);
		ob_dsel(tree, INPUT_CANCEL);

		id_code = args.clicks;		/* Fenster-Code */

		for	(s = mem, i = 0; i < LINES; i++)
			{
			*s = EOS;
			if	(args.data)
				{
				t = get_line((unsigned char *) args.data, i, &l);
				if	(t)
					memcpy(s, t, l);
				s[l] = EOS;
				}

			tree[line_objs[i]].ob_spec.tedinfo->te_txtlen =
						LINEWIDTH+1;
			tree[line_objs[i]].ob_spec.tedinfo->te_ptext =
						(char *) s;
			s += LINEWIDTH+2;
			}
		return(1);
		}

	/* 2. Fall: Nachricht mit Code >= 1040 empfangen */
	/* --------------------------------------------- */

	if	(args.obj == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		switch(args.events->msg[0])
			{
#if 0
			 case WM_ALLICONIFY:
	
			 case WM_ICONIFY:
			 	wind_update(BEG_UPDATE);
			 	wdlg_set_iconify(args.dialog, (GRECT *) (args.events->msg+4),
	 							" MGCOPY ",
	 							adr_beg_iconified, 1);
			 	is_iconified = TRUE;
			 	wind_update(END_UPDATE);
			 	break;
	
			 case WM_UNICONIFY:
			 	wind_update(BEG_UPDATE);
			 	wdlg_set_uniconify(args.dialog, (GRECT *) (args.events->msg+4),
		 							Rgetstring(STR_MAINTITLE, global),
		 							adr_beg);
			 	is_iconified = FALSE;
			 	wind_update(END_UPDATE);
				break;
#endif
			}
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		Mfree(mem);
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)	/* unbekannte Unterfunktion */
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	if	(args.obj == INPUT_CANCEL)		/* Abbruch */
		{
		goto close_dialog;
		}

	if	(args.obj == INPUT_OK)			/* OK */
		{
		/* Speicherbedarf ermitteln und Zeilen komprimieren */
		for	(s = t = u = mem, i = 0; i < LINES; i++)
			{
			l = strlen((char *) s);
			if	(s != t)
				memmove(t, s, l);
			t += l;
			*t++ = '\r';
			*t++ = '\n';
			s += LINEWIDTH+2;
			if	(l)
				u = t;
			}
		*u++ = '\0';
		Mshrink(mem, u-mem);

		if	(id_code < 0)
			{
			/* Neues Fenster */
			errcode = open_notice_wind( mem, -1,
							tree->ob_x, tree->ob_y,
							prefs.fontID,
							prefs.fontprop,
							prefs.fontH,
							prefs.colour,
							&newwin );
			if	(errcode)
				{
				Mfree(mem);
				form_xerr(errcode, NULL);
				}
			else	{
				select_window(newwin);
				save_notice(newwin, notice_path);
				}
			}
		else	{
			if	(edit_notice_wind( mem, id_code, &newwin))
				Mfree(mem);
			else	save_notice(newwin, notice_path);
			}

		return(0);
		}

	return(1);

	ende:
	ob_dsel(tree, args.obj);
	subobj_wdraw(args.dialog, args.obj, args.obj, 0);
	return(1);		/* weiter */
}
