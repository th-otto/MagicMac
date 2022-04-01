#include "vt52.h"

long bios PROTO((short opcode, ...));

#define Bconin(dev) bios(2, dev)
#define Bconout(dev, c) bios(3, dev, c)

#define conout(c) Bconout(2, c)
#define rawconout(c) Bconout(5, c)

#ifdef __ALCYON__
#  define EXTERN extern
#else
#  define EXTERN static
#endif
EXTERN char strbuf[162];
EXTERN int cont_parse;
EXTERN int vt52_err;
EXTERN char *args;
EXTERN const char *strstart;
EXTERN const char *strend;
static char const wrong_format[] = "falsches Format";
static char const wrong_extension[] = "falsches Formatextension";
static char const miss_paren[] = "fehlende Klammer";
static char const miss_delim[] = "fehlender Stringdelimiter";
static char const wrong_rep_count[] = "falscher Rep.count";
static char const wrong_command[] = "falsche vt52-Anweisung";
static int inplen = -1;
static int doprompt = 0;


static VOID doprt PROTO((const char *start, const char *end));
static VOID doinp PROTO((const char *start, const char *end));
static int prt_field PROTO((const char *start, const char *end));
static int parse_field PROTO((const char **start, const char **end, const char **, const char **, int *count));
static VOID printerr PROTO((NOTHING));
static VOID printstr PROTO((const char *str));
static VOID rawprint PROTO((NOTHING));
static VOID prt_str PROTO((NOTHING));
static VOID prt_int PROTO((NOTHING));
static VOID prt_long PROTO((NOTHING));
static VOID prt_fixed PROTO((NOTHING));
static VOID prt_float PROTO((NOTHING));
static VOID vt52_seq PROTO((NOTHING));
static int streq PROTO((const char *str1, const char *str2));
static VOID flush_strbuf PROTO((NOTHING));
static int prt_hex PROTO((const char *str, int len, int width));
static VOID prt_bin PROTO((const char *str, int len, int width));
static int inp_field PROTO((const char *start, const char *end));
static VOID inp_str PROTO((NOTHING));
static VOID inp_int PROTO((NOTHING));
static VOID inp_long PROTO((NOTHING));
static VOID inp_float PROTO((NOTHING));
static int readstr PROTO((char *str, int maxlen));
static VOID inp_item PROTO((int *));



int vt52_printf(P(const char *) format)
PP(const char *format;)
{
	register const char *start;
	register const char *end;
	
	cont_parse = 1;
	vt52_err = 0;
	args = (char *)(&format);
	args += sizeof(format);
	start = format;
	end = start;
	while (*end != '\0')
		end++;
	doprt(start, end);
	if (vt52_err != 0)
		printerr();
	return vt52_err;
}


static VOID doprt(P(const char *) start, P(const char *) end)
PP(const char *start;)
PP(const char *end;)
{
	const char *substart;
	const char *subend;
	int err;
	int count;

	while ((long)start < (long)end && cont_parse != 0) /* FIXME: cast */
	{
		err = parse_field(&start, &end, &substart, &subend, &count);
		if (err < 0)
		{
			cont_parse = 0;
			vt52_err = err;
		} else
		{
			if ((long)substart < (long)subend) /* FIXME: cast */
			{
				if (err > 0)
				{
					while (count-- != 0 && cont_parse != 0)
						doprt(substart, subend);
				} else
				{
					while (count-- != 0 && cont_parse != 0)
						prt_field(substart, subend);
				}
			}
		}
	}
}


int vt52_scanf(P(const char *) format)
PP(const char *format;)
{
	register const char *start;
	register const char *end;
	
	cont_parse = 1;
	vt52_err = 0;
	inplen = -1;
	args = (char *)(&format);
	args += sizeof(format);
	start = format;
	end = start;
	while (*end != '\0')
		end++;
	doinp(start, end);
	if (vt52_err != 0)
		printerr();
	return vt52_err;
}


static VOID doinp(P(const char *) start, P(const char *) end)
PP(const char *start;)
PP(const char *end;)
{
	const char *substart;
	const char *subend;
	int err;
	int count;

	while ((long)start < (long)end && cont_parse != 0) /* FIXME: cast */
	{
		err = parse_field(&start, &end, &substart, &subend, &count);
		if (err < 0)
		{
			cont_parse = 0;
			vt52_err = err;
		} else
		{
			if ((long)substart < (long)subend) /* FIXME: cast */
			{
				if (err > 0)
				{
					while (count-- != 0 && cont_parse != 0)
						doinp(substart, subend);
				} else
				{
					while (count-- != 0 && cont_parse != 0)
						inp_field(substart, subend);
				}
			}
		}
	}
}


static int parse_field(P(const char **)start, P(const char **)end, P(const char **)substart, P(const char **)subend, P(int *)count)
PP(const char **start;)
PP(const char **end;)
PP(const char **substart;)
PP(const char **subend;)
PP(int *count;)
{
	int val;
	register const char *first;
	register const char *last;
	register int c;
	register int level;
	int endfound;
	int delim;
	
	val = 1;
	first = *start;
	last = *end;
	do
	{
		do
		{
			c = *--last;
		} while (c == ' ');
	} while (c == ',');
	last++;
	*end = last;
	while ((c = *first) == ' ' || c == ',')
		++first;
	if (first < last)
	{
		if (c >= '0' && c <= '9')
		{
			val = 0;
			while ((c = *first) >= '0' && c <= '9')
			{
				first++;
				val = val * 10 + c - '0';
			}
			while (c == ' ')
				c = *++first;
			if (c == ',')
				return -5;
			if (first >= last)
				return -5;
		}
		*count = val;
		if (c == '(')
		{
			first++;
			level = 1;
			endfound = 1;
			*substart = first;
			while (level != 0 && first < last)
			{
				c = *first++;
				if (endfound != 0)
				{
					if (c == '\'' || c == '`')
					{
						endfound = 0;
						delim = c;
					} else
					{
						if (c == '(')
							level++;
						else if (c == ')')
							level--;
					}
				} else
				{
					endfound = c != delim ? 0 : 1;
				}
			}
			if (endfound == 0)
				return -4;
			if (level != 0)
				return -3;
			*start = first;
			first--;
			*subend = first;
			return 1;
		} else
		{
			*substart = first;
			endfound = c == '\'' || c == '`' ? 0 : 1;
			if (endfound)
			{
				while (c != ',' && c != '\'' && c != '`' && first < last)
					c = *++first;
			} else
			{
				delim = c;
				first++;
				c = 0;
				do
				{
					if (first >= last)
						break;
					c = *first++;
				} while (c != delim);
				if (c != delim)
					return -4;
			}
			*subend = first;
			*start = first;
			return 0;
		}
	}
	*start = *end;
	*substart = *subend = *end;
	*count = 0;
	return 0;
}


static int prt_field(P(const char *) start, P(const char *) end)
PP(const char *start;)
PP(const char *end;)
{
	register char c;
	
	if (start >= end)
		return -1;
	strstart = start;
	strend = end;
	c = *start;
	switch (c)
	{
	case '/':
		conout(13);
		conout(10);
		break;
	case '\'':
	case '`':
		rawprint();
		break;
	case '?':
		doprompt = 1;
		break;
	case '!':
		doprompt = 0;
		break;
	case 's':
		prt_str();
		break;
	case 'l':
		prt_long();
		break;
	case 'i':
		prt_int();
		break;
	case 'f':
		prt_fixed();
		break;
	case 'e':
		prt_float();
		break;
	case 'v':
		vt52_seq();
		break;
	default:
		cont_parse = 0;
		vt52_err = -1;
		break;
	}
#ifndef __ALCYON__
	return 0;
#endif
}


static int parse_prec(P(int *) pwidth, P(int *) pprec)
PP(int *pwidth;)
PP(int *pprec;)
{
	register const char *start;
	register const char *end;
	register int width;
	register int prec;
	register int digit;
	
	start = strstart + 1;
	end = strend - 1;
	width = prec = -1;
	while (*start == ' ')
		start++;
	while (*end == ' ')
		end--;
	if (start > end)
		goto retit;
	width = 0;
	while (start <= end && (digit = *start - '0') >= 0 && digit < 10)
	{
		width = width * 10 + digit;
		start++;
	}
	if (start > end)
		goto retit;
	if (*start++ == '.' && start <= end)
	{
		prec = 0;
		while (start <= end && (digit = *start - '0') >= 0 && digit < 10)
		{
			prec = prec * 10 + digit;
			start++;
		}
		if (start > end)
		{
		retit:
			*pwidth = width;
			*pprec = prec;
			return 0;
		}
	}
	cont_parse = 0;
	vt52_err = -2;
	return -1;
}


static VOID rawprint(NOTHING)
{
	register const char *start;
	register const char *end;
	
	start = strstart + 1;
	end = strend - 1;
	
	while (start < end)
	{
		rawconout(*start++);
	}
}


static VOID prt_str(NOTHING)
{
	register const char *str;
	register const char *start;
#ifdef __ALCYON__
	register char *unused;
#endif
	int width;
	int prec;
	char **pstr;
	register int len;
	
	pstr = (char **)args;
	args += sizeof(char *);
	str = *pstr;
	start = strstart + 1;
	if (start < strend && (*start == 'h' || *start == 'b'))
		strstart++;
	parse_prec(&width, &prec);
	if (cont_parse != 0)
	{
		for (len = 0; str[len]; len++)
			;
		if (*start == 'h')
		{
			prt_hex(str, len, width);
		} else if (*start == 'b')
		{
			prt_bin(str, len, width);
		} else
		{
			while (len < width)
			{
				width--;
				conout(' ');
			}
			if (width >= 0 && width < len)
				len = width;
			while (len-- > 0)
				conout(*str++);
		}
	}
}


static VOID prt_int(NOTHING)
{
	register int *pint;
	register const char *start;
	int width;
	int prec;
	
	pint = (int *)args;
	args += sizeof(int);
	start = strstart + 1;
	if (start < strend && (*start == 'h' || *start == 'b'))
		strstart++;
	parse_prec(&width, &prec);
	if (cont_parse != 0)
	{
		if (*start == 'h')
		{
			prt_hex((char *)pint, (int)sizeof(int), width);
		} else if (*start == 'b')
		{
			prt_bin((char *)pint, (int)sizeof(int), width);
		} else
		{
			fmt_int(*pint, width, strbuf);
			flush_strbuf();
		}
	}
}


static VOID prt_long(NOTHING)
{
	register long *plong;
	register const char *start;
	int width;
	int prec;
	
	plong = (long *)args;
	args += sizeof(long);
	start = strstart + 1;
	if (start < strend && (*start == 'h' || *start == 'b'))
		strstart++;
	parse_prec(&width, &prec);
	if (cont_parse != 0)
	{
		if (*start == 'h')
		{
			prt_hex((char *)plong, (int)sizeof(long), width);
		} else if (*start == 'b')
		{
			prt_bin((char *)plong, (int)sizeof(long), width);
		} else
		{
			fmt_long(*plong, width, strbuf);
			flush_strbuf();
		}
	}
}


static VOID prt_fixed(NOTHING)
{
	register FLOAT *pfloat;
	int width;
	int prec;
	
	pfloat = (FLOAT *)args;
	args += sizeof(long);
	parse_prec(&width, &prec);
	if (cont_parse != 0)
	{
		fmt_fixed(*pfloat, width, prec, strbuf);
		flush_strbuf();
	}
}


VOID prt_float(NOTHING)
{
	register FLOAT *pfloat;
	int width;
	int prec;
	
	pfloat = (FLOAT *)args;
	args += sizeof(long);
	parse_prec(&width, &prec);
	if (cont_parse != 0)
	{
		fmt_float(*pfloat, width, prec, strbuf);
		flush_strbuf();
	}
}


static VOID vt52_seq(NOTHING)
{
	register char *argptr;
	register int arg1;
	register int arg2;

	strstart++;
	if (streq("cuup", strstart))
	{
		conout(27);
		conout('A');
	} else if (streq("cudown", strstart))
	{
		conout(27);
		conout('B');
	} else if (streq("curight", strstart))
	{
		conout(27);
		conout('C');
	} else if (streq("culeft", strstart))
	{
		conout(27);
		conout('D');
	} else if (streq("clhome", strstart))
	{
		conout(27);
		conout('E');
	} else if (streq("cuhome", strstart))
	{
		conout(27);
		conout('H');
	} else if (streq("cuupin", strstart))
	{
		conout(27);
		conout('I');
	} else if (streq("cldown", strstart))
	{
		conout(27);
		conout('J');
	} else if (streq("clliner", strstart))
	{
		conout(27);
		conout('K');
	} else if (streq("insline", strstart))
	{
		conout(27);
		conout('L');
	} else if (streq("delline", strstart))
	{
		conout(27);
		conout('M');
	} else if (streq("cupos", strstart))
	{
		argptr = args;
		args += sizeof(int);
		arg1 = *((int *)argptr);
		argptr = args;
		args += sizeof(int);
		arg2 = *((int *)argptr);
		conout(27);
		conout('Y');
		conout(arg2 + 32);
		conout(arg1 + 32);
	} else if (streq("white", strstart))
	{
		conout(27);
		conout('b');
		conout(1);
		conout(27);
		conout('c');
		conout(0);
	} else if (streq("black", strstart))
	{
		conout(27);
		conout('b');
		conout(0);
		conout(27);
		conout('c');
		conout(1);
	} else if (streq("clup", strstart))
	{
		conout(27);
		conout('d');
	} else if (streq("cuon", strstart))
	{
		conout(27);
		conout('e');
	} else if (streq("cuoff", strstart))
	{
		conout(27);
		conout('f');
	} else if (streq("cusave", strstart))
	{
		conout(27);
		conout('j');
	} else if (streq("curest", strstart))
	{
		conout(27);
		conout('k');
	} else if (streq("clline", strstart))
	{
		conout(27);
		conout('l');
	} else if (streq("cllinel", strstart))
	{
		conout(27);
		conout('o');
	} else if (streq("revon", strstart))
	{
		conout(27);
		conout('p');
	} else if (streq("revoff", strstart))
	{
		conout(27);
		conout('q');
	} else if (streq("autoon", strstart))
	{
		conout(27);
		conout('v');
	} else if (streq("autooff", strstart))
	{
		conout(27);
		conout('w');
	} else
	{
		cont_parse = 0;
		vt52_err = -6;
	}
}


static int streq(P(const char *) str1, P(const char *) str2)
PP(register const char *str1;)
PP(register const char *str2;)
{
	register int eq;
	
	eq = 1;
	while (eq && *str1)
	{
		eq = *str1++ != *str2++ ? 0 : 1;
	}
	return eq;
}


static VOID flush_strbuf(NOTHING)
{
	register char *str;
	register int c;
	
	str = strbuf;
	while ((c = *str++))
	{
		rawconout(c);
	}
}


static int prt_hex(P(const char *) str, P(int) len, P(int) width)
PP(const char *str;)
PP(int len;)
PP(int width;)
{
	register const char *p;
	register int plen;
	register int byte;
	register int c;
	register int numspaces;
	register int needspace;
	
	if (len > 0)
	{
		p = str;
		plen = len << 1;
		if (width <= 0)
		{
			numspaces = needspace = 0;
		} else
		{
			numspaces = plen - width;
			needspace = 1;
		}
		while (plen < width)
		{
			width--;
			conout(' ');
		}
#ifdef __GNUC__
		byte = 0;
#endif
		while (plen-- != 0)
		{
			if (plen & 1)
			{
				byte = *p++;
				c = (byte >> 4) & 0x0f;
			} else
			{
				c = byte & 0x0f;
			}
			if (c != 0 && numspaces > 0)
				goto toolarge;
			if (numspaces-- <= 0)
			{
				needspace = needspace == 0 || c != 0 ? 0 : 1;
				c = c > 9 ? c + ('A' - 10) : c + '0';
				if (needspace && plen)
					conout(' ');
				else
					conout(c);
			}
		}
		return 0;
	toolarge:
		while (width-- > 0)
		{
			conout('*');
		}
		return -1;
	}
#ifndef __ALCYON__
	return -1;
#endif
}


static VOID prt_bin(P(const char *) str, P(int) len, P(int) width)
PP(const char *str;)
PP(int len;)
PP(int width;)
{
	register const char *p;
	register int c;
	register int mask;
	
	if (len > 0)
	{
		p = str;
		while (len-- != 0)
		{
			c = *p++;
			mask = 0x80;
			while (mask != 0)
			{
				if (c & mask)
					conout('I');
				else
					conout('0');
				mask >>= 1;
			}
		}
	}
}


static int inp_field(P(const char *) start, P(const char *) end)
PP(const char *start;)
PP(const char *end;)
{
	register char c;
	
	if (start >= end)
		return -1;
	strstart = start;
	strend = end;
	c = *start;
	switch (c)
	{
	case '/':
		conout(13);
		conout(10);
		break;
	case '\'':
	case '`':
		rawprint();
		break;
	case '?':
		doprompt = 1;
		break;
	case '!':
		doprompt = 0;
		break;
	case 's':
		inp_str();
		break;
	case 'l':
		inp_long();
		break;
	case 'i':
		inp_int();
		break;
	case 'f':
	case 'e':
		inp_float();
		break;
	case 'v':
		vt52_seq();
		break;
	default:
		cont_parse = 0;
		vt52_err = -1;
		break;
	}
#ifndef __ALCYON__
	return 0;
#endif
}


static VOID inp_str(NOTHING)
{
	register char **pstr;
	register char *str;
	int width;
	int prec;
	
	pstr = (char **)args;
	args += sizeof(char *);
	str = *pstr;
	parse_prec(&width, &prec);
	if (width < 0)
		width = 1;
	readstr(str, width);
	inplen = -1;
}


static VOID inp_int(NOTHING)
{
	int start;
	register int **pint;
	
	pint = (int **)args;
	args += sizeof(int *);
	
	for (;;)
	{
		inp_item(&start);
		if (atoint(&strbuf[start], *pint) >= 0)
			break;
		conout(13);
		conout(10);
		printstr(" falsche Integer-Eingabe. ");
		inplen = -1;
	}
}


static VOID inp_long(NOTHING)
{
	int start;
	register long **plong;
	
	plong = (long **)args;
	args += sizeof(long *);
	
	for (;;)
	{
		inp_item(&start);
		if (atolong(&strbuf[start], *plong) >= 0)
			break;
		conout(13);
		conout(10);
		printstr(" falsche Long-Eingabe. ");
		inplen = -1;
	}
}


static VOID inp_float(NOTHING)
{
	int start;
	register FLOAT **pfloat;
	
	pfloat = (FLOAT **)args;
	args += sizeof(FLOAT *);
	
	for (;;)
	{
		inp_item(&start);
		if (atofloat(&strbuf[start], *pfloat) >= 0)
			break;
		conout(13);
		conout(10);
		printstr(" falsche Float-Eingabe. ");
		inplen = -1;
	}
}


static VOID inp_item(P(int *) start)
PP(int *start;)
{
	register int c;
	
	do
	{
		if (inplen >= 0)
		{
			if (!strbuf[inplen])
				inplen = 0;
			if (inplen == 0)
			{
				conout(13);
				conout(10);
			}
		}
		if (inplen <= 0)
		{
			readstr(strbuf, (int)sizeof(strbuf) - 2);
			inplen = 0;
		}
		while ((c = strbuf[inplen]) == ' ')
			inplen++;
	} while (c == 0);
	*start = inplen;
	while ((c = strbuf[inplen]) && c != ',')
		inplen++;
	if (c != '\0')
	{
		strbuf[inplen] = '\0';
		inplen++;
	} else
	{
		inplen = 0;
	}
}


static int readstr(P(char *)str, P(int) maxlen)
PP(register char *str;)
PP(int maxlen;)
{
	register int c;
	register int len;
	
	len = 0;
	if (doprompt)
	{
		conout('?');
	}
	while ((c = (int)Bconin(2)) != 13)
	{
		if (c == 8) /* Backspace */
		{
			if (len > 0)
			{
				len--;
				conout(27);
				conout('D');
				conout(' ');
				conout(27);
				conout('D');
			}
		} else
		{
			if (len < maxlen)
			{
				str[len] = c;
				len++;
				rawconout(c);
			}
		}
	}
	str[len] = '\0';
	return len;
}


static VOID printerr(NOTHING)
{
	register const char *str;
	
	switch (vt52_err)
	{
	case -1:
		str = wrong_format;
		break;
	case -2:
		str = wrong_extension;
		break;
	case -3:
		str = miss_paren;
		break;
	case -4:
		str = miss_delim;
		break;
	case -5:
		str = wrong_rep_count;
		break;
	case -6:
		str = wrong_command;
		break;
	default:
		return;
	}
	printstr("*** ");
	printstr(str);
	printstr(". ***");
	conout(13);
	conout(10);
}


static VOID printstr(P(const char *)str)
PP(const char *str;)
{
	while (*str != '\0')
	{
		conout(*str);
		str++;
	}
}
