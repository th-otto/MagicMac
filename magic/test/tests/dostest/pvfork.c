#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main( void )
{
	long ret;
	long testvar = 4711;


	printf("testvar = %ld\n", testvar);
	ret = Pvfork( );
	printf("Pvfork() => %ld\n", ret);
	if	(ret < 0)
		return((int) ret);		/* Fehler */
	if	(ret > 0)
		{
		Cconws("Ich bin der Kindprozež\r\n");
		testvar = 815;
		printf("testvar := %ld\n", testvar);
		Pterm0();
		}
	else	{
		Cconws("Ich bin der Elterprozež\r\n");
		printf("testvar = %ld\n", testvar);
		Pterm0();
		}
	return(0);
}
