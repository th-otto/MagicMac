/*
*
* Dieser Quelltext enthÑlt die Routinen fÅr
* das Edit-Objekt
*
*/

#define MIN(a,b) ((a < b) ? a : b)
#define MAX(a,b) ((a > b) ? a : b)

#define TEMPLATES 0
#define DEBUG 0

#include <mgx_dos.h>
#include ".\mt_aes.h"
#include <vdi.h>
#if DEBUG
#include <stdio.h>
#endif
#include <string.h>
#include "editob.h"
#include "globals.h"

/* GEMDOS (MiNT) Fopen modes */

#define   MO_RDONLY       0
#define   MO_WRONLY       1
#define   MO_RDWR         2
#define   MO_APPEND       8
#define   MO_COMPAT       0
#define   MO_DENYRW       0x10
#define   MO_DENYW        0x20
#define   MO_DENYR        0x30
#define   MO_DENYNONE     0x40
#define   MO_CREAT        0x200
#define   MO_TRUNC        0x400
#define   MO_EXCL         0x800

/* extern aus memchr2.s */

/* sucht nach '\r' oder '\n' */
extern void  *memchr2( const void *s, size_t len );

/* extern aus editob_s.s */

#if	TEMPLATES
extern void mrgtmplt( WORD just, char *txt, char *tmplt, unsigned char *dest);
#endif
#if	DEBUG
int errno;
#endif

/* lokal */

static void init_lines( XEDITINFO *xi );
static void init_pcursor( XEDITINFO *xi );
static LONG get_number_of_lines( XEDITINFO *xi );

static WORD curr_fontID = -1;
static WORD curr_fontH = -1;		/* Hîhe in pt bzw. Pixeln */
static WORD curr_fontMd = -1;		/* Modus 0/1 */
static WORD curr_charW, curr_charH;


/****************************************************************
*
* Zeichensatz einstellen
*
****************************************************************/

static void setfont( XEDITINFO *xi )
{
	int dummy = 0;


	if	(curr_fontID != xi->fontID)
		{
		vst_font(vdi_handle, xi->fontID);
		curr_fontID = xi->fontID;
		dummy = 1;
		}

	if	((dummy) || (curr_fontMd != xi->fontPix) ||
		 (curr_fontH != xi->fontH))
		{
		if	(xi->fontPix)
			vst_height(vdi_handle, xi->fontH, &dummy, &dummy,
				&curr_charW, &curr_charH);
		else	vst_point(vdi_handle, xi->fontH, &dummy, &dummy,
				&curr_charW, &curr_charH);
		curr_fontMd = xi->fontPix;
		curr_fontH = xi->fontH;
		}
	xi->charW = curr_charW;
	xi->charH = curr_charH;
}


/****************************************************************
*
* EDITINFO modifizieren
*
****************************************************************/

WORD edit_set_font( XEDITINFO *xi,
			WORD fontID, WORD fontH, WORD fontPix, WORD mono )
{
	unsigned char *firstline;


	if	(xi->lines)
		{
		firstline = xi->lines->line;	/* erste sichtbare Zeile */
		Mfree(xi->lines);
		}
	xi->fontID = fontID;
	xi->fontH = fontH;
	xi->fontPix = fontPix;
	xi->mono = mono;
	setfont( xi );
#if DEBUG
	printf("xi->charH = %d\n", xi->charH);
#endif

	if	(xi->lines)	/* geîffnet? */
		{
		xi->lvis = xi->ob_h/xi->charH;
#if DEBUG
	printf("xi->lvis = %d\n", xi->lvis);
#endif
		xi->lines = Malloc(xi->lvis * sizeof(struct _xed_li));
		if	(!xi->lines)
			return(0);
		if	(xi->lvis)
			xi->lines->line = firstline;
		init_lines( xi );
		init_pcursor(xi);			/* Pixelpos. berechnen */
#if DEBUG
	printf("init_lines,init_pcursor\n");
#endif
		}
	return(1);
}

void edit_set_buf( XEDITINFO *xi,
			unsigned char *buf, LONG buflen )
{
	xi->buf = buf;
	xi->buflen = buflen;				/* inkl. EOS */
	xi->curr_tlen = strlen((char *) xi->buf);	/* ohne EOS */
	xi->max_linew = -1;					/* unbekannt */
	xi->nlines = get_number_of_lines(xi);
	xi->dirty = FALSE;
	if	(xi->lines)	/* geîffnet ? */
		{
		xi->xscroll = 0;
		xi->yscroll = 0;
		xi->lines[0].line = xi->buf;	/* erste sichtbare Zeile */
		init_lines( xi );
		xi->ccurs_x = xi->ccurs_y = 0;	/* Cursor links oben */
		init_pcursor(xi);				/* Pixelpos. berechnen */
		xi->curs_hidecnt = 0;
		xi->bsel = NULL;
		}
}

void edit_set_format( XEDITINFO *xi,
			WORD tabwidth, WORD autowrap )
{
	if	((tabwidth >= 0) && (xi->tabwidth != tabwidth))
		{
		xi->tabwidth = tabwidth;
		init_pcursor(xi);				/* Pixelpos. berechnen */
		}
	if	((autowrap >= 0) && (xi->autowrap != autowrap))
		{
		xi->autowrap = autowrap;
		if	(xi->buf)
			{
			xi->max_linew = -1;
			xi->nlines = get_number_of_lines(xi);
			}
		if	(xi->lines)	/* geîffnet ? */
			{
			xi->xscroll = 0;
			xi->yscroll = 0;
			xi->lines[0].line = xi->buf;	/* erste sichtbare Zeile */
			init_lines( xi );
			xi->ccurs_x = xi->ccurs_y = 0;	/* Cursor links oben */
			init_pcursor(xi);				/* Pixelpos. berechnen */
			}
		}
}


/****************************************************************
*
* EDITINFO allozieren
*
****************************************************************/

XEDITINFO *edit_create( void )
{
	XEDITINFO *xi;

	xi = Malloc(sizeof(XEDITINFO));
	if	(xi)
		{
		xi->magic = 'XEDT';
		xi->buf = NULL;
		xi->lines = NULL;
		xi->buflen = 0L;
		xi->tabwidth = 64;
		xi->autowrap = 0;
		xi->tcolour = BLACK;
		xi->bcolour = WHITE;
		xi->dirty = FALSE;
		xi->curs_hidecnt = 0;
		edit_set_font(xi, 1 /* AES-Font */,
					10 /* 10pt */, FALSE, TRUE);
		}
	return(xi);
}


/****************************************************************
*
* Objektgrîûe liegt fest, Speicher fÅr Zeilenpuffer anfordern.
*
****************************************************************/

WORD edit_open( OBJECT *ob, XEDITINFO *xi )
{
	xi->ob_h = ob->ob_height;
	xi->lvis = xi->ob_h/xi->charH;
	xi->xscroll = 0;
	xi->lines = Malloc(xi->lvis * sizeof(struct _xed_li));
	if	(!xi->lines)
		return(0);
	xi->yscroll = 0;
	xi->lines[0].line = xi->buf;	/* erste sichtbare Zeile */
/*
	xi->curr_tlen = strlen((char *) xi->buf);
*/
	init_lines( xi );
	xi->ccurs_x = xi->ccurs_y = 0;	/* Cursor links oben */
	init_pcursor(xi);				/* Pixelpos. berechnen */
	xi->bsel = NULL;
	return(1);
}


/****************************************************************
*
* Scroll- und Cursorposition setzen. Kein Redraw.
*
****************************************************************/

void edit_set_scroll_and_cpos( XEDITINFO *xi,
			WORD xscroll,
			LONG yscroll,
			unsigned char *cyscroll,
			unsigned char *curpos,
			WORD cx, WORD cy)
{
	xi->lines[0].line = cyscroll;
	xi->yscroll = yscroll;
	xi->xscroll = xscroll;
	init_lines(xi);
	xi->tcurs = curpos;		/* falls cy ungÅltig ist */
	xi->ccurs_x = cx;
	xi->ccurs_y = cy;
	init_pcursor(xi);
}


/****************************************************************
*
* Das Objekt ist geîffnet.
* Objektgrîûe oder der Zeichensatz haben sich geÑndert.
*
* Geliefert wird zusÑtzlich noch die vorherige und neue
* tatsÑchliche Hîhe, damit ein Editor den Rand neu
* zeichnen kann.
*
****************************************************************/

WORD edit_resized( OBJECT *ob, XEDITINFO *xi,
				WORD *oldrh, WORD *newrh )
{
	int new_lvis;
	unsigned char *oldline;


	xi->ob_h = ob->ob_height;

	/* Neue Zeilen-Anzahlen berechnen */
	/* ------------------------------ */

	*oldrh = xi->lvis * xi->charH;
	new_lvis = xi->ob_h/xi->charH;
	*newrh = new_lvis * xi->charH;
	if	(xi->lvis == new_lvis)
		return(1);

	/* Cursorposition retten */
	/* --------------------- */

	if	(!xi->tcurs)
		xi->tcurs = edit_get_cursor(xi);

	/* vertikale Scrollpos. merken. */
	/* Zeilenstruktur neu aufbauen. */
	/* ---------------------------- */

	if	(xi->lines)
		{
		oldline = xi->lines[0].line;
		Mfree(xi->lines);
		xi->lines = NULL;
		}
	else	oldline = xi->buf;
	xi->lvis = new_lvis;

	if	(xi->lvis)
		{
		xi->lines = Malloc(xi->lvis * sizeof(struct _xed_li));
		if	(!xi->lines)
			return(0);
		xi->lines[0].line = oldline;	/* erste sichtbare Zeile */
		init_lines( xi );
		init_pcursor(xi);			/* Pixelpos. berechnen */
		}
	return(1);
}


/****************************************************************
*
* Objektgrîûe, Zeichensatz, Text oder Formatierungsmodi haben
* sich geÑndert, Speicher fÅr Zeilenpuffer freigeben.
*
****************************************************************/

void edit_close( XEDITINFO *xi )
{
	if	(xi->lines)
		{
		Mfree(xi->lines);
		xi->lines = NULL;
		}
}


/****************************************************************
*
* Alles freigeben.
*
****************************************************************/

void edit_delete( XEDITINFO *xi )
{
	edit_close(xi);
	Mfree(xi);
}


/*********************************************************************
*
* PrÅft, ob der Mausklick ins Objekt ging.
*
*********************************************************************/

static WORD xy_in_grect( WORD x, WORD y, GRECT *g )
{
	return((x >= g->g_x) && (x < g->g_x+g->g_w) &&
		  (y >= g->g_y) && (y < g->g_y+g->g_h));
}


/****************************************************************
*
* Bestimmt die Schnittmenge zwischen zwei Rechtecken
*
****************************************************************/

static WORD rc_intersect(GRECT *p1, GRECT *p2)
{
	WORD	tx, ty, tw, th;

	tw = MIN(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = MIN(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = MAX(p2->g_x, p1->g_x);
	ty = MAX(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return( (tw > tx) && (th > ty) );
}


/****************************************************************
*
* Zeichenposition in Pixelpos umrechnen. Dabei wird vqt_extend
* verwendet.
*
****************************************************************/

static WORD extent( unsigned char *s, LONG len, WORD mono,
					WORD charW, WORD tabwidth)
{
	unsigned char c;
	unsigned char *l,*t;
	WORD slen;
	WORD offs = 0;
	WORD rest;
	int out[8];



	l = s + len;
	c = *l;
	*l = '\0';

	while(*s)
		{

		/* nÑchsten Tabulator bestimmen */
		/* ---------------------------- */

		if	(!tabwidth)
			t = NULL;
		else	t = (unsigned char *) strchr((char *) s, '\t');

		/* Text bis zum Tabulator berechnen */
		/* -------------------------------- */

		if	(t)
			*t = '\0';
		slen = (WORD) strlen((char *) s);
		if	(mono)
			offs += slen*charW;
		else	{
			vqt_extent(vdi_handle, (char *) s, out);
			offs += (out[2] - out[0]);
			}

		/* x-Position weiterschalten */
		/* ------------------------- */

		if	(t)
			{
			offs += 1;	/* mind. 1 Pixel */
			rest = offs % tabwidth;
			if	(rest)
				offs += (tabwidth-rest);
			*t = '\t';
			slen++;
			}
		s += slen;
		}
	*l = c;
	return(offs);
/*
	unsigned char c;
	register unsigned char *s2;
	int out[8];


	if	(mono)
		return((WORD) (n*charW));
	s2 = s+n;
	c = *s2;
	*s2 = '\0';
	vqt_extent(vdi_handle, (char *) s, out);
	*s2 = c;
	return(out[2] - out[0]/* + 1*/);
*/
}


/****************************************************************
*
* Zeichenkette mit Tabulator ausgeben.
*
****************************************************************/

static void gtext( unsigned char *s, WORD len,
			WORD x, WORD y, WORD mono, WORD charW, WORD tabwidth )
{
	unsigned char c;
	unsigned char *l,*t;
	WORD slen;
	WORD offs = 0;
	WORD rest;



	l = s + len;
	c = *l;
	*l = '\0';

	while(*s)
		{

		/* nÑchsten Tabulator bestimmen */
		/* ---------------------------- */

		if	(!tabwidth)
			t = NULL;
		else	t = (unsigned char *) strchr((char *) s, '\t');

		/* Text bis zum Tabulator ausgeben */
		/* ------------------------------- */

		if	(t)
			*t = '\0';
		slen = (WORD) strlen((char *) s);
		v_gtext(vdi_handle, x+offs, y, (char *) s);

		/* x-Position weiterschalten */
		/* ------------------------- */

		if	(t)
			{
			offs += extent(s, slen, mono, charW, 0);
			offs += 1;	/* mind. 1 Pixel */
			rest = offs % tabwidth;
			if	(rest)
				offs += (tabwidth-rest);
			*t = '\t';
			slen++;
			}
		s += slen;
		}
	*l = c;
}


/****************************************************************
*
* Scrap-Datei îffnen.
*
****************************************************************/

static WORD open_scrap( WORD omode )
{
	char path[130];
	long ret;
	WORD file;

	file = -1;
	if	(scrp_read(path))
		{
		strcat(path, "SCRAP.TXT");
		ret = Fopen(path, omode);
		if	(ret >= 0)
			file = (WORD) ret;
		}
	return(file);
}


/****************************************************************
*
* Feststellen, ob das Zeichen ein Wort-Trenner ist.
*
****************************************************************/

static WORD c_is_sep( unsigned char c)
{
	return(NULL != strchr(" !..+-*/:..?[\\]{|}()~ˆ˜¯˘˙" "\t", c));
}


/****************************************************************
*
* Anzahl der Zeilen-Ende zÑhlen
*
****************************************************************/

static WORD lcount( unsigned char *bsel, unsigned char *esel,
				WORD *additional)
{
	long lc;
	unsigned char *eline = NULL;
	char c;

/*
Cconws("bsel = ");
Fwrite(1, 20L, bsel);
Cconws("\r\nesel = ");
Fwrite(1, 20L, esel);
Cconws("\r\n");
*/

	eline = esel;
	for	(lc = 0; bsel < esel; bsel++)
		{
		/* erstes Vorkommen von '\r' oder '\n' */
		bsel = memchr2(bsel, esel-bsel);
		if	(!bsel)
			break;	/* kein (weiteres) Zeilen-Ende gefunden */

		lc++;		/* Anzahl der Zeilen-Enden erhîhen */
		if	(bsel < esel-1)	/* noch nicht am Ende */
			{
			c = bsel[1];		/* nÑchstes Zeichen */
			if	(((c == '\r') || (c == '\n')) && (c != *bsel))
				bsel++;		/* "\r\n" oder "\n\r" */
			}
		eline = bsel+1;	/* nÑchste Zeile */
		}

	if	(eline < esel)
		*additional = 1;
	else	*additional = 0;

	if	(lc > 32000)
		return(32000);
	else	return((WORD) lc);
}


/****************************************************************
*
* Pixelposition in Zeichenposition umrechnen.
*
* Da es hierzu keine VDI-Funktion gibt, muû man mit Hilfe
* von vqt_extend() und binÑrer Suche schachteln.
*
****************************************************************/

static int pixpos_to_npos( XEDITINFO *xi,
						unsigned char *line, LONG len_o,
						WORD x )
{
	LONG len_u,len;
	WORD ix;


#if DEBUG1
printf("x = %d len_o = %ld\n", x, len_o);
#endif
/*
	if	(xi->mono)
		{
		len = x / xi->charW;
		if	(len >= len_o)
			len = len_o;
		}
	else	{
*/
		/* Zeichensatz und -hîhe setzen */
		/* ---------------------------- */

		setfont( xi );

		len = len_u = 0;
		while(len_u < len_o)
			{
#if DEBUG1
printf("u = %ld o = %ld => len = ", len_u, len_o);
#endif
			if	(len_o - len_u == 1)
				{
#if DEBUG1
printf("%ld\n", len_o);
#endif
				ix = extent( line, len_o, xi->mono, xi->charW,
							xi->tabwidth );
#if DEBUG1
printf(" ix = %d\n", ix);
#endif
				if	(ix <= x)
					len = len_o;
				else	len = len_u;
				break;
				}
			else	{
				len = (len_u+len_o)/2;
#if DEBUG1
printf("%ld\n", len);
#endif
				ix = extent( line, len, xi->mono, xi->charW,
							xi->tabwidth  );
#if DEBUG1
printf(" ix = %d\n", ix);
#endif
				if	(ix < x)
					{
/*
					if	(len_u == len)
						break;
*/
					len_u = len;
					}
				else	{
					len_o = len;
					}
				}
			}
/*
		}
*/
#if DEBUG1
	printf("len = %ld\n", len);
#endif
	return((int) len);
}


/****************************************************************
*
* Zeichenposition des Cursors in Pixelposition umrechnen.
* Die Pixelposition ist relativ zum Textanfang, d.h. man muû
* noch den horizontalen Scroll-Offset abziehen, um die
* tatsÑchliche Position zu erhalten.
*
****************************************************************/

static void init_pcursor( XEDITINFO *xi )
{
	struct _xed_li *li;


	if	(xi->ccurs_y < xi->lvis)
		{
		xi->pcurs_y = xi->ccurs_y * xi->charH;
		li = xi->lines + xi->ccurs_y;
		xi->pcurs_x = extent( li->line, xi->ccurs_x,
						xi->mono, xi->charW,
						xi->tabwidth );
		xi->tcurs = NULL;	/* Cursor ist gÅltig */
		xi->pcursth_x = xi->pcurs_x;
		}
#if	DEBUG2
	printf("pcursth_x = %d  ccurs_x = %d\n",
			xi->pcursth_x, xi->ccurs_x);
#endif
}


/****************************************************************
*
* Position des selektierten Bereichs berechnen
*
* => RÅckgabe	1, wenn Bereich sichtbar.
*	bl		erste Zeile
*	bc		 zugehîrige Zeichenposition
*	el		letzte Zeile (ggf. -1, wenn bis Ende)
*	ec		 zugehîrige Zeichenposition (ggf. -1, wenn bis Ende )
*
****************************************************************/

static int get_selrange( XEDITINFO *xi, WORD *bl, WORD *bc,
					WORD *el, WORD *ec,
					unsigned char *bsel, unsigned char *esel )
{
	struct _xed_li *li;
	register int i;


	if	(esel < xi->lines->line)
		return(0);
	if	(!xi->leff)
		return(0);
	li = xi->lines+xi->leff-1;	/* letzte Zeile */
	if	(bsel == esel)
		{
		if	(bsel > li->line+li->len+li->lextra)
			return(0);
		}
	else	{
		if	(bsel >= li->line+li->len+li->lextra)
			return(0);
		}

	if	(bsel < xi->lines->line)
		bsel = xi->lines->line;


	/* Beginn der Selektion finden */
	/* --------------------------- */

	*bc = -1;		/* nix gefunden */
	for	(li = xi->lines,i = 0; (li->line); li++,i++)
		{
		if	((bsel >= li->line) && (bsel <= li->line+li->len))
			{
			*bl = i;
			*bc = (WORD) (bsel - li->line);

			/* Ende der Selektion finden */
			/* ------------------------- */

			for	(; (li->line); li++,i++)
				{
				if	((esel >= li->line) && (esel <= li->line+li->len))
					{
					*el = i;
					*ec = (WORD) (esel - li->line);

/*
printf("bl = %d, bc = %d, el = %d, ec = %d\n", *bl, *bc, *el, *ec);
*/

					return(1);
					}
				}
			*el = *ec = -1;

/*
printf("bl = %d, bc = %d, el = %d, ec = %d\n", *bl, *bc, *el, *ec);
*/

			return(1);
			}
		}
	return(0);
}


/****************************************************************
*
* GRECTs des selektierten Bereichs berechnen
*
* =>	RÅckgabe:	Anzahl Bereiche (0 oder 1 oder 2 oder 3)
*	g[0..2]	selektierte Bereiche
*
****************************************************************/

static int get_selgrects( XEDITINFO *xi, GRECT *obj_g, GRECT *g,
			unsigned char *bsel, unsigned char *esel )
{
	WORD bl,bc,el,ec;
	WORD xp,ng;


	if	(!bsel)
		return(0);		/* nix selektiert */

	if	(!get_selrange( xi, &bl, &bc, &el, &ec, bsel, esel))
		return(0);		/* Bereich unsichtbar */

	ng = 1;	/* nur ein GRECT */
/*
	if	(xi->mono)
		xp = bc * xi->charW;
	else	{
		if	(bc)
*/
			xp = extent(xi->lines[bl].line, bc, xi->mono, xi->charW,
						xi->tabwidth );
/*
		else xp = 0;	/* Zeilenanfang! */
		}
*/
	g->g_x = obj_g->g_x + xp - xi->xscroll;
	g->g_y = obj_g->g_y + bl * xi->charH;
	if	(bl == el)
		goto restzeile;
	else	{
volle_zeilen:
		g->g_w = obj_g->g_w + xi->xscroll;		/* volle Breite */
		if	(!bc)	/* Beginnt am Zeilenanfang */
			{
			if	(ec >= 0)	/* letzte Zeile nicht vollst. */
				{
				if	(el > bl)
					{
					g->g_h = (el - bl) * xi->charH;
					g++;
					ng++;
					}
				xp = 0;
				g->g_x = obj_g->g_x - xi->xscroll;
				g->g_y = obj_g->g_y + el * xi->charH;
restzeile:
				if	(!ec)
					ng--;
				else	{
					g->g_w = extent(xi->lines[el].line,
								ec, xi->mono, xi->charW,
								xi->tabwidth ) - xp;
					g->g_h = xi->charH;
					}
				}
			else	{
				if	(el < 0)
					el = xi->lvis - 1;
				g->g_h = (el - bl + 1) * xi->charH;
				}
			}
		else	{	/* Beginnt nicht am Zeilenanfang */
			g->g_h = xi->charH;
			if	((bl < xi->lvis-1) && !((el == bl+1) && (!ec)))
				{
				g++;
				ng++;
				bc = 0;
				bl++;
				g->g_x = obj_g->g_x - xi->xscroll;
				g->g_y = obj_g->g_y + bl * xi->charH;
				goto volle_zeilen;
				}
			}
		}
	return(ng);
}


/****************************************************************
*
* ZeilenlÑnge und nÑchste Zeile bestimmen.
*
* Eingabe:
*	xi			Editfeld-Daten
*	s			Beginn der Zeile
*
* RÅckgabe:
*	len			Netto-ZeilenlÑnge ohne EOL
*    lextra		LÑnge der Zeilenende-Markierung
*	<ret>		1, wenn die Zeile mit EOT abschlieût
*
* Die nÑchste Zeile beginnt also bei
*	s+len+lextra
*
****************************************************************/

static int get_next_eol( XEDITINFO *xi, unsigned char *s,
					LONG *len, WORD *lextra )
{
	unsigned char *eol;
	int lmax;
	int eot;
	char c;


	eol = (unsigned char *) memchr2((char *) s,
				xi->curr_tlen - (s - xi->buf));

	if	(eol)
		{
		*len = eol-s;
		*lextra = 1;			/* CR oder LF Åberlesen */
		if	(eol < xi->buf+xi->curr_tlen-1)
			{
			c = eol[1];			/* nÑchstes Zeichen */
			if	(((c == '\r') || (c == '\n')) && (c != *eol))
				(*lextra)++;	/* "\r\n" oder "\n\r" */
			}
		eot = 0;
		}
	else	{
		*len = strlen((char *) s);
		*lextra = 0;
		eot = 1;			/* EOT */
		}

#if DEBUG1
	printf("len = %ld, lextra = %d, eot = %d\n", *len,
			*lextra, eot);
#endif

	/* ggf. Auto-Wrap */
	/* -------------- */

	if	(xi->autowrap)
		{
/*
		if	(xi->mono)
			lmax = xi->autowrap / xi->charW;
		else */	lmax = pixpos_to_npos(xi, s, *len, xi->autowrap);

#if DEBUG1
printf("lmax = %d, len = %ld\n", lmax, *len);
#endif

		if	(*len > lmax)
			{

			/* Suche Wort-Ende */
			/* --------------- */

			eol = s + lmax - 1;
			while((eol > s) &&
				 (*eol != ' ') && (*eol != '-'))
				eol--;
			if	(eol > s)
				lmax = (WORD) (eol - s + 1);
			*len = lmax;
			*lextra = 0;
			eot = FALSE;
			}
		}

	return(eot);
}


/****************************************************************
*
* vorherige Zeile und ZeilenlÑnge bestimmen.
*
* Eingabe:
*	xi			Editfeld-Daten
*	s			aktuelle Zeile
*
* Ausgabe:
*	len			Netto-ZeilenlÑnge ohne EOL
*    lextra		LÑnge der Zeilenende-Markierung
*	<ret>		Zeiger auf vorherige Zeile oder NULL
*
* Wenn <s> auf den Beginn der aktuellen Zeile zeigt, wird
* der Beginn der vorherigen Zeile sowie die LÑnge der
* Zeilenende-Markierung der vorherigen Zeile geliefert.
*
* Wenn <s> mitten in eine Zeile zeigt, wird der Beginn der
* aktuellen Zeile geliefert, und (*lextra) ist 0.
*
****************************************************************/

static unsigned char *get_prev_eol( XEDITINFO *xi,
				unsigned char *s, LONG *len, WORD *lextra )
{
	unsigned char *sol,*t;
	int eot;
	LONG len2;
	WORD lextra2;
	char c1,c2;



	/* EOL der vorherigen Zeile bestimmen */
	/* ---------------------------------- */

	*len = 0L;
	if	(s <= xi->buf)
		{
		*lextra = 0;
		return(NULL);
		}

	sol = s;
	c1 = sol[-1];	/* vorheriges Zeichen */
	if	((c1 == '\r') || (c1 == '\n'))
		{
		sol--;
		if	(sol > xi->buf)
			{
			c2 = sol[-1];		/* noch ein Zeichen davor */
			if	(((c2 == '\r') || (c2 == '\n')) && (c1 != c2))
				sol--;		/* "\r\n" oder "\n\r" */
			}
		}
	*lextra = (WORD) (s-sol);

	/* Beginn der vorherigen Zeile bestimmen      */
	/* Wir suchen erst nach einem "harten" Return */
	/* ------------------------------------------ */

	t = sol-1;
	while((t > xi->buf) && (*t != '\n') && (*t != '\r'))
		t--;
	if	(t > xi->buf)
		t++;
	else
	if	(t < xi->buf)
		t = xi->buf;

	/* Bei automatischem Zeilenumbruch suchen wir die */
	/* vorherige Teil-Zeile						*/
	/* ---------------------------------------------- */

	if	(xi->autowrap)
		{
		len2 = 0L;
		lextra2 = 0;
		do	{
			t += len2+lextra2;
			eot = get_next_eol( xi, t, &len2, &lextra2 );
			}
		while((!eot) && (t+len2+lextra2 < s));
		}

	*len = sol - t;
	return(t);
}


/****************************************************************
*
* Zeilenanzahl berechnen.
* Die Zeilen werden durch (weichen) Umbruch oder durch
* "\r\n" (CR+LF) abgeschlossen oder durch EOS (am Text-Ende).
*
****************************************************************/

static LONG get_number_of_lines( XEDITINFO *xi )
{
	register LONG i;
	unsigned char *s;
	int eot;
	LONG len;
	WORD lextra;
	WORD linew;


	s = xi->buf;
	i = 0L;
	do	{
		eot = get_next_eol( xi, s, &len, &lextra );
		if	(xi->autowrap)
			{
			linew = extent(s, len, xi->mono, xi->charW,
						xi->tabwidth);
			if	(linew > xi->max_linew)
				xi->max_linew = linew;
			}
		i++;
		s += len + lextra;
		}
	while(!eot);
	return(i);
}


/****************************************************************
*
* Zeilenzeiger und -lÑngen initialisieren.
* Die Zeilen werden durch \r\n (CR+LF) abgeschlossen oder
* durch EOS (am Text-Ende).
*
* Der Zeiger
*	xi->lines[0].line
* ist bereits initialisiert und zeigt auf die erste
* sichtbare Zeile.
*
****************************************************************/

static void init_lines( XEDITINFO *xi )
{
	register int i;
	struct _xed_li *li;
	unsigned char *s;
	int eot;


	li = xi->lines;
	s = li->line;
	xi->leff = 0;

	for	(i = 0,eot = FALSE; i < xi->lvis; i++,li++)
		{
#if DEBUG
	printf("Zeile %d\n", i);
#endif
		if	(eot)
			li->line = NULL;
		else	{
			li->line = s;
#if DEBUG
	printf(" li->line = %c%c%c%c%c\n", s[0],s[1],s[2],s[3]);
#endif
			eot = get_next_eol( xi, s, &(li->len), &(li->lextra) );
#if DEBUG
	printf(" li->len = %ld, li->lextra = %d\n", li->len, li->lextra);
#endif
			xi->leff++;

			s += li->len + li->lextra;
			}
		}
}


/***************************************************************
*
* Toggelt den Selektionsstatus fÅr das GRECT im Fenster
*
***************************************************************/

static void sel_grect( GRECT *g, WORD whdl )
{
	int pxy[4];
	GRECT list;


	vsf_color(vdi_handle, BLACK);
	vswr_mode(vdi_handle, MD_XOR);
	vs_clip(vdi_handle, FALSE, NULL);

	if	(whdl < 0)
		{
		pxy[0] = g->g_x;
		pxy[1] = g->g_y;
		pxy[2] = pxy[0] + g->g_w - 1;
		pxy[3] = pxy[1] + g->g_h - 1;
		vr_recfl(vdi_handle, pxy);
		return;
		}

	wind_get_grect(whdl, WF_FIRSTXYWH, &list);
	do	{
		if	(rc_intersect(g, &list))
			{
			pxy[0] = list.g_x;
			pxy[1] = list.g_y;
			pxy[2] = pxy[0] + list.g_w - 1;
			pxy[3] = pxy[1] + list.g_h - 1;
			vr_recfl(vdi_handle, pxy);
			}
		wind_get_grect(whdl, WF_NEXTXYWH, &list);
		}
	while(list.g_w > 0);
}


/***************************************************************
*
* (De)selektiert einen Bereich des Edit-Fensters
*
***************************************************************/

static void sel_xeditob( XEDITINFO *xi, GRECT *obj_g, WORD whdl,
			unsigned char *bsel, unsigned char *esel )
{
	GRECT *g;
	GRECT gx[3];
	int i;


	if	(bsel)
		{
		graf_mouse(M_OFF, NULL);
		i = get_selgrects( xi, obj_g, gx, bsel, esel );
		if	(i)
			{
			vswr_mode(vdi_handle, MD_XOR);
			vsf_color(vdi_handle, BLACK);		/* Selektion */
			for	(g = gx; i > 0; i--,g++)
				{
				if	(rc_intersect(obj_g, g))
					sel_grect( g, whdl );
				}
			}
		graf_mouse(M_ON, NULL);
		}
}


/***************************************************************
*
* Deselektiert den gesamten Bereich des Edit-Fensters
*
***************************************************************/

static void unsel_xeditob( XEDITINFO *xi, GRECT *obj_g, WORD whdl )
{
	if	(xi->bsel)
		{
		sel_xeditob( xi, obj_g, whdl, xi->bsel, xi->esel );
		xi->bsel = NULL;
		}
}


/***************************************************************
*
* Erweitert/Verkleinert einen Bereich des Edit-Fensters
*
***************************************************************/

static void sel_new_xeditob( XEDITINFO *xi, GRECT *obj_g, WORD whdl,
			unsigned char *bsel, unsigned char *esel )
{
	unsigned char *b,*e;


	if	(bsel == esel)
		bsel = NULL;		/* leerer Bereich */

	/* neue Selektion */

	if	(!xi->bsel)		/* bisher nix selektiert */
		{
		b = bsel;			/* ggf. NULL */
		e = esel;
		goto draw;
		}

	if	(!bsel)
		{
		b = xi->bsel;
		e = xi->esel;
		goto draw;
		}

	/* Ende unverÑndert */

	if	(esel == xi->esel)
		{
		if	(bsel < xi->bsel)	/* Anfang erweitert */
			{
			b = bsel;
			e = xi->bsel;
			}
		else
		if	(bsel > xi->bsel)	/* Anfang verkÅrzt */
			{
			b = xi->bsel;
			e = bsel;
			}
		else	return;			/* keine énderung */
		goto draw;
		}

	/* Anfang unverÑndert */

	if	(bsel == xi->bsel)
		{
		if	(esel < xi->esel)
			{
			b = esel;
			e = xi->esel;
			}
		else
		if	(esel > xi->esel)
			{
			b = xi->esel;
			e = esel;
			}
		else return;
		goto draw;
		}

	/* Weder Anfang noch Ende unverÑndert */

	sel_xeditob( xi, obj_g, whdl, xi->bsel, xi->esel );
	b = bsel;
	e = esel;

draw:
	xi->bsel = bsel;
	xi->esel = esel;
	if	(b)
		sel_xeditob( xi, obj_g, whdl, b, e );
}


/***************************************************************
*
* Zeichenroutine fÅrs USERDEF
*
***************************************************************/

static void _draw_cursor( WORD x, WORD y, XEDITINFO *xi )
{
	int pxy[4];

	if	(!xi->tcurs)
		{
		vsl_color(vdi_handle, BLACK);
		vswr_mode(vdi_handle, MD_XOR);
		pxy[0] = x + xi->pcurs_x - xi->xscroll;
		pxy[1] = y + xi->pcurs_y;
		pxy[2] = pxy[0];
		pxy[3] = pxy[1] + xi->charH;
		v_pline( vdi_handle, 2, pxy);
		}
}

WORD cdecl xeditob_userdef( PARMBLK *pb )
{
	XEDITINFO *xi = (XEDITINFO *) pb->pb_parm;
	int pxy[4];
	int x,y;
	register int i;
	struct _xed_li *li;


	/* objc_change() bearbeiten */
	/* ------------------------ */

	if	(pb->pb_currstate != pb->pb_prevstate)
		goto ende;

	/* Zeichensatz und -hîhe setzen */
	/* ---------------------------- */

	setfont( xi );
	vst_color(vdi_handle, xi->tcolour);

	/* Hintergrundfarbe festlegen */
	/* -------------------------- */

	vswr_mode(vdi_handle, MD_REPLACE);
	vsf_color(vdi_handle, xi->bcolour);

	/* Clipping setzen (mit Objekt schneiden!) */
	/* --------------------------------------- */

	if	(!rc_intersect((GRECT *) &(pb->pb_x), (GRECT *) &(pb->pb_xc)))
		goto ende;
	pxy[0] = pb->pb_xc;
	pxy[1] = pb->pb_yc;
	pxy[2] = pxy[0] + pb->pb_wc - 1;
	pxy[3] = pxy[1] + pb->pb_hc - 1;
	if	(pxy[2] < 0)
		goto ende;
	vs_clip(vdi_handle, TRUE, pxy);

/*
printf("x1 = %d y1 = %d x2 = %d y2 = %d\n",
	pxy[0],pxy[1],pxy[2],pxy[3]);
*/

	/* Hintergrund (FlÑche) ausgeben */
	/* ----------------------------- */

	vr_recfl(vdi_handle, pxy);

	/* Text ausgeben */
	/* ------------- */

	if	(xi->bcolour)
		vswr_mode(vdi_handle, MD_TRANS);

	x = pb->pb_x - xi->xscroll;
	y = pb->pb_y;
	for	(i = 0,li = xi->lines; i < xi->lvis; i++,li++)
		{
#if DEBUG1
	printf("li->line = %s, li->len = %ld\n", li->line, li->len);
#endif

		/* Leerzeilen und solche auûerhalb des	*/
		/* Clippings weglassen				*/
		/* ------------------------------------ */

		if	((y + xi->charH > pb->pb_yc) &&
			 (y < pb->pb_yc + pb->pb_hc) &&
			 (li->line) && (li->len))
			{

			/* zeichnen */
			/* -------- */

			gtext(li->line, (WORD) li->len, x, y,
					xi->mono, xi->charW, xi->tabwidth);
			}

		y += xi->charH;
		}

	/* Cursor zeichnen */
	/* --------------- */

	if	(!xi->curs_hidecnt)
		_draw_cursor(pb->pb_x, pb->pb_y, xi);

	/* Selektion zeichnen */
	/* ------------------ */

	if	(xi->bsel)
		{
		GRECT gx[3];
		GRECT *g;

		i = get_selgrects( xi, (GRECT *) &(pb->pb_x), gx,
					xi->bsel, xi->esel );
		if	(i)
			{
			vswr_mode(vdi_handle, MD_XOR);
			vsf_color(vdi_handle, BLACK);		/* Selektion */
			for	(g = gx; i > 0; i--,g++)
				{
				pxy[0] = g->g_x;
				pxy[1] = g->g_y;
				pxy[2] = pxy[0] + g->g_w - 1;
				pxy[3] = pxy[1] + g->g_h - 1;
				vr_recfl(vdi_handle, pxy);
				}
			}
		}

ende:
	return(pb->pb_currstate);
}


/***************************************************************
*
* Cursor zeichnen
*
***************************************************************/

static void _draw_cursor_whdl( GRECT *obj_g, XEDITINFO *xi,
						WORD whdl )
{
	int pxy[4];
	int pxyc[4];
	GRECT list;


	if	(xi->tcurs)		/* Cursor auûerhalb des Fensters */
		return;

	if	(whdl < 0)
		{
		_draw_cursor( obj_g->g_x, obj_g->g_y, xi );
		return;
		}

	vsl_color(vdi_handle, BLACK);
	vswr_mode(vdi_handle, MD_XOR);
	pxy[0] = obj_g->g_x + xi->pcurs_x - xi->xscroll;
	pxy[1] = obj_g->g_y + xi->pcurs_y;
	pxy[2] = pxy[0];
	pxy[3] = pxy[1] + xi->charH;
	wind_get_grect(whdl, WF_FIRSTXYWH, &list);
	do	{
		if	(rc_intersect(obj_g, &list))
			{
			pxyc[0] = list.g_x;
			pxyc[1] = list.g_y;
			pxyc[2] = pxyc[0] + list.g_w - 1;
			pxyc[3] = pxyc[1] + list.g_h - 1;
			vs_clip(vdi_handle, TRUE, pxyc);
			v_pline( vdi_handle, 2, pxy);
			}
		wind_get_grect(whdl, WF_NEXTXYWH, &list);
		}
	while(list.g_w > 0);
}


/***************************************************************
*
* Cursor an/aus
*
***************************************************************/

static void edit_cursor_off( GRECT *obj_g, XEDITINFO *xi,
						WORD whdl )
{
	if	(xi->lines)			/* geîffnet */
		{
		if	(!xi->curs_hidecnt)		/* Cursor sichtbar */
			{
			graf_mouse(M_OFF, NULL);
			_draw_cursor_whdl( obj_g, xi, whdl );
			graf_mouse(M_ON, NULL);
			}
		}
	xi->curs_hidecnt++;
}

static void edit_cursor_on( GRECT *obj_g, XEDITINFO *xi,
						WORD whdl )
{
	xi->curs_hidecnt--;
	if	(!xi->curs_hidecnt)
		{
		graf_mouse(M_OFF, NULL);
		_draw_cursor_whdl( obj_g, xi, whdl );
		graf_mouse(M_ON, NULL);
		}
}


/***************************************************************
*
* Cursor an/aus (extern)
* Show = -1: Hide-Counter ermitteln
*
***************************************************************/

WORD edit_cursor(OBJECT *tree, WORD obj, WORD whdl,
			WORD show, XEDITINFO *xi)
{
	GRECT g;


	objc_offset(tree, obj, &g.g_x, &g.g_y);
	tree += obj;
	g.g_w = tree->ob_width;
	g.g_h = tree->ob_height;
	if	(show == 1)
		edit_cursor_on(&g, xi, whdl);
	else
	if	(!show)
		edit_cursor_off(&g, xi, whdl);
	return(xi->curs_hidecnt);
}


/***************************************************************
*
* Universelle Scrollroutine
*
* Sollte ins AES Åbernommen werden.
*
* g			Zu scrollender Bereich
* offset		soviele Pixel scrollen
* is_horiz	horizontal (1) oder vertikal (0)
* draw		Routine fÅr redraw (nicht gescrollter Bereich)
* whdl		Fenster-Handle oder -1
*
***************************************************************/

void wind_scroll( GRECT *g, WORD offset, WORD is_horiz,
				void *param, WORD whdl,
				void cdecl (*draw)(GRECT *g, WORD whdl,
							void *param))
{
	WORD abs_offset;
	WORD page_offset;
	register int xcopy,ycopy;		/* soviele x-Pixel werden kopiert */
	MFDB src_mfdb,dest_mfdb;
	int  pxy[8];
	GRECT list_g;
	int clip_rect[4];



	/* wenn >= 1 Seite gescrollt, wird das Fenster neu aufgebaut */

	abs_offset = (offset > 0) ? offset : -offset;
	page_offset = (is_horiz) ? g->g_w : g->g_h;
	if	(abs_offset > page_offset)
		{
		(*draw)(g, whdl, param);		/* Voller Redraw */
		return;
		}

	/* offset > 0: Balken nach unten/rechts, Inhalt nach oben/links */

	/* Fenster Åber Rechteckliste scrollen */

	graf_mouse(M_OFF, NULL);
	if	(whdl >= 0)
		wind_get_grect(whdl, WF_FIRSTXYWH, &list_g);
	else	{
		list_g = *g;		/* alles */
		goto scrollit;
		}

	do	{
		if	(rc_intersect(g, &list_g))
			{
			scrollit:
			if	(is_horiz)
				{
				xcopy = list_g.g_w - (int) abs_offset;		/* soviele Pixel blitten */
				if	(xcopy > 0)
					{
					pxy[1] = pxy[5] = list_g.g_y;
					pxy[3] = pxy[7] = list_g.g_y + list_g.g_h - 1;
					if	(offset > 0)
						{
						pxy[4] = list_g.g_x;
						pxy[0] = list_g.g_x + offset;
						}
					else {
						pxy[0] = list_g.g_x;
						pxy[4] = list_g.g_x - offset;
						}
					pxy[2] = pxy[0] + xcopy - 1;
					pxy[6] = pxy[4] + xcopy - 1;
					src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
					clip_rect[0] = g->g_x;
					clip_rect[1] = g->g_y;
					clip_rect[2] = clip_rect[0] + g->g_w-1;
					clip_rect[3] = clip_rect[1] + g->g_h-1;
					vs_clip	(vdi_handle, TRUE, clip_rect);
					vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
					/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
					list_g.g_w -= xcopy;
					if	(offset > 0)
						list_g.g_x += xcopy;
					}
				}
			else	{
				ycopy = list_g.g_h - abs_offset;		/* soviele Pixel blitten */
				if	(ycopy > 0)
					{
					pxy[0] = pxy[4] = list_g.g_x;
					pxy[2] = pxy[6] = list_g.g_x + list_g.g_w - 1;
					if	(offset > 0)
						{
						pxy[5] = list_g.g_y;
						pxy[1] = list_g.g_y + offset;
						}
					else {
						pxy[1] = list_g.g_y;
						pxy[5] = list_g.g_y - offset;
						}
					pxy[3] = pxy[1] + ycopy - 1;
					pxy[7] = pxy[5] + ycopy - 1;
					src_mfdb.fd_addr = dest_mfdb.fd_addr = NULL;
					clip_rect[0] = g->g_x;
					clip_rect[1] = g->g_y;
					clip_rect[2] = clip_rect[0] + g->g_w-1;
					clip_rect[3] = clip_rect[1] + g->g_h-1;
					vs_clip(vdi_handle, TRUE, clip_rect);
					vro_cpyfm(vdi_handle, S_ONLY, pxy, &src_mfdb, &dest_mfdb);
					/* alles neu zeichnen, was nicht vom Zielraster Åberdeckt wurde */
					list_g.g_h -= ycopy;
					if	(offset > 0)
						list_g.g_y += ycopy;
					}
				}
			(*draw)(&list_g, whdl, param);
			}
		if	(whdl >= 0)
			wind_get_grect(whdl, WF_NEXTXYWH, &list_g);
		}
	while((whdl >= 0) && (list_g.g_w > 0));		/* bis Rechteckliste vollstÑndig */

	graf_mouse(M_ON, NULL);
}


/***************************************************************
*
* Horizontale Scrollroutine fÅrs USERDEF
*
* Es muû sichergestellt werden, daû der Cursor horizontal
* sichtbar ist. Ggf. muû gescrollt werden.
*
* Der Cursor kann minimal am Textanfang stehen (Pos 0),
* maximal hinter dem letzten Zeichen, d.h. ein Pixel
* auûerhalb (!) des Objekts.
*
***************************************************************/

struct _draw_param
	{
	OBJECT *tree;
	WORD obj;
	};

static void cdecl _draw(GRECT *g, WORD whdl,
				void *p)
{
	struct _draw_param *dp = p;

	objc_wdraw(dp->tree, dp->obj, 0, g, whdl);
}

static void hscroll(OBJECT *tree, WORD obj,GRECT *obj_g,
					XEDITINFO *xi, WORD whdl)
{
	int x,xn,offset;
	struct _draw_param dp;


	x = xi->pcurs_x - xi->xscroll;		/* tats. Position */
	if	(x < 0)
		xn = 0;
	else
	if	(x >= obj_g->g_w)
		xn = obj_g->g_w-1;
	else	return;		/* Cursor ist sichtbar */

	offset = x - xn;
	dp.tree = tree;
	dp.obj = obj;
	xi->xscroll += offset;
	wind_scroll(obj_g, offset, TRUE, &dp, whdl, _draw);
}

static void hscroll_lr(OBJECT *tree, WORD obj,GRECT *obj_g,
					XEDITINFO *xi, WORD whdl, WORD offset)
{
	struct _draw_param dp;

	dp.tree = tree;
	dp.obj = obj;
	if	(xi->xscroll + offset >= 0)
		{
		xi->xscroll += offset;
		wind_scroll(obj_g, offset, TRUE, &dp, whdl, _draw);
		}
}


/***************************************************************
*
* Wort-Suchroutinen
*
***************************************************************/

static unsigned char *next_word( struct _xed_li *li, WORD x,
						int spaces )
{
	unsigned char *s,*se;


	s = li->line+x;
	se = li->line+li->len;
	while((s < se) && (!(c_is_sep(*s))))
		s++;		/* öberspringe Zeichen */
	if	(spaces)
		{
		while((s < se) && (c_is_sep(*s)))
			s++;		/* öberspringe Zeichen */
		}
	return(s);
}

static unsigned char *prev_word( struct _xed_li *li, WORD x )
{
	unsigned char *s;


	s = li->line+x - 1;
	while((s > li->line) && (c_is_sep(*s)))
		s--;		/* öberspringe Blanks */
	if	(s > li->line)
		{
		while((s > li->line) && (!(c_is_sep(s[-1]))))
			s--;		/* öberspringe Zeichen */
		}
	return(s);
}


/***************************************************************
*
* Scrolling.
*
* RÅckgabe der Anzahl tatsÑchlich gescrollter Zeilen.
*
***************************************************************/

static int scroll_up(OBJECT *tree, WORD obj, GRECT *obj_g,
				WORD whdl, XEDITINFO *xi, WORD n)
{
	struct _xed_li *li;		/* Cursorzeile */
	unsigned char *s;
	GRECT draw_g;
	struct _draw_param dp;
	int m;


	for	(m = n; m; m--)
		{
		if	(xi->leff < xi->lvis)
			break;
		li = xi->lines+xi->lvis-1;	/* letzte sichtbare Zeile */
		if	((!li->lextra) && (li->line+li->len >= xi->buf+xi->curr_tlen))
			break;

		s = li->line+li->len+li->lextra;

		/* Alle Zeilenzeiger shiften */
		/* ------------------------- */

		memmove(xi->lines, xi->lines+1,
				(xi->lvis-1)*sizeof(struct _xed_li));
		/* Letzte Zeile umsetzen */
		li->line = s;	/* neue letzte Zeile! */
		get_next_eol( xi, li->line, &li->len, &li->lextra );
		}

	/* Scrolling */
	/* --------- */

	n -= m;		/* soviel haben wir gescrollt */
	if	(n)
		{
		dp.tree = tree;
		dp.obj = obj;

		draw_g = *obj_g;
		draw_g.g_h = xi->lvis * xi->charH;
		wind_scroll( &draw_g, n * xi->charH, FALSE,
					&dp, whdl, _draw);
		xi->yscroll += n;
		}
	return(n);			/* soviel habe ich gescrollt */
}


static int scroll_down(OBJECT *tree, WORD obj, GRECT *obj_g,
				WORD whdl, XEDITINFO *xi, WORD n)
{
	struct _xed_li *li;		/* Cursorzeile */
	unsigned char *s;
	GRECT draw_g;
	struct _draw_param dp;
	LONG len;
	WORD lextra;
	int m;


	for	(m = n; m; m--)
		{
		li = xi->lines;		/* erste sichtbare Zeile */
		s = get_prev_eol( xi, li->line, &len, &lextra );
		if	(!s)
			break;		/* es geht nicht weiter */

		/* Alle Zeilenzeiger shiften */
		/* ------------------------- */

		memmove(xi->lines+1, xi->lines,
				(xi->lvis-1)*sizeof(struct _xed_li));
		/* Erste Zeile umsetzen */
		li->line = s;	/* neue erste Zeile! */
		li->len = len;
		li->lextra = lextra;
		if	(xi->leff < xi->lvis)
			xi->leff++;
		}

	/* Scrolling */
	/* --------- */

	n -= m;		/* soviel haben wir gescrollt */
	if	(n)
		{
		dp.tree = tree;
		dp.obj = obj;

		draw_g = *obj_g;
		draw_g.g_h = xi->lvis * xi->charH;
		wind_scroll( &draw_g, -n*(xi->charH), FALSE,
					&dp, whdl, _draw);
		xi->yscroll -= n;
		}
	return(n);			/* soviel habe ich gescrollt */
}


/***************************************************************
*
* Setzt yscroll absolut, gibt die Anzahl gescrollter Zeilen
* zurÅck.
*
***************************************************************/

static long _lnum_yscroll(XEDITINFO *xi, LONG n)
{
	struct _xed_li *li;
	long curr;
	unsigned char *t;
	long difflines = 0L;
	int eot;
	long len;
	WORD lextra;


	curr = xi->yscroll;
	t = xi->lines->line;		/* erste Zeile */
	if	(n == curr)
		return(difflines);

	if	(n < curr)	/* muû hoch scrollen */
		{
		do	{
			t = get_prev_eol( xi, t, &len, &lextra );
			curr--;
			difflines--;
			}
		while(n < curr);
		/* oberste Zeile beginnt jetzt bei t */
		if	(difflines)
			{
			xi->lines->line = t;
			init_lines(xi);
			}
		}
	else	{			/* muû runter scrollen */
		eot = TRUE;
		li = xi->lines+xi->lvis-1;	/* letzte Zeile */
		t = li->line;
		if	(t)
			{
			t += li->len + li->lextra;
			if	((t < xi->buf+xi->curr_tlen) || (li->lextra))
				eot = FALSE;	/* es gibt nÑchste Zeile */
			}

		while((!eot) && (n > curr))
			{
			/* Alle Zeilenzeiger shiften */
			/* ------------------------- */

			memmove(xi->lines, xi->lines+1,
					(xi->lvis-1)*sizeof(struct _xed_li));
			difflines++;
			curr++;
			/* Letzte Zeile umsetzen */
			li->line = t;	/* neue letzte Zeile! */
			eot = get_next_eol( xi, t, &li->len, &li->lextra );
			t += li->len+li->lextra;
			}
		}
	return(difflines);
}


/***************************************************************
*
* Vertikales Scrolling
*
* Es wird solange gescrollt, bis die Zeile, welche <s> enthÑlt,
* im Objekt sichtbar ist.
* Der Cursor (ccurs_x, ccurs_y) wird auf s gesetzt.
*
***************************************************************/

static void vscroll_to(OBJECT *tree, WORD obj, GRECT *obj_g,
				WORD whdl, XEDITINFO *xi,
				unsigned char *dest)
{
	int difflines = 0;
	struct _xed_li *li;
	unsigned char *t;
	long len;
	WORD lextra;
	GRECT draw_g;
	struct _draw_param dp;
	WORD bl,bc,el,ec;
	int eot;


#if	DEBUG1
	printf("vscroll_to: %c%c%c%c%c|%s\n",
			dest[-5],dest[-4],dest[-3],dest[-2],dest[-1],dest);
#endif

	t = xi->lines->line;		/* erste Zeile */
	if	(dest < t)
		{

		/* ich muû hoch scrollen */
		/* --------------------- */

		do	{
			t = get_prev_eol( xi, t, &len, &lextra );
			difflines--;
			}
		while(dest < t);
		/* oberste Zeile beginnt jetzt bei t */
		if	(difflines)
			{
			xi->lines->line = t;
			init_lines(xi);
			}
		}
	else	{

		eot = TRUE;
		li = xi->lines+xi->lvis-1;	/* letzte Zeile */
		t = li->line;
		if	(t)
			{
			t += li->len + li->lextra;
			if	((t < xi->buf+xi->curr_tlen) || (li->lextra))
				eot = FALSE;	/* es gibt nÑchste Zeile */
			}

		while((!eot) && (dest >= t))
			{
			/* Alle Zeilenzeiger shiften */
			/* ------------------------- */

			memmove(xi->lines, xi->lines+1,
					(xi->lvis-1)*sizeof(struct _xed_li));
			difflines++;
			/* Letzte Zeile umsetzen */
			li->line = t;	/* neue letzte Zeile! */
			eot = get_next_eol( xi, t, &li->len, &li->lextra );
			t += li->len+li->lextra;
			}
		}

/*
Fwrite(1, 20L, t);
Cconws("\r\n");
return(1);
*/

	if	(difflines)
		{
		/* Scrolling */
		/* --------- */

		dp.tree = tree;
		dp.obj = obj;

		draw_g = *obj_g;
		draw_g.g_h = xi->lvis * xi->charH;
		wind_scroll( &draw_g, difflines * (xi->charH), FALSE,
				&dp, whdl, _draw);
		xi->yscroll += difflines;
		}

	/* Cursor positionieren */
	/* -------------------- */

	if	(get_selrange( xi, &bl, &bc, &el, &ec, dest, dest ))
		{
		xi->ccurs_x = bc;
		xi->ccurs_y = bl;
		init_pcursor(xi);
		hscroll( tree, obj, obj_g, xi, whdl);
		}
}


/***************************************************************
*
* Bereich lîschen
*
***************************************************************/

static void del_range( OBJECT *tree, WORD obj, GRECT *obj_g,
			WORD whdl, XEDITINFO *xi,
			unsigned char *bsel, unsigned char *esel,
			struct _xed_li *li)

{
	GRECT draw_g;
	struct _draw_param dp;
	int scroll_lines_range,leff,nlines_del;
	int additional_line,difflines;
	unsigned char *aline,*nextline,*pline;
	LONG len;
	WORD lextra;
	void *was_tabulator;



	/* Scrollen, bis Anfang der Selektion sichtbar ist */
	/* Cursor auf den Anfang der Selektion setzen.	 */
	/* ----------------------------------------------- */

	if	(!li)
		{
		vscroll_to(tree, obj, obj_g, whdl, xi, bsel);
		li = xi->lines+xi->ccurs_y;
		}

	/* Im Fall "autowrap" vorherige Zeile bestimmen */
	/* -------------------------------------------- */

	if	(xi->autowrap)
		{
		if	(!xi->ccurs_y)
			pline = get_prev_eol( xi, li->line, &len, &lextra );
		else	pline = NULL;
		}
	else	{
		/* Anzahl der zu lîschenden Zeilen berechnen */
		/* ----------------------------------------- */
		nlines_del = lcount(bsel, esel, &additional_line);
		xi->nlines -= nlines_del;
		if	(!nlines_del)
			was_tabulator = memchr(bsel, '\t', esel-bsel);
		}


	/* Bereich lîschen */
	/* --------------- */

	memcpy(bsel, esel, xi->buf+xi->curr_tlen-
							esel+1);
	xi->dirty = TRUE;	/* Text geÑndert */
	if	(xi->autowrap)
		xi->max_linew = -1;		/* Breite unbekannt */
	xi->curr_tlen -= esel-bsel;
	if	(xi->bsel == bsel)
		xi->bsel = NULL;

	/* Redraw-Rechteck der aktuellen Zeile ab Cursor */
	/* --------------------------------------------- */

	draw_g.g_x = obj_g->g_x + xi->pcurs_x - xi->xscroll;
	draw_g.g_y = obj_g->g_y + xi->ccurs_y * xi->charH;
	draw_g.g_w = obj_g->g_w - (draw_g.g_x - obj_g->g_x);
	draw_g.g_h = xi->charH;

	/* 1. Fall: Autowrap: Im Zweifelsfall alles neu machen */
	/* --------------------------------------------------- */

	if	(xi->autowrap)
		{

		/* aktuelle, vorherige und folgende Zeile merken */
		/* --------------------------------------------- */

		aline = li->line;
		if	(xi->ccurs_y < xi->leff-1)
			nextline = (li+1)->line - (esel-bsel);
		else	nextline = NULL;
		leff = xi->leff;

		/* neue Zeilenenden berechnen */
		/* -------------------------- */

		if	(pline)
			{
			get_next_eol(xi, pline, &len, &lextra);
			li->line = pline+len+lextra;
			}
		init_lines(xi);

		/* nachsehen, ob sich aktuelle Zeile geÑndert hat */
		/* Wenn ja, aktuelle und vorherige neu zeichnen	*/
		/* ---------------------------------------------- */

		if	(aline != li->line)
			{
/*
Cconws("aline != li->line\r\n");
*/
			draw_g = *obj_g;
			if	(xi->ccurs_y)
				{
				draw_g.g_y += (xi->ccurs_y-1) * xi->charH;
				draw_g.g_h -= (xi->ccurs_y-1) * xi->charH;
				}
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			goto scroll;
			}

		/* nachsehen, ob sich Zeilen verschoben haben */
		if	(nextline)
			{
			if	(nextline == (li+1)->line)
				{

				/* nÑchste Zeile hat sich nicht geÑndert */
				/* Nur Zeile neu machen und Ende */

				if	((xi->mono) && (!xi->tabwidth))
					{
					dp.tree = tree;
					dp.obj = obj;
		
					wind_scroll( &draw_g, ((WORD) (esel-bsel)) * xi->charW, TRUE,
								&dp, whdl, _draw);
					}
				else	{
					objc_wdraw(tree, obj, 0, &draw_g, whdl);
					}
				goto scroll;
				}
			}
		if	(li->len < xi->ccurs_x)
			{
			draw_g.g_x = extent( li->line, li->len,
							xi->mono, xi->charW,
							xi->tabwidth );
			if	(!xi->mono)
				draw_g.g_x -= 4;	/* wg. Kerning */
			draw_g.g_x += obj_g->g_x - xi->xscroll;
			draw_g.g_w = obj_g->g_w - (draw_g.g_x - obj_g->g_x);
			}
		objc_wdraw(tree, obj, 0, &draw_g, whdl);
		if	(xi->ccurs_y < leff-1)
			{
			draw_g = *obj_g;
			draw_g.g_y += (xi->ccurs_y+1) * xi->charH;
			draw_g.g_h = (leff - (xi->ccurs_y+1)) * xi->charH;
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			}

/*
Cconws("vscroll_to: ");Fwrite(1, 10L, s + (bp-kbuf));Cconws("\r\n");
*/
	scroll:
		vscroll_to(tree, obj, obj_g, whdl, xi, bsel);
		return;
		}

	/* 2. Fall: kein Autowrap */
	/* ---------------------- */

	/* Zeilenzeiger aktualisieren */
	/* -------------------------- */

	if	(nlines_del)
		{

		/* mehrere Zeilen gelîscht */
		/* ----------------------- */

		leff = xi->leff;			/* vorherige Anzahl */
		init_lines(xi);

		objc_wdraw(tree, obj, 0, &draw_g, whdl);	/* Anfangszeile */

		/* verbleibender Redraw */

		scroll_lines_range = leff - xi->ccurs_y - 1;
		difflines = nlines_del;
/*
printf("leff = %d\n", leff);
printf("additional_line = %d\n", additional_line);
printf("nlines_del = %d\n", nlines_del);
printf("scroll_lines_range = %d\n", scroll_lines_range);
*/

		if	((difflines > 0) && (scroll_lines_range > 0))
			{
	
			/* Redraw: Alle Zeilen unterhalb der	*/
			/* neuen Zeile nach oben verschieben	*/
			/* ------------------------------------ */
	
			dp.tree = tree;
			dp.obj = obj;
	
			draw_g = *obj_g;
			draw_g.g_h = scroll_lines_range * xi->charH;
			draw_g.g_y += (xi->ccurs_y + 1) * xi->charH;
	
			wind_scroll( &draw_g, difflines * xi->charH, FALSE,
						&dp, whdl, _draw);
	
			/* Redraw der letzten Zeilen */
			/* ------------------------- */
	/*
			draw_g = *obj_g;
			draw_g.g_y = obj_g->g_y + (xi->lvis-nlines_del) * xi->charH;
			draw_g.g_h = nlines_del * (xi->charH);
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
	*/
			}
		}

	else	{

		/* nur innerhalb einer Zeile */
		/* ------------------------- */

		li = xi->lines+xi->ccurs_y;
		li->len -= esel-bsel;		/* Zeile verkÅrzt */
		if	(xi->mono && !was_tabulator)
			{

			dp.tree = tree;
			dp.obj = obj;

			wind_scroll( &draw_g, ((WORD) (esel-bsel))*xi->charW,
						TRUE, &dp, whdl, _draw);
			}
		else	{

			/* bei Prop.fonts sicherheitshalber neu zeichnen */

			if	(!xi->mono)
				{
				draw_g.g_x -= 4;	/* wg. Kerning */
				draw_g.g_w += 4;
				}
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			}

		/* Zeilenzeiger der folgenden Zeilen anpassen */
		/* ------------------------------------------ */

		li++;
		while((li < xi->lines+xi->lvis) && (li->line))
			{
			li->line -= esel-bsel;
			li++;
			}
		
		}
}


/***************************************************************
*
* Bereich (bse,esel) an Cursorposition einfÅgen
*
* RÅckgabe 0 bei PufferÅberlauf
*
***************************************************************/

static int ins_range( OBJECT *tree, WORD obj, GRECT *obj_g,
			WORD whdl, XEDITINFO *xi,
			unsigned char *data, LONG add_len,
			struct _xed_li *li)

{
	GRECT draw_g;
	struct _draw_param dp;
	int nlines_ins;
	int additional_line;
	long len;
	unsigned char *s;
	int only_crlf,scroll_lines;
	int old_lextra;
	unsigned char *nextline,*aline,*pline;



	if	(xi->curr_tlen + add_len >= xi->buflen)
		return(0);

	/* Im Fall "autowrap" vorherige Zeile bestimmen */
	/* -------------------------------------------- */

	if	(xi->autowrap)
		{
		if	(!xi->ccurs_y)
			pline = get_prev_eol( xi, li->line, &len, &old_lextra );
		else	pline = NULL;
		}

	/* Text einfÅgen */
	/* ------------- */

	s = li->line + xi->ccurs_x;
	memmove( s+add_len, s, (xi->buf+xi->curr_tlen+1)-(s));
	memmove( s, data, add_len );
	xi->dirty = TRUE;	/* Text geÑndert */
	if	(xi->autowrap)
		xi->max_linew = -1;		/* Breite unbekannt */
	s += add_len;
	xi->curr_tlen += add_len;

	/* GRECT fÅr Redraw der Cursorzeile */
	/* -------------------------------- */

	draw_g.g_x = obj_g->g_x+xi->pcurs_x - xi->xscroll;
	draw_g.g_y = obj_g->g_y + xi->ccurs_y * xi->charH;
	draw_g.g_w = obj_g->g_w - (draw_g.g_x - obj_g->g_x);
	draw_g.g_h = xi->charH;
	if	(!xi->mono)
		{
		draw_g.g_x -= 4;	/* wg. Kerning */
		draw_g.g_w += 4;
		}

	/* 1. Fall: Autowrap: Im Zweifelsfall alles neu machen */
	/* --------------------------------------------------- */

	if	(xi->autowrap)
		{

		/* aktuelle, vorherige und folgende Zeile merken */
		/* --------------------------------------------- */

		aline = li->line;
		if	(xi->ccurs_y < xi->leff-1)
			nextline = (li+1)->line + add_len;
		else	nextline = NULL;

		/* neue Zeilenenden berechnen */
		/* -------------------------- */

		if	(pline)
			{
			get_next_eol(xi, pline, &len, &old_lextra);
			li->line = pline+len+old_lextra;
			}
		init_lines(xi);

		/* nachsehen, ob sich aktuelle Zeile geÑndert hat */
		/* Wenn ja, aktuelle und vorherige neu zeichnen	*/
		/* ---------------------------------------------- */

		if	(aline != li->line)
			{
			draw_g = *obj_g;
			if	(xi->ccurs_y)
				{
				draw_g.g_y += (xi->ccurs_y-1) * xi->charH;
				draw_g.g_h -= (xi->ccurs_y-1) * xi->charH;
				}
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			return(1);
			}

		/* nachsehen, ob sich Zeilen verschoben haben */
		if	(nextline)
			{
			if	(nextline == (li+1)->line)
				{

				/* nÑchste Zeile hat sich nicht geÑndert */
				/* Nur Zeile neu machen und Ende */

				if	((xi->mono) && (!xi->tabwidth))
					{
					dp.tree = tree;
					dp.obj = obj;
		
					wind_scroll( &draw_g, (-(WORD) add_len) * xi->charW, TRUE,
								&dp, whdl, _draw);
					}
				else	{
					objc_wdraw(tree, obj, 0, &draw_g, whdl);
					}
				return(1);
				}
			}
		if	(li->len < xi->ccurs_x)
			{
			draw_g.g_x = extent( li->line, li->len,
							xi->mono, xi->charW,
							xi->tabwidth );
			if	(!xi->mono)
				draw_g.g_x -= 4;	/* wg. Kerning */
			draw_g.g_x += obj_g->g_x - xi->xscroll;
			draw_g.g_w = obj_g->g_w - (draw_g.g_x - obj_g->g_x);
			}
		objc_wdraw(tree, obj, 0, &draw_g, whdl);
		if	(xi->ccurs_y < xi->leff-1)
			{
			draw_g = *obj_g;
			draw_g.g_y += (xi->ccurs_y+1) * xi->charH;
			draw_g.g_h = (xi->leff - (xi->ccurs_y+1)) * xi->charH;
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			}
		return(1);
		}

	/* 2. Fall: kein Autowrap */
	/* ---------------------- */

	/* Anzahl der zu einzufÅgenden Zeilen berechnen */
	/* -------------------------------------------- */

	nlines_ins = lcount(data, data+add_len, &additional_line);
	xi->nlines += nlines_ins;

	if	(!nlines_ins)
		{

		/* 1. Fall: keine neue Zeile eingefÅgt */
		/* ----------------------------------- */

		li->len += add_len;

		/* Redraw der Zeile */
		/* ---------------- */

		if	(xi->mono	&& !memchr(data, '\t', add_len))
			{
			dp.tree = tree;
			dp.obj = obj;

			wind_scroll( &draw_g, (-(WORD) add_len) * xi->charW, TRUE,
						&dp, whdl, _draw);
			}
		else	{
			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			}

		/* Zeilenzeiger der folgenden Zeilen anpassen */
		/* ------------------------------------------ */

		li++;
		while((li < xi->lines+xi->lvis) && (li->line))
			{
			li->line += add_len;
			li++;
			}
		}

	else	{

		/* 2. Fall: neue Zeile(n) eingefÅgt */
		/* -------------------------------- */

		only_crlf = ((*data == '\r') && (add_len == 2));

		/* hat sich Cursorzeile geÑndert? */
		/* ------------------------------ */

		if	(only_crlf)
			{
			len = li->len - xi->ccurs_x;		/* soviel ist weg */
			old_lextra = li->lextra;
			li->lextra = 2;		/* "harter" Return */
			}
		else	init_lines(xi);

		if	((!only_crlf) || (len > 0))
			{
			if	(only_crlf)
				li->len -= len;

			/* Redraw der Zeile */
			/* ---------------- */

			objc_wdraw(tree, obj, 0, &draw_g, whdl);
			}

		/* Alle Zeilenzeiger unterhalb der */
		/* aktuellen Zeile korrigieren	*/
		/* ------------------------------- */

		scroll_lines = xi->lvis - xi->ccurs_y - 1;
		if	(scroll_lines)
			{
			if	(only_crlf)
				{
				if	(scroll_lines > 1)
					{
					memmove(li+2,
						li+1,
						(scroll_lines-1) *
							sizeof(struct _xed_li));
					}
				li++;
				li->line = s;
				li->len = len;		/* neue LÑnge */
				li->lextra = old_lextra;
				li++;

				while((li < xi->lines+xi->lvis) && (li->line))
					{
					li->line += 2;
					li++;
					}
				if	(xi->leff < xi->lvis)
					xi->leff++;
				}

			/* Redraw: Alle Zeilen unterhalb der	*/
			/* neuen Zeile nach unten verschieben	*/
			/* ------------------------------------ */

			dp.tree = tree;
			dp.obj = obj;

			draw_g = *obj_g;
			draw_g.g_h = scroll_lines * xi->charH;
			draw_g.g_y += (xi->ccurs_y + 1) * xi->charH;

			wind_scroll( &draw_g, -nlines_ins*(xi->charH), FALSE,
						&dp, whdl, _draw);
			}
		}

	return(1);
}


/***************************************************************
*
* Tastatur-Eingaberoutine fÅrs USERDEF
*
* noch: Del zurÅckfÅhren auf Block lîschen
* Zeicheneingabe zurÅckfÅhren auf Block einfÅgen
*
***************************************************************/

static WORD key_xeditob( OBJECT *tree, WORD obj, WORD whdl, WORD key,
				WORD kbsh, XEDITINFO *xi, LONG *errcode )
{
	OBJECT *t;
	GRECT obj_g;
	struct _xed_li *li;		/* Cursorzeile */
	unsigned char *s,*bp;
	LONG len;
	unsigned char kbuf[2];
	int hdl;
	WORD pcursth_x = -1;



	*errcode = -1L;		/* kein spez. Fehler */
	if	(!xi->lines)
		return(0);
	objc_offset(tree, obj, &obj_g.g_x, &obj_g.g_y);
	t = tree+obj;
	obj_g.g_w = t->ob_width;
	obj_g.g_h = t->ob_height;
	edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */

	if	(xi->tcurs)	/* Cursor muû umgesetzt werden */
		vscroll_to(tree, obj, &obj_g, whdl, xi, xi->tcurs);
	li = xi->lines + xi->ccurs_y;

#if	DEBUG1
	printf("cx: %d cy: %d tcurs = %ld\n",
			xi->ccurs_x, xi->ccurs_y, xi->tcurs);
#endif


	/* Ctrl-Cursor runter/hoch */
	/* ----------------------- */

	if	((key == 0x4800) && (kbsh & K_CTRL))
		{
		if	(scroll_down(tree, obj, &obj_g, whdl, xi, 1))
			{
			ctrl_cursor_ud:
			pcursth_x = xi->pcursth_x;
			goto cursor;
			}
		}
	else
	if	((key == 0x5000) && (kbsh & K_CTRL))
		{
		if	(scroll_up(tree, obj, &obj_g, whdl, xi, 1))
			goto ctrl_cursor_ud;
		}

	switch(key)
		{
		case 0x011b:	/* Esc */
		break;

		/* BackSpace */
		/* --------- */

		case 0x0e08:
		if	(xi->bsel)
			goto delete;
		if	(xi->ccurs_x)
			xi->ccurs_x--;
		else	{
			if	(!xi->ccurs_y)
				{
				if	(!scroll_down(tree, obj, &obj_g, whdl, xi, 1))
					break;
				li = xi->lines + xi->ccurs_y;
				}
			else	{
				xi->ccurs_y--;
				li--;
				}
			xi->ccurs_x = (WORD) li->len;
			}
		init_pcursor(xi);
		hscroll(tree, obj, &obj_g, xi, whdl);	/* Cursor sichtbar! */
		goto delete;

		/* Cursor links */
		/* ------------ */

		case 0x4b00:
		if	(xi->bsel)
			goto	hoch_sel;

cursor_links:
		if	(xi->ccurs_x)
			xi->ccurs_x--;
		else	{
			if	(xi->ccurs_y)
				{
				xi->ccurs_y--;
				li--;
				xi->ccurs_x = (WORD) li->len;
				}
			else	{
				if	(li->line > xi->buf)
					{
					xi->pcursth_x = 32767;
					goto cursor_up;
					}
				}
			}
		init_pcursor(xi);
		hscroll(tree, obj, &obj_g, xi, whdl);	/* Cursor sichtbar! */
		break;

		/* SH- Cursor links */
		/* ---------------- */

		case 0x4b34:
		xi->ccurs_x = 0;
		goto cursor2;

		/* CTRL- Cursor links */
		/* ------------------ */

		case 0x7300:

		/* Am Zeilenanfang wie Cursor links */

		if	(!xi->ccurs_x)
			goto cursor_links;

		/* Ansonsten das vorherige Wort suchen */

		s = prev_word( li, xi->ccurs_x );
		xi->ccurs_x = (int) (s - li->line);
		goto cursor2;

		/* Cursor rechts */
		/* ------------- */

		case 0x4d00:
#if	DEBUG
	printf("pcursth_x = %d  ccurs_x = %d\n",
			xi->pcursth_x, xi->ccurs_x);
#endif
		if	(xi->bsel)
			goto	runter_sel;
cursor_rechts:
		if	(xi->ccurs_x < li->len)
			xi->ccurs_x++;
		else	{
			if	(xi->ccurs_y < xi->lvis-1)
				{
				li++;
				if	(li->line)
					{
					xi->ccurs_y++;
					xi->ccurs_x = 0;
					}
				}
			else	{
				if	((li->line) && (li->lextra))
					{
					xi->ccurs_x = 0;
					xi->pcursth_x = -1;
					goto cursor_down;
					}
				}
			}
		goto cursor2;

		/* SH- Cursor rechts */
		/* ----------------- */

		case 0x4d36:
		xi->ccurs_x = (int) li->len;
		goto cursor2;

		/* CTRL- Cursor rechts */
		/* ------------------- */

		case 0x7400:
		/* Am Zeilenende wie Cursor rechts */

		if	(xi->ccurs_x >= li->len)
			goto cursor_rechts;

		/* Ansonsten das nÑchste Wort suchen */

		s = next_word( li, xi->ccurs_x, TRUE );
		xi->ccurs_x = (int) (s - li->line);
		goto cursor2;

		/* Home */
		/* ---- */

		case 0x4700:
		if	(xi->bsel)
			goto hoch_sel;
		vscroll_to(tree, obj, &obj_g, whdl, xi, xi->buf);
		xi->ccurs_x = xi->ccurs_y = 0;	/* Cursor links oben */
		goto cursor2;

		/* Ende (nur MF-2)     */
		/* Ende (Macintosh)    */
		/* SH- Clr/Home (alle) */
		/* ------------------- */

		case 0x3700:
		case 0x4f00:
		case 0x4737:
		if	(xi->bsel)
			goto runter_sel;
		vscroll_to(tree, obj, &obj_g, whdl, xi, xi->buf+xi->curr_tlen);
		xi->ccurs_y = xi->leff-1;	/* letzte sichtbare Zeile */
		xi->ccurs_x = (WORD) xi->lines[xi->leff-1].len;	/* letztes Zeichen */
		goto cursor2;

		/* Cursor hoch */
		/* ----------- */

		case 0x4800:
		pcursth_x = xi->pcursth_x;
		if	(xi->bsel)
			{
hoch_sel:
			vscroll_to(tree, obj, &obj_g, whdl, xi, xi->bsel);
unsel:
			unsel_xeditob( xi, &obj_g, whdl );
			edit_cursor_on(&obj_g, xi, whdl);
			break;
			}
cursor_up:
		if	(xi->ccurs_y > 0)
			{
			xi->ccurs_y--;
			li--;
			goto cursor;
			}
		else	{
			if	(scroll_down(tree, obj, &obj_g, whdl, xi, 1))
				goto cursor;
			}
		break;
		

		/* Cursor runter */
		/* ------------- */

		case 0x5000:
		pcursth_x = xi->pcursth_x;
		if	(xi->bsel)
			{
runter_sel:
			vscroll_to(tree, obj, &obj_g, whdl, xi, xi->esel);
			goto unsel;
			}
cursor_down:
		if	(xi->ccurs_y < xi->lvis-1)
			{
			li++;
			if	(li->line)
				{
				xi->ccurs_y++;
cursor:
				xi->ccurs_x = pixpos_to_npos( xi, li->line,
										li->len,
										xi->pcursth_x );
#if	DEBUG
	printf("pcursth_x = %d  ccurs_x = %d\n",
			xi->pcursth_x, xi->ccurs_x);
#endif
				if	(xi->ccurs_x > li->len)
					xi->ccurs_x = (int) li->len;
cursor2:
				init_pcursor(xi);		/* Cursor versetzen */
				if	(pcursth_x >= 0)
					xi->pcursth_x = pcursth_x;
				hscroll(tree, obj, &obj_g, xi, whdl);	/* Cursor sichtbar! */
				}
			}
		else	{
			if	(scroll_up(tree, obj, &obj_g, whdl, xi, 1))
				goto cursor;
			}
		break;

		/* Bild hoch (Macintosh) */
		/* SH-Cursor up */
		/* ------------ */

		case 0x4900:
		case 0x4838:
		pcursth_x = xi->pcursth_x;
/*
		if	(xi->bsel)
			goto	hoch_sel;
*/
		if	(scroll_down(tree, obj, &obj_g, whdl, xi, xi->lvis))
			goto cursor;
		break;

		/* Bild runter (Macintosh) */
		/* SH-Cursor dwn */
		/* ------------- */

		case 0x5100:
		case 0x5032:
		pcursth_x = xi->pcursth_x;
/*
		if	(xi->bsel)
			goto	runter_sel;
*/
		if	(scroll_up(tree, obj, &obj_g, whdl, xi, xi->lvis))
			goto cursor;
		break;

		/* Entf (Delete) */
		/* ------------- */

		case 0x537f:
		delete:
		if	(xi->bsel)
			{
			del_range( tree, obj, &obj_g, whdl, xi,
					xi->bsel, xi->esel, NULL);
			edit_cursor_on(&obj_g, xi, whdl);
			}
		else	{
			s = li->line + xi->ccurs_x;
			if	(xi->ccurs_x < li->len)
				len = 1L;		/* nur ein Zeichen entfernen */
			else	len = li->lextra;	/* Zeilenende entfernen */
			if	(len)
				del_range( tree, obj, &obj_g, whdl, xi,
						s, s+len, li);
			}
		break;

		case 0x531f:	/* ^Del */
		break;

		case 0x5200:	/* Einfg */
		break;

		case 0x5230:	/* SH-Einfg */
		break;

		/* ^A */
		/* -- */

		case 0x1e01:
		sel_new_xeditob( xi, &obj_g, whdl,
			xi->buf, xi->buf + xi->curr_tlen );
		if	(xi->bsel)
			edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */
		break;

		/* ^Y */
		/* -- */

		case 0x2c19:
		if	(!xi->bsel)
			{
			sel_new_xeditob( xi, &obj_g, whdl,
				li->line, li->line + li->len + li->lextra );
			if	(xi->bsel)
				edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */
			}
		key = 0x2d18;		/* wie ^X */
		goto ctrl_x;

		/* ^X */
		/* ^C */
		/* -- */

		case 0x2d18:	/* ^X */
		case 0x2e03:	/* ^C */

		ctrl_x:
		if	(xi->bsel)
			{
			hdl = open_scrap(MO_CREAT+MO_RDWR+MO_TRUNC);
			if	(hdl >= 0)
				{
				Fwrite(hdl, xi->esel-xi->bsel, xi->bsel);
				Fclose(hdl);
				}

			if	(key == 0x2d18)	/* ^X */
				{
				del_range( tree, obj, &obj_g, whdl, xi,
					xi->bsel, xi->esel, NULL);
				li = xi->lines + xi->ccurs_y;
				edit_cursor_on(&obj_g, xi, whdl);
				}
			}
		break;

		/* ^V */
		/* -- */

		case 0x2f16:
		if	(xi->bsel)
			{
			del_range( tree, obj, &obj_g, whdl, xi,
					xi->bsel, xi->esel, NULL);
			li = xi->lines + xi->ccurs_y;
			edit_cursor_on(&obj_g, xi, whdl);
			}
		hdl = open_scrap(MO_RDONLY);
		if	(hdl >= 0)
			{
			XATTR xa;
			long ret;
			unsigned char *nbuf;


			ret = Fcntl(hdl, (long) (&xa), FSTAT);
			if	(ret >= 0)
				{
				nbuf = Malloc(xa.size+1);
				if	(nbuf)
					{
					ret = Fread(hdl, xa.size, nbuf);
					if	(ret == xa.size)
						{
						s = li->line+xi->ccurs_x;
						if	(ins_range(tree, obj, &obj_g, whdl, xi,
							nbuf, xa.size, li))
							vscroll_to(tree, obj, &obj_g, whdl, xi,
							s + xa.size);
						else	*errcode = EDITERR_BUFFER_FULL;
						}
					Mfree(nbuf);
					}
				}
			Fclose(hdl);
			}
		break;

		/* Zeichen */
		/* ------- */

		default:

		if	(!(key & 0xff))		/* kein Zeichen!! */
			break;

		if	(xi->bsel)
			{
			del_range( tree, obj, &obj_g, whdl, xi,
					xi->bsel, xi->esel, NULL);
			li = xi->lines + xi->ccurs_y;
			edit_cursor_on(&obj_g, xi, whdl);
			}

		s = li->line + xi->ccurs_x;
		kbuf[0] = (unsigned char) key;
		bp = kbuf+1;
		if	((key & 0xff) == 0x0d)
			{
			kbuf[1] = '\n';
			bp++;
			}
		if	(ins_range(tree, obj, &obj_g, whdl, xi,
					kbuf, bp-kbuf, li))
			{
			if	(xi->autowrap)
				{

/*
Cconws("vscroll_to: ");Fwrite(1, 10L, s + (bp-kbuf));Cconws("\r\n");
*/
				vscroll_to(tree, obj, &obj_g, whdl, xi,
						s + (bp-kbuf));
				}
			else	{
				if	((key & 0xff) == 0x0d)
					{
					li = xi->lines + xi->ccurs_y;	/* li restaurieren */
					xi->ccurs_x = 0;	/* Cursor an Zeilenanfang */
					init_pcursor(xi);		/* Cursor versetzen */
					goto cursor_down;	/* ... und nach unten */
					}
				else	{
					xi->ccurs_x++;
					goto cursor2;
					}
				}
			}
		else	*errcode = EDITERR_BUFFER_FULL;

		break;
	}

	edit_cursor_on(&obj_g, xi, whdl);
#if	DEBUG2
	printf("\x1b""H""Scrollpos: %3ld von %3ld\n",
			xi->yscroll, xi->nlines);
#endif
	*errcode = E_OK;		/* kein Fehler */
	return(1);
}


/***************************************************************
*
* Mausklick in Zeile/Spalte umrechnen.
*
* RÅckgabe:	0	innerhalb des Objekts, bei clickx/clicky
*				Absolut: (xi->lines[clicky]->line)+clickx
*		Bits:
*			1	oberhalb
*			2	unterhalb
*			4	links	ggf. ist clicky gÅltig
*			8	rechts	ggf. ist clicky gÅltig
*
***************************************************************/

static int mxmy2cxcy(int mx, int my, GRECT *obj_g,
				XEDITINFO *xi,
				WORD *clicky, WORD *clickx)
{
	struct _xed_li *li;
	int ret = 0;
	int cy;


	*clicky = -1;		/* erstmal ungÅltig */
	cy = (my - obj_g->g_y) / xi->charH;		/* Zeilennummer */
	if	(cy < 0)
		ret |= 1;					/* oberhalb */
	else	{
		if	(cy < xi->lvis)
			{
			li = xi->lines+cy;
			if	(li->line)
				{
				*clicky = cy;		/* clicky ist gÅltig */
				if	((mx >= obj_g->g_x) && (mx < obj_g->g_x+obj_g->g_w))
					{
					*clickx = mx - obj_g->g_x + xi->xscroll;
					*clickx = pixpos_to_npos( xi,
									li->line, li->len, *clickx );
					}
				}
			else	ret |= 2;			/* unterhalb */
			}
		else	ret |= 2;				/* unterhalb */
		}

	if	(mx < obj_g->g_x)
		ret |= 4;		/* links */
	else
	if	(mx >= obj_g->g_x+obj_g->g_w)
		ret |= 8;		/* rechts */

/*
printf("ret = %d\n", ret);
*/

	return(ret);
}


/***************************************************************
*
* Mausbutton-Behandlungsroutine fÅrs USERDEF
*
***************************************************************/

static WORD button_xeditob( OBJECT *tree, WORD obj, WORD whdl,
				EVNTDATA *ev, WORD nclicks,
				XEDITINFO *xi )
{
	int mwhich;
	int timer,xtimer;
	OBJECT *t;
	GRECT obj_g;
	struct _xed_li *li;
	WORD clicky,clickx;
	EVNTDATA ev2;
	GRECT mg;
	int ret,dummy;
	unsigned char *bsel,*new_esel,*new_bsel;
/*
	struct _draw_param dp;
*/



	if	(!xi->lines)
		return(0);

	/* Objekt-Rechteck bestimmen */
	/* ------------------------- */

	objc_offset(tree, obj, &obj_g.g_x, &obj_g.g_y);
	t = tree+obj;
	obj_g.g_w = t->ob_width;
	obj_g.g_h = t->ob_height;

	/* PrÅfen, ob der Mausklick in unser Objekt geht */
	/* --------------------------------------------- */

	if	(!xy_in_grect(ev->x, ev->y, &obj_g))
		return(0);		/* nicht in unser Objekt */

	/* Zeile und Spalte des Klicks bestimmen */
	/* ------------------------------------- */

	if	(mxmy2cxcy(ev->x, ev->y, &obj_g, xi, &clicky, &clickx))
		return(1);	/* ungÅltig */

	li = xi->lines+clicky;

	if	(!xi->bsel)
		edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */

	/* Einzelner Klick					*/
	/* ------------------------------------ */

	if	(nclicks == 1)
		{
		if	(!(ev->kstate & (K_LSHIFT+K_RSHIFT)))
			unsel_xeditob( xi, &obj_g, whdl );

		graf_mkstate(&ev2.x, &ev2.y, &ev2.bstate, &ev2.kstate);
		if	(ev2.bstate & 1)
			{

			/*  noch gedrÅckt: Bereich */
			/* ----------------------- */

			mg.g_w = mg.g_h = 1;
			bsel = li->line+clickx;
			do	{

				mwhich = MU_BUTTON+MU_M1;

				timer = ev2.y - (obj_g.g_y + obj_g.g_h);
				if	(timer <= 0)
					timer = obj_g.g_y - ev2.y + 1;

				xtimer = ev2.x - (obj_g.g_x + obj_g.g_w);
				if	(xtimer <= 0)
					xtimer = obj_g.g_x - ev2.x + 1;

				if	(xtimer > timer)
					timer = xtimer;

				if	(timer > 0)
					{
					mwhich += MU_TIMER;
					if	(timer > 16)
						timer = 16;
					timer = 16 - timer;
					if	(xtimer > 0)
						{
						}
					else	{
						timer *= 200;
						timer /= 16;
						timer += 20;
						}
					}

				mg.g_x = ev2.x;
				mg.g_y = ev2.y;
				mwhich = evnt_multi(
						mwhich,
						1,1,0,		/* linke Mtaste loslassen */
						1,&mg,		/* Mauspos. verlassen */
						0,NULL,		/* kein 2. Mausrechteck */
						NULL,		/* keine Message */
						timer,		/* Autoscroll-Timer */
						&ev2,
						&dummy,		/* kreturn */
						&dummy		/* breturn */
						);

				if	(!(mwhich&MU_BUTTON))
					{
					ret = (mxmy2cxcy(ev2.x, ev2.y, &obj_g,
							xi, &clicky, &clickx));

					if	(clicky >= 0)
						li = xi->lines+clicky;
					else	li = NULL;

					if	(ret & 4)	/* links */
						{
						hscroll_lr(tree, obj, &obj_g,
								xi, whdl, -1);
						if	(li)
							{
							new_esel = li->line;
							goto new_sel;
							}
						}

					if	(ret & 8)	/* rechts */
						{
						hscroll_lr(tree, obj, &obj_g,
								xi, whdl, 1);
						if	(li)
							{
							new_esel = li->line+li->len;
							goto new_sel;
							}
						}

					if	(ret & 1)	/* oberhalb */
						{
						new_esel = xi->lines->line;
						scroll_down(tree, obj, &obj_g, whdl, xi, 1);
						goto new_sel;
						}

					if	(ret & 2)	/* unterhalb */
						{
						li = xi->lines+xi->lvis-1;
/*
if	(li->line)
	printf("line\n");
else	printf("no line\n");
*/
						if	(li->line)
							new_esel = li->line+li->len;
						else	new_esel = xi->buf+xi->curr_tlen;

/*
Cconws("new_esel-2 = ");
printf("%02x %02x %02x %02x\n", new_esel[-2], new_esel[-1], new_esel[0], new_esel[1]);
*/

						scroll_up(tree, obj, &obj_g, whdl, xi, 1);
						goto new_sel;
						}

					if	(!ret)
						{

						/* neue Selektion berechnen */
						/* ------------------------ */

						new_esel = xi->lines[clicky].line+clickx;
new_sel:
						if	(new_esel < bsel)
							{
							new_bsel = new_esel;
							new_esel = bsel;
							}
						else	new_bsel = bsel;

						/* Selektion verÑndern */
						/* ------------------- */

						sel_new_xeditob( xi, &obj_g, whdl,
								new_bsel, new_esel );
						}
					}
				}
			while(!(mwhich & MU_BUTTON));

			}
		else	{

			if	(ev->kstate & (K_LSHIFT+K_RSHIFT))
				{

				/* Shift-Klick: Selektion erweitern */
				/* -------------------------------- */

				if	(xi->bsel)
					bsel = xi->bsel;
				else	bsel = xi->lines[xi->ccurs_y].line+xi->ccurs_x;
				new_esel = li->line+clickx;
				if	(new_esel < bsel)
					{
					new_bsel = new_esel;
					new_esel = bsel;
					}
				else	new_bsel = bsel;

				/* Selektion verÑndern */
				/* ------------------- */

				sel_new_xeditob( xi, &obj_g, whdl,
						new_bsel, new_esel );
				}
			else	{
				xi->ccurs_x = clickx;
				xi->ccurs_y = clicky;
				init_pcursor(xi);
				}
			}
		}
	else

	/* Doppelklick: Wort selektieren */
	/* ----------------------------- */

	if	(nclicks == 2)
		{

		/* Vorhandene Selektion lîschen */
		/* ---------------------------- */

		unsel_xeditob( xi, &obj_g, whdl );

		xi->bsel = prev_word( li, clickx+1 );
		xi->esel = next_word( li, clickx, FALSE );

		/* Neue Selektion */
		/* -------------- */

		sel_xeditob( xi, &obj_g, whdl, xi->bsel, xi->esel );
		}

	if	(!xi->bsel)
		edit_cursor_on(&obj_g, xi, whdl);
	return(1);
}


/***************************************************************
*
* EVNT-Verarbeitung
*
***************************************************************/

WORD edit_evnt( OBJECT *tree, WORD obj, WORD whdl, EVNT *ev,
				XEDITINFO *xi, LONG *errcode )
{
	WORD ret;
	WORD res = 1;
	LONG key_err;


	*errcode = E_OK;		/* kein Fehler */
	if	(ev->mwhich & MU_KEYBD)
		{
		ret = key_xeditob( tree, obj, whdl, ev->key,
				ev->kstate, xi, &key_err );
		if	(!ret)
			{
			res = 0;
			*errcode = key_err;
			}
		ev->mwhich &= ~MU_KEYBD;
		}
	if	(ev->mwhich & MU_BUTTON)
		{
		ret = button_xeditob( tree, obj, whdl,
				(EVNTDATA *) &(ev->mx), ev->mclicks, xi );
		if	(!ret)
			{
			res = 0;
			if	(!(*errcode))
				*errcode = -1L;
			}
		else	ev->mwhich &= ~MU_BUTTON;
		}
	return(res);
}


/***************************************************************
*
* Cursorposition ermitteln/setzen
*
***************************************************************/

unsigned char *edit_get_cursor( XEDITINFO *xi )
{
	if	(xi->tcurs)
		return(xi->tcurs);
	else	return(xi->lines[xi->ccurs_y].line+xi->ccurs_x);
}

WORD edit_set_cursor( OBJECT *tree, WORD obj, WORD whdl,
				XEDITINFO *xi, unsigned char *s )
{
	unsigned char *curr;
	OBJECT *t;
	GRECT obj_g;


	curr = edit_get_cursor(xi);
	if	(curr == s)
		return(1);
	if	((s < xi->buf) || (s > xi->buf+xi->curr_tlen))
		return(0);

	objc_offset(tree, obj, &obj_g.g_x, &obj_g.g_y);
	t = tree+obj;
	obj_g.g_w = t->ob_width;
	obj_g.g_h = t->ob_height;
	edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */

	vscroll_to(tree, obj, &obj_g, whdl, xi, s);
	init_pcursor(xi);		/* Cursor versetzen */
	hscroll(tree, obj, &obj_g, xi, whdl);	/* Cursor sichtbar! */

	edit_cursor_on(&obj_g, xi, whdl);
	return(1);
}


/***************************************************************
*
* Setzt xscroll und yscroll absolut.
*
***************************************************************/

WORD edit_scroll(OBJECT *tree, WORD obj,
				WORD whdl, XEDITINFO *xi,
				LONG yscroll, WORD xscroll)
{
	WORD diffcols;
	long difflines;
	GRECT obj_g;
	OBJECT *t;
	struct _draw_param dp;
	GRECT draw_g;
	WORD dl;
	WORD pcursth_x = -1;
	struct _xed_li *li;		/* Cursorzeile */


	if	(!xi->lines)
		return(0);

	objc_offset(tree, obj, &obj_g.g_x, &obj_g.g_y);
	t = tree+obj;
	obj_g.g_w = t->ob_width;
	obj_g.g_h = t->ob_height;
	dp.tree = tree;
	dp.obj = obj;

	edit_cursor_off(&obj_g, xi, whdl);	/* Cursor aus */

	if	(xscroll >= 0)
		{
		diffcols = xscroll - xi->xscroll;

		if	(diffcols)
			{
			xi->xscroll = xscroll;
			wind_scroll(&obj_g, diffcols, TRUE, &dp, whdl, _draw);
			}
		}

	if	((yscroll >= 0) && (yscroll < xi->nlines))
		{
		difflines = _lnum_yscroll( xi, yscroll);

		if	(difflines)
			{
			/* Scrolling */
			/* --------- */
	
			draw_g = obj_g;
			draw_g.g_h = xi->lvis * xi->charH;
			dl = (difflines > 32000) ? 32000 : (WORD) difflines;
			wind_scroll( &draw_g, dl * (xi->charH), FALSE,
					&dp, whdl, _draw);
			xi->yscroll += difflines;
	
			pcursth_x = xi->pcursth_x;
			li = xi->lines + xi->ccurs_y;
			xi->ccurs_x = pixpos_to_npos( xi, li->line,
									li->len,
									xi->pcursth_x );
			if	(xi->ccurs_x > li->len)
				xi->ccurs_x = (int) li->len;
			init_pcursor(xi);		/* Cursor versetzen */
			if	(pcursth_x >= 0)
				xi->pcursth_x = pcursth_x;
			hscroll(tree, obj, &obj_g, xi, whdl);	/* Cursor sichtbar! */
			}
		}
	edit_cursor_on(&obj_g, xi, whdl);
	return(1);
}
