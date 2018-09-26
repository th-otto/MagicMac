#include <tos.h>
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	int dev;


	if	(argc != 2)
	{
		Cconws("Syntax: bconout dev\r\n");
		Cconws(" 0   PRT\r\n");
		Cconws(" 1   AUX\r\n");
		Cconws(" 2   CON\r\n");
		Cconws(" 3   MIDI\r\n");
		Cconws(" 4   IKBD\r\n");
		Cconws(" 5   RAWCON\r\n");
		return(1);
	}

	dev = atoi(argv[1]);

	Bconout(dev, (int) 'a');
	return(0);
}