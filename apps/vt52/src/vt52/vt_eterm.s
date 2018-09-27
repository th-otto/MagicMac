					IMPORT	reset_vec
					EXPORT	new_etv_term, old_etv_term

					DC.L		'XBRA'
					DC.L		'VT52'
old_etv_term:	DC.L		0
new_etv_term:	movem.l	d0-d2/a0-a1,-(sp)
					bsr		reset_vec
					movem.l	(sp)+,d0-d2/a0-a1
					move.l	old_etv_term,-(sp)
					rts