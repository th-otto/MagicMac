#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "nvram.rsh"
#include "cpxdata.h"

XCPB *global_xcpb;

CPXINFO *cdecl cpx_init(XCPB *xcpb)
{
	global_xcpb = xcpb;
	if (global_xcpb->booting)
	{
		return (CPXINFO *)1;
	}
	if (!global_xcpb->SkipRshFix)
	{
		global_xcpb->rsh_fix(NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
			rs_object, rs_tedinfo, rs_strings,
			rs_iconblk, rs_bitblk, rs_frstr,
			rs_frimg, rs_trindex, rs_imdope);
	}
	return NULL;
}