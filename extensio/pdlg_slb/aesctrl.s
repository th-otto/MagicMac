				GLOBL	_aes_trap
				GLOBL	_crystal
				GLOBL	_appl_yield
				XREF aes_global
				XREF aes_dispatcher
				
				TEXT

; _WORD _aes_trap(MX_PARMDATA *data, const _WORD *control, _WORD *global_aes)
_aes_trap:
		move.l    a2,-(a7)
		lea.l     -24(a7),a7
		movea.l   a7,a2
		move.l    a0,(a2)+
		move.l    (a1)+,(a0)+
		move.l    (a1)+,(a0)+
		clr.w     (a0)+
		move.l    32(a7),(a2)+
		bne.s     _mt_aes1
		move.l    #aes_global,-4(a2)
_mt_aes1:
		move.l    a0,(a2)+
		lea.l     32(a0),a0
		move.l    a0,(a2)+
		lea.l     32(a0),a0
		move.l    a0,(a2)+
		lea.l     64(a0),a0
		move.l    a0,(a2)+
		move.l    aes_dispatcher,d0
		beq.s     _mt_aes2
		movea.l   d0,a2
		movea.l   a7,a0
		movem.l   d3-d7/a3-a6,-(a7)
		jsr       (a2)
		movem.l   (a7)+,d3-d7/a3-a6
		bra.s     _mt_aes3
_mt_aes2:		
		move.w    #$00C8,d0
		move.l    a7,d1
		trap      #2
_mt_aes3:
		lea.l     24(a7),a7
		movea.l   (a7)+,a2
		rts
				
_crystal:
		move.l	a2,-(a7)
		move.l    aes_dispatcher,d0
		beq.s     _crystal1
		movea.l   d0,a2
		movem.l   d3-d7/a3-a6,-(a7)
		jsr       (a2)
		movem.l   (a7)+,d3-d7/a3-a6
		bra.s     _crystal2
_crystal1:
		move.w	#$00c8,d0
		move.l	a0,d1
		trap	#2
_crystal2:
		move.l	(a7)+,a2
		rts

; void _appl_yield()
_appl_yield:
				move.l	a2,-(a7)
				move.w	#$00c9,d0
				trap	#2
				move.l	(a7)+,a2
				rts

		data
aes_dispatcher: dc.l 0
