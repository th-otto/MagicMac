/*
*
* EnthÑlt die spezifischen Routinen fÅr die
* Notizfenster
*
*/

#include <tos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <tosdefs.h>
#include <string.h>
#include <stdlib.h>
/* #include <stdio.h> */
#include <magx.h>
#include "gemut_mt.h"
#include "portab.h"
#include "windows.h"
#include "globals.h"

WINDOW *selected_window = NULL;

/*******************************************************************
*
* Taste
*
*******************************************************************/

#pragma warn -par
static void key_fnames( WINDOW *w, int kstate, int key )
{
/*
	if	((key == 0x1011) ||		/* ^Q */
		 (key == 0x1615))		/* ^U */
		exit_immed = TRUE;
*/
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
		update_window(w);
		selected_window = w;

		/* ggf. andere Fenster deselektieren */
		/* --------------------------------- */

		for	(i = 0; i < NWINDOWS; i++)
			if	((windows[i]) &&
				 (windows[i] != w) &&
				 (windows[i]->selected))
				{
				windows[i]->selected = FALSE;
				update_window(windows[i]);
				}
		}
}


/*******************************************************************
*
* Mausklick
*
*******************************************************************/

static void button_notice_wind( WINDOW *w, int kstate,
				int x, int y, int button, int nclicks )
{
	EVNTDATA ev;


	if	(nclicks > 1)
		{
		create_notice(w);
		return;
		}

	graf_mkstate(&ev);

	if	(ev.bstate)	/* Maustaste noch gedrÅckt */
		{
		graf_dragbox(w->out.g_w, w->out.g_h,
					w->out.g_x, w->out.g_y,
					&scrg,
					&w->out.g_x, &w->out.g_y);
		w->moved(w, &w->out);
		return;
		}

	/* Klick auf Hintergrundfenster.					*/
	/* Weil WF_BEVENT gesetzt ist, wird das Fenster nicht	*/
	/* vom System nach oben gebracht. Dies muû daher		*/
	/* manuell erfolgen. Hier nur bei kurzem Einfachklick	*/
	/* mit nur der linken Maustaste und ohne			*/
	/* Umschalttasten!								*/
	/* --------------------------------------------------- */

	if	((nclicks == 1) && (button == 1) && (!kstate))
		{
		if	(!ev.bstate)	/* wieder losgelassen! */
			{
			wind_set(w->handle, WF_TOP, 0, 0, 0, 0);
			wind_set(0, WF_TOPALL, ap_id, 0,0,0);
			/*
			top_all_my_windows();
			*/

			/* Fenster selektieren */
			/* ------------------- */

			if	(!w->selected)
				{
				select_window(w);
				}

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
	if	(!(w->flags & WFLAG_ICONIFIED))
		w->snap(w);
	wind_set_grect(w->handle, WF_CURRXYWH, &(w->out));
	wind_get_grect(w->handle, WF_WORKXYWH, &(w->in));
	w->position_dirty = TRUE;	/* Position ist geÑndert */
}


/*******************************************************************
*
* Schlieûen
*
*******************************************************************/

#pragma warn -par
static void close_fnames( WINDOW *w, int kstate )
{
/*
	WINDOW **sw;

	wind_close(w->handle);
	wind_delete(w->handle);
	Mfree(w->tree);
	sw = find_slot_window(w);
	mywindow = NULL;
	*sw = NULL;

	exit_immed = TRUE;
*/
}
#pragma warn +par



/*****************************************************************
*
* Expandiert eine Zeile mit Tabulatoren. Die ZeilenlÑnge
* im Text ist <len>, ohne crlf.
* Die neue ZeilenlÑnge wird zurÅckgegeben.
* Ist die Zeile zu breit, wird abgebrochen.
* Ist <tabsize> = 0, werden Tabs wîrtlich angezeigt (als Kuller)
* Ist <buf> = NULL, wird nix kopiert.
*
*****************************************************************/

static long expand_line( unsigned char *text, long len, int tabsize,
					unsigned char *buf, long bufsize )
{
	unsigned char *end = text+len;
	long newlen;
	int ntabs;


	newlen = 0L;
	while((text < end) && (bufsize))
		{
			/* Tab expandieren */
		if	((*text == '\t') && (tabsize))
			{
			ntabs = (int) (tabsize - (newlen % tabsize));
			if	(!ntabs)
				ntabs += tabsize;
			while(ntabs && bufsize)
				{
				if	(buf)
					{
					*buf++ = ' ';
					bufsize--;
					}
				newlen++;
				ntabs--;
				}
			}
			/* normal: ein Zeichen kopieren */
		else	{
			if	(buf)
				{
				if	(*text)
					*buf++ = *text;
				else	*buf++ = ' ';		/* Nullbyte! */
				bufsize--;
				}
			newlen++;
			}
		text++;
		}
	return(newlen);
}


/*****************************************************************
*
* Ermittelt die Anzahl der Zeilen und die maximale
* Spaltenbreite in einem Text.
* Dabei wird nur '\n' berÅcksichtigt, damit man mit UNIX-
* Textdateien keine Probleme hat.
* D.h. Zeilen kînnen beendet werden durch:
*
*	$d$a
*	$a
*	EOF
*
*
* Eingabe:	text		Zeiger auf die Daten
*			len		LÑnge der Daten
*			tabsize	Tabulatorbreite
*			fontW	Zeichenbreite oder -1 (proportional)
*
* Ausgabe:	lc		Anzahl Zeilen
*			cc		Maximale Anzahl Spalten
*			pc		Maximale Pixelbreite
*
*****************************************************************/

static void get_line_column_count(
				unsigned char *text,
				long len,
				int tabsize,
				int fontW,
				long *lc, long *cc, long *pc)
{
	unsigned char *ende = text+len;
	unsigned char *eol,*eol2;
	unsigned char buf[MAXWIDTH+2];
	int out[8];
	long w;			/* LÑnge einer Zeile (in Zeichen) */



	*lc = *cc = *pc = 0;
	while(text < ende)
		{
		(*lc)++;		/* hier beginnt eine Zeile! */
		eol = memchr(text, '\n', ende-text);

		/* Letzte Zeile: */

		if	(!eol)
			eol = eol2 = ende;

		/* noch nicht letzte Zeile */

		else	{
			if	((eol > text) && (eol[-1] == '\r'))
				eol2 = eol-1;		/* '\r' ignorieren */
			else	eol2 = eol;
			}

		/*	w = eol2 - text;	ohne TABs */

		w = expand_line( text, eol2-text, tabsize,
						(fontW < 0) ? buf : NULL,
						MAXWIDTH );
		if	(w > MAXWIDTH)
			w = MAXWIDTH;

		if	(w > *cc)
			*cc = w;

		if	(fontW < 0)
			{
			buf[w] = EOS;
			vqt_extent(vdi_handle, (char *) buf, out);
			w = out[2] - out[0] + 1;
/*
			printf("vqt_extent(%s) = %d\n", buf, (int) w);
*/
			}
		else	w *= fontW;

		if	(w > *pc)		/* maximale Breite in Pixeln */
			*pc = w;

		text = eol+1;		/* aufs nÑchste Zeichen */
		}
}


/****************************************************************
*
* éndert die Objektkoordinaten von w->out so, daû sie in
* bestimmte Raster einrasten.
* Hier:	Innen-GRECT muû ganzzahliges Vielfaches der Zeichengrîûe
*		sein.
*
****************************************************************/
/*
static void snap_notice_wind( WINDOW *w )
{
	/* Innenbereich berechnen */
	wind_calc(WC_WORK, NOTICE_W_KIND, &(w->out), &(w->in));
	/* x-Position auf 8er-Grenze */
	w->in.g_x &= ~7;
	/* Minimalgrîûe */
	if	(w->in.g_w < 8*w->user_charW)
		w->in.g_w = 8*w->user_charW;
	if	(w->in.g_h < w->user_charH + MOVER_HEIGHT)
		w->in.g_h = w->user_charH + MOVER_HEIGHT;
	/* Breite und Hîhe */
	w->in.g_w -= w->in.g_w % w->hscroll.pixelsize;
	w->in.g_h -= (w->in.g_h - MOVER_HEIGHT) % w->vscroll.pixelsize;
	/* nochmal Auûenbereich berechnen */
	wind_calc(WC_BORDER, NOTICE_W_KIND, &(w->in), &(w->out));
}
*/


/****************************************************************
*
* Organisiert das Fenster neu, d.h. legt Position der Objekte fest.
* gibt TRUE zurÅck, falls sich fenster.cols oder fenster.shift
* geÑndert haben.
*
****************************************************************/

static int arrange_notice_wind( WINDOW *w )
{
	long old_hshift,old_vshift;


	old_hshift 	= w->hscroll.shift;
	old_vshift 	= w->vscroll.shift;

	w->hscroll.nvis = w->in.g_w / (w->hscroll.pixelsize);
	w->vscroll.nvis = w->in.g_h / (w->vscroll.pixelsize);

	if	(w->vscroll.n >= 0)
		window_calc_slider(w, FALSE);
	if	(w->hscroll.n >= 0)
		window_calc_slider(w, TRUE);

	return((old_vshift != w->vscroll.shift) ||
		  (old_hshift != w->hscroll.shift));
}


/*****************************************************************
*
* Ermittelt einen Zeiger auf die <n>-te Zeile des Textes.
* Gibt die LÑnge dieser Zeile (ohne CRLF bzw. LF) zurÅck.
*
*****************************************************************/

unsigned char *get_line(unsigned char *text,
						long n, long *lw )
{
	long len = strlen((char *) text);
	unsigned char *ende = text+len;
	unsigned char *eol;


	while(n)
		{
		text = memchr(text, '\n', ende-text);
		if	(!text)
			{
			*lw = 0;
			return(NULL);
			}
		text++;
		n--;
		}

	eol = memchr(text, '\n', ende-text);

	/* Letzte Zeile: */

	if	(!eol)
		eol = ende;

	/* noch nicht letzte Zeile */

	else	{
		if	((eol > text) && (eol[-1] == '\r'))
			eol--;		/* '\r' ignorieren */
		}

	*lw = eol - text;
	return(text);
}


/****************************************************************
*
* Routine zum Zeichnen eines Textfensters.
*
****************************************************************/

static void draw_notice_wind(WINDOW *w, GRECT *g)
{
	unsigned char *line;
	int i,dummy;
	long l;
	long lw;
	int x,y;
	int pxy[4];
	unsigned char textbuf[MAXWIDTH+1];
	static int last_bcolour = WHITE;
	static int last_tcolour = BLACK;
	int tcolour;


	/* Text- und Hintergrundfarbe festlegen */

	tcolour = (w->user_bcolour < ncolours) ? w->user_tcolour : WHITE;

	pxy[0] = g->g_x;
	pxy[1] = g->g_y;
	pxy[2] = g->g_x + g->g_w - 1;
	pxy[3] = g->g_y + g->g_h - 1;
	vs_clip(vdi_handle, TRUE, pxy);

	/* Mover */

	pxy[0] = w->in.g_x;
	pxy[1] = w->in.g_y;
	pxy[2] = w->in.g_x + w->in.g_w - 1;
	pxy[3] = w->in.g_y + MOVER_HEIGHT - 1;
	last_bcolour = (w->selected) ? MOVER_COLOUR : WHITE;
	vsf_color(vdi_handle, last_bcolour);
	vr_recfl(vdi_handle, pxy);

	/* Zeichensatz festlegen */

	vst_font(vdi_handle, w->user_fontID);
	vst_point(vdi_handle, w->user_fontH,
			&dummy, &dummy,
			&dummy, &dummy);

	/* FÅr jede sichtbare Zeile */

	x = w->in.g_x - (int) (w->hscroll.shift*w->hscroll.pixelsize);
	y = w->in.g_y + MOVER_HEIGHT;
	l = w->vscroll.shift;

	for	(i = 0; i < w->vscroll.nvis; i++)
		{
		if	((y+w->vscroll.pixelsize > g->g_y) &&
			 (y < g->g_y+g->g_h))
			{
			line = get_line(w->user_file, l, &lw);

			/* TABs expandieren */

			if	(line)
				lw = expand_line( line, lw, 8,
								textbuf, MAXWIDTH );

			/* Wenn der Hintergrund nicht weiû ist, muû erst	*/
			/* ein farbiges Rechteck ausgegeben werden.		*/
			/* Das machen wir auch bei proportionalem		*/
			/* Zeichensatz.							*/
			/* ---------------------------------------------- */

			if	((w->user_fontprop) || (w->user_bcolour != WHITE))
				{
				if	(x < w->in.g_x+w->in.g_w)
					{
					if	(last_bcolour != w->user_bcolour)
						{
						vsf_color(vdi_handle, w->user_bcolour);
						last_bcolour = w->user_bcolour;
						}
					pxy[0] = x;
					pxy[1] = y;
					pxy[2] = w->in.g_x + w->in.g_w - 1;
					pxy[3] = y + w->vscroll.pixelsize - 1;
					vr_recfl(vdi_handle, pxy);
					}

				/* Jetzt der Text */

				if	(line)
					{
					textbuf[lw] = '\0';
					if	(last_tcolour != tcolour)
						{
						vst_color(vdi_handle, tcolour);
						last_tcolour = tcolour;
						}
					vswr_mode(vdi_handle, MD_TRANS);
					v_gtext(vdi_handle, x, y, (char *) textbuf);
					vswr_mode(vdi_handle, MD_REPLACE);
					}
				}

			/* sonst: erst den Text ausgeben */
			/* ----------------------------- */

			else	{
				if	(line)
					{
					textbuf[lw] = '\0';
					if	(last_tcolour != tcolour)
						{
						vst_color(vdi_handle, tcolour);
						last_tcolour = tcolour;
						}
					v_gtext(vdi_handle, x, y, (char *) textbuf);
					}

				lw *= w->hscroll.pixelsize;	/* ausgegebene Pixel */

				/* dann ein (weiûes) Rechteck dahinter */

				if	(x+lw < w->in.g_x+w->in.g_w)
					{
					if	(last_bcolour != w->user_bcolour)
						{
						vsf_color(vdi_handle, w->user_bcolour);
						last_bcolour = w->user_bcolour;
						}
					pxy[0] = x + (int) lw;
					pxy[1] = y;
					pxy[2] = w->in.g_x + w->in.g_w - 1;
					pxy[3] = y + w->vscroll.pixelsize - 1;
					vr_recfl(vdi_handle, pxy);
					}

				}
			}

		/* nÑchste Zeile */

		y += w->vscroll.pixelsize;
		l++;
		}
}


/*******************************************************************
*
* Notizfenstergrîûe berechnen
*
*******************************************************************/

void calc_size_notice_wind( WINDOW *w )
{
	long err;
	long pixelwidth;
	int dummy;


	vst_font(vdi_handle, w->user_fontID);
	vst_point(vdi_handle, w->user_fontH, &dummy, &dummy,
			&w->user_charW, &w->user_charH);
	w->hscroll.pixelsize = w->user_charW;
	w->vscroll.pixelsize = w->user_charH;

	get_line_column_count(w->user_file,
					strlen((char *) w->user_file),
					8,
					(w->user_fontprop) ? -1 : w->user_charW,
					&(w->vscroll.n),
					&(w->hscroll.n),
					&pixelwidth);
	/* Breite */

	if	(pixelwidth > scrg.g_w)
		pixelwidth = scrg.g_w;
	if	(pixelwidth < w->user_charW)
		pixelwidth = w->user_charW;
	w->in.g_w = (int) pixelwidth;

	/* Hîhe */

	err = (long) w->vscroll.n * (long) w->user_charH;
	if	(err > scrg.g_h)
		err = scrg.g_h;
	if	(err < w->user_charH)
		err = w->user_charH;
	w->in.g_h = (int) err + MOVER_HEIGHT;

	/* Auûenbereich berechnen */

	wind_calc(WC_BORDER, NOTICE_W_KIND, &(w->in),&(w->out));

	if	(w->out.g_y < scrg.g_y)
		w->out.g_y = scrg.g_y;
	if	(w->out.g_w > scrg.g_w)
		w->out.g_w = scrg.g_w;
	if	(w->out.g_h > scrg.g_h)
		w->out.g_h = scrg.g_h;
}


/*******************************************************************
*
* Notizfenster editieren
*
*******************************************************************/

long edit_notice_wind( unsigned char *notice, int id,
					WINDOW **pw )
{
	WINDOW *w;
	int i;


	for	(i = 0; i < NWINDOWS; i++)
		{
		if	(!windows[i])
			continue;	/* leerer Slot */
		if	(windows[i]->id_code == id)
			goto found;
		}
	return(ERROR);		/* id ungÅltig */
	 found:
	w = windows[i];

	Mfree(w->user_file);
	w->user_file = notice;
	calc_size_notice_wind( w );
	if	(!(w->flags & WFLAG_ICONIFIED))
		{
		w->snap(w);
		w->arrange(w);
		w->moved(w, &(w->out));
		update_window(w);
		}

	if	(pw)
		*pw = w;
	return(E_OK);
}


/*******************************************************************
*
* Notizfenster îffnen
*
* <notice> zeigt auf die Notiz, die Zeilen sind mit CR/LF
* abgeschlossen, der Gesamttext mit EOS.
*
*******************************************************************/

long open_notice_wind( unsigned char *notice, int id,
					int x, int y,
					int fontID, int font_is_prop, int fontH,
					int colour,
					WINDOW **pw )
{
	WINDOW **wp;
	WINDOW *w;
	int i;


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
		Mfree(w);
		return(ENSMEM);
		}

	*wp = w;
	init_window(w);

	w->id_code = id;
	w->selected = FALSE;
	w->user_bcolour = colour;
	w->user_tcolour = ((adr_colour[colour+1].ob_spec.tedinfo
					->te_color)&0xf00) >> 8;
	w->user_file = notice;
	w->user_fontH = fontH;
	w->user_fontID = fontID;
	w->user_fontprop = font_is_prop;

	w->in.g_x = x;
	w->in.g_y = y;

	calc_size_notice_wind( w );

	/* Spezielle Einstellungen */
	/* ----------------------- */

	wind_set(w->handle, WF_BEVENT, 0x0001, 0, 0, 0 );

	w->draw = draw_notice_wind;
/*	w->snap = snap_notice_wind;	*/
	w->arrange = arrange_notice_wind;
	w->moved = MY_moved;

	w->button = button_notice_wind;
	w->snap(w);
	w->open(w);
	if	(pw)
		*pw = w;
	return(E_OK);
}
