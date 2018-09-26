/*******************************************************************
*
*             INSTMAGC.PRG                             10.10.91
*             ============
*                                 letzte énderung:     15.5.98
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
* -	MAGiC.RAM auf X:\ erstellen
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
#include "instmagc.h"
#include "xcopy.h"

#define SCREEN      0
#define TRUE        1
#define FALSE       0
#define EOS		'\0'
#define USA		0
#define FRG		1
#define BUFLEN		400000L
#define INFBUFLEN	65538L

int       ap_id;
int       scrx,scry,scrw,scrh;
OBJECT    *adr_dialog;

/* Meldungen: */
char		*writing;
char		*crfolder;
char		*reading;
char		*err_creating;
char		*diskfull;

int       drv;
char      buf[BUFLEN];
char		infbuf[INFBUFLEN];


void redraw_dialog( void );
void close_work     (void);
int  do_exdialog    (OBJECT *dialog,
                    int (*check)(int exitbutton));
void subobj_draw(OBJECT *tree, int obj, int n, char *s);
int  install        ( int exitbutton );
char *get_name      (char *path);
void ob_dsel        (OBJECT *tree, int which);
int  selected       (OBJECT *tree, int which);
void	create_cpx	( void );
int  create_ram     ( void );
int	load_inf		( void );
int  create_inf     ( void );
int  create_rsc     ( void );
static int test_serno( long code );


#define TXT(a)      ((((adr_dialog + a) -> ob_spec.tedinfo))->te_ptext)


static char *dst_dir = "X:\\";
static char cpxpath[128] = "X:\\CPX\\";
static char *zusatzpath = "X:\\GEMSYS\\MAGIC\\UTILITY\\";
static char *zusatz = "X:\\GEMSYS\\MAGIC\\UTILITY\\EXTRAS\\";
static char *inf_name = "X:\\MAGX.INF";
static char *inf_old_name = "X:\\MAGX.xxx";
static char *rampath = "X:\\MAGIC.RAM";
static char *rscname = "X:\\GEMSYS\\GEMDESK\\MAGXDESK.RSC";
static char *mod_appname = "X:\\GEMSYS\\GEMDESK\\MOD_APP.TTP";
static char *mod_appparm = "\0-Xis PARD ZurÅck MAGICICN.RSC 132";
static char *default_home = "@:\\GEMSYS\\HOME\\";
static char *default_dev = "1 0";

void main()
{
	int file;
	long cnt;
	char *s,*t;


	/* Applikation beim AES anmelden */
	/* ----------------------------- */
	if   ((ap_id = appl_init()) < 0)
		Pterm(1);

	/* Mauskontrolle holen */
	/* ------------------- */

	wind_update(BEG_MCTRL);
	graf_mouse(ARROW, NULL);

	/* Resourcedatei laden */
	/* ------------------- */
	if   (!rsrc_load("instmagc.rsc"))
		{
		form_alert(1, "[3][\"INSTMAGC.RSC\"|not found.][Abort]");
		close_work();
		}

	rsrc_gaddr(R_STRING, READING, &reading);
	rsrc_gaddr(R_STRING, CRFOLDER, &crfolder);
	rsrc_gaddr(R_STRING, WRITING, &writing);
	rsrc_gaddr(R_STRING, ERR_CREATING, &err_creating);
	rsrc_gaddr(R_STRING, DISKFULL, &diskfull);

	/* Bildschirm- Arbeitsbereich berechnen */
	/* ------------------------------------ */

	wind_get(SCREEN, 4, &scrx, &scry, &scrw, &scrh);

	/* Adressen der Resourcen berechnen */
	/* -------------------------------- */

	rsrc_gaddr(0, TREE_PERSONALIZE, &adr_dialog);

	/* Dialog initialisieren */
	/* --------------------- */

	TXT(O_PERS_SERNO)[0] = '\0';
	TXT(O_PERS_NAME)[0] = '\0';
	TXT(O_PERS_ADRESSE)[0] = '\0';

	/* inf- Datei laden */
	/* ---------------- */

	file = (int) Fopen("instmagx.inf", O_RDONLY);
	if	(file > 0)
		{
		cnt = Fread(file, 1000L, buf);
		Fclose(file);
		if	(cnt >= 0)
			{
			buf[cnt] = '\0';
			s = buf;
			t = TXT(O_PERS_SERNO);
			while((*s) && ((*s) != '\r'))
				*t++ = *s++;
			*t = '\0';
			if	(*s == '\r')
				s++;
			if	(*s == '\n')
				s++;

			t = TXT(O_PERS_NAME);
			while((*s) && ((*s) != '\r'))
				*t++ = *s++;
			*t = '\0';
			if	(*s == '\r')
				s++;
			if	(*s == '\n')
				s++;

			t = TXT(O_PERS_ADRESSE);
			while((*s) && ((*s) != '\r'))
				*t++ = *s++;
			*t = '\0';
			if	(*s == '\r')
				s++;
			if	(*s == '\n')
				s++;

			if	((*s >= 'A') && (*s <= 'L'))
				{
				adr_dialog[O_PERS_LWA+2].ob_state
						&= ~SELECTED;
				adr_dialog[O_PERS_LWA+ *s - 'A'].ob_state
						|= SELECTED;
				}
			}
		}

	do_exdialog(adr_dialog, install);
	close_work();
}


/****************************************************************
*
* install
*
****************************************************************/

void callback(char *action, char *name)
{
	subobj_draw(adr_dialog, O_ACTION, 0, action);
	subobj_draw(adr_dialog, O_PATH, 0, name);
}


int install( int exitbutton )
{
	long doserr;
	register int i;
	char *alert;


     if   (exitbutton == O_PERS_ABBRUCH)
          return(1);

	rsrc_gaddr(R_STRING, SER_ASK_OK, &alert);
     if   (2 == form_alert(2,alert))
          return(0);

     doserr = atol(TXT(O_PERS_SERNO));
	if	(test_serno(doserr))
		{
		rsrc_gaddr(R_STRING, INV_SER, &alert);
		form_alert(1,alert);
		return(0);
		}

     /* Laufwerk bestimmen */
     /* ------------------ */

     drv = -1;
     for  (i = O_PERS_LWA; i <= O_PERS_LWL; i++)
          {
          if   (selected(adr_dialog, i))
               drv = i - O_PERS_LWA + 'A';
          }

	dst_dir[0] = zusatzpath[0] = zusatz[0] = cpxpath[0] =
	inf_name[0] = inf_old_name[0] = rampath[0] =
	rscname[0] = default_home[0] = drv;
	mod_appname[0] = mod_appparm[2] = drv;

	/* alte INF-Datei lesen */
	/* -------------------- */

	load_inf();

	/* CPX-Pfad feststellen */
	/* -------------------- */

	create_cpx();

	/* Disk 1:	MAGX_1\_COPY kopieren nach X:\ */
	/* ------------------------------------------ */

	doserr = copy_subdir("MAGX_1\\_COPY\\", dst_dir);
	if	(doserr)
		{
		 cp_err:
		rsrc_gaddr(R_STRING, ERR_COPY, &alert);
		form_alert(1,alert);
          return(0);
		}

	/* Disk wechseln */
	/* ------------- */

	while(E_OK > Fattrib("MAGX_2\\DISK2", 0, 0))
		{
		DTA dta;

		rsrc_gaddr(R_STRING, DISK_2, &alert);
		if	(2 == form_alert(1, alert))
			return(0);

		/* FÅr TOS: */

		Fsetdta(&dta);
		Fsfirst("\\*.*", -1);
		}

	/* Disk 2:	MAGX_2\_COPY kopieren nach X:\ */
	/* ------------------------------------------ */

	doserr = copy_subdir("MAGX_2\\_COPY\\", dst_dir);
	if	(doserr)
		goto cp_err;

	/* Disk 2:	MAGX.INF auf X:\ erstellen */
	/* -------------------------------------- */

     if   (!create_inf())
		{
		rsrc_gaddr(R_STRING, ERR_INF, &alert);
		form_alert(1, alert);
          return(0);
          }

	/* Disk 2:	MAGIC.RAM auf X:\ erstellen */
	/* --------------------------------------- */

     if   (!create_ram())
		{
		rsrc_gaddr(R_STRING, ERR_RAM, &alert);
		form_alert(1, alert);
          return(0);
          }

     /* MAGXDESK.RSC erstellen */
     /* ---------------------- */

     if   (!create_rsc())
     	{
		rsrc_gaddr(R_STRING, ERR_RSC, &alert);
		form_alert(1, alert);
		return(0);
		}

     /* CPXe kopieren	 */
     /* ----------------- */

	doserr = copy_subdir("MAGX_2\\CPX\\", cpxpath);
	if	(doserr)
		{
		rsrc_gaddr(R_STRING, ERR_CPX, &alert);
		form_alert(1, alert);
		}
	rsrc_gaddr(R_STRING, WCOLOR, &alert);
	{
	char s[256];
	char *t;

	strcpy(s, alert);
	t = strchr(s, '%');
	strcpy(t, cpxpath);
	t = strchr(alert, '%');
	strcat(s, t+2);
	form_alert(1,s);
	}

	/* Auf Wunsch ZusÑtze kopieren */
	/* --------------------------- */

	if	(selected(adr_dialog, EXTRAS_Y))
		{
		GDcreate(zusatzpath, "EXTRAS");
		doserr = copy_subdir("MAGX_2\\EXTRAS\\", zusatz);
		if	(doserr)
			{
			rsrc_gaddr(R_STRING, ERR_EXTRAS, &alert);
			form_alert(1, alert);
			}
		}


     /* MOD_APP aufrufen */
     /* ---------------- */

	mod_appparm[0] = (char) strlen(mod_appparm+1);
	Pexec(0, mod_appname, mod_appparm, NULL);

	/* fertig */
	/* ------ */

	rsrc_gaddr(R_STRING, FERTIG, &alert);
	form_alert(1, alert);

     return(1);
}


/****************************************************************
*
* close_work
*
****************************************************************/

void close_work(void)
{
     wind_update(END_MCTRL);
     rsrc_free();
     appl_exit();
     Pterm0();
}


/****************************************************************
*
* do_exdialog
*
****************************************************************/

int do_exdialog(OBJECT *dialog,
                int (*check)(int exitbutton))
{
     int cx, cy, cw, ch;
     int exitbutton;


     /* Pfad usw. entfernen */
     dialog[O_ACTION].ob_flags |= HIDETREE;
     dialog[O_PATH].ob_flags |= HIDETREE;

     form_center(dialog, &cx, &cy, &cw, &ch);
     form_dial(FMD_START, 0,0,0,0, cx, cy, cw, ch);
     objc_draw(dialog, ROOT, MAX_DEPTH, cx, cy, cw, ch);
     do   {
          exitbutton = 0x7f & form_do(dialog, 0);

          adr_dialog[O_PERS_NAME].ob_flags |= HIDETREE;
          adr_dialog[O_PERS_ADRESSE].ob_flags |= HIDETREE;
          adr_dialog[O_ACTION].ob_flags &= ~HIDETREE;
          adr_dialog[O_PATH].ob_flags &= ~HIDETREE;

          ob_dsel(dialog, exitbutton);
          graf_mouse(HOURGLASS, NULL);
          if   ((*check)(exitbutton))
               break;

          adr_dialog[O_PERS_NAME].ob_flags &= ~HIDETREE;
          adr_dialog[O_PERS_ADRESSE].ob_flags &= ~HIDETREE;
          adr_dialog[O_ACTION].ob_flags |= HIDETREE;
          adr_dialog[O_PATH].ob_flags |= HIDETREE;

          subobj_draw(dialog, O_PERS_NAME, -1, NULL);
          subobj_draw(dialog, O_PERS_ADRESSE, -1, NULL);
          graf_mouse(ARROW, NULL);
          objc_draw(dialog, exitbutton, 1, cx, cy, cw, ch);
          }
     while(1);
     form_dial(FMD_FINISH, 0,0,0,0,cx, cy, cw, ch);
     return(exitbutton);
}


/********** Objekt selektiert? *********/

int selected(OBJECT *tree, int which)

{ return( ((tree+which)->ob_state & SELECTED) ? 1 : 0 ); }

/******* Objekt deselektieren **********/

void ob_dsel(OBJECT *tree, int which)

{ (tree+which)->ob_state &= ~SELECTED; }


void ws(int file, char *s)
{
     Fwrite(file, strlen(s), s);
}


/****************************************************************
*
* Teste, ob ein Pfad existiert. Wirf vorher ggf. einen
* angehÑngten Dateinamen weg.
*
****************************************************************/

static int path_ok( char *path )
{
	long doserr;
	char *s;
	DTA dta;


	if	((strlen(path) < 3) || (path[1] != ':'))
		return(FALSE);
	s = strrchr(path, '\\');
	if	(!s)
		return(FALSE);			/* Pfad existiert nicht */
	if	(s[1])				/* kommt noch ein Dateiname? */
		s[1] = '\0';			/* Ja, Dateinamen absÑgen */
	*s = EOS;					/* Backslash entfernen */
	Fsetdta(&dta);
	doserr = Fsfirst(path, FA_SUBDIR);
/*	Cconws("Fsfirst ");Cconws(path);Cconws("\r\n");	*/
	*s = '\\';
	return((doserr == E_OK) && (dta.d_attrib & FA_SUBDIR));
}

static void path_create( char *path )
{
	char *s;

	if	(strlen(path) > 3)
		{
		s = path + strlen(path) - 1;
		*s = EOS;
		Dcreate(cpxpath);
/*		Cconws("Dcreate ");Cconws(path);Cconws("\r\n");	*/
		*s = '\\';
		}
}


/****************************************************************
*
* CPX-Pfad ermitteln und ggf. erstellen
*
****************************************************************/

void create_cpx( void )
{
	int ret;
	char *alert;
	char fname[66];
	char oldcpxpath[128];


	strcpy(oldcpxpath, cpxpath);		/* Default retten */
	fname[0] = '\0';
	do	{
		if	(path_ok(cpxpath))
			break;
		rsrc_gaddr(R_STRING, CPX_FOLDER, &alert);
		form_alert(1, alert);
		strcat(cpxpath, "*.*");
		fsel_input(cpxpath, fname, &ret);
		redraw_dialog( );
		}
	while(ret);

	if	(!ret)			/* Abbruch betÑtigt */
		strcpy(cpxpath, oldcpxpath);	/* Default restaurieren */

	path_create(cpxpath);
/*
	Cconws(cpxpath);
	Cconin();
*/
}


/****************************************************************
*
* alte MAGX.INF lesen
*
****************************************************************/

int load_inf( void )
{
	int file;
	long flen;


	file = (int) Fopen(inf_name, O_RDONLY);
	if	(file < 0)
		return(0);
	flen = Fread(file, INFBUFLEN-1, infbuf);
	Fclose(file);
	if	(flen <= 0L)
		return(0);
	buf[flen] = EOS;		/* Mit Nullbyte abschlieûen */
	return(1);
}


/****************************************************************
*
* ermittle Zeichenkette <key> in Abschnitt <section>
*
* section:	"\r\n#[...]"
* key:		"\r\ndrives="
*
****************************************************************/

char *find_key( char *key, char *section )
{
	char *s,*t;

	s = strstr(infbuf, section);
	if	(!s)
		return(NULL);			/* Abschnitt nicht da */
	s += strlen(section);
	t = strstr(s, "\r\n#[");		/* nÑchster Abschnitt */
	s = strstr(s, key);
	if	(!s)
		return(NULL);			/* SchlÅssel nicht da */
	if	((t) && (s >= t))
		return(NULL);			/* SchlÅssel in anderem Abschnitt */
	return(s + strlen(key));
}


/****************************************************************
*
* MAGX.INF erstellen
*
****************************************************************/

int create_inf( void )
{
	int file;
	long flen;
	char *s,*t;
	char *old,*old2;
	char *alert;
	int i;



	/* MAGX.INF von Diskette lesen */
	/* --------------------------- */

	file = (int) Fopen("MAGX_2\\MAGX.INF", O_RDONLY);
	if	(file < 0)
		return(0);
	flen = Fread(file, BUFLEN-1, buf);
	Fclose(file);
	if	(flen <= 0L)
		return(0);
	buf[flen] = EOS;		/* Mit Nullbyte abschlieûen */

	/* Das Laufwerk statt des @ eintragen */
	/* ---------------------------------- */

	s = buf;
	while(NULL != (s = strchr(s, '@')))
		*s = drv;

	/* Kontrollfeld-Daten reinpatchen */
	/* ------------------------------ */

	s = strstr(buf, "#_CTR\r\n");
	s += 7;
     shel_get(s, 128);          /* Kontrollfeld- Daten */
	if   (s[127] == '\n' &&
		 s[126] == '\r' &&
		 s[125] == ' ')
		s[125] = ';';

     /* MAGX.INF erstellen */
     /* ------------------ */

	if	(!Frename(0, inf_name, inf_old_name))
		{
		rsrc_gaddr(R_STRING, INF_REN, &alert);
		form_alert(1, alert);
		}

     file = (int) MFcreate(inf_name);
     if   (file < 0)
          return(0);

	/* Einzelblîcke erstellen */

	i = 0;
	s = buf;
	do	{
		t = strchr(s, '%');
		flen = (t) ? (t-s) : strlen(s);
	     Fwrite(file, flen, s);

		/* Bei '%' einfÅgen */

		if	(t)
			{
			t++;

			switch(i)
				{
				case 0:
					old = find_key("\r\ndrives=", "\r\n#[vfat]");
					if	(old)
						{
						old2 = strstr(old, "\r\n");
						if	(old2)
							Fwrite(file, old2-old, old);
						}
					break;
				case 1:
					old = find_key("\r\n#_DEV ", "\r\n#[aes]");
					if	(old)
						old2 = strstr(old, "\r\n");
					else	{
						old = default_dev;
						old2 = old+strlen(old);
						}
					if	(old2)
						Fwrite(file, old2-old, old);
					break;
				case 2:
					old = find_key("\r\n#_ENV HOME=", "\r\n#[aes]");
					if	(old)
						old2 = strstr(old, "\r\n");
					else	{
						old = default_home;
						old2 = old+strlen(old);
						}
					if	(old2)
						Fwrite(file, old2-old, old);
					break;
				}
			s = t;
			i++;
			}
		}
	while(t);

     Fclose(file);
     return(1);
}


/****************************************************************
*
* MAGX.RAM erstellen
*
****************************************************************/

void encode(char *z, char *q)
{
     register int i;

     for  (i = 0; i < 50; i++)
          {
          z[i] += q[i];
          z[i] += i*11;
          }
}

int create_ram(void)
{
     register char *s;
     int file;
     long flen, doserr;
     KEYTAB *keys;
     char *alert;



     /* MAGIC.RAM modifizieren und erstellen */
     /* ------------------------------------ */

	callback(reading, "MAGIC.RAM");
	file = (int) Fopen("MAGX_2\\MAGIC.RAM", O_RDONLY);
	if	(file < 0)
		return(0);
	flen = Fread(file, BUFLEN, buf);
	Fclose(file);
	if	(flen <= 0L)
		return(0);

	keys = Keytbl((void *) -1L, (void *) -1L, (void *) -1L);

	/* Tastaturtabellen modifizieren */
	/* ----------------------------- */

	for  (s = buf + 0x4000L; s < buf + 0x9000L; s++)
		{
		if   (!memcmp(s, "tastaturtabellen", 16))
			{
			s += 16;
			memcpy(s, 	  keys->unshift,  128L);
			memcpy(s + 128L, keys->shift,    128L);
			memcpy(s + 256L, keys->capslock, 128L);
			break;
			}
		}

	/* buf+1c ist das Programm ohne den Programmheader */
	/* Bei Offset 0x14 steht der Zeiger auf die AES-Variablen */

     s = (buf+0x1c) + *((long *) (buf+0x1c+0x14));
     s[0x79] = drv-'A';		/* Installationslaufwerk */
     doserr = atol(TXT(O_PERS_SERNO));
     memcpy(s - 0x8c, &doserr, 4L);
     memcpy(s - 0x88, TXT(O_PERS_NAME), 50L);
     encode(s - 0x88, "C:\\AUTO\\GEMSYS\\GEMDESK\\CLIPBRD\\BILDER\\MAGXDESK\\MAGXDESK.RSC");
     memcpy(s - 0x56, TXT(O_PERS_ADRESSE), 50L);
     encode(s - 0x56, "[1][Sie haben eine falsche Seriennummer|eingegeben][Abbruch]");
     file = (int) MFcreate(rampath);
     if   (file < 0)
          return(0);
     doserr = Fwrite(file, flen, buf);
     Fclose(file);
     if   (doserr != flen)
          {
		rsrc_gaddr(R_STRING, WAS_EWRITF, &alert);
		form_alert(1, alert);
          return(0);
          }
     return(1);
}


/****************************************************************
*
* MAGXDESK.RSC erstellen
*
****************************************************************/

int  create_rsc( void )
{
     register char *s;
     register int is;
     int file;
     long flen, doserr;
     char *alert;


	callback(reading, "MAGXDESK.RSC");
     file = (int) Fopen("MAGX_2\\MAGXDESK.RSC", O_RDONLY);
     if   (file < 0)
          return(0);
     flen = Fread(file, BUFLEN, buf);
     Fclose(file);
     if   (flen <= 0L)
          return(0);
     is = 0;
     for  (s = buf; s < buf + flen && is < 2; s++)
          {
          if   (!strncmp(s, "Erika Mustermann", 16))
               {
               memcpy(s, TXT(O_PERS_NAME), 36L);
               is++;
               continue;
               }
          if   (!strncmp(s, "Quarkstraûe", 11))
               {
               memcpy(s, TXT(O_PERS_ADRESSE), 47L);
               is++;
               continue;
               }
          }
     if   (is < 2)
          return(0);
     file = (int) MFcreate(rscname);
     if   (file < 0)
          return(0);
     doserr = Fwrite(file, flen, buf);
     Fclose(file);
     if   (doserr != flen)
          {
		rsrc_gaddr(R_STRING, WAS_EWRITF, &alert);
		form_alert(1, alert);
          return(0);
          }
     return(1);
}


/****************************************************************
*
* Bestimmt die Begrenzung eines Objekts
*
****************************************************************/

void objc_grect(OBJECT *tree, int objn, GRECT *g)
{
     objc_offset(tree, objn, &(g -> g_x), &(g -> g_y));
     g -> g_w = (tree + objn) -> ob_width;
     g -> g_h = (tree + objn) -> ob_height;
}


/****************************************************************
*
* Malt ein Unterobjekt. Wenn es sich um eine Zahl handelt, wird
* sie ausgegeben, sonst ggf. der String
*
****************************************************************/

void subobj_draw(OBJECT *tree, int obj, int n, char *s)
{
     GRECT g;
     char *z;
     void objc_grect(OBJECT *tree, int objn, GRECT *g);


     z = (tree+obj)->ob_spec.free_string;
     if   (s)
          strncpy(z,s, 55);
     else if   (n >= 0)
               ultoa(n, z, 10);
     objc_grect(tree, obj, &g);
     objc_draw (tree, 0, MAX_DEPTH, g.g_x, g.g_y, g.g_w, g.g_h);
}


void redraw_dialog( void )
{
	subobj_draw(adr_dialog, 0, -1, NULL);
}


/*   Das Verfahren beruht darauf, daû die laufende Nummer nicht direkt
     verwendet, sondern mit Hilfe einer bestimmten Abbildung in eine
     echte Teilmenge der natÅrlichen Zahlen abgebildet wird. Diese Abbildung
     ist injektiv.
     Das Betriebssystem kann nun testen, ob die eingegebene Seriennummer
     gÅltig ist, d.h. ob sie ein Element der Bildmenge der obigen Funktion
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
* <lfdnum> eine gÅltige Seriennummer zuordnet.
*
*******************************************************************/

static int test_serno(long serno)
{
	register unsigned long i,j,k;
     register int l;
     char *mag2 = MAG2;


	i = serno - MAG3;
	k = 0L;
	j = 1L;
	for	(l = 31; l >= 0; l--)
     	{
		if	(mag2[l] == 'x')
			{
			if	(i & 1L)
				k |= j;   /* Bit einmischen */
			j <<= 1L;
			}
		else	
		if	(mag2[l] == '1')
			{
			if	(!(i & 1L))
				return(-1);
			}
		else	{
			if	(i & 1L)
				return(-1);
			}
		i >>= 1L;
          }
	if	(k % MAG1)
		return(-1);		/* Fehler */
	return(0);
}
