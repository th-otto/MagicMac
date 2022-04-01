#include "vt52.h"


#ifdef __ALCYON__
#  define EXTERN extern
#else
#  define EXTERN static
#endif
EXTERN char tmpbuf[82];
#ifndef __ALCYON__
int errno;
#endif


static VOID copytmp PROTO((char *buf, int len, int width));


#ifdef __ALCYON__
asm("dc.w 0x23f9");
asm("dc.b 'cio2.o',0,0");
#endif


int fmt_int(P(int) val, P(int) width, P(char *)buf)
PP(int val;)
PP(int width;)
PP(char *buf;)
{
	return fmt_long((long)val, width, buf);
}


int fmt_long(P(long) val, P(int) width, P(char *)buf)
PP(register long val;)
PP(int width;)
PP(char *buf;)
{
	register int len = 0;
	register int sign;
	register char *p;
	
	if ((sign = val >= 0 ? 0 : 1))
		val = -val;
	p = &tmpbuf[sizeof(tmpbuf) - 1];
	do
	{
		*--p = (val % 10) + '0';
		val = val / 10;
		len++;
	} while (val != 0);
	if (sign)
	{
		len++;
		*--p = '-';
	}
	if (width < 0)
		width = len;
	if (width > 80)
		width = 80;
	copytmp(buf, len, width);
	return len;
}


int fmt_fixed(P(FLOAT) val, P(int) width, P(int) prec, P(char *)buf)
PP(FLOAT val;)
PP(int width;)
PP(int prec;)
PP(register char *buf;)
{
	register int ie;
	register int d6;
	register int len;
	float pow;
	int sign;
	int dig;
	
	sign = val >= 0 ? 0 : 1;
	if (prec < 0)
		prec = 2;
	if (sign)
		val = -val;
	pow = 10;
	ie = 1;
	while (pow <= val && ie < 100)
	{
		pow = pow * 10.0;
		ie++;
	}
	len = ie + prec + sign + 1;
	if (width < 0)
		width = len;
	d6 = width - len;
	if (d6 >= 0)
	{
		while (d6-- != 0)
			*buf++ = ' ';
		if (sign)
			*buf++ = '-';
		while (ie-- != 0)
		{
			pow = pow / 10.0;
			dig = (int)(val / pow);
			*buf++ = dig + '0';
			val = val - dig * pow;
		}
		*buf++ = '.';
		while (prec-- != 0)
		{
			dig = (int)(val = val * 10.0);
			*buf++ = dig + '0';
			val = val - dig;
		}
		*buf++ = '\0';
		return len;
	}
	while (width-- > 0)
	{
		*buf++ = '*';
	}
	*buf++ = '\0';
	return -1;
}


int fmt_float(P(FLOAT) val, P(int) width, P(int) prec, P(char *)buf)
PP(FLOAT val;)
PP(int width;)
PP(int prec;)
PP(char *buf;)
{
	register int sign;
	register int exp = 0;
	register int d5;
	int w;
	float pow;
	register char *p;

	if (width < 0)
		width = 1;
	if (prec < 0)
		prec = 0;
	pow = 1.0;
	d5 = width;
	while (d5-- != 0)
	{
		pow = pow * 10.0;
	}
	if ((sign = val >= 0 ? 0 : 1))
		val = -val;
	if (val != 0.0)
	{
		while (val < pow)
		{
			val = val * 10.0;
			exp--;
		}
		while (val > pow)
		{
			val = val * 0.1;
			exp++;
		}
	}
	w = width + prec + 2;
	fmt_fixed(val, w, prec, buf);
	if (sign)
		*buf = '-';
	else if (width == 0)
		*buf = ' ';
	p = buf + w;
	*p++ = 'e';
	if (exp < 0)
	{
		exp = -exp;
		*p++ = '-';
	} else
	{
		*p++ = '+';
	}
	*p++ = (exp / 10) + '0';
	*p++ = (exp % 10) + '0';
	*p++ = '\0';
	return w + 4;
}


static VOID copytmp(P(char *)buf, P(int) len, P(int) width)
PP(char *buf;)
PP(register int len;)
PP(int width;)
{
	register int diff;
	register char *p;
	register char *dst;
	
	diff = width - len;
	p = &tmpbuf[sizeof(tmpbuf) - 1];
	dst = buf + width;
	*dst = '\0';
	if (diff >= 0)
	{
		while (len-- > 0)
			*--dst = *--p;
		while (diff-- > 0)
			*--dst = ' ';
	} else
	{
		while (width-- > 0)
			*--dst = '*';
	}
}


int atolong(P(const char *) str, P(long *) pval)
PP(register const char *str;)
PP(long *pval;)
{
	register long val;
	register int c;
	register int sign;
	register int hex;
	register int bin;
	int digit;
	int hexdigit;
	int hexlowdigit;
	
	val = 0;
	while ((c = *str++) == ' ')
		;
	sign = c != '-' ? 0 : 1;
	hex = c != 'h' ? 0 : 1;
	bin = c != 'b' ? 0 : 1;
	if (hex || bin || sign || c == '+')
	{
		do
			c = *str++;
		while (c == ' ');
	}
	if (c == 0)
		return -1;
	if (bin)
	{
		while (c == '0' || c == '1')
		{
			val <<= 1;
			val |= c - '0';
			c = *str++;
		}
		if (c != ',' && c != ' ' && c != 0)
			return -2;
	} else if (hex)
	{
		while ((digit = c < '0' || c > '9' ? 0 : 1) ||
			   (hexdigit = c < 'A' || c > 'F' ? 0 : 1) ||
			   (hexlowdigit = c < 'a' || c > 'f' ? 0 : 1))
		{
			if (digit)
				c -= '0';
			else if (hexdigit)
				c -= 'A' - 10;
			else
				c -= 'a' - 10;
			val = (val << 4) + c;
			c = *str++;
		}
		if (c != ',' && c != ' ' && c != 0)
			return -2;
	} else
	{
		while (c >= '0' && c <= '9')
		{
			val = val * 10 + c - '0';
			c = *str++;
		}
		if (c != ',' && c != ' ' && c != 0)
			return -2;
		if (sign)
			val = -val;
	}
	*pval = val;
	return 1;
}


int atoint(P(const char *)str, P(int *) pval)
PP(char *str;)
PP(int *pval;)
{
	register int ret;
	long val;
	
	ret = atolong(str, &val);
	*pval = (int)val;
	return ret;
}


int atofloat(P(const char *) str, P(FLOAT *) pval)
PP(register char *str;)
PP(FLOAT *pval;)
{
	FLOAT val;
	int sign;
	int expsign;
	FLOAT mant;
	register int c;
	register int exp;
	
	val = 0.0;
	while ((c = *str++) == ' ')
		;
	sign = c != '-' ? 0 : 1;
	if (sign || c == '+')
	{
		do
			c = *str++;
		while (c == ' ');
	}
	if (c == 0)
		return -1;
	while (c >= '0' && c <= '9')
	{
		val = 10.0 * val + (c - '0');
		c = *str++;
	}
	if (c == '.')
	{
		mant = 1.0;
		c = *str++;
		while (c >= '0' && c <= '9')
		{
			mant = mant * 0.1;
			val = val + mant * (c - '0');
			c = *str++;
		}
	}
	exp = 0;
	if (c == 'e' || c == 'E')
	{
		c = *str++;
		expsign = c != '-' ? 0 : 1;
		if (expsign || c == '+')
			c = *str++;
		while (c >= '0' && c <= '9')
		{
			exp = exp * 10 + c - '0';
			c = *str++;
		}
		if (exp > 99)
			exp = 99;
		mant = expsign ? 0.1 : 10.0;
		while (exp-- > 0)
		{
			val = mant * val;
		}
	}
	if (c != ' ' && c != ',' && c != 0)
		return -2;
	if (sign)
		val = -val;
	*pval = val;
	return 1;
}
