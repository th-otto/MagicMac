#include <tos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include "cpxdata.h"

#undef SC_GETCONF
#undef SC_SETCONF
#define SC_GETCONF 0x414b
#define SC_SETCONF 0x454c


/*
 * Sconfig() bits that are handled here
 */
#define SCONFIG_MASK ((long)(SCB_NFAST|SCB_CMPTB|SCB_NSMRT|SCB_NGRSH|SCB_NHALT|SCB_PULLM|SCB_FLPAR))

struct save_vars {
	long config;
};

struct save_vars save_vars = { 0 };

static BOOLEAN cdecl cpx_call(GRECT *work);

CPXINFO cpxinfo = {
	cpx_call,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
};

#include "magxconf.rsh"
extern OBJECT rs_object[];
extern OBJECT *rs_trindex[];

long config;
OBJECT *maintree;
XCPB *global_xcpb;

extern long cdecl _gemdos(short opcode, ...);
#define Sconfig(a, b) _gemdos(51, a, b)

static char *format_number(unsigned long val, int digits, char *dst);


CPXINFO *cdecl cpx_init(XCPB *xcpb)
{
	MAGX_COOKIE *magx;
	AESVARS *aesvars;
	
	global_xcpb = xcpb;
	global_xcpb->getcookie(0x4D616758L, (long *)&magx);
	if (magx == 0 && !global_xcpb->booting)
	{
		mt_form_alert(1, "[1][MagiC ist nicht installiert!][ Abbruch ]", NULL);
		return NULL;
	}
	if (magx == 0)
	{
		return (CPXINFO *)1;
	}
	aesvars = magx->aesvars;
	if (aesvars == NULL && !global_xcpb->booting)
	{
		mt_form_alert(1, "[1][MagiC-AES ist nicht aktiv!][ Abbruch ]", NULL);
		return NULL;
	}
	
	if (aesvars == NULL)
		return (CPXINFO *)1;

	if (global_xcpb->booting)
	{
		config = Sconfig(SC_GETCONF, 0l);
		config &= ~SCONFIG_MASK;
		config |= save_vars.config;
		Sconfig(SC_SETCONF, config);
		return (CPXINFO *)1;
	}		

	config = Sconfig(SC_GETCONF, 0l);

	if (!global_xcpb->SkipRshFix)
	{
		_WORD i;
		char *str;
		
		for (i = 0; i < NUM_OBS; i++)
			global_xcpb->rsh_obfix(rs_object, i);
		maintree = rs_trindex[MAIN];
		str = maintree[VERSION].ob_spec.free_string;
		str = format_number(aesvars->date, 8, str + strlen(str) - 1);
		str -= 6;
		if (aesvars->release < 3)
		{
			/* -> 0xe0 = alpha, 0xe1 = beta */
			*str = 0xe0 + aesvars->release;
		}
		format_number(aesvars->version, 3, str);
	}
	
	return &cpxinfo;
}


static char *format_number(unsigned long value, int digits, char *str)
{
	char c;
	do {
		c = ((char)(value) & 0x0f) + '0';
		*--str = c;
		value >>= 4;
		if (str[-1] == '.')
			str--;
	} while (--digits > 0);
	return str;
}


static void get_config(long *config)
{
	long conf = Sconfig(SC_GETCONF, 0l);
	
	if (conf & SCB_NFAST)
		rs_object[CF_FASTLOAD].ob_state &= ~OS_SELECTED;
	else
		rs_object[CF_FASTLOAD].ob_state |= OS_SELECTED;
	if (conf & SCB_CMPTB)
		rs_object[CF_TOSCOMPAT].ob_state |= OS_SELECTED;
	else
		rs_object[CF_TOSCOMPAT].ob_state &= ~OS_SELECTED;
	if (conf & SCB_NSMRT)
		rs_object[CF_SMARTREDRAW].ob_state &= ~OS_SELECTED;
	else
		rs_object[CF_SMARTREDRAW].ob_state |= OS_SELECTED;
	if (conf & SCB_NGRSH)
		rs_object[CF_GROWBOX].ob_state &= ~OS_SELECTED;
	else
		rs_object[CF_GROWBOX].ob_state |= OS_SELECTED;
	if (conf & SCB_PULLM)
		rs_object[CF_PULLDOWN].ob_state |= OS_SELECTED;
	else
		rs_object[CF_PULLDOWN].ob_state &= ~OS_SELECTED;
	if (conf & SCB_FLPAR)
		rs_object[CF_FLOPPY_DMA].ob_state |= OS_SELECTED;
	else
		rs_object[CF_FLOPPY_DMA].ob_state &= ~OS_SELECTED;
	*config = conf;
}


static void set_config(long *config)
{
	long conf = 0;
	
	if (!(rs_object[CF_FASTLOAD].ob_state & OS_SELECTED))
		conf = SCB_NFAST;
	if (rs_object[CF_TOSCOMPAT].ob_state & OS_SELECTED)
		conf |= SCB_CMPTB;
	if (!(rs_object[CF_SMARTREDRAW].ob_state & OS_SELECTED))
		conf |= SCB_NSMRT;
	if (!(rs_object[CF_GROWBOX].ob_state & OS_SELECTED))
		conf |= SCB_NGRSH;
	if (rs_object[CF_PULLDOWN].ob_state & OS_SELECTED)
		conf |= SCB_PULLM;
	if (rs_object[CF_FLOPPY_DMA].ob_state & OS_SELECTED)
		conf |= SCB_FLPAR;
	*config &= ~SCONFIG_MASK;
	*config |= conf;
	Sconfig(SC_SETCONF, *config);
}


static void fix_obj(OBJECT *tree, _WORD index, GRECT *gr, _WORD flags)
{
	_WORD outline;
	_WORD frame;
	
	mt_objc_offset(tree, index, &gr->g_x, &gr->g_y, NULL);
	gr->g_w = tree[index].ob_width;
	gr->g_h = tree[index].ob_height;
	if (flags)
	{
		flags = tree[index].ob_flags;
		switch (tree[index].ob_type & 0xff)
		{
		case G_BOX:
		case G_IBOX:
		case G_BOXCHAR:
#if FIXME
			frame = outline = OBSPEC_GET_FRAMESIZE(tree[index].ob_spec);
#else
			frame = outline = tree[index].ob_spec.obspec.framesize;
#endif
			break;
		default:
			/* FIXME: outline not set here */
			frame = 0;
			break;
		}
		if (flags & OF_TOUCHEXIT)
			outline = -1;
		if (flags & OF_EXIT)
			outline = -2;
		if (tree[index].ob_state & OS_OUTLINED)
			outline = -3;
		if (outline < 0)
		{
			gr->g_x += outline;
			gr->g_y += outline;
			outline += outline;
			gr->g_w -= outline;
			gr->g_h -= outline;
		}
		if (tree[index].ob_state & OS_SHADOWED)
		{
			if (frame < 0)
				frame = -frame;
			frame += frame;
			gr->g_w += frame;
			gr->g_h += frame;
		}
	}
}


static void draw_obj(OBJECT *tree, _WORD index)
{
	GRECT gr;
	GRECT *r;
	
	fix_obj(tree, index, &gr, 1);
	r = global_xcpb->GetFirstRect(&gr);
	while (r)
	{
		mt_objc_draw_grect(tree, index, MAX_DEPTH, r, NULL);
		r = global_xcpb->GetNextRect();
	}
}


static _WORD handle_msg(_WORD obj, _WORD *msg)
{
	_WORD ret = 0;
	struct save_vars vars;
	
	if (obj != -1)
		obj &= 0x7fff;
	switch (obj)
	{
	case OK:
		rs_object[OK].ob_state &= ~OS_SELECTED;
		ret = 1;
		break;
	case CANCEL:
		rs_object[CANCEL].ob_state &= ~OS_SELECTED;
		ret = 1;
		break;
	case SAVE:
		if (global_xcpb->XGen_Alert(CPX_SAVE_DEFAULTS) != 0)
		{
			set_config(&config);
			vars.config = config & SCONFIG_MASK;
			global_xcpb->CPX_Save(&vars, sizeof(vars));
		}
		rs_object[SAVE].ob_state &= ~OS_SELECTED;
		draw_obj(maintree, SAVE);
		break;
	case -1:
		switch (msg[0])
		{
		case AC_CLOSE:
			ret = 1;
			break;
		case WM_CLOSED:
			set_config(&config);
			ret = 1;
			break;
		}
	}
	return ret;
}


static BOOLEAN cdecl cpx_call(GRECT *work)
{
	_WORD msg[8];
	_WORD obj;
	_WORD ret;
	
	rs_object[ROOT].ob_x = work->g_x;
	rs_object[ROOT].ob_y = work->g_y;
	get_config(&config);
	draw_obj(maintree, ROOT);
	do
	{
		obj = global_xcpb->Xform_do(rs_object, ROOT, msg);
		ret = handle_msg(obj, msg);
	} while (ret == 0);
	return 0;
}
