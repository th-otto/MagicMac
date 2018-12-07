/*******************************************************************
*
*             MGCOPY.APP                             14.04.95
*             ==========
*                                 letzte énderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: MGCOPY.PRJ
*
* Modul zum Kopieren/Verschieben/Lîschen/Aliasen von Dateien
* Parameter:
*
* -W									- auf Nachricht warten
* -C src1 src2 src3 ... dest				- kopieren
* -M src1 src2 src3 ... dest				- verschieben
* -A src1 src2 src3 ... dest				- Aliase erstellen
* -D src1 src2 src3 ...					- lîschen
*
* scr<n> immer 2 Argumente, Pfad und LÑnge, dabei:
*		LÑnge -1:		Ordner
*		LÑnge -2:		Alias
*		LÑnge -3:		Device
*		LÑnge -4:		unbekanntes Objekt
*
* Schalter (hinter dem Kommando):
*	c		BestÑtigen (d.h. mit Dialogbox kopieren)
*	u		Update-Modus
*	o		Overwrite-Modus
*	f		freien Speicher abtesten
*	q		nach Aktion terminieren
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>
#include "mgcopy.h"
#include "gemut_mt.h"
#include "beg_dial.h"
#include "dat_dial.h"
#include "globals.h"
#include "toserror.h"

#define MAX_PENDING_TASKS	10
#define DEBUG 0


struct prefs prefs;
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int	scrx,scry,scrw,scrh;
int	is_3d;
void close_work     (void);

/* Dialoge */

void *d_beg = NULL;
void *d_working = NULL;
void *d_dat = NULL;
OBJECT *adr_beg;
OBJECT *adr_working;
OBJECT *adr_dat;


int copy_id = -1;			/* ap_id des threads */
						/* Wenn > 0, ist eine Aktion aktiv */
int run_status;			/* Kopieraktion aktiv */
int abbruch;				/* Button "Abbruch" betÑtigt */
static int quit = FALSE;		/* nicht resident */
int exit_immed = FALSE;


/* aktuell abgearbeitete Argumente */

int	nargs;
char **xargv;
static char *xargs;
int	action;
int	confirm,tst_free,copy_mode;
char *dst_path;

/* zwischendurch empfangene Nachrichten mit Argumenten */

int n_pending_tasks = 0;
char *pending_tasks[MAX_PENDING_TASKS];


/************************************************************
*
* Wird regelmÑûig aufgerufen.
*
* Röckgabe > 0:	Vorgang abbrechen.
*
************************************************************/

int callback_ever( void )
{
	EVNT w_ev;

	w_ev.mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG,
			  2,			/* Doppelklicks erkennen 	*/
			  1,			/* nur linke Maustaste		*/
			  1,			/* linke Maustaste gedrÅckt	*/
			  0,0,0,0,0,		/* kein 1. Rechteck			*/
			  0,0,0,0,0,		/* kein 2. Rechteck			*/
			  w_ev.msg,
			  0L,	/* ms */
			  &w_ev.mx,
			  &w_ev.my,
			  &w_ev.mbutton,
			  &w_ev.kstate,
			  &w_ev.key,
			  &w_ev.mclicks
			  );

	if	(w_ev.mwhich & MU_MESAG)
		{

		if	((w_ev.msg[0] == AP_TERM) ||
			(w_ev.msg[0] == PA_EXIT))
			exit_immed = TRUE;
		else	
		if	(w_ev.msg[0] == THR_EXIT)
			{
			run_status = DLG_FINISHED;
			copy_id = -1;
			}
		else

		/* Kommandozeile empfangen */
		/* ----------------------- */

		if	(w_ev.msg[0] == VA_START)
			{
			char *s;
			register int i;

			s = *((char **)(w_ev.msg+3));
			if	(!s)	/* erweitertes VA_START */
				{
				if	(w_ev.msg[5] == 'XA')
					s = *((char **)(w_ev.msg+6));
				}

			if	(s)
				{
				for	(i = 0; i < MAX_PENDING_TASKS; i++)
					{
					if	(!pending_tasks[i])
						{
						pending_tasks[i] = s;
						n_pending_tasks++;
						goto weiter;
						}
					}
				Mfree(s);		/* weg mit der Nachricht */
				Rform_alert(1, ALRT_TOOBUSY, NULL);
				}
			weiter:
			w_ev.mwhich &= ~MU_MESAG;
			}
		}

	if	(d_working && !wdlg_evnt(d_working, &w_ev))
		{
		terminate_dialog( &d_working, &prefs.progr_win );
		}

	if	(d_beg && !wdlg_evnt(d_beg, &w_ev))
		{
		terminate_dialog( &d_beg, &prefs.main_win );
		}

	if	(!d_beg)
		return(1);

	return(0);
}


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgrîûe <old> abgespeichert, jetzt ist die
* Bildschirmgrîûe <new>.
*
****************************************************************/

static void recalc(int *wert, int old, int new)
{
	unsigned long tmp;

	tmp    = (unsigned long) *wert;
	tmp   *= new;
	tmp   /= old;
	*wert  = (int) tmp;
}


/****************************************************************
*
* Lese INF-Datei
*
****************************************************************/

static char infpath[128];

void read_inf( char *fname )
{
	char buf[512];
	long len;
	int hdl;
	char *s,*t;
	int oldwh[2];


	/* Defaults setzen */
	/* --------------- */

	prefs.main_win.g_x = prefs.main_win.g_y =
	prefs.progr_win.g_x = prefs.progr_win.g_y = -1;
	prefs.work_expanded = TRUE;
	prefs.dirty = FALSE;

	/* Pfad ggf. aus dem HOME holen */
	/* ---------------------------- */

	s = getenv("HOME");
	if	(s)
		{
		strcpy(infpath, s);
		t = infpath+strlen(s);
		if	(t[-1] != '\\')
			*t++ = '\\';
		}
	else	t = infpath;
	strcpy(t, fname);


	/* Datei laden, falls vorhanden */
	/* ---------------------------- */

	if	((s) || (shel_find(infpath)))
		{
		hdl = (int) Fopen(infpath, O_RDONLY);
		if	(hdl < 0)
			return;
		len = Fread(hdl, 511L, buf);
		Fclose(hdl);
		if	(len < E_OK)
			return;
		buf[len] = EOS;

		/* erste Zeile Åberlesen */

		for	(s = buf; (*s) && (*s != '\n'); s++)
			;

		if	(*s == '\n')
			s++;

		/* andere Zeilen auswerten */

		while(*s)
			{
			if	(!strncmp(s, "SCREENSIZE ", 11))
				{
				s += 11;
				scan_values(&s, 2, oldwh);
				goto weiter;
				}

			if	(!strncmp(s, "WINDOW MAIN ", 12))
				{
				s += 12;
				scan_values(&s, 4, (int *) &prefs.main_win);
				}


			if	(!strncmp(s, "WINDOW PROGRESS ", 16))
				{
				s += 16;
				scan_values(&s, 4, (int *) &prefs.progr_win);
				}

			if	(!strncmp(s, "SHORT PROGRESS", 14))
				{
				prefs.work_expanded = FALSE;
				}

			weiter:

			while((*s) && (*s != '\n'))
				s++;

			if	(*s == '\n')
				s++;
			}


		if	(oldwh[0] != scrw)
			{
			recalc(&(prefs.main_win.g_x), oldwh[0], scrw);
			recalc(&(prefs.main_win.g_w), oldwh[0], scrw);
			recalc(&(prefs.progr_win.g_x), oldwh[0], scrw);
			recalc(&(prefs.progr_win.g_w), oldwh[0], scrw);
			}
		if	(oldwh[1] != scrh)
			{
			recalc(&(prefs.main_win.g_y), oldwh[1], scrh);
			recalc(&(prefs.main_win.g_h), oldwh[1], scrh);
			recalc(&(prefs.progr_win.g_y), oldwh[1], scrh);
			recalc(&(prefs.progr_win.g_h), oldwh[1], scrh);
			}
		prefs.main_win.g_x += scrx;
		prefs.main_win.g_y += scry;
		prefs.progr_win.g_x += scrx;
		prefs.progr_win.g_y += scry;
		}

	/* keine INF-Datei. Merke Pfad fÅr spÑteres Create */
	/* ----------------------------------------------- */

	else	{
		s = infpath;
		*s++ = Dgetdrv()+'A';
		*s++ = ':';
		Dgetpath(s, 0);
		s += strlen(s);
		if	(s[-1] != '\\')
			*s++ = '\\';
		strcpy(s, fname);
		}
}


/****************************************************************
*
* Schreibe Fensterposition auflîsungsunabhÑngig in
* Zeichenkette.
*
****************************************************************/

static void print_winpos(char *s, GRECT *g, int n)
{
	g->g_x -= scrx;
	g->g_y -= scry;
	print_values(s, n, (int *) g);
	g->g_x += scrx;
	g->g_y += scry;
}


/****************************************************************
*
* Schreibe INF-Datei
*
****************************************************************/

void write_inf( void  )
{
	int hdl;
	char buf[256];
	int scrwh[2];



	if	(!prefs.dirty)
		return;

	hdl = (int) Fcreate(infpath, 0);
	if	(hdl < 0)
		return;
	Fwrite(hdl, 32L,	"[MGCOPY Header V 1]\r\n"
					"SCREENSIZE ");
	scrwh[0] = scrw;
	scrwh[1] = scrh;
	print_values(buf, 2, scrwh);

	strcat(buf, "\r\nWINDOW MAIN ");
	print_winpos(buf + strlen(buf), &prefs.main_win, 4);

	strcat(buf, "\r\nWINDOW PROGRESS ");
	print_winpos(buf + strlen(buf), &prefs.progr_win, 4);

	if	(!prefs.work_expanded)
		{
		strcat(buf, "\r\nSHORT PROGRESS");
		}

	Fwrite(hdl, strlen(buf), buf);
	Fclose(hdl);
}


/****************************************************************
*
* gibt die abgearbeitete Argumentliste frei und wartet auf
* eine neue.
*
****************************************************************/

static void next_args( void )
{
	register int i;


	if	(xargs)
		{
		Mfree(xargs);
		xargs = NULL;
		}
	if	(exit_immed || (quit && !n_pending_tasks))
		return;
	while(!n_pending_tasks && !exit_immed)
		callback_ever();		/* warte auf Argument */
	if	(exit_immed)
		return;
	for	(i = 0; i < MAX_PENDING_TASKS; i++)
		{
		if	(pending_tasks[i])
			{
			xargs = pending_tasks[i];
			pending_tasks[i] = NULL;
			n_pending_tasks--;
			return;
			}
		}		
}


/****************************************************************
*
* Bearbeite eine Argumentliste
*
****************************************************************/

long do_args( void )
{
	char *s;
	char **t;
	char *args;


	args = xargs + strlen(xargs)+1;	/* "ARGV=" Åberspringen */
	for	(nargs = 0,s=args; *s; nargs++)
		{
		s += strlen(s) + 1;
		}

	xargv = Malloc(nargs * sizeof(char *));
	if	(!xargv)
		return((int) ENSMEM);

#if DEBUG
	Cconws("\x1b" "H");		/* Home */
#endif
	for	(s=args,t=xargv; *s;)
		{
#if DEBUG
		Cconws(s);
		Cconws("\r\n");
#endif
		*t++ = s;
		s += strlen(s) + 1;
		}
	return(E_OK);
}


/*************************************************/
/**************** HAUPTPROGRAMM ******************/
/*************************************************/

int main( int argc, char *argv[] )
{
/*	EVNT w_ev;	*/
	long err;
	int whdl;
	char *s;
	char *args;
	char argbuf[200];	/* falls kein ARGV da ist */
	int dummy;



	/* Kommandozeile auswerten */
	/* ----------------------- */

	if	(NULL == (args = getenv("ARGV")))
		{
		s = argbuf;
		strcpy(s, "ARGV=");
		s += 6;
		s[0] = s[1] = EOS;
		if	(!argv[0][0])
			argv[0] = "dummy.prg";
		while(argc)
			{
			memcpy(s, *argv, strlen(*argv) + 1);
			s += strlen(*argv) + 1;
			argv++;
			argc--;
			}
		*s = EOS;
		args = argbuf;
		}



	/* Initialisierung */
	/* --------------- */

	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	wind_get(SCREEN, WF_WORKXYWH, &scrx, &scry, &scrw, &scrh);
	vdi_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);
	objc_sysvar(0, MX_ENABLE3D, 0, 0, &is_3d, &dummy);

	rsrc_load("mgcopy.rsc");
	read_inf("MGCOPY.INF");

	dat_dial_init_rsc();
	beg_dial_init_rsc();

	xargs = args;

	for	(; !exit_immed && (!quit || xargs); next_args())
		{
		run_status = DLG_WAITING;	/* warte auf DrÅcken von OK */
		abbruch = FALSE;

		if	(!xargs)
			continue;

		err = do_args();
		if	(err)
			return((int) err);
		if	(nargs == 1)
			continue;		/* nix Åbergeben */
		if	(nargs < 3)
			{
			par_err:
			Rform_alert(1, ALRT_ERRARG, NULL);
			continue;
			}
		s = xargv[1];	/* Schalter */
		if	(*s++ != '-')
			goto par_err;
		action = *s++;
		if	((action != 'W') &&
			 (action != 'D') &&
			 (action != 'C') &&
			 (action != 'A') &&
			 (action != 'M'))
			goto par_err;

		quit = (strchr(s, 'q') != NULL);
		confirm = (strchr(s, 'c') != NULL);
		tst_free = (strchr(s, 'f') != NULL);
		if	(strchr(s, 'u'))
			copy_mode = BACKUP;		/* update */
		else
		if	(strchr(s, 'o'))
			copy_mode = OVERWRITE;		/* overwrite */
		else	copy_mode = CONFIRM;		/* normal */

		if	(action != 'D')	/* es gibt einen Zielpfad */
			{
			if	(nargs < 4)	/* cmd -a src dst */
				goto par_err;
			dst_path = xargv[nargs - 1];	/* Zielpfad */
			nargs--;
			}
		else	dst_path = NULL;	/* Lîschen: Kein Zielpfad */


		/* alles ausrechnen	*/
		/* ---------------- */

		err = beg_dial_prepare(nargs-2, xargv+2, dst_path);
		if	(err)
			continue;

		/* in jedem Fall den Dialog îffnen	*/
		/* -------------------------------	*/

		set_dialog_title( action );
		if	(confirm)
			{
			d_beg = wdlg_create(hdl_beg,
				adr_beg,
				NULL,
				action,
				NULL,
				0);

			if	(!d_beg)
				goto errw;

			whdl = wdlg_open( d_beg,
						Rgetstring(STR_MAINTITLE, NULL),
						NAME+CLOSER+MOVER+SMALLER,
						prefs.main_win.g_x,prefs.main_win.g_y,
						0,
						NULL );
			if	(whdl <= 0)
				{
				wdlg_delete(d_beg);
				d_beg = NULL;
				errw:
				Rform_alert(1, ALRT_ERROPENWIND, NULL);
				continue;
				}
			}

		/* Wenn nicht BestÑtigen: Taste [Return] schicken.	*/
		/* ---------------------------------------------------	*/

		else	{
			beg_dial_action(nargs-2, xargv+2, dst_path, copy_mode);
			}
/*
		if	(!confirm)
			{
			w_ev.mwhich = MU_KEYBD;
			w_ev.key = 0x1c0d;
			wdlg_evnt(d_beg, &w_ev);
			}
*/

		/* Jetzt warten wir auf das DrÅcken von "OK"  */
		/* ------------------------------------------ */

		while(!exit_immed && (run_status == DLG_WAITING))
			callback_ever();

		while(!exit_immed && (run_status == DLG_RUNNING))
			callback_ever();

		close_beg_dialog();
		}


	if	(prefs.work_expanded != working_is_expanded)
		{
		prefs.work_expanded = working_is_expanded;
		prefs.dirty = TRUE;
		}
	write_inf();

	close_work();
	return(0);
}


/****************************************************************
*
* Schlieût ein Dialogfenster
*
****************************************************************/

void terminate_dialog( void **dialog, GRECT *pref_g )
{
	GRECT g;
	OBJECT *tree;
	int whandle;
	int iconified,dummy;


	wdlg_get_tree( *dialog, &tree, &g);
	whandle = wdlg_get_handle(*dialog);
	if	(whandle > 0)
		wind_get(whandle, WF_ICONIFY, &iconified,
				&dummy, &dummy, &dummy);
	else	iconified = TRUE;
	wdlg_close( *dialog, &dummy, &dummy );
	wdlg_delete( *dialog );
	*dialog = NULL;
	/* Fensterposition merken */
	if	(!iconified)
		{
		if	( pref_g->g_x != tree->ob_x )
			{
			pref_g->g_x = tree->ob_x;
			prefs.dirty = TRUE;
			}
		if	( pref_g->g_y != tree->ob_y )
			{
			pref_g->g_y = tree->ob_y;
			prefs.dirty = TRUE;
			}
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
	appl_exit();
	Pterm0();
}
