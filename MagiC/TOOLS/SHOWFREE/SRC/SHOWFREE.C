/*********************************************************************
*
* Zeigt den freien internen Speicher an.
*
*********************************************************************/

#include <stdio.h>
#include <tos.h>
#include <tosdefs.h>

#define   KER_INTMAVAIL  0x0102
#define	KER_INTGARBC	0x0103

void main()
{
	long n[2];
	long n2[2] = {0,0};

	for	(;;)
		{
		while(Dcntl(KER_INTGARBC, (char *) 0, 0L))
			;
		Dcntl(KER_INTMAVAIL, (char *) 0, (long) n);
		if	(n[0] != n2[0] || n[1] != n2[1])
			{
			printf("frei: %3ld belegt: %3ld\n", n[0], n[1]);
			n2[0] = n[0];
			n2[1] = n[1];
			}
		}
}