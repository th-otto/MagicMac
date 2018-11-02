#define __PRINTING__
#include "wdlgmain.h"
#include "mgmc_api.h"
#include "pdlgqd.h"

#define strlen mystrlen

#define ctrlItem	4

struct mac_sub_dlg {
	DialogItem dlg;
	const char *title;
};



static _LONG _CDECL init_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub);
static _LONG _CDECL do_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj);
static _LONG _CDECL reset_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub);
static _LONG _CDECL init_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub);
static _LONG _CDECL do_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj);
static _LONG _CDECL reset_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub);
static _LONG _CDECL init_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub);
static _LONG _CDECL do_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj);
static _LONG _CDECL reset_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub);
static short handle_dlg_paper_mac(void);
static short handle_dlg_general_mac(void);
static TPPrDlg pascal mac_dlg_init_paper(THPrint hPrint);
static TPPrDlg pascal mac_dlg_init_general(THPrint hPrint);
static short create_sub_dlgs(TPPrDlg dlg, const struct mac_sub_dlg *subdlgs, int count, short id);
static void subclass_dialog(TPPrDlg dlg);
static void qd_refresh_modes(XDRV_ENTRY *driver, PRN_ENTRY *printer);


#define NUM(x) (WORD)(sizeof(x) / sizeof(x[0]))

static struct mac_sub_dlg const mac_sub_dlgs_paper[] = {
	{ { 0, { 10, 10, 30, 110 }, ctrlItem, 12 }, "Allgemein..." },
	{ { 0, { 10, 120, 30, 270 }, ctrlItem, 19 }, "weitere Optionen..." }
};

static struct mac_sub_dlg const mac_sub_dlgs_general[] = {
	{ { 0, { 40, 10, 60, 130 }, ctrlItem, 15 }, "Papierformat..." },
	{ { 0, { 40, 140, 60, 300 }, ctrlItem, 19 }, "weitere Optionen..." },
	{ { 0, { 10, 10, 30, 120 }, 5, 13 }, "gerade Seiten" },
	{ { 0, { 10, 130, 30, 260 }, 5, 15 }, "ungerade Seiten" }
};


static SIMPLE_SUB const qd_subs[] = {
	{ 0, init_dlg_general, do_dlg_general, reset_dlg_general, ICON_GENERAL, NIL },
	{ 1, init_dlg_paper, do_dlg_paper, reset_dlg_paper, ICON_PAPER, NIL },
	{ 4, init_dlg_options, do_dlg_options, reset_dlg_options, ICON_OPTIONS, DITHER_DIALOG }
};


static void get_mac_settings(THPrint mac, PRN_SETTINGS *settings)
{
	settings->first_page = (*mac)->prJob.iFstPage;
	settings->last_page = (*mac)->prJob.iLstPage;
	if (settings->first_page < PG_MIN_PAGE)
		settings->first_page = PG_MIN_PAGE;
	if (settings->first_page > PG_MAX_PAGE)
		settings->first_page = PG_MAX_PAGE;
	if (settings->last_page < PG_MIN_PAGE)
		settings->last_page = PG_MIN_PAGE;
	if (settings->last_page > PG_MAX_PAGE)
		settings->last_page = PG_MAX_PAGE;
	settings->no_copies = (*mac)->prJob.iCopies;
	settings->mac_settings = **mac;
	getRotnBlk.iOpCode = getRotnOp;
	getRotnBlk.hPrint = mac;
	MacPrGeneral(&getRotnBlk);
	if (MacPrError() == 0 && getRotnBlk.iError == 0)
	{
		if (getRotnBlk.fLandscape)
			settings->orientation = PG_LANDSCAPE;
		else
			settings->orientation = PG_PORTRAIT;
	} else
	{
		settings->orientation = PG_UNKNOWN;
	}
	settings->scale = 1L << 16;
}



static void do_dlg_paper_mac(void)
{
	MacPrOpen();
	if (MacPrError() == 0)
		mac_exit_code = handle_dlg_paper_mac();
	else
		mac_exit_code = 3;
	MacPrClose();
}


static short handle_dlg_paper_mac(void)
{
	THPrint hPrint;
	PRN_SETTINGS *settings;
	
	hPrint = (THPrint)MacNewHandle(sizeof(TPrint));
	if (hPrint != 0)
	{
		settings = mac_settings;
		**hPrint = settings->mac_settings;
		(*hPrint)->prJob.iFstPage = settings->first_page;
		(*hPrint)->prJob.iLstPage = settings->last_page;
		(*hPrint)->prJob.iCopies = settings->no_copies;
		if (MacPrError() == 0)
		{
			mac_dlg = MacPrStlInit(hPrint);
			if (MacPrError() == 0)
			{
				if (MacPrDlgMain(hPrint, mac_dlg_init_paper))
				{
					get_mac_settings(hPrint, settings);
					MacDisposeHandle((Handle)hPrint);
					switch (mac_dlg_code)
					{
						case 1: return 2;
						case 2: return 3;
						default: return 1;
					}
				}
				MacDisposeHandle((Handle)hPrint);
			}
		}
	}
	return 0;
}


static TPPrDlg pascal mac_dlg_init_paper(THPrint hPrint)
{
	WORD id;
	
	UNUSED(hPrint);
	if (mac_subdlg->option_flags & PDLG_PRINT)
		id = 1;
	else
		id = 0;
	mac_subdlg_code = create_sub_dlgs(mac_dlg, mac_sub_dlgs_paper, NUM(mac_sub_dlgs_paper), id);
	if (mac_subdlg_code != 0)
	{
		subclass_dialog(mac_dlg);
		return mac_dlg;
	}
	
	return 0;
}


static void do_dlg_general_mac(void)
{
	MacPrOpen();
	if (MacPrError() == 0)
		mac_exit_code = handle_dlg_general_mac();
	else
		mac_exit_code = 3;
	MacPrClose();
}


static short handle_dlg_general_mac(void)
{
	THPrint hPrint;
	
	hPrint = (THPrint)MacNewHandle(sizeof(TPrint));
	if (hPrint != 0)
	{
		PRN_SETTINGS *settings = *&mac_settings;
		
		**hPrint = settings->mac_settings;
		(*hPrint)->prJob.iFstPage = (*&mac_settings)->first_page;
		(*hPrint)->prJob.iLstPage = (*&mac_settings)->last_page;
		(*hPrint)->prJob.iCopies = (*&mac_settings)->no_copies;
		if (MacPrError() == 0)
		{
			mac_dlg = MacPrJobInit(hPrint);
			if (MacPrError() == 0)
			{
				if (MacPrDlgMain(hPrint, mac_dlg_init_general))
				{
					get_mac_settings(hPrint, settings);
					MacDisposeHandle((Handle)hPrint);
					switch (mac_dlg_code)
					{
						case 1: return 2;
						case 2: return 3;
						default: return 1;
					}
				}
				MacDisposeHandle((Handle)hPrint);
			}
		}
	}
	return 0;
}


static TPPrDlg pascal mac_dlg_init_general(THPrint hPrint)
{
	WORD id;
	WORD count;
	Handle item;
	Rect box;
	Integer itemType;
	
	UNUSED(hPrint);
	if (mac_subdlg->option_flags & PDLG_PRINT)
		id = 1;
	else
		id = 0;
	if (mac_subdlg->option_flags & PDLG_EVENODD)
		count = 4;
	else
		count = 2;
	mac_subdlg_code = create_sub_dlgs(mac_dlg, mac_sub_dlgs_general, count, id);
	if (mac_subdlg_code != 0)
	{
		subclass_dialog(mac_dlg);
		if (mac_subdlg->option_flags & PDLG_EVENODD)
		{
			MacGetDItem((DialogPtr)mac_dlg, mac_subdlg_code + 2, &itemType, &item, &box);
			if (mac_settings->page_flags & PG_EVEN_PAGES)
				MacSetCtlValue(item, 1);
			else
				MacSetCtlValue(item, 0);
			MacGetDItem((DialogPtr)mac_dlg, mac_subdlg_code + 3, &itemType, &item, &box);
			if (mac_settings->page_flags & PG_ODD_PAGES)
				MacSetCtlValue(item, 1);
			else
				MacSetCtlValue(item, 0);
		}
		return mac_dlg;
	}
	
	return 0;
}


static Boolean pascal my_filter_proc(DialogPtr dlg, EventRecord *event, short *data);
static void pascal my_item_proc(DialogPtr dlg, short item);

static void subclass_dialog(TPPrDlg dlg)
{
	old_item_proc = dlg->pItemProc;
	dlg->pItemProc = my_item_proc;
	old_filter_proc = dlg->pFltrProc;
	dlg->pFltrProc = my_filter_proc;
	mac_dlg_code = 0;
}


static void pascal my_item_proc(DialogPtr dlg, short itemno)
{
	WORD idx;
	
	idx = itemno - mac_subdlg_code;
	if (idx >= 0)
	{
		switch (idx)
		{
		case 0:
		case 1:
			mac_dlg_code = idx + 1;
			break;
		case 2:
			{
			Handle item;
			Rect box;
			Integer itemType;
			mac_settings->page_flags ^= PG_EVEN_PAGES;
			MacGetDItem(dlg, itemno, &itemType, &item, &box);
			if (mac_settings->page_flags & PG_EVEN_PAGES)
				MacSetCtlValue(item, 1);
			else
				MacSetCtlValue(item, 0);
			}
			break;
		case 3:
			{
			Handle item;
			Rect box;
			Integer itemType;
			mac_settings->page_flags ^= PG_ODD_PAGES;
			MacGetDItem(dlg, itemno, &itemType, &item, &box);
			if (mac_settings->page_flags & PG_ODD_PAGES)
				MacSetCtlValue(item, 1);
			else
				MacSetCtlValue(item, 0);
			}
			break;
		}
	} else
	{
		if (old_item_proc)
			old_item_proc(dlg, itemno);
	}
}


static Boolean pascal my_filter_proc(DialogPtr dlg, EventRecord *event, short *itemHit)
{
	if (mac_dlg_code)
	{
		*itemHit = 1;
		return 1;
	} else if (old_filter_proc)
	{
		return old_filter_proc(dlg, event, itemHit);
	}
	return 0;
}


static short create_sub_dlgs(TPPrDlg dlg, const struct mac_sub_dlg *subdlgs, int count, short id)
{
	WORD i;
	LONG total_len;
	Str255 PrintButton;
	Handle item;
	Rect box;
	Integer itemType;
	unsigned short offsets[2];
	Rect totalbox;
	Ptr data;
	char *ptr;
	LONG offset;
	LONG itemlen;
	ItemListHandle items;
	
	if (dlg == 0)
		return FALSE;
	total_len = 0;
	for (i = 0; i < count; i++)
	{
		LONG len = strlen(subdlgs[i].title);
		subdlgs[i].dlg.data[0] = (unsigned char)len;
		total_len += (len + 1) & 0xfffe;
	}
	total_len += count * sizeof(DialogItem);
	total_len += 2;
	data = MacNewPtr(total_len);
	if (data == 0)
		return FALSE;
	
	MacGetDItem((DialogPtr)dlg, 1, &itemType, &item, &box);
	if (itemType == 4)
	{
		if (id != 0)
			vstrcpy((char *)PrintButton + 1, "Drucken");
		else
			vstrcpy((char *)PrintButton + 1, "OK");
		PrintButton[0] = (unsigned char)strlen((char *)PrintButton + 1);
		MacSetCTitle(item, PrintButton);
	}
	offset = 0;
	ptr = data;
	for (i = 0; i < count; i++)
	{
		*((DialogItem *)ptr) = subdlgs->dlg;
		vstrcpy(ptr + sizeof(DialogItem), subdlgs->title);
		itemlen = sizeof(DialogItem);
		itemlen += (((size_t)((DialogItem *)ptr)->data[0] + 1) & 0xfffeUL);
		offset += itemlen;
		ptr += itemlen;
		subdlgs++;
	}
	totalbox = dlg->Dlg.window.port.portRect;
	offsets[0] = totalbox.bottom;
	offsets[1] = 0;
	totalbox.bottom -= 5;
	totalbox.right -= 5;
	items = (ItemListHandle)dlg->Dlg.items;

	{
		short max_index;
		
		max_index = (*items)->max_index + 2;
		ptr = data;
		for (i = 0; i < count; i++)
		{
			MacOffsetRect(&((DialogItem *)ptr)->bounds, offsets[1], offsets[0]);
			MacUnionRect(&((DialogItem *)ptr)->bounds, &totalbox, &totalbox);
			itemlen = ((size_t)((DialogItem *)ptr)->data[0] + 1) & 0xfffe;
			switch (((DialogItem *)ptr)->type & 0x7f)
			{
			case 4:
			case 5:
			case 6:
				((DialogItem *)ptr)->handle = MacNewControl(&dlg->Dlg.window,
					&((DialogItem *)ptr)->bounds,
					((DialogItem *)ptr)->data, TRUE,
					0, 0, 1,
					((DialogItem *)ptr)->type & 3,
					0);
				break;
			default:
				((DialogItem *)ptr)->handle = 0;
				break;
			}
			itemlen += sizeof(DialogItem);
			ptr += itemlen;
		}
		{
			MacOSErr err;
			
			err = MacPtrAndHand(data, (Handle)items, offset);
			MacDisposePtr(data);
			if (err == 0)
			{
				(*items)->max_index += count;
				totalbox.bottom += 5;
				totalbox.right += 5;
				MacSizeWindow(&dlg->Dlg.window, totalbox.right, totalbox.bottom, TRUE);
				return max_index;
			}
		}
	}
	return 0;
}


PDLG_SUB *pdlg_qd_sub(OBJECT **tree_addr)
{
	return install_sub_dialogs(tree_addr, qd_subs, NUM(qd_subs));
}


static _LONG _CDECL init_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	mac_subdlg = sub;
	mac_settings = settings;
	return TRUE;
}


static _LONG _CDECL do_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj)
{
	UNUSED(settings);
	UNUSED(sub);
	UNUSED(exit_obj);
	ExecuteMacFunction(do_dlg_general_mac);
	switch (mac_exit_code)
	{
	case 0:
		return PDLG_PREBUTTON | PDLG_PB_CANCEL;
	case 1:
		return PDLG_PREBUTTON | PDLG_PB_OK;
	case 2:
		return PDLG_CHG_SUB | 1;
	case 3:
		return PDLG_CHG_SUB | 4;
	}
	return TRUE;
}


static _LONG _CDECL reset_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	XDRV_ENTRY *driver;
	PRN_ENTRY *printer;
	
	sub = mac_subdlg;
	driver = get_driver((XDRV_ENTRY *)sub->drivers, settings);
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	qd_refresh_modes(driver, printer);
	return TRUE;
}


static _LONG _CDECL init_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	mac_subdlg = sub;
	mac_settings = settings;
	return TRUE;
}


static _LONG _CDECL do_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj)
{
	UNUSED(settings);
	UNUSED(sub);
	UNUSED(exit_obj);
	ExecuteMacFunction(do_dlg_paper_mac);
	switch (mac_exit_code)
	{
	case 0:
		return PDLG_PREBUTTON | PDLG_PB_CANCEL;
	case 1:
		return PDLG_PREBUTTON | PDLG_PB_OK;
	case 2:
		return PDLG_CHG_SUB | 0;
	case 3:
		return PDLG_CHG_SUB | 4;
	}
	return TRUE;
}


static _LONG _CDECL reset_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	XDRV_ENTRY *driver;
	PRN_ENTRY *printer;
	
	sub = mac_subdlg;
	driver = get_driver((XDRV_ENTRY *)sub->drivers, settings);
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	qd_refresh_modes(driver, printer);
	return TRUE;
}


static _LONG _CDECL init_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	XDRV_ENTRY *driver;
	PRN_ENTRY *printer;
	OBJECT *tree;
	WORD index_offset;
	
	driver = get_driver((XDRV_ENTRY *)sub->drivers, settings);
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	qd_refresh_modes(driver, printer);
	tree = sub->tree;
	index_offset = sub->index_offset;
	set_tedinfo(tree, PAPER_DEVICE_POPUP + index_offset, get_printer((XDRV_ENTRY *)sub->drivers, settings)->name, 2);
	set_mode(sub, settings, settings->mode_hdpi, settings->mode_vdpi, settings->mode_id);
	set_color(sub, settings, settings->color_mode);
	settings->scale = 1L << 16;
	if (printer->printer_capabilities & PC_BACKGROUND)
	{
		tree[DITHER_BACKGROUND + index_offset].ob_state &= ~DISABLED;
		tree[DITHER_FOREGROUND + index_offset].ob_state &= ~DISABLED;
		if (settings->driver_mode & DM_BG_PRINTING)
			tree[DITHER_BACKGROUND + index_offset].ob_state |= SELECTED;
		else
			tree[DITHER_FOREGROUND + index_offset].ob_state |= SELECTED;
	} else
	{
		tree[DITHER_BACKGROUND + index_offset].ob_state |= DISABLED;
		tree[DITHER_FOREGROUND + index_offset].ob_state |= DISABLED;
		tree[DITHER_FOREGROUND + index_offset].ob_state |= SELECTED;
	}
	return TRUE;
}


static _LONG _CDECL do_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj)
{
	switch (exit_obj - sub->index_offset)
	{
	case DITHER_DEVICE_POPUP:
		return PDLG_PREBUTTON | PDLG_PB_DEVICE;
	case DITHER_DITHER_POPUP:
		/* ??? we are running a mac-dialog here;
		   invoking WDIALOG popups might not work */
		do_qual_popup(settings, sub, exit_obj);
		break;
	case DITHER_COLOR_POPUP:
		/* ??? we are running a mac-dialog here;
		   invoking WDIALOG popups might not work */
		do_color_popup(settings, sub, exit_obj);
		break;
	}
	return TRUE;
}


static _LONG _CDECL reset_dlg_options(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;
	
	if (tree[DITHER_BACKGROUND + index_offset].ob_state & SELECTED)
		settings->driver_mode |= DM_BG_PRINTING;
	else
		settings->driver_mode &= ~DM_BG_PRINTING;
	return TRUE;
}



LONG __CDECL pdlg_qd_setup(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer)
{
	UNUSED(old_printer);
	UNUSED(new_printer);
	mac_settings = settings;
	mgmc_set_settings(settings);
	validate_mode((XDRV_ENTRY *)drivers, settings, settings->mode_hdpi, settings->mode_vdpi, settings->mode_id);
	validate_color_mode((XDRV_ENTRY *)drivers, settings, settings->color_mode);
	if (mgmc_cookie)
		return TRUE;
	return FALSE;
}


LONG __CDECL pdlg_qd_close(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer)
{
	UNUSED(drivers);
	UNUSED(old_printer);
	UNUSED(new_printer);
	mgmc_set_settings(settings);
	return TRUE;
}


static void qd_refresh_modes(XDRV_ENTRY *driver, PRN_ENTRY *printer)
{
	Boolean flag;
	
	if (driver->driver_type == DT_NVDI || driver->version >= 0x410)
		flag = TRUE;
	else
		flag = FALSE;
	delete_modes(&printer->modes);
	mgmc_get_modes(printer, flag);
}
