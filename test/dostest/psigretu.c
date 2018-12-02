#include <tos.h>
#include <setjmp.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#undef SIGUSR1
#define SIGUSR1 29
#undef SIGUSR2
#define SIGUSR2 30
#undef SIGTERM
#define SIGTERM 15

jmp_buf env;

void cdecl handler(long signr)
{
	printf("handler: Signal %ld empfangen.\n", signr);
	Cconws("Mache Psigreturn()\r\n");
	if	(!Psigreturn())		/* wenn Aufruf OK... */
		longjmp(env, 1);		/* ... dann springen */
}

int main( void )
{
	long ssp;

	printf("Meine ProcID ist %d.\n", Pgetpid());
	Psignal(SIGUSR1, handler);

	if	(setjmp(env))
		Cconws("komme von longjmp.\r\n");
	else	Cconws("komme von setjmp.\r\n");
	ssp = Super(0L);
	Super((void *) ssp);
	printf("ssp = 0%08lx\n", ssp);
	Cconin();
	return(0);
}
