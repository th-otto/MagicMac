				GLOBL	_aes
				GLOBL	_aes_trap
				GLOBL	_crystal
				GLOBL	_appl_yield

				TEXT
								
_aes_trap:
				move.l    a2,-(a7)
				lea.l     -24(a7),a7
				movea.l   a7,a2
				move.l    a0,(a2)+
				move.l    (a1)+,(a0)+
				move.l    (a1)+,(a0)+
				clr.w     (a0)+
				move.l    32(a7),(a2)+
				bne		  _aes_trap1
				move.l    #aes_global,-4(a2)
_aes_trap1:
				move.l    a0,(a2)+
				lea.l     32(a0),a0
				move.l    a0,(a2)+
				lea.l     32(a0),a0
				move.l    a0,(a2)+
				lea.l     64(a0),a0
				move.l    a0,(a2)+
				move.w    #$00c8,d0
				move.l    a7,d1
				trap      #2
				lea.l     24(a7),a7
				movea.l   (a7)+,a2
				rts

; void _crystal(AESPB *)
_crystal:
				move.l	a2,-(a7)
				move.w	#$00c8,d0
				move.l	a0,d1
				trap	#2
				move.l	(a7)+,a2
				rts

; void _appl_yield()				
				move.l	a2,-(a7)
				move.w	#$00c9,d0
				trap	#2
				move.l	(a7)+,a2
				rts

				BSS
aes_global:
				ds.w 15
