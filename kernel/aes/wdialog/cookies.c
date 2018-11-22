#include "wdlgmain.h"

#define P_COOKIES ((long **) 0x5a0)

long get_magic_cookie(void)
{
	long *jarptr;
	
	jarptr = *P_COOKIES;
	if (jarptr != NULL)
	{
		while (*jarptr != 0)
		{
			if (*jarptr == 0x4D616758L) /* 'MagX' */
				return jarptr[1];
			jarptr += 2;
		}
	}
	return 0;
}


long get_nvdi_cookie(void)
{
	long *jarptr;
	
	jarptr = *P_COOKIES;
	if (jarptr != NULL)
	{
		while (*jarptr != 0)
		{
			if (*jarptr == 0x4E564449L) /* 'NVDI' */
				return jarptr[1];
			jarptr += 2;
		}
	}
	return 0;
}
