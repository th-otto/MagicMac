/*********************************************************************
*  Aufruf:
*  sort [-u[datei]] [-m] [-odatei] [-b] [-c] [-d] [-f] [-i] [-n] [-r] [-v] [-p<Pos1>[,<Pos2>]]
*       [Dateien ...]
*
*  Die Switches bedeuten:
*
*  u:     Gleiche Zeilen in der Ausgabedatei weglassen
*  m:     Nur mischen, Dateien sind bereits sortiert
*  b:     SPACE/TAB am Feldanfang Åberlesen
*  d:     Nur Buchstaben, Ziffern und Leerzeichen vergleichen
*  f:     Gross- fÅr Vergleich in Kleinbuchstaben wandeln
*  i:     Nur Zeichen 0x20-0x7f berÅcksichtigen
*  n:     Nach numerischen Werten am Feldanfang sortieren
*  r:     Reihenfolge beim Sortieren umdrehen
*  v:     WÑhrend des Programmlaufs Kommentare ausgeben.
*  c:     Nur prÅfen, ob Dateien sortiert sind ("check")
*  o:     Output auf die angegebene Datei. Kann auch die Inputdatei sein.
*  Pos1:  Anfangsposition des SchlÅsselfeldes
*  Pos2:  Letzte Position des SchlÅsselfeldes
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
#include "fsort.h"


static int unique = FALSE;              /* TRUE: Verschlucke identische Zeilen */
static int merge_only = FALSE;          /* TRUE: Nur Mergen der Dateien */
static int skip_white_space = FALSE;    /* TRUE: white Space an Zeilenanfang ignorieren */
static int alphnum = FALSE;             /* TRUE: Nur alphanumerisch + whitespace */
static int cases = TRUE;                /* FALSE: GROSS = klein */
static int printable = FALSE;           /* TRUE: nur druckbare ASCII-Zeichen */
static int numerisch = FALSE;           /* TRUE: numerisch sortieren, falls moeglich */
static int reverse = FALSE;             /* TRUE: Ausgabe in reverser Reihenfolge */
static int verbose = FALSE;             /* TRUE: labern */
static int check_only = FALSE;          /* TRUE: Nur prÅfen, ob Eingabedatei bereits sortiert */
static int ab_pos = 0;                  /* Anfangsposition des SchlÅsselfelds */
static int len_pos = MAXLEN + 1;        /* LÑnge desselbigen */
static FILE *uni_file = NULL;           /* Hier kommen gleiche Zeilen drauf */

int  (*vergl)();                 /* Zeiger auf benutzte Vergleichsfkt. */
int  (*gibaus)();                /* Zeiger auf benutzte Ausgabefunktion */
long memavail;                   /* Groesse des freien Speichers */
char obuf[BUF_LEN];              /* Ausgabepuffer */


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
              int  stati_flag;           /* 0: aus, 1,2: Teil, 3: Alles */
              FILE *in_file;
     static   char *out_name = NULL;
     register int  n;
              int  no_of_infiles;
     extern   int  filesort(),cmps(),strcmp(),stricmp(),ncmps(),nicmps();
     extern   int  fputs1(),fputs();
              char hilfs_name[200];      /* Ausgabedatei bei <merge-only> */


    /* Interpretiere die Kommandozeile (Switches) */
    /* ------------------------------------------ */

    while (argc > 1 && argv [1][0] == SWITCH)     /* Switch vorhanden */
        {
        switch (argv [1][1])
            {
            case 'o':
            case 'O':
                out_name = argv[1]+2;
                break;
            case 'u':
            case 'U':
                unique = TRUE;
                if  (argv[1][2] != EOS) {
                    uni_file = fopen (argv[1]+2,"wa");
                    if   (uni_file == NULL)
                         fprintf(stderr,"Kann <unique>-Datei %s nicht îffnen\n",argv[1]+2);
                    }
                break;
            case 'm':
            case 'M':
                merge_only = TRUE;
                break;
            case 'c':
            case 'C':
                check_only = TRUE;
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
            case 'r':
            case 'R':
                reverse = TRUE;
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
                fprintf(stderr, "Syntax: fsort [-u[datei]] [-odatei] [-m][-c][-b][-d][-f][-i][-n][-r][-v] [-p<Pos1>[,<Pos2>]] {Datei}\n");
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
              !reverse && !numerisch && (ab_pos == 0)) {
          if   (len_pos > MAXLEN)
               vergl = (cases) ? strcmp : stricmp;
          else vergl = (cases) ? ncmps : nicmps;
          }


     /* Wird das <unique>- Flag nicht benutzt, kann die Standardprozedur */
     /* "fputs" verwendet werden, andernfalls die eigene Routine         */
     /* ---------------------------------------------------------------- */

     gibaus = (unique) ? fputs1 : fputs;

     if   (check_only && merge_only) {
          fprintf(stderr, "'merge'- und 'check'- Optionen unvereinbar => Checke nur.\n");
          merge_only = FALSE;
          }

     no_of_infiles = argc - 1;

     if   (merge_only && (no_of_infiles > MAXFILES)) {
          fprintf(stderr,"Ich kann leider nicht mehr als %d Dateien mist */
                    writestr("-(");
                    write_areg(reg);
                    writestr("),-(");
                    write_areg(reg1);
                    writechr(')');
                    } /* IF4 */
               else { /* ELSE4, Datenregister */
                    write_dreg(reg);
                    writechr(',');
                    write_dreg(reg1);
                    } /* ELSE4 */
               } /* IF3 */
          else { /* ELSE3, ADD,SUB */
               format = opmode & 3;
               if   (adfehler(opmode & 4))
                    return(TRUE);
               writestr(prefix_str);
               write_format();
               if   (opmode & 4) { /* IF6, Ziel: effektive Adresse */
                    write_dreg(reg1);
                    writechr(',');
                    adressierung();
                    } /* IF6 */
               else { /* ELSE6, Ziel: Datenregister */
                    adressierung();
                    writechr(',');
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                /*********************************************************************
*  Aufruf:
*  sort [-u[datei]] [-m] [-odatei] [-b] [-c] [-d] [-f] [-i] [-n] [-r] [-v] [-p<Pos1>[,<Pos2>]]
*       [Dateien ...]
*
*  Die Switches bedeuten:
*
*  u:     Gleiche Zeilen in der Ausgabedatei weglassen
*  m:     Nur mischen, Dateien sind bereits sortiert
*  b:     SPACE/TAB am Feldanfang Åberlesen
*  d:     Nur Buchstaben, Ziffern und Leerzeichen vergleichen
*  f:     Gross- fÅr Vergleich in Kleinbuchstaben wandeln
*  i:     Nur Zeichen 0x20-0x7f berÅcksichtigen
*  n:     Nach numerischen Werten am Feldanfang sortieren
*  r:     Reihenfolge beim Sortieren umdrehen
*  v:     WÑhrend des Programmlaufs Kommentare ausgeben.
*  c:     Nur prÅfen, ob Dateien sortiert sind ("check")
*  o:     Output auf die angegebene Datei. Kann auch die Inputdatei sein.
*  Pos1:  Anfangsposition des SchlÅsselfeldes
*  Pos2:  Letzte Position des SchlÅsselfeldes
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
#include "fsort.h"


static int unique = FALSE;              /* TRUE: Verschlucke identische Zeilen */
static int merge_only = FALSE;          /* TRUE: Nur Mergen der Dateien */
static int skip_white_space = FALSE;    /* TRUE: white Space an Zeilenanfang ignorieren */
static int alphnum = FALSE;             /* TRUE: Nur alphanumerisch + whitespace */
static int cases = TRUE;                /* FALSE: GROSS = klein */
static int printable = FALSE;           /* TRUE: nur druckbare ASCII-Zeichen */
static int numerisch = FALSE;           /* TRUE: numerisch sortieren, falls moeglich */
static int reverse = FALSE;             /* TRUE: Ausgabe in reverser Reihenfolge */
static int verbose = FALSE;             /* TRUE: labern */
static int check_only = FALSE;          /* TRUE: Nur prÅfen, ob Eingabedatei bereits sortiert */
static int ab_pos = 0;                  /* Anfangsposition des SchlÅsselfelds */
static int len_pos = MAXLEN + 1;        /* LÑnge desselbigen */
static FILE *uni_file = NULL;           /* Hier kommen gleiche Zeilen drauf */

int  (*vergl)();                 /* Zeiger auf benutzte Vergleichsfkt. */
int  (*gibaus)();                /* Zeiger auf benutzte Ausgabefunktion */
long memavail;                   /* Groesse des freien Speichers */
char obuf[BUF_LEN];              /* Ausgabepuffer */


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
              int  stati_flag;           /* 0: aus, 1,2: Teil, 3: Alles */
              FILE *in_file;
     static   char *out_name = NULL;
     register int  n;
              int  no_of_infiles;
     extern   int  filesort(),cmps(),strcmp(),stricmp(),ncmps(),nicmps();
     extern   int  fputs1(),fputs();
              char hilfs_name[200];      /* Ausgabedatei bei <merge-only> */


    /* Interpretiere die Kommandozeile (Switches) */
    /* ------------------------------------------ */

    while (argc > 1 && argv [1][0] == SWITCH)     /* Switch vorhanden */
        {
        switch (argv [1][1])
            {
            case 'o':
            case 'O':
                out_name = argv[1]+2;
                break;
            case 'u':
            case 'U':
                unique = TRUE;
                if  (argv[1][2] != EOS) {
                    uni_file = fopen (argv[1]+2,"wa");
                    if   (uni_file == NULL)
                         fprintf(stderr,"Kann <unique>-Datei %s nicht îffnen\n",argv[1]+2);
                    }
                break;
            case 'm':
            case 'M':
                merge_only = TRUE;
                break;
            case 'c':
            case 'C':
                check_only = TRUE;
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
            case 'r':
            case 'R':
                reverse = TRUE;
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
                fprintf(stderr, "Syntax: fsort [-u[datei]] [-odatei] [-m][-c][-b][-d][-f][-i][-n][-r][-v] [-p<Pos1>[,<Pos2>]] {Datei}\n");
                break;
            }
        ++argv;
        --argc;
        }

     /* Werden keine Switches benutzt, kann der normale Stringvergleich */
     /* verwendet werden, andernfalls die eigene Routine                */
     /* --------------------------------------------------------------- */

     vergl = cmps;
     if   (!skip_white_space &&