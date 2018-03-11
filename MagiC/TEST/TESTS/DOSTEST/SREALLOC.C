#include <magix.h>
#include <stdio.h>
#include <tos.h>

#define Srealloc(a) gemdos(0x15, a)

int main()
{
	long ret;

	printf("L„nge: ");
	scanf("%ld", &ret);
	ret = Srealloc(ret);
	printf("Srealloc => %08lx == %ld\n", ret, ret);
	return(0);
}