#include <tos.h>
#include <aes.h>
#include <setjmp.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

jmp_buf env;

void cdecl handler(long signr)
{
	printf("handler: Signal %ld empfangen.\n", signr);
	Cconws("Mache Psigreturn()\r\n");
	Psigreturn();
	longjmp(env, 1);
}

int main( void )
{
	long ssp;

	appl_init();
	printf("Meine ProcID ist %d.\n", Pgetpid());
	Psignal(SIGUSR1, handler);

	if	(setjmp(env))
		Cconws("komme von longjmp.\r\n");
	else	Cconws("komme von setjmp.\r\n");
	ssp = Super(0L);
	Super((void *) ssp);
	printf("ssp = 0%08lx\n", ssp);
	evnt_keybd();
	return(0);
}
