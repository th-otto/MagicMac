/*
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 *
 *
 * Copyright 2003 Konrad M. Kokoszkiewicz <draco@atari.org>
 * All rights reserved.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *
 * begin:	2003-02-25
 * last change:	2000-02-25
 *
 * Author:	Konrad M. Kokoszkiewicz <draco@atari.org>
 *          Thorsten Otto <admin@tho-otto.de>
 *
 * Please send suggestions, patches or bug reports to me or
 * the MiNT mailing list.
 *
 */

/* Make a keyboard translation table out of the given source file.
 *
 * The source file must consist of text lines. A text line must either
 * begin with a semicolon (;), or contain one of two directives:
 *
 * dc.b	- begins a sequence of bytes
 * dc.w - begins a sequence of words
 *
 * The data may be given as hex numbers (in either asm or C syntax),
 * dec numbers or ASCII characters. A hex number begins with $ or 0x,
 * (e.g. $2735 or 0x2735), an ASCII character is quoted (e.g. 'a'),
 * and a dec number has no prefix (e.g. 1 or 48736 is fine).
 *
 * If a number exceeds the desired limit, e.g. when you do
 *
 * dc.b 100000
 *
 * Only the lowest eight (or sixteen in case of dc.w) of such a
 * number will be taken into account, and a warning message is
 * printed.
 *
 * The data may be separated with commas or semicolons.
 *
 * Examples:
 *
 * ; This is a comment
 *
 *	dc.b 'a',$00,0x55,76
 *	dc.w $2334,4,0x12,'d'
 *
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>


#define TAB_UNSHIFT   0
#define TAB_SHIFT     1
#define TAB_CAPS      2
#define TAB_ALTGR     3
#define TAB_SHALTGR   4
#define TAB_CAPSALTGR 5
#define TAB_ALT       6
#define TAB_SHALT     7
#define TAB_CAPSALT   8
#define N_KEYTBL      9
#define TAB_DEADKEYS  N_KEYTBL

static unsigned char keytab[N_KEYTBL][128];
#define MAX_DEADKEYS 2048
static unsigned char deadkeys[MAX_DEADKEYS];
static int tabsize[N_KEYTBL + 1];
static int copyfrom[N_KEYTBL];

static const char *const labels[N_KEYTBL + 1] = {
	"tab_unshift:",
	"tab_shift:",
	"tab_caps:",
	"tab_altgr:",
	"tab_shaltgr:",
	"tab_capsaltgr:",
	"tab_alt:",
	"tab_shalt:",
	"tab_capsalt:",
	"tab_dead:"
};


/* Own getdelim(). The `n' buffer size must definitely be bigger than 0!
 */
static int mktbl_getdelim(char **lineptr, size_t *n, FILE *stream)
{
	int ch;
	char *buf = *lineptr;
	size_t len = 0;

	while ((ch = fgetc(stream)) != EOF)
	{
		if ((len + 1) >= *n)
		{
			buf = realloc(buf, len + 256L);
			*n += 256L;
			*lineptr = buf;
		}

		if (ch == 0x0a)
			break;
		if (ch == 0x0d)
		{
			ch = fgetc(stream);
			if (ch != 0x0a && ch != EOF)
				ungetc(ch, stream);
			break;
		}
		buf[len++] = (char) ch;
	}

	buf[len] = 0;

	/* A problem here: returning -1 on EOF may cause data loss
	 * if there is no terminator character at the end of the file
	 * (in this case all the previously read characters of the
	 * line are discarded). At the other hand returning 0 at
	 * first EOF and -1 at the other creates an additional false
	 * empty line, if there *was* terminator character at the
	 * end of the file. So the check must be more extensive
	 * to behave correctly.
	 */
	if (ch == EOF)
	{
		if (len == 0)					/* Nothing read before EOF in this line */
			return -1;
		/* Pretend success otherwise */
	}

	return 0;
}


int main(int argc, char **argv)
{
	char *line;
	char *ln;
	char *outname;
	char *o;
	int r;
	long lineno;
	long num;
	long flen;
	short w;
	size_t buf;
	FILE *fd;
	FILE *out;
	int tab, newtab;
	int loop;
	const char *filename;
	
	if (argc <= 2)
	{
		if (argc < 2 || (argc >= 2 && (strcmp(argv[1], "--help") == 0)))
		{
			printf("Usage: %s src-file [tbl-file]\n", argv[0]);

			return 1;
		}

		filename = argv[1];
		flen = strlen(filename);
		outname = malloc(flen + 5);
		if (!outname)
		{
			fprintf(stderr, "Out of RAM\n");
			return 1;
		}
		strcpy(outname, argv[1]);
		o = strrchr(outname, '.');
		if (o == NULL)
			strcat(outname, ".sys");
		else
			strcpy(o, ".sys");

		printf("%s: output to %s\n", argv[1], outname);
	} else
	{
		filename = argv[1];
		outname = argv[2];
	}
	
	buf = 1024;
	line = malloc(buf);					/* should be plenty */
	if (!line)
		return 2;

	fd = fopen(filename, "r");
	if (!fd)
		return 3;

	out = fopen(outname, "wb");
	if (!fd)
		return 4;

	for (tab = 0; tab < N_KEYTBL; tab++)
		copyfrom[tab] = -1;
	lineno = 0;
	tab = -1;
	w = 0;
	
	for (;;)
	{
		lineno++;

		r = mktbl_getdelim(&line, &buf, fd);
		if (r < 0)
			break;
		ln = line;
		while (*ln == ' ' || *ln == '\t')
			ln++;
		if (ln[0] == ';' || ln[0] == '\0')
			continue;
		newtab = -1;
		if (strncmp(ln, "dc.b", 4) == 0)
		{
			w = 0;
		} else if (strncmp(ln, "dc.w", 4) == 0)
		{
			w = 1;
		} else if (strcmp(ln, labels[TAB_SHIFT]) == 0)
		{
			newtab = TAB_SHIFT;
		} else if (strcmp(ln, labels[TAB_UNSHIFT]) == 0)
		{
			newtab = TAB_UNSHIFT;
		} else if (strcmp(ln, labels[TAB_CAPS]) == 0)
		{
			newtab = TAB_CAPS;
		} else if (strcmp(ln, labels[TAB_ALTGR]) == 0)
		{
			newtab = TAB_ALTGR;
		} else if (strcmp(ln, labels[TAB_SHALTGR]) == 0)
		{
			newtab = TAB_SHALTGR;
		} else if (strcmp(ln, labels[TAB_CAPSALTGR]) == 0)
		{
			newtab = TAB_CAPSALTGR;
		} else if (strcmp(ln, labels[TAB_ALT]) == 0)
		{
			newtab = TAB_ALT;
		} else if (strcmp(ln, labels[TAB_ALT]) == 0)
		{
			newtab = TAB_ALT;
		} else if (strcmp(ln, labels[TAB_SHALT]) == 0)
		{
			newtab = TAB_SHALT;
		} else if (strcmp(ln, labels[TAB_CAPSALT]) == 0)
		{
			newtab = TAB_CAPSALT;
		} else if (strcmp(ln, labels[TAB_DEADKEYS]) == 0)
		{
			newtab = TAB_DEADKEYS;
		} else if (strncmp(ln, "IFNE", 4) == 0)
		{
			continue;
		} else if (strncmp(ln, "ENDC", 4) == 0)
		{
			continue;
		} else
		{
			fprintf(stderr, "%s: warning, unknown statement in line %ld: %s\n", filename, lineno, line);
			continue;
		}
		
		if (newtab >= 0)
		{
			if (tab >= 0 && tab < N_KEYTBL && tabsize[tab] == 0)
				copyfrom[tab] = newtab;
			tab = newtab;
			continue;
		}
		
		ln += 4;
		while (*ln == ' ' || *ln == '\t')
			ln++;

		while (*ln)
		{
			if (ln[0] == ';')
				break;
			
			if (ln[0] == '\'')
			{
				if (ln[2] != '\'')
				{
					fprintf(stderr, "%s: error, unmatched quotes in line %ld: %s\n", filename, lineno, line);
					r = 5;
					goto error;
				}
				num = (unsigned char)ln[1];
				ln += 3;
			} else if (ln[0] == '$')
			{
				if (!isxdigit(ln[1]))
				{
					fprintf(stderr, "%s: error, '%c' is not a hex number in line %ld: %s\n", filename, ln[1], lineno, line);
					r = 6;
					goto error;
				}

				ln++;
				num = strtoul(ln, &ln, 16);
			} else if (ln[0] == '0' && ln[1] == 'x')
			{
				if (!isxdigit(ln[3]))
				{
					fprintf(stderr, "%s: error, '%c' is not a hex number in line %ld: %s\n", filename, ln[3], lineno, line);
					r = 7;
					goto error;
				}

				ln += 2;
				num = strtoul(ln, &ln, 16);
			} else if (isdigit(ln[0]))
			{
				num = strtoul(ln, &ln, 10);
			} else if (strncmp(ln, "XXX", 3) == 0)
			{
				num = 0;
				ln += 3;
			} else if (strncmp(ln, "YYY", 3) == 0)
			{
				num = 0;
				ln += 3;
			} else if (strncmp(ln, "U2B", 3) == 0)
			{
				num = 0x7e;
				ln += 3;
			} else if (strncmp(ln, "S2B", 3) == 0)
			{
				num = 0x7c;
				ln += 3;
			} else if (strncmp(ln, "S29", 3) == 0)
			{
				num = 0x5e;
				ln += 3;
			} else
			{
				fprintf(stderr, "%s: error, unexpected '%c' in line %ld: %s\n", filename, ln[0], lineno, line);
				r = 8;
				goto error;
			}

			if (w)
			{
				/*
				 * dc.w only used for MiNT to specify magics at filestart
				 */
				if (num > 65535L)
					fprintf(stderr, "%s: warning, number %ld in line %ld is too big\n", filename, num, lineno);
				if (tab >= 0)
				{
					fprintf(stderr, "%s: error, too late for magics in line %ld: %s\n", filename, lineno, line);
					r = 1;
					goto error;
				}
				fputc((int)(num >> 8), out);
				fputc((int)(num & 0xff), out);
			} else
			{
				if (num > 255)
					fprintf(stderr, "%s: warning, number %ld in line %ld is too big\n", filename, num, lineno);
				if (tab < 0)
				{
					fprintf(stderr, "%s: error, no table in line %ld: %s\n", filename, lineno, line);
					r = 1;
					goto error;
				}
				if (tab == TAB_DEADKEYS)
				{
					if (tabsize[tab] >= MAX_DEADKEYS)
					{
						fprintf(stderr, "%s: error, too many dead keys in line %ld: %s\n", filename, lineno, line);
						r = 1;
						goto error;
					}
					deadkeys[tabsize[tab]] = num;
				} else
				{
					if (tabsize[tab] >= 128)
					{
						fprintf(stderr, "%s: error, too many keys in line %ld: %s\n", filename, lineno, line);
						r = 1;
						goto error;
					}
					keytab[tab][tabsize[tab]] = num;
				}
				tabsize[tab]++;
			}

			while (*ln == ' ' || *ln == '\t')
				ln++;
			if (ln[0] == ',')
			{
				ln++;
				while (*ln == ' ' || *ln == '\t')
					ln++;
			}
		}
	}

	r = 0;

	for (loop = 0; loop < N_KEYTBL; loop++)
	{
		for (tab = 0; tab < N_KEYTBL; tab++)
		{
			if (copyfrom[tab] >= 0 && tabsize[copyfrom[tab]] > 0)
			{
				memcpy(keytab[tab], keytab[copyfrom[tab]], 128);
				tabsize[tab] = tabsize[copyfrom[tab]];
			}
		}
	}
	for (tab = 0; tab < N_KEYTBL; tab++)
	{
		if (tabsize[tab] == 0)
			fprintf(stderr, "%s: warning, missing table for %s\n", filename, labels[tab]);
		else if (tabsize[tab] != 128)
			fprintf(stderr, "%s: warning, incomplete table for %s\n", filename, labels[tab]);
	}
	if (tabsize[TAB_DEADKEYS] == 0)
		tabsize[TAB_DEADKEYS] = 2;
	for (tab = 0; tab < N_KEYTBL; tab++)
		if (fwrite(keytab[tab], 128, 1, out) != 1)
			;
	if (fwrite(deadkeys, tabsize[TAB_DEADKEYS], 1, out) != 1)
		;

  error:
	fclose(fd);
	fclose(out);

	if (r)
		unlink(outname);

	return r;
}
