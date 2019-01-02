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

/*
 * Dont get fooled by C-library header files;
 * we need the kernel values here
 */
#undef O_NDELAY
#undef O_CREAT
#undef O_TRUNC
#undef O_EXCL
#undef O_NOATIME
#undef O_APPEND
#undef O_TTY
#undef O_NOCTTY
#undef O_DIRECT
#undef O_DIRECTORY
#undef O_LOCK
#undef O_NONBLOCK
#undef O_NOINHERIT
#undef O_SYNC
#undef O_COMPAT
#undef O_DENYRW
#undef O_DENYW
#undef O_DENYR
#undef O_DENYNONE
#undef O_SHMODE

#define O_NOATIME	0x00000004	/* Do not set atime.  */
#define O_APPEND	0x00000008	/* all writes go to end of file */
#define O_NOINHERIT 0x00000080  /* not inherited by child upon fork() */
#define O_NDELAY	0x00000100	/* don't block for I/O on this file */
#define O_NONBLOCK O_NDELAY
#define O_CREAT		0x00000200
#define O_TRUNC		0x00000400
#define O_EXCL		0x00000800
#define O_TTY		0x00002000
#define O_LOCK		0x00008000
#define O_DIRECTORY 0x00010000UL
#define O_DIRECT    0 /* NYI */
#define O_SYNC		0 /* NYI */

#define O_COMPAT	0x00	/* old TOS compatibility mode */
#define O_DENYRW	0x10	/* deny both reads and writes */
#define O_DENYW		0x20
#define O_DENYR		0x30
#define O_DENYNONE	0x40	/* don't deny anything */
#define O_SHMODE	0x70	/* mask for file sharing mode */

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
