#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>


int main( void )
{
	long ret;
	char buf[256];

	ret = Dgetdrv();
	printf("\r\nDgetdrv => %ld (%c:)\n", ret, ((int) ret)+'A');
	ret = Dgetpath(buf, 0);		/* akt. LW */
	printf("\r\nDgetpath => %ld (\"%s\")\n", ret, buf);
	Cnecin();
	return(0);
}

