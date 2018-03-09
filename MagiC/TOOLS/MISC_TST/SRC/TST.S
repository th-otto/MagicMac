	MC68020

 move.l	#$12345678,d0
 roxr.w	#3,d0

 move.l	#$12345678,d0
 roxl.w	#3,d0

 move.l	#$12345678,d0
 roxr.l	#3,d0

 move.l	#$12345678,d0
 roxl.l	#3,d0

 move.l	#$12345678,d0
 move.l	#$5555aaaa,d1
 divu.l	d0,d1

 move.l	#$12345678,d0
 move.l	#$5555aaaa,d1
 divs.l	d0,d1

 move.l	#$12345678,d0
 move.l	#$5555aaaa,d1
 mulu.l	d0,d1

 move.l	#$12345678,d0
 move.l	#$5555aaaa,d1
 muls.l	d0,d1

 clr.w	-(sp)
 trap	#1
