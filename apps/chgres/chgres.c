#ifdef __PUREC__
#include <portab.h>
#include <aes.h>
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#include <tos.h>
#else
#include <gemx.h>
#include <osbind.h>
#endif
#include <mint/falcon.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "de/chgres.h"
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


#define COOKIE_P ((long **)0x5a0)


/* Values returned by VgetMonitor() */
#ifndef MON_MONO
#define MON_MONO		0
#define MON_COLOR		1
#define MON_VGA			2
#define MON_TV			3
#endif
#ifndef VGA
#define VGA 0x10
#endif
#ifndef PAL
#define PAL 0x20
#endif
#ifndef NUMCOLS
#define NUMCOLS 7
#endif
#ifndef SVEXT
#define SVEXT 0x4000
#endif

#define SV_INQUIRE		0	/* inquire sysvar data, see mt_objc_sysvar() */
#define AD3DVAL      6                  /* AES 4.0     */


WORD gl_apid;
static WORD aes_handle;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;
static char **rs_frstr;
static OBJECT **rs_trindex;

static WORD vdo;
WORD magicpc;
static struct res *possible_resolutions[MAX_DEPTHS];
static struct res *vgainf_modes[NUM_ET4000];
static struct res *nvdipc_modes[NUM_NVDIPC];
static WORD bpp_index;
static WORD monitor_type;
static char nvdivga_inf[] = "A:\\AUTO\\NVDIVGA.INF";
static char nvdipc_inf[] = "A:\\AUTO\\NVDIPC.INF";
static char assign_sys[] = "A:\\ASSIGN.SYS";
static LIST_BOX *color_lbox; 
static DIALOG *dialog;
static const char *lbox_names[MAX_DEPTHS];
static short name_count;
static struct res *res_tab;
static struct res *cur_res;
static WORD must_shutdown;



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
static WORD const ctrl_objs[5] = { CHGRES_BOX, CHGRES_UP, CHGRES_DOWN, CHGRES_BACK, CHGRES_SLIDER };
static WORD const objs[N_ITEMS] = {
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

static short const valid_planes[MAX_DEPTHS] = { 1, 2, 4, 8, 15, 16, 24, 32 };
static short const et4000_planes[NUM_ET4000] = { 1, 4, 8, 15, 16, 24 };
static short const nvdipc_planes[NUM_NVDIPC] = { 8, 15, 16, 32 };

#define R (struct res *)

static struct resbase st_mono_resolutions[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch     ",ST_HIGH, 0,                                             0, 640, 400, 640, 400 },
};
struct res *st_mono_table[MAX_DEPTHS] = {
	R &st_mono_resolutions[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase st_color_resolutions[] = {
	{ NULL,                       0, " 640 *  200, ST Mittel   ",ST_MED, 0,                                              0, 640, 200, 640, 200 },
	{ NULL,                       0, " 320 *  200, ST Niedrig  ",ST_LOW, 0,                                              0, 320, 200, 320, 200 },
	{ NULL,                       0, NULL, 0, 0, 0, 0, 0, 0, 0 }
};
struct res *st_color_table[MAX_DEPTHS] = {
	NULL,
	R &st_color_resolutions[0],
	R &st_color_resolutions[1],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase tt_color_resolutions[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch     ",ST_HIGH, 0,                                             0, 640, 400, 640, 400 },
	{ NULL,                       0, NULL, 0, 0, 0, 0, 0, 0, 0 },
	{ NULL,                       0, " 640 *  200, ST Mittel   ",ST_MED, 0,                                              0, 640, 200, 640, 200 },
	{ R &tt_color_resolutions[4], 0, " 320 *  200, ST Niedrig  ",ST_LOW, 0,                                              0, 320, 200, 320, 200 },
	{ NULL,                       0, " 640 *  480, TT Mittel   ",TT_MED, 0,                                              0, 640, 480, 640, 480 },
	{ NULL,                       0, " 320 *  480, TT Niedrig  ",TT_LOW, 0,                                              0, 320, 480, 320, 480 }
};
struct res *tt_color_table[MAX_DEPTHS] = {
	R &tt_color_resolutions[0],
	R &tt_color_resolutions[2],
	R &tt_color_resolutions[3],
	R &tt_color_resolutions[5],
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase tt_mono_resolutions[] = {
	{ NULL,                       0, "1280 *  960, TT Hoch     ",TT_HIGH, 0,                                             0, 1280, 960, 1280, 960 }
};
struct res *tt_mono_table[MAX_DEPTHS] = {
	R &tt_mono_resolutions[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};



static struct resbase vga_resolutions[] = {
	{ R &vga_resolutions[1],      0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS1,                    0, 640, 240, 640, 240 },
	{ R &vga_resolutions[2],      0, " 640 *  400, ST Hoch     ",FALCON_REZ, STMODES|VGA|COL80|BPS1,                     0, 640, 400, 640, 400 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS1,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[4],      0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS2,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[5],      0, " 320 *  480",              FALCON_REZ, VGA|BPS2,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[6],      0, " 640 *  200, ST Mittel   ",FALCON_REZ, VERTFLAG|STMODES|VGA|COL80|BPS2,            0, 640, 200, 640, 200 },
	{ R &vga_resolutions[7],      0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS2,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS2,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[9],      0, " 320 *  200, ST Niedrig  ",FALCON_REZ, VERTFLAG|STMODES|VGA|BPS4,                  0, 320, 200, 320, 200 },
	{ R &vga_resolutions[10],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS4,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[11],     0, " 320 *  480",              FALCON_REZ, VGA|BPS4,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[12],     0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS4,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS4,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[14],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS8,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[15],     0, " 320 *  480",              FALCON_REZ, VGA|BPS8,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[16],     0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS8,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS8,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[18],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS16,                         0, 320, 240, 320, 240 },
	{ R NULL,                     0, " 320 *  480",              FALCON_REZ, VGA|BPS16,                                  0, 320, 480, 320, 480 }
};

struct res *vga_res_table[MAX_DEPTHS] = {
	R &vga_resolutions[0],
	R &vga_resolutions[3],
	R &vga_resolutions[8],
	R &vga_resolutions[13],
	R &vga_resolutions[17],
	NULL,
	NULL,
	NULL
};


static struct resbase tv_resolutions[] = {
	{ R &tv_resolutions[1],       0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS1,                              0, 640, 200, 640, 200 },
	{ R &tv_resolutions[2],       0, " 640 *  400, ST Hoch     ",FALCON_REZ, VERTFLAG|TV|STMODES|COL80|BPS1,             0, 640, 400, 640, 400 },
	{ R &tv_resolutions[3],       0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS1,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480",              FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS1,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[5],       0, " 320 *  200",              FALCON_REZ, TV|BPS2,                                    0, 320, 200, 320, 200 },
	{ R &tv_resolutions[6],       0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS2,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[7],       0, " 384 *  240",              FALCON_REZ, TV|OVERSCAN|BPS2,                           0, 384, 240, 384, 240 },
	{ R &tv_resolutions[8],       0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS2,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[9],       0, " 640 *  200, ST Mittel   ",FALCON_REZ, TV|STMODES|COL80|BPS2,                      0, 640, 200, 640, 200 },
	{ R &tv_resolutions[10],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS2,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[11],      0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS2,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS2,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[13],      0, " 320 *  200, ST Niedrig  ",FALCON_REZ, TV|STMODES|BPS4,                            0, 320, 200, 320, 200 },
	{ R &tv_resolutions[14],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS4,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[15],      0, " 384 *  240",              FALCON_REZ, OVERSCAN|BPS4,                              0, 384, 240, 384, 240 },
	{ R &tv_resolutions[16],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS4,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[17],      0, " 640 *  200",              FALCON_REZ, COL80|BPS4,                                 0, 640, 200, 640, 200 },
	{ R &tv_resolutions[18],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS4,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[19],      0, " 768 *  240",              FALCON_REZ, OVERSCAN|COL80|BPS4,                        0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS4,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[21],      0, " 320 *  200",              FALCON_REZ, TV|BPS8,                                    0, 320, 200, 320, 200 },
	{ R &tv_resolutions[22],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS8,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[23],      0, " 384 *  240",              FALCON_REZ, TV|OVERSCAN|BPS8,                           0, 384, 240, 384, 240 },
	{ R &tv_resolutions[24],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS8,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[25],      0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS8,                              0, 640, 200, 640, 200 },
	{ R &tv_resolutions[26],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS8,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[27],      0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS8,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS8,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[29],      0, " 320 *  200",              FALCON_REZ, TV|BPS16,                                   0, 320, 200, 320, 200 },
	{ R &tv_resolutions[30],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS16,                          0, 320, 400, 320, 400 },
	{ R &tv_resolutions[31],      0, " 384 *  240",              FALCON_REZ, OVERSCAN|TV|BPS16,                          0, 384, 240, 384, 240 },
	{ R &tv_resolutions[32],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|OVERSCAN|TV|BPS16,                 0, 384, 480, 384, 480 },
	{ R &tv_resolutions[33],      0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS16,                             0, 640, 200, 640, 200 },
	{ R &tv_resolutions[34],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS16,                    0, 640, 400, 640, 400 },
	{ R &tv_resolutions[35],      0, " 768 *  240",              FALCON_REZ, OVERSCAN|TV|COL80|BPS16,                    0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|OVERSCAN|TV|COL80|BPS16,           0, 768, 480, 768, 480 }
};

struct res *tv_res_table[MAX_DEPTHS] = {
	R &tv_resolutions[0],
	R &tv_resolutions[4],
	R &tv_resolutions[12],
	R &tv_resolutions[20],
	R &tv_resolutions[28],
	NULL,
	NULL,
	NULL
};


static struct resbase st_high[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch     ",FALCON_REZ, STMODES|COL80|BPS1,                         0, 640, 400, 640, 400 }
};

struct res *falc_mono_table[MAX_DEPTHS] = {
	R &st_high[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

struct res *magicpc_res_table[MAX_DEPTHS] = {
	R &st_mono_resolutions[0],
	R &st_color_resolutions[0],
	R &st_color_resolutions[1],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

#undef R


static int do_dialog(OBJECT *tree)
{
	GRECT gr;
	void *flydial;
	WORD lastcrsr;
	int ret;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	form_center_grect(tree, &gr);
	form_xdial_grect(FMD_START, &gr, &gr, &flydial);
	objc_draw_grect(tree, ROOT, MAX_DEPTH, &gr);
	ret = form_xdo(tree, ROOT, &lastcrsr, NULL, flydial);
	ret &= 0x7fff;
	form_xdial_grect(FMD_FINISH, &gr, &gr, &flydial);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	tree[ret].ob_state &= ~OS_SELECTED;
	return ret;
}


static WORD _CDECL set_item(struct SET_ITEM_args args)
{
	OBJECT *tree = args.tree;
	char *text;
	struct res *res = (struct res *)args.item;
	WORD obj_index = args.obj_index;
	const char *src;
	
	text = tree[obj_index].ob_spec.tedinfo->te_ptext;
	if (res != NULL)
	{
		if (res->base.selected)
			tree[obj_index].ob_state |= OS_SELECTED;
		else
			tree[obj_index].ob_state &= ~OS_SELECTED;
		src = res->base.desc;
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


static void redraw_obj(DIALOG *dlg, WORD obj)
{
	OBJECT *tree;
	GRECT gr;
	
	wdlg_get_tree(dlg, &tree, &gr);
	wind_update(BEG_UPDATE);
	wdlg_redraw(dlg, &gr, obj, MAX_DEPTH);
	wind_update(END_UPDATE);
}


static void _CDECL select_item(struct SLCT_ITEM_args args)
{
	OBJECT *tree = args.tree;
	struct res *res = (struct res *)args.item;
	DIALOG *dialog = (DIALOG *)args.user_data;
	
	if (res != NULL)
	{
		if (cur_res == NULL)
		{
			tree[CHGRES_OK].ob_state &= ~OS_DISABLED;
			tree[CHGRES_OK].ob_flags |= OF_SELECTABLE;
			tree[CHGRES_OK].ob_flags |= OF_DEFAULT;
			redraw_obj(dialog, CHGRES_OK);
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
		redraw_obj(dialog, CHGRES_INFO);
		cur_res = res;
	}
}


static void set_bpp(WORD bpp_index)
{
	const char *src;
	char *dst;
	OBJECT *tree;
	
	src = bpp_tab[bpp_index];
	tree = rs_trindex[MAIN_DIALOG];
	dst = tree[CHGRES_COLORS].ob_spec.free_string;
	if (*dst)
		*dst++ = ' ';
	if (*dst)
		*dst++ = ' ';
	while (*dst && *src)
		*dst++ = *src++;
	while (*dst)
		*dst++ = ' ';
	if (magicpc)
	{
		switch (valid_planes[bpp_index])
		{
		case 8:
		case 15:
		case 16:
		case 32:
			tree[CHGRES_NEW].ob_state &= ~OS_DISABLED;
			break;
		default:
			tree[CHGRES_NEW].ob_state |= OS_DISABLED;
			break;
		}
	}
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
		if (possible_resolutions[i] == NULL)
		{
			if (magicpc)
			{
				switch (valid_planes[i])
				{
				case 8:
				case 15:
				case 16:
				case 32:
					*p++ = bpp_tab[i];
					name_count++;
					break;
				}
			}
		} else
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
		switch (valid_planes[i])
		{
		default:
			if (possible_resolutions[i] != NULL)
				--idx;
			break;
		case 8:
		case 15:
		case 16:
		case 32:
			if (possible_resolutions[i] != NULL || magicpc)
				--idx;
			break;
		}
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


static int cmp_res(const void *res1, const void *res2)
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
            (((r1->base.flags & FLAG_INFO) != 0)) && (((r2->base.flags & FLAG_INFO) == 0 ||
             r1->freq > r2->freq)))))))))))))))))
	    return 1;
	return -1;
}


static struct res *sort_restab(struct res *res)
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


static void translate_restab(void)
{
	struct res *res;
	char *p;
	
	for (res = res_tab; res != NULL; res = res->base.next)
	{
		if ((p = strstr(res->base.desc, "Niedrig")) != NULL)
			strcpy(p, rs_frstr[FS_LOW]);
		if ((p = strstr(res->base.desc, "Mittel")) != NULL)
			strcpy(p, rs_frstr[FS_MED]);
		if ((p = strstr(res->base.desc, "Hoch")) != NULL)
			strcpy(p, rs_frstr[FS_HIGH]);
	}
}


static void set_items(void)
{
	translate_restab();
	lbox_set_items(color_lbox, (LBOX_ITEM *)res_tab);
	lbox_update(color_lbox, NULL);
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
	sprintf(tree[INFO_FREQ].ob_spec.free_string, "%4d", res->base.flags & FLAG_INFO ? res->freq : 0);
	sprintf(tree[INFO_VIRT_HRES].ob_spec.tedinfo->te_ptext, "%4d", res->base.virt_hres);
	sprintf(tree[INFO_VIRT_VRES].ob_spec.tedinfo->te_ptext, "%4d", res->base.virt_vres);
	if (do_dialog(tree) == INFO_OK && !magicpc)
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
		if (res->planes >= 24)
			linesize = (long)res->base.virt_hres * 4;
		else if (res->planes >= 15)
			linesize = (long)res->base.virt_hres * 2;
		else
			linesize = ((long)res->base.virt_hres * res->planes) >> 3;
		if (linesize > 32700)
		{
			res->base.virt_hres = orig_hres;
			res->base.virt_vres = orig_vres;
			do_dialog(rs_trindex[ERR_RES_TOO_LARGE]);
		} else
		{
			if ((linesize * res->base.virt_vres) > 1048576L) /* FIXME: hard coded */
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
		set_items();
		redraw_obj(dialog, CHGRES_BOX);
	}
}


static void new_res(void)
{
	OBJECT *tree;
	struct res *res;
	
	/* TODO: nvdivga.inf currently cannot be rewritten */
	if (!magicpc)
		return;
	tree = rs_trindex[NEW_RES];
	sprintf(tree[NEW_HRES].ob_spec.tedinfo->te_ptext, "%4d", 640);
	sprintf(tree[NEW_VRES].ob_spec.tedinfo->te_ptext, "%4d", 480);
	if (do_dialog(tree) == NEWRES_OK)
	{
		res = (struct res *)Malloc(sizeof(*res));
		if (res != NULL)
		{
			res->base.selected = FALSE;
			res->base.desc = res->descbuf;
			res->base.vmode = SVEXT|0x200|STMODES|OVERSCAN|7;
			res->base.flags = FLAG_INFO;
			res->planes = valid_planes[bpp_index];
			switch (res->planes)
			{
			case 8:
				res->base.rez = nvdipc_driver_ids[0];
				break;
			case 15:
				res->base.rez = nvdipc_driver_ids[1];
				break;
			case 16:
				res->base.rez = nvdipc_driver_ids[2];
				break;
			case 32:
				res->base.rez = nvdipc_driver_ids[3];
				break;
			}
			res->base.virt_hres = atoi(tree[NEW_HRES].ob_spec.tedinfo->te_ptext);
			res->base.virt_vres = atoi(tree[NEW_VRES].ob_spec.tedinfo->te_ptext);
			if ((res->base.virt_hres & 15) != 0 || (res->base.virt_vres & 7) != 0)
			{
				res->base.virt_hres &= -16;
				res->base.virt_vres &= -8;
				do_dialog(rs_trindex[ERR_VIRTUAL_RES]);
			}
			if (res->base.virt_hres < 512)
				res->base.virt_hres = 512;
			if (res->base.virt_vres < 384)
				res->base.virt_vres = 384;
			res->base.hres = res->base.virt_hres;
			res->base.vres = res->base.virt_vres;
			res->freq = 0;
			res->mode_offset = 0;
			sprintf(res->base.desc, "%4d * %4d", res->base.virt_hres, res->base.virt_vres);
			res->base.next = res_tab;
			res_tab = sort_restab(res);
			possible_resolutions[bpp_index] = res_tab;
			set_items();
			lbox_set_asldr(color_lbox, 0, NULL);
			redraw_obj(dialog, CHGRES_BOX);
		}
	}
}


static void delete_res(void)
{
	struct res *res;
	struct res **respp;
	OBJECT *tree;
	
	/* TODO: nvdivga.inf currently cannot be rewritten */
	if (!magicpc)
		return;
	res = (struct res *)lbox_get_slct_item(color_lbox);
	if (res->base.flags & FLAG_INFO)
	{
		if (do_dialog(rs_trindex[RES_DELETE]) == RES_DELETE_OK)
		{
			respp = &res_tab;
			while (*respp != NULL)
			{
				if (*respp == res)
				{
					*respp = res->base.next;
					Mfree(res);
					cur_res = NULL;
					tree = rs_trindex[MAIN_DIALOG];
					tree[CHGRES_OK].ob_state |= OS_DISABLED;
					tree[CHGRES_OK].ob_flags &= ~OF_SELECTABLE;
					tree[CHGRES_OK].ob_flags &= ~OF_DEFAULT;
					tree[CHGRES_INFO].ob_state |= OS_DISABLED;
					tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
					break;
				}
				respp = &(*respp)->base.next;
			}
			possible_resolutions[bpp_index] = res_tab;
			set_items();
			lbox_set_asldr(color_lbox, 0, NULL);
			redraw_obj(dialog, ROOT);
		}
	}
}


static WORD _CDECL hdl_obj(struct HNDL_OBJ_args args)
{
	DIALOG *dlg;
	WORD obj;
	WORD index;
	OBJECT *tree;
	GRECT gr;
	
	dlg = args.dialog;
	obj = args.obj;
	wdlg_get_tree(dlg, &tree, &gr);

	if (obj < 0)
	{
		if (obj != HNDL_CLSD)
			return 1;
		return 0;
	}
	index = obj;
	if (args.clicks > 1)
		index |= 0x8000;
	if (lbox_do(color_lbox, index) == -1)
		obj = CHGRES_OK;
	switch (obj)
	{
	case CHGRES_BOX_FIRST:
	case CHGRES_BOX_FIRST+1:
	case CHGRES_BOX_FIRST+2:
	case CHGRES_BOX_FIRST+3:
	case CHGRES_BOX_FIRST+4:
	case CHGRES_BOX_FIRST+5:
	case CHGRES_BOX_FIRST+6:
	case CHGRES_BOX_FIRST+7:
	case CHGRES_BOX_FIRST+8:
	case CHGRES_BOX_LAST:
		if (args.events && args.events->kstate == K_CTRL)
			delete_res();
		break;
	case CHGRES_COLORS:
		index = index_to_popup(bpp_index);
		index = simple_popup(tree, CHGRES_COLORS, lbox_names, name_count, index);
		if (index >= 0)
		{
			bpp_index = popup_to_index(index);
			if (bpp_index >= 0)
			{
				res_tab = possible_resolutions[bpp_index];
				set_bpp(bpp_index);
				set_items();
				lbox_set_asldr(color_lbox, 0, NULL);
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
				} else
				{
					tree[CHGRES_OK].ob_state |= OS_DISABLED;
					tree[CHGRES_OK].ob_flags &= ~OF_SELECTABLE;
					tree[CHGRES_OK].ob_flags &= ~OF_DEFAULT;
					tree[CHGRES_INFO].ob_state |= OS_DISABLED;
					tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
				}
				redraw_obj(dlg, ROOT);
			}
		}
		break;
	case CHGRES_INFO:
		show_info(cur_res);
		tree[CHGRES_INFO].ob_state &= ~OS_SELECTED;
		redraw_obj(dlg, CHGRES_INFO);
		break;
	case CHGRES_NEW:
		new_res();
		tree[CHGRES_NEW].ob_state &= ~OS_SELECTED;
		redraw_obj(dlg, CHGRES_NEW);
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
	WORD dummy;
	
	tree = rs_trindex[MAIN_DIALOG];
	if (cur_res != NULL)
	{
		tree[CHGRES_OK].ob_state &= ~OS_DISABLED;
		tree[CHGRES_OK].ob_flags |= OF_SELECTABLE;
		tree[CHGRES_OK].ob_flags |= OF_DEFAULT;
		tree[CHGRES_INFO].ob_state &= ~OS_DISABLED;
		tree[CHGRES_INFO].ob_flags |= OF_SELECTABLE;
	} else
	{
		tree[CHGRES_OK].ob_state |= OS_DISABLED;
		tree[CHGRES_OK].ob_flags &= ~OF_SELECTABLE;
		tree[CHGRES_OK].ob_flags &= ~OF_DEFAULT;
		tree[CHGRES_INFO].ob_state |= OS_DISABLED;
		tree[CHGRES_INFO].ob_flags &= ~OF_SELECTABLE;
	}
	if (magicpc)
	{
		tree[CHGRES_INFO].ob_flags |= OF_HIDETREE;
		tree[CHGRES_NEW].ob_flags &= ~OF_HIDETREE;
	} else
	{
		tree[CHGRES_INFO].ob_flags &= ~OF_HIDETREE;
		tree[CHGRES_NEW].ob_flags |= OF_HIDETREE;
	}
	init_lbox_names();
	set_bpp(bpp_index);
	dialog = wdlg_create(hdl_obj, tree, NULL, 0, NULL, 0);
	if (dialog != NULL)
	{
		translate_restab();
		color_lbox = lbox_create(tree, select_item, set_item, (LBOX_ITEM *)res_tab,
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
					events.mwhich = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						events.msg,
						0,
						&events.mx, &events.my, &events.mbutton, &events.kstate, &events.key, &events.mclicks);
				} while (wdlg_evnt(dialog, &events) != 0);
				wdlg_close(dialog, &dummy, &dummy);
			}
			lbox_delete(color_lbox);
		}
		wdlg_delete(dialog);
	}
	return must_shutdown;
}


static long get_cookies(void)
{
	long *jar = *COOKIE_P;
	
	if (jar != 0)
	{
		while (jar[0] != 0)
		{
			if (jar[0] == 0x5f56444fL) /* '_VDO' */
				vdo = (WORD)(jar[1] >> 16);
			if (jar[0] == 0x4d675063L) /* 'MgPc' */
				magicpc = TRUE;
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
	
	if (magicpc)
	{
		for (i = 0; i < NUM_NVDIPC; i++)
			if (rez == nvdipc_driver_ids[i])
				return TRUE;
	} else
	{
		for (i = 0; i < NUM_ET4000; i++)
			if (rez == et4000_driver_ids[i])
				return TRUE;
	}
	return FALSE;
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


static void load_nvdivga_inf(void)
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


static void create_nvdipcinf_mode(struct nvdipcinf *inf, struct nvdipcinf_mode *mode, short modeidx, short idx)
{
	struct res *res;
	
	res = (struct res *)Malloc(sizeof(*res));
	if (res == NULL)
		return;
	res->base.selected = FALSE;
	res->base.desc = res->descbuf;
	res->base.vmode = modeidx + SVEXT;
	res->base.flags = FLAG_INFO;
	res->planes = nvdipc_planes[idx];
	res->base.rez = nvdipc_driver_ids[idx];
	res->base.virt_hres = mode->xres + 1;
	res->base.virt_vres = mode->yres + 1;
	res->base.hres = res->base.virt_hres;
	res->base.vres = res->base.virt_vres;
	res->freq = 0;
	res->mode_offset = 0;
	if (modeidx == inf->defmode[idx])
		res->base.flags |= FLAG_DEFMODE;
	sprintf(res->base.desc, "%4d * %4d", res->base.virt_hres, res->base.virt_vres);
	res->base.next = nvdipc_modes[idx];
	nvdipc_modes[idx] = res;
}


static void load_nvdipc_inf(void)
{
	short rez[NUM_NVDIPC];
	long size;
	struct nvdipcinf *inf;
	struct nvdipcinf_mode *mode;
	long num_modes;
	int i;
	
	inf = (struct nvdipcinf *)load_file(nvdipc_inf, &size);
	if (inf == NULL)
		return;
	mode = inf->modes;
	num_modes = inf->nummodes;
	if (num_modes > 0)
	{
		for (i = 0; i < NUM_NVDIPC; i++)
			rez[i] = 0;
		while (num_modes > 0)
		{
			for (i = 0; i < NUM_NVDIPC; i++)
			{
				if (nvdipc_planes[i] == mode->planes)
				{
					create_nvdipcinf_mode(inf, mode, inf->nummodes - num_modes, i);
					rez[i]++;
				}
			}
			mode++;
			num_modes--;
		}
	}
	Mfree(inf);
}


static void init_res(void)
{
	int i;
	short currez;
	int vmode;
	struct res **table;

	vdo = 0;
	magicpc = 0;
	Supexec(get_cookies);

	read_assign_sys(assign_sys);
	if (magicpc)
		load_nvdipc_inf();
	else
		load_nvdivga_inf();
	for (i = 0; i < MAX_DEPTHS; i++)
		possible_resolutions[i] = NULL;
	monitor_type = MON_VGA;
	bpp_index = BPS1;
	res_tab = NULL;
	currez = Getrez() + 2;
	vmode = 0;
	table = NULL;
	if (magicpc)
	{
		table = magicpc_res_table;
	} else
	{
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
			vmode = VsetMode(-1) & ~PAL;
			monitor_type = VgetMonitor();
			bpp_index = vmode & NUMCOLS;
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

		/*
		 * remove resolutions that are in use by graphic card drivers
		 */
		respp = &possible_resolutions[i];
		while (*respp != NULL)
		{
			res = *respp;
			if (magicpc)
			{
				for (j = 0; j < NUM_NVDIPC; j++)
				{
					if (res->base.rez == nvdipc_driver_ids[j])
						*respp = res->base.next;
				}
			} else
			{
				for (j = 0; j < NUM_ET4000; j++)
				{
					if (res->base.rez == et4000_driver_ids[j])
						*respp = res->base.next;
				}
			}
			respp = &res->base.next;
		}
		
		/*
		 * add graphic card resolutions to the end of the table
		 */
		if (magicpc)
		{
			for (j = 0; j < NUM_NVDIPC; j++)
			{
				if (valid_planes[i] == nvdipc_planes[j])
				{
					respp = &possible_resolutions[i];
					while (*respp != NULL)
						respp = &(*respp)->base.next;
					*respp = nvdipc_modes[j];
					break;
				}
			}
		} else
		{
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


static void fix_3d(OBJECT *tree)
{
	tree[CHGRES_UP].ob_spec.obspec.framesize = 1;
	tree[CHGRES_DOWN].ob_spec.obspec.framesize = 1;
	tree[CHGRES_SLIDER].ob_spec.obspec.framesize = 1;
	tree[CHGRES_BACK].ob_spec.obspec.interiorcol = 1;
	tree[CHGRES_BACK].ob_spec.obspec.fillpattern = 1;
}


static void fix_rsc(void)
{
	WORD dummy;
	OBJECT *tree;
	RSHDR *rs_hdr;
	
	rs_hdr = *((void **)&aes_global[7]);
	rs_trindex = (OBJECT **)(((char *)rs_hdr + rs_hdr->rsh_trindex));
	rs_frstr = (char **)(((char *)rs_hdr + rs_hdr->rsh_frstr));
	tree = rs_trindex[MAIN_DIALOG];
	tree[CHGRES_UP].ob_y -= 1;
	tree[CHGRES_DOWN].ob_y -= 1;
	tree[CHGRES_ICON].ob_y += (tree[CHGRES_ICON].ob_height - tree[CHGRES_ICON].ob_spec.iconblk->ib_hicon) / 2;
	if (objc_sysvar(SV_INQUIRE, AD3DVAL, 0, 0, &dummy, &dummy) == 0)
		fix_3d(tree);
}


static int get_paths(void)
{
	int drv = Dgetdrv();
	if (drv < 26)
		drv += 'A';
	else
		drv += '1' - 26;
	nvdivga_inf[0] = drv;
	nvdipc_inf[0] = drv;
	assign_sys[0] = drv;
	return TRUE;
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
				vmode = res->base.vmode | 0xc000;
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


static int change_nvdipc_inf(struct res *res)
{
	long fd;
	int i;
	struct nvdipcinf inf;
	struct nvdipcinf_mode mode;
	
	fd = Fcreate(nvdipc_inf, 0);
	if (fd > 0)
	{
		inf.length = sizeof(inf);
		inf.magic = 0x4e465043L; /* "NFPC" */
		inf.version = 0x10000L;
		inf.nummodes = 0;
		for (i = 0; i < 16; i++)
			inf.defmode[i] = -1;
		for (i = 0; i < MAX_DEPTHS; i++)
		{
			struct res *resi;

			for (resi = possible_resolutions[i]; resi != NULL; resi = resi->base.next)
			{
				if (res->base.flags & FLAG_INFO)
				{
					if (resi == res)
					{
						switch (valid_planes[i])
						{
						case 8:
							inf.defmode[0] = inf.nummodes;
							break;
						case 15:
							inf.defmode[1] = inf.nummodes;
							break;
						case 16:
							inf.defmode[2] = inf.nummodes;
							break;
						case 32:
							inf.defmode[3] = inf.nummodes;
							break;
						}
					}
					inf.nummodes++;
				}
			}
		}
		Fwrite((short)fd, sizeof(inf), &inf);
		for (i = 0; i < MAX_DEPTHS; i++)
		{
			struct res *resi;

			for (resi = possible_resolutions[i]; resi != NULL; resi = resi->base.next)
			{
				if (res->base.flags & FLAG_INFO)
				{
					mode.length = sizeof(mode);
					mode.planes = resi->planes;
					mode.xres = resi->base.virt_hres - 1;
					mode.yres = resi->base.virt_vres - 1;
					Fwrite((short)fd, sizeof(mode), &mode);
				}
			}
		}
		Fclose((short)fd);
		return TRUE;
	}
	return FALSE;
}


static int start_shutdown(struct res *cur)
{
	char buf[40];
	int ret = TRUE;
	int i;
	struct res *res;
	
	for (i = 0; i < MAX_DEPTHS; i++)
	{
		for (res = possible_resolutions[i]; res != NULL; res = res->base.next)
		{
			if ((res->base.flags & FLAG_INFO) && res == cur)
			{
				if (magicpc)
					ret = change_nvdipc_inf(res);
				else
					ret = change_nvdivga_inf(res);
			}
		}
	}
	if (ret)
	{
		buf[0] = (char)sprintf(&buf[1], "%d 0 %d", cur->base.rez, cur->base.vmode);
		shel_write(1, 1, 1, "SHUTDOWN.PRG", buf); /* BUG: return value ignored */
	}
	return ret;
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
			get_paths();
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
			rsrc_free();
			ret = 0;
		}
		appl_exit();
	}

	return ret;
}
