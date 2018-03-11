* Programm zum Test von CRASHDMP

	SUPER

main:
 clr.l	-(sp)
 move.w	#$20,-(sp)
 trap	#1				; gemdos Super
 addq.l	#6,sp

 move.l	#$12121212,a0
 move.l	a0,usp
 moveq	#0,d0
 moveq	#1,d1
 moveq	#2,d2
 moveq	#3,d3
 moveq	#4,d4
 moveq	#5,d5
 moveq	#6,d6
 moveq	#7,d7
 move.w	#$10,a0
 move.w	#$11,a1
 move.w	#$12,a2
 move.w	#$13,a3
 move.w	#$14,a4
 move.w	#$15,a5
 move.w	#$16,a6
 clr		$87878787