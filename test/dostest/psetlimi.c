#include <tos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( void )
{
	long ret;
	int i;
	
	for (i = 0; i < 4; i++)
	{
		ret = Psetlimit(i, -1L);
		printf("Hole  Limit(%d): Rckgabe: %ld\n", i, ret);
	}
	ret = Psetlimit(3, 128000L);
	printf("\r\nSetze Limit: Rckgabe: %ld\n", ret);
	ret = Psetlimit(3, -1L);
	printf("\r\nHole  Limit: Rckgabe: %ld\n", ret);
	return(0);
}
