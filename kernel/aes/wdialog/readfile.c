#include "wdlgmain.h"
#include "filestat.h"
#include <sys/stat.h>

void *readfile(const char *filename, LONG *size)
{
	XATTR xattr;
	void *buf;
	
	buf = NULL;
	if (filestat(0, filename, &xattr) == 0 &&
		(xattr.st_mode & S_IFREG))
	{
		buf = Malloc(xattr.st_size);
		if (buf != NULL)
		{
			*size = readbuf(filename, buf, 0, xattr.st_size);
			if (*size != xattr.st_size)
			{
				Mfree(buf);
				buf = NULL;
			}
		}
	}
	return buf;
}


LONG readbuf(const char *filename, void *buf, LONG offset, LONG size)
{
	LONG readsize;
	LONG fh;
	
	readsize = 0;
	fh = Fopen(filename, FO_READ);
	if (fh > 0)
	{
		Fseek(offset, (WORD)fh, SEEK_SET);
		readsize = Fread((WORD)fh, size, buf);
		Fclose((WORD)fh);
	}
	return readsize;
}


LONG writebuf(const char *filename, void *buf, LONG offset, LONG size)
{
	LONG writesize;
	LONG fh;
	
	writesize = 0;
	fh = Fopen(filename, FO_WRITE);
	if (fh > 0)
	{
		Fseek(offset, (WORD)fh, SEEK_SET);
		writesize = Fwrite((WORD)fh, size, buf);
		Fclose((WORD)fh);
	}
	return writesize;
}
