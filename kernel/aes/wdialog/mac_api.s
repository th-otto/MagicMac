		XDEF ExecuteMacFunction
		XDEF MacOffsetRect
		XDEF MacUnionRect
		XDEF MacSizeWindow
		XDEF MacNewHandle
		XDEF MacDisposeHandle
		XDEF MacHLock
		XDEF MacHUnlock
		XDEF MacNewPtr
		XDEF MacDisposePtr
		XDEF MacPtrAndHand
		XDEF MacPrOpen
		XDEF MacPrintDefault
		XDEF MacPrValidate
		XDEF MacPrStlInit
		XDEF MacPrJobInit
		XDEF MacPrDlgMain
		XDEF MacPrGeneral
		XDEF MacPrError
		XDEF MacPrClose
		XDEF MacNewControl
		XDEF MacSetCtlValue
		XDEF MacSetCTitle
		XDEF MacGetDItem
		
		XREF modeMac
		XREF callMacContext
		XREF modeAtari
		XREF macA5

; void ExecuteMacFunction(VoidProcPtr theFunction)
ExecuteMacFunction:
		move.l    a2,-(a7)
		move.l    a0,gMacFuncToExec
		pea.l     execMacFuncSub(pc)
		move.w    #38,-(a7)
		trap      #14
		addq.l    #6,a7
		movea.l   (a7)+,a2
		rts
gMacFuncToExec:
		ds.l 1
execMacFuncSub:
		movea.l   gMacFuncToExec(pc),a0
		bra.w     gMacFuncToExec1
		nop
gMacFuncToExec1:
		movem.l   d3-d7/a2-a6,-(a7)
		move.l    modeMac,d0
		beq.s     gMacFuncToExec2
		move.l    a0,-(a7)
		movea.l   modeMac,a1
		jsr       (a1)
		movea.l   (a7)+,a0
		move.l    a0,-(a7)
		movea.l   callMacContext,a1
		jsr       (a1)
		addq.l    #4,a7
		movea.l   modeAtari,a1
		jsr       (a1)
gMacFuncToExec2:
		movem.l   (a7)+,d3-d7/a2-a6
		rts


MacOffsetRect:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		move.w    d1,-(a7)
		dc.w $a8a8
		move.l    (a7)+,a5
		rts

MacUnionRect:
		movem.l   a2/a5,-(a7)
		movea.l   macA5,a5
		movea.l   12(a7),a2
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.l    a2,-(a7)
		dc.w      $a8ab 
		movem.l   (a7)+,a2/a5
		rts

MacSizeWindow:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		move.w    d1,-(a7)
		move.b    d2,-(a7)
		dc.w      $a91d
		movea.l   (a7)+,a5
		rts

MacNewHandle:
		dc.w	$a122
		rts

MacDisposeHandle:
		dc.w    $a023
		rts

MacHLock:
		dc.w    $a029
		rts

MacHUnlock:
        dc.w    $a02a
		rts

MacNewPtr:
		dc.w $a11e
		rts

MacDisposePtr:
		dc.w $a01f
		rts

MacPtrAndHand:
		dc.w $a9ef
		rts

MacPrOpen:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    #$C8000000,-(a7)
		dc.w	$a8fd
		movea.l   (a7)+,a5
		rts

MacPrintDefault:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.l    #$20040480,-(a7)
		dc.w	  $a8fd
		movea.l   (a7)+,a5
		rts

MacPrValidate:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		subq.l    #2,a7
		move.l    a0,-(a7)
		move.l    #$52040498,-(a7)
		dc.w      $a8fd
		move.b	  (a7)+,d0
		movea.l   (a7)+,a5
		rts

MacPrStlInit:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		subq.l    #4,a7
		move.l    a0,-(a7)
		move.l    #$3C04040C,-(a7)
		dc.w	  $a8fd
		move.l	  (a7)+,a0
		movea.l   (a7)+,a5
		rts

MacPrJobInit:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		subq.l    #4,a7
		move.l    a0,-(a7)
		move.l    #$44040410,-(a7)
		dc.w	  $a8fd
		move.l	  (a7)+,a0
		movea.l   (a7)+,a5
		rts

MacPrDlgMain:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		subq.l    #2,a7
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		move.l    #$4A040894,-(a7)
		dc.w	  $a8fd
		move.b	  (a7)+,d0
		movea.l   (a7)+,a5
		rts

MacPrGeneral:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.l    #$70070480,-(a7)
		dc.w	  $a8fd
		movea.l   (a7)+,a5
		rts

MacPrError:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		subq.l    #2,a7
		move.l    #$BA000000,-(a7)
		dc.w	  $a8fd
		move.w    (a7)+,d0
		movea.l   (a7)+,a5
		rts

MacPrClose:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    #$D0000000,-(a7)
		dc.w	  $a8fd
		movea.l   (a7)+,a5
		rts

MacNewControl:
		movem.l   d3-d5/a2/a5,-(a7)
		movea.l   macA5,a5
		movea.l   24(a7),a2 ; title
		move.w    28(a7),d3 ; max
		move.w    30(a7),d4 ; procID
		move.l    32(a7),d5 ; refCon
		subq.l    #4,a7
		move.l    a0,-(a7) ; theWindow
		move.l    a1,-(a7) ; bounds
		move.l    a2,-(a7) ; title
		move.b    d0,-(a7) ; visible
		move.w    d1,-(a7) ; value
		move.w    d2,-(a7) ; min
		move.w    d3,-(a7) ; max
		move.w    d4,-(a7) ; procID
		move.l    d5,-(a7) ; refCon
		dc.w	  $a954
		movea.l   (a7)+,a0
		movem.l   (a7)+,d3-d5/a2/a5
		rts

MacSetCtlValue:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		dc.w	  $a963
		movea.l   (a7)+,a5
		rts

MacSetCTitle:
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.l    a1,-(a7)
		dc.w	  $a95f
		movea.l   (a7)+,a5
		rts

MacGetDItem:
		move.l    4(a7),d1
		move.l    8(a7),d2
		move.l    a5,-(a7)
		movea.l   macA5,a5
		move.l    a0,-(a7)
		move.w    d0,-(a7)
		move.l    a1,-(a7)
		move.l    d1,-(a7)
		move.l    d2,-(a7)
		dc.w	  $a98d
		movea.l   (a7)+,a5
		rts
