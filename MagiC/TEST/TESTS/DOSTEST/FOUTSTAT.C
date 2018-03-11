#include <tos.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	int hdl;
	long i;

	if	(argc != 3)
		{
		printf("FOUTSTAT fname data");
		return(-1);
		}
	hdl = (int) Fopen(argv[1], 1);
	if	(strlen(argv[2]))
		Fwrite(hdl, strlen(argv[2]), argv[2]);
	i = gemdos(0x106,hdl);
	printf("Foutstat => %ld\n", i);
	return((int) i);
}