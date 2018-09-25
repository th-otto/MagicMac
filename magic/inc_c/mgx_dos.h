/*      MGX_DOS.H

     MagiC GEMDOS/(X)BIOS Definition Includes

	Andreas Kromke
	31.1.98

	- 20.8.99: SLB_EXEC und Slbclose korrigiert
*/


#ifndef LONG
#include <portab.h>
#endif
#ifndef NULL
#define NULL        ((void *)0L)
#endif
#ifndef EOS
#define EOS         '\0'
#endif

#if !defined( __TOS )
#define __TOS


/* File Access Types */

#define RMODE_RD 0
#define RMODE_WR 1
#define RMODE_RW 2

/* Device Identifiers  (BIOS) */

#define PRT	0
#define AUX	1
#define CON	2
#define MIDI	3
#define IKBD	4
#define RAWCON	5		   /* no control- characters */

/* GEMDOS- Device- Handles */

#define HDL_CON -1
#define HDL_AUX -2
#define HDL_PRN -3
#define HDL_NUL -4		   /* KAOS extension */

/* GEMDOS- Standard- Handles */

#define STDIN	 0
#define STDOUT	 1
#define STDAUX	 2
#define STDPRN	 3
#define STDERR	 4
#define STDXTRA 5

/* File Attributes */

#define F_RDONLY 0x01
#define F_HIDDEN 0x02
#define F_SYSTEM 0x04
#define F_VOLUME 0x08
#define F_SUBDIR 0x10
#define F_ARCHIVE 0x20

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */
#define XEXE_INIT   101                                     /* MAG!X      */
#define XEXE_TERM   102                                     /* MAG!X      */
#define XEXE_XBASE  107                                     /* Mag!X 2.10 */
#define XEXE_EXACC  108                                     /* Mag!X 2.10 */


/* GEMDOS (MiNT) Fopen modes */

#define   OF_RDONLY       0
#define   OF_WRONLY       1
#define   OF_RDWR         2
#define   OF_APPEND       8
#define   OF_COMPAT       0
#define   OF_DENYRW       0x10
#define   OF_DENYW        0x20
#define   OF_DENYR        0x30
#define   OF_DENYNONE     0x40
#define   OF_CREAT        0x200
#define   OF_TRUNC        0x400
#define   OF_EXCL         0x800

/* GEMDOS Fseek Modes */

#define SEEK_SET    0                                       /* TOS */
#define SEEK_CUR    1                                       /* TOS */
#define SEEK_END    2                                       /* TOS */

/* Psemaphore */

#define PSEM_CRGET       0                                  /* MagiC 3.0 */
#define PSEM_DESTROY     1
#define PSEM_GET         2
#define PSEM_RELEASE     3

/* Dlock modes */

#define DLOCKMODE_LOCK   1
#define DLOCKMODE_UNLOCK 0
#define DLOCKMODE_GETPID 2

/* Dopendir modes */

#define DOPEN_COMPAT     1
#define DOPEN_NORMAL     0

/* Fxattr modes */

#define FXATTR_RESOLVE	0
#define FXATTR_NRESOLVE	1

/* Pdomain modes */

#define PDOM_TOS         0
#define PDOM_MINT        1

/* Modi und Codes fr Dpathconf() (-> MiNT) */

#define   DP_MAXREQ      (-1)
#define   DP_IOPEN       0
#define   DP_MAXLINKS    1
#define   DP_PATHMAX     2
#define   DP_NAMEMAX     3
#define   DP_ATOMIC      4
#define   DP_TRUNC       5
#define    DP_NOTRUNC    0
#define    DP_AUTOTRUNC  1
#define    DP_DOSTRUNC   2
#define   DP_CASE        6
#define    DP_CASESENS   0
#define    DP_CASECONV   1
#define    DP_CASEINSENS 2
#define DP_MODEATTR		7
#define	DP_ATTRBITS	0x000000ffL
#define	DP_MODEBITS	0x000fff00L
#define	DP_FILETYPS	0xfff00000L
#define	DP_FT_DIR		0x00100000L
#define	DP_FT_CHR		0x00200000L
#define	DP_FT_BLK		0x00400000L
#define	DP_FT_REG		0x00800000L
#define	DP_FT_LNK		0x01000000L
#define	DP_FT_SOCK	0x02000000L
#define	DP_FT_FIFO	0x04000000L
#define	DP_FT_MEM		0x08000000L
#define DP_XATTRFIELDS	8
#define	DP_INDEX		0x0001
#define	DP_DEV		0x0002
#define	DP_RDEV		0x0004
#define	DP_NLINK		0x0008
#define	DP_UID		0x0010
#define	DP_GID		0x0020
#define	DP_BLKSIZE	0x0040
#define	DP_SIZE		0x0080
#define	DP_NBLOCKS	0x0100
#define	DP_ATIME		0x0200
#define	DP_CTIME		0x0400
#define	DP_MTIME		0x0800

/* additional Dcntl/Fcntl Modes */

#define KER_DRVSTAT			0x0104	/* Kernel: Drive-Status (ab 9.9.95) */
#define KER_XFSNAME			0x0105	/* Kernel: XFS-Name (ab 15.6.96) */


typedef struct
{
        unsigned int  time;
        unsigned int  date;
} DOSTIME;


typedef struct          /* used by Iorec */
{
        void    *ibuf;
        int     ibufsiz;
        int     ibufhd;
        int     ibuftl;
        int     ibuflow;
        int     ibufhi;
} IOREC;


typedef struct          /* used by Kbdvbase */
{
        void    (*kb_midivec)();
        void    (*kb_vkbderr)();
        void    (*kb_vmiderr)();
        void    (*kb_statvec)();
        void    (*kb_mousevec)();
        void    (*kb_clockvec)();
        void    (*kb_joyvec)();
        void    (*kb_midisys)();
        void    (*kb_kbdsys)();
} KBDVBASE;


typedef struct          /* used by Pexec */
{
        unsigned char   length;
        char            command_tail[128];
} COMMAND;


typedef struct          /* used by Initmouse */
{
        char    topmode;
        char    buttons;
        char    x_scale;
        char    y_scale;
        int     x_max;
        int     y_max;
        int     x_start;
        int     y_start;
} MOUSE;


typedef struct          /* used by Keytbl */
{
        char *unshift;
        char *shift;
        char *capslock;
} KEYTAB;


/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;

/****** Tos *************************************************************/

/* Memory Control Block */

typedef struct
     {
     long mcb_magic;                    /* 'ANDR' oder 'KROM' (letzter)    */
     long mcb_len;                      /* Nettol„nge                      */
     long mcb_owner;                    /* PD *                            */
     long mcb_prev;                     /* vorh. Block oder NULL           */
     char mcb_data[0];
     } MCB;

/************************************************************************/

#endif
