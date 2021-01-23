/*
 * Original-SCSI-Routinen aus HADES-TOS
 */

/*
 * **********************************************************************************************
 * fa 1.1.96:pseudo dma fuer scsi
 * a0=basis adresse register
 * a1=dma adresse
 * a2=alter stackwert/adresse letztes zu uebertragendes long (restdaten!!)
 * a3=sprungadresse/write back 3 adresse 
 * a4=endadresse
 * d0=divers
 * d1=anzahl byts resp. restbyts des letzten sectors -1
 * d2=dma start adresse
 * d3=dtt0 alt
 * d4=10000-anzahl buserrors
 * d5=anzahl sectoren-1
 */
dma_residue    =     0xffff8710
dma_addr_high  =     0xffff8701		/* dma address hi */
dma_addr_mu    =     0xffff8703		/* dma address upper middle */
dma_addr_ml    =     0xffff8705		/* dma address lower middle */
dma_addr_low   =     0xffff8707		/* dma address lo */
dma_count_high =     0xffff8709		/* dma counter hi */
dma_count_mu   =     0xffff870b		/* dma counter upper middle */
dma_count_ml   =     0xffff870d		/* dma counter lower middel */
dma_count_low  =     0xffff870f		/* dma counter lo */
dma_sctr1      =     0xffff8715     /* normal scsi control register.    bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror */
dma_sctr2      =     0xffff8717     /* extra scsi control register.bit 0 = count0/eop. bit 1 = buserror */
dma_psdm       =     0xffff8741     /* pseudo dma adresse for data */


scsi_int2:
	movem.l    d0-d7/a0-a4,-(sp)
	move.b     dma_addr_high.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_mu.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_ml.w,d2
	lsl.l      #8,d2
	move.b     dma_addr_low.w,d2
	move.b     dma_count_high.w,d1
	lsl.l      #8,d1
	move.b     dma_count_mu.w,d1
	lsl.l      #8,d1
	move.b     dma_count_ml.w,d1
	lsl.l      #8,d1
	move.b     dma_count_low.w,d1
	.IFNE 0
	tst.l      d1
	beq        scsiendx
	.ENDC
	move.l     8.w,-(sp)               /* save old buserror vector */
	bclr       #1,dma_sctr1.w          /* dma off -> int 2 off */
	andi.b     #0xfc,dma_sctr2.w       /* eop, bus error off */
	move.l     #scsibuserror,8.w       /* set new vector */
	.dc.w      _movecd,_dtt0+0x3000    /* dtt0 to d3 */
	.dc.w      _movecd,_itt0+0x6000    /* itt0 to d6 */
	.dc.w      _movecd,_cacr+0x7000    /* cacr to d7 */
	move.l     #0x007fc020,d0          /* ram and eprom copy back */
	.dc.w      _movec,_dtt0            /* set copy back */
	.dc.w      _movec,_itt0            
	move.l     #0x80008000,d0
	.dc.w      _movec,_cacr            /* cache on */
	.dc.w      cpusha
	nop
	movea.l    a7,a2                   /* save old stack */
	move.w     #10000,d4               /* 10000 tries = ca. 40ms (1 buserror ist 4us(=min. transferrate=250kb/sec)) -> min. 1500U/min */
	lea        dma_psdm.w,a0
	movea.l    d2,a1                   /* dma address */
	movea.l    d2,a4                   /* start address */
	adda.l     d1,a4                   /* +length=end addresse */
scsijmp:
	subq.l     #1,d1
	move.l     d1,d5                   /* number bytes-1 */
	lsr.l      #8,d5                   /* /512 */
	lsr.l      #1,d5                   /* =number whole sectors */
	and.l      #0x1ff,d1               /* number bytes -1 in last sector */
	lea        scsiwrlb.w(pc),a3       /* table for write to a3 */
	btst       #0,dma_sctr1.w          /* write? */
	bne.s      scsibs                  /* yes-> */
	lea        scsirdlb.w(pc),a3       /* table for read to a3 */
scsibs:
	suba.l     d1,a3                   /* x2 because every instruction is 1 word */
	suba.l     d1,a3                   /* - = current entry point */
	jmp        (a3)                    /* branch */
scsiwrloop:
	.REPT 511
	move.b     (a1)+,(a0)              /* transfer byte */
	.ENDM
scsiwrlb:
	tst.w      d5                      /* last byte? */
	bne.s      scsiwrlb1               /* no-> */
	bset       #0,dma_sctr2.w          /* sonst count0/eop on */
scsiwrlb1:
	move.b     (a1)+,(a0)              /* transfer byte */
	dbf        d5,scsiwrloop           /* repeat until finished */
	bra        scsicont
scsirdloop:
	.REPT 511
	move.b     (a0),(a1)+              /* transfer byte */
	.ENDM
scsirdlb:
	tst.w      d5                      /* last byte? */
	bne.s      scsirdlb1               /* no-> */
	bset       #0,dma_sctr2.w          /* count0/eop on */
scsirdlb1:
	move.b     (a0),(a1)+              /* transfer byte */
	dbf        d5,scsirdloop           /* repeat until finished */

	move.l     a1,d2
	and.b      #0xfc,d2                /* last long */
	movea.l    d2,a0
	move.l     (a0),dma_residue.w      /* restdaten nach register */
scsicont:
	moveq.l    #0,d1                   /* done */
scsiend:
	bset       #1,dma_sctr1.w          /* dma on = ein int 7 scharf */
	.dc.w      _movec,_dtt0+0x3000     /* dtt0 back */
	.dc.w      _movec,_itt0+0x6000     /* itt0 back */
	.dc.w      _movec,_cacr+0x7000     /* cacr back */
	.dc.w      cpusha
	nop
	move.b     d1,dma_count_low.w      /* write byte counter back */
	lsr.l      #8,d1
	move.b     d1,dma_count_ml.w
	lsr.l      #8,d1
	move.b     d1,dma_count_mu.w
	lsr.l      #8,d1
	move.b     d1,dma_count_high.w
	move.l     a1,d1                   /* new dma address */
	move.b     d1,dma_addr_low.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_ml.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_mu.w
	lsr.l      #8,d1
	move.b     d1,dma_addr_high.w
	move.l     (sp)+,8.w               /* restore old buserror vector */
	movem.l    (sp)+,d0-d7/a0-a4
	rte
/* ----------------------------------------------- scsi buserror */
scsibuserror:
	cmp.w      #40,longframe.w         /* mc68040? */
	bne        scsibuer60              /* no-> mc68060 */
	btst       #0,dma_sctr1.w          /* read? */
	beq.s      scbueread40             /* yes-> */
	move.b     15(a7),d0               /* wb3s? */
	bpl.s      scb2                    /* no */
	cmpa.l     24(a7),a0               /* scsiadresse */
	bne.s      scb2x                   /* no */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
scb2:
	tst.b      17(a7)                  /* wb2s? */
	bpl.s      scb1                    /* no */
	cmpa.l     32(a7),a0               /* scsiaddress */
	bne.s      scb1x                   /* no-> */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
scb1:
	tst.b      19(a7)                  /* wb1s? */
	bpl.s      scbuer40w               /* no-> */
	cmpa.l     40(a7),a0               /* scsiaddress */
	bne.s      scbuer40w               /* no-> */
	subq.l     #1,a1                   /* -1 because of prefetch (a1)+,(a0) */
	bra.s      scbuer40w
scbueread40:
	move.b     15(a7),d0               /* wb3s? */
	bpl.s      scbuer40w               /* no-> */
	movea.l    24(a7),a3               /* address */
	move.l     28(a7),d1               /* data */
	bsr        savewb
scbuer40w:
	cmpa.l     20(a7),a0               /* scsidaten area? */
	beq.s      scsitimeout             /* yes -> timeout */
scsibuerer:
	bset       #1,dma_sctr1.w          /* dma on = ein, int 7 scharf */
	movea.l    a2,a7                   /* restore old stack */
	.dc.w      _movec,_dtt0+0x3000     /* dtt0 back */
	.dc.w      _movec,_itt0+0x6000     /* itt0 back */
	.dc.w      _movec,_cacr+0x7000     /* cacr back */
	.dc.w      cpusha
	nop
	or.b       #0x03,dma_sctr2.w       /* buserror- und eop-bit setzen */
	move.l     (sp)+,8.w               /* restore old buserror vector */
	movem.l    (sp)+,d0-d7/a0-a4
	rte
scsibuer60:
	cmpa.l     8(a7),a0                /* scsidaten area? */
	bne.s      scsibuerer              /* no-> bus error */
scsitimeout:
	movea.l    a2,a7                   /* restore old stack */
	move.l     a4,d1                   /* end address */
	sub.l      a1,d1                   /* -current address=rest length */
	subq.w     #1,d4                   /* -1 try */
	bpl        scsijmp                 /* abgelaufen?nein->wiedereinstieg */
	bra        scsiend
scb2x:
	movea.l    24(a7),a3
	move.l     28(a7),d1
	bsr        savewb
	bra        scb2
scb1x:
	movea.l    32(a7),a3
	move.l     36(a7),d1
	bsr        savewb
	bra        scb1
/* ------------------------------------------------------------------------------------------------------------------- */
savewb:
	move.l     #savewbber,8.w          /* neuw buserror vector */
	and.b      #0x60,d0                /* relevant bits */
	bne.s      nolong                  /* is not long-> */
	move.l     d1,(a3)                 /* otherwise write long */
	nop
	rts
nolong:
	cmp.b      #0x20,d0                /* byte? */
	beq.s      ibyt                    /* yes-> */
	move.w     d1,(a3)                 /* otherwise store word */
	nop
	rts
ibyt:
	move.b     d1,(a3)                 /* store byte */
	nop
	rts
savewbber:
	move.l     #scsibuserror,8.w
	rte
