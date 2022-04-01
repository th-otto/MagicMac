       ttl     fast floating point add/subtract (ffpadd/ffpsub)
***************************************
* (c) copyright 1980 by motorola inc. *
***************************************
 
*************************************************************
*                  ffpadd/ffpsub                            *
*             fast floating point add/subtract              *
*                                                           *
*  ffpadd/ffpsub - fast floating point add and subtract     *
*                                                           *
*  input:                                                   *
*      ffpadd                                               *
*          d6 - floating point addend                       *
*          d7 - floating point adder                        *
*      ffpsub                                               *
*          d6 - floating point subtrahend                   *
*          d7 - floating point minuend                      *
*                                                           *
*  output:                                                  *
*          d7 - floating point add result                   *
*                                                           *
*  condition codes:                                         *
*          n - result is negative                           *
*          z - result is zero                               *
*          v - overflow has occured                         *
*          c - undefined                                    *
*          x - undefined                                    *
*                                                           *
*           registers d3 thru d5 are volatile               *
*                                                           *
*  code size: 228 bytes       stack work area:  0 bytes     *
*                                                           *
*  notes:                                                   *
*    1) addend/subtrahend unaltered (d6).                   *
*    2) underflow returns zero and is unflagged.            *
*    3) overflow returns the highest value with the         *
*       correct sign and the 'v' bit set in the ccr.        *
*                                                           *
*  time: (8 mhz no wait states assumed)                     *
*                                                           *
*           composite average  20.625 microseconds          *
*                                                           *
*  add:         arg1=0              7.75 microseconds       *
*               arg2=0              5.25 microseconds       *
*                                                           *
*          like signs  14.50 - 26.00  microseconds          *
*                    average   18.00  microseconds          *
*         unlike signs 20.13 - 54.38  microceconds          *
*                    average   22.00  microseconds          *
*                                                           *
*  subtract:    arg1=0              4.25 microseconds       *
*               arg2=0              9.88 microseconds       *
*                                                           *
*          like signs  15.75 - 27.25  microseconds          *
*                    average   19.25  microseconds          *
*         unlike signs 21.38 - 55.63  microseconds          *
*                    average   23.25  microseconds          *
*                                                           *
*************************************************************
* ffpadd idnt    1,1  ffp add/subtract
 
       xdef    ffpadd,ffpsub   | entry points
       xref    ffpcpyrt        | copyright notice
		
		text

************************
* subtract entry point *
************************
ffpsub:   move.b  d6,d4   | test arg1
         beq.s   fpart2   | return arg2 if arg1 zero
         eor.b   #$80,d4  | invert copied sign of arg1
         bmi.s   fpami1   | branch arg1 minus
* + arg1
         move.b  d7,d5    | copy and test arg2
         bmi.s   fpams    | branch arg2 minus
         bne.s   fpals    | branch positive not zero
         bra.s   fpart1   | return arg1 since arg2 is zero
 
*******************
* add entry point *
*******************
ffpadd:  move.b  d6,d4    | test argument1
         bmi.s   fpami1   | branch if arg1 minus
         beq.s   fpart2   | return arg2 if zero
 
* + arg1
         move.b  d7,d5    | test argument2
         bmi.s   fpams    | branch if mixed signs
         beq.s   fpart1   | zero so return argument1
 
* +arg1 +arg2
* -arg1 -arg2
fpals:   sub.b   d4,d5    | test exponent magnitudes
         bmi.s   fpa2lt   | branch arg1 greater
         move.b  d7,d4    | setup stronger s+exp in d4
 
* arg1exp <= arg2exp
         cmp.b   #24,d5   | overbearing size
         bcc.s   fpart2   | branch yes, return arg2
         move.l  d6,d3    | copy arg1
         clr.b   d3       | clean off sign+exponent
         lsr.l   d5,d3    | shift to same magnitude
         move.b  #$80,d7  | force carry if lsb-1 on
         add.l   d3,d7    | add arguments
         bcs.s   fpa2gc   | branch if carry produced
fparsr:  move.b  d4,d7    | restore sign/exponent
         rts              | return to caller
 
* add same sign overflow normalization
fpa2gc:  roxr.l  #1,d7    | shift carry back into result
         add.b   #1,d4    | add one to exponent
         bvs.s   fpa2os   | branch overflow
         bcc.s   fparsr   | branch if no exponent overflow
fpa2os:  moveq   #-1,d7   | create all ones
         sub.b   #1,d4    | back to highest exponent+sign
         move.b  d4,d7    | replace in result
*        or.b    #$02,ccr | show overflow occurred
         dc.l    $003c0002 | ****assembler error****
         rts              | return to caller
 
* return argument1
fpart1:  move.l  d6,d7    | move in as result
         move.b  d4,d7    | move in prepared sign+exponent
         rts              | return to caller
 
* return argument2
fpart2:  tst.b   d7       | test for returned value
         rts              | return to caller
 
* -arg1exp > -arg2exp
* +arg1exp > +arg2exp
fpa2lt:  cmp.b   #-24,d5  | ? arguments within range
         ble.s   fpart1   | nope, return larger
         neg.b   d5       | change difference to positive
         move.l  d6,d3    | setup larger value
         clr.b   d7       | clean off sign+exponent
         lsr.l   d5,d7    | shift to same magnitude
         move.b  #$80,d3  | force carry if lsb-1 on
         add.l   d3,d7    | add arguments
         bcs.s   fpa2gc   | branch if carry produced
         move.b  d4,d7    | restore sign/exponent
         rts              | return to caller
 
* -arg1
fpami1:  move.b  d7,d5    | test arg2's sign
         bmi.s   fpals    | branch for like signs
         beq.s   fpart1   | if zero return argument1
 
* -arg1 +arg2
* +arg1 -arg2
fpams:   moveq   #-128,d3  | create a carry mask ($80)
         eor.b   d3,d5    | strip sign off arg2 s+exp copy
         sub.b   d4,d5    | compare magnitudes
         beq.s   fpaeq    | branch equal magnitudes
         bmi.s   fpatlt   | branch if arg1 larger
* arg1 <= arg2
         cmp.b   #24,d5   | compare magnitude difference
         bcc.s   fpart2   | branch arg2 much bigger
         move.b  d7,d4    | arg2 s+exp dominates
         move.b  d3,d7    | setup carry on arg2
         move.l  d6,d3    | copy arg1
fpamss:  clr.b   d3       | clear extraneous bits
         lsr.l   d5,d3    | adjust for magnitude
         sub.l   d3,d7    | subtract smaller from larger
         bmi.s   fparsr   | return final result if no overflow

* mixed signs normalize
fpanor:  move.b  d4,d5    | save correct sign
fpanrm:  clr.b   d7       | clear subtract residue
         sub.b   #1,d4    | make up for first shift
         cmp.l   #$00007fff,d7   | ? small enough for swap
         bhi.s   fpaxqn   | branch nope
         swap.w  d7       | shift left 16 bits real fast
         sub.b   #16,d4   | make up for 16 bit shift
fpaxqn:  add.l   d7,d7    | shift up one bit
         dbmi    d4,fpaxqn | decrement and branch if positive
         eor.b   d4,d5    | ? same sign
         bmi.s   fpazro   | branch underflow to zero
         move.b  d4,d7    | restore sign/exponent
         beq.s   fpazro   | return zero if exponent underflowed
         rts              | return to caller

* exponent underflowed - return zero
fpazro:  moveq.l #0,d7    | create a true zero
         rts              | return to caller

* arg1 > arg2
fpatlt:  cmp.b   #-24,d5  | ? arg1 >> arg2
         ble.s   fpart1   | return it if so
         neg.b   d5       | absolutize difference
         move.l  d7,d3    | move arg2 as lower value
         move.l  d6,d7    | set up arg1 as high
         move.b  #$80,d7  | setup rounding bit
         bra.s   fpamss   | perform the addition

* equal magnitudes
fpaeq:   move.b  d7,d5    | save arg1 sign
         exg     d5,d4    | swap arg2 with arg1 s+exp
         move.b  d6,d7    | insure same low byte
         sub.l   d6,d7    | obtain difference
         beq.s   fpazro   | return zero if identical
         bpl.s   fpanor   | branch if arg2 bigger
         neg.l   d7       | correct difference to positive
         move.b  d5,d4    | use arg2's sign + exponent
         bra.s   fpanrm   | and go normalize

	dc.w 0x23f9
	dc.b 'ffpadd.o'
