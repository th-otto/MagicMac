#ifndef __sigset_t_defined
#define __sigset_t_defined 1

/* A `sigset_t' has a bit for each signal.  */
typedef unsigned long int __sigset_t;

#if defined __USE_POSIX
/* A set of signals to be blocked, unblocked, or waited for.  */
typedef __sigset_t sigset_t;
#endif

#endif

