#include <tos.h>
#include <stdio.h>


int main()
{
	long ret;

	ret = Cconin();
	printf(" => %08lx\n", ret);
	return(0);
}