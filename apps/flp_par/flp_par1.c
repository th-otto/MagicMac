/*********************************************************************
*
*  FLP_PAR1              Andreas Kromke, 27.8.94
*  ========
*
* schaltet die parallele FloppyÅbertragung ein.
*
*********************************************************************/

#include <tos.h>

int main( void )
{
	long mode;

	mode = Sconfig(0, 0L);
	Sconfig(1, mode | SCB_FLPAR);		/* Parallelbetrieb ein */
	return(0);
}
