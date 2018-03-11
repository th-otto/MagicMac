#include <tos.h>
#include <string.h>
#include <tosdefs.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int	omode;
	char	path[128] = "u:\\dev\\";
	long i,r;
	int  hdl;
	char *s = "abcdefghijklmnop\r\nqrstuvwxyz0123456789\r\n";


	if	(argc != 3)
		{
		printf("TST_DEV devname openmode\n");
		return(-1);
		}

	strcat(path, argv[1]);
	omode = atoi(argv[2]);
	printf("Teste Datei %s mit Modus %d\n", path, omode);
	i = Fopen(path, omode);
	printf("Fopen => %ld\n", i);
	if	(i >= 0)
		{
		hdl = (int) i;
		i = Fwrite(hdl, strlen(s), s);
		printf("Fwrite => %ld\n", i);
		i = Fread( hdl, 6L, s);
		if	(i >= 0L)
			{
			s[i] = '\0';
			printf("Fread => %ld, String _%s_\n", i, s);
			}
		else	printf("Fread => %ld\n", i);

		r = 1L << hdl;
		i = Fselect(10000, &r, NULL, 0L);
		printf("Fselect zum Lesen:     mask = %ld, ret = %ld\n", r, i);
		r = 1L << hdl;
		i = Fselect(10000, NULL, &r, 0L);
		printf("Fselect zum Schreiben: mask = %ld, ret = %ld\n", r, i);

		i = Fclose(hdl);
		printf("Fclose => %ld\n", i);
		}

	return(0);
}
