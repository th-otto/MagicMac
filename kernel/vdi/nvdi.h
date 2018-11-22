#ifndef NVDI_H
#define NVDI_H

#include <stdint.h>

#define MAX_HANDLES 128

typedef struct _osd OSD;
typedef struct _drv_sys DRV_SYS;


typedef struct
{
	/*  0 */ uint8_t *baseAddr;		/* pointer to pixels */
	/*  4 */ uint16_t rowBytes;		/* offset to next line */
	/* Rect bounds; */		/* encloses bitmap */
	/*  6 */ uint16_t bounds_top;	/* oberste Zeile */
	/*  8 */ uint16_t bounds_left;	/* erste Spalte */
	/* 10 */ uint16_t bounds_bottom;	/* unterste Zeile */
	/* 12 */ uint16_t bounds_right;	/* letzte Spalte */
	/* 14 */ uint16_t pmVersion;	/* pixMap version number */
	/* 16 */ uint16_t packType;		/* defines packing format */
	/* 18 */ uint32_t packSize;		/* length of pixel data */
	/* 22 */ int32_t hRes;			/* horiz. resolution (ppi), in fact of type "Fixed" */
	/* 26 */ int32_t vRes;			/* vert. resolution (ppi), in fact of type "Fixed" */
	/* 30 */ uint16_t pixelType;	/* defines pixel type */
	/* 32 */ uint16_t pixelSize;	/* # bits in pixel */
	/* 34 */ uint16_t cmpCount;		/* # components in pixel */
	/* 36 */ uint16_t cmpSize;		/* # bits per component */
	/* 38 */ uint32_t planeBytes;	/* offset to next plane */
	/* 42 */ uint8_t *pmTable;		/* color map for this pixMap (definiert CtabHandle), in fact of type CTabHandle */
	/* 46 */ uint32_t pmReserved;	/* for future use. MUST BE 0 */
	/* 50 */
} MXVDI_PIXMAP;

struct bitmap_format {
	unsigned long colors;
	short planes;
	short format;
	short flags;
	short res1;
	short res2;
	short res3;
};

typedef struct _vwk VWK;

struct v_unknown {
	/*   0 */ void *unknown1;
	/*   4 */ short unknown3;
	/*   6 */ short unknown4;
	/*   8 */ short device_type;
	/*  10 */ short device_refcount;
	/*  12 */ struct _drv_sys *device_addr;
	/*  16 */ long unknown6;
	/*  20 */ VWK *device_wk;
	/*  22 */ short device_handle;
};

struct _vwk {
	/*   0 */ void *vdi_disp;
	/*   4 */ void *disp_addr;
	/*   8 */ short wk_handle;
	/*  10 */ short v_device_id;
	/*  12 */ short pixel_width;
	/*  14 */ short pixel_height;
	/*  16 */ short res_x;
	/*  18 */ short res_y;
	/*  20 */ short colors;
	/*  22 */ short res_ratio;
	/*  24 */ char driver_type;
	          char pad0;
	/*  26 */ short unknown13;
	/*  28 */ short unknown14;
	/*  30 */ char input_mode;
	          char pad1;
	/*  32 */ void *buffer_a;
	/*  36 */ long buffer_l;
	/*  40 */ long bez_buff;
	/*  44 */ long bez_buf_;
	/*  48 */ short unknown21;
	/*  50 */ short clip_flag;
	/*  52 */ short clip_xmin;
	/*  54 */ short clip_ymin;
	/*  56 */ short clip_xmax;
	/*  58 */ short clip_ymax;
	/*  60 */ short wr_mode;
	/*  62 */ short bez_on;
	/*  64 */ short bez_qual;
	/*  66 */ short unknown24;
	/*  68 */ short unknown25;
	/*  70 */ short l_color;
	/*  72 */ short l_width;
	/*  74 */ short l_start;
	/*  76 */ short l_end;
	/*  78 */ short l_lastpix;
	/*  80 */ short l_style;
	/*  82 */ short l_pattern[6];
	/*  94 */ short l_udstyle;
	/*  96 */ short unknown26;
	/*  98 */ short unknown27;
	/* 100 */ short t_color;
	char res1[3];
	/* 105 */ char t_mapping;
	/* 106 */ short t_first_ade;
	/* 108 */ short t_ades;
	/* 110 */ short t_space_hor;
	/* 112 */ short t_space_ver;
	/* 114 */ char t_prop;
	/* 115 */ char t_grow;
	/* 116 */ short t_no_kern;
	/* 118 */ short t_no_track;
	/* 120 */ short t_hor;
	/* 122 */ short t_ver;
	/* 124 */ short t_base;
	/* 126 */ short t_half;
	/* 128 */ short t_descent;
	/* 130 */ short t_bottom;
	/* 132 */ short t_ascent;
	/* 134 */ short t_top;
	/* 136 */ short unknown28;
	/* 138 */ short unknown29;
	/* 140 */ short t_left_offset;
	/* 142 */ short t_whole_width;
	/* 144 */ short t_thicken;
	/* 146 */ short t_uline;
	/* 148 */ short t_ulpos;
	/* 150 */ short t_width;
	/* 152 */ short t_height;
	/* 154 */ short t_cwidth;
	/* 156 */ short t_cheight;
	/* 158 */ short t_point_size;
	/* 160 */ long t_scale_x;
	/* 164 */ long t_scale_y;
	/* 168 */ short t_rotation;
	/* 170 */ short t_skew;
	/* 172 */ short t_effects;
	/* 174 */ short t_light_0[8];
	/* 190 */ short f_color;
	/* 192 */ short f_interior;
	/* 194 */ short f_style;
	/* 196 */ short f_perimeter;
	/* 198 */ const short *f_pointer;
	/* 202 */ short f_planes;
	/* 204 */ const short *f_fill0;
	/* 208 */ const short *f_fill1;
	/* 212 */ const short *f_fill2;
	/* 216 */ const short *f_fill3;
	/* 220 */ const short *f_spoints;
	/* 224 */ short f_splanes;
	/* 226 */ long v_unknown30;
	/* 230 */ short m_color;
	/* 232 */ short m_type;
	/* 234 */ short m_width;
	/* 236 */ short m_height;
	/* 238 */ void *m_data;
	/* 242 */ char res2[8];
	/* 250 */ short t_number;
	/* 252 */ char t_font_test;
	          char pad2;
	/* 254 */ short t_bitmap_flag;
	/* 256 */ void *t_bitmap_addr;
	/* 260 */ void *t_res_ptx;
	/* 264 */ void *t_res_pty;
	/* 268 */ short t_res_xy;
	/* 270 */ void *t_pointer;
	/* 274 */ void *t_fonthdr;
	/* 278 */ void *t_offtab;
	/* 282 */ void *t_image;
	/* 286 */ short t_iwidth;
	/* 288 */ short t_iheight;
	/* 290 */ short t_eff_theight;
	/* 292 */ short t_act_line;
	/* 294 */ short t_add_len;
	/* 296 */ short t_space_;
	/* 298 */ short v_unknown31;
	/* 300 */ long t_width31;
	/* 304 */ long t_height31;
	/* 308 */ long t_point_1;
	/* 312 */ short t_point_2;
	/* 314 */ short v_unknown40;
	/* 316 */ short t_track_x;
	/* 318 */ long t_track_y;
	/* 322 */ long t_left_off;
	/* 326 */ long t_whole_;
	/* 330 */ short t_thickena[5];
	/* 340 */ long t_thicken1;
	/* 344 */ long t_thicken2;
	/* 348 */ long t_char_x;
	/* 352 */ long t_char_y;
	/* 356 */ long t_word_x;
	/* 360 */ long t_word_y;
	/* 364 */ long t_string1;
	/* 368 */ long t_string2;
	/* 372 */ long t_last_x;
	/* 376 */ long t_last_y;
	/* 380 */ short t_gtext_;
	/* 382 */ short t_xadd;
	/* 384 */ short t_yadd;
	/* 386 */ short t_buf_x1;
	/* 388 */ short t_buf_x2;
	char res3[10];
	/* 400 */ OSD *device_drv;
	/* 404 */ OSD *bitmap_drv;
	short res98;
	/* 410 */ struct bitmap_format v_format;
	char res99[4];
	/* 430 */ void *bitmap_addr;
	/* 434 */ short bitmap_w;
	/* 436 */ short r_planes;
	/* 438 */ short bitmap_off_x;
	/* 440 */ short bitmap_off_y;
	/* 442 */ short bitmap_dx;
	/* 444 */ short bitmap_dy;
	/* 446 */ long bitmap_length;
	/* 450 */ void *r_saddr;
	/* 454 */ short r_swidth;
	/* 456 */ short r_splanes;
	/* 458 */ long r_snxtwork;
	char res100[8];
	/* 470 */ void *r_daddr;
	/* 474 */ short r_dwidth;
	/* 476 */ short r_dplanes;
	/* 478 */ long r_dnxtwork;
	char res101[8];
	/* 490 */ short r_fgcol;
	/* 492 */ short r_bgcol;
	/* 494 */ short r_wmode;
	long res102;
	/* 500 */ void *p_fbox;
	/* 504 */ void *p_fline;
	/* 508 */ void *p_hline;
	/* 512 */ void *p_vline;
	/* 516 */ void *p_line;
	/* 520 */ void *p_expblt;
	/* 524 */ void *p_bitblt;
	/* 528 */ void *p_textblt;
	/* 532 */ void *p_scanline;
	/* 536 */ void *p_set_pixel;
	/* 540 */ void *p_get_pixel;
	/* 544 */ void *p_transform;
	/* 548 */ void *p_set_pattern;
	/* 552 */ void *p_set_color;
	/* 556 */ void *p_get_color;
	/* 560 */ void *p_vdi_to;
	/* 564 */ void *p_color_;
	long res103[3];
	/* 580 */ void *p_gtext;
	/* 584 */ void *p_escape;
	short res104[4];
	/* 596 */ void *wk_owner;
	/* 600 WK_LENGTH */
};

#define FORM_ID_STANDARD    0
#define FORM_ID_PIXPACKED   1
#define FORM_ID_INTERLEAVED 2

typedef struct {
	/*   0 */ unsigned short version;
	/*   2 */ unsigned long date;
	/*   6 */ unsigned short conf;
	/*   8 */ VWK *nvdi_wk;
	/*  12 */ short *fill0;
	/*  16 */ VWK *wk_tab;
	/*  20 */ char *gdos_path;
	/*  24 */ long x1;
	/*  28 */ long x2;
	/*  32 */ void *font_header;
	/*  36 */ void *sys_font;
	/*  40 */ void *color_map;
	/*  44 */ short *work_out;
	/*  48 */ short *extnd_out;
	/*  52 */ short w1;
	/*  54 */ short w2;
	/*  56 */ short w3;
	/*  58 */ short w4;
	/*  60 */ void *vdi_tab;
	/*  64 */ void *linea_tab;
	/*  68 */ void *gem_tab;
	/*  72 */ void **cursor_cnt;
	/*  76 */ long x4;
	/*  80 */ void *mouse_buf;
	/*  84 */ char c1[2];
	/*  86 */ short blitter;
	/*  88 */ short modecode;
	/*  90 */ short resolution;
	/*  92 */ short nvdi_cookie_cpu;
	/*  94 */ short nvdi_cpu_type;
	/*  96 */ long nvdi_cookie_vdo;
	/* 100 */ long nvdi_cookie_mch;
	/* 104 */ short first_de;
	/* 106 */ short cpu020;
	/* 108 */ short magix;
	/* 110 */ short mint;
	/* 112 */ void *search_cookie;
	/* 116 */ void *init_cookie;
	/* 120 */ void *reset_cookie;
	/* 124 */ void *init_virt;
	/* 128 */ void *reset_virt;
	/* 132 */ void *Malloc_sys;
	/* 136 */ void *Mfree_sys;
	/* 140 */ long x5;
	/* 144 */ long x6;
	/* 148 */ void *load_file;
	/* 152 */ void *load_prg;
	/* 156 */ void *load_NOD;
	/* 160 */ void *unload_NOD;
	/* 164 */ void *init_NOD;
	/* 168 */ long x7;
	/* 172 */
} NVDI_STRUCT;

extern NVDI_STRUCT nvdi_struct;
extern VWK closed;
extern VWK *wk_tab[MAX_HANDLES];

#endif /* NVDI_H */
