/*******************************************************************
*
*             INSTMAGC.PRG                             10.10.91
*             ============
*                                 letzte �nderung:     15.5.98
*
* geschrieben mit TUBO C V2.03, PureC
*
* Vorgehensweise der Installation:
*
* -	Dialogeingabe
* -	Bootlaufwerk X bestimmen
*
* Von Disk 1:
* -	Den Ordner MAGX nach X:\ kopieren (rekursiv)
* -	MAGX.INF auf X:\ erstellen
*
* Von Disk 2:
* -	MAGIC.RAM auf X:\ erstellen
* -	MAGXDESC.RSC auf X:\GEMSYS\GEMDESK erstellen
* -  Wenn X:\CPX\ nicht existiert, per fsel_input() nachfragen.
*    ggf. X:\CPX erstellen.
* -  Die CPX-Dateien kopieren.
* -	ggf. EXTRAS nach X:\GEMSYS\MAGIC\UTITLITY\ kopieren
*
*******************************************************************/

#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <toserror.h>
#include "country.h"
#include "instmagc.h"
#include "xcopy.h"

#define SCREEN      0
#define BUFLEN		400000L
#define INFBUFLEN	65538L

int ap_id;
int scrx, scry, scrw, scrh;
OBJECT *adr_dialog;

/* Meldungen: */
char *writing;
char *crfolder;
char *reading;
char *err_creating;
char *diskfull;

int drv;
char buf[BUFLEN];
char infbuf[INFBUFLEN];


static int test_serno(long code);


#define TXT(a)      ((((adr_dialog + a) -> ob_spec.tedinfo))->te_ptext)


#define PERS_SERNO "188160918"
#define PERS_NAME "Test Name"
#define PERS_ADRESSE "Test Adresse, 00000 Test Stadt"


static char dst_dir[128] = "X:\\xx\mm\\";
static char cpxpath[128];
static char zusatzpath[128];
static char zusatz[128];
static char inf_name[128];
static char inf_old_name[128];
static char rampath[128];
static char rscname[128];
static char mod_appname[128];
static char mod_appparm[] = "\0-Xis PARD Zur�ck MAGICICN.RSC 132";
static char default_home[] = "@:\\GEMSYS\\HOME\\";
static char default_dev[] = "1 0";


static char *rs_str(int obj)
{
	char *str = 0;
	rsrc_gaddr(R_STRING, obj, &str);
	return str;
}


static int alertv(const char *format, ...)
{
	char buf[256];
	va_list(args);
	
	va_start(args, format);
	vsprintf(buf, format, args);
	va_end(args);
	return form_alert(1, buf);
}


/****************************************************************
*
* close_work
*
****************************************************************/

static void close_work(void)
{
	wind_update(END_MCTRL);
	rsrc_free();
	appl_exit();
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

static void objc_grect(OBJECT *tree, int objn, GRECT *g)
{
	objc_offset(tree, objn, &(g->g_x), &(g->g_y));
	g->g_w = (tree + objn)->ob_width;
	g->g_h = (tree + objn)->ob_height;
}


/****************************************************************
*
* Malt ein Unterobjekt. Wenn es sich um eine Zahl handelt, wird
* sie ausgegeben, sonst ggf. der String
*
****************************************************************/

static void subobj_draw(OBJECT *tree, int obj, int n, const char *s)
{
	GRECT g;
	char *z;

	z = (tree + obj)->ob_spec.free_string;
	if (s)
		strncpy(z, s, 55);
	else if (n >= 0)
		ultoa(n, z, 10);
	objc_grect(tree, obj, &g);
	objc_draw_grect(tree, 0, MAX_DEPTH, &g);
}


void callback(const char *action, const char *name)
{
	subobj_draw(adr_dialog, O_ACTION, 0, action);
	subobj_draw(adr_dialog, O_PATH, 0, name);
}


/********** Objekt selektiert? *********/

static int selected(OBJECT *tree, int which)
{
	return ((tree + which)->ob_state & SELECTED) ? 1 : 0;
}

/******* Objekt deselektieren **********/

static void ob_dsel(OBJECT *tree, int which)
{
	(tree + which)->ob_state &= ~SELECTED;
}


static void redraw_dialog(void)
{
	subobj_draw(adr_dialog, 0, -1, NULL);
}


/****************************************************************
*
* Teste, ob ein Pfad existiert. Wirf vorher ggf. einen
* angeh�ngten Dateinamen weg.
*
****************************************************************/

static int path_ok(char *path)
{
	long doserr;
	char *s;
	DTA dta;

	if (strlen(path) < 3 || path[1] != ':')
		return FALSE;
	s = strrchr(path, '\\');
	if (!s)
		return FALSE;					/* Pfad existiert nicht */
	if (s[1])							/* kommt noch ein Dateiname? */
		s[1] = '\0';					/* Ja, Dateinamen abs�gen */
	*s = EOS;							/* Backslash entfernen */
	Fsetdta(&dta);
	doserr = Fsfirst(path, FA_SUBDIR);
	*s = '\\';
	return doserr == E_OK && (dta.d_attrib & FA_SUBDIR);
}

static void path_create(char *path)
{
	char *s;

	if (strlen(path) > 3)
	{
		s = path + strlen(path) - 1;
		*s = EOS;
		Dcreate(cpxpath);
		*s = '\\';
	}
}


/****************************************************************
*
* CPX-Pfad ermitteln und ggf. erstellen
*
****************************************************************/

static void create_cpx(void)
{
	int ret;
	char fname[66];
	char oldcpxpath[128];

	strcpy(oldcpxpath, cpxpath);		/* Default retten */
	fname[0] = '\0';
	do
	{
		if (path_ok(cpxpath))
			break;
		form_alert(1, rs_str(CPX_FOLDER));
		strcat(cpxpath, "*.*");
		fsel_input(cpxpath, fname, &ret);
		redraw_dialog();
	} while (ret);

	if (!ret)							/* Abbruch bet�tigt */
		strcpy(cpxpath, oldcpxpath);	/* Default restaurieren */

	path_create(cpxpath);
}


/****************************************************************
*
* MAGX.RAM erstellen
*
****************************************************************/

static void encode(char *z, char *q)
{
	int i;

	for (i = 0; i < 50; i++)
	{
		z[i] += q[i];
		z[i] += i * 11;
	}
}


static int create_ram(void)
{
	char *s;
	int file;
	long flen;
	long doserr;
	KEYTAB *keys;

	/* MAGIC.RAM modifizieren und erstellen */
	/* ------------------------------------ */

	callback(reading, "MAGIC.RAM");
	file = (int) Fopen("MAGX_2\\MAGIC.RAM", O_RDONLY);
	if (file < 0)
		return 0;
	flen = Fread(file, BUFLEN, buf);
	Fclose(file);
	if (flen <= 0)
		return 0;

	keys = Keytbl((void *) -1L, (void *) -1L, (void *) -1L);

	/* Tastaturtabellen modifizieren */
	/* ----------------------------- */

	for (s = buf + 0x4000L; s < buf + 0x9000L; s++)
	{
		if (!memcmp(s, "tastaturtabellen", 16))
		{
			s += 16;
			memcpy(s, keys->unshift, 128L);
			memcpy(s + 128L, keys->shift, 128L);
			memcpy(s + 256L, keys->capslock, 128L);
			break;
		}
	}

	/* buf+1c ist das Programm ohne den Programmheader */
	/* Bei Offset 0x14 steht der Zeiger auf die AES-Variablen */

	s = (buf + 0x1c) + *((long *) (buf + 0x1c + 0x14));
	s[0x79] = drv - 'A';				/* Installationslaufwerk */
	doserr = atol(PERS_SERNO);
	memcpy(s - 0x8c, &doserr, 4L);
	memset(s - 0x88, 0, 50);
	strcpy(s - 0x88, PERS_NAME);
	encode(s - 0x88, "C:\\AUTO\\GEMSYS\\GEMDESK\\CLIPBRD\\BILDER\\MAGXDESK\\MAGXDESK.RSC");
	memset(s - 0x56, 0, 50);
	strcpy(s - 0x56, PERS_ADRESSE);
	encode(s - 0x56, "[1][Sie haben eine falsche Seriennummer|eingegeben][Abbruch]");
	file = (int) MFcreate(rampath);
	if (file < 0)
		return 0;
	doserr = Fwrite(file, flen, buf);
	Fclose(file);
	if (doserr != flen)
	{
		form_alert(1, rs_str(WAS_EWRITF));
		return 0;
	}
	return 1;
}


/****************************************************************
*
* MAGXDESK.RSC erstellen
*
****************************************************************/

static int create_rsc(void)
{
	int file;
	long flen;
	long doserr;

	callback(reading, "MAGXDESK.RSC");
	file = (int) Fopen("MAGX_2\\MAGXDESK.RSC", O_RDONLY);
	if (file < 0)
		return 0;
	flen = Fread(file, BUFLEN, buf);
	Fclose(file);
	if (flen <= 0)
		return 0;
	file = (int) MFcreate(rscname);
	if (file < 0)
		return 0;
	doserr = Fwrite(file, flen, buf);
	Fclose(file);
	if (doserr != flen)
	{
		form_alert(1, rs_str(WAS_EWRITF));
		return 0;
	}
	return 1;
}


/****************************************************************
*
* ermittle Zeichenkette <key> in Abschnitt <section>
*
* section:	"\r\n#[...]"
* key:		"\r\ndrives="
*
****************************************************************/

static char *find_key(const char *key, const char *section)
{
	char *s;
	char *t;

	s = strstr(infbuf, section);
	if (!s)
		return NULL;					/* Abschnitt nicht da */
	s += strlen(section);
	t = strstr(s, "\r\n#[");			/* n�chster Abschnitt */
	s = strstr(s, key);
	if (!s)
		return NULL;					/* Schl�ssel nicht da */
	if (t && s >= t)
		return NULL;					/* Schl�ssel in anderem Abschnitt */
	return s + strlen(key);
}


/****************************************************************
*
* alte MAGX.INF lesen
*
****************************************************************/

static int load_inf(void)
{
	int file;
	long flen;


	file = (int) Fopen(inf_name, O_RDONLY);
	if (file < 0)
		return 0;
	flen = Fread(file, INFBUFLEN - 1, infbuf);
	Fclose(file);
	if (flen <= 0)
		return 0;
	buf[flen] = EOS;					/* Mit Nullbyte abschlie�en */
	return 1;
}


/****************************************************************
*
* MAGX.INF erstellen
*
****************************************************************/

static int create_inf(void)
{
	int file;
	long flen;
	char *s;
	char *t;
	char *old;
	char *old2;
	int i;

	/* MAGX.INF von Diskette lesen */
	/* --------------------------- */

	file = (int) Fopen("MAGX_2\\MAGX.INF", O_RDONLY);
	if (file < 0)
		return 0;
	flen = Fread(file, BUFLEN - 1, buf);
	Fclose(file);
	if (flen <= 0)
		return 0;
	buf[flen] = EOS;					/* Mit Nullbyte abschlie�en */

	/* Das Laufwerk statt des @ eintragen */
	/* ---------------------------------- */

	s = buf;
	while (NULL != (s = strchr(s, '@')))
	{
		/* do not patch the icon character for desktop icons */
		if (s[1] != ' ')
			*s = drv;
	}

	/* Kontrollfeld-Daten reinpatchen */
	/* ------------------------------ */

	s = strstr(buf, "#_CTR\r\n");
	s += 7;
	shel_get(s, 128);					/* Kontrollfeld- Daten */
	if (s[127] == '\n' && s[126] == '\r' && s[125] == ' ')
		s[125] = ';';

	/* MAGX.INF erstellen */
	/* ------------------ */

	if (Frename(0, inf_name, inf_old_name) == 0)
	{
		form_alert(1, rs_str(INF_REN));
	}

	file = (int) MFcreate(inf_name);
	if (file < 0)
		return 0;

	/* Einzelbl�cke erstellen */

	i = 0;
	s = buf;
	do
	{
		t = strchr(s, '%');
		flen = (t) ? (t - s) : strlen(s);
		Fwrite(file, flen, s);

		/* Bei '%' einf�gen */

		if (t)
		{
			t++;

			switch (i)
			{
			case 0:
				old = find_key("\r\ndrives=", "\r\n#[vfat]");
				if (old)
				{
					old2 = strstr(old, "\r\n");
					if (old2)
						Fwrite(file, old2 - old, old);
				}
				break;
			case 1:
				old = find_key("\r\n#_DEV ", "\r\n#[aes]");
				if (old)
				{
					old2 = strstr(old, "\r\n");
				} else
				{
					old = default_dev;
					old2 = old + strlen(old);
				}
				if (old2)
					Fwrite(file, old2 - old, old);
				break;
			case 2:
				old = find_key("\r\n#_ENV HOME=", "\r\n#[aes]");
				if (old)
				{
					old2 = strstr(old, "\r\n");
				} else
				{
					old = default_home;
					old2 = old + strlen(old);
				}
				if (old2)
					Fwrite(file, old2 - old, old);
				break;
			}
			s = t;
			i++;
		}
	} while (t);

	Fclose(file);
	return 1;
}


/****************************************************************
*
* install
*
****************************************************************/

static int install(int exitbutton)
{
	long doserr;
	int i;

	if (exitbutton == O_PERS_ABBRUCH)
		return 1;

	/* Laufwerk bestimmen */
	/* ------------------ */

	drv = -1;
	for (i = O_PERS_LWA; i <= O_PERS_LWL; i++)
	{
		if (selected(adr_dialog, i))
			drv = i - O_PERS_LWA + 'A';
	}

	dst_dir[0] = drv;
	strcat(strcpy(zusatzpath, dst_dir), "GEMSYS\\MAGIC\\UTILITY\\");
	strcat(strcpy(zusatz, zusatzpath), "EXTRAS\\");
	strcat(strcpy(cpxpath, dst_dir), "CPX\\");
	strcat(strcpy(inf_name, dst_dir), "MAGX.INF");
	strcat(strcpy(inf_old_name, dst_dir), "MAGX.xxx");
	strcat(strcpy(rampath, dst_dir), "MAGIC.RAM");
	strcat(strcpy(rscname, dst_dir), "GEMSYS\\GEMDESK\\MAGXDESK.RSC");
	default_home[0] = drv;
	strcat(strcpy(mod_appname, dst_dir), "GEMSYS\\GEMDESK\\MOD_APP.TTP");
	mod_appparm[2] = drv;

	/* alte INF-Datei lesen */
	/* -------------------- */

	load_inf();

	/* CPX-Pfad feststellen */
	/* -------------------- */

	create_cpx();

	/* Disk 1:  MAGX_1\_COPY kopieren nach X:\ */
	/* ------------------------------------------ */

	doserr = copy_subdir("MAGX_1\\_COPY\\", dst_dir);
	if (doserr)
	{
	  cp_err:
		form_alert(1, rs_str(ERR_COPY));
		return 0;
	}

	/* Disk wechseln */
	/* ------------- */

	while (E_OK > Fattrib("MAGX_2\\DISK2", 0, 0))
	{
		DTA dta;

		if (2 == form_alert(1, rs_str(DISK_2)))
			return 0;

		/* F�r TOS: */

		Fsetdta(&dta);
		Fsfirst("\\*.*", -1);
	}

	/* Disk 2:  MAGX_2\_COPY kopieren nach X:\ */
	/* ------------------------------------------ */

	doserr = copy_subdir("MAGX_2\\_COPY\\", dst_dir);
	if (doserr)
		goto cp_err;

	/* Disk 2:  MAGX.INF auf X:\ erstellen */
	/* -------------------------------------- */

	if (!create_inf())
	{
		form_alert(1, rs_str(ERR_INF));
		return 0;
	}

	/* Disk 2:  MAGIC.RAM auf X:\ erstellen */
	/* --------------------------------------- */

	if (!create_ram())
	{
		form_alert(1, rs_str(ERR_RAM));
		return 0;
	}

	/* MAGXDESK.RSC erstellen */
	/* ---------------------- */

	if (!create_rsc())
	{
		form_alert(1, rs_str(ERR_RSC));
		return 0;
	}

	/* CPXe kopieren    */
	/* ----------------- */

	doserr = copy_subdir("MAGX_2\\CPX\\", cpxpath);
	if (doserr)
	{
		form_alert(1, rs_str(ERR_CPX));
	}
	alertv(rs_str(WCOLOR), cpxpath);

	/* Auf Wunsch Zus�tze kopieren */
	/* --------------------------- */

	if (selected(adr_dialog, EXTRAS_Y))
	{
		GDcreate(zusatzpath, "EXTRAS");
		doserr = copy_subdir("MAGX_2\\EXTRAS\\", zusatz);
		if (doserr)
		{
			form_alert(1, rs_str(ERR_EXTRAS));
		}
	}


#if 0
	/* MOD_APP aufrufen */
	/* ---------------- */
	mod_appparm[0] = (char) strlen(mod_appparm + 1);
	Pexec(0, mod_appname, mod_appparm, NULL);
#endif

	/* fertig */
	/* ------ */

	form_alert(1, rs_str(FERTIG));

	return 1;
}


/****************************************************************
*
* do_exdialog
*
****************************************************************/

static int do_exdialog(OBJECT *dialog, int (*check)(int exitbutton))
{
	GRECT cr;
	int exitbutton;

	/* Pfad usw. entfernen */
	dialog[O_ACTION].ob_flags |= HIDETREE;
	dialog[O_PATH].ob_flags |= HIDETREE;

	form_center_grect(dialog, &cr);
	form_dial_grect(FMD_START, &cr, &cr);
	objc_draw_grect(dialog, ROOT, MAX_DEPTH, &cr);
	for (;;)
	{
		exitbutton = 0x7f & form_do(dialog, 0);

		adr_dialog[O_ACTION].ob_flags &= ~HIDETREE;
		adr_dialog[O_PATH].ob_flags &= ~HIDETREE;

		ob_dsel(dialog, exitbutton);
		graf_mouse(HOURGLASS, NULL);
		if ((*check) (exitbutton))
			break;

		adr_dialog[O_ACTION].ob_flags |= HIDETREE;
		adr_dialog[O_PATH].ob_flags |= HIDETREE;

		subobj_draw(dialog, O_ACTION, -1, NULL);
		subobj_draw(dialog, O_PATH, -1, NULL);
		graf_mouse(ARROW, NULL);
		objc_draw_grect(dialog, exitbutton, 1, &cr);
	}
	form_dial_grect(FMD_FINISH, &cr, &cr);
	return exitbutton;
}


int main(void)
{
	int file;
	long cnt;
	char *s;
	char *t;

	/* Applikation beim AES anmelden */
	/* ----------------------------- */
	if ((ap_id = appl_init()) < 0)
		return 1;

	/* Mauskontrolle holen */
	/* ------------------- */

	wind_update(BEG_MCTRL);
	graf_mouse(ARROW, NULL);

	/* Resourcedatei laden */
	/* ------------------- */
	if (!rsrc_load("instmagc.rsc"))
	{
		form_alert(1, "[3][\"INSTMAGC.RSC\"|not found.][Abort]");
		close_work();
		return 0;
	}

	reading = rs_str(READING);
	crfolder = rs_str(CRFOLDER);
	writing = rs_str(WRITING);
	err_creating = rs_str(ERR_CREATING);
	diskfull = rs_str(DISKFULL);

	/* Bildschirm- Arbeitsbereich berechnen */
	/* ------------------------------------ */

	wind_get(SCREEN, WF_WORKXYWH, &scrx, &scry, &scrw, &scrh);

	/* Adressen der Resourcen berechnen */
	/* -------------------------------- */

	rsrc_gaddr(R_TREE, TREE_PERSONALIZE, &adr_dialog);

	/* inf- Datei laden */
	/* ---------------- */

	file = (int) Fopen("instmagx.inf", O_RDONLY);
	if (file > 0)
	{
		cnt = Fread(file, 1000L, buf);
		Fclose(file);
		if (cnt >= 0)
		{
			buf[cnt] = '\0';
			s = buf;
			/* t = TXT(O_PERS_SERNO); */
			t = buf;
			while (*s && *s != '\r')
				*t++ = *s++;
			*t = '\0';
			if (*s == '\r')
				s++;
			if (*s == '\n')
				s++;

			/* t = TXT(O_PERS_NAME); */
			t = buf;
			while (*s && *s != '\r')
				*t++ = *s++;
			*t = '\0';
			if (*s == '\r')
				s++;
			if (*s == '\n')
				s++;

			/* t = TXT(O_PERS_ADRESSE); */
			t = buf;
			while (*s && *s != '\r')
				*t++ = *s++;
			*t = '\0';
			if (*s == '\r')
				s++;
			if (*s == '\n')
				s++;

			if (*s >= 'A' && *s <= 'L')
			{
				adr_dialog[O_PERS_LWA + 2].ob_state &= ~SELECTED;
				adr_dialog[O_PERS_LWA + *s - 'A'].ob_state |= SELECTED;
			}
		}
	}

	do_exdialog(adr_dialog, install);
	close_work();
	return 0;
}


/*   Das Verfahren beruht darauf, da� die laufende Nummer nicht direkt
     verwendet, sondern mit Hilfe einer bestimmten Abbildung in eine
     echte Teilmenge der nat�rlichen Zahlen abgebildet wird. Diese Abbildung
     ist injektiv.
     Das Betriebssystem kann nun testen, ob die eingegebene Seriennummer
     g�ltig ist, d.h. ob sie ein Element der Bildmenge der obigen Funktion
     ist. Falls sie nicht in der Menge enthalten ist, kann sie kein Bild
     einer laufenden Nummer sein, ist also definitiv fehlerhaft.

     Die Abbildung ist folgende:

          Nimm eine 16-Bit-Zahl (laufende Nummer)
          Multipliziere die Zahl mit 7
          Schiebe das Ergebnis in die freien Bits von
                    %0xxxxx01x1x0x000xxx1x0x1xx0xx1xx
          Addiere 1671805031
*/

#define MAG1   7L
#define MAG2   "0xxxxx01x1x0x000xxx1x0x1xx0xx1xx"
#define MAG3   167185031L

/*******************************************************************
*
* Die eigentliche Codierungsroutine, die einer 16-Bit-Zahl
* <lfdnum> eine g�ltige Seriennummer zuordnet.
*
*******************************************************************/

static int test_serno(long serno)
{
	unsigned long i;
	unsigned long j;
	unsigned long k;
	int l;
	char *mag2 = MAG2;

	i = serno - MAG3;
	k = 0;
	j = 1;
	for (l = 31; l >= 0; l--)
	{
		if (mag2[l] == 'x')
		{
			if (i & 1)
				k |= j;					/* Bit einmischen */
			j <<= 1;
		} else if (mag2[l] == '1')
		{
			if (!(i & 1L))
				return -1;
		} else
		{
			if (i & 1)
				return -1;
		}
		i >>= 1;
	}
	if (k % MAG1)
		return -1;					/* Fehler */
	return 0;
}
