#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void swrite( char *s );

int main(int argc, char *argv[])
{
	long i;
	long infiles;
	long outfiles;
	int	timeout;
	char	s[500];


	if	(argc != 4)
		{
		swrite("FSELECT infiles outfiles timeout\r\n");
		return(-1);
		}

	swrite("infiles:  "); swrite(argv[1]); swrite("\r\n");
	swrite("outfiles: "); swrite(argv[2]); swrite("\r\n");
	swrite("timeout : "); swrite(argv[3]); swrite("\r\n");

	infiles  = atol(argv[1]);
	outfiles = atol(argv[2]);
	timeout  = atoi(argv[3]);
	i = Fselect(timeout, &infiles, &outfiles, 0L);
	sprintf(s, "ret=%ld infiles=%ld outfiles=%ld\r\n", i, infiles, outfiles);
	swrite(s);
	return((int) i);
}


void swrite( char *s )
{
	Fwrite(-1, strlen(s), s);
}