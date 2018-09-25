#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define KER_XFSNAME			0x0105	/* Kernel: XFS-Name (ab 15.6.96) */


int main(int argc, char *argv[])
{
	char nam[10] = "\0\0\0\0\0\0\0\0\0";
	long ret;

	if	(argc != 2)
		{
		Cconws("Syntax: XFS_NAME pfadname\r\n");
		return(1);
		}

	ret = Dcntl(KER_XFSNAME, argv[1], (long) nam);
	if	(ret <= 0)
		{
		printf("Dcntl => %ld\n", ret);
		}
	else	{
		Cconws(nam);
		ret = 0;
		}
	return((int) ret);
}
