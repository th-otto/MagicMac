#define __WDIALOG_IMPLEMENTATION
#define __HNDL_OBJ
#define __MTDIALOG
#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "wdlgmain.h"

WORD aes_flags;
WORD aes_font;
WORD aes_height;
WORD hor_3d;
WORD ver_3d;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;
WORD vdi_handle;
WORD vdi_device;
WORD workout[57];
WORD xworkout[57];
WORD cpu020;


BOOLEAN wd_aes_init(WORD aes_handle)
{
	if (aes_handle == -1)
	{
		aes_handle = mt_graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox, NULL);
	}
	vdi_handle = open_vwork(aes_handle, workout);
	vdi_device = Getrez() + 2;
	if (vdi_handle > 0)
	{
		vq_extnd(vdi_handle, 1, xworkout);
		return TRUE;
	}
	vdi_handle = aes_handle;
	return FALSE;
}


BOOLEAN wd_xexit(void)
{
	if (vdi_handle != 0)
	{
		v_clsvwk(vdi_handle);
		vdi_handle = 0;
	}
	return TRUE;
}


BOOLEAN wd_nvdi_exit(void)
{
	vdi_handle = 0;
	return TRUE;
}


BOOLEAN wd_xinit(WORD aes_version, WORD ap_id)
{
	aes_global[0] = aes_version;
	aes_global[2] = ap_id;
	cpu020 = 0;
	if (vdi_handle == 0)
		wd_aes_init(-1);
	mt_graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox, NULL);
	aes_flags = get_aes_info(&aes_font, &aes_height, &hor_3d, &ver_3d);
	return TRUE;
}


WORD open_vwork(WORD aes_handle, WORD *workout)
{
	WORD workin[11];
	WORD i;
	WORD handle;
	
	for (i = 0; i < 10; i++)
		workin[i] = 1;
	workin[10] = 2;
	handle = aes_handle;
	v_opnvwk(workin, &handle, workout);
	return handle;
}



WORD aes_check(void)
{
	WORD aes_version;
	WORD ret;
	
	aes_global[0] = 0;
	ret = mt_appl_init(NULL);
	aes_version = aes_global[0];
	if (aes_version != 0 && ret >= 0)
		mt_appl_exit(NULL);
	return aes_version;
}
