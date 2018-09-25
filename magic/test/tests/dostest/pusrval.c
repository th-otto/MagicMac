#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( void )
{
	long ret;


	ret = Pusrval(11);
	printf("\r\nHole Usrval: RÅckgabe: %ld\n", ret);
	ret = Pusrval((int) ret);
	printf("\r\nSetze wieder altes: RÅckgabe: %ld\n", ret);
	return(0);
}
