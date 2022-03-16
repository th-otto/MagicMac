#ifdef __PUREC__
#include <portab.h>
#include <aes.h>
#define __GRECT
#define __MOBLK
#define __PORTAES_H__
#define EXTERN_C_BEG
#define EXTERN_C_END
#include <tos.h>
#else
#include <gem.h>
#include <osbind.h>
#include <mint/falcon.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "chgres.h"
#include "extern.h"

#define R (struct res *)

short const valid_planes[MAX_DEPTHS] = { 1, 2, 4, 8, 15, 16, 24, 32 };

static struct resbase st_mono_resolutions[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch",     ST_HIGH, 0,                                             0, 640, 400, 640, 400 },
};
struct res *st_mono_table[MAX_DEPTHS] = {
	R &st_mono_resolutions[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase st_color_resolutions[] = {
	{ NULL,                       0, " 640 *  200, ST Mittel",   ST_MED, 0,                                              0, 640, 200, 640, 200 },
	{ NULL,                       0, " 320 *  200, ST Niedrig",  ST_LOW, 0,                                              0, 320, 200, 320, 200 },
	{ NULL,                       0, NULL, 0, 0, 0, 0, 0, 0, 0 }
};
struct res *st_color_table[MAX_DEPTHS] = {
	NULL,
	R &st_color_resolutions[0],
	R &st_color_resolutions[1],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase tt_color_resolutions[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch",     ST_HIGH, 0,                                             0, 640, 400, 640, 400 },
	{ NULL,                       0, NULL, 0, 0, 0, 0, 0, 0, 0 },
	{ NULL,                       0, " 640 *  200, ST Mittel",   ST_MED, 0,                                              0, 640, 200, 640, 200 },
	{ R &tt_color_resolutions[4], 0, " 320 *  200, ST Niedrig",  ST_LOW, 0,                                              0, 320, 200, 320, 200 },
	{ NULL,                       0, " 640 *  480, TT Mittel",   TT_MED, 0,                                              0, 640, 480, 640, 480 },
	{ NULL,                       0, " 320 *  480, TT Niedrig",  TT_LOW, 0,                                              0, 320, 480, 320, 480 }
};
struct res *tt_color_table[MAX_DEPTHS] = {
	R &tt_color_resolutions[0],
	R &tt_color_resolutions[2],
	R &tt_color_resolutions[3],
	R &tt_color_resolutions[5],
	NULL,
	NULL,
	NULL,
	NULL
};

static struct resbase tt_mono_resolutions[] = {
	{ NULL,                       0, "1280 *  960, TT Hoch",     TT_HIGH, 0,                                             0, 1280, 960, 1280, 960 }
};
struct res *tt_mono_table[MAX_DEPTHS] = {
	R &tt_mono_resolutions[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};



static struct resbase vga_resolutions[] = {
	{ R &vga_resolutions[1],      0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS1,                    0, 640, 240, 640, 240 },
	{ R &vga_resolutions[2],      0, " 640 *  400, ST Hoch",     FALCON_REZ, STMODES|VGA|COL80|BPS1,                     0, 640, 400, 640, 400 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS1,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[4],      0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS2,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[5],      0, " 320 *  480",              FALCON_REZ, VGA|BPS2,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[6],      0, " 640 *  200, ST Mittel",   FALCON_REZ, VERTFLAG|STMODES|VGA|COL80|BPS2,            0, 640, 200, 640, 200 },
	{ R &vga_resolutions[7],      0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS2,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS2,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[9],      0, " 320 *  200, ST Niedrig",  FALCON_REZ, VERTFLAG|STMODES|VGA|BPS4,                  0, 320, 200, 320, 200 },
	{ R &vga_resolutions[10],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS4,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[11],     0, " 320 *  480",              FALCON_REZ, VGA|BPS4,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[12],     0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS4,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS4,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[14],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS8,                          0, 320, 240, 320, 240 },
	{ R &vga_resolutions[15],     0, " 320 *  480",              FALCON_REZ, VGA|BPS8,                                   0, 320, 480, 320, 480 },
	{ R &vga_resolutions[16],     0, " 640 *  240",              FALCON_REZ, VERTFLAG|VGA|COL80|BPS8,                    0, 640, 240, 640, 240 },
	{ R NULL,                     0, " 640 *  480",              FALCON_REZ, VGA|COL80|BPS8,                             0, 640, 480, 640, 480 },
	{ R &vga_resolutions[18],     0, " 320 *  240",              FALCON_REZ, VERTFLAG|VGA|BPS16,                         0, 320, 240, 320, 240 },
	{ R NULL,                     0, " 320 *  480",              FALCON_REZ, VGA|BPS16,                                  0, 320, 480, 320, 480 }
};

struct res *vga_res_table[MAX_DEPTHS] = {
	R &vga_resolutions[0],
	R &vga_resolutions[3],
	R &vga_resolutions[8],
	R &vga_resolutions[13],
	R &vga_resolutions[17],
	NULL,
	NULL,
	NULL
};


static struct resbase tv_resolutions[] = {
	{ R &tv_resolutions[1],       0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS1,                              0, 640, 200, 640, 200 },
	{ R &tv_resolutions[2],       0, " 640 *  400, ST Hoch",     FALCON_REZ, VERTFLAG|TV|STMODES|COL80|BPS1,             0, 640, 400, 640, 400 },
	{ R &tv_resolutions[3],       0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS1,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480",              FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS1,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[5],       0, " 320 *  200",              FALCON_REZ, TV|BPS2,                                    0, 320, 200, 320, 200 },
	{ R &tv_resolutions[6],       0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS2,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[7],       0, " 384 *  240",              FALCON_REZ, TV|OVERSCAN|BPS2,                           0, 384, 240, 384, 240 },
	{ R &tv_resolutions[8],       0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS2,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[9],       0, " 640 *  200, ST Mittel",   FALCON_REZ, TV|STMODES|COL80|BPS2,                      0, 640, 200, 640, 200 },
	{ R &tv_resolutions[10],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS2,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[11],      0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS2,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS2,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[13],      0, " 320 *  200, ST Niedrig",  FALCON_REZ, TV|STMODES|BPS4,                            0, 320, 200, 320, 200 },
	{ R &tv_resolutions[14],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS4,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[15],      0, " 384 *  240",              FALCON_REZ, OVERSCAN|BPS4,                              0, 384, 240, 384, 240 },
	{ R &tv_resolutions[16],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS4,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[17],      0, " 640 *  200",              FALCON_REZ, COL80|BPS4,                                 0, 640, 200, 640, 200 },
	{ R &tv_resolutions[18],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS4,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[19],      0, " 768 *  240",              FALCON_REZ, OVERSCAN|COL80|BPS4,                        0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS4,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[21],      0, " 320 *  200",              FALCON_REZ, TV|BPS8,                                    0, 320, 200, 320, 200 },
	{ R &tv_resolutions[22],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS8,                           0, 320, 400, 320, 400 },
	{ R &tv_resolutions[23],      0, " 384 *  240",              FALCON_REZ, TV|OVERSCAN|BPS8,                           0, 384, 240, 384, 240 },
	{ R &tv_resolutions[24],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|BPS8,                  0, 384, 480, 384, 480 },
	{ R &tv_resolutions[25],      0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS8,                              0, 640, 200, 640, 200 },
	{ R &tv_resolutions[26],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS8,                     0, 640, 400, 640, 400 },
	{ R &tv_resolutions[27],      0, " 768 *  240",              FALCON_REZ, TV|OVERSCAN|COL80|BPS8,                     0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|TV|OVERSCAN|COL80|BPS8,            0, 768, 480, 768, 480 },
	{ R &tv_resolutions[29],      0, " 320 *  200",              FALCON_REZ, TV|BPS16,                                   0, 320, 200, 320, 200 },
	{ R &tv_resolutions[30],      0, " 320 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|BPS16,                          0, 320, 400, 320, 400 },
	{ R &tv_resolutions[31],      0, " 384 *  240",              FALCON_REZ, OVERSCAN|TV|BPS16,                          0, 384, 240, 384, 240 },
	{ R &tv_resolutions[32],      0, " 384 *  480, interlaced",  FALCON_REZ, VERTFLAG|OVERSCAN|TV|BPS16,                 0, 384, 480, 384, 480 },
	{ R &tv_resolutions[33],      0, " 640 *  200",              FALCON_REZ, TV|COL80|BPS16,                             0, 640, 200, 640, 200 },
	{ R &tv_resolutions[34],      0, " 640 *  400, interlaced",  FALCON_REZ, VERTFLAG|TV|COL80|BPS16,                    0, 640, 400, 640, 400 },
	{ R &tv_resolutions[35],      0, " 768 *  240",              FALCON_REZ, OVERSCAN|TV|COL80|BPS16,                    0, 768, 240, 768, 240 },
	{   NULL,                     0, " 768 *  480, interlaced",  FALCON_REZ, VERTFLAG|OVERSCAN|TV|COL80|BPS16,           0, 768, 480, 768, 480 }
};

struct res *tv_res_table[MAX_DEPTHS] = {
	R &tv_resolutions[0],
	R &tv_resolutions[4],
	R &tv_resolutions[12],
	R &tv_resolutions[20],
	R &tv_resolutions[28],
	NULL,
	NULL,
	NULL
};


static struct resbase st_high[] = {
	{ NULL,                       0, " 640 *  400, ST Hoch",     FALCON_REZ, STMODES|COL80|BPS1,                         0, 640, 400, 640, 400 }
};

struct res *falc_mono_table[MAX_DEPTHS] = {
	R &st_high[0],
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};


short const et4000_planes[NUM_ET4000] = { 1, 4, 8, 15, 16, 24 };

const char *const et4000_driver_names[NUM_ET4000] = {
	"XVGA2.SYS",
	"XVGA16.SYS",
	"XVGA256.SYS",
	"XVGA32K.SYS",
	"XVGA65K.SYS",
	"XVGA16M.SYS"
};
