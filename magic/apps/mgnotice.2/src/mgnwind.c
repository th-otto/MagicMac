/*
*
* EnthÑlt die spezifischen Routinen fÅr die
* Notizfenster
*
*/

#define DEBUG 0

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#if DEBUG
#include <stdio.h>
#endif
#include <stdlib.h>
#include "gemut_mt.h"
#include "portab.h"
#include "windows.h"
#include "globals.h"

WINDOW *selected_window = NULL;


/*******************************************************************
*
* Notizfenstergrîûe berechnen
*
*******************************************************************/

void calc_size_notice_wind( WINDOW *w )
{
	WORD dummy;
	long nlines;
	long yscroll;
	WORD yvis,yval;
	WORD ncols,xscroll,xvis;


	vst_font(vdi_handle, w->fontID);
	vst_point(vdi_handle, w->fontH, &dummy, &dummy,
			&w->charW, &w->charH);

	*((GRECT *) &(w->tree.ob_x)) = w->in;
	/* Tabulatorweite und Autowrap-Breite */
	edit_set_format( &w->tree, EDITFELD,
				w->tabwidth, (&w->tree)[EDITFELD].ob_width);

	if	(w->buf[0])
		{
		edit_get_scrollinfo( &w->tree, EDITFELD,
				&nlines, &yscroll,
				&yvis, &yval,
				&ncols, &xscroll, &xvis );
#if	DEBUG
	printf("%ld Zeilen\n", nlines);
#endif
		}
	else	nlines = 3;	/* fÅr leeres Fenster */

	nlines *= (long) w->charH;
	if	(nlines > scrg.g_h)
		nlines = scrg.g_h;
	if	(nlines < w->charH)
		nlines = w->charH;
	w->in.g_h = w->tree.ob_height = (int) nlines + MOVER_HEIGHT;
	if	(ncols > 16)
		w->in.g_w = ncols;

	/* Auûenbereich berechnen */

	wind_calc(WC_BORDER, NOTICE_W_KIND, &(w->in),&(w->out));
}


/*******************************************************************
*
* Ein Fenster deselektieren
*
*******************************************************************/

void deselect_window( WINDOW *w )
{
	if	(w->selected)
		{
		w->selected = FALSE;
		edit_cursor(&(w->tree), EDITFELD, w->handle, FALSE );
		/* wir erzwingen Neuberechnung von <nlines> */
		edit_set_format( &w->tree, EDITFELD,
				w->tabwidth, 0);
		/* und optimieren die Fensterhîhe */
		calc_size_notice_wind( w );
		w->sized(w, &(w->out));
		}
}


/*******************************************************************
*
* Ein Fenster selektieren
*
*******************************************************************/

void select_window( WINDOW *w )
{
	register int i;

	/* Fenster selektieren */
	/* ------------------- */

	if	(!w->selected)
		{
		w->selected = TRUE;
		edit_cursor(&(w->tree), EDITFELD, w->handle, TRUE );
	/*	update_window(w);	*/
		selected_window = w;

		/* ggf. andere Fenster deselektieren */
		/* --------------------------------- */

		for	(i = 0; i < NWINDOWS; i++)
			if	((windows[i]) &&
				 (windows[i] != w) &&
				 (windows[i]->selected))
				{
				deselect_window(windows[i]);
				}
		}
}


/*******************************************************************
*
* Mausklick
*
*******************************************************************/

static void MY_buttoned( WINDOW *w, int nclicks, EVNTDATA *ev )
{
	EVNTDATA evm;


	if	(w->selected)
		{
		EVNT w_ev;
		LONG err;


		w_ev.mwhich = MU_BUTTON;
		w_ev.mclicks = nclicks;
		*((EVNTDATA *) (&w_ev.mx)) = *ev;
		edit_evnt( &(w->tree), EDITFELD,
			w->handle, &w_ev, &err );
		return;
		}

	graf_mkstate(&evm.x, &evm.y, &evm.bstate, &evm.kstate);

	if	(evm.bstate)	/* Maustaste noch gedrÅckt */
		{
		/* Beim Klick rechts unten wird das Fenster	*/
		/* in der Grîûe verÑndert				*/

		if	((ev->x > w->out.g_x + w->out.g_w - 8) &&
			 (ev->y > w->out.g_y + w->out.g_h - 8))
			{
			graf_rubbox(w->in.g_x, w->in.g_y,
						16, w->charH,
						&w->in.g_w, &w->in.g_h);
			wind_calc(WC_BORDER, NOTICE_W_KIND, &(w->in),&(w->out));
			w->sized(w, &w->out);
			}
		else	{
		/* Ansonsten wird das Fenster verschoben	*/
			graf_dragbox(w->out.g_w, w->out.g_h,
						w->out.g_x, w->out.g_y,
						&scrg,
						&w->out.g_x, &w->out.g_y);
			w->moved(w, &w->out);
			}
		return;
		}

	/* Doppelklick auf Fenster: aktivieren	*/
	/* ------------------------------------ */

	if	(nclicks == 2)
		{
		wind_set(w->handle, WF_TOP, 0, 0, 0, 0);
		wind_set(0, WF_TOPALL, ap_id, 0,0,0);
		select_window(w);
		return;
		}

	/* Klick auf Hintergrundfenster.					*/
	/* Weil WF_BEVENT gesetzt ist, wird das Fenster nicht	*/
	/* vom System nach oben gebracht. Dies muû daher		*/
	/* manuell erfolgen. Hier nur bei kurzem Einfachklick	*/
	/* mit nur der linken Maustaste und ohne			*/
	/* Umschalttasten!								*/
	/* --------------------------------------------------- */

	if	((nclicks == 1) && (ev->bstate == 1) && (!ev->kstate))
		{
		if	(!evm.bstate)	/* wieder losgelassen! */
			{
			wind_set(w->handle, WF_TOP, 0, 0, 0, 0);
			wind_set(0, WF_TOPALL, ap_id, 0,0,0);
			/*
			top_all_my_windows();
			*/

			/* Fenster selektieren */
			/* ------------------- */

/*
			if	(!w->selected)
				{
				select_window(w);
				}
*/
/*
			wind_set(-1, WF_TOP, -1);	/* MenÅ nach oben! */
*/
			return;
			}
		}
}
#pragma warn +par


/*******************************************************************
*
* Verschieben
*
*******************************************************************/

static void MY_moved(WINDOW *w, GRECT *g)
{
	w->out = *g;
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	*((GRECT *) &(w->tree.ob_x)) = w->in;
	w->position_dirty = TRUE;	/* Position ist geÑndert */
}


/*******************************************************************
*
* Grîûe Ñndern
*
*******************************************************************/

static void MY_sized(WINDOW *w, GRECT *g)
{
	WORD oldrh,newrh;

	if	(w->flags & WFLAG_ICONIFIED)
		return;
	w->out = *g;
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	*((GRECT *) &(w->tree.ob_x)) = w->in;
	edit_set_format( &w->tree, EDITFELD,
				w->tabwidth, (&w->tree)[EDITFELD].ob_width);
	edit_resized(&w->tree, EDITFELD, &oldrh, &newrh);
	w->position_dirty = TRUE;	/* Position ist geÑndert */
	update_window(w);
}


/*******************************************************************
*
* Tastencode
*
*******************************************************************/

static void MY_keyed( WINDOW *w, int kstate, int key )
{
	EVNT w_ev;
	LONG err;


	if	(w->selected)
		{
		if	(key == 0x011b)
			{
			deselect_window(selected_window);
			selected_window->selected = FALSE;
			selected_window = NULL;
			}
		else	{
			w_ev.key = key;
			w_ev.kstate = kstate;
			w_ev.mwhich = MU_KEYBD;
			edit_evnt( &(w->tree), EDITFELD,
					w->handle, &w_ev, &err );
			}
		}
	else	{
		}
}


/****************************************************************
*
* Organisiert das Fenster neu, d.h. legt Position der Objekte fest.
* gibt TRUE zurÅck, falls sich fenster.cols oder fenster.shift
* geÑndert haben.
*
****************************************************************/

#pragma warn -par
static int arrange_notice_wind( WINDOW *w )
{
	return(FALSE);
}
#pragma warn .par


/*******************************************************************
*
* Neues Notizfenster îffnen
*
* <notice> zeigt auf die Notiz, die Zeilen sind mit CR/LF
* abgeschlossen, der Gesamttext mit EOS.
*
*******************************************************************/

long open_notice_wind( unsigned char *notice, int id,
					GRECT *g,
					int fontID, int font_is_prop, int fontH,
					int colour,
					WINDOW **pw )
{
	WINDOW **wp;
	WINDOW *w;
	int i;
	int tcolour;


	if	(id < 0)
		{
		for	(id = 0; id < NWINDOWS; id++)
			{
			for	(i = 0; i < NWINDOWS; i++)
				{
				if	(!windows[i])
					continue;		/* leerer Slot */
				if	(windows[i]->id_code == id)
					goto weiter;	/* id ist belegt */
				}
			break;	/* id ist noch frei */
			weiter:
			;
			}
		if	(id >= NWINDOWS)
			return(ENSMEM);
		}

	wp = new_window();
	if	(!wp)
		return(ENSMEM);		/* kein Slot */
	w = Malloc(sizeof(WINDOW));
	if	(!w)
		return(ENSMEM);
	w->handle = wind_create(NOTICE_W_KIND, &scrg);	/* keine Fensterelemente */
	if	(w->handle < 0)
		{
		fehler:
		Mfree(w);
		return(ENSMEM);
		}

	/* Einstellungen */
	/* ------------- */

	w->id_code = id;
	w->selected = FALSE;
	w->bcolour = colour;
	w->tcolour = COLSPEC_GET_TEXTCOL(adr_colour[colour+1].ob_spec.tedinfo->te_color);
	w->fontH = fontH;
	w->fontID = fontID;
	w->fontprop = font_is_prop;
	w->tabwidth = 64;

	/* Puffer anlegen */
	/* -------------- */

	w->bufsize = NOTICE_MEM;
	w->buf = Malloc(w->bufsize);
	if	(!w->buf)
		goto fehler;
	strcpy(w->buf, (char *) notice);

	/* Objektbaum aufbauen */
	/* ------------------- */

	w->xedit = edit_create();
	if	(!w->xedit)
		{
		Mfree(w->buf);
		goto fehler;
		}
	w->tree.ob_next = w->tree.ob_head = w->tree.ob_tail = -1;
	w->tree.ob_flags = LASTOB;
	w->tree.ob_state = 0;
	w->tree.ob_type = G_EDIT;
	w->tree.ob_spec.index = (long) w->xedit;
	edit_set_buf( &w->tree, EDITFELD,	w->buf, w->bufsize );
	edit_set_font( &w->tree, EDITFELD,
				w->fontID, w->fontH, FALSE, !w->fontprop);
	tcolour = (w->bcolour < ncolours) ? w->tcolour : WHITE;
	edit_set_color( &w->tree, EDITFELD,
				tcolour, w->bcolour);

	*wp = w;
	init_window(w);

	w->in = *g;

	if	(!(*notice))
		{
		w->in.g_w += 80;
		w->in.g_h += 40;
		}

	/* Breite und Hîhe des EDIT-Objekts festlegen.		*/
	/* Die Breite ist vorgegeben, die Hîhe stellt sicher,	*/
	/* daû alle Zeilen sichtbar sind.					*/
	/* --------------------------------------------------- */

	calc_size_notice_wind( w );

	/* Spezielle Einstellungen */
	/* ----------------------- */

	wind_set(w->handle, WF_BEVENT, 0x0001, 0, 0, 0 );

	w->arrange = arrange_notice_wind;
	w->moved = MY_moved;
	w->sized = MY_sized;

	w->button = MY_buttoned;
	w->key = MY_keyed;
	w->open(w);

	edit_cursor( &w->tree, EDITFELD, -1, 0);	/* Cursor aus */
	edit_open( &w->tree, EDITFELD );
	if	(pw)
		*pw = w;
	return(E_OK);
}
