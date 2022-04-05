
; offsets of AES parameter block
a_control       equ 0
a_global		equ 4
a_intin			equ 8
a_intout		equ 12
a_addrin		equ 16
a_addrout		equ 20

		.globl _appl_init
		.globl _appl_exit
		.globl _appl_read
		.globl _appl_write
		.globl _appl_find
		.globl _shel_read
		.globl _shel_find
		.globl _shel_envrn
		.globl _wind_get
		.globl _wind_set
		.globl _wind_find
		.globl _winx_create
		.globl _winx_open
		.globl _wind_close
		.globl _wind_delete
		.globl _wind_new
		.globl _wind_update
		.globl _winx_calc
		.globl _form_alert
		.globl _objc_find
		.globl _objc_draw
		.globl _rc_intersect
		.globl _evnt_timer
		.globl _evnx_multi
		.globl _rsrc_load
		.globl _rsrc_free
		.globl _rsrc_gaddr
		.globl _objc_offset_grect
		.globl _objc_offset
		.globl _menu_bar
		.globl _form_popup

		.globl aespb
		.globl _aesglobal
		.globl _global
		.globl aescall2
		
		.text

_form_popup:
		move.l     #$87020101,d0
		lea.l      4(a7),a0
		lea.l      8(a7),a1
		jmp        aescall

_wind_get:
		link       a6,#$FFF6
		move.l     #$68020500,d0
		moveq.l    #-10,d2
		lea.l      8(a6),a1
		jsr        aescall2
		movea.l    12(a6),a1
wind_get1:
		lea.l      -10(a6),a0
		move.w     (a0)+,d0
		move.l     (a0)+,(a1)+
		move.l     (a0),(a1)
		tst.w      d0
		unlk       a6
		rts

; wind_xalc(int type, int kind, GRECT in, GRECT *out)
_winx_calc:
		link       a6,#-10
		move.l     #$6C060500,d0
		moveq.l    #-10,d2 ; intout on stack
		lea.l      8(a6),a1 ; intin from parameters
		jsr        aescall2
		movea.l    20(a6),a1
		bra.s      wind_get1

_menu_bar:
		move.l     #$1E010101,d0
		bra.s      menu_tnormal1

_menu_icheck:
		move.l     #$1F020101,d0
		bra.s      menu_tnormal1

_menu_ienable:
		move.l     #$20020101,d0
		bra.s      menu_tnormal1

_menu_tnormal:
		move.l     #$21020101,d0
menu_tnormal1:
		lea.l      8(a7),a1
		lea.l      4(a7),a0
		jmp        aescall

_objc_offset_grect:
		movea.l    10(a7),a1
		movea.l    4(a7),a0
		move.w     8(a7),d0
		move.w     d0,d1
		muls.w     #$0018,d0
		move.l     20(a0,d0.l),4(a1)
		pea.l      2(a1)
		pea.l      0(a1)
		move.w     d1,-(a7)
		move.l     a0,-(a7)
		jsr        _objc_offset
		lea.l      14(a7),a7
		rts

_appl_init:
		lea.l      aespb,a0
		movea.l    a0,a1
		moveq.l    #31,d0
		moveq.l    #0,d1
appl_init1:
		move.w     d1,(a1)+
		dbf        d0,appl_init1
		lea.l      24(a0),a1 /* acontrol-aespb */
		move.l     a1,0(a0)
		lea.l      34(a0),a1 /* _aesglobal-aespb */
		move.l     a1,4(a0)
		move.l     #$0A000100,d0
		bra.s      appl_exit1

_appl_exit:
		move.l     #$13000100,d0
appl_exit1:
		jmp        aescall

_appl_read:
		move.l     #$0B020101,d0
		bra.s      appl_write1

_appl_write:
		move.l     #$0C020101,d0
appl_write1:
		lea.l      4(a7),a1
		lea.l      8(a7),a0
		jmp        aescall

_appl_find:
		move.l     #$0D000101,d0
		lea.l      4(a7),a0
		jmp        aescall

_shel_read:
		move.l     #$78000102,d0
		bra.s      aesa

_shel_find:
		move.l     #$7C000101,d0
		bra.s      aesa

_shel_envrn:
		move.l     #$7D000103,d0
aesa:
		lea.l      4(a7),a0
		jmp        aescall

_wind_set:
		move.l     #$69060100,d0
		bra.s      aesi

_wind_find:
		move.l     #$6A020100,d0
		bra.s      aesi

_winx_create:
		move.l     #$64050100,d0
		bra.s      aesi

_winx_open:
		move.l     #$65050100,d0
		bra.s      aesi

_wind_close:
		move.l     #$66010100,d0
		bra.s      aesi

_wind_delete:
		move.l     #$67010100,d0
		bra.s      aesi

_wind_new:
		move.l     #$6D000000,d0
aesi:
		lea.l      4(a7),a1
		jmp        aescall

_wind_update:
		move.l     #$6B010100,d0
		lea.l      4(a7),a1
		jmp        aescall

_form_alert:
		move.l     #$34010101,d0
		lea.l      4(a7),a1
		lea.l      6(a7),a0
		jmp        aescall

_objc_find:
		move.l     #$2B040101,d0
		lea.l      8(a7),a1
		lea.l      4(a7),a0
		jmp        aescall

_objc_draw:
		move.l     #$2A060101,d0
		lea.l      8(a7),a1
		lea.l      4(a7),a0
		jmp        aescall

_rc_intersect:
		movea.l    4(a7),a1
		movea.l    8(a7),a0
		movem.l    d4-d7,-(a7)
		move.w     (a1),d1
		add.w      4(a1),d1
		move.w     (a0),d7
		add.w      4(a0),d7
		cmp.w      d1,d7
		blt.s      rc_intersect1
		move.w     d1,d7
rc_intersect1:
		move.w     2(a1),d1
		add.w      6(a1),d1
		move.w     2(a0),d6
		add.w      6(a0),d6
		cmp.w      d1,d6
		blt.s      rc_intersect2
		move.w     d1,d6
rc_intersect2:
		move.w     (a0),d5
		cmp.w      (a1),d5
		bge.s      rc_intersect3
		move.w     (a1),d5
rc_intersect3:
		move.w     2(a0),d4
		cmp.w      2(a1),d4
		bge.s      rc_intersect4
		move.w     2(a1),d4
rc_intersect4:
		move.w     d5,(a0)+
		move.w     d4,(a0)+
		sub.w      d5,d7
		move.w     d7,(a0)+
		sub.w      d4,d6
		move.w     d6,(a0)+
		moveq.l    #1,d0
		subq.w     #1,d6
		subq.w     #1,d7
		or.w       d6,d7
		bpl.s      rc_intersect5
		moveq.l    #0,d0
rc_intersect5:
		movem.l    (a7)+,d4-d7
		tst.w      d0
		rts

_evnt_timer:
		move.l     #$18020100,d0
		lea.l      4(a7),a1
		jmp        aescall

/*
 * struct EVENT {
 *     short msgbuf[8];
 * inputs:
 *     short mflags;
 *     short mbclicks;
 *     short bmask;
 *     short mbstate;
 *     short mm1flags;
 *     short mm1x;
 *     short mm1y;
 *     short mm1w;
 *     short mm1h;
 *     short mm2flags;
 *     short mm2x;
 *     short mm2y;
 *     short mm2w;
 *     short mm2h;
 *     short mtlocount;
 *     short mthicount;
 * outputs:
 *     short mwhich;
 *     short mx;
 *     short my;
 *     short mbutton;
 *     short mkstate;
 *     short mkreturn;
 *     short mbreturn;
 * }
 */
_evnx_multi:
		move.l     #$19100701,d0
		lea.l      aespb,a0
		movep.l    d0,25(a0)
		exg        d2,a2
		lea.l      4(a7),a2
		move.l     a2,a_addrin(a0)
		movea.l    (a2),a2
		lea.l      16(a2),a1
		move.l     a1,a_intin(a0)
		lea.l      48(a2),a1
		move.l     a1,a_intout(a0)
		exg        d2,a2
		move.l     a0,d1
		move.w     #$00C8,d0
		trap       #2
		movea.l    4(a7),a0
		move.w     48(a0),d0
		rts

_rsrc_load:
		move.l     #$6E000101,d0
		lea.l      4(a7),a0
		jmp        aescall
_rsrc_free:
		move.l     #$6F000100,d0
		jmp        aescall
_rsrc_gaddr:
		link       a6,#$FFFE
		lea.l      aespb,a0
		move.l     12(a6),a_addrout(a0)
		move.w     #1,32(a0) /* acontrol-aespb+8 */
		move.l     #$70020100,d0
		moveq.l    #-2,d2
		lea.l      8(a6),a1
		jsr        aescall2
		lea.l      aespb,a0
		clr.l      a_addrout(a0)
		clr.w      32(a0)/* acontrol-aespb+8 */
		move.w     -2(a6),d0
		unlk       a6
		rts
		.bss
