/* Umlenken der BIOS-Kan„le */

#include <mgx_dos.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int dev;


	if	(argc != 2)
	{
		Cconws("Syntax: fwrite_d stdhdl\r\n");
		Cconws(" 0   STDIN\r\n");
		Cconws(" 1   STDOUT\r\n");
		Cconws(" 2   STDAUX\r\n");
		Cconws(" 3   STDPRN\r\n");
		Cconws(" 4   STDERR\r\n");
		Cconws(" 5   STDXTRA\r\n");
		return(1);
	}

	dev = atoi(argv[1]);

	Fwrite(dev, 10L, "0123456789");
	return(0);
}