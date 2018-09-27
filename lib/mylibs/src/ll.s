/*
*
* Multiplikation 32Bit * 32Bit = 64Bit
* fÅr 68000 Prozessor
*
* Andreas Kromke
* 18.7.98
*
* Tabulatorweite: 5
*
*/

	EXPORT	ullmul

;	MC68030
; mulu	d0,d0:d1

/*****************************************************************
*
* void ullmul(
*			d0 = ULONG m1,
*			d1 = ULONG m2,
*			a0 = ULONG erg[2]
*			);
*
*****************************************************************/

	MODULE ullmul
 movem.l	d3/d4/d5/d6,-(sp)
 move.w	d0,d2
 mulu	d1,d2		; d2.l = low*low
 move.l	d0,d3
 swap	d3
 mulu	d1,d3		; d3.l = hi*low
 move.l	d1,d5
 swap	d5
 mulu	d0,d5		; d5.l = low*hi
 moveq	#0,d4
 swap	d3
 move.w	d3,d4		; d4.l = öberlauf von hi*low << 16
 clr.w	d3			; d3.l = low*hi << 16
 moveq	#0,d6
 swap	d5
 move.w	d5,d6		; d6.l = öberlauf von low*hi << 16
 clr.w	d5			; d5.l = hi*low << 16
 add.l	d3,d2
 bcc.b	um_noc
 addq.l	#1,d4		; 1 Bit öberlauf
um_noc:
 add.l	d5,d5
 bcc.b	um_noc2
 addq.l	#1,d6		; 1 Bit öberlauf
um_noc2:
 move.l	d2,4(a0)		; untere 32 Bit
 swap	d0
 swap	d1
 mulu	d1,d0		; hi*hi
 add.l	d4,d0
 add.l	d6,d0
 move.l	d0,(a0)		; obere 32 Bit
 movem.l	(sp)+,d3/d4/d5/d6
 rts
	ENDMOD


	END