/*******************************************************************
*
*             APPLICAT.APP                             21.03.94
*             ============
*                                 letzte énderung:	2.5.98
*
* geschrieben mit Pure C V1.1
* Projektdatei: APPLICAT.PRJ
*
* Modul zur Iconauswahl und Anwendung anmelden.
* Parameter:
*
*	-c				; APPLICAT.DAT neu aufbauen
*
*	-aa	appath		; Applikation anmelden
*	-ad	appath dat	; angemeldete Datei modifizieren
*
*	-ia	appath		; Icon fÅr Programm anmelden
*	-id	apname dat	; Icon fÅr Datei anmelden
*					; ggf. <apname> == "<>"
*	-io	opath		; Icon fÅr Ordner/Disk anmelden
*	-is	key[4]		; Icon fÅr "special object" anmelden
*
*
* ----------------------------------------------------------------
*
* Textdatei fÅr APPLICAT:
* Konfigurationsdatei applicat.inf:
*
*	magic			; Zeile mit "applicat.inf" und Versionsnummer
*	[Programmname]
*	.... (Programmdaten):
*		Icon mit RSC-Dateiname, Icon-Name und Index (oder Leerzeile)
*		kompletter Pfad oder Leerzeile
*		Konfigurationsangaben im Klartext ("TTP", "Single")
*		Dateitypen, jeweils einer pro Zeile
*	[Programmname]
*	.... (Programmdaten)
*	[Dateityp]
*	.... (Dateidaten)
*		Icon mit RSC-Dateiname, Icon-Name und Index (oder Leerzeile)
*
*	
*
* BinÑrdatei fÅr MAGXDESK:
* Konfigurationsdatei magxdesk.icn:
*
*	long magic;		'APNF'
*	int ver;			0	(Versionskennung)
*	int n_icons;
*	int n_pgm;		Anzahl ProgrammeintrÑge
*	int n_dat;		Anzahl DateieintrÑge
*	long	offs_pgm;
*	long	offs_dat;		Zeiger auf Tabelle der Daten-Dateien
*	void *pgmx[n_pgm];	Angemeldete Programme
*	void *datx[n_dat];	Angemeldete Dateitypen
*	void *icons[n_icons];
*
*	 Icons:
*	ICONBLK
*
*	 Programme:
*	char name[?];		Dateiname ohne Extension, nullterminiert,
*	char cpath[?]		kompletter Pfadname nullterminiert,
*					auf gerade Adresse erweitert
*					ggf. '\0', wenn kein Pfad bekannt ist.
*	int	icon;		Index fÅr Icon (ggf. auch Standardicon)
*	int config;		Konfigurationsbits (TTP/Single...)
*	int types[?];		Index auf Dateitypen, durch -1
*					abgeschlossen
*
*	 Daten:
*	char name[?];		Extension, nullterminiert,
*					auf gerade Adresse erweitert
*	int	icon;		Index fÅr Icon (ggf. auch Standardicon)
*
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "windows.h"
#include "applicat.h"
#include "gemut_mt.h"

#include "anw_dial.h"
#include "typ_dial.h"
#include "ica_dial.h"

#include "icp_dial.h"
#include "pth_dial.h"

#include "spc_dial.h"

#include "appl.h"
#include "appldata.h"
#include "iconsel.h"

int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int	is_3d;
GRECT scrg;

int is_multiwindow;		/* alle Fenster sind offen */

int spcn	= 0;			/* Anzahl Spezialobjekte */
int pthn	= 0;			/* Anzahl Pfade */
int datn	= 0;			/* Anzahl Dateitypen */
int pgmn	= 0;			/* Anzahl Programme */
int icnn  = 0;			/* Anzahl Icons */
int linn  = 0;			/* Anzahl Zeilen */
int rscn	= 0;			/* Anzahl RSC-Dateien */
struct pgm_file pgmx[MAX_PGMN];
struct dat_file datx[MAX_DATN];
struct pth_file pthx[MAX_PTHN];
struct spc_file spcx[MAX_SPCN];
struct icon	 icnx[MAX_ICNN];
struct zeile	 linx[MAX_LINN];
struct iconfile rscx[MAX_RSCN];


void open_work		(void);
void close_work     (void);

static void _rsrc_load( char *fname );
void  Mgraf_mouse(int type);

/* Dialoge */

DIALOG *d_ica = NULL;			/* Icons fÅr Applikationen */
OBJECT *adr_ica_dialog;

DIALOG *d_icp = NULL;			/* Icons fÅr Pfade */
OBJECT *adr_icp_dialog;

DIALOG *d_spc = NULL;			/* Spezial-Icons */
OBJECT *adr_spc_dialog;

DIALOG *d_anw = NULL;			/* Anwendung anmelden */
OBJECT *adr_anwndg;

DIALOG *d_pth = NULL;			/* Pfade anmelden */
OBJECT *adr_newpath;

DIALOG *d_typ = NULL;			/* Dateityp anmelden */
OBJECT *adr_ftypes;


/********************************************
* Hauptprogramm
********************************************/

int main( int argc, char *argv[] )
{
	EVNT w_ev;
	int	whdl;
	char	action[2] = {0,0};
	char *args[2] = {NULL, NULL};
	WINDOW *w;
	int dummy;
	WORD intin2;


	Pdomain(1);
	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	Mrsrc_load("applicat.rsc", NULL);
	objc_sysvar(0, MX_ENABLE3D, 0, 0, &is_3d, &dummy);
	wind_get_grect(SCREEN, WF_WORKXYWH, &scrg);
	vdi_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	/* INF- Datei einlesen */
	/* ------------------- */

	if	(get_inf())
		return(-1);

	/* Kommandozeile auswerten */
	/* ----------------------- */

	if	(argc > 1)
		{
		if	(argv[1][0] != '-')
			{
			par_err:
			Rform_alert(1, ALRT_ERRARG, NULL);
			return(-1);
			}
		action[0] = argv[1][1];
		if	(!action[0])
			goto par_err;
		action[1] = argv[1][2];
		if	(argc > 2)
			args[0] = argv[2];
		if	(argc > 3)
			args[1] = argv[3];
		}


	open_work();
	load_icons();
	load_int_icons();

	if	((action[0] == 'c') && (!action[1]))
		{
		/* nur compilieren */
		put_inf();
		goto fehler;
		}

	rsrc_gtree(T_APPS, &adr_ica_dialog);
	ica_dial_init_rsc();
	rsrc_gtree(T_FOLDRS, &adr_icp_dialog);
	icp_dial_init_rsc();
	rsrc_gtree(T_SPECIA, &adr_spc_dialog);
	spc_dial_init_rsc();

	rsrc_gtree(T_ANWNDG, &adr_anwndg);
	anw_dial_init_rsc();

	rsrc_gtree(T_FTYPES, &adr_ftypes);
	typ_dial_init_rsc();

	rsrc_gtree(T_NEWFLD, &adr_newpath);
	pth_dial_init_rsc();


	init_iconsel();

	Mgraf_mouse(ARROW);


	is_multiwindow = FALSE;

	if	(action[0] == 'i')
		{
		open_iconsel();
		switch(action[1])
			{
		 case 'a':
		 		d_ica = xy_wdlg_init(
		 				hdl_ica,
		 				adr_ica_dialog,
		 				"APPLICATIONS",
		 				0,
		 				args,
		 				STR_WINTITLE_APP);
				if	(!d_ica)
					goto fehler;
				break;
		 case 'd':
		 		d_ica = xy_wdlg_init(
		 				hdl_ica,
		 				adr_ica_dialog,
		 				"APPLICATIONS",
		 				1,
		 				args,
		 				STR_WINTITLE_APP);
				if	(!d_ica)
					goto fehler;
				break;
		 case 'o':
		 		d_icp = xy_wdlg_init(
		 				hdl_icp,
		 				adr_icp_dialog,
		 				"PATHS",
		 				0,
		 				args,
		 				STR_WINTITLE_PTH);
				if	(!d_icp)
					goto fehler;
				break;
		 case 's':
		 		d_spc = xy_wdlg_init(
		 				hdl_spc,
		 				adr_spc_dialog,
		 				"SPECIAL",
		 				0,
		 				args,
		 				STR_WINTITLE_SPC);
				if	(!d_spc)
					goto fehler;
				break;
			}
		}
	else
	if	(action[0] == 'a')
		{
 		d_ica = xy_wdlg_init(
 				hdl_ica,
 				adr_ica_dialog,
 				"APPLICATIONS",
 				2,
 				args,
 				STR_WINTITLE_APP);
		if	(!d_ica)
			goto fehler;
		}

	else	{
		is_multiwindow = TRUE;

 		d_ica = xy_wdlg_init(
 				hdl_ica,
 				adr_ica_dialog,
 				"APPLICATIONS",
 				0,
 				args,
 				STR_WINTITLE_APP);
		if	(!d_ica)
			goto fehler;

 		d_icp = xy_wdlg_init(
 				hdl_icp,
 				adr_icp_dialog,
 				"PATHS",
 				0,
 				args,
 				STR_WINTITLE_PTH);
		if	(!d_icp)
			goto fehler;

 		d_spc = xy_wdlg_init(
 				hdl_spc,
 				adr_spc_dialog,
 				"SPECIAL",
 				0,
 				args,
 				STR_WINTITLE_SPC);
		if	(!d_spc)
			goto fehler;
		}

	while(1)
		{
		w_ev.mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
					  2,			/* Doppelklicks erkennen 	*/
					  1,			/* nur linke Maustaste		*/
					  1,			/* linke Maustaste gedrÅckt	*/
					  0,NULL,		/* kein 1. Rechteck			*/
					  0,NULL,		/* kein 2. Rechteck			*/
					  w_ev.msg,
					  0L,	/* ms */
					  (EVNTDATA*) &(w_ev.mx),
					  &w_ev.key,
					  &w_ev.mclicks
					  );

		if	(w_ev.mwhich & MU_KEYBD)
			{
			int message[8];

			if	(w_ev.key == 0x1011)	/* Ctrl-Q */
				{
				break;		/* Beenden */
				}
			else
			if	(w_ev.key == 0x1615)	/* Ctrl-U */
				{
				/* unser oberstes Fenster <whdl> ermitteln */
				intin2 = ap_id;		/* Eingabewert! */
				wind_get(0, WF_BOTTOM, &intin2, &whdl,
						&dummy, &dummy);
				/* schicke mir selbst eine Nachricht */
				if	(whdl > 0)
					{
					message[0] = WM_CLOSED;
					message[1] = ap_id;
					message[2] = 0;
					message[3] = whdl;
					message[4] = message[5] =
					message[6] = message[7] = 0;
					appl_write(ap_id, 16, message);
					}
				goto key_done;
				}
			if	(w_ev.key == 0x1117)	/* Ctrl-W */
				{
				/* unser unterstes Fenster <whdl> ermitteln */
				intin2 = ap_id;		/* Eingabewert! */
				wind_get(-1, WF_BOTTOM, &intin2, &whdl,
						&dummy, &dummy);
				/* schicke mir selbst eine Nachricht */
				if	(whdl > 0)
					{
					message[0] = WM_TOPPED;
					message[1] = ap_id;
					message[2] = 0;
					message[3] = whdl;
					message[4] = message[5] =
					message[6] = message[7] = 0;
					appl_write(ap_id, 16, message);
					}
				goto key_done;
				}

			w = whdl2window(top_whdl());
			if	(w)
				{
				w->key(w, w_ev.kstate, w_ev.key);
			key_done:
				w_ev.mwhich &= ~MU_KEYBD;	/* bearbeitet */
				}
			}

		if	(w_ev.mwhich & MU_BUTTON)
			{
			w = whdl2window(wind_find(w_ev.mx, w_ev.my));
			if	(w)
				{
				w->button(w, w_ev.kstate, w_ev.mx, w_ev.my,
						w_ev.mbutton, w_ev.mclicks);
				w_ev.mwhich &= ~MU_BUTTON;	/* bearbeitet */
				}
			}

		if	(w_ev.mwhich & MU_MESAG)
			{
			if	(w_ev.msg[0] == AP_TERM)
				{
				close_work();
				return(0);
				}
/*
			if	(w_ev.msg[0] == AV_START)
				{
				}
*/

			if	(((w_ev.msg[0] >= 20) &&
					(w_ev.msg[0] < 40)) ||		/* WM_XX */
				 	(w_ev.msg[0] >= 1040))
				{
				w = whdl2window(w_ev.msg[3]);
				if	(w)
					{
					w->message(w, w_ev.kstate, w_ev.msg);
					w_ev.mwhich &= ~MU_MESAG;	/* bearbeitet */
					}
				}
			}


		if	(d_ica && !wdlg_evnt(d_ica, &w_ev))
			break;
		if	(d_icp && !wdlg_evnt(d_icp, &w_ev))
			break;
		if	(d_spc && !wdlg_evnt(d_spc, &w_ev))
			break;

		if	(d_typ && !wdlg_evnt(d_typ, &w_ev))
			{
			Mfree(wdlg_get_udata(d_typ));
			wdlg_close(d_typ, NULL, NULL);
			wdlg_delete(d_typ);
			d_typ = NULL;
			}
		if	(d_anw && !wdlg_evnt(d_anw, &w_ev))
			{
			Mfree(wdlg_get_udata(d_anw));
			wdlg_close(d_anw, NULL, NULL);
			wdlg_delete(d_anw);
			d_anw = NULL;
			}
		if	(d_pth && !wdlg_evnt(d_pth, &w_ev))
			{
			Mfree(wdlg_get_udata(d_pth));
			wdlg_close(d_pth, NULL, NULL);
			wdlg_delete(d_pth);
			d_pth = NULL;
			}

		} /* END FOREVER */

	fehler:
	close_work();
	return(0);
}


char *err_file;

long err_alert(long e)
{
	form_xerr(e, err_file);
	err_file = NULL;
	return(e);
}


/*************************************************************
*
* Fensterdialog îffnen.
*
*************************************************************/

DIALOG *xy_wdlg_init(
			HNDL_OBJ hndl_obj,
			OBJECT *tree,
			char *ident,
			int code,
			void *data,
			int title_code
			)
{
	int whdl;
	register WINDEFPOS *wd;
	int x,y;
	DIALOG *d;
	struct dialog_userdata *du;


	if	(NULL == (du = Malloc(sizeof(struct dialog_userdata))))
		return(NULL);
	if	((wd = def_wind_pos( ident )) != NULL)
		{
		x = wd->g.g_x;
		y = wd->g.g_y + gl_hhbox;
		}
	else	x = y = -1;
	du->ident = ident;
	du->mode = 0;
	d = wdlg_create(
			hndl_obj,
			tree,
			du,			/* user_data */
			code,
			data,
			0			/* flags */
			);

	if	(d)
		{
		whdl = wdlg_open(
			d,
			Rgetstring(title_code, NULL),
			NAME+CLOSER+MOVER,
			x,y,
			0,			/* code */
			NULL );		/* data */
		if	(whdl <= 0)
			{
			wdlg_delete(d);
			d = NULL;
			Rform_alert(1, ALRT_ERRWINDOPEN, NULL);
			}
		}

	if	(!d)
		Mfree(du);
	return(d);
}


/*************************************************************
*
* Fensterdialog soll geschlossen werden. Vorher Position
* sichern.
*
*************************************************************/

void save_dialog_xy( DIALOG *d )
{
	register WINDEFPOS *wd;
	OBJECT *tree;
	GRECT dummy;
	struct dialog_userdata *du;


	du = wdlg_get_udata(d);
	wdlg_get_tree(d, &tree, &dummy);
	wd = def_wind_pos( du->ident );
	if	((!wd) && (n_windefpos < MAXWINDEFPOS))
		{
		wd = windefpos+n_windefpos;	/* freien Eintrag suchen */
		strcpy(wd->name, du->ident);
		n_windefpos++;
		}
	if	(wd)
		{
		wd->g.g_x = tree->ob_x;
		wd->g.g_y = tree->ob_y - gl_hhbox;
		}
}


/****************************************************************
*
* Malt ein Unterobjekt eines Fensters
*
****************************************************************/

void subobj_wdraw(void *d, int obj, int startob, int depth)
{
	OBJECT *tree;
	GRECT g;


	wdlg_get_tree( d, &tree, &g );
	objc_grect(tree, obj, &g);
	wdlg_redraw( d, &g, startob, depth );
}


/****************************************************************
*
* close_work
*
****************************************************************/

void close_work(void)
{
	rsrc_free();
	v_clsvwk(vdi_handle);
	appl_exit();
	Pterm0();
}


/****************************************************************
*
* meine rsrc_gaddr
*
****************************************************************/

int rsrc_gtree(int index, OBJECT **tree )
{
	return(rsrc_gaddr(R_TREE, index, tree));
}


/****************************************************************
*
* Dateiname isolieren und öberlauf testen
*
* RÅckgabe:	-1	Name ungÅltig
*			1	Name ohne Pfad
*			0	Name mit Pfad
*
****************************************************************/

int extract_apname(char *path, char *name)
{
	char *nurname;
	char fname[MAX_NAMELEN+10];
	char *f;


	nurname = get_name(path);
	if	(strlen(nurname) > MAX_NAMELEN+9)
		{
		over:
		Rform_alert(1, ALRT_FNAME_2LONG, NULL);
		return(-1);
		}
	strcpy(fname, nurname);
	f = strchr(fname, '.');
	if	(f)
		*f = EOS;
	if	(!fname[0] || (strlen(fname) > MAX_NAMELEN-1))
		goto over;
	if	(strpbrk(fname, "[]:\\'"))
		{
		Rform_alert(1, ALRT_FNAME_INVAL, NULL);
		return(-1);
		}
	strcpy(name, fname);
	return(nurname == path);
}


/****************************************************************
*
* Default-Icon ermitteln
*
****************************************************************/

int get_deficonnr(long key)
{
	register int i;
	register struct spc_file *spc_file;

	for	(i = 0,spc_file = spcx; i < spcn; i++,spc_file++)
		if	(spc_file->key == key)
			return(spc_file->iconnr);
	return(0);
}
