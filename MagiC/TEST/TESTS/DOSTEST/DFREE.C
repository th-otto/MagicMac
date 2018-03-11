#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
     DISKINFO buf;
     int drv;
     long ret;


	if	(argc < 2)
		drv = 0;
	else	{
		if   (argc != 2)
			{
			err:
			Cconws("Syntax: DFREE X:\r\n");
			return(1);
			}
		argv[1][0] &= 0x5f;		/* toupper */
		if	((argv[1][1] != '\0') && (argv[1][1] != ':'))
			goto err;
		drv = argv[1][0] - 'A' + 1;
		}

     ret = Dfree(&buf, drv);
     if	(ret != E_OK)
	     printf("=> Fehler %ld\n", ret);
	else	{
		if	(drv)
			printf("Informationen fÅr Laufwerk %c:\n"
				  "------------------------------\n", drv + 'A' - 1);
		printf("%ld Cluster frei\n", buf.b_free);
		printf("%ld Cluster auf Laufwerk\n", buf.b_total);
		printf("%ld Bytes pro Sektor\n", buf.b_secsiz);
		printf("%ld Sektoren pro Cluster\n", buf.b_clsiz);
		}
     return((int) ret);
}
