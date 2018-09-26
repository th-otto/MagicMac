/****************************************************************
*
*             MGEDIT.APP                             03.11.97
*             ==========
*                                 letzte énderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: MGEDIT.PRJ
*
* Einfacher Editor, basierend auf "EDITOBJC.SLB".
*
****************************************************************/

#define DEBUG 0

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "globals.h"
#include <wdlgfslx.h>
#include "mgedit.h"
#include "gemut_mt.h"
#include "toserror.h"
#if DEBUG
#include <stdio.h>
#endif

int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int	ncolours;
GRECT scrg;
int aes_handle;		/* Screen-Workstation des AES */
int terminate = FALSE;

/* fÅr die SharedLib */
SLB_EXEC	slbexec;
SHARED_LIB  slb;

/* globale Einstellungen */

struct prefs prefs;

/* Dialoge */

OBJECT *adr_menu;
OBJECT *adr_about;
OBJECT *adr_options;
OBJECT *adr_colour;
void *d_options = NULL;

/* Dateiauswahl-Dialog */

typedef enum { fxopen, fxsaveas } fslx_modet;
static fslx_modet fslx_mode;
static XFSL_DIALOG *fslx_dialog;
static WORD fslx_whdl;
static char fslx_path[258];
static char fslx_fname[66];
static WORD fslx_button,fslx_nfiles;	/* Ergebnis */
static WINDOW *fslx_saveas_w;			/* zu speicherndes Fenster */
static char *fslx_bsel,*fslx_esel;		/* zu speichernder Bereich */

/* Fenster */
WINDOW *windows[NWINDOWS];


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgrîûe <old> abgespeichert, jetzt ist die
* Bildschirmgrîûe <new>.
*
* Liegt das Fenster links aus dem Bildschirm heraus, wird
* nichts umgerechnet. Hier sollte aber sichergestellt werden,
* daû man an das Fenster noch herankommt, d.h.:
*	x+w > k > 0.
*
****************************************************************/

static void recalc(int *wert, int old, int new)
{
	unsigned long tmp;

	if	(*wert > 0)
		{
		tmp    = (unsigned long) *wert;
		tmp   *= new;
		tmp   /= old;
		*wert  = (int) tmp;
		}
}


/****************************************************************
*
* Lese INF-Datei
*
****************************************************************/

static char infpath[128];

void read_inf( void )
{
	char buf[512];
	long len;
	int hdl;
	char *s,*t;
	int oldwh[2];
	int font[3];


	prefs.fontID = 1;
	prefs.fontH = 10;
	prefs.fontprop = FALSE;
	strcpy(prefs.fontname, "System Font");
	prefs.tcolour = 1;
	prefs.bcolour = 0;
	prefs.tabwidth = 64;
	prefs.bufsize = 65536L;		/* freier Platz in Puffer */
	prefs.prefs_win.g_x = prefs.prefs_win.g_y = -1;

	s = getenv("HOME");
	if	(s)
		{
		strcpy(infpath, s);
		t = infpath+strlen(s);
		if	(t[-1] != '\\')
			*t++ = '\\';
		}
	else	t = infpath;
	strcpy(t, "MGEDIT.INF");

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

			if	(!strncmp(s, "WINDOW PREFS ", 12))
				{
				s += 13;
				scan_values(&s, 4, (int *) &prefs.prefs_win);
				}

			if	(!strncmp(s, "FONT ", 5))
				{
				s += 5;
				scan_values(&s, 3, font);
				prefs.fontID = font[0];
				prefs.fontprop = font[1];
				prefs.fontH = font[2];
				}

			if	(!strncmp(s, "FONTNAME ", 9))
				{
				s += 9;
				t = prefs.fontname;
				while((*s) && (*s != '\r'))
					*t++ = *s++;
				*t = EOS;
				}

			if	(!strncmp(s, "TCOLOUR ", 8))
				{
				s += 7;
				scan_values(&s, 1, &prefs.tcolour);
				}

			if	(!strncmp(s, "BCOLOUR ", 8))
				{
				s += 7;
				scan_values(&s, 1, &prefs.bcolour);
				}

			if	(!strncmp(s, "TABWIDTH ", 9))
				{
				s += 8;
				scan_values(&s, 1, &prefs.tabwidth);
				}

			weiter:

			while((*s) && (*s != '\n'))
				s++;

			if	(*s == '\n')
				s++;
			}


		if	(oldwh[0] != scrg.g_w)
			{
			recalc(&(prefs.prefs_win.g_x), oldwh[0], scrg.g_w);
			recalc(&(prefs.prefs_win.g_w), oldwh[0], scrg.g_w);
			}
		if	(oldwh[1] != scrg.g_h)
			{
			recalc(&(prefs.prefs_win.g_y), oldwh[1], scrg.g_h);
			recalc(&(prefs.prefs_win.g_h), oldwh[1], scrg.g_h);
			}
		prefs.prefs_win.g_x += scrg.g_x;
		prefs.prefs_win.g_y += scrg.g_y;

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
	g->g_x -= scrg.g_x;
	g->g_y -= scrg.g_y;
	print_values(s, n, (int *) g);
	g->g_x += scrg.g_x;
	g->g_y += scrg.g_y;
}


/****************************************************************
*
* Schreibe INF-Datei
*
****************************************************************/

void save_options( void )
{
	int hdl;
	char buf[512];
	int scrwh[2];
	int font[3];



	if	(d_options)
		{
		prefs.prefs_win.g_x = adr_options->ob_x;
		prefs.prefs_win.g_y = adr_options->ob_y;
		}

	hdl = (int) Fcreate(infpath, 0);
	if	(hdl < 0)
		return;
	strcpy(buf, "[MGEDIT Header V 1.0]\r\n"
					"SCREENSIZE ");
	scrwh[0] = scrg.g_w;
	scrwh[1] = scrg.g_h;
	print_values(buf+strlen(buf), 2, scrwh);

	strcat(buf, "\r\nWINDOW PREFS ");
	print_winpos(buf + strlen(buf), &prefs.prefs_win, 4);

	strcat(buf, "\r\nFONT ");
	font[0] = prefs.fontID;
	font[1] = prefs.fontprop;
	font[2] = prefs.fontH;
	print_values(buf + strlen(buf), 3, font);

	strcat(buf, "\r\nFONTNAME ");
	strcat(buf, prefs.fontname);

	strcat(buf, "\r\nTCOLOUR ");
	print_values(buf + strlen(buf), 1, &(prefs.tcolour));

	strcat(buf, "\r\nBCOLOUR ");
	print_values(buf + strlen(buf), 1, &(prefs.bcolour));

	strcat(buf, "\r\nTABWIDTH ");
	print_values(buf + strlen(buf), 1, &(prefs.tabwidth));

	Fwrite(hdl, strlen(buf), buf);
	Fclose(hdl);
}


/****************************************************************
*
* WÑhlt einen Zeichensatz aus.
*
****************************************************************/

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )
#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE )

int dial_font( long *id, long *pt, int *mono, char *name )
{
	int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
	int	handle;
	register int i;
	FNT_DIALOG *fnt_dialog;
	int button,check_boxes;
	long ratio;
	int dummy;


	for( i = 1; i < 10 ; i++ )											/* work_in initialisieren */
		work_in[i] = 1;
	work_in[10] = 2;		/* Rasterkoordinaten benutzen */
	handle = aes_handle;
	v_opnvwk( work_in, &handle, work_out );

	ratio = (1L<<16L);
	fnt_dialog = fnts_create( handle, 0, FONT_FLAGS, FNTS_3D,
				  "Was Shumway Your favourite Gordon?", 0L );
	if	(!fnt_dialog )
		return(0);
	button = fnts_do( fnt_dialog, BUTTON_FLAGS, *id, *pt, ratio,
			&check_boxes, id, pt, &ratio );
	if	(button == FNTS_OK)
		{
/*
		char s[100];
		Cconws("\x1b" "Hid=");
		ltoa(id, s, 16);
		Cconws(s);
		Cconws("        pt=");
		ltoa(pt, s, 16);
		Cconws(s);
		Cconws("        ratio=");
		ltoa(ratio, s, 16);
		Cconws(s);
		Cconws("        ");
		Cnecin();
*/
		if	(!fnts_get_info(fnt_dialog, *id, mono, &dummy ))
			*mono = FALSE;
		if	(name)
			{
			fnts_get_name(fnt_dialog, *id, name, NULL, NULL);
			}
		}
	fnts_delete( fnt_dialog, handle );
	v_clsvwk(handle);
	return(button == FNTS_OK);
}


/****************************************************************
*
* Das Dateiauswahl-Fenster wurde mit OK verlassen.
* LÑdt eine Datei per Dateiauswahl in ein neues Fenster
*
****************************************************************/

void open_file_close( void )
{
	if	(fslx_button)
		{
		strcat(fslx_path, fslx_fname);
		open_new_window( fslx_path );
		}
}


/****************************************************************
*
* Speichert ein Fenster
*
****************************************************************/

int save_window( WINDOW *w, char *path,
				char *bsel, char *esel )
{
	char *buf;
	LONG buflen,actsize;
	long ret;
	int ret2,file;


	ret = Fcreate(path, 0);
	if	(ret < 0)
		{
		form_xerr(ret, path);
		return(0);
		}

	file = (int) ret;
	if	(bsel)
		{
		buf = bsel;
		actsize = esel-bsel;
		}
	else	edit_get_buf(&w->tree, EDITFELD, &buf, &buflen, &actsize);

	ret = Fwrite(file, actsize, buf);
	Fclose(file);
	if	((ret >= 0) && (ret != actsize))
		ret = ERROR;
	if	(ret < 0)
		{
		form_xerr(ret, path);
		return(0);
		}

	if	(!bsel)
		{
		ret2 = strcmp(w->path, path);

		if	(w->dirty)
			{
			edit_set_dirty( &w->tree, EDITFELD, FALSE );
			w->dirty = FALSE;
			ret2 = TRUE;
			}

		if	(ret2)
			{
			strcpy(w->path, path);
			strcpy(w->title, path);
			wind_set_str(w->handle, WF_NAME, w->title);
			}
		}

	return(1);
}


/****************************************************************
*
* ôffnet den Fensterdialog "Datei speichern als..."
*
****************************************************************/

void saveas_file_open( WINDOW *w )
{
	char *s;



	edit_get_sel(&w->tree, EDITFELD, &fslx_bsel, &fslx_esel);
	strcpy(fslx_path, w->path);

	s = get_name(fslx_path);
	if	(fslx_bsel)
		fslx_fname[0] = '\0';
	else	strcpy(fslx_fname, s);
	*s = EOS;

	fslx_mode = fxsaveas;
	fslx_dialog = fslx_open(
				Rgetstring((fslx_bsel) ? STR_SAVEBLOCK : STR_SAVEFILE,
					NULL),
				-1,-1,
				&fslx_whdl,
				fslx_path, 256,
				fslx_fname, 64,
				NULL,
				0L,
				NULL,
				SORTDEFAULT,
				0);
	fslx_saveas_w = w;
	w->save_active = TRUE;
}


/****************************************************************
*
* Das Dateiauswahl-Fenster wurde mit OK verlassen.
* Speichert ein Fenster per Dateiauswahl in eine Datei
*
****************************************************************/

void saveas_file_close( void )
{
	if	(fslx_button)
		{
		strcat(fslx_path, fslx_fname);
		save_window( fslx_saveas_w, fslx_path,
				fslx_bsel, fslx_esel );
		}
	if	(fslx_saveas_w)
		{
		fslx_saveas_w->save_active = FALSE;
		fslx_saveas_w = NULL;
		}
}


/****************************************************************
*
* Schlieût eine Datei.
* RÅckgabe 0: geschlossen 1: noch nicht geschlossen.
*
****************************************************************/

int close_file( WINDOW *w )
{
	int ret;
	char *fname;


	if	(!w->dirty)
		goto erledigt;
		
	fname = get_name(w->path);
	if	(!(*fname))
		{
		fname = w->title;
		if	(*fname == '*')
			fname++;
		}
	ret = Rxform_alert(1, ALRT_SAVEFILE, 0, fname, NULL );
	if	(ret == 3)
		{
		if	(terminate)
			{
			menu_ienable( adr_menu, MT_DESK, TRUE );
			menu_ienable( adr_menu, MT_FILE, TRUE );
			menu_ienable( adr_menu, MT_OPTIONS, TRUE );
			menu_bar(adr_menu, TRUE);
			terminate = FALSE;
			}
		return(1);	/* Abbruch, nicht erledigt */
		}
	if	(ret == 1)
		{
		if	(w->path[0])
			{
			if	(!save_window(w, w->path, NULL, NULL))
				return(1);	/* Abbruch == Fehler */
			}
		else	{
			saveas_file_open(w);
			return(1);
			}
		}

erledigt:
	close_window(w);
	return(0);
}


/****************************************************************
*
* Schlieût alle Dateien, allerdings nacheinander.
* Die Routine muû solange aufgerufen werden, bis alle
* Dateien geschlossen sind.
*
****************************************************************/

void close_all_files( void )
{
	register int i;
	register WINDOW **pw;


	for	(i = 0,pw = windows; i < NWINDOWS; i++,pw++)
		{
		if	(*pw)
			{
			if	(close_file(*pw))	/* noch nicht geschlossen */
				break;
			}
		}
}


/****************************************************************
*
* éndert alle Fenster
*
****************************************************************/

void prefs_were_changed( void )
{
	register int i;
	register WINDOW *w,**pw;

	for	(i = 0,pw = windows; i < NWINDOWS; i++,pw++)
		{
		w = *pw;
		if	(w)
			{
			wind_update(BEG_UPDATE);
			if	((prefs.fontID != w->fontID) ||
				 (prefs.fontH != w->fontH))
				{
				w->fontID = prefs.fontID;
				w->fontH = prefs.fontH;
				w->fontprop = prefs.fontprop;
				edit_set_font( &w->tree, EDITFELD,
					w->fontID, w->fontH, FALSE, !w->fontprop);
				}

			if	((prefs.tcolour != w->tcolour) ||
				 (prefs.bcolour != w->bcolour))
				{
				w->tcolour = prefs.tcolour;
				w->bcolour = prefs.bcolour;
				edit_set_color( &w->tree, EDITFELD,
					w->tcolour, w->bcolour);
				}

			if	(prefs.tabwidth != w->tabwidth)
				{
				w->tabwidth = prefs.tabwidth;
				w->bcolour = prefs.bcolour;
				edit_set_format( &w->tree, EDITFELD,
					w->tabwidth, FALSE);
				}
			update_window(w, NULL);
			wind_update(END_UPDATE);
			}
		}
}


/****************************************************************
*
* ôffnet den "Voreinstllungen" Dialog
*
****************************************************************/

void open_options( void )
{
	int whdl;


	if	(d_options)	/* ist schon geîffnet */
		{
		}
	else	{
		d_options = wdlg_create(
			hdl_options,
			adr_options,
			NULL,
			0,
			NULL,
			0);
		if	(d_options)
			{
			whdl =
				wdlg_open(
					d_options,
					Rgetstring(
						STR_OPTIONTITLE,
						NULL),
					NAME+
					CLOSER+
					MOVER/*+
					SMALLER*/,
					prefs.prefs_win.g_x,
					prefs.prefs_win.g_y,
					0,
					NULL );
			if	(whdl <= 0)
				{
				wdlg_delete(d_options);
				d_options = NULL;
				Rform_alert(1,
						ALRT_ERROPENWIND,
						NULL);
				}
			}
		}
}


/****************************************************************
*
* Bearbeitet die MenÅbefehle
*
****************************************************************/

static int do_menu( int title, int entry, WINDOW *w)
{
	int state;
	int ret = 0;


	/* Sonderfall fÅr Tastaturbedienung: */
	/* --------------------------------- */

	state = adr_menu[title].ob_state;
	if	(state & DISABLED)
		return(0);	/* Eintrag ungÅltig */
	if	(!(state & SELECTED))
		menu_tnormal(adr_menu, title, 0);

	switch( entry )
		{
		/* -- Datei -- */
		case MEN_ABOUT:
			do_dialog(adr_about);
			break;
		case MEN_NEW:
			open_new_window( NULL );
			break;
		case MEN_OPEN:
			if	(fslx_dialog && (fslx_mode != fxopen))
				break;
			if	(fslx_dialog)
				{
				wind_set(fslx_whdl,
						WF_TOP, 0, 0, 0, 0);
				}
			else	{
				fslx_mode = fxopen;
				fslx_path[0] = fslx_fname[0] = EOS;
				fslx_dialog = fslx_open(
							Rgetstring(STR_LOADFILE,NULL),
							-1,-1,
							&fslx_whdl,
							fslx_path, 256,
							fslx_fname, 64,
							NULL,
							0L,
							NULL,
							SORTDEFAULT,
							0);
				}
			break;
		case MEN_CLOSE:
			if	(w)
				if	(w->save_active)
					Bconout(2,7);
				else close_file(w);
			break;
		case MEN_SAVE:
			if	(w)
				{
				if	(w->save_active)
					{
					Bconout(2,7);
					break;
					}
				if	(w->path[0])
					{
					save_window(w, w->path, NULL, NULL);
					break;
					}
				/* fall through */
				}
		case MEN_SAVEAS:
			if	((!w) || fslx_dialog)
				break;
			saveas_file_open(w);
			break;
		case MEN_QUIT:
			ret = 1;
			break;
		/* -- Optionen -- */
		case MEN_PREFS:
			open_options();
			break;
		}
     menu_tnormal(adr_menu, title, 1);
	return(ret);
}


/****************************************************************
*
* Bearbeitet die Tastatur-Kommandos
*
****************************************************************/

static int do_key( EVNT *w_ev, WINDOW *w )

{
	int i,wnr;


	switch(w_ev->key)
		{
		case 0x310e:	/* ^N */
			do_menu(MT_FILE, MEN_NEW, w);
			break;

		case 0x180f:	/* ^O */
			do_menu(MT_FILE, MEN_OPEN, w);
			break;

		case 0x1615:	/* ^U */
			do_menu(MT_FILE, MEN_CLOSE, w);
			break;

		case 0x1f13:	/* ^S */
			do_menu(MT_FILE, MEN_SAVE, w);
			break;

		case 0x320d:	/* ^M */
			do_menu(MT_FILE, MEN_SAVEAS, w);
			break;

		case 0x1011:	/* ^Q */
			w_ev->mwhich &= ~MU_KEYBD;	/* bearbeitet */
			return(1);	/* Ende */

		case	0x1200:	/* Alt-E */
			do_menu(MT_OPTIONS, MEN_PREFS, w);
			break;

		case	0x1117:	/* ^W */
			if	(!w)
				break;

			wnr = (int) (find_slot_window(w) - windows);
			i = wnr;
			do	{
				i++;
				if	(i >= NWINDOWS)
					i = 0;
				if	(windows[i])
					{
					wind_set(windows[i]->handle,
							WF_TOP, 0, 0, 0, 0);
					break;
					}
				}
			while(i != wnr);
			break;
		default:
			return(0);
		}
	w_ev->mwhich &= ~MU_KEYBD;	/* bearbeitet */
	return(0);
}


/*************************************************/
/**************** HAUPTPROGRAMM ******************/
/*************************************************/

int main( int argc, char *argv[] )
{
	WINDOW *w;
	EVNT w_ev;
	int i;
	LONG err;
	int update = FALSE;



	/* SharedLib laden */
	/* --------------- */

	Pdomain(1);
	err = Slbopen("editobjc.slb", NULL, 6L, &slb, &slbexec);
	if	(err < 0)
		Pterm((WORD) err);

	/* Initialisierung */
	/* --------------- */

	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	i = _GemParBlk.global[10];
	ncolours = (i > 8) ? 32767 : (1 << i);
	wind_get_grect(SCREEN, WF_WORKXYWH, &scrg);

	if	(!rsrc_load("mgedit.rsc"))
		{
		form_xerr(EFILNF, "mgedit.rsc");
		appl_exit();
		Pterm((int) EFILNF);
		}

	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);
	rsrc_gaddr(0, T_MENU, &adr_menu);
	rsrc_gaddr(0, T_ABOUT, &adr_about);
	rsrc_gaddr(0, T_OPTIONS, &adr_options);
	rsrc_gaddr(0, T_COLOUR, &adr_colour);

	/* Voreinstellungen */
	/* ---------------- */

	read_inf();

	options_dial_init_rsc();

	menu_bar(adr_menu, TRUE);

	/* Alle Åbergebenen Dateien îffnen */
	/* ------------------------------- */

	for	(argc--,argv++; argc; argc--,argv++)
		{
		open_new_window(*argv);
		}

	while((!terminate) || (fslx_dialog))
		{
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

		wind_update(BEG_UPDATE);
		update = TRUE;

		/* Fensterdialoge */
		/* -------------- */

		if	(d_options && !wdlg_evnt(d_options, &w_ev))
			{
			wdlg_close(d_options, NULL, NULL);
			wdlg_delete(d_options);
			d_options = NULL;
			/* Fensterposition merken */
			prefs.prefs_win.g_x = adr_options->ob_x;
			prefs.prefs_win.g_y = adr_options->ob_y;
			}

		if	(fslx_dialog && !fslx_evnt(
								fslx_dialog,
								&w_ev,
								fslx_path,
								fslx_fname,
								&fslx_button,
								&fslx_nfiles,
								NULL,
								NULL))
			{
			switch(fslx_mode)
				{
				case fxopen:
					open_file_close();
					break;
				case fxsaveas:
					saveas_file_close();
					break;
				}
			fslx_close(fslx_dialog);
			fslx_dialog = NULL;
			}

		/* Tastatur */
		/* -------- */

		w = whdl2window(top_whdl());
		if	((w_ev.mwhich & MU_KEYBD) &&
			 (w_ev.kstate & (K_CTRL+K_ALT))
			)
			if	(do_key(&w_ev, w))
				goto ende;

		/* Editorfenster */
		/* ------------- */

		if	((w) && (terminate || w->save_active))
			{
			if	(w_ev.mwhich & MU_KEYBD)
				{
				Bconout(2,7);
				w_ev.mwhich &= ~MU_KEYBD;
				}
			}

		if	(w && !(w->flags & WFLAG_SHADED))
			{
			edit_evnt( &w->tree, EDITFELD, w->handle, &w_ev, &err );
			if	(!w->dirty)
				{
				w->dirty = edit_get_dirty( &w->tree, EDITFELD );
				if	(w->dirty)
					{
					memcpy(w->title+1, w->title,
							strlen(w->title)+1);
					w->title[0] = '*';
					wind_set_str(w->handle, WF_NAME, w->title);
					}
				}
			window_set_slider(w);
			}


		/* Nachricht */
		/* --------- */

		if	(w_ev.mwhich & MU_MESAG)
			{
			if	((w_ev.msg[0] == MN_SELECTED) && (!terminate))
				{
				if	(do_menu(w_ev.msg[3], w_ev.msg[4], w))
					goto ende;
				}
				
			else
			if	(w_ev.msg[0] == AP_TERM)
				{
				ende:
				if	(!terminate)
					{
					menu_ienable( adr_menu, MT_DESK, FALSE );
					menu_ienable( adr_menu, MT_FILE, FALSE );
					menu_ienable( adr_menu, MT_OPTIONS, FALSE );
					menu_bar(adr_menu, TRUE);
					if	(fslx_dialog && (fslx_mode == fxopen))
						{
						fslx_close(fslx_dialog);
						fslx_dialog = NULL;
						}
					terminate = TRUE;
					}
				}

			else
			if	(w_ev.msg[0] == VA_START)
				{
				register char *s;
				register char *p,*p2;
				char path[256];

				s = *((char **)(w_ev.msg+3));
				while((s) && (*s))
					{
					p = path;
					p2 = p+255;
					while(*s == ' ')
						s++;		/* leading blanks */
					if	(*s == '\'')
						{
						s++;
						while((*s) && (p < p2))
							{
							if	(*s == '\'')
								{
								if	(s[1] != '\'')
									break;
								s++;		/* Doppelte ' entfernen */
								}
							*p++ = *s++;
							}
						if	(*s)
							s++;
						}
					else	{
						while(*s && (*s != ' ') && (p < p2))
							*p++ = *s++;
						}
					*p = '\0';
					if	(*s)
						s++;
					if	(path[0])
						open_new_window(path);
					}

				i = w_ev.msg[1];		/* Absender */

				w_ev.msg[0] = AV_STARTED;
				w_ev.msg[1] = ap_id;
				w_ev.msg[2] = 0;		/* keine öberlÑnge */
				/* Wort 3 und 4 unverÑndert */
				w_ev.msg[5] =
				w_ev.msg[6] =
				w_ev.msg[7] = 0;

				appl_write(i, 16, w_ev.msg);
				}
			else

			/* Fenster-Nachricht empfangen */
			/* --------------------------- */
	
			if	(((w_ev.msg[0] >= 20) &&
						(w_ev.msg[0] < 40)) ||		/* WM_XX */
				 		(w_ev.msg[0] >= 1040))
				{
				w = whdl2window(w_ev.msg[3]);
				if	(w)
					{
					window_message(w, w_ev.kstate, w_ev.msg);
					w_ev.mwhich &= ~MU_MESAG;	/* bearbeitet */
					}
				}
			}
		wind_update(END_UPDATE);
		if	((terminate) && (!fslx_dialog))
			close_all_files();
		}

	rsrc_free();
	if	(slb)
		Slbclose( slb );
	if	(update)
		wind_update(END_UPDATE);
	appl_exit();
	return(0);
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
