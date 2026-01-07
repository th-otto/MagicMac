/*********************************************************************
*
* Dieses Modul enthÑlt das Laden und Abspeichern der Defaults
*
*********************************************************************/

#define  PGM_I_VERSION	1

#include <tos.h>
#include <toserror.h>
#include "k.h"
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include "kachel.h"
#include <wdlgfslx.h>


/****************************************************************
*
* globale Daten.
* inf_name[0] wird von get_syshdr auf das AES-Bootlaufwerk
* gesetzt.
* desk_path wird von get_rsrc gesetzt.
*
****************************************************************/

char inf_name[] = "A:\\MAGX.INF";
char desk_path[128];

char *apdatabuf = NULL;
long n_apps = 0L;						/* TabellenlÑnge */
APPLICATION *apps;						/* Tabelle */
CICONBLK *std_app_icon;

long n_dfiles = 0L;						/* TabellenlÑnge */
DATAFILE *dfiles;						/* Tabelle */
CICONBLK *std_dat_icon;

long n_paths = 0L;						/* TabellenlÑnge */
PATHNAME *paths;						/* Tabelle */
CICONBLK *std_fld_icon;					/* fÅr Ordner */

long n_specs = 0L;						/* TabellenlÑnge */
SPECIALOBJECT *specs;					/* Tabelle */

CICONBLK *std_dsk_icon;					/* fÅr Laufwerk */
CICONBLK *std_bat_icon;					/* fÅr Batchdatei */
CICONBLK *std_prt_icon;					/* fÅr Drucker */
CICONBLK *std_tra_icon;					/* fÅr Papierkorb */
CICONBLK *std_dev_icon;					/* fÅr Devices */
CICONBLK *std_par_icon;					/* fÅr Elter-Verzeichnis ".." */

static void set_deskt_icons(int initial);

/****************************************************************
*
* Liest die vom Hilfsprogramm APPLICAT erstellte Datei, die
* die angemeldeten Dateitypen sowie die Icons enthÑlt.
*
****************************************************************/

static void init_app_icons(void)
{
	static CICONBLK _stda;
	static CICONBLK _stdd;
	static CICONBLK _stfl;
	static CICONBLK _stbt;
	static CICONBLK _stdk;
	static CICONBLK _sttr;
	static CICONBLK _stdr;
	static CICONBLK _stdv;
	static CICONBLK _stpa;


	_stda.monoblk = *((adr_icons + I_PRO)->ob_spec.iconblk);
	_stda.mainlist = NULL;
	std_app_icon = &_stda;
	_stdd.monoblk = *((adr_icons + I_DAT)->ob_spec.iconblk);
	_stdd.mainlist = NULL;
	std_dat_icon = &_stdd;
	_stfl.monoblk = *((adr_icons + I_ORD)->ob_spec.iconblk);
	_stfl.mainlist = NULL;
	std_fld_icon = &_stfl;
	_stdk.monoblk = *((adr_icons + I_DSK)->ob_spec.iconblk);
	_stdk.mainlist = NULL;
	std_dsk_icon = &_stdk;
	_stbt.monoblk = *((adr_icons + I_BAT)->ob_spec.iconblk);
	_stbt.mainlist = NULL;
	std_bat_icon = &_stbt;
	_sttr.monoblk = *((adr_icons + I_PAP)->ob_spec.iconblk);
	_sttr.mainlist = NULL;
	std_tra_icon = &_sttr;
	_stdr.monoblk = *((adr_icons + I_DRK)->ob_spec.iconblk);
	_stdr.mainlist = NULL;
	std_prt_icon = &_stdr;
	_stdv.monoblk = *((adr_icons + I_DAT)->ob_spec.iconblk);
	_stdv.mainlist = NULL;
	std_dev_icon = &_stdv;
	_stpa.monoblk = *((adr_icons + I_PAR)->ob_spec.iconblk);
	_stpa.mainlist = NULL;
	std_par_icon = &_stpa;
}


static int _load_app_icons(char *buf)
{
	long n_icons = 0L;
	CICONBLK **icons;
	CICONBLK *stdci;
	struct ico_head *ich;
	long i, j;
	long flen;
	APPLICATION *ap;
	DATAFILE *da;
	PATHNAME *pa;
	SPECIALOBJECT *sp;
	struct
	{
		long magic;
		int subfn;
		int numicns;
		CICONBLK **cictab;
		char *data;
		char *endptr;
	} magic_rcfix;



	ich = (struct ico_head *) buf;
	if (ich->magic == 'BnKr')
	{
		dirty_applicat_dat = TRUE;
		ich->magic = 'AnKr';
	} else
		dirty_applicat_dat = FALSE;

	if ((ich->magic != 'AnKr') || (ich->version != 2))
	{
		Mfree(buf);
		return (-1);
	}

	init_app_icons();					/* immer erst Standard-Icons */
	if (apdatabuf)
	{
		Mfree(apdatabuf);
		n_apps = n_dfiles = n_paths = n_specs = 0L;
	}

	apdatabuf = buf;
	apps = (APPLICATION *) (buf + ich->p_ap2ic);
	n_apps = ich->n_ap2ic;
	dfiles = (DATAFILE *) (buf + ich->p_da2ic);
	n_dfiles = ich->n_da2ic;
	paths = (PATHNAME *) (buf + ich->p_pa2ic);
	n_paths = ich->n_pa2ic;
	specs = (SPECIALOBJECT *) (buf + ich->p_sp2ic);
	n_specs = ich->n_sp2ic;
	icons = (CICONBLK **) (buf + ich->p_icn);
	n_icons = ich->n_icn;


	/* Farbicons initialisieren */
	/* die werden dabei auch komprimiert */

	magic_rcfix.magic = 'MagC';
	magic_rcfix.subfn = 0;
	magic_rcfix.numicns = (int) n_icons;
	magic_rcfix.cictab = icons;
	magic_rcfix.data = (char *) icons;
	magic_rcfix.data += n_icons * sizeof(CICONBLK *);
	rsrc_rcfix((RSHDR *) & magic_rcfix);
	flen = magic_rcfix.endptr - buf;
	Mshrink(buf, flen);

	/* relozieren */

	for (i = 0, ap = apps; i < n_apps; i++, ap++)
	{
		ap->apname += (long) buf;
		if (((long) ap->path) >= 0L)
			ap->path += (long) buf;
		ap->icon = icons[(long) (ap->icon)];
	}
	for (i = 0, da = dfiles; i < n_dfiles; i++, da++)
	{
		da->daname += (long) buf;
		j = ((long) da->ap);			/* Index der APP */
		if (j != -1L)
			da->ap = apps + j;
		else
			da->ap = NULL;
		da->icon = icons[(long) (da->icon)];
	}
	for (i = 0, pa = paths; i < n_paths; i++, pa++)
	{
		pa->path += (long) buf;
		pa->icon = icons[(long) (pa->icon)];
	}
	for (i = 0, sp = specs; i < n_specs; i++, sp++)
	{
		sp->icon = icons[(long) (sp->icon)];
	}

	/* Standardicons festlegen */

	stdci = specialkey_to_iconblk('APPS');
	if (stdci)
		std_app_icon = stdci;
	stdci = specialkey_to_iconblk('DATS');
	if (stdci)
		std_dat_icon = stdci;
	stdci = specialkey_to_iconblk('FLDR');
	if (stdci)
		std_fld_icon = stdci;
	stdci = specialkey_to_iconblk('PARD');
	if (stdci)
		std_par_icon = stdci;
	stdci = specialkey_to_iconblk('DRVS');
	if (stdci)
	{
		std_dsk_icon = stdci;
		stdci->monoblk.ib_ptext = (adr_icons + I_DSK)->ob_spec.iconblk->ib_ptext;
	}
	stdci = specialkey_to_iconblk('TRSH');
	if (stdci)
	{
		stdci->monoblk.ib_ptext = (adr_icons + I_PAP)->ob_spec.iconblk->ib_ptext;
		std_tra_icon = stdci;
	}
	stdci = specialkey_to_iconblk('PRNT');
	if (stdci)
	{
		stdci->monoblk.ib_ptext = (adr_icons + I_DRK)->ob_spec.iconblk->ib_ptext;
		std_prt_icon = stdci;
	}
	stdci = specialkey_to_iconblk('BTCH');
	if (stdci)
	{
		stdci->monoblk.ib_ptext = (adr_icons + I_BAT)->ob_spec.iconblk->ib_ptext;
		std_bat_icon = stdci;
	}
	stdci = specialkey_to_iconblk('DEVC');
	if (stdci)
		std_dev_icon = stdci;

	return (0);
}


void load_app_icons(void)
{
	XATTR xa;
	char path[128];
	int fd;
	long flen;
	long retcode;
	char *buf;



	init_app_icons();					/* Standard-Icons */
	strcpy(path, desk_path);
	strcat(path, "applicat.dat");
	fd = (int) Fopen(path, O_RDONLY);
	if (fd < 0)
		return;							/* Datei nicht gefunden */
	retcode = Fcntl(fd, (long) &xa, FSTAT);
	if (!retcode)
		flen = xa.st_size;
	else
		goto err;

	buf = Malloc(flen);
	if (!buf)
	{
	  err:
		Fclose(fd);
		return;
	}

	retcode = Fread(fd, flen, buf);
	Fclose(fd);
	if (retcode != flen)
	{
		Mfree(buf);
		return;
	}

	_load_app_icons(buf);
}


/****************************************************************
*
* Wertet die Message aus, die von APPLICAT verschickt wird.
*
****************************************************************/

void re_read_icons(void *data)
{
	if (_load_app_icons(data))
		return;							/* Fehler */
	set_deskt_icons(FALSE);
	upd_icons();
	upd_wind(fenster[0]);
}


/****************************************************************
*
* Sucht in der Icondatei nach einer Applikation.
* fname ist der Programmname ohne Pfad. Die Programmnamen
* in der Icondatei liegen ohne Extension vor, es sind keine
* Wildcards zulÑssig.
* Groû-/Kleinschreibung wird ignoriert.
*
****************************************************************/

APPLICATION *find_application(char *fname)
{
	char *f;
	APPLICATION *a;
	int i;

	if (n_apps)
	{
		f = strrchr(fname, '.');
		if (f)
		{
			*f = EOS;					/* Extension entfernen */
			for (a = apps, i = 0; i < n_apps; i++, a++)
			{
				if (!stricmp(fname, a->apname))
				{
					*f = '.';
					return (a);
				}
			}
			*f = '.';
		}
	}
	return (NULL);
}


/****************************************************************
*
* Sucht in der Icondatei nach einer nicht ausfÅhrbaren Datei.
* fname ist der Dateiname ohne Pfad. Die Dateinamen
* in der Icondatei liegen in folgenden Formen vor:
*
*	exakter Name
*	*.ext
*
* ZunÑchst werden die exakten Namen ÅberprÅft, sie liegen in
* der Tabelle vorn.
* Groû-/Kleinschreibung wird ignoriert.
*
****************************************************************/

DATAFILE *find_datafile(char *fname)
{
	DATAFILE *da;
	char *extension;
	char *d;


	extension = strrchr(fname, '.');
	for (da = dfiles; da < dfiles + n_dfiles; da++)
	{
		d = da->daname;
		if ((d[0] == '*') && (extension))
		{
			if (!stricmp(extension, d + 1))
				return (da);
		} else
		{
			if (!stricmp(fname, d))
				return (da);
		}
	}
	return (NULL);
}

PATHNAME *find_path(char *path, char *nurname)
{
	PATHNAME *pa;
	int i;


	if (!nurname)
	{
		nurname = path + strlen(path) - 2;
		while ((nurname > path) && (*nurname != '\\'))
			nurname--;
		nurname++;
	}
	for (i = 0, pa = paths; i < n_paths; i++, pa++)
	{
		if (pa->path[1] == ':')			/* abs. Pfad */
		{
			if (!stricmp(path, pa->path))
				return (pa);
		} else
		{
			if (!stricmp(nurname, pa->path))
				return (pa);
		}
	}
	return (NULL);
}


/****************************************************************
*
* Sucht <fname> in der Icondatei.
* <fname> ist der Programmname ohne Pfad
*
* RÅckgabe:	Zeiger auf Iconblk.
*
****************************************************************/

CICONBLK *pgmname_to_iconblk(char *fname)
{
	APPLICATION *a;
	char *extension;

	a = find_application(fname);
	if (a)
		return (a->icon);
	extension = strrchr(fname, '.');
	if ((extension) && (!stricmp(extension, ".ACC") || !stricmp(extension, ".ACX")))
		return (datname_to_iconblk(fname));
	return (std_app_icon);
}


/****************************************************************
*
* Sucht <fname> in der Icondatei.
* <fname> ist der Dateiname ohne Pfad
*
* RÅckgabe:	Zeiger auf Iconblk.
*
****************************************************************/

CICONBLK *datname_to_iconblk(char *fname)
{
	DATAFILE *da;

	da = find_datafile(fname);
	if (da)
		return (da->icon);
	return (std_dat_icon);
}


/****************************************************************
*
* Sucht <path> in der Icondatei.
* <path> ist der volle Pfad mit abschlieûendem '\'
* <nurname> ist ggf. der Ordnername mit abschlieûendem '\'
*	oder NULL, dann wird er berechnet.
*
* RÅckgabe:	Zeiger auf Iconblk.
*
****************************************************************/

CICONBLK *diskname_to_iconblk(int diskname, char **name)
{
	char pth[4];

	pth[0] = diskname;
	pth[1] = ':';
	pth[2] = '\\';
	pth[3] = EOS;
	if (name)
		*name = std_dsk_icon->monoblk.ib_ptext;
	return (foldername_to_iconblk(pth, pth + 1));
}


CICONBLK *foldername_to_iconblk(char *path, char *nurname)
{
	PATHNAME *p;

	p = find_path(path, nurname);
	if (p)
		return (p->icon);
	if (path[3])
		return (std_fld_icon);			/* "Ordner" */
	return (std_dsk_icon);				/* "Disk" */
}


#pragma warn -par
CICONBLK *parentname_to_iconblk(char *path, char *nurname)
{
	return (std_par_icon);
}

#pragma warn +par


#pragma warn -par
CICONBLK *batchname_to_iconblk(char *fname)
{
	return (std_bat_icon);
}

#pragma warn +par


#pragma warn -par
CICONBLK *devicename_to_iconblk(char *fname)
{
	return (std_dev_icon);
}

#pragma warn +par

#pragma warn -par
CICONBLK *alias_to_iconblk(char *fname)
{
	CICONBLK *c;

	c = specialkey_to_iconblk('ALIS');
	if (!c)
		c = std_dev_icon;
	return (c);
}

#pragma warn +par


CICONBLK *specialkey_to_iconblk(long key)
{
	SPECIALOBJECT *sp;
	int i;

	for (i = 0, sp = specs; i < n_specs; i++, sp++)
	{
		if (key == sp->key)
			return (sp->icon);
	}
	return (NULL);
}


/****************************************************************
*
* Rechnet Koordinaten linear um. Der Wert <wert> wurde bei
* Bildschirmgrîûe <old> abgespeichert, jetzt ist die
* Bildschirmgrîûe <new>.
*
****************************************************************/

void recalc(int *wert, int old, int new)
{
	unsigned long tmp;

	tmp = (unsigned long) *wert;
	tmp *= new;
	tmp /= old;
	*wert = (int) tmp;
}


/****************************************************************
*
* Legt den Desktop-Hintergrund fest
*
****************************************************************/

void set_desktop(void)
{
	OBJECT *o;
	static USERBLK desktop;
	extern int work_out[];


	kachel_exit();						/* falls noch alte Kachel da */
	o = fenster[0]->pobj;
	if (*kachel_path)
	{
		if ((*kachel_path)->path[0])
		{
			if (!kachel_init((*kachel_path)->path, work_out[13] - 1))
			{
				o->ob_type = G_USERDEF;
				desktop.ub_code = drawdesk;
				o->ob_spec.userblk = &desktop;
				return;
			}
		} else
		{
			Mfree(*kachel_path);
			*kachel_path = NULL;
		}
	}

	o->ob_type = G_BOX;
	(o->ob_spec).index = 0;				/* alle Felder auf 0 */
	(o->ob_spec).obspec.interiorcol = *desk_col;
	(o->ob_spec).obspec.fillpattern = *desk_patt;
}


/****************************************************************
*
* Legt die Icons fÅr den Desktop-Hintergrund fest
*
* initial = TRUE:	ob_x ist die Iconposition, Ñndere
*				ob_x entsprechend so, daû das Icon selbst
*				auf derselben Position bleibt.
*		= FALSE:	ob_x nicht verÑndern
*
****************************************************************/

static void set_deskt_icons(int initial)
{
	int i;
	OBJECT *o;
	ICON *ic;
	int typ;
	char path[128];
	char *txt;
	char *name;
	char **pname;


	for (i = 0, o = fenster[0]->pobj + 1, ic = icon; i < n_deskicons; i++, o++, ic++)
	{
		typ = ic->icontyp;
		if (typ)						/* Icon gÅltig */
		{
			txt = ic->text;
			name = NULL;
			if (ic->isdisk)
			{
				pname = &name;
				if (!initial)
				{
					name = ic->data.monoblk.ib_ptext;
					if ((name >= ic->text) && (name < ic->text + MAX_ICONTXT))
						pname = NULL;	/* Icontext retten */
				}
				ic->data = *(diskname_to_iconblk(ic->isdisk, pname));
				ic->data.monoblk.ib_char = ic->isdisk + 0x1000;
				ic->icontyp = ITYP_DISK;
			} else if (typ >= ITYP_ORDNER)
			{
				name = get_name(txt);
				if (typ == ITYP_ORDNER)
				{
					strcpy(path, txt);
					if (path[strlen(txt) - 1] != '\\')
						strcat(path, "\\");
					ic->data = *(foldername_to_iconblk(path, NULL));
				} else if (typ == ITYP_BTCHDA)
					ic->data = *(batchname_to_iconblk(name));
				else if (typ == ITYP_DEVICE)
					ic->data = *(devicename_to_iconblk(name));
				else if (typ == ITYP_PROGRA)
					ic->data = *(pgmname_to_iconblk(name));
				else
/*				if	(typ == ITYP_DATEI)	*/
					ic->data = *(datname_to_iconblk(name));
			} else
			{
				if (typ == ITYP_DRUCKR)
					ic->data = *std_prt_icon;
				else
/*				if	(typ == ITYP_PAPIER)	*/
					ic->data = *std_tra_icon;
			}
			init_icnobj(o, &(ic->data), ic->icontyp, name, ic->is_alias);
			if (initial)
				o->ob_x -= o->ob_spec.iconblk->ib_xicon;
		} else
			o->ob_flags = HIDETREE;
	}									/* END FOR */
}


/****************************************************************
*
* LÑdt bzw. setzt alle Defaults.
* pass == 0: gmemptr initialisieren, d.h. n_icons,
*            bestimmen und Speicher fÅr icon
*		   allozieren
* pass == 1: Status  laden
*
****************************************************************/

static char *s;

/*
*  Liest eine Zeile bis zum Zeilenende.
*/

static int scnlin(void)
{
	while (1)
	{
		if (!*s)
			return (0);
		if (*s++ != '\r')
			continue;
		if (*s++ != '\n')
			return (0);
		return (1);
	}
}

/*
*  Liest eine Zeichenkette bis zum nÑchsten ' '
*/

static void scnstr(char *t)
{
	while (*s == ' ')
		s++;
	while (*s != ' ' && *s != '\0' && *s != '\r' && *s != '\n')
		*t++ = *s++;
	*t = '\0';
}

/*
*  Liest Zeichenkette bis Zeilenende
*/

static void scnbstr(char *t)
{
	while (*s == ' ')
		s++;
	while (*s != '\0' && *s != '\r' && *s != '\n')
		*t++ = *s++;
	*t = '\0';
}

/*
*  Liest Dezimalzahl (int).
*/

static int scndez(void)
{
	while (*s == ' ')
		s++;
	return ((int) strtol(s, &s, 10));
}

/*
*  Liest ein Flag ('1' oder '0')
*/

static char scnflg(void)
{
	char c;

	while (*s == ' ')
		s++;
	if (*s)
	{
		c = *s++ - '0';
		return (c);
	}
	return (0);
}

void load_status(int pass)
{
	int i;
	int dx, dy;
	int icw, ich;
	char **p;
	int dummy;
	char dummy_s[128];
	int i_version;
	char *inf;
	unsigned int len;
	int old_w, old_h;
	GRECT *g;
	int ln_wind;
	int ln_icns;
	int ln_pgms;
	int code;
	OBJECT *o;
	LONG err;


	dirty_pgm = TRUE;
	Mgraf_mouse(HOURGLASS);
	if (!pass)
	{
		if (gmemptr)
			Mfree(gmemptr);
		gmemptr = NULL;

		icon = NULL;
		fenster[0]->pobj = NULL;

	}

	if (pass)
	{

		/* zunÑchst sicherheitshalber Defaults setzen */
		/* ------------------------------------------ */

		(((adr_ttppar + TTPPAR_1)->ob_spec.tedinfo)->te_ptext)[0] = EOS;
		(((adr_ttppar + TTPPAR_2)->ob_spec.tedinfo)->te_ptext)[0] = EOS;

/* Fenster: */
		status.use_pp = TRUE;			/* ".." zeigen */
		status.show_prticon = TRUE;
		status.show_8p3 = TRUE;
		status.h_icon_dist = 3;
		status.v_icon_dist = 1;
		status.sorttyp = M_SNAME;
		status.showtyp = M_ABILDR;
		status.is_1col = FALSE;
		status.is_groesse = TRUE;
		status.is_datum = TRUE;
		status.is_zeit = TRUE;
		status.font_is_prop = FALSE;
		status.fontID = 1;
		status.fontH = 10;
/* Kopieren: */
		status.cnfm_del = TRUE;
		status.cnfm_copy = TRUE;
		status.mode_ovwr = CONFIRM;
		status.check_free = TRUE;
		status.resident = TRUE;
		status.show_all = FALSE;
		status.dnam_init = TRUE;
		status.copy_resident = TRUE;
		status.copy_use_kobold = FALSE;
/* Desktop: */
		status.desk_col_1 = BLACK;
		status.desk_patt_1 = 3;
		status.desk_col_4 = GREEN;
		status.desk_patt_4 = 7;
		status.desk_raster = 1;
		if (kachel_1)
			Mfree(kachel_1);
		if (kachel_4)
			Mfree(kachel_4);
		if (kachel_8)
			Mfree(kachel_8);
		if (kachel_m)
			Mfree(kachel_m);
		kachel_1 = kachel_4 = kachel_8 = kachel_m = NULL;

		strcpy(ext_bat, "BAT");
		strcpy(ext_btp, "BTP");

/* versch.: */
		status.save_on_exit = FALSE;
		status.rtbutt_dclick = FALSE;
		status.disk_extinfo = FALSE;

		for (ln_wind = 1, g = fensterg + 1; ln_wind <= ANZFENSTER; ln_wind++, g++)
		{
			g->g_x = 140 + 20 * ln_wind;
			g->g_y = desk_g.g_y + 10 * ln_wind;
			g->g_w = 300;
			g->g_h = 10 * gl_hhchar;
		}
	}									/* END IF (pass) */
	else
	{
		ln_wind = 1;
		ln_icns = 40;
	}

	/* Jetzt die Inf- Datei aus dem AES- Puffer holen */
	/* ---------------------------------------------- */

	len = shel_get(NULL, -1);			/* LÑnge des INF- Puffers ermitteln */
	inf = Malloc((long) (len + 1));
	if (inf == NULL)
	{
		err_alert(ENSMEM);
		return;
	}
	inf[len] = EOS;
	shel_get(inf, len);
	s = inf + 128;						/* Beginn der Desktop- Daten */

	ln_wind = 1;						/* erstes Fenster */
	ln_pgms = 0;
	if ((s == NULL) || (*s == EOS))		/* keine Daten */
		goto install;					/* ... dann Defaults verwenden */

	if (strncmp(s, "#_DSK", 5))
	{
	  err:
		Rform_alert(1, ALRT_ERR_AT_INF);
		goto install;
	}
	s += 5;								/* #_DSK Åberspringen */
	scnstr(dummy_s);					/* "MAGXDESK" */
	scnstr(dummy_s);					/* Vxx.xx */
	i_version = scndez();
	if (i_version != PGM_I_VERSION)
		goto err;						/* falsche INF- Version */
	if (!scnlin())						/* Zeile #_DSK Åberspringen */
		goto err;

	/* Wir beginnen mit dem Einlesen */
	/* ----------------------------- */

	old_w = desk_g.g_w;
	old_h = desk_g.g_h;
	ln_icns = 0;						/* erstes Icon */

	/* Die groûe Schleife fÅrs Einlesen */
	/* -------------------------------- */

	for (; *s; scnlin())
	{
		if (strncmp(s, "#_D", 3))
			continue;
		s += 3;
		if (!*s || *s == '\r')
			break;
		code = (*s++) << 8;				/* Hibyte holen */
		if (!*s || *s == '\r')
			break;
		code |= *s++;					/* Lobyte holen */

		switch (code)
		{
		case 'SW':
			if (pass != 0)
			{
				old_w = scndez();
				old_h = scndez();

				deflt_topwnr = scndez();

				status.sorttyp = scndez() + M_SNAME;

				status.showtyp = (scnflg())? M_ATEXT : M_ABILDR;

				scndez();					/* points */

				status.is_1col = scnflg();
				status.is_groesse = scnflg();
				status.is_datum = scnflg();
				status.is_zeit = scnflg();

				status.rtbutt_dclick = scnflg();	/* Alt: blitstate */
				status.cnfm_del = scnflg();
				status.cnfm_copy = scnflg();
				status.mode_ovwr = scnflg();
				status.check_free = scnflg();
				status.use_pp = scnflg();
				status.resident = scnflg();
				status.show_all = scnflg();
				status.show_prticon = scnflg();	/* V2: clock */
				status.disk_extinfo = scnflg();	/* Alt: resvd0 */
				status.dnam_init = scnflg();
				scnflg();					/* resvd1 */
				scnflg();					/* resvd2 */
			}
			break;

		case 'S2':
			if (pass != 0)
			{
				status.copy_resident = scnflg();
				status.copy_use_kobold = scnflg();
				status.save_on_exit = scnflg();
				status.show_8p3 = scnflg();

				status.h_icon_dist = scndez();
				status.v_icon_dist = scndez();
				status.desk_raster = scndez();
				status.desk_col_1 = scndez();
				status.desk_patt_1 = scndez();
				status.desk_col_4 = scndez();
				status.desk_patt_4 = scndez();
				status.font_is_prop = scndez();
				status.fontID = scndez();
				status.fontH = scndez();
			}
			break;

		case 'WN':
			if (pass != 0 && ln_wind <= ANZFENSTER)
			{
				g = fensterg + ln_wind;

				/* Fensterpositionen einlesen */
				/* -------------------------- */

				g->g_x = scndez();
				g->g_y = scndez();
				g->g_w = scndez();
				g->g_h = scndez();

				/* Fensterpositionen fÅr Auflîsung umrechnen */
				/* ----------------------------------------- */

				if (old_w != desk_g.g_w)
				{
					recalc(&(g->g_x), old_w, desk_g.g_w);
					recalc(&(g->g_w), old_w, desk_g.g_w);
				}
				if (old_h != desk_g.g_h)
				{
					recalc(&(g->g_y), old_h, desk_g.g_h);
					recalc(&(g->g_h), old_h, desk_g.g_h);
				}
				g->g_x += desk_g.g_x;
				g->g_y += desk_g.g_y;

				/* ab V3.25: Bereichsabfragen */
				/* -------------------------- */

				make_g_fit_screen(g);

				/* Sliderposition, Pfad, Flags */
				/* --------------------------- */

				{
					char buf[200];
					char buf2[200];
					char *name;
					int shift;
					int flags;

					shift = scndez();
					if (shift < 0)
					{
						switch (shift)
						{
						case -1:
							flags = WFLAG_ICONIFIED;
							break;
						case -2:
							flags = WFLAG_ICONIFIED + WFLAG_ALLICONIFIED;
							break;
						case -3:
							flags = WFLAG_ALLICONIFIED;
							break;
						}
						shift = 0;
					} else
						flags = 0;

					scnbstr(buf);

					if (*buf)				/* Fenster geîffnet */
					{
						name = get_name(buf);
						strcpy(buf2, name);
						*name = '\0';
						create_wnd(ln_wind, buf, buf2, shift, flags, &err);
					}
				}
				ln_wind++;
			}
			break;

		case 'IC':
			if (pass)
			{
				int *obx;
				int *oby;
				int ich = (adr_icons + I_DSK)->ob_height + 1;


				icon[ln_icns].is_alias = FALSE;
				icon[ln_icns].icontyp = scndez();
				icon[ln_icns].isdisk = scnflg() + '0';
				if (icon[ln_icns].isdisk == '@')
					icon[ln_icns].isdisk = 0;
				obx = &(fenster[0]->pobj + ln_icns + 1)->ob_x;
				oby = &(fenster[0]->pobj + ln_icns + 1)->ob_y;
				*obx = scndez();
				*oby = scndez();
				if (old_w != desk_g.g_w)
					recalc(obx, old_w, desk_g.g_w);
				if (*obx < 0)
					*obx = 0;
				if (*obx >= desk_g.g_w - 32)
					*obx = desk_g.g_w - 32;

				if (old_h != desk_g.g_h)
					recalc(oby, old_h, desk_g.g_h);
				if (*oby < 0)
					*oby = 0;
				if (*oby >= desk_g.g_h - ich)
					*oby = desk_g.g_h - ich;
				*obx += desk_g.g_x;
				*oby += desk_g.g_y;
				if (icon[ln_icns].icontyp >= ITYP_ORDNER)
					scnbstr(icon[ln_icns].text);
			}

			ln_icns++;
			break;

		case 'PG':
			if (pass != 0 && ln_pgms < ANZPROGRAMS)
			{
				scnbstr(menuprograms[ln_pgms].path);
				if (menuprograms[ln_pgms].path[0] == '*')
					strcpy(menuprograms[ln_pgms].path, menuprograms[ln_pgms].path + 1);
				ln_pgms++;
			}
			break;

		case 'K1':
			p = &kachel_1;
		  kachel:
			if (pass != 0)
			{
				scnbstr(dummy_s);
				if ((i = (int) strlen(dummy_s)) > 0)
				{
					*p = Malloc(i + 1);
					if (*p)
						strcpy(*p, dummy_s);
				}
			}
			break;

		case 'K4':
			p = &kachel_4;
			goto kachel;

		case 'K8':
			p = &kachel_8;
			goto kachel;

		case 'KM':
			p = &kachel_m;
			goto kachel;

		case 'EX':
			scnstr(ext_bat);
			scnstr(ext_btp);
			break;

			/*  case 'AP':   in V3 nicht mehr verwendet */

		case 'PP':
			if (pass != 0)
			{
				char buf[200];
				char *ziel1;
				char *ziel2;

				buf[0] = EOS;
				if (*s)
					s++;
				ziel1 = buf;
				while ((*s) && (*s != '\r') && (*s != '\n'))
					*ziel1++ = *s++;
				*ziel1 = EOS;
				ziel1 = ((adr_ttppar + TTPPAR_1)->ob_spec.tedinfo)->te_ptext;
				ziel2 = ((adr_ttppar + TTPPAR_2)->ob_spec.tedinfo)->te_ptext;
				if (buf[0])
				{
					strncpy(ziel1, buf, TTPLEN);
					if (strlen(buf) >= TTPLEN)
					{
						ziel1[TTPLEN] = EOS;
						strcpy(ziel2, buf + TTPLEN);
					}
				}
			}
			break;
		}
	}

  install:
	Mfree(inf);

	if (!pass)							/* wollte nur n_icons bestimmen */
	{
		n_deskicons = ln_icns + PLUSICONS;
		gmemptr = Malloc(sizeof(ICON) * n_deskicons + sizeof(OBJECT) * (n_deskicons + 1));
		if (!gmemptr)
		{
			err_alert(ENSMEM);
			return;
		}
		fenster[0]->shownum = fenster[0]->realnum = n_deskicons;
		fenster[0]->pobj = (OBJECT *) gmemptr;
		icon = (ICON *) (fenster[0]->pobj + n_deskicons + 1);

		/* Desktop- Hintergrund zusammenfummeln */
		/* ------------------------------------ */

		o = fenster[0]->pobj;
		o->ob_next = -1;
		o->ob_head = 1;
		o->ob_tail = n_deskicons;
/*		o->ob_type = G_BOX;		*/

		o->ob_flags = o->ob_state = 0;
		icw = (adr_icons + I_DSK)->ob_width + 1;
		ich = (adr_icons + I_DSK)->ob_height + 1;
		dx = desk_g.g_x;
		dy = desk_g.g_y;
		for (i = 0; i < n_deskicons; i++)
		{
			o++;
			o->ob_next = i + 2;
			o->ob_head = o->ob_tail = -1;
			o->ob_x = dx;
			o->ob_y = dy;
			dx += icw;
			if (dx + icw > desk_g.g_w)
			{
				dx = desk_g.g_x;
				dy += ich;
				if (dy + ich > desk_g.g_h)
					dy = desk_g.g_y;
			}
			o->ob_flags = o->ob_state = o->ob_type = 0;
		}
		o->ob_next = 0;
		o->ob_flags = LASTOB;
		return;
	}

	/* Farbe des Desktop-Hintergrunds */
	/* ------------------------------ */

	set_desktop();

	/* unbenutzte Fenster/Icons/Programme/Applikationen */
	/* ------------------------------------------------ */

	for (; ln_icns < n_deskicons; ln_icns++)
		icon[ln_icns].icontyp = icon[ln_icns].isdisk = 0;
	for (; ln_pgms < ANZPROGRAMS; ln_pgms++)
		menuprograms[ln_pgms].path[0] = EOS;

	/* allgemeine Installation der Icons */
	/* --------------------------------- */

	set_deskt_icons(TRUE);

	/* Systemeinstellungen */

	fslx_set_flags(status.show_8p3, &dummy);

	Mgraf_mouse(ARROW);
}


/****************************************************************
*
* Speichert alle Defaults.
* Die TMP- Datei wird IMMER aufs Bootlaufwerk geschrieben.
*
****************************************************************/

static void prtdez(int i)
{
	*s++ = ' ';
	itoa(i, s, 10);
	while (*s++)
		;
	s--;
}

static void prtflg(int i)
{
	*s++ = (i) ? '1' : '0';
}

static void prtstr(char *str)
{
	while ((*s++ = *str++) != '\0')
		;
	s--;
}

static void status_to_ascii(char *inf)
{
	int i;
	WINDOW **pw;
	WINDOW *w;
	ICON *ic;
	OBJECT *o;
	GRECT *g;


	s = inf;

	/* 1. Zeile: "#_DSK MAGXDESK Vx.xx" */
	/* -------------------------------- */

	prtstr("#_DSK MAGXDESK V");
	prtstr(pgm_ver);
	prtdez(PGM_I_VERSION);
	prtstr("\r\n#_DSW");

	/* 2. Zeile: "#_DSW w h t a bb cccc ddddddddddddd"  */
	/* w     Bildschirmbreite                           */
	/* h  Bildschirmhîhe                            */
	/* t     Sortiertyp 0..4                            */
	/* a  '0'/'1' = Anzeigen als Bilder/als Text        */
	/* b  '08'/'09'/'10' = Punktgrîûe fÅr Text          */
	/* c  1col/isgr/isdat/iszeit                        */
	/* d  status.blitstate                          */
	/*   status.cnfm_del                            */
	/*   status.cnfm_copy                           */
	/*   status.mode_ovwr                           */
	/*   status.check_free                          */
	/*   status.use_fldl                            */
	/*   status.resident                            */
	/*   status.show_all                            */
	/*   status.show_prticon    V2: clock               */
	/*   status.use_cache                           */
	/*   status.dnam_init                           */
	/*   status.resvd1                              */
	/*   status.resvd2                              */
	/* --------------------------------------------------- */

	prtdez(desk_g.g_w);
	prtdez(desk_g.g_h);
	prtdez(deflt_topwnr);
	prtdez(status.sorttyp - M_SNAME);
	*s++ = ' ';
	prtflg(status.showtyp == M_ATEXT);
/*
	if	(status.points == M_8_PKT)
		i = 8;
	else i = (status.points == M_9_PKT) ? 9 : 10;
*/
	i = 10;

	prtdez(i);
	*s++ = ' ';
	prtflg(status.is_1col);
	prtflg(status.is_groesse);
	prtflg(status.is_datum);
	prtflg(status.is_zeit);
	*s++ = ' ';
	prtflg(status.rtbutt_dclick);		/* Alt: blitstate */
	prtflg(status.cnfm_del);
	prtflg(status.cnfm_copy);
	*s++ = status.mode_ovwr + '0';
	prtflg(status.check_free);
	prtflg(status.use_pp);
	prtflg(status.resident);
	prtflg(status.show_all);
	prtflg(status.show_prticon);		/* V2: clock */
	prtflg(status.disk_extinfo);		/* V4: resvd0 */
	prtflg(status.dnam_init);
	*s++ = '0';							/* resvd1 */
	*s++ = '0';							/* resvd2 */

	/* 3. Zeile: "#_DS2 aaaa b c x d e f g h i j"       */
	/* a     status.copy_resident                       */
	/* a     status.copy_use_kobold                     */
	/* a     status.save_on_exit                        */
	/* a     status.show_8p3                            */
	/* b     status.h_icon_dist                         */
	/* c     status.v_icon_dist                         */
	/* x     status.desk_raster                         */
	/* d     status.desk_col_1                          */
	/* e     status.desk_patt_1                         */
	/* f     status.desk_col_4                          */
	/* g     status.desk_patt_4                         */
	/* h     status.font_is_prop                        */
	/* i     status.fontID                              */
	/* j     status.fontH                               */
	/* --------------------------------------------------- */

	prtstr("\r\n#_DS2 ");
	prtflg(status.copy_resident);
	prtflg(status.copy_use_kobold);
	prtflg(status.save_on_exit);
	prtflg(status.show_8p3);
	prtdez(status.h_icon_dist);
	prtdez(status.v_icon_dist);
	prtdez(status.desk_raster);
	prtdez(status.desk_col_1);
	prtdez(status.desk_patt_1);
	prtdez(status.desk_col_4);
	prtdez(status.desk_patt_4);
	prtdez(status.font_is_prop);
	prtdez(status.fontID);
	prtdez(status.fontH);
	prtstr("\r\n");

	/* 4. Zeile: "#_DK1 path"                       */
	/* 5. Zeile: "#_DK4 path"                       */
	/* 6. Zeile: "#_DK8 path"                       */
	/* 7. Zeile: "#_DKM path"                       */
	/* Pfade fÅr Kachel-IMGs                            */

	if (kachel_1 && *kachel_1)
	{
		prtstr("#_DK1 ");
		prtstr(kachel_1);
		prtstr("\r\n");
	}
	if (kachel_4 && *kachel_4)
	{
		prtstr("#_DK4 ");
		prtstr(kachel_4);
		prtstr("\r\n");
	}
	if (kachel_8 && *kachel_8)
	{
		prtstr("#_DK8 ");
		prtstr(kachel_8);
		prtstr("\r\n");
	}
	if (kachel_m && *kachel_m)
	{
		prtstr("#_DKM ");
		prtstr(kachel_m);
		prtstr("\r\n");
	}

	/* 8. Zeile: "#_DEX ext_bat ext_btp                    */
	/* -------------------------------------------------------- */

	prtstr("#_DEX ");
	prtstr(ext_bat);
	prtstr(" ");
	prtstr(ext_btp);
	prtstr("\r\n");

	/* 9. Zeile und folgende: "#_DWN x y w h shift path\mask" */
	/* shift = -1: Fenster ist ikonifiziert                */
	/* shift = -2: Fenster ist all-ikonifiziert            */
	/* shift = -3: anderes Fenster ist all-ikonifiziert    */
	/* ------------------------------------------------------ */

	for (i = 1, pw = fenster + 1, g = fensterg + 1; i <= ANZFENSTER; i++, pw++, g++)
	{
		GRECT g2;

		w = *pw;
		prtstr("#_DWN");

		if (w)
		{
			if (w->flags & WFLAG_ICONIFIED)
				wind_get_grect(w->handle, WF_UNICONIFY, &g2);
			else
				g2 = w->out;
		} else
			g2 = *g;

		prtdez(g2.g_x - desk_g.g_x);
		prtdez(g2.g_y - desk_g.g_y);
		prtdez(g2.g_w);
		prtdez(g2.g_h);
		if (w)
		{
			if (w->flags & WFLAG_ICONIFIED)
			{
				if (w->flags & WFLAG_ALLICONIFIED)
					prtdez(-2);
				else
					prtdez(-1);
			} else if (w->flags & WFLAG_ALLICONIFIED)
				prtdez(-3);
			else
				prtdez(w->yscroll);
			*s++ = ' ';
			prtstr(w->path);
			prtstr(w->maske);
		} else
			prtdez(0);
		*s++ = '\r';
		*s++ = '\n';
	}

	/* "#_DIC typ c x y path" */
	/* ---------------------- */

	for (i = 0, ic = icon, o = fenster[0]->pobj + 1; i < n_deskicons; i++, ic++, o++)
	{
		if (ic->icontyp)
		{
			prtstr("#_DIC");
			prtdez(ic->icontyp);
			*s++ = ' ';
			*s++ = (ic->isdisk) ? (ic->isdisk) : '@';
			prtdez(o->ob_x - desk_g.g_x + o->ob_spec.iconblk->ib_xicon);
			prtdez(o->ob_y - desk_g.g_y);
			if (ic->icontyp >= ITYP_ORDNER)
			{
				*s++ = ' ';
				prtstr(ic->text);
			}
			*s++ = '\r';
			*s++ = '\n';
		}
	}

	/* "#_DAP path typ ext1 ext2"       */
	/* wird in V3 nicht mehr verwendet */
	/* ------------------------------- */

	/* "#_DPG path */
	/* ----------- */

	for (i = 0; i < ANZPROGRAMS; i++)
	{
		if (i < INDEX_USER || menuprograms[i].path[0] != '\0')
		{
			prtstr("#_DPG ");
			prtstr(menuprograms[i].path);
			*s++ = '\r';
			*s++ = '\n';
		}
	}

	/* "#_DPP line" */
	/* ------------ */

	prtstr("#_DPP ");
	prtstr(((adr_ttppar + TTPPAR_1)->ob_spec.tedinfo)->te_ptext);
	prtstr(((adr_ttppar + TTPPAR_2)->ob_spec.tedinfo)->te_ptext);
	*s++ = '\r';
	*s++ = '\n';

	*s = '\0';
}


void save_status(int is_inf)
{
	char *inf;
	char *t;
	int handle = 0;
	long doserr;
	WINDOW *tw;


	Mgraf_mouse(HOURGLASS);
	inf = (char *) Malloc(65536L);
	if (inf == NULL)
	{
		doserr = ENSMEM;
		goto ende;
	}

	if (is_inf)
	{
		doserr = Fopen(inf_name, O_RDWR);
		handle = (int) doserr;
		if (doserr == EFILNF)
		{
			doserr = Fcreate(inf_name, 0);
			handle = (int) doserr;
			if (doserr > E_OK)
			{
				static char os_ver_s2[] =
					"#_MAG MAG!X v__.__\r\n" "#[boot]\r\n" "#[aes]\r\n" "#[shelbuf]\r\n" "#_CTR\r\n";
				strncpy(os_ver_s2 + 13, os_ver_s + 7, 5);
				Fwrite((int) doserr, strlen(os_ver_s2), os_ver_s2);
				Fseek(0L, handle, SEEK_SET);
			}
		}
		if (doserr < E_OK)
			goto ende;
		doserr = Fread(handle, 32768L, inf);
		if (doserr < E_OK)
			goto ende;
		s = inf;
		while (strncmp(s, "#_CTR", 5))
		{
			if (!scnlin())
			{
			  err2:
				doserr = ERROR;
				goto ende;				/* unerwartetes Dateiende */
			}
		}
		if (!scnlin())
			goto err2;
		t = s;							/* Beginn der neuen Daten */
		shel_get(s, 128);
		tw = top_window();
		deflt_topwnr = (tw) ? tw->wnr : -1;
		status_to_ascii(t + 128);
		Fseek(t - inf, handle, SEEK_SET);	/* Dateizeiger auf Kontrollfeld */
		doserr = Fwrite(handle, 128 + strlen(t + 128), t);
		if (doserr != 128 + strlen(t + 128))
		{
			if (doserr >= E_OK)
				doserr = EWRITF;
			goto ende;
		}
		Fshrink(handle);
	} else
	{
		unsigned int len;

		doserr = E_OK;
		len = shel_get(NULL, -1);
		shel_get(inf, len);
		inf[len] = EOS;
		s = inf;
		status_to_ascii(s + 128);
		if (!shel_put(inf, 128 + ((unsigned int) strlen(inf + 128) + 1)))
			Rform_alert(1, ALRT_OVL_AES_BUF);
	}

  ende:

	if (handle > 0)
		Fclose(handle);
	if (inf)
		Mfree(inf);
	if (!is_inf && gmemptr)
	{
		Mfree(gmemptr);
		gmemptr = NULL;

		icon = NULL;
		fenster[0]->pobj = NULL;

	}
	if (doserr < E_OK)
		err_alert(doserr);
	Mgraf_mouse(ARROW);
}


/****************************************************************
*
* LÑdt alle Defaults neu von Laufwerk <drv>
*
****************************************************************/

void reload_status(int drv)
{
	int handle;
	char *inf;
	char olddrv;
	long doserr;


	Mgraf_mouse(HOURGLASS);
	olddrv = inf_name[0];
	if (drv >= 0)
		inf_name[0] = letter_from_drive(drv);
	inf = (char *) Malloc(65536L);
	if (inf == NULL)
	{
		doserr = ENSMEM;
		goto err;
	}

	doserr = Fopen(inf_name, O_RDONLY);
	if (doserr == EFILNF)
	{
		if (1 != Rxform_alert(2, ALRT_NO_INF_AT_X, inf_name[0], NULL))
		{
			inf_name[0] = olddrv;
			Mgraf_mouse(ARROW);
			Mfree(inf);
			return;
		}
		goto getit;
	}
	handle = (int) doserr;
	if (doserr < E_OK)
	{
	  err:

		if (handle > 0)
			Fclose(handle);
		Mgraf_mouse(ARROW);
		err_alert(doserr);
		if (inf)
			Mfree(inf);
		return;
	}
	doserr = Fread(handle, 65535L, inf);
	Fclose(handle);
	if (doserr < E_OK)
		goto err;
	inf[doserr] = EOS;
	s = inf;
	while (strncmp(s, "#_CTR", 5))
	{
		if (!scnlin())
		{
		  err2:
			doserr = ERROR;
			goto err;					/* unerwartetes Dateiende */
		}
	}
	if (!scnlin())
		goto err2;
	shel_put(s, (unsigned int) strlen(s) + 1);
  getit:
	Mfree(inf);

	close_all_wind();
	load_status(0);
	load_status(1);
	open_all_wind();
	Mgraf_mouse(ARROW);
}
