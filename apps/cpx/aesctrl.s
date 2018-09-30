				GLOBL	_aes
				GLOBL	_aes_trap
				GLOBL	_crystal
				GLOBL	_appl_yield
				GLOBL	aes_global

				TEXT

; void _aes_trap(MT_PARMDATA *aes_params, const _WORD *control, _WORD *global_aes);
				MODULE _aes_trap								
				move.l    a2,-(a7)
; allocate stack for AESPB
				lea.l     -24(a7),a7
				movea.l   a7,a2
; aespb.control = aes_params->control
				move.l    a0,(a2)+
; aespb.control[0-1] = control[0-1]
				move.l    (a1)+,(a0)+
; aespb.control[2-3] = control[2-3]
				move.l    (a1)+,(a0)+
; aespb.control[4] = 0
				clr.w     (a0)+
; aespb.global = global_aes
				move.l    32(a7),(a2)+
				bne		  _aes_trap1
				move.l    #aes_global,-4(a2)
_aes_trap1:
; aespb.intin = aes_params->intin
				move.l    a0,(a2)+
; aespb.intout = aes_params->intout
				lea.l     32(a0),a0
				move.l    a0,(a2)+
; aespb.addrin = aes_params->addrin
				lea.l     32(a0),a0
				move.l    a0,(a2)+
; aespb.addrout = aes_params->addrout
				lea.l     64(a0),a0
				move.l    a0,(a2)+
; call AES trap
				move.w    #$00c8,d0
				move.l    a7,d1
				trap      #2
				lea.l     24(a7),a7
				movea.l   (a7)+,a2
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

				BSS
aes_global:
				ds.w 15
