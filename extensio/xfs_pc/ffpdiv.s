         ttl       fast floating point divide (ffpdiv)
*****************************************
*  (c) copyright 1980 by motorola inc.  *
*****************************************
 
********************************************
*           ffpdiv subroutine              *
*                                          *
* input:                                   *
*        d6 - floating point divisor       *
*        d7 - floating point dividend      *
*                                          *
* output:                                  *
*        d7 - floating point quotient      *
*                                          *
* condition codes:                         *
*        n - set if result negative        *
*        z - set if result zero            *
*        v - set if result overflowed      *
*        c - undefined                     *
*        x - undefined                     *
*                                          *
* registers d3 thru d5 volatile            *
*                                          *
* code: 150 bytes     stack work: 0 bytes  *
*                                          *
* notes:                                   *
*   1) divisor is unaltered (d6).          *
*   2) underflows return zero without      *
*      any indicators set.                 *
*   3) overflows return the highest value  *
*      with the proper sign and the 'v'    *
*      bit set in the ccr.                 *
*   4) if a divide by zero is attempted    *
*      the divide by zero exception trap   *
*      is forced by this code with the     *
*      original arguments intact.  if the  *
*      exception returns with the denom-   *
*      inator altered the divide operation *
*      continues, otherwise an overflow    *
*      is forced with the proper sign.     *
*      the floating divide by zero can be  *
*      distinguished from true zero divide *
*      by the fact that it is an immediate *
*      zero dividing into register d7.     *
*                                          *
* time: (8 mhz no wait states assumed)     *
* dividend zero         5.250 microseconds *
* minimum time others  72.750 microseconds *
* maximum time others  85.000 microseconds *
* average others       76.687 microseconds *
*                                          *
********************************************
         page
*ffpdiv   idnt      1,1  ffp divide
 
         xdef      ffpdiv     | entry point
         xref      ffpcpyrt   | copyright notice
 
         text
 
* divide by zero exit
fpddzr: divu.w #0,d7     | **force divide by zero **
 
* if the exception returns with altered denominator - continue divide
         tst.l     d6        | ? exception alter the zero
         bne.s     ffpdiv    | branch if so to continue
* setup maximum number for divide overflow
fpdovf: or.l   #$ffffff7f,d7 | maximize with proper sign
       tst.b  d7        | set condition code for sign
*      or.w   #$02,ccr  set overflow bit
       dc.l   $003c0002 | ******sick assembler******
fpdrtn: rts              | return to caller
 
* over or underflow detected
fpdov2:   swap.w    d6        | restore arg1
         swap.w    d7        | restore arg2 for sign
fpdovfs: eor.b  d6,d7     | setup correct sign
        bra.s  fpdovf    | and enter overflow handling
fpdouf: bmi.s  fpdovfs   | branch if overflow
fpdund: move.l #0,d7     | underflow to zero
        rts              | and return to caller
 
***************
* entry point *
***************
 
* first subtract exponents
ffpdiv: move.b d6,d5    | copy arg1 (divisor)
       beq.s  fpddzr    | branch if divide by zero
       move.l d7,d4     | copy arg2 (dividend)
       beq.s  fpdrtn    | return zero if dividend zero
       moveq  #-128,d3  | setup sign mask
       add.w  d5,d5     | isolate arg1 sign from exponent
       add.w  d4,d4     | isolate arg2 sign from exponent
       eor.b  d3,d5     | adjust arg1 exponent to binary
       eor.b  d3,d4     | adjust arg2 exponent to binary
       sub.b  d5,d4     | subtract exponents
       bvs.s  fpdouf    | branch if overflow/underflow
       clr.b  d7        | clear arg2 s+exp
       swap.w d7        | prepare high 16 bit compare
       swap.w d6        | against arg1 and arg2
       cmp.w  d6,d7     | ? check if overflow will occur
       bmi.s  fpdnov    | branch if not
* adjust for fixed point | divide overflow
       add.b  #2,d4     | adjust exponent up one
       bvs.s  fpdov2    | branch overflow here
       ror.l  #1,d7     | shift down by power of two
fpdnov: swap.w d7       | correct arg2
       move.b d3,d5     | move $80 into d5.b
       eor.w  d5,d4     | create sign and absolutize exponent
       lsr.w  #1,d4     | d4.b now has sign+exponent of result
 
* now divide just using 16 bits into 24
       move.l d7,d3     | copy arg1 for initial divide
       divu.w d6,d3     | obtain test quotient
       move.w d3,d5     | save test quotient
 
* now multiply 16-bit divide result times full 24 bit divisor and compare
* with the dividend.  multiplying back out with the full 24-bits allows
* us to see if the result was too large due to the 8 missing divisor bits
* used in the hardware divide.  the result can only be too large by 1 unit.
       mulu.w d6,d3     | high divisor x quotient
       sub.l  d3,d7     | d7=partial subtraction
       swap.w d7        | to low divisor
       swap.w d6        | rebuild arg1 to normal
       move.w d6,d3     | setup arg1 for product
       clr.b  d3        | zero low byte
       mulu.w d5,d3     | find remaining product
       sub.l  d3,d7     | now have full subtraction
       bcc.s  fpdqok    | branch first 16 bits correct
 
* estimate too high, decrement quotient by one
       move.l d6,d3     | rebuild divisor
       clr.b  d3        | reverse halves
       add.l  d3,d7     | add another divisor
       sub.w  #1,d5     | decrement quotient
 
* compute last 8 bits with another divide.  the exact remainder from the
* multiply and compare above is divided again by a 16-bit only divisor.
* however, this time we require only 9 bits of accuracy in the result
* (8 to make 24 bits total and 1 extra bit for rounding purposes) and this
* divide always returns a precision of at least 9 bits.
fpdqok: move.l d6,d3    | copy arg1 again
       swap.w d3        | first 16 bits divisor in d3.w
       clr.w  d7        | into first 16 bits of dividend
       divu.w d3,d7     | obtain final 16 bit result
       swap.w d5        | first 16 quotient to high half
       bmi.s  fpdisn    | branch if normalized
* rare occurrance - unnormalized
* happends when mantissa arg1 < arg2 and they differ only in last 8 bits
       move.w d7,d5     | insert low word of quotient
       add.l  d5,d5     | shift mantissa left one
       sub.b  #1,d4     | adjust exponent down (cannot zero)
       move.w d5,d7     | cancel next instruction
 
* rebuild our final result and return
fpdisn: move.w d7,d5    | append next 16 bits
       add.l  #$80,d5   | round to 24 bits (cannot overflow)
       move.l d5,d7     | return in d7
       move.b d4,d7     | finish result with sign+exponent
       beq.s  fpdund    | underflow if zero exponent
       rts              | return result to caller

	dc.w 0x23f9
	dc.b 'ffpdiv.o'
