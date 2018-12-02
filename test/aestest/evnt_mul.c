#include <tos.h>
#include <aes.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#undef SIGUSR1
#define SIGUSR1 29
#undef SIGUSR2
#define SIGUSR2 30
#undef SIGTERM
#define SIGTERM 15


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
	int msg[8];
	int ret2;
	int  ev_mwhich, ev_mbreturn, keycode, kstate,
		ev_mmobutton, ev_mmoy, ev_mmox;


	if	(0 > appl_init())
		return(-1);
	printf("Meine ProcID ist %d.\n", Pgetpid());
	ret = (long) Psignal(SIGUSR1, handler);
	printf("Psignal => %ld\n", ret);
	ret = (long) Psignal(SIGUSR2, handler);
	printf("Psignal => %ld\n", ret);
	ret = (long) Psignal(SIGTERM, handler);
	printf("Psignal => %ld\n", ret);
	for	(;;)
		{
		ev_mwhich = evnt_multi(MU_KEYBD+MU_BUTTON+MU_MESAG+MU_TIMER,
						  2,			/* Doppelklicks erkennen 	*/
						  1,			/* nur linke Maustaste		*/
						  1,			/* linke Maustaste gedrckt	*/
						  0,0,0,0,0,	/* kein 1. Rechteck			*/
						  0,0,0,0,0,	/* kein 2. Rechteck			*/
						  msg,
						  10000,	/* ms */
						  &ev_mmox, &ev_mmoy,
						  &ev_mmobutton, &kstate,
						  &keycode, &ev_mbreturn
						  );
		printf("evnt_multi => %d\n", ev_mwhich);
		for	(ret2 = 0; ret2 < 8; ret2++)
			printf("msg[%d] == %02x\n", ret2, msg[ret2]);
		printf("\n");
		}
}
