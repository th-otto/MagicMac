/*
*
* EnthÑlt die spezifischen Routinen fÅr das
* Fenster der angezeigten Pfade
*
*/

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <tosdefs.h>
#include <string.h>
#include <stdlib.h>
#include <magx.h>
#include "mgsearch.h"
#include "gemutils.h"
#include "portab.h"
#include "windows.h"
#include "srch_win.h"

/* Speicher in Blîcken holen */

#define	BLOCKLEN	8192

#define	WXOFFS	3
#define	WYOFFS	1
#define	WXDIST	3
#define	WYDIST	1

/* max. Anzahl Dateien */

#define NOBJS	1000

/* Daten fÅrs Fenster */
static WINDOW fnamewindow;

static WINDOW *mywindow = NULL;

static char *block = NULL;			/* aktueller Speicherblock */
static char *wpos = NULL;				/* Schreibposition */
static size_t free_block;			/* noch Platz im Block */

int exit_immed = FALSE;


/*******************************************************************
*
* Taste
*
*******************************************************************/

#pragma warn -par
static void key_fnames( WINDOW *w, int kstate, int key )
{
	switch(key)
		{
/* ^Q */
		case 0x1011:
/* ^U */
		case 0x1615:	exit_immed = TRUE;
					break;
/* Pos1  */
		case	0x4700:	w->arrowed(w, -1);
					break;
/* SH-Pos1 */
		case 0x4737:	w->arrowed(w, -2);
					break;
/* Cursor up */
		case 0x4800:	w->arrowed(w, WA_UPLINE);
					break;
/* Cursor down */
		case 0x5000:	w->arrowed(w, WA_DNLINE);
					break;
/* SH-Cursor up */
		case 0x4838:	w->arrowed(w, WA_UPPAGE);
					break;
/* SH-Cursor dwn */
		case 0x5032:	w->arrowed(w, WA_DNPAGE);
					break;
		}
}


/*******************************************************************
*
* Mausklick
*
*******************************************************************/

static void button_fnames( WINDOW *w, int kstate,
				int x, int y, int button, int nclicks )
{
	register int i;
	int	objnr;
	int	mstat;
	int	dummy;
	int	msg[8];
	static char path[128];	/* static wg. verschicken ! */
	static char fname[128];
	char *s;



	graf_mkstate(&dummy, &dummy, &mstat, &dummy);

	/* Klick auf Hintergrundfenster.					*/
	/* Weil WF_BEVENT gesetzt ist, wird das Fenster nicht	*/
	/* vom System nach oben gebracht. Dies muû daher		*/
	/* manuell erfolgen. Hier nur bei kurzem Einfachklick	*/
	/* mit nur der linken Maustaste und ohne			*/
	/* Umschalttasten!								*/
	/* --------------------------------------------------- */

	if	((nclicks == 1) && (button == 1) && (!kstate) &&
			(w->handle != top_whdl()))
		{
		if	(!mstat)	/* wieder losgelassen! */
			{
			wind_set_int(w->handle, WF_TOP, 0);
#if 0
			wind_set(-1, WF_TOP, -1);	/* MenÅ nach oben! */
#endif
			return;
			}
		}

	objnr = find_obj(w->tree, x, y);
	for	(i = 1; i <= w->shownum; i++)
		{
		if	((i != objnr) && (selected(w->tree, i)))
			{
			ob_dsel(w->tree, i);
			obj_malen(w->handle, w->tree, i);
			}
		}

	if	(objnr <= 0)
		return;

	if	(!selected(w->tree, objnr))
		{
		ob_sel(w->tree, objnr);
		obj_malen(w->handle, w->tree, objnr);
		}
	else
	if	(nclicks != 2)
		{
		ob_dsel(w->tree, objnr);
		obj_malen(w->handle, w->tree, objnr);
		}

	if	(nclicks == 2)
		{
		strcpy(path,(w->tree+objnr)->ob_spec.free_string);
		s = get_name(path);
		strcpy(fname, s);
		*s = EOS;
/*
		msg[0] = AV_OPENWIND;
		msg[1] = ap_id;
		msg[2] = 0;
		*((void **) (msg+3)) = path;
		*((void **) (msg+5)) = "*.*";
		msg[7] = 0;
*/
		msg[0] = AV_XOPENWIND;
		msg[1] = ap_id;
		msg[2] = 0;
		*((void **) (msg+3)) = path;
		*((void **) (msg+5)) = fname;
		msg[7] = 0x0003;	/* ggf. ex.Fenster, Sel.maske */

		appl_write(0, 16, msg);
		}
}
#pragma warn +par


/*******************************************************************
*
* Initialisierung
*
*******************************************************************/

void init_fnames( GRECT *g )
{
	if	(!g->g_w || !g->g_h)
		{
		fnamewindow.out.g_x = scrx;
		fnamewindow.out.g_y = scry;
		fnamewindow.out.g_w = scrw;
		fnamewindow.out.g_h = scrh;
		}
	else	fnamewindow.out = *g;
}


/*******************************************************************
*
* Beendigung
*
*******************************************************************/

void exit_fnames( GRECT *g )
{
	*g = fnamewindow.out;
}


/*******************************************************************
*
* Schlieûen
*
*******************************************************************/

#pragma warn -par
static void close_fnames( WINDOW *w, int kstate )
{
	WINDOW **sw;

	wind_close(w->handle);
	wind_delete(w->handle);
	Mfree(w->tree);
	sw = find_slot_window(w);
	mywindow = NULL;
	*sw = NULL;

	exit_immed = TRUE;
}
#pragma warn +par


/*******************************************************************
*
* Fenster îffnen
*
*******************************************************************/

int open_fnames( void )
{
	WINDOW **w;
	register OBJECT *o;


	if	(mywindow)		/* schon geîffnet */
		{
		wind_set_int(WF_TOP, mywindow->handle, 0);
		return(0);	/* OK */
		}
	w = new_window();
	if	(!w)
		return(-1);		/* kein Slot */
	fnamewindow.handle = wind_create(NAME+CLOSER+FULLER+MOVER+
						SIZER+UPARROW+DNARROW+VSLIDE+
						LFARROW+RTARROW+HSLIDE,
						fnamewindow.out.g_x,
						fnamewindow.out.g_y,
						fnamewindow.out.g_w,
						fnamewindow.out.g_h);

	fnamewindow.tree = Malloc(sizeof(OBJECT) * (NOBJS+1));
	if	(!fnamewindow.tree)
		return(-3);
	block = wpos = Malloc(BLOCKLEN);
	if	(!block)
		return(-3);
	free_block = BLOCKLEN;


	if	(fnamewindow.handle < 0)
		{
		Mfree(fnamewindow.tree);
		return(-2);		/* kein AES-Fenster */
		}

	/* Baum aufbauen */

	o = fnamewindow.tree;
	/* Objekt der weiûen Hintergrundbox */
	o -> ob_next = -1;
	o -> ob_type = G_BOX;
	o -> ob_state = NORMAL;
	o -> ob_spec.index = (long) (WHITE);
	o -> ob_flags = LASTOB;
	o -> ob_head = o -> ob_tail = -1;

	init_window(&fnamewindow);

	/* horiz. Scrolling aktivieren */
	fnamewindow.step_hshift = gl_hwchar;
	fnamewindow.allsteps_hshift = 0;
	fnamewindow.set_hshift = hshift;	/* !! */

	fnamewindow.flags = 0;
	fnamewindow.is_1col = TRUE;
	fnamewindow.showw = 200;
	fnamewindow.showh = gl_hhchar;
	fnamewindow.shownum = 0;
	fnamewindow.xoffs = WXOFFS;
	fnamewindow.yoffs = WYOFFS;
	fnamewindow.xdist = WXDIST;
	fnamewindow.ydist = WYDIST;
	fnamewindow.button = button_fnames;
	fnamewindow.key = key_fnames;
	fnamewindow.close = close_fnames;
	*w = mywindow = &fnamewindow;
	wind_set_str(fnamewindow.handle, WF_NAME, Rgetstring(STR_WINTITLE));
	wind_set(fnamewindow.handle, WF_BEVENT, 0x0001, 0, 0, 0 );
	fnamewindow.open(&fnamewindow);
	return(0);
}


/*******************************************************************
*
* Titelzeile Ñndern, weil Suchvorgang fertig
*
*******************************************************************/

void srch_finished( void )
{
	wind_set_str(fnamewindow.handle, WF_NAME, Rgetstring(STR_WINTITLE) + 2);
}


/*******************************************************************
*
* Pfadobjekt hinzufÅgen.
*
*******************************************************************/

int add_path( char *s )
{
	WINDOW *w;
	size_t	len;
	register int n;
	register OBJECT *tree,*o;
	int y;


	w = &fnamewindow;
	if	(w->shownum >= NOBJS)
		return(-1);		/* öberlauf */
	len = strlen(s) + 1;	/* benîtigter Platz */
	if	(len > BLOCKLEN)	/* ??? */
		return(-2);

	if	(free_block < len)
		{
		block = wpos = Malloc(BLOCKLEN);
		if	(!block)
			return(-3);
		free_block = BLOCKLEN;
		}

	tree = w->tree;
	n = w->shownum++;		/* Anzahl Objekte erhîhen */
	w->lins++;			/* = Anzahl Zeilen */
	o = tree + n;
	o->ob_flags &= ~LASTOB;

	if	(n)				/* VorgÑnger */
		{
		o->ob_next = n+1;
		y = o->ob_y + w->showh + w->ydist;
		}
	else	{
		tree->ob_head = n+1;
		y = w->yoffs;
		}

	o++;
	n++;
	tree->ob_tail = n;
	o->ob_x = w->xoffs;
	o->ob_y = y;
	o->ob_height = w->showh;
	o->ob_width = gl_hwchar * (int) strlen(s);
	if	(strlen(s) > w->allsteps_hshift)
		w->allsteps_hshift = (int) strlen(s);
	o->ob_head = o->ob_tail = -1;
	o->ob_next = 0;
	o->ob_flags = LASTOB;
	o->ob_state = NORMAL;
	o->ob_type = G_STRING;
	o->ob_spec.free_string = wpos;
	memcpy(wpos, s, len);
	wpos += len;
	free_block -= len;
	window_calc_vslider(w);
	window_calc_hslider(w);
	obj_malen(w->handle, w->tree, n);
	return(0);
}
