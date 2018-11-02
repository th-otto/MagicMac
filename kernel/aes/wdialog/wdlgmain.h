#define __WDIALOG_IMPLEMENTATION
#define __HNDL_OBJ
#define __MTDIALOG
#define __PRNDIALOG
typedef struct _prn_dialog PRN_DIALOG;
#include <portab.h>
#ifdef __PRINTING__
#include "mgmc_api.h"
#endif
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "country.h"
#include "std.h"
#include "list.h"

#ifndef CALL_MAGIC_KERNEL
#define	CALL_MAGIC_KERNEL 1
#endif


#include "wdialog.h"
#define __LBOX_H__
#define __FSLX_H__
#include "listbox.h"
#include "fnts.h"
typedef struct _fslx_dialog { int dummy; } XFSL_DIALOG;
typedef _WORD _CDECL (*XFSL_FILTER)(char *path, char *name, XATTR *xa);
#include "mt_aes.h"
#include "pdlg.h"

#ifndef UNUSED
# define UNUSED(x) (void)(x)
#endif


extern WORD vdi_handle;
extern WORD	aes_flags;
#define	GAI_WDLG	0x0001	/* wdlg_xx()-functions available */
#define	GAI_LBOX	0x0002	/* lbox_xx()-functions available */
#define	GAI_FNTS	0x0004	/* fnts_xx()-functions available */
#define	GAI_FSEL	0x0008	/* new file selector (fslx_xx) available */
#define	GAI_PDLG	0x0010	/* pdlg_xx()-functions available */

#define	GAI_MAGIC	0x0100	/* MagiC-AES present */
#define	GAI_INFO	0x0200	/* appl_getinfo() supported */
#define	GAI_3D		0x0400	/* 3D-Look supported */
#define	GAI_CICN	0x0800	/* Color-Icons supported */
#define	GAI_APTERM	0x1000	/* AP_TERM supported */
#define	GAI_GSHORTCUT	0x2000	/* object type G_SHORTCUT supported */

extern WORD workout[];
extern WORD xworkout[];
extern WORD gl_wchar;
extern WORD gl_hchar;
extern WORD hor_3d;
extern WORD ver_3d;
extern WORD aes_font;
extern WORD aes_height;

extern WORD	magx_found;
extern WORD	magx_version;

BOOLEAN wd_aes_init(WORD aes_handle);
BOOLEAN wd_xinit(WORD aes_version, WORD ap_id);
BOOLEAN wd_xexit(void);
BOOLEAN wd_nvdi_exit(void);

WORD nvdi_write_default_settings(WORD vhandle, PRN_SETTINGS *settings);
WORD nvdi_read_default_settings(WORD vdi_handle, PRN_SETTINGS *settings);


WORD open_vwork(WORD aes_handle, WORD *workout);
WORD aes_check(void);

WORD get_aes_info(_WORD *font_id, _WORD *font_height, _WORD *hor_3d, _WORD *ver_3d);
LONG get_magic(void);
extern size_t mystrlen(const char *s);
void _appl_yield(void);
void substitute_objects(OBJECT *obj, UWORD nobs, WORD flags, OBJECT *selected, OBJECT *unselected);
void substitute_free(void);

void _rsrc_rcfix(WORD *global, RSHDR *rsc);

WORD MT_evnt_multi(
			WORD evtypes,
			WORD nclicks, WORD bmask, WORD bstate,
			WORD flg1_leave, GRECT *g1,
			WORD flg2_leave, GRECT *g2,
			WORD *msgbuf,
			ULONG ms,
			EVNTDATA *ev,
			WORD *keycode,
			WORD *nbclicks,
			WORD *global_aes
			);


#if	CALL_MAGIC_KERNEL

#define vmemcpyl vmemcpy

extern int enable_3d;

#define	is_3d_look (enable_3d)

#define	objc_draw_grect(tree, obj, depth, clip) \
			set_clip_grect( clip ), _objc_draw(tree, obj, depth)

#define	evnt_timer(low, high) _evnt_timer(low)

#define	Malloc(size) ((void *) mmalloc( size ))

#ifdef BINEXACT
LONG mmalloc(ULONG size);
#endif

#else

#undef is_3d_look
#define	is_3d_look mt_objc_sysvar(OB_GETVAR, AD3DVALUE, 0, 0, &dummy, &dummy, NULL)

#define wind_update(kind) mt_wind_update(kind, NULL)
#define	objc_draw_grect(tree, obj, depth, clip) mt_objc_draw_grect(tree, obj, depth, clip, NULL)
#define objc_delete(tree, obj) mt_objc_delete(tree, obj, NULL)
#define objc_add(tree, parent, child) mt_objc_add(tree, parent, child, NULL)
#define objc_offset(tree, obj, x, y) mt_objc_offset(tree, obj, x, y, NULL)

#define form_xdo(tree, startob, cursor_obj, scantab, flyinf) mt_form_xdo(tree, startob, cursor_obj, scantab, flyinf, NULL)
#define form_do(tree, startob) mt_form_do(tree, startob, NULL)
#define form_dial_grect(kind, lg, bg) mt_form_dial_grect(kind, lg, bg, NULL)
#define form_center_grect(kind, g) mt_form_center_grect(kind, g, NULL)

#define appl_write(id, len, msg) mt_appl_write(id, len, msg, NULL)
#define wind_set_str(w, k, s) mt_wind_set_str(w, k, s, NULL)
#define wind_get_grect(handle, field, g) mt_wind_get_grect(handle, field, g, NULL)
#define	evnt_timer(low, high) mt_evnt_timer(low, NULL)

#undef Malloc
#define	Malloc(size) pdlg_malloc(size)
#undef Mfree
#define	Mfree(addr) pdlg_mfree(addr)

void *pdlg_malloc(LONG size);
int pdlg_mfree(void *addr);

extern void vmemcpyl(void *dst, void *src, long len);

#endif
