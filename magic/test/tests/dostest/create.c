#include <tos.h>
#include <string.h>


#define BUFLEN 1024

static char buf[BUFLEN];

int main(int argc, char *argv[])
{
	char *endptr;
	long retcode;
	int handle;
	long flen;
	char *fname;


	if	(argc != 3)
		{
		syntax:
		Cconws("Syntax: CREATE fname size[k|m]");
		return(1);
		}

	flen = strtoul(argv[2], &endptr, 10);
	if	(!stricmp(endptr, "k"))
		flen <<= 10L;
	else
	if	(!stricmp(endptr, "m"))
		flen <<= 20L;
	else
	if	(*endptr)
		goto syntax;

	fname = argv[1];
	retcode = Fcreate(fname, 0);
	if	(retcode < 0L)
		return((int) retcode);

	handle = (int) retcode;

	while(flen >= BUFLEN)
		{
		retcode = Fwrite(handle, BUFLEN, buf);
		flen -= BUFLEN;
		if	(retcode != BUFLEN)
			goto err;
		}

	while(flen)
		{
		retcode = Fwrite(handle, 1, buf);
		flen -= 1;
		if	(retcode != 1)
			{
			err:
			Fclose(handle);
			if	(retcode > 0)
				return((int) -1);
			return((int) retcode);
			}
		}

	Fclose(handle);
	return(0);
}