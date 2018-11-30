				GLOBL	_aes_trap
				XREF aes_global
				
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
		move.w    #$00C8,d0
		move.l    a7,d1
		trap      #2
		lea.l     24(a7),a7
		movea.l   (a7)+,a2
		rts
