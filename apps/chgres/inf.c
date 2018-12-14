#include <portab.h>
#include <aes.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"

static char *skip_white(char *s);
static char *load_file(const char *filename, long *size);
static long next_line(char *s, long maxlen, long *valid);
static char *find_str(char *line, const char *str, char **end);


WORD save_rez(WORD rez, WORD vmode)
{
	char *buf;
	char *p;
	char linebuf[512];
	long valid;
	long size;
	long remain;
	WORD ret;
	long linesize;
	long fd;
	int i;
	
	ret = 0;
	buf = load_file("\\MAGX.INF", &size);
	if (buf != NULL)
	{
		p = buf;
		remain = size;
		do
		{
			linesize = next_line(p, remain, &valid);
			remain -= linesize;
			if (valid > 511)
				valid = 511;
			for (i = 0; i < valid; i++)
				linebuf[i] = p[i];
			linebuf[i] = '\0';
			{
				char *end;
				
				if (find_str(linebuf, "#_DEV", &end) != NULL)
					break;
			}
			p += linesize;
		} while (remain > 0 && linesize > 0);
		fd = Fcreate("\\MAGX.INF", 0);
		if (fd > 0)
		{
			if (remain > 0)
			{
				Fwrite((short)fd, p - buf, buf);
				p += linesize;
			} else
			{
				p = buf;
			}
			{
				char numbuf[8];

				strcpy(linebuf, "#_DEV ");
				itoa(rez, numbuf, 10);
				strcat(linebuf, numbuf);
				strcat(linebuf, " ");
				itoa(vmode, numbuf, 10);
				strcat(linebuf, numbuf);
				strcat(linebuf, "\015\012");
				Fwrite((short)fd, strlen(linebuf), linebuf);
				Fwrite((short)fd, size - (p - buf), p);
				Fclose((short)fd);
				ret = 1;
			}
		}
		Mfree(buf);
	}
	return ret;
}


static char *find_str(char *line, const char *str, char **end)
{
	char *p;
	
	line = skip_white(line);
	p = line;
	while (*p && *p == *str)
	{
		p++;
		str++;
	}
	if (*p != '\0' && *str == '\0')
	{
		*end = p;
		return line;
	} else
	{
		*end = NULL;
		return NULL;
	}
}


static char *skip_white(char *s)
{
	while (*s == ' ' || *s == '\t')
		s++;
	return s;
}


static long next_line(char *s, long maxlen, long *valid)
{
	char *p;
	char c;
	int comment;
	
	p = s;
	*valid = 0;
	comment = 0;
	while (maxlen > 0)
	{
		c = *p++;
		maxlen--;
		if (c == 0x0d)
		{
			if (*p == 0x0a)
			{
				p++;
				maxlen--;
			}
			break;
		}
		if (c == 0x0a)
			break;
		if (c == ';' || c == '*')
			comment = 1;
		if (comment == 0)
			++(*valid);
	}
	return p - s;
}


static char *load_file(const char *filename, long *size)
{
	DTA *olddta;
	DTA dta;
	char *buf;
	long fd;
	
	buf = NULL;
	*size = 0;
	olddta = Fgetdta();
	Fsetdta(&dta);
	if (Fsfirst(filename, FA_READONLY|FA_HIDDEN|FA_SYSTEM|FA_ARCHIVE) == 0)
	{
		buf = Malloc(dta.d_length);
		if (buf != NULL)
		{
			fd = Fopen(filename, FO_READ);
			if (fd > 0)
			{
				*size = Fread((short)fd, dta.d_length, buf);
				Fclose((short)fd);
			}
			if (*size != dta.d_length)
			{
				Mfree(buf);
				buf = NULL;
			}
		}
	}
	Fsetdta(olddta);
	return buf;
}
