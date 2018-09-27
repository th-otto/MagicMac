/* Symlink l”schen */

#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void readline(char *s, int len);


int main(int argc, char *argv[])
{
	char new[128];
	long ret;


	if	(argc != 2)
		{
		Cconws("Syntax: RMSLINK linkname\r\n");
		Cconws("\r\nName des Links:     ");readline(new, 127);
		ret = Fdelete(new);
		}
	else	{
		ret = Fdelete(argv[1]);
		}
/*	printf("\r\n%ld\n", ret);	*/
	return((int) ret);
}



/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

void readline(char *s, int len)
{
	long ret;

	ret = Fread(STDIN, (long) len, s);
	if	(ret < 0)
		exit((int) ret);
	s[ret] = '\0';
}
