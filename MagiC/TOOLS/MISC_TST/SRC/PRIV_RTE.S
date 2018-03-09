	SUPER

 moveq	#0,d0
 move.l	#$d1,d1
 move.l	#$d2,d2
 move.l	#$d3,d3
 move.l	#$d4,d4
 move.l	#$d5,d5
 move.l	#$d6,d6
 move.l	#$d7,d7

 lea		$a0,a0
 lea		$a1,a1
 lea		$a2,a2
 lea		$a3,a3
 lea		$a4,a4
 lea		$a5,a5
 lea		$a6,a6

 rte

 clr.w	-(sp)
 trap	#1