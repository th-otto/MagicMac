EXPORT	vt_aes
EXPORT	appl_yield

;void	vt_aes( AESPB *pb )
vt_aes:	move.l	a2,-(sp)
			move.l	a0,d1
			move.w	#200,d0
			trap		#2
			move.l	(sp)+,a2
			rts
			
appl_yield:	move.l	a2,-(sp)
				move.w	#201,d0
				trap		#2
				movea.l	(sp)+,a2
				rts
			