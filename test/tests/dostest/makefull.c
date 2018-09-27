/* Testprogramm fÅr FÅllen der Platte */

#include <stdio.h>
#include <tos.h>
#include <tosdefs.h>

#define BUFLEN	8192
char buf[BUFLEN];

int main( void )
{
	int hdl;
	long ret;


	hdl = (int) Fcreate("$$$", 0);
	if	(hdl < 0)
		return(hdl);
	for	(;;)
		{
		ret = Fwrite(hdl, BUFLEN, buf);
		if	(ret != BUFLEN)
			{
			printf("%ld\n", ret);
			Cconin();
			}
		}
}