	XDEF	OSC_ptr
	XDEF	nvdi_struct
	XDEF	vt_seq_e
	XDEF	vt_seq_f
	XDEF	closed
	XDEF	OSC_count
	XDEF	vdi_entry
	XDEF	wk_tab
	XDEF	clear_cpu_cache
	XDEF	clear_bitmap
	XDEF	vdi_init
	XDEF	vdi_blinit
	XDEF	int_linea
	XDEF	vdi_conout
	XDEF	vdi_cursor
	XDEF	Blitmode
	XDEF	init_mon
	XDEF	wk_init
	XDEF	vdi_rawout
	XDEF	gdos_path
	XDEF	transform
	XDEF	__a_vdi
	XDEF	vt52_init
	XDEF	__e_vdi

	XREF	strgcat
	XREF	strgcpy
	XREF	delete_bitmap
	XREF	load_prg
	XREF	load_ATARI_driver
	XREF	load_MAC_driver
	XREF	load_NOD
	XREF	unload_NOD
	XREF	clear_mem
	XREF	load_file
	XREF	MSys
	XREF	create_bitmap
	XREF	Mfree_sys
	XREF	init_NOD
	XREF	Malloc_sys
	XREF	Mshrink_sys

	XDEF	cpu020
	XREF MSys_BehneError
	
/* version info for ndvi_struct */
VERSION equ $0313
YEAR    equ $1998
DAY		equ $06
MONTH	equ $02

MAX_HANDLES equ 128
MAX_PTS equ 1024
NVDI_BUFSIZE equ $4000

/* system variables */
etv_timer equ $0400
p_cookie  equ $05a0
timer_ms  equ $0442
sshiftmd  equ $044c
v_bas_ad  equ $044e
vbl_queue equ $0456
conterm   equ $0484
con_stat  equ $04a8
sysbase   equ $04f2
bell_hook equ $05ac


/* DRV */
		OFFSET 0
DRVR_branch:      ds.w 1
DRVR_magic:       ds.b 8
DRVR_version:     ds.w 1
DRVR_headersize:  ds.w 1
DRVR_type:        ds.w 1
DRVR_init:        ds.l 1
DRVR_exit:        ds.l 1
DRVR_wk_create:   ds.l 1
DRVR_wk_delete:   ds.l 1
DRVR_open:        ds.l 1
DRVR_ext:         ds.l 1
DRVR_scr:         ds.l 1
DRVR_name:        ds.l 1
DRVR_res2:        ds.l 4
DRVR_colors:      ds.l 1
DRVR_planes:      ds.w 1
DRVR_format:      ds.w 1
DRVR_flags:       ds.w 1
DRVR_res3:        ds.w 3

/* OSD */
		OFFSET 0
driver_next:      ds.l 1
DRIVER_A:         ds.l 1
driver_wk_size:   ds.l 1
driver_refcount:  ds.w 1
driver_format:    ds.w 8
driver_fname:     ds.b 16
driver_fsize:     ds.l 1
driver_path:      ds.l 1


/* VDIPB */
		OFFSET 0
pb_control: ds.l 1
pb_intin:   ds.l 1
pb_ptsin:   ds.l 1
pb_intout:  ds.l 1
pb_ptsout:  ds.l 1


/* VDI control */
		OFFSET 0
opcode:   ds.w 1
n_ptsin:  ds.w 1
n_ptsout: ds.w 1
n_intin:  ds.w 1
n_intout: ds.w 1
opcode2:  ds.w 1
handle:   ds.w 1
s_addr:   ds.l 1
d_addr:   ds.l 1


/* PH */
		OFFSET 0
PH_MAGIC:   ds.w 1
ph_tlen:    ds.l 1
ph_dlen:    ds.l 1
ph_blen:    ds.l 1
ph_slen:    ds.l 1
ph_res1:    ds.l 1
ph_prgflgs: ds.l 1
ph_flag:    ds.w 1
PH_LEN:

/* BASEPAGE */
		OFFSET 0
p_lowtpa:  ds.l 1
p_hitpa:   ds.l 1
p_tbase:   ds.l 1
p_tlen:    ds.l 1
p_dbase:   ds.l 1
p_dlen:    ds.l 1
p_bbase:   ds.l 1
p_blen:    ds.l 1
p_dta:     ds.l 1
p_parent:  ds.l 1
p_flags:   ds.l 1
p_env:     ds.l 1
p_devx:    ds.b 6
p_resrvd1: ds.b 1
p_defdrv:  ds.b 1
p_undef:   ds.l 17
p_usp:     ds.l 1
p_cmdlin:  ds.b 128

/* fonthdr */
		OFFSET 0
font_id:        ds.w 1   /*  0 */
point:          ds.w 1   /*  2 */
name:           ds.b 32  /*  4 */
first_ade:      ds.w 1   /* 36 */
last_ade:       ds.w 1   /* 38 */
top:            ds.w 1   /* 40 */
ascent:         ds.w 1   /* 42 */
half:           ds.w 1   /* 44 */
descent:        ds.w 1   /* 46 */
bottom:         ds.w 1   /* 48 */
max_char_width: ds.w 1   /* 50 */
max_cell_width: ds.w 1   /* 52 */
left_offset:    ds.w 1   /* 54 */
right_offset:   ds.w 1   /* 56 */
thicken:        ds.w 1   /* 58 */
ul_size:        ds.w 1   /* 60 */
lighten:        ds.w 1   /* 62 */
skew:           ds.w 1   /* 64 */
flags:          ds.w 1   /* 66 */
hor_table:      ds.l 1   /* 68 */
off_table:      ds.l 1   /* 72 */
dat_table:      ds.l 1   /* 76 */
form_width:     ds.w 1   /* 80 */
form_height:    ds.w 1   /* 82 */
next_font:      ds.l 1   /* 84 */
sizeof_FONTHDR:          /* 88 */


/* MFDB */
		OFFSET 0
fd_addr:    ds.l 1
fd_w:       ds.w 1
fd_h:       ds.w 1
fd_wdwidth: ds.w 1
fd_stand:   ds.w 1
fd_nplanes: ds.w 1
fd_r1:      ds.w 1
fd_r2:      ds.w 1
fd_r3:      ds.w 1
MFDB_SIZE:


/* screen driver */
		OFFSET 0
		ds.w 4
device_type:     ds.w 1
device_refcount: ds.w 1
device_addr:     ds.l 1
                 ds.l 1
device_wk:       ds.l 1
device_handle:   ds.w 1


/* VWK */
		OFFSET 0
vdi_disp:      ds.l 1
disp_addr:     ds.l 1
wk_handle:     ds.w 1
v_device_id:   ds.w 1
pixel_width:   ds.w 1
pixel_height:  ds.w 1
res_x:         ds.w 1
res_y:         ds.w 1
colors:        ds.w 1
res_ratio:     ds.w 1
driver_type:   ds.b 1
               ds.b 1
               ds.w 1
               ds.w 1
input_mode:    ds.b 1
               ds.b 1
buffer_a:      ds.l 1
buffer_l:      ds.l 1
bez_buff:      ds.l 1
bez_buf_:      ds.l 1
               ds.w 1
clip_flag:     ds.w 1
clip_xmin:     ds.w 1
clip_ymin:     ds.w 1
clip_xmax:     ds.w 1
clip_ymax:     ds.w 1
wr_mode:       ds.w 1
bez_on:        ds.w 1
bez_qual:      ds.w 1
               ds.w 1
               ds.w 1
l_color:       ds.w 1
l_width:       ds.w 1
l_start:       ds.w 1
l_end:         ds.w 1
l_lastpix:     ds.w 1
l_style:       ds.w 1
l_pattern:     ds.w 6
l_udstyle:     ds.w 1
               ds.w 1
               ds.w 1
t_color:       ds.w 1
               ds.b 3
t_mapping:     ds.b 1
t_first_ade:   ds.w 1
t_ades:        ds.w 1
t_space_hor:   ds.w 1
t_space_ver:   ds.w 1
t_prop:        ds.b 1
t_grow:        ds.b 1
t_no_kern:     ds.w 1
t_no_track:    ds.w 1
t_hor:         ds.w 1
t_ver:         ds.w 1
t_base:        ds.w 1
t_half:        ds.w 1
t_descent:     ds.w 1
t_bottom:      ds.w 1
t_ascent:      ds.w 1
t_top:         ds.w 1
               ds.w 1
               ds.w 1
t_left_offset: ds.w 1
t_whole_width: ds.w 1
t_thicken:     ds.w 1
t_uline:       ds.w 1
t_ulpos:       ds.w 1
t_width:       ds.w 1
t_height:      ds.w 1
t_cwidth:      ds.w 1
t_cheight:     ds.w 1
t_point_size:  ds.w 1
t_scale_x:     ds.l 1
t_scale_y:     ds.l 1
t_rotation:    ds.w 1
t_skew:        ds.w 1
t_effects:     ds.w 1
t_light_0:     ds.w 8
f_color:       ds.w 1
f_interior:    ds.w 1
f_style:       ds.w 1
f_perimeter:   ds.w 1
f_pointer:     ds.l 1
f_planes:      ds.w 1
f_fill0:       ds.l 1
f_fill1:       ds.l 1
f_fill2:       ds.l 1
f_fill3:       ds.l 1
f_spoints:     ds.l 1
f_splanes:     ds.w 1
               ds.l 1
m_color:       ds.w 1
m_type:        ds.w 1
m_width:       ds.w 1
m_height:      ds.w 1
m_data:        ds.l 1
               ds.b 8
t_number:      ds.w 1
t_font_test:   ds.w 1
t_bitmap_flag: ds.w 1
t_bitmap_addr: ds.l 1
t_res_ptx:     ds.l 1
t_res_pty:     ds.l 1
t_res_xy:      ds.w 1
t_pointer:     ds.l 1
t_fonthdr:     ds.l 1
t_offtab:      ds.l 1
t_image:       ds.l 1
t_iwidth:      ds.w 1
t_iheight:     ds.w 1
t_eff_theight: ds.w 1
t_act_line:    ds.w 1
t_add_len:     ds.w 1
t_space_:      ds.w 1
               ds.w 1
t_width31:     ds.l 1
t_height31:    ds.l 1
t_point_x:     ds.l 1
t_point_2:     ds.w 1
               ds.w 1
t_track_x:     ds.w 1
t_track_y:     ds.l 1
t_left_off:    ds.l 1
t_whole_:      ds.l 1
t_thickena:    ds.w 5
t_thicken1:    ds.l 1
t_thicken2:    ds.l 1
t_char_x:      ds.l 1
t_char_y:      ds.l 1
t_word_x:      ds.l 1
t_word_y:      ds.l 1
t_string1:     ds.l 1
t_string2:     ds.l 1
t_last_x:      ds.l 1
t_last_y:      ds.l 1
t_gtext_:      ds.w 1
t_xadd:        ds.w 1
t_yadd:        ds.w 1
t_buf_x1:      ds.w 1
t_buf_x2:      ds.w 1
               ds.b 10
device_drv:    ds.l 1
bitmap_drv:    ds.l 1
               ds.w 1
bitmap_colors: ds.l 1
bitmap_planes: ds.w 1
bitmap_format: ds.w 1
bitmap_flags:  ds.w 1
bitmap_res1:   ds.w 1
bitmap_res2:   ds.w 1
bitmap_res3:   ds.w 1
               ds.b 4
bitmap_addr:   ds.l 1
bitmap_w:      ds.w 1
r_planes:      ds.w 1
bitmap_off_x:  ds.w 1
bitmap_off_y:  ds.w 1
bitmap_dx:     ds.w 1
bitmap_dy:     ds.w 1
bitmap_length: ds.l 1
r_saddr:       ds.l 1
r_swidth:      ds.w 1
r_splanes:     ds.w 1
r_snxtwork:    ds.l 1
               ds.b 8
r_daddr:       ds.l 1
r_dwidth:      ds.w 1
r_dplanes:     ds.w 1
r_dnxtwork:    ds.l 1
               ds.b 8
r_fgcol:       ds.w 1
r_bgcol:       ds.w 1
r_wmode:       ds.w 1
               ds.l 1
p_fbox:        ds.l 1
p_fline:       ds.l 1
p_hline:       ds.l 1
p_vline:       ds.l 1
p_line:        ds.l 1
p_expblt:      ds.l 1
p_bitblt:      ds.l 1
p_textblit:    ds.l 1
p_scanline:    ds.l 1
p_set_pixel:   ds.l 1
p_get_pixel:   ds.l 1
p_transform:   ds.l 1
p_set_pattern: ds.l 1
p_set_color:   ds.l 1
p_get_color:   ds.l 1
p_vdi_to:      ds.l 1
p_color_:      ds.l 1
               ds.l 3
p_gtext:       ds.l 1
p_escape:      ds.l 1
               ds.w 4
wk_owner:      ds.l 1
WK_LENGTH:

WK_SIZE equ WK_LENGTH+(2*MAX_PTS)



/* MXVDI_PIXMAP */
		OFFSET 0
PM_baseAddr:   ds.l 1
PM_rowBytes:   ds.w 1
PM_bounds:     ds.w 4
PM_pmVersion:  ds.w 1
PM_packType:   ds.w 1
PM_packSize:   ds.l 1
PM_hRes:       ds.l 1
PM_vRes:       ds.l 1
PM_pixelType:  ds.w 1
PM_pixelSize:  ds.w 1
PM_cmpCount:   ds.w 1
PM_cmpSize:    ds.w 1
PM_planeBytes: ds.l 1
PM_pmTable:    ds.l 1
PM_pmReserved: ds.l 1



/* VDI variables */
__a_vdi equ $1200
		OFFSET __a_vdi
tmp_buff:
ptsin:         ds.w 256
intin:         ds.w 12
intout:        ds.w 12
ptsout:        ds.w 24
control:       ds.w 12
vdipb:         ds.l 5
font_header:   ds.b sizeof_FONTHDR*4
atxt_off:      ds.l 1
old_etv_timer: ds.l 1
key_stat:      ds.l 1
nvdi_pool:     ds.b 128
scrtchp:       ds.l 1
system_b:      ds.w 1
gdos_path:     ds.b 128
screen_d:      ds.b 32
vt52_fal:      ds.w 4
OSC_ptr:       ds.l 1
OSC_count:     ds.w 1
mono_DRV:      ds.l 1
mono_bitmap:   ds.l 1
mono_expblt:   ds.l 1
wk_tab0:       ds.l 1
wk_tab:        ds.l MAX_HANDLES
linea_wk:      ds.l 1
aes_wk_p:      ds.l 1
               ds.l 1
cursor_cnt:    ds.l 1
cursor_vbl:    ds.l 1
vt52_vec:      ds.l 1
con_vec:       ds.l 1
rawcon_vec:    ds.l 1
color_map:     ds.l 1
color_rev:     ds.l 1
mouse_buf:     ds.l 1
draw_spr:      ds.l 1
undraw_spr:    ds.l 1
call_old:      ds.l 2
call_old2:     ds.l 2
nvdi_struct:
               ds.w 1 ; _nvdi_version
               ds.l 1 ; _nvdi_date
               ds.w 1 ; _nvdi_conf
nvdi_aes_wk:   ds.l 1 ; _nvdi_aes_wk
               ds.l 1 ; _nvdi_fill0
               ds.l 1 ; _nvdi_wk_tab
               ds.l 1 ; _nvdi_path
               ds.l 1 ; _nvdi_drv
               ds.l 1 ; _nvdi_font
               ds.l 1 ; _nvdi_font_header
               ds.l 1 ; _nvdi_sys_font
               ds.l 1 ; _nvdi_color_map
               ds.l 1 ; _nvdi_work_out
               ds.l 1 ; _nvdi_extnd_out
               ds.w 1 ; _nvdi_no
               ds.w 1 ; _nvdi_ma
               ds.w 1 ; _nvdi_sta
               ds.w 1 ; _nvdi_vd
               ds.l 1 ; _nvdi_vdi_tab
               ds.l 1 ; _nvdi_linea_tab
               ds.l 1 ; _nvdi_gem_tab
               ds.l 1 ; cursor_cnt/_nvdi_bios
               ds.l 1 ; _nvdi_xbios
               ds.l 1 ; _nvdi_mouse_buf
               ds.w 1
blitter:       ds.w 1 ; _nvdi_blitter
modecode:      ds.w 1 ; _nvdi_modecode
resolution:    ds.w 1 ; _nvdi_xb
nvdi_cookie_cpu: ds.w 1 ; _nvdi_cookie_cpu
nvdi_cpu_type: ds.w 1 ; _nvdi_cookie_cpu
nvdi_cookie_vdo: ds.l 1 ; _nvdi_cookie_vdo
nvdi_cookie_mch: ds.l 1 ; _nvdi_cookie_mch
first_de:      ds.w 1 ; _nvdi_first_de
cpu020:        ds.w 1 ; _nvdi_cpu020
               ds.w 1 ; _nvdi_magix
               ds.w 1 ; _nvdi_mint
               ds.l 1 ; _nvdi_search_cookie
               ds.l 1 ; _nvdi_init_cookie
               ds.l 1 ; _nvdi_reset_cookie
               ds.l 1 ; _nvdi_init_virt
               ds.l 1 ; _nvdi_reset_virt
               ds.l 1 ; _nvdi_Malloc_sys
               ds.l 1 ; _nvdi_Mfree_sys
               ds.l 1 ; _nvdi_nmalloc
               ds.l 1 ; _nvdi_nmfree
               ds.l 1 ; _nvdi_load_file
               ds.l 1 ; _nvdi_load_prg
               ds.l 1 ; _nvdi_load_NOD
               ds.l 1 ; _nvdi_unload_NOD
               ds.l 1 ; _nvdi_init_NOD
               ds.l 1 ; _nvdi_id_to_
n_set_FO:      ds.l 1 ; _nvdi_set_FO
n_get_FO:      ds.l 1 ; _nvdi_get_FO
n_set_ca:      ds.l 1 ; _nvdi_set_ca
n_get_ca:      ds.l 1 ; _nvdi_get_ca
n_get_FI:      ds.l 1 ; _nvdi_get_FI
n_get_IN:      ds.l 1 ; _nvdi_get_IN
nvdi_struct_end:

PixMap_ptr:    ds.l 1

               ds.b 670

/* Line-A variables */
               xdef CUR_FONT
CUR_FONT:      ds.l 1      /* (lineavars-$38a) */	/* long */
               ds.w 23     /*   (lineavars-$386) */ /* 23 reserved words */
               xdef M_POS_HX
M_POS_HX:      ds.w 1      /* (lineavars-$358) */	/* word */
               xdef M_POS_HY
M_POS_HY:      ds.w 1      /* (lineavars-$356) */	/* word */
               xdef M_PLANES
M_PLANES:      ds.w 1      /* (lineavars-$354) */	/* word */
               xdef M_CDB_BG
M_CDB_BG:      ds.w 1      /* (lineavars-$352) */	/* word */
               xdef M_CDB_FG
M_CDB_FG:      ds.w 1      /* (lineavars-$350) */	/* word */
               xdef MASK_FORM
MASK_FORM:     ds.w 32     /* (lineavars-$34e) */	/* 32 words */
               xdef INQ_TAB
INQ_TAB:       ds.w 45     /* (lineavars-$30e) */	/* 45 words */
               xdef DEV_TAB
DEV_TAB:       ds.w 45     /* (lineavars-$2b4) */	/* 45 words */
               xdef GCURX
GCURX:         ds.w 1      /* (lineavars-$25a) */	/* word */
               xdef GCURY
GCURY:         ds.w 1      /* (lineavars-$258) */	/* word */
               xdef M_HID_CNT
M_HID_CNT:     ds.w 1      /* (lineavars-$256) */	/* word */
               xdef MOUSE_BT
MOUSE_BT:      ds.w 1      /* (lineavars-$254) */	/* word */
               xdef REQ_COL
REQ_COL:       ds.w 16*3   /* (lineavars-$252) */	/* 16 * 3 words */
               xdef SIZ_TAB
SIZ_TAB:       ds.w 15     /* (lineavars-$1F2) */	/* 15 words */
               xdef TERM_CH
TERM_CH:       ds.w 1      /* (lineavars-$1d4) */	/* word */
               xdef CHC_MOD
CHC_MOD:       ds.w 1      /* (lineavars-$1d2) */	/* word */
               xdef CUR_WORK
CUR_WORK:      ds.l 1      /* (lineavars-$1d0) */	/* long */
               xdef DEF_FONT
DEF_FONT:      ds.l 1      /* (lineavars-$1cc) */	/* long */
               xdef FONT_RING
FONT_RING:     ds.l 4      /* (lineavars-$1c8) */	/* 4 longs */
               xdef FONT_COUNT
FONT_COUNT:    ds.w 1      /* (lineavars-$1b8) */	/* word */
               xdef LINE_CW
LINE_CW:       ds.w 1      /* (lineavars-$1b6) */	/* word */
               xdef LOC_MODE
LOC_MODE:      ds.w 1      /* (lineavars-$1b4) */	/* word */
               xdef NUM_QC_LIN
NUM_QC_LIN:    ds.w 1      /* (lineavars-$1b2) */	/* word */
               xdef TRAP14SAV
TRAP14SAV:     ds.l 1      /* (lineavars-$1b0) */	/* long */
               xdef COL_OR_MASK
COL_OR_MASK:   ds.l 1      /* (lineavars-$1ac) */	/* long */
               xdef COL_AND_MASK
COL_AND_MASK:  ds.l 1      /* (lineavars-$1a8) */	/* long */
               xdef TRAP14BSAV
TRAP14BSAV:    ds.l 1      /* (lineavars-$1a4) */	/* long */
               ds.w 32       /*   (lineavars-$1a2)    32 reserved words */
               xdef STR_MODE
STR_MODE:      ds.w 1      /* (lineavars-$160) */	/* word */
               xdef VAL_MODE
VAL_MODE:      ds.w 1      /* (lineavars-$15e) */	/* word */
               xdef CUR_MS_STAT
CUR_MS_STAT:   ds.b 1      /* (lineavars-$15c) */	/* byte */
               ds.b 1                           /* padding */
               xdef V_HID_CNT
V_HID_CNT:     ds.w 1      /* (lineavars-$15a) */	/* word */
               xdef CUR_X
CUR_X:         ds.w 1      /* (lineavars-$158) */	/* word */
               xdef CUR_Y
CUR_Y:         ds.w 1      /* (lineavars-$156) */	/* word */
               xdef CUR_FLAG
CUR_FLAG:      ds.b 1      /* (lineavars-$154) */	/* byte */
               xdef MOUSE_FLAG
MOUSE_FLAG:    ds.b 1      /* (lineavars-$153) */	/* byte */
               xdef RETSAV
RETSAV:        ds.l 1      /* (lineavars-$14e) */	/* long */
               xdef SAV_CURX
V_SAV_XY:      ds.w 2      /* (lineavars-$152) */	/* word */ ; BUG: swapped with RETSAV
               xdef SAVE_LEN
SAVE_LEN:      ds.w 1      /* (lineavars-$14a) */	/* word */
               xdef SAVE_ADDR
SAVE_ADDR:     ds.l 1      /* (lineavars-$148) */	/* long */
               xdef SAVE_STAT
SAVE_STAT:     ds.w 1      /* (lineavars-$144) */	/* word */
               xdef SAVE_AREA
SAVE_AREA:     ds.l 64     /* (lineavars-$142) */	/* 64 longs */
               xdef USER_TIM
USER_TIM:      ds.l 1      /* (lineavars-$042) */	/* long */
               xdef NEXT_TIM
NEXT_TIM:      ds.l 1      /* (lineavars-$03e) */	/* long */
               xdef USER_BUT
USER_BUT:      ds.l 1      /* (lineavars-$03a) */	/* long */
               xdef USER_CUR
USER_CUR:      ds.l 1      /* (lineavars-$036) */	/* long */
               xdef USER_MOT
USER_MOT:      ds.l 1      /* (lineavars-$032) */	/* long */
               xdef V_CEL_HT
V_CEL_HT:      ds.w 1      /* (lineavars-$02e) */	/* word */
               xdef V_CEL_MX
V_CEL_MX:      ds.w 1      /* (lineavars-$02c) */	/* word */
               xdef V_CEL_MY
V_CEL_MY:      ds.w 1      /* (lineavars-$02a) */	/* word */
               xdef V_CEL_WR
V_CEL_WR:      ds.w 1      /* (lineavars-$028) */	/* word */
               xdef V_COL_BG
V_COL_BG:      ds.w 1      /* (lineavars-$026) */	/* word */
               xdef V_COL_FG
V_COL_FG:      ds.w 1      /* (lineavars-$024) */	/* word */
               xdef V_CUR_AD
V_CUR_AD:      ds.l 1      /* (lineavars-$022) */	/* long */
               xdef V_CUR_OF
V_CUR_OF:      ds.w 1      /* (lineavars-$01e) */	/* word */
               xdef V_CUR_XY
V_CUR_XY:      ds.w 2      /* (lineavars-$01c) */	/* 2 words X,Y */
               xdef V_PERIOD
V_PERIOD:      ds.b 1      /* (lineavars-$018) */	/* byte */
               xdef V_CUR_CT
V_CUR_CT:      ds.b 1      /* (lineavars-$017) */	/* byte */
               xdef V_FNT_AD
V_FNT_AD:      ds.l 1      /* (lineavars-$016) */	/* long */
               xdef V_FNT_ND
V_FNT_ND:      ds.w 1      /* (lineavars-$012) */	/* word */
               xdef V_FNT_ST
V_FNT_ST:      ds.w 1      /* (lineavars-$010) */	/* word */
               xdef V_FNT_WD
V_FNT_WD:      ds.w 1      /* (lineavars-$00e) */	/* word */
               xdef V_REZ_HZ
V_REZ_HZ:      ds.w 1      /* (lineavars-$00c) */	/* word */
               xdef V_OFF_AD
V_OFF_AD:      ds.l 1      /* (lineavars-$00a) */	/* long */
               xdef V_STAT_0
V_STAT_0:      ds.b 1      /* (lineavars-$006) */	/* byte */
               xdef V_DELAY
V_DELAY:       ds.b 1      /* (lineavars-$005) */	/* byte */
               xdef V_REZ_VT
V_REZ_VT:      ds.w 1      /* (lineavars-$004) */	/* word */
               xdef BYTES_LINE
BYTES_LINE:    ds.w 1      /* (lineavars-$002) */	/* word */
/* Line-A variables */

LINE_A_BASE:
               xdef PLANES
PLANES:        ds.w 1      /* (lineavars+$000) */	/* word */
               xdef WIDTH
WIDTH:         ds.w 1      /* (lineavars+$002) */	/* word */
               xdef CONTRL
CONTRL:        ds.l 1      /* (lineavars+$004) */	/* long */
               xdef INTIN
INTIN:         ds.l 1      /* (lineavars+$008) */	/* long */
               xdef PTSIN
PTSIN:         ds.l 1      /* (lineavars+$00c) */	/* long */
               xdef INTOUT
INTOUT:        ds.l 1      /* (lineavars+$010) */	/* long */
               xdef PTSOUT
PTSOUT:        ds.l 1      /* (lineavars+$014) */	/* long */
               xdef COLBIT0
COLBIT0:       ds.w 1      /* (lineavars+$018) */	/* word */
               xdef COLBIT1
COLBIT1:       ds.w 1      /* (lineavars+$01a) */	/* word */
               xdef COLBIT2
COLBIT2:       ds.w 1      /* (lineavars+$01c) */	/* word */
               xdef COLBIT3
COLBIT3:       ds.w 1      /* (lineavars+$01e) */	/* word */
               xdef LSTLIN
LSTLIN:        ds.w 1      /* (lineavars+$020) */	/* word */
               xdef LNMASK
LNMASK:        ds.w 1      /* (lineavars+$022) */	/* word */
               xdef WMODE
WMODE:         ds.w 1      /* (lineavars+$024) */	/* word */
               xdef X1
X1:            ds.w 1      /* (lineavars+$026) */	/* word */
               xdef Y1
Y1:            ds.w 1      /* (lineavars+$028) */	/* word */
               xdef X2
X2:            ds.w 1      /* (lineavars+$02a) */	/* word */
               xdef Y2
Y2:            ds.w 1      /* (lineavars+$02c) */	/* word */
               xdef PATPTR
PATPTR:        ds.l 1      /* (lineavars+$02e) */	/* long */
               xdef PATMSK
PATMSK:        ds.w 1      /* (lineavars+$032) */	/* word */
               xdef MFILL
MFILL:         ds.w 1      /* (lineavars+$034) */	/* word */
               xdef CLIP
CLIP:          ds.w 1      /* (lineavars+$036) */	/* word */
               xdef XMINCL
XMINCL:        ds.w 1      /* (lineavars+$038) */	/* word */
               xdef YMINCL
YMINCL:        ds.w 1      /* (lineavars+$03a) */	/* word */
               xdef XMAXCL
XMAXCL:        ds.w 1      /* (lineavars+$03c) */	/* word */
               xdef YMAXCL
YMAXCL:        ds.w 1      /* (lineavars+$03e) */	/* word */
               xdef XDDA
XDDA:          ds.w 1      /* (lineavars+$040) */	/* word */
               xdef DDAINC
DDAINC:        ds.w 1      /* (lineavars+$042) */	/* word */
               xdef SCALDIR
SCALDIR:       ds.w 1      /* (lineavars+$044) */	/* word */
               xdef MONO
MONO:          ds.w 1      /* (lineavars+$046) */	/* word */
               xdef SOURCEX
SOURCEX:       ds.w 1      /* (lineavars+$048) */	/* word */
               xdef SOURCEY
SOURCEY:       ds.w 1      /* (lineavars+$04a) */	/* word */
               xdef DESTX
DESTX:         ds.w 1      /* (lineavars+$04c) */	/* word */
               xdef DESTY
DESTY:         ds.w 1      /* (lineavars+$04e) */	/* word */
               xdef DELX
DELX:          ds.w 1      /* (lineavars+$050) */	/* word */
               xdef DELY
DELY:          ds.w 1      /* (lineavars+$052) */	/* word */
               xdef FBASE
FBASE:         ds.l 1      /* (lineavars+$054) */	/* long */
               xdef FWIDTH
FWIDTH:        ds.w 1      /* (lineavars+$058) */	/* word */
               xdef STYLE
STYLE:         ds.w 1      /* (lineavars+$05a) */	/* word */
               xdef LITEMASK
LITEMASK:      ds.w 1      /* (lineavars+$05c) */	/* word */
               xdef SKEWMASK
SKEWMASK:      ds.w 1      /* (lineavars+$05e) */	/* word */
               xdef WEIGHT
WEIGHT:        ds.w 1      /* (lineavars+$060) */	/* word */
               xdef ROFF
ROFF:          ds.w 1      /* (lineavars+$062) */	/* word */
               xdef LOFF
LOFF:          ds.w 1      /* (lineavars+$064) */	/* word */
               xdef SCALE
SCALE:         ds.w 1      /* (lineavars+$066) */	/* word */
               xdef CHUP
CHUP:          ds.w 1      /* (lineavars+$068) */	/* word */
               xdef TEXTFG
TEXTFG:        ds.w 1      /* (lineavars+$06a) */	/* word */
               xdef SCRTCHP
SCRTCHP:       ds.l 1      /* (lineavars+$06c) */	/* long */
               xdef SCRPT2
SCRPT2:        ds.w 1      /* (lineavars+$070) */	/* word */
               xdef TEXTBG
TEXTBG:        ds.w 1      /* (lineavars+$072) */	/* word */
               xdef COPYTRAN
COPYTRAN:      ds.w 1      /* (lineavars+$074) */	/* word */
               xdef SEEDABORT
SEEDABORT:     ds.l 1      /* (lineavars+$076) */	/* long */
               ds.b 52  /* device dep. function ptr in TOS */
               xdef REQ_COL_X
REQ_COL_X:     ds.w 240*3  /* (lineavars+$0ae) */	/* 240*3 words */
               xdef SSB_ADDR
SSB_ADDR:      ds.l 1      /* (lineavars+$64e) */	/* long */
               xdef LINEA_COLPLANES
LINEA_COLPLANES: ds.l 1    /* (lineavars+$652) */	/* long */
               xdef COLBIT4
COLBIT4:       ds.w 1      /* (lineavars+$656) */	/* word */
               xdef COLBIT5
COLBIT5:       ds.w 1      /* (lineavars+$658) */	/* word */
               xdef COLBIT6
COLBIT6:       ds.w 1      /* (lineavars+$65a) */	/* word */
               xdef COLBIT7
COLBIT7:       ds.w 1      /* (lineavars+$65c) */	/* word */
               xdef SAVLEN
SAVLEN:        ds.w 1      /* (lineavars+$65e) */	/* word */
               xdef SAVADDR
SAVADDR:       ds.l 1      /* (lineavars+$660) */	/* long */
               xdef SAVSTAT
SAVSTAT:       ds.w 1      /* (lineavars+$664) */	/* word */
               xdef SAVAREA
SAVAREA:       ds.w 256    /* (lineavars+$666) */

               xdef __e_vdi
__e_vdi:



	TEXT
	
sys_font:
		   dc.w  3
		   dc.l font_header
	       dc.l dat_table_10
sf_image:
           dc.l 0
sfb_image:
           dc.l 0
linea_fonts:
	dc.l	header_08
	dc.l	header_09
	dc.l	header_10
	dc.l	0
	dc.l	0
header_08:
	dc.w 1
	dc.w 8
	dc.b	'6x6 system font',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,255 ; first_ade,last_ade
	dc.w	4,4,3,1,1 ; top,ascent,half,descent,bottom
	dc.w	5,6 ; char_width,,cell_width
	dc.w	0,3 ; left_offset,right_offset
	dc.w	1,1 ; thicken,ul_size
	dc.w	$5555 ; lighten
	dc.w	$aaaa ; skew
	dc.w	$000c ; flags
	dc.l    0
	dc.l	off_table_08
	dc.l	dat_table_08
	dc.w	(256*6)/8 ; form_width
	dc.w	6 ; form_height
	dc.l	0 ; next_font
off_table_08:
	dc.w	$0000,$0006,$000C,$0012,$0018,$001E,$0024,$002A
	dc.w	$0030,$0036,$003C,$0042,$0048,$004E,$0054,$005A
	dc.w	$0060,$0066,$006C,$0072,$0078,$007E,$0084,$008A
	dc.w	$0090,$0096,$009C,$00A2,$00A8,$00AE,$00B4,$00BA
	dc.w	$00C0,$00C6,$00CC,$00D2,$00D8,$00DE,$00E4,$00EA
	dc.w	$00F0,$00F6,$00FC,$0102,$0108,$010E,$0114,$011A
	dc.w	$0120,$0126,$012C,$0132,$0138,$013E,$0144,$014A
	dc.w	$0150,$0156,$015C,$0162,$0168,$016E,$0174,$017A
	dc.w	$0180,$0186,$018C,$0192,$0198,$019E,$01A4,$01AA
	dc.w	$01B0,$01B6,$01BC,$01C2,$01C8,$01CE,$01D4,$01DA
	dc.w	$01E0,$01E6,$01EC,$01F2,$01F8,$01FE,$0204,$020A
	dc.w	$0210,$0216,$021C,$0222,$0228,$022E,$0234,$023A
	dc.w	$0240,$0246,$024C,$0252,$0258,$025E,$0264,$026A
	dc.w	$0270,$0276,$027C,$0282,$0288,$028E,$0294,$029A
	dc.w	$02A0,$02A6,$02AC,$02B2,$02B8,$02BE,$02C4,$02CA
	dc.w	$02D0,$02D6,$02DC,$02E2,$02E8,$02EE,$02F4,$02FA
	dc.w	$0300,$0306,$030C,$0312,$0318,$031E,$0324,$032A
	dc.w	$0330,$0336,$033C,$0342,$0348,$034E,$0354,$035A
	dc.w	$0360,$0366,$036C,$0372,$0378,$037E,$0384,$038A
	dc.w	$0390,$0396,$039C,$03A2,$03A8,$03AE,$03B4,$03BA
	dc.w	$03C0,$03C6,$03CC,$03D2,$03D8,$03DE,$03E4,$03EA
	dc.w	$03F0,$03F6,$03FC,$0402,$0408,$040E,$0414,$041A
	dc.w	$0420,$0426,$042C,$0432,$0438,$043E,$0444,$044A
	dc.w	$0450,$0456,$045C,$0462,$0468,$046E,$0474,$047A
	dc.w	$0480,$0486,$048C,$0492,$0498,$049E,$04A4,$04AA
	dc.w	$04B0,$04B6,$04BC,$04C2,$04C8,$04CE,$04D4,$04DA
	dc.w	$04E0,$04E6,$04EC,$04F2,$04F8,$04FE,$0504,$050A
	dc.w	$0510,$0516,$051C,$0522,$0528,$052E,$0534,$053A
	dc.w	$0540,$0546,$054C,$0552,$0558,$055E,$0564,$056A
	dc.w	$0570,$0576,$057C,$0582,$0588,$058E,$0594,$059A
	dc.w	$05A0,$05A6,$05AC,$05B2,$05B8,$05BE,$05C4,$05CA
	dc.w	$05D0,$05D6,$05DC,$05E2,$05E8,$05EE,$05F4,$05FA
	dc.w	$0600
dat_table_08:
	dc.w	$0082,$0421,$CFB6,$0DE3,$04E3,$8150,$F987,$BCC3
	dc.w	$CC3E,$73E0,$381F,$847C,$00CD,$947B,$260C,$3184
	dc.w	$8800,$0006,$704F,$3C33,$C73E,$71C3,$0C18,$061C
	dc.w	$71CF,$1EF3,$EF9E,$89C0,$9242,$289C,$F1CF,$1EFA
	dc.w	$28A2,$8A2F,$9EC1,$E200,$6008,$0008,$0180,$8001
	dc.w	$2060,$0000,$0000,$0020,$0000,$0000,$0E31,$C400
	dc.w	$7941,$0851,$0200,$2144,$1421,$0888,$2007,$8851
	dc.w	$0210,$5228,$841A,$2706,$1041,$04F1,$E71C,$6000
	dc.w	$30C0,$C36C,$69A3,$4201,$E41A,$6941,$0869,$E7BD
	dc.w	$4BA9,$BC7B,$FF1C,$7BFC,$1EF3,$0D8E,$F9BF,$B6F9
	dc.w	$CD5E,$3BE0,$3ED8,$C000,$01CF,$C0F8,$E000,$71C7
	dc.w	$0C18,$838C,$7886,$060C,$C21A,$30C0,$0071,$C73E
	dc.w	$01C2,$0662,$AF2A,$1A17,$8682,$0150,$C880,$84C2
	dc.w	$0C02,$5367,$203F,$42FE,$00CD,$BEA3,$4D0C,$60C3
	dc.w	$0800,$000C,$98C0,$8252,$0802,$8A23,$0C31,$E326
	dc.w	$8A28,$A08A,$0820,$8880,$9443,$6CA2,$8A28,$A022
	dc.w	$28A2,$5221,$1860,$6700,$61CF,$1C79,$C21E,$B181
	dc.w	$2421,$4F1C,$F1E7,$0E72,$28A2,$4A27,$8C30,$CE88
	dc.w	$8002,$1400,$801E,$5002,$0050,$8700,$FBCA,$1400
	dc.w	$8508,$01C0,$0E23,$6888,$2082,$0800,$00A2,$0000
	dc.w	$30C0,$06F6,$B2C4,$8C72,$C22C,$B002,$1CEB,$38D7
	dc.w	$012D,$8C08,$618C,$31BD,$861B,$E7C6,$D9B9,$B618
	dc.w	$6D56,$186F,$E6D8,$A216,$6B66,$FE61,$C6BE,$736D
	dc.w	$9A21,$C412,$03E1,$9810,$C02C,$49E0,$0768,$6300
	dc.w	$0362,$3BDF,$6E1C,$B297,$84DE,$E150,$C88F,$BEC3
	dc.w	$EF8E,$7320,$B760,$62B2,$00C9,$1470,$8618,$60C7
	dc.w	$BE01,$E018,$A847,$1C93,$CF04,$71E0,$0060,$018C
	dc.w	$BBEF,$208B,$CF26,$F880,$9842,$AAA2,$F22F,$1C22
	dc.w	$28AA,$2142,$1830,$6D80,$3028,$A08B,$E7A2,$C881
	dc.w	$3823,$E8A2,$8A24,$9822,$28AA,$3221,$1830,$6B9C
	dc.w	$8227,$1C71,$C720,$71C7,$1821,$889C,$80EF,$9C71
	dc.w	$C8A2,$8A28,$9871,$CF1E,$7187,$22F1,$2FA2,$61E7
	dc.w	$B6CC,$CD9B,$71C5,$96BA,$E71C,$7000,$08EA,$DB55
	dc.w	$4927,$0C18,$6D8C,$19BD,$8618,$6646,$D9BD,$9CD8
	dc.w	$6F56,$1866,$F671,$C72D,$D3C6,$5433,$668C,$ABED
	dc.w	$9C72,$A792,$7886,$0630,$CF80,$30C3,$0468,$C100
	dc.w	$008D,$8662,$ACAA,$E2DF,$DC93,$A358,$D9CC,$06D8
	dc.w	$698C,$DBEF,$A440,$2172,$00C0,$3E29,$6E80,$60C3
	dc.w	$0830,$0330,$C848,$02F8,$2888,$8823,$0C31,$E30C
	dc.w	$B228,$A08A,$0822,$8888,$9442,$29A2,$822A,$0222
	dc.w	$2536,$5084,$1818,$6000,$03E8,$A08A,$021E,$8881
	dc.w	$2422,$A8A2,$8A24,$0622,$252A,$31E2,$0C30,$C132
	dc.w	$822F,$8208,$20A0,$FBEF,$8820,$8FA2,$F38A,$228A
	dc.w	$28A2,$7A28,$8E20,$8888,$0888,$A289,$A79C,$6100
	dc.w	$8B14,$C6F6,$0A26,$9AA2,$C8A2,$8800,$086A,$F8C0
	dc.w	$4BAD,$8C38,$6D8C,$19BD,$8018,$6646,$D9B1,$8ED0
	dc.w	$6C56,$1866,$C631,$CDAD,$D366,$1463,$668C,$AB65
	dc.w	$36AA,$A412,$0000,$0030,$C01A,$0003,$3469,$E700
	dc.w	$0087,$0421,$C9B6,$4210,$3C18,$E75C,$D9CC,$06F8
	dc.w	$6D8C,$D867,$3C71,$EEDE,$0000,$14F2,$6D00,$3184
	dc.w	$8830,$0320,$704F,$BC13,$C708,$71C3,$0418,$0600
	dc.w	$822F,$1EF3,$E81E,$89C7,$127A,$289C,$81C9,$BC21
	dc.w	$E222,$888F,$9E09,$E000,$01EF,$1C79,$C202,$89C1
	dc.w	$2272,$289C,$F1E4,$1C11,$E236,$4827,$8E31,$C03E
	dc.w	$7A28,$3EFB,$EF9E,$8208,$0820,$88BE,$81EB,$A28A
	dc.w	$28A2,$09C7,$8479,$CF08,$F888,$A289,$6000,$C900
	dc.w	$863C,$C36C,$FA24,$8C79,$EFBE,$8800,$082B,$1A40
	dc.w	$482C,$BE68,$6D8C,$19BF,$80F1,$E6DE,$73FF,$BEC0
	dc.w	$6FF6,$1867,$C632,$889A,$6BC6,$14C1,$C7CC,$71CD
	dc.w	$B671,$C392,$7BE7,$9E30,$822C,$0000,$1C00,$0000
	dc.w	$0082,$0000,$0000,$01E3,$1810,$B64C,$F9CF,$BE1B
	dc.w	$EF8C,$F860,$0758,$AC00,$00C0,$0020,$0680,$0000
	dc.w	$0060,$0000,$0000,$0000,$0000,$0000,$0800,$000C
	dc.w	$7800,$0000,$0000,$0000,$0000,$0000,$0060,$0000
	dc.w	$0000,$0000,$0000,$003E,$0000,$0000,$003C,$000E
	dc.w	$0000,$0000,$8020,$0000,$0000,$03C0,$0030,$0000
	dc.w	$C1E7,$1E79,$E7B8,$71C7,$1C71,$C022,$F800,$1C71
	dc.w	$C79E,$F000,$0000,$8830,$79C7,$1E89,$2FBE,$7000
	dc.w	$0F04,$C000,$79CB,$1000,$08A2,$7000,$0029,$E780
	dc.w	$10C0,$0000,$0000,$0000,$0000,$0000,$0000,$00C0
	dc.w	$0000,$0000,$0001,$8000,$0306,$00F8,$0C08,$7000
	dc.w	$1CC0,$8000,$0000,$0033,$0000,$0000,$0800,$0000

header_09:
	dc.w 1
	dc.w 9
	dc.b	'8x8 system font',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,255 ; first_ade,last_ade
	dc.w	6,6,4,1,1 ; top,ascent,half,descent,bottom
	dc.w	7,8 ; char_width,,cell_width
	dc.w	1,3 ; left_offset,right_offset
	dc.w	1,1 ; thicken,ul_size
	dc.w	$5555 ; lighten
	dc.w	$5555 ; skew
	dc.w	$000d ; flags
	dc.l    0
	dc.l	off_table_09
	dc.l	dat_table_09
	dc.w	(256*8)/8 ; form_width
	dc.w	8 ; form_height
	dc.l	font_header+2*sizeof_FONTHDR ; next_font
off_table_09:
off_table_10:
	dc.w	$0000,$0008,$0010,$0018,$0020,$0028,$0030,$0038
	dc.w	$0040,$0048,$0050,$0058,$0060,$0068,$0070,$0078
	dc.w	$0080,$0088,$0090,$0098,$00A0,$00A8,$00B0,$00B8
	dc.w	$00C0,$00C8,$00D0,$00D8,$00E0,$00E8,$00F0,$00F8
	dc.w	$0100,$0108,$0110,$0118,$0120,$0128,$0130,$0138
	dc.w	$0140,$0148,$0150,$0158,$0160,$0168,$0170,$0178
	dc.w	$0180,$0188,$0190,$0198,$01A0,$01A8,$01B0,$01B8
	dc.w	$01C0,$01C8,$01D0,$01D8,$01E0,$01E8,$01F0,$01F8
	dc.w	$0200,$0208,$0210,$0218,$0220,$0228,$0230,$0238
	dc.w	$0240,$0248,$0250,$0258,$0260,$0268,$0270,$0278
	dc.w	$0280,$0288,$0290,$0298,$02A0,$02A8,$02B0,$02B8
	dc.w	$02C0,$02C8,$02D0,$02D8,$02E0,$02E8,$02F0,$02F8
	dc.w	$0300,$0308,$0310,$0318,$0320,$0328,$0330,$0338
	dc.w	$0340,$0348,$0350,$0358,$0360,$0368,$0370,$0378
	dc.w	$0380,$0388,$0390,$0398,$03A0,$03A8,$03B0,$03B8
	dc.w	$03C0,$03C8,$03D0,$03D8,$03E0,$03E8,$03F0,$03F8
	dc.w	$0400,$0408,$0410,$0418,$0420,$0428,$0430,$0438
	dc.w	$0440,$0448,$0450,$0458,$0460,$0468,$0470,$0478
	dc.w	$0480,$0488,$0490,$0498,$04A0,$04A8,$04B0,$04B8
	dc.w	$04C0,$04C8,$04D0,$04D8,$04E0,$04E8,$04F0,$04F8
	dc.w	$0500,$0508,$0510,$0518,$0520,$0528,$0530,$0538
	dc.w	$0540,$0548,$0550,$0558,$0560,$0568,$0570,$0578
	dc.w	$0580,$0588,$0590,$0598,$05A0,$05A8,$05B0,$05B8
	dc.w	$05C0,$05C8,$05D0,$05D8,$05E0,$05E8,$05F0,$05F8
	dc.w	$0600,$0608,$0610,$0618,$0620,$0628,$0630,$0638
	dc.w	$0640,$0648,$0650,$0658,$0660,$0668,$0670,$0678
	dc.w	$0680,$0688,$0690,$0698,$06A0,$06A8,$06B0,$06B8
	dc.w	$06C0,$06C8,$06D0,$06D8,$06E0,$06E8,$06F0,$06F8
	dc.w	$0700,$0708,$0710,$0718,$0720,$0728,$0730,$0738
	dc.w	$0740,$0748,$0750,$0758,$0760,$0768,$0770,$0778
	dc.w	$0780,$0788,$0790,$0798,$07A0,$07A8,$07B0,$07B8
	dc.w	$07C0,$07C8,$07D0,$07D8,$07E0,$07E8,$07F0,$07F8
	dc.w	$0800

dat_table_09:
	dc.w	$0018,$3C18,$183C,$FFE7,$017E,$1818,$F0F0,$05A0
	dc.w	$7C06,$7C7C,$C67C,$7C7C,$7C7C,$0078,$07F0,$11FC
	dc.w	$0018,$6600,$1800,$3818,$0E70,$0000,$0000,$0002
	dc.w	$3C18,$3C7E,$0C7E,$3C7E,$3C3C,$0000,$0600,$603C
	dc.w	$3C18,$7C3C,$787E,$7E3E,$663C,$0666,$60C6,$663C
	dc.w	$7C3C,$7C3C,$7E66,$66C6,$6666,$7E1E,$4078,$1000
	dc.w	$0000,$6000,$0600,$1C00,$6018,$1860,$3800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$000E,$1870,$0000
	dc.w	$0066,$0C18,$6630,$1800,$1866,$3066,$1860,$6618
	dc.w	$0C00,$3F18,$6630,$1830,$6666,$6618,$1C66,$1C1E
	dc.w	$0C0C,$0C0C,$3434,$0000,$0000,$00C6,$C600,$1BD8
	dc.w	$3434,$0200,$007F,$3034,$3466,$0C00,$7A7E,$7EF1
	dc.w	$66F6,$0000,$0000,$0000,$0000,$6000,$0060,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$000E,$0066
	dc.w	$001C,$0000,$FE00,$0000,$3C00,$001C,$0C00,$3E3C
	dc.w	$0018,$300C,$0018,$1800,$3838,$0000,$3838,$7800
	dc.w	$003C,$241C,$3899,$FFC3,$03C3,$3C1C,$C0C0,$05A0
	dc.w	$C606,$0606,$C6C0,$C006,$C6C6,$0060,$0FF8,$0BFC
	dc.w	$0018,$666C,$3E66,$6C18,$1C38,$6618,$0000,$0006
	dc.w	$6638,$660C,$1C60,$6006,$6666,$1818,$0C00,$3066
	dc.w	$663C,$6666,$6C60,$6060,$6618,$066C,$60EE,$7666
	dc.w	$6666,$6666,$1866,$66C6,$6666,$0618,$6018,$3800
	dc.w	$C000,$6000,$0600,$3000,$6000,$0060,$1800,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0018,$1818,$6018
	dc.w	$3C00,$1866,$0018,$1800,$6600,$1800,$6630,$0000
	dc.w	$1800,$7866,$0018,$6618,$0000,$0018,$3A66,$3630
	dc.w	$1818,$1818,$5858,$3C3C,$1800,$00CC,$CC18,$366C
	dc.w	$5858,$3C02,$00D8,$1858,$5800,$1810,$CAC3,$C35B
	dc.w	$0066,$667C,$1E7E,$7C1C,$1E7E,$6E3C,$3E7E,$6C1C
	dc.w	$3E36,$7E66,$3E78,$D67C,$1C3E,$FE7E,$361B,$10F7
	dc.w	$0036,$FE00,$661E,$0000,$183C,$3C36,$1810,$7066
	dc.w	$7E18,$1818,$0E18,$1832,$6C7C,$0000,$6C6C,$0CFE
	dc.w	$0066,$24F6,$6FC3,$FE99,$06D3,$3C16,$FEDF,$05A0
	dc.w	$C606,$0606,$C6C0,$C006,$C6C6,$3C78,$1FEC,$0DFF
	dc.w	$0018,$66FE,$606C,$3818,$1818,$3C18,$0000,$000C
	dc.w	$6E18,$0618,$3C7C,$600C,$6666,$1818,$187E,$1806
	dc.w	$6E66,$6660,$6660,$6060,$6618,$0678,$60FE,$7E66
	dc.w	$6666,$6660,$1866,$66C6,$3C66,$0C18,$3018,$6C00
	dc.w	$603C,$7C3C,$3E3C,$7C3E,$7C38,$1866,$18EC,$7C3C
	dc.w	$7C3E,$7C3E,$7E66,$66C6,$6666,$7E18,$1818,$F218
	dc.w	$6600,$0000,$3C00,$003C,$003C,$0000,$0000,$1818
	dc.w	$7E7E,$D800,$0000,$0000,$663C,$663C,$303C,$667C
	dc.w	$0000,$0000,$0000,$0666,$0000,$00D8,$D800,$6C36
	dc.w	$0000,$663C,$7ED8,$0000,$3C00,$3038,$CABD,$BD5F
	dc.w	$E666,$760C,$060C,$060C,$0C36,$660C,$0606,$3E0C
	dc.w	$3636,$6666,$060C,$D66C,$0C06,$6666,$363C,$3899
	dc.w	$7666,$66FE,$3038,$6C7E,$3C66,$6678,$387C,$6066
	dc.w	$007E,$0C30,$1B18,$004C,$3838,$000F,$6C18,$3800
	dc.w	$00C3,$E783,$C1E7,$FC3C,$8CD3,$3C10,$D8DB,$0DB0
	dc.w	$0000,$7C7C,$7C7C,$7C00,$7C7C,$0660,$1804,$06E1
	dc.w	$0018,$006C,$3C18,$7000,$1818,$FF7E,$007E,$0018
	dc.w	$7618,$0C0C,$6C06,$7C18,$3C3E,$0000,$3000,$0C0C
	dc.w	$6A66,$7C60,$667C,$7C6E,$7E18,$0670,$60D6,$7E66
	dc.w	$7C66,$7C3C,$1866,$66D6,$183C,$1818,$1818,$C600
	dc.w	$3006,$6660,$6666,$3066,$6618,$186C,$18FE,$6666
	dc.w	$6666,$6660,$1866,$66C6,$3C66,$0C30,$180C,$9E34
	dc.w	$6066,$3C3C,$063C,$3C60,$3C66,$3C38,$3838,$3C3C
	dc.w	$601B,$DE3C,$3C3C,$6666,$6666,$6660,$7C18,$7C30
	dc.w	$3C38,$3C66,$7C66,$3E66,$183E,$7C36,$3618,$D81B
	dc.w	$3C3C,$6E6E,$DBDE,$1818,$6600,$0010,$CAB1,$A555
	dc.w	$6666,$3C0C,$0E0C,$660C,$0636,$660C,$0606,$660C
	dc.w	$3636,$763C,$360C,$D66C,$0C06,$6676,$1C66,$6C99
	dc.w	$DC7C,$626C,$186C,$6C18,$667E,$66DC,$54D6,$7E66
	dc.w	$7E18,$1818,$1B18,$7E00,$0000,$0018,$6C30,$0C00
	dc.w	$00E7,$C383,$C1C3,$F999,$D8DB,$7E10,$DEFF,$0DB0
	dc.w	$C606,$C006,$0606,$C606,$C606,$7E7E,$1804,$07E1
	dc.w	$0018,$006C,$0630,$DE00,$1818,$3C18,$0000,$0030
	dc.w	$6618,$1806,$7E06,$6630,$6606,$1818,$1800,$1818
	dc.w	$6E7E,$6660,$6660,$6066,$6618,$0678,$60C6,$6E66
	dc.w	$6076,$6C06,$1866,$66FE,$3C18,$3018,$0C18,$0000
	dc.w	$003E,$6660,$667E,$3066,$6618,$1878,$18D6,$6666
	dc.w	$6666,$603C,$1866,$66D6,$1866,$1818,$1818,$0C34
	dc.w	$6666,$7E06,$3E06,$0660,$7E7E,$7E18,$1818,$6666
	dc.w	$7C7F,$F866,$6666,$6666,$6666,$6660,$303C,$6630
	dc.w	$0618,$6666,$6676,$6666,$3030,$0C6B,$6E18,$6C36
	dc.w	$0666,$7676,$DFD8,$3C3C,$6600,$0010,$7AB1,$B951
	dc.w	$6666,$6E0C,$1E0C,$660C,$0636,$6600,$0606,$660C
	dc.w	$3636,$060E,$360C,$D66C,$0C06,$6606,$0C66,$C6EF
	dc.w	$C866,$606C,$306C,$6C18,$6666,$66CC,$54D6,$6066
	dc.w	$0018,$300C,$18D8,$0032,$0000,$18D8,$6C7C,$7800
	dc.w	$0024,$66F6,$6F99,$F3C3,$70C3,$1070,$181E,$1998
	dc.w	$C606,$C006,$0606,$C606,$C606,$6618,$1004,$2E21
	dc.w	$0000,$00FE,$7C66,$CC00,$1C38,$6618,$3000,$1860
	dc.w	$6618,$3066,$0C66,$6630,$660C,$1818,$0C7E,$3000
	dc.w	$6066,$6666,$6C60,$6066,$6618,$666C,$60C6,$6666
	dc.w	$606C,$6666,$1866,$3CEE,$6618,$6018,$0618,$0000
	dc.w	$0066,$6660,$6660,$303E,$6618,$186C,$18C6,$6666
	dc.w	$6666,$6006,$1866,$3C7C,$3C3E,$3018,$1818,$0062
	dc.w	$3C66,$607E,$667E,$7E3C,$6060,$6018,$1818,$7E7E
	dc.w	$60D8,$D866,$6666,$6666,$3E66,$663C,$3018,$6630
	dc.w	$7E18,$6666,$666E,$3E3C,$6030,$0CC3,$D618,$366C
	dc.w	$7E66,$6666,$D8D8,$6666,$6600,$0010,$0ABD,$AD00
	dc.w	$F6F6,$667E,$360C,$660C,$0636,$7E00,$3E0E,$6E3C
	dc.w	$1C7E,$7E7E,$340C,$FEEC,$0C06,$7E06,$0C3C,$8266
	dc.w	$DC66,$606C,$666C,$6C18,$3C66,$24EC,$38D6,$7066
	dc.w	$7E00,$0000,$18D8,$184C,$0000,$1870,$0000,$0000
	dc.w	$0024,$3C1C,$383C,$E7E7,$20C3,$38F0,$181B,$799E
	dc.w	$7C06,$7C7C,$067C,$7C06,$7C7C,$3C1E,$1E3C,$393F
	dc.w	$0018,$006C,$1846,$7600,$0E70,$0000,$3000,$1840
	dc.w	$3C7E,$7E3C,$0C3C,$3C30,$3C38,$0030,$0600,$6018
	dc.w	$3E66,$7C3C,$787E,$603E,$663C,$3C66,$7EC6,$663C
	dc.w	$6036,$663C,$183E,$18C6,$6618,$7E1E,$0278,$00FE
	dc.w	$003E,$7C3C,$3E3C,$3006,$663C,$1866,$3CC6,$663C
	dc.w	$7C3E,$607C,$0E3E,$186C,$6606,$7E0E,$1870,$007E
	dc.w	$083E,$3C3E,$3E3E,$3E08,$3C3C,$3C3C,$3C3C,$6666
	dc.w	$7E7E,$DF3C,$3C3C,$3E3E,$063C,$3E18,$7E18,$7C60
	dc.w	$3E3C,$3C3E,$6666,$0000,$6630,$0C86,$9F18,$1BD8
	dc.w	$3E3C,$3C3C,$7E7F,$7E7E,$6600,$0000,$0AC3,$C300
	dc.w	$0606,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3000,$0000,$0C06,$0006,$0CD8,$0000
	dc.w	$767C,$606C,$FE38,$7F18,$183C,$6678,$307C,$3E66
	dc.w	$007E,$7E7E,$1870,$1800,$0000,$0030,$0000,$0000
	dc.w	$003C,$1818,$1800,$0000,$007E,$1060,$0000,$718E
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1754,$3800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$6000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007C,$0000,$7000,$0000,$0000
	dc.w	$6006,$0000,$0000,$0000,$007C,$0000,$1800,$0000
	dc.w	$3800,$0000,$0000,$0018,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7C00,$0018,$0000,$6000
	dc.w	$0000,$0000,$0000,$3C3C,$3C00,$000F,$0618,$0000
	dc.w	$0000,$4040,$0000,$6666,$3C00,$0000,$0A7E,$7E00
	dc.w	$1C1C,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0070,$0000
	dc.w	$0060,$F848,$0000,$C010,$3C00,$0000,$6010,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$0000,$0000

dat_table_10:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1100
	dc.w	$0000,$0000,$1800,$3800,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$4000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$003C
	dc.w	$0600,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$6032,$3200,$0000,$0000,$00F1
	dc.w	$00F6,$0000,$0000,$0000,$0000,$0000,$0060,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0018,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$05A0
	dc.w	$7C00,$7C7C,$007C,$7C7C,$7C7C,$0000,$0000,$0B00
	dc.w	$0000,$0000,$1800,$7C00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1000
	dc.w	$6000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$000E,$18E0,$0000
	dc.w	$0000,$0618,$0060,$1C00,$1800,$6000,$1860,$6666
	dc.w	$0C00,$3E18,$0060,$1860,$0066,$6600,$0E00,$0000
	dc.w	$0606,$0606,$3232,$0000,$0000,$0060,$6000,$0000
	dc.w	$3232,$0100,$0000,$307A,$7A66,$0610,$0000,$005B
	dc.w	$66F6,$0000,$0000,$0000,$0000,$0000,$0060,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7C00,$001E,$0E00,$0000
	dc.w	$0000,$0000,$0018,$0000,$3838,$0000,$0000,$00FE
	dc.w	$0000,$0030,$0C7C,$FEEE,$0100,$0008,$7838,$05A0
	dc.w	$BA02,$3A3A,$82B8,$B8BA,$BABA,$0078,$0000,$0DFC
	dc.w	$0018,$6666,$3E66,$6C18,$0660,$6600,$0000,$0006
	dc.w	$3C18,$3C7E,$0C7E,$1C7E,$3C3C,$0000,$0000,$003C
	dc.w	$3818,$7C3C,$787E,$7E3E,$667E,$06CC,$60C6,$663C
	dc.w	$7C3C,$F83E,$7E66,$66C6,$6666,$7E1E,$6078,$1000
	dc.w	$7000,$6000,$0600,$0E00,$6018,$0CC0,$3800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0018,$1830,$0000
	dc.w	$3C66,$0C3C,$6630,$3600,$3C66,$3066,$3C30,$663C
	dc.w	$1800,$7E3C,$6630,$3C30,$6666,$6618,$1E66,$1C0E
	dc.w	$0C0C,$0C0C,$7A7A,$0000,$1800,$0020,$2000,$0000
	dc.w	$7A7A,$3D00,$007E,$184C,$4C66,$0C7C,$7A7C,$7C5F
	dc.w	$6666,$667C,$1E7E,$7E38,$1E7E,$6E3C,$3C7E,$6C1C
	dc.w	$FE36,$7E6E,$3E7C,$D67E,$387E,$7E7E,$6E1C,$0000
	dc.w	$0018,$FE00,$FE00,$0000,$103C,$383E,$1E10,$3E7C
	dc.w	$0000,$6006,$0E18,$0000,$6C7C,$0000,$3030,$78FE
	dc.w	$0018,$3C38,$1C38,$FEC6,$013C,$000E,$4040,$05A0
	dc.w	$C606,$0606,$C6C0,$C0C6,$C6C6,$0040,$0000,$06FC
	dc.w	$0018,$6666,$7E66,$6C18,$0C30,$6618,$0000,$0006
	dc.w	$7E18,$7E7E,$0C7E,$3C7E,$7E7E,$0000,$0E00,$E07E
	dc.w	$7C3C,$7E7E,$7C7E,$7E7E,$667E,$06CC,$60C6,$667E
	dc.w	$7E7E,$FC7E,$7E66,$66C6,$6666,$7E1E,$6078,$3800
	dc.w	$3800,$6000,$0600,$1E00,$6018,$0CC0,$3800,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0018,$1830,$0000
	dc.w	$7E66,$1866,$6618,$1C00,$6666,$1866,$6618,$1818
	dc.w	$7E00,$F866,$6618,$6618,$6600,$0018,$3866,$3E1E
	dc.w	$1818,$1818,$4C4C,$0000,$1800,$0020,$2018,$0000
	dc.w	$4C4C,$7E00,$00FE,$0000,$0000,$1810,$CAC6,$C655
	dc.w	$0066,$767C,$1E7E,$7E38,$1E7E,$6E3C,$3E7E,$6E1C
	dc.w	$FE36,$7E6E,$3E7E,$D67E,$387E,$3E7E,$6E36,$0000
	dc.w	$003C,$7E00,$FE00,$0002,$107E,$6C20,$1010,$7EFE
	dc.w	$0018,$700E,$1918,$1802,$447C,$0000,$7848,$1800
	dc.w	$003C,$242C,$34BA,$FED6,$0366,$180F,$7040,$05A0
	dc.w	$C606,$0606,$C6C0,$C0C6,$C6C6,$0070,$0000,$07FC
	dc.w	$0018,$66FF,$606C,$3818,$1C38,$3C18,$0000,$0006
	dc.w	$6638,$660C,$1C60,$7006,$6666,$1818,$1C7E,$7066
	dc.w	$E67E,$6666,$6E60,$6060,$6618,$06D8,$60EE,$6666
	dc.w	$6666,$CC60,$1866,$66C6,$6666,$0C18,$6018,$3800
	dc.w	$1C00,$6000,$0600,$1800,$6000,$00C0,$1800,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0018,$1830,$0000
	dc.w	$6600,$0000,$0000,$0000,$0000,$0000,$0000,$3C3C
	dc.w	$7E00,$D800,$0000,$0000,$003C,$663C,$3066,$6618
	dc.w	$0000,$0000,$0000,$3C3C,$0000,$0023,$2318,$0000
	dc.w	$0000,$6601,$00D8,$3C3C,$3C00,$0010,$CA82,$8251
	dc.w	$E666,$760C,$060C,$0618,$0466,$660C,$0606,$3E0C
	dc.w	$FE36,$6666,$3E06,$D666,$1806,$3666,$6632,$0066
	dc.w	$6266,$6202,$601E,$007E,$7C66,$C630,$7C7C,$E0C6
	dc.w	$7E18,$381C,$1B18,$183E,$6C7C,$0000,$4818,$3000
	dc.w	$0066,$24E6,$6792,$FC92,$03C3,$3C09,$4040,$0DB0
	dc.w	$C606,$0606,$C6C0,$C0C6,$C6C6,$7C40,$0000,$2EFF
	dc.w	$0018,$66FF,$600C,$3818,$1818,$3C18,$0000,$000C
	dc.w	$6638,$660C,$1C60,$6006,$6666,$1818,$387E,$3866
	dc.w	$C266,$6666,$6660,$6060,$6618,$06D8,$60EE,$7666
	dc.w	$6666,$CC60,$1866,$66C6,$3C66,$0C18,$3018,$6C00
	dc.w	$0C3C,$7C3C,$3E3C,$183E,$7C38,$0CCC,$186C,$3C3C
	dc.w	$7C3E,$7C3E,$7E66,$66C6,$6666,$7E18,$1830,$6218
	dc.w	$6666,$3C3C,$3C3C,$3C3C,$3C3C,$3C38,$3838,$7E7E
	dc.w	$6076,$D83C,$3C3C,$6666,$667E,$667E,$3066,$6618
	dc.w	$3C38,$3C66,$3C66,$3E7E,$1800,$0026,$2600,$0000
	dc.w	$3C3C,$663D,$7ED8,$7E7E,$7E00,$0010,$CABA,$BA00
	dc.w	$6666,$3E0C,$060C,$6618,$0C66,$660C,$0606,$360C
	dc.w	$C636,$6636,$0606,$D666,$1806,$3666,$7618,$10F7
	dc.w	$F666,$607E,$3038,$66FC,$C642,$C618,$D6D6,$C0C6
	dc.w	$7E18,$1C38,$1B18,$007C,$3838,$001F,$4830,$1800
	dc.w	$00C3,$2483,$C1D6,$FCBA,$0691,$3C08,$4038,$0DB0
	dc.w	$8202,$3A3A,$BAB8,$B882,$BABA,$7E78,$0000,$39E1
	dc.w	$0018,$6666,$7C18,$7018,$1818,$FF7E,$007E,$000C
	dc.w	$6618,$0C18,$3C7C,$600C,$3C7E,$1818,$7000,$1C0C
	dc.w	$DA66,$7E60,$667C,$7C6E,$7E18,$06F0,$60FE,$7666
	dc.w	$6666,$CC70,$1866,$66C6,$3C3C,$1818,$3018,$6C00
	dc.w	$043E,$7E7C,$7E7E,$7E7E,$7E38,$0CDC,$18FE,$7E7E
	dc.w	$7E7E,$7E7E,$7E66,$66C6,$6666,$7E38,$1838,$F218
	dc.w	$6066,$7E3E,$3E3E,$3E7C,$7E7E,$7E38,$3838,$6666
	dc.w	$607F,$DE7E,$7E7E,$6666,$6666,$6666,$307E,$6618
	dc.w	$3E38,$7E66,$7E66,$0666,$1800,$002C,$2C18,$1AB0
	dc.w	$3E7E,$6E7E,$FFDE,$6666,$6600,$0010,$CAA2,$AA00
	dc.w	$6666,$3C0C,$0E0C,$6618,$0C66,$6600,$0606,$660C
	dc.w	$C636,$763E,$0606,$F666,$1806,$3676,$3E3C,$1099
	dc.w	$DC66,$60FC,$186C,$6690,$8242,$C63C,$9292,$C0C6
	dc.w	$007E,$0E70,$1818,$7E40,$0000,$0010,$4860,$4800
	dc.w	$0081,$E783,$C1C6,$F838,$0691,$3C08,$0000,$1DB8
	dc.w	$0000,$7C7C,$7C7C,$7C00,$7C7C,$0600,$0000,$38E1
	dc.w	$0018,$6666,$3E18,$7018,$1818,$FF7E,$007E,$0018
	dc.w	$6E18,$0C18,$3C7E,$7C0C,$3C3E,$1818,$E000,$0E0C
	dc.w	$D666,$7C60,$667C,$7C6E,$7E18,$06F0,$60D6,$7E66
	dc.w	$6666,$FC38,$1866,$66D6,$183C,$1818,$1818,$C600
	dc.w	$0006,$6660,$6666,$7E66,$6618,$0CF8,$18FE,$6666
	dc.w	$6666,$6660,$1866,$66D6,$3C66,$0CF0,$181E,$BE3C
	dc.w	$6066,$6606,$0606,$0660,$6666,$6618,$1818,$6666
	dc.w	$7C1B,$DE66,$6666,$6666,$6666,$6660,$303C,$7C7E
	dc.w	$0618,$6666,$6676,$3E66,$1800,$0018,$1818,$36D8
	dc.w	$0666,$6E66,$DBDE,$6666,$6600,$0010,$CAA2,$B200
	dc.w	$6666,$3C0C,$1E0C,$6618,$0C66,$6600,$060E,$660C
	dc.w	$C636,$7618,$3606,$F666,$1806,$3676,$0E66,$3899
	dc.w	$887C,$60A8,$0CC6,$6630,$827E,$C666,$9292,$FCC6
	dc.w	$7E7E,$1C38,$1818,$7E02,$0000,$00D0,$4878,$3000
	dc.w	$00E7,$81E6,$67D6,$FABA,$8C9D,$3C78,$1E1C,$399C
	dc.w	$8202,$B83A,$3A3A,$BA02,$BA3A,$060E,$07F0,$00E1
	dc.w	$0018,$00FF,$0630,$DE00,$1818,$3C18,$0000,$0018
	dc.w	$7618,$180C,$6C06,$7E18,$6606,$0000,$707E,$1C18
	dc.w	$D67E,$6660,$6660,$6066,$6618,$06D8,$60D6,$7E66
	dc.w	$7E66,$F81C,$1866,$66D6,$1818,$3018,$1818,$C600
	dc.w	$003E,$6660,$6666,$1866,$6618,$0CF0,$18D6,$6666
	dc.w	$6666,$6070,$1866,$66D6,$3C66,$18F0,$181E,$9C24
	dc.w	$6066,$663E,$3E3E,$3E60,$6666,$6618,$1818,$7E7E
	dc.w	$7C7B,$F866,$6666,$6666,$6666,$6660,$FE18,$6618
	dc.w	$3E18,$6666,$667E,$7E66,$3000,$0030,$3218,$6C6C
	dc.w	$3E66,$766E,$DBD8,$7E7E,$6600,$0000,$7AA2,$BA00
	dc.w	$6666,$6E0C,$360C,$6618,$0C66,$6600,$061C,$660C
	dc.w	$C636,$061C,$3606,$C666,$1806,$3606,$0666,$38EF
	dc.w	$8866,$6028,$0CC6,$6630,$8242,$6C42,$9292,$FCC6
	dc.w	$7E18,$381C,$1818,$003E,$0000,$00D0,$0000,$0000
	dc.w	$0024,$C32C,$3492,$F292,$8C81,$3CF8,$1012,$799E
	dc.w	$C606,$C006,$0606,$C606,$C606,$7E10,$0FF8,$00E1
	dc.w	$0018,$00FF,$0636,$DE00,$1818,$3C18,$0000,$0030
	dc.w	$6618,$180C,$6C06,$6618,$6606,$0000,$387E,$3818
	dc.w	$DC7E,$6660,$6660,$6066,$6618,$06D8,$60C6,$6E66
	dc.w	$7C66,$D80E,$1866,$66FE,$3C18,$3018,$0C18,$0000
	dc.w	$007E,$6660,$667E,$1866,$6618,$0CF8,$18D6,$6666
	dc.w	$6666,$603C,$1866,$66FE,$1866,$1838,$1838,$0066
	dc.w	$6066,$7E7E,$7E7E,$7E60,$7E7E,$7E18,$1818,$7E7E
	dc.w	$60FF,$F866,$6666,$6666,$6666,$6666,$307E,$6618
	dc.w	$7E18,$6666,$667E,$6666,$307E,$7E6E,$6618,$D836
	dc.w	$7E66,$767E,$DFD8,$7E7E,$6600,$0000,$0ABA,$AA00
	dc.w	$6666,$6E0C,$360C,$6618,$0C66,$6600,$0630,$6E0C
	dc.w	$C636,$7E0E,$3606,$C666,$1806,$3606,$063C,$6C66
	dc.w	$DC66,$6028,$18C6,$6630,$8242,$2842,$9292,$C0C6
	dc.w	$0018,$700E,$1818,$187C,$0000,$1850,$0000,$0000
	dc.w	$0024,$6638,$1CBA,$F6D6,$D8C3,$7E70,$1C1C,$718E
	dc.w	$C606,$C006,$0606,$C606,$C606,$660C,$1FEC,$0021
	dc.w	$0000,$0066,$7E66,$CC00,$1818,$6618,$1800,$1830
	dc.w	$6618,$3066,$7E06,$6630,$6606,$1818,$1C00,$7018
	dc.w	$C066,$6666,$6660,$6066,$6618,$66CC,$60C6,$6E66
	dc.w	$6066,$CC06,$1866,$3CFE,$3C18,$6018,$0C18,$0000
	dc.w	$0066,$6660,$6660,$1866,$6618,$0CD8,$18D6,$6666
	dc.w	$6666,$600E,$1866,$3CFE,$3C66,$3018,$1830,$0042
	dc.w	$6666,$6066,$6666,$6660,$6060,$6018,$1818,$6666
	dc.w	$60D8,$D866,$6666,$6666,$6666,$667E,$3018,$6618
	dc.w	$6618,$6666,$666E,$6666,$667E,$7ED3,$CE18,$6C6C
	dc.w	$6666,$6676,$D8D8,$6666,$6600,$0000,$0A82,$8200
	dc.w	$6666,$667E,$360C,$6618,$0C66,$7E00,$3E30,$6E7C
	dc.w	$FE7E,$7E7E,$3606,$FEE6,$1806,$3E06,$0618,$6C00
	dc.w	$F666,$6028,$30C6,$6630,$C666,$AA66,$D6D6,$C0C6
	dc.w	$7E18,$6006,$18D8,$1840,$0000,$3C70,$0000,$0000
	dc.w	$0024,$3C30,$0C38,$E6C6,$5866,$FF00,$1014,$718E
	dc.w	$C606,$C006,$0606,$C606,$C606,$6602,$1804,$0021
	dc.w	$0000,$0066,$7C66,$CC00,$1C38,$6600,$1800,$1860
	dc.w	$6618,$3066,$7E66,$6630,$660E,$1818,$0E00,$E000
	dc.w	$E266,$6666,$6E60,$6066,$6618,$66CC,$60C6,$6666
	dc.w	$606A,$CC06,$1866,$3CEE,$6618,$6018,$0618,$0000
	dc.w	$0066,$6660,$6660,$187E,$6618,$0CCC,$18C6,$6666
	dc.w	$6666,$6006,$1866,$3CEE,$3C7E,$3018,$1830,$00C3
	dc.w	$6666,$6066,$6666,$6660,$6060,$6018,$1818,$6666
	dc.w	$60D8,$D866,$6666,$6666,$7E66,$663C,$3018,$6618
	dc.w	$6618,$6666,$6666,$7E7E,$6660,$0606,$1A18,$36D8
	dc.w	$6666,$6666,$D8D8,$6666,$6600,$0000,$0AC6,$C600
	dc.w	$66F6,$627E,$360C,$6618,$0466,$7E00,$3C30,$6E7C
	dc.w	$7C7E,$7E7E,$3606,$FEE6,$1806,$3E06,$064C,$C600
	dc.w	$627C,$6028,$606C,$7F20,$7C7E,$EE7E,$7C7C,$E0C6
	dc.w	$7E00,$0000,$18D8,$0000,$0000,$3C20,$0000,$0000
	dc.w	$003C,$1800,$007C,$EEEE,$703C,$1000,$1012,$6186
	dc.w	$BA02,$B83A,$023A,$BA02,$BA3A,$7E1C,$1804,$003F
	dc.w	$0018,$0000,$1800,$FE00,$0C30,$0000,$1800,$1860
	dc.w	$7E7E,$7E7E,$0C7E,$7E30,$7E3C,$1818,$0000,$0018
	dc.w	$7E66,$7E7E,$7C7E,$607E,$667E,$7EC6,$7EC6,$667E
	dc.w	$607C,$C67E,$187E,$18C6,$6618,$7E1E,$0678,$00FE
	dc.w	$007E,$7E7E,$7E7E,$183E,$663C,$0CCE,$3CC6,$667E
	dc.w	$7E7E,$607E,$1E7E,$18C6,$663E,$7E18,$1830,$00FF
	dc.w	$7E7E,$7E7E,$7E7E,$7E7E,$7E7E,$7E3C,$3C3C,$6666
	dc.w	$7EFF,$DE7E,$7E7E,$7E7E,$3E7E,$7E18,$7F18,$7E18
	dc.w	$7E3C,$7E7E,$6666,$3E3C,$7E60,$060C,$3218,$1AB0
	dc.w	$7E7E,$7E7E,$FFFE,$6666,$7E00,$0000,$0A7C,$7C00
	dc.w	$F6F6,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3000,$0000,$1806,$0006,$066C,$C600
	dc.w	$006C,$6000,$FE38,$5D00,$103C,$6C3C,$1010,$7EC6
	dc.w	$007E,$7E7E,$1898,$0000,$0000,$1800,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3000,$3800,$0000,$4182
	dc.w	$7C00,$7C7C,$007C,$7C00,$7C7C,$3C00,$1004,$0000
	dc.w	$0018,$0000,$1800,$7600,$0660,$0000,$1800,$1860
	dc.w	$3C7E,$7E3C,$0C3C,$3C30,$3C38,$1818,$0000,$0018
	dc.w	$3C66,$7C3C,$787E,$603C,$667E,$3CC6,$7EC6,$663C
	dc.w	$6036,$C67C,$183C,$1882,$6618,$7E1E,$0678,$00FE
	dc.w	$003E,$7C3E,$3E3E,$1806,$663C,$0CC6,$3CC6,$663C
	dc.w	$7C3E,$607C,$0E3E,$1882,$6606,$7E18,$1830,$0000
	dc.w	$3C3E,$3E3E,$3E3E,$3E3E,$3E3E,$3E3C,$3C3C,$6666
	dc.w	$7E7F,$DE3C,$3C3C,$3E3E,$063C,$3C18,$FF18,$7C70
	dc.w	$3E3C,$3C3E,$6666,$0000,$3C60,$0618,$3F18,$0000
	dc.w	$3E3C,$BCBC,$7F7E,$6666,$3C00,$0000,$0A00,$0000
	dc.w	$0E0E,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3000,$0000,$1806,$0006,$0638,$0000
	dc.w	$0060,$F000,$FE00,$C000,$1000,$0000,$F010,$3EC6
	dc.w	$007E,$7E7E,$1870,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$2000,$1000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1E3C,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0030,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007E,$0000,$7C00,$0000,$0000
	dc.w	$6006,$0000,$0000,$0000,$007E,$000E,$18E0,$0000
	dc.w	$0C00,$0000,$0000,$000C,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7E00,$0000,$0000,$6060
	dc.w	$0000,$0000,$0000,$7E7E,$0000,$001F,$0218,$0000
	dc.w	$0000,$8080,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3C7C,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0040,$0000,$0000,$8000,$7C00,$0000,$E000,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1754,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$2000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0020,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007C,$0000,$7800,$0000,$0000
	dc.w	$6006,$0000,$0000,$0000,$007C,$0000,$0000,$0000
	dc.w	$3800,$0000,$0000,$0038,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7C00,$0000,$0000,$6000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3878,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$0000,$0000

header_10:
	dc.w 1
	dc.w 10
	dc.b	'8x16 system font',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,255 ; first_ade,last_ade
	dc.w	13,11,8,2,2 ; top,ascent,half,descent,bottom
	dc.w	7,8 ; char_width,,cell_width
	dc.w	1,7 ; left_offset,right_offset
	dc.w	1,1 ; thicken,ul_size
	dc.w	$5555 ; lighten
	dc.w	$5555 ; skew
	dc.w	$000c ; flags
	dc.l    0
	dc.l	off_table_10
	dc.l	dat_table_10
	dc.w	(256*8)/8 ; form_width
	dc.w	16 ; form_height
	dc.l	0 ; next_font

closed:
	dc.l	handle_error
	dc.w	$0000
	dc.w	$0000
	dc.w	-1 ; handle
	dc.w	-1 ; device_id
color_map_tab:
	dc.b	$00,$FF,$01,$02,$04,$06,$03,$05
	dc.b	$07,$08,$09,$0A,$0C,$0E,$0B,$0D
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17
	dc.b	$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	dc.b	$20,$21,$22,$23,$24,$25,$26,$27
	dc.b	$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	dc.b    $30,$31,$32,$33,$34,$35,$36,$37
	dc.b    $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
	dc.b    $40,$41,$42,$43,$44,$45,$46,$47
	dc.b    $48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	dc.b    $50,$51,$52,$53,$54,$55,$56,$57
	dc.b    $58,$59,$5A,$5B,$5C,$5D,$5E,$5F
	dc.b    $60,$61,$62,$63,$64,$65,$66,$67
	dc.b    $68,$69,$6A,$6B,$6C,$6D,$6E,$6F
	dc.b    $70,$71,$72,$73,$74,$75,$76,$77
	dc.b    $78,$79,$7A,$7B,$7C,$7D,$7E,$7F
	dc.b	$80,$81,$82,$83,$84,$85,$86,$87
	dc.b	$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
	dc.b	$90,$91,$92,$93,$94,$95,$96,$97
	dc.b	$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
	dc.b	$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	dc.b	$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
	dc.b	$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	dc.b	$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	dc.b	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
	dc.b	$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
	dc.b	$D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
	dc.b	$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
	dc.b	$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	dc.b	$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
	dc.b	$F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
	dc.b	$F8,$F9,$FA,$FB,$FC,$FD,$FE,$0F
color_rev_tab:
	dc.b	$00,$02,$03,$06,$04,$07,$05,$08
	dc.b	$09,$0A,$0B,$0E,$0C,$0F,$0D,$FF
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17
	dc.b	$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	dc.b	$20,$21,$22,$23,$24,$25,$26,$27
	dc.b    $28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	dc.b    $30,$31,$32,$33,$34,$35,$36,$37
	dc.b    $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
	dc.b    $40,$41,$42,$43,$44,$45,$46,$47
	dc.b    $48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	dc.b    $50,$51,$52,$53,$54,$55,$56,$57
	dc.b    $58,$59,$5A,$5B,$5C,$5D,$5E,$5F
	dc.b    $60,$61,$62,$63,$64,$65,$66,$67
	dc.b    $68,$69,$6A,$6B,$6C,$6D,$6E,$6F
	dc.b    $70,$71,$72,$73,$74,$75,$76,$77
	dc.b    $78,$79,$7A,$7B,$7C,$7D,$7E,$7F
	dc.b	$80,$81,$82,$83,$84,$85,$86,$87
	dc.b	$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
	dc.b	$90,$91,$92,$93,$94,$95,$96,$97
	dc.b	$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
	dc.b	$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	dc.b	$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
	dc.b	$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	dc.b	$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	dc.b	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
	dc.b	$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
	dc.b	$D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
	dc.b	$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
	dc.b	$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	dc.b	$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
	dc.b	$F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
	dc.b	$F8,$F9,$FA,$FB,$FC,$FD,$FE,$01

fill0:
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
fill1:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
fill2_1:
	dc.w	$0000,$4444,$0000,$1111
	dc.w	$0000,$4444,$0000,$1111
	dc.w	$0000,$4444,$0000,$1111
	dc.w	$0000,$4444,$0000,$1111
fill2_2:
	dc.w	$0000,$5555,$0000,$5555
	dc.w	$0000,$5555,$0000,$5555
	dc.w	$0000,$5555,$0000,$5555
	dc.w	$0000,$5555,$0000,$5555
fill2_3:
	dc.w	$8888,$5555,$2222,$5555
	dc.w	$8888,$5555,$2222,$5555
	dc.w	$8888,$5555,$2222,$5555
	dc.w	$8888,$5555,$2222,$5555
fill2_4:
	dc.w	$AAAA,$5555,$AAAA,$5555
	dc.w	$AAAA,$5555,$AAAA,$5555
	dc.w	$AAAA,$5555,$AAAA,$5555
	dc.w	$AAAA,$5555,$AAAA,$5555
fill2_5:
	dc.w	$AAAA,$DDDD,$AAAA,$7777
	dc.w	$AAAA,$DDDD,$AAAA,$7777
	dc.w	$AAAA,$DDDD,$AAAA,$7777
	dc.w	$AAAA,$DDDD,$AAAA,$7777
fill2_6:
	dc.w	$AAAA,$FFFF,$AAAA,$FFFF
	dc.w	$AAAA,$FFFF,$AAAA,$FFFF
	dc.w	$AAAA,$FFFF,$AAAA,$FFFF
	dc.w	$AAAA,$FFFF,$AAAA,$FFFF
fill2_7:
	dc.w	$EEEE,$FFFF,$BBBB,$FFFF
	dc.w	$EEEE,$FFFF,$BBBB,$FFFF
	dc.w	$EEEE,$FFFF,$BBBB,$FFFF
	dc.w	$EEEE,$FFFF,$BBBB,$FFFF
fill2_8:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
fill2_9:
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$FFFF,$0808,$0808,$0808
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$FFFF,$0808,$0808,$0808
fill2_10:
	dc.w	$2020,$4040,$8080,$4141
	dc.w	$2222,$1414,$0808,$1010
	dc.w	$2020,$4040,$8080,$4141
	dc.w	$2222,$1414,$0808,$1010
fill2_11:
	dc.w	$0000,$0000,$1010,$2828
	dc.w	$0000,$0000,$0101,$8282
	dc.w	$0000,$0000,$1010,$2828
	dc.w	$0000,$0000,$0101,$8282
fill2_12:
	dc.w	$0202,$0202,$AAAA,$5050
	dc.w	$2020,$2020,$AAAA,$0505
	dc.w	$0202,$0202,$AAAA,$5050
	dc.w	$2020,$2020,$AAAA,$0505
fill2_13:
	dc.w	$4040,$8080,$0000,$0808
	dc.w	$0404,$0202,$0000,$2020
	dc.w	$4040,$8080,$0000,$0808
	dc.w	$0404,$0202,$0000,$2020
fill2_14:
	dc.w	$6606,$C6C6,$D8D8,$1818
	dc.w	$8181,$8DB1,$0C33,$6000
	dc.w	$6606,$C6C6,$D8D8,$1818
	dc.w	$8181,$8DB1,$0C33,$6000
fill2_15:
	dc.w	$0000,$0000,$0400,$0000
	dc.w	$0010,$0000,$8000,$0000
	dc.w	$0000,$0000,$0400,$0000
	dc.w	$0010,$0000,$8000,$0000
fill2_16:
	dc.w	$F8F8,$6C6C,$C6C6,$8F8F
	dc.w	$1F1F,$3636,$6363,$F1F1
	dc.w	$F8F8,$6C6C,$C6C6,$8F8F
	dc.w	$1F1F,$3636,$6363,$F1F1
fill2_17:
	dc.w	$AAAA,$0000,$8888,$1414
	dc.w	$2222,$4141,$8888,$0000
	dc.w	$AAAA,$0000,$8888,$1414
	dc.w	$2222,$4141,$8888,$0000
fill2_18:
	dc.w	$0808,$0000,$AAAA,$0000
	dc.w	$0808,$0000,$8888,$0000
	dc.w	$0808,$0000,$AAAA,$0000
	dc.w	$0808,$0000,$8888,$0000
fill2_19:
	dc.w	$7777,$9898,$F8F8,$F8F8
	dc.w	$7777,$8989,$8F8F,$8F8F
	dc.w	$7777,$9898,$F8F8,$F8F8
	dc.w	$7777,$8989,$8F8F,$8F8F
fill2_20:
	dc.w	$8080,$8080,$4141,$3E3E
	dc.w	$0808,$0808,$1414,$E3E3
	dc.w	$8080,$8080,$4141,$3E3E
	dc.w	$0808,$0808,$1414,$E3E3
fill2_21:
	dc.w	$8181,$4242,$2424,$1818
	dc.w	$0606,$0101,$8080,$8080
	dc.w	$8181,$4242,$2424,$1818
	dc.w	$0606,$0101,$8080,$8080
fill2_22:
	dc.w	$F0F0,$F0F0,$F0F0,$F0F0
	dc.w	$0F0F,$0F0F,$0F0F,$0F0F
	dc.w	$F0F0,$F0F0,$F0F0,$F0F0
	dc.w	$0F0F,$0F0F,$0F0F,$0F0F
fill2_23:
	dc.w	$0808,$1C1C,$3E3E,$7F7F
	dc.w	$FFFF,$7F7F,$3E3E,$1C1C
	dc.w	$0808,$1C1C,$3E3E,$7F7F
	dc.w	$FFFF,$7F7F,$3E3E,$1C1C
fill2_24:
	dc.w	$1111,$2222,$4444,$FFFF
	dc.w	$8888,$4444,$2222,$FFFF
	dc.w	$1111,$2222,$4444,$FFFF
	dc.w	$8888,$4444,$2222,$FFFF
fill3_1:
	dc.w	$0101,$0202,$0404,$0808
	dc.w	$1010,$2020,$4040,$8080
	dc.w	$0101,$0202,$0404,$0808
	dc.w	$1010,$2020,$4040,$8080
fill3_2:
	dc.w	$6060,$C0C0,$8181,$0303
	dc.w	$0606,$0C0C,$1818,$3030
	dc.w	$6060,$C0C0,$8181,$0303
	dc.w	$0606,$0C0C,$1818,$3030
fill3_3:
	dc.w	$4242,$8181,$8181,$4242
	dc.w	$2424,$1818,$1818,$2424
	dc.w	$4242,$8181,$8181,$4242
	dc.w	$2424,$1818,$1818,$2424
fill3_4:
	dc.w	$8080,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
fill3_5:
	dc.w	$FFFF,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
fill3_6:
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
fill3_7:
	dc.w	$0001,$0002,$0004,$0008
	dc.w	$0010,$0020,$0040,$0080
	dc.w	$0100,$0200,$0400,$0800
	dc.w	$1000,$2000,$4000,$8000
fill3_8:
	dc.w	$8003,$0007,$000E,$001C
	dc.w	$0038,$0070,$00E0,$01C0
	dc.w	$0380,$0700,$0E00,$1C00
	dc.w	$3800,$7000,$E000,$C001
fill3_9:
	dc.w	$8001,$4002,$2004,$1008
	dc.w	$0810,$0420,$0240,$0180
	dc.w	$0180,$0240,$0420,$0810
	dc.w	$1008,$2004,$4002,$8001
fill3_10:
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$8000,$8000
fill3_11:
	dc.w	$FFFF,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
fill3_12:
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
	dc.w	$FFFF,$8080,$8080,$8080
	dc.w	$8080,$8080,$8080,$8080
fill4_1:
	dc.w	$0000,$05A0,$05A0,$05A0
	dc.w	$05A0,$0DB0,$0DB0,$1DB8
	dc.w	$399C,$799E,$718E,$718E
	dc.w	$6186,$4182,$0000,$0000
sin:
	dc.w	$7FFF,$7FFA,$7FEB,$7FD2
	dc.w	$7FAF,$7F82,$7F4B,$7F0B
	dc.w	$7EC0,$7E6C,$7E0D,$7DA5
	dc.w	$7D33,$7CB7,$7C32,$7BA2
	dc.w	$7B0A,$7A67,$79BB,$7906
	dc.w	$7847,$777F,$76AD,$75D2
	dc.w	$74EE,$7401,$730B,$720C
	dc.w	$7104,$6FF3,$6ED9,$6DB7
	dc.w	$6C8C,$6B59,$6A1D,$68D9
	dc.w	$678D,$6639,$64DD,$6379
	dc.w	$620D,$609A,$5F1F,$5D9C
	dc.w	$5C13,$5A82,$58EA,$574B
	dc.w	$55A5,$53F9,$5246,$508D
	dc.w	$4ECD,$4D08,$4B3C,$496A
	dc.w	$4793,$45B6,$43D4,$41EC
	dc.w	$4000,$3E0E,$3C17,$3A1C
	dc.w	$381C,$3618,$3410,$3203
	dc.w	$2FF3,$2DDF,$2BC7,$29AC
	dc.w	$278E,$256C,$2348,$2121
	dc.w	$1EF7,$1CCB,$1A9D,$186C
	dc.w	$163A,$1406,$11D0,$0F99
	dc.w	$0D61,$0B28,$08EE,$06B3
	dc.w	$0478,$023C
cos:
	dc.w	$0000,$FDC4,$FB88,$F94D
	dc.w	$F712,$F4D8,$F29F,$F067
	dc.w	$EE30,$EBFA,$E9C6,$E794
	dc.w	$E563,$E335,$E109,$DEDF
	dc.w	$DCB8,$DA94,$D872,$D654
	dc.w	$D439,$D221,$D00D,$CDFD
	dc.w	$CBF0,$C9E8,$C7E4,$C5E4
	dc.w	$C3E9,$C1F2,$C001,$BE14
	dc.w	$BC2C,$BA4A,$B86D,$B696
	dc.w	$B4C4,$B2F8,$B133,$AF73
	dc.w	$ADBA,$AC07,$AA5B,$A8B5
	dc.w	$A716,$A57E,$A3ED,$A264
	dc.w	$A0E1,$9F66,$9DF3,$9C87
	dc.w	$9B23,$99C7,$9873,$9727
	dc.w	$95E3,$94A7,$9374,$9249
	dc.w	$9127,$900D,$8EFC,$8DF4
	dc.w	$8CF5,$8BFF,$8B12,$8A2E
	dc.w	$8953,$8881,$87B9,$86FA
	dc.w	$8645,$8599,$84F6,$845E
	dc.w	$83CE,$8349,$82CD,$825B
	dc.w	$81F3,$8194,$8140,$80F5
	dc.w	$80B5,$807E,$8051,$802E
	dc.w	$8015,$8006,$8001,$8006
	dc.w	$8015,$802E,$8051,$807E
	dc.w	$80B5,$80F5,$8140,$8194
	dc.w	$81F3,$825B,$82CD,$8349
	dc.w	$83CE,$845E,$84F6,$8599
	dc.w	$8645,$86FA,$87B9,$8881
	dc.w	$8953,$8A2E,$8B12,$8BFF
	dc.w	$8CF5,$8DF4,$8EFC,$900D
	dc.w	$9127,$9249,$9374,$94A7
	dc.w	$95E3,$9727,$9873,$99C7
	dc.w	$9B23,$9C87,$9DF3,$9F66
	dc.w	$A0E1,$A264,$A3ED,$A57E
	dc.w	$A716,$A8B5,$AA5B,$AC07
	dc.w	$ADBA,$AF73,$B133,$B2F8
	dc.w	$B4C4,$B696,$B86D,$BA4A
	dc.w	$BC2C,$BE14,$C001,$C1F2
	dc.w	$C3E9,$C5E4,$C7E4,$C9E8
	dc.w	$CBF0,$CDFD,$D00D,$D221
	dc.w	$D439,$D654,$D872,$DA94
	dc.w	$DCB8,$DEDF,$E109,$E335
	dc.w	$E563,$E794,$E9C6,$EBFA
	dc.w	$EE30,$F067,$F29F,$F4D8
	dc.w	$F712,$F94D,$FB88,$FDC4
	dc.w	$0000,$023C,$0478,$06B3
	dc.w	$08EE,$0B28,$0D61,$0F99
	dc.w	$11D0,$1406,$163A,$186C
	dc.w	$1A9D,$1CCB,$1EF7,$2121
	dc.w	$2348,$256C,$278E,$29AC
	dc.w	$2BC7,$2DDF,$2FF3,$3203
	dc.w	$3410,$3618,$381C,$3A1C
	dc.w	$3C17,$3E0E,$4000,$41EC
	dc.w	$43D4,$45B6,$4793,$496A
	dc.w	$4B3C,$4D08,$4ECD,$508D
	dc.w	$5246,$53F9,$55A5,$574B
	dc.w	$58EA,$5A82,$5C13,$5D9C
	dc.w	$5F1F,$609A,$620D,$6379
	dc.w	$64DD,$6639,$678D,$68D9
	dc.w	$6A1D,$6B59,$6C8C,$6DB7
	dc.w	$6ED9,$6FF3,$7104,$720C
	dc.w	$730B,$7401,$74EE,$75D2
	dc.w	$76AD,$777F,$7847,$7906
	dc.w	$79BB,$7A67,$7B0A,$7BA2
	dc.w	$7C32,$7CB7,$7D33,$7DA5
	dc.w	$7E0D,$7E6C,$7EC0,$7F0B
	dc.w	$7F4B,$7F82,$7FAF,$7FD2
	dc.w	$7FEB,$7FFA,$7FFF,$7FFA
	dc.w	$7FEB,$7FD2,$7FAF,$7F82
	dc.w	$7F4B,$7F0B,$7EC0,$7E6C
	dc.w	$7E0D,$7DA5,$7D33,$7CB7
	dc.w	$7C32,$7BA2,$7B0A,$7A67
	dc.w	$79BB,$7906,$7847,$777F
	dc.w	$76AD,$75D2,$74EE,$7401
	dc.w	$730B,$720C,$7104,$6FF3
	dc.w	$6ED9,$6DB7,$6C8C,$6B59
	dc.w	$6A1D,$68D9,$678D,$6639
	dc.w	$64DD,$6379,$620D,$609A
	dc.w	$5F1F,$5D9C,$5C13,$5A82
	dc.w	$58EA,$574B,$55A5,$53F9
	dc.w	$5246,$508D,$4ECD,$4D08
	dc.w	$4B3C,$496A,$4793,$45B6
	dc.w	$43D4,$41EC,$4000,$3E0E
	dc.w	$3C17,$3A1C,$381C,$3618
	dc.w	$3410,$3203,$2FF3,$2DDF
	dc.w	$2BC7,$29AC,$278E,$256C
	dc.w	$2348,$2121,$1EF7,$1CCB
	dc.w	$1A9D,$186C,$163A,$1406
	dc.w	$11D0,$0F99,$0D61,$0B28
	dc.w	$08EE,$06B3,$0478,$023C
	dc.w	$0000,$FDC4,$FB88,$F94D
	dc.w	$F712,$F4D8,$F29F,$F067
	dc.w	$EE30,$EBFA,$E9C6,$E794
	dc.w	$E563,$E335,$E109,$DEDF
	dc.w	$DCB8,$DA94,$D872,$D654
	dc.w	$D439,$D221,$D00D,$CDFD
	dc.w	$CBF0,$C9E8,$C7E4,$C5E4
	dc.w	$C3E9,$C1F2,$C001,$BE14
	dc.w	$BC2C,$BA4A,$B86D,$B696
	dc.w	$B4C4,$B2F8,$B133,$AF73
	dc.w	$ADBA,$AC07,$AA5B,$A8B5
	dc.w	$A716,$A57E,$A3ED,$A264
	dc.w	$A0E1,$9F66,$9DF3,$9C87
	dc.w	$9B23,$99C7,$9873,$9727
	dc.w	$95E3,$94A7,$9374,$9249
	dc.w	$9127,$900D,$8EFC,$8DF4
	dc.w	$8CF5,$8BFF,$8B12,$8A2E
	dc.w	$8953,$8881,$87B9,$86FA
	dc.w	$8645,$8599,$84F6,$845E
	dc.w	$83CE,$8349,$82CD,$825B
	dc.w	$81F3,$8194,$8140,$80F5
	dc.w	$80B5,$807E,$8051,$802E
	dc.w	$8015,$8006,$8001,$8006
	dc.w	$8015,$802E,$8051,$807E
	dc.w	$80B5,$80F5,$8140,$8194
	dc.w	$81F3,$825B,$82CD,$8349
	dc.w	$83CE,$845E,$84F6,$8599
	dc.w	$8645,$86FA,$87B9,$8881
	dc.w	$8953,$8A2E,$8B12,$8BFF
	dc.w	$8CF5,$8DF4,$8EFC,$900D
	dc.w	$9127,$9249,$9374,$94A7
	dc.w	$95E3,$9727,$9873,$99C7
	dc.w	$9B23,$9C87,$9DF3,$9F66
	dc.w	$A0E1,$A264,$A3ED,$A57E
	dc.w	$A716,$A8B5,$AA5B,$AC07
	dc.w	$ADBA,$AF73,$B133,$B2F8
	dc.w	$B4C4,$B696,$B86D,$BA4A
	dc.w	$BC2C,$BE14,$C001,$C1F2
	dc.w	$C3E9,$C5E4,$C7E4,$C9E8
	dc.w	$CBF0,$CDFD,$D00D,$D221
	dc.w	$D439,$D654,$D872,$DA94
	dc.w	$DCB8,$DEDF,$E109,$E335
	dc.w	$E563,$E794,$E9C6,$EBFA
	dc.w	$EE30,$F067,$F29F,$F4D8
	dc.w	$F712,$F94D,$FB88,$FDC4
	dc.w	$0000,$023C,$0478,$06B3
	dc.w	$08EE,$0B28,$0D61,$0F99
	dc.w	$11D0,$1406,$163A,$186C
	dc.w	$1A9D,$1CCB,$1EF7,$2121
	dc.w	$2348,$256C,$278E,$29AC
	dc.w	$2BC7,$2DDF,$2FF3,$3203
	dc.w	$3410,$3618,$381C,$3A1C
	dc.w	$3C17,$3E0E,$4000,$41EC
	dc.w	$43D4,$45B6,$4793,$496A
	dc.w	$4B3C,$4D08,$4ECD,$508D
	dc.w	$5246,$53F9,$55A5,$574B
	dc.w	$58EA,$5A82,$5C13,$5D9C
	dc.w	$5F1F,$609A,$620D,$6379
	dc.w	$64DD,$6639,$678D,$68D9
	dc.w	$6A1D,$6B59,$6C8C,$6DB7
	dc.w	$6ED9,$6FF3,$7104,$720C
	dc.w	$730B,$7401,$74EE,$75D2
	dc.w	$76AD,$777F,$7847,$7906
	dc.w	$79BB,$7A67,$7B0A,$7BA2
	dc.w	$7C32,$7CB7,$7D33,$7DA5
	dc.w	$7E0D,$7E6C,$7EC0,$7F0B
	dc.w	$7F4B,$7F82,$7FAF,$7FD2
	dc.w	$7FEB,$7FFA,$7FFF,$7FFA
	dc.w	$7FEB,$7FD2,$7FAF,$7F82
	dc.w	$7F4B,$7F0B,$7EC0,$7E6C
	dc.w	$7E0D,$7DA5,$7D33,$7CB7
	dc.w	$7C32,$7BA2,$7B0A,$7A67
	dc.w	$79BB,$7906,$7847,$777F
	dc.w	$76AD,$75D2,$74EE,$7401
	dc.w	$730B,$720C,$7104,$6FF3
	dc.w	$6ED9,$6DB7,$6C8C,$6B59
	dc.w	$6A1D,$68D9,$678D,$6639
	dc.w	$64DD,$6379,$620D,$609A
	dc.w	$5F1F,$5D9C,$5C13,$5A82
	dc.w	$58EA,$574B,$55A5,$53F9
	dc.w	$5246,$508D,$4ECD,$4D08
	dc.w	$4B3C,$496A,$4793,$45B6
	dc.w	$43D4,$41EC,$4000,$3E0E
	dc.w	$3C17,$3A1C,$381C,$3618
	dc.w	$3410,$3203,$2FF3,$2DDF
	dc.w	$2BC7,$29AC,$278E,$256C
	dc.w	$2348,$2121,$1EF7,$1CCB
	dc.w	$1A9D,$186C,$163A,$1406
	dc.w	$11D0,$0F99,$0D61,$0B28
	dc.w	$08EE,$06B3,$0478,$023C
	dc.w	$0000
m_dot:
	dc.w	$0001,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
m_plus:
	dc.w	$0002,$0000,$7FFF,$7FFF
	dc.w	$7FFF,$0000,$7FFF,$FFFF
	dc.w	$0000,$7FFF,$FFFF,$7FFF
m_asterisk:
	dc.w	$0004,$0000,$7FFF,$7FFF
	dc.w	$7FFF,$0000,$7FFF,$FFFF
	dc.w	$1999,$1999,$E665,$E665
	dc.w	$0000,$7FFF,$FFFF,$7FFF
	dc.w	$E665,$1999,$1999,$E665
m_square:
	dc.w	$0004,$0000,$7FFF,$7FFF
	dc.w	$0000,$0000,$FFFF,$0000
	dc.w	$0000,$FFFF,$FFFF,$FFFF
	dc.w	$0000,$0000,$0000,$FFFF
	dc.w	$FFFF,$0000,$FFFF,$FFFF
m_cross:
	dc.w	$0002,$0000,$7FFF,$7FFF
	dc.w	$FFFF,$0000,$0000,$FFFF
	dc.w	$0000,$0000,$FFFF,$FFFF
m_diamond:
	dc.w	$0004,$9AB0,$7FFF,$5014
	dc.w	$0000,$5014,$7FFF,$0096
	dc.w	$7FFF,$0096,$FFFF,$5014
	dc.w	$FFFF,$5014,$7FFF,$A028
	dc.w	$7FFF,$A028,$0000,$5014
work_out:
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0003,$0007,$0000
	dc.w	$0006,$0000,$0001,$0018
	dc.w	$000C,$0000,$000A,$0001
	dc.w	$0002,$0003,$0004,$0005
	dc.w	$0006,$0007,$0008,$0009
	dc.w	$000A,$0003,$0000,$0003
	dc.w	$0003,$0003,$0000,$0003
	dc.w	$0000,$0003,$0002,$0001
	dc.w	$0001,$0001,$0000,$0000
	dc.w	$0002,$0001,$0001,$0001
	dc.w	$0002,$0005,$0004,$0007
	dc.w	$000D,$0001,$0000,$0063
	dc.w	$0000,$0001,$0001,$0535
	dc.w	$03E7
extnd_out:
	dc.w	$0004,$0000,$001F,$0000
	dc.w	$0000,$0001,$0898,$0001
	dc.w	$0002,$0004,$0002,$0001
	dc.w	$0000,$0000,$0400,$FFFF
	dc.w	$0002,$0000,$0004,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000

nvdi_struct_rom:
		dc.w VERSION
		dc.b DAY
		dc.b MONTH
		dc.w YEAR
		dc.w 0
		dc.l 0
		dc.l fill0
		dc.l wk_tab
		dc.l gdos_path
		dc.l 0
		dc.l 0
		dc.l font_header
		dc.l sys_font
		dc.l color_map
		dc.l work_out
		dc.l extnd_out
		dc.w $0080,$0083,0,0
		dc.l vdi_tab
		dc.l linea_tab
		dc.l 0
		dc.l cursor_cnt
		dc.l 0
		dc.l mouse_buf
		dc.b 0,0,0,0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l search_cookie
		dc.l init_cookie0
		dc.l reset_co
		dc.l init_virt
		dc.l reset_virt
		dc.l Malloc_sys
		dc.l Mfree_sys
		dc.l 0
		dc.l 0
		dc.l load_file
		dc.l load_prg
		dc.l load_NOD
		dc.l unload_NOD
		dc.l init_NOD
		dc.l 0
nvdi_struct_rom_end:



change_vec:
		movem.l   d0-d1/a0,-(a7)
		moveq.l   #-1,d1
		cmpa.l    d1,a1
		beq.s     change_s
		movea.l   d1,a0
		bsr.s     setexc
		move.l    d0,(a1)
		movem.l   (a7),d0-d1/a0
change_s:
		bsr.s     setexc
		movem.l   (a7)+,d0-d1/a0
		rts
setexc:
		movem.l   d1-d2/a1-a2,-(a7)
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		move.w    #5,-(a7)
		trap      #13
		addq.l    #8,a7
		movea.l   d0,a0
		movem.l   (a7)+,d1-d2/a1-a2
		rts
init_gdos:
		lea.l     (screen_d).w,a1
		move.l    #$4E564449,(a1)+ ; 'NVDI'
		clr.l     (a1)+
		clr.b     (a1)+
		move.b    #$03,(a1)+
		clr.w     (a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		movea.l   (sysbase).w,a0
		movea.l   20(a0),a0 ; os_magic
		move.w    120(a0),d0 ; install_drv
		lea.l     (gdos_path).w,a0
		add.w     #'A',d0
		move.b    d0,(a0)+
		move.b    #':',(a0)+
		move.b    #$5C,(a0)+
		move.b    #'G',(a0)+
		move.b    #'E',(a0)+
		move.b    #'M',(a0)+
		move.b    #'S',(a0)+
		move.b    #'Y',(a0)+
		move.b    #'S',(a0)+
		move.b    #$5C,(a0)+
		clr.b     (a0)
		rts
MallocA:
		movem.l   d1-d2/a0-a2,-(a7)
		bsr.w     Malloc_sys
		movem.l   (a7)+,d1-d2/a0-a2
		rts
Mshrink: ; not exported!
		movem.l   d1-d2/a0-a2,-(a7)
		movea.l   d0,a0
		move.l    d1,d0
		bsr.w     Mshrink_sys
		movem.l   (a7)+,d1-d2/a0-a2
		rts
Mfree: ; not exported!
		movem.l   d1-d2/a0-a2,-(a7)
		movea.l   d0,a0
		bsr.w     Mfree_sys
		movem.l   (a7)+,d1-d2/a0-a2
		rts
clear_cpu_cache:
		move.w    (nvdi_cpu_type).w,d0
		cmp.w     #40,d0
		blt.s     clear_cp_020
		move.w    sr,-(a7)
		ori.w     #$0700,sr
		dc.w $f4f8 ; cpusha    bc
		move.w    (a7)+,sr
		rts
clear_cp_020:
		cmpi.w    #20,d0
		blt.s     clear_cp_end
		move.w    sr,-(a7)
		move.l    d0,-(a7)
		ori.w     #$0700,sr
		dc.w $4e7a,$0002 ; movec     cacr,d0
		or.l      #$00000808,d0
		dc.w $4e7b,$0002 ; movec     d0,cacr
		move.l    (a7)+,d0
		move.w    (a7)+,sr
clear_cp_end:
		rts
vdi_blinit:
		move.l    a0,-(a7)
		bsr       copy_nvdi_struct
		move.l    a0,(PixMap_ptr).w
		move.w    #1,(system_b).w
		lea.l     (cursor_cnt).w,a0
		move.l    #V_HID_CNT,(a0)+
		move.l    #vbl_curs,(a0)+ ; write cursor_vbl
		move.l    #con_stat,(a0)+ ; write v52_vec
		move.l    #vt_con,(a0)+ ; write con_vec
		move.l    #vt_rawcon,(a0)+ ; write rawcon_vec
		move.l    #vt_con,(con_stat).w
		lea.l     (call_old).w,a0
		move.l    #dummy_rte,(a0)+
		move.l    #dummy_rte,(a0)+
		lea.l     (call_old2).w,a0
		move.l    #dummy_rte,(a0)+
		move.l    #dummy_rte,(a0)+
		lea.l     (mouse_buf).w,a0
		move.l    #tmp_buff,(a0)+
		move.l    #draw_sprite0,(a0)+
		move.l    #undraw_sprite0,(a0)+
		bsr       init_font
		lea.l     (screen_d).w,a0
		clr.l     12(a0)
		clr.w     (blitter).w
		tst.l     (PixMap_ptr).w
		bne.s     vdi_blinit1
		move.l    d0,-(a7)
		bsr.s     chk_blit
		move.w    d0,(blitter).w
		move.l    (a7)+,d0
vdi_blinit1:
		movea.l   (a7)+,a0
		rts
chk_blit:
		movem.l   d1/a0-a1,-(a7)
		move.w    sr,d1
		ori.w     #$0700,sr
		movea.l   a7,a0
		movea.l   ($00000008).w,a1
		move.l    #bus_err_blit,($00000008).w
		moveq.l   #0,d0
		tst.w     ($FFFF8A00).w
		moveq.l   #2,d0
bus_err_blit:
		move.l    a1,($00000008).w
		movea.l   a0,a7
		move.w    d1,sr
		movem.l   (a7)+,d1/a0-a1
		rts
rez_bps_tab:
		dc.w 1,2,4,8,16
create_f:
		movem.l   d0-d2,-(a7)
		move.w    (modecode).w,d0
		lea.l     (vt52_fal).w,a0
		moveq.l   #7,d1
		and.w     d0,d1
		add.w     d1,d1
		move.w    rez_bps_tab(pc,d1.w),d1
		move.w    d1,(a0)+
		mulu.w    #40,d1
		move.w    #320,d2
		btst      #3,d0
		beq.s     falcon_h1
		add.w     d1,d1
		add.w     d2,d2
falcon_h1:
		btst      #6,d0
		beq.s     falcon_l
		mulu.w    #12,d1
		mulu.w    #12,d2
		divu.w    #10,d1
		divu.w    #10,d2
falcon_l:
		move.w    d1,(a0)+
		move.w    d2,(a0)+
		btst      #7,d0
		beq.s     falcon_v1
		move.w    #200,d2
		moveq.l   #7,d1
		and.w     d0,d1
		bne.s     falcon_h2
		add.w     d2,d2
		bra.s     falcon_h2
falcon_v1:
		btst      #4,d0
		beq.s     falcon_t
		move.w    #$00F0,d2
		btst      #8,d0
		bne.s     falcon_v2
		add.w     d2,d2
		bra.s     falcon_v2
falcon_t:
		move.w    #200,d2
		btst      #8,d0
		beq.s     falcon_v2
		add.w     d2,d2
falcon_v2:
		btst      #6,d0
		beq.s     falcon_h2
		muls.w    #12,d2
		divs.w    #10,d2
falcon_h2:
		move.w    d2,(a0)+
		subq.l    #8,a0
		movem.l   (a7)+,d0-d2
		rts
vt52_rez_tab:
		dc.w 4,160,320,200
		dc.w 2,160,640,200
		dc.w 1,80,640,400
		dc.w 0,0,0,0
		dc.w 4,320,640,480
		dc.w 0,0,0,0
		dc.w 1,160,1280,960
		dc.w 8,320,320,480
vt52_init:
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    (PLANES).w,-(a7)
		move.l    (PixMap_ptr).w,d0
		bne.s     vt52_init1
		moveq.l   #0,d0
		move.b    (sshiftmd).w,d0
		cmp.w     #3,d0
		bne.s     init_vt52_1
		move.w    4(a7),(modecode).w
		bsr       create_f
		bra.s     init_vt52_2
init_vt52_1:
		lsl.w     #3,d0
		lea.l     vt52_rez_tab(pc,d0.w),a0
init_vt52_2:
		move.w    (a0)+,(PLANES).w
		move.w    (a0),(BYTES_LINE).w
		move.w    (a0)+,(WIDTH).w
		move.w    (a0)+,(V_REZ_HZ).w
		move.w    (a0)+,(V_REZ_VT).w
		bra.s     vt52_init2
vt52_init1:
		movea.l   d0,a0
		move.l    (a0),(v_bas_ad).w
		move.w    4(a0),d2
		and.w     #$1FFF,d2
		move.w    d2,(BYTES_LINE).w
		move.w    d2,(WIDTH).w
		move.w    32(a0),(PLANES).w
		move.w    12(a0),d0
		sub.w     8(a0),d0
		move.w    d0,(V_REZ_HZ).w
		move.w    10(a0),d1
		sub.w     6(a0),d1
		move.w    d1,(V_REZ_VT).w
vt52_init2:
		bsr.s     init_vt52_3
		move.w    (a7)+,d0
		tst.w     (system_b).w
		bne.s     vt52_init3
		sub.w     (PLANES).w,d0
		bsr       unload_s
		bsr       load_scr
vt52_init3:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
init_vt52_3:
		movem.l   d0-d3/a0-a2,-(a7)
		move.w    (V_REZ_HZ).w,d0
		move.w    (V_REZ_VT).w,d1
		move.w    (BYTES_LINE).w,d2
		lea.l     header_09,a1
		cmpi.w    #320,d1
		blt.s     init_vt52_4
		lea.l     header_10,a1
init_vt52_4:
		move.l    76(a1),(V_FNT_AD).w
		move.l    72(a1),(V_OFF_AD).w
		move.w    #$100,(V_FNT_WD).w
		move.l    #$00FF0000,(V_FNT_ND).w
		move.w    82(a1),d3
		move.w    d3,(V_CEL_HT).w
		lsr.w     #3,d0
		subq.w    #1,d0
		divu.w    d3,d1
		subq.w    #1,d1
		mulu.w    d3,d2
		movem.w   d0-d2,(V_CEL_MX).w
		move.l    #$0000ff,(V_COL_BG).w
		move.w    #1,(V_HID_CNT).w
		move.w    #$100,(V_STAT_0).w
		move.w    #REQ_COL,(V_PERIOD).w
		move.l    (v_bas_ad).w,(V_CUR_AD).w
		clr.l     (V_CUR_XY).w
		clr.w     (V_CUR_OF).w
		movem.l   (a7)+,d0-d3/a0-a2
		rts
no_offscreen:
	dc.b	'Offscreen-Treiber nicht gefunden.',$0D
	dc.b	$0A,'MCMD wird gestartet...',$0D
	dc.b	$0A,$00
no_screen:
	dc.b	'Bildschirm-Treiber nicht gefunden.',$0D,$0A
	dc.b	'MCMD wird gestartet...',$0D,$0A
	dc.b	$00
empty_cmd:
	dc.b	$00
mcmd_path:
	dc.b	'GEMDESK\MCMD.TOS',0
system_halted:
	dc.b	'System wird angehalten.',$0D,$0A,0
	even


Cconws:
	movem.l	d1-d2/a0-a2,-(a7)
	move.l	a0,-(a7)
	move.w	#$0009,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d1-d2/a0-a2
	rts

vdi_init:
		movem.l   d0-d2/a0-a3/a6,-(a7)
		bsr       search_cookie0
		bsr       init_vdi
		bsr       init_gdos
		jsr       init_NOD
		tst.w     d0
		bne.s     vdi_init2
		tst.l     (PixMap_ptr).w
		bne.s     load_NOD_err
		lea.l     no_offscreen(pc),a0
		jsr       Cconws
		lea.l     -128(a7),a7
		movea.l   a7,a0
		lea.l     (gdos_path).w,a1
		jsr       strgcpy
		movea.l   a7,a0
		lea.l     mcmd_path(pc),a1
		jsr       strgcat
		movea.l   a7,a0
		clr.l     -(a7)
		pea.l     empty_cmd(pc)
		move.l    a0,-(a7)
		clr.w     -(a7)
		move.w    #$4b,-(a7) ; Pexec
		trap      #1
		lea.l     16(a7),a7
		lea.l     128(a7),a7
		lea.l     system_halted(pc),a0
		jsr       Cconws
vdi_init1:
		nop
		bra.s     vdi_init1
load_NOD_err:
		moveq.l   #-1,d0
		movea.l   MSys_BehneError,a0
		jmp       (a0)
vdi_init2:
		bsr       init_font
		bsr.w     load_scr
		lea.l     (screen_d).w,a0
		movea.l   device_wk(a0),a1
		movea.l   (linea_wk).w,a6
		bsr       wk_default
		movea.l   (aes_wk_p).w,a6
		bsr       wk_default
		bsr       init_cookie
		clr.w     (system_b).w
		movem.l   (a7)+,d0-d2/a0-a3/a6
		rts
load_scr:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   (screen_d+device_addr).w,a0
		move.l    a0,d0
		bne       load_scr3
		tst.l     (PixMap_ptr).w
		bne.s     load_scr2
		moveq.l   #0,d0
		move.b    (sshiftmd).w,d0
		move.w    (modecode).w,d1
		lea.l     (gdos_path).w,a0
		bsr.w     load_ATARI_driver
		move.l    a0,d0
		bne.s     load_scr3
		lea.l     no_screen(pc),a0
		jsr       Cconws
		lea.l     -128(a7),a7
		movea.l   a7,a0
		lea.l     (gdos_path).w,a1
		jsr       strgcpy
		movea.l   a7,a0
		lea.l     mcmd_path(pc),a1
		jsr       strgcat
		movea.l   a7,a0
		clr.l     -(a7)
		pea.l     empty_cmd(pc)
		move.l    a0,-(a7)
		clr.w     -(a7)
		move.w    #$4b,-(a7) ; Pexec
		trap      #1
		lea.l     16(a7),a7
		lea.l     128(a7),a7
		lea.l     system_halted(pc),a0
		jsr       Cconws
load_scr1:
		nop
		bra.s     load_scr1
load_scr2:
		movea.l   (PixMap_ptr).w,a0
		lea.l     (gdos_path).w,a1
		bsr.w     load_MAC_driver
		move.l    a0,d0
		bne.s     load_scr3
		moveq.l   #-1,d0
		movea.l   MSys_BehneError,a0
		jmp       (a0)
load_scr3:
		lea.l     (screen_d).w,a3
		move.l    a0,device_addr(a3)
		movea.l   DRVR_init(a0),a2
		lea.l     (nvdi_struct).w,a0
		movea.l   a3,a1
		jsr       (a2)
		move.l    d0,16(a3)
		bne.s     load_scr5
		tst.l     (PixMap_ptr).w
		bne.s     load_scr4
		illegal
load_scr4:
		moveq.l   #-1,d0
		movea.l   MSys_BehneError,a0
		jmp       (a0)
load_scr5:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
unload_s:
		movem.l   d0-d2/a0-a2,-(a7)
		lea.l     (nvdi_struct).w,a0
		lea.l     (screen_d).w,a1
		move.l    device_addr(a1),d0
		beq.s     unload_s1
		movea.l   d0,a2
		movea.l   DRVR_exit(a2),a2
		jsr       (a2)
		tst.w     2(a7)
		beq.s     unload_s1
		lea.l     (screen_d).w,a1
		movea.l   device_addr(a1),a0
		clr.l     device_addr(a1)
		bsr.w     Mfree_sys
unload_s1:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
init_vdi:
		move.l    #WK_SIZE,d0
		bsr.w     Malloc_sys
		move.l    a0,(linea_wk).w
		move.l    #WK_SIZE,d0
		bsr.w     clear_mem
		move.l    #WK_SIZE,d0
		bsr.w     Malloc_sys
		move.l    a0,(aes_wk_p).w
		move.l    a0,(nvdi_aes_wk).w
		move.l    #WK_SIZE,d0
		bsr.w     clear_mem
		move.l    #NVDI_BUFSIZE,d0
		bsr.w     Malloc_sys
		move.l    a0,(scrtchp).w
		move.w    #MAX_HANDLES-1,d0
		lea.l     (wk_tab-4).w,a1
		move.l    (linea_wk).w,(a1)+
make_wk_:
		move.l    #closed,(a1)+
		dbf       d0,make_wk_
		move.w    #$FFFF,(first_de).w
		lea.l     (color_map).w,a1
		move.l    #color_map_tab,(a1)+
		move.l    #color_rev_tab,(a1)+
		movea.l   (sysbase).w,a0
		movea.l   8(a0),a0
		move.l    36(a0),(key_stat).w
		cmpi.w    #$0106,2(a0)
		bge.s     get_act_
		move.l    #make_pling,(bell_hook).w
get_act_:
		cmpi.w    #$100,2(a0)
		bne.s     init_vdi1
		move.l    #$00000E1B,(key_stat).w
init_vdi1:
		rts
init_font:
		movem.l   d0-d2/a0-a2,-(a7)
		moveq.l   #2,d1
		lea.l     (font_header).w,a1
		lea.l     linea_fonts(pc),a2
init_font1:
		move.l    (a2)+,d0
		movea.l   d0,a0
		bsr.s     copy_header
		lea.l     sizeof_FONTHDR(a1),a1
		move.l    a1,-4(a1)
		dbf       d1,init_font1
		clr.l     -4(a1)
		movem.l   (a7)+,d0-d2/a0-a2
		rts
copy_header:
		movem.l   d0/a0-a1,-(a7)
		moveq.l   #((sizeof_FONTHDR/4)-2),d0
copy_header1:
		move.l    (a0)+,(a1)+
		dbf       d0,copy_header1
		movem.l   (a7)+,d0/a0-a1
		rts
copy_nvdi_struct:
		movem.l   d0/a0-a1,-(a7)
		moveq.l   #((nvdi_struct_rom_end-nvdi_struct_rom)/2)-1,d0
		lea.l     nvdi_struct_rom(pc),a0
		lea.l     (nvdi_struct).w,a1
copy_nvdi_struct1:
		move.w    (a0)+,(a1)+
		dbf       d0,copy_nvdi_struct1
		movem.l   (a7)+,d0/a0-a1
		rts
init_cookie:
		move.l    #$4D464D56,d0
		move.l    #MFMV_cookie,d1
		bsr.s     init_cookie0
		rts
init_cookie0:
		movem.l   d0-d1,-(a7)
		move.l    (p_cookie).w,d0
		beq.s     cookie_err2
cookie_jar:
		movea.l   d0,a0
		movea.l   d0,a1
		moveq.l   #0,d0
cookie_search:
		addq.l    #1,d0
		tst.l     (a1)
		addq.l    #8,a1
		bne.s     cookie_search
cookie_err1:
		move.l    -(a1),d1
		subq.l    #4,a1
		cmp.l     d1,d0
		blt.s     cookie_f
		move.l    d1,d2
		subq.l    #1,d2
		bgt.s     cookie_c1
		moveq.l   #0,d1
		moveq.l   #0,d2
cookie_c1:
		addq.l    #8,d1
		move.l    d1,d0
		lsl.l     #3,d0
		bsr       MallocA
		move.l    d0,(p_cookie).w
		beq.s     cookie_err2
		movea.l   d0,a1
		bra.s     cookie_d
cookie_c2:
		move.l    (a0)+,(a1)+
		move.l    (a0)+,(a1)+
cookie_d:
		dbf       d2,cookie_c2
cookie_f:
		move.l    (a7),(a1)+
		move.l    4(a7),(a1)+
		clr.l     (a1)+
		move.l    d1,(a1)+
cookie_err2:
		addq.l    #8,a7
		rts
search_cookie0:
		move.l    #$5F435055,d0
		bsr.w     search_cookie
		move.l    d1,(nvdi_cookie_cpu).w
		sub.w     #20,d1
		spl       d1
		ext.w     d1
		move.w    d1,(cpu020).w
		move.l    #$5F56444F,d0
		bsr.w     search_cookie
		move.l    d1,(nvdi_cookie_vdo).w
		move.l    #$5F4D4348,d0
		bsr.w     search_cookie
		move.l    d1,(nvdi_cookie_mch).w
		rts
search_cookie:
		move.l    (p_cookie).w,d2
		beq.s     search_cookie2
		movea.l   d2,a0
search_cookie1:
		move.l    (a0)+,d2
		beq.s     search_cookie2
		move.l    (a0)+,d1
		cmp.l     d0,d2
		bne.s     search_cookie1
		rts
search_cookie2:
		clr.l     d0
		clr.l     d1
		rts
reset_co:
		move.l    (p_cookie).w,d2
		beq.s     reset_ck3
		movea.l   d2,a0
reset_ck1:
		move.l    (a0)+,d2
		beq.s     reset_ck3
		move.l    (a0)+,d1
		cmp.l     d0,d2
		bne.s     reset_ck1
reset_ck2:
		addq.l    #4,a0
		move.l    (a0)+,-12(a0)
		move.l    -8(a0),-16(a0)
		bne.s     reset_ck2
reset_ck3:
		rts
init_virt:
		rts
reset_virt:
		rts
MFMV_cookie:
		dc.b 'MFMV'
		dc.l      nvdi_struct
		dc.l PixMap_ptr
eddi_dispatch:
		tst.w     d0
		bhi.s     eddi_err
		add.w     d0,d0
		move.w    eddi_tab(pc,d0.w),d0
		jsr       eddi_tab(pc,d0.w)
		rts
eddi_tab:
		dc.w eddi_ver-eddi_tab
eddi_err:
		moveq #-1,d0
		rts
eddi_ver:
		move.w    #$100,d0
		rts
v_contour:
		move.l    #scln_fail,(SEEDABORT).w
seedfill:
		movem.w   (a3),d0-d1
		lea.l     clip_xmin(a6),a0
		cmp.w     (a0)+,d0
		blt.s     Ente
		cmp.w     (a0)+,d1
		blt.s     Ente
		cmp.w     (a0)+,d0
		bgt.s     Ente
		cmp.w     (a0),d1
		bgt.s     Ente
		movea.l   buffer_a(a6),a5
		move.w    d0,14(a5)
		move.w    d1,d7
		move.w    (a2),d0
		cmp.w     colors(a6),d0
		ble.s     tst_indx
Ente:
		rts
tst_indx:
		tst.w     d0
		bge.s     indx_pos
		move.w    (a3)+,d0
		move.w    (a3)+,d1
		movea.l   p_get_pixel(a6),a4
		jsr       (a4)
		move.l    d0,2(a5)
		move.w    #1,(a5)
		bra.s     scan_onc
indx_pos:
		movea.l   p_vdi_to(a6),a4
		jsr       (a4)
		move.l    d0,2(a5)
		clr.w     (a5)
scan_onc:
		lea.l     6(a5),a0
		lea.l     8(a5),a1
		move.w    14(a5),d0
		move.w    d7,d1
		bsr       scanline
		tst.w     d0
		beq.s     Ente
		move.w    d0,22(a5)
		move.w    #3,d5
		clr.w     d6
		move.w    d7,d0
		ori.w     #$8000,d0
		move.w    d0,34(a5)
		move.l    6(a5),36(a5)
		clr.w     20(a5)
		bra.s     lbl250
lbl184:
		addq.w    #3,d6
		cmp.w     d5,d6
		bne.s     lbl1A2
		clr.w     d6
lbl1A2:
		lea.l     34(a5),a0
		adda.w    d6,a0
		adda.w    d6,a0
		cmpi.w    #$FFFF,(a0)
		beq.s     lbl184
		move.w    (a0),d7
		move.w    #$FFFF,(a0)+
		move.l    (a0)+,6(a5)
		addq.w    #3,d6
		cmp.w     d5,d6
		bne.s     lbl228
		bsr       fillabort
lbl228:
		tst.w     20(a5)
		bne       ex_seedf
		movem.w   6(a5),d0/d2
		move.w    d7,d1
		andi.w    #$7FFF,d1
		jsr       fline_sa
lbl250:
		moveq.l   #-1,d1
		tst.w     d7
		bpl.s     lbl262
		moveq.l   #1,d1
lbl262:
		move.w    d1,18(a5)
		lea.l     32(a5),a2
		lea.l     12(a5),a1
		lea.l     10(a5),a0
		add.w     d7,d1
		move.w    6(a5),d0
		bsr       draw_to
		move.w    d0,22(a5)
		move.w    18(a5),26(a5)
		move.w    d0,28(a5)
		move.w    32(a5),30(a5)
		move.w    d7,24(a5)
		bra.s     lbl372
lbl2D4:
		lea.l     30(a5),a2
		lea.l     16(a5),a1
		lea.l     14(a5),a0
		move.w    24(a5),d1
		eori.w    #$8000,d1
		subq.w    #1,14(a5)
		move.w    14(a5),d0
		bsr       draw_to
		move.w    d0,28(a5)
lbl30E:
		move.w    14(a5),d0
		cmp.w     10(a5),d0
		bgt.s     lbl2D4
		move.w    10(a5),d0
		move.w    d0,6(a5)
		subq.w    #1,d0
		cmp.w     14(a5),d0
		ble.s     lbl372
		tst.l     28(a5)
		beq.s     lbl372
lbl346:
		move.w    14(a5),10(a5)
		move.w    26(a5),d0
		add.w     d0,24(a5)
		neg.w     26(a5)
		eori.w    #$8000,24(a5)
lbl372:
		move.w    6(a5),d0
		subq.w    #1,d0
		cmp.w     10(a5),d0
		ble.s     lbl3D2
		tst.l     28(a5)
		beq.s     lbl3D2
		move.w    6(a5),14(a5)
		bra.s     lbl30E
lbl398:
		lea.l     32(a5),a2
		lea.l     12(a5),a1
		lea.l     14(a5),a0
		move.w    d7,d1
		add.w     18(a5),d1
		addq.w    #1,12(a5)
		move.w    12(a5),d0
		bsr       draw_to
		move.w    d0,22(a5)
lbl3D2:
		move.w    12(a5),d0
		cmp.w     8(a5),d0
		blt.s     lbl398
		bra.s     lbl48E
lbl3E4:
		move.w    8(a5),16(a5)
		bra.s     lbl42A
lbl3F0:
		lea.l     32(a5),a2
		lea.l     16(a5),a1
		lea.l     14(a5),a0
		move.w    d7,d1
		eori.w    #$8000,d1
		addq.w    #1,16(a5)
		move.w    16(a5),d0
		bsr.s     draw_to
		move.w    d0,22(a5)
lbl42A:
		move.w    12(a5),d0
		cmp.w     16(a5),d0
		bgt.s     lbl3F0
		move.w    d0,8(a5)
		addq.w    #1,d0
		cmp.w     16(a5),d0
		bge.s     lbl48E
		tst.w     22(a5)
		bne.s     lbl462
		tst.w     32(a5)
		beq.s     lbl48E
lbl462:
		move.w    16(a5),12(a5)
		move.w    18(a5),d0
		add.w     d0,d7
		neg.w     18(a5)
		eori.w    #$8000,d7
lbl48E:
		move.w    8(a5),d0
		addq.w    #1,d0
		cmp.w     12(a5),d0
		bge.s     lbl4B2
		tst.w     22(a5)
		bne.s     lbl3E4
		tst.w     32(a5)
		bne.s     lbl3E4
lbl4B2:
		tst.w     d5
		bne       lbl1A2
ex_seedf:
		rts
drawto_f:
		clr.w     d0
ex_drawt:
		rts
draw_to:
		clr.w     (a2)
		tst.w     20(a5)
		bne.s     drawto_f
		move.w    d1,-(a7)
		and.w     #$7FFF,d1
		bsr       scanline
		tst.w     d0
		bne.s     lbl575
		addq.w    #2,a7
		rts
lbl575:
		moveq.l   #0,d3
		moveq.l   #-1,d4
		lea.l     34(a5),a3
		bra.s     lbl646
lbl576:
		movea.l   a3,a4
		adda.w    d3,a4
		adda.w    d3,a4
		move.l    (a4),d0
		cmp.w     (a0),d0
		bne.s     lbl618
		swap      d0
		cmp.w     #$FFFF,d0
		beq.s     lbl61e
		eori.w    #$8000,d0
		cmp.w     (a7),d0
		bne.s     lbl618
		move.w    (a7)+,d1
		andi.w    #$7FFF,d1
		move.w    (a0),d0
		move.w    (a1),d2
		jsr       fline_sa
		move.w    #$FFFF,(a4)
		addq.w    #3,d3
		cmp.w     d5,d3
		bne.s     lbl60A
		bsr.s     fillabort
lbl60A:
		move.w    #1,(a2)
		clr.w     d0
		rts
lbl618:
		cmpi.w    #$FFFF,(a4)
		bne.s     lbl640
lbl61e:
		cmpi.w    #$FFFF,d4
		bne.s     lbl640
		move.w    d3,d4
lbl640:
		addq.w    #3,d3
lbl646:
		cmp.w     d5,d3
		blt.s     lbl576
		cmpi.w    #$FFFF,d4
		bne.s     lbl686
		addq.w    #3,d5
		cmpi.w    #$0780,d5
		ble.s     lbl690
		move.w    #1,20(a5)
		addq.w    #2,a7
		clr.w     d0
		rts
lbl686:
		move.w    d4,d3
lbl690:
		adda.w    d3,a3
		adda.w    d3,a3
		move.w    (a7)+,(a3)+
		move.w    (a0),(a3)+
		move.w    (a1),(a3)
		moveq.l   #1,d0
		rts
fillabort:
		lea.l     28(a5),a0
		adda.w    d5,a0
		adda.w    d5,a0
		cmpi.w    #$FFFF,(a0)
		bne.s     lbl4FC
		tst.w     d5
		ble.s     lbl4FC
		subq.w    #3,d5
		bra.s     fillabort
lbl4FC:
		cmp.w     d5,d6
		blt.s     ex_filla
		clr.w     d6
		bsr.s     contour_
		move.w    d0,20(a5)
ex_filla:
		rts
contour_:
scln_fail:
		moveq.l   #0,d0
		rts
scanline:
		cmp.w     clip_ymin(a6),d1
		bmi.s     contour_
		cmp.w     clip_ymax(a6),d1
		bgt.s     contour_
		move.w    clip_xmin(a6),d2
		swap      d2
		move.w    clip_xmax(a6),d2
		movea.l   p_scanline(a6),a4
		jmp       (a4)
dummy_rts:
		rts
dummy_rte:
		rte
vq_extnd:
		movea.l   (a0),a1
		cmpi.w    #1,opcode2(a1)
		bne.s     vq_extnd1
		movea.l   pb_intin(a0),a1
		cmpi.w    #2,(a1)
		beq.s     vq_scrninfo
vq_extnd1:
		movem.l   a2-a5,-(a7)
		movea.l   pb_intin(a0),a4
		movem.l   pb_intout(a0),a0-a1
		move.l    device_drv(a6),d0
		beq.s     vq_extnd2
		movea.l   d0,a2
		movea.l   device_addr(a2),a2
		bra.s     vq_extnd3
vq_extnd2:
		movea.l   bitmap_drv(a6),a2
		movea.l   DRIVER_A(a2),a2
vq_extnd3:
		movea.l   DRVR_ext(a2),a3
		tst.w     (a4)
		bne.s     vq_extnd4
		movea.l   DRVR_open(a2),a3
vq_extnd4:
		jsr       (a3)
vq_extnd5:
		movem.l   (a7)+,a2-a5
		rts
vq_scrninfo:
		move.l    a2,-(a7)
		movea.l   (a0),a1
		move.w    #$0110,n_intout(a1)
		clr.w     n_ptsout(a1)
		movea.l   pb_intout(a0),a0
		move.l    device_drv(a6),d0
		beq.s     vq_scrninfo1
		movea.l   d0,a2
		movea.l   device_addr(a2),a2
		bra.s     vq_scrninfo2
vq_scrninfo1:
		movea.l   bitmap_drv(a6),a2
		movea.l   DRIVER_A(a2),a2
vq_scrninfo2:
		movea.l   DRVR_scr(a2),a2
		jsr       (a2)
vq_scrninfo3:
		movea.l   (a7)+,a2
		rts
vq_color:
		movea.l   pb_intout(a0),a1
		movea.l   pb_intin(a0),a0
		move.w    (a0)+,d0
		cmp.w     colors(a6),d0
		bhi.s     vq_color2
		move.w    d0,(a1)+
		movem.l   d1-d2,-(a7)
		move.w    (a0)+,d1
		movea.l   p_get_color(a6),a0
		move.l    a1,-(a7)
		jsr       (a0)
		movea.l   (a7)+,a1
		move.w    d0,(a1)+
		move.w    d1,(a1)+
		move.w    d2,(a1)+
		movem.l   (a7)+,d1-d2
		rts
vq_color2:
		move.w    #$FFFF,(a1)
		rts
vql_attributes:
		movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
		move.w    l_style(a6),d0
		addq.w    #1,d0
		move.w    d0,(a0)+
		move.w    l_color(a6),(a0)+
		move.w    wr_mode(a6),d0
		addq.w    #1,d0
		move.w    d0,(a0)+
		move.l    l_start(a6),(a0)+
		move.w    l_width(a6),(a1)
		rts
vqm_attributes:
		movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
		move.w    m_type(a6),d0
		addq.w    #1,d0
		move.w    d0,(a0)+
		move.w    m_color(a6),(a0)+
		move.w    wr_mode(a6),d0
		addq.w    #1,d0
		move.w    d0,(a0)+
		move.w    m_width(a6),(a1)+
		move.w    m_height(a6),(a1)
		rts
vqf_attributes:
		movea.l   pb_intout(a0),a1
		move.w    f_interior(a6),(a1)+
		move.w    f_color(a6),(a1)+
		move.w    f_style(a6),(a1)+
		move.w    wr_mode(a6),d0
		addq.w    #1,d0
		move.w    d0,(a1)+
		move.w    f_perimeter(a6),(a1)+
		rts
vqt_attributes:
		movem.l   pb_intout(a0),a0-a1 ; intout->a0, ptsout->a1
		move.w    t_number(a6),(a0)+
		move.w    t_color(a6),(a0)+
		move.w    t_rotation(a6),d0
		tst.b     t_font_test(a6)
		bne.s     vqt_attributes1
		mulu.w    #900,d0
vqt_attributes1:
		move.w    d0,(a0)+
		move.l    t_hor(a6),(a0)+
		move.w    wr_mode(a6),d0
		addq.w    #1,d0 ; note: not done by TOS VDI
		move.w    d0,(a0)
		move.l    t_width(a6),(a1)+
		move.l    t_cwidth(a6),(a1)
		rts
vqt_extend:
		movem.l   d1-d3/a2,-(a7)
		movea.l   (a0)+,a1
		move.w    n_intin(a1),d0
		movea.l   (a0),a1 ; a1=intin
		movea.l   pb_ptsout-4(a0),a0
		moveq.l   #0,d1
		moveq.l   #0,d2
		moveq.l   #0,d3
		subq.w    #1,d0
		bmi.s     vqt_ext_7
		movea.l   t_offtab(a6),a2
		tst.b     t_grow(a6)
		beq.s     vqt_ext_4
		move.w    t_iheight(a6),d1
		add.w     d1,d1
		cmp.w     t_cheight(a6),d1
		beq.s     vqt_ext_4
		movem.l   d4-d6,-(a7)
		move.w    t_cheight(a6),d5
		move.w    t_iheight(a6),d6
vqt_ext_1:
		move.w    (a1)+,d1
		sub.w     t_first_ade(a6),d1
		cmp.w     t_ades(a6),d1
		bls.s     vqt_ext_2
		move.w    t_space_ver(a6),d1
vqt_ext_2:
		add.w     d1,d1
		move.w    2(a2,d1.w),d4
		sub.w     0(a2,d1.w),d4
		mulu.w    d5,d4
		divu.w    d6,d4
		add.w     d4,d2
		addq.w    #2,d3
vqt_ext_3:
		dbf       d0,vqt_ext_1
		movem.l   (a7)+,d4-d6
		bra.s     vqt_ext_7
vqt_ext_4:
		move.w    (a1)+,d1
		sub.w     t_first_ade(a6),d1
		cmp.w     t_ades(a6),d1
		bls.s     vqt_ext_5
		move.w    t_space_ver(a6),d1
vqt_ext_5:
		add.w     d1,d1
		add.w     2(a2,d1.w),d2
		sub.w     0(a2,d1.w),d2
		addq.w    #2,d3
vqt_ext_6:
		dbf       d0,vqt_ext_4
		tst.b     t_grow(a6)
		beq.s     vqt_ext_7
		add.w     d2,d2
vqt_ext_7:
		move.w    t_cheight(a6),d1
		move.w    t_effects(a6),d0
		btst      #4,d0
		beq.s     vqt_ext_8
		add.w     d3,d2
		addq.w    #2,d1
vqt_ext_8:
		btst      #2,d0
		beq.s     vqt_ext_9
		add.w     t_whole_width(a6),d2
vqt_ext_9:
		btst      #0,d0
		beq.s     vqt_ext_10
		lsr.w     #1,d3
		mulu.w    t_thicken(a6),d3
		add.w     d3,d2
vqt_ext_10:
		moveq.l   #0,d0
		swap      d2
		clr.w     d2
		swap      d2
		move.w    t_rotation(a6),d3
		bne.s     vqt_ext_11
		move.l    d0,(a0)+
		move.w    d2,(a0)+
		move.l    d2,(a0)+
		move.w    d1,(a0)+
		move.l    d1,(a0)+
		movem.l   (a7)+,d1-d3/a2
		rts
vqt_ext_11:
		subq.w    #1,d3
		bne.s     vqt_ext_12
		move.w    d1,(a0)+
		move.l    d1,(a0)+
		move.w    d2,(a0)+
		move.l    d2,(a0)+
		move.l    d0,(a0)+
		movem.l   (a7)+,d1-d3/a2
		rts
vqt_ext_12:
		subq.w    #1,d3
		bne.s     vqt_ext_13
		move.w    d2,(a0)+
		move.w    d1,(a0)+
		move.l    d1,(a0)+
		move.l    d0,(a0)+
		move.w    d2,(a0)+
		move.w    d0,(a0)+
		movem.l   (a7)+,d1-d3/a2
		rts
vqt_ext_13:
		move.l    d2,(a0)+
		move.l    d0,(a0)+
		move.w    d1,(a0)+
		move.l    d1,(a0)+
		move.w    d2,(a0)+
		movem.l   (a7)+,d1-d3/a2
		rts
vqt_width:
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		movem.l   pb_intout(a0),a0-a1
		move.w    d0,(a0)
		sub.w     t_first_ade(a6),d0
		cmp.w     t_ades(a6),d0
		bls.s     vqt_width1
		move.w    #-1,(a0)
		move.w    t_space_ver(a6),d0
vqt_width1:
		movea.l   t_offtab(a6),a0
		add.w     d0,d0
		adda.w    d0,a0
		moveq.l   #0,d0
		sub.w     (a0)+,d0
		add.w     (a0),d0
		tst.b     t_grow(a6)
		beq.s     vqt_width2
		mulu.w    t_cheight(a6),d0
		divu.w    t_iheight(a6),d0
		and.l     #$0000FFFF,d0
vqt_width2:
		swap      d0
		move.l    d0,(a1)+
		moveq.l   #0,d0
		move.l    d0,(a1)+
		move.l    d0,(a1)+
		rts
vqt_name:
		move.l    d1,-(a7)
		move.l    d2,-(a7)
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		movea.l   pb_intout(a0),a1
		moveq.l   #1,d1
		lea.l     (font_header).w,a0
		subq.w    #1,d0
		ble.s     vqt_name4
		subq.w    #1,d0
		move.l    t_bitmap_addr(a6),d2
		bne.s     vqt_name2
vqt_name1:
		move.l    84(a0),d2
		beq.s     vqt_name6
vqt_name2:
		movea.l   d2,a0
		cmp.w     (a0),d1
		beq.s     vqt_name1
vqt_name3:
		move.w    (a0),d1
		dbf       d0,vqt_name1
vqt_name4:
		move.w    d1,(a1)+
		moveq.l   #7,d0
		addq.l    #4,a0
		moveq.l   #0,d2
vqt_name5:
		move.l    (a0)+,d1
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		movep.l   d1,-7(a1)
		dbf       d0,vqt_name5
		move.l    (a7)+,d2
		move.l    (a7)+,d1
		rts
vqt_name6:
		moveq.l   #1,d1
		lea.l     (font_header).w,a0
		bra.s     vqt_name4
vq_cellarray:
		rts
vqin_mode:
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		movea.l   pb_intout(a0),a1
		subq.w    #1,d0
		cmpi.w    #3,d0
		bhi.s     vqin_mode1
		moveq.l   #1,d1
		btst      d0,input_mode(a6)
		beq.s     vqin_write
		moveq.l   #2,d1
vqin_write:
		move.w    d1,(a1)
		move.l    a0,d1
vqin_mode1:
		rts
vqt_fontinfo:
		movem.l   d1-d4,-(a7)
		movem.l   pb_intout(a0),a1
		move.l    t_first_ade(a6),d0
		add.w     buffer_l(a6),d0 ; ???
		move.l    d0,(a1)+
		movea.l   pb_ptsout(a0),a1
		lea.l     t_height(a6),a0
		moveq.l   #0,d0
		moveq.l   #0,d1
		moveq.l   #0,d4
		move.w    (a0)+,d4
		move.w    (a0)+,(a1)+
		lea.l     t_half(a6),a0
		move.l    d4,d2
		move.w    d4,d3
		sub.w     (a0)+,d2
		sub.w     (a0)+,d3
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		sub.w     d4,d0
		bpl.s     vqt_fi_b
		moveq.l   #0,d0
vqt_fi_b:
		sub.w     d4,d1
		swap      d0
		swap      d1
		swap      d2
		btst      #0,t_effects+1(a6)
		beq.s     vqt_fi_i
		move.w    t_thicken(a6),d0
vqt_fi_i:
		btst      #2,t_effects+1(a6)
		beq.s     vqt_fi_s
		move.w    t_left_offset(a6),d1
		move.w    t_whole_width(a6),d2
		sub.w     d1,d2
vqt_fi_s:
		move.l    d0,(a1)+
		move.l    d1,(a1)+
		move.l    d2,(a1)+
		move.w    d3,(a1)+
		move.l    d4,(a1)+
		movem.l   (a7)+,d1-d4
		rts
vsin_mode:
		movea.l   pb_intin(a0),a1
		move.w    (a1)+,d0
		move.w    (a1),d1
		movea.l   pb_intout(a0),a1
		subq.w    #1,d0
		cmp.w     #3,d0
		bhi.s     vsin_mode2
		move.w    d1,(a1)
		subq.w    #1,d1
		beq.s     vsin_mode1
		move.w    #2,(a1)
		bset      d0,input_mode(a6)
		move.l    a0,d1
		rts
vsin_mode1:
		move.w    #1,(a1)
		bclr      d0,input_mode(a6)
vsin_mode2:
		move.l    a0,d1
		rts
v_locator:
		movea.l   pb_ptsin(a0),a1
v_loc_cl1:
		move.w    (a1)+,d0
		bpl.s     v_loc_cl2
		moveq.l   #0,d0
v_loc_cl2:
		cmp.w     (DEV_TAB).w,d0
		ble.s     v_loc_cl3
		move.w    (DEV_TAB).w,d0
v_loc_cl3:
		move.w    (a1)+,d1
		bpl.s     v_loc_cl4
		moveq.l   #0,d1
v_loc_cl4:
		cmp.w     (DEV_TAB+2).w,d1
		ble.s     v_loc_sa
		move.w    (DEV_TAB+2).w,d1
v_loc_sa:
		movem.w   d0-d1,(GCURX).w
		move.l    a0,d1
		movem.l   pb_intout(a0),a0-a1
		btst      #0,input_mode(a6)
		beq.s     vrq_locator
vsm_locator:
		move.w    sr,d0
		ori.w     #$0700,sr
		move.l    (GCURX).w,(a1)
		move.w    (MOUSE_BT).w,(a0)
		addi.w    #31,(a0)
		movea.l   d1,a0
		movea.l   (a0),a1
		tst.w     (MOUSE_BT).w
		beq.s     vsm_move
		move.w    #1,n_intout(a1)
vsm_move:
		btst      #5,(CUR_MS_STAT).w
		beq.s     vsm_l_ex
		move.w    #1,n_ptsout(a1)
vsm_l_ex:
		andi.b    #$03,(CUR_MS_STAT).w
		move.w    d0,sr
		rts
vrq_locator:
		move.w    (MOUSE_BT).w,d0
		beq.s     vrq_locator
		move.l    (GCURX).w,(a1)
		addi.w    #31,d0
		move.w    d0,(a0)
		rts
v_valuator:
		rts
v_choice:
		movem.l   d1-d2/a2-a4,-(a7)
		movea.l   (a0),a3
		movea.l   pb_intout(a0),a4
		btst      #2,input_mode(a6)
		beq.s     vrq_choice
vsm_choice:
		bsr.s     v_status
		tst.w     d0
		beq.s     vsm_choice2
vrq_choice:
		bsr.s     v_input
		move.l    d0,d1
		swap      d1
		subi.b    #$3B,d1
		cmpi.b    #$09,d1
		bhi.s     v_choice2
		addq.b    #1,d1
		move.b    d1,d0
v_choice2:
		move.w    d0,(a4)
		movem.l   (a7)+,d1-d2/a2-a4
		rts
vsm_choice2:
		clr.w     8(a3)
		movem.l   (a7)+,d1-d2/a2-a4
		rts
v_status:
		move.w    #2,-(a7)
		move.w    #1,-(a7)
		trap      #13
		addq.l    #4,a7
		rts
v_input:
		move.w    #2,-(a7)
		move.w    #2,-(a7)
		trap      #13
		addq.l    #4,a7
		move.l    d0,d1
		swap      d1
		lsl.w     #8,d1
		or.w      d1,d0
		rts
v_string:
		movem.l   d1-d5/a2-a4,-(a7)
		movea.l   (a0)+,a3 ; a3->control
		movea.l   (a0)+,a2 ; a2->intin
		movea.l   4(a0),a4 ; a4->intout
		move.w    #$ff,d3
		move.w    (a2),d4
		bpl.s     v_string2
		neg.w     d4
		moveq.l   #-1,d3
v_string2:
		move.w    d4,d5
		subq.w    #1,d4
		btst      #3,input_mode(a6)
		beq.s     vrq_string
vsm_string:
		bsr.s     v_status
		tst.w     d0
		beq.s     vsm_str_1
		bsr.s     v_input
		and.w     d3,d0
		move.w    d0,(a4)+
		cmpi.b    #$0D,d0
		beq.s     vsm_str_2
		dbf       d4,vsm_string
vsm_str_1:
		addq.w    #1,d4
vsm_str_2:
		sub.w     d4,d5
		move.w    d5,8(a3)
		movem.l   (a7)+,d1-d5/a2-a4
		rts
vrq_string:
		bsr.s     v_input
		and.w     d3,d0
		move.w    d0,(a4)+
		cmpi.b    #$0D,d0
		beq.s     vrq_str_1
		dbf       d4,vrq_string
		addq.w    #1,d4
vrq_str_1:
		sub.w     d4,d5
		move.w    d5,8(a3)
		movem.l   (a7)+,d1-d5/a2-a4
		rts
vsc_form:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a4
		tst.w     n_intin(a1)
		bne.s     vsc_form2
vsc_form1:
		move.w    #37,n_intout(a1)
		lea.l     (M_POS_HX).w,a0
		movea.l   a4,a1
		movem.w   (a0)+,d0-d4
		movem.w   d0-d4,(a1)
		lea.l     10(a1),a1
		movem.w   (a0)+,d0-d7/a2-a5
		movem.w   d0/d2/d4/d6/a2/a4,(a1)
		movem.w   d1/d3/d5/d7/a3/a5,32(a1)
		movem.w   (a0)+,d0-d7/a2-a5
		movem.w   d0/d2/d4/d6/a2/a4,12(a1)
		movem.w   d1/d3/d5/d7/a3/a5,44(a1)
		movem.w   (a0)+,d0-d7
		movem.w   d0/d2/d4/d6,24(a1)
		movem.w   d1/d3/d5/d7,56(a1)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vsc_form2:
		move.w    colors(a6),d5
vsc_form3:
		addq.b    #1,(MOUSE_FLAG).w
		movem.w   (a2)+,d0-d4
vsc_form4:
		cmp.w     d5,d3
		bls.s     vsc_form5
		moveq.l   #1,d3
vsc_form5:
		cmp.w     d5,d4
		bls.s     vsc_form6
		moveq.l   #1,d4
vsc_form6:
		moveq.l   #15,d5
		and.w     d5,d0
		and.w     d5,d1
		movea.l   (color_map).w,a1
		move.b    0(a1,d3.w),d3
		move.b    0(a1,d4.w),d4
		movem.w   d0-d4,(M_POS_HX).w
		lea.l     32(a2),a3
		movem.w   (a2)+,d0/d2/d4/d6/a0/a4
		movem.w   (a3)+,d1/d3/d5/d7/a1/a5
		movem.w   d0-d7/a0-a1/a4-a5,(MASK_FORM).w
		movem.w   (a2)+,d0/d2/d4/d6/a0/a4
		movem.w   (a3)+,d1/d3/d5/d7/a1/a5
		movem.w   d0-d7/a0-a1/a4-a5,(MASK_FORM+24).w
		movem.w   (a2)+,d0/d2/d4/d6
		movem.w   (a3)+,d1/d3/d5/d7
		movem.w   d0-d7,(MASK_FORM+48).w
		move.w    sr,d0
		ori.w     #$0700,sr
		move.l    (GCURX).w,(CUR_X).w
		clr.b     (CUR_FLAG).w
		move.w    d0,sr
		subq.b    #1,(MOUSE_FLAG).w
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vex_timv:
		movea.l   (a0),a1
		movea.l   pb_intout(a0),a0
		move.w    sr,d0
		ori.w     #$0700,sr
		move.l    (USER_TIM).w,d_addr(a1)
		move.l    s_addr(a1),(USER_TIM).w
		move.w    d0,sr
		move.w    (timer_ms).w,(a0)
		rts
v_show_c:
		tst.w     bitmap_w(a6)
		bne.s     v_show_c4
		movea.l   pb_intin(a0),a1
		tst.w     (a1)
		bne.s     v_show_c1
		tst.w     (M_HID_CNT).w
		beq.s     v_show_c4
		move.w    #1,(M_HID_CNT).w
v_show_c1:
		cmpi.w    #1,(M_HID_CNT).w
		bgt.s     v_show_c2
		blt.s     v_show_c3
		movem.l   d1-d7/a2-a5,-(a7)
		move.w    sr,d2
		ori.w     #$0700,sr
		movem.w   (GCURX).w,d0-d1
		clr.b     (CUR_FLAG).w
		move.w    d2,sr
		lea.l     (M_POS_HX).w,a0
		movea.l   (mouse_buf).w,a2
		bsr       draw_sprite ; 8eaa
		movem.l   (a7)+,d1-d7/a2-a5
v_show_c2:
		subq.w    #1,(M_HID_CNT).w
		rts
v_show_c3:
		clr.w     (M_HID_CNT).w
v_show_c4:
		rts
v_hide_c:
		tst.w     bitmap_w(a6)
		bne.s     v_hide_c2
		movem.l   d1-d7/a2-a5,-(a7)
		lea.l     (M_HID_CNT).w,a2
		addq.w    #1,(a2)
		cmpi.w    #1,(a2)
		bne.s     v_hide_c1
		movea.l   (mouse_buf).w,a2
		bsr       undraw_sprite
v_hide_c1:
		movem.l   (a7)+,d1-d7/a2-a5
v_hide_c2:
		rts
vq_mouse:
		movem.l   pb_intout(a0),a0-a1
		move.w    sr,d0
		ori.w     #$0700,sr
		move.l    (GCURX).w,(a1)
		move.w    (MOUSE_BT).w,(a0)
		move.w    d0,sr
		rts
vex_butv:
		movea.l   (a0),a1
		move.l    (USER_BUT).w,d_addr(a1)
		move.l    s_addr(a1),(USER_BUT).w
		rts
vex_motv:
		movea.l   (a0),a1
		move.l    (USER_MOT).w,d_addr(a1)
		move.l    s_addr(a1),(USER_MOT).w
		rts
vex_curv:
		movea.l   (a0),a1
		move.l    (USER_CUR).w,d_addr(a1)
		move.l    s_addr(a1),(USER_CUR).w
		rts
vq_key_s:
		movea.l   pb_intout(a0),a1
		movea.l   (key_stat).w,a0
		moveq.l   #15,d0
		and.b     (a0),d0
		move.w    d0,(a1)
		rts
vro_cpyfm:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a3
		move.w    (a2),d0
		cmp.w     #15,d0
		bhi       vro_cpyfm2
		move.w    d0,r_wmode(a6)
vro_cpyfm1:
		movem.l   s_addr(a1),a4-a5
		movem.w   (a3),d0-d7
vro_sx:
		cmp.w     d0,d2
		bge.s     vro_sy
		exg       d0,d2
vro_sy:
		cmp.w     d1,d3
		bge.s     vro_dx
		exg       d1,d3
vro_dx:
		cmp.w     d4,d6
		bge.s     vro_dy
		exg       d4,d6
vro_dy:
		cmp.w     d5,d7
		bge.s     vro_src
		exg       d5,d7
vro_src:
		move.l    fd_addr(a4),r_saddr(a6)
		beq.s     vro_src_2
		move.w    fd_nplanes(a4),d7
		subq.w    #1,d7
		cmp.w     #7,d7
		bne.s     vro_src_1
		cmp.w     r_planes(a6),d7
		bge.s     vro_src_1
		move.w    r_planes(a6),d7
vro_src_1:
		move.w    d7,r_splanes(a6)
		addq.w    #1,d7
		mulu.w    fd_wdwidth(a4),d7
		add.w     d7,d7
		move.w    d7,r_swidth(a6)
		mulu.w    fd_h(a4),d7
		move.l    d7,r_snxtwork(a6)
		move.l    (v_bas_ad).w,d7
		cmp.l     r_saddr(a6),d7
		bne.s     vro_des
		move.w    fd_w(a4),d7
		cmp.w     (V_REZ_HZ).w,d7
		bne.s     vro_des
		move.w    (PLANES).w,d7
		subq.w    #1,d7
		cmp.w     r_splanes(a6),d7
		bne.s     vro_des
vro_src_2:
		move.l    (v_bas_ad).w,r_saddr(a6)
		move.w    (BYTES_LINE).w,r_swidth(a6)
		move.l    bitmap_length(a6),r_snxtwork(a6)
		move.w    r_planes(a6),r_splanes(a6)
		tst.w     bitmap_w(a6)
		beq.s     vro_des
		move.l    bitmap_addr(a6),r_saddr(a6)
		move.w    bitmap_w(a6),r_swidth(a6)
		sub.w     bitmap_off_x(a6),d0
		sub.w     bitmap_off_y(a6),d1
		sub.w     bitmap_off_x(a6),d2
		sub.w     bitmap_off_y(a6),d3
vro_des:
		move.l    fd_addr(a5),r_daddr(a6)
		beq.s     vro_des_2
		move.w    fd_nplanes(a5),d7
		subq.w    #1,d7
		cmp.w     #7,d7
		bne.s     vro_des_1
		cmp.w     r_planes(a6),d7
		bge.s     vro_des_1
		move.w    r_planes(a6),d7
vro_des_1:
		move.w    d7,r_dplanes(a6)
		addq.w    #1,d7
		mulu.w    fd_wdwidth(a5),d7
		add.w     d7,d7
		move.w    d7,r_dwidth(a6)
		mulu.w    fd_h(a5),d7
		move.l    d7,r_dnxtwork(a6)
		move.l    (v_bas_ad).w,d7
		cmp.l     r_daddr(a6),d7
		bne.s     vro_width
		move.w    fd_w(a5),d7
		cmp.w     (V_REZ_HZ).w,d7
		bne.s     vro_width
		move.w    (PLANES).w,d7
		subq.w    #1,d7
		cmp.w     r_dplanes(a6),d7
		bne.s     vro_width
		move.w    (BYTES_LINE).w,r_dwidth(a6)
		bra.s     vro_width
vro_des_2:
		move.w    d2,d6
		move.w    d3,d7
		sub.w     d0,d6
		sub.w     d1,d7
		add.w     d4,d6
		add.w     d5,d7
		lea.l     clip_xmin(a6),a1
		cmp.w     (a1)+,d4
		bge.s     vro_clip1
		sub.w     -(a1),d4
		sub.w     d4,d0
		move.w    (a1)+,d4
vro_clip1:
		cmp.w     (a1)+,d5
		bge.s     vro_clip2
		sub.w     -(a1),d5
		sub.w     d5,d1
		move.w    (a1)+,d5
vro_clip2:
		sub.w     (a1)+,d6
		ble.s     vro_clip3
		sub.w     d6,d2
vro_clip3:
		sub.w     (a1),d7
		ble.s     vro_desa
		sub.w     d7,d3
vro_desa:
		move.l    (v_bas_ad).w,r_daddr(a6)
		move.w    (BYTES_LINE).w,r_dwidth(a6)
		move.l    bitmap_length(a6),r_dnxtwork(a6)
		move.w    r_planes(a6),r_dplanes(a6)
		move.w    bitmap_w(a6),d7
		beq.s     vro_width
		move.l    bitmap_addr(a6),r_daddr(a6)
		move.w    d7,r_dwidth(a6)
		sub.w     bitmap_off_x(a6),d4
		sub.w     bitmap_off_y(a6),d5
vro_width:
		exg       d2,d4
		exg       d3,d5
		sub.w     d0,d4
		bmi.s     vro_cpyfm2
		sub.w     d1,d5
		bmi.s     vro_cpyfm2
		move.w    r_dplanes(a6),d6
		cmp.w     r_planes(a6),d6
		bne.s     vro_cpyfm3
		movea.l   p_bitblt(a6),a0
		jsr       (a0)
vro_cpyfm2:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vro_cpyfm3:
		tst.w     d6
		bne.s     vro_cpyfm2
		move.l    (mono_bitmap).w,d6
		beq.s     vro_cpyfm2
		movea.l   d6,a0
		jsr       (a0)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vrt_cpyfm:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a3
		move.w    (a2)+,d0
		subq.w    #1,d0
		cmpi.w    #3,d0
		bhi.s     vro_cpyfm2
		move.w    d0,r_wmode(a6)
		move.w    (a2)+,d0
		move.w    (a2)+,d1
		cmp.w     colors(a6),d0
		bls.s     vrt_cpyfm1
		moveq.l   #1,d0
vrt_cpyfm1:
		cmp.w     colors(a6),d1
		bls.s     vrt_cpyfm2
		moveq.l   #1,d1
vrt_cpyfm2:
		move.w    d0,r_fgcol(a6)
		move.w    d1,r_bgcol(a6)
		movem.l   s_addr(a1),a4-a5
		movem.w   (a3),d0-d7
vrt_sx:
		cmp.w     d0,d2
		bge.s     vrt_sy
		exg       d0,d2
vrt_sy:
		cmp.w     d1,d3
		bge.s     vrt_dx
		exg       d1,d3
vrt_dx:
		cmp.w     d4,d6
		bge.s     vrt_dy
		exg       d4,d6
vrt_dy:
		cmp.w     d5,d7
		bge.s     vrt_src
		exg       d5,d7
vrt_src:
		move.l    fd_addr(a4),r_saddr(a6)
		bne.s     vrt_src_1
		move.l    (v_bas_ad).w,r_saddr(a6)
		move.w    (BYTES_LINE).w,r_swidth(a6)
		move.w    r_planes(a6),d7
		clr.w     d7
		tst.w     bitmap_w(a6)
		beq.s     vrt_src_2
		move.l    bitmap_addr(a6),r_daddr(a6)
		move.w    bitmap_w(a6),r_dwidth(a6)
		sub.w     bitmap_off_x(a6),d0
		sub.w     bitmap_off_y(a6),d1
		sub.w     bitmap_off_x(a6),d2
		sub.w     bitmap_off_y(a6),d3
		bra.s     vrt_src_2
vrt_src_1:
		move.w    fd_wdwidth(a4),d7
		add.w     d7,d7
		move.w    d7,r_swidth(a6)
		mulu.w    fd_h(a4),d7
		move.l    d7,r_snxtwork(a6)
		move.w    fd_nplanes(a4),d7
		subq.w    #1,d7
vrt_src_2:
		move.w    d7,r_splanes(a6)
		bne       vrt_cpyfm3
		move.l    fd_addr(a5),r_daddr(a6)
		beq.s     vrt_des_2
		move.w    fd_nplanes(a5),d7
		subq.w    #1,d7
		cmp.w     #7,d7
		bne.s     vrt_des_1
		cmp.w     r_planes(a6),d7
		bge.s     vrt_des_1
		move.w    r_planes(a6),d7
vrt_des_1:
		move.w    d7,r_dplanes(a6)
		addq.w    #1,d7
		mulu.w    fd_wdwidth(a5),d7
		add.w     d7,d7
		move.w    d7,r_dwidth(a6)
		mulu.w    fd_h(a5),d7
		move.l    d7,r_dnxtwork(a6)
		move.l    (v_bas_ad).w,d7
		cmp.l     r_daddr(a6),d7
		bne.s     vrt_width
		move.w    fd_w(a5),d7
		cmp.w     (V_REZ_HZ).w,d7
		bne.s     vrt_width
		move.w    (BYTES_LINE).w,r_dwidth(a6)
		bra.s     vrt_width
vrt_des_2:
		move.w    d2,d6
		move.w    d3,d7
		sub.w     d0,d6
		sub.w     d1,d7
		add.w     d4,d6
		add.w     d5,d7
		lea.l     clip_xmin(a6),a1
		cmp.w     (a1)+,d4
		bge.s     vrt_clip1
		sub.w     -(a1),d4
		sub.w     d4,d0
		move.w    (a1)+,d4
vrt_clip1:
		cmp.w     (a1)+,d5
		bge.s     vrt_clip2
		sub.w     -(a1),d5
		sub.w     d5,d1
		move.w    (a1)+,d5
vrt_clip2:
		sub.w     (a1)+,d6
		ble.s     vrt_clip3
		sub.w     d6,d2
vrt_clip3:
		sub.w     (a1),d7
		ble.s     vrt_desa
		sub.w     d7,d3
vrt_desa:
		move.l    (v_bas_ad).w,r_daddr(a6)
		move.w    (BYTES_LINE).w,r_dwidth(a6)
		move.w    r_planes(a6),r_dplanes(a6)
		move.l    bitmap_length(a6),r_dnxtwork(a6)
		move.w    bitmap_w(a6),d7
		beq.s     vrt_width
		move.l    bitmap_addr(a6),r_daddr(a6)
		move.w    d7,r_dwidth(a6)
		sub.w     bitmap_off_x(a6),d4
		sub.w     bitmap_off_y(a6),d5
vrt_width:
		exg       d2,d4
		exg       d3,d5
		sub.w     d0,d4
		bmi.s     vrt_cpyfm3
		sub.w     d1,d5
		bmi.s     vrt_cpyfm3
		move.w    r_dplanes(a6),d6
		cmp.w     r_planes(a6),d6
		bne.s     vrt_cpyfm4
		movea.l   p_expblt(a6),a0
		jsr       (a0)
vrt_cpyfm3:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vrt_cpyfm4:
		tst.w     d6
		bne.s     vrt_cpyfm3
		move.l    (mono_expblt).w,d6
		beq.s     vrt_cpyfm3
		movea.l   d6,a0
		jsr       (a0)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vr_trnfm:
		movem.l   d1-d7/a2-a5,-(a7)
		movea.l   (a0),a1
		movem.l   s_addr(a1),a0-a1
		movea.l   p_transform(a6),a2
		jsr       (a2)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_get_pixel:
		movem.l   d1-d2/a2,-(a7)
		movea.l   pb_intout(a0),a2
		movea.l   pb_ptsin(a0),a0
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		movea.l   p_get_pixel(a6),a0
		jsr       (a0)
		cmpi.w    #15,r_planes(a6)
		bgt.s     v_get_pixel1
		move.w    d0,(a2)+
		movea.l   p_color_(a6),a0
		jsr       (a0)
		move.w    d0,(a2)+
		movem.l   (a7)+,d1-d2/a2
		rts
v_get_pixel1:
		swap      d0
		move.l    d0,(a2)+
		movem.l   (a7)+,d1-d2/a2
		rts
vswr_mode:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
vswr_mode1:
		move.w    d0,(a0)
		subq.w    #1,d0
		move.w    d0,wr_mode(a6)
		subq.w    #3,d0
		bhi.s     vswr_mode2
		rts
vswr_mode2:
		moveq.l   #1,d0
		bra.s     vswr_mode1
vs_color:
		movem.l   d1-d4,-(a7)
		movem.l   pb_intin(a0),a0
		move.w    (a0)+,d3
		cmp.w     colors(a6),d3
		bhi.s     vs_color8
		move.w    #1000,d4
vs_color1:
		move.w    (a0)+,d0
		bpl.s     vs_color2
		moveq.l   #0,d0
vs_color2:
		cmp.w     d4,d0
		ble.s     vs_color3
		move.w    d4,d0
vs_color3:
		move.w    (a0)+,d1
		bpl.s     vs_color4
		moveq.l   #0,d1
vs_color4:
		cmp.w     d4,d1
		ble.s     vs_color5
		move.w    d4,d1
vs_color5:
		move.w    (a0)+,d2
		bpl.s     vs_color6
		moveq.l   #0,d2
vs_color6:
		cmp.w     d4,d2
		ble.s     vs_color7
		move.w    d4,d2
vs_color7:
		movea.l   p_set_color(a6),a0
		jsr       (a0)
vs_color8:
		movem.l   (a7)+,d1-d4
		rts
vsl_type:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
vsl_type1:
		move.w    d0,(a0)
		subq.w    #1,d0
		move.w    d0,l_style(a6)
		subq.w    #6,d0
		bhi.s     vsl_type2
		rts
vsl_type2:
		moveq.l   #1,d0
		bra.s     vsl_type1
vsl_udstyle:
		movea.l   pb_intin(a0),a1
		move.w    (a1),l_udstyle(a6)
		rts
vsl_width:
		movea.l   pb_ptsin(a0),a1
		movea.l   pb_ptsout(a0),a0
		move.w    (a1),d0
		subq.w    #1,d0
		cmpi.w    #98,d0
		bhi.s     vsl_width2
		or.w      #1,d0
vsl_width1:
		move.w    d0,(a0)
		move.w    d0,l_width(a6)
		rts
vsl_width2:
		tst.w     d0
		bpl.s     vsl_width3
		moveq.l   #1,d0
		bra.s     vsl_width1
vsl_width3:
		moveq.l   #99,d0
		bra.s     vsl_width1
vsl_color:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
		cmp.w     colors(a6),d0
		bhi.s     vsl_color2
vsl_color1:
		move.w    d0,(a0)
		move.w    d0,l_color(a6)
		rts
vsl_color2:
		moveq.l   #1,d0
		bra.s     vsl_color1
vsl_ends:
		movea.l   pb_intin(a0),a1
		move.w    (a1)+,d0
		cmp.w     #2,d0
		bls.s     vsl_ends1
		moveq.l   #0,d0
vsl_ends1:
		move.w    d0,l_start(a6)
		move.w    (a1),d0
		cmp.w     #2,d0
		bls.s     vsl_ends2
		moveq.l   #0,d0
vsl_ends2:
		move.w    d0,l_end(a6)
		rts
vsm_type:
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		movea.l   pb_intout(a0),a1
		move.w    d0,(a1)
		subq.w    #1,d0
		cmpi.w    #5,d0
		bls.s     vsm_type1
		move.w    #3,(a1)
		moveq.l   #2,d0
vsm_type1:
		move.w    m_height(a6),d1
		move.w    d0,m_type(a6)
		add.w     d0,d0
		add.w     d0,d0
		bne.s     vsm_type2
		moveq.l   #1,d1
vsm_type2:
		movea.l   marker_a(pc,d0.w),a1
		move.l    a1,m_data(a6)
		move.w    2(a1),d0
		mulu.w    d1,d0
		swap      d0
		add.w     d1,d0
		move.w    d0,m_width(a6)
		move.l    a0,d1
		rts
marker_a:
		dc.l      m_dot
		dc.l      m_plus
		dc.l      m_asterisk
		dc.l      m_square
		dc.l      m_cross
		dc.l      m_diamond
vsm_height:
		movea.l   pb_ptsin(a0),a1
		move.l    (a1),d1
		subq.w    #1,d1
		or.w      #1,d1
		bgt.s     vsm_height1
		moveq.l   #1,d1
vsm_height1:
		cmp.w     #999,d1
		ble.s     vsm_height2
		move.w    #999,d1
vsm_height2:
		move.w    d1,m_height(a6)
		move.w    m_type(a6),d0
		add.w     d0,d0
		add.w     d0,d0
		bne.s     vsm_height3
		moveq.l   #1,d1
vsm_height3:
		movea.l   marker_a(pc,d0.w),a1
		move.w    2(a1),d0
		mulu.w    d1,d0
		swap      d0
		add.w     d1,d0
		move.w    d0,m_width(a6)
		movea.l   pb_ptsout(a0),a1
		move.w    d0,(a1)+
		move.w    m_height(a6),(a1)
		move.l    a0,d1
		rts
vsm_color:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
		cmp.w     colors(a6),d0
		bls.s     vsm_color1
		moveq.l   #1,d0
vsm_color1:
		move.w    d0,(a0)
		move.w    d0,m_color(a6)
		rts
vdi_fktr:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vst_height3:
		movea.l   pb_ptsout(a0),a1
		move.l    #$00070006,d0
		movea.l   #$00080008,a0
		move.l    d0,(a1)+
		move.l    a0,(a1)+
		lea.l     t_width(a6),a1
		move.l    d0,(a1)+
		move.l    a0,(a1)+
		lea.l     t_base(a6),a1
		move.l    #$00060002,(a1)+ ; t_base=6,t_half=2
		moveq.l   #7,d0
		move.l    d0,(a1)+ ; t_descent=0,t_bottom=7
		swap      d0
		move.l    d0,(a1)+ ; t_ascent=7,t_top=0
		addq.l    #4,a1
		move.l    #$00010008,(a1)+ ; t_left_offset=1,t_whole_width=8
		moveq.l   #0,d0
		move.l    d0,(a1)+ ; t_thicken=0, t_uline=0
		move.w    d0,t_prop(a6)
		lea.l     (font_header+sizeof_FONTHDR).w,a0
		lea.l     t_fonthdr(a6),a1
		move.l    a0,(a1)+
		move.l    a0,(CUR_FONT).w
		lea.l     off_table(a0),a0
		move.l    (a0)+,(a1)+ ; off_table->t_offtab
		move.l    (a0)+,(a1)+ ; dat_table->t_image
		move.l    (a0)+,(a1)+ ; form_width/form_height -> t_iwidth/t_iheight
		rts
vst_height0:
		movea.l   pb_ptsout(a0),a1
		move.l    #$0007000D,d0
		movea.l   #$00080010,a0
		move.l    d0,(a1)+
		move.l    a0,(a1)+
		lea.l     t_width(a6),a1
		move.l    d0,(a1)+
		move.l    a0,(a1)+
		lea.l     t_base(a6),a1
		move.l    #$000D0005,(a1)+
		move.l    #$0002000F,(a1)+
		move.l    #$000F0000,(a1)+
		addq.l    #4,a1
		moveq.l   #0,d0
		move.l    #$00010008,(a1)+
		move.l    d0,(a1)+
		move.w    d0,t_prop(a6)
		lea.l     (font_header+2*sizeof_FONTHDR).w,a0
		lea.l     t_fonthdr(a6),a1
		move.l    a0,(a1)+
		move.l    a0,(CUR_FONT).w
		lea.l     off_table(a0),a0
		move.l    (a0)+,(a1)+ ; off_table->t_offtab
		move.l    (a0)+,(a1)+ ; dat_table->t_image
		move.l    (a0)+,(a1)+ ; form_width/form_height -> t_iwidth/t_iheight
		rts
vst_height:
		movea.l   pb_ptsin(a0),a1
		move.l    (a1),d0
		clr.w     t_point_size(a6)
		cmp.w     t_height(a6),d0
		beq       vst_h_er
vst_h_sa:
		movem.l   d1-d7/a2,-(a7)
		movea.l   16(a0),a2
		move.w    d0,d1
		move.w    t_number(a6),d0
		move.w    d1,d7
		bgt.s     vst_h_st
		moveq.l   #1,d7
vst_h_st:
		movea.l   t_pointer(a6),a0
vst_height2:
		movea.l   a0,a1
		sub.w     top(a1),d1
		beq.s     vst_h_ca
		bpl.s     vst_h_lo
		neg.w     d1
vst_h_lo:
		move.l    next_font(a1),d2
		beq.s     vst_h_ca
		movea.l   d2,a1
		cmp.w     (a1),d0
		bne.s     vst_h_ca
		move.w    d7,d3
		sub.w     top(a1),d3
		bpl.s     vst_h_po
		neg.w     d3
vst_h_po:
		cmp.w     d1,d3
		bgt.s     vst_h_lo
		movea.l   a1,a0
		move.w    d3,d1
		bne.s     vst_h_lo
vst_h_ca:
		move.l    a0,t_fonthdr(a6)
		move.l    a0,(CUR_FONT).w
		movem.l   off_table(a0),d0-d2
		movem.l   d0-d2,t_offtab(a6)
		movem.w   first_ade(a0),d2-d3/d6 ; d2=first_ade, d3=last_ade, d6=top
		btst      #3,flags+1(a0)
		seq       d0
		move.b    d0,t_prop(a6)
		moveq.l   #0,d0
		move.w    d6,d1
		sub.w     d7,d1
		beq.s     vst_h_no
		moveq.l   #1,d0
		tst.w     d1
		bpl.s     vst_h_no
		moveq.l   #-1,d0
vst_h_no:
		move.b    d0,t_grow(a6)
		sub.w     d2,d3
		movem.w   d2-d3,t_first_ade(a6)
		moveq.l   #63,d0
		sub.w     d2,d0
		cmp.w     d3,d0
		bls.s     vst_h_un
		moveq.l   #0,d0
vst_h_un:
		move.w    d0,t_space_ver(a6)
		moveq.l   #32,d0
		sub.w     d2,d0
		cmp.w     d3,d0
		bls.s     vst_h_sp
		moveq.l   #0,d0
vst_h_sp:
		move.w    d0,t_space_hor(a6)
		move.w    left_offset(a0),d0
		move.w    form_height(a0),d5
		mulu.w    d7,d5
		divu.w    d6,d5
		move.w    d5,d4
		move.w    d5,d1
		lsr.w     #1,d1
		movem.w   thicken(a0),d2-d3
		cmp.w     d6,d7
		beq.s     vst_h_th1
		mulu.w    d7,d0
		mulu.w    d7,d2
		mulu.w    d7,d3
		divu.w    d6,d0
		divu.w    d6,d2
		divu.w    d6,d3
vst_h_th1:
		tst.b     t_prop(a6)
		bne.s     vst_h_th2
		moveq.l   #0,d2
vst_h_th2:
		cmp.w     #15,d2
		ble.s     vst_h_ul
		moveq.l   #15,d2
vst_h_ul:
		subq.w    #1,d3
		bpl.s     vst_h_of
		moveq.l   #0,d3
vst_h_of:
		movem.w   d0-d3,t_left_offset(a6) ; t_whole_width/thicken/t_uline
		movem.w   max_char_width(a0),d1/d3
		move.w    d7,d2
		cmp.w     d6,d7
		beq.s     vst_h_pt
		mulu.w    d7,d1
		mulu.w    d7,d3
		divu.w    d6,d1
		divu.w    d6,d3
vst_h_pt:
		movem.w   d1-d4,(a2)
		movem.w   d1-d4,t_width(a6)
		move.w    d7,d0
		move.w    d6,d1
		sub.w     half(a0),d1
		move.w    d6,d2
		sub.w     ascent(a0),d2
		move.w    d4,d3
		subq.w    #1,d3
		move.w    d6,d4
		add.w     descent(a0),d4
		moveq.l   #0,d5
		cmp.w     d6,d7
		beq.s     vst_h_exit
		mulu.w    d7,d1
		mulu.w    d7,d2
		mulu.w    d7,d4
		divu.w    d6,d1
		divu.w    d6,d2
		divu.w    d6,d4
vst_h_exit:
		movem.w   d0-d5,t_base(a6)
		movem.l   (a7)+,d1-d7/a2
		rts
vst_h_er:
		movea.l   pb_ptsout(a0),a1
		move.l    t_width(a6),(a1)+
		move.l    t_cwidth(a6),(a1)+
		rts
vst_point0:
		tst.w     d0
		ble.s     vst_point2
		movem.l   pb_intout(a0),a0-a1
		move.w    d0,(a0)
		move.l    t_width(a6),(a1)+
		move.l    t_cwidth(a6),(a1)+
		rts
vst_point:
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		cmp.w     t_point_size(a6),d0
		beq.s     vst_point0
vst_point2:
		movem.l   d1-d7/a2,-(a7)
		movea.l   d1,a2
		move.w    t_number(a6),d0
		moveq.l   #0,d1
		move.w    (a1),d1
		bgt.s     vst_point3
		moveq.l   #1,d1
		move.w    d1,t_point_size(a6)
vst_point3:
		movea.l   t_pointer(a6),a1
		moveq.l   #-1,d3
vst_p_lo:
		move.l    d1,d5
		move.w    2(a1),d2
		sub.w     d2,d5
		bmi.s     vst_p_ne
		cmp.w     d2,d5
		blt.s     vst_p_cm
		sub.w     d2,d5
		bset      #16,d5
vst_p_cm:
		cmp.w     d3,d5
		bhi.s     vst_p_ne
		bne.s     vst_p_sa
		btst      #16,d5
		bne.s     vst_p_ne
vst_p_sa:
		movea.l   a1,a0
		move.l    d5,d3
		beq.s     vst_p_po
vst_p_ne:
		move.l    84(a1),d2
		beq.s     vst_p_ca
		movea.l   d2,a1
		cmp.w     (a1),d0
		beq.s     vst_p_lo
vst_p_ca:
		addq.l    #1,d3
		bne.s     vst_p_po
		movea.l   t_pointer(a6),a0
		movea.l   a0,a1
		move.w    2(a0),d5
vst_p_sm:
		move.l    84(a1),d2
		beq.s     vst_p_po
		movea.l   d2,a1
		cmp.w     (a1),d0
		bne.s     vst_p_po
		cmp.w     2(a1),d5
		ble.s     vst_p_sm
		move.w    (a1),d5
		movea.l   a1,a0
		bra.s     vst_p_sm
vst_p_po:
		move.w    2(a0),d0
		move.w    40(a0),d7
		btst      #16,d3
		beq.s     vst_set_point
		add.w     d0,d0
		add.w     d7,d7
vst_set_point:
		movem.l   pb_intout(a2),a1-a2
		move.w    d0,(a1)
		move.w    d0,t_point_size(a6)
		bra       vst_h_ca
vst_rotation:
		movea.l   pb_intout(a0),a1
		movea.l   pb_intin(a0),a0
		move.w    (a0),d0
		ext.l     d0
		divs.w    #3600,d0
		swap      d0
		ext.l     d0
		bpl.s     vst_rot_
		addi.l    #3600,d0
vst_rot_:
		addi.w    #450,d0
		divu.w    #900,d0
		move.w    d0,t_rotation(a6)
		mulu.w    #$0384,d0
		move.w    d0,(a1)
		rts
vst_font:
		movea.l   pb_intin(a0),a1
		move.w    (a1),d0
		movea.l   pb_intout(a0),a1
		move.w    d0,(a1)
		cmp.w     t_number(a6),d0
		beq.s     vst_font4
		movem.l   d1-d7/a2,-(a7)
		lea.l     (font_header).w,a0
		cmp.w     #1,d0
		beq.s     vst_font2
		move.l    t_bitmap_addr(a6),d1
		beq.s     vst_font1
		movea.l   d1,a0
vst_font1:
		cmp.w     (a0),d0
		beq.s     vst_font2
		movea.l   84(a0),a0
		move.l    a0,d1
		bne.s     vst_font1
		moveq.l   #1,d0
		lea.l     (font_header).w,a0
		move.w    d0,(a1)
vst_font2:
		move.l    a0,t_pointer(a6)
		move.l    a0,(CUR_FONT).w
		lea.l     (ptsout).w,a2
		move.w    d0,t_number(a6)
		clr.b     t_font_test(a6)
		moveq.l   #0,d1
		move.w    t_point_size(a6),d1
		bne.s     vst_font3
		move.w    t_height(a6),d1
		move.w    d1,d7
		bra       vst_height2
vst_font3:
		lea.l     (vdipb).w,a2
		move.l    #intout,pb_intout(a2)
		move.l    #ptsout,pb_ptsout(a2)
		bra       vst_point3
vst_font4:
		rts
vst_color:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
		cmp.w     colors(a6),d0
		bhi.s     vst_color2
vst_color1:
		move.w    d0,(a0)
		move.w    d0,t_color(a6)
		rts
vst_color2:
		moveq.l   #1,d0
		bra.s     vst_color1
vst_effects:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		moveq.l   #31,d0
		and.w     (a1),d0
		move.w    d0,(a0)
vst_effects1:
		move.w    d0,t_effects(a6)
		rts
vst_alignment:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1)+,d0
		cmpi.w    #2,d0
		bls.s     vst_v_al
		moveq.l   #0,d0
vst_v_al:
		swap      d0
		move.w    (a1),d0
		cmp.w     #5,d0
		bls.s     vst_set_hor
		clr.w     d0
vst_set_hor:
		move.l    d0,t_hor(a6)
		move.l    d0,(a0)
		rts
vsf_int_1:
		moveq.l   #0,d0
		move.w    d0,(a0)
		move.w    d0,f_interior(a6)
		lea.l     f_planes(a6),a0
		clr.w     (a0)
		bra.s     vsf_int_3
vsf_interior:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
vsf_int_2:
		move.w    d0,(a0)
		move.w    d0,f_interior(a6)
		subq.w    #4,d0
		bhi.s     vsf_int_1
		lea.l     f_planes(a6),a0
		clr.w     (a0)
		move.b    vsf_int_tab+4(pc,d0.w),d0
		jmp       vsf_int_7(pc,d0.w)
vsf_int_tab:
		dc.b vsf_int_3-vsf_int_7
		dc.b vsf_int_4-vsf_int_7
		dc.b vsf_int_5-vsf_int_7
		dc.b vsf_int_6-vsf_int_7
		dc.b vsf_int_7-vsf_int_7
		dc.b 0
vsf_int_3:
		move.l    f_fill0(a6),-(a0)
		rts
vsf_int_4:
		move.l    f_fill1(a6),-(a0)
		rts
vsf_int_5:
		movea.l   f_fill2(a6),a1
		move.w    f_style(a6),d0
		subq.w    #1,d0
		lsl.w     #5,d0
		adda.w    d0,a1
		move.l    a1,-(a0)
		rts
vsf_int_6:
		movea.l   f_fill3(a6),a1
		move.w    f_style(a6),d0
		subq.w    #1,d0
		lsl.w     #5,d0
		adda.w    d0,a1
		move.l    a1,-(a0)
		rts
vsf_int_7:
		move.w    f_splanes(a6),(a0)
		move.l    f_spoints(a6),-(a0)
		rts
vsf_style:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    f_interior(a6),d0
		move.b    vsf_style_tab(pc,d0.w),d0
		jmp       vsf_style_tab(pc,d0.w)
vsf_style_tab:
		dc.b vsf_sty_0-vsf_style_tab
		dc.b vsf_sty_1-vsf_style_tab
		dc.b vsf_sty_2-vsf_style_tab
		dc.b vsf_sty_3-vsf_style_tab
		dc.b vsf_sty_4-vsf_style_tab
		dc.b 0
vsf_sty_0:
vsf_sty_1:
vsf_sty_4:
		move.w    (a1),d0
		move.w    d0,(a0)
		move.w    d0,f_style(a6)
		rts
vsf_sty_2:
		move.w    (a1),d0
vsf_sty_2_1:
		move.w    d0,(a0)
		move.w    d0,f_style(a6)
		subq.w    #1,d0
		cmpi.w    #23,d0
		bhi.s     vsf_sty_2_2
		movea.l   f_fill2(a6),a0
		lsl.w     #5,d0
		adda.w    d0,a0
		move.l    a0,f_pointer(a6)
		rts
vsf_sty_2_2:
		moveq.l   #1,d0
		bra.s     vsf_sty_2_1
vsf_sty_3:
		move.w    (a1),d0
vsf_sty_3_1:
		move.w    d0,(a0)
		move.w    d0,f_style(a6)
		subq.w    #1,d0
		cmpi.w    #21,d0
		bhi.s     vsf_sty_3_2
		movea.l   f_fill3(a6),a0
		lsl.w     #5,d0
		adda.w    d0,a0
		move.l    a0,f_pointer(a6)
		rts
vsf_sty_3_2:
		moveq.l   #1,d0
		bra.s     vsf_sty_3_1
vsf_color:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
		cmp.w     colors(a6),d0
		bhi.s     vsf_color2
vsf_color1:
		move.w    d0,(a0)
		move.w    d0,f_color(a6)
		rts
vsf_color2:
		moveq.l   #1,d0
		bra.s     vsf_color1
vsf_perimeter:
		movea.l   pb_intin(a0),a1
		movea.l   pb_intout(a0),a0
		move.w    (a1),d0
		move.w    d0,f_perimeter(a6)
		move.w    d0,(a0)
		rts
vsf_udpat:
		move.l    a2,-(a7)
		movea.l   (a0),a1
		move.w    n_intin(a1),d0
		movea.l   pb_intin(a0),a0
		movea.l   f_spoints(a6),a1
		movea.l   p_set_pattern(a6),a2
		jsr       (a2)
		move.w    d0,f_splanes(a6)
		cmpi.w    #4,f_interior(a6)
		bne.s     vsf_udpat1
		move.w    d0,f_planes(a6)
vsf_udpat1:
		movea.l   (a7)+,a2
		rts
vs_grayo:
		movea.l   pb_intin(a0),a0
		moveq.l   #0,d0
		move.w    (a0),d0
		bpl.s     vs_gor_m
		moveq.l   #0,d0
vs_gor_m:
		cmp.w     #1000,d0
		ble.s     vs_gor_s
		move.w    #1000,d0
vs_gor_s:
		add.w     #62,d0
		divu.w    #125,d0
		bne.s     vs_gor_a
		move.l    f_fill0(a6),f_pointer(a6)
		clr.w     f_planes(a6)
		clr.w     f_interior(a6)
		rts
		beq.s     vs_gor_a
		addq.w    #4,d0
vs_gor_a:
		move.w    #2,f_interior(a6)
		move.w    d0,f_style(a6)
		movea.l   f_fill2(a6),a0
		subq.w    #1,d0
		lsl.w     #5,d0
		adda.w    d0,a0
		move.l    a0,f_pointer(a6)
		clr.w     f_planes(a6)
		rts
v_setrgb:
		rts
v140:
		rts
v_pline_1:
		movem.l   d1-d5/a2-a5,-(a7)
		lea.l     -24(a7),a7
		movea.l   a7,a3
		movea.l   a0,a2
		move.l    pb_ptsin(a2),(a3)
		movea.l   (a2),a0
		move.w    2(a0),12(a3)
		moveq.l   #0,d3
		tst.w     l_start(a6)
		beq.s     no_start
		move.w    2(a0),d0
		movea.l   8(a2),a0
		movea.l   a3,a1
		bsr       dr_start
		moveq.l   #1,d3
		movea.l   8(a2),a5
		movea.l   (a3),a4
		cmpa.l    a4,a5
		beq.s     first_pt
		subq.l    #4,a4
		move.l    a4,(a3)
first_pt:
		move.l    (a4),d4
		move.l    4(a3),(a4)
no_start:
		tst.w     l_end(a6)
		beq.s     no_endfm
		movea.l   (a2),a0
		move.w    2(a0),d0
		movea.l   8(a2),a0
		movea.l   a3,a1
		bsr       dr_endfm
		addq.w    #2,d3
		movea.l   (a2),a0
		move.w    2(a0),d0
		subq.w    #1,d0
		ext.l     d0
		asl.l     #2,d0
		movea.l   8(a2),a5
		adda.l    d0,a5
		move.l    (a5),d5
		move.l    8(a3),(a5)
no_endfm:
		move.w    12(a3),d0
		movea.l   (a3),a0
		bsr.s     fat_line
		tst.w     d3
		beq.s     exit_vpl
		btst      #0,d3
		beq.s     _rest_xy
		move.l    d4,(a4)
_rest_xy:
		btst      #1,d3
		beq.s     exit_vpl
		move.l    d5,(a5)
exit_vpl:
		lea.l     24(a7),a7
		movem.l   (a7)+,d1-d5/a2-a5
		rts
small_line:
		movem.l   d1-d7/a2-a3,-(a7)
		movea.l   a0,a3
		move.w    d0,d4
		subq.w    #2,d4
		bpl       v_plines1
		movem.l   (a7)+,d1-d7/a2-a3
		rts
fat_line:
		cmpi.w    #1,l_width(a6)
		beq.s     small_line
		movem.l   d3-d6/a2-a4,-(a7)
		subq.w    #2,d0
		bmi.s     exit_fat
		lea.l     -16(a7),a7
		movea.l   a7,a4
		movea.l   a0,a2
		move.w    d0,d3
		tst.w     res_ratio(a6)
		beq.s     fat_qpix
		lea.l     -8(a7),a7
		movea.l   a7,a3
		move.w    l_width(a6),d6
		move.w    d6,d4
		cmpi.w    #1,res_ratio(a6)
		bne.s     _fat_STM
		move.w    d4,d5
		asr.w     #1,d4
		add.w     d6,d6
		bra.s     fat_TT_L
_fat_STM:
		asr.w     #1,d4
		move.w    d4,d5
		asr.w     #1,d5
fat_TT_L:
		movea.l   a2,a0
		movea.l   a3,a1
		bsr       conv_pix
		movea.l   a3,a0
		movea.l   a4,a1
		move.w    d6,d0
		bsr       calc_lin
		movea.l   a4,a0
		movea.l   a0,a1
		bsr       conv_q2p
		moveq.l   #4,d0
		movea.l   a4,a0
		bsr       v_fillline
		addq.l    #4,a2
		cmpi.w    #3,l_width(a6)
		ble.s     _fat_whi
		tst.w     d3
		ble.s     _fat_whi
		move.w    d3,-(a7)
		movem.w   (a2),d0-d1
		move.w    d4,d2
		move.w    d5,d3
		bsr       v_fillpie
		move.w    (a7)+,d3
_fat_whi:
		dbf       d3,fat_TT_L
		lea.l     24(a7),a7
exit_fat:
		movem.l   (a7)+,d3-d6/a2-a4
		rts
fat_qpix:
		move.w    l_width(a6),d4
_fat_qpi:
		movea.l   a2,a0
		movea.l   a4,a1
		move.w    d4,d0
		bsr       calc_lin
		moveq.l   #4,d0
		movea.l   a4,a0
		bsr       v_fillline
		addq.l    #4,a2
		cmp.w     #3,d4
		ble.s     _fat_qwh
		tst.w     d3
		ble.s     _fat_qwh
		move.w    d3,-(a7)
		movem.w   (a2),d0-d1
		move.w    d4,d3
		asr.w     #1,d3
		move.w    d3,d2
		bsr       v_fillpie
		move.w    (a7)+,d3
_fat_qwh:
		dbf       d3,_fat_qpi
		lea.l     16(a7),a7
		movem.l   (a7)+,d3-d6/a2-a4
		rts
conv_pix:
		move.w    res_ratio(a6),d0
		cmpi.w    #$FFFF,d0
		bne.s     _pix2q_T
		move.l    (a0)+,d0
		add.w     d0,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		add.w     d0,d0
		move.l    d0,(a1)
		rts
_pix2q_T:
		cmp.w     #1,d0
		bne.s     exit_pix
		move.w    (a0)+,d0
		add.w     d0,d0
		move.w    d0,(a1)+
		move.l    (a0)+,d0
		add.w     d0,d0
		move.l    d0,(a1)+
		move.w    (a0),(a1)
exit_pix:
		rts
conv_q2p:
		move.w    res_ratio(a6),d0
		cmpi.w    #$FFFF,d0
		bne.s     _q2pix_T
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)
		rts
_q2pix_T:
		cmp.w     #1,d0
		bne.s     exit_q2p
		move.w    (a0)+,d0
		asr.w     #1,d0
		move.w    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.l    (a0)+,d0
		asr.w     #1,d0
		move.l    d0,(a1)+
		move.w    (a0),(a1)
exit_q2p:
		rts
calc_lin:
		movem.l   d3-d7/a2-a3,-(a7)
		move.w    d0,d3
		movea.l   a0,a2
		movea.l   a1,a3
		move.w    (a0)+,d1
		ext.l     d1
		move.w    (a0)+,d2
		ext.l     d2
		move.w    (a0)+,d0
		ext.l     d0
		sub.l     d1,d0
		move.w    (a0)+,d1
		ext.l     d1
		sub.l     d2,d1
		move.l    d0,d6
		move.l    d1,d7
		tst.l     d0
		bpl.s     calc_dx_1
		neg.l     d0
calc_dx_1:
		tst.l     d1
		bpl.s     calc_dy_1
		neg.l     d1
calc_dy_1:
		move.l    d0,d4
		move.l    d1,d5
		cmp.w     #$ff,d4
		bgt.s     gross_hy
		cmp.w     #$ff,d5
		bgt.s     gross_hy
		lsl.w     #7,d5
		lsl.w     #7,d4
		move.w    d4,d0
		move.w    d5,d1
gross_hy:
		bsr.s     hypot
		mulu.w    d3,d5
		mulu.w    d3,d4
		divu.w    d0,d5
		lsr.w     #1,d5
		ext.l     d5
		tst.l     d7
		bpl.s     calc_dx_2
		neg.l     d5
calc_dx_2:
		divu.w    d0,d4
		lsr.w     #1,d4
		ext.l     d4
		tst.l     d6
		bpl.s     calc_dy_2
		neg.l     d4
calc_dy_2:
		movea.l   a2,a0
		move.w    (a0)+,d0
		sub.w     d5,d0
		move.w    (a0)+,d1
		add.w     d4,d1
		move.w    (a2)+,d2
		add.w     d5,d2
		move.w    (a2)+,d3
		sub.w     d4,d3
		movem.w   d0-d3,(a3)
		addq.l    #8,a3
		move.w    (a0)+,d0
		add.w     d5,d0
		move.w    (a0),d1
		sub.w     d4,d1
		move.w    (a2)+,d2
		sub.w     d5,d2
		move.w    (a2),d3
		add.w     d4,d3
		movem.w   d0-d3,(a3)
		movem.l   (a7)+,d3-d7/a2-a3
		rts
hypot:
		move.l    d3,-(a7)
		mulu.w    d0,d0
		mulu.w    d1,d1
		add.l     d0,d1
		bne.s     sqrt
		moveq.l   #1,d0 ; WTF? sqrt(0) = 1?
		addq.l    #4,a7
		rts
sqrt:
		moveq.l   #0,d0
		move.l    #$10000000,d2
lblA:
		move.l    d0,d3
		add.l     d2,d3
		lsr.l     #1,d0
		cmp.l     d3,d1
		bcs.s     lbl18
		sub.l     d3,d1
		add.l     d2,d0
lbl18:
		lsr.l     #2,d2
		bne.s     lblA
		cmp.l     d0,d1
		bls.s     exit_hypot
		addq.l    #1,d0
exit_hypot:
		move.l    (a7)+,d3
		rts
dr_start:
		movem.l   d3-d7/a2-a3,-(a7)
		movea.l   a0,a2
		movea.l   a1,a3
		move.w    d0,d3
		move.w    l_start(a6),d0
		cmp.w     #2,d0
		bne.s     _strtfm_1
		move.l    (a2),4(a3)
		move.w    l_width(a6),d2
		cmp.w     #3,d2
		ble.s     exit_str
		asr.w     #1,d2
		move.w    d2,d3
		tst.w     res_ratio(a6)
		beq.s     _strt_el
		bpl.s     _st_ell_
		asr.w     #1,d3
		bra.s     _strt_el
_st_ell_:
		asl.w     #1,d3
_strt_el:
		movem.w   (a2),d0-d1
		bsr       v_fillpie
exit_str:
		movem.l   (a7)+,d3-d7/a2-a3
		rts
_strtfm_1:
		cmp.w     #1,d0
		bne.s     exit_str
		move.w    d3,d0
		bsr       tstlin_f
		move.w    14(a3),d0
		move.w    16(a3),d1
		bsr       hypot
		move.w    l_width(a6),d2
		cmp.w     #1,d2
		bgt.s     _strtfm_2
		moveq.l   #9,d2
		bra.s     _strtfm_3
_strtfm_2:
		tst.w     res_ratio(a6)
		ble.s     _strtfm
		add.w     d2,d2
_strtfm:
		move.w    d2,d3
		add.w     d2,d2
		add.w     d3,d2
_strtfm_3:
		move.w    d2,d3
		mulu.w    14(a3),d2
		mulu.w    16(a3),d3
		divu.w    d0,d2
		divu.w    d0,d3
		tst.w     18(a3)
		beq.s     strt_dx_
		neg.w     d2
strt_dx_:
		tst.w     20(a3)
		beq.s     strt_dy_
		neg.w     d3
strt_dy_:
		lea.l     -16(a7),a7
		movea.l   a7,a0
		move.w    (a2)+,d0
		move.w    (a2),d1
		tst.w     res_ratio(a6)
		beq.s     _strt_qp
		bmi.s     _strt_ST
		add.w     d0,d0
		bra.s     _strt_qp
_strt_ST:
		add.w     d1,d1
_strt_qp:
		move.w    d0,(a0)+
		move.w    d1,(a0)+
		add.w     d2,d0
		add.w     d3,d1
		move.w    d0,d6
		move.w    d1,d7
		move.w    d0,d4
		move.w    d1,d5
		asr.w     #1,d2
		asr.w     #1,d3
		add.w     d3,d0
		sub.w     d2,d1
		sub.w     d3,d4
		add.w     d2,d5
		movem.w   d0-d1/d4-d7,(a0)
		movea.l   a7,a0
		movea.l   a0,a1
		bsr       conv_q2p
		moveq.l   #3,d0
		movea.l   a7,a0
		move.l    12(a0),4(a3)
		bsr       v_fillline
		lea.l     16(a7),a7
		movem.l   (a7)+,d3-d7/a2-a3
		rts
dr_endfm:
		movem.l   d3-d7/a2-a3,-(a7)
		move.w    d0,d3
		subq.w    #1,d0
		ext.l     d0
		asl.l     #2,d0
		adda.l    d0,a0
		movea.l   a0,a2
		movea.l   a1,a3
		move.w    l_end(a6),d0
		cmp.w     #2,d0
		bne.s     _endfm_A
		move.l    (a0),8(a3)
		move.w    l_width(a6),d2
		cmp.w     #3,d2
		ble.s     exit_end
		asr.w     #1,d2
		move.w    d2,d3
		tst.w     res_ratio(a6)
		beq.s     _end_ell2
		bpl.s     _end_ell1
		asr.w     #1,d3
		bra.s     _end_ell2
_end_ell1:
		asl.w     #1,d3
_end_ell2:
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		bsr       v_fillpie
exit_end:
		movem.l   (a7)+,d3-d7/a2-a3
		rts
_endfm_A:
		cmp.w     #1,d0
		bne.s     exit_end
		move.w    12(a1),d0
		bsr       tstlin_b
		move.w    14(a3),d0
		move.w    16(a3),d1
		bsr       hypot
		move.w    l_width(a6),d2
		cmp.w     #1,d2
		bgt.s     _endfm_T
		moveq.l   #9,d2
		bra.s     _endfm_c
_endfm_T:
		tst.w     res_ratio(a6)
		ble.s     _endfm
		add.w     d2,d2
_endfm:
		move.w    d2,d3
		add.w     d2,d2
		add.w     d3,d2
_endfm_c:
		move.w    d2,d3
		mulu.w    14(a3),d2
		mulu.w    16(a3),d3
		divu.w    d0,d2
		divu.w    d0,d3
		tst.w     18(a3)
		beq.s     end_dx_p
		neg.w     d2
end_dx_p:
		tst.w     20(a3)
		beq.s     end_dy_p
		neg.w     d3
end_dy_p:
		lea.l     -16(a7),a7
		movea.l   a7,a0
		move.w    (a2)+,d0
		move.w    (a2),d1
		tst.w     res_ratio(a6)
		beq.s     _end_qpi
		bmi.s     _end_STM
		add.w     d0,d0
		bra.s     _end_qpi
_end_STM:
		add.w     d1,d1
_end_qpi:
		move.w    d0,(a0)+
		move.w    d1,(a0)+
		add.w     d2,d0
		add.w     d3,d1
		move.w    d0,d6
		move.w    d1,d7
		move.w    d0,d4
		move.w    d1,d5
		asr.w     #1,d2
		asr.w     #1,d3
		add.w     d3,d0
		sub.w     d2,d1
		sub.w     d3,d4
		add.w     d2,d5
		movem.w   d0-d1/d4-d7,(a0)
		movea.l   a7,a0
		movea.l   a0,a1
		bsr       conv_q2p
		moveq.l   #3,d0
		movea.l   a7,a0
		move.l    12(a0),8(a3)
		bsr       v_fillline
		lea.l     16(a7),a7
		movem.l   (a7)+,d3-d7/a2-a3
		rts
tstlin_f:
		movem.l   d3-d7,-(a7)
		move.w    d0,d5
		move.l    a0,(a1)
		move.w    d0,12(a1)
		move.w    l_width(a6),d4
		add.w     d4,d4
		add.w     l_width(a6),d4
		ext.l     d4
		movem.w   (a0)+,d0-d1
		subq.w    #2,d5
_fwd_loop:
		moveq.l   #0,d6
		moveq.l   #0,d7
		movem.w   (a0)+,d2-d3
		sub.l     d0,d2
		bpl.s     _fwd_pos1
		neg.l     d2
		moveq.l   #-1,d6
_fwd_pos1:
		sub.l     d1,d3
		bpl.s     _fwd_pos2
		neg.l     d3
		moveq.l   #-1,d7
_fwd_pos2:
		cmp.l     d4,d2
		bge.s     _fwd_fou
		cmp.l     d4,d3
		bge.s     _fwd_fou
_fwd_cnt:
		dbf       d5,_fwd_loop
		addq.w    #1,d5
_fwd_fou:
		subq.l    #4,a0
		move.l    a0,(a1)
		move.w    res_ratio(a6),d0
		bpl.s     _fwd_TTL
		add.w     d3,d3
		bra.s     exit_fwd
_fwd_TTL:
		ble.s     exit_fwd
		add.w     d2,d2
exit_fwd:
		movem.w   d2-d3/d6-d7,14(a1)
		addq.w    #2,d5
		move.w    d5,12(a1)
		movem.l   (a7)+,d3-d7
		rts
tstlin_b:
		movem.l   d3-d7,-(a7)
		move.w    d0,d5
		move.w    l_width(a6),d4
		add.w     d4,d4
		add.w     l_width(a6),d4
		ext.l     d4
		movem.w   (a0),d0-d1
		subq.w    #2,d5
_bk_loop:
		moveq.l   #0,d6
		moveq.l   #0,d7
		subq.l    #4,a0
		movem.w   (a0),d2-d3
		sub.l     d0,d2
		bpl.s     _bk_posd1
		neg.l     d2
		moveq.l   #-1,d6
_bk_posd1:
		sub.l     d1,d3
		bpl.s     _bk_posd2
		neg.l     d3
		moveq.l   #-1,d7
_bk_posd2:
		cmp.l     d4,d2
		bge.s     _bk_found
		cmp.l     d4,d3
		bge.s     _bk_found
_bk_cntr:
		dbf       d5,_bk_loop
		addq.w    #1,d5
_bk_found:
		move.w    res_ratio(a6),d0
		bpl.s     _bk_TTLO
		add.w     d3,d3
		bra.s     exit_bk
_bk_TTLO:
		ble.s     exit_bk
		add.w     d2,d2
exit_bk:
		movem.w   d2-d3/d6-d7,14(a1)
		addq.w    #2,d5
		move.w    d5,12(a1)
		movem.l   (a7)+,d3-d7
		rts
v_pline_2:
		tst.w     n_intin(a1)
		beq       v_pline_1
		cmpi.w    #13,opcode2(a1)
		beq       v_bez
		tst.w     bez_on(a6)
		bne       v_bez
		bra       v_pline_1
v_pline:
		movea.l   (a0),a1
		movep.w   l_start+1(a6),d0
		add.w     l_width(a6),d0
		add.w     n_intin(a1),d0
		subq.w    #1,d0
		bne.s     v_pline_2
v_pline_3:
		move.w    2(a1),d0
		subq.w    #2,d0
		bne.s     v_plines
v_pline1:
		movem.l   d2-d7,-(a7)
		pea.l     v_pline_4(pc)
		move.w    l_style(a6),d0
		add.w     d0,d0
		move.w    l_pattern(a6,d0.w),d6
		movea.l   pb_ptsin(a0),a1
		movem.w   (a1),d0-d3
		cmp.w     d1,d3
		beq       hline
		cmp.w     d0,d2
		beq       vline
		bra       line
v_pline_4:
		movem.l   (a7)+,d2-d7
		move.l    a0,d1
		rts
v_plines:
		bmi.s     v_pline_7
		movem.l   d1-d7/a2-a3,-(a7)
		movea.l   8(a0),a3
		move.w    d0,d4
v_plines1:
		move.w    l_style(a6),d0
		add.w     d0,d0
		movea.w   l_pattern(a6,d0.w),a2
		cmpi.w    #2,wr_mode(a6)
		bne.s     v_pline_5
		not.w     l_lastpix(a6)
v_pline_5:
		movea.w   d4,a0
		movem.w   (a3),d0-d3
		addq.l    #4,a3
		move.w    a2,d6
		pea.l     v_pline_6(pc)
		cmp.w     d1,d3
		beq       hline
		cmp.w     d0,d2
		beq       vline
		bra       line
v_pline_6:
		move.w    a0,d4
		dbf       d4,v_pline_5
		movem.l   (a7)+,d1-d7/a2-a3
v_pline_7:
		clr.w     l_lastpix(a6)
		rts
search_min_max:
		movem.l   d0/d2-d7/a0,-(a7)
		subq.w    #1,d0
		movem.w   (a3),d4-d7
min_max_:
		move.w    (a0)+,d2
		move.w    (a0)+,d3
		cmp.w     d2,d4
		ble.s     search_m1
		move.w    d2,d4
search_m1:
		cmp.w     d3,d5
		ble.s     search_m2
		move.w    d3,d5
search_m2:
		cmp.w     d2,d6
		bge.s     search_m3
		move.w    d2,d6
search_m3:
		cmp.w     d3,d7
		bge.s     search_m4
		move.w    d3,d7
search_m4:
		dbf       d0,min_max_
		movem.w   d4-d7,(a3)
		movem.l   (a7)+,d0/d2-d7/a0
		rts
v_bez:
		movem.l   d1-d7/a2-a5,-(a7)
		move.l    a0,-(a7)
		move.l    l_start(a6),-(a7)
		moveq.l   #0,d5
		moveq.l   #0,d6
		movea.l   (a0),a1
		move.w    n_ptsin(a1),d7
		ble       v_bez_ex
		moveq.l   #-1,d2
		subq.w    #1,d7
		movea.l   pb_ptsout(a0),a3
		move.l    res_x(a6),(a3)
		clr.l     4(a3)
		movea.l   pb_ptsin(a0),a4
		movea.l   pb_intin(a0),a5
		move.w    #2,l_end(a6)
v_bez_lo:
		addq.w    #1,d2
		move.w    a5,d3
		moveq.l   #1,d0
		and.w     #1,d3
		beq.s     v_bezarr
		moveq.l   #-1,d0
v_bezarr:
		moveq.l   #3,d3
		tst.w     d7
		bne.s     v_bez_ar
		move.w    2(a7),l_end(a6)
		and.b     0(a5,d0.w),d3
		bra.s     v_bez_dr
v_bez_ar:
		and.b     0(a5,d0.w),d3
		beq       v_bez_ne
v_bez_dr:
		addq.w    #1,d2
		move.w    d2,d0
		movea.l   a4,a0
		add.w     d2,d2
		add.w     d2,d2
		adda.w    d2,a4
		moveq.l   #-1,d2
		btst      #1,d3
		beq.s     v_bez_li
		subq.w    #1,d0
		addq.w    #1,d6
		cmp.w     #3,d3
		beq.s     v_bez_li
		moveq.l   #0,d2
		subq.l    #4,a4
v_bez_li:
		cmp.w     #2,d0
		blt.s     v_bez_be
		add.w     d0,d5
		bsr       search_min_max
		bsr.s     bez_line
		move.w    #2,l_start(a6)
v_bez_be:
		and.w     #1,d3
		beq.s     v_bez_ne
		subq.w    #3,d7
		blt.s     v_bez_ex
		bne.s     v_bez_sa
		move.w    2(a7),l_end(a6)
v_bez_sa:
		movem.w   d5-d7,-(a7)
		movem.w   -4(a4),d0-d7
		movea.w   bez_qual(a6),a0
		movea.l   buffer_a(a6),a2
		lea.l     1024(a2),a1
		bsr       calc_bez
		movem.w   (a7)+,d5-d7
		add.w     d0,d5
		movea.l   buffer_a(a6),a0
		lea.l     1024(a0),a0
		bsr       search_min_max
		bsr.s     bez_line
		move.w    #2,l_start(a6)
		moveq.l   #-1,d2
		addq.w    #1,d7
		addq.l    #2,a5
		lea.l     8(a4),a4
v_bez_ne:
		addq.l    #1,a5
		dbf       d7,v_bez_lo
v_bez_ex:
		move.l    (a7)+,l_start(a6)
		movea.l   (a7)+,a0
		movea.l   pb_intout(a0),a1
		move.w    d5,(a1)+
		move.w    d6,(a1)+
		movem.l   (a7)+,d1-d7/a2-a5
		rts
bez_line:
		cmpi.b    #3,driver_type(a6) ; DT_OLDNVDI
		bne.s     gdos_line
nvdi_line:
		lea.l     -52(a7),a7
		lea.l     20(a7),a1
		move.l    a0,8(a7)
		move.l    a1,(a7)
		move.l    a7,d1
		movea.l   d1,a0
		move.w    d0,2(a1)
		pea.l     nvdi_line1(pc)
		movep.w   l_start+1(a6),d0
		add.w     l_width(a6),d0
		subq.w    #1,d0
		bne       v_pline_1
		bra       v_pline_3
nvdi_line1:
		lea.l     52(a7),a7
		rts
gdos_line:
		movem.l   d2/a2,-(a7)
		lea.l     -116(a7),a7
		lea.l     20(a7),a1
		move.l    a7,d1
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		movea.l   d1,a0
		move.l    a1,(a0)+
		lea.l     l_start(a6),a2
		move.l    a2,(a0)+
		lea.l     32(a1),a2
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.w    #108,(a1)+ ; vsl_ends
		clr.l     (a1)+
		move.w    #2,(a1)+
		clr.l     (a1)+
		move.w    wk_handle(a6),(a1)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    (a7)+,d0
		movea.l   (a7)+,a2
		move.l    a7,d1
		movea.l   d1,a0
		move.l    a2,pb_ptsin(a0)
		lea.l     20(a0),a1
		move.w    #6,(a1)+ ; v_pline
		move.w    d0,(a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		move.w    wk_handle(a6),(a1)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		lea.l     116(a7),a7
		movem.l   (a7)+,d2/a2
		rts
bez_max_tab:
		dc.w 4,7,13,25,49,97
calc_bez:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.l    a2,-(a7)
		lea.l     1024(a2),a2
		movem.w   d0-d7,(a1)
		moveq.l   #0,d0
		moveq.l   #5,d3
calc_bez1:
		move.w    (a1)+,d1
		ext.l     d1
		move.w    2(a1),d2
		ext.l     d2
		sub.l     d1,d2
		bpl.s     calc_bez2
		neg.l     d2
calc_bez2:
		add.l     d2,d0
		dbf       d3,calc_bez1
		cmp.l     #97,d0
		bge.s     calc_bez4
		move.w    a0,d2
		move.w    d2,d1
		add.w     d1,d1
		lea.l     bez_max_tab+2(pc,d1.w),a0
calc_bq_:
		cmp.w     -(a0),d0
		bge.s     calc_bez3
		dbf       d2,calc_bq_ ; ??? shouldn't that be d3?
		moveq.l   #0,d2
calc_bez3:
		movea.w   d2,a0
calc_bez4:
		subq.l    #8,a1
		movem.w   -4(a1),d0-d3
		swap      d0
		swap      d1
		swap      d2
		swap      d3
		swap      d4
		swap      d5
		swap      d6
		swap      d7
		move.w    #$8000,d0
		move.w    d0,d1
		move.w    d0,d2
		move.w    d0,d3
		move.w    d0,d4
		move.w    d0,d5
		move.w    d0,d6
		move.w    d0,d7
		asr.l     #1,d0
		asr.l     #1,d1
		asr.l     #1,d2
		asr.l     #1,d3
		asr.l     #1,d4
		asr.l     #1,d5
		asr.l     #1,d6
		asr.l     #1,d7
		bsr.s     generate
		movea.l   (a7)+,a2
		move.l    a1,d0
		sub.l     (a7)+,d0
		lsr.w     #2,d0
		cmp.w     #1,d0
		bgt.s     call_bez
		move.l    -4(a1),(a1)+
		addq.w    #1,d0
call_bez:
		movea.l   (a7)+,a0
		rts
generate:
		cmpa.w    #0,a0
		beq.s     bez_out
		subq.w    #1,a0
		movem.l   d6-d7,-(a2)
		add.l     d4,d6
		asr.l     #1,d6
		add.l     d5,d7
		asr.l     #1,d7
		add.l     d2,d4
		asr.l     #1,d4
		add.l     d3,d5
		asr.l     #1,d5
		add.l     d0,d2
		asr.l     #1,d2
		add.l     d1,d3
		asr.l     #1,d3
		movem.l   d6-d7,-(a2)
		add.l     d4,d6
		asr.l     #1,d6
		add.l     d5,d7
		asr.l     #1,d7
		add.l     d2,d4
		asr.l     #1,d4
		add.l     d3,d5
		asr.l     #1,d5
		movem.l   d6-d7,-(a2)
		add.l     d4,d6
		asr.l     #1,d6
		add.l     d5,d7
		asr.l     #1,d7
		movem.l   d6-d7,-(a2)
		bsr.s     generate
		movem.l   (a2)+,d0-d7
		bsr.s     generate
		addq.w    #1,a0
		rts
bez_out:
		swap      d2
		rol.l     #1,d2
		move.w    d2,(a1)+
		swap      d3
		rol.l     #1,d3
		move.w    d3,(a1)+
		swap      d2
		move.w    d3,d2
		cmp.l     -8(a1),d2
		bne.s     bez_out_1
		subq.l    #4,a1
bez_out_1:
		swap      d4
		rol.l     #1,d4
		move.w    d4,(a1)+
		swap      d5
		rol.l     #1,d5
		move.w    d5,(a1)+
		swap      d4
		move.w    d5,d4
		cmp.l     -8(a1),d4
		bne.s     bez_out_2
		subq.l    #4,a1
bez_out_2:
		swap      d6
		rol.l     #1,d6
		move.w    d6,(a1)+
		swap      d7
		rol.l     #1,d7
		move.w    d7,(a1)+
		swap      d6
		move.w    d7,d6
		cmp.l     -8(a1),d6
		bne.s     bez_out_3
		subq.l    #4,a1
bez_out_3:
		rts
v_pmarker:
		movem.l   d1-d7/a2,-(a7)
		move.w    l_color(a6),-(a7)
		move.w    m_color(a6),l_color(a6)
		movem.l   (a0),a0-a2
		move.w    2(a0),d5
		subq.w    #1,d5
		bmi.s     v_pm_exit
		tst.w     m_type(a6)
		beq.s     v_pmarker3
		movea.l   m_data(a6),a0
		lea.l     -64(a7),a7
		movea.l   a7,a1
		bsr.w     v_pmbuild
v_pmarker1:
		move.w    (a2)+,d0
		move.w    (a2)+,d1
		move.w    d0,d2
		move.w    d1,d3
		movea.l   a7,a0
		move.w    (a0)+,d4
		move.w    d5,-(a7)
v_pmarker2:
		movem.w   d0-d4,-(a7)
		add.w     (a0)+,d0
		add.w     (a0)+,d1
		add.w     (a0)+,d2
		add.w     (a0)+,d3
		moveq.l   #-1,d6
		bsr       line
		movem.w   (a7)+,d0-d4
		dbf       d4,v_pmarker2
		move.w    (a7)+,d5
		dbf       d5,v_pmarker1
		lea.l     64(a7),a7
v_pm_exit:
		move.w    (a7)+,l_color(a6)
		movem.l   (a7)+,d1-d7/a2
		rts
v_pmarker3:
		move.w    d5,-(a7)
		move.w    (a2)+,d0
		move.w    (a2)+,d1
		move.w    d1,d3
		moveq.l   #-1,d6
		bsr       vline
		move.w    (a7)+,d5
		dbf       d5,v_pmarker3
		move.w    (a7)+,l_color(a6)
		movem.l   (a7)+,d1-d7/a2
		rts
v_pmbuild:
		move.w    (a0)+,d0
		subq.w    #1,d0
		move.w    d0,(a1)+
		add.w     d0,d0
		addq.w    #1,d0
		addq.l    #2,a0
		move.w    m_width(a6),d1
		move.w    (a0)+,d2
		mulu.w    d1,d2
		swap      d2
		move.w    (a0)+,d3
		mulu.w    d1,d3
		swap      d3
v_pmbuild1:
		move.w    (a0)+,d4
		mulu.w    d1,d4
		swap      d4
		sub.w     d2,d4
		move.w    d4,(a1)+
		move.w    (a0)+,d4
		mulu.w    d1,d4
		swap      d4
		sub.w     d3,d4
		move.w    d4,(a1)+
		dbf       d0,v_pmbuild1
		rts
v_gtext:
		movem.l   d1-d7/a2-a5,-(a7)
v_gtext_1:
		movem.l   (a0),a1-a3
v_gtext_2:
		movea.l   p_gtext(a6),a4
		jsr       (a4)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_fillpie:
		movem.l   d3-d7/a2-a5,-(a7)
		move.l    f_color(a6),-(a7)
		move.w    f_planes(a6),-(a7)
		move.l    f_pointer(a6),-(a7)
		move.w    l_color(a6),f_color(a6)
		move.w    #1,f_interior(a6)
		clr.w     f_planes(a6)
		move.l    f_fill1(a6),f_pointer(a6)
		bsr       fellipse
		move.l    (a7)+,f_pointer(a6)
		move.w    (a7)+,f_planes(a6)
		move.l    (a7)+,f_color(a6)
		movem.l   (a7)+,d3-d7/a2-a5
		rts
v_fillline:
		move.l    f_color(a6),-(a7)
		move.w    f_perimeter(a6),-(a7)
		move.w    f_planes(a6),-(a7)
		move.l    f_pointer(a6),-(a7)
		movem.l   d1-d7/a2-a5,-(a7)
		move.w    l_color(a6),f_color(a6)
		moveq.l   #1,d1
		move.w    d1,f_interior(a6)
		move.w    d1,f_perimeter(a6)
		clr.w     f_planes(a6)
		move.l    f_fill1(a6),f_pointer(a6)
		movea.l   a0,a3
		move.w    d0,d4
		subq.w    #1,d4
		bsr.s     v_fillarray3
		movem.l   (a7)+,d1-d7/a2-a5
		move.l    (a7)+,f_pointer(a6)
		move.w    (a7)+,f_planes(a6)
		move.w    (a7)+,f_perimeter(a6)
		move.l    (a7)+,f_color(a6)
		rts
v_fillarray:
		movea.l   (a0),a1
		tst.w     n_intin(a1)
		beq.s     v_fillarray1
		cmpi.w    #13,opcode2(a1)
		beq       v_bez_fi
		tst.w     bez_on(a6)
		bne       v_bez_fi
v_fillarray1:
		movem.l   d1-d7/a2-a5,-(a7)
		pea.l     vdi_fktr(pc)
		movem.l   (a0),a1-a3
		move.w    2(a1),d0
		subq.w    #1,d0
		ble       fpoly_ex
		cmpi.w    #1,d0
		beq       v_fae_li
		cmpi.w    #3,d0
		beq       v_fae_bo1
		cmpi.w    #4,d0
		beq       v_fae_bo
v_fillarray2:
		move.w    2(a1),d4
		subq.w    #1,d4
v_fillarray3:
		cmpi.w    #$03FF,d4
		bhi       fpoly_ex
		subq.w    #1,d4
		move.w    d4,d6
		movea.l   buffer_a(a6),a5
		move.w    #$7FFF,d5
		moveq.l   #0,d7
		movea.l   (a3),a4
vfa_minmax:
		move.l    (a3)+,d0
		cmp.w     d0,d5
		ble.s     vfa_max
		move.w    d0,d5
vfa_max:
		cmp.w     d0,d7
		bge.s     vfa_x2_y
		move.w    d0,d7
vfa_x2_y:
		move.l    (a3),d2
		cmp.w     d0,d2
		bge.s     vfa_x1_y
		exg       d0,d2
vfa_x1_y:
		move.l    d0,(a5)+
		move.w    d2,d3
		sub.w     d0,d3
		swap      d0
		swap      d2
		sub.w     d0,d2
		add.w     d2,d2
		move.w    d2,(a5)+
		move.w    d3,(a5)+
		dbf       d6,vfa_minmax
		move.l    (a3)+,d0
		cmp.w     d0,d5
		ble.s     vfa_max2
		move.w    d0,d5
vfa_max2:
		cmp.w     d0,d7
		bge.s     vfa_last
		move.w    d0,d7
vfa_last:
		cmpa.l    d0,a4
		beq.s     vfa_call
		move.l    a4,d2
		cmp.w     d0,d2
		bpl.s     vfill_ss
		exg       d0,d2
vfill_ss:
		move.l    d0,(a5)+
		move.w    d2,d3
		sub.w     d0,d3
		swap      d0
		swap      d2
		sub.w     d0,d2
		add.w     d2,d2
		move.w    d2,(a5)+
		move.w    d3,(a5)+
		addq.w    #1,d4
vfa_call:
		movea.l   buffer_a(a6),a4
fpoly:
		move.w    clip_ymin(a6),d1
		move.w    clip_ymax(a6),d3
		cmp.w     d3,d5
		bgt.s     fpoly_ex
		cmp.w     d1,d7
		blt.s     fpoly_ex
		cmp.w     d1,d5
		bge.s     fpoly_cl
		move.w    d1,d5
fpoly_cl:
		cmp.w     d3,d7
		ble.s     fpoly_co
		move.w    d3,d7
fpoly_co:
		sub.w     d5,d7
fpoly_lo:
		movea.l   a4,a0
		movea.l   a5,a1
		movem.w   d4-d5/d7,-(a7)
		bsr.s     fpoly_hl
		movem.w   (a7)+,d4-d5/d7
		addq.w    #1,d5
		dbf       d7,fpoly_lo
		tst.w     f_perimeter(a6)
		beq.s     fpoly_ex
		move.w    l_color(a6),-(a7)
		move.w    f_color(a6),l_color(a6)
		cmpi.w    #2,wr_mode(a6)
		bne.s     fpoly_bo
		not.w     l_lastpix(a6)
fpoly_bo:
		movea.w   d4,a0
		movem.w   (a4)+,d0-d3
		asr.w     #1,d2
		add.w     d0,d2
		add.w     d1,d3
		moveq.l   #-1,d6
		pea.l     fpoly_br(pc)
		cmp.w     d1,d3
		beq       hline
		cmp.w     d0,d2
		beq       vline
		bra       line
fpoly_br:
		move.w    a0,d4
		dbf       d4,fpoly_bo
		clr.w     l_lastpix(a6)
		move.w    (a7)+,l_color(a6)
fpoly_ex:
		rts
fpoly_hl:
		movea.l   a1,a3
fpoly_ca:
		move.w    d5,d1
		move.w    (a0)+,d0
		sub.w     (a0)+,d1
		move.w    (a0)+,d2
		move.w    (a0)+,d3
		beq.s     fpoly_ne
		cmp.w     d1,d3
		bls.s     fpoly_ne
		muls.w    d1,d2
		divs.w    d3,d2
		bmi.s     fpoly_sa
		addq.w    #1,d2
fpoly_sa:
		asr.w     #1,d2
		add.w     d0,d2
		move.w    d2,(a1)+
fpoly_ne:
		dbf       d4,fpoly_ca
		move.l    a1,d6
		sub.l     a3,d6
		subq.w    #4,d6
		bne.s     fpoly_po
		move.w    (a3)+,d0
		move.w    (a3)+,d2
		move.w    d5,d1
		bra       fline
fpoly_po:
		tst.w     d6
		bmi.s     fpoly_hl2
		addq.w    #4,d6
		lsr.w     #1,d6
		move.w    d6,d1
		subq.w    #2,d1
fpoly_bu1:
		move.w    d1,d0
		movea.l   a3,a1
fpoly_bu2:
		move.w    (a1)+,d2
		cmp.w     (a1),d2
		ble.s     fpoly_bu3
		move.w    (a1),-2(a1)
		move.w    d2,(a1)
fpoly_bu3:
		dbf       d0,fpoly_bu2
		dbf       d1,fpoly_bu1
		movea.w   d5,a2
		lsr.w     #1,d6
		subq.w    #1,d6
fpoly_dr:
		movea.w   d6,a0
		move.w    (a3)+,d0
		move.w    (a3)+,d2
		move.w    a2,d1
		bsr       fline
		move.w    a0,d6
		dbf       d6,fpoly_dr
fpoly_hl2:
		rts
v_fae_bo:
		move.l    (a3),d0
		sub.l     16(a3),d0
		bne       v_fillarray2
v_fae_bo1:
		movem.w   (a3),d0-d7
		cmp.w     d1,d3
		bne.s     v_fa_tes
		cmp.w     d0,d6
		bne       v_fillarray2
		cmp.w     d2,d4
		bne       v_fillarray2
		cmp.w     d5,d7
		bne       v_fillarray2
		move.w    d5,d3
		bra.s     v_fa_per
v_fa_tes:
		cmp.w     d0,d2
		bne       v_fillarray2
		cmp.w     d1,d7
		bne       v_fillarray2
		cmp.w     d4,d6
		bne       v_fillarray2
		cmp.w     d3,d5
		bne       v_fillarray2
		move.w    d4,d2
v_fa_per:
		cmp.w     d1,d3
		bge.s     v_fa_per1
		exg       d1,d3
v_fa_per1:
		tst.w     f_perimeter(a6)
		bne       v_bar2
		cmp.w     d1,d3
		beq       fbox
		addq.w    #1,d1
		subq.w    #1,d3
		bra       fbox
v_fae_li:
		movem.w   (a3),d0-d3
		movea.l   f_pointer(a6),a0
		move.w    (a0),d6
		move.w    l_color(a6),-(a7)
		move.w    f_color(a6),l_color(a6)
		bsr       line
		move.w    (a7)+,l_color(a6)
v_cellarray:
		rts
bez_pnt_tab:
		dc.w 4,7,13,25,49,97

v_bez_fi:
		movem.l   d1-d7/a2-a5,-(a7)
		movea.l   (a0),a1
		moveq.l   #0,d7
		move.w    2(a1),d7
		cmp.w     #3,d7
		blt       v_bezf_e
		move.l    bez_buf_(a6),d0
		bne.s     v_bezf_m
		movea.l   buffer_a(a6),a1
		move.l    buffer_l(a6),d0
v_bezf_m:
		move.l    d7,d1
		lsl.l     #3,d1
		add.l     d7,d1
		add.l     #MAX_PTS,d1
		cmp.l     d0,d1
		ble.s     v_bezf_s1
		move.l    d0,d7
		sub.l     #MAX_PTS,d7
		divu.w    #9,d7
v_bezf_s1:
		move.w    bez_qual(a6),-(a7)
		movea.l   8(a0),a4
		movea.l   pb_intin(a0),a0
		movea.l   a1,a2
		adda.l    d0,a2
		lea.l     -1024(a2),a2
		movea.l   a2,a5
		move.w    d7,d0
		addq.w    #1,d0
		and.w     #$FFFE,d0
		suba.w    d0,a5
		subq.w    #1,d7
		move.w    d7,d0
		lsr.w     #1,d0
		movea.l   a5,a3
v_bezf_s2:
		move.w    (a0)+,d1
		and.w     #$0303,d1
		rol.w     #8,d1
		move.w    d1,(a3)+
		dbf       d0,v_bezf_s2
		movea.l   a5,a0
		move.w    d7,d0
		moveq.l   #0,d2
		move.w    d7,d2
		addq.w    #1,d2
		moveq.l   #0,d3
v_bezf_p1:
		moveq.l   #1,d1
		and.b     (a0)+,d1
		beq.s     v_bezf_p2
		subq.w    #2,d0
		bmi.s     v_bezfq_
		subq.w    #3,d2
		addq.w    #1,d3
		addq.l    #2,a0
v_bezf_p2:
		dbf       d0,v_bezf_p1
v_bezfq_:
		move.w    bez_qual(a6),d0
		move.l    a5,d4
		sub.l     a1,d4
		lsl.l     #3,d2
		sub.l     d2,d4
		lea.l     bez_pnt_tab(pc),a0
v_bezf_q:
		move.w    d0,d1
		add.w     d1,d1
		move.w    0(a0,d1.w),d1
		mulu.w    d3,d1
		lsl.l     #3,d1
		cmp.l     d4,d1
		ble.s     v_bezf_s3
		subq.w    #1,d0
		bpl.s     v_bezf_q
		moveq.l   #0,d0
v_bezf_s3:
		move.w    d0,bez_qual(a6)
		moveq.l   #0,d6
		movea.l   a4,a3
		andi.b    #$01,(a5)
v_bezf_l1:
		move.l    (a4)+,d0
		move.l    (a4),d2
		tst.w     d7
		bne.s     v_bezf_c
		move.l    (a3),d2
		move.l    a4,d4
		subq.l    #8,d4
		cmp.l     a3,d4
		beq.s     v_bezf_c
		cmp.l     d0,d2
		beq       v_bezf_n
v_bezf_c:
		cmp.w     d0,d2
		bge.s     v_bezf_d1
		exg       d0,d2
v_bezf_d1:
		move.l    d0,(a1)+
		sub.w     d0,d2
		swap      d0
		swap      d2
		sub.w     d0,d2
		add.w     d2,d2
		swap      d2
		move.l    d2,(a1)+
		move.b    (a5)+,d4
		beq       v_bezf_n
		bclr      #1,d4
		beq.s     v_bezf_l2
		addq.w    #1,d6
		move.w    (a3)+,d2
		move.w    (a3)+,d3
		movea.l   a4,a3
		subq.l    #4,a3
		movem.w   -8(a4),d0-d1
		cmp.w     d1,d3
		bge.s     v_bezf_d2
		exg       d0,d2
		exg       d1,d3
v_bezf_d2:
		sub.w     d0,d2
		add.w     d2,d2
		sub.w     d1,d3
		movem.w   d0-d3,-16(a1)
		tst.w     d7
		bne.s     v_bezf_l2
		subq.l    #8,a1
v_bezf_l2:
		subq.b    #1,d4
		bne.s     v_bezf_n
		subq.w    #3,d7
		blt.s     v_bezf_f
		movem.w   d6-d7,-(a7)
		move.l    a2,-(a7)
		subq.l    #8,a1
		move.l    a1,-(a7)
		move.w    bez_qual(a6),d0
		lea.l     bez_pnt_tab(pc),a0
		add.w     d0,d0
		move.w    0(a0,d0.w),d0
		add.w     d0,d0
		add.w     d0,d0
		adda.w    d0,a1
		move.l    a1,-(a7)
		movem.w   -4(a4),d0-d7
		movea.w   bez_qual(a6),a0
		bsr       calc_bez
		movea.l   (a7)+,a0
		movea.l   (a7)+,a1
		movea.l   (a7)+,a2
		movem.w   (a7)+,d6-d7
		subq.w    #2,d0
v_bezf_b1:
		move.l    (a0)+,d2
		move.l    (a0),d3
		cmp.w     d2,d3
		bge.s     v_bezf_d3
		exg       d2,d3
v_bezf_d3:
		move.l    d2,(a1)+
		sub.w     d2,d3
		swap      d2
		swap      d3
		sub.w     d2,d3
		add.w     d3,d3
		swap      d3
		move.l    d3,(a1)+
		dbf       d0,v_bezf_b1
		addq.l    #8,a4
		addq.l    #2,a5
		andi.b    #$01,(a5)
		bra       v_bezf_l1
v_bezf_f:
		move.w    d7,d0
		beq.s     v_bezf_n
		subq.w    #2,d0
		bne.s     v_bezf_b2
		clr.b     1(a5)
v_bezf_b2:
		clr.b     (a5)
v_bezf_n:
		dbf       d7,v_bezf_l1
		move.w    (a7)+,bez_qual(a6)
		movea.l   (a7),a0
		movea.l   bez_buff(a6),a4
		movea.l   buffer_a(a6),a5
		move.l    a4,d0
		bne.s     v_bezf_p3
		movea.l   buffer_a(a6),a4
		movea.l   a1,a5
v_bezf_p3:
		move.l    a1,d4
		sub.l     a4,d4
		lsr.l     #3,d4
		cmp.w     #2,d4
		blt.s     v_bezf_e
		movea.l   16(a0),a1
		movea.l   a4,a0
		move.w    d4,d0
		bsr.s     fsearch_
		move.l    (a1)+,d5
		move.l    (a1),d7
		subq.w    #1,d4
		pea.l     v_bezf_e(pc)
		cmpi.b    #3,driver_type(a6) ; DT_OLDNVDI
		beq       fpoly
		bra.s     gpoly
v_bezf_e:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
fsearch_:
		movem.l   d0-d7/a0,-(a7)
		subq.w    #1,d0
		movem.w   res_x(a6),d4-d5
		moveq.l   #0,d6
		moveq.l   #0,d7
fmin_max:
		move.w    (a0)+,d2
		move.w    (a0)+,d3
		cmp.w     d2,d4
		ble.s     fsearch_1
		move.w    d2,d4
fsearch_1:
		cmp.w     d3,d5
		ble.s     fsearch_2
		move.w    d3,d5
fsearch_2:
		cmp.w     d2,d6
		bge.s     fsearch_3
		move.w    d2,d6
fsearch_3:
		cmp.w     d3,d7
		bge.s     fsearch_4
		move.w    d3,d7
fsearch_4:
		move.w    (a0)+,d1
		asr.w     #1,d1
		add.w     d1,d2
		add.w     (a0)+,d3
		cmp.w     d2,d4
		ble.s     fsearch_5
		move.w    d2,d4
fsearch_5:
		cmp.w     d3,d5
		ble.s     fsearch_6
		move.w    d3,d5
fsearch_6:
		cmp.w     d2,d6
		bge.s     fsearch_7
		move.w    d2,d6
fsearch_7:
		cmp.w     d3,d7
		bge.s     fsearch_8
		move.w    d3,d7
fsearch_8:
		dbf       d0,fmin_max
		movem.w   d4-d7,(a1)
		movem.l   (a7)+,d0-d7/a0
		rts
gpoly:
		move.w    clip_ymin(a6),d1
		move.w    clip_ymax(a6),d3
		cmp.w     d3,d5
		bgt       gpoly_ex
		cmp.w     d1,d7
		blt       gpoly_ex
		cmp.w     d1,d5
		bge.s     gpoly_cl
		move.w    d1,d5
gpoly_cl:
		cmp.w     d3,d7
		ble.s     gpoly_co
		move.w    d3,d7
gpoly_co:
		sub.w     d5,d7
		moveq.l   #0,d0
		bsr       gperimeter
gpoly_lo:
		movea.l   a4,a0
		movea.l   a5,a1
		movem.w   d4-d5/d7,-(a7)
		bsr.s     gpoly_hl
		movem.w   (a7)+,d4-d5/d7
		addq.w    #1,d5
		dbf       d7,gpoly_lo
		move.w    f_perimeter(a6),d0
		beq.s     gpoly_ex
		bsr       gperimeter
		bsr       gdos_get
		bsr       gdos_line0
		lea.l     -116(a7),a7
		lea.l     52(a7),a2
		lea.l     20(a7),a1
		movea.l   a7,a0
		move.l    a1,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
gpoly_bo:
		lea.l     20(a7),a1
		move.w    #6,(a1)+
		move.w    #2,(a1)+
		clr.l     (a1)+
		clr.l     (a1)+
		move.w    wk_handle(a6),(a1)
		move.l    a1,(a7)
		move.l    a4,8(a7)
		movem.w   (a4)+,d0-d3
		asr.w     #1,d2
		add.w     d0,d2
		add.w     d1,d3
		movem.w   d2-d3,-4(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		dbf       d4,gpoly_bo
		lea.l     116(a7),a7
		bsr       gdos_set
gpoly_ex:
		rts
gpoly_hl:
		movea.l   a1,a3
gpoly_ca:
		move.w    d5,d1
		move.w    (a0)+,d0
		sub.w     (a0)+,d1
		move.w    (a0)+,d2
		move.w    (a0)+,d3
		beq.s     gpoly_ne
		cmp.w     d1,d3
		bls.s     gpoly_ne
		muls.w    d1,d2
		divs.w    d3,d2
		bmi.s     gpoly_sa
		addq.w    #1,d2
gpoly_sa:
		asr.w     #1,d2
		add.w     d0,d2
		move.w    d2,(a1)+
gpoly_ne:
		dbf       d4,gpoly_ca
		move.l    a1,d6
		sub.l     a3,d6
		subq.w    #4,d6
		bne.s     gpoly_po
		move.w    (a3)+,d0
		move.w    (a3)+,d2
		move.w    d5,d1
		bra.s     gdos_fli
gpoly_po:
		tst.w     d6
		bmi.s     gpoly_hl2
		addq.w    #4,d6
		lsr.w     #1,d6
		move.w    d6,d1
		subq.w    #2,d1
gpoly_bu1:
		move.w    d1,d0
		movea.l   a3,a1
gpoly_bu2:
		move.w    (a1)+,d2
		cmp.w     (a1),d2
		ble.s     gpoly_bu3
		move.w    (a1),-2(a1)
		move.w    d2,(a1)
gpoly_bu3:
		dbf       d0,gpoly_bu2
		dbf       d1,gpoly_bu1
		lsr.w     #1,d6
		subq.w    #1,d6
gpoly_dr:
		move.w    d6,-(a7)
		move.w    (a3)+,d0
		move.w    (a3)+,d2
		move.w    d5,d1
		bsr.s     gdos_fli
		move.w    (a7)+,d6
		dbf       d6,gpoly_dr
gpoly_hl2:
		rts
gdos_fli:
		lea.l     -116(a7),a7
		lea.l     52(a7),a2
		lea.l     20(a7),a1
		movea.l   a7,a0
		move.l    a1,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.w    #114,(a1) ; vr_recfl
		move.w    #2,n_ptsin(a1)
		clr.w     n_intin(a1)
		move.w    wk_handle(a6),handle(a1)
		move.w    d0,(a2)+
		move.w    d1,(a2)+
		move.w    d2,(a2)+
		move.w    d1,(a2)+
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		cmpi.w    #9,v_device_id(a6)
		bls.s     gdos_fli2
		move.w    #11,(a1) ; v_bar
		move.w    #1,opcode2(a1)
		addq.w    #1,-(a2)
		subq.w    #1,-4(a2)
gdos_fli2:
		jsr       (a0)
		lea.l     116(a7),a7
		rts
gperimeter:
		movem.l   d0-d2/a0-a2,-(a7)
		lea.l     2(a7),a2
		lea.l     -116(a7),a7
		lea.l     20(a7),a1
		move.l    a7,d1
		movea.l   d1,a0
		move.l    a1,(a0)+
		move.l    a2,(a0)+
		lea.l     32(a1),a2
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.w    #104,(a1)+ ; vsf_perimeter
		clr.l     (a1)+
		move.w    #1,(a1)
		move.w    wk_handle(a6),6(a1)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		lea.l     116(a7),a7
		movem.l   (a7)+,d0-d2/a0-a2
		rts
gdos_get:
		movem.l   d0-d2/a0-a2,-(a7)
		lea.l     -116(a7),a7
		lea.l     20(a7),a1
		move.l    a7,d1
		movea.l   d1,a0
		move.l    a1,(a0)+
		lea.l     32(a1),a2
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		move.l    a2,(a0)+
		lea.l     32(a2),a2
		move.l    a2,(a0)
		move.w    #35,(a1) ; vql_attributes
		clr.w     n_ptsin(a1)
		clr.w     n_intin(a1)
		move.w    wk_handle(a6),handle(a1)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		lea.l     52(a7),a1
		move.w    (a1)+,l_style(a6)
		move.w    (a1)+,l_color(a6)
		lea.l     28(a1),a1
		move.w    (a1),l_width(a6)
		lea.l     116(a7),a7
		movem.l   (a7)+,d0-d2/a0-a2
		rts
gdos_line0:
		movem.l   d0-d2/a0-a4,-(a7)
		lea.l     -116(a7),a7
		lea.l     20(a7),a3
		move.l    a7,d1
		movea.l   d1,a0
		move.l    a3,(a0)+
		lea.l     32(a3),a4
		move.l    a4,(a0)+
		move.l    a4,(a0)+
		lea.l     32(a4),a2
		move.l    a2,(a0)+
		move.l    a2,(a0)
		move.w    wk_handle(a6),handle(a3)
		move.w    #37,(a3) ; vqf_attributes
		clr.w     n_ptsin(a3)
		clr.w     n_intin(a3)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    86(a7),d0
		move.w    d0,f_color(a6)
		move.w    #17,(a3) ; vsl_color
		move.w    #1,n_intin(a3)
		move.w    d0,(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #15,(a3) ; vsl_type
		move.w    #1,(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #108,(a3) ; vsl_ends
		move.w    #2,n_intin(a3)
		clr.l     (a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #16,(a3) ; vsl_width
		move.w    #1,n_ptsin(a3)
		clr.w     n_intin(a3)
		move.w    #1,(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		lea.l     116(a7),a7
		movem.l   (a7)+,d0-d2/a0-a4
		rts
gdos_set:
		movem.l   d0-d2/a0-a4,-(a7)
		lea.l     -116(a7),a7
		lea.l     20(a7),a3
		move.l    a7,d1
		movea.l   d1,a0
		move.l    a3,(a0)+
		lea.l     32(a3),a4
		move.l    a4,(a0)+
		move.l    a4,(a0)+
		lea.l     32(a4),a2
		move.l    a2,(a0)+
		move.l    a2,(a0)
		move.w    wk_handle(a6),handle(a3)
		move.w    #16,(a3) ; vsl_width
		move.w    #1,n_ptsin(a3)
		clr.w     n_intin(a3)
		move.w    l_width(a6),(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #108,(a3) ; vsl_ends
		clr.w     n_ptsin(a3)
		move.w    #2,n_intin(a3)
		move.l    l_start(a6),(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #17,(a3) ; vsl_color
		move.w    #1,n_intin(a3)
		move.w    l_color(a6),(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		move.w    #15,(a3) ; vsl_type
		move.w    l_style(a6),(a4)
		move.l    a7,d1
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		lea.l     116(a7),a7
		movem.l   (a7)+,d0-d2/a0-a4
		rts
v_contour_fill:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a3
		bsr       v_contour
		movem.l   (a7)+,d1-d7/a2-a5
		rts
vr_recfl:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   pb_ptsin(a0),a0
		movem.w   (a0),d0-d3
		bsr       fbox_nor
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_gdp:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a3
		move.w    opcode2(a1),d0
		subq.w    #1,d0
		cmpi.w    #12,d0
		bhi.s     v_gdp_error
		add.w     d0,d0
		move.w    v_gdp_tab(pc,d0.w),d0
		jsr       v_gdp_tab(pc,d0.w)
v_gdp_error:
		movem.l   (a7)+,d1-d7/a2-a5
v_gdp_exit:
		rts
v_gdp_tab:
		dc.w	v_bar-v_gdp_tab
		dc.w	v_arc-v_gdp_tab
		dc.w	v_pieslice-v_gdp_tab
		dc.w	v_circle-v_gdp_tab
		dc.w	v_ellipse-v_gdp_tab
		dc.w	v_ellarc-v_gdp_tab
		dc.w	v_ellpie-v_gdp_tab
		dc.w	v_rbox-v_gdp_tab
		dc.w	v_rfbox-v_gdp_tab
		dc.w	v_justified-v_gdp_tab
		dc.w	v_gdp_exit-v_gdp_tab
		dc.w	v_gdp_exit-v_gdp_tab
		dc.w	v_bez_on-v_gdp_tab
v_bar:
		movem.w	(a3),d0-d3
v_bar2:
		bsr  	fbox
		tst.w	f_perimeter(a6)
		beq.s	v_bar_exit2
		cmp.w	d1,d3
		bge.s	v_bar_out
		exg	d1,d3
v_bar_out:
		move.w    l_color(a6),-(a7)
		move.w    f_color(a6),l_color(a6)
		bsr.s     hline_fill
		cmp.w     d1,d3
		beq.s     v_bar_exit
		exg       d1,d3
		bsr.s     hline_fill
		subq.w    #1,d1
		addq.w    #1,d3
		bsr.s     vline_fill
		exg       d0,d2
		cmp.w     d0,d2
		beq.s     v_bar_exit
		bsr.s     vline_fill
v_bar_exit:
		move.w    (a7)+,l_color(a6)
v_bar_exit2:
		rts
hline_fill:
		movem.w   d0-d3,-(a7)
		moveq.l   #-1,d6
		bsr       hline
		movem.w   (a7)+,d0-d3
		rts
vline_fill:
		movem.w   d0-d3,-(a7)
		moveq.l   #-1,d6
		bsr       vline
		movem.w   (a7)+,d0-d3
		rts
v_pieslice:
		move.w    (a3)+,d0
		move.w    (a3)+,d1
		move.w    (a2)+,d4
		move.w    (a2)+,d5
		move.w    8(a3),d2
		move.w    d2,d3
		move.w    res_ratio(a6),d6
		beq       fellipse1
		add.w     d3,d3
		tst.w     d6
		bgt       fellipse1
		asr.w     #2,d3
		bra       fellipse1
v_circle:
		move.w    (a3)+,d0
		move.w    (a3)+,d1
		move.w    4(a3),d2
		move.w    d2,d3
		move.w    res_ratio(a6),d6
		beq.s     v_ellipse2
		add.w     d3,d3
		tst.w     d6
		bgt.s     v_ellipse2
		asr.w     #2,d3
		bra.s     v_ellipse2
v_ellipse:
		movem.w   (a3),d0-d3
v_ellipse2:
		bra       fellipse5
v_arc:
		move.w    (a3)+,d0
		move.w    (a3)+,d1
		move.w    8(a3),d2
		move.w    d2,d3
		move.w    res_ratio(a6),d6
		beq.s     v_ellarc2
		add.w     d3,d3
		tst.w     d6
		bgt.s     v_ellarc2
		asr.w     #2,d3
		bra.s     v_ellarc2
v_ellarc:
		movem.w   (a3),d0-d3
v_ellarc2:
		move.w    (a2)+,d4
		move.w    (a2)+,d5
		move.l    buffer_l(a6),-(a7)
		move.l    buffer_a(a6),-(a7)
		bsr       ellipse_1
		move.l    a1,d1
		movea.l   (a7),a0
		sub.l     a0,d1
		move.l    d1,buffer_l(a6)
		move.l    a1,buffer_a(a6)
		bsr       nvdi_line
		move.l    (a7)+,buffer_a(a6)
		move.l    (a7)+,buffer_l(a6)
		rts
v_ellpie:
		movem.w   (a3),d0-d3
		move.w    (a2)+,d4
		move.w    (a2)+,d5
		bra       fellipse1
v_rbox:
		movem.w   (a3),d0-d3
		move.l    buffer_l(a6),-(a7)
		move.l    buffer_a(a6),-(a7)
		bsr       rbox_cal
		move.l    a3,d0
		sub.l     (a7),d0
		move.l    d0,buffer_l(a6)
		move.l    a3,buffer_a(a6)
		movea.l   (a7),a0
		move.l    l_start(a6),-(a7)
		clr.l     l_start(a6)
		move.w    d4,d0
		bsr       nvdi_line
		move.l    (a7)+,l_start(a6)
		move.l    (a7)+,buffer_a(a6)
		move.l    (a7)+,buffer_l(a6)
		rts
v_rfbox:
		movem.w   (a3),d0-d3
		tst.w     f_perimeter(a6)
		beq       frbox
		bsr       frbox
		bsr       rbox_cal
		movea.l   buffer_a(a6),a3
v_pline_8:
		subq.w    #2,d4
		bmi.s     vpfl_ex
		move.w    l_color(a6),-(a7)
		move.w    f_color(a6),l_color(a6)
		cmpi.w    #2,wr_mode(a6)
		bne.s     v_plfill1
		not.w     l_lastpix(a6)
v_plfill1:
		movea.w   d4,a0
		movem.w   (a3),d0-d3
		addq.l    #4,a3
		moveq.l   #-1,d6
		pea.l     v_plfill2(pc)
		cmp.w     d1,d3
		beq       hline
		cmp.w     d0,d2
		beq       vline
		bra       line
v_plfill2:
		move.w    a0,d4
		dbf       d4,v_plfill1
		clr.w     l_lastpix(a6)
		move.w    (a7)+,l_color(a6)
vpfl_ex:
		rts
v_justified:
		tst.l     (a2)+
		bne.s     v_justified2
		subq.w    #2,n_intin(a1)
		move.l    a1,-(a7)
		movea.l   p_gtext(a6),a4
		jsr       (a4)
		movea.l   (a7)+,a1
		addq.w    #2,n_intin(a1)
		rts
v_justified2:
		bra       text_jus
v_bez_on:
		movea.l   pb_intout(a0),a0
		tst.w     2(a1)
		bne.s     v_bez_on2
		clr.w     bez_on(a6)
		clr.w     (a0)
v_bez_oo:
		rts
v_bez_on2:
		move.w    #5,bez_qual(a6)
		move.w    #7,(a0)
		move.w    #1,bez_on(a6)
		rts
set_xbios:
		cmp.w     #4,d3
		bne.s     set_xbios1
		cmpi.w    #3,(nvdi_cookie_vdo).w
		beq.s     set_falc
set_xbios1:
		movem.l   d0-d1,-(a7)
		move.w    (resolution).w,d0
		tst.w     d3
		beq.s     set_res_2
		moveq.l   #3,d1
		cmpi.w    #2,(nvdi_cookie_vdo).w
		bne.s     set_res_1
		moveq.l   #7,d1
set_res_1:
		cmp.w     d1,d0
		beq.s     set_res_2
		cmp.w     d1,d3
		beq.s     set_res_2
		move.w    d3,d0
		subq.w    #1,d0
		cmp.w     #7,d0
		bgt.s     set_act_
		btst      d0,#$28
		beq       set_xbios3
set_act_:
		move.w    (resolution).w,d0
		subq.w    #1,d0
set_xbios3:
		bsr       set_resolution
set_res_2:
		movem.l   (a7)+,d0-d1
		rts
set_falc:
		movem.l   d0-d2/a0-a2,-(a7)
		move.l    d1,-(a7)
		move.w    #$FFFF,-(a7)
		move.w    #$58,-(a7) ; VsetMode
		trap      #14
		addq.l    #4,a7
		movea.l   (a7)+,a0
		movea.l   pb_ptsout(a0),a0
		move.w    d0,(modecode).w
		cmp.w     (a0),d0
		beq.s     set_flc_
		move.w    (a0),(modecode).w
		move.w    (a0),-(a7)
		move.w    #3,-(a7)
		moveq.l   #-1,d0
		move.l    d0,-(a7)
		move.l    d0,-(a7)
		move.w    #5,-(a7)
		trap      #14
		lea.l     14(a7),a7
set_flc_:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
opnwk_lo:
		bsr       set_xbios
		move.l    (screen_d+device_addr).w,d0
		movea.l   d0,a0
		tst.l     d0
		bne.s     opnwk_dr
		rts
opnwk_dr:
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    DRVR_planes(a0),d0
		cmp.w     (PLANES).w,d0
		beq.s     opnwk_dp
		bsr       unload_s
		bsr       load_scr
opnwk_dp:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
open_nvdi:
		move.w    d3,(first_de).w
		movea.l   (aes_wk_p).w,a6
		move.l    a6,(wk_tab).w
		moveq.l   #1,d4
		move.w    d3,v_device_id(a6)
		move.w    d4,wk_handle(a6)
		move.w    d4,handle(a1)
		addq.w    #1,device_refcount(a3)
		move.w    d4,device_handle(a3)
		bsr       init_font_nvdi
		bsr       init_res
		bsr       init_int
		movem.l   d1/a0-a1,-(a7)
		movea.l   a3,a0
		movea.l   device_wk(a3),a1
		bsr       wk_default
		movem.l   (a7)+,d1/a0-a1
		movem.l   d1/a0-a1/a6,-(a7)
		movea.l   a3,a0
		movea.l   device_wk(a3),a1
		movea.l   (linea_wk).w,a6
		bsr       wk_default
		movem.l   (a7)+,d1/a0-a1/a6
		bra       opnwk_io
set_disp:
		move.l    #handle_f,vdi_disp(a6)
		move.b    device_type+1(a3),driver_type(a6)
		rts
v_opnwk:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a5
		bsr       get_resolution
		move.w    (a2),d3
		subq.w    #1,d3
		cmpi.w    #9,d3
		bhi       opnwk_err1
		lea.l     (screen_d).w,a3
		tst.w     device_refcount(a3)
		bne.s     opnwk_op
		bsr       opnwk_lo
		tst.l     d0
		beq.s     opnwk_err1
		bsr       open_nvdi
		tst.l     (PixMap_ptr).w
		beq.s     v_opnwk_1
		lea.l     (CONTRL).w,a0
		move.l    a0,d1
		lea.l     (control).w,a1
		move.l    a1,(a0)+
		lea.l     (intin).w,a2
		move.l    a2,(a0)+
		move.l    #ptsin,(a0)+
		move.l    #intout,(a0)+
		move.l    #ptsout,(a0)+
		move.w    #21,(a1) ; vst_font
		move.w    #1,n_intin(a1)
		clr.w     n_ptsin(a1)
		move.w    #1,handle(a1)
		move.w    #1,(a2)
		moveq.l   #115,d0
		trap      #2
v_opnwk_1:
		move.l    #$45644449,d0
		move.l    #eddi_dispatch,d1
		bsr       init_cookie0
opn_handle:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
opnwk_op:
		move.l    a6,d0
		bsr       Mfree
		lsl.w     #2,d4
		lea.l     (wk_tab-4).w,a6
		move.l    #closed,vdi_disp(a6,d4.w)
		move.w    d3,d0
		addq.w    #1,d0
opnwk_err1:
		movem.l   (a7)+,d1-d7/a2-a5
		movea.l   d1,a0
		movea.l   (a0),a1
		clr.w     handle(a1)
		rts
alloc_wk:
		moveq.l   #0,d4
		moveq.l   #MAX_HANDLES-2,d2
		lea.l     (wk_tab+4).w,a6
opnwk_lo2:
		cmpi.l    #closed,(a6)+
		dbeq      d2,opnwk_lo2
		eori.w    #MAX_HANDLES-1,d2
		bpl.s     opnwk_alloc
		moveq.l   #-1,d0
		bra.s     alloc_wk1
opnwk_alloc:
		move.l    #WK_LENGTH,d0
		cmpi.b    #$03,9(a3)
		bne.s     opnwk_ge
		move.l    16(a3),d0
opnwk_ge:
		move.w    d0,-(a7)
		bsr       MallocA
		tst.l     d0
		bne.s     opnwk_sa
		addq.l    #2,a7
		moveq.l   #-3,d0
		bra.s     alloc_wk1
opnwk_sa:
		move.w    d2,d4
		addq.w    #1,d4
		move.l    d0,-(a6)
		movea.l   d0,a6
		move.w    (a7)+,d2
		lsr.w     #1,d2
		subq.w    #1,d2
opnwk_cl:
		clr.w     (a6)+
		dbf       d2,opnwk_cl
		movea.l   d0,a6
		move.w    d3,v_device_id(a6)
		move.w    d4,wk_handle(a6)
alloc_wk1:
		move.w    d4,handle(a1)
		rts
free_wk:
		lsl.w     #2,d0
		lea.l     (wk_tab-4).w,a0
		move.l    #closed,vdi_disp(a0,d0.w)
		move.l    a6,d0
		bra       Mfree
get_resolution:
		movem.l   d0-d2/a0-a2,-(a7)
		moveq.l   #0,d0
		move.b    (sshiftmd).w,d0
		addq.w    #1,d0
		move.w    d0,(resolution).w
		movem.l   (a7)+,d0-d2/a0-a2
		rts
set_resolution:
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    d0,-(a7)
		moveq.l   #-1,d0
		move.l    d0,-(a7)
		move.l    d0,-(a7)
		move.w    #5,-(a7)
		trap      #14
		lea.l     12(a7),a7
		movem.l   (a7)+,d0-d2/a0-a2
		rts
opnwk_io:
		bsr       init_arr
		bsr.s     v_opnwk_setattr
		bsr.s     v_opnwk_2
opnwk_io2:
		rts
v_opnwk_2:
		movem.l   d0-d2/a0-a5,-(a7)
		move.l    device_drv(a6),d0
		beq.s     v_opnwk_3
		movea.l   d0,a2
		movea.l   device_addr(a2),a2
		bra.s     v_opnwk_4
v_opnwk_3:
		movea.l   bitmap_drv(a6),a2
		movea.l   DRIVER_A(a2),a2
v_opnwk_4:
		movea.l   DRVR_open(a2),a2
		movea.l   a4,a0
		movea.l   a5,a1
		jsr       (a2)
v_opnwk_5:
		movem.l   (a7)+,d0-d2/a0-a5
		rts
call_nvd:
		lsl.w     #3,d0
		lea.l     vdi_tab(pc),a0
		move.l    4(a0,d0.w),-(a7)
		movea.l   d1,a0
		rts
v_opnwk_setattr:
		movem.l   d0-d1/a0-a1/a3,-(a7)
		movea.l   d1,a0
		lea.l     pb_intin(a0),a3
		addq.l    #2,(a3)
		moveq.l   #15,d0 ; vsl_type
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #17,d0 ; vsl_color
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #18,d0 ; vsm_type
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #20,d0 ; vsm_color
		bsr.s     call_nvd
		movea.l   d1,a0
		pea.l     opnwk_tc(pc)
		cmpi.w    #320-1,res_y(a6)
		blt       vst_height3
		bra       vst_height0
opnwk_tc:
		addq.l    #4,(a3)
		moveq.l   #22,d0 ; vst_color
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #23,d0 ; vsf_interior
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #24,d0 ; vsf_style
		bsr.s     call_nvd
		addq.l    #2,(a3)
		moveq.l   #25,d0 ; vsf_color
		bsr.s     call_nvd
		subi.l    #18,(a3)
		movem.l   (a7)+,d0-d1/a0-a1/a3
		rts
init_font_nvdi:
		movem.l   d0-d1/a0-a2,-(a7)
		lea.l     (font_header).w,a1
		lea.l     (font_header+sizeof_FONTHDR).w,a2
		lea.l     (FONT_RING).w,a0
		move.l    a1,(a0)+
		move.l    a2,(a0)+
		clr.l     (a0)+
		clr.l     (a0)+
		move.w    #1,(FONT_COUNT).w
		move.l    a2,(DEF_FONT).w
		move.l    76(a2),(V_FNT_AD).w
		moveq.l   #8,d0
		moveq.l   #0,d1
		move.w    (V_REZ_VT).w,d1
		cmpi.w    #400,d1
		blt.s     init_nvdi
		moveq.l   #16,d0
		lea.l     (font_header+2*sizeof_FONTHDR).w,a2
init_nvdi:
		move.l    a2,(DEF_FONT).w
		move.l    76(a2),(V_FNT_AD).w
		move.w    d0,(V_CEL_HT).w
		divu.w    d0,d1
		subq.w    #1,d1
		move.w    d1,(V_CEL_MY).w
		movem.l   (a7)+,d0-d1/a0-a2
		rts
init_res:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   12(a3),a2
		movea.l   32(a2),a2
		lea.l     (DEV_TAB).w,a0
		lea.l     (SIZ_TAB).w,a1
		jsr       (a2)
		movea.l   12(a3),a2
		movea.l   36(a2),a2
		lea.l     (INQ_TAB).w,a0
		lea.l     -64(a7),a7
		movea.l   a7,a1
		jsr       (a2)
		lea.l     64(a7),a7
init_res1:
		movem.l   (a7)+,d0-d2/a0-a2
		rts
init_int:
		movem.l   d0-d7/a0-a6,-(a7)
		move.w    sr,-(a7)
		ori.w     #$0700,sr
		move.w    #256,d0
		lea.l     sys_time(pc),a0
		lea.l     (old_etv_timer).w,a1
		bsr       change_vec
		move.l    #dummy_rts,(USER_TIM).w
		move.l    (old_etv_timer).w,(NEXT_TIM).w
		move.l    #dummy_rts,(USER_BUT).w
		move.l    #user_cur,(USER_CUR).w
		move.l    #dummy_rts,(USER_MOT).w
		lea.l     mouse_form(pc),a2
		bsr       transform_mouse1
		clr.w     (MOUSE_BT).w
		clr.b     (CUR_MS_STAT).w
		clr.b     (MOUSE_FLAG).w
		moveq.l   #1,d0
		move.b    d0,(M_HID_CNT).w
		move.b    d0,(CUR_FLAG).w
		move.l    (DEV_TAB).w,d0
		lsr.l     #1,d0
		bclr      #15,d0
		move.l    d0,(GCURX).w
		move.l    d0,(CUR_X).w
		movea.l   (vbl_queue).w,a0
		move.l    #vbl_mouse2,(a0)
		lea.l     mouse_int(pc),a0
		move.l    a0,-(a7)
		pea.l     mouse_pa(pc)
		moveq.l   #1,d0
		move.l    d0,-(a7)
		trap      #14
		lea.l     12(a7),a7
		move.w    (a7)+,sr
		movem.l   (a7)+,d0-d7/a0-a6
		rts
mouse_pa:
		dc.w	$0000,$0101
mouse_form:
		dc.w	$0001,$0001,$0001,$0000
		dc.w	$0001
		dc.w	$C000,$E000,$F000,$F800
		dc.w	$FC00,$FE00,$FF00,$FF80
		dc.w	$FFC0,$FFE0,$FE00,$EF00
		dc.w	$CF00,$8780,$0780,$0380
		dc.w	$0000,$4000,$6000,$7000
		dc.w	$7800,$7C00,$7E00,$7F00
		dc.w	$7F80,$7C00,$6C00,$4600
		dc.w	$0600,$0300,$0300,$0000

init_arr:
		movem.l	d0/a0/a6,-(a7)
		moveq.l   #-1,d0
		lea.l     (intin).w,a6
		move.l    d0,(a6)
		lea.l     (COLBIT0).w,a0
		move.l    d0,(a0)+
		move.l    d0,(a0)+
		move.l    d0,(a0)+
		move.w    d0,(TEXTFG).w
		clr.w     (TEXTBG).w
		move.l    (font_header+sizeof_FONTHDR*2+dat_table).w,(FBASE).w
		move.w    (font_header+sizeof_FONTHDR*2+form_width).w,(FWIDTH).w
		move.l    (scrtchp).w,(SCRTCHP).w
		move.w    #$2000,(SCRPT2).w
		move.l    #fill0,(PATPTR).w
		clr.w     (PATMSK).w
		move.w    #1,(V_HID_CNT).w
		clr.w     (MFILL).w
		cmpi.w    #8,(PLANES).w
		blt.s     init_la_
		clr.l     (COLBIT4).w
		clr.l     (COLBIT6).w
init_la_:
		movem.l   (a7)+,d0/a0/a6
		rts
wk_init:
		move.l    a6,-(a7)
		movea.l   8(a7),a6
		moveq.l   #0,d1
		bsr.s     wk_default
		movea.l   (a7)+,a6
		rts

;
; a0: ptr to screen_drv; can be null
; a1: ptr to OSD; can be null
; a6: ptr to WK
;
wk_default:
		movem.l   d0-d2/a0-a1,-(a7)
		move.l    #handle_f,vdi_disp(a6)
		clr.l     disp_addr(a6)
		move.l    (DEV_TAB).w,res_x(a6)
		move.l    (DEV_TAB+6).w,pixel_width(a6)
		move.w    (PLANES).w,d0
		subq.w    #1,d0
		move.w    d0,r_planes(a6)
		move.w    (DEV_TAB+26).w,d0
		subq.w    #1,d0
		move.w    d0,colors(a6)
		move.b    #3,driver_type(a6) ; DT_OLDNVDI
		clr.w     t_bitmap_flag(a6)
		clr.w     res_ratio(a6)
		cmpa.l    (aes_wk_p).w,a6
		beq.s     wk_array
		movea.l   (aes_wk_p).w,a0
		move.w    res_ratio(a0),res_ratio(a6)
wk_array:
		move.b    #$0F,input_mode(a6)
		move.w    #5,bez_qual(a6)
		clr.l     bez_buff(a6)
		clr.l     bez_buf_(a6)
		clr.l     clip_xmin(a6)
		move.l    res_x(a6),clip_xmax(a6)
		clr.w     wr_mode(a6)
		lea.l     l_width(a6),a0
		move.w    #1,l_width(a6)
		clr.l     l_start(a6)
		clr.l     l_lastpix(a6) ; clrs also l_style
		lea.l     l_pattern(a6),a0
		move.l    #$FFFFFFF0,(a0)+
		move.l    #$E0E0FF18,(a0)+
		move.l    #$FF00F198,(a0)+
		move.w    #$FFFF,(a0)+
		clr.l     t_effects(a6) ; clrs also
		clr.l     t_hor(a6)
		move.w    #1,t_number(a6)
		move.l    #font_header,t_pointer(a6)
		move.l    (scrtchp).w,buffer_a(a6)
		move.l    #NVDI_BUFSIZE,buffer_l(a6)
		clr.w     t_point_2(a6)
		clr.l     t_bitmap_addr(a6)
		clr.b     t_font_test(a6)
		move.b    #$01,t_mapping(a6)
		move.w    #$FFFF,t_no_kern(a6)
		clr.w     t_no_track(a6)
		clr.w     t_skew(a6)
		clr.w     t_track_x(a6)
		clr.l     t_track_y(a6)
		move.w    #$ff,t_ades(a6)
		move.w    #1,f_perimeter(a6)
		lea.l     WK_LENGTH(a6),a0
		move.l    a0,f_spoints(a6)
		clr.w     f_splanes(a6)
		move.l    #fill0,f_fill0(a6)
		move.l    #fill1,f_fill1(a6)
		move.l    #fill2_1,f_fill2(a6)
		move.l    #fill3_1,f_fill3(a6)
		lea.l     fill4_1,a1
		moveq.l   #7,d0
init_wk_:
		move.l    (a1)+,(a0)+
		dbf       d0,init_wk_
		move.w    #9,m_height(a6)
		move.l    #text,p_gtext(a6)
		move.l    #v_escape,p_escape(a6)
		movem.l   (a7),d0-d2/a0-a1
		move.l    a0,device_drv(a6)
		move.l    a1,bitmap_drv(a6)
		move.l    a0,d0
		beq.s     wkdef_of
		movea.l   device_addr(a0),a0
		move.l    DRVR_colors(a0),bitmap_colors(a6)
		move.w    DRVR_planes(a0),bitmap_planes(a6)
		move.w    DRVR_format(a0),bitmap_format(a6)
		move.w    DRVR_flags(a0),bitmap_flags(a6)
wkdef_of:
		move.l    a1,d0
		beq.s     wkdef_dr
		movea.l   DRIVER_A(a1),a1
		movea.l   DRVR_wk_create(a1),a1
		jsr       (a1)
wkdef_dr:
		movem.l   (a7),d0-d2/a0-a1
		move.l    a0,d0
		beq.s     wkdef_ex
		movea.l   device_addr(a0),a0
		movea.l   DRVR_wk_create(a0),a0
		jsr       (a0)
wkdef_ex:
		moveq.l   #0,d0
		move.w    pixel_width(a6),d0
		move.w    pixel_height(a6),d1
		move.w    d0,d2
		lsr.w     #1,d2
		add.w     d2,d0
		divu.w    d1,d0
		subq.w    #1,d0
		move.w    d0,res_ratio(a6)
		movem.l   (a7)+,d0-d2/a0-a1
		rts
init_mon:
		movem.l   d3-d7/a2-a6,-(a7)
		move.l    a0,(mono_DRV).w
		movea.l   (linea_wk).w,a6
		movea.l   24(a0),a1
		jsr       (a1)
		move.l    p_bitblt(a6),(mono_bitmap).w
		move.l    p_expblt(a6),(mono_expblt).w
		movem.l   (a7)+,d3-d7/a2-a6
		rts
Bconout: ; not exported!
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    d0,-(a7)
		move.w    #2,-(a7)
		move.w    #3,-(a7)
		trap      #13
		addq.l    #6,a7
		movem.l   (a7)+,d0-d2/a0-a2
		rts
cldrvr:
		movem.l   d0-d2/a0-a2,-(a7)
		movea.l   disp_addr(a6),a0
		jsr       (a0)
		movem.l   (a7)+,d0-d2/a0-a2
		rts
v_opnvwk:
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   (a0),a1-a5
		cmpi.w    #1,opcode2(a1)
		bne.s     v_opnvwk1
		cmpi.w    #20,n_intin(a1)
		beq.s     v_opnbm
v_opnvwk1:
		move.w    v_device_id(a6),d3
		movea.l   device_drv(a6),a3
		move.w    wk_handle(a6),d7
		bsr       alloc_wk
		tst.w     d4
		beq.s     v_opnvwk3
		movem.l   a0-a1,-(a7)
		movea.l   a3,a0
		movea.l   device_wk(a3),a1
		bsr       wk_default
		movem.l   (a7)+,a0-a1
		addq.w    #1,device_refcount(a3)
v_opnvwk2:
		bsr       opnwk_io
v_opnvwk3:
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_opnvwk4:
		move.w    d4,d0
		bsr       free_wk
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_opnbm:
		move.l    a2,-(a7)
		move.l    s_addr(a1),-(a7)
		movea.l   a6,a1
		movea.l   device_drv(a6),a0
		jsr       create_bitmap
		addq.l    #8,a7
		move.l    a0,d0
		beq.s     v_opnbm_1
		movea.l   a0,a6
		movea.l   (a7),a0
		move.l    a0,d1 ; fetch VDIPB from saved D1
		movem.l   (a0),a1-a5
		move.w    wk_handle(a6),handle(a1)
		bsr       v_opnwk_setattr
		movea.l   bitmap_drv(a6),a2
		movea.l   DRIVER_A(a2),a2
		movea.l   DRVR_open(a2),a2
		movea.l   a4,a0
		movea.l   a5,a1
		jsr       (a2)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_opnbm_1:
		movea.l   (a7),a0
		movea.l   (a0),a1
		clr.w     handle(a1)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
clear_bitmap:
		move.l    a6,-(a7)
		movea.l   a0,a6
		bsr       v_clrwk
		movea.l   (a7)+,a6
		rts
transform:
		movem.l   a2/a6,-(a7)
		movea.l   12(a7),a6
		movea.l   p_transform(a6),a2
		jsr       (a2)
		movem.l   (a7)+,a2/a6
		rts
v_clswk_1:
		movem.l   (a7)+,d1-d2/a2
		bra       v_clsvwk
v_clswk:
		movem.l   d1-d3/a2,-(a7)
		movea.l   (a0),a1
		move.w    handle(a1),d0
		beq.s     v_clswk_5
		movea.l   device_drv(a6),a2
		move.l    a2,d2
		beq.s     v_clswk_5
		cmp.w     24(a2),d0
		bne.s     v_clswk_1
		move.w    v_device_id(a6),d2
		moveq.l   #127,d3
		lea.l     (wk_tab).w,a1
v_clswk_2:
		movea.l   (a1)+,a2
		cmp.w     10(a2),d2
		bne.s     v_clswk_4
		cmpa.l    (aes_wk_p).w,a2
		beq.s     v_clswk_3
		cmpa.l    a6,a2
		beq.s     v_clswk_3
		bsr.w     call_cls
		bra.s     v_clswk_4
v_clswk_3:
		move.l    #closed,-4(a1)
v_clswk_4:
		dbf       d3,v_clswk_2
		movem.l   d0/a0-a1/a6,-(a7)
		movea.l   (a0),a1
		move.w    #120,(a1) ; vst_unload_fonts
		bsr       vst_unload_fonts
		movem.l   (a7)+,d0/a0-a1/a6
		movea.l   (a0),a1
		move.w    #2,(a1) ; v_clswk
		movea.l   device_drv(a6),a2
		clr.w     10(a2)
		movea.l   device_addr(a2),a1
		movea.l   DRVR_wk_delete(a1),a1
		lea.l     (nvdi_struct).w,a0
		jsr       (a1)
		bsr.w     reset_int
		move.l    #$45644449,d0
		bsr       reset_co
v_clswk_5:
		movem.l   (a7)+,d1-d3/a2
		rts
call_cls:
		rts
v_clsvwk:
		movem.l   d1-d2/a2,-(a7)
		movea.l   (a0),a1
		move.w    handle(a1),d0
		beq.s     v_clsvwk2
		cmp.w     #1,d0
		beq.s     v_clsvwk3
		tst.l     bitmap_addr(a6)
		bne.s     v_clsbm
		movea.l   device_drv(a6),a2
v_clsvwk1:
		movea.l   device_addr(a2),a1
		movea.l   DRVR_wk_delete(a1),a1
		lea.l     (nvdi_struct).w,a0
		jsr       (a1)
		subq.w    #1,10(a2)
		bsr       free_wk
v_clsvwk2:
		movem.l   (a7)+,d1-d2/a2
		rts
v_clsbm:
		movea.l   bitmap_drv(a6),a1
		movea.l   4(a1),a1
		movea.l   DRVR_wk_delete(a1),a1
		lea.l     (nvdi_struct).w,a0
		jsr       (a1)
		movea.l   a6,a0
		jsr       delete_bitmap
		movem.l   (a7)+,d1-d2/a2
		rts
v_clsvwk3:
		movem.l   (a7)+,d1-d2/a2
		cmp.w     #1,d0
		beq.s     v_clsvwk4
		bra       v_clswk
v_clsvwk4:
		rts
reset_int:
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    sr,-(a7)
		ori.w     #$0700,sr
		move.l    (old_etv_timer).w,(etv_timer).w
		lea.l     (USER_TIM).w,a0
		clr.l     (a0)+
		clr.l     (a0)+
		clr.l     (a0)+
		clr.l     (a0)+
		clr.l     (a0)+
		clr.l     -(a7)
		clr.l     -(a7)
		clr.l     -(a7)
		trap      #14
		lea.l     12(a7),a7
		movea.l   (vbl_queue).w,a0
		clr.l     (a0)
		move.w    (a7)+,sr
		movem.l   (a7)+,d0-d2/a0-a2
		rts
v_clrwk:
		movem.l   d1-d7/a2-a5,-(a7)
		move.w    wr_mode(a6),-(a7)
		move.w    f_interior(a6),-(a7)
		move.l    f_pointer(a6),-(a7)
		move.w    f_planes(a6),-(a7)
		clr.w     wr_mode(a6)
		move.l    f_fill0(a6),f_pointer(a6)
		clr.w     f_planes(a6)
		clr.w     f_interior(a6)
		moveq.l   #0,d0
		moveq.l   #0,d1
		move.w    res_x(a6),d2
		move.w    res_y(a6),d3
		move.l    a6,-(a7)
		bsr       fbox_nor
		movea.l   (a7)+,a6
		move.w    (a7)+,f_planes(a6)
		move.l    (a7)+,f_pointer(a6)
		move.w    (a7)+,f_interior(a6)
		move.w    (a7)+,wr_mode(a6)
		movem.l   (a7)+,d1-d7/a2-a5
		rts
v_updwk:
		rts
vst_load_fonts:
		movem.l   d1-d3/a2-a5,-(a7)
		movea.l   (a0),a1
		movea.l   pb_intout(a0),a4
		tst.l     t_bitmap_addr(a6)
		bne.s     vst_lfg_
		move.l    20(a1),d0 ; ??? thats contrl[10-11]???
		beq.s     vst_lfg_
		btst      #0,d0
		bne.s     vst_lfg_
		clr.w     t_bitmap_flag(a6)
vst_lf_n:
		movea.l   d0,a0
		move.l    a0,t_bitmap_addr(a6)
vst_lf_i:
		moveq.l   #-1,d0
		moveq.l   #0,d1
vst_lf_l:
		cmp.w     (a0),d0
		beq.s     vst_lf_f
		move.w    (a0),d0
		addq.w    #1,d1
vst_lf_f:
		tst.b     67(a0)
		bne.s     vst_lf_m
		movea.l   76(a0),a1
		move.w    80(a0),d2
		mulu.w    82(a0),d2
		lsr.w     #1,d2
		subq.w    #1,d2
vst_lf_s:
		move.w    (a1),d3
		ror.w     #8,d3
		move.w    d3,(a1)+
		dbf       d2,vst_lf_s
vst_lf_m:
		bset      #2,67(a0)
		movea.l   84(a0),a0
		move.l    a0,d2
		bne.s     vst_lf_l
		move.w    d1,(a4)
		move.l    t_bitmap_addr(a6),(FONT_RING+8).w ; ???
		movem.l   (a7)+,d1-d3/a2-a5
		rts
vst_lfg_:
		clr.w     (a4)
		movem.l   (a7)+,d1-d3/a2-a5
		rts
vst_unload_fonts:
		movem.l   d1-d2/a2,-(a7)
		movea.l   (a0),a1
		tst.l     t_bitmap_addr(a6)
		beq.s     vst_unload1
		clr.l     t_bitmap_addr(a6)
vst_ulf_:
		movem.l   (a7)+,d1-d2/a2
		movea.l   d1,a0
		movem.l   d1-d7/a2,-(a7)
		moveq.l   #1,d0
		lea.l     (font_header).w,a0
		bra       vst_font2
vst_unload1:
		movem.l   (a7)+,d1-d2/a2
		rts
vs_clip:
		movem.l   pb_intin(a0),a0-a1
		tst.w     bitmap_w(a6)
		bne.s     vs_clip_13
		movem.l   d1-d5,-(a7)
		movem.w   (DEV_TAB).w,d4-d5
		move.w    (a0),d0
		move.w    d0,(CLIP).w
		beq.s     vs_clip_12
		move.w    (a1)+,d0
		bpl.s     vs_clip_1
		moveq.l   #0,d0
vs_clip_1:
		cmp.w     d4,d0
		ble.s     vs_clip_2
		move.w    d4,d0
vs_clip_2:
		move.w    (a1)+,d1
		bpl.s     vs_clip_3
		moveq.l   #0,d1
vs_clip_3:
		cmp.w     d5,d1
		ble.s     vs_clip_4
		move.w    d5,d1
vs_clip_4:
		move.w    (a1)+,d2
		bpl.s     vs_clip_5
		moveq.l   #0,d2
vs_clip_5:
		cmp.w     d4,d2
		ble.s     vs_clip_6
		move.w    d4,d2
vs_clip_6:
		move.w    (a1)+,d3
		bpl.s     vs_clip_7
		moveq.l   #0,d3
vs_clip_7:
		cmp.w     d5,d3
		ble.s     vs_clip_8
		move.w    d5,d3
vs_clip_8:
		cmp.w     d0,d2
		bge.s     vs_clip_9
		exg       d0,d2
vs_clip_9:
		cmp.w     d1,d3
		bge.s     vs_clip_10
		exg       d1,d3
vs_clip_10:
		movem.w   d0-d3,clip_xmin(a6)
		movem.w   d0-d3,(XMINCL).w
vs_clip_11:
		movem.l   (a7)+,d1-d5
		rts
vs_clip_12:
		moveq.l   #0,d0
		moveq.l   #0,d1
		move.w    d4,d2
		move.w    d5,d3
		bra.s     vs_clip_10
vs_clip_13:
		movem.l   d1-d7,-(a7)
		movem.w   (a1),d0-d3
		movem.w   bitmap_off_x(a6),d4-d7
		add.w     d4,d6
		add.w     d5,d7
		tst.w     (a0)
		bne.s     vs_clip_14
		move.w    d4,d0
		move.w    d5,d1
		move.w    d6,d2
		move.w    d7,d3
vs_clip_14:
		cmp.w     d4,d0
		bge.s     vs_clip_15
		move.w    d4,d0
vs_clip_15:
		cmp.w     d6,d0
		ble.s     vs_clip_16
		move.w    d6,d0
vs_clip_16:
		cmp.w     d5,d1
		bge.s     vs_clip_17
		move.w    d5,d1
vs_clip_17:
		cmp.w     d7,d1
		ble.s     vs_clip_18
		move.w    d7,d1
vs_clip_18:
		cmp.w     d4,d2
		bge.s     vs_clip_19
		move.w    d4,d2
vs_clip_19:
		cmp.w     d6,d2
		ble.s     vs_clip_20
		move.w    d6,d2
vs_clip_20:
		cmp.w     d5,d3
		bge.s     vs_clip_21
		move.w    d5,d3
vs_clip_21:
		cmp.w     d7,d3
		ble.s     vs_clip_22
		move.w    d7,d3
vs_clip_22:
		cmp.w     d0,d2
		bge.s     vs_clip_23
		exg       d0,d2
vs_clip_23:
		cmp.w     d1,d3
		bge.s     vs_clip_24
		exg       d1,d3
vs_clip_24:
		movem.w   d0-d3,clip_xmin(a6)
		movem.l   (a7)+,d1-d7
		rts
text_par:
		move.l    t_image(a6),-(a7)
		exg       d0,d2
		exg       d1,d3
		move.w    t_rotation(a6),d7
		beq.s     text_par1
		subq.w    #1,d7
		beq.s     text_par1
		exg       d1,d3
		subq.w    #1,d7
		beq.s     text_par1
		exg       d1,d3
		exg       d0,d2
text_par1:
		move.w    t_act_line(a6),d0
		move.w    t_cheight(a6),d1
		btst      #4,t_effects+1(a6)
		beq.s     text_par2
		moveq.l   #16,d5
		tst.w     d0
		beq.s     text_par3
		subq.w    #1,d0
		sub.w     d0,d1
		cmp.w     d5,d1
		ble.s     text_par3
		moveq.l   #17,d5
		bra.s     text_par3
text_par2:
		moveq.l   #15,d5
		sub.w     d0,d1
		cmp.w     d5,d1
		bgt.s     text_par3
		subq.w    #1,d1
		move.w    d1,d5
text_par3:
		move.w    d3,d4
		add.w     d5,d4
		movea.l   (a7),a1
		movem.w   d2-d3,-(a7)
		move.w    d6,-(a7)
		move.w    a3,-(a7)
		move.l    a5,-(a7)
		mulu.w    t_iheight(a6),d0
		divu.w    t_cheight(a6),d0
		mulu.w    t_iwidth(a6),d0
		adda.l    d0,a1
		move.l    a1,t_image(a6)
text_par4:
		move.w    t_space_(a6),-(a7)
		move.w    t_add_len(a6),-(a7)
		bsr       fill_tex
		move.w    (a7)+,t_add_len(a6)
		move.w    (a7)+,t_space_(a6)
		movea.l   buffer_a(a6),a0
		movea.w   a3,a2
		move.w    t_effects(a6),d7
		beq.s     text_par9
text_par5:
		btst      #0,d7
		beq.s     text_par6
		bsr       bold
text_par6:
		btst      #3,t_effects+1(a6)
		beq.s     text_par7
		pea.l     text_par7(pc)
		btst      #4,t_effects+1(a6)
		beq       underlin1
		addq.l    #4,a7
		adda.w    a2,a0
		bsr       underlin1
		suba.w    a2,a0
text_par7:
		btst      #4,t_effects+1(a6)
		beq.s     text_par8
		bsr       outline
		subq.w    #2,d5
		move.w    t_act_line(a6),d0
		beq.s     text_par8
		adda.w    a2,a0
		adda.w    a2,a0
		addi.w    #16,d0
		cmp.w     t_cheight(a6),d0
		bge.s     text_par8
		subq.w    #2,d5
text_par8:
		btst      #1,t_effects+1(a6)
		beq.s     text_par9
		bsr       light
text_par9:
		movea.l   (a7)+,a5
		movea.w   (a7)+,a3
		move.w    (a7)+,d6
		movem.w   (a7)+,d2-d3
		move.w    t_rotation(a6),d7
		bne.s     textp_ro1
text_par10:
		btst      #2,t_effects+1(a6)
		bne.s     text_par13
		movem.l   d2-d6/a1/a3/a5,-(a7)
		bsr       textblt_1
		movem.l   (a7)+,d2-d6/a1/a3/a5
text_par11:
		addq.w    #1,d5
		add.w     d5,d3
		moveq.l   #16,d1
		add.w     t_act_line(a6),d1
		move.w    d1,t_act_line(a6)
		move.w    t_cheight(a6),d5
		sub.w     d1,d5
		bgt       text_par1
text_par12:
		move.l    (a7)+,t_image(a6)
		rts
text_par13:
		movem.w   d3/d5-d6,-(a7)
		tst.w     t_act_line(a6)
		bne.s     text_par14
		sub.w     t_left_offset(a6),d2
		add.w     t_whole_width(a6),d2
text_par14:
		move.w    #$5555,d6
		moveq.l   #0,d1
		move.w    d5,d7
textp_it1:
		moveq.l   #0,d5
		movem.l   d1-d7/a0-a5,-(a7)
		moveq.l   #0,d0
		bsr       textblt
		movem.l   (a7)+,d1-d7/a0-a5
		ror.w     #1,d6
		bcc.s     textp_it2
		subq.w    #1,d2
textp_it2:
		addq.w    #1,d3
		addq.w    #1,d1
		dbf       d7,textp_it1
		movem.w   (a7)+,d3/d5-d6
		bra.s     text_par11
textp_ro1:
		subq.w    #1,d7
		bne.s     textp_ro2
		movem.l   d6/a3/a5,-(a7)
		bsr       rotate90
		movem.l   (a7)+,d6/a3/a5
		btst      #2,t_effects+1(a6)
		bne.s     textp_it3
		movem.l   d2-d6/a3/a5,-(a7)
		bsr       textblt_1
		movem.l   (a7)+,d2-d6/a3/a5
text_par15:
		addq.w    #1,d4
		add.w     d4,d2
		moveq.l   #16,d1
		add.w     t_act_line(a6),d1
		move.w    d1,t_act_line(a6)
		move.w    t_cheight(a6),d5
		sub.w     d1,d5
		bgt       text_par1
		move.l    (a7)+,t_image(a6)
		rts
textp_it3:
		movem.w   d2/d4-d6,-(a7)
		tst.w     t_act_line(a6)
		bne.s     text_par16
		add.w     t_left_offset(a6),d3
		sub.w     t_whole_width(a6),d3
text_par16:
		move.w    #$5555,d6
		moveq.l   #0,d0
		move.w    d4,d7
textp_it4:
		moveq.l   #0,d4
		movem.l   d0/d2-d7/a0-a5,-(a7)
		bsr       textblt_2
		movem.l   (a7)+,d0/d2-d7/a0-a5
		ror.w     #1,d6
		bcc.s     textp_it5
		addq.w    #1,d3
textp_it5:
		addq.w    #1,d2
		addq.w    #1,d0
		dbf       d7,textp_it4
		movem.w   (a7)+,d2/d4-d6
		bra.s     text_par15
textp_ro2:
		subq.w    #1,d7
		bne.s     textp_ro3
		movem.l   d6/a3/a5,-(a7)
		bsr       rotate180
		movem.l   (a7)+,d6/a3/a5
		btst      #2,t_effects+1(a6)
		bne.s     textp_it6
		sub.w     d5,d3
		movem.l   d2-d6/a3/a5,-(a7)
		bsr       textblt_1
		movem.l   (a7)+,d2-d6/a3/a5
		subq.w    #1,d3
text_par17:
		moveq.l   #16,d1
		add.w     t_act_line(a6),d1
		move.w    d1,t_act_line(a6)
		move.w    t_cheight(a6),d5
		sub.w     d1,d5
		bgt       text_par1
		move.l    (a7)+,t_image(a6)
		rts
textp_it6:
		movem.w   d5-d6,-(a7)
		tst.w     t_act_line(a6)
		bne.s     text_par18
		add.w     t_left_offset(a6),d2
		sub.w     t_whole_width(a6),d2
text_par18:
		move.w    #$5555,d6
		move.w    d5,d7
		move.w    d5,d1
textp_it7:
		moveq.l   #0,d5
		movem.l   d1-d7/a0-a5,-(a7)
		moveq.l   #0,d0
		bsr       textblt
		movem.l   (a7)+,d1-d7/a0-a5
		ror.w     #1,d6
		bcc.s     textp_it8
		addq.w    #1,d2
textp_it8:
		subq.w    #1,d3
		subq.w    #1,d1
		dbf       d7,textp_it7
		movem.w   (a7)+,d5-d6
		bra.s     text_par17
textp_ro3:
		movem.l   d6/a3/a5,-(a7)
		bsr       rotate270
		movem.l   (a7)+,d6/a3/a5
		btst      #2,t_effects+1(a6)
		bne.s     textp_it9
		sub.w     d4,d2
		movem.l   d2-d6/a3/a5,-(a7)
		bsr       textblt_1
		movem.l   (a7)+,d2-d6/a3/a5
		subq.w    #1,d2
text_par19:
		moveq.l   #16,d1
		add.w     t_act_line(a6),d1
		move.w    d1,t_act_line(a6)
		move.w    t_cheight(a6),d5
		sub.w     d1,d5
		bgt       text_par1
		move.l    (a7)+,t_image(a6)
		rts
textp_it9:
		movem.w   d5-d6,-(a7)
		tst.w     t_act_line(a6)
		bne.s     text_par20
		sub.w     t_left_offset(a6),d3
		add.w     t_whole_width(a6),d3
text_par20:
		move.w    #$5555,d6
		move.w    d4,d0
		move.w    d4,d7
textp_it10:
		moveq.l   #0,d4
		movem.l   d0/d2-d7/a0-a5,-(a7)
		bsr       textblt_2
		movem.l   (a7)+,d0/d2-d7/a0-a5
		ror.w     #1,d6
		bcc.s     textp_it11
		subq.w    #1,d3
textp_it11:
		subq.w    #1,d2
		subq.w    #1,d0
		dbf       d7,textp_it10
		movem.w   (a7)+,d5-d6
		bra.s     text_par19
text:
		move.w    n_intin(a1),d6
		ble.s     text_exi
		subq.w    #1,d6
		clr.l     t_act_line(a6)
		moveq.l   #0,d5
		move.w    t_effects(a6),d0
		btst      #0,d0
		beq.s     text_eff
		move.w    t_thicken(a6),d5
text_eff:
		btst      #4,d0
		beq.s     text_thi
		addq.w    #2,d5
text_thi:
		move.w    d5,t_eff_theight(a6)
		movea.l   t_fonthdr(a6),a0
		move.l    76(a0),t_image(a6)
		movea.l   a2,a5
		movea.l   t_offtab(a6),a4
		tst.b     t_prop(a6)
		beq.s     text_mon
		movem.w   t_first_ade(a6),d0-d1
		moveq.l   #-1,d4
		move.w    d6,d7
text_wid1:
		move.w    (a2)+,d2
		sub.w     d0,d2
		cmp.w     d1,d2
		bls.s     text_wid2
		move.w    t_space_ver(a6),d2
text_wid2:
		add.w     d2,d2
		move.w    2(a4,d2.w),d3
		sub.w     0(a4,d2.w),d3
		tst.b     t_grow(a6)
		beq.s     text_wid3
		mulu.w    t_cheight(a6),d3
		divu.w    t_iheight(a6),d3
text_wid3:
		add.w     d5,d3
		add.w     d3,d4
		dbf       d7,text_wid1
		tst.w     d4
		bpl.s     text_pos
text_exi:
		rts
text_mon:
		move.w    t_cwidth(a6),d4
		add.w     d5,d4
		addq.w    #1,d6
		mulu.w    d6,d4
		subq.w    #1,d6
		subq.w    #1,d4
text_pos:
		move.w    (a3)+,d0
		move.w    (a3)+,d1
		move.w    t_ver(a6),d3
		add.w     d3,d3
		move.w    t_base(a6,d3.w),d3
		move.w    t_cheight(a6),d5
		subq.w    #1,d5
		btst      #4,t_effects+1(a6)
		beq.s     text_ali
		addq.w    #1,d3
		addq.w    #2,d5
text_ali:
		moveq.l   #0,d2
		move.w    t_hor(a6),d7
		beq.s     text_left
		subq.w    #1,d7
		bne.s     text_right
		move.w    d4,d2
		addq.w    #1,d2
		asr.w     #1,d2
		bra.s     text_left
text_right:
		move.w    d4,d2
text_left:
		move.w    t_rotation(a6),d7
		beq       text_cli2
		subq.w    #1,d7
		bne       text_cli1
		tst.w     t_add_len(a6)
		beq.s     text_cl90_1
		btst      #2,t_effects+1(a6)
		beq.s     text_cl90_1
		sub.w     t_left_offset(a6),d1
text_cl90_1:
		sub.w     d3,d0
		add.w     d2,d1
		move.w    d0,d2
		move.w    d1,d3
		add.w     d5,d2
		sub.w     d4,d1
		cmp.w     clip_xmax(a6),d0
		bgt.s     text_exi
		cmp.w     clip_xmin(a6),d2
		blt.s     text_exi
		cmp.w     clip_ymax(a6),d1
		ble.s     text_cl90_2
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d1,d7
		add.w     t_left_offset(a6),d7
		sub.w     t_whole_width(a6),d7
		cmp.w     clip_ymax(a6),d7
		bgt       text_exi
text_cl90_2:
		cmp.w     clip_ymin(a6),d3
		bge.s     text_cl90_3
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d3,d7
		add.w     t_left_offset(a6),d7
		cmp.w     clip_ymin(a6),d7
		blt       text_exi
text_cl90_3:
		cmp.w     clip_ymin(a6),d1
		bge       text_cl90_9
		movem.w   d0/d2-d5,-(a7)
		movem.w   t_first_ade(a6),d2-d3
		move.w    t_eff_theight(a6),d5
		move.w    d6,d7
		add.w     d7,d7
		lea.l     2(a5,d7.w),a2
		btst      #2,t_effects+1(a6)
		beq.s     text_cl90_4
		add.w     t_left_offset(a6),d1
text_cl90_4:
		move.w    -(a2),d0
		sub.w     d2,d0
		cmp.w     d3,d0
		bls.s     text_cl90_5
		move.w    t_space_ver(a6),d2
text_cl90_5:
		add.w     d0,d0
		move.w    2(a4,d0.w),d4
		sub.w     0(a4,d0.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		add.w     d4,d1
		cmp.w     clip_ymin(a6),d1
		bgt.s     text_cl90_8
		tst.w     d6
		beq.s     text_cl90_8
		move.w    t_add_len(a6),d7
		beq.s     text_cl90_7
		ext.l     d7
		move.w    t_space_(a6),d0
		bmi.s     text_cl90_6
		cmpi.w    #32,(a2)
		bne.s     text_cl90_7
		divs.w    d0,d7
		add.w     d7,d1
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl90_4
text_cl90_6:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		add.w     d7,d1
text_cl90_7:
		dbf       d6,text_cl90_4
text_cl90_8:
		sub.w     d4,d1
		movem.w   (a7)+,d0/d2-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl90_9
		sub.w     t_left_offset(a6),d1
text_cl90_9:
		cmp.w     clip_ymax(a6),d3
		ble       text_cl270_15
		movem.w   d0-d2/d4-d5,-(a7)
		movem.w   t_first_ade(a6),d0-d1
		move.w    t_eff_theight(a6),d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl90_10
		add.w     t_left_offset(a6),d3
		sub.w     t_whole_width(a6),d3
text_cl90_10:
		move.w    (a5)+,d2
		sub.w     d0,d2
		cmp.w     d1,d2
		bls.s     text_cl90_11
		move.w    t_space_ver(a6),d2
text_cl90_11:
		add.w     d2,d2
		move.w    2(a4,d2.w),d4
		sub.w     0(a4,d2.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		sub.w     d4,d3
		cmp.w     clip_ymax(a6),d3
		blt.s     text_cl90_14
		tst.w     d6
		beq.s     text_cl90_14
		move.w    t_add_len(a6),d7
		beq.s     text_cl90_13
		ext.l     d7
		move.w    t_space_(a6),d2
		bmi.s     text_cl90_12
		cmpi.w    #32,-2(a5)
		bne.s     text_cl90_13
		divs.w    d2,d7
		sub.w     d7,d3
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl90_10
text_cl90_12:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		sub.w     d7,d3
text_cl90_13:
		dbf       d6,text_cl90_10
text_cl90_14:
		add.w     d4,d3
		subq.l    #2,a5
		movem.w   (a7)+,d0-d2/d4-d5
		btst      #2,t_effects+1(a6)
		beq       text_cl270_15
		sub.w     t_left_offset(a6),d3
		add.w     t_whole_width(a6),d3
		bra       text_cl270_15
text_cli1:
		subq.w    #1,d7
		bne       text270
		tst.w     t_add_len(a6)
		beq.s     text_cl180_1
		btst      #2,t_effects+1(a6)
		beq.s     text_cl180_1
		sub.w     t_left_offset(a6),d0
text_cl180_1:
		add.w     d2,d0
		add.w     d3,d1
		move.w    d0,d2
		move.w    d1,d3
		sub.w     d4,d0
		sub.w     d5,d1
		cmp.w     clip_ymax(a6),d1
		bgt       text_exi
		cmp.w     clip_ymin(a6),d3
		blt       text_exi
		cmp.w     clip_xmax(a6),d0
		ble.s     text_cl180_2
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d0,d7
		add.w     t_left_offset(a6),d7
		sub.w     t_whole_width(a6),d7
		cmp.w     clip_xmax(a6),d7
		bgt       text_exi
text_cl180_2:
		cmp.w     clip_xmin(a6),d2
		bge.s     text_cl180_3
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d2,d7
		add.w     t_left_offset(a6),d7
		cmp.w     clip_xmin(a6),d7
		blt       text_exi
text_cl180_3:
		cmp.w     clip_xmin(a6),d0
		bge       text_cl180_9
		movem.w   d1-d5,-(a7)
		movem.w   t_first_ade(a6),d2-d3
		move.w    t_eff_theight(a6),d5
		move.w    d6,d7
		add.w     d7,d7
		lea.l     2(a5,d7.w),a2
		btst      #2,t_effects+1(a6)
		beq.s     text_cl180_4
		add.w     t_left_offset(a6),d0
text_cl180_4:
		move.w    -(a2),d1
		sub.w     d2,d1
		cmp.w     d3,d1
		bls.s     text_cl180_5
		move.w    t_space_ver(a6),d1
text_cl180_5:
		add.w     d1,d1
		move.w    2(a4,d1.w),d4
		sub.w     0(a4,d1.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		add.w     d4,d0
		cmp.w     clip_xmin(a6),d0
		bgt.s     text_cl180_8
		tst.w     d6
		beq.s     text_cl180_8
		move.w    t_add_len(a6),d7
		beq.s     text_cl180_7
		ext.l     d7
		move.w    t_space_(a6),d1
		bmi.s     text_cl180_6
		cmpi.w    #32,(a2)
		bne.s     text_cl180_7
		divs.w    d1,d7
		add.w     d7,d0
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl180_4
text_cl180_6:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		add.w     d7,d0
text_cl180_7:
		dbf       d6,text_cl180_4
text_cl180_8:
		sub.w     d4,d0
		movem.w   (a7)+,d1-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl180_9
		sub.w     t_left_offset(a6),d0
text_cl180_9:
		cmp.w     clip_xmax(a6),d2
		ble       text_cl0_14
		movem.w   d0-d1/d3-d5,-(a7)
		movem.w   t_first_ade(a6),d0-d1
		move.w    t_eff_theight(a6),d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl180_10
		add.w     t_left_offset(a6),d2
		sub.w     t_whole_width(a6),d2
text_cl180_10:
		move.w    (a5)+,d3
		sub.w     d0,d3
		cmp.w     d1,d3
		bls.s     text_cl180_11
		move.w    t_space_ver(a6),d3
text_cl180_11:
		add.w     d3,d3
		move.w    2(a4,d3.w),d4
		sub.w     0(a4,d3.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		sub.w     d4,d2
		cmp.w     clip_xmax(a6),d2
		blt.s     text_cl180_14
		tst.w     d6
		beq.s     text_cl180_14
		move.w    t_add_len(a6),d7
		beq.s     text_cl180_13
		ext.l     d7
		move.w    t_space_(a6),d3
		bmi.s     text_cl180_12
		cmpi.w    #32,-2(a5)
		bne.s     text_cl180_13
		divs.w    d3,d7
		sub.w     d7,d2
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl180_10
text_cl180_12:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		sub.w     d7,d2
text_cl180_13:
		dbf       d6,text_cl180_10
text_cl180_14:
		add.w     d4,d2
		subq.l    #2,a5
		movem.w   (a7)+,d0-d1/d3-d5
		btst      #2,t_effects+1(a6)
		beq       text_cl0_14
		sub.w     t_left_offset(a6),d2
		add.w     t_whole_width(a6),d2
		bra       text_cl0_14
text270:
		tst.w     t_add_len(a6)
		beq.s     text_cl270_1
		btst      #2,t_effects+1(a6)
		beq.s     text_cl270_1
		add.w     t_left_offset(a6),d1
text_cl270_1:
		add.w     d3,d0
		sub.w     d2,d1
		move.w    d0,d2
		move.w    d1,d3
		sub.w     d5,d0
		add.w     d4,d3
		cmp.w     clip_xmax(a6),d0
		bgt       text_exi
		cmp.w     clip_xmin(a6),d2
		blt       text_exi
		cmp.w     clip_ymax(a6),d1
		ble.s     text_cl270_2
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d1,d7
		sub.w     t_left_offset(a6),d7
		cmp.w     clip_ymax(a6),d7
		bgt       text_exi
text_cl270_2:
		cmp.w     clip_ymin(a6),d3
		bge.s     text_cl270_3
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d3,d7
		sub.w     t_left_offset(a6),d7
		add.w     t_whole_width(a6),d7
		cmp.w     clip_ymin(a6),d7
		blt       text_exi
text_cl270_3:
		cmp.w     clip_ymin(a6),d1
		bge       text_cl270_9
		movem.w   d0/d2-d5,-(a7)
		movem.w   t_first_ade(a6),d2-d3
		move.w    t_eff_theight(a6),d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl270_4
		sub.w     t_left_offset(a6),d1
		add.w     t_whole_width(a6),d1
text_cl270_4:
		move.w    (a5)+,d0
		sub.w     d2,d0
		cmp.w     d3,d0
		bls.s     text_cl270_5
		move.w    t_space_ver(a6),d0
text_cl270_5:
		add.w     d0,d0
		move.w    2(a4,d0.w),d4
		sub.w     0(a4,d0.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		add.w     d4,d1
		cmp.w     clip_ymin(a6),d1
		bgt.s     text_cl270_8
		tst.w     d6
		beq.s     text_cl270_8
		move.w    t_add_len(a6),d7
		beq.s     text_cl270_7
		ext.l     d7
		move.w    t_space_(a6),d0
		bmi.s     text_cl270_6
		cmpi.w    #32,-2(a5)
		bne.s     text_cl270_7
		divs.w    d0,d7
		add.w     d7,d1
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl270_4
text_cl270_6:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		add.w     d7,d1
text_cl270_7:
		dbf       d6,text_cl270_4
text_cl270_8:
		sub.w     d4,d1
		subq.l    #2,a5
		movem.w   (a7)+,d0/d2-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl270_9
		add.w     t_left_offset(a6),d1
		sub.w     t_whole_width(a6),d1
text_cl270_9:
		cmp.w     clip_ymax(a6),d3
		ble       text_cl270_15
		movem.w   d0-d2/d4-d5,-(a7)
		movem.w   t_first_ade(a6),d0-d1
		move.w    t_eff_theight(a6),d5
		move.w    d6,d7
		add.w     d7,d7
		lea.l     2(a5,d7.w),a2
		btst      #2,t_effects+1(a6)
		beq.s     text_cl270_10
		sub.w     t_left_offset(a6),d3
text_cl270_10:
		move.w    -(a2),d2
		sub.w     d0,d2
		cmp.w     d1,d2
		bls.s     text_cl270_11
		move.w    t_space_ver(a6),d2
text_cl270_11:
		add.w     d2,d2
		move.w    2(a4,d2.w),d4
		sub.w     0(a4,d2.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		sub.w     d4,d3
		cmp.w     clip_ymax(a6),d3
		blt.s     text_cl270_14
		tst.w     d6
		beq.s     text_cl270_14
		move.w    t_add_len(a6),d7
		beq.s     text_cl270_13
		ext.l     d7
		move.w    t_space_(a6),d2
		bmi.s     text_cl270_12
		cmpi.w    #32,(a2)
		bne.s     text_cl270_13
		divs.w    d2,d7
		sub.w     d7,d3
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl270_10
text_cl270_12:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		sub.w     d7,d3
text_cl270_13:
		dbf       d6,text_cl270_10
text_cl270_14:
		add.w     d4,d3
		movem.w   (a7)+,d0-d2/d4-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl270_15
		add.w     t_left_offset(a6),d3
text_cl270_15:
		move.w    d3,d4
		sub.w     d1,d4
		bra       text_buf1
text_cli2:
		tst.w     t_add_len(a6)
		beq.s     text_cl0_1
		btst      #2,t_effects+1(a6)
		beq.s     text_cl0_1
		add.w     t_left_offset(a6),d0
text_cl0_1:
		sub.w     d2,d0
		sub.w     d3,d1
		move.w    d0,d2
		move.w    d1,d3
		add.w     d4,d2
		add.w     d5,d3
		cmp.w     clip_ymax(a6),d1
		bgt       text_exi
		cmp.w     clip_ymin(a6),d3
		blt       text_exi
		cmp.w     clip_xmax(a6),d0
		ble.s     text_cli3
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d0,d7
		sub.w     t_left_offset(a6),d7
		cmp.w     clip_xmax(a6),d7
		bgt       text_exi
text_cli3:
		cmp.w     clip_xmin(a6),d2
		bge.s     text_cl0_2
		btst      #2,t_effects+1(a6)
		beq       text_exi
		move.w    d2,d7
		sub.w     t_left_offset(a6),d7
		add.w     t_whole_width(a6),d7
		cmp.w     clip_xmin(a6),d7
		blt       text_exi
text_cl0_2:
		cmp.w     clip_xmin(a6),d0
		bge       text_cl0_8
		movem.w   d1-d5,-(a7)
		movem.w   t_first_ade(a6),d2-d3
		move.w    t_eff_theight(a6),d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl0_3
		sub.w     t_left_offset(a6),d0
		add.w     t_whole_width(a6),d0
text_cl0_3:
		move.w    (a5)+,d1
		sub.w     d2,d1
		cmp.w     d3,d1
		bls.s     text_cl0_4
		move.w    t_space_ver(a6),d1
text_cl0_4:
		add.w     d1,d1
		move.w    2(a4,d1.w),d4
		sub.w     0(a4,d1.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		add.w     d4,d0
		cmp.w     clip_xmin(a6),d0
		bgt.s     text_cl0_7
		tst.w     d6
		beq.s     text_cl0_7
		move.w    t_add_len(a6),d7
		beq.s     text_cl0_6
		ext.l     d7
		move.w    t_space_(a6),d1
		bmi.s     text_cl0_5
		cmpi.w    #32,-2(a5)
		bne.s     text_cl0_6
		divs.w    d1,d7
		add.w     d7,d0
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl0_3
text_cl0_5:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		add.w     d7,d0
text_cl0_6:
		dbf       d6,text_cl0_3
text_cl0_7:
		sub.w     d4,d0
		subq.l    #2,a5
		movem.w   (a7)+,d1-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl0_8
		add.w     t_left_offset(a6),d0
		sub.w     t_whole_width(a6),d0
text_cl0_8:
		cmp.w     clip_xmax(a6),d2
		ble       text_cl0_14
		movem.w   d0-d1/d3-d5,-(a7)
		move.w    d6,d7
		add.w     d7,d7
		lea.l     2(a5,d7.w),a2
		movem.w   t_first_ade(a6),d0-d1
		move.w    t_eff_theight(a6),d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl0_9
		sub.w     t_left_offset(a6),d2
text_cl0_9:
		move.w    -(a2),d3
		sub.w     d0,d3
		cmp.w     d1,d3
		bls.s     text_cl0_10
		move.w    t_space_ver(a6),d3
text_cl0_10:
		add.w     d3,d3
		move.w    2(a4,d3.w),d4
		sub.w     0(a4,d3.w),d4
		mulu.w    t_cheight(a6),d4
		divu.w    t_iheight(a6),d4
		add.w     d5,d4
		sub.w     d4,d2
		cmp.w     clip_xmax(a6),d2
		blt.s     text_cl0_13
		tst.w     d6
		beq.s     text_cl0_13
		move.w    t_add_len(a6),d7
		beq.s     text_cl0_12
		ext.l     d7
		move.w    t_space_(a6),d3
		bmi.s     text_cl0_11
		cmpi.w    #32,(a2)
		bne.s     text_cl0_12
		divs.w    d3,d7
		sub.w     d7,d2
		sub.w     d7,t_add_len(a6)
		subq.w    #1,t_space_(a6)
		dbf       d6,text_cl0_9
text_cl0_11:
		divs.w    d6,d7
		sub.w     d7,t_add_len(a6)
		sub.w     d7,d2
text_cl0_12:
		dbf       d6,text_cl0_9
text_cl0_13:
		add.w     d4,d2
		movem.w   (a7)+,d0-d1/d3-d5
		btst      #2,t_effects+1(a6)
		beq.s     text_cl0_14
		add.w     t_left_offset(a6),d2
text_cl0_14:
		move.w    d2,d4
		sub.w     d0,d4
text_buf1:
		addi.w    #16,d4
		lsr.w     #4,d4
		add.w     d4,d4
		movea.w   d4,a3
		move.w    d5,d7
		addq.w    #1,d7
		tst.w     t_rotation(a6)
		beq.s     text_buf2
		addi.w    #15,d7
		andi.w    #$FFF0,d7
text_buf2:
		mulu.w    d4,d7
		move.l    buffer_l(a6),d4
		btst      #4,t_effects+1(a6)
		bne.s     text_buf3
		tst.w     t_rotation(a6)
		beq.s     text_buf4
text_buf3:
		lsr.l     #1,d4
text_buf4:
		cmp.l     d4,d7
		bgt       text_par
		movem.w   d0-d1,-(a7)
		move.w    t_cheight(a6),d5
		subq.w    #1,d5
		bsr       fill_tex
		movea.l   buffer_a(a6),a0
		movea.w   a3,a2
		move.w    t_effects(a6),d7
		beq.s     text_out2
text_bol:
		btst      #0,d7
		beq.s     text_und
		bsr       bold
text_und:
		btst      #3,t_effects+1(a6)
		beq.s     text_out1
		bsr       underlin1
text_out1:
		btst      #4,t_effects+1(a6)
		beq.s     text_lig
		bsr       outline
text_lig:
		btst      #1,t_effects+1(a6)
		beq.s     text_out2
		bsr       light
text_out2:
		movem.w   (a7)+,d2-d3
		move.w    t_rotation(a6),d7
		bne.s     text_rot2
text_rot1:
		btst      #2,t_effects+1(a6)
		beq       textblt_1
text_ita1:
		sub.w     t_left_offset(a6),d2
		add.w     t_whole_width(a6),d2
text_ita2:
		move.w    #$5555,d6
		moveq.l   #0,d1
		move.w    d5,d7
text_ita3:
		movem.w   d1-d4/d6-d7/a2-a3,-(a7)
		move.l    a0,-(a7)
		moveq.l   #0,d0
		moveq.l   #0,d5
		bsr       textblt
		movea.l   (a7)+,a0
		movem.w   (a7)+,d1-d4/d6-d7/a2-a3
		ror.w     #1,d6
		bcc.s     text_ita4
		subq.w    #1,d2
text_ita4:
		addq.w    #1,d1
		addq.w    #1,d3
		dbf       d7,text_ita3
		rts
text_rot2:
		subq.w    #1,d7
		bne.s     text_rot3
		bsr       rotate90
		btst      #2,t_effects+1(a6)
		beq       textblt_1
text_ita5:
		add.w     t_left_offset(a6),d3
		sub.w     t_whole_width(a6),d3
text_ita6:
		move.w    #$5555,d6
		move.w    d4,d7
text_ita7:
		movem.w   d0/d2-d3/d5-d7/a2-a3,-(a7)
		move.l    a0,-(a7)
		moveq.l   #0,d1
		moveq.l   #0,d4
		bsr       textblt
		movea.l   (a7)+,a0
		movem.w   (a7)+,d0/d2-d3/d5-d7/a2-a3
		ror.w     #1,d6
		bcc.s     text_ita8
		addq.w    #1,d3
text_ita8:
		addq.w    #1,d0
		addq.w    #1,d2
		dbf       d7,text_ita7
		rts
text_rot3:
		subq.w    #1,d7
		bne.s     text_rot4
		bsr       rotate180
		btst      #2,t_effects+1(a6)
		beq       textblt_1
		add.w     t_left_offset(a6),d2
		bra       text_ita2
text_rot4:
		bsr       rotate270
		btst      #2,t_effects+1(a6)
		beq       textblt_1
		sub.w     t_left_offset(a6),d3
		bra.s     text_ita6
underlin1:
		move.w    t_act_line(a6),d0
		move.w    d0,d1
		add.w     d5,d1
		move.w    t_uline(a6),d2
		move.w    t_base(a6),d3
		addq.w    #2,d3
		move.w    t_cheight(a6),d7
		subq.w    #1,d7
		cmp.w     d7,d3
		ble.s     underlin2
		move.w    d7,d3
underlin2:
		add.w     d3,d2
		cmp.w     d7,d2
		ble.s     underlin3
		move.w    d7,d2
underlin3:
		cmp.w     d1,d3
		bgt.s     underlin8
		cmp.w     d0,d2
		blt.s     underlin8
		cmp.w     d1,d2
		ble.s     underlin4
		move.w    d1,d2
underlin4:
		cmp.w     d0,d3
		bge.s     underlin5
		move.w    d0,d3
underlin5:
		sub.w     d3,d2
		bmi.s     underlin8
		sub.w     d0,d3
		move.w    a2,d0
		mulu.w    d3,d0
		movea.l   a0,a1
		adda.w    d0,a1
		move.w    d4,d0
		lsr.w     #4,d0
		moveq.l   #-1,d1
		moveq.l   #15,d3
		and.w     d4,d3
		add.w     d3,d3
		move.w    underlin_tab(pc,d3.w),d3
		movea.w   a2,a3
		suba.w    d0,a3
		suba.w    d0,a3
		subq.w    #2,a3
underlin6:
		move.w    d0,d6
underlin7:
		move.w    d1,(a1)+
		dbf       d6,underlin7
		and.w     d3,-2(a1)
		adda.w    a3,a1
		dbf       d2,underlin6
underlin8:
		rts
underlin_tab:
		dc.w	$8000,$C000,$E000,$F000
		dc.w	$F800,$FC00,$FE00,$FF00
		dc.w	$FF80,$FFC0,$FFE0,$FFF0
		dc.w	$FFF8,$FFFC,$FFFE,$FFFF

bold:
		move.w	d5,-(a7)
		movea.l	a0,a4
		move.w	a2,d6
		lsr.w     #1,d6
		subq.w    #1,d6
		move.w    t_thicken(a6),d2
		beq.s     bold_loo
		add.w     d2,d4
		subq.w    #1,d2
bold_loo:
		move.w    d6,d7
		move.w    (a4)+,d0
bold_fet:
		swap      d0
		clr.w     d0
		move.l    d0,d1
		move.w    d2,d3
bold_thi:
		ror.l     #1,d0
		or.l      d0,d1
		dbf       d3,bold_thi
		move.w    (a4)+,d0
		or.l      d1,-4(a4)
		dbf       d7,bold_fet
		move.w    d0,-(a4)
		dbf       d5,bold_loo
		move.w    (a7)+,d5
		rts
outline:
		movea.l   a0,a1
		move.l    buffer_l(a6),d0
		lsr.l     #1,d0
		adda.l    d0,a1
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.w    a2,d2
		lsr.w     #1,d2
		subq.w    #1,d2
		moveq.l   #16,d0
		addq.w    #2,d4
		add.w     d4,d0
		lsr.w     #4,d0
		add.w     d0,d0
		movea.w   d0,a2
		movea.w   d0,a3
		adda.w    d0,a3
		move.w    d5,d1
		addq.w    #3,d1
		mulu.w    d1,d0
		lsr.w     #2,d0
		moveq.l   #0,d1
		movea.l   a1,a4
outlined1:
		move.l    d1,(a4)+
		dbf       d0,outlined1
		move.w    d5,d6
outlined2:
		move.w    d2,d3
		movea.l   a1,a4
outlined3:
		moveq.l   #0,d0
		move.w    (a0)+,d0
		swap      d0
		move.l    d0,d1
		ror.l     #1,d1
		or.l      d1,d0
		ror.l     #1,d1
		or.l      d1,d0
		or.l      d0,(a4)
		or.l      d0,0(a4,a2.w)
		or.l      d0,0(a4,a3.w)
		addq.l    #2,a4
		dbf       d3,outlined3
		adda.w    a2,a1
		dbf       d6,outlined2
		movea.l   (a7),a1
		movea.l   4(a7),a0
		move.w    d5,d6
		adda.w    a2,a1
outlined4:
		move.w    d2,d3
		movea.l   a1,a4
outlined5:
		moveq.l   #0,d0
		move.w    (a0)+,d0
		swap      d0
		ror.l     #1,d0
		eor.l     d0,(a4)
		addq.l    #2,a4
		dbf       d3,outlined5
		adda.w    a2,a1
		dbf       d6,outlined4
		movea.l   (a7)+,a0
		movea.l   (a7)+,a1
		addq.w    #2,d5
		rts
light:
		move.w    #$5555,d0
		moveq.l   #15,d6
		and.w     t_act_line(a6),d6
		ror.w     d6,d0
		movea.l   a0,a3
		move.w    a2,d1
		lsr.w     #1,d1
		subq.w    #1,d1
		move.w    d5,d7
		btst      #2,t_effects+1(a6)
		bne.s     light_it
light_lo1:
		move.w    d1,d6
light_lo2:
		and.w     d0,(a3)+
		dbf       d6,light_lo2
		ror.w     #1,d0
		dbf       d7,light_lo1
		rts
light_it:
		move.w    #$5555,d2
		ror.w     d6,d2
light_i_1:
		move.w    d1,d6
light_i_2:
		and.w     d0,(a3)+
		dbf       d6,light_i_2
		ror.w     #1,d0
		ror.w     #1,d2
		bcc.s     light_i_3
		ror.w     #1,d0
light_i_3:
		dbf       d7,light_i_1
		rts
rotate90:
		movea.l   a0,a1
		move.l    buffer_l(a6),d0
		lsr.l     #1,d0
		adda.l    d0,a1
		cmpa.l    buffer_a(a6),a0
		beq.s     rotate90_1
		movea.l   buffer_a(a6),a1
rotate90_1:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		movem.w   d2-d3/d5,-(a7)
		moveq.l   #16,d6
		move.w    d5,d0
		add.w     d6,d0
		andi.w    #$FFF0,d0
		move.w    d0,d7
		add.w     d7,d7
		lsr.w     #3,d0
		movea.w   d0,a3
		movea.l   a1,a4
		mulu.w    d4,d0
		adda.w    d0,a1
		add.w     a3,d0
		lsr.w     #4,d0
		moveq.l   #0,d1
rotate90_2:
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		dbf       d0,rotate90_2
		move.w    #$8000,d2
rotate90_3:
		move.w    d4,d3
		movea.l   a0,a4
		movea.l   a1,a5
		adda.w    a2,a0
		bra.s     rotate90_5
rotate90_4:
		dbf       d1,rotate90_6
rotate90_5:
		moveq.l   #15,d1
		move.w    (a4)+,d0
		bne.s     rotate90_6
		sub.w     d6,d3
		bmi.s     rotate90_8
		move.w    (a4)+,d0
		suba.w    d7,a5
rotate90_6:
		add.w     d0,d0
		bcc.s     rotate90_7
		or.w      d2,(a5)
rotate90_7:
		suba.w    a3,a5
		dbf       d3,rotate90_4
rotate90_8:
		ror.w     #1,d2
		bcc.s     rotate90_9
		addq.l    #2,a1
rotate90_9:
		dbf       d5,rotate90_3
		movem.w   (a7)+,d2-d3/d5
		movea.l   (a7)+,a0
		movea.l   (a7)+,a1
		exg       d4,d5
		movea.w   a3,a2
		rts
rotate180:
		movea.l   a0,a1
		move.l    buffer_l(a6),d0
		lsr.l     #1,d0
		adda.l    d0,a1
		cmpa.l    buffer_a(a6),a0
		beq.s     rotate180_1
		movea.l   buffer_a(a6),a1
rotate180_1:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		movem.w   d2-d3/d5,-(a7)
		moveq.l   #16,d6
		movea.l   a1,a4
		move.w    a2,d0
		mulu.w    d5,d0
		add.w     a2,d0
		adda.w    d0,a1
		lsr.w     #4,d0
		moveq.l   #0,d1
rotate180_2:
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		dbf       d0,rotate180_2
		moveq.l   #15,d0
		and.w     d4,d0
		move.w    #$8000,d2
		lsr.w     d0,d2
		movea.w   d2,a4
rotate180_3:
		move.w    a4,d2
		move.w    d4,d3
		moveq.l   #0,d7
		bra.s     rotate180_5
rotate180_4:
		dbf       d1,rotate180_6
rotate180_5:
		moveq.l   #15,d1
		move.w    (a0)+,d0
		bne.s     rotate180_6
		move.w    d7,-(a1)
		sub.w     d6,d3
		bmi.s     rotate180_9
		move.w    (a0)+,d0
		moveq.l   #0,d7
rotate180_6:
		add.w     d0,d0
		bcc.s     rotate180_7
		or.w      d2,d7
rotate180_7:
		add.w     d2,d2
		bcc.s     rotate180_8
		moveq.l   #1,d2
		move.w    d7,-(a1)
		moveq.l   #0,d7
rotate180_8:
		dbf       d3,rotate180_4
rotate180_9:
		dbf       d5,rotate180_3
		movem.w   (a7)+,d2-d3/d5
		movea.l   (a7)+,a0
		movea.l   (a7)+,a1
		rts
rotate270:
		movea.l   a0,a1
		move.l    buffer_l(a6),d0
		lsr.l     #1,d0
		adda.l    d0,a1
		cmpa.l    buffer_a(a6),a0
		beq.s     rotate270_1
		movea.l   buffer_a(a6),a1
rotate270_1:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		movem.w   d2-d3/d5,-(a7)
		moveq.l   #16,d6
		move.w    d5,d0
		add.w     d6,d0
		andi.w    #$FFF0,d0
		move.w    d0,d7
		add.w     d7,d7
		lsr.w     #3,d0
		movea.w   d0,a3
		movea.l   a1,a4
		mulu.w    d4,d0
		add.w     a3,d0
		lsr.w     #4,d0
		moveq.l   #0,d1
rotate270_2:
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		move.l    d1,(a4)+
		dbf       d0,rotate270_2
		move.w    #$8000,d2
		move.w    a2,d0
		mulu.w    d5,d0
		adda.w    d0,a0
rotate270_3:
		move.w    d4,d3
		movea.l   a0,a4
		movea.l   a1,a5
		bra.s     rotate270_5
rotate270_4:
		dbf       d1,rotate270_6
rotate270_5:
		moveq.l   #15,d1
		move.w    (a4)+,d0
		bne.s     rotate270_6
		sub.w     d6,d3
		bmi.s     rotate270_8
		move.w    (a4)+,d0
		adda.w    d7,a5
rotate270_6:
		add.w     d0,d0
		bcc.s     rotate270_7
		or.w      d2,(a5)
rotate270_7:
		adda.w    a3,a5
		dbf       d3,rotate270_4
rotate270_8:
		suba.w    a2,a0
		ror.w     #1,d2
		bcc.s     rotate270_9
		addq.l    #2,a1
rotate270_9:
		dbf       d5,rotate270_3
		movem.w   (a7)+,d2-d3/d5
		movea.l   (a7)+,a0
		movea.l   (a7)+,a1
		exg       d4,d5
		movea.w   a3,a2
		rts
textblt_1:
		moveq.l   #0,d0
textblt_2:
		moveq.l   #0,d1
textblt:
		move.w    d5,d7
		add.w     d2,d4
		add.w     d3,d5
		lea.l     clip_xmin(a6),a1
		cmp.w     (a1)+,d2
		bge.s     textblt_3
		sub.w     d2,d0
		move.w    -2(a1),d2
		add.w     d2,d0
textblt_3:
		cmp.w     (a1)+,d3
		bge.s     textblt_4
		sub.w     d3,d1
		move.w    -2(a1),d3
		add.w     d3,d1
textblt_4:
		cmp.w     (a1)+,d4
		ble.s     textblt_5
		move.w    -2(a1),d4
textblt_5:
		cmp.w     (a1),d5
		ble.s     textblt_6
		move.w    (a1),d5
textblt_6:
		sub.w     d2,d4
		bmi.s     textblt_7
		sub.w     d3,d5
		bmi.s     textblt_7
		movea.l   p_textblit(a6),a4
		jmp       (a4)
textblt_7:
		rts
fill_tex:
		movea.w   t_iwidth(a6),a2
		movea.l   t_offtab(a6),a4
ftb_eff:
		move.w    a3,d0
		mulu.w    d5,d0
		add.w     a3,d0
		lsr.w     #4,d0
		moveq.l   #0,d1
		movea.l   buffer_a(a6),a1
ftb_clea:
		move.l    d1,(a1)+
		move.l    d1,(a1)+
		move.l    d1,(a1)+
		move.l    d1,(a1)+
		dbf       d0,ftb_clea
		movea.l   buffer_a(a6),a1
		moveq.l   #0,d2
		moveq.l   #15,d7
		move.w    t_eff_theight(a6),d3
		addq.w    #1,d3
		tst.b     t_grow(a6)
		bne       ftb_grow1
ftb_loop:
		move.w    (a5)+,d0
		sub.w     t_first_ade(a6),d0
		cmp.w     t_ades(a6),d0
		bls.s     ftb_posi
		move.w    t_space_ver(a6),d0
ftb_posi:
		add.w     d0,d0
		movem.w   0(a4,d0.w),d0/d4
		sub.w     d0,d4
		subq.w    #1,d4
		bmi.s     ftb_next
		movea.l   t_image(a6),a0
		move.w    d0,d1
		lsr.w     #4,d1
		add.w     d1,d1
		adda.w    d1,a0
		and.w     d7,d0
		movem.w   d3/d5-d6/a2-a3,-(a7)
		add.w     d2,d3
		add.w     d4,d3
		move.w    d3,-(a7)
		move.l    a1,-(a7)
		bsr.s     copy_to_
		movea.l   (a7)+,a1
		movem.w   (a7)+,d2-d3/d5-d6/a2-a3
		tst.w     t_add_len(a6)
		beq.s     ftb_no_o
		bsr.s     text_off
ftb_no_o:
		cmp.w     d7,d2
		ble.s     ftb_next
		move.w    d2,d4
		lsr.w     #4,d4
		add.w     d4,d4
		adda.w    d4,a1
		and.w     d7,d2
ftb_next:
		dbf       d6,ftb_loop
		move.l    a1,d4
		sub.l     buffer_a(a6),d4
		lsl.w     #3,d4
		add.w     d2,d4
		sub.w     d3,d4
		rts
text_off:
		move.w    d6,d0
		beq.s     text_off2
		move.w    t_space_(a6),d4
		bmi.s     text_off1
		cmpi.w    #32,-2(a5)
		bne.s     text_off2
		subq.w    #1,t_space_(a6)
		move.w    d4,d0
text_off1:
		move.w    t_add_len(a6),d4
		ext.l     d4
		divs.w    d0,d4
		sub.w     d4,t_add_len(a6)
		add.w     d4,d2
		bpl.s     text_off2
		move.w    d2,d4
		neg.w     d4
		lsr.w     #4,d4
		addq.w    #1,d4
		add.w     d4,d4
		suba.w    d4,a1
		and.w     d7,d2
		cmpa.l    buffer_a(a6),a1
		bpl.s     text_off2
		movea.l   buffer_a(a6),a1
		moveq.l   #0,d2
text_off2:
		rts
copy_to_:
		cmp.w     #7,d4
		bne.s     cptb_no_
		tst.w     d0
		beq       cptb_byt2
		cmp.w     #8,d0
		beq       cptb_byt1
cptb_no_:
		sub.w     d2,d0
		move.w    d2,d1
		add.w     d4,d1
		lsr.w     #4,d1
		add.w     d2,d4
		not.w     d4
		and.w     d7,d4
		moveq.l   #-1,d3
		lsr.w     d2,d3
		moveq.l   #-1,d2
		lsl.w     d4,d2
		subq.w    #1,d1
		bmi       cptb_1wo
		beq       cptb_1lo
		move.w    d1,d4
		addq.w    #1,d4
		add.w     d4,d4
		suba.w    d4,a2
		suba.w    d4,a3
		subq.w    #1,d1
		tst.w     d0
		beq.s     cptb_mul1
		blt.s     cptbm_r
		cmpi.w    #8,d0
		ble.s     cptb_mul3
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_mul2
cptbm_r:
		neg.w     d0
		subq.l    #2,a0
		cmpi.w    #8,d0
		ble.s     cptb_mul2
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_mul3
cptb_mul1:
		move.w    d1,d4
		move.w    (a0)+,d6
		and.w     d3,d6
		or.w      d6,(a1)+
cptbm_lo1:
		move.w    (a0)+,(a1)+
		dbf       d4,cptbm_lo1
		move.w    (a0),d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_mul1
		rts
cptb_mul2:
		move.w    d1,d4
		move.l    (a0),d6
		addq.l    #2,a0
		ror.l     d0,d6
		and.w     d3,d6
		or.w      d6,(a1)+
cptbm_lo2:
		move.l    (a0),d6
		addq.l    #2,a0
		ror.l     d0,d6
		move.w    d6,(a1)+
		dbf       d4,cptbm_lo2
		move.l    (a0),d6
		ror.l     d0,d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_mul2
		rts
cptb_mul3:
		move.w    d1,d4
		move.l    (a0),d6
		addq.l    #2,a0
		swap      d6
		rol.l     d0,d6
		and.w     d3,d6
		or.w      d6,(a1)+
cptbm_lo3:
		move.l    (a0),d6
		addq.l    #2,a0
		swap      d6
		rol.l     d0,d6
		move.w    d6,(a1)+
		dbf       d4,cptbm_lo3
		move.l    (a0),d6
		swap      d6
		rol.l     d0,d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_mul3
		rts
cptb_1wo:
		and.w     d3,d2
		move.w    d2,d3
		not.w     d3
		tst.w     d0
		beq.s     cptb_wor1
		blt.s     cptb_wr
		cmpi.w    #8,d0
		ble.s     cptb_wor3
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_wor2
cptb_wr:
		neg.w     d0
		subq.l    #2,a0
		cmpi.w    #8,d0
		ble.s     cptb_wor2
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_wor3
cptb_wor1:
		move.w    (a0),d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_wor1
		rts
cptb_wor2:
		move.l    (a0),d6
		ror.l     d0,d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_wor2
		rts
cptb_wor3:
		move.l    (a0),d6
		swap      d6
		rol.l     d0,d6
		and.w     d2,d6
		or.w      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_wor3
		rts
cptb_1lo:
		swap      d3
		move.w    d2,d3
		move.l    d3,d2
		not.l     d3
		tst.w     d0
		beq.s     cptb_lon1
		blt.s     cptb_lr
		cmpi.w    #8,d0
		ble.s     cptb_lon3
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_lon2
cptb_lr:
		neg.w     d0
		subq.l    #2,a0
		cmpi.w    #8,d0
		ble.s     cptb_lon2
		subq.w    #1,d0
		eor.w     d7,d0
		bra.s     cptb_lon3
cptb_lon1:
		move.l    (a0),d6
		and.l     d2,d6
		or.l      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_lon1
		rts
cptb_lon2:
		move.l    (a0),d6
		ror.l     d0,d6
		swap      d6
		move.l    2(a0),d4
		ror.l     d0,d4
		move.w    d4,d6
		and.l     d2,d6
		or.l      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_lon2
		rts
cptb_lon3:
		move.l    (a0),d6
		rol.l     d0,d6
		move.l    2(a0),d4
		swap      d4
		rol.l     d0,d4
		move.w    d4,d6
		and.l     d2,d6
		or.l      d6,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_lon3
		rts
cptb_byt1:
		addq.l    #1,a0
cptb_byt2:
		not.w     d2
		and.w     d7,d2
		addq.w    #1,d2
cptb_byt3:
		moveq.l   #0,d0
		movep.w   0(a0),d0
		clr.b     d0
		lsl.l     d2,d0
		or.l      d0,(a1)
		adda.w    a2,a0
		adda.w    a3,a1
		dbf       d5,cptb_byt3
		rts
ftb_grow1:
		move.w    (a5)+,d0
		sub.w     t_first_ade(a6),d0
		cmp.w     t_ades(a6),d0
		bls.s     ftb_grow2
		move.w    t_space_ver(a6),d0
ftb_grow2:
		add.w     d0,d0
		movem.w   0(a4,d0.w),d0/d4
		sub.w     d0,d4
		subq.w    #1,d4
		bmi.s     ftb_grow3
		movea.l   t_image(a6),a0
		move.w    d0,d1
		lsr.w     #4,d1
		add.w     d1,d1
		adda.w    d1,a0
		and.w     d7,d0
		movem.w   d2-d3/d5-d6/a2-a3,-(a7)
		movem.l   a1/a4-a6,-(a7)
		pea.l     ftb_retu(pc)
		tst.b     t_grow(a6)
		bmi       grow_cha3
		bra       shrink_c1
ftb_retu:
		movem.l   (a7)+,a1/a4-a6
		movem.w   (a7)+,d2-d3/d5-d6/a2-a3
		add.w     d3,d2
		add.w     d4,d2
		tst.w     t_add_len(a6)
		beq.s     ftbg_no_
		bsr       text_off
ftbg_no_:
		cmp.w     d7,d2
		ble.s     ftb_grow3
		move.w    d2,d4
		lsr.w     #4,d4
		add.w     d4,d4
		adda.w    d4,a1
		and.w     d7,d2
ftb_grow3:
		dbf       d6,ftb_grow1
		move.l    a1,d4
		sub.l     buffer_a(a6),d4
		lsl.w     #3,d4
		add.w     d2,d4
		sub.w     d3,d4
		rts
grow_byt1:
		addq.l    #1,a0
grow_byt2:
		moveq.l   #15,d4
grow_byt3:
		moveq.l   #0,d1
		move.b    (a0),d0
		adda.w    a2,a0
		beq.s     grow_byt6
		moveq.l   #7,d3
grow_byt4:
		add.w     d1,d1
		add.w     d1,d1
		add.b     d0,d0
		bcc.s     grow_byt5
		addq.w    #3,d1
grow_byt5:
		dbf       d3,grow_byt4
		move.w    d1,(a1)
		adda.w    a3,a1
		move.w    d1,(a1)
		adda.w    a3,a1
		dbf       d5,grow_byt3
		rts
grow_byt6:
		adda.w    a3,a1
		adda.w    a3,a1
		dbf       d5,grow_byt3
		rts
grow_cha1:
		lsr.w     #1,d5
		cmp.w     #7,d4
		bne.s     grow_cha2
		tst.w     d2
		bne.s     grow_cha2
		tst.w     d0
		beq.s     grow_byt2
		cmp.w     #8,d0
		beq.s     grow_byt1
grow_cha2:
		move.w    d2,d3
		move.w    d0,d2
		eor.w     d7,d2
		subq.w    #7,d2
		bgt.s     grow_db_1
		addq.l    #1,a0
		addq.w    #8,d2
grow_db_1:
		movea.l   a0,a4
		movea.l   a1,a5
		move.w    d4,d7
grow_db_2:
		moveq.l   #7,d6
		cmp.w     d6,d7
		bge.s     grow_db_3
		move.w    d7,d6
grow_db_3:
		subq.w    #8,d7
		moveq.l   #0,d1
		movep.w   0(a4),d0
		addq.l    #1,a4
		move.b    (a4),d0
		lsr.w     d2,d0
grow_db_4:
		add.w     d1,d1
		add.w     d1,d1
		add.b     d0,d0
		bcc.s     grow_db_5
		addq.w    #3,d1
grow_db_5:
		dbf       d6,grow_db_4
		tst.w     d7
		bpl.s     grow_db_6
		move.w    d7,d6
		addq.w    #1,d6
		neg.w     d6
		add.w     d6,d6
		lsl.w     d6,d1
grow_db_6:
		ror.l     d3,d1
		swap      d1
		or.l      d1,(a5)
		or.l      d1,0(a5,a3.w)
		addq.l    #2,a5
		tst.w     d7
		bpl.s     grow_db_2
		adda.w    a2,a0
		adda.w    a3,a1
		adda.w    a3,a1
		dbf       d5,grow_db_1
		add.w     d4,d4
		addq.w    #1,d4
		moveq.l   #15,d7
		rts
grow_cha3:
		move.w    t_iheight(a6),d1
		add.w     d1,d1
		move.w    t_cheight(a6),d6
		cmp.w     d6,d1
		beq       grow_cha1
		move.w    d5,-(a7)
		swap      d2
		move.w    d0,d2
		move.w    t_iheight(a6),d5
		addq.w    #1,d4
		mulu.w    d6,d4
		divu.w    d5,d4
		subq.w    #1,d4
		moveq.l   #16,d1
		add.w     d4,d1
		swap      d2
		add.w     d2,d1
		swap      d2
		lsr.w     #4,d1
		subq.w    #1,d1
		swap      d1
		moveq.l   #-1,d7
		swap      d2
		lsr.w     d2,d7
		swap      d2
		move.w    d7,d1
		movea.w   d5,a4
		sub.w     d6,d5
		movea.w   d5,a5
		move.w    d5,d3
		swap      d3
		move.w    d5,d3
		move.w    (a7)+,d5
pte_grow1:
		bsr.s     grow_lin
		adda.w    a2,a0
		swap      d3
		tst.w     d3
		bmi.s     grow_hei
pte_grow2:
		add.w     a5,d3
		swap      d3
		adda.w    a3,a1
		dbf       d5,pte_grow1
		bra.s     pte_grow3
grow_loo1:
		tst.w     d3
		bpl.s     pte_grow2
grow_hei:
		move.l    d1,d7
		swap      d7
		movea.l   a1,a6
		adda.w    a3,a6
		move.l    a6,-(a7)
		move.w    (a1)+,d6
		and.w     d1,d6
		or.w      d6,(a6)+
		bra.s     grow_nex1
grow_loo2:
		move.w    (a1)+,(a6)+
grow_nex1:
		dbf       d7,grow_loo2
		movea.l   (a7)+,a1
		add.w     a4,d3
		dbf       d5,grow_loo1
pte_grow3:
		moveq.l   #15,d7
		rts
grow_lin:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.l    d1,-(a7)
		move.w    d3,-(a7)
		move.w    d4,-(a7)
		move.w    #$8000,d6
		moveq.l   #0,d7
		bra.s     grow_rea
grow_nex2:
		add.w     a5,d3
		ror.w     #1,d6
		dbcs      d4,grow_loo3
		swap      d2
		ror.l     d2,d7
		swap      d2
		swap      d7
		or.l      d7,(a1)
		addq.l    #2,a1
		moveq.l   #0,d7
		subq.w    #1,d4
		bmi.s     grow_exi
grow_loo3:
		dbf       d0,grow_tes
grow_rea:
		moveq.l   #15,d0
		move.l    (a0),d1
		addq.l    #2,a0
		lsl.l     d2,d1
		swap      d1
grow_tes:
		btst      d0,d1
		beq.s     grow_whi
		or.w      d6,d7
grow_whi:
		tst.w     d3
		bpl.s     grow_nex2
		add.w     a4,d3
		ror.w     #1,d6
		dbcs      d4,grow_tes
		swap      d2
		ror.l     d2,d7
		swap      d2
		swap      d7
		or.l      d7,(a1)
		addq.l    #2,a1
		moveq.l   #0,d7
		subq.w    #1,d4
		bpl.s     grow_tes
grow_exi:
		move.w    (a7)+,d4
		move.w    (a7)+,d3
		move.l    (a7)+,d1
		movea.l   (a7)+,a1
		movea.l   (a7)+,a0
		rts
shrink_c1:
		addq.w    #1,d5
		move.w    t_cheight(a6),d7
		mulu.w    t_iheight(a6),d5
		divu.w    d7,d5
		subq.w    #1,d5
		move.w    d5,-(a7)
		swap      d2
		move.w    d0,d2
		move.w    t_iheight(a6),d5
		addq.w    #1,d4
		mulu.w    d7,d4
		divu.w    d5,d4
		subq.w    #1,d4
		bpl.s     shrink_p
		move.w    (a7)+,d5
		bra.s     shrink_c3
shrink_p:
		movea.w   d7,a4
		sub.w     d5,d7
		movea.w   d7,a5
		move.w    d7,d3
		swap      d3
		move.w    d7,d3
		move.w    (a7)+,d5
shrink_c2:
		bsr.s     shrink_l
		adda.w    a2,a0
		adda.w    a3,a1
		swap      d3
		tst.w     d3
		bpl.s     shrink_h
		add.w     a4,d3
		suba.w    a3,a1
		swap      d3
		dbf       d5,shrink_c2
		bra.s     shrink_c3
shrink_h:
		add.w     a5,d3
		swap      d3
		dbf       d5,shrink_c2
shrink_c3:
		moveq.l   #15,d7
		rts
shrink_l:
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.w    d1,-(a7)
		move.w    d3,-(a7)
		move.w    d4,-(a7)
		move.w    #$8000,d6
		moveq.l   #0,d7
		bra.s     shrink_r
shrink_n:
		add.w     a5,d3
		ror.w     #1,d6
		dbcs      d4,shrink_l1
		swap      d2
		ror.l     d2,d7
		swap      d2
		swap      d7
		or.l      d7,(a1)
		addq.l    #2,a1
		moveq.l   #0,d7
		subq.w    #1,d4
		bmi.s     shrink_e
shrink_l1:
		dbf       d0,shrink_t
shrink_r:
		moveq.l   #15,d0
		move.l    (a0),d1
		addq.l    #2,a0
		lsl.l     d2,d1
		swap      d1
shrink_t:
		btst      d0,d1
		beq.s     shrink_w
		or.w      d6,d7
shrink_w:
		tst.w     d3
		bpl.s     shrink_n
		add.w     a4,d3
		bra.s     shrink_l1
shrink_e:
		move.w    (a7)+,d4
		move.w    (a7)+,d3
		move.w    (a7)+,d1
		movea.l   (a7)+,a1
		movea.l   (a7)+,a0
		rts
text_jus:
		move.w    n_intin(a1),d6
		subq.w    #3,d6
		cmp.w     #$7FFC,d6
		bhi       text_exi
		clr.w     t_act_line(a6)
		move.w    -2(a2),d3
		sne       d3
		ext.w     d3
		move.w    d3,t_space_(a6)
		moveq.l   #0,d5
		move.w    t_effects(a6),d0
		btst      #0,d0
		beq.s     textj_ou
		move.w    t_thicken(a6),d5
textj_ou:
		btst      #4,d0
		beq.s     textj_th
		addq.w    #2,d5
textj_th:
		move.w    d5,t_eff_theight(a6)
		movem.w   t_first_ade(a6),d0-d1
		moveq.l   #-1,d4
		move.w    d6,d7
		movea.l   t_fonthdr(a6),a0
		move.l    dat_table(a0),t_image(a6)
		movea.l   a2,a5
		movea.l   t_offtab(a6),a4
textj_wi1:
		move.w    (a2)+,d2
		tst.w     d3
		bmi.s     textj_ch
		cmp.w     #32,d2
		bne.s     textj_ch
		addq.w    #1,t_space_(a6)
textj_ch:
		sub.w     d0,d2
		cmp.w     d1,d2
		bls.s     textj_wi2
		move.w    t_space_ver(a6),d2
textj_wi2:
		add.w     d2,d2
		lea.l     2(a4,d2.w),a0
		move.w    (a0),d2
		sub.w     -(a0),d2
		tst.b     t_grow(a6)
		beq.s     textj_ad
		mulu.w    t_cheight(a6),d2
		divu.w    t_iheight(a6),d2
textj_ad:
		add.w     d5,d2
		add.w     d2,d4
		dbf       d7,textj_wi1
		tst.w     d4
		bmi       text_exi
textj_le:
		move.w    4(a3),d3
		btst      #2,t_effects+1(a6)
		beq.s     textj_sp
		sub.w     t_whole_width(a6),d3
textj_sp:
		tst.w     t_space_(a6)
		bpl.s     textj_di
		cmp.w     t_cwidth(a6),d3
		bge.s     textj_di
		move.w    t_cwidth(a6),d3
textj_di:
		subq.w    #1,d3
		neg.w     d4
		add.w     d3,d4
		move.w    d4,t_add_len(a6)
		move.w    d3,d4
		move.w    t_space_(a6),d7
		bmi       text_pos
		move.w    t_add_len(a6),d2
		bpl       text_pos
		move.w    t_space_hor(a6),d0
		add.w     d0,d0
		lea.l     2(a4,d0.w),a0
		move.w    (a0),d0
		sub.w     -(a0),d0
		mulu.w    t_cheight(a6),d0
		divu.w    t_iheight(a6),d0
		mulu.w    d7,d0
		neg.w     d0
		cmp.w     d2,d0
		ble       text_pos
		sub.w     d2,d4
		add.w     d0,d4
		move.w    d0,t_add_len(a6)
		bra       text_pos
fellipse1:
		tst.w     d4
		bne.s     fellipse2
		cmpi.w    #3600,d5
		beq       fellipse5
fellipse2:
		tst.w     d5
		bne.s     fellipse3
		cmpi.w    #3600,d4
		beq       fellipse5
fellipse3:
		movea.l   buffer_a(a6),a1
		move.l    buffer_l(a6),-(a7)
		move.l    a1,-(a7)
		move.w    d0,(a1)+
		move.w    d1,(a1)+
		bsr.s     ellipse_2
		movea.l   (a7),a3
		move.l    (a3),(a1)+
		move.l    a1,d1
		sub.l     a3,d1
		move.l    a1,buffer_a(a6)
		move.l    d1,buffer_l(a6)
		move.w    d0,d4
		addq.w    #1,d4
		bmi.s     fellipse4
		bsr       v_fillarray3
fellipse4:
		move.l    (a7)+,buffer_a(a6)
		move.l    (a7)+,buffer_l(a6)
		rts
ellipse_1:
		movea.l   buffer_a(a6),a1
ellipse_2:
		ext.l     d4
		ext.l     d5
		move.w    #3600,d6
		cmp.w     d4,d5
		bne.s     ellipse_4
		divs.w    d6,d4
		clr.w     d4
		swap      d4
		tst.w     d4
		bpl.s     ellipse_3
		add.w     d6,d4
ellipse_3:
		divs.w    #10,d4
		bsr       ellipse_14
		move.l    -4(a1),(a1)+
		moveq.l   #2,d0
		rts
ellipse_4:
		divs.w    d6,d4
		clr.w     d4
		swap      d4
		tst.w     d4
		bpl.s     ellipse_5
		add.w     d6,d4
ellipse_5:
		divs.w    d6,d5
		clr.w     d5
		swap      d5
		tst.w     d5
		bpl.s     ellipse_6
		add.w     d6,d5
ellipse_6:
		cmp.w     d4,d5
		bgt.s     ellipse_7
		add.w     d6,d5
ellipse_7:
		divs.w    #10,d4
		divs.w    #10,d5
		bsr       ellipse_14
		move.l    d5,-(a7)
		lea.l     sin,a0
ellipse_8:
		cmp.w     #100,d2
		bgt.s     ellipse_9
		cmp.w     #100,d3
		bgt.s     ellipse_9
		cmp.w     #20,d2
		ble.s     ellipse_9
		cmp.w     #20,d3
		ble.s     ellipse_9
		addq.w    #8,d4
		andi.w    #$FFF8,d4
		movea.w   #16,a2
		add.w     d4,d4
		adda.w    d4,a0
		lsr.w     #4,d4
		lsr.w     #3,d5
		bra.s     ellipse_11
ellipse_9:
		cmp.w     #300,d2
		bgt.s     ellipse_10
		cmp.w     #300,d3
		bgt.s     ellipse_10
		addq.w    #4,d4
		andi.w    #$FFFC,d4
		movea.w   #8,a2
		add.w     d4,d4
		adda.w    d4,a0
		lsr.w     #3,d4
		lsr.w     #2,d5
		bra.s     ellipse_11
ellipse_10:
		addq.w    #2,d4
		andi.w    #$FFFE,d4
		movea.w   #4,a2
		add.w     d4,d4
		adda.w    d4,a0
		lsr.w     #2,d4
		lsr.w     #1,d5
ellipse_11:
		sub.w     d4,d5
		moveq.l   #1,d4
		subq.w    #1,d5
		bmi.s     ellipse_13
		move.l    #$8000,d7
ellipse_12:
		move.w    (a0),d6
		muls.w    d2,d6
		add.l     d6,d6
		add.l     d7,d6
		swap      d6
		add.w     d0,d6
		bvc.s     ell_noov1
		tst.w     d6
		bmi.s     ell_over1
		move.w    #$8001,d6
		bra.s     ell_noov1
ell_over1:
		move.w    #$7FFF,d6
ell_noov1:
		move.w    d6,(a1)+
		move.w    180(a0),d6
		muls.w    d3,d6
		add.l     d6,d6
		add.l     d7,d6
		swap      d6
		add.w     d1,d6
		bvc.s     ell_noov2
		tst.w     d6
		bmi.s     ell_over2
		move.w    #$8001,d6
		bra.s     ell_noov2
ell_over2:
		move.w    #$7FFF,d6
ell_noov2:
		move.w    d6,(a1)+
		move.l    -(a1),d6
		cmp.l     -4(a1),d6
		beq.s     ell_next
		addq.l    #4,a1
		addq.w    #1,d4
ell_next:
		adda.w    a2,a0
		dbf       d5,ellipse_12
ellipse_13:
		move.w    d4,d5
		addq.w    #1,d5
		move.l    (a7)+,d4
		bsr.s     ellipse_14
		move.w    d5,d0
		rts
ellipse_14:
		lea.l     sin,a0
		adda.w    d4,a0
		adda.w    d4,a0
		swap      d4
		move.w    (a0)+,d6
		move.w    (a0),d7
		sub.w     d6,d7
		muls.w    d4,d7
		add.l     d7,d7
		divs.w    #10,d7
		addq.w    #1,d7
		asr.w     #1,d7
		add.w     d7,d6
		muls.w    d2,d6
		add.l     d6,d6
		add.l     #$8000,d6
		swap      d6
		add.w     d0,d6
		bvc.s     ell_noov3
		tst.w     d6
		bmi.s     ell_over3
		move.w    #$8001,d6
		bra.s     ell_noov3
ell_over3:
		move.w    #$7FFF,d6
ell_noov3:
		move.w    d6,(a1)+
		lea.l     180(a0),a0
		move.w    (a0),d7
		move.w    -(a0),d6
		sub.w     d6,d7
		muls.w    d4,d7
		add.l     d7,d7
		divs.w    #10,d7
		addq.w    #1,d7
		asr.w     #1,d7
		add.w     d7,d6
		muls.w    d3,d6
		add.l     d6,d6
		add.l     #$8000,d6
		swap      d6
		add.w     d1,d6
		bvc.s     ell_noov4
		tst.w     d6
		bmi.s     ell_over4
		move.w    #$8001,d6
		bra.s     ell_noov4
ell_over4:
		move.w    #$7FFF,d6
ell_noov4:
		move.w    d6,(a1)+
		swap      d4
		rts
fellipse5:
		moveq.l   #0,d4
		move.w    #3600,d5
		cmp.w     #1000,d2
		bgt       fellipse3
		cmp.w     #1000,d3
		bgt       fellipse3
		bsr.s     fellipse
		tst.w     f_perimeter(a6)
		beq.s     fellipse6
		bsr       ellipse_1
		move.w    d0,d4
		movea.l   buffer_a(a6),a3
		bra       v_pline_8
fellipse6:
		rts
fellipse:
		movem.l   d0-d7/a0-a1,-(a7)
		movea.l   buffer_a(a6),a0
		tst.w     d2
		bgt.s     fellipse7
		neg.w     d2
fellipse7:
		tst.w     d3
		beq.s     fellipse9
		bgt.s     fellipse8
		neg.w     d3
fellipse8:
		bsr.s     fec
fellipse9:
		move.w    d0,d4
		sub.w     d2,d0
		add.w     d2,d2
		add.w     d0,d2
		movem.w   d0-d2/d4,-(a7)
		bsr       fline
		movem.w   (a7)+,d0-d2/d4
		tst.w     d3
		beq.s     fe_exit
		sub.w     d3,d1
		add.w     d3,d3
		add.w     d1,d3
fe_loop:
		move.w    d4,d0
		move.w    d4,d2
		sub.w     (a0),d0
		add.w     (a0)+,d2
		move.w    d4,-(a7)
		movem.w   d0-d2,-(a7)
		bsr       fline
		movem.w   (a7),d0-d2
		move.w    d3,d1
		bsr       fline
		movem.w   (a7)+,d0-d2
		move.w    (a7)+,d4
		addq.w    #1,d1
		subq.w    #1,d3
		cmp.w     d1,d3
		bne.s     fe_loop
fe_exit:
		movem.l   (a7)+,d0-d7/a0-a1
		rts
fec:
		tst.w     d2
		beq.s     fec_small1
		cmp.w     #1,d2
		beq.s     fec_small3
		cmp.w     #1,d3
		beq       fec_small6
		movem.l   d0-d7/a0,-(a7)
		clr.w     d0
		move.w    d3,d1
		mulu.w    d2,d2
		move.l    d2,d6
		move.l    d2,d7
		add.l     d2,d2
		mulu.w    d3,d3
		add.l     d3,d6
		add.l     d3,d3
		move.l    d2,d5
		move.w    d5,d4
		swap      d5
		mulu.w    d1,d5
		swap      d5
		clr.w     d5
		mulu.w    d1,d4
		add.l     d4,d5
		sub.l     d7,d5
		move.l    d3,d4
		lsr.l     #1,d4
		subq.w    #1,d1
		bmi.s     fec_exit
		bra.s     fec_plus
fec_loop:
		add.l     d5,d6
		sub.l     d2,d5
fec_plus:
		tst.l     d6
		bmi.s     fec_outp
fec_x_lo:
		sub.l     d4,d6
		add.l     d3,d4
		addq.w    #1,d0
		tst.l     d6
		bpl.s     fec_x_lo
fec_outp:
		subq.w    #1,d0
		move.w    d0,(a0)+
		addq.w    #1,d0
		dbf       d1,fec_loop
fec_exit:
		movem.l   (a7)+,d0-d7/a0
		rts
fec_small1:
		move.l    a0,-(a7)
		move.w    d3,-(a7)
fec_small2:
		clr.w     (a0)+
		dbf       d3,fec_small2
		move.w    (a7)+,d3
		movea.l   (a7)+,a0
		rts
fec_small3:
		movem.l   d0/d3/a0,-(a7)
		move.w    d3,d0
		add.w     d0,d0
		add.w     d3,d0
		lsr.w     #2,d0
		sub.w     d0,d3
		subq.w    #1,d3
fec_small4:
		clr.w     (a0)+
		dbf       d3,fec_small4
fec_small5:
		move.w    #1,(a0)+
		dbf       d0,fec_small5
		movem.l   (a7)+,d0/d3/a0
		rts
fec_small6:
		move.w    d0,-(a7)
		move.w    d2,d0
		add.w     d0,d0
		add.w     d2,d0
		lsr.w     #2,d0
		move.w    d0,(a0)
		move.w    (a7)+,d0
		rts
rbox_cal:
		movea.l   buffer_a(a6),a3
		cmp.w     d0,d2
		bge.s     rby1y2
		exg       d0,d2
rby1y2:
		cmp.w     d1,d3
		bge.s     rbtestx
		exg       d1,d3
rbtestx:
		move.w    d2,d4
		sub.w     d0,d4
		cmpi.w    #15,d4
		ble.s     rbsmall
rbtesty:
		move.w    d3,d4
		sub.w     d1,d4
		cmpi.w    #15,d4
		bgt.s     rbnormal
rbsmall:
		subq.w    #3,d4
		bpl.s     rbsmall2
		move.w    d0,(a3)+
		move.w    d1,(a3)+
		move.w    d2,(a3)+
		move.w    d1,(a3)+
		move.w    d2,(a3)+
		move.w    d3,(a3)+
		move.w    d0,(a3)+
		move.w    d3,(a3)+
		move.w    d0,(a3)+
		move.w    d1,(a3)+
		moveq.l   #5,d4
		rts
rbsmall2:
		move.w    d0,d4
		move.w    d1,d5
		move.w    d2,d6
		move.w    d3,d7
		addq.w    #1,d4
		addq.w    #1,d5
		subq.w    #1,d6
		subq.w    #1,d7
		move.w    d4,(a3)+
		move.w    d1,(a3)+
		move.w    d6,(a3)+
		move.w    d1,(a3)+
		move.w    d2,(a3)+
		move.w    d5,(a3)+
		move.w    d2,(a3)+
		move.w    d7,(a3)+
		move.w    d6,(a3)+
		move.w    d3,(a3)+
		move.w    d4,(a3)+
		move.w    d3,(a3)+
		move.w    d0,(a3)+
		move.w    d7,(a3)+
		move.w    d0,(a3)+
		move.w    d5,(a3)+
		moveq.l   #8,d4
		rts
rbnormal:
		addq.w    #8,d0
		subq.w    #8,d2
		move.w    d0,(a3)+
		move.w    d1,(a3)+
		move.w    d2,(a3)+
		move.w    d1,(a3)+
		moveq.l   #7,d4
		lea.l     round(pc),a4
rbloop1:
		add.w     (a4)+,d2
		addq.w    #1,d1
		move.w    d2,(a3)+
		move.w    d1,(a3)+
		dbf       d4,rbloop1
		subq.w    #8,d3
		move.w    d2,(a3)+
		move.w    d3,(a3)+
		moveq.l   #7,d4
rbloop2:
		sub.w     -(a4),d2
		addq.w    #1,d3
		move.w    d2,(a3)+
		move.w    d3,(a3)+
		dbf       d4,rbloop2
		move.w    d0,(a3)+
		move.w    d3,(a3)+
		lea.l     round(pc),a4
		moveq.l   #7,d4
rbloop3:
		sub.w     (a4)+,d0
		subq.w    #1,d3
		move.w    d0,(a3)+
		move.w    d3,(a3)+
		dbf       d4,rbloop3
		move.w    d0,(a3)+
		move.w    d1,(a3)+
		moveq.l   #7,d4
rbloop4:
		add.w     -(a4),d0
		subq.w    #1,d1
		move.w    d0,(a3)+
		move.w    d1,(a3)+
		dbf       d4,rbloop4
		moveq.l   #37,d4
		rts
frbox:
		movem.l   d0-d7/a0-a1,-(a7)
frbx1x2:
		cmp.w     d0,d2
		bge.s     frby1y2
		exg       d0,d2
frby1y2:
		cmp.w     d1,d3
		bge.s     frbtestx
		exg       d1,d3
frbtestx:
		move.w    d2,d4
		sub.w     d0,d4
		cmpi.w    #15,d4
		ble.s     frbsmall
frbtesty:
		move.w    d3,d4
		sub.w     d1,d4
		cmpi.w    #15,d4
		bgt.s     frbnormal
frbsmall:
		subq.w    #3,d4
		bpl.s     frbsb
		bsr.s     fbox
		bra.s     frbexit
frbsb:
		addq.w    #1,d0
		subq.w    #1,d2
		bsr       fline_sa
		addq.w    #1,d1
		exg       d1,d3
		bsr       fline_sa
		subq.w    #1,d1
		exg       d1,d3
		subq.w    #1,d0
		addq.w    #1,d2
		bsr.s     fbox
		bra.s     frbexit
frbnormal:
		addq.w    #8,d0
		subq.w    #8,d2
		moveq.l   #7,d4
		lea.l     round(pc),a0
frbloop:
		move.w    d4,-(a7)
		movem.w   d0-d2,-(a7)
		bsr       fline
		movem.w   (a7),d0-d2
		move.w    d3,d1
		bsr       fline
		movem.w   (a7)+,d0-d2
		move.w    (a7)+,d4
		sub.w     (a0),d0
		add.w     (a0)+,d2
		addq.w    #1,d1
		subq.w    #1,d3
		dbf       d4,frbloop
		cmp.w     d1,d3
		blt.s     frbexit
		bsr.s     fbox
frbexit:
		movem.l   (a7)+,d0-d7/a0-a1
		rts
round:
		ori.b     #$02,d2
		ori.b     #$01,d1
		ori.b     #$01,d0
		ori.b     #$01,d0
fbox:
		movem.l   d0-d7/a0-a6,-(a7)
		bsr.s     fbox_nor
		movem.l   (a7)+,d0-d7/a0-a6
fbox_exit:
		rts
fbox_nor:
		cmp.w     d0,d2
		bge.s     fbox_exg
		exg       d0,d2
fbox_exg:
		cmp.w     d1,d3
		bge.s     fbox_clip1
		exg       d1,d3
fbox_clip1:
		lea.l     clip_xmin(a6),a1
fbox_clip2:
		cmp.w     (a1)+,d0
		bge.s     fbox_clip3
		move.w    -2(a1),d0
fbox_clip3:
		cmp.w     (a1)+,d1
		bge.s     fbox_clip4
		move.w    -2(a1),d1
fbox_clip4:
		cmp.w     (a1)+,d2
		ble.s     fbox_clip5
		move.w    -2(a1),d2
fbox_clip5:
		cmp.w     d0,d2
		blt.s     fbox_exit
fbox_clip6:
		cmp.w     (a1),d3
		ble.s     fbox_clip7
		move.w    (a1),d3
fbox_clip7:
		cmp.w     d1,d3
		blt.s     fbox_exit
		movea.l   p_fbox(a6),a1 ; ??? where is that set?
		jmp       (a1)
fline_sa:
		movem.l   d0-d2/d4-d7/a1,-(a7)
		bsr.s     fline
		movem.l   (a7)+,d0-d2/d4-d7/a1
		rts
fline:
		cmp.w     d0,d2
		bge.s     fline_cl
		exg       d0,d2
fline_cl:
		lea.l     clip_xmin(a6),a1
fclip_x1:
		cmp.w     (a1)+,d0
		bge.s     fclip_y1
		move.w    -2(a1),d0
fclip_y1:
		cmp.w     (a1)+,d1
		blt.s     hline_ex
fclip_x2:
		cmp.w     (a1)+,d2
		ble.s     fclip_y2
		move.w    -2(a1),d2
fclip_y2:
		cmp.w     (a1)+,d1
		bgt.s     hline_ex
		cmp.w     d2,d0
		bgt.s     hline_ex
		move.w    (a1),d7
		movea.l   p_fline(a6),a1
		jmp       (a1)
fline_ex:
hline_ex:
		rts
hline:
		cmp.w     d0,d2
		bge.s     hline_cl
		exg       d0,d2
hline_cl:
		add.w     l_lastpix(a6),d2
		lea.l     clip_xmin(a6),a1
hclip_x1:
		cmp.w     (a1)+,d0
		bge.s     hclip_y1
		move.w    -2(a1),d0
hclip_y1:
		cmp.w     (a1)+,d1
		blt.s     hline_ex
hclip_x2:
		cmp.w     (a1)+,d2
		ble.s     hclip_y2
		move.w    -2(a1),d2
hclip_y2:
		cmp.w     (a1)+,d1
		bgt.s     hline_ex
		cmp.w     d2,d0
		bgt.s     hline_ex
		move.w    (a1),d7
		movea.l   p_hline(a6),a1
		jmp       (a1)
vline:
		cmp.w     d1,d3
		blt.s     vline_ch
		add.w     l_lastpix(a6),d3
		lea.l     clip_xmin(a6),a1
		cmp.w     (a1)+,d0
		blt.s     vline_ex
vclip_y1:
		cmp.w     (a1)+,d1
		bge.s     vclip_x
		move.w    -2(a1),d1
vclip_x:
		cmp.w     (a1)+,d0
		bgt.s     vline_ex
vclip_y2:
		cmp.w     (a1)+,d3
		ble.s     vclip_y_
		move.w    -2(a1),d3
vclip_y_:
		cmp.w     d3,d1
		bgt.s     vline_ex
		move.w    (a1)+,d7
		movea.l   p_vline(a6),a1
		jmp       (a1)
vline_ch:
Clipping:
		exg       d1,d3
		add.w     l_lastpix(a6),d3
		lea.l     clip_xmin(a6),a1
		cmp.w     (a1)+,d0
		blt.s     vline_ex
		cmp.w     (a1)+,d1
		bge.s     vclip_c_1
		move.w    -2(a1),d1
vclip_c_1:
		cmp.w     (a1)+,d0
		bgt.s     vline_ex
		cmp.w     (a1)+,d3
		ble.s     vclip_c_2
		move.w    -2(a1),d3
vclip_c_2:
		cmp.w     d3,d1
		bgt.s     vline_ex
		move.w    (a1)+,d7
		move.w    d3,d2
		sub.w     d1,d2
		andi.w    #15,d2
		ror.w     d2,d6
		movea.l   p_vline(a6),a1
		jmp       (a1)
vline_ex:
		rts
line:
		cmp.w     d0,d2
		bge.s     line_clip1
		exg       d0,d2
		exg       d1,d3
line_clip1:
		lea.l     clip_xmin(a6),a1
		cmp.w     clip_xmax(a6),d0
		bgt.s     line_exit
		cmp.w     (a1),d2
		blt.s     line_exit
		move.w    d2,d4
		sub.w     d0,d4
		cmp.w     d1,d3
		blt.s     line_clip5
		beq       hline
		move.w    d3,d5
		sub.w     d1,d5
		cmp.w     (a1)+,d0
		bge.s     line_clip2
		sub.w     -(a1),d0
		neg.w     d0
		mulu.w    d5,d0
		divu.w    d4,d0
		add.w     d0,d1
		move.w    (a1)+,d0
line_clip2:
		cmp.w     clip_ymax(a6),d1
		bgt.s     line_exit
		cmp.w     (a1)+,d1
		bge.s     line_clip3
		sub.w     -(a1),d1
		neg.w     d1
		mulu.w    d4,d1
		divu.w    d5,d1
		add.w     d1,d0
		move.w    (a1)+,d1
		cmp.w     (a1),d0
		bgt.s     line_exit
line_clip3:
		cmp.w     (a1)+,d2
		ble.s     line_clip4
		sub.w     -(a1),d2
		mulu.w    d5,d2
		divu.w    d4,d2
		sub.w     d2,d3
		move.w    (a1)+,d2
line_clip4:
		cmp.w     clip_ymin(a6),d3
		blt.s     line_exit
		cmp.w     (a1)+,d3
		ble.s     line_clip9
		sub.w     -(a1),d3
		muls.w    d4,d3
		divs.w    d5,d3
		sub.w     d3,d2
		move.w    (a1)+,d3
		cmp.w     clip_xmin(a6),d2
		bge.s     line_clip9
line_exit:
		rts
line_clip5:
		move.w    d1,d5
		sub.w     d3,d5
		cmp.w     (a1)+,d0
		bge.s     line_clip6
		sub.w     -(a1),d0
		neg.w     d0
		mulu.w    d5,d0
		divu.w    d4,d0
		sub.w     d0,d1
		move.w    (a1)+,d0
line_clip6:
		cmp.w     (a1)+,d1
		blt.s     line_exit
		cmp.w     clip_ymax(a6),d1
		ble.s     line_clip7
		sub.w     clip_ymax(a6),d1
		mulu.w    d4,d1
		divu.w    d5,d1
		add.w     d1,d0
		move.w    clip_ymax(a6),d1
		cmp.w     (a1),d0
		bgt.s     line_exit
line_clip7:
		cmp.w     (a1)+,d2
		ble.s     line_clip8
		sub.w     -(a1),d2
		mulu.w    d5,d2
		divu.w    d4,d2
		add.w     d2,d3
		move.w    (a1)+,d2
line_clip8:
		cmp.w     (a1)+,d3
		bgt.s     line_exit
		cmp.w     clip_ymin(a6),d3
		bge.s     line_clip9
		sub.w     clip_ymin(a6),d3
		neg.w     d3
		mulu.w    d4,d3
		divu.w    d5,d3
		sub.w     d3,d2
		move.w    clip_ymin(a6),d3
		cmp.w     clip_xmin(a6),d2
		blt.s     line_exit
line_clip9:
		cmp.w     d0,d2
		blt.s     line_exit
		move.w    (a1),d7
		movea.l   p_line(a6),a1
		jmp       (a1)
a_dummy:
		rts
linea_tab:
		dc.l	linea_init
		dc.l	put_pixel
		dc.l	get_pixel
		dc.l	linea_line
		dc.l	linea_hline
		dc.l	linea_rect
		dc.l	a_dummy ; filled polygon
		dc.l	linea_bit_blt
		dc.l	linea_text_blt
		dc.l	show_mouse
		dc.l	hide_mouse
		dc.l	transform_mouse
		dc.l	undraw_sprite
		dc.l	draw_sprite ; 8eaa
		dc.l	linea_copy_raster
linea_a0:
		dc.l	a_dummy ; seedfill
int_linea:
linea_di:
		movea.l   2(a7),a1
		move.w    (a1)+,d2
		move.l    a1,2(a7)
		subi.w    #$A00F,d2
		bgt.s     linea_ex1
		cmp.w     #$FFF1,d2
		beq.s     linea_ge
		movea.l   (linea_wk).w,a1
		movea.w   r_planes(a1),a1
		addq.w    #1,a1
		cmpa.w    (PLANES).w,a1
		bne.s     planes_c
linea_ge:
		add.w     d2,d2
		add.w     d2,d2
		movea.l   linea_a0(pc,d2.w),a1
		movem.l   d3-d7/a3-a5,-(a7)
		jsr       (a1)
		movem.l   (a7)+,d3-d7/a3-a5
linea_ex1:
		rte
planes_c:
		rte
linea_init:
		lea.l     (LINE_A_BASE).w,a0
		move.l    a0,d0
		lea.l     linea_fonts,a1
		lea.l     linea_tab(pc),a2
		rts
set_lclip:
		lea.l     clip_xmin(a6),a1
		clr.l     (a1)+
		move.l    #$7FFF7FFF,(a1)+
		move.w    (WMODE).w,(a1) ; wr_mode
		move.w    (PLANES).w,d0
		subq.w    #1,d0
		move.w    d0,r_planes(a6)
		rts
set_lclip2:
		tst.w     (CLIP).w
		beq.s     set_lclip
		lea.l     clip_xmin(a6),a1
		move.l    (XMINCL).w,(a1)+
		move.l    (XMAXCL).w,(a1)+
		move.w    (WMODE).w,(a1) ; wr_mode
		move.w    (PLANES).w,d0
		subq.w    #1,d0
		move.w    d0,r_planes(a6)
		rts
get_line:
		moveq.l   #0,d0
		moveq.l   #3,d1
		lea.l     (LSTLIN).w,a0
linea_co1:
		add.w     d0,d0
		tst.w     -(a0)
		beq.s     linea_co2
		addq.w    #1,d0
linea_co2:
		dbf       d1,linea_co1
		moveq.l   #15,d1
		and.w     colors(a6),d1
		and.w     d1,d0
		cmp.w     d0,d1
		bne.s     linea_co4
linea_co3:
		moveq.l   #1,d0
		rts
linea_co4:
		lea.l     color_rev_tab,a0
		move.b    0(a0,d0.w),d0
		rts
get_line2:
		movea.l   (PATPTR).w,a0
		lea.l     WK_LENGTH(a6),a1
		move.w    #4,f_interior(a6)
		move.l    a1,f_pointer(a6)
		move.w    (MFILL).w,f_splanes(a6)
		bne.s     get_lpat3
		movea.l   (scrtchp).w,a1
		move.w    (PATMSK).w,d0
		addq.w    #1,d0
		moveq.l   #16,d2
		divu.w    d0,d2
		subq.w    #1,d0
		subq.w    #1,d2
		bpl.s     get_lpat1
		moveq.l   #15,d0
		moveq.l   #0,d2
get_lpat1:
		move.w    d0,d1
		movea.l   a0,a2
get_lpat2:
		move.w    (a2)+,(a1)+
		dbf       d1,get_lpat2
		dbf       d2,get_lpat1
		movea.l   (scrtchp).w,a0
		moveq.l   #0,d0
		bra.s     get_lpat4
get_lpat3:
		move.w    r_planes(a6),d0
get_lpat4:
		addq.w    #1,d0
		lsl.w     #4,d0
		movea.l   f_spoints(a6),a1
		movea.l   p_set_pattern(a6),a2
		jmp       (a2)
put_pixel:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		movea.l   (INTIN).w,a0
		move.w    (a0)+,d2
		movea.l   (PTSIN).w,a0
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		movea.l   p_set_pixel(a6),a0
		jsr       (a0)
		movea.l   (a7)+,a6
		rts
get_pixel:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		movea.l   (PTSIN).w,a0
		move.w    (a0)+,d0
		move.w    (a0),d1
		movea.l   p_get_pixel(a6),a0
		jsr       (a0)
		movea.l   (a7)+,a6
		rts
linea_line:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		bsr       set_lclip
		bsr       get_line
		move.w    d0,l_color(a6)
		movem.w   (X1).w,d0-d3
		move.w    (LNMASK).w,d6
		tst.w     (LSTLIN).w
		seq       d4
		ext.w     d4
		move.w    d4,l_lastpix(a6)
		pea.l     linea_line1(pc)
		cmp.w     d1,d3
		beq       hline
		cmp.w     d0,d2
		beq       vline
		bra       line
linea_line1:
		clr.w     l_lastpix(a6)
		movea.l   (a7)+,a6
		rts
linea_hline:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		bsr       set_lclip
		bsr       get_line
		move.w    d0,f_color(a6)
		bsr       get_line2
		movem.w   (X1).w,d0-d2
		bsr       fline
		movea.l   (a7)+,a6
		rts
linea_rect:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		bsr       set_lclip2
		bsr       get_line
		move.w    d0,f_color(a6)
		bsr       get_line2
		movem.w   (X1).w,d0-d3
		bsr       fbox
		movea.l   (a7)+,a6
		rts
linea_bit_blt:
		move.l    a6,-(a7)
		movea.l   a6,a5 ; -> BITBLT structure
		movea.l   (linea_wk).w,a6
		move.l    18(a5),r_saddr(a6)
		move.w    24(a5),r_swidth(a6)
		move.w    26(a5),d0
		beq.s     linea_blt1
		move.w    4(a5),d0
		subq.w    #1,d0
linea_blt1:
		move.w    d0,r_splanes(a6)
		move.l    32(a5),r_daddr(a6)
		move.w    38(a5),r_dwidth(a6)
		move.w    40(a5),d0
		beq.s     linea_blt2
		move.w    4(a5),d0
		subq.w    #1,d0
linea_blt2:
		move.w    d0,r_dplanes(a6)
		move.w    14(a5),d0
		move.w    16(a5),d1
		move.w    28(a5),d2
		move.w    30(a5),d3
		move.w    (a5),d4
		subq.w    #1,d4
		move.w    2(a5),d5
		subq.w    #1,d5
		move.w    6(a5),d6
		move.w    8(a5),d7
		move.w    d6,r_fgcol(a6)
		move.w    d7,r_bgcol(a6)
		and.w     #1,d6
		and.w     #1,d7
		add.w     d6,d6
		add.w     d7,d6
		move.b    10(a5,d6.w),d7
		move.w    d7,r_wmode(a6)
		cmpi.w    #1,4(a5)
		bne.s     linea_bit_blt1
		movea.l   (mono_bitmap).w,a0
		jsr       (a0)
		bra.s     linea_blt3
linea_bit_blt1:
		move.w    r_splanes(a6),d6
		cmp.w     r_dplanes(a6),d6
		bne.s     linea_bit_blt2
		movea.l   p_bitblt(a6),a0
		jsr       (a0)
		bra.s     linea_blt3
linea_bit_blt2:
		move.l    10(a5),d6
		moveq.l   #3,d7
		cmp.l     #$010D010D,d6
		beq.s     linea_ex2
		moveq.l   #2,d7
		cmp.l     #$06060606,d6
		beq.s     linea_ex2
		moveq.l   #1,d7
		cmp.l     #$04040707,d6
		beq.s     linea_ex2
		moveq.l   #0,d7
linea_ex2:
		move.w    d7,r_wmode(a6)
		movea.l   p_expblt(a6),a0
		jsr       (a0)
linea_blt3:
		movea.l   (a7)+,a6
		lea.l     76(a6),a6
		rts
linea_text_blt:
		move.l    a6,-(a7)
		lea.l     -130(a7),a7
		movea.l   (linea_wk).w,a6
		bsr       set_lclip2
		movea.l   a7,a1
		lea.l     32(a1),a2
		lea.l     2(a2),a3
		lea.l     4(a3),a4
		lea.l     4(a4),a5
		lea.l     color_rev_tab,a0
		move.w    (TEXTFG).w,d0
		moveq.l   #15,d1
		and.w     colors(a6),d1
		and.w     d1,d0
		move.w    #1,t_color(a6)
		cmp.w     d0,d1
		beq.s     atext_in
		move.b    0(a0,d0.w),t_color(a6)
atext_in:
		clr.b     t_mapping(a6)
		clr.w     t_first_ade(a6)
		clr.w     t_ades(a6)
		clr.w     t_space_hor(a6)
		clr.w     t_space_ver(a6)
		move.b    #$01,t_prop(a6)
		clr.b     t_grow(a6)
		clr.w     t_no_kern(a6)
		clr.w     t_no_track(a6)
		clr.l     t_hor(a6) ; also clr t_ver
		clr.l     t_base(a6) ; also clr t_half
		clr.l     t_descent(a6) ; also clr t_bottom
		clr.l     t_ascent(a6) ; also clr t_top 
		clr.l     t_left_offset(a6) ; also clr t_whole_width
		move.w    (WEIGHT).w,d0
		tst.w     (MONO).w
		beq.s     atext_th1
		moveq.l   #0,d0
atext_th1:
		cmp.w     #15,d0
		bls.s     atext_th2
		moveq.l   #15,d0
atext_th2:
		move.w    d0,t_thicken(a6)
		move.l    a5,t_pointer(a6)
		move.l    a5,t_fonthdr(a6)
		move.l    a4,t_offtab(a6)
		move.w    (SOURCEX).w,d0
		move.w    d0,(a4)
		add.w     (DELX).w,d0
		move.w    d0,2(a4)
		movem.w   (DESTX).w,d2-d5
		move.w    (FWIDTH).w,d0
		move.w    d0,t_iwidth(a6)
		mulu.w    (SOURCEY).w,d0
		movea.l   (FBASE).w,a0
		adda.l    d0,a0
		move.l    a0,t_image(a6)
		move.w    d5,t_iheight(a6)
		move.l    a4,off_table(a5)
		movea.l   t_image(a6),a0
		move.l    a0,dat_table(a5)
		move.w    t_iwidth(a6),form_width(a5)
		move.w    t_iheight(a6),form_height(a5)
		clr.l     next_font(a5)
		move.w    (STYLE).w,d0
		bclr      #3,d0
		move.w    d0,t_effects(a6)
		move.w    (SCALE).w,d6
		beq.s     atext_se
		move.w    (DDAINC).w,d1
		mulu.w    d5,d1
		swap      d1
		moveq.l   #-1,d6
		tst.w     (SCALDIR).w
		bgt.s     atext_he
		moveq.l   #1,d6
		moveq.l   #0,d5
atext_he:
		add.w     d1,d5
atext_se:
		move.w    d5,t_cheight(a6)
		move.b    d6,t_grow(a6)
		move.w    d5,d0
		lsr.w     #1,d0
		move.w    d0,t_whole_width(a6)
		mulu.w    d5,d4
		divu.w    (DELY).w,d4
		move.w    d4,t_cwidth(a6)
		move.w    t_effects(a6),d0
		btst      #0,d0
		beq.s     atext_out
		add.w     t_thicken(a6),d4
atext_out:
		btst      #4,d0
		beq.s     atext_ro1
		addq.w    #2,d4
		addq.w    #2,d5
atext_ro1:
		moveq.l   #0,d0
		move.w    (CHUP).w,d0
		divu.w    #$0384,d0
		move.w    d0,t_rotation(a6)
		bne.s     atext_ro2
		add.w     d4,(DESTX).w
		bra.s     atext_ca
atext_ro2:
		subq.w    #1,d0
		bne.s     atext_ro3
		sub.w     d4,(DESTY).w
		bra.s     atext_ca
atext_ro3:
		subq.w    #1,d0
		bne.s     atext_ro4
		sub.w     d4,(DESTX).w
		bra.s     atext_ca
atext_ro4:
		add.w     d4,(DESTY).w
atext_ca:
		move.w    #1,6(a1)
		clr.w     (a2)
		movem.w   d2-d3,(a3)
		bsr       text
		lea.l     130(a7),a7
		movea.l   (a7)+,a6
		rts
show_mouse:
		move.l    a6,-(a7)
		moveq.l   #122,d0
		lea.l     (CONTRL).w,a0
		move.l    a0,d1
		movea.l   (linea_wk).w,a6
		bsr       call_nvd
		movea.l   (a7)+,a6
		rts
hide_mouse:
		move.l    a6,-(a7)
		moveq.l   #123,d0
		lea.l     (CONTRL).w,a0
		move.l    a0,d1
		movea.l   (linea_wk).w,a6
		bsr       call_nvd
		movea.l   (a7)+,a6
		rts
transform_mouse:
		movea.l   (INTIN).w,a2
transform_mouse1:
		move.w    (DEV_TAB+26).w,d5
		subq.w    #1,d5
		lea.l     -44(a7),a7
		bra       vsc_form3
undraw_sprite:
		move.l    (undraw_spr).w,-(a7)
		rts
undraw_sprite0:
		move.w    (a2)+,d2
		subq.w    #1,d2
		bmi.s     undraw_error
		cmpi.w    #30,(nvdi_cpu_type).w
		bne.s     undraw_sprite1
		btst      #0,(blitter+1).w
		beq.s     undraw_sprite1
		dc.w $4e7a,$0002 ; movec     cacr,d0
		bset      #11,d0
		dc.w $4e7b,$0002 ; movec     d0,cacr
undraw_sprite1:
		movea.l   (a2)+,a1
		bclr      #0,(a2)
		beq.s     undraw_error
		movea.w   (BYTES_LINE).w,a3
		addq.l    #2,a2
		move.w    (PLANES).w,d0
		moveq.l   #0,d1
		move.b    undraw_tab-1(pc,d0.w),d1
		add.w     d0,d0
		add.w     d0,d0
		suba.w    d0,a3
		jmp       undraw_tab(pc,d1.w)
undraw_tab:
		dc.b undraw_1-undraw_tab
		dc.b undraw_2-undraw_tab
		dc.b undraw_error-undraw_tab
		dc.b undraw_4-undraw_tab
		dc.b undraw_error-undraw_tab
		dc.b undraw_error-undraw_tab
		dc.b undraw_error-undraw_tab
		dc.b undraw_8-undraw_tab
undraw_1:
		move.l    (a2)+,(a1)+
		adda.w    a3,a1
		dbf       d2,undraw_1
undraw_error:
		rts
undraw_2:
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		adda.w    a3,a1
		dbf       d2,undraw_2
		rts
undraw_4:
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		adda.w    a3,a1
		dbf       d2,undraw_4
		rts
undraw_8:
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		move.l    (a2)+,(a1)+
		adda.w    a3,a1
		dbf       d2,undraw_8
vbl_mouse1:
		rts
vbl_mouse2:
		tst.w     (M_HID_CNT).w
		bne.s     vbl_mouse1
		tst.b     (MOUSE_FLAG).w
		bne.s     vbl_mouse1
		bclr      #0,(CUR_FLAG).w
		beq.s     vbl_mouse1
		movea.l   (mouse_buf).w,a2
		move.l    a2,-(a7)
		bsr       undraw_sprite
		movea.l   (a7)+,a2
		movem.w   (CUR_X).w,d0-d1
		lea.l     (M_POS_HX).w,a0
draw_sprite:
		move.l    (draw_spr).w,-(a7)
		rts
draw_sprite0:
		move.l    a6,-(a7)
		move.w    6(a0),-(a7)
		move.w    8(a0),-(a7)
		clr.w     d2
		tst.w     4(a0)
		bge.s     vdi_form
		moveq.l   #16,d2
vdi_form:
		move.w    d2,-(a7)
		clr.w     d2
		sub.w     (a0),d0
		bcs.s     Xko_lt_i
		move.w    (DEV_TAB).w,d3
		subi.w    #15,d3
		cmp.w     d3,d0
		bhi.s     X_am_rRa
		bra.s     get_yhot
Xko_lt_i:
		addi.w    #16,d0
		moveq.l   #4,d2
		bra.s     get_yhot
X_am_rRa:
		moveq.l   #8,d2
get_yhot:
		sub.w     2(a0),d1
		lea.l     10(a0),a0
		bcs.s     Y_am_oRa
		move.w    (DEV_TAB+2).w,d3
		subi.w    #15,d3
		cmp.w     d3,d1
		bhi.s     Y_am_uRa
		moveq.l   #16,d5
		bra.s     hole_Koo
Y_am_oRa:
		move.w    d1,d5
		addi.w    #16,d5
		asl.w     #2,d1
		suba.w    d1,a0
		clr.w     d1
		bra.s     hole_Koo
Y_am_uRa:
		move.w    (DEV_TAB+2).w,d5
		sub.w     d1,d5
		addq.w    #1,d5
hole_Koo:
		bsr       calc_add
		andi.w    #15,d0
		lea.l     draw_sprite15(pc),a3 ; 904e
		move.w    d0,d6
		cmpi.w    #8,d6
		bcs.s     load_drr
		lea.l     draw_sprite14(pc),a3 ; 9040
		move.w    #16,d6
		sub.w     d0,d6
load_drr:
		movea.l   draw_sprite2(pc,d2.w),a5 ; 8f7e
		movea.l   draw_sprite3(pc,d2.w),a6 ; 8f8a
		move.w    (PLANES).w,d7
		move.w    d7,d3
		add.w     d3,d3
		ext.l     d3
		move.w    (BYTES_LINE).w,d4
		cmpi.w    #30,(nvdi_cpu_type).w
		bne.s     draw_sprite1
		btst      #0,(blitter+1).w
		beq.s     draw_sprite1
		dc.w $4e7a,$0002 ; movec     cacr,d0
		bset      #11,d0
		dc.w $4e7b,$0002 ; movec     d0,cacr
draw_sprite1:
		move.w    d5,(a2)+
		move.l    a1,(a2)+
		cmpa.l    #draw_sprite12,a6
		bne.s     draw_x_o
		sub.l     d3,-4(a2)
draw_x_o:
		move.w    #$0300,(a2)+
		subq.w    #1,d5
		bpl.s     draw_sprite5
		bra.s     draw_sprite6
draw_sprite2:
		dc.l draw_sprite9
		dc.l draw_sprite11
		dc.l draw_sprite13
draw_sprite3:
		dc.l draw_sprite8
		dc.l draw_sprite10
		dc.l draw_sprite12
draw_sprite4:
		clr.w     d0
		lsr.w     2(a7)
		addx.w    d0,d0
		lsr.w     4(a7)
		roxl.w    #3,d0
		add.w     (a7),d0
		movea.l   draw_sprite7(pc,d0.w),a4 ; 8fc6
		move.w    d5,-(a7)
		movem.l   a0-a2,-(a7)
		jsr       (a6)
		movem.l   (a7)+,a0-a2
		move.w    (a7)+,d5
		addq.l    #2,a1
		addq.l    #2,a2
draw_sprite5:
		dbf       d7,draw_sprite4
draw_sprite6:
		addq.l    #6,a7
		movea.l   (a7)+,a6
		rts
draw_sprite7:
		dc.l draw_sprite16
		dc.l draw_sprite17
		dc.l draw_sprite18
		dc.l draw_sprite19
		dc.l draw_sprite20
		dc.l draw_sprite21
		dc.l draw_sprite22
		dc.l draw_sprite23
draw_sprite8:
		move.w    (a1),d2
		move.w    d2,(a2)
		adda.w    d3,a2
		swap      d2
		move.w    0(a1,d3.w),d2
		move.w    d2,(a2)
		adda.w    d3,a2
		jmp       (a3)
draw_sprite9:
		move.w    d2,0(a1,d3.w)
		swap      d2
		move.w    d2,(a1)
		adda.w    d4,a1
		dbf       d5,draw_sprite8
		rts
draw_sprite10:
		move.w    (a1),d2
		move.w    d2,(a2)
		adda.w    d3,a2
		move.w    0(a1,d3.w),(a2)
		adda.w    d3,a2
		jmp       (a3)
draw_sprite11:
		move.w    d2,(a1)
		adda.w    d4,a1
		dbf       d5,draw_sprite10
		rts
draw_sprite12:
		move.w    (a1),d2
		neg.w     d3
		move.w    0(a1,d3.w),(a2)
		neg.w     d3
		adda.w    d3,a2
		move.w    d2,(a2)
		adda.w    d3,a2
		swap      d2
		jmp       (a3)
draw_sprite13:
		swap      d2
		move.w    d2,(a1)
		adda.w    d4,a1
		dbf       d5,draw_sprite12
		rts
draw_sprite14:
		moveq.l   #0,d0
		moveq.l   #0,d1
		move.w    (a0)+,d0
		move.w    (a0)+,d1
		rol.l     d6,d0
		rol.l     d6,d1
		jmp       (a4)
draw_sprite15:
		move.l    (a0)+,d0
		move.w    d0,d1
		swap      d1
		clr.w     d0
		clr.w     d1
		ror.l     d6,d0
		ror.l     d6,d1
		jmp       (a4)
draw_sprite16:
		or.l      d1,d0
		not.l     d0
		and.l     d0,d2
		jmp       (a5)
draw_sprite17:
		or.l      d0,d2
		not.l     d1
		and.l     d1,d2
		jmp       (a5)
draw_sprite18:
		not.l     d0
		and.l     d0,d2
		or.l      d1,d2
		jmp       (a5)
draw_sprite19:
		or.l      d0,d2
		or.l      d1,d2
		jmp       (a5)
draw_sprite20:
		eor.l     d1,d2
		not.l     d0
		and.l     d0,d2
		jmp       (a5)
draw_sprite21:
		or.l      d0,d2
		eor.l     d1,d2
		jmp       (a5)
draw_sprite22:
		not.l     d0
		and.l     d0,d2
		eor.l     d1,d2
		jmp       (a5)
draw_sprite23:
		eor.l     d0,d2
		or.l      d1,d2
		jmp       (a5)
calc_add:
		move.w    d0,-(a7)
		move.w    d1,-(a7)
		movea.l   (v_bas_ad).w,a1
		muls.w    (BYTES_LINE).w,d1
		adda.l    d1,a1
		and.w     #$FFF0,d0
		asr.w     #3,d0
		mulu.w    (PLANES).w,d0
		adda.w    d0,a1
		move.w    (a7)+,d1
		move.w    (a7)+,d0
		rts
linea_copy_raster:
		move.l    a6,-(a7)
		movea.l   (linea_wk).w,a6
		lea.l     clip_xmin(a6),a0
		clr.l     (a0)+
		move.l    #$7FFF7FFF,(a0)+
		move.w    (DEV_TAB+26).w,d0
		subq.w    #1,d0
		move.w    d0,colors(a6)
		lea.l     (CONTRL).w,a0
		move.l    a0,d1
		pea.l     linea_cf(pc)
		tst.w     (COPYTRAN).w
		beq       vro_cpyfm
		bra       vrt_cpyfm
linea_cf:
		movea.l   (a7)+,a6
		rts
mouse_int:
		move.w    sr,-(a7)
		movem.l   d0-d3/a0-a1,-(a7)
		ori.w     #$0700,sr
		nop ; was andi.w    #$FDFF,sr
		nop
mouse_int2:
		move.b    (a0)+,d0
		move.b    d0,d1
		moveq.l   #-8,d2
		and.b     d2,d1
		sub.b     d2,d1
		bne.s     mouse_ex
		moveq.l   #3,d2
		and.w     d2,d0
		lsr.w     #1,d0
		bcc.s     mouse_button
		addq.w    #2,d0
mouse_button:
		move.b    (CUR_MS_STAT).w,d1
		and.w     d2,d1
		cmp.w     d1,d0
		beq.s     mouse_no
		movea.l   (USER_BUT).w,a1
		move.w    d1,-(a7)
		jsr       (a1)
		move.w    (a7)+,d1
		move.w    d0,(MOUSE_BT).w
		eor.b     d0,d1
		ror.b     #2,d1
		or.b      d0,d1
mouse_no:
		move.b    d1,(CUR_MS_STAT).w
		move.b    (a0)+,d2
		move.b    (a0)+,d3
		move.b    d2,d0
		or.b      d3,d0
		beq.s     mouse_ex
		ext.w     d2
		ext.w     d3
		movem.w   (GCURX).w,d0-d1
		add.w     d2,d0
		add.w     d3,d1
		bsr.s     clip_mouse
		cmp.w     (GCURX).w,d0
		bne.s     mouse_user
		cmp.w     (GCURY).w,d1
		beq.s     mouse_ex
mouse_user:
		bset      #5,(CUR_MS_STAT).w
		movem.w   d0-d1,-(a7)
		movea.l   (USER_MOT).w,a1
		jsr       (a1)
		movem.w   (a7)+,d2-d3
		sub.w     d0,d2
		sub.w     d1,d3
		or.w      d2,d3
		beq.s     mouse_sa
		bsr.s     clip_mouse
mouse_sa:
		movem.w   d0-d1,(GCURX).w
		movea.l   (USER_CUR).w,a1
		jsr       (a1)
mouse_ex:
		movem.l   (a7)+,d0-d3/a0-a1
		move.w    (a7)+,sr
		rts
clip_mouse:
		tst.w     d0
		bpl.s     clip_mouse1
		moveq.l   #0,d0
		bra.s     clip_mouse2
clip_mouse1:
		cmp.w     (V_REZ_HZ).w,d0
		blt.s     clip_mouse2
		move.w    (V_REZ_HZ).w,d0
		subq.w    #1,d0
clip_mouse2:
		tst.w     d1
		bpl.s     clip_mouse3
		moveq.l   #0,d1
		rts
clip_mouse3:
		cmp.w     (V_REZ_VT).w,d1
		blt.s     clip_mouse4
		move.w    (V_REZ_VT).w,d1
		subq.w    #1,d1
clip_mouse4:
		rts
user_cur:
		move.w    sr,-(a7)
		ori.w     #$0700,sr
		move.w    d0,(CUR_X).w
		move.w    d1,(CUR_Y).w
		bset      #0,(CUR_FLAG).w
		move.w    (a7)+,sr
		rts
sys_time:
		move.l    (NEXT_TIM).w,-(a7)
		move.l    (USER_TIM).w,-(a7)
		rts
v_escape_call:
		move.l    p_escape(a6),-(a7)
		rts
v_escape:
		tst.w     bitmap_w(a6)
		bne.s     v_escape2
		movea.l   (a0),a1
		move.w    opcode2(a1),d0
		cmp.w     #19,d0
		bhi.s     v_escape2
		movem.l   d1-d7/a2-a5,-(a7)
		movem.l   4(a0),a2-a5
		add.w     d0,d0
		move.w    v_escape_tab(pc,d0.w),d2
		movea.l   a2,a5
		movea.l   a1,a0
		movem.w   (V_CUR_XY).w,d0-d1
		movea.l   (V_CUR_AD).w,a1
		movea.w   (BYTES_LINE).w,a2
		jsr       v_escape_tab(pc,d2.w)
		movem.l   (a7)+,d1-d7/a2-a5
v_escape1:
		rts
v_escape2:
		rts
v_escape_tab:
		dc.w	v_escape1-v_escape_tab
		dc.w	vq_chcells-v_escape_tab
		dc.w	v_exit_cur-v_escape_tab
		dc.w	v_enter_cur-v_escape_tab
		dc.w	vt_seq_A-v_escape_tab
		dc.w	vt_seq_B-v_escape_tab
		dc.w	vt_seq_C-v_escape_tab
		dc.w	vt_seq_D-v_escape_tab
		dc.w	vt_seq_H-v_escape_tab
		dc.w	vt_seq_J-v_escape_tab
		dc.w	v_eeol-v_escape_tab
		dc.w	vs_curaddress-v_escape_tab
		dc.w	v_curtext-v_escape_tab
		dc.w	vt_seq_p-v_escape_tab
		dc.w	vt_seq_q-v_escape_tab
		dc.w	vq_curaddress-v_escape_tab
		dc.w	vq_tabstatus-v_escape_tab
		dc.w	v_hardcopy-v_escape_tab
		dc.w	v_dspcur-v_escape_tab
		dc.w	v_rmcur-v_escape_tab
vq_chcells:
		move.l    (V_CEL_MX).w,d3
		addi.l    #$00010001,d3
		swap      d3
		move.l    d3,(a4)
		move.w    #2,n_intout(a0)
		rts
v_exit_cur:
		addq.w    #1,(V_HID_CNT).w
		bclr      #1,(V_STAT_0).w
		bra       clear_screen
v_enter_cur:
		clr.l     (V_CUR_XY).w
		move.l    (v_bas_ad).w,(V_CUR_AD).w
		move.l    (con_vec).w,(con_stat).w
		jsr       clear_screen
		bclr      #1,(V_STAT_0).w
		move.w    #1,(V_HID_CNT).w
		bra       cursor_off2
vs_curaddress:
		move.w    (a5)+,d1
		move.w    (a5)+,d0
		subq.w    #1,d0
		subq.w    #1,d1
		bra       set_curs1
v_curtext:
		moveq.l   #0,d1
		move.w    6(a0),d1
		subq.w    #1,d1
		bmi.s     v_curtext2
		movea.l   buffer_a(a6),a0
		movea.l   a0,a1
		move.l    buffer_l(a6),d0
		subq.l    #1,d0
		sub.l     d1,d0
		bgt.s     v_curtext1
		add.l     d1,d0
		move.l    d0,d1
v_curtext1:
		move.w    (a5)+,d0
		move.b    d0,(a1)+
		dbf       d1,v_curtext1
		clr.b     (a1)+
		move.l    a0,-(a7)
		move.w    #9,-(a7)
		trap      #1
		addq.l    #6,a7
v_curtext2:
		rts
vq_curaddress:
		addq.w    #1,d0
		addq.w    #1,d1
		move.w    d1,(a4)+
		move.w    d0,(a4)+
		move.w    #2,n_intout(a0)
		rts
vq_tabstatus:
		move.w    #1,(a4)
		move.w    #1,n_intout(a0)
		rts
v_dspcur:
v_rmcur:
		rts
v_hardcopy:
		move.w    #20,-(a7) ; Scrdmp
		trap      #14
		addq.l    #2,a7
		rts
Blitmode:
		move.w    (a0),d0
		bmi.s     Blitmode1
		lea.l     (blitter).w,a0
		btst      #1,1(a0)
		beq.s     Blitmode1
		and.w     #1,d0
		andi.w    #$FFFE,(a0)
		or.w      d0,(a0)
Blitmode1:
		move.w    (blitter).w,d0
		rte
vdi_cursor:
		tst.w     (V_HID_CNT).w
		bne.s     vdi_cursor1
		subq.b    #1,(V_CUR_CT).w
		bne.s     vdi_cursor1
		move.b    (V_PERIOD).w,(V_CUR_CT).w
		move.l    (cursor_vbl).w,-(a7)
vdi_cursor1:
		rts
rawcon:
vdi_rawout:
		lea.l     6(a7),a0
		move.w    (a0),d1
		and.w     #$ff,d1
		movea.l   (rawcon_vec).w,a0
		jmp       (a0)
bconout:
vdi_conout:
		lea.l     6(a7),a0
		move.w    (a0),d1
		and.w     #$ff,d1
		movea.l   (con_stat).w,a0
		jmp       (a0)
set_curs1:
		bsr.w     cursor_off
set_cur_1:
		move.w    (V_CEL_MX).w,d2
		tst.w     d0
		bpl.s     set_cur_2
		moveq.l   #0,d0
set_cur_2:
		cmp.w     d2,d0
		ble.s     set_cur_3
		move.w    d2,d0
set_cur_3:
		move.w    (V_CEL_MY).w,d2
		tst.w     d1
		bpl.s     set_cur_4
		moveq.l   #0,d1
set_cur_4:
		cmp.w     d2,d1
		ble.s     set_curs2
		move.w    d2,d1
set_curs2:
		movem.w   d0-d1,(V_CUR_XY).w
		movea.l   (v_bas_ad).w,a1
		mulu.w    (V_CEL_WR).w,d1
		adda.l    d1,a1
		moveq.l   #1,d1
		and.w     d0,d1
		and.w     #$FFFE,d0
		mulu.w    (PLANES).w,d0
		add.w     d1,d0
		adda.w    d0,a1
		adda.w    (V_CUR_OF).w,a1
		move.l    a1,(V_CUR_AD).w
		bra.s     cursor_off2
cursor_off:
		addq.w    #1,(V_HID_CNT).w
		cmpi.w    #1,(V_HID_CNT).w
		bne.s     cursor_off1
		bclr      #1,(V_STAT_0).w
		bne.s     cursor
cursor_off1:
		rts
cursor_off2:
		cmpi.w    #1,(V_HID_CNT).w
		bcs.s     cursor_off4
		bhi.s     cursor_off3
		move.b    (V_PERIOD).w,(V_CUR_CT).w
		bsr.s     cursor
		bset      #1,(V_STAT_0).w
cursor_off3:
		subq.w    #1,(V_HID_CNT).w
cursor_off4:
		rts
vbl_curs:
		btst      #0,(V_STAT_0).w
		beq.s     vbl_no_b
		bchg      #1,(V_STAT_0).w
		bra.s     cursor
vbl_no_b:
		bset      #1,(V_STAT_0).w
		beq.s     cursor
		rts
cursor:
		movem.l   d0-d2/a0-a2,-(a7)
		move.w    (PLANES).w,d0
		subq.w    #1,d0
		move.w    (V_CEL_HT).w,d2
		subq.w    #1,d2
		movea.l   (V_CUR_AD).w,a0
		movea.w   (BYTES_LINE).w,a2
cursor_b:
		movea.l   a0,a1
		move.w    d2,d1
cursor_l:
		not.b     (a1)
		adda.w    a2,a1
		dbf       d1,cursor_l
		addq.l    #2,a0
		dbf       d0,cursor_b
		movem.l   (a7)+,d0-d2/a0-a2
cursor_e:
		rts
vt_bel:
		btst      #2,(conterm).w
		beq.s     cursor_e
		movea.l   (bell_hook).w,a0
		jmp       (a0)
make_pling:
		pea.l     pling(pc)
		move.w    #32,-(a7) ; Dosound
		trap      #14
		addq.l    #6,a7
		rts
pling:
		dc.w	$0034,$0100,$0200,$0300
		dc.w	$0400,$0500,$0600,$07FE
		dc.w	$0810,$0900,$0A00,$0B00
		dc.w	$0C10,$0D09,$FF00
vt_bs:
		movem.w   (V_CUR_XY).w,d0-d1
		subq.w    #1,d0
		bra       set_curs1
vt_ht:
		andi.w    #$FFF8,d0
		addq.w    #8,d0
		bra       set_curs1
vt_lf:
		pea.l     cursor_off2(pc)
		bsr       cursor_off
		sub.w     (V_CEL_MY).w,d1
		beq       scroll_up
		move.w    (V_CEL_WR).w,d1
		add.l     d1,(V_CUR_AD).w
		addq.w    #1,(V_CUR_XY+2).w
		rts
vt_cr:
		bsr       cursor_off
		pea.l     cursor_off2(pc)
		movea.l   (V_CUR_AD).w,a1
set_x0:
		move.w    (PLANES).w,d2
		btst      #0,d0
		beq.s     set_x0_e
		subq.w    #1,d0
		mulu.w    d2,d0
		addq.l    #1,d0
		bra.s     set_x0_a
set_x0_e:
		mulu.w    d2,d0
set_x0_a:
		suba.l    d0,a1
		move.l    a1,(V_CUR_AD).w
		clr.w     (V_CUR_XY).w
		rts
vt_esc:
		move.l    #vt_esc_s,(con_stat).w
		rts
vt_contr:
		cmpi.w    #27,d1
		beq.s     vt_esc
		subq.w    #7,d1
		subq.w    #6,d1
		bhi.s     vt_c_exit
		move.l    #vt_con,(con_stat).w
		add.w     d1,d1
		move.w    vt_c_tab(pc,d1.w),d2
		movem.w   (V_CUR_XY).w,d0-d1
		jmp       vt_c_tab(pc,d2.w)
vt_c_exit:
		rts

		dc.w      vt_bel-vt_c_tab
		dc.w      vt_bs-vt_c_tab
		dc.w      vt_ht-vt_c_tab
		dc.w      vt_lf-vt_c_tab
		dc.w      vt_lf-vt_c_tab
		dc.w      vt_lf-vt_c_tab
vt_c_tab:
		dc.w      vt_cr-vt_c_tab

vt_con:
		cmpi.w    #32,d1
		blt.s     vt_contr
vt_rawcon:
		move.l    d3,-(a7)
		move.w    (V_CEL_HT).w,d0
		subq.w    #1,d0
		movea.l   (V_FNT_AD).w,a0
		movea.l   (V_CUR_AD).w,a1
		movea.w   (BYTES_LINE).w,a2
		adda.w    d1,a0
		move.w    (PLANES).w,d2
		subq.w    #1,d2
		move.l    (V_COL_BG).w,d3
		move.b    #$04,(V_CUR_CT).w
		bclr      #1,(V_STAT_0).w
		btst      #4,(V_STAT_0).w
		beq.s     vtc_char1
		swap      d3
vtc_char1:
		movem.l   d0/a0-a1,-(a7)
		pea.l     vtc_char3(pc)
		lsr.l     #1,d3
		bcc.s     vtc_char2
		btst      #15,d3
		beq       vtc_char4
		bra       vtc_bg_b
vtc_char2:
		btst      #15,d3
		bne       vtc_char5
		bra       vtc_bg_w
vtc_char3:
		movem.l   (a7)+,d0/a0-a1
		addq.l    #2,a1
		dbf       d2,vtc_char1
		move.l    (a7)+,d3
		move.w    (V_CUR_XY).w,d0
		cmp.w     (V_CEL_MX).w,d0
		bge.s     vtc_l_co
		addq.w    #1,(V_CUR_XY).w
		lsr.w     #1,d0
		bcs.s     vtc_n_co
		addq.l    #1,(V_CUR_AD).w
		rts
vtc_n_co:
		subq.l    #1,a1
		move.l    a1,(V_CUR_AD).w
		rts
vtc_l_co:
		btst      #3,(V_STAT_0).w
		beq.s     vtc_con_2
		addq.w    #1,(V_HID_CNT).w
		subq.w    #1,d0
		mulu.w    (PLANES).w,d0
		addq.w    #1,d0
		movea.l   (V_CUR_AD).w,a1
		suba.w    d0,a1
		move.l    a1,(V_CUR_AD).w
		clr.w     (V_CUR_XY).w
		move.w    (V_CUR_XY+2).w,d1
		pea.l     vtc_con_1(pc)
		cmp.w     (V_CEL_MY).w,d1
		bge       scroll_up
		addq.l    #4,a7
		adda.w    (V_CEL_WR).w,a1
		move.l    a1,(V_CUR_AD).w
		addq.w    #1,(V_CUR_XY+2).w
vtc_con_1:
		subq.w    #1,(V_HID_CNT).w
vtc_con_2:
		rts
vtc_char4:
		move.b    (a0),(a1)
		lea.l     256(a0),a0
		adda.w    a2,a1
		dbf       d0,vtc_char4
		rts
vtc_char5:
		move.b    (a0),d1
		not.b     d1
		move.b    d1,(a1)
		lea.l     256(a0),a0
		adda.w    a2,a1
		dbf       d0,vtc_char5
		rts
vtc_bg_w:
		moveq.l   #0,d1
		bra.s     vtc_bg
vtc_bg_b:
		moveq.l   #-1,d1
vtc_bg:
		move.b    d1,(a1)
		adda.w    a2,a1
		dbf       d0,vtc_bg
		rts
vt_esc_s:
		cmpi.w    #'Y',d1
		beq       vt_seq_Y
		move.w    d1,d2
		movem.w   (V_CUR_XY).w,d0-d1
		movea.l   (V_CUR_AD).w,a1
		movea.w   (BYTES_LINE).w,a2
		move.l    #vt_con,(con_stat).w
vt_seq_t:
		subi.w    #$0041,d2
		cmpi.w    #12,d2
		bhi.s     vt_seq_t2
		add.w     d2,d2
		move.w    vt_seq_tab1(pc,d2.w),d2
		jmp       vt_seq_tab1(pc,d2.w)
vt_seq_t2:
		subi.w    #33,d2
		cmpi.w    #21,d2
		bhi.s     vt_seq_error
		add.w     d2,d2
		move.w    vt_seq_tab2(pc,d2.w),d2
		jmp       vt_seq_tab2(pc,d2.w)
vt_seq_error:
		rts
vt_seq_tab1:
	dc.w	vt_seq_A-vt_seq_tab1
	dc.w	vt_seq_B-vt_seq_tab1
	dc.w	vt_seq_C-vt_seq_tab1
	dc.w	vt_seq_D-vt_seq_tab1
	dc.w	vt_seq_E-vt_seq_tab1
	dc.w	vt_seq_error-vt_seq_tab1
	dc.w	vt_seq_error-vt_seq_tab1
	dc.w	vt_seq_H-vt_seq_tab1
	dc.w	vt_seq_I-vt_seq_tab1
	dc.w	vt_seq_J-vt_seq_tab1
	dc.w	v_eeol-vt_seq_tab1
	dc.w	vt_seq_L-vt_seq_tab1
	dc.w	vt_seq_M-vt_seq_tab1
vt_seq_tab2:
	dc.w	vt_seq_b-vt_seq_tab2
	dc.w	vt_seq_c-vt_seq_tab2
	dc.w	vt_seq_d-vt_seq_tab2
	dc.w	vt_seq_e-vt_seq_tab2
	dc.w	vt_seq_f-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_j-vt_seq_tab2
	dc.w	vt_seq_k-vt_seq_tab2
	dc.w	vt_seq_l-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_o-vt_seq_tab2
	dc.w	vt_seq_p-vt_seq_tab2
	dc.w	vt_seq_q-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_error-vt_seq_tab2
	dc.w	vt_seq_v-vt_seq_tab2
	dc.w	vt_seq_w-vt_seq_tab2

vt_seq_A:
v_curup:
		subq.w    #1,d1
		bra       set_curs1
vt_seq_B:
v_curdown:
		addq.w    #1,d1
		bra       set_curs1
vt_seq_C:
v_curright:
		addq.w    #1,d0
		bra       set_curs1
vt_seq_D:
v_curleft:
		subq.w    #1,d0
		bra       set_curs1
vt_seq_E:
		bsr       cursor_off
		bsr       clear_screen
		bra.s     vt_seq_H1
vt_seq_H:
v_curhome:
		bsr       cursor_off
vt_seq_H1:
		clr.l     (V_CUR_XY).w
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		move.l    a1,(V_CUR_AD).w
		bra       cursor_off2
vt_seq_I:
		pea.l     cursor_off2(pc)
		bsr       cursor_off
		subq.w    #1,d1
		blt       scroll_down
		suba.w    (V_CEL_WR).w,a1
		move.l    a1,(V_CUR_AD).w
		move.w    d1,(V_CUR_XY+2).w
		rts
vt_seq_J:
v_eeos:
		bsr.s     vt_seq_K
		move.w    (V_CUR_XY+2).w,d1
		move.w    (V_CEL_MY).w,d2
		sub.w     d1,d2
		beq.s     vt_seq_J1
		movem.l   d2-d7/a1-a6,-(a7)
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		addq.w    #1,d1
		mulu.w    (V_CEL_WR).w,d1
		adda.l    d1,a1
		move.w    d2,d7
		mulu.w    (V_CEL_HT).w,d7
		subq.w    #1,d7
		bra       clear_line2 ; 99ee
vt_seq_J1:
		rts
vt_seq_K:
v_eeol:
		bsr       cursor_off
		move.w    (V_CEL_MX).w,d2
		sub.w     d0,d2
		bsr       clear_line5 ; 9d50
		bra       cursor_off2
vt_seq_L:
		pea.l     cursor_off2(pc)
		bsr       cursor_off
		bsr       set_x0
		movem.l   d2-d7/a1-a6,-(a7)
		move.w    (V_CEL_MY).w,d7
		move.w    d7,d5
		sub.w     d1,d7
		beq.s     vt_seq_L1
		move.w    (V_CEL_WR).w,d6
		mulu.w    d6,d5
		movea.l   (v_bas_ad).w,a0
		adda.w    (V_CUR_OF).w,a0
		adda.l    d5,a0
		lea.l     0(a0,d6.w),a1
		mulu.w    d6,d7
		divu.w    #320,d7
		subq.w    #1,d7
		bsr       scroll_down1
vt_seq_L1:
		movea.l   (V_CUR_AD).w,a1
		bra       clear_line1 ; 99e8
vt_seq_M:
		pea.l     cursor_off2(pc)
		bsr       cursor_off
		bsr       set_x0
		movem.l   d2-d7/a1-a6,-(a7)
		move.w    (V_CEL_MY).w,d7
		sub.w     d1,d7
		beq       clear_line1 ; 99e8
		move.w    (V_CEL_WR).w,d6
		lea.l     0(a1,d6.w),a0
		mulu.w    d6,d7
		divu.w    #320,d7
		subq.w    #1,d7
		bra       scroll_up1
vt_seq_Y:
		move.l    #vt_set_y,(con_stat).w
		rts
vt_set_y:
		subi.w    #32,d1
		move.w    (V_CUR_XY).w,d0
		move.l    #vt_set_x,(con_stat).w
		bra       set_curs1
vt_set_x:
		subi.w    #32,d1
		move.w    d1,d0
		move.w    (V_CUR_XY+2).w,d1
		move.l    #vt_con,(con_stat).w
		bra       set_curs1
vt_seq_b:
		move.l    #vt_set_b,(con_stat).w
		rts
vt_set_b:
		moveq.l   #15,d0
		and.w     d0,d1
		cmp.w     d0,d1
		bne.s     vt_set_b1
		moveq.l   #-1,d1
vt_set_b1:
		move.w    d1,(V_COL_FG).w
		move.l    #vt_con,(con_stat).w
		rts
vt_seq_c:
		move.l    #vt_set_c,(con_stat).w
		rts
vt_set_c:
		moveq.l   #15,d0
		and.w     d0,d1
		cmp.w     d0,d1
		bne.s     vt_set_c1
		moveq.l   #-1,d1
vt_set_c1:
		move.w    d1,(V_COL_BG).w
		move.l    #vt_con,(con_stat).w
		rts
vt_seq_d:
		bsr.s     vt_seq_o
		move.w    (V_CUR_XY+2).w,d1
		beq.s     vt_seq_d1
		movem.l   d2-d7/a1-a6,-(a7)
		mulu.w    (V_CEL_HT).w,d1
		move.w    d1,d7
		subq.w    #1,d7
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		bra       clear_line2 ; 99ee
vt_seq_d1:
		rts
vt_seq_e:
		tst.w     (V_HID_CNT).w
		beq.s     vt_seq_e1
		move.w    #1,(V_HID_CNT).w
		bra       cursor_off2
vt_seq_e1:
		rts
vt_seq_f:
		bra       cursor_off
vt_seq_j:
		bset      #5,(V_STAT_0).w
		move.l    (V_CUR_XY).w,(V_SAV_XY).w
		rts
vt_seq_k:
		movem.w   (V_SAV_XY).w,d0-d1
		bclr      #5,(V_STAT_0).w
		bne       set_curs1
		moveq.l   #0,d0
		moveq.l   #0,d1
		bra       set_curs1
vt_seq_l:
		bsr       cursor_off
		bsr       set_x0
		bsr       clear_line ; 99e4
		bra       cursor_off2
vt_seq_o:
		move.w    d0,d2
		subq.w    #1,d2
		bmi.s     vt_seq_o1
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		mulu.w    (V_CEL_WR).w,d1
		adda.l    d1,a1
		bra       clear_line5 ; 9d50
vt_seq_o1:
		rts
vt_seq_p:
v_rvon:
		bset      #4,(V_STAT_0).w
		rts
vt_seq_q:
v_rvoff:
		bclr      #4,(V_STAT_0).w
		rts
vt_seq_v:
		bset      #3,(V_STAT_0).w
		rts
vt_seq_w:
		bclr      #3,(V_STAT_0).w
		rts
scroll_up:
		movem.l   d2-d7/a1-a6,-(a7)
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		movea.l   a1,a0
		move.w    (V_CEL_WR).w,d7
		adda.w    d7,a0
		mulu.w    (V_CEL_MY).w,d7
		divu.w    #320,d7
		subq.w    #1,d7
scroll_up1:
		pea.l     clear_line1(pc) ; 99e8
scroll_up2:
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,(a1)
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,40(a1)
		lea.l     80(a1),a1
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,(a1)
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,40(a1)
		lea.l     80(a1),a1
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,(a1)
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,40(a1)
		lea.l     80(a1),a1
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,(a1)
		movem.l   (a0)+,d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,40(a1)
		lea.l     80(a1),a1
		dbf       d7,scroll_up2
		swap      d7
		lsr.w     #1,d7
		dbf       d7,scroll_up3
		rts
scroll_up3:
		move.w    (a0)+,(a1)+
		dbf       d7,scroll_up3
		rts
scroll_down:
		movem.l   d2-d7/a1-a6,-(a7)
		movea.l   (v_bas_ad).w,a0
		adda.w    (V_CUR_OF).w,a0
		move.w    (V_CEL_WR).w,d6
		move.w    (V_CEL_MY).w,d7
		mulu.w    d6,d7
		lea.l     -40(a0,d7.l),a0
		lea.l     40(a0,d6.w),a1
		divu.w    #320,d7
		subq.w    #1,d7
		bsr.s     scroll_down2
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		bra.s     clear_line1 ; 99e8
scroll_down1:
		lea.l     -40(a0),a0
scroll_down2:
		movem.l   (a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		movem.l   -40(a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		lea.l     -80(a0),a0
		movem.l   (a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		movem.l   -40(a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		lea.l     -80(a0),a0
		movem.l   (a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		movem.l   -40(a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		lea.l     -80(a0),a0
		movem.l   (a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		movem.l   -40(a0),d2-d6/a2-a6
		movem.l   d2-d6/a2-a6,-(a1)
		lea.l     -80(a0),a0
		dbf       d7,scroll_down2
		swap      d7
		lea.l     40(a0),a0
		lsr.w     #1,d7
		dbf       d7,scroll_down3
		rts
scroll_down3:
		move.w    -(a0),-(a1)
		dbf       d7,scroll_down3
		rts
clear_line:
		movem.l   d2-d7/a1-a6,-(a7)
clear_line1:
		move.w    (V_CEL_HT).w,d7
		subq.w    #1,d7
clear_line2:
		move.w    (V_CEL_MX).w,d5
		addq.w    #1,d5
		move.w    (V_COL_BG).w,d6
		movea.w   (BYTES_LINE).w,a2
		move.w    (PLANES).w,d2
		cmp.w     #8,d2
		bgt       clear_line4 ; 9d0e
		add.w     d2,d2
		move.w    clear_tab(pc,d2.w),d2
		jmp       clear_tab(pc,d2.w)
clear_tab:
		dc.w clear_line3-clear_tab ; 9b6c
		dc.w clear_mo1-clear_tab
		dc.w clear_co1-clear_tab
		dc.w clear_line3-clear_tab ; 9b6c
		dc.w clear_co2-clear_tab
		dc.w clear_line3-clear_tab ; 9b6c
		dc.w clear_line3-clear_tab ; 9b6c
		dc.w clear_line3-clear_tab ; 9b6c
		dc.w clear_co3-clear_tab
clear_mo1:
		moveq.l   #0,d2
		lsr.w     #1,d6
		negx.l    d2
		suba.w    d5,a2
		subq.w    #4,d5
		lsr.w     #2,d5
		bcc.s     clear_mo2
		lea.l     clear_sc2(pc),a3
		move.w    d5,d6
		lsr.w     #7,d5
		not.w     d6
		and.w     #$007F,d6
		add.w     d6,d6
		lea.l     clear_sc3(pc,d6.w),a4
		move.w    d5,d6
		jmp       (a3)
clear_mo2:
		move.w    d5,d6
		lsr.w     #7,d5
		not.w     d6
		and.w     #$007F,d6
		add.w     d6,d6
		lea.l     clear_sc3(pc,d6.w),a3
clear_sc1:
		move.w    d5,d6
		jmp       (a3)
clear_sc2:
		move.w    d2,(a1)+
		jmp       (a4)
clear_sc3:
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		move.l    d2,(a1)+
		dbf       d6,clear_sc3
		adda.w    a2,a1
		dbf       d7,clear_sc1
clear_line3:
		movem.l   (a7)+,d2-d7/a1-a6
		rts
clear_co1:
		add.w     d5,d5
		moveq.l   #0,d2
		lsr.w     #1,d6
		negx.w    d2
		swap      d2
		lsr.w     #1,d6
		negx.w    d2
clear_re1:
		move.l    d2,d3
clear_re2:
		move.l    d2,d4
		movea.l   d3,a4
clear_re3:
		suba.w    d5,a2
		subq.w    #1,d5
		lsr.w     #2,d5
		move.w    d5,d6
		lsr.w     #7,d5
		not.w     d6
		and.w     #$007F,d6
		add.w     d6,d6
		lea.l     clear_sc5(pc,d6.w),a3
clear_sc4:
		move.w    d5,d6
		jmp       (a3)
clear_sc5:
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		move.l    d2,(a1)+
		move.l    d3,(a1)+
		move.l    d4,(a1)+
		move.l    a4,(a1)+
		dbf       d6,clear_sc5
		adda.w    a2,a1
		dbf       d7,clear_sc4
		movem.l   (a7)+,d2-d7/a1-a6
		rts
clear_co2:
		add.w     d5,d5
		add.w     d5,d5
		moveq.l   #0,d2
		moveq.l   #0,d3
		lsr.w     #1,d6
		negx.w    d2
		swap      d2
		lsr.w     #1,d6
		negx.w    d2
		lsr.w     #1,d6
		negx.w    d3
		swap      d3
		lsr.w     #1,d6
		negx.w    d3
		bra       clear_re2
clear_co3:
		moveq.l   #0,d2
		moveq.l   #0,d3
		moveq.l   #0,d4
		moveq.l   #0,d5
		lsr.w     #1,d6
		negx.w    d2
		swap      d2
		lsr.w     #1,d6
		negx.w    d2
		lsr.w     #1,d6
		negx.w    d3
		swap      d3
		lsr.w     #1,d6
		negx.w    d3
		lsr.w     #1,d6
		negx.w    d4
		swap      d4
		lsr.w     #1,d6
		negx.w    d4
		lsr.w     #1,d6
		negx.w    d5
		swap      d5
		lsr.w     #1,d6
		negx.w    d5
		movea.l   d5,a4
		move.w    (V_CEL_MX).w,d5
		addq.w    #1,d5
		lsl.w     #3,d5
		bra       clear_re3
clear_line4:
		addq.w    #1,d7
		mulu.w    (BYTES_LINE).w,d7
		lsr.l     #5,d7
		subq.l    #1,d7
		moveq.l   #-1,d6
clear_un:
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		move.l    d6,(a1)+
		subq.l    #1,d7
		bpl.s     clear_un
		movem.l   (a7)+,d2-d7/a1-a6
		rts
clear_screen:
		movem.l   d2-d7/a1-a6,-(a7)
		move.w    (V_CEL_MY).w,d7
		addq.w    #1,d7
		mulu.w    (V_CEL_HT).w,d7
		subq.w    #1,d7
		movea.l   (v_bas_ad).w,a1
		adda.w    (V_CUR_OF).w,a1
		bra       clear_line2 ; 99ee
clear_line5:
		movem.l   d3-d6/a3-a4,-(a7)
		move.w    (V_COL_BG).w,d4
		move.w    (PLANES).w,d5
		move.w    d5,d6
		add.w     d5,d5
		subq.w    #1,d6
		movea.l   a1,a3
clear_lp1:
		move.w    d2,d3
		movea.l   a3,a0
		lea.l     vtc_bg_w(pc),a4
		lsr.w     #1,d4
		bcc.s     clear_lp2
		lea.l     vtc_bg_b(pc),a4
clear_lp2:
		movea.l   a0,a1
		move.w    (V_CEL_HT).w,d0
		subq.w    #1,d0
		jsr       (a4)
		addq.l    #1,a0
		move.l    a0,d1
		lsr.w     #1,d1
		bcs.s     clear_lp3
		subq.l    #2,a0
		adda.w    d5,a0
clear_lp3:
		dbf       d3,clear_lp2
		addq.l    #2,a3
		dbf       d6,clear_lp1
		movem.l   (a7)+,d3-d6/a3-a4
		rts
opcode_err0:
		pea.l     vdi_exit(pc)
opcode_error:
		movea.l   d1,a1
		movea.l   (a1),a1
		move.w    (a1),d0
		clr.w     n_intout(a1)
		clr.w     n_ptsout(a1)
		rts
handle_error:
		move.w    (a1),d0
		subq.w    #1,d0
		beq.s     handle_0
		subi.w    #99,d0
		beq.s     handle_0
		nop
handle_0:
		movea.l   (linea_wk).w,a6
		clr.w     handle(a1)
		moveq.l   #0,d0
		bra.s     handle_f
vdi_entry:
		movem.l   a0-a1/a6,-(a7)
		movea.l   d1,a0
		movea.l   (a0),a1
		move.w    handle(a1),d0
		beq.s     handle_error
		cmp.w     #MAX_HANDLES,d0
		bhi.s     handle_error
		subq.w    #1,d0
		add.w     d0,d0
		add.w     d0,d0
		lea.l     (wk_tab).w,a6
		movea.l   0(a6,d0.w),a6
		movea.l   vdi_disp(a6),a0
		jmp       (a0)
handle_f:
		movea.l   d1,a0
		movea.l   (a0),a1
		move.w    (a1),d0
		cmp.w     #131,d0
		bhi.s     opcode_err0
		cmp.w     #39,d0
		bhi.s     vdi_dispatch
		lsl.w     #3,d0
		lea.l     vdi_tab(pc,d0.w),a0
		bra.s     vdi_dispatch1
vdi_dispatch:
		sub.w     #100,d0
		bmi.s     opcode_err0
		lsl.w     #3,d0
		lea.l     vdi_tab1(pc),a0
		adda.w    d0,a0
vdi_dispatch1:
		move.w    (a0)+,n_ptsout(a1)
		move.w    (a0)+,n_intout(a1)
		movea.l   (a0),a1
		movea.l   d1,a0
		jsr       (a1)
vdi_exit:
		movem.l   (a7)+,a0-a1/a6
		moveq.l   #0,d0
		rts
vdi_tab:
	dc.w	0,0
	dc.l	opcode_error
	dc.w	6,45
	dc.l	v_opnwk
	dc.w	0,0
	dc.l	v_clswk
	dc.w	0,0
	dc.l	v_clrwk
	dc.w	0,0
	dc.l	v_updwk
	dc.w	0,0
	dc.l	v_escape_call
	dc.w	0,0
	dc.l	v_pline
	dc.w	0,0
	dc.l	v_pmarker
	dc.w	0,0
	dc.l	v_gtext
	dc.w	0,0
	dc.l	v_fillarray
	dc.w	0,0
	dc.l	v_cellarray
	dc.w	0,0
	dc.l	v_gdp
	dc.w	2,0
	dc.l	vst_height
	dc.w	0,1
	dc.l	vst_rotation
	dc.w	0,0
	dc.l	vs_color
	dc.w	0,1
	dc.l	vsl_type
	dc.w	1,0
	dc.l	vsl_width
	dc.w	0,1
	dc.l	vsl_color
	dc.w	0,1
	dc.l	vsm_type
	dc.w	1,0
	dc.l	vsm_height
	dc.w	0,1
	dc.l	vsm_color
	dc.w	0,1
	dc.l	vst_font
	dc.w	0,1
	dc.l	vst_color
	dc.w	0,1
	dc.l	vsf_interior
	dc.w	0,1
	dc.l	vsf_style
	dc.w	0,1
	dc.l	vsf_color
	dc.w	0,4
	dc.l	vq_color
	dc.w	0,0
	dc.l	vq_cellarray
	dc.w	0,0
	dc.l	v_locator
	dc.w	0,2
	dc.l	v_valuator
	dc.w	0,1
	dc.l	v_choice
	dc.w	0,0
	dc.l	v_string
	dc.w	0,1
	dc.l	vswr_mode
	dc.w	0,1
	dc.l	vsin_mode
	dc.w	0,0
	dc.l	opcode_error
	dc.w	1,5
	dc.l	vql_attributes
	dc.w	1,3
	dc.l	vqm_attributes
	dc.w	0,5
	dc.l	vqf_attributes
	dc.w	2,6
	dc.l	vqt_attributes
	dc.w	0,2
	dc.l	vst_alignment
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
	dc.w	0,0
	dc.l	opcode_error
vdi_tab1:
	dc.w	6,45
	dc.l	v_opnvwk
	dc.w	0,0
	dc.l	v_clsvwk
	dc.w	6,45
	dc.l	vq_extnd
	dc.w	0,0
	dc.l	v_contour_fill
	dc.w	0,1
	dc.l	vsf_perimeter
	dc.w	0,2
	dc.l	v_get_pixel
	dc.w	0,1
	dc.l	vst_effects
	dc.w	2,1
	dc.l	vst_point
	dc.w	0,0
	dc.l	vsl_ends
	dc.w	0,0
	dc.l	vro_cpyfm
	dc.w	0,0
	dc.l	vr_trnfm
	dc.w	0,0
	dc.l	vsc_form
	dc.w	0,0
	dc.l	vsf_udpat
	dc.w	0,0
	dc.l	vsl_udstyle
	dc.w	0,0
	dc.l	vr_recfl
	dc.w	0,1
	dc.l	vqin_mode
	dc.w	4,0
	dc.l	vqt_extend
	dc.w	3,1
	dc.l	vqt_width
	dc.w	0,1
	dc.l	vex_timv
	dc.w	0,1
	dc.l	vst_load_fonts
	dc.w	0,0
	dc.l	vst_unload_fonts
	dc.w	0,0
	dc.l	vrt_cpyfm
	dc.w	0,0
	dc.l	v_show_c
	dc.w	0,0
	dc.l	v_hide_c
	dc.w	1,1
	dc.l	vq_mouse
	dc.w	0,0
	dc.l	vex_butv
	dc.w	0,0
	dc.l	vex_motv
	dc.w	0,0
	dc.l	vex_curv
	dc.w	0,1
	dc.l	vq_key_s
	dc.w	0,0
	dc.l	vs_clip
	dc.w	0,33
	dc.l	vqt_name
	dc.w	5,2
	dc.l	vqt_fontinfo


; end: 0000a24c


; 0000001c a V_LOCATO
; 0000001c a D_XMIN
; 0000001c a VBLVEC
; 0000001c a v_42
; 0000001c a os_conf
; 0000001e a METAFILE
; 0000001e a D_YMIN
; 0000001e a v_44
; 0000001f a N_META
; 00000020 a D_FORM
; 00000020 a V_PS_HAL
; 00000020 a GLOBAL_M
; 00000020 a sizeof_c
; 00000020 a sizeof_d
; 00000020 a v_46
; 00000022 a v_48
; 00000024 a VQ_TRAY_
; 00000024 a D_NXWD
; 00000024 a kbshift
; 00000024 a v_4a
; 00000025 a V_PAGE_S
; 00000026 a D_NXLN
; 00000028 a CAMERA
; 00000028 a run
; 00000028 a D_NXPL
; 00000028 a LAST_MB
; 0000002a a P_ADDR
; 0000002d a BIOSVEC
; 0000002e a P_NXLN
; 0000002e a XBIOSVEC
; 00000030 a SUPER_ME
; 00000030 a P_NXPL
; 00000032 a P_MASK
; 00000032 a TABLETT
; 0000003c a MEMORY
; 0000003d a N_MEMORY
; 0000003d a V_SOUND
; 00000040 a PRIVATER




/* VDI variables in lowmem */
; 00001200 A __a_vdi
; 00001200: ptsin
; 00001400: intin
; 00001418: intout
; 00001430: ptsout
; 00001460: control
; 00001478: vdipb
; 0000148C: font_header[4]
; 000015EC: atxt_off
; 000015F0: old_etv_timer
; 000015F4: key_stat
; 000015F8: nvdi_pool
; 00001678: scrtchp
; 0000167e: gdos_path
; 000016FE: screen_d
; 0000171E: vt52_fal
; 00001726: OSC_ptr
; 0000172a: OSC_count
; 0000172c: mono_DRV
; 00001730: mono_bitmap
; 00001734: mono_expblt
; 00001738: wk_tab0
; 0000173C: VWK *wk_tab[128]
; 00001940: aes_wk_p
; 00001948: cursor_cnt
; 0000194C: cursor_vbl
; 00001950: vt52_vec
; 00001954: con_vec
; 00001958: rawcon_vec
; 0000195C: color_map
; 00001960: color_rev
; 00001964: mouse_buf
; 00001968: draw_spr
; 0000196C: undraw_spr
; 00001970: call_old
; 00001978: call_old2
; 00001980: nvdi_struct
; 00001988: nvdi_aes_wk
; 000019D6: blitter
; 000019D8: modecode
; 000019DA: resolution
; 000019DC: nvdi_cookie_cpu
; 000019de: nvdi_cpu_type
; 000019E0: nvdi_cookie_vdo
; 000019E4: nvdi_cookie_mch
; 000019E8: first_de
; 000019ea: cpu020
; 00001A44: PixMap_ptr

; 000028d6: __e_vdi
