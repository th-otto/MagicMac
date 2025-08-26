/****************************************************************
*
*             MGEDIT.APP                             03.11.97
*             ==========
*                                 letzte �nderung:
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
#include "mm7.h"
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

/* f�r die SharedLib */
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
* Bildschirmgr��e <old> abgespeichert, jetzt ist die
* Bildschirmgr��e <new>.
*
* Liegt das Fenster links aus dem Bildschirm heraus, wird
* nichts umgerechnet. Hier sollte aber sichergestellt werden,
* da� man an das Fenster noch herankommt, d.h.:
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

		/* erste Zeile �berlesen */

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
* Schreibe Fensterposition aufl�sungsunabh�ngig in
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
* W�hlt einen Zeichensatz aus.
*
****************************************************************/

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )
#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE )

int dial_font( long *id, long *pt, int *mono, char *name )
{
	int work_out[57],work_in [12];	 /* VDI- Felder f�r v_opnvwk() */
	int	handle;
	register int i;
	FNT_DIALOG *fnt_dialog;
	int button,check_boxes;
	long ratio;
	int dummy;


	for( i = 0; i < 10 ; i++ )											/* work_in initialisieren */
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
* L�dt eine Datei per Dateiauswahl in ein neues Fenster
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
* �ffnet den Fensterdialog "Datei speichern als..."
*
****************************************************************/

static void saveas_file_open( WINDOW *w )
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
#ifdef MM7
	{
	char *dp;
	LONG ret;
	char macpath[256];

	strcpy(macpath, fslx_path+3);
	strcat(macpath, fslx_fname);
	while((dp = strchr(macpath, '\\')) != NULL)
		*dp = ':';
	ret = MgMc7NavPutFile(macpath, 255);
	if	(!ret)	/* OK */
		{
		fslx_path[0] = 'M';
		fslx_path[1] = ':';
		fslx_path[2] = '\\';
		strcpy(fslx_path+3, macpath);
		while((dp = strchr(fslx_path, ':')) != NULL)
			*dp = '\\';
		dp = get_name(fslx_path);
		strcpy(fslx_fname, dp);
		*dp = '\0';
		fslx_button = 1;	/* OK */
		}
	else	fslx_button = 0;	/* Abbruch */
	}
#else
	fslx_dialog = fslx_open(
				Rgetstring((fslx_bsel) ? STR_SAVEBLOCK : STR_SAVEFILE,
					NULL),
				-1,-1,
				&fslx_whdl,
				fslx_path, (int)sizeof(fslx_path),
				fslx_fname, (int)sizeof(fslx_fname) - 2,
				NULL,
				0L,
				NULL,
				SORTDEFAULT,
				0);
#endif
	fslx_saveas_w = w;
	w->save_active = TRUE;
#ifdef MM7
	saveas_file_close();
#endif
}


/****************************************************************
*
* Schlie�t eine Datei.
* R�ckgabe 0: geschlossen 1: noch nicht geschlossen.
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
#ifdef MM7
			MgMc7EnableItem(1,0);
			MgMc7EnableItem(2,0);
			MgMc7EnableItem(3,0);
			MgMc7DrawMenuBar();
#else
			menu_ienable( adr_menu, MT_DESK, TRUE );
			menu_ienable( adr_menu, MT_FILE, TRUE );
			menu_ienable( adr_menu, MT_OPTIONS, TRUE );
			menu_bar(adr_menu, TRUE);
#endif

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
* Schlie�t alle Dateien, allerdings nacheinander.
* Die Routine mu� solange aufgerufen werden, bis alle
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
* �ndert alle Fenster
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
* �ffnet den "Voreinstellungen" Dialog
*
****************************************************************/

void open_options( void )
{
	int whdl;


	if	(d_options)	/* ist schon ge�ffnet */
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
* Bearbeitet die Men�befehle
*
****************************************************************/

static int do_menu( int title, int entry, WINDOW *w)
{
	int state;
	int ret = 0;


	/* Sonderfall f�r Tastaturbedienung: */
	/* --------------------------------- */

	state = adr_menu[title].ob_state;
	if	(state & DISABLED)
		return(0);	/* Eintrag ung�ltig */
	if	(!(state & SELECTED))
	{
#ifdef MM7
		switch(title)
			{
			case MT_DESK: MgMc7MenuHilite(1);break;
			case MT_FILE: MgMc7MenuHilite(2);break;
			case MT_OPTIONS: MgMc7MenuHilite(3);break;
			}
		adr_menu[title].ob_state |= SELECTED;
#else
		menu_tnormal(adr_menu, title, 0);
#endif
	}

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
			else
			{
				fslx_mode = fxopen;
				fslx_path[0] = fslx_fname[0] = EOS;
#ifdef MM7
				{
				char *dp;
				LONG ret;
				char macpath[256];

				strcpy(macpath, fslx_path+3);
				strcat(macpath, fslx_fname);
				while((dp = strchr(macpath, '\\')) != NULL)
					*dp = ':';
				ret = MgMc7NavGetFile(macpath, 256);
				if	(!ret)	/* OK */
					{
					fslx_path[0] = 'M';
					fslx_path[1] = ':';
					fslx_path[2] = '\\';
					strcpy(fslx_path+3, macpath);
					while((dp = strchr(fslx_path+3, ':')) != NULL)
						*dp = '\\';
					dp = get_name(fslx_path);
					strcpy(fslx_fname, dp);
					*dp = '\0';
					fslx_button = 1;	/* OK */
					}
				else	fslx_button = 0;	/* Abbruch */
				}
				open_file_close();
#else
				fslx_dialog = fslx_open(
							Rgetstring(STR_LOADFILE,NULL),
							-1,-1,
							&fslx_whdl,
							fslx_path, (int)sizeof(fslx_path),
							fslx_fname, (int)sizeof(fslx_fname),
							NULL,
							0L,
							NULL,
							SORTDEFAULT,
							0);
#endif
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
#ifdef MM7
	MgMc7MenuHilite(0);
#else
	menu_tnormal(adr_menu, title, 1);
#endif
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
		case 0x316e:	/* Cmd-N */
		case 0x310e:	/* ^N */
			do_menu(MT_FILE, MEN_NEW, w);
			break;

		case 0x186f:	/* Cmd-O */
		case 0x180f:	/* ^O */
			do_menu(MT_FILE, MEN_OPEN, w);
			break;

		case 0x1177:	/* Cmd-W */
		case 0x1615:	/* ^U */
			do_menu(MT_FILE, MEN_CLOSE, w);
			break;

		case 0x1f73:	/* Cmd-S */
		case 0x1f13:	/* ^S */
			do_menu(MT_FILE, MEN_SAVE, w);
			break;

		case 0x326d:	/* Cmd-M */
		case 0x320d:	/* ^M */
			do_menu(MT_FILE, MEN_SAVEAS, w);
			break;

		case 0x1071:	/* Cmd-Q */
		case 0x1011:	/* ^Q */
			w_ev->mwhich &= ~MU_KEYBD;	/* bearbeitet */
			return(1);	/* Ende */

		case	0x1265:	/* Cmd-E */
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
	char *pattern;
	WORD dummy;


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
	graf_mouse(ARROW, 0);
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

#ifdef MM7
	err = MgMc7Init();		/* Mac-Funktionen */
	if	(err)
		return((int) err);

	err = MgMc7InitMenuBar("MgEdit.rsrc", 128, adr_menu);
	if	(err)
		return((int) err);
#else
	menu_bar(adr_menu, TRUE);
#endif

	/* Alle �bergebenen Dateien �ffnen */
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
			  1,			/* linke Maustaste gedr�ckt	*/
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
			wdlg_close(d_options, &dummy, &dummy);
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
								&dummy,
								&pattern))
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
			 (w_ev.kstate & (K_CTRL+K_ALT+K_CMD))
			)
			if	(do_key(&w_ev, w))
				goto ende;

#ifdef MM7
		/* Mac-Funktionen */
		/* -------------- */

		if	(w_ev.mwhich & MU_BUTTON)
			{
			int menu, entry;

			err = MgMc7DoMouseClick(w_ev.mx, w_ev.my, &menu, &entry);
			if	(err)
				w_ev.mwhich &= ~MU_BUTTON;
			if	(err == 1)	/* Men� */
				{
				switch(menu)
					{
					case 1:
						menu = MT_DESK;
						switch(entry)
							{
							case 1: entry = MEN_ABOUT;break;
							default: entry = 0;
							}
						break;
					case 2:
						menu = MT_FILE;
						switch(entry)
							{
							case 1: entry = MEN_NEW;break;
							case 2: entry = MEN_OPEN;break;
							case 4: entry = MEN_CLOSE;break;
							case 5: entry = MEN_SAVE;break;
							case 6: entry = MEN_SAVEAS;break;
							case 8: 	MgMc7Exit();
									MgMc7Shutdown();
									break;
							case 9: entry = MEN_QUIT;break;
							default: entry = 0;
							}
						break;
					case 3:
						menu = MT_OPTIONS;
						switch(entry)
							{
							case 1: entry = MEN_PREFS;break;
							default: entry = 0;
							}
						break;
					default:
						menu = 0;
					}
				if	(do_menu(menu, entry, w))
					goto ende;
				}
			}
#endif
		
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
#ifdef MM7
					MgMc7DisableItem(1,0);
					MgMc7DisableItem(2,0);
					MgMc7DisableItem(3,0);
					MgMc7DrawMenuBar();
#else
					menu_ienable( adr_menu, MT_DESK, FALSE );
					menu_ienable( adr_menu, MT_FILE, FALSE );
					menu_ienable( adr_menu, MT_OPTIONS, FALSE );
					menu_bar(adr_menu, TRUE);
#endif
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
				w_ev.msg[2] = 0;		/* keine �berl�nge */
				/* Wort 3 und 4 unver�ndert */
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
#ifdef MM7
	MgMc7Exit();	/* Mac-Funktionen */
#endif
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
