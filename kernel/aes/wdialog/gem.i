				XREF	_VdiCtrl
				XREF	_VdiParBlk
				XREF	vdi
				
;
; sizes of the various arrays
; these MUST match the definitions in mt_gem.h/aes.h
;
VDI_CNTRLMAX    equ		15
VDI_INTINMAX    equ		132
VDI_INTOUTMAX   equ		140
VDI_PTSINMAX    equ		145
VDI_PTSOUTMAX   equ		145

				OFFSET	0

control:		ds.w	VDI_CNTRLMAX
intin:			ds.w	VDI_INTINMAX
intout:			ds.w	VDI_INTOUTMAX
ptsin:			ds.w	VDI_PTSINMAX
ptsout:			ds.w	VDI_PTSOUTMAX


; offsets of VDI control array
				OFFSET	control
v_opcode:		ds.w	1
v_nptsin:		ds.w	1
v_nptsout:		ds.w	1
v_nintin:		ds.w	1
v_nintout:		ds.w	1
v_opcode2:		ds.w	1
v_handle:		ds.w	1
v_param:		ds.l	4

; offsets of VDI parameter block
				OFFSET	0
v_control:		ds.l	1
v_intin:		ds.l	1
v_ptsin:		ds.l	1
v_intout:		ds.l	1
v_ptsout:		ds.l	1

				TEXT

