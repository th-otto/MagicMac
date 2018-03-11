#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>


int main(int argc, char *argv[])
{
	long ret;

	if	(argc != 2)
		{
		printf(	"\r\n"
				"Syntax: dopendir path\r\n");
		return(-1);
		}

	ret = Dopendir(argv[1], 1);
	printf("\r\nDopendir => %ld\n", ret);
	if	(ret > 0L)
		{
		Cconin();
		ret = Dclosedir(ret);
		printf("\r\nDclosedir => %ld\n", ret);
		}
	return((int) ret);
}

