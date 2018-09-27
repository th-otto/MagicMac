#include <tos.h>
#include <tosdefs.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BEG_TTRAM	((char *) 0x01000000L)

/* Meldet einfach einen Teil des TT-RAMs an */

int main()
{
	Maddalt(BEG_TTRAM,  0x20000L);
	Maddalt(BEG_TTRAM + 0x20000L, 0x10000L);
	return(0);
}