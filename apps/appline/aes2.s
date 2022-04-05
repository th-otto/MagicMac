; offsets of AES parameter block
a_control       equ 0
a_global		equ 4
a_intin			equ 8
a_intout		equ 12
a_addrin		equ 16
a_addrout		equ 20

		.globl aescall
		.globl aescall2
		.globl _objc_offset
		.globl aespb
		.globl _global
		.globl _aesglobal
		.globl _msgbuff

		.text


/*
 * a0: addrin
 * a1: intin
 */
aescall:
		subq.l     #2,a7
		move.l     a0,d1
		lea.l      aespb,a0
		movep.l    d0,25(a0) /* acontrol-aespb+1 */
		move.l     a1,a_intin(a0)
		move.l     d1,a_addrin(a0)
		move.l     a7,a_intout(a0)
		move.l     a0,d1
		move.w     #$00C8,d0
		trap       #2
		move.w     (a7)+,d0
		rts


aesret:
		move.w     0(a6,d1.w),d0
aesret1:
		addq.w     #2,d1
		beq.s      aesret2
		movea.l    (a1)+,a0
		move.w     0(a6,d1.w),(a0)
		bra.s      aesret1
aesret2:
		unlk       a6
		tst.w      d0
		rts

/*
 * a0: addrin
 * a1: intin
 * d2: frame offset of intout
 */
aescall2:
		move.l     a0,d1
		lea.l      aespb,a0
		movep.l    d0,25(a0) /* acontrol-aespb+1 */
		move.l     a1,a_intin(a0)
		move.l     d1,a_addrin(a0)
		add.l      a6,d2
		move.l     d2,a_intout(a0)
		move.l     a0,d1
		move.w     #$00C8,d0
		trap       #2
		lea.l      aesret(pc),a0
		rts

/* objc_offset(OBJECT *tree, int obj, int *x, int *y) */
_objc_offset:
		movem.l    10(a7),a1-a2
		movea.l    4(a7),a0
		move.w     8(a7),d1
		clr.w      (a1)
		clr.w      (a2)
objc_offset1:
		moveq.l    #24,d0
		muls.w     d1,d0
		move.w     16(a0,d0.l),d2
		add.w      d2,(a1)
		move.w     18(a0,d0.l),d2
		add.w      d2,(a2)
		tst.w      d1
		beq.s      objc_offset3
objc_offset2:
		move.w     d1,d2
		muls.w     #$0018,d1
		move.w     0(a0,d1.l),d0
		move.w     d0,d1
		muls.w     #$0018,d0
		cmp.w      4(a0,d0.l),d2
		bne.s      objc_offset2
		bra.s      objc_offset1
objc_offset3:
		moveq.l    #1,d0
		rts

		.bss
	
_msgbuff: .ds.b 16
aespb: .ds.l 6
acontrol: .ds.w 5
_global:
_aesglobal: .ds.w 15
