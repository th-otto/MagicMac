#ifdef __PUREC__
#include <portab.h>
#include <aes.h>
#include <tos.h>
#else
#include <gem.h>
#include <osbind.h>
#include <support.h>
#define itoa(val, buf, base) _itoa(val, buf, base, 0)
#define DTA _DTA
#define d_length dta_size
#define FA_READONLY 0x01
#define FA_ARCHIVE  0x20
#endif
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"

struct res *possible_resolutions[MAX_DEPTHS];
struct res *vgainf_modes[NUM_ET4000];
short et4000_driver_ids[NUM_ET4000];

static long next_line(char *s, long maxlen, long *valid);
static int get_driver_id(char *line, const char *str, short *id);
static char *find_str(char *line, const char *str, char **end);
static char *skip_white(char *s);




void read_assign_sys(const char *path)
{
	char buf[512];
	long size;
	long valid;
	char *assign;
	char *p;
	long linesize;
	int i;
	
	assign = load_file(path, &size);
	if (assign == NULL)
		return;
	p = assign;
	do
	{
		linesize = next_line(p, size, &valid);
		size -= linesize;
		if (valid < 512)
		{
			memcpy(buf, p, valid);
			buf[valid] = '\0';
		} else
		{
			memcpy(buf, p, 512);
			buf[511] = '\0';
		}
		strupr(buf);
		for (i = 0; i < NUM_ET4000; i++)
		{
			get_driver_id(buf, et4000_driver_names[i], &et4000_driver_ids[i]);
		}
		p += linesize;
	} while (size > 0 && linesize > 0);
	Mfree(assign);
}


static int get_driver_id(char *line, const char *str, short *id)
{
	if (strstr(line, str) != NULL)
	{
		*id = atoi(line);
		return TRUE;
	}
	return FALSE;
}


int change_magx_inf(WORD rez, WORD vmode)
{
	WORD ret;
	char *buf;
	long size;
	
	ret = 0;
	(void)" %d %d ";
	buf = load_file("\\MAGX.INF", &size);
	if (buf != NULL)
	{
		char *p;
		char linebuf[512];
		long valid;
		long remain;
		long linesize;
		long fd;
		int i;

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
	char *start;
	
	p = line;
	start = skip_white(p);
	p = start;
	while (*p && *p == *str)
	{
		p++;
		str++;
	}
	if (*p != '\0' && *str == '\0')
	{
		*end = p;
	} else
	{
		*end = NULL;
		start = NULL;
	}
	return start;
}


static char *skip_white(char *s)
{
	while (*s == ' ' || *s == '\t')
		s++;
	return s;
}


static long next_line(char *s, long maxlen, long *valid)
{
	char *start = s;
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
	return p - start;
}


void *load_file(const char *filename, long *size)
{
	DTA *olddta;
	DTA dta;
	void *buf;
	long fd;
	
	buf = NULL;
	*size = 0;
	olddta = Fgetdta();
	Fsetdta(&dta);
	if (Fsfirst(filename, FA_READONLY|FA_HIDDEN|FA_SYSTEM|FA_ARCHIVE) == 0)
	{
		buf = (void *)Malloc(dta.d_length);
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
