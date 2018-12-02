#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void readline(char *s, int len);


int main(int argc, char *argv[])
{
	char new[128];
	register int i,n;


	if	(argc != 2)
		{
		Cconws("Syntax: DPATHCNF pfadname\r\n");
		Cconws("\r\nPfad:     ");readline(new, 127);
		}
	else	{
		strcpy(new, argv[1]);
		}

	n = (int) Dpathconf(new, -1);
	if	(n >= 0)
		{
		for	(i = 0; i <= n; i++)
			{
			printf("Modus %2d => %2d\n", i, (int) Dpathconf(new, i));
			}
		return(0);
		}
	return(n);
}



/*********************************************************************
*
* Wandelt DOS- Datum in eine Zeichenkette um.
*
*********************************************************************/

void readline(char *s, int len)
{
	long ret;

	ret = Fread(0, (long) len, s);
	if	(ret < 0)
		exit((int) ret);
	s[ret] = '\0';
}
