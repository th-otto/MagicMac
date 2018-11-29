;the following addresses must remain unchanged:
;device_id  10
;wr_mode        60
;colors     20
;l_color        70
;l_udstyle  94
;t_color        100
;f_color        190
;f_style        194
;f_interior 192
;f_pointer  198

MAX_PTS           EQU 1024                ;Maximale Anzahl der Koordinatenpaare in ptsin

;workstation attribute table (WK)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		OFFSET 0
disp_addr1:    ds.l 1 /* pointer to NVDI-Dispatcher */
disp_addr2:    ds.l 1 /* pointer to Treiber-Dispatcher */
wk_handle:     ds.w 1 /* workstation handle */

/* coordinate system */
driver_id:     ds.w 1 /* device ID */
pixel_width:   ds.w 1 /* width of a pixel in micro meter */
pixel_height:  ds.w 1 /* height of a pixel in micro meter */
res_x:         ds.w 1 /* raster width -1 */
res_y:         ds.w 1 /* raster height -1 */
colors:        ds.w 1 /* number of pens -1 */
res_ratio:     ds.w 1 /* aspect ratio: <0: vertical shrink ; >0 vertical zoom */
driver_type:   ds.b 1 /* driver type (NVDI or GDOS) */
               ds.b 1
driver_device: ds.w 1 /* device (screen, printer, metafile or memory) */
               ds.w 1
input_mode:    ds.b 1 /* modi of input devices */
               ds.b 1

;Notloesungen:
;Der Allzweckbuffer, Notloesung!
buffer_addr:   ds.l 1 /* pointer to tmp buffer */
buffer_len:    ds.l 1 /* length of tmp buffer in bytes */
bez_buffer:    ds.l 1 /* bezier buffer from v_set_app_buf */
bez_buf_len:   ds.l 1 /* length of bezier buffer */

/* arrays for input coordinates */
gdos_buffer:   ds.l 1 /* buffer for gdos driver */

/* clip limits */
clip_xmin:     ds.w 1 /* minimum - x */
clip_ymin:     ds.w 1 /* minimum - y */
clip_xmax:     ds.w 1 /* maximum - x */
clip_ymax:     ds.w 1 /* maximum - y */
wr_mode:       ds.w 1 /* graphic mode */
bez_on:        ds.w 1 /* beziers on? */
bez_qual:      ds.w 1 /* bezier quality from 0-5 */
               ds.w 1
               ds.w 1
l_color:       ds.w 1 /* line color */
l_width:       ds.w 1 /* line width */
l_start:       ds.w 1 /* line start */
l_end:         ds.w 1 /* line end */
l_lastpix:     ds.w 1 /* 1 = do not set last point */
l_style:       ds.w 1 /* line style */
l_styles:      ds.w 6 /* line patterns */
l_udstyle:     ds.w 1 /* user defined style */
               ds.w 1
               ds.w 1

/* text handling */
t_color:       ds.w 1 /* text color */
               ds.b 3
t_mapping:     ds.b 1 /* 0: use direct index 1: use t_asc_map */
t_first_ade:   ds.w 1 /* code of first charaacter */
t_ades:        ds.w 1 /* number of characters -1 */
t_space_index:   ds.w 1 /* index for a space (delimiter for v_justified) */
t_unknown_index: ds.w 1 /* index for a unknown character */
t_prop:        ds.b 1 /* 1: font is proportional */
t_grow:        ds.b 1 /* -1: grow +1: shrink (bitmap-fonts only) */
t_no_kern:     ds.w 1 /* number of kerning pairs <0: kerning disabled */
t_no_track:    ds.w 1 /* number of track kern pairs */
t_hor:         ds.w 1 /* horizontal alignment */
t_ver:         ds.w 1 /* verical alignment */
t_base:        ds.w 1 /* topline<->baseline */
t_half:        ds.w 1 /* topline<->halfline */
t_descent:     ds.w 1 /* topline<->descent line */
t_bottom:      ds.w 1 /* topline<->bottom line */
t_ascent:      ds.w 1 /* topline<->ascent line */
t_top:         ds.w 1 /* topline<->topline */
               ds.w 1
               ds.w 1
t_left_off:    ds.w 1 /* left offset for italic */
t_whole_off:   ds.w 1 /* total widening for italic */
t_thicken:     ds.w 1 /* thickening for bold */
t_uline:       ds.w 1 /* thickness of underline */
t_ulpos:       ds.w 1 /* distance of underline to topline */
t_width:       ds.w 1 /* text width */
t_height:      ds.w 1 /* text height */
t_cwidth:      ds.w 1 /* cell width */
t_cheight:     ds.w 1 /* cell height */
t_point_last:  ds.w 1 /* last used point size */
t_scale_width: ds.l 1 /* width in 1/65536 pixel (relative) for character generation */
t_scale_height:ds.l 1 /* height in 1/65536 pixel for character generation */
t_rotation:    ds.w 1 /* text rotation */
t_skew:        ds.w 1 /* counter clockwise, in 1/10 degree */
t_effects:     ds.w 1 /* text effects */
t_light_pct:   ds.w 1 /* grey value */
t_light_fill:  ds.l 1 /* pointer to grey image for light text */
               ds.w 5

/* pattern handling */
f_color:       ds.w 1 /* fill color */
f_interior:    ds.w 1 /* fill interior */
f_style:       ds.w 1 /* fill style */
f_perimeter:   ds.w 1 /* flag for rectangle outline */
f_pointer:     ds.l 1 /* pointer to current fill pattern */
f_planes:      ds.w 1 /* number of planes of pattern */
f_fill0:       ds.l 1
f_fill1:       ds.l 1
f_fill2:       ds.l 1
f_fill3:       ds.l 1
f_spointer:    ds.l 1 /* pointer to user defined fill pattern */
f_splanes:     ds.w 1 /* number of planes of user defined pattern */
               ds.w 1
               ds.w 1

/* marker handling */
m_color:       ds.w 1 /* marker color */
m_type:        ds.w 1 /* marker type */
m_width:       ds.w 1 /* marker width */
m_height:      ds.w 1 /* marker height */
m_data:        ds.l 1 /* pointer to marker data */
               ds.w 1
               ds.w 1
               ds.w 1
               ds.w 1
t_number:      ds.w 1 /* font number */
t_font_type:   ds.b 1 /* type of font */
		       ds.b 1
t_bitmap_gdos: ds.w 1 /* 1: bitmap fonts where embedded using GDOS */
t_bitmap_fonts:ds.l 1 /* pointer to more bitmap fonts */
t_res_ptr1:    ds.l 1 /* reserved */
t_res_ptr2:    ds.l 1 /* reserved */
t_res_xyz1:    ds.w 1 /* reserved */

/* pointer for vector fonts */
t_pointer:				/* pointer to bitmap font */
t_FONT_ptr:    ds.l 1	/* pointer to current FONT structure for vector fonts */
t_fonthdr:           	/* pointer to current bitmap font */
t_asc_map:     ds.l 1	/* pointer to table ascii -> index */
t_offtab:            	/* pointer to offset table for bitmap fonts */
t_BAT_ptr:     ds.l 1   /* pointer to attribute table for vector fonts */
t_image:                /* pointer to font data of bitmap fonts */
t_bin_table:   ds.l 1   /* pointer to fast access table for vector fonts */
t_iwidth:      ds.w 1 /* width of font data in bytes */
t_iheight:     ds.w 1 /* height of font data in lines */

/* temporary data for bitmap text */
t_eff_thicken: ds.w 1 /* widening from effects */
t_act_line:    ds.w 1 /* starting line number in text buffer */
t_add_length:  ds.w 1 /* additional length for v_justified */
t_space_kind:  ds.w 1 /* -1: per-character spacing */
               ds.w 1

/* dimensions for vector fonts */
t_width32:     ds.l 1 /* width in 1/65536 pixel (relative value) */
t_height32:    ds.l 1 /* height in 1/65536 pixel */
t_point_width: ds.l 1 /* width in 1/65536 pixel */
t_point_height:ds.l 1 /* height in 1/65536 pixel */
t_track_index: ds.w 1 /* number of track index */
t_track_offset:ds.l 1 /* offset between characters in 1/65536 pixel */
t_left_off32:  ds.l 1 /* left offset for italic */
t_whole_off32: ds.l 1 /* total widening for italic */
t_thicken32:   ds.l 1 /* thickening for bold */
               ds.w 1
               ds.w 1
               ds.w 1
t_thicken_x:   ds.l 1 /* x-part of string width */
t_thicken_y:   ds.l 1 /* y-part of string width */
t_char_x:      ds.l 1 /* x-part of string width */
t_char_y:      ds.l 1 /* y-part of string width */
t_word_x:      ds.l 1 /* x-part of string width */
t_word_y:      ds.l 1 /* y-part of string width */
t_string_x:    ds.l 1 /* x-part of string width */
t_string_y:    ds.l 1 /* y-part of string width */
t_last_x:      ds.l 1 /* x-part of width of last character*/
t_last_y:      ds.l 1 /* y-part of width of last character*/
t_gtext_spacing:ds.w 1 /* 1: use character widths as for v_gtext */
t_xadd:        ds.w 1
t_yadd:        ds.w 1
t_buf_x1:      ds.w 1 /* x1 of bitmap in text buffer */
t_buf_x2:      ds.w 1 /* x2 of bitmap in text buffer */
               ds.w 1
               ds.w 1
               ds.w 1
               ds.w 1
               ds.w 1

/* bitmap description */
device_drvr:   ds.l 1 /* pointer to device driver, or NULL */
bitmap_drvr:   ds.l 1 /* pointer to offscreen driver */
               ds.w 1
bitmap_colors: ds.l 1
bitmap_planes: ds.w 1
bitmap_format: ds.w 1
bitmap_flags:  ds.w 1
bitmap_res1:   ds.w 1
bitmap_res2:   ds.w 1
bitmap_res3:   ds.w 1
               ds.b 4
bitmap_addr:   ds.l 1 /* pointer to bitmap */
bitmap_width:  ds.w 1 /* bytes per line, or 0 for screen drivers */
r_planes:      ds.w 1 /* number of planes -1 */
bitmap_off_x:  ds.w 1 /* x-offset for coordinates */
bitmap_off_y:  ds.w 1 /* y-offset for coordinates */
bitmap_dx:     ds.w 1 /* width of bitmap -1 */
bitmap_dy:     ds.w 1 /* height of bitmap -1 */
bitmap_len:    ds.l 1 /* length of bitmap in bytes */

/* raster operations */
r_saddr:       ds.l 1 /* src address */
r_swidth:      ds.w 1 /* bytes per src line */
r_splanes:     ds.w 1 /* no of src planes -1 */
r_splane_len:         /* length of a plane */
r_snxtword:    ds.l 1 /* alternative: distance to next word of same plane */
               ds.b 8
r_daddr:       ds.l 1 /* destination address */
r_dwidth:      ds.w 1 /* bytes per destination line */
r_dplanes:     ds.w 1 /* no of dst planes -1 */
r_dplane_len:         /* length of a plane */
r_dnxtword:    ds.l 1 /* alternative: distance to next word of same plane */
               ds.b 8
r_fgcol:       ds.w 1 /* foreground color */
r_bgcol:       ds.w 1 /* background color */
r_wmode:       ds.w 1 /* operation mode */
               ds.l 1

/* jump tables */
p_fbox:        ds.l 1 /* vector for filled rectangle */
p_fline:       ds.l 1 /* vector for filled line */
p_hline:       ds.l 1 /* vector for horizontal line */
p_vline:       ds.l 1 /* vector for vertical line */
p_line:        ds.l 1 /* vector for diagonal line */
p_expblt:      ds.l 1 /* vector for expanded bitblk transfer */
p_bitblt:      ds.l 1 /* vector for bitblk transfer */
p_textblt:     ds.l 1 /* vector for text blit */
p_scanline:    ds.l 1 /* vector for scanline (seedfill) */
p_set_pixel:   ds.l 1
p_get_pixel:   ds.l 1
p_transform:   ds.l 1
p_set_pattern: ds.l 1
p_set_color_rgb:ds.l 1
p_get_color_rgb:ds.l 1
p_vdi_to_color:ds.l 1
p_color_to_vdi:ds.l 1
               ds.l 3
p_gtext:       ds.l 1
p_escapes:     ds.l 1
               ds.w 4
wk_owner:      ds.l 1 /* pointer to owning application */
WK_LENGTH:

WK_SIZE equ WK_LENGTH+(2*MAX_PTS)



f_saddr             EQU WK_LENGTH           ;Hier wird das USER-DEF gespeichert

;color_map_ptr
;color_remap_ptr


