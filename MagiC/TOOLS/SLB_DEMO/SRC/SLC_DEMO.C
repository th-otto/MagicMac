/*
*
* Demo-Programm fr die Benutzung einer "shared library"
*
* Andreas Kromke
* 22.10.97
*
*/

#include <tos.h>
#include <stdio.h>
#include "slb.h"

SLB_EXEC	slbexec;
SHARED_LIB  slb;

WORD main( void )
{
	LONG err;


	/* SharedLibrary ”ffnen */
	/* -------------------- */

	err = Slbopen("SLB_DEMO.SLB", ".\\", 1L,
				&slb, &slbexec);
	printf("Slbopen => %ld\n", err);
	if	(err < 0)
		{
		return((int) err);
		}
	
	/* Beispielfunktion aufrufen */
	/* ------------------------- */

	err = (*slbexec)(slb, 0L, 2, "sis is e strink\r\n");
	printf("exec => %ld\n", err);
	if	(err < 0)
		{
		return((int) err);
		}

	/* SharedLibrary schlieen */
	/* ----------------------- */

	err = Slbclose( slb );
	printf("Slbclose => %ld\n", err);
	if	(err < 0)
		{
		return((int) err);
		}

	return(0);
}