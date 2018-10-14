     MC68881
     SUPER

     INCLUDE   "osbind.inc"

 clr.l    -(sp)
 gemdos   Super
 addq.l   #6,sp

; clr.w    -(sp)
; move.w   #$0038,-(sp)
; frestore (sp)+

 fsave    -(sp)
 tst.b    (sp)
 lea      nix_s(pc),a0
 beq.b    isnix
 lea      iss_s(pc),a0
isnix:
 pea      (a0)
 gemdos   Cconws
 addq.l   #6,sp
 gemdos   Pterm0

nix_s: DC.B    'keine FPU-Benutzung',$d,$a,0
iss_s: DC.B    'FPU-Benutzung',$d,$a,0

     END
