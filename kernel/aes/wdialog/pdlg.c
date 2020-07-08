#include "wdlgmain.h"
#include "pdlgqd.h"


static unsigned char const pdlg_rsc[] = {
#if COUNTRY == COUNTRY_DE || COUNTRY == COUNTRY_SG
#include "de\pdlg.inc"
#elif COUNTRY == COUNTRY_US || COUNTRY == COUNTRY_UK
#include "en\pdlg.inc"
#elif COUNTRY == COUNTRY_FR || COUNTRY == COUNTRY_SF
#include "fr\pdlg.inc"
#endif
};



/*
 * FIXME: these belong into the RSC file
 */
#if COUNTRY == COUNTRY_DE || COUNTRY == COUNTRY_SG

#define S_PRINTBUTTON "Drucken"
#define S_PRINTTITLE  " Drucken: "
#define S_PAPERTITLE  " Papierformat: "
#define S_OK          "OK"

#elif COUNTRY == COUNTRY_US || COUNTRY == COUNTRY_UK

#define S_PRINTBUTTON "Print"
#define S_PRINTTITLE  " Print: "
#define S_PAPERTITLE  " Paper format: "
#define S_OK          "OK"

#elif COUNTRY == COUNTRY_FR || COUNTRY == COUNTRY_SF

#define S_PRINTBUTTON "Imprimper"
#define S_PRINTTITLE  " Imprimper: "
#define S_PAPERTITLE  " Format de papier: "
#define S_OK          "OK"

#endif

static int pdlg_notequal(PDLG_SUB *s1, PDLG_SUB *s2);
static void pdlg_draw(PDLG_SUB *sub, GRECT *gr);

static WORD cdecl handle_exit(DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data);

static int create_lboxes(PRN_DIALOG *prn_dialog);
static void free_lboxes(PRN_DIALOG *prn_dialog);
static void free_printer_items(PRN_DIALOG *prn_dialog);
static int do_button(PRN_DIALOG *prn_dialog, WORD exit_button);
static int create_printer_lbox(PRN_DIALOG *prn_dialog);
static int do_device_popup(PRN_DIALOG *prn_dialog, WORD obj);
static void deselect_button(PDLG_SUB *sub, WORD obj);
static size_t tree_memsize(OBJECT *tree);
static WORD insert_panel(OBJECT *tree, OBJECT *main, WORD obj, WORD count, OBJECT *sub_tree);
static int pdlg_delete_drivers(XDRV_ENTRY **drv_info, WORD vhandle);


static void cdecl select_driver(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state);

static void init_rsrc(RSHDR *rsh, PRN_DIALOG *d, WORD dialog_flags);
static WORD cdecl set_icon_item(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD first);



static RSHDR *copy_rsrc(const RSHDR *rsc, LONG len)
{
	RSHDR *new;

	new = Malloc(len);
	
	if (new)
	{
#if CALL_MAGIC_KERNEL
		WORD dummy_global[15];

		vmemcpy(new, rsc, len);							/* Resource kopieren */
		_rsrc_rcfix(dummy_global, new);							/* Resource anpassen */
#elif PDLG_SLB
		vmemcpy(new, rsc, len);								/* Resource kopieren */
		mt_rsrc_rcfix(new, NULL);						/* Resource anpassen */
#else
		WORD dummy_global[15];

		vmemcpy(new, rsc, len);								/* Resource kopieren */
		if (aes_flags & GAI_CICN)
			mt_rsrc_rcfix(new, NULL);						/* Resource anpassen */
		else
			_rsrc_rcfix(dummy_global, new); /* NOTE: does not work, because builtin _rsrc_rcfix doesn not handle color icons */
#endif
	}
	return new;															/* Zeiger auf den Resource-Header */
}


static int init_settings(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	if (nvdi_read_default_settings(vdi_handle, settings) == 0)
	{
		settings->magic = PRN_SETTINGS_MAGIC;
		settings->length = sizeof(*settings);
		settings->format = PRN_SETTINGS_FORMAT;
		settings->reserved = 0;
		settings->page_flags = VALID_PAGE_FLAGS;
		settings->first_page = PG_MIN_PAGE;
		settings->last_page = PG_MAX_PAGE;
		settings->no_copies = PG_MIN_COPIES;
		settings->driver_id = 0;
		settings->driver_type = DRIVER_NONE;
		settings->driver_mode = 0;
		/* reserved1 */
		/* reserved2 */
		settings->printer_id = 0;
		settings->mode_id = 0;
		settings->mode_hdpi = 0;
		settings->mode_vdpi = 0;
		settings->quality_id = 0;
		settings->color_mode = CC_MONO;
		settings->plane_flags = VALID_PLANE_FLAGS;
		settings->dither_mode = DC_NONE;
		settings->dither_value = 0;
		settings->size_id = 0;
		settings->type_id = 0;
		settings->orientation = PG_UNKNOWN;
		settings->input_id = 0;
		settings->output_id = 0;
		settings->scale = 1L << 16;
		settings->contrast = 1L << 16;
		settings->brightness = 1L << 16;
		vstrcpy(settings->device, PRN_DEVICE);
		mgmc_init_settings(settings);
		if (drv_info && drv_info->printers)
		{
			PRN_ENTRY *printer;
			PRN_MODE *mode;
			XDRV_ENTRY *drv_id;
			
			printer = drv_info->printers;
			drv_id = get_driver_info(drv_info, printer->driver_id);
			if (drv_id)
			{
				mode = printer->modes;
				settings->driver_id = drv_id->driver_id;
				settings->driver_type = drv_id->driver_type;
				settings->driver_mode = 0;
				settings->printer_id = printer->printer_id;
				if (mode)
				{
					settings->mode_id = mode->mode_id;
					settings->mode_hdpi = mode->hdpi;
					settings->mode_vdpi = mode->vdpi;
					settings->quality_id = 0;
					if (printer->papers)
						settings->size_id = printer->papers->size_id;
					if (mode->paper_types)
						settings->type_id = mode->paper_types->type_id;
					settings->orientation = PG_PORTRAIT;
					if (printer->input_trays)
						settings->input_id = printer->input_trays->tray_id;
					if (printer->output_trays)
						settings->output_id = printer->output_trays->tray_id;
				}
				vstrcpy(settings->device, drv_id->device);
			}
		}
	}
	return TRUE;
}


static int validate_settings(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	XDRV_ENTRY *d;
	PRN_ENTRY *p;
	
	if (settings->magic == PRN_SETTINGS_MAGIC)
	{
		if (settings->format != PRN_SETTINGS_FORMAT)
			init_settings(drv_info, settings);
		d = get_driver(drv_info, settings);
		if (d != NULL)
		{
			settings->driver_id = d->driver_id;
			settings->driver_type = d->driver_type;
			p = get_printer(drv_info, settings);
			if (p != NULL)
			{
				settings->printer_id = p->printer_id;
				validate_mode(drv_info, settings, settings->mode_hdpi, settings->mode_vdpi, settings->mode_id);
				validate_paper_size(drv_info, settings);
				validate_media_type(drv_info, settings);
				validate_orientation(drv_info, settings);
				validate_input_tray(drv_info, settings);
				validate_output_tray(drv_info, settings);
				validate_color_mode(drv_info, settings, settings->color_mode);
				validate_dither_mode(drv_info, settings);
				validate_scale(drv_info, settings);
				validate_device(drv_info, settings);
				
				settings->plane_flags &= VALID_PLANE_FLAGS;
				settings->page_flags &= VALID_PAGE_FLAGS;
				if (settings->first_page > PG_MAX_PAGE)
					settings->first_page = PG_MAX_PAGE;
				if (settings->last_page > PG_MAX_PAGE)
					settings->last_page = PG_MAX_PAGE;
				if (settings->no_copies > PG_MAX_COPIES)
					settings->no_copies = PG_MAX_COPIES;
				if (settings->contrast <= 0x8000L)
					settings->contrast = 0x8000L;
				if (settings->contrast >= 0x18000L)
					settings->contrast = 0x18000L;
				if (settings->brightness <= 0x8000L)
					settings->brightness = 0x8000L;
				if (settings->brightness >= 0x18000L)
					settings->brightness = 0x18000L;
				
				if (strcmp(MAC_DRIVER_NAME, d->driver_name) == 0)
				{
					settings->scale = 0x10000L;
					mgmc_validate_settings(settings);
				}
				
				return TRUE;
			}
		}
	}
	return init_settings(drv_info, settings);
}


PRN_DIALOG *pdlg_create(WORD dialog_flags)
{
	PRN_DIALOG *d;
	RSHDR *rsc;
	
	mgmc_init();
	d = Malloc(sizeof(*d));
	if (d != NULL)
	{
		rsc = copy_rsrc((const RSHDR *)pdlg_rsc, sizeof(pdlg_rsc));
		if (rsc != NULL)
		{
#if CALL_MAGIC_KERNEL
			if (is_3d_look == 0)
				dialog_flags &= ~PDLG_3D;
#else
			WORD dummy;
			if (
#if !PDLG_SLB
				!(aes_flags & GAI_MAGIC) ||
#endif
				is_3d_look == 0)
			{
				dialog_flags &= ~PDLG_3D;
			}
#endif
			d->rsc = rsc;
			init_rsrc(rsc, d, dialog_flags);
			d->option_flags = 0;
			d->dialog = NULL;
			d->printer_sub_id = 0;
			d->printer_items = NULL;
			d->sub_dialog = NULL;
			d->printers = NULL;
			d->drivers = get_driver_list(d->tree_addr, vdi_handle);
			if (d->drivers != NULL)
			{
				init_settings(d->drivers, &d->settings);
				return d;
			}
			Mfree(d->rsc);
		}
		Mfree(d);
		d = NULL;
	}
	return d;
}


WORD pdlg_delete(PRN_DIALOG *prn_dialog)
{
	if (prn_dialog)
	{
		pdlg_delete_drivers(&prn_dialog->drivers, vdi_handle);
#if !PDLG_SLB
		substitute_free();
#endif
		Mfree(prn_dialog->rsc);
		Mfree(prn_dialog);
	}
	return TRUE;
}


PRN_SETTINGS *pdlg_new_settings(PRN_DIALOG *prn_dialog)
{
	PRN_SETTINGS *settings;
	
	settings = Malloc(sizeof(*settings));
	if (settings != NULL)
		init_settings(prn_dialog->drivers, settings);
	return settings;
}


WORD pdlg_free_settings(PRN_SETTINGS *settings)
{
	if (settings && settings->magic == PRN_SETTINGS_MAGIC)
	{
		Mfree(settings);
		return TRUE;
	} else
	{
		return FALSE;
	}
}


WORD pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	return init_settings(prn_dialog->drivers, settings);
}


LONG pdlg_get_setsize(void)
{
	return sizeof(PRN_SETTINGS);
}


WORD pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *prn_settings)
{
	return validate_settings(prn_dialog->drivers, prn_settings);
}


WORD pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	if (validate_settings(prn_dialog->drivers, settings))
	{
		XDRV_ENTRY *p = get_driver(prn_dialog->drivers, settings);
		if (p != NULL)
			return nvdi_write_settings(p, settings);
	}
	return FALSE;
}


WORD pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings)
{
	UNUSED(prn_dialog);
	return nvdi_write_default_settings(vdi_handle, settings);
}


static PRINTER_ENTRY *find_sub_dialog(PRN_DIALOG *prn_dialog, LONG id)
{
	PRINTER_ENTRY *entry;
	PDLG_SUB *sub;
	
	for (entry = prn_dialog->printer_items; entry != NULL; entry = entry->next)
		if (entry->sub->sub_id == id)
			break;
	if (entry == NULL)
		entry = prn_dialog->printer_items;
	entry->selected = TRUE;
	sub = entry->sub;
	prn_dialog->printer_sub_id = sub->sub_id;
	sub->drivers = (DRV_ENTRY *)prn_dialog->drivers;
	if (sub->sub_tree != NULL)
	{
		prn_dialog->index_offset = insert_panel(prn_dialog->tree, prn_dialog->tree_addr[MAIN_DIALOG], MAIN_SUBBOX, prn_dialog->sub_count, sub->sub_tree);
		if (prn_dialog->sub_count == 0)
			prn_dialog->sub_count++;
		sub->dialog = prn_dialog->dialog;
		sub->tree = prn_dialog->tree;
		sub->index_offset = prn_dialog->index_offset;
		if (prn_dialog->option_flags & PDLG_PRINT)
			prn_dialog->tree[MAIN_OK].ob_spec.free_string = S_PRINTBUTTON;
		else
			prn_dialog->tree[MAIN_OK].ob_spec.free_string = S_OK;
	} else
	{
		prn_dialog->index_offset = insert_panel(prn_dialog->tree, prn_dialog->tree_addr[MAIN_DIALOG], MAIN_SUBBOX, prn_dialog->sub_count, prn_dialog->tree_addr[EMPTY_DIALOG]);
		if (prn_dialog->sub_count == 0)
			prn_dialog->sub_count++;
		sub->dialog = NULL;
		sub->tree = NULL;
	}
	return entry;
}


static void reset_sub_dialog(PRN_DIALOG *prn_dialog, PRN_ENTRY *new_printer, WORD sub_id, PRN_ENTRY *old_printer, PDLG_SUB *old_sub)
{
	PDLG_SUB *printer_sub;
	DIALOG *dialog = prn_dialog->dialog;
	WORD ow = prn_dialog->tree[ROOT].ob_width;
	WORD oh = prn_dialog->tree[ROOT].ob_height;
	WORD act_editob;
	WORD dummy;
	
	if (old_sub->reset_dlg != NULL)
		old_sub->reset_dlg(&prn_dialog->settings, old_sub);
	if (dialog != NULL && old_sub->tree != NULL)
	{
		WORD dummy;
		act_editob = wdlg_get_edit(dialog, &dummy);
		wdlg_set_edit(dialog, 0);
	} else
	{
		prn_dialog->edit_obj = 0;
	}
	printer_sub = find_sub_dialog(prn_dialog, sub_id)->sub;
	prn_dialog->printer_sub_id = printer_sub->sub_id;
	if (printer_sub->init_dlg != NULL)
		printer_sub->init_dlg(&prn_dialog->settings, printer_sub);
	ow -= prn_dialog->tree[ROOT].ob_width;
	oh -= prn_dialog->tree[ROOT].ob_height;
	if (printer_sub->tree != NULL)
	{
		lbox_update(prn_dialog->printer_lbox, NULL);
		if (dialog != NULL)
		{
			if (old_sub->tree != NULL)
			{
				if (old_printer != new_printer)
				{
					pdlg_redraw_obj(printer_sub, MAIN_SCROLLBOX);
					pdlg_redraw_obj(printer_sub, MAIN_BACK);
				}
				if (ow != 0 || oh != 0)
				{
					wdlg_set_size(dialog, (GRECT *)&prn_dialog->tree[ROOT].ob_x);
					pdlg_redraw_obj(printer_sub, ROOT);
				} else
				{
					GRECT clip;
					
					objc_offset(printer_sub->tree, MAIN_SUBBOX, &clip.g_x, &clip.g_y);
					clip.g_w = printer_sub->tree[MAIN_SUBBOX].ob_width;
					clip.g_h = printer_sub->tree[MAIN_SUBBOX].ob_height;
					clip.g_x -= 8;
					clip.g_y -= 8;
					clip.g_w += 8 * 2;
					clip.g_h += 8 * 2;
					pdlg_draw(printer_sub, &clip);
				}
				if (old_sub->sub_tree == printer_sub->sub_tree)
					wdlg_set_edit(dialog, act_editob);
			} else
			{
				prn_dialog->sub_whdl = wdlg_open(dialog, prn_dialog->title, NAME|CLOSER|MOVER, -1, -1, 0, NULL);
				printer_sub->dialog = dialog;
			}
		} else
		{
			WORD clip_flag;
			GRECT clip;
			
			clip = prn_dialog->clip;
			if (ow != 0 || oh != 0)
			{
				GRECT subbox;
				GRECT *gr2 = &subbox;
				
				wind_get_grect(DESK, WF_WORKXYWH, gr2);
				prn_dialog->clip.g_w -= ow;
				prn_dialog->clip.g_h -= oh;
				ow = prn_dialog->clip.g_x + prn_dialog->clip.g_w - gr2->g_x - gr2->g_w;
				oh = prn_dialog->clip.g_y + prn_dialog->clip.g_h - gr2->g_y - gr2->g_h;
				if (ow > 0)
				{
					prn_dialog->clip.g_x -= ow;
					prn_dialog->tree[ROOT].ob_x -= ow;
				}
				if (oh > 0)
				{
					prn_dialog->clip.g_y -= oh;
					prn_dialog->tree[ROOT].ob_y -= oh;
				}
				clip_flag = 1;
			} else
			{
				clip_flag = 0;
			}
			if (old_sub->tree != NULL)
			{
				if (clip_flag)
				{
					form_dial_grect(FMD_FINISH, &clip, &clip);
					form_dial_grect(FMD_START, &prn_dialog->clip, &prn_dialog->clip);
					pdlg_redraw_obj(printer_sub, ROOT);
				} else
				{
					GRECT subbox;
					
					if (pdlg_notequal(printer_sub, old_sub))
					{
						pdlg_redraw_obj(printer_sub, MAIN_SCROLLBOX);
						pdlg_redraw_obj(printer_sub, MAIN_BACK);
					}
					objc_offset(printer_sub->tree, MAIN_SUBBOX, &subbox.g_x, &subbox.g_y);
					subbox.g_w = printer_sub->tree[MAIN_SUBBOX].ob_width;
					subbox.g_h = printer_sub->tree[MAIN_SUBBOX].ob_height;
					subbox.g_x -= 8;
					subbox.g_y -= 8;
					subbox.g_w += 8 * 2;
					subbox.g_h += 8 * 2;
					pdlg_draw(printer_sub, &subbox);
				}
			} else
			{
				form_dial_grect(FMD_START, &prn_dialog->clip, &prn_dialog->clip);
				pdlg_redraw_obj(printer_sub, ROOT);
			}
		}
	} else if (old_sub->tree != NULL)
	{
		if (dialog != NULL)
		{
			wdlg_close(dialog, &dummy, &dummy);
			prn_dialog->sub_whdl = 0;
		} else
		{
			form_dial_grect(FMD_FINISH, &prn_dialog->clip, &prn_dialog->clip);
		}
	}
}


static size_t sub_dialog_maxsize(PRN_DIALOG *prn_dialog)
{
	size_t maxsize;
	PDLG_SUB *sub_dialog;
	XDRV_ENTRY *driver;
	PRN_ENTRY *printer;
	
	maxsize = 0;
	
	for (sub_dialog = prn_dialog->sub_dialog; sub_dialog != NULL; sub_dialog = sub_dialog->next)
	{
		sub_dialog->tree = NULL;
		sub_dialog->dialog = NULL;
		sub_dialog->option_flags = prn_dialog->option_flags;
		if (sub_dialog->sub_tree != NULL)
		{
			size_t size = tree_memsize(sub_dialog->sub_tree);
			if (size > maxsize)
				maxsize = size;
		}
	}
	for (driver = prn_dialog->drivers; driver != NULL; driver = driver->next)
	{
		for (printer = driver->printers; printer != NULL; printer = printer->next)
		{
			for (sub_dialog = printer->sub_dialogs; sub_dialog != NULL; sub_dialog = sub_dialog->next)
			{
				sub_dialog->tree = NULL;
				sub_dialog->dialog = NULL;
				sub_dialog->option_flags = prn_dialog->option_flags;
				if (sub_dialog->sub_tree != NULL)
				{
					size_t size = tree_memsize(sub_dialog->sub_tree);
					if (size > maxsize)
						maxsize = size;
				}
			}
		}
	}
	return maxsize;
}


static void set_sub_title(PRN_DIALOG *prn_dialog, const char *title)
{
	if (prn_dialog->option_flags & PDLG_PRINT)
		vstrcpy(prn_dialog->title, S_PRINTTITLE);
	else
		vstrcpy(prn_dialog->title, S_PAPERTITLE);
	if (title != NULL)
	{
		strcat(prn_dialog->title, "\"");
		strcat(prn_dialog->title, title);
		strcat(prn_dialog->title, "\" ");
	}
}


WORD pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, const char *document_name, WORD option_flags)
{
	size_t size;
	size_t subsize;
	OBJECT *tree;
	XDRV_ENTRY *driver;
	
	prn_dialog->option_flags = option_flags;
	size = tree_memsize(prn_dialog->tree_addr[MAIN_DIALOG]);
	subsize = sub_dialog_maxsize(prn_dialog);
	tree = Malloc(size + subsize);
	if (tree != NULL)
	{
		set_sub_title(prn_dialog, document_name);
		prn_dialog->dialog = NULL;
		prn_dialog->tree = tree;
		prn_dialog->sub_count = 0;
		prn_dialog->exit_button = 0;
		if (settings)
			prn_dialog->settings = *settings;
		validate_settings(prn_dialog->drivers, &prn_dialog->settings);
		driver = get_driver(prn_dialog->drivers, &prn_dialog->settings);
		if (driver != NULL)
			vstrcpy(driver->device, prn_dialog->settings.device);
		if (create_lboxes(prn_dialog))
		{
			PRN_ENTRY *printer = get_printer(prn_dialog->drivers, &prn_dialog->settings);
			PDLG_SUB *sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
			WORD exit_button;
			
			prn_dialog->printer_sub_id = sub->sub_id;
			if (printer->setup_panel)
				printer->setup_panel((DRV_ENTRY *)prn_dialog->drivers, &prn_dialog->settings, NULL, printer);
			if (sub->init_dlg)
				sub->init_dlg(&prn_dialog->settings, sub);
			wind_update(BEG_UPDATE);
			wind_update(BEG_MCTRL);
			form_center_grect(tree, &prn_dialog->clip);
			form_dial_grect(FMD_START, &prn_dialog->clip, &prn_dialog->clip);
			if (sub->tree != NULL)
				pdlg_redraw_obj(sub, ROOT);
			prn_dialog->edit_obj = 0;
			exit_button = 0;
			do
			{
				sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
				if (sub->tree != NULL)
				{
#if !PDLG_SLB
					if (!(aes_flags & GAI_MAGIC))
					{
						exit_button = form_do(tree, ROOT);
					} else
#endif
					{
						exit_button = form_xdo(tree, prn_dialog->edit_obj, &prn_dialog->edit_obj, NULL, NULL);
					}
				} else
				{
					exit_button = 0;
				}
			} while (do_button(prn_dialog, exit_button));
			form_dial_grect(FMD_FINISH, &prn_dialog->clip, &prn_dialog->clip);
			wind_update(END_MCTRL);
			wind_update(END_UPDATE);
			if (printer->close_panel)
				printer->close_panel((DRV_ENTRY *)prn_dialog->drivers, &prn_dialog->settings, NULL, printer);
			free_lboxes(prn_dialog);
			free_printer_items(prn_dialog);
			Mfree(tree);
			if (prn_dialog->exit_button == MAIN_OK)
			{
				*settings = prn_dialog->settings;
				nvdi_write_settings(get_driver(prn_dialog->drivers, settings), settings);
				return PDLG_OK;
			}
			return PDLG_CANCEL;
		}
	}
	return FALSE;
}


WORD pdlg_xopen(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, const char *document_name, WORD option_flags, WORD x, WORD y, WORD ap_id)
{
	size_t size;
	size_t subsize;
	OBJECT *tree;

	prn_dialog->option_flags = option_flags;
	size = tree_memsize(prn_dialog->tree_addr[MAIN_DIALOG]);
	subsize = sub_dialog_maxsize(prn_dialog);
	tree = Malloc(size + subsize);
	if (tree != NULL)
	{
		set_sub_title(prn_dialog, document_name);
		prn_dialog->dialog = wdlg_create(handle_exit, tree, prn_dialog, 0, NULL, 0);
		if (prn_dialog->dialog != NULL)
		{
			prn_dialog->tree = tree;
			prn_dialog->sub_count = 0;
			prn_dialog->exit_button = 0;
			if (settings)
				prn_dialog->settings = *settings;
			validate_settings(prn_dialog->drivers, &prn_dialog->settings);
			if (create_lboxes(prn_dialog))
			{
				PRN_ENTRY *printer = get_printer(prn_dialog->drivers, &prn_dialog->settings);
				PDLG_SUB *sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
				
				prn_dialog->printer_sub_id = sub->sub_id;
				if (printer->setup_panel)
					printer->setup_panel((DRV_ENTRY *)prn_dialog->drivers, &prn_dialog->settings, NULL, printer);
				if (sub->init_dlg)
					sub->init_dlg(&prn_dialog->settings, sub);
				if (sub->tree != NULL)
				{
					WORD whdl = wdlg_open(prn_dialog->dialog, prn_dialog->title, NAME|MOVER, x, y, 0, NULL);
					if (whdl)
					{
						prn_dialog->sub_whdl = whdl;
						return whdl;
					} else
					{
						free_lboxes(prn_dialog);
						free_printer_items(prn_dialog);
					}
				} else
				{
					WORD msg[8];
					
					prn_dialog->sub_whdl = 0;
					msg[0] = WM_REDRAW;
					msg[1] = 1;
					msg[2] = 0;
					msg[3] = 32767;
					msg[4] = 0;
					msg[5] = 0;
					msg[6] = 0;
					msg[7] = 0;
					appl_write(ap_id, 16, msg);
					return 32767;
				}
			}
			wdlg_delete(prn_dialog->dialog);
			prn_dialog->dialog = NULL;
		}
		Mfree(tree);
	}
	return 0;
}


WORD pdlg_close(PRN_DIALOG *prn_dialog, WORD *x, WORD *y)
{
	DIALOG *dialog = prn_dialog->dialog;
	
	if (prn_dialog->sub_whdl)
	{
		wdlg_close(dialog, x, y);
	} else
	{
		*x = -1;
		*y = -1;
	}
	wdlg_delete(dialog);
	free_lboxes(prn_dialog);
	free_printer_items(prn_dialog);
	prn_dialog->dialog = NULL;
	prn_dialog->sub_whdl = 0;
	Mfree(prn_dialog->tree);
	prn_dialog->tree = NULL;
	return TRUE;
}


WORD pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, WORD *button)
{
	WORD cont;
	PDLG_SUB *sub;
	
	cont = TRUE;
	sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
	while (cont && sub->tree == NULL)
	{
		cont = do_button(prn_dialog, 0);
		sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
	}
	if (cont)
	{
		cont = wdlg_evnt(prn_dialog->dialog, events);
		sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
		while (cont && sub->tree == NULL)
		{
			cont = do_button(prn_dialog, 0);
			sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
		}
	}
	if (prn_dialog->exit_button == MAIN_OK)
	{
		*settings = prn_dialog->settings;
		nvdi_write_settings(get_driver(prn_dialog->drivers, settings), settings);
		*button = PDLG_OK;
	} else
	{
		*button = PDLG_CANCEL;
	}
	prn_dialog->exit_button = 0;
	return cont;
}


WORD pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info)
{
	XDRV_ENTRY *entry;
	
	entry = Malloc(sizeof(*entry));
	if (entry != NULL)
	{
		prn_dialog->printers = entry;
		entry->next = NULL;
		entry->length = sizeof(*entry);
		entry->format = DRV_ENTRY_FORMAT;
		entry->reserved = 0;
		entry->driver_id = drv_info->driver_id;
		entry->version = 0;
		entry->reserved2 = 0;
		entry->offset_hdr = 0;
		entry->reserved4 = 0;
		entry->reserved6 = 0;
		entry->file_path[0] = '\0';
		entry->driver_name[0] = '\0';
		entry->name[0] = '\0';
		entry->drv_info = drv_info;
		entry->printers = drv_info->printers;
		entry->dither_modes = drv_info->dither_modes;
		vstrcpy(entry->device, drv_info->device);
		entry->driver_type = DRIVER_CUSTOM;
		install_std_dialogs(prn_dialog->tree_addr, entry);
		list_append((void **)&prn_dialog->drivers, entry);
		return TRUE;
	}
	return FALSE;
}


WORD pdlg_remove_printers(PRN_DIALOG *prn_dialog)
{
	XDRV_ENTRY *printers = prn_dialog->printers;
	list_remove((void **)&prn_dialog->drivers, printers);
	remove_std_dialogs(printers);
	Mfree(printers);
	prn_dialog->printers = NULL;
	return TRUE;
}


WORD pdlg_update(PRN_DIALOG *prn_dialog, const char *document_name)
{
	if (prn_dialog != NULL && prn_dialog->dialog != NULL)
	{
		set_sub_title(prn_dialog, document_name);
		wind_set_str(prn_dialog->sub_whdl, WF_NAME, prn_dialog->title);
		return TRUE;
	}
	return FALSE;
}


WORD pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog)
{
	WORD id;
	
	prn_dialog->sub_dialog = sub_dialog;
	id = 128;
	while (sub_dialog != NULL)
	{
		sub_dialog->sub_id = id;
		sub_dialog = sub_dialog->next;
		id++;
	}
	return TRUE;
}


WORD pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog)
{
	prn_dialog->sub_dialog = NULL;
	return TRUE;
}


static void build_lists(PRN_DIALOG *prn_dialog)
{
	PDLG_SUB *sub;
	
	prn_dialog->printer_items = NULL;
	for (sub = get_printer(prn_dialog->drivers, &prn_dialog->settings)->sub_dialogs; sub != NULL; sub = sub->next)
	{
		PRINTER_ENTRY *entry = Malloc(sizeof(*entry));
		if (entry != NULL)
		{
			entry->next = NULL;
			entry->selected = FALSE;
			entry->data1 = 0;
			entry->sub = sub;
			entry->data3 = NULL;
			list_append((void **)&prn_dialog->printer_items, entry);
		}
	}
	for (sub = prn_dialog->sub_dialog; sub != NULL; sub = sub->next)
	{
		PRINTER_ENTRY *entry = Malloc(sizeof(*entry));
		if (entry != NULL)
		{
			entry->next = NULL;
			entry->selected = FALSE;
			entry->data1 = 0;
			entry->sub = sub;
			entry->data3 = NULL;
			list_append((void **)&prn_dialog->printer_items, entry);
		}
	}
}


static int create_lboxes(PRN_DIALOG *prn_dialog)
{
	build_lists(prn_dialog);
	if (prn_dialog->option_flags & PDLG_PRINT)
		find_sub_dialog(prn_dialog, 0);
	else
		find_sub_dialog(prn_dialog, 1);
	if (create_printer_lbox(prn_dialog))
		return TRUE;
	return FALSE;
}


static int create_printer_lbox(PRN_DIALOG *prn_dialog)
{
	static WORD const ctrl[5] = { MAIN_SCROLLBOX, MAIN_UP, MAIN_DOWN, MAIN_BACK, MAIN_SLIDER };
	static WORD const obj[4] = { MAIN_ICON0, MAIN_ICON1, MAIN_ICON2, MAIN_ICON3 };
	
	prn_dialog->printer_lbox = lbox_create(prn_dialog->tree, select_driver,
		set_icon_item, (LBOX_ITEM *)prn_dialog->printer_items,
		4, 0, ctrl, obj,
		LBOX_VERT | LBOX_AUTO | LBOX_REAL | LBOX_SNGL,
		20, prn_dialog, prn_dialog->dialog,
		0, 0, 0, 0);
	if (prn_dialog->printer_lbox != NULL)
		return TRUE;
	return FALSE;
}


static void free_printer_items(PRN_DIALOG *prn_dialog)
{
	while (prn_dialog->printer_items != NULL)
	{
		PRINTER_ENTRY *top = prn_dialog->printer_items;
		prn_dialog->printer_items = top->next;
		Mfree(top);
	}
}


static void free_lboxes(PRN_DIALOG *prn_dialog)
{
	if (prn_dialog->printer_lbox)
		lbox_delete(prn_dialog->printer_lbox);
}


static WORD cdecl set_icon_item(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD first)
{
	OBJECT *obj = &tree[index];
	
	UNUSED(first);
	UNUSED(rect);
	UNUSED(user_data);
	UNUSED(box);

	if (item)
	{
		OBJECT *icon = ((PRINTER_ENTRY *)item)->sub->sub_icon;
		obj->ob_type = icon->ob_type;
		obj->ob_spec = icon->ob_spec;
		obj->ob_spec.iconblk->ib_xicon = (obj->ob_width - obj->ob_spec.iconblk->ib_wicon) / 2;
		obj->ob_spec.iconblk->ib_xtext = (obj->ob_width - obj->ob_spec.iconblk->ib_wtext) / 2;
		obj->ob_flags |= TOUCHEXIT;
		if (item->selected)
			obj->ob_state |= SELECTED;
		else
			tree[index].ob_state &= ~SELECTED;
	} else
	{
		obj->ob_type = G_BOX;
		obj->ob_spec.obspec.framesize = 0;
		obj->ob_spec.obspec.interiorcol = WHITE;
		obj->ob_spec.obspec.fillpattern = IP_SOLID;
		tree[index].ob_state &= ~SELECTED;
	}
	
	return index;
}



static void cdecl select_driver(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state)
{
	UNUSED(box);
	UNUSED(tree);
	UNUSED(user_data);
	UNUSED(obj_index);
	UNUSED(last_state);
	UNUSED(item);
}


static WORD cdecl handle_exit(DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data)
{
	PRN_DIALOG *prn_dialog;
	
	UNUSED(events);
	if (obj < 0)
	{
		if (obj == HNDL_CLSD)
		{
			prn_dialog = (PRN_DIALOG *)wdlg_get_udata(dialog);
			prn_dialog->exit_button = MAIN_OK;
			return FALSE;
		}
	} else
	{
		prn_dialog = (PRN_DIALOG *)data;
		if (clicks == 2)
			obj |= 0x8000;
		return do_button(prn_dialog, obj);
	}
	return TRUE;
}


static int do_button(PRN_DIALOG *prn_dialog, WORD obj)
{
	PRINTER_ENTRY *printer;
	PDLG_SUB *this_sub;
	PRINTER_ENTRY *old_entry;
	PDLG_SUB *old_sub;
	PRINTER_ENTRY *new_entry;
	PDLG_SUB *new_sub;
	LONG ret;
	
	old_entry = (PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox);
	obj = lbox_do(prn_dialog->printer_lbox, obj);
	new_entry = (PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox);
	old_sub = old_entry->sub;
	new_sub = new_entry->sub;
	obj &= 0x7fff;
	for (;;)
	{
	again:
		if (prn_dialog->printer_sub_id != new_sub->sub_id)
			reset_sub_dialog(prn_dialog, NULL, new_sub->sub_id, NULL, old_sub);
		switch (obj)
		{
		case MAIN_CANCEL:
			if (new_sub->tree != NULL)
				deselect_button(new_sub, MAIN_CANCEL);
			prn_dialog->exit_button = MAIN_CANCEL;
			return FALSE;
		case MAIN_OK:
			if (new_sub->reset_dlg != 0)
				new_sub->reset_dlg(&prn_dialog->settings, new_sub);
			if (new_sub->tree != NULL)
				deselect_button(new_sub, MAIN_OK);
			prn_dialog->exit_button = MAIN_OK;
			return FALSE;
		default:
			for (printer = prn_dialog->printer_items; printer != NULL; printer = printer->next)
			{
				if (printer->sub->sub_id != prn_dialog->printer_sub_id)
					continue;
				this_sub = printer->sub;
				if (this_sub->do_dlg == NULL)
					return TRUE;
				{
					struct PDLG_HNDL_args args;
					args.settings = &prn_dialog->settings;
					args.sub = this_sub;
					args.exit_obj = obj;
#pragma warn -stv
					ret = this_sub->do_dlg(args);
#pragma warn +stv
					if (ret & PDLG_PREBUTTON)
					{
						switch ((WORD)ret)
						{
						case PDLG_PB_OK:
							prn_dialog->exit_button = MAIN_OK;
							return FALSE;
						case PDLG_PB_CANCEL:
							prn_dialog->exit_button = MAIN_CANCEL;
							return FALSE;
						case PDLG_PB_DEVICE:
							do_device_popup(prn_dialog, obj);
							return TRUE;
						default:
							goto again;
						}
					}
					if (!(ret & PDLG_CHG_SUB))
						return TRUE;
					{
						WORD id = (WORD)ret;
						
						old_entry = (PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox);
						for (new_entry = prn_dialog->printer_items; new_entry != NULL; new_entry = new_entry->next)
						{
							if (new_entry->sub->sub_id == id)
							{
								new_entry->selected = TRUE;
								old_entry->selected = FALSE;
								break;
							}
						}
						if (new_entry != NULL)
						{
							old_sub = old_entry->sub;
							new_sub = new_entry->sub;
							obj = 0;
							continue;
						} else
						{
							return FALSE;
						}
					}
				}
			}
			break;
		}
	}
}


static int pdlg_notequal(PDLG_SUB *s1, PDLG_SUB *s2)
{
	while (s1 && s2)
	{
		if (s1->sub_tree != s2->sub_tree)
			break;
		s1 = s1->next;
		s2 = s2->next;
	}
	if (s1 != s2)
		return TRUE;
	return FALSE;
}


static int do_device_popup(PRN_DIALOG *prn_dialog, WORD obj)
{
	PRN_SETTINGS *settings = &prn_dialog->settings;
	char **namep; /* o12 */
	XDRV_ENTRY *driver; /* o8 */
	char **names; /* o4 */
	PRN_ENTRY **printers;
	PRN_ENTRY *printer;
	PRN_ENTRY **entriep;
	WORD active;
	
	{
		WORD num_printers;
		
		num_printers = 0;
		for (driver = prn_dialog->drivers; driver != NULL; driver = driver->next)
		{
			num_printers += (WORD)list_count(driver->printers);
		}
		names = Malloc(num_printers * (2 * sizeof(void *)));
		printers = (PRN_ENTRY **)names + num_printers;
		if (names == NULL)
			return FALSE;
		namep = names;
		entriep = printers;
		active = 0;
		for (driver = prn_dialog->drivers; driver != NULL; driver = driver->next)
		{
			for (printer = driver->printers; printer != NULL; printer = printer->next)
			{
				if (printer->driver_id == settings->driver_id &&
					printer->printer_id == settings->printer_id)
				{
					active = (WORD)(namep - names);
				}
				*namep++ = printer->name;
				*entriep++ = printer;
				
			}
		}
		active = simple_popup(prn_dialog->tree, obj, names, num_printers, active);
		Mfree(names);
	}
		
	if (active >= 0)
	{
		PRN_ENTRY *selected;
		XDRV_ENTRY *new_driver; /* o24 */
		PDLG_SUB *new_sub; /* o20 */
		PDLG_SUB *old_sub; /* o16 */
		WORD first;
		
		printer = get_printer(prn_dialog->drivers, settings);
		selected = printers[active];
		if (printer != selected)
		{
			old_sub = ((PRINTER_ENTRY *)lbox_get_slct_item(prn_dialog->printer_lbox))->sub;
			new_sub = old_sub;
			if (new_sub->reset_dlg)
				new_sub->reset_dlg(settings, new_sub);
			if (printer->close_panel)
				printer->close_panel((DRV_ENTRY *)prn_dialog->drivers, settings, printer, selected);
			if (pdlg_notequal(selected->sub_dialogs, printer->sub_dialogs))
			{
				first = lbox_get_afirst(prn_dialog->printer_lbox);
				free_printer_items(prn_dialog);
				lbox_set_items(prn_dialog->printer_lbox, NULL);
			}
			settings->driver_id = selected->driver_id;
			settings->driver_type = selected->driver_type;
			settings->printer_id = selected->printer_id;
			new_driver = get_driver(prn_dialog->drivers, settings);
			if (new_driver != NULL)
				vstrcpy(settings->device, new_driver->device);
			if (selected->setup_panel)
				selected->setup_panel((DRV_ENTRY *)prn_dialog->drivers, settings, printer, selected);
			if (pdlg_notequal(selected->sub_dialogs, printer->sub_dialogs))
			{
				build_lists(prn_dialog);
				lbox_set_items(prn_dialog->printer_lbox, (LBOX_ITEM *)prn_dialog->printer_items);
				lbox_set_asldr(prn_dialog->printer_lbox, first, NULL);
			}
			reset_sub_dialog(prn_dialog, printer, prn_dialog->printer_sub_id, selected, old_sub);
		}
	}
	
	return FALSE;
}


static void deselect_button(PDLG_SUB *sub, WORD obj)
{
	OBJECT *tree;
	
	tree = sub->tree;

	if (tree[obj].ob_state & SELECTED)
	{
		evnt_timer(40, 0);
		tree[obj].ob_state &= ~SELECTED;
		pdlg_redraw_obj(sub, obj);
	}
}


static void pdlg_draw(PDLG_SUB *sub, GRECT *gr)
{
	OBJECT *tree = sub->tree;
	
	wind_update(BEG_UPDATE);
	if (sub->dialog != NULL)
	{
		wdlg_redraw(sub->dialog, gr, ROOT, MAX_DEPTH);
	} else if (tree != NULL)
	{
		objc_draw_grect(tree, ROOT, MAX_DEPTH, gr);
	}
	wind_update(END_UPDATE);
}


void pdlg_redraw_obj(PDLG_SUB *sub, WORD obj)
{
	GRECT gr;
	OBJECT *tree;
	
	tree = sub->tree;
	gr = *((GRECT *)&tree[ROOT].ob_x);
	if (obj == ROOT)
	{
		gr.g_x -= 3;
		gr.g_y -= 3;
		gr.g_w += 3 * 2;
		gr.g_h += 3 * 2;
	}
	wind_update(BEG_UPDATE);
	if (sub->dialog != NULL)
	{
		wdlg_redraw(sub->dialog, &gr, obj, MAX_DEPTH);
	} else if (tree != NULL)
	{
		objc_draw_grect(tree, obj, MAX_DEPTH, &gr);
	}
	wind_update(END_UPDATE);
}


static size_t tree_memsize(OBJECT *tree)
{
	OBJECT *p = tree;
	
	while (!(p->ob_flags & LASTOB))
		p++;
	p++;
	return (char *)p - (char *)tree;
}


static WORD insert_panel(OBJECT *tree, OBJECT *main_dialog, WORD obj, WORD count, OBJECT *sub_tree)
{
	size_t size = tree_memsize(main_dialog);
	size_t subsize = tree_memsize(sub_tree);
	WORD main_count = (WORD)(size / sizeof(OBJECT));
	
	if (tree != NULL)
	{
		OBJECT *dst;
		WORD d;
		
		if (count != 0)
		{
			WORD dw;
			WORD dh;
			
			tree[obj].ob_width -= 4;
			tree[obj].ob_height -= 4;
			dw = tree[obj].ob_width - main_dialog[obj].ob_width;
			dh = tree[obj].ob_height - main_dialog[obj].ob_height;
			objc_delete(tree, main_count);
			tree[ROOT].ob_width -= dw;
			tree[ROOT].ob_height -= dh;
			tree[obj].ob_width -= dw;
			tree[obj].ob_height -= dh;
			tree[MAIN_OK].ob_x -= dw;
			tree[MAIN_OK].ob_y -= dh;
			tree[MAIN_CANCEL].ob_x -= dw;
			tree[MAIN_CANCEL].ob_y -= dh;
		} else
		{
			vmemcpy(tree, main_dialog, size);
			tree[main_count - 1].ob_flags &= ~LASTOB;
			tree[obj].ob_spec.obspec.framesize = 0;
		}
		dst = &tree[main_count];
		vmemcpy(dst, sub_tree, subsize);
		dst->ob_type = G_BOX;
		dst->ob_spec.obspec.framesize = 0;
		dst->ob_state &= ~0xff;
		if (dst->ob_width > tree[obj].ob_width)
		{
			d = dst->ob_width - tree[obj].ob_width;
			tree[ROOT].ob_width += d;
			tree[obj].ob_width += d;
			tree[MAIN_OK].ob_x += d;
			tree[MAIN_CANCEL].ob_x += d;
		}
		if (dst->ob_height > tree[obj].ob_height)
		{
			d = dst->ob_height - tree[obj].ob_height;
			tree[ROOT].ob_height += d;
			tree[obj].ob_height += d;
			tree[MAIN_OK].ob_y += d;
			tree[MAIN_CANCEL].ob_y += d;
		}
		tree[obj].ob_width += 4;
		tree[obj].ob_height += 4;
		dst->ob_width = tree[obj].ob_width;
		dst->ob_height = tree[obj].ob_height;
		if (dst->ob_head != NIL)
			dst->ob_head += main_count;
		if (dst->ob_tail != NIL)
			dst->ob_tail += main_count;
		if (!(dst->ob_flags & LASTOB))
		{
			do
			{
				dst++;
				if (dst->ob_next != NIL)
					dst->ob_next += main_count;
				if (dst->ob_head != NIL)
					dst->ob_head += main_count;
				if (dst->ob_tail != NIL)
					dst->ob_tail += main_count;
			} while (!(dst->ob_flags & LASTOB));
		}
		objc_add(tree, obj, main_count);
	}
	return main_count;
}


static void init_popups(OBJECT *tree, const WORD *popups, WORD npopups)
{
	while (npopups > 0)
	{
		OBJECT *pop = &tree[*popups++];
		OBJECT *obj = &tree[pop->ob_head];
		obj->ob_y += (pop->ob_height - obj->ob_spec.bitblk->bi_hl) / 2;
		obj->ob_width = 0;
		--npopups;
	}
}


static void init_rsrc(RSHDR *rsh, PRN_DIALOG *prn_dialog, WORD dialog_flags)
{
	OBJECT *objects;
	OBJECT **trindex;
	OBJECT *tree;
	UWORD nobs;
	
	static WORD const icons[] = { ICON_GENERAL, ICON_PAPER, ICON_DITHER, ICON_DEVICE, ICON_OPTIONS, ICON_PORTRAIT, ICON_LANDSCAPE };
	static WORD const cicons[] = { CICON_PORTRAIT, CICON_LANDSCAPE };
	
	static WORD const page_popups[] = { PAGE_DEVICE_POPUP, PAGE_QUAL_POPUP, PAGE_COLOR_POPUP };
	static WORD const paper_popups[] = { PAPER_DEVICE_POPUP, PAPER_SIZE_POPUP, PAPER_QUAL_POPUP, PAPER_INTRAY_POPUP, PAPER_OUTTRAY_POPUP };
	static WORD const color_popups[] = { COLOR_DEVICE_POPUP, COLOR_DITHER_POPUP };
	static WORD const device_popups[] = { DEVICE_DEVICE_POPUP, DEVICE_NAME_POPUP };
	static WORD const dither_popups[] = { DITHER_DEVICE_POPUP, DITHER_DITHER_POPUP, DITHER_COLOR_POPUP };
	
	objects = (OBJECT *)(((UBYTE *)rsh) + rsh->rsh_object);
	nobs = rsh->rsh_nobs;
	prn_dialog->tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);
	prn_dialog->tree_count = rsh->rsh_ntree;
	
	{
		WORD i;
		
		trindex = prn_dialog->tree_addr;
#define NUM(x) (WORD)(sizeof(x) / sizeof(x[0]))

		tree = trindex[MAIN_DIALOG];
		tree[MAIN_UP].ob_y -= 1;
		tree[MAIN_DOWN].ob_y -= 1;
		
		tree = trindex[SUBDLG_ICONS];
		for (i = 0; i < NUM(icons); i++)
		{
			tree[icons[i]].ob_spec.iconblk->ib_char = ICOLSPEC_MAKE(BLACK, WHITE, 0);
		}
		
#if !PDLG_SLB
		tree = trindex[PAPER_DIALOG];
		tree[PAPER_PORTRAIT].ob_type = G_ICON;
		tree[PAPER_PORTRAIT].ob_spec.iconblk = trindex[SUBDLG_ICONS][ICON_PORTRAIT].ob_spec.iconblk;
		tree[PAPER_LANDSCAPE].ob_type = G_ICON;
		tree[PAPER_LANDSCAPE].ob_spec.iconblk = trindex[SUBDLG_ICONS][ICON_LANDSCAPE].ob_spec.iconblk;

		if (aes_flags & GAI_CICN)
#endif
		{
			tree = trindex[CICON_DIALOG];
			for (i = 0; i < NUM(cicons); i++)
			{
				OBJECT *obj = &tree[cicons[i]];
				obj->ob_spec.ciconblk->monoblk.ib_char = ICOLSPEC_MAKE(BLACK, WHITE, 0);
				obj->ob_spec.ciconblk->monoblk.ib_wtext = 0;
				obj->ob_spec.ciconblk->monoblk.ib_htext = 0;
			}
			tree = trindex[PAPER_DIALOG];
			tree[PAPER_PORTRAIT].ob_type = G_CICON;
			tree[PAPER_PORTRAIT].ob_spec.ciconblk = trindex[CICON_DIALOG][CICON_PORTRAIT].ob_spec.ciconblk;
			tree[PAPER_LANDSCAPE].ob_type = G_CICON;
			tree[PAPER_LANDSCAPE].ob_spec.ciconblk = trindex[CICON_DIALOG][CICON_LANDSCAPE].ob_spec.ciconblk;
		}
		
		init_popups(trindex[PAGE_DIALOG], page_popups, NUM(page_popups));
		init_popups(trindex[PAPER_DIALOG], paper_popups, NUM(paper_popups));
		init_popups(trindex[COLOR_DIALOG], color_popups, NUM(color_popups));
		init_popups(trindex[DEVICE_DIALOG], device_popups, NUM(device_popups));
		init_popups(trindex[DITHER_DIALOG], dither_popups, NUM(dither_popups));

		tree = trindex[COLOR_DIALOG];
		tree[COLOR_BRIGHTNESS_TEXT].ob_x = tree[COLOR_BRIGHTNESS_BAR].ob_x - (tree[COLOR_BRIGHTNESS_TEXT].ob_width - tree[COLOR_BRIGHTNESS_BAR].ob_width) / 2;
		tree[COLOR_CONTRAST_TEXT].ob_x = tree[COLOR_CONTRAST_BAR].ob_x - (tree[COLOR_CONTRAST_TEXT].ob_width - tree[COLOR_CONTRAST_BAR].ob_width) / 2;
		tree[COLOR_BRIGHTNESS_SLIDER].ob_y = -tree[COLOR_BRIGHTNESS_SLIDER].ob_height;
		tree[COLOR_BRIGHTNESS_SLIDER].ob_height = tree[COLOR_BRIGHTNESS_SLIDER].ob_height * 3;
		tree[COLOR_CONTRAST_SLIDER].ob_y = -tree[COLOR_CONTRAST_SLIDER].ob_height;
		tree[COLOR_CONTRAST_SLIDER].ob_height = tree[COLOR_CONTRAST_SLIDER].ob_height * 3;
#undef NUM
	}
	
	if ((dialog_flags & PDLG_3D)
#if !PDLG_SLB
		&& (aes_flags & GAI_3D)
#endif
		)
	{
		pdlg_do3d_rsrc(objects, nobs, hor_3d, ver_3d);
	} else
	{
		trindex = prn_dialog->tree_addr;
		tree = trindex[MAIN_DIALOG];
		tree[MAIN_UP].ob_spec.obspec.framesize = 1;
		tree[MAIN_DOWN].ob_spec.obspec.framesize = 1;
		tree[MAIN_SLIDER].ob_spec.obspec.framesize = 1;
		tree[MAIN_BACK].ob_spec.obspec.interiorcol = BLACK;
		tree[MAIN_BACK].ob_spec.obspec.fillpattern = IP_1PATT;
		pdlg_no3d_rsrc(objects, nobs, TRUE);
	}
	
#if !PDLG_SLB
	if (!(aes_flags & GAI_MAGIC))
	{
		OBJECT *selected, *deselected;
		
		if (gl_hchar < 15)
		{
			selected = &trindex[RADIOBUTTONS_DIALOG][RADIO_SMALL_SELECTED];
			deselected = &trindex[RADIOBUTTONS_DIALOG][RADIO_SMALL_DESELECTED];
		} else
		{
			selected = &trindex[RADIOBUTTONS_DIALOG][RADIO_LARGE_SELECTED];
			deselected = &trindex[RADIOBUTTONS_DIALOG][RADIO_LARGE_DESELECTED];
		}
		substitute_objects(objects, nobs, aes_flags, selected, deselected);
	} else
	{
		substitute_objects(objects, nobs, aes_flags, NULL, NULL);
	}
#endif
}


#if CALL_MAGIC_KERNEL == 0

void *pdlg_malloc(LONG size)
{
	if (size != 0)
	{
#if PDLG_SLB
		return (Malloc)(size);
#else
		if (magx_found)
			return (Malloc)(size);
		else
			return malloc(size);
#endif
	}
	return NULL;
}


void pdlg_mfree(void *addr)
{
#if PDLG_SLB
	(Mfree)(addr);
#else
	if (magx_found)
		(Mfree)(addr);
	else
		free(addr);
#endif
}

#endif
