#include <portab.h>
#include <tos.h>
#include <vdi.h>
#include "std.h"
#include "drivers.h"
#include "nvdi.h"
#include "init_res.h"

/* Bitmasks for Vsetmode() */
#define BPS1			0x00
#define BPS2			0x01
#define BPS4			0x02
#define BPS8			0x03
#define BPS16			0x04
#define BPS32			0x05	/* SuperVidel's RGBx truecolour (4 bytes per pixel) */
#define BPS8C			0x07	/* SuperVidel's 8-bit chunky mode */


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


DRV_SYS *load_ATARI_driver(WORD shiftmode, WORD modecode, const char *driver_dir)
{
	char fnamebuf[128];
	
	strgcpy(fnamebuf, driver_dir);
	switch (shiftmode)
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
		switch (modecode & 7)
		{
		case BPS1:
			strgcat(fnamebuf, "MFA2.SYS");
			break;
		case BPS2:
			strgcat(fnamebuf, "MFA4.SYS");
			break;
		case BPS4:
			strgcat(fnamebuf, "MFA16.SYS");
			break;
		case BPS8:
			strgcat(fnamebuf, "MFA256.SYS");
			break;
		case BPS16:
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
