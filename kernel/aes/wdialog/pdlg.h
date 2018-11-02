#include "mgmc_api.h"
#include "../vdi/nvdi.h"
#include "../vdi/drivers.h"

#if COUNTRY == COUNTRY_DE || COUNTRY == COUNTRY_SG
#include "ger\pdlg.h"
#elif COUNTRY == COUNTRY_US || COUNTRY == COUNTRY_UK
#include "us\pdlg.h"
#elif COUNTRY == COUNTRY_FR || COUNTRY == COUNTRY_SF
#include "fra\pdlg.h"
#endif


#define PRN_DEVICE "PRN:"
#define AUX_DEVICE "AUX:"
#define ACSI_DEVICE "ACSI:"
#define SCSI_DEVICE "SCSI:"

#define MAC_DRIVER_NAME "MACPRN.SYS"
#define ATARILS_DRIVER_NAME "ATARILS.SYS"
#define IMG_DRIVER_NAME "IMG.SYS"
#define META_DRIVER_NAME "META.SYS"

/*
 * Driver types
 */
#define DT_NONE      0
#define DT_UNKNOWN   1
#define DT_FSM       2
#define DT_OLDNVDI   3
#define DT_NVDI      4

#define VDI_SCREEN_DEVICE   1
#define VDI_PLOTTER_DEVICE 11
#define VDI_PRINTER_DEVICE 21
#define VDI_META_DEVICE    31
#define VDI_CAMERA_DEVICE  41
#define VDI_TABLET_DEVICE  51
#define VDI_MEMORY_DEVICE  61
#define VDI_OFFSCREEN_DEVICE (VDI_MEMORY_DEVICE + 1)
#define VDI_FAX_DEVICE     81
#define VDI_BITMAP_DEVICE  91
#define VDI_MM_DEVICE      101
#define VDI_SOUND_DEVICE   111

#define PG_MIN_COPIES 1
#define PG_MAX_COPIES 999
#define VALID_PAGE_FLAGS (PG_EVEN_PAGES|PG_ODD_PAGES)
#define VALID_PLANE_FLAGS (PLANE_BLACK|PLANE_YELLOW|PLANE_MAGENTA|PLANE_CYAN)


/*
 * Paper sizes passed in workin[11] on v_opnwk call.
 These should actually be defined in <vdi.h>
 */
#define PAPERSIZE_USER      (-1)
#define PAPERSIZE_DEFAULT     0
#define PAPERSIZE_DINA3       1
#define PAPERSIZE_DINA4       2
#define PAPERSIZE_DINA5       3
#define PAPERSIZE_DINB5       4
#define PAPERSIZE_LETTER     16
#define PAPERSIZE_HALF       17
#define PAPERSIZE_LEGAL      18
#define PAPERSIZE_DOUBLE     19
#define PAPERSIZE_BROADSHEET 20

typedef struct _xdrv_entry {
	/*   0 */ struct _xdrv_entry *next;
	/*   4 */ _LONG        length;          /* Structure length */
	/*   8 */ _LONG        format;          /* Data format */
	/*  12 */ _LONG        reserved;        /* Reserved */
	
	/*  16 */ _WORD        driver_id;       /* Driver number for the VDI */
	/*  18 */ _WORD        driver_type;     /* Driver type */
	/*  20 */ _WORD        version;
	/*  22 */ _WORD        reserved2;       /* reserved */
	/*  24 */ _LONG        offset_hdr;
	/*  28 */ _LONG        reserved4;       /* reserved */
	
	/*  32 */ PRN_ENTRY   *printers;        /* List of printers belonging to driver */
	/*  36 */ DITHER_MODE *dither_modes;
	/*  40 */ DRV_INFO    *drv_info;
	/*  44 */ _LONG        reserved6;
	/*  48 */ char         file_path[128];  /* driver path */
	/* 176 */ char         driver_name[32];
	/* 208 */ char         name[32];
	/* 240 */ char         device[128];     /* Output file of printer driver */
	/* 368 */
} XDRV_ENTRY;

/*
 * This must match LBOX_ITEM
 */
typedef struct _sub_entry {
	struct _sub_entry *next;
	WORD selected;
	WORD data1;
	PDLG_SUB *sub;
	void *data3;
} PRINTER_ENTRY;

struct _prn_dialog {
	LONG  magic;            /* unused */
	LONG  length;           /* Structure length */
	LONG  format;           /* Structure type */
	LONG  reserved;         /* reserved */
	
	/*  16 */ PRN_SETTINGS settings;
	          /*   0 LONG magic */
	          /*   4 LONG length */
	          /*   8 LONG format */
	          /*  12 LONG reserved */
	          /*  16 LONG page_flags */
	          /*  20 WORD first_page */
	          /*  22 WORD last_page */
	          /*  24 WORD no_copies */
	          /*  26 WORD orientation */
	          /*  28 fixed scale */
	          /*  32 WORD driver_id */
	          /*  34 WORD driver_type */
	          /*  36 LONG driver_mode */
	          /*  40 LONG reserved1 */
	          /*  44 LONG reserved2 */
	          /*  48 LONG printer_id */
	          /*  52 LONG mode_id */
	          /*  56 WORD mode_hdpi */
	          /*  58 WORD mode_vdpi */
	          /*  60 LONG quality_id */
	          /*  64 LONG color_mode */
	          /*  68 LONG plane_flags */
	          /*  72 LONG dither_mode */
	          /*  76 LONG dither_value */
	          /*  80 LONG size_id */
	          /*  84 LONG type_id */
	          /*  88 LONG input_id */
	          /*  92 LONG output_id */
	          /*  96 fixed contrast */
	          /* 100 fixed brightness */
	          /* 104 LONG reserved3 */
	          /* 108 LONG reserved4 */
	          /* 112 LONG reserved5 */
	          /* 116 LONG reserved6 */
	          /* 120 LONG reserved7 */
	          /* 124 LONG reserved8 */
	          /* 128 char device[128] */
	          /* 256 TPrint mac_settings */
	          /* 376 */
	
	/* 392 */ GRECT clip;
	/* 400 */ DIALOG *dialog;
	/* 404 */ WORD sub_whdl;
	/* 406 */ exit_button;
	/* 408 */ WORD edit_obj;
	/* 410 */ WORD option_flags;
	/* 412 */ RSHDR *rsc;
	/* 416 */ OBJECT **tree_addr;
	/* 420 */ WORD tree_count;
	/* 422 */ WORD index_offset;
	/* 424 */ OBJECT *tree;
	/* 428 */ WORD sub_count;
	/* 430 */ XDRV_ENTRY *drivers;
	/* 434 */ WORD printer_sub_id; /* id of the printer sub-dialog */
	/* 436 */ PRINTER_ENTRY *printer_items;
	/* 440 */ LIST_BOX *printer_lbox;
	/* 444 */ PDLG_SUB *sub_dialog;
	/* 448 */ XDRV_ENTRY *printers;
	/* 452 */ char title[128];
	/* 580 */
};

#define PRN_SETTINGS_MAGIC 0x70736574L /* 'pset' */
#define PRN_SETTINGS_FORMAT 1
#define DRV_ENTRY_FORMAT 1


struct xx {
	LONG o0;
	LONG offset;
	WORD o8;
	WORD num_printer;
	WORD num_modes;
	WORD o14;
	struct {
		WORD id;
		char name[30];
	} o16[1];
};

struct yy {
	UWORD printer_id;
	char *name;
	WORD o6;
	UWORD o8;
	UWORD hdpi;
	UWORD vdpi;
	UWORD o14;
	UWORD o16;
	UWORD o18;
	UWORD o20;
	UWORD o22;
	UWORD o24;
	char fill1[10];
	void *o36;
	long o40;
	void *o44;
	long o48;
	void *o52;
	long o56;
	void *o60;
	long o64;
	void *o68;
	long o72;
	void *o76;
	long o80;
	void *o84;
	long o88;
	void *o92;
	char o96[4];
	void *o100;
	long o104;
	void *o108;
	long o112;
	void *o116;
	char o120[4][8];
	char o152[4][8];
};

struct media_info {
	LONG xsize;
	LONG ysize;
	char o8[16];
	WORD size_id;
	char o26[6];
	char name[32];
};

struct zz {
	WORD printer_id;
	WORD mode_id;
	WORD no_copies;
	WORD orientation;
	WORD input_tray_id;
	WORD output_tray_id;
	WORD size_id;
	WORD num_sizes;
	char printer_name[128];
	char name[16];
	char device[128];
	struct media_info sizes[16];
};



extern struct MgMcCookie *mgmc_cookie;
extern VoidProcPtr modeMac;
extern VoidProcPtr modeAtari;
extern MacCtProc callMacContext;
extern Ptr macA5;
extern VoidProcPtr intrLock;
extern VoidProcPtr intrUnlock;
extern PDLG_SUB *mac_subdlg;
extern PRN_SETTINGS *mac_settings;
extern TPPrDlg mac_dlg;
typedef TPPrDlg pascal (*PDlgInitProcPtr)(THPrint hPrint);

void mgmc_init(void);
long mgmc_init_settings(PRN_SETTINGS *settings);
long mgmc_validate_settings(PRN_SETTINGS *settings);
long mgmc_set_settings(PRN_SETTINGS *settings);
int mgmc_get_modes(PRN_ENTRY *printer, Boolean flag);


void ExecuteMacFunction(void (*theFunction)(void));

void MacOffsetRect(Rect *r, short dx, short dy);
void MacUnionRect(const Rect *src1, const Rect *src2, Rect *dst);
void MacSizeWindow(WindowPtr w, short width, short height, Boolean flag);
Handle MacNewHandle(Size size);
void MacDisposeHandle(Handle handle);
void MacHLock(Handle handle);
void MacHUnlock(Handle handle);
Ptr MacNewPtr(Size size);
void MacDisposePtr(Ptr p);
MacOSErr MacPtrAndHand(const void *ptr1, Handle handle, long size);
void MacPrOpen(void);
void MacPrintDefault(THPrint hprint);
Boolean MacPrValidate(THPrint hprint);
TPPrDlg MacPrStlInit(THPrint hprint);
TPPrDlg MacPrJobInit(THPrint hprint);
Boolean MacPrDlgMain(THPrint hprint, PDlgInitProcPtr init);
void MacPrGeneral(Ptr pData);
Integer MacPrError(void);
void MacPrClose(void);
ControlHandle MacNewControl(WindowPtr theWindow, const Rect *bounds, Str255 title, Boolean visible, Integer value, Integer min, Integer max, Integer procID, long refCon);
void MacSetCtlValue(ControlHandle theControl, Integer value);
void MacSetCTitle(ControlHandle theControl, Str255 title);
void MacGetDItem(DialogPtr theDialog, Integer itemNo, Integer *itemType, Handle *item, Rect *box);


XDRV_ENTRY *get_driver_list(OBJECT **tree_addr, WORD vhandle);
void install_std_dialogs(OBJECT **tree_addr, XDRV_ENTRY *entry);
void remove_std_dialogs(XDRV_ENTRY *printers);
int pdlg_delete_drivers(XDRV_ENTRY **drv_info, WORD vhandle);
int delete_modes(PRN_MODE **modes);
void set_tedinfo(OBJECT *tree, WORD obj, const char *str, WORD spaces);
void set_mode(PDLG_SUB *sub, PRN_SETTINGS *settings, WORD hdpi, WORD vdpi, LONG mode_id);
void set_color(PDLG_SUB *sub, PRN_SETTINGS *settings, LONG color_mode);
int do_qual_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj);
int do_color_popup(PRN_SETTINGS *settings, PDLG_SUB *sub, _WORD exit_obj);




void pdlg_redraw_obj(PDLG_SUB *sub, WORD obj);
void pdlg_do3d_rsrc(OBJECT *obj, WORD nobs, WORD hor, WORD ver);
void pdlg_no3d_rsrc(OBJECT *obj, WORD nobs, WORD flag);
WORD simple_popup(OBJECT *tree, WORD root, const char **names, WORD num_names, WORD selected);


int nvdi_write_settings(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
XDRV_ENTRY *get_driver_info(XDRV_ENTRY *drv_info, WORD id);
XDRV_ENTRY *get_driver(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_ENTRY *get_printer(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_ENTRY *find_printer(XDRV_ENTRY *drv_info, WORD id, _LONG printer_id);
PRN_MODE *validate_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings, WORD hdpi, WORD vdpi, LONG id);
MEDIA_SIZE *validate_paper_size(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
MEDIA_TYPE *validate_media_type(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
WORD validate_orientation(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_TRAY *validate_input_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_TRAY *validate_output_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
void validate_color_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings, LONG color_mode);
DITHER_MODE *validate_dither_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
void validate_scale(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
void validate_device(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_MODE *find_mode(PRN_ENTRY *p, LONG id);
MEDIA_SIZE *find_paper_size(PRN_ENTRY *p, LONG id);
MEDIA_TYPE *find_media_type(PRN_MODE *mode, LONG id);
PRN_TRAY *find_input_tray(PRN_ENTRY *p, LONG id);
PRN_TRAY *find_output_tray(PRN_ENTRY *p, LONG id);
PRN_TRAY *get_input_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_TRAY *get_output_tray(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
MEDIA_TYPE *get_media_type(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);
PRN_MODE *get_mode(XDRV_ENTRY *drv_info, PRN_SETTINGS *settings);

LONG __CDECL pdlg_qd_setup(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer);
LONG __CDECL pdlg_qd_close(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer);
PDLG_SUB *pdlg_qd_sub(OBJECT **tree_addr);

LONG __CDECL pdlg_std_setup(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer);
LONG __CDECL pdlg_std_close(DRV_ENTRY *drivers, PRN_SETTINGS *settings, PRN_ENTRY *old_printer, PRN_ENTRY *new_printer);
PDLG_SUB *pdlg_std_sub(OBJECT **tree_addr);
PDLG_SUB *pdlg_fsm_sub(OBJECT **tree_addr);


typedef struct																/* Dialogbeschreibung fÅr create_sub_dialogs() */
{
	WORD sub_id;
	PDLG_INIT init_dlg;
	PDLG_HNDL do_dlg;
	PDLG_RESET reset_dlg;
	WORD icon_index;
	WORD tree_index;
} SIMPLE_SUB;



PDLG_SUB *install_sub_dialogs(OBJECT **tree_addr, const SIMPLE_SUB *subs, WORD count);
