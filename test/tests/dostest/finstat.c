#include <tos.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	int hdl;
	long i;

	if	(argc != 2)
		{
		printf("FINSTAT fname");
		return(-1);
		}
	hdl = (int) Fopen(argv[1], 0);
	i = gemdos(0x105, hdl);
	printf("Finstat => %ld\n", i);
	return((int) i);
}