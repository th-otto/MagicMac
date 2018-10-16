; cpxstart.s
;=============================================================================
; Startup file for CPXs
;
;


	.globl	    cpxstart
	.globl	    cpx_init
	
	.text

cpxstart:
   	  jmp cpx_init
