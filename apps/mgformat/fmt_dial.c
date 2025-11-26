/*
*
* EnthÑlt die spezifischen Routinen fÅr den Dialog
* "Formatieren"
*
*/

#include <tos.h>
#include <aes.h>
#include <mt_aes.h>
#include <string.h>
#include <stdlib.h>
#include <country.h>
#include "de/mgformat.h"
#include "gemut_mt.h"
#include "globals.h"


int tmpdrv;
OBJECT *adr_format;
OBJECT *adr_fmtopt;

static int is_iconified = FALSE;
static int src_dev;
static struct fmt_parameter fmt_parameter;


/****************************************************************
*
* Malt ein Unterobjekt. Wenn es sich um eine Zahl handelt, wird
* sie ausgegeben, sonst ggf. der String
*
****************************************************************/

void MYsubobj_wdraw(DIALOG *d, int obj, int n, char *s)
{
	char *z;
	OBJECT *tree;
	GRECT g;


	wdlg_get_tree( d, &tree, &g );
	z = (tree+obj)->ob_spec.free_string;
	if	(s)
		strcpy(z,s);
	else if	(n >= 0)
			ultoa(n, z, 10);

	objc_grect(tree, obj, &g);
	wdlg_redraw( d, &g, 0, MAX_DEPTH );
}


/*********************************************************************
*
* Initialisierung der Objektklasse "Formatierdialog"
*
*********************************************************************/

void fmt_dial_init_rsc( int devno, int init, int only )
{
	src_dev = devno;

	tmpdrv = prefs.tmpdrv;		/* -> CPY_DIAL */
	mt_rsrc_gaddr(0, T_FORMAT, &adr_format, global);
	mt_rsrc_gaddr(0, T_FMTOPT, &adr_fmtopt, global);
	/* Laufwerkbuchstaben einsetzen */
	drv_to_str(((adr_format+FORMAT_T)->ob_spec.tedinfo)->te_ptmplt, letter_from_drive(src_dev));
	/* Diskname fÅrs Formatieren auf "" setzen 	*/
	*((adr_format+FORMAT_T)->ob_spec.tedinfo)->te_ptext = EOS;
	/* Gruppenrahmen anpassen */
	(adr_format+FORMT_R1)->ob_y -= gl_hhchar >> 1;
	/* TemporÑrlaufwerk eintragen bzw. Disablen */
	((adr_fmtopt+FMOPT_TM)->ob_spec.tedinfo)->te_ptext[0] = tmpdrv;
	if	(only)
		(adr_fmtopt + FMOPT_TM)->ob_state |=  DISABLED;

	if	(init)
		{
		(adr_format + FORMT_OK)->ob_state |=  DISABLED;
		(adr_format + FORMT_EX)->ob_state |=  DISABLED;
		(adr_format + FORMT_S1)->ob_state |=  DISABLED;
		(adr_format + FORMT_S2)->ob_state |=  DISABLED;
		(adr_format + FORMT_DD)->ob_state |=  DISABLED;
		(adr_format + FORMT_HD)->ob_state |=  DISABLED;
		(adr_format + TRK_MINU)->ob_state |=  DISABLED;
		(adr_format + TRK_PLUS)->ob_state |=  DISABLED;
		(adr_format + TRK_NUM )->ob_state |=  DISABLED;
		(adr_format + SEC_MINU)->ob_state |=  DISABLED;
		(adr_format + SEC_PLUS)->ob_state |=  DISABLED;
		(adr_format + SEC_NUM )->ob_state |=  DISABLED;
		(adr_format + FORMT_R1)->ob_state |=  DISABLED;
		(adr_format + FORMT_T1)->ob_state |=  DISABLED;
		(adr_format + FORMT_T2)->ob_state |=  DISABLED;
		(adr_format + FORMT_T3)->ob_state |=  DISABLED;
		}
}


static void up_cnt( DIALOG *d, int n )
{
	MYsubobj_wdraw(d, FORMT_DT, n, NULL);
}


/*********************************************************************
*
* Schickt eine Nachricht an FORMAT.OVL.
*
*********************************************************************/

int fmt_id = -1;

int send_message(int message[8])
{
	extern int ap_id;

	if	(fmt_id >= 0)
		{
		message[1] = ap_id;		/* Absender */
		message[2] = 0;		/* öberlÑnge */
		return(appl_write(fmt_id, 16, message));
		}
	else	return(0);
}


/*********************************************************************
*
* Startet den Formatier-Thread.
*
*********************************************************************/

int start_format( void *param )
{
	THREADINFO thi;

	if	(fmt_id < 0)			/* Thread noch nicht aktiv */
		{
		thi.proc = (void *) format_thread;
		thi.user_stack = NULL;
		thi.stacksize = 4096L;
		thi.mode = 0;
		thi.res1 = 0L;
		fmt_id = shel_write(SHW_THR_CREATE, 1, 0, 
						(char *) &thi, param);
		return(fmt_id);
		}
	return(-1);				/* Thread lÑuft noch */
}


/*********************************************************************
*
* Schickt Abbruchbefehl an FORMAT.OVL.
* Wenn <hard>, wird FORMAT.OVL beendet
*
*********************************************************************/

int send_message_break( int whdl )
{
	int message[8];

	if	(fmt_id >= 0)
		{
		message[0] = 1031;
		message[1] = ap_id;		/* Absender */
		message[2] = 0;		/* öberlÑnge */
		message[3] = whdl;		/* Abschickendes Fenster */
		return(appl_write(fmt_id, 16, message));
		}
	return(0);
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Optionendialogs
* Das Exit-Objekt <objnr> wurde mit <clicks> Klicks angewÑhlt.
*
* objnr = -1:	Initialisierung.
*			d->user_data und d->dialog_tree initialisieren!
*		-2:	Nachricht
* 		-3:	Fenster wurde durch Closebutton geschlossen.
*		-4:	Programm wurde beendet.
*
* RÅckgabe:	0	Dialog schlieûen
*			< 0	Fehlercode
*
*********************************************************************/


WORD cdecl hdl_fmtopt(struct HNDL_OBJ_args args)
{
	static char _inter,_spurver,_seitenver,_clsize;
	int	tmplw;
	char *inter,*spurv,*seitv,*clust;
	char *r;
	register int i,obj;
	OBJECT *tree;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_fmtopt;

	if	(args.obj == HNDL_INIT)
		{
		if	(d_fmtopt)			/* Dialog ist schon geîffnet ! */
			return(0);
		d_fmtopt = args.dialog;

		r = (adr_fmtopt+INT_NUM)->ob_spec.free_string;
		ultoa(prefs.interlv, r, 10);
		r = (adr_fmtopt+SPV_NUM)->ob_spec.free_string;
		ultoa(prefs.trkincr, r, 10);
		r = (adr_fmtopt+SEV_NUM)->ob_spec.free_string;
		ultoa(prefs.sidincr, r, 10);
		r = (adr_fmtopt+CLU_NUM)->ob_spec.free_string;
		ultoa(prefs.clustsize, r, 10);
		((adr_fmtopt+FMOPT_TM)->ob_spec.tedinfo)->te_ptext[0] = letter_from_drive(prefs.tmpdrv);

		return(1);
		}

	/* 2. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		d_fmtopt = NULL;
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)
		return(1);

	/* 3. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	inter = (tree + INT_NUM)->ob_spec.free_string;
	spurv = (tree + SPV_NUM)->ob_spec.free_string;
	seitv = (tree + SEV_NUM)->ob_spec.free_string;
	clust = (tree + CLU_NUM)->ob_spec.free_string;
	_inter     = atoi(inter);
	_spurver   = atoi(spurv);
	_seitenver = atoi(seitv);
	_clsize	 = atoi(clust);
	obj = 0;
	if	(args.obj == INT_MINU || args.obj == INT_PLUS)
		{
		obj = INT_NUM;
		r = &_inter;
		i = (args.obj == INT_MINU) ? -1 : 1;
		}
	if	(args.obj == SPV_MINU || args.obj == SPV_PLUS)
		{
		obj = SPV_NUM;
		r = &_spurver;
		i = (args.obj == SPV_MINU) ? -1 : 1;
		}
	if	(args.obj == SEV_MINU || args.obj == SEV_PLUS)
		{
		obj = SEV_NUM;
		r = &_seitenver;
		i = (args.obj == SEV_MINU) ? -1 : 1;
		}
	if	(args.obj == CLU_MINU || args.obj == CLU_PLUS)
		{
		obj = CLU_NUM;
		r = &_clsize;
		i = (args.obj == CLU_MINU) ? -(_clsize >> 1) : _clsize;
		}
	if	(obj)
		{
		if	(*r + i >= 0 && *r + i <= 99)
			{
			*r += i;
			MYsubobj_wdraw(args.dialog, obj, *r, NULL);
			}
		return(1);		/* weitermachen */
		}

	if	((args.obj == FMOPT_OK) || (args.obj == FMOPT_SV))
		{
		tmplw = ((adr_fmtopt+FMOPT_TM)->ob_spec.tedinfo)->te_ptext[0];
		if	(tmplw == 0 || tmplw == '@')
			tmplw = -1;			/* Kein TemporÑrlaufwerk */
		else {
			tmplw = drive_from_letter(tmplw);
			if	(tmplw < 0 || 0 == (Drvmap() & (1 << tmplw)))
				{
				Rform_alert(1, AL_TMPINV, global);
				ob_dsel(tree, args.obj);
				MYsubobj_wdraw(args.dialog, args.obj,  -1, NULL);
				return(1);
				}
			}
	
		prefs.interlv		= _inter;
		prefs.trkincr		= _spurver;
		prefs.sidincr		= _seitenver;
		prefs.clustsize	= _clsize;
		prefs.tmpdrv		= tmpdrv = tmplw;

		if	(args.obj == FMOPT_SV)
			write_inf();
		}

	ende:
	ob_dsel(tree, args.obj);
	MYsubobj_wdraw(args.dialog, args.obj,  -1, NULL);
	return(0);		/* Ende */
}


/*********************************************************************
*
* ôffnet den Dialog "Formatieroptionen".
* Gibt das Fensterhandle zurÅck oder 0.
*
*********************************************************************/

int open_format_options( void )
{
	int whdl;
	void *dialog_fmtopt;

	dialog_fmtopt = wdlg_create(hdl_fmtopt,
							adr_fmtopt,
							NULL,
							0,
							NULL,
							0);
	if	(!dialog_fmtopt)
		goto fehler;

	whdl = wdlg_open( dialog_fmtopt,
						"FORMAT-OPTIONS",
						NAME+CLOSER+MOVER,
						-1,-1,
						0,
						NULL );
	if	(!whdl)
		{
		wdlg_delete(dialog_fmtopt);
	 fehler:
		Rform_alert(1, AL_OPENWIND, global);
		return(0);
		}

	return(whdl);
}

		
/*********************************************************************
*
* Behandelt die Exit- Objekte des Formatierdialogs
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

WORD	cdecl hdl_format(struct HNDL_OBJ_args args)
{
	OBJECT *tree;
	char *t,*s;
	int *r;
	char *dname;
	register int i,obj;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_format;

	if	(args.obj == HNDL_INIT)
		{
		if	(d_format)			/* Dialog ist schon geîffnet ! */
			return(0);

		if	((adr_format + FORMT_OK)->ob_state & DISABLED)
			{
			if	(2 == Rxform_alert(2, AL_DEL_ALL, letter_from_drive(src_dev),
							NULL, global))
				return(0);	/* Dialog nicht îffnen */
			}

		if	(prefs.sides == 2)
			{
			ob_dsel(adr_format, FORMT_S1);
			ob_sel (adr_format, FORMT_S2);
			}
		else {
			ob_dsel(adr_format, FORMT_S2);
			ob_sel (adr_format, FORMT_S1);
			}
		s = (adr_format+TRK_NUM)->ob_spec.free_string;
		ultoa(prefs.tracks,  s, 10);
		s = (adr_format+SEC_NUM)->ob_spec.free_string;
		ultoa(prefs.sectors, s, 10);
		objs_hide(adr_format, FORMT_H1, FORMT_DT, 0);

		d_format = args.dialog;
		return(1);
		}

	/* 2. Fall: Fensternachricht empfangen */
	/* ----------------------------------- */

	if	(args.obj == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		switch(args.events->msg[0])
			{
			 case WM_ALLICONIFY:
	
			 case WM_ICONIFY:
			 	wdlg_set_iconify(args.dialog, (GRECT *) (args.events->msg+4),
			 							" MGFORMAT ",
			 							adr_iconified, 1);
			 	is_iconified = TRUE;
			 	break;
	
			 case WM_UNICONIFY:
			 	wdlg_set_uniconify(args.dialog, (GRECT *) (args.events->msg+4),
			 							"DISKFORMAT",
			 							adr_format);
			 	is_iconified = FALSE;
				break;

			case 1040:
					if	(is_iconified)
						break;

					if	(wind_update(BEG_UPDATE | 0x100))
						{
						up_cnt(args.dialog, args.events->msg[4]);
						wind_update(END_UPDATE);
						}
					break;
			case 1041:
					if	(args.events->msg[4] == 0)
						Rform_alert(1, AL_COMPLETE, global);

					goto abbruch;
			case 1042:
					Rform_alert(1, AL_BREAK, global);
					abbruch:
					wind_update(BEG_UPDATE);
					objs_hide(tree, FORMT_H1, FORMT_DT, 0);
					if	(!is_iconified)
						{
						MYsubobj_wdraw(args.dialog, FORMT_H1, -1, NULL);
						MYsubobj_wdraw(args.dialog, FORMT_DT, -1, NULL);
						}
					if	(selected(tree, FORMT_OK) || selected(tree, FORMT_IN))	/* Formatieren aktiv */
						{
						ob_dsel(tree, FORMT_OK);
						ob_dsel(tree, FORMT_IN);
						(tree+FORMT_IN)->ob_state &= ~DISABLED;
						if	(!is_iconified)
							MYsubobj_wdraw(args.dialog, FORMT_IN,  -1, NULL);
						if	(!((adr_format + FORMT_R1)->ob_state & DISABLED))
							{
							(tree+FORMT_OK)->ob_state &= ~DISABLED;
							if	(!is_iconified)
								MYsubobj_wdraw(args.dialog, FORMT_OK,  -1, NULL);
							}
						}
					wind_update(END_UPDATE);
					break;
			}
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{
		close_dialog:
		d_format = NULL;
		send_message_break(wdlg_get_handle( args.dialog ));
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	if	(args.obj == FORMT_EX)
		{
		open_format_options();
		goto ende;
		}

	s = (tree + SEC_NUM)->ob_spec.free_string;
	t = (tree + TRK_NUM)->ob_spec.free_string;
	prefs.tracks  = atoi(t);
	prefs.sectors = atoi(s);
	obj = 0;
	if	((args.obj == FORMT_DD) || (args.obj == FORMT_HD))
		{
		int dummy;

		prefs.sides	= 2;
		if	(selected(tree, FORMT_S1))
			form_button(tree, FORMT_S2, 1, &dummy);
		prefs.tracks  = 80;
		prefs.sectors = (args.obj == FORMT_HD) ? 18 : 9;
		if	(!is_iconified)
			{
			MYsubobj_wdraw(args.dialog, TRK_NUM,  prefs.tracks, NULL);
			MYsubobj_wdraw(args.dialog, SEC_NUM, prefs.sectors, NULL);
			}
		goto ende;
		}
	if	(args.obj == TRK_PLUS)
		{
		obj = TRK_NUM;
		r = &prefs.tracks;
		i = 1;
		}
	if	(args.obj == TRK_MINU)
		{
		obj = TRK_NUM;
		r = &prefs.tracks;
		i = -1;
		}
	if	(args.obj == SEC_MINU)
		{
		obj = SEC_NUM;
		r = &prefs.sectors;
		i = -1;
		}
	if	(args.obj == SEC_PLUS)
		{
		obj = SEC_NUM;
		r = &prefs.sectors;
		i = 1;
		}
	if	(obj)
		{
		if	(*r + i >= 5 && *r + i <= 99)
			{
			*r += i;
			MYsubobj_wdraw(args.dialog, obj, *r, NULL);
			}
		return(1);
		}

	prefs.sides   = (selected(tree, FORMT_S1)) ? 1 : 2;
	if	(args.obj == FORMT_AB)		/* Abbruch */
		{
		if	(selected(tree, FORMT_OK) || selected(tree, FORMT_IN))		/* Formatieren aktiv */
			{
			send_message_break(wdlg_get_handle( args.dialog ));	/* Formatieren abbrechen */
			goto ende;
			}
		goto close_dialog;				/* Ende */
		}

	/* "Formatieren" oder "Initialisieren" */
	/* ----------------------------------- */

	dname = ((tree+FORMAT_T)->ob_spec.tedinfo)->te_ptext;
	fname_ext(dname, fmt_parameter.diskname);
	objs_unhide(tree, FORMT_H1, FORMT_DT, 0);
	if	(!is_iconified)
		MYsubobj_wdraw(args.dialog, FORMT_H1, -1, NULL);

	fmt_parameter.action = action_format;
	fmt_parameter.apid = ap_id;
	fmt_parameter.whdl = wdlg_get_handle( args.dialog );
	fmt_parameter.device = src_dev;
	fmt_parameter.do_logical = (args.obj == FORMT_IN);
	start_format(&fmt_parameter);

	(tree+FORMT_OK)->ob_state |= DISABLED;
	(tree+FORMT_IN)->ob_state |= DISABLED;
	if	(!is_iconified)
		{
		MYsubobj_wdraw(args.dialog, FORMT_OK,  -1, NULL);
		MYsubobj_wdraw(args.dialog, FORMT_IN,  -1, NULL);
		}
	return(1);

	ende:
	ob_dsel(tree, args.obj);
	MYsubobj_wdraw(args.dialog, args.obj,  -1, NULL);
	return(1);		/* weiter */
}
