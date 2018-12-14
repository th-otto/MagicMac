#include <portab.h>
#define wdlg_close wdlg_close_ex
#include <aes.h>
#define __GRECT
#define __MOBLK
#define __PORTAES_H__
#define _WORD WORD
#define _LONG LONG
#define _VOID void
#define _CDECL cdecl
#define EXTERN_C_BEG
#define EXTERN_C_END
#include <wdlgwdlg.h>
#include <wdlglbox.h>
#undef wdlg_close
_WORD wdlg_close(DIALOG *dialog);
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"


static struct res st_resolutions[] = {
	{ NULL, 0, " 640 * 400, ST High", ST_HIGH, BPS1 },
	{ NULL, 0, " 640 * 200, ST Medium", ST_MED, BPS1 }, /* BUG; should be BPS2 */
	{ NULL, 0, " 320 * 200, ST Low    ", ST_LOW, BPS1 }, /* BUG; should be BPS4 */
	{ NULL, 0, NULL, 0, 0 }
};
struct res *st_res_tab[] = {
	&st_resolutions[0],
	&st_resolutions[1],
	&st_resolutions[2],
	NULL,
	NULL
};

static struct res tt_resolutions[] = {
	{ NULL,                0, " 640 * 400, ST High", ST_HIGH, BPS1 },
	{ NULL,                0, NULL, 0, 0 },
	{ NULL,                0, " 640 * 200, ST Medium", ST_MED, 0 }, /* BUG; should be BPS2 */
	{ &tt_resolutions[4],  0, " 320 * 200, ST Low    ", ST_LOW, 0 }, /* BUG; should be BPS4 */
	{ NULL,                0, " 640 * 480, TT Medium", TT_MED, 0 }, /* BUG; should be BPS4 */
	{ NULL,                0, " 320 * 480, TT Low    ", TT_LOW, 0 } /* BUG; should be BPS8 */
};

struct res *tt_res_tab[] = {
	&tt_resolutions[0],
	&tt_resolutions[2],
	&tt_resolutions[3],
	&tt_resolutions[5],
	NULL
};

struct res tt_high[1] = {
	{ NULL,                 0, "1280 * 960, TT High", TT_HIGH, BPS1 }
};

static struct res vga_resolutions[] = {
	{ &vga_resolutions[1],  0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS1 },
	{ &vga_resolutions[2],  0, " 640 * 400, ST High", FALCON_REZ, STMODES|VGA|COL80|BPS1 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS1 },
	{ &vga_resolutions[4],  0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS2 },
	{ &vga_resolutions[5],  0, " 320 * 480", FALCON_REZ, VGA|BPS2 },
	{ &vga_resolutions[6],  0, " 640 * 200, ST Medium", FALCON_REZ, VERTFLAG|STMODES|VGA|COL80|BPS2 },
	{ &vga_resolutions[7],  0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS2 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS2 },
	{ &vga_resolutions[9],  0, " 320 * 200, ST Low    ", FALCON_REZ, VERTFLAG|STMODES|VGA|BPS4 },
	{ &vga_resolutions[10], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS4 },
	{ &vga_resolutions[11], 0, " 320 * 480", FALCON_REZ, VGA|BPS4 },
	{ &vga_resolutions[12], 0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS4 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS4 },
	{ &vga_resolutions[14], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS8 },
	{ &vga_resolutions[15], 0, " 320 * 480", FALCON_REZ, VGA|BPS8 },
	{ &vga_resolutions[16], 0, " 640 * 240", FALCON_REZ, VERTFLAG|VGA|COL80|BPS8 },
	{ NULL,                 0, " 640 * 480", FALCON_REZ, VGA|COL80|BPS8 },
	{ &vga_resolutions[18], 0, " 320 * 240", FALCON_REZ, VERTFLAG|VGA|BPS16 },
	{ NULL,                 0, " 320 * 480", FALCON_REZ, VGA|BPS16 }
};

struct res *vga_res_tab[] = {
	&vga_resolutions[0],
	&vga_resolutions[3],
	&vga_resolutions[8],
	&vga_resolutions[13],
	&vga_resolutions[17]
};


static struct res tv_resolutions[] = {
	{ &tv_resolutions[1],  0, " 640 * 200", FALCON_REZ, TV|COL80|BPS1 },
	{ &tv_resolutions[2],  0, " 640 * 400, ST High", FALCON_REZ, VERTFLAG|TV|STMODES|COL80|BPS1 },
	{ &tv_resolutions[3],  0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS1 },
	{ NULL,                0, " 768 * 480", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS1 },
	{ &tv_resolutions[5],  0, " 320 * 200", FALCON_REZ, TV|BPS2 },
	{ &tv_resolutions[6],  0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS2 },
	{ &tv_resolutions[7],  0, " 384 * 240", FALCON_REZ, TV|OVERSCAN|BPS2 },
	{ &tv_resolutions[8],  0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS2 },
	{ &tv_resolutions[9],  0, " 640 * 200, ST Medium", FALCON_REZ, TV|STMODES|COL80|BPS2 },
	{ &tv_resolutions[10], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS2 },
	{ &tv_resolutions[11], 0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS2 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS2 },
	{ &tv_resolutions[13], 0, " 320 * 200, ST Low    ", FALCON_REZ, TV|STMODES|BPS4 },
	{ &tv_resolutions[14], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS4 },
	{ &tv_resolutions[15], 0, " 384 * 240", FALCON_REZ, OVERSCAN|BPS4 },
	{ &tv_resolutions[16], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS4 },
	{ &tv_resolutions[17], 0, " 640 * 200", FALCON_REZ, COL80|BPS4 },
	{ &tv_resolutions[18], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS4 },
	{ &tv_resolutions[19], 0, " 768 * 240", FALCON_REZ, OVERSCAN|COL80|BPS4 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS4 },
	{ &tv_resolutions[21], 0, " 320 * 200", FALCON_REZ, TV|BPS8 },
	{ &tv_resolutions[22], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS8 },
	{ &tv_resolutions[23], 0, " 384 * 240", FALCON_REZ, TV|OVERSCAN|BPS8 },
	{ &tv_resolutions[24], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS8 },
	{ &tv_resolutions[25], 0, " 640 * 200", FALCON_REZ, TV|COL80|BPS8 },
	{ &tv_resolutions[26], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS8 },
	{ &tv_resolutions[27], 0, " 768 * 240", FALCON_REZ, TV|OVERSCAN|COL80|BPS8 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS8 },
	{ &tv_resolutions[29], 0, " 320 * 200", FALCON_REZ, TV|BPS16 },
	{ &tv_resolutions[30], 0, " 320 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|BPS16 },
	{ &tv_resolutions[31], 0, " 384 * 240", FALCON_REZ, OVERSCAN|TV|BPS16 },
	{ &tv_resolutions[32], 0, " 384 * 480, interlaced", FALCON_REZ, VERTFLAG|OVERSCAN|TV|BPS16 },
	{ &tv_resolutions[33], 0, " 640 * 200", FALCON_REZ, TV|COL80|BPS16 },
	{ &tv_resolutions[34], 0, " 640 * 400, interlaced", FALCON_REZ, VERTFLAG|TV|COL80|BPS16 },
	{ &tv_resolutions[35], 0, " 768 * 240", FALCON_REZ, OVERSCAN|TV|COL80|BPS16 },
	{ NULL,                0, " 768 * 480, interlaced", FALCON_REZ, VERTFLAG|OVERSCAN|TV|COL80|BPS16 },
};

struct res *tv_res_tab[] = {
	&tv_resolutions[0],
	&tv_resolutions[4],
	&tv_resolutions[12],
	&tv_resolutions[20],
	&tv_resolutions[28]
};


struct res st_high[1] = {
	{ NULL, 0, " 640 * 400, ST High", FALCON_REZ, STMODES|COL80|BPS1 }
};

