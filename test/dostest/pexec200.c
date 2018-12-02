#include <portab.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	long ret;
	char tail[128];
	long len;
	WORD fh;


	if	((argc != 2) && (argc != 3) && (argc != 4))
		{
		Cconws("Syntax: PEXEC pfadname tail [stdout]\r\n");
		return(1);
		}

	if	(argc == 4)
		{
		ret = Fcreate(argv[3], 0);
		if	(ret < 0)
			return((int) ret);
		fh = (WORD) ret;
		Fforce(1, fh);
		Fclose(fh);
		argc--;
		}

	if	(argc == 2)
		{
		len = 0;
		}
	else	{
		len = strlen(argv[2]);
		if	(len > 127)
			{
			printf("Kommandozeile zu lang.\n");
			return(1);
			}
		strcpy(tail+1, argv[2]);
		}

	Malloc(128000L);		/* test! */
	tail[0] = (char) len;
	ret = Pexec(200, argv[1], tail, NULL);
	printf("pexec(200) => %ld\n", ret);

	return((int) ret);
}
