/*
*
* EnthÑlt die Routinen fÅr die Editorfenster
*
*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include <stdlib.h>
#include "gemut_mt.h"
#include "globals.h"
#include "mgedit.h"
#include "toserror.h"
#include <mint/dcntl.h>

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
* îffnet ein neues Fenster.
* Wenn <path> == NULL ist, wird ein leeres Dokument erzeugt.
*
****************************************************************/

void close_window( WINDOW *w )
{
	WINDOW **pw;

	pw = find_slot_window(w);
	if	(pw)
		{
		edit_close(&w->tree, EDITFELD);
		edit_delete( w->xedit );
		Mfree(w->buf);
		wind_close(w->handle);
		wind_delete(w->handle);
		Mfree(w);
		*pw = NULL;
		}
}


/****************************************************************
*
* îffnet ein neues Fenster.
* Wenn <path> == NULL ist, wird ein leeres Dokument erzeugt.
*
****************************************************************/

WINDOW *open_new_window( char *path )
{
	WINDOW *w = NULL;
	WINDOW **pw;
	int file = 0;
	int success = FALSE;
	long ret = E_OK;
	XATTR xa;
	int wnr;


	pw = new_window();
	if	(!pw)
		{
		ret = ENSMEM;
		goto fehler;
		}

	wnr = (int) (pw-windows);
	w = Malloc(sizeof(WINDOW));
	if	(!w)
		{
		ret = ENSMEM;
		goto fehler;
		}

	w->buf = NULL;

	w->out.g_x = -1 + wnr * 8;
	w->out.g_y = scrg.g_y + wnr * 8;
	w->out.g_w = 640;
	w->out.g_h = scrg.g_h-16;

	w->handle = wind_create_grect(EDITOR_W_KIND, &scrg);
	if	(w->handle < 0)
		{
		ret = ENSMEM;
		goto fehler;
		}

	/* Allgemeine Einstellungen */
	/* ------------------------ */

	w->dirty = FALSE;
	w->save_active = FALSE;
	w->flags = 0;
	w->fontID = prefs.fontID;
	w->fontH = prefs.fontH;
	w->fontprop = prefs.fontprop;
	w->tcolour = prefs.tcolour;
	w->bcolour = prefs.bcolour;
	w->tabwidth = prefs.tabwidth;

	/* ggf. DateilÑnge ermitteln */
	/* ------------------------- */

	if	(path)
		{
		strcpy(w->path, path);
		strcpy(w->title, path);
		ret = Fopen(path, O_RDONLY);
		if	(ret < 0)
			goto fehler;

		file = (int) ret;

		ret = Fcntl(file, (long) (&xa), FSTAT);
		if	(ret < 0)
			goto fehler;
		}
	else	{
		w->path[0] = '\0';
		strcpy(w->title, Rgetstring(STR_NONAME, NULL));
		itoa(wnr+1, w->title+strlen(w->title), 10);
		xa.st_size = 0L;
		}

	w->bufsize = xa.st_size + prefs.bufsize;
	w->buf = Malloc(w->bufsize);
	if	(!w->buf)
		{
		ret = ENSMEM;
		goto fehler;
		}

	if	(file)
		{
		ret = Fread(file, xa.st_size, w->buf);
		Fclose(file);
		file = 0;
		if	(ret != xa.st_size)
			{
			ret = ERROR;
			goto fehler;
			}
		}

	w->buf[xa.st_size] = '\0';

	w->xedit = edit_create();
	if	(!w->xedit)
		{
		ret = ENSMEM;
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
	edit_set_color( &w->tree, EDITFELD,
				w->tcolour, w->bcolour);
	edit_set_format( &w->tree, EDITFELD,
				w->tabwidth, FALSE);
	wind_set_str(w->handle, WF_NAME, w->title);
	success = TRUE;


	fehler:
	if	(!success)
		{
		if	(w)
			{
			if	(w->handle > 0)
				wind_delete(w->handle);
			if	(w->buf)
				Mfree(w->buf);
			Mfree(w);
			}
		if	(file)
			Fclose(file);
		form_xerr(ret, path);
		}
	else	{
		*pw = w;
		wind_open_grect(w->handle, &(w->out));
		wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
		*((GRECT *) &(w->tree.ob_x)) = w->in;
		edit_open( &w->tree, EDITFELD );
		w->nlines = w->yscroll = w->xscroll = w->ncols = -1L;
		window_set_slider(w);
		}
	return(w);
}


/****************************************************************
*
* Zeichnet das Fenster <w> neu.
*
****************************************************************/

int update_window(WINDOW *w, GRECT *g)
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
	mesag.msg.g		= (g) ? *g : w->out;
	return(appl_write(ap_id, 16, mesag.message));
}


/****************************************************************
*
* Fenster <w> in Grîûe und/oder Position Ñndern
*
****************************************************************/

static void change_g(WINDOW *w, GRECT *g, int resized)
{
	WORD oldrh,newrh;
	GRECT rg;

	if	(w->flags & WFLAG_ICONIFIED)
		return;
	w->out = *g;
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	*((GRECT *) &(w->tree.ob_x)) = w->in;
	if	(resized)
		{
		edit_resized(&w->tree, EDITFELD, &oldrh, &newrh);

		/* weiûen Rand nachbessern */
		/* ----------------------- */

		if	(newrh != oldrh)
			{
			if	(newrh < oldrh)
				oldrh = newrh;
			rg.g_x = w->tree.ob_x;
			rg.g_y = w->tree.ob_y + oldrh;
			rg.g_w = w->tree.ob_width;
			rg.g_h = w->tree.ob_height - oldrh;
			if	((rg.g_h > 0) && (rg.g_w > 0))
				{
				objc_wdraw(&w->tree,0,0, &rg,	w->handle);
				/*
				update_window(w, &rg);
				*/
				}
			}
		window_set_slider(w);
		}
}


/****************************************************************
*
* Das Fenster <w> wird auf Maximalgrîûe gebracht.
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

	change_g(w, newg, TRUE);
}


/****************************************************************
*
* Fensternachricht verarbeiten
*
****************************************************************/

#pragma warn -par
void window_message(WINDOW *w, int kstate, int message[16])
{
	EVNT w_ev;
	int key = 0;
	long line;
	long ldummy;
	WORD dummy;
	WORD yvis,xvis;
	LONG h_offs;
	LONG err;


	switch(message[0])
		{
		case WM_REDRAW:
			objc_wdraw(&w->tree,0,0,(GRECT *) (message+4),
					w->handle);
			break;
		case WM_TOPPED:
			wind_set_int(w->handle, WF_TOP, 0);
			break;
		case WM_CLOSED:
			if	(w->save_active)
				Bconout(2,7);
			else	close_file(w);
			break;
		case WM_ALLICONIFY:
			break;
		case WM_ICONIFY:
			break;
		case WM_UNICONIFY:
			break;
		case WM_FULLED:
			fulled(w);
			break;
		case WM_ARROWED:

			switch(message[4])
				{
				case WA_LFLINE:
					h_offs = -8;
					goto hscroll;
				case WA_RTLINE:
					h_offs = 8;
					goto hscroll;
				case WA_LFPAGE:
					h_offs = -w->xvis;
					goto hscroll;
				case WA_RTPAGE:
					h_offs = w->xvis;
					hscroll:
					h_offs += w->xscroll;
					if	(h_offs >= w->ncols)
						h_offs = w->ncols - 1;
					if	(h_offs < 0)
						h_offs = 0;
					if	(w->xscroll != h_offs)
						{
						if	(edit_scroll( &w->tree, EDITFELD, w->handle, -1L, (WORD) h_offs ))
							window_set_slider(w);
						}
					break;

				case WA_UPLINE:
					key = 0x4800;
					w_ev.kstate = K_CTRL;
					break;
				case WA_DNLINE:
					key = 0x5000;
					w_ev.kstate = K_CTRL;
					break;
				case WA_UPPAGE:
					key = 0x4900;
					w_ev.kstate = K_LSHIFT;
					break;
				case WA_DNPAGE:
					key = 0x5100;
					w_ev.kstate = K_RSHIFT;
					break;
				default: key = 0;
					break;
				}

			if	(key)
				{
				w_ev.mwhich = MU_KEYBD;
				w_ev.key = key;
				edit_evnt( &w->tree, EDITFELD, w->handle, &w_ev, &err );
				window_set_slider(w);
				}
			break;

		case WM_HSLID:
			edit_get_scrollinfo(&w->tree, EDITFELD,
				&ldummy, &ldummy, &dummy, &dummy,
				&dummy, &dummy, &xvis);

			line = (message[4] * (w->ncols - xvis + 1L))/1000L;
			if	(edit_scroll( &w->tree, EDITFELD, w->handle, -1L, (WORD) line ))
				window_set_slider(w);
			break;

		case WM_VSLID:

			edit_get_scrollinfo(&w->tree, EDITFELD,
				&ldummy, &ldummy, &yvis, &dummy,
				&dummy, &dummy, &dummy);

			line = (message[4] * (w->nlines - yvis + 1L))/1000L;
			if	(edit_scroll( &w->tree, EDITFELD, w->handle, line, -1 ))
				window_set_slider(w);
			break;
		case WM_SIZED:
			change_g(w, ((GRECT *) (message+4)), TRUE);
			break;
		case WM_MOVED:
			change_g(w, ((GRECT *) (message+4)), FALSE);
			break;
		case WM_SHADED:
			w->flags |= WFLAG_SHADED;
			break;
		case WM_UNSHADED:
			w->flags &= ~WFLAG_SHADED;
			break;
		}
}
#pragma warn +par


/****************************************************************
*
* Fenster-Slider ggf. Ñndern
*
****************************************************************/

#pragma warn -par
void window_set_slider(WINDOW *w)
{
	LONG nlines,yscroll;
	WORD ncols,xscroll;
	WORD yvis,yval,xvis;
	LONG size;


	edit_get_scrollinfo(&w->tree, EDITFELD,
				&nlines, &yscroll, &yvis, &yval,
				&ncols, &xscroll, &xvis);

	if	(ncols < 0)
		ncols = 256*8;			/* Textbreite erraten */

	if	((w->nlines != nlines) || (w->yvis != yvis))
		{
		w->nlines = nlines;
		w->yvis = yvis;
		if	(nlines)
			{
			size = yval;
			size *= 1000;
			size /= nlines;
			}
		else	size = 1000;
		wind_set_int(w->handle, WF_VSLSIZE, (int) size);
		}
	if	(w->yscroll != yscroll)
		{
		w->yscroll = yscroll;
		if	(nlines)
			{
			nlines -= yval;
			yscroll *= 1000;
			yscroll /= nlines;
			}
		else	yscroll = 1;
		wind_set_int(w->handle, WF_VSLIDE, (int) yscroll);
		}
	if	((w->ncols != ncols) || (w->xvis != xvis))
		{
		w->ncols = ncols;
		w->xvis = xvis;
		if	(ncols)
			{
			size = xvis;
			size *= 1000;
			size /= ncols;
			}
		else	size = 1000;
		wind_set_int(w->handle, WF_HSLSIZE, (int) size);
		}
	if	(w->xscroll != xscroll)
		{
		w->xscroll = xscroll;
		if	(ncols)
			{
			ncols -= xvis;
			size = xscroll;
			size *= 1000;
			size /= ncols;
			}
		else	size = 1;
		wind_set_int(w->handle, WF_HSLIDE, (int) size);
		}
}
