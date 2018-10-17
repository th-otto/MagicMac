#include <tos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stddef.h>
#include "cpxdata.h"
#include "cpxhead.h"
#include "country.h"

struct save_vars {
	_WORD ticks;
	_WORD old_ticks;
	_WORD bgprio;
	_WORD old_bgprio;
	_WORD preemptive;
};

#define MIN_TICKS 1
#define MAX_TICKS 10
#define MIN_BGPRIO 0
#define MAX_BGPRIO 63

static struct save_vars config;
static AESVARS *aesvars;
static XCPB *xcpb;


/* must be first item in data segment; written by CPX_Save */
struct save_vars save_vars = { 1, 1, 9, 19, 1 };

#include "tslice.rsh"




static _WORD get_timeslice(void)
{
	union {
		_WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = -2;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[1];
}


static _WORD get_prio(void)
{
	union {
		_WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = -2;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[0];
}


static _WORD set_timeslice(_WORD v)
{
	union {
		_WORD w[2];
		LONG l;
	} u;
	
	u.w[1] = v;
	u.w[0] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[1];
}


static _WORD set_prio(_WORD v)
{
	union {
		_WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = v;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[0];
}


static void disable_preemptive(void)
{
	OBJECT *tree = rs_trindex[MAIN];
	
	tree[LF_1].ob_state |= OS_DISABLED;
	tree[RT_1].ob_state |= OS_DISABLED;
	tree[BG_1].ob_state |= OS_DISABLED;
	tree[SLIDER_1].ob_state |= OS_DISABLED;
	tree[LF_1].ob_flags &= ~OF_TOUCHEXIT;
	tree[RT_1].ob_flags &= ~OF_TOUCHEXIT;
	tree[BG_1].ob_flags &= ~OF_TOUCHEXIT;
	tree[SLIDER_1].ob_flags &= ~OF_TOUCHEXIT;
	tree[LF_2].ob_state |= OS_DISABLED;
	tree[RT_2].ob_state |= OS_DISABLED;
	tree[BG_2].ob_state |= OS_DISABLED;
	tree[SLIDER_2].ob_state |= OS_DISABLED;
	tree[LF_2].ob_flags &= ~OF_TOUCHEXIT;
	tree[RT_2].ob_flags &= ~OF_TOUCHEXIT;
	tree[BG_2].ob_flags &= ~OF_TOUCHEXIT;
	tree[SLIDER_2].ob_flags &= ~OF_TOUCHEXIT;
}


static void enable_preemptive(void)
{
	OBJECT *tree = rs_trindex[MAIN];
	
	tree[LF_1].ob_state &= ~OS_DISABLED;
	tree[RT_1].ob_state &= ~OS_DISABLED;
	tree[BG_1].ob_state &= ~OS_DISABLED;
	tree[SLIDER_1].ob_state &= ~OS_DISABLED;
	tree[LF_1].ob_flags |= OF_TOUCHEXIT;
	tree[RT_1].ob_flags |= OF_TOUCHEXIT;
	tree[BG_1].ob_flags |= OF_TOUCHEXIT;
	tree[SLIDER_1].ob_flags |= OF_TOUCHEXIT;
	tree[LF_2].ob_state &= ~OS_DISABLED;
	tree[RT_2].ob_state &= ~OS_DISABLED;
	tree[BG_2].ob_state &= ~OS_DISABLED;
	tree[SLIDER_2].ob_state &= ~OS_DISABLED;
	tree[LF_2].ob_flags |= OF_TOUCHEXIT;
	tree[RT_2].ob_flags |= OF_TOUCHEXIT;
	tree[BG_2].ob_flags |= OF_TOUCHEXIT;
	tree[SLIDER_2].ob_flags |= OF_TOUCHEXIT;
}


static void draw_obj(OBJECT *tree, _WORD index)
{
	GRECT clip;
	GRECT gr;
	GRECT desk;
	GRECT *r;
	
	mt_wind_get(DESK, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h, NULL);
	mt_objc_offset(tree, ROOT, &gr.g_x, &gr.g_y, NULL);
	gr.g_w = tree[ROOT].ob_width;
	gr.g_h = tree[ROOT].ob_height;
	r = xcpb->GetFirstRect(&gr);
	while (r)
	{
		clip = *r;
		if (rc_intersect(&desk, &clip))
			mt_objc_draw_grect(tree, index, MAX_DEPTH, &clip, NULL);
		r = xcpb->GetNextRect();
	}
}


/* my_itoa()
 *==========================================================================
 * NOTE: These are 2 digit conversions ONLY.
 */
static void my_itoa(char *ptr, int val)
{
	int high = val / 10;
	if (high != 0)
		*ptr++ = high + '0';
	*ptr++ = (val % 10) + '0';
	*ptr = '\0';
}



static void cdecl set_objects(void)
{
	OBJECT *tree = rs_trindex[MAIN];
	char *str;
	
	set_timeslice(config.ticks);
	set_prio(config.bgprio);
	my_itoa(tree[SLIDER_1].ob_spec.free_string, config.ticks * 5);
	str = tree[SLIDER_2].ob_spec.free_string;
	strcpy(str, "1:");
	str += 2;
	my_itoa(str, config.bgprio + 1);
}


static void get_config(void)
{
	OBJECT *tree = rs_trindex[MAIN];

	if (config.preemptive)
	{
		config.old_bgprio = config.bgprio;
		config.old_ticks = config.ticks;
		set_objects();
		xcpb->Sl_x(tree, BG_2, SLIDER_2, config.bgprio, MIN_BGPRIO, MAX_BGPRIO, NULLFUNC);
		xcpb->Sl_x(tree, BG_1, SLIDER_1, config.ticks, MIN_TICKS, MAX_TICKS, NULLFUNC);
	} else
	{
		strcpy(tree[SLIDER_1].ob_spec.free_string, "-");
		strcpy(tree[SLIDER_2].ob_spec.free_string, "-:--");
	}
}


static void handle_slider(OBJECT *tree, _WORD *val, _WORD left, _WORD right, _WORD bg, _WORD slider, _WORD min, _WORD max, _WORD obj, void cdecl (*foo)(void))
{
	_WORD dir;
	_WORD inc;
	void cdecl (*drag)(OBJECT *tree, _WORD base, _WORD slider, _WORD min, _WORD max, _WORD *val, void cdecl (*foo)(void));
	MFORM mf;
	EVNTDATA ev;
	_WORD x;
	_WORD y;
	
	if (tree[left].ob_x == tree[right].ob_x)
	{
		dir = VERTICAL;
		drag = xcpb->Sl_dragy;
	} else
	{
		dir = HORIZONTAL;
		drag = xcpb->Sl_dragx;
	}
	if (obj == left || obj == right)
	{
		inc = obj == left ? -1 : 1;
		xcpb->Sl_arrow(tree, bg, slider, obj, inc, min, max, val, dir, foo);
	} else if (obj == bg)
	{
		mt_graf_mkstate_event(&ev, NULL);
		mt_objc_offset(tree, slider, &x, &y, NULL);
		if (dir == VERTICAL)
		{
			ev.x = y;
			x = ev.y;
		}
		inc = ev.x < x ? -4 : 4;
		xcpb->Sl_arrow(tree, bg, slider, NIL, inc, min, max, val, dir, foo);
	} else if (obj == slider)
	{
		xcpb->MFsave(MFSAVE, &mf);
		mt_graf_mouse(FLAT_HAND, NULL, NULL);
		drag(tree, bg, slider, min, max, val, foo);
		xcpb->MFsave(MFRESTORE, &mf);
	}
}


static _WORD handle_msg(_WORD obj, _WORD *msg)
{
	_WORD ret = 0;
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
		set_timeslice(config.old_ticks);
		set_prio(config.old_bgprio);
		ret = 1;
		break;
	case SAVE:
		if (xcpb->XGen_Alert(CPX_SAVE_DEFAULTS) != 0)
		{
			xcpb->CPX_Save(&config, sizeof(config));
		}
		tree[SAVE].ob_state &= ~OS_SELECTED;
		draw_obj(tree, SAVE);
		break;
	case LF_2:
	case BG_2:
	case SLIDER_2:
	case RT_2:
		handle_slider(tree, &config.bgprio, LF_2, RT_2, BG_2, SLIDER_2, MIN_BGPRIO, MAX_BGPRIO, obj, set_objects);
		break;
	case LF_1:
	case BG_1:
	case SLIDER_1:
	case RT_1:
		handle_slider(tree, &config.ticks, LF_1, RT_1, BG_1, SLIDER_1, MIN_TICKS, MAX_TICKS, obj, set_objects);
		break;
	case PREEMPTIVE:
		if (!(tree[PREEMPTIVE].ob_state & OS_SELECTED))
		{
			disable_preemptive();
			config.ticks = -1;
			config.bgprio = -1;
			config.old_ticks = set_timeslice(config.ticks);
			config.old_bgprio = set_prio(config.bgprio);
			config.preemptive = 0;
		} else
		{
			enable_preemptive();
			config.ticks = config.old_ticks;
			config.bgprio = config.old_bgprio;
			set_timeslice(config.old_ticks);
			set_prio(config.old_bgprio);
			config.preemptive = 1;
			get_config();
		}
		draw_obj(tree, CONFIG_BOX);
		break;
	case -1:
		switch (msg[0])
		{
		case AC_CLOSE:
			set_timeslice(config.old_ticks);
			set_prio(config.old_bgprio);
			ret = 1;
			break;
		case WM_CLOSED:
			ret = 1;
			break;
		}
		break;
	}
	return ret;
}


static BOOLEAN cdecl cpx_call(GRECT *work)
{
	BOOLEAN ret = 0;
	OBJECT *tree = rs_trindex[MAIN];
	_WORD msg[8];
	_WORD obj;
	
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
		CPXNAME_EN,
		FS_SLICE_EN,
		FS_PRIO_EN,
		FS_PREEMPTIVE_EN,
		SAVE_EN,
		OK_EN,
		CANCEL_EN,
		AL_NO_MAGIC_EN,
		AL_NOT_ACTIVE_EN
	};
	static const _WORD trans_de[] = {
		CPXTITLE_DE,
		CPXNAME_DE,
		FS_SLICE_DE,
		FS_PRIO_DE,
		FS_PREEMPTIVE_DE,
		SAVE_DE,
		OK_DE,
		CANCEL_DE,
		AL_NO_MAGIC_DE,
		AL_NOT_ACTIVE_DE
	};
	static const _WORD trans_fr[] = {
		CPXTITLE_FR,
		CPXNAME_FR,
		FS_SLICE_FR,
		FS_PRIO_FR,
		FS_PREEMPTIVE_FR,
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
		title = buffer - (offsetof(CPXHEAD, buffer) - offsetof(CPXHEAD, i_text));
		strcpy(title, rs_frstr[p[1]]);
	}

#define XString(obj,string) tree[obj].ob_spec.free_string = rs_frstr[string]
	XString(SLICE, p[2]);
	XString(PRIO, p[3]);
	XString(PREEMPTIVE, p[4]);
	XString(SAVE, p[5]);
	XString(OK, p[6]);
	XString(CANCEL, p[7]);
#undef XString

	al_no_magic = p[8];
	al_not_active = p[9];
}


CPXINFO *cdecl cpx_init(XCPB *Xcpb)
{
	MAGX_COOKIE *magx = 0;
	OBJECT *tree;

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
		config = save_vars;
		set_timeslice(config.ticks);
		set_prio(config.bgprio);
		return (CPXINFO *)1;
	}
	
	config.ticks = get_timeslice();
	config.bgprio = get_prio();
	if (config.ticks == -1 && config.bgprio == -1)
		config.preemptive = 0;
	else
		config.preemptive = 1;
	tree = rs_trindex[MAIN];
	if (config.preemptive)
	{
		if (config.ticks > MAX_TICKS)
			config.ticks = MAX_TICKS;
		if (config.ticks < MIN_TICKS)
			config.ticks = MIN_TICKS;
		if (config.bgprio > MAX_BGPRIO)
			config.bgprio = MAX_BGPRIO;
		if (config.bgprio < MIN_BGPRIO)
			config.bgprio = MIN_BGPRIO;
		tree[PREEMPTIVE].ob_state |= OS_SELECTED;
		enable_preemptive();
	} else
	{
		tree[PREEMPTIVE].ob_state &= ~OS_SELECTED;
		disable_preemptive();
		config.old_ticks = save_vars.ticks;
		config.old_bgprio = save_vars.bgprio;
	}
	
	if (!xcpb->SkipRshFix)
	{
		_WORD i;
		
		for (i = 0; i < NUM_OBS; i++)
			xcpb->rsh_obfix(rs_object, i);
	}
	return &cpxinfo;
}
