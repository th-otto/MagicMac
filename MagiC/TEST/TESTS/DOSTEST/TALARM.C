#include <mgx_dos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static int count = 0;
static int sem = 0;
static int blocked = 0;

void cdecl handler(long signr)
{
	if	(!sem)
		{
		if	(signr == SIGALRM)
			Cconws("handler: Signal SIGALRM empfangen\r\n");
		else	Cconws("handler: Signal ? empfangen\r\n");
		}
	else	blocked++;
	count++;
}

int main( void )
{
	long ret;
	char s[10];

	Psignal(SIGALRM, handler);
	Cconws("Talarm mit 10 Sekunden\r\n");
	ret = Talarm(10);
	if	(ret < 0)
		return((int) ret);
	while(!count)
		{
		ltoa(Talarm(-1), s, 10);
		sem++;
		Cconws("Noch ");
		Cconws(s);
		Cconws("s\r\n");
		if	(Cconis())
			{
			Cnecin();
			ltoa(Talarm(0), s, 10);
			Cconws("Alarm abgebrochen => ");
			Cconws(s);
			Cconws("\r\n");
			count++;
			sem--;
			break;
			}
		sem--;
		for	(ret = 0; ret < 2000000L; ret++)
			;
		}

	sem++;
	if	(blocked)
		{
		Cconws("Signalhandler verborgen ausgefhrt\r\n");
		blocked--;
		}
	Cconws("Tmalarm mit 1000 Millisekunden\r\n");
	sem--;
	ret = Tmalarm(1000);
	if	(ret < 0)
		return((int) ret);
	while(count < 2)
		{
		ltoa(Tmalarm(-1), s, 10);
		sem++;
		Cconws("Noch ");
		Cconws(s);
		Cconws("ms\r\n");
		sem--;
		for	(ret = 0; ret < 400000L; ret++)
			;
		}
	sem++;
	if	(blocked)
		{
		Cconws("Signalhandler verborgen ausgefhrt\r\n");
		blocked--;
		}
	Cconws("Ende");
	sem--;
	return(0);
}
