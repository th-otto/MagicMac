#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include <tosdefs.h>

#define SERNO "188160918"
#define PERS_NAME "Test Name"
#define PERS_ADRESSE "Test Adresse, 00000 Test Stadt"

int create_ram(char *src, char *dst);
char buf[300000L];

void encode(char *z, char *q)
{
     register int i;

     for  (i = 0; i < 50; i++)
          {
          z[i] += q[i];
          z[i] += i*11;
          }
}


int create_ram(char *src, char *dst)
{
     register char *s;
     int file;
     long flen, doserr;
     long hlen;


     /* MAGIC.RAM modifizieren und erstellen */
     /* ------------------------------------ */

     file = (int) Fopen(src, RMODE_RD);
     if   (file < 0)
          return(-1);
     flen = Fread(file, 300000L, buf);
     Fclose(file);
     if   (flen <= 0L)
          return(-1);

	hlen = *((long *) (buf+0x20));	/* L„nge MAC-Header */
     s = (buf+0x1c) + *((long *) (buf+0x1c+hlen+0x14));
     doserr = atol(SERNO);
     memcpy(s - 0x8c, &doserr, 4L);
     memcpy(s - 0x88, PERS_NAME, 50L);
     encode(s - 0x88, "C:\\AUTO\\GEMSYS\\GEMDESK\\CLIPBRD\\BILDER\\MAGXDESK\\MAGXDESK.RSC");
     memcpy(s - 0x56, PERS_ADRESSE, 50L);
     encode(s - 0x56, "[1][Sie haben eine falsche Seriennummer|eingegeben][Abbruch]");
     file = (int) Fcreate(dst, 0);
     if   (file < 0)
          return(-1);
     doserr = Fwrite(file, flen, buf);
     Fclose(file);
     if   (doserr != flen)
          {
          return(-1);
          }
     return(0);
}


int main( int argc, char *argv[] )
{
	if	(argc != 3)
		{
		Cconws("rawinst macsrc macdst\r\n");
		return(1);
		}
	return(create_ram(argv[1], argv[2]));
}
