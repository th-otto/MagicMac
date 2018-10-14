#include <tos.h>
#include <mt_aes.h>

_WORD aes_global[AES_GLOBMAX];

_WORD _mt_aes(MX_PARMDATA *data, const _WORD *control, _WORD *global_aes)
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


_WORD mt_appl_init(WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 10, 0, 1, 0 };
	aes_params.intout[0] = -1;
	return _mt_aes(&aes_params, aes_control_data, global_aes);
}


_WORD mt_objc_draw_grect(OBJECT *tree, _WORD start, _WORD depth, const GRECT *r, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 42, 6, 1, 1 };
	
	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	*(GRECT *)&aes_params.intin[2] = *r;
	aes_params.addrin[0] = tree;
	
	_mt_aes(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


_WORD mt_objc_offset(OBJECT *tree, _WORD object, _WORD *x, _WORD *y, _WORD *global_aes)
{
	MX_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 44, 1, 3, 1 };
	
	aes_params.intin[0] = object;
	aes_params.addrin[0] = tree;
	
	_mt_aes(&aes_params, aes_control_data, global_aes);
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
	
	_mt_aes(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}
