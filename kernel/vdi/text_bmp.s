                  /* 'allgemeine Textausgabe' */

/* teilweise Textausgabe */
text_partitial:
                  move.l   t_image(a6),-(sp)

                  exg      d0,d2
                  exg      d1,d3
                  move.w   t_rotation(a6),d7 /* 0 degree ? */
                  beq.s    text_part_loop
                  subq.w   #T_ROT_90,d7   /* 90 degree ? */
                  beq.s    text_part_loop
                  exg      d1,d3
                  subq.w   #T_ROT_180-T_ROT_90,d7 /* 180 degree ? */
                  beq.s    text_part_loop
                  exg      d1,d3
                  exg      d0,d2

text_part_loop:

                  move.w   t_act_line(a6),d0 /* character cell width without effects */
                  move.w   t_cheight(a6),d1 /* character cell height */

                  btst     #T_OUTLINED_BIT,t_effects+1(a6)
                  beq.s    text_part_line
                  moveq.l  #16,d5         /* number of lines - 1 */
                  tst.w    d0             /* the top lines ? */
                  beq.s    text_part_clipy
                  subq.w   #1,d0
                  sub.w    d0,d1
                  cmp.w    d5,d1          /* the bottom lines ? */
                  ble.s    text_part_clipy
                  moveq.l  #17,d5         /* number of lines - 1 */
                  bra.s    text_part_clipy

text_part_line:   moveq.l  #15,d5         /* number of lines - 1 */
                  sub.w    d0,d1
                  cmp.w    d5,d1
                  bgt.s    text_part_clipy
                  subq.w   #1,d1
                  move.w   d1,d5          /* number of lines - 1 */

text_part_clipy:  move.w   d3,d4
                  add.w    d5,d4

                  movea.l  (sp),a1        /* t_image */
                  movem.w  d2-d3,-(sp)    /* x/y on stack */
                  move.w   d6,-(sp)       /* character counter */
                  move.w   a3,-(sp)       /* buffer start width */
                  move.l   a5,-(sp)       /* intin */

                  mulu.w   t_iheight(a6),d0
                  divu.w   t_cheight(a6),d0
                  mulu.w   t_iwidth(a6),d0
                  adda.l   d0,a1
                  move.l   a1,t_image(a6)

text_part_fill:
                  move.w   t_space_kind(a6),-(sp)
                  move.w   t_add_length(a6),-(sp)
                  bsr      fill_text_buf  /* copy everything to buffer */
                  move.w   (sp)+,t_add_length(a6)
                  move.w   (sp)+,t_space_kind(a6)

/* d4 Bufferbreite - 1 */
/* d5 Bufferhoehe - 1 */
                  movea.l  buffer_addr(a6),a0 /* address of text buffer */
                  movea.w  a3,a2          /* size of textbuffer in bytes */

                  move.w   t_effects(a6),d7
                  beq.s    text_part_output
                  btst     #T_BOLD_BIT,d7 /* bold ? */
                  beq.s    text_part_underlined
                  bsr      bold
text_part_underlined:
                  btst     #T_UNDERLINED_BIT,t_effects+1(a6) /* underlined ? */
                  beq.s    text_part_outlined
                  pea.l    text_part_outlined(pc)
                  btst     #T_OUTLINED_BIT,t_effects+1(a6)
                  beq      underline
                  addq.l   #4,sp          /* adjust stack */
                  adda.w   a2,a0
                  bsr      underline
                  suba.w   a2,a0
text_part_outlined:
                  btst     #T_OUTLINED_BIT,t_effects+1(a6) /* outlined ? */
                  beq.s    text_part_lightend
                  bsr      outline
                  subq.w   #2,d5
                  move.w   t_act_line(a6),d0 /* the top lines ? */
                  beq.s    text_part_lightend
                  adda.w   a2,a0
                  adda.w   a2,a0          /* ignore top lines ! */
                  addi.w   #16,d0         /* output whole text ? */
                  cmp.w    t_cheight(a6),d0 /* the bottom lines ? */
                  bge.s    text_part_lightend
                  subq.w   #2,d5
text_part_lightend:
                  btst     #T_LIGHT_BIT,t_effects+1(a6) /* light ? */
                  beq.s    text_part_output
                  bsr      light

text_part_output: movea.l  (sp)+,a5
                  movea.w  (sp)+,a3
                  move.w   (sp)+,d6
                  movem.w  (sp)+,d2-d3    /* x/y */
                  move.w   t_rotation(a6),d7 /* text rotation ? */
                  bne.s    textp_rot90
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  bne.s    text_part_ital0
                  movem.l  d2-d6/a1/a3/a5,-(sp)
                  bsr      textblt_xs0
                  movem.l  (sp)+,d2-d6/a1/a3/a5
text_part_next:   addq.w   #1,d5
                  add.w    d5,d3
                  moveq.l  #16,d1
                  add.w    t_act_line(a6),d1
                  move.w   d1,t_act_line(a6)
                  move.w   t_cheight(a6),d5
                  sub.w    d1,d5          /* still lines to output ? */
                  bgt      text_part_loop
                  move.l   (sp)+,t_image(a6)
                  rts

text_part_ital0:  movem.w  d3/d5-d6,-(sp)
                  tst.w    t_act_line(a6)
                  bne.s    text_part_skew0
                  sub.w    t_left_off(a6),d2
                  add.w    t_whole_off(a6),d2
text_part_skew0:  move.w   #$5555,d6   /* t_skew_mask */
                  moveq.l  #0,d1
                  move.w   d5,d7
textp_ital_loop0: moveq.l  #0,d5
                  movem.l  d1-d7/a0-a5,-(sp)
                  moveq.l  #0,d0
                  bsr      textblt
                  movem.l  (sp)+,d1-d7/a0-a5
                  ror.w    #1,d6
                  bcc.s    textp_ital_next0
                  subq.w   #1,d2
textp_ital_next0: addq.w   #1,d3          /* next dest line */
                  addq.w   #1,d1          /* next source line */
                  dbra     d7,textp_ital_loop0
                  movem.w  (sp)+,d3/d5-d6
                  bra.s    text_part_next

textp_rot90:      subq.w   #T_ROT_90,d7   /* rotate 90 degrees ? */
                  bne.s    textp_rot180

                  movem.l  d6/a3/a5,-(sp)
                  bsr      rotate90       /* rotate char by 90 degree */
                  movem.l  (sp)+,d6/a3/a5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  bne.s    textp_ital90
                  movem.l  d2-d6/a3/a5,-(sp)
                  bsr      textblt_xs0
                  movem.l  (sp)+,d2-d6/a3/a5

text_part_next90: addq.w   #1,d4
                  add.w    d4,d2
                  moveq.l  #16,d1
                  add.w    t_act_line(a6),d1
                  move.w   d1,t_act_line(a6)
                  move.w   t_cheight(a6),d5
                  sub.w    d1,d5          /* still lines to output ? */
                  bgt      text_part_loop

                  move.l   (sp)+,t_image(a6)
                  rts

textp_ital90:     movem.w  d2/d4-d6,-(sp)
                  tst.w    t_act_line(a6)
                  bne.s    text_part_skew90
                  add.w    t_left_off(a6),d3
                  sub.w    t_whole_off(a6),d3
text_part_skew90: move.w   #$5555,d6      /* t_skew_mask */
                  moveq.l  #0,d0
                  move.w   d4,d7
textp_ital_loop90:moveq.l  #0,d4
                  movem.l  d0/d2-d7/a0-a5,-(sp)
                  bsr      textblt_ys0
                  movem.l  (sp)+,d0/d2-d7/a0-a5
                  ror.w    #1,d6
                  bcc.s    textp_ital_next90
                  addq.w   #1,d3
textp_ital_next90:addq.w   #1,d2
                  addq.w   #1,d0          /* next source line */
                  dbra     d7,textp_ital_loop90
                  movem.w  (sp)+,d2/d4-d6
                  bra.s    text_part_next90

textp_rot180:     subq.w   #T_ROT_180-T_ROT_90,d7 /* rotate 180 degrees ? */
                  bne.s    textp_rot270
                  movem.l  d6/a3/a5,-(sp)
                  bsr      rotate180      /* rotate char by 180 degree */
                  movem.l  (sp)+,d6/a3/a5
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  bne.s    textp_ital180
                  sub.w    d5,d3
                  movem.l  d2-d6/a3/a5,-(sp)
                  bsr      textblt_xs0
                  movem.l  (sp)+,d2-d6/a3/a5

                  subq.w   #1,d3
text_part_next180:moveq.l  #16,d1
                  add.w    t_act_line(a6),d1
                  move.w   d1,t_act_line(a6)
                  move.w   t_cheight(a6),d5
                  sub.w    d1,d5          /* still lines to output ? */
                  bgt      text_part_loop
                  move.l   (sp)+,t_image(a6)
                  rts

textp_ital180:    movem.w  d5-d6,-(sp)
                  tst.w    t_act_line(a6)
                  bne.s    text_part_skew180
                  add.w    t_left_off(a6),d2
                  sub.w    t_whole_off(a6),d2
text_part_skew180:move.w   #$5555,d6      /* t_skew_mask BUG: should be taken from fonthdr */
                  move.w   d5,d7
                  move.w   d5,d1
textp_ital_loop180:
                  moveq.l  #0,d5
                  movem.l  d1-d7/a0-a5,-(sp)
                  moveq.l  #0,d0
                  bsr      textblt
                  movem.l  (sp)+,d1-d7/a0-a5
                  ror.w    #1,d6
                  bcc.s    textp_ital_next180
                  addq.w   #1,d2
textp_ital_next180:
                  subq.w   #1,d3
                  subq.w   #1,d1          /* next source line */
                  dbra     d7,textp_ital_loop180
                  movem.w  (sp)+,d5-d6
                  bra.s    text_part_next180

textp_rot270:
                  movem.l  d6/a3/a5,-(sp)
                  bsr      rotate270      /* rotate char by 270 degree */
                  movem.l  (sp)+,d6/a3/a5
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  bne.s    textp_ital270
                  sub.w    d4,d2
                  movem.l  d2-d6/a3/a5,-(sp)
                  bsr      textblt_xs0
                  movem.l  (sp)+,d2-d6/a3/a5

                  subq.w   #1,d2
text_part_next270:moveq.l  #16,d1
                  add.w    t_act_line(a6),d1
                  move.w   d1,t_act_line(a6)
                  move.w   t_cheight(a6),d5
                  sub.w    d1,d5          /* still lines to output ? */
                  bgt      text_part_loop
                  move.l   (sp)+,t_image(a6)
                  rts
textp_ital270:    movem.w  d5-d6,-(sp)
                  tst.w    t_act_line(a6)
                  bne.s    text_part_skew270
                  sub.w    t_left_off(a6),d3
                  add.w    t_whole_off(a6),d3

text_part_skew270:move.w   #$5555,d6      /* t_skew_mask(a6) */
                  move.w   d4,d0
                  move.w   d4,d7
textp_ital_loop270:
                  moveq.l  #0,d4
                  movem.l  d0/d2-d7/a0-a5,-(sp)
                  bsr      textblt_ys0
                  movem.l  (sp)+,d0/d2-d7/a0-a5
                  ror.w    #1,d6
                  bcc.s    textp_ital_next270
                  subq.w   #1,d3
textp_ital_next270:
                  subq.w   #1,d2
                  subq.w   #1,d0          /* next source line */
                  dbra     d7,textp_ital_loop270
                  movem.w  (sp)+,d5-d6
                  bra.s    text_part_next270

/*
 * Allgemeine Textroutine
 * Eingaben
 * a1 contrl
 * a2 intin
 * a3 ptsin
 * a6 Zeiger auf die Workstation
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
text:             move.w   n_intin(a1),d6 /* character count */
                  ble.s    text_exit      /* enough ? */
                  subq.w   #1,d6          /* character counter */

                  clr.l    t_act_line(a6) /* clear t_act_line/t_add_length */

                  moveq.l  #0,d5
                  move.w   t_effects(a6),d0
                  btst     #T_BOLD_BIT,d0 /* bold ? */
                  beq.s    text_eff_out
                  move.w   t_thicken(a6),d5 /* thickening for bold */
text_eff_out:     btst     #T_OUTLINED_BIT,d0 /* outlined? */
                  beq.s    text_thicken
                  addq.w   #2,d5          /* thickening for outline */
text_thicken:     move.w   d5,t_eff_thicken(a6) /* wideningo for effects */

                  movea.l  t_fonthdr(a6),a0
                  move.l   dat_table(a0),t_image(a6) /* address of fontimage ??? why take that from fonthdr again? */
                  movea.l  a2,a5          /* addresse of intin */
                  movea.l  t_offtab(a6),a4 /* address of character offset */

                  tst.b    t_prop(a6)     /* proportional font ? */
                  beq.s    text_mono

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  moveq.l  #-1,d4         /* initialize total width */
                  move.w   d6,d7          /* character counter */

text_width:       move.w   (a2)+,d2       /* character index */
                  sub.w    d0,d2
                  cmp.w    d1,d2          /* character present ? */
                  bls.s    text_width_char
                  move.w   t_unknown_index(a6),d2
text_width_char:  add.w    d2,d2
                  move.w   2(a4,d2.w),d3
                  sub.w    0(a4,d2.w),d3  /* unscaled width */
                  tst.b    t_grow(a6)     /* enlarge ? */
                  beq.s    text_width_add
                  mulu.w   t_cheight(a6),d3 /* * character height */
                  divu.w   t_iheight(a6),d3 /* / actual height */
text_width_add:   add.w    d5,d3          /* + widening from effects */
                  add.w    d3,d4
                  dbra     d7,text_width
                  tst.w    d4             /* at least 1 pixel ? */
                  bpl.s    text_position
text_exit:        rts

text_mono:        move.w   t_cwidth(a6),d4 /* character width */
                  add.w    d5,d4          /* + widening from effects */
                  addq.w   #1,d6
                  mulu.w   d6,d4          /* * character count */
                  subq.w   #1,d6
                  subq.w   #1,d4          /* width of all chars -1 */

text_position:    move.w   (a3)+,d0       /* x */
                  move.w   (a3)+,d1       /* y */

                  move.w   t_ver(a6),d3   /* vertical alignment */
                  add.w    d3,d3
                  move.w   t_base(a6,d3.w),d3 /* shift up */

                  move.w   t_cheight(a6),d5
                  subq.w   #1,d5          /* cell height -1 */

                  btst     #T_OUTLINED_BIT,t_effects+1(a6) /* outlined ? */
                  beq.s    text_alignment
                  addq.w   #1,d3          /* one line up */
                  addq.w   #2,d5          /* two lines up */

text_alignment:   moveq.l  #0,d2          /* shift to left */
                  move.w   t_hor(a6),d7   /* horizontal alignment */
                  beq.s    text_left      /* left aligned ? */
                  subq.w   #T_MID_ALIGN,d7 /* centered ? */
                  bne.s    text_right
                  move.w   d4,d2
                  addq.w   #1,d2
                  asr.w    #1,d2
                  bra.s    text_left
text_right:       move.w   d4,d2          /* right aligned */
text_left:        move.w   t_rotation(a6),d7 /* text rotation ? */
                  beq      text_clip_rot0
                  subq.w   #T_ROT_90,d7   /* 90 degree ? */
                  bne      text_clip_rot180

                  tst.w    t_add_length(a6) /* stretching ? */
                  beq.s    text_cl900_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl900_x1
                  sub.w    t_left_off(a6),d1 /* shift up */

text_cl900_x1:    sub.w    d3,d0          /* x1 */
                  add.w    d2,d1
                  move.w   d0,d2
                  move.w   d1,d3          /* y2 */
                  add.w    d5,d2          /* x2 */
                  sub.w    d4,d1          /* y1 */

                  cmp.w    clip_xmax(a6),d0 /* too far right ? */
                  bgt.s    text_exit
                  cmp.w    clip_xmin(a6),d2 /* too far left ? */
                  blt.s    text_exit

                  cmp.w    clip_ymax(a6),d1 /* too far to bottom ? */
                  ble.s    text_cl90_top
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d1,d7
                  add.w    t_left_off(a6),d7
                  sub.w    t_whole_off(a6),d7
                  cmp.w    clip_ymax(a6),d7
                  bgt      text_exit

text_cl90_top:    cmp.w    clip_ymin(a6),d3 /* too far to top ? */
                  bge.s    text_cl90_y1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d3,d7
                  add.w    t_left_off(a6),d7
                  cmp.w    clip_ymin(a6),d7
                  blt      text_exit

text_cl90_y1:     cmp.w    clip_ymin(a6),d1
                  bge      text_cl90_y2

                  movem.w  d0/d2-d5,-(sp)

                  movem.w  t_first_ade(a6),d2-d3 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */
                  move.w   d6,d7                 /* character counter */
                  add.w    d7,d7
                  lea.l    2(a5,d7.w),a2

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl90_y1_loop
                  add.w    t_left_off(a6),d1 /* left character margin */

text_cl90_y1_loop:move.w   -(a2),d0       /* character index */
                  sub.w    d2,d0
                  cmp.w    d3,d0          /* character present ? */
                  bls.s    text_cl90_y1_width
                  move.w   t_unknown_index(a6),d2
text_cl90_y1_width:
                  add.w    d0,d0
                  move.w   2(a4,d0.w),d4
                  sub.w    0(a4,d0.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  add.w    d4,d1

                  cmp.w    clip_ymin(a6),d1 /* outside clipping rectangle ? */
                  bgt.s    text_cl90_y1_end
                  tst.w    d6
                  beq.s    text_cl90_y1_end

                  move.w   t_add_length(a6),d7 /* widen ? */

                  beq.s    text_cl90_y1_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d0 /* character spacing ? */
                  bmi.s    text_cl90_y1_char
                  cmpi.w   #SPACE,(a2)         /* space ? */
                  bne.s    text_cl90_y1_next
                  divs.w   d0,d7
                  add.w    d7,d1
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl90_y1_loop /* decrement character counter */
text_cl90_y1_char:divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  add.w    d7,d1
text_cl90_y1_next:dbra     d6,text_cl90_y1_loop

text_cl90_y1_end: sub.w    d4,d1
                  movem.w  (sp)+,d0/d2-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl90_y2
                  sub.w    t_left_off(a6),d1 /* left character margin */

text_cl90_y2:     cmp.w    clip_ymax(a6),d3
                  ble      text_cl270_width

                  movem.w  d0-d2/d4-d5,-(sp)

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5 /* widening from effects */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl90_y2_loop
                  add.w    t_left_off(a6),d3
                  sub.w    t_whole_off(a6),d3 /* right character margin */

text_cl90_y2_loop:move.w   (a5)+,d2       /* character index */
                  sub.w    d0,d2
                  cmp.w    d1,d2          /* character present ? */
                  bls.s    text_cl90_y2_width
                  move.w   t_unknown_index(a6),d2
text_cl90_y2_width:
                  add.w    d2,d2
                  move.w   2(a4,d2.w),d4
                  sub.w    0(a4,d2.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  sub.w    d4,d3

                  cmp.w    clip_ymax(a6),d3 /* inside clipping rectangle ? */
                  blt.s    text_cl90_y2_end
                  tst.w    d6
                  beq.s    text_cl90_y2_end

                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl90_y2_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d2 /* character spacing ? */
                  bmi.s    text_cl90_y2_char
                  cmpi.w   #SPACE,-2(a5)       /* space ? */
                  bne.s    text_cl90_y2_next
                  divs.w   d2,d7
                  sub.w    d7,d3
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl90_y2_loop /* decrement character counter */
text_cl90_y2_char:divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  sub.w    d7,d3
text_cl90_y2_next:dbra     d6,text_cl90_y2_loop /* decrement character counter */

text_cl90_y2_end: add.w    d4,d3          /* output position */
                  subq.l   #2,a5          /* first character to output */
                  movem.w  (sp)+,d0-d2/d4-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_cl270_width
                  sub.w    t_left_off(a6),d3
                  add.w    t_whole_off(a6),d3
                  bra      text_cl270_width

text_clip_rot180: subq.w   #T_ROT_180-T_ROT_90,d7 /* 180 degreee ? */
                  bne      text270

                  tst.w    t_add_length(a6) /* widen ? */
                  beq.s    text_cl1800_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl1800_x1
                  sub.w    t_left_off(a6),d0 /* shift to left */

text_cl1800_x1:   add.w    d2,d0
                  add.w    d3,d1
                  move.w   d0,d2          /* x2 */
                  move.w   d1,d3          /* y2 */
                  sub.w    d4,d0          /* x1 */
                  sub.w    d5,d1          /* y1 */

                  cmp.w    clip_ymax(a6),d1 /* too far to bottom ? */
                  bgt      text_exit
                  cmp.w    clip_ymin(a6),d3 /* too far to top ? */
                  blt      text_exit

                  cmp.w    clip_xmax(a6),d0 /* too far right ? */
                  ble.s    text_cl180_left
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d0,d7
                  add.w    t_left_off(a6),d7
                  sub.w    t_whole_off(a6),d7
                  cmp.w    clip_xmax(a6),d7
                  bgt      text_exit

text_cl180_left:  cmp.w    clip_xmin(a6),d2 /* too far left ? */
                  bge.s    text_cl180_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d2,d7
                  add.w    t_left_off(a6),d7
                  cmp.w    clip_xmin(a6),d7
                  blt      text_exit

text_cl180_x1:    cmp.w    clip_xmin(a6),d0
                  bge      text_cl180_x2

                  movem.w  d1-d5,-(sp)

                  movem.w  t_first_ade(a6),d2-d3 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5 /* widening from effects */
                  move.w   d6,d7
                  add.w    d7,d7

                  lea.l    2(a5,d7.w),a2

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl180_x1_loop
                  add.w    t_left_off(a6),d0 /* left character margin */

text_cl180_x1_loop:
                  move.w   -(a2),d1       /* character index */
                  sub.w    d2,d1
                  cmp.w    d3,d1          /* character present ? */
                  bls.s    text_cl180_x1_width
                  move.w   t_unknown_index(a6),d1
text_cl180_x1_width:
                  add.w    d1,d1
                  move.w   2(a4,d1.w),d4
                  sub.w    0(a4,d1.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4          /* + widening from effects */
                  add.w    d4,d0

                  cmp.w    clip_xmin(a6),d0 /* outside clipping rectangle ? */
                  bgt.s    text_cl180_x1_end

                  tst.w    d6
                  beq.s    text_cl180_x1_end
                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl180_x1_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d1 /* character spacing ? */
                  bmi.s    text_cl180_x1_char
                  cmpi.w   #SPACE,(a2)    /* space ? */
                  bne.s    text_cl180_x1_next
                  divs.w   d1,d7
                  add.w    d7,d0
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl180_x1_loop /* decrement character counter */
text_cl180_x1_char:
                  divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  add.w    d7,d0

text_cl180_x1_next:
                  dbra     d6,text_cl180_x1_loop

text_cl180_x1_end:sub.w    d4,d0
                  movem.w  (sp)+,d1-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl180_x2
                  sub.w    t_left_off(a6),d0 /* left character margin */

text_cl180_x2:    cmp.w    clip_xmax(a6),d2
                  ble      text_cl0_width

                  movem.w  d0-d1/d3-d5,-(sp)

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl180_x2_loop
                  add.w    t_left_off(a6),d2
                  sub.w    t_whole_off(a6),d2 /* right character marging */

text_cl180_x2_loop:
                  move.w   (a5)+,d3       /* character index */
                  sub.w    d0,d3
                  cmp.w    d1,d3          /* character present ? */
                  bls.s    text_cl180_x2_width
                  move.w   t_unknown_index(a6),d3
text_cl180_x2_width:
                  add.w    d3,d3
                  move.w   2(a4,d3.w),d4
                  sub.w    0(a4,d3.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  sub.w    d4,d2

                  cmp.w    clip_xmax(a6),d2 /* inside clipping rectangle ? */
                  blt.s    text_cl180_x2_end

                  tst.w    d6
                  beq.s    text_cl180_x2_end
                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl180_x2_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d3 /* character spacing ? */
                  bmi.s    text_cl180_x2_char
                  cmpi.w   #SPACE,-2(a5)       /* space ? */
                  bne.s    text_cl180_x2_next
                  divs.w   d3,d7
                  sub.w    d7,d2
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl180_x2_loop /* decrement character counter */
text_cl180_x2_char:
                  divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  sub.w    d7,d2
text_cl180_x2_next:
                  dbra     d6,text_cl180_x2_loop /* decrement character counter */

text_cl180_x2_end:add.w    d4,d2          /* output position */
                  subq.l   #2,a5          /* first character to output */
                  movem.w  (sp)+,d0-d1/d3-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_cl0_width
                  sub.w    t_left_off(a6),d2
                  add.w    t_whole_off(a6),d2 /* right character marging */
                  bra      text_cl0_width

text270:          tst.w    t_add_length(a6) /* widen ? */
                  beq.s    text_cl2700_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl2700_x1
                  add.w    t_left_off(a6),d1 /* shift to bottom */

text_cl2700_x1:   add.w    d3,d0
                  sub.w    d2,d1          /* y1 */

                  move.w   d0,d2          /* x2 */
                  move.w   d1,d3

                  sub.w    d5,d0          /* x1 */
                  add.w    d4,d3          /* y2 */

                  cmp.w    clip_xmax(a6),d0 /* too far right ? */
                  bgt      text_exit
                  cmp.w    clip_xmin(a6),d2 /* too far left ? */
                  blt      text_exit

                  cmp.w    clip_ymax(a6),d1 /* too far to bottom ? */
                  ble.s    text_cl270_top
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d1,d7
                  sub.w    t_left_off(a6),d7
                  cmp.w    clip_ymax(a6),d7
                  bgt      text_exit

text_cl270_top:   cmp.w    clip_ymin(a6),d3 /* too far to top ? */
                  bge.s    text_cl270_y1

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d3,d7
                  sub.w    t_left_off(a6),d7
                  add.w    t_whole_off(a6),d7
                  cmp.w    clip_ymin(a6),d7
                  blt      text_exit

text_cl270_y1:    cmp.w    clip_ymin(a6),d1
                  bge      text_cl270_y2

                  movem.w  d0/d2-d5,-(sp)

                  movem.w  t_first_ade(a6),d2-d3 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */

                  beq.s    text_cl270_y1_loop
                  sub.w    t_left_off(a6),d1
                  add.w    t_whole_off(a6),d1 /* right character marging */

text_cl270_y1_loop:
                  move.w   (a5)+,d0       /* character index */
                  sub.w    d2,d0
                  cmp.w    d3,d0          /* character present ? */
                  bls.s    text_cl270_y1_width
                  move.w   t_unknown_index(a6),d0
text_cl270_y1_width:
                  add.w    d0,d0
                  move.w   2(a4,d0.w),d4
                  sub.w    0(a4,d0.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  add.w    d4,d1

                  cmp.w    clip_ymin(a6),d1 /* inside clipping rectangle ? */
                  bgt.s    text_cl270_y1_end
                  tst.w    d6
                  beq.s    text_cl270_y1_end

                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl270_y1_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d0 /* character spacing ? */
                  bmi.s    text_cl270_y1_char
                  cmpi.w   #SPACE,-2(a5)       /* space ? */
                  bne.s    text_cl270_y1_next
                  divs.w   d0,d7
                  add.w    d7,d1
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl270_y1_loop /* decrement character counter */
text_cl270_y1_char:
                  divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  add.w    d7,d1
text_cl270_y1_next:
                  dbra     d6,text_cl270_y1_loop /* decrement character counter */

text_cl270_y1_end:sub.w    d4,d1          /* output position */
                  subq.l   #2,a5          /* first character to output */
                  movem.w  (sp)+,d0/d2-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl270_y2
                  add.w    t_left_off(a6),d1
                  sub.w    t_whole_off(a6),d1 /* right character marging */

text_cl270_y2:    cmp.w    clip_ymax(a6),d3
                  ble      text_cl270_width

                  movem.w  d0-d2/d4-d5,-(sp)

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */
                  move.w   d6,d7          /* character counter */
                  add.w    d7,d7
                  lea.l    2(a5,d7.w),a2  /* end of intin */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl270_y2_loop
                  sub.w    t_left_off(a6),d3 /* left character margin */

text_cl270_y2_loop:
                  move.w   -(a2),d2       /* character index */
                  sub.w    d0,d2
                  cmp.w    d1,d2          /* character present ? */
                  bls.s    text_cl270_y2_width
                  move.w   t_unknown_index(a6),d2
text_cl270_y2_width:
                  add.w    d2,d2
                  move.w   2(a4,d2.w),d4
                  sub.w    0(a4,d2.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  sub.w    d4,d3

                  cmp.w    clip_ymax(a6),d3 /* outside clipping rectangle ? */
                  blt.s    text_cl270_y2_end
                  tst.w    d6
                  beq.s    text_cl270_y2_end

                  move.w   t_add_length(a6),d7 /* widen ? */

                  beq.s    text_cl270_y2_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d2 /* character spacing ? */
                  bmi.s    text_cl270_y2_char
                  cmpi.w   #SPACE,(a2)         /* space ? */
                  bne.s    text_cl270_y2_next
                  divs.w   d2,d7
                  sub.w    d7,d3
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl270_y2_loop /* decrement character counter */
text_cl270_y2_char:
                  divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  sub.w    d7,d3
text_cl270_y2_next:
                  dbra     d6,text_cl270_y2_loop

text_cl270_y2_end:add.w    d4,d3
                  movem.w  (sp)+,d0-d2/d4-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl270_width
                  add.w    t_left_off(a6),d3 /* left character margin */

text_cl270_width: move.w   d3,d4
                  sub.w    d1,d4          /* buffer width in pixel -1 */
                  bra      text_buf_width

text_clip_rot0:   tst.w    t_add_length(a6) /* widen ? */
                  beq.s    text_cl00_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl00_x1
                  add.w    t_left_off(a6),d0 /* shift right */

text_cl00_x1:     sub.w    d2,d0          /* x1 of text rectangle */
                  sub.w    d3,d1          /* y1 of text rectangle */
                  move.w   d0,d2
                  move.w   d1,d3
                  add.w    d4,d2          /* x2 of text rectangle */
                  add.w    d5,d3          /* y2 of text rectangle */

                  cmp.w    clip_ymax(a6),d1 /* too far to bottom ? */
                  bgt      text_exit
                  cmp.w    clip_ymin(a6),d3 /* too far to top ? */
                  blt      text_exit

                  cmp.w    clip_xmax(a6),d0 /* too far right ? */
                  ble.s    text_clip0_left
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d0,d7
                  sub.w    t_left_off(a6),d7
                  cmp.w    clip_xmax(a6),d7
                  bgt      text_exit

text_clip0_left:  cmp.w    clip_xmin(a6),d2 /* too far left ? */
                  bge.s    text_cl0_x1
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      text_exit
                  move.w   d2,d7
                  sub.w    t_left_off(a6),d7
                  add.w    t_whole_off(a6),d7
                  cmp.w    clip_xmin(a6),d7
                  blt      text_exit

text_cl0_x1:      cmp.w    clip_xmin(a6),d0 /* clip left ? */
                  bge      text_cl0_x2

                  movem.w  d1-d5,-(sp)

                  movem.w  t_first_ade(a6),d2-d3 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl0_x1_loop
                  sub.w    t_left_off(a6),d0
                  add.w    t_whole_off(a6),d0 /* right character marging */

text_cl0_x1_loop: move.w   (a5)+,d1       /* character index */
                  sub.w    d2,d1
                  cmp.w    d3,d1          /* character present ? */
                  bls.s    text_cl0_x1_width
                  move.w   t_unknown_index(a6),d1
text_cl0_x1_width:add.w    d1,d1
                  move.w   2(a4,d1.w),d4
                  sub.w    0(a4,d1.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  add.w    d4,d0

                  cmp.w    clip_xmin(a6),d0 /* inside clipping rectangle ? */
                  bgt.s    text_cl0_x1_end

                  tst.w    d6             /* last character ? */
                  beq.s    text_cl0_x1_end

                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl0_x1_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d1 /* character spacing ? */
                  bmi.s    text_cl0_x1_char
                  cmpi.w   #SPACE,-2(a5)    /* space ? */
                  bne.s    text_cl0_x1_next
                  divs.w   d1,d7
                  add.w    d7,d0
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl0_x1_loop /* decrement character counter */
text_cl0_x1_char: divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  add.w    d7,d0
text_cl0_x1_next: dbra     d6,text_cl0_x1_loop /* decrement character counter */

text_cl0_x1_end:  sub.w    d4,d0          /* output position */
                  subq.l   #2,a5          /* first character to output */
                  movem.w  (sp)+,d1-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl0_x2
                  add.w    t_left_off(a6),d0
                  sub.w    t_whole_off(a6),d0

text_cl0_x2:      cmp.w    clip_xmax(a6),d2 /* clip right ? */
                  ble      text_cl0_width

                  movem.w  d0-d1/d3-d5,-(sp) /* save registers */
                  move.w   d6,d7
                  add.w    d7,d7
                  lea.l    2(a5,d7.w),a2

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  move.w   t_eff_thicken(a6),d5  /* widening from effects */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl0_x2_loop
                  sub.w    t_left_off(a6),d2 /* left character margin */

text_cl0_x2_loop: move.w   -(a2),d3       /* character index */
                  sub.w    d0,d3
                  cmp.w    d1,d3          /* character present ? */
                  bls.s    text_cl0_x2_width
                  move.w   t_unknown_index(a6),d3
text_cl0_x2_width:add.w    d3,d3
                  move.w   2(a4,d3.w),d4
                  sub.w    0(a4,d3.w),d4
                  mulu.w   t_cheight(a6),d4 /* * character height */
                  divu.w   t_iheight(a6),d4 /* / actual height */
                  add.w    d5,d4            /* + widening from effects */
                  sub.w    d4,d2

                  cmp.w    clip_xmax(a6),d2 /* inside clipping rectangle ? */
                  blt.s    text_cl0_x2_end

                  tst.w    d6             /* last character ? */
                  beq.s    text_cl0_x2_end
                  move.w   t_add_length(a6),d7 /* widen ? */
                  beq.s    text_cl0_x2_next
                  ext.l    d7
                  move.w   t_space_kind(a6),d3 /* character spacing ? */
                  bmi.s    text_cl0_x2_char
                  cmpi.w   #SPACE,(a2)       /* space ? */
                  bne.s    text_cl0_x2_next
                  divs.w   d3,d7
                  sub.w    d7,d2
                  sub.w    d7,t_add_length(a6)
                  subq.w   #1,t_space_kind(a6) /* one word less */
                  dbra     d6,text_cl0_x2_loop /* decrement character counter */
text_cl0_x2_char: divs.w   d6,d7
                  sub.w    d7,t_add_length(a6)
                  sub.w    d7,d2
text_cl0_x2_next: dbra     d6,text_cl0_x2_loop /* decrement character counter */

text_cl0_x2_end:  add.w    d4,d2
                  movem.w  (sp)+,d0-d1/d3-d5

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    text_cl0_width
                  add.w    t_left_off(a6),d2 /* left character margin */

text_cl0_width:   move.w   d2,d4
                  sub.w    d0,d4          /* buffer width in pixel -1 */

text_buf_width:   addi.w   #16,d4
                  lsr.w    #4,d4
                  add.w    d4,d4
                  movea.w  d4,a3          /* buffer width in bytes */
                  move.w   d5,d7
                  addq.w   #1,d7          /* buffer height in lines */

                  tst.w    t_rotation(a6) /* text rotation ? */
                  beq.s    text_buf_size
                  addi.w   #15,d7
                  andi.w   #$fff0,d7

text_buf_size:    mulu.w   d4,d7          /* needed buffer size */

                  move.l   buffer_len(a6),d4 /* buffer size */

                  btst     #T_OUTLINED_BIT,t_effects+1(a6) /* outline ? */
                  bne.s    text_buf_shrink
                  tst.w    t_rotation(a6) /* text rotation ? */
                  beq.s    text_buf_cmp
text_buf_shrink:  lsr.l    #1,d4          /* halved due to certain effects */
text_buf_cmp:     cmp.l    d4,d7          /* does everything fit into buffer ? */
                  bgt      text_partitial

                  movem.w  d0-d1,-(sp)    /* x/y onto stack */

                  move.w   t_cheight(a6),d5 /* text buffer height */
                  subq.w   #1,d5

                  bsr      fill_text_buf  /* fill textbuffer */

                  movea.l  buffer_addr(a6),a0 /* address of textbuffer */
                  movea.w  a3,a2          /* width of textbuffer in bytes */

                  move.w   t_effects(a6),d7
                  beq.s    text_output
text_bold:        btst     #T_BOLD_BIT,d7 /* bold ? */
                  beq.s    text_underlined
                  bsr      bold
text_underlined:  btst     #T_UNDERLINED_BIT,t_effects+1(a6) /* underlined ? */
                  beq.s    text_outlined
                  bsr      underline
text_outlined:    btst     #T_OUTLINED_BIT,t_effects+1(a6) /* outlined ? */
                  beq.s    text_lightend
                  bsr      outline
text_lightend:    btst     #T_LIGHT_BIT,t_effects+1(a6) /* light ? */
                  beq.s    text_output
                  bsr      light

text_output:      movem.w  (sp)+,d2-d3    /* x/y */
                  move.w   t_rotation(a6),d7 /* text rotation ? */
                  bne.s    text_rot90
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      textblt_xs0
                  sub.w    t_left_off(a6),d2
                  add.w    t_whole_off(a6),d2
text_ital180:     move.w   #$5555,d6      /* t_skew_mask(a6) */
                  moveq.l  #0,d1
                  move.w   d5,d7
text_ital_loop0:  movem.w  d1-d4/d6-d7/a2-a3,-(sp)
                  move.l   a0,-(sp)
                  moveq.l  #0,d0          /* first source column */
                  moveq.l  #0,d5          /* one line */
                  bsr      textblt
                  movea.l  (sp)+,a0
                  movem.w  (sp)+,d1-d4/d6-d7/a2-a3
                  ror.w    #1,d6
                  bcc.s    text_ital_next0
                  subq.w   #1,d2
text_ital_next0:  addq.w   #1,d1          /* next source line */
                  addq.w   #1,d3          /* next dest line */
                  dbra     d7,text_ital_loop0
                  rts

text_rot90:       subq.w   #T_ROT_90,d7   /* rotate 90 degrees ? */
                  bne.s    text_rot180
                  bsr      rotate90       /* rotate char by 90 degree */
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      textblt_xs0
                  add.w    t_left_off(a6),d3
                  sub.w    t_whole_off(a6),d3
text_ital270:     move.w   #$5555,d6      /* t_skew_mask(a6) */
                  move.w   d4,d7
text_ital_loop90: movem.w  d0/d2-d3/d5-d7/a2-a3,-(sp)
                  move.l   a0,-(sp)
                  moveq.l  #0,d1          /* first source line */
                  moveq.l  #0,d4          /* one column */
                  bsr      textblt
                  movea.l  (sp)+,a0
                  movem.w  (sp)+,d0/d2-d3/d5-d7/a2-a3
                  ror.w    #1,d6
                  bcc.s    text_ital_next90
                  addq.w   #1,d3
text_ital_next90: addq.w   #1,d0          /* next source line */
                  addq.w   #1,d2          /* next column */
                  dbra     d7,text_ital_loop90
                  rts

text_rot180:      subq.w   #T_ROT_180-T_ROT_90,d7 /* rotate 180 degrees ? */
                  bne.s    text_rot270
                  bsr      rotate180      /* rotate char by 180 degree */
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      textblt_xs0
                  add.w    t_left_off(a6),d2
                  bra      text_ital180

text_rot270:      bsr      rotate270      /* rotate char by 270 degree */
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq      textblt_xs0
                  sub.w    t_left_off(a6),d3
                  bra.s    text_ital270

/*
 * Unterstreichung erzeugen
 * Eingaben
 * d4.w Breite -1
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bufferbreite in Bytes
 * a6.l Workstation
 * Ausgaben
 * d0-d3/d6/a1/a3 werden zerstoert
 * d4.w Breite -1
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bufferbreite in Bytes
 * a6.l Workstation
 */
underline:        move.w   t_act_line(a6),d0 /* start line of section */
                  move.w   d0,d1
                  add.w    d5,d1          /* end line of section */
                  move.w   t_uline(a6),d2 /* thickness of underline */
                  move.w   t_base(a6),d3
                  addq.w   #2,d3          /* start line of underline */
                  move.w   t_cheight(a6),d7
                  subq.w   #1,d7
                  cmp.w    d7,d3
                  ble.s    underline_width
                  move.w   d7,d3
underline_width:  add.w    d3,d2          /* end line of underline */
                  cmp.w    d7,d2
                  ble.s    underline_top
                  move.w   d7,d2
underline_top:    cmp.w    d1,d3          /* too far to top ? */
                  bgt.s    underline_exit
                  cmp.w    d0,d2          /* zu too far to bottom ? */
                  blt.s    underline_exit
                  cmp.w    d1,d2
                  ble.s    underline_clip
                  move.w   d1,d2
underline_clip:   cmp.w    d0,d3
                  bge.s    underline_count
                  move.w   d0,d3
underline_count:  sub.w    d3,d2
                  bmi.s    underline_exit
                  sub.w    d0,d3
                  move.w   a2,d0          /* bytes per line */
                  mulu.w   d3,d0
                  movea.l  a0,a1
                  adda.w   d0,a1          /* start address of underline */
                  move.w   d4,d0          /* width -1 */
                  lsr.w    #4,d0          /* word counter */
                  moveq.l  #-1,d1         /* fill value */
                  moveq.l  #15,d3
                  and.w    d4,d3          /* bit position */
                  add.w    d3,d3

                  move.w   underline_mask(pc,d3.w),d3 /* mask for last word */
                  movea.w  a2,a3
                  suba.w   d0,a3
                  suba.w   d0,a3
                  subq.w   #2,a3          /* offset to next buffer line */
underline_loop1:  move.w   d0,d6          /* word counter */
underline_loop2:  move.w   d1,(a1)+
                  dbra     d6,underline_loop2
                  and.w    d3,-2(a1)      /* mask out */

                  adda.w   a3,a1          /* next line */
                  dbra     d2,underline_loop1
underline_exit:   rts

underline_mask:
                  dc.w  $8000,$C000,$E000,$F000
                  dc.w  $F800,$FC00,$FE00,$FF00
                  dc.w  $FF80,$FFC0,$FFE0,$FFF0
                  dc.w  $FFF8,$FFFC,$FFFE,$FFFF

/*
 * Fette Schrift erzeugen
 * Eingaben
 * d4.w Breite -1
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bytes pro Bufferzeile
 * a6.l Workstation
 * Ausgaben
 * d0-d3/d6-d7/a4 werden zerstoert
 * d4.w Breite -1
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bytes pro Bufferzeile
 * a6.l Workstation
 */
bold:             move.w   d5,-(sp)

                  movea.l  a0,a4          /* buffer address */
                  move.w   a2,d6          /* buffer width in bytes */
                  lsr.w    #1,d6
                  subq.w   #1,d6          /* word counter */
                  move.w   t_thicken(a6),d2 /* thickening */
                  beq.s    bold_loop      /* aequidistant font? */
                  add.w    d2,d4          /* new width */
                  subq.w   #1,d2

bold_loop:        move.w   d6,d7          /* counter inside line */
                  move.w   (a4)+,d0       /* fetch first data */
bold_fetch:       swap     d0
                  clr.w    d0
                  move.l   d0,d1
                  move.w   d2,d3          /* thickening counter */
bold_thicken:     ror.l    #1,d0
                  or.l     d0,d1
                  dbra     d3,bold_thicken
                  move.w   (a4)+,d0       /* next data */
                  or.l     d1,-4(a4)
                  dbra     d7,bold_fetch
                  move.w   d0,-(a4)       /* start of next line */
                  dbra     d5,bold_loop
                  move.w   (sp)+,d5
                  rts

/*
 * Umrandung erzeugen
 * Eingaben
 * 
 * Ausgaben
 */
outline:
                  movea.l  a0,a1
                  move.l   buffer_len(a6),d0
                  lsr.l    #1,d0
                  adda.l   d0,a1

                  move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  move.w   a2,d2
                  lsr.w    #1,d2
                  subq.w   #1,d2          /* counter */
                  moveq.l  #16,d0
                  addq.w   #2,d4

                  add.w    d4,d0
                  lsr.w    #4,d0
                  add.w    d0,d0
                  movea.w  d0,a2          /* new line width */
                  movea.w  d0,a3
                  adda.w   d0,a3          /* double line width */
                  move.w   d5,d1
                  addq.w   #3,d1
                  mulu.w   d1,d0
                  lsr.w    #2,d0          /* longword counter */
                  moveq.l  #0,d1          /* fill value */
                  movea.l  a1,a4          /* dest buffer address */

outlined_clear:   move.l   d1,(a4)+
                  dbra     d0,outlined_clear

                  move.w   d5,d6          /* line counter */
outlined_loop1:   move.w   d2,d3
                  movea.l  a1,a4

outlined_loop2:   moveq.l  #0,d0
                  move.w   (a0)+,d0       /* source word */
                  swap     d0
                  move.l   d0,d1
                  ror.l    #1,d1
                  or.l     d1,d0
                  ror.l    #1,d1
                  or.l     d1,d0
                  or.l     d0,(a4)
                  or.l     d0,0(a4,a2.w)
                  or.l     d0,0(a4,a3.w)

                  addq.l   #2,a4
                  dbra     d3,outlined_loop2
                  adda.w   a2,a1          /* next dest line */
                  dbra     d6,outlined_loop1
                  movea.l  (sp),a1
                  movea.l  4(sp),a0

                  move.w   d5,d6          /* line counter */
                  adda.w   a2,a1
outlined_loop3:   move.w   d2,d3
                  movea.l  a1,a4

outlined_loop4:   moveq.l  #0,d0
                  move.w   (a0)+,d0
                  swap     d0
                  ror.l    #1,d0
                  eor.l    d0,(a4)
                  addq.l   #2,a4
                  dbra     d3,outlined_loop4
                  adda.w   a2,a1
                  dbra     d6,outlined_loop3

                  movea.l  (sp)+,a0
                  movea.l  (sp)+,a1
                  addq.w   #2,d5
                  rts

/*
 * Helle Schrift erzeugen
 * Eingaben
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bytes pro Bufferzeile
 * a6.l Workstationpointer
 * Ausgaben
 * d0-d2/d6-d7/a3 werden zerstoert
 */
light:            move.w   #$5555,d0      /* mask for light font (t_light_mask) */
                  moveq.l  #15,d6
                  and.w    t_act_line(a6),d6 /* relative output line */
                  ror.w    d6,d0          /* shift mask accordingly */
                  movea.l  a0,a3          /* buffer address */
                  move.w   a2,d1          /* bytes per line */
                  lsr.w    #1,d1          /* counter */
                  subq.w   #1,d1
                  move.w   d5,d7          /* line counter */

                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  bne.s    light_italics
light_loop1:      move.w   d1,d6
light_loop2:      and.w    d0,(a3)+
                  dbra     d6,light_loop2
                  ror.w    #1,d0
                  dbra     d7,light_loop1
                  rts
light_italics:    move.w   #$5555,d2      /* t_skew_mask(a6) shift mask for italics */
                  ror.w    d6,d2          /* mask according to relativ line */
light_i_loop1:    move.w   d1,d6          /* word counter */
light_i_loop2:    and.w    d0,(a3)+
                  dbra     d6,light_i_loop2
                  ror.w    #1,d0          /* rotate lighting mask */
                  ror.w    #1,d2          /* rotate italics mask */
                  bcc.s    light_i_next   /* italics ? */
                  ror.w    #1,d0
light_i_next:     dbra     d7,light_i_loop1
                  rts

/* rotate char by 90 degree */
rotate90:
                  movea.l  a0,a1
                  move.l   buffer_len(a6),d0
                  lsr.l    #1,d0
                  adda.l   d0,a1
                  cmpa.l   buffer_addr(a6),a0
                  beq.s    rotate90_save
                  movea.l  buffer_addr(a6),a1

rotate90_save:    move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  movem.w  d2-d3/d5,-(sp)

                  moveq.l  #16,d6         /* preset */

                  move.w   d5,d0          /* height  */
                  add.w    d6,d0
                  andi.w   #$fff0,d0
                  move.w   d0,d7
                  add.w    d7,d7          /* bytes per 16 lines */
                  lsr.w    #3,d0
                  movea.w  d0,a3          /* bytes per line */

                  movea.l  a1,a4          /* pointer to first buffer line */
                  mulu.w   d4,d0
                  adda.w   d0,a1          /* pointer to last buffer line */
                  add.w    a3,d0
                  lsr.w    #4,d0          /* counter */
                  moveq.l  #0,d1          /* fill value */
rotate90_clear:   move.l   d1,(a4)+       /* clear buffer */
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  dbra     d0,rotate90_clear

                  move.w   #$8000,d2      /* dot pattern */

rotate90_bloop:   move.w   d4,d3          /* pixel counter */
                  movea.l  a0,a4
                  movea.l  a1,a5
                  adda.w   a2,a0
                  bra.s    rotate90_read
rotate90_loop:    dbra     d1,rotate90_test
rotate90_read:    moveq.l  #15,d1         /* bit counter */
                  move.w   (a4)+,d0       /* read source word */
                  bne.s    rotate90_test  /* white ? */
                  sub.w    d6,d3          /* 16 Pixel less */
                  bmi.s    rotate90_shift
                  move.w   (a4)+,d0       /* next source word */
                  suba.w   d7,a5          /* 16 lines further */
rotate90_test:    add.w    d0,d0          /* bit set ? */
                  bcc.s    rotate90_white
                  or.w     d2,(a5)        /* set bit */
rotate90_white:   suba.w   a3,a5          /* next dest line */
                  dbra     d3,rotate90_loop
rotate90_shift:   ror.w    #1,d2          /* next dot mask */
                  bcc.s    rotate90_next
                  addq.l   #2,a1          /* next dest word */
rotate90_next:    dbra     d5,rotate90_bloop
                  movem.w  (sp)+,d2-d3/d5
                  movea.l  (sp)+,a0       /* new source address */
                  movea.l  (sp)+,a1       /* new dest address */
                  exg      d4,d5          /* swap width and height */
                  movea.w  a3,a2          /* new line width */
                  rts

/* rotate char by 180 degree */
rotate180:
                  movea.l  a0,a1
                  move.l   buffer_len(a6),d0
                  lsr.l    #1,d0
                  adda.l   d0,a1
                  cmpa.l   buffer_addr(a6),a0
                  beq.s    rotate180_save
                  movea.l  buffer_addr(a6),a1

rotate180_save:
                  move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  movem.w  d2-d3/d5,-(sp)

                  moveq.l  #16,d6         /* preset */
                  movea.l  a1,a4          /* pointer to first buffer line */
                  move.w   a2,d0
                  mulu.w   d5,d0
                  add.w    a2,d0
                  adda.w   d0,a1          /* pointer behind last buffer line */
                  lsr.w    #4,d0          /* counter */
                  moveq.l  #0,d1          /* fill value */
rotate180_clear:  move.l   d1,(a4)+       /* clear buffer */
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  dbra     d0,rotate180_clear

                  moveq.l  #15,d0
                  and.w    d4,d0
                  move.w   #$8000,d2
                  lsr.w    d0,d2          /* dot mask */
                  movea.w  d2,a4

rotate180_bloop:  move.w   a4,d2          /* dot mask */
                  move.w   d4,d3          /* counter */
                  moveq.l  #0,d7
                  bra.s    rotate180_read
rotate180_loop:   dbra     d1,rotate180_test
rotate180_read:   moveq.l  #15,d1         /* bit counter */
                  move.w   (a0)+,d0       /* source word */
                  bne.s    rotate180_test /* white ? */
                  move.w   d7,-(a1)       /* next dest word */
                  sub.w    d6,d3          /* 16 pixel further */
                  bmi.s    rotate180_next
                  move.w   (a0)+,d0       /* next source word */
                  moveq.l  #0,d7
rotate180_test:   add.w    d0,d0          /* bit set ? */
                  bcc.s    rotate180_white
                  or.w     d2,d7          /* set bit */
rotate180_white:  add.w    d2,d2          /* shift dot mask */
                  bcc.s    rotate180_dbra
                  moveq.l  #1,d2          /* dot mask */
                  move.w   d7,-(a1)       /* next dest word */
                  moveq.l  #0,d7

rotate180_dbra:   dbra     d3,rotate180_loop
rotate180_next:   dbra     d5,rotate180_bloop

                  movem.w  (sp)+,d2-d3/d5
                  movea.l  (sp)+,a0       /* new source address */
                  movea.l  (sp)+,a1       /* new dest address */
                  rts

/* rotate char by 270 degree */
rotate270:
                  movea.l  a0,a1
                  move.l   buffer_len(a6),d0
                  lsr.l    #1,d0
                  adda.l   d0,a1

                  cmpa.l   buffer_addr(a6),a0
                  beq.s    rotate270_save
                  movea.l  buffer_addr(a6),a1

rotate270_save:   move.l   a0,-(sp)
                  move.l   a1,-(sp)

                  movem.w  d2-d3/d5,-(sp)

                  moveq.l  #16,d6

                  move.w   d5,d0          /* height */
                  add.w    d6,d0
                  andi.w   #$fff0,d0
                  move.w   d0,d7
                  add.w    d7,d7          /* bytes per 16 lines */
                  lsr.w    #3,d0
                  movea.w  d0,a3          /* bytes per buffer line */

                  movea.l  a1,a4          /* pointer to first buffer line */
                  mulu.w   d4,d0
                  add.w    a3,d0
                  lsr.w    #4,d0          /* counter */
                  moveq.l  #0,d1          /* fill value */
rotate270_clear:  move.l   d1,(a4)+       /* clear buffer */
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  move.l   d1,(a4)+
                  dbra     d0,rotate270_clear

                  move.w   #$8000,d2      /* dot mask */
                  move.w   a2,d0
                  mulu.w   d5,d0
                  adda.w   d0,a0          /* pointer to first source line */

rotate270_bloop:  move.w   d4,d3          /* counter */
                  movea.l  a0,a4
                  movea.l  a1,a5
                  bra.s    rotate270_read
rotate270_loop:   dbra     d1,rotate270_test
rotate270_read:   moveq.l  #15,d1         /* bit counter */
                  move.w   (a4)+,d0       /* read source word */
                  bne.s    rotate270_test
                  sub.w    d6,d3          /* 16 Pixel further */
                  bmi.s    rotate270_shift
                  move.w   (a4)+,d0       /* new source word */
                  adda.w   d7,a5          /* 16 lines further */
rotate270_test:   add.w    d0,d0          /* bit set ? */
                  bcc.s    rotate270_white
                  or.w     d2,(a5)        /* set bit */
rotate270_white:  adda.w   a3,a5          /* next dest line */
                  dbra     d3,rotate270_loop
rotate270_shift:  suba.w   a2,a0          /* next source line */
                  ror.w    #1,d2          /* next dot mask */
                  bcc.s    rotate270_next
                  addq.l   #2,a1          /* next dest word */

rotate270_next:   dbra     d5,rotate270_bloop

                  movem.w  (sp)+,d2-d3/d5
                  movea.l  (sp)+,a0       /* new source address */
                  movea.l  (sp)+,a1       /* new dest address */
                  exg      d4,d5          /* swap width and height */
                  movea.w  a3,a2          /* new line width */
                  rts

/*
 * Textausgabe mit Clipping ab Bufferstart
 * Eingaben
 * d0.w x-Quelle (xs1)
 * d1.w y-Quelle (ys1)
 * d2.w x-Ziel (xd1)
 * d3.w y-Ziel (yd1)
 * d4.w Breite -1
 * d5.w Hoehe -1
 * a0.l Bufferadresse
 * a2.w Bytes pro Bufferzeile
 * a6.l Workstation
 * Ausgaben
 * d0-a5 werden zerstoert
 */
textblt_xs0:      moveq.l  #0,d0
textblt_ys0:      moveq.l  #0,d1          /* y-Quellkoordinate = 0 */
textblt:          move.w   d5,d7
                  add.w    d2,d4          /* xd2 */
                  add.w    d3,d5          /* yd2 */

                  lea.l    clip_xmin(a6),a1
                  cmp.w    (a1)+,d2       /* xd1 zu klein ? */
                  bge.s    textblt_clipy1
                  sub.w    d2,d0
                  move.w   -2(a1),d2      /* xd1 = clip_xmin */
                  add.w    d2,d0          /* xs1 = xs1 - xd1 + clip_xmin */
textblt_clipy1:   cmp.w    (a1)+,d3       /* yd1 zu klein ? */
                  bge.s    textblt_clipx2
                  sub.w    d3,d1
                  move.w   -2(a1),d3      /* yd1 = clip_ymin */
                  add.w    d3,d1          /* ys1 = ys1 - yd1 + clip_ymin */
textblt_clipx2:   cmp.w    (a1)+,d4       /* xd2 zu gross ? */
                  ble.s    textblt_clipy2
                  move.w   -2(a1),d4      /* xd2 = clip_xmax */
textblt_clipy2:   cmp.w    (a1),d5        /* yd2 zu gross ? */
                  ble.s    textblt_cmp
                  move.w   (a1),d5        /* yd2 = clip_ymax */
textblt_cmp:      sub.w    d2,d4
                  bmi.s    textblt_exit
                  sub.w    d3,d5
                  bmi.s    textblt_exit

                  movea.l  p_textblt(a6),a4
                  jmp      (a4)

textblt_exit:     rts

/*
 * Textbuffer fuellen
 * Eingaben
 * d5.w Zeichenhoehe - 1
 * a3.w Bufferbreite in Bytes
 * a5.l intin
 * Ausgaben
 * d0-d3/d6/d7/a0-a2/a4-a5 werden zerstoert
 * d4.w Bufferbreite -1
 * d5.w Bufferhoehe -1
 * a3.w Bytes pro Bufferzeile
 */
fill_text_buf:    movea.w  t_iwidth(a6),a2 /* width of the font images */
                  movea.l  t_offtab(a6),a4 /* character offset table */

ftb_eff:          move.w   a3,d0          /* buffer width in bytes */
                  mulu.w   d5,d0          /* * buffer height */
                  add.w    a3,d0          /* size of buffer in bytes */
                  lsr.w    #4,d0          /* 16-byte counter */
                  moveq.l  #0,d1          /* fill value */
                  movea.l  buffer_addr(a6),a1
ftb_clear:        move.l   d1,(a1)+
                  move.l   d1,(a1)+
                  move.l   d1,(a1)+
                  move.l   d1,(a1)+
                  dbra     d0,ftb_clear

                  movea.l  buffer_addr(a6),a1 /* buffer address */

                  moveq.l  #0,d2          /* start position */
                  moveq.l  #15,d7         /* mask value */
                  move.w   t_eff_thicken(a6),d3 /* widening from effects */
                  addq.w   #1,d3          /* + offset to next character */

                  tst.b    t_grow(a6)     /* enlarge ? */
                  bne      ftb_grow_loop

ftb_loop:         move.w   (a5)+,d0       /* character index */
                  sub.w    t_first_ade(a6),d0
                  cmp.w    t_ades(a6),d0  /* character present ? */
                  bls.s    ftb_position
                  move.w   t_unknown_index(a6),d0
ftb_position:     add.w    d0,d0
                  movem.w  0(a4,d0.w),d0/d4
                  sub.w    d0,d4
                  subq.w   #1,d4          /* character width in pixel - 1 */
                  bmi.s    ftb_next
                  movea.l  t_image(a6),a0
                  move.w   d0,d1          /* source coordinate */
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a0          /* source address */
                  and.w    d7,d0          /* source shifts */

                  movem.w  d3/d5-d6/a2-a3,-(sp)
                  add.w    d2,d3
                  add.w    d4,d3
                  move.w   d3,-(sp)
                  move.l   a1,-(sp)
                  bsr.s    copy_to_buf    /* copy characters to buffer */
                  movea.l  (sp)+,a1
                  movem.w  (sp)+,d2-d3/d5-d6/a2-a3

                  tst.w    t_add_length(a6) /* text stretching ? */
                  beq.s    ftb_no_offset

                  bsr.s    text_offset    /* return offset in d4 */

ftb_no_offset:    cmp.w    d7,d2          /* more than 15 shifts ? */
                  ble.s    ftb_next
                  move.w   d2,d4
                  lsr.w    #4,d4
                  add.w    d4,d4
                  adda.w   d4,a1          /* increment dest address */
                  and.w    d7,d2          /* new shift count */

ftb_next:         dbra     d6,ftb_loop    /* copy next character */
                  move.l   a1,d4
                  sub.l    buffer_addr(a6),d4
                  lsl.w    #3,d4
                  add.w    d2,d4
                  sub.w    d3,d4          /* width in pixel */
                  rts

/*
 * Offset fuers naechste Zeichen berechnen
 * Eingaben
 * d6.w Anzahl der verbleibenden Zeichen
 * a1.l Zieladresse
 * a5.l Zeiger auf das naechste Zeichen
 * a6.l Zeiger auf die Workstation
 * Ausgaben
 * d0/d4 werden zerstoert
 * d2.w Zielschifts
 * a1.l Zieladresse
 */
text_offset:      move.w   d6,d0          /* remaining character count */
                  beq.s    text_offset_exit
                  move.w   t_space_kind(a6),d4 /* word spacing ? */
                  bmi.s    text_offset_calc
                  cmpi.w   #SPACE,-2(a5)     /* space ? */
                  bne.s    text_offset_exit
                  subq.w   #1,t_space_kind(a6) /* decrement word count */
                  move.w   d4,d0          /* remaining word count */
text_offset_calc: move.w   t_add_length(a6),d4
                  ext.l    d4
                  divs.w   d0,d4
                  sub.w    d4,t_add_length(a6)
                  add.w    d4,d2          /* new position */
                  bpl.s    text_offset_exit
                  move.w   d2,d4
                  neg.w    d4
                  lsr.w    #4,d4
                  addq.w   #1,d4
                  add.w    d4,d4
                  suba.w   d4,a1
                  and.w    d7,d2          /* mask out */
                  cmpa.l   buffer_addr(a6),a1
                  bpl.s    text_offset_exit
                  movea.l  buffer_addr(a6),a1
                  moveq.l  #0,d2
text_offset_exit: rts

/*
 * Bereich kopieren
 * Eingaben
 * d0.w Shiftanzahl der Quelldaten
 * d2.w Shiftanzahl der Zieldaten
 * d4.w Breite - 1
 * d5.w Hoehe - 1
 * d7.w 15 (zum ausmaskieren)
 * a0.l Quelladresse
 * a1.l Zieladresse
 * a2.w Bytes pro Quellzeile
 * a3.w Bytes pro Zielzeile
 * Ausgaben
 * d3-d6/a0-a3 werden zerstoert (?)
 */
copy_to_buf:      cmp.w    #7,d4          /* byte width ? */
                  bne.s    cptb_no_byte
                  tst.w    d0
                  beq      cptb_byte
                  cmp.w    #8,d0
                  beq      cptb_byte8

cptb_no_byte:     sub.w    d2,d0          /* shifts */

                  move.w   d2,d1          /* counter */
                  add.w    d4,d1
                  lsr.w    #4,d1          /* /16 */

                  add.w    d2,d4
                  not.w    d4
                  and.w    d7,d4
                  moveq.l  #-1,d3
                  lsr.w    d2,d3          /* start mask */
                  moveq.l  #-1,d2
                  lsl.w    d4,d2          /* end mask */

                  subq.w   #1,d1
                  bmi      cptb_1word
                  beq      cptb_1long

                  move.w   d1,d4
                  addq.w   #1,d4
                  add.w    d4,d4
                  suba.w   d4,a2
                  suba.w   d4,a3

                  subq.w   #1,d1

                  tst.w    d0
                  beq.s    cptb_multiple
                  blt.s    cptbm_r
                  cmpi.w   #8,d0
                  ble.s    cptb_multiple_l
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_multiple_r
cptbm_r:          neg.w    d0
                  subq.l   #2,a0
                  cmpi.w   #8,d0
                  ble.s    cptb_multiple_r
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_multiple_l

cptb_multiple:    move.w   d1,d4
                  move.w   (a0)+,d6       /* buffer */

                  and.w    d3,d6
                  or.w     d6,(a1)+
cptbm_loop:       move.w   (a0)+,(a1)+
                  dbra     d4,cptbm_loop
                  move.w   (a0),d6        /* buffer */

                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_multiple
                  rts

cptb_multiple_r:  move.w   d1,d4
                  move.l   (a0),d6        /* buffer */
                  addq.l   #2,a0
                  ror.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)+
cptbm_loop_r:     move.l   (a0),d6        /* buffer */
                  addq.l   #2,a0
                  ror.l    d0,d6
                  move.w   d6,(a1)+
                  dbra     d4,cptbm_loop_r
                  move.l   (a0),d6        /* buffer */
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_multiple_r
                  rts

cptb_multiple_l:  move.w   d1,d4
                  move.l   (a0),d6        /* buffer */
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  and.w    d3,d6
                  or.w     d6,(a1)+
cptbm_loop_l:     move.l   (a0),d6        /* buffer */
                  addq.l   #2,a0
                  swap     d6
                  rol.l    d0,d6
                  move.w   d6,(a1)+
                  dbra     d4,cptbm_loop_l
                  move.l   (a0),d6        /* buffer */
                  swap     d6
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_multiple_l
                  rts

cptb_1word:       and.w    d3,d2
                  move.w   d2,d3
                  not.w    d3

                  tst.w    d0
                  beq.s    cptb_word
                  blt.s    cptb_wr

                  cmpi.w   #8,d0
                  ble.s    cptb_word_l
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_word_r

cptb_wr:          neg.w    d0
                  subq.l   #2,a0
                  cmpi.w   #8,d0
                  ble.s    cptb_word_r
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_word_l

cptb_word:        move.w   (a0),d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_word
                  rts
cptb_word_r:      move.l   (a0),d6
                  ror.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_word_r
                  rts
cptb_word_l:      move.l   (a0),d6
                  swap     d6
                  rol.l    d0,d6
                  and.w    d2,d6
                  or.w     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_word_l
                  rts

cptb_1long:       swap     d3
                  move.w   d2,d3
                  move.l   d3,d2
                  not.l    d3

                  tst.w    d0
                  beq.s    cptb_long
                  blt.s    cptb_lr

                  cmpi.w   #8,d0
                  ble.s    cptb_long_l
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_long_r

cptb_lr:          neg.w    d0
                  subq.l   #2,a0
                  cmpi.w   #8,d0
                  ble.s    cptb_long_r
                  subq.w   #1,d0
                  eor.w    d7,d0
                  bra.s    cptb_long_l

cptb_long:        move.l   (a0),d6
                  and.l    d2,d6
                  or.l     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_long
                  rts
cptb_long_r:      move.l   (a0),d6
                  ror.l    d0,d6
                  swap     d6
                  move.l   2(a0),d4
                  ror.l    d0,d4
                  move.w   d4,d6
                  and.l    d2,d6
                  or.l     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_long_r
                  rts
cptb_long_l:      move.l   (a0),d6
                  rol.l    d0,d6
                  move.l   2(a0),d4
                  swap     d4
                  rol.l    d0,d4
                  move.w   d4,d6
                  and.l    d2,d6
                  or.l     d6,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_long_l
                  rts

cptb_byte8:       addq.l   #1,a0
cptb_byte:        not.w    d2
                  and.w    d7,d2
                  addq.w   #1,d2
cptb_byte_loop:   moveq.l  #0,d0
                  movep.w  0(a0),d0
                  clr.b    d0
                  lsl.l    d2,d0
                  or.l     d0,(a1)
                  adda.w   a2,a0
                  adda.w   a3,a1
                  dbra     d5,cptb_byte_loop
                  rts

ftb_grow_loop:    move.w   (a5)+,d0
                  sub.w    t_first_ade(a6),d0
                  cmp.w    t_ades(a6),d0  /* character present ? */
                  bls.s    ftb_grow_position
                  move.w   t_unknown_index(a6),d0
ftb_grow_position:add.w    d0,d0
                  movem.w  0(a4,d0.w),d0/d4
                  sub.w    d0,d4
                  subq.w   #1,d4          /* character width in pixel - 1 */
                  bmi.s    ftb_grow_next
                  movea.l  t_image(a6),a0
                  move.w   d0,d1          /* x-source */
                  lsr.w    #4,d1
                  add.w    d1,d1
                  adda.w   d1,a0          /* source address */
                  and.w    d7,d0          /* source shifts */

                  movem.w  d2-d3/d5-d6/a2-a3,-(sp)
                  movem.l  a1/a4-a6,-(sp)
                  pea.l    ftb_return(pc)
                  tst.b    t_grow(a6)     /* need to enlarge ? */
                  bmi      grow_char
                  bra      shrink_char
ftb_return:       movem.l  (sp)+,a1/a4-a6
                  movem.w  (sp)+,d2-d3/d5-d6/a2-a3
                  add.w    d3,d2
                  add.w    d4,d2

                  tst.w    t_add_length(a6)
                  beq.s    ftbg_no_offset

                  bsr      text_offset    /* return offset in d4 */

ftbg_no_offset:   cmp.w    d7,d2          /* more than 15 shifts ? */
                  ble.s    ftb_grow_next
                  move.w   d2,d4
                  lsr.w    #4,d4
                  add.w    d4,d4
                  adda.w   d4,a1          /* increment des address */
                  and.w    d7,d2          /* new shift count */

ftb_grow_next:    dbra     d6,ftb_grow_loop /* copy next character */
                  move.l   a1,d4
                  sub.l    buffer_addr(a6),d4
                  lsl.w    #3,d4
                  add.w    d2,d4
                  sub.w    d3,d4          /* width */
                  rts

/* double size of byte-width characters without shifts */
grow_byte2:       addq.l   #1,a0
grow_byte:        moveq.l  #15,d4         /* new width */
grow_byte_bloop:  moveq.l  #0,d1
                  move.b   (a0),d0        /* read source word */
                  adda.w   a2,a0          /* next source line */
                  beq.s    grow_byte_out
                  moveq.l  #7,d3          /* bit counter */
grow_byte_loop:   add.w    d1,d1          /* make room */
                  add.w    d1,d1
                  add.b    d0,d0          /* bit set ? */
                  bcc.s    grow_byte_next
                  addq.w   #3,d1          /* set 2 bits */
grow_byte_next:   dbra     d3,grow_byte_loop
                  move.w   d1,(a1)        /* output dest word */
                  adda.w   a3,a1          /* next dest line */
                  move.w   d1,(a1)
                  adda.w   a3,a1
                  dbra     d5,grow_byte_bloop
                  rts
grow_byte_out:    adda.w   a3,a1
                  adda.w   a3,a1
                  dbra     d5,grow_byte_bloop
                  rts

/* double size of characters */
grow_char2:       lsr.w    #1,d5
                  cmp.w    #7,d4
                  bne.s    grow_char_db
                  tst.w    d2
                  bne.s    grow_char_db
                  tst.w    d0             /* no source shift ? */
                  beq.s    grow_byte
                  cmp.w    #8,d0          /* 8 source shifts ? */
                  beq.s    grow_byte2
grow_char_db:     move.w   d2,d3          /* number of dest shifts */
                  move.w   d0,d2          /* number of source shifts */
                  eor.w    d7,d2
                  subq.w   #7,d2
                  bgt.s    grow_db_lloop
                  addq.l   #1,a0
                  addq.w   #8,d2
grow_db_lloop:    movea.l  a0,a4          /* source address */
                  movea.l  a1,a5          /* dest address */
                  move.w   d4,d7
grow_db_bloop:    moveq.l  #7,d6
                  cmp.w    d6,d7
                  bge.s    grow_db_read
                  move.w   d7,d6
grow_db_read:     subq.w   #8,d7
                  moveq.l  #0,d1          /* source word */
                  movep.w  0(a4),d0
                  addq.l   #1,a4
                  move.b   (a4),d0
                  lsr.w    d2,d0
grow_db_loop:     add.w    d1,d1          /* make room */
                  add.w    d1,d1
                  add.b    d0,d0
                  bcc.s    grow_db_white
                  addq.w   #3,d1          /* set 2 bits */
grow_db_white:    dbra     d6,grow_db_loop

                  tst.w    d7
                  bpl.s    grow_db_out
                  move.w   d7,d6
                  addq.w   #1,d6
                  neg.w    d6
                  add.w    d6,d6
                  lsl.w    d6,d1
grow_db_out:      ror.l    d3,d1
                  swap     d1
                  or.l     d1,(a5)
                  or.l     d1,0(a5,a3.w)
                  addq.l   #2,a5
                  tst.w    d7
                  bpl.s    grow_db_bloop
                  adda.w   a2,a0
                  adda.w   a3,a1
                  adda.w   a3,a1
                  dbra     d5,grow_db_lloop
                  add.w    d4,d4
                  addq.w   #1,d4
                  moveq.l  #15,d7
                  rts

/*
 * Zeichenvergroesserung
 * Eingaben
 * d0 Shiftanzahl der Quelldaten
 * d2 Shiftanzahl der Zieldaten
 * d4 Breite - 1
 * d5 vergroesserte Hoehe - 1
 * d7 15 (zum ausmaskieren)
 * a0 Quelladresse
 * a1 Zieladresse
 * a2 Bytes pro Quellzeile
 * a3 Bytes pro Zielzeile
 * a6 Workstation
 * Ausgabe
 * d4 vergroesserte Breite - 1
 * d0-d3/d5-d6/a0-a6 werden zerstoert
 */
grow_char:        move.w   t_iheight(a6),d1
                  add.w    d1,d1
                  move.w   t_cheight(a6),d6
                  cmp.w    d6,d1          /* double size ? */
                  beq      grow_char2
                  move.w   d5,-(sp)
                  swap     d2
                  move.w   d0,d2

                  move.w   t_iheight(a6),d5
                  addq.w   #1,d4
                  mulu.w   d6,d4
                  divu.w   d5,d4
                  subq.w   #1,d4          /* enlarged width in pixel */

                  moveq.l  #16,d1
                  add.w    d4,d1
                  swap     d2
                  add.w    d2,d1
                  swap     d2
                  lsr.w    #4,d1
                  subq.w   #1,d1          /* word counter for copying */
                  swap     d1
                  moveq.l  #-1,d7
                  swap     d2
                  lsr.w    d2,d7
                  swap     d2
                  move.w   d7,d1          /* mask for copying */

                  movea.w  d5,a4          /* xs=dy */
                  sub.w    d6,d5
                  movea.w  d5,a5          /* ys=dy-dx */
                  move.w   d5,d3          /* e=dy-dx */
                  swap     d3
                  move.w   d5,d3          /* e=dy-dx */
                  move.w   (sp)+,d5       /* height in lines */
pte_grow_loop:    bsr.s    grow_line
                  adda.w   a2,a0

                  swap     d3
                  tst.w    d3
                  bmi.s    grow_height
pte_grow_next:    add.w    a5,d3          /* +ys */
                  swap     d3
                  adda.w   a3,a1
                  dbra     d5,pte_grow_loop
                  bra.s    pte_grow_exit
grow_loop2:       tst.w    d3
                  bpl.s    pte_grow_next
grow_height:      move.l   d1,d7
                  swap     d7             /* word counter */
                  movea.l  a1,a6
                  adda.w   a3,a6          /* address of next dest line */
                  move.l   a6,-(sp)
                  move.w   (a1)+,d6
                  and.w    d1,d6          /* mask */
                  or.w     d6,(a6)+
                  bra.s    grow_next3
grow_loop3:       move.w   (a1)+,(a6)+
grow_next3:       dbra     d7,grow_loop3
                  movea.l  (sp)+,a1
                  add.w    a4,d3          /* +xs */
                  dbra     d5,grow_loop2
pte_grow_exit:    moveq.l  #15,d7
                  rts

grow_line:        move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  move.l   d1,-(sp)
                  move.w   d3,-(sp)
                  move.w   d4,-(sp)
                  move.w   #$8000,d6
                  moveq.l  #0,d7
                  bra.s    grow_read
grow_next:        add.w    a5,d3          /* +ys */
                  ror.w    #1,d6
                  dbcs     d4,grow_loop
                  swap     d2
                  ror.l    d2,d7
                  swap     d2
                  swap     d7
                  or.l     d7,(a1)
                  addq.l   #2,a1
                  moveq.l  #0,d7

                  subq.w   #1,d4
                  bmi.s    grow_exit
grow_loop:        dbra     d0,grow_test
grow_read:        moveq.l  #15,d0
                  move.l   (a0),d1

                  addq.l   #2,a0
                  lsl.l    d2,d1
                  swap     d1
grow_test:        btst     d0,d1
                  beq.s    grow_white
                  or.w     d6,d7
grow_white:       tst.w    d3
                  bpl.s    grow_next
                  add.w    a4,d3          /* +xs */
                  ror.w    #1,d6
                  dbcs     d4,grow_test
                  swap     d2
                  ror.l    d2,d7
                  swap     d2
                  swap     d7
                  or.l     d7,(a1)
                  addq.l   #2,a1
                  moveq.l  #0,d7
                  subq.w   #1,d4
                  bpl.s    grow_test
grow_exit:        move.w   (sp)+,d4
                  move.w   (sp)+,d3
                  move.l   (sp)+,d1
                  movea.l  (sp)+,a1
                  movea.l  (sp)+,a0
                  rts

/*
 * Zeichenverkleinerung
 * Eingaben
 * d0 Shiftanzahl der Quelldaten
 * d2 Shiftanzahl der Zieldaten
 * d4 Breite - 1
 * d5 verkleinerte Hoehe - 1
 * d7 15 (zum ausmaskieren)
 * a0 Quelladresse
 * a1 Zieladresse
 * a2 Bytes pro Quellzeile
 * a3 Bytes pro Zielzeile
 * a6 Workstation
 * Ausgabe
 * d4 verkleinerte Breite - 1
 * d0-d3/d5-d6/a0-a6 werden zerstoert
 */
shrink_char:      addq.w   #1,d5          /* buffer height in pixel */
                  move.w   t_cheight(a6),d7
                  mulu.w   t_iheight(a6),d5
                  divu.w   d7,d5
                  subq.w   #1,d5
                  move.w   d5,-(sp)
                  swap     d2
                  move.w   d0,d2

                  move.w   t_iheight(a6),d5
                  addq.w   #1,d4
                  mulu.w   d7,d4
                  divu.w   d5,d4
                  subq.w   #1,d4          /* width in pixel */
                  bpl.s    shrink_plus2
                  move.w   (sp)+,d5
                  bra.s    shrink_char_exit
shrink_plus2:     movea.w  d7,a4          /* xs=dx */
                  sub.w    d5,d7
                  movea.w  d7,a5          /* ys=dx-dy */
                  move.w   d7,d3          /* e=dx-dy */
                  swap     d3

                  move.w   d7,d3          /* e=dx-dy */
                  move.w   (sp)+,d5       /* line counter for source image */
shrink_char_loop: bsr.s    shrink_line
                  adda.w   a2,a0
                  adda.w   a3,a1
                  swap     d3
                  tst.w    d3
                  bpl.s    shrink_height
                  add.w    a4,d3          /* +xs */
                  suba.w   a3,a1
                  swap     d3
                  dbra     d5,shrink_char_loop
                  bra.s    shrink_char_exit
shrink_height:    add.w    a5,d3          /* +ys */
                  swap     d3
                  dbra     d5,shrink_char_loop
shrink_char_exit: moveq.l  #15,d7
                  rts

shrink_line:      move.l   a0,-(sp)
                  move.l   a1,-(sp)
                  move.w   d1,-(sp)
                  move.w   d3,-(sp)
                  move.w   d4,-(sp)
                  move.w   #$8000,d6
                  moveq.l  #0,d7
                  bra.s    shrink_read
shrink_next:      add.w    a5,d3          /* +ys */
                  ror.w    #1,d6
                  dbcs     d4,shrink_loop
                  swap     d2
                  ror.l    d2,d7
                  swap     d2
                  swap     d7
                  or.l     d7,(a1)
                  addq.l   #2,a1
                  moveq.l  #0,d7
                  subq.w   #1,d4
                  bmi.s    shrink_exit

shrink_loop:      dbra     d0,shrink_test
shrink_read:      moveq.l  #15,d0
                  move.l   (a0),d1
                  addq.l   #2,a0
                  lsl.l    d2,d1
                  swap     d1
shrink_test:      btst     d0,d1
                  beq.s    shrink_white
                  or.w     d6,d7
shrink_white:     tst.w    d3
                  bpl.s    shrink_next
                  add.w    a4,d3          /* +xs */
                  bra.s    shrink_loop
shrink_exit:      move.w   (sp)+,d4
                  move.w   (sp)+,d3
                  move.w   (sp)+,d1
                  movea.l  (sp)+,a1
                  movea.l  (sp)+,a0
                  rts

                  
/* ********************************************************************** */
                  /* 'gestreckte Textausgabe' */

/*
 * Einsprung von v_justified
 * Eingaben
 * a1.l contrl
 * a2.l &intin[2]
 * a3.l ptsin
 * a6.l Zeiger auf die Workstation
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
text_justified:   move.w   n_intin(a1),d6 /* character count */
                  subq.w   #3,d6
                  cmp.w    #32764,d6      /* enough characters? */
                  bhi      text_exit

                  clr.w    t_act_line(a6) /* character line 0 */
                  move.w   -2(a2),d3      /* char_space */
                  sne      d3
                  ext.w    d3             /* -1 => character spacing */

                  move.w   d3,t_space_kind(a6) /* 0 => word spacing */

                  moveq.l  #0,d5
                  move.w   t_effects(a6),d0
                  btst     #T_BOLD_BIT,d0 /* bold? */
                  beq.s    textj_outlined
                  move.w   t_thicken(a6),d5 /* widening from bold */
textj_outlined:   btst     #T_OUTLINED_BIT,d0 /* outlined? */
                  beq.s    textj_thicken
                  addq.w   #2,d5          /* enlargement from outline */
textj_thicken:    move.w   d5,t_eff_thicken(a6) /* widening from effects */

                  movem.w  t_first_ade(a6),d0-d1 /* t_first_ade/t_ades */
                  moveq.l  #-1,d4         /* preset total width */
                  move.w   d6,d7          /* character counter */
                  movea.l  t_fonthdr(a6),a0
                  move.l   dat_table(a0),t_image(a6) /* address of fontimage ??? why take that from fonthdr again? */
                  movea.l  a2,a5          /* address of intin */
                  movea.l  t_offtab(a6),a4 /* address of character offsets */

textj_width_loop: move.w   (a2)+,d2       /* character index */
                  tst.w    d3             /* word spacing ? */
                  bmi.s    textj_char
                  cmp.w    #SPACE,d2      /* space, new word ? */
                  bne.s    textj_char
                  addq.w   #1,t_space_kind(a6) /* increment word count */
textj_char:       sub.w    d0,d2
                  cmp.w    d1,d2          /* character present ? */
                  bls.s    textj_width
                  move.w   t_unknown_index(a6),d2
textj_width:      add.w    d2,d2
                  lea.l    2(a4,d2.w),a0
                  move.w   (a0),d2
                  sub.w    -(a0),d2       /* character width without scaling */
                  tst.b    t_grow(a6)     /* enlarge ? */
                  beq.s    textj_add
                  mulu.w   t_cheight(a6),d2 /* * character height */
                  divu.w   t_iheight(a6),d2 /* / actual height */
textj_add:        add.w    d5,d2            /* + widening from effects */
                  add.w    d2,d4
                  dbra     d7,textj_width_loop
                  tst.w    d4             /* at least 1 pixel ? */
                  bmi      text_exit

textj_length:     move.w   4(a3),d3       /* text length in pixel */
                  btst     #T_ITALICS_BIT,t_effects+1(a6) /* italics ? */
                  beq.s    textj_spacing
                  sub.w    t_whole_off(a6),d3 /* subtract italics enlargement */

textj_spacing:    tst.w    t_space_kind(a6) /* character spacing? */
                  bpl.s    textj_difference
                  cmp.w    t_cwidth(a6),d3 /* enough room for largest character? */
                  bge.s    textj_difference
                  move.w   t_cwidth(a6),d3
textj_difference: subq.w   #1,d3          /* desired text length -1 */
                  neg.w    d4
                  add.w    d3,d4
                  move.w   d4,t_add_length(a6) /* length difference */
                  move.w   d3,d4

                  move.w   t_space_kind(a6),d7 /* character spacing ? */
                  bmi      text_position
                  move.w   t_add_length(a6),d2 /* stretching? */
                  bpl      text_position

                  move.w   t_space_index(a6),d0
                  add.w    d0,d0
                  lea.l    2(a4,d0.w),a0
                  move.w   (a0),d0
                  sub.w    -(a0),d0
                  mulu.w   t_cheight(a6),d0
                  divu.w   t_iheight(a6),d0 /* width of a space */
                  mulu.w   d7,d0          /* width of all space */
                  neg.w    d0
                  cmp.w    d2,d0          /* compression to large? */
                  ble      text_position
                  sub.w    d2,d4          /* width without compression */
                  add.w    d0,d4
                  move.w   d0,t_add_length(a6) /* new text length difference */
                  bra      text_position
