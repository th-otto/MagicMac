#include <tos.h>
#include <mt_aes.h>
#include "mt_aes_i.h"

typedef struct
{
	WORD	control[5];
	WORD	intin[AES_INTINMAX];
	WORD	intout[AES_INTOUTMAX];
	void	*addrin[AES_ADDRINMAX];
	void	*addrout[AES_ADDROUTMAX];
} MT_PARMDATA;

void _aes_trap(MT_PARMDATA *aes_params, const WORD *control, WORD *global_aes);



void sys_set_getdisp(void **disp_adr, void **disp_err)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[] = { 0, 1, 0, 0 };

	aes_params.intin[0] = 0;	/* Subcode 0: AES-Dispatcher ermitteln */
	_aes_trap(&aes_params, aes_control_data, NULL);
	*disp_adr = aes_params.addrout[0];
	if	(disp_err)
		*disp_err = aes_params.addrout[1];
}


AES_FUNCTION *sys_set_getfn(WORD fn)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[] = { 0, 2, 0, 0 };

	aes_params.intin[0] = 1;	/* Subcode 1: AES-Funktion ermitteln */
	aes_params.intin[1] = fn;	/* Funktionsnummer */
	_aes_trap(&aes_params, aes_control_data, NULL);
	return (AES_FUNCTION *) aes_params.addrout[0];
}


WORD sys_set_setfn(WORD fn, AES_FUNCTION *f)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[] = { 0, 2, 1, 1};							/* Funktion 0 */

	aes_params.intin[0] = 2;	/* Subcode 2: change AES function */
	aes_params.intin[1] = fn;	/* Funktionsnummer */
	aes_params.addrin[0] = (void *) f;
	_aes_trap(&aes_params, aes_control_data, NULL);
	return aes_params.intout[0];
}


void *sys_set_appl_getinfo(AES_FUNCTION *f)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[] = { 0, 1, 0, 1 };

	aes_params.intin[0] = 3;	/* Subcode 3: appl_getinfo einklinken */
	aes_params.addrin[0] = (void *) f;
	_aes_trap(&aes_params, aes_control_data, NULL);
	return aes_params.addrout[0];
}


void sys_set_colourtab(WORD *colourtab)
{
	MT_PARMDATA aes_params;
	static WORD const aes_control_data[] = { 0, 1, 0, 1 };

	aes_params.intin[0] = 5;	/* Subcode 5: Farbtabelle Åbergeben */
	aes_params.addrin[0] = colourtab;
	_aes_trap(&aes_params, aes_control_data, NULL);
}
