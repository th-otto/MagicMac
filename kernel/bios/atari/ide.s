		XDEF IDEWrite
		XDEF IDERead
		XDEF IDEIdentify
		XDEF IDEInitDrive

		INCLUDE "lowmem.inc"
		INCLUDE "hardware.inc"

SECTOR_SIZE equ 512
IO_TIMEOUT  equ 2000
CMD_TIMEOUT equ 200
		
		XREF _lmul
		XREF _ldiv
		XREF _uldiv
		XREF _ulmod
		XREF ideparm

; IDE_PARAM
	OFFSET 0
heads:    ds.w 1
secs:     ds.w 1
cyls:     ds.w 1
capacity: ds.l 1
maxsecs:  ds.w 1

		TEXT

idesleep:
		move.l    d3,-(a7)
		move.l    d0,d3
		moveq.l   #5,d1
		jsr       _ldiv
		move.l    d0,d3
		move.l    (_hz_200).w,d0
idesleep1:
		move.l    (_hz_200).w,d1
		move.l    d0,d2
		add.l     d3,d2
		cmp.l     d2,d1
		bcs.s     idesleep1
		move.l    (a7)+,d3
		rts

idewritesec:
		clr.w     d0
		bra.s     idewritesec2
idewritesec1:
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		move.w    (a1)+,IDE_Data(a0)
		addq.w    #1,d0
idewritesec2:
		cmp.w     #32,d0
		blt.s     idewritesec1
		rts

idereadsec:
		clr.w     d0
		bra.s     idereadsec2
idereadsec1:
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		move.w    IDE_Data(a0),(a1)+
		addq.w    #1,d0
idereadsec2:
		cmp.w     #32,d0
		blt.s     idereadsec1
		rts

idewait:
		move.l    (_hz_200).w,d1
		add.l     d0,d1
		move.l    d1,d0
		bra.s     idewait2
idewait1:
		cmp.l     (_hz_200).w,d0
		bcc.s     idewait2
		moveq.l   #-1,d0
		rts
idewait2:
		moveq.l   #32,d1
		and.b     (gpip).w,d1
		bne.s     idewait1
		move.b    IDE_StatReg(a0),d0
		moveq.l   #9,d2
		and.b     d0,d2
		beq.s     idewait3
		clr.w     d1
		move.b    d0,d1
		move.w    d1,d0
		rts
idewait3:
		clr.w     d0
		rts

ideidentify:
		move.l    a2,-(a7)
		move.l    a3,-(a7)
		movea.l   a0,a3
		movea.l   #IDE_Base,a2
		moveq.l   #7,d1
		and.b     d0,d1
		lsl.b     #4,d1
		or.b      #$A0,d1
		move.b    d1,IDE_DriveHead(a2)
		clr.b     IDE_StatReg2(a2)	/* enable interrupt */
		move.b    #$EC,IDE_Command(a2)	/* send ATA command IDENTIFY DEVICE */
		move.l    #IO_TIMEOUT,d0
		movea.l   a2,a0
		bsr.w     idewait
		tst.w     d0
		bmi.s     ideidentify1
		moveq.l   #1,d1
		and.w     d0,d1
		bne.s     ideidentify1
		moveq.l   #8,d2
		and.w     d0,d2
		bne.s     ideidentify2
ideidentify1:
		bra.s     ideidentify3
ideidentify2:
		movea.l   a3,a1
		movea.l   a2,a0
		bsr       idereadsec			/* read the identify packet */
		clr.w     d0
ideidentify3:
		movea.l   (a7)+,a3
		movea.l   (a7)+,a2
		rts

; void IDEIdentify(short dev, void *ide_data)
IDEIdentify:
		bsr.w     ideidentify
		rts


iderecalibrate:
		move.l    a2,-(a7)
		movea.l   #IDE_Base,a2
		moveq.l   #7,d1
		and.b     d0,d1
		lsl.b     #4,d1
		or.b      #$A0,d1
		move.b    d1,IDE_DriveHead(a2)
		clr.b     IDE_StatReg2(a2)
		move.b    #$10,IDE_Command(a2) /* send ATA command RECALIBRATE */
		move.l    #CMD_TIMEOUT,d0
		movea.l   a2,a0
		bsr       idewait
		movea.l   (a7)+,a2
		rts

idediag:
		movea.l   #IDE_Base,a0
		move.b    #$A0,IDE_DriveHead(a0)
		clr.b     57(a0)
		move.b    #$90,IDE_Command(a0)	/* send ATA command EXECUTE DEVICE DIAGNOSTICS */
		move.l    (_hz_200).w,d0
		add.l     #IO_TIMEOUT,d0
		bra.s     idediag2
idediag1:
		cmp.l     (_hz_200).w,d0
		bcc.s     idediag2
		moveq.l   #-1,d0
		rts
idediag2:
		moveq.l   #32,d1
		and.b     (gpip).w,d1
		bne.s     idediag1
		clr.w     d0
		move.b    5(a0),d0
		rts

iderdy:
		move.l    a2,-(a7)
		movea.l   #IDE_Base,a2
		ori.b     #$04,IDE_StatReg2(a2)
		moveq.l   #50,d0
		bsr       idesleep
		andi.b    #$FB,IDE_StatReg2(a2)
		move.l    #CMD_TIMEOUT,d0
		bsr       idesleep
		moveq.l   #0,d0
		movea.l   (a7)+,a2
		rts
IDERdy:
		bsr.w     iderdy
		rts

idecount:
		movem.l   d3-d4/a2,-(a7)
		movea.l   #IDE_Base,a2
		and.w     #7,d0
		lea.l     (ideparm).l,a0
		move.w    d0,d3
		lsl.w     #4,d3
		move.w    d1,heads(a0,d3.w)
		move.w    d2,secs(a0,d3.w)
		move.w    16(a7),cyls(a0,d3.w)
		move.w    d1,d3
		mulu.w    d2,d3
		moveq.l   #0,d4
		move.w    d3,d4
		move.w    d0,d3
		lsl.w     #4,d3
		move.l    d4,capacity(a0,d3.w)
		move.b    d0,d4
		lsl.b     #4,d4
		move.b    d1,d3
		add.b     #$FF,d3
		or.b      d3,d4
		or.b      #$A0,d4
		move.b    d4,IDE_DriveHead(a2)
		move.b    d2,IDE_SectorCount(a2)
		clr.b     IDE_StatReg2(a2)
		move.b    #$91,IDE_Command(a2)		/* send ATA command INITIALIZE DEVICE PARAMETERS */
		move.l    #IO_TIMEOUT,d0
		movea.l   a2,a0
		bsr       idewait
		movem.l   (a7)+,d3-d4/a2
		rts

idesetmultiple:
		move.l    a2,-(a7)
		movea.l   #IDE_Base,a2
		and.w     #7,d0
		move.w    d0,d2
		lsl.w     #4,d2
		lea.l     (ideparm).l,a0
		move.w    d1,maxsecs(a0,d2.w)
		move.b    d0,d2
		lsl.b     #4,d2
		or.b      #$A0,d2
		move.b    d2,IDE_DriveHead(a2)
		move.b    d1,IDE_SectorCount(a2)
		clr.b     IDE_StatReg2(a2)
		move.b    #$C6,IDE_Command(a2)	/* send ATA command SET MULTIPLE MODE */
		move.l    #IO_TIMEOUT,d0
		movea.l   a2,a0
		bsr       idewait
		movea.l   (a7)+,a2
		rts

; void IDEInitDrive(short dev, void *ide_data)
IDEInitDrive:
		move.w    d3,-(a7)
		move.l    a2,-(a7)
		move.w    d0,d3
		movea.l   a0,a2
		clr.w     d0
		moveq.l   #1,d0
		move.w    2(a2),-(a7) /* # number of logical cylinders */
		move.w    12(a2),d2  /* # of sectors per track */
		move.w    6(a2),d1   /* # of logical heads */
		move.w    d3,d0
		bsr       idecount
		addq.w    #2,a7
		movea.l   (a7)+,a2
		move.w    (a7)+,d3
		rts

ideread:
		movem.l   d3-d7/a2-a3,-(a7)
		subq.w    #4,a7
		move.w    d0,d3
		move.l    d1,(a7)
		move.w    d2,d6
		movea.l   a0,a3
		movea.l   #IDE_Base,a2
		and.w     #7,d3
		lea.l     (ideparm).l,a0
		move.w    d3,d0
		lsl.w     #4,d0
		move.w    secs(a0,d0.w),d4
		move.l    capacity(a0,d0.w),d5
		move.l    (a7),d0
		move.l    d5,d1
		jsr       _uldiv
		move.l    d0,d7
		move.l    (a7),d0
		move.l    d5,d1
		jsr       _ulmod
		move.b    d7,IDE_CylL(a2)
		move.l    d7,d1
		lsr.l     #8,d1
		move.b    d1,IDE_CylH(a2)
		move.b    d3,d1
		lsl.b     #4,d1
		moveq.l   #0,d2
		move.w    d0,d2
		divu.w    d4,d2
		or.b      d2,d1
		or.b      #$A0,d1
		move.b    d1,IDE_DriveHead(a2)
		moveq.l   #0,d1
		move.w    d0,d1
		divu.w    d4,d1
		swap      d1
		addq.b    #1,d1
		move.b    d1,IDE_SectorNumber(a2)
		move.b    d6,IDE_SectorCount(a2)
		clr.b     IDE_StatReg2(a2)
		move.b    #$20,IDE_Command(a2)		/* send ATA command READ SECTORS */
		bra.s     ideread4
ideread1:
		move.l    #IO_TIMEOUT,d0
		movea.l   a2,a0
		bsr       idewait
		tst.w     d0
		bmi.s     ideread2
		moveq.l   #1,d1
		and.w     d0,d1
		bne.s     ideread2
		moveq.l   #8,d2
		and.w     d0,d2
		bne.s     ideread3
ideread2:
		bra.s     ideread5
ideread3:
		movea.l   a3,a1
		movea.l   a2,a0
		bsr       idereadsec
		lea.l     SECTOR_SIZE(a3),a3
		subq.w    #1,d6
ideread4:
		tst.w     d6
		bne.s     ideread1
		clr.w     d0
ideread5:
		addq.w    #4,a7
		movem.l   (a7)+,d3-d7/a2-a3
		rts

; short IDERead (short dev, unsigned long sector, unsigned short count, void *data, long *jiffies)
IDERead:
		movem.l   d3-d5/a3,-(a7)
		move.w    d2,d5
		movea.l   a1,a3
		clr.w     d3
		move.l    (_hz_200).w,d4
		move.w    d5,d2
		bsr       ideread
		move.w    d0,d3
		move.l    a3,d1
		beq.s     IDERead1
		move.l    (_hz_200).w,d2
		sub.l     d4,d2
		move.l    d2,(a3)
IDERead1:
		move.w    d3,d0
		movem.l   (a7)+,d3-d5/a3
		rts

idewrite:
		movem.l   d3-d7/a2-a3,-(a7)
		subq.w    #2,a7
		move.w    d0,d3
		move.l    d1,d6
		move.w    d2,d4
		movea.l   a0,a3
		movea.l   #IDE_Base,a2
		and.w     #7,d3
		lea.l     (ideparm).l,a0
		move.w    d3,d0
		lsl.w     #4,d0
		move.w    secs(a0,d0.w),(a7)
		move.l    capacity(a0,d0.w),d5
		move.l    d6,d0
		move.l    d5,d1
		jsr       _uldiv
		move.l    d0,d7
		move.l    d6,d0
		move.l    d5,d1
		jsr       _ulmod
		move.l    d0,d6
		move.b    d7,IDE_CylL(a2)
		move.l    d7,d1
		lsr.l     #8,d1
		move.b    d1,IDE_CylH(a2)
		move.b    d3,d1
		lsl.b     #4,d1
		move.b    d1,-(a7)
		moveq.l   #0,d1
		move.w    2(a7),d1
		jsr       _uldiv
		or.b      (a7)+,d0
		or.b      #$A0,d0
		move.b    d0,IDE_DriveHead(a2)
		move.l    d6,d0
		moveq.l   #0,d1
		move.w    (a7),d1
		jsr       _ulmod
		addq.b    #1,d0
		move.b    d0,IDE_SectorNumber(a2)
		move.b    d4,IDE_SectorCount(a2)
		clr.b     IDE_StatReg2(a2)
		move.b    #$30,IDE_Command(a2)		/* send ATA command WRITE SECTORS */
		bra.s     idewrite4
idewrite1:
		moveq.l   #8,d0
		and.b     IDE_StatReg2(a2),d0
		beq.s     idewrite1
		movea.l   a3,a1
		movea.l   a2,a0
		bsr       idewritesec
		lea.l     SECTOR_SIZE(a3),a3
		move.l    #IO_TIMEOUT,d0
		movea.l   a2,a0
		bsr       idewait
		tst.w     d0
		bmi.s     idewrite2
		moveq.l   #1,d1
		and.w     d0,d1
		bne.s     idewrite2
		moveq.l   #8,d2
		and.w     d0,d2
		bne.s     idewrite3
idewrite2:
		bra.s     idewrite5
idewrite3:
		subq.w    #1,d4
idewrite4:
		tst.w     d4
		bne.s     idewrite1
		clr.w     d0
idewrite5:
		addq.w    #2,a7
		movem.l   (a7)+,d3-d7/a2-a3
		rts

; short IDEWrite (short dev, unsigned long sector, unsigned short count, void *data)
IDEWrite:
		movem.l   d3-d6/a2,-(a7)
		move.w    d0,d5
		move.l    d1,d4
		move.w    d2,d3
		movea.l   a0,a2
		move.w    d3,d2
		bsr       idewrite
		move.w    d0,d6
		tst.w     d0
		beq.s     IDEWrite1
		movea.l   a2,a0
		move.w    d3,d2
		move.l    d4,d1
		move.w    d5,d0
		bsr       idewrite
		move.w    d0,d6
IDEWrite1:
		move.w    d6,d0
		movem.l   (a7)+,d3-d6/a2
		rts
