/* '7. Escape-Funktionen' */

/*
 * ESCAPE (VDI 5)
 */
v_escape:
	move.l     p_escapes(a6),-(sp)
	rts

v_escape_in:
	tst.w      bitmap_width(a6)         /* Off-Screen-Bitmap? */
	bne.s      v_escape_unof
	movea.l    pb_control(a0),a1
	move.w     v_opcode2(a1),d0
/* Opcodebereich pruefen */
	cmp.w      #V_RMCUR,d0
	bhi.s      v_escape_unof
	movem.l    d1-d7/a2-a5,-(sp)
	movem.l    pb_intin(a0),a2-a5       /* a2=intin, a3=ptsin, a4=intout, a5=ptsout */
	add.w      d0,d0
	move.w     v_escape_tab(pc,d0.w),d2
	movea.l    a2,a5
	movea.l    a1,a0
	movem.w    (V_CUR_XY).w,d0-d1
	movea.l    (V_CUR_AD).w,a1
	movea.w    (BYTES_LIN).w,a2
	jsr        v_escape_tab(pc,d2.w)
	movem.l    (sp)+,d1-d7/a2-a5
v_escape_exit:
	rts

v_escape_unof:
	rts

v_escape_tab:
	.dc.w v_escape_exit-v_escape_tab
	.dc.w vq_chcells-v_escape_tab
	.dc.w v_exit_cur-v_escape_tab
	.dc.w v_enter_cur-v_escape_tab
	.dc.w v_curup-v_escape_tab
	.dc.w v_curdown-v_escape_tab
	.dc.w v_curright-v_escape_tab
	.dc.w v_curleft-v_escape_tab
	.dc.w v_curhome-v_escape_tab
	.dc.w v_eeos-v_escape_tab
	.dc.w v_eeol-v_escape_tab
	.dc.w vs_curaddress-v_escape_tab
	.dc.w v_curtext-v_escape_tab
	.dc.w v_rvon-v_escape_tab
	.dc.w v_rvoff-v_escape_tab
	.dc.w vq_curaddress-v_escape_tab
	.dc.w vq_tabstatus-v_escape_tab
	.dc.w v_hardcopy-v_escape_tab
	.dc.w v_dspcur-v_escape_tab
	.dc.w v_rmcur-v_escape_tab

/*
 * INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS (VDI 5, ESCAPE 1)
 */
vq_chcells:
	move.l     (V_CEL_MX).w,d3          /* columns / lines */
	addi.l     #0x00010001,d3
	swap       d3
	move.l     d3,(a4)
	move.w     #2,v_nintout(a0)
	rts

/*
 * EXIT ALPHA MODE (VDI 5, ESCAPE 2)
 */
v_exit_cur:
	addq.w     #1,(V_HID_CNT).w         /* cursor off */
	bclr       #CURSOR_STATE,(V_STAT_0).w
	bra        clear_screen

/*
 * ENTER ALPHA MODE (VDI 5, ESCAPE 3)
 */
v_enter_cur:
	clr.l      (V_CUR_XY).w             /* column 0 / row 0 */
	move.l     (v_bas_ad).w,(V_CUR_AD).w /* address of cursor */
	move.l     bconout_tab+_con_vec,con_state    /* pointer to VT function */
	jsr        clear_screen
	bclr       #CURSOR_STATE,(V_STAT_0).w
	move.w     #1,(V_HID_CNT).w
	bra        cursor_on                /* cursor on */

/*
 * DIRECT ALPHA CURSOR ADDRESS (VDI 5, ESCAPE 11)
 */
vs_curaddress:
	move.w     (a5)+,d1                 /* column */
	move.w     (a5)+,d0                 /* row */
	subq.w     #1,d0
	subq.w     #1,d1
	bra        set_cursor_xy

/*
 * OUTPUT CURSOR ADDRESSABLE ALPHA TEXT (VDI 5, ESCAPE 12)
 * inputs:
 *  d1: pb
 *  a0: control
 *  a5: intin
 *  a6: wk
 */
v_curtext:
	moveq.l    #0,d1
	move.w     v_nintin(a0),d1          /* number of characters */
	subq.w     #1,d1                    /* not any characters? */
	bmi.s      v_curtext_exit
	movea.l    buffer_addr(a6),a0       /* buffer address */
	movea.l    a0,a1
	move.l     buffer_len(a6),d0
	subq.l     #1,d0
	sub.l      d1,d0                    /* too many characters? */
	bgt.s      v_curtext_copy
	add.l      d1,d0
	move.l     d0,d1                    /* maximum count */
v_curtext_copy:
	move.w     (a5)+,d0                 /* get character */
	move.b     d0,(a1)+                 /* copy it */
	dbra       d1,v_curtext_copy
	clr.b      (a1)+                    /* mark end of string */

	move.l     a0,-(sp)                 /* string address */
	move.w     #CCONWS,-(sp)
	trap       #GEMDOS
	addq.l     #6,sp

v_curtext_exit:
	rts

/*
 * INQUIRE CURRENT ALPHA CURCOR ADDRESS (VDI 5, ESCAPE 15)
 */
vq_curaddress:
	addq.w     #1,d0
	addq.w     #1,d1
	move.w     d1,(a4)+                 /* intout[0] = column */
	move.w     d0,(a4)+                 /* intout[1] = row */
	move.w     #2,v_nintout(a0)
	rts

/*
 * INQUIRE TABLET STATUS (VDI 5, ESCAPE 16)
 */
vq_tabstatus:
	move.w     #1,(a4)                  /* mouse available */
	move.w     #1,v_nintout(a0)
	rts

/*
 * PLACE GRAPHIC CURSOR AT LOCATION (VDI 5, ESCAPE 18)
 */
v_dspcur:
/*
 * REMOVE LAST GRAPHIC CURSOR (VDI 5, ESCAPE 19)
 */
v_rmcur:
	rts
	
/*
 * HARD COPY (VDI 5, ESCAPE 17)
 */
v_hardcopy:
	move.w     #SCRDMP,-(sp)
	trap       #14
	addq.l     #2,sp
	rts
