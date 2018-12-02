#include <tos.h>
#include <stdio.h>


int main()
{
	long retcode;
	retcode = Fopen("CON:", 2);
	printf("%ld\n", retcode);
	Cconin();
	return((int) retcode);
}