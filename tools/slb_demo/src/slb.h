/*
*
* Binding fÅr Verwendung von "shared libraries"
*
* Andreas Kromke
* 22.10.97
*
* 19.2.99
* - SLB_EXEC mit cdecl korrigiert
* 20.8.99
* - Slbclose korrigiert
*/

#ifndef LONG
#include <portab.h>
#endif

typedef void *SHARED_LIB;

/* alte Version: typedef LONG (*SLB_EXEC)( void , ... );	*/
typedef LONG cdecl (*SLB_EXEC)( SHARED_LIB sl, LONG fn, WORD nargs, ... );

extern LONG Slbopen( char *name, char *path, LONG min_ver,
				SHARED_LIB *sl, SLB_EXEC *fn );
extern LONG Slbclose( SHARED_LIB sl );
