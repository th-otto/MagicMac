/*
*
* EnthÑlt die allgemeinen Routinen fÅr die
* Fensterverwaltung
*
*/

#include <aes.h>
#include <stdlib.h>
#include <stddef.h>
#include <vdi.h>
#include "gemut_mt.h"
#include "windows.h"

#ifndef WM_ICONIFY
#define WM_ICONIFY       34                                 /* AES 4.1     */
#define WM_UNICONIFY     35                                 /* AES 4.1     */
#define WM_ALLICONIFY    36                                 /* AES 4.1     */
#endif

WINDOW *windows[NWINDOWS];


/****************************************************************
*
* Rechnet Fensterhandle in WINDOW um.
*
****************************************************************/

WINDOW *whdl2window(int whdl)
{
	register int i;
	register WINDOW **w;


	for	(i = 0,w = windows; i < NWINDOWS; i++,w++)
		{
		if	(!*w)
			continue;		/* leerer Slot */
		if	((*w)->handle == whdl)
			return(*w);
		}
	return(NULL);
}


/****************************************************************
*
* ermittelt unbenutzten WINDOW-Slot.
*
****************************************************************/

WINDOW **new_window( void )
{
	register int i;
	register WINDOW **w;


	for	(i = 0,w = windows; i < NWINDOWS; i++,w++)
		{
		if	(!*w)
			return(w);		/* leerer Slot */
		}
	return(NULL);
}


/****************************************************************
*
* ermittelt einen WINDOW-Slot
*
****************************************************************/

WINDOW **find_slot_window( WINDOW *myw )
{
	register int i;
	register WINDOW **w;


	for	(i = 0,w = windows; i < NWINDOWS; i++,w++)
		{
		if	(*w == myw)
			return(w);
		}
	return(NULL);
}


/****************************************************************
*
* Das Objekt mit der Objektnummer <index> wird neu gemalt.
* (da es sich entweder verschoben hat oder der Status sich
*  geÑndert hat).
* Das Objekt liegt im Fenster mit Nummer <wnr> bzw. auf dem
* Desktop, wenn <wnr> = 0;
*
****************************************************************/

void obj_malen(int whdl, OBJECT *tree, int index)
{
	GRECT 	list,neu;


	objc_offset(tree, index, &(neu.g_x), &(neu.g_y));
	neu.g_w = (tree+index)->ob_width;
	neu.g_h = (tree+index)->ob_height;

	index = 0;
	wind_get_grect(whdl,WF_FIRSTXYWH, &list);
	do	{
		if	(rc_intersect(&neu,&list))
			objc_draw(tree,index,1, &list);
		wind_get_grect(whdl,WF_NEXTXYWH,&list);
		}
	while(list.g_w > 0);
}


/****************************************************************
*
* Malt das Fenster mit Nummer <wnr> im Bereich
* neu_x,neu_y,neu_b,neu_h  nach.
*
****************************************************************/

void redraw_window(WINDOW *w, GRECT *neu)
{
	GRECT g;


	graf_mouse(M_OFF, NULL);
	wind_get(w->handle,WF_FIRSTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
	do	{
		if	(rc_intersect(neu,&g))
			w->draw(w, &g);
		wind_get(w->handle,WF_NEXTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */
	graf_mouse(M_ON, NULL);
}


/****************************************************************
*
* Zeichnet das Fenster <wnr> neu.
*
****************************************************************/

int update_window(WINDOW *w)
{
	WMESAG mesag;

	/* Der Redraw wird nicht direkt ausgefÅhrt, sondern schickt */
	/* eine Nachricht an die Applikation, um Kollisionen mit    */
	/* von AES erzeugten Redraws zu vermeiden                   */
	/* -------------------------------------------------------- */

	mesag.msg.code		= WM_REDRAW;
	mesag.msg.dest_apid	= ap_id;
	mesag.msg.is_zero	= 0;
	mesag.msg.whdl		= w->handle;
	mesag.msg.g		= w->out;
	return(appl_write(ap_id, 16, mesag.message));
}


/****************************************************************
*
* Die Innenmaûe des Fensters werden berechnet.
*
****************************************************************/

static void calc_in(WINDOW *w)
{
	register int scrolled_pixels;
	register GRECT *ob_grect;



	ob_grect = (GRECT *) &((w->tree)->ob_x);
	wind_get(w->handle, WF_WORKXYWH,
					&(w->in.g_x),
					&(w->in.g_y),
					&(w->in.g_w),
					&(w->in.g_h));

	*ob_grect = w->in;
	if	(!(w->flags & WFLAG_ICONIFIED))
		{
		scrolled_pixels = w->vshift*(w->showh+w->ydist);
		(w->tree)->ob_y -= scrolled_pixels;
		(w->tree)->ob_height += scrolled_pixels;
		if	(w->step_hshift)
			{
			scrolled_pixels = w->hshift*w->step_hshift;
			(w->tree)->ob_x -= scrolled_pixels;
			(w->tree)->ob_width += scrolled_pixels;
			}
		}
}


/****************************************************************
*
* Die Anzahl der Spalten des Fensters werden berechnet.
* Die Anzahl der sichtbaren Zeilen des Fensters werden berechnet.
*
****************************************************************/

static void calc_collin(WINDOW *w)
{
	int x,y;
	int c;


	x = w->in.g_w - w->xoffs + w->xdist;
	y = w->in.g_h - w->yoffs + w->ydist;
	if	(w->is_1col)
		c = 1;
	else {
		c = x / (w->showw + w->xdist);
		if	(c < 1)
			c = 1;
		}
	w->cols = c;
	w->wlins = y / (w->showh + w->ydist);
	w->lins = (w->shownum + w->cols - 1) / w->cols;
	if	(w->step_hshift)
		{
		w->vissteps_hshift = (w->in.g_w - w->xoffs) / w->step_hshift;
		}
}


/****************************************************************
*
* Grîûe und Position des horizontalen Sliders werden
* berechnet.
*
****************************************************************/

void window_calc_hslider(WINDOW *w)
{
	long hsize,hpos;

	w->max_hshift = w->allsteps_hshift - w->vissteps_hshift;
	if	(w->max_hshift < 0)
		w->max_hshift = 0;

	if	(w->hshift < 0)
		w->hshift = 0;
	if	(w->hshift > w->max_hshift)
		w->hshift = w->max_hshift;

	if	(w->allsteps_hshift > 0)
		hsize = (1000L * w->vissteps_hshift) / w->allsteps_hshift;
	else hsize = 1000L;
	if	(hsize > 1000L)
		hsize = 1000L;
	wind_set(w->handle, WF_HSLSIZE, (int) hsize, 0,0,0);

	if	(w->max_hshift > 0)
		hpos = (1000L * w->hshift) / w->max_hshift;
	else hpos = 1L;
	if	(hpos > 1000L)
		hpos = 1000L;
	if	(hpos < 1)
		hpos = 1;
	wind_set(w->handle, WF_HSLIDE, (int) hpos, 0,0,0);
}


/****************************************************************
*
* Erledigt die horizontale Positionierung der Objekte und
* setzt die Sliderposition und -grîûe
*
****************************************************************/

static void arrange_window_horizontal( WINDOW *w )
{
	OBJECT *o;


	o 			= w->tree;

	calc_in(w);			/* Innenmaûe berechnen */
	w->vissteps_hshift = (w->in.g_w - w->xoffs) / w->step_hshift;

	window_calc_hslider(w);

	/* Position und Breite ggf. korrigieren (von calc_in schon gesetzt) */
	o -> ob_x 	= w->in.g_x - w->hshift * w->step_hshift;
	o -> ob_width  = w->in.g_w + w->hshift * w->step_hshift;
}


/****************************************************************
*
* Grîûe und Position des vertikalen Sliders werden
* berechnet.
*
****************************************************************/

void window_calc_vslider(WINDOW *w)
{
	long vsize,vpos;

	w->max_vshift = w->lins - w->wlins;
	if	(w->max_vshift < 0)
		w->max_vshift = 0;

	if	(w->vshift < 0)
		w->vshift = 0;
	if	(w->vshift > w->max_vshift)
		w->vshift = w->max_vshift;

	if	(w->lins > 0)
		vsize = (1000L * w->wlins) / w->lins;
	else vsize = 1000L;
	if	(vsize > 1000L)
		vsize = 1000L;
	wind_set(w->handle, WF_VSLSIZE, (int) vsize, 0,0,0);

	if	(w->max_vshift > 0)
		vpos = (1000L * w->vshift) / w->max_vshift;
	else vpos = 1L;
	if	(vpos > 1000L)
		vpos = 1000L;
	if	(vpos < 1)
		vpos = 1;
	wind_set(w->handle, WF_VSLIDE, (int) vpos, 0,0,0);
}


/****************************************************************
*
* Organisiert das Fenster neu, d.h. legt Position der Objekte fest.
* gibt TRUE zurÅck, falls sich fenster.cols oder fenster.shift
* geÑndert haben.
*
****************************************************************/

static int arrange_window( WINDOW *w )
{
	register int i,j;
	int x,y,cols;
	int oldcols;
	int old_hshift,old_vshift;
	int anzahl;
	OBJECT *o;
	ICONBLK *icb;


	oldcols 		= w->cols;
	old_hshift 	= w->hshift;
	old_vshift 	= w->vshift;
	anzahl 		= w->shownum;
	o 			= w->tree;

	calc_in(w);			/* Innenmaûe berechnen */
	calc_collin(w);		/* Zeilen/Spalten berechnen */
	cols = w->cols;

	window_calc_vslider(w);
	if	(w->step_hshift)
		{
		window_calc_hslider(w);
		o -> ob_x 	= w->in.g_x - w->hshift * w->step_hshift;
		o -> ob_width  = w->in.g_w + w->hshift * w->step_hshift;
		}

	/* Position und Hîhe ggf. korrigieren (von calc_in schon gesetzt) */
	o -> ob_y 	= w->in.g_y - w->vshift*(w->showh + w->ydist);
	o -> ob_height = w->in.g_h + w->vshift*(w->showh + w->ydist);
	for	(i = 0, y = w->yoffs, x = w->xoffs, j = anzahl;
			j > 0; i++,j--)
		{
		o++;

		if	(o -> ob_type == G_USERDEF)
			icb = (ICONBLK *) o->ob_spec.userblk->ub_parm;
		else
		if	((o -> ob_type == G_ICON) ||
			 (o -> ob_type == G_CICON))
			icb = o->ob_spec.iconblk;
		else icb = NULL;

		if	(i >= cols)
			{
			i = 0;
			x = w->xoffs;
			y += w->showh + w->ydist;
			}
		o -> ob_x = x;
		o -> ob_y = y;
		if	(icb)
			o -> ob_y += w->max_hicon - icb->ib_hicon;
		x += w->showw + w->xdist;
		}
	if	(anzahl < oldcols)
		oldcols = anzahl;
	if	(anzahl < cols)
		cols = anzahl;
	return((oldcols != cols) || (old_vshift != w->vshift) ||
		  (old_hshift != w->hshift));
}


/****************************************************************
*
* Das Fenster mit Nummer <wnr> wird auf Maximalgrîûe gebracht.
*
****************************************************************/

static void fulled(WINDOW *w)
{
	GRECT   prev, full;
	register GRECT *out;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	out = &(w->out);				/* out = Auûenmaûe */
	wind_get(w->handle, WF_PREVXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
	wind_get(w->handle, WF_FULLXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
 
	/* 1. Fall: Das Fenster hat bereits Maximalgrîûe	  */
	/*		  Also muû das Fenster verkleinert werden */
	/* ------------------------------------------------ */

	if	((out->g_x == full.g_x) && (out->g_y == full.g_y) &&
		 (out->g_w == full.g_w) && (out->g_h == full.g_h)) {
		graf_shrinkbox(&prev, &full);
		out->g_x = prev.g_x; out->g_y = prev.g_y;
		out->g_w = prev.g_w; out->g_h = prev.g_h;
		}

	/* 2. Fall: Das Fenster hat nicht Maximalgrîûe	  */
	/*		  Also Grîûe auf Maximum 			  */
	/* ------------------------------------------------ */

	else {
		graf_growbox(out, &full);
		out->g_x = full.g_x; out->g_y = full.g_y;
		out->g_w = full.g_w; out->g_h = full.g_h;
		}

	wind_set(w->handle,WF_CURRXYWH,out->g_x, out->g_y, out->g_w, out->g_h);
	if	(arrange_window(w))
		update_window(w);
}


/****************************************************************
*
* Der horizontale Scrollbalken von <w> ist auf die Position
* <newshift> zu bringen und der Redraw zu bewerkstelligen.
*
****************************************************************/

void hshift(WINDOW *w, int newshift)
{
	register int diff;		/* um soviele Spalten scrollen */
	register int xcopy;		/* soviele x-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT g;
	int clip_rect[4];



	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(newshift < 0)
		newshift = 0;
	else if	(newshift > w->max_hshift)
			newshift = w->max_hshift;

	if	(0 == (diff = newshift - w->hshift))
		return;

	w->hshift = newshift;
	arrange_window_horizontal(w);

	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	if	(abs(diff) > w->vissteps_hshift)
		{
		update_window(w);
		return;
		}

	/* Von Zeilen in Pixel umrechnen */
	/* diff > 0: Balken nach unten, Inhalt nach oben */

	diff *= w->step_hshift;

	/* Fenster Åber Rechteckliste scrollen */

	graf_mouse(M_OFF, NULL);
	wind_get_grect(w->handle,WF_FIRSTXYWH, &g);
	do	{
		if	(rc_intersect(&scrg, &g))
			{
			xcopy = g.g_w - abs(diff);		/* soviele Pixel blitten */
			if	(xcopy > 0)
				{
				pxy[1] = pxy[5] = g.g_y;
				pxy[3] = pxy[7] = g.g_y + g.g_h - 1;
				if	(diff > 0)
					{
					pxy[4] = g.g_x;
					pxy[0] = g.g_x + diff;
					}
				else {
					pxy[0] = g.g_x;
					pxy[4] = g.g_x - diff;
					}
				pxy[2] = pxy[0] + xcopy - 1;
				pxy[6] = pxy[4] + xcopy - 1;
				src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
				clip_rect[0] = scrg.g_x;
				clip_rect[1] = scrg.g_y;
				clip_rect[2] = scrg.g_x+scrg.g_w-1;
				clip_rect[3] = scrg.g_y+scrg.g_h-1;
				vs_clip	(vdi_handle, TRUE, clip_rect);
				vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
				/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
				g.g_w -= xcopy;
				if	(diff > 0)
					g.g_x += xcopy;
				}
			w->draw(w, &g);
			}
		wind_get(w->handle,WF_NEXTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */

	graf_mouse(M_ON, NULL);
}


/****************************************************************
*
* Der vertikale Scrollbalken von <w> ist auf die Position
* <newshift> zu bringen und der Redraw zu bewerkstelligen.
*
****************************************************************/

static void vshift(WINDOW *w, int newshift)
{
	register int diff;		/* um soviele Zeilen Scrollen */
	register int ycopy;		/* soviele y-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT g;
	int clip_rect[4];



	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(newshift < 0)
		newshift = 0;
	else if	(newshift > w->max_vshift)
			newshift = w->max_vshift;

	if	(0 == (diff = newshift - w->vshift))
		return;

	w->vshift = newshift;
	arrange_window(w);

	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	if	(abs(diff) > w->wlins)
		{
		update_window(w);
		return;
		}

	/* Von Zeilen in Pixel umrechnen */
	/* diff > 0: Balken nach unten, Inhalt nach oben */

	diff *= (w->showh + w->ydist);

	/* Fenster Åber Rechteckliste scrollen */

	graf_mouse(M_OFF, NULL);
	wind_get_grect(w->handle,WF_FIRSTXYWH, &g);
	do	{
		if	(rc_intersect(&scrg, &g))
			{
			ycopy = g.g_h - abs(diff);		/* soviele Pixel blitten */
			if	(ycopy > 0)
				{
				pxy[0] = pxy[4] = g.g_x;
				pxy[2] = pxy[6] = g.g_x + g.g_w - 1;
				if	(diff > 0)
					{
					pxy[5] = g.g_y;
					pxy[1] = g.g_y + diff;
					}
				else {
					pxy[1] = g.g_y;
					pxy[5] = g.g_y - diff;
					}
				pxy[3] = pxy[1] + ycopy - 1;
				pxy[7] = pxy[5] + ycopy - 1;
				src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
				clip_rect[0] = scrg.g_x;
				clip_rect[1] = scrg.g_y;
				clip_rect[2] = scrg.g_x+scrg.g_w-1;
				clip_rect[3] = scrg.g_y+scrg.g_h-1;
				vs_clip	(vdi_handle, TRUE, clip_rect);
				vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
				/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
				g.g_h -= ycopy;
				if	(diff > 0)
					g.g_y += ycopy;
				}
			w->draw(w, &g);
			}
		wind_get(w->handle,WF_NEXTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */

	graf_mouse(M_ON, NULL);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist einer der Scrollpfeile
* angeklickt worden.
* zusÑtzlich: Code -1 => Scrollbalken ganz nach oben
*		    Code -2 => Scrollbalken ganz nach unten
*
****************************************************************/

static void arrowed(WINDOW *w, int arrow)
{
	int	new_hshift,new_vshift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;

	new_hshift = w->hshift;
	new_vshift = w->vshift;

	switch(arrow)
		{
		case -1:			new_vshift  = 0;
						break;
		case -2:			new_vshift  = w->max_vshift;
						break;
		case -3:			new_hshift  = 0;
						break;
		case -4:			new_hshift  = w->max_hshift;
						break;
		case WA_UPPAGE:	new_vshift -= w->wlins;
						break;
		case WA_DNPAGE:	new_vshift += w->wlins;
						break;
		case WA_UPLINE:	new_vshift--;
						break;
		case WA_DNLINE:	new_vshift++;
						break;
		case WA_LFPAGE:	new_hshift -= w->vissteps_hshift;
						break;
		case WA_RTPAGE:	new_hshift += w->vissteps_hshift;
						break;
		case WA_LFLINE:	new_hshift--;
						break;
		case WA_RTLINE:	new_hshift++;
						break;
		default:			return;
		}
	w->set_vshift(w, new_vshift);
	w->set_hshift(w, new_hshift);
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist der horizontale Scrollbalken
* bewegt worden.
*
****************************************************************/

#pragma warn -par
static void dummy_hshift(WINDOW *w, int newshift)
{
}
static void iconified(WINDOW *w, GRECT *g)
{
}
static void uniconified(WINDOW *w, GRECT *g, int unhide)
{
}
static void alliconified(WINDOW *w, GRECT *g, int hide)
{
}
static void closed(WINDOW *w, int kstate)
{
}
static void buttoned( WINDOW *w, int kstate,
				int x, int y, int button, int nclicks )
{
}
static void keyed( WINDOW *w, int kstate, int key )
{
}
#pragma warn +par


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist der horizontale Scrollbalken
* bewegt worden.
*
****************************************************************/

static void hslid(WINDOW *w, int newpos)
{
	long newshift;


	if	(w->step_hshift)
		{
		if	(w->flags & WFLAG_ICONIFIED)
			return;
		newshift = (newpos * (w->max_hshift + 1L))/1000L;
		w->set_hshift(w, (int) newshift);
		}
}


/****************************************************************
*
* Im Fenster mit Handle <whdl> ist der vertikale Scrollbalken
* bewegt worden.
*
****************************************************************/

static void vslid(WINDOW *w, int newpos)
{
	long newshift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	newshift = (newpos * (w->max_vshift + 1L))/1000L;
	w->set_vshift(w, (int) newshift);
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> ist in seiner Grîûe
* verÑndert worden.
*
****************************************************************/

static void sized(WINDOW *w, GRECT *g)
{
	if	(w->flags & WFLAG_ICONIFIED)
		return;
	if	(wind_set(w->handle, WF_CURRXYWH, g->g_x, g->g_y, g->g_w, g->g_h))
		{
		w->out = *g;
		if	(arrange_window(w))
			update_window(w);
		}
}


/****************************************************************
*
* Das Fenster mit Handle <whdl> ist verschoben worden.
*
****************************************************************/

static void moved(WINDOW *w, GRECT *g)
{
	g->g_x &= ~7;
	if	(wind_set(w->handle, WF_CURRXYWH, g->g_x, g->g_y, g->g_w, g->g_h))
		{
		w->out = *g;
		calc_in(w);
		}
}


/****************************************************************
*
* Das Fenster wird geîffnet.
*
****************************************************************/

static void opened(WINDOW *w)
{
	wind_open(w->handle, &(w->out));
	arrange_window(w);
}


/***************************************************************/
/******************** DEFAULT-Routinen *************************/
/***************************************************************/

/****************************************************************
*
* Defaultroutine zum Zeichnen eines Fensters, dessen Inhalt
* AES- Objekte sind.
*
****************************************************************/

static void _draw_obj_window(WINDOW *w, GRECT *g)
{
	objc_draw(w->tree,0,1, g);
}


static void _message_obj_window(WINDOW *w, int kstate, int message[16])
{
	switch(message[0])
		{
		case WM_REDRAW:
			redraw_window(w, (GRECT *) (message+4));
			break;
		case WM_TOPPED:
			wind_set(w->handle, WF_TOP, 0,0,0,0);
			break;
		case WM_CLOSED:
			w->close(w, kstate);
			break;
		case WM_ALLICONIFY:
			w->alliconified(w, (GRECT *) (message+4), TRUE);
			break;
		case WM_ICONIFY:
			w->iconified(w, (GRECT *) (message+4));
			break;
		case WM_UNICONIFY:
			w->uniconified(w, (GRECT *) (message+4), FALSE);
			break;
		case WM_FULLED:
			w->fulled(w);
			break;
		case WM_ARROWED:
			w->arrowed(w, message[4]);
			break;
		case WM_HSLID:
			w->hslid(w, message[4]);
			break;
		case WM_VSLID:
			w->vslid(w, message[4]);
			break;
		case WM_SIZED:
			w->sized(w, (GRECT *) (message+4));
			break;
		case WM_MOVED:
			w->moved(w, (GRECT *) (message+4));
			break;
		}
}


/****************************************************************
*
* Das Fenster wird mit Default-Funktionen initialisiert.
* Da der PureC- Linker "intelligent" ist, wird hier nur die
* Dummy-Funktion fÅr den horizontalen Slider eingetragen.
*
* Wenn das Programm den horizontalen Slider braucht, muû es
* einfach w->hslid = hslid setzen.
*
****************************************************************/

void	init_window( WINDOW *w)
{
	w->close = closed;
	w->open = opened;
	w->message = _message_obj_window;
	w->draw = _draw_obj_window;
	w->moved = moved;
	w->fulled = fulled;
	w->arrowed = arrowed;
	w->sized = sized;

	w->is_1col = TRUE;
	w->vslid = vslid;
	w->hslid = hslid;
	w->set_vshift = vshift;

	w->step_hshift = 0;		/* kein horiz. Slider ! */
	w->hshift = 0;
	w->set_hshift = dummy_hshift;

	w->iconified = iconified;
	w->uniconified = uniconified;
	w->alliconified = alliconified;
	w->key = keyed;
	w->button = buttoned;
	w->usertype = 0L;
	w->userdata = NULL;
}
