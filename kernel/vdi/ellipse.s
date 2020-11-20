/* 'Grafische Unterfunktionen' */

/*
 * Ellipsenausschnitt zeichnen (gefuellt)
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w Radius a
 * d3.w Radius b
 * d4.w starting angle in tenths of degrees (0-3600)
 * d5.w ending angle in tenths of degrees (0-3600)
 * a6.l Wk-Zeiger
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
fellipse_arc:
	tst.w      d4
	bne.s      fellipse_arc2
	cmpi.w     #3600,d5
	beq        fellipse2                /* Vollellipse zeichnen */
fellipse_arc2:
	tst.w      d5
	bne.s      fellipse_arc3
	cmpi.w     #3600,d4
	beq        fellipse2                /* Vollellipse zeichnen */
fellipse_arc3:
	movea.l    buffer_addr(a6),a1
	move.l     buffer_len(a6),-(sp)     /* Bufferlaenge speichern */
	move.l     a1,-(sp)                 /* Bufferadresse speichern */
	move.w     d0,(a1)+
	move.w     d1,(a1)+
	bsr.s      ellipse_calc_in          /* Bufferadresse uebergeben */
	movea.l    (sp),a3
	move.l     (a3),(a1)+               /* Umriss schliessen */
	move.l     a1,d1
	sub.l      a3,d1
	move.l     a1,buffer_addr(a6)       /* neue Bufferstartadresse */
	move.l     d1,buffer_len(a6)        /* neue Bufferlaenge */
	move.w     d0,d4
	addq.w     #1,d4                    /* Koordinatenpaaranzahl - 1 */
	bmi.s      fellipse_arc_ex
	bsr        v_fillarea3
fellipse_arc_ex:
	move.l     (sp)+,buffer_addr(a6)    /* alte Bufferadresse */
	move.l     (sp)+,buffer_len(a6)     /* alte Bufferlaenge */
	rts

/*
 * Ellipse berechnen
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w Radius a
 * d3.w Radius b
 * d4.w starting angle in tenths of degrees (0-3600)
 * d5.w ending angle in tenths of degrees (0-3600)
 * a6.l Zeiger auf die Wk (buffer_addr)
 * Ausgaben
 * Register d0/d4-d7/a0-a1/a2.l werden veraendert
 * d0.w Koordinatenpaaranzahl
 * a1.l Zeiger auf die erste unbenutzte Bufferadresse
 */
ellipse_calc:
	movea.l    buffer_addr(a6),a1

/*
 * Ellipse berechnen
 * Eingaben wie bei ellipse_calc, zusaetzlich
 * a1.l Bufferadresse
 * Ausgaben wie bei ellipse_calc
 */
ellipse_calc_in:
	ext.l      d4
	ext.l      d5
	move.w     #3600,d6
	cmp.w      d4,d5                    /* gleiche Winkel, nur ein Punkt ? */
	bne.s      ellipse_wa

	divs.w     d6,d4
	clr.w      d4
	swap       d4
	tst.w      d4
	bpl.s      ellipse_calc1
	add.w      d6,d4
ellipse_calc1:
	divs.w     #10,d4
	bsr        ellipse_point
	move.l     -4(a1),(a1)+
	moveq.l    #2,d0                    /* 2 Punkte fuer v_pline */
	rts

ellipse_wa:
	divs.w     d6,d4
	clr.w      d4
	swap       d4
	tst.w      d4
	bpl.s      ellipse_wb
	add.w      d6,d4

ellipse_wb:
	divs.w     d6,d5
	clr.w      d5
	swap       d5
	tst.w      d5
	bpl.s      ellipse_wab
	add.w      d6,d5

ellipse_wab:
	cmp.w      d4,d5
	bgt.s      ellipse_grad
	add.w      d6,d5

ellipse_grad:
	divs.w     #10,d4                   /* in Grad umrechnen */
	divs.w     #10,d5                   /* in Grad umrechnen */
	bsr        ellipse_point            /* Startpunkt berechnen */
	move.l     d5,-(sp)                 /* Endwinkel sichern */
	lea.l      isintable,a0
ellipse_grad8:
	cmp.w      #100,d2
	bgt.s      ellipse_grad4
	cmp.w      #100,d3
	bgt.s      ellipse_grad4
	cmp.w      #20,d2
	ble.s      ellipse_grad4
	cmp.w      #20,d3
	ble.s      ellipse_grad4

	addq.w     #8,d4
	andi.w     #0xfff8,d4               /* naechste 8 degree-Position */
	movea.w    #16,a2                   /* Schrittweite fuer 8 degree */
	add.w      d4,d4
	adda.w     d4,a0
	lsr.w      #4,d4
	lsr.w      #3,d5                    /* 8 degree-Schritte */
	bra.s      ellipse_test

ellipse_grad4:
	cmp.w      #300,d2
	bgt.s      ellipse_grad2
	cmp.w      #300,d3
	bgt.s      ellipse_grad2

	addq.w     #4,d4
	andi.w     #0xfffc,d4               /* naechste 4 degree-Position */

	movea.w    #8,a2                    /* Schrittweite fuer 4 degree */
	add.w      d4,d4
	adda.w     d4,a0
	lsr.w      #3,d4
	lsr.w      #2,d5                    /* 4 degree-Schritte */
	bra.s      ellipse_test

ellipse_grad2:
	addq.w     #2,d4
	andi.w     #0xfffe,d4
	movea.w    #4,a2                    /* Schrittweite fuer 2 degree */

	add.w      d4,d4
	adda.w     d4,a0
	lsr.w      #2,d4
	lsr.w      #1,d5
ellipse_test:
	sub.w      d4,d5                    /* Zaehler */
	moveq.l    #1,d4                    /* Anzahl der berechneten Punkte */
	subq.w     #1,d5
	bmi.s      ellipse_last
	move.l     #32768,d7                /* Rundungswert */

ellipse_cloop:
	move.w     (a0),d6                  /* sin */

	muls.w     d2,d6                    /* * a */
	add.l      d6,d6                    /* * 2 */
	add.l      d7,d6                    /* runden */
	swap       d6                       /* / 65536 */
	add.w      d0,d6                    /* + x1 */
	bvc.s      ell_noover1
	tst.w      d6
	bmi.s      ell_overmi1
	move.w     #-32767,d6               /* grosses negatives Ergebnis */
	bra.s      ell_noover1
ell_overmi1:
	move.w     #32767,d6                /* grosses positives Ergebnis */
ell_noover1:
	move.w     d6,(a1)+
	move.w     icostable-isintable(a0),d6 /* cos */
	muls.w     d3,d6                    /* * b */
	add.l      d6,d6                    /* * 2 */
	add.l      d7,d6                    /* runden */
	swap       d6                       /* / 65536 */
	add.w      d1,d6                    /* + y1 */
	bvc.s      ell_noover2
	tst.w      d6
	bmi.s      ell_overmi2
	move.w     #-32767,d6               /* grosses negatives Ergebnis */
	bra.s      ell_noover2
ell_overmi2:
	move.w     #32767,d6                /* grosses positives Ergebnis */
ell_noover2:
	move.w     d6,(a1)+
	move.l     -(a1),d6
	cmp.l      -4(a1),d6                /* gleicher Punkt? */

	beq.s      ell_next
	addq.l     #4,a1
	addq.w     #1,d4
ell_next:
	adda.w     a2,a0                    /* um a2/2 Grad weiter */
	dbf        d5,ellipse_cloop

ellipse_last:
	move.w     d4,d5
	addq.w     #1,d5                    /* Punktanzahl */
	move.l     (sp)+,d4
	bsr.s      ellipse_point
	move.w     d5,d0
	rts

/*
 * Start- bzw. Endpunkt einer Ellipse annaehren
 * Eingaben
 * d0.w x
 * d1.w y
 * d2.w ra
 * d3.w rb
 * d4.l Winkel in Grad im unteren und Rest in 10tel Grad im oberen Wort
 * a1.l Zeiger auf den Buffer
 * Ausgaben
 * Register d6-d7/a0-a1.l werden veraendert
 * d0.w x
 * d1.w y
 * d2.w ra
 * d3.w rb
 * d4.l Winkel in Grad im unteren und Rest in 10tel Grad im oberen Wort
 * a1.l wird um 4 Bytes weitergesetzt, x- und y-Koordinate wurden abgelegt
 */
ellipse_point:
	lea.l      isintable,a0
	adda.w     d4,a0
	adda.w     d4,a0
	swap       d4
	move.w     (a0)+,d6
	move.w     (a0),d7
	sub.w      d6,d7
	muls.w     d4,d7
	add.l      d7,d7
	divs.w     #10,d7                   /* Interpolationsergebnis */
	addq.w     #1,d7
	asr.w      #1,d7
	add.w      d7,d6                    /* sin */
	muls.w     d2,d6                    /* * a */
	add.l      d6,d6                    /* * 2 */
	add.l      #32768,d6                /* runden */
	swap       d6                       /* / 65536 */
	add.w      d0,d6                    /* + x1 */
	bvc.s      ell_noover3
	tst.w      d6
	bmi.s      ell_overmi3
	move.w     #-32767,d6               /* grosses negatives Ergebnis */
	bra.s      ell_noover3
ell_overmi3:
	move.w     #32767,d6                /* grosses positives Ergebnis */
ell_noover3:
	move.w     d6,(a1)+
	lea.l      icostable-isintable(a0),a0 /* Zeiger in die Cosinus-Tabelle */
	move.w     (a0),d7
	move.w     -(a0),d6
	sub.w      d6,d7
	muls.w     d4,d7
	add.l      d7,d7
	divs.w     #10,d7                   /* Interpolationsergebnis */
	addq.w     #1,d7
	asr.w      #1,d7
	add.w      d7,d6                    /* cos */
	muls.w     d3,d6                    /* * b */
	add.l      d6,d6                    /* * 2 */
	add.l      #32768,d6                /* runden */
	swap       d6                       /* / 65536 */
	add.w      d1,d6                    /* + y1 */
	bvc.s      ell_noover4
	tst.w      d6
	bmi.s      ell_overmi4
	move.w     #-32767,d6               /* grosses negatives Ergebnis */
	bra.s      ell_noover4
ell_overmi4:
	move.w     #32767,d6                /* grosses positives Ergebnis */
ell_noover4:
	move.w     d6,(a1)+
	swap       d4
	rts

/*
 * Ellipse zeichnen (gefuellt)
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w Radius a
 * d3.w Radius b
 * a6.l Workstation
 * Ausgaben
 * d0-d7/a0-a5 werden zerstoert
 */
fellipse2:
	moveq.l    #0,d4
	move.w     #3600,d5
	cmp.w      #1000,d2                 /* Radius zu gross (ueberlauf moeglich) ? */
	bgt        fellipse_arc3
	cmp.w      #1000,d3                 /* Radius zu gross (ueberlauf moeglich) ? */
	bgt        fellipse_arc3
	bsr.s      fellipse
	tst.w      f_perimeter(a6)          /* Umrahmung ? */
	beq.s      fellipse_ex2
	bsr        ellipse_calc             /* Koordinaten der Umrahmung berechnen */
	move.w     d0,d4                    /* Koordinatenpaaranzahl */
	movea.l    buffer_addr(a6),a3
	bra        v_pline_fill             /* Umrandung ziehen */
fellipse_ex2:
	rts

/*
 * Ellipse zeichnen (gefuellt, ohne Umrahmung)
 * Eingaben
 * d0.w x1
 * d1.w y1
 * d2.w Radius a
 * d3.w Radius b
 * a6.l Workstation
 * Ausgaben
 * kein Register wird zerstoert
 */
fellipse:
	movem.l    d0-d7/a0-a1,-(sp)        /* Register sichern */
	movea.l    buffer_addr(a6),a0       /* Zeiger auf Offsettabelle */

	tst.w      d2
	bgt.s      fellipse_a
	neg.w      d2
fellipse_a:
	tst.w      d3
	beq.s      fellipse_b0
	bgt.s      fellipse_b
	neg.w      d3

fellipse_b:
	bsr.s      fec                      /* Offsets berechnen */

fellipse_b0:
	move.w     d0,d4
	sub.w      d2,d0                    /* x1 */
	add.w      d2,d2
	add.w      d0,d2                    /* x2 */
	movem.w    d0-d2/d4,-(sp)
	bsr        fline
	movem.w    (sp)+,d0-d2/d4

	tst.w      d3                       /* nur eine Zeile ? */
	beq.s      fe_exit

	sub.w      d3,d1                    /* y1 */
	add.w      d3,d3
	add.w      d1,d3                    /* y2 */

fe_loop:
	move.w     d4,d0                    /* x */
	move.w     d4,d2                    /* x */
	sub.w      (a0),d0                  /* x1 */
	add.w      (a0)+,d2                 /* x2 */

	move.w     d4,-(sp)
	movem.w    d0-d2,-(sp)
	bsr        fline
	movem.w    (sp),d0-d2
	move.w     d3,d1
	bsr        fline
	movem.w    (sp)+,d0-d2
	move.w     (sp)+,d4
	addq.w     #1,d1                    /* naechste Zeile */
	subq.w     #1,d3                    /* naechste Zeile */

	cmp.w      d1,d3
	bne.s      fe_loop

fe_exit:
	movem.l    (sp)+,d0-d7/a0-a1
	rts

/*
 * a0 buffer
 * Ellipse berechnen (gefuellt) nach Bresenham
 * Eingaben
 * d2.w Radius a, max. 1023
 * d3.w Radius b, max. 1023
 * a0.l Bufferadresse
 * Ausgaben
 * kein Register wird zerstoert
 */
fec:
	tst.w      d2
	beq.s      fec_small0
	cmp.w      #1,d2
	beq.s      fec_small1
	cmp.w      #1,d3
	beq        fec_small2
	movem.l    d0-d7/a0,-(sp)           /* Register sichern */

	clr.w      d0                       /* Offset x = 0 */
	move.w     d3,d1                    /* Offset y = b */

	mulu.w     d2,d2                    /* qa = a*a */
	move.l     d2,d6                    /* da = a*a */
	move.l     d2,d7                    /* Hilfsvariable */
	add.l      d2,d2                    /* qa = 2a*a */

	mulu.w     d3,d3                    /* qb = b*b */
	add.l      d3,d6                    /* da = a*a + b*b */
	add.l      d3,d3                    /* qb = 2b*b */

	move.l     d2,d5                    /* dy = qa */
	move.w     d5,d4                    /* Low von dy */
	swap       d5                       /* High von dy */
	mulu.w     d1,d5                    /* dy_high = qa_high * b */
	swap       d5
	clr.w      d5                       /* Low loeschen */
	mulu.w     d1,d4                    /* dy_low = qa_low * b */
	add.l      d4,d5                    /* dy = qa * b */
	sub.l      d7,d5                    /* dy = qa * b -a*a */

	move.l     d3,d4                    /* dx = 2b*b */
	lsr.l      #1,d4                    /* dx = b*b */

	subq.w     #1,d1                    /* wegen dbf */
	bmi.s      fec_exit
	bra.s      fec_plus

fec_loop:
	add.l      d5,d6                    /* da += dy */
	sub.l      d2,d5                    /* dy -= qa */

fec_plus:
	tst.l      d6
	bmi.s      fec_output

fec_x_loop:
	sub.l      d4,d6                    /* da -= dx */
	add.l      d3,d4                    /* dx += qb */
	addq.w     #1,d0                    /* Offsetx x += 1 */
	tst.l      d6
	bpl.s      fec_x_loop               /* while (da >= 0) */

fec_output:
	subq.w     #1,d0
	move.w     d0,(a0)+                 /* *buf++ = Offset x */
	addq.w     #1,d0
	dbf        d1,fec_loop

fec_exit:
	movem.l    (sp)+,d0-d7/a0
	rts

fec_small0:
	move.l     a0,-(sp)
	move.w     d3,-(sp)
fec_small0_loop:
	clr.w      (a0)+
	dbf        d3,fec_small0_loop
	move.w     (sp)+,d3
	movea.l    (sp)+,a0
	rts

fec_small1:
	movem.l    d0/d3/a0,-(sp)
	move.w     d3,d0
	add.w      d0,d0
	add.w      d3,d0
	lsr.w      #2,d0
	sub.w      d0,d3
	subq.w     #1,d3
fec_small_l1:
	clr.w      (a0)+
	dbf        d3,fec_small_l1
fec_small_l2:
	move.w     #1,(a0)+
	dbf        d0,fec_small_l2
	movem.l    (sp)+,d0/d3/a0
	rts

fec_small2:
	move.w     d0,-(sp)
	move.w     d2,d0
	add.w      d0,d0
	add.w      d2,d0
	lsr.w      #2,d0
	move.w     d0,(a0)
	move.w     (sp)+,d0
	rts
