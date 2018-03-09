EXPORT move_tbuf

;void	move_tbuf( ULONG *tbuf, WORD cnt )
;cnt ist die Anzahl der zu kopierenden Zeichen
;Ist cnt 0 oder kleiner, wird kein Zeichen kopiert.
move_tbuf:			tst.w		d0
						ble.s		move_tbuf_exit
						subq.w	#1,d0
move_tbuf_loop:	move.l 4(a0),(a0)+
						subq.w	#1,d0
						bpl.s		move_tbuf_loop
move_tbuf_exit:	rts