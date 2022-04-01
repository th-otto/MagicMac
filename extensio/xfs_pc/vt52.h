#ifndef __GNUC__
# ifndef __PUREC__
#   ifndef __TURBOC__
#     ifndef LATTICE
#       define __ALCYON__ 1
#     endif
#   endif
# endif
#endif

#ifdef __ALCYON__
#define VOID int					/* Void function return	   */
#define VOIDPTR char *
#define NOTHING                     /* no parameters */
#define PROTO(p) ()
#define P(t)
#define PP(v) v
#define volatile
#define const
#define signed
#else
#define VOID void
#define VOIDPTR void *
#define NOTHING void                /* no parameters */
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif

typedef float FLOAT;

int vt52_printf PROTO((const char *format));
int vt52_scanf PROTO((const char *format));



int fmt_int PROTO((int val, int width, char *buf));
int fmt_long PROTO((long val, int width, char *buf));
int fmt_fixed PROTO((FLOAT val, int width, int prec, char *buf));
int fmt_float PROTO((FLOAT val, int width, int prec, char *buf));

int atoint PROTO((const char *str, int *pval));
int atolong PROTO((const char *str, long *pval));
int atofloat PROTO((const char *str, FLOAT *pval));
