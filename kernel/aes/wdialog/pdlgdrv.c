#include "wdlgmain.h"
#include "filestat.h"
#include "ph.h"

/*
 * FIXME: these belong into the RSC file
 */
#if COUNTRY == COUNTRY_DE || COUNTRY == COUNTRY_SG

#define S_FLOYD_STEINBERG  "Floyd-Steinberg"
#define S_QUICKDRAW_OUTPUT "QuickDraw-Ausgabe"
#define S_USERDEFINED      "benutzerdefiniert"
#define S_INPUT_TRAYNAME1  "manuell"
#define S_INPUT_TRAYNAME2  "Kassette 1"
#define S_INPUT_TRAYNAME3  "Kassette 2"
#define S_INPUT_TRAYNAME4  "Kassette 3"
#define S_INPUT_TRAYNAME2_1  "Traktor"
#define S_INPUT_TRAYNAME2_2  "Schacht 1"
#define S_INPUT_TRAYNAME2_3  "Schacht 2"
#define S_INPUT_TRAYNAME2_4  "manuell"
#define S_OUTPUT_TRAYNAME1  "vorne"
#define S_OUTPUT_TRAYNAME2  "hinten"
#define S_OUTPUT_TRAYNAME3  "Auswurf 3"
#define S_OUTPUT_TRAYNAME4  "Auswurf 4"
#define S_FSM_PAPERSIZE0 "Letter"
#define S_FSM_PAPERSIZE1 "Legal"
#define S_FSM_PAPERSIZE2 "DIN A4"
#define S_FSM_PAPERSIZE3 "DIN B5"
#define S_FSM_PAPERSIZE4 S_USERDEFINED

#elif COUNTRY == COUNTRY_US || COUNTRY == COUNTRY_UK

#define S_FLOYD_STEINBERG  "Floyd-Steinberg"
#define S_QUICKDRAW_OUTPUT "QuickDraw-Output"
#define S_USERDEFINED      "user defined"
#define S_INPUT_TRAYNAME1  "manual"
#define S_INPUT_TRAYNAME2  "Cassette 1"
#define S_INPUT_TRAYNAME3  "Cassette 2"
#define S_INPUT_TRAYNAME4  "Cassette 3"
#define S_INPUT_TRAYNAME2_1  "Traktor"
#define S_INPUT_TRAYNAME2_2  "Shaft 1"
#define S_INPUT_TRAYNAME2_3  "Shaft 2"
#define S_INPUT_TRAYNAME2_4  "manual"
#define S_OUTPUT_TRAYNAME1  "front"
#define S_OUTPUT_TRAYNAME2  "back"
#define S_OUTPUT_TRAYNAME3  "Eject 3"
#define S_OUTPUT_TRAYNAME4  "Eject 4"
#define S_FSM_PAPERSIZE0 "Letter"
#define S_FSM_PAPERSIZE1 "Legal"
#define S_FSM_PAPERSIZE2 "DIN A4"
#define S_FSM_PAPERSIZE3 "DIN B5"
#define S_FSM_PAPERSIZE4 S_USERDEFINED

#elif COUNTRY == COUNTRY_FR || COUNTRY == COUNTRY_SF

#define S_FLOYD_STEINBERG  "Floyd-Steinberg"
#define S_QUICKDRAW_OUTPUT "QuickDraw-Output"
#define S_USERDEFINED      "user defined"
#define S_INPUT_TRAYNAME1  "manual"
#define S_INPUT_TRAYNAME2  "Cassette 1"
#define S_INPUT_TRAYNAME3  "Cassette 2"
#define S_INPUT_TRAYNAME4  "Cassette 3"
#define S_INPUT_TRAYNAME2_1  "Traktor"
#define S_INPUT_TRAYNAME2_2  "Shaft 1"
#define S_INPUT_TRAYNAME2_3  "Shaft 2"
#define S_INPUT_TRAYNAME2_4  "manual"
#define S_OUTPUT_TRAYNAME1  "front"
#define S_OUTPUT_TRAYNAME2  "back"
#define S_OUTPUT_TRAYNAME3  "Eject 3"
#define S_OUTPUT_TRAYNAME4  "Eject 4"
#define S_FSM_PAPERSIZE0 "Letter"
#define S_FSM_PAPERSIZE1 "Legal"
#define S_FSM_PAPERSIZE2 "DIN A4"
#define S_FSM_PAPERSIZE3 "DIN B5"
#define S_FSM_PAPERSIZE4 S_USERDEFINED

#endif

#define MAX_INPUT_TRAYS  4
#define MAX_OUTPUT_TRAYS 4

#define S_INPUT_TRAYNAMES S_INPUT_TRAYNAME1, S_INPUT_TRAYNAME2, S_INPUT_TRAYNAME3, S_INPUT_TRAYNAME4
#define S_INPUT_TRAYNAMES2 S_INPUT_TRAYNAME2_1, S_INPUT_TRAYNAME2_2, S_INPUT_TRAYNAME2_3, S_INPUT_TRAYNAME2_4
#define S_OUTPUT_TRAYNAMES S_OUTPUT_TRAYNAME1, S_OUTPUT_TRAYNAME2, S_OUTPUT_TRAYNAME3, S_OUTPUT_TRAYNAME4
#define S_FSM_PAPERSIZES S_FSM_PAPERSIZE0, S_FSM_PAPERSIZE1, S_FSM_PAPERSIZE2, S_FSM_PAPERSIZE3, S_FSM_PAPERSIZE4

struct fsm_hdr {
	LONG magic1; /* '_FSM' */
	LONG magic2; /* '_HDR' */
	UWORD version;
	UWORD flags;
#define FSM_PAPER_LETTER 0x0002
#define FSM_PAPER_LEGAL  0x0004
#define FSM_PAPER_DINA4  0x0008
#define FSM_PAPER_DINB5  0x0010
#define FSM_PAPER_USER   0x0020
#define FSM_RESOLUTION   0x0040
#define FSM_SERIAL       0x0100
#define FSM_INTRAY_0     0x0200
#define FSM_INTRAY_1     0x0400
#define FSM_INTRAY_2     0x0800
#define FSM_INTRAY_3     0x1000
	WORD color_mode;
	WORD o14;
	WORD o16;
	WORD o18;
	WORD o20;
	WORD o22;
	WORD hdpi[4];
	WORD vdpi[4];
	WORD size_id;
	WORD o42;
	WORD o44;
	WORD aux_dev;
	WORD input_tray_id;
	char name[26];
	char o76[16];
};

#define PAPERSIZE_FSM_LETTER 0
#define PAPERSIZE_FSM_LEGAL  1
#define PAPERSIZE_FSM_DINA4  2
#define PAPERSIZE_FSM_DINB5  3
#define PAPERSIZE_FSM_USER   4


static XDRV_ENTRY *query_driver_info(OBJECT **tree_addr, WORD vhandle, WORD device);
static void delete_printers(PRN_ENTRY **printers);
static void free_list(void **root);


#define P_COOKIES ((long *) 0x5a0)

static void delete_sub_dialogs(PDLG_SUB **sub);
static void delete_paper_types(MEDIA_TYPE **types);
static void delete_paper_sizes(MEDIA_SIZE **sizes);
static void delete_trays(PRN_TRAY **trays);

static PRN_ENTRY *query_mac_driver(OBJECT **tree_addr, XDRV_ENTRY *entry, DRVR_HEADER *nvdihdr, struct zz *z);
static int is_mac_driver(XDRV_ENTRY *entry);
static int can_do_landscape(XDRV_ENTRY *entry);
static int can_do_contrast(XDRV_ENTRY *entry);
static int can_do_serial(XDRV_ENTRY *entry);
static int can_do_acsi(XDRV_ENTRY *entry);
static int can_do_file(XDRV_ENTRY *entry);
static int can_do_copies(XDRV_ENTRY *entry);
static int create_mode_infos(XDRV_ENTRY *entry, PRN_ENTRY *printer, DRVR_HEADER *nvdihdr, struct zz *z, struct xx *p);
static PRN_ENTRY *query_fsm_driver(OBJECT **tree_addr, WORD vhandle, XDRV_ENTRY *entry, const char *name, char *filepath, const char *filename);
static void add_input_tray(PRN_ENTRY *printer, WORD id);
static void add_paper_size(PRN_ENTRY *printer, WORD id);
static void add_mode(PRN_ENTRY *printer, WORD hdpi, WORD vdpi, WORD id);
static WORD read_nvdi_hdr(DRVR_HEADER *hdr, struct zz *z, const char *filename, const char *drivername, LONG *offset_hdr);
static struct xx *mgmc_read_hdr(const char *filepath, const char *name);


struct XVDI_PARAMS {
	WORD control[12];
	WORD intin[16];
	WORD ptsin[16];
	WORD intout[16];
	WORD ptsout[16];
};



static void set_vdipb(VDIPB *pb, struct XVDI_PARAMS *params)
{
	pb->control = params->control;
	pb->intin = params->intin;
	pb->ptsin = params->ptsin;
	pb->intout = params->intout;
	pb->ptsout = params->ptsout;
}


/*******************************************************************
*
* Cookie ermitteln.
*
*******************************************************************/

static LONG __init_cookie(void)
{
	return *P_COOKIES;
}


static ULONG *get_cookie(ULONG val)
{
	ULONG *cookie;

	cookie = (ULONG *) Supexec(__init_cookie);
	if	(cookie)
	{
		while (*cookie)
		{
			if	(*cookie == val)
				return cookie;
			cookie += 2;
		}
	}
	return NULL;
}


struct _nvdi_struct													/* verkuerzte NVDI-Struktur */
{
	WORD version;
	LONG datum;
	WORD conf;
};


WORD disable_nvdi_errors(void)
{
	ULONG *cookie;
	struct _nvdi_struct	*nvdi_struct;
#define COOKIE_NVDI 0x4E564449L /* 'NVDI' */
	WORD ret;
	
	cookie = get_cookie(COOKIE_NVDI);
	if (cookie != 0)
	{
		nvdi_struct = (struct _nvdi_struct *)cookie[1];
		ret = nvdi_struct->conf;
		nvdi_struct->conf |= 0x0002;  /* turn error compatibility on */
		nvdi_struct->conf &= ~0x0040; /* turn alerts off */
		return ret;
	}
	return 0;
}


void enable_nvdi_errors(WORD conf)
{
	ULONG *cookie;
	struct _nvdi_struct	*nvdi_struct;
	
	cookie = get_cookie(COOKIE_NVDI);
	if (cookie != 0)
	{
		nvdi_struct = (struct _nvdi_struct *)cookie[1];
		nvdi_struct->conf = conf;
	}
}



DRV_INFO *v_create_driver_info(WORD vhandle, WORD driver_id)
{
	VDIPB pb;
	struct XVDI_PARAMS params;
	WORD conf;
	
	set_vdipb(&pb, &params);
	params.intin[0] = driver_id;
	params.control[0] = 180;
	params.control[1] = 0;
	params.control[3] = 1;
	params.control[5] = 0;
	params.control[6] = vhandle;
	params.control[2] = 0;
	params.control[4] = 0;
	conf = disable_nvdi_errors();
	vdi(&pb);
	enable_nvdi_errors(conf);
	if (params.control[4] >= 2)
		return *((DRV_INFO **)&params.intout[0]);
	return NULL;
}


WORD v_delete_driver_info(WORD vhandle, DRV_INFO *drv_info)
{
	VDIPB pb;
	struct XVDI_PARAMS params;
	/* WORD conf; */
	
	set_vdipb(&pb, &params);
	*((DRV_INFO **)&params.intin[0]) = drv_info;
	params.control[0] = 181;
	params.control[1] = 0;
	params.control[2] = 0;
	params.control[3] = 2;
	params.control[4] = 0;
	params.control[5] = 0;
	params.control[6] = vhandle;
	/* conf = disable_nvdi_errors(); */
	vdi(&pb);
	/* enable_nvdi_errors(conf); */
	if (params.control[4] >= 1)
		return params.intout[0];
	return 0;
}


WORD v_read_default_settings(WORD vhandle, PRN_SETTINGS *settings)
{
	VDIPB pb;
	struct XVDI_PARAMS params;
	WORD conf;
	
	set_vdipb(&pb, &params);
	*((PRN_SETTINGS **)&params.intin[0]) = settings;
	params.control[0] = 182;
	params.control[1] = 0;
	params.control[3] = 2;
	params.control[5] = 0;
	params.control[6] = vhandle;
	params.control[2] = 0;
	params.control[4] = 0;
	conf = disable_nvdi_errors();
	vdi(&pb);
	enable_nvdi_errors(conf);
	if (params.control[4] >= 1)
		return params.intout[0];
	return 0;
}


WORD v_write_default_settings(WORD vhandle, PRN_SETTINGS *settings)
{
	VDIPB pb;
	struct XVDI_PARAMS params;
	WORD conf;
	
	set_vdipb(&pb, &params);
	*((PRN_SETTINGS **)&params.intin[0]) = settings;
	params.control[0] = 182;
	params.control[1] = 0;
	params.control[3] = 2;
	params.control[5] = 1;
	params.control[6] = vhandle;
	params.control[2] = 0;
	params.control[4] = 0;
	conf = disable_nvdi_errors();
	vdi(&pb);
	enable_nvdi_errors(conf);
	if (params.control[4] >= 1)
		return params.intout[0];
	return 0;
}


XDRV_ENTRY *get_driver_list(OBJECT **tree_addr, WORD vhandle)
{
	WORD id;
	XDRV_ENTRY *root;
	XDRV_ENTRY *driver;
	
	root = NULL;
	if (vq_gdos())
	{
		/* BUG? what about plotter drivers? */
		for (id = VDI_PRINTER_DEVICE; id < 100; id++)
		{
			/* skip memory drivers */
			if (id == VDI_MEMORY_DEVICE)
				id = 71;
			driver = query_driver_info(tree_addr, vhandle, id);
			if (driver)
				list_append((void **)&root, driver);
		}
	}
	return root;
}


int pdlg_delete_drivers(XDRV_ENTRY **drv_info, WORD vhandle)
{
	XDRV_ENTRY *driver;
	
	while (*drv_info != NULL)
	{
		driver = *drv_info;
		if (driver->drv_info)
		{
			remove_std_dialogs(driver);
			v_delete_driver_info(vhandle, driver->drv_info);
		} else
		{
			delete_printers(&driver->printers);
			free_list((void **) &driver->dither_modes);
		}
		*drv_info = driver->next;
		Mfree(driver);
	}
	return TRUE;
}


static void free_list(void **root)
{
	while (*root)
	{
		void **entry = *root;
		*root = *entry;
		Mfree(entry);
	}
}


static void delete_printers(PRN_ENTRY **printers)
{
	PRN_ENTRY *printer;
	
	while (*printers != NULL)
	{
		printer = *printers;
		*printers = printer->next;
		delete_sub_dialogs(&printer->sub_dialogs);
		delete_modes(&printer->modes);
		delete_paper_sizes(&printer->papers);
		delete_trays(&printer->input_trays);
		delete_trays(&printer->output_trays);
		Mfree(printer);
	}
}


static void delete_sub_dialogs(PDLG_SUB **list)
{
	while (*list != NULL)
	{
		PDLG_SUB *sub = *list;
		*list = sub->next;
		Mfree(sub);
	}
}


void delete_modes(PRN_MODE **modes)
{
	PRN_MODE *mode;
	
	while (*modes != NULL)
	{
		mode = *modes;
		*modes = mode->next;
		delete_paper_types(&mode->paper_types);
		Mfree(mode);
	}
}


static void delete_paper_types(MEDIA_TYPE **types)
{
	MEDIA_TYPE *type;
	
	while (*types != NULL)
	{
		type = *types;
		*types = type->next;
		Mfree(type);
	}
}


static void delete_paper_sizes(MEDIA_SIZE **sizes)
{
	MEDIA_SIZE *size;
	
	while (*sizes != NULL)
	{
		size = *sizes;
		*sizes = size->next;
		Mfree(size);
	}
}


static void delete_trays(PRN_TRAY **trays)
{
	PRN_TRAY *tray;
	
	while (*trays != NULL)
	{
		tray = *trays;
		*trays = tray->next;
		Mfree(tray);
	}
}


void install_std_dialogs(OBJECT **tree_addr, XDRV_ENTRY *entry)
{
	PRN_ENTRY *printer;
	
	for (printer = entry->printers; printer != NULL; printer = printer->next)
	{
		if (printer->sub_dialogs == NULL)
		{
			if (printer->sub_flags == PRN_QD_SUBS)
			{
				printer->setup_panel = pdlg_qd_setup;
				printer->close_panel = pdlg_qd_close;
				printer->sub_dialogs = pdlg_qd_sub(tree_addr);
			} else
			{
				printer->setup_panel = pdlg_std_setup;
				printer->close_panel = pdlg_std_close;
				printer->sub_dialogs = pdlg_std_sub(tree_addr);
			}
		}
	}
}


void remove_std_dialogs(XDRV_ENTRY *printers)
{
	PRN_ENTRY *p;
	
	for (p = printers->printers; p != NULL; p = p->next)
	{
		if (p->sub_flags < 0x10000L)
		{
			delete_sub_dialogs(&p->sub_dialogs);
			p->setup_panel = 0;
			p->close_panel = 0;
		}
	}
}


static XDRV_ENTRY *query_driver_info(OBJECT **tree_addr, WORD vhandle, WORD device)
{
	char filename[128];
	char filepath[128];
	char name[128];
	WORD exists;
	
	vq_ext_devinfo(vhandle, device, &exists, filepath, filename, name);
	if (exists)
	{
		XDRV_ENTRY *entry;
		
		entry = Malloc(sizeof(*entry));
		if (entry != NULL)
		{
			entry->next = NULL;
			entry->length = sizeof(*entry);
			entry->format = DRV_ENTRY_FORMAT;
			entry->reserved = 0;
			entry->driver_id = device;
			entry->driver_type = DRIVER_NONE;
			entry->version = 0;
			entry->reserved2 = 0;
			entry->offset_hdr = 0;
			entry->reserved4 = 0;
			entry->dither_modes = NULL;
			entry->reserved6 = 0;
			vstrcpy(entry->file_path, filepath);
			vstrcpy(entry->driver_name, filename);
			entry->name[0] = '\0';
			entry->device[0] = '\0';
			entry->drv_info = v_create_driver_info(vhandle, device);
			if (entry->drv_info != NULL)
			{
				entry->printers = entry->drv_info->printers;
				entry->dither_modes = entry->drv_info->dither_modes;
				vstrcpy(entry->device, entry->drv_info->device);
				entry->driver_type = DRIVER_AVDI;
				install_std_dialogs(tree_addr, entry);
			} else
			{
				DRVR_HEADER nvdihdr;
				struct zz z;
				WORD type;
				
				type = read_nvdi_hdr(&nvdihdr, &z, entry->file_path, entry->driver_name, &entry->offset_hdr);
				if (type)
				{
					entry->driver_type = DRIVER_NVDI;
					entry->version = nvdihdr.version;
					if (entry->offset_hdr != 0)
					{
						DITHER_MODE *mode;
						
						vstrcpy(entry->name, z.name);
						vstrcpy(entry->device, z.device);
						entry->printers = query_mac_driver(tree_addr, entry, &nvdihdr, &z);
						mode = Malloc(sizeof(*mode));
						if (mode != NULL)
						{
							mode->next = NULL;
							mode->length = sizeof(*mode);
							mode->format = DRV_ENTRY_FORMAT;
							mode->reserved = 0;
							mode->dither_id = 1;
							mode->color_modes = CC_16M_COLOR | CC_16M_GREY;
							mode->reserved1 = 0;
							mode->reserved2 = 0;
							vstrcpy(mode->name, S_FLOYD_STEINBERG);
							entry->dither_modes = mode;
						}
					} else
					{
						PRN_ENTRY *printer;
						
						printer = Malloc(sizeof(*printer));
						if (printer != NULL)
						{
							printer->next = NULL;
							printer->length = sizeof(*printer);
							printer->format = DRV_ENTRY_FORMAT;
							printer->reserved = 0;
							printer->driver_id = entry->driver_id;
							printer->driver_type = entry->driver_type;
							printer->printer_id = 0;
							printer->printer_capabilities = 0;
							printer->reserved1 = 0;
							printer->sub_flags = PRN_STD_SUBS;
							printer->setup_panel = pdlg_std_setup;
							printer->close_panel = pdlg_std_close;
							printer->sub_dialogs = pdlg_std_sub(tree_addr);
							printer->modes = NULL;
							printer->papers = NULL;
							printer->input_trays = NULL;
							printer->output_trays = NULL;
							vstrcpy(printer->name, name);
							entry->printers = printer;
							if (type == VDI_META_DEVICE) /* metafile driver? */
							{
								printer->printer_capabilities |= PC_FILE;
								vstrcpy(entry->device, "GEMFILE.GEM");
							}
						}
					}
				} else
				{
					entry->printers = query_fsm_driver(tree_addr, vhandle, entry, name, filepath, filename);
				}
			}
			if (entry->printers == NULL)
			{
				Mfree(entry);
				return NULL;
			} else
			{
				return entry;
			}
		}
	}
	return NULL;
}


static PRN_ENTRY *query_mac_driver(OBJECT **tree_addr, XDRV_ENTRY *entry, DRVR_HEADER *nvdihdr, struct zz *z)
{
	struct xx *p;
	PRN_ENTRY *root;
	WORD i;
	
	root = NULL;
	p = mgmc_read_hdr(entry->file_path, entry->name);
	if (p != NULL)
	{
		for (i = 0; i < p->num_printer; i++)
		{
			PRN_ENTRY *printer;
			
			printer = Malloc(sizeof(*printer));
			if (printer != NULL)
			{
				printer->next = NULL;
				printer->length = sizeof(*printer);
				printer->format = DRV_ENTRY_FORMAT;
				printer->reserved = 0;
				printer->modes = NULL;
				printer->papers = NULL;
				printer->input_trays = NULL;
				printer->output_trays = NULL;
				printer->driver_id = entry->driver_id;
				printer->driver_type = entry->driver_type;
				printer->printer_id = p->o16[i].id;
				printer->printer_capabilities = 0;
				printer->reserved1 = 0;
				if (is_mac_driver(entry))
				{
					printer->sub_flags = PRN_QD_SUBS;
					printer->setup_panel = pdlg_qd_setup;
					printer->close_panel = pdlg_qd_close;
					printer->sub_dialogs = pdlg_qd_sub(tree_addr);
					vstrcpy(printer->name, S_QUICKDRAW_OUTPUT);
				} else
				{
					printer->sub_flags = PRN_STD_SUBS;
					printer->setup_panel = pdlg_std_setup;
					printer->close_panel = pdlg_std_close;
					printer->sub_dialogs = pdlg_std_sub(tree_addr);
					if (can_do_serial(entry))
						printer->printer_capabilities |= PC_SERIAL|PC_PARALLEL;
					if (can_do_acsi(entry))
						printer->printer_capabilities |= PC_ACSI;
					if (can_do_file(entry))
						printer->printer_capabilities |= PC_FILE;
					if (can_do_copies(entry))
						printer->printer_capabilities |= PC_COPIES;
					vstrcpy(printer->name, p->o16[i].name);
					create_mode_infos(entry, printer, nvdihdr, z, p);
				}
				if (nvdihdr->version >= 0x460)
					printer->printer_capabilities |= PC_BACKGROUND;
				list_append((void **)&root, printer);
			}
		}
		Mfree(p);
	}
	return root;
}


static int is_mac_driver(XDRV_ENTRY *entry)
{
	if (strcmp(MAC_DRIVER_NAME, entry->driver_name) == 0)
		return TRUE;
	return FALSE;
}


static int can_do_landscape(XDRV_ENTRY *entry)
{
	if (strcmp(IMG_DRIVER_NAME, entry->driver_name) == 0)
		return FALSE;
	return TRUE;
}


static int can_do_contrast(XDRV_ENTRY *entry)
{
	if (strcmp(IMG_DRIVER_NAME, entry->driver_name) != 0 &&
		strcmp(META_DRIVER_NAME, entry->driver_name) != 0 &&
		strcmp(MAC_DRIVER_NAME, entry->driver_name) != 0 &&
		entry->version >= 0x470)
		return TRUE;
	return FALSE;
}


static int can_do_serial(XDRV_ENTRY *entry)
{
	if (strcmp(ATARILS_DRIVER_NAME, entry->driver_name) == 0 ||
		strcmp(IMG_DRIVER_NAME, entry->driver_name) == 0)
		return FALSE;
	return TRUE;
}


static int can_do_file(XDRV_ENTRY *entry)
{
	if (strcmp(ATARILS_DRIVER_NAME, entry->driver_name) == 0)
		return FALSE;
	return TRUE;
}


static int can_do_acsi(XDRV_ENTRY *entry)
{
	if (strcmp(ATARILS_DRIVER_NAME, entry->driver_name) == 0)
		return TRUE;
	return FALSE;
}


static int can_do_copies(XDRV_ENTRY *entry)
{
	if (strcmp(META_DRIVER_NAME, entry->driver_name) == 0 ||
		strcmp(IMG_DRIVER_NAME, entry->driver_name) == 0)
		return FALSE;
	return TRUE;
}


static int can_do_truecolor(XDRV_ENTRY *entry, DRVR_HEADER *nvdihdr)
{
	if (nvdihdr->version < 0x410 ||
		strcmp(ATARILS_DRIVER_NAME, entry->driver_name) == 0 ||
		strcmp(IMG_DRIVER_NAME, entry->driver_name) == 0)
		return FALSE;
	return TRUE;
}


static int create_mode_infos(XDRV_ENTRY *entry, PRN_ENTRY *printer, DRVR_HEADER *nvdihdr, struct zz *z, struct xx *p)
{
	LONG maxxsize;
	LONG maxysize;
	LONG xsize;
	LONG ysize;
	WORD i;
	WORD min_input_trays;
	WORD min_output_trays;
	struct yy *buf;

	maxysize = maxxsize = 0;
	min_input_trays = 32767;
	min_output_trays = 32767;
	buf = (struct yy *)((char *)p + p->offset);
	for (i = 0; i < p->num_modes; i++)
	{
		if (buf->printer_id == printer->printer_id)
		{
			PRN_MODE *mode;
			
			xsize = buf->o6 + buf->o18 + buf->o20 + 1;
			ysize = buf->o8 + buf->o22 + buf->o24 + 1;
			xsize *= 25400;
			ysize *= 25400;
			xsize /= buf->hdpi;
			ysize /= buf->vdpi;
			if (xsize > maxxsize)
				maxxsize = xsize;
			if (ysize > maxysize)
				maxysize = ysize;
			mode = Malloc(sizeof(*mode));
			if (mode != NULL)
			{
				WORD j;
				
				mode->next = NULL;
				mode->mode_id = i;
				mode->mode_capabilities = 0;
				if (can_do_landscape(entry))
					mode->mode_capabilities |= MC_PORTRAIT | MC_LANDSCAPE;
				if (can_do_contrast(entry))
					mode->mode_capabilities |= MC_CTRST_BRGHT;
				mode->color_capabilities = CC_MONO;
				mode->dither_flags = 0;
				mode->paper_types = NULL;
				if (buf->o96[0] != '\0')
				{
					mode->color_capabilities |= CC_8_COLOR;
					if (can_do_truecolor(entry, nvdihdr))
					{
						mode->color_capabilities |= CC_16M_COLOR;
						mode->dither_flags |= CC_16M_COLOR; /* ??? */
					}
				}
				if (can_do_truecolor(entry, nvdihdr))
				{
					mode->color_capabilities |= CC_16M_GREY;
					mode->dither_flags |= CC_16M_GREY; /* ??? */
				}
				mode->hdpi = buf->hdpi;
				mode->vdpi = buf->vdpi;
				strncpy(mode->name, buf->name, sizeof(mode->name) - 1);
				mode->name[sizeof(mode->name) - 1] = '\0';
				for (j = 0; j < MAX_INPUT_TRAYS; j++)
				{
					if (buf->o120[j][0] == '\0')
						break;
				}
				if (min_input_trays > j)
					min_input_trays = j;
				for (j = 0; j < MAX_OUTPUT_TRAYS; j++)
				{
					if (buf->o152[j][0] == '\0')
						break;
				}
				if (min_output_trays > j)
					min_output_trays = j;
				list_append((void **)&printer->modes, mode);
			}
		}
		buf++;
	}
	
	maxxsize += maxxsize / 10;
	maxysize += maxysize / 10;
	
	{
		struct media_info *info;
		MEDIA_SIZE *size;
		
		info = z->sizes;
		for (i = 0; i < z->num_sizes; i++)
		{
			if (strcmp(info->name, S_USERDEFINED) != 0 &&
				info->xsize <= maxxsize &&
				info->ysize <= maxysize)
			{
				size = Malloc(sizeof(*size));
				if (size != NULL)
				{
					size->next = NULL;
					size->size_id = info->size_id;
					vstrcpy(size->name, info->name);
					list_append((void **)&printer->papers, size);
				}
			}
			info++;
		}
	}
	
	if (min_input_trays <= MAX_INPUT_TRAYS)
	{
		for (i = 0; i < min_input_trays; i++)
		{
			PRN_TRAY *tray;
			static const char *const input_tray_names[MAX_INPUT_TRAYS] = { S_INPUT_TRAYNAMES };
			
			tray = Malloc(sizeof(*tray));
			if (tray != NULL)
			{
				tray->next = NULL;
				tray->tray_id = i;
				vstrcpy(tray->name, input_tray_names[i]);
				list_append((void **)&printer->input_trays, tray);
			}
		}
	}
	
	if (min_output_trays <= MAX_OUTPUT_TRAYS)
	{
		static const char *const output_tray_names[MAX_OUTPUT_TRAYS] = { S_OUTPUT_TRAYNAMES };
		
		for (i = 0; i < min_output_trays; i++)
		{
			PRN_TRAY *tray;
			
			tray = Malloc(sizeof(*tray));
			if (tray != NULL)
			{
				tray->next = NULL;
				tray->tray_id = i;
				vstrcpy(tray->name, output_tray_names[i]);
				list_append((void **)&printer->output_trays, tray);
			}
		}
	}
	
	return TRUE;
}



static PRN_ENTRY *query_fsm_driver(OBJECT **tree_addr, WORD vhandle, XDRV_ENTRY *entry, const char *name, char *filepath, const char *filename)
{
	PRN_ENTRY *printer;
	void *buf;
	WORD workin[11];
	WORD workout[57];
	LONG size;
	WORD handle;
	WORD i;
	WORD hdpi;
	WORD vdpi;
	
	entry->driver_type = DRIVER_DYNAMIC;
	entry->name[0] = '\0';
	entry->device[0] = '\0';
	
	printer = Malloc(sizeof(*printer));
	if (printer != NULL)
	{
		printer->next = NULL;
		printer->length = sizeof(*printer);
		printer->format = DRV_ENTRY_FORMAT;
		printer->reserved = 0;
		printer->driver_id = entry->driver_id;
		printer->driver_type = entry->driver_type;
		printer->printer_id = 0x5F46534DL + entry->driver_id; /* '_FSM' */
		printer->printer_capabilities = 0;
		printer->reserved1 = 0;
		printer->sub_flags = PRN_FSM_SUBS;
		printer->setup_panel = pdlg_std_setup;
		printer->close_panel = pdlg_std_close;
		printer->sub_dialogs = pdlg_fsm_sub(tree_addr);
		printer->modes = NULL;
		printer->papers = NULL;
		printer->input_trays = NULL;
		printer->output_trays = NULL;
		printer->name[0] = '\0';
		strcat(filepath, filename);
		buf = readfile(filepath, &size);
		if (buf != NULL)
		{
			unsigned short *p = buf;
			
			while (size > 0)
			{
				if (*p++ == 0x5F46) /* '_F' */
				{
					if (*p++ == 0x534D) /* 'SM' */
					{
						if (*((unsigned long *)p) == 0x5F484452L) /* '_HDR' */
						{
							struct fsm_hdr *hdr = (struct fsm_hdr *)(p - 2);
							
							entry->driver_type = DRIVER_RESIDENT;
							entry->offset_hdr = (char *)hdr - (char *)buf;
							if (hdr->flags & FSM_PAPER_LETTER)
								add_paper_size(printer, 0);
							if (hdr->flags & FSM_PAPER_LEGAL)
								add_paper_size(printer, 1);
							if (hdr->flags & FSM_PAPER_DINA4)
								add_paper_size(printer, 2);
							if (hdr->flags & FSM_PAPER_DINB5)
								add_paper_size(printer, 3);
							if (hdr->flags & FSM_PAPER_USER)
								add_paper_size(printer, 4);
							if (hdr->flags & FSM_INTRAY_0)
								add_input_tray(printer, 0);
							if (hdr->flags & FSM_INTRAY_1)
								add_input_tray(printer, 1);
							if (hdr->flags & FSM_INTRAY_2)
								add_input_tray(printer, 2);
							if (hdr->flags & FSM_INTRAY_3)
								add_input_tray(printer, 3);
							if (hdr->flags & FSM_SERIAL)
								printer->printer_capabilities |= PC_SERIAL|PC_PARALLEL;
							if (hdr->flags & FSM_RESOLUTION)
							{
								for (i = 0; i <= 3; i++)
								{
									add_mode(printer, hdr->hdpi[i], hdr->vdpi[i], i);
								}
							} else
							{
								add_mode(printer, hdr->hdpi[0], hdr->vdpi[0], 0);
							}
							strncpy(printer->name, hdr->name, 26);
							printer->name[26] = '\0';
							if (printer->modes != NULL)
							{
								Mfree(buf);
								return printer;
							}
							break;
						}
					}
					size -= 2;
				}
				size -= 2;
			}
			Mfree(buf);
		}
		
		for (i = 1; i < 10; i++)
			workin[i] = 1;
		workin[0] = entry->driver_id;
		workin[10] = 2;
		handle = vhandle;
		v_opnwk(workin, &handle, workout);
		if (handle > 0)
		{
			hdpi = 25400 / workout[3] + 5;
			hdpi -= hdpi % 10;
			vdpi = 25400 / workout[4] + 5;
			vdpi -= vdpi % 10;
			switch (workout[13])
			{
			case 4:
				i = 1;
				break;
			case 8:
				i = 2;
				break;
			case 16:
				i = 3;
				break;
			case 256:
				vq_extnd(handle, 1, workout);
				i = 4;
				if (workout[4] >= 16)
					i = 5;
				if (workout[4] >= 24)
					i = 6;
				break;
			default:
				i = 0;
				break;
			}
			add_mode(printer, hdpi, vdpi, i);
			if (printer->name[0] == '\0')
			{
				strncpy(printer->name, name, sizeof(printer->name) - 1);
				printer->name[sizeof(printer->name) - 1] = '\0';
			}
			v_clswk(handle);
		} else
		{
			delete_sub_dialogs(&printer->sub_dialogs);
			Mfree(printer);
			printer = NULL;
		}
	}
	return printer;
}


static void add_mode(PRN_ENTRY *printer, WORD hdpi, WORD vdpi, WORD id)
{
	PRN_MODE *mode;
	char buf[8];
	PRN_MODE **end;
	
	if (hdpi == 0 || vdpi == 0)
		return;
	mode = Malloc(sizeof(*mode));
	if (mode != NULL)
	{
		mode->next = NULL;
		mode->mode_id = 0;
		mode->mode_capabilities = 0;
		switch (id)
		{
		case 1:
			mode->color_capabilities = CC_4_COLOR;
			break;
		case 2:
			mode->color_capabilities = CC_8_COLOR;
			break;
		case 3:
			mode->color_capabilities = CC_16_COLOR;
			break;
		case 4:
			mode->color_capabilities = CC_256_COLOR;
			break;
		case 5:
			mode->color_capabilities = CC_32K_COLOR;
			break;
		case 6:
			mode->color_capabilities = CC_16M_COLOR;
			break;
		case 0:
		default:
			mode->color_capabilities = CC_MONO;
			break;
		}
		mode->dither_flags = mode->color_capabilities & (CC_16M_COLOR|CC_32K_COLOR|CC_256_COLOR);
		mode->paper_types = NULL;
		mode->hdpi = hdpi;
		mode->vdpi = vdpi;
		itoa(hdpi, mode->name, 10);
		strcat(mode->name, " * ");
		itoa(vdpi, buf, 10);
		strcat(mode->name, buf);
		strcat(mode->name, " dpi");
		end = &printer->modes;
		while (*end != NULL)
		{
			++mode->mode_id;
			end = &(*end)->next;
		}
		*end = mode;
	}
}


static void add_input_tray(PRN_ENTRY *printer, WORD id)
{
	PRN_TRAY *tray;
	static const char *const input_tray_names2[MAX_INPUT_TRAYS] = { S_INPUT_TRAYNAMES2 };
	
	tray = Malloc(sizeof(*tray));
	if (tray != NULL)
	{
		tray->next = NULL;
		tray->tray_id = id;
		vstrcpy(tray->name, input_tray_names2[id]);
		list_append((void **)&printer->input_trays, tray);
	}
}


static void add_paper_size(PRN_ENTRY *printer, WORD id)
{
	MEDIA_SIZE *size;
	static const char *const paper_sizes[5] = { S_FSM_PAPERSIZES };
	
	size = Malloc(sizeof(*size));
	if (size != NULL)
	{
		size->next = NULL;
		switch (id)
		{
		case PAPERSIZE_FSM_LETTER:
			size->size_id = PAPERSIZE_LETTER;
			break;
		case PAPERSIZE_FSM_LEGAL:
			size->size_id = PAPERSIZE_LEGAL;
			break;
		case PAPERSIZE_FSM_DINA4:
			size->size_id = PAPERSIZE_DINA4;
			break;
		case PAPERSIZE_FSM_DINB5:
			size->size_id = PAPERSIZE_DINB5;
			break;
		case PAPERSIZE_FSM_USER:
			size->size_id = PAPERSIZE_USER;
			break;
		}
		vstrcpy(size->name, paper_sizes[id]);
		list_append((void **)&printer->papers, size);
	}
}


WORD vq_ext_devinfo(WORD handle, WORD device, WORD *dev_exists, char *filepath, char *filename, char *name)
{
	VDIPB pb;
	struct {
		WORD control[12];
		WORD intin[16];
		WORD ptsin[16];
		WORD intout[16];
		WORD ptsout[16];
	} params;
	
	pb.control = params.control;
	pb.intin = params.intin;
	pb.ptsin = params.ptsin;
	pb.intout = params.intout;
	pb.ptsout = params.ptsout;

	params.control[0] = 248;
	params.control[1] = 0;
	params.control[3] = 7;
	params.control[5] = 4242;
	params.control[6] = handle;
	params.intin[0] = device;
	*((char **)&params.intin[1]) = filepath;
	*((char **)&params.intin[3]) = filename;
	*((char **)&params.intin[5]) = name;
	vdi(&pb);
	*dev_exists = params.intout[0];
	return params.intout[1];
}


static WORD read_nvdi_hdr(DRVR_HEADER *nvdihdr, struct zz *z, const char *filepath, const char *drivername, LONG *offset_hdr)
{
	char filename[256];
	WORD ret;
	
	ret = 0;
	vstrcpy(filename, filepath);
	strcat(filename, drivername);
	if (readbuf(filename, nvdihdr, sizeof(PH), sizeof(*nvdihdr)) == sizeof(*nvdihdr) &&
		strncmp(nvdihdr->magic, "NVDIDRV", sizeof(nvdihdr->magic)) == 0)
	{
		if (nvdihdr->offset_hdr != 0)
		{
			*offset_hdr = nvdihdr->offset_hdr + sizeof(PH);
			if (readbuf(filename, z, *offset_hdr, sizeof(*z)) != sizeof(*z))
				*offset_hdr = 0;
		} else
		{
			*offset_hdr = 0;
		}
		ret = nvdihdr->type;
	}
	return ret;
}


static struct xx *mgmc_read_hdr(const char *filepath, const char *name)
{
	char filename[256];
	LONG size;
	struct xx *x;
	WORD i;
	
	vstrcpy(filename, filepath);
	strcat(filename, name);
	x = readfile(filename, &size);
	if (x != NULL)
	{
		struct yy *y = (struct yy *)((char *)x + x->offset);
		for (i = 0; i < x->num_modes; i++)
		{
#define FIX(e) if (y->e != 0) (char *)y->e += (long)x
			FIX(name);
			FIX(o36);
			FIX(o44);
			FIX(o52);
			FIX(o60);
			FIX(o68);
			FIX(o76);
			FIX(o84);
			FIX(o92);
			FIX(o100);
			FIX(o108);
			FIX(o116);
#undef FIX
			y++;
		}
	}
	return x;
}


int nvdi_write_settings(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings)
{
	struct fsm_hdr fsm_hdr;
	char filename[256];
	struct zz hdr;
	DRVR_HEADER nvdihdr;
	WORD i;
	
	vstrcpy(filename, drv_info->file_path);
	strcat(filename, drv_info->driver_name);
	if (drv_info->driver_type == DRIVER_NVDI)
	{
		if (readbuf(filename, &nvdihdr, sizeof(PH), sizeof(nvdihdr)) != sizeof(nvdihdr))
			return FALSE;
		if (nvdihdr.type != VDI_PRINTER_DEVICE && nvdihdr.type != VDI_BITMAP_DEVICE)
			return TRUE;
		if (is_mac_driver(drv_info))
			mgmc_set_settings(settings);
		switch ((WORD)settings->color_mode)
		{
		case CC_MONO:
			nvdihdr.o52 = 0;
			nvdihdr.info.colors = 2;
			nvdihdr.info.planes = 1;
			nvdihdr.info.format = FORM_ID_INTERLEAVED;
			nvdihdr.info.flags = 1;
			break;
		case CC_8_COLOR:
			nvdihdr.o52 = 0x10;
			nvdihdr.info.colors = 8;
			nvdihdr.info.planes = 3;
			nvdihdr.info.format = FORM_ID_PIXPACKED;
			nvdihdr.info.flags = 1;
			break;
		case CC_16M_GREY:
			nvdihdr.o52 = 0x10f;
			nvdihdr.info.colors = 0x1000000L; /* 16M */
			nvdihdr.info.planes = 32;
			nvdihdr.info.format = FORM_ID_INTERLEAVED;
			nvdihdr.info.flags = 1;
			break;
		case CC_16M_COLOR:
			nvdihdr.o52 = 0x11f;
			nvdihdr.info.colors = 0x1000000L; /* 16M */
			nvdihdr.info.planes = 32;
			nvdihdr.info.format = FORM_ID_INTERLEAVED;
			nvdihdr.info.flags = 1;
			break;
		}
		if (writebuf(filename, &nvdihdr, sizeof(PH), sizeof(nvdihdr)) != sizeof(nvdihdr))
			return FALSE;
		if (readbuf(filename, &hdr, nvdihdr.offset_hdr + sizeof(PH), sizeof(hdr)) != sizeof(hdr))
			return FALSE;
		hdr.printer_id = (WORD)settings->printer_id;
		hdr.mode_id = (WORD)settings->mode_id;
		hdr.no_copies = (WORD)settings->no_copies;
		if (settings->orientation == PG_LANDSCAPE)
			hdr.orientation = 1;
		else
			hdr.orientation = 0;
		hdr.input_tray_id = (WORD)settings->input_id;
		hdr.output_tray_id = (WORD)settings->output_id;
		for (i = 0; i < hdr.num_sizes; i++)
		{
			if (hdr.sizes[i].size_id == settings->size_id)
			{
				hdr.size_id = i;
			}
		}
		vstrcpy(hdr.printer_name, get_printer(drv_info, settings)->name);
		vstrcpy(hdr.device, settings->device);
		if (writebuf(filename, &hdr, nvdihdr.offset_hdr + sizeof(PH), sizeof(hdr)) == sizeof(hdr))
			return TRUE;
		return FALSE;
	} else if (drv_info->driver_type == DRIVER_RESIDENT)
	{
		if (readbuf(filename, &fsm_hdr, drv_info->offset_hdr, sizeof(fsm_hdr)) != sizeof(fsm_hdr))
			return FALSE;
		switch ((WORD)settings->color_mode)
		{
		case CC_MONO:
			fsm_hdr.color_mode = 0;
			break;
		case CC_4_COLOR:
			fsm_hdr.color_mode = 1;
			break;
		case CC_8_COLOR:
			fsm_hdr.color_mode = 2;
			break;
		case CC_16_COLOR:
			fsm_hdr.color_mode = 3;
			break;
		case CC_256_COLOR:
			fsm_hdr.color_mode = 4;
			break;
		case CC_32K_COLOR:
			fsm_hdr.color_mode = 5;
			break;
		case CC_16M_COLOR:
			fsm_hdr.color_mode = 6;
			break;
		}
		if (strcmp(AUX_DEVICE, drv_info->device) == 0)
			fsm_hdr.aux_dev = 1;
		else
			fsm_hdr.aux_dev = 0;
		switch ((WORD)settings->size_id)
		{
		case PAPERSIZE_LETTER:
			fsm_hdr.size_id = PAPERSIZE_FSM_LETTER;
			break;
		case PAPERSIZE_LEGAL:
			fsm_hdr.size_id = PAPERSIZE_FSM_LEGAL;
			break;
		case PAPERSIZE_DINA4:
			fsm_hdr.size_id = PAPERSIZE_FSM_DINA4;
			break;
		case PAPERSIZE_DINB5:
			fsm_hdr.size_id = PAPERSIZE_FSM_DINB5;
			break;
		case PAPERSIZE_USER:
			fsm_hdr.size_id = PAPERSIZE_FSM_USER;
			break;
		}
		fsm_hdr.input_tray_id = (WORD)settings->input_id;
		if (writebuf(filename, &fsm_hdr, drv_info->offset_hdr, sizeof(fsm_hdr)) == sizeof(fsm_hdr))
			return TRUE;
	} else
	{
		return TRUE;
	}
	return FALSE;
}


WORD nvdi_read_default_settings(WORD vhandle, PRN_SETTINGS *settings)
{
	return v_read_default_settings(vhandle, settings);
}


WORD nvdi_write_default_settings(WORD vhandle, PRN_SETTINGS *settings)
{
	return v_write_default_settings(vhandle, settings);
}
