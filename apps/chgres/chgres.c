#include <portab.h>
#include <aes.h>
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#include <tos.h>
#include <mint/falcon.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"


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


struct res {
	struct res *next;
	short selected;
	const char *desc;
	short rez;
	short vmode;
};

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


static WORD gl_apid;
static WORD aes_handle;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;
static RSHDR *rs_hdr;
static char **rs_frstr;
static OBJECT **rs_trindex;

static WORD vdo;
static WORD bpp;
static WORD monitor_type;
static LIST_BOX *color_lbox; 
static DIALOG *dialog;
static struct res *res_tab;
static WORD must_shutdown;
static int currez;
static int vmode;
static WORD first_bpp;
static WORD last_bpp;



static const char *const bpp_tab[] = {
	"    2",
	"    4",
	"   16",
	"  256",
	"32768"
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

static struct res st_resolutions[] = {
	{ NULL, 0, " 640 * 400, ST High", ST_HIGH, 0 },
	{ NULL, 0, " 640 * 200, ST Medium", ST_MED, 0 },
	{ NULL, 0, " 320 * 200, ST Low    ", ST_LOW, 0 },
	{ NULL, 0, NULL, 0, 0 }
};
static struct res *st_res_tab[] = {
	&st_resolutions[0],
	&st_resolutions[1],
	&st_resolutions[2],
	NULL,
	NULL
};

static struct res tt_resolutions[] = {
	{ NULL,                0, " 640 * 400, ST High", ST_HIGH, BPS1 },
	{ NULL,                0, NULL, 0, 0 },
	{ NULL,                0, " 640 * 200, ST Medium", ST_MED, 0 },
	{ &tt_resolutions[4],  0, " 320 * 200, ST Low    ", ST_LOW, 0 },
	{ NULL,                0, " 640 * 480, TT Medium", TT_MED, 0 },
	{ NULL,                0, " 320 * 480, TT Low    ", TT_LOW, 0 }
};

static struct res *tt_res_tab[] = {
	&tt_resolutions[0],
	&tt_resolutions[2],
	&tt_resolutions[3],
	&tt_resolutions[5],
	NULL
};

static struct res tt_high[] = {
	{ NULL,                 0, "1280 * 960, TT High", TT_HIGH, 0 }
};

static struct res vga_resolutions[] = {
	{ &vga_resolutions[1],  0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS1 },
	{ &vga_resolutions[2],  0, " 640 * 400, ST High", FALCON_REZ, STMODES|VGA|COL80|BPS1 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS1 },
	{ &vga_resolutions[4],  0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS2 },
	{ &vga_resolutions[5],  0, " 320 * 480", FALCON_REZ, VGA|BPS2 },
	{ &vga_resolutions[6],  0, " 640 * 200, ST Medium", FALCON_REZ, VERTFLAG|STMODES|VGA|COL80|BPS2 },
	{ &vga_resolutions[7],  0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS2 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS2 },
	{ &vga_resolutions[9],  0, " 320 * 200, ST Low    ", FALCON_REZ, VERTFLAG|STMODES|VGA|BPS4 },
	{ &vga_resolutions[10], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS4 },
	{ &vga_resolutions[11], 0, " 320 * 480", FALCON_REZ, VGA|BPS4 },
	{ &vga_resolutions[12], 0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS4 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS4 },
	{ &vga_resolutions[14], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS8 },
	{ &vga_resolutions[15], 0, " 320 * 480", FALCON_REZ, VGA|BPS8 },
	{ &vga_resolutions[16], 0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS8 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS8 },
	{ &vga_resolutions[18], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS16 },
	{ NULL,                 0, " 320 * 480", FALCON_REZ, VGA|BPS16 }
};

static struct res *vga_res_tab[] = {
	&vga_resolutions[0],
	&vga_resolutions[3],
	&vga_resolutions[8],
	&vga_resolutions[13],
	&vga_resolutions[17]
};


static struct res tv_resolutions[] = {
	{ &tv_resolutions[1],  0, " 640 * 200", FALCON_REZ, TV|COL80|BPS1 },
	{ &tv_resolutions[2],  0, " 640 * 400, ST High", FALCON_REZ, VERTFLAG|TV|STMODES|COL80|BPS1 },
	{ &tv_resolutions[3],  0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS1 },
	{ NULL,                0, " 768 * 480", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS1 },
	{ &tv_resolutions[5],  0, " 320 * 200", FALCON_REZ, TV|BPS2 },
	{ &tv_resolutions[6],  0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS2 },
	{ &tv_resolutions[7],  0, " 384 * 240", FALCON_REZ, TV|OVERSCAN|BPS2 },
	{ &tv_resolutions[8],  0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS2 },
	{ &tv_resolutions[9],  0, " 640 * 200, ST Medium", FALCON_REZ, TV|STMODES|COL80|BPS2 },
	{ &tv_resolutions[10], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS2 },
	{ &tv_resolutions[11], 0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS2 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS2 },
	{ &tv_resolutions[13], 0, " 320 * 200, ST Low    ", FALCON_REZ, TV|STMODES|BPS4 },
	{ &tv_resolutions[14], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS4 },
	{ &tv_resolutions[15], 0, " 384 * 240", FALCON_REZ, OVERSCAN|BPS4 },
	{ &tv_resolutions[16], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS4 },
	{ &tv_resolutions[17], 0, " 640 * 200", FALCON_REZ, COL80|BPS4 },
	{ &tv_resolutions[18], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS4 },
	{ &tv_resolutions[19], 0, " 768 * 240", FALCON_REZ, OVERSCAN|COL80|BPS4 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS4 },
	{ &tv_resolutions[21], 0, " 320 * 200", FALCON_REZ, TV|BPS8 },
	{ &tv_resolutions[22], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS8 },
	{ &tv_resolutions[23], 0, " 384 * 240", FALCON_REZ, TV|OVERSCAN|BPS8 },
	{ &tv_resolutions[24], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS8 },
	{ &tv_resolutions[25], 0, " 640 * 200", FALCON_REZ, TV|COL80|BPS8 },
	{ &tv_resolutions[26], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS8 },
	{ &tv_resolutions[27], 0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS8 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS8 },
	{ &tv_resolutions[29], 0, " 320 * 200", FALCON_REZ, TV|BPS16 },
	{ &tv_resolutions[30], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS16 },
	{ &tv_resolutions[31], 0, " 384 * 240", FALCON_REZ, OVERSCAN|TV|BPS16 },
	{ &tv_resolutions[32], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|OVERSCAN|TV|BPS16 },
	{ &tv_resolutions[33], 0, " 640 * 200", FALCON_REZ, TV|COL80|BPS16 },
	{ &tv_resolutions[34], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS16 },
	{ &tv_resolutions[35], 0, " 768 * 240", FALCON_REZ, OVERSCAN|TV|COL80|BPS16 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|OVERSCAN|TV|COL80|BPS16 },
};

static struct res *tv_res_tab[] = {
	&tv_resolutions[0],
	&tv_resolutions[4],
	&tv_resolutions[12],
	&tv_resolutions[20],
	&tv_resolutions[28]
};


static struct res st_high[] = {
	{ NULL, 0, " 640 * 400, ST High", FALCON_REZ, STMODES|COL80|BPS1 }
};



static struct res *get_restab(WORD vdo, WORD bpp, WORD montype)
{
	struct res *res = NULL;
	
	switch (vdo)
	{
	case 0: /* ST-compatible hardware */
	case 1: /* STE-compatible hardware */
		res = st_res_tab[bpp];
		break;
	case 2: /* TT-compatible hardware */
		if (montype == MON_MONO)
			res = tt_high;
		else
			res = tt_res_tab[bpp];
		break;
	case 3:
		if (montype == MON_VGA)
			res = vga_res_tab[bpp];
		else if (montype == MON_MONO)
			res = st_high;
		else
			res = tv_res_tab[bpp];
		break;
	}
	return res;
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
		if (res->selected)
			tree[obj_index].ob_state |= SELECTED;
		else
			tree[obj_index].ob_state &= ~SELECTED;
		src = res->desc;
		if (*text)
			*text++ = ' ';
		while (*text && *src)
			*text++ = *src++;
	} else
	{
		tree[obj_index].ob_state &= ~SELECTED;
	}
	while (*text)
		*text++ = ' ';
	return obj_index;
}


static void redraw_obj(DIALOG *dialog, WORD obj)
{
	OBJECT *tree;
	GRECT gr;
	
	wdlg_get_tree(dialog, &tree, &gr);
	wind_update(BEG_UPDATE);
	wdlg_redraw(dialog, &gr, obj, MAX_DEPTH);
	wind_update(END_UPDATE);
}


static void _CDECL select_item(struct SLCT_ITEM_args args)
{
	OBJECT *tree = args.tree;
	struct res *res = (struct res *)args.item;
	DIALOG *dialog = (DIALOG *)args.user_data;
	
	if (currez == 0)
	{
		tree[CHGRES_OK].ob_state &= ~DISABLED;
		tree[CHGRES_OK].ob_flags |= SELECTABLE;
		tree[CHGRES_OK].ob_flags |= DEFAULT;
		redraw_obj(dialog, CHGRES_OK);
		tree[CHGRES_SAVE].ob_state &= ~DISABLED;
		tree[CHGRES_SAVE].ob_flags |= SELECTABLE;
		redraw_obj(dialog, CHGRES_SAVE);
	}
	currez = res->rez;
	vmode = res->vmode;
}


static void set_bpp(WORD bpp)
{
	const char *src;
	char *dst;
	
	src = bpp_tab[bpp];
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
	case CHGRES_COLORS:
		index = simple_popup(tree, CHGRES_COLORS, &bpp_tab[first_bpp], last_bpp - first_bpp + 1, bpp - first_bpp);
		if (index >= 0)
		{
			index += first_bpp;
			bpp = index;
			{
				struct res *res;
				res = get_restab(vdo, index, monitor_type);
				res_tab = res;
				currez = 0;
				vmode = 0;
				while (res != NULL)
				{
					if (res->selected)
					{
						currez = res->rez;
						vmode = res->vmode;
					}
					res = res->next;
				}
			}
			set_bpp(index);
			lbox_set_items(color_lbox, (LBOX_ITEM *)res_tab);
			lbox_update(color_lbox, NULL);
			if (currez == 0)
			{
				tree[CHGRES_OK].ob_state |= DISABLED;
				tree[CHGRES_OK].ob_flags &= ~SELECTABLE;
				tree[CHGRES_OK].ob_flags &= ~DEFAULT;
				tree[CHGRES_SAVE].ob_state |= DISABLED;
				tree[CHGRES_SAVE].ob_flags &= ~SELECTABLE;
			} else
			{
				tree[CHGRES_OK].ob_state &= ~DISABLED;
				tree[CHGRES_OK].ob_flags |= SELECTABLE;
				tree[CHGRES_OK].ob_flags |= DEFAULT;
				tree[CHGRES_SAVE].ob_state &= ~DISABLED;
				tree[CHGRES_SAVE].ob_flags |= SELECTABLE;
			}
			redraw_obj(dlg, ROOT);
		}
		break;
	case CHGRES_SAVE:
		save_rez(currez, vmode);
		tree[CHGRES_SAVE].ob_state &= ~SELECTED;
		redraw_obj(dlg, CHGRES_SAVE);
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
	if (currez == 0)
	{
		tree[CHGRES_OK].ob_state |= DISABLED;
		tree[CHGRES_OK].ob_flags &= ~SELECTABLE;
		tree[CHGRES_OK].ob_flags &= ~DEFAULT;
		tree[CHGRES_SAVE].ob_state |= DISABLED;
		tree[CHGRES_SAVE].ob_flags &= ~SELECTABLE;
	} else
	{
		tree[CHGRES_OK].ob_state &= ~DISABLED;
		tree[CHGRES_OK].ob_flags |= SELECTABLE;
		tree[CHGRES_OK].ob_flags |= DEFAULT;
		tree[CHGRES_SAVE].ob_state &= ~DISABLED;
		tree[CHGRES_SAVE].ob_flags |= SELECTABLE;
	}
	set_bpp(bpp);
	dialog = wdlg_create(hdl_obj, tree, NULL, 0, NULL, 0);
	if (dialog != NULL)
	{
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
	
	rs_hdr = *((void **)&_GemParBlk.global[7]);
	rs_trindex = (OBJECT **)(((char *)rs_hdr + rs_hdr->rsh_trindex));
	rs_frstr = (char **)(((char *)rs_hdr + rs_hdr->rsh_frstr));
	tree = rs_trindex[MAIN_DIALOG];
	tree[CHGRES_UP].ob_y -= 1;
	tree[CHGRES_DOWN].ob_y -= 1;
	tree[CHGRES_ICON].ob_y += (tree[CHGRES_ICON].ob_height - tree[CHGRES_ICON].ob_spec.iconblk->ib_hicon) / 2;
	if (objc_sysvar(SV_INQUIRE, AD3DVAL, 0, 0, &dummy, &dummy) == 0)
		fix_3d(tree);
}


static void init_res(void)
{
	monitor_type = MON_VGA;
	bpp = BPS1;
	vdo = (WORD)(Supexec(get_vdo) >> 16);
	currez = Getrez() + 2;
	vmode = 0;
	switch (vdo)
	{
	case 0: /* ST-compatible hardware */
	case 1: /* STE-compatible hardware */
		switch (currez)
		{
		case ST_LOW:
			monitor_type = MON_COLOR;
			bpp = BPS4;
			break;
		case ST_MED:
			monitor_type = MON_COLOR;
			bpp = BPS2;
			break;
		case ST_HIGH:
			monitor_type = MON_MONO;
			bpp = BPS1;
			break;
		}
		if (monitor_type == MON_MONO)
		{
			first_bpp = BPS1;
			last_bpp = BPS1;
		} else
		{
			first_bpp = BPS2;
			last_bpp = BPS4;
		}
		break;
	case 2: /* TT-compatible hardware */
		switch (currez)
		{
		case ST_MED:
			monitor_type = MON_VGA;
			bpp = BPS2;
			break;
		case ST_HIGH:
			monitor_type = MON_VGA;
			bpp = BPS1;
			break;
		case ST_LOW:
		case TT_MED:
			monitor_type = MON_VGA;
			bpp = BPS4;
			break;
		case TT_HIGH:
			monitor_type = MON_MONO;
			bpp = BPS1;
			break;
		case TT_LOW:
			monitor_type = MON_VGA;
			bpp = BPS8;
			break;
		}
		if (monitor_type == MON_MONO)
		{
			first_bpp = BPS1;
			last_bpp = BPS1;
		} else
		{
			first_bpp = BPS1;
			last_bpp = BPS8;
		}
		break;
	case 3:
		currez = FALCON_REZ;
		vmode = VsetMode(-1) & ~PAL;
		monitor_type = VgetMonitor();
		bpp = VsetMode(-1) & NUMCOLS;
		if (monitor_type == MON_MONO)
		{
			first_bpp = BPS1;
			last_bpp = BPS1;
		} else
		{
			first_bpp = BPS1;
			last_bpp = BPS16;
		}
		break;
	default:
		currez = 0;
		break;
	}
	{
		struct res *res;
		res = get_restab(vdo, bpp, monitor_type);
		res_tab = res;
		while (res != NULL)
		{
			if (res->rez == currez && res->vmode == vmode)
			{
				res->selected = 1;
				break;
			}
			res = res->next;
		}
	}
}


int main(void)
{
	int ret = -1;
	char buf[32];
	char numbuf[8];
	
	gl_apid = appl_init();
	if (gl_apid != -1)
	{
		aes_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
		graf_mouse(ARROW, NULL);
		if (rsrc_load("CHGRES.RSC") != 0)
		{
			fix_rsc();
			init_res();
			if (select_res())
			{
				itoa(currez, numbuf, 10);
				strcpy(&buf[1], numbuf);
				strcat(&buf[1], " 0 ");
				itoa(vmode, numbuf, 10);
				strcat(&buf[1], numbuf);
				buf[0] = (char)strlen(&buf[1]);
				shel_write(1, 1, 1, "SHUTDOWN.PRG", buf);
			}
			rsrc_free();
			ret = 0;
		}
		appl_exit();
	}
	
	return ret;
}
