#include <tos.h>
#include <tosdefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


int main( int argc, char *argv[] )
{
	long ret;
	DTA mydta;
	int attr,sattr;
	char *s;


	if	(argc == 3)
		{
		sattr = (int) strtoul(argv[2], &s, 0);
		argc--;
		}
	else sattr = 0;

	if	(argc != 2)
		{
		Cconws("Syntax: FSFIRST path [sattr]\r\n");
		return(1);
		}

	Fsetdta(&mydta);
	ret = Fsfirst(argv[1], sattr);
	printf("\r\nFsfirst ");
	for	(;;)
		{
		printf("Rckgabe: %ld\n", ret);
		if	(ret >= 0)
			{
			attr = mydta.d_attrib;
			if	(attr & FA_SYMLINK) Cconws("Symlink ");
			if	(attr & FA_ARCHIVE) Cconws("Archiv ");
			if	(attr & FA_SUBDIR ) Cconws("Subdir ");
			if	(attr & FA_VOLUME ) Cconws("Label ");
			if	(attr & FA_SYSTEM ) Cconws("System ");
			if	(attr & FA_HIDDEN ) Cconws("Hidden ");
			if	(attr & FA_RDONLY ) Cconws("Rdonly ");
			Cconws(mydta.d_fname);
			Cconws(" ");
			Cconws("\r\n");
			}
		else break;
		ret = Fsnext();
		}
	return(0);
}
