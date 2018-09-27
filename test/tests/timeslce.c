#include <tos.h>
#include <magix.h>
#include <stdlib.h>
#include <stdio.h>

#define P_COOKIES	((long *)			0x5a0)

/* d0.l = long ctrl_timeslice( d0.lo = int ticks, d0.hi = int count ) */

long get_cookie(long code)
{
	long oldssp;
	unsigned long	*cookie,*p_cookies;

	oldssp    = Super(0L);
	p_cookies = cookie = (unsigned long *) (* P_COOKIES);
	Super((char *) oldssp);

	while(p_cookies && *cookie)
		{
		if	(*cookie == code)
			{
			cookie++;
			return(*cookie);
			}
		cookie += 2;
		}
	return(-1L);
}

void getstring( char *s, int n )
{
	s[Fread(STDIN, (long) n, s)] = '\0';
}

int main()
{
	char s[20];
	MAGX_COOKIE *magxcookie;
	AESVARS *aesvars;
	union _oldval {
		int data[2];
		long val;
		} oldval;


	magxcookie = (MAGX_COOKIE *) get_cookie('MagX');
	if	(!magxcookie)
		{
		Cconws("Kein Mag!X aktiv\r\n");
		return(-1);
		}
	aesvars = magxcookie->aesvars;
	if	(!aesvars)
		{
		Cconws("Kein Mag!X- AES aktiv\r\n");
		return(-2);
		}
	Cconws("Hintergrund- Priorit„t:   1:");
	getstring(s, 19);
	if	(s[0])
		oldval.data[0] = atoi(s);
	else oldval.data[0] = -2;

	Cconws("\r\n");
	Cconws("Zeitscheibentick:       5ms*");
	getstring(s, 19);
	if	(s[0])
		oldval.data[1] = atoi(s);
	else oldval.data[1] = -2;

	Cconws("\r\n");
	oldval.val = aesvars->ctrl_timeslice( oldval.val );
	printf("cnt = %d ticks = %d\n", oldval.data[0], oldval.data[1]);
	return(0);
}
