			GLOBL _gemdos

			TEXT

_gemdos:
			move.l    (a7)+,ret_pc
			move.l    a2,save_a2
			trap      #1
			movea.l   save_a2,a2
			movea.l   ret_pc,a1
			jmp       (a1)

			BSS

ret_pc:		ds.l 1
save_a2:	ds.l 1
