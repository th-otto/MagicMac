#include <tos.h>
#include <stdio.h>


int main()
{
	long ret;
	short hdl[2];

	ret = Fpipe(hdl);
	printf("\r\nret = %ld hdl1 = %d hdl2 = %d\n", ret, hdl[0], hdl[1]);
	Cconin();
	return(0);
}