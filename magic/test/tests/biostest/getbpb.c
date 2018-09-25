#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
     BPB *bpb;
     int drv;


	if	(argc < 2)
		drv = 0;
	else	{
		if   (argc != 2)
			{
			err:
			Cconws("Syntax: GETBPB X:\r\n");
			return(1);
			}
		argv[1][0] &= 0x5f;		/* toupper */
		if	((argv[1][1] != '\0') && (argv[1][1] != ':'))
			goto err;
		drv = argv[1][0] - 'A';
		}

     bpb = Getbpb(drv);
     if	(!bpb)
	     printf("=> Fehler\n");
	else	{
		printf("BPB fr Laufwerk %c:\n"
			  "-------------------\n", drv + 'A');
		printf("%6u Bytes pro Sektor\n", bpb->recsiz);
		printf("%6u Sektoren pro Cluster\n", bpb->clsiz);
		printf("%6u Bytes pro Cluster\n", bpb->clsizb);
		printf("%6u Sektoren im Wurzelverzeichnis\n", bpb->rdlen);
		printf("%6u Sektoren pro FAT\n", bpb->fsiz);
		printf("%6u Startsektor der 2. FAT\n", bpb->fatrec);
		printf("%6u Startsektor fr Daten\n", bpb->datrec);
		printf("%6u Cluster insgesamt\n", bpb->numcl);
		printf("%6u = Flags\n", bpb->bflags);
		}
     return(0);
}
