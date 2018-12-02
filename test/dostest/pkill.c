#include <tos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( int argc, char *argv[] )
{
	int pid;
	int sig;
	long ret;

	if	(argc != 3)
		{
		Cconws("Syntax: PKILL pid signr\r\n");
		Cconws("nr  Name      Default\r\n");
		Cconws("---------------------\r\n");
		Cconws(" 0: SIGNULL   ignoriert\r\n");
 		Cconws(" 1: SIGHUP    Programmende\r\n");
 		Cconws(" 2: SIGINT    Programmende\r\n");
 		Cconws(" 3: SIGQUIT   Programmende\r\n");
 		Cconws(" 4: SIGILL    Programmende\r\n");
 		Cconws(" 5: SIGTRAP   Programmende\r\n");
 		Cconws(" 6: SIGABRT   Programmende\r\n");
 		Cconws(" 7: SIGPRIV   Programmende\r\n");
 		Cconws(" 8: SIGFPE    ignoriert\r\n");
 		Cconws(" 9: SIGKILL   Programmende\r\n");
 		Cconws("10: SIGBUS    Programmende\r\n");
 		Cconws("11: SIGSEGV   Programmende\r\n");
 		Cconws("12: SIGSYS    Programmende\r\n");
 		Cconws("13: SIGPIPE   Programmende\r\n");
 		Cconws("14: SIGALRM   Programmende\r\n");
 		Cconws("15: SIGTERM   Programmende\r\n");
 		Cconws("16: SIGURG    Programmende\r\n");
 		Cconws("17: SIGSTOP   Stop\r\n");
 		Cconws("18: SIGTSTP   Stop\r\n");
 		Cconws("19: SIGCONT   Continue\r\n");
 		Cconws("20: SIGCHLD   ignoriert\r\n");
 		Cconws("21: SIGTTIN   Stop\r\n");
 		Cconws("22: SIGTTOU   Stop\r\n");
 		Cconws("23: SIGIO     Programmende\r\n");
 		Cconws("24: SIGXCPU   Programmende\r\n");
 		Cconws("25: SIGXFSZ   Programmende\r\n");
 		Cconws("26: SIGVTALRM Programmende\r\n");
 		Cconws("27: SIGPROF   Programmende\r\n");
 		Cconws("28: SIGWINCH  ignoriert\r\n");
 		Cconws("29: SIGUSR1   Programmende\r\n");
 		Cconws("30: SIGUSR2   Programmende\r\n");
		return(1);
		}
	pid = atoi(argv[1]);
	sig = atoi(argv[2]);
	ret = Pkill(pid, sig);
	return((int)ret);
}
