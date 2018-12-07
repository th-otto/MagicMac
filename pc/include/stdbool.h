#if defined(__GNUC__)

#  include_next <stdbool.h>

#else

#ifndef _STDBOOL_H
#define _STDBOOL_H

#if defined(__AHCC__)
/*
 * AHCC erroneously declares 'false' and 'true'
 * as builtin constants, and also defines
 * __bool_true_false_are_defined but only declares _Bool, not bool
 */
#undef __bool_true_false_are_defined
#endif

#if ! defined __bool_true_false_are_defined

#ifndef __cplusplus

#define bool	_Bool
#if !defined(__AHCC__)
#define _Bool	int
#endif
#define true	1
#define false	0

#else

/* Supporting <stdbool.h> in C++ is a GCC extension.  */
#define _Bool	bool

#if __cplusplus < 201103L
/* Defining these macros in C++98 is a GCC extension.  */
#define bool	bool
#define false	false
#define true	true
#endif

#endif

#endif

/* Signal that all the definitions are present.  */
#define __bool_true_false_are_defined 1

#endif /* _STDBOOL_H */

#endif /* __GNUC__ */
