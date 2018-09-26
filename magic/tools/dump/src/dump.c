/*******************************************************************
*
*		    DUMP.TTP							4.1.89
*		    ========
*						    letzte énderung:	28.4.90
*
* Allgemeine Dateien in HEX/ASCII ausgeben
* (geht auch mit CON)
*
* Syntax: DUMP [-[s]hex1[-hex2]] datei ...
*
* geschrieben mit TUBO C V1.0
*
*******************************************************************/

#include <tos.h>
#include <tosdefs.h>
#include <stddef.h>
#include <string.h>
#include <limits.h>


#define EOS '\0'
#define TRUE  1
#define FALSE 0
#define toupper(c)	((c) & 0x5f)
#define tolower(c)	((c) | 0x20)
#define tohex(c)	(((c) < '\12')  ? ((c) + '0') : ((c) + ('a'-'\12')))
#define write16x(i)	Cconout(tohex((i) >> 4)),Cconout(tohex((i) & 0xf))

unsigned char inbuf[100*16];
int	line;					/* Bytes pro Zeile */
long buffersize;				/* 100 Zeilen puffern */
long start = 0L;
long end   = (LONG_MAX & ~1);
char	isc   = FALSE;
char isinf = FALSE;
char isbyt = FALSE;

void cerrws	(char *string);
void setflags	(char *s);
void dump		(char *s);
void write32x	(unsigned long zahl);
int	lies		(int handle, unsigned char s[16]);
int	isprint	(unsigned char c);


void main(int argc, char *argv[])
{
	if	(argc < 2)		  /* nicht genÅgend Argumente */
		{
		cerrws("Syntax: DUMP [-ci] [[-[s]hhhhhh[-hhhhhh]] datei] ...\r\n"
		       " -s    Start- und Endadresse hexadezimal\r\n"
		       " -c    Ausgabe als C- Quelltext\r\n"
		       " -b     byteweise\r\n"
		       " -i     mit Kommentaren\r\n");
		Pterm(1);
		}

	for	(argv++; argc > 1; argc--,argv++)
		{
		if	(**argv == '-')
			setflags(*argv);
		else	dump(*argv);
		}
	Pterm0();
}


/**************************************************************
*
* Wertet einen String nach "-[c][i][s]hhhhhh[-hhhhhh]" aus.
* Setzt entsprechend die Start- und Endadresse.
* Wird letztere nicht angegeben, wird sie auf 0 gesetzt.
*
**************************************************************/

void setflags(char *s)
{
		    char *ends;
	register char *t;


	t = s + 1;					/* '-' Åberspringen */
	while(*t)
		{
		if	(toupper(*t) == 'C')	/* 'C'- Modus		*/
			{
			isc = TRUE;
			t++;
			continue;
			}
		if	(toupper(*t) == 'I')	/* kommentiert		*/
			{
			isinf = TRUE;
			t++;
			continue;
			}
		if	(toupper(*t) == 'B')	/* byteweise		*/
			{
			isbyt = TRUE;
			t++;
			continue;
			}
		if	(toupper(*t) == 'S')	/* Bereich		*/
			t++;
		start = strtoul(t, &ends, 16);
		if	(ends > t)
			{
			if	(*ends == EOS)
				{
				end = (LONG_MAX & ~1);
				return;
				}
			if	(*ends == '-')
				{
				t = ends + 1;
				end = strtoul(t, &ends, 16);
				if	(ends > t && *ends == EOS)
					return;
				}
			}
		cerrws("DUMP: Fehler in Schalter ");
		cerrws(s);
		cerrws("\r\n");
		Pterm(-1);
		}
}


/**************************************************************
*
* Gibt eine Datei aus.
*
**************************************************************/

void dump(char *s)
{
	DTA	dta;
	int  handle;
	long retcode;
	unsigned char buf[16];
	register int  amnt,i;
	unsigned long pos;



	if	(!isc)
		{
		isinf = TRUE;
		isbyt = FALSE;
		line  = 16;
		}
	else {
		if	(isbyt && isinf)
			line = 8;
		else if	(!isbyt && !isinf)
			line = 16;
		else line = 12;
		}
	buffersize = 100*line;

	if	(isc && !isbyt && ((start & 1) || (end & 1)))
		{
		cerrws("DUMP: Ungerade Start- oder Endadresse bei ");
		cerrws(s);
		cerrws("\r\n");
		Pterm((int) ERROR);
		}

	/* Datei îffnen, Startadresse angehen und Titel drucken */
	/* ---------------------------------------------------- */

	Fsetdta(&dta);
	if	((strlen(s) == 4) && (s[3] == ':'))		/* GerÑt ! */
		{
		strupr(s);
		strcpy(dta.d_fname, s);
		dta.d_length = 0x7fffffffL;
		if	(!stricmp(s, "MEM:"))
			{
			retcode = -10;
			buffersize = 16;
			}
		else {
			retcode = Fopen(s, O_RDONLY);
			if	(retcode < 0)
				goto erro;
			}
		}
	else
	if	((retcode = Fsfirst(s, 0)) < 0 ||
		 (retcode = Fopen(s, O_RDONLY)) < 0)
		{
		erro:
		cerrws("DUMP: Kann nicht îffnen: ");
		cerrws(s);
		cerrws("\r\n");
		Pterm((int) retcode);
		}
	handle = (int) retcode;
	if	(handle >= 0)
		{
		if	(start != (pos = Fseek(start, handle, 0)))
			{
			cerrws("DUMP: Falsche Startadresse bei ");
			cerrws(s);
			cerrws("\r\n");
			if	(pos >= 0)
				pos = -1L;
			Pterm((int) pos);
			}
		}
	else pos = start;
	if	(isc)
		{
		Cconws((isbyt) ? "char " : "int  ");
		i = 0;
		while(dta.d_fname[i] && dta.d_fname[i] != '.')
			Cconout(tolower(dta.d_fname[i++]));
		Cconws("[] = {\r\n");
		}
	else	{
		Cconws(" Datei: ");
		Cconws(s);
		Cconws("\r\n\r\n");
		}

	/* Datei ausgeben								 */
	/* ---------------------------------------------------- */

	lies(0,NULL);			/* Initialisierung der Puffer*/
	while(pos < end)
		{
		amnt = lies(handle, buf);
		if	(amnt == 0)
			break;
		if	(amnt > end - pos)
			amnt = (int) (end - pos);

		if	(isinf)
			{
			if	(isc)
				Cconws("/* ");
			write32x(pos);
			Cconws((isc) ? " */  " : "  ");
			}

		for	(i = 0; i < line; )
			{

			/* High- Byte	*/
			/* =========== */

			if	(i < amnt)
				{
				pos++;
				if	(isc)
					Cconws("0x");
				write16x(buf[i]);
				if	(isc && isbyt)
					{
					if	(pos < dta.d_length && pos < end)
						Cconout(',');
					else if	(isinf)
							Cconout(' ');
					}
				}
			else {
				if	(isinf)
					{
					if	(!isc)
						Cconws("  ");
					else Cconws((isbyt) ? "     " : "    ");
					}
				}
			i++;

			/* Low- Byte	*/
			/* =========== */

			if	(i < amnt)
				{
				pos++;
				if	(isc && isbyt)
					Cconws("0x");
				write16x(buf[i]);
				if	(isc && pos < dta.d_length && pos < end)
					Cconout(',');
				else if	(isinf)
						Cconout(' ');
				}
			else {
				if	(isinf)
					{
					if	(!isc)
						Cconws("   ");
					else Cconws((isbyt) ? "     " : "   ");
					}
				}
			i++;
			}


		if	(!isc || isinf)
			{
			Cconws(" ");
			if	(isc)
				Cconws("/* ");
			for	(i = 0; i < amnt; i++)
				Cconout((isprint(buf[i])) ? buf[i] : '.');
			if	(isc)
				Cconws(" */");
			}
		Cconws("\r\n");
		}
	if	(isc)
		Cconws("};\r\n");
	if	(handle != -10)
		Fclose(handle);
}


/**************************************************************
*
* Liest maximal 16 Zeichen aus der Datei <handle> und gibt
* die tatsÑchliche Anzahl zurÅck.
* Wird NULL als RÅckgabepuffer Åbergeben, werden die statischen
* Variablen neu initialisiert.
*
**************************************************************/

int lies(int handle, unsigned char s[16])
{
	static long count;
	static unsigned char *p;
	static int  eof;
	register int i;
	static char *memp;
	long oldssp;


	if	(s == NULL)				/* Neue Datei */
		{
		eof = FALSE;
		count = 0L;
		memp = (char *) start;
		return(0);
		}
	while(TRUE)
		{
		if	(eof)				/* Dateiende */
			return(0);
		if	(count)				/* noch Zeichen im Puffer */
			{
			for	(i = 0; i < line && i < count; i++)
				*s++ = *p++;			/* Zeichen kopieren */
			count -= i;
			if	(isc && isbyt)
				return(i & ~1);
			else	return(i);
			}
		if	(handle != -10)
			count = Fread(handle, buffersize, inbuf);
		else	{
			oldssp = Super(0L);
			memcpy(inbuf, memp, buffersize);
			count = buffersize;
			memp += buffersize;
			Super((char *) oldssp);
			}
		p = inbuf;					/* Puffer neu gefÅllt */
		if	 (count < 0L)
			 Pterm((int) count);
		if	(count == 0L || ((handle < 0 && handle != -10) && *p == 0x1a))
			eof = TRUE;
	}
}


/**************************************************************
*
* Gibt einen <string> nach stderr aus, d.h. nach Handle 4,
* falls vorhanden. Sonst nach Handle -1.
*
**************************************************************/

void cerrws(char *string)
{
	extern BASPAG *_BasPag;


	Fwrite( (_BasPag->p_stdfh[STDERR]) ? STDERR : HDL_CON,
		  strlen(string), string);
}


/*********************************************************************
*
*  Schreibt <zahl> als Hexzahl (6 Stellen) nach stdout
*
*********************************************************************/

void write32x(unsigned long zahl)
{
	register int i;

	for	(i = 20; i >= 0; i-=4)
		Cconout((char) tohex((zahl >> i) & 0xf));
}


/*********************************************************************
*
*  Gibt an, ob ein Zeichen ausgegeben wird
*
*********************************************************************/

int isprint(unsigned char c)
{
	if	(c  < 0x20 ||				/* Steuerzeichen  */
		 c == 0x7f ||				/* DELete		   */
		 c  > 0xc1 ||				/* hebr.+griech.  */
		 (c  > 0xa5 && c < 0xb0) ||	/* versch. */
		 (c  > 0xb8 && c < 0xc0)		/* versch. */
		)
		return(FALSE);
	else return(TRUE);
}
