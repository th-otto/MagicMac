#include <stdio.h>
#include <malloc.h>
#include "fsort.h"


static char     *buf[MAXSEG];     /* Mehrere Puffer jew. <= 64k */
static int      anzbuf;           /* Anzahl der Puffer */
static unsigned buflen[MAXSEG];   /* LÑnge des jew. Segments    */
static char     **zketten;        /* Zeiger auf Zeichenketten   */
static unsigned anzstr;           /* Anzahl der Strings */
static unsigned maxanzstr;        /* Maximale Anzahl    */

extern long     memavail;         /* VerfÅgbarer freier Speicher */
extern int      (*vergl)();       /* Zeiger auf benutzte Vergleichsfkt. */
extern int      (*gibaus)();      /* Zeiger auf benutzte Ausgabefkt. */
extern char     obuf[];           /* Ausgabepuffer */


/***********************************************************
*
* Initialisiert den grossen Puffer fÅr das interne Sortieren
* der zerhackten Teildatei sowie das Feld der Zeiger auf
* die Zeichenketten.
* Der Speicher wird in Blîcken <= 64k in den Feldern buf[]
* verwaltet, die LÑnge eines jeden Blocks in buflen[].
* FÅr die Zeiger werden 40kB fÅr 10.000 Zeilen benutzt.
*
***********************************************************/

int init_buf1()
{
     zketten = (char **) malloc((unsigned) ZEIGERMEM);
     if   (zketten == NULL)
          return(TRUE);                    /* zuwenig Speicher */
     memavail = (long) ZEIGERMEM;
     maxanzstr = ((unsigned) ZEIGERMEM) / sizeof(char *);

     for  (anzbuf = 0; anzbuf < MAXSEG; anzbuf++) {
          for  (buflen[anzbuf] =  (unsigned) SEGMENT;
                buflen[anzbuf] >  10000;
                buflen[anzbuf] -= 10000) {
                buf[anzbuf] = malloc(buflen[anzbuf]);
                if   (buf[anzbuf] != NULL)
                     goto ok;
                }
          return(anzbuf == 0);
          ok:   memavail += (long) buflen[anzbuf];
          buflen[anzbuf] -= MAXLEN + 1;    /* Sicherheitsbereich */
          }

     return(FALSE);
}


/***********************************************************
*
* Gibt den benutzten Speicher wieder an das OS zurÅck.
* Routine ist "void", da beim IBM kein Rueckgabewert von free()
* kommt.                          ====
*
***********************************************************/

free_buf1()
{
     register int i;

     free((char *) zketten);
     for  (i = 0; i < anzbuf; i++)
          free((char *) buf[i]);
}


/***********************************************************
*
* Strings von <datei> einlesen, bis alle Puffer voll sind.
* <anzstr>   = Anzahl gelesener Strings und
*  <zketten> = Anf.adressen der Strings werden initialisiert.
* RÅckgabe TRUE, wenn Eingabedatei zuende.
*
***********************************************************/

int  lies_teil(datei)
FILE *datei;
{
     register int i;
     int  dateiende;
     char *string;          /* gerade einzulesender String */
     unsigned totlen;       /* Gesamtlaenge aller bisher eingelesenen... */
                            /* ...Strings einschl. EOS */

     dateiende = FALSE;
     anzstr    = 0;

     for  (i = 0; i < anzbuf; i++) {
          totlen = 0;
          while(!dateiende && (anzstr < maxanzstr) && (totlen < buflen[i])) {
               string = buf[i] + totlen;
               if   (NULL == fgets(string, MAXLEN, datei))
                    dateiende = TRUE;
               else {
                    zketten[anzstr] = string;        /* Anfangsadresse */
                    totlen += strlen(string) + 1;    /* einschl. EOS  */
                    anzstr++;
                    }
               }
          }
     return(dateiende);
}


/***********************************************************
*
* Strings sortieren.
* Es wird indirekt sortiert, nÑmlich nur das Feld <zketten[]>,
* das die Anfangsadressen der Strings enthÑlt.
* hier: SHELLSORT
*
***********************************************************/

sortiere()
{
     register unsigned h,i,j;
     register char *v;

     h = 1;
     do
          h = 3*h + 1;
     while(h <= anzstr);

     do   {
          h /= 3;
          for  (i = h; i < anzstr; i++) {
               v = zketten[i];
               j = i;
               while((*vergl)(zketten[j-h],v) > 0) {
                    zketten[j] = zketten[j-h];
                    j -= h;
                    if   (j < h)
                         break;
                    }
               zketten[j] = v;
               }
          }
     while(h != 1);
}


/***********************************************************
*
* Alle Strings an Datei <outfile> ausgeben und diese
*  geschlossen.
* RÅckgabe TRUE, wenn Schreibfehler.
*
***********************************************************/

int  schreib(outfile)
FILE *outfile;
{
     register unsigned i;

     for  (i = 0; i < anzstr; i++) {
          if   (EOF == (*gibaus)(zketten[i], outfile)) {
               fclose(outfile);
               return(TRUE);
               }
          }
     fclose(outfile);
     return(FALSE);
}


/***********************************************************
*
* Phase 1 des Sortiervorgangs:
* Die Eingabedatei <datei> wird in mehrere Ausgabedateien
* zerlegt, die jeweils im Speicher sortiert
* worden sind.
* <fileanz>- viele Zwischendateien sind schon erzeugt worden.
* Wenn <no_of_infiles> = 1 und diese Datei ganz in den 
*  Speicher passt, wird direkt die Ausgabe erzeugt.
* RÅckgabewert TRUE, wenn Fehler.
*
***********************************************************/

int filesort(in_file, ausg_name, no_of_infiles)
FILE *in_file;
char *ausg_name;
int  no_of_infiles;
{
     int      eoinfile;                 /* Flag fÅr eof(Eingabedatei) */
     static   int  fileanz = 0;         /* Anzahl der erzeugten Ausg.dateien */
              char name[15];            /* Platz fÅr Name fÅr Zwischendateien */
     extern   char *tmpnam();
              FILE *ausgabe_datei;

 
     /* Speicher initialisieren */
     if   (init_buf1()) {
          fprintf(stderr,"Zuwenig Speicher\n");
          return(TRUE);
          }
     eoinfile = FALSE;                  /* Dateiende nicht erreicht */

     while(!eoinfile) {
          eoinfile = lies_teil(in_file);      /* Strings einlesen,... */
          sortiere();                         /* ...sortieren         */

          /* Falls genau eine Eingabedatei in genau eine sortierte */
          /* Ausgabedatei passt, wird diese sofort augegeben       */
          /* ----------------------------------------------------- */

          if   (eoinfile && (fileanz == 0) && (no_of_infiles == 1)) {
               ausgabe_datei = (ausg_name == NULL) ? stdout :
                                                     fopen(ausg_name,"wa");
               if   (ausgabe_datei == NULL) {
                    fprintf(stderr,"Ausgabedatei %s lÑsst sich nicht îffnen\n",ausg_name);
                    return(TRUE);
                    }

               /* ausgabe_datei soll einen grossen Puffer bekommen */
               /* ------------------------------------------------ */

               setvbuf (ausgabe_datei, obuf, _IOFBF, BUF_LEN);

               if   (schreib(ausgabe_datei)) {
                    fprintf(stderr,"Schreibfehler auf %s.\n",ausg_name);
                    free_buf1();
                    return(TRUE);
                    }
               free_buf1();
               return(FALSE);
               }

          if   (NULL == tmpnam(name)) {  /* Namen fÅr temporÑre Datei holen */
               fprintf(stderr, "Fehler bei 'tmpnam()'\n");
               return(1);
               }
          ausgabe_datei = fopen(name,"wa");

          if   (ausgabe_datei == NULL) {
               fprintf(stderr,"Kann Zwischendatei nicht îffnen\n");
               free_buf1();
               return(TRUE);
               }

     /* ausgabe_datei soll einen grossen Puffer bekommen */
     /* ------------------------------------------------ */

     setvbuf (ausgabe_datei, obuf, _IOFBF, BUF_LEN);

          if   (schreib(ausgabe_datei)) {          /* ...und ausgeben      */
               fprintf(stderr,"Schreibfehler\n");
               free_buf1();
               return(TRUE);
               }
          merke(name);                        /* Merken fÅr Merging   */
          fileanz++;
          }

     free_buf1();
     return(FALSE);
}


/***********************************************************
*
* Routine zum öberprÅfen, ob eine Eingabedatei <datei>
* sortiert ist.
* RÅckgabewert TRUE, wenn Fehler.
*
***********************************************************/

checke(datei, dateiname, unique)
FILE *datei;
char *dateiname;
int  unique;
{
     char puffer[2][MAXLEN+1];
     register int puffernr1, puffernr2, status;

     puffernr1 = 1;
     if   (NULL == fgets(puffer[0], MAXLEN, datei))
          return(0);                   /* Datei war leer */

     while(NULL != fgets(puffer[puffernr1], MAXLEN, datei)) {
          puffernr2 = (puffernr1 + 1) % 2;
          status = (*vergl)(puffer[puffernr1], puffer[puffernr2]);
          if   ((unique && (status == 0)) || (status < 0)) {
               fprintf(stderr, "Datei %s NICHT sortiert!\n", dateiname);
               return(0);
               }
          puffernr1 = puffernr2;
          }

     return(0);
}

