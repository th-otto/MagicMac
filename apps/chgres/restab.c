#include <portab.h>
#include <aes.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"

const char *const bpp_tab[5] = {
	"    2",
	"    4",
	"   16",
	"  256",
	"32768"
};

WORD const ctrl_objs[5] = { CHGRES_BOX, CHGRES_UP, CHGRES_DOWN, CHGRES_BACK, CHGRES_SLIDER };
WORD const objs[N_ITEMS] = {
	CHGRES_BOX_FIRST,
	CHGRES_BOX_FIRST+1,
	CHGRES_BOX_FIRST+2,
	CHGRES_BOX_FIRST+3,
	CHGRES_BOX_FIRST+4,
	CHGRES_BOX_FIRST+5,
	CHGRES_BOX_FIRST+6,
	CHGRES_BOX_FIRST+7,
	CHGRES_BOX_FIRST+8,
	CHGRES_BOX_LAST
};



struct res *get_restab(WORD vdo, WORD bpp, WORD montype)
{
	struct res *res = NULL;
	
	switch (vdo)
	{
	case 0: /* ST-compatible hardware */
	case 1: /* STE-compatible hardware */
		res = st_res_tab[bpp];
		break;
	case 2: /* TT-compatible hardware */
		if (montype == MON_MONO)
			res = tt_high;
		else
			res = tt_res_tab[bpp];
		break;
	case 3:
		if (montype == MON_VGA)
			res = vga_res_tab[bpp];
		else if (montype == MON_MONO)
			res = st_high;
		else
			res = tv_res_tab[bpp];
		break;
	}
	return res;
}
