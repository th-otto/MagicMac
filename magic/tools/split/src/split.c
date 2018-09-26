/*******************************************************************
*
*                          SPLIT				21.11.89
*                          =====
*
*					  letzte énderung:		28.04.90
*
*
* Zweck:  (Text)dateien, die zu groû fÅr den Hauptspeicher sind,
*		aufspalten
*
* Syntax: SPLIT [-t] [-pos] von nach1 nach2
*
*******************************************************************/


#include <tos.h>
#include <stddef.h>
#include <string.h>
#include <tosdefs.h>
#include <structs.h>


#define FALSE             0
#define TRUE              1
#define EOS               '\0'
#define CRLF              "\r\n"
#define BUFLEN			 10240L
#define toupper(c)	((c) & 0x5f)

char buf[BUFLEN];
void setflags(char *s);
void split(char *quelle, char *ziel1, char *ziel2);
void cerrws(char *string);
int	istext = FALSE;
long splitpos = 0L;
long length;

int main (int argc, char *argv[])
{
	char *quelle,*ziel1,*ziel2;


	/* PrÅfen, ob genug Argumente Åbergeben wurden */
	/* ------------------------------------------- */

	if   (argc < 2)
		{
		syntax:
		cerrws("Syntax: SPLIT [-t] [-[s]hhhhhh] datei1 ...\r\n"
			  "     -hhhhhh  Aufspaltposition, hexadezimal\r\n"
			  "     -t       Textdatei, auf Zeilenende spalten\r\n");
	     Pterm(1);
	     }

	/* Schalter auswerten */
	/* ------------------ */

	for	(argv++; argc > 1; argc--,argv++)
		{
		if	(**argv == '-')
			setflags(*argv);
		else	{
			quelle = *argv;
			if	(argc > 2 && **(argv+1) != '-')
				{
				argv++;
				argc--;
				ziel1 = *argv;
				}
			else ziel1 = NULL;
			if	(argc > 2 && **(argv+1) != '-')
				{
				argv++;
				argc--;
				ziel2 = *argv;
				}
			else ziel2 = NULL;
			split(quelle, ziel1, ziel2);
			}
		}
	return(0);
}


/**************************************************************
*
* Splittet die Datei mit dem Namen <quelle> in Dateien mit den
* Namen <ziel1> und <ziel2> an Position <splitpos>.
*
**************************************************************/

void split(char *quelle, char *ziel1, char *ziel2)
{
	int  file, out;
	long err;
	char c;
	long i;


	if	(!ziel1)
		ziel1 = "__eins__";

	/* Datei îffnen          */
	/* --------------------- */

	if   (0L > (err = Fopen(quelle, O_RDONLY)))
		Pterm((int) err);
	file = (int) err;
	length = Fseek(0L, file, 2);
	if	(splitpos == 0L)
		splitpos = length/2;

	/* Splitting-  Position ermitteln */
	/* ------------------------------ */

	if	(0L > Fseek(splitpos, file, 0))
		Pterm((int) ERANGE);

	if	(istext)
		{
		do	{
			err = Fread(file, 1L, &c);
			if	(err != 1L)
				Pterm((int) err);
			}
		while(c != '\n');
		splitpos = Fseek(0L, file, 1);
		}

	/* erste Datei erzeugen */
	/* -------------------- */

	if	(0L > (err = Fcreate(ziel1, 0)))
		Pterm((int) err);
	out = (int) err;
	Fseek(0L, file, 0);
	for	(i = splitpos / BUFLEN; i > 0; i--)
		{
		err = Fread(file, BUFLEN, buf);
		if	(err != BUFLEN)
			Pterm(-1);
		err = Fwrite(out, BUFLEN, buf);
		if	(err != BUFLEN)
			Pterm(-1);
		}
	err = Fread(file, splitpos % BUFLEN, buf);
	if	(err < 0L)
		Pterm(-1);
	err = Fwrite(out, splitpos % BUFLEN, buf);
	if	(err < 0L)
		Pterm(-1);
	Fclose(out);


	/* zweite Datei erzeugen */
	/* --------------------- */

	if	(!ziel2)
		{
		Fclose(file);
		return;
		}

	if	(0L > (err = Fcreate(ziel2, 0)))
		Pterm((int) err);
	out = (int) err;
	for	(i = (length - splitpos) / BUFLEN; i > 0; i--)
		{
		err = Fread(file, BUFLEN, buf);
		if	(err != BUFLEN)
			Pterm(-1);
		err = Fwrite(out, BUFLEN, buf);
		if	(err != BUFLEN)
			Pterm(-1);
		}
	err = Fread(file, (length - splitpos) % BUFLEN, buf);
	if	(err < 0L)
		Pterm(-1);
	err = Fwrite(out, (length - splitpos) % BUFLEN, buf);
	if	(err < 0L)
		Pterm(-1);
	Fclose(file);
	Fclose(out);
}


/**************************************************************
*
* Wertet einen String nach "-[t][s]hhhhhh" aus.
* Setzt entsprechend die Splitadresse.
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
		if	(toupper(*t) == 'T')	/* Text- Modus		*/
			{
			istext = TRUE;
			t++;
			continue;
			}
		if	(toupper(*t) == 'S')	/* Bereich		*/
			t++;
		splitpos = strtoul(t, &ends, 16);
		if	(ends <= t || *ends != EOS)
			{
			cerrws("SPLIT: Fehler in Schalter ");
			cerrws(s);
			cerrws("\r\n");
			Pterm(-1);
			}
		t = ends;
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
