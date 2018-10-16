#include <tos.h>
#include <mt_aes.h>
#include <vdi.h>
#include <string.h>
#include <stddef.h>
#include "../cpxdata.h"

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

static MAGX_COOKIE *magx;
static AESVARS *aesvars;
static struct save_vars config;
static OBJECT *maintree;
static XCPB *xcpb;

int errno;


/* must be first item in data segment; written by CPX_Save */
struct save_vars save_vars = { 1, 1, 9, 19, 1 };
_WORD unused = 0;

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

extern char tslice_string_0[];
extern char tslice_string_1[];
extern char tslice_string_2[];
extern char tslice_string_3[];
extern char tslice_string_4[];
extern char tslice_string_5[];
extern char tslice_string_6[];
extern char tslice_string_7[];
extern char tslice_string_8[];

#include "tslice.rsh"
extern OBJECT rs_object[];
extern OBJECT *rs_trindex[];

#undef min
#undef max
#undef abs
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define abs(x) ((x) < 0 ? (-(x)) : (x))


static WORD get_timeslice(void);
static WORD get_prio(void);
static WORD set_timeslice(WORD v);
static WORD set_prio(WORD v);
static void disable_preemptive(void);
static void enable_preemptive(void);
static void get_config(void);
static void cdecl set_objects(void);
static void handle_slider(OBJECT *tree, _WORD *val, _WORD left, _WORD right, _WORD bg, _WORD slider, _WORD min, _WORD max, _WORD obj, void cdecl (*foo)(void));


CPXINFO *cdecl cpx_init(XCPB *Xcpb)
{
	xcpb = Xcpb;
	xcpb->getcookie(0x4D616758L, (long *)&magx);
	
	if (magx == 0 && !xcpb->booting)
	{
		mt_form_alert(1, "[1][MagiC ist nicht installiert!][ Abbruch ]", NULL);
		return NULL;
	}
	if (magx == 0)
	{
		return (CPXINFO *)1;
	}

	aesvars = magx->aesvars;
	if (aesvars == NULL && !xcpb->booting)
	{
		mt_form_alert(1, "[1][MagiC-AES ist nicht aktiv!][ Abbruch ]", NULL);
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
		rs_object[PREEMPTIVE].ob_state |= OS_SELECTED;
		enable_preemptive();
	} else
	{
		rs_object[PREEMPTIVE].ob_state &= ~OS_SELECTED;
		disable_preemptive();
		config.old_ticks = save_vars.ticks;
		config.old_bgprio = save_vars.bgprio;
	}
	
	if (!xcpb->SkipRshFix)
	{
		_WORD i;
		
		for (i = 0; i < NUM_OBS; i++)
			xcpb->rsh_obfix(rs_object, i);
		maintree = rs_trindex[MAIN];
	}
	return &cpxinfo;
}


static WORD get_timeslice(void)
{
	union {
		WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = -2;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[1];
}


static WORD get_prio(void)
{
	union {
		WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = -2;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[0];
}


static WORD set_timeslice(WORD v)
{
	union {
		WORD w[2];
		LONG l;
	} u;
	
	u.w[1] = v;
	u.w[0] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[1];
}


static WORD set_prio(WORD v)
{
	union {
		WORD w[2];
		LONG l;
	} u;
	
	u.w[0] = v;
	u.w[1] = -2;
	u.l = aesvars->ctrl_timeslice(u.l);
	return u.w[0];
}


static void disable_preemptive(void)
{
	OBJECT *tree = rs_object;
	
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
	OBJECT *tree = rs_object;
	
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


_WORD rc_intersect(const GRECT *r1, GRECT *r2)
{
	_WORD tx, ty, tw, th;

	tw = min(r2->g_x + r2->g_w, r1->g_x + r1->g_w);
	th = min(r2->g_y + r2->g_h, r1->g_y + r1->g_h);
	tx = max(r2->g_x, r1->g_x);
	ty = max(r2->g_y, r1->g_y);
	
	r2->g_x = tx;
	r2->g_y = ty;
	r2->g_w = tw - tx;
	r2->g_h = th - ty;
	
	return tw > tx && th > ty;
}


static _WORD handle_msg(_WORD obj, _WORD *msg)
{
	_WORD ret = 0;
	OBJECT *tree;
	
	if (obj != -1)
		obj &= 0x7fff;
	tree = rs_object;
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
		draw_obj(maintree, SAVE);
		break;
	case LF_2:
	case BG_2:
	case SLIDER_2:
	case RT_2:
		handle_slider(maintree, &config.bgprio, LF_2, RT_2, BG_2, SLIDER_2, MIN_BGPRIO, MAX_BGPRIO, obj, set_objects);
		break;
	case LF_1:
	case BG_1:
	case SLIDER_1:
	case RT_1:
		handle_slider(maintree, &config.ticks, LF_1, RT_1, BG_1, SLIDER_1, MIN_TICKS, MAX_TICKS, obj, set_objects);
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
		draw_obj(maintree, CONFIG_BOX);
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


static void get_config(void)
{
	if (config.preemptive)
	{
		config.old_bgprio = config.bgprio;
		config.old_ticks = config.ticks;
		set_objects();
		xcpb->Sl_x(maintree, BG_2, SLIDER_2, config.bgprio, MIN_BGPRIO, MAX_BGPRIO, NULLFUNC);
		xcpb->Sl_x(maintree, BG_1, SLIDER_1, config.ticks, MIN_TICKS, MAX_TICKS, NULLFUNC);
	} else
	{
		sprintf(maintree[SLIDER_1].ob_spec.free_string, "-");
		sprintf(maintree[SLIDER_2].ob_spec.free_string, "-:--");
	}
}


static void cdecl set_objects(void)
{
	set_timeslice(config.ticks);
	set_prio(config.bgprio);
	sprintf(maintree[SLIDER_1].ob_spec.free_string, "%d", config.ticks * 5);
	sprintf(maintree[SLIDER_2].ob_spec.free_string, "1:%d", config.bgprio + 1);
}


static void handle_slider(OBJECT *tree, _WORD *val, _WORD left, _WORD right, _WORD bg, _WORD slider, _WORD min, _WORD max, _WORD obj, void cdecl (*foo)(void))
{
	WORD dir;
	WORD inc;
	void cdecl (*drag)(OBJECT *tree, WORD base, WORD slider, WORD min, WORD max, WORD *val, void cdecl (*foo)(void));
	MFORM mf;
	EVNTDATA ev;
	WORD x;
	WORD y;
	
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


static BOOLEAN cdecl cpx_call(GRECT *work)
{
	BOOLEAN ret = 0;
	OBJECT *tree = rs_object;
	WORD msg[8];
	WORD obj;
	
	tree[ROOT].ob_x = work->g_x;
	tree[ROOT].ob_y = work->g_y;
	get_config();
	draw_obj(maintree, ROOT);
	do
	{
		obj = xcpb->Xform_do(tree, ROOT, msg);
		ret = handle_msg(obj, msg);
	} while (ret == 0);
	return 0;
}
