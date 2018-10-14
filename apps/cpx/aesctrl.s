				GLOBL	aes
				GLOBL	_crystal
				GLOBL	_appl_yield

				TEXT

; short aes(AESPB *)
				MODULE	aes
				move.l	a2,-(a7)
				move.l	a0,-(a7)
				move.w	#$00c8,d0
				move.l	a0,d1
				trap	#2
				move.l	(a7)+,a0
				move.l	12(a0),a0
				move.w	(a0)+,d0
				move.l	(a7)+,a2
				rts
				ENDMOD
				
; void _crystal(AESPB *)
				MODULE _crystal
				move.l	a2,-(a7)
				move.w	#$00c8,d0
				move.l	a0,d1
				trap	#2
				move.l	(a7)+,a2
				rts
				ENDMOD

; void _appl_yield()
				MODULE _appl_yield
				move.l	a2,-(a7)
				move.w	#$00c9,d0
				trap	#2
				move.l	(a7)+,a2
				rts
				ENDMOD
