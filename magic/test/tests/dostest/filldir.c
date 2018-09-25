#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	char fname[32];
	register int i,l;
	long retcode;


	if	(argc > 1)
		l = atoi(argv[1]);
	else l = 1000;
	for	(i = 0; i < l; i++)
		{
		sprintf(fname, "$$$.%03d", i);
		retcode = Fcreate(fname, 0);
		if	(retcode < 0L)
			break;
		Fclose((int) retcode);
		}
	return((int) retcode);
}