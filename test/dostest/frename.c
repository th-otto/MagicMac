#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	long ret;


	if	(argc != 3)
		{
		Cconws("Syntax: FRENAME alt neu\r\n");
		return(1);
		}
	ret = Frename(0,argv[1], argv[2]);
	return((int) ret);
}
