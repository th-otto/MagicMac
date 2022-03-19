#ifdef __PUREC__
#include <portab.h>
#include <aes.h>
#include <tos.h>
#else
#include <gem.h>
#include <osbind.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "extern.h"


short et4000_driver_ids[NUM_ET4000];
short nvdipc_driver_ids[NUM_NVDIPC];


static const char *const et4000_driver_names[NUM_ET4000] = {
	"XVGA2.SYS",
	"XVGA16.SYS",
	"XVGA256.SYS",
	"XVGA32K.SYS",
	"XVGA65K.SYS",
	"XVGA16M.SYS"
};

static const char *const nvdipc_driver_names[NUM_NVDIPC] = {
	"NFPC256.SYS",
	"NFPC32K.SYS",
	"NFPC65K.SYS",
	"NFPC16M.SYS"
};


char *load_file(const char *filename, long *size)
{
	char *buf;
	short fd;
	long length;

	buf = NULL;
	*size = 0;
	fd = (short)Fopen(filename, FO_READ);
	if (fd > 0)
	{
		length = Fseek(0, fd, SEEK_END);
		Fseek(0, fd, SEEK_SET);
		buf = (char *)Malloc(length);
		if (buf != NULL)
		{
			*size = Fread(fd, length, buf);
			if (*size != length)
			{
				Mfree(buf);
				buf = NULL;
			}
		}
		Fclose(fd);
	}
	return buf;
}


static char *skip_white(char *s)
{
	while (*s == ' ' || *s == '\t')
		s++;
	return s;
}


static char *find_str(char *line, const char *str, char **end)
{
	char *p;
	char *start;
	
	start = skip_white(line);
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


int change_magx_inf(WORD rez, WORD vmode)
{
	WORD ret;
	char *buf;
	long size;
	char *p;
	char linebuf[40];
	long linesize;
	long remain;
	short fd;
	
	ret = FALSE;
	buf = load_file("\\MAGX.INF", &size);
	if (buf != NULL)
	{
		p = find_line(buf, "#_DEV", size, &remain, &linesize);
		if (remain == 0)
		{
			p = find_line(buf, "#[aes]", size, &remain, &linesize);
			p += linesize;
			linesize = 0;
		}
		fd = (short)Fcreate("\\MAGX.INF", 0);
		if (fd > 0)
		{
			if (remain > 0)
			{
				Fwrite(fd, p - buf, buf);
				p += linesize;
			} else
			{
				p = buf;
			}
			sprintf(linebuf, "#_DEV %d %d\r\n", rez, vmode);
			Fwrite(fd, strlen(linebuf), linebuf);
			Fwrite(fd, size - (p - buf), p);
			Fclose(fd);
			ret = TRUE;
		}
		Mfree(buf);
	}
	return ret;
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
		if (magicpc)
		{
			for (i = 0; i < NUM_NVDIPC; i++)
			{
				get_driver_id(buf, nvdipc_driver_names[i], &nvdipc_driver_ids[i]);
			}
		} else
		{
			for (i = 0; i < NUM_ET4000; i++)
			{
				get_driver_id(buf, et4000_driver_names[i], &et4000_driver_ids[i]);
			}
		}
		p += linesize;
	} while (size > 0 && linesize > 0);
	Mfree(assign);
}
