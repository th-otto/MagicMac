/*********************************************************************
*
*  FC                     1.4.88
*  ==
*
*  letzte énderung       28.10.89
*
*  Vergleichsprogramm fÅr Dateien
*
* Eingabe: FC [-[s]hex1[-hex2]] datei1 datei2
*
*  Endet <datei2> auf ':' oder '\', wird ein Pfad angenommen und
*  <datei1> im Pfad <datei2> gesucht.
*  Fehlt <datei2> ganz, wird <datei1> im aktuellen Laufwerk gesucht.
*
*********************************************************************/

#include <tos.h>
#include <string.h>
#include <stdio.h>
#include <tosdefs.h>
#include <limits.h>

#define TRUE   1
#define FALSE  0
#define EOS    '\0'
#define BUFLEN 10240L
#define CRLF   "\15\12"
#define toupper(c)	((c) & 0x5f)
#define tohex(c)    (((c) < '\12')  ? ((c) + '0') : ((c) + ('A'-'\12')))

unsigned char puffer1[BUFLEN], puffer2[BUFLEN];
long start = 0L;
long end   = LONG_MAX;
int	datasize = 1;		/* byteweise */
int intel = FALSE;

int  comp(int datei1, int datei2);
void write32x(unsigned long zahl);
void screen(char *string);


void main(argc,argv)
int  argc;
char *argv[];
{
		    char fname1[200],fname2[200];
     register int  file1,file2;
     register long retcode;
	void setstart(char *s);
	char *s;
	static char *syntax = "Syntax: FC [-[i][w|l][s]hex1[-hex2]] [datei1] [datei2|pfad2]\r\n"
					  "            -i Intel-WORDs\r\n"
					  "            -w WORD-weise\r\n"
					  "            -l LONG-weise\r\n";



	/* Auswertung der Kommandozeile. Dateinamen festlegen */
	/* -------------------------------------------------- */

	if	(argc > 4)
		{
		screen(syntax);
		Pterm(1);
		}
     if   (argc == 1)
     	{
		screen(syntax);
     	Cconws("Datei 1: ");
     	Fread(STDIN,200L,fname1);
     	Cconws("\r\nDatei 2: ");
     	Fread(STDIN,200L,fname2);
     	Cconws(CRLF);
          }
     else {
     	if	(argc > 1 && argv[1][0] == '-')
     		{
     		s = argv[1]+1;
     		if	(*s == 'i')
     			{
     			intel = TRUE;
     			s++;
     			}
     		if	(*s == 'w')
     			{
     			datasize = 2;		/* wortweise */
     			s++;
     			}
     		else
     		if	(*s == 'l')
     			{
     			datasize = 4;		/* langwortweise */
     			s++;
     			}
     		if	(*s)
	     		setstart(s);
     		argv++;
     		argc--;
     		}
     	strcpy(fname1,argv[1]);
     	if	(argc == 3)
     		strcpy(fname2,argv[2]);
     	else fname2[0] = EOS;
     	if	(fname2[0] == EOS ||
     		 fname2[strlen(fname2) - 1] == ':'  ||
			 fname2[strlen(fname2) - 1] == '\\'
			)
			{
			char *file;

			file = strrchr(fname1,'\\');
			if	(file == NULL)
				file = strrchr(fname1,':');
			if   (file == NULL)
				file = fname1;
			else file++;
			strcat(fname2,file);
			}
		}

     if   (0L > (retcode = Fopen(fname1,RMODE_RD)))
     	{
          screen("FC : Kann nicht îffnen : ");
          screen(fname1);
          newline: screen(CRLF);
          Pterm((int) retcode);
          }
     file1 = (int) retcode;

     if   (0L > (retcode = Fopen(fname2,RMODE_RD))) {
          Fclose(file1);
          screen("FC : Kann nicht îffnen : ");
          screen(fname2);
          goto newline;
          }

     file2 = (int) retcode;

     Cconws("Datei1:  ");Cconws(fname1);
     Cconws(CRLF);
     Cconws("                Datei2: ");Cconws(fname2);
	Cconws("\r\n");
     if	(intel)
     	Cconws(" Intel-Modus\r\n");
     Cconws("\r\n");
     retcode = comp(file1,file2);
     Fclose(file1);
     Fclose(file2);
     Pterm((int) retcode);
}


/**************************************************************
*
* Wertet einen String nach "-[s]hhhhhh[-hhhhhh]" aus.
* Setzt entsprechend die Start- und Endadresse.
* Wird letztere nicht angegeben, wird sie auf 0 gesetzt.
*
**************************************************************/

void setstart(char *s)
{
		    char *ends;
	register char *t;


	t = s;
	if	(toupper(*t) == 'S')
		t++;						/* 's' Åberspringen */
	start = strtoul(t, &ends, 16);
	if	(ends > t)
		{
		if	(*ends == EOS)
			{
			end = LONG_MAX;
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
	screen("FC: Fehler in Schalter ");
	screen(s);
	screen("\r\n");
	Pterm(-1);
}


/*************************************************************
*
*  Vergleicht die beiden Dateien.
*  RÅckgabe : Fehlercode oder 0
*
*************************************************************/

int comp(datei1,datei2)
int datei1,datei2;
{
              int  eof;
     register unsigned char *p1,*p2,c1,c2;
     unsigned int w1,w2;
     unsigned long l1,l2;
     register long amnt1,amnt2;
     unsigned long pos;


	if	(start)
		{
		pos = Fseek(start, datei1, 0);
		if	(pos < 0L)
			return((int) pos);
		pos = Fseek(start, datei2, 0);
		if	(pos < 0L)
			return((int) pos);
		}
	else	pos = 0L;
     do   {
          amnt1 = Fread(datei1, BUFLEN, puffer1);
          if   (amnt1 < 0L)
               return((int) amnt1);

          amnt2 = Fread(datei2, BUFLEN, puffer2);
          if   (amnt2 < 0L)
               return((int) amnt2);

          if   (amnt1 != amnt2) {
               Cconws("DateilÑnge unterschiedlich\15\12");
               return(0);
               }
          eof  = (amnt1 < BUFLEN);

          p1 = puffer1;
          p2 = puffer2;
          while(amnt1-- > 0L)
          	{
          	switch(datasize)
          		{
          		case 1:

          		byte:
		               if   ((c1 = *p1++) != (c2 = *p2++))
		               	{
		                    write32x(pos);
		                    Cconws(":  ");
		                    Cconout(tohex(c1 >> 4));
		                    Cconout(tohex(c1 & 0xf));
		                    Cconws(" (");
		                    Cconout( (c1 >= ' ') ? c1 : ' ');
		                    Cconout(')');
		                    Cconws("         ");
		                    Cconout(tohex(c2 >> 4));
		                    Cconout(tohex(c2 & 0xf));
		                    Cconws(" (");
		                    Cconout( (c2 >= ' ') ? c2 : ' ');
		                    Cconout(')');
		                    Cconws(CRLF);
		                    }
		               break;

				case 2:
					if	(amnt1 < 1)
						goto byte;
					if	(intel)
						{
						w1 = (*p1++) + (*p1++ << 8);
						w2 = (*p2++) + (*p2++ << 8);
						}
					else	{
						w1 = (*p1++ << 8) + (*p1++);
						w2 = (*p2++ << 8) + (*p2++);
						}
					if	(w1 != w2)
						{
						printf("%06lx:  %04x  %04x\n",
								pos, w1, w2);
						}
					amnt1--;
					pos++;
					break;

				case 4:
					if	(amnt1 < 3)
						goto byte;
					l1 = (*p1++ << 24L) + (*p1++ << 16L) +
							(*p1++ << 8L) + (*p1++);
					l2 = (*p2++ << 24L) + (*p2++ << 16L) +
							(*p2++ << 8L) + (*p2++);
					if	(l1 != l2)
						{
						printf("%06lx:  %08lx  %08lx\n",
								pos, l1, l2);
						}
					amnt1-=3;
					pos+=3;
					break;
				}

               pos++;
               if	(pos >= end)
               	return(0);
               }
          }
     while(!eof);
     return(0);
}


/*********************************************************************
*
*  Schreibt <zahl> als Hexzahl (6 Stellen) nach stdout
*
*********************************************************************/

void write32x(zahl)
unsigned long zahl;
{
     register int i;

     for  (i = 20; i >= 0; i-=4)
          Cconout((char) tohex((zahl >> i) & 0xf));
}


/*********************************************************************
*
*  Schreibt <string> auf den Bildschirm
*
*********************************************************************/

void screen(string)
char *string;
{
     Fwrite(HDL_CON,(long) strlen(string), string);
}

