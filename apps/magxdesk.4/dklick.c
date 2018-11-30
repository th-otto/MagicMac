/*********************************************************************
*
* Dieses Modul enthÑlt die Bearbeitung aller Doppel-Mausklicks, also
*
* 1) ôffnen   von Unterverzeichnissen
* 2) Starten  von Programmen
* 3) Anzeigen/Drucken von Dateien
*
*********************************************************************/

#include <tos.h>
#include "k.h"
#include <string.h>
#include <vdi.h>
#include <toserror.h>

typedef struct          /* used by Pexec */
{
        unsigned char   length;
        char            command_tail[128];
} COMMAND;



/****************************************************************
*
* FÅr eine Datei wird die Standardapplikation ermittelt und ein
* Zeiger auf APPLICATION zurÅckgeliefert, falls vorhanden.
*
* Es gibt zwei Typen von Dateinamen:
*
* - "*.typ" gibt eine Extension an, Groû/Kleinschrift egal
* - "name" ist ein exakter Name, Groû/Kleinschrift wichtig.
*
****************************************************************/

APPLICATION *dfile_to_app(char *filepath)
{
	register DATAFILE *da;

	da = find_datafile(get_name(filepath));
	if	(da)
		return(da->ap);
	return(NULL);
}


/****************************************************************
*
* FÅr ein Programm wird festgestellt, ob es sich um eine
* angemeldete Applikation handelt, und ggf. ein Zeiger auf
* APPLICATION zurÅckgeliefert.
* Groû-/Kleinschrift muû z.Zt. passen.
*
****************************************************************/

APPLICATION *path_to_app(char *pgmpath)
{
	return(find_application(get_name(pgmpath)));
}


/*********************************************************************
*
* Wie obj_typ(), aber es wird ein Pfad vorgegeben
*
*********************************************************************/

static void path_typ(char *path, int *typ, int *config,
		APPLICATION **a)
{
	*config = suffixtyp(path);
	if	(*config == PGMT_NOEXE)					/* Textdatei */
		{
		*a = dfile_to_app(path);
		if	(*a)
			*typ = 'TX';
		else	*typ = '_T';
		}
	else {
		if	(*config & PGMT_BATCH)	/* Batch */
			*typ = 'BX';
		else
		if	(*config & PGMT_ACC)
			*typ = '_X';
		else	{
			*typ = '_X';
			(*a) = path_to_app(path);
			}
		}
}


/*********************************************************************
*
* Untersuchung des Objekts <obj> in <wnr.
* typ =     '_X'	Programm oder ACC, <config> ist gÅltig
*		  'BX'	Batch, <config> ist gÅltig
*		  'TX'	angemeldete Datei, <config> ist gÅltig
*		  '_T'	Text- Datei
*		  'AT'	unaufgelîster Alias
*		  'DO'	Disk
*		  '_O'    Ordner
*		  '_F'    Fenster
*		  'P_'	Papierkorb
*		  'D_'	Drucker
*		  '__'	undefiniert
*
* config ist der Bitvektor, der anzeigt, ob es ein TOS- Programm,
* oder single mode usw. ist.
* Wenn eine APPLICATION existiert, Åberlagert (*a)->config config.
*
* Genau:
*
*	-	Klick auf Programmdatei, Programm ist angemeldet
*		typ = _X, config ist Extension, (*a)->config Åberlagert
*	-	Klick auf Programmdatei, nicht angemeldet oder ACC
*		typ = _X, config ist Extension, (*a) ist NULL
*	-	Klick auf Batchdatei
*		typ = BX, config ist PGMT_BATCH, (*a) ist NULL
*	-	Klick auf angemeldete Datei
*		typ = TX, config ist -1, (*a) ist zugehîrige APP
*	-	Klick auf Textdatei
*		typ = _T, config ist -1, (*a) ist NULL
*	-	Klick auf unaufgelîsten Alias
*		typ = AT, config ist -1, (*a) ist NULL
*
* RÅckgabe  0, falls Datei
*           1, falls Pfad (Disk oder Ordner oder Fenster)
*		 -1, sonst
*
*********************************************************************/

int obj_typ(WINDOW *w, int obj, char *path, MYDTA **f,
		int *typ, int *config, APPLICATION **a)
{
	int ret;
	char	mpath[200];
	APPLICATION *ma;
	MYDTA *_f;


	*typ = '__';
	if	(path == NULL)
		path = mpath;
	if	(!a)
		a = &ma;
	*path = EOS;
	*a = NULL;
	if	(!f)
		f = &_f;


	ret = obj_to_path(w, obj, path, f);
	if	(ret == 0)						/* Datei */
		{
		if	((*f) && ((*f)->is_alias == 2))	/* unaufgelîster Alias */
			{
			*config = PGMT_NOEXE;
			*typ = 'AT';
			}
		else	path_typ(path, typ, config, a);
		return(ret);
		}
	if	(obj == 0)
		{
		*typ = '_F';
		return(ret);
		}
	if	(!w->handle)	/* Desktop */
		{
		switch(icon[obj-1].icontyp)
			{
			case ITYP_ORDNER:	*typ = '_O';break;
			case ITYP_DISK:	*typ = 'DO';break;
			case ITYP_PAPIER:	*typ = 'P_';break;
			case ITYP_DRUCKR:	*typ = 'D_';break;
			}
		return(ret);
		}
	*typ = '_O';
	return(ret);
}


/****************************************************************
*
* Initialisiert ein XARG-Argument
*
****************************************************************/

static void init_xarg(char **nxt_xarg, long *xarg_free)
{
	static char *xa = "\xfe" "ARGV=";

	strcpy(*nxt_xarg, xa);
	*nxt_xarg += 7;
	*xarg_free -= 8;	/* Platz fÅr Doppel-EOS am Ende! */
}


/****************************************************************
*
* FÅgt einen Parameter an eine Kommandozeile an.
* RÅckgabe -1 bei öberlauf.
* Wenn <do_spaces> gesetzt ist, werden Argumente mit Leerzeichen
* in Hochkommata eingeschlossen und dabei Hochkommata verdoppelt.
*
****************************************************************/

static int add_param(char *arg, char **nxt_xarg,
				long *xarg_free, int do_spaces)
{
	register char *s;
	long len,extra_len;
	int contains_spaces;

/*
Cconws("\"");
Cconws(arg);
Cconws("\"\r\n");
*/
	len = strlen(arg);
	contains_spaces = do_spaces && (strchr(arg, ' ') != NULL);
	if	(contains_spaces)
		{
		extra_len = 3;		/* 2 Hochkommas + EOS */

		/* Anzahl der Hochkommata zÑhlen */
		/* ----------------------------- */

		s = arg;
		do	{
			s = strchr(s, '\'');
			if	(s)
				{
				extra_len++;
				s++;
				}
			}
		while(s);
		}
	else	extra_len = 1;		/* fÅr EOS */

	if	(len+extra_len > *xarg_free)
		{
		Rform_alert(1, ALRT_OVL_CMDLINE);
		return(-1);
		}

	s = *nxt_xarg;
	if	(contains_spaces)
		{
		*s++ = '\'';
		if	(extra_len > 3)			/* Hochkommata */
			{
			while(*arg)
				{
				if	(*arg == '\'')
					*s++ = '\'';
				*s++ = *arg++;
				}
			}
		else	{
			strcpy(s, arg);
			s += len;
			}
		*s++ = '\'';
		*s++ = EOS;
		}
	else	{
		strcpy(s, arg);
		s += len+extra_len;
		}

	*nxt_xarg = s;
	*xarg_free -= len+extra_len;
	return(0);
}


/****************************************************************
*
* Entfernt die ÅberflÅssigen ' aus einer ARGV-Kette.
*
****************************************************************/

static void fix_xarg(char *xarg, char *nxt_xarg)
{
	register char *s,*t,*u;
	long len;
	long extra_len;


	if	(*xarg != '\xfe')		/* schon gewandelt ? */
		return;				/* ja, alles OK */
	s = xarg+7;				/* "\xfe" "ARGV= " Åberspr. */

	while(*s)
		{
		len = strlen(s);	/* LÑnge eines Arguments */
		if	((s[0] == '\'') && (s[len-1] == '\''))
			{
			s[len-1] = EOS;			/* letztes ' lîschen */
			extra_len = 2;
			if	(strchr(s+1, '\''))
				{
				t = s;
				u = s+1;
				while(*u)
					{
					if	(*u == '\'')
						{
						u++;			/* Hochkomma weglassen */
						extra_len++;
						}
					*t++ = *u++;
					}
				}
			else	{
				memcpy(s,s+1, len-extra_len);
				}
			memcpy(s+len-extra_len, s+len, nxt_xarg-(s+len));
			nxt_xarg -= extra_len;
			*nxt_xarg = EOS;			/* neue Endkennung! */
			len -= extra_len;			/* neue ArgumentlÑnge */
			}
		s += len + 1;
		}
}


/****************************************************************
*
* Wandelt einen ARGV-Block in eine normale Kommandozeile um.
* Wenn <fail> == TRUE: RÅckgabe -1 bei öberlauf.
*
* Dabei muû arg0 entfernt werden.
*
****************************************************************/

static int xarg2arg(char *xarg, char *nxt_xarg, int fail)
{
	register char *s,*t;
	long len;


	*nxt_xarg = EOS;			/* Endkennung */
	s = xarg+7;				/* "\xfe" "ARGV= " Åberspr. */
	if	(*s)
		s += strlen(s)+1;		/* arg0 Åberspringen */

	len = (*s) ? (nxt_xarg - s - 1) : 0;

	/* Wenn nur 126 Zeichen mîglich sind (normale Kommandozeile),	*/
	/* aber die LÑnge grîûer ist, muû ARGV gemacht werden.			*/
	/* Die ÅberflÅssigen ' bei Argumenten mit Leerzeichen kînnen 	*/
	/* noch nicht entfernt werden (wg. VA_START).				*/
	/* Anfangs-Bytekennung bleibt 0xfe							*/
	/* ------------------------------------------------------------- */

	if	(fail && (len > 126))
		return(-1);			/* öberlauf */

	/* Wenn die Parameter kÅrzer als 126 Zeichen sind oder wenn	die	*/
	/* KommandozeilenlÑnge unbegrenzt ist (fail == FALSE bei D&D und	*/
	/* ARGV), wird die Kommandozeile umgewandelt, d.h. EOS durch	*/
	/* Leerzeichen ersetzt.									*/
	/* Anfangs-Bytekennung ist die ParameterlÑnge, bzw., wenn > 126,	*/
	/* die 0.												*/
	/* ------------------------------------------------------------- */

	t = xarg+1;
	while(*s)
		{
		do	{
			*t++ = *s++;
			}
		while(*s);
		if	(s[1])
			{
			*t++ = ' ';
			s++;
			}
		}
	*t = EOS;
	if	(len > 126)
		len = 0;
	*xarg = (char) len;
	return(0);
}


/****************************************************************
*
* FÅr ein Programm wird der Parameterstring zusammengesetzt.
* Dateien im selben Verzeichnis wie das Programm werden ohne
* vollstÑndigen Pfad Åbergeben.
*
* Wenn <pgm> = NULL, werden nur ganze Pfade Åbergeben
*
* RÅckgabe: Anzahl Parameter
*		  -1 bei öberlauf der Kommandozeile
*
****************************************************************/

static int get_param(char *pgm, WINDOW *w, int obj,
				char **nxt_xarg, long *xarg_free)
{
	OBJECT *tree;
	register int iwnr,i;
	char path[128];
	char *endppath,rettc;
	int nargs;
	register WINDOW *iw;


	if	(pgm)
		{
		endppath = get_name(pgm);
		rettc = *endppath;
		*endppath = EOS;
		}
	nargs = 0;
	for	(iwnr = 0; iwnr <= ANZFENSTER; iwnr++)
		{
		iw = fenster[iwnr];
		if	(!iw)
			continue;				/* Fenster unbenutzt */
		tree = iw->pobj;
		if	((i = (tree -> ob_head)) > 0)
			{
			for	(; i <= (tree -> ob_tail); i++)
				{
				if	(w == iw && i == obj)
					continue;		/* Das Programm selbst */
				if	(!((tree+i)->ob_flags & HIDETREE) && selected(tree, i))
					{
					char rettc1;
					char *e;
					int  isne;

					if	(0 > obj_to_path(iw, i, path, NULL))
						continue;		/* Keine Datei */

					if	(pgm)
						{
						e = get_name(path);
						rettc1 = *e;
#if 0
						if	(!rettc1)
							continue;		/* Nullname */
#endif
						*e = EOS;
						isne = strcmp(pgm, path);
						*e = rettc1;
						}
					else	isne = TRUE;

					if	(isne)
						e = path;
					if	(add_param(e, nxt_xarg, xarg_free, TRUE))
						return(-1);	/* öberlauf */
					nargs++;
					}
				}
			}
		}
	if	(pgm)
		*endppath = rettc;
	return(nargs);
}


/***************************************************************************
*
* create a pipe for doing the drag & drop,
* and send an AES message to the recipient
* application telling it about the drag & drop
* operation.
*
* Input Parameters:
* apid:	AES id of the window owner
* winid:	target window (0 for background)
* msx, msy:	mouse X and Y position
*		(or -1, -1 if a fake drag & drop)
* kstate:	shift key state at time of event
*
* Output Parameters:
* exts:	A 32 byte buffer into which the
*		receipient's 8 favorite
*		extensions will be copied.
*
* Returns:
* A positive file descriptor (of the opened
* drag & drop pipe) on success.
* -1 if the receipient doesn't respond or
*    returns DD_NAK
* -2 if appl_write fails
*
****************************************************************************/

static int ddcreate(int apid, int winid, int msx, int msy, int kstate, char exts[])
{
	int fd;
	long i;
	int msg[8];
	long fd_mask;
	char c;
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";


	pipename[17] = 'A';
	pipename[18] = 'A' - 1;
	fd = -1;
	do	{
		pipename[18]++;
		if	(pipename[18] > 'Z')
			{
			pipename[17]++;
			if	(pipename[17] > 'Z')
				break;
			else	pipename[18] = 'A';
			}
		fd = (int) Fcreate(pipename, FAP_NOBLOCK);
		}
	while (fd == EACCDN);

	if	(fd < 0)
		return(fd);

/* construct and send the AES message */
	msg[0] = AP_DRAGDROP;
	msg[1] = ap_id;
	msg[2] = 0;
	msg[3] = winid;
	msg[4] = msx;
	msg[5] = msy;
	msg[6] = kstate;
	msg[7] = (pipename[17] << 8) | pipename[18];
	if 	(!appl_write(apid, 16, msg))
		{
		abort:
		Fclose(fd);
		return(-2);
		}

/* now wait for a response */

	fd_mask = 1L << fd;
	i = Fselect(DD_TIMEOUT, &fd_mask, NULL, 0L);
	if	(!i || !fd_mask)	/* timeout happened */
		{
		abort_nak:
		Fclose(fd);
		return(-1);
		}

/* read the 1 byte response */

	i = Fread(fd, 1L, &c);
	if	(i != 1L)
		goto abort;

	if	(c != DD_OK)
		goto abort_nak;

/* now read the "preferred extensions" */
	i = Fread(fd, DD_EXTSIZE, exts);
	if	(i != DD_EXTSIZE)
		goto abort;

	return(fd);
}


/***********************************************************************
*
* see if the recipient is willing to accept a certain
* type of data (as indicated by "ext")
*
* Input parameters:
* fd			file descriptor returned from ddcreate()
* ext		pointer to the 4 byte file type
* name		pointer to the name of the data
* size		number of bytes of data that will be sent
*
* Output parameters: none
*
* Returns:
* DD_OK	if the receiver will accept the data
* DD_EXT	if the receiver doesn't like the data type
* DD_LEN	if the receiver doesn't like the data size
* DD_NAK	if the receiver aborts
*
***********************************************************************/

static int ddstry(int fd, char *ext, char *name, long size)
{
	int  hdrlen;
	long i;
	char c;

/* 4 bytes for extension, 4 bytes for size, 1 byte for
 * trailing 0
 */
	hdrlen = 9 + (int) strlen(name);
	i = Fwrite(fd, 2L, &hdrlen);

/* now send the header */
	if	(i != 2)
		return(DD_NAK);
	i = Fwrite(fd, 4L, ext);
	i += Fwrite(fd, 4L, &size);
	i += Fwrite(fd, (long)strlen(name)+1, name);
	if	(i != hdrlen)
		return(DD_NAK);

/* wait for a reply */
	i = Fread(fd, 1L, &c);
	if	(i != 1)
		return(DD_NAK);
	return(c);
}


/*********************************************************************
*
* Drag&Drop ins fremde Fenster <whdl>.
* RÅckgabe: 0	Erfolg
*		 -1	fataler Fehler
*
*********************************************************************/

int drag_and_drop(int whdl, int kbsh, int mx, int my)
{
	int client_id;
	/* long oldpipesig; */
	int fd;
	int ret;
	char *xarg,*nxt_xarg;
	long xarg_free,datalen;


	if	(!wind_get_int(whdl, WF_OWNER, &client_id))
		return(-1);

	xarg_free = MAX_PARAMLEN;
	xarg = nxt_xarg = Malloc(xarg_free+3);	/* Platz fÅr Kommandozeile */
	if	(!xarg)
		{
		err_alert(ENSMEM);
		return(-1);
		}
	init_xarg(&nxt_xarg, &xarg_free);

	/* dummy als arg0 eintragen */

	add_param(".", &nxt_xarg, &xarg_free, TRUE);

/*	oldpipesig = Psignal(__MINT_SIGPIPE, __MINT_SIG_IGN); */

	fd = ddcreate(client_id, whdl, mx, my, kbsh, nxt_xarg);

	if	(fd < 0)
		{
		Mfree(xarg);
/*		(void)Psignal(__MINT_SIGPIPE, oldpipesig); */
		if	(fd == -1)
			Rform_alert(1, ALRT_DD_FAILURE);
		return(-1);
		}
	/* gewÅnschte Dateitypen <exts> ignorieren */

	get_param("*", NULL, -1, &nxt_xarg, &xarg_free);
	xarg2arg(xarg, nxt_xarg, FALSE);	/* umwandeln in normale Parameterliste */
	datalen = strlen(xarg+1)+1;	/* Anzahl Bytes inkl. EOS */

	ret = ddstry(fd, "ARGS", "", datalen);

	if	(ret == DD_OK)
		Fwrite(fd, datalen, xarg+1);	/* exts+1 wg. ohne LÑnge */
	else	{
		Rform_alert(1, ALRT_DD_NO_CMDLN);
		}
	Mfree(xarg);
	Fclose(fd);
/*	(void)Psignal(__MINT_SIGPIPE, oldpipesig); */
	return(0);
}


/*********************************************************************
*
* Testet einen Pfad, ob er ein Programm darstellt, und gibt
* ggf. eine Fehlermeldung aus.
* gibt den Typ zurÅck.
*
*********************************************************************/

int tst_exepath(char *path)
{
	int typ;

	typ = suffixtyp(path);
	if	(typ == PGMT_NOEXE)
		{
		Rform_alert(1, ALRT_NO_PGM_ASNG);
		}
	return(typ);
}


/*********************************************************************
*
* Doppelklick auf Fenster <wnr> bzw. Desktopicon (wnr == 0)
* Icon- Objeknummer <obj> bei Shift- Status <kbsh>.
* RÅckgabe 1: Icon nach Aktion wieder deselektieren.
*
* Textdateien: CTRL		in Texteditor laden
*
* Programme:   CTRL		immer Parameter holen (TTP)
*			ALT		Shell zum Programmstart verlassen
*
*********************************************************************/

int dclick(WINDOW *w, int obj, int kbsh)
{
	APPLICATION *ap;
	int		ret,typ;
	int		pgm_config;
	char		path[200];
	MYDTA	*file;


	path[0] = EOS;
	ret = obj_typ(w, obj, path, &file, &typ, &pgm_config, &ap);

/*
if	(ret < 0)
	Cconws("ret < 0 ");
else
if	(ret == 0)
	Cconws("ret == 0 ");
else
	Cconws("ret > 0 ");
Cconws("typ = ");
Cconout((char) (typ >> 8)); Cconout((char) typ);
Cconout(' ');
Cconws(path);
*/

	if	(strlen(path) > 127)
		{
		err_alert(EPTHOV);
		return(0);
		}
	if	(ret < 0)			/* weder Datei noch Pfad */
		{
		switch(typ)
			{
			case 'D_':
			case 'P_': Rform_alert(1, ALRT_CANT_OPEN);
					 break;
			default  : err_alert(EINTRN);
					 break;
			}
		return(0);
		}

	/* Doppelklick auf Pfad (Ordner oder Disk) */
	/* --------------------------------------- */

	if	(ret == 1)
		{

		/* Doppelklick auf Icon. Neues Fenster îffnen */
		/* ------------------------------------------ */

		if	(!w->handle)
			{
			opn_newwnd(path);
			return(0);
			}

		/* Doppelklick auf Ordner in Fenster		 */
		/* ------------------------------------------ */

		if	(typ == '_O')
			{
			if	(kbsh & K_ALT)
				{
				opn_newwnd(path);
				}
			else	{
				strcpy(w->path, path);
				if	(w->flags & WFLAG_ICONIFIED)
					{
					int msg[8];

					msg[0] = WM_UNICONIFY;
					msg[1] = ap_id;
					msg[2] = 0;
					msg[3] = w->handle;
					wind_get_grect(w->handle, WF_UNICONIFY,
							(GRECT *) (msg+4));
					appl_write(ap_id, 16, msg);
					}
				else	upd_path(w, FALSE);
				}
			}
		}

	/* Doppelklick auf Datei (Programm oder Textdatei oder ... ) 	*/
	/*  1) Datei ist kein Programm, CTRL gedrÅckt:				*/
	/*		Datei(en) mit Standard- Editor aufrufen				*/
	/*  2) Datei ist nicht ausfÅhrbar oder ALT gedrÅckt:			*/
	/*		Datei anzeigen									*/
	/*  3) Datei ist ausfÅhrbar (PGM,BAT,angem. Datei):			*/
	/*		starten										*/
	/* ------------------------------------------------------------- */

	else {
		if	((typ != '_X') && (kbsh & K_CTRL))
			{

			/* CTRL+ALT mit Textdatei: Anzeigen		*/
			/* ----------------------------------------- */

			if	(kbsh & K_ALT)
				prt_icns(w, FALSE);

			/* CTRL mit Textdatei: Editor starten		*/
			/* ----------------------------------------- */

			else	{
				strcpy(path, menuprograms[3].path);
				typ = tst_exepath(path);
				if	(typ != PGMT_NOEXE)
					{
					ap = path_to_app(path);
					starten(path, NULL, typ, ap, w, 0, kbsh & ~K_CTRL);
					}
				}
			return(0);
			}
		if	(typ == '_T')
			{
			prt_icns(w, FALSE);
			return(0);
			}
	 	if	((typ & 0xff) == 'X')
	 		{
			starten(path, NULL, pgm_config, ap, w, obj, kbsh);
			return(kbsh & K_ALT);
			}
		}
	return(0);
}


/****************************************************************
*
* Ein Fenster wird geîffnet, das den Pfad <path> und die
* Maske <mask> zeigt.
* Wenn <sel_mask> != NULL ist, wird die entsprechende Datei
* bzw. das Muster selektiert.
*
* Dies ist die Antwort auf die Nachricht AV_XOPENWIND.
* Diese Routine wird aufgerufen, wenn MGSEARCH eine Datei an
* MAGXDESK Åbergibt.
*
****************************************************************/

static void set_selmask(WINDOW *w, char *sel_mask)
{
	extern void upperstring( char *s );	/* pattern.c */
	int len;

	if	(sel_mask)
		{
		len = (int) strlen(sel_mask);
		strncpy(w->sel_maske, sel_mask, MAX_SELMASK);
		if	(len > MAX_SELMASK)
			w->sel_maske[MAX_SELMASK-1] = '*';
		upperstring(w->sel_maske);
		upd_selmask(w);
		}
}

void open_window(char *path, char *mask, char *sel_mask,
			int new)
{
	register WINDOW **pw,*w,*new_w;
	register int wnr,free;
	long ret;


	/* passendes bzw. freies Fenster suchen */

	for	(wnr = 1,pw = fenster+1,free = 0;
			wnr <= ANZFENSTER; wnr++,pw++)
		{
		w = *pw;

		/* passendes Fenster gefunden */
		/* -------------------------- */

		if	(!new && (w) && (!strcmp(path, w->path)))
			{
			if	(*mask && (strcmp(w->maske, mask)))
				{
				strcpy(w->maske, mask);
				upd_mask(w);
				}
			set_selmask(w, sel_mask);
			w->topped(w);
			return;
			}

		/* erstes freies Fenster gefunden */
		/* ------------------------------ */
		
		if	(!free && (!w))
			{
			free = wnr;
			if	(new)
				break;
			}
		}

	if	(!free)
		ret = ENOWND;
	else	{
		new_w = create_wnd( free, path, mask, 0, 0, &ret);
		if	(new_w)
			{
			ret = opn_wnd(new_w, FALSE);
			if	(ret)
				delete_wnd(new_w);
			}
		}

	if	(ret)
		{
		if	(ret == ENOWND)
			{
			Rform_alert(1, ALRT_NO_MORE_WND);
			}
		else	err_alert(ret);
		return;
		}
	set_selmask(new_w, sel_mask);
}


/****************************************************************
*
* Ein neues Fenster mit Pfad <path> wird geîffnet.
*
****************************************************************/

void opn_newwnd(char *path)
{
	open_window(path, "", NULL, TRUE);
}


/****************************************************************
*
* FÅr ein Programm wird der Pfad gesetzt.
*
* stdpath = TRUE: Das Programm wird in den Fensterpfaden
* gestartet.
*
****************************************************************/

static long setpath(char *program, int stdpath)
{
	long doserr;
	char	rett,*endp;
	char *path;
	register int i;
	WINDOW **pw,*w,*tw;



	if	(!stdpath)		/* Programm- Pfad */
		{
		endp = get_name(program);
		rett = *endp;
		*endp = EOS;
		if	(program[0] && program[1] == ':')
			Dsetdrv(program[0] - 'A');
		if	(program < endp)
			doserr = Dsetpath(program);
		else doserr = E_OK;
		*endp = rett;
		}
	else {
		/* KAOSDESK- Pfad */
		tw = top_window();		/* Nummer des obersten Fensters */
		for	(i = 1,pw = fenster+1; i <= ANZFENSTER; i++)
			{
			w = *pw++;
			if	((w) && (w != tw))
				Dsetpath(w->path);
			}
		if	((tw) && (tw->wnr))	/* nicht Fenster #0 */
			{
			path = tw->path;
			Dsetdrv (path[0] - 'A');
			Dsetpath(path);
			}
		doserr = E_OK;
		}
	return(err_alert(doserr));
}


/****************************************************************
*
* Testet, ob ein Programm schon lÑuft, und schickt ggf. VA_START.
*
* Liefert TRUE, wenn VA_START oder eine Ñquivalente Aktion
* durchgefÅhrt werden konnte. Im Fall FALSE muû der Aufrufer
* das Programm starten.
*
* Ist <nxt_arg> != NULL, zeigt <param> auf einen allozierten
* Block, in dem die Parameter liegen. Es wird dann eine
* erweiterte AES-Nachricht verschickt, bei der der Block an
* den Aufrufer Åbergeben wird.
*
****************************************************************/

static int do_va_start(char *program, COMMAND *param,
				char *nxt_xarg, char *mem,
				int app_knows_vastart, int prompt)
{
	char apname[9];
	int	msg[8];
	int  dst_apid,ret;


	/* Wenn mîglich, VA_START aufrufen */

	get_app_name(program, apname);

	if	((dst_apid = appl_find(apname)) >= 0)
		{
		/* Programm lÑuft schon ! */
		msg[1] = ap_id;
		msg[2] = 0;
		if	(app_knows_vastart)
			{
			XAESMSG xmsg;

			if	(param->length == 0xfe)
				xarg2arg((char*) param, nxt_xarg, FALSE);
			else	param->command_tail[param->length] = EOS;

			msg[0] = VA_START;
			msg[5] = 'XA';			/* Kennung fÅr erweitertes V.. */
			*((void **) (msg+3)) = param->command_tail;

			xmsg.dst_apid = dst_apid;
			xmsg.unique_flg = FALSE;
			xmsg.attached_mem = mem;
			xmsg.msgbuf = msg;

			if	(mem)
				Mshrink(mem, strlen(mem+1)+3);
			if	(0 >= appl_write(-2, 16, &xmsg))
				{
				Mfree(mem);
				err_alert(ERROR);
				}
			return(TRUE);
			}
		if	(prompt)
			{
			ret = Rform_alert(1, ALRT_APPISACTIVE);
			if	(ret == 1)
				return(FALSE);
			msg[0] = SM_M_SPECIAL;
			msg[3] = 0;
			msg[4] = 'MA';
			msg[5] = 'GX';
			msg[6] = 2;		/* SMC_SWITCH */
			msg[7] = dst_apid;
			appl_write(1, 16, msg);	/* -> SCRENMGR */
			return(TRUE);
			}
		}
	return(FALSE);
}


/****************************************************************
*
* Ein Programm <path> wird gestartet.
*
* Programmtyp muû ermittelt werden.
*
****************************************************************/

int start_path(char *path, char *tail, int kbsh)
{
	APPLICATION *a;
	int typ, config;
	char *pgm;
	char cmd[128];


	path_typ(path, &typ, &config,	&a);
	if	((typ == '_T') && (!a) && (!tail))
		{
/*
Cconws("#");
Cconws(path);
Cconws("#\r\n");
*/
		pgm = menuprograms[1].path;	/* Anzeigeprogramm */
		typ = tst_exepath(pgm);
		if	(typ != PGMT_NOEXE)
			{
			typ &= ~PGMT_TP;	/* .TTP -> .TOS */
			tail = path;
			config = typ;
			path = pgm;
			if	(pgm[0] && (pgm[1] != ':'))
				{
				path = cmd;
				strcpy(cmd, desk_path);
				strcat(cmd, pgm);
				}
			}
		}
	return(starten(path, tail, config, a, NULL, -1, kbsh));
}


/****************************************************************
*
* Ein Hilfsprogramm der Shell wird gestartet.
* Wenn <is_multi> = FALSE ist, wird ein AV_START geschickt,
* falls das Programm schon lÑuft.
*
* <isargv> ist meistens FALSE, bis auf den Aufruf von
* MGCOPY.
*
****************************************************************/

void starte_dienstpgm(char *name, int is_multi, int isargv,
					char *arg1, char *arg2, char *arg3)
{
	char	cmd[128];
	char *x;
	long datalen;
	char xargs[512];


	strcpy(cmd, desk_path);
	strcat(cmd, name);

	if	(!isargv)
		{
		x = xargs;
		datalen = 254L;	/* zusÑtzl. Nullbyte berÅcksichtigen */
		init_xarg(&x, &datalen);
		add_param(".", &x, &datalen, TRUE);	/* Dummy - arg0 */
		if	(arg1)
			add_param(arg1, &x, &datalen, TRUE);
		if	(arg2)
			add_param(arg2, &x, &datalen, TRUE);
		if	(arg3)
			add_param(arg3, &x, &datalen, TRUE);
		xarg2arg(xargs, x, FALSE);	/* umwandeln in normale Parameterliste */
		arg1 = xargs;
		}

	if	(setpath(cmd, FALSE))
		return;
	if	(!is_multi && do_va_start(cmd, (COMMAND *) arg1, NULL, NULL,
				TRUE, FALSE))
		return;
	shel_write(TRUE, TRUE, SHW_PARALLEL, cmd, arg1);
}


/****************************************************************
*
* Ein Programm wird gestartet.
*
*	-	Klick auf Programmdatei, Programm ist angemeldet
*		config ist Extension, ap->config Åberlagert
*	-	Klick auf Programmdatei, nicht angemeldet
*		config ist Extension, ap ist NULL
*	-	Klick auf Batchdatei
*		config ist PGMT_BATCH, ap ist NULL
*	-	Klick auf angemeldete Datei
*		config ist -1, a ist zugehîrige APP
*
* Wenn w == NULL ist, werden keine Parameter in Form von
* selektierten Icons angehÑngt (z.B. bei ^B).
* Wenn kbsh = -1 ist, wird statt res_exec() eine -1 geliefert.
*
* Es wird zunÑchst eine lange Kommandozeile (max 10k) erstellt,
* die wenn sie keine Dateinamen mit Leerstellen enthÑlt sowie
* kÅrzer als 127 Bytes ist, in eine normale Kommandozeile
* gewandelt wird.
*
* RÅckgabe:	0	Programm nicht gestartet
*			1	Programm gestartet
*
****************************************************************/

int starten(char *path, char *tail, int config, APPLICATION *ap,
			WINDOW *w, int obj, int kbsh)
{
	char		*program;					/* argv[0] */
	char		*arg1;					/* argv[1] */

	char		*xarg,*nxt_xarg;
	long		xarg_free;
	int		is_long_arg;

	char		*shw_cmd;
	XSHW_COMMAND	xcmd;
	int		add_args;
	int 		stdpath;			/* Flag: in Fensterpfaden starten */
	int 		isgr,doex,isover;
	char		*execpath;		/* In diesem Pfad starten */
	long  	doserr;
	int		success = FALSE;
	int		do_res_exec = TRUE;
	WINDOW	*tw;



	if	(kbsh == -1)		/* fÅr VA/AV_STARTPROG */
		{
		do_res_exec = FALSE;
		kbsh = 0;
		}

	xarg_free = MAX_PARAMLEN;
	xarg = nxt_xarg = Malloc(xarg_free+3);	/* Platz fÅr Kommandozeile */
	if	(!xarg)
		{
		err_alert(ENSMEM);
		return(0);
		}
	
	execpath = arg1 = NULL;
	init_xarg(&nxt_xarg, &xarg_free);

	if	(config == PGMT_NOEXE)	/* angem. Datei */
		{
		if	(!ap)
			{
			Rform_alert(1, ALRT_NO_PGM_ASNG);
			goto ende;
			}
		config = ap->config;
		program = ap->path;
		arg1 = path;
		}
	else
	if	(config & PGMT_BATCH)
		{
		execpath = path;		/* akt. Pfad = Batchdatei */
		program = menuprograms[INDEX_CMD].path;
		ap = path_to_app(program);
		if	(ap)
			config = (ap->config | (config & PGMT_TP));
		else	config = (suffixtyp(program) | (config & PGMT_TP));
		arg1 = path;
		}
	else	{
		program = path;
		if	(ap)
			config = ap->config;
		}

	stdpath = FALSE;
	if	(!execpath)			/* steht noch kein Pfad fest */
		{
		if	(!(config & PGMT_WINPATH))
			execpath = program;
		else	{
			tw = top_window();
			if	(tw)
				execpath = tw->path;
			stdpath = TRUE;	/* execpath = Fenster */
			}
		}

	/* Das Programm selbst muû als ARG0 eingetragen werden.	*/
	/* Bei der Umwandlung muû der Parameter entfernt werden.	*/
	/* -------------------------------------------------------- */

	if	(add_param(program, &nxt_xarg, &xarg_free, TRUE))
		goto ende;

	/* alle aktivierten Icons auûer dem doppelgeklickten werden als	*/
	/* Parameter Åbernommen (nicht bei Batchprozessor Åber ^B).		*/
	/* ------------------------------------------------------------- */


	if	(arg1)
		{
		if	(add_param(arg1, &nxt_xarg, &xarg_free, TRUE))
			goto ende;
		}

	if	(tail)	/* Hier Leerzeichen belassen */
		{
		if	(add_param(tail, &nxt_xarg, &xarg_free, FALSE))
			goto ende;
		}

	if	(w)
		add_args = get_param(execpath, w, obj, &nxt_xarg, &xarg_free);
	else	add_args = 0;

	if	(add_args < 0)
		goto ende;

	/* Wenn mîglich, wird die Liste der Parameter in eine normale	*/
	/* Kommandozeile gewandelt.								*/
	/* ------------------------------------------------------------- */

	is_long_arg = xarg2arg(xarg, nxt_xarg, TRUE);

	/* Parameter werden manuell geholt, wenn dies mit CTRL erzwungen	*/
	/* wurde oder wenn es eine BTP- Datei ist oder wenn es ein TTP-	*/
	/* Programm ist und sonst keine Parameter vorliegen			*/
	/* ------------------------------------------------------------- */

	if	(!is_long_arg &&
		((kbsh & K_CTRL) || ((config & PGMT_TP) && !add_args)))
		{
		if	(!dial_ttppar(program, xarg+1))
			goto ende;
		xarg[0] = (char) strlen(xarg+1);
		}

	/* Ein kleiner Patch fÅr uralte Programme */
	/* -------------------------------------- */

	if	(!is_long_arg && (xarg[0] < 126))
		{
		xarg[xarg[0]+1] = '\r';
		xarg[xarg[0]+2] = EOS;
		}


	err_file = program;
	if	(setpath(execpath, stdpath))
		goto ende;

	/* Nachsehen, ob die Datei Åberhaupt existiert	*/
	/* ---------------------------------------------- */

	err_file = program;
	doserr = Fattrib(program, 0, 0);
	if	(doserr < E_OK)
		{
		err_alert(doserr);
		goto ende;
		}

	/* ACC starten */
	/* ----------- */

	if	(config & PGMT_ACC)
		{
		if	(do_va_start(program, (COMMAND *) xarg, nxt_xarg, xarg,
			 		!(config & PGMT_NVASTART), TRUE))
			return(1);
		fix_xarg(xarg, nxt_xarg);
		if	(!shel_write(SHW_EXEC_ACC, 0, 0, program, NULL))
			err_alert(ENSMEM);
		else	success = TRUE;
		goto ende;
		}

	/* Parameter fÅr "MAGXDESK resident" oder "nichtresident"	*/
	/*	und Parameter "doex" setzen.						*/
	/* -------------------------------------------------------- */

	doex = SHW_EXEC;
	if	(ap)
		{
		if	(ap->memlimit)
			{
			doex |= SHW_XMDLIMIT;
			xcmd.limit = (ap->memlimit << 10L);	/* B -> kB */
			}
		if	(ap->config & PGMT_NO_PROPFNT)
			{
			doex |= SHW_XMDFLAGS;
			xcmd.flags = 1L;
			}
		}

	if	(doex & 0xff00)
		{
		xcmd.command = program;
		shw_cmd = (char *) &xcmd;
		}
	else	shw_cmd = program;


	isover = SHW_CHAIN;
	isgr = (config & PGMT_ISGEM) != 0;
	if	(status.resident)
		kbsh ^= K_ALT;				/* MAGIX: ggf. per Default parallel */
	if	(kbsh & K_ALT)
		isover = SHW_PARALLEL;		/* MAGIX: Multitasking EXEC */
	if	(config & PGMT_SINGLE)
		isover = SHW_SINGLE;		/* MagiX: single mode */


	/* Im Fall "Multitasking starten" wird einfach der Aufruf		*/
	/* gemacht, und MAGXDESK lÑuft weiter						*/
	/* ------------------------------------------------------------- */

	err_file = NULL;
	if	(isover == SHW_PARALLEL)
		{
		/* TOS-Programme kennen kein VA_START */
		if	(do_va_start(program, (COMMAND *) xarg, nxt_xarg, xarg,
			 		(isgr && !(config & PGMT_NVASTART)), isgr))
			return(1);

		fix_xarg(xarg, nxt_xarg);
		if	(!shel_write(doex, isgr, SHW_PARALLEL,
						shw_cmd, xarg))
			err_alert(ENSMEM);
		else	success = TRUE;
		goto ende;
		}

	/* Andernfalls werden alle Fenster geschlossen und gelîscht,	*/
	/* um Speicher fÅr das aufrufende Programm freizumachen.		*/
	/* Auch MenÅ und Hintergrund abschalten.					*/
	/* ------------------------------------------------------------- */

	save_status(FALSE);
	close_all_wind();	/* Fenster/MenÅ/Hintergrund */

	/* Hier wird MAGXDESK nichtresident verlassen.				*/
	/* Als letzte Aktion werden die Einstellungen abgespeichert		*/
	/* ------------------------------------------------------------- */

	if	(isover == SHW_CHAIN)
		/* Pfade an den Parent weiterreichen: */
		shel_write(doex, isgr, SHW_SINGLE, shw_cmd, xarg);
	fix_xarg(xarg, nxt_xarg);
	if	(!shel_write(doex, isgr, isover, shw_cmd, xarg))
		goto ende;
	Mfree(xarg);
	xarg = NULL;
	v_clsvwk(vdi_handle);
	wind_update(END_UPDATE);
	/* Falls per ^O gestartet: MenÅtitel deselektieren */
	adr_hauptmen[MM_DATEI].ob_state &= ~SELECTED;
	if	(do_res_exec)
		res_exec();
	return(-1);

  ende:
	if	(xarg)
		Mfree(xarg);
	return(success);
}
