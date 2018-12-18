#include <tos.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>


int main( void )
{
	long ret;
	int drv;
	char buf[256];

	drv = Dgetdrv();
	printf("\r\nDgetdrv => %d (%c:)\n", drv, drv >= 26 ? drv - 26 + '1' : drv +'A');
	ret = Dgetpath(buf, 0);		/* akt. LW */
	printf("\r\nDgetpath => %ld (\"%s\")\n", ret, buf);
	Cnecin();
	return(0);
}

