#include <tos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stddef.h>
#include "cpxdata.h"
#include "cpxhead.h"
#include "country.h"

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

/* must be first item in data segment; written by CPX_Save */
struct save_vars save_vars = { 0 };

#include "magxconf.rsh"

static long config;
static XCPB *xcpb;




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


static void get_config(void)
{
	long conf = Sconfig(SC_GETCONF, 0l);
	OBJECT *tree = rs_trindex[MAIN];
	
	if (conf & SCB_NFAST)
		tree[CF_FASTLOAD].ob_state &= ~OS_SELECTED;
	else
		tree[CF_FASTLOAD].ob_state |= OS_SELECTED;
	if (conf & SCB_CMPTB)
		tree[CF_TOSCOMPAT].ob_state |= OS_SELECTED;
	else
		tree[CF_TOSCOMPAT].ob_state &= ~OS_SELECTED;
	if (conf & SCB_NSMRT)
		tree[CF_SMARTREDRAW].ob_state &= ~OS_SELECTED;
	else
		tree[CF_SMARTREDRAW].ob_state |= OS_SELECTED;
	if (conf & SCB_NGRSH)
		tree[CF_GROWBOX].ob_state &= ~OS_SELECTED;
	else
		tree[CF_GROWBOX].ob_state |= OS_SELECTED;
	if (conf & SCB_PULLM)
		tree[CF_PULLDOWN].ob_state |= OS_SELECTED;
	else
		tree[CF_PULLDOWN].ob_state &= ~OS_SELECTED;
	if (conf & SCB_FLPAR)
		tree[CF_FLOPPY_DMA].ob_state |= OS_SELECTED;
	else
		tree[CF_FLOPPY_DMA].ob_state &= ~OS_SELECTED;
	config = conf;
}


static void set_config(void)
{
	long conf = 0;
	OBJECT *tree = rs_trindex[MAIN];
	
	if (!(tree[CF_FASTLOAD].ob_state & OS_SELECTED))
		conf = SCB_NFAST;
	if (tree[CF_TOSCOMPAT].ob_state & OS_SELECTED)
		conf |= SCB_CMPTB;
	if (!(tree[CF_SMARTREDRAW].ob_state & OS_SELECTED))
		conf |= SCB_NSMRT;
	if (!(tree[CF_GROWBOX].ob_state & OS_SELECTED))
		conf |= SCB_NGRSH;
	if (tree[CF_PULLDOWN].ob_state & OS_SELECTED)
		conf |= SCB_PULLM;
	if (tree[CF_FLOPPY_DMA].ob_state & OS_SELECTED)
		conf |= SCB_FLPAR;
	config &= ~SCONFIG_MASK;
	config |= conf;
	Sconfig(SC_SETCONF, config);
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
			frame = outline = tree[index].ob_spec.obspec.framesize;
			break;
		default:
			frame = outline = 0;
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
	r = xcpb->GetFirstRect(&gr);
	while (r)
	{
		mt_objc_draw_grect(tree, index, MAX_DEPTH, r, NULL);
		r = xcpb->GetNextRect();
	}
}


static _WORD handle_msg(_WORD obj, _WORD *msg)
{
	_WORD ret = 0;
	struct save_vars vars;
	OBJECT *tree = rs_trindex[MAIN];
	
	if (obj != -1)
		obj &= 0x7fff;
	switch (obj)
	{
	case OK:
		tree[OK].ob_state &= ~OS_SELECTED;
		ret = 1;
		break;
	case CANCEL:
		tree[CANCEL].ob_state &= ~OS_SELECTED;
		ret = 1;
		break;
	case SAVE:
		if (xcpb->XGen_Alert(CPX_SAVE_DEFAULTS) != 0)
		{
			set_config();
			vars.config = config & SCONFIG_MASK;
			xcpb->CPX_Save(&vars, sizeof(vars));
		}
		tree[SAVE].ob_state &= ~OS_SELECTED;
		draw_obj(tree, SAVE);
		break;
	case -1:
		switch (msg[0])
		{
		case AC_CLOSE:
			ret = 1;
			break;
		case WM_CLOSED:
			set_config();
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
	OBJECT *tree = rs_trindex[MAIN];
	
	tree[ROOT].ob_x = work->g_x;
	tree[ROOT].ob_y = work->g_y;
	get_config();
	draw_obj(tree, ROOT);
	do
	{
		obj = xcpb->Xform_do(tree, ROOT, msg);
		ret = handle_msg(obj, msg);
	} while (ret == 0);
	return 0;
}


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

static _WORD al_no_magic;
static _WORD al_not_active;

static void set_texts(_WORD country)
{
	OBJECT *tree = rs_trindex[MAIN];
	const _WORD *p;
	
	static const _WORD trans_en[] = {
		CPXTITLE_EN,
		CF_VERSION_EN,
		CF_FASTLOAD_EN,
		CF_TOSCOMPAT_EN,
		CF_SMARTREDRAW_EN,
		CF_GROWBOX_EN,
		CF_FLOPPY_DMA_EN,
		CF_PULLDOWN_EN,
		SAVE_EN,
		OK_EN,
		CANCEL_EN,
		AL_NO_MAGIC_EN,
		AL_NOT_ACTIVE_EN
	};
	static const _WORD trans_de[] = {
		CPXTITLE_DE,
		CF_VERSION_DE,
		CF_FASTLOAD_DE,
		CF_TOSCOMPAT_DE,
		CF_SMARTREDRAW_DE,
		CF_GROWBOX_DE,
		CF_FLOPPY_DMA_DE,
		CF_PULLDOWN_DE,
		SAVE_DE,
		OK_DE,
		CANCEL_DE,
		AL_NO_MAGIC_DE,
		AL_NOT_ACTIVE_DE
	};
	static const _WORD trans_fr[] = {
		CPXTITLE_FR,
		CF_VERSION_FR,
		CF_FASTLOAD_FR,
		CF_TOSCOMPAT_FR,
		CF_SMARTREDRAW_FR,
		CF_GROWBOX_FR,
		CF_FLOPPY_DMA_FR,
		CF_PULLDOWN_FR,
		SAVE_FR,
		OK_FR,
		CANCEL_FR,
		AL_NO_MAGIC_FR,
		AL_NOT_ACTIVE_FR
	};
	
	switch (country)
	{
	default:
		/* Default case is USA/UK */
		p = trans_en;
		break;
	case COUNTRY_DE:
		p = trans_de;
		break;
	case COUNTRY_FR:
		p = trans_fr;
		break;
	case COUNTRY_UK:
		p = trans_en;
		break;
#if 0
	case COUNTRY_ES:
		p = trans_es;
		break;
	case COUNTRY_IT:
		p = trans_it;
		break;
	case COUNTRY_SE:
		p = trans_sv;
		break;
#endif
	}

	{
		char *buffer = xcpb->Get_Buffer();
		char *title = buffer - (offsetof(CPXHEAD, buffer) - offsetof(CPXHEAD, title_txt));
		strcpy(title, rs_frstr[p[0]]);
	}

#define XString(obj,string) tree[obj].ob_spec.free_string = rs_frstr[string]
	XString(VERSION, p[1]);
	XString(CF_FASTLOAD, p[2]);
	XString(CF_TOSCOMPAT, p[3]);
	XString(CF_SMARTREDRAW, p[4]);
	XString(CF_GROWBOX, p[5]);
	XString(CF_FLOPPY_DMA, p[6]);
	XString(CF_PULLDOWN, p[7]);
	XString(SAVE, p[8]);
	XString(OK, p[9]);
	XString(CANCEL, p[10]);
#undef XString

	al_no_magic = p[11];
	al_not_active = p[12];
}


CPXINFO *cdecl cpx_init(XCPB *Xcpb)
{
	MAGX_COOKIE *magx = 0;
	AESVARS *aesvars;
	
	xcpb = Xcpb;
	xcpb->getcookie(0x4D616758L, (long *)&magx);
	mt_appl_init(NULL);
	set_texts(xcpb->Country_Code);
	if (magx == 0 && !xcpb->booting)
	{
		mt_form_alert(1, rs_frstr[al_no_magic], NULL);
		return NULL;
	}
	if (magx == 0)
	{
		return (CPXINFO *)1;
	}
	aesvars = magx->aesvars;
	if (aesvars == NULL && !xcpb->booting)
	{
		mt_form_alert(1, rs_frstr[al_not_active], NULL);
		return NULL;
	}
	
	if (aesvars == NULL)
		return (CPXINFO *)1;

	if (xcpb->booting)
	{
		config = Sconfig(SC_GETCONF, 0l);
		config &= ~SCONFIG_MASK;
		config |= save_vars.config;
		Sconfig(SC_SETCONF, config);
		return (CPXINFO *)1;
	}		

	config = Sconfig(SC_GETCONF, 0l);

	if (!xcpb->SkipRshFix)
	{
		_WORD i;
		char *str;
		OBJECT *tree;
		
		tree = rs_object;
		for (i = 0; i < NUM_OBS; i++)
			xcpb->rsh_obfix(tree, i);
		tree = rs_trindex[MAIN];
		str = tree[VERSION].ob_spec.free_string;
		str += strlen(str);
		while (str[-1] == ' ')
			str--;
		str = format_number(aesvars->date, 8, str);
		while (*--str != '\340')
			;
		if (aesvars->release < 3)
		{
			/* -> 0xe0 = alpha, 0xe1 = beta */
			*str = 0xe0 + aesvars->release;
		} else
		{
			*str = ' ';
		}
		format_number(aesvars->version, 4, str);
		str = tree[VERSION].ob_spec.free_string;
	}
	
	return &cpxinfo;
}
