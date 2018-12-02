#include <tos.h>
#include <stdlib.h>
#include <stdio.h>


int main(int argc, char *argv[])
{
	long ret;
	char fname[32];
	int n;
	int num;

	if	(argc != 2)
		{
		Cconws("Syntax: CRFILES n\r\n"
			  "        erzeugt n Dateien FILEnnnn.DAT\r\n");
		return(1);
		}
	n = atoi(argv[1]);
	for	(num = 0; num < n; num++)
		{
		sprintf(fname, "FILE%04d.DAT", num);
		ret = Fcreate(fname, 0);
		if	(ret < 0)
			break;
		Fclose((int) ret);
		ret = 0;
		}

	return((int) ret);
}