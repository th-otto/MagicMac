#include <tos.h>
#include <stddef.h>
#include "filediv.h"


unsigned char *load_file(const char *filename, long *size)
{
	DTA *olddta;
	DTA dta;
	unsigned char *buf = NULL;
	
	olddta = Fgetdta();
	Fsetdta(&dta);
	if (Fsfirst(filename, FA_CHANGED|FA_RDONLY|FA_HIDDEN|FA_SYSTEM) == 0)
	{
		buf = (unsigned char *)Malloc_sys(dta.d_length);
		if (buf != NULL)
		{
			*size = read_file(filename, buf, 0, dta.d_length);
			if (*size != dta.d_length)
			{
				Mfree_sys(buf);
				buf = NULL;
			}
		}
	}
	Fsetdta(olddta);
	return buf;
}


long read_file(const char *filename, void *buf, long offset, long size)
{
	long fd;
	long retsize = 0;
	
	fd = Fopen(filename, FO_READ);
	if (fd > 0)
	{
		Fseek(offset, (short)fd, SEEK_SET);
		retsize = Fread((short)fd, size, buf);
		Fclose((short)fd);
	}
	return retsize;
}
