/*
 * horizontale Linie mit Fuellmuster ausgeben
 * Eingaben:
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * a6.l Zeiger auf Attribute
 * Ausgaben:
 * kein Register wird veraendert
 */
fline_save_regs:
	movem.l    d0-d2/d4-d7/a1,-(sp)
	bsr.s      fline
	movem.l    (sp)+,d0-d2/d4-d7/a1
	rts

/*
 * horizontale Linie mit Fuellmuster ausgeben
 * Vorgaben:
 * d0-d2/d4-d7/a1 duerfen veraendert werden
 * Eingaben:
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * a6.l Zeiger auf Attribute
 * Ausgaben:
 * -
 */
fline:
	cmp.w      d0,d2                    /* x1 > x2 (Tausch) ? */
	bge.s      fline_clip
	exg        d0,d2
fline_clip:
	lea.l      clip_xmin(a6),a1
fclip_x1:
	cmp.w      (a1)+,d0                 /* x1 < clip_xmin ? */
	bge.s      fclip_y1
	move.w     -2(a1),d0
fclip_y1:
	cmp.w      (a1)+,d1                 /* y1 < clip_ymin ? */
	blt.s      fline_exit
fclip_x2:
	cmp.w      (a1)+,d2                 /* x2 > clip_xmax ? */
	ble.s      fclip_y2
	move.w     -2(a1),d2
fclip_y2:
	cmp.w      (a1)+,d1                 /* y1 > clip_ymax ? */
	bgt.s      fline_exit
	cmp.w      d2,d0                    /* x1 > x2 (nichts zeichnen) ? */
	bgt.s      fline_exit
	move.w     (a1),d7                  /* wr_mode */
	movea.l    p_fline(a6),a1
	jmp        (a1)
fline_exit:
hline_exit:
	rts

/*
 * horizontale Linie ausgeben
 * Vorgaben:
 * d0-d2/d4-d7/a1 duerfen veraendert werden
 * Eingaben:
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d6.w Linienmuster
 * a6.l Zeiger auf Attribute
 * Ausgaben:
 * -
 */
hline:
	cmp.w      d0,d2                    /* x1 > x2 (Tausch) ? */
	bge.s      hline_clip
	exg        d0,d2
hline_clip:
	add.w      l_lastpix(a6),d2
	lea.l      clip_xmin(a6),a1
hclip_x1:
	cmp.w      (a1)+,d0                 /* x1 < clip_xmin ? */
	bge.s      hclip_y1
	move.w     -2(a1),d0
hclip_y1:
	cmp.w      (a1)+,d1                 /* y1 < clip_ymin ? */
	blt.s      hline_exit
hclip_x2:
	cmp.w      (a1)+,d2                 /* x2 > clip_xmax ? */
	ble.s      hclip_y2
	move.w     -2(a1),d2
hclip_y2:
	cmp.w      (a1)+,d1                 /* y1 > clip_ymax ? */
	bgt.s      hline_exit
	cmp.w      d2,d0                    /* x1 > x2 (nichts zeichnen) ? */
	bgt.s      hline_exit
	move.w     (a1),d7                  /* wr_mode */
	movea.l    p_hline(a6),a1
	jmp        (a1)

/*
 * vertikale Linie ausgeben
 * Vorgaben:
 * d0-d7/a1 duerfen veraendert werden
 * Eingaben:
 * d0.w x1
 * d1.w y1
 * d3.w y2
 * d6.w Linienmuster
 * a6.l Zeiger auf Attribute
 * Ausgaben:
 * -
 */
vline:
	cmp.w      d1,d3
	blt.s      vline_change
	add.w      l_lastpix(a6),d3
	lea.l      clip_xmin(a6),a1
	cmp.w      (a1)+,d0                 /* x zu klein ? */
	blt.s      vline_exit
vclip_y1:
	cmp.w      (a1)+,d1                 /* y1 zu klein ? */
	bge.s      vclip_x
	move.w     -2(a1),d1
vclip_x:
	cmp.w      (a1)+,d0                 /* x zu gross ? */
	bgt.s      vline_exit

vclip_y2:
	cmp.w      (a1)+,d3                 /* y2 zu gross ? */
	ble.s      vclip_y_cmp
	move.w     -2(a1),d3
vclip_y_cmp:
	cmp.w      d3,d1
	bgt.s      vline_exit
	move.w     (a1)+,d7                 /* wr_mode */
	movea.l    p_vline(a6),a1
	jmp        (a1)

/* Clipping: */
vline_change:
	exg        d1,d3

	add.w      l_lastpix(a6),d3
	lea.l      clip_xmin(a6),a1

	cmp.w      (a1)+,d0                 /* x zu klein ? */
	blt.s      vline_exit
	cmp.w      (a1)+,d1                 /* y1 zu klein ? */
	bge.s      vclip_c_x
	move.w     -2(a1),d1
vclip_c_x:
	cmp.w      (a1)+,d0                 /* x zu gross ? */
	bgt.s      vline_exit
	cmp.w      (a1)+,d3                 /* y2 zu gross ? */
	ble.s      vclip_c_y_cmp
	move.w     -2(a1),d3
vclip_c_y_cmp:
	cmp.w      d3,d1
	bgt.s      vline_exit
	move.w     (a1)+,d7                 /* wr_mode */
	move.w     d3,d2
	sub.w      d1,d2
	andi.w     #15,d2
	ror.w      d2,d6
	movea.l    p_vline(a6),a1
	jmp        (a1)
vline_exit:
	rts

/*
 * Schraege Linie ziehen
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * d6.w Linienmuster
 * a6.l Workstation-Attribut-Tabelle
 * Ausgaben
 * d0-d7/a1 werden zerstoert
 */
line:
	cmp.w      d0,d2                    /* Koordinaten vertauschen ? */
	bge.s      line_clip
	exg        d0,d2
	exg        d1,d3

line_clip:
	lea.l      clip_xmin(a6),a1
	cmp.w      clip_xmax(a6),d0         /* x1 zu gross ? */
	bgt.s      line_exit
	cmp.w      (a1),d2                  /* x2 zu klein ? */
	blt.s      line_exit

	move.w     d2,d4
	sub.w      d0,d4                    /* dx = x2 - x1 (positiver Ausdruck) */
	cmp.w      d1,d3                    /* y1 groesser y2, dy negativ ? */
	blt.s      line_clip2
	beq        hline                    /* horizontale Linie ? */

	move.w     d3,d5
	sub.w      d1,d5                    /* dy = y2 - y1 (positiver Ausdruck) */

	cmp.w      (a1)+,d0                 /* x1 zu klein ? */
	bge.s      line_clip_y1
	sub.w      -(a1),d0                 /* x1 - clip_xmin (negativer Ausdruck) */
	neg.w      d0                       /* positiver Ausdruck fuer mulu/divu */
	mulu.w     d5,d0                    /* * dy */
	divu.w     d4,d0                    /* / dx */
	add.w      d0,d1                    /* y1 += -(x1 - clip_xmin) * dy / dx */
	move.w     (a1)+,d0                 /* x1 = clip_xmin */

line_clip_y1:
	cmp.w      clip_ymax(a6),d1         /* y1 zu gross ? */
	bgt.s      line_exit
	cmp.w      (a1)+,d1                 /* y1 zu klein ? */
	bge.s      line_clip_x2
	sub.w      -(a1),d1                 /* y1 - clip_ymin (negativer Ausdruck) */
	neg.w      d1                       /* positiver Ausdruck fuer mulu/divu */
	mulu.w     d4,d1                    /* * dx */
	divu.w     d5,d1                    /* * dy */
	add.w      d1,d0                    /* x1 += -(y1 - clip_ymin) * dx / dy */
	move.w     (a1)+,d1                 /* y1 = clip_ymin */
	cmp.w      (a1),d0                  /* x1 zu gross ? */
	bgt.s      line_exit

line_clip_x2:
	cmp.w      (a1)+,d2                 /* x2 zu gross ? */
	ble.s      line_clip_y2
	sub.w      -(a1),d2                 /* x2 - clip_xmax (positiver Ausdruck) */
	mulu.w     d5,d2                    /* * dy */
	divu.w     d4,d2                    /* / dx */
	sub.w      d2,d3                    /* y2 -= (x2 - clip_xmax) * dy / dx */
	move.w     (a1)+,d2                 /* x2 = clip_xmax */

line_clip_y2:
	cmp.w      clip_ymin(a6),d3         /* y2 zu klein ? */
	blt.s      line_exit

	cmp.w      (a1)+,d3                 /* y2 zu gross ? */
	ble.s      line_clip_cmp
	sub.w      -(a1),d3                 /* y2 - clip_ymax (positiver Ausdruck) */
	muls.w     d4,d3                    /* * dx */
	divs.w     d5,d3                    /* / dy */
	sub.w      d3,d2                    /* x2 -= (y2 - clip_ymax) * dx / dy */
	move.w     (a1)+,d3                 /* y2 = clip_ymax */
	cmp.w      clip_xmin(a6),d2         /* x2 zu klein ? */
	bge.s      line_clip_cmp
line_exit:
	rts

line_clip2:
	move.w     d1,d5
	sub.w      d3,d5                    /* dy = y1 - y2 (positiver Ausdruck) */

	cmp.w      (a1)+,d0                 /* x1 zu klein ? */
	bge.s      line_clip2_y1
	sub.w      -(a1),d0                 /* x1 - clip_xmin (negativer Ausdruck) */
	neg.w      d0                       /* positiver Ausdruck fuer mulu/divu */
	mulu.w     d5,d0                    /* * dy */
	divu.w     d4,d0                    /* / dx */
	sub.w      d0,d1                    /* y1 -= -(x1 - clip_xmin) * dy / dx */
	move.w     (a1)+,d0                 /* x1 = clip_xmin */

line_clip2_y1:
	cmp.w      (a1)+,d1                 /* y1 zu klein ? */
	blt.s      line_exit
	cmp.w      clip_ymax(a6),d1         /* y1 zu gross ? */
	ble.s      line_clip2_x2
	sub.w      clip_ymax(a6),d1         /* y1 - clip_ymax (positiver Ausdruck) */
	mulu.w     d4,d1                    /* * dx */
	divu.w     d5,d1                    /* / dy */
	add.w      d1,d0                    /* x1 += (y1 - clip_ymax) * dx / dy */
	move.w     clip_ymax(a6),d1         /* y1 = clip_ymax */
	cmp.w      (a1),d0                  /* x1 zu gross ? */
	bgt.s      line_exit

line_clip2_x2:
	cmp.w      (a1)+,d2                 /* x2 zu gross ? */
	ble.s      line_clip2_y2
	sub.w      -(a1),d2                 /* x2 - clip_xmax (positiver Ausdruck) */
	mulu.w     d5,d2                    /* * dy */
	divu.w     d4,d2                    /* / dx */
	add.w      d2,d3                    /* y2 += (x2 - clip_xmax) * dy / dx */
	move.w     (a1)+,d2                 /* x2 = clip_xmax */

line_clip2_y2:
	cmp.w      (a1)+,d3                 /* y2 zu gross ? */
	bgt.s      line_exit
	cmp.w      clip_ymin(a6),d3         /* y2 zu klein ? */
	bge.s      line_clip_cmp
	sub.w      clip_ymin(a6),d3         /* y2 - clip_ymin (negativer Ausdruck) */
	neg.w      d3                       /* positiver Ausdruck fuer mulu/divu */
	mulu.w     d4,d3                    /* * dx */
	divu.w     d5,d3                    /* / dy */
	sub.w      d3,d2                    /* x2 -= -(y2 - clip_ymin) * dx / dy */
	move.w     clip_ymin(a6),d3         /* y2 = clip_ymin */
	cmp.w      clip_xmin(a6),d2         /* x2 zu klein ? */
	blt.s      line_exit

line_clip_cmp:
	cmp.w      d0,d2                    /* x1 groesser als x2 ? */
	blt.s      line_exit

	move.w     (a1),d7                  /* wr_mode */
	movea.l    p_line(a6),a1
	jmp        (a1)
