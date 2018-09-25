	MC68030

 divu.l	d0,d0
 divu.l	d0,d1
 divu.l	d0,d2
 divu.l	d0,d1:d0
 divul.l	d0,d1:d0

 mulu.l	d0,d0
 mulu.l	d0,d0:d0

*	DIVU.W <ea>,Dn      32/16 -> 16r:16q
*	DIVU.L <ea>,Dq      32/32 -> 32q     ( MC68020 )
*	DIVU.L <ea>,Dr:Dq   64/32 -> 32r:32q ( MC68020 )
*	DIVUL.L <ea>,Dr:Dq  32/32 -> 32r:32q ( MC68020 )
