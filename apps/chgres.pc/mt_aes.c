#include <portab.h>
#include <tos.h>
#include "_mt_aes.h"

#ifndef FALSE
#define FALSE 0
#endif

#undef min
#undef max
#undef abs
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define abs(x) ((x) < 0 ? (-(x)) : (x))

typedef struct
{
	WORD	control[AES_CTRLMAX];
	WORD	intin[AES_INTINMAX];
	WORD	intout[AES_INTOUTMAX];
	void	*addrin[AES_ADDRINMAX];
	void	*addrout[AES_ADDROUTMAX];
} MT_PARMDATA;

void _aes_trap(MT_PARMDATA *aes_params, const WORD *control, WORD *global_aes);

char unused[30];
WORD aes_global[16];
char unused2[190];

WORD mt_appl_init(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 10, 0, 1, 0 };

	aes_params.intout[0] = -1;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_read(WORD apid, WORD len, void *buf, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 11, 2, 1, 1 };

	aes_params.intin[0] = apid;
	aes_params.intin[1] = len;
	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_write(WORD wid, WORD length, const void *buf, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 12, 2, 1, 1 };

	aes_params.intin[0] = wid;
	aes_params.intin[1] = length;
	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_find(const char *ap_fpname, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 13, 0, 1, 1 };

	aes_params.addrin[0] = ap_fpname;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_tplay(void *mem, WORD len, WORD scale, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 14, 2, 1, 1 };

	aes_params.intin[0] = len;
	aes_params.intin[1] = scale;
	aes_params.addrin[0] = mem;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_trecord(void *mem, WORD len, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 15, 1, 1, 1 };

	aes_params.intin[0] = len;
	aes_params.addrin[0] = mem;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_yield(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 17, 0, 1, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_search(WORD mode, char *name, WORD *type, WORD *id,
						WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 18, 0, 1, 0 };

	aes_params.intin[0] = mode;
	aes_params.addrin[0] = name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*type = aes_params.intout[1];
	*id = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_appl_exit(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 19, 0, 1, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_appl_getinfo(WORD type, WORD *out1, WORD *out2, WORD *out3, WORD *out4, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 130, 1, 5, 0 };

	aes_params.intin[0] = type;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	if (out1)
		*out1 = aes_params.intout[1];
	if (out2)
		*out2 = aes_params.intout[2];
	if (out3)
		*out3 = aes_params.intout[3];
	if (out4)
		*out4 = aes_params.intout[4];
	return aes_params.intout[0];
}


WORD mt_evnt_keybd(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 20, 0, 1, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_evnt_button_evnt(WORD nclicks, WORD mask, WORD state, EVNTDATA *ev, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 21, 3, 5, 0 };

	aes_params.intin[0] = nclicks;
	aes_params.intin[1] = mask;
	aes_params.intin[2] = state;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	ev->x = aes_params.intout[1];
	ev->y = aes_params.intout[2];
	ev->bstate = aes_params.intout[3];
	ev->kstate = aes_params.intout[4];
	return aes_params.intout[0];			/* nclicks */
}


WORD mt_evnt_mouse_event(WORD flg_leave, GRECT *g, EVNTDATA *ev, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 22, 5, 5, 0 };

	aes_params.intin[0] = flg_leave;
	*((GRECT *)(aes_params.intin+1)) = *g;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	ev->x = aes_params.intout[1];
	ev->y = aes_params.intout[2];
	ev->bstate = aes_params.intout[3];
	ev->kstate = aes_params.intout[4];
	return aes_params.intout[0];
}


WORD mt_evnt_mesag(WORD *buf, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 23, 0, 1, 1 };

	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_evnt_timer(ULONG timeout, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 24, 2, 1, 0 };

	aes_params.intin[0] = (WORD)timeout;
	aes_params.intin[1] = (WORD)(timeout >> 16);
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


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
			)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 25, 16, 7, 1 };

	aes_params.intin[0] = evtypes;
	aes_params.intin[1] = nclicks;
	aes_params.intin[2] = bmask;
	aes_params.intin[3] = bstate;

	if (evtypes & MU_M1)
	{
		aes_params.intin[4] = flg1_leave;
		*((GRECT *)(aes_params.intin+5)) = *g1;
	}
	
	if (evtypes & MU_M2)
	{
		aes_params.intin[9] = flg2_leave;
		*((GRECT *)(aes_params.intin+10)) = *g2;
	}

	aes_params.intin[14] = (WORD) ms;			/* Intel: erst Low */
	aes_params.intin[15] = (WORD) (ms>>16L);	/* Intel: dann High */
	aes_params.addrin[0] = msgbuf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	ev->x = aes_params.intout[1];
	ev->y = aes_params.intout[2];
	ev->bstate = aes_params.intout[3];
	ev->kstate = aes_params.intout[4];
	*keycode = aes_params.intout[5];
	*nbclicks = aes_params.intout[6];
	return aes_params.intout[0];
}


void MT_EVNT_multi(WORD evtypes, WORD nclicks, WORD bmask, WORD bstate,
							MOBLK *m1, MOBLK *m2, ULONG ms,
							EVNT *event, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	WORD *intout;
	WORD *ev;
	static WORD const aes_control_data[4] = { 25, 16, 7, 1 };

	aes_params.intin[0] = evtypes;
	aes_params.intin[1] = nclicks;
	aes_params.intin[2] = bmask;
	aes_params.intin[3] = bstate;

	if (evtypes & MU_M1)					/* Mausrechteck 1? */
		*((MOBLK *)(aes_params.intin + 4)) = *m1;

	if (evtypes & MU_M2)					/* Mausrechteck 2? */
		*((MOBLK *)(aes_params.intin + 9)) = *m2;

	aes_params.intin[14] = (WORD) ms;					/* W”rter drehen */
	aes_params.intin[15] = (WORD) (ms >> 16L);
	aes_params.addrin[0] = event->msg;				/* Nachrichtenbuffer */
	_aes_trap(&aes_params, aes_control_data, global_aes);
	
	ev = (WORD *) event;					/* EVNT-Struktur besetzen */
	intout = aes_params.intout;
	*ev++ = *intout++;						/* mwhich */
	*ev++ = *intout++;						/* mx */
	*ev++ = *intout++;						/* my */
	*ev++ = *intout++;						/* mbutton */
	*ev++ = *intout++;						/* kstate */
	*ev++ = *intout++;						/* key */
	*ev++ = *intout++;						/* mclicks */
}


WORD mt_evnt_dclicks(WORD val, WORD setflg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 26, 2, 1, 0 };

	aes_params.intin[0] = val;
	aes_params.intin[1] = setflg;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_bar(OBJECT *tree, WORD show, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 30, 1, 1, 1 };

	aes_params.intin[0] = show;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_icheck(OBJECT *tree, WORD objnr, WORD chkflg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 31, 2, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = chkflg;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_ienable(OBJECT *tree, WORD objnr, WORD chkflg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 32, 2, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = chkflg;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_tnormal(OBJECT *tree, WORD objnr, WORD chkflg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 33, 2, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = chkflg;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_text(OBJECT *tree, WORD objnr, const char *text, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 34, 1, 1, 2 };

	aes_params.intin[0] = objnr;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = text;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_register(WORD apid, const char *text, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 35, 1, 1, 1 };

	aes_params.intin[0] = apid;
	aes_params.addrin[0] = text;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_unregister(WORD menuid, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 36, 1, 1, 0 };

	aes_params.intin[0] = menuid;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_popup(MENU *menu, WORD x, WORD y, MENU *data, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 36, 2, 1, 2 };

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	aes_params.addrin[0] = menu;
	aes_params.addrin[1] = data;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_click(WORD val, WORD setflag, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 37, 2, 1, 0 };

	aes_params.intin[0] = val;
	aes_params.intin[1] = setflag;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_attach(WORD flag, OBJECT *tree, WORD obj, MENU *data, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 37, 2, 1, 2 };

	aes_params.intin[0] = flag;
	aes_params.intin[1] = obj;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = data;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_istart(WORD flag, OBJECT *tree, WORD menu, WORD item, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 38, 3, 1, 1 };

	aes_params.intin[0] = flag;
	aes_params.intin[1] = menu;
	aes_params.intin[2] = item;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_menu_settings(WORD flag, MN_SET *values, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 39, 1, 1, 1 };

	aes_params.intin[0] = flag;
	aes_params.addrin[0] = values;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_add(OBJECT *tree, WORD parent, WORD child, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 40, 2, 1, 1 };

	aes_params.intin[0] = parent;
	aes_params.intin[1] = child;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_delete(OBJECT *tree, WORD objnr, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 41, 1, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_draw_grect(OBJECT *tree, WORD start, WORD depth, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 42, 6, 1, 1 };

	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	*((GRECT *)(aes_params.intin+2)) = *g;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_find(OBJECT *tree, WORD start, WORD depth, WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 43, 4, 1, 1 };

	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	aes_params.intin[2] = x;
	aes_params.intin[3] = y;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_offset(OBJECT *tree, WORD objnr, WORD *x, WORD *y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 44, 1, 3, 1 };

	aes_params.intin[0] = objnr;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*x = aes_params.intout[1];
	*y = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_objc_order(OBJECT *tree, WORD objnr, WORD newpos, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 45, 2, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = newpos;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_edit(OBJECT *tree, WORD objnr, WORD key, WORD *cursor_xpos, WORD subfn, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 46, 4, 2, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = key;
	aes_params.intin[2] = *cursor_xpos;
	aes_params.intin[3] = subfn;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*cursor_xpos = aes_params.intout[1];
	return aes_params.intout[0];
}

WORD mt_objc_xedit(OBJECT *tree, WORD objnr, WORD key, WORD *cursor_xpos, WORD subfn, GRECT *r, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 46, 4, 2, 2 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = key;
	aes_params.intin[2] = *cursor_xpos;
	aes_params.intin[3] = subfn;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = r;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*cursor_xpos = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_objc_change_grect(OBJECT *tree, WORD objnr, WORD resvd, const GRECT *g, WORD newstate, WORD redraw, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 47, 8, 1, 1 };

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = resvd;
	*((GRECT *)(aes_params.intin+2)) = *g;
	aes_params.intin[6] = newstate;
	aes_params.intin[7] = redraw;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_sysvar(WORD ob_smode, WORD ob_swhich, WORD ob_sival1, WORD ob_sival2, WORD *ob_soval1, WORD *ob_soval2, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 48, 4, 3, 0 };

	aes_params.intin[0] = ob_smode;
	aes_params.intin[1] = ob_swhich;
	aes_params.intin[2] = ob_sival1;
	aes_params.intin[3] = ob_sival2;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*ob_soval1 = aes_params.intout[1];
	*ob_soval2 = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_form_do(OBJECT *tree, WORD startob, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 50, 1, 1, 1 };

	aes_params.intin[0] = startob;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_xdo(OBJECT *tree, WORD startob, WORD *cursor_obj, XDO_INF *scantab, void *flyinf, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 50, 1, 2, 3 };

	aes_params.intin[0] = startob;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = scantab;
	aes_params.addrin[2] = flyinf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*cursor_obj = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_form_dial_grect(WORD subfn, const GRECT *lg, const GRECT *bg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 51, 9, 1, 0 };

	aes_params.intin[0] = subfn;
	if (lg)
		*((GRECT *)(aes_params.intin+1)) = *lg;
	*((GRECT *)(aes_params.intin+5)) = *bg;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_xdial_grect(WORD subfn, const GRECT *lg, const GRECT *bg, void **flyinf, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 51, 9, 1, 2 };

	aes_params.intin[0] = subfn;
	if (lg)
		*((GRECT *)(aes_params.intin+1)) = *lg;
	*((GRECT *)(aes_params.intin+5)) = *bg;
	aes_params.addrin[0] = flyinf;
	aes_params.addrin[1] = 0;		/* reserviert */
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_alert(WORD defbutton, const char *string, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 52, 1, 1, 1 };

	aes_params.intin[0] = defbutton;
	aes_params.addrin[0] = string;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_error(WORD dosenkot, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 53, 1, 1, 0 };

	aes_params.intin[0] = dosenkot;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_center_grect(OBJECT *tree, GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 54, 0, 5, 1 };

	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*g = *((GRECT *)(aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_form_keybd(OBJECT *tree, WORD obj, WORD nxt, WORD key, WORD *nextob, WORD *nextchar, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 55, 3, 3, 1 };

	aes_params.intin[0] = obj;
	aes_params.intin[1] = key;
	aes_params.intin[2] = nxt;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);

	*nextob = aes_params.intout[1];
	*nextchar = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_form_button(OBJECT *tree, WORD obj, WORD nclicks, WORD *nextob, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 56, 2, 2, 1 };

	aes_params.intin[0] = obj;
	aes_params.intin[1] = nclicks;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*nextob = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_graf_rubberbox(WORD x, WORD y, WORD begw, WORD begh, WORD *endw, WORD *endh, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 70, 4, 3, 0 };

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	aes_params.intin[2] = begw;
	aes_params.intin[3] = begh;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*endw	 = aes_params.intout[1];
	*endh	 = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_graf_dragbox_grect(WORD w, WORD h, WORD begx, WORD begy, GRECT *g, WORD *endx, WORD *endy, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 71, 8, 3, 0 };

	aes_params.intin[0] = w;
	aes_params.intin[1] = h;
	aes_params.intin[2] = begx;
	aes_params.intin[3] = begy;
	*((GRECT *)(aes_params.intin+4)) = *g;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*endx	 = aes_params.intout[1];
	*endy	 = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_graf_movebox(WORD w, WORD h, WORD begx, WORD begy, WORD endx, WORD endy, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 72, 6, 1, 0 };

	aes_params.intin[0] = w;
	aes_params.intin[1] = h;
	aes_params.intin[2] = begx;
	aes_params.intin[3] = begy;
	aes_params.intin[4] = endx;
	aes_params.intin[5] = endy;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_growbox_grect(const GRECT *startg, const GRECT *endg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 73, 8, 1, 0 };

	*((GRECT *)(aes_params.intin)) = *startg;
	*((GRECT *)(aes_params.intin+4)) = *endg;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_shrinkbox_grect(const GRECT *endg, const GRECT *startg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 74, 8, 1, 0 };

	*((GRECT *)(aes_params.intin)) = *endg;
	*((GRECT *)(aes_params.intin+4)) = *startg;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_watchbox(OBJECT *tree, WORD obj, WORD instate, WORD outstate, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 75, 4, 1, 1 };

	aes_params.intin[0] = 0;
	aes_params.intin[1] = obj;
	aes_params.intin[2] = instate;
	aes_params.intin[3] = outstate;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_slidebox(OBJECT *tree, WORD parent, WORD obj, WORD h, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 76, 3, 1, 1 };

	aes_params.intin[0] = parent;
	aes_params.intin[1] = obj;
	aes_params.intin[2] = h;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_handle(WORD *wchar, WORD *hchar, WORD *wbox, WORD *hbox, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 77, 0, 5, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	*wchar = aes_params.intout[1];
	*hchar = aes_params.intout[2];
	*wbox = aes_params.intout[3];
	*hbox = aes_params.intout[4];
	return aes_params.intout[0];
}


WORD mt_graf_xhandle(WORD *wchar, WORD *hchar, WORD *wbox, WORD *hbox, WORD *device, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 77, 0, 6, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	*wchar = aes_params.intout[1];
	*hchar = aes_params.intout[2];
	*wbox = aes_params.intout[3];
	*hbox = aes_params.intout[4];
	*device = aes_params.intout[5];
	return aes_params.intout[0];
}


WORD mt_graf_mouse(WORD code, const MFORM *adr, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 78, 1, 1, 1 };

	aes_params.intin[0] = code;
	aes_params.addrin[0] = adr;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_mkstate_event(EVNTDATA *ev, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 79, 0, 5, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	*ev = *((EVNTDATA *) (aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_scrp_read(char *path, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 80, 0, 1, 1 };

	aes_params.addrin[0] = path;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_scrp_write(const char *path, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 81, 0, 1, 1 };

	aes_params.addrin[0] = path;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_scrp_clear(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 82, 0, 1, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_fsel_input(char *path, char *name, WORD *button, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 90, 0, 2, 2 };

	aes_params.addrin[0] = path;
	aes_params.addrin[1] = name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*button = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_fsel_exinput(char *path, char *name, WORD *button, const char *label, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 91, 0, 2, 3 };

	aes_params.addrin[0] = path;
	aes_params.addrin[1] = name;
	aes_params.addrin[2] = label;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*button = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_wind_create_grect(WORD kind, const GRECT *maxsize, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 100, 5, 1, 0 };

	aes_params.intin[0] = kind;
	*((GRECT *)(aes_params.intin+1)) = *maxsize;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_open_grect(WORD whdl, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 101, 5, 1, 0 };

	aes_params.intin[0] = whdl;
	*((GRECT *)(aes_params.intin+1)) = *g;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_close(WORD whdl, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 102, 1, 1, 0 };

	aes_params.intin[0] = whdl;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}

WORD mt_wind_delete(WORD whdl, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 103, 1, 1, 0 };

	aes_params.intin[0] = whdl;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_get(WORD whdl, WORD subfn, WORD *g1, WORD *g2, WORD *g3, WORD *g4, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 104, 3, 5, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	if (g1)
		aes_params.intin[2] = *g1;		/* for WF_DCOLOR */
	_aes_trap(&aes_params, aes_control_data, global_aes);

	if (g1)
		*g1 = aes_params.intout[1];
	if (g2)
		*g2 = aes_params.intout[2];
	if (g3)
		*g3 = aes_params.intout[3];
	if (g4)
		*g4 = aes_params.intout[4];

	return aes_params.intout[0];
}


WORD mt_wind_get_grect(WORD whdl, WORD subfn, GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 104, 2, 5, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*g = *((GRECT *) (aes_params.intout+1));

	return aes_params.intout[0];
}


WORD mt_wind_get_ptr(WORD whdl, WORD subfn, void **v, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 104, 2, 5, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*v = *((void **) (aes_params.intout+1));

	return aes_params.intout[0];
}


WORD mt_wind_set(WORD whdl, WORD subfn, WORD g1, WORD g2, WORD g3, WORD g4, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 105, 6, 1, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	aes_params.intin[2] = g1;
	aes_params.intin[3] = g2;
	aes_params.intin[4] = g3;
	aes_params.intin[5] = g4;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_set_str(WORD whdl, WORD subfn, const char *s, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 105, 4, 1, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	*((const char **) (aes_params.intin+2)) = s;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_set_grect(WORD whdl, WORD subfn, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 105, 6, 1, 0 };

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	*((GRECT *) (aes_params.intin+2)) = *g;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_find(WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 106, 2, 1, 0 };

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_update(WORD subfn, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 107, 1, 1, 0 };

	aes_params.intin[0] = subfn;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_calc_grect(WORD subfn, WORD kind, const GRECT *ing, GRECT *outg, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 108, 6, 5, 0 };

	aes_params.intin[0] = subfn;
	aes_params.intin[1] = kind;
	*((GRECT *) (aes_params.intin+2)) = *ing;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*outg = *((GRECT *) (aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_wind_new(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 109, 0, 0, 0 }; /* BUG: nintout should be 1 */

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_rsrc_load(const char *filename, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 110, 0, 1, 1 };

	aes_params.addrin[0] = filename;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_rsrc_free(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 111, 0, 1, 0 };

	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_rsrc_gaddr(WORD type, WORD index, void *addr, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 112, 2, 1, 0 };

	aes_params.intin[0] = type;
	aes_params.intin[1] = index;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*((void **) addr) = aes_params.addrout[0];
	return aes_params.intout[0];
}


WORD mt_rsrc_saddr(WORD type, WORD index, void *o, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 113, 2, 1, 1 };

	aes_params.intin[0] = type;
	aes_params.intin[1] = index;
	aes_params.addrin[0] = o;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_rsrc_obfix(OBJECT *tree, WORD obj, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 114, 1, 1, 1 };

	aes_params.intin[0] = obj;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_rsrc_rcfix(void *rsh, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 115, 0, 1, 1 };

	aes_params.addrin[0] = rsh;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_read(char *cmd, char *tail, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 120, 0, 1, 2 };

	aes_params.addrin[0] = cmd;
	aes_params.addrin[1] = tail;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_write(WORD doex, WORD isgr, WORD isover, const void *cmd, const char *tail, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 121, 3, 1, 2 };

	aes_params.intin[0] = doex;
	aes_params.intin[1] = isgr;
	aes_params.intin[2] = isover;
	aes_params.addrin[0] = cmd;
	aes_params.addrin[1] = tail;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_get(char *buf, WORD len, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 122, 1, 1, 1 };

	aes_params.intin[0] = len;
	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_put(const char *buf, WORD len, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 123, 1, 1, 1 };

	aes_params.intin[0] = len;
	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_find(char *path, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 124, 0, 1, 1 };

	aes_params.addrin[0] = path;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_envrn(char **val, const char *name, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 125, 0, 1, 2 };

	aes_params.addrin[0] = val;
	aes_params.addrin[1] = name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_rdef(char *fname, char *dir, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 126, 0, 1, 2 };

	aes_params.addrin[0] = fname;
	aes_params.addrin[1] = dir;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_shel_wdef(const char *fname, const char *dir, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 127, 0, 1, 2 };

	aes_params.addrin[0] = fname;
	aes_params.addrin[1] = dir;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_form_popup(OBJECT *tree, WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 135, 2, 1, 1 };

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_xfrm_popup(OBJECT *tree, WORD x, WORD y, WORD firstscrlob,
				WORD lastscrlob, WORD nlines,
				void /* __CDECL */ (*init)(struct POPUP_INIT_args),
				void *param, WORD *lastscrlpos,
				WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 135, 6, 2, 3 };

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	aes_params.intin[2] = firstscrlob;
	aes_params.intin[3] = lastscrlob;
	aes_params.intin[4] = nlines;
	aes_params.intin[5] = *lastscrlpos;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = init;
	aes_params.addrin[2] = param;

	aes_params.intout[1] = *lastscrlpos;		/* vorbesetzen */

	_aes_trap(&aes_params, aes_control_data, global_aes);
	*lastscrlpos = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_form_xerr(LONG errcode, char *errfile, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 136, 2, 1, 1 };

	*(LONG *) (aes_params.intin) = errcode;
	aes_params.addrin[0] = errfile;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


DIALOG *mt_wdlg_create(HNDL_OBJ handle_exit, OBJECT *tree,
				void *user_data, WORD code, void *data,
				WORD flags, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 160, 2, 0, 4 };

	aes_params.intin[0] = code;
	aes_params.intin[1] = flags;
	aes_params.addrin[0] = handle_exit;
	aes_params.addrin[1] = tree;
	aes_params.addrin[2] = user_data;
	aes_params.addrin[3] = data;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_wdlg_open(DIALOG *dialog, const char *title, WORD kind,
				WORD x, WORD y, WORD code, void *data,
				WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 161, 4, 1, 3 };

	aes_params.intin[0] = kind;
	aes_params.intin[1] = x;
	aes_params.intin[2] = y;
	aes_params.intin[3] = code;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = title;
	aes_params.addrin[2] = data;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_close(DIALOG *dialog, WORD *x, WORD *y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 162, 0, 3, 1 };

	aes_params.intout[1] = -1;
	aes_params.intout[2] = -1;

	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);

	if (x)
		*x = aes_params.intout[1];
	if (y)
		*y = aes_params.intout[2];

	return aes_params.intout[0];
}


WORD mt_wdlg_delete(DIALOG *dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 163, 0, 1, 1 };

	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_get_tree(DIALOG *dialog, OBJECT **tree, GRECT *r, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 164, 1, 1, 3 };

	aes_params.intin[0] = 0;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = tree;
	aes_params.addrin[2] = r;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_get_edit(DIALOG *dialog, WORD *cursor, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 164, 1, 2, 1 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*cursor	 = aes_params.intout[1];
	return aes_params.intout[0];
}


void *mt_wdlg_get_udata(DIALOG *dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 164, 1, 0, 1 };

	aes_params.intin[0] = 2;
	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_wdlg_get_handle(DIALOG *dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 164, 1, 1, 1 };

	aes_params.intin[0] = 3;
	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_set_edit(DIALOG *dialog, WORD obj, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 165, 2, 1, 1 };

	aes_params.intin[0] = 0;
	aes_params.intin[1] = obj;
	aes_params.addrin[0] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_set_tree(DIALOG *dialog, OBJECT *new_tree, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 165, 1, 1, 2 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = new_tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_set_size(DIALOG *dialog, GRECT *new_size, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 165, 1, 1, 2 };

	aes_params.intin[0] = 2;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = new_size;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_set_iconify(DIALOG *dialog, GRECT *g, const char *title, OBJECT *tree, WORD obj, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 165, 2, 1, 4 };

	aes_params.intin[0] = 3;
	aes_params.intin[1] = obj;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = g;
	aes_params.addrin[2] = title;
	aes_params.addrin[3] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_set_uniconify(DIALOG *dialog, GRECT *g, const char *title, OBJECT *tree, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 165, 1, 1, 4 };

	aes_params.intin[0] = 4;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = g;
	aes_params.addrin[2] = title;
	aes_params.addrin[3] = tree;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_wdlg_evnt(DIALOG *dialog, EVNT *events, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 166, 0, 1, 2 };

	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = events;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


void mt_wdlg_redraw(DIALOG *dialog, GRECT *rect, WORD obj, WORD depth, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 167, 2, 0, 2 };

	aes_params.intin[0] = obj;
	aes_params.intin[1] = depth;
	aes_params.addrin[0] = dialog;
	aes_params.addrin[1] = rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


LIST_BOX *mt_lbox_create(OBJECT *tree, SLCT_ITEM slct,
	SET_ITEM set, LBOX_ITEM *items,
	WORD visible_a, WORD first_a,
	const WORD *ctrl_objs, const WORD *objs, WORD flags,
	WORD pause_a, void *user_data,
	DIALOG *dialog, WORD visible_b,
	WORD first_b, WORD entries_b,
	WORD pause_b, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 170, 8, 0, 8 };

	aes_params.intin[0] = visible_a;
	aes_params.intin[1] = first_a;
	aes_params.intin[2] = flags;
	aes_params.intin[3] = pause_a;
	aes_params.intin[4] = visible_b;
	aes_params.intin[5] = first_b;
	aes_params.intin[6] = entries_b;
	aes_params.intin[7] = pause_b;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = slct;
	aes_params.addrin[2] = set;
	aes_params.addrin[3] = items;
	aes_params.addrin[4] = ctrl_objs;
	aes_params.addrin[5] = objs;
	aes_params.addrin[6] = user_data;
	aes_params.addrin[7] = dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


void mt_lbox_update(LIST_BOX *box, GRECT *rect, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 171, 0, 0, 2 };

	aes_params.addrin[0] = box;
	aes_params.addrin[1] = rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


WORD mt_lbox_do(LIST_BOX *box, WORD obj, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 172, 1, 1, 1 };

	aes_params.intin[0] = obj;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_lbox_delete(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 173, 0, 1, 1 };

	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}



WORD mt_lbox_cnt_items(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 0;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


OBJECT *mt_lbox_get_tree(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 0, 1 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_box_get_visible(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 2;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


void *mt_lbox_get_udata(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 0, 1 };

	aes_params.intin[0] = 3;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_lbox_get_afirst(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 4;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_lbox_get_slct_idx(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 5;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


LBOX_ITEM *mt_lbox_get_items(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 0, 1 };

	aes_params.intin[0] = 6;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


LBOX_ITEM *mt_lbox_get_item(LIST_BOX *box, WORD n, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 2, 0, 1 };

	aes_params.intin[0] = 7;
	aes_params.intin[1] = n;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


LBOX_ITEM *mt_lbox_get_slct_item(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 0, 1 };

	aes_params.intin[0] = 8;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_lbox_get_idx(LBOX_ITEM *items, LBOX_ITEM *search, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 2 };

	aes_params.intin[0] = 9;
	aes_params.addrin[0] = items;
	aes_params.addrin[1] = search;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_lbox_get_bvis(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 10;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_lbox_get_bentries(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 11;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_lbox_get_bfirst(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 174, 1, 1, 1 };

	aes_params.intin[0] = 12;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


void mt_lbox_set_asldr(LIST_BOX *box, WORD first, GRECT *rect, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 2, 0, 2 };

	aes_params.intin[0] = 0;
	aes_params.intin[1] = first;
	aes_params.addrin[0] = box;
	aes_params.addrin[1] = rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_set_items(LIST_BOX *box, LBOX_ITEM *items, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 1, 0, 2 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = box;
	aes_params.addrin[1] = items;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_free_items(LIST_BOX *box, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 1, 0, 1 };

	aes_params.intin[0] = 2;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_free_list(LBOX_ITEM *items, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 1, 0, 1 };

	aes_params.intin[0] = 3;
	aes_params.addrin[0] = items;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_ascroll_to(LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 2, 0, 3 };

	aes_params.intin[0] = 4;
	aes_params.intin[1] = first;
	aes_params.addrin[0] = box;
	aes_params.addrin[1] = box_rect;
	aes_params.addrin[2] = slider_rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_set_bsldr(LIST_BOX *box, WORD first, GRECT *rect, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 2, 0, 2 };

	aes_params.intin[0] = 5;
	aes_params.intin[1] = first;
	aes_params.addrin[0] = box;
	aes_params.addrin[1] = rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_set_bentries(LIST_BOX *box, WORD entries, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 2, 0, 1 };

	aes_params.intin[0] = 6;
	aes_params.intin[1] = entries;
	aes_params.addrin[0] = box;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


void mt_lbox_bscroll_to(LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 175, 2, 0, 3 };

	aes_params.intin[0] = 7;
	aes_params.intin[1] = first;
	aes_params.addrin[0] = box;
	aes_params.addrin[1] = box_rect;
	aes_params.addrin[2] = slider_rect;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


FNT_DIALOG *mt_fnts_create(WORD vdi_handle, WORD no_fonts,
	WORD font_flags, WORD dialog_flags,
	const char *sample, const char *opt_button,
	WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 180, 4, 0, 4 };

	aes_params.intin[0] = vdi_handle;
	aes_params.intin[1] = no_fonts;
	aes_params.intin[2] = font_flags;
	aes_params.intin[3] = dialog_flags;
	aes_params.addrin[0] = sample;
	aes_params.addrin[1] = opt_button;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_fnts_delete(FNT_DIALOG *fnt_dialog, WORD vdi_handle, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 181, 1, 1, 1 };

	aes_params.intin[0] = vdi_handle;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_fnts_open(FNT_DIALOG *fnt_dialog, WORD button_flags,
	WORD x, WORD y, LONG id, LONG pt, LONG ratio,
	WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 182, 9, 1, 1 };

	aes_params.intin[0] = button_flags;
	aes_params.intin[1] = x;
	aes_params.intin[2] = y;
	*((LONG *)(aes_params.intin+3)) = id;
	*((LONG *)(aes_params.intin+5)) = pt;
	*((LONG *)(aes_params.intin+7)) = ratio;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_fnts_close(FNT_DIALOG *fnt_dialog, WORD *x, WORD *y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 183, 0, 3, 1 };

	aes_params.intout[1] = -1;
	aes_params.intout[2] = -1;

	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);

	if (x)
		*x = aes_params.intout[1];
	if (y)
		*y = aes_params.intout[2];

	return  aes_params.intout[0];
}


WORD mt_fnts_get_no_styles(FNT_DIALOG *fnt_dialog, LONG id, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 184, 3, 1, 1 };

	aes_params.intin[0] = 0;
	*((LONG *) (aes_params.intin+1)) = id;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


LONG mt_fnts_get_style(FNT_DIALOG *fnt_dialog, LONG id, WORD index, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 184, 4, 1, 1 };

	aes_params.intin[0] = 1;
	*((LONG *) (aes_params.intin+1)) = id;
	aes_params.intin[3] = index;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return *((LONG *) (aes_params.intout+0));
}


WORD mt_fnts_get_name(FNT_DIALOG *fnt_dialog, LONG id, char *full_name, char *family_name, char *style_name, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 184, 3, 1, 4 };

	aes_params.intin[0] = 2;
	*((LONG *) (aes_params.intin+1)) = id;
	aes_params.addrin[0] = fnt_dialog;
	aes_params.addrin[1] = full_name;
	aes_params.addrin[2] = family_name;

	aes_params.addrin[3] = style_name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_fnts_get_info(FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 184, 3, 0, 1 };

	aes_params.intin[0] = 3;
	*((LONG *) (aes_params.intin+1)) = id;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*mono = aes_params.intout[1];
	*outline = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_fnts_add(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 185, 1, 1, 2 };

	aes_params.intin[0] = 0;
	aes_params.addrin[0] = fnt_dialog;
	aes_params.addrin[1] = user_fonts;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


void mt_fnts_remove(FNT_DIALOG *fnt_dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 185, 1, 0, 1 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
}


WORD mt_fnts_update(FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 185, 8, 1, 1 };

	aes_params.intin[0] = 2;
	aes_params.intin[1] = button_flags;
	*((LONG *) &aes_params.intin[2] ) = id;
	*((LONG *) &aes_params.intin[4] ) = pt;
	*((LONG *) &aes_params.intin[6] ) = ratio;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return  aes_params.intout[0];
}


WORD mt_fnts_evnt(FNT_DIALOG *fnt_dialog, EVNT *events,
	WORD *button, WORD *check_boxes, LONG *id,
	LONG *pt, LONG *ratio, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 186, 0, 9, 2 };

	aes_params.addrin[0] = fnt_dialog;
	aes_params.addrin[1] = events;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*button	 = aes_params.intout[1];
	*check_boxes = aes_params.intout[2];
	*id		 = *((LONG *)(aes_params.intout+3));
	*pt		 = *((LONG *)(aes_params.intout+5));
	*ratio	 = *((LONG *)(aes_params.intout+7));
	return aes_params.intout[0];
}


WORD mt_fnts_do(FNT_DIALOG *fnt_dialog, WORD button_flags,
	LONG id_in, LONG pt_in, LONG ratio_in,
	WORD *check_boxes, LONG *id, LONG *pt,
	LONG *ratio, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 187, 7, 0, 1 };

	aes_params.intin[0] = button_flags;
	*((LONG *) (aes_params.intin+1)) = id_in;
	*((LONG *) (aes_params.intin+3)) = pt_in;
	*((LONG *) (aes_params.intin+5)) = ratio_in;
	aes_params.addrin[0] = fnt_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*check_boxes = aes_params.intout[1];
	*id = *((LONG *) (aes_params.intout+2));
	*pt = *((LONG *) (aes_params.intout+4));
	*ratio = *((LONG *) (aes_params.intout+6));
	return aes_params.intout[0];
}


XFSL_DIALOG *mt_fslx_open(
	const char *title,
	WORD x, WORD y,
	WORD *handle,
	char *path, WORD pathlen,
	char *fname, WORD fnamelen,
	const char *patterns,
	XFSL_FILTER filter,
	char *paths,
	WORD sort_mode,
	WORD flags,
	WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 190, 6, 1, 6 };

	WORD *intin = aes_params.intin;
	void **addrin = aes_params.addrin;

	*intin++ = x;
	*intin++ = y;
	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	_aes_trap(&aes_params, aes_control_data, global_aes);

	*handle = aes_params.intout[0];
	return aes_params.addrout[0];
}


WORD mt_fslx_close(XFSL_DIALOG *fsd, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 191, 0, 1, 1 };

	aes_params.addrin[0] = fsd;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_fslx_getnxtfile(XFSL_DIALOG *fsd, char *fname, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 192, 0, 1, 2 };

	aes_params.addrin[0] = fsd;
	aes_params.addrin[1] = fname;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];

}


WORD mt_fslx_evnt(
	XFSL_DIALOG *fsd,
	EVNT *events,
	char *path,
	char *fname,
	WORD *button,
	WORD *nfiles,
	WORD *sort_mode,
	char **pattern, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	void **addrin = aes_params.addrin;
	static WORD const aes_control_data[4] = { 193, 0, 4, 4 };

	*addrin++ = fsd;
	*addrin++ = events;
	*addrin++ = path;
	*addrin = fname;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*button = aes_params.intout[1];
	*nfiles = aes_params.intout[2];
	if (sort_mode)
		*sort_mode = aes_params.intout[3];
	if (pattern)
		*pattern = aes_params.addrout[0];

	return aes_params.intout[0];
}


XFSL_DIALOG *mt_fslx_do(
	const char *title,
	char *path, WORD pathlen,
	char *fname, WORD fnamelen,
	char *patterns,
	XFSL_FILTER filter,
	char *paths,
	WORD *sort_mode,
	WORD flags,
	WORD *button,
	WORD *nfiles,
	char **pattern, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 194, 4, 4, 6 };

	WORD *intin = aes_params.intin;
	void **addrin = aes_params.addrin;

	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = *sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	_aes_trap(&aes_params, aes_control_data, global_aes);

	*button = aes_params.intout[1];
	*nfiles = aes_params.intout[2];
	*sort_mode = aes_params.intout[3];
	*pattern = aes_params.addrout[1];
	return aes_params.addrout[0];
}


WORD mt_fslx_set_flags(WORD flags, WORD *oldval, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 195, 2, 2, 0 };

	aes_params.intin[0] = 0;
	aes_params.intin[1] = flags;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*oldval = aes_params.intout[1];
	return aes_params.intout[0];
}


PRN_DIALOG *mt_pdlg_create(WORD dialog_flags, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 200, 1, 0, 0 };

	aes_params.intin[0] = dialog_flags;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_pdlg_delete(PRN_DIALOG *prn_dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 201, 0, 1, 1 };

	aes_params.addrin[0] = prn_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_open(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
	const char *document_name, WORD option_flags,
	WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 202, 3, 1, 3 };

	aes_params.intin[0] = option_flags;
	aes_params.intin[1] = x;
	aes_params.intin[2] = y;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	aes_params.addrin[2] = document_name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_close(PRN_DIALOG *prn_dialog, WORD *x, WORD *y, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 203, 0, 3, 1 };

	aes_params.intout[1] = -1;
	aes_params.intout[2] = -1;

	aes_params.addrin[0] = prn_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);

	if (x)
		*x = aes_params.intout[1];
	if (y)
		*y = aes_params.intout[2];
		
	return aes_params.intout[0];
}


LONG mt_pdlg_get_setsize(WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 204, 0, 2, 0 };

	aes_params.intin[0] = 0;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return *(LONG *) &aes_params.intout[0];
}


WORD mt_pdlg_add_printers(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 0;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = drv_info;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_remove_printers(PRN_DIALOG *prn_dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 1 };

	aes_params.intin[0] = 1;
	aes_params.addrin[0] = prn_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_update(PRN_DIALOG *prn_dialog, const char *document_name, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 3 };

	aes_params.intin[0] = 2;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = 0L;
	aes_params.addrin[2] = document_name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_add_sub_dialogs(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 3;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = sub_dialogs;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_remove_sub_dialogs(PRN_DIALOG *prn_dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 1 };

	aes_params.intin[0] = 4;
	aes_params.addrin[0] = prn_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


PRN_SETTINGS *mt_pdlg_new_settings(PRN_DIALOG *prn_dialog, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 0, 1 };

	aes_params.intin[0] = 5;
	aes_params.addrin[0] = prn_dialog;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.addrout[0];
}


WORD mt_pdlg_free_settings(PRN_SETTINGS *settings, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 1 };

	aes_params.intin[0] = 6;
	aes_params.addrin[0] = settings;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_dflt_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 7;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_validate_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 8;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


WORD mt_pdlg_use_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 9;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


#if !PDLG_SLB && BINEXACT
WORD mt_pdlg_save_default_settings(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 205, 1, 1, 2 };

	aes_params.intin[0] = 10;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}
#endif


WORD mt_pdlg_evnt(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, WORD *button, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 206, 0, 2, 3 };

	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	aes_params.addrin[2] = events;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*button	 = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_pdlg_do(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
	const char *document_name, WORD option_flags,
	WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[4] = { 207, 1, 1, 3 };

	aes_params.intin[0] = option_flags;
	aes_params.addrin[0] = prn_dialog;
	aes_params.addrin[1] = settings;
	aes_params.addrin[2] = document_name;
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}
