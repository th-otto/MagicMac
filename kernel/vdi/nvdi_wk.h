#ifndef NVDI_H
#define NVDI_H

#include <stdint.h>
#include "pixmap.h"

#define MAX_HANDLES 128

typedef struct DRIVER_tag DRIVER;
typedef struct _device_driver DEVICE_DRIVER;


typedef struct _ORGANISATION {
	unsigned long colors;			/* number of simultaneous color */
	short planes;                   /* number of planes */
	short format;                   /* format type (0-2) */
	short flags;                    /* format flags */
	short reserved[3];
} ORGANISATION;

/*	Formatflags: see also NEUE_FKT.TXT/NEW_FUNC.TXT
	bit
	0: normal format (RGB565)
	1: Falcon 32k-format (RGAB5515)
	7: bytes swapped (little endian)
*/


typedef struct _wk WK;

struct _wk {
	/*   0 */ void *disp_addr1;		/* pointer to NVDI-Dispatcher */
	/*   4 */ void *disp_addr2;		/* pointer to Treiber-Dispatcher */
	/*   8 */ short wk_handle;		/* workstation handle */

/* coordinate system */
	/*  10 */ short driver_id;		/* device ID */
	/*  12 */ short pixel_width;	/* width of a pixel in micro meter */
	/*  14 */ short pixel_height;	/* height of a pixel in micro meter */
	/*  16 */ short res_x;			/* raster width -1 */
	/*  18 */ short res_y;			/* raster height -1 */
	/*  20 */ short colors;			/* number of pens -1 */
	/*  22 */ short res_ratio;		/* aspect ratio: <0: vertical shrink ; >0 vertical zoom */
	/*  24 */ char driver_type;     /* driver type (NVDI or GDOS) */
	          char free25;
	/*  26 */ short driver_device;  /* device (screen, printer, metafile or memory) */
	/*  28 */ short free28;

/* driver specific data */
	/*  30 */ char input_mode;      /* modi of input devices */
	          char free31;
	/*  32 */ void *buffer_addr;    /* pointer to tmp buffer */
	/*  36 */ long buffer_len;      /* length of tmp buffer in bytes */
	/*  40 */ long bez_buffer;      /* bezier buffer from v_set_app_buf */
	/*  44 */ long bez_buf_len;     /* length of bezier buffer */

/* arrays for input coordinates */
	/*  48 */ void *gdos_buffer;    /* buffer for gdos driver */

/* clip limits */
	/*  52 */ short clip_xmin;      /* minimum - x */
	/*  54 */ short clip_ymin;      /* minimum - y */
	/*  56 */ short clip_xmax;      /* maximum - x */
	/*  58 */ short clip_ymax;      /* maximum - y */
	/*  60 */ short wr_mode;        /* graphic mode */
	/*  62 */ short bez_on;         /* beziers on? */
	/*  64 */ short bez_qual;       /* bezier quality from 0-5 */
	/*  66 */ short free66;
	/*  68 */ short free68;
	/*  70 */ short l_color;        /* line color */
	/*  72 */ short l_width;        /* line width */
	/*  74 */ short l_start;        /* line start */
	/*  76 */ short l_end;          /* line end */
	/*  78 */ short l_lastpix;      /* 1 = do not set last point */
	/*  80 */ short l_style;        /* line style */
	/*  82 */ short l_styles[6];    /* line patterns */
	/*  94 */ short l_udstyle;      /* user defined style */
	/*  96 */ short free96;
	/*  98 */ short free98;

/* text handling */
	/* 100 */ short t_color;        /* text color */
	/* 102 */ WORD free102;
	/* 104 */ BYTE free104;
	/* 105 */ char t_mapping;	    /* 0: use direct index 1: use t_asc_map */
	/* 106 */ short t_first_ade;    /* code of first character */
	/* 108 */ short t_ades;         /* number of characters -1 */
	/* 110 */ short t_space_index;  /* index for a space (delimiter for v_justified) */
	/* 112 */ short t_unknown_index; /* index for a unknown character */
	/* 114 */ char t_prop;			/* 1: font is proportional */
	/* 115 */ char t_grow;			/* -1: grow +1: shrink (bitmap-fonts only) */
	/* 116 */ short t_no_kern;		/* number of kerning pairs <0: kerning disabled */
	/* 118 */ short t_no_track;		/* number of track kern pairs */
	/* 120 */ short t_hor;			/* horizontal alignment */
	/* 122 */ short t_ver;			/* verical alignment */
	/* 124 */ short t_base;			/* topline<->baseline */
	/* 126 */ short t_half;			/* topline<->halfline */
	/* 128 */ short t_descent;		/* topline<->descent line */
	/* 130 */ short t_bottom;		/* topline<->bottom line */
	/* 132 */ short t_ascent;		/* topline<->ascent line */
	/* 134 */ short t_top;			/* topline<->topline */
	/* 136 */ short free136;
	/* 138 */ short free138;
	/* 140 */ short t_left_off;		/* left offset for italic */
	/* 142 */ short t_whole_off;	/* total widening for italic */
	/* 144 */ short t_thicken;		/* thickening for bold */
	/* 146 */ short t_uline;		/* thickness of underline */
	/* 148 */ short t_ulpos;		/* distance of underline to topline */
	/* 150 */ short t_width;		/* text width */
	/* 152 */ short t_height;		/* text height */
	/* 154 */ short t_cwidth;		/* cell width */
	/* 156 */ short t_cheight;		/* cell height */
	/* 158 */ short t_point_last;	/* last used point size */
	/* 160 */ long t_scale_width;   /* width in 1/65536 pixel (relative) for character generation */
	/* 164 */ long t_scale_height;  /* height in 1/65536 pixel for character generation */
	/* 168 */ short t_rotation;		/* text rotation */
	/* 170 */ short t_skew;			/* counter clockwise, in 1/10 degree */
	/* 172 */ short t_effects;		/* text effects */
	/* 174 */ short t_light_pct;	/* grey value */
	/* 176 */ short *t_light_fill;	/* pointer to grey image for light text */
	/* 180 */ short free180;
	/* 182 */ short free182;
	/* 184 */ short free184;
	/* 186 */ short free186;
	/* 188 */ short free188;

/* pattern handling */
	/* 190 */ short f_color;		/* fill color */
	/* 192 */ short f_interior;		/* fill interior */
	/* 194 */ short f_style;		/* fill style */
	/* 196 */ short f_perimeter;	/* flag for rectangle outline */
	/* 198 */ const short *f_pointer; /* pointer to current fill pattern */
	/* 202 */ short f_planes;		/* number of planes of pattern */
	/* 204 */ const short *f_fill0;
	/* 208 */ const short *f_fill1;
	/* 212 */ const short *f_fill2;
	/* 216 */ const short *f_fill3;
	/* 220 */ const short *f_spointer; /* pointer to user defined fill pattern */
	/* 224 */ short f_splanes;		/* number of planes of user defined pattern */
	/* 226 */ short free226;
	/* 228 */ short free228;

/* marker handling */
	/* 230 */ short m_color;		/* marker color */
	/* 232 */ short m_type;			/* marker type */
	/* 234 */ short m_width;		/* marker width */
	/* 236 */ short m_height;		/* marker height */
	/* 238 */ void *m_data;			/* pointer to marker data */
	/* 242 */ short free242;
	/* 244 */ short free244;
	/* 246 */ short free246;
	/* 248 */ short free248;
	/* 250 */ short t_number;		/* font number */
	/* 252 */ char t_font_type;     /* type of font */
	          char free253;
	/* 254 */ short t_bitmap_gdos;  /* 1: bitmap fonts where embedded using GDOS */
	/* 256 */ void *t_bitmap_fonts; /* pointer to more bitmap fonts */
	/* 260 */ void *t_res_ptr1;     /* reserved */
	/* 264 */ void *t_res_ptr2;     /* reserved */
	/* 268 */ short t_res_xyz1;     /* reserved */

/* pointer for vector fonts */
	/* 270 */ void *t_pointer;		/* pointer to font */
	/* 274 */ void *t_fonthdr;		/* pointer to current font */
	/* 278 */ void *t_offtab;		/* pointer to character offsets */
	/* 282 */ void *t_image;        /* pointer to font data */
	/* 286 */ short t_iwidth;       /* width of font data in bytes */
	/* 288 */ short t_iheight;      /* height of font data in lines */

/* temporary data for bitmap text */
	/* 290 */ short t_eff_thicken;  /* widening from effects */
	/* 292 */ short t_act_line;     /* starting line number in text buffer */
	/* 294 */ short t_add_length;   /* additional length for v_justified */
	/* 296 */ short t_space_kind;   /* -1: per-character spacing */

#define t_FONT_ptr t_pointer		/* pointer to current FONT structure */
#define t_asc_map t_fonthdr         /* pointer to table ascii -> index */
#define t_BAT_ptr t_offtab          /* pointer to attribute table */
#define t_bin_table t_image         /* pointer to fast access map */

	/* 298 */ short free298;

/* dimensions for vector fonts */
	/* 300 */ long t_width32;		/* width in 1/65536 pixel (relative value) */
	/* 304 */ long t_height32;		/* height in 1/65536 pixel */
	/* 308 */ long t_point_width;	/* width in 1/65536 pixel */
	/* 312 */ long t_point_height;  /* height in 1/65536 pixel */
	/* 316 */ short t_track_index;  /* number of track index */
	/* 318 */ long t_track_offset;  /* offset between characters in 1/65536 pixel */
	/* 322 */ long t_left_off32;    /* left offset for italic */
	/* 326 */ long t_whole_off32;   /* total widening for italic */
	/* 330 */ long t_thicken32;     /* thickening for bold */
	          short free334;
	          short free336;
	          short free338;
	/* 340 */ long t_thicken_x;     /* x-part of string width */
	/* 344 */ long t_thicken_y;     /* y-part of string width */
	/* 348 */ long t_char_x;        /* x-part of string width */
	/* 352 */ long t_char_y;        /* y-part of string width */
	/* 356 */ long t_word_x;        /* x-part of string width */
	/* 360 */ long t_word_y;        /* y-part of string width */
	/* 364 */ long t_string_x;      /* x-part of string width */
	/* 368 */ long t_string_y;      /* y-part of string width */
	/* 372 */ long t_last_x;        /* x-part of width of last character*/
	/* 376 */ long t_last_y;        /* y-part of width of last character*/
	/* 380 */ short t_gtext_spacing; /* 1: use character widths as for v_gtext */
	/* 382 */ short t_xadd;
	/* 384 */ short t_yadd;
	/* 386 */ short t_buf_x1;       /* x1 of bitmap in text buffer */
	/* 388 */ short t_buf_x2;       /* x2 of bitmap in text buffer */
	          short free390;
	          short free392;
	          short free394;
	          short free396;
	          short free398;

/* bitmap description */
	/* 400 */ DEVICE_DRIVER *device_drvr;  /* pointer to device driver, or NULL */
	/* 404 */ DRIVER *bitmap_drvr;  /* pointer to offscreen driver */
	          short free408;
	/* 410 */ ORGANISATION bitmap_info;
	          short free426;
	          short free428;
	/* 430 */ void *bitmap_addr;    /* pointer to bitmap */
	/* 434 */ short bitmap_width;   /* bytes per line, or 0 for screen drivers */
	/* 436 */ short r_planes;       /* number of planes -1 */
	/* 438 */ short bitmap_off_x;   /* x-offset for coordinates */
	/* 440 */ short bitmap_off_y;   /* y-offset for coordinates */
	/* 442 */ short bitmap_dx;      /* width of bitmap -1 */
	/* 444 */ short bitmap_dy;      /* height of bitmap -1 */
	/* 446 */ long bitmap_len;      /* length of bitmap in bytes */

/* raster operations */
	/* 450 */ void *r_saddr;        /* src address */
	/* 454 */ short r_swidth;       /* bytes per src line */
	/* 456 */ short r_splanes;      /* no of src planes -1 */
	/* 458 */ long r_splane_len;    /* length of a plane */
#define r_snxtword r_splane_len     /* alternative: distance to next word of same plane */
	          char free462[8];
	/* 470 */ void *r_daddr;        /* destination address */
	/* 474 */ short r_dwidth;       /* bytes per destination line */
	/* 476 */ short r_dplanes;      /* no of dst planes -1 */
	/* 478 */ long r_dplane_len;    /* length of a plane */
#define r_dnxtword r_dplane_len     /* alternative: distance to next word of same plane */
	          char free482[8];
	/* 490 */ short r_fgcol;        /* foreground color */
	/* 492 */ short r_bgcol;        /* background color */
	/* 494 */ short r_wmode;        /* operation mode */
	          long free496;
	/* 500 */ void *p_fbox;         /* vector for filled rectangle */
	/* 504 */ void *p_fline;        /* vector for filled line */
	/* 508 */ void *p_hline;        /* vector for horizontal line */
	/* 512 */ void *p_vline;        /* vector for vertical line */
	/* 516 */ void *p_line;         /* vector for diagonal line */
	/* 520 */ void *p_expblt;       /* vector for expanded bitblk transfer */
	/* 524 */ void *p_bitblt;       /* vector for bitblk transfer */
	/* 528 */ void *p_textblt;      /* vector for text blit */
	/* 532 */ void *p_scanline;     /* vector for scanline (seedfill) */
	/* 536 */ void *p_set_pixel;
	/* 540 */ void *p_get_pixel;
	/* 544 */ void *p_transform;
	/* 548 */ void *p_set_pattern;
	/* 552 */ void *p_set_color_rgb;
	/* 556 */ void *p_get_color_rgb;
	/* 560 */ void *p_vdi_to_color;
	/* 564 */ void *p_color_to_vdi;
	          long free568;
	          long free572;
	          long free576;
	/* 580 */ void *p_gtext;
	/* 584 */ void *p_escapes;
	          long free588;
	          long free592;
	/* 596 */ void *wk_owner;       /* pointer to owning application */
	/* 600 WK_LENGTH */
};

#define FORM_ID_STANDARD    0
#define FORM_ID_PIXPACKED   1
#define FORM_ID_INTERLEAVED 2

/* NVDI-Struktur, der NVDI-Cookie zeigt hierauf */

/* es fehlen noch Funktionen zum
	-	aendern der Cache-Groessen
	-	Scannen des Font-Ordners
	-	Zurueckliefern des Pfads fuer einen Font (ID)
*/

typedef struct {
	/*   0 */ unsigned short version;
	/*   2 */ unsigned long date;
	/*   6 */ unsigned short conf;
	/*   8 */ WK *nvdi_wk;
	/*  12 */ short *fills;
	/*  16 */ WK **wk_tab;
	/*  20 */ char *gdos_path;
	/*  24 */ void *drivers;
	/*  28 */ void *gdos_fonts;
	/*  32 */ void *fonthdr;
	/*  36 */ void *sys_font_info;
	/*  40 */ UBYTE **colmaptab;
	/*  44 */ short *opnwk_work_out;
	/*  48 */ short *extnd_work_out;
	/*  52 */ short no_wks;
	/*  54 */ short max_vdi;
	/*  56 */ short status;
	/*  58 */ short res58;
	/*  60 */ void *vdi_tab;
	/*  64 */ void *linea_tab;
	/*  68 */ void *gemdos_tab;
	/*  72 */ void *bios_tab;
	/*  76 */ void *xbios_tab;
	/*  80 */ void **mouse_tab;
	/*  84 */ short res84;
	/*  86 */ short blitter;
	/*  88 */ short modecode;
	/*  90 */ short xbios_res;
	/*  92 */ short nvdi_cookie_CPU;
	/*  94 */ short nvdi_cpu_type;
	/*  96 */ long nvdi_cookie_VDO;
	/* 100 */ long nvdi_cookie_MCH;
	/* 104 */ short first_device;
	/* 106 */ short cpu020;
	/* 108 */ short magix;
	/* 110 */ short mint;
	/* 112 */ long (*search_cookie)(long name);
	/* 116 */ long (*init_cookie)(long name, long val);
	/* 120 */ void (*reset_cookie)(long name);
	/* 124 */ void (*init_virtual_vbl)(void);
	/* 128 */ void (*reset_virtual_vbl)(void);
	/* 132 */ void *(*Malloc_sys)(long len);
	/* 136 */ void (*Mfree_sys)(void *addr);
	/* 140 */ void *(*nmalloc)(long len);
	/* 144 */ void (*nmfree)(void *addr);
	/* 148 */ void *(*load_file)(const char *name, long *length);
	/* 152 */ void *(*load_prg)(const char *name);
	/* 156 */ DRIVER *(*load_NOD_driver)(ORGANISATION *info);
	/* 160 */ short (*unload_NOD_driver)(DRIVER *drv);
	/* 164 */ short (*init_NOD_drivers)(void);
	/* 168 */ short (*id_to_font_file)(short id, char *file_name);
	/* 172 */ short (*set_FONT_pathes)(short count, long output_vec, char **pathes);
	/* 176 */ short (*get_FONT_path)(WORD index, char *path);
	/* 180 */ short (*set_caches)(long acache, long bcache, long fcache, long kcache, long wcache, long res);
	/* 184 */ void (*get_caches)(long *acache, long *bcache, long *fcache, long *kcache, long *wcache, long *res);
	/* 188 */ short (*get_FIF_path)(char *path);
	/* 192 */ short (*get_INF_name)(char *name);
	/* 196 */ void *vdi_setup_ptr;
	/* 200 */ void (*vdi_exit)(void);
	/* 204 */ long free204[31];
	/* 296 */
} NVDI_STRUCT;

extern NVDI_STRUCT nvdi_struct;
extern WK closed;
extern WK *wk_tab[MAX_HANDLES];

#endif /* NVDI_H */
