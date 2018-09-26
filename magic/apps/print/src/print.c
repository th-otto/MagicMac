/*********************************************************************
*
*                  PRINT.TTP                  27.12.87
*                  =========
*
*					letzte énderung:	 19.5.89
*
*  Druckprogramm fÅr den Ausdruck von TOS- Dateien auf
*  Epson- kompatiblen Druckern
*
*  Syntax: print [-p] [-s] [-i] datei1...    - Druckt Datei(en)
*		 -tn							- Tab- Grîûe
*          -s                                - schmaler Zeilenabstand
*          -p                                - Form Feed nach Ausdruck
*          -i                                - Init vor jeder Datei
*		 -c							- compressed
*		 -d							- double width
*
*********************************************************************/

#include <tos.h>
#include <tosdefs.h>
#include <string.h>


#define TRUE   1
#define FALSE  0
#define EOS    '\0'
#define ESC    '\33'
#define FF     '\14'
#define CTRL_C '\3'
#define toupper(c)  (c & '\137')

int	tabsize		= 8;
int  form_feed 	= FALSE;
int  small_spc 	= FALSE;
int  to_init   	= FALSE;
int	compressed 	= FALSE;
int  double_width 	= FALSE;


int	drucke(char *dateiname);
void screen(char *string);
void print(char *string);
void toterm(void);



void main(argc,argv)
int argc;
char *argv[];
{
	register int i;
	register char *schalter;


     /* PrÅfen, ob ohne Parameter gestartet */
	if   (argc < 2)
		{
		message:
		screen("\r\nUsage: PRINT [-psicd] datei1 datei2 ...\r\n\r\n");
		screen("          -tn   Tabgrîûe\r\n"
			  "          -s    Zeilenabstand 1/8\"\r\n"
			  "          -p    Seitenvorschub nach jeder Datei\r\n"
			  "          -i    Init vor jeder Datei\r\n"
			  "          -c    Schmale Zeichen\r\n"
			  "          -d    Breite Zeichen\r\n");
		Pterm(1);
		}

	/* Alle Switches auswerten */
	for  (i = 1; (i < argc) && (argv[i][0] == '-'); i++)
		for	(schalter = argv[i] + 1; *schalter != EOS; schalter++)
			{
			switch(toupper(*schalter))
				{
				case 'T' : {
						 char *endp;

						 tabsize = (int) strtoul(schalter+1, &endp, 10);
						 if	(endp == schalter+1 || tabsize == 0)
						 	{
						 	screen("PRINT: Formatfehler bei -Tn in: ");
						 	goto err;
						 	}
						 schalter = endp-1;
						 }
						 break;
				case 'P' : form_feed    = TRUE;
				           break;
				case 'I' : to_init      = TRUE;
				           break;
				case 'S' : small_spc    = TRUE;
				           break;
				case 'C' : compressed   = TRUE;
				           break;
				case 'D' : double_width = TRUE;
				           break;
				default  : screen("PRINT: Unbekannter Schalter in: ");
						 err:
						 screen(argv[i]);
						 screen("\r\n");
						 Pterm(2);
				}
			}

	/* Dateien drucken */

	if	(i >= argc)				/* keine Dateien */
		goto message;
	for  (; i < argc; i++) {
		if   (to_init)
			{
			toterm();
			print("@");
			}
		if   (small_spc)
			{
			toterm();
			Cprnout(ESC);
			toterm();
			Cprnout('0');
			}
		if   (compressed)
			{
			toterm();
			Cprnout('\x0f');
			}
		if   (double_width)
			{
			toterm();
			Cprnout(ESC);
			toterm();
			Cprnout('W');
			toterm();
			Cprnout('\x01');
			}
		/* Tabgrîûe einstellen */
		toterm();
		Cprnout(ESC);
		toterm();
		Cprnout('e');
		toterm();
		Cprnout(0);
		toterm();
		Cprnout(tabsize);
		if   (drucke(argv[i]))
			if   (form_feed) {
				toterm();
				Cprnout(FF);
				}
		}

	Pterm0();
}


/*********************************************************************
*
*  Druckt die Datei mit Namen <dateiname>
*  RÅckgabe FALSE, wenn Fehler
*
*********************************************************************/

int drucke(dateiname)
char dateiname[];
{
	         long retcode;
	         int  handle;
	         char puffer[2];
	register char *string;


	if   (0L > (retcode = Fopen(dateiname,O_RDONLY))) {
		screen("PRINT: ");
		screen(dateiname);
		screen(" nicht gefunden\r\n");
		return(FALSE);
		}
	handle = (int) retcode;

	screen("Drucke ");
	screen(dateiname);
	screen("\r\n");

     while(1L == Fread(handle,1L,puffer)) {
          puffer[1] = EOS;
          string = puffer;
          switch(puffer[0]) {
               case '#':
               case '$':
               case '@':
               case '[':
               case '\\':
               case ']':
               case '^':
               case '\'':
               case '{':
               case '|':
               case '}':
               case '~': print("R");
                         Cprnout('\0');      break;
               case 'Ä': string = "C\b,";    break;
               case 'Å': string = "R\2}";   break;
               case 'Ç': string = "R\1{";   break;
               case 'É': puffer[0] = 'a';    goto circ;
               case 'à': puffer[0] = 'e';    goto circ;
               case 'å': puffer[0] = 'i';    goto circ;
               case 'ì': puffer[0] = 'o';    goto circ;
               case 'ñ': puffer[0] = 'u';
                         circ:
                         Cprnout(puffer[0]);
                         print("\bR");
                         Cprnout('\0');
                         puffer[0] = '^';    break;
               case 'Ñ': string = "R\2{";   break;
               case 'Ö': string = "R\1@";   break;
               case 'Ü': string = "R\4}";   break;
               case 'á': string = "R\1\\";  break;
               case 'â': string = "e\bR\1~";break;
               case 'ä': string = "R\1}";   break;
               case 'ã': string = "i\bR\1~";break;
               case 'ç': string = "R\6~";   break;
               case 'é': string = "R\2[";   break;
               case 'è': string = "R\4]";   break;
               case 'ê': string = "R\9@";   break;
               case 'ë': string = "R\4{";   break;
               case 'í': string = "R\4[";   break;
               case 'î': string = "R\2|";   break;
               case 'ï': string = "R\6|";   break;
               case 'ó': string = "R\1|";   break;
               case '¿':
               case 'ò': string = "y\bR\1~";break;
               case 'ô': string = "R\2\\";  break;
               case 'ö': string = "R\2]";   break;
               case 'õ': print("c\bR");
                         Cprnout('\0');
                         string[0] = '|';    break;
               case 'ú': string = "R\3#";   break;
               case 'ù': string = "R\8\\";  break;
               case 'û': string = "R\2~";   break;
               case 'ü': string[0] = 'f';    break;
               case '†': string = "a\b'";    break;
               case '°': string = "i\b'";    break;
               case '¢': string = "o\b'";    break;
               case '£': string = "u\b'";    break;
               case '§': string = "R\7|";   break;
               case '•': string = "R\7\\";  break;
               case '¶': string = "a\b_";    break;
               case 'ß': string = "o\b_";    break;
               case '®': string = "R\7]";   break;
               case '≠': string = "R\7[";   break;
               case '∞': Cprnout('a');       goto tilde;
               case '±': Cprnout('o');
                         tilde:
                         print("\bR");
                         Cprnout('\0');
                         string[0] = '~';    break;
               case '≤': string = "R\4\\";  break;
               case '≥': string = "R\4|";   break;
               case '∂':
               case '∑': string[0] = 'A';    break;
               case '∏': string[0] = 'O';    break;
               case 'π': string = "R\1~";   break;
               case '∫': string[0] = '\'';   break;
               case 'ª': string = "\0\0\24\147\24\0\0\0\0";
                         goto graph;
               case '': string = "\0\x18\x38\x6f\xc1\xc1\x6f\x38\x18";
                         goto graph;
               case '': string = "\0\x18\x1c\xf6\x83\x83\xf6\x1c\x18";
                         goto graph;
               case '': string = "\0\x3c\x24\x24\xe7\xc3\x66\x3c\x18";
                         goto graph;
               case '': string = "\0\x18\x3c\x66\xc3\xe7\x24\x24\x3c";
                         goto graph;
               case 'º': string = "\140\220\220\224\224\377\4\0\0";
                         goto graph;
               case 'Ω': string = "\176\303\275\245\245\245\303\176\0";
                         goto graph;
               case 'æ': string = "\176\303\275\251\255\265\303\176\0";
                         goto graph;
               case 'ø': string = "\200\360\200\360\200\100\200\360\0";
					graph:
					{
					register int i;


					/* ungerade Spalten drucken */
					/* ------------------------ */
					print("y\376");
					for (i = 0; i < 9; i++)
					     Cprnout((i & 1) ? string[i] : '\0');
					Cprnout('\376');

					/* ein Schritt zurÅck */
					/* ------------------ */
					Cprnout('\b');

					/* gerade Spalten drucken */
					/* ---------------------- */
					print("y\376");
					for (i = 0; i < 9; i++)
					     Cprnout((i & 1) ? '\0' : string[i]);
					Cprnout('\376');
					}
					string[0] = EOS;    break;
               case '¡': string[0] = 'Y';    break;
               case '›': string = "R\2@";   break;
               case 'ﬁ': print("R");
                         Cprnout('\0');
                         puffer[0] = '^';    break;
               case '·': string = "R\2~";   break;
               case '': string = "=\b_";    break;
               case 'Ò': string = "+\b_";    break;
               case 'Ú': string = ">\b_";    break;
               case 'Û': string = "<\b_";    break;
               case 'ˆ': string = ":\b-";    break;
               case '¯': string = "R\1[";   break;

               default:  if   ((string[0] < 0) || (string[0] == '\177'))
                              string[0] = ' ';
               }
          toterm();
          print(string);

          } /* END WHILE */

     Fclose(handle);
     return(TRUE);
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


/*********************************************************************
*
*  Schreibt <string> auf den Drucker
*
*********************************************************************/

void print(string)
char *string;
{
     while(*string)
          Cprnout(*string++);
}


/*********************************************************************
*
*  Liest Tastaturpuffer und fragt, ob Programm abgebrochen werden soll
*
*********************************************************************/

void toterm()
{
     char c;

     do   {
          if   (Bconstat(CON)) { /* Wenn Taste gedrÅckt */
               while(Bconstat(CON))
                    if   (CTRL_C == (0xff & Bconin(CON)))
                         Pterm0();
               screen("Abbruch (j/n) ? ");
               Bconout(5, c = Bconin(CON));
               if   (toupper(c) == 'J')
                    Pterm0();
               screen("\r\n");
               }
          }
     while(!Cprnos());            /* solange Drucker nicht verfÅgbar */
}
