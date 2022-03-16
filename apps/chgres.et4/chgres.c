#ifdef __PUREC__
#include <portab.h>
#include <stddef.h>
#define wdlg_close wdlg_xclose
#define evnt_multi evnt_multi_gemlib
#include <aes.h>
#define __GRECT
#define __MOBLK
#define __PORTAES_H__
#define _WORD WORD
#define _LONG LONG
#define _VOID void
#define __CDECL cdecl
#define _CDECL __CDECL
#define EXTERN_C_BEG
#define EXTERN_C_END
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#undef wdlg_close
#undef evnt_multi
void wdlg_close(DIALOG *dialog);
int evnt_multi( int ev_mflags, int ev_mbclicks,
                               int ev_mbmask, int ev_mbstate,
                               int ev_mm1flags, int ev_mm1x,
                               int ev_mm1y, int ev_mm1width,
                               int ev_mm1height, int ev_mm2flags,
                               int ev_mm2x, int ev_mm2y,
                               int ev_mm2width, int ev_mm2height,
                               int *ev_mmgpbuff, int ev_mtlocount,
                               int ev_mthicount, int *ev_mmox,
                               int *ev_mmoy, int *ev_mmbutton,
                               int *ev_mmokstate, int *ev_mkreturn,
                               int *ev_mbreturn );
#include <tos.h>
#else
#include <gemx.h>
#include <osbind.h>
#include <mint/falcon.h>
#include <support.h>
#define itoa(val, buf, base) _itoa(val, buf, base, 0)
#define Vsetmode(mode) VsetMode(mode)
#define mon_type() VgetMonitor()
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"
#include "vgainf.h"


#undef ST_LOW
#undef ST_MED
#undef ST_HIGH
#undef FALCON_REZ
#undef TT_MED
#undef TT_HIGH
#undef TT_LOW
#define ST_LOW     (0 + 2)
#define ST_MED     (1 + 2)
#define ST_HIGH    (2 + 2)
#define FALCON_REZ (3 + 2)
#define TT_MED     (4 + 2)
#define TT_HIGH    (6 + 2)
#define TT_LOW     (7 + 2)

#define SV_INQUIRE		0	/* inquire sysvar data, see mt_objc_sysvar() */
#define AD3DVAL      6                  /* AES 4.0     */
#define SVEXT 0x4000

#define COOKIE_P ((long **)0x5a0)



WORD gl_apid;
static WORD aes_handle;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;
RSHDR *rs_hdr;
char **rs_frstr;
OBJECT **rs_trindex;
unsigned short rs_ntree;

static WORD vdo;
static WORD monitor_type;
static char nvdivga_inf[128];
static char assign_sys[128];
static LIST_BOX *color_lbox; 
static DIALOG *dialog;
static const char *lbox_names[MAX_DEPTHS];
static short name_count;
static WORD bpp_index;
static struct res *res_tab;
static struct res *cur_res;
static WORD must_shutdown;

WORD (objc_sysvar)(WORD ob_svmode, WORD ob_svwhich, WORD ob_svinval1, WORD ob_svinval2, WORD *ob_svoutval1, WORD *ob_svoutval2);
void my_aes(void);
WORD (form_xdial)( WORD fo_diflag, WORD fo_dilittlx,
               WORD fo_dilittly, WORD fo_dilittlw,
               WORD fo_dilittlh, WORD fo_dibigx,
               WORD fo_dibigy, WORD fo_dibigw, WORD fo_dibigh,
               void **flydial );
WORD (form_xdo)( OBJECT *tree, WORD startob, WORD *lastcrsr, void *tabs, void *flydial);

static void redraw_obj(DIALOG *dialog, WORD obj);

static const char *const bpp_tab[MAX_DEPTHS] = {
	"  2",
	"  4",
	" 16",
	"256",
	"32K",
	"65K",
	"16M",
	"16M"
};

#define N_ITEMS CHGRES_BOX_LAST-CHGRES_BOX_FIRST+1
WORD const ctrl_objs[5] = { CHGRES_BOX, CHGRES_UP, CHGRES_DOWN, CHGRES_BACK, CHGRES_SLIDER };
WORD const objs[N_ITEMS] = {
	CHGRES_BOX_FIRST,
	CHGRES_BOX_FIRST+1,
	CHGRES_BOX_FIRST+2,
	CHGRES_BOX_FIRST+3,
	CHGRES_BOX_FIRST+4,
	CHGRES_BOX_FIRST+5,
	CHGRES_BOX_FIRST+6,
	CHGRES_BOX_FIRST+7,
	CHGRES_BOX_FIRST+8,
	CHGRES_BOX_LAST
};




static int do_dialog(OBJECT *tree)
{
	GRECT gr;
	void *flydial;
	WORD lastcrsr;
	int ret;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	form_center(tree, &gr.g_x, &gr.g_y, &gr.g_w, &gr.g_h);
	form_xdial(FMD_START, gr.g_x, gr.g_y, gr.g_w, gr.g_h, gr.g_x, gr.g_y, gr.g_w, gr.g_h, &flydial);
	objc_draw(tree, ROOT, MAX_DEPTH, gr.g_x, gr.g_y, gr.g_w, gr.g_h);
	ret = form_xdo(tree, ROOT, &lastcrsr, NULL, flydial);
	ret &= 0x7fff;
	form_xdial(FMD_FINISH, gr.g_x, gr.g_y, gr.g_w, gr.g_h, gr.g_x, gr.g_y, gr.g_w, gr.g_h, &flydial);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	tree[ret].ob_state &= ~OS_SELECTED;
	return ret;
}


#ifdef __PUREC__
#pragma warn -par
#endif

static WORD _CDECL set_item(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, _WORD obj_index, void *user_data, GRECT *rect, _WORD first)
{
	char *text;
	const char *src;
	
	text = tree[obj_index].ob_spec.tedinfo->te_ptext;
	if (item != NULL)
	{
		if (((struct res *)item)->base.selected)
			tree[obj_index].ob_state |= OS_SELECTED;
		else
			tree[obj_index].ob_state &= ~OS_SELECTED;
		src = ((struct res *)item)->base.desc;
		if (*text)
			*text++ = ' ';
		while (*text && *src)
			*text++ = *src++;
	} else
	{
		tree[obj_index].ob_state &= ~OS_SELECTED;
	}
	while (*text)
		*text++ = ' ';
	return obj_index;
}


static void _CDECL select_item(LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, _WORD obj_index, _WORD last_state)
{
	struct res *res;
	
	if (item != NULL)
	{
		res = (struct res *)item;
		if (cur_res == NULL)
		{
			tree[CHGRES_OK].ob_state &= ~OS_DISABLED;
			tree[CHGRES_OK].ob_flags |= OF_SELECTABLE;
			tree[CHGRES_OK].ob_flags |= OF_DEFAULT;
			redraw_obj((DIALOG *)user_data, CHGRES_OK);
		}
		if (res->base.flags & FLAG_INFO)
		{
			tree[CHGRES_INFO].ob_state &= ~OS_DISABLED;
			tree[CHGRES_INFO].ob_flags |= OF_SELECTABLE;
		} else
		{
			tree[CHGRES_INFO].ob_state |= OS_DISABLED;
			tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
		}
		redraw_obj((DIALOG *)user_data, CHGRES_INFO);
		cur_res = res;
	}
}


static void set_bpp(WORD bpp_index)
{
	const char *src;
	char *dst;
	
	src = bpp_tab[bpp_index];
	dst = rs_trindex[MAIN_DIALOG][CHGRES_COLORS].ob_spec.free_string;
	if (*dst)
		*dst++ = ' ';
	if (*dst)
		*dst++ = ' ';
	while (*dst && *src)
		*dst++ = *src++;
	while (*dst)
		*dst++ = ' ';
}


static void init_lbox_names(void)
{
	int i;
	const char **p;
	
	for (i = 0; i < MAX_DEPTHS; i++)
		lbox_names[i] = NULL;
	p = lbox_names;
	name_count = 0;
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		if (possible_resolutions[i] != NULL)
		{
			*p++ = bpp_tab[i];
			name_count++;
		}
	}
}


static int popup_to_index(int idx)
{
	int i;
	
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		if (possible_resolutions[i] != NULL)
			--idx;
		if (idx < 0)
			return i;
	}
	return -1;
}


static int index_to_popup(int bpp)
{
	int i;
	int idx;
	
	idx = -1;
	for (i = 0; i <= bpp; i++)
		if (possible_resolutions[i] != NULL)
			idx++;
	return idx;
}


static void show_info(struct res *res)
{
	OBJECT *tree;
	long linesize;
	short orig_hres;
	short orig_vres;
	
	tree = rs_trindex[INFO_DIALOG];
	sprintf(tree[INFO_HRES].ob_spec.free_string, "%4d", res->base.hres);
	sprintf(tree[INFO_VRES].ob_spec.free_string, "%4d", res->base.vres);
	sprintf(tree[INFO_FREQ].ob_spec.free_string, "%4d", res->freq);
	sprintf(tree[INFO_VIRT_HRES].ob_spec.tedinfo->te_ptext, "%4d", res->base.virt_hres);
	sprintf(tree[INFO_VIRT_VRES].ob_spec.tedinfo->te_ptext, "%4d", res->base.virt_vres);
	tree[INFO_STR_PULSE].ob_flags |= OF_HIDETREE;
	tree[INFO_STR_MHZ].ob_flags |= OF_HIDETREE;
	if (do_dialog(tree) == INFO_OK)
	{
		orig_hres = res->base.virt_hres;
		orig_vres = res->base.virt_vres;
		
		res->base.virt_hres = atoi(tree[INFO_VIRT_HRES].ob_spec.tedinfo->te_ptext);
		res->base.virt_vres = atoi(tree[INFO_VIRT_VRES].ob_spec.tedinfo->te_ptext);
		if ((res->base.virt_hres & 15) != 0 || (res->base.virt_vres & 15) != 0)
		{
			res->base.virt_hres &= -16;
			res->base.virt_vres &= -16;
			do_dialog(rs_trindex[ERR_VIRTUAL_RES]);
		}
		if (res->base.virt_hres < res->base.hres)
			res->base.virt_hres = res->base.hres;
		if (res->base.virt_vres < res->base.vres)
			res->base.virt_vres = res->base.vres;
		linesize = (long)res->base.virt_hres * res->planes;
		/* FIXME: nonsense, that will restrict truecolor modes to a width of 512 */
		if (linesize > 16368)
		{
			res->base.virt_hres = orig_hres;
			res->base.virt_vres = orig_vres;
			do_dialog(rs_trindex[ERR_RES_TOO_LARGE]);
		} else
		{
			if ((linesize * res->base.virt_vres) / 8 > 1048576L) /* FIXME: hard coded */
			{
				res->base.virt_hres = orig_hres;
				res->base.virt_vres = orig_vres;
				do_dialog(rs_trindex[ERR_RES_TOO_LARGE]);
			}
		}
		sprintf(res->base.desc, "%4d * %4d, ET 4000", res->base.virt_hres, res->base.virt_vres);
		if (res->base.hres != res->base.virt_hres || res->base.vres != res->base.virt_vres)
		{
			strcat(res->base.desc, ", ");
			strcat(res->base.desc, rs_frstr[FS_VIRTUAL]);
		}
		res_tab = sort_restab(res_tab);
		lbox_set_items(color_lbox, (LBOX_ITEM *)res_tab);
		lbox_update(color_lbox, NULL);
		redraw_obj(dialog, CHGRES_BOX);
	}
}


static WORD _CDECL hdl_obj(DIALOG *dlg, EVNT *events, _WORD obj, _WORD clicks, void *data)
{
	WORD index;
	OBJECT *tree;
	GRECT gr;
	
	wdlg_get_tree(dlg, &tree, &gr);

	if (obj < 0)
	{
		if (obj != HNDL_CLSD)
			return 1;
		return 0;
	}
	index = obj;
	if (clicks > 1)
		index |= 0x8000;
	if (lbox_do(color_lbox, index) == -1)
		obj = CHGRES_OK;
	switch (obj)
	{
	case CHGRES_COLORS:
		index = index_to_popup(bpp_index);
		index = simple_popup(tree, CHGRES_COLORS, lbox_names, name_count, index);
		if (index >= 0)
		{
			bpp_index = popup_to_index(index);
			res_tab = possible_resolutions[bpp_index];
			set_bpp(bpp_index);
			lbox_set_items(color_lbox, (LBOX_ITEM *)res_tab);
			lbox_set_asldr(color_lbox, 0, NULL);
			lbox_update(color_lbox, NULL);
			cur_res = (struct res *)lbox_get_slct_item(color_lbox);
			if (cur_res != NULL)
			{
				tree[CHGRES_OK].ob_state &= ~OS_DISABLED;
				tree[CHGRES_OK].ob_flags |= OF_SELECTABLE;
				tree[CHGRES_OK].ob_flags |= OF_DEFAULT;
				if (cur_res->base.flags & FLAG_INFO)
				{
					tree[CHGRES_INFO].ob_state &= ~OS_DISABLED;
					tree[CHGRES_INFO].ob_flags |= OF_SELECTABLE;
				} else
				{
					tree[CHGRES_INFO].ob_state |= OS_DISABLED;
					tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
				}
#if 0
				tree[CHGRES_SAVE].ob_state &= ~OS_DISABLED;
				tree[CHGRES_SAVE].ob_flags |= OF_SELECTABLE;
#endif
			} else
			{
				tree[CHGRES_OK].ob_state |= OS_DISABLED;
				tree[CHGRES_OK].ob_flags &= ~OF_SELECTABLE;
				tree[CHGRES_OK].ob_flags &= ~OF_DEFAULT;
				tree[CHGRES_INFO].ob_state |= OS_DISABLED;
				tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
#if 0
				tree[CHGRES_SAVE].ob_state |= OS_DISABLED;
				tree[CHGRES_SAVE].ob_flags &= ~OF_SELECTABLE;
#endif
			}
			redraw_obj(dlg, ROOT);
		}
		break;
#if 0
	case CHGRES_SAVE:
		change_magx_inf(cur_res->rez, cur_res->vmode);
		tree[CHGRES_SAVE].ob_state &= ~OS_SELECTED;
		redraw_obj(dlg, CHGRES_SAVE);
		break;
#endif
	case CHGRES_INFO:
		show_info(cur_res);
		tree[CHGRES_INFO].ob_state &= ~OS_SELECTED;
		redraw_obj(dlg, CHGRES_INFO);
		break;
	case CHGRES_OK:
		must_shutdown = 1;
		return 0;
	case CHGRES_CANCEL:
		must_shutdown = 0;
		return 0;
	}
	return 1;
}


static int select_res(void)
{
	OBJECT *tree;
	EVNT events;
	
	tree = rs_trindex[MAIN_DIALOG];
	if (cur_res != NULL)
	{
		tree[CHGRES_OK].ob_state &= ~OS_DISABLED;
		tree[CHGRES_OK].ob_flags |= OF_SELECTABLE;
		tree[CHGRES_OK].ob_flags |= OF_DEFAULT;
		tree[CHGRES_INFO].ob_state &= ~OS_DISABLED;
		tree[CHGRES_INFO].ob_flags |= OF_SELECTABLE;
#if 0
		tree[CHGRES_SAVE].ob_state &= ~OS_DISABLED;
		tree[CHGRES_SAVE].ob_flags |= OF_SELECTABLE;
#endif
	} else
	{
		tree[CHGRES_OK].ob_state |= OS_DISABLED;
		tree[CHGRES_OK].ob_flags &= ~OF_SELECTABLE;
		tree[CHGRES_OK].ob_flags &= ~OF_DEFAULT;
		tree[CHGRES_INFO].ob_state |= OS_DISABLED;
		tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
#if 0
		tree[CHGRES_SAVE].ob_state |= OS_DISABLED;
		tree[CHGRES_SAVE].ob_flags &= ~OF_SELECTABLE;
#endif
	}
	tree[CHGRES_SAVE].ob_flags |= OF_HIDETREE;
	tree[CHGRES_SAVE].ob_flags &= ~OF_SELECTABLE;
	tree[CHGRES_INFO].ob_flags &= ~OF_HIDETREE;
	init_lbox_names();
	set_bpp(bpp_index);
	dialog = wdlg_create((HNDL_OBJ)hdl_obj, tree, NULL, 0, NULL, 0);
	if (dialog != NULL)
	{
		color_lbox = lbox_create(tree, (SLCT_ITEM)select_item, (SET_ITEM)set_item, (LBOX_ITEM *)res_tab,
			CHGRES_BOX_LAST-CHGRES_BOX_FIRST+1, 0,
			ctrl_objs, objs,
			LBOX_VERT|LBOX_AUTO|LBOX_AUTOSLCT|LBOX_REAL|LBOX_SNGL, 40,
			dialog, dialog, 0, 0, 0, 0);
		if (color_lbox != NULL)
		{
			if (wdlg_open(dialog, rs_frstr[FS_CHANGE_RES], NAME|CLOSER|MOVER, -1, -1, 0, NULL))
			{
				do
				{
#ifdef __GNUC__
					events.mwhich = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						events.msg,
						0,
						&events.mx, &events.my, &events.mbutton, &events.kstate, &events.key, &events.mclicks);
#else
					events.mwhich = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						events.msg,
						0, 0,
						&events.mx, &events.my, &events.mbutton, &events.kstate, &events.key, &events.mclicks);
#endif
				} while (wdlg_evnt(dialog, &events) != 0);
#ifdef __GNUC__
				wdlg_close(dialog, NULL, NULL);
#else
				wdlg_close(dialog);
#endif
			}
			lbox_delete(color_lbox);
		}
		wdlg_delete(dialog);
	}
	return must_shutdown;
}


static long get_vdo(void);
static long get_shiftmod(void);
static long get_ttshiftmod(void);
static int is_rez_assigned(int rez);


static void init_res(void)
{
	int i;
	short currez;
	int vmode;
	struct res **table;

	read_assign_sys(assign_sys);
	load_nvdivga_inf();
	for (i = 0; i < MAX_DEPTHS; i++)
		possible_resolutions[i] = NULL;
	monitor_type = MON_VGA;
	bpp_index = BPS1;
	res_tab = NULL;
	vdo = (WORD)(Supexec(get_vdo) >> 16);
	currez = Getrez() + 2;
	vmode = 0;
	table = NULL;
	switch (vdo)
	{
	case 0: /* ST-compatible hardware */
	case 1: /* STE-compatible hardware */
		{
		int shiftmod;
		shiftmod = (WORD)Supexec(get_shiftmod) + 2;
		switch (shiftmod)
		{
		case ST_LOW:
		case ST_MED:
			monitor_type = MON_COLOR;
			break;
		case ST_HIGH:
			monitor_type = MON_MONO;
			break;
		}
		if (monitor_type == MON_MONO)
		{
			table = st_mono_table;
		} else
		{
			table = st_color_table;
		}
		}
		break;

	case 2: /* TT-compatible hardware */
		{
		int shiftmod = (WORD)Supexec(get_ttshiftmod) + 2;
		switch (shiftmod)
		{
		case ST_MED:
		case ST_HIGH:
		case ST_LOW:
		case TT_MED:
		case TT_LOW:
			monitor_type = MON_VGA;
			break;
		case TT_HIGH:
			monitor_type = MON_MONO;
			bpp_index = BPS1;
			break;
		}
		if (monitor_type == MON_MONO)
		{
			table = tt_mono_table;
		} else
		{
			table = tt_color_table;
		}
		}
		break;

	case 3:
		currez = FALCON_REZ;
		vmode = Vsetmode(-1) & ~PAL;
		monitor_type = mon_type();
		bpp_index = Vsetmode(-1) & NUMCOLS;
		if (monitor_type == MON_MONO)
		{
			table = falc_mono_table;
		} else if (monitor_type == MON_VGA)
		{
			table = vga_res_table;
		} else
		{
			table = tv_res_table;
		}
		break;
	default:
		currez = 0;
		break;
	}
	
	if (table != NULL)
	{
		for (i = 0; i < MAX_DEPTHS; i++)
			possible_resolutions[i] = *table++;
	}
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		struct res **respp;
		struct res *res;
		int j;

		respp = &possible_resolutions[i];
		while (*respp != NULL)
		{
			res = *respp;
			for (j = 0; j < NUM_ET4000; j++)
			{
				if (res->base.rez == et4000_driver_ids[j])
					*respp = res->base.next;
			}
			respp = &res->base.next;
		}
		
		for (j = 0; j < NUM_ET4000; j++)
		{
			if (valid_planes[i] == et4000_planes[j])
			{
				respp = &possible_resolutions[i];
				while (*respp != NULL)
					respp = &(*respp)->base.next;
				*respp = vgainf_modes[j];
				break;
			}
		}
	}
	
	if (is_rez_assigned(currez))
	{
		struct res *res;
		int j;

		for (j = 0; j < MAX_DEPTHS; j++)
		{
			res = possible_resolutions[j];
			while (res != NULL)
			{
				if (res->base.rez == currez && (res->base.flags & FLAG_DEFMODE))
				{
					vmode = res->base.vmode;
					break;
				}
				res = res->base.next;
			}
		}
	}
	
	cur_res = NULL;
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		struct res *res;

		if (possible_resolutions[i] != NULL)
		{
			possible_resolutions[i] = sort_restab(possible_resolutions[i]);
			res = possible_resolutions[i];
			while (res != NULL)
			{
				if (res->base.rez == currez && res->base.vmode == vmode)
				{
					cur_res = res;
					res->base.selected = TRUE;
					bpp_index = i;
					res_tab = possible_resolutions[i];
					break;
				}
				res = res->base.next;
			}
		}
	}
}


static long get_vdo(void)
{
	long *jar = *COOKIE_P;
	
	if (jar != 0)
	{
		while (jar[0] != 0)
		{
			if (jar[0] == 0x5F56444FL) /* '_VDO' */
			{
				return jar[1];
			}
			jar += 2;
		}
	}
	return 0;
}


static long get_shiftmod(void)
{
	unsigned char shiftmod = *((unsigned char *)0xFFFF8260UL);
	shiftmod &= 3;
	return shiftmod;
}


static long get_ttshiftmod(void)
{
	unsigned char shiftmod = *((unsigned char *)0xFFFF8262UL);
	shiftmod &= 7;
	return shiftmod;
}


static int is_rez_assigned(int rez)
{
	int i;
	
	for (i = 0; i < NUM_ET4000; i++)
		if (rez == et4000_driver_ids[i])
			return TRUE;
	return FALSE;
}


static void create_vgainf_mode(struct vgainf *inf, struct vgainf_mode *mode, short planes, short idx);

void load_nvdivga_inf(void)
{
	short rez[NUM_ET4000];
	long size;
	struct vgainf *inf;
	struct vgainf_mode *mode;
	int i;
	
	inf = (struct vgainf *)load_file(nvdivga_inf, &size);
	if (inf == NULL)
		return;
	mode = (struct vgainf_mode *)((char *)inf + sizeof(*inf));
	if (inf->vgainf_nummodes > 0)
	{
		for (i = 0; i < NUM_ET4000; i++)
			rez[i] = 0;
		while (mode != (struct vgainf_mode *)-1)
		{
			/* convert offsets to pointer */
			mode->vga_modename = (char *)((long)mode + (long)mode->vga_modename);
			mode->vga_ts_regs = (unsigned char *)((long)mode + (long)mode->vga_ts_regs);
			mode->vga_crtc_regs = (unsigned char *)((long)mode + (long)mode->vga_crtc_regs);
			mode->vga_atc_regs = (unsigned char *)((long)mode + (long)mode->vga_atc_regs);
			mode->vga_gdc_regs = (unsigned char *)((long)mode + (long)mode->vga_gdc_regs);
			if (mode->vga_next != (struct vgainf_mode *)-1)
				mode->vga_next = (struct vgainf_mode *)((long)mode + (long)mode->vga_next);
			for (i = 0; i < NUM_ET4000; i++)
			{
				if (et4000_planes[i] == mode->vga_planes)
				{
					create_vgainf_mode(inf, mode, rez[i], i);
					rez[i]++;
				}
			}
			switch (mode->vga_planes)
			{
			case 1:
				create_vgainf_mode(inf, mode, rez[1], 1);
				rez[1]++;
				break;
			case 16:
				create_vgainf_mode(inf, mode, rez[3], 3);
				rez[3]++;
				break;
			}
			mode = mode->vga_next;
		}
	}
	Mfree(inf);
}


static void create_vgainf_mode(struct vgainf *inf, struct vgainf_mode *mode, short modeidx, short idx)
{
	struct res *res;
	
	res = (struct res *)Malloc(sizeof(*res));
	if (res == NULL)
		return;
	res->base.selected = FALSE;
	res->base.desc = res->descbuf;
	res->base.vmode = modeidx + SVEXT;
	res->base.flags = FLAG_INFO;
	res->planes = et4000_planes[idx];
	res->base.rez = et4000_driver_ids[idx];
	res->base.virt_hres = mode->vga_xres + 1;
	res->base.virt_vres = mode->vga_yres + 1;
	res->base.hres = mode->vga_visible_xres + 1;
	res->base.vres = mode->vga_visible_yres + 1;
	res->freq = mode->vga_vfreq / 10;
	res->mode_offset = (long)mode - (long)inf;
	if (modeidx == inf->vgainf_defmode[idx])
		res->base.flags |= FLAG_DEFMODE;
	sprintf(res->base.desc, "%4d * %4d, ET 4000", res->base.virt_hres, res->base.virt_vres);
	if (res->base.hres != res->base.virt_hres || res->base.vres != res->base.virt_vres)
	{
		strcat(res->base.desc, ", ");
		strcat(res->base.desc, rs_frstr[FS_VIRTUAL]);
	}
	res->base.next = vgainf_modes[idx];
	vgainf_modes[idx] = res;
}


static int count_res(struct res *res);
static int cmp_res (const void *res1, const void *res2);

struct res *sort_restab(struct res *res)
{
	struct res **table;
	int count;
	struct res **respp;
	struct res *ret;
	
	count = count_res(res);
	ret = res;
	table = (struct res **)Malloc(count * sizeof(*table));
	if (table != NULL)
	{
		respp = table;
		while (res != NULL)
		{
			*respp++ = res;
			res = res->base.next;
		}
		qsort(table, count, sizeof(*table), cmp_res);
		ret = table[0];
		respp = table;
		while (count > 1)
		{
			respp[0]->base.next = respp[1];
			respp++;
			count--;
		}
		respp[0]->base.next = NULL;
		Mfree(table);
	}
	return ret;
}


static int count_res(struct res *res)
{
	int count;

	count = 0;
	while (res != NULL)
	{
		res = res->base.next;
		count++;
	}
	return count;
}


static int cmp_res (const void *res1, const void *res2)
{
	const struct res *r1 = *(const void *const *)res1;
	const struct res *r2 = *(const void *const *)res2;
	if ((r1->base.virt_hres > r2->base.virt_hres) ||
     ((r1->base.virt_hres >= r2->base.virt_hres &&
      ((r1->base.virt_vres > r2->base.virt_vres ||
       ((r1->base.virt_vres >= r2->base.virt_vres &&
        ((r1->base.hres > r2->base.hres ||
         ((r1->base.hres >= r2->base.hres &&
          ((r1->base.vres > r2->base.vres ||
           ((r1->base.vres >= r2->base.vres &&
            (((r1->base.flags & FLAG_INFO) != 0)) && ((r2->base.flags & FLAG_INFO) == 0 ||
             r1->freq > r2->freq))))))))))))))))
	    return 1;
	return -1;
}


static int change_nvdivga_inf(struct res *res);


static int start_shutdown(struct res *cur)
{
	char buf[32];
	char numbuf[8];
	int ret = TRUE;
	int i;
	struct res *res;
	
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		for (res = possible_resolutions[i]; res != NULL; res = res->base.next)
		{
			if ((res->base.flags & FLAG_INFO) && res == cur)
				ret = change_nvdivga_inf(res);
		}
	}
	if (ret)
	{
		itoa(cur->base.rez, numbuf, 10);
		strcpy(&buf[1], numbuf);
		strcat(&buf[1], " 0 ");
		itoa(cur->base.vmode, numbuf, 10);
		strcat(&buf[1], numbuf);
		buf[0] = (char)strlen(&buf[1]);
		shel_write(1, 1, 1, "SHUTDOWN.PRG", buf); /* BUG: return value ignored */
	}
	return ret;
}


static int change_nvdivga_inf(struct res *res)
{
	long fd;
	int i;
	short vmode;
	struct vgainf_mode mode;
	long offset;
	
	fd = Fopen(nvdivga_inf, FO_WRITE);
	if (fd > 0)
	{
		for (i = 0; i < NUM_ET4000; i++)
		{
			if (et4000_planes[i] == res->planes)
			{
				vmode = res->base.vmode + 0xc000;
				offset = offsetof(struct vgainf, vgainf_defmode);
				offset += 2 * (long)i;
				Fseek(offset, (short)fd, SEEK_SET);
				Fwrite((short)fd, sizeof(vmode), &vmode);
				break;
			}
		}
		mode.vga_xres = res->base.virt_hres - 1;
		mode.vga_yres = res->base.virt_vres - 1;
		offset = offsetof(struct vgainf_mode, vga_xres) + res->mode_offset;
		Fseek(offset, (short)fd, SEEK_SET);
		Fwrite((short)fd, 2 * sizeof(mode.vga_xres), &mode.vga_xres);
		Fclose((short)fd);
		return TRUE;
	}
	return FALSE;
}


static int get_paths(void)
{
	strcpy(nvdivga_inf, "A:\\AUTO\\NVDIVGA.INF");
	nvdivga_inf[0] += Dgetdrv();
	strcpy(assign_sys, "A:\\ASSIGN.SYS");
	assign_sys[0] += Dgetdrv();
	return TRUE;
}


static void fix_3d(OBJECT *tree);

static void fix_rsc(void)
{
	WORD dummy;
	OBJECT *o;

#ifdef __GNUC__
	rs_hdr = *((void **)&aes_global[7]);
#else
	rs_hdr = *((void **)&_GemParBlk.global[7]);
#endif
	rs_trindex = (OBJECT **)(((char *)rs_hdr + rs_hdr->rsh_trindex));
	rs_ntree = rs_hdr->rsh_ntree;
	rs_frstr = (char **)(((char *)rs_hdr + rs_hdr->rsh_frstr));
	rs_trindex[MAIN_DIALOG][CHGRES_UP].ob_y -= 1;
	rs_trindex[MAIN_DIALOG][CHGRES_DOWN].ob_y -= 1;
	o = &rs_trindex[MAIN_DIALOG][CHGRES_ICON];
	o->ob_y += (o->ob_height - o->ob_spec.iconblk->ib_hicon) / 2;
	rs_trindex[INFO_DIALOG][INFO_VIRT_VRES].ob_y -= gl_hchar / 2;
	rs_trindex[INFO_DIALOG][INFO_VIRT_BOX].ob_height -= gl_hchar / 2;
	if (objc_sysvar(SV_INQUIRE, AD3DVAL, 0, 0, &dummy, &dummy) == 0)
		fix_3d(rs_trindex[MAIN_DIALOG]);
}


static void fix_3d(OBJECT *tree)
{
	tree[CHGRES_UP].ob_spec.obspec.framesize = 1;
	tree[CHGRES_DOWN].ob_spec.obspec.framesize = 1;
	tree[CHGRES_SLIDER].ob_spec.obspec.framesize = 1;
	tree[CHGRES_BACK].ob_spec.obspec.interiorcol = 1;
	tree[CHGRES_BACK].ob_spec.obspec.fillpattern = 1;
}


static void redraw_obj(DIALOG *dlg, WORD obj)
{
	OBJECT *tree;
	GRECT gr;
	
	wdlg_get_tree(dlg, &tree, &gr);
	wind_update(BEG_UPDATE);
	wdlg_redraw(dlg, &gr, obj, MAX_DEPTH);
	wind_update(END_UPDATE);
}


int main(void)
{
	int ret = -1;
	
	gl_apid = appl_init();
	if (gl_apid != -1)
	{
		aes_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
		graf_mouse(ARROW, NULL);
		if (rsrc_load("CHGRES.RSC") != 0)
		{
			fix_rsc();
			if (get_paths())
			{
				init_res();
				if (select_res())
				{
					if (start_shutdown(cur_res) == 0)
					{
						do_dialog(rs_trindex[ERR_RESCHG]);
					} else
					{
						change_magx_inf(cur_res->base.rez, cur_res->base.vmode);
					}
				}
			} else
			{
				do_dialog(rs_trindex[ERR_RESCHG]);
			}
			rsrc_free();
			ret = 0;
		}
		appl_exit();
	}
	
	return ret;
}
