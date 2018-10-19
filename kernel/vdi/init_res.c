#include <portab.h>
#include <tos.h>
#include "std.h"
#include "nvdi.h"
#include "init_res.h"
#include "drivers.h"


unsigned char *load_MAC_driver(VWK *vwk, const char *driver_dir)
{
	char fnamebuf[128];
	
	strgcpy(fnamebuf, driver_dir);
	switch (vwk->v_planes)
	{
	case 1:
		strgcat(fnamebuf, "MFM2.SYS");
		break;
	case 2:
		if (vwk->form_id == FORM_ID_INTERLEAVED)
			strgcat(fnamebuf, "MFM4IP.SYS");
		else
			strgcat(fnamebuf, "MFM4.SYS");
		break;
	case 4:
		if (vwk->form_id == FORM_ID_INTERLEAVED)
			strgcat(fnamebuf, "MFM16IP.SYS");
		else
			strgcat(fnamebuf, "MFM16.SYS");
		break;
	case 8:
		strgcat(fnamebuf, "MFM256.SYS");
		break;
	case 16:
		strgcat(fnamebuf, "MFM32K.SYS");
		break;
	case 32:
		strgcat(fnamebuf, "MFM16M.SYS");
		break;
	}
	return load_prg(fnamebuf);
}


unsigned char *load_ATARI_driver(WORD type, WORD subtype, const char *driver_dir, VWK *vwk)
{
	char fnamebuf[128];
	
	(void)vwk;
	strgcpy(fnamebuf, driver_dir);
	switch (type)
	{
	case 0:
		strgcat(fnamebuf, "MFA16.SYS");
		break;
	case 1:
		strgcat(fnamebuf, "MFA4.SYS");
		break;
	case 2:
		strgcat(fnamebuf, "MFA2.SYS");
		break;
	case 3:
		switch (subtype & 7)
		{
		case 0:
			strgcat(fnamebuf, "MFA2.SYS");
			break;
		case 1:
			strgcat(fnamebuf, "MFA4.SYS");
			break;
		case 2:
			strgcat(fnamebuf, "MFA16.SYS");
			break;
		case 3:
			strgcat(fnamebuf, "MFA256.SYS");
			break;
		case 4:
			strgcat(fnamebuf, "MFA32K.SYS");
			break;
		default:
			strgcat(fnamebuf, "MFA2.SYS");
			break;
		}
		break;
	case 4:
		strgcat(fnamebuf, "MFA16.SYS");
		break;
	case 6:
		strgcat(fnamebuf, "MFA2.SYS");
		break;
	case 7:
		strgcat(fnamebuf, "MFA256.SYS");
		break;
	case 5:
	default:
		strgcat(fnamebuf, "MFA2.SYS");
		break;
	}
	return load_prg(fnamebuf);
}
