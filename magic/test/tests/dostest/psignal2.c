#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void cdecl handler(long signr)
{
	long i;

	printf("handler: Signal %ld empfangen.\n", signr);
	Cconws("warte...");
	for	(i = 0; i < 7000000L; i++)
		;
	Cconws("...OK\r\n");
}

int main( void )
{
	long ret;

	printf("Meine ProcID ist %d.\n", Pgetpid());
	ret = (long) Psignal(SIGUSR1, handler);
	printf("Psignal => %ld\n", ret);
	ret = (long) Psignal(SIGUSR2, handler);
	printf("Psignal => %ld\n", ret);
	for	(;;)
		Cconout('a');
	return(0);
}
