/*********************************************************************
*  Aufruf:
*  unique [-udatei] [-b] [-d] [-f] [-i] [-n] [-v] [-p<Pos1>[,<Pos2>]]
*       [Dateien ...]
*
*  Die Switches bedeuten:
*
*  u:     Gleiche Zeilen in der Ausgabedatei weglassen
*  b:     SPACE/TAB am Feldanfang Åberlesen
*  d:     Nur Buchstaben, Ziffern und Leerzeichen vergleichen
*  f:     Gross- fÅr Vergleich in Kleinbuchstaben wandeln
*  i:     Nur Zeichen 0x20-0x7f beruecksichtigen
*  n:     Numerische Werte am Feldanfang vergleichen
*  v:     WÑhrend des Programmlaufs Kommentare ausgeben.
*  Pos1:  Anfangsposition des Schluesselfeldes
*  Pos2:  Letzte Position des Schluesselfeldes
*/
/*
* ----------------------------------------------------------------------------
*
*              Includedateien, Konstanten und globale Variablen
*              ================================================
*
* ----------------------------------------------------------------------------
*/

#include <stdio.h>
#include <ctype.h>

#define FALSE            0
#define TRUE             1
#define MAXLEN           1000     /* Maximale Zeilenlaenge */
#define SWITCH           '-'      /* Command Line Switch Zeichen */
#define EOS              '\0'



static int skip_white_space = FALSE;    /* TRUE: white Space an Zeilenanfang ignorieren */
static int alphnum = FALSE;             /* TRUE: Nur alphanumerisch + whitespace */
static int cases = TRUE;                /* FALSE: GROSS = klein */
static int printable = FALSE;           /* TRUE: nur druckbare ASCII-Zeichen */
static int numerisch = FALSE;           /* TRUE: numerisch sortieren, falls moeglich */
static int verbose = FALSE;             /* TRUE: labern */
static int ab_pos = 0;                  /* Anfangsposition des Schluesselfelds */
static int len_pos = MAXLEN + 1;        /* Laenge desselbigen */
static FILE *uni_file = NULL;           /* Hier kommen gleiche Zeilen drauf */
static char puffer[2][MAXLEN+1];        /* Der I/O-Puffer */

int  (*vergl)();                 /* Zeiger auf benutzte Vergleichsfkt. */


/*
* ----------------------------------------------------------------------------
*
*                                 Hauptprogramm
*                                 =============
*
*  Rahmenprogramm. Interpretiert Command Line (Switches).
* ----------------------------------------------------------------------------
*/

main (argc,argv)
int   argc;
char *argv[];
{
              FILE *in_file;
     register int  n;
     extern   int  cmps(),strcmp(),stricmp(),ncmps(),nicmps();


    /* Interpretiere die Kommandozeile (Switches) */
    /* ------------------------------------------ */

    while (argc > 1 && argv [1][0] == SWITCH)     /* Switch vorhanden */
        {
        switch (argv [1][1])
            {
            case 'u':
            case 'U':
                if  (argv[1][2] != EOS) {
                    uni_file = fopen (argv[1]+2,"wa");
                    if   (uni_file == NULL)
                         fprintf(stderr,"Kann <unique>-Datei %s nicht îffnen\n",argv[1]+2);
                    }
                break;
            case 'b':
            case 'B':
                skip_white_space = TRUE;
                break;
            case 'd':
            case 'D':
                alphnum = TRUE;
                break;
            case 'f':
            case 'F':
                cases = FALSE;
                break;
            case 'i':
            case 'I':
                printable = TRUE;
                break;
            case 'n':
            case 'N':
                numerisch = TRUE;
                break;
            case 'v':
            case 'V':
                verbose = TRUE;
                break;
            case 'p':
            case 'P':
                ab_pos = atoi(argv[1]+2);
                while ((argv[1][2] != EOS) && (argv[1][2] != ','))
                      (argv[1])++;
                
                if  (argv[1][2] == ',')
                    len_pos = atoi (argv[1]+3);
                ab_pos--;
                len_pos -= ab_pos;
                if  (ab_pos < 0)
                    ab_pos = 0;
                if  (ab_pos >= MAXLEN)
                    ab_pos = MAXLEN - 1;
                if  (len_pos <= 0)
                    len_pos = MAXLEN + 1;
                break;

            default:
                fprintf(stderr, "Fehler: Unbekannte Option %c\n", argv[1][1]);
                fprintf(stderr, "Syntax: unique [-u[datei]] [-b][-d][-f][-i][-n][-v] [-p<Pos1>[,<Pos2>]] {Datei}\n");
                break;
            }
        ++argv;
        --argc;
        }

     /* Werden keine Switches benutzt, kann der normale Stringvergleich */
     /* verwendet werden, andernfalls die eigene Routine                */
     /* --------------------------------------------------------------- */

     vergl = cmps;
     if   (!skip_white_space && !alphnum && !printable &&
              !numerisch && (ab_pos == 0)) {
          if   (len_pos > MAXLEN)
               vergl = (cases) ? strcmp : stricmp;
          else vergl = (cases) ? ncmps : nicmps;
          }

     if   (argc == 1) {
          if   (unique(stdin))
               exit(1);
          }
     else {
          for  (n = 1; n < argc; n++) {
               if   (verbose)
                    fprintf(stderr,"Bearbeite: %s\n",argv[n]);

               if   (argv[n][0] == '-')
                    in_file = stdin;
               else in_file = fopen(argv[n],"ra");
               if   (in_file == NULL) {
                    fprintf(stderr, "Datei %s laesst sich nicht oeffnen\n", argv[n]);
                    fprintf(stderr, " Ich mache weiter auf IHRE Verantwortung\n");
                    continue;
                    }

               if   (unique(in_file))
                    exit(1);
     
               if   (in_file != stdin)
                    fclose(in_file);

               } /* END FOR */
          }

     exit(0);
}


/***********************************************************
*
* Strings vergleichen und ALLE Switches berÅcksichtigen.
* RÅckgabe > 0 : erster String grîsser.
*          = 0 : Strings gleich
*          < 0 : zweiter String grîsser.
*
***********************************************************/

int cmps(s1,s2)
unsigned char *s1,*s2;
{
     register unsigned char c1,c2;
                       long n1,n2;
     register          int  i;


     if   (ab_pos > 0) {                         /* SchlÅsselfeld */
          for  (i = 0; (i < ab_pos) && (*s1 != EOS); i++)
               s1++;
          for  (i = 0; (i < ab_pos) && (*s2 != EOS); i++)
               s2++;
          }

     if   (skip_white_space) {      /* SPACE und TAB am Anfang Åberlesen */
          while(isspace(*s1))
               s1++;
          while(isspace(*s2))
               s2++;
          }

     if   (numerisch) {             /* Numerische Werte am Feldanfang sort. */
          n1 = atol(s1);
          n2 = atol(s2);
          return ( (n1 < n2) ? -1 : (n1 > n2) );
          }

     i = 0;                         /* Positions- ZÑhler */
     while((*s1 != EOS) || (*s2 != EOS)) {
          c1 = *s1;
          c2 = *s2;

          if   (alphnum) {          /* nur Buchst., Ziffern und SPACE  */
               if   ( (c1 != EOS)    && (c1 != ' ') && !isalnum(c1) ) {
                    s1++;
                    continue;
                    }
               if   ( (c2 != EOS)    && (c2 != ' ') && !isalnum(c2) ) {
                    s2++;
                    continue;
                    }
               }

          if   (printable) {        /* nur ' ' <= Zeichen <= '\176' */
               if   (!isprint(c1)) {
                    s1++;
                    continue;
                    }
               if   (!isprint(c2)) {
                    s2++;
                    continue;
                    }
               }

          if   (!cases) {           /* Gross- in Kleinbuchstaben wandeln */
               c1 = tolower(c1);
               c2 = tolower(c2);
               }

          if   (c1 > c2)            /* String1 grîsser */
               return(1);
          if   (c1 < c2)            /* String2 grîsser */
               return(-1);
          s1++;                     /* bisher beide gleich => weitermachen */
          s2++;
          i++;
          if   (i > len_pos)
               break;
          }

     return(0);                     /* beide gleich */
}


/***********************************************************
*
* maximal <len_pos> Zeichen der Strings vergleichen.
* Sonst keine Switches berÅcksichtigen.
* RÅckgabe > 0 : erster String grîsser.
*          = 0 : Strings gleich
*          < 0 : zweiter String grîsser.
*
***********************************************************/

int ncmps(s1,s2)
unsigned char *s1,*s2;
{
     return(strncmp(s1,s2,len_pos));
}


/***********************************************************
*
* maximal <len_pos> Zeichen der Strings vergleichen.
* mit Gross- = Kleinbuchstaben vergleichen.
* RÅckgabe > 0 : erster String grîsser.
*          = 0 : Strings gleich
*          < 0 : zweiter String grîsser.
*
***********************************************************/

int nicmps(s1,s2)
unsigned char *s1,*s2;
{
     return(strnicmp(s1,s2,len_pos));
}


/***********************************************************
*
* Eigentliche Unique- Routine. Die <datei> wird nach 
* stdout geschrieben, identische Zeilen nach <uni_file>
* RÅckgabewert TRUE, wenn Fehler.
*
***********************************************************/

int unique(datei)
FILE *datei;
{
     register int puffernr1, puffernr2, status;

     puffernr1 = 1;
     if   (NULL == fgets(puffer[0], MAXLEN, datei))
          return(0);                   /* Datei war leer */
     if   (EOF == fputs(puffer[0], stdout)) {
          fprintf(stderr, "Schreibfehler auf STDOUT\n");
          return(1);
          }

     while(NULL != fgets(puffer[puffernr1], MAXLEN, datei)) {
          puffernr2 = (puffernr1 + 1) % 2;
          if   (0 == (*vergl)(puffer[puffernr1], puffer[puffernr2])) {
               if   (uni_file != NULL) {
                    if   (EOF == fputs(puffer[puffernr1], uni_file)) {
                         fprintf(stderr, "Schreibfehler\n");
                         return(1);
                         }
                    }
               }
          else {
               if   (EOF == fputs(puffer[puffernr1], stdout)) {
                    fprintf(stderr, "Schreibfehler auf STDOUT\n");
                    return(1);
                    }
               puffernr1 = puffernr2;
               }
          }

     return(0);
}

