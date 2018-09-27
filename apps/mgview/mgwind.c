/*
*
* Dieses Modul enthÑlt die Fenster-Routinen
* FÅr ein Textfenster
*
*/

#include <stddef.h>
#include <string.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "globals.h"
#include "toserror.h"
#include "windows.h"
#include "mgwind.h"

extern const unsigned char *memchr2( const unsigned char *s, ssize_t len );

#define	MAXWIDTH	272

#define	MY_KIND	NAME+CLOSER+FULLER+MOVER+	\
				SIZER+UPARROW+DNARROW+VSLIDE+		\
				LFARROW+RTARROW+HSLIDE


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

static long expand_line( const unsigned char *text, long len, int tabsize,
					unsigned char *buf, long bufsize )
{
	const unsigned char *end = text+len;
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
* Dabei wird nur '\n' berÅcksichtigt, daû Zeilen mit '\n' oder
* mit '\r' abgeschlossen werden kînnen damit man mit UNIX-
* und Mac- Textdateien keine Probleme hat.
* D.h. Zeilen kînnen beendet werden durch:
*
*	$d$a
*	$a
*	$d
*	EOF
*
*****************************************************************/

static void get_line_column_count( const unsigned char *text, long len,
				long *lc, long *cc, int tabsize )
{
	const unsigned char *ende = text+len;
	const unsigned char *eol,*eol2;
	long w;			/* LÑnge einer Zeile */


	*lc = *cc = 0;
	while(text < ende)
		{
		(*lc)++;		/* hier beginnt eine Zeile! */

		/* eol markiert das erste Zeichen hinter der Zeile */
		/* Das Zeilenende kann CR,LF oder CRLF sein. eol2  */
		/* markiert das erste Zeichen der nÑchsten Zeile   */
		/* ----------------------------------------------- */

		eol = memchr2(text, ende-text);
		if	(eol)
			{
			eol2 = eol+1;		/* nÑchstes Zeichen */
			if	((*eol == '\r') && (*eol2 == '\n'))
				eol2++;
			}

		/* Letzte Zeile: */

		else	eol = eol2 = ende;

		w = expand_line( text, eol-text, tabsize,
						NULL, 1L );
		if	(w > MAXWIDTH)
			w = MAXWIDTH;

		if	(w > *cc)
			*cc = w;
		text = eol2;		/* aufs nÑchste Zeichen */
		}
}


/*****************************************************************
*
* Initialisiert das Feld w->user_lines[], das die ZeilenanfÑnge
* definiert.
*
*****************************************************************/

static void init_line_ptrs( const unsigned char *text, long len,
					const unsigned char **lines )
{
	const unsigned char *ende = text+len;
	const unsigned char *eol;


	while(text < ende)
		{
		*lines++ = text;		/* hier beginnt eine Zeile! */
		eol = memchr2(text, ende-text);

		/* Letzte Zeile: */

		if	(!eol)
			break;

		text = eol+1;		/* aufs nÑchste Zeichen */
		if	((*eol == '\r') && (*text == '\n'))
			text++;
		}
}


/*****************************************************************
*
* Ermittelt einen Zeiger auf die <n>-te Zeile des Textes.
* Gibt die LÑnge dieser Zeile (ohne CRLF bzw. LF) zurÅck.
*
*****************************************************************/

static unsigned char *get_line( WINDOW *w, long n, long *lw )
{
	unsigned char *line;
	unsigned char *ende;
	const unsigned char *eol;


	if	(n >= w->vscroll.n)
		{
		*lw = 0;
		return(NULL);
		}

	ende = w->user_file + w->user_fsize;
	line = w->user_lines[n];
	eol = memchr2(line, ende-line);

	/* Letzte Zeile: */

	if	(!eol)
		eol = ende;

	*lw = eol - line;
	return(line);
}


/****************************************************************
*
* éndert die Objektkoordinaten von w->out so, daû sie in
* bestimmte Raster einrasten.
* Hier:	Innen-GRECT muû ganzzahliges Vielfaches der Zeichengrîûe
*		sein.
*
****************************************************************/

static void _my_snap( WINDOW *w )
{
	/* Innenbereich berechnen */
	wind_calc_grect(WC_WORK, MY_KIND, &(w->out), &(w->in));
	/* x-Position auf 8er-Grenze */
	w->in.g_x &= ~7;
	/* Minimalgrîûe */
	if	(w->in.g_w < 8*text_attrib[8])
		w->in.g_w = 8*text_attrib[8];
	if	(w->in.g_h < 3*text_attrib[9])
		w->in.g_h = 3*text_attrib[9];
	/* Breite und Hîhe */
	w->in.g_w -= w->in.g_w % w->hscroll.pixelsize;
	w->in.g_h -= w->in.g_h % w->vscroll.pixelsize;
	/* nochmal Auûenbereich berechnen */
	wind_calc_grect(WC_BORDER, MY_KIND, &(w->in), &(w->out));
}


/****************************************************************
*
* Organisiert das Fenster neu, d.h. legt Position der Objekte fest.
* gibt TRUE zurÅck, falls sich fenster.cols oder fenster.shift
* geÑndert haben.
*
****************************************************************/

static int _my_arrange( WINDOW *w )
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


/****************************************************************
*
* Routine zum Zeichnen eines Textfensters.
*
****************************************************************/

static void _my_draw(WINDOW *w, GRECT *g)
{
	unsigned char *line;
	int i;
	long l;
	long lw;
	int x,y;
	int pxy[4];
	unsigned char textbuf[MAXWIDTH+1];


	pxy[0] = g->g_x;
	pxy[1] = g->g_y;
	pxy[2] = g->g_x + g->g_w - 1;
	pxy[3] = g->g_y + g->g_h - 1;
	vs_clip(vdi_handle, TRUE, pxy);

	/* FÅr jede sichtbare Zeile */

	x = w->in.g_x - (int) (w->hscroll.shift*w->hscroll.pixelsize);
	y = w->in.g_y;
	l = w->vscroll.shift;

	for	(i = 0; i < w->vscroll.nvis; i++)
		{
		if	((y+w->vscroll.pixelsize > g->g_y) &&
			 (y < g->g_y+g->g_h))
			{
			line = get_line(w, l, &lw);

			/* TABs expandieren */

			if	(line)
				lw = expand_line( line, lw, w->user_tabsize,
								textbuf, MAXWIDTH );

			/* erst den Text ausgeben */

			if	(line)
				{
				textbuf[lw] = '\0';
				v_gtext(vdi_handle, x, y, (char *) textbuf);
				}

			lw *= w->hscroll.pixelsize;	/* ausgegebene Pixel */

			/* dann ggf. ein weiûes Rechteck dahinter */

			if	(x+lw < w->in.g_x+w->in.g_w)
				{
				pxy[0] = x + (int) lw;
				pxy[1] = y;
				pxy[2] = w->in.g_x + w->in.g_w - 1;
				pxy[3] = y + w->vscroll.pixelsize - 1;
				vr_recfl(vdi_handle, pxy);
				}

			}

		/* nÑchste Zeile */

		y += w->vscroll.pixelsize;
		l++;
		}
}


/*****************************************************************
*
* Schlieût ein Textfenster
*
*****************************************************************/

static void _my_close(WINDOW *w, int kstate)
{
	WINDOW **sl;

	if	(kstate & K_CTRL)
		{
		v_clsvwk(vdi_handle);
		appl_exit();
		Pterm0();				/* brutalo */
		}
	wind_close(w->handle);
	wind_delete(w->handle);
	Mfree(w->user_file);
	Mfree(w->user_lines);
	sl = find_slot_window(w);
	*sl = NULL;
	nwindows--;
}


/*****************************************************************
*
* Tastatureingabe fÅr Textfenster
*
*****************************************************************/


#pragma warn -par
static void _my_keyed( WINDOW *w, int kstate, int key )
{
	int newtab;
	int ascii;

	/* Tabulator umschalten */

	ascii = key&0xff;
	if	((key < 0x1000) && (ascii >= '0') && (ascii <= '9'))
		{
		newtab = ascii-'0';
		if	(newtab != w->user_tabsize)
			{
			w->user_tabsize = newtab;
			get_line_column_count(w->user_file, w->user_fsize,
					&(w->vscroll.n), &(w->hscroll.n),
					w->user_tabsize);
			w->arrange(w);	/* Scrollbalken justieren! */
			update_window(w);
			}
		}
	else
	switch(key)
		{
/* Pos1  */
		case	0x4700:	w->arrowed(w, -1);
					break;
/* Ende (nur MF-2)     */
/* Ende (Macintosh)    */
		case 0x3700:
		case 0x4f00:
/* SH-Pos1 */
		case 0x4737:	w->arrowed(w, -2);
					break;
/* Cursor up */
		case 0x4800:	w->arrowed(w, WA_UPLINE);
					break;
/* Cursor down */
		case 0x5000:	w->arrowed(w, WA_DNLINE);
					break;
/* Bild hoch (Macintosh) */
		case 0x4900:
/* SH-Cursor up */
		case 0x4838:	w->arrowed(w, WA_UPPAGE);
					break;
/* Bild runter (Macintosh) */
		case 0x5100:
/* SH-Cursor dwn */
		case 0x5032:	w->arrowed(w, WA_DNPAGE);
					break;
/* Cursor links */
		case 0x4b00:	w->arrowed(w, WA_LFLINE);
					break;
/* Cursor rechts */
		case 0x4d00:	w->arrowed(w, WA_RTLINE);
					break;
/* SH-Cursor links */
		case 0x4b34:	w->arrowed(w, WA_LFPAGE);
					break;
/* SH-Cursor rechts */
		case 0x4d36:	w->arrowed(w, WA_RTPAGE);
					break;
/* ^U */
		case 0x1615:	w->close(w, 0);
					break;
		}
}
#pragma warn +par


/*****************************************************************
*
* Initialisiert und îffnet ein Textfenster
*
*****************************************************************/

void open_textwind( char *path )
{
	WINDOW **new_slot;
	WINDOW *w;
	XATTR xa;
	long err;
	int handle;
	GRECT full;		/* berechne maximale Fenstergrîûe */


	/* Fensterstruktur allozieren und Fenster erstellen */
	/* ------------------------------------------------ */

	if	(strlen(path) > 127)
		return;				/* Pfad zu tief */
	new_slot = new_window();
	if	(!new_slot)
		{
		err:
		form_alert(1,"[3][Kein Fenster mehr.][Abbruch]");
		return;
		}
	w = Malloc(sizeof(WINDOW));
	if	(!w)
		{
		form_xerr(ENSMEM, NULL);
		return;
		}

	/* Fenster-Maximalgrîûe berechnen */
	/* ------------------------------ */

	wind_calc_grect(WC_WORK, MY_KIND, &scrg, &full);	/* Innenbereich */
	/* x-Position auf 8er-Grenze */
	full.g_x &= ~7;
	/* Breite und Hîhe */
	full.g_w -= full.g_w % text_attrib[8];
	full.g_h -= full.g_h % text_attrib[9];
	/* nochmal Auûenbereich berechnen */
	wind_calc_grect(WC_BORDER, MY_KIND, &full, &full);

	w->handle = wind_create_grect(MY_KIND, &full );
	if	(w->handle <= 0)
		{
		Mfree(w);
		goto err;
		}

	/* Datei einlesen */
	/* -------------- */

	err = Fopen(path, O_RDONLY);
	if	(err < E_OK)
		{
		err2:
		wind_delete(w->handle);
		Mfree(w);
		form_xerr(err, path);
		return;
		}
	handle = (int) err;
	err = Fcntl(handle, (long) &xa, FSTAT);
	if	(err < E_OK)
		{
		err3:
		Fclose(handle);
		goto err2;
		}

	w->user_fsize = xa.st_size;
	w->user_file = Malloc(xa.st_size + 1);	/* Platz fÅr EOS */
	if	(!w->user_file)
		{
		err = ENSMEM;
		goto err3;
		}

	err = Fread(handle, xa.st_size, w->user_file);
	if	(err != xa.st_size)
		{
		if	(err >= 0)
			err = EREADF;
		err4:
		Mfree(w->user_file);
		goto err3;
		}

	Fclose(handle);
	*new_slot = w;
	nwindows++;

	/* Default-Einstellungen */

	init_window(w);

	/* Eigene Einstellungen */

	w->user_tabsize = 8;
	get_line_column_count(w->user_file, w->user_fsize,
					&(w->vscroll.n), &(w->hscroll.n),
					w->user_tabsize);
	w->user_lines = Malloc(w->vscroll.n * sizeof(char *));
	if	(!w->user_lines)
		{
		err = ENSMEM;
		goto err4;
		}
	init_line_ptrs( w->user_file, w->user_fsize,
				w->user_lines );
	strcpy(w->title, path);
	w->hscroll.pixelsize = text_attrib[8];
	w->vscroll.pixelsize = text_attrib[9];
	w->snap = _my_snap;
	w->draw = _my_draw;
	w->arrange = _my_arrange;
	w->close = _my_close;
	w->key = _my_keyed;

	w->in.g_x = scrg.g_x;
	w->in.g_y = scrg.g_y;
	err = (long) w->hscroll.n * (long) text_attrib[8];
	if	(err > scrg.g_w)
		err = scrg.g_w;
	w->in.g_w = (int) err;
	err = (long) w->vscroll.n * (long) text_attrib[9];
	if	(err > scrg.g_h)
		err = scrg.g_h;
	w->in.g_h = (int) err;
	wind_calc_grect(WC_BORDER, MY_KIND, &(w->in),&(w->out));

	if	(w->out.g_y < scrg.g_y)
		w->out.g_y = scrg.g_y;
	if	(w->out.g_w > scrg.g_w)
		w->out.g_w = scrg.g_w;
	if	(w->out.g_h > scrg.g_h)
		w->out.g_h = scrg.g_h;

	/* Fenster staffeln */
	w->out.g_x += (int) (new_slot-windows)*text_attrib[8];
	w->out.g_y += (int) (new_slot-windows)*text_attrib[9];

	/* Und schlieûlich îffnen */

	w->open(w);
	wind_set_str(w->handle, WF_NAME, w->title);
}
