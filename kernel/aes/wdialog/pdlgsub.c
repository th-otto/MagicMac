#include "wdlgmain.h"

#define strlen mystrlen

#if	CALL_MAGIC_KERNEL == 0
	#define graf_mkstate_event(ev) mt_graf_mkstate_event(ev, NULL)
#else
	#define graf_mkstate_event(ev) graf_mkstate(&(ev)->x, &(ev)->y, &(ev)->bstate, &(ev)->kstate)
#endif

/*
 * FIXME: these belong into the RSC file
 */
#if COUNTRY == COUNTRY_DE || COUNTRY == COUNTRY_SG

#define S_CC_MONO "S/W"
#define S_CC_4_GREY "4 Graustufen"
#define S_CC_8_GREY "8 Graustufen"
#define S_CC_16_GREY "16 Graustufen"
#define S_CC_256_GREY "256 Graustufen"
#define S_CC_32K_GREY "Graustufen"
#define S_CC_65K_GREY "Graustufen"
#define S_CC_16M_GREY "Graustufen"
#define S_CC_2_COLOR "2 Farben"
#define S_CC_4_COLOR "4 Farben"
#define S_CC_8_COLOR "8 Farben"
#define S_CC_16_COLOR "16 Farben"
#define S_CC_256_COLOR "256 Farben"
#define S_CC_32K_COLOR "32768"
#define S_CC_65K_COLOR "65536"
#define S_CC_16M_COLOR "Vollfarben"
#define S_PARALLEL_DEVICE "parallele Schnittstelle"
#define S_SERIAL_DEVICE "serielle Schnittstelle"
#define S_ACSI_DEVICE "ACSI-Schnittstelle"
#define S_SCSI_DEVICE "SCSI-Schnittstelle"
#define S_FILE_OUTPUT "in Datei ausgeben"
#define S_FILE_TITLE "Datei/Ger\204t ausw\204hlen"

#elif COUNTRY == COUNTRY_US || COUNTRY == COUNTRY_UK

#define S_CC_MONO "B/W"
#define S_CC_4_GREY "4 Greyscale"
#define S_CC_8_GREY "8 Greyscale"
#define S_CC_16_GREY "16 Greyscale"
#define S_CC_256_GREY "256 Greyscale"
#define S_CC_32K_GREY "Greyscale"
#define S_CC_65K_GREY "Greyscale"
#define S_CC_16M_GREY "Greyscale"
#define S_CC_2_COLOR "2 colors"
#define S_CC_4_COLOR "4 colors"
#define S_CC_8_COLOR "8 colors"
#define S_CC_16_COLOR "16 colors"
#define S_CC_256_COLOR "256 colors"
#define S_CC_32K_COLOR "32768"
#define S_CC_65K_COLOR "65536"
#define S_CC_16M_COLOR "True color"
#define S_PARALLEL_DEVICE "Parallel Port"
#define S_SERIAL_DEVICE "Serial Port"
#define S_ACSI_DEVICE "ACSI-port"
#define S_SCSI_DEVICE "SCSI-port"
#define S_FILE_OUTPUT "Output to file"
#define S_FILE_TITLE "File/Device selection"

#elif COUNTRY == COUNTRY_FR || COUNTRY == COUNTRY_SF

#define S_CC_MONO "B/W"
#define S_CC_4_GREY "4 Greyscale"
#define S_CC_8_GREY "8 Greyscale"
#define S_CC_16_GREY "16 Greyscale"
#define S_CC_256_GREY "256 Greyscale"
#define S_CC_32K_GREY "Greyscale"
#define S_CC_65K_GREY "Greyscale"
#define S_CC_16M_GREY "Greyscale"
#define S_CC_2_COLOR "2 colors"
#define S_CC_4_COLOR "4 colors"
#define S_CC_8_COLOR "8 colors"
#define S_CC_16_COLOR "16 colors"
#define S_CC_256_COLOR "256 colors"
#define S_CC_32K_COLOR "32768"
#define S_CC_65K_COLOR "65536"
#define S_CC_16M_COLOR "True color"
#define S_PARALLEL_DEVICE "Parallel Port"
#define S_SERIAL_DEVICE "Serial Port"
#define S_ACSI_DEVICE "ACSI-port"
#define S_SCSI_DEVICE "SCSI-port"
#define S_FILE_OUTPUT "Output to file"
#define S_FILE_TITLE "File/Device selection"

#endif


#define CC_ANY_COLOR (CC_2_COLOR | CC_4_COLOR | CC_8_COLOR | CC_16_COLOR | CC_256_COLOR | CC_32K_COLOR | CC_65K_COLOR | CC_16M_COLOR)
#define CC_ANY_BRIGHT (CC_256_GREY | CC_32K_GREY | CC_65K_GREY | CC_16M_GREY | CC_256_COLOR | CC_32K_COLOR | CC_65K_COLOR | CC_16M_COLOR)


static LONG _CDECL init_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL do_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static LONG _CDECL reset_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL init_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL do_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static LONG _CDECL reset_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL init_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL do_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static LONG _CDECL reset_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL init_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub);
static LONG _CDECL do_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static LONG _CDECL reset_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub);

static void set_tedinfo(OBJECT *tree, WORD obj, const char *str, WORD spaces);
static void set_mode(PDLG_SUB *sub, PRN_SETTINGS *settings, WORD hdpi, WORD vdpi, LONG mode_id);
static void set_color(PDLG_SUB *sub, PRN_SETTINGS *settings, LONG color_mode);
static int do_qual_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_color_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static void set_paper_size(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_media_type(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_input_tray(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_output_tray(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_orientation(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_scale(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_dither_mode(PDLG_SUB *sub, PRN_SETTINGS *settings);
static void set_device(PDLG_SUB *sub, PRN_SETTINGS *settings);
static int do_size_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_paperqual_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_intray_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_outtray_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_dither_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static int do_device_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj);
static WORD slider_val(DIALOG *dialog, OBJECT *tree, WORD obj, WORD exit_button);
static void empty_tedinfo(OBJECT *tree, WORD obj);


static SIMPLE_SUB const std_subs[] = {
	{ 0, init_dlg_general, do_dlg_general, reset_dlg_general, ICON_GENERAL, PAGE_DIALOG },
	{ 1, init_dlg_paper, do_dlg_paper, reset_dlg_paper, ICON_PAPER, PAPER_DIALOG },
	{ 2, init_dlg_color, do_dlg_color, reset_dlg_color, ICON_DITHER, COLOR_DIALOG },
	{ 3, init_dlg_device, do_dlg_device, reset_dlg_device, ICON_DEVICE, DEVICE_DIALOG }
};

static SIMPLE_SUB const fsm_subs[] = {
	{ 0, init_dlg_general, do_dlg_general, reset_dlg_general, ICON_GENERAL, PAGE_DIALOG },
	{ 1, init_dlg_paper, do_dlg_paper, NULL, ICON_PAPER, PAPER_DIALOG }
};

static const char *const color_cap_names[NO_CC_BITS] = {
	S_CC_MONO,
	S_CC_4_GREY,
	S_CC_8_GREY,
	S_CC_16_GREY,
	S_CC_256_GREY,
	S_CC_32K_GREY,
	S_CC_65K_GREY,
	S_CC_16M_GREY,
	S_CC_2_COLOR,
	S_CC_4_COLOR,
	S_CC_8_COLOR,
	S_CC_16_COLOR,
	S_CC_256_COLOR,
	S_CC_32K_COLOR,
	S_CC_65K_COLOR,
	S_CC_16M_COLOR
};



#define NUM(x) (WORD)(sizeof(x) / sizeof(x[0]))

PDLG_SUB *pdlg_fsm_sub(OBJECT **tree_addr)
{
	return install_sub_dialogs(tree_addr, fsm_subs, NUM(fsm_subs));
}


PDLG_SUB *pdlg_std_sub(OBJECT **tree_addr)
{
	return install_sub_dialogs(tree_addr, std_subs, NUM(std_subs));
}


static LONG _CDECL init_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	PRN_ENTRY *printer;
	OBJECT *tree;
	WORD index_offset;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	tree = sub->tree;
	index_offset = sub->index_offset;
	
	set_tedinfo(tree, PAGE_DEVICE_POPUP + index_offset, get_printer((XDRV_ENTRY *)sub->drivers, settings)->name, 2);
	set_mode(sub, settings, settings->mode_hdpi, settings->mode_vdpi, settings->mode_id);
	set_color(sub, settings, settings->color_mode);
	itoa(settings->no_copies, tree[PAGE_COPIES + index_offset].ob_spec.tedinfo->te_ptext, 10);
	if (settings->first_page == PG_MIN_PAGE && settings->last_page == PG_MAX_PAGE)
	{
		tree[PAGE_ALL + index_offset].ob_state |= SELECTED;
		tree[PAGE_SELECT + index_offset].ob_state &= ~SELECTED;
		tree[PAGE_FROM + index_offset].ob_state |= DISABLED;
		tree[PAGE_TO + index_offset].ob_state |= DISABLED;
		tree[PAGE_FROM + index_offset].ob_flags &= ~EDITABLE;
		tree[PAGE_TO + index_offset].ob_flags &= ~EDITABLE;
		tree[PAGE_FROM + index_offset].ob_spec.tedinfo->te_ptext[0] = '\0';
		tree[PAGE_TO + index_offset].ob_spec.tedinfo->te_ptext[0] = '\0';
	} else
	{
		tree[PAGE_SELECT + index_offset].ob_state |= SELECTED;
		tree[PAGE_ALL + index_offset].ob_state &= ~SELECTED;
		tree[PAGE_FROM + index_offset].ob_state &= ~DISABLED;
		tree[PAGE_TO + index_offset].ob_state &= ~DISABLED;
		tree[PAGE_FROM + index_offset].ob_flags |= EDITABLE;
		tree[PAGE_TO + index_offset].ob_flags |= EDITABLE;
		itoa(settings->first_page, tree[PAGE_FROM + index_offset].ob_spec.tedinfo->te_ptext, 10);
		itoa(settings->last_page, tree[PAGE_TO + index_offset].ob_spec.tedinfo->te_ptext, 10);
	}
	if (settings->page_flags & PG_EVEN_PAGES)
		tree[PAGE_EVEN + index_offset].ob_state |= SELECTED;
	else
		tree[PAGE_EVEN + index_offset].ob_state &= ~SELECTED;
	if (settings->page_flags & PG_ODD_PAGES)
		tree[PAGE_ODD + index_offset].ob_state |= SELECTED;
	else
		tree[PAGE_ODD + index_offset].ob_state &= ~SELECTED;
	if (sub->option_flags & PDLG_EVENODD)
	{
		tree[PAGE_EVEN + index_offset].ob_state &= ~DISABLED;
		tree[PAGE_ODD + index_offset].ob_state &= ~DISABLED;
	} else
	{
		tree[PAGE_EVEN + index_offset].ob_state |= DISABLED;
		tree[PAGE_ODD + index_offset].ob_state |= DISABLED;
	}
	if ((printer->printer_capabilities & PC_COPIES) || (sub->option_flags & PDLG_ALWAYS_COPIES))
	{
		tree[PAGE_COPIES + index_offset].ob_state &= ~DISABLED;
		tree[PAGE_COPIES + index_offset].ob_flags |= EDITABLE;
	} else
	{
		tree[PAGE_COPIES + index_offset].ob_state |= DISABLED;
		tree[PAGE_COPIES + index_offset].ob_flags &= ~EDITABLE;
	}
	return TRUE;
}


static LONG _CDECL do_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	WORD index_offset = sub->index_offset;
	WORD cursor;
	
	switch (exit_obj - index_offset)
	{
	case PAGE_DEVICE_POPUP:
		return PDLG_PREBUTTON | PDLG_PB_DEVICE;
	case PAGE_QUAL_POPUP:
		do_qual_popup(settings, sub, exit_obj);
		break;
	case PAGE_COLOR_POPUP:
		do_color_popup(settings, sub, exit_obj);
		break;
	case PAGE_ALL:
		sub->tree[PAGE_FROM + index_offset].ob_state |= DISABLED;
		sub->tree[PAGE_TO + index_offset].ob_state |= DISABLED;
		sub->tree[PAGE_FROM + index_offset].ob_flags &= ~EDITABLE;
		sub->tree[PAGE_TO + index_offset].ob_flags &= ~EDITABLE;
		pdlg_redraw_obj(sub, PAGE_FROM + index_offset);
		pdlg_redraw_obj(sub, PAGE_TO + index_offset);
		if (sub->dialog)
		{
			WORD obj = wdlg_get_edit(sub->dialog, &cursor) - index_offset;
			if (obj == PAGE_FROM || obj == PAGE_TO)
			{
				wdlg_set_edit(sub->dialog, ROOT);
			}
		}
		break;
	case PAGE_SELECT:
		sub->tree[PAGE_FROM + index_offset].ob_state &= ~DISABLED;
		sub->tree[PAGE_TO + index_offset].ob_state &= ~DISABLED;
		sub->tree[PAGE_FROM + index_offset].ob_flags |= EDITABLE;
		sub->tree[PAGE_TO + index_offset].ob_flags |= EDITABLE;
		pdlg_redraw_obj(sub, PAGE_FROM + index_offset);
		pdlg_redraw_obj(sub, PAGE_TO + index_offset);
		if (sub->dialog)
		{
			wdlg_set_edit(sub->dialog, PAGE_FROM + index_offset);
		}
		break;
	}
	return TRUE;
}


static LONG _CDECL reset_dlg_general(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;
	
	settings->first_page = atoi(tree[PAGE_FROM + index_offset].ob_spec.tedinfo->te_ptext);
	settings->last_page = atoi(tree[PAGE_TO + index_offset].ob_spec.tedinfo->te_ptext);
	if ((settings->first_page | settings->last_page) == 0)
	{
		settings->first_page = PG_MIN_PAGE;
		settings->last_page = PG_MAX_PAGE;
	}
	settings->no_copies = atoi(tree[PAGE_COPIES + index_offset].ob_spec.tedinfo->te_ptext);
	if (tree[PAGE_ALL + index_offset].ob_state & SELECTED)
	{
		settings->first_page = PG_MIN_PAGE;
		settings->last_page = PG_MAX_PAGE;
	}
	settings->page_flags &= ~PG_EVEN_PAGES;
	if (tree[PAGE_EVEN + index_offset].ob_state & SELECTED)
		settings->page_flags |= PG_EVEN_PAGES;
	settings->page_flags &= ~PG_ODD_PAGES;
	if (tree[PAGE_ODD + index_offset].ob_state & SELECTED)
		settings->page_flags |= PG_ODD_PAGES;
	return TRUE;
}


static LONG _CDECL init_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree;
	WORD index_offset;
	
	tree = sub->tree;
	index_offset = sub->index_offset;
	
	set_tedinfo(tree, PAPER_DEVICE_POPUP + index_offset, get_printer((XDRV_ENTRY *)sub->drivers, settings)->name, 2);
	set_paper_size(sub, settings);
	set_media_type(sub, settings);
	set_input_tray(sub, settings);
	set_output_tray(sub, settings);
	set_orientation(sub, settings);
	set_scale(sub, settings);
	
	return TRUE;
}


static LONG _CDECL do_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	switch (exit_obj - sub->index_offset)
	{
	case PAPER_DEVICE_POPUP:
		return PDLG_PREBUTTON | PDLG_PB_DEVICE;
	case PAPER_SIZE_POPUP:
		do_size_popup(settings, sub, exit_obj);
		break;
	case PAPER_QUAL_POPUP:
		do_paperqual_popup(settings, sub, exit_obj);
		break;
	case PAPER_INTRAY_POPUP:
		do_intray_popup(settings, sub, exit_obj);
		break;
	case PAPER_OUTTRAY_POPUP:
		do_outtray_popup(settings, sub, exit_obj);
		break;
	case PAPER_PORTRAIT:
		settings->orientation = PG_PORTRAIT;
		break;
	case PAPER_LANDSCAPE:
		settings->orientation = PG_LANDSCAPE;
		break;
	}
	return TRUE;
}


static LONG _CDECL reset_dlg_paper(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;

	settings->scale = atoi(tree[PAPER_SCALE + index_offset].ob_spec.tedinfo->te_ptext);
	settings->scale <<= 16;
	settings->scale += 50;
	settings->scale /= 100;
	
	return TRUE;
}


static LONG _CDECL init_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;
	PRN_ENTRY *printer;
	PRN_MODE *mode;
	WORD w;
	fixed val;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
 	mode = get_mode((XDRV_ENTRY *)sub->drivers, settings);
 	
	set_tedinfo(tree, COLOR_DEVICE_POPUP + index_offset, printer->name, 2);
	set_dither_mode(sub, settings);

	w = tree[COLOR_BRIGHTNESS_BAR + index_offset].ob_width - tree[COLOR_BRIGHTNESS_SLIDER + index_offset].ob_width;
	val = settings->brightness * 1000;
	val >>= 16;
	val += -500;
	val *= w;
	val /= 1000;
	tree[COLOR_BRIGHTNESS_SLIDER + index_offset].ob_x = (WORD)val;

	w = tree[COLOR_CONTRAST_BAR + index_offset].ob_width - tree[COLOR_CONTRAST_SLIDER + index_offset].ob_width;
	val = settings->contrast * 1000;
	val >>= 16;
	val += -500;
	val *= w;
	val /= 1000;
	tree[COLOR_CONTRAST_SLIDER + index_offset].ob_x = (WORD)val;
	
	if (settings->plane_flags & PLANE_CYAN)
		tree[COLOR_CYAN + index_offset].ob_state |= SELECTED;
	else
		tree[COLOR_CYAN + index_offset].ob_state &= ~SELECTED;
	if (settings->plane_flags & PLANE_MAGENTA)
		tree[COLOR_MAGENTA + index_offset].ob_state |= SELECTED;
	else
		tree[COLOR_MAGENTA + index_offset].ob_state &= ~SELECTED;
	if (settings->plane_flags & PLANE_YELLOW)
		tree[COLOR_YELLOW + index_offset].ob_state |= SELECTED;
	else
		tree[COLOR_YELLOW + index_offset].ob_state &= ~SELECTED;
	if (settings->plane_flags & PLANE_BLACK)
		tree[COLOR_BLACK + index_offset].ob_state |= SELECTED;
	else
		tree[COLOR_BLACK + index_offset].ob_state &= ~SELECTED;
	
	if (mode && (mode->mode_capabilities & MC_SLCT_CMYK) && (settings->color_mode & CC_ANY_COLOR) != 0)
	{
		tree[COLOR_CYAN + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_YELLOW + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_MAGENTA + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_BLACK + index_offset].ob_state &= ~DISABLED;
	} else
	{
		tree[COLOR_CYAN + index_offset].ob_state |= DISABLED;
		tree[COLOR_YELLOW + index_offset].ob_state |= DISABLED;
		tree[COLOR_MAGENTA + index_offset].ob_state |= DISABLED;
		tree[COLOR_BLACK + index_offset].ob_state |= DISABLED;
	}
	if (mode && (mode->mode_capabilities & MC_CTRST_BRGHT) && (settings->color_mode & CC_ANY_BRIGHT) != 0)
	{
		tree[COLOR_BRIGHTNESS_IMAGE + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_CONTRAST_IMAGE + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_BRIGHTNESS_BAR + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_BRIGHTNESS_SLIDER + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_CONTRAST_BAR + index_offset].ob_state &= ~DISABLED;
		tree[COLOR_CONTRAST_SLIDER + index_offset].ob_state &= ~DISABLED;
	} else
	{
		tree[COLOR_BRIGHTNESS_IMAGE + index_offset].ob_state |= DISABLED;
		tree[COLOR_CONTRAST_IMAGE + index_offset].ob_state |= DISABLED;
		tree[COLOR_BRIGHTNESS_BAR + index_offset].ob_state |= DISABLED;
		tree[COLOR_BRIGHTNESS_SLIDER + index_offset].ob_state |= DISABLED;
		tree[COLOR_CONTRAST_BAR + index_offset].ob_state |= DISABLED;
		tree[COLOR_CONTRAST_SLIDER + index_offset].ob_state |= DISABLED;
	}
		
	return TRUE;
}


static LONG _CDECL do_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	fixed w;
	
	switch (exit_obj - sub->index_offset)
	{
	case COLOR_DEVICE_POPUP:
		return PDLG_PREBUTTON | PDLG_PB_DEVICE;
	case COLOR_DITHER_POPUP:
		do_dither_popup(settings, sub, exit_obj);
		break;
	case COLOR_BRIGHTNESS_SLIDER:
		if (!(sub->tree[exit_obj].ob_state & DISABLED))
		{
			w = slider_val(sub->dialog, sub->tree, COLOR_BRIGHTNESS_BAR + sub->index_offset, exit_obj) + 500;
			settings->brightness = (w << 16) / 1000;
		}
		break;
	case COLOR_CONTRAST_SLIDER:
		if (!(sub->tree[exit_obj].ob_state & DISABLED))
		{
			w = slider_val(sub->dialog, sub->tree, COLOR_CONTRAST_BAR + sub->index_offset, exit_obj) + 500;
			settings->contrast = (w << 16) / 1000;
		}
		break;
	}
	return TRUE;
}


static LONG _CDECL reset_dlg_color(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;

	if (tree[COLOR_CYAN + index_offset].ob_state & SELECTED)
		settings->plane_flags |= PLANE_CYAN;
	else
		settings->plane_flags &= ~PLANE_CYAN;
	if (tree[COLOR_MAGENTA + index_offset].ob_state & SELECTED)
		settings->plane_flags |= PLANE_MAGENTA;
	else
		settings->plane_flags &= ~PLANE_MAGENTA;
	if (tree[COLOR_YELLOW + index_offset].ob_state & SELECTED)
		settings->plane_flags |= PLANE_YELLOW;
	else
		settings->plane_flags &= ~PLANE_YELLOW;
	if (tree[COLOR_BLACK + index_offset].ob_state & SELECTED)
		settings->plane_flags |= PLANE_BLACK;
	else
		settings->plane_flags &= ~PLANE_BLACK;
	return TRUE;
}



static LONG _CDECL init_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;
	PRN_ENTRY *printer;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	set_tedinfo(tree, DEVICE_DEVICE_POPUP + index_offset, printer->name, 2);
	set_device(sub, settings);
	if (printer->printer_capabilities & PC_BACKGROUND)
	{
		tree[DEVICE_BACKGROUND + index_offset].ob_state &= ~DISABLED;
		tree[DEVICE_FOREGROUND + index_offset].ob_state &= ~DISABLED;
		if (settings->driver_mode & DM_BG_PRINTING)
			tree[DEVICE_BACKGROUND + index_offset].ob_state |= SELECTED;
		else
			tree[DEVICE_FOREGROUND + index_offset].ob_state |= SELECTED;
	} else
	{
		tree[DEVICE_BACKGROUND + index_offset].ob_state |= DISABLED;
		tree[DEVICE_FOREGROUND + index_offset].ob_state |= DISABLED;
		tree[DEVICE_FOREGROUND + index_offset].ob_state |= SELECTED;
	}
	return TRUE;
}


static LONG _CDECL do_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	switch (exit_obj - sub->index_offset)
	{
	case DEVICE_DEVICE_POPUP:
		return PDLG_PREBUTTON | PDLG_PB_DEVICE;
	case DEVICE_NAME_POPUP:
		do_device_popup(settings, sub, exit_obj);
		break;
	}
	return TRUE;
}


static LONG _CDECL reset_dlg_device(PRN_SETTINGS *settings, PDLG_SUB *sub)
{
	OBJECT *tree = sub->tree;
	WORD index_offset = sub->index_offset;

	if (tree[DEVICE_BACKGROUND + index_offset].ob_state & SELECTED)
		settings->driver_mode |= DM_BG_PRINTING;
	else
		settings->driver_mode &= ~DM_BG_PRINTING;
	return TRUE;
}


static void validate_dialog(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	validate_mode(drv_info, settings, settings->mode_hdpi, settings->mode_vdpi, settings->mode_id);
	validate_color_mode(drv_info, settings, settings->color_mode);
	validate_paper_size(drv_info, settings);
	validate_media_type(drv_info, settings);
	validate_input_tray(drv_info, settings);
	validate_output_tray(drv_info, settings);
	validate_orientation(drv_info, settings);
	validate_scale(drv_info, settings);
	validate_dither_mode(drv_info, settings);
	validate_device(drv_info, settings);
}


LONG __CDECL pdlg_std_setup(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer)
{
	validate_dialog((XDRV_ENTRY *)drivers, settings);
	UNUSED(old_printer);
	UNUSED(new_printer);
	return TRUE;
}


LONG __CDECL pdlg_std_close(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer)
{
	validate_dialog((XDRV_ENTRY *)drivers, settings);
	UNUSED(old_printer);
	UNUSED(new_printer);
	return TRUE;
}


static WORD slider_val(DIALOG *dialog, OBJECT *tree, WORD obj, WORD exit_button)
{
	EVNTDATA ev;
	WORD w = tree[obj].ob_width;
	WORD y;
	GRECT gr;
	WORD x;
	WORD dw;
	WORD bstate;
	
	w -= tree[exit_button].ob_width;
	gr.g_w = tree[exit_button].ob_width;
	gr.g_h = tree[exit_button].ob_height;
	do
	{
		objc_offset(tree, obj, &x, &y);
		objc_offset(tree, exit_button, &gr.g_x, &gr.g_y);
		graf_mkstate_event(&ev);
		dw = ev.x;
		bstate = ev.bstate;
		dw -= gr.g_w / 2 + x;
		if (dw < 0)
			dw = 0;
		if (dw > w)
			dw = w;
		dw &= ~1;
		dw -= tree[exit_button].ob_x;
		if (dw != 0)
		{
			wind_update(BEG_UPDATE);
			tree[exit_button].ob_x += dw;
			if (dialog)
			{
				wdlg_redraw(dialog, &gr, ROOT, MAX_DEPTH);
				gr.g_x += dw;
				wdlg_redraw(dialog, &gr, ROOT, MAX_DEPTH);
			} else
			{
				objc_draw_grect(tree, ROOT, MAX_DEPTH, &gr);
				gr.g_x += dw;
				objc_draw_grect(tree, ROOT, MAX_DEPTH, &gr);
			}
			wind_update(END_UPDATE);
		}
		_appl_yield();
	} while (bstate == 1);
	return (WORD)((tree[exit_button].ob_x * 1000L) / w);
}


int do_qual_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	PRN_ENTRY *printer;
	WORD count;
	WORD selected;
	char **names;
	PRN_MODE *mode;
	char **namep;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	count = list_count(printer->modes);
	names = Malloc(count * sizeof(char *));
	if (names != NULL)
	{
		namep = names;
		selected = 0;
		for (mode = printer->modes; mode != NULL; mode = mode->next)
		{
			if (mode->mode_id == settings->mode_id)
			{
				selected = (WORD)(namep - names);
			}
			*namep++ = mode->name;
		}
		selected = simple_popup(sub->tree, exit_obj, names, count, selected);
		Mfree(names);
		if (selected >= 0)
		{
			mode = list_nth(printer->modes, selected);
			if (mode->mode_id != settings->mode_id)
			{
				settings->mode_id = mode->mode_id;
				settings->mode_hdpi = mode->hdpi;
				settings->mode_vdpi = mode->vdpi;
				set_tedinfo(sub->tree, exit_obj, mode->name, 2);
				pdlg_redraw_obj(sub, exit_obj);
				set_color(sub, settings, settings->color_mode);
				pdlg_redraw_obj(sub, PAGE_COLOR_POPUP + sub->index_offset);
				validate_media_type((XDRV_ENTRY *)sub->drivers, settings);
				validate_dither_mode((XDRV_ENTRY *)sub->drivers, settings);
				return TRUE;
			}
		}
	}
	return FALSE;
}


int do_color_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	LONG color_capabilities;
	WORD selected;
	WORD i, count;
	const char *names[NO_CC_BITS];
	LONG vals[NO_CC_BITS];
	const char **namep;
	
	{
		PRN_MODE *mode = get_mode((XDRV_ENTRY *)sub->drivers, settings);
		if (mode == NULL)
			return FALSE;
		color_capabilities = mode->color_capabilities;
	}
	namep = names;
	for (i = selected = count = 0; i < NO_CC_BITS; i++)
	{
		if (color_capabilities & 1)
		{
			vals[count] = 1L << i;
			if (vals[count] == settings->color_mode)
				selected = count;
			*namep++ = color_cap_names[i];
			count++;
		}
		color_capabilities >>= 1;
	}
	selected = simple_popup(sub->tree, exit_obj, names, count, selected);
	if (selected >= 0 && settings->color_mode != vals[selected])
	{
		set_color(sub, settings, vals[selected]);
		pdlg_redraw_obj(sub, exit_obj);
		return TRUE;
	}
	return FALSE;
}


static int do_size_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	PRN_ENTRY *printer;
	WORD count;
	WORD selected;
	char **names;
	MEDIA_SIZE *size;
	char **namep;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	size = printer->papers;
	if (size != NULL)
	{
		count = list_count(size);
		names = Malloc(count * sizeof(char *));
		if (names != NULL)
		{
			namep = names;
			selected = 0;
			while (size != NULL)
			{
				if (size->size_id == settings->size_id)
				{
					selected = (WORD)(namep - names);
				}
				*namep++ = size->name;
				size = size->next;
			}
			selected = simple_popup(sub->tree, exit_obj, names, count, selected);
			Mfree(names);
			if (selected >= 0)
			{
				size = list_nth(printer->papers, selected);
				if (size->size_id != settings->size_id)
				{
					settings->size_id = size->size_id;
					set_tedinfo(sub->tree, exit_obj, size->name, 2);
					pdlg_redraw_obj(sub, exit_obj);
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}


static int do_paperqual_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	PRN_MODE *mode;
	WORD count;
	WORD selected;
	char **names;
	MEDIA_TYPE *type;
	char **namep;
	
	mode = get_mode((XDRV_ENTRY *)sub->drivers, settings);
	if (mode != NULL && mode->paper_types != NULL)
	{
		type = mode->paper_types;
		count = list_count(type);
		names = Malloc(count * sizeof(char *));
		if (names != NULL)
		{
			namep = names;
			selected = 0;
			while (type != NULL)
			{
				if (type->type_id == settings->type_id)
				{
					selected = (WORD)(namep - names);
				}
				*namep++ = type->name;
				type = type->next;
			}
			selected = simple_popup(sub->tree, exit_obj, names, count, selected);
			Mfree(names);
			if (selected >= 0)
			{
				type = list_nth(mode->paper_types, selected);
				if (type->type_id != settings->type_id)
				{
					settings->type_id = type->type_id;
					set_tedinfo(sub->tree, exit_obj, type->name, 2);
					pdlg_redraw_obj(sub, exit_obj);
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}


static int do_intray_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	PRN_ENTRY *printer;
	WORD count;
	WORD selected;
	char **names;
	PRN_TRAY *tray;
	char **namep;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	if (printer->input_trays != NULL)
	{
		tray = printer->input_trays;
		count = list_count(tray);
		names = Malloc(count * sizeof(char *));
		if (names != NULL)
		{
			namep = names;
			selected = 0;
			while (tray != NULL)
			{
				if (tray->tray_id == settings->input_id)
				{
					selected = (WORD)(namep - names);
				}
				*namep++ = tray->name;
				tray = tray->next;
			}
			selected = simple_popup(sub->tree, exit_obj, names, count, selected);
			Mfree(names);
			if (selected >= 0)
			{
				tray = list_nth(printer->input_trays, selected);
				if (tray->tray_id != settings->input_id)
				{
					settings->input_id = tray->tray_id;
					set_tedinfo(sub->tree, exit_obj, tray->name, 2);
					pdlg_redraw_obj(sub, exit_obj);
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}


static int do_outtray_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	PRN_ENTRY *printer;
	WORD count;
	WORD selected;
	char **names;
	PRN_TRAY *tray;
	char **namep;
	
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	if (printer->output_trays != NULL)
	{
		tray = printer->output_trays;
		count = list_count(tray);
		names = Malloc(count * sizeof(char *));
		if (names != NULL)
		{
			namep = names;
			selected = 0;
			while (tray != NULL)
			{
				if (tray->tray_id == settings->output_id)
				{
					selected = (WORD)(namep - names);
				}
				*namep++ = tray->name;
				tray = tray->next;
			}
			selected = simple_popup(sub->tree, exit_obj, names, count, selected);
			Mfree(names);
			if (selected >= 0)
			{
				tray = list_nth(printer->output_trays, selected);
				if (tray->tray_id != settings->output_id)
				{
					settings->output_id = tray->tray_id;
					set_tedinfo(sub->tree, exit_obj, tray->name, 2);
					pdlg_redraw_obj(sub, exit_obj);
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}


static int do_dither_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	XDRV_ENTRY *driver;
	WORD count;
	WORD selected;
	char **names;
	DITHER_MODE *mode;
	char **namep;
	
	driver = get_driver((XDRV_ENTRY *)sub->drivers, settings);
	if (driver == NULL)
		return FALSE;
	mode = driver->dither_modes;
	if (mode != NULL)
	{
		count = list_count(mode);
		names = Malloc(count * sizeof(char *));
		if (names != NULL)
		{
			namep = names;
			selected = 0;
			while (mode != NULL)
			{
				if ((mode->color_modes & settings->color_mode) != 0)
				{
					if (mode->dither_id == settings->dither_mode)
					{
						selected = (WORD)(namep - names);
					}
					*namep++ = mode->name;
				} else
				{
					count--;
				}
				mode = mode->next;
			}
			if (count > 0)
				selected = simple_popup(sub->tree, exit_obj, names, count, selected);
			else
				selected = -1;
			Mfree(names);
			if (selected >= 0)
			{
				mode = list_nth(driver->dither_modes, selected);
				if (mode->dither_id != settings->dither_mode)
				{
					settings->dither_mode = mode->dither_id;
					set_tedinfo(sub->tree, exit_obj, mode->name, 2);
					pdlg_redraw_obj(sub, exit_obj);
					return TRUE;
				}
			}
		}
	}
	return FALSE;
}


static int do_device_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, WORD exit_obj)
{
	WORD selected;
	const char *names[5];
	const char *device_names[5];
	{
	PRN_ENTRY *printer;
	LONG printer_capabilities;
	const char **namep;
	const char **device_namep;
	
	namep = names;
	device_namep = device_names;
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	if (printer)
		printer_capabilities = printer->printer_capabilities;
	else
		printer_capabilities = 0;
	if (printer_capabilities & PC_PARALLEL)
	{
		*namep++ = S_PARALLEL_DEVICE;
		*device_namep++ = PRN_DEVICE;
	}
	if (printer_capabilities & PC_SERIAL)
	{
		*namep++ = S_SERIAL_DEVICE;
		*device_namep++ = AUX_DEVICE;
	}
	if (printer_capabilities & PC_ACSI)
	{
		*namep++ = S_ACSI_DEVICE;
		*device_namep++ = ACSI_DEVICE;
	}
	if (printer_capabilities & PC_SCSI)
	{
		*namep++ = S_SCSI_DEVICE;
		*device_namep++ = SCSI_DEVICE;
	}
	if (printer_capabilities & PC_FILE)
	{
		*namep++ = S_FILE_OUTPUT;
		*device_namep++ = "";
	}
	if (namep <= names)
		return FALSE;
	selected = simple_popup(sub->tree, exit_obj, names, (WORD)(namep - names), NIL);
	}
	if (selected >= 0)
	{
		if (device_names[selected][0] != '\0')
		{
			vstrcpy(settings->device, device_names[selected]);
		} else
		{
			char *slash;
			char path[128];
			char filename[128];
			WORD button;
			
			vstrcpy(path, settings->device);
			slash = strrchr(path, '\\');
			if (slash)
			{
				++slash;
				vstrcpy(filename, slash);
				*slash = '\0';
			} else
			{
				vstrcpy(filename, path);
				*path = '\0';
			}
			wind_update(BEG_UPDATE);
			strcat(path, "*.*");
			/* FIXME: should use fslx_() functions if available */
			if (aes_global[0] >= 0x140)
			{
				selected = mt_fsel_exinput(path, filename, &button, S_FILE_TITLE, NULL);
			} else
			{
				selected = mt_fsel_input(path, filename, &button, NULL);
			}
			wind_update(END_UPDATE);
			if (selected != 0 && button == 1 && filename[0] != '\0')
			{
				slash = strrchr(path, '\\');
				if (slash != NULL)
					slash[1] = '\0';
				else
					path[0] = '\0';
				strcat(path, filename);
				vstrcpy(settings->device, path);
			}
		}
		set_device(sub, settings);
		if (sub->dialog)
			pdlg_redraw_obj(sub, exit_obj);
		else
			pdlg_redraw_obj(sub, ROOT);
		return TRUE;
	}
	return FALSE;
}


XDRV_ENTRY *get_driver(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	XDRV_ENTRY *d = get_driver_info(drv_info, settings->driver_id);
	if (d == NULL)
		d = drv_info;
	return d;
}


PRN_ENTRY *get_printer(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_ENTRY *p = find_printer(drv_info, settings->driver_id, settings->printer_id);
	if (p == NULL)
	{
		p = get_driver(drv_info, settings)->printers;
	}
	return p;
}


PRN_MODE *get_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_ENTRY *p = get_printer(drv_info, settings);
	PRN_MODE *mode = find_mode(p, settings->mode_id);
	if (mode == NULL)
		mode = p->modes;
	return mode;
}


MEDIA_SIZE *get_paper_size(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_ENTRY *p = get_printer(drv_info, settings);
	MEDIA_SIZE *size = find_paper_size(p, settings->size_id);
	if (size == NULL)
		size = p->papers;
	return size;
}


MEDIA_TYPE *get_media_type(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_MODE *mode = get_mode(drv_info, settings);
	MEDIA_TYPE *type;
	
	if (mode != NULL)
	{
		type = find_media_type(mode, settings->type_id);
		if (type == NULL)
			type = mode->paper_types;
	} else
	{
		type = NULL;
	}
	return type;
}


PRN_TRAY *get_input_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_ENTRY *p = get_printer(drv_info, settings);
	PRN_TRAY *tray = find_input_tray(p, settings->input_id);
	if (tray == NULL)
		tray = p->input_trays;
	return tray;
}


PRN_TRAY *get_output_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_ENTRY *p = get_printer(drv_info, settings);
	PRN_TRAY *tray = find_output_tray(p, settings->output_id);
	if (tray == NULL)
		tray = p->output_trays;
	return tray;
}


XDRV_ENTRY *get_driver_info(XDRV_ENTRY *drv_info, WORD id)
{
	while (drv_info != 0)
	{
		if (drv_info->driver_id == id)
			break;
		drv_info = drv_info->next;
	}
	return drv_info;
}


PRN_ENTRY *find_printer(XDRV_ENTRY *drv_info, WORD id, LONG printer_id)
{
	PRN_ENTRY *printer;
	
	while (drv_info)
	{
		if (drv_info->driver_id == id)
		{
			printer = drv_info->printers;
			while (printer)
			{
				if (printer->printer_id == printer_id)
					return printer;
				printer = printer->next;
			}
		}
		drv_info = drv_info->next;
	}
	return NULL;
}


PRN_MODE *find_mode(PRN_ENTRY *p, LONG id)
{
	PRN_MODE *mode = p->modes;
	
	while (mode != NULL)
	{
		if (mode->mode_id == id)
			break;
		mode = mode->next;
	}
	return mode;
}


MEDIA_SIZE *find_paper_size(PRN_ENTRY *p, LONG id)
{
	MEDIA_SIZE *size = p->papers;
	
	while (size != NULL)
	{
		if (size->size_id == id)
			break;
		size = size->next;
	}
	return size;
}


MEDIA_TYPE *find_media_type(PRN_MODE *mode, LONG id)
{
	MEDIA_TYPE *type = mode->paper_types;
	
	while (type != NULL)
	{
		if (type->type_id == id)
			break;
		type = type->next;
	}
	return type;
}


PRN_TRAY *find_input_tray(PRN_ENTRY *p, LONG id)
{
	PRN_TRAY *tray = p->input_trays;
	
	while (tray != NULL)
	{
		if (tray->tray_id == id)
			break;
		tray = tray->next;
	}
	return tray;
}


PRN_TRAY *find_output_tray(PRN_ENTRY *p, LONG id)
{
	PRN_TRAY *tray = p->output_trays;
	
	while (tray != NULL)
	{
		if (tray->tray_id == id)
			break;
		tray = tray->next;
	}
	return tray;
}


PRN_MODE *validate_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings, WORD hdpi, WORD vdpi, LONG id)
{
	PRN_MODE *mode = get_printer(drv_info, settings)->modes;
	
	while (mode)
	{
		if (mode->mode_id == id && mode->hdpi == hdpi && mode->vdpi == vdpi)
			break;
		mode = mode->next;
	}
	if (mode == NULL)
	{
		mode = get_printer(drv_info, settings)->modes;
		while (mode != NULL)
		{
			if (mode->hdpi == hdpi && mode->vdpi == vdpi)
				break;
			mode = mode->next;
		}
		if (mode == NULL)
			mode = get_printer(drv_info, settings)->modes;
	}
	if (mode != NULL)
	{
		settings->mode_id = mode->mode_id;
		settings->mode_hdpi = mode->hdpi;
		settings->mode_vdpi = mode->vdpi;
	}
	return mode;
}


void set_mode(PDLG_SUB *sub, PRN_SETTINGS *settings, WORD hdpi, WORD vdpi, LONG mode_id)
{
	PRN_MODE *mode = validate_mode((XDRV_ENTRY *)sub->drivers, settings, hdpi, vdpi, mode_id);
	if (mode != NULL)
	{
		set_tedinfo(sub->tree, PAGE_QUAL_POPUP + sub->index_offset, mode->name, 2);
	} else
	{
		empty_tedinfo(sub->tree, PAGE_QUAL_POPUP + sub->index_offset);
	}
}


void validate_color_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings, LONG color_mode)
{
	if (get_mode(drv_info, settings) != NULL)
	{
		LONG caps;
		
		caps = get_mode(drv_info, settings)->color_capabilities;
		if ((caps & color_mode) == 0)
		{
			WORD i;
			
			color_mode = 0;
			for (i = 0; i < NO_CC_BITS; i++)
			{
				if (caps & 1)
				{
					color_mode = 1L << i;
					break;
				}
				caps >>= 1;
			}
			if (color_mode == 0)
				color_mode = CC_MONO;
		}
		settings->color_mode = color_mode;
	}
}


void set_color(PDLG_SUB *sub, PRN_SETTINGS *settings, LONG color_mode)
{
	WORD i;
	
	validate_color_mode((XDRV_ENTRY *)sub->drivers, settings, color_mode);
	color_mode = settings->color_mode;
	empty_tedinfo(sub->tree, PAGE_COLOR_POPUP + sub->index_offset);
	if (get_mode((XDRV_ENTRY *)sub->drivers, settings) != NULL)
	{
		for (i = 0; i < NO_CC_BITS; i++)
		{
			if (color_mode & 1)
			{
				set_tedinfo(sub->tree, PAGE_COLOR_POPUP + sub->index_offset, color_cap_names[i], 2);
				break;
			}
			color_mode >>= 1;
		}
	}
}


MEDIA_SIZE *validate_paper_size(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	MEDIA_SIZE *size = get_paper_size(drv_info, settings);
	if (size)
		settings->size_id = size->size_id;
	else
		settings->size_id = 0;
	return size;
}


static void set_paper_size(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	MEDIA_SIZE *size = validate_paper_size((XDRV_ENTRY *)sub->drivers, settings);
	if (size)
		set_tedinfo(sub->tree, PAPER_SIZE_POPUP + sub->index_offset, size->name, 2);
	else
		empty_tedinfo(sub->tree, PAPER_SIZE_POPUP + sub->index_offset);
}


MEDIA_TYPE *validate_media_type(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	MEDIA_TYPE *type = get_media_type(drv_info, settings);
	if (type)
		settings->type_id = type->type_id;
	else
		settings->type_id = 0;
	return type;
}


static void set_media_type(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	MEDIA_TYPE *type = validate_media_type((XDRV_ENTRY *)sub->drivers, settings);
	if (type)
		set_tedinfo(sub->tree, PAPER_QUAL_POPUP + sub->index_offset, type->name, 2);
	else
		empty_tedinfo(sub->tree, PAPER_QUAL_POPUP + sub->index_offset);
}


PRN_TRAY *validate_input_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_TRAY *tray = get_input_tray(drv_info, settings);
	if (tray)
		settings->input_id = tray->tray_id;
	else
		settings->input_id = 0;
	return tray;
}


static void set_input_tray(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	PRN_TRAY *tray = validate_input_tray((XDRV_ENTRY *)sub->drivers, settings);
	if (tray)
		set_tedinfo(sub->tree, PAPER_INTRAY_POPUP + sub->index_offset, tray->name, 2);
	else
		empty_tedinfo(sub->tree, PAPER_INTRAY_POPUP + sub->index_offset);
}


PRN_TRAY *validate_output_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_TRAY *tray = get_output_tray(drv_info, settings);
	if (tray)
		settings->output_id = tray->tray_id;
	else
		settings->output_id = 0;
	return tray;
}


static void set_output_tray(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	PRN_TRAY *tray = validate_output_tray((XDRV_ENTRY *)sub->drivers, settings);
	if (tray)
		set_tedinfo(sub->tree, PAPER_OUTTRAY_POPUP + sub->index_offset, tray->name, 2);
	else
		empty_tedinfo(sub->tree, PAPER_OUTTRAY_POPUP + sub->index_offset);
}


WORD validate_orientation(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	PRN_MODE *mode = get_mode(drv_info, settings);
	
	if (mode != NULL && (mode->mode_capabilities & MC_ORIENTATION))
	{
		WORD orient;
		
		if ((settings->orientation & mode->mode_capabilities) == 0)
		{
			settings->orientation = PG_UNKNOWN;
			orient = PG_PORTRAIT;
			while (orient <= MC_REV_LNDSCP)
			{
				if ((orient & mode->mode_capabilities) != 0)
				{
					settings->orientation = orient;
					break;
				}
				orient += orient;
			}
		}
	}
	return settings->orientation;
}


static void set_orientation(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	PRN_MODE *mode;
	OBJECT *tree;
	WORD index_offset;
	
	validate_orientation((XDRV_ENTRY *)sub->drivers, settings);
	mode = get_mode((XDRV_ENTRY *)sub->drivers, settings);
	tree = sub->tree;
	index_offset = sub->index_offset;
	if (sub->option_flags & PDLG_ALWAYS_ORIENT)
	{
		tree[PAPER_PORTRAIT + index_offset].ob_state &= ~DISABLED;
		tree[PAPER_LANDSCAPE + index_offset].ob_state &= ~DISABLED;
	} else
	{
		tree[PAPER_PORTRAIT + index_offset].ob_state |= DISABLED;
		tree[PAPER_LANDSCAPE + index_offset].ob_state |= DISABLED;
		if (mode != NULL)
		{
			if (mode->mode_capabilities & MC_PORTRAIT)
				tree[PAPER_PORTRAIT + index_offset].ob_state &= ~DISABLED;
			if (mode->mode_capabilities & MC_LANDSCAPE)
				tree[PAPER_LANDSCAPE + index_offset].ob_state &= ~DISABLED;
		}
	}
	if (settings->orientation == PG_PORTRAIT)
		tree[PAPER_PORTRAIT + index_offset].ob_state |= SELECTED;
	if (settings->orientation == PG_LANDSCAPE)
		tree[PAPER_LANDSCAPE + index_offset].ob_state |= SELECTED;
}


void validate_scale(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	UNUSED(drv_info);
	if (settings->scale > 0x9fd70L)
		settings->scale = 0x9fd70L;
	if (settings->scale < 0x00cccL)
		settings->scale = 0x00cccL;
}


static void set_scale(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	OBJECT *tree;
	WORD index_offset;
	PRN_ENTRY *printer;
	char buf[16];
	
	validate_scale((XDRV_ENTRY *)sub->drivers, settings);
	printer = get_printer((XDRV_ENTRY *)sub->drivers, settings);
	tree = sub->tree;
	index_offset = sub->index_offset;
	if ((printer->printer_capabilities & PC_SCALING) || (sub->option_flags & PDLG_ALWAYS_SCALE))
	{
		tree[PAPER_SCALE + index_offset].ob_state &= ~DISABLED;
		tree[PAPER_SCALE + index_offset].ob_flags |= EDITABLE;
	} else
	{
		tree[PAPER_SCALE + index_offset].ob_state |= DISABLED;
		tree[PAPER_SCALE + index_offset].ob_flags &= ~EDITABLE;
	}
	itoa((int)((settings->scale * 100 + 32768L) >> 16), buf, 10);
	set_tedinfo(sub->tree, PAPER_SCALE + index_offset, buf, 0);
}


DITHER_MODE *validate_dither_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	XDRV_ENTRY *d = get_driver(drv_info, settings);
	PRN_MODE *mode = get_mode(drv_info, settings);
	
	if (d != NULL && mode != NULL)
	{
		LONG dither_mode = settings->dither_mode;
		DITHER_MODE *dither = d->dither_modes;
		
		if (dither != NULL)
		{
			while (dither != NULL)
			{
				if ((settings->color_mode & mode->dither_flags & dither->color_modes) != 0 &&
					dither->dither_id == dither_mode)
					return dither;
				dither = dither->next;
			}
			dither = d->dither_modes;
			while (dither != NULL)
			{
				if ((settings->color_mode & mode->dither_flags & dither->color_modes) != 0)
				{
					settings->dither_mode = dither->dither_id;
					return dither;
				}
				dither = dither->next;
			}
		}
	}
	settings->dither_mode = DC_NONE;
	return NULL;
}


static void set_dither_mode(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	DITHER_MODE *mode = validate_dither_mode((XDRV_ENTRY *)sub->drivers, settings);
	if (mode)
		set_tedinfo(sub->tree, DITHER_DITHER_POPUP + sub->index_offset, mode->name, 2);
	else
		empty_tedinfo(sub->tree, DITHER_DITHER_POPUP + sub->index_offset);
}


void validate_device(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	XDRV_ENTRY *d = get_driver(drv_info, settings);
	PRN_ENTRY *p = get_printer(drv_info, settings);
	char *device = settings->device;
	LONG check;
	LONG caps;
	
	if (d != NULL && p != NULL)
	{
		caps = p->printer_capabilities;
		
		if (strcmp(device, PRN_DEVICE) == 0)
			check = PC_PARALLEL;
		else if (strcmp(device, AUX_DEVICE) == 0)
			check = PC_SERIAL;
		else if (strcmp(device, ACSI_DEVICE) == 0)
			check = PC_ACSI;
		else if (strcmp(device, SCSI_DEVICE) == 0)
			check = PC_SCSI;
		else
			check = PC_FILE;
	} else
	{
		check = PC_PARALLEL;
		caps = 0;
	}
	if ((check & caps) == 0)
	{
		if (caps & PC_PARALLEL)
		{
			vstrcpy(device, PRN_DEVICE);
		} else if (caps & PC_SERIAL)
		{
			vstrcpy(device, AUX_DEVICE);
		} else if (caps & PC_ACSI)
		{
			vstrcpy(device, ACSI_DEVICE);
		} else if (caps & PC_SCSI)
		{
			vstrcpy(device, SCSI_DEVICE);
		} else if (caps & PC_FILE)
		{
			if (d != NULL)
				vstrcpy(device, d->device);
			else
				vstrcpy(device, "FILE.OUT");
		} else
		{
			*device = '\0';
		}
	}
	if (d != NULL)
		vstrcpy(d->device, device);
}


static void set_device(PDLG_SUB *sub, PRN_SETTINGS *settings)
{
	const char *device;
	const char *name;
	
	validate_device((XDRV_ENTRY *)sub->drivers, settings);
	device = settings->device;
	if (strcmp(device, PRN_DEVICE) == 0)
		name = S_PARALLEL_DEVICE;
	else if (strcmp(device, AUX_DEVICE) == 0)
		name = S_SERIAL_DEVICE;
	else if (strcmp(device, ACSI_DEVICE) == 0)
		name = S_ACSI_DEVICE;
	else if (strcmp(device, SCSI_DEVICE) == 0)
		name = S_SCSI_DEVICE;
	else
		name = device;
	if (*name != '\0')
		set_tedinfo(sub->tree, DEVICE_NAME_POPUP + sub->index_offset, name, 2);
	else
		empty_tedinfo(sub->tree, DEVICE_NAME_POPUP + sub->index_offset);
}


void set_tedinfo(OBJECT *tree, WORD obj, const char *str, WORD spaces)
{
	char *dst = tree[obj].ob_spec.tedinfo->te_ptext;
	
	if (str != NULL)
	{
		while (*dst != '\0' && spaces > 0)
		{
			*dst++ = ' ';
			spaces--;
		}
		while (*dst != '\0' && *str != '\0')
			*dst++ = *str++;
		if (*dst == '\0' && *str != '\0')
		{
			dst[-1] = '.';
			dst[-2] = '.';
			dst[-3] = '.';
		}
	}
	while (*dst != '\0')
		*dst++ = ' ';
}


static void empty_tedinfo(OBJECT *tree, WORD obj)
{
	char *str;
	LONG len;
	
	str = tree[obj].ob_spec.tedinfo->te_ptext;
	len = strlen(str);
	len >>= 1;
	while (*str != '\0' && len >= 0)
	{
		*str++ = ' ';
		len--;
	}
	if (*str != '\0')
		*str++ = '-';
	while (*str != '\0')
		*str++ = ' ';
}
