                  ;'4. Rasterfunktionen'

/*
 * COPY RASTER, OPAQUE (VDI 109)
 */
vro_cpyfm:        movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a3     /* contrl,intin,ptsin */

                  move.w   (a2),d0        /* mode */
                  cmp.w    #15,d0         /* valid? */
                  bhi      vro_cpyfm_exit
                  move.w   d0,r_wmode(a6)

vro_cpyfm2:       movem.l  s_addr(a1),a4-a5 /* psrcMFDB/pdesMFDB */
                  movem.w  (a3),d0-d7

vro_sx:           cmp.w    d0,d2          /* xq1 > xq2 */
                  bge.s    vro_sy
                  exg      d0,d2          /* swap coordinates */
vro_sy:           cmp.w    d1,d3          /* yq1 > yq2 */
                  bge.s    vro_dx
                  exg      d1,d3          /* swap coordinates */
vro_dx:           cmp.w    d4,d6          /* xz1 > xz2 */
                  bge.s    vro_dy
                  exg      d4,d6          /* swap coordinates */
vro_dy:           cmp.w    d5,d7          /* yz1 > yz2 */
                  bge.s    vro_src
                  exg      d5,d7          /* swap coordinates */

vro_src:          move.l   fd_addr(a4),r_saddr(a6) /* source address */
                  beq.s    vro_src_screen

                  move.w   fd_nplanes(a4),d7
                  subq.w   #1,d7
                  cmp.w    #7,d7             /* 8 Planes to copy? */
                  bne.s    vro_src_planes
                  cmp.w    r_planes(a6),d7   /* device with more than 8 Planes? */
                  bge.s    vro_src_planes
                  move.w   r_planes(a6),d7   /* correct AES-bug */
vro_src_planes:   move.w   d7,r_splanes(a6)  /* number of planes - 1 */
                  addq.w   #1,d7
                  mulu.w   fd_wdwidth(a4),d7
                  add.w    d7,d7
                  move.w   d7,r_swidth(a6)   /* bytes per source line */
                  mulu.w   fd_h(a4),d7
                  move.l   d7,r_splane_len(a6)

                  move.l   (v_bas_ad).w,d7
                  cmp.l    r_saddr(a6),d7    /* source address of screen? */
                  bne.s    vro_des
                  move.w   fd_w(a4),d7
                  cmp.w    (V_REZ_HZ).w,d7   /* source width same as screen width? */
                  bne.s    vro_des
                  move.w   (PLANES).w,d7
                  subq.w   #1,d7
                  cmp.w    r_splanes(a6),d7  /* planes same as screen? */
                  bne.s    vro_des

vro_src_screen:   move.l   (v_bas_ad).w,r_saddr(a6) /* screen address */
                  move.w   (BYTES_LIN).w,r_swidth(a6) /* width of screen line in bytes */
                  move.l   bitmap_len(a6),r_splane_len(a6)
                  move.w   r_planes(a6),r_splanes(a6) /* planes - 1 */
                  tst.w    bitmap_width(a6) /* off-screen-bitmap? */
                  beq.s    vro_des
                  move.l   bitmap_addr(a6),r_saddr(a6)   /* address of bitmap */
                  move.w   bitmap_width(a6),r_swidth(a6) /* bytes per line */
                  sub.w    bitmap_off_x(a6),d0
                  sub.w    bitmap_off_y(a6),d1
                  sub.w    bitmap_off_x(a6),d2
                  sub.w    bitmap_off_y(a6),d3

vro_des:          move.l   fd_addr(a5),r_daddr(a6) /* destination address */
                  beq.s    vro_des_screen

                  move.w   fd_nplanes(a5),d7
                  subq.w   #1,d7
                  cmp.w    #7,d7             /* 8 Planes to copy? */
                  bne.s    vro_des_planes
                  cmp.w    r_planes(a6),d7   /* device with more than 8 Planes? */
                  bge.s    vro_des_planes
                  move.w   r_planes(a6),d7   /* correct AES-bug */
vro_des_planes:   move.w   d7,r_dplanes(a6)  /* planes - 1 */
                  addq.w   #1,d7
                  mulu.w   fd_wdwidth(a5),d7
                  add.w    d7,d7
                  move.w   d7,r_dwidth(a6)   /* bytes per destination line */
                  mulu.w   fd_h(a5),d7
                  move.l   d7,r_dplane_len(a6)

                  move.l   (v_bas_ad).w,d7
                  cmp.l    r_daddr(a6),d7    /* destination address of screen? */
                  bne.s    vro_width
                  move.w   fd_w(a5),d7
                  cmp.w    (V_REZ_HZ).w,d7   /* destination width same as screen width? */
                  bne.s    vro_width
                  move.w   (PLANES).w,d7
                  subq.w   #1,d7
                  cmp.w    r_dplanes(a6),d7  /* planes same as screen? */
                  bne.s    vro_width
                  move.w   (BYTES_LIN).w,r_dwidth(a6) /* set correct width */
                  bra.s    vro_width

vro_des_screen:   move.w   d2,d6          /* xq2 */
                  move.w   d3,d7          /* yq2 */
                  sub.w    d0,d6          /* - xq1 = width -1 */
                  sub.w    d1,d7          /* - yq1 = height -1 */
                  add.w    d4,d6          /* + xz1 = xz2 */
                  add.w    d5,d7          /* + yz1 = yz2 */

                  lea.l    clip_xmin(a6),a1
                  cmp.w    (a1)+,d4       /* xz1 < clip_xmin? */
                  bge.s    vro_clipdy1
                  sub.w    -(a1),d4
                  sub.w    d4,d0          /* correct xq1 */
                  move.w   (a1)+,d4
vro_clipdy1:      cmp.w    (a1)+,d5       /* yz1 < clip_ymin? */
                  bge.s    vro_clipdx2
                  sub.w    -(a1),d5
                  sub.w    d5,d1          /* correct yq1 */
                  move.w   (a1)+,d5
vro_clipdx2:      sub.w    (a1)+,d6       /* xz2 > clip_xmax? */
                  ble.s    vro_clipdy2
                  sub.w    d6,d2          /* correct xq2 */
vro_clipdy2:      sub.w    (a1),d7        /* yz2 > clip_ymax? */
                  ble.s    vro_desaddr
                  sub.w    d7,d3          /* correct yq2 */

vro_desaddr:      move.l   (v_bas_ad).w,r_daddr(a6) /* screen address */
                  move.w   (BYTES_LIN).w,r_dwidth(a6) /* width of destination in bytes */
                  move.l   bitmap_len(a6),r_dplane_len(a6)
                  move.w   r_planes(a6),r_dplanes(a6)   /* planes - 1 */

                  move.w   bitmap_width(a6),d7 /* off-screen-bitmap? */
                  beq.s    vro_width

                  move.l   bitmap_addr(a6),r_daddr(a6) /* address of bitmap */
                  move.w   d7,r_dwidth(a6) /* width of destination in bytes */
                  sub.w    bitmap_off_x(a6),d4
                  sub.w    bitmap_off_y(a6),d5

/* outside of clipping rectangle? */
vro_width:        exg      d2,d4
                  exg      d3,d5

                  sub.w    d0,d4          /* source width - 1 */
                  bmi.s    vro_cpyfm_exit
                  sub.w    d1,d5          /* source height - 1 */
                  bmi.s    vro_cpyfm_exit

                  move.w   r_dplanes(a6),d6
                  cmp.w    r_planes(a6),d6  /* planes different than device? */
                  bne.s    vro_cpyfm_mono
                  
                  movea.l  p_bitblt(a6),a0
                  jsr      (a0)

vro_cpyfm_exit:   movem.l  (sp)+,d1-d7/a2-a5
                  rts

vro_cpyfm_mono:   tst.w    d6             /* monochrom? */
                  bne.s    vro_cpyfm_exit

                  move.l   (mono_bitblt).w,d6 /* driver available? */
                  beq.s    vro_cpyfm_exit
                  movea.l  d6,a0
                  jsr      (a0)

                  movem.l  (sp)+,d1-d7/a2-a5
                  rts



/*
 * COPY RASTER, TRANSPARENT (VDI 121)
 */
vrt_cpyfm:        movem.l  d1-d7/a2-a5,-(sp)
                  movem.l  (a0),a1-a3
                  move.w   (a2)+,d0
                  subq.w   #MD_REPLACE,d0
                  cmpi.w   #MD_ERASE-MD_REPLACE,d0
                  bhi.s    vro_cpyfm_exit
                  move.w   d0,r_wmode(a6)
                  move.w   (a2)+,d0       /* fg_col */
                  move.w   (a2)+,d1       /* bg_col */
                  cmp.w    colors(a6),d0  /* color index valid ? */
                  bls.s    vrt_cpyfm_bg
                  moveq.l  #BLACK,d0
vrt_cpyfm_bg:     cmp.w    colors(a6),d1  /* color index valid ? */
                  bls.s    vrt_cpyfm_fg
                  moveq.l  #BLACK,d1
vrt_cpyfm_fg:     move.w   d0,r_fgcol(a6) /* fg_col */
                  move.w   d1,r_bgcol(a6) /* bg_col */

                  movem.l  s_addr(a1),a4-a5 /* psrcMFDB/pdesMFDB */
                  movem.w  (a3),d0-d7

vrt_sx:           cmp.w    d0,d2          /* swap coordinaten? */
                  bge.s    vrt_sy
                  exg      d0,d2
vrt_sy:           cmp.w    d1,d3
                  bge.s    vrt_dx
                  exg      d1,d3
vrt_dx:           cmp.w    d4,d6
                  bge.s    vrt_dy
                  exg      d4,d6
vrt_dy:           cmp.w    d5,d7
                  bge.s    vrt_src
                  exg      d5,d7

vrt_src:          move.l   fd_addr(a4),r_saddr(a6) /* source address */
                  bne.s    vrt_src_width

                  move.l   (v_bas_ad).w,r_saddr(a6) /* screen address */
                  move.w   (BYTES_LIN).w,r_swidth(a6) /* width of source line in bytes */
                  move.w   r_planes(a6),d7
                  clr.w    d7
                  tst.w    bitmap_width(a6) /* Off-Screen-Bitmap? */
                  beq.s    vrt_src_planes
                  move.l   bitmap_addr(a6),r_daddr(a6) /* bitmap address */
                  move.w   bitmap_width(a6),r_dwidth(a6) /* bytes per line */
                  sub.w    bitmap_off_x(a6),d0
                  sub.w    bitmap_off_y(a6),d1
                  sub.w    bitmap_off_x(a6),d2
                  sub.w    bitmap_off_y(a6),d3
                  bra.s    vrt_src_planes

vrt_src_width:    move.w   fd_wdwidth(a4),d7
                  add.w    d7,d7
                  move.w   d7,r_swidth(a6) /* bytes per source line */
                  mulu.w   fd_h(a4),d7
                  move.l   d7,r_splane_len(a6)
                  move.w   fd_nplanes(a4),d7
                  subq.w   #1,d7
vrt_src_planes:   move.w   d7,r_splanes(a6) /* planes - 1 */
                  bne      vrt_cpyfm_exit

                  move.l   fd_addr(a5),r_daddr(a6) /* destination address */
                  beq.s    vrt_des_screen

                  move.w   fd_nplanes(a5),d7
                  subq.w   #1,d7
                  cmp.w    #7,d7             /* 8 Planes to copy? */
                  bne.s    vrt_des_planes
                  cmp.w    r_planes(a6),d7     /* device with more than 8 Planes? */
                  bge.s    vrt_des_planes
                  move.w   r_planes(a6),d7     /* correct AES-bug */
vrt_des_planes:   move.w   d7,r_dplanes(a6) /* planes - 1 */
                  addq.w   #1,d7
                  mulu.w   fd_wdwidth(a5),d7
                  add.w    d7,d7
                  move.w   d7,r_dwidth(a6) /* width of destination line */
                  mulu.w   fd_h(a5),d7
                  move.l   d7,r_dplane_len(a6)

                  move.l   (v_bas_ad).w,d7
                  cmp.l    r_daddr(a6),d7   /* check for OVERSCAN */
                  bne.s    vrt_width
                  move.w   fd_w(a5),d7
                  cmp.w    (V_REZ_HZ).w,d7  /* screen width in pixel ? */
                  bne.s    vrt_width
                  move.w   (BYTES_LIN).w,r_dwidth(a6) /* set correct width */
                  bra.s    vrt_width

vrt_des_screen:   move.w   d2,d6          /* xq2 */
                  move.w   d3,d7          /* yq2 */
                  sub.w    d0,d6          /* - xq1 = width -1 */
                  sub.w    d1,d7          /* - yq1 = height -1 */
                  add.w    d4,d6          /* + xz1 = xz2 */
                  add.w    d5,d7          /* + yz1 = yz2 */

                  lea.l    clip_xmin(a6),a1
                  cmp.w    (a1)+,d4       /* xz1 < clip_xmin? */
                  bge.s    vrt_clipdy1
                  sub.w    -(a1),d4
                  sub.w    d4,d0          /* correct xq1 */
                  move.w   (a1)+,d4
vrt_clipdy1:      cmp.w    (a1)+,d5       /* yz1 < clip_ymin? */
                  bge.s    vrt_clipdx2
                  sub.w    -(a1),d5
                  sub.w    d5,d1          /* correct yq1 */
                  move.w   (a1)+,d5
vrt_clipdx2:      sub.w    (a1)+,d6       /* xz2 > clip_xmax? */
                  ble.s    vrt_clipdy2
                  sub.w    d6,d2          /* correct xq2 */
vrt_clipdy2:      sub.w    (a1),d7        /* yz2 > clip_ymax? */
                  ble.s    vrt_desaddr
                  sub.w    d7,d3          /* correct yq2 */

vrt_desaddr:      move.l   (v_bas_ad).w,r_daddr(a6) /* screen address */
                  move.w   (BYTES_LIN).w,r_dwidth(a6) /* width of destination in bytes */
                  move.w   r_planes(a6),r_dplanes(a6)   /* planes - 1 */
                  move.l   bitmap_len(a6),r_dplane_len(a6)
                  move.w   bitmap_width(a6),d7 /* off-screen-bitmap? */
                  beq.s    vrt_width
                  move.l   bitmap_addr(a6),r_daddr(a6) /* adress of bitmap */
                  move.w   d7,r_dwidth(a6) /* bytes per line */
                  sub.w    bitmap_off_x(a6),d4
                  sub.w    bitmap_off_y(a6),d5

/* outside of clipping rectangle? */
vrt_width:        exg      d2,d4
                  exg      d3,d5

                  sub.w    d0,d4          /* source width - 1 */
                  bmi.s    vrt_cpyfm_exit
                  sub.w    d1,d5          /* source height - 1 */
                  bmi.s    vrt_cpyfm_exit

                  move.w   r_dplanes(a6),d6
                  cmp.w    r_planes(a6),d6  /* planes different than device? */
                  bne.s    vrt_cpyfm_mono

                  movea.l  p_expblt(a6),a0
                  jsr      (a0)

vrt_cpyfm_exit:   movem.l  (sp)+,d1-d7/a2-a5
                  rts

vrt_cpyfm_mono:   tst.w    d6             /* monochromes vrt_cpyfm? */
                  bne.s    vrt_cpyfm_exit
                  
                  move.l   (mono_expblt).w,d6 /* driver available? */
                  beq.s    vrt_cpyfm_exit
                  movea.l  d6,a0
                  jsr      (a0)

                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/*
 *TRANSFORM FORM (VDI 110)
 */
vr_trnfm:         movem.l  d1-d7/a2-a5,-(sp)
                  movea.l  (a0),a1           /* contrl */
                  movem.l  s_addr(a1),a0-a1  /* Zeiger auf psrcMFDB/pdesMFDB */
                  movea.l  p_transform(a6),a2
                  jsr      (a2)
                  movem.l  (sp)+,d1-d7/a2-a5
                  rts

/*
 * GET PIXEL (VDI 105)
 */
v_get_pixel:      movem.l  d1-d2/a2,-(sp)
                  movea.l  pb_intout(a0),a2
                  movea.l  pb_ptsin(a0),a0

                  move.w   (a0)+,d0
                  move.w   (a0)+,d1
                  movea.l  p_get_pixel(a6),a0
                  jsr      (a0)

                  cmp.w    #15,r_planes(a6) /* mehr als 16 Bit? */
                  bgt.s    v_get_pixel_tc

                  move.w   d0,(a2)+       /* intout[0] = Pixelzustand */
                  movea.l  p_color_to_vdi(a6),a0
                  jsr      (a0)
                  move.w   d0,(a2)+       /* intout[1] = VDI-Farbindex */

                  movem.l  (sp)+,d1-d2/a2
                  rts

v_get_pixel_tc:   swap     d0
                  move.l   d0,(a2)+
                  movem.l  (sp)+,d1-d2/a2
                  rts
