/*******************************************************************
*
*             MOD_APP.TTP                            28.04.98
*             ===========
*                                 letzte énderung:
*
* geschrieben mit Pure C V1.1
* Projektdatei: PCX_TTP.PRJ
*
* Programm zur Modifikation von APPLICAT.INF. Das Programm sollte
* auch unter TOS laufen kînnen.
*
* Parameter:
*
*	-Xis key[4] name icondatei iconnr
*
*	X ist das MagiC-Laufwerk
*	Icon fÅr "special object" anmelden. z.B.
*	key=PARD name=MAGICICN.RSC iconnr=132
*
*	-Xia pgmname rscname iconnr path|- code
*
*	X ist das MagiC-Laufwerk
*	Anwendung anmelden, z.B.
*	pgmname = mupfel.prg rscname=MAGICICN.RSC path=c:\mupfel.prg
*	iconnr=132 code=1(GEM)
*
*	-Xid pgmname dat rscname iconnr
*
*	X ist das MagiC-Laufwerk
*	Dateityp fÅr Applikation anmelden, z.B.
*	pgmname = mupfel.prg dat=*.BAT rscname=MAGICICN.RSC iconnr=132
*
* RÅckgabewert:
*
*	0				OK
*	< 0				Systemfehler
*	1				Syntaxfehler beim Aufruf
*	2				Formatfehler in APPLICAT.INF
*	3				Kennung schon vergeben
*	4				Applikation nicht eingetragen (-id)
*	5				Pfad fÅr Applikation fehlt (-id)
*
*
* noch nicht eingebaut:
*
*	-ad	appath dat	; angemeldete Datei modifizieren
*
*	-io	opath		; Icon fÅr Ordner/Disk anmelden
*
*
* ----------------------------------------------------------------
*
* Textdatei fÅr APPLICAT:
* Konfigurationsdatei applicat.inf:
*
*	magic			; Zeile mit "applicat.inf" und Versionsnummer
*	[Programmname]
*	.... (Programmdaten):
*		Icon mit RSC-Dateiname, Icon-Name und Index (oder Leerzeile)
*		kompletter Pfad oder Leerzeile
*		Konfigurationsangaben im Klartext ("TTP", "Single")
*		Dateitypen, jeweils einer pro Zeile
*	[Programmname]
*	.... (Programmdaten)
*	[Dateityp]
*	.... (Dateidaten)
*		Icon mit RSC-Dateiname, Icon-Name und Index (oder Leerzeile)
*
****************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <mgx_dos.h>

#define DEBUG 0

#if DEBUG
char *infname = "C:\\PC\\SOURCE\\DESKUTIL\\MOD_APP\\APPLICAT.INF";
char *bakname = "C:\\PC\\SOURCE\\DESKUTIL\\MOD_APP\\APPLICAT.BAK";
char *datname = "C:\\PC\\SOURCE\\DESKUTIL\\MOD_APP\\APPLICAT.DAT";
#else
char *infname = "C:\\GEMSYS\\GEMDESK\\APPLICAT.INF";
char *bakname = "C:\\GEMSYS\\GEMDESK\\APPLICAT.BAK";
char *datname = "C:\\GEMSYS\\GEMDESK\\APPLICAT.DAT";
#endif

char *buf = NULL;
char *new_line = NULL;
char *ins_pos;
char drv;

/*********************************************************************
*
* Ermittelt zu einem Programmnamen den zugehîrigen
* Sektionsnamen.
*
*********************************************************************/

char *name_to_section( char *s, char *name)
{
	register int i;

	*s++ = '[';
	for	(i = 0; i < 8; i++)
		{
		if	(*name == '.' || *name == EOS)
			break;
		*s++ = toupper(*name++);
		}
	*s++ = ']';
	return(s);
}


/*********************************************************************
*
* Erzeugt die Zeile
*	RSCNAME.RSC NNNN "-"
*
*********************************************************************/

char *cr_rscinfo( char *s, char *rscname, int iconnr )
{
	strcpy(s, rscname);
	s += strlen(s);
	*s++ = ' ';
	itoa(iconnr, s, 10);
	strcat(s, " \"-\"\r\n");
	s += strlen(s);
	return(s);
}


/*******************************************************************
*
* APPLICAT.INF mit eingefÅgten Daten schreiben
*
****************************************************************/

static long ainf_save( void )
{
	long ret,len;
	int f;
	long magic;


	if	(!new_line)
		return(E_OK);			/* nix zu tun */

	Fdelete(bakname);
	ret = Frename(0, infname, bakname);
	if	(ret)
		return(ret);
	ret = Fcreate(infname, 0);
	if	(ret < 0)
		return(ret);
	f = (int) ret;

	/* Anfang schreiben */

	len = ins_pos - buf;
	if	(len)
		{
		ret = Fwrite(f, len, buf);
		if	((ret > 0) && (ret < len))
			ret = -1L;
		if	(ret < 0)
			{
			 err:
			Fclose(f);
			Fdelete(infname);
			Frename(0, bakname, infname);
			return(ret);
			}
		}

	/* neue Zeile(n) schreiben */

	len = strlen(new_line);
	if	(len)
		{
		ret = Fwrite(f, len, new_line);
		if	((ret > 0) && (ret < len))
			ret = -1L;
		if	(ret < 0)
			goto err;
		}

	/* Rest schreiben */

	len = strlen(ins_pos);
	if	(len)
		{
		ret = Fwrite(f, len, ins_pos);
		if	((ret > 0) && (ret < len))
			ret = -1L;
		if	(ret < 0)
			goto err;
		}

	/* DAT modifizieren */

	ret = Fopen(datname, RMODE_RW);
	if	(ret >= 0)
		{
		f = (int) ret;
		ret = Fread(f, sizeof(magic), &magic);
		if	((ret == sizeof(magic)) && (magic == 'AnKr'))
			{
			ret = Fseek(0L, f, SEEK_SET);		/* zurÅck */
			if	(!ret)
				{
				magic = 'BnKr';
				Fwrite(f, sizeof(magic), &magic);
				}
			}
		Fclose(f);
		}
	return(E_OK);
}


/*******************************************************************
*
* APPLICAT.INF îffnen
*
* RÅckgabe: 0 (OK), <0 (Systemfehler) oder 2 (Formatfehler)
*
****************************************************************/

static long ainf_open( void )
{
	long ret,len;
	int f;


	ret = Fopen(infname, RMODE_RD);
	if	(ret < 0)
		return(ret);
	f = (int) ret;
	len = Fseek(0L, f, SEEK_END);		/* DateilÑnge bestimmen */
	if	(len > 0)
		{
		ret = Fseek(0L, f, SEEK_SET);
		if	(ret)
			len = -1L;
		}
	if	(!len)
		{
		Fclose(f);
		return(2);				/* Formatfehler */
		}
	if	(len < 0)
		{
		Fclose(f);
		return(len);
		}

	buf = Malloc(len+1);
	if	(!buf)
		{
		Fclose(f);
		return(ENSMEM);
		}
	buf[len] = '\0';				/* Ende-Zeichen */
	ret = Fread(f, len, buf);
	Fclose(f);

	if	((ret > 0) && (ret < len))
		ret = ERROR;
	if	(ret < 0)
		{
		Mfree(buf);
		buf = NULL;
		return(ret);
		}
	if	(strncmp(buf, "[APPLICAT Header V ", 19))
		return(2);			/* Formatfehler */
	return(E_OK);
}


/*******************************************************************
*
* neue, einzufÅgende Zeile zusammenstellen.
*
****************************************************************/

static long is_get_new_line(char *key, char *name, char *rscname,
					int iconnr, char **line)
{
	static char l[] = "ABCD 012345678901234567890123456789 "
				"01234567.RSC 99999 \"0123456789abcdefg\"\r\n";

	if	(strlen(key) != 4)
		return(1);
	if	(strlen(rscname) > 12)
		return(1);
	memcpy(l, key, 4);
	if	(strlen(name) > 30)
		return(1);
	strcpy(l+5, name);
	strcat(l, " ");
	cr_rscinfo( l+strlen(l), rscname, iconnr );
	*line = l;
	return(E_OK);
}


/*******************************************************************
*
* Position fÅr einzufÅgende Zeile ermitteln.
*
****************************************************************/

static long is_get_insert_position(char *key, char **line)
{
	static char findstr[] = "\r\nABCD ";
	char *beg,*end;
	char *s;
	static char *spec_part = "\r\n[<Spezial>]\r\n";


	*line = NULL;

	/* Beginn des Abschnitts suchen */
	beg = strstr(buf, spec_part);
	if	(!beg)
		{
#if DEBUG
		printf("Abschnitt [<Spezial>] nicht gefunden\n");
#endif
		return(2);				/* Formatfehler */
		}
	beg += strlen(spec_part) - 2;		/* auf vorh. Zeilenende */

	/* Ende des Abschnitts suchen */

	end = strstr(beg, "\r\n[");
	if	(!end)
		return(2);				/* Formatfehler */
	end += 2;
	*end = '\0';					/* EOS statt [ */

	/* nachsehen, ob der SchlÅssel schon vorkommt */

	memcpy(findstr+2, key, 4);
	s = strstr(beg, findstr);
	*end = '[';					/* wieder [ */
	if	(s)
		return(3);				/* Kennung schon da */

	/* EinfÅgepunkt ist vor nÑchstem Abschnitt */

	*line = end;

	return(E_OK);
}


/*******************************************************************
*
* Schalter 'is'
*
*******************************************************************/

long do_mode_is( char *key, char *name, char *rscname,
				int iconnr)
{
	long ret;

	/* neue Daten bestimmen */

	ret = is_get_new_line(key, name, rscname, iconnr, &new_line);
	if	(ret)
		{
#if DEBUG
		printf("Fehler %ld beim Bestimmen der Daten\n", ret);
#endif
		return((int) ret);
		}

	/* EinfÅgeposition festlegen */

	ret = is_get_insert_position(key, &ins_pos);
	if	(ret)
		{
#if DEBUG
		printf("Fehler %ld beim Bestimmen der EinfÅgeposition\n", ret);
#endif
		return((int) ret);
		}
	return(E_OK);
}


/*******************************************************************
*
* Schalter 'ia'
*
*******************************************************************/

long do_mode_ia( char *pgmname, char *rscname, int iconnr,
				char *path, int code)
{
	static char ins_data[] =
			"[12345678]\r\n"
			"12345678.rsc 99999 \"-\"\r\n"
			"1234567890123456789012345678901234567890"
			"1234567890123456789012345678901234567890"
			"1234567890123456789012345678901234567890"
			"12345678\r\n"
			"99999\r\n";
	char *s,*t;
	int cmp;
	long namelen;


	if	(strlen(rscname) > 12)
		return(1);
	if	(strlen(path) > 128)
		return(1);
	s = name_to_section(ins_data, pgmname);
	namelen = s - ins_data;
	*s++ = '\r';
	*s++ = '\n';

	t = buf;
	while(1)
		{
		t = strstr(t, "\r\n[");	/* nÑchste Applikation suchen */
		if	(!t)
			return(2);		/* Formatfehler */
		if	(t[3] == '<')		/* erste Spezial-Section */
			cmp = 1;
		else	{
			cmp = strncmp(t+2, ins_data, namelen);
			if	(!cmp)
				return(3);	/* Kennung schon vergeben */
			}
		if	(cmp > 0)
			{
			break;
			}
		t += 3;
		}
	
	ins_pos = t+2;		/* hier einfÅgen! */
	s = cr_rscinfo( s, rscname, iconnr );
	if	((*path != '-') || (path[1]))
		{
		t = strchr(path, ' ');		/* Leerzeichen ? */
		if	(t)
			*s++ = '\'';			/* in Hochkomma einschlieûen */
		strcpy(s, path);
		if	(t)
			strcat(s, "'");		/* in Hochkomma einschlieûen */
		}
	strcat(s, "\r\n");
	s += strlen(s);
	itoa(code, s, 10);
	strcat(s, "\r\n");
	new_line = ins_data;
	return(E_OK);
}


/*******************************************************************
*
* Schalter 'id'
*
*******************************************************************/

long do_mode_id( char *pgmname, char *ftyp, char *rscname, int iconnr)
{
	static char section[] = "[12345678]";

	static char ins_data[] =
			"12345678901234567890123456789012 12345678.rsc 99999 \"-\"\r\n";
	char *s,*t,*u;
	int cmp_nam,cmp_typ;
	long namelen,typlen;


	if	(strlen(rscname) > 12)
		return(1);
	if	(strlen(ftyp) > 32)
		return(1);
	s = name_to_section(section, pgmname);
	*s = EOS;
	namelen = s - section;

	strcpy(ins_data, ftyp);
	strupr(ins_data);
	strcat(ins_data, " ");
	typlen = strlen(ins_data);
	s = ins_data + typlen;

	t = buf;
	while(1)
		{
		t = strstr(t, "\r\n[");	/* nÑchste Applikation suchen */
		if	(!t)
			return(2);		/* Formatfehler */
		t += 2;
		if	((t[1] == '<') && (strncmp(t, "[<frei>]", 8)))
			break;			/* <frei> ist letzte APP */

#if DEBUG
	Cconws("Bearbeite APP ");
	Fwrite(1, strchr(t, '\r')-t, t);
	Cconws("\r\n");
#endif
		cmp_nam = strncmp(t, section, namelen);
		u = strstr(t, "\r\n");
		if	((!u) || (u[2] == '['))
			return(2);		/* Formatfehler */
		u += 2;				/* u: Icondaten fÅr Programm */
		u = strstr(u, "\r\n");
		if	((!u) || (u[2] == '['))
			return(2);		/* Formatfehler */
		u += 2;				/* u: Pfad fÅr Programm */
		u = strstr(u, "\r\n");
		if	((!u) || (u[2] == '['))
			return(2);		/* Formatfehler */
		u += 2;				/* u: Code fÅr Programm */
		u = strstr(u, "\r\n");
		if	(!u)
			return(2);		/* Formatfehler */
		u += 2;				/* u: Zeile mit Datentypen */
		while(*u != '[')
			{
#if DEBUG
	Cconws(" Bearbeite Typ ");
	Fwrite(1, strchr(u, '\r')-u, u);
	Cconws("\r\n");
#endif
			cmp_typ = strncmp(u, ins_data, typlen);
			if	(!cmp_typ)
				return(3);	/* Kennung schon vergeben */
			if	(cmp_typ > 0)
				{
				if	(!cmp_nam)	/* unsere APP */
					ins_pos = u;	/* hier gehîren wir hin */
				break;		/* wir liegen hier nicht */
				}
			u = strstr(u, "\r\n");
			if	(!u)
				return(2);	/* Formatfehler */
			u += 2;
			}
		if	((!cmp_nam) && (!ins_pos))
			ins_pos = u;			/* anhÑngen! */
		t = u - 2;				/* nÑchste Section suchen */
	/*	Fwrite(1, 8L, t+2);	*/
		}

	if	(!ins_pos)
		return(4);			/* Applikation fehlt */
	s = cr_rscinfo( s, rscname, iconnr );
	new_line = ins_data;
	return(E_OK);
}


/*******************************************************************
*
* Hauptprogramm
*
*******************************************************************/

int main(int argc, char *argv[] )
{
	char *s;
	long ret;
	int mode;


	/* Modus ermitteln: mode */
	/* --------------------- */

	s = argv[1];
	if	(*s != '-')
		{
		global_syntax:
		Cconws("Syntax: mod_app -[Xis|Xia|Xid] ...\r\n");
		return(1);
		}
	s++;
	if	(!(*s))
		goto global_syntax;
	drv = toupper(*s++);		/* Laufwerk (A,B,C,...) */
	if	(!(*s))
		goto global_syntax;
	mode = *s << 8;
	s++;
	mode |= *s;
	s++;
	if	(*s)
		goto global_syntax;

	if	((mode != 'is') && (mode != 'ia') && (mode != 'id'))
		goto global_syntax;

	/* Pfade anpassen */
	/* -------------- */

	infname[0] = bakname[0] = datname[0] = drv;

	/* APPLICAT.INF îffnen und einlesen */
	/* -------------------------------- */

	ret = ainf_open();
	if	(ret)
		{
#if DEBUG
		printf("Fehler %ld beim ôffnen\n", ret);
#endif
		return((int) ret);
		}

	/* Aktionen je nach Modus */
	/* ---------------------- */

	switch(mode)
		{
		case 'is':
			if	(argc != 6)
				{
				Cconws("Syntax: mod_app -Xis key name rscname iconnr\r\n");
				return(1);
				}
			ret = do_mode_is(argv[2],argv[3],argv[4],atoi(argv[5]));
			break;

		case 'ia':
			if	(argc != 7)
				{
				Cconws("Syntax: mod_app -Xia pgmname rscname iconnr path|- code\r\n");
				return(1);
				}
			ret = do_mode_ia(argv[2],argv[3],atoi(argv[4]),
						argv[5],atoi(argv[6]));
			break;

		case 'id':
			if	(argc != 6)
				{
				Cconws("Syntax: mod_app -Xid pgmname dtype rscname iconnr\r\n");
				return(1);
				}
			ret = do_mode_id(argv[2],argv[3],
						argv[4],atoi(argv[5]));
			break;
		}

	/* Fehlerbehandlung */
	/* ---------------- */

#if DEBUG
	if	(ret)
		printf("Fehler %ld beim Bearbeiten\n", ret);
#endif
	if	(ret)
		return((int) ret);

	/* Datei rausschreiben */

	ret = ainf_save();

#if DEBUG
	if	(ret)
		printf("Fehler %ld beim Schreiben\n", ret);
#endif
	return((int) ret);
}
