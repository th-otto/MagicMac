#include <ctype.h>

/***********************************************************
*
* Strings vergleichen ohne Bercksichtigung von
* Gross-/Kleinschrift.
* Rckgabe > 0 : erster String gr”sser.
*          = 0 : Strings gleich
*          < 0 : zweiter String gr”sser.
*
***********************************************************/

int stricmp(s1,s2)
register unsigned char *s1,*s2;
{
     for  (; toupper(*s1) == toupper(*s2); s1++,s2++)
          if   (*s1 == '\0')
               return(0);
     return(toupper(*s1) - toupper(*s2));
}


/***********************************************************
*
* Strings vergleichen mit n Zeichen ohne Bercksichtigung von
* Gross-/Kleinschrift.
* Rckgabe > 0 : erster String gr”sser.
*          = 0 : Strings gleich
*          < 0 : zweiter String gr”sser.
*
***********************************************************/

int strnicmp(s1,s2,n)
register unsigned char *s1,*s2;
register int n;
{
     register int i;

     for  (i = 0; (i < n) && (toupper(*s1) == toupper(*s2)); s1++,s2++,i++)
          if   (*s1 == '\0')
               return(0);
     return( (i < n) ? (toupper(*s1) - toupper(*s2)) : 0 );
}


/* Verschiedene Prozeduren, die beim IBM was bringen */

setvbuf()
{
}

t_reset()
{
}

t_display()
{
}

char *tmpnam(string)
char string[];
{
     static int zaehler = 0;

     if   (zaehler > 999)
          return((char *) 0L);
     sprintf(string,"tmpdat.%3d",zaehler++);
     return(string);
}

