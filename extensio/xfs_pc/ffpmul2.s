         ttl       fast floating point precise multiply (ffpmul2)
*******************************************
* (c)  copyright 1980 by motorola inc.    *
*******************************************
 
********************************************
*          ffpmul2 subroutine              *
*                                          *
*   this module is the second of the       *
*   multiply routines.  it is 18% slower   *
*   but provides the highest accuracy      *
*   possible.  the error is exactly .5     *
*   least significant bit versus an error  *
*   in the high-speed default routine of   *
*   .50390625 least significant bit due    *
*   to truncation.                         *
*                                          *
* input:                                   *
*          d6 - floating point multiplier  *
*          d7 - floating point multiplican *
*                                          *
* output:                                  *
*          d7 - floating point result      *
*                                          *
* registers d3 thru d5 are volatile        *
*                                          *
* condition codes:                         *
*          n - set if result negative      *
*          z - set if result is zero       *
*          v - set if overflow occurred    *
*          c - undefined                   *
*          x - undefined                   *
*                                          *
* code: 134 bytes    stack work: 0 bytes   *
*                                          *
* notes:                                   *
*   1) multipier unaltered (d6).           *
*   2) underflows return zero with no      *
*      indicator set.                      *
*   3) overflows will return the maximum   *
*      value with the proper sign and the  *
*      'v' bit set in the ccr.             *
*                                          *
*  times: (8mhz no wait states assumed)    *
* arg1 zero            5.750 microseconds  *
* arg2 zero            3.750 microseconds  *
* minimum time others 45.750 microseconds  *
* maximum time others 61.500 microseconds  *
* average others      52.875 microseconds  *
*                                          *
********************************************
       page
*ffpmul2  idnt  1,1 ffp high-precision multiply
 
       xdef     ffpmul2      | entry point
       xref     ffpcpyrt     | copyright notice
 
       text
 
 
* ffpmul2 subroutine entry point
ffpmul2: move.b d7,d5   | prepare sign/exponent work       4
       beq.s  ffmrtn    | return if result already zero    8/10
       move.b d6,d4     | copy arg1 sign/exponent          4
       beq.s  ffmrt0    | return zero if arg1=0            8/10
       add.w  d5,d5     | shift left by one                4
       add.w  d4,d4     | shift left by one                4
       moveq  #-128,d3  | prepare exponent modifier ($80)  4
       eor.b  d3,d4     | adjust arg1 exponent to binary   4
       eor.b  d3,d5     | adjust arg2 exponent to binary   4
       add.b  d4,d5     | add exponents                    4
       bvs.s  ffmouf    | branch if overflow/underflow     8/10
       move.b d3,d4     | overlay $80 constant into d4     4
       eor.w  d4,d5     | d5 now has sign and exponent     4
       ror.w  #1,d5     | move to low 8 bits               8
       swap.w d5        | save final s+exp in high word    4
       move.w d6,d5     | copy arg1 low byte               4
       clr.b  d7        | clear s+exp out of arg2          4
       clr.b  d5        | clear s+exp out of arg1 low byte 4
       move.w d5,d4     | prepare arg1lowb for multiply    4
       mulu.w d7,d4     | d4 = arg2lowb x arg1lowb         38-54 (46)
       swap.w d4        | place result in low word         4
       move.l d7,d3     | copy arg2                        4
       swap.w d3        | to arg2highw                     4
       mulu.w d5,d3     | d3 = arg1lowb x arg2highw        38-54 (46)
       add.l  d3,d4     | d4 = partial product (no carry)  8
       swap.w d6        | to arg1 high two bytes           4
       move.l d6,d3     | copy arg1highw over              4
       mulu.w d7,d3     | d3 = arg2lowb x arg1highw        38-54 (46)
       add.l  d3,d4     | d4 = partial product             8
       clr.w  d4        | clear low end runoff             4
       addx.b d4,d4     | shift in carry if any            4
       swap.w d4        | put carry into high word         4
       swap.w d7        | now top of arg2                  4
       mulu.w d6,d7     | d7 = arg1highw x arg2highw       40-70 (54)
       swap.w d6        | restore arg1                     4 
       swap.w d5        | restore s+exp to low word
       add.l  d4,d7     | add partial products             8
       bpl    ffmnor    | branch if must normalize         8/10
       add.l  #$80,d7   | round up (cannot overflow)       16
       move.b d5,d7     | insert sign and exponent         4
       beq.s  ffmrt0    | return zero if zero exponent     8/10
ffmrtn: rts             | return to caller                 16
 
* must normalize result
ffmnor: sub.b   #1,d5   | bump exponent down by one        4
       bvs.s   ffmrt0   | return zero if underflow         8/10
       bcs.s   ffmrt0   | return zero if sign inverted     8/10
       moveq   #$40,d4  | rounding factor                  4
       add.l   d4,d7    | add in rounding factor           8
       add.l   d7,d7    | shift to normalize               8
       bcc.s   ffmcln   | return normalized number         8/10
       roxr.l  #1,d7    | rounding forced carry in top bit 10
       add.b   #1,d5    | undo normalize attempt           4
ffmcln: move.b  d5,d7   | insert sign and exponent         4
       beq.s   ffmrt0   | return zero if exponent zero     8/10
       rts              | return to caller                 16
 
* arg1 zero
ffmrt0: move.l #0,d7    | return zero                      4
       rts              | return to caller                 16
 
* overflow or underflow exponent
ffmouf: bpl.s  ffmrt0    | branch if underflow to give zero 8/10
       eor.b  d6,d7     | calculate proper sign            4
       or.l   #$ffffff7f,d7 | force highest value possible 16
       tst.b  d7        | set sign in return code
*        ori.b   #$02,ccr                            set overflow bit
       dc.l   $003c0002 | ****sick assembler****           20
       rts              | return to caller                 16

	dc.w 0x23f9
	dc.b 'ffpmul2.'
