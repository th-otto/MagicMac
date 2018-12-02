#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	int drv;
	long ret;
	DISKINFO buf;

	if (argc < 2)
	{
		drv = 0;
	} else
	{
		if (argc != 2)
		{
		  err:
			Cconws("syntax: DFREE X:\r\n");
			return 1;
		}
		argv[1][0] &= 0x5f;				/* toupper */
		if ((argv[1][1] != '\0') && (argv[1][1] != ':'))
			goto err;
		drv = argv[1][0] - 'A' + 1;
	}

	ret = Dfree(&buf, drv);
	if (ret != 0)
	{
		printf("=> Fehler %ld\n", ret);
	} else
	{
		if (drv == 0)
			drv = Dgetdrv();
		else
			drv--;
		printf("Information for drive %c:\n"
		       "------------------------\n", drv + 'A');
		printf("%lu clusters free\n", buf.b_free);
		printf("%lu clusters total\n", buf.b_total);
		printf("%lu bytes/sector\n", buf.b_secsiz);
		printf("%lu sectors/cluster\n", buf.b_clsiz);
	}
	return (int) ret;
}
