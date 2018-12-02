#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include "ll.h"

#if defined(__PUREC__)
static unsigned long ulmul(unsigned short x, unsigned short y) 0xc0c1;
static unsigned long swap(unsigned long x) 0x4840;
#elif defined(__GNUC__) && defined(__mc68000__)
static __inline unsigned long ulmul(unsigned short x, unsigned short y)
{
	unsigned long z;

	__asm__ __volatile(
		" mulu.w %1,%0"
	: "=d"(z)
	: "d"(y), "0"(x)
	: "cc");
	return z;
}
static __inline unsigned long swap(unsigned long x)
{
	__asm__ __volatile(
		" swap %0"
	: "=d"(x)
	: "0"(x)
	: "cc");
	return x;
}
#else
#define ulmul(x, y) ((unsigned long)(x) * (unsigned long)(y))
#endif

#define W_TYPE_SIZE 32
typedef unsigned long UWtype;
typedef unsigned short UHWtype;

#define __BITS4 (W_TYPE_SIZE / 4)
#define __ll_B ((UWtype) 1 << (W_TYPE_SIZE / 2))
#define __ll_lowpart(t) ((UHWtype) (t))
#define __ll_highpart(t) ((UHWtype) (swap(t)))

#define umul_ppmm(w1, w0, u, v)						\
  {									\
    UWtype __x0, __x1, __x2, __x3;					\
    UHWtype __ul, __vl, __uh, __vh;					\
									\
    __ul = __ll_lowpart (u);						\
    __uh = __ll_highpart (u);						\
    __vl = __ll_lowpart (v);						\
    __vh = __ll_highpart (v);						\
									\
    __x0 = ulmul(__ul, __vl);					\
    __x1 = ulmul(__ul, __vh);					\
    __x2 = ulmul(__uh, __vl);					\
    __x3 = ulmul(__uh, __vh);					\
									\
    __x1 += __ll_highpart (__x0);/* this can't give carry */		\
    __x1 += __x2;		/* but this indeed can */		\
    if (__x1 < __x2)		/* did we get it? */			\
      __x3 += __ll_B;		/* yes, add it in the proper pos.  */	\
									\
    (w1) = __x3 + __ll_highpart (__x1);					\
    (w0) = __ll_lowpart (__x1) * __ll_B + __ll_lowpart (__x0);		\
  }

ULONG64 ullmul(unsigned long x, unsigned long y)
{
	ULONG64 ret;
	
	umul_ppmm(ret.p.hi, ret.p.lo, x, y);
	return ret;
}

