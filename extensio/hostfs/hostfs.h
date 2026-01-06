/*
 *
 * Global functions of HOST-XFS for MagiC
 *
 * (C) Thorsten Otto 2018
 *
 */

#include <portab.h>
#include <stddef.h>
#include <toserror.h>
#include <tos.h>
#define PD BASEPAGE
typedef void APPL;
#include "mgx_xfs.h"
#include "mgx_devd.h"
#include "nfapi.h"
#include "ktypes.h"
#include "mxkernel.h"

/*
 * set this to 1 to add some additional checks that should
 * normally be unneeded
 */
#define PARANOIA 1

/*
 * set this to 1 to turn on tracing using NF_STDERR output
 */
#define DEBUG 1

#if DEBUG
#include <mint/arch/nf_ops.h>
#define DEBUGPRINTF(x) nf_debugprintf x
#else
#define DEBUGPRINTF(x)
#endif

# ifndef str
# define str(x)		_stringify(x)
# define _stringify(x)	#x
# endif

#define MSG_VERSION	str (HOSTFS_XFS_VERSION) "." str (HOSTFS_NFAPI_VERSION)
#define MSG_BUILDDATE	__DATE__

/*
 * maximum length of filenames we allow.
 * Needed because in MagiC, the XFS has to
 * do the parsing.
 */
#define HOSTFS_NAMEMAX 255

#define MSG_PFAILURE(p,s) \
    "Sorry, hostfs.xfs NOT installed: " s "!\r\n"

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

/**** structures ****/

#if PARANOIA
#define DD_MAGIC 0x484f4444UL
#define FD_MAGIC 0x484f4644UL
#define DHD_MAGIC 0x484f4448UL
#endif

/*
 * size of the following structures must not exceed internal file descriptor
 * size of the kernel (FDSIZE, currently 94 bytes)
 */

typedef struct {
	unsigned short len;
	char name[1];
} MX_SYMLINK;

/*
 * Descriptor for a directory path
 */
typedef struct hostxfs_dd
{
	MX_DD dd;
	WORD dd_mode; /* not used; corresponds to fd_mode */
	const MX_DEV *dd_dev; /* not used; corresponds to fd_dev */
#if PARANOIA
	unsigned long dd_magic;
#endif
	unsigned short st_mode;
	struct hostxfs_dd *dd_parent;
	MX_SYMLINK *dd_symlink;
	fcookie fc;
} HOSTXFS_DD;

/*
 * Descriptor for an open file
 */
typedef struct hostxfs_fd
{
	MX_FD fd;
#if PARANOIA
	unsigned long fd_magic;
#endif
	unsigned short st_mode;
	MINT_FILEPTR fp;
} HOSTXFS_FD;

/*
 * Descriptor for a directory handle
 */
typedef struct hostxfs_dhd
{
	MX_DHD dhd;
	WORD      dhd_refcnt;
	WORD      dhd_mode;
	MX_DEV    *dhd_dev;
#if PARANOIA
	unsigned long dhd_magic;
#endif
	MINT_DIR dir;
} HOSTXFS_DHD;

#define MAX_DRIVES 32
extern unsigned long nf_hostfs_id;
extern HOSTXFS_DD *mydrives[MAX_DRIVES];

HOSTXFS_DD *get_root_dd(UWORD drv);

/*
 * from nfapi.c
 */
extern long nf_get_id(const char *feature_name);

/**** internal stuff ****/

extern CDECL_MX_XFS const cdecl_hostxfs;
extern CDECL_MX_DEV const cdecl_hostdev;

/* Hier die Assembler-Schnittstelle */

extern MX_XFS hostxfs;
extern MX_DEV const hostdev;
