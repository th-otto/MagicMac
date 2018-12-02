#include <stdio.h>
#include <tos.h>
#include <aes.h>

int main()
{
	int r,i1,i2,i3,i4;

	r = appl_getinfo(0, &i1, &i2, &i3, &i4);
	printf("%d %d %d %d %d\n", r, i1, i2, i3, i4);
	Cnecin();
	return(0);
}