#include <tos.h>
#include <mgx_dos.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void swrite( char *s );

int main( int argc, char *argv[] )
{
	long ret;
	char *s;
	int code;
	long name;


	if	(argc != 4)
		{
		err:
		swrite("Syntax: PSEMAPHO -[c|d|g|r] name timeout\r\n"
			  "        -c Semaphore erstellen\r\n"
			  "        -d Semaphore entfernen\r\n"
			  "        -g Semaphore holen\r\n"
			  "        -r Semaphore freigeben\r\n");
		return(1);
		}

	s = argv[1];
	if	(*s++ != '-')
		goto err;

	switch(toupper(*s++))
		{
		case 'C': code = PSEM_CRGET;break;
		case 'D': code = PSEM_DESTROY;break;
		case 'G': code = PSEM_GET;break;
		case 'R': code = PSEM_RELEASE;break;
		default: goto err;
		}

	if	(*s)
		goto err;

	s = argv[2];
	name = 0L;
	while(*s)
		{
		name <<= 8;
		name |= *s++;
		}

	if	(code == PSEM_DESTROY)
		{
		ret = Psemaphore(PSEM_GET, name, atol(argv[3]));
		if	(ret)
			{
			printf("Rckgabe PSEM_GET: %ld\n", ret);
			return((int) ret);
			}
		}
	ret = Psemaphore(code, name, atol(argv[3]));
	printf("Rckgabe: %ld\n", ret);
	if	(code == PSEM_GET)
		{
		swrite("Taste ... ");
		Cconin();
		}
	return((int) ret);
}

void swrite( char *s )
{
	Fwrite(-1, strlen(s), s);
}