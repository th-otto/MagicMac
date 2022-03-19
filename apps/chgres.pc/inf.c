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
#if 0
struct res *vgainf_modes[NUM_ET4000];
short et4000_driver_ids[NUM_ET4000];
#else
struct res *nvdipc_modes[NUM_NVDIPC];
short nvdipc_driver_ids[NUM_NVDIPC];
#endif

static long next_line(char *s, long maxlen, long *valid);
static int get_driver_id(char *line, const char *str, short *id);
static char *find_str(char *line, const char *str, char **end);
static char *skip_white(char *s);
static char *find_line(char *buf, const char *str, long size, long *remain, long *linesize);




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
#if 0
		for (i = 0; i < NUM_ET4000; i++)
		{
			get_driver_id(buf, et4000_driver_names[i], &et4000_driver_ids[i]);
		}
#else
		for (i = 0; i < NUM_NVDIPC; i++)
		{
			get_driver_id(buf, nvdipc_driver_names[i], &nvdipc_driver_ids[i]);
		}
#endif
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
		char linebuf[32];
		char numbuf[8];
		long linesize;
		long remain;
		long fd;

		p = find_line(buf, "#_DEV", size, &remain, &linesize);
		if (remain == 0)
		{
			p = find_line(buf, "#[aes]", size, &remain, &linesize);
			p += linesize;
			linesize = 0;
		}
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


static char *find_line(char *p, const char *str, long size, long *remain, long *linesize)
{
	char *end;
	long valid;
	char linebuf[512];
	int i;
	long lsize;
	
	do
	{
		lsize = next_line(p, size, &valid);
		size -= lsize;
		if (valid > 511)
			valid = 511;
		for (i = 0; i < valid; i++)
			linebuf[i] = p[i];
		linebuf[i] = '\0';
		if (find_str(linebuf, str, &end) != NULL)
			break;
		p += lsize;
	} while (size > 0 && lsize > 0);
	*remain = size;
	*linesize = lsize;
	return p;
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
	if (*str == '\0')
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


static long read_file(const char *filename, void *buffer, long offset, long size);

void *load_file(const char *filename, long *size)
{
	DTA *olddta;
	DTA dta;
	void *buf;
	
	buf = NULL;
	olddta = Fgetdta();
	Fsetdta(&dta);
	if (Fsfirst(filename, FA_READONLY|FA_HIDDEN|FA_SYSTEM|FA_ARCHIVE) == 0)
	{
		buf = (void *)m_alloc(dta.d_length);
		if (buf != NULL)
		{
			*size = read_file(filename, buf, 0, dta.d_length);
			if (*size != dta.d_length)
			{
				m_free(buf);
				buf = NULL;
			}
		}
	}
	Fsetdta(olddta);
	return buf;
}


static long read_file(const char *filename, void *buffer, long offset, long size)
{
	long fd;
	long rsize;
	
	rsize = 0;
	fd = Fopen(filename, FO_READ);
	if (fd > 0)
	{
		Fseek(offset, (short)fd, 0);
		rsize = Fread((short)fd, size, buffer);
		Fclose((short)fd);
	}
	return rsize;
}
