#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	long ret;
	char tail[128];
	long len;


	if	((argc != 2) && (argc != 3))
		{
		Cconws("Syntax: PEXEC pfadname tail\r\n");
		return(1);
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

	tail[0] = (char) len;
	ret = Pexec(3, argv[1], tail, NULL);
	printf("pexec(3) => %ld\n", ret);
	if	(ret > 0L)
		{
		ret = Pexec(104, NULL, (char *) ret, NULL);
		printf("pexec(104) => %ld\n", ret);
		}
	for	(len = 0; len < 10000000L; len++)
		;

	return((int) ret);
}
