#include <tos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( int argc, char *argv[] )
{
	if	(argc != 2)
		{
		Cconws("Syntax: FLPTIOUT ticks\r\n");
		Cconws("Setzt Floppy-Timeout in 5ms-Einheiten\r\n");
		return(1);
		}


	Floprate(-1, atoi(argv[1]));
	return(0);
}
