#include <tos.h>

#define FLEN	40000L
#define BUFLEN	(FLEN/sizeof(long))

long data[BUFLEN];

int main()
{
	long retcode;
	int handle;
	register long i;
	long *d;

	d = data;
	for	(i = 0; i < BUFLEN; i++)
		*d++ = i;

	retcode = Fcreate("$$$", 0);
	if	(retcode < 0L)
		return((int) retcode);
	handle = (int) retcode;
	retcode = Fwrite(handle, 40000L, data);
	if	(retcode != 40000L)
		return((int) retcode);
	Fclose(handle);
	return(0);
}