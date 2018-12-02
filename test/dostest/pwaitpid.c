#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	long ret;
	char tail[128];
	long len;
	int pid;
	long rusage[2];


	if	(argc != 3)
		{
		Cconws("Syntax: PWAITPID pfadname tail\r\n");
		return(1);
		}

	len = strlen(argv[2]);
	if	(len > 127)
		{
		printf("Kommandozeile zu lang.\n");
		ret = 1;
		}
	else	{
		strcpy(tail+1, argv[2]);
		tail[0] = (char) len;
		ret = Pexec(100, argv[1], tail, NULL);
		printf("pexec => %ld\n", ret);
		if	(ret > 0)
			{
			pid = (int) ret;
			ret = Pwaitpid(pid, 0, rusage);
			printf("Pwaitpid => %08lx\n", ret);
			}
		}
	return((int) ret);
}
