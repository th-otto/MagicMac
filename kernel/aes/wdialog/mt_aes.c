#include <tos.h>
#include <mt_aes.h>

#undef min
#undef max
#undef abs
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define abs(x) ((x) < 0 ? (-(x)) : (x))

typedef struct
{
	_WORD	control[5];
	_WORD	intin[AES_INTINMAX];
	_WORD	intout[AES_INTOUTMAX];
	void	*addrin[AES_ADDRINMAX];
	void	*addrout[AES_ADDROUTMAX];
} MT_PARMDATA;

void _aes_trap(MT_PARMDATA *aes_params, const _WORD *control, _WORD *global_aes);

#if BINEXACT
char unused[30];
#endif
_WORD aes_global[AES_GLOBMAX];
#if BINEXACT
char unused2[190];
#endif

static _WORD const aes_control_data[][4] = {
	{ 10, 0, 1, 0 }, /* 0 appl_init */
	{ 11, 2, 1, 1 }, /* 1 */
	{ 12, 2, 1, 1 }, /* 2 appl_write */
	{ 13, 0, 1, 1 }, /* 3 appl_find */
	{ 14, 2, 1, 1 }, /* 4 */
	{ 15, 1, 1, 1 }, /* 5 */
	{ 17, 0, 1, 0 }, /* 6 */
	{ 18, 0, 1, 0 }, /* 7 */
	{ 19, 0, 1, 0 }, /* 8 appl_exit */
	{ 130, 1, 5, 0 }, /* 9 appl_getinfo */
	{ 20, 0, 1, 0 }, /* 10 */
	{ 21, 3, 5, 0 }, /* 11 */
	{ 22, 5, 5, 0 }, /* 12 */
	{ 23, 0, 1, 1 }, /* 13 */
	{ 24, 2, 1, 0 }, /* 14 evnt_timer */
	{ 25, 16, 7, 1 }, /* 15 evnt_multi */
	{ 25, 16, 7, 1 }, /* 16 evnt_multi */
	{ 26, 2, 1, 0 }, /* 17 */
	{ 30, 1, 1, 1 }, /* 18 */
	{ 31, 2, 1, 1 }, /* 19 */
	{ 32, 2, 1, 1 }, /* 20 */
	{ 33, 2, 1, 1 }, /* 21 */
	{ 34, 1, 1, 2 }, /* 22 */
	{ 35, 1, 1, 1 }, /* 23 */
	{ 36, 1, 1, 0 }, /* 24 */
	{ 36, 2, 1, 2 }, /* 25 */
	{ 37, 2, 1, 0 }, /* 26 */
	{ 37, 2, 1, 2 }, /* 27 */
	{ 38, 3, 1, 1 }, /* 28 */
	{ 39, 1, 1, 1 }, /* 29 */
	{ 40, 2, 1, 1 }, /* 30 objc_add */
	{ 41, 1, 1, 1 }, /* 31 objc_delete */
	{ 42, 6, 1, 1 }, /* 32 objc_draw */
	{ 43, 4, 1, 1 }, /* 33 objc_find */
	{ 44, 1, 3, 1 }, /* 34 objc_offset */
	{ 45, 2, 1, 1 }, /* 35 */
	{ 46, 4, 2, 1 }, /* 36 objc_edit */
	{ 46, 4, 2, 2 }, /* 37 objc_xedit */
	{ 47, 8, 1, 1 }, /* 38 objc_change */
	{ 48, 4, 3, 0 }, /* 39 objc_sysvar */
	{ 50, 1, 1, 1 }, /* 40 form_do */
	{ 50, 1, 2, 3 }, /* 41 form_xdo */
	{ 51, 9, 1, 0 }, /* 42 form_dial */
	{ 51, 9, 1, 2 }, /* 43 form_xdial */
	{ 52, 1, 1, 1 }, /* 44 */
	{ 53, 1, 1, 0 }, /* 45 */
	{ 54, 0, 5, 1 }, /* 46 form_center */
	{ 55, 3, 3, 1 }, /* 47 form_keybd */
	{ 56, 2, 2, 1 }, /* 48 form_button */
	{ 60, 3, 0, 2 }, /* 49 */
	{ 61, 3, 0, 2 }, /* 50 */
	{ 62, 4, 1, 1 }, /* 51 */
	{ 63, 3, 2, 1 }, /* 52 */
	{ 64, 3, 3, 1 }, /* 53 */
	{ 65, 5, 2, 1 }, /* 54 */
	{ 70, 4, 3, 0 }, /* 55 */
	{ 71, 8, 3, 0 }, /* 56 */
	{ 72, 6, 1, 0 }, /* 57 */
	{ 73, 8, 1, 0 }, /* 58 */
	{ 74, 8, 1, 0 }, /* 59 */
	{ 75, 4, 1, 1 }, /* 60 */
	{ 76, 3, 1, 1 }, /* 61 graf_slidebox */
	{ 77, 0, 5, 0 }, /* 62 graf_handle */
	{ 77, 0, 6, 0 }, /* 63 graf_xhandle */
	{ 78, 1, 1, 1 }, /* 64 graf_mouse */
	{ 79, 0, 5, 0 }, /* 65 graf_mkstate */
	{ 80, 0, 1, 1 }, /* 66 */
	{ 81, 0, 1, 1 }, /* 67 */
	{ 82, 0, 1, 0 }, /* 68 */
	{ 90, 0, 2, 2 }, /* 69 fsel_input */
	{ 91, 0, 2, 3 }, /* 70 fsel_exinput */
	{ 100, 5, 1, 0 }, /* 71 wind_create */
	{ 101, 5, 1, 0 }, /* 72 wind_open */
	{ 102, 1, 1, 0 }, /* 73 wind_close */
	{ 103, 1, 1, 0 }, /* 74 wind_delete */
	{ 104, 3, 5, 0 }, /* 75 wind_get */
	{ 104, 2, 5, 0 }, /* 76 wind_get_grect */
	{ 104, 2, 5, 0 }, /* 77 */
	{ 104, 2, 5, 0 }, /* 78 */
	{ 105, 6, 1, 0 }, /* 79 wind_set */
	{ 105, 4, 1, 0 }, /* 80 wind_set_str */
	{ 105, 6, 1, 0 }, /* 81 wind_set_grect */
	{ 105, 4, 1, 0 }, /* 82 */
	{ 105, 4, 1, 0 }, /* 83 */
	{ 106, 2, 1, 0 }, /* 84 wind_find */
	{ 107, 1, 1, 0 }, /* 85 wind_update */
	{ 108, 6, 5, 0 }, /* 86 wind_calc*/
	{ 109, 0, 0, 0 }, /* 87 */
	{ 110, 0, 1, 1 }, /* 88 */
	{ 111, 0, 1, 0 }, /* 89 */
	{ 112, 2, 1, 0 }, /* 90 */
	{ 113, 2, 1, 1 }, /* 91 */
	{ 114, 1, 1, 1 }, /* 92 */
	{ 115, 0, 1, 1 }, /* 93 rsrc_rcfix */
	{ 120, 0, 1, 2 }, /* 94 */
	{ 121, 3, 1, 2 }, /* 95 */
	{ 122, 1, 1, 1 }, /* 96 */
	{ 123, 1, 1, 1 }, /* 97 */
	{ 124, 0, 1, 1 }, /* 98 */
	{ 125, 0, 1, 2 }, /* 99 */
	{ 126, 0, 1, 2 }, /* 100 */
	{ 127, 0, 1, 2 }, /* 101 */
	{ 135, 2, 1, 1 }, /* 102 */
	{ 135, 6, 2, 3 }, /* 103 xfrm_popup */
	{ 136, 2, 1, 1 }, /* 104 */
	{ 160, 2, 0, 4 }, /* 105 */
	{ 161, 4, 1, 3 }, /* 106 */
	{ 162, 0, 3, 1 }, /* 107 */
	{ 163, 0, 1, 1 }, /* 108 */
	{ 164, 1, 1, 3 }, /* 109 */
	{ 164, 1, 2, 1 }, /* 110 */
	{ 164, 1, 0, 1 }, /* 111 */
	{ 164, 1, 1, 1 }, /* 112 */
	{ 165, 2, 1, 1 }, /* 113 */
	{ 165, 1, 1, 2 }, /* 114 */
	{ 165, 1, 1, 2 }, /* 115 */
	{ 165, 2, 1, 4 }, /* 116 */
	{ 165, 1, 1, 4 }, /* 117 */
	{ 166, 0, 1, 2 }, /* 118 */
	{ 167, 2, 0, 2 }, /* 119 */
	{ 170, 8, 0, 8 }, /* 120 */
	{ 171, 0, 0, 2 }, /* 121 */
	{ 172, 1, 1, 1 }, /* 122 */
	{ 173, 0, 1, 1 }, /* 123 */
	{ 174, 1, 1, 1 }, /* 124 */
	{ 174, 1, 0, 1 }, /* 125 */
	{ 174, 1, 1, 1 }, /* 126 */
	{ 174, 1, 0, 1 }, /* 127 */
	{ 174, 1, 1, 1 }, /* 128 */
	{ 174, 1, 1, 1 }, /* 129 */
	{ 174, 1, 0, 1 }, /* 130 */
	{ 174, 2, 0, 1 }, /* 131 */
	{ 174, 1, 0, 1 }, /* 132 */
	{ 174, 1, 1, 2 }, /* 133 */
	{ 174, 1, 1, 1 }, /* 134 */
	{ 174, 1, 1, 1 }, /* 135 */
	{ 174, 1, 1, 1 }, /* 136 */
	{ 175, 2, 0, 2 }, /* 137 */
	{ 175, 1, 0, 2 }, /* 138 */
	{ 175, 1, 0, 1 }, /* 139 */
	{ 175, 1, 0, 1 }, /* 140 */
	{ 175, 2, 0, 3 }, /* 141 */
	{ 175, 2, 0, 2 }, /* 142 */
	{ 175, 2, 0, 1 }, /* 143 */
	{ 175, 2, 0, 3 }, /* 144 */
	{ 180, 4, 0, 4 }, /* 145 */
	{ 181, 1, 1, 1 }, /* 146 */
	{ 182, 9, 1, 1 }, /* 147 */
	{ 183, 0, 3, 1 }, /* 148 */
	{ 184, 3, 1, 1 }, /* 149 */
	{ 184, 4, 1, 1 }, /* 150 */
	{ 184, 3, 1, 4 }, /* 151 */
	{ 184, 3, 0, 1 }, /* 152 */
	{ 185, 1, 1, 2 }, /* 153 */
	{ 185, 1, 0, 1 }, /* 154 */
	{ 185, 8, 1, 1 }, /* 155 */
	{ 186, 0, 9, 2 }, /* 156 */
	{ 187, 7, 0, 1 }, /* 157 */
	{ 190, 6, 1, 6 }, /* 158 */
	{ 191, 0, 1, 1 }, /* 159 */
	{ 192, 0, 1, 2 }, /* 160 */
	{ 193, 0, 4, 4 }, /* 161 */
	{ 194, 4, 4, 6 }, /* 162 */
	{ 195, 2, 2, 0 }, /* 163 */
	{ 200, 1, 0, 0 }, /* 164 */
	{ 201, 0, 1, 1 }, /* 165 */
	{ 202, 3, 1, 3 }, /* 166 */
	{ 203, 0, 3, 1 }, /* 167 */
	{ 204, 1, 2, 0 }, /* 168 */
	{ 205, 1, 1, 2 }, /* 169 */
	{ 205, 1, 1, 1 }, /* 170 */
	{ 205, 1, 1, 3 }, /* 171 */
	{ 205, 1, 1, 2 }, /* 172 */
	{ 205, 1, 1, 1 }, /* 173 */
	{ 205, 1, 0, 1 }, /* 174 */
	{ 205, 1, 1, 1 }, /* 175 */
	{ 205, 1, 1, 2 }, /* 176 */
	{ 205, 1, 1, 2 }, /* 177 */
	{ 205, 1, 1, 2 }, /* 178 */
	{ 205, 1, 1, 2 }, /* 179 */
	{ 206, 0, 2, 3 }, /* 180 */
	{ 207, 1, 1, 3 }, /* 181 */
	{ 210, 0, 0, 0 }, /* 182 */
	{ 211, 1, 1, 1 }, /* 183 */
	{ 212, 1, 0, 1 }, /* 184 */
	{ 213, 0, 0, 1 }, /* 185 */
	{ 214, 3, 1, 1 }, /* 186 */
	{ 215, 2, 3, 2 }, /* 187 */
	{ 216, 2, 5, 1 }, /* 188 */
	{ 216, 2, 3, 1 }, /* 189 */
	{ 216, 2, 3, 1 }, /* 190 */
	{ 216, 2, 5, 1 }, /* 191 */
	{ 216, 2, 1, 1 }, /* 192 */
	{ 216, 2, 6, 1 }, /* 193 */
	{ 216, 2, 1, 1 }, /* 194 */
	{ 216, 2, 0, 1 }, /* 195 */
	{ 216, 2, 6, 1 }, /* 196 */
	{ 217, 4, 0, 2 }, /* 197 */
	{ 217, 4, 0, 1 }, /* 198 */
	{ 217, 4, 0, 1 }, /* 199 */
	{ 217, 6, 0, 1 }, /* 200 */
	{ 217, 2, 0, 2 }, /* 201 */
	{ 217, 7, 0, 3 }, /* 202 */
	{ 217, 2, 3, 1 }, /* 203 */
	{ 217, 2, 0, 2 }, /* 204 */
	{ 217, 6, 1, 1 }, /* 205 */
};


_WORD mt_appl_init(_WORD *global_aes)
{
	MT_PARMDATA aes_params;
	aes_params.intout[0] = -1;
	_aes_trap(&aes_params, aes_control_data[0], global_aes);
	return aes_params.intout[0];
}


_WORD mt_appl_write(_WORD wid, _WORD length, const void *buf, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	aes_params.intin[0] = wid;
	aes_params.intin[1] = length;
	aes_params.addrin[0] = buf;
	_aes_trap(&aes_params, aes_control_data[2], global_aes);
	return aes_params.intout[0];
}


_WORD mt_appl_find(const char *ap_fpname, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	aes_params.addrin[0] = ap_fpname;
	_aes_trap(&aes_params, aes_control_data[3], global_aes);
	return aes_params.intout[0];
}


_WORD mt_appl_exit(_WORD *global_aes)
{
	MT_PARMDATA aes_params;
	_aes_trap(&aes_params, aes_control_data[8], global_aes);
	return aes_params.intout[0];
}


_WORD mt_appl_getinfo(_WORD type, _WORD *out1, _WORD *out2, _WORD *out3, _WORD *out4, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	aes_params.intin[0] = type;
	_aes_trap(&aes_params, aes_control_data[9], global_aes);
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


_WORD mt_evnt_timer(_ULONG timeout, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	aes_params.intin[0] = (_WORD)timeout;
	aes_params.intin[1] = (_WORD)(timeout >> 16);
	_aes_trap(&aes_params, aes_control_data[14], global_aes);
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
	_aes_trap(&aes_params, aes_control_data[15], global_aes);
	ev->x = aes_params.intout[1];
	ev->y = aes_params.intout[2];
	ev->bstate = aes_params.intout[3];
	ev->kstate = aes_params.intout[4];
	*keycode = aes_params.intout[5];
	*nbclicks = aes_params.intout[6];
	return aes_params.intout[0];
}


WORD mt_objc_add(OBJECT *tree, WORD parent, WORD child, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = parent;
	aes_params.intin[1] = child;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[30], global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_delete(OBJECT *tree, WORD objnr, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = objnr;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[31], global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_draw_grect(OBJECT *tree, WORD start, WORD depth, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	*((GRECT *)(aes_params.intin+2)) = *g;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[32], global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_find(OBJECT *tree, WORD start, WORD depth, WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	aes_params.intin[2] = x;
	aes_params.intin[3] = y;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[33], global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_offset(OBJECT *tree, WORD objnr, WORD *x, WORD *y, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = objnr;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[34], global_aes);
	*x = aes_params.intout[1];
	*y = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_objc_xedit(OBJECT *tree, WORD objnr, WORD key, WORD *cursor_xpos, WORD subfn, GRECT *r, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = key;
	aes_params.intin[2] = *cursor_xpos;
	aes_params.intin[3] = subfn;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = r;
	_aes_trap(&aes_params, aes_control_data[37], global_aes);
	*cursor_xpos = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_objc_change_grect(OBJECT *tree, WORD objnr, WORD resvd, const GRECT *g, WORD newstate, WORD redraw, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = objnr;
	aes_params.intin[1] = resvd;
	*((GRECT *)(aes_params.intin+2)) = *g;
	aes_params.intin[6] = newstate;
	aes_params.intin[7] = redraw;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[38], global_aes);
	return aes_params.intout[0];
}


WORD mt_objc_sysvar(WORD ob_smode, WORD ob_swhich, WORD ob_sival1, WORD ob_sival2, WORD *ob_soval1, WORD *ob_soval2, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = ob_smode;
	aes_params.intin[1] = ob_swhich;
	aes_params.intin[2] = ob_sival1;
	aes_params.intin[3] = ob_sival2;
	_aes_trap(&aes_params, aes_control_data[39], global_aes);
	*ob_soval1 = aes_params.intout[1];
	*ob_soval2 = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_form_do(OBJECT *tree, WORD startob, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = startob;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[40], global_aes);
	return aes_params.intout[0];
}


WORD mt_form_xdo(OBJECT *tree, WORD startob, WORD *cursor_obj, XDO_INF *scantab, void *flyinf, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = startob;
	aes_params.addrin[0] = tree;
	aes_params.addrin[1] = scantab;
	aes_params.addrin[2] = flyinf;
	_aes_trap(&aes_params, aes_control_data[41], global_aes);
	*cursor_obj = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_form_dial_grect(WORD subfn, const GRECT *lg, const GRECT *bg, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = subfn;
	if (lg)
		*((GRECT *)(aes_params.intin+1)) = *lg;
	*((GRECT *)(aes_params.intin+5)) = *bg;
	_aes_trap(&aes_params, aes_control_data[42], global_aes);
	return aes_params.intout[0];
}


WORD mt_form_xdial_grect(WORD subfn, const GRECT *lg, const GRECT *bg, void **flyinf, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = subfn;
	if (lg)
		*((GRECT *)(aes_params.intin+1)) = *lg;
	*((GRECT *)(aes_params.intin+5)) = *bg;
	aes_params.addrin[0] = flyinf;
	aes_params.addrin[1] = 0;		/* reserviert */
	_aes_trap(&aes_params, aes_control_data[43], global_aes);
	return aes_params.intout[0];
}


WORD mt_form_center_grect(OBJECT *tree, GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[46], global_aes);
	*g = *((GRECT *)(aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_form_keybd(OBJECT *tree, WORD obj, WORD nxt, WORD key, WORD *nextob, WORD *nextchar, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = obj;
	aes_params.intin[1] = key;
	aes_params.intin[2] = nxt;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[47], global_aes);

	*nextob = aes_params.intout[1];
	*nextchar = aes_params.intout[2];
	return aes_params.intout[0];
}


WORD mt_form_button(OBJECT *tree, WORD obj, WORD nclicks, WORD *nextob, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = obj;
	aes_params.intin[1] = nclicks;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[48], global_aes);
	*nextob = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_graf_slidebox(OBJECT *tree, WORD parent, WORD obj, WORD h, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = parent;
	aes_params.intin[1] = obj;
	aes_params.intin[2] = h;
	aes_params.addrin[0] = tree;
	_aes_trap(&aes_params, aes_control_data[61], global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_handle(WORD *wchar, WORD *hchar, WORD *wbox, WORD *hbox, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	_aes_trap(&aes_params, aes_control_data[62], global_aes);
	*wchar = aes_params.intout[1];
	*hchar = aes_params.intout[2];
	*wbox = aes_params.intout[3];
	*hbox = aes_params.intout[4];
	return aes_params.intout[0];
}


WORD mt_graf_mouse(WORD code, const MFORM *adr, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = code;
	aes_params.addrin[0] = adr;
	_aes_trap(&aes_params, aes_control_data[64], global_aes);
	return aes_params.intout[0];
}


WORD mt_graf_mkstate_event(EVNTDATA *ev, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	_aes_trap(&aes_params, aes_control_data[65], global_aes);
	*ev = *((EVNTDATA *) (aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_fsel_input(char *path, char *name, WORD *button, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.addrin[0] = path;
	aes_params.addrin[1] = name;
	_aes_trap(&aes_params, aes_control_data[69], global_aes);
	*button = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_fsel_exinput(char *path, char *name, WORD *button, const char *label, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.addrin[0] = path;
	aes_params.addrin[1] = name;
	aes_params.addrin[2] = label;
	_aes_trap(&aes_params, aes_control_data[70], global_aes);
	*button = aes_params.intout[1];
	return aes_params.intout[0];
}


WORD mt_wind_create_grect(WORD kind, const GRECT *maxsize, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = kind;
	*((GRECT *)(aes_params.intin+1)) = *maxsize;
	_aes_trap(&aes_params, aes_control_data[71], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_open_grect(WORD whdl, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	*((GRECT *)(aes_params.intin+1)) = *g;
	_aes_trap(&aes_params, aes_control_data[72], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_close(WORD whdl, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	_aes_trap(&aes_params, aes_control_data[73], global_aes);
	return aes_params.intout[0];
}

WORD mt_wind_delete(WORD whdl, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	_aes_trap(&aes_params, aes_control_data[74], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_get(WORD whdl, WORD subfn, WORD *g1, WORD *g2, WORD *g3, WORD *g4, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	if (g1)
		aes_params.intin[2] = *g1;		/* for WF_DCOLOR */
	_aes_trap(&aes_params, aes_control_data[75], global_aes);

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

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	_aes_trap(&aes_params, aes_control_data[76], global_aes);
	*g = *((GRECT *) (aes_params.intout+1));

	return aes_params.intout[0];
}


WORD mt_wind_set(WORD whdl, WORD subfn, WORD g1, WORD g2, WORD g3, WORD g4, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	aes_params.intin[2] = g1;
	aes_params.intin[3] = g2;
	aes_params.intin[4] = g3;
	aes_params.intin[5] = g4;
	_aes_trap(&aes_params, aes_control_data[79], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_set_str(WORD whdl, WORD subfn, const char *s, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	*((const char **) (aes_params.intin+2)) = s;
	_aes_trap(&aes_params, aes_control_data[80], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_set_grect(WORD whdl, WORD subfn, const GRECT *g, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	*((GRECT *) (aes_params.intin+2)) = *g;
	_aes_trap(&aes_params, aes_control_data[81], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_find(WORD x, WORD y, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = x;
	aes_params.intin[1] = y;
	_aes_trap(&aes_params, aes_control_data[84], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_update(WORD subfn, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = subfn;
	_aes_trap(&aes_params, aes_control_data[85], global_aes);
	return aes_params.intout[0];
}


WORD mt_wind_calc_grect(WORD subfn, WORD kind, const GRECT *ing, GRECT *outg, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.intin[0] = subfn;
	aes_params.intin[1] = kind;
	*((GRECT *) (aes_params.intin+2)) = *ing;
	_aes_trap(&aes_params, aes_control_data[86], global_aes);
	*outg = *((GRECT *) (aes_params.intout+1));
	return aes_params.intout[0];
}


WORD mt_rsrc_rcfix(void *rsh, WORD *global_aes)
{
	MT_PARMDATA aes_params;

	aes_params.addrin[0] = rsh;
	_aes_trap(&aes_params, aes_control_data[93], global_aes);
	return aes_params.intout[0];
}


WORD mt_xfrm_popup(OBJECT *tree, WORD x, WORD y, WORD firstscrlob,
				WORD lastscrlob, WORD nlines,
				void /* __CDECL */ (*init)(struct POPUP_INIT_args),
				void *param, WORD *lastscrlpos,
				WORD *global_aes)
{
	MT_PARMDATA aes_params;

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

	_aes_trap(&aes_params, aes_control_data[103], global_aes);
	*lastscrlpos = aes_params.intout[1];
	return aes_params.intout[0];
}
