/* Define the machine-dependent type `jmp_buf'.  m68k version.  */
#ifndef _BITS_SETJMP_H
#define _BITS_SETJMP_H	1

#if !defined _SETJMP_H && !defined _PTHREAD_H && !defined __ASSEMBLER__
# error "Never include <bits/setjmp.h> directly; use <setjmp.h> instead."
#endif

#ifdef _PUREC_SOURCE

#include <bits/types.h>

#ifdef	__HAVE_FPU__
/* D3-D7,PC,A2-A7,FP3-FP7 */
typedef char  __jmp_buf[12*4 + 5*12];
#else
/* D3-D7,PC,A2-A7 */
typedef char  __jmp_buf[12*4];
#endif

#else

#ifndef __ASSEMBLER__

#include <bits/types.h>

/* Calling environment.  */
typedef struct __jmp_buf_internal_tag
{
	__int32_t ret_pc;
	__int32_t regs[12];		/* d2-d7,a2-a7 */
	char fpregs[6 * 12];	/* fp2-fp7 */
} __jmp_buf[1];

#else

#define __JMP_BUF_FPREGS (4 + 12 * 4)
#define __JMP_BUF_MASK_WAS_SAVED (__JMP_BUF_FPREGS + 6 * 12)
#define __JMP_BUF_SAVED_MASK (__JMP_BUF_MASK_WAS_SAVED + 4)
#define __JMP_BUF_SIZEOF (__JMP_BUF_SAVED_MASK + 4)

#endif

#endif

#endif	/* bits/setjmp.h */

