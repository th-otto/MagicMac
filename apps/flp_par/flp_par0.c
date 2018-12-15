/*********************************************************************
*
*  FLP_PAR0              Andreas Kromke, 27.8.94
*  ========
*
* schaltet die parallele FloppyÅbertragung ab.
*
*********************************************************************/

#include <tos.h>

int main( void )
{
	long mode;

	mode = Sconfig(0, 0L);
	Sconfig(1, mode & ~SCB_FLPAR);		/* Parallelbetrieb aus */
	return(0);
}
