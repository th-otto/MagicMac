/*
*
* EnthÑlt die spezifischen Routinen fÅr den Hauptdialog
* fÅr "Dateien kopieren/verschieben/aliasen/lîschen"
*
* sowie fÅr den Fortschrittsdialog mit dem Balken.
*
*/

#define DEBUG 0

#include <tos.h>
#if DEBUG
#include <stdio.h>
#endif
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "mgcopy.h"
#include "beg_dial.h"
#include "cpfiles.h"
#include "globals.h"
#include "toserror.h"

#define OUTPUT_FNAME_LEN	30

int working_is_expanded;

static OBJECT *adr_beg_iconified;
static int	is_iconified,working_is_iconified;
static long n_dat,n_ord;	/* Anzahl Dateien/Ordner */
static long used_src;	/* Benîtigter Speicherplatz */
static long netto_src;	/* fÅr den Fortschrittsbalken */
/* Ziel: */
static long cl_used_dst;	/* soviel brÑuchte eine Kopie */
static long cl_free_dst;	/* soviele Cluster sind auf Zielpfad frei */
static long clsize_dst;	/* Clustergrîûe Zielpfad */


static char *delete_text;	/* =	"Lîsche Dateien";	*/
static char *copy_text;		/* =	"Kopiere Dateien";	*/
static char *alias_text;		/* =	"Aliase erstellen";	*/
static char *move_text;		/* =	"Verschiebe Dateien";	*/

static char *titel;			/* einer der fÅnf vorherigen */

static char *work_ak_text;	/* die gerade ausgefÅhrte Aktion */
static char *work_dt_text;	/* die gerade bearbeitete Datei */


/*********************************************************************
*
* Initialisierung
*
*********************************************************************/

void beg_dial_init_rsc( void )
{
	rsrc_gaddr(0, T_CPMVDL,  &adr_beg);
	rsrc_gaddr(0, T_WORKING, &adr_working);
	rsrc_gaddr(0, T_ICONIF,  &adr_beg_iconified);
	adr_beg_iconified[1].ob_width  = 72;
	adr_beg_iconified[1].ob_height = (adr_beg_iconified[1].ob_spec.iconblk->ib_hicon)+8;

	delete_text	= Rgetstring(STR_DELETEFILES, NULL);
	copy_text		= Rgetstring(STR_COPYFILES, NULL);
	alias_text	= Rgetstring(STR_ALIASFILES, NULL);
	move_text		= Rgetstring(STR_MOVEFILES, NULL);

	work_ak_text = (adr_working+WORK_AK)->ob_spec.tedinfo->te_ptext;
	work_dt_text = (adr_working+WORK_DT)->ob_spec.free_string;

	working_is_expanded = prefs.work_expanded;
	if	(!working_is_expanded)
		{
		objs_hide(adr_working, WORK_AK, WORK_DT, 0);
		adr_working->ob_height -= 3*gl_hhbox;
		adr_working[WORK_STOP].ob_y -= 3*gl_hhbox;
		adr_working[WORK_EXP].ob_spec.obspec.character = 3;
		}
	if	(!is_3d)
		{
		adr_working[WORK_MAXIMAL].ob_spec.obspec.framesize = -1;
		adr_working[WORK_MAXIMAL].ob_spec.obspec.fillpattern = 7;
		adr_working[WORK_AKTUELL].ob_spec.obspec.fillpattern = 4;
		}
	init_messages();
}


/*********************************************************************
*
* Dialogtitel festlegen (statische Variable "titel")
*
*********************************************************************/

void set_dialog_title( int action )
{
	switch(action)
		{
		case 'D': titel = delete_text;
				break;

		case 'C': titel = copy_text;
				break;

		case 'A': titel = alias_text;
				break;

		case 'M': titel = move_text;
				break;
		}
}


/*********************************************************************
*
* Beginn der Aktion
*
*********************************************************************/

long beg_dial_prepare( int argc, char *argv[],
					char *dstpath )
{
	long err;


	Mgraf_mouse(HOURGLASS);

	err = prepare_action(action,
					copy_mode,
					tst_free,
					&n_dat,
					&n_ord,
					&used_src,	/* Brutto-Bytes auf Quelle */
					&cl_used_dst,	/* Brutto-Bytes auf Ziel */
					&netto_src,	/* Netto-Bytes */
					&cl_free_dst,	/* freie Cluster auf Ziel */
					&clsize_dst,
					argc,
					argv,
					dstpath);
#if DEBUG
	printf(
		"\x1b" "H"				/* Cursor -> (0,0) */
		"Anzahl Dateien: %ld\n"
		"Anzahl Ordner: %ld\n"
		"\n"
		"Netto-Speicherbedarf auf Quelle: %ld Bytes\n"
		"Brutto-Speicherbedarf auf Quelle: %ld Bytes\n"
		"\n"
		"freien Speicher auf Ziel prÅfen: %c\n"
		"Zielpfad: %s\n"
		"Brutto-Speicherbedarf auf Ziel: %ld Cluster\n"
		"Clustergrîûe auf Ziel: %ld Bytes\n"
		"Freie Cluster auf Ziel: %ld\n",

		n_dat,
		n_ord,
		netto_src,
		used_src,
		tst_free ? 'J' : 'N',
		(dstpath) ? dstpath : "-- kein Pfad --",
		cl_used_dst,
		clsize_dst,
		cl_free_dst
		);
#endif

	Mgraf_mouse(ARROW);
	if	(err)
		{
		return(err);
		}
	if	(n_dat == 0 && n_ord == 0)		/* keine Objekte */
		{
		return(1);
		}


	if	(((action == 'C') ||
		  (action == 'M') ||
		  (action == 'A')) &&
		  tst_free &&
		 (cl_used_dst > cl_free_dst))
		{
		if	(2 == Rform_alert(2, ALRT_INSUFFSPACE, NULL))
			err = EBREAK;
		}

	return(err);
}

static long count_bytes;		/* zum RunterzÑhlen */
static long beg_count_bytes;

/*********************************************************************
*
* down_cnt:
*  ord =  3: Forschrittsbalken um <bytes> weiter
*  ord =  2: Aktion anzeigen
*  ord =  0: Dateien herunterzÑhlen
*  ord =  1: Ordner herunterzÑhlen
*
*********************************************************************/

void down_cnt( int ord, char *aktion, char *path, long bytes )
{
	int  obj;
	long cnt;
	char *z;
	OBJECT *tree = adr_working;
	char *s;
	char buf[OUTPUT_FNAME_LEN+1];




	if	(ord != 2)
		{
#if DEBUG
		printf(" erledigt: %ld\n", bytes);
#endif
		count_bytes += bytes;
		if	(count_bytes > beg_count_bytes)
			count_bytes = beg_count_bytes;
		if	(count_bytes > 0x7fffffffL/adr_working[WORK_MAXIMAL].ob_width)
			{
			cnt = count_bytes / (beg_count_bytes/adr_working[WORK_MAXIMAL].ob_width);
			}
		else	{
			cnt = count_bytes * adr_working[WORK_MAXIMAL].ob_width;
			cnt /= beg_count_bytes;
			}
		tree[WORK_AKTUELL].ob_width = (int) cnt;

		if	(ord == 1)
			{
			obj = WORK_O;
			cnt = --n_ord;
			goto cnt_tst;
			}
		else
		if	(ord == 0)
			{
			obj = WORK_D;
			cnt = --n_dat;
		  cnt_tst:
			if	((cnt > 99999L) || (cnt < 0))
				return;			/* ??? */
			}
		}

	if	(!d_working || !wind_update(BEG_UPDATE + 0x100))
		return;

	if	(ord == 2)
		{
		s = work_dt_text;
		buf[OUTPUT_FNAME_LEN] = EOS;
		strncpy(buf, get_name(path), OUTPUT_FNAME_LEN+1);
		if	(buf[OUTPUT_FNAME_LEN])
			strcpy(buf+(OUTPUT_FNAME_LEN-3), "...");
		if	(*path != *s || s[1] != ':' || strcmp(s+2, buf))
			{
			*s++ = *path;			/* Laufwerk */
			*s++ = ':';
			strcpy(s, buf);
			if	(!is_iconified)
				subobj_wdraw(d_working, WORK_DT, ROOT, MAX_DEPTH);
			}
		if	(strcmp(work_ak_text, aktion))
			{
			strcpy(work_ak_text, aktion);
			if	(!working_is_iconified)
				subobj_wdraw(d_working, WORK_AK, ROOT, MAX_DEPTH);
			}
		}

	else	{
		if	((bytes) && (!working_is_iconified))
			subobj_wdraw(d_working, WORK_AKTUELL, WORK_AKTUELL, MAX_DEPTH);

		if	((ord == 0) || (ord == 1))
			{
			if	(working_is_iconified)
				{
				GRECT g;
				ICONBLK *ic;
	
				ic = adr_beg_iconified[1].ob_spec.iconblk;
				z = ic->ib_ptext;
				cnt = n_ord + n_dat;
				ultoa(cnt, z, 10);
				objc_grect(adr_beg_iconified, 1, &g);
				g.g_x += ic->ib_xtext;
				g.g_y += ic->ib_ytext;
				g.g_w  = ic->ib_wtext;
				g.g_h  = ic->ib_htext;
				wdlg_redraw(d_working, &g, 0, MAX_DEPTH);
				}
			else	{
				z = (tree+obj)->ob_spec.free_string;
				ultoa(cnt, z, 10);
				subobj_wdraw(d_working, obj, ROOT, MAX_DEPTH);
				}
			}
		}
	wind_update(END_UPDATE);
}


void ackn_cancel( void )
{
	abbruch = FALSE;
	if	((d_working) && (!is_iconified))
		{
		wind_update(BEG_UPDATE);
		adr_working[WORK_STOP].ob_state &= ~(DISABLED+SELECTED);
		subobj_wdraw(d_working, WORK_STOP, WORK_STOP, MAX_DEPTH);
		wind_update(END_UPDATE);
		}
}
		

void close_beg_dialog( void )
{
	if	(d_beg)
		{
		terminate_dialog( &d_beg, &prefs.main_win );
		}
	if	(d_working)
		{
		terminate_dialog( &d_working, &prefs.progr_win );
		}
	send_shwdraw( );
}
		

static ACTIONPARAMETER param;

void beg_dial_action( int argc, char *argv[],
					char *dstpath, int mode )
{
	THREADINFO thi;
	int whdl;


	if	(copy_id <= 0)	/* thread noch nicht aktiv */
		{
		beg_count_bytes = netto_src;
		count_bytes = 0L;
		adr_working[WORK_AKTUELL].ob_width = 0;
#if DEBUG
		printf("Bytes auf Quelle: %ld\n", netto_src);
#endif
		d_working = wdlg_create(hdl_work,
			adr_working,
			NULL,
			mode,
			NULL,
			0);

		if	(!d_working)
			goto errw;

		whdl = wdlg_open( d_working,
					titel,
					NAME+CLOSER+MOVER+SMALLER,
					prefs.progr_win.g_x,prefs.progr_win.g_y,
					0,
					NULL );
		if	(whdl <= 0)
			{
			wdlg_delete(d_working);
			d_working = NULL;
			errw:
			Rform_alert(1, ALRT_ERROPENWIND, NULL);
			return;
			}

		param.action = action;
		param.argc = argc;
		param.argv = argv;
		param.dstpath = dstpath;
		param.mode = mode;

		thi.proc = action_thread;
		thi.user_stack = NULL;
		thi.stacksize = 0x4000L;		/* 16k Userstack */
		thi.mode = 0;
		thi.res1 = 0L;
		copy_id = shel_write(SHW_THR_CREATE, 1, 0, 
						(char *) &thi, (char *) (&param));
		if	(copy_id <= 0)
			{
			form_xerr(ENSMEM, NULL);
			wdlg_close(d_working, NULL, NULL);
			wdlg_delete(d_working);
			d_working = NULL;
			}
		else	run_status = DLG_RUNNING;
		}
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Dialogs
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

WORD	cdecl hdl_beg(struct HNDL_OBJ_args args)
{
	long kbytes;
	OBJECT *tree;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_beg;

	if	(args.obj == HNDL_INIT)
		{
		if	(d_beg)			/* Dialog ist schon geîffnet ! */
			return(0);

		switch(args.clicks)			/* action */
			{
			case 'D': objs_hide(tree, CPMVD_MD, 0);
					break;


			case 'A': ob_sel(tree, CPMVD_KB);
					ob_dsel(tree, CPMVD_RE);
					objs_disable(tree, CPMVD_KA, CPMVD_KU, 0);
					objs_unhide(tree, CPMVD_MD, 0);
					break;

			case 'C':
			case 'M':	objs_unhide(tree, CPMVD_MD, 0);
					objs_enable(tree, CPMVD_KA, CPMVD_KU, 0);
					ob_sel_dsel(tree, CPMVD_KB, copy_mode == CONFIRM);
					ob_sel_dsel(tree, CPMVD_KA, copy_mode == BACKUP);
					ob_sel_dsel(tree, CPMVD_KU, copy_mode == OVERWRITE);
					ob_dsel(tree, CPMVD_RE);
					break;
			}

		(adr_beg+CPMVDL_B)->ob_spec.free_string[0] = EOS;

		ultoa(n_dat, (adr_beg+CPMVDL_D)->ob_spec.free_string, 10);
		ultoa(n_ord, (adr_beg+CPMVDL_O)->ob_spec.free_string, 10);
		if	(args.clicks == 'D')
			kbytes = (used_src+1023L)/1024L;
		else	{
			if	(clsize_dst & 1023L)	/* nicht durch 1024 teilbar */
				{
				if	(clsize_dst & 511L)	/* nicht durch 512 teilbar */
					{
					kbytes = clsize_dst * cl_used_dst;
					kbytes >>= 10L;
					}
				else	{
					kbytes = clsize_dst >> 9L;	/* teile durch 512 */
					kbytes *= cl_used_dst;
					if	(kbytes & 1)
						kbytes++;				/* aufrunden! */
					kbytes >>= 1L;
					}
				}
			else	{
				kbytes = clsize_dst >> 10L;	/* Bytes -> kBytes */
				kbytes *= cl_used_dst;
				}
			}
		ultoa(kbytes, (adr_beg+CPMVDL_B)->ob_spec.free_string, 10);

		ob_dsel(adr_beg, CPMVD_OK);
		ob_dsel(adr_beg, CPMVD_AB);
		adr_beg[CPMVD_OK].ob_state &= ~DISABLED;
		adr_beg[CPMVD_AB].ob_state &= ~DISABLED;
		(adr_beg+CPMVDL_T)->ob_spec.free_string = titel;

		d_beg = args.dialog;
		is_iconified = FALSE;
		return(1);
		}

	/* 2. Fall: Nachricht mit Code >= 1040 empfangen */
	/* --------------------------------------------- */

	if	(args.obj == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		switch(args.events->msg[0])
			{
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
		 							Rgetstring(STR_MAINTITLE,
		 									NULL),
		 							adr_beg);
			 	is_iconified = FALSE;
			 	wind_update(END_UPDATE);
				break;
	
			}
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{

		if	(run_status == DLG_RUNNING)	/* Aktion lÑuft ! */
			goto ende;				/* ignorieren ?!??! */

		close_dialog:
		run_status = DLG_FINISHED;
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)	/* unbekannte Unterfunktion */
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	if	(args.obj == CPMVD_AB)			/* Abbruch */
		{
		if	(run_status == DLG_WAITING)	/* keine Aktion lÑuft */
			goto close_dialog;
		goto ende;		/* ignorieren ?!!??? */
		}

	if	(args.obj == CPMVD_OK)			/* OK */
		{
		if	(selected(adr_beg, CPMVD_KB))
			copy_mode = CONFIRM;
		if	(selected(adr_beg, CPMVD_KA))
			copy_mode = BACKUP;
		if	(selected(adr_beg, CPMVD_KU))
			copy_mode = OVERWRITE;
		if	(selected(adr_beg, CPMVD_RE))
			copy_mode = RENAME;

		/* Jetzt geht es los */

		beg_dial_action(nargs-2, xargv+2, dst_path, copy_mode);

		if	(run_status == DLG_RUNNING)	/* OK ? */
			{
			return(0);		/* Dialog schlieûen */
			}
		}

	return(1);

	ende:
	ob_dsel(tree, args.obj);
	subobj_wdraw(args.dialog, args.obj, args.obj, 0);
	return(1);		/* weiter */
}


/*********************************************************************
*
* Behandelt die Exit- Objekte des Fortschrittsdialogs
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

WORD	cdecl hdl_work(struct HNDL_OBJ_args args)
{
	OBJECT *tree;


	/* 1. Fall: Dialog soll geîffnet werden */
	/* ------------------------------------ */

	tree = adr_working;

	if	(args.obj == HNDL_INIT)
		{
		if	(d_working)		/* Dialog ist schon geîffnet ! */
			return(0);

		work_ak_text[0] = EOS;
		work_dt_text[0] = EOS;

		ultoa(n_dat, (tree+WORK_D)->ob_spec.free_string, 10);
		ultoa(n_ord, (tree+WORK_O)->ob_spec.free_string, 10);

		ob_dsel(tree, WORK_STOP);
		tree[WORK_STOP].ob_state &= ~DISABLED;

		d_working = args.dialog;
		working_is_iconified = FALSE;
		return(1);
		}

	/* 2. Fall: Nachricht mit Code >= 1040 empfangen */
	/* --------------------------------------------- */

	if	(args.obj == HNDL_MESG)	/* Wenn Nachricht empfangen... */
		{
		switch(args.events->msg[0])
			{
			 case WM_ALLICONIFY:
	
			 case WM_ICONIFY:
			 	wind_update(BEG_UPDATE);
			 	wdlg_set_iconify(args.dialog, (GRECT *) (args.events->msg+4),
	 							" MGCOPY ",
	 							adr_beg_iconified, 1);
			 	working_is_iconified = TRUE;
			 	wind_update(END_UPDATE);
			 	break;
	
			 case WM_UNICONIFY:
			 	wind_update(BEG_UPDATE);
			 	wdlg_set_uniconify(args.dialog, (GRECT *) (args.events->msg+4),
		 							titel,
		 							adr_working);
			 	working_is_iconified = FALSE;
			 	wind_update(END_UPDATE);
				break;
	
			}
		return(1);		/* weiter */
		}

	/* 3. Fall: Dialog soll geschlossen werden */
	/* --------------------------------------- */

	if	(args.obj == HNDL_CLSD)	/* Wenn Dialog geschlossen werden soll... */
		{

		if	(run_status == DLG_RUNNING)	/* Aktion lÑuft ! */
			{
			args.obj = WORK_STOP;
			goto do_abbruch;
			}

		close_dialog:
		run_status = DLG_FINISHED;
		return(0);		/* ...dann schlieûen wir ihn auch */
		}

	if	(args.obj < 0)	/* unbekannte Unterfunktion */
		return(1);

	/* 4. Fall: Exitbutton wurde betÑtigt */
	/* ---------------------------------- */

	if	(args.clicks != 1)
		goto ende;

	if	(args.obj == WORK_EXP)			/* erweiterter Modus */
		{
		int handle = wdlg_get_handle(args.dialog);
		GRECT g;
		int ydiff = 3*gl_hhbox;
		char c;

		working_is_expanded = !working_is_expanded;
		wind_get_grect(handle, WF_CURRXYWH, &g);
		if	(working_is_expanded)
			{
			objs_unhide(tree, WORK_AK, WORK_DT, 0);
			objs_hide(tree, WORK_STOP, 0);
			subobj_wdraw(d_working, WORK_STOP, ROOT, MAX_DEPTH);
			c = 2;	/* Pfeil nach unten */
			}
		else	{
			objs_hide(tree, WORK_AK, WORK_DT, 0);
			ydiff = -ydiff;
			c = 3;	/* Pfeil nach rechts */
			}
		tree->ob_height += ydiff;
		g.g_h += ydiff;
		tree[WORK_STOP].ob_y += ydiff;
		wind_set_grect(handle, WF_CURRXYWH, &g);
		if	(working_is_expanded)
			objs_unhide(tree, WORK_STOP, 0);
		else	subobj_wdraw(d_working, WORK_STOP, ROOT, MAX_DEPTH);
		tree[WORK_EXP].ob_spec.obspec.character = c;
		goto ende;	/* deselektieren */
		}

	if	(args.obj == WORK_STOP)		/* Abbruch */
		{
		if	(run_status == DLG_WAITING)	/* keine Aktion lÑuft */
			{
			goto close_dialog;
			}
	do_abbruch:
		tree[WORK_STOP].ob_state |= DISABLED;

		/* ggf. Thread aufwecken */
		/* --------------------- */

		if	(copy_id > 0)
			{
			int message[8];

			message[0] = 1031;		/* Nachrichtennummer */
			message[1] = ap_id;		/* Absender */
			message[2] = 0;		/* öberlÑnge */
			appl_write(copy_id, 16, message);
			}
		abbruch = TRUE;
		goto ende2;
		}

	return(1);

	ende:
	ob_dsel(tree, args.obj);
	ende2:
	subobj_wdraw(args.dialog, args.obj, args.obj, 0);
	return(1);		/* weiter */
}
