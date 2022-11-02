#include <tos.h>
#include <mt_aes.h>

#undef min
#undef max
#undef abs
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define abs(x) ((x) < 0 ? (-(x)) : (x))

_WORD aes_global[AES_GLOBMAX];

_WORD rc_intersect(const GRECT *r1, GRECT *r2)
{
	_WORD tx, ty, tw, th;
	_WORD ret;

	tx = max(r2->g_x, r1->g_x);
	tw = min(r2->g_x + r2->g_w, r1->g_x + r1->g_w) - tx;
	
	ret = tw > 0;
	if (ret)
	{
		ty = max(r2->g_y, r1->g_y);
		th = min(r2->g_y + r2->g_h, r1->g_y + r1->g_h) - ty;
		
		ret = th > 0;
		if (ret)
		{
			r2->g_x = tx;
			r2->g_y = ty;
			r2->g_w = tw;
			r2->g_h = th;
		}
	}
	
	return ret;
}


_WORD _mt_aes_alt(MX_PARMDATA *data, const _WORD *control, _WORD *global_aes)
{
	AESPB pb;
	
	pb.control = data->control;
	data->control[0] = control[0];
	data->control[1] = control[1];
	data->control[2] = control[2];
	data->control[3] = control[3];
	data->control[4] = 0;
	pb.global = global_aes;
	if (pb.global == NULL)
		pb.global = aes_global;
	pb.intin = data->intin;
	pb.intout = data->intout;
	pb.addrin = data->addrin;
	pb.addrout = data->addrout;
	return aes(&pb);
}


_WORD mt_appl_init(_WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 10, 0, 1, 0 };
	aes_params.intout[0] = -1;
	return _mt_aes_alt(&aes_params, aes_control_data, global_aes);
}


_WORD mt_objc_draw_grect(OBJECT *tree, _WORD start, _WORD depth, const GRECT *r, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 42, 6, 1, 1 };
	
	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	*(GRECT *)&aes_params.intin[2] = *r;
	aes_params.addrin[0] = tree;
	
	_mt_aes_alt(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


_WORD mt_objc_offset(OBJECT *tree, _WORD object, _WORD *x, _WORD *y, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 44, 1, 3, 1 };
	
	aes_params.intin[0] = object;
	aes_params.addrin[0] = tree;
	
	_mt_aes_alt(&aes_params, aes_control_data, global_aes);
	*x = aes_params.intout[1];
	*y = aes_params.intout[2];
	return aes_params.intout[0];
}


_WORD mt_form_alert(_WORD fo_adefbttn, const char *fo_astring, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 52, 1, 1, 1 };
	
	aes_params.intin[0] = fo_adefbttn;
	aes_params.addrin[0] = fo_astring;
	
	_mt_aes_alt(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


_WORD mt_graf_mouse(_WORD gr_monumber, const MFORM *gr_mofaddr, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 78, 1, 1, 1 };
	
	aes_params.intin[0] = gr_monumber;
	aes_params.addrin[0] = gr_mofaddr;
	
	return _mt_aes_alt(&aes_params, aes_control_data, global_aes);
}


_WORD mt_graf_mkstate_event(EVNTDATA *data, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 79, 0, 5, 0 };
	
	_mt_aes_alt(&aes_params, aes_control_data, global_aes);
	*data = *((EVNTDATA *)&aes_params.intout[1]);
	return aes_params.intout[0];
}


_WORD mt_wind_get(_WORD whdl, _WORD subfn, _WORD *g1, _WORD *g2, _WORD *g3, _WORD *g4, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 104, 2, 5, 0 };
	
	aes_params.intin[0] = whdl;
	aes_params.intin[1] = subfn;
	_mt_aes_alt(&aes_params, aes_control_data, global_aes);
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
