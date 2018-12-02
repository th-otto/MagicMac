#include <tos.h>
#include <stdio.h>

int main()
{
	long i;

	while((Cconin() & 0xff) != ' ')
		;
	i = Dlock(1, 0);		/* mode,drv */
	printf("locking mode 1: %ld\n", i);
	i = Dlock(3, 0);		/* mode,drv */
	printf("locking mode 3: %ld\n", i);
	while((Cconin() & 0xff) != ' ')
		;
	i = Dlock(0, 0);
	printf("unlocking: %ld\n", i);
	while((Cconin() & 0xff) != ' ')
		;
	return(0);
}