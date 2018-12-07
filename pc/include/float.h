#ifdef __GNUC__
# pragma warning Ooops, this shouldn't happen, please read comment below.
/* This file is obsolete for recent gcc versions.  Recent gcc systems
   have their own <float.h> in 
   $prefix/gcc-lib/m68k-atari-mint/<version>/include.  */
  #include_next <float.h>
#else

#ifndef _FEATURES_H
# include <features.h>
#endif

#if defined(__PUREC__) || defined(__TURBOC__)
#include <purec/float.h>
#endif

#endif
