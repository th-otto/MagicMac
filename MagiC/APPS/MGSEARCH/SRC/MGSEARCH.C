/*******************************************************************
*
*             MGSEARCH.APP                             2.04.95
*             ============
*                                 letzte Žnderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: MGSEARCH.PRJ
*
* Modul zum Suchen von Dateien
* Parameter:
*
* -Dabcdef (Liste der zu durchsuchenden Laufwerke)
*
*	oder
*
* -P<path>
*
****************************************************************/

#include <aes.h>
#include <vdi.h>
#include <portab.h>
#include <tos.h>
#include <magx.h>
#include <string.h>
#include <stdlib.h>
#include <tosdefs.h>
#include "windows.h"
#include "mgsearch.h"
#include "search.h"
#include "srch_win.h"
#include "gemutils.h"


static GRECT winpos,old_winpos;
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int	scrx,scry,scrw,scrh;


void open_work		(void);
void close_work     (void);

static int ready;


/************************************************************
*
* Wird aufgerufen, wenn ein Match gefunden wurde.
*
************************************************************/

void callback_match(char *path, char *fname)
{
	char buf[512];

	strcpy(buf, path);
	strcat(buf, fname);
	add_path(buf);			/* im Fenster */
}


/************************************************************
*
* Wird regelm„žig aufgerufen.
*
* Ršckgabe > 0:	Suchvorgang abbrechen.
*
************************************************************/

int callback_ever( void )
{
	WINDOW *w;
	int	message[16];
	int  mwhich, nclicks, keycode, kstate,
		button, yclick, xclick;
	int evtype;


	evtype = MU_KEYBD+MU_BUTTON+MU_MESAG;
	if	(!ready)
		evtype += MU_TIMER;
	mwhich = evnt_multi(evtype,
				  2,			/* Doppelklicks erkennen 	*/
				  1,			/* nur linke Maustaste		*/
				  1,			/* linke Maustaste gedrckt	*/
				  0,0,0,0,0,	/* kein 1. Rechteck			*/
				  0,0,0,0,0,	/* kein 2. Rechteck			*/
				  message,
				  0,0,	/* ms */
				  &xclick, &yclick,
				  &button, &kstate,
				  &keycode, &nclicks
				  );

	if	(mwhich & MU_KEYBD)
		{
		w = whdl2window(top_whdl());
		if	(w)
			{
			w->key(w, kstate, keycode);
			mwhich &= ~MU_KEYBD;	/* bearbeitet */
			}
		}

	if	(mwhich & MU_BUTTON)
		{
		w = whdl2window(wind_find(xclick, yclick));
		if	(w)
			{
			w->button(w, kstate, xclick, yclick,
					button, nclicks);
			mwhich &= ~MU_BUTTON;	/* bearbeitet */
			}
		}

	if	(mwhich & MU_MESAG)
		{
		if	(message[0] == AP_TERM)
			exit_immed = TRUE;
		else
		if	(((message[0] >= 20) &&
			(message[0] < 40)) ||		/* WM_XX */
	 		(message[0] >= 1040))
			{
			w = whdl2window(message[3]);
			if	(w)
				{
				w->message(w, kstate, message);
				mwhich &= ~MU_MESAG;	/* bearbeitet */
				}
			}
		}

	return(exit_immed);		/* ggf. abbrechen */
}


/************************************************************
*
* String-> Gr”ženangabe
*
************************************************************/

long get_size(char *s)
{
	long l;
	char *t;

	l = strtoul(s, &t, 10);
	if	(s != t)
		{
		if	(!*t)
			return(l);
		if	((*t == 'k') || (*t == 'K'))
			{
			t++;
			if	(!*t)
				return(l << 10);		/* Bytes -> kBytes */
			}
		else
		if	((*t == 'm') || (*t == 'M'))
			{
			t++;
			if	(!*t)
				return(l << 20);		/* Bytes -> MBytes */
			}
		}
	Rform_alert(1, ALRT_INVAL_SIZE);
	return(-2);
}


/************************************************************
*
* String (z.B. "210765") -> Datumsangabe
*
************************************************************/

int str_2_date(char *s)
{
	int d,m,y;
	char hilfs[3];


	if	(strlen(s) == 6)
		{
		hilfs[0] = s[0];
		hilfs[1] = s[1];
		hilfs[2] = EOS;
		d = atoi(hilfs);
	
		hilfs[0] = s[2];
		hilfs[1] = s[3];
		m = atoi(hilfs);
	
		hilfs[0] = s[4];
		hilfs[1] = s[5];
		y = atoi(hilfs);
		if	(y >= 80)
			y -= 80;	/* 1980..1999 */
		else	y += 20;	/* 2000..2079 */

		if	((d >= 1) && (d < 32) &&
			 (m >= 1) && (m < 13))
			{
			return(d | (m << 5) | (y << 9));
			}	
		}

	Rform_alert(1, ALRT_INVAL_DATE);
	return(-2);
}


/************************************************************
*
* Der Suchdialog.
*
************************************************************/

static int obj_tab[] = {
			IS_LSIZE, LSIZ_TXT,
			IS_HSIZE, HSIZ_TXT,
			IS_LDATE, LDATE,
			IS_HDATE, HDATE,
			-1};

static	char *txt;
static	char *lsiz,*hsiz,*ldate,*hdate;
static	int	date_l, date_h;
static	long size_l, size_h;


static int chk_srch(OBJECT *tree, int exitbutton)
{
	register int *i;

	if	(exitbutton == SRCH_AB)
		return(TRUE);

	i = obj_tab;
	while(*i >= 0)
		{
		if	(*i == exitbutton)
			{
			i++;
			if	(selected(tree, exitbutton))
				objs_enable(tree, *i, 0);
			else	objs_disable(tree, *i, 0);
			subobj_draw (tree, *i, 0, MAX_DEPTH);
			return(FALSE);
			}
		i += 2;
		}

	if	(exitbutton == SRCH_OK)
		{
		if	(!*txt)
			{
			Rform_alert(1, ALRT_NO_PATTERNS);
			err:
			ob_dsel(tree, exitbutton);
			subobj_draw (tree, exitbutton, 0, MAX_DEPTH);
			return(FALSE);
			}
		if	(selected(tree, IS_LSIZE))
			{
			size_l = get_size(lsiz);
			if	(size_l == -2)
				goto err;			/* Fehler */
			}
		else	size_l = -1;
	
		if	(selected(tree, IS_HSIZE))
			{
			size_h = get_size(hsiz);
			if	(size_h == -2)
				goto err;			/* Fehler */
			}
		else	size_h = -1;

		if	(selected(tree, IS_LDATE))
			{
			date_l = str_2_date(ldate);
			if	(date_l == -2)
				goto err;			/* Fehler */
			}
		else	date_l = -1;
	
		if	(selected(tree, IS_HDATE))
			{
			date_h = str_2_date(hdate);
			if	(date_h == -2)
				goto err;			/* Fehler */
			}
		else	date_h = -1;
		return(TRUE);				/* ok */
		}
	return(FALSE);
}

long	srch_dialog( char *param )
{
	OBJECT *adr_search;
	int	ret;
	char path[128] = "X:\\";


	rsrc_gaddr(0, T_SEARCH, &adr_search);
	txt   = adr_search[T_PATTRN].ob_spec.tedinfo->te_ptext;
	lsiz  = adr_search[LSIZ_TXT].ob_spec.tedinfo->te_ptext;
	hsiz  = adr_search[HSIZ_TXT].ob_spec.tedinfo->te_ptext;
	ldate = adr_search[LDATE].ob_spec.tedinfo->te_ptext;
	hdate = adr_search[HDATE].ob_spec.tedinfo->te_ptext;

	*txt = *lsiz = *hsiz = *ldate = *hdate = EOS;
	wind_update(BEG_UPDATE);
	ret = do_exdialog(adr_search, chk_srch, NULL);
	wind_update(END_UPDATE);
	if	(ret == SRCH_AB)
		return(EBREAK);

	init_fnames( &winpos );
	open_fnames();

	if	((param[0] != '-') || (param[1] != 'D'))
		{
		if	(*param == '-')
			{
				param++;
			if	(*param)
				param++;
			}
		strcpy(path, param);
		filesearch(path, txt, date_l, date_h, size_l, size_h,
				callback_ever, callback_match);
		}
	else	{
		param += 2;
		while(*param)	/* Laufwerke */
			{
			path[0] = *param++;
			filesearch(path, txt, date_l, date_h, size_l, size_h,
			callback_ever, callback_match);
			}
		}
	srch_finished( );
	return(E_OK);
}


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgr”že <old> abgespeichert, jetzt ist die
* Bildschirmgr”že <new>.
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

void read_inf( char *fname, GRECT *gwin )
{
	char buf[512];
	long len;
	int hdl;
	char *s,*t;
	int oldwh[2];


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

	if	((s) || (shel_find(infpath)))
		{
		hdl = (int) Fopen(infpath, RMODE_RD);
		if	(hdl < 0)
			return;
		len = Fread(hdl, 511L, buf);
		Fclose(hdl);
		if	(len < E_OK)
			return;
		buf[len] = EOS;

		/* erste Zeile berlesen */

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

			if	(!strncmp(s, "WINDOW PATHS ", 13))
				{
				s += 13;
				scan_values(&s, 4, (int *) gwin);
				}

			weiter:

			while((*s) && (*s != '\n'))
				s++;

			if	(*s == '\n')
				s++;
			}


		if	(oldwh[0] != scrw)
			{
			recalc(&(gwin->g_x), oldwh[0], scrw);
			recalc(&(gwin->g_w), oldwh[0], scrw);
			}
		if	(oldwh[1] != scrh)
			{
			recalc(&(gwin->g_y), oldwh[1], scrh);
			recalc(&(gwin->g_h), oldwh[1], scrh);
			}
		gwin->g_x += scrx;
		gwin->g_y += scry;

		}
}


/****************************************************************
*
* Schreibe INF-Datei
*
****************************************************************/

void write_inf( GRECT *gwin )
{
	int hdl;
	char buf[128];
	int scrwh[2];



	hdl = (int) Fcreate(infpath, 0);
	if	(hdl < 0)
		return;
	Fwrite(hdl, 34L,	"[MGSEARCH Header V 0]\r\n"
					"SCREENSIZE ");
	scrwh[0] = scrw;
	scrwh[1] = scrh;
	print_values(buf, 2, scrwh);
	strcat(buf, "\r\nWINDOW PATHS ");
	gwin->g_x -= scrx;
	gwin->g_y -= scry;
	print_values(buf + strlen(buf), 4, (int *) gwin);
	Fwrite(hdl, strlen(buf), buf);
	Fclose(hdl);
}


/**************** HAUPTPROGRAMM ******************/

int main( int argc, char *argv[] )
{
/*	GRECT desk;	*/
	char param[256];


	if   ((ap_id = appl_init()) < 0)
		Pterm(-1);
	wind_get(SCREEN, WF_WORKXYWH, &scrx, &scry, &scrw, &scrh);
	vdi_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

/*
	desk.g_x = scrx;
	desk.g_y = scry;
	desk.g_w = scrw;
	desk.g_h = scrh;
*/

	/* Kommandozeile auswerten */
	/* ----------------------- */

	if	(argc != 2)
		{
		strcpy(param, "-Dx");
		param[2] = Dgetdrv() + 'A';
		}
	else	strcpy(param, argv[1]);

	Mrsrc_load("mgsearch.rsc");
	open_work();

	read_inf("MGSEARCH.INF", &winpos);
	old_winpos = winpos;

	Mgraf_mouse(ARROW);
	if	(EBREAK == srch_dialog(param))
		{
		close_work();
		return(0);
		}

	ready = TRUE;
	while(!exit_immed)
		callback_ever();

	exit_fnames( &winpos );
	if	(memcmp(&winpos, &old_winpos, sizeof(GRECT)))
		write_inf(&winpos);

	close_work();
	return(0);
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
