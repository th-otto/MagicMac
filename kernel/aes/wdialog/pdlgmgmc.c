#define __PRINTING__
#include "wdlgmain.h"
#include "pdlgqd.h"



static long get_mgmc_cookie(void);
static struct TGetRslBlk *mgmc_get_resolutions(void);
static void mac_get_resolutions(void);
static int add_mode(PRN_ENTRY *printer, long id, short iXRsl, short iYRsl, Boolean flag);



static void do_init_settings(TPrint **settings)
{
	if (mgmc_cookie->vers >= 0x103 &&
		mgmc_cookie->printDescPtr != NULL &&
		*mgmc_cookie->printDescPtr->printHdl != NULL)
	{
		MacHLock((Handle) mgmc_cookie->printDescPtr->printHdl);
		**settings = **mgmc_cookie->printDescPtr->printHdl;
		MacHUnlock((Handle) mgmc_cookie->printDescPtr->printHdl);
	} else
	{
		MacPrintDefault(settings);
	}
	MacPrValidate(settings);
}


static void init_mac_settings(void)
{
	TPrint *settings = &mac_settings->mac_settings;
	THPrint hPrint = &settings;
	
	MacPrOpen();
	if (MacPrError() == 0)
	{
		do_init_settings(hPrint);
	}
	MacPrClose();
}


static void validate_mac_settings(void)
{
	TPrint *settings = &mac_settings->mac_settings;
	THPrint hPrint = &settings;
	
	MacPrOpen();
	if (MacPrError() == 0)
	{
		MacPrValidate(hPrint);
	}
	MacPrClose();
}


long mgmc_init_settings(PRN_SETTINGS *settings)
{
	if (mgmc_cookie)
	{
		mac_settings = settings;
		ExecuteMacFunction(init_mac_settings);
		return TRUE;
	}
	return FALSE;
}


static void set_mac_settings(void)
{
	if (mgmc_cookie->vers >= 0x103 &&
		mgmc_cookie->printDescPtr != NULL &&
		*mgmc_cookie->printDescPtr->printHdl != NULL)
	{
		MacHLock((Handle) mgmc_cookie->printDescPtr->printHdl);
		**mgmc_cookie->printDescPtr->printHdl = mac_settings->mac_settings;
		MacHUnlock((Handle) mgmc_cookie->printDescPtr->printHdl);
	}
}


long mgmc_set_settings(PRN_SETTINGS *settings)
{
	if (mgmc_cookie)
	{
		mac_settings = settings;
		ExecuteMacFunction(set_mac_settings);
		return TRUE;
	}
	return FALSE;
}


long mgmc_validate_settings(PRN_SETTINGS *settings)
{
	if (mgmc_cookie)
	{
		mac_settings = settings;
		ExecuteMacFunction(validate_mac_settings);
		return TRUE;
	}
	return FALSE;
}


void mgmc_init(void)
{
	mgmc_cookie = (struct MgMcCookie *)Supexec(get_mgmc_cookie);
	if (mgmc_cookie != NULL)
	{
		modeMac = mgmc_cookie->modeMac;
		modeAtari = mgmc_cookie->modeAtari;
		callMacContext = mgmc_cookie->callMacContext;
		intrLock = mgmc_cookie->intrLock;
		intrUnlock = mgmc_cookie->intrUnlock;
		macA5 = mgmc_cookie->macA5;
	} else
	{
		modeMac = 0;
		modeAtari = 0;
		callMacContext = 0;
		macA5 = 0;
		intrLock = 0;
		intrUnlock = 0;
	}
}




int mgmc_get_modes(PRN_ENTRY *printer, Boolean flag)
{
	struct TGetRslBlk *tsl;
	WORD count;
	
	tsl = mgmc_get_resolutions();
	count = 0;
	if (tsl != NULL)
	{
		if (tsl->xRslRg.iMin <= 0 || tsl->iRslRecCnt > 1)
		{
			WORD i;
			
			for (i = 0; i < tsl->iRslRecCnt; i++)
			{
				if (add_mode(printer, count, tsl->rgRslRec[i].iXRsl, tsl->rgRslRec[i].iYRsl, flag))
					count++;
			}
		} else
		{
			WORD xmin;
			WORD xmax;
			WORD res;
			WORD frac;
			WORD val;
			
			xmin = tsl->xRslRg.iMin;
			if (xmin < 60)
				xmin = 60;
			xmax = tsl->xRslRg.iMax;
			if (xmax > 2540)
				xmax = 2540;
			res = tsl->rgRslRec[0].iXRsl;
			for (val = 128; val > 1; val /= 2)
			{
				frac = res / val;
				if (frac < xmin)
					continue;
				if (add_mode(printer, count, frac, frac, flag))
					count++;
			}
			while (res <= xmax)
			{
				if (add_mode(printer, count, res, res, flag))
					count++;
				if (res == 300)
				{
					if (add_mode(printer, count, 400, 400, flag))
						count++;
				}
				if (res == 600)
				{
					if (add_mode(printer, count, 800, 800, flag))
						count++;
				}
				res = res * 2;
			}
			if ((res / 2) < xmax)
			{
				if (add_mode(printer, count, xmax, xmax, flag))  ; /* << BUG */
					count++;
			}
		}
	}
	return count;
}


static int add_mode(PRN_ENTRY *printer, long id, short xres, short yres, Boolean flag)
{
	PRN_MODE *mode;
	char buf[8];
	
	mode = Malloc(sizeof(*mode));
	if (mode != NULL)
	{
		mode->next = NULL;
		mode->mode_id = id;
		mode->mode_capabilities = 0;
		mode->color_capabilities = CC_MONO;
		mode->dither_flags = 0;
		mode->paper_types = NULL;
		/* mode->reserved = 0; */
		if (flag)
		{
			mode->color_capabilities |= CC_8_COLOR | CC_16M_COLOR;
			mode->dither_flags |= CC_16M_COLOR;
		}
		mode->hdpi = xres;
		mode->vdpi = yres;
		itoa(xres, mode->name, 10);
		strcat(mode->name, " * ");
		itoa(yres, buf, 10);
		strcat(mode->name, buf);
		strcat(mode->name, " dpi");
		list_append((void **)&printer->modes, mode);
		return TRUE;
	}
	return FALSE;
}


static struct TGetRslBlk *mgmc_get_resolutions(void)
{
	if (mgmc_cookie)
	{
		ExecuteMacFunction(mac_get_resolutions);
		if (mac_exit_code != 0)
			return &getRslBlk;
	}
	return NULL;
}


static void mac_get_resolutions(void)
{
	THPrint hPrint;
	
	mac_exit_code = 0;
	hPrint = (THPrint)MacNewHandle(sizeof(TPrint));
	if (hPrint != 0)
	{
		MacPrOpen();
		if (MacPrError() == 0)
		{
			**hPrint = mac_settings->mac_settings;
			getRslBlk.iOpCode = getRslDataOp;
			MacPrGeneral(&getRslBlk);
			if (MacPrError() == 0)
				mac_exit_code = 1;
		}
		MacPrClose();
		MacDisposeHandle((Handle)hPrint);
	}
}


long get_mgmc_cookie(void)
{
	long *jarptr;
	
	jarptr = *((long **)0x5a0);
	if (jarptr != NULL)
	{
		while (*jarptr != 0)
		{
			if (*jarptr == 0x4D674D63L) /* 'MgMc' */
				return jarptr[1];
			jarptr += 2;
		}
	}
	return 0;
}
