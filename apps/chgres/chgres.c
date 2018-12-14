#include <portab.h>
#define wdlg_close wdlg_close_ex
#include <aes.h>
#define __GRECT
#define __MOBLK
#define __PORTAES_H__
#define _WORD WORD
#define _LONG LONG
#define _VOID void
#define _CDECL cdecl
#define EXTERN_C_BEG
#define EXTERN_C_END
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#undef wdlg_close
_WORD wdlg_close(DIALOG *dialog);
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"


#define SV_INQUIRE		0	/* inquire sysvar data, see mt_objc_sysvar() */
#define AD3DVAL      6                  /* AES 4.0     */



#define COOKIE_P ((long **)0x5a0)



static WORD gl_apid;
static WORD aes_handle;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;
static struct {
	RSHDR *rs_hdr;
	char **rs_frstr;
	OBJECT **rs_trindex;
	unsigned short rs_ntree;
} rsc;

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


WORD objc_sysvar(WORD ob_svmode, WORD ob_svwhich, WORD ob_svinval1, WORD ob_svinval2, WORD *ob_svoutval1, WORD *ob_svoutval2);
void my_aes(void);


static void redraw_obj(DIALOG *dialog, WORD obj);


static void fix_3d(OBJECT *tree);


#pragma warn -par
static WORD _CDECL set_item(LIST_BOX *box, OBJECT *tree, struct res *res, WORD obj_index, void *user_data, GRECT *rect, WORD first)
{
	char *text;
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


static void _CDECL select_item(LIST_BOX *box, OBJECT *_tree, struct res *item, void *user_data, WORD obj_index, WORD last_state)
{
	OBJECT *tree = _tree;
	DIALOG *dialog = (DIALOG *)user_data;
	struct res *res = (struct res *)item;
	
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
#pragma warn .par


static void set_bpp(WORD bpp)
{
	const char *src;
	char *dst;
	
	src = bpp_tab[bpp];
	dst = rsc.rs_trindex[MAIN_DIALOG][CHGRES_COLORS].ob_spec.free_string;
	if (*dst)
		*dst++ = ' ';
	if (*dst)
		*dst++ = ' ';
	while (*dst && *src)
		*dst++ = *src++;
	while (*dst)
		*dst++ = ' ';
}


#pragma warn -par
static WORD _CDECL hdl_obj(DIALOG *dlg, EVNT *events, WORD obj, WORD clicks, void *data)
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
#pragma warn .par


static int select_res(void)
{
	OBJECT *tree;
	EVNT events;
	
	tree = rsc.rs_trindex[MAIN_DIALOG];
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
			if (wdlg_open(dialog, rsc.rs_frstr[FS_CHANGE_RES], NAME|CLOSER|MOVER, -1, -1, 0, NULL))
			{
				do
				{
					events.mwhich = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,
						0, 0, 0, 0, 0,
						0, 0, 0, 0, 0,
						events.msg,
						0, 0,
						&events.mx, &events.my, &events.mbutton, &events.kstate, &events.key, &events.mclicks);
				} while (wdlg_evnt(dialog, &events) != 0);
				wdlg_close(dialog);
			}
			lbox_delete(color_lbox);
		}
		wdlg_delete(dialog);
	}
	return must_shutdown;
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


static void fix_rsc(void)
{
	WORD dummy;
	OBJECT *o;
	
	rsc.rs_hdr = *((void **)&_GemParBlk.global[7]);
	rsc.rs_trindex = (OBJECT **)(((char *)rsc.rs_hdr + rsc.rs_hdr->rsh_trindex));
	rsc.rs_ntree = rsc.rs_hdr->rsh_ntree;
	rsc.rs_frstr = (char **)(((char *)rsc.rs_hdr + rsc.rs_hdr->rsh_frstr));
	rsc.rs_trindex[MAIN_DIALOG][CHGRES_UP].ob_y -= 1;
	rsc.rs_trindex[MAIN_DIALOG][CHGRES_DOWN].ob_y -= 1;
	o = &rsc.rs_trindex[MAIN_DIALOG][CHGRES_ICON];
	o->ob_y += (o->ob_height - o->ob_spec.iconblk->ib_hicon) / 2;
	if (objc_sysvar(SV_INQUIRE, AD3DVAL, 0, 0, &dummy, &dummy) == 0)
		fix_3d(rsc.rs_trindex[MAIN_DIALOG]);
}


static void fix_3d(OBJECT *tree)
{
	tree[CHGRES_UP].ob_spec.obspec.framesize = 1;
	tree[CHGRES_DOWN].ob_spec.obspec.framesize = 1;
	tree[CHGRES_SLIDER].ob_spec.obspec.framesize = 1;
	tree[CHGRES_BACK].ob_spec.obspec.interiorcol = 1;
	tree[CHGRES_BACK].ob_spec.obspec.fillpattern = 1;
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
		vmode = Vsetmode(-1) & ~PAL;
		monitor_type = mon_type();
		bpp = Vsetmode(-1) & NUMCOLS;
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
