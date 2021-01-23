;*******************************************************************************************************************

; Aus Hades-TOS-Source:

; Nur fuer 68060!


; unimplemented integer instruction handler (fuer movep,mulx.l,divx.l)

x060_real_fline:
UIIADR:
     pea  exception
     rts

;========================================================
;unimplementet integer routinen
;=========================================================

x060_fpsp_done:
x060_real_trap:
x060_real_trace:
x060_real_access:
x060_isp_done:
     rte

x060_real_cas:
     bra.l          xI_CALL_TOP+$80+$08

x060_real_cas2:
     bra.l          xI_CALL_TOP+$80+$10

; INPUTS:
;    a0 - source address 
;    a1 - destination address
;    d0 - number of bytes to transfer   
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
; OUTPUTS:
;    d1 - 0 = success, !0 = failure
x060_dmem_write:
x060_imem_read:
x060_dmem_read:
     dc.w      $4efb,$0522,$6,0         ;jmp ([mov_tab,pc,d0.w*4],0)
mov_tab:dc.l        mov0,mov1,mov2,mov3,mov4,mov5
        dc.l            mov6,mov7,mov8,mov9,mov10,mov11,mov12
mov1:     move.b         (a0)+,(a1)+
mov0:     clr.l          d1
     rts
mov3:     move.b         (a0)+,(a1)+
mov2:     move.w         (a0)+,(a1)+
     clr.l          d1
     rts
mov5:     move.b         (a0)+,(a1)+
mov4:     move.l         (a0)+,(a1)+
     clr.l          d1
     rts
mov7:     move.b         (a0)+,(a1)+
mov6:     move.w         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts
mov9:     move.b         (a0)+,(a1)+
mov8:     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts  
mov11:    move.b         (a0)+,(a1)+
mov10:    move.w         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts  
mov12:    move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     move.l         (a0)+,(a1)+
     clr.l          d1
     rts  
     


; INPUTS:
;    a0 - user source address
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
; OUTPUTS:
;    d0 - data byte in d0
;    d1 - 0 = success, !0 = failure
x060_dmem_read_byte:
     clr.l          d0             ;clear whole longword
     move.b         (a0),d0             ;fetch super byte
     clr.l          d1             ;return success
     rts
;INPUTS:
;    a0 - user source address
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d0 - data word in d0
;    d1 - 0 = success, !0 = failure
x060_dmem_read_word:
     clr.l          d0             ;clear whole longword
     move.w         (a0),d0             ;fetch super word
     clr.l          d1             ;return success
     rts

;INPUTS:
;    a0 - user source address
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d0 - instruction longword in d0
;    d1 - 0 = success, !0 = failure
x060_imem_read_long:
x060_dmem_read_long:
     move.l         (a0),d0             ;fetch super longword
     clr.l          d1             ;return success
     rts
;INPUTS:
;    a0 - user destination address
;    d0 - data byte in d0
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d1 - 0 = success, !0 = failure
;
x060_dmem_write_byte:
     move.b         d0,(a0)             ;store super byte
     clr.l          d1             ;return success
     rts

;INPUTS:
;    a0 - user destination address
;    d0 - data word in d0
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d1 - 0 = success, !0 = failure
;
x060_dmem_write_word:
     move.w         d0,(a0)             ;store super word
     clr.l          d1             ;return success
     rts

;INPUTS:
;    a0 - user destination address
;    d0 - data longword in d0
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d1 - 0 = success, !0 = failure
x060_dmem_write_long:
     move.l         d0,(a0)             ;store super longword
     clr.l          d1             ;return success
     rts

;INPUTS:
;    a0 - user source address
;    $4(a6),bit5 - 1 = supervisor mode, 0 = user mode
;OUTPUTS:
;    d0 - instruction word in d0
;    d1 - 0 = success, !0 = failure
x060_imem_read_word:
     move.w         (a0),d0             ;fetch super word
     clr.l          d1             ;return success
     rts


;################################
;# CALL-OUT SECTION #
;################################

; The size of this section MUST be 128 bytes!!!

xI_CALL_TOP:
     dc.l UIIADR-xI_CALL_TOP       
     dc.l UIIADR-xI_CALL_TOP       
     dc.l x060_real_trace-xI_CALL_TOP
     dc.l x060_real_access-xI_CALL_TOP
     dc.l x060_isp_done-xI_CALL_TOP
     dc.l x060_real_cas-xI_CALL_TOP
     dc.l x060_real_cas2-xI_CALL_TOP
     dc.l UIIADR-xI_CALL_TOP
     dc.l UIIADR-xI_CALL_TOP
     dc.l 0,0,0,0,0,0,0
     dc.l x060_imem_read-xI_CALL_TOP
     dc.l x060_dmem_read-xI_CALL_TOP
     dc.l x060_dmem_write-xI_CALL_TOP
     dc.l x060_imem_read_word-xI_CALL_TOP
     dc.l x060_imem_read_long-xI_CALL_TOP
     dc.l x060_dmem_read_byte-xI_CALL_TOP
     dc.l x060_dmem_read_word-xI_CALL_TOP
     dc.l x060_dmem_read_long-xI_CALL_TOP
     dc.l x060_dmem_write_byte-xI_CALL_TOP
     dc.l x060_dmem_write_word-xI_CALL_TOP
     dc.l x060_dmem_write_long-xI_CALL_TOP
     dc.l 0,0,0
     dc.b "XBRA"
     dc.b "Hade"         ; uups -- kein korrektes XBRA! (af)
unim_int_instr:
	.include "..\..\bios\atari\modules\isp.sa"

;=======================================================
;floating point routinen
;======================================================
;# The sample routine below simply clears the exception status bit and
;# does an "rte".
x060_real_ovfl:
x060_real_unfl:
x060_real_operr:
x060_real_snan:
x060_real_dz:
x060_real_inex:
     dc.w      $f327                    ;fsave         -(sp)
     move.w    #$6000,2(sp)
     dc.w      $f35f                    ;frestore (sp)+
     dc.w      $f23c,$9000,0,0          ;fmovem.l #0,fpcr
     rte

;# The sample routine below clears the exception status bit, clears the NaN
;# bit in the FPSR, and does an "rte". The instruction that caused the 
;# bsun will now be re-executed but with the NaN FPSR bit cleared.
x060_real_bsun:
     dc.w      $f327                    ;fsave         -(sp)
     dc.w      $f227,$a800              ;fmovem.l   fpsr,-(a7)
     and.b     #$fe,(sp)
     dc.l      $f21f,$8800              ;fmove.l (sp)+,fpsr
     add.w     #$c,sp
     dc.w      $f23c,$9000,0,0          ;fmovem.l #0,fpcr
     rte

x060_real_fpu_disabled:
     move.l    d0,-(sp)                 ;# enabled the fpu
     dc.w      _movec,_pcr
     bclr      #1,d0
     dc.w      _movecd,_pcr
     move.l    (sp)+,d0
     move.l    $c(sp),2(sp)             ;# set "Current PC"
     dc.w      $f23c,$9000,0,0          ;fmovem.l #0,fpcr
     rte

;# The size of this section MUST be 128 bytes!!!

xFP_CALL_TOP:
     dc.l x060_real_bsun-xFP_CALL_TOP
     dc.l x060_real_snan-xFP_CALL_TOP
     dc.l x060_real_operr-xFP_CALL_TOP
     dc.l x060_real_ovfl-xFP_CALL_TOP
     dc.l x060_real_unfl-xFP_CALL_TOP
     dc.l x060_real_dz-xFP_CALL_TOP
     dc.l x060_real_inex-xFP_CALL_TOP
     dc.l x060_real_fline-xFP_CALL_TOP
     dc.l x060_real_fpu_disabled-xFP_CALL_TOP
     dc.l x060_real_trap-xFP_CALL_TOP
     dc.l x060_real_trace-xFP_CALL_TOP
     dc.l x060_real_access-xFP_CALL_TOP
     dc.l x060_fpsp_done-xFP_CALL_TOP
     dc.l 0,0,0
     dc.l x060_imem_read-xFP_CALL_TOP
     dc.l x060_dmem_read-xFP_CALL_TOP
     dc.l x060_dmem_write-xFP_CALL_TOP
     dc.l x060_imem_read_word-xFP_CALL_TOP
     dc.l x060_imem_read_long-xFP_CALL_TOP
     dc.l x060_dmem_read_byte-xFP_CALL_TOP
     dc.l x060_dmem_read_word-xFP_CALL_TOP
     dc.l x060_dmem_read_long-xFP_CALL_TOP
     dc.l x060_dmem_write_byte-xFP_CALL_TOP
     dc.l x060_dmem_write_word-xFP_CALL_TOP
     dc.l x060_dmem_write_long-xFP_CALL_TOP
     dc.l 0,0,0,0,0

;#############################################################################
;# 060 FPSP KERNEL PACKAGE NEEDS TO GO HERE!!!

	.include "..\..\bios\atari\modules\fpsp.sa"
