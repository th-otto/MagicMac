#include <portab.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>
#include "std.h"
#include "wdlgmain.h"
#include "mt_aes_i.h"
#include "pdlg_slb.h"

#define NINTOUT  control[2]
#define NADDROUT control[4]




void dsp_pdlg_create(AESPB *pb)
{
	WORD *control;
	WORD *intin = pb->intin;
	void **addrout = pb->addrout;

	*addrout = pdlg_create(intin[0]);
	control = pb->control;
	NINTOUT = 0;
	NADDROUT = 1;
}


void dsp_pdlg_delete(AESPB *pb)
{
	WORD *control;
	void **addrin = pb->addrin;

	pb->intout[0] = pdlg_delete(addrin[0]);
	control = pb->control;
	NINTOUT = 1;
	NADDROUT = 0;
}


void dsp_pdlg_open(AESPB *pb)
{
	WORD *control;
	WORD *intin = pb->intin;
	void **addrin = pb->addrin;

	pb->intout[0] = pdlg_xopen(addrin[0], addrin[1], addrin[2], intin[0], intin[1], intin[2], intin[3]);
	control = pb->control;
	NINTOUT = 1;
	NADDROUT = 0;
}


void dsp_pdlg_close(AESPB *pb)
{
	WORD *control;
	WORD *intout = pb->intout;
	void **addrin = pb->addrin;

	intout[0] = pdlg_close(addrin[0], &intout[1], &intout[2]);
	control = pb->control;
	NINTOUT = 3;
	NADDROUT = 0;
}


void dsp_pdlg_get(AESPB *pb)
{
	WORD *control = pb->control;
	WORD *intin = pb->intin;

	switch (intin[0])
	{
	case 0:
		*((LONG *)(pb->intout)) = pdlg_get_setsize();
		NINTOUT = 2;
		NADDROUT = 0;
		break;
	default:
		NINTOUT = 0;
		NADDROUT = 0;
		break;
	}
}


void dsp_pdlg_set(AESPB *pb)
{
	WORD *control = pb->control;
	WORD *intout = pb->intout;
	void **addrin = pb->addrin;
	
	switch (pb->intin[0])
	{
	case 0:
		intout[0] = pdlg_add_printers(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 1:
		intout[0] = pdlg_remove_printers(addrin[0]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 2:
		intout[0] = pdlg_update(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 3:
		intout[0] = pdlg_add_sub_dialogs(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 4:
		intout[0] = pdlg_remove_sub_dialogs(addrin[0]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 5:
		pb->addrout[0] = pdlg_new_settings(addrin[0]);
		NINTOUT = 0;
		NADDROUT = 1;
		break;
	case 6:
		intout[0] = pdlg_free_settings(addrin[0]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 7:
		intout[0] = pdlg_dflt_settings(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 8:
		intout[0] = pdlg_validate_settings(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 9:
		intout[0] = pdlg_use_settings(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	case 10:
		intout[0] = pdlg_use_settings(addrin[0], addrin[1]);
		NINTOUT = 1;
		NADDROUT = 0;
		break;
	}
}


void dsp_pdlg_evnt(AESPB *pb)
{
	WORD *control;
	WORD *intout = pb->intout;
	void **addrin = pb->addrin;

	intout[0] = pdlg_evnt(addrin[0], addrin[1], addrin[2], &intout[1]);
	control = pb->control;
	NINTOUT = 1;
	NADDROUT = 0;
}


void dsp_pdlg_do(AESPB *pb)
{
	WORD *control;
	void **addrin = pb->addrin;
	
	pb->intout[0] = pdlg_do(addrin[0], addrin[1], addrin[2], pb->intin[0]);
	control = pb->control;
	NINTOUT = 1;
	NADDROUT = 0;
}
