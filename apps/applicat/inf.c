/*
*
* EnthÑlt die Routinen zum Einlesen und Abspeichern der INF-
* Dateien
*
*/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "gemut_mt.h"
#include "toserror.h"
#include "country.h"
#include "windows.h"
#include "appl.h"
#include "applicat.h"
#include "appldata.h"
#include "anw_dial.h"					/* wegen d_anw */
#include "ica_dial.h"					/* wegen d_ica */
#include "icp_dial.h"					/* wegen d_icp */
#include "pth_dial.h"					/* wegen d_pth */
#include "spc_dial.h"					/* wegen d_spc */
#include "typ_dial.h"					/* wegen d_typ */

#define DEBUG 0
#define WBUFLEN 8000L

#define LBUFLEN 128
static char *inf_buf;
static char *cpos;						/* Position innerhalb der Datei */
static char *lpos;						/* Position innerhalb der Zeile */


long put_icons(void);
static char line[LBUFLEN];
int n_windefpos = 0;
WINDEFPOS windefpos[MAXWINDEFPOS];
static int old_w, old_h;				/* alte Bildschirmgrîûe */



/****************************************************************
*
* Merkt sich die Ressource-Informationen im global-Feld.
*
****************************************************************/

static int systemglobal[5];

static void save_rscdata(int *save)
{
	memcpy(save, _GemParBlk.global +5, 5 * sizeof(int));
}

static void restore_rscdata(int *save)
{
	memcpy(_GemParBlk.global +5, save, 5 * sizeof(int));
}


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgrîûe <old> abgespeichert, jetzt ist die
* Bildschirmgrîûe <new>.
*
****************************************************************/

static void recalc(int *wert, int old, int new)
{
	unsigned long tmp;

	tmp = (unsigned long) *wert;
	tmp *= new;
	tmp /= old;
	*wert = (int) tmp;
}


/*********************************************************************
*
* Ermittelt bzw. setzt eine Fensterposition.
*
*********************************************************************/

WINDEFPOS *def_wind_pos(char *s)
{
	WINDEFPOS *w;
	int i;

	for (i = 0, w = windefpos; i < n_windefpos; i++, w++)
	{
		if (!strcmp(w->name, s))
			return (w);
	}
	return (NULL);
}


/*********************************************************************
*
* Liest eine Fensterposition ein.
*
*********************************************************************/

static void put_wind_pos(char *s)
{
	WINDEFPOS *w;

	if (n_windefpos >= MAXWINDEFPOS)
		return;
	w = windefpos + n_windefpos;
	sscanf(s, "WINDOW %s %d,%d,%d,%d", &(w->name), &(w->g.g_x), &(w->g.g_y), &(w->g.g_w), &(w->g.g_h));
	if (old_w != scrg.g_w)
	{
		recalc(&(w->g.g_x), old_w, scrg.g_w);
		recalc(&(w->g.g_w), old_w, scrg.g_w);
	}
	if (old_h != scrg.g_h)
	{
		recalc(&(w->g.g_y), old_h, scrg.g_h);
		recalc(&(w->g.g_h), old_h, scrg.g_h);
	}
	w->g.g_x += scrg.g_x;
	w->g.g_y += scrg.g_y;
	n_windefpos++;
}


/*********************************************************************
*
* Gibt das <n>-te Icon der Datei fname zurÅck
*
*********************************************************************/

static int get_icon(char *fname, int n)
{
	int i;

	for (i = 0; i < rscn; i++)
		if (!stricmp(rscx[i].fname, fname))
		{
			if (n >= rscx[i].nicons)
				return (-1);			/* Fehler ! */
			return (rscx[i].firsticon + n);
		}
	return (-1);
}


/*********************************************************************
*
* LÑdt alle Icons in den Speicher
*
*********************************************************************/

void load_int_icons(void)
{
	rsrc_gtree(T_DEFICN, &(rscx[0].adr_icons));
}

void load_icons(void)
{
	int i;
	char *fname = "rsc\\12345678901234567890";
	long errcode;
	struct icon *ic;
	OBJECT *ob;
	int objnr;
	DTA mydta;
	int rscglobal[5];


	save_rscdata(systemglobal);			/* System-RSC merken */

	strcpy(rscx[0].fname, "<intern>");
	rscx[0].nicons = 7;
	rscx[0].firsticon = 1;

	ic = icnx;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_FLPDSK;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_ORDNER;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_PROGRA;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_DATEI;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_BTCHDA;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_PAPIER;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_DRUCKR;
	ic++;
	icnn++;
	ic->rscfile = 0;					/* internes Icon */
	ic->objnr = I_PAR;
	ic++;
	icnn++;


	rscn = 1;

	Fsetdta(&mydta);
	errcode = Fsfirst("rsc\\*.rsc", 0);
	for (; errcode == E_OK; errcode = Fsnext())
	{
		if (rscn >= MAX_RSCN)
		{
			save_rscdata(rscglobal);
			restore_rscdata(systemglobal);
			Rform_alert(1, ALRT_TOOMANY_RSC, NULL);
			restore_rscdata(rscglobal);
			break;
		}
		strcpy(fname + 4, mydta.d_fname);
		strcpy(rscx[rscn].fname, mydta.d_fname);
		if (!rsrc_load(fname))
		{
			form_xerr(EFILNF, fname);
			continue;
		}

		if (!rsrc_gaddr(R_TREE, 0, &rscx[rscn].adr_icons))
		{
			save_rscdata(rscglobal);
			restore_rscdata(systemglobal);
			Rform_alert(1, ALRT_FORMATICERR, NULL);
			restore_rscdata(rscglobal);
			continue;
		}

		rscx[rscn].nicons = 0;
		rscx[rscn].firsticon = icnn;
		objnr = rscx[rscn].adr_icons->ob_head;	/* erstes Kind */

		while (objnr > 0)				/* gÅltig und nicht parent */
		{
			ob = rscx[rscn].adr_icons + objnr;
			if ((ob->ob_type != G_ICON) && (ob->ob_type != G_CICON))
			{
				save_rscdata(rscglobal);
				restore_rscdata(systemglobal);
				Rform_alert(1, ALRT_FORMATICERR, NULL);
				restore_rscdata(rscglobal);
				break;
			}
			if (icnn >= MAX_ICNN)
			{
				save_rscdata(rscglobal);
				restore_rscdata(systemglobal);
				Rform_alert(1, ALRT_2MANY_ICONS, NULL);
				restore_rscdata(rscglobal);
				break;
			}
			ic->rscfile = rscn;
			ic->objnr = objnr;
			/* ic -> sel_pgm = ic -> sel_dat = FALSE */
			ic++;
			rscx[rscn].nicons++;		/* Anzahl in der Datei */
			icnn++;						/* Gesamtanzahl */
			objnr = ob->ob_next;
		}
		rscn++;
		if (icnn >= MAX_ICNN)
			break;
	}

	/* Icons umrechnen */
	/* --------------- */

	for (i = 0; i < spcn; i++)
	{
		spcx[i].iconnr = get_icon(spcx[i].rscname, spcx[i].rscindex);
		if (spcx[i].iconnr < 0)
			spcx[i].iconnr = 3;
	}

	for (i = 0; i < pgmn; i++)
	{
		pgmx[i].iconnr = get_icon(pgmx[i].rscname, pgmx[i].rscindex);
		if (pgmx[i].iconnr < 0)
		{
			pgmx[i].iconnr = get_deficonnr('APPS');
			if (!pgmx[i].iconnr)
				pgmx[i].iconnr = 2;
		}
	}

	for (i = 0; i < datn; i++)
	{
		datx[i].iconnr = get_icon(datx[i].rscname, datx[i].rscindex);
		if (datx[i].iconnr < 0)
		{
			datx[i].iconnr = get_deficonnr('DATS');
			if (!datx[i].iconnr)
				datx[i].iconnr = 3;
		}
	}

	for (i = 0; i < pthn; i++)
	{
		pthx[i].iconnr = get_icon(pthx[i].rscname, pthx[i].rscindex);
		if (pthx[i].iconnr < 0)
		{
			pthx[i].iconnr = get_deficonnr('FLDR');
			if (!pthx[i].iconnr)
				pthx[i].iconnr = 1;
		}
	}

	restore_rscdata(systemglobal);		/* System-RSC zurÅck */
}


/****************************************************************
*
* Fehler bei Dateioperation
*
****************************************************************/

static void serror(char *s)
{
	char buf[512];

	sprintf(buf, Rgetstring(ALRT_ERR_IN_INF, NULL), s);
	form_alert(1, buf);
}

static void error(int id)
{
	serror(Rgetstring(id, NULL));
}


/****************************************************************
*
* Zeichenkette schreiben
*
* wbuf	Schreibpuffer
* *wlen	Zeichen im Schreibpuffer
*
****************************************************************/

static long iwrite(int hdl, char *wbuf, long *wlen, char *s)
{
	long ret, len;

	if (s)
		len = strlen(s);
	else
		len = 0L;

	if (s && (len < (WBUFLEN - *wlen)))
	{
		strcat(wbuf, s);
		*wlen += len;
	} else
	{
		ret = Fwrite(hdl, *wlen, wbuf);
		if (ret < 0)
		{
			error(STR_ERR_WR_INF);
			return (ret);
		}
		if (ret != *wlen)
		{
			error(STR_ERR_FULL_INF);
			return (ERROR);
		}
		if (s)
			strcpy(wbuf, s);
		*wlen = len;
	}
	return (E_OK);
}


/****************************************************************
*
* Entfernt rechtsbÅndige Leerstellen aus <string>
*
****************************************************************/

static void trim(char *s)
{
	char *t;

	t = s + strlen(s) - 1;
	while ((t >= s) && isspace(*t))
	{
		*t = EOS;
		t--;
	}
}


/****************************************************************
*
* Liest einen Pfad mit max <len> Zeichen
*
* RÅckgabe 1: öberlauf
*
****************************************************************/

int scanpath(char **lpos, char *buf, int len)
{
	char *s;

	s = *lpos;
	while (isspace(*s))
		s++;
	if (*s == '\'')
	{
		s++;
		while (*s && ((*s != '\'') || (s[1] == '\'')))
		{
			if (!len)
				return (1);
			if (*s == '\'' && (s[1] == '\''))	/* doppeltes ' */
				s++;
			*buf++ = *s++;
			len--;
		}
		if (!*s)
			return (-1);				/* fehlendes ' */
		s++;
	} else
	{
		while (*s && ((*s != ' ')))
		{
			if (!len)
				return (1);
			*buf++ = *s++;
			len--;
		}
	}
	*lpos = s;
	*buf = EOS;
	return (0);
}


/****************************************************************
*
* Extrahiert die Zeichenkette s aus der Gruppe [s]
*
* Röckgabe TRUE, wenn Fehler
*
****************************************************************/

static int getgroup(char *buf)
{
	char *s;

	*buf = EOS;
	s = line;
	while (isspace(*s))					/* fÅhrende Leerstellen Åberlesen */
		s++;
	if (*s++ != '[')
		return (1);						/* Fehler */

	if (*s == '\'')
	{
		s++;
		while (*s && ((*s != '\'') || (s[1] == '\'')))
		{
			if (*s == '\'' && (s[1] == '\''))	/* doppeltes ' */
				s++;
			*buf++ = *s++;
		}
		if (!*s)
			return (-1);				/* fehlendes ' */
		s++;
	} else
	{
		while (*s && ((*s != ']')))
		{
			*buf++ = *s++;
		}
	}

	if (*s != ']')
		return (1);						/* letztes Zeichen nicht ']' */

	*buf = EOS;
	return (0);
}

#if 0
static int getgroup(char *s)
{
	char *t;

	*s = EOS;
	t = line;
	while (isspace(*t))					/* fÅhrende Leerstellen Åberlesen */
		t++;
	if (*t++ != '[')
		return (1);						/* Fehler */

	if (*t == '\'')
	{
		if (scanpath(&t, s, MAX_NAMELEN))
			return (1);
	} else
	{
		while ((*t) && ((*t != ']')))
			*s++ = *t++;
	}

	if (*t != ']')
		return (1);						/* letztes Zeichen nicht ']' */
	return (0);
}
#endif



/****************************************************************
*
* Wandelt einen Pfad in die externe Darstellung mit
* Hochkommata um, falls dies notwendig ist.
*
* RÅckgabe 1: öberlauf
*
****************************************************************/

int path_2_arg(char *path, char *buf, int len)
{
	char *hoch;

	hoch = strchr(path, ' ');
	if (hoch)
	{
		if (!(--len))
			return (-1);
		*buf++ = '\'';
	}

	while (*path)
	{
		if (*path == '\'')
		{
			if (!(--len))
				return (-1);
			*buf++ = '\'';
		}
		if (!(--len))
			return (-1);
		*buf++ = *path++;
	}

	if (hoch)
	{
		if (!(--len))
			return (-1);
		*buf++ = '\'';
	}
	*buf = EOS;
	return (0);
}


/****************************************************************
*
* Liest einen int
*
****************************************************************/

int scanint(char **lpos, int *val)
{
	long l;
	char *endptr;

	while (isspace(**lpos))
		(*lpos)++;
	if (**lpos != '-' && (**lpos < '0' || **lpos > '9'))
		return (-1);
	l = strtol(*lpos, &endptr, 10);
	if (endptr == *lpos)
		return (-1);					/* Fehler */
	*val = (int) l;
	return (0);
}


/****************************************************************
*
* Liest eine Zeile
*
****************************************************************/

static void readline(void)
{
	char *s;

  again:
	s = line;
	do
	{
		if (!*cpos)
		{
			error(STR_ERR_EOF_INF);
			exit(1);					/* Dateiende */
		}
		*s = *cpos++;					/* ein Zeichen */
		if (*s == '\r')
			continue;					/* CR Åberlesen */
		if (*s != '\n')
			s++;
		if ((s - line) > (LBUFLEN - 2))
		{
			error(STR_ERR_LEN_INF);
			exit(-1);					/* ZeilenÅberlauf */
		}
	}
	while (*s != '\n');
	*s = EOS;
	trim(line);
#if DEBUG
	Cconws(line);
	Cconws("\r\n");
#endif
	if (line[0] == ';')
		goto again;						/* Kommentar */
	lpos = line;
}


/****************************************************************
*
* Liest eine Nicht-Leerzeile
*
****************************************************************/

static void rreadline(void)
{
	do
		readline();
	while (!line[0]);
}


/****************************************************************
*
* Liest die Textdatei "applicat.inf".
*
****************************************************************/

long get_inf(void)
{
	long ret;
	int hdl;
	int ver;
	char group[100];
	char iconname[128];
	XATTR xa;
	char *fname = "applicat.inf";


	ret = Fxattr(0, "applicat.inf", &xa);
	if (ret < E_OK)
		goto err_open;
	if (NULL == (inf_buf = Malloc(xa.st_size + 1)))
	{
		form_xerr(ENSMEM, NULL);
		return (ENSMEM);
	}

	ret = Fopen(fname, O_RDONLY);
	if (ret < E_OK)
	{
	  err_open:
		if (inf_buf)
			Mfree(inf_buf);
		inf_buf = NULL;
		form_xerr(ret, fname);
		return (ret);
	}
	hdl = (int) ret;
	ret = Fread(hdl, xa.st_size, inf_buf);
	Fclose(hdl);
	if (ret < E_OK)
		goto err_open;
	inf_buf[ret] = EOS;
	cpos = inf_buf;						/* Leseposition: Dateianfang */

	readline();
	if (getgroup(group) || (1 != sscanf(group, "APPLICAT Header V %d", &ver)))
	{
		char s[512];

		error(STR_ERR_HEAD_INF);
	  err:
		strcpy(s, Rgetstring(STR_LINE, NULL));
		strcat(s, line);
		serror(s);
		if (inf_buf)
			Mfree(inf_buf);
		inf_buf = NULL;
		return (1);
	}

	if (ver != 0)
	{
		error(STR_ERR_VERSION);
		goto err;
	}

	old_w = scrg.g_w;
	old_h = scrg.g_h;
	rreadline();
	if (!strncmp(line, "SCREENSIZE ", 11))
	{
		sscanf(line, "SCREENSIZE %d,%d", &old_w, &old_h);
		rreadline();
	}

	while (!strncmp(line, "WINDOW ", 7))
	{
		put_wind_pos(line);
		rreadline();
	}

	while (strncmp(line, "[End]", 5))
	{
		if (!line[0])
		{
			readline();
			continue;
		}

		if (getgroup(group))
		{
		  erri:
			error(STR_ERR_FORMAT);
			goto err;
		}

		if (!strcmp(group, "<Pfade>"))
		{
			readline();
			while (line[0] != '[')
			{
				if (scanpath(&lpos, pthx[pthn].path, MAX_PATHLEN))
					goto erri;
				if (scanpath(&lpos, pthx[pthn].rscname, MAX_NAMELEN))
					goto erri;
				if (scanint(&lpos, &pthx[pthn].rscindex))
					goto erri;
				if (scanpath(&lpos, iconname, 128))
					goto erri;
				readline();
				pthn++;
			}
			continue;
		}

		if (!strcmp(group, "<Spezial>"))
		{
			readline();
			while (line[0] != '[')
			{
				if (scanpath(&lpos, (char *) &(spcx[spcn].key), 4))
					goto erri;
				if (scanpath(&lpos, spcx[spcn].name, MAX_NAMELEN))
					goto erri;
				if (scanpath(&lpos, spcx[spcn].rscname, MAX_NAMELEN))
					goto erri;
				if (scanint(&lpos, &spcx[spcn].rscindex))
					goto erri;
				if (scanpath(&lpos, iconname, 128))
					goto erri;
				readline();
				spcn++;
			}
			continue;
		}

		/* Applikation */
		/* ----------- */

		strcpy(pgmx[pgmn].name, group);
		readline();
		if (line[0])
		{
			if (scanpath(&lpos, pgmx[pgmn].rscname, MAX_NAMELEN))
				goto erri;
			if (scanint(&lpos, &pgmx[pgmn].rscindex))
				goto erri;
			if (scanpath(&lpos, iconname, 128))
				goto erri;
		}
		readline();

		if (scanpath(&lpos, pgmx[pgmn].path, 128))
			goto erri;

/*		strcpy(pgmx[pgmn].path, line);	*/
		readline();
		if (scanint(&lpos, &pgmx[pgmn].config))
		{
			error(STR_ERR_FORMAT);
			goto err;
		}
		rreadline();
		if (!strncmp(line, "LIMITMEM=", 9))
		{
			pgmx[pgmn].memlimit = atol(line + 9);
			rreadline();
		}
		pgmx[pgmn].types = -1;			/* Ende der Verkettung */
		pgmx[pgmn].ntypes = 0;			/* Anzahl Dateitypen */
		while (line[0] != '[')
		{
			/* Dateityp suchen */
			int i;

			if (scanpath(&lpos, datx[datn].name, MAX_NAMELEN))
				goto erri;
			if (scanpath(&lpos, datx[datn].rscname, MAX_NAMELEN))
				goto erri;
			if (scanint(&lpos, &datx[datn].rscindex))
				goto erri;
			if (scanpath(&lpos, iconname, 128))
				goto erri;

			for (i = 0; i < datn; i++)
			{
				if (!strcmp(datx[datn].name, datx[i].name))
				{
					error(STR_ERR_MULTITYP);
					goto err;			/* schon verkettet */
				}
				break;
			}
			/* vorn einketten */
			datx[datn].next = pgmx[pgmn].types;
			datx[datn].pgm = pgmn;
			pgmx[pgmn].types = datn;

			linx[linn].pgmnr = pgmn;
			linx[linn].reldatnr = pgmx[pgmn].ntypes;
			linx[linn].datnr = datn;
			linx[linn].selected = FALSE;
			datn++;
			linn++;

			pgmx[pgmn].ntypes++;

			rreadline();
		}

		if (pgmx[pgmn].ntypes == 0)
		{
			linx[linn].pgmnr = pgmn;
			linx[linn].reldatnr = -1;
			linx[linn].datnr = -1;
			linn++;
		}
		pgmn++;
	}

	Mfree(inf_buf);
	return (0);
}


/****************************************************************
*
* Ermittelt TabellenlÑngen
*
* Wenn <m_used> != NULL, wird in *m_used eine Tabelle
* zurÅckgegeben, die fÅr jedes benutzte Icon eine 1 enthÑlt.
*
****************************************************************/

void get_len(long *npg, long *nd, long *npt, long *ns, long *ni, char **m_used)
{
	struct pgm_file *pg;
	struct dat_file *d;
	struct pth_file *pt;
	struct spc_file *s;
	int i, n;
	char *used, *buf;

	if (m_used)
		*m_used = NULL;

	buf = Malloc(icnn);
	if (!buf)
	{
		form_xerr(ENSMEM, NULL);
		return;
	}
	memset(buf, 0, icnn);
	used = buf;

	/* Anzahl Applikationen */
	/* -------------------- */

	for (n = 0, i = 0, pg = pgmx; i < pgmn; i++, pg++)
	{
		if ((pg->name[0]) && (pg->name[0] != '<'))
		{
			n++;
			used[pg->iconnr] = TRUE;
		}
	}
	*npg = n;

	/* Anzahl Dateitypen */
	/* ----------------- */

	for (n = 0, i = 0, d = datx; i < datn; i++, d++)
	{
		if (d->name[0])
		{
			n++;
			used[d->iconnr] = TRUE;
		}
	}
	*nd = n;

	/* Anzahl Pfade */
	/* ------------ */

	for (i = 0, pt = pthx; i < pthn; i++, pt++)
	{
		used[pt->iconnr] = TRUE;
	}
	*npt = pthn;

	/* Anzahl Spezialicons */
	/* ------------------- */

	for (i = 0, s = spcx; i < spcn; i++, s++)
	{
		used[s->iconnr] = TRUE;
	}
	*ns = spcn;

	/* Anzahl benutzter Icons */
	/* ---------------------- */

	for (n = 0, i = 0; i < icnn; i++, used++)
	{
		if (*used)
			n++;
	}
	*ni = n;
	if (m_used)
		*m_used = buf;
	else
		Mfree(buf);
}


/****************************************************************
*
* Ermittelt Icondaten
*
****************************************************************/

void calc_ic(int icn, int *o, char **rnam, char **inam)
{
	struct iconfile *rscf;
	OBJECT *obj;
	ICONBLK *icb;

	rscf = rscx + icnx[icn].rscfile;
	/* Resourcedatei fÅr Programm-Icon */
	*rnam = rscf->fname;
	/* Iconnummer innerhalb der Ressource */
	*o = icn - rscf->firsticon;
	/* Name des Icons (dummy) */
	obj = rscf->adr_icons + icnx[icn].objnr;
	if (obj->ob_type == G_USERDEF)
		icb = (ICONBLK *) obj->ob_spec.userblk->ub_parm;
	else if ((obj->ob_type == G_ICON) || (obj->ob_type == G_CICON))
		icb = (ICONBLK *) obj->ob_spec.iconblk;
	*inam = icb->ib_ptext;
}


/****************************************************************
*
* Schreibt die Textdatei "applicat.inf".
*
****************************************************************/

long put_inf(void)
{
	long ret;
	struct dat_file *d;
	struct zeile *z;
	int i, n;
	long npg, nd, npt, ns, ni;
	char *wbuf;
	long wlen;
	char buf[512];
	char buf1[152];
	char buf2[50];
	char buf3[152];
	WINDEFPOS *w;
	char *rnam, *inam;
	int o;
	int hdl;
	char *fname = "applicat.$$$";

	/* x,y-Positionen aller offenen Dialoge sichern */
	/* -------------------------------------------- */

	if (d_anw)
		save_dialog_xy(d_anw);
	if (d_ica)
		save_dialog_xy(d_ica);
	if (d_icp)
		save_dialog_xy(d_icp);
	if (d_pth)
		save_dialog_xy(d_pth);
	if (d_spc)
		save_dialog_xy(d_spc);
	if (d_typ)
		save_dialog_xy(d_typ);
	if (mywindow)
	{
		w = def_wind_pos("ICONS");
		if ((!w) && (n_windefpos < MAXWINDEFPOS))
		{
			w = windefpos + n_windefpos;	/* freien Eintrag suchen */
			strcpy(w->name, "ICONS");
			n_windefpos++;
		}

		if (w)
			w->g = mywindow->out;
	}

	/* INF-Datei erstellen */
	/* ------------------- */

	wbuf = Malloc(WBUFLEN);
	if (!wbuf)
		return (ENSMEM);
	wlen = 0L;							/* Schreibpuffer ist leer */
	*wbuf = EOS;
	ret = Fcreate(fname, 0);
	if (ret < E_OK)
	{
		Mfree(buf);
		form_xerr(ret, fname);
		return (ret);
	}
	hdl = (int) ret;

	/* Header schreiben */
	/* ---------------- */

	ret = iwrite(hdl, wbuf, &wlen, "[APPLICAT Header V 0]\r\n");
	if (ret)
	{
	  err:
		Mfree(wbuf);
		Fclose(hdl);
		return (ret);
	}

	/* Fensterpositionen schreiben */
	/* --------------------------- */

	sprintf(buf, "SCREENSIZE %d,%d\r\n", scrg.g_w, scrg.g_h);
	ret = iwrite(hdl, wbuf, &wlen, buf);
	if (ret)
		goto err;
	for (i = 0, w = windefpos; i < n_windefpos; i++, w++)
	{
		sprintf(buf, "WINDOW %s %d,%d,%d,%d\r\n", w->name,
				w->g.g_x - scrg.g_x, w->g.g_y - scrg.g_y, w->g.g_w, w->g.g_h);
		ret = iwrite(hdl, wbuf, &wlen, buf);
		if (ret)
			goto err;
	}

	/* Tabellengrîûen ermitteln und schreiben */
	/* -------------------------------------- */

	get_len(&npg, &nd, &npt, &ns, &ni, NULL);

	sprintf(buf, ";PROGRAMS = %ld\r\n"
			";FILETYPES = %ld\r\n"
			";PATHS = %ld\r\n" ";SPECS = %ld\r\n" ";ICONS = %ld of %d\r\n", npg, nd, npt, ns, ni, icnn);

	ret = iwrite(hdl, wbuf, &wlen, buf);
	if (ret)
		goto err;

	/* EintrÑge erstellen */
	/* ------------------ */

	for (i = 0, z = linx; i < linn;)
	{
		/* Gruppe: Programmname */
		n = z->pgmnr;

		calc_ic(pgmx[n].iconnr, &o, &rnam, &inam);

		path_2_arg(pgmx[n].name, buf1, 150);
		path_2_arg(rnam, buf2, 50);
		path_2_arg(pgmx[n].path, buf3, 150);

		sprintf(buf, "[%s]\r\n" "%s %d \"%s\"\r\n" "%s\r\n" "%d\r\n", buf1, buf2, o, inam, buf3, pgmx[n].config);
		ret = iwrite(hdl, wbuf, &wlen, buf);
		if (ret)
			goto err;

		if (pgmx[n].memlimit)
		{
			sprintf(buf, "LIMITMEM=%ld\r\n", pgmx[n].memlimit);
			ret = iwrite(hdl, wbuf, &wlen, buf);
			if (ret)
				goto err;
		}
		/* angemeldete Dateitypen */
		while ((i < linn) && (z->pgmnr == n))
		{
			if (z->datnr >= 0)
			{
				d = datx + z->datnr;

				calc_ic(d->iconnr, &o, &rnam, &inam);

				path_2_arg(d->name, buf1, 150);
				path_2_arg(rnam, buf2, 50);

				sprintf(buf, "%s %s %d \"%s\"\r\n", buf1, buf2, o, inam);
				ret = iwrite(hdl, wbuf, &wlen, buf);
				if (ret)
					goto err;
			}
			i++;
			z++;
		}
	}


	/* Pfade erstellen */
	/* --------------- */

	ret = iwrite(hdl, wbuf, &wlen, "[<Pfade>]\r\n");
	if (ret)
		goto err;
	for (i = 0; i < pthn; i++)
	{
		calc_ic(pthx[i].iconnr, &o, &rnam, &inam);

		path_2_arg(pthx[i].path, buf1, 150);
		path_2_arg(rnam, buf2, 50);

		sprintf(buf, "%s %s %d \"%s\"\r\n", buf1, buf2, o, inam);
		ret = iwrite(hdl, wbuf, &wlen, buf);
		if (ret)
			goto err;
	}


	/* Defaulticons */
	/* ------------ */

	ret = iwrite(hdl, wbuf, &wlen, "[<Spezial>]\r\n");
	if (ret)
		goto err;
	for (i = 0; i < spcn; i++)
	{
		char val[5];

		calc_ic(spcx[i].iconnr, &o, &rnam, &inam);
		strncpy(val, (char *) &spcx[i].key, 4);
		val[4] = EOS;

		path_2_arg(rnam, buf2, 50);

		sprintf(buf, "%s %s %s %d \"%s\"\r\n", val, spcx[i].name, buf2, o, inam);
		ret = iwrite(hdl, wbuf, &wlen, buf);
		if (ret)
			goto err;
	}


	ret = iwrite(hdl, wbuf, &wlen, "[End]\r\n");
	if (ret)
		goto err;
	ret = iwrite(hdl, wbuf, &wlen, NULL);	/* flush buffer */
	if (ret)
		goto err;
	Mfree(wbuf);

	ret = Fclose(hdl);
	if (!ret)
		ret = Fdelete("applicat.inf");
	if (!ret)
		ret = Frename(0, "applicat.$$$", "applicat.inf");
	if (ret)
	{
		form_xerr(EWRITF, NULL);
		return (ret);
	}

	put_icons();
	return (ret);
}


/****************************************************************
*
* Icon-Daten:
*	action = 0:	LÑnge bestimmen
*	action = 1:	Daten sichern
*
* ic		Tabelle der Icon-Nummern (int)
* cb		hier kommen die Zeiger auf die CICONBLKs rein.
*
****************************************************************/

static long put_icondata(int action, int n_icn, int *ic, CICONBLK ** cb, char *data, long offset)
{
	int i;
	int n;
	int *curr_ic;
	CICONBLK ciblk;
	CICONBLK **curr_cb;
	CICON mycicon;
	CICON *cic, *cic2;
	struct icon *icn;
	OBJECT *o;
	long mono_len, slen;
	long all_len;


	all_len = 0L;
	for (i = 0, curr_ic = ic, curr_cb = cb; i < n_icn; i++, curr_ic++, curr_cb++)
	{
		if (data)
			*curr_cb = (CICONBLK *) (offset + all_len);
		icn = icnx + *curr_ic;
		o = rscx[icn->rscfile].adr_icons + icn->objnr;
		n = 0;
		switch (o->ob_type)
		{
		case G_ICON:
			ciblk.monoblk = *(o->ob_spec.iconblk);
			mono_len = (ciblk.monoblk.ib_wicon >> 3) * ciblk.monoblk.ib_hicon;
			cic = NULL;
			break;

		case G_CICON:
			ciblk = *((CICONBLK *) (o->ob_spec.index));
			mono_len = (ciblk.monoblk.ib_wicon >> 3) * ciblk.monoblk.ib_hicon;
			/* Anzahl Icons berechnen */
			cic = ciblk.mainlist;
			if (!cic)					/* bin in Monochrom-Auflîsung ? */
				cic = (CICON *) ((o->ob_spec.index) + sizeof(CICONBLK) + 2 * mono_len +	/* Mono-Icon */
								 12);	/* Text */
			if (cic == (void *) -1L)
			{
				cic = NULL;
				ciblk.mainlist = NULL;
			}
			cic2 = cic;
			while (cic2)
			{
				n++;
				cic2 = cic2->next_res;
			}
			break;
		default:
			exit(-1);
		}

		if (action)
		{
			/* CICONBLK schreiben */

			ciblk.mainlist = (CICON *) n;
			memcpy(data, &ciblk, sizeof(CICONBLK));
			data += sizeof(CICONBLK);

			/* Monochrom-Icon */
			memcpy(data, ciblk.monoblk.ib_pdata, mono_len);
			data += mono_len;
			/* Monochrom-Maske */
			memcpy(data, ciblk.monoblk.ib_pmask, mono_len);
			data += mono_len;
		}
		all_len += sizeof(CICONBLK) + mono_len + mono_len;

		/* Farbicons */
		while (cic)
		{
			slen = mono_len * cic->num_planes;
			if (action)
			{
				mycicon.num_planes = cic->num_planes;
				mycicon.col_data = mycicon.col_mask = (void *) 1L;
				if (cic->sel_data)
					mycicon.sel_data = mycicon.sel_mask = (void *) 1L;
				else
					mycicon.sel_data = mycicon.sel_mask = NULL;
				if (cic->next_res)
					mycicon.next_res = (CICON *) 1L;
				else
					mycicon.next_res = NULL;

				memcpy(data, &mycicon, sizeof(CICON));
				data += sizeof(CICON);

				memcpy(data, cic->col_data, slen);
				data += slen;

				memcpy(data, cic->col_mask, mono_len);
				data += mono_len;

				if (cic->sel_data)
				{
					memcpy(data, cic->sel_data, slen);
					data += slen;
					memcpy(data, cic->sel_mask, mono_len);
					data += mono_len;
				}
			}

			all_len += sizeof(CICON) + slen + mono_len;
			if (cic->sel_data)
				all_len += slen + mono_len;

			cic = cic->next_res;
		}
	}
	return (all_len);
}


/****************************************************************
*
* Sortiervergleich fÅr Dateitypen.
*
****************************************************************/

static int compare_ico_dat(const void *_e1, const void *_e2)
{
	const DATAFILE *e1 = (const DATAFILE *) _e1;
	const DATAFILE *e2 = (const DATAFILE *) _e2;

	if ((e1->daname[0] == '*') && (e2->daname[0] != '*'))
		return (1);						/* '*'-lose Typen nach vorn */
	if ((e1->daname[0] != '*') && (e2->daname[0] == '*'))
		return (-1);
	return (stricmp(e1->daname, e2->daname));
}


/****************************************************************
*
* Schreibt die Icondatei "applicat.dat".
*
* Dateiaufbau:
*	Header		struct ico_head	LÑnge = 1
*	Strings		char []			LÑnge = all_slen
*	APPs			struct ico_ap		LÑnge = h.n_ap2ic
*	DATs			struct ico_dat		LÑnge = h.n_da2ic
*	PATHs		struct ico_path	LÑnge = h.n_pa2ic
*	SPECs		struct ico_spec	LÑnge = h.n_sp2ic
*	Tabelle		CICONBLK **		LÑnge = h.n_icn;
*	Icondaten		char []			LÑnge = all_iconlen
*
****************************************************************/

long put_icons(void)
{
	int i, n;
	int hdl;
	long ret;
	struct ico_head h;
	char *all_strings;
	char *curr_string;

	int *ic, *curr_ic, *cci;
	struct zeile *z;

	struct ico_ap *app, *curr_app;
	struct ico_dat *dat, *curr_dat;
	struct ico_path *pth, *curr_pth;
	struct ico_spec *spc, *curr_spc;

	struct pgm_file *pgm_file;
	struct dat_file *dat_file;
	struct pth_file *pth_file;
	struct spc_file *spc_file;

	CICONBLK **cb;
	long slen, all_slen, all_iconlen, icon_offs, all_len;
	char *buf, *buf2;
	char *icondata;
	char *used_icons;
	XAESMSG xmsg;
	int msg[8];


	/* LÑnge der Strings bestimmen */
	/* --------------------------- */

	all_slen = 0;
	for (i = 0, pgm_file = pgmx; i < pgmn; i++, pgm_file++)
	{
		if (!pgm_file->name[0])
			continue;					/* leerer Eintrag */
		if (pgm_file->name[0] == '<')
			continue;					/* Dummy-Applikation */
		all_slen += strlen(pgm_file->name) + 1;
		if ((!pgm_file->path[0]) || (!pgm_file->ntypes))
			continue;					/* kein Pfad */
		all_slen += strlen(pgm_file->path) + 1;
	}
	for (i = 0, dat_file = datx; i < datn; i++, dat_file++)
	{
		if (!dat_file->name[0])
			continue;					/* leerer Eintrag */
		all_slen += strlen(dat_file->name) + 1;
	}
	for (i = 0, pth_file = pthx; i < pthn; i++, pth_file++)
	{
		all_slen += strlen(pth_file->path) + 1;
	}
	if (all_slen & 1)
		all_slen++;						/* gerade Adresse */

	/* Header anlegen und LÑnge der Tabellen bestimmen */
	/* ----------------------------------------------- */

	h.magic = 'AnKr';
	h.version = 0x0002L;
	get_len(&h.n_ap2ic, &h.n_da2ic, &h.n_pa2ic, &h.n_sp2ic, &h.n_icn, &used_icons);
	if (!used_icons)
		return (ENSMEM);
	ic = Malloc(h.n_icn * sizeof(int));	/* interne Icon-Nummern */
	for (i = 0, curr_ic = ic, buf = used_icons; i < icnn; i++, buf++)
	{
		if (*buf)
			*curr_ic++ = i;
	}
	Mfree(used_icons);

	/* LÑnge der Icondaten bestimmen */
	/* ----------------------------- */

	all_iconlen = put_icondata(0, (int) h.n_icn, ic, NULL, NULL, 0L);

	/* Speicher allozieren und Tabellen zuweisen */
	/* ----------------------------------------- */

	all_len = sizeof(struct ico_head) +
		all_slen +
		h.n_ap2ic * sizeof(struct ico_ap) +
		h.n_da2ic * sizeof(struct ico_dat) +
		h.n_pa2ic * sizeof(struct ico_path) +
		h.n_sp2ic * sizeof(struct ico_spec) + h.n_icn * sizeof(CICONBLK *) + all_iconlen;

	buf = Malloc(all_len);
	if (!buf || !ic)
		return (ENSMEM);

	slen = sizeof(struct ico_head);

	all_strings = buf + slen;
	slen += all_slen;

	h.p_ap2ic = slen;
	app = (struct ico_ap *) (buf + slen);
	slen += h.n_ap2ic * sizeof(struct ico_ap);

	h.p_da2ic = slen;
	dat = (struct ico_dat *) (buf + slen);
	slen += h.n_da2ic * sizeof(struct ico_dat);

	h.p_pa2ic = slen;
	pth = (struct ico_path *) (buf + slen);
	slen += h.n_pa2ic * sizeof(struct ico_path);

	h.p_sp2ic = slen;
	spc = (struct ico_spec *) (buf + slen);
	slen += h.n_sp2ic * sizeof(struct ico_spec);

	h.p_icn = slen;
	cb = (CICONBLK **) (buf + slen);
	slen += h.n_icn * sizeof(CICONBLK *);

	icon_offs = slen;
	icondata = buf + slen;
	memcpy(buf, &h, sizeof(struct ico_head));

	/* Applikationsnamen, Pfade und Dateitypen anlegen */
	/* ----------------------------------------------- */

	curr_app = app;
	curr_ic = ic;
	curr_dat = dat;
	curr_string = all_strings;
	for (i = 0, z = linx; i < linn;)
	{
		n = z->pgmnr;
		pgm_file = pgmx + n;

		if (pgm_file->name[0] != '<')
		{
			curr_app->config = pgm_file->config;
			curr_app->memlimit = pgm_file->memlimit;
			curr_app->apname = (long) curr_string;
			slen = strlen(pgm_file->name) + 1;
			memcpy(curr_string, pgm_file->name, slen);
			curr_string += slen;
			if ((pgm_file->path) && (pgm_file->path[0]) && (pgm_file->ntypes))
			{
				curr_app->path = (long) curr_string;
				slen = strlen(pgm_file->path) + 1;
				memcpy(curr_string, pgm_file->path, slen);
				curr_string += slen;
			} else
				curr_app->path = -1L;

			/* Icon suchen */
			for (cci = ic; cci < curr_ic; cci++)
			{
				if (*cci == pgm_file->iconnr)
					goto ok;
			}
			*curr_ic++ = pgm_file->iconnr;
		  ok:
			curr_app->icon_nr = cci - ic;
		}

		/* angemeldete Dateitypen */

		while ((i < linn) && (z->pgmnr == n))
		{
			if (z->datnr >= 0)
			{
				dat_file = datx + z->datnr;
				slen = strlen(dat_file->name) + 1;

				curr_dat->daname = (long) curr_string;
				if (pgm_file->name[0] != '<')
					curr_dat->ap = curr_app - app;	/* Index der AP */
				else
					curr_dat->ap = -1;	/* keine APP */
				memcpy(curr_string, dat_file->name, slen);
				curr_string += slen;

				/* Icon suchen */
				for (cci = ic; cci < curr_ic; cci++)
				{
					if (*cci == dat_file->iconnr)
						goto ok2;
				}
				*curr_ic++ = dat_file->iconnr;
			  ok2:
				curr_dat->icon_nr = cci - ic;

				curr_dat++;
			}
			i++;
			z++;
		}

		if (pgm_file->name[0] != '<')
			curr_app++;
	}

	/* angemeldete Pfade anlegen */
	/* ------------------------- */

	for (i = 0, curr_pth = pth, pth_file = pthx; i < pthn; i++, curr_pth++, pth_file++)
	{
		slen = strlen(pth_file->path) + 1;

		curr_pth->pathname = (long) curr_string;
		memcpy(curr_string, pth_file->path, slen);
		curr_string += slen;

		/* Icon suchen */
		for (cci = ic; cci < curr_ic; cci++)
		{
			if (*cci == pth_file->iconnr)
				goto ok3;
		}
		*curr_ic++ = pth_file->iconnr;
	  ok3:
		curr_pth->icon_nr = cci - ic;
	}

	/* Spezialicons anlegen */
	/* -------------------- */

	for (i = 0, curr_spc = spc, spc_file = spcx; i < spcn; i++, curr_spc++, spc_file++)
	{
		curr_spc->key = spc_file->key;
		/* Icon suchen */
		for (cci = ic; cci < curr_ic; cci++)
		{
			if (*cci == spc_file->iconnr)
				goto ok4;
		}
		*curr_ic++ = spc_file->iconnr;
	  ok4:
		curr_spc->icon_nr = cci - ic;
	}


	/* Die Datentypen mÅssen so sortiert werden, daû diejenigen,    */
	/* die '*' enthalten, vorn stehen. Wir machen aber gleich       */
	/* eine vollstÑndige Sortierung                         */
	/* ------------------------------------------------------------- */

	qsort(dat, h.n_da2ic, sizeof(struct ico_dat), compare_ico_dat);

	/* Zeiger in Offsets konvertieren */
	/* ------------------------------ */

	for (i = 0; i < h.n_ap2ic; i++)
	{
		app[i].apname += sizeof(struct ico_head) - (long) all_strings;
		if (app[i].path >= 0)
			app[i].path += sizeof(struct ico_head) - (long) all_strings;
	}
	for (i = 0; i < h.n_da2ic; i++)
		dat[i].daname += sizeof(struct ico_head) - (long) all_strings;
	for (i = 0; i < h.n_pa2ic; i++)
		pth[i].pathname += sizeof(struct ico_head) - (long) all_strings;

	/* Icons anlegen */
	/* ------------- */

	put_icondata(1, (int) h.n_icn, ic, cb, icondata, icon_offs);

	/* Kopie zum Abspeichern anlegen */
	/* ----------------------------- */

	buf2 = Malloc(all_len);

	/* Alles ans Desktop verschicken */
	/* ----------------------------- */

	if (buf2)
	{
		memcpy(buf2, buf, all_len);
		msg[0] = 'AK';
		msg[1] = ap_id;
		msg[2] = 0;
		msg[3] = 0;						/* Unterfunktion */
		msg[4] = msg[5] = 0;
		xmsg.dst_apid = 0;
		xmsg.unique_flg = FALSE;
		xmsg.attached_mem = buf2;
		xmsg.msgbuf = msg;
		if (0 >= appl_write(-2, 16, &xmsg))
		{
			Mfree(buf2);
			err_alert(ERROR);
			return (ERROR);
		}
	}

	/* alles schreiben */
	/* --------------- */

	ret = Fcreate("applicat.dat", 0);
	if (ret < 0L)
		return (ret);
	hdl = (int) ret;

	ret = Fwrite(hdl, all_len, buf);
	Mfree(buf);
	Fclose(hdl);

	if (ret < E_OK)
		return (ret);
	if (ret != all_len)
	{
		Fdelete("applicat.dat");
		error(STR_ERR_FULL_INF);
	}
	return (E_OK);
}
