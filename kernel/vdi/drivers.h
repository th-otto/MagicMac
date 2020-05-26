#ifndef NDRIVERS_H
#define NDRIVERS_H

#define	OFFSCREEN_MAGIC "OFFSCRN"
#define	DEVICE_MAGIC "NVDIDRV"

/* device driver (type) */
#define	N_OFFSCREEN	0
#define	N_SCREEN	1
#define	N_PLOTTER	11
#define	N_PRINTER	21
#define	N_META		31
#define	N_MEMORY	61
#define	N_IMAGE		91

/*
 * header of a *.OSD/*.NOD/*.SYS driver
 */
typedef struct DRVR_tag {
	/*  0 */ unsigned short branch;
	/*  2 */ char magic[8];				/* 'NVDIDRV' or 'OFFSCRN' */
	/* 10 */ short version;				/* driver version; at least 0x290 for *.SYS */
	/* 12 */ unsigned short header_len;	/* length of header */
	/* 14 */ unsigned short type;		/* driver type; 0 for *.OSD, 1 for *.SYS */
	/* 16 */ long (*init)(NVDI_STRUCT *nvdi, DEVICE_DRIVER *drv); /* initialise driver */
	/* 20 */ void (*reset)(NVDI_STRUCT *nvdi, DEVICE_DRIVER *drv); /* release driver */
	/* 24 */ void (*wk_init)(NVDI_STRUCT *nvdi); /* initialise workstation */
	/* 28 */ void (*wk_reset)(NVDI_STRUCT *nvdi); /* release workstation */
	/* 32 */ void (*opnwkinfo)(WORD *intout, WORD *ptsout); /* create output for v_opnwk; change resolution; a6 points to WK */
	/* 36 */ void (*extndinfo)(WORD *intout, WORD *ptsout); /* create output for vq_extnd */
	/* 40 */ void (*scrninfo)(WORD *intout, WORD *ptsout);  /* create output for vq_scrninfo */
	/* 44 */ char *name;                /* driver name; max 128 bytes incl. zero byte */
	/* 48 */ unsigned long offset_hdr;  /* driver specific */
	/* 52 */ long o52;
	/* 56 */ void *res2[2];             /* reserved */
	/* 64 */ ORGANISATION info;         /* description of bitmap format */
	/* 80 */ 
} DRVR_HEADER;

struct DRIVER_tag {
	/*  0 */ DRIVER *next;				/* next element in linked list */
	/*  4 */ DRVR_HEADER *code;			/* pointer to driver header */
	/*  8 */ long wk_len;				/* length of workstation */
	/* 12 */ short used;				/* how many times this driver is used */
	/* 14 */ ORGANISATION info;			/* bitmap organisation */
	/* 30 */ char file_name[16];		/* file name */
	/* 46 */ unsigned long file_size;	/* file size */
	/* 50 */ const char *file_path;		/* path for driver */
	/* 54 */ 
};

/* structure for device drivers */
struct _device_driver {
	/*   0 */ char name[9];				/* filename, without extension */
	/*   9 */ char status;				/* driver type, (GDOS-, ATARI-VDI or NVDI- driver) */
	/*  10 */ short use;				/* how many times this driver is used */
	/*  12 */ DRVR_HEADER *addr;		/* pointer to driver header or NULL */
	/*  16 */ long wk_len;				/* length of workstation for driver */
	/*  20 */ DRIVER *offscreen;		/* pointer to offscreen driver being used */
	/*  24 */ short open_hdl;			/* handle that was used to open the device */
	          short res26;
	          short res28;
	          short res30;
};

DRVR_HEADER *load_prg(const char *filename);
DRIVER *load_NOD(ORGANISATION *format);
int unload_NOD(DRIVER *drv);

/*
 * from mxvdiknl
 */
void clear_cpu_caches(void);
void wk_init(void *p, DRIVER *drv, WK *wk);
void clear_bitmap(WK *wk);
void transform_bitmap(MFDB *src, MFDB *dst, WK *wk);

#endif /* NDRIVERS_H */
