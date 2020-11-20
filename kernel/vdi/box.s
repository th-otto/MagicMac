/*
 * Umriss eines abgerundetes Rechtecks berechnen
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * a6.l Wk-Zeiger
 * Ausgaben
 * Register d0-d7/a3/a4.l werden veraendert
 * d4.w Punktanzahl
 * a3.l Zeiger auf die erste unbenutze Bufferadresse
 */
rbox_calc:
	movea.l    buffer_addr(a6),a3
	cmp.w      d0,d2                    /* x1 und x2 vertauschen ? */
	bge.s      rby1y2
	exg        d0,d2
rby1y2:
	cmp.w      d1,d3                    /* y1 u. y2 vertauschen ? */
	bge.s      rbtestx
	exg        d1,d3

rbtestx:
	move.w     d2,d4
	sub.w      d0,d4
	cmpi.w     #15,d4
	ble.s      rbsmall

rbtesty:
	move.w     d3,d4
	sub.w      d1,d4
	cmpi.w     #15,d4
	bgt.s      rbnormal

rbsmall:
	subq.w     #3,d4
	bpl.s      rbsmall2

	move.w     d0,(a3)+                 /* ptsin[0] */
	move.w     d1,(a3)+
	move.w     d2,(a3)+                 /* ptsin[1] */
	move.w     d1,(a3)+
	move.w     d2,(a3)+                 /* ptsin[2] */
	move.w     d3,(a3)+
	move.w     d0,(a3)+                 /* ptsin[3] */
	move.w     d3,(a3)+
	move.w     d0,(a3)+                 /* ptsin[4] */
	move.w     d1,(a3)+
	moveq.l    #5,d4
	rts

rbsmall2:
	move.w     d0,d4
	move.w     d1,d5
	move.w     d2,d6
	move.w     d3,d7
	addq.w     #1,d4
	addq.w     #1,d5
	subq.w     #1,d6
	subq.w     #1,d7
	move.w     d4,(a3)+                 /* ptsin[0] */
	move.w     d1,(a3)+
	move.w     d6,(a3)+                 /* ptsin[1] */
	move.w     d1,(a3)+
	move.w     d2,(a3)+                 /* ptsin[2] */
	move.w     d5,(a3)+
	move.w     d2,(a3)+                 /* ptsin[3] */
	move.w     d7,(a3)+
	move.w     d6,(a3)+                 /* ptsin[4] */
	move.w     d3,(a3)+
	move.w     d4,(a3)+                 /* ptsin[5] */
	move.w     d3,(a3)+
	move.w     d0,(a3)+                 /* ptsin[6] */
	move.w     d7,(a3)+
	move.w     d0,(a3)+                 /* ptsin[7] */
	move.w     d5,(a3)+
	moveq.l    #8,d4                    /* Anzahl */
	rts

rbnormal:
	addq.w     #8,d0
	subq.w     #8,d2
	move.w     d0,(a3)+
	move.w     d1,(a3)+
	move.w     d2,(a3)+
	move.w     d1,(a3)+
	moveq.l    #7,d4
	lea.l      round(pc),a4
rbloop1:
	add.w      (a4)+,d2
	addq.w     #1,d1
	move.w     d2,(a3)+
	move.w     d1,(a3)+
	dbf        d4,rbloop1
	subq.w     #8,d3
	move.w     d2,(a3)+
	move.w     d3,(a3)+
	moveq.l    #7,d4
rbloop2:
	sub.w      -(a4),d2
	addq.w     #1,d3
	move.w     d2,(a3)+
	move.w     d3,(a3)+
	dbf        d4,rbloop2
	move.w     d0,(a3)+
	move.w     d3,(a3)+
	lea.l      round(pc),a4
	moveq.l    #7,d4
rbloop3:
	sub.w      (a4)+,d0
	subq.w     #1,d3
	move.w     d0,(a3)+
	move.w     d3,(a3)+
	dbf        d4,rbloop3
	move.w     d0,(a3)+
	move.w     d1,(a3)+
	moveq.l    #7,d4
rbloop4:
	add.w      -(a4),d0
	subq.w     #1,d1
	move.w     d0,(a3)+
	move.w     d1,(a3)+
	dbf        d4,rbloop4
	moveq.l    #37,d4
	rts

/*
 * gefuelltes abgerundetes Rechteck zeichnen
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * a6.l Wk-Zeiger
 * Ausgaben
 * kein Register wird veraendert
 */
frbox:
	movem.l    d0-d7/a0-a1,-(sp)
frbx1x2:
	cmp.w      d0,d2                    /* muessen x1 und x2 vertauscht werden ? */
	bge.s      frby1y2
	exg        d0,d2
frby1y2:
	cmp.w      d1,d3                    /* y1 u. y2 vertauschen ? */
	bge.s      frbtestx
	exg        d1,d3
frbtestx:
	move.w     d2,d4
	sub.w      d0,d4
	cmpi.w     #15,d4
	ble.s      frbsmall
frbtesty:
	move.w     d3,d4
	sub.w      d1,d4
	cmpi.w     #15,d4
	bgt.s      frbnormal
frbsmall:
	subq.w     #3,d4
	bpl.s      frbsb
	bsr.s      fbox
	bra.s      frbexit

frbsb:
	addq.w     #1,d0
	subq.w     #1,d2
	bsr        fline_save_regs
	addq.w     #1,d1
	exg        d1,d3
	bsr        fline_save_regs
	subq.w     #1,d1
	exg        d1,d3

	subq.w     #1,d0
	addq.w     #1,d2
	bsr.s      fbox
	bra.s      frbexit

frbnormal:
	addq.w     #8,d0
	subq.w     #8,d2
	moveq.l    #7,d4                    /* Zaehler */
	lea.l      round(pc),a0             /* Zeiger */
frbloop:
	move.w     d4,-(sp)
	movem.w    d0-d2,-(sp)
	bsr        fline
	movem.w    (sp),d0-d2
	move.w     d3,d1
	bsr        fline
	movem.w    (sp)+,d0-d2
	move.w     (sp)+,d4
	sub.w      (a0),d0
	add.w      (a0)+,d2
	addq.w     #1,d1                    /* y1+1 */
	subq.w     #1,d3                    /* y2-1 */
	dbf        d4,frbloop
	cmp.w      d1,d3
	blt.s      frbexit
	bsr.s      fbox
frbexit:
	movem.l    (sp)+,d0-d7/a0-a1
	rts

/* Rundungsdaten fuer RBOX */
round:
	.dc.w 2,2,1,1,0,1,0,1


/*
 * gefuelltes Rechteck zeichnen
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w x2
 * d3.w y2
 * a6.l Wk-Zeiger
 * Ausgaben
 * kein Register wird veraendert
 */
fbox:
	movem.l    d0-d7/a0-a6,-(sp)
	bsr.s      fbox_noreg
	movem.l    (sp)+,d0-d7/a0-a6
fbox_exit:
	rts
/* d0-a6 werden veraendert */
fbox_noreg:
	cmp.w      d0,d2
	bge.s      fbox_exgy
	exg        d0,d2
fbox_exgy:
	cmp.w      d1,d3
	bge.s      fbox_clip
	exg        d1,d3

fbox_clip:
	lea.l      clip_xmin(a6),a1

fbox_clipx1:
	cmp.w      (a1)+,d0
	bge.s      fbox_clipy1
	move.w     -2(a1),d0
fbox_clipy1:
	cmp.w      (a1)+,d1
	bge.s      fbox_clipx2
	move.w     -2(a1),d1
fbox_clipx2:
	cmp.w      (a1)+,d2
	ble.s      fbox_clipxx
	move.w     -2(a1),d2
fbox_clipxx:
	cmp.w      d0,d2
	blt.s      fbox_exit
fbox_clipy2:
	cmp.w      (a1),d3
	ble.s      fbox_clipyy
	move.w     (a1),d3
fbox_clipyy:
	cmp.w      d1,d3
	blt.s      fbox_exit

	movea.l    p_fbox(a6),a1
	jmp        (a1)
