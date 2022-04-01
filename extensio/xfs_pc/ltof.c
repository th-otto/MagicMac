/*
	Copyright 1982
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121
*/

#include "vt52.h"

/* 
 *	Floating Point Long to Float Routine :
 *		Front End to FFP Floating Point Package.
 *
 *		double
 *		fpltof(larg)
 *		long larg;
 *
 *	Return : Floating Point representation of Long Fixed point integer
 */

long fpltof(P(long) l)
PP(long l;)
{
	register long exp;
	register int sign;

	if (l < 0)
	{									/* signed ?? */
		sign = 1;
		l = -l;
	} else
		sign = 0;
	if (l == 0)
		return (0);
	exp = 24;
	for (; l & 0x7f000000; exp++)		/* something in upper 7 bits */
		l >>= 1;
	for (; !(l & 0x00800000); exp--)	/* get mantissa : .F */
		l <<= 1;
	l <<= 8;							/* mantissa (.F) into top 24 bits */
	exp += 0x40;
	l |= (exp & 0x7f);
	if (sign)
		l |= 0x80;
	return (l);
}

asm("dc.w 0x23f9");
asm("dc.b 'ltof.o',0,0");
