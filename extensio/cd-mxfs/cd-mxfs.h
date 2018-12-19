/*
**
** Dies sind die globalen Prozeduren des CD-XFS fuer MagiX
** Entwickelt mit PureC und Pasm.
**
** (C) Andreas Kromke 1997
**
**
*/

#include <portab.h>
#include <stddef.h>
#include <toserror.h>
#include <tos.h>
#define PD BASEPAGE
typedef void APPL;
#include "mgx_xfs.h"
#include "mgx_devd.h"

/* Hier die Assembler-Schnittstelle */

extern MX_XFS cdxfs;
extern MX_DEV cddev;
extern MX_DDEV cdblkdev;
extern void cdecl kernel__sprintf( char *dst, char *src, LONG *data );
extern void * cdecl kernel_int_malloc( void );
extern void cdecl kernel_int_mfree( void *block );
extern LONG cdecl kernel_diskchange( WORD drv );
extern LONG cdecl kernel_proc_info( WORD code, PD *pd );
extern void cdecl kernel_conv_8_3( const char *from, char to[11] );
extern WORD cdecl kernel_match_8_3( const char *patt, const char *fname );
extern LONG eject( WORD fn, LONG devcode );
