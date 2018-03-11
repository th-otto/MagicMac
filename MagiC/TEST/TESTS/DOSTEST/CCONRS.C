#include <tos.h>
#include <stdio.h>


int main()
{
	long ret;
	LINE s;

	s.maxlen = 20;
	ret = Cconrs(&s);
	printf("\r\nret = %ld len = %d\n", ret, s.actuallen);
	Fwrite(1, (long) s.actuallen, s.buffer);
	return(0);
}