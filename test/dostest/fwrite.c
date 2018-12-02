/* Testprogramm fÅr fortgesetztes Fseek und Fread */

#include <tos.h>
#include <stdlib.h>

#define WLEN	6
#define FLEN	40000L
#define BUFLEN	(FLEN/sizeof(long))

long data[BUFLEN];

char buf[WLEN];

int main( void )
{
	int hdl;
	long pos;
	register long i;
	long *d;
	char *b;

	b = (char *) data;
	d = data;
	for	(i = 0; i < BUFLEN; i++)
		*d++ = i;


	hdl = (int) Fopen("$$$", FO_RW);
	if	(hdl < 0)
		return(hdl);
	for	(;;)
		{
		if	(Cconis())
			return(0);
		pos = rand() % (FLEN-WLEN);
		if	(pos != Fseek(pos, hdl, SEEK_SET))
			return((int) pos);
		if	(WLEN != Fwrite(hdl, WLEN, b + pos))
			return(-1);
		}
}