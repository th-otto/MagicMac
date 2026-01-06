/*
 *
 * Main module for the hostfs.xfs for MagiX.
 * Based on Andreas Kromke's port of the cd-xfs
 *
 * (C) Thorsten Otto 2018
 *
 */

#include "hostfs.h"



/********************** MAIN ***********************/

int main(void)
{
	LONG ret;

	ret = hostxfs.xfs_init();
	if (ret < E_OK)
		return (int) ret;				/* Fehler */

	Ptermres(_PgmSize, 0);
	return 0;
}
