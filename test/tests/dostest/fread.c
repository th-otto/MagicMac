/* Testprogramm fÅr fortgesetztes Fseek und Fread */

#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <magx.h>

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


	hdl = (int) Fopen("$$$", O_RDONLY);
	if	(hdl < 0)
		return(hdl);
	for	(;;)
		{
		pos = rand() % (FLEN-WLEN);
		Fseek(pos, hdl, SEEK_SET);
		Fread(hdl, WLEN, buf);
		/* Sollwert ausrechnen */
		for	(i = 0; i < WLEN; i++)
			{
			if	(buf[i] != b[i + pos])
				Cconws("#### ERROR ###\r\n");
			}
		}
}