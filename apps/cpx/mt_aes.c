#include <tos.h>
#include <mt_aes.h>

typedef struct
{
	_WORD	control[5];
	_WORD	intin[AES_INTINMAX];
	_WORD	intout[AES_INTOUTMAX];
	void	*addrin[AES_ADDRINMAX];
	void	*addrout[AES_ADDROUTMAX];
} MT_PARMDATA;


void _aes_trap(MT_PARMDATA *aes_params, const _WORD *control, _WORD *global_aes);


_WORD mt_objc_draw_grect(OBJECT *tree, _WORD start, _WORD depth, const GRECT *r, WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 42, 6, 1, 1 };
	
	aes_params.intin[0] = start;
	aes_params.intin[1] = depth;
	*(GRECT *)&aes_params.intin[2] = *r;
	aes_params.addrin[0] = tree;
	
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}


_WORD mt_objc_offset(OBJECT *tree, _WORD object, _WORD *x, _WORD *y, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 44, 1, 3, 1 };
	
	aes_params.intin[0] = object;
	aes_params.addrin[0] = tree;
	
	_aes_trap(&aes_params, aes_control_data, global_aes);
	*x = aes_params.intout[1];
	*y = aes_params.intout[2];
	return aes_params.intout[0];
}


_WORD mt_form_alert(_WORD fo_adefbttn, const char *fo_astring, _WORD *global_aes)
{
	MT_PARMDATA aes_params;
	static _WORD const aes_control_data[4] = { 52, 1, 1, 1 };
	
	aes_params.intin[0] = fo_adefbttn;
	aes_params.addrin[0] = fo_astring;
	
	_aes_trap(&aes_params, aes_control_data, global_aes);
	return aes_params.intout[0];
}
