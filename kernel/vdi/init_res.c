#include <portab.h>
#include <tos.h>
#include <vdi.h>
#include "std.h"
#include "drivers.h"
#include "nvdi.h"
#include "init_res.h"


DRV_SYS *load_MAC_driver(MXVDI_PIXMAP *pixmap, const char *driver_dir)
{
	char fnamebuf[128];
	
	strgcpy(fnamebuf, driver_dir);
	switch (pixmap->pixelSize)
	{
	case 1:
		strgcat(fnamebuf, "MFM2.SYS");
		break;
	case 2:
		if (pixmap->planeBytes == 2)
			strgcat(fnamebuf, "MFM4IP.SYS");
		else
			strgcat(fnamebuf, "MFM4.SYS");
		break;
	case 4:
		if (pixmap->planeBytes == 2)
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


DRV_SYS *load_ATARI_driver(WORD type, WORD subtype, const char *driver_dir)
{
	char fnamebuf[128];
	
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
