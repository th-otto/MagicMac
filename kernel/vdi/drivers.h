#ifndef NDRIVERS_H
#define NDRIVERS_H

typedef struct _osd OSD;
typedef struct _drv_sys DRV_SYS;

#include "nvdi.h"

/*
 * header of a *.OSD/*.NOD/*.SYS driver
 */
struct _drv_sys {
	/*  0 */ unsigned short branch;
	/*  2 */ char magic[8];    /* 'NVDIDRV' or 'OFFSCRN' */
	/* 10 */ short version;  /* driver version; 3.13 for *.SYS */
	/* 12 */ unsigned short headersize;
	/* 14 */ unsigned short type; /* 0 for *.OSD, 1 for *.SYS */
	/* 16 */ long (*init)(NVDI_STRUCT *nvdi);
	/* 20 */ void *res1;
	/* 24 */ void (*wk_create)(NVDI_STRUCT *nvdi);
	/* 28 */ void (*wk_delete)(NVDI_STRUCT *nvdi);
	/* 32 */ void (*open)(void);
	/* 36 */ void (*ext)(void);
	/* 40 */ void (*scr)(void);
	/* 44 */ char *name;
	/* 48 */ void *res2[4];
	/* 64 */ struct bitmap_format format;
	/* 80 */ 
};

struct _osd {
	/*  0 */ struct _osd *next;
	/*  4 */ DRV_SYS *sys;
	/*  8 */ long wk_size;
	/* 12 */ short refcount;
	/* 14 */ struct bitmap_format format;
	/* 30 */ char fname[16];
	/* 46 */ unsigned long filesize;
	/* 50 */ const char *path;
	/* 54 */ 
};

DRV_SYS *load_prg(const char *filename);
OSD *load_NOD(struct bitmap_format *format);
int unload_NOD(OSD *drv);

/*
 * from mxvdiknl
 */
void clear_cpu_cache(void);
void wk_init(void *p, OSD *drv, VWK *wk);
void clear_bitmap(VWK *wk);
void transform(MFDB *src, MFDB *dst, VWK *wk);

#endif /* NDRIVERS_H */
