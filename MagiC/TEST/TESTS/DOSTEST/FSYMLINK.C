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


	if	(argc != 3)
		{
		Cconws("Syntax: FSYMLINK pfadname linkname\r\n");
		Cconws("\r\nName einer Datei:   ");readline(old, 127);
		Cconws("\r\nName des Links:     ");readline(new, 127);
		ret = Fsymlink(old, new);
		}
	else	{
		ret = Fsymlink(argv[1], argv[2]);
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
