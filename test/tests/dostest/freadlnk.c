#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void readline(char *s, int len);


int main(int argc, char *argv[])
{
	char old[128],new[128];
	long ret;


	if	(argc != 2)
		{
		Cconws("Syntax: FREADLINK pfadname\r\n");
		Cconws("\r\nName des Links:     ");readline(new, 127);
		ret = Freadlink(128, old, new);
		}
	else	{
		ret = Freadlink(128, old, argv[1]);
		}
/*	printf("\r\n%ld\n", ret);	*/
	if	(ret >= 0)
		{
		Cconws(old);
		Cconws("\r\n");
		}
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
