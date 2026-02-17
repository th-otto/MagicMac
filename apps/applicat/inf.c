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
#include "inf.h"
#include "de/applicat.h"
#include "appldata.h"
#include "anw_dial.h"					/* wegen d_anw */
#include "ica_dial.h"					/* wegen d_ica */
#include "icp_dial.h"					/* wegen d_icp */
#include "pth_dial.h"					/* wegen d_pth */
#include "spc_dial.h"					/* wegen d_spc */
#include "typ_dial.h"					/* wegen d_typ */

#define WBUFLEN 8000L


/*
 * local variables
 */

static char const applicat_dat[] = "applicat.dat";

/*
 * global variables
 */
char const applicat_inf[] = "applicat.inf";
int n_windefpos = 0;
WINDEFPOS windefpos[MAXWINDEFPOS];


/****************************************************************
*
* Write string or flush the write buffer
*
* wbuf	write buffer
* *wlen	current number of characters in write buffer
* s		string to write, or NULL to flush the write buffer
*
****************************************************************/

static long iwrite(int hdl, char *wbuf, long *wlen, const char *s)
{
	long ret, len;

	if (s)
		len = strlen(s);
	else
		len = 0;

	if (s && (len < (WBUFLEN - *wlen)))
	{
		/* there is enough space in the write buffer */
		strcat(wbuf, s);
		*wlen += len;
	} else
	{
		ret = Fwrite(hdl, *wlen, wbuf);
		if (ret < 0)
		{
			error(STR_ERR_WR_INF);
			return ret;
		}

		if (ret != *wlen)
		{
			error(STR_ERR_FULL_INF);
			return ERROR;
		}

		if (s)
			strcpy(wbuf, s);

		*wlen = len;
	}

	return E_OK;
}


/****************************************************************
*
* Wandelt einen Pfad in die externe Darstellung mit
* Hochkommata um, falls dies notwendig ist.
*
* RÅckgabe 1: öberlauf
*
****************************************************************/

static int path_2_arg(const char *path, char *buf, int len)
{
	char *hoch;

	hoch = strchr(path, ' ');
	if (hoch)
	{
		if (!(--len))
			return -1;
		*buf++ = '\'';
	}

	while (*path)
	{
		if (*path == '\'')
		{
			if (!(--len))
				return -1;
			*buf++ = '\'';
		}

		if (!(--len))
			return -1;
		*buf++ = *path++;
	}

	if (hoch)
	{
		if (!(--len))
			return -1;
		*buf++ = '\'';
	}

	*buf = EOS;
	return 0;
}


/*********************************************************************
*
* global: Ermittelt bzw. setzt eine Fensterposition.
*
*********************************************************************/

WINDEFPOS *def_wind_pos(const char *s)
{
	WINDEFPOS *w;
	int i;

	for (i = 0, w = windefpos; i < n_windefpos; i++, w++)
	{
		if (!strcmp(w->name, s))
			return w;
	}

	return NULL;
}


/****************************************************************
*
* Ermittelt TabellenlÑngen
*
* Wenn <m_used> != NULL, wird in *m_used eine Tabelle
* zurÅckgegeben, die fÅr jedes benutzte Icon eine 1 enthÑlt.
*
****************************************************************/

static void get_len(long *npg, long *nd, long *npt, long *ns, long *ni, char **m_used)
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

	/* Anzahl Spezial-Icons */
	/* -------------------- */

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
* Ermittelt Icon-Daten
*
****************************************************************/

static void calc_ic(int icn, int *o, char **rnam, char **inam)
{
	struct iconfile *rscf;
	OBJECT *obj;
	ICONBLK *icb;

	rscf = rscx + icnx[icn].rscfile;
	/* Resourcedatei fÅr Programm-Icon */
	*rnam = rscf->fname;
	/* Iconnummer innerhalb der Ressource */
	*o = icn - rscf->firsticon;		/* Achtung: fÅhrt wohl zu -1 bei I_FLPDSK! */
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
* Icon-Daten:
*	action = 0:	LÑnge bestimmen
*	action = 1:	Daten sichern
*
* ic		Tabelle der Icon-Nummern (int)
* cb		hier kommen die Zeiger auf die CICONBLKs rein.
*
****************************************************************/

static long put_icondata(int action, int n_icn, int *ic, CICONBLK **cb, char *data, long offset)
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
			exit(1);
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
	return all_len;
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
		return 1;						/* '*'-lose Typen nach vorn */
	if ((e1->daname[0] != '*') && (e2->daname[0] == '*'))
		return -1;
	return stricmp(e1->daname, e2->daname);
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

static long put_icons(void)
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


	/* LÑnge der Zeichenketten bestimmen */
	/* --------------------------------- */

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
		return ENSMEM;
	ic = Malloc(h.n_icn * sizeof(int));	/* interne Icon-Nummern */
	for (i = 0, curr_ic = ic, buf = used_icons; i < icnn; i++, buf++)
	{
		if (*buf)
			*curr_ic++ = i;
	}
	Mfree(used_icons);

	/* LÑnge der Icon-Daten bestimmen */
	/* ------------------------------ */

	all_iconlen = put_icondata(0, (int) h.n_icn, ic, NULL, NULL, 0L);

	/* Speicher allozieren und Tabellen zuweisen */
	/* ----------------------------------------- */

	all_len = sizeof(struct ico_head) +
		all_slen +
		h.n_ap2ic * sizeof(struct ico_ap) +
		h.n_da2ic * sizeof(struct ico_dat) +
		h.n_pa2ic * sizeof(struct ico_path) +
		h.n_sp2ic * sizeof(struct ico_spec) +
		h.n_icn * sizeof(CICONBLK *) + all_iconlen;

	buf = Malloc(all_len);
	if (!buf || !ic)
		return ENSMEM;

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

	/* Spezial-Icons anlegen */
	/* --------------------- */

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
			return ERROR;
		}
	}

	/* alles schreiben */
	/* --------------- */

	ret = Fcreate(applicat_dat, 0);
	if (ret < 0L)
		return ret;
	hdl = (int) ret;

	ret = Fwrite(hdl, all_len, buf);
	Mfree(buf);
	Fclose(hdl);

	if (ret < E_OK)
		return ret;

	if (ret != all_len)
	{
		Fdelete(applicat_dat);
		error(STR_ERR_FULL_INF);
	}

	return E_OK;
}


/****************************************************************
*
* global: Schreibt die Textdatei "applicat.inf".
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
	char buf512[512];
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
		w = def_wind_pos(IDENT_ICONS);
		if ((!w) && (n_windefpos < MAXWINDEFPOS))
		{
			w = windefpos + n_windefpos;	/* freien Eintrag suchen */
			strcpy(w->name, IDENT_ICONS);
			n_windefpos++;
		}

		if (w)
			w->g = mywindow->out;
	}

	/* INF-Datei erstellen */
	/* ------------------- */

	wbuf = Malloc(WBUFLEN);
	if (!wbuf)
		return ENSMEM;
	wlen = 0L;		/* Schreibpuffer ist leer */
	*wbuf = EOS;
	ret = Fcreate(fname, 0);
	if (ret < E_OK)
	{
		Mfree(wbuf);
		form_xerr(ret, fname);
		return ret;
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
		return ret;
	}

	/* Fensterpositionen schreiben */
	/* --------------------------- */

	sprintf(buf512, "SCREENSIZE %d,%d\r\n", scrg.g_w, scrg.g_h);
	ret = iwrite(hdl, wbuf, &wlen, buf512);
	if (ret)
		goto err;
	for (i = 0, w = windefpos; i < n_windefpos; i++, w++)
	{
		sprintf(buf512, "WINDOW %s %d,%d,%d,%d\r\n", w->name,
				w->g.g_x - scrg.g_x, w->g.g_y - scrg.g_y, w->g.g_w, w->g.g_h);
		ret = iwrite(hdl, wbuf, &wlen, buf512);
		if (ret)
			goto err;
	}

	/* Tabellengrîûen ermitteln und schreiben */
	/* -------------------------------------- */

	get_len(&npg, &nd, &npt, &ns, &ni, NULL);

	sprintf(buf512, ";PROGRAMS = %ld of %d\r\n"
			";FILETYPES = %ld of %d\r\n"
			";PATHS = %ld of %d\r\n"
			";SPECS = %ld of %d\r\n"
			";ICONS = %ld of %d/%d\r\n",
			npg, MAX_PGMN,
			nd, MAX_DATN,
			npt, MAX_PTHN,
			ns, MAX_SPCN,
			ni, icnn, MAX_ICNN);

	ret = iwrite(hdl, wbuf, &wlen, buf512);
	if (ret)
		goto err;

	/* EintrÑge rausschreiben */
	/* ---------------------- */

	for (i = 0, z = linx; i < linn; )
	{
		/* Gruppe: Programmname */
		n = z->pgmnr;

		calc_ic(pgmx[n].iconnr, &o, &rnam, &inam);

		path_2_arg(pgmx[n].name, buf1, 150);
		path_2_arg(rnam, buf2, 50);
		path_2_arg(pgmx[n].path, buf3, 150);

		sprintf(buf512, "[%s]\r\n"
		        "%s %d \"%s\"\r\n"
		        "%s\r\n"
		        "%d\r\n",
		        buf1, buf2, o, inam, buf3, pgmx[n].config);
		ret = iwrite(hdl, wbuf, &wlen, buf512);
		if (ret)
			goto err;

		if (pgmx[n].memlimit)
		{
			sprintf(buf512, "LIMITMEM=%ld\r\n", pgmx[n].memlimit);
			ret = iwrite(hdl, wbuf, &wlen, buf512);
			if (ret)
				goto err;
		}

		/* angemeldete Dateitypen */
		while (i < linn && z->pgmnr == n)
		{
			if (z->datnr >= 0)
			{
				d = datx + z->datnr;

				calc_ic(d->iconnr, &o, &rnam, &inam);

				path_2_arg(d->name, buf1, 150);
				path_2_arg(rnam, buf2, 50);

				sprintf(buf512, "%s %s %d \"%s\"\r\n", buf1, buf2, o, inam);
				ret = iwrite(hdl, wbuf, &wlen, buf512);
				if (ret)
					goto err;
			}
			i++;
			z++;
		}
	}


	/* Pfade rausschreiben */
	/* ------------------- */

	ret = iwrite(hdl, wbuf, &wlen, "[" SECTION_PATHS "]\r\n");
	if (ret)
		goto err;
	for (i = 0; i < pthn; i++)
	{
		calc_ic(pthx[i].iconnr, &o, &rnam, &inam);

		path_2_arg(pthx[i].path, buf1, 150);
		path_2_arg(rnam, buf2, 50);

		sprintf(buf512, "%s %s %d \"%s\"\r\n", buf1, buf2, o, inam);
		ret = iwrite(hdl, wbuf, &wlen, buf512);
		if (ret)
			goto err;
	}


	/* Default-Icons rausschreiben */
	/* --------------------------- */

	ret = iwrite(hdl, wbuf, &wlen, "[" SECTION_SPECIAL "]\r\n");
	if (ret)
		goto err;
	for (i = 0; i < spcn; i++)
	{
		char val[5];

		/* FÅr I_FLPDSK wird o hier -1, falls es ein internes Icon ist. Unschîn. */
		calc_ic(spcx[i].iconnr, &o, &rnam, &inam);
		strncpy(val, (char *) &spcx[i].key, 4);
		val[4] = EOS;

		/* enclose in '', if necessary */
		path_2_arg(rnam, buf2, 50);
		path_2_arg(spcx[i].name, buf3, 50);

		sprintf(buf512, "%s %s %s %d \"%s\"\r\n", val, buf3, buf2, o, inam);
		ret = iwrite(hdl, wbuf, &wlen, buf512);
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
		ret = Fdelete(applicat_inf);
	if (!ret)
		ret = Frename(0, "applicat.$$$", applicat_inf);
	if (ret)
	{
		form_xerr(EWRITF, NULL);
		return ret;
	}

	put_icons();
	return ret;
}
