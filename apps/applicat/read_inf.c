/*
*
* EnthÑlt die Routinen zum Einlesen der INF-Datei
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
#include "inf.h"
#include "read_inf.h"
#include "de/applicat.h"
#include "appldata.h"
#include "anw_dial.h"					/* wegen d_anw */
#include "ica_dial.h"					/* wegen d_ica */
#include "icp_dial.h"					/* wegen d_icp */
#include "pth_dial.h"					/* wegen d_pth */
#include "spc_dial.h"					/* wegen d_spc */
#include "typ_dial.h"					/* wegen d_typ */

#define DEBUG 0
#define LBUFLEN 128

/*
 * local variables
 */
static char *inf_buf;
static char *cpos;						/* Position innerhalb der Datei */
static char *lpos;						/* Position innerhalb der Zeile */

static char line[LBUFLEN];
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
* Liest eine Fensterposition aus APPLICAT.INF
*
* Die Zeile hat dieses Format:
* 	WINDOW <IDENTIFICATION> x,y,w,h
*
*********************************************************************/

static void get_wind_pos(const char *s)
{
	WINDEFPOS *w;

	if (n_windefpos >= MAXWINDEFPOS)
		return;

	w = windefpos + n_windefpos;
	sscanf(s, "WINDOW %s %d,%d,%d,%d", w->name, &(w->g.g_x), &(w->g.g_y), &(w->g.g_w), &(w->g.g_h));

	/* compatibility conversion */
	if (strcmp(w->name, "ANW_ANMELDEN") == 0)
		strcpy(w->name, IDENT_REGISTER_APP);
	else if (strcmp(w->name, "PFAD_ANMELDEN") == 0)
		strcpy(w->name, IDENT_REGISTER_PATH);
	else if (strcmp(w->name, "DATEITYP_EDIT") == 0)
		strcpy(w->name, IDENT_EDIT_FILE_TYPE);

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
* Gibt das <n>-te Icon der Datei fname zurÅck, d.h. dessen ID
* -1 bei Fehler
*
*********************************************************************/

static int get_icon(const char *fname, int n)
{
	int i;

	/* backward compatibility */
	if (!strcmp(fname, "<intern>"))
	{
		fname = RSC_FNAME_INTERN;
	}

	for (i = 0; i < rscn; i++)
	{
		if (stricmp(rscx[i].fname, fname) == 0)
		{
			if (n >= rscx[i].nicons)
				return -1;			/* Fehler ! */
			return rscx[i].firsticon + n;
		}
	}

	return -1;
}


/*********************************************************************
*
* global: LÑdt alle externen Icons in den Speicher
*
*********************************************************************/

void load_icons(void)
{
	int i;
	char fname[MAX_PATHLEN];
	long errcode;
	struct icon *ic;
	OBJECT *ob;
	int objnr;
	DTA mydta;
	int rscglobal[5];

	strcpy(fname, "rsc\\12345678901234567890");
	save_rscdata(systemglobal);			/* System-RSC merken */

	strcpy(rscx[0].fname, RSC_FNAME_INTERN);
	rscx[0].nicons = 7;					/* 8? */
	rscx[0].firsticon = 1;				/* 0? */
	/* LÑdt alle internen Icons in den Speicher */
	rsrc_gtree(T_DEFICN, &(rscx[0].adr_icons));

	ic = icnx;
	icnn = 0;
	
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
			spcx[i].iconnr = 3; /* I_DATEI */
	}

	for (i = 0; i < pgmn; i++)
	{
		pgmx[i].iconnr = get_icon(pgmx[i].rscname, pgmx[i].rscindex);
		if (pgmx[i].iconnr < 0)
		{
			pgmx[i].iconnr = get_deficonnr(ICON_KEY_APPS);
			if (!pgmx[i].iconnr)
				pgmx[i].iconnr = 2; /* I_PROGRA */
		}
	}

	for (i = 0; i < datn; i++)
	{
		datx[i].iconnr = get_icon(datx[i].rscname, datx[i].rscindex);
		if (datx[i].iconnr < 0)
		{
			datx[i].iconnr = get_deficonnr(ICON_KEY_DATS);
			if (!datx[i].iconnr)
				datx[i].iconnr = 3; /* I_DATEI */
		}
	}

	for (i = 0; i < pthn; i++)
	{
		pthx[i].iconnr = get_icon(pthx[i].rscname, pthx[i].rscindex);
		if (pthx[i].iconnr < 0)
		{
			pthx[i].iconnr = get_deficonnr(ICON_KEY_FLDR);
			if (!pthx[i].iconnr)
				pthx[i].iconnr = 1; /* I_ORDNER */
		}
	}

	restore_rscdata(systemglobal);		/* System-RSC zurÅck */
}


/****************************************************************
*
* Fehler-Alert fÅr APPLICAT.INF, mit variablem Text
*
* ALRT_ERR_IN_INF ist:
* "[3][Fehler auf APPLICAT.INF:|%s][Abbruch]"
*
* s hat maximal 127 Zeichen
*
****************************************************************/

static void serror(const char *s)
{
	char sbuf[512];
	char buf512[512 + 128];
	char *t;

	/* replace control characters "[]|%" in string to insert */
	strncpy(sbuf, s, sizeof(sbuf) - 1);
	sbuf[sizeof(sbuf) - 1] = '\0';
	t = sbuf;
	while (*t)
	{
		if (*t == '[' || *t == ']' /* || *t == '|' || *t == '%' */)
		{
			*t = '_';
		}
		t++;
	}
	
	/* merge alert template with variable text and show alert */
	sprintf(buf512, Rgetstring(ALRT_ERR_IN_INF, NULL), sbuf);
	form_alert(1, buf512);
}


/****************************************************************
*
* Fehler-Alert bei Dateioperation, ohne variablen Text
*
****************************************************************/
void error(int id)
{
	serror(Rgetstring(id, NULL));
}


/****************************************************************
*
* Entfernt rechtsbÅndige Leerstellen aus Zeichenkette
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

static int scanpath(char **lpos, char *buf, int len)
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
				return 1;
			if (*s == '\'' && (s[1] == '\''))	/* doppeltes ' */
				s++;
			*buf++ = *s++;
			len--;
		}

		if (!*s)
			return -1;					/* fehlendes ' */
		s++;
	} else
	{
		while (*s && ((*s != ' ')))
		{
			if (!len)
				return 1;
			*buf++ = *s++;
			len--;
		}
	}

	*lpos = s;
	*buf = EOS;
	return 0;
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
		return 1;						/* Fehler */

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
			return -1;					/* fehlendes ' */
		s++;
	} else
	{
		while (*s && ((*s != ']')))
		{
			*buf++ = *s++;
		}
	}

	if (*s != ']')
		return 1;						/* letztes Zeichen nicht ']' */

	*buf = EOS;
	return 0;
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
		return 1;						/* Fehler */

	if (*t == '\'')
	{
		if (scanpath(&t, s, MAX_NAMELEN))
			return 1;
	} else
	{
		while ((*t) && ((*t != ']')))
			*s++ = *t++;
	}

	if (*t != ']')
		return 1;						/* letztes Zeichen nicht ']' */
	return 0;
}
#endif


/****************************************************************
*
* Liest einen int, RÅckgabe 0 fÅr OK
*
****************************************************************/

static int scanint(char **lpos, int *val)
{
	long l;
	char *endptr;

	while (isspace(**lpos))
		(*lpos)++;
	if (**lpos != '-' && (**lpos < '0' || **lpos > '9'))
		return -1;

	l = strtol(*lpos, &endptr, 10);
	if (endptr == *lpos)
		return -1;						/* Fehler */

	*val = (int) l;
	return 0;
}


/****************************************************************
*
* Liest eine Zeile
*
****************************************************************/

static void readline(void)
{
	char *s;

	do
	{
		s = line;
		do
		{
			if (!*cpos)
			{
				error(STR_ERR_EOF_INF);
				exit(1);				/* Dateiende */
			}

			*s = *cpos++;				/* ein Zeichen */
			if (*s == '\r')
				continue;				/* CR Åberlesen */
			if (*s != '\n')
				s++;

			if ((s - line) > (LBUFLEN - 2))
			{
				error(STR_ERR_LEN_INF);
				exit(1);				/* ZeilenÅberlauf */
			}
		} while (*s != '\n');

		*s = EOS;
		trim(line);
#if DEBUG
		Cconws(line);
		Cconws("\r\n");
#endif
	} while (line[0] == ';');				/* Kommentar */

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
* Convert special file key to localised string
*
****************************************************************/

static void key2name(char *name, long key)
{
	int rsc_index;

	/*
	 * Pure-C cannot handle switch on long values
	 */
	if (key == ICON_KEY_APPS)
		rsc_index = STR_APPS;
	else if (key == ICON_KEY_DATS)
		rsc_index = STR_DATS;
	else if (key == ICON_KEY_BTCH)
		rsc_index = STR_BTCH;
	else if (key == ICON_KEY_DEVC)
		rsc_index = STR_DEVC;
	else if (key == ICON_KEY_ALIS)
		rsc_index = STR_ALIS;
	else if (key == ICON_KEY_FLDR)
		rsc_index = STR_FLDR;
	else if (key == ICON_KEY_DRVS)
		rsc_index = STR_DRVS;
	else if (key == ICON_KEY_TRSH)
		rsc_index = STR_TRSH;
	else if (key == ICON_KEY_PRNT)
		rsc_index = STR_PRNT;
	else
		return;

	strcpy(name, Rgetstring(rsc_index, NULL));
}


/****************************************************************
*
* Helper: read lines and return error code
*
****************************************************************/

static int _read_inf(void)
{
	int ver;
	char group[100];
	char iconname[128];

	/* read first line: header section */
	readline();
	if (getgroup(group) || strncmp(group, "APPLICAT Header V", 17) != 0)
	{
		/* Fehler im Header */
		return STR_ERR_HEAD_INF;
	}
	lpos += 17 + 1; /* getgroup() does not advance lpos */

	/* check for file version number */
	if (scanint(&lpos, &ver) < 0 || ver != 0)
	{
		return STR_ERR_VERSION;
	}

	/* old_w/h is the screen size when the .INF file was written */
	old_w = scrg.g_w;
	old_h = scrg.g_h;
	rreadline();
	if (!strncmp(line, "SCREENSIZE ", 11))
	{
		sscanf(line, "SCREENSIZE %d,%d", &old_w, &old_h);
		rreadline();
	}

	/* read all stored window positions */
	while (!strncmp(line, "WINDOW ", 7))
	{
		get_wind_pos(line);
		rreadline();
	}

	/*
	 * Main loop. Reads the remaining of the .INF file
	 */
	while (strncmp(line, "[End]", 5))
	{
		/* skip blank lines */
		if (!line[0])
		{
			readline();
			continue;
		}

		/* we expect a section like "[bla]", otherwise error */
		if (getgroup(group))
		{
			return STR_ERR_FORMAT;
		}

		/* section: directories with registered icons */
		if (!strcmp(group, SECTION_PATHS) || !strcmp(group, "<Pfade>"))
		{
			/* loop until next section */
			readline();
			while (line[0] != '[')
			{
				if (pthn >= MAX_PTHN)
				{
					return ALRT_OVERFLOW;
				}
				if (scanpath(&lpos, pthx[pthn].path, MAX_PATHLEN))
				{
					return STR_ERR_FORMAT;
				}
				if (scanpath(&lpos, pthx[pthn].rscname, MAX_NAMELEN))
				{
					return STR_ERR_FORMAT;
				}

				if (scanint(&lpos, &pthx[pthn].rscindex))
				{
					return STR_ERR_FORMAT;
				}

				if (scanpath(&lpos, iconname, (int)sizeof(iconname)))
				{
					return STR_ERR_FORMAT;
				}

				readline();
				pthn++;
			}
			continue;
		}

		/* section: icons for batch file, printer, dustbin etc. */
		if (!strcmp(group, SECTION_SPECIAL) || !strcmp(group, "<Spezial>"))
		{
			/* loop until next section */
			readline();
			while (line[0] != '[')
			{
				/* key: APPS,DATS,BTCH,DEVC,ALIS,FLDR,DRVS,TRSH,PRNT */
				if (spcn >= MAX_SPCN)
				{
					return ALRT_OVERFLOW;
				}
				if (scanpath(&lpos, (char *) &(spcx[spcn].key), 4))
				{
					return STR_ERR_FORMAT;
				}
				if (scanpath(&lpos, spcx[spcn].name, MAX_NAMELEN))
				{
					return STR_ERR_FORMAT;
				}
				/* With 1.01, we localize the name */
				key2name(spcx[spcn].name, spcx[spcn].key);

				if (scanpath(&lpos, spcx[spcn].rscname, MAX_NAMELEN))
				{
					return STR_ERR_FORMAT;
				}
				if (scanint(&lpos, &spcx[spcn].rscindex))
				{
					return STR_ERR_FORMAT;
				}
				if (scanpath(&lpos, iconname, (int)sizeof(iconname)))
				{
					return STR_ERR_FORMAT;
				}
				readline();
				spcn++;
			}
			continue;
		}

		/* All other sections must be applications */
		/* --------------------------------------- */

		/* backward compatibility */
		if (!strcmp(group, "<frei>"))
		{
			strcpy(group, APP_NAME_FREE);
		}
		if (pgmn >= MAX_PGMN)
		{
			return ALRT_OVERFLOW;
		}
		strcpy(pgmx[pgmn].name, group);
		readline();
		/* The first line defines the icon */
		if (line[0])
		{
			if (scanpath(&lpos, pgmx[pgmn].rscname, MAX_NAMELEN))
			{
				return STR_ERR_FORMAT;
			}
			if (scanint(&lpos, &pgmx[pgmn].rscindex))
			{
				return STR_ERR_FORMAT;
			}
			if (scanpath(&lpos, iconname, (int)sizeof(iconname)))
			{
				return STR_ERR_FORMAT;
			}
		}
		readline();

		/* The second line defines the program path */
		if (scanpath(&lpos, pgmx[pgmn].path, MAX_PATHLEN))
		{
			return STR_ERR_FORMAT;
		}

		/* The third line is an integer value, a bitmask */
		readline();
		if (scanint(&lpos, &pgmx[pgmn].config))
		{
			return STR_ERR_FORMAT;
		}

		/* This LIMITMEM line is optional */
		rreadline();
		if (!strncmp(line, "LIMITMEM=", 9))
		{
			pgmx[pgmn].memlimit = atol(line + 9);
			rreadline();
		}

		/* loop through all associated file types for this application */
		/* loop ends not before next section */

		pgmx[pgmn].types = -1;			/* Ende der Verkettung */
		pgmx[pgmn].ntypes = 0;			/* Anzahl Dateitypen */
		while (line[0] != '[')
		{
			/* Dateityp suchen */
			int i;

			if (datn >= MAX_DATN || linn >= MAX_LINN)
			{
				return ALRT_OVERFLOW;
			}
			if (scanpath(&lpos, datx[datn].name, MAX_NAMELEN))
			{
				return STR_ERR_FORMAT;
			}
			if (scanpath(&lpos, datx[datn].rscname, MAX_NAMELEN))
			{
				return STR_ERR_FORMAT;
			}
			if (scanint(&lpos, &datx[datn].rscindex))
			{
				return STR_ERR_FORMAT;
			}
			if (scanpath(&lpos, iconname, (int)sizeof(iconname)))
			{
				return STR_ERR_FORMAT;
			}

			for (i = 0; i < datn; i++)
			{
				if (!stricmp(datx[datn].name, datx[i].name))
				{
					return STR_ERR_MULTITYP;			/* schon verkettet */
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

		/* special case: no file types associated */
		if (pgmx[pgmn].ntypes == 0)
		{
			linx[linn].pgmnr = pgmn;
			linx[linn].reldatnr = -1;
			linx[linn].datnr = -1;
			linn++;
		}
		pgmn++;
	}

	return 0;
}


/****************************************************************
*
* global: Liest die Textdatei "applicat.inf"
*
****************************************************************/

long get_inf(void)
{
	long ret;
	int hdl;
	XATTR xa;
	int rsc_id_err;

	/* check, if file exists, and get file size */
	ret = Fxattr(0, applicat_inf, &xa);
	if (ret < E_OK)
	{
		form_xerr(ret, applicat_inf);
		return ret;
	}

	/* allocate space for whole file plus one byte more */
	if (NULL == (inf_buf = Malloc(xa.st_size + 1)))
	{
		form_xerr(ENSMEM, NULL);
		return ENSMEM;
	}

	/* open and read entire file */
	ret = Fopen(applicat_inf, O_RDONLY);
	if (ret >= 0)
	{
		hdl = (int) ret;
		ret = Fread(hdl, xa.st_size, inf_buf);
		Fclose(hdl);
	}

	/* open or read error */
	if (ret < E_OK)
	{
		Mfree(inf_buf);
		inf_buf = NULL;
		form_xerr(ret, applicat_inf);
		return ret;
	}

	/* add NUL byte to buffer for string handling */
	inf_buf[ret] = EOS;
	cpos = inf_buf;						/* Leseposition: Dateianfang */

	rsc_id_err = _read_inf();
	if (rsc_id_err)
	{
		char s[LBUFLEN + 64];

		if (rsc_id_err == ALRT_OVERFLOW)
		{
			Rform_alert(1, ALRT_OVERFLOW, NULL);
		} else
		{
			error(rsc_id_err);
			/* "Zeile: |" */
			strcpy(s, Rgetstring(STR_LINE, NULL));
			strcat(s, line);
			serror(s);
		}
	}

	Mfree(inf_buf);
	inf_buf = NULL;
	return rsc_id_err;
}
