/*
*
* EnthÑlt die allgemeinen Routinen fÅr die
* Fensterverwaltung
*
*/

#include <portab.h>
#include <stdlib.h>
#include <stddef.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "gemut_mt.h"
#include "windows.h"

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
* Malt das Fenster mit Nummer <wnr> im Bereich
* neu_x,neu_y,neu_b,neu_h  nach.
*
****************************************************************/

void redraw_window(WINDOW *w, GRECT *neu)
{
	GRECT g;


	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);
	wind_get(w->handle,WF_FIRSTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
	do	{
		if	(rc_intersect(neu,&g))
			w->draw(w, &g);
		wind_get(w->handle,WF_NEXTXYWH,&(g.g_x),&(g.g_y),&(g.g_w),&(g.g_h));
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */
	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);
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
* Grîûe und Position eines Sliders werden berechnet.
*
****************************************************************/

void window_calc_slider(WINDOW *w, int is_horiz)
{
	WINDSCROLLINFO *wsi;
	long size,pos;


	wsi = (is_horiz) ? &(w->hscroll) : &(w->vscroll);
	wsi->maxshift = wsi->n - wsi->nvis;
	if	(wsi->maxshift < 0)
		wsi->maxshift = 0;

	if	(wsi->shift < 0)
		wsi->shift = 0;
	if	(wsi->shift > wsi->maxshift)
		wsi->shift = wsi->maxshift;

	if	(wsi->n > 0)
		size = (1000L * wsi->nvis) / wsi->n;
	else size = 1000L;
	if	(size > 1000L)
		size = 1000L;
	wind_set(w->handle, (is_horiz) ? WF_HSLSIZE : WF_VSLSIZE,
			(int) size, 0, 0, 0);

	if	(wsi->maxshift > 0)
		pos = (1000L * wsi->shift) / wsi->maxshift;
	else pos = 1L;
	if	(pos > 1000L)
		pos = 1000L;
	if	(pos < 1)
		pos = 1;
	wind_set(w->handle, (is_horiz) ? WF_HSLIDE : WF_VSLIDE,
			(int) pos, 0, 0, 0);
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
	GRECT *newg;


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
		graf_shrinkbox_grect(&prev, &full);
		newg = &prev;
		}

	/* 2. Fall: Das Fenster hat nicht Maximalgrîûe	  */
	/*		  Also Grîûe auf Maximum 			  */
	/* ------------------------------------------------ */

	else {
		graf_growbox_grect(out, &full);
		newg = &full;
		}

	w->sized(w, newg);
}


static void _message_obj_window(WINDOW *w, int kstate, int message[16])
{
	switch(message[0])
		{
		case WM_REDRAW:
			redraw_window(w, (GRECT *) (message+4));
			break;
		case WM_TOPPED:
			wind_set(w->handle, WF_TOP, 0, 0, 0, 0);
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

#pragma warn -par
static void scrl_arrange(struct _window *w, int is_horiz)
{
	window_calc_slider(w, is_horiz);
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
static void draw (WINDOW *w, GRECT *g)
{
}
static void snap (WINDOW *w)
{
}
static void moved(WINDOW *w, GRECT *g)
{
	w->out = *g;
	if	(!(w->flags & WFLAG_ICONIFIED))
		w->snap(w);
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
}
#pragma warn +par

static void opened(WINDOW *w)
{
	w->snap(w);
	wind_open_grect(w->handle, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	w->arrange(w);
}
static void sized(WINDOW *w, GRECT *g)
{
	if	(w->flags & WFLAG_ICONIFIED)
		return;
	w->out = *g;
	w->snap(w);
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	if	(w->arrange(w))
		update_window(w);
}
static void slid(WINDOW *w, int newpos, int is_horiz)
{
	long newshift;
	WINDSCROLLINFO *wsi;


	if	(w->flags & WFLAG_ICONIFIED)
		return;
	wsi = (is_horiz) ? &(w->hscroll) : &(w->vscroll);
	newshift = (newpos * (wsi->maxshift + 1L))/1000L;
	wsi->set_shift(w, (int) newshift, is_horiz);
}
static void hslid(WINDOW *w, int newpos)
{
	slid(w,newpos,TRUE);
}
static void vslid(WINDOW *w, int newpos)
{
	slid(w,newpos,FALSE);
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
	WINDSCROLLINFO *wsi;
	int is_horiz;
	long new_shift;


	if	(w->flags & WFLAG_ICONIFIED)
		return;

	is_horiz = (arrow == -3) ||
			 (arrow == -4) ||
			 (arrow == WA_LFPAGE) ||
			 (arrow == WA_RTPAGE) ||
			 (arrow == WA_LFLINE) ||
			 (arrow == WA_RTLINE);

	wsi = (is_horiz) ? &(w->hscroll) : &(w->vscroll);
	new_shift = wsi->shift;

	switch(arrow)
		{
		case -1:
		case -3:			new_shift  = 0;
						break;
		case -2:
		case -4:			new_shift  = wsi->maxshift;
						break;
		case WA_UPPAGE:
		case WA_LFPAGE:	new_shift -= wsi->nvis;
						break;
		case WA_DNPAGE:
		case WA_RTPAGE:	new_shift += wsi->nvis;
						break;
		case WA_UPLINE:
		case WA_LFLINE:	new_shift--;
						break;
		case WA_DNLINE:
		case WA_RTLINE:	new_shift++;
						break;
		default:			return;
		}
	wsi->set_shift(w, new_shift, is_horiz);
}


/****************************************************************
*
* Ein Scrollbalken von <w> ist auf die Position
* <newshift> zu bringen und der Redraw zu bewerkstelligen.
*
****************************************************************/

void set_shift(WINDOW *w, long newshift, int is_horiz)
{
	WINDSCROLLINFO *wsi;
	register long diff;		/* um soviele Spalten scrollen */
	long absdiff;
	register int xcopy,ycopy;		/* soviele x-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT g;
	int clip_rect[4];



	if	(w->flags & WFLAG_ICONIFIED)
		return;

	wsi = (is_horiz) ? &(w->hscroll) : &(w->vscroll);
	if	(newshift < 0)
		newshift = 0;
	else if	(newshift > wsi->maxshift)
			newshift = wsi->maxshift;

	if	(0 == (diff = newshift - wsi->shift))
		return;		/* nix zu scrollen */

	wsi->shift = newshift;
	wsi->arrange(w, is_horiz);		/* Slider anzeigen,
							ggf. Objektpos. umsetzen */

	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	absdiff = (diff > 0) ? diff : -diff;
	if	(absdiff > wsi->nvis)
		{
		update_window(w);
		return;
		}

	/* Von Zeilen/Spalten in Pixel umrechnen */
	/* diff > 0: Balken nach unten/rechts, Inhalt nach oben/links */

	diff *= wsi->pixelsize;
	absdiff *= wsi->pixelsize;

	/* Fenster Åber Rechteckliste scrollen */

	graf_mouse(M_OFF, NULL);
	wind_get_grect(w->handle,WF_FIRSTXYWH,&g);
	do	{
		if	(rc_intersect(&scrg, &g))
			{
			if	(is_horiz)
				{
				xcopy = g.g_w - (int) absdiff;		/* soviele Pixel blitten */
				if	(xcopy > 0)
					{
					pxy[1] = pxy[5] = g.g_y;
					pxy[3] = pxy[7] = g.g_y + g.g_h - 1;
					if	(diff > 0)
						{
						pxy[4] = g.g_x;
						pxy[0] = g.g_x + (int) diff;
						}
					else {
						pxy[0] = g.g_x;
						pxy[4] = g.g_x - (int) diff;
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
				}
			else	{
				ycopy = g.g_h - (int) absdiff;		/* soviele Pixel blitten */
				if	(ycopy > 0)
					{
					pxy[0] = pxy[4] = g.g_x;
					pxy[2] = pxy[6] = g.g_x + g.g_w - 1;
					if	(diff > 0)
						{
						pxy[5] = g.g_y;
						pxy[1] = g.g_y + (int) diff;
						}
					else {
						pxy[1] = g.g_y;
						pxy[5] = g.g_y - (int) diff;
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
				}
			w->draw(w, &g);
			}
		wind_get_grect(w->handle,WF_NEXTXYWH,&g);
		}
	while(g.g_w > 0);					/* bis Rechteckliste vollstÑndig */

	graf_mouse(M_ON, NULL);
}


void	init_window( WINDOW *w)
{
	w->close = closed;
	w->snap = snap;
	w->open = opened;
	w->message = _message_obj_window;
	w->draw = draw;
	w->moved = moved;
	w->fulled = fulled;
	w->arrowed = arrowed;
	w->sized = sized;

	w->vslid = vslid;
	w->hslid = hslid;
	w->hscroll.shift = w->vscroll.shift = 0;	/* Anfangs-Pos */
	w->hscroll.nvis  = w->vscroll.nvis = 0;		/* nix da */

	w->hscroll.set_shift = set_shift;
	w->hscroll.arrange = scrl_arrange;

	w->vscroll.arrange = scrl_arrange;
	w->vscroll.set_shift = set_shift;

	w->iconified = iconified;
	w->uniconified = uniconified;
	w->alliconified = alliconified;
	w->key = keyed;
	w->button = buttoned;
	w->flags = 0;
}
