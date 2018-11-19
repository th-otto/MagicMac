#include <portab.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include "std.h"
#include "wdlgmain.h"
#include "mt_aes_i.h"
#include "pdlg_slb.h"

#define E_OK 0
#define ERROR -1

typedef void PD;

static char mypath[128];
static char myname[128];
static AES_FUNCTION *old_pdlg_create;
static AES_FUNCTION *old_pdlg_delete;
static AES_FUNCTION *old_pdlg_open;
static AES_FUNCTION *old_pdlg_close;
static AES_FUNCTION *old_pdlg_get;
static AES_FUNCTION *old_pdlg_set;
static AES_FUNCTION *old_pdlg_evnt;
static AES_FUNCTION *old_pdlg_do;
WORD hor_3d = 0;
WORD ver_3d = 0;
WORD cpu020 = 0;
int errno;
WORD aes_handle;
WORD gl_wchar;
WORD gl_hchar;
WORD gl_wbox;
WORD gl_hbox;

extern void *aes_dispatcher;



static void do_pdlg_create(AESPB *pb)
{
	SLB_HANDLE slb;
	SLB_EXEC exec;
	
	Slbopen(myname, mypath, 1, &slb, &exec);
	aes_handle = mt_graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox, pb->global);
	dsp_pdlg_create(pb);
}


static int install_functions(void)
{
	sys_set_getdisp(&aes_dispatcher, NULL);
	old_pdlg_create = sys_set_getfn(200);
	old_pdlg_delete = sys_set_getfn(201);
	old_pdlg_open = sys_set_getfn(202);
	old_pdlg_close = sys_set_getfn(203);
	old_pdlg_get = sys_set_getfn(204);
	old_pdlg_set = sys_set_getfn(205);
	old_pdlg_evnt = sys_set_getfn(206);
	old_pdlg_do = sys_set_getfn(207);
	sys_set_setfn(207, dsp_pdlg_do);
	sys_set_setfn(206, dsp_pdlg_evnt);
	sys_set_setfn(205, dsp_pdlg_set);
	sys_set_setfn(204, dsp_pdlg_get);
	sys_set_setfn(203, dsp_pdlg_close);
	sys_set_setfn(202, dsp_pdlg_open);
	sys_set_setfn(201, dsp_pdlg_delete);
	sys_set_setfn(200, do_pdlg_create);
	return TRUE;
}


static int uninstall_functions(void)
{
	sys_set_setfn(207, old_pdlg_do);
	sys_set_setfn(206, old_pdlg_evnt);
	sys_set_setfn(205, old_pdlg_set);
	sys_set_setfn(204, old_pdlg_get);
	sys_set_setfn(203, old_pdlg_close);
	sys_set_setfn(202, old_pdlg_open);
	sys_set_setfn(201, old_pdlg_delete);
	sys_set_setfn(200, old_pdlg_create);
	return TRUE;
}


LONG cdecl slb_init(BASEPAGE *bp)
{
	char *p;
	
	vstrcpy(mypath, bp->p_cmdlin);
	p = strrchr(mypath, '\\');
	if (p != NULL)
		p++;
	else
		p = mypath;
	vstrcpy(myname, p);
	*p = '\0';
	if (install_functions())
		return E_OK;
	return ERROR;
}


void cdecl slb_exit(BASEPAGE *bp)
{
	UNUSED(bp);
	uninstall_functions();
}


LONG cdecl slb_open(PD *pd)
{
	UNUSED(pd);
	return E_OK;
}


void cdecl slb_close(PD *pd)
{
	UNUSED(pd);
}
