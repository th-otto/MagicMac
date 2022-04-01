/*
	Copyright 1982
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121
*/

#include "vt52.h"

/* 
 *	Floating Point Float to Long Routine :
 *		Front End to IEEE Floating Point Package.
 *
 *	long
 *	fpftol(fparg)
 *	double fparg;
 *
 *	Return : Fixed Point representation of Floating Point Number
 */

long fpftol(P(long) f)
PP(long f;)
{
	register long l;
	register int exp, sign;

	exp = (f & 0x7f) - 0x40;
	if (f == 0L || exp < 0)				/* underflow or 0 */
		return (0L);
	sign = (f & 0x80);
	if (exp > 31)						/* overflow */
		return ((sign) ? 0x80000000 : 0x7fffffff);
	l = (f >> 8) & 0xffffff;
	exp -= 24;
	for (; exp < 0; exp++)
		l >>= 1;
	for (; exp > 0; exp--)
		l <<= 1;
	if (sign)
		l = -l;
	return (l);
}

asm("dc.w 0x23f9");
asm("dc.b 'ftol.o',0,0");
